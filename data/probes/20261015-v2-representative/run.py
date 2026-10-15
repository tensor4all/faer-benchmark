#!/usr/bin/env python3
"""Diagnostic representative controls, not a published/full campaign run."""
import argparse
import copy
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import yaml
from campaign_toolkit import descriptor, record_run, report_run, timing_evidence

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
CPU = {1: '4', 4: '4-7', 8: '4-11'}
# (name, families, shapes): chosen before seeing these measurements.
GROUPS = {
    1: [('gemm', 'gemm', '4,256'), ('qr-factor', 'qr_factor', '64x8,8x64')],
    4: [('gemm', 'gemm', '16x4096x240'), ('lu-solve', 'lu,solve', '256'),
        ('svd', 'svd_thin', '64x1024')],
    8: [('qr', 'qr_factor,qr', '4096x256'),
        ('decompose', 'cholesky,eigh,svd_values', '512'),
        ('householder', 'householder_apply', '4096x256')],
}


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def sources_unchanged(manifest):
    for name in ('library', 'upstream', 'harness', 'toolkit'):
        identity = manifest[name]
        path = ROOT if name == 'harness' else identity['measured_path']
        head = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], text=True).strip()
        dirty = subprocess.check_output(['git', '-C', str(path), 'status', '--porcelain', '--untracked-files=no'], text=True).strip()
        if head != identity['commit'] or dirty:
            raise RuntimeError(f'{name} source changed: {head}, dirty={bool(dirty)}')
    if digest(manifest['binary']['path']) != manifest['binary']['sha256']:
        raise RuntimeError('binary changed since the provenance smoke')


