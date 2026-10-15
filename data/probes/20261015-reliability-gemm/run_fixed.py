#!/usr/bin/env python3
"""Additional independent processes at one fixed setting, after the 12-cell pilot."""
import csv
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess

out = Path(__file__).resolve().parent
root = out.parents[2]
meta = json.loads((out / 'metadata.json').read_text())
assert len(meta['processes']) == 12  # Refuse to overwrite an already extended probe.
lock = (root / 'target/campaign.lock').open('a')
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
env = os.environ.copy()
for key in list(env):
    if key.startswith(('OPENBLAS_', 'OMP_', 'RAYON_', 'MKL_', 'PINNED_')):
        env.pop(key)
env.update(meta['environment'])
for vendor in ('mkl', 'openblas'):
    binary = Path(meta['binaries'][vendor]['path'])
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == meta['binaries'][vendor]['sha256']
meta['fixed_replication_schedule'] = ['mkl', 'openblas', 'openblas', 'mkl']
for index, vendor in enumerate(meta['fixed_replication_schedule'], 12):
    stem = f'{index:02d}-{vendor}-p3000-r0-fixed'
    cmd = [str(root / 'benchmarks/scripts/pinned.sh'), '4', '--', meta['binaries'][vendor]['path'],
           'run', '--threads', '1', '--n', '256x256x256,256x256x256', '--batch', '1',
           '--dtype', 'f64', '--family', 'gemm', '--regime', 'reliability-pilot',
           '--reps', '30', '--prime-ms', '3000', '--rotate-rows', '0',
           '--csv', str(out / f'{stem}.csv')]
    start = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=180, cwd=root)
    (out / f'{stem}.guard').write_text(result.stdout + result.stderr)
    meta['processes'].append({'index': index, 'vendor': vendor, 'prime_ms': 3000,
                              'rotation': 0, 'csv': f'{stem}.csv', 'command': cmd,
                              'started_utc': start, 'returncode': result.returncode,
                              'phase': 'fixed-setting replication'})
    (out / 'metadata.json').write_text(json.dumps(meta, indent=2) + '\n')
    if result.returncode:
        raise SystemExit(f'guard/command failed for {stem}; see log, no automatic retry')
    rows = list(csv.DictReader((out / f'{stem}.csv').open()))
    assert len(rows) == 12 and all(r['status'] == 'ok' and len(json.loads(r['samples_ms'])) == 30 for r in rows)
    print(stem, 'ok', flush=True)
