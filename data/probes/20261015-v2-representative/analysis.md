# v2 representative controls — what they measured (attempt 3, completed)

Driver `run.py` (sha256 in `metadata.json`), observer launched pinned to CPUs 0-3,
guard policy as recorded in `metadata.json.pin_policy` (`retries=8`, `wait=30s`,
`idle_window=3s`, `max_busy=0.05`) and echoed in the first line of every `*.guard`
file. All 64 declared processes completed with exit 0; four process attempts were
discarded by the idle guard and re-run on the same schedule. 528 timed rows,
172 cells, 15,480 chronological samples, all evidence validated by the common v2
validator. Raw input: `metadata.json`, `*/*t/control-contract.yaml`, `*/*t/*.csv`,
`within-process.csv`, `between-process.csv`, `position-analysis.txt`.

**Caveat on the contracts:** each `control-contract.yaml` still carries
`guards.attempts: 1` inherited from the smoke manifest it was copied from, and the
generated `report.md` repeats that field. That was **not** the policy in force:
the driver sets the environment, and `metadata.json.pin_policy` plus the guard
logs are the record. The production recorder's default is three attempts, not
eight; eight was a control-specific override.

These are **baseline-vs-baseline** controls (clean fork `bfe4041`, upstream
`0539947`, one vendor arm per binary). No optimized candidate was measured. The
fork is not upstream-equivalent: 2233 insertions / 188 deletions over 30 files,
including its own QR/LU/EVD work, so a fork-vs-upstream difference can be a real
code difference; that does not by itself prove any particular difference is
algorithmic rather than schedule- or build-related.

## 1. Within-process noise is small

Median over cells of the within-process relative sample SD: **1.47%**. The three
engine rows of a cell are measured back-to-back inside one process, so this is the
repeatability of a single row.

## 2. Between scheduled process starts, level variation is large

Of 172 cells, **50 (29%)** have a relative range of their three process medians
above 5%; the median cell is 1.5%, and the worst is **74%**
(`mkl/4T c64 lu 256x256` F-order: 1.224 / 1.208 / 2.115 ms).

This is *scheduled between-process variation*: each process start changes both the
process state and the row order, so this count does not isolate a pure
"process-level" shift. In some cells the movement is shared across engines
(`mkl/4T c64 lu` F-order: fork 1.224→2.115 ms, upstream 0.903→1.499 ms) while in
others it is not (`lapack-mkl` there moves 0.583→0.663 ms only; `openblas/4T
gemm 16x240x4096` moves the vendor row while both faer rows stay put). Absolute ms
values across process starts are therefore not comparable at the percent level,
and the direction of the shift is not known.

This is the same kind of ~1.4× shift the earlier investigation could not explain.
It is located at the level of scheduled process starts; the mechanism
(frequency/thermal state, allocation or page state, SMT neighbours, scheduler
placement) remains unestablished.

## 3. A row-position effect exists; the rotation cancels it only under a model

The per-position effect is estimable only where every declared engine has a
successful row (a real 3x3 Latin square). That is 52 of the 60 ratio-bearing
cells. There the median position effect is **1.010 (1.0%)**, 10 cells exceed 1.05,
and the worst is **1.486 (~49%)**: `openblas/8T f64 cholesky 512x512` C-order,
followed by `mkl/8T f64 cholesky 512x512` C-order at 1.239.

In 8 cells an engine has **no row at all** (the vendor skips `full_piv_lu`,
square `triangular_solve`, and Householder). A skipped record keeps an emission
position but no measured work happens there, so the remaining engines are *not* a
Latin square: for two measured engines the first one is measured first in two of
the three starts. Those cells are marked `no` in `position-analysis.txt`; their
averaged ratio is **not position-balanced** and no position effect is estimated
from them.

Even in balanced cells, the averaged log-ratio cancels a position effect only
under the model `log m[e,r] = alpha_e + beta_r + gamma_position(e,r)` — one
position effect shared by all engines and stable across process starts. Engine x
position interactions, predecessor effects and process x position interactions are
not cancelled. The Cholesky cells above show why that qualification matters: the
vendor row, first in one rotation, does not show the same penalty the faer rows
show when they are first. The per-rotation ratios are printed next to the average
for exactly this reason, and **17 comparisons** differ between the
rotation-averaged ratio and the naive ratio of per-engine median-of-three medians
by more than 5%.

## 4. Retained outliers and rotation-consistent differences

No sample was trimmed: e.g. `run1-qr-8t` upstream has 30 calls with median
16.61 ms and max 34.91 ms. Differences that repeat in all three rotations are not
position artifacts, e.g. F-order `qr_factor` `4096x256` f64 8T is 2.26× slower on
upstream than on the fork (per-rotation 2.243 / 2.275 / 2.258; the explicit-Q `qr`
ratio there is 1.80), and `lapack-mkl` GEMM `16x240x4096` c64 4T is ~10× slower
than either faer row. Neither is a statement about the optimized candidate.

## 5. Measured cost of the declared control protocol

Timed wall time for 528 rows: **39.4 min** (48 timing processes, including guard
overhead of roughly 7 s per process), i.e. ~3.5-7.2 s per row depending on family
and budget, of which 3 s is priming.

Full declared suite accounting per set per vendor (derived from the declared grid
and the harness's variant expansion): **5,148 base engine-cells**; of those 3,756
are successful base cells, plus **192 Householder variant rows**, giving **3,948
primed rows**, **1,392 declared skips**, and **5,340 emitted CSV rows**. At 3 s of
priming per primed row and three sets, the priming floor alone is 9.87 h per
vendor and **19.7 h for both**, before measured calls, checks, guard overhead,
30 verification processes per vendor and two builds. The heaviest suite cells
(512³ GEMM and the 512² decompositions at 1T) are larger than every control cell,
so the real total is higher, not lower.

## What this does not establish

No causal mechanism for either the position effect or the between-process
variation; no provider equality or superiority; no result for the saved
optimization candidate; no validation of budgets that were not used here; and no
universal position cancellation. Attempts 1 and 2 are preserved under
`attempt1-aborted-guard/` and `attempt2-aborted-guard/` with their abort reasons;
they were rejected by idle admission, not compared for favourable numbers.
