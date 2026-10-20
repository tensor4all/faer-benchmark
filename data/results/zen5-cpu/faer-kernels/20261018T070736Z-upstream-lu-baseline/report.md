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
- timestamp: `2026-10-18T07:34:22.868761Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --families lu,solve,full_piv_lu,cholesky,gemm --shapes 32,64,96,128,256,512,1024x64,4096x256,64x1024,256x4096,256x256x256 --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label upstream-lu-baseline --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T070736Z-upstream-lu-baseline/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.18%, worst 1321.46% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 122 of 1068 engine cells exceed 5% and carry `!`; median within-process relative SD 0.64%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/256x256x256/b1` | 1.07029 ± 0.00485227 (W 0.00166843) | 1.07382 ± 0.00414174 (W 0.002791) | 1.19828 ± 0.00362547 (W 0.00254963) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.3056 ± 0.00242995 (W 0.0027604) | 0.299556 ± 0.00127123 (W 0.00322474) | 0.344853 ± 0.000900588 (W 0.00233756) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.202987 ± 0.0231336 (W 0.04273) | 0.230926 ± 0.0132479 (W 0.0287676) | 0.183071 ± 0.00230838 (W 0.00169045) | 🔵 fork 1.14× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07251 ± 0.000480979 (W 0.00238163) | 1.07294 ± 0.00194426 (W 0.000774419) | 1.2048 ± 0.00189765 (W 0.0034717) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.309428 ± 0.00637558 (W 0.00946668) | 0.307794 ± 0.00582855 (W 0.00681526) | 0.343655 ± 0.00170346 (W 0.00221551) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.212194 ± 0.00680412 (W 0.0203179) | 0.255081 ± 0.0116126 (W 0.0334607) | 0.182236 ± 0.00258306 (W 0.00172112) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27475 ± 0.00988852 (W 0.00286571) | 4.28425 ± 0.00455835 (W 0.00344499) | 5.07559 ± 0.00176813 (W 0.0201602) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12477 ± 0.00148297 (W 0.00368957) | 1.12573 ± 0.00183326 (W 0.00379934) | 1.82507 ± 0.0197494 (W 0.00493771) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.60643 ± 0.00425364 (W 0.0148281) | 0.60541 ± 0.00730377 (W 0.0140103) | 0.69829 ± 0.00626028 (W 0.00410801) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27957 ± 0.00370303 (W 0.00618364) | 4.2846 ± 0.00556467 (W 0.00349946) | 5.1557 ± 0.00500801 (W 0.0175598) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12787 ± 0.00249509 (W 0.00379569) | 1.12804 ± 0.000777377 (W 0.00378422) | 1.80099 ± 0.0150839 (W 0.00468786) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.612591 ± 0.0115137 (W 0.0154889) | 0.618047 ± 0.00299688 (W 0.0128438) | 0.685235 ± 0.00864068 (W 0.00243099) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003527 ± 2.88675e-05 (W 4.51918e-05) | 0.003266 ± 0.000182511 (W 3.27109e-05) | 0.004198 ± 2.51661e-05 (W 4.86755e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016661 ± 3.56417e-05 (W 4.219e-05) | 0.015028 ± 0.00119397 (W 2.70185e-05) | 0.016871 ± 2.09841e-05 (W 8.11745e-05) | 🔴 fork 1.11× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.032902 ± 0.000110726 (W 8.95276e-05) | 0.031128 ± 0.00120974 (W 6.34058e-05) | 0.048259 ± 0.000449638 (W 0.000119373) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011682 ± 0.000205508 (W 0.000149647) | 0.01056 ± 0.00017493 (W 6.31213e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.050905 ± 0.000125048 (W 8.5745e-05) | 0.046847 ± 0.00032532 (W 0.00016412) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143908 ± 0.000145548 (W 0.00168886) | 0.134409 ± 0.00097447 (W 0.00183137) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008626 ± 1.52753e-05 (W 7.63623e-05) | 0.007494 ± 0.000222336 (W 0.000146746) | 0.012203 ± 3.66106e-05 (W 7.45875e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031048 ± 0.000177858 (W 0.000221802) | 0.026719 ± 0.000295691 (W 0.000173226) | 0.04287 ± 2.39653e-05 (W 0.000164229) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075571 ± 0.00017706 (W 0.00208404) | 0.065552 ± 0.000202268 (W 0.00217121) | 0.110063 ± 0.00112765 (W 0.0022301) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009688 ± 0.000155757 (W 7.25762e-05) | 0.008366 ± 0.000134288 (W 0.000183039) | 0.012784 ± 6.65833e-05 (W 4.08656e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031689 ± 0.000155597 (W 9.02735e-05) | 0.027581 ± 0.000130309 (W 0.00010849) | 0.043531 ± 1.57162e-05 (W 0.000177942) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077856 ± 0.0012758 (W 0.00256784) | 0.068156 ± 0.000966705 (W 0.000449269) | 0.103912 ± 7.95676e-05 (W 0.00121247) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003527 ± 5.50485e-05 (W 2.89879e-05) | 0.003236 ± 0.000180666 (W 2.58844e-05) | 0.004268 ± 6.55769e-05 (W 3.40044e-05) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016611 ± 0.00184077 (W 4.74257e-05) | 0.015178 ± 0.00109261 (W 3.87466e-05) | 0.016811 ± 9.07377e-05 (W 6.40406e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050434 ± 0.00212306 (W 0.00200837) | 0.062336 ± 0.00452159 (W 0.005477) | 0.04839 ± 0.000135242 (W 0.00145067) | 🔵 fork 1.24× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.011732 ± 0.000111505 (W 0.000217512) | 0.01065 ± 0.000293606 (W 8.73567e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051265 ± 0.00022301 (W 0.000404808) | 0.046647 ± 0.000335188 (W 0.00014342) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144057 ± 0.000183718 (W 0.00245536) | 0.134037 ± 0.00044978 (W 0.00281649) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008716 ± 0.000296024 (W 3.64692e-05) | 0.007303 ± 0.000202609 (W 0.000159584) | 0.012173 ± 0.000225019 (W 0.000103209) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031007 ± 0.000187351 (W 0.000164104) | 0.045254 ± 0.00133725 (W 0.00276083) | 0.04286 ± 0.00026181 (W 0.000948964) | 🔵 fork 1.46× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.07589 ± 0.000462343 (W 0.00241833) | 0.103842 ± 0.00374921 (W 0.00304923) | 0.093224 ± 0.000376125 (W 0.000192234) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009438 ± 6.05833e-05 (W 4.54456e-05) | 0.008155 ± 0.000233453 (W 5.78386e-05) | 0.012784 ± 7.86787e-05 (W 6.91375e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031739 ± 0.000134288 (W 0.000107145) | 0.045504 ± 0.0010525 (W 0.00291221) | 0.043681 ± 0.000229566 (W 0.000180406) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077583 ± 0.000351555 (W 0.00253307) | 0.101377 ± 0.00194684 (W 0.00241259) | 0.087502 ± 0.000234952 (W 0.0013292) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003567 ± 2.3094e-05 (W 2.5006e-05) | 0.003236 ± 0.000189597 (W 3.39116e-05) | 0.004178 ± 1.52753e-05 (W 4.54973e-05) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016741 ± 0.00010504 (W 4.87852e-05) | 0.014938 ± 0.00138529 (W 3.96232e-05) | 0.016721 ± 9.88956e-05 (W 4.03646e-05) | 🔴 fork 1.12× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.057036 ± 0.0043825 (W 0.00316989) | 0.069129 ± 0.000775341 (W 0.00223532) | 0.048149 ± 0.000165742 (W 9.14292e-05) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011562 ± 0.000307799 (W 6.14003e-05) | 0.01073 ± 0.0001367 (W 5.63312e-05) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.052067 ± 0.000574759 (W 0.000451853) | 0.046928 ± 0.000321187 (W 0.000109496) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143537 ± 0.000250961 (W 0.00281576) | 0.133296 ± 0.00248716 (W 0.00123875) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008656 ± 0.000102632 (W 7.07142e-05) | 0.007503 ± 0.00028522 (W 0.000151428) | 0.012262 ± 0.00340678 (W 9.36552e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030657 ± 0.000277921 (W 0.000213217) | 0.05312 ± 0.000443217 (W 0.00333196) | 0.042799 ± 0.000112398 (W 0.000128613) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.07567 ± 0.000263365 (W 0.00221194) | 0.116675 ± 0.00406902 (W 0.00491878) | 0.090478 ± 0.00301598 (W 0.000354118) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009497 ± 5.67186e-05 (W 4.9932e-05) | 0.008115 ± 0.000151889 (W 0.000177277) | 0.012754 ± 6.4291e-05 (W 6.73053e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031539 ± 0.000446931 (W 0.000103258) | 0.052367 ± 0.000674231 (W 0.0035164) | 0.043461 ± 0.000172018 (W 0.000120603) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.078085 ± 0.00352552 (W 0.0020452) | 0.116577 ± 0.00739526 (W 0.00785951) | 0.085148 ± 8.18189e-05 (W 0.000249983) | 🔵 fork 1.49× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003426 ± 6.5041e-05 (W 1.63493e-05) | 0.003236 ± 0.000141067 (W 3.10371e-05) | 0.003376 ± 5.56776e-05 (W 2.09332e-05) | 🔴 fork 1.06× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01665 ± 0.000265368 (W 3.94487e-05) | 0.014837 ± 0.00117384 (W 0.00126201) | 0.014126 ± 2.64575e-05 (W 6.04417e-05) | 🔴 fork 1.12× slower than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.031999 ± 8.77515e-05 (W 8.13093e-05) | 0.030316 ± 0.00115889 (W 5.3209e-05) | 0.038251 ± 0.000290057 (W 7.93864e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010369 ± 0.000115902 (W 5.44977e-05) | 0.01049 ± 3.4641e-05 (W 5.97495e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045854 ± 0.000256731 (W 0.000313774) | 0.045975 ± 0.000273545 (W 0.000231666) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131957 ± 0.000263978 (W 0.00274133) | 0.132405 ± 0.000614156 (W 0.00260697) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007274 ± 0.000147886 (W 5.01996e-05) | 0.007123 ± 9.29157e-05 (W 4.48587e-05) | 0.009768 ± 4.96689e-05 (W 4.72229e-05) | · | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025817 ± 0.000106588 (W 0.00138531) | 0.025978 ± 0.0001805 (W 0.000173765) | 0.033823 ± 0.000112829 (W 0.000108259) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063197 ± 0.000325935 (W 0.00220538) | 0.063558 ± 0.000398136 (W 0.00246082) | 0.074298 ± 0.000200326 (W 0.00016012) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007935 ± 8.44413e-05 (W 7.59296e-05) | 0.007975 ± 3.10966e-05 (W 5.94138e-05) | 0.009918 ± 7.53459e-05 (W 4.34189e-05) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026098 ± 0.000259095 (W 0.000198051) | 0.026099 ± 0.000480504 (W 0.00013308) | 0.033642 ± 0.000156387 (W 8.79102e-05) | · | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065101 ± 0.00115122 (W 0.00253401) | 0.066022 ± 0.000798321 (W 0.00168689) | 0.073696 ± 0.000174605 (W 0.000335393) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003336 ± 0.000224025 (W 4.72229e-05) | 0.003106 ± 0.00021443 (W 1.41421e-05) | 0.003326 ± 3.21455e-05 (W 2.59673e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01612 ± 0.00162489 (W 3.04959e-05) | 0.014757 ± 0.00135789 (W 4.46912e-05) | 0.014156 ± 0.00014095 (W 4.60467e-05) | · | 🔴 fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049582 ± 0.000144222 (W 0.0019823) | 0.062125 ± 0.00321976 (W 0.00478078) | 0.03796 ± 0.0001117 (W 9.78264e-05) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010479 ± 0.000307215 (W 6.80904e-05) | 0.010449 ± 0.000244166 (W 5.5975e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045975 ± 0.000483861 (W 0.000120462) | 0.045715 ± 0.000229674 (W 0.000141174) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131395 ± 0.000229012 (W 0.00236457) | 0.131725 ± 0.000704012 (W 0.00160004) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007153 ± 0.000166233 (W 4.99019e-05) | 0.007063 ± 0.00012822 (W 2.36897e-05) | 0.009818 ± 0.000122202 (W 0.000127856) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025848 ± 0.000129152 (W 0.00018463) | 0.044883 ± 0.00103573 (W 0.00138884) | 0.033562 ± 0.000148561 (W 0.000129574) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063488 ± 0.000191068 (W 0.000359271) | 0.100056 ± 0.00111663 (W 0.00344897) | 0.074608 ± 0.000217716 (W 0.000218825) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007724 ± 7.63763e-05 (W 5.80793e-05) | 0.007865 ± 5.64535e-05 (W 4.01659e-05) | 0.009858 ± 4.16333e-05 (W 7.30705e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026038 ± 0.000111355 (W 7.97389e-05) | 0.044553 ± 0.000284488 (W 0.00110735) | 0.033612 ± 0.000130001 (W 4.96619e-05) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065201 ± 7.93725e-05 (W 0.00234713) | 0.10302 ± 0.00460465 (W 0.00349118) | 0.073496 ± 7.26659e-05 (W 0.000115374) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003326 ± 5.50757e-05 (W 3.42681e-05) | 0.003086 ± 0.000189297 (W 3.40044e-05) | 0.003356 ± 5.50757e-05 (W 2.88998e-05) | 🔴 fork 1.08× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01641 ± 0.000211346 (W 0.00116087) | 0.015068 ± 0.00139185 (W 3.92212e-05) | 0.013876 ± 9.07377e-05 (W 8.32845e-05) | · | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.057586 ± 0.00238696 (W 0.00315519) | 0.069609 ± 0.00235955 (W 0.00344901) | 0.037961 ± 0.000351342 (W 9.02774e-05) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.52× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010249 ± 0.000282479 (W 6.02262e-05) | 0.0106 ± 0.000149901 (W 8.17313e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045825 ± 0.000512173 (W 0.000416262) | 0.045985 ± 0.000377868 (W 0.00011077) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131273 ± 0.00277059 (W 0.00244331) | 0.130932 ± 0.00254825 (W 0.00236785) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007153 ± 8.14453e-05 (W 3.77134e-05) | 0.007213 ± 0.000162973 (W 4.76991e-05) | 0.009678 ± 3.17857e-05 (W 8.39536e-05) | · | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025838 ± 0.000213776 (W 0.000298505) | 0.052558 ± 0.00159657 (W 0.00290436) | 0.033632 ± 0.000128582 (W 9.06488e-05) | 🔵 fork 2.03× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.062936 ± 0.00179819 (W 0.00165493) | 0.112661 ± 0.00341938 (W 0.00431509) | 0.073857 ± 0.000498117 (W 0.00112882) | 🔵 fork 1.79× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007755 ± 0.000128557 (W 4.22765e-05) | 0.007834 ± 4.52806e-05 (W 7.01021e-05) | 0.009828 ± 4.74377e-05 (W 7.29123e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026148 ± 0.000265877 (W 5.9793e-05) | 0.051606 ± 0.0024195 (W 0.0029093) | 0.033543 ± 0.000116477 (W 5.12279e-05) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065792 ± 0.00386133 (W 0.00243556) | 0.11235 ± 0.0035562 (W 0.00393739) | 0.073536 ± 0.000320063 (W 0.000118098) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 2.91605e-05 (W 3.16749e-05) | 0.0052 ± 5.45619e-05 (W 4.74342e-05) | 0.008986 ± 0.000189297 (W 7.89823e-05) | · | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030466 ± 0.000153189 (W 0.000128395) | 0.030427 ± 0.000108076 (W 8.41914e-05) | 0.051275 ± 0.000474425 (W 0.000398983) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083905 ± 0.000475973 (W 0.000204862) | 0.084266 ± 0.00295894 (W 0.00020386) | 0.138709 ± 0.000690514 (W 0.00108805) | · | 🔵 fork 1.65× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017743 ± 6e-05 (W 7.46994e-05) | 0.015709 ± 3.21455e-05 (W 5.26042e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097252 ± 0.000312289 (W 0.00129833) | 0.092092 ± 0.000320765 (W 0.00155043) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319803 ± 0.00161684 (W 0.00185305) | 0.307684 ± 0.00195799 (W 0.0031628) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013154 ± 7.91854e-05 (W 9.43096e-05) | 0.011291 ± 0.0001367 (W 0.000101515) | 0.019846 ± 6.35085e-05 (W 8.19469e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057988 ± 0.000316212 (W 0.000173909) | 0.052737 ± 1.53948e-05 (W 0.000392928) | 0.096419 ± 0.000602854 (W 0.000150207) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.190393 ± 0.00168077 (W 0.00209961) | 0.177251 ± 0.00125823 (W 0.0019398) | 0.30018 ± 0.00198372 (W 0.00275576) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014356 ± 6.75056e-05 (W 6.05913e-05) | 0.012343 ± 0.000172434 (W 0.000107346) | 0.020107 ± 3.05505e-05 (W 4.97021e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.05962 ± 0.000234564 (W 0.000138914) | 0.054451 ± 0.000212605 (W 0.00041515) | 0.094275 ± 0.000588859 (W 0.00160914) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.201295 ± 0.0018372 (W 0.00296212) | 0.188318 ± 0.00179099 (W 0.00263691) | 0.252551 ± 0.000495163 (W 0.00169665) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005199 ± 5.50757e-06 (W 3.12618e-05) | 0.00519 ± 4.04145e-05 (W 2.70056e-05) | 0.008937 ± 3.78594e-05 (W 4.26063e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030196 ± 0.000315902 (W 6.06407e-05) | 0.030236 ± 7.54983e-05 (W 6.08136e-05) | 0.051336 ± 0.000517912 (W 0.000273619) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103022 ± 0.000509047 (W 0.0011498) | 0.103011 ± 0.00114526 (W 0.00147612) | 0.137986 ± 0.000208164 (W 0.00130772) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017583 ± 6.02771e-05 (W 5.02991e-05) | 0.015649 ± 8.02081e-05 (W 5.47376e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09732 ± 0.000447573 (W 0.00175802) | 0.091601 ± 0.000203726 (W 0.000520007) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.317753 ± 0.000714963 (W 0.00178374) | 0.304142 ± 0.000885423 (W 0.00370715) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013194 ± 0.000350543 (W 0.000115542) | 0.011241 ± 5.85947e-05 (W 5.48835e-05) | 0.019856 ± 7.26659e-05 (W 5.71839e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058068 ± 0.000183058 (W 0.000191216) | 0.052488 ± 0.000286335 (W 0.000331067) | 0.095397 ± 0.000367919 (W 0.0012342) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.189734 ± 0.00127842 (W 0.00342356) | 0.192616 ± 0.00155741 (W 0.00262791) | 0.263617 ± 0.011953 (W 0.00452268) | · | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014287 ± 9.23598e-05 (W 0.000109281) | 0.012443 ± 0.000102144 (W 0.000112802) | 0.020247 ± 6.02246e-05 (W 7.59552e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060111 ± 0.000515326 (W 0.000224578) | 0.05444 ± 0.000184782 (W 0.000307344) | 0.092832 ± 0.000587992 (W 0.0010434) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.205532 ± 0.000774388 (W 0.0025706) | 0.205041 ± 0.00294387 (W 0.00329638) | 0.236587 ± 0.000273964 (W 0.00161585) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00523 ± 2.51661e-05 (W 2.68328e-05) | 0.00516 ± 5.72742e-05 (W 4.30732e-05) | 0.008977 ± 0.00014526 (W 3.03315e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029825 ± 0.00028564 (W 6.02495e-05) | 0.030156 ± 0.000313072 (W 3.4195e-05) | 0.051535 ± 0.00048305 (W 0.00162411) | · | 🔵 fork 1.73× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.110907 ± 0.000285553 (W 0.00284773) | 0.110806 ± 0.000674525 (W 0.00248328) | 0.141474 ± 0.000622735 (W 0.00133073) | · | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017663 ± 5.18684e-05 (W 0.000112478) | 0.015729 ± 5.50757e-05 (W 0.000125496) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097139 ± 0.000352204 (W 0.00110286) | 0.09172 ± 0.000251854 (W 0.00122764) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319122 ± 0.00229903 (W 0.00216058) | 0.306361 ± 0.00186339 (W 0.00331439) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012954 ± 0.000142818 (W 0.000131682) | 0.011271 ± 7.54983e-05 (W 0.000187964) | 0.019917 ± 6.55744e-05 (W 6.26993e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058419 ± 0.000282153 (W 0.000526813) | 0.052397 ± 0.000366102 (W 0.0015296) | 0.096359 ± 0.000136163 (W 0.00105189) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.189824 ± 0.00184438 (W 0.00231162) | 0.20364 ± 0.00240649 (W 0.00690225) | 0.244797 ± 0.0150316 (W 0.0016596) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014327 ± 5.1316e-05 (W 8.06238e-05) | 0.012493 ± 0.00015695 (W 0.000106204) | 0.020197 ± 4.55741e-05 (W 6.44461e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060682 ± 0.000383445 (W 0.00040627) | 0.054842 ± 0.000969139 (W 0.00120255) | 0.093153 ± 0.000638348 (W 0.00103418) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.200964 ± 0.00262876 (W 0.00398043) | 0.215899 ± 0.00243358 (W 0.0027261) | 0.235867 ± 0.000467167 (W 0.00166671) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00518 ± 5.45008e-05 (W 3.11448e-05) | 0.005179 ± 6.35085e-06 (W 3.55148e-05) | 0.008055 ± 8.5049e-05 (W 2.58844e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030075 ± 3.12143e-05 (W 5.58238e-05) | 0.030046 ± 8.88819e-05 (W 6.87023e-05) | 0.043541 ± 0.000420916 (W 9.07871e-05) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083255 ± 0.000277519 (W 9.52434e-05) | 0.083233 ± 0.000125157 (W 0.000137132) | 0.125703 ± 0.000424421 (W 0.00145922) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01569 ± 9.16588e-05 (W 0.000108841) | 0.015739 ± 0.000106353 (W 6.92553e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090177 ± 8.68581e-05 (W 0.000264151) | 0.090497 ± 0.000201174 (W 0.00127685) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.301953 ± 0.00213662 (W 0.00230887) | 0.305497 ± 0.00177916 (W 0.00236148) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011231 ± 0.000205218 (W 5.6745e-05) | 0.011421 ± 0.000329955 (W 0.000144652) | 0.017502 ± 5.50757e-05 (W 5.29273e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050725 ± 0.000204309 (W 0.000137384) | 0.051116 ± 0.000138818 (W 0.00011677) | 0.086009 ± 0.00030677 (W 0.0014678) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.173273 ± 0.000445574 (W 0.00340468) | 0.174464 ± 0.00273521 (W 0.00222156) | 0.225651 ± 0.000572653 (W 0.00110731) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012343 ± 2.51661e-05 (W 3.57771e-05) | 0.012563 ± 0.000133418 (W 0.000128725) | 0.017262 ± 3.21455e-05 (W 0.000105286) | · | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052667 ± 0.000118731 (W 0.000111041) | 0.052768 ± 0.000144777 (W 0.00132725) | 0.083174 ± 0.000205218 (W 0.000191811) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.185513 ± 0.00311795 (W 0.00357955) | 0.186244 ± 0.00175747 (W 0.00286055) | 0.21959 ± 0.000425409 (W 0.00112283) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005179 ± 0.000127307 (W 2.78622e-05) | 0.005189 ± 5.80259e-05 (W 3.23929e-05) | 0.007915 ± 0.000126623 (W 9.29096e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029866 ± 0.000197707 (W 6.28435e-05) | 0.030066 ± 0.000186405 (W 0.000103967) | 0.043341 ± 0.000182748 (W 0.000107811) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103192 ± 0.00108462 (W 0.00171129) | 0.101889 ± 0.00015047 (W 0.00101907) | 0.125612 ± 0.000831097 (W 0.00107065) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015759 ± 0.000145717 (W 8.06052e-05) | 0.015699 ± 8.5967e-05 (W 6.85514e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089796 ± 0.000241056 (W 0.000434172) | 0.090008 ± 0.000425129 (W 0.000204842) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.304068 ± 0.00038085 (W 0.00208331) | 0.30299 ± 0.00021315 (W 0.00161547) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011341 ± 0.00022646 (W 8.84828e-05) | 0.011281 ± 6e-05 (W 0.000108084) | 0.017573 ± 6.45006e-05 (W 6.73053e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050975 ± 0.000112694 (W 0.00130564) | 0.050804 ± 0.000123087 (W 0.000207799) | 0.08564 ± 0.000130347 (W 0.00108153) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.176618 ± 0.00213797 (W 0.0022938) | 0.186595 ± 0.00400943 (W 0.0043235) | 0.224084 ± 8.1265e-05 (W 0.00137954) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012253 ± 3.84318e-05 (W 3.20936e-05) | 0.012323 ± 0.000147309 (W 8.17313e-05) | 0.017282 ± 4.58258e-05 (W 7.19722e-05) | · | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052989 ± 0.000581609 (W 0.000200004) | 0.052858 ± 0.000293793 (W 0.000279376) | 0.082884 ± 0.000195021 (W 0.000245042) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.188438 ± 0.00209408 (W 0.00271201) | 0.201817 ± 0.00278117 (W 0.00417542) | 0.218113 ± 0.000231656 (W 0.00146256) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005189 ± 3.50761e-05 (W 3.24238e-05) | 0.00513 ± 4.52806e-05 (W 1.31643e-05) | 0.007975 ± 0.000135277 (W 3.34664e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029845 ± 0.000295127 (W 0.00125709) | 0.029886 ± 0.000180888 (W 0.000116748) | 0.043341 ± 3.05014e-05 (W 8.24148e-05) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.110666 ± 0.000441464 (W 0.0028786) | 0.110355 ± 0.000612354 (W 0.00308014) | 0.125712 ± 0.00155033 (W 0.00159537) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015649 ± 3.51188e-05 (W 9.73822e-05) | 0.015719 ± 5.68624e-05 (W 9.15434e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089675 ± 0.000254095 (W 0.000375988) | 0.089676 ± 0.000361017 (W 0.00170106) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.301222 ± 0.00280257 (W 0.00457549) | 0.304588 ± 0.000132952 (W 0.00261691) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011191 ± 8.96289e-05 (W 0.000137063) | 0.011551 ± 0.000401183 (W 0.000105509) | 0.017532 ± 6.87047e-05 (W 7.96386e-05) | · | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051095 ± 0.000189315 (W 0.00150226) | 0.051205 ± 0.000874961 (W 0.000260426) | 0.085258 ± 7.13933e-05 (W 0.00140642) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174656 ± 0.00036605 (W 0.0025831) | 0.198909 ± 0.00145155 (W 0.00478769) | 0.224328 ± 0.000253129 (W 0.00121103) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012363 ± 5.03322e-05 (W 9.51751e-05) | 0.012353 ± 7.6922e-05 (W 8.90966e-05) | 0.017202 ± 4.93288e-05 (W 5.77062e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052948 ± 0.000365596 (W 0.000213561) | 0.052547 ± 0.000788968 (W 0.00031611) | 0.082955 ± 4.51331e-05 (W 0.000241583) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.18834 ± 0.00221229 (W 0.00269805) | 0.211625 ± 0.00157302 (W 0.00403173) | 0.217523 ± 0.000302888 (W 0.00181717) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070241 ± 0.000276022 (W 0.00109622) | 0.066764 ± 0.000398375 (W 0.000985687) | 0.114662 ± 0.000784882 (W 0.000547083) | 🔴 fork 1.05× slower than `faer-upstream` | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.388916 ± 0.00341767 (W 0.00196796) | 0.383515 ± 0.00919284 (W 0.00129331) | 0.639914 ± 0.00278236 (W 0.002195) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.53702 ± 0.0120233 (W 0.00421104) | 2.54575 ± 0.0183857 (W 0.00688833) | 4.02596 ± 0.00790754 (W 0.0352575) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.311902 ± 0.00184797 (W 0.00203536) | 0.313012 ± 0.0013666 (W 0.00411427) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70541 ± 0.00438868 (W 0.00807207) | 2.7507 ± 0.0132744 (W 0.00881611) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.673 ± 0.0216688 (W 0.047269) | 22.3123 ± 0.166311 (W 0.054435) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.133587 ± 0.0186763 (W 0.00156984) | 0.138158 ± 0.017592 (W 0.00297074) | 0.170245 ± 0.0183949 (W 0.00167889) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.98113 ± 0.115773 (W 0.00295925) | 1.05562 ± 0.0137184 (W 0.00477332) | 0.979593 ± 0.130019 (W 0.00270121) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.62144 ± 0.0226287 (W 0.0179699) | 7.1779 ± 0.119228 (W 0.0209659) | 6.98006 ± 0.0343034 (W 0.0108098) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.135463 ± 0.00180175 (W 0.00193484) | 0.136885 ± 0.00159777 (W 0.00231374) | 0.170195 ± 0.000926636 (W 0.00204603) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.747033 ± 0.00173578 (W 0.00279216) | 0.805603 ± 0.00275172 (W 0.00258505) | 0.967801 ± 0.00392875 (W 0.00273087) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.52062 ± 0.047151 (W 0.0175754) | 7.19745 ± 0.103392 (W 0.0152321) | 5.99304 ± 0.0108588 (W 0.0094371) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.088434 ± 0.000440807 (W 0.00154183) | 0.103503 ± 0.00315058 (W 0.00650401) | 0.114282 ± 0.000829338 (W 0.00107307) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.402735 ± 0.0158054 (W 0.0109729) | 0.402017 ± 0.00997756 (W 0.0196509) | 0.40739 ± 0.00112237 (W 0.00295688) | · | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.60985 ± 0.0147347 (W 0.0259956) | 1.68046 ± 0.0291935 (W 0.022622) | 1.94917 ± 0.0155132 (W 0.0107404) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309898 ± 0.000749154 (W 0.00468489) | 0.314392 ± 0.00321264 (W 0.0021703) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7177 ± 0.0110258 (W 0.00897255) | 2.77703 ± 0.0151331 (W 0.00895736) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4865 ± 0.174737 (W 0.385683) | 17.9699 ± 0.0633365 (W 0.144429) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134741 ± 0.0182265 (W 0.00105338) | 0.203129 ± 0.0205283 (W 0.00934485) | 0.151542 ± 0.012692 (W 0.00139422) | 🔵 fork 1.51× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.986503 ± 0.11781 (W 0.00288454) | 1.19091 ± 0.010682 (W 0.0214544) | 0.38091 ± 0.111611 (W 0.00378772) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 2.59× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.8217 ± 0.0383518 (W 0.0390665) | 5.58042 ± 0.0354897 (W 0.0504592) | 2.62442 ± 0.0113139 (W 0.0126041) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.13473 ± 0.000422116 (W 0.00141749) | 0.199922 ± 0.00275486 (W 0.00774294) | 0.15016 ± 0.000529008 (W 0.00129552) | 🔵 fork 1.48× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.765257 ± 0.00563029 (W 0.00332853) | 0.914734 ± 0.0171267 (W 0.0269527) | 0.366929 ± 0.0014415 (W 0.00256685) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.81666 ± 0.0564397 (W 0.103694) | 5.49953 ± 0.047549 (W 0.0222572) | 1.79752 ± 0.0283977 (W 0.00238333) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 2.68× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.096049 ± 0.00239644 (W 0.00336927) | 0.108281 ± 0.00463902 (W 0.00477232) | 0.114543 ± 0.000638302 (W 0.000405719) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.406407 ± 0.00277958 (W 0.0250336) | 0.45862 ± 0.0247302 (W 0.0175548) | 0.358604 ± 0.00334233 (W 0.00322225) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.52867 ± 0.0185942 (W 0.0209075) | 1.61187 ± 0.0501653 (W 0.0402086) | 1.46665 ± 0.00826768 (W 0.0122148) | 🔵 fork 1.05× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.313533 ± 0.00322817 (W 0.0018785) | 0.31224 ± 0.000987619 (W 0.00405241) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7033 ± 0.012295 (W 0.0108292) | 2.75665 ± 0.0114702 (W 0.0103661) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4075 ± 0.0607692 (W 0.0447275) | 17.9132 ± 0.123304 (W 0.146083) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.165747 ± 0.00189198 (W 0.00125804) | 0.223995 ± 0.0202613 (W 0.00579389) | 0.189952 ± 0.0245174 (W 0.00506824) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.992584 ± 0.123423 (W 0.00308104) | 1.26817 ± 0.00742346 (W 0.0206399) | 0.346943 ± 0.158407 (W 0.00387133) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 2.86× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.58242 ± 0.10663 (W 0.0188292) | 5.75054 ± 0.121107 (W 0.0739444) | 2.27256 ± 0.0790508 (W 0.00947959) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.133779 ± 0.00137127 (W 0.000332607) | 0.216481 ± 0.00638822 (W 0.0110134) | 0.146159 ± 0.000113192 (W 0.00138824) | 🔵 fork 1.62× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.76179 ± 0.000762179 (W 0.00327746) | 0.946283 ± 0.0115504 (W 0.0131231) | 0.33366 ± 0.00317615 (W 0.00270304) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.59741 ± 0.0289861 (W 0.0308546) | 5.55248 ± 0.0315196 (W 0.0452603) | 1.31193 ± 0.0229089 (W 0.00456862) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 3.50× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063379 ± 0.00341671 (W 0.00103409) | 0.060162 ± 0.00216087 (W 7.01427e-05) | 0.094495 ± 0.002061 (W 0.000196513) | · | 🔵 fork 1.49× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.320192 ± 0.00471892 (W 0.00231041) | 0.320899 ± 0.00703366 (W 0.00231468) | 0.449362 ± 0.00258358 (W 0.00313144) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06637 ± 0.00323265 (W 0.00241629) | 2.06142 ± 0.00169793 (W 0.0028708) | 3.35356 ± 0.0306257 (W 0.0186539) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290943 ± 0.0018218 (W 0.00181832) | 0.28997 ± 0.000923658 (W 0.00206053) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62019 ± 0.0113616 (W 0.0051486) | 2.6209 ± 0.0064184 (W 0.00791543) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.1876 ± 0.0301583 (W 0.139951) | 21.1275 ± 0.0160011 (W 0.020766) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.144069 ± 0.000873895 (W 0.000629123) | 0.144768 ± 0.00111799 (W 0.00165562) | 0.133379 ± 0.00123201 (W 0.00187159) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.698843 ± 0.117037 (W 0.00206998) | 0.695197 ± 0.116701 (W 0.00243798) | 0.816146 ± 0.00144412 (W 0.00312612) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.11121 ± 0.021907 (W 0.0099339) | 6.11771 ± 0.0157283 (W 0.00928987) | 5.20812 ± 0.014008 (W 0.0142406) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111216 ± 0.000313644 (W 0.00017637) | 0.112749 ± 0.00114761 (W 0.00129556) | 0.133006 ± 0.000738932 (W 0.00153315) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.663963 ± 0.00489817 (W 0.00291011) | 0.662686 ± 0.00408794 (W 0.00245653) | 0.812955 ± 0.0015923 (W 0.00239103) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.04475 ± 0.0546981 (W 0.0125576) | 6.06517 ± 0.037239 (W 0.0115831) | 5.2478 ± 0.01485 (W 0.0106397) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.080499 ± 0.00127312 (W 0.00336501) | 0.094836 ± 0.00108043 (W 0.00513206) | 0.091029 ± 0.00164847 (W 0.000670985) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.331726 ± 0.0176796 (W 0.0179279) | 0.352633 ± 0.0162994 (W 0.023459) | 0.24121 ± 0.019268 (W 0.00484251) | · | 🔴 fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.11056 ± 0.0184089 (W 0.0241608) | 1.20495 ± 0.00107969 (W 0.0292809) | 1.40866 ± 0.0142539 (W 0.00321238) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.291812 ± 0.000375352 (W 0.00149887) | 0.290858 ± 0.0014898 (W 0.00231016) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6278 ± 0.0083743 (W 0.0088097) | 2.62792 ± 0.0168442 (W 0.0152347) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8823 ± 0.22819 (W 0.137128) | 16.946 ± 0.119668 (W 0.134382) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.144628 ± 0.000518385 (W 0.00196303) | 0.215601 ± 0.00123581 (W 0.00656958) | 0.132227 ± 0.000427098 (W 0.00153959) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.706598 ± 0.115937 (W 0.00568776) | 0.842021 ± 0.107043 (W 0.0199465) | 0.329435 ± 0.00187808 (W 0.00313698) | · | 🔴 fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.28747 ± 0.0268978 (W 0.0453399) | 4.59392 ± 0.0955011 (W 0.0708112) | 1.63352 ± 0.0111433 (W 0.00559642) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 2.62× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112569 ± 0.00033105 (W 0.00150718) | 0.185985 ± 0.00811959 (W 0.00685696) | 0.131665 ± 0.000511803 (W 0.00142032) | 🔵 fork 1.65× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.676822 ± 0.00625894 (W 0.00259763) | 0.765478 ± 0.0103637 (W 0.0157905) | 0.312719 ± 0.00300081 (W 0.00289389) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.20233 ± 0.0334205 (W 0.0261859) | 4.36796 ± 0.0484164 (W 0.0308585) | 1.63354 ± 0.0141977 (W 0.00370842) | · | 🔴 fork 2.57× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.087412 ± 0.000447754 (W 0.00152728) | 0.100547 ± 0.00118609 (W 0.00126298) | 0.09134 ± 0.000349961 (W 0.00186473) | 🔵 fork 1.15× faster than `faer-upstream` | · |  |
| `cholesky/n256/b1` | 0.343188 ± 0.00418532 (W 0.0192346) | 0.396816 ± 0.0149655 (W 0.0205329) | 0.193946 ± 0.00126182 (W 0.0037026) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.05306 ± 0.0177346 (W 0.0153171) | 1.19105 ± 0.0110175 (W 0.0239204) | 0.965729 ± 0.0126829 (W 0.0117742) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289097 ± 0.0018574 (W 0.00239513) | 0.289065 ± 0.000843298 (W 0.00178073) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6218 ± 0.0068241 (W 0.00780328) | 2.63152 ± 0.00844561 (W 0.00440023) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8104 ± 0.128216 (W 0.0524203) | 16.8304 ± 0.0853864 (W 0.176093) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.114354 ± 0.0180604 (W 0.000455636) | 0.197268 ± 0.0193647 (W 0.00649915) | 0.133117 ± 0.00109079 (W 0.00189328) | 🔵 fork 1.73× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.706838 ± 0.116195 (W 0.00215076) | 0.927939 ± 0.133329 (W 0.0219357) | 0.317529 ± 0.001697 (W 0.00228626) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 2.23× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.16144 ± 0.0385526 (W 0.0846895) | 4.75306 ± 0.0300532 (W 0.0544973) | 1.23813 ± 0.0101184 (W 0.00544336) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 3.36× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112088 ± 0.000309107 (W 0.00117575) | 0.18314 ± 0.000683514 (W 0.00657329) | 0.131804 ± 0.000373698 (W 0.000232387) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.676176 ± 0.00205317 (W 0.00215064) | 0.827882 ± 0.0106415 (W 0.0331279) | 0.302056 ± 0.00163145 (W 0.00185904) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 2.24× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.07249 ± 0.00167153 (W 0.0238838) | 4.63157 ± 0.0833772 (W 0.0912849) | 1.19981 ± 0.013179 (W 0.0055048) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 3.39× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.187657 ± 0.000556598 (W 0.00119011) | 0.187991 ± 0.000533579 (W 0.000742209) | 0.474916 ± 0.00249753 (W 0.00243171) | · | 🔵 fork 2.53× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.22344 ± 0.0199219 (W 0.00260335) | 1.22029 ± 0.00395895 (W 0.00358856) | 1.85417 ± 0.0154408 (W 0.00476967) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.89904 ± 0.0107323 (W 0.00874663) | 7.91196 ± 0.0439467 (W 0.00824507) | 11.3753 ± 0.0120797 (W 0.017006) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.774108 ± 0.0333736 (W 0.00712809) | 0.779723 ± 0.0265565 (W 0.00480358) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.90551 ± 0.12901 (W 0.00906998) | 6.05996 ± 0.101477 (W 0.0157701) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 43.3643 ± 0.73043 (W 0.0817765) | 43.1356 ± 0.413708 (W 0.0894702) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.32421 ± 0.000129639 (W 0.00225676) | 0.32707 ± 0.00283005 (W 0.00286439) | 0.501957 ± 0.0024557 (W 0.00249895) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.11118 ± 0.00476789 (W 0.00163093) | 2.20817 ± 0.00581959 (W 0.00547932) | 3.31021 ± 0.0100547 (W 0.00756765) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.3301 ± 0.0488861 (W 0.0361508) | 17.3717 ± 0.0465303 (W 0.0193365) | 23.1469 ± 0.0165862 (W 0.0336247) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.320077 ± 0.00301841 (W 0.00192579) | 0.324611 ± 0.0016876 (W 0.00231041) | 0.489175 ± 0.00167449 (W 0.00241102) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.04725 ± 0.00773962 (W 0.00165097) | 2.1428 ± 0.010826 (W 0.00851674) | 2.82503 ± 0.00715857 (W 0.00484695) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 17.8973 ± 0.0369415 (W 0.0510369) | 17.8901 ± 0.0840963 (W 0.0162762) | 18.8049 ± 0.0451764 (W 0.0444089) | · | · |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.18875 ± 0.00125693 (W 0.00334709) | 0.200042 ± 0.00147168 (W 0.00334094) | 0.475483 ± 0.00182694 (W 0.00431186) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 2.52× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.846313 ± 0.00271481 (W 0.00439516) | 0.869933 ± 0.00659671 (W 0.00977561) | 0.794787 ± 0.00793505 (W 0.00937728) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.37759 ± 0.0182269 (W 0.0159742) | 3.40685 ± 0.0167499 (W 0.0309132) | 3.66802 ± 0.0269539 (W 0.0151403) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.768944 ± 0.00140919 (W 0.00419233) | 0.776399 ± 0.0031208 (W 0.00535292) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.88133 ± 0.0310748 (W 0.0154525) | 6.06187 ± 0.0179473 (W 0.0232932) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.6977 ± 0.190805 (W 0.0407144) | 29.6262 ± 0.12941 (W 0.205008) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.322601 ± 0.00106597 (W 0.0024932) | 0.338567 ± 0.00190748 (W 0.00631705) | 0.481785 ± 0.00720247 (W 0.00289564) | · | 🔵 fork 1.49× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.11689 ± 0.00631426 (W 0.0105604) | 1.67262 ± 0.00936132 (W 0.0195996) | 1.01184 ± 0.00416054 (W 0.0059611) | 🔴 fork 1.27× slower than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.7632 ± 0.0311604 (W 0.096049) | 9.917 ± 0.0245252 (W 0.0215475) | 7.59446 ± 0.00433902 (W 0.0225161) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.321297 ± 0.000647556 (W 0.00175971) | 0.333448 ± 0.00151283 (W 0.00477534) | 0.467933 ± 0.00252579 (W 0.00297921) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.0633 ± 0.00217219 (W 0.00539643) | 1.54481 ± 0.0122747 (W 0.0209486) | 0.897234 ± 0.00362023 (W 0.00400668) | 🔴 fork 1.34× slower than `faer-upstream` | 🔴 fork 2.30× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 11.3696 ± 0.0616859 (W 0.111968) | 10.3853 ± 0.0901035 (W 0.0315638) | 5.62037 ± 0.0616679 (W 0.0163569) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.02× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.19368 ± 0.00114203 (W 0.00166928) | 0.21159 ± 0.000758396 (W 0.00297432) | 0.475892 ± 0.00101749 (W 0.00324305) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 2.46× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.844816 ± 0.0102913 (W 0.0171934) | 0.882811 ± 0.0106124 (W 0.0182854) | 0.661946 ± 0.00398013 (W 0.00281431) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.79652 ± 0.0113237 (W 0.0168065) | 2.8657 ± 0.0868951 (W 0.0193017) | 2.25079 ± 0.0256812 (W 0.01136) | · | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.771995 ± 0.00838796 (W 0.00646495) | 0.782344 ± 0.00353417 (W 0.00717403) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.89311 ± 0.00147703 (W 0.0256042) | 6.03979 ± 0.0188071 (W 0.018721) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.949 ± 0.096353 (W 0.11437) | 27.9808 ± 0.0393488 (W 0.174019) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.323099 ± 0.000401359 (W 0.00231909) | 0.36958 ± 0.00336302 (W 0.0109787) | 0.487756 ± 0.00925191 (W 0.00267299) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.14485 ± 0.0137719 (W 0.0224464) | 1.68677 ± 0.0146093 (W 0.0193103) | 0.698053 ± 0.00153988 (W 0.00573799) | 🔴 fork 1.27× slower than `faer-upstream` | 🔴 fork 3.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.70722 ± 0.0225286 (W 0.0334133) | 8.81743 ± 0.0645429 (W 0.0690142) | 5.03873 ± 0.0221116 (W 0.0252487) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.320269 ± 0.000665865 (W 0.00271475) | 0.355611 ± 0.00392779 (W 0.00594034) | 0.471393 ± 0.0017577 (W 0.00272418) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.08794 ± 0.0376608 (W 0.0237026) | 1.52475 ± 0.00864133 (W 0.0224165) | 0.668149 ± 0.00163705 (W 0.00237635) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 3.12× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.2584 ± 0.0952578 (W 0.0532933) | 9.33744 ± 0.56515 (W 0.0319431) | 3.44059 ± 0.0111363 (W 0.0086455) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 2.98× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174606 ± 0.000875936 (W 0.00169402) | 0.174853 ± 0.000306009 (W 0.00127698) | 0.409494 ± 0.00105062 (W 0.0026014) | · | 🔵 fork 2.35× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.12933 ± 0.000721675 (W 0.00105909) | 1.12712 ± 0.00192371 (W 0.00277717) | 1.60064 ± 0.00199584 (W 0.00248287) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.54675 ± 0.0207083 (W 0.0094518) | 7.51824 ± 0.020731 (W 0.0124298) | 10.5734 ± 0.0165595 (W 0.018772) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.749292 ± 0.032715 (W 0.00861149) | 0.754777 ± 0.0225115 (W 0.00448182) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.76324 ± 0.142841 (W 0.0120892) | 5.77726 ± 0.140866 (W 0.00972216) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 42.0557 ± 0.534063 (W 0.104352) | 42.1565 ± 0.365308 (W 0.109972) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.294956 ± 0.000399922 (W 0.0017348) | 0.294297 ± 0.00297901 (W 0.00383835) | 0.465599 ± 0.00449172 (W 0.00280906) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.99902 ± 0.0105449 (W 0.00597133) | 2.00668 ± 0.0113218 (W 0.00609352) | 3.23488 ± 0.0187029 (W 0.00811053) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.3739 ± 0.0432219 (W 0.0288298) | 16.4297 ± 0.0316023 (W 0.0268051) | 20.246 ± 0.0744117 (W 0.0319422) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.293263 ± 0.00120971 (W 0.00189854) | 0.292041 ± 0.00135919 (W 0.00251267) | 0.44526 ± 0.00195722 (W 0.00186363) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93271 ± 0.00970362 (W 0.00272869) | 1.92742 ± 0.00989918 (W 0.00187219) | 2.65875 ± 0.00398829 (W 0.00944228) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 16.9357 ± 0.0486188 (W 0.0930226) | 16.8321 ± 0.0677092 (W 0.0430632) | 17.5125 ± 0.0272762 (W 0.0231723) | · | · |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176758 ± 0.00105893 (W 0.00310637) | 0.190123 ± 0.000641575 (W 0.00340619) | 0.410093 ± 0.000451578 (W 0.00307032) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.32× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.75594 ± 0.00303175 (W 0.00915099) | 0.778622 ± 0.00509547 (W 0.0103819) | 0.585765 ± 0.00189438 (W 0.00924824) | · | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.00867 ± 0.0198901 (W 0.0144895) | 3.06219 ± 0.0178623 (W 0.0206889) | 3.21244 ± 0.00401231 (W 0.0179086) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.742575 ± 0.00224456 (W 0.00604175) | 0.747705 ± 0.00237082 (W 0.00688529) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.73278 ± 0.0319968 (W 0.00975358) | 5.76915 ± 0.0282531 (W 0.0166852) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.4579 ± 0.078914 (W 0.0726157) | 28.4238 ± 0.124159 (W 0.123436) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.294768 ± 0.000362688 (W 0.00197455) | 0.310299 ± 0.0083993 (W 0.00900477) | 0.458515 ± 0.00141508 (W 0.00177599) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 2.01291 ± 0.00831801 (W 0.0105457) | 1.47144 ± 0.00873248 (W 0.0240994) | 0.972802 ± 0.000572867 (W 0.00378108) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.6972 ± 0.064877 (W 0.110048) | 9.05535 ± 0.0613515 (W 0.0306794) | 5.80665 ± 0.0332003 (W 0.0105535) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.67× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.291782 ± 0.000560758 (W 0.00171112) | 0.302202 ± 0.00245251 (W 0.00519013) | 0.446477 ± 0.00180778 (W 0.00233569) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.94509 ± 0.0132785 (W 0.00286887) | 1.32873 ± 0.0146078 (W 0.0147997) | 0.857113 ± 0.00152916 (W 0.00353624) | 🔴 fork 1.46× slower than `faer-upstream` | 🔴 fork 2.27× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.314 ± 0.069723 (W 0.0998112) | 9.36379 ± 0.0842797 (W 0.0374352) | 5.3795 ± 0.0549061 (W 0.00909769) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.92× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.181243 ± 0.000457884 (W 0.00416118) | 0.200711 ± 0.0016834 (W 0.00399488) | 0.409142 ± 0.00184708 (W 0.00370069) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 2.26× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.745812 ± 0.00550755 (W 0.017581) | 0.778703 ± 0.00652322 (W 0.0164244) | 0.45882 ± 0.00433797 (W 0.00345474) | · | 🔴 fork 1.63× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.43538 ± 0.0160648 (W 0.022296) | 2.47054 ± 0.0217192 (W 0.0137089) | 1.86151 ± 0.0209528 (W 0.0136354) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.742496 ± 0.00320669 (W 0.00801677) | 0.746633 ± 0.00136673 (W 0.00488449) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.75343 ± 0.00970893 (W 0.0138945) | 5.76569 ± 0.0191319 (W 0.0165583) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.9947 ± 0.0407626 (W 0.202962) | 26.8876 ± 0.12429 (W 0.318097) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295383 ± 0.00024682 (W 0.00207278) | 0.332106 ± 0.000511539 (W 0.00483566) | 0.458152 ± 0.00108045 (W 0.00230536) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.01939 ± 0.00870855 (W 0.0244168) | 1.46803 ± 0.00507073 (W 0.0218635) | 0.677626 ± 0.00575991 (W 0.00451218) | 🔴 fork 1.38× slower than `faer-upstream` | 🔴 fork 2.98× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.66691 ± 0.0112053 (W 0.0403279) | 8.00572 ± 0.0253301 (W 0.0414898) | 3.47847 ± 0.0124035 (W 0.00773189) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 2.49× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.290539 ± 0.00113889 (W 0.0018322) | 0.325894 ± 2.48519 (W 0.00548932) | 0.44675 ± 0.00226829 (W 0.00242642) | · | 🔵 fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n256/b1` | 1.96407 ± 0.00330903 (W 0.0128786) | 1.30516 ± 0.00828133 (W 0.0317762) | 0.648366 ± 0.00395711 (W 0.00423214) | 🔴 fork 1.50× slower than `faer-upstream` | 🔴 fork 3.03× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.18487 ± 0.0488945 (W 0.109175) | 8.38435 ± 0.0268298 (W 0.096437) | 3.35138 ± 0.0406762 (W 0.00574955) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 2.74× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.812235 ± 0.00588051 (W 0.0106658) | 0.819985 ± 0.00379715 (W 0.00989468) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.231 ± 0.559917 (W 0.355344) | 55.239 ± 0.710462 (W 1.27728) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.465923 ± 0.00191358 (W 0.00370044) | 0.471093 ± 0.0011873 (W 0.00392062) | 0.658741 ± 0.133961 (W 0.00449085) | · | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.3663 ± 0.124994 (W 0.093399) | 18.9683 ± 0.054919 (W 0.0360191) | 17.9395 ± 2.65103 (W 0.118848) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.812296 ± 0.00262802 (W 0.002871) | 0.816568 ± 0.011629 (W 0.00644336) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.9425 ± 0.182356 (W 0.237666) | 25.3955 ± 1.20437 (W 0.213559) | - | 🔵 fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.492293 ± 0.000641743 (W 0.0141167) | 0.502592 ± 0.00935023 (W 0.010725) | 0.535172 ± 0.119319 (W 0.00703444) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.43866 ± 0.149803 (W 0.128759) | 13.067 ± 0.0243314 (W 0.0327602) | 13.3232 ± 1.78654 (W 0.0446362) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.811605 ± 0.00160195 (W 0.00228663) | 0.816634 ± 0.00567128 (W 0.00900613) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.9598 ± 0.121965 (W 0.0849783) | 19.4519 ± 0.0794391 (W 0.121719) | - | 🔵 fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.479361 ± 0.00160266 (W 0.00539068) | 0.520128 ± 0.00650302 (W 0.0118498) | 0.605806 ± 0.169311 (W 0.00329034) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.78599 ± 0.133255 (W 0.140693) | 12.2234 ± 0.0123406 (W 0.0494305) | 4.11478 ± 1.90495 (W 0.0363684) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731386 ± 0.0016186 (W 0.00213315) | 0.732248 ± 0.00187131 (W 0.00663802) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.0018 ± 0.445978 (W 0.145846) | 47.1372 ± 0.467366 (W 0.137596) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.384322 ± 0.00135198 (W 0.00310674) | 0.384663 ± 0.00133336 (W 0.00211989) | 0.287569 ± 0.00136356 (W 0.00167403) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2425 ± 0.0148545 (W 0.0184973) | 13.2494 ± 0.00378486 (W 0.0190972) | 11.7348 ± 0.0249129 (W 0.0164167) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.732759 ± 0.000878488 (W 0.00285169) | 0.732288 ± 0.00171084 (W 0.00212784) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.8585 ± 0.0263031 (W 0.359358) | 17.7594 ± 0.0913871 (W 0.099535) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.407248 ± 0.00263692 (W 0.0138755) | 0.433985 ± 0.00366033 (W 0.00452481) | 0.286682 ± 0.00186973 (W 0.00208065) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.29965 ± 0.0335402 (W 0.0486579) | 7.38306 ± 0.0303843 (W 0.0270816) | 11.5943 ± 0.020684 (W 0.0103563) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.733333 ± 0.0135677 (W 0.00393646) | 0.731016 ± 0.0125816 (W 0.0111942) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.832 ± 0.0246232 (W 0.116264) | 13.5873 ± 0.134898 (W 0.0638845) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.392017 ± 0.0011159 (W 0.00461003) | 0.452103 ± 0.00339097 (W 0.0107275) | 0.286923 ± 0.000805397 (W 0.00300113) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.66173 ± 0.0196267 (W 0.0400134) | 6.70365 ± 0.0160216 (W 0.0313432) | 3.13867 ± 0.0524444 (W 0.00851608) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77916 ± 0.00309965 (W 0.00334976) | 1.82273 ± 0.0257837 (W 0.0026526) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 149.085 ± 0.788049 (W 0.590382) | 155.814 ± 0.31707 (W 0.795126) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.992146 ± 0.00322788 (W 0.00435015) | 0.993107 ± 0.00980903 (W 0.00154219) | 1.18909 ± 0.00166226 (W 0.00355517) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.4317 ± 0.0601756 (W 0.0953887) | 53.77 ± 0.0837945 (W 0.0380231) | 56.2682 ± 5.92282 (W 0.548578) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77576 ± 0.00699924 (W 0.00209785) | 1.82124 ± 0.0154904 (W 0.00243174) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.3553 ± 0.232725 (W 0.861741) | 65.3703 ± 0.295149 (W 1.20796) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.858 ± 0.0126222 (W 0.0105071) | 0.810527 ± 0.00319647 (W 0.0127309) | 1.09295 ± 0.00379511 (W 0.0019361) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.5557 ± 0.32476 (W 0.218709) | 29.6825 ± 0.0553706 (W 0.0832321) | 53.3761 ± 3.77228 (W 0.290617) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 2.37× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77212 ± 0.00678379 (W 0.00425724) | 1.82426 ± 0.0141627 (W 0.00212522) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.7382 ± 0.189534 (W 0.504269) | 41.7936 ± 0.137057 (W 0.379024) | - | 🔵 fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.834487 ± 0.00550565 (W 0.00976823) | 0.791121 ± 0.00672221 (W 0.0138618) | 1.08086 ± 0.00692636 (W 0.00259245) | 🔴 fork 1.05× slower than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 18.8138 ± 0.206397 (W 0.163398) | 25.8551 ± 0.0749219 (W 0.0659622) | 57.3014 ± 3.43707 (W 0.0912851) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 3.05× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66729 ± 0.00570931 (W 0.0028897) | 1.6973 ± 0.00102764 (W 0.00259995) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.841 ± 0.824284 (W 0.514276) | 143.545 ± 0.644652 (W 1.14394) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.872438 ± 0.00465495 (W 0.00265358) | 0.872782 ± 0.00213009 (W 0.00300643) | 1.09418 ± 0.00879231 (W 0.00319085) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 41.7676 ± 0.0550322 (W 0.0521609) | 41.6801 ± 0.0745321 (W 0.0247468) | 50.9803 ± 0.732921 (W 0.0406192) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.65914 ± 0.00726443 (W 0.00358799) | 1.69329 ± 0.00116924 (W 0.0102375) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.1748 ± 0.676505 (W 0.402113) | 52.7961 ± 0.256678 (W 0.710642) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.76521 ± 0.00348992 (W 0.00974688) | 0.707492 ± 0.00375259 (W 0.00675863) | 1.06513 ± 0.00105937 (W 0.00173573) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.2998 ± 0.0523241 (W 0.0731539) | 17.342 ± 0.0732002 (W 0.0495946) | 50.1833 ± 0.373895 (W 0.461594) | · | 🔵 fork 2.90× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.65739 ± 0.00689577 (W 0.00311455) | 1.69541 ± 0.00532078 (W 0.00233458) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 28.926 ± 0.187858 (W 0.208324) | 29.5203 ± 0.41558 (W 0.203183) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.726809 ± 0.00739565 (W 0.00782989) | 0.693415 ± 0.00565057 (W 0.0127212) | 1.06796 ± 0.000865859 (W 0.00145259) | · | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.4415 ± 0.0966159 (W 0.0412483) | 13.5016 ± 0.0488142 (W 0.0428656) | 49.5138 ± 0.636752 (W 0.0729907) | · | 🔵 fork 3.68× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 73.91 ± 0.694188 (W 0.24566) | 77.6929 ± 1.66182 (W 0.497396) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12679 ± 0.0110331 (W 0.00389405) | 1.26297 ± 0.0184414 (W 0.00579607) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 15.9253 ± 0.0505445 (W 0.0506016) | 18.1328 ± 0.0613308 (W 0.0328549) | 72.8861 ± 3.4795 (W 1.67019) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 4.58× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.396391 ± 0.00734168 (W 0.00308909) | 0.515149 ± 0.00358813 (W 0.00241885) | 0.924304 ± 0.1337 (W 0.00262364) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.33× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.4654 ± 0.705406 (W 0.245995) | 40.2196 ± 0.637707 (W 0.253434) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12071 ± 0.0170744 (W 0.00467582) | 1.26831 ± 0.0269971 (W 0.00180909) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.15057 ± 0.0650624 (W 0.0685535) | 9.34128 ± 0.123666 (W 0.0267277) | 10.1704 ± 0.163916 (W 0.0654207) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.225546 ± 0.00184375 (W 0.00306888) | 0.374386 ± 0.0062484 (W 0.0198221) | 0.291482 ± 0.00199296 (W 0.00250027) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.8003 ± 0.297777 (W 0.242578) | 35.0444 ± 0.030742 (W 0.445634) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.1131 ± 0.017412 (W 0.00495517) | 1.25554 ± 0.00995427 (W 0.00374) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.94583 ± 0.0747905 (W 0.109805) | 7.67185 ± 0.125235 (W 0.0572494) | 6.89713 ± 1.5665 (W 0.0290737) | 🔵 fork 1.29× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.209109 ± 0.00116769 (W 0.00392441) | 0.356267 ± 0.0158541 (W 0.0229396) | 0.169172 ± 0.00063392 (W 0.00184258) | 🔵 fork 1.70× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.1925 ± 0.500622 (W 0.28626) | 72.5541 ± 1.85119 (W 0.239029) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.06048 ± 0.00164058 (W 0.00398361) | 1.05413 ± 0.00199995 (W 0.00236937) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3219 ± 0.0807768 (W 0.0201106) | 13.2821 ± 0.0740765 (W 0.00750168) | 210.25 ± 0.29445 (W 0.114741) | · | 🔵 fork 15.78× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.311318 ± 0.000453502 (W 0.0020019) | 0.311604 ± 0.00152614 (W 0.00236139) | 3.12903 ± 0.00375256 (W 0.00293831) | · | 🔵 fork 10.05× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 34.8754 ± 0.206499 (W 0.203645) | 34.8952 ± 0.320229 (W 0.284262) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.06156 ± 0.0140779 (W 0.00222089) | 1.06035 ± 0.00380391 (W 0.00489431) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.39629 ± 0.0213805 (W 0.0474622) | 4.66669 ± 0.0133497 (W 0.0440338) | 5.35379 ± 0.0434787 (W 0.00688641) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.135762 ± 0.00127719 (W 0.00153424) | 0.166359 ± 0.00164764 (W 0.00187043) | 0.234302 ± 0.00297079 (W 0.00239977) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.73× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.0165 ± 0.0953367 (W 0.13554) | 30.0984 ± 0.201951 (W 0.121222) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05524 ± 0.00803005 (W 0.00240784) | 1.05638 ± 0.00683781 (W 0.00379681) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.9243 ± 0.0168883 (W 0.0212693) | 3.32152 ± 0.00758322 (W 0.0298629) | 3.15558 ± 0.0260008 (W 0.00683739) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.114953 ± 0.000894652 (W 0.0030095) | 0.15588 ± 0.00158998 (W 0.0313451) | 0.133296 ± 0.000324596 (W 0.00193683) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 224.938 ± 4.38701 (W 0.545068) | 226.347 ± 4.62707 (W 0.828033) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.36379 ± 0.0582429 (W 0.0174488) | 2.4463 ± 0.0746578 (W 0.0142115) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 45.8964 ± 0.0876048 (W 0.0470443) | 46.5329 ± 0.124659 (W 0.0829699) | 88.0408 ± 0.245307 (W 0.265282) | · | 🔵 fork 1.92× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.995852 ± 0.00229691 (W 0.00317193) | 1.05544 ± 0.00419079 (W 0.00406092) | 2.28443 ± 0.0226293 (W 0.00292551) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 2.29× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.8882 ± 2.52016 (W 0.468355) | 96.6633 ± 2.14785 (W 0.525175) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.39864 ± 0.0391689 (W 0.0105971) | 2.52365 ± 0.0440971 (W 0.0114543) | - | 🔵 fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.5035 ± 0.127228 (W 0.17195) | 18.0248 ± 0.133476 (W 0.124511) | 29.3229 ± 3.30848 (W 0.0764306) | · | 🔵 fork 1.68× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.432394 ± 0.00255452 (W 0.00365649) | 0.492894 ± 0.0244294 (W 0.00598608) | 0.640982 ± 0.00288268 (W 0.00341007) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.1004 ± 0.869053 (W 0.440048) | 70.3049 ± 1.10758 (W 0.76633) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.41276 ± 0.0254205 (W 0.00820875) | 2.52759 ± 0.0840622 (W 0.0180751) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 12.734 ± 0.140969 (W 0.152658) | 12.2243 ± 0.0161639 (W 0.062874) | 18.7858 ± 3.05858 (W 0.0953366) | · | 🔵 fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.351002 ± 0.00138397 (W 0.00450694) | 0.402508 ± 0.00204003 (W 0.00251256) | 0.451851 ± 0.0015995 (W 0.00220251) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 220.526 ± 5.75336 (W 0.72506) | 221.514 ± 4.71164 (W 0.696003) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.2971 ± 0.0588421 (W 0.0150612) | 2.3158 ± 0.0681426 (W 0.0155473) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 41.979 ± 0.155966 (W 0.0270569) | 42.0614 ± 0.111381 (W 0.0357035) | 73.4557 ± 0.0509707 (W 0.0642383) | · | 🔵 fork 1.75× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.893277 ± 0.0013223 (W 0.00344674) | 0.892485 ± 0.0014722 (W 0.00341814) | 2.12132 ± 0.00354952 (W 0.00217275) | · | 🔵 fork 2.37× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 93.2501 ± 3.8712 (W 0.477682) | 93.2345 ± 3.99297 (W 0.358746) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.30506 ± 0.0434344 (W 0.00688559) | 2.28977 ± 0.0501744 (W 0.00633519) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.4484 ± 0.118533 (W 0.108486) | 13.7969 ± 0.0251743 (W 0.0335435) | 20.5187 ± 0.0100957 (W 0.101257) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.322951 ± 0.0052632 (W 0.00394771) | 0.321306 ± 0.00382506 (W 0.00436839) | 0.588913 ± 0.00384923 (W 0.00389918) | · | 🔵 fork 1.82× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 64.5161 ± 0.312723 (W 0.616618) | 64.0429 ± 0.443832 (W 0.504613) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.27494 ± 0.0449248 (W 0.00731908) | 2.25633 ± 0.028491 (W 0.00610575) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.61487 ± 0.0758664 (W 0.0897425) | 8.30635 ± 0.00142749 (W 0.0502923) | 11.3874 ± 0.0818849 (W 0.0199936) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.240276 ± 0.00051644 (W 0.00177532) | 0.239301 ± 0.00176953 (W 0.00201896) | 0.410161 ± 0.00543271 (W 0.00242605) | · | 🔵 fork 1.71× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
