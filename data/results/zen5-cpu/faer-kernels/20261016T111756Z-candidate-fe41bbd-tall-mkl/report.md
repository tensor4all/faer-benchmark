# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `fe41bbdfb88c0528e0726dca3b1764f47222ad56`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `22a99b295247f785277800ae3c771d85dd3128e1`
- toolkit commit: `5e2b35c2197117414ca97372735938a1a3d958ac`
- measured binary SHA-256: `b0781c1608511c2a7caf169f45c0ebb5dc8e143a33b8c7ac93679526d39558a4`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-16T11:28:45.473078Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /home/shinaoka/projects/tensor4all/faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-tall --shapes 4096x256 --families qr_factor,qr,lu --dtypes f64,c64 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label candidate-fe41bbd-tall-mkl --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T111756Z-candidate-fe41bbd-tall-mkl/`

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
- CPU sets: 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.87%, worst 58.04% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 9 of 72 engine cells exceed 5% and carry `!`; median within-process relative SD 0.45%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 9.68363 ± 0.0188754 (W 0.158987) | 13.0404 ± 0.0433857 (W 0.0260931) | 13.3684 ± 0.027511 (W 0.0295858) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 33.3458 ± 3.01664 (W 0.176547) | 40.0354 ± 0.0481216 (W 0.201525) | 29.9694 ± 2.28532 (W 0.154383) | 🔵 fork 1.20× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 15.8026 ± 0.178178 (W 0.133301) | 76.4385 ± 0.367253 (W 0.438807) | 12.6805 ± 0.112946 (W 0.0597037) | 🔵 fork 4.84× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 8.95274 ± 0.170118 (W 0.0896596) | 12.2437 ± 0.0260992 (W 0.0292972) | 4.06325 ± 0.0422332 (W 0.0174466) | 🔵 fork 1.37× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 27.4684 ± 2.93946 (W 0.368466) | 39.7946 ± 2.4252 (W 0.737655) | 20.7138 ± 0.988604 (W 0.0834724) | 🔵 fork 1.45× faster than `faer-upstream` | 🔴 fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 12.84 ± 0.0575139 (W 0.0697704) | 76.2558 ± 0.0390858 (W 0.381867) | 7.26634 ± 0.0723491 (W 0.056082) | 🔵 fork 5.94× faster than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 7.44485 ± 0.0565457 (W 0.0398198) | 7.38364 ± 0.0195948 (W 0.0287894) | 11.5928 ± 0.0259936 (W 0.0276024) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 30.854 ± 0.0685864 (W 0.218474) | 34.4685 ± 0.173627 (W 0.121887) | 26.8909 ± 0.125819 (W 0.0872826) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.7575 ± 0.0774967 (W 0.204727) | 17.6719 ± 0.111107 (W 0.138786) | 11.2422 ± 0.0105993 (W 0.0614103) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 6.70662 ± 0.0267197 (W 0.056229) | 6.69389 ± 0.0315892 (W 0.02605) | 3.16546 ± 0.00436028 (W 0.0113152) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 24.6512 ± 2.68332 (W 0.264697) | 34.7415 ± 3.02447 (W 0.651441) | 19.2433 ± 0.226934 (W 0.458887) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 11.5149 ± 0.0395105 (W 0.0654533) | 19.5009 ± 0.161709 (W 0.234759) | 6.49248 ± 0.031746 (W 0.0326958) | 🔵 fork 1.69× faster than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 22.886 ± 0.261241 (W 0.170124) | 29.6737 ± 0.0464713 (W 0.0539916) | 58.9631 ± 0.158602 (W 0.173301) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.58× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 93.9497 ± 0.249158 (W 0.484948) | 107.618 ± 0.282438 (W 0.169757) | 85.8468 ± 0.458349 (W 0.445895) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 40.9763 ± 0.122152 (W 0.0774693) | 124.331 ± 0.594799 (W 0.488378) | 33.8022 ± 0.395894 (W 0.265833) | 🔵 fork 3.03× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 19.1909 ± 6.41598 (W 0.118934) | 25.8076 ± 0.0411279 (W 0.0660216) | 57.9578 ± 0.369617 (W 0.174587) | · | 🔵 fork 3.02× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/4096x256/b1` | 67.4934 ± 0.552962 (W 0.439648) | 91.1192 ± 0.189365 (W 0.273134) | 46.0225 ± 3.0356 (W 0.169507) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 30.3117 ± 0.222606 (W 0.0619244) | 121.984 ± 0.61114 (W 4.56103) | 19.6394 ± 0.0735288 (W 0.0782269) | 🔵 fork 4.02× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 17.3401 ± 0.0554895 (W 0.0575973) | 17.2898 ± 0.0749951 (W 0.0496003) | 49.3316 ± 0.0397495 (W 0.0532291) | · | 🔵 fork 2.84× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 88.2008 ± 0.412823 (W 0.299956) | 96.1828 ± 0.306636 (W 0.158627) | 74.414 ± 0.183363 (W 0.431361) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 35.7321 ± 0.112851 (W 0.0554865) | 44.469 ± 0.163977 (W 0.0949649) | 31.6477 ± 0.430627 (W 0.210915) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 13.5515 ± 0.0132278 (W 0.0590289) | 13.5073 ± 0.00771707 (W 0.0370767) | 49.4063 ± 0.0460707 (W 0.0500085) | · | 🔵 fork 3.65× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 61.8976 ± 0.080619 (W 0.236971) | 79.6869 ± 0.273343 (W 0.443267) | 42.1236 ± 0.14108 (W 0.159451) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.2915 ± 0.0762907 (W 0.0581163) | 41.7406 ± 0.192616 (W 0.119627) | 17.6857 ± 0.312459 (W 0.0549522) | 🔵 fork 1.53× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
