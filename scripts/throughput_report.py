#!/usr/bin/env python3
"""Write the throughput charts for a set of recorded runs.

    scripts/throughput_report.py --out <dir> --daily-mkl <run> --daily-openblas <run> \\
        [--large-mkl <run>] [--large-openblas <run>]

The four runs are the positions 0-3 the series in the config name (`run: [0, 2]` and `[1, 3]`).
A large-tier run that was not recorded at the pinned revision is simply left out: its series stops
at 768 and the page says so. The old positional form (`<run0> <run1> [<run2> [<run3>]]`) still works.

The nominal operation count per family, the series and the families come from
`benchmarks/throughput.yaml`; the charts are one SVG plus one markdown table of the plotted numbers
per family, written by the toolkit's `campaign_toolkit.throughput`.
"""
import argparse
import pathlib
import sys

import yaml

from campaign_toolkit import descriptor, throughput

ROOT = pathlib.Path(__file__).resolve().parents[1]


def main(argv=None):
    descriptor.set_root(ROOT)
    ap = argparse.ArgumentParser()
    ap.add_argument('run_dirs', nargs='*', type=pathlib.Path, help='positional runs 0-3 (legacy form)')
    for name in ('daily-mkl', 'daily-openblas', 'large-mkl', 'large-openblas'):
        ap.add_argument('--' + name, type=pathlib.Path)
    ap.add_argument('--config', type=pathlib.Path, default=ROOT / 'benchmarks/throughput.yaml')
    ap.add_argument('--out', required=True, type=pathlib.Path)
    ap.add_argument('--dtype', default='f64')
    ap.add_argument('--order', default='c')
    args = ap.parse_args(argv)
    named = [args.daily_mkl, args.daily_openblas, args.large_mkl, args.large_openblas]
    if args.run_dirs and any(named):
        ap.error('give the runs either positionally or by name, not both')
    run_dirs = list(args.run_dirs) if args.run_dirs else named
    if run_dirs[0] is None or (len(run_dirs) < 2 or run_dirs[1] is None):
        ap.error('the daily MKL and daily OpenBLAS runs are required')
    run_dirs += [None] * (4 - len(run_dirs))
    config = yaml.safe_load(args.config.read_text())
    written, dropped = throughput.write_report(run_dirs, config, args.out, dtype=args.dtype,
                                               order=args.order)
    print(f'wrote {len(written)} families to {args.out}: {", ".join(written)}')
    if dropped:
        print(f'dropped {len(dropped)} crowded tick labels: {", ".join(sorted(set(dropped))[:8])}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
