# Observer-pin effect on one representative cell (diagnostic, 2026-10-15)

Question: does pinning the observing side (harness/agent, recorder, guard checker)
off the measured L3 domain change the timing distribution of a cell?

Cell: `lu` 256x256, c64, 4T on the declared CPU set `4-7`, which lies in a single
L3 domain. Three process starts per condition, 30 chronological calls each,
3000 ms priming per row, row rotations 0/1/2, both memory orders measured by the
same process. Observing side pinned to the **derived** complement of the measured
L3 domain (`0-3,12-15` on this host) versus unpinned. Order of runs:
pinned-0, unpinned-0, pinned-1, unpinned-1, pinned-2, unpinned-2.

Artifacts: `probe.py` (the driver, derives the observer set from sysfs, no
hardcoded CPU list), six `*.json` / `*.csv` / `*.guard` triples.

| condition | row | process medians (ms) | range | median within-process rel. SD |
| --- | --- | --- | --- | --- |
| pinned | `f/faer-fork` | 1.2235 / 1.2144 / 1.5002 | 23.4% | 8.33% |
| pinned | `f/faer-upstream` | 0.9032 / 0.9005 / 1.2384 | 37.4% | 1.54% |
| pinned | `f/lapack-mkl` | 0.5835 / 0.6050 / 0.5813 | 4.1% | 0.43% |
| unpinned | `f/faer-fork` | 1.2139 / 1.2139 / 1.5065 | 24.1% | 7.72% |
| unpinned | `f/faer-upstream` | 0.9086 / 0.9055 / 1.2436 | 37.2% | 1.44% |
| unpinned | `f/lapack-mkl` | 0.6092 / 0.6067 / 0.5834 | 4.3% | 0.68% |

## Result

The two conditions are indistinguishable on this cell. The same rotation-2 process
is slower by the same amount in both (fork +23.4% pinned vs +24.1% unpinned;
upstream +37.4% vs +37.2%), the vendor row moves 4.1% vs 4.3%, and the median
within-process relative SD is 8.3% / 1.5% / 0.4% pinned versus 7.7% / 1.4% / 0.7%
unpinned. All six guard windows were idle on attempt 1 in both conditions
(`pinned.sh: cpus 4-7 idle before and after (attempt 1)`).

So on this cell the pin does **not** improve the measured distribution. It removes
one known source of guard rejections and makes the "keep unrelated work off the
measured cores" precondition enforceable and recorded. The fork row's larger
within-process SD (7.7-8.3%) comes from a single slow call inside the first
measured row (min ~1.204 ms, max ~2.04 ms), consistent with the row-position
effect seen in the larger controls.

Also kept here (host diagnostics used for the pinning decision):
`idle-diagnostic.py` (guard windows on an idle host),
`guard-repro.py`, `guard-attribute.py` (which process consumes the watched cores).

## What this does not establish

No mechanism for the rotation-2 shift; no claim about other cells or budgets; no
provider comparison; no evidence that pinning changes absolute performance; and
six clean windows are not a rejection-rate measurement.
