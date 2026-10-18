# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `7f713a1401f18546d1ef0c134df982be80626b2e`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `651807301c4fd0d485a66038346388dffe289073`
- toolkit commit: `9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5`
- measured binary SHA-256: `f8e8e3337463fe7219395de47c8161bba8c95fb604e743ca89266f587bcfce2a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T15:57:54.317372Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families cholesky --shapes 32,64,96,128,256 --no-publish --label native-floor-stage1-B-cholesky`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T155301Z-native-floor-stage1-B-cholesky/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.69%, worst 64.16% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 38 of 180 engine cells exceed 5% and carry `!`; median within-process relative SD 0.78%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `cholesky/n32/b1` | 0.003196 ± 5.18684e-05 (W 4.00037e-05) | 0.003466 ± 4.78226e-05 (W 1.94242e-05) | 0.004198 ± 3.05505e-05 (W 3.57939e-05) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014999 ± 7.60285e-05 (W 4.41588e-05) | 0.016832 ± 0.00121187 (W 4.57734e-05) | 0.016872 ± 0.000145029 (W 6.95004e-05) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030829 ± 0.000866618 (W 4.58934e-05) | 0.033053 ± 0.000990264 (W 7.57377e-05) | 0.048473 ± 0.000276261 (W 9.84139e-05) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003226 ± 9.50438e-06 (W 2.60806e-05) | 0.003446 ± 0.000196868 (W 2.16795e-05) | 0.004198 ± 4.6188e-05 (W 8.90505e-05) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014999 ± 9.07377e-05 (W 3.63318e-05) | 0.014748 ± 0.00121577 (W 3.93345e-05) | 0.016882 ± 0.000135031 (W 0.00134314) | · | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.03121 ± 0.000243064 (W 5.68093e-05) | 0.061378 ± 0.00168131 (W 0.00529612) | 0.048413 ± 0.000121655 (W 0.000123338) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003226 ± 1.76163e-05 (W 2.92438e-05) | 0.003456 ± 0.000144627 (W 3.57771e-05) | 0.004158 ± 6.35085e-05 (W 7.03562e-05) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015089 ± 0.00102077 (W 4.84593e-05) | 0.016642 ± 0.00108398 (W 5.76481e-05) | 0.017003 ± 0.000189597 (W 6.72309e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.03119 ± 9.81495e-05 (W 4.70032e-05) | 0.070024 ± 0.000595804 (W 0.00153754) | 0.048724 ± 8.01686e-05 (W 8.46759e-05) | 🔵 fork 2.25× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003076 ± 2.51661e-05 (W 1.92354e-05) | 0.003376 ± 3.05014e-05 (W 2.21878e-05) | 0.003417 ± 4.03361e-05 (W 2.2963e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014698 ± 0.000304921 (W 4.32435e-05) | 0.016642 ± 0.000872177 (W 2.62355e-05) | 0.014037 ± 2.51661e-05 (W 3.24037e-05) | 🔵 fork 1.13× faster than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.029997 ± 0.00017493 (W 6.35161e-05) | 0.032141 ± 0.00125306 (W 0.000419823) | 0.038233 ± 0.000107816 (W 6.38616e-05) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003046 ± 4.50925e-05 (W 2.52448e-05) | 0.003297 ± 0.000194054 (W 2.24121e-05) | 0.003326 ± 5.56507e-05 (W 3.21916e-05) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014628 ± 0.00012554 (W 2.33731e-05) | 0.014397 ± 0.00171552 (W 4.72261e-05) | 0.014087 ± 0.000124808 (W 6.96419e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030188 ± 0.00131318 (W 3.70135e-05) | 0.062841 ± 0.00483443 (W 0.00452589) | 0.038543 ± 7.38941e-05 (W 7.02937e-05) | 🔵 fork 2.08× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003086 ± 0.000121244 (W 3.36155e-05) | 0.003286 ± 0.000111505 (W 2.96648e-05) | 0.003416 ± 4.20357e-05 (W 3.17695e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014738 ± 3.25115e-05 (W 4.17289e-05) | 0.016181 ± 0.00110872 (W 1.61307e-05) | 0.014047 ± 4.07063e-05 (W 4.1833e-05) | 🔵 fork 1.10× faster than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030107 ± 0.000155779 (W 8.47779e-05) | 0.071246 ± 0.000893739 (W 0.0018019) | 0.038374 ± 6.37992e-05 (W 0.00017214) | 🔵 fork 2.37× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 3.4641e-05 (W 4.09878e-05) | 0.004869 ± 5.82266e-05 (W 2.90568e-05) | 0.009007 ± 0.00015308 (W 8.8713e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030127 ± 0.00012356 (W 0.000252401) | 0.029307 ± 0.000160575 (W 0.00143517) | 0.051158 ± 0.000571735 (W 0.000335779) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083901 ± 0.000115529 (W 0.000202606) | 0.082969 ± 0.000195372 (W 0.00017742) | 0.139357 ± 0.0220944 (W 0.0015387) | · | 🔵 fork 1.66× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0053 ± 6.84617e-05 (W 3.40176e-05) | 0.004899 ± 8.7178e-05 (W 3.92849e-05) | 0.008707 ± 0.000202362 (W 7.40426e-05) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030538 ± 0.000155393 (W 5.5857e-05) | 0.029316 ± 0.000200301 (W 0.000111149) | 0.051489 ± 0.000102144 (W 0.000403469) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.08402 ± 0.00314463 (W 0.000169848) | 0.101866 ± 0.000963693 (W 0.000546684) | 0.139277 ± 0.0229038 (W 0.000316644) | 🔵 fork 1.21× faster than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 5.56776e-05 (W 3.07929e-05) | 0.004909 ± 1.78979e-05 (W 3.18795e-05) | 0.009047 ± 0.000200127 (W 0.000104394) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030198 ± 0.000297423 (W 6.5569e-05) | 0.029226 ± 0.000180093 (W 0.000123216) | 0.051249 ± 0.000214888 (W 0.000384409) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084352 ± 0.000385333 (W 0.000108158) | 0.109388 ± 0.00345419 (W 0.00405857) | 0.140037 ± 0.000813938 (W 0.00134443) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005169 ± 4.0501e-05 (W 3.51596e-05) | 0.00487 ± 6.60076e-05 (W 4.77001e-05) | 0.007965 ± 0.000101425 (W 2.71901e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029777 ± 0.000160935 (W 4.78571e-05) | 0.028976 ± 0.000171561 (W 9.57147e-05) | 0.043464 ± 0.000298163 (W 0.000343923) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.082959 ± 0.000295107 (W 0.000102417) | 0.082138 ± 0.000200973 (W 0.000134833) | 0.125642 ± 0.000679902 (W 0.00177816) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 4.0501e-05 (W 4.01908e-05) | 0.004909 ± 8.14453e-05 (W 5.41959e-05) | 0.008005 ± 9.0185e-05 (W 3.42666e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030158 ± 0.000133418 (W 6.70619e-05) | 0.028845 ± 0.00143186 (W 0.000101021) | 0.043523 ± 0.000354246 (W 6.38694e-05) | · | 🔵 fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.083109 ± 0.000281603 (W 0.000112291) | 0.09926 ± 0.00380438 (W 0.0014231) | 0.124518 ± 0.000347104 (W 0.00165665) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00521 ± 5.03322e-05 (W 2.78244e-05) | 0.004889 ± 4.0501e-05 (W 4.52239e-05) | 0.007935 ± 5.50757e-05 (W 5.77339e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030248 ± 0.000111505 (W 4.749e-05) | 0.029005 ± 0.000137369 (W 0.000110305) | 0.043162 ± 0.000130615 (W 0.00012973) | · | 🔵 fork 1.43× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083078 ± 8.58157e-05 (W 0.00153447) | 0.10936 ± 0.00056657 (W 0.00375499) | 0.125611 ± 0.00081282 (W 0.00127943) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.067089 ± 0.000178646 (W 0.00108679) | 0.070445 ± 0.0020825 (W 0.00165405) | 0.11447 ± 0.000687956 (W 0.000525062) | · | 🔵 fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.378506 ± 0.00194107 (W 0.00298525) | 0.384296 ± 0.00606423 (W 0.00288105) | 0.640111 ± 0.00308203 (W 0.0029885) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.067519 ± 0.00253277 (W 0.00171682) | 0.109018 ± 0.00158485 (W 0.00416555) | 0.11448 ± 0.000301454 (W 0.000400128) | 🔵 fork 1.61× faster than `faer-upstream` | 🔵 fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.341341 ± 0.00184267 (W 0.0220819) | 0.42222 ± 0.0129606 (W 0.0198806) | 0.407279 ± 0.00473455 (W 0.00481126) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.066808 ± 0.00248381 (W 0.00070064) | 0.106664 ± 0.00132571 (W 0.00364025) | 0.114188 ± 0.000411987 (W 0.00142464) | 🔵 fork 1.60× faster than `faer-upstream` | 🔵 fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.37012 ± 0.0163067 (W 0.0111286) | 0.46189 ± 0.00328177 (W 0.0179765) | 0.36113 ± 0.126018 (W 0.00292647) | 🔵 fork 1.25× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.060616 ± 0.000138684 (W 0.00143146) | 0.063512 ± 0.00186292 (W 0.0016629) | 0.094241 ± 0.00185451 (W 0.000203601) | · | 🔵 fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.316688 ± 0.00155 (W 0.00274387) | 0.316814 ± 0.00545365 (W 0.00269686) | 0.457285 ± 0.00657159 (W 0.00262898) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.060545 ± 0.00212637 (W 0.00138936) | 0.099692 ± 0.00186632 (W 0.00443773) | 0.092817 ± 0.0019047 (W 0.000529704) | 🔵 fork 1.65× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.281939 ± 0.010468 (W 0.0188742) | 0.355822 ± 0.00847513 (W 0.0193827) | 0.242055 ± 0.0187304 (W 0.00500647) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.064083 ± 0.00229433 (W 0.000205643) | 0.0997 ± 0.00102508 (W 0.00308924) | 0.093268 ± 0.000945701 (W 0.000913861) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.302851 ± 0.0011346 (W 0.0150105) | 0.40831 ± 0.0116203 (W 0.0246444) | 0.194571 ± 0.00726901 (W 0.00569638) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.186629 ± 0.000298986 (W 0.00152541) | 0.184702 ± 0.000484325 (W 0.00179712) | 0.478606 ± 0.00372607 (W 0.00318933) | · | 🔵 fork 2.56× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.22017 ± 0.00157915 (W 0.00292692) | 1.22256 ± 0.00421931 (W 0.00254555) | 1.87311 ± 0.0159873 (W 0.00532069) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189382 ± 0.00414372 (W 0.00201544) | 0.202207 ± 0.00116673 (W 0.00578392) | 0.475523 ± 0.00262307 (W 0.00362721) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.51× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.847416 ± 0.00709995 (W 0.00734736) | 0.874953 ± 0.0160272 (W 0.0114708) | 0.790381 ± 0.00275829 (W 0.00965519) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.1939 ± 0.000493028 (W 0.00199743) | 0.207798 ± 0.00227739 (W 0.00426351) | 0.479709 ± 0.00502734 (W 0.0028919) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.47× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.828343 ± 0.0059356 (W 0.0173409) | 0.874617 ± 0.00408313 (W 0.0133181) | 0.65957 ± 0.242987 (W 0.00446296) | 🔵 fork 1.06× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174544 ± 0.000402644 (W 0.00162008) | 0.1728 ± 0.000149001 (W 0.00161349) | 0.408762 ± 0.00107246 (W 0.00253998) | · | 🔵 fork 2.34× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.12921 ± 0.00158464 (W 0.00158674) | 1.12841 ± 0.000967597 (W 0.00144179) | 1.62168 ± 0.026303 (W 0.00539135) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175477 ± 0.00110054 (W 0.00262866) | 0.185084 ± 0.00243648 (W 0.00455388) | 0.410192 ± 0.00315848 (W 0.00321935) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 2.34× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.752183 ± 0.00717677 (W 0.0108679) | 0.78691 ± 0.00861141 (W 0.00808871) | 0.606965 ± 0.0304415 (W 0.0280648) | · | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.181888 ± 0.0004395 (W 0.00263941) | 0.198039 ± 0.00261366 (W 0.00399796) | 0.40803 ± 0.0010414 (W 0.00363881) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 2.24× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.75098 ± 0.00699113 (W 0.0143271) | 0.778813 ± 0.01009 (W 0.012337) | 0.462648 ± 0.00273609 (W 0.00298474) | · | 🔴 fork 1.62× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
