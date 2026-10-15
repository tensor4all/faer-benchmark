#!/usr/bin/env python3
"""Position analysis of the representative controls (read-only evidence).

The controls run three engine rows (faer-fork, faer-upstream, lapack-vendor) per
cell, and three process starts whose row rotation is a Latin square: over the
three processes each engine occupies each row position exactly once. That
balance means

  * the mean over processes of `log(median_i)` differences between two engines
    cancels an arbitrary per-position effect (each engine visits every position),
  * the per-position effect is itself estimable as the mean over the three
    observations that sat in that position.

This script reports, per (vendor, cell): the position-effect range (max-min of
per-position means of log medians), the position-adjusted engine ratios
exp(mean_j log(engine_j / fork_j)), the naive ratio of per-engine
median-of-process-medians, and the within-process sample SD share. It never
discards samples, never pools variants, and makes no inference beyond the
descriptive numbers it prints. Engine ratios here are baseline-vs-baseline
controls (fork vs upstream) plus the vendor row; they are not optimized-candidate
results.
"""
import csv
import json
import math
import statistics
import sys
from collections import defaultdict
from pathlib import Path

import yaml
from campaign_toolkit import timing_evidence

HERE = Path(__file__).resolve().parent


def load():
    cells = defaultdict(dict)   # (vendor, family, m, n, k, order, note, threads) -> {rot: {engine: log median}}
    spread = defaultdict(list)
    for contract in sorted(HERE.glob('*/*t/control-contract.yaml')):
        manifest = yaml.safe_load(contract.read_text())
        timing_evidence.validate(manifest, contract.parent)
        for name in manifest['result_files']:
            rotation = int(name.split('-')[0][3:])
            for row in csv.DictReader((contract.parent / name).open(newline='')):
                if row['status'] != 'ok':
                    continue
                samples = timing_evidence.samples(row, manifest['timing_policy']['repetitions'])
                key = (manifest['vendor']['name'], row['family'], row['m'], row['n'], row['k'],
                       row['order'], row['note'], row['threads'])
                cells[key].setdefault(rotation, {})[row['row']] = math.log(statistics.median(samples))
                spread[key].append(statistics.stdev(samples) / statistics.median(samples))
    return cells, spread


def main():
    cells, spread = load()
    records = []
    for key, by_rotation in sorted(cells.items()):
        engines = sorted({e for rows in by_rotation.values() for e in rows})
        if len(by_rotation) != 3 or len(engines) < 2:
            continue
        positions = defaultdict(list)   # position -> log medians
        rows = {}
        for rotation, measured in by_rotation.items():
            for engine, value in measured.items():
                rows[(engine, rotation)] = value
        if len(rows) != len(engines) * 3:
            continue
        # position of engine e inside rotation r: engines[r:] + engines[:r]
        for engine, rotation in rows:
            order = engines[rotation:] + engines[:rotation]
            positions[order.index(engine)].append(rows[(engine, rotation)])
        record = {
            'vendor': key[0], 'family': key[1], 'shape': f"{key[2]}x{key[3]}" + (f"x{key[4]}" if key[4] else ''),
            'order': key[5], 'note': key[6], 'threads': key[7], 'engines': len(engines),
            'position_effect_range': max(statistics.fmean(v) for v in positions.values())
                                     - min(statistics.fmean(v) for v in positions.values()),
            'within_process_relative_sd': statistics.median(spread[key]),
        }
        for engine in engines:
            if engine == 'faer-fork':
                continue
            adjusted = statistics.fmean(rows[(engine, r)] - rows[('faer-fork', r)] for r in by_rotation)
            raw = {e: [rows[(e, r)] for r in by_rotation] for e in (engine, 'faer-fork')}
            naive = math.log(statistics.median([math.exp(v) for v in raw[engine]])) - \
                    math.log(statistics.median([math.exp(v) for v in raw['faer-fork']]))
            record[f'{engine}/fork adjusted'] = math.exp(adjusted)
            record[f'{engine}/fork naive'] = math.exp(naive)
            record[f'{engine}/fork per-rotation'] = ' '.join(
                f"{math.exp(rows[(engine, r)] - rows[('faer-fork', r)]):.3f}" for r in sorted(by_rotation))
        records.append(record)
    out = HERE / 'position-analysis.txt'
    lines = ['# Row-position and engine-effect analysis of the v2 representative controls',
             '',
             'Derived from the retained control CSVs by `analyze_positions.py`; engine ratios are',
             'rotation-averaged (position-balanced) unless the column says naive. The balanced',
             '3x3 row rotation cancels an arbitrary per-position effect in the averaged ratio,',
             'while the per-process median-of-medians comparison does not.',
             '',
             f"{'cell':<42} {'pos.eff':>7} {'withinSD':>8} {'up/fork adj':>11} {'up/fork naive':>13} "
             f"{'mkl/fork adj':>12} {'per-rotation up/fork':<24}"]
    flagged_position = flagged_naive = 0
    for record in records:
        name = f"{record['vendor']}/{record['threads']}T {record['family']} {record['shape']} {record['order']}"
        if record['note']:
            name += f" [{record['note']}]"
        lines.append(f"{name:<42} {record['position_effect_range']:>7.3f} {record['within_process_relative_sd']:>8.4f} "
                     f"{record.get('faer-upstream/fork adjusted', float('nan')):>11.4f} "
                     f"{record.get('faer-upstream/fork naive', float('nan')):>13.4f} "
                     f"{record.get('lapack-mkl/fork adjusted', float('nan')):>12.4f} "
                     f"{record.get('faer-upstream/fork per-rotation', ''):<24}")
        if record['position_effect_range'] > math.log(1.05):
            flagged_position += 1
        for engine in ('faer-upstream', 'lapack-mkl', 'lapack-openblas'):
            adjusted, naive = record.get(f'{engine}/fork adjusted'), record.get(f'{engine}/fork naive')
            if adjusted and naive and abs(math.log(naive) - math.log(adjusted)) > math.log(1.05):
                flagged_naive += 1
    lines += ['',
              f"cells analysed: {len(records)}",
              f"cells whose position effect exceeds 5% of the level: {flagged_position}",
              f"engine comparisons where the naive ratio differs from the position-adjusted ratio by >5%: {flagged_naive}",
              f"median position-effect range: {statistics.median(r['position_effect_range'] for r in records):.4f}",
              f"median within-process relative SD: {statistics.median(r['within_process_relative_sd'] for r in records):.4f}",
              '',
              'Not claimed here: any causal mechanism for the position or process-level shifts, any',
              'provider equality, or any optimized-candidate performance result.']
    out.write_text('\n'.join(lines) + '\n')
    print('\n'.join(lines[-8:]))
    print(f'wrote {out}')


if __name__ == '__main__':
    sys.exit(main())
