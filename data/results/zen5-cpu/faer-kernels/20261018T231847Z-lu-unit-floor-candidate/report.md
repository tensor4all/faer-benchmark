# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `2870062a7ee60c440a88bd08fd421cb94421cd56`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `8badcc74314c82508a8a143643fe6015832d6a5a`
- toolkit commit: `bfaeb6eef2015a04d755eeb3a581c782b8824d5a`
- measured binary SHA-256: `36e974e89d53aaf1c17dd5352dffb41335fc4affe62d185b2ff6c79e50931310`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T23:46:32.787833Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --families lu,solve,full_piv_lu,cholesky,gemm --shapes 32,64,96,128,256,512,1024x64,4096x256,64x1024,256x4096,256x256x256 --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label lu-unit-floor-candidate --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T231847Z-lu-unit-floor-candidate/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.22%, worst 179.42% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 112 of 1068 engine cells exceed 5% and carry `!`; median within-process relative SD 0.62%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/256x256x256/b1` | 1.07264 ± 0.00619766 (W 0.00292073) | 1.07491 ± 0.00200293 (W 0.000610074) | 1.19987 ± 0.00257367 (W 0.0034647) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.300722 ± 0.00536549 (W 0.00254876) | 0.300404 ± 0.00558779 (W 0.00199882) | 0.345816 ± 0.000468029 (W 0.00163025) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.193442 ± 0.0116859 (W 0.015942) | 0.2194 ± 0.00686466 (W 0.0372351) | 0.179447 ± 0.000639463 (W 0.000621258) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07504 ± 0.00337355 (W 0.00173853) | 1.07433 ± 0.00174903 (W 0.000740934) | 1.20363 ± 0.00247586 (W 0.00151731) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.299843 ± 0.00151704 (W 0.00783616) | 0.302536 ± 0.00493599 (W 0.00261328) | 0.342911 ± 0.000868553 (W 0.00149156) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.230852 ± 0.00296307 (W 0.0433388) | 0.236785 ± 0.0365856 (W 0.0327228) | 0.178424 ± 0.0010329 (W 0.00151904) | · | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28857 ± 0.020891 (W 0.0109377) | 4.28938 ± 0.0133483 (W 0.00880585) | 5.09138 ± 0.0213074 (W 0.012581) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12348 ± 0.00637347 (W 0.00296257) | 1.12736 ± 0.00164078 (W 0.0030441) | 1.81595 ± 0.0246249 (W 0.00612848) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.606815 ± 0.00477846 (W 0.00525361) | 0.607687 ± 0.00409619 (W 0.0138276) | 0.700244 ± 0.00534806 (W 0.00435395) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.29553 ± 0.00947709 (W 0.00342097) | 4.3053 ± 0.0173041 (W 0.00548693) | 5.15236 ± 0.0145274 (W 0.0311593) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12694 ± 0.00377456 (W 0.00316236) | 1.12773 ± 0.00111802 (W 0.00370411) | 1.81062 ± 0.0112163 (W 0.00367141) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.606919 ± 0.00432941 (W 0.0108445) | 0.604922 ± 0.00703768 (W 0.011571) | 0.687116 ± 0.0113157 (W 0.0025758) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003416 ± 2.04206e-05 (W 2.09809e-05) | 0.003166 ± 3.4641e-05 (W 1.78885e-05) | 0.004208 ± 2.0502e-05 (W 4.24641e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016631 ± 4.2194e-05 (W 0.00131017) | 0.014968 ± 0.000148436 (W 4.49444e-05) | 0.016851 ± 7.29178e-05 (W 6.78476e-05) | 🔴 fork 1.11× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.032721 ± 0.000288808 (W 7.46344e-05) | 0.031249 ± 0.00135745 (W 9.98499e-05) | 0.048431 ± 0.00017657 (W 0.00138311) | · | 🔵 fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011772 ± 0.000155671 (W 0.000104409) | 0.0105 ± 0.000348704 (W 0.000110522) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051476 ± 0.000106444 (W 0.000338271) | 0.046878 ± 0.000337038 (W 0.000101465) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144201 ± 0.00105852 (W 0.00238787) | 0.134342 ± 0.000545218 (W 0.00232871) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008546 ± 0.000178326 (W 6.429e-05) | 0.007113 ± 3.10966e-05 (W 3.05008e-05) | 0.012153 ± 0.000108214 (W 9.60208e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031038 ± 9.70069e-05 (W 0.00013489) | 0.0265 ± 0.000372578 (W 0.000149105) | 0.04307 ± 0.000121698 (W 0.000122434) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075752 ± 0.00074605 (W 0.00241093) | 0.065673 ± 9.53939e-05 (W 0.00123663) | 0.110337 ± 0.000212784 (W 0.00157009) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009568 ± 4.16333e-05 (W 8.54675e-05) | 0.008276 ± 7.26659e-05 (W 7.32141e-05) | 0.012864 ± 5.03322e-05 (W 4.08656e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031459 ± 0.000293606 (W 0.000133903) | 0.027381 ± 0.000270617 (W 7.4694e-05) | 0.043541 ± 0.00017094 (W 0.00158146) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077685 ± 0.000622449 (W 0.00204955) | 0.067486 ± 0.000266584 (W 0.0027694) | 0.104095 ± 0.000127986 (W 0.000155467) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003437 ± 3.05014e-05 (W 2.56963e-05) | 0.003186 ± 5.7735e-06 (W 2.07364e-05) | 0.004238 ± 1.09697e-05 (W 5.44977e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016521 ± 9.53939e-05 (W 5.77062e-05) | 0.015118 ± 0.000132288 (W 4.83032e-05) | 0.016832 ± 8.62168e-05 (W 5.02991e-05) | 🔴 fork 1.09× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.052348 ± 0.000493183 (W 0.00081142) | 0.059251 ± 0.0011355 (W 0.00199381) | 0.048571 ± 0.000195021 (W 0.00133035) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011893 ± 0.000128829 (W 0.000189616) | 0.01058 ± 0.000272838 (W 0.000120706) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051036 ± 0.000106927 (W 0.000150852) | 0.046908 ± 0.000255147 (W 0.00158811) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.14394 ± 0.000564146 (W 0.002243) | 0.1334 ± 0.000267427 (W 0.00266622) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008486 ± 0.000144222 (W 4.07468e-05) | 0.007143 ± 6.02771e-05 (W 6.04177e-05) | 0.012243 ± 7.93725e-05 (W 8.84873e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030637 ± 0.000199149 (W 0.000188051) | 0.045656 ± 0.00133593 (W 0.00277595) | 0.04283 ± 0.000196571 (W 0.000109127) | 🔵 fork 1.49× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.075642 ± 0.000220568 (W 0.000252856) | 0.103684 ± 0.00189306 (W 0.00305056) | 0.093555 ± 0.000115036 (W 0.00340748) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009598 ± 9.81495e-05 (W 8.73499e-05) | 0.008166 ± 0.000173494 (W 6.26897e-05) | 0.012784 ± 9.0185e-05 (W 5.65889e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031749 ± 0.000181357 (W 0.000701115) | 0.045095 ± 0.00152686 (W 0.00251035) | 0.043702 ± 0.000106616 (W 5.6269e-05) | 🔵 fork 1.42× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077605 ± 0.00040704 (W 0.00235392) | 0.104035 ± 0.00261299 (W 0.00519541) | 0.087504 ± 0.00015695 (W 0.00121583) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003436 ± 2.6839e-05 (W 3.74727e-05) | 0.003456 ± 0.000177858 (W 2.31366e-05) | 0.004158 ± 3.78594e-05 (W 4.3359e-05) | · | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016731 ± 0.000165712 (W 2.30478e-05) | 0.017082 ± 0.00130747 (W 3.39116e-05) | 0.016812 ± 0.000185023 (W 6.64477e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.05883 ± 0.000304254 (W 0.00277883) | 0.072816 ± 0.000570974 (W 0.00147245) | 0.048281 ± 5.72742e-05 (W 0.00139347) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011882 ± 0.000372613 (W 3.86549e-05) | 0.010499 ± 0.00013604 (W 5.98105e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051637 ± 0.000480989 (W 0.000150024) | 0.047169 ± 0.000440641 (W 0.00168949) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143989 ± 0.000717245 (W 0.0012551) | 0.13349 ± 0.00333317 (W 0.00040691) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008516 ± 0.000183058 (W 0.000117814) | 0.007083 ± 0.000173754 (W 4.95298e-05) | 0.012233 ± 5.50757e-05 (W 0.000105451) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031028 ± 0.000240646 (W 0.00010229) | 0.053851 ± 0.000303447 (W 0.00299073) | 0.04288 ± 0.000110151 (W 0.000127194) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075621 ± 0.000292211 (W 0.00234084) | 0.118401 ± 0.00336828 (W 0.00452779) | 0.08578 ± 0.00463109 (W 0.000283052) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009498 ± 0.000133167 (W 9.88433e-05) | 0.008226 ± 6.1101e-05 (W 0.000118496) | 0.012844 ± 9.60902e-05 (W 4.02281e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.03199 ± 0.000103923 (W 0.000115427) | 0.05345 ± 0.000740639 (W 0.00330833) | 0.043542 ± 0.000121327 (W 4.82203e-05) | 🔵 fork 1.67× faster than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077625 ± 0.0032333 (W 0.00179055) | 0.118952 ± 0.0130839 (W 0.00566264) | 0.085521 ± 0.00136301 (W 0.001378) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003296 ± 4.58258e-05 (W 2.32207e-05) | 0.003126 ± 6.08276e-05 (W 4.25124e-05) | 0.003336 ± 2.94449e-05 (W 1.68612e-05) | 🔴 fork 1.05× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01618 ± 0.000126295 (W 3.49328e-05) | 0.014898 ± 0.00122928 (W 2.55402e-05) | 0.014237 ± 0.000170587 (W 2.24789e-05) | · | 🔴 fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.031919 ± 0.000265419 (W 8.8744e-05) | 0.030417 ± 0.00143994 (W 6.1887e-05) | 0.038362 ± 0.000318429 (W 0.000127465) | · | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010349 ± 7.40968e-05 (W 6.06737e-05) | 0.010389 ± 0.00023567 (W 9.75305e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045706 ± 0.000261255 (W 0.000208644) | 0.046697 ± 0.0157266 (W 0.000239463) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n96/b1` | 0.131867 ± 0.000400538 (W 0.00236485) | 0.132678 ± 0.00047862 (W 0.00281434) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007043 ± 8.3668e-05 (W 3.67723e-05) | 0.007044 ± 0.000127005 (W 5.89915e-05) | 0.009708 ± 1.58219e-05 (W 3.60319e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025678 ± 4.50925e-05 (W 0.000139403) | 0.025869 ± 0.000225677 (W 0.000135223) | 0.033814 ± 0.000205687 (W 5.02991e-05) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063218 ± 0.000170588 (W 0.00245042) | 0.06367 ± 0.000365506 (W 0.00203703) | 0.074429 ± 7.02377e-05 (W 0.000187377) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007895 ± 4.93288e-05 (W 5.06952e-05) | 0.007935 ± 6.08276e-05 (W 0.00011649) | 0.009959 ± 4.52806e-05 (W 2.87785e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025818 ± 0.000257547 (W 9.07981e-05) | 0.0264 ± 0.000597661 (W 0.00106309) | 0.033643 ± 8.18535e-05 (W 0.000118237) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065242 ± 0.000195192 (W 0.00249366) | 0.065774 ± 0.000594734 (W 9.60791e-05) | 0.073768 ± 0.000337071 (W 0.00125346) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003326 ± 7.0946e-05 (W 1.47071e-05) | 0.003066 ± 1.18462e-05 (W 2.16795e-05) | 0.003337 ± 2.70247e-05 (W 2.25655e-05) | 🔴 fork 1.08× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.01633 ± 6.50922e-05 (W 2.46435e-05) | 0.014708 ± 0.00169039 (W 4.51697e-05) | 0.013986 ± 0.00013 (W 2.77002e-05) | · | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049683 ± 0.00111978 (W 0.00339076) | 0.05844 ± 0.00157096 (W 0.00327433) | 0.037941 ± 7.26659e-05 (W 7.7738e-05) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.0103 ± 9.53432e-05 (W 3.61428e-05) | 0.010449 ± 7.5368e-05 (W 8.21054e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046036 ± 0.000240576 (W 0.000149239) | 0.045926 ± 0.000689407 (W 0.00018093) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131407 ± 0.000370083 (W 0.0023001) | 0.131426 ± 0.00039225 (W 0.00225434) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007043 ± 7.56329e-05 (W 5.63028e-05) | 0.007023 ± 7.77839e-05 (W 4.12589e-05) | 0.009749 ± 2.0664e-05 (W 6.36498e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025738 ± 0.000207196 (W 0.000233132) | 0.043771 ± 0.000967436 (W 0.00288288) | 0.033532 ± 5.54106e-05 (W 0.000107691) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063248 ± 0.00040883 (W 0.00208785) | 0.101149 ± 0.000960704 (W 0.00272451) | 0.07451 ± 0.000222419 (W 0.000101927) | 🔵 fork 1.60× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007695 ± 0.000174261 (W 5.25195e-05) | 0.007834 ± 4.7648e-05 (W 7.94116e-05) | 0.009868 ± 5.91636e-05 (W 6.6882e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025908 ± 9.23418e-05 (W 0.00111386) | 0.043983 ± 0.00140389 (W 0.00258262) | 0.033723 ± 0.000306649 (W 8.7494e-05) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065403 ± 0.000229674 (W 0.00207786) | 0.100529 ± 0.00265347 (W 0.00301718) | 0.073237 ± 6.9282e-05 (W 0.000382506) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003306 ± 4.30155e-05 (W 3.01861e-05) | 0.003366 ± 0.000168625 (W 3.3426e-05) | 0.003346 ± 5.55908e-05 (W 3.12282e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016291 ± 0.000126623 (W 5.07464e-05) | 0.016691 ± 0.00115677 (W 3.93357e-05) | 0.014117 ± 7.40968e-05 (W 4.85613e-05) | · | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056616 ± 0.00292483 (W 0.00345638) | 0.071694 ± 0.00114586 (W 0.00133765) | 0.037991 ± 0.000248797 (W 0.001528) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.01066 ± 0.00019789 (W 6.50385e-05) | 0.01057 ± 0.000195533 (W 5.02991e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045956 ± 0.000402716 (W 7.5048e-05) | 0.045915 ± 0.000280358 (W 0.000216423) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131857 ± 0.00268384 (W 0.00132763) | 0.132868 ± 0.00361825 (W 0.00202827) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007033 ± 5.7735e-06 (W 3.66633e-05) | 0.007073 ± 2.0664e-05 (W 3.72599e-05) | 0.009739 ± 9.70069e-05 (W 4.96991e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025798 ± 0.000301458 (W 0.000133799) | 0.052268 ± 0.000903869 (W 0.00336706) | 0.033583 ± 8.73689e-05 (W 8.75785e-05) | 🔵 fork 2.03× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.062948 ± 0.00223094 (W 0.00173272) | 0.116528 ± 0.00460782 (W 0.00375959) | 0.074219 ± 0.000352179 (W 0.000132696) | 🔵 fork 1.85× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007825 ± 6.09945e-05 (W 9.80933e-05) | 0.007825 ± 7.2111e-05 (W 8.12355e-05) | 0.009869 ± 0.000102632 (W 4.65328e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026189 ± 0.000117758 (W 0.000139879) | 0.051607 ± 0.000788637 (W 0.00332409) | 0.033492 ± 6.89952e-05 (W 0.00105213) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065022 ± 0.00336176 (W 0.00160131) | 0.118251 ± 0.00561794 (W 0.00374569) | 0.073678 ± 0.000170189 (W 0.000102724) | 🔵 fork 1.82× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00528 ± 4.3589e-05 (W 3e-05) | 0.00519 ± 9.0185e-05 (W 4.50555e-05) | 0.008907 ± 0.000151527 (W 3.83406e-05) | · | 🔵 fork 1.69× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030568 ± 0.0098909 (W 0.000439853) | 0.030297 ± 0.000313307 (W 9.16515e-05) | 0.050334 ± 0.000472982 (W 0.000219985) | · | 🔵 fork 1.65× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n96/b1` | 0.084017 ± 0.000204476 (W 0.000218816) | 0.083858 ± 0.000367179 (W 0.000270845) | 0.13862 ± 0.00052215 (W 0.0012818) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017654 ± 0.000239653 (W 9.39638e-05) | 0.01581 ± 0.000251913 (W 7.95192e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097923 ± 0.00068456 (W 0.000428853) | 0.092332 ± 0.000693839 (W 0.000430128) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.318698 ± 0.00177446 (W 0.00424802) | 0.30475 ± 0.0015341 (W 0.00400606) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013285 ± 1.73205e-05 (W 6.1743e-05) | 0.011041 ± 0.000122882 (W 6.75448e-05) | 0.019897 ± 7.81025e-05 (W 0.000103225) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057968 ± 0.000156312 (W 0.000177697) | 0.052689 ± 0.000129152 (W 0.000351517) | 0.0966 ± 0.000436693 (W 0.00147488) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.189845 ± 0.0004035 (W 0.00336541) | 0.17658 ± 0.000372272 (W 0.00191762) | 0.29808 ± 0.00184839 (W 0.00345206) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014558 ± 8.5967e-05 (W 6.63325e-05) | 0.012473 ± 0.000144222 (W 6.57366e-05) | 0.020158 ± 3.55949e-05 (W 6.22896e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060203 ± 9.50438e-06 (W 0.000132046) | 0.054542 ± 0.000172143 (W 8.57456e-05) | 0.094537 ± 0.000304056 (W 0.00102204) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.203362 ± 0.00157182 (W 0.00279139) | 0.188483 ± 0.00270691 (W 0.00268263) | 0.252422 ± 0.000542021 (W 0.00188768) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00527 ± 6.35085e-06 (W 3.56371e-05) | 0.0052 ± 9.86577e-05 (W 1.81659e-05) | 0.009007 ± 6.50641e-05 (W 8.02446e-05) | · | 🔵 fork 1.71× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030337 ± 0.000149332 (W 9.14292e-05) | 0.030317 ± 3.60555e-05 (W 8.66499e-05) | 0.051026 ± 0.000405936 (W 0.000271246) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103383 ± 0.00405111 (W 0.00395385) | 0.105578 ± 0.00371515 (W 0.00226134) | 0.13887 ± 0.000834185 (W 0.00134063) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017994 ± 0.000162543 (W 6.96419e-05) | 0.01612 ± 9.58662e-05 (W 0.000186537) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097442 ± 9.05005e-05 (W 0.000322071) | 0.092123 ± 0.000176116 (W 0.000377952) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.321091 ± 0.0012078 (W 0.00213662) | 0.305472 ± 0.000903497 (W 0.00342209) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013214 ± 0.00010591 (W 7.6376e-05) | 0.011141 ± 0.000127884 (W 6.82371e-05) | 0.019867 ± 0.0001249 (W 7.47877e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058289 ± 6.245e-05 (W 0.000215305) | 0.052739 ± 0.000177502 (W 0.000398303) | 0.09581 ± 0.000434316 (W 0.00121941) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.193303 ± 9.05373e-05 (W 0.0020689) | 0.19212 ± 0.000627535 (W 0.00423829) | 0.264575 ± 0.0133585 (W 0.00591235) | · | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014768 ± 8.77515e-05 (W 0.000190542) | 0.012443 ± 8.41843e-05 (W 6.80456e-05) | 0.020268 ± 7.46615e-05 (W 8.90213e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060443 ± 0.000341302 (W 7.82304e-05) | 0.054853 ± 0.000426014 (W 0.000279751) | 0.092904 ± 0.000351 (W 0.0014585) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.207318 ± 0.00204483 (W 0.00253917) | 0.205927 ± 0.000554601 (W 0.00508113) | 0.237464 ± 0.000802499 (W 0.00133125) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0053 ± 2.64575e-05 (W 0.000101242) | 0.00521 ± 5.08626e-05 (W 3.23775e-05) | 0.008986 ± 0.000121533 (W 7.25203e-05) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030397 ± 0.000223361 (W 0.00108194) | 0.030157 ± 0.000117205 (W 0.00143603) | 0.051266 ± 0.00038714 (W 0.000448833) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111599 ± 0.000181348 (W 0.00333096) | 0.11228 ± 0.000933517 (W 0.00327027) | 0.140514 ± 0.000252726 (W 0.00151548) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.018054 ± 0.000176163 (W 9.06328e-05) | 0.01591 ± 0.000150111 (W 7.96699e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097623 ± 0.000315817 (W 0.000386651) | 0.092082 ± 0.000277291 (W 0.000398896) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.320349 ± 0.00035168 (W 0.0023773) | 0.30512 ± 0.0011217 (W 0.00328361) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013365 ± 0.000145717 (W 7.30568e-05) | 0.011131 ± 0.000121655 (W 6.65582e-05) | 0.019967 ± 4.7648e-05 (W 6.75152e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.49× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058059 ± 0.000493863 (W 0.000136063) | 0.052769 ± 0.000152756 (W 0.00169172) | 0.09639 ± 0.000471934 (W 0.00139018) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.191318 ± 0.00199186 (W 0.00216147) | 0.205935 ± 0.000419336 (W 0.00190768) | 0.262912 ± 0.0101104 (W 0.00285774) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014567 ± 7.57188e-05 (W 0.000103199) | 0.012483 ± 2.94449e-05 (W 7.41707e-05) | 0.020278 ± 0.000160728 (W 9.02618e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060493 ± 0.000190867 (W 0.000135515) | 0.054783 ± 0.000387957 (W 0.00180937) | 0.093425 ± 0.000151327 (W 0.000442582) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.206206 ± 0.00286194 (W 0.00276574) | 0.216124 ± 0.00359 (W 0.00264724) | 0.236363 ± 0.000311812 (W 0.00158468) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00529 ± 6.80686e-05 (W 3.39116e-05) | 0.00515 ± 6.65833e-05 (W 4.40602e-05) | 0.008025 ± 0.000118462 (W 3.55429e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030146 ± 0.000146868 (W 0.00151253) | 0.030036 ± 0.000149778 (W 7.92925e-05) | 0.043391 ± 0.000151767 (W 0.000169202) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083397 ± 0.000203299 (W 0.000159337) | 0.082906 ± 0.000587343 (W 0.000155146) | 0.124764 ± 0.000365664 (W 0.00108207) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01586 ± 0.000197315 (W 6.75152e-05) | 0.01604 ± 0.000320718 (W 8.23669e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09055 ± 0.000435982 (W 0.00038387) | 0.091221 ± 0.000449735 (W 0.00145161) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.302867 ± 0.00112193 (W 0.0032377) | 0.303128 ± 0.00117508 (W 0.00396447) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011311 ± 5e-05 (W 5.26308e-05) | 0.011251 ± 4.63717e-05 (W 6.37197e-05) | 0.017553 ± 9.2376e-05 (W 7.70065e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050755 ± 0.000100664 (W 0.00024131) | 0.050876 ± 7.64875e-05 (W 0.000112273) | 0.086192 ± 0.000227377 (W 0.00121116) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174176 ± 0.00032333 (W 0.00289004) | 0.174387 ± 0.0003905 (W 0.0027492) | 0.225542 ± 0.000524054 (W 0.00141361) | · | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012433 ± 8.79223e-05 (W 4.13425e-05) | 0.012363 ± 0.00010843 (W 0.000111858) | 0.017333 ± 7.03586e-05 (W 0.00130221) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.05299 ± 8.52467e-05 (W 0.000105594) | 0.052879 ± 6.9282e-05 (W 0.000137569) | 0.083276 ± 9.26337e-05 (W 0.00172265) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.188503 ± 0.00225736 (W 0.00258879) | 0.185928 ± 0.00211726 (W 0.00261069) | 0.21936 ± 0.00112659 (W 0.00157515) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00526 ± 4.04145e-05 (W 1.64317e-05) | 0.00514 ± 3.19427e-05 (W 2.6857e-05) | 0.007884 ± 5.55908e-05 (W 4.70872e-05) | · | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029986 ± 0.000100167 (W 4.88498e-05) | 0.029906 ± 0.00012741 (W 0.00132406) | 0.043702 ± 0.00056103 (W 0.000106911) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102321 ± 0.0010068 (W 0.00149404) | 0.103002 ± 0.00168824 (W 0.000939811) | 0.124573 ± 0.00122588 (W 0.000149991) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01599 ± 0.000125033 (W 0.000123431) | 0.01597 ± 0.000122882 (W 0.000100146) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089888 ± 4.96689e-05 (W 0.00126421) | 0.090099 ± 0.000164521 (W 0.00156753) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.301875 ± 0.00370118 (W 0.00245464) | 0.303628 ± 0.000952248 (W 0.00303707) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011321 ± 0.000111355 (W 4.219e-05) | 0.011501 ± 0.000217348 (W 7.79102e-05) | 0.017563 ± 8.44413e-05 (W 4.70447e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050906 ± 0.000204598 (W 0.000374501) | 0.051046 ± 0.000319511 (W 0.000166094) | 0.085741 ± 0.000294924 (W 0.000146742) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174738 ± 0.00111 (W 0.00274607) | 0.189815 ± 0.00250875 (W 0.00351427) | 0.224781 ± 0.000753393 (W 0.00209096) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012474 ± 0.000141529 (W 7.59289e-05) | 0.012303 ± 7.2111e-05 (W 6.5192e-05) | 0.017252 ± 3.51188e-05 (W 6.84785e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053169 ± 0.000311256 (W 0.000229084) | 0.052889 ± 0.000171407 (W 0.00124469) | 0.082875 ± 0.000113227 (W 0.000192193) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.191268 ± 0.0033592 (W 0.00328232) | 0.206637 ± 0.00613344 (W 0.00726522) | 0.21837 ± 0.000381592 (W 0.00185796) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00528 ± 5.50757e-05 (W 2.79285e-05) | 0.00522 ± 7e-05 (W 4.18485e-05) | 0.008005 ± 8.18535e-05 (W 3.96232e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029926 ± 0.000289885 (W 5.42605e-05) | 0.030046 ± 0.000190421 (W 7.59605e-05) | 0.043231 ± 0.000280993 (W 0.000150207) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111479 ± 0.00370046 (W 0.00483118) | 0.111148 ± 0.00010583 (W 0.00144637) | 0.124793 ± 0.000458694 (W 0.00030198) | · | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.01607 ± 0.000191398 (W 9.42338e-05) | 0.01583 ± 0.000248154 (W 0.00013998) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090019 ± 0.000322274 (W 0.0014988) | 0.090279 ± 0.000188585 (W 0.00153614) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.306654 ± 0.00320855 (W 0.00343477) | 0.304029 ± 0.00159019 (W 0.00305067) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011472 ± 0.00022598 (W 5.49545e-05) | 0.011371 ± 0.000101129 (W 6.49407e-05) | 0.017543 ± 8.05005e-05 (W 8.66326e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050825 ± 0.0001045 (W 0.000246457) | 0.050955 ± 0.00032612 (W 0.000197748) | 0.085279 ± 0.000310516 (W 0.000233785) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174938 ± 0.00225466 (W 0.00205479) | 0.204293 ± 0.00131246 (W 0.00546751) | 0.224921 ± 0.000231884 (W 0.00177441) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012483 ± 8.32666e-05 (W 5.12084e-05) | 0.012433 ± 1.52753e-05 (W 6.65605e-05) | 0.017283 ± 6.76782e-05 (W 6.73521e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052839 ± 0.000438076 (W 0.00157192) | 0.053019 ± 0.000140119 (W 0.000332435) | 0.082945 ± 0.000189033 (W 0.000195909) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.187781 ± 0.00245111 (W 0.00256315) | 0.214181 ± 0.00149797 (W 0.00394188) | 0.218689 ± 0.000999783 (W 0.00149993) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070322 ± 0.000371651 (W 0.000622673) | 0.067176 ± 8.544e-05 (W 0.0011551) | 0.114745 ± 0.00131247 (W 0.00111533) | · | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.388056 ± 0.00458768 (W 0.00291208) | 0.378669 ± 0.00263475 (W 0.00198195) | 0.639135 ± 0.00297897 (W 0.00456894) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.54095 ± 0.0326572 (W 0.00649751) | 2.52101 ± 0.0170114 (W 0.00550784) | 4.04444 ± 0.0148735 (W 0.0189616) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.312404 ± 0.00177837 (W 0.00137826) | 0.314619 ± 0.000988341 (W 0.00182396) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71696 ± 0.012087 (W 0.0110321) | 2.76431 ± 0.013938 (W 0.0068446) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.834 ± 0.229635 (W 0.0562412) | 22.4407 ± 0.0737507 (W 0.0615557) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134351 ± 0.0181528 (W 0.000853995) | 0.136596 ± 0.0182737 (W 0.00324819) | 0.17124 ± 0.0190018 (W 0.00180373) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.986665 ± 0.114834 (W 0.00269024) | 1.03545 ± 0.0181587 (W 0.0053552) | 0.968906 ± 0.131503 (W 0.00247944) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.62941 ± 0.0319168 (W 0.0117576) | 7.14389 ± 0.0408013 (W 0.0179408) | 6.98437 ± 0.0227261 (W 0.0226672) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134752 ± 0.00180365 (W 0.000346376) | 0.135864 ± 0.00133929 (W 0.00196039) | 0.169678 ± 0.000820181 (W 0.00134048) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.757247 ± 0.00670693 (W 0.00348929) | 0.804625 ± 0.0028669 (W 0.00247683) | 0.971111 ± 0.00134951 (W 0.00134998) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.55926 ± 0.0303944 (W 0.021185) | 7.06388 ± 0.119993 (W 0.0196926) | 6.01375 ± 0.0212715 (W 0.0195029) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089758 ± 0.000902248 (W 0.00383626) | 0.103023 ± 0.00280266 (W 0.00829634) | 0.113493 ± 0.00053465 (W 0.001824) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.411139 ± 0.0263928 (W 0.0270837) | 0.405319 ± 0.0096873 (W 0.00902812) | 0.409717 ± 0.00330935 (W 0.00386964) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.56739 ± 0.0306645 (W 0.0304512) | 1.68731 ± 0.0225052 (W 0.0324404) | 1.94645 ± 0.00536693 (W 0.00666959) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309198 ± 0.00127238 (W 0.00192674) | 0.312464 ± 0.00283195 (W 0.00231839) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70648 ± 0.00830608 (W 0.00884976) | 2.76486 ± 0.0104705 (W 0.00933043) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4754 ± 0.0771247 (W 0.0637814) | 18.0767 ± 0.143201 (W 0.0541758) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.136255 ± 0.0160869 (W 0.000490492) | 0.214892 ± 0.0151686 (W 0.00773213) | 0.151303 ± 0.0143435 (W 0.000918642) | 🔵 fork 1.58× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.992697 ± 0.122506 (W 0.00448742) | 1.17151 ± 0.0256478 (W 0.0173337) | 0.377677 ± 0.115721 (W 0.00338102) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 2.63× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.88932 ± 0.107018 (W 0.0269242) | 5.65866 ± 0.0753222 (W 0.0524454) | 2.63194 ± 0.0413735 (W 0.0171539) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.86× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133951 ± 0.00117637 (W 0.00177769) | 0.206025 ± 0.00267453 (W 0.00706008) | 0.150092 ± 0.000615181 (W 0.00102973) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.76297 ± 0.00321636 (W 0.00306083) | 0.897422 ± 0.0153099 (W 0.0251909) | 0.366465 ± 0.000897722 (W 0.00215822) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.72503 ± 0.00822654 (W 0.0286971) | 5.4671 ± 0.0265886 (W 0.0570444) | 1.80848 ± 0.0319172 (W 0.00825232) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 2.61× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.094466 ± 0.000335804 (W 0.00366732) | 0.103874 ± 0.00264523 (W 0.00235459) | 0.115767 ± 0.00101661 (W 0.00149204) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.413553 ± 0.00844437 (W 0.0191454) | 0.452637 ± 0.0103902 (W 0.0204831) | 0.358541 ± 0.000700571 (W 0.00439763) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 1.53434 ± 0.0771147 (W 0.0214534) | 1.66707 ± 0.0300266 (W 0.0299018) | 1.45873 ± 0.0178685 (W 0.0180514) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.310141 ± 0.000880618 (W 0.002365) | 0.313547 ± 0.00177997 (W 0.00213576) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71136 ± 0.00471414 (W 0.00766471) | 2.76538 ± 0.00835598 (W 0.0110524) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.342 ± 0.0187047 (W 0.0879894) | 17.9351 ± 0.20461 (W 0.15666) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.16579 ± 0.000373444 (W 0.00181699) | 0.231643 ± 0.0179531 (W 0.00965535) | 0.19244 ± 0.0248693 (W 0.00299285) | 🔵 fork 1.40× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.997766 ± 0.133087 (W 0.00232168) | 1.28711 ± 0.0094105 (W 0.0264426) | 0.349775 ± 0.163524 (W 0.00263737) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 2.85× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.61945 ± 0.0216182 (W 0.0616398) | 5.75658 ± 0.0801783 (W 0.411301) | 2.45538 ± 0.162354 (W 0.0124349) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 1.88× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.13369 ± 0.000370972 (W 0.00187549) | 0.218228 ± 0.0011965 (W 0.00506749) | 0.146695 ± 0.000597613 (W 0.00147909) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.770721 ± 0.00317187 (W 0.00532728) | 0.938987 ± 0.0193692 (W 0.0260102) | 0.336952 ± 0.00333127 (W 0.00317978) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 2.29× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.63532 ± 0.0551654 (W 0.0143581) | 5.67239 ± 0.0992522 (W 0.123642) | 1.31399 ± 0.0233609 (W 0.00574725) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 3.53× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063188 ± 0.00310037 (W 8.60535e-05) | 0.056034 ± 0.00256353 (W 0.0013094) | 0.094868 ± 0.00247382 (W 0.000356191) | 🔴 fork 1.13× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.322833 ± 0.00388961 (W 0.00201245) | 0.315189 ± 0.00210512 (W 0.002557) | 0.448641 ± 0.00312926 (W 0.00292608) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.07182 ± 0.00516579 (W 0.00219132) | 2.06536 ± 0.00283351 (W 0.00238538) | 3.33215 ± 0.0354944 (W 0.0217687) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290954 ± 0.00142469 (W 0.00142978) | 0.292598 ± 0.00203323 (W 0.00170834) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62676 ± 0.0115911 (W 0.00938351) | 2.6346 ± 0.0148211 (W 0.00548762) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.194 ± 0.134379 (W 0.045352) | 21.244 ± 0.100504 (W 0.0337179) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146804 ± 0.00145795 (W 0.0021261) | 0.145142 ± 0.00134303 (W 0.00184283) | 0.133501 ± 0.000604948 (W 0.00128679) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.705132 ± 0.116838 (W 0.00364277) | 0.697488 ± 0.113909 (W 0.00257585) | 0.818244 ± 0.00249296 (W 0.00234566) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.12634 ± 0.0159495 (W 0.015065) | 6.09981 ± 0.0110173 (W 0.0120583) | 5.21851 ± 0.0142428 (W 0.00928112) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111779 ± 0.000738432 (W 0.00124951) | 0.113262 ± 0.00146249 (W 0.000288592) | 0.13326 ± 0.000485933 (W 0.00131358) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.665615 ± 0.00167461 (W 0.00286845) | 0.665825 ± 0.00368969 (W 0.00368544) | 0.815385 ± 0.00129854 (W 0.00360716) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.05819 ± 0.0123084 (W 0.0289327) | 6.08006 ± 0.0167007 (W 0.0133996) | 5.25113 ± 0.0179644 (W 0.0111726) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.082365 ± 0.000943496 (W 0.00309705) | 0.099907 ± 0.00500891 (W 0.0047151) | 0.092463 ± 0.00102371 (W 0.0003166) | 🔵 fork 1.21× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.344935 ± 0.00569788 (W 0.00898762) | 0.349084 ± 0.0105425 (W 0.024316) | 0.236492 ± 0.00282644 (W 0.00437502) | · | 🔴 fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.14716 ± 0.0212378 (W 0.0227237) | 1.22046 ± 0.0114204 (W 0.0180725) | 1.41511 ± 0.013181 (W 0.00976045) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290012 ± 0.0030067 (W 0.00392997) | 0.290213 ± 0.00154875 (W 0.00147524) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62391 ± 0.00553328 (W 0.00717707) | 2.62652 ± 0.0070627 (W 0.0102536) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9171 ± 0.161351 (W 0.118769) | 16.9976 ± 0.0968978 (W 0.0592137) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146634 ± 0.00190286 (W 0.00175108) | 0.217056 ± 0.00473018 (W 0.0121277) | 0.132789 ± 0.000849425 (W 0.000233046) | 🔵 fork 1.48× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.714079 ± 0.110802 (W 0.00368844) | 0.820946 ± 0.144484 (W 0.0280861) | 0.327874 ± 0.00564408 (W 0.00324736) | · | 🔴 fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.27169 ± 0.041659 (W 0.059441) | 4.57306 ± 0.0294334 (W 0.0385568) | 1.6507 ± 0.0181077 (W 0.00459777) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 2.59× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.11217 ± 0.00020205 (W 0.00140175) | 0.181269 ± 0.00387161 (W 0.00551859) | 0.131697 ± 0.000340686 (W 0.00184678) | 🔵 fork 1.62× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.684433 ± 0.00638371 (W 0.00513492) | 0.756716 ± 0.0064852 (W 0.0219198) | 0.311733 ± 0.000222671 (W 0.00188658) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.23542 ± 0.0455351 (W 0.116712) | 4.40476 ± 0.0271238 (W 0.0311094) | 1.63021 ± 0.00933634 (W 0.0031056) | · | 🔴 fork 2.60× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.088085 ± 0.00065186 (W 0.00252773) | 0.097132 ± 0.00187848 (W 0.00247292) | 0.091161 ± 0.0103357 (W 0.00298191) | 🔵 fork 1.10× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.336198 ± 0.00459144 (W 0.0171096) | 0.396843 ± 0.0204961 (W 0.0155071) | 0.194544 ± 0.0448754 (W 0.0050176) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.07526 ± 0.0300096 (W 0.0240833) | 1.19084 ± 0.00302829 (W 0.0333196) | 0.965166 ± 0.00469071 (W 0.011344) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.290003 ± 0.000808686 (W 0.00190083) | 0.290002 ± 0.00173882 (W 0.00186674) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61636 ± 0.0129498 (W 0.00649182) | 2.62801 ± 0.0113785 (W 0.00899553) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.7553 ± 0.0358977 (W 0.0453839) | 16.8624 ± 0.0730454 (W 0.121387) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.116267 ± 0.0170673 (W 0.000645896) | 0.194434 ± 0.0201824 (W 0.00519313) | 0.13363 ± 0.000454526 (W 0.00134743) | 🔵 fork 1.67× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.707766 ± 0.11652 (W 0.00254224) | 0.928508 ± 0.099993 (W 0.0171834) | 0.314659 ± 0.00133059 (W 0.00215487) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.17318 ± 0.148048 (W 0.0899755) | 4.80757 ± 0.0477617 (W 0.063992) | 1.22938 ± 0.00394674 (W 0.00767674) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 3.39× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.111769 ± 0.000633999 (W 0.00165019) | 0.193742 ± 0.00994284 (W 0.00813566) | 0.132348 ± 0.00092804 (W 0.00195749) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.678488 ± 0.00380143 (W 0.00262163) | 0.81787 ± 0.0125694 (W 0.0307828) | 0.302576 ± 0.00363178 (W 0.00217436) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 2.24× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.10674 ± 0.0440551 (W 0.0347045) | 4.57244 ± 1.74134 (W 0.060295) | 1.20816 ± 0.169722 (W 0.00979968) | · | 🔴 fork 3.40× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188393 ± 0.000329242 (W 0.00168418) | 0.1871 ± 0.000571955 (W 0.00152846) | 0.473698 ± 0.00284073 (W 0.0040357) | · | 🔵 fork 2.51× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.22833 ± 0.00700666 (W 0.0022614) | 1.22792 ± 0.00701184 (W 0.00219166) | 1.85829 ± 0.0158478 (W 0.0039516) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.92049 ± 0.0139481 (W 0.0151418) | 7.90175 ± 0.0122909 (W 0.00855957) | 11.3716 ± 0.0425228 (W 0.0298779) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.781994 ± 0.0348388 (W 0.00665914) | 0.77506 ± 0.0363325 (W 0.00576702) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.98612 ± 0.150785 (W 0.0207401) | 6.16306 ± 0.104703 (W 0.0242788) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 43.8356 ± 0.13012 (W 0.0829975) | 43.6935 ± 0.204728 (W 0.0857097) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.324307 ± 0.000846618 (W 0.00210764) | 0.328445 ± 0.000756155 (W 0.00169532) | 0.501568 ± 0.000704692 (W 0.00235035) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.12085 ± 0.013743 (W 0.00274738) | 2.20788 ± 0.00642091 (W 0.00449891) | 3.30801 ± 0.00723821 (W 0.0109864) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.4785 ± 0.0429037 (W 0.0346704) | 17.4153 ± 0.0637155 (W 0.0367342) | 23.2784 ± 0.0755902 (W 0.0489207) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.323015 ± 0.00180985 (W 0.00266259) | 0.326661 ± 0.00102963 (W 0.00315346) | 0.487995 ± 0.00210423 (W 0.00259382) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.05211 ± 0.0104548 (W 0.00342174) | 2.14553 ± 0.00595853 (W 0.00357403) | 2.83526 ± 0.00388253 (W 0.0100695) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 18.0446 ± 0.299462 (W 0.0591802) | 17.956 ± 0.0890357 (W 0.031624) | 18.8635 ± 0.0227009 (W 0.066416) | · | · |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188853 ± 0.00105171 (W 0.00426132) | 0.202699 ± 0.00260711 (W 0.00175006) | 0.477033 ± 0.00110474 (W 0.00381509) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.53× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.839411 ± 0.0117098 (W 0.00990881) | 0.869489 ± 0.00768149 (W 0.0106042) | 0.797264 ± 0.00552583 (W 0.0124295) | · | 🔴 fork 1.05× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.37014 ± 0.011652 (W 0.0289222) | 3.4065 ± 0.00688151 (W 0.0275968) | 3.64946 ± 0.026799 (W 0.0112155) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.768657 ± 0.00104823 (W 0.0073654) | 0.77367 ± 0.00602122 (W 0.00548136) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.9009 ± 0.0199412 (W 0.0100404) | 6.02004 ± 0.0307028 (W 0.0149541) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.8141 ± 0.175698 (W 0.0706737) | 29.737 ± 0.0729157 (W 0.111483) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.32533 ± 0.000954204 (W 0.0018665) | 0.346238 ± 0.00547733 (W 0.00657035) | 0.483675 ± 0.00552953 (W 0.00280314) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.49× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.58359 ± 0.0117807 (W 0.01385) | 1.69476 ± 0.00389833 (W 0.0190265) | 1.01198 ± 0.00662161 (W 0.00237255) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.1266 ± 0.0295247 (W 0.0573519) | 9.96172 ± 0.0495689 (W 0.053441) | 7.53708 ± 0.0533708 (W 0.0180533) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.324288 ± 0.00165419 (W 0.00241109) | 0.33716 ± 0.000479861 (W 0.00500969) | 0.470983 ± 0.000790467 (W 0.00275897) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.45299 ± 0.00919426 (W 0.0169144) | 1.54834 ± 0.00583602 (W 0.0171242) | 0.898444 ± 0.00573121 (W 0.00378567) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.6383 ± 0.0762843 (W 0.110923) | 10.4156 ± 0.0555318 (W 0.0470682) | 5.62141 ± 0.0636422 (W 0.0194261) | · | 🔴 fork 1.89× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.198932 ± 0.00285701 (W 0.00350388) | 0.216846 ± 0.00150475 (W 0.00400866) | 0.478507 ± 0.000708213 (W 0.00200284) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 2.41× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.837529 ± 0.0186795 (W 0.0220274) | 0.900335 ± 0.0235932 (W 0.0173606) | 0.660175 ± 0.00195778 (W 0.00519031) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.80145 ± 0.0499084 (W 0.0363258) | 2.85696 ± 0.0855735 (W 0.023013) | 2.28953 ± 0.0406352 (W 0.014011) | · | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.773747 ± 0.00487324 (W 0.00530956) | 0.779108 ± 0.00323497 (W 0.00569802) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.90181 ± 0.00513595 (W 0.0235267) | 6.05283 ± 0.0256423 (W 0.0175799) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.0341 ± 0.166724 (W 0.164923) | 28.1348 ± 0.161232 (W 0.145632) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.32569 ± 0.00175064 (W 0.0026581) | 0.367988 ± 0.00539407 (W 0.00479832) | 0.488996 ± 0.00685493 (W 0.00241897) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.53664 ± 0.0018177 (W 0.0164793) | 1.73127 ± 0.02429 (W 0.017643) | 0.695662 ± 0.00239683 (W 0.00504812) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.94629 ± 0.0186571 (W 0.0765377) | 8.95526 ± 0.0780421 (W 0.0337377) | 5.02067 ± 0.0166436 (W 0.0213255) | · | 🔴 fork 1.78× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.324367 ± 0.00240284 (W 0.00316491) | 0.360605 ± 0.00231184 (W 0.00307982) | 0.473337 ± 0.00646223 (W 0.00214181) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.40329 ± 0.0183154 (W 0.0175518) | 1.56883 ± 0.0328737 (W 0.0221014) | 0.667661 ± 0.000885336 (W 0.00317288) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.4744 ± 0.130766 (W 0.142647) | 9.25503 ± 0.115985 (W 0.0563636) | 3.4386 ± 0.00694521 (W 0.00718353) | · | 🔴 fork 2.76× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175258 ± 0.000864137 (W 0.001751) | 0.175328 ± 0.00141179 (W 0.00114449) | 0.40641 ± 0.0038386 (W 0.00347288) | · | 🔵 fork 2.32× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.12912 ± 0.00279083 (W 0.00140349) | 1.13079 ± 0.00473099 (W 0.00367003) | 1.60279 ± 0.00300466 (W 0.0067343) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.51915 ± 0.00789098 (W 0.00956853) | 7.53341 ± 0.00453298 (W 0.021858) | 10.5817 ± 0.0168196 (W 0.0215512) | · | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.752668 ± 0.039876 (W 0.00684803) | 0.753803 ± 0.0361838 (W 0.00518641) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.83009 ± 0.15105 (W 0.0100683) | 5.83939 ± 0.119565 (W 0.0193185) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 42.6999 ± 0.347033 (W 0.0947239) | 42.6838 ± 0.200365 (W 0.0701862) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.294811 ± 0.000349333 (W 0.00251139) | 0.295172 ± 0.000580462 (W 0.00225885) | 0.462345 ± 0.00113223 (W 0.00283793) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.99801 ± 0.0103144 (W 0.00231958) | 2.0039 ± 0.0107507 (W 0.00211635) | 3.23423 ± 0.0105032 (W 0.00592039) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.3982 ± 0.0366622 (W 0.0562819) | 16.375 ± 0.0283106 (W 0.0635632) | 20.2868 ± 0.014932 (W 0.0377557) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292949 ± 0.00193559 (W 0.0019869) | 0.292817 ± 0.000917353 (W 0.00204856) | 0.447218 ± 0.00195327 (W 0.00250564) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93499 ± 0.00465653 (W 0.00527119) | 1.93373 ± 0.00850911 (W 0.00209797) | 2.67344 ± 0.00520229 (W 0.00785097) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 16.9371 ± 0.0349403 (W 0.0360245) | 16.9228 ± 0.0237403 (W 0.0419502) | 17.516 ± 0.0253467 (W 0.0376286) | · | · |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176901 ± 0.00200058 (W 0.00236549) | 0.191037 ± 0.00278749 (W 0.0054699) | 0.408064 ± 0.00304662 (W 0.00297134) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.31× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.769472 ± 0.0109871 (W 0.0107955) | 0.782052 ± 0.00426184 (W 0.0101879) | 0.598199 ± 0.000619148 (W 0.00824726) | · | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.99358 ± 0.00393826 (W 0.0159454) | 3.04886 ± 0.0249057 (W 0.0142043) | 3.2196 ± 0.0173749 (W 0.0126126) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.744355 ± 0.00384835 (W 0.00675613) | 0.746689 ± 0.00543648 (W 0.00671291) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.73354 ± 0.00751618 (W 0.00675465) | 5.75613 ± 0.0167481 (W 0.0316898) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.6057 ± 0.0176194 (W 0.16793) | 28.6538 ± 0.118169 (W 0.0907184) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295374 ± 0.000731685 (W 0.00246023) | 0.314709 ± 0.00312298 (W 0.00747784) | 0.45966 ± 0.00347623 (W 0.00281826) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.45216 ± 0.0042113 (W 0.00837432) | 1.49002 ± 0.0146664 (W 0.0184023) | 0.976307 ± 0.000257826 (W 0.00417098) | · | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.0122 ± 0.0106176 (W 0.0707584) | 9.03707 ± 0.0254457 (W 0.0517023) | 5.79708 ± 0.0105381 (W 0.0170306) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.291506 ± 0.00019133 (W 0.00231991) | 0.305272 ± 0.00354015 (W 0.00651173) | 0.448019 ± 0.00234271 (W 0.00224291) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.32741 ± 0.00535681 (W 0.0127895) | 1.33599 ± 0.00871209 (W 0.0182348) | 0.85467 ± 0.00436264 (W 0.00464405) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.43795 ± 0.021576 (W 0.0736689) | 9.4617 ± 0.00307202 (W 0.030975) | 5.3311 ± 0.0261522 (W 0.0196903) | · | 🔴 fork 1.77× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.185036 ± 0.00228717 (W 0.00206803) | 0.201938 ± 0.00202581 (W 0.00545632) | 0.408995 ± 0.00119878 (W 0.00221242) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 2.21× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.747571 ± 0.000966587 (W 0.0150598) | 0.781943 ± 0.0121083 (W 0.0173653) | 0.461234 ± 0.00260793 (W 0.00450452) | · | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.45631 ± 0.0346021 (W 0.0190369) | 2.52388 ± 0.0388794 (W 0.0252974) | 1.86119 ± 0.017008 (W 0.0128603) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.748162 ± 0.0065617 (W 0.00463401) | 0.750274 ± 0.00721039 (W 0.00484222) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74388 ± 0.026967 (W 0.0148446) | 5.75249 ± 0.0155714 (W 0.0205054) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.0305 ± 0.0959644 (W 0.112918) | 27.0012 ± 0.0489329 (W 0.116373) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296995 ± 0.00149179 (W 0.00217932) | 0.337031 ± 0.00540447 (W 0.00762856) | 0.459912 ± 0.00255273 (W 0.00293274) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.41573 ± 0.00710334 (W 0.0150618) | 1.48887 ± 0.0219049 (W 0.0250471) | 0.678158 ± 0.00234926 (W 0.00391787) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 7.83963 ± 0.0187995 (W 0.0546453) | 8.03369 ± 0.0881789 (W 0.0506668) | 3.46881 ± 0.0123132 (W 0.0114408) | · | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292578 ± 0.000605473 (W 0.00207725) | 0.328325 ± 0.00613204 (W 0.00404734) | 0.448389 ± 0.000672488 (W 0.00252842) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.26852 ± 0.0126869 (W 0.0106846) | 1.32384 ± 0.0240117 (W 0.0248253) | 0.649886 ± 0.00543097 (W 0.00264331) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 8.31291 ± 0.0544817 (W 0.0994519) | 8.42705 ± 0.323324 (W 0.0347647) | 3.30935 ± 0.105568 (W 0.0141764) | · | 🔴 fork 2.51× slower than `lapack-mkl` | `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.813282 ± 0.00191763 (W 0.00184742) | 0.824104 ± 0.00648905 (W 0.00688068) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.4313 ± 0.728187 (W 0.0801854) | 54.0843 ± 0.901914 (W 0.733756) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.469508 ± 0.00833652 (W 0.00289572) | 0.472053 ± 0.00338777 (W 0.00491459) | 0.659476 ± 0.132099 (W 0.00230285) | · | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.3248 ± 0.0437132 (W 0.0524805) | 19.0494 ± 0.0291189 (W 0.0335171) | 17.9222 ± 2.59065 (W 0.150072) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.815287 ± 0.0038638 (W 0.00267614) | 0.819565 ± 0.00469265 (W 0.0054091) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.8519 ± 0.186279 (W 0.0640187) | 23.6834 ± 0.377802 (W 0.137649) | - | 🔵 fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.497951 ± 0.00638411 (W 0.0102392) | 0.510855 ± 0.0164842 (W 0.0130225) | 0.532587 ± 0.117646 (W 0.00276749) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.64404 ± 0.118215 (W 0.0655847) | 13.1162 ± 0.0571435 (W 0.0433265) | 13.4024 ± 1.93831 (W 0.0327411) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814374 ± 0.00328029 (W 0.00197193) | 0.831485 ± 0.00777048 (W 0.0054346) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.766 ± 0.112768 (W 0.102374) | 19.6309 ± 0.117835 (W 0.16407) | - | 🔵 fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.484076 ± 0.499255 (W 0.00183317) | 0.517077 ± 0.0103696 (W 0.0149189) | 0.601447 ± 0.166665 (W 0.00342527) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.83925 ± 0.170782 (W 0.0987727) | 12.2631 ± 0.0152027 (W 0.0463092) | 4.12169 ± 1.90829 (W 0.0248568) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.73195 ± 0.0015666 (W 0.00320464) | 0.735496 ± 0.00355999 (W 0.00800337) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.234 ± 0.649601 (W 0.16276) | 47.2902 ± 0.0409641 (W 0.0909516) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.385011 ± 0.0017018 (W 0.00361186) | 0.386493 ± 0.00175642 (W 0.00324357) | 0.288961 ± 0.00106117 (W 0.0016823) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2575 ± 0.015907 (W 0.0465855) | 13.2437 ± 0.0237053 (W 0.0333705) | 11.7525 ± 0.0446377 (W 0.0326724) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729747 ± 0.00300426 (W 0.00279739) | 0.73756 ± 0.00272151 (W 0.00634155) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6633 ± 0.0664531 (W 0.137545) | 17.7699 ± 0.0906204 (W 0.296943) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.407282 ± 0.00341514 (W 0.0109644) | 0.431718 ± 0.00196437 (W 0.0126344) | 0.287248 ± 0.000242693 (W 0.00234925) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.34936 ± 0.0150024 (W 0.0384129) | 7.38777 ± 0.0145468 (W 0.0366711) | 11.6293 ± 0.111247 (W 0.019757) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730396 ± 0.00321621 (W 0.00371382) | 0.737709 ± 0.00253261 (W 0.00659398) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.692 ± 0.0606619 (W 0.110403) | 13.8664 ± 0.104532 (W 0.0956336) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.393726 ± 0.0034137 (W 0.00438861) | 0.44891 ± 0.00275261 (W 0.0109165) | 0.287337 ± 0.00390083 (W 0.00198006) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.65358 ± 0.0101845 (W 0.0290018) | 6.70539 ± 0.027713 (W 0.0212472) | 3.15379 ± 0.0342509 (W 0.0112709) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79465 ± 0.00290989 (W 0.00312981) | 1.80453 ± 0.0105726 (W 0.00540234) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 149.717 ± 0.487673 (W 0.595092) | 156.319 ± 1.30911 (W 1.37332) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.00778 ± 0.00261442 (W 0.003438) | 1.00369 ± 0.00232644 (W 0.00157679) | 1.19091 ± 0.00525741 (W 0.00542031) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.6101 ± 0.251965 (W 0.074634) | 53.7313 ± 0.0281676 (W 0.0949134) | 56.4071 ± 5.71341 (W 0.146784) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78314 ± 0.0055105 (W 0.0029751) | 1.80676 ± 0.00508117 (W 0.00328449) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 59.0003 ± 0.0792822 (W 0.487176) | 66.3951 ± 0.71288 (W 1.35771) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.838227 ± 0.0035767 (W 0.0154077) | 0.81671 ± 0.121967 (W 0.0210463) | 1.09582 ± 0.00223964 (W 0.00202158) | · | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 22.8681 ± 0.066602 (W 0.167809) | 29.7455 ± 0.0242077 (W 0.0972016) | 58.6095 ± 3.80742 (W 0.420228) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.56× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78104 ± 0.0103835 (W 0.00958069) | 1.80707 ± 0.0136988 (W 0.00244985) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.6545 ± 0.284238 (W 0.371407) | 41.4268 ± 0.0716635 (W 0.21476) | - | 🔵 fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.820705 ± 0.0041148 (W 0.0128455) | 0.802851 ± 0.0118378 (W 0.0144361) | 1.08992 ± 0.00266795 (W 0.0013382) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 18.9446 ± 0.256369 (W 0.154878) | 25.9124 ± 0.0488902 (W 0.0619021) | 57.5605 ± 2.92033 (W 0.0533209) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 3.04× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66466 ± 0.00374383 (W 0.00378022) | 1.67694 ± 0.00497854 (W 0.0066258) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 144.167 ± 0.419827 (W 0.884337) | 143.642 ± 0.484424 (W 0.583478) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.874195 ± 0.000147432 (W 0.00296687) | 0.874876 ± 0.0014772 (W 0.00156773) | 1.09329 ± 0.00194033 (W 0.00244509) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 41.7797 ± 0.105864 (W 0.0630454) | 41.7662 ± 0.0883088 (W 0.0755072) | 50.9529 ± 0.745397 (W 0.0623801) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66214 ± 0.0067399 (W 0.00190296) | 1.67235 ± 0.00716117 (W 0.00575944) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.6242 ± 0.44956 (W 0.531299) | 52.431 ± 0.316449 (W 0.607478) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.714055 ± 0.00804693 (W 0.00808697) | 0.717472 ± 0.00603879 (W 0.0096945) | 1.06921 ± 0.0357183 (W 0.00294335) | · | 🔵 fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 17.4099 ± 0.0251026 (W 0.0625123) | 17.4036 ± 0.0433945 (W 0.0395795) | 49.5898 ± 0.169122 (W 0.113633) | · | 🔵 fork 2.85× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.65874 ± 0.0059338 (W 0.00282189) | 1.6612 ± 0.00808863 (W 0.00175497) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.0335 ± 0.23514 (W 0.417422) | 29.156 ± 9.2612 (W 0.229127) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.699949 ± 0.00118516 (W 0.00892735) | 0.693577 ± 0.00727713 (W 0.0115605) | 1.06903 ± 0.0110402 (W 0.00193631) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.5161 ± 0.0696542 (W 0.0926373) | 13.5233 ± 0.035519 (W 0.0316902) | 49.8376 ± 0.52502 (W 0.0892684) | · | 🔵 fork 3.69× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 74.9722 ± 0.923414 (W 0.314809) | 77.3986 ± 1.41154 (W 0.512577) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.11238 ± 0.0192815 (W 0.00415976) | 1.25591 ± 0.00924707 (W 0.00316624) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.0505 ± 0.118397 (W 0.0730131) | 18.0206 ± 0.366216 (W 0.0613613) | 72.6261 ± 1.49023 (W 2.25992) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 4.52× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.39485 ± 0.000602735 (W 0.00195083) | 0.514733 ± 0.000649875 (W 0.00274773) | 0.927124 ± 0.134082 (W 0.00264727) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.5556 ± 0.364721 (W 0.205474) | 40.1542 ± 0.603442 (W 0.326799) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.11618 ± 0.0117516 (W 0.00658359) | 1.24599 ± 0.00890496 (W 0.00180217) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.16836 ± 0.0854446 (W 0.0638869) | 9.31284 ± 0.11389 (W 0.04467) | 10.1424 ± 0.112964 (W 0.0602418) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.228017 ± 0.0070381 (W 0.00289134) | 0.384369 ± 0.0041441 (W 0.0146474) | 0.28862 ± 0.00586061 (W 0.00520538) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 33.2145 ± 0.264576 (W 0.0935887) | 35.9754 ± 0.864109 (W 0.21572) | - | 🔵 fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12128 ± 0.0054993 (W 0.00677003) | 1.24207 ± 0.355207 (W 0.00391265) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 6.12885 ± 0.109904 (W 0.184673) | 8.00388 ± 0.233742 (W 0.13578) | 6.90186 ± 1.60196 (W 0.0205481) | 🔵 fork 1.31× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.210634 ± 0.00126265 (W 0.00426442) | 0.343342 ± 0.0199025 (W 0.0227862) | 0.173906 ± 0.00269087 (W 0.00173755) | 🔵 fork 1.63× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.1849 ± 0.605328 (W 0.434996) | 73.2399 ± 1.24184 (W 1.36762) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04618 ± 0.00348299 (W 0.00328899) | 1.05121 ± 0.00667125 (W 0.0013776) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2487 ± 0.106035 (W 0.0134108) | 13.2974 ± 0.0707952 (W 0.0428971) | 210.579 ± 0.218509 (W 0.372665) | · | 🔵 fork 15.89× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.312746 ± 0.00240263 (W 0.00221613) | 0.313036 ± 0.00144564 (W 0.00195714) | 3.13445 ± 0.00487346 (W 0.00523001) | · | 🔵 fork 10.02× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.1651 ± 0.158794 (W 0.211031) | 34.9536 ± 0.38414 (W 0.241576) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04553 ± 0.00142205 (W 0.00190855) | 1.04955 ± 0.0104502 (W 0.00305214) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.39097 ± 0.0186571 (W 0.0186183) | 4.65132 ± 0.0157522 (W 0.0176596) | 5.34394 ± 0.0470644 (W 0.0101754) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.136636 ± 0.00161878 (W 0.00246942) | 0.166581 ± 0.00562755 (W 0.00449423) | 0.231152 ± 0.00595232 (W 0.00146778) | 🔵 fork 1.22× faster than `faer-upstream` | 🔵 fork 1.69× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.4368 ± 0.299923 (W 0.114261) | 30.2754 ± 0.702975 (W 0.164114) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05164 ± 0.00824532 (W 0.00336052) | 1.07035 ± 0.331079 (W 0.00438773) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 2.92121 ± 0.00865711 (W 0.0168042) | 3.36158 ± 0.0344646 (W 0.0356907) | 3.17609 ± 0.0195258 (W 0.0065236) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.116598 ± 0.00127315 (W 0.00204504) | 0.158196 ± 0.00611791 (W 0.0310091) | 0.132829 ± 0.00113919 (W 0.00167849) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 226.106 ± 3.98198 (W 1.74393) | 224.927 ± 4.96967 (W 0.651314) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.41324 ± 0.0118076 (W 0.00831195) | 2.43058 ± 0.0533529 (W 0.012384) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.3554 ± 0.0866607 (W 0.0344802) | 46.6681 ± 0.225611 (W 0.0741108) | 88.0984 ± 0.0798405 (W 0.102653) | · | 🔵 fork 1.90× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 1.00795 ± 0.00876922 (W 0.0052471) | 1.0543 ± 0.00132521 (W 0.00464702) | 2.33249 ± 0.0255314 (W 0.00365931) | · | 🔵 fork 2.31× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 97.8247 ± 2.46526 (W 0.496487) | 96.5756 ± 2.50738 (W 0.591042) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.44465 ± 0.021699 (W 0.0165987) | 2.51395 ± 0.0446149 (W 0.01625) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.585 ± 0.0574811 (W 0.0850865) | 18.1869 ± 0.0541105 (W 0.0811216) | 29.2308 ± 3.28167 (W 0.126289) | · | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.454872 ± 0.0209152 (W 0.0155312) | 0.49197 ± 0.00239746 (W 0.00373031) | 0.638985 ± 0.00575283 (W 0.00359361) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.8243 ± 1.48749 (W 0.487941) | 71.1398 ± 1.56993 (W 0.575135) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.41856 ± 0.239483 (W 0.0106215) | 2.54168 ± 0.107877 (W 0.0136688) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 13.0231 ± 0.101778 (W 0.0824963) | 12.3973 ± 0.128082 (W 0.0564044) | 18.8834 ± 0.053367 (W 0.0920817) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.36379 ± 0.00103772 (W 0.00518989) | 0.403886 ± 0.0205813 (W 0.00346529) | 0.453277 ± 0.00390346 (W 0.00216948) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 221.468 ± 4.67768 (W 0.917103) | 221.047 ± 5.2322 (W 0.513625) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.28566 ± 0.0344938 (W 0.00688867) | 2.32557 ± 0.0203767 (W 0.00770369) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.1344 ± 0.0990721 (W 0.0450136) | 42.1919 ± 0.0957882 (W 0.052553) | 73.4097 ± 0.139544 (W 0.067253) | · | 🔵 fork 1.74× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.901355 ± 0.00481562 (W 0.00544734) | 0.898951 ± 0.00560329 (W 0.00383859) | 2.1293 ± 0.00162337 (W 0.00236413) | · | 🔵 fork 2.36× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.9751 ± 3.18868 (W 0.463774) | 93.6245 ± 3.67754 (W 0.720548) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.27281 ± 0.0199995 (W 0.0066616) | 2.2815 ± 0.0104867 (W 0.00968894) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.8025 ± 0.0182041 (W 0.0283721) | 13.8051 ± 0.0328073 (W 0.0443916) | 20.4262 ± 0.0927619 (W 0.0221179) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.321892 ± 0.00170524 (W 0.00270563) | 0.324337 ± 0.0155409 (W 0.00402515) | 0.592438 ± 0.00311913 (W 0.00313905) | · | 🔵 fork 1.84× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 65.5334 ± 0.337942 (W 0.595924) | 65.8378 ± 0.104838 (W 0.7897) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.29575 ± 0.223897 (W 0.0104698) | 2.30195 ± 0.0496493 (W 0.00883195) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 8.24659 ± 0.0297989 (W 0.0261931) | 8.34465 ± 0.0688556 (W 0.0650485) | 11.255 ± 0.039392 (W 0.0161587) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.240661 ± 0.000912434 (W 0.00218759) | 0.243044 ± 0.00165773 (W 0.00775489) | 0.415357 ± 0.00521859 (W 0.0025654) | · | 🔵 fork 1.73× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
