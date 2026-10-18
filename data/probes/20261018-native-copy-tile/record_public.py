"""Thin public-copy diagnostic; --check runs dummy tests only, --record PI_PID records.

Own prior owned-copy/run.py and reviewed isolation guard adapted, not new statistics.
Original Rust probe, attributed pinned.sh and toolkit are unchanged. Never adopt here.
"""
import os
import sys

if not __debug__ or os.environ.get('PYTHONOPTIMIZE'):
    raise SystemExit('Refusing optimized Python/PYTHONOPTIMIZE: safety checks must remain enabled')

import collections
import csv
import datetime
import fcntl
import hashlib
import json
import math
import re
import signal
import statistics
import subprocess
import time
from pathlib import Path

import yaml
from campaign_toolkit import record_run as rr

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
SEQUENCE = 'ABBABAAB'
INTERRUPTS = []


def install_interrupt_handlers():
    # Never raise asynchronously inside Popen ownership or group cleanup.
    # The CLI owns this process; waits observe requests within 100 ms.
    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, lambda signum, frame: INTERRUPTS.append(signum))


def check_budget(deadline):
    if INTERRUPTS:
        raise InterruptedError(f'recorder received signals {INTERRUPTS}')
    if time.monotonic() >= deadline:
        raise TimeoutError('absolute deadline expired')


FIELDS = ('dtype', 'note', 'order', 'm', 'n', 'method', 'threads')
SHAPES = [(32, 32), (64, 64), (96, 96), (128, 128), (256, 256), (512, 512), (1024, 64), (64, 1024)]


