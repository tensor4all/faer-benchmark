#!/usr/bin/env python3
"""One representative cell: does pinning the observing side off the measured L3 domain
change the timing distribution? Diagnostic only; publishes nothing."""
import argparse, csv, json, os, statistics, subprocess, sys
from pathlib import Path

ROOT = Path('/home/shinaoka/projects/tensor4all/faer-benchmark')
MEASURED = '4-7'          # this cell's declared 4T set; must sit in one L3 domain
VENDOR_ENV = ['OPENBLAS_NUM_THREADS', 'MKL_NUM_THREADS', 'MKL_DOMAIN_NUM_THREADS', 'MKL_INTERFACE_LAYER',
              'MKL_THREADING_LAYER', 'MKL_DYNAMIC', 'MKL_ENABLE_INSTRUCTIONS', 'MKL_CBWR', 'OMP_NUM_THREADS',
              'OMP_THREAD_LIMIT', 'OMP_PROC_BIND', 'OMP_PLACES', 'KMP_AFFINITY', 'GOMP_CPU_AFFINITY',
              'RAYON_NUM_THREADS']


def cpus(text):
    out = set()
    for part in str(text).split(','):
        if '-' in part:
            lo, hi = part.split('-'); out.update(range(int(lo), int(hi) + 1))
        elif part:
            out.add(int(part))
    return out


def l3_domain(of):
    domain = set()
    for cpu in of:
        domain |= cpus(Path(f'/sys/devices/system/cpu/cpu{cpu}/cache/index3/shared_cpu_list').read_text())
    return domain


def online():
    return cpus(Path('/sys/devices/system/cpu/online').read_text())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--binary', required=True)
    ap.add_argument('--condition', required=True, choices=['pinned', 'unpinned'])
    ap.add_argument('--rotate', required=True)
    ap.add_argument('--out', required=True)
    a = ap.parse_args()
    domain = l3_domain(cpus(MEASURED))
    observer = sorted(online() - domain)
    env = {k: v for k, v in os.environ.items() if k not in VENDOR_ENV}
    csv_path = Path(a.out).with_suffix('.csv')
    guard_log = Path(a.out).with_suffix('.guard')
    argv = [str(ROOT / 'benchmarks/scripts/pinned.sh'), MEASURED, '--', a.binary, 'run',
            '--threads', '4', '--n', '256', '--family', 'lu', '--dtype', 'c64', '--batch', '1',
            '--regime', 'pinprobe', '--statistic', 'median', '--prime-ms', '3000', '--reps', '30',
            '--rotate-rows', a.rotate, '--csv', str(csv_path)]
    started = subprocess.run(['taskset', '-pc', str(os.getpid())], capture_output=True, text=True).stdout
    proc = subprocess.run(argv, env=env, capture_output=True, text=True)
    guard_log.write_text(proc.stderr)
    rows = {}
    if csv_path.exists():
        for row in csv.DictReader(csv_path.open(newline='')):
            if row['status'] != 'ok':
                continue
            samples = json.loads(row['samples_ms'])
            rows[f"{row['order']}/{row['row']}"] = {
                'median': statistics.median(samples), 'sd': statistics.stdev(samples),
                'relative_sd': statistics.stdev(samples) / statistics.median(samples),
                'min': min(samples), 'max': max(samples), 'n': len(samples)}
    Path(a.out).write_text(json.dumps({
        'condition': a.condition, 'rotate': a.rotate, 'guard_rc': proc.returncode,
        'observer_cpus_derived': observer, 'measured': MEASURED, 'l3_domain': sorted(domain),
        'affinity_at_start': started.strip(), 'rows': rows}, indent=2) + '\n')
    return proc.returncode


if __name__ == '__main__':
    sys.exit(main())
