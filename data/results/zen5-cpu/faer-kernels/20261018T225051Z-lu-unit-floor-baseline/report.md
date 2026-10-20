# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `b7715c53ba75946d68a97d5655f481b198332447`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `8badcc74314c82508a8a143643fe6015832d6a5a`
- toolkit commit: `bfaeb6eef2015a04d755eeb3a581c782b8824d5a`
- measured binary SHA-256: `2decf425848a5b0706f9c20de65084822a23d659071b38b6bf7c9dea9d347e4a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T23:17:06.296515Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --families lu,solve,full_piv_lu,cholesky,gemm --shapes 32,64,96,128,256,512,1024x64,4096x256,64x1024,256x4096,256x256x256 --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label lu-unit-floor-baseline --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T225051Z-lu-unit-floor-baseline/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.27%, worst 1212.31% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 138 of 1068 engine cells exceed 5% and carry `!`; median within-process relative SD 0.65%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.0747 ± 0.00333005 (W 0.00134299) | 1.07712 ± 0.00164546 (W 0.000852198) | 1.20047 ± 0.00713844 (W 0.00255233) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.304688 ± 0.00460513 (W 0.00253343) | 0.306111 ± 0.00435511 (W 0.00576601) | 0.343169 ± 0.0014088 (W 0.00240369) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.194964 ± 0.0159868 (W 0.0354569) | 0.217435 ± 0.0168672 (W 0.0393204) | 0.183873 ± 0.00240678 (W 0.00263486) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07498 ± 0.00328994 (W 0.00117231) | 1.07801 ± 0.00194637 (W 0.00135051) | 1.20606 ± 0.00276048 (W 0.0038109) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.299608 ± 0.00103434 (W 0.00743283) | 0.309467 ± 0.00670387 (W 0.00649882) | 0.342448 ± 0.00133553 (W 0.00171454) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.21996 ± 0.0242735 (W 0.0414399) | 0.221903 ± 0.0188505 (W 0.0257433) | 0.18272 ± 0.00497905 (W 0.00151688) | · | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28378 ± 0.000230335 (W 0.00646595) | 4.28303 ± 0.00058197 (W 0.00213688) | 5.07172 ± 0.00619386 (W 0.0169698) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12577 ± 0.00225696 (W 0.00340459) | 1.12933 ± 0.00162307 (W 0.00421766) | 1.80816 ± 0.0226886 (W 0.00595621) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.604677 ± 0.00602468 (W 0.00587514) | 0.603986 ± 0.00216054 (W 0.00348228) | 0.700896 ± 0.0124937 (W 0.00331225) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28524 ± 0.00239905 (W 0.0126753) | 4.28171 ± 0.00425837 (W 0.0113993) | 5.15191 ± 0.00702304 (W 0.0217434) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12919 ± 0.00319597 (W 0.00334512) | 1.12904 ± 0.00324375 (W 0.00387873) | 1.79305 ± 0.0160039 (W 0.00439233) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.614205 ± 0.00917325 (W 0.0126296) | 0.616018 ± 0.00847908 (W 0.0125806) | 0.69168 ± 0.0101459 (W 0.0044165) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003436 ± 3.51188e-05 (W 3.09887e-05) | 0.003206 ± 3.60555e-05 (W 1.41421e-05) | 0.004188 ± 4.50925e-05 (W 3.70135e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016531 ± 5.7735e-06 (W 5.36656e-05) | 0.015038 ± 4.58258e-05 (W 3.67423e-05) | 0.016902 ± 0.000123843 (W 7.07623e-05) | 🔴 fork 1.10× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.032872 ± 0.000100898 (W 0.00010231) | 0.031178 ± 0.000214189 (W 5.73524e-05) | 0.04858 ± 0.000255148 (W 6.2915e-05) | 🔴 fork 1.05× slower than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011802 ± 0.000234592 (W 6.80088e-05) | 0.01096 ± 0.000193807 (W 0.000126796) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051105 ± 0.000457699 (W 0.000184516) | 0.046847 ± 0.000687989 (W 0.000296152) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145 ± 0.000188768 (W 0.00235572) | 0.13409 ± 0.000166433 (W 0.00181298) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008576 ± 5.03322e-05 (W 4.42741e-05) | 0.007123 ± 3.05505e-05 (W 3.62933e-05) | 0.012323 ± 9.12707e-05 (W 8.77115e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031068 ± 0.000195021 (W 9.8387e-05) | 0.026529 ± 0.000473741 (W 0.000116315) | 0.04306 ± 0.000150334 (W 0.000189679) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.076001 ± 0.000110123 (W 0.00236279) | 0.065713 ± 0.00046712 (W 0.0022766) | 0.110716 ± 0.000447729 (W 0.00232704) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009758 ± 0.000105314 (W 9.74797e-05) | 0.008325 ± 9.58662e-05 (W 8.9304e-05) | 0.012854 ± 0.000125527 (W 5.3406e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.032951 ± 0.000661528 (W 0.00113103) | 0.027321 ± 0.000185023 (W 0.000157462) | 0.043601 ± 8.2282e-05 (W 9.852e-05) | 🔴 fork 1.21× slower than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077555 ± 0.000162759 (W 0.0025034) | 0.067766 ± 0.000587718 (W 0.000151665) | 0.104415 ± 0.000351711 (W 0.00166414) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003416 ± 1.57162e-05 (W 2.24989e-05) | 0.003176 ± 3.21455e-05 (W 2.34521e-05) | 0.004228 ± 8.5049e-05 (W 4.96991e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016561 ± 4.50925e-05 (W 4.96991e-05) | 0.015028 ± 4.09919e-05 (W 5e-05) | 0.016831 ± 0.00017164 (W 4.98417e-05) | 🔴 fork 1.10× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.051416 ± 0.00226755 (W 0.00182434) | 0.060573 ± 0.00115925 (W 0.00204961) | 0.04854 ± 0.000106397 (W 0.00013233) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011702 ± 0.000288497 (W 0.00015678) | 0.01061 ± 0.000252171 (W 0.000116919) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051516 ± 0.000144915 (W 0.000236288) | 0.046587 ± 0.000376975 (W 0.000162383) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144299 ± 0.00051916 (W 0.00222989) | 0.133288 ± 0.00232125 (W 0.00240481) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008526 ± 0.000102632 (W 4.13183e-05) | 0.007254 ± 8.24035e-05 (W 5.28507e-05) | 0.012133 ± 5.7735e-05 (W 0.00012542) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031008 ± 5.91636e-05 (W 0.000245606) | 0.044804 ± 0.00340804 (W 0.00202575) | 0.04269 ± 6.7159e-05 (W 9.35644e-05) | 🔵 fork 1.44× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.075531 ± 0.00043207 (W 0.00211514) | 0.105417 ± 0.00476456 (W 0.00349705) | 0.093494 ± 0.000302523 (W 0.00157904) | 🔵 fork 1.40× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009608 ± 0.000100664 (W 6.84105e-05) | 0.008216 ± 0.000127005 (W 8.52643e-05) | 0.012714 ± 7.37111e-05 (W 5.09902e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031729 ± 0.000115717 (W 0.000236495) | 0.045464 ± 0.000624325 (W 0.00307451) | 0.043721 ± 0.000119151 (W 3.84994e-05) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077675 ± 0.00378402 (W 0.000273042) | 0.104335 ± 0.00402881 (W 0.00369337) | 0.087774 ± 0.000213378 (W 0.000230723) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003396 ± 1.47309e-05 (W 2.78604e-05) | 0.003287 ± 0.000174261 (W 4.219e-05) | 0.004198 ± 9.07377e-05 (W 4.15933e-05) | · | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016521 ± 0.000193477 (W 4.85623e-05) | 0.015309 ± 0.0010785 (W 3.48181e-05) | 0.016781 ± 6.55769e-05 (W 6.69328e-05) | 🔴 fork 1.08× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.054101 ± 0.00310948 (W 0.00301446) | 0.071083 ± 0.497486 (W 0.00133008) | 0.04823 ± 7.17031e-05 (W 0.000105262) | · | 🔴 fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.011933 ± 0.000111072 (W 7.51479e-05) | 0.010509 ± 0.000346624 (W 5.57162e-05) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051596 ± 0.000199575 (W 0.00140586) | 0.046807 ± 0.000192827 (W 0.000146561) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143993 ± 0.000775257 (W 0.00162818) | 0.133263 ± 0.0026118 (W 0.00146942) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008577 ± 5.04017e-05 (W 7.51678e-05) | 0.007163 ± 9.92321e-05 (W 6.30079e-05) | 0.012172 ± 4.17971e-05 (W 9.74679e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031189 ± 0.000151163 (W 0.00010285) | 0.053852 ± 0.00179323 (W 0.00331141) | 0.04287 ± 9.66971e-05 (W 0.000145623) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.075964 ± 0.000295532 (W 0.00188017) | 0.118701 ± 0.00547483 (W 0.00277888) | 0.090762 ± 0.00453963 (W 0.0026952) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009589 ± 6.05062e-05 (W 4.92159e-05) | 0.008506 ± 0.000159478 (W 0.000153575) | 0.012753 ± 0.000102763 (W 4.35339e-05) | 🔴 fork 1.13× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.03192 ± 3.21455e-05 (W 0.0016677) | 0.05318 ± 0.00291345 (W 0.00305114) | 0.043441 ± 6.61085e-05 (W 0.000110136) | 🔵 fork 1.67× faster than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.078198 ± 0.00493671 (W 0.00269058) | 0.118515 ± 0.00538092 (W 0.00510385) | 0.085442 ± 0.000541648 (W 0.00136689) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003326 ± 2.08167e-05 (W 2.45825e-05) | 0.003126 ± 2.3094e-05 (W 3.39116e-05) | 0.003346 ± 2.58908e-05 (W 4.76445e-05) | 🔴 fork 1.06× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016261 ± 3.25115e-05 (W 3.91152e-05) | 0.014748 ± 3.46458e-05 (W 3.63222e-05) | 0.014136 ± 7.22519e-05 (W 4.07836e-05) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.03206 ± 9.86425e-05 (W 0.000430425) | 0.030227 ± 0.000326702 (W 0.00152115) | 0.038231 ± 0.000237803 (W 4.07345e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01039 ± 1.1547e-05 (W 5.18006e-05) | 0.010429 ± 8.14453e-05 (W 0.000130802) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045795 ± 0.000560664 (W 0.000183145) | 0.046146 ± 0.000271509 (W 0.00173771) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132658 ± 0.000154306 (W 0.000395077) | 0.132107 ± 0.000541036 (W 0.00223655) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007124 ± 8.50314e-05 (W 6.06325e-05) | 0.007103 ± 6.1101e-05 (W 5.05193e-05) | 0.009849 ± 5.5109e-05 (W 0.000125675) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025858 ± 0.000111505 (W 0.00013089) | 0.025698 ± 0.000448692 (W 0.000183929) | 0.033783 ± 0.000343663 (W 0.0011394) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063057 ± 0.000404904 (W 0.0024151) | 0.063849 ± 0.000347535 (W 0.00250137) | 0.07505 ± 0.000189033 (W 0.000185556) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007945 ± 0.000103055 (W 3.96232e-05) | 0.007854 ± 5.74195e-05 (W 5.58596e-05) | 0.009948 ± 4.50925e-05 (W 2.92626e-05) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025959 ± 5.62168e-05 (W 0.000113676) | 0.025948 ± 0.000545009 (W 0.000110861) | 0.033752 ± 0.000273887 (W 0.000211664) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065212 ± 0.0002533 (W 0.00230238) | 0.065653 ± 0.000176485 (W 0.00206313) | 0.073858 ± 0.000397091 (W 0.000113394) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003306 ± 3.27159e-05 (W 2.30217e-05) | 0.003095 ± 2.09841e-05 (W 2.23607e-05) | 0.003336 ± 2.13776e-05 (W 2.58515e-05) | 🔴 fork 1.07× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01617 ± 0.00179889 (W 3.28634e-05) | 0.014707 ± 6.55769e-05 (W 3.27002e-05) | 0.014006 ± 5.85947e-05 (W 3.78153e-05) | · | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.051035 ± 0.00497781 (W 0.000727504) | 0.058429 ± 0.00116837 (W 0.00179035) | 0.038192 ± 0.000222801 (W 8.95293e-05) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.01045 ± 0.000109119 (W 6.07552e-05) | 0.01046 ± 0.000153266 (W 7.17377e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046637 ± 0.000354444 (W 0.000185553) | 0.045585 ± 0.000310725 (W 0.000191354) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131134 ± 0.00214821 (W 0.00223568) | 0.131565 ± 0.00251463 (W 0.000350996) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007063 ± 4.50925e-05 (W 2.89517e-05) | 0.007173 ± 3.05505e-05 (W 6.2276e-05) | 0.009829 ± 4.17971e-05 (W 7.93297e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025728 ± 6.02771e-05 (W 0.000182182) | 0.044022 ± 0.000553445 (W 0.00327051) | 0.033773 ± 0.000196554 (W 0.00126505) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063398 ± 0.000316314 (W 0.000226948) | 0.099365 ± 0.00227457 (W 0.00315667) | 0.074539 ± 0.000159478 (W 0.00154992) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007844 ± 8.87149e-05 (W 5.85662e-05) | 0.007774 ± 5.04017e-05 (W 5.96096e-05) | 0.009878 ± 4.96689e-05 (W 3.2362e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025908 ± 8.79223e-05 (W 0.000108214) | 0.044694 ± 0.000969169 (W 0.0010475) | 0.033663 ± 0.000204042 (W 0.000157652) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065091 ± 0.00368486 (W 0.000162429) | 0.100096 ± 0.00656369 (W 0.0026826) | 0.073738 ± 0.000401211 (W 0.000377889) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003296 ± 3.19427e-05 (W 2.47427e-05) | 0.003126 ± 0.000138924 (W 3.31708e-05) | 0.003366 ± 3.09892e-05 (W 4.47795e-05) | 🔴 fork 1.05× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01629 ± 0.000130424 (W 0.00141732) | 0.014847 ± 0.00109258 (W 2.90224e-05) | 0.013947 ± 6.5041e-05 (W 6.09196e-05) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.057958 ± 0.00044419 (W 0.00260849) | 0.070331 ± 0.00205852 (W 0.00206895) | 0.038472 ± 0.0122173 (W 0.000308601) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.51× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.0106 ± 0.000100732 (W 6.50385e-05) | 0.0105 ± 0.000343649 (W 0.000142293) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045606 ± 0.000331859 (W 0.000203417) | 0.045605 ± 0.000209956 (W 0.000114543) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131455 ± 0.00261165 (W 0.00196928) | 0.131234 ± 0.00276402 (W 0.00169953) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007073 ± 1.09697e-05 (W 4.27703e-05) | 0.007224 ± 7.50555e-05 (W 6.31047e-05) | 0.009668 ± 3.4641e-05 (W 6.87023e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025818 ± 0.000263319 (W 0.000163677) | 0.052808 ± 0.00183166 (W 0.00321288) | 0.033472 ± 0.000171235 (W 8.81431e-05) | 🔵 fork 2.05× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063148 ± 0.00188764 (W 0.00154437) | 0.119052 ± 0.00300968 (W 0.00563047) | 0.073877 ± 0.000298572 (W 0.000123488) | 🔵 fork 1.89× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007814 ± 2.52389e-05 (W 0.000102768) | 0.008055 ± 0.000185023 (W 7.44533e-05) | 0.009818 ± 4.2194e-05 (W 3.50885e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025849 ± 0.000216865 (W 0.000166332) | 0.053159 ± 0.00149762 (W 0.00102944) | 0.033372 ± 0.000131036 (W 5.14782e-05) | 🔵 fork 2.06× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065544 ± 0.00476654 (W 0.000251461) | 0.119386 ± 0.00594815 (W 0.00636792) | 0.073577 ± 0.000381294 (W 0.000322676) | 🔵 fork 1.82× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005229 ± 6.16468e-05 (W 2.8674e-05) | 0.00518 ± 1.73205e-05 (W 4.82701e-05) | 0.008976 ± 0.000108214 (W 6.20991e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030477 ± 0.000195533 (W 9.85759e-05) | 0.030376 ± 0.000233232 (W 0.000146316) | 0.050514 ± 0.00025064 (W 0.000192123) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084267 ± 0.000865769 (W 0.000161417) | 0.083926 ± 0.000305517 (W 0.00039269) | 0.13951 ± 0.00114782 (W 0.00150093) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017854 ± 0.000158745 (W 5.9028e-05) | 0.01578 ± 0.000187538 (W 9.71298e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097893 ± 3.61985e-05 (W 0.00179318) | 0.092392 ± 0.000165227 (W 0.00161934) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.321249 ± 0.000757192 (W 0.00317318) | 0.308285 ± 0.00158552 (W 0.00230694) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013235 ± 0.000106209 (W 4.18115e-05) | 0.011321 ± 0.000186559 (W 5.44812e-05) | 0.019817 ± 2.5697e-05 (W 6.26897e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058288 ± 0.000586675 (W 0.000146203) | 0.052758 ± 0.000211732 (W 0.000177018) | 0.09693 ± 0.00068276 (W 0.000139392) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.190996 ± 0.000310989 (W 0.002428) | 0.17712 ± 0.0017615 (W 0.00234844) | 0.300219 ± 0.00239688 (W 0.00275544) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014568 ± 9.0813e-05 (W 0.000104524) | 0.012423 ± 5.56776e-05 (W 7.04003e-05) | 0.020268 ± 2.08167e-05 (W 0.000107564) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060613 ± 0.000125033 (W 9.498e-05) | 0.054742 ± 0.000461325 (W 0.000129515) | 0.094506 ± 0.000444014 (W 9.30306e-05) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.20338 ± 0.00298649 (W 0.00275143) | 0.188992 ± 0.000926738 (W 0.00256454) | 0.252511 ± 0.000108167 (W 0.00181902) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00526 ± 1e-05 (W 1.22474e-05) | 0.00518 ± 2.70247e-05 (W 4.25464e-05) | 0.008927 ± 0.0001905 (W 2.68328e-05) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030587 ± 0.000263319 (W 0.000121673) | 0.030396 ± 0.00028075 (W 0.000137198) | 0.051105 ± 0.000393684 (W 0.000210022) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102882 ± 0.000834188 (W 0.00151416) | 0.102922 ± 0.00370278 (W 0.0031254) | 0.138038 ± 0.000320366 (W 0.00162216) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017934 ± 0.000111267 (W 7.6872e-05) | 0.015989 ± 0.0002155 (W 7.39067e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097702 ± 6.61589e-05 (W 0.000440438) | 0.092152 ± 0.000372693 (W 0.00130911) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319145 ± 0.000893408 (W 0.00204248) | 0.308394 ± 0.00112594 (W 0.00246241) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013375 ± 0.000129152 (W 7.01734e-05) | 0.011221 ± 0.0001205 (W 8.24512e-05) | 0.019977 ± 0.000130908 (W 7.36695e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.49× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058248 ± 0.000120085 (W 0.00015602) | 0.053459 ± 0.000604804 (W 0.000333305) | 0.095979 ± 0.000508332 (W 0.000388753) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.191016 ± 0.000511235 (W 0.00229787) | 0.192369 ± 0.00142591 (W 0.00268238) | 0.263261 ± 0.0114516 (W 0.00414695) | · | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014687 ± 8.0829e-05 (W 8.75511e-05) | 0.012473 ± 6.55744e-05 (W 5.37894e-05) | 0.020418 ± 0.000107858 (W 5.72713e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060724 ± 0.000394424 (W 0.00150322) | 0.054651 ± 0.000133418 (W 0.000297148) | 0.093454 ± 0.00030654 (W 0.00137988) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.202979 ± 0.000543252 (W 0.00425121) | 0.207096 ± 0.00292796 (W 0.00645023) | 0.237072 ± 0.000127954 (W 0.00170987) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 3.25115e-05 (W 0.000118748) | 0.00525 ± 9.16515e-05 (W 4.49444e-05) | 0.008727 ± 8.66045e-05 (W 9.99965e-05) | · | 🔵 fork 1.66× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030348 ± 3.80832e-05 (W 0.000112974) | 0.030237 ± 8.93141e-05 (W 7.49947e-05) | 0.051686 ± 0.000600477 (W 0.00108226) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.112279 ± 0.00714044 (W 0.00483385) | 0.111728 ± 0.000653518 (W 0.0030258) | 0.138889 ± 0.001938 (W 0.00145581) | · | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017773 ± 4.04145e-05 (W 0.00011078) | 0.01579 ± 0.0001095 (W 9.85809e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.098013 ± 0.000280554 (W 0.000553905) | 0.092593 ± 0.000455931 (W 0.000463543) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319726 ± 0.00210451 (W 0.00350253) | 0.306331 ± 0.00234105 (W 0.00287882) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013175 ± 0.000122312 (W 3.08221e-05) | 0.011212 ± 5.60446e-05 (W 6.44996e-05) | 0.019817 ± 8.95005e-05 (W 5.76194e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058259 ± 0.000114037 (W 0.000195352) | 0.052458 ± 0.000106532 (W 0.00179806) | 0.096109 ± 0.000868796 (W 0.000937617) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.190775 ± 0.00275178 (W 0.00221687) | 0.206094 ± 0.0021999 (W 0.00399297) | 0.244887 ± 0.0126026 (W 0.00302857) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014728 ± 5.03322e-05 (W 8.37156e-05) | 0.012504 ± 7.78481e-05 (W 5.69148e-05) | 0.020328 ± 0.000140119 (W 9.31837e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060875 ± 0.000457186 (W 0.0016186) | 0.055025 ± 0.000507476 (W 0.000327682) | 0.093194 ± 4.56545e-05 (W 0.000336105) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.203485 ± 0.000666458 (W 0.00310439) | 0.218544 ± 0.00150923 (W 0.00423355) | 0.236539 ± 0.000336262 (W 0.00184745) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005249 ± 4.51331e-05 (W 3.19374e-05) | 0.00512 ± 2.12211e-05 (W 4.19082e-05) | 0.007925 ± 4.16333e-05 (W 6.9857e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030217 ± 1.57162e-05 (W 4.50033e-05) | 0.030046 ± 0.00035609 (W 0.000169382) | 0.043461 ± 0.000753387 (W 0.000148174) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083406 ± 0.000310559 (W 8.10938e-05) | 0.083015 ± 0.000879006 (W 0.000119416) | 0.127157 ± 0.00170436 (W 0.00139004) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01598 ± 0.000199826 (W 0.00011068) | 0.015799 ± 0.000146289 (W 6.7855e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090248 ± 0.000652228 (W 0.0017994) | 0.090478 ± 0.000161868 (W 0.00185789) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.306671 ± 0.000991868 (W 0.00215351) | 0.304037 ± 0.000816941 (W 0.00347316) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011411 ± 0.000215964 (W 4.5607e-05) | 0.011361 ± 0.000106927 (W 5.35724e-05) | 0.017493 ± 5.56507e-05 (W 3.3216e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050765 ± 0.00053514 (W 0.000159835) | 0.051115 ± 0.000445096 (W 0.000127083) | 0.08613 ± 0.000146186 (W 0.000265596) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174365 ± 0.000396515 (W 0.00238834) | 0.174095 ± 0.000571234 (W 0.00240349) | 0.226032 ± 0.00153489 (W 0.00159257) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012433 ± 0.000200899 (W 7.8613e-05) | 0.012453 ± 4.98698e-05 (W 3.74192e-05) | 0.017272 ± 4.07063e-05 (W 5.74996e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053279 ± 0.000290057 (W 0.000111803) | 0.053129 ± 0.000373047 (W 0.000167539) | 0.083465 ± 3.09892e-05 (W 0.000218019) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.186978 ± 0.00224757 (W 0.00268387) | 0.186107 ± 0.00119268 (W 0.00319334) | 0.21995 ± 0.000636303 (W 0.00129937) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005229 ± 3.10966e-05 (W 1.86091e-05) | 0.005199 ± 4.59021e-05 (W 2.25655e-05) | 0.008085 ± 9.29157e-05 (W 7.09225e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030246 ± 0.000291212 (W 7.22793e-05) | 0.030076 ± 0.000170098 (W 8.77684e-05) | 0.043441 ± 0.000316118 (W 0.000101387) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103242 ± 0.00050346 (W 0.00124989) | 0.103843 ± 0.001516 (W 0.00170258) | 0.124632 ± 0.000518743 (W 0.0016513) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015959 ± 8.50706e-05 (W 6.79581e-05) | 0.015899 ± 0.000221157 (W 6.03183e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090289 ± 0.000138156 (W 0.0017729) | 0.089877 ± 0.000199525 (W 0.00171954) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.305299 ± 0.00176992 (W 0.00246861) | 0.302484 ± 0.00143811 (W 0.00255682) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011371 ± 5.19615e-05 (W 8.55815e-05) | 0.011341 ± 6.55744e-05 (W 7.42577e-05) | 0.017492 ± 0.000125061 (W 0.000101288) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050975 ± 0.000423521 (W 0.000176625) | 0.051135 ± 0.000215948 (W 0.000342668) | 0.08586 ± 0.000348704 (W 0.00126762) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.175076 ± 0.00115487 (W 0.0019321) | 0.190776 ± 0.000894849 (W 0.00315333) | 0.224689 ± 0.00132931 (W 0.00119523) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012403 ± 2.3094e-05 (W 0.000151981) | 0.012483 ± 7.03586e-05 (W 5.79759e-05) | 0.017372 ± 0.000145258 (W 4.58279e-05) | · | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053409 ± 3.72872e-05 (W 0.000142356) | 0.053099 ± 0.000256321 (W 0.000162257) | 0.082915 ± 0.000136847 (W 0.00187798) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.191197 ± 0.00273963 (W 0.00261392) | 0.204421 ± 0.000757523 (W 0.0036875) | 0.218755 ± 0.000596739 (W 0.00183165) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00527 ± 5.56776e-05 (W 2.81816e-05) | 0.005179 ± 2.09841e-05 (W 2.91548e-05) | 0.007954 ± 0.000104644 (W 6.66206e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029996 ± 8.79223e-05 (W 8.67756e-05) | 0.029926 ± 0.000158745 (W 4.15716e-05) | 0.04316 ± 0.000276019 (W 0.000116363) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111938 ± 0.000430233 (W 0.00285117) | 0.111782 ± 0.000214805 (W 0.00324528) | 0.125354 ± 0.000932713 (W 0.00153574) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01585 ± 0.000176918 (W 8.7426e-05) | 0.01586 ± 0.000110274 (W 6.37966e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090188 ± 0.000373364 (W 0.00233434) | 0.090339 ± 0.000672645 (W 0.0019993) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.30573 ± 0.00123518 (W 0.00209401) | 0.305229 ± 0.00107665 (W 0.00179175) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011311 ± 4.72582e-05 (W 5.84577e-05) | 0.011241 ± 7.82326e-05 (W 4.93994e-05) | 0.017593 ± 0.000174443 (W 6.43288e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051175 ± 0.000188595 (W 0.000287879) | 0.050876 ± 0.000130679 (W 0.000159484) | 0.085439 ± 0.000259107 (W 0.0012138) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.176369 ± 0.00148205 (W 0.00306883) | 0.200795 ± 0.00156808 (W 0.00290366) | 0.22544 ± 0.000865916 (W 0.002271) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012563 ± 4.0501e-05 (W 0.00015365) | 0.012584 ± 1.18462e-05 (W 0.000129055) | 0.017272 ± 4.62637e-05 (W 4.71731e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053261 ± 0.000275175 (W 0.000202214) | 0.052868 ± 0.000388547 (W 0.000141846) | 0.082955 ± 0.000344627 (W 0.001507) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.186006 ± 0.000676039 (W 0.00269066) | 0.213685 ± 0.000361502 (W 0.00542894) | 0.218575 ± 0.000314233 (W 0.00168505) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070253 ± 0.000115245 (W 0.000558674) | 0.067047 ± 0.00251955 (W 0.000534141) | 0.114564 ± 0.00137412 (W 0.0016361) | · | 🔵 fork 1.63× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.39691 ± 0.00514772 (W 0.00319417) | 0.387562 ± 0.0095365 (W 0.00262917) | 0.642737 ± 0.002799 (W 0.00487277) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.5225 ± 0.00389658 (W 0.00285892) | 2.52435 ± 0.0560991 (W 0.00231611) | 4.04356 ± 0.0200892 (W 0.0198492) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.310979 ± 0.00222594 (W 0.00281066) | 0.313725 ± 0.00243925 (W 0.00299749) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70023 ± 0.00328199 (W 0.00530424) | 2.76238 ± 0.00733348 (W 0.0117013) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.6846 ± 0.0571725 (W 0.0431088) | 22.3311 ± 0.065971 (W 0.0383392) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134641 ± 0.0190613 (W 0.00186392) | 0.138779 ± 0.016393 (W 0.00140117) | 0.170127 ± 0.0184343 (W 0.00164977) | · | 🔵 fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.982391 ± 0.11506 (W 0.00187021) | 1.03876 ± 0.00606046 (W 0.00324741) | 0.973986 ± 0.136275 (W 0.00425994) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.60545 ± 0.00955869 (W 0.0180187) | 7.19755 ± 0.0479471 (W 0.0232932) | 6.96707 ± 0.0415115 (W 0.0186991) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134655 ± 0.00112533 (W 0.00167349) | 0.136558 ± 0.000796515 (W 0.00257861) | 0.169832 ± 0.00120142 (W 0.000940181) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.747466 ± 0.00621026 (W 0.00273923) | 0.802055 ± 0.00384142 (W 0.00199922) | 0.967803 ± 0.00158781 (W 0.00185473) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.54015 ± 0.0320723 (W 0.0164858) | 7.12534 ± 0.0610764 (W 0.0281195) | 6.01622 ± 0.0549601 (W 0.0169827) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.088786 ± 0.00167918 (W 0.00287972) | 0.105657 ± 0.0028947 (W 0.00405009) | 0.115348 ± 0.000217401 (W 0.00157284) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.404003 ± 0.0159263 (W 0.0306989) | 0.432677 ± 0.0204763 (W 0.019745) | 0.409755 ± 0.00390565 (W 0.00474433) | 🔵 fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.55976 ± 0.0314451 (W 0.0203491) | 1.70556 ± 0.0515542 (W 0.0329029) | 1.94262 ± 0.0117356 (W 0.0098533) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.310948 ± 0.00177244 (W 0.00139319) | 0.313044 ± 0.000988701 (W 0.00267187) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70569 ± 0.00497925 (W 0.00922927) | 2.76789 ± 0.0118261 (W 0.0112542) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.592 ± 0.156019 (W 0.172764) | 18.1686 ± 0.0935495 (W 0.130561) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.133459 ± 0.017466 (W 0.00032252) | 0.211173 ± 0.021338 (W 0.00703319) | 0.151482 ± 0.012803 (W 0.00237887) | 🔵 fork 1.58× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.992971 ± 0.118973 (W 0.00575329) | 1.1928 ± 0.0186035 (W 0.0278045) | 0.380008 ± 0.118337 (W 0.00304631) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 2.61× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.8068 ± 0.03097 (W 0.100344) | 5.62805 ± 0.0335702 (W 0.0686037) | 2.61978 ± 0.0361198 (W 0.00849259) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.83× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133348 ± 0.000540363 (W 0.00187117) | 0.209346 ± 0.00272601 (W 0.00497124) | 0.150089 ± 0.000487632 (W 0.00121448) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.758183 ± 0.0105621 (W 0.00215134) | 0.930941 ± 0.0291963 (W 0.0228397) | 0.367034 ± 0.00164813 (W 0.00181519) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.70751 ± 0.0673896 (W 0.0686079) | 5.40434 ± 0.0405674 (W 0.0541692) | 1.79985 ± 0.0233812 (W 0.00363743) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 2.62× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.094398 ± 0.00253168 (W 0.00428994) | 0.102604 ± 0.000734606 (W 0.00205411) | 0.115004 ± 0.00038423 (W 0.000446095) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.40197 ± 0.0106743 (W 0.0142641) | 0.441174 ± 0.008536 (W 0.0165119) | 0.360432 ± 0.00262995 (W 0.00287293) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.52543 ± 0.0183823 (W 0.0374255) | 1.63686 ± 0.0346199 (W 0.0233573) | 1.46079 ± 0.0181948 (W 0.00894654) | 🔵 fork 1.07× faster than `faer-upstream` | · |  |
| `full_piv_lu/n128/b1` | 0.308054 ± 0.000987381 (W 0.00231522) | 0.31146 ± 3.7027e-05 (W 0.00235267) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70449 ± 0.0195759 (W 0.0126818) | 2.77829 ± 0.0118388 (W 0.0106472) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.5158 ± 0.459455 (W 0.119176) | 18.0187 ± 0.175996 (W 0.13979) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.165479 ± 0.0174557 (W 0.00215822) | 0.221313 ± 0.0147735 (W 0.00486657) | 0.191346 ± 0.0250211 (W 0.00341586) | 🔵 fork 1.34× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.993147 ± 0.134859 (W 0.00691884) | 1.30039 ± 0.0127917 (W 0.0399282) | 0.345454 ± 0.16161 (W 0.00337198) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 2.87× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.60128 ± 0.0905532 (W 0.103094) | 5.74619 ± 0.0386432 (W 0.798342) | 2.35142 ± 0.0385574 (W 0.00910342) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.13451 ± 0.00116475 (W 0.000229773) | 0.215728 ± 0.00234696 (W 0.00601166) | 0.146146 ± 0.000730051 (W 0.00132385) | 🔵 fork 1.60× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.761029 ± 0.00416472 (W 0.00521944) | 0.950296 ± 0.0122739 (W 0.0228988) | 0.333973 ± 0.00298124 (W 0.00404192) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.63972 ± 0.0515129 (W 0.0986035) | 5.62698 ± 0.0807085 (W 0.0595347) | 1.31316 ± 0.0231489 (W 0.00428447) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 3.53× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063328 ± 0.000139861 (W 8.2694e-05) | 0.060274 ± 0.00233184 (W 0.000100846) | 0.094315 ± 0.00225351 (W 0.000563479) | · | 🔵 fork 1.49× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.32194 ± 0.00142763 (W 0.00249086) | 0.315738 ± 0.00503294 (W 0.00262631) | 0.451051 ± 0.00232045 (W 0.00303003) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06678 ± 0.00110524 (W 0.00351655) | 2.06925 ± 0.00334117 (W 0.00190188) | 3.33637 ± 0.0133794 (W 0.0264319) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289009 ± 0.00145784 (W 0.00173397) | 0.291732 ± 0.00133455 (W 0.00230232) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6209 ± 0.00977179 (W 0.0111506) | 2.62883 ± 0.00386862 (W 0.00863127) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.1131 ± 0.015843 (W 0.0552822) | 21.2074 ± 0.0495028 (W 0.0519413) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145241 ± 0.00159274 (W 0.00134651) | 0.145877 ± 0.000506296 (W 0.00111778) | 0.133239 ± 0.000157068 (W 0.00160411) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.694545 ± 0.12179 (W 0.00368427) | 0.698262 ± 0.120449 (W 0.0038597) | 0.820565 ± 0.00345501 (W 0.00233213) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.1051 ± 0.0332489 (W 0.0120805) | 6.10603 ± 0.00748133 (W 0.0104024) | 5.21557 ± 0.031458 (W 0.0120433) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112433 ± 0.000109777 (W 0.000985958) | 0.112049 ± 0.00121031 (W 0.00147506) | 0.133639 ± 0.00097354 (W 0.00155181) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.662755 ± 0.0028382 (W 0.00375274) | 0.662505 ± 0.00116515 (W 0.00245151) | 0.812208 ± 0.00121937 (W 0.00211305) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.05698 ± 0.0133507 (W 0.0229757) | 6.06784 ± 0.0187894 (W 0.0086121) | 5.24371 ± 0.0464866 (W 0.0148265) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.081574 ± 0.00326126 (W 0.00238362) | 0.097372 ± 0.00598356 (W 0.00615141) | 0.091453 ± 0.00217337 (W 0.000791746) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.336366 ± 0.00787365 (W 0.0233951) | 0.355863 ± 0.00954929 (W 0.0264921) | 0.238642 ± 0.00208383 (W 0.00409662) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.11955 ± 0.0150401 (W 0.0262884) | 1.22146 ± 0.0098401 (W 0.0280946) | 1.40282 ± 0.0140888 (W 0.00901336) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289409 ± 0.00177622 (W 0.00250952) | 0.290001 ± 0.000502578 (W 0.0021271) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62075 ± 0.00858353 (W 0.0118926) | 2.62864 ± 0.00287718 (W 0.00924498) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9101 ± 0.127803 (W 0.0270482) | 16.9221 ± 0.0918878 (W 0.151694) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.14489 ± 0.000324817 (W 0.00280574) | 0.219469 ± 0.000412901 (W 0.0100997) | 0.132677 ± 0.000703335 (W 0.00120945) | 🔵 fork 1.51× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.705565 ± 0.114692 (W 0.00564522) | 0.834195 ± 0.126101 (W 0.024) | 0.326779 ± 0.00294062 (W 0.00215587) | · | 🔴 fork 2.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.26226 ± 0.0662692 (W 0.05273) | 4.61931 ± 0.0195268 (W 0.0642638) | 1.65027 ± 0.0127645 (W 0.0038762) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 2.58× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111598 ± 0.000358023 (W 0.00128802) | 0.18218 ± 0.00342012 (W 0.00812479) | 0.131866 ± 0.000604037 (W 0.00174351) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.673824 ± 0.00560551 (W 0.00353047) | 0.774244 ± 0.0205666 (W 0.0190281) | 0.312673 ± 0.00167884 (W 0.00263493) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.20475 ± 0.0487292 (W 0.0491192) | 4.38868 ± 0.0190688 (W 0.0349582) | 1.64385 ± 0.0200979 (W 0.00408483) | · | 🔴 fork 2.56× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.087455 ± 0.000372213 (W 0.00354018) | 0.095851 ± 0.00223327 (W 0.00230975) | 0.091831 ± 0.000203436 (W 0.00111337) | 🔵 fork 1.10× faster than `faer-upstream` | · |  |
| `cholesky/n256/b1` | 0.342368 ± 0.00280513 (W 0.0226669) | 0.403061 ± 0.00379462 (W 0.0293942) | 0.194403 ± 0.00125959 (W 0.00566888) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 1.76× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 1.07028 ± 0.0170419 (W 0.029655) | 1.20399 ± 0.00878713 (W 0.0144346) | 0.949751 ± 0.00340481 (W 0.00961821) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.288084 ± 0.0016482 (W 0.00309156) | 0.292382 ± 0.00259949 (W 0.00232697) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62584 ± 0.0170527 (W 0.0081971) | 2.63379 ± 0.00858368 (W 0.00787631) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.7894 ± 0.119397 (W 0.100079) | 16.9595 ± 0.196559 (W 0.116419) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.116207 ± 0.0174556 (W 0.000877756) | 0.197098 ± 0.0292487 (W 0.00678724) | 0.133352 ± 0.000934991 (W 0.0016327) | 🔵 fork 1.70× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.709563 ± 0.120813 (W 0.00385032) | 0.925835 ± 0.122439 (W 0.0280202) | 0.317582 ± 0.000804566 (W 0.003147) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 2.23× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.16535 ± 0.0402961 (W 0.0664) | 4.72789 ± 0.0270235 (W 0.0863836) | 1.22873 ± 0.00651504 (W 0.00777029) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 3.39× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112429 ± 0.000921219 (W 0.000236183) | 0.190189 ± 0.00252999 (W 0.00798029) | 0.131278 ± 0.00114018 (W 0.00232074) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.680205 ± 0.00357717 (W 0.00389786) | 0.824378 ± 0.0266224 (W 0.0307505) | 0.298845 ± 0.000700997 (W 0.0029756) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.06613 ± 0.0409949 (W 0.0538718) | 4.55014 ± 0.0333399 (W 0.0700892) | 1.20501 ± 0.00340624 (W 0.0045728) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 3.37× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188031 ± 0.000383015 (W 0.00141134) | 0.18759 ± 4.33013e-05 (W 0.00158463) | 0.478065 ± 0.00309356 (W 0.00352292) | · | 🔵 fork 2.54× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.25377 ± 0.0182176 (W 0.00421389) | 1.25076 ± 0.0192117 (W 0.00277532) | 1.86183 ± 0.0151415 (W 0.00802367) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.90598 ± 0.0128789 (W 0.00813177) | 7.92595 ± 0.079072 (W 0.0216129) | 11.3865 ± 0.0191829 (W 0.0513646) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.77617 ± 0.00758026 (W 0.00486104) | 0.773712 ± 0.00790142 (W 0.00654247) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.92774 ± 0.0493802 (W 0.0177081) | 5.9998 ± 0.0235056 (W 0.0171661) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 43.3538 ± 0.124733 (W 0.0985924) | 43.2247 ± 0.128907 (W 0.0723319) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.325667 ± 0.00202931 (W 0.00244715) | 0.329895 ± 0.00183878 (W 0.00290922) | 0.504771 ± 0.00360707 (W 0.00261969) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.13143 ± 0.00244448 (W 0.00619117) | 2.20607 ± 0.006153 (W 0.00423459) | 3.31496 ± 0.00533319 (W 0.0112518) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.5424 ± 0.0532962 (W 0.0329818) | 17.3931 ± 0.0333528 (W 0.0316994) | 23.1805 ± 0.0483765 (W 0.0512015) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.323162 ± 0.000421901 (W 0.00308863) | 0.326097 ± 0.00122397 (W 0.00326229) | 0.489166 ± 0.001157 (W 0.00306445) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.06169 ± 0.00447568 (W 0.00409407) | 2.1427 ± 0.0025298 (W 0.00335826) | 2.83288 ± 0.0294336 (W 0.00991027) | · | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 18.078 ± 0.0783939 (W 0.0603722) | 17.9157 ± 0.0205632 (W 0.0331778) | 18.8588 ± 0.0423968 (W 0.153141) | · | · |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189128 ± 0.000612151 (W 0.00350235) | 0.202277 ± 0.002604 (W 0.0039211) | 0.479514 ± 0.000522523 (W 0.00348733) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.54× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.852332 ± 0.00505499 (W 0.0101729) | 0.869785 ± 0.00788593 (W 0.0135701) | 0.797236 ± 0.0102468 (W 0.00867227) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.37719 ± 0.00335288 (W 0.0258381) | 3.41248 ± 0.011711 (W 0.0172499) | 3.65989 ± 0.0351485 (W 0.00655728) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.774545 ± 0.00686664 (W 0.00681886) | 0.768794 ± 0.00508473 (W 0.00666844) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.89788 ± 0.0226906 (W 0.0262657) | 5.97372 ± 0.0353285 (W 0.0266059) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.7957 ± 0.143546 (W 0.101775) | 29.6375 ± 0.0601516 (W 0.362809) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.325366 ± 0.00237248 (W 0.00230209) | 0.343319 ± 0.00317325 (W 0.00480392) | 0.482412 ± 0.000949365 (W 0.00228935) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.1377 ± 0.00863389 (W 0.0108604) | 1.70312 ± 0.00899387 (W 0.0136003) | 1.01472 ± 0.00578896 (W 0.00351413) | 🔴 fork 1.26× slower than `faer-upstream` | 🔴 fork 2.11× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.9177 ± 0.0316045 (W 0.0533115) | 9.96885 ± 0.066403 (W 0.045689) | 7.54869 ± 0.0575626 (W 0.037226) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.323191 ± 0.000994451 (W 0.00240493) | 0.339792 ± 0.00250413 (W 0.00602416) | 0.469537 ± 0.0014377 (W 0.00216629) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.07976 ± 0.00189907 (W 0.00633678) | 1.53719 ± 0.00655167 (W 0.0143185) | 0.894962 ± 0.00261718 (W 0.00267031) | 🔴 fork 1.35× slower than `faer-upstream` | 🔴 fork 2.32× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 11.5545 ± 0.186124 (W 0.13245) | 10.3808 ± 0.0550853 (W 0.0520983) | 5.60948 ± 0.012619 (W 0.011377) | 🔴 fork 1.11× slower than `faer-upstream` | 🔴 fork 2.06× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.195745 ± 0.000253746 (W 0.00220222) | 0.213568 ± 0.000658098 (W 0.00468051) | 0.477552 ± 0.00136497 (W 0.00247541) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 2.44× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.826451 ± 0.00909304 (W 0.0141606) | 0.866315 ± 0.016362 (W 0.0198634) | 0.658859 ± 0.00164751 (W 0.00453392) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.77972 ± 0.0107556 (W 0.0161189) | 2.85359 ± 0.00739208 (W 0.029194) | 2.30053 ± 0.0410008 (W 0.0141995) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.777369 ± 0.00650751 (W 0.00572845) | 0.773742 ± 0.00617927 (W 0.00503613) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.92469 ± 0.0184536 (W 0.0241628) | 6.0459 ± 0.0347861 (W 0.0898279) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.1732 ± 0.161303 (W 0.190217) | 28.0028 ± 0.226781 (W 0.171544) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.324503 ± 0.00160182 (W 0.00190326) | 0.368146 ± 0.00610938 (W 0.00910634) | 0.486337 ± 0.00104724 (W 0.00274494) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.14521 ± 0.028078 (W 0.0157051) | 1.69803 ± 0.0160342 (W 0.0200998) | 0.69847 ± 0.00321309 (W 0.00608589) | 🔴 fork 1.26× slower than `faer-upstream` | 🔴 fork 3.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.90486 ± 0.0853912 (W 0.0582546) | 8.7815 ± 0.0593675 (W 0.0265054) | 5.05167 ± 0.0139294 (W 0.0385319) | 🔴 fork 1.13× slower than `faer-upstream` | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.323232 ± 0.000847036 (W 0.00241052) | 0.362374 ± 0.00302138 (W 0.00268318) | 0.47201 ± 0.00663041 (W 0.00301222) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.09552 ± 0.00997762 (W 0.00594951) | 1.52807 ± 0.0167846 (W 0.0164847) | 0.667374 ± 0.00348634 (W 0.00454235) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 3.14× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.4155 ± 0.0113275 (W 0.0651981) | 9.25487 ± 0.0282663 (W 0.0733613) | 3.4432 ± 0.00960263 (W 0.0139833) | 🔴 fork 1.13× slower than `faer-upstream` | 🔴 fork 3.02× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174576 ± 0.000420552 (W 0.00115904) | 0.174565 ± 0.000583922 (W 0.00146149) | 0.410715 ± 0.00116861 (W 0.00238107) | · | 🔵 fork 2.35× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13106 ± 0.00119704 (W 0.0024049) | 1.13059 ± 0.00303559 (W 0.00309178) | 1.60273 ± 0.00455284 (W 0.0051622) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.52611 ± 0.0226971 (W 0.0205219) | 7.52366 ± 0.00808091 (W 0.0309616) | 10.5893 ± 0.103032 (W 0.0348489) | · | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.749769 ± 0.00777527 (W 0.00524209) | 0.750591 ± 0.00491636 (W 0.00422022) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.77865 ± 0.0397745 (W 0.0125498) | 5.73566 ± 0.0185613 (W 0.00929492) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 42.3159 ± 0.172076 (W 0.123442) | 42.2087 ± 0.142719 (W 0.147589) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.297303 ± 0.000809254 (W 0.00182818) | 0.29552 ± 0.00207713 (W 0.00192994) | 0.459647 ± 0.00257378 (W 0.00280386) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.99662 ± 0.0180872 (W 0.00139438) | 1.99605 ± 0.00439525 (W 0.00215601) | 3.22059 ± 0.00911139 (W 0.0108376) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.4137 ± 0.0280232 (W 0.0574529) | 16.4224 ± 0.0435602 (W 0.039033) | 20.3016 ± 0.0817864 (W 0.0397311) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.293225 ± 0.00148103 (W 0.00181738) | 0.292335 ± 0.000236348 (W 0.0023356) | 0.446142 ± 0.00243506 (W 0.00199642) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93893 ± 0.00154493 (W 0.00235472) | 1.93502 ± 0.00460388 (W 0.00700338) | 2.67071 ± 0.00137745 (W 0.00707785) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 16.9274 ± 0.0543153 (W 0.0236354) | 17.0386 ± 0.112741 (W 0.180644) | 17.5297 ± 0.0204128 (W 0.0262931) | · | · |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176099 ± 0.00636119 (W 0.00420294) | 0.188226 ± 0.00498728 (W 0.00479641) | 0.409654 ± 0.00298364 (W 0.00216553) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.33× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.765968 ± 0.00272644 (W 0.0105052) | 0.781348 ± 0.00470932 (W 0.0165556) | 0.600098 ± 0.00974391 (W 0.00951214) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.0249 ± 0.0277847 (W 0.0218762) | 3.0572 ± 0.0119002 (W 0.0244499) | 3.21887 ± 0.0154502 (W 0.0126522) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.746321 ± 0.00664668 (W 0.0062375) | 0.746051 ± 0.00828853 (W 0.00450508) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.76624 ± 0.00875906 (W 0.0295429) | 5.74282 ± 0.0760329 (W 0.0115869) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.7257 ± 0.0636112 (W 0.119106) | 28.6313 ± 0.0597733 (W 0.310309) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296192 ± 0.00158183 (W 0.0021186) | 0.314987 ± 0.00374789 (W 0.00656127) | 0.458996 ± 0.00149894 (W 0.00308953) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.01783 ± 0.00973579 (W 0.0126965) | 1.47987 ± 0.00955134 (W 0.0149923) | 0.971 ± 0.00466033 (W 0.00224857) | 🔴 fork 1.36× slower than `faer-upstream` | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.72495 ± 0.0535714 (W 0.070401) | 9.06105 ± 0.0217973 (W 0.0412304) | 5.77541 ± 0.0139283 (W 0.0116694) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292082 ± 0.000290452 (W 0.0023552) | 0.308414 ± 0.000690199 (W 0.00298518) | 0.444769 ± 0.00581678 (W 0.00266736) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.95124 ± 0.000516199 (W 0.00259922) | 1.34773 ± 0.00994592 (W 0.0238421) | 0.859502 ± 0.00102268 (W 0.00175363) | 🔴 fork 1.45× slower than `faer-upstream` | 🔴 fork 2.27× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.3512 ± 0.0224155 (W 0.124577) | 9.49803 ± 0.0247749 (W 0.0634144) | 5.32928 ± 0.00822294 (W 0.00611851) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.94× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.183212 ± 0.0012157 (W 0.00322546) | 0.201095 ± 0.000107852 (W 0.00284584) | 0.409002 ± 0.00351696 (W 0.0046008) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 2.23× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.735669 ± 0.0185138 (W 0.0220235) | 0.789111 ± 0.00600825 (W 0.0163271) | 0.464136 ± 0.00362546 (W 0.00280163) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.42876 ± 0.0123365 (W 0.0308125) | 2.49531 ± 0.0109448 (W 0.0178777) | 1.87648 ± 0.0213205 (W 0.016852) | · | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.746702 ± 0.00568678 (W 0.00660441) | 0.737515 ± 0.00298164 (W 0.00606978) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.76809 ± 0.0281369 (W 0.0208939) | 5.77146 ± 0.0244676 (W 0.0392907) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.0544 ± 0.0804796 (W 0.135905) | 27.0276 ± 0.0967492 (W 0.125071) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296011 ± 0.00115481 (W 0.00272792) | 0.337117 ± 0.00170187 (W 0.00483045) | 0.458324 ± 0.00414404 (W 0.00281717) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.03899 ± 0.00998449 (W 0.0270981) | 1.48339 ± 0.012322 (W 0.021078) | 0.683454 ± 0.00198131 (W 0.00569408) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 2.98× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.68287 ± 0.0415687 (W 0.0388062) | 8.07092 ± 0.0545148 (W 1.16447) | 3.46765 ± 0.0057784 (W 0.0123992) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 2.50× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.293244 ± 0.00061844 (W 0.00160892) | 0.329314 ± 0.00191889 (W 0.00436505) | 0.445821 ± 0.0025002 (W 0.00197646) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.98016 ± 0.00969387 (W 0.0171801) | 1.31035 ± 0.0136466 (W 0.0236637) | 0.650509 ± 0.00472796 (W 0.00400062) | 🔴 fork 1.51× slower than `faer-upstream` | 🔴 fork 3.04× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.12677 ± 0.0577296 (W 0.0783891) | 8.41008 ± 0.0383934 (W 0.0612017) | 3.29484 ± 0.0105625 (W 0.00879415) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.77× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814317 ± 0.0408998 (W 0.00394668) | 0.819006 ± 0.0768132 (W 0.00357342) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 49.6196 ± 23.4829 (W 0.0702308) | 53.61 ± 23.4483 (W 0.293607) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.485565 ± 0.139549 (W 0.0111975) | 0.473022 ± 0.0877608 (W 0.00617165) | 0.658878 ± 0.00208064 (W 0.00247606) | · | 🔵 fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.4724 ± 1.79329 (W 0.0911555) | 18.9935 ± 1.70164 (W 0.0489593) | 18.0193 ± 5.15418 (W 0.127051) | 🔵 fork 1.23× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.813938 ± 0.00262581 (W 0.00220696) | 0.817464 ± 0.00576672 (W 0.00573383) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.8986 ± 0.0816331 (W 0.288152) | 26.1429 ± 0.917159 (W 1.03302) | - | 🔵 fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.495074 ± 0.00345761 (W 0.0128006) | 0.501074 ± 0.0122752 (W 0.00631978) | 0.529898 ± 0.117937 (W 0.00374613) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.48657 ± 0.097308 (W 0.171258) | 13.0595 ± 0.0098137 (W 0.0361308) | 13.342 ± 1.85928 (W 0.0195242) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.813434 ± 0.00120445 (W 0.00283503) | 0.818604 ± 0.00370878 (W 0.00827233) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 16.0079 ± 0.199703 (W 0.0684989) | 19.7219 ± 0.456613 (W 0.144816) | - | 🔵 fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.484604 ± 0.0115041 (W 0.0053436) | 0.520511 ± 0.00537413 (W 0.00966222) | 0.597113 ± 0.166283 (W 0.00228775) | 🔵 fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.80269 ± 0.0531114 (W 0.0755837) | 12.2508 ± 0.026584 (W 0.0919324) | 4.09815 ± 1.89392 (W 0.0473961) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 2.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.733336 ± 0.0340195 (W 0.00978329) | 0.735471 ± 0.0349893 (W 0.00342365) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 47.4176 ± 23.2323 (W 0.33225) | 47.5179 ± 23.4951 (W 0.207158) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.385909 ± 0.0243548 (W 0.00294629) | 0.384647 ± 0.0237407 (W 0.00390184) | 0.288428 ± 0.0155794 (W 0.00331429) | · | 🔴 fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 13.2773 ± 1.41836 (W 0.0298819) | 13.2757 ± 1.43334 (W 0.0462676) | 11.8135 ± 1.25674 (W 0.0236735) | · | · | `!` between-start range over 5% |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.732422 ± 0.00205334 (W 0.0016332) | 0.744708 ± 0.00439669 (W 0.00828736) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6651 ± 0.1044 (W 0.117644) | 17.692 ± 0.109665 (W 0.0792046) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.403621 ± 0.0100031 (W 0.0160493) | 0.432326 ± 0.00462801 (W 0.00708812) | 0.28619 ± 0.000794774 (W 0.00212494) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.30729 ± 0.0151963 (W 0.0274728) | 7.38369 ± 0.0104559 (W 0.0259149) | 11.5883 ± 0.0308667 (W 0.0336313) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730818 ± 0.00280978 (W 0.00213535) | 0.741519 ± 0.00609147 (W 0.00802728) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.7917 ± 0.141376 (W 0.117215) | 13.8584 ± 0.093895 (W 0.0872486) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.393993 ± 0.00460319 (W 0.00320591) | 0.446883 ± 0.00257898 (W 0.00794021) | 0.28642 ± 0.000459568 (W 0.00286662) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.68849 ± 0.0350915 (W 0.0215627) | 6.69725 ± 0.082474 (W 0.02731) | 3.15655 ± 0.0468992 (W 0.00734853) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79933 ± 0.418918 (W 0.00818842) | 1.81896 ± 0.333879 (W 0.00519229) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 149.435 ± 24.309 (W 2.01807) | 155.566 ± 25.2268 (W 0.673755) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 1.00973 ± 0.218784 (W 0.00199006) | 1.01368 ± 0.153328 (W 0.00556738) | 1.19196 ± 0.299171 (W 0.00376072) | · | · | `!` between-start range over 5% |
| `lu/4096x256/b1` | 46.8115 ± 4.07641 (W 0.101785) | 53.7901 ± 3.60837 (W 0.109408) | 56.3526 ± 10.0391 (W 0.149433) | 🔵 fork 1.15× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79986 ± 0.00103984 (W 0.00815296) | 1.82799 ± 0.0267075 (W 0.00521424) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.4533 ± 0.754765 (W 0.875781) | 64.9703 ± 1.65249 (W 1.00713) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.880611 ± 0.0183904 (W 0.0129198) | 0.812474 ± 0.00324878 (W 0.0150541) | 1.09577 ± 0.00442032 (W 0.00152195) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.8944 ± 0.247683 (W 0.192449) | 29.7547 ± 0.0601612 (W 0.0881794) | 52.5837 ± 3.67171 (W 0.082616) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.30× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78707 ± 0.00631539 (W 0.00358) | 1.80032 ± 0.0268807 (W 0.00167384) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.8572 ± 0.189284 (W 0.632721) | 41.668 ± 0.288773 (W 0.51839) | - | 🔵 fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.85919 ± 0.00126238 (W 0.00775354) | 0.843702 ± 0.0215161 (W 0.00677344) | 1.08562 ± 0.139716 (W 0.00453644) | · | 🔵 fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 19.1881 ± 0.131137 (W 0.183256) | 25.8117 ± 0.0536606 (W 0.0450529) | 57.5917 ± 3.06919 (W 0.172918) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 3.00× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66502 ± 0.268529 (W 0.00356283) | 1.67723 ± 0.278493 (W 0.0042716) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 143.352 ± 24.2408 (W 0.688156) | 144.793 ± 23.9199 (W 1.51253) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.877155 ± 0.175576 (W 0.00310314) | 0.878728 ± 0.174977 (W 0.00243487) | 1.0927 ± 0.240506 (W 0.00316673) | · | · | `!` between-start range over 5% |
| `lu/4096x256/b1` | 41.7827 ± 3.11498 (W 0.131766) | 41.7768 ± 2.97018 (W 0.0881083) | 51.1267 ± 2.59252 (W 0.0929137) | · | 🔵 fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66853 ± 0.00547002 (W 0.0029361) | 1.66377 ± 0.00563744 (W 0.00119694) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.7002 ± 0.383935 (W 0.797783) | 52.7542 ± 0.263471 (W 0.959553) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.759807 ± 0.0141191 (W 0.0108684) | 0.712574 ± 0.00782689 (W 0.0138308) | 1.06852 ± 0.00346118 (W 0.00324508) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.4794 ± 0.0641847 (W 0.0652883) | 17.5055 ± 0.00975391 (W 0.0816305) | 49.6703 ± 0.272174 (W 0.0879823) | · | 🔵 fork 2.84× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66256 ± 0.00374569 (W 0.00340402) | 1.67163 ± 0.00937071 (W 0.00616919) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.4036 ± 0.523489 (W 0.642288) | 29.4452 ± 0.85131 (W 0.604896) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.739084 ± 0.0149658 (W 0.00884005) | 0.696288 ± 0.00885606 (W 0.0122278) | 1.06787 ± 0.0114396 (W 0.00313868) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.5103 ± 0.0409207 (W 0.0396105) | 13.6026 ± 0.0112832 (W 0.0441961) | 49.7029 ± 0.227687 (W 0.153378) | · | 🔵 fork 3.68× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 73.6808 ± 0.234474 (W 0.261405) | 77.0457 ± 1.06358 (W 0.379464) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.11232 ± 0.0100123 (W 0.003331) | 1.25026 ± 0.0121558 (W 0.00481348) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 15.9696 ± 0.131059 (W 0.0287659) | 18.117 ± 0.0615257 (W 0.0429862) | 74.4382 ± 2.09518 (W 2.30757) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 4.66× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.392572 ± 0.001195 (W 0.00307295) | 0.511554 ± 0.00242066 (W 0.00236908) | 0.925114 ± 0.136575 (W 0.00515625) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.2139 ± 0.397458 (W 0.28026) | 39.5022 ± 0.250657 (W 0.592754) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.11745 ± 0.0112754 (W 0.0019273) | 1.2375 ± 0.0268054 (W 0.00447415) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.2092 ± 0.213256 (W 0.0522725) | 9.36597 ± 0.123514 (W 0.0369893) | 10.204 ± 0.211195 (W 0.0937104) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.233911 ± 0.00431127 (W 0.00566516) | 0.387732 ± 0.019704 (W 0.00502959) | 0.28972 ± 0.00439788 (W 0.0035335) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.929 ± 0.0678683 (W 0.208853) | 35.4827 ± 0.54481 (W 0.1757) | - | 🔵 fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12589 ± 0.0156299 (W 0.010986) | 1.2459 ± 0.00978013 (W 0.0042723) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 6.06846 ± 0.0955556 (W 0.0476709) | 7.98475 ± 0.109901 (W 0.0515162) | 6.82849 ± 1.30508 (W 0.0701556) | 🔵 fork 1.32× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.211564 ± 0.00268004 (W 0.00270989) | 0.361163 ± 0.0151348 (W 0.0240342) | 0.171002 ± 0.000282438 (W 0.00176141) | 🔵 fork 1.71× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 71.697 ± 0.520859 (W 0.148826) | 71.6557 ± 0.947923 (W 0.357551) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04785 ± 0.0023399 (W 0.00254242) | 1.05056 ± 0.00433652 (W 0.00561199) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2651 ± 0.0660139 (W 0.0339366) | 13.2621 ± 0.0459052 (W 0.0398601) | 210.389 ± 0.0292322 (W 0.0517293) | · | 🔵 fork 15.86× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.311301 ± 0.00037684 (W 0.00255668) | 0.312122 ± 0.00235629 (W 0.00235427) | 3.13308 ± 0.00597231 (W 0.00286465) | · | 🔵 fork 10.06× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.0834 ± 0.464988 (W 0.174062) | 35.1167 ± 0.214461 (W 0.184655) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04324 ± 0.00542793 (W 0.00449395) | 1.04793 ± 0.0119956 (W 0.0038204) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.37054 ± 0.00529136 (W 0.0181544) | 4.65276 ± 0.00897791 (W 0.0229244) | 5.3433 ± 0.0563671 (W 0.0188403) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.138708 ± 0.00219808 (W 0.00768285) | 0.172795 ± 0.00243877 (W 0.0028735) | 0.231351 ± 0.00180763 (W 0.00281679) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.4214 ± 0.184123 (W 0.0504204) | 30.2067 ± 0.145106 (W 0.138132) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.0459 ± 0.00661069 (W 0.00350022) | 1.04575 ± 0.0054352 (W 0.00450899) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.90102 ± 0.0128732 (W 0.0255487) | 3.33104 ± 0.0464498 (W 0.121023) | 3.16718 ± 0.030283 (W 0.00716162) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.116216 ± 0.00132468 (W 0.0031615) | 0.159618 ± 0.0070541 (W 0.0084172) | 0.134673 ± 0.00173322 (W 0.00166848) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 226.576 ± 3.94597 (W 0.810056) | 226.189 ± 3.9454 (W 0.437046) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.4572 ± 0.015914 (W 0.00525825) | 2.53142 ± 0.0200985 (W 0.0100832) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.4677 ± 0.070822 (W 0.0656571) | 46.9065 ± 0.19578 (W 0.0534724) | 88.0583 ± 0.230867 (W 0.285509) | · | 🔵 fork 1.90× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 1.02288 ± 0.00818501 (W 0.00666027) | 1.06157 ± 0.0259863 (W 0.00298498) | 2.33321 ± 0.00376358 (W 0.00736884) | · | 🔵 fork 2.28× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 97.0389 ± 2.53347 (W 0.641191) | 97.1346 ± 2.61758 (W 0.55105) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.37477 ± 0.0414249 (W 0.0149131) | 2.51185 ± 0.0253165 (W 0.00893458) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.0131 ± 0.0515178 (W 0.144394) | 18.0364 ± 0.0550534 (W 0.10634) | 29.1912 ± 3.15316 (W 0.120095) | · | 🔵 fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.443757 ± 0.00106943 (W 0.0131987) | 0.48819 ± 0.00229789 (W 0.00340614) | 0.6384 ± 0.00295923 (W 0.00222991) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.2375 ± 0.660019 (W 0.407496) | 70.7633 ± 0.745402 (W 0.371564) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.44127 ± 0.0105342 (W 0.009306) | 2.49882 ± 0.0381766 (W 0.012561) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.5234 ± 0.223556 (W 0.144373) | 12.512 ± 0.206253 (W 0.0656368) | 13.6754 ± 3.05909 (W 0.0303114) | 🔴 fork 1.08× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.361791 ± 0.00495743 (W 0.00465757) | 0.411177 ± 0.0252404 (W 0.00348286) | 0.452673 ± 0.178322 (W 0.0017482) | 🔵 fork 1.14× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 223.224 ± 3.56858 (W 0.540199) | 221.729 ± 4.03368 (W 0.60008) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.30478 ± 0.0122852 (W 0.00687558) | 2.2815 ± 0.0163998 (W 0.00861571) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.1388 ± 0.149064 (W 0.0625985) | 42.0699 ± 0.159411 (W 0.0532652) | 73.5899 ± 0.174147 (W 0.076109) | · | 🔵 fork 1.75× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.896651 ± 0.0016299 (W 0.00210736) | 0.89578 ± 0.00720727 (W 0.0018899) | 2.12699 ± 0.00657765 (W 0.00457563) | · | 🔵 fork 2.37× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.4732 ± 3.41456 (W 0.517042) | 92.2109 ± 3.48646 (W 0.684894) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.25633 ± 0.0294631 (W 0.0121642) | 2.25973 ± 0.00537132 (W 0.0128509) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.4265 ± 0.169091 (W 0.330566) | 13.9007 ± 0.0501646 (W 0.0858886) | 20.5747 ± 0.0217944 (W 0.0164907) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.321058 ± 0.00178847 (W 0.002248) | 0.323049 ± 0.000810763 (W 0.00371836) | 0.593887 ± 0.00792026 (W 0.00268002) | · | 🔵 fork 1.85× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 65.3703 ± 0.861981 (W 0.444) | 66.6373 ± 0.936283 (W 1.00986) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.2996 ± 0.0160352 (W 0.006592) | 2.30374 ± 0.0199341 (W 0.0109606) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.66459 ± 0.0344819 (W 0.0735046) | 8.30782 ± 0.0871549 (W 0.0663878) | 11.2819 ± 0.0462236 (W 0.0264636) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.24115 ± 0.00184383 (W 0.00273068) | 0.242146 ± 0.00449079 (W 0.00301375) | 0.413431 ± 0.00284522 (W 0.00162615) | · | 🔵 fork 1.71× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
