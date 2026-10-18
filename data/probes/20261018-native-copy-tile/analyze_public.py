"""Describe all public-copy cells only after a COMPLETE diagnostic; never adopt."""
import collections
import json
import statistics

import record_public as run


def summarize(directory):
    complete = json.loads((directory / 'complete.json').read_text())
    assert complete == {'processes': 8, 'accepted_rows': 512, 'diagnostic_only': True, 'adoption': False}
    identity = json.loads((directory / 'identity.json').read_text())
    source_ids = identity['initial']['sources']
    expected_dirs = {f'block{block}-{side}' for block, side in enumerate(run.SEQUENCE)}
    assert {p.name for p in directory.glob('block*-*')} == expected_dirs
    cells = collections.defaultdict(lambda: {'A': [], 'B': []})
    inputs = {}
    for block, side in enumerate(run.SEQUENCE):
        process = directory / f'block{block}-{side}'
        assert json.loads((process / 'terminal.json').read_text()) == {'kind': 'exit', 'returncode': 0}
        assert json.loads((process / 'errors.json').read_text()) == []
        for stage in ('before', 'after'):
            assert json.loads((process / f'{stage}.json').read_text())['sources'] == source_ids
        path = process / 'result.csv'
        inputs[str(path)] = run.digest(path)
        for row in run.audit(path):
            key = tuple(row[k] for k in run.FIELDS)
            cells[key][side].append({'block': block, 'total_ms': float(row['total_ms']),
                                     'samples_ms': json.loads(row['samples_ms'])})
    assert len(cells) == 64
    results = []
    for key, sides in sorted(cells.items()):
        assert len(sides['A']) == len(sides['B']) == 4
        medians = {side: statistics.median(r['total_ms'] for r in records) for side, records in sides.items()}
        a = [r['total_ms'] for r in sides['A']]
        target = key[2] == 'c' and key[5] == 'to_owned'
        results.append({'identity': dict(zip(run.FIELDS, key, strict=True)), 'target': target,
                        'starts': sides, 'median_of_start_medians_ms': medians,
                        'ratio_B_A': medians['B'] / medians['A'],
                        'B_median_outside_A_range_plusminus5pct': not min(a) * .95 <= medians['B'] <= max(a) * 1.05})
    assert sum(r['target'] for r in results) == 16
    assert sum(len(start['samples_ms']) for r in results for records in r['starts'].values() for start in records) == 2560
    return {'diagnostic_only': True, 'adoption': False, 'inputs_sha256': inputs, 'recording_identity': identity,
            'cells': results, 'targets': 16, 'unchanged_controls': 48,
            'control_flags': [r['identity'] for r in results if not r['target'] and r['B_median_outside_A_range_plusminus5pct']],
            'limits': 'All64cells/all4starts/all5samples. Four-start descriptive range flags only: not formalAA3, '
                      'pvalues, causal attribution, adoption, control waiver or substituted final campaign.'}


if __name__ == '__main__':
    output = run.HERE / 'public-outcome.json'
    assert not output.exists(), 'do not overwrite analysis'
    result = summarize(run.HERE / 'runtime-public')
    run.dump(output, result)
    print('diagnostic only:', len(result['cells']), 'cells;', len(result['control_flags']), 'unchanged-control flags; not adoption')
