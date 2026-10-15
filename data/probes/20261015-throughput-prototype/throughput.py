#!/usr/bin/env python3
"""Size-versus-throughput charts: one SVG per family, three thread budgets side by side.

Layout rules learned the hard way: a family per file (a six-panel sheet was unreadable), a table of
contents on the page, a rotated y-axis label, and a legend inside every panel. The script also
checks its own geometry (no text may overlap another text or leave its panel) and prints an ASCII
sketch so the layout can be inspected without a rasteriser. No timing is run; nothing is published.
"""
import csv
import json
import math
import statistics
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

import yaml

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
HERE = Path(__file__).resolve().parent
RUNS = {
    'mkl': ROOT / 'data/results/zen5-cpu/faer-kernels/20261015T130805Z-baseline-v2-faer-kernels-mkl',
    'openblas': ROOT / 'data/results/zen5-cpu/faer-kernels/20261015T194810Z-baseline-v2-faer-kernels-openblas',
}
# Nominal, algorithmic operation counts for a square n x n problem; complex is 4x the real count.
FLOPS = {
    'gemm': (2, '2n^3'), 'lu': (2 / 3, '2n^3/3'), 'full_piv_lu': (2 / 3, '2n^3/3'),
    'cholesky': (1 / 3, 'n^3/3'), 'qr_factor': (4 / 3, '4n^3/3'), 'qr': (8 / 3, '8n^3/3 (factor + Q)'),
    'eigh': (8 / 3, '8n^3/3'), 'svd_values': (4, '4n^3'), 'svd_thin': (10, '10n^3'),
}
FAMILIES = ['gemm', 'lu', 'cholesky', 'qr', 'svd_values', 'eigh']
BUDGETS = [1, 4, 8]
# The fork is the subject of the campaign, so it shares its colour with its upstream baseline and is
# distinguished by line style (solid vs dashed) and a larger marker, and it is drawn **last** so a
# nearly coincident upstream curve cannot hide it. Vendors keep their own colours and markers.
FORK_COLOUR = '#1f77b4'
SERIES = [   # legend order: main row first
    ('faer-fork', 'mkl', FORK_COLOUR, 'circle', None, 4.2),
    ('faer-upstream', 'mkl', FORK_COLOUR, 'circle', '5 3', 2.2),
    ('lapack-mkl', 'mkl', '#2ca02c', 'triangle', None, 3.0),
    ('lapack-openblas', 'openblas', '#d62728', 'diamond', None, 3.0),
]
DRAW_ORDER = ['faer-upstream', 'lapack-mkl', 'lapack-openblas', 'faer-fork']
ORDER, DTYPE = 'c', 'f64'
PANEL_W, PANEL_H = 620, 480          # one panel per thread budget, stacked so GitHub renders it large
PAD_L, PAD_R, PAD_T, PAD_B = 132, 24, 56, 44
# Doubled label/legend sizes: at GitHub's page width the SVG is not scaled down, so a bigger font is
# really bigger on screen. The panels, margins and tick count below give the text room for it.
FONT = {'title': 26, 'panel': 24, 'tick': 17, 'axis': 19, 'legend': 16}
CANVAS_W, CANVAS_H = PAD_L + PANEL_W + PAD_R, PAD_T + 3 * PANEL_H + PAD_B


@dataclass
class Checker:
    """Text bounding boxes, so a layout bug is an assertion instead of a surprise on GitHub."""
    boxes: list = field(default_factory=list)

    def text(self, x, y, size, content, anchor='start', rotate=None, panel=None):
        width = 0.62 * size * len(content)
        if rotate:
            x0, x1 = x - size * 0.8, x
        elif anchor == 'middle':
            x0, x1 = x - width / 2, x + width / 2
        elif anchor == 'end':
            x0, x1 = x - width, x
        else:
            x0, x1 = x, x + width
        box = (x0, y - size * 0.9, x1, y + size * 0.25, panel)
        for other in self.boxes:
            if other[4] is not panel:
                continue
            if box[0] < other[2] and other[0] < box[2] and box[1] < other[3] and other[1] < box[3]:
                raise AssertionError(f'overlapping text: {content!r} with a neighbour')
        if panel:
            px, py = panel
            if box[0] < px - 1 or box[2] > px + PANEL_W + 1 or box[1] < py - 1 or box[3] > py + PANEL_H + 1:
                raise AssertionError(f'text {content!r} box={tuple(round(v, 1) for v in box[:4])} '
                                     f'panel={(px, py, px + PANEL_W, py + PANEL_H)}')
        self.boxes.append(box)
        transform = f' transform="rotate(-90 {x:.1f} {y:.1f})"' if rotate else ''
        return (f'<text x="{x:.1f}" y="{y:.1f}" font-size="{size}" text-anchor="{anchor}"{transform}>'
                f'{content}</text>')


