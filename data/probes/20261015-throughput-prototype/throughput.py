#!/usr/bin/env python3
"""Size-versus-throughput prototype: 1T / 4T / 8T, small multiples per family, four engines.

Reads the two recorded daily-suite runs (MKL arm for fork/upstream/mkl, OpenBLAS arm for the
openblas row), takes the median of the process medians per cell and the between-start sample SD as
the error bar, converts to **nominal** GFLOP/s with one operation count per family, and writes one
SVG per thread budget plus a markdown page. No timing is run and nothing is published.
"""
import csv
import json
import math
import statistics
import sys
from collections import defaultdict
from pathlib import Path

import yaml

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
HERE = Path(__file__).resolve().parent
RUNS = {
    'mkl': ROOT / 'data/results/zen5-cpu/faer-kernels/20261015T130805Z-baseline-v2-faer-kernels-mkl',
    'openblas': ROOT / 'data/results/zen5-cpu/faer-kernels/20261015T194810Z-baseline-v2-faer-kernels-openblas',
}
# Nominal operation counts for a square n x n problem. They are algorithmic, not measured, so the
# page must call the result "nominal GFLOP/s" and must not compare absolute values across families.
FLOPS = {
    'gemm': lambda n, c: 2 * n ** 3 * (4 if c else 1),          # c64 is a complex product: 8 flops/elt
    'lu': lambda n, c: 2 / 3 * n ** 3 * (4 if c else 1),
    'full_piv_lu': lambda n, c: 2 / 3 * n ** 3 * (4 if c else 1),
    'cholesky': lambda n, c: 1 / 3 * n ** 3 * (4 if c else 1),
    'qr_factor': lambda n, c: 4 / 3 * n ** 3 * (4 if c else 1),
    'qr': lambda n, c: 8 / 3 * n ** 3 * (4 if c else 1),        # factor + explicit Q
    'eigh': lambda n, c: 8 / 3 * n ** 3 * (4 if c else 1),
    'svd_values': lambda n, c: 4 * n ** 3 * (4 if c else 1),
    'svd_thin': lambda n, c: 10 * n ** 3 * (4 if c else 1),
}
PANELS = ['gemm', 'lu', 'cholesky', 'qr', 'svd_values', 'eigh']
SERIES = [('faer-fork', 'mkl', '#1f77b4'), ('faer-upstream', 'mkl', '#ff7f0e'),
          ('lapack-mkl', 'mkl', '#2ca02c'), ('lapack-openblas', 'openblas', '#d62728')]
ORDER = 'c'
DTYPE = 'f64'


def load(vendor, run):
    manifest = yaml.safe_load((run / 'run.yaml').read_text())
    cells = defaultdict(dict)          # (threads, family, shape, engine) -> repeat -> median ms
    for name in manifest['result_files']:
        repeat = name.split('-')[0]
        for row in csv.DictReader((run / name).open(newline='')):
            if row['status'] != 'ok' or row['dtype'] != DTYPE or row['order'] != ORDER:
                continue
            if row['m'] != row['n']:
                continue
            cells[(int(row['threads']), row['family'], int(row['n']), row['note'], row['row'])][repeat] = \
                statistics.median(json.loads(row['samples_ms']))
    return cells


def points(cells, threads, family, engine):
    """[(n, nominal GFLOP/s, between-start SD)] for one engine, in the cells this run measured."""
    out = []
    for (t, f, size, note, row), medians in sorted(cells.items()):
        if t != threads or f != family or row != engine or note:
            continue
        values = [ms for ms in medians.values() if ms > 0]
        if len(values) < 2:
            continue
        ms = statistics.median(values)
        gflops = FLOPS[family](size, False) / (ms * 1e6)
        out.append((size, gflops, gflops * statistics.stdev(values) / ms))
    return out


