#!/usr/bin/env python3
"""Does a short per-row priming change the measured median? Diagnostic, publishes nothing.

Best-practice reference for a native/AOT benchmark is a warm-up calibrated to steady state,
not a fixed 3 s per measured row (Criterion.rs defaults to a 3 s warm-up per benchmark
configuration; google/benchmark defaults to none with ~0.5 s as a suggested floor).
"""
import csv
import json
import os
import statistics
import subprocess
import sys
from pathlib import Path

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
BIN = ROOT / 'target/faer-rev/bfe4041cd991-mkl/release/fbench'
CELLS = [  # (name, threads, cpus, dtype, family, shapes)
    ('gemm-1t-f64', 1, '4', 'f64', 'gemm', '256x256x256'),
    ('lu-4t-c64', 4, '4-7', 'c64', 'lu', '256'),
    ('cholesky-8t-f64', 8, '4-11', 'f64', 'cholesky', '512'),
    ('qrfactor-8t-f64', 8, '4-11', 'f64', 'qr_factor', '4096x256'),
]
SETTINGS = [(3000, 30), (250, 30), (250, 10)]
VENDOR_ENV = ['OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'MKL_DOMAIN_NUM_THREADS', 'MKL_INTERFACE_LAYER',
              'MKL_THREADING_LAYER', 'MKL_DYNAMIC', 'MKL_ENABLE_INSTRUCTIONS', 'MKL_CBWR', 'OMP_NUM_THREADS',
              'OMP_THREAD_LIMIT', 'OMP_PROC_BIND', 'OMP_PLACES', 'KMP_AFFINITY', 'GOMP_CPU_AFFINITY',
              'RAYON_NUM_THREADS']
HERE = Path(__file__).resolve().parent


def main():
    env = {k: v for k, v in os.environ.items() if k not in VENDOR_ENV}
    out = {}
    for name, threads, cpus, dtype, family, shapes in CELLS:
        for prime, reps in SETTINGS:
            for rotation in (0, 2):
                stem = f'{name}-p{prime}-r{reps}-rot{rotation}'
                csv_path = HERE / f'{stem}.csv'
                argv = [str(ROOT / 'benchmarks/scripts/pinned.sh'), cpus, '--', str(BIN), 'run',
                        '--threads', str(threads), '--n', shapes, '--family', family, '--dtype', dtype,
                        '--batch', '1', '--regime', name, '--statistic', 'median', '--prime-ms', str(prime),
                        '--reps', str(reps), '--rotate-rows', str(rotation), '--csv', str(csv_path)]
                started = subprocess.run(['date', '-u', '+%FT%TZ'], check=False,
                                         capture_output=True, text=True).stdout.strip()
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
                            'max': max(samples), 'relative_sd': statistics.stdev(samples) / statistics.median(samples),
                            'n': len(samples)}
                out[stem] = {'cell': name, 'prime_ms': prime, 'reps': reps, 'rotation': rotation,
                             'guard_rc': proc.returncode, 'started': started, 'rows': rows,
                             'guard': proc.stderr.strip().splitlines()[-1] if proc.stderr.strip() else ''}
                (HERE / f'{stem}.json').write_text(json.dumps(out[stem], indent=2) + '\n')
                print(f'{stem}: rc={proc.returncode} rows={len(rows)}', flush=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
