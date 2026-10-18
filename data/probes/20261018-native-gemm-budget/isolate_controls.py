"""Diagnostic only. Adapt existing upstream-binary-abba/run.py; no adoption gate.

--check: offline grid/argv check, never measure. Otherwise pass the current pi PID.
PRE/POST reports and scope: docs/reviews/20261018-native-control-isolation-*.
Existing attributed pinned.sh is reused unchanged; no new foreign code imported.
"""
import collections
import csv
import datetime
import fcntl
import hashlib
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

if not __debug__:
    raise SystemExit('Refusing optimized Python: safety assertions must remain enabled')

import yaml
from campaign_toolkit import record_run as rr

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
OUT = HERE / 'runtime-isolation'
FIELDS = ('regime', 'family', 'dtype', 'order', 'm', 'n', 'k', 'batch',
          'row', 'threads', 'note', 'status')
SHAPES = {'cholesky': '32,128,256', 'gemm': '32x32x32,96x96x96,128x128x128',
          'triangular_solve': '128,256'}
SEQUENCE = 'ABBABAAB'


def expected(family=None, threads=None):
    sizes = {'cholesky': {'32', '128', '256'}, 'gemm': {'32', '96', '128'},
             'triangular_solve': {'128', '256'}}
    with (HERE / 'stage1-grid.csv').open() as stream:
        rows = [dict(r, regime='native-control-isolation') for r in csv.DictReader(stream)
                if r['row'] == 'faer-upstream' and r['family'] in sizes
                and r['m'] in sizes[r['family']]
                and (family is None or r['family'] == family)
                and (threads is None or r['threads'] == str(threads))]
    return collections.Counter(tuple(r[k] for k in FIELDS) for r in rows)


def argv(binary, cpus, family, threads, path, verify):
    cmd = ['timeout', '--signal=TERM', '--kill-after=15s', '120s',
           str(ROOT / 'benchmarks/scripts/pinned.sh'), cpus, '--', binary,
           'verify' if verify else 'run', '--threads', str(threads),
           '--n', SHAPES[family], '--batch', '1', '--dtype', 'f64,c64',
           '--family', family, '--rows', 'faer-upstream',
           '--regime', 'native-control-isolation', '--csv', str(path)]
    return cmd if verify else cmd + ['--reps', '5', '--prime-ms', '250', '--statistic', 'median']


def audit(path, family, threads, verify):
    with path.open() as stream:
        rows = list(csv.DictReader(stream))
    assert collections.Counter(tuple(r[k] for k in FIELDS) for r in rows) == expected(family, threads)
    for row in rows:
        assert row['rayon_threads'] == row['vendor_threads'] == str(threads)
        if not verify and row['status'] == 'ok':
            samples = json.loads(row['samples_ms'])
            assert len(samples) == 5 and all(math.isfinite(v) and v > 0 for v in samples)
            assert math.isfinite(float(row['total_ms'])) and float(row['total_ms']) > 0


def check():
    grid = expected()
    assert sum(grid.values()) == len(grid) == 96
    assert {f: sum(expected(f).values()) for f in SHAPES} == {
        'cholesky': 36, 'gemm': 36, 'triangular_solve': 24}
    for t in (1, 4, 8):
        assert sum(expected(threads=t).values()) == 32
    for family in SHAPES:
        for t in (1, 4, 8):
            for verify in (False, True):
                cmd = argv('binary', 'cpus', family, t, Path('test.csv'), verify)
                assert cmd[cmd.index('--rows') + 1] == 'faer-upstream'
                assert cmd[cmd.index('--threads') + 1] == str(t)
                assert ('--prime-ms' in cmd) != verify
    assert len(SEQUENCE) * len(SHAPES) * 3 == 72
    # Exercise the actual CSV audit, including same-count wrong-identity refusal.
    rows = [dict(zip(FIELDS, key, strict=True), rayon_threads='1', vendor_threads='1',
                 samples_ms='[0.1,0.1,0.1,0.1,0.1]', total_ms='0.1') for key in expected('gemm', 1)]
    with tempfile.TemporaryDirectory() as temp:
        path = Path(temp) / 'synthetic.csv'
        for bad in (False, True):
            if bad:
                rows[0]['batch'] = '2'
            with path.open('w') as stream:
                writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
                writer.writeheader()
                writer.writerows(rows)
            try:
                audit(path, 'gemm', 1, False)
            except AssertionError:
                assert bad
            else:
                assert not bad
    print('offline check:96 cells/block,768 total,72 timing +18 verification processes; valid/forged CSV checked')


