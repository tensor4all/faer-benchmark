"""One-off, fixed-binary diagnostic. Run from faer-benchmark; see README.md."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import yaml

root = Path.cwd()
out = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('idle_cpus', root / 'benchmarks/scripts/idle_cpus.py')
idle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(idle)
refs = {'A': '20261018T070736Z-upstream-lu-baseline',
        'B': '20261018T081053Z-upstream-lu-restored-budget-repeat'}
records = {key: yaml.safe_load((root / 'data/results/zen5-cpu/faer-kernels' / name / 'run.yaml').read_text())
           for key, name in refs.items()}
pins = {t: records['A']['threads']['cpu_sets'][str(t)] for t in (1, 4)}
watched = idle.with_cache_peers(Path('/'), sum((idle.parse_cpu_list(v) for v in pins.values()), []))
assert not set(os.sched_getaffinity(0)).intersection(watched), 'observer overlaps measured L3'
assert Path('/sys/devices/system/cpu/cpufreq/boost').read_text().strip() == '0'
env = dict(os.environ, PINNED_RETRIES='8')
for key in records['A']['threads']['env']:
    env.pop(key, None)
identity = {'observer_cpus': sorted(os.sched_getaffinity(0)), 'watched_l3_cpus': watched,
            'pins': pins, 'sequence': list('ABBABAAB'), 'binaries': {}}
for label, record in records.items():
    binary = Path(record['binary']['path'])
    digest = hashlib.sha256(binary.read_bytes()).hexdigest()
    assert digest == record['binary']['sha256'], f'{label}: binary changed'
    identity['binaries'][label] = {'path': str(binary), 'sha256': digest, 'reference_run': refs[label],
                                  'fork': record['library']['commit'], 'upstream': record['upstream']['commit'],
                                  'harness': record['harness']['commit']}
    for t, cpus in pins.items():
        info = subprocess.run(['taskset', '-c', cpus, str(binary), 'info', '--threads', str(t)],
                              env=env, check=True, capture_output=True, text=True).stdout
        assert f'threads.rayon_observed={t}' in info
        if t == 1:
            assert 'threads.faer=sequential' in info
        (out / f'{label}-info-{t}t.txt').write_text(info)
(out / 'identities.json').write_text(json.dumps(identity, indent=2) + '\n')

def execute(label, t, name, verify=False):
    binary = records[label]['binary']['path']
    prefix = out / name
    cmd = ['benchmarks/scripts/pinned.sh', pins[t], '--', binary, 'verify' if verify else 'run',
           '--threads', str(t), '--n', '32,64,96,128', '--batch', '1', '--dtype', 'f64,c64',
           '--family', 'cholesky', '--rows', 'faer-upstream', '--regime', 'upstream-abba',
           '--csv', str(prefix.with_suffix('.csv'))]
    if not verify:
        cmd += ['--reps', '5', '--prime-ms', '250', '--statistic', 'median']
    power = {str(cpu): {key: (Path(f'/sys/devices/system/cpu/cpu{cpu}/cpufreq') / key).read_text().strip()
                       for key in ('scaling_cur_freq', 'scaling_max_freq', 'scaling_governor')}
             for cpu in idle.parse_cpu_list(pins[t])}
    prefix.with_suffix('.command.json').write_text(json.dumps({'argv': cmd, 'power_before': power}, indent=2)+'\n')
    print(name, flush=True)
    with prefix.with_suffix('.log').open('w') as log:
        subprocess.run(cmd, env=env, check=True, stdout=log, stderr=subprocess.STDOUT)

for t in pins:
    for label in records:
        execute(label, t, f'verify-{label}-{t}t', verify=True)
    for start, label in enumerate(identity['sequence']):
        execute(label, t, f'process{start}-{label}-{t}t')
