#!/usr/bin/env python3
"""Priming calibration with boost disabled: is a short per-row priming defensible?

Three process starts (rotations 0/1/2) per setting per cell, so a priming/call-count
effect can be separated from the between-process variation that one start cannot
resolve. Diagnostic only; publishes nothing.
"""
import csv
import json
import os
import statistics
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
BIN = ROOT / 'target/faer-rev/bfe4041cd991-mkl/release/fbench'
HERE = Path(__file__).resolve().parent
CELLS = [
    ('gemm-1t-f64', 1, '4', 'f64', 'gemm', '256x256x256'),
    ('lu-4t-c64', 4, '4-7', 'c64', 'lu', '256'),
    ('cholesky-8t-f64', 8, '4-11', 'f64', 'cholesky', '512'),
]
SETTINGS = [(3000, 30), (250, 30), (250, 10)]
VENDOR_ENV = ['OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'MKL_DOMAIN_NUM_THREADS', 'MKL_INTERFACE_LAYER',
              'MKL_THREADING_LAYER', 'MKL_DYNAMIC', 'MKL_ENABLE_INSTRUCTIONS', 'MKL_CBWR', 'OMP_NUM_THREADS',
              'OMP_THREAD_LIMIT', 'OMP_PROC_BIND', 'OMP_PLACES', 'KMP_AFFINITY', 'GOMP_CPU_AFFINITY',
              'RAYON_NUM_THREADS']


def main():
    env = {k: v for k, v in os.environ.items() if k not in VENDOR_ENV}
    records = {}
    for name, threads, cpus, dtype, family, shapes in CELLS:
        for prime, reps in SETTINGS:
            for rotation in (0, 1, 2):
                stem = f'{name}-p{prime}-r{reps}-rot{rotation}'
                path = HERE / f'{stem}.json'
                if path.exists():
                    raise SystemExit(f'{path} already exists; never overwrite a first attempt')
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
                            'median': statistics.median(samples), 'first': samples[0],
                            'last': samples[-1], 'max': max(samples),
                            'relative_sd': statistics.stdev(samples) / statistics.median(samples),
                            'n': len(samples)}
                record = {'cell': name, 'threads': threads, 'prime_ms': prime, 'reps': reps,
                          'rotation': rotation, 'guard_rc': proc.returncode, 'rows': rows,
                          'guard': proc.stderr.strip().splitlines()[-1] if proc.stderr.strip() else ''}
                records[stem] = record
                path.write_text(json.dumps(record, indent=2) + '\n')
                print(f'{stem}: rc={proc.returncode} rows={len(rows)}', flush=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
