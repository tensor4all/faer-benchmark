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
- timestamp: `2026-10-18T15:43:34.416478Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families triangular_solve --shapes 32,64,128,256 --no-publish --label native-floor-stage1-A-triangular_solve`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T153955Z-native-floor-stage1-A-triangular_solve/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 3.68%, worst 30.11% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 34 of 96 engine cells exceed 5% and carry `!`; median within-process relative SD 0.86%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `triangular_solve/n32/b1` | 0.000672 ± 1e-05 (W 1.71814e-05) | 0.000671 ± 1.00167e-05 (W 1.85796e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001573 ± 4.93288e-05 (W 2.32852e-05) | 0.001523 ± 5.05008e-05 (W 2.87263e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000661 ± 2.88675e-05 (W 1.95755e-05) | 0.000681 ± 2.08167e-05 (W 2.11707e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001502 ± 5.70117e-05 (W 1.89789e-05) | 0.001553 ± 6.50641e-05 (W 2.22329e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000681 ± 5.7735e-06 (W 1.94216e-05) | 0.000671 ± 6.08276e-06 (W 1.41527e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001503 ± 6.02771e-05 (W 8.94427e-06) | 0.001573 ± 5.56507e-05 (W 2.41081e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000742 ± 2.6839e-05 (W 2.14079e-05) | 0.000771 ± 0.00015972 (W 1.94756e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001763 ± 2.60832e-05 (W 2.04034e-05) | 0.001773 ± 4.55741e-05 (W 1.64712e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000762 ± 1.47309e-05 (W 1.9139e-05) | 0.000761 ± 3.61985e-05 (W 1.81742e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001784 ± 3.06649e-05 (W 1.86896e-05) | 0.001803 ± 8.5967e-05 (W 1.64712e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000771 ± 1.1547e-05 (W 2.27882e-05) | 0.000752 ± 1.0504e-05 (W 1.66793e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001823 ± 3.82143e-05 (W 1.96799e-05) | 0.001793 ± 2.51661e-05 (W 2.20749e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001062 ± 2.64575e-05 (W 2.70185e-05) | 0.001072 ± 2e-05 (W 1.67332e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002705 ± 2.08167e-05 (W 2.96648e-05) | 0.002715 ± 2.51661e-05 (W 3.63318e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001082 ± 2e-05 (W 1.64317e-05) | 0.001072 ± 1e-05 (W 2.07364e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002775 ± 4.93288e-05 (W 3e-05) | 0.002725 ± 3.4641e-05 (W 3.63318e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001072 ± 5.7735e-06 (W 1.61307e-05) | 0.001072 ± 1.52753e-05 (W 2.38747e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 1e-05 (W 9.1214e-06) | 0.002705 ± 1.52753e-05 (W 2.64575e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001193 ± 3.09892e-05 (W 1.13225e-05) | 0.001223 ± 5.7735e-07 (W 2.5044e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002966 ± 1.1547e-05 (W 2.13846e-05) | 0.003005 ± 9.88956e-05 (W 2.07364e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001232 ± 3.21455e-05 (W 5.47723e-06) | 0.001222 ± 4.68722e-05 (W 1.96774e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003056 ± 0.000140358 (W 1.09545e-05) | 0.003256 ± 0.000236961 (W 2.40062e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001243 ± 4.17971e-05 (W 1.77848e-05) | 0.001202 ± 2.60832e-05 (W 1.91364e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003036 ± 3.21455e-05 (W 1.60997e-05) | 0.003045 ± 4.96689e-05 (W 2.10523e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `triangular_solve/32`, `triangular_solve/64`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004037 ± 0.000331805 (W 5.09441e-05) | 0.003697 ± 0.000366497 (W 3.32145e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011411 ± 0.000993782 (W 6.93203e-05) | 0.009768 ± 0.0015425 (W 7.19319e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004178 ± 9.71253e-05 (W 5.44977e-05) | 0.004258 ± 0.00020664 (W 4.85613e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012453 ± 0.000362658 (W 0.000219609) | 0.012473 ± 0.000523986 (W 0.00010065) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004268 ± 0.000136137 (W 5.58766e-05) | 0.004017 ± 0.000298614 (W 5.12835e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011311 ± 0.000879832 (W 7.42044e-05) | 0.009749 ± 0.00167747 (W 5.16265e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004248 ± 4.58258e-05 (W 2.77489e-05) | 0.004909 ± 0.000433622 (W 3.4641e-05) | - | 🔵 fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013064 ± 0.000321979 (W 3.79776e-05) | 0.013044 ± 0.000334889 (W 5.7925e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004879 ± 6.08276e-05 (W 5.36656e-05) | 0.004258 ± 0.000590391 (W 2.50998e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012854 ± 0.000141774 (W 8.13892e-05) | 0.012784 ± 0.000200301 (W 0.00010439) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004678 ± 0.000406007 (W 3.31557e-05) | 0.004609 ± 0.000332866 (W 3.68822e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012683 ± 0.000145741 (W 4.86826e-05) | 0.012814 ± 4.58258e-05 (W 5.57961e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007484 ± 0.00010116 (W 3.03315e-05) | 0.007574 ± 3.4641e-05 (W 3.36779e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023544 ± 0.000147986 (W 8.08084e-05) | 0.023473 ± 0.000552443 (W 8.83702e-05) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007544 ± 1.73205e-05 (W 3.57771e-05) | 0.007554 ± 2.6839e-05 (W 4.24182e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023784 ± 0.000438145 (W 9.46002e-05) | 0.023654 ± 0.000303447 (W 0.000132767) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007494 ± 1e-05 (W 3.57771e-05) | 0.007554 ± 7e-05 (W 5.32466e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023724 ± 0.000383563 (W 8.60593e-05) | 0.023503 ± 0.000132138 (W 0.00190516) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.008265 ± 0.000175214 (W 2.03544e-05) | 0.008285 ± 0.000166233 (W 2.614e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025217 ± 0.000330807 (W 6.58027e-05) | 0.025478 ± 0.000200592 (W 6.98226e-05) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.008135 ± 0.00011415 (W 1.1149e-05) | 0.008165 ± 5.50757e-05 (W 3.31542e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025047 ± 0.000561813 (W 8.81476e-05) | 0.024917 ± 0.00032773 (W 7.22302e-05) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.008196 ± 9.0185e-05 (W 2.62164e-05) | 0.008225 ± 7.80833e-05 (W 2e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025407 ± 0.00037006 (W 5.45738e-05) | 0.025277 ± 0.000176213 (W 6.81564e-05) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `triangular_solve/128`, `triangular_solve/256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
