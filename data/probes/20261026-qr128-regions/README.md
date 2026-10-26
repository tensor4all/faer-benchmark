# QR 128 on a team, and the gates of the join regions (2026-10-26)

Rough M5 evidence for tensor4all/faer PR #61 (`exp/par-team-lifetime`) and faer-benchmark#24. One shared
laptop (Apple M5 Max, 6 threads, QoS `UserInitiated`) with the desktop session running; it decides nothing,
acceptance is on a quiet Linux host. Revisions: before `6788b20`, after `7b60550` (`9cd64f0` for the QR
comparison with the earlier gates). Host protocol of every process: `guarded.py` waits until idle is at least
85 percent and no other cargo, rustc, fbench or test process runs (here at most 40 s, then the process runs
and is marked busy), records idle, load and the top 3 consumers before and after in `processes.log`, and marks
`busy` when idle was below 85 percent before or after. `*` in a table marks a cell with a busy process (the
host was busy for most of the session, 48 of 221 logged processes). Warm-up: 250 ms priming per cell, 40 ms
before every timed window, serial and parallel windows interleaved in one process.

## Task A: why QR 128 on a team went from 86 us to 102 us

Serial QR 128 is 121 to 128 us. Team of 6, microseconds:

| build | QR 128, team of 6 | source |
| --- | --- | --- |
| `9cd64f0` (old gates) | 87.1, 87.4, 89.3, 91.3, 94.5 | `raw/qr-old-*`, `raw/qr-old9cd-*` |
| `6788b20` (rule, GEMM rate) | 102.5 (median of 8 passes), 105.5 in one process | `raw/tbl-before-qr-128-*`, `raw/modes-128.csv` |
| `7b60550` (rule, GEMM work plus streaming term) | 98.9 (2 passes), 96.0 (3 passes of the previous commit), 99.8 in one process | `raw/tbl-after-qr-128-*`, `raw/modes-128-final.csv` |

### Every parallel region of QR 128 (`raw/trace-128.csv`, feature `par-trace`)

One factorization (block size 8, sub block 4) asks 512 gate decisions on a team of 6 (86 of them after an
already sequential token, 426 with the team). The records (site, dimensions, units, sections, estimate,
dispatch cost, decision) come from the `par-trace` feature of the fork (`utils::cost::trace`). The old decision
of each record is recomputed from its dimensions with the old formula.

| gate | decisions | parallel under `9cd64f0` | parallel under `6788b20` | now |
| --- | --- | --- | --- | --- |
| `upgrade_householder_factor` (reduction `deep_rows * n * n`) | 83 | 0 (`8192` floor) | 0 (largest estimate 0.28 us) | 0 |
| block apply row split | 37 | 0 | 0 (shape: `M >= 2K` fails for the square part) | 0 |
| block apply rank one (`N == 1`) | 59 | not reached (`N >= 2` in every call) | not reached | not reached |
| triangular product and solve joins | 170 | 0 | 0 (largest estimate 0.14 us) | 0 |
| **block apply column split** (`n_tasks`) | 59 | **10** (`M*K*4M >= 589824`, `M` 56 to 128) | **5** (`M` 96 to 128) | **7** (`M` 80 to 128) |

Only the column split of the block apply changed its decision between the two builds. Its regions
(`M x N x K = M x 8 x (M-8)`, `raw/apply-a9813bf.csv`, `regions.md`; one apply timed with the target copy
subtracted, serial against the team forced parallel, medians of 21 or more repetitions):

