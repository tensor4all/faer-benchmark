# `faer-kernels-large` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `487e16df0d0d4b648e84f6a40fba13249418bf54`
- toolkit commit: `884b638a744449a59ab1c98453fce4e242cb462d`
- measured binary SHA-256: `7a0c2d6474f16fd0ff736e4d8b04932fbdfbf0ca57f21ea8391cc4d4e1707bfe`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-16T08:08:36.592598Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels-large --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-large,linalg-large --shapes 1024,1024x1024x1024 --dtypes f64 --families lu,full_piv_lu,cholesky,qr_factor,qr,svd_values,svd_thin,eigh,gemm --reps 5 --aa 3 --prime-ms 250 --label baseline-v2-large-1024-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels-large/20261016T070748Z-baseline-v2-large-1024-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.95%, worst 41.70% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 20 of 104 engine cells exceed 5% and carry `!`; median within-process relative SD 0.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 7.87059 ± 0.0968967 (W 0.044553) | 7.82949 ± 0.181829 (W 0.0922589) | 8.50985 ± 0.0924928 (W 0.038586) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n1024/b1` | 120.157 ± 0.206312 (W 0.272653) | 120.219 ± 0.433268 (W 0.317261) | 123.751 ± 0.343908 (W 0.346311) | · | · |  |
| `full_piv_lu/n1024/b1` | 78.7025 ± 2.69718 (W 0.846929) | 78.846 ± 2.15547 (W 0.310062) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n1024/b1` | 27.1006 ± 2.83094 (W 0.087912) | 26.9865 ± 3.09508 (W 0.4363) | 11.4791 ± 1.79878 (W 0.087147) | · | 🔴 fork 2.36× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 63.4498 ± 3.3768 (W 0.333344) | 63.846 ± 3.5458 (W 0.530294) | 60.657 ± 0.446098 (W 0.135887) | · | · | `!` between-start range over 5% |
| `qr_factor/n1024/b1` | 75.8893 ± 0.35145 (W 0.143275) | 83.8032 ± 0.208634 (W 0.135684) | 20.8986 ± 0.185523 (W 0.0353598) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 3.63× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 308.047 ± 0.707396 (W 0.650106) | 307.372 ± 0.442589 (W 1.0255) | 297.833 ± 1.49025 (W 4.0525) | · | · |  |
| `svd_values/n1024/b1` | 210.486 ± 1.04511 (W 1.16675) | 210.824 ± 1.49859 (W 0.833745) | 124.48 ± 1.74075 (W 0.395084) | · | 🔴 fork 1.69× slower than `lapack-mkl` |  |

## linalg-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 6.55403 ± 0.0642547 (W 0.101343) | 6.50258 ± 0.0802526 (W 0.0756148) | 5.21569 ± 0.0665611 (W 0.0296463) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `eigh/n1024/b1` | 103.387 ± 1.304 (W 0.202489) | 103.278 ± 1.40395 (W 0.855854) | 85.3295 ± 0.0287664 (W 0.305626) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 67.9095 ± 0.28573 (W 1.16299) | 68.1518 ± 2.64226 (W 0.728946) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n1024/b1` | 24.8652 ± 1.98478 (W 0.19583) | 25.2727 ± 0.43066 (W 0.204782) | 6.94945 ± 1.6705 (W 0.0347608) | · | 🔴 fork 3.58× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 60.4335 ± 0.182797 (W 1.41195) | 60.8943 ± 0.630715 (W 0.913603) | 44.7056 ± 0.11345 (W 0.132593) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 78.9863 ± 0.264411 (W 0.452262) | 87.3654 ± 0.188129 (W 0.463385) | 14.5847 ± 0.09124 (W 0.0252669) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 5.42× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 271.588 ± 0.640489 (W 1.28119) | 271.708 ± 0.360519 (W 0.917211) | 232.066 ± 0.660302 (W 0.775683) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 197.016 ± 0.775948 (W 0.729115) | 197.44 ± 0.446048 (W 1.1869) | 93.6738 ± 0.439247 (W 0.0723077) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |

