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
- timestamp: `2026-10-18T15:51:26.861170Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families householder_apply --shapes 64,1024x64,4096x256 --no-publish --label native-floor-stage1-A-householder_apply`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T154335Z-native-floor-stage1-A-householder_apply/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.50%, worst 21.47% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 17 of 144 engine cells exceed 5% and carry `!`; median within-process relative SD 0.97%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.04039 ± 0.000319648 (W 9.67988e-05) | 0.040699 ± 0.000106237 (W 0.00164932) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040661 ± 0.00029278 (W 6.28196e-05) | 0.04049 ± 8.45044e-05 (W 7.67607e-05) | - | · | - | `*` one row has no measurement here |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.024518 ± 0.00136403 (W 0.00149778) | 0.024398 ± 0.000122976 (W 0.000434353) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.02532 ± 0.000305363 (W 0.000577894) | 0.024518 ± 0.000262763 (W 0.00077505) | - | · | - | `*` one row has no measurement here |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.02022 ± 0.000544474 (W 0.000611134) | 0.028366 ± 0.000769875 (W 0.00183563) | - | 🔵 fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.021149 ± 0.000330881 (W 0.000508827) | 0.02708 ± 0.00108138 (W 0.00175435) | - | 🔵 fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.04031 ± 0.000308523 (W 0.000106364) | 0.040215 ± 8.13962e-05 (W 8.48127e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040004 ± 1.66433e-05 (W 0.001254) | 0.040019 ± 0.000166676 (W 7.29123e-05) | - | · | - | `*` one row has no measurement here |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.034447 ± 0.00410041 (W 0.000602684) | 0.023847 ± 4.21466e-05 (W 0.000806469) | - | 🔴 fork 1.44× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.034234 ± 0.00345043 (W 0.00248544) | 0.023596 ± 0.000169063 (W 0.000248349) | - | 🔴 fork 1.45× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.028746 ± 0.000472346 (W 0.00138854) | 0.026602 ± 0.000941658 (W 0.00197466) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.028506 ± 0.000285386 (W 0.00140446) | 0.027525 ± 9.10165e-05 (W 0.00157894) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.158946 ± 0.000712942 (W 0.00149934) | 0.158695 ± 0.000813118 (W 0.00165275) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159635 ± 0.000386509 (W 0.000257704) | 0.159785 ± 0.000684609 (W 0.00116474) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.065299 ± 0.000689533 (W 0.000461521) | 0.067902 ± 0.00158863 (W 0.00234889) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.065842 ± 0.000302004 (W 0.00123489) | 0.067722 ± 0.00180766 (W 0.00200493) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.042449 ± 0.000562793 (W 0.000740238) | 0.07178 ± 0.000828158 (W 0.00165725) | - | 🔵 fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.043671 ± 0.000171974 (W 0.00140947) | 0.073815 ± 0.000326184 (W 0.001916) | - | 🔵 fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157193 ± 0.00033251 (W 0.000248031) | 0.157123 ± 0.000616057 (W 0.00022056) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.157628 ± 0.000257424 (W 0.0018706) | 0.157714 ± 0.000115855 (W 0.000284048) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.075439 ± 0.00414343 (W 0.00308085) | 0.066143 ± 0.0014016 (W 0.00115571) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.076541 ± 0.00359649 (W 0.00252149) | 0.065462 ± 0.000570232 (W 0.00103444) | - | 🔴 fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.051511 ± 0.00093409 (W 0.00227806) | 0.072952 ± 0.00135275 (W 0.00282014) | - | 🔵 fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.054356 ± 0.00222969 (W 0.00368499) | 0.07204 ± 0.00113172 (W 0.00272946) | - | 🔵 fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `householder_apply/64`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.556005 ± 0.00386118 (W 0.00166874) | 0.573729 ± 0.0115327 (W 0.00232854) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.556415 ± 0.00216043 (W 0.00198652) | 0.570894 ± 0.0123148 (W 0.00527816) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1477 ± 0.236333 (W 0.0249922) | 35.0822 ± 0.260169 (W 0.0488969) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.1084 ± 0.255916 (W 0.0548852) | 35.1131 ± 0.592332 (W 0.0427946) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.196175 ± 0.00323181 (W 0.0020158) | 0.164075 ± 0.00384975 (W 0.00289882) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.197598 ± 0.00283272 (W 0.0131336) | 0.162816 ± 0.000421967 (W 0.00157245) | - | 🔴 fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.4091 ± 0.0635873 (W 0.100058) | 9.50023 ± 0.0290382 (W 0.0436658) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.1981 ± 0.140912 (W 0.14979) | 9.5013 ± 0.0132476 (W 0.0244986) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.166967 ± 0.00636123 (W 0.0128096) | 0.139241 ± 0.00580378 (W 0.00299408) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.172421 ± 0.00615266 (W 0.0057395) | 0.142486 ± 0.00441779 (W 0.00222925) | - | 🔴 fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.51897 ± 0.0323082 (W 0.0973836) | 5.06887 ± 0.0400241 (W 1.01042) | - | 🔴 fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.61139 ± 0.0622338 (W 0.0627545) | 5.0658 ± 0.0237061 (W 0.0817806) | - | 🔴 fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.597256 ± 0.00729967 (W 0.00330277) | 0.600139 ± 0.00259062 (W 0.00361532) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.594548 ± 0.014821 (W 0.00382084) | 0.59584 ± 0.00786834 (W 0.00164123) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.7675 ± 0.315507 (W 0.0323278) | 35.7598 ± 0.313426 (W 0.0283454) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.7227 ± 0.333097 (W 0.0429681) | 35.7639 ± 0.351274 (W 0.0638388) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.198509 ± 0.00365711 (W 0.0105755) | 0.201375 ± 0.00084561 (W 0.00138386) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.206926 ± 0.00576823 (W 0.00466979) | 0.201142 ± 0.0033301 (W 0.00114107) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.0872 ± 0.0567647 (W 0.0664644) | 11.1872 ± 0.068674 (W 0.0709776) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2857 ± 0.056701 (W 0.0242336) | 11.2406 ± 0.0150178 (W 0.0222443) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.160928 ± 0.0027367 (W 0.00560399) | 0.184518 ± 0.00294964 (W 0.00408306) | - | 🔵 fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.169291 ± 0.00275017 (W 0.0064543) | 0.184999 ± 0.00255582 (W 0.00310752) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.8725 ± 0.120033 (W 0.117203) | 6.99197 ± 0.0945001 (W 0.139544) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.69828 ± 0.152765 (W 0.117196) | 7.00805 ± 0.0487844 (W 0.818479) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19062 ± 0.0145441 (W 0.00323758) | 2.23046 ± 0.0189312 (W 0.00645688) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20795 ± 0.0148329 (W 0.00654802) | 2.19931 ± 0.0376553 (W 0.00729286) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.733 ± 0.951595 (W 0.0812885) | 137.726 ± 1.00318 (W 0.0633946) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.649 ± 0.991278 (W 0.106713) | 137.799 ± 1.01461 (W 0.121454) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.624454 ± 0.00511242 (W 0.0097101) | 0.583127 ± 0.00189321 (W 0.0019986) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.624284 ± 0.00570529 (W 0.0101947) | 0.610097 ± 0.00353803 (W 0.00289756) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.1249 ± 0.214669 (W 0.441229) | 37.1696 ± 0.29755 (W 0.106489) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.1762 ± 0.109206 (W 0.203528) | 37.0884 ± 0.0787688 (W 0.141115) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.405357 ± 0.0131377 (W 0.0059929) | 0.411654 ± 0.00504966 (W 0.0037023) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.411639 ± 0.0153792 (W 0.010631) | 0.416586 ± 0.00590539 (W 0.00227112) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.9289 ± 0.20608 (W 0.329435) | 18.9333 ± 0.059663 (W 0.103112) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.6276 ± 0.136913 (W 0.389184) | 19.041 ± 0.0695239 (W 0.088687) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.27121 ± 0.0196887 (W 0.00946425) | 2.27218 ± 0.00266938 (W 0.00634654) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.28488 ± 0.00702127 (W 0.00253819) | 2.27999 ± 0.00289632 (W 0.00320482) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.939 ± 0.958377 (W 0.426998) | 138.699 ± 1.05145 (W 0.0705725) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.873 ± 0.980566 (W 0.0743636) | 138.886 ± 1.04362 (W 0.381064) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.648071 ± 0.0106026 (W 0.0105235) | 0.644383 ± 0.00535502 (W 0.00218693) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.650065 ± 0.00266534 (W 0.00763517) | 0.648558 ± 0.00117542 (W 0.00190781) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.0105 ± 0.0817436 (W 0.0360181) | 39.5392 ± 0.124028 (W 0.109231) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.1444 ± 0.0374585 (W 0.0533473) | 39.5865 ± 0.261752 (W 0.137597) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.42007 ± 0.00590012 (W 0.00943141) | 0.455922 ± 0.00937242 (W 0.00306182) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.421303 ± 0.00811977 (W 0.00914823) | 0.459398 ± 0.00556063 (W 0.00334371) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.0371 ± 0.0822263 (W 0.413268) | 21.0448 ± 0.195692 (W 0.211605) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.3873 ± 0.210537 (W 0.321439) | 21.1821 ± 0.14565 (W 3.29394) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `householder_apply/1024x64`, `householder_apply/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
