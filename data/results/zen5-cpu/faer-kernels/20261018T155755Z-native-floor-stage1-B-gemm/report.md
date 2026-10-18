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
- timestamp: `2026-10-18T16:02:45.075906Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families gemm --shapes 32x32x32,64x64x64,96x96x96,128x128x128 --no-publish --label native-floor-stage1-B-gemm`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T155755Z-native-floor-stage1-B-gemm/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.49%, worst 58.62% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 35 of 144 engine cells exceed 5% and carry `!`; median within-process relative SD 1.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 2.91605e-05 (W 1.82291e-05) | 0.002324 ± 1.0504e-05 (W 1.37586e-05) | 0.004489 ± 3.19427e-05 (W 3.07132e-05) | · | 🔵 fork 1.94× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017163 ± 6e-05 (W 2.56184e-05) | 0.017062 ± 0.000121533 (W 1.33154e-05) | 0.024366 ± 7.05006e-05 (W 2.96648e-05) | · | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056787 ± 0.000196225 (W 5.2214e-05) | 0.056767 ± 0.000134859 (W 3.67042e-05) | 0.062589 ± 0.000121244 (W 0.000143631) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002335 ± 5.7735e-06 (W 1.33116e-05) | 0.01033 ± 0.000110092 (W 0.00083294) | 0.00503 ± 0.000139237 (W 0.00010807) | 🔵 fork 4.42× faster than `faer-upstream` | 🔵 fork 2.15× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017142 ± 5.61278e-05 (W 2.03765e-05) | 0.023214 ± 0.00152834 (W 0.00255265) | 0.014147 ± 0.0001905 (W 8.33667e-05) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.050176 ± 0.0107584 (W 0.0119853) | 0.045026 ± 0.00863774 (W 0.015932) | 0.022273 ± 0.000407076 (W 0.000156736) | · | 🔴 fork 2.25× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 5.7735e-06 (W 8.61974e-06) | 0.013125 ± 0.000487558 (W 0.00168483) | 0.004869 ± 6.7159e-05 (W 0.000160225) | 🔵 fork 5.65× faster than `faer-upstream` | 🔵 fork 2.10× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017183 ± 8.44413e-05 (W 2.19363e-05) | 0.019397 ± 0.000345408 (W 0.00117163) | 0.01018 ± 0.000241662 (W 0.000320778) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030919 ± 0.000443273 (W 0.00136474) | 0.030438 ± 0.000921364 (W 0.00145397) | 0.014818 ± 0.000122882 (W 0.000210417) | · | 🔴 fork 2.09× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 5.50757e-06 (W 1.14586e-05) | 0.002344 ± 1.1547e-05 (W 2.05985e-05) | 0.004528 ± 1.95021e-05 (W 5.5157e-05) | · | 🔵 fork 1.95× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017083 ± 3.60555e-05 (W 1.80887e-05) | 0.017092 ± 4.50925e-05 (W 4.96921e-05) | 0.024386 ± 8.544e-05 (W 4.72229e-05) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056828 ± 0.000211346 (W 0.00138032) | 0.056898 ± 0.000145583 (W 0.00136685) | 0.062839 ± 8.88819e-05 (W 5.34444e-05) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 5.71577e-05 (W 8.78635e-06) | 0.010541 ± 0.000300467 (W 0.00110325) | 0.00527 ± 0.000139658 (W 0.000121788) | 🔵 fork 4.55× faster than `faer-upstream` | 🔵 fork 2.28× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017063 ± 3.72872e-05 (W 2.86583e-05) | 0.023715 ± 0.00159825 (W 0.00368336) | 0.014287 ± 0.00015308 (W 9.7392e-05) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.049213 ± 0.00282961 (W 0.0155172) | 0.048672 ± 0.0113031 (W 0.0123781) | 0.022322 ± 0.000405216 (W 0.000209822) | · | 🔴 fork 2.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002394 ± 5.50757e-05 (W 2.35648e-05) | 0.012844 ± 0.00116098 (W 0.00145621) | 0.004919 ± 0.000144915 (W 0.000217587) | 🔵 fork 5.37× faster than `faer-upstream` | 🔵 fork 2.05× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017243 ± 0.00010116 (W 2.28035e-05) | 0.019988 ± 0.000753858 (W 0.00164927) | 0.009929 ± 7.76745e-05 (W 0.000241558) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.74× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0318 ± 0.000111132 (W 0.000908977) | 0.030207 ± 0.00155485 (W 0.00154726) | 0.014838 ± 0.000761268 (W 0.00042045) | · | 🔴 fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008857 ± 1.1547e-05 (W 8.3666e-06) | 0.008877 ± 3.51188e-05 (W 1.52086e-05) | 0.011281 ± 8.59089e-05 (W 0.000152736) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067928 ± 0.000330748 (W 0.0015679) | 0.067859 ± 0.000413877 (W 5.05292e-05) | 0.081324 ± 0.0015099 (W 0.0018305) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226902 ± 0.000164746 (W 0.00157832) | 0.22671 ± 0.000381184 (W 0.001232) | 0.270643 ± 0.000541805 (W 0.00314231) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008797 ± 5.85947e-05 (W 1.64317e-05) | 0.008857 ± 5.25389e-05 (W 2.16795e-05) | 0.014457 ± 0.000382694 (W 0.000333202) | · | 🔵 fork 1.64× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.036569 ± 0.00068018 (W 0.00434293) | 0.04169 ± 0.00506347 (W 0.00634767) | 0.035448 ± 0.000131936 (W 0.000466219) | 🔵 fork 1.14× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.087095 ± 0.00122731 (W 0.00784519) | 0.092536 ± 0.00414143 (W 0.00810375) | 0.098036 ± 0.000492476 (W 0.00130601) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008836 ± 2.0664e-05 (W 1.60997e-05) | 0.008897 ± 5.1316e-05 (W 2.54951e-05) | 0.024677 ± 0.0050243 (W 0.000268351) | · | 🔵 fork 2.79× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.038192 ± 0.00162326 (W 0.0017558) | 0.037791 ± 0.000869547 (W 0.00124923) | 0.01596 ± 0.000138564 (W 0.000461362) | · | 🔴 fork 2.39× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.051317 ± 0.00104173 (W 0.00117171) | 0.050827 ± 0.000995335 (W 0.000632844) | 0.042671 ± 0.000242487 (W 0.00105795) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008877 ± 2.88675e-05 (W 2.35627e-05) | 0.008877 ± 2.64575e-05 (W 1.66193e-05) | 0.011122 ± 3.50761e-05 (W 0.000152562) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067698 ± 0.000464429 (W 2.3816e-05) | 0.067788 ± 0.000400027 (W 3.53864e-05) | 0.082006 ± 6.55769e-05 (W 0.000902262) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.2269 ± 0.000389929 (W 0.00167705) | 0.227151 ± 0.000433264 (W 0.00136217) | 0.272096 ± 0.00153961 (W 0.00266952) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008797 ± 3.15753e-05 (W 1.81659e-05) | 0.008866 ± 2.85832e-05 (W 1.8061e-05) | 0.014037 ± 0.000312693 (W 0.000176862) | · | 🔵 fork 1.60× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.040506 ± 0.00337224 (W 0.00551811) | 0.036479 ± 0.00467107 (W 0.00474105) | 0.035367 ± 0.000183576 (W 0.000471254) | · | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.093488 ± 0.00486576 (W 0.00636779) | 0.091133 ± 0.00509157 (W 0.0081331) | 0.099248 ± 0.00162552 (W 0.00164633) | · | 🔵 fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008877 ± 4.72582e-05 (W 1.78885e-05) | 0.008857 ± 4.93288e-05 (W 1.78885e-05) | 0.024817 ± 4.3589e-05 (W 0.000170675) | · | 🔵 fork 2.80× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.037351 ± 0.000877042 (W 0.00148453) | 0.036229 ± 0.00024934 (W 0.00151877) | 0.01599 ± 0.00022942 (W 0.000178309) | · | 🔴 fork 2.34× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.051477 ± 0.000352507 (W 0.00141998) | 0.051457 ± 0.00032833 (W 0.00221615) | 0.042611 ± 0.000361526 (W 0.000291884) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133603 ± 5.02693e-05 (W 0.00142861) | 0.133684 ± 8.01686e-05 (W 0.00216953) | 0.167088 ± 0.000241054 (W 0.002512) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.096152 ± 0.0248005 (W 0.0206426) | 0.076315 ± 0.00644946 (W 0.0196634) | 0.057419 ± 0.000894436 (W 0.00116372) | · | 🔴 fork 1.67× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.07937 ± 0.0040656 (W 0.00991691) | 0.088958 ± 0.017217 (W 0.0211693) | 0.032872 ± 0.000457671 (W 0.00109499) | · | 🔴 fork 2.41× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133663 ± 0.000114806 (W 0.00115575) | 0.133633 ± 0.000156845 (W 0.00152828) | 0.16872 ± 0.000257663 (W 0.00116324) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.06859 ± 0.00521988 (W 0.0196238) | 0.084129 ± 0.00903658 (W 0.0202729) | 0.055876 ± 0.000479293 (W 0.000433723) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.080232 ± 0.0235145 (W 0.022748) | 0.086825 ± 0.0190081 (W 0.0276058) | 0.03177 ± 0.000190553 (W 0.000108458) | · | 🔴 fork 2.53× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.536656 ± 0.000551183 (W 0.00228839) | 0.539866 ± 0.000350563 (W 0.00271723) | 0.6426 ± 0.00704774 (W 0.00527963) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.161788 ± 0.00130865 (W 0.00196443) | 0.159863 ± 0.00029915 (W 0.00166289) | 0.23279 ± 0.000905718 (W 0.00338588) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.124766 ± 0.0119904 (W 0.0170312) | 0.113095 ± 0.00771841 (W 0.00907232) | 0.094218 ± 0.001349 (W 0.000494213) | · | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538914 ± 0.00267699 (W 0.00255168) | 0.537561 ± 0.00113133 (W 0.00188156) | 0.659332 ± 0.00900609 (W 0.00447757) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.161126 ± 0.000337654 (W 0.00499302) | 0.160213 ± 0.0017768 (W 0.00713269) | 0.232431 ± 0.0013807 (W 0.00390546) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.112803 ± 0.00123246 (W 0.0127305) | 0.114196 ± 0.00776104 (W 0.00725041) | 0.095141 ± 0.00070189 (W 0.00159195) | · | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5% |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
