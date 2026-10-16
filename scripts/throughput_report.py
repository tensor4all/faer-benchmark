#!/usr/bin/env python3
"""Write the throughput charts for a set of recorded runs.

    scripts/throughput_report.py --out <dir> <run-with-upstream> <run-with-the-other-vendor>

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
    ap.add_argument('run_dirs', nargs='+', type=pathlib.Path)
    ap.add_argument('--config', type=pathlib.Path, default=ROOT / 'benchmarks/throughput.yaml')
    ap.add_argument('--out', required=True, type=pathlib.Path)
    ap.add_argument('--dtype', default='f64')
    ap.add_argument('--order', default='c')
    args = ap.parse_args(argv)
    config = yaml.safe_load(args.config.read_text())
    written, dropped = throughput.write_report(args.run_dirs, config, args.out, dtype=args.dtype,
                                               order=args.order)
    print(f'wrote {len(written)} families to {args.out}: {", ".join(written)}')
    if dropped:
        print(f'dropped {len(dropped)} crowded tick labels: {", ".join(sorted(set(dropped))[:8])}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
