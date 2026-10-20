# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `b7715c53ba75946d68a97d5655f481b198332447`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `651807301c4fd0d485a66038346388dffe289073`
- toolkit commit: `9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5`
- measured binary SHA-256: `2decf425848a5b0706f9c20de65084822a23d659071b38b6bf7c9dea9d347e4a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T15:35:03.731095Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families cholesky --shapes 32,64,96,128,256 --no-publish --label native-floor-stage1-A-cholesky`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T153011Z-native-floor-stage1-A-cholesky/`

## What was measured

- **Workload** — Direct calls into one faer revision: square and rectangular dense matrices, C (row-major) and F (column-major) order, `f64` and `c64`. A shape is `N` for square, `MxN` for rectangular, or `MxKxN` for `gemm`, which is a three-index operation and cannot be written as two. Sizes are the matrix dimensions, not a memory budget, so a case name says exactly what was factored. `gemm` measures `linalg::matmul::matmul` into a caller-prepared destination with `Accum::Replace`; there is no operator path, so one shape is one work.
  Source: The fork's own public API (`faer/src/linalg`): `matmul`, the QR factor and composite, `upgrade_householder_factor`, the block/sequence Householder apply, LU and full-pivot LU, Cholesky, triangular solve, solve, thin SVD, singular values and the symmetric/nonsymmetric eigensolvers. Inputs are seeded from the case, so `verify` and `run` measure the same matrices and a rerun is reproducible.
  Known blind spot: Only the faer entry points are measured. tlinalg's packing, batch loop and lane policy, tenferro's tensor construction and dtype dispatch, and the small-`m` decode-projection shapes are other repositories' rows (tlinalg-benchmark, tenferro-benchmark).
  Known blind spot: Vendor C-order cells use CBLAS/LAPACKE row-major entry points. Workspace allocation or layout conversion internal to those APIs remains timed; these are not prepared-column-major or transpose measurements.
  Known blind spot: `gemm` covers the tall class's two Householder legs (a 16-wide basis and a 240-column target over 4096 rows: the reduction and the write-back) beside a vendor `?gemm` on the same leg. A single leg beside a vendor gemm is a diagnostic reference, not the equivalent implementation of the whole update, and the row is labelled accordingly.
  Known blind spot: `householder_apply` measures block apply and the one-block sequence form as two distinct rows, labelled with basis width min(m,n) and target width n. QR fixture preparation is outside timing. Independently varied basis/target widths and multi-panel sequences are not covered.
  Known blind spot: Allocation performed inside the measured call stays inside the clock. The fork's two row splits allocate their partial buffers inside the public call, and the public scratch function does not expose them; the campaign reports that as it is instead of changing faer's API to make the boundary look cleaner.
  Known blind spot: `cholesky`, `eigh`, `solve` and `triangular_solve` are measured on square shapes only: the matrix they factor or solve with is square by definition (self-adjoint for the first two, a triangular factor for the last). `lu` and `full_piv_lu` are not gated that way -- they take the declared rectangular shapes too, with `min(m, n)` pivots and a trapezoidal `L` or `U`, which is what `dgetrf` does as well -- so a rectangular LU cell is measured in both orders beside its square one.
  Known blind spot: `f32`/`c32`, the large regime's 1024 shapes, BLIS, sparse, iterative and GPU arms are later declarations, not machinery built now.
  Known blind spot: A vendor arm records the library it linked. Only OpenBLAS reports the kernel its runtime dispatched to; MKL names no kernel and no processor count, so its manifest leaves both empty rather than inferring them.
- **Rows** — one row per engine in every table below:
  - `faer-fork` — The measured library: the tensor4all fork (`t4a-faer`, `[lib] name = "faer"`) at the checkout the harness linked by path. This is the row the campaign exists for; the fork's three perf experiments and the two correctness changes land here.
    Identity: the fork revision in this run's manifest (`library.commit`), pinned by `pins/t4a-faer.rev`
    Caveat: Both faer crates declare `[lib] name = "faer"`. They are distinct dependency keys (`faer_fork = { package = "t4a-faer" }`, `faer_upstream = { package = "faer" }`) and therefore distinct Rust crate identities, but their `Mat`, `Par` and trait types are not interchangeable: every adapter is written per arm, and shared transitive dependencies can unify Cargo features, so both arms declare equivalent feature sets and the resolved lock is recorded.
    As measured: `faer-fork` (the provider in the measured revision; see library and upstream above)
  - `faer-upstream` — Upstream `faer` at the tag the fork is based on, in the same binary as the fork row. The baseline that says whether a fork change moved the number.
    Identity: the upstream revision in this run's manifest (`upstream.commit`), pinned by `pins/upstream-faer.rev`
    Caveat: Same crate-name and feature-unification caveat as `faer-fork`. A change to upstream at a fixed fork revision produces a different page rather than overwriting one.
    As measured: `faer-upstream` (the provider in the measured revision; see library and upstream above)
  - `lapack-mkl` — The same calls against Intel oneAPI MKL, linked from the installation `MKLROOT` names. One binary links one vendor library, so this row is measured by its own build of the harness and recorded as its own run; no page carries two vendor arms. The LP64 interface layer and the threading layer are pinned by the harness before the first MKL call, because MKL otherwise lets the environment choose them and the interface layer is an ABI.
    Identity: the MKL build recorded in this run's manifest (`providers[mkl]`)
    Caveat: MKL reports no dispatched-kernel name and no processor count, so its manifest records neither rather than inferring them. Its threading is vendor-owned, as for OpenBLAS.
    As measured: linked shared; mkl 2026.1; kernel not reported by the vendor

## Hardware

- CPU: `AMD Ryzen AI 9 HX 470`
- logical CPUs: `24`
- L3: `24 MiB (2 instances)`
- L3 domains: `0-3: 16 MiB shared; 4-11: 8 MiB shared`
- OS / arch: `Linux 7.0.0-38-generic` / `x86_64`
- hostname: `shinaoka-EVO-X1Pro`
- CPU sets: 1T -> `4`, 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 1.52%, worst 508.37% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 32 of 180 engine cells exceed 5% and carry `!`; median within-process relative SD 0.80%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
The `vs faer-fork` column is the rotation-averaged ratio exp(mean over starts of
log(engine median / faer-fork median)), with the per-start ratios beside it: `R > 1`
means the engine was slower than that first-declared row in that start. It removes a
row-position
effect only under one position effect shared by the engines and stable across starts,
and only where every declared engine has a measured row (`*` marks a cell where one has
no row, so no ratio there is position-balanced). `!` marks a cell where some engine's own
per-start median range exceeds 5% of its median, and `p` a balanced cell whose estimated
position-effect ratio exceeds 1.05. Flagged cells are retained, not discarded; the
between-start variation can exceed the difference being compared.
The `vs` columns mark only differences larger than the spread this run recorded for those
two rows (combined between-start SD, floored at 5%), always with the fork as the subject:
`🔵 fork X faster than <row>` / `🔴 fork X slower than <row>` (the compared row is named in
the cell, not only in the column header), `·` inside the band, `-` that row is not
measured in this arm. `notes` carries the cell warnings (`*` a declared row has no measurement,
`!` between-start range over 5%, `p` position effect over 5%, dispatch-dominated means the
row is under 20 us so 4T/8T pay thread-region start-up). Per-start ratios and every
chronological sample are in the run directory named at the top of this page (`run*.csv`).
These describe the recorded revisions; they are not a regression claim.

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003356 ± 3.60555e-05 (W 3.43511e-05) | 0.003196 ± 0.000208806 (W 3.1372e-05) | 0.004168 ± 2.00083e-05 (W 4.32435e-05) | · | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016431 ± 4.72582e-05 (W 3.82923e-05) | 0.015058 ± 0.00107846 (W 5.43719e-05) | 0.016962 ± 0.000156195 (W 7.16952e-05) | 🔴 fork 1.09× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.032491 ± 0.00011547 (W 7.11562e-05) | 0.031098 ± 0.00134007 (W 9.58932e-05) | 0.048851 ± 0.000268099 (W 0.000109569) | · | 🔵 fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003397 ± 1.70392e-05 (W 2.81283e-05) | 0.003216 ± 0.000173877 (W 3.71484e-05) | 0.004168 ± 1.58219e-05 (W 3.93865e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016481 ± 5e-05 (W 2.86356e-05) | 0.014948 ± 0.0010289 (W 3.05483e-05) | 0.016821 ± 0.000108721 (W 7.94311e-05) | 🔴 fork 1.10× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050384 ± 0.00111347 (W 0.00358015) | 0.062186 ± 0.000818794 (W 0.00550693) | 0.048601 ± 7.2111e-05 (W 0.000152727) | 🔵 fork 1.23× faster than `faer-upstream` | · |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003376 ± 1.1547e-05 (W 3.795e-05) | 0.003426 ± 0.000135769 (W 2.05499e-05) | 0.004177 ± 3.05014e-05 (W 3.72048e-05) | · | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016521 ± 0.000116047 (W 2.71901e-05) | 0.016751 ± 0.00114069 (W 2.86356e-05) | 0.016812 ± 0.000110666 (W 6.69328e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.058679 ± 0.000423734 (W 0.00366338) | 0.071724 ± 0.00200913 (W 0.00324882) | 0.04862 ± 9.07028e-05 (W 0.00011741) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003286 ± 2.3094e-05 (W 2.04939e-05) | 0.003066 ± 0.000184752 (W 2.56963e-05) | 0.003397 ± 9.50438e-06 (W 2.50639e-05) | 🔴 fork 1.07× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01612 ± 3.21455e-05 (W 3.8629e-05) | 0.014758 ± 0.00111745 (W 3.67587e-05) | 0.014136 ± 9.58662e-05 (W 5.43351e-05) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.03192 ± 0.000538975 (W 6.4135e-05) | 0.030096 ± 0.00140015 (W 0.00111137) | 0.038492 ± 0.000341195 (W 7.81876e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003256 ± 1e-05 (W 1.14018e-05) | 0.003095 ± 0.000207534 (W 3.17065e-05) | 0.003347 ± 2.91605e-05 (W 3.53171e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016351 ± 6.245e-05 (W 4.50555e-05) | 0.014647 ± 0.00100444 (W 4.26415e-05) | 0.014226 ± 0.000100683 (W 4.63379e-05) | 🔴 fork 1.12× slower than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050695 ± 0.000346858 (W 0.00139015) | 0.061676 ± 0.00368616 (W 0.00524521) | 0.038643 ± 0.000140787 (W 0.00011045) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003296 ± 3.55949e-05 (W 3.58929e-05) | 0.003326 ± 0.000128103 (W 2.89344e-05) | 0.003376 ± 8.59089e-05 (W 4.15126e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0162 ± 7.50355e-05 (W 3.29742e-05) | 0.016331 ± 0.00127136 (W 5.15577e-05) | 0.014126 ± 5.55608e-05 (W 4.96991e-05) | · | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056856 ± 0.000296127 (W 0.00308815) | 0.070131 ± 0.00164325 (W 0.00110512) | 0.038572 ± 0.000246002 (W 0.000128725) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005219 ± 4.32474e-05 (W 2.33923e-05) | 0.005189 ± 7.10422e-05 (W 3.24546e-05) | 0.008966 ± 0.000143377 (W 3.31662e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030507 ± 8.5049e-05 (W 5.97495e-05) | 0.030227 ± 0.0002582 (W 0.000117334) | 0.051076 ± 0.000153971 (W 0.00105331) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084036 ± 0.00018921 (W 0.000172105) | 0.083807 ± 0.000650311 (W 0.000214501) | 0.13944 ± 0.0228003 (W 0.00103477) | · | 🔵 fork 1.66× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005219 ± 3.80832e-05 (W 1.30384e-05) | 0.00518 ± 5.45008e-05 (W 4.80448e-05) | 0.008787 ± 2.62742e-05 (W 8.06802e-05) | · | 🔵 fork 1.68× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030628 ± 0.000150699 (W 3.16228e-05) | 0.030287 ± 0.000261382 (W 6.60242e-05) | 0.051346 ± 0.000273746 (W 0.000325768) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103934 ± 0.00125212 (W 0.00147132) | 0.102962 ± 0.00055309 (W 0.00285482) | 0.13928 ± 0.0231767 (W 0.00168493) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005259 ± 1.53948e-05 (W 2.07364e-05) | 0.005199 ± 7.26659e-05 (W 3.59764e-05) | 0.008937 ± 0.000161494 (W 7.8761e-05) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030367 ± 0.00040724 (W 5.56444e-05) | 0.030327 ± 0.000163147 (W 6.30872e-05) | 0.051026 ± 0.00098044 (W 0.000137801) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.11235 ± 0.000873857 (W 0.00292658) | 0.111538 ± 0.000733532 (W 0.00240111) | 0.140993 ± 0.00139941 (W 0.00135055) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005239 ± 5.1449e-05 (W 3.05336e-05) | 0.00515 ± 1.18462e-05 (W 2.9416e-05) | 0.008165 ± 4.58258e-05 (W 6.79205e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030246 ± 0.000120968 (W 6.45004e-05) | 0.029936 ± 0.000194569 (W 6.53452e-05) | 0.043331 ± 0.000588303 (W 0.000104863) | · | 🔵 fork 1.43× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083326 ± 0.00034742 (W 0.000107908) | 0.083536 ± 0.000359639 (W 7.42314e-05) | 0.126666 ± 0.0013325 (W 0.00150146) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005219 ± 2.51064e-05 (W 2.16795e-05) | 0.00517 ± 4.45758e-05 (W 2.48998e-05) | 0.008045 ± 0.000125527 (W 2.30217e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029966 ± 0.000247857 (W 7.44735e-05) | 0.029855 ± 0.000210571 (W 5.38266e-05) | 0.044063 ± 0.0003271 (W 0.000119316) | · | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.10162 ± 0.00255136 (W 0.00351783) | 0.1022 ± 0.00104526 (W 0.00196547) | 0.126105 ± 0.00162309 (W 0.00193239) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00524 ± 4.98698e-05 (W 2.1822e-05) | 0.005169 ± 3.80832e-05 (W 3.59333e-05) | 0.007935 ± 0.000162891 (W 5.52467e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030226 ± 0.000412747 (W 0.000103199) | 0.029946 ± 0.000135769 (W 5.71839e-05) | 0.044182 ± 0.000622441 (W 0.00195805) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.110367 ± 0.000747057 (W 0.00308182) | 0.110797 ± 0.00077081 (W 0.00274684) | 0.124913 ± 0.000357366 (W 0.00142624) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.069439 ± 0.000287699 (W 0.000483475) | 0.066614 ± 0.000455145 (W 0.000617868) | 0.114824 ± 0.000406092 (W 0.00176405) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.386892 ± 0.00611945 (W 0.00306868) | 0.380269 ± 0.00536381 (W 0.00241547) | 0.641969 ± 0.00189446 (W 0.00505566) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.088155 ± 6.55744e-05 (W 0.000668612) | 0.102711 ± 0.00360227 (W 0.00657348) | 0.115525 ± 0.00143747 (W 0.00159368) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.382183 ± 0.0139396 (W 0.022326) | 0.400627 ± 0.0173888 (W 0.0398284) | 0.402521 ± 0.00428529 (W 0.00302346) | · | 🔵 fork 1.05× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.093224 ± 0.00209415 (W 0.00352134) | 0.102511 ± 0.00407237 (W 0.00251104) | 0.113492 ± 0.000536031 (W 0.000381791) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.399616 ± 0.00924668 (W 0.0242815) | 0.465669 ± 0.0142555 (W 0.011783) | 0.358019 ± 0.00416673 (W 0.00299831) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063428 ± 0.00355821 (W 0.000128889) | 0.060183 ± 0.000176154 (W 0.00011297) | 0.094817 ± 0.00124532 (W 0.00153871) | · | 🔵 fork 1.49× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.322412 ± 0.00036809 (W 0.00190463) | 0.316531 ± 0.00270749 (W 0.00220703) | 0.457884 ± 0.0059477 (W 0.00393859) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.081302 ± 0.00126233 (W 0.00346841) | 0.095488 ± 0.00393995 (W 0.00393327) | 0.091161 ± 0.00135451 (W 0.00120931) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.343722 ± 0.0327041 (W 0.0261458) | 0.363438 ± 0.0113063 (W 0.0232201) | 0.240158 ± 0.00207479 (W 0.00404826) | · | 🔴 fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.086772 ± 0.000214399 (W 0.00272199) | 0.09633 ± 0.00091991 (W 0.001795) | 0.09149 ± 0.00128801 (W 0.000547697) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.34287 ± 0.011036 (W 0.0239898) | 0.373999 ± 0.00695553 (W 0.0320584) | 0.207357 ± 0.0437259 (W 0.0393346) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.65× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.18786 ± 0.000364966 (W 0.000866496) | 0.18714 ± 0.0006366 (W 0.0016928) | 0.475348 ± 0.00251691 (W 0.00345334) | · | 🔵 fork 2.53× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.22509 ± 0.00333899 (W 0.00309856) | 1.22128 ± 0.00200198 (W 0.00235763) | 1.84469 ± 0.0169419 (W 0.00583738) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188722 ± 0.00115543 (W 0.00274012) | 0.201886 ± 0.00307252 (W 0.00495594) | 0.476419 ± 0.000796662 (W 0.00272695) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.52× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.854825 ± 0.00449389 (W 0.00792535) | 0.859464 ± 0.0144429 (W 0.0133873) | 0.793832 ± 0.00356002 (W 0.00946996) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.195245 ± 0.00123437 (W 0.00250019) | 0.213939 ± 0.00251323 (W 0.00350637) | 0.47699 ± 0.00110839 (W 0.00360585) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 2.44× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.849886 ± 2.48668 (W 0.0241538) | 0.872037 ± 0.0061779 (W 0.0134396) | 0.655974 ± 0.00341056 (W 0.00276775) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174917 ± 0.00030679 (W 0.00139348) | 0.174456 ± 0.000250414 (W 0.00137109) | 0.409474 ± 0.00105036 (W 0.00203772) | · | 🔵 fork 2.34× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.12823 ± 0.000655793 (W 0.0023077) | 1.12746 ± 0.0026841 (W 0.00225321) | 1.62047 ± 0.0170943 (W 0.00525902) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176609 ± 0.00244835 (W 0.001585) | 0.191147 ± 0.0032674 (W 0.00626655) | 0.407901 ± 0.00293092 (W 0.00199557) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.31× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.756822 ± 0.00435479 (W 0.010832) | 0.779966 ± 0.00870433 (W 0.00978257) | 0.644714 ± 0.0362985 (W 0.0337399) | · | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.183061 ± 0.000324389 (W 0.00352534) | 0.197589 ± 0.00130708 (W 0.00389675) | 0.405857 ± 0.000369658 (W 0.0035116) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.22× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.752174 ± 0.0101662 (W 0.0175977) | 0.785827 ± 0.00441023 (W 0.0127627) | 0.461952 ± 0.000281202 (W 0.00255874) | · | 🔴 fork 1.63× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
