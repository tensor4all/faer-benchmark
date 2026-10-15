#!/usr/bin/env python3
"""Is 150 ms priming equivalent to 250 ms? Three process starts per setting per cell.

Cells cover the tiers that stayed in scope: gemm mid (cheap call), linalg mid c64 LU,
linalg mid f64 Cholesky at 8T, and the expensive tall QR factor. Diagnostic only.
"""
import csv, json, os, statistics, subprocess, sys
from pathlib import Path

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
BIN = ROOT / 'target/faer-rev/bfe4041cd991-mkl/release/fbench'
HERE = Path(__file__).resolve().parent
CELLS = [
    ('gemm-256-1t', 1, '4', 'f64', 'gemm', '256x256x256'),
    ('lu-256-4t-c64', 4, '4-7', 'c64', 'lu', '256'),
    ('cholesky-512-8t-f64', 8, '4-11', 'f64', 'cholesky', '512'),
    ('qrfactor-4096x256-8t', 8, '4-11', 'f64', 'qr_factor', '4096x256'),
]
SETTINGS = [(250, 5), (150, 5)]
VENDOR_ENV = ['OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'MKL_DOMAIN_NUM_THREADS', 'MKL_INTERFACE_LAYER',
              'MKL_THREADING_LAYER', 'MKL_DYNAMIC', 'MKL_ENABLE_INSTRUCTIONS', 'MKL_CBWR', 'OMP_NUM_THREADS',
              'OMP_THREAD_LIMIT', 'OMP_PROC_BIND', 'OMP_PLACES', 'KMP_AFFINITY', 'GOMP_CPU_AFFINITY',
              'RAYON_NUM_THREADS']

env = {k: v for k, v in os.environ.items() if k not in VENDOR_ENV}
for name, threads, cpus, dtype, family, shapes in CELLS:
    for prime, reps in SETTINGS:
        for rotation in (0, 1, 2):
            stem = f'{name}-p{prime}-rot{rotation}'
            path = HERE / f'{stem}.json'
            if path.exists():
                raise SystemExit(f'{path} exists; never overwrite a first attempt')
            csv_path = HERE / f'{stem}.csv'
            argv = [str(ROOT / 'benchmarks/scripts/pinned.sh'), cpus, '--', str(BIN), 'run',
                    '--threads', str(threads), '--n', shapes, '--family', family, '--dtype', dtype,
                    '--batch', '1', '--regime', name, '--statistic', 'median', '--prime-ms', str(prime),
                    '--reps', str(reps), '--rotate-rows', str(rotation), '--csv', str(csv_path)]
            proc = subprocess.run(argv, env=env, check=False, capture_output=True, text=True, timeout=300)
            (HERE / f'{stem}.guard').write_text(proc.stderr)
            rows = {}
            if csv_path.exists():
                for row in csv.DictReader(csv_path.open(newline='')):
                    if row['status'] != 'ok':
                        continue
                    samples = json.loads(row['samples_ms'])
                    rows[f"{row['order']}/{row['row']}"] = {
                        'median': statistics.median(samples), 'first': samples[0], 'max': max(samples),
                        'relative_sd': statistics.stdev(samples) / statistics.median(samples), 'n': len(samples)}
            (HERE / f'{stem}.json').write_text(json.dumps(
                {'cell': name, 'prime_ms': prime, 'reps': reps, 'rotation': rotation,
                 'guard_rc': proc.returncode, 'rows': rows}, indent=2) + '\n')
            print(f'{stem}: rc={proc.returncode} rows={len(rows)}', flush=True)
