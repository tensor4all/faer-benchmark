"""Audit the frozen stage1 census; describe results without overriding the CLI gate."""
import collections
import csv
import hashlib
import json
import pathlib

import yaml
from campaign_toolkit import candidate

ROOT = pathlib.Path(__file__).resolve().parents[3]
HERE = pathlib.Path(__file__).resolve().parent
FIELDS = ('regime', 'family', 'dtype', 'order', 'm', 'n', 'k', 'batch',
          'row', 'threads', 'note', 'status')


def main():
    with (HERE / 'stage1-grid.csv').open() as stream:
        expected = collections.Counter(tuple(r[k] for k in FIELDS) for r in csv.DictReader(stream))
    commands = json.loads((HERE / 'commands.json').read_text())
    runs, identities, rows_by_side = {}, {}, {}
    for side in ('A', 'B'):
        manifests = {}
        for entry in commands['stages']['stage1']:
            label = entry['label_template'].format(side=side)
            matches = list((ROOT / 'data/results/zen5-cpu/faer-kernels').glob('*-' + label))
            assert len(matches) == 1, (side, label, matches)
            directory = matches[0]
            manifests[entry['group']] = (directory, yaml.safe_load((directory / 'run.yaml').read_text()))
        runs[side] = manifests
        for repeat in range(3):
            actual = collections.Counter()
            for directory, manifest in manifests.values():
                assert manifest['run_spec']['aa'] == 3
                for name in manifest['result_files']:
                    if not name.startswith(f'run{repeat}-'):
                        continue
                    with (directory / name).open() as stream:
                        for row in csv.DictReader(stream):
                            actual[tuple(row[k] for k in FIELDS)] += 1
                            assert row['rayon_threads'] == row['threads']
                            assert row['vendor_threads'] == row['threads']
                            if row['status'] == 'ok':
                                assert len(json.loads(row['samples_ms'])) == 5
            assert actual == expected, (side, repeat, actual - expected, expected - actual)
        hashes = set()
        for _, manifest in manifests.values():
            assert manifest['library']['commit'].startswith(commands['sides'][side])
            assert not manifest['library']['dirty']
            assert not manifest['harness']['dirty'] and not manifest['toolkit']['dirty']
            binary = manifest['binary']
            assert hashlib.sha256(pathlib.Path(binary['path']).read_bytes()).hexdigest() == binary['sha256']
            hashes.add(binary['sha256'])
            identity = {k: manifest[k]['commit'] for k in ('library', 'upstream', 'harness', 'toolkit')}
            assert identities.setdefault(side, identity) == identity
        assert len(hashes) == 1
        rows_by_side[side] = {'records_per_start': sum(expected.values()),
                              'starts': 3, 'binary_sha256': hashes.pop()}
    comparisons = {}
    for group in runs['A']:
        a, b = runs['A'][group][0], runs['B'][group][0]
        ok, controls = candidate.control_check(a, b, 'faer-upstream')
        fork = candidate.fork_comparison(a, b, 'faer-fork')
        baseline = candidate.series(a, 'faer-fork', 5)
        # A diagnostic guard listing, not a new acceptance rule. Keep both median
        # range and rotation ratios; a failed control still vetoes the experiment.
        slower = [r for r in fork if r['candidate_fork_ms'] > max(baseline[r['cell']].values()) * 1.05]
        comparisons[group] = {'control_ok': ok, 'controls': controls,
                              'descriptive_fork': fork, 'above_baseline_max_plus5': slower}
    all_controls = all(c['control_ok'] for c in comparisons.values())
    result = {'identities': identities, 'census': rows_by_side, 'comparisons': comparisons,
              'all_controls_reproduce': all_controls,
              'outcome': 'INCONCLUSIVE / NOT ADOPTED' if not all_controls else 'requires target/guard decision',
              'stage2_run': False, 'adoption': False,
              'caveat': 'All timed samples, starts, skipped identities and variants retained; descriptive fork rows do not override control failures.'}
    (HERE / 'runtime-stage1/outcome.json').write_text(json.dumps(result, indent=2) + '\n')
    for group, data in comparisons.items():
        failed = sum(c['outside_baseline_range'] for c in data['controls'])
        print(group, 'controls', len(data['controls']), 'failed', failed,
              'fork cells', len(data['descriptive_fork']),
              'median above baseline-max+5%', len(data['above_baseline_max_plus5']))
        for row in data['above_baseline_max_plus5']:
            print('  descriptive guard', row)
    print(result['outcome'], 'stage2 not run; adoption false')


if __name__ == '__main__':
    main()
