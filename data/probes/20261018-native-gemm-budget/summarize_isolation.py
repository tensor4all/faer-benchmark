"""Describe all96 isolated upstream cells; never replace the canonical control gate."""
import collections
import csv
import hashlib
import json
import statistics
from pathlib import Path

import isolate_controls as run

HERE = Path(__file__).resolve().parent
OUT = HERE / 'runtime-isolation'


def key(row):
    return tuple(dict(row, regime='native-control-isolation')[k] for k in run.FIELDS)


def describe(a, b):
    aa, bb = statistics.median(a), statistics.median(b)
    return {'A_process_ms': a, 'B_process_ms': b, 'median_B_over_A': bb / aa,
            'process_geomean_B_over_A': statistics.geometric_mean(y / x for x, y in zip(a, b, strict=True)),
            'B_median_outside_A_range_plusminus5pct': bb < min(a) * .95 or bb > max(a) * 1.05}


def main():
    completion = json.loads((OUT / 'complete.json').read_text())
    assert completion == {'blocks': 8, 'timing_processes': 72, 'verification_processes': 18, 'records': 768, 'adoption': False}
    wanted = run.expected()
    actual_files = set(OUT.glob('block[0-7]-?-*.csv'))
    expected_files = {OUT / f'block{block}-{side}-{family}-{t}t.csv'
                      for block, side in enumerate(run.SEQUENCE) for family in run.SHAPES for t in (1, 4, 8)}
    assert actual_files == expected_files and len(actual_files) == 72
    isolated = {s: collections.defaultdict(list) for s in 'AB'}
    for block, side in enumerate(run.SEQUENCE):
        counter = collections.Counter()
        for family in run.SHAPES:
            for t in (1, 4, 8):
                path = OUT / f'block{block}-{side}-{family}-{t}t.csv'
                run.audit(path, family, t, False)
                with path.open() as stream:
                    for row in csv.DictReader(stream):
                        k = key(row)
                        counter[k] += 1
                        isolated[side][k].append(float(row['total_ms']))
        assert counter == wanted
    context = json.loads((HERE / 'canonical-isolation-context.json').read_text())
    canonical = {s: collections.defaultdict(list) for s in 'AB'}
    for side, files in context['sources'].items():
        counters = collections.defaultdict(collections.Counter)
        for entry in files:
            path = run.ROOT / entry['path']
            assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256']
            with path.open() as stream:
                for row in csv.DictReader(stream):
                    k = key(row)
                    if k in wanted:
                        counters[entry['repeat']][k] += 1
                        canonical[side][k].append(float(row['total_ms']))
        assert set(counters) == {0, 1, 2} and all(c == wanted for c in counters.values())
    rows = []
    for k in sorted(wanted):
        assert len(isolated['A'][k]) == len(isolated['B'][k]) == 4
        assert len(canonical['A'][k]) == len(canonical['B'][k]) == 3
        rows.append({'cell': dict(zip(run.FIELDS, k, strict=True)),
                     'isolated': describe(isolated['A'][k], isolated['B'][k]),
                     'canonical': describe(canonical['A'][k], canonical['B'][k])})
    groups = []
    for family in run.SHAPES:
        for t in (1, 4, 8):
            cells = [r for r in rows if r['cell']['family'] == family and r['cell']['threads'] == str(t)]
            g = {'family': family, 'threads': t, 'cells': len(cells)}
            for arm in ('isolated', 'canonical'):
                g[arm + '_outside_diagnostic_band'] = sum(r[arm]['B_median_outside_A_range_plusminus5pct'] for r in cells)
                g[arm + '_geomean_of_median_ratios'] = statistics.geometric_mean(r[arm]['median_B_over_A'] for r in cells)
            groups.append(g)
    result = {'diagnostic_only': True, 'adoption': False, 'canonical_refusal_unchanged': True,
              'groups': groups, 'all_cells': rows,
              'limitation': 'Noncontemporaneous canonical/isolated campaigns; provider construction, allocation/worker/cache history differ. Persistence is binary association, not a causal mechanism. A quiet isolated subset cannot waive canonical controls/guards.'}
    (OUT / 'descriptive-comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(groups, indent=2))
    for r in rows:
        if r['isolated']['B_median_outside_A_range_plusminus5pct']:
            print('ISOLATED FLAG (descriptive)', r)


if __name__ == '__main__':
    main()