def run(agent_pid):
    check()
    assert sys.platform == 'linux' and Path('/proc/stat').is_file()
    assert shutil.which('taskset') and shutil.which('timeout')
    OUT.mkdir()  # Never overwrite an attempt, including a partial failure.
    references = {'A': '20261018T153011Z-native-floor-stage1-A-cholesky',
                  'B': '20261018T155301Z-native-floor-stage1-B-cholesky'}
    records = {s: yaml.safe_load((ROOT / 'data/results/zen5-cpu/faer-kernels' / name / 'run.yaml').read_text())
               for s, name in references.items()}
    pins = {t: records['A']['threads']['cpu_sets'][str(t)] for t in (1, 4, 8)}
    domains = {frozenset(rr.l3_domain(cpu)) for cpus in pins.values() for cpu in rr.parse_cpu_list(cpus)}
    assert len(domains) == 1, 'measurement spans L3 domains'
    watched = set(next(iter(domains)))
    sources = [ROOT, ROOT.parent / 'campaign-toolkit', ROOT / 'extern/t4a-faer', ROOT / 'extern/upstream-faer']
    commits = {str(p): rr.git(p, 'rev-parse', 'HEAD') for p in sources}
    assert commits[str(sources[1])] == '9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5'
    assert Path(rr.__file__).resolve().parent.parent == sources[1]
    assert commits[str(sources[2])] == records['B']['library']['commit']
    assert commits[str(sources[3])] == records['A']['upstream']['commit']
    rr.git(ROOT, 'diff', '--exit-code', records['A']['harness']['commit'], 'HEAD', '--',
           'fbench', 'Cargo.toml', 'Cargo.lock')
    env = dict(os.environ, PINNED_RETRIES='8', PINNED_IDLE_SECONDS='3', PINNED_MAX_BUSY='0.05')
    for key in yaml.safe_load((ROOT / 'benchmarks/campaign.yaml').read_text())['vendor_env']:
        env.pop(key, None)
    env.pop('FBENCH_ALLOW_BOOST', None)

    def guard():
        rr.require_observer_off_measured_cpus(pins)
        assert Path(f'/proc/{agent_pid}/comm').read_text().strip() == 'pi'
        affinities = {p.name: sorted(os.sched_getaffinity(int(p.name)))
                      for p in Path(f'/proc/{agent_pid}/task').iterdir()}
        assert affinities and all(not set(v) & watched for v in affinities.values())
        assert rr.boost_state().get('cpufreq_boost') == '0'
        power = {str(cpu): {k: (Path(f'/sys/devices/system/cpu/cpu{cpu}/cpufreq') / k).read_text().strip()
                            for k in ('scaling_governor', 'energy_performance_preference', 'scaling_max_freq')}
                 for cpu in sorted(watched)}
        assert all(v == {'scaling_governor': 'performance', 'energy_performance_preference': 'performance',
                         'scaling_max_freq': '2000000'} for v in power.values())
        for source, commit in commits.items():
            assert rr.git(source, 'rev-parse', 'HEAD') == commit
            assert not rr.git(source, 'status', '--porcelain', '--untracked-files=no'), source
        for record in records.values():
            assert hashlib.sha256(Path(record['binary']['path']).read_bytes()).hexdigest() == record['binary']['sha256']
        return {'power': power, 'agent_thread_affinities': affinities}

    def capture(name, command, environ):
        before = guard()
        (OUT / f'{name}.command.json').write_text(json.dumps({
            'argv': command, 'before': before, 'utc': datetime.datetime.now(datetime.UTC).isoformat()}, indent=2) + '\n')
        print(name, flush=True)
        log_path = OUT / f'{name}.log'
        stdout_path = OUT / f'{name}.stdout'
        with log_path.open('w') as log, stdout_path.open('w') as stdout:
            result = subprocess.run(command, check=False, env=environ, stdout=stdout, stderr=log)
        # Preserve wrapper's command-failure/timeout temporary evidence too.
        for stdout, stderr in re.findall(r'evidence retained at (\S+) and (\S+)', log_path.read_text()):
            for source in (stdout, stderr):
                shutil.copy2(source, OUT / f'{name}-{Path(source).name}')
        after = {'returncode': result.returncode}
        (OUT / f'{name}.after.json').write_text(json.dumps(after) + '\n')
        after['after'] = guard()
        (OUT / f'{name}.after.json').write_text(json.dumps(after, indent=2) + '\n')
        result.check_returncode()  # No outer retry; incomplete evidence remains in place.
        return stdout_path.read_text()

    def execute(side, family, t, name, verify):
        path = OUT / f'{name}.csv'
        command = argv(records[side]['binary']['path'], pins[t], family, t, path, verify)
        capture(name, command, dict(env, PINNED_CSV=str(path)))
        audit(path, family, t, verify)

    os.chdir(ROOT)
    with (ROOT / 'target/campaign.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        initial = guard()
        identity = {'diagnostic_only': True, 'adoption': False, 'sequence_blocks': SEQUENCE,
                    'recording_sources': commits, 'canonical_references': references,
                    'compiled_records': records, 'pins': pins, 'watched_l3': sorted(watched),
                    'observer_cpus': sorted(os.sched_getaffinity(0)), 'initial': initial,
                    'worker_policy_env': {k: env.get(k) for k in ('KMP_BLOCKTIME', 'OMP_WAIT_POLICY', 'LD_LIBRARY_PATH')}}
        (OUT / 'identity.json').write_text(json.dumps(identity, indent=2) + '\n')
        for side, record in records.items():
            for t, cpus in pins.items():
                info = capture(f'{side}-info-{t}t', ['timeout', '--kill-after=15s', '30s',
                               'taskset', '-c', cpus, record['binary']['path'], 'info', '--threads', str(t)], env)
                assert f'threads.rayon_observed={t}\n' in info and f'threads.vendor_reported={t}\n' in info
                assert 'vendor.name=mkl\n' in info
                if t == 1:
                    assert 'threads.faer=sequential\n' in info
            for family in SHAPES:
                for t in pins:
                    execute(side, family, t, f'verify-{side}-{family}-{t}t', True)
        for block, side in enumerate(SEQUENCE):
            for family in SHAPES:
                for t in pins:
                    execute(side, family, t, f'block{block}-{side}-{family}-{t}t', False)
        guard()
        (OUT / 'complete.json').write_text(json.dumps({'blocks': 8, 'timing_processes': 72,
            'verification_processes': 18, 'records': 768, 'adoption': False}) + '\n')


if __name__ == '__main__':
    if sys.argv[1:] == ['--check']:
        check()
    else:
        run(int(sys.argv[1]))