## linalg-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 5.77881 ± 0.0385445 (W 0.113842) | 5.77491 ± 0.0327911 (W 0.14021) | 6.826 ± 0.0720979 (W 0.0257277) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `eigh/n1024/b1` | 118.015 ± 0.215064 (W 0.15223) | 118.178 ± 0.397767 (W 0.159264) | 122.35 ± 0.175199 (W 0.148641) | · | · |  |
| `full_piv_lu/n1024/b1` | 69.5484 ± 2.839 (W 0.201665) | 69.681 ± 0.454741 (W 0.4917) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n1024/b1` | 14.9468 ± 3.0607 (W 0.0405911) | 14.8904 ± 3.03977 (W 0.052615) | 9.54245 ± 0.00934275 (W 0.0223258) | · | 🔴 fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 55.9268 ± 4.2173 (W 0.141656) | 56.4358 ± 4.32411 (W 0.296642) | 63.0839 ± 0.129517 (W 0.383754) | · | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n1024/b1` | 26.1628 ± 0.123592 (W 0.0916088) | 26.3752 ± 0.116043 (W 0.100619) | 19.2802 ± 0.0404521 (W 0.0152723) | · | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 300.964 ± 0.537782 (W 1.07319) | 300.519 ± 0.630299 (W 1.49846) | 278.492 ± 7.84613 (W 1.20089) | · | 🔴 fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n1024/b1` | 203.574 ± 0.35668 (W 1.00542) | 203.661 ± 0.552836 (W 0.738528) | 122.799 ± 1.11181 (W 0.614022) | · | 🔴 fork 1.66× slower than `lapack-mkl` |  |

## linalg-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 4.3778 ± 0.00990261 (W 0.0693143) | 4.52801 ± 0.0663511 (W 0.0851089) | 4.01142 ± 0.195332 (W 0.0260098) | · | 🔴 fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n1024/b1` | 101.13 ± 0.584854 (W 0.532204) | 101.103 ± 0.45171 (W 0.57935) | 83.6522 ± 0.0919705 (W 0.0675303) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 64.6739 ± 2.85359 (W 0.154682) | 64.4843 ± 2.62264 (W 0.283175) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n1024/b1` | 12.7894 ± 2.944 (W 0.147553) | 12.8913 ± 2.92259 (W 0.148614) | 5.97116 ± 0.00697773 (W 0.013283) | · | 🔴 fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 53.0775 ± 0.528872 (W 0.708569) | 53.3991 ± 0.440188 (W 1.04288) | 48.5302 ± 0.219992 (W 0.0337383) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 27.4413 ± 0.0866959 (W 0.743561) | 28.142 ± 0.536711 (W 0.422349) | 13.349 ± 0.0844788 (W 0.0147651) | · | 🔴 fork 2.06× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 264.329 ± 0.176176 (W 1.11299) | 263.802 ± 1.03202 (W 1.27489) | 214.524 ± 1.75132 (W 0.753852) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 190.06 ± 0.68192 (W 0.442582) | 189.466 ± 0.153921 (W 0.659972) | 92.5976 ± 0.569476 (W 0.397897) | · | 🔴 fork 2.05× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/1024`.

## gemm-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.5673 ± 0.0415376 (W 0.0173901) | 17.6069 ± 0.0306329 (W 0.0230502) | 20.7981 ± 0.06691 (W 0.0488446) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.08576 ± 0.0256097 (W 0.00858562) | 9.0775 ± 0.0175452 (W 0.00985484) | 11.5945 ± 0.049691 (W 0.0398996) | · | 🔵 fork 1.28× faster than `lapack-mkl` |  |

## gemm-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6374 ± 0.0433081 (W 0.0198054) | 17.6104 ± 0.0414932 (W 0.0303141) | 20.8986 ± 0.249234 (W 0.0415877) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.06527 ± 0.0461141 (W 0.0218566) | 9.06949 ± 0.00291418 (W 0.00496767) | 11.502 ± 0.0879917 (W 0.0245833) | · | 🔵 fork 1.27× faster than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
