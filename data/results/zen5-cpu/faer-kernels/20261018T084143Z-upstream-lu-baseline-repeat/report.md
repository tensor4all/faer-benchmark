# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `2240b076a03011b2f128988fecf2967c4b1dda1c`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9baafe6afe1b468b81b7b13f72ed64aa0da6678a`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `9d14689ab8ea005412a100a46a6bd7b0301062ca0d4bd04b7880f38eb8b79ec6`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T09:09:19.134098Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --families lu,solve,full_piv_lu,cholesky,gemm --shapes 32,64,96,128,256,512,1024x64,4096x256,64x1024,256x4096,256x256x256 --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label upstream-lu-baseline-repeat --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T084143Z-upstream-lu-baseline-repeat/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.21%, worst 78.93% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 104 of 1068 engine cells exceed 5% and carry `!`; median within-process relative SD 0.65%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/256x256x256/b1` | 1.07159 ± 0.00363161 (W 0.00179624) | 1.07143 ± 0.000216505 (W 0.00400893) | 1.19665 ± 0.0035739 (W 0.00324225) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.301032 ± 0.00493783 (W 0.00831418) | 0.302876 ± 0.00157964 (W 0.00617319) | 0.344476 ± 0.00188197 (W 0.00241713) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.195395 ± 0.00905241 (W 0.0253658) | 0.248074 ± 0.0267729 (W 0.0387544) | 0.183683 ± 0.00228085 (W 0.00206986) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07239 ± 0.00272319 (W 0.00349962) | 1.07247 ± 0.0061475 (W 0.000920666) | 1.20461 ± 0.00114989 (W 0.00194725) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.308176 ± 0.0048996 (W 0.00946877) | 0.305361 ± 0.00611459 (W 0.0082541) | 0.342971 ± 0.00172527 (W 0.00179417) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.197479 ± 0.00910892 (W 0.0385543) | 0.23512 ± 0.016367 (W 0.0217561) | 0.182221 ± 0.00200788 (W 0.0015079) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28288 ± 0.00978504 (W 0.00419911) | 4.28533 ± 0.0078283 (W 0.00628586) | 5.07071 ± 0.0106809 (W 0.0188262) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12726 ± 0.00238199 (W 0.00391962) | 1.12529 ± 0.00277808 (W 0.00418515) | 1.8218 ± 0.0230872 (W 0.00351682) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.604779 ± 0.000938345 (W 0.0125205) | 0.606544 ± 0.00561717 (W 0.0121935) | 0.701111 ± 0.00725307 (W 0.00260891) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28222 ± 0.0141717 (W 0.0051828) | 4.28989 ± 0.0134508 (W 0.00778683) | 5.14109 ± 0.00974228 (W 0.0212967) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12421 ± 0.0044071 (W 0.00395495) | 1.12716 ± 0.004097 (W 0.00394541) | 1.79197 ± 0.0213637 (W 0.00747064) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.621853 ± 0.0115109 (W 0.00935873) | 0.617511 ± 0.00628855 (W 0.011909) | 0.687064 ± 0.0113606 (W 0.00429141) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003516 ± 2.5697e-05 (W 3.65964e-05) | 0.003256 ± 3.60555e-05 (W 2.36685e-05) | 0.004208 ± 5.89661e-05 (W 2.30217e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01661 ± 9.54481e-05 (W 5.49545e-05) | 0.014707 ± 0.00160515 (W 6.6553e-05) | 0.016762 ± 1.70392e-05 (W 5.4775e-05) | 🔴 fork 1.13× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.032802 ± 9.57305e-05 (W 0.00113461) | 0.030347 ± 0.00169215 (W 0.000103876) | 0.04822 ± 0.000264309 (W 9.90414e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.012102 ± 0.000272416 (W 4.39352e-05) | 0.010629 ± 0.000168613 (W 5.80457e-05) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051323 ± 0.000165633 (W 8.32184e-05) | 0.046815 ± 0.000195633 (W 9.67585e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144202 ± 2.00333e-05 (W 0.00231344) | 0.13362 ± 0.000844708 (W 0.00225428) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008486 ± 7.23418e-05 (W 5.89067e-05) | 0.007384 ± 0.000191941 (W 5.54094e-05) | 0.012152 ± 6.94286e-05 (W 8.98348e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031038 ± 0.000381754 (W 0.000195254) | 0.026438 ± 8.96158e-05 (W 0.000151074) | 0.043021 ± 0.00015494 (W 0.000142321) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075932 ± 0.000635558 (W 0.00249499) | 0.065282 ± 0.000222109 (W 0.00228331) | 0.110226 ± 0.00094764 (W 0.00114641) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009467 ± 2.5632e-05 (W 9.92033e-05) | 0.008125 ± 7.93725e-05 (W 0.000131085) | 0.012843 ± 2.6839e-05 (W 6.92329e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.03163 ± 0.000231574 (W 0.000181561) | 0.02721 ± 0.00029023 (W 0.000109683) | 0.043882 ± 0.000196505 (W 9.07193e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077565 ± 0.00158379 (W 0.0024109) | 0.068495 ± 0.000730516 (W 0.00195923) | 0.103949 ± 0.000387575 (W 0.00156057) | 🔴 fork 1.13× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003526 ± 2.00083e-05 (W 4.63702e-05) | 0.003236 ± 0.000188813 (W 2.56574e-05) | 0.004248 ± 6.1101e-05 (W 7.19027e-05) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016461 ± 0.000206108 (W 3.58371e-05) | 0.015008 ± 0.00229892 (W 4.32435e-05) | 0.016791 ± 0.000167413 (W 8.44233e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050505 ± 0.00201988 (W 0.00286086) | 0.067106 ± 0.00284466 (W 0.00377353) | 0.048227 ± 6.0542e-05 (W 0.000104288) | 🔵 fork 1.33× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.012022 ± 0.000469285 (W 0.000148492) | 0.010609 ± 0.000114282 (W 5.54076e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051386 ± 0.000432462 (W 0.000559997) | 0.046777 ± 0.0002271 (W 0.000338944) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144924 ± 0.000717047 (W 0.00244157) | 0.134071 ± 0.000521178 (W 0.00246747) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008516 ± 8.14453e-05 (W 7.98699e-05) | 0.007253 ± 3.09892e-05 (W 0.000163753) | 0.012162 ± 4.95681e-05 (W 8.91628e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031126 ± 0.000294741 (W 0.000149861) | 0.04398 ± 0.00183824 (W 0.00150116) | 0.042719 ± 0.000159795 (W 0.00134335) | 🔵 fork 1.41× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.076002 ± 0.000300375 (W 0.00209786) | 0.097758 ± 0.00242108 (W 0.00377966) | 0.094055 ± 0.000690797 (W 0.00302978) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009478 ± 8.34286e-05 (W 3.49285e-05) | 0.008276 ± 0.000152895 (W 0.000135688) | 0.012734 ± 5.25389e-05 (W 4.57515e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031639 ± 0.000443812 (W 0.000177489) | 0.041838 ± 0.00199411 (W 0.00305212) | 0.043539 ± 0.000307526 (W 0.000100186) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077575 ± 0.000126848 (W 0.00259462) | 0.103684 ± 0.00255941 (W 0.00227886) | 0.087439 ± 0.000152004 (W 0.000226097) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003497 ± 0.000162543 (W 2.55988e-05) | 0.003236 ± 2.08167e-05 (W 4.03733e-05) | 0.004228 ± 4.3589e-05 (W 5.27257e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0167 ± 0.0020002 (W 5.0043e-05) | 0.015038 ± 0.000140678 (W 5.35724e-05) | 0.016761 ± 0.000140607 (W 5.83378e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.05866 ± 0.000607668 (W 0.00280094) | 0.069641 ± 0.000658034 (W 0.00297258) | 0.04836 ± 0.0002984 (W 0.000110509) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011932 ± 0.000114282 (W 4.21331e-05) | 0.01066 ± 0.000255408 (W 5.04975e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051096 ± 0.000131925 (W 0.000959954) | 0.046788 ± 0.000247015 (W 0.000162986) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143882 ± 0.00312996 (W 0.00290447) | 0.133369 ± 0.00281182 (W 0.000311501) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008576 ± 0.00010116 (W 6.22093e-05) | 0.007494 ± 0.000199249 (W 0.000173739) | 0.012273 ± 4.41626e-05 (W 9.30177e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030807 ± 1.9e-05 (W 0.000157367) | 0.052718 ± 0.00387819 (W 0.00340466) | 0.04279 ± 0.000141507 (W 0.000107104) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.075718 ± 0.000165321 (W 0.000334351) | 0.116478 ± 0.0041711 (W 0.00446046) | 0.086141 ± 0.00251731 (W 0.00160067) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009387 ± 2.09841e-05 (W 6.14003e-05) | 0.008166 ± 0.000255807 (W 0.000167611) | 0.012754 ± 5.62168e-05 (W 4.0598e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031439 ± 0.00029896 (W 0.000253756) | 0.05343 ± 0.000783014 (W 0.00354373) | 0.043642 ± 0.000145349 (W 0.000151064) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.071464 ± 0.00364058 (W 0.000328004) | 0.112911 ± 0.00702006 (W 0.00491783) | 0.08538 ± 3.87427e-05 (W 0.000316082) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003357 ± 5.04017e-05 (W 2.5499e-05) | 0.003036 ± 0.000171561 (W 2.77705e-05) | 0.003336 ± 5.50757e-06 (W 2.07364e-05) | 🔴 fork 1.11× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0163 ± 0.000393027 (W 2.96648e-05) | 0.014737 ± 0.00146852 (W 7.81038e-05) | 0.014047 ± 0.000140429 (W 4.83353e-05) | · | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.03178 ± 0.00017198 (W 6.77886e-05) | 0.029975 ± 0.0026592 (W 0.000108385) | 0.037951 ± 0.00032639 (W 7.4162e-05) | · | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.010449 ± 5.18684e-05 (W 7.00021e-05) | 0.010559 ± 0.00010724 (W 4.76445e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046244 ± 0.000151596 (W 0.000121687) | 0.046016 ± 0.000199377 (W 0.00137161) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.13217 ± 0.000234668 (W 0.00252917) | 0.131586 ± 0.000940683 (W 0.00251625) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007073 ± 6.35085e-05 (W 4.35798e-05) | 0.007043 ± 5.62168e-05 (W 4.14729e-05) | 0.009748 ± 8.02081e-05 (W 0.000116324) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025598 ± 0.000276155 (W 0.000254402) | 0.026068 ± 0.000330137 (W 0.000163998) | 0.033934 ± 8.13286e-05 (W 0.00010063) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063238 ± 0.000303507 (W 0.00213896) | 0.062978 ± 0.000541721 (W 0.00223421) | 0.074355 ± 7.50022e-05 (W 0.00162502) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007764 ± 8.96679e-05 (W 6.45081e-05) | 0.007915 ± 7.02377e-05 (W 4.50699e-05) | 0.009868 ± 2.88675e-05 (W 5.72477e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025907 ± 0.000167663 (W 5.67124e-05) | 0.026209 ± 0.000260097 (W 0.000133463) | 0.033903 ± 0.000194933 (W 7.73305e-05) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065402 ± 0.00161456 (W 0.00225194) | 0.06627 ± 0.000494658 (W 0.00241711) | 0.073788 ± 0.000286514 (W 0.000163007) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003356 ± 2.64575e-05 (W 5.23479e-05) | 0.003146 ± 0.000329222 (W 4.1028e-05) | 0.003286 ± 1.52753e-05 (W 3.28634e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016169 ± 0.00018273 (W 2.44949e-05) | 0.014697 ± 0.00205663 (W 5.58238e-05) | 0.014135 ± 0.000249754 (W 0.00112647) | · | 🔴 fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.04946 ± 0.000334787 (W 0.00251523) | 0.064418 ± 0.00350666 (W 0.00566697) | 0.038261 ± 1.1547e-06 (W 0.000982664) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010469 ± 6.1101e-05 (W 5.30208e-05) | 0.01055 ± 0.00012268 (W 4.00037e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046246 ± 0.000234159 (W 0.000232557) | 0.046056 ± 0.000271271 (W 0.000168034) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131947 ± 0.000782885 (W 0.00257853) | 0.132407 ± 0.00059606 (W 0.00217815) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007033 ± 9.75551e-05 (W 5.69579e-05) | 0.007053 ± 7.86787e-05 (W 4.34316e-05) | 0.009728 ± 9.32577e-05 (W 9.03881e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025596 ± 0.000319825 (W 0.00017318) | 0.045432 ± 0.00161105 (W 0.00404517) | 0.033501 ± 0.000160855 (W 0.000103537) | 🔵 fork 1.77× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063445 ± 5.003e-05 (W 0.00232273) | 0.098534 ± 0.00108225 (W 0.00324086) | 0.07474 ± 0.000175995 (W 0.00170749) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007714 ± 8.99463e-05 (W 3.67451e-05) | 0.007864 ± 0.000105532 (W 5.31977e-05) | 0.009909 ± 9.54481e-05 (W 6.92835e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025968 ± 0.0003105 (W 0.000177257) | 0.045002 ± 0.000841271 (W 0.0030426) | 0.033352 ± 0.000260832 (W 6.26099e-05) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065292 ± 0.000288488 (W 0.00243894) | 0.102291 ± 0.00227869 (W 0.00338784) | 0.073534 ± 0.000152533 (W 0.000168102) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003316 ± 0.000211369 (W 2.9853e-05) | 0.003066 ± 1.1547e-05 (W 3.20936e-05) | 0.003356 ± 1.95021e-05 (W 2.77903e-05) | 🔴 fork 1.08× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016329 ± 0.00163678 (W 5.10813e-05) | 0.014738 ± 0.00017131 (W 4.63681e-05) | 0.013936 ± 0.000134288 (W 4.24264e-05) | 🔴 fork 1.11× slower than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056856 ± 0.00082862 (W 0.00337338) | 0.068585 ± 0.00241363 (W 0.00124837) | 0.038019 ± 0.000136044 (W 9.83362e-05) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.50× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.01047 ± 0.000156771 (W 5.66683e-05) | 0.01057 ± 0.000106616 (W 6.75367e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046286 ± 0.000349589 (W 0.000300875) | 0.045836 ± 0.000227394 (W 0.00178237) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.127638 ± 0.00216868 (W 0.000567674) | 0.126947 ± 0.00306858 (W 0.000639516) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007063 ± 8.62168e-05 (W 4.56651e-05) | 0.006963 ± 3.9879e-05 (W 4.50466e-05) | 0.009718 ± 3e-05 (W 8.08041e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025939 ± 0.000331566 (W 0.000231759) | 0.052208 ± 0.000372484 (W 0.00259723) | 0.033401 ± 4.95681e-05 (W 0.000154024) | 🔵 fork 2.01× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.05907 ± 0.00269674 (W 0.000370027) | 0.117424 ± 0.00412151 (W 0.00284968) | 0.073788 ± 0.000142356 (W 0.00156686) | 🔵 fork 1.99× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007684 ± 3.45977e-05 (W 3.80039e-05) | 0.007855 ± 0.000249969 (W 4.59151e-05) | 0.009848 ± 5.9808e-05 (W 5.74569e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026049 ± 0.000283339 (W 0.000250865) | 0.051587 ± 0.00215304 (W 0.00292444) | 0.033563 ± 0.000172259 (W 0.000117686) | 🔵 fork 1.98× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.05906 ± 0.00388953 (W 0.000195215) | 0.109835 ± 0.00402213 (W 0.00502022) | 0.073528 ± 8.40972e-05 (W 0.000114644) | 🔵 fork 1.86× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00524 ± 2.00083e-05 (W 3.24376e-05) | 0.005149 ± 2.88675e-05 (W 1.41527e-05) | 0.008846 ± 0.000120625 (W 3.42053e-05) | · | 🔵 fork 1.69× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030285 ± 0.000301975 (W 0.00146682) | 0.030325 ± 0.000204745 (W 8.36254e-05) | 0.050735 ± 0.000348942 (W 0.000364055) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084313 ± 0.000481217 (W 0.00154238) | 0.083852 ± 0.000286931 (W 0.000356841) | 0.138913 ± 0.000648087 (W 0.00134166) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017732 ± 0.000165016 (W 0.000101706) | 0.015949 ± 0.000133422 (W 6.32084e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097362 ± 0.000661002 (W 0.000431784) | 0.092273 ± 0.000378171 (W 0.000405294) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.318786 ± 0.00218621 (W 0.00277637) | 0.306052 ± 0.000786166 (W 0.00435745) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013104 ± 7.76745e-05 (W 8.01873e-05) | 0.011181 ± 3.5171e-05 (W 0.000116401) | 0.019847 ± 5.74195e-05 (W 8.06616e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057878 ± 7.7861e-05 (W 0.000156461) | 0.052718 ± 0.000233397 (W 0.000455596) | 0.096756 ± 0.000636539 (W 0.001432) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.192109 ± 0.00149114 (W 0.00192958) | 0.17624 ± 0.000686761 (W 0.00199659) | 0.29965 ± 0.00147803 (W 0.00375257) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014517 ± 2.08167e-05 (W 6.8558e-05) | 0.012433 ± 0.000158219 (W 5.21651e-05) | 0.020236 ± 4.59021e-05 (W 6.17916e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059949 ± 0.000133553 (W 0.00118135) | 0.054409 ± 0.000281645 (W 0.000164366) | 0.094367 ± 9.75551e-05 (W 0.000188275) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.204012 ± 0.00159912 (W 0.00334688) | 0.190536 ± 0.000959842 (W 0.00263671) | 0.252191 ± 7.8239e-05 (W 0.0021863) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00522 ± 2.08167e-05 (W 3.42826e-05) | 0.00516 ± 6.02246e-05 (W 3.74727e-05) | 0.008977 ± 4.00042e-05 (W 3.89397e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029966 ± 0.000337328 (W 0.000153008) | 0.030116 ± 0.000442834 (W 8.35464e-05) | 0.051303 ± 0.000384813 (W 0.000316829) | · | 🔵 fork 1.71× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102672 ± 0.00400681 (W 0.00199392) | 0.102763 ± 0.000873615 (W 0.00056591) | 0.138439 ± 3.86825e-05 (W 0.00126467) | · | 🔵 fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017873 ± 0.000203062 (W 6.49554e-05) | 0.01595 ± 0.000117053 (W 7.66368e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096781 ± 0.000737344 (W 0.00150818) | 0.091982 ± 0.000338651 (W 0.000480095) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.321081 ± 0.00075574 (W 0.00290866) | 0.308152 ± 0.000366435 (W 0.00250979) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013103 ± 0.000159701 (W 0.000105557) | 0.011141 ± 7.84241e-05 (W 7.29383e-05) | 0.019897 ± 6.65833e-05 (W 9.93479e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058326 ± 0.000215644 (W 8.6373e-05) | 0.052609 ± 0.000350667 (W 0.000234975) | 0.095418 ± 0.000232595 (W 0.000246502) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.191368 ± 0.001886 (W 0.00249102) | 0.193673 ± 0.00288092 (W 0.00225243) | 0.265564 ± 0.0154507 (W 0.00622583) | · | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014477 ± 0.000146277 (W 8.69379e-05) | 0.012543 ± 0.00015885 (W 8.27659e-05) | 0.020228 ± 2.36714e-05 (W 8.12404e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060363 ± 0.000306523 (W 0.000106289) | 0.055043 ± 0.000559653 (W 0.00118356) | 0.092809 ± 0.000147846 (W 0.00117593) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.206165 ± 0.00372645 (W 0.00267437) | 0.204402 ± 0.00154793 (W 0.00306653) | 0.236731 ± 0.000551909 (W 0.00192566) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 1.1547e-05 (W 3.38127e-05) | 0.005179 ± 3.4356e-05 (W 1.81439e-05) | 0.009017 ± 0.000162235 (W 6.32456e-05) | · | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030177 ± 0.000175034 (W 7.74597e-05) | 0.030416 ± 0.0001455 (W 0.000105931) | 0.051697 ± 0.000620281 (W 0.00144638) | · | 🔵 fork 1.71× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111689 ± 0.000298005 (W 0.00282254) | 0.111248 ± 0.000742928 (W 0.00315012) | 0.140482 ± 0.000256434 (W 0.00181975) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.018063 ± 0.0001105 (W 0.000106378) | 0.015859 ± 0.000145204 (W 0.000246409) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097472 ± 0.000257209 (W 0.00163904) | 0.091892 ± 3.32916e-05 (W 0.00135705) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.316913 ± 0.000922455 (W 0.00327138) | 0.306319 ± 0.000861483 (W 0.00259997) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013185 ± 9.59184e-05 (W 8.5557e-05) | 0.011281 ± 0.000226775 (W 0.000160088) | 0.019877 ± 7.05715e-05 (W 0.000112736) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058236 ± 7.25465e-05 (W 0.00144497) | 0.052856 ± 0.000310189 (W 0.000371127) | 0.095799 ± 0.000121657 (W 0.00142783) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.192431 ± 0.000723588 (W 0.00233062) | 0.204383 ± 0.00492143 (W 0.00623807) | 0.243615 ± 0.0155126 (W 0.00196119) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.014396 ± 0.000170608 (W 3.06137e-05) | 0.012443 ± 6.45523e-05 (W 6.13783e-05) | 0.020308 ± 4.46132e-05 (W 7.70065e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060363 ± 0.000451705 (W 0.000256621) | 0.054389 ± 0.000376144 (W 0.000190553) | 0.093475 ± 0.000476869 (W 0.000534416) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.201867 ± 0.00259461 (W 0.00264095) | 0.216956 ± 0.00125416 (W 0.00370298) | 0.236563 ± 0.000500501 (W 0.00115431) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005189 ± 3.00056e-05 (W 2.65387e-05) | 0.005139 ± 5.68624e-05 (W 3.19734e-05) | 0.007995 ± 8.0829e-05 (W 6.41732e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029994 ± 0.000304392 (W 0.000106734) | 0.029734 ± 0.00040641 (W 4.5653e-05) | 0.044483 ± 0.000519062 (W 0.000174726) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083496 ± 0.000192281 (W 0.000158668) | 0.083131 ± 0.00313953 (W 0.000114181) | 0.124743 ± 0.000311327 (W 0.00138999) | · | 🔵 fork 1.49× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.015829 ± 0.000170823 (W 4.84593e-05) | 0.015929 ± 1.57162e-05 (W 0.000109395) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090194 ± 0.000423331 (W 0.000298542) | 0.090585 ± 0.000355678 (W 0.00181036) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.302957 ± 0.00114418 (W 0.00231931) | 0.305696 ± 0.00159716 (W 0.00222481) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011351 ± 8.07279e-05 (W 5.531e-05) | 0.011251 ± 0.000132666 (W 7.04982e-05) | 0.017432 ± 9.50438e-06 (W 0.00113851) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050823 ± 0.000229059 (W 0.000111823) | 0.051296 ± 0.000968132 (W 0.000442673) | 0.086061 ± 0.000106679 (W 0.000273308) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.177722 ± 0.00281906 (W 0.00236468) | 0.174106 ± 0.00166938 (W 0.00247152) | 0.225682 ± 0.000451668 (W 0.00158115) | · | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012523 ± 7.0713e-05 (W 0.000119442) | 0.012483 ± 0.000121698 (W 0.000121849) | 0.017323 ± 0.000108969 (W 7.06845e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052949 ± 0.000326378 (W 6.22093e-05) | 0.053146 ± 0.000531011 (W 0.000160101) | 0.083322 ± 9.69072e-05 (W 0.000167873) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.187261 ± 0.00173232 (W 0.00277291) | 0.187031 ± 0.000440726 (W 0.00246673) | 0.219801 ± 0.000998217 (W 0.00158036) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00519 ± 3.21455e-05 (W 2.48998e-05) | 0.00509 ± 0.000100683 (W 2.88496e-05) | 0.007925 ± 7.02377e-05 (W 0.000105519) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029766 ± 5.27289e-05 (W 8.6737e-05) | 0.029475 ± 0.000351258 (W 7.91833e-05) | 0.043071 ± 0.000310188 (W 0.000104433) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.10177 ± 0.00102507 (W 0.00168031) | 0.10173 ± 0.000735121 (W 0.0012636) | 0.124637 ± 0.000209154 (W 0.00147894) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015789 ± 0.000144915 (W 7.12039e-05) | 0.015899 ± 5.83981e-05 (W 0.000155715) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090108 ± 0.000258661 (W 0.000308581) | 0.090008 ± 0.000265982 (W 0.000234116) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.301554 ± 0.00203183 (W 0.0042073) | 0.30472 ± 0.00109871 (W 0.00400031) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011361 ± 0.000151461 (W 7.40696e-05) | 0.011281 ± 0.00010583 (W 0.000116321) | 0.017282 ± 0.000155907 (W 5.76741e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051105 ± 0.000104462 (W 0.0002103) | 0.051416 ± 0.00105736 (W 0.000322664) | 0.08539 ± 4.75219e-05 (W 0.00130547) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.173986 ± 0.00013147 (W 0.00227502) | 0.188413 ± 0.00491912 (W 0.00251926) | 0.224259 ± 0.00018735 (W 0.00180341) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.012404 ± 0.000103365 (W 0.000108444) | 0.012543 ± 0.000119304 (W 8.76253e-05) | 0.017261 ± 0.000100504 (W 0.000112202) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052996 ± 7.72722e-05 (W 0.000165904) | 0.053046 ± 0.000321966 (W 0.00027399) | 0.082885 ± 0.000127143 (W 0.000174986) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.184845 ± 0.00274469 (W 0.00291549) | 0.200675 ± 0.00267758 (W 0.00552431) | 0.218128 ± 0.000506008 (W 0.00135857) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00518 ± 1.12694e-05 (W 3.50714e-05) | 0.00518 ± 2e-05 (W 3.56959e-05) | 0.008025 ± 9.60902e-05 (W 3.96232e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029906 ± 0.000154643 (W 0.00011343) | 0.030006 ± 0.000219819 (W 0.000152103) | 0.043571 ± 0.000331855 (W 9.12486e-05) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.110051 ± 0.0002007 (W 0.00334308) | 0.110937 ± 0.000803831 (W 0.00243327) | 0.125245 ± 0.000357836 (W 0.00151646) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015869 ± 0.000240618 (W 0.000114543) | 0.015969 ± 5.5109e-05 (W 0.000114832) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090058 ± 0.000134783 (W 0.00160352) | 0.090078 ± 0.0003858 (W 0.000560434) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.304295 ± 0.00147072 (W 0.0024268) | 0.304695 ± 7.30205e-05 (W 0.0033301) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011381 ± 0.000152753 (W 5.41295e-05) | 0.011361 ± 4.72582e-05 (W 0.000193779) | 0.017403 ± 9.26517e-05 (W 3.37979e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051115 ± 0.000341863 (W 0.000280771) | 0.050955 ± 0.000303788 (W 0.000206923) | 0.08557 ± 0.000288792 (W 0.000174402) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.173515 ± 0.00216515 (W 0.00229951) | 0.203431 ± 0.000526641 (W 0.00439604) | 0.22421 ± 0.00096686 (W 0.00210141) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012383 ± 0.000126295 (W 3.50714e-05) | 0.012433 ± 0.0001505 (W 0.000108486) | 0.017342 ± 6.71143e-05 (W 9.86316e-05) | · | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052877 ± 0.000425571 (W 0.000128403) | 0.053189 ± 0.000429016 (W 0.00112659) | 0.082972 ± 3.28075e-05 (W 0.000201503) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.185467 ± 0.00240861 (W 0.00261248) | 0.214811 ± 0.000996895 (W 0.00428244) | 0.218088 ± 0.000120554 (W 0.00155201) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070582 ± 0.000126582 (W 0.000889343) | 0.067403 ± 0.0022352 (W 0.000291609) | 0.115385 ± 0.000488072 (W 0.000777964) | · | 🔵 fork 1.63× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.388549 ± 0.00415148 (W 0.00167753) | 0.384459 ± 0.00599276 (W 0.00200988) | 0.637943 ± 0.00246683 (W 0.00912286) | · | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.52142 ± 0.00822432 (W 0.00258053) | 2.52005 ± 0.0044901 (W 0.00271922) | 4.04275 ± 0.0304698 (W 0.0311699) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309789 ± 0.00315948 (W 0.00164743) | 0.313676 ± 0.00274081 (W 0.00305194) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71421 ± 0.00952584 (W 0.0144171) | 2.76438 ± 0.0353539 (W 0.00827239) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.7122 ± 0.0257774 (W 0.033038) | 22.3176 ± 0.0555631 (W 0.057189) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.135474 ± 0.0168997 (W 0.00217453) | 0.136595 ± 0.0174141 (W 0.00211293) | 0.169697 ± 0.0195534 (W 0.0016743) | · | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.982614 ± 0.120718 (W 0.00297466) | 1.03217 ± 0.00145935 (W 0.00372535) | 0.96845 ± 0.133237 (W 0.00259198) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.62272 ± 0.0272547 (W 0.00480672) | 7.14382 ± 0.0744503 (W 0.0181446) | 6.96642 ± 0.029564 (W 0.00655276) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133324 ± 0.00187173 (W 0.00117344) | 0.13716 ± 0.00099527 (W 0.00234787) | 0.169677 ± 0.000639407 (W 0.0011337) | · | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.751473 ± 0.00232075 (W 0.00152538) | 0.806488 ± 0.00162572 (W 0.00278695) | 0.969552 ± 0.00114783 (W 0.00149764) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.53122 ± 0.0266079 (W 0.0197227) | 7.06355 ± 0.0366321 (W 0.00875878) | 5.99856 ± 0.0111522 (W 0.022826) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089223 ± 0.00033606 (W 0.00160495) | 0.105443 ± 0.00330104 (W 0.0036528) | 0.11445 ± 0.000805961 (W 0.0017458) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.411082 ± 0.00342158 (W 0.025979) | 0.427089 ± 0.0153591 (W 0.0171936) | 0.404807 ± 0.004827 (W 0.00425038) | · | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.6067 ± 0.0445673 (W 0.0285027) | 1.72226 ± 0.0786051 (W 0.0547814) | 1.92239 ± 0.00708299 (W 0.0128039) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.309829 ± 0.000419684 (W 0.00197479) | 0.312522 ± 0.000541294 (W 0.00252775) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70029 ± 0.0132902 (W 0.0106546) | 2.75733 ± 0.010112 (W 0.0100231) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4198 ± 0.111458 (W 0.151346) | 18.2188 ± 0.143611 (W 0.339558) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.133569 ± 0.0189198 (W 0.00154519) | 0.204513 ± 0.0193797 (W 0.00710043) | 0.151984 ± 0.0135296 (W 0.0018408) | 🔵 fork 1.53× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.990281 ± 0.117165 (W 0.00433531) | 1.18594 ± 0.00771769 (W 0.0229075) | 0.378788 ± 0.115019 (W 0.00341255) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 2.61× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.83246 ± 0.0173549 (W 0.0907169) | 5.55807 ± 0.0536723 (W 0.0345579) | 2.61079 ± 0.0415263 (W 0.0104492) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133649 ± 0.00066719 (W 0.00145406) | 0.204532 ± 0.00176953 (W 0.00944389) | 0.150105 ± 9.98516e-05 (W 0.00101394) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.765932 ± 0.0188089 (W 0.00200691) | 0.904756 ± 0.0225833 (W 0.0158149) | 0.368178 ± 0.00241775 (W 0.00322757) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.6931 ± 0.055257 (W 0.0255634) | 5.52083 ± 0.123827 (W 0.0618711) | 1.83299 ± 0.0177707 (W 0.00518331) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 2.56× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.092734 ± 0.000846509 (W 0.0034141) | 0.103335 ± 0.00453265 (W 0.00430256) | 0.115161 ± 0.00146208 (W 0.00119671) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.394978 ± 0.0038456 (W 0.0211196) | 0.429443 ± 0.0153915 (W 0.017874) | 0.358066 ± 0.00233204 (W 0.0049707) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.52527 ± 0.0271802 (W 0.0231739) | 1.64594 ± 0.0310843 (W 0.0438755) | 1.43851 ± 0.0175815 (W 0.00677756) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309288 ± 0.000398098 (W 0.00182773) | 0.312475 ± 0.00109368 (W 0.00213636) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71454 ± 0.0108524 (W 0.00758627) | 2.76468 ± 0.0193084 (W 0.00580142) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.2919 ± 0.196043 (W 0.0588159) | 17.8203 ± 0.20506 (W 0.115115) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.164822 ± 0.000829533 (W 0.00167577) | 0.254396 ± 0.0247217 (W 0.00940701) | 0.193507 ± 0.025674 (W 0.0031167) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.992027 ± 0.119786 (W 0.00625133) | 1.25312 ± 0.0141874 (W 0.0299045) | 0.348532 ± 0.157916 (W 0.00302785) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 2.85× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.64964 ± 0.0503169 (W 0.0380693) | 5.74329 ± 0.00327885 (W 0.0527631) | 2.221 ± 0.040465 (W 0.0143452) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133871 ± 0.000537633 (W 0.00145409) | 0.208462 ± 0.00796841 (W 0.00763722) | 0.146469 ± 0.000225282 (W 0.0012667) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.764359 ± 0.00746513 (W 0.00240192) | 0.955203 ± 0.0244542 (W 0.0249829) | 0.335091 ± 0.0082105 (W 0.00323495) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.66013 ± 0.0588938 (W 0.0827866) | 5.48463 ± 0.0849823 (W 0.043735) | 1.28269 ± 0.00270129 (W 0.00592506) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 3.63× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063118 ± 0.00028334 (W 9.12688e-05) | 0.060633 ± 0.00235571 (W 0.000104729) | 0.095228 ± 0.00243424 (W 0.000181453) | · | 🔵 fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.322734 ± 0.00181704 (W 0.00226174) | 0.31776 ± 0.00397168 (W 0.00320236) | 0.448459 ± 0.0018838 (W 0.00258375) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06615 ± 0.00572473 (W 0.00243145) | 2.06415 ± 0.0050058 (W 0.00270675) | 3.33225 ± 0.0624012 (W 0.00390977) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290974 ± 0.00111707 (W 0.002388) | 0.291916 ± 0.00110912 (W 0.00180606) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62457 ± 0.013097 (W 0.0100869) | 2.63449 ± 0.0262121 (W 0.00678685) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.1696 ± 0.059788 (W 0.0351059) | 21.1611 ± 0.0699455 (W 0.0346982) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.144139 ± 0.00157228 (W 0.00218734) | 0.145405 ± 0.000550878 (W 0.0018263) | 0.133119 ± 0.000550367 (W 0.00113335) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.697704 ± 0.114566 (W 0.00473741) | 0.698386 ± 0.115087 (W 0.00190468) | 0.81837 ± 0.00273406 (W 0.00235187) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.12605 ± 0.0143595 (W 0.00697) | 6.10971 ± 0.0393569 (W 0.0102953) | 5.224 ± 0.012633 (W 0.00944361) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111694 ± 0.00102173 (W 0.00100906) | 0.113187 ± 0.00144661 (W 0.000258129) | 0.132959 ± 0.00099971 (W 0.00108084) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.66234 ± 0.00162214 (W 0.00260093) | 0.663611 ± 0.00201773 (W 0.00330988) | 0.813797 ± 0.00215788 (W 0.00302553) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.04784 ± 0.0297336 (W 0.00532095) | 6.04881 ± 0.020296 (W 0.00781563) | 5.26316 ± 0.00778901 (W 0.0200927) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.081439 ± 0.000115522 (W 0.00292076) | 0.094977 ± 0.00878604 (W 0.00748829) | 0.091291 ± 0.000904611 (W 0.00123675) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.337591 ± 0.0130748 (W 0.0242303) | 0.346237 ± 0.00405722 (W 0.0192569) | 0.237093 ± 0.00465727 (W 0.00385775) | · | 🔴 fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.12083 ± 0.0245216 (W 0.0205041) | 1.21316 ± 0.00159387 (W 0.0173967) | 1.4226 ± 0.0182571 (W 0.0046633) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290703 ± 0.00257283 (W 0.00282971) | 0.291323 ± 0.000644847 (W 0.00186588) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62867 ± 0.014084 (W 0.0132744) | 2.63229 ± 0.0113253 (W 0.00752308) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8654 ± 0.0321406 (W 0.0963618) | 16.8597 ± 0.13031 (W 0.150484) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146264 ± 0.00143434 (W 0.00126747) | 0.216235 ± 0.001931 (W 0.00918201) | 0.132933 ± 0.00107618 (W 0.00100855) | 🔵 fork 1.48× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.70576 ± 0.118971 (W 0.00285303) | 0.832737 ± 0.125738 (W 0.0297552) | 0.326717 ± 0.00220579 (W 0.00223106) | · | 🔴 fork 2.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.26461 ± 0.0462455 (W 0.098961) | 4.60156 ± 0.0347101 (W 0.0510655) | 1.62891 ± 0.0110037 (W 0.00399484) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 2.62× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111488 ± 0.000819272 (W 0.00171) | 0.179686 ± 0.00228346 (W 0.00562347) | 0.131846 ± 0.000413672 (W 0.00026223) | 🔵 fork 1.61× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.675357 ± 0.00130244 (W 0.00314632) | 0.759389 ± 0.0139615 (W 0.0151656) | 0.312194 ± 0.00066946 (W 0.00155832) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.19552 ± 0.0132774 (W 0.0338693) | 4.3843 ± 0.0173761 (W 0.0279888) | 1.63143 ± 0.0106152 (W 0.00536303) | · | 🔴 fork 2.57× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.085497 ± 0.000103436 (W 0.0037759) | 0.09637 ± 0.00428067 (W 0.00193151) | 0.093027 ± 0.000164214 (W 0.00157027) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.349546 ± 0.0109575 (W 0.015497) | 0.393792 ± 0.0141147 (W 0.0232171) | 0.193778 ± 0.00171502 (W 0.00310329) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.07334 ± 0.0160386 (W 0.0156224) | 1.19696 ± 0.00364292 (W 0.0234116) | 0.951499 ± 0.0141086 (W 0.00848951) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289419 ± 0.00314193 (W 0.00186766) | 0.287316 ± 0.000924098 (W 0.00279097) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61895 ± 0.00309193 (W 0.00758759) | 2.6264 ± 0.00379325 (W 0.00766642) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8752 ± 0.136896 (W 0.119424) | 16.8028 ± 0.137444 (W 0.0821813) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.113995 ± 0.0188166 (W 0.00139943) | 0.19767 ± 0.0190075 (W 0.0077813) | 0.132963 ± 0.0010235 (W 0.00120108) | 🔵 fork 1.73× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.710173 ± 0.118893 (W 0.00757083) | 0.945103 ± 0.119492 (W 0.0205151) | 0.316948 ± 0.00131342 (W 0.00235527) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 2.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.12908 ± 0.0771717 (W 0.0924108) | 4.69101 ± 0.0315341 (W 0.0687836) | 1.2266 ± 0.00560623 (W 0.00635728) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 3.37× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111308 ± 0.00113622 (W 0.00121275) | 0.18351 ± 0.00297177 (W 0.0057806) | 0.132027 ± 0.000949111 (W 0.000202064) | 🔵 fork 1.65× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.6796 ± 0.00297348 (W 0.00307564) | 0.781342 ± 0.043749 (W 0.0291186) | 0.302493 ± 0.005937 (W 0.00261284) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.07997 ± 0.00454452 (W 0.0125352) | 4.58324 ± 0.0501893 (W 0.0871885) | 1.20224 ± 0.00593861 (W 0.00391451) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 3.39× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188242 ± 0.00121313 (W 0.000724911) | 0.187019 ± 0.000668249 (W 0.00190582) | 0.472854 ± 0.00473058 (W 0.00311505) | · | 🔵 fork 2.51× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.2243 ± 0.00289005 (W 0.00305482) | 1.22402 ± 0.00339243 (W 0.00564524) | 1.85287 ± 0.0197274 (W 0.00604582) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.91693 ± 0.0784476 (W 0.00881209) | 7.90432 ± 0.101299 (W 0.0139732) | 11.4238 ± 0.0574922 (W 0.0313654) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.776058 ± 0.00481154 (W 0.00493184) | 0.784296 ± 0.00295073 (W 0.0059493) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.92401 ± 0.0244889 (W 0.0164807) | 6.06901 ± 0.0543777 (W 0.0170641) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 43.2938 ± 0.213708 (W 0.13097) | 43.2359 ± 0.187491 (W 0.119681) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.323431 ± 0.00270547 (W 0.00325511) | 0.326637 ± 0.000216176 (W 0.00160608) | 0.502418 ± 0.00270473 (W 0.00293243) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.11381 ± 0.00990538 (W 0.00572797) | 2.20169 ± 0.00248913 (W 0.00503911) | 3.30777 ± 0.00582551 (W 0.00751664) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.3893 ± 0.0434102 (W 0.0526187) | 17.42 ± 0.0719256 (W 0.0557633) | 23.2051 ± 0.0841557 (W 0.0548263) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.32282 ± 0.00100274 (W 0.00174372) | 0.326447 ± 0.00156954 (W 0.00147693) | 0.487752 ± 0.000698915 (W 0.00222732) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.04787 ± 0.00442339 (W 0.00198565) | 2.13878 ± 0.00693651 (W 0.00228944) | 2.82995 ± 0.00751532 (W 0.00426189) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 17.8913 ± 0.0227598 (W 0.0479955) | 17.9489 ± 0.0462944 (W 0.0463807) | 18.853 ± 0.0144708 (W 0.0602816) | · | 🔵 fork 1.05× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188713 ± 0.00490003 (W 0.00228658) | 0.199104 ± 0.00626362 (W 0.00341815) | 0.473705 ± 0.00218883 (W 0.00245269) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 2.51× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.867579 ± 0.00900959 (W 0.0108019) | 0.880155 ± 0.0126869 (W 0.00858983) | 0.795828 ± 0.00737832 (W 0.00790862) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.37189 ± 0.0219697 (W 0.022144) | 3.40932 ± 0.0101361 (W 0.0206025) | 3.63267 ± 0.00925871 (W 0.0111043) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.768687 ± 0.00447154 (W 0.00492998) | 0.780088 ± 0.00477058 (W 0.0100553) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.90394 ± 0.0137434 (W 0.011729) | 6.056 ± 0.0232611 (W 0.0196623) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.648 ± 0.157238 (W 0.094247) | 29.754 ± 0.102053 (W 0.266287) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.322306 ± 0.00100253 (W 0.0025325) | 0.345115 ± 0.00114754 (W 0.0066514) | 0.482413 ± 0.0082768 (W 0.00369049) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.13056 ± 0.00759841 (W 0.00893046) | 1.68561 ± 0.0221405 (W 0.0166445) | 1.01471 ± 0.00399088 (W 0.00208178) | 🔴 fork 1.26× slower than `faer-upstream` | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.7952 ± 0.0811319 (W 0.0784162) | 9.89339 ± 0.0276679 (W 0.0436072) | 7.6132 ± 0.0108802 (W 0.0220361) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.319267 ± 0.000955923 (W 0.00208134) | 0.330407 ± 0.00240433 (W 0.00587331) | 0.470161 ± 0.00136431 (W 0.00294223) | · | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.0605 ± 0.00592758 (W 0.00152969) | 1.55685 ± 0.0136259 (W 0.0150798) | 0.897198 ± 0.00264326 (W 0.00425866) | 🔴 fork 1.32× slower than `faer-upstream` | 🔴 fork 2.30× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 11.4117 ± 0.0284959 (W 0.127493) | 10.4331 ± 0.038825 (W 0.0913313) | 5.6654 ± 0.0446537 (W 0.0113278) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.01× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.194409 ± 0.00172478 (W 0.00227776) | 0.213049 ± 0.00186128 (W 0.00414358) | 0.476787 ± 0.00145584 (W 0.00356699) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 2.45× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.829551 ± 0.00403396 (W 0.0164518) | 0.882077 ± 0.00745695 (W 0.0107445) | 0.659244 ± 0.00289909 (W 0.00462527) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.76555 ± 0.0173889 (W 0.0308899) | 2.86154 ± 0.0134009 (W 0.01639) | 2.27937 ± 0.0154644 (W 0.0142812) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.770953 ± 0.00370618 (W 0.00727393) | 0.77955 ± 0.00566172 (W 0.00416876) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.88154 ± 0.0594322 (W 0.0410536) | 6.05923 ± 0.058568 (W 0.0225444) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.9186 ± 0.128003 (W 0.140814) | 28.1913 ± 0.162398 (W 0.117516) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.323786 ± 0.00111087 (W 0.00294409) | 0.363867 ± 0.00140901 (W 0.00428902) | 0.487685 ± 0.0067966 (W 0.00170957) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.1548 ± 0.0171318 (W 0.0209361) | 1.68583 ± 0.0115435 (W 0.0203969) | 0.696918 ± 0.00308656 (W 0.00361161) | 🔴 fork 1.28× slower than `faer-upstream` | 🔴 fork 3.09× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.68745 ± 0.0517687 (W 0.06252) | 8.85592 ± 0.0591337 (W 0.0637558) | 5.01101 ± 0.0679204 (W 0.0140268) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.318866 ± 0.000740501 (W 0.00233714) | 0.354042 ± 0.00143671 (W 0.00457978) | 0.473039 ± 0.00541405 (W 0.00286121) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.07886 ± 0.00427849 (W 0.00712952) | 1.52214 ± 0.00764142 (W 0.0186029) | 0.670575 ± 0.00180448 (W 0.00533182) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 3.10× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.2651 ± 0.0194046 (W 0.089862) | 9.33357 ± 0.121257 (W 0.0428064) | 3.44167 ± 0.0157556 (W 0.0107425) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 2.98× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174546 ± 0.000285406 (W 0.00138403) | 0.174466 ± 0.000268206 (W 0.00154811) | 0.408013 ± 0.00275531 (W 0.0028204) | · | 🔵 fork 2.34× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.12969 ± 0.000407424 (W 0.0025434) | 1.12862 ± 0.000783665 (W 0.00370475) | 1.60124 ± 0.00228053 (W 0.00536639) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.54385 ± 0.0628414 (W 0.0135442) | 7.52246 ± 0.0723712 (W 0.0125855) | 10.5759 ± 0.0189156 (W 0.0122934) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.743729 ± 0.00378172 (W 0.00541865) | 0.748768 ± 0.00169549 (W 0.00538404) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.76221 ± 0.0363336 (W 0.0142991) | 5.82188 ± 0.0652168 (W 0.0121874) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 42.3412 ± 0.269415 (W 0.105945) | 42.2833 ± 0.24298 (W 0.112658) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295212 ± 0.000536041 (W 0.00228769) | 0.29412 ± 0.00270237 (W 0.00159568) | 0.459519 ± 0.00209548 (W 0.00272481) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.99859 ± 0.00164801 (W 0.00469945) | 1.99787 ± 0.00665436 (W 0.00606642) | 3.22084 ± 0.0106999 (W 0.00643367) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.3663 ± 0.0274067 (W 0.0297618) | 16.3698 ± 0.0158948 (W 0.021002) | 20.2778 ± 0.00706461 (W 0.0253269) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292577 ± 0.0015513 (W 0.00543411) | 0.292978 ± 0.00126469 (W 0.00234958) | 0.445613 ± 0.00243206 (W 0.00264938) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93018 ± 0.00350639 (W 0.00290914) | 1.92925 ± 0.00796846 (W 0.00902385) | 2.663 ± 0.015647 (W 0.0043412) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 16.9028 ± 0.0177815 (W 0.0525853) | 16.9147 ± 0.0506071 (W 0.0274834) | 17.5342 ± 0.0193917 (W 0.0396755) | · | · |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176656 ± 0.000540334 (W 0.00269497) | 0.188085 ± 0.00060371 (W 0.00609244) | 0.408624 ± 0.000733175 (W 0.00278985) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 2.31× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.760202 ± 0.0133938 (W 0.0089941) | 0.791877 ± 0.00790903 (W 0.0114025) | 0.593145 ± 0.0113325 (W 0.0073141) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.00629 ± 0.0117609 (W 0.0203698) | 3.05111 ± 0.0125498 (W 0.0237629) | 3.22125 ± 0.00319979 (W 0.00880208) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.740274 ± 0.00546351 (W 0.00335397) | 0.746646 ± 0.00434175 (W 0.00666188) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.77073 ± 0.0254212 (W 0.0238972) | 5.77103 ± 0.0364964 (W 0.0253222) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.6313 ± 0.230907 (W 0.219125) | 28.5337 ± 0.076636 (W 0.235016) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295231 ± 0.000827762 (W 0.00202363) | 0.31526 ± 0.00591433 (W 0.0066287) | 0.457938 ± 0.00171425 (W 0.0032149) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.01073 ± 0.00578607 (W 0.00736892) | 1.46326 ± 0.00579113 (W 0.0205288) | 0.970216 ± 0.00279552 (W 0.00489999) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.70661 ± 0.0368684 (W 0.0756492) | 9.03592 ± 0.0177741 (W 0.0290677) | 5.78674 ± 0.0420971 (W 0.0114577) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.290423 ± 0.000988848 (W 0.00224348) | 0.303056 ± 0.00280299 (W 0.00595676) | 0.445568 ± 0.0015077 (W 0.00259989) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.94955 ± 0.00140892 (W 0.00364571) | 1.33102 ± 0.00610768 (W 0.0204351) | 0.854711 ± 0.00415152 (W 0.00213199) | 🔴 fork 1.46× slower than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.2937 ± 0.0570484 (W 0.0381952) | 9.45561 ± 0.02585 (W 0.0614151) | 5.38972 ± 0.0403066 (W 0.00793688) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.91× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.180979 ± 0.00209694 (W 0.00297077) | 0.199476 ± 0.0021842 (W 0.00354861) | 0.410748 ± 5.36749e-05 (W 0.0021153) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 2.27× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.744903 ± 0.00758145 (W 0.0147218) | 0.774378 ± 0.00240759 (W 0.00793777) | 0.464875 ± 0.00160065 (W 0.00310929) | · | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.42566 ± 0.00463511 (W 0.0402116) | 2.49149 ± 0.0152036 (W 0.019827) | 1.87206 ± 0.0182948 (W 0.0164859) | · | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.740958 ± 0.00115755 (W 0.00335715) | 0.741366 ± 0.003707 (W 0.00554734) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.73868 ± 0.019562 (W 0.0342197) | 5.78079 ± 0.0897942 (W 0.0338476) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.7092 ± 0.123536 (W 0.14227) | 26.863 ± 0.117851 (W 0.128442) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296895 ± 0.00110467 (W 0.00230919) | 0.334766 ± 0.000985512 (W 0.00580538) | 0.45857 ± 0.0023885 (W 0.00201635) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.01387 ± 0.0123913 (W 0.018165) | 1.45565 ± 0.0100734 (W 0.0237741) | 0.679329 ± 0.00131151 (W 0.00200595) | 🔴 fork 1.38× slower than `faer-upstream` | 🔴 fork 2.96× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.70421 ± 0.017222 (W 0.0404394) | 7.97685 ± 0.0476965 (W 0.0644039) | 3.47773 ± 0.0171799 (W 0.00798877) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.50× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.293357 ± 0.00107551 (W 0.00265688) | 0.322291 ± 0.000342816 (W 0.00506761) | 0.449234 ± 0.00251785 (W 0.00291328) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.96945 ± 0.00378063 (W 0.0197069) | 1.29829 ± 0.00754951 (W 0.0108201) | 0.646148 ± 0.00945073 (W 0.00321604) | 🔴 fork 1.52× slower than `faer-upstream` | 🔴 fork 3.05× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.13006 ± 0.0446615 (W 0.107038) | 8.38857 ± 0.0652417 (W 0.0554326) | 3.29924 ± 0.0221362 (W 0.0104073) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.77× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.821688 ± 0.0185867 (W 0.00440819) | 0.820144 ± 0.0103186 (W 0.00410012) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.168 ± 0.703761 (W 0.120903) | 53.9221 ± 1.15181 (W 0.795934) | - | 🔵 fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.47302 ± 0.0074136 (W 0.00358251) | 0.473165 ± 0.00274217 (W 0.00350239) | 0.664793 ± 0.13557 (W 0.00400721) | · | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.2991 ± 0.16386 (W 0.0344091) | 19.0233 ± 0.0977759 (W 0.0653372) | 18.2593 ± 2.53211 (W 0.144049) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.826485 ± 0.00561083 (W 0.00256759) | 0.819306 ± 0.00252395 (W 0.00834966) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.7114 ± 0.0823759 (W 0.0699821) | 26.1577 ± 1.15511 (W 0.940312) | - | 🔵 fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.497706 ± 0.00320604 (W 0.0119257) | 0.496545 ± 0.00102573 (W 0.00676852) | 0.531464 ± 0.117194 (W 0.00362259) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.5819 ± 0.128425 (W 0.0862028) | 13.0586 ± 0.0392144 (W 0.035629) | 13.3635 ± 1.93702 (W 0.0849164) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.817622 ± 0.00483844 (W 0.0115366) | 0.824414 ± 0.00518229 (W 0.00445425) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.8941 ± 0.0884027 (W 0.171775) | 19.5248 ± 0.0580157 (W 0.446982) | - | 🔵 fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.478194 ± 0.0211015 (W 0.0086733) | 0.522788 ± 0.00596495 (W 0.00988471) | 0.597497 ± 0.167151 (W 0.00218141) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.80956 ± 0.1398 (W 0.0696805) | 12.2045 ± 0.0684903 (W 0.051032) | 4.11438 ± 1.83928 (W 0.0127905) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.751138 ± 0.0119366 (W 0.00443092) | 0.744068 ± 0.0123196 (W 0.0115107) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.9533 ± 0.753123 (W 0.063449) | 46.9161 ± 0.648123 (W 0.070743) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.38481 ± 0.000565936 (W 0.00296602) | 0.384529 ± 0.00114324 (W 0.00284679) | 0.286456 ± 0.00106273 (W 0.00208348) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2906 ± 0.0224327 (W 0.033544) | 13.2808 ± 0.0198651 (W 0.0314379) | 11.6507 ± 0.0928652 (W 0.0222651) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731648 ± 0.0107261 (W 0.00341631) | 0.731573 ± 0.00028522 (W 0.00466706) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6162 ± 0.0517196 (W 0.168705) | 17.6663 ± 0.0745546 (W 0.1576) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.409598 ± 0.00295317 (W 0.00442526) | 0.430204 ± 0.0065817 (W 0.00738426) | 0.288329 ± 0.000759959 (W 0.00276434) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.31199 ± 0.0200982 (W 0.0481716) | 7.38733 ± 0.171897 (W 0.0242606) | 11.5988 ± 0.0971566 (W 0.040277) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730913 ± 0.00402047 (W 0.00423833) | 0.7325 ± 0.00137393 (W 0.00875674) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6051 ± 0.021071 (W 0.118693) | 13.6536 ± 0.124237 (W 0.0804771) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.39572 ± 0.00160833 (W 0.00301958) | 0.442523 ± 0.00614514 (W 0.0118612) | 0.286277 ± 0.000520577 (W 0.00260067) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.62373 ± 0.0285969 (W 0.0444248) | 6.7212 ± 0.0234317 (W 0.032701) | 3.12255 ± 0.0564273 (W 0.0139567) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79472 ± 0.00173175 (W 0.00331397) | 1.84146 ± 0.0234154 (W 0.00267104) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.187 ± 0.428691 (W 0.481623) | 157.947 ± 0.236112 (W 1.85769) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.994399 ± 0.00365899 (W 0.00184465) | 1.00121 ± 0.00835822 (W 0.00282159) | 1.18956 ± 0.00216366 (W 0.0044007) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.6533 ± 0.0219614 (W 0.121722) | 53.7331 ± 0.079853 (W 0.0650099) | 56.2331 ± 6.02369 (W 0.468095) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.76601 ± 0.0063345 (W 0.00269253) | 1.83986 ± 0.0206846 (W 0.00363775) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.3319 ± 0.262709 (W 0.33772) | 65.3502 ± 0.471353 (W 0.621625) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.869777 ± 0.00563591 (W 0.0111576) | 0.804147 ± 0.0192183 (W 0.0104052) | 1.09533 ± 0.00145738 (W 0.00191713) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.6173 ± 0.118433 (W 0.165634) | 29.6948 ± 0.0551465 (W 0.0965512) | 52.2919 ± 3.63558 (W 0.0806807) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 2.31× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.76869 ± 0.0110679 (W 0.00328494) | 1.82968 ± 0.0172396 (W 0.00216271) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.5761 ± 0.267173 (W 0.277831) | 41.5645 ± 0.184388 (W 0.146687) | - | 🔵 fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.836815 ± 0.000956579 (W 0.0134221) | 0.786489 ± 0.0101696 (W 0.0115495) | 1.07948 ± 0.00290031 (W 0.00150511) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 19.069 ± 0.26451 (W 0.212234) | 25.7869 ± 0.0390821 (W 0.110577) | 57.3712 ± 3.68419 (W 0.116349) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 3.01× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.67715 ± 0.00418808 (W 0.00459741) | 1.69979 ± 0.00317538 (W 0.00393726) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 142.804 ± 1.13207 (W 0.358512) | 144.299 ± 0.474966 (W 0.524299) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.873472 ± 0.0042906 (W 0.00175105) | 0.880264 ± 0.00466544 (W 0.00537223) | 1.06338 ± 0.0169257 (W 0.00179763) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 41.5772 ± 0.0772933 (W 0.0646936) | 41.5982 ± 0.064444 (W 0.0859311) | 50.0421 ± 0.307711 (W 0.0675769) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.65551 ± 0.00370432 (W 0.0032087) | 1.6902 ± 0.00340621 (W 0.00400855) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.4242 ± 0.212674 (W 0.393831) | 53.1211 ± 0.199242 (W 0.613539) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.756354 ± 0.00948408 (W 0.00739246) | 0.70566 ± 0.00549031 (W 0.00680906) | 1.06558 ± 0.00980249 (W 0.00201775) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.3891 ± 0.0374091 (W 0.0534965) | 17.3916 ± 0.0432437 (W 0.0550884) | 49.6559 ± 0.315185 (W 0.442147) | · | 🔵 fork 2.86× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.65867 ± 0.00577638 (W 0.00559899) | 1.68799 ± 0.000490649 (W 0.00326416) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.0157 ± 0.373389 (W 0.587798) | 29.5574 ± 0.169955 (W 1.06282) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.713017 ± 0.00412766 (W 0.0100327) | 0.694946 ± 0.00551383 (W 0.0107575) | 1.06638 ± 0.000321853 (W 0.00236158) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.4723 ± 0.0527666 (W 0.0473763) | 13.5378 ± 0.0415185 (W 0.0714084) | 50.049 ± 0.345088 (W 0.0655468) | · | 🔵 fork 3.71× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 73.9069 ± 0.382798 (W 0.538223) | 75.821 ± 0.538156 (W 0.346846) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12234 ± 0.00987221 (W 0.00180794) | 1.2659 ± 0.0217565 (W 0.00334755) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 15.9531 ± 0.104155 (W 0.0288673) | 18.0416 ± 0.191224 (W 0.0234358) | 76.0642 ± 2.63745 (W 1.61061) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 4.77× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.396018 ± 0.00186906 (W 0.00288686) | 0.512241 ± 0.0025616 (W 0.00289528) | 0.931152 ± 0.13753 (W 0.00397767) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 2.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.5082 ± 0.292847 (W 0.200547) | 39.8226 ± 0.627038 (W 0.396009) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12972 ± 0.00904166 (W 0.00470792) | 1.25702 ± 0.0107025 (W 0.00282586) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.16341 ± 0.193731 (W 0.077302) | 9.03571 ± 0.251067 (W 0.088135) | 10.1295 ± 0.178317 (W 0.0589816) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.229205 ± 0.0005121 (W 0.00398072) | 0.376131 ± 0.00250006 (W 0.0158472) | 0.291916 ± 0.00302977 (W 0.00320335) | 🔵 fork 1.64× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.6967 ± 0.447532 (W 0.184336) | 35.0688 ± 0.327496 (W 0.127945) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12711 ± 0.0084313 (W 0.00339161) | 1.26409 ± 0.0124149 (W 0.00366183) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.87284 ± 0.166994 (W 0.153698) | 8.07318 ± 0.161998 (W 0.108265) | 6.8343 ± 1.54784 (W 0.0211072) | 🔵 fork 1.37× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.210768 ± 0.00231767 (W 0.0042371) | 0.378458 ± 0.0193432 (W 0.0164141) | 0.170909 ± 0.00156611 (W 0.00242924) | 🔵 fork 1.80× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.023 ± 0.511994 (W 0.141575) | 71.5591 ± 0.381895 (W 0.219787) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05373 ± 0.00536222 (W 0.00245054) | 1.05355 ± 0.0169282 (W 0.00334444) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3188 ± 0.00512421 (W 0.0214284) | 13.3576 ± 0.0326976 (W 0.0275317) | 210.134 ± 0.228053 (W 0.390916) | · | 🔵 fork 15.78× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.312594 ± 0.00147959 (W 0.00202425) | 0.310711 ± 0.00239171 (W 0.00201799) | 3.13352 ± 0.00612566 (W 0.000967342) | · | 🔵 fork 10.02× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.274 ± 0.340286 (W 0.10699) | 35.3252 ± 0.26778 (W 0.216991) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.06161 ± 0.0141451 (W 0.00258435) | 1.05128 ± 0.0262078 (W 0.00371219) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.39029 ± 0.0138421 (W 0.0392749) | 4.66386 ± 0.0168842 (W 0.0146905) | 5.28659 ± 0.0137647 (W 0.0114842) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.13599 ± 0.00263125 (W 0.00277267) | 0.169006 ± 0.00154116 (W 0.00298383) | 0.232811 ± 0.00232323 (W 0.0021741) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.71× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.4552 ± 0.215724 (W 0.228463) | 30.323 ± 0.0415356 (W 0.399468) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05143 ± 0.00789844 (W 0.00292908) | 1.05327 ± 0.0052672 (W 0.00293011) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.92765 ± 0.0250478 (W 0.0276087) | 3.36612 ± 0.0299042 (W 0.0829315) | 3.14699 ± 0.016149 (W 0.00723122) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.115335 ± 0.00137432 (W 0.0018889) | 0.154871 ± 0.00553836 (W 0.00586899) | 0.130656 ± 0.00178229 (W 0.00151881) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 235.948 ± 2.80142 (W 0.800675) | 235.396 ± 1.36504 (W 0.898402) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.3841 ± 0.0525924 (W 0.016927) | 2.50355 ± 0.0698161 (W 0.0150814) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 45.9985 ± 0.161372 (W 0.368784) | 46.62 ± 0.143034 (W 0.0968912) | 88.2156 ± 0.446289 (W 0.39572) | · | 🔵 fork 1.92× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.994547 ± 0.00269347 (W 0.00422799) | 1.05221 ± 0.00400447 (W 0.00327159) | 2.32538 ± 0.0179632 (W 0.00437084) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 2.34× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.6619 ± 2.61568 (W 0.466468) | 97.2439 ± 1.31396 (W 0.588941) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.43145 ± 0.0248209 (W 0.00512706) | 2.52279 ± 0.0161261 (W 0.0136772) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.6045 ± 0.123103 (W 0.114456) | 18.245 ± 0.020164 (W 0.0893658) | 23.8872 ± 3.22988 (W 0.0706545) | · | 🔵 fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.430936 ± 0.00165993 (W 0.0166488) | 0.487287 ± 0.00175793 (W 0.00353989) | 0.643133 ± 0.00242053 (W 0.00602352) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.49× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 68.4932 ± 0.250826 (W 0.460718) | 69.9101 ± 0.953469 (W 0.275165) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.42779 ± 0.0477333 (W 0.00704892) | 2.52853 ± 0.0534016 (W 0.0159666) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 12.9267 ± 0.140938 (W 0.0729381) | 12.2984 ± 0.0533104 (W 0.0533005) | 18.8141 ± 2.99973 (W 0.106391) | · | 🔵 fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.3532 ± 0.00264496 (W 0.00373338) | 0.409132 ± 0.0148005 (W 0.00789322) | 0.452242 ± 0.00304226 (W 0.00259225) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 231.446 ± 3.31905 (W 0.460948) | 231.905 ± 2.17283 (W 0.627602) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.29741 ± 0.045012 (W 0.00905528) | 2.30261 ± 0.0323228 (W 0.00980737) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.064 ± 0.174645 (W 0.0334945) | 42.0662 ± 0.166595 (W 0.398316) | 72.9486 ± 0.423772 (W 0.139584) | · | 🔵 fork 1.73× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.89343 ± 0.00402078 (W 0.00412075) | 0.892299 ± 0.00146871 (W 0.00383532) | 2.12225 ± 0.00282517 (W 0.00244274) | · | 🔵 fork 2.38× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.6128 ± 1.97956 (W 0.687336) | 91.8261 ± 2.03693 (W 0.461295) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.26647 ± 0.0112211 (W 0.0136934) | 2.2629 ± 0.0291519 (W 0.0144731) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.4985 ± 0.0581286 (W 0.097253) | 13.8576 ± 0.032834 (W 0.0605299) | 20.5083 ± 0.0304773 (W 0.0328471) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.32039 ± 0.00344498 (W 0.00399645) | 0.322945 ± 0.00510536 (W 0.00348559) | 0.590554 ± 0.00462119 (W 0.00460783) | · | 🔵 fork 1.84× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 64.6883 ± 0.668451 (W 0.49657) | 65.3213 ± 0.517032 (W 0.517612) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.27764 ± 0.0540153 (W 0.0100045) | 2.28408 ± 0.0425447 (W 0.00716201) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.65139 ± 0.0362329 (W 0.0749109) | 8.31295 ± 0.0913518 (W 0.0437988) | 11.2855 ± 0.0756573 (W 0.0172668) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.240339 ± 0.00191211 (W 0.00550709) | 0.245455 ± 0.00516572 (W 0.00302711) | 0.411688 ± 0.00222632 (W 0.0021153) | · | 🔵 fork 1.71× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
