# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a53774682edd4e96f0387a80ddaa7bec2f3d1d70`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9baafe6afe1b468b81b7b13f72ed64aa0da6678a`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `05d9af5eee5559bdc76f381b47d2237b8aee0eb1b930553195ab89648eef3bfe`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T08:40:39.045487Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --families lu,solve,full_piv_lu,cholesky,gemm --shapes 32,64,96,128,256,512,1024x64,4096x256,64x1024,256x4096,256x256x256 --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label upstream-lu-restored-budget-repeat --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T081053Z-upstream-lu-restored-budget-repeat/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.19%, worst 78.40% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 125 of 1068 engine cells exceed 5% and carry `!`; median within-process relative SD 0.64%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/256x256x256/b1` | 1.0701 ± 0.00471809 (W 0.00198349) | 1.07786 ± 0.00258878 (W 0.00216962) | 1.1942 ± 0.00431513 (W 0.00238476) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.310651 ± 0.0247181 (W 0.00392338) | 0.307956 ± 0.0234668 (W 0.00772821) | 0.343423 ± 0.0392665 (W 0.00338671) | · | · | `!` between-start range over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.212979 ± 0.00906955 (W 0.0260646) | 0.20824 ± 0.0299624 (W 0.0376789) | 0.183714 ± 0.00194418 (W 0.00157751) | · | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07378 ± 0.00299951 (W 0.00227308) | 1.07135 ± 0.00740739 (W 0.00106879) | 1.20326 ± 0.00133458 (W 0.00190789) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.30991 ± 0.0229542 (W 0.00237185) | 0.306484 ± 0.0277742 (W 0.00408991) | 0.346267 ± 0.0389275 (W 0.00197203) | · | · | `!` between-start range over 5% |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.212538 ± 0.0272462 (W 0.0280909) | 0.211065 ± 0.0214332 (W 0.0339503) | 0.180177 ± 0.00110989 (W 0.00181428) | · | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.29276 ± 0.00638715 (W 0.00366887) | 4.28694 ± 0.00570489 (W 0.00381728) | 5.07825 ± 0.00582583 (W 0.0174736) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12668 ± 0.054912 (W 0.00946978) | 1.12816 ± 0.0416046 (W 0.00400099) | 1.84396 ± 0.0714195 (W 0.00589475) | · | 🔵 fork 1.64× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.617155 ± 0.0093813 (W 0.0130417) | 0.604951 ± 0.00483748 (W 0.0084459) | 0.701492 ± 0.00764559 (W 0.00258815) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28976 ± 0.00681374 (W 0.00284904) | 4.28688 ± 0.00663251 (W 0.00435572) | 5.15188 ± 0.0035589 (W 0.019342) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12846 ± 0.0372178 (W 0.00346539) | 1.13039 ± 0.0456387 (W 0.0116341) | 1.81817 ± 0.0730144 (W 0.00886012) | · | 🔵 fork 1.61× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.602678 ± 0.0151766 (W 0.00935031) | 0.61478 ± 0.00830751 (W 0.0160493) | 0.690772 ± 0.0117594 (W 0.00387528) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003266 ± 4.16333e-05 (W 4.18366e-05) | 0.003527 ± 4.78226e-05 (W 3.16117e-05) | 0.004198 ± 5.08626e-05 (W 4.20714e-05) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015118 ± 3.05505e-05 (W 4.09878e-05) | 0.016671 ± 0.00167071 (W 3.14213e-05) | 0.016791 ± 0.000205695 (W 7.36885e-05) | · | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030887 ± 9.06661e-05 (W 4.03733e-05) | 0.032821 ± 0.00188688 (W 6.76336e-05) | 0.048431 ± 0.000201098 (W 9.06819e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011952 ± 0.000170392 (W 8.85511e-05) | 0.01073 ± 0.00016 (W 4.43847e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051105 ± 6.6335e-05 (W 0.00017073) | 0.047339 ± 0.000321623 (W 0.00140685) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.14448 ± 0.000104644 (W 0.00277648) | 0.133921 ± 0.000465691 (W 0.00231907) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008446 ± 6.55744e-05 (W 3.97492e-05) | 0.007404 ± 0.000180831 (W 0.000167093) | 0.012172 ± 6.26126e-05 (W 3.70135e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030998 ± 0.000119304 (W 0.000177472) | 0.026439 ± 9.65419e-05 (W 0.000166373) | 0.043071 ± 0.0129886 (W 0.00130188) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.075651 ± 0.0001552 (W 0.00223863) | 0.065823 ± 0.000151527 (W 0.00200535) | 0.109976 ± 0.00175858 (W 0.00274449) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009608 ± 7.54983e-05 (W 4.1282e-05) | 0.008216 ± 0.000274287 (W 0.000187819) | 0.012844 ± 7.60285e-05 (W 3.91152e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031699 ± 0.000223681 (W 0.000101031) | 0.027611 ± 0.000447102 (W 0.00016521) | 0.043461 ± 0.000110259 (W 0.00117523) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077765 ± 0.00129927 (W 0.00244519) | 0.068188 ± 0.00158822 (W 0.00310389) | 0.103674 ± 0.000162194 (W 0.000144566) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003296 ± 0.000240901 (W 3.27613e-05) | 0.003436 ± 0.00019894 (W 3.32911e-05) | 0.004228 ± 5.2915e-05 (W 4.41384e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015008 ± 0.00174416 (W 6.86753e-05) | 0.014988 ± 0.0016468 (W 4.93994e-05) | 0.016841 ± 0.000110636 (W 5.77088e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.046477 ± 0.00242032 (W 0.00271672) | 0.065092 ± 0.00369473 (W 0.00611421) | 0.048391 ± 2.08167e-05 (W 0.00134618) | 🔵 fork 1.40× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011661 ± 0.000242357 (W 6.98949e-05) | 0.01058 ± 0.000265651 (W 6.83827e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051356 ± 0.000352137 (W 0.00146805) | 0.046787 ± 0.000711008 (W 0.000185796) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144461 ± 0.0002205 (W 0.00239477) | 0.133791 ± 0.000236792 (W 0.00212329) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008526 ± 5.50757e-05 (W 7.05691e-05) | 0.007374 ± 0.0001367 (W 0.000113116) | 0.012233 ± 3.60555e-05 (W 4.35798e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030777 ± 0.000316167 (W 0.000193673) | 0.046598 ± 0.00363887 (W 0.00360254) | 0.04268 ± 2.51661e-05 (W 0.000138521) | 🔵 fork 1.51× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.075842 ± 0.000440534 (W 0.000451969) | 0.105277 ± 0.00210827 (W 0.00277535) | 0.094026 ± 0.00105884 (W 0.00243695) | 🔵 fork 1.39× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009468 ± 7.25282e-05 (W 5.91295e-05) | 0.008125 ± 0.000196876 (W 0.000147411) | 0.012724 ± 0.000119039 (W 7.01427e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031599 ± 0.000190875 (W 0.000174749) | 0.044583 ± 0.000373698 (W 0.00202749) | 0.043652 ± 7.6922e-05 (W 0.000148119) | 🔵 fork 1.41× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.078137 ± 0.00129981 (W 0.00257146) | 0.102803 ± 0.000586061 (W 0.00335069) | 0.087534 ± 0.000217026 (W 0.000166506) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003326 ± 0.00017493 (W 4.20714e-05) | 0.003446 ± 0.000130908 (W 2.04768e-05) | 0.004288 ± 7.57188e-05 (W 6.08276e-05) | · | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015129 ± 0.00240865 (W 6.33822e-05) | 0.016611 ± 0.00116298 (W 7.10162e-05) | 0.016762 ± 0.000237003 (W 5.97185e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056346 ± 0.00147754 (W 0.00302717) | 0.071845 ± 0.00205993 (W 0.00137593) | 0.04815 ± 0.000163707 (W 0.000125667) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011852 ± 0.000408975 (W 7.0705e-05) | 0.01055 ± 0.000254395 (W 5.07937e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.052208 ± 0.000759435 (W 0.00115558) | 0.046797 ± 0.000296024 (W 0.000229558) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143198 ± 0.00116347 (W 0.00427678) | 0.133911 ± 0.000573192 (W 0.00234858) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008496 ± 8.18535e-05 (W 2.30217e-05) | 0.007374 ± 0.000178429 (W 6.27399e-05) | 0.012282 ± 5.16753e-05 (W 8.73499e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030918 ± 0.000261598 (W 0.000171331) | 0.05338 ± 0.000885868 (W 0.00237613) | 0.04281 ± 0.000102632 (W 0.000126354) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075691 ± 0.000433563 (W 0.00169051) | 0.118903 ± 0.00189002 (W 0.00298492) | 0.08553 ± 0.0030922 (W 0.000315485) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009478 ± 2.64575e-05 (W 3.52449e-05) | 0.008446 ± 6.80686e-05 (W 0.000195699) | 0.012754 ± 4.50925e-05 (W 4.76445e-05) | 🔴 fork 1.12× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031679 ± 0.000237691 (W 0.000188487) | 0.05337 ± 0.00283675 (W 0.00235612) | 0.043411 ± 4.09512e-05 (W 0.000109038) | 🔵 fork 1.68× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.079458 ± 0.00149808 (W 0.00241473) | 0.120706 ± 0.000711589 (W 0.00410929) | 0.085209 ± 0.00042151 (W 0.000138384) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003196 ± 5.50757e-05 (W 4.01647e-05) | 0.003346 ± 5.56507e-05 (W 3.15626e-05) | 0.003366 ± 2e-05 (W 3.53553e-05) | · | 🔵 fork 1.05× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014708 ± 7.38941e-05 (W 5.50482e-05) | 0.01643 ± 0.00171503 (W 7.7957e-05) | 0.014097 ± 1.1547e-05 (W 4.08938e-05) | 🔵 fork 1.12× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.029966 ± 8.73689e-05 (W 6.58027e-05) | 0.03175 ± 0.00186645 (W 5.2098e-05) | 0.038031 ± 0.000130512 (W 5.78463e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.01049 ± 3.17857e-05 (W 5.68181e-05) | 0.010519 ± 0.0001138 (W 5.60027e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045775 ± 0.000140571 (W 0.00138388) | 0.046016 ± 0.000205695 (W 0.000114282) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132217 ± 0.000318817 (W 0.00153392) | 0.131906 ± 0.000520487 (W 0.00200611) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007074 ± 6.64605e-05 (W 7.46003e-05) | 0.007133 ± 5.85947e-05 (W 7.61794e-05) | 0.009758 ± 4.09512e-05 (W 0.000110147) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025928 ± 0.000105832 (W 0.00185462) | 0.025819 ± 0.000356259 (W 0.000149599) | 0.033753 ± 0.000124231 (W 0.000100874) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063469 ± 0.000249065 (W 0.00231161) | 0.063759 ± 0.000296704 (W 0.00237341) | 0.074499 ± 0.00034693 (W 0.000130963) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007845 ± 0.00012108 (W 4.68647e-05) | 0.007935 ± 2.46374e-05 (W 4.76445e-05) | 0.009878 ± 3.40637e-05 (W 4.79302e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026149 ± 0.00019 (W 0.000151223) | 0.026279 ± 0.000179536 (W 0.000139821) | 0.033633 ± 0.00010116 (W 9.37561e-05) | · | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065363 ± 0.00119275 (W 0.00225644) | 0.065943 ± 0.00138669 (W 0.00255417) | 0.073458 ± 0.000159155 (W 0.000851686) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003066 ± 0.000264059 (W 2.88097e-05) | 0.003286 ± 0.00017673 (W 2.81638e-05) | 0.003376 ± 1.52753e-05 (W 2.2786e-05) | · | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014718 ± 0.00174899 (W 5.25671e-05) | 0.014678 ± 0.00148845 (W 6e-05) | 0.014157 ± 0.000151767 (W 3.63621e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.047779 ± 0.00209081 (W 0.00246548) | 0.064351 ± 0.00236991 (W 0.00361267) | 0.037951 ± 0.000261982 (W 0.000116817) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010429 ± 5.0797e-05 (W 2.74627e-05) | 0.01052 ± 0.000111505 (W 4.73424e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045946 ± 0.000213987 (W 0.000144548) | 0.046026 ± 0.000415035 (W 0.00146628) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132018 ± 0.000527868 (W 0.00238371) | 0.131827 ± 0.000296127 (W 0.00177166) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007033 ± 7.29178e-05 (W 5.95819e-05) | 0.007023 ± 7.26659e-05 (W 4.08656e-05) | 0.009718 ± 3.78594e-05 (W 4.15933e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025588 ± 7.54983e-05 (W 0.000168666) | 0.043161 ± 9.11062e-05 (W 0.00242796) | 0.033622 ± 0.00012454 (W 0.00129318) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063249 ± 0.000181935 (W 0.000299434) | 0.099687 ± 0.0030608 (W 0.00288924) | 0.07452 ± 0.000109697 (W 0.00147586) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007784 ± 4.39356e-05 (W 3.60181e-05) | 0.007835 ± 3.55949e-05 (W 5.26308e-05) | 0.009859 ± 4.63717e-05 (W 5.1896e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025819 ± 0.0002071 (W 0.000144294) | 0.044574 ± 0.000358387 (W 0.00311645) | 0.033432 ± 8.50706e-05 (W 9.05439e-05) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065673 ± 0.00111041 (W 0.00246241) | 0.098965 ± 0.00299042 (W 0.00510198) | 0.073477 ± 0.000250034 (W 0.000120251) | 🔵 fork 1.51× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003066 ± 0.000179258 (W 3e-05) | 0.003387 ± 7.55667e-05 (W 5.46013e-05) | 0.003396 ± 5.16753e-05 (W 3.25761e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014687 ± 0.00233247 (W 4.74689e-05) | 0.013725 ± 0.00200072 (W 4.24535e-05) | 0.013976 ± 0.00015695 (W 4.76445e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056526 ± 0.00373122 (W 0.00293417) | 0.071073 ± 0.00222715 (W 0.00160643) | 0.038101 ± 8.96289e-05 (W 9.09395e-05) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.010389 ± 4.62637e-05 (W 8.75854e-05) | 0.010299 ± 9.07377e-05 (W 4.38098e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045816 ± 0.000483922 (W 0.000154581) | 0.045885 ± 0.000274367 (W 0.000429193) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131947 ± 0.000340906 (W 0.00244556) | 0.132397 ± 0.000413877 (W 0.00294201) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007013 ± 7.26659e-05 (W 3.11448e-05) | 0.007063 ± 7.81025e-05 (W 3.45297e-05) | 0.009758 ± 7.37111e-05 (W 8.95545e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025939 ± 0.000482687 (W 0.0013077) | 0.051406 ± 0.00266755 (W 0.00339213) | 0.033432 ± 7.38941e-05 (W 0.000125241) | 🔵 fork 1.98× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063178 ± 0.00249398 (W 0.00240932) | 0.113462 ± 0.00228516 (W 0.00388046) | 0.074229 ± 0.000385509 (W 0.000215616) | 🔵 fork 1.80× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007784 ± 0.000115327 (W 3.52605e-05) | 0.007814 ± 1e-05 (W 5.77261e-05) | 0.009758 ± 5.34821e-05 (W 6.1849e-05) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025998 ± 0.000183957 (W 0.000170691) | 0.051056 ± 0.00241257 (W 0.00215062) | 0.033532 ± 5.87963e-05 (W 9.42088e-05) | 🔵 fork 1.96× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.066204 ± 0.00164209 (W 0.00255851) | 0.116949 ± 0.0042821 (W 0.006655) | 0.073617 ± 9.75722e-05 (W 0.0012405) | 🔵 fork 1.77× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005249 ± 3.78594e-05 (W 5.39008e-05) | 0.005049 ± 3.64737e-05 (W 3.247e-05) | 0.008967 ± 0.000156195 (W 3.56973e-05) | · | 🔵 fork 1.71× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030227 ± 6.37992e-05 (W 7.71447e-05) | 0.029285 ± 0.000173782 (W 7.89303e-05) | 0.050134 ± 0.000474317 (W 0.000210224) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084298 ± 0.00309789 (W 0.0017141) | 0.083346 ± 0.000981827 (W 9.46166e-05) | 0.138089 ± 8.75043e-05 (W 0.00137074) | · | 🔵 fork 1.64× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017753 ± 0.000113725 (W 9.34682e-05) | 0.015629 ± 5.23482e-05 (W 7.48418e-05) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097632 ± 0.000351019 (W 0.00146216) | 0.092252 ± 0.000120112 (W 0.00167884) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319878 ± 0.00141752 (W 0.00234567) | 0.307967 ± 0.000260771 (W 0.00182727) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013204 ± 5.89661e-05 (W 0.00014357) | 0.011111 ± 9.20887e-05 (W 0.000160724) | 0.019957 ± 8.18535e-05 (W 9.65671e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058129 ± 0.000449567 (W 0.000171948) | 0.052638 ± 0.000436533 (W 0.000259848) | 0.096511 ± 7.15565e-05 (W 0.00134661) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.189785 ± 0.000302987 (W 0.00217463) | 0.178745 ± 0.00175118 (W 0.00212006) | 0.29946 ± 0.00252712 (W 0.00403799) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014317 ± 0.000100167 (W 0.000127201) | 0.012433 ± 5.91636e-05 (W 9.7976e-05) | 0.020298 ± 2.64575e-05 (W 6.98011e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060092 ± 0.000418219 (W 0.000120309) | 0.054582 ± 0.000234458 (W 0.000286793) | 0.094416 ± 0.000481236 (W 0.0015514) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.203801 ± 0.00182953 (W 0.00268569) | 0.187802 ± 0.00521209 (W 0.00246684) | 0.252232 ± 0.000655369 (W 0.00133308) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005189 ± 3.45977e-05 (W 2.5006e-05) | 0.004969 ± 2e-05 (W 4.33613e-05) | 0.008836 ± 0.000107037 (W 4.30116e-05) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030427 ± 3.78594e-05 (W 9.01011e-05) | 0.029264 ± 0.00015393 (W 7.12482e-05) | 0.050825 ± 0.00102638 (W 0.000254991) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103834 ± 0.000747268 (W 0.00163838) | 0.102491 ± 0.00118713 (W 0.00139202) | 0.138128 ± 0.000634341 (W 0.000294297) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017653 ± 0.000118462 (W 8.47774e-05) | 0.015639 ± 4.04145e-05 (W 9.0111e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097352 ± 0.000172715 (W 0.00049962) | 0.091431 ± 0.000377978 (W 0.000594629) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319257 ± 0.00193321 (W 0.00365191) | 0.307375 ± 0.00134626 (W 0.00283906) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013064 ± 3.27159e-05 (W 0.000100111) | 0.011131 ± 4.12351e-05 (W 0.000138601) | 0.019767 ± 3.78594e-05 (W 8.79204e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058279 ± 0.000422138 (W 0.000149064) | 0.052828 ± 7.83603e-05 (W 0.000400131) | 0.095749 ± 0.000313975 (W 0.000997787) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.19231 ± 0.00183189 (W 0.00190624) | 0.194254 ± 0.0011869 (W 0.00541698) | 0.267901 ± 0.0146433 (W 0.00513248) | · | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014387 ± 7.05715e-05 (W 0.000124407) | 0.012493 ± 0.000109986 (W 0.000140501) | 0.020308 ± 0.0001505 (W 6.91686e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060273 ± 0.000197569 (W 0.00149905) | 0.054813 ± 0.000146936 (W 0.000325639) | 0.092874 ± 0.000363112 (W 0.000389168) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.206136 ± 0.000286758 (W 0.00271916) | 0.209262 ± 0.00181176 (W 0.00273634) | 0.237073 ± 0.000598176 (W 0.00213269) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 5.05008e-05 (W 3.1305e-05) | 0.004929 ± 2.28108e-05 (W 3.61829e-05) | 0.009007 ± 4.62637e-05 (W 3.42082e-05) | 🔴 fork 1.05× slower than `faer-upstream` | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030177 ± 0.000112398 (W 0.00152976) | 0.029114 ± 0.000431302 (W 0.000149909) | 0.050885 ± 0.00108525 (W 0.00133821) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111649 ± 0.000299134 (W 0.00328472) | 0.110527 ± 0.000536161 (W 0.00367374) | 0.140382 ± 0.000856449 (W 0.0016535) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017773 ± 7.62911e-05 (W 8.03698e-05) | 0.015729 ± 6.69104e-05 (W 7.96134e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096972 ± 0.000246982 (W 0.000298499) | 0.091732 ± 0.000288808 (W 0.000167257) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319287 ± 0.00180501 (W 0.00263167) | 0.30474 ± 0.00232254 (W 0.00245113) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013174 ± 0.000123249 (W 5.22034e-05) | 0.011391 ± 0.000200301 (W 0.000115967) | 0.019968 ± 7.26659e-05 (W 6.6935e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057988 ± 0.0001367 (W 0.000761334) | 0.052749 ± 0.000297271 (W 0.000291708) | 0.09625 ± 0.000403188 (W 0.000381328) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.189936 ± 0.000637018 (W 0.00224753) | 0.206246 ± 0.00209781 (W 0.00435278) | 0.244608 ± 0.0118785 (W 0.00209111) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014457 ± 7e-05 (W 8.38451e-05) | 0.012403 ± 0.00014526 (W 0.000113416) | 0.020238 ± 7.80833e-05 (W 9.69701e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059962 ± 0.000153298 (W 0.000152919) | 0.054562 ± 0.000178979 (W 0.000309161) | 0.092904 ± 0.000160104 (W 0.00135475) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.202128 ± 0.00107978 (W 0.00405721) | 0.215183 ± 0.00364676 (W 0.00357296) | 0.235961 ± 0.000335515 (W 0.00124481) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005169 ± 2.51661e-05 (W 3.21916e-05) | 0.00487 ± 8.87149e-05 (W 8.05562e-05) | 0.008065 ± 2.51661e-05 (W 7.82304e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029886 ± 0.00268354 (W 6.09861e-05) | 0.029034 ± 0.000943474 (W 0.000152162) | 0.043411 ± 0.000391681 (W 0.000105024) | · | 🔵 fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n96/b1` | 0.083426 ± 0.000454023 (W 0.000235988) | 0.082294 ± 0.00103331 (W 0.00123486) | 0.125464 ± 0.0012416 (W 0.00163251) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01576 ± 0.00011415 (W 5.17687e-05) | 0.015649 ± 3.66106e-05 (W 6.29468e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09094 ± 0.00021997 (W 0.0014964) | 0.09067 ± 0.000488146 (W 0.00141904) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.302436 ± 0.00147884 (W 0.00346726) | 0.305452 ± 0.0013992 (W 0.00351584) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011251 ± 6.02771e-05 (W 5.81378e-05) | 0.011181 ± 0.000240069 (W 0.000184917) | 0.017382 ± 6.10765e-05 (W 0.000103722) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051266 ± 0.000501133 (W 0.000164552) | 0.051386 ± 0.000543987 (W 0.00111778) | 0.086212 ± 0.000302821 (W 0.000237692) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.176851 ± 0.00122523 (W 0.00277965) | 0.174837 ± 0.000878574 (W 0.00310788) | 0.225452 ± 0.000215523 (W 0.00157291) | · | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012473 ± 6.61589e-05 (W 3.37817e-05) | 0.012424 ± 0.000147422 (W 8.95394e-05) | 0.017392 ± 5.1316e-05 (W 5.91709e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052748 ± 0.000395442 (W 6.35232e-05) | 0.052808 ± 0.000428798 (W 0.000195888) | 0.083447 ± 0.00016017 (W 0.000133217) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.186569 ± 0.00171956 (W 0.00388803) | 0.188422 ± 0.00176839 (W 0.00392627) | 0.219681 ± 0.000451106 (W 0.00139225) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00521 ± 3.4641e-05 (W 4.95005e-05) | 0.004859 ± 6.1403e-05 (W 3.43511e-05) | 0.007935 ± 8.0829e-05 (W 8.95545e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030026 ± 0.000162583 (W 5.72818e-05) | 0.029014 ± 0.000239952 (W 9.23704e-05) | 0.043391 ± 0.000768041 (W 0.000157892) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.101891 ± 0.000979133 (W 0.000845286) | 0.101009 ± 0.00128719 (W 0.00110948) | 0.125585 ± 0.00119726 (W 0.0002138) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015719 ± 0.000112281 (W 7.96072e-05) | 0.015629 ± 0.000275953 (W 7.73305e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089648 ± 0.000355964 (W 0.000531312) | 0.090159 ± 6.08276e-05 (W 0.00115628) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.303998 ± 0.00197079 (W 0.00253478) | 0.302526 ± 0.00259512 (W 0.00328795) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011281 ± 3e-05 (W 0.00106661) | 0.011191 ± 2.51661e-05 (W 0.000152727) | 0.017452 ± 2.6839e-05 (W 8.41427e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051106 ± 0.00104577 (W 0.00170863) | 0.051306 ± 0.000112694 (W 0.000806824) | 0.08573 ± 0.000461093 (W 0.00110805) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.173594 ± 0.0021683 (W 0.00225565) | 0.19236 ± 0.0017148 (W 0.0021436) | 0.224449 ± 0.000198688 (W 0.00134879) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012243 ± 0.000171555 (W 7.25066e-05) | 0.012454 ± 7.05006e-05 (W 9.12266e-05) | 0.017332 ± 7.37111e-05 (W 8.50488e-05) | · | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052719 ± 0.000213776 (W 0.000195438) | 0.052859 ± 0.000314463 (W 0.000123207) | 0.082995 ± 0.000110151 (W 0.00132968) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.185717 ± 0.00216191 (W 0.00259041) | 0.205274 ± 0.00187353 (W 0.00422806) | 0.218409 ± 0.000268418 (W 0.00168525) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00519 ± 4.16333e-05 (W 2.12908e-05) | 0.00492 ± 0.000111267 (W 5.09931e-05) | 0.008125 ± 0.000144627 (W 8.60233e-05) | 🔴 fork 1.05× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029936 ± 0.000125779 (W 3.95891e-05) | 0.028854 ± 0.000222442 (W 8.56154e-05) | 0.043531 ± 0.000345071 (W 0.00011001) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111358 ± 0.000774639 (W 0.00236903) | 0.109264 ± 0.000215523 (W 0.00386519) | 0.125084 ± 0.000974466 (W 0.00138644) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01581 ± 9.59705e-05 (W 0.000105803) | 0.01567 ± 9.68005e-05 (W 5.65447e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089608 ± 0.000211093 (W 0.00107092) | 0.089638 ± 0.000131149 (W 0.00170952) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.303858 ± 0.00152909 (W 0.0021036) | 0.303959 ± 0.00172677 (W 0.00210367) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011351 ± 6.65833e-05 (W 9.49805e-05) | 0.011201 ± 0.000145007 (W 0.000104332) | 0.017522 ± 2.5697e-05 (W 6.04152e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051055 ± 0.000219864 (W 0.000168102) | 0.051056 ± 0.000119862 (W 0.00104593) | 0.08541 ± 0.000171407 (W 0.000275095) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174356 ± 0.0020527 (W 0.00189004) | 0.200545 ± 0.00218469 (W 0.00258862) | 0.223949 ± 0.00058401 (W 0.0017027) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012333 ± 0.000120139 (W 6.36396e-05) | 0.012483 ± 8.18535e-05 (W 8.67254e-05) | 0.017292 ± 0.0001005 (W 6.83608e-05) | · | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052909 ± 0.00016563 (W 0.00012855) | 0.052869 ± 0.000216564 (W 0.000174557) | 0.082695 ± 0.000104403 (W 0.000391344) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.186619 ± 0.00187524 (W 0.00298395) | 0.214431 ± 0.0024006 (W 0.00413974) | 0.218859 ± 0.000716255 (W 0.00185374) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.067597 ± 0.002282 (W 0.000600884) | 0.070623 ± 0.000522098 (W 0.000651558) | 0.114955 ± 0.000656505 (W 0.000743563) | · | 🔵 fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.38994 ± 0.00720276 (W 0.00195279) | 0.388918 ± 0.00125208 (W 0.00327028) | 0.640608 ± 0.00142057 (W 0.0129055) | · | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.51923 ± 0.01007 (W 0.00508165) | 2.53399 ± 0.0358528 (W 0.00637787) | 4.03139 ± 0.00901916 (W 0.0304187) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309339 ± 0.000792347 (W 0.00265646) | 0.313366 ± 0.00251785 (W 0.00297421) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7072 ± 0.00923975 (W 0.0102137) | 2.75752 ± 0.00103408 (W 0.0072479) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.6413 ± 0.220122 (W 0.0330993) | 22.2446 ± 0.10315 (W 0.0287109) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.133379 ± 0.0182293 (W 0.00207973) | 0.136836 ± 0.0172339 (W 0.00183474) | 0.169598 ± 0.0192263 (W 0.00194494) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.979463 ± 0.117256 (W 0.00304395) | 1.03801 ± 0.00471209 (W 0.00354903) | 0.972911 ± 0.132707 (W 0.00344911) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.6025 ± 0.00622768 (W 0.0130535) | 7.21195 ± 0.108205 (W 0.0278812) | 6.94738 ± 0.0115446 (W 0.0190554) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134361 ± 0.000355979 (W 0.000214257) | 0.135703 ± 0.00145763 (W 0.000749901) | 0.170118 ± 0.000267644 (W 0.000280794) | · | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.750884 ± 0.0074357 (W 0.00366959) | 0.809043 ± 0.000915251 (W 0.0032556) | 0.96805 ± 0.00134834 (W 0.000715595) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.53821 ± 0.0416915 (W 0.0190584) | 7.10763 ± 0.0594178 (W 0.0181329) | 5.95465 ± 0.0274246 (W 0.00922722) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.084418 ± 0.000885246 (W 0.00262881) | 0.10723 ± 0.00384474 (W 0.00565391) | 0.114224 ± 0.00113857 (W 0.000604329) | 🔵 fork 1.27× faster than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.398274 ± 0.0071828 (W 0.0126688) | 0.42218 ± 0.00605163 (W 0.0236802) | 0.405448 ± 0.00370236 (W 0.00474051) | 🔵 fork 1.06× faster than `faer-upstream` | · |  |
| `cholesky/n512/b1` | 1.61211 ± 0.0373123 (W 0.0323278) | 1.65109 ± 0.0218854 (W 0.0328108) | 1.91485 ± 0.0164932 (W 0.00657442) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.30995 ± 0.00105636 (W 0.00182898) | 0.312545 ± 0.00170428 (W 0.00239865) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70155 ± 0.0090412 (W 0.00724459) | 2.76435 ± 0.0109417 (W 0.0129746) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4008 ± 0.083945 (W 0.0639181) | 18.07 ± 0.154417 (W 0.172878) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134081 ± 0.0177705 (W 0.000466937) | 0.198952 ± 0.0223317 (W 0.00773501) | 0.151554 ± 0.0132089 (W 0.00926556) | 🔵 fork 1.48× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.916945 ± 0.111058 (W 0.0215041) | 1.16168 ± 0.0110513 (W 0.0224428) | 0.375482 ± 0.116396 (W 0.00406741) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 2.44× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.65535 ± 0.0432555 (W 0.0503127) | 5.62243 ± 0.0172264 (W 0.066424) | 2.6016 ± 0.00771562 (W 0.0126783) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134301 ± 0.000495742 (W 0.00162389) | 0.200134 ± 0.00210603 (W 0.00684803) | 0.14981 ± 0.000301993 (W 0.00120403) | 🔵 fork 1.49× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.660745 ± 0.00464545 (W 0.0216146) | 0.893922 ± 0.0084581 (W 0.0266754) | 0.366205 ± 0.00048535 (W 0.00254854) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.55971 ± 0.0425774 (W 0.092552) | 5.43711 ± 0.0707749 (W 0.044686) | 1.83268 ± 0.0214187 (W 0.00578768) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.49× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.091261 ± 0.00197503 (W 0.0037642) | 0.107091 ± 0.00246669 (W 0.00477361) | 0.114935 ± 0.000761175 (W 0.000706065) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.399818 ± 0.0307938 (W 0.027547) | 0.469289 ± 0.0107249 (W 0.0195751) | 0.359833 ± 0.00251954 (W 0.00420929) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.55007 ± 0.0154819 (W 0.0178257) | 1.68699 ± 0.0125325 (W 0.0317719) | 1.45161 ± 0.00815029 (W 0.0146079) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.308006 ± 0.00334807 (W 0.0034223) | 0.311773 ± 0.000781299 (W 0.00210635) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70328 ± 0.0190406 (W 0.00683968) | 2.75879 ± 0.0163208 (W 0.00878508) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4227 ± 0.17777 (W 0.096817) | 17.9246 ± 0.045392 (W 0.125395) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134421 ± 0.0176609 (W 0.0013027) | 0.217156 ± 0.0242392 (W 0.0109689) | 0.189204 ± 0.0236577 (W 0.00168144) | 🔵 fork 1.62× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.909793 ± 0.107792 (W 0.0282875) | 1.27077 ± 0.00865067 (W 0.0295227) | 0.347711 ± 0.122687 (W 0.00317081) | 🔵 fork 1.40× faster than `faer-upstream` | 🔴 fork 2.62× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.47763 ± 0.00541302 (W 0.0284331) | 5.72552 ± 0.0917546 (W 0.118875) | 2.41938 ± 0.0675399 (W 0.0121523) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.85× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.134792 ± 0.00113143 (W 0.000307519) | 0.214331 ± 0.00825792 (W 0.00571819) | 0.146063 ± 0.00037006 (W 0.000384269) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.675994 ± 0.00278432 (W 0.0184538) | 0.958873 ± 0.0153035 (W 0.0371211) | 0.334195 ± 0.00418581 (W 0.00368817) | 🔵 fork 1.42× faster than `faer-upstream` | 🔴 fork 2.02× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.47003 ± 0.0663818 (W 0.0364516) | 5.56285 ± 0.0445984 (W 0.0677614) | 1.2892 ± 0.0191359 (W 0.00740642) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 3.47× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.06409 ± 0.00232057 (W 0.000144326) | 0.06373 ± 0.000897498 (W 0.00117121) | 0.093625 ± 0.00797641 (W 0.000288556) | · | 🔵 fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.326451 ± 0.00676587 (W 0.00264484) | 0.322863 ± 0.0019136 (W 0.00195894) | 0.461885 ± 0.00832486 (W 0.00373026) | · | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06105 ± 0.00533746 (W 0.00492321) | 2.06502 ± 0.000484909 (W 0.00232504) | 3.43036 ± 0.0262597 (W 0.0810906) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289812 ± 0.00101068 (W 0.00196003) | 0.289832 ± 0.00127587 (W 0.00182949) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62653 ± 0.00449467 (W 0.00786387) | 2.62303 ± 0.0064903 (W 0.00809387) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.1459 ± 0.225803 (W 0.0320481) | 21.0799 ± 0.142404 (W 0.0353864) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.144521 ± 0.000558535 (W 0.00126576) | 0.144811 ± 0.00102277 (W 0.000543046) | 0.133029 ± 0.000265688 (W 0.00154689) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.696282 ± 0.122953 (W 0.00300132) | 0.701222 ± 0.122866 (W 0.0045329) | 0.819022 ± 0.00160298 (W 0.00346657) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.10806 ± 0.00883395 (W 0.0157573) | 6.11422 ± 0.0117517 (W 0.0133683) | 5.20898 ± 0.00690764 (W 0.00826067) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112821 ± 0.000681898 (W 0.000528783) | 0.111318 ± 0.00129905 (W 0.00148539) | 0.13359 ± 0.000757749 (W 0.00167634) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.663211 ± 0.00100169 (W 0.00384007) | 0.663781 ± 0.00148508 (W 0.00410037) | 0.814373 ± 0.00353118 (W 0.00168229) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.04627 ± 0.0225697 (W 0.0142238) | 6.04227 ± 0.00536383 (W 0.00554105) | 5.21573 ± 0.0104178 (W 0.00790003) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.077795 ± 0.0021004 (W 0.000779497) | 0.10199 ± 0.00178153 (W 0.0065827) | 0.093395 ± 0.00100736 (W 0.000977765) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.334576 ± 0.0262775 (W 0.0259641) | 0.365855 ± 0.0211445 (W 0.0227646) | 0.239357 ± 0.0223451 (W 0.00664117) | · | 🔴 fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.11727 ± 0.00764103 (W 0.0225925) | 1.2058 ± 0.00729965 (W 0.0412452) | 1.40383 ± 0.0112382 (W 0.00629833) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.28839 ± 0.000676559 (W 0.00236212) | 0.288569 ± 0.0024445 (W 0.00157005) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61741 ± 0.00368614 (W 0.0100459) | 2.61486 ± 0.00628285 (W 0.00681801) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9023 ± 0.117699 (W 0.058407) | 16.9262 ± 0.115688 (W 0.144781) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145542 ± 0.000640563 (W 0.00264439) | 0.219571 ± 0.00249036 (W 0.00798123) | 0.133109 ± 0.000275627 (W 0.000157676) | 🔵 fork 1.51× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.633905 ± 0.114087 (W 0.0121911) | 0.840393 ± 0.123477 (W 0.016789) | 0.324487 ± 0.00201577 (W 0.00281342) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.95× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.17822 ± 0.0490535 (W 0.0483439) | 4.57428 ± 0.0243258 (W 0.029498) | 1.63145 ± 0.00198815 (W 0.00567368) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 2.56× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112119 ± 0.000255774 (W 0.000344995) | 0.173826 ± 0.000935787 (W 0.00336081) | 0.132397 ± 0.00102787 (W 0.00171752) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.585475 ± 0.00564136 (W 0.0132607) | 0.76465 ± 0.00999996 (W 0.00818738) | 0.313787 ± 0.00357533 (W 0.00152337) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 1.87× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.04347 ± 0.00321198 (W 0.027953) | 4.39819 ± 0.0195382 (W 0.0403075) | 1.61319 ± 0.00672199 (W 0.00860301) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 2.51× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.083887 ± 0.00142344 (W 0.0027453) | 0.099135 ± 0.00416419 (W 0.00362951) | 0.09061 ± 0.000381906 (W 0.00055199) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.338073 ± 0.0152671 (W 0.0210118) | 0.393105 ± 0.00534731 (W 0.0249852) | 0.196448 ± 0.00290227 (W 0.00133969) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.06026 ± 0.0223195 (W 0.0166832) | 1.19406 ± 0.00382566 (W 0.024568) | 0.960336 ± 0.00888707 (W 0.0070187) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289501 ± 0.00142777 (W 0.00157014) | 0.289772 ± 0.00101531 (W 0.00261977) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.63252 ± 0.0149222 (W 0.00720144) | 2.62167 ± 0.0138944 (W 0.011034) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8351 ± 0.115357 (W 0.0570571) | 16.7568 ± 0.16967 (W 0.100079) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.116337 ± 0.0169507 (W 0.00412378) | 0.202168 ± 0.00612341 (W 0.00560052) | 0.133239 ± 0.000159427 (W 0.000261286) | 🔵 fork 1.74× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.666457 ± 0.116113 (W 0.0169259) | 0.916655 ± 0.130965 (W 0.0211306) | 0.316512 ± 0.00191438 (W 0.00407875) | 🔵 fork 1.38× faster than `faer-upstream` | 🔴 fork 2.11× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 3.99571 ± 0.0158212 (W 0.0170349) | 4.73138 ± 0.0388308 (W 0.0639613) | 1.22451 ± 0.0116617 (W 0.00554286) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 3.26× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112631 ± 0.00084494 (W 0.0010196) | 0.189164 ± 0.00258893 (W 0.00400077) | 0.131827 ± 0.000670493 (W 0.00116299) | 🔵 fork 1.68× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.587037 ± 0.0185618 (W 0.0320296) | 0.833599 ± 0.0224701 (W 0.0207562) | 0.299059 ± 0.00129182 (W 0.00178567) | 🔵 fork 1.42× faster than `faer-upstream` | 🔴 fork 1.96× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 3.94623 ± 0.0458583 (W 0.0346695) | 4.60263 ± 0.04984 (W 0.0815221) | 1.2032 ± 0.00967183 (W 0.00415153) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 3.28× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188322 ± 0.000351412 (W 0.000606737) | 0.185498 ± 0.000150401 (W 0.00146404) | 0.478937 ± 0.00491321 (W 0.00370876) | · | 🔵 fork 2.54× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.22234 ± 0.00138792 (W 0.00288581) | 1.21958 ± 0.00307659 (W 0.0028097) | 1.87743 ± 0.0231798 (W 0.00360876) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.90393 ± 0.0114456 (W 0.0138229) | 7.90316 ± 0.0182743 (W 0.00427347) | 11.3752 ± 0.0148734 (W 0.0216901) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.774058 ± 0.00370248 (W 0.00449065) | 0.778216 ± 0.00469625 (W 0.00349988) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.90364 ± 0.0319796 (W 0.00914328) | 6.08884 ± 0.0203797 (W 0.016777) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 43.1174 ± 0.252349 (W 0.0867982) | 43.3411 ± 0.223184 (W 0.0687149) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.324737 ± 0.00062317 (W 0.00275992) | 0.328335 ± 0.000981186 (W 0.00233346) | 0.501479 ± 0.000481224 (W 0.0029874) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.10838 ± 0.00585311 (W 0.00203389) | 2.20755 ± 0.00239973 (W 0.00535846) | 3.30971 ± 0.00443213 (W 0.00888825) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.3693 ± 0.0288586 (W 0.039735) | 17.3612 ± 0.0257467 (W 0.0327244) | 23.1865 ± 0.0210024 (W 0.0194508) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.320459 ± 0.00173061 (W 0.00210546) | 0.323746 ± 0.00188993 (W 0.00236303) | 0.488694 ± 0.0012411 (W 0.00279068) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.04483 ± 0.00252189 (W 0.0014709) | 2.13552 ± 0.00239453 (W 0.0051311) | 2.82964 ± 0.00491582 (W 0.00928807) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 17.8796 ± 0.0283573 (W 0.0336992) | 17.9265 ± 0.0505025 (W 0.0317348) | 18.8097 ± 0.00927652 (W 0.0409913) | · | 🔵 fork 1.05× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.18705 ± 0.00264329 (W 0.00371422) | 0.200155 ± 0.00308821 (W 0.00261469) | 0.474066 ± 0.00235416 (W 0.00213823) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.53× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.846334 ± 0.0123042 (W 0.0104174) | 0.873714 ± 0.0201194 (W 0.0148778) | 0.794596 ± 0.00372265 (W 0.00528574) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.37823 ± 0.0136679 (W 0.0198256) | 3.39473 ± 0.00423518 (W 0.0246917) | 3.6376 ± 0.00262261 (W 0.0142351) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.768167 ± 0.00426963 (W 0.00595675) | 0.771483 ± 0.00941893 (W 0.00639116) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.87458 ± 0.0291487 (W 0.00817043) | 6.0376 ± 0.0622782 (W 0.0177208) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.5741 ± 0.145827 (W 0.166363) | 29.5289 ± 0.168165 (W 0.170522) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.317324 ± 0.00087654 (W 0.00196469) | 0.341429 ± 0.00367546 (W 0.00770901) | 0.481491 ± 0.000797656 (W 0.00290628) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.56026 ± 0.00983288 (W 0.0187172) | 1.68853 ± 0.00384109 (W 0.0143292) | 1.0149 ± 0.00144884 (W 0.00233569) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.97793 ± 0.0314696 (W 0.027594) | 9.88052 ± 0.0638693 (W 0.0459627) | 7.53414 ± 0.0207733 (W 0.0278669) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.309228 ± 0.00378972 (W 0.0039541) | 0.335798 ± 0.0101311 (W 0.00432408) | 0.469358 ± 0.00122577 (W 0.00217632) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 1.43535 ± 0.00693705 (W 0.0172778) | 1.55517 ± 0.00730428 (W 0.0174575) | 0.893741 ± 0.00102197 (W 0.00304607) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.4455 ± 0.0263754 (W 0.0426929) | 10.4335 ± 0.0503032 (W 0.0335254) | 5.69808 ± 0.0152805 (W 0.0212994) | · | 🔴 fork 1.83× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.195595 ± 0.000527145 (W 0.00125394) | 0.210764 ± 0.00145028 (W 0.00298567) | 0.478696 ± 0.00614268 (W 0.00410126) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.45× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.834472 ± 0.00983131 (W 0.0187422) | 0.864136 ± 0.0279392 (W 0.0214402) | 0.657329 ± 0.000925473 (W 0.00417159) | · | 🔴 fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 2.78554 ± 0.00714411 (W 0.0211344) | 2.85734 ± 0.00648264 (W 0.0217393) | 2.25525 ± 0.0400265 (W 0.0082482) | · | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.768677 ± 0.00208529 (W 0.0077361) | 0.778006 ± 0.004693 (W 0.00620762) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.89615 ± 0.0212559 (W 0.0179685) | 6.08136 ± 0.030998 (W 0.0314175) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.0108 ± 0.018496 (W 0.0876709) | 28.0354 ± 0.0513531 (W 0.0927878) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.323865 ± 0.00224163 (W 0.00477641) | 0.372055 ± 0.00666848 (W 0.00782) | 0.487021 ± 0.00811536 (W 0.00271618) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.53657 ± 0.0128571 (W 0.0147368) | 1.68867 ± 0.0100746 (W 0.0139678) | 0.699758 ± 0.00156698 (W 0.00356978) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.9491 ± 0.0725393 (W 0.0724395) | 8.84392 ± 0.0760756 (W 0.0839695) | 5.02358 ± 0.021023 (W 0.0241491) | · | 🔴 fork 1.78× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.318396 ± 0.0029011 (W 0.00557813) | 0.360093 ± 0.00387169 (W 0.00577984) | 0.470169 ± 0.00654429 (W 0.00259286) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.38617 ± 0.00577942 (W 0.0157556) | 1.51883 ± 0.0070331 (W 0.0210555) | 0.667938 ± 0.00533585 (W 0.00413494) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.43681 ± 0.0966629 (W 0.143213) | 9.2731 ± 0.199659 (W 0.03855) | 3.4389 ± 0.00773418 (W 0.00982643) | · | 🔴 fork 2.74× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175118 ± 0.000749098 (W 0.00191249) | 0.172833 ± 0.000371539 (W 0.00112425) | 0.407122 ± 0.0023481 (W 0.00252874) | · | 🔵 fork 2.32× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13078 ± 0.00181399 (W 0.00348164) | 1.12739 ± 0.00141782 (W 0.0011089) | 1.82069 ± 0.123905 (W 0.0056269) | · | 🔵 fork 1.61× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 7.51655 ± 0.00310624 (W 0.0113515) | 7.5094 ± 0.016542 (W 0.00842839) | 12.0409 ± 0.871951 (W 0.0169904) | · | 🔵 fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.747057 ± 0.000686505 (W 0.00335695) | 0.749902 ± 0.00549434 (W 0.00774922) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.76999 ± 0.0360221 (W 0.0137673) | 5.76983 ± 0.0333033 (W 0.0109741) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 42.091 ± 0.162096 (W 0.0299439) | 42.2341 ± 0.182304 (W 0.382949) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.294821 ± 0.000327623 (W 0.00207341) | 0.295192 ± 0.000667654 (W 0.00269735) | 0.463086 ± 0.00190254 (W 0.00235803) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.99607 ± 0.00272006 (W 0.000683293) | 2.00087 ± 0.011295 (W 0.00779723) | 3.18828 ± 0.0343045 (W 0.0101982) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.3834 ± 0.0302416 (W 0.0308465) | 16.336 ± 0.0481463 (W 0.0260903) | 19.982 ± 0.171917 (W 0.0387473) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292147 ± 0.00110923 (W 0.00174149) | 0.291596 ± 0.00160364 (W 0.00173543) | 0.44908 ± 0.00337861 (W 0.00304058) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.92798 ± 0.00308578 (W 0.00518806) | 1.92509 ± 0.00387976 (W 0.00368949) | 2.73053 ± 0.0404944 (W 0.00829371) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 16.8727 ± 0.0227199 (W 0.0291741) | 16.8528 ± 0.0352499 (W 0.0498306) | 17.9486 ± 0.250165 (W 0.375617) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175698 ± 0.00119853 (W 0.00154286) | 0.187631 ± 0.00245291 (W 0.00417427) | 0.407222 ± 0.00156608 (W 0.0028201) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.32× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.761043 ± 0.00530301 (W 0.00543952) | 0.776161 ± 0.0073065 (W 0.0122937) | 0.595885 ± 0.00229486 (W 0.00615716) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.99178 ± 0.00922006 (W 0.0285135) | 3.02734 ± 0.00964084 (W 0.0308582) | 3.20555 ± 0.0106946 (W 0.0103028) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.7428 ± 0.00251984 (W 0.00535033) | 0.746717 ± 0.0023339 (W 0.0045833) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74269 ± 0.0335562 (W 0.00628945) | 5.73715 ± 0.0109078 (W 0.0146829) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.4516 ± 0.150984 (W 0.0522104) | 28.6127 ± 0.0786584 (W 0.0967675) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.288841 ± 0.0046255 (W 0.00370829) | 0.315199 ± 0.00452806 (W 0.00722174) | 0.457265 ± 0.00116436 (W 0.00233451) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.46189 ± 0.0263966 (W 0.0182458) | 1.4703 ± 0.012514 (W 0.0193958) | 0.969905 ± 0.00479463 (W 0.00285836) | · | 🔴 fork 1.51× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.98895 ± 0.0511142 (W 0.0436351) | 9.01366 ± 0.0425319 (W 0.0434238) | 5.77028 ± 0.0516781 (W 0.0141669) | · | 🔴 fork 1.56× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.28316 ± 0.00211851 (W 0.00372203) | 0.302216 ± 0.00321778 (W 0.00588487) | 0.446464 ± 0.00109891 (W 0.00215946) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.31758 ± 0.0183758 (W 0.0220368) | 1.34186 ± 0.00689321 (W 0.0140165) | 0.856462 ± 0.00266235 (W 0.001569) | · | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.45127 ± 0.0156634 (W 0.0700268) | 9.53402 ± 0.0683013 (W 0.116638) | 5.37624 ± 0.0185111 (W 0.00661992) | · | 🔴 fork 1.76× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.182942 ± 0.00152513 (W 0.00217156) | 0.196698 ± 0.00174396 (W 0.00386039) | 0.409206 ± 0.00305131 (W 0.00319242) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.24× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.738511 ± 0.00847312 (W 0.00980547) | 0.786151 ± 0.00323957 (W 0.0168009) | 0.463186 ± 0.00476395 (W 0.00751482) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.43212 ± 0.0233715 (W 0.0260569) | 2.49369 ± 0.0187668 (W 0.0282239) | 1.84859 ± 0.00789633 (W 0.0176952) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.740875 ± 0.0065052 (W 0.0035527) | 0.749041 ± 0.0036812 (W 0.00468406) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.73539 ± 0.0421365 (W 0.0268339) | 5.77361 ± 0.00675443 (W 0.0216868) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.9708 ± 0.0946298 (W 0.107519) | 26.9374 ± 0.18206 (W 0.138925) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.299641 ± 0.000867235 (W 0.00495364) | 0.338162 ± 0.00497914 (W 0.00485948) | 0.459419 ± 0.00198237 (W 0.00186399) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.41201 ± 0.0135555 (W 0.020019) | 1.46885 ± 0.0127047 (W 0.0214127) | 0.679631 ± 0.00336058 (W 0.0029878) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 7.90328 ± 0.0183624 (W 0.0352103) | 8.06903 ± 0.0489528 (W 0.0458878) | 3.45601 ± 0.00726362 (W 0.00929586) | · | 🔴 fork 2.29× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292116 ± 0.00118444 (W 0.00290398) | 0.325308 ± 0.00227027 (W 0.00999832) | 0.446004 ± 0.00166095 (W 0.00283857) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.27981 ± 0.0241716 (W 0.0178851) | 1.30653 ± 0.00746686 (W 0.0224457) | 0.649766 ± 0.00395894 (W 0.00457607) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 8.34492 ± 0.06134 (W 0.0536513) | 8.40666 ± 0.0130107 (W 0.0488772) | 3.32396 ± 0.021702 (W 0.0103556) | · | 🔴 fork 2.51× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.831735 ± 0.00115411 (W 0.00286339) | 0.814894 ± 0.0015066 (W 0.00625218) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.2909 ± 0.103561 (W 0.117454) | 52.9623 ± 0.404264 (W 0.779526) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.473556 ± 0.00261516 (W 0.00263546) | 0.467104 ± 0.00210663 (W 0.00517078) | 0.663361 ± 0.135225 (W 0.0039161) | · | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.4999 ± 0.136591 (W 0.0760208) | 19.0362 ± 0.0487487 (W 0.0454794) | 18.1488 ± 2.5251 (W 0.12586) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.816887 ± 0.00198652 (W 0.0100922) | 0.815315 ± 0.00377253 (W 0.00418753) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.8326 ± 0.0785735 (W 0.112996) | 24.0979 ± 0.725815 (W 0.742078) | - | 🔵 fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.499414 ± 0.00198372 (W 0.00383944) | 0.505585 ± 0.00734133 (W 0.0128702) | 0.533919 ± 0.119242 (W 0.00663007) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.5809 ± 0.074202 (W 0.137284) | 13.1043 ± 0.0333612 (W 0.0209177) | 13.327 ± 1.98147 (W 0.0514842) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.820834 ± 0.00627959 (W 0.00899406) | 0.81226 ± 0.000294721 (W 0.00455137) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.6987 ± 0.0733488 (W 0.0799311) | 19.4815 ± 0.165542 (W 0.0930222) | - | 🔵 fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.490998 ± 0.00501153 (W 0.00632655) | 0.535452 ± 0.0146573 (W 0.0146366) | 0.596896 ± 0.165312 (W 0.0053409) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.75494 ± 0.0740727 (W 0.0352567) | 12.2246 ± 0.0238182 (W 0.0596525) | 4.10966 ± 1.85769 (W 0.0321501) | 🔵 fork 1.40× faster than `faer-upstream` | 🔴 fork 2.13× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731748 ± 0.00166595 (W 0.00343387) | 0.730828 ± 0.000332207 (W 0.00246179) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.0587 ± 0.052079 (W 0.328692) | 46.6933 ± 0.139735 (W 0.139139) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.386081 ± 0.00163952 (W 0.00331579) | 0.383086 ± 0.000992192 (W 0.00248049) | 0.285033 ± 0.00056496 (W 0.00171442) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2887 ± 0.0571486 (W 0.0260531) | 13.2599 ± 0.0122908 (W 0.044784) | 11.6153 ± 0.0596562 (W 0.0230556) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.737058 ± 0.00395815 (W 0.00986198) | 0.738201 ± 0.00793219 (W 0.0102051) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6226 ± 0.0635365 (W 0.143985) | 17.4948 ± 0.249398 (W 0.196968) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.405258 ± 0.00677561 (W 0.00986307) | 0.429162 ± 0.000758685 (W 0.00477929) | 0.286146 ± 0.00616781 (W 0.00205818) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.33076 ± 0.0319931 (W 0.0351149) | 7.40358 ± 0.0702867 (W 0.0270548) | 11.599 ± 0.0879562 (W 0.0253987) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.739033 ± 0.0115094 (W 0.0114117) | 0.733312 ± 0.00518961 (W 0.00274974) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6486 ± 0.051692 (W 0.128836) | 13.7666 ± 0.0698973 (W 0.150851) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.390981 ± 0.00534221 (W 0.0062413) | 0.450693 ± 0.00495063 (W 0.00867301) | 0.286375 ± 0.00135157 (W 0.00244822) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.68424 ± 0.0284824 (W 0.0217554) | 6.70336 ± 0.0379461 (W 0.032528) | 3.1376 ± 0.0432158 (W 0.00859296) | · | 🔴 fork 2.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77989 ± 0.00455675 (W 0.00409412) | 1.82986 ± 0.0306338 (W 0.00359602) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.018 ± 0.324517 (W 0.519007) | 156.298 ± 0.514551 (W 0.841479) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.991354 ± 0.00100884 (W 0.00287159) | 0.997566 ± 0.00785363 (W 0.00337936) | 1.19252 ± 0.00231004 (W 0.00401524) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.5813 ± 0.0727481 (W 0.123378) | 53.8469 ± 0.132474 (W 0.0690984) | 56.2469 ± 5.99327 (W 0.103122) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.76602 ± 0.00362432 (W 0.00342337) | 1.85524 ± 0.0212019 (W 0.00324142) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.3018 ± 0.0440599 (W 0.353736) | 65.6967 ± 0.656895 (W 1.13949) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.806559 ± 0.00914494 (W 0.0154984) | 0.805877 ± 0.00643662 (W 0.00909308) | 1.09442 ± 0.00229286 (W 0.00289189) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.7821 ± 0.0879549 (W 0.176666) | 29.7086 ± 0.0290494 (W 0.094272) | 52.5158 ± 3.48039 (W 0.183868) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.31× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77048 ± 0.0076874 (W 0.00250618) | 1.82188 ± 0.0181683 (W 0.00379123) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.7288 ± 0.333108 (W 0.340359) | 41.7248 ± 0.130082 (W 0.13671) | - | 🔵 fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.793164 ± 0.000807236 (W 0.010814) | 0.785068 ± 0.00350992 (W 0.0108506) | 1.08293 ± 0.00307028 (W 0.00207385) | · | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 18.7764 ± 0.193379 (W 0.121952) | 25.8244 ± 0.0682193 (W 0.0796621) | 57.0014 ± 3.41309 (W 0.105292) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 3.04× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6605 ± 0.00175572 (W 0.00333449) | 1.698 ± 0.00428387 (W 0.0057303) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 142.936 ± 0.191822 (W 1.2999) | 144.428 ± 0.682887 (W 0.627488) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.872523 ± 0.00266782 (W 0.0037266) | 0.872813 ± 0.00159713 (W 0.00773251) | 1.08423 ± 0.0312695 (W 0.0029405) | · | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 41.6425 ± 0.065043 (W 0.0498474) | 41.613 ± 0.0120251 (W 0.0701987) | 49.9914 ± 0.288165 (W 0.0726734) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6579 ± 0.000925434 (W 0.0101551) | 1.69388 ± 0.00486294 (W 0.00299173) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.8864 ± 0.715694 (W 0.445603) | 52.9618 ± 0.453949 (W 0.787022) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.708455 ± 0.00629799 (W 0.0117601) | 0.71061 ± 0.00310763 (W 0.0068031) | 1.06468 ± 0.00303107 (W 0.00372553) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.4413 ± 0.0994432 (W 0.0634966) | 17.4558 ± 0.0342841 (W 0.110444) | 49.4093 ± 0.11191 (W 0.0891829) | · | 🔵 fork 2.83× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6599 ± 0.00313386 (W 0.00263227) | 1.70296 ± 0.0113759 (W 0.0027323) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.0178 ± 0.123351 (W 0.151703) | 29.8928 ± 0.251405 (W 0.387233) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.68435 ± 0.00281676 (W 0.0112235) | 0.685572 ± 0.0063405 (W 0.0117435) | 1.06595 ± 0.00990043 (W 0.0027282) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.4202 ± 0.0324758 (W 0.0608202) | 13.5545 ± 0.0303765 (W 0.0409466) | 49.5526 ± 0.13153 (W 0.0979675) | · | 🔵 fork 3.69× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 73.262 ± 0.447921 (W 0.320032) | 77.1259 ± 0.191474 (W 0.244496) | - | 🔵 fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12511 ± 0.0142739 (W 0.0058186) | 1.25866 ± 0.0184082 (W 0.00393685) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 15.9257 ± 0.0763569 (W 0.039888) | 18.0939 ± 0.0322549 (W 0.0421245) | 72.9343 ± 2.07754 (W 1.83648) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 4.58× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.394608 ± 0.00174281 (W 0.00280303) | 0.510284 ± 0.00542263 (W 0.00203268) | 0.920532 ± 0.136712 (W 0.00307402) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 2.33× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.471 ± 0.373762 (W 0.350247) | 40.17 ± 0.928542 (W 0.384882) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12865 ± 0.0133737 (W 0.00315152) | 1.25592 ± 0.018206 (W 0.00485341) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.25495 ± 0.0838924 (W 0.104772) | 9.19547 ± 0.164236 (W 0.0276846) | 10.1037 ± 0.155151 (W 0.0948182) | 🔵 fork 1.27× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.228067 ± 0.00154944 (W 0.00530959) | 0.352779 ± 0.0181475 (W 0.0244848) | 0.291816 ± 0.0040674 (W 0.00324766) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 33.0136 ± 0.182431 (W 0.195844) | 35.2672 ± 0.160573 (W 0.40049) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.13136 ± 0.00650345 (W 0.00364011) | 1.25947 ± 0.00943287 (W 0.00552392) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.65498 ± 0.172913 (W 0.109458) | 7.87312 ± 0.198069 (W 0.123782) | 6.87695 ± 0.0134688 (W 0.0361381) | 🔵 fork 1.39× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.208179 ± 0.00386945 (W 0.00281662) | 0.367046 ± 0.00914897 (W 0.0230747) | 0.172563 ± 0.00138511 (W 0.0029038) | 🔵 fork 1.76× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.9082 ± 0.627184 (W 0.177304) | 72.1493 ± 0.0910027 (W 0.129755) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05265 ± 0.00250334 (W 0.00673446) | 1.05818 ± 0.00660898 (W 0.00317267) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3265 ± 0.0342941 (W 0.0253807) | 13.3181 ± 0.0215736 (W 0.0196497) | 209.926 ± 0.301529 (W 0.358312) | · | 🔵 fork 15.75× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.311212 ± 0.00249126 (W 0.00199154) | 0.314147 ± 0.00210877 (W 0.00284732) | 3.13338 ± 0.000473998 (W 0.00392161) | · | 🔵 fork 10.07× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.1235 ± 0.0867361 (W 0.275601) | 35.2067 ± 0.194353 (W 0.213887) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04648 ± 0.00234086 (W 0.00401726) | 1.0517 ± 0.0109996 (W 0.00193454) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.29552 ± 0.019223 (W 0.0221382) | 4.67112 ± 0.0297858 (W 0.0706575) | 5.28431 ± 0.0258047 (W 0.0102273) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.135764 ± 0.00219432 (W 0.00203235) | 0.170199 ± 0.000399351 (W 0.00218035) | 0.234598 ± 0.00204561 (W 0.00311523) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.73× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.1242 ± 0.255688 (W 0.153259) | 30.2421 ± 0.152585 (W 0.145037) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05888 ± 0.00589973 (W 0.00305214) | 1.04739 ± 0.011355 (W 0.00243547) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.86079 ± 0.0243299 (W 0.0309546) | 3.3632 ± 0.0912192 (W 0.062761) | 3.16126 ± 0.0153194 (W 0.0177248) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.116718 ± 0.00250103 (W 0.00214585) | 0.156192 ± 0.004333 (W 0.00644969) | 0.132197 ± 0.00134979 (W 0.00121967) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 235.924 ± 3.11416 (W 0.678326) | 235.963 ± 3.1741 (W 0.781195) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.4036 ± 0.210256 (W 0.00994375) | 2.49821 ± 0.0545215 (W 0.00723635) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 45.9074 ± 0.165513 (W 0.388655) | 46.3671 ± 0.0729706 (W 0.0550884) | 88.6214 ± 0.684932 (W 0.216793) | · | 🔵 fork 1.93× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 1.00489 ± 0.00176784 (W 0.00395187) | 1.05614 ± 0.0219473 (W 0.00274242) | 2.32272 ± 0.00907378 (W 0.00426983) | · | 🔵 fork 2.31× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.6951 ± 1.93537 (W 0.540625) | 97.786 ± 3.06709 (W 0.658657) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.419 ± 0.0037815 (W 0.004926) | 2.50812 ± 0.0207513 (W 0.00803062) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.1435 ± 0.0921728 (W 0.102726) | 18.247 ± 0.0250792 (W 0.0811683) | 23.8372 ± 3.14306 (W 0.047934) | · | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.436327 ± 0.000737972 (W 0.00238932) | 0.488163 ± 0.00260372 (W 0.00484168) | 0.639686 ± 0.00075718 (W 0.00223251) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 69.9126 ± 0.938588 (W 0.377021) | 68.8868 ± 0.815545 (W 0.819875) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.42754 ± 0.0508137 (W 0.00868126) | 2.53379 ± 0.0354049 (W 0.00759089) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 12.458 ± 0.121317 (W 0.139212) | 12.365 ± 0.146854 (W 0.0777924) | 18.6898 ± 3.05113 (W 0.0949927) | · | 🔵 fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.355004 ± 0.00882064 (W 0.0037161) | 0.401882 ± 0.00140699 (W 0.00348082) | 0.452616 ± 0.00442302 (W 0.0032245) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 231.801 ± 3.01465 (W 0.690194) | 231.162 ± 2.1669 (W 0.369596) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.27517 ± 0.199169 (W 0.0108787) | 2.27339 ± 0.0203619 (W 0.00975019) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 42.0622 ± 0.11012 (W 0.0997288) | 41.9373 ± 0.187085 (W 0.0961371) | 72.9688 ± 0.428087 (W 0.143629) | · | 🔵 fork 1.73× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.895345 ± 0.00161398 (W 0.00351417) | 0.895745 ± 0.000795423 (W 0.00533548) | 2.12785 ± 0.0130407 (W 0.00242665) | · | 🔵 fork 2.38× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.8791 ± 4.13944 (W 0.476837) | 92.0131 ± 1.10614 (W 0.490677) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.28148 ± 0.0020403 (W 0.00551271) | 2.27954 ± 0.0162025 (W 0.0091986) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.8418 ± 0.0670291 (W 0.0642346) | 13.8823 ± 0.0481472 (W 0.0766092) | 20.4828 ± 0.0570597 (W 0.0304055) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.325729 ± 0.00627407 (W 0.00483758) | 0.323455 ± 0.00138882 (W 0.00339804) | 0.586867 ± 0.00401253 (W 0.00390391) | · | 🔵 fork 1.80× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 64.604 ± 0.807403 (W 0.555706) | 64.8642 ± 0.851144 (W 0.21204) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.27162 ± 0.0534441 (W 0.0134869) | 2.29229 ± 0.0386998 (W 0.00952135) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.29256 ± 0.0712566 (W 0.0530396) | 8.30065 ± 0.0142146 (W 0.0471651) | 11.2555 ± 0.0157353 (W 0.0189516) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.238346 ± 0.00151277 (W 0.00171858) | 0.239909 ± 0.000896506 (W 0.00483937) | 0.413925 ± 0.00332252 (W 0.00279924) | · | 🔵 fork 1.74× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
