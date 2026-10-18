"""Guard artifact checks with fake programs; no real pinning, sleeping or timing."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

PINNED = Path(__file__).resolve().parents[1] / 'benchmarks/scripts/pinned.sh'
FAKE = r'''
import os
from pathlib import Path
import sys
name = Path(sys.argv[0]).name
root = Path(os.environ['SIM_ROOT'])
def count(kind):
    path = root / kind
    value = int(path.read_text())+1 if path.exists() else 1
    path.write_text(str(value))
    return value
if name == 'python3':
    n = count('checks')
    bad = str(n) in os.environ.get('FAIL_CHECKS','').split(',')
    print('cpu4 busy=0.00\ncpu16 busy=' + ('0.20' if bad else '0.00') + ' (cache peer)',file=sys.stderr)
    sys.exit(1 if bad else 0)
if name == 'taskset':
    os.execv(sys.argv[3],sys.argv[3:])
if name == 'mktemp':
    if '-d' in sys.argv and os.environ.get('FAIL_ARCHIVE') == 'mkdir':
        sys.exit(1)
    os.execv(os.environ['REAL_MKTEMP'],[os.environ['REAL_MKTEMP'],*sys.argv[1:]])
if name == 'cp':
    if sys.argv[-1].endswith('result.csv') and os.environ.get('FAIL_ARCHIVE') == 'copy':
        sys.exit(1)
    os.execv(os.environ['REAL_CP'],[os.environ['REAL_CP'],*sys.argv[1:]])
if name == 'writer':
    n = count('commands')
    args = sys.argv[1:]
    paths = [args[i+1] for i,arg in enumerate(args) if arg == '--csv']
    if paths and not os.environ.get('OMIT_CSV'):
        Path(paths[-1]).write_text(f'fake,{n}\n')
    print(f'sample={n}')
    sys.exit(int(os.environ.get('COMMAND_STATUS','0')))
raise RuntimeError(name)
'''


@unittest.skipUnless(sys.platform.startswith('linux') and Path('/proc/stat').exists(), 'Linux guard branch')
class PinnedTest(unittest.TestCase):
    def test_rejected_evidence_and_failure_paths(self):
        cases = [
            ('reject_accept', '2', 2, 0, 2, 1, {}),
            ('two_rejections', '2,4', 3, 0, 3, 2, {}),
            ('exhausted', '2,4', 2, 75, 2, 2, {}),
            ('precheck_only', '1', 2, 0, 1, 0, {}),
            ('command_failure', '', 2, 42, 1, 0, {'COMMAND_STATUS':'42'}),
            ('mkdir_failure', '2', 2, 1, 1, 0, {'FAIL_ARCHIVE':'mkdir'}),
            ('partial_copy_failure', '2', 2, 1, 1, 1, {'FAIL_ARCHIVE':'copy'}),
            ('missing_declared_csv', '2', 2, 1, 1, 1, {'OMIT_CSV':'1'}),
            ('stdout_only', '2', 2, 0, 2, 1, {'NO_CSV':'1'}),
        ]
        for name, failures, retries, status, commands, archives, extra in cases:
            with self.subTest(name=name), tempfile.TemporaryDirectory(prefix='pinned test ') as tmp:
                root = Path(tmp)
                bindir = root/'bin'
                bindir.mkdir()
                script = bindir/'fake.py'
                script.write_text(f'#!{sys.executable}\n'+FAKE)
                script.chmod(0o755)
                for program in ('python3','taskset','mktemp','cp','writer'):
                    (bindir/program).symlink_to(script)
                scratch = root/'scratch'
                scratch.mkdir()
                csv = root/'effective output.csv'
                ignored = root/'ignored.csv'
                ignored.write_text('unchanged')
                env = dict(os.environ, PATH=str(bindir)+os.pathsep+os.environ['PATH'],
                           SIM_ROOT=str(root),TMPDIR=str(scratch),FAIL_CHECKS=failures,
                           REAL_CP=shutil.which('cp'),REAL_MKTEMP=shutil.which('mktemp'),
                           PINNED_RETRIES=str(retries),PINNED_WAIT='0',PINNED_IDLE_SECONDS='0',
                           PINNED_CSV='' if extra.get('NO_CSV') else str(csv),**extra)
                cmd = ['bash',str(PINNED),'4','--',str(bindir/'writer')]
                if not extra.get('NO_CSV'):
                    # The caller declares the effective last --csv, not a guessed token scan.
                    cmd += ['--csv',str(ignored),'--csv',str(csv)]
                result = subprocess.run(cmd,env=env,text=True,capture_output=True)
                self.assertEqual(result.returncode,status,result.stderr)
                self.assertEqual(int((root/'commands').read_text()),commands)
                self.assertEqual(ignored.read_text(),'unchanged')
                saved = sorted(root.rglob('*.rejected.*'))
                self.assertEqual(len(saved),archives,result.stderr)
                samples = []
                for folder in saved:
                    self.assertTrue(folder.is_dir())
                    samples.append((folder/'command.stdout').read_text().strip())
                    if not extra and name != 'precheck_only':
                        self.assertIn('cpu16 busy=0.20 (cache peer)',(folder/'guard.log').read_text())
                        self.assertIn('fake,',(folder/'result.csv').read_text())
                self.assertEqual(set(samples),{f'sample={i}' for i in range(1,archives+1)})
                if status == 0:
                    self.assertEqual(result.stdout.strip(),f'sample={commands}')
                    if not extra.get('NO_CSV'):
                        self.assertEqual(csv.read_text(),f'fake,{commands}\n')
                if extra.get('FAIL_ARCHIVE') or extra.get('OMIT_CSV') or name == 'command_failure':
                    self.assertIn('evidence retained at',result.stderr)
                    self.assertEqual(len(list(scratch.glob('tmp.*'))),2)
                if name == 'command_failure':
                    self.assertEqual((root/'checks').read_text(),'1')
                if name == 'precheck_only':
                    self.assertIn('cpu16 busy=0.20 (cache peer)',result.stderr)


if __name__ == '__main__':
    unittest.main()
