"""Frozen-binary, diagnostic-only stages. Run from faer-benchmark; see README."""
from collections import Counter, defaultdict
import csv
import fcntl
import hashlib
import importlib.util
import itertools
import json
import os
from pathlib import Path
import shlex
import statistics
import subprocess
import sys

import yaml

from campaign_toolkit.record_run import boost_state

root = Path.cwd()
source = Path(__file__).resolve().parent
stage = sys.argv[1]
grids = {
    'householder': [('hh', ['householder_apply'], [(64,64),(1024,64),(4096,256)])],
    'downstream': [('qr', ['qr_factor','qr'], [(512,512),(1024,64)]),
                   ('spectral', ['svd_values','svd_thin','eigh'], [(512,512)])],
}[stage]
out = source/stage
out.mkdir(exist_ok=True)
assert not (out/'identities.json').exists(), 'retain previous attempts; use a new experiment, not an overwrite'
assert Path('/tmp/householder-partial-merge-build.exit').read_text().strip() == '0'
lock = (root/'target/campaign.lock').open('w')
fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
reference = root/'data/results/zen5-cpu/faer-kernels/20261018T070736Z-upstream-lu-baseline/run.yaml'
base = yaml.safe_load(reference.read_text())
vars_text = Path('/tmp/householder-partial-merge-build.vars').read_text()
build = {}
for line in vars_text.splitlines():
    (assignment,) = shlex.split(line)
    key,value = assignment.split('=',1)
    build[key] = value
assert build['FAER_FORK_REV'] == 'ad9f2ef45e3508dddc15c275f5482e597f1da7c4'
assert build['FAER_UPSTREAM_REV'] == base['upstream']['commit']
assert build['FAER_FORK_DIRTY'] == build['FAER_UPSTREAM_DIRTY'] == 'false'
assert build['FAER_FORK_FEATURES'].split(',') == base['library']['features']
assert build['BUILD_VENDOR'] == base['vendor']['name'] and build['BUILD_ENV'] == base['vendor']['build_env']
for path in ('fbench','Cargo.toml','Cargo.lock'):
    old = subprocess.check_output(['git','rev-parse',f'{base["harness"]["commit"]}:{path}'],text=True)
    assert old == subprocess.check_output(['git','rev-parse',f'HEAD:{path}'],text=True), path
binaries = {'A':Path(base['binary']['path']), 'B':Path(build['BIN_DIR'])/'fbench'}
hashes = {label:hashlib.sha256(path.read_bytes()).hexdigest() for label,path in binaries.items()}
assert hashes['A'] == base['binary']['sha256']
(out/'build.vars').write_text(vars_text)
(out/'build.log').write_text(Path('/tmp/householder-partial-merge-build.log').read_text())
spec = importlib.util.spec_from_file_location('idle_cpus',root/'benchmarks/scripts/idle_cpus.py')
idle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(idle)
pins = {t:base['threads']['cpu_sets'][str(t)] for t in (1,4,8)}
watched = set()
for cpus in pins.values():
    sets = [set(idle.with_cache_peers(Path('/'),[cpu])) for cpu in idle.parse_cpu_list(cpus)]
    assert all(s == sets[0] for s in sets), 'one L3 domain per measured cell'
    watched.update(sets[0])
assert not watched.intersection(os.sched_getaffinity(0)), 'observer overlaps measured cache'
env = dict(os.environ,PINNED_RETRIES='8',PINNED_IDLE_SECONDS='3',PINNED_MAX_BUSY='0.05')
for key in base['threads']['env']:
    env.pop(key,None)

def power():
    actual = boost_state()
    assert actual == {k:v for k,v in base['host']['power'].items() if k in ('cpufreq_boost','intel_pstate_no_turbo')}
    actual['amd_pstate_status'] = Path('/sys/devices/system/cpu/amd_pstate/status').read_text().strip()
    assert actual['amd_pstate_status'] == base['host']['power']['amd_pstate_status']
    actual['cpus'] = {}
    for cpu in sorted(watched):
        p = Path(f'/sys/devices/system/cpu/cpu{cpu}/cpufreq')
        values = {key:(p/key).read_text().strip() for key in
                  ('scaling_cur_freq','scaling_max_freq','scaling_governor','energy_performance_preference')}
        for key,ref in (('scaling_max_freq','scaling_max_freq_khz'),('scaling_governor','governor'),
                        ('energy_performance_preference','energy_performance_preference')):
            assert values[key] == base['host']['power'][ref], (cpu,key,values)
        actual['cpus'][str(cpu)] = values
    return actual

repos = [root,root.parent/'faer',root.parent/'campaign-toolkit',Path(build['FAER_FORK_DIR']),Path(build['FAER_UPSTREAM_DIR'])]
def sources():
    state = {}
    for path in repos:
        head = subprocess.check_output(['git','-C',str(path),'rev-parse','HEAD'],text=True).strip()
        dirty = subprocess.check_output(['git','-C',str(path),'status','--porcelain','--untracked-files=no'],text=True)
        assert not dirty, (path,dirty)
        state[str(path)] = head
    return state

heads = sources()
identity = dict(diagnostic_only=True,adopted=False,stage=stage,source_heads=heads,
                observer_cpus=sorted(os.sched_getaffinity(0)),watched_l3_cpus=sorted(watched),pins=pins,
                sequence='ABBAAB',binary_sha256=hashes,binaries={k:str(v) for k,v in binaries.items()},
                baseline_library=base['library']['commit'],candidate_library=build['FAER_FORK_REV'],
                upstream=build['FAER_UPSTREAM_REV'],power=power(),
                source_sha256={p:hashlib.sha256((source/p).read_bytes()).hexdigest() for p in ('README.md','run.py')})
