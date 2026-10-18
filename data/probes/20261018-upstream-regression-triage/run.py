"""One-off diagnostic; run from the campaign root. See README.md."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import yaml

root = Path.cwd()
out = Path(__file__).resolve().parent
old = yaml.safe_load((root / 'data/results/zen5-cpu/faer-kernels/20261018T022054Z-final-full-mkl/run.yaml').read_text())
# Reuse the recorded host's per-budget pin; sysfs and pinned.sh validate the domain.
print(json.dumps(old['threads'], indent=2))
revs = ['0627828d965b', '2240b076a030']
env = dict(os.environ, PINNED_RETRIES='8')
for key in old['threads']['env']:
    env.pop(key, None)
# Reuse the declared host profile; do not bake a machine-specific CPU list into code.
pins = {int(k): v for k, v in old['threads']['cpu_sets'].items()}
identity = {}
for rev in revs:
    binary = root / f'target/faer-rev/{rev}-mkl/release/fbench'
    identity[rev] = {'binary': str(binary), 'sha256': hashlib.sha256(binary.read_bytes()).hexdigest()}
    for t in pins:
        info = subprocess.run(['taskset', '-c', pins[t], str(binary), 'info', '--threads', str(t)],
                              env=env, check=True, text=True, capture_output=True)
        (out / f'{rev}-info-{t}t.json').write_text(info.stdout)
(out / 'binary-identities.json').write_text(json.dumps(identity, indent=2) + '\n')
for case, families, shapes, dtype, budgets in [
    ('lu256', 'lu,solve', '256', 'c64', [1, 4, 8]),
    ('hh64', 'householder_apply', '64', 'f64', [1, 4, 8]),
    ('hh-tall', 'householder_apply', '1024x64,4096x256', 'f64', [8]),
]:
    for t in budgets:
        args = ['--threads', str(t), '--n', shapes, '--batch', '1', '--dtype', dtype,
                '--family', families, '--rows', 'faer-fork,faer-upstream,lapack-mkl', '--regime', case]
        for rev in revs:
            binary = root / f'target/faer-rev/{rev}-mkl/release/fbench'
            for start in [-1, 0, 1, 2]:
                prefix = out / f'{rev}-{case}-{t}t-{start}'
                cmd = ['benchmarks/scripts/pinned.sh', pins[t], '--', str(binary)]
                if start == -1:
                    cmd += ['verify', *args, '--csv', str(prefix.with_suffix('.csv'))]
                else:
                    cmd += ['run', *args, '--reps', '5', '--prime-ms', '250', '--statistic', 'median',
                            '--rotate-rows', str(start), '--csv', str(prefix.with_suffix('.csv'))]
                print(' '.join(cmd), flush=True)
                with prefix.with_suffix('.log').open('w') as log:
                    subprocess.run(cmd, env=env, check=True, stdout=log, stderr=subprocess.STDOUT)
