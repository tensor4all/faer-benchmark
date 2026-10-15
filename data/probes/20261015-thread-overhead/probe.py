#!/usr/bin/env python3
"""Small-shape overhead probe: is the per-call cost dominated by fixed launch/region overhead?

Measures gemm at 4^3, 32^3 and 256^3 with 1, 4 and 8 threads, two rotations, 500 ms priming,
30 calls. If the 4T/8T minus 1T difference is roughly constant across shapes, tiny cells are
measuring thread/region start-up rather than the kernel. Diagnostic; publishes nothing.
"""
import csv, json, os, statistics, subprocess, sys
from pathlib import Path

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
BIN = ROOT / 'target/faer-rev/bfe4041cd991-mkl/release/fbench'
HERE = Path(__file__).resolve().parent
BUDGETS = [(1, '4'), (4, '4-7'), (8, '4-11')]
SHAPES = '4x4x4,32x32x32,256x256x256'
VENDOR_ENV = ['OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'MKL_DOMAIN_NUM_THREADS', 'MKL_INTERFACE_LAYER',
              'MKL_THREADING_LAYER', 'MKL_DYNAMIC', 'MKL_ENABLE_INSTRUCTIONS', 'MKL_CBWR', 'OMP_NUM_THREADS',
              'OMP_THREAD_LIMIT', 'OMP_PROC_BIND', 'OMP_PLACES', 'KMP_AFFINITY', 'GOMP_CPU_AFFINITY',
              'RAYON_NUM_THREADS']

env = {k: v for k, v in os.environ.items() if k not in VENDOR_ENV}
for threads, cpus in BUDGETS:
    for rotation in (0, 2):
        stem = f'gemm-{threads}t-rot{rotation}'
        path = HERE / f'{stem}.json'
        if path.exists():
            raise SystemExit(f'{path} exists; never overwrite a first attempt')
        csv_path = HERE / f'{stem}.csv'
        argv = [str(ROOT / 'benchmarks/scripts/pinned.sh'), cpus, '--', str(BIN), 'run',
                '--threads', str(threads), '--n', SHAPES, '--family', 'gemm', '--dtype', 'f64', '--batch', '1',
                '--regime', 'thread-overhead', '--statistic', 'median', '--prime-ms', '500', '--reps', '30',
                '--rotate-rows', str(rotation), '--csv', str(csv_path)]
        proc = subprocess.run(argv, env=env, check=False, capture_output=True, text=True, timeout=300)
        (HERE / f'{stem}.guard').write_text(proc.stderr)
        rows = {}
        if csv_path.exists():
            for row in csv.DictReader(csv_path.open(newline='')):
                if row['status'] != 'ok':
                    continue
                samples = json.loads(row['samples_ms'])
                rows[f"{row['order']}/{row['n']}/{row['row']}"] = {
                    'median_ms': statistics.median(samples), 'median_us': statistics.median(samples) * 1000,
                    'relative_sd': statistics.stdev(samples) / statistics.median(samples), 'n': len(samples)}
        (HERE / f'{stem}.json').write_text(json.dumps(
            {'threads': threads, 'cpus': cpus, 'rotation': rotation, 'guard_rc': proc.returncode,
             'rows': rows}, indent=2) + '\n')
        print(f'{stem}: rc={proc.returncode} rows={len(rows)}', flush=True)
