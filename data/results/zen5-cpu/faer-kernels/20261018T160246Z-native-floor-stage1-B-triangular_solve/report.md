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
- timestamp: `2026-10-18T16:07:04.195386Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families triangular_solve --shapes 32,64,128,256 --no-publish --label native-floor-stage1-B-triangular_solve`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T160246Z-native-floor-stage1-B-triangular_solve/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 4.20%, worst 27.43% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 40 of 96 engine cells exceed 5% and carry `!`; median within-process relative SD 0.80%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `triangular_solve/n32/b1` | 0.000681 ± 1.70392e-05 (W 1.89816e-05) | 0.000681 ± 1.12694e-05 (W 1.30115e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001553 ± 4.72582e-05 (W 2.16795e-05) | 0.001473 ± 3.4641e-05 (W 2.07364e-05) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000681 ± 1.18462e-05 (W 1.66823e-05) | 0.000682 ± 1.00167e-05 (W 1.62542e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001493 ± 4.16333e-05 (W 1.64317e-05) | 0.001573 ± 6.08276e-05 (W 1.87083e-05) | - | 🔵 fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000671 ± 1.73205e-05 (W 1.2657e-05) | 0.000671 ± 5.7735e-06 (W 1.22474e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001493 ± 3.21455e-05 (W 2.30478e-05) | 0.001593 ± 6.9282e-05 (W 3.1305e-05) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000742 ± 2.3388e-05 (W 1.32023e-05) | 0.000751 ± 0.000173754 (W 2.50659e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001743 ± 2.70247e-05 (W 1.64073e-05) | 0.001743 ± 3.80832e-05 (W 2.02781e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000761 ± 1.70392e-05 (W 1.27397e-05) | 0.000782 ± 3.56417e-05 (W 2.00823e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001774 ± 6.22923e-05 (W 2.92455e-05) | 0.001834 ± 0.000115036 (W 1.71814e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.000761 ± 1.12694e-05 (W 4.72229e-06) | 0.000752 ± 1.73205e-05 (W 1.84201e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001804 ± 4.12351e-05 (W 1.71843e-05) | 0.001793 ± 3.50761e-05 (W 1.79221e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001052 ± 2.3094e-05 (W 2.48998e-05) | 0.001062 ± 1.1547e-05 (W 1.44983e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002725 ± 6.51178e-05 (W 3.06806e-05) | 0.002746 ± 4.50592e-05 (W 2.55186e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001072 ± 1e-05 (W 2.28035e-05) | 0.001082 ± 2.3094e-05 (W 1.93959e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002705 ± 3.05505e-05 (W 2.34585e-05) | 0.002776 ± 1.53948e-05 (W 5.16846e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001052 ± 5.7735e-06 (W 1.51658e-05) | 0.001082 ± 2e-05 (W 2.42322e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 1e-05 (W 2.09332e-05) | 0.002705 ± 1.52753e-05 (W 2.73861e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001192 ± 5.2915e-05 (W 8.84873e-06) | 0.001232 ± 2.91605e-05 (W 1.14978e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002866 ± 7.55447e-05 (W 1.31643e-05) | 0.002966 ± 0.000125301 (W 1.88468e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001223 ± 3.06649e-05 (W 1.65288e-05) | 0.001253 ± 2.09841e-05 (W 1.34648e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002996 ± 0.00017131 (W 1.65015e-05) | 0.003266 ± 0.000228685 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n32/b1` | 0.001223 ± 2.70247e-05 (W 1.35757e-05) | 0.001192 ± 1.1547e-05 (W 1.22556e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002986 ± 7.84241e-05 (W 1.22474e-05) | 0.002975 ± 3.49333e-05 (W 1.79527e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `triangular_solve/32`, `triangular_solve/64`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004078 ± 0.000337147 (W 2.91548e-05) | 0.003777 ± 0.000337017 (W 5.12835e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011532 ± 0.000829953 (W 0.000162943) | 0.010069 ± 0.00144338 (W 0.000106809) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004208 ± 9.64365e-05 (W 5.43139e-05) | 0.004278 ± 0.000179258 (W 3.60319e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012413 ± 3e-05 (W 0.000120935) | 0.012303 ± 0.000396692 (W 6.1887e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004268 ± 0.00014 (W 3.08253e-05) | 0.004038 ± 0.000317123 (W 3.71484e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011582 ± 0.00102961 (W 7.0214e-05) | 0.010049 ± 0.00150943 (W 8.70241e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004268 ± 4.04145e-05 (W 3.02209e-05) | 0.004789 ± 0.000401232 (W 1.52053e-05) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012614 ± 0.000374941 (W 3.16228e-05) | 0.012814 ± 0.000284113 (W 5.41221e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.00493 ± 3.52184e-05 (W 4.58181e-05) | 0.004278 ± 0.00054951 (W 5.65685e-05) | - | 🔴 fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012744 ± 7e-05 (W 5.72713e-05) | 0.012664 ± 5.56776e-05 (W 6.45755e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.004668 ± 0.000391 (W 2.86059e-05) | 0.004659 ± 0.00032078 (W 4.06202e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012875 ± 5.50485e-05 (W 3.72048e-05) | 0.012834 ± 8.0829e-05 (W 5.5857e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007524 ± 5.50757e-05 (W 2.19089e-05) | 0.007484 ± 5.74195e-05 (W 1.51096e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023615 ± 0.000169638 (W 7.35275e-05) | 0.023655 ± 0.000377969 (W 9.78121e-05) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007505 ± 3.19427e-05 (W 2.73002e-05) | 0.007545 ± 3.09892e-05 (W 3.09887e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023304 ± 0.000430964 (W 8.53247e-05) | 0.023625 ± 0.000357413 (W 9.74638e-05) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007494 ± 5.56776e-05 (W 3.76855e-05) | 0.007504 ± 4.99032e-05 (W 4.42289e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023734 ± 0.00021537 (W 9.12688e-05) | 0.023605 ± 0.000717682 (W 0.00174079) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007885 ± 0.000223681 (W 2.05475e-05) | 0.007805 ± 0.000235521 (W 3.20936e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022913 ± 0.00139609 (W 9.61769e-05) | 0.023033 ± 0.00135408 (W 7.87401e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007895 ± 0.000243023 (W 3.1305e-05) | 0.007725 ± 0.000110666 (W 4.66401e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022423 ± 0.00097368 (W 0.000116118) | 0.022403 ± 0.00108357 (W 0.000106838) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `triangular_solve/n128/b1` | 0.007855 ± 0.000110395 (W 3.73938e-05) | 0.007835 ± 0.000210405 (W 3.56371e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023064 ± 0.00103707 (W 0.00010872) | 0.023174 ± 0.00103643 (W 0.000120026) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `triangular_solve/128`, `triangular_solve/256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
