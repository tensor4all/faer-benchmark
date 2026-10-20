"""Declare exact development grids from the existing validated suite census; no timing."""
import csv
import hashlib
import itertools
import json
from collections import Counter
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
REFERENCE = ROOT / 'data/results/zen5-cpu/faer-kernels/20261018T022054Z-final-full-mkl'
FIELDS = ['regime', 'family', 'dtype', 'order', 'm', 'n', 'k', 'batch', 'row', 'threads', 'note', 'status']
SPECS = {
    'stage1': {
        'cholesky': ['32', '64', '96', '128', '256'],
        'gemm': ['32x32x32', '64x64x64', '96x96x96', '128x128x128'],
        'triangular_solve': ['32', '64', '128', '256'],
        'householder_apply': ['64', '1024x64', '4096x256'],
    },
    'stage2': {
        **{family: ['128', '256', '512', '1024x64', '64x1024']
           for family in ('lu', 'full_piv_lu', 'cholesky', 'triangular_solve', 'solve',
                          'qr_factor', 'qr', 'svd_values', 'svd_thin', 'eigh')},
        'eig': ['128', '256', '512'],
        'householder_apply': ['64', '512', '1024x64', '4096x256'],
        'upgrade_factor': ['64', '512', '1024x64', '4096x256'],
        'gemm': ['32x32x32', '64x64x64', '96x96x96', '128x128x128',
                 '192x192x192', '256x256x256', '512x512x512', '4096x64x64',
                 '16x4096x240', '4096x16x240', '64x64x4096'],
    },
}


def dimensions(shape):
    parts = shape.split('x')
    if len(parts) == 1:
        return parts[0], parts[0], ''
    if len(parts) == 2:
        return *parts, ''
    m, k, n = parts
    return m, n, k


def main():
    manifest = yaml.safe_load((REFERENCE / 'run.yaml').read_text())
    rows = []
    hashes = {}
    for filename in manifest['result_files']:
        if filename.startswith('run0-'):
            path = REFERENCE / filename
            hashes[filename] = hashlib.sha256(path.read_bytes()).hexdigest()
            with path.open() as stream:
                rows.extend(csv.DictReader(stream))
    result = {'reference': str(REFERENCE.relative_to(ROOT)), 'reference_sha256': hashes,
              'candidate': '7f713a1401f18546d1ef0c134df982be80626b2e',
              'base': 'b7715c5', 'measured': False, 'stages': {}}
    for stage, spec in SPECS.items():
        requested = {(family, *dimensions(shape), dtype, order, str(threads), engine)
                     for family, shapes in spec.items() for shape in shapes
                     for dtype, order, threads, engine in itertools.product(
                         ('f64', 'c64'), ('c', 'f'), (1, 4, 8),
                         ('faer-fork', 'faer-upstream', 'lapack-mkl'))}
        selected = [{key: row[key] for key in FIELDS} for row in rows
                    if tuple(row[key] for key in ('family', 'm', 'n', 'k', 'dtype',
                                                 'order', 'threads', 'row')) in requested]
        observed = {tuple(row[key] for key in ('family', 'm', 'n', 'k', 'dtype',
                                             'order', 'threads', 'row')) for row in selected}
        # Independent Cartesian axes, including skips: not an A/B intersection.
        if observed != requested:
            raise ValueError(f'{stage}: missing declared cases {requested - observed}')
        identities = [tuple(row[key] for key in FIELDS) for row in selected]
        if len(identities) != len(set(identities)):
            raise ValueError(f'{stage}: duplicate full identities')
        counts = Counter((row['row'], row['status']) for row in selected)
        expected_path = HERE / f'{stage}-grid.csv'
        with expected_path.open('w', newline='') as stream:
            writer = csv.DictWriter(stream, FIELDS, lineterminator='\n')
            writer.writeheader()
            writer.writerows(sorted(selected, key=lambda row: tuple(row[k] for k in FIELDS)))
        result['stages'][stage] = {'spec': spec, 'records_per_start': len(selected),
                                  'counts': {f'{engine}/{status}': count
                                             for (engine, status), count in sorted(counts.items())},
                                  'expected_csv': expected_path.name,
                                  'sha256': hashlib.sha256(expected_path.read_bytes()).hexdigest()}
        print(stage, len(selected), dict(counts))
    (HERE / 'grid.json').write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    main()
