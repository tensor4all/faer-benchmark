"""Offline CLI audit: no timings; real, unchanged baseline evidence is read-only."""
import argparse
import csv
import json
import pathlib
import subprocess
import sys
import tempfile

import yaml
from campaign_toolkit import descriptor, validate_run

ROOT = pathlib.Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'data/results/zen5-cpu/faer-kernels/20261018T070736Z-upstream-lu-baseline'


def clone(source, dest):
    dest.mkdir()
    for path in source.iterdir():
        if path.name != 'run.yaml':
            (dest / path.name).symlink_to(path.resolve())
    manifest = yaml.safe_load((source / 'run.yaml').read_text())
    (dest / 'run.yaml').write_text(yaml.safe_dump(manifest))
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json', type=pathlib.Path, required=True)
    args = parser.parse_args()
    descriptor.set_root(ROOT)
    results = []
    with tempfile.TemporaryDirectory(prefix='candidate-coverage-audit-') as tmp:
        tmp = pathlib.Path(tmp)
        base = tmp / 'baseline'
        clone(SOURCE, base)
        errors = validate_run.validate(base / 'run.yaml')
        if errors:
            raise ValueError(f'reference fixture not valid: {errors}')
        for case in ('empty-results', 'missing-controls', 'missing-third-start',
                     'unmatched-selector', 'valid-unselected-dtype-subset'):
            cand = tmp / case
            manifest = clone(SOURCE, cand)
            extra = []
            if case == 'empty-results':
                manifest['result_files'] = []
            elif case == 'missing-third-start':
                manifest['result_files'] = [n for n in manifest['result_files'] if not n.startswith('run2-')]
            elif case in ('missing-controls', 'valid-unselected-dtype-subset'):
                names = manifest['result_files']
                if case == 'valid-unselected-dtype-subset':
                    manifest['run_spec']['dtypes'] = ['f64']
                    names = names + manifest['verification_files']
                for name in names:
                    path = cand / name
                    with path.open(newline='') as handle:
                        reader = csv.DictReader(handle)
                        fields = reader.fieldnames
                        rows = [r for r in reader
                                if (r['row'] != 'faer-upstream' if case == 'missing-controls'
                                    else r['dtype'] == 'f64')]
                    path.unlink()  # remove fixture symlink, never edit original CSV
                    with path.open('w', newline='') as handle:
                        writer = csv.DictWriter(handle, fieldnames=fields)
                        writer.writeheader()
                        writer.writerows(rows)
            else:
                extra = ['--cells', '__no_declared_cell__']
            (cand / 'run.yaml').write_text(yaml.safe_dump(manifest))
            command = [sys.executable, str(ROOT / 'scripts/candidate_compare.py'),
                       '--baseline', str(base), '--candidate', str(cand),
                       '--checkout', str(ROOT.parent / 'faer'), *extra]
            proc = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=30,
                                  check=False)
            results.append({'case': case, 'returncode': proc.returncode,
                            'stdout': proc.stdout, 'stderr': proc.stderr,
                            'candidate_validation_errors': validate_run.validate(cand / 'run.yaml'),
                            'expected_refusal': True})
            print(f'{case}: returncode={proc.returncode}')
            print(proc.stdout, end='')
    args.json.write_text(json.dumps({'source_run': str(SOURCE.relative_to(ROOT)),
                                    'source_changed': False, 'performance_measurement': False,
                                    'reference_validates': True, 'cases': results}, indent=2) + '\n')


if __name__ == '__main__':
    main()
