<!-- generated from data/results/zen5-cpu/faer-kernels/20261018T003938Z-candidate-qr-apply-tasks-mkl/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `52b113acd2e22fe97f4ad1face143cff58d9b3ed`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `095bc5580f5bd4a4ee024800dfa331698df46a8f`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `e68bfcc44f04569d9656938f37133343b92850898b1986ab8d4051a57150f83b`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T00:51:02.244289Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid --shapes 64,128,256,512 --families qr_factor,qr,svd_values,svd_thin --threads 1,4,8 --dtypes f64 --reps 5 --aa 3 --prime-ms 250 --label candidate-qr-apply-tasks-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T003938Z-candidate-qr-apply-tasks-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.74%, worst 77.81% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 30 of 288 engine cells exceed 5% and carry `!`; median within-process relative SD 0.41%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `qr/n64/b1` | 0.121384 ± 0.000324705 (W 0.00190838) | 0.118449 ± 0.000341527 (W 0.00104763) | 0.132514 ± 0.00038025 (W 0.00173102) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.088964 ± 0.000151767 (W 0.000261857) | 0.129999 ± 0.000272032 (W 0.0011731) | 0.298119 ± 0.133646 (W 0.00172044) | 🔵 fork 1.46× faster than `faer-upstream` | 🔵 fork 3.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.912954 ± 0.00269142 (W 0.00180918) | 0.912113 ± 0.00118846 (W 0.00134537) | 0.721772 ± 0.00313466 (W 0.00428752) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.515497 ± 0.00477083 (W 0.00170664) | 0.518024 ± 0.00171888 (W 0.00187375) | 0.265089 ± 0.00125446 (W 0.0019081) | · | 🔴 fork 1.94× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.169021 ± 0.00231767 (W 0.00169628) | 0.475965 ± 0.00526182 (W 0.00956033) | 0.146008 ± 0.00056178 (W 0.00207646) | 🔵 fork 2.82× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.108439 ± 0.0175206 (W 0.0094423) | 0.482778 ± 0.013882 (W 0.0143995) | 0.29858 ± 0.133859 (W 0.00165701) | 🔵 fork 4.45× faster than `faer-upstream` | 🔵 fork 2.75× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.949903 ± 0.00320845 (W 0.00710212) | 0.94847 ± 0.00985541 (W 0.00416188) | 0.677736 ± 0.00366154 (W 0.00350335) | · | 🔴 fork 1.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.516613 ± 0.000713245 (W 0.00195227) | 0.51484 ± 0.001466 (W 0.00194086) | 0.269957 ± 0.000302405 (W 0.00110302) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.162389 ± 0.0112828 (W 0.00198483) | 0.667351 ± 0.0212936 (W 0.0158633) | 0.157761 ± 0.00165461 (W 0.0026183) | 🔵 fork 4.11× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.112988 ± 0.00592675 (W 0.00194537) | 0.627057 ± 0.00524321 (W 0.0100384) | 0.298279 ± 0.133605 (W 0.00170742) | 🔵 fork 5.55× faster than `faer-upstream` | 🔵 fork 2.64× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.962834 ± 0.00244508 (W 0.00437584) | 0.961171 ± 0.00277258 (W 0.00356682) | 0.660539 ± 0.00629333 (W 0.00192796) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.515301 ± 0.00119158 (W 0.00226121) | 0.517774 ± 0.00813318 (W 0.00189575) | 0.269597 ± 0.000497679 (W 0.00187164) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.11392 ± 0.000653115 (W 0.000340981) | 0.115223 ± 0.000251496 (W 0.000334658) | 0.115563 ± 0.00103188 (W 0.00128359) | · | · |  |
| `qr_factor/n64/b1` | 0.072744 ± 0.000216174 (W 0.000154296) | 0.075108 ± 0.000196817 (W 0.000200505) | 0.289403 ± 0.000523148 (W 0.00170228) | · | 🔵 fork 3.98× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.956275 ± 0.00119918 (W 0.00131906) | 0.956799 ± 0.000920902 (W 0.000363402) | 0.694307 ± 0.0033523 (W 0.00239222) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.53739 ± 0.00477995 (W 0.00211383) | 0.536528 ± 0.00355217 (W 0.00175613) | 0.254749 ± 0.000281846 (W 0.00145233) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.151158 ± 0.000536687 (W 0.00238853) | 0.47726 ± 0.00494523 (W 0.011685) | 0.126592 ± 0.000683357 (W 0.000970933) | 🔵 fork 3.16× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.103431 ± 0.00200153 (W 0.00757541) | 0.397534 ± 0.020804 (W 0.0163763) | 0.289203 ± 0.000506584 (W 0.00142233) | 🔵 fork 3.84× faster than `faer-upstream` | 🔵 fork 2.80× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.993083 ± 0.0033002 (W 0.00391531) | 0.994044 ± 0.00152866 (W 0.00172587) | 0.644888 ± 0.00229695 (W 0.00213068) | · | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537007 ± 0.00263859 (W 0.00238283) | 0.537552 ± 0.00121183 (W 0.0019611) | 0.259408 ± 0.000906061 (W 0.0011584) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.145157 ± 0.000954024 (W 0.00144093) | 0.672962 ± 0.00864006 (W 0.0187052) | 0.138565 ± 0.000617752 (W 0.00173051) | 🔵 fork 4.64× faster than `faer-upstream` | · |  |
| `qr_factor/n64/b1` | 0.091639 ± 0.000434627 (W 0.00113148) | 0.565823 ± 0.00728972 (W 0.0121878) | 0.289524 ± 0.00019433 (W 0.00167645) | 🔵 fork 6.17× faster than `faer-upstream` | 🔵 fork 3.16× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.00884 ± 0.00349438 (W 0.00501778) | 1.00793 ± 0.00579476 (W 0.00476733) | 0.6391 ± 0.00772188 (W 0.00283025) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536479 ± 0.00162914 (W 0.00243131) | 0.5362 ± 0.000467348 (W 0.00166397) | 0.258957 ± 0.000691525 (W 0.00138967) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.51991 ± 0.00290495 (W 0.00240689) | 0.513254 ± 0.00173039 (W 0.00144151) | 0.751805 ± 0.00373069 (W 0.00234879) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.89425 ± 0.0041109 (W 0.00356136) | 2.93004 ± 0.00451513 (W 0.00201562) | 4.3295 ± 0.0238818 (W 0.0106425) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.1591 ± 0.983828 (W 0.0294513) | 20.7029 ± 0.951619 (W 0.0401302) | 30.6413 ± 0.19344 (W 0.0564682) | · | 🔵 fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.338014 ± 0.00201639 (W 0.00185396) | 0.532222 ± 0.00350893 (W 0.001735) | 0.369171 ± 0.000897534 (W 0.0029973) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.61257 ± 0.00775349 (W 0.00314863) | 2.87662 ± 0.0142687 (W 0.004812) | 2.04225 ± 0.0026702 (W 0.0121186) | 🔵 fork 1.78× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.9269 ± 0.0735645 (W 0.0110314) | 17.6116 ± 0.0518965 (W 0.0184225) | 14.1717 ± 0.0457951 (W 0.034941) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67707 ± 0.00495696 (W 0.00372881) | 3.67592 ± 0.00910334 (W 0.00587195) | 3.39387 ± 0.00320704 (W 0.0165034) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4248 ± 0.0308066 (W 0.0211746) | 18.4395 ± 0.0310453 (W 0.0204458) | 18.077 ± 0.0567667 (W 0.0329067) | · | · |  |
| `svd_thin/n512/b1` | 105.43 ± 0.23308 (W 0.0699259) | 105.544 ± 0.305852 (W 0.0779566) | 116.957 ± 0.484787 (W 0.327333) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69004 ± 0.00850861 (W 0.0030938) | 2.69179 ± 0.00761031 (W 0.00574329) | 1.19066 ± 0.00201736 (W 0.00203302) | · | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.5056 ± 0.0495443 (W 0.0111702) | 12.5096 ± 0.0659297 (W 0.0186817) | 6.94982 ± 0.0161839 (W 0.00746065) | · | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.5432 ± 0.384447 (W 0.0581152) | 66.5191 ± 0.24964 (W 0.0460225) | 48.2987 ± 0.211056 (W 0.0784907) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.589436 ± 0.035996 (W 0.0268383) | 1.44955 ± 0.0208744 (W 0.0220627) | 0.480427 ± 0.000179534 (W 0.00274952) | 🔵 fork 2.46× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.89435 ± 0.0113551 (W 0.0199106) | 3.87044 ± 0.0435564 (W 0.089288) | 2.01004 ± 0.00640345 (W 0.00703044) | 🔵 fork 2.04× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 10.0126 ± 0.307142 (W 0.0934234) | 14.3642 ± 0.328517 (W 0.111402) | 12.1533 ± 0.366355 (W 0.030595) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.37904 ± 0.0260336 (W 0.0172636) | 1.48894 ± 0.00390064 (W 0.0225814) | 0.197454 ± 0.0012665 (W 0.00203871) | 🔵 fork 3.93× faster than `faer-upstream` | 🔴 fork 1.92× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.35074 ± 0.0104045 (W 0.0130303) | 5.63385 ± 0.0448556 (W 0.0380925) | 0.670724 ± 0.00194777 (W 0.00226464) | 🔵 fork 4.17× faster than `faer-upstream` | 🔴 fork 2.01× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.04658 ± 0.0155177 (W 0.0575024) | 22.1996 ± 0.260268 (W 0.0666399) | 3.86129 ± 0.0022498 (W 0.00312073) | 🔵 fork 4.40× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02922 ± 0.00409741 (W 0.0147782) | 3.00896 ± 0.00971068 (W 0.0322169) | 2.63971 ± 0.00673407 (W 0.0048363) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6532 ± 0.0820631 (W 0.0555811) | 13.642 ± 0.0221527 (W 0.0349078) | 12.5473 ± 0.0452176 (W 0.0220177) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.5509 ± 0.0141664 (W 0.237645) | 61.6554 ± 0.102415 (W 0.207511) | 57.8886 ± 2.19496 (W 0.0920615) | · | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22191 ± 0.0184215 (W 0.00474286) | 2.21771 ± 0.00611952 (W 0.00474634) | 1.14239 ± 0.00456843 (W 0.00462969) | · | 🔴 fork 1.94× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8462 ± 0.067155 (W 0.0329557) | 10.8153 ± 0.0034525 (W 0.0508314) | 6.13323 ± 0.0087119 (W 0.0117104) | · | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.0614 ± 0.020515 (W 0.155825) | 48.0227 ± 0.137197 (W 0.217495) | 25.8 ± 0.071053 (W 0.0274726) | · | 🔴 fork 1.86× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.61213 ± 0.0197714 (W 0.0217268) | 1.94053 ± 0.0170973 (W 0.0253399) | 0.434301 ± 0.00188977 (W 0.00357323) | 🔵 fork 3.17× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.73469 ± 0.00986858 (W 0.0287614) | 4.83038 ± 0.103557 (W 0.0425458) | 1.80321 ± 0.0146337 (W 0.0165536) | 🔵 fork 2.78× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 8.61914 ± 0.0324821 (W 0.0592379) | 15.6863 ± 0.0478423 (W 0.147047) | 10.5558 ± 0.325087 (W 0.0390375) | 🔵 fork 1.82× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.365063 ± 0.0119776 (W 0.00657776) | 2.00651 ± 0.0133572 (W 0.0424399) | 0.157821 ± 0.00161499 (W 0.0011301) | 🔵 fork 5.50× faster than `faer-upstream` | 🔴 fork 2.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.30212 ± 0.012038 (W 0.0191715) | 6.7357 ± 0.0264801 (W 0.0678976) | 0.576294 ± 0.00160157 (W 0.00291854) | 🔵 fork 5.17× faster than `faer-upstream` | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.55888 ± 0.044778 (W 0.032027) | 25.2268 ± 0.149129 (W 0.10898) | 2.31288 ± 0.00725035 (W 0.00392955) | 🔵 fork 5.53× faster than `faer-upstream` | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.0544 ± 0.0134497 (W 0.0133819) | 3.12883 ± 0.0161472 (W 0.0277876) | 2.52375 ± 0.00474889 (W 0.00469607) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4453 ± 0.0415616 (W 0.0496431) | 13.7403 ± 0.0399153 (W 0.0325519) | 11.4906 ± 0.0269331 (W 0.0185995) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.1262 ± 0.0920533 (W 0.545064) | 60.8376 ± 0.48658 (W 0.27646) | 48.3768 ± 2.32121 (W 0.16443) | · | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.21669 ± 0.0416797 (W 0.00431543) | 2.27312 ± 0.005944 (W 0.00732186) | 1.12949 ± 0.00218971 (W 0.00162202) | · | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.9629 ± 0.0196512 (W 0.024482) | 10.9632 ± 0.0105856 (W 0.0219909) | 5.99523 ± 0.0230193 (W 0.0063293) | · | 🔴 fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.5987 ± 0.142844 (W 0.36313) | 49.1811 ± 0.125054 (W 0.448448) | 22.3865 ± 0.0842153 (W 0.0240697) | · | 🔴 fork 2.17× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.485546 ± 0.00226647 (W 0.00219304) | 0.490281 ± 0.000526466 (W 0.00195315) | 0.720936 ± 0.0240641 (W 0.00323036) | · | 🔵 fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.77183 ± 0.00249158 (W 0.00305083) | 2.78457 ± 0.00560564 (W 0.00295195) | 4.34247 ± 0.00732024 (W 0.00892649) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.5668 ± 0.98768 (W 0.0270927) | 19.6181 ± 0.816857 (W 0.0300612) | 30.3006 ± 0.181998 (W 0.0208068) | · | 🔵 fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.275678 ± 0.000318118 (W 0.00137636) | 0.279786 ± 0.00272365 (W 0.00251278) | 0.333804 ± 0.000565893 (W 0.00234274) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.36133 ± 0.00760243 (W 0.00259644) | 1.37184 ± 0.0057536 (W 0.00245297) | 1.89385 ± 0.00516754 (W 0.00699093) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.92023 ± 0.0259929 (W 0.0115423) | 7.98046 ± 0.0588287 (W 0.0097361) | 13.4292 ± 0.0186673 (W 0.0146603) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67524 ± 0.00714642 (W 0.00474242) | 3.67413 ± 0.0122139 (W 0.00382769) | 3.31865 ± 0.00678644 (W 0.0176381) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3116 ± 0.0282913 (W 0.388196) | 18.3194 ± 0.0621756 (W 0.0212523) | 17.7276 ± 0.0358955 (W 0.0290047) | · | · |  |
| `svd_thin/n512/b1` | 104.618 ± 0.129921 (W 0.0809043) | 104.835 ± 0.174268 (W 0.386734) | 114.433 ± 1.79207 (W 0.249286) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.61116 ± 0.0128366 (W 0.00451138) | 2.62003 ± 0.00797673 (W 0.0028774) | 1.15703 ± 0.00357054 (W 0.00303146) | · | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.3128 ± 0.0515494 (W 0.0167486) | 12.3269 ± 0.04869 (W 0.018018) | 6.87224 ± 0.0457958 (W 0.0129014) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.5558 ± 0.432 (W 0.0329509) | 65.5349 ± 0.473277 (W 0.361654) | 47.1777 ± 0.0606565 (W 0.0768637) | · | 🔴 fork 1.39× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.554292 ± 0.0239459 (W 0.0246682) | 1.39944 ± 0.0169441 (W 0.023765) | 0.45634 ± 0.0145878 (W 0.00335919) | 🔵 fork 2.52× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.77827 ± 0.0069808 (W 0.0117833) | 3.72165 ± 0.0130743 (W 0.05927) | 2.207 ± 0.0226788 (W 0.00742195) | 🔵 fork 2.09× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.40886 ± 0.273191 (W 0.148102) | 13.28 ± 0.324902 (W 0.134864) | 13.1474 ± 0.0712499 (W 0.0208748) | 🔵 fork 1.41× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.346459 ± 0.0282666 (W 0.00168717) | 1.19759 ± 0.035019 (W 0.019722) | 0.183588 ± 0.00177331 (W 0.0016908) | 🔵 fork 3.46× faster than `faer-upstream` | 🔴 fork 1.89× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.22791 ± 0.00380727 (W 0.00912091) | 3.13395 ± 0.0325038 (W 0.0426366) | 0.61823 ± 0.00517816 (W 0.00337549) | 🔵 fork 2.55× faster than `faer-upstream` | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.66151 ± 0.0460135 (W 0.0262543) | 8.56893 ± 0.0620861 (W 0.0770368) | 3.69695 ± 0.0296411 (W 0.00632368) | 🔵 fork 1.84× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.00808 ± 0.00915286 (W 0.0156117) | 3.00451 ± 0.019619 (W 0.0212371) | 2.59402 ± 0.00428791 (W 0.00460972) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5897 ± 0.0397985 (W 0.0867947) | 13.557 ± 0.0482443 (W 0.0476937) | 12.3901 ± 0.047141 (W 0.0187818) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.3952 ± 0.0903073 (W 0.152774) | 60.8536 ± 0.217076 (W 0.499645) | 56.5871 ± 0.191134 (W 0.0762059) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.16678 ± 0.0163003 (W 0.0114341) | 2.14927 ± 0.00223619 (W 0.00480971) | 1.12376 ± 0.0118305 (W 0.00340696) | · | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6536 ± 0.0106437 (W 0.0481688) | 10.6335 ± 0.0259061 (W 0.018078) | 6.08912 ± 0.00814974 (W 0.010729) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.1251 ± 0.0800646 (W 0.40804) | 47.3986 ± 0.304964 (W 0.538567) | 25.5582 ± 0.215429 (W 0.0180256) | · | 🔴 fork 1.84× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.561944 ± 0.00299436 (W 0.0174216) | 1.8591 ± 0.0594592 (W 0.0248231) | 0.419973 ± 0.0235079 (W 0.00470868) | 🔵 fork 3.31× faster than `faer-upstream` | 🔴 fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.60442 ± 0.0112877 (W 0.0169547) | 4.65904 ± 0.0528502 (W 0.043099) | 2.06453 ± 0.00162166 (W 0.00814237) | 🔵 fork 2.90× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 7.96439 ± 0.0231426 (W 0.120044) | 14.7062 ± 0.0782683 (W 0.120802) | 10.6398 ± 0.197441 (W 0.0166014) | 🔵 fork 1.85× faster than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.326353 ± 0.00504702 (W 0.00506074) | 1.60546 ± 0.00268206 (W 0.0149271) | 0.146079 ± 0.00028 (W 0.00133626) | 🔵 fork 4.92× faster than `faer-upstream` | 🔴 fork 2.23× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.20736 ± 0.00435331 (W 0.0257242) | 4.11914 ± 0.0237577 (W 0.0394986) | 0.543891 ± 0.00618122 (W 0.00275741) | 🔵 fork 3.41× faster than `faer-upstream` | 🔴 fork 2.22× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.24607 ± 0.00472098 (W 0.0391382) | 10.1229 ± 0.0821377 (W 0.0404391) | 2.24538 ± 0.00192377 (W 0.00365773) | 🔵 fork 2.38× faster than `faer-upstream` | 🔴 fork 1.89× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01015 ± 0.02658 (W 0.012863) | 3.09544 ± 0.00797801 (W 0.0123747) | 2.47387 ± 0.0110852 (W 0.0069431) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3635 ± 0.0710813 (W 0.0398319) | 13.7139 ± 0.0644422 (W 0.0455244) | 11.4231 ± 0.0695758 (W 0.0327168) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.0102 ± 0.141073 (W 0.326967) | 59.837 ± 0.238399 (W 0.516212) | 47.7538 ± 0.301587 (W 0.278639) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.19156 ± 0.039571 (W 0.00603122) | 2.15343 ± 0.0377294 (W 0.00375209) | 1.11649 ± 0.00127797 (W 0.00688338) | · | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.79 ± 0.0179762 (W 0.0216821) | 10.7983 ± 0.0311902 (W 0.0184069) | 6.01432 ± 0.0438564 (W 0.0115101) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.9577 ± 0.156923 (W 0.513099) | 48.171 ± 0.17595 (W 0.332255) | 22.2597 ± 0.0288158 (W 0.0253598) | · | 🔴 fork 2.15× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