def dump(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit(path):
    expected = collections.Counter((d, '', o, str(m), str(n), method, '1')
                                   for d in ('f64', 'c64') for o in ('c', 'f')
                                   for m, n in SHAPES for method in ('to_owned', 'cloned'))
    with path.open() as stream:
        rows = list(csv.DictReader(stream))
    assert collections.Counter(tuple(r[k] for k in FIELDS) for r in rows) == expected
    for row in rows:
        samples = json.loads(row['samples_ms'])
        total = float(row['total_ms'])
        assert len(samples) == 5 and all(math.isfinite(x) and x > 0 for x in samples)
        assert math.isfinite(total) and total > 0
        assert abs(total - statistics.median(samples)) <= 0.5001e-9  # nine decimal ms
    return rows


def group_members(pgid):
    """Snapshot live owned group members; zombies cannot load the measured domain."""
    members = []
    for path in Path('/proc').glob('[0-9]*/stat'):
        try:
            fields = path.read_text().rpartition(')')[2].split()
            if int(fields[2]) == pgid and fields[0] != 'Z':
                members.append({'pid': int(path.parent.name), 'state': fields[0]})
        except (FileNotFoundError, ProcessLookupError):
            pass
    return members


def stop_group(child, receipt):
    """Own only the new session/group. Bounded cleanup is not more measurement time."""
    actions = []
    for sig in (signal.SIGTERM, signal.SIGKILL):
        members = group_members(child.pid)
        actions.append({'signal': sig.name, 'members_before': members})
        try:
            dump(receipt, {'actions': actions, 'direct_child_reaped': False})
        except OSError as exc:
            actions[-1]['receipt_error'] = repr(exc)  # logging failure cannot prevent termination
        if members:
            try:
                os.killpg(child.pid, sig)
            except ProcessLookupError:
                pass
        end = time.monotonic() + 5
        while group_members(child.pid) and time.monotonic() < end:
            child.poll()  # reap the direct child as soon as it exits
            time.sleep(.05)
        if not group_members(child.pid):
            break
    child.wait(timeout=5)
    remaining = group_members(child.pid)
    if remaining:
        raise RuntimeError(f'owned descendants survived cleanup: {remaining}')
    return {'actions': actions, 'direct_child_reaped': True, 'returncode': child.returncode, 'live_remaining': remaining}


def inventory(directory):
    # No copying/harvesting dependency: even missing EXIT-trap messages cannot lose
    # wrapper mktemp evidence, because TMPDIR already points into this directory.
    return {str(p.relative_to(directory)): digest(p) for p in directory.rglob('*') if p.is_file()}


def state():
    rr.require_observer_off_measured_cpus({1: CFG['cpus']})
    suite = yaml.safe_load((ROOT / 'benchmarks/suites/faer-kernels.yaml').read_text())['runs'][0]
    assert CFG['cpus'] == suite['cpu_sets'][suite['threads'].index(1)]
    measured = rr.parse_cpu_list(CFG['cpus'])
    assert len(measured) == 1
    domains = {frozenset(rr.l3_domain(cpu)) for cpu in measured}
    assert len(domains) == 1 and set(next(iter(domains))) == set(CFG['watched_l3'])
    assert Path(f'/proc/{PI_PID}/comm').read_text().strip() == 'pi'
    affinities = {p.name: sorted(os.sched_getaffinity(int(p.name)))
                  for p in Path(f'/proc/{PI_PID}/task').iterdir()}
    assert affinities and all(not set(cpus) & set(CFG['watched_l3']) for cpus in affinities.values())
    assert rr.boost_state().get('cpufreq_boost') == CFG['expected_boost'] == '0'
    power = {str(cpu): {key: (Path(f'/sys/devices/system/cpu/cpu{cpu}/cpufreq') / key).read_text().strip()
                        for key in ('scaling_governor', 'energy_performance_preference', 'scaling_max_freq')}
             for cpu in CFG['watched_l3']}
    assert power == CFG['expected_power']
    for source, commit in COMMITS.items():
        assert rr.git(source, 'rev-parse', 'HEAD') == commit
        assert not rr.git(source, 'status', '--porcelain', '--untracked-files=no'), source
    assert Path(rr.__file__).resolve().parent.parent == ROOT.parent / 'campaign-toolkit'
    for name, sha in CFG['probe_source_sha256'].items():
        assert digest(ROOT / 'data/probes/20261018-owned-copy' / name) == sha
    static_path = ROOT / CFG['static_report']
    assert digest(static_path) == CFG['static_report_sha256']
    static = json.loads(static_path.read_text())
    assert static['prefilter_pass'] is True and len(static['functions']) == 4
    assert all(f['matched'] and f['equal'] and f['A_size'] == f['B_size'] for f in static['functions'])
    for side, item in static['binaries'].items():
        expected = ROOT / 'target/faer-rev' / f"{CFG['records'][side]['ref'][:12]}-mkl/release/fbench"
        assert Path(item['path']) == expected and digest(expected) == item['sha256']
    assert CFG['records'] == json.loads((HERE / 'probe-builds/complete.json').read_text())['records']
    for item in CFG['records'].values():
        assert digest(Path(item['binary'])) == item['sha256']
    return {'power': power, 'agent_threads': affinities, 'sources': COMMITS}


def capture(directory, command, env, deadline):
    directory.mkdir()  # no overwrite, even following incomplete attempts
    tmp = directory / 'tmp'
    tmp.mkdir()
    dump(directory / 'command.json', {'argv': command, 'deadline_monotonic': deadline,
                                     'utc': datetime.datetime.now(datetime.UTC).isoformat()})
    child = None
    terminal = None
    errors = []
    try:
        check_budget(deadline)
        dump(directory / 'before.json', state())
        check_budget(deadline)
        with (directory / 'stdout').open('w') as stdout, (directory / 'stderr').open('w') as stderr:
            child = subprocess.Popen(command, env=dict(env, TMPDIR=str(tmp.resolve())),
                                     stdout=stdout, stderr=stderr, start_new_session=True)
            dump(directory / 'started.json', {'pid': child.pid, 'pgid': child.pid})
            while terminal is None:
                if INTERRUPTS:
                    raise InterruptedError(f'recorder received signals {INTERRUPTS}')
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    terminal = {'kind': 'timeout', 'returncode': None}
                    break
                try:
                    code = child.wait(timeout=min(.1, remaining))
                    terminal = {'kind': 'exit', 'returncode': code}
                except subprocess.TimeoutExpired:
                    pass
            dump(directory / 'terminal.json', terminal)  # BEFORE cleanup/inventory/after-guard
    except BaseException as exc:  # noqa: BLE001 -- persist interruption, clean owned group, then fail
        if terminal is None:
            terminal = {'kind': 'exception', 'returncode': None, 'error': repr(exc)}
            try:
                dump(directory / 'terminal.json', terminal)
            except OSError as write_error:
                errors.append('terminal-write: ' + repr(write_error))
        else:
            errors.append(repr(exc))
    if child is not None:
        try:
            leftovers = group_members(child.pid)
            if terminal['kind'] == 'timeout' or leftovers:
                dump(directory / 'cleanup.json', stop_group(child, directory / 'cleanup.json'))
                if terminal['kind'] == 'exit':
                    errors.append('unexpected live descendants after command exit')
            else:
                child.wait()
        except Exception as exc:  # noqa: BLE001 -- retain original terminal; any cleanup error stops phase
            errors.append('cleanup: ' + repr(exc))
    try:
        dump(directory / 'tmp-inventory.json', inventory(tmp))
    except OSError as exc:
        errors.append('inventory: ' + repr(exc))
    try:
        dump(directory / 'after.json', state())
    except BaseException as exc:  # noqa: BLE001 -- retain original result, log guard failure, then stop
        errors.append('after-guard: ' + repr(exc))
    try:
        check_budget(deadline)  # inventory/after-guard are phase work too
    except (InterruptedError, TimeoutError) as exc:
        errors.append('post-validation: ' + repr(exc))
    dump(directory / 'errors.json', errors)
    dump(directory / 'final.json', {'terminal': terminal, 'errors': errors, 'signals': INTERRUPTS.copy()})
    if terminal != {'kind': 'exit', 'returncode': 0} or errors:
        raise RuntimeError(f'command stopped: {terminal!r}; evidence retained in {directory}')


def argv(binary, start, path):
    return [str(ROOT / 'benchmarks/scripts/pinned.sh'), CFG['cpus'], '--', 'bash', '-c',
            'exec "$1" "$2" > "$3"', 'copy-probe', binary, str(start), str(path)]


def record(pi_pid):
    global CFG, COMMITS, PI_PID
    CFG = json.loads((HERE / 'public-config.json').read_text())
    assert CFG['status'] == 'FROZEN_POST_REVIEWED'
    assert CFG['binary_sequence'] == SEQUENCE and CFG['reps'] == 5 and CFG['prime_ms'] == 250
    assert CFG['process_indices_per_side'] == [0, 1, 2, 3]
    PI_PID = pi_pid

    install_interrupt_handlers()
    sources = [ROOT, ROOT.parent / 'campaign-toolkit', ROOT / 'extern/t4a-faer', ROOT / 'extern/upstream-faer']
    COMMITS = {str(p): rr.git(p, 'rev-parse', 'HEAD') for p in sources}
    assert COMMITS[str(sources[1])] == CFG['toolkit']
    assert COMMITS[str(sources[2])] == CFG['expected_current_extern'] == CFG['records']['B']['ref']
    assert COMMITS[str(sources[3])] == CFG['upstream']
    rr.git(ROOT, 'diff', '--exit-code', CFG['compiled_harness'], 'HEAD', '--', 'fbench', 'Cargo.toml', 'Cargo.lock')
    env = dict(os.environ, PINNED_RETRIES='8', PINNED_IDLE_SECONDS='3', PINNED_MAX_BUSY='0.05',
               PINNED_WAIT='30', RAYON_NUM_THREADS='1', OMP_NUM_THREADS='1',
               OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
    env.pop('FBENCH_ALLOW_BOOST', None)
    out = HERE / 'runtime-public'
    with (ROOT / 'target/campaign.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        out.mkdir()
        deadline = time.monotonic() + 1200
        dump(out / 'identity.json', {'config': CFG, 'initial': state(), 'observer_cpus': sorted(os.sched_getaffinity(0)),
                                    'phase_work_seconds': 1200, 'cleanup_grace_per_signal_seconds': 5,
                                    'diagnostic_only': True, 'adoption': False})
        starts = collections.Counter()
        for block, side in enumerate(SEQUENCE):
            if time.monotonic() >= deadline:
                dump(out / 'phase-timeout.json', {'completed_processes': block, 'no_new_launch': True})
                raise RuntimeError('phase deadline; partial data retained, no outer retry')
            directory = out / f'block{block}-{side}'
            path = directory / 'result.csv'
            command = argv(CFG['records'][side]['binary'], starts[side], path)
            capture(directory, command, dict(env, PINNED_CSV=str(path)), min(time.monotonic() + 420, deadline))
            audit(path)
            check_budget(deadline)
            observed = re.findall(r'configured_threads=(\d+) observed_rayon_threads=(\d+) faer=(\S+)',
                                  (directory / 'stderr').read_text())
            assert observed and all(x == ('1', '1', 'Seq') for x in observed)
            starts[side] += 1
            print('accepted', block, side, starts[side], flush=True)
        assert starts == {'A': 4, 'B': 4}
        state()
        check_budget(deadline)
        dump(out / 'complete.json', {'processes': 8, 'accepted_rows': 512, 'diagnostic_only': True, 'adoption': False})


if __name__ == '__main__':
    if sys.argv[1:] == ['--check']:
        import check_public
        check_public.check()
    elif len(sys.argv) == 3 and sys.argv[1] == '--record':
        record(int(sys.argv[2]))
    else:
        raise SystemExit('usage: record_public.py --check | --record PI_PID')
