#!/usr/bin/env python3
"""Bounded descriptive pilot, not a campaign performance publication."""
import csv
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys

root = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
out = Path(sys.argv[1]).resolve()
out.mkdir(parents=True, exist_ok=False)
lock = (root / 'target/campaign.lock').open('a')
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
env = os.environ.copy()
for key in ['OPENBLAS_NUM_THREADS', 'OMP_NUM_THREADS', 'RAYON_NUM_THREADS',
            'MKL_NUM_THREADS', 'MKL_DOMAIN_NUM_THREADS', 'MKL_INTERFACE_LAYER',
            'MKL_THREADING_LAYER', 'MKL_DYNAMIC', 'OMP_THREAD_LIMIT', 'OMP_PROC_BIND',
            'OMP_PLACES']:
    env.pop(key, None)
# Faer explicitly uses Par::Seq. Set and record the latent Rayon pool's budget too.
env['RAYON_NUM_THREADS'] = '1'
env['PINNED_RETRIES'] = '1'

def text(cmd, cwd=root):
    return subprocess.check_output(cmd, cwd=cwd, text=True, env=env).strip()

def git_id(path):
    return {'path': str(path), 'commit': text(['git', 'rev-parse', 'HEAD'], path),
            'status': text(['git', 'status', '--porcelain', '--untracked-files=no'], path)}

meta = {'purpose': 'descriptive reliability pilot, no speedup inference',
        'harness': git_id(root), 'fork': git_id(root.parent / 'faer'),
        'upstream': git_id(root / 'extern/upstream-faer'),
        'cpu': text(['lscpu']), 'cpu_set': '4', 'threads': 1,
        'faer_execution': 'Par::Seq for --threads 1; RAYON_NUM_THREADS=1',
        'environment': {k: v for k, v in env.items() if k.startswith(('OMP_', 'MKL_', 'OPENBLAS_', 'RAYON_', 'PINNED_'))},
        'processes': [], 'binaries': {}}
(out / 'harness.diff').write_text(text(['git', 'diff', 'HEAD']))
(out / 'run_pilot.py').write_text(Path(__file__).read_text())
meta['source_sha256'] = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                         for p in sorted((root / 'fbench/src').glob('*.rs'))}
for vendor in ('mkl', 'openblas'):
    pin = {}
    for line in Path(f'/tmp/reliability-{vendor}.env').read_text().splitlines():
        k, v = line.split('=', 1)
        pin[k] = shlex.split(v)[0] if v else ''
    binary = str(Path(pin['BIN_DIR']) / 'fbench')
    identity = text([binary, 'info', '--threads', '1'])
    assert f'vendor.name={vendor}' in identity and 'threads.vendor_reported=1' in identity
    assert 'threads.faer=sequential' in identity
    meta['binaries'][vendor] = {'path': binary, 'sha256': hashlib.sha256(Path(binary).read_bytes()).hexdigest(),
                                'build': pin, 'info': identity}
    # Correctness precedes measurement; assert marker, not just exit status.
    cmd = [str(root / 'benchmarks/scripts/pinned.sh'), '4', '--', binary,
           'verify', '--threads', '1', '--n', '256x256x256', '--dtype', 'f64', '--family', 'gemm']
    result = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=120, cwd=root)
    (out / f'{vendor}-verify.log').write_text(result.stdout + result.stderr)
    assert result.returncode == 0 and 'all comparisons within tolerance' in result.stdout

# Each vendor/prime arm receives all three positions. Alternate vendor and prime
# order so neither is always late. Still only three processes/arm: descriptive only.
schedule = []
for rotation in range(3):
    vendors = ('mkl', 'openblas') if rotation % 2 == 0 else ('openblas', 'mkl')
    for vi, vendor in enumerate(vendors):
        primes = (500, 3000) if (rotation + vi) % 2 == 0 else (3000, 500)
        for prime in primes:
            schedule.append((vendor, prime, rotation))
meta['schedule'] = schedule
(out / 'metadata.json').write_text(json.dumps(meta, indent=2) + '\n')
for index, (vendor, prime, rotation) in enumerate(schedule):
    stem = f'{index:02d}-{vendor}-p{prime}-r{rotation}'
    binary = meta['binaries'][vendor]['path']
    cmd = [str(root / 'benchmarks/scripts/pinned.sh'), '4', '--', binary, 'run',
           '--threads', '1', '--n', '256x256x256,256x256x256', '--batch', '1',
           '--dtype', 'f64', '--family', 'gemm', '--regime', 'reliability-pilot',
           '--reps', '30', '--prime-ms', str(prime), '--rotate-rows', str(rotation),
           '--csv', str(out / f'{stem}.csv')]
    start = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=180, cwd=root)
    (out / f'{stem}.guard').write_text(result.stdout + result.stderr)
    meta['processes'].append({'index': index, 'vendor': vendor, 'prime_ms': prime,
                              'rotation': rotation, 'csv': f'{stem}.csv', 'command': cmd,
                              'started_utc': start, 'returncode': result.returncode})
    (out / 'metadata.json').write_text(json.dumps(meta, indent=2) + '\n')
    if result.returncode:
        raise SystemExit(f'guard/command failed for {stem}; see guard log, no automatic retry')
    rows = list(csv.DictReader((out / f'{stem}.csv').open()))
    assert len(rows) == 12 and all(r['status'] == 'ok' and len(json.loads(r['samples_ms'])) == 30 for r in rows)
    print(stem, 'ok', flush=True)