(out/'identities.json').write_text(json.dumps(identity,indent=2)+'\n')
for label,binary in binaries.items():
    for t,cpus in pins.items():
        info = subprocess.run(['taskset','-c',cpus,str(binary),'info','--threads',str(t)],
                              env=env,check=True,capture_output=True,text=True).stdout
        (out/f'{label}-info-{t}t.txt').write_text(info)
        assert f'vendor.name={base["vendor"]["name"]}\n' in info
        assert f'vendor.version={base["vendor"]["version"]}\n' in info
        assert f'threads.rayon_observed={t}\n' in info
        assert f'threads.vendor_reported={t}\n' in info
        if t == 1:
            assert 'threads.faer=sequential\n' in info

inventory = {}
timed = defaultdict(lambda:defaultdict(list))
identity_fields = 'regime family dtype order m n k batch row threads note status'.split()
def audit(path, families, shapes, t, verify):
    rows = list(csv.DictReader(path.open()))
    expected = Counter()
    for engine,family,dtype,order,(m,n) in itertools.product(
            ('faer-fork','faer-upstream','lapack-mkl'),families,('f64','c64'),('c','f'),shapes):
        expected[(engine,family,dtype,order,str(m),str(n))] = 2 if family == 'householder_apply' and engine != 'lapack-mkl' else 1
    observed = Counter(tuple(row[k] for k in ('row','family','dtype','order','m','n')) for row in rows)
    assert observed == expected, (path,'incomplete or extra grid')
    keys = [tuple(row[k] for k in identity_fields) for row in rows]
    assert len(keys) == len(set(keys)), (path,'duplicate full identity')
    for row in rows:
        assert row['k'] == '' and row['batch'] == '1' and int(row['threads']) == t
        skipped = row['family'] == 'householder_apply' and row['row'] == 'lapack-mkl'
        assert row['status'] == ('skipped' if skipped else 'ok'), row
        if skipped:
            continue
        assert int(row['rayon_threads']) == int(row['vendor_threads']) == t, row
        if row['family'] == 'householder_apply':
            n = min(int(row['m']),int(row['n']))
            assert row['note'] in (f'block(basis={n},target={row["n"]})',f'sequence(basis={n},target={row["n"]})')
        if not verify:
            samples = json.loads(row['samples_ms'])
            assert len(samples) == 5 and all(v > 0 for v in samples), row
            assert abs(statistics.median(samples)-float(row['total_ms'])) <= 5.1e-7, row
    return rows,set(keys)

def execute(label,t,grid,name,verify=False,rotation=0):
    group,families,shapes = grid
    dest = out/f'{name}-{group}-{t}t'
    path = dest.with_suffix('.csv')
    cmd = ['benchmarks/scripts/pinned.sh',pins[t],'--',str(binaries[label]),'verify' if verify else 'run',
           '--threads',str(t),'--n',','.join(f'{m}x{n}' for m,n in shapes),'--batch','1',
           '--dtype','f64,c64','--family',','.join(families),'--rows','faer-fork,faer-upstream,lapack-mkl',
           '--regime','partial-merge-diag','--csv',str(path)]
    if not verify:
        cmd += ['--reps','5','--prime-ms','250','--statistic','median','--rotate-rows',str(rotation)]
    dest.with_suffix('.command.json').write_text(json.dumps(dict(argv=cmd,power_before=power()),indent=2)+'\n')
    print(name,group,t,flush=True)
    with dest.with_suffix('.log').open('w') as log:
        subprocess.run(cmd,env={**env,'PINNED_CSV':str(path)},check=True,stdout=log,stderr=subprocess.STDOUT)
    dest.with_suffix('.power-after.json').write_text(json.dumps(power(),indent=2)+'\n')
    assert sources() == heads, 'source changed during recording'
    assert all(hashlib.sha256(p.read_bytes()).hexdigest() == hashes[k] for k,p in binaries.items())
    rows,keys = audit(path,families,shapes,t,verify)
    if (group,t) not in inventory:
        inventory[group,t] = keys
    assert inventory[group,t] == keys, 'full cell/variant/status identities changed'
    if not verify:
        for row in rows:
            if row['status'] == 'ok':
                key = tuple(row[k] for k in identity_fields)
                timed[key][label].append(statistics.median(json.loads(row['samples_ms'])))

for grid in grids:
    for t in pins:
        for label in binaries:
            execute(label,t,grid,f'verify-{label}',True)
for grid in grids:
    for t in pins:
        counters = {'A':0,'B':0}
        for label in 'ABBAAB':
            rep = counters[label]
            execute(label,t,grid,f'process{rep}-{label}',rotation=rep)
            counters[label] += 1
comparison = []
for key,values in sorted(timed.items()):
    assert set(values) == {'A','B'} and all(len(v) == 3 for v in values.values())
    comparison.append(dict(cell=dict(zip(identity_fields,key)),start_medians_ms=values,
                           ratio_of_medians=statistics.median(values['B'])/statistics.median(values['A'])))
(out/'comparison.json').write_text(json.dumps(dict(diagnostic_only=True,adopted=False,cells=comparison),indent=2)+'\n')
print('complete diagnostic stage',stage,'cells',len(comparison),'NOT adoption',flush=True)