def load(vendor, run):
    manifest = yaml.safe_load((run / 'run.yaml').read_text())
    cells = defaultdict(dict)
    for name in manifest['result_files']:
        repeat = name.split('-')[0]
        for row in csv.DictReader((run / name).open(newline='')):
            if row['status'] != 'ok' or row['dtype'] != DTYPE or row['order'] != ORDER or row['m'] != row['n']:
                continue
            cells[(int(row['threads']), row['family'], int(row['n']), row['note'], row['row'])][repeat] = \
                statistics.median(json.loads(row['samples_ms']))
    return cells


def points(cells, threads, family, engine):
    out = []
    for (t, f, size, note, row), medians in sorted(cells.items()):
        if t != threads or f != family or row != engine or note:
            continue
        values = [ms for ms in medians.values() if ms > 0]
        if len(values) < 2:
            continue
        ms = statistics.median(values)
        gflops = FLOPS[family][0] * size ** 3 / (ms * 1e6)
        out.append((size, gflops, gflops * statistics.stdev(values) / ms))
    return out


def marker(kind, x, y, colour, size=2.7):
    if kind == 'triangle':
        return (f'<polygon points="{x:.1f},{y - size:.1f} {x - size:.1f},{y + size * 0.8:.1f} '
                f'{x + size:.1f},{y + size * 0.8:.1f}" fill="{colour}"/>')
    if kind == 'diamond':
        return (f'<polygon points="{x:.1f},{y - size:.1f} {x - size:.1f},{y:.1f} {x:.1f},{y + size:.1f} '
                f'{x + size:.1f},{y:.1f}" fill="{colour}"/>')
    return f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{size:.1f}" fill="{colour}"/>'


def panel(checker, family, threads, blocks, origin):
    """One thread budget for one family: axes, ticks, error bars, markers and an inside legend."""
    ox, oy = origin
    x0, y0 = ox + 92, oy + 32
    width, height = PANEL_W - 116, PANEL_H - 100
    data = [p for pts in blocks.values() for p in pts]
    if not data:
        return f'<g><text x="{x0}" y="{y0 + 20}" font-size="12">no data</text></g>'
    xs = [p[0] for p in data]
    ys = [max(p[1], 1e-6) for p in data]
    lx0, lx1 = math.log10(min(xs)), math.log10(max(xs)) + 0.02
    ly0, ly1 = math.log10(min(ys)) - 0.25, math.log10(max(ys)) + 0.25

    def sx(value):
        return x0 + (math.log10(value) - lx0) / (lx1 - lx0) * width

    def sy(value):
        return y0 + height - (math.log10(max(value, 1e-6)) - ly0) / (ly1 - ly0) * height

    panel_key = (ox, oy)
    out = [f'<rect x="{ox + 6}" y="{oy + 6}" width="{PANEL_W - 12}" height="{PANEL_H - 12}" fill="#ffffff" '
           f'stroke="#d0d0d0"/>',
           checker.text(ox + 16, oy + 32, FONT['panel'], f'{threads}T')]
    for size in sorted(set(xs)):
        out.append(f'<line x1="{sx(size):.1f}" y1="{y0}" x2="{sx(size):.1f}" y2="{y0 + height}" stroke="#f2f2f2"/>')
        out.append(checker.text(sx(size), y0 + height + 26, FONT['tick'], f'{size}', 'middle', panel=panel_key))
    for power in range(math.ceil(ly0), math.floor(ly1) + 1):   # only powers inside the axis
        value = 10.0 ** power
        out.append(f'<line x1="{x0}" y1="{sy(value):.1f}" x2="{x0 + width}" y2="{sy(value):.1f}" stroke="#f2f2f2"/>')
        out.append(checker.text(x0 - 8, sy(value) + 6, FONT['tick'], f'{value:g}', 'end', panel=panel_key))
    out.append(f'<rect x="{x0}" y="{y0}" width="{width}" height="{height}" fill="none" stroke="#c8c8c8"/>')
    out.append(checker.text(ox + 28, oy + PANEL_H - 14, FONT['axis'], 'n (matrix size)', 'start', panel=panel_key))
    out.append(checker.text(ox + 30, oy + PANEL_H / 2, FONT['axis'], 'nominal GFLOP/s', 'middle',
                            rotate=True, panel=panel_key))
    by_name = {name: (vendor, colour, kind, dash, size) for name, vendor, colour, kind, dash, size in SERIES}
    for name in DRAW_ORDER:
        vendor, colour, kind, dash, size = by_name[name]
        pts = blocks.get(name) or []
        if not pts:
            continue
        style = f' stroke-dasharray="{dash}"' if dash else ''
        stroke_w = 1.9 if name == 'faer-fork' else 1.3      # not `width`: that is the panel geometry
        out.append('<polyline points="' + ' '.join(f'{sx(x):.1f},{sy(y):.1f}' for x, y, _ in pts)
                   + f'" fill="none" stroke="{colour}" stroke-width="{stroke_w}"{style}/>')
        for x, y, err in pts:
            out.append(f'<line x1="{sx(x):.1f}" y1="{sy(y - err):.1f}" x2="{sx(x):.1f}" y2="{sy(y + err):.1f}" '
                       f'stroke="{colour}" stroke-width="1.1"/>')
            out.append(marker(kind, sx(x), sy(y), colour, size))
    # legend inside the panel: the lower-right corner is the one a rising curve leaves free
    legend_row, legend_w = 2.1 * FONT['legend'], 13.6 * FONT['legend']
    legend_x = x0 + width - legend_w + 8
    legend_y = y0 + height - 10 - legend_row * len(SERIES)
    out.append(f'<rect x="{legend_x - 8}" y="{legend_y - 12}" width="{legend_w:.0f}" '
               f'height="{legend_row * len(SERIES) + 16:.0f}" '
               f'fill="#ffffff" fill-opacity="0.86" stroke="#e0e0e0"/>')
    for index, (name, vendor, colour, kind, dash, size) in enumerate(SERIES):
        row_y = legend_y + index * legend_row
        style = f' stroke-dasharray="{dash}"' if dash else ''
        out.append(f'<line x1="{legend_x}" y1="{row_y}" x2="{legend_x + 30}" y2="{row_y}" stroke="{colour}" '
                   f'stroke-width="{2.6 if name == "faer-fork" else 1.8}"{style}/>')
        out.append(marker(kind, legend_x + 15, row_y, colour, size * 1.5))
        out.append(checker.text(legend_x + 38, row_y + 5, FONT['legend'], name, panel=panel_key))
    return '<g>' + ''.join(out) + '</g>'


