"""Audit this predeclared small grid and summarize all process medians."""
import collections
import csv
import itertools
import json
import math
from pathlib import Path
import statistics

out = Path(__file__).resolve().parent
data = collections.defaultdict(lambda: collections.defaultdict(list))
expected = set(itertools.product(('f64','c64'),('c','f'),('32','64','96','128')))
for path in sorted(out.glob('*.csv')):
    rows = list(csv.DictReader(path.open()))
    assert len(rows) == 16 and {(r['dtype'],r['order'],r['m']) for r in rows} == expected, path
    for row in rows:
        assert row['status'] == 'ok' and row['row'] == 'faer-upstream' and row['family'] == 'cholesky', path
        assert row['n'] == row['m'] and row['note'] == ''
        assert row['rayon_threads'] == row['threads']
        if path.name.startswith('verify'):
            continue
        samples = json.loads(row['samples_ms'])
        assert len(samples) == 5
        assert math.isclose(float(row['total_ms']),statistics.median(samples),abs_tol=0.000000500001)
        key = tuple(row[k] for k in ('threads','dtype','order','m','n','note'))
        data[key][path.stem.split('-')[1]].append(float(row['total_ms']))
assert len(list(out.glob('verify*.csv'))) == 4 and len(list(out.glob('process*.csv'))) == 16
assert len(data) == 32
result = []
for cell, values in sorted(data.items()):
    assert len(values['A']) == len(values['B']) == 4
    ratio = math.exp(statistics.mean(map(math.log,values['B']))-statistics.mean(map(math.log,values['A'])))
    result.append(dict(cell=cell,A_ms=values['A'],B_ms=values['B'],B_over_A=ratio))
(out / 'comparison.json').write_text(json.dumps(result,indent=2)+'\n')
print('Verified: 4 verification grids, 16 timing grids, 32 cells, 4 processes/binary/cell, all 5 samples retained.')