| M x N x K | serial us | team us | gain us | `9cd64f0` | `6788b20` estimate us | `6788b20` | now estimate us | now | estimate / serial now |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 48 x 8 x 40 | 2.08 | 1.38 | +0.71 | serial | 1.12 | serial | 1.54 | serial | 0.74 |
| 56 x 8 x 48 | 2.54 | 1.46 | +1.08 | parallel | 1.57 | serial | 2.16 | serial | 0.85 |
| 64 x 8 x 56 | 3.04 | 2.12 | +0.92 | parallel | 2.09 | serial | 2.88 | serial | 0.95 |
| 72 x 8 x 64 | 4.04 | 2.00 | +2.04 | parallel | 2.68 | serial | 3.71 | serial | 0.92 |
| 80 x 8 x 72 | 4.67 | 2.25 | +2.42 | parallel | 3.35 | serial | 4.63 | parallel | 0.99 |
| 88 x 8 x 80 | 5.75 | 2.33 | +3.42 | parallel | 4.10 | serial | 5.66 | parallel | 0.98 |
| 96 x 8 x 88 | 6.92 | 2.67 | +4.25 | parallel | 4.92 | parallel | 6.79 | parallel | 0.98 |
| 128 x 8 x 120 | 11.75 | 3.79 | +7.96 | parallel | 8.95 | parallel | 12.35 | parallel | 1.05 |

(`regions.md` has all rows.) The floor of the rule on a team of 6 is `3 * 1.4 = 4.2 us` of estimated serial time.

### Findings

1. **The estimate was wrong.** `2 * M * N * K` multiply-adds at the GEMM rate (0.0364 ns) was 0.58 to 0.77 of the
   measured serial time of an `N = 8` block between `M = 56` and 88. The apply streams its `M x K` target
   (temporaries, triangular steps) besides the products. A fit over the 40 shapes of `raw/applyrate.csv` and
   `raw/apply.csv` (`M` 24 to 512, `N` 2 to 32, f64 and c64) is `t = 2MNK * GEMM rate + M*K * 0.236 ns` (f64)
   and `+ M*K * 0.538 ns` (c64) with median errors of 7 and 4 percent, and the streaming rate is the rank one
   Householder apply rate already in `utils::cost::rate` (0.212 and 0.725). The gate now uses
   `block_apply_estimate` (GEMM term plus streaming term, no new constant); the estimate is 0.85 to 1.05 of
   the measured time from `M = 56`. A first attempt with one flat rate per multiply-add (0.054) fitted `M = 56
   to 128` but over estimated the wide bases of QR 256 (0.036 to 0.043 measured); QR 256 got 8 to 12 percent
   slower, which is how the two term form was found (`raw/superseded-801d781/`).
2. **`sections` is right.** The column split is one `for_each_with_par` over `n_tasks` parts, one dispatch.
3. **The old parallel decisions at `M` 56 to 72 were not luck.** Forced parallel wins there by 1.1, 0.9 and
   2.0 us per call (4.0 us in all, the 3.7 us difference between the rule and the previous rule in one
   process: `raw/modes-128-a9813bf.csv` team 100.5, previous gate 96.8, no column split 131.6, serial
   125.0). They stay serial because their estimates (2.2, 2.9, 3.7 us) are below `PAYS * dispatch = 4.2 us`, the
   break-even is about `1.2 * dispatch` for a width 6 section. That is the margin of `PAYS = 3` and the rule is
   kept. After the correction the rule loses 4 us of 100 at QR 128; the remaining distance to the 87 to 94 us
   of `9cd64f0` is these regions (4 us) plus 2 to 4 us not isolated (the gate calls themselves cost 0.7 us per
   factorization serial: 124.3 against 123.5 us, `par_pays` and `region_pays` now return false for a
   sequential token before computing an estimate).
4. **Width of a join is 2.** Found on the way (triangular inverse at 128 on a team): a 64 x 64 triangular
   product is 7.0 us serial and 8.1 us on the team at an estimate of 4.8 us, 72 x 72 is 11.8 against 16.7
   (`raw/trimm.csv`); the products only win from 80 (14.4 against 13.2) and clearly from 96. A join splits
   the budget in two halves, one section of width 2 at 3.0 us on the team table, not the full degree cost
   1.4 us. `utils::cost::join_pays` decides every join at width 2, including the existing triangular
   product and solve joins.

## Task B: the regions that had no gate

