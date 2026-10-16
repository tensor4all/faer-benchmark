# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `5578ccc3df0d980374b2fda6327710d0dcb52c8c`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `01e9f81fdf1c082c862f6d9656ff6c444b799f21`
- toolkit commit: `ca3ffc988b745675988a403fb2837d3e4dfe5653`
- measured binary SHA-256: `b0781c1608511c2a7caf169f45c0ebb5dc8e143a33b8c7ac93679526d39558a4`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-16T22:38:45.874766Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall,linalg-wide --shapes 4096x256,256x256x256,512x512x512,64x1024 --families qr_factor,qr,lu,full_piv_lu,solve --dtypes f64,c64 --threads 1 --reps 5 --aa 3 --prime-ms 250 --label merged-main-accept1 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T223016Z-merged-main-accept1/`

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
- CPU sets: 1T -> `4`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.80%, worst 26.36% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 4 of 88 engine cells exceed 5% and carry `!`; median within-process relative SD 0.28%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 48.9845 ± 0.35748 (W 0.181651) | 52.8591 ± 0.560053 (W 0.867572) | - | 🔵 fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 15.3507 ± 0.0596251 (W 0.048695) | 18.9886 ± 0.106941 (W 0.0636382) | 17.8218 ± 0.0697793 (W 0.0909097) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 71.0975 ± 0.0253897 (W 0.0970716) | 74.8274 ± 0.223344 (W 0.153582) | 82.8645 ± 1.69729 (W 0.129802) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 31.8023 ± 0.225859 (W 0.132878) | 78.2359 ± 0.315383 (W 0.0650624) | 35.6051 ± 0.377118 (W 0.186143) | 🔵 fork 2.46× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 46.8362 ± 0.15926 (W 0.229675) | 46.8375 ± 0.410081 (W 0.133252) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 13.2133 ± 0.0209384 (W 0.046745) | 13.1913 ± 0.0102687 (W 0.0506043) | 11.8031 ± 0.102734 (W 0.0262423) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 68.8772 ± 0.178132 (W 0.128594) | 68.7775 ± 0.150122 (W 0.102412) | 69.8492 ± 0.356246 (W 0.113567) | · | · |  |
| `qr_factor/4096x256/b1` | 25.6598 ± 0.247458 (W 0.0809177) | 25.5348 ± 0.297777 (W 0.0525619) | 28.9085 ± 0.0666097 (W 0.0450742) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 149.344 ± 0.612326 (W 0.531472) | 155.677 ± 0.462756 (W 0.833887) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 46.6617 ± 0.133056 (W 0.0793853) | 53.6815 ± 0.0845537 (W 0.0819391) | 65.8034 ± 0.540034 (W 0.264783) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 250.528 ± 0.29783 (W 0.234964) | 256.01 ± 0.176067 (W 0.410002) | 239.077 ± 0.93542 (W 0.465732) | · | · |  |
| `qr_factor/4096x256/b1` | 101.564 ± 0.55376 (W 0.428153) | 176.315 ± 0.217632 (W 0.123957) | 110.679 ± 0.373474 (W 0.381284) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 144.594 ± 0.266973 (W 0.817549) | 144.314 ± 0.339456 (W 0.856572) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 41.7135 ± 0.119262 (W 0.0694376) | 41.6795 ± 0.0517537 (W 0.0751058) | 49.8556 ± 1.07432 (W 0.0770948) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 244.359 ± 0.212188 (W 0.457957) | 244.831 ± 0.358378 (W 0.473722) | 215.554 ± 2.98982 (W 0.321184) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 89.9646 ± 0.462565 (W 0.17502) | 89.7537 ± 0.664867 (W 0.0510787) | 104.039 ± 0.783415 (W 0.675881) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/4096x256`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 1.12285 ± 0.00342347 (W 0.00259564) | 1.25146 ± 0.00709529 (W 0.00263838) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 0.395006 ± 0.000883075 (W 0.00989393) | 0.517885 ± 0.0027752 (W 0.00211986) | 0.926916 ± 0.136704 (W 0.00356717) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 2.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.744146 ± 0.000632731 (W 0.00257924) | 0.838642 ± 0.0164242 (W 0.00159703) | 1.52413 ± 0.0101636 (W 0.0139915) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 2.05× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.986287 ± 0.00776441 (W 0.0058134) | 1.00878 ± 0.00629668 (W 0.00335226) | 1.34535 ± 0.00166259 (W 0.0023213) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 1.0491 ± 0.00900415 (W 0.00278189) | 1.04667 ± 0.00462475 (W 0.00305358) | - | · | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 0.312131 ± 0.00142982 (W 0.00324755) | 0.312141 ± 0.000616785 (W 0.0026265) | 3.12907 ± 0.00573945 (W 0.00301322) | · | 🔵 fork 10.02× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.629262 ± 0.00218282 (W 0.00259125) | 0.632157 ± 0.00238073 (W 0.00230911) | 1.47412 ± 0.041421 (W 0.00329131) | · | 🔵 fork 2.34× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.565423 ± 0.00724139 (W 0.0021696) | 0.564873 ± 0.00597025 (W 0.00244983) | 6.3002 ± 0.00362792 (W 0.00289617) | · | 🔵 fork 11.14× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 2.42776 ± 0.0362846 (W 0.00686644) | 2.42299 ± 0.0760713 (W 0.0186385) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/64x1024/b1` | 1.01162 ± 0.0030571 (W 0.00165324) | 1.05378 ± 0.0239208 (W 0.00368812) | 2.32977 ± 0.259374 (W 0.00517178) | · | 🔵 fork 2.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 2.53343 ± 0.00334831 (W 0.00739962) | 2.60464 ± 0.0208852 (W 0.00332311) | 3.8676 ± 0.0169052 (W 0.00338598) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.575 ± 0.0060356 (W 0.00677727) | 2.59497 ± 0.0112215 (W 0.00458734) | 3.5542 ± 0.00859373 (W 0.00240657) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 2.32322 ± 0.0298224 (W 0.0130944) | 2.28263 ± 0.0226095 (W 0.0147509) | - | · | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 0.896721 ± 0.00328985 (W 0.00261855) | 0.894837 ± 0.00189666 (W 0.00486635) | 2.12994 ± 0.0095408 (W 0.00413844) | · | 🔵 fork 2.38× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 2.40396 ± 0.00946405 (W 0.0073809) | 2.41011 ± 0.000652836 (W 0.00237968) | 3.88881 ± 0.135783 (W 0.0175387) | · | 🔵 fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.21928 ± 0.00907017 (W 0.00319491) | 2.21634 ± 0.0108404 (W 0.00381979) | 16.8871 ± 0.025658 (W 0.0229633) | · | 🔵 fork 7.61× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/64x1024`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
