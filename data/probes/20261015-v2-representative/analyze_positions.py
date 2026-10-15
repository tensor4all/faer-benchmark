#!/usr/bin/env python3
"""Position/rotation analysis of the representative controls (read-only evidence).

The controls run three engine rows (faer-fork, faer-upstream, lapack-vendor) per
cell and three process starts whose row rotation is a cyclic shift of the
emitted engine list. What that design can and cannot identify:

  * For a cell where every engine has a successful row, the three starts form a
    3x3 Latin square: each engine is measured in each row position exactly once.
    Under the model
        log m[e, r] = alpha_e + beta_r + gamma_position(e, r),
    i.e. one position effect shared by the engines and stable across process
    starts, the averaged log-ratio cancels gamma exactly. Engine x position
    interactions, predecessor/history effects and process x position
    interactions are NOT cancelled; the per-rotation ratios are therefore printed
    next to the average so that rotation dependence stays visible.
  * For a cell where an engine has no row at all (for example the vendor skips
    `full_piv_lu`, square `triangular_solve` or Householder), the emitted skip
    keeps an emission position but no measured work happens in it, so the
    remaining engines are NOT a Latin square and the averaged ratio of the
    measured engines keeps a residual position factor. Those cells are reported
    as `unbalanced` and no position effect is estimated from them.
  * Cells without both faer rows, or without all three process starts, get no
    ratio at all.

Ratios are time ratios: `R > 1` means engine A took longer than engine B. The
script never discards samples, never pools variants or dtypes, and reports
descriptive quantities only.
"""
import csv
import math
import statistics
import sys
from collections import defaultdict
from pathlib import Path

import yaml
from campaign_toolkit import timing_evidence

HERE = Path(__file__).resolve().parent
WARN = math.log(1.05)


def load():
    cells = defaultdict(dict)   # key -> {rotation: {engine: log median}}
    spread = defaultdict(list)
    engines = {}
    for contract in sorted(HERE.glob('*/*t/control-contract.yaml')):
        manifest = yaml.safe_load(contract.read_text())
        timing_evidence.validate(manifest, contract.parent)
        for name in manifest['result_files']:
            rotation = int(name.split('-')[0][3:])
            for row in csv.DictReader((contract.parent / name).open(newline='')):
                engines[(manifest['vendor']['name'], row['regime'], row['threads'])] = manifest['run_spec']['engines']
                if row['status'] != 'ok':
                    continue
                samples = timing_evidence.samples(row, manifest['timing_policy']['repetitions'])
                key = (manifest['vendor']['name'], row['regime'], row['family'], row['dtype'], row['m'],
                       row['n'], row['k'], row['batch'], row['order'], row['note'], row['threads'])
                cells[key].setdefault(rotation, {})[row['row']] = math.log(statistics.median(samples))
                spread[key].append(statistics.stdev(samples) / statistics.median(samples))
    return cells, spread, engines