| region | sections | estimate | constant (f64, c64 ns) | measured by |
| --- | --- | --- | --- | --- |
| `bidiag_svd` recursion join | 1, width 2 | `2 (n/2)^2` | 53 per `m^2` (real types only) | `consts/bsvd*.csv` |
| `bidiag_svd` merge products (`update_v`, `update_u`, the join of both) | 1 each, width 2 | `(k^2+rem^2) n`, `((k+1)^2+(rem+1)^2)(n+1)`, their sum, multiply-adds | GEMM rate | |
| `tridiag_evd` recursion join | 1, width 2 | `2 (n/2)^2` | 31 per `m^2` (real) | `consts/tevd*.csv` |
| `tridiag_evd` merge products | 1, width 2 | `(n1^2 + (n-n1)^2) n` multiply-adds | GEMM rate | |
| triangular inverse join (lower, unit lower) | 1, width 2 | `2 (n/2)^3` | 0.0096, 0.0344 per `m^3` | `consts/tinv2.csv` |
| sparse by sparse numeric product | 1, width = degree | symbolic flop count of `SparseMatMulInfo` | 1.5, 1.8 per multiply-add | `consts/spmm.csv` |
| norm reductions, `zip`, elementwise kernels | none | | | no parallel region exists |

Recurrence for the divide and conquer joins: the work of the join at size `n` is the two subproblems it
runs, `2 W(n/2)`, with `W(m)` the serial time of a whole solve of size `m` measured at one thread (both
vectors, Gaussian bidiagonal and tridiagonal data so that nothing deflates). `W` is not cubic: it is
`45 m^2 + 0.023 m^3` ns (fit over `m` 64 to 512, `consts/bsvd-gauss*.csv`; the `m^2` term, secular equation,
deflation and permutations, is the larger below `m` 1900), so the unit is `m^2` with 53 ns, whose values over
the sizes run 47.6 to 61.7. The tridiagonal solve is `31` ns per `m^2` (26.6 to 36.2). The merge after the
join is not part of it: it is not parallel through this join, its products have their own gates. The
triangular inverse is cubic (0.0096 ns per `m^3` at 128 to 512, 0.022 at 64, c64 0.034 to 0.051). The default
recursion thresholds (128 and 64) are above the floors of the two divide and conquer joins on every token
(width 2 floors: team from `n` about 20 to 25, plain outside from about 40 to 55), so those joins are decided in effect by the merge
product gates; the join gates matter when `recursion_threshold` is set small.

Norms and `zip`: `norm_l2`, `norm_l2_sqr`, `norm_max`, `norm_l1` and the `zip` machinery take no `Par`, call no
Rayon function and run serial pairwise SIMD reductions and loops (`linalg/reductions/*.rs`, `linalg/zip.rs`);
`Mat::par_*` iterators are caller driven. There is no region to convert, and no norm or zip case in the tables
below. A parallel norm would be a new feature with its own API question (global parallelism or a `par`
argument), not a gate.

### Before and after (`tables.md`, `raw/tbl-*`, `run_tbl.py`, `summarize.py`)

Microseconds per call, f64, median over passes (before 6788b20: 4 to 8 passes, after 7b60550: 2 passes, QR:
2 passes, in separate processes alternating before and after); the ratios are to the one thread serial time of
the same process. `plain` is `Par::rayon(6)` called from outside the pool, `team` is `Par::Team` of 6.