def main():
    import fcntl
    os.chdir(ROOT)
    descriptor.set_root(ROOT)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mkl_smoke', type=Path)
    parser.add_argument('openblas_smoke', type=Path)
    args = parser.parse_args()
    if (HERE / 'metadata.json').exists():
        raise RuntimeError('control attempt already exists; preserve its metadata and logs')
    record_run.require_observer_off_measured_cpus({str(n): cpus for n, cpus in CPU.items()})
    suite = yaml.safe_load((ROOT / 'benchmarks/suites/faer-kernels.yaml').read_text())
    env = dict(os.environ)
    for key in descriptor.current().vendor_env:
        env.pop(key, None)
    # The declared one-attempt policy could not finish a 64-process package on this
    # host: ~3.5% of 3 s guard windows were rejected by unrelated host activity
    # (measured in attempt 1/2 and the repro runs), and a rejection discards that
    # process. Retries are the pinned protocol's own admission retry, the same
    # policy the production recorder uses by default; a discarded attempt's output
    # is overwritten by the first attempt whose windows were idle, and every guard
    # log records the retries. All attempts keep their own metadata/README.
    env['PINNED_RETRIES'] = '8'
    outcomes = []
    metadata = {'driver_argv': sys.argv, 'driver_sha256': digest(__file__),
                'analysis_sha256': digest(HERE / 'analyze.py'),
                'settings': {'prime_ms': 3000, 'reps': 30, 'aa': 3},
                'cpu_sets': CPU, 'groups': GROUPS, 'commands': outcomes, 'provenance': {},
                'observer_affinity': sorted(os.sched_getaffinity(0)),
                'pin_policy': {'retries': env['PINNED_RETRIES'],
                               'wait_s': env.get('PINNED_WAIT', '30'),
                               'idle_window_s': env.get('PINNED_IDLE_SECONDS', '3'),
                               'max_busy': env.get('PINNED_MAX_BUSY', '0.05')},
                'warning_rule': '(max(process medians)-min(process medians))/median > 0.05',
                'note': 'Diagnostic controls only; no provider-ratio equality criterion, C/F are separate fixtures.'}
    meta_path = HERE / 'metadata.json'
    # Same admission lock as record_run: no builds or parallel campaigns.
    with (ROOT / 'target/campaign.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        for vendor, smoke in [('mkl', args.mkl_smoke), ('openblas', args.openblas_smoke)]:
            original = yaml.safe_load((smoke / 'run.yaml').read_text())
            sources_unchanged(original)
            metadata['provenance'][vendor] = {key: original[key] for key in
                ('library', 'upstream', 'harness', 'toolkit', 'binary', 'vendor', 'host')}
            meta_path.write_text(json.dumps(metadata, indent=2) + '\n')
            for n, groups in GROUPS.items():
                directory = HERE / vendor / f'{n}t'
                directory.mkdir(parents=True, exist_ok=False)
                dtype = 'c64' if n == 4 else 'f64'
                manifest = copy.deepcopy(original)
                manifest['command'] = f'python3 {Path(__file__).relative_to(ROOT)} (see metadata.json commands)'
                manifest['threads']['counts'] = [n]
                manifest['threads']['cpu_sets'] = {str(n): CPU[n]}
                manifest['timing_policy'].update(minimum_untimed_priming_ms=3000, repetitions=30,
                    notes='DIAGNOSTIC candidate protocol, not yet a validated full-suite policy')
                manifest['run_spec'] = {'populations': [
                    {'regime': name, 'families': families.split(','), 'n': shapes.split(','), 'batch': [1]}
                    for name, families, shapes in groups], 'dtypes': [dtype], 'order': ['c', 'f'],
                    'engines': original['run_spec']['engines'], 'aa': 3, 'covers_declared_suite': False}
                manifest['verification_files'] = []
                manifest['result_files'] = []
                manifest['guards']['logs'] = []
                shutil.copyfile(smoke / 'build-info.json', directory / 'build-info.json')
                info = [manifest['binary']['path'], 'info', '--threads', str(n)]
                (directory / 'binary-info-command.json').write_text(json.dumps(info) + '\n')
                (directory / 'binary-info.txt').write_text(subprocess.check_output(info, text=True, env=env))
                for repeat in [-1, 0, 1, 2]:
                    for name, families, shapes in groups:
                        verify = repeat == -1
                        stem = f'verify-{name}-{n}t' if verify else f'run{repeat}-{name}-{n}t'
                        csv_path = directory / f'{stem}.csv'
                        command = ['timeout', '--kill-after=10s', '180s',
                            str(ROOT / 'benchmarks/scripts/pinned.sh'), CPU[n], '--',
                            manifest['binary']['path'], 'verify' if verify else 'run', '--threads', str(n),
                            '--n', shapes, '--family', families, '--dtype', dtype, '--batch', '1',
                            '--regime', name, '--csv', str(csv_path)]
                        if not verify:
                            command += ['--statistic', 'median', '--prime-ms', '3000', '--reps', '30',
                                        '--rotate-rows', str(repeat)]
                        record = {'vendor': vendor, 'threads': n, 'start': datetime.datetime.now(datetime.UTC).isoformat(),
                                  'argv': command, 'returncode': None}
                        outcomes.append(record)
                        meta_path.write_text(json.dumps(metadata, indent=2) + '\n')
                        with (directory / f'{stem}.stdout').open('w') as stdout, (directory / f'{stem}.guard').open('w') as stderr:
                            result = subprocess.run(command, env=env, stdout=stdout, stderr=stderr, check=False)
                        record['returncode'] = result.returncode
                        record['end'] = datetime.datetime.now(datetime.UTC).isoformat()
                        meta_path.write_text(json.dumps(metadata, indent=2) + '\n')
                        if result.returncode:
                            raise RuntimeError(f'{stem} failed ({result.returncode}); preserve logs, no automatic retry')
                        field = 'verification_files' if verify else 'result_files'
                        manifest[field].append(csv_path.name)
                        manifest['guards']['logs'].append(f'{stem}.guard')
                        print(vendor, n, stem, 'passed', flush=True)
                sources_unchanged(manifest)
                manifest['timestamp'] = datetime.datetime.now(datetime.UTC).isoformat()
                timing_evidence.validate(manifest, directory)
                # A control contract, not run.yaml: populations intentionally differ
                # from the published suite. Validate the common evidence, not pretend
                # the current declaration selected these bespoke diagnostic cells.
                (directory / 'control-contract.yaml').write_text(yaml.safe_dump(manifest, sort_keys=False))
                rows = report_run.read_rows([directory / name for name in manifest['result_files']])
                (directory / 'report.md').write_text(report_run.render(manifest, suite, rows, directory))
        if digest(__file__) != metadata['driver_sha256'] or digest(HERE / 'analyze.py') != metadata['analysis_sha256']:
            raise RuntimeError('control/analysis scripts changed during the controls')
        metadata['complete'] = True
        meta_path.write_text(json.dumps(metadata, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
