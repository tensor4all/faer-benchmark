#!/usr/bin/env python3
"""Compare a candidate run against a recorded baseline run (candidate mode).

    scripts/candidate_compare.py --baseline <run dir> --candidate <run dir> \
        [--control-engine faer-upstream] [--fork-engine faer-fork] [--cells a,b] [--json out]

Refuses the comparison - exit 1 - when the machine, the declaration or the harness/toolkit identity
changed, or when the in-run control row no longer reproduces the baseline within the spread the
baseline recorded. The cell list is the caller's declared subset; nothing is inferred for cells that
were not measured in both runs.
"""
import argparse
import json
import pathlib
import subprocess
import sys

import yaml

from campaign_toolkit import candidate, descriptor

ROOT = pathlib.Path(__file__).resolve().parents[1]
# The paths whose content decides what a measurement means: changing one of them invalidates the
# cells that depend on it, and a merge that leaves them alone keeps the measurement valid.
MEASURED_PATHS = ('faer/src', 'faer/Cargo.toml', 'faer-traits/src', 'faer-traits/Cargo.toml',
                  'Cargo.lock')


def git(path, *args):
    return subprocess.run(['git', '-C', str(path), *args], check=True, capture_output=True,
                          text=True).stdout.strip()


def main(argv=None):
    descriptor.set_root(ROOT)
    ap = argparse.ArgumentParser()
    ap.add_argument('--baseline', required=True, type=pathlib.Path)
    ap.add_argument('--candidate', required=True, type=pathlib.Path)
    ap.add_argument('--control-engine', default='faer-upstream')
    ap.add_argument('--fork-engine', default='faer-fork')
    ap.add_argument('--cells', default=None, help='comma separated substrings of the declared subset')
    ap.add_argument('--json', type=pathlib.Path, default=None)
    ap.add_argument('--checkout', type=pathlib.Path, default=ROOT / 'extern/t4a-faer',
                    help='the checkout that carries both the measured and the merged revision')
    ap.add_argument('--merged-commit', default=None,
                    help='the revision the candidate was merged into; the comparison is refused when '
                         'the merge changed any measured path, so the measurement cannot silently '
                         'describe different code than the branch that was measured')
    args = ap.parse_args(argv)

    measured = yaml.safe_load((args.candidate / 'run.yaml').read_text())['library']['commit']
    merged = args.merged_commit or measured
    changed = candidate.same_measured_code(args.checkout, measured, merged, MEASURED_PATHS, git=git)
    if changed:
        print(f'refused: the merged revision {merged[:12]} does not carry the measured code:',
              '; '.join(changed))
        return 1
    print(f'measured revision {measured[:12]} and merged revision {merged[:12]} carry identical '
          f'measured paths')
    differences = candidate.identity_differences(args.baseline, args.candidate)
    if differences:
        for line in differences:
            print(f'refused: {line}')
        return 1
    cells = args.cells.split(',') if args.cells else None
    ok, controls = candidate.control_check(args.baseline, args.candidate, args.control_engine, cells)
    print(f'{args.control_engine} control over {len(controls)} cells: '
          f'{"reproduces the baseline" if ok else "does NOT reproduce the baseline"}')
    if not ok:
        for row in controls:
            if row['outside_baseline_range']:
                print(f"  {row['cell']}: baseline {row['baseline_ms']:.6g} "
                      f"(range {row['baseline_range_ms'][0]:.6g}-{row['baseline_range_ms'][1]:.6g}) "
                      f"candidate {row['candidate_ms']:.6g}")
        print('refused: the machine is not in the baseline state')
        return 1
    rows = candidate.fork_comparison(args.baseline, args.candidate, args.fork_engine, cells)
    better = [r for r in rows if r['rotation_averaged_ratio'] < 0.95]
    worse = [r for r in rows if r['rotation_averaged_ratio'] > 1.05]
    print(f'{args.fork_engine}: {len(rows)} cells compared, faster {len(better)}, slower {len(worse)} '
          f'(beyond 5%; the rest is inside the recorded spread)')
    for row in sorted(rows, key=lambda r: r['rotation_averaged_ratio'])[:5]:
        print(f"  {row['cell']}: {row['rotation_averaged_ratio']:.3f} "
              f"({row['baseline_fork_ms']:.6g} -> {row['candidate_fork_ms']:.6g} ms)")
    if args.json:
        args.json.write_text(json.dumps({'identity_differences': differences, 'controls': controls,
                                         'fork': rows}, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())
