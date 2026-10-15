# v2 representative controls — what they measured (attempt 3, completed)

Driver `run.py` (sha256 in `metadata.json`), observer pinned to CPUs 0-3, guard
policy `retries=8 wait=30s idle_window=3s max_busy=0.05`. All 64 declared
processes completed with exit 0; four process attempts were discarded by the idle
guard and re-run on the same schedule (guard logs record each attempt). 528 timed
rows, 172 cells, 15,480 chronological samples, all evidence validated by the
common v2 validator. Raw input: `metadata.json`, `*/*t/control-contract.yaml`,
`*/*t/*.csv`, `within-process.csv`, `between-process.csv`, `position-analysis.txt`.

These are **baseline-vs-baseline** controls (clean fork `bfe4041`, upstream
`0539947`, one vendor arm per binary). No optimized candidate was measured. The
fork is not upstream-equivalent: it carries 2233 insertions / 188 deletions over
30 files, including its own QR/LU/EVD work, so a fork-vs-upstream difference is a
real code difference, not an artifact.

## 1. Within-process noise is small

Median over cells of the within-process relative sample SD: **1.47%**. The three
engine rows of a cell are measured back-to-back inside one process, so this is the
repeatability of a single row.

## 2. Process-level level shifts are the dominant absolute uncertainty

Of 172 cells, **50 (29%)** have a relative process-median range above 5%; the
median cell is 1.5%, and the worst cells reach 74% (`mkl/4T lu 256² c64`),
66% (`mkl/4T solve 256² f64`), 40% (`openblas/8T cholesky 512² c64`). In those
cells all engine rows move together: e.g. `mkl/4T lu 256² f` has fork medians
1.224 / 1.208 / 2.115 ms across the three processes while the upstream/fork ratio
stays 0.738 / 0.752 / 0.709. So the *level* is unstable between process starts,
while the *comparison inside a process* is not.

This reproduces, under the declared v2 contract, the same kind of ~1.4× shift that
the earlier investigation could not explain. It is now located at the process
level, with the mechanism still unestablished (frequency/thermal state, allocation
and page state, SMT neighbours, and scheduler placement are all untested here).

## 3. A row-position effect exists and the rotation cancels it

Within a process the rows are measured in a rotated order. Estimating the
per-position effect from the balanced 3×3 design (`position-analysis.txt`) gives a
median position-effect range of **1.4%**, with 17 of 60 ratio-bearing cells above
5% and a worst case of **21%** (`mkl/8T cholesky 512² c64`, where the first-measured
row is ~40% slower than the same row in the other two processes).

Because each engine occupies each position exactly once across the three process
starts, the mean of the per-process log-ratios cancels an arbitrary position
effect, while the naive ratio of per-engine median-of-process-medians does not:
17 engine comparisons differ between the two by more than 5%. The declared 3-start
rotation is therefore not cosmetic; the position-balanced ratio is the defensible
comparison, and the absolute per-engine median must be reported with its
between-process spread.

## 4. Retained outliers and declared differences that are not artifacts

No sample was trimmed: e.g. `run1-qr-8t` upstream has 30 calls with median
16.61 ms and max 34.91 ms. Rotation-consistent large differences are real for
this pair of revisions, e.g. `qr`/`qr_factor` at `4096x256` f64 8T is 2.26× faster
on the fork in all three rotations, and `lapack-mkl` GEMM `16x240x4096` f64 4T is
~10× slower than either faer row in all three. Neither is a position effect, and
neither is a statement about the optimized candidate.

## 5. Measured cost of the declared control protocol

Timed wall time for 528 rows: **39.4 min** (48 timing processes, including guard
overhead of roughly 7 s per process), i.e. ~3.5-7.2 s per row depending on
family and budget, of which 3 s is priming. Priming is the floor: the full
declared suite has 3948 primed rows per set per vendor, so at 3 s/row the priming
alone is ~9.9 h per vendor and ~19.7 h for both, before measured calls, checks,
guard overhead, verification and build. The heavy suite cells (512³ GEMM and the
512² decompositions at 1T) are larger than every control cell, so the real total
is higher, not lower.

## What this does not establish

No causal mechanism for either shift; no provider equality or superiority; no
result for the saved optimization candidate; no validation of budgets that were
not used here. Attempts 1 and 2 are preserved under `attempt1-aborted-guard/` and
`attempt2-aborted-guard/` with their abort reasons; they were rejected by idle
admission, not compared for favourable numbers.
