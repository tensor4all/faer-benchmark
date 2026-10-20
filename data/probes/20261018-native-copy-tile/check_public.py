"""Dummy-only checks of the actual recorder/audit; never launch a benchmark."""
import csv
import json
import os
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from unittest import mock

import record_public as run


def check():
    run.install_interrupt_handlers()
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        rows = [dict(zip(run.FIELDS, (d, '', o, str(m), str(n), method, '1'), strict=True),
                     total_ms='0.300000000', samples_ms='[0.1,0.2,0.3,0.4,0.5]')
                for d in ('f64', 'c64') for o in ('c', 'f') for m, n in run.SHAPES
                for method in ('to_owned', 'cloned')]
        path = root / 'fixture.csv'

        def write(data):
            with path.open('w', newline='') as stream:
                writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
                writer.writeheader()
                writer.writerows(data)

        write(rows)
        assert len(run.audit(path)) == 64
        for kind in ('identity', 'duplicate', 'samples', 'nan', 'median', 'threads'):
            bad = [dict(r) for r in rows]
            if kind == 'identity':
                bad[0]['m'] = '33'
            elif kind == 'duplicate':
                bad[1] = dict(bad[0])
            elif kind == 'samples':
                bad[0]['samples_ms'] = '[0.1,0.2,0.3,0.4]'
            elif kind == 'nan':
                bad[0]['samples_ms'] = '[0.1,0.2,NaN,0.4,0.5]'
            elif kind == 'median':
                bad[0]['total_ms'] = '0.31'
            else:
                bad[0]['threads'] = '8'
            write(bad)
            try:
                run.audit(path)
            except AssertionError:
                pass
            else:
                raise AssertionError('forged CSV accepted: ' + kind)
        rounded = [dict(r, total_ms='0.123456789', samples_ms='[0.1,0.11,0.12345678949,0.2,0.3]') for r in rows]
        write(rounded)
        run.audit(path)  # valid nine-decimal median, not exact unrounded equality
        run.CFG = {'cpus': 'fixture-only'}
        for i in range(4):
            argv = run.argv('dummy', i, root / 'result.csv')
            assert argv[-3:] == ['dummy', str(i), str(root / 'result.csv')]
        assert run.SEQUENCE.count('A') == run.SEQUENCE.count('B') == 4

        def call(name, command, seconds=3, failure=False):
            directory = root / name
            run.INTERRUPTS.clear()  # dummy processes only; actual record never clears requests
            try:
                with mock.patch.object(run, 'state', return_value={'dummy': True}):
                    run.capture(directory, command, dict(os.environ), time.monotonic() + seconds)
            except RuntimeError:
                assert failure
            else:
                assert not failure
            return directory

        okay = call('okay', [sys.executable, '-c', 'print("saved stdout")'])
        assert json.loads((okay / 'terminal.json').read_text()) == {'kind': 'exit', 'returncode': 0}
        assert 'saved stdout' in (okay / 'stdout').read_text()
        failed = call('exit3', [sys.executable, '-c', 'import sys; print("partial");sys.exit(3)'], failure=True)
        assert json.loads((failed / 'terminal.json').read_text()) == {'kind': 'exit', 'returncode': 3}
        assert 'partial' in (failed / 'stdout').read_text()
        missing = call('launch-error', [str(root / 'absent-executable')], failure=True)
        assert json.loads((missing / 'terminal.json').read_text())['kind'] == 'exception'
        # No evidence copy operation exists. Force the remaining fallible inventory
        # step to fail; original terminal and raw TMPDIR evidence must survive.
        with mock.patch.object(run, 'inventory', side_effect=OSError('dummy inventory failure')):
            harvested = call('inventory-error', [sys.executable, '-c',
                'import os,pathlib;pathlib.Path(os.environ["TMPDIR"],"raw").write_text("preserved")'], failure=True)
        assert json.loads((harvested / 'terminal.json').read_text()) == {'kind': 'exit', 'returncode': 0}
        assert (harvested / 'tmp/raw').read_text() == 'preserved'
        assert 'inventory:' in (harvested / 'errors.json').read_text()
        with mock.patch.object(run, 'state', side_effect=[{}, OSError('dummy after failure')]):
            after = root / 'after-error'
            try:
                run.capture(after, [sys.executable, '-c', 'print("before failed guard")'], dict(os.environ), time.monotonic() + 3)
            except RuntimeError:
                pass
            else:
                raise AssertionError('after guard failed open')
        assert json.loads((after / 'terminal.json').read_text()) == {'kind': 'exit', 'returncode': 0}
        assert 'before failed guard' in (after / 'stdout').read_text()
        original_dump = run.dump
        started = []

        def broken_receipt(path, value):
            if path.name == 'started.json':
                started.append(value)
                raise OSError('dummy started receipt failure')
            if path.name == 'cleanup.json':
                raise OSError('dummy cleanup receipt failure')
            original_dump(path, value)

        with mock.patch.object(run, 'dump', side_effect=broken_receipt):
            receipt_error = call('receipt-error', [sys.executable, '-c', 'import time;time.sleep(60)'], failure=True)
        assert started and not Path(f"/proc/{started[0]['pid']}").exists()
        assert json.loads((receipt_error / 'terminal.json').read_text())['kind'] == 'exception'
        expired = call('expired', [str(root / 'must-not-launch')], seconds=-1, failure=True)
        assert not (expired / 'started.json').exists()
        assert 'absolute deadline expired' in (expired / 'terminal.json').read_text()
        # POST1: primary terminal path alone fails; original exit still has a
        # durable final receipt. No command or filesystem-wide failure implied.
        def broken_terminal(path, value):
            if path.name == 'terminal.json':
                raise OSError('dummy primary terminal failure')
            original_dump(path, value)

        with mock.patch.object(run, 'dump', side_effect=broken_terminal):
            fallback = call('terminal-fallback', [sys.executable, '-c', 'import sys;sys.exit(3)'], failure=True)
        assert not (fallback / 'terminal.json').exists()
        assert json.loads((fallback / 'final.json').read_text())['terminal'] == {'kind': 'exit', 'returncode': 3}
        # POST2: REAL signals arrive after OS launch but BEFORE caller ownership,
        # and on the first cleanup group scan. Handler must never raise there.
        original_popen = run.subprocess.Popen
        owned = []

        def interrupted_launch(*args, **kwargs):
            child = original_popen(*args, **kwargs)
            owned.append(child)
            os.kill(os.getpid(), signal.SIGTERM)
            return child

        with mock.patch.object(run.subprocess, 'Popen', side_effect=interrupted_launch):
            launch_interrupt = call('launch-interrupt', [sys.executable, '-c', 'import time;time.sleep(60)'], failure=True)
        assert owned[0].returncode is not None and not run.group_members(owned[0].pid)
        assert json.loads((launch_interrupt / 'final.json').read_text())['signals'] == [signal.SIGTERM]
        original_group_members = run.group_members
        scans = []

        def interrupted_cleanup(pgid):
            if not scans:
                scans.append(pgid)
                os.kill(os.getpid(), signal.SIGINT)
            return original_group_members(pgid)

        with mock.patch.object(run, 'group_members', side_effect=interrupted_cleanup):
            cleanup_interrupt = call('cleanup-interrupt', [sys.executable, '-c', 'import time;time.sleep(60)'], seconds=.3, failure=True)
        assert not original_group_members(scans[0])
        assert json.loads((cleanup_interrupt / 'cleanup.json').read_text())['direct_child_reaped']
        # POST3: a quick child succeeds but validation consumes remaining budget.
        def slow_after():
            time.sleep(.25)
            return {}

        run.INTERRUPTS.clear()
        guards = []

        def validation_state():
            guards.append(True)
            return {} if len(guards) == 1 else slow_after()

        with mock.patch.object(run, 'state', side_effect=validation_state):
            late = root / 'late-validation'
            try:
                run.capture(late, [sys.executable, '-c', 'pass'], dict(os.environ), time.monotonic() + .2)
            except RuntimeError:
                pass
            else:
                raise AssertionError('late validation accepted')
        final = json.loads((late / 'final.json').read_text())
        assert final['terminal'] == {'kind': 'exit', 'returncode': 0}
        assert 'post-validation' in str(final['errors'])
        try:
            run.check_budget(time.monotonic() - 1)
        except TimeoutError:
            pass
        else:
            raise AssertionError('completion budget check failed open')
        # Parent handles TERM and reaps its own grandchild, so the test leaves no
        # orphan zombies. A second single-child fixture exercises KILL fallback.
        script = '''import os,signal,sys,time
child=os.fork()
if child==0:
 time.sleep(60)
else:
 def stop(sig,frame):
  try: os.kill(child,signal.SIGTERM)
  except ProcessLookupError: pass
  os.waitpid(child,0)
  sys.exit(0)
 signal.signal(signal.SIGTERM,stop)
 print(os.getpid(),child,flush=True)
 time.sleep(60)
'''
        sleepy = call('grandchild-timeout', [sys.executable, '-c', script], seconds=.3, failure=True)
        assert json.loads((sleepy / 'terminal.json').read_text())['kind'] == 'timeout'
        cleanup = json.loads((sleepy / 'cleanup.json').read_text())
        assert cleanup['direct_child_reaped'] and not cleanup['live_remaining']
        assert not run.group_members(json.loads((sleepy / 'started.json').read_text())['pgid'])
        stubborn = call('kill-timeout', [sys.executable, '-c',
            'import signal,time;signal.signal(signal.SIGTERM,signal.SIG_IGN);time.sleep(60)'], seconds=.3, failure=True)
        cleanup = json.loads((stubborn / 'cleanup.json').read_text())
        assert [a['signal'] for a in cleanup['actions']] == ['SIGTERM', 'SIGKILL']
        assert cleanup['direct_child_reaped'] and not cleanup['live_remaining']
    for args, env in [([sys.executable, '-O', run.__file__, '--check'], dict(os.environ)),
                      ([sys.executable, run.__file__, '--check'], dict(os.environ, PYTHONOPTIMIZE='1'))]:
        result = subprocess.run(args, check=False, env=env, capture_output=True, text=True, timeout=10)
        assert result.returncode and 'Refusing optimized Python' in result.stderr
    print('PASS: real CSV valid/6 forged/precision; argv; capture success/exit/launch/inventory/afterguard; '
          'receipt-write failure still terminates/reaps; expired deadline; owned child+grandchild TERM and stubborn '
          'KILL/reap; primary-terminal fallback/real launch+cleanup interrupts/late-validation deadline; '
          '-O/env refusal. No benchmark executed.')