def panel_svg(family, threads, blocks):
    scale = 300
    x0, y0 = 46, 20
    width, height = scale - 56, scale - 60
    all_x = [p[0] for pts in blocks.values() for p in pts]
    all_y = [max(p[1], 1e-6) for pts in blocks.values() for p in pts]
    if not all_x:
        return f'<g><text x="{x0}" y="{y0 + 20}">no data</text></g>'
    lx0, lx1 = math.log10(min(all_x)), math.log10(max(all_x))
    ly0, ly1 = math.log10(min(all_y) / 2), math.log10(max(all_y) * 2)
    def sx(value):
        return x0 + (math.log10(value) - lx0) / (lx1 - lx0 or 1) * width
    def sy(value):
        return y0 + height - (math.log10(max(value, 1e-6)) - ly0) / (ly1 - ly0 or 1) * height
    parts = [f'<rect x="{x0}" y="{y0}" width="{width}" height="{height}" fill="none" stroke="#cccccc"/>',
             f'<text x="{x0 + width / 2}" y="{y0 + height + 32}" font-size="11" text-anchor="middle">n</text>',
             f'<text x="{x0 - 34}" y="{y0 + 12}" font-size="11">{family}</text>',
             f'<text x="{x0 - 30}" y="{y0 + 26}" font-size="9" fill="#666">nominal GFLOP/s</text>']
    for value in all_x:
        parts.append(f'<line x1="{sx(value):.1f}" y1="{y0}" x2="{sx(value):.1f}" y2="{y0 + height}" stroke="#f0f0f0"/>')
        parts.append(f'<text x="{sx(value):.1f}" y="{y0 + height + 14}" font-size="9" text-anchor="middle">{value}</text>')
    for power in range(int(math.floor(ly0)), int(math.ceil(ly1)) + 1):
        value = 10 ** power
        parts.append(f'<line x1="{x0}" y1="{sy(value):.1f}" x2="{x0 + width}" y2="{sy(value):.1f}" stroke="#f0f0f0"/>')
        parts.append(f'<text x="{x0 - 4}" y="{sy(value) + 3:.1f}" font-size="9" text-anchor="end">{value:g}</text>')
    for name, _, colour in SERIES:
        pts = blocks.get(name) or []
        if not pts:
            continue
        parts.append('<polyline points="' + ' '.join(f'{sx(x):.1f},{sy(y):.1f}' for x, y, _ in pts)
                     + f'" fill="none" stroke="{colour}" stroke-width="1.4"/>')
        for x, y, err in pts:
            parts.append(f'<line x1="{sx(x):.1f}" y1="{sy(y - err):.1f}" x2="{sx(x):.1f}" y2="{sy(y + err):.1f}" '
                         f'stroke="{colour}" stroke-width="1"/>')
            parts.append(f'<circle cx="{sx(x):.1f}" cy="{sy(y):.1f}" r="2.4" fill="{colour}"/>')
    return '<g>' + ''.join(parts) + '</g>'


def main():
    cells = {vendor: load(vendor, run) for vendor, run in RUNS.items()}
    pages = []
    for threads in (1, 4, 8):
        rows = (len(PANELS) + 2) // 3
        svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="960" height="{rows * 330 + 40}" '
               f'viewBox="0 0 960 {rows * 330 + 40}">',
               f'<text x="20" y="16" font-size="13">timing-v2 baseline, {threads}T, f64, C order — '
               f'nominal GFLOP/s vs n (median of process medians, error bar = between-start SD)</text>']
        for index, family in enumerate(PANELS):
            blocks = {name: points(cells[vendor], threads, family, name) for name, vendor, _ in SERIES}
            svg.append(f'<g transform="translate({56 + (index % 3) * 300}, {30 + (index // 3) * 330})">'
                       + panel_svg(family, threads, blocks) + '</g>')
        for series_index, (name, _, colour) in enumerate(SERIES):
            svg.append(f'<g transform="translate({56 + series_index * 210}, {rows * 330 + 22})">'
                       f'<line x1="0" y1="0" x2="18" y2="0" stroke="{colour}" stroke-width="1.6"/>'
                       f'<text x="24" y="4" font-size="11">{name}</text></g>')
        svg.append('</svg>')
        path = HERE / f'throughput-{threads}t.svg'
        path.write_text('\n'.join(svg) + '\n')
        pages.append(f'### {threads}T\n\n![{threads}T throughput](throughput-{threads}t.svg)\n')
        print(f'--- {threads}T (fork, nominal GFLOP/s)')
        for family in PANELS:
            pts = points(cells['mkl'], threads, family, 'faer-fork')
            if pts:
                print(f'  {family:<12}' + ' '.join(f'{size}:{value:.1f}' for size, value, _ in pts))
    (HERE / 'README.md').write_text(
        '# Throughput prototype (visual check only)\n\n'
        'Generated from the recorded daily-suite runs; no timing was run. **Nominal** GFLOP/s with one\n'
        'algorithmic operation count per family (GEMM 2n^3, LU 2n^3/3, Cholesky n^3/3, QR 8n^3/3 with Q,\n'
        'SVD values 4n^3, self-adjoint EVD 8n^3/3), median of process medians, error bar = between-start\n'
        'sample SD, C order, f64, one panel per family and one SVG per thread budget.\n\n'
        + '\n'.join(pages) +
        '\nThe `lapack-openblas` line comes from the other arm (a separate binary), so its absolute\n'
        'level carries the between-arm uncertainty; `faer-fork`/`faer-upstream`/`lapack-mkl` are one\n'
        'process. Sizes above 768 need the `faer-kernels-large` suite (4T/8T only).\n')
    print('\nwrote', HERE / 'throughput-1t.svg', 'and the 4T/8T equivalents')


if __name__ == '__main__':
    sys.exit(main())