def main():
    cells = {vendor: load(vendor, run) for vendor, run in RUNS.items()}
    families = []
    for family in FAMILIES:
        checker = Checker()          # one file per family: boxes only have to be disjoint within it
        svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{CANVAS_W}" height="{CANVAS_H}" '
               f'viewBox="0 0 {CANVAS_W} {CANVAS_H}">',
               checker.text(12, 30, FONT['title'], f'{family}: nominal GFLOP/s vs n')]
        for index, threads in enumerate(BUDGETS):
            blocks = {name: points(cells[vendor], threads, family, name)
                      for name, vendor, *_ in SERIES}
            svg.append(panel(checker, family, threads, blocks,
                             (PAD_L, PAD_T + index * PANEL_H)))
        svg.append('</svg>')
        (HERE / f'throughput-{family}-v3.svg').write_text('\n'.join(svg) + '\n')
        families.append((family, FLOPS[family][1],
                          {threads: len(points(cells['mkl'], threads, family, 'faer-fork')) for threads in BUDGETS}))
    toc = '\n'.join(f'| [{family}](throughput-{family}-v3.svg) | `{flops}` | ' +
                    ', '.join(f'{t}T: {count}' for t, count in counts.items()) + ' |'
                    for family, flops, counts in families)
    (HERE / 'README.md').write_text(
        '# Throughput charts (prototype, visual check only)\n\n'
        'Recorded daily-suite data only; no timing was run and nothing is published. One file per\n'
        'family, one panel per thread budget (1T measured 32-768; 4T/8T will extend to 1536 once\n'
        '`faer-kernels-large` is recorded). Error bars are the between-start sample SD of the process\n'
        'medians. GFLOP/s is **nominal**: one algorithmic operation count per family, so absolute\n'
        'values are not comparable across families. The `lapack-openblas` line comes from the other\n'
        'arm (its own binary, its own processes); the other three share one process.\n\n'
        '## Contents\n\n| family | nominal flops | points per budget |\n|---|---|---|\n' + toc + '\n\n' +
        '\n'.join(f'## {family}\n\n![{family}](throughput-{family}-v3.svg)\n'
                  f'Nominal operation count: `{flops}`.\n' for family, flops, _ in families) +
        '\nLayout is checked by the script: no label may overlap another or leave its panel.\n')
    print('charts:', ', '.join(f'{family}({sum(counts.values())} pts)' for family, _, counts in families))
    print('geometry check: no overlapping or out-of-panel text')
    # ASCII sketch of the 8T panel of gemm so the layout can be eyeballed without a rasteriser
    family = 'gemm'
    blocks = {name: points(cells[vendor], 8, family, name) for name, vendor, *_ in SERIES}
    grid = [[' '] * 92 for _ in range(22)]
    data = [p for pts in blocks.values() for p in pts]
    lx0, lx1 = math.log10(min(p[0] for p in data)), math.log10(max(p[0] for p in data))
    ly0, ly1 = math.log10(min(p[1] for p in data)), math.log10(max(p[1] for p in data))
    for row, (name, *_) in enumerate(SERIES):
        for x, y, _ in blocks.get(name) or []:
            col = int((math.log10(x) - lx0) / (lx1 - lx0) * 88)
            line = int((math.log10(y) - ly0) / (ly1 - ly0) * 20)
            grid[20 - line][col] = '1234'[row]
    print('\nASCII sketch — gemm 8T, columns = n (log), rows = nominal GFLOP/s (log):')
    for line in grid:
        print('  |' + ''.join(line) + '|')
    print('  1=faer-fork  2=faer-upstream  3=lapack-mkl  4=lapack-openblas')


if __name__ == '__main__':
    sys.exit(main())