def main():
    cells, spread, declared = load()
    records = []
    for key, by_rotation in sorted(cells.items()):
        measured = sorted({e for rows in by_rotation.values() for e in rows})
        if 'faer-fork' not in measured or 'faer-upstream' not in measured or len(by_rotation) != 3:
            continue
        row = {'vendor': key[0], 'regime': key[1], 'family': key[2], 'dtype': key[3],
               'shape': f'{key[4]}x{key[5]}' + (f'x{key[6]}' if key[6] else ''), 'batch': key[7],
               'order': key[8], 'note': key[9], 'threads': key[10], 'measured_engines': len(measured),
               'declared_engines': len(declared[(key[0], key[1], key[10])]),
               'within_process_relative_sd': statistics.median(spread[key])}
        complete = len(measured) == row['declared_engines'] == 3 and all(
            len(rows) == 3 for rows in by_rotation.values())
        row['balanced'] = complete
        if complete:
            order = declared[(key[0], key[1], key[10])]
            positions = defaultdict(list)
            for rotation, rows in by_rotation.items():
                for engine, value in rows.items():
                    positions[(order[rotation:] + order[:rotation]).index(engine)].append(value)
            means = [statistics.fmean(v) for v in positions.values()]
            row['position_effect_ratio'] = math.exp(max(means) - min(means))
        else:
            row['position_effect_ratio'] = None
        for engine in measured:
            if engine == 'faer-fork':
                continue
            row[f'{engine}/fork averaged'] = math.exp(
                statistics.fmean(by_rotation[r][engine] - by_rotation[r]['faer-fork'] for r in by_rotation))
            naive = [math.exp(by_rotation[r][engine]) for r in by_rotation]
            base = [math.exp(by_rotation[r]['faer-fork']) for r in by_rotation]
            row[f'{engine}/fork naive'] = statistics.median(naive) / statistics.median(base)
            row[f'{engine}/fork per-rotation'] = ' '.join(
                f"{math.exp(by_rotation[r][engine] - by_rotation[r]['faer-fork']):.3f}" for r in sorted(by_rotation))
        records.append(row)

    out = HERE / 'position-analysis.txt'
    lines = ['# Rotation/position analysis of the v2 representative controls',
             '',
             '`R > 1` means the first engine took longer. `averaged` is the geometric mean of the',
             'three per-process ratios; `naive` is the ratio of per-engine median-of-three medians.',
             '`pos.eff` is exp(max-min) of the per-position mean log medians and is only defined for',
             'cells where every declared engine has a successful row (balanced design); `-` means the',
             'position effect is not identifiable there and the averaged ratio is not position-balanced.',
             'Engine x position interactions are not cancelled by the average; the per-rotation ratios',
             'are printed for that reason.',
             '',
             (f"{'cell':<44}{'dtype':<5}{'pos.eff':>8}{'bal':>5}{'withinSD':>9}"
              f"{'up/fork avg':>12}{'naive':>8}{'mkl/fork avg':>13}{'ob/fork avg':>12}"
              f"  per-rotation up/fork")]
    unbalanced = flags = 0
    for row in records:
        name = f"{row['vendor']}/{row['threads']}T {row['family']} {row['shape']} {row['order']}"
        if row['note']:
            name += f" [{row['note']}]"
        pos = f"{row['position_effect_ratio']:.3f}" if row['position_effect_ratio'] else '-'
        if row['position_effect_ratio'] and row['position_effect_ratio'] > 1.05:
            flags += 1
        if not row['balanced']:
            unbalanced += 1
        lines.append(
            f"{name:<44}{row['dtype']:<5}{pos:>8}{'yes' if row['balanced'] else 'no':>5}"
            f"{row['within_process_relative_sd']:>9.4f}"
            f"{row.get('faer-upstream/fork averaged', float('nan')):>12.4f}"
            f"{row.get('faer-upstream/fork naive', float('nan')):>8.3f}"
            f"{row.get('lapack-mkl/fork averaged', float('nan')):>13.4f}"
            f"{row.get('lapack-openblas/fork averaged', float('nan')):>12.4f}  "
            f"{row.get('faer-upstream/fork per-rotation', '')}")
    ratios = [row for row in records if row['balanced'] and row.get('position_effect_ratio')]
    disagree = sum(1 for row in records for engine in ('faer-upstream', 'lapack-mkl', 'lapack-openblas')
                   if row.get(f'{engine}/fork averaged') and row.get(f'{engine}/fork naive')
                   and abs(math.log(row[f'{engine}/fork naive']) - math.log(row[f'{engine}/fork averaged'])) > WARN)
    lines += ['',
              f"cells with both faer rows and three process starts: {len(records)}",
              f"cells where the averaged ratio is position-balanced (all engines measured): {len(ratios)}",
              f"cells where it is not (an engine has no row): {unbalanced}",
              f"balanced cells whose position effect exceeds the 5% ratio threshold: {flags}",
              (f"median position effect over balanced cells: "
               f"{statistics.median(r['position_effect_ratio'] for r in ratios):.4f}"),
              f"engine comparisons where `naive` differs from `averaged` by more than 5%: {disagree}",
              (f"median within-process relative SD: "
               f"{statistics.median(r['within_process_relative_sd'] for r in records):.4f}"),
              '',
              'Not established: any causal mechanism for the position or between-process variation,',
              'provider equality, or any result for the saved optimization candidate. The averaged',
              'ratio is only balanced under the shared-position model stated above.']
    out.write_text('\n'.join(lines) + '\n')
    print('\n'.join(lines[-9:]))
    print(f'wrote {out}')


if __name__ == '__main__':
    sys.exit(main())
