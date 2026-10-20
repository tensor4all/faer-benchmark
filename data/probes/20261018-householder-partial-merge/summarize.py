"""Reproduce the completed stage1 diagnostic decision; never an adoption gate."""
import json
import math
from pathlib import Path
import statistics

root = Path(__file__).resolve().parent/'householder'
rows = json.loads((root/'comparison.json').read_text())['cells']
assert len(rows) == 144
controls, guards = [], []
for row in rows:
    a, b = (row['start_medians_ms'][k] for k in ('A', 'B'))
    assert len(a) == len(b) == 3
    row['rotation_averaged_ratio'] = math.exp(statistics.mean(math.log(y)-math.log(x) for x,y in zip(a,b)))
    row['outside_baseline_range_5pct'] = not min(a)*.95 <= statistics.median(b) <= max(a)*1.05
    if row['cell']['row'] == 'faer-upstream':
        controls.append(row)
    elif row['rotation_averaged_ratio'] > 1.05:
        guards.append(row)
assert len(controls) == 72 and guards
outcome = dict(
    diagnostic_only=True, adopted=False,
    decision='NOT ADOPTED; stage1 guard deterioration, downstream NOT RUN',
    complete_timed_cell_identities=len(rows), starts_per_binary_per_cell=3, repetitions=5,
    upstream_control_cells=len(controls),
    upstream_outside_baseline_range_5pct=sum(r['outside_baseline_range_5pct'] for r in controls),
    guard_deteriorations=guards,
    pre_execution_rejections=[dict(log=p.name,count=p.read_text().count('busy before run'))
                              for p in sorted(root.glob('*.log')) if 'busy before run' in p.read_text()],
    rejected_archives=[str(p.relative_to(root)) for p in root.rglob('*.rejected.*') if p.is_dir()],
)
(root/'outcome.json').write_text(json.dumps(outcome,indent=2)+'\n')
print(json.dumps(outcome,indent=2))
