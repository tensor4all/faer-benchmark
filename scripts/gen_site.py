#!/usr/bin/env python3
"""Write `result/index.html`: the landing page of the latest generation. See `campaign_toolkit.site`.

    python3 scripts/gen_site.py [--repo-ref main]

The page is generated, not committed (`result/index.html` is git-ignored): the Pages workflow
runs this on every deploy from the committed `result/` and `pins/`. It links the pages at the
pinned fork revision, the joined four-way comparison of that revision
(`result/zen5-cpu/faer-kernels/<rev12>-comparison.html`, written by `gen_comparison.py`) and the
throughput charts. The charts are committed outputs of `throughput_report.py`, which needs the
recorded run directories; the workflow does not regenerate them.
"""
import argparse
import pathlib
import re
import sys

from campaign_toolkit import site

ROOT = pathlib.Path(__file__).resolve().parents[1]
PIN = 'pins/t4a-faer.rev'


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo-ref', default='main', help='the branch the site is published from')
    args = ap.parse_args(argv)
    index = ROOT / 'result' / 'index.html'
    rev = site._pin_revisions(ROOT, [PIN])[0][:12]
    comparison = ROOT / 'result' / 'zen5-cpu' / 'faer-kernels' / f'{rev}-comparison.html'
    extra = ''
    if comparison.exists():
        cells = len(re.findall(r'<tr><td class="k">', comparison.read_text()))
        rel = comparison.relative_to(index.parent)
        extra = ('<h2>The four-way view</h2>\n'
                 f'<p><a href="{rel}">The same recording against upstream, OpenBLAS and MKL in one '
                 f'table ({cells} cells)</a>, with the unchanged row\'s control in its header.</p>')
    site.write_site(index.parent, pins=[PIN], repo_ref=args.repo_ref, title='faer benchmark results',
                    intro=('The latest generation of results: for each suite and vendor arm, the '
                           'page recorded at the pinned fork revision, the joined four-way view '
                           'of that recording and its throughput charts.'),
                    extra_html=extra, root=ROOT)
    return 0


if __name__ == '__main__':
    sys.exit(main())