| family | n | serial | plain before | plain after | team before | team after | plain b/s | plain a/s | team b/s | team a/s |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QR (no pivoting) | 128* | 124.6 | 127.3 | 127.2 | 102.4 | 98.9 | 1.02 | 1.02 | 0.82 | 0.80 |
| QR (no pivoting) | 256* | 703.8 | 805.5 | 818.0 | 428.5 | 437.9 | 1.14 | 1.16 | 0.61 | 0.62 |
| QR (no pivoting) | 512* | 4410.6 | 3006.2 | 3151.1 | 1797.9 | 2081.9 | 0.68 | 0.71 | 0.41 | 0.47 |
| SVD (U, V) | 128 | 1362.0 | 1194.8 | 1137.3 | 1030.6 | 1035.1 | 0.88 | 0.83 | 0.76 | 0.76 |
| SVD (U, V) | 256* | 7694.7 | 6757.9 | 6849.1 | 4702.5 | 4928.0 | 0.88 | 0.87 | 0.61 | 0.63 |
| SVD (U, V) | 512* | 46205.0 | 35271.0 | 35067.6 | 20456.7 | 19500.3 | 0.75 | 0.76 | 0.44 | 0.42 |
| EVD (eigenvectors) | 128* | 867.5 | 842.2 | 864.3 | 837.3 | 860.1 | 0.98 | 0.99 | 0.97 | 0.98 |
| EVD (eigenvectors) | 256* | 3917.8 | 3354.0 | 3362.9 | 2186.0 | 2293.5 | 0.86 | 0.85 | 0.56 | 0.58 |
| EVD (eigenvectors) | 512* | 21597.4 | 14474.7 | 14407.4 | 8428.2 | 8430.5 | 0.67 | 0.66 | 0.39 | 0.39 |
| triangular inverse | 128* | 26.7 | 177.2 | 26.2 | 21.6 | 27.1 | 6.62 | 1.00 | 0.81 | 1.04 |
| triangular inverse | 256* | 160.8 | 269.1 | 160.7 | 77.9 | 83.3 | 1.67 | 1.00 | 0.48 | 0.52 |
| triangular inverse | 512 | 1254.9 | 1200.3 | 1140.2 | 360.9 | 388.1 | 0.96 | 0.90 | 0.29 | 0.31 |
| sparse matmul (4/col, n = dimension) | 500* | 9.8 | 147.5 | 10.0 | 4.4 | 4.6 | 15.00 | 1.02 | 0.44 | 0.47 |
| sparse matmul (4/col, n = dimension) | 2000* | 51.4 | 163.0 | 50.3 | 14.3 | 14.2 | 3.09 | 1.01 | 0.27 | 0.28 |
| sparse matmul (4/col, n = dimension) | 8000 | 238.9 | 200.2 | 200.6 | 60.0 | 59.6 | 0.83 | 0.84 | 0.25 | 0.25 |

Reading: the plain token is no longer slower than serial at the triangular inverse 128 (6.6 times) and 256
(1.67 times), and the sparse product at 500 and 2000 columns (15 and 3.1 times), because their regions are
now gated (the sparse product has no gate before: every call dispatched). On a team the same cells give back
part of what the ungated recursion won: the triangular inverse 128 is 1.04 times serial (0.81 before) and 256
is 0.52 (0.48), the cost of the margin `PAYS = 3` at a width 2 section (a join under 9 us of estimated work
stays serial, and the model estimates the 64 wide halves at 5.0 us where they take 11.6 us because the rate
at `m` 64 is 2.3 times the median one). SVD and EVD at 128 to 512 are unchanged within the noise of a busy
host (their joins sat above every floor already). QR 128 on a team is 0.80 times serial (0.82 before,
0.72 with the gates of `9cd64f0`); QR 256 and 512 are unchanged.
Team cells at 512 differ by up to 10 percent between passes on this host (QR 512 team in a separate check, three
processes each: 1828, 1929, 1773 us before against 1956, 1791, 2056 us after, `raw/qr512check/`).

## Files

* `bench/` (`regions`): decision trace, gate modes, block apply region timings (feature `par-trace` of the fork).
* `bench-old/`: QR 128 timing against `9cd64f0`.
* `bench-tbl/`, `bench-tbl-before/` (same source, two revisions): the serial constants of Task B and the tables.
* `guarded.py`, `run_tbl.py`, `summarize.py`, `run_final*.sh`: host protocol and drivers.
* `raw/superseded-*`: runs of earlier commits of the branch (`dd0bc19`, `801d781`, `a9813bf`; `f880081` was
  a triangular inverse rate that was dropped again) kept for the record; they are not in the tables.
