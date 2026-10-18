"""Run the predeclared copy-only probe, from faer-benchmark, after building."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import yaml

root = Path.cwd()
source = Path(__file__).resolve().parent
out = source / sys.argv[1] if len(sys.argv) > 1 else source
out.mkdir(exist_ok=True)
assert not (out/'identities.json').exists(), 'use a fresh output directory'
binary = root / 'target/probe-owned-copy/release/owned-copy-probe'
spec = importlib.util.spec_from_file_location('idle_cpus', root/'benchmarks/scripts/idle_cpus.py')
idle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(idle)
reference = root/'data/results/zen5-cpu/faer-kernels/20261018T070736Z-upstream-lu-baseline/run.yaml'
cpus = yaml.safe_load(reference.read_text())['threads']['cpu_sets']['1']
watched = idle.with_cache_peers(Path('/'), idle.parse_cpu_list(cpus))
assert not set(os.sched_getaffinity(0)).intersection(watched)
metadata = json.loads((source/'cargo-metadata.json').read_text())
package = next(p for p in metadata['packages'] if p['name']=='t4a-faer')
assert Path(package['manifest_path']).resolve() == (root/'extern/t4a-faer/faer/Cargo.toml').resolve()
identity = dict(binary=str(binary),sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),
                faer=package['manifest_path'],version=package['version'],
                library_commit=subprocess.check_output(['git','-C','extern/t4a-faer','rev-parse','HEAD'],text=True).strip(),
                harness_commit=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
                measured_cpus=cpus,watched_l3_cpus=watched,observer_cpus=sorted(os.sched_getaffinity(0)),
                source_sha256={p:hashlib.sha256((source/p).read_bytes()).hexdigest()
                               for p in ('Cargo.toml','Cargo.lock','src/main.rs','run.py')})
(out/'identities.json').write_text(json.dumps(identity,indent=2)+'\n')
env = dict(os.environ,PINNED_RETRIES='1',RAYON_NUM_THREADS='1',OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',MKL_NUM_THREADS='1')
for start in range(4):
    csv = out/f'process{start}.csv'
    assert not csv.exists(), 'do not overwrite previous attempts'
    # Write outside pinned.sh's temporary stdout: preserve even a rejected run.
    cmd = ['benchmarks/scripts/pinned.sh',cpus,'--','bash','-c',
           'exec "$1" "$2" > "$3"','copy-probe',str(binary),str(start),str(csv)]
    (out/f'process{start}.command.json').write_text(json.dumps(cmd,indent=2)+'\n')
    with (out/f'process{start}.log').open('w') as log:
        for admission in range(8):
            result = subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
            if result.returncode == 0:
                break
            if result.returncode != 75 or csv.exists() or admission == 7:
                raise RuntimeError(f'{start}: failed/rejected; output retained, no timed retry')
            time.sleep(30)  # No measurement launched; admission-only retry.
    print('completed',start,flush=True)
