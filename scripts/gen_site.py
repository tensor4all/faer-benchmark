#!/usr/bin/env python3
"""Write the site under `result/`: the landing page, the history, the charts and the joined view.

    python3 scripts/gen_site.py [--repo-ref main]

Nothing it writes is committed (see `.gitignore`); the Pages workflow runs it on every deploy from
the committed `data/`, `result/` and `pins/`. The landing page, the history, the HTML copy of every
result page and the charts declared in `benchmarks/campaign.yaml` (`figures:`, `trend:`) are the
toolkit's (`campaign_toolkit.site`). What is this campaign's own is the four-way view: the MKL and
OpenBLAS arms of the current `faer-kernels` pages joined on the cell key by `gen_comparison.py`,
written to `result/zen5-cpu/faer-kernels/<rev12>-comparison.html` and linked from the landing page.
"""
import argparse
import pathlib
import re
import sys

from campaign_toolkit import descriptor, gen_index, site

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import gen_comparison  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parents[1]
PIN = 'pins/t4a-faer.rev'
SUITE = 'faer-kernels'


def current_arms():
    """{vendor: run dir} of the current `faer-kernels` pages (the index's own rule), and the newest
    MKL run of an earlier revision, which states the unchanged row's control."""
    descriptor.set_root(ROOT)
    found = gen_index.collect()
    current, history = gen_index.split_pages(found['pages'], found['declared'], found['resolved'])
    pages = {c['vendor']: c['page'] for c in current if c['suite'] == SUITE and c['page'] is not None}
    arms = {vendor: page['run_dir'] for vendor, page in pages.items()}
    revision = pages['mkl']['commit'] if 'mkl' in pages else None
    # history is newest first; the control is the newest MKL arm of another revision
    earlier = [r for r in history if r['suite'] == SUITE and r['vendor'] == 'mkl' and r['commit'] != revision]
    control = earlier[0]['run_dir'] if earlier else None
    return arms, control


def write_comparison():
    """Write the four-way view of the current pages; returns its path, or None without both arms."""
    arms, control = current_arms()
    if 'mkl' not in arms or 'openblas' not in arms:
        return None
    rev = site._pin_revisions(ROOT, [PIN])[0][:12]
    out = ROOT / 'result' / 'zen5-cpu' / SUITE / f'{rev}-comparison.html'
    argv = ['--mkl', str(arms['mkl']), '--openblas', str(arms['openblas']), '--out', str(out)]
    if control is not None:
        argv += ['--control-mkl', str(control)]
    gen_comparison.main(argv)
    return out


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo-ref', default='main', help='the branch the site is published from')
    args = ap.parse_args(argv)
    index = ROOT / 'result' / 'index.html'
    comparison = write_comparison()
    extra = ''
    if comparison is not None:
        cells = len(re.findall(r'<tr><td class="k">', comparison.read_text()))
        rel = comparison.relative_to(index.parent)
        extra = ('<h2>The four-way view</h2>\n'
                 f'<p><a href="{rel}">The same recording against upstream, OpenBLAS and MKL in one '
                 f'table ({cells} cells)</a>, with the unchanged row\'s control in its header.</p>')
    site.write_site(index.parent, pins=[PIN], repo_ref=args.repo_ref, title='faer benchmark results',
                    intro=('The results at the pinned fork revision, one section per hardware profile: '
                           'each page as HTML, the joined four-way view of the recording, and the '
                           'charts drawn from the same runs.'),
                    extra_html=extra, root=ROOT)
    return 0


if __name__ == '__main__':
    sys.exit(main())
