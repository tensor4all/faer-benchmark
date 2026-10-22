# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `50c2b989484f063f4e1b132adc333715391d8b73`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `b09a1dc5bec4c327d94b4745cf3512c3695097f5`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `cb28b8103eca9d14565dc5cc5f1a1f9d1b3f7609b96f17c4c81c8581f4fbd476`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-22T10:57:17.751965Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-small,gemm-mid,gemm-tall,gemm-wide,linalg-mid,linalg-tall --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label baseline-ref-50c2b98-853f008stack --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261022T092932Z-baseline-ref-50c2b98-853f008stack/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.84%, worst 176.76% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 216 of 2124 engine cells exceed 5% and carry `!`; median within-process relative SD 0.43%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
The `vs faer-fork` column is the rotation-averaged ratio
exp(mean over starts of log(engine median / faer-fork median)),
with the per-start ratios beside it: `R > 1`
means the engine was slower than that first-declared row in that start. It removes a
row-position
effect only under one position effect shared by the engines and stable across starts,
and only where every declared engine has a measured row (`*` marks a cell where one has
no row, so no ratio there is position-balanced). `!` marks a cell where some engine's own
per-start median range exceeds 5% of its median, and `p` a balanced cell whose estimated
position-effect ratio exceeds 1.05. Flagged cells are retained, not discarded; the
between-start variation can exceed the difference being compared.
The `vs` columns mark only differences larger than the spread this run recorded for those
two rows (combined between-start SD, floored at 5%), always with the measured library as the subject:
`🔵 <row> X faster than <row>` / `🔴 <row> X slower than <row>` (the subject is the first column of the table, the compared row is named in
the cell, not only in the column header), `·` inside the band, `-` that row is not
measured in this arm. `notes` carries the cell warnings (`*` a declared row has no measurement,
`!` between-start range over 5%, `p` position effect over 5%, dispatch-dominated means the
row is under 20 us so 4T/8T pay thread-region start-up). Per-start ratios and every
chronological sample are in the run directory named at the top of this page (`run*.csv`).
These describe the recorded revisions; they are not a regression claim.

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 2.47049e-05 (W 1.54693e-05) | 0.002344 ± 4.74377e-05 (W 1.85822e-05) | 0.004509 ± 1.53948e-05 (W 3.31104e-05) | · | 🔵 faer-fork 1.93× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017072 ± 0.000132855 (W 1.30384e-05) | 0.017082 ± 0.000148964 (W 2.78244e-05) | 0.024365 ± 8.31084e-05 (W 4.15933e-05) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056776 ± 0.000160936 (W 3.61829e-05) | 0.056796 ± 9.58662e-05 (W 7.78666e-05) | 0.062719 ± 1.00664e-05 (W 0.000177094) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002345 ± 1.52753e-05 (W 2.07894e-05) | 0.01093 ± 0.000263699 (W 0.00100405) | 0.005259 ± 0.000246435 (W 0.00011563) | 🔵 faer-fork 4.66× faster than `faer-upstream` | 🔵 faer-fork 2.24× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017162 ± 3.51188e-05 (W 4.91152e-05) | 0.025427 ± 0.000828322 (W 0.0034636) | 0.013966 ± 0.000132288 (W 0.00012131) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.055083 ± 0.0108242 (W 0.0101287) | 0.051326 ± 0.00490324 (W 0.014204) | 0.022462 ± 0.00035019 (W 0.000198107) | · | 🔴 faer-fork 2.45× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002354 ± 6.1101e-05 (W 2.09093e-05) | 0.013806 ± 0.000782255 (W 0.00124319) | 0.004769 ± 0.000149332 (W 0.000138431) | 🔵 faer-fork 5.86× faster than `faer-upstream` | 🔵 faer-fork 2.03× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017212 ± 0.000170177 (W 2.68328e-05) | 0.018635 ± 0.000627319 (W 0.00129123) | 0.009768 ± 6.48614e-05 (W 0.000248361) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030546 ± 0.000723297 (W 0.00121999) | 0.030538 ± 0.00120131 (W 0.00139659) | 0.014797 ± 4.95681e-05 (W 0.000173826) | · | 🔴 faer-fork 2.06× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 2.88675e-05 (W 1.96774e-05) | 0.002334 ± 3.751e-05 (W 1.51063e-05) | 0.004498 ± 2.09841e-05 (W 3.15801e-05) | · | 🔵 faer-fork 1.92× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017102 ± 0.000132791 (W 3.61012e-05) | 0.017112 ± 0.000116477 (W 4.02765e-05) | 0.024396 ± 4e-05 (W 3.30938e-05) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056788 ± 5.85947e-06 (W 0.000154639) | 0.057108 ± 0.000141987 (W 9.77814e-05) | 0.062706 ± 0.000169474 (W 9.78274e-05) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 1.52753e-05 (W 2.10071e-05) | 0.009969 ± 0.000276219 (W 0.000913232) | 0.00517 ± 8.0829e-05 (W 8.7178e-05) | 🔵 faer-fork 4.25× faster than `faer-upstream` | 🔵 faer-fork 2.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017092 ± 1e-05 (W 1.52053e-05) | 0.024386 ± 0.000471933 (W 0.0039447) | 0.014267 ± 0.000264614 (W 7.20153e-05) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.067889 ± 0.000587514 (W 0.00744557) | 0.069009 ± 0.00226138 (W 0.0122328) | 0.022603 ± 0.000437878 (W 0.000165025) | · | 🔴 faer-fork 3.00× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 3.51188e-05 (W 2.17325e-05) | 0.013495 ± 0.000575751 (W 0.0021638) | 0.004799 ± 0.000127671 (W 0.000211346) | 🔵 faer-fork 5.76× faster than `faer-upstream` | 🔵 faer-fork 2.05× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017072 ± 0.000193176 (W 2.86356e-05) | 0.02124 ± 0.00188573 (W 0.00248091) | 0.009809 ± 9.68005e-05 (W 0.000178895) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030717 ± 0.00136838 (W 0.00180462) | 0.029876 ± 0.000818292 (W 0.00217409) | 0.015018 ± 0.000112694 (W 0.000140145) | · | 🔴 faer-fork 2.05× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008867 ± 6.37992e-05 (W 1.67332e-05) | 0.008946 ± 6.61891e-05 (W 1.58177e-05) | 0.011222 ± 0.000104245 (W 0.0001627) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.068227 ± 0.000299894 (W 5.14782e-05) | 0.067837 ± 0.000310713 (W 3.67872e-05) | 0.081532 ± 0.00028917 (W 0.00142168) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226813 ± 0.000979561 (W 0.00147281) | 0.226989 ± 1.65025e-05 (W 0.00199291) | 0.271366 ± 0.00395014 (W 0.00351561) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008827 ± 5.80259e-05 (W 9.1815e-06) | 0.008856 ± 1.00167e-05 (W 2.31128e-05) | 0.014437 ± 0.000436143 (W 8.61974e-05) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.035978 ± 0.00551182 (W 0.00550734) | 0.041678 ± 0.00212836 (W 0.00551272) | 0.035726 ± 0.000105219 (W 0.000450899) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.090431 ± 0.00450456 (W 0.00749703) | 0.099698 ± 0.00877205 (W 0.00659635) | 0.097992 ± 0.000889541 (W 0.00143649) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008787 ± 6.69104e-05 (W 1.68315e-05) | 0.008836 ± 1.12694e-05 (W 3.61151e-05) | 0.024496 ± 0.00810577 (W 8.41974e-05) | · | 🔵 faer-fork 2.79× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.036309 ± 0.00120691 (W 0.00175743) | 0.037702 ± 0.00119217 (W 0.00144928) | 0.01579 ± 0.000226606 (W 9.45796e-05) | · | 🔴 faer-fork 2.30× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.051666 ± 0.000598804 (W 0.00120712) | 0.050685 ± 0.00105959 (W 0.00171766) | 0.042731 ± 0.000275489 (W 0.000373042) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008926 ± 5.55908e-05 (W 1.9652e-05) | 0.008897 ± 6.15386e-05 (W 2.16795e-05) | 0.011141 ± 3.55949e-05 (W 7.77837e-05) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067946 ± 0.0003047 (W 4.95601e-05) | 0.067818 ± 0.000345315 (W 5.49545e-05) | 0.082033 ± 0.000149168 (W 0.00112637) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226966 ± 0.000573167 (W 0.00180032) | 0.227083 ± 0.000732347 (W 0.00158635) | 0.272721 ± 0.00291194 (W 0.00354539) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008807 ± 5.7735e-06 (W 2.35223e-05) | 0.008877 ± 5.05008e-05 (W 1.02616e-05) | 0.014477 ± 0.000231157 (W 0.000117789) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.041427 ± 0.00190203 (W 0.00445268) | 0.044032 ± 0.00528492 (W 0.00570227) | 0.035456 ± 0.000294177 (W 0.000347825) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.094459 ± 0.00466821 (W 0.00762817) | 0.096009 ± 0.00809615 (W 0.00681841) | 0.098804 ± 0.000380773 (W 0.0014295) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008787 ± 1.47309e-05 (W 2.32444e-05) | 0.008846 ± 8.28674e-05 (W 1.87136e-05) | 0.024667 ± 9.83379e-05 (W 0.000160622) | · | 🔵 faer-fork 2.81× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.037641 ± 0.0015019 (W 0.000879246) | 0.036929 ± 0.000700024 (W 0.00166258) | 0.01579 ± 0.00024077 (W 0.000184069) | · | 🔴 faer-fork 2.38× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.051206 ± 0.00118111 (W 0.00148283) | 0.051116 ± 0.00127997 (W 0.00158952) | 0.042771 ± 0.000301503 (W 0.00031763) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133719 ± 0.00013164 (W 0.00125005) | 0.133749 ± 7.97747e-05 (W 0.00115988) | 0.167537 ± 0.00143282 (W 0.0016017) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.451796 ± 0.000665793 (W 0.00166726) | 0.453696 ± 0.000424798 (W 0.00186906) | 0.481006 ± 0.00244368 (W 0.00180153) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07743 ± 0.00238965 (W 0.000843915) | 1.07154 ± 0.00191634 (W 0.000582039) | 1.20533 ± 0.0119042 (W 0.00329462) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.60981 ± 0.00263001 (W 0.00298054) | 3.61389 ± 0.00173159 (W 0.00173062) | 3.72524 ± 0.0125623 (W 0.00438573) | · | · |  |
| `gemm/512x512x512/b1` | 8.60568 ± 0.0207029 (W 0.012747) | 8.60207 ± 0.00781637 (W 0.0103178) | 9.79305 ± 0.041923 (W 0.00920917) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.3451 ± 0.0689054 (W 0.0350305) | 29.3866 ± 0.04448 (W 0.0261477) | 30.5329 ± 0.256969 (W 0.024606) | · | · |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.071764 ± 0.0134025 (W 0.0158395) | 0.09547 ± 0.0250496 (W 0.0212918) | 0.056635 ± 0.000283768 (W 0.000149727) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.158557 ± 0.00503878 (W 0.0176259) | 0.146996 ± 0.0137211 (W 0.0195848) | 0.135997 ± 0.000636887 (W 0.00128847) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.301232 ± 0.0062376 (W 0.0077669) | 0.302151 ± 0.00416742 (W 0.00636714) | 0.344065 ± 0.000623024 (W 0.00168812) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.934205 ± 0.0014513 (W 0.00484753) | 0.930749 ± 0.00442182 (W 0.00363932) | 1.00889 ± 0.00270877 (W 0.00216454) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.24087 ± 0.0102161 (W 0.0035285) | 2.24982 ± 0.00302476 (W 0.0042767) | 2.92839 ± 0.0944173 (W 0.00616592) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.54715 ± 0.0133636 (W 0.00525206) | 7.52833 ± 0.0118933 (W 0.0262966) | 8.50194 ± 0.0159922 (W 0.0100732) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.075082 ± 0.00708615 (W 0.018403) | 0.114344 ± 0.00276397 (W 0.0273721) | 0.032541 ± 0.000383137 (W 0.000131313) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 2.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.15362 ± 0.0324822 (W 0.0424562) | 0.139531 ± 0.025604 (W 0.0347509) | 0.073759 ± 0.000736769 (W 0.000189331) | · | 🔴 faer-fork 2.08× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.201958 ± 0.0167032 (W 0.0147142) | 0.221689 ± 0.0117086 (W 0.0428086) | 0.179056 ± 0.000595341 (W 0.00147833) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.565249 ± 0.00938529 (W 0.00845245) | 0.563109 ± 0.00304196 (W 0.0125408) | 0.514199 ± 0.00227999 (W 0.00174267) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.20288 ± 0.0019361 (W 0.0070437) | 1.19909 ± 0.00989851 (W 0.0130824) | 1.51884 ± 0.0177278 (W 0.00513508) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.92361 ± 0.0382682 (W 0.0169002) | 3.93509 ± 0.00674521 (W 0.0125463) | 4.65103 ± 0.0380508 (W 0.0165416) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133713 ± 0.000183187 (W 8.68458e-05) | 0.133903 ± 0.000179157 (W 0.00122526) | 0.168118 ± 0.000506824 (W 0.00119639) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.452788 ± 0.00163623 (W 0.00148762) | 0.453039 ± 0.00300485 (W 0.00248015) | 0.484193 ± 0.00245021 (W 0.00180603) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07704 ± 0.00325421 (W 0.00204767) | 1.07067 ± 0.00312013 (W 0.000894041) | 1.20441 ± 0.0057876 (W 0.0022887) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.61669 ± 0.000907932 (W 0.00647082) | 3.61252 ± 0.00733657 (W 0.0023068) | 3.72383 ± 0.00673611 (W 0.0052583) | · | · |  |
| `gemm/512x512x512/b1` | 8.5995 ± 0.00807582 (W 0.0083444) | 8.60718 ± 0.0128712 (W 0.0128594) | 9.77016 ± 0.0719279 (W 0.00744925) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4498 ± 0.00573739 (W 0.035502) | 29.5244 ± 0.0271646 (W 0.0301321) | 30.403 ± 0.202909 (W 0.0437705) | · | · |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.053921 ± 0.00357065 (W 0.0220407) | 0.075812 ± 0.00672671 (W 0.0163745) | 0.055353 ± 0.000634431 (W 0.000279874) | 🔵 faer-fork 1.41× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.140562 ± 0.00272039 (W 0.0143668) | 0.159999 ± 0.0144499 (W 0.0181746) | 0.135042 ± 0.000380331 (W 0.00157886) | 🔵 faer-fork 1.14× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.300788 ± 0.000583086 (W 0.00314351) | 0.300317 ± 0.0012982 (W 0.0072917) | 0.343173 ± 0.00282519 (W 0.00157215) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.932888 ± 0.00221971 (W 0.00274537) | 0.9315 ± 0.00221078 (W 0.0034261) | 1.00481 ± 0.00102195 (W 0.00134995) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.2369 ± 0.00837808 (W 0.00553559) | 2.24355 ± 0.00592305 (W 0.00419272) | 2.83528 ± 0.0758966 (W 0.00758245) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 7.5252 ± 0.0102212 (W 0.0232624) | 7.51536 ± 0.00953524 (W 0.00831432) | 8.47543 ± 0.0133556 (W 0.00568819) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.081743 ± 0.0092545 (W 0.0219182) | 0.075111 ± 0.0161639 (W 0.02351) | 0.03192 ± 0.000301498 (W 6.81858e-05) | · | 🔴 faer-fork 2.56× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.167122 ± 0.0464558 (W 0.0381229) | 0.202638 ± 0.0369142 (W 0.0510071) | 0.074169 ± 0.000340173 (W 0.00151446) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.206908 ± 0.0121668 (W 0.0341693) | 0.227349 ± 0.00955368 (W 0.0496533) | 0.179284 ± 0.00149464 (W 0.00166405) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.559894 ± 0.0115651 (W 0.0170606) | 0.564138 ± 0.000942785 (W 0.0144671) | 0.515173 ± 0.00543458 (W 0.00207449) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.19444 ± 0.00395011 (W 0.012558) | 1.20208 ± 0.00986737 (W 0.00824712) | 1.52464 ± 0.0113678 (W 0.00457461) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.96615 ± 0.0120121 (W 0.018634) | 3.94946 ± 0.0154322 (W 0.0225209) | 4.66541 ± 0.0148039 (W 0.0104112) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.537837 ± 0.000524587 (W 0.0018874) | 0.540813 ± 0.00170822 (W 0.00258039) | 0.653426 ± 0.00228212 (W 0.00706551) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81521 ± 0.000127492 (W 0.00190615) | 1.81912 ± 0.00294417 (W 0.00335982) | 2.15095 ± 0.00739947 (W 0.0101276) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.28322 ± 0.000841665 (W 0.00461401) | 4.29324 ± 0.00276203 (W 0.00268867) | 5.09072 ± 0.0283509 (W 0.0149994) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4614 ± 0.0151816 (W 0.0144129) | 14.4596 ± 0.0131647 (W 0.0111107) | 17.171 ± 0.0278412 (W 0.0528398) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.3197 ± 0.0122447 (W 0.0219497) | 34.3545 ± 0.022811 (W 0.0271597) | 41.0768 ± 0.316351 (W 0.0479657) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.507 ± 0.0495254 (W 0.083155) | 116.599 ± 0.0910081 (W 0.0466054) | 136.849 ± 0.519827 (W 0.42103) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.16056 ± 0.00191079 (W 0.00182186) | 0.160802 ± 0.000735555 (W 0.00426506) | 0.23299 ± 0.000910835 (W 0.0018835) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.474847 ± 0.00407148 (W 0.00303869) | 0.474214 ± 0.00132465 (W 0.00152857) | 0.746109 ± 0.00525373 (W 0.00455793) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.13028 ± 0.00462336 (W 0.00376453) | 1.13031 ± 0.00498521 (W 0.0037125) | 1.82053 ± 0.00347728 (W 0.00806965) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.66914 ± 0.00717513 (W 0.00892835) | 3.67604 ± 0.00703287 (W 0.00813994) | 5.79864 ± 0.007913 (W 0.0107439) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.7227 ± 0.0159376 (W 0.00763827) | 8.72197 ± 0.0214409 (W 0.00606116) | 13.7656 ± 0.0733717 (W 0.020396) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4556 ± 0.0666838 (W 0.0305428) | 29.4804 ± 0.0944453 (W 0.0209005) | 46.627 ± 0.0287421 (W 0.287915) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.113403 ± 0.000198948 (W 0.00357882) | 0.115495 ± 0.0140285 (W 0.0127732) | 0.094447 ± 0.000400771 (W 0.00113887) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.277106 ± 0.00258718 (W 0.00822936) | 0.276121 ± 0.00202354 (W 0.0121695) | 0.297066 ± 0.000981281 (W 0.0034357) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 0.608959 ± 0.000737277 (W 0.0115577) | 0.607666 ± 0.00651048 (W 0.00687277) | 0.708337 ± 0.00271912 (W 0.00264856) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.87227 ± 0.0140252 (W 0.00657709) | 1.86528 ± 0.00763137 (W 0.00998998) | 2.2736 ± 0.0104256 (W 0.0105731) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.50476 ± 0.00980401 (W 0.0150931) | 4.51692 ± 0.0146646 (W 0.0129202) | 5.54413 ± 0.0122793 (W 0.0242895) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.977 ± 2.54122 (W 0.0329467) | 14.9721 ± 0.0129792 (W 0.0134997) | 18.5333 ± 0.348929 (W 0.0984189) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.53909 ± 0.000701188 (W 0.00209698) | 0.539721 ± 0.00207133 (W 0.00178206) | 0.652713 ± 0.0079128 (W 0.00451841) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81168 ± 0.00301741 (W 0.00343066) | 1.81461 ± 0.00202454 (W 0.00203736) | 2.14455 ± 0.0172077 (W 0.0122545) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.28342 ± 0.00429706 (W 0.00336466) | 4.29116 ± 0.0023924 (W 0.00630975) | 5.1391 ± 0.0537812 (W 0.0124125) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4547 ± 0.00873236 (W 0.0162109) | 14.4609 ± 0.00830691 (W 0.0141113) | 17.1809 ± 0.034265 (W 0.0278584) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.3781 ± 0.01671 (W 0.0291868) | 34.4125 ± 0.0108099 (W 0.0400332) | 40.9206 ± 0.0461177 (W 0.0460648) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.475 ± 0.0477221 (W 0.0538452) | 116.655 ± 0.18987 (W 0.361333) | 137.274 ± 0.0874423 (W 0.0987644) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160719 ± 0.00700261 (W 0.00692664) | 0.160573 ± 0.000606441 (W 0.00198136) | 0.233341 ± 0.000620824 (W 0.00268595) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.474265 ± 0.000758406 (W 0.0025089) | 0.469735 ± 0.00278178 (W 0.00362776) | 0.742723 ± 0.00439069 (W 0.00309715) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.12688 ± 0.00154003 (W 0.00312376) | 1.12957 ± 0.00189252 (W 0.00421972) | 1.80019 ± 0.00595864 (W 0.00379381) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.65798 ± 0.0115805 (W 0.0106457) | 3.66735 ± 0.0162452 (W 0.0103427) | 5.78632 ± 0.0105549 (W 0.00709811) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.6959 ± 0.0230232 (W 0.00767576) | 8.71814 ± 0.0410093 (W 0.0103864) | 13.7811 ± 0.0579091 (W 0.0209038) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4919 ± 0.0737148 (W 0.0208265) | 29.4897 ± 0.0562251 (W 0.026419) | 46.5686 ± 0.159437 (W 0.0350795) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.113773 ± 0.00104146 (W 0.00767307) | 0.113962 ± 0.00182773 (W 0.00934296) | 0.094206 ± 0.000742068 (W 0.000899947) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.276075 ± 0.00195155 (W 0.00964748) | 0.281748 ± 0.00547869 (W 0.0160398) | 0.294462 ± 0.00155918 (W 0.00204703) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 0.610072 ± 0.00659704 (W 0.0136818) | 0.615672 ± 0.00564641 (W 0.0122851) | 0.712565 ± 0.00866631 (W 0.00531722) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.87386 ± 0.00558915 (W 0.00939189) | 1.87599 ± 0.0077601 (W 0.00791635) | 2.28803 ± 0.00516033 (W 0.00545988) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.51869 ± 0.00207475 (W 0.00771246) | 4.51674 ± 0.0086164 (W 0.00757306) | 5.5221 ± 0.0266787 (W 0.0175759) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.9975 ± 0.020411 (W 0.0381376) | 14.9991 ± 0.104324 (W 0.0346574) | 18.8171 ± 0.110365 (W 0.055217) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.27155 ± 0.057072 (W 0.00296934) | 1.27073 ± 0.0560297 (W 0.00699552) | 1.622 ± 0.0860481 (W 0.00580203) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.074 ± 0.00343544 (W 0.00702348) | 1.07166 ± 0.00491677 (W 0.00720508) | 1.52486 ± 0.0209212 (W 0.0237647) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08453 ± 0.00291934 (W 0.00157635) | 1.0861 ± 0.000923289 (W 0.00136298) | 1.55863 ± 0.00171177 (W 0.00257294) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.441528 ± 0.00244191 (W 0.0055845) | 0.440746 ± 0.00147829 (W 0.00340821) | 0.412688 ± 0.0100886 (W 0.00404988) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.325717 ± 0.00685074 (W 0.00265414) | 0.322558 ± 0.00609539 (W 0.00269516) | 0.430112 ± 0.00224221 (W 0.00238218) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.311443 ± 0.00138744 (W 0.00670356) | 0.304718 ± 0.0105421 (W 0.0123987) | 0.389214 ± 0.000413723 (W 0.00195518) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.441833 ± 0.00438622 (W 0.00387791) | 0.442916 ± 0.0025325 (W 0.00358751) | 0.255176 ± 0.00867873 (W 0.00214798) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.210201 ± 0.0015639 (W 0.00347171) | 0.211537 ± 0.00382898 (W 0.00321835) | 0.290674 ± 0.00207312 (W 0.00205166) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.192489 ± 0.0151799 (W 0.0187594) | 0.209836 ± 0.0060731 (W 0.0231071) | 0.198471 ± 0.000838003 (W 0.00152301) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.03505 ± 0.00455269 (W 0.00264168) | 1.03539 ± 0.0181251 (W 0.00151238) | 2.6403 ± 0.0173241 (W 0.00819156) | · | 🔵 faer-fork 2.55× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.08889 ± 0.000999666 (W 0.00307199) | 1.09401 ± 0.00267973 (W 0.0047066) | 1.40834 ± 0.00673275 (W 0.0124118) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.13125 ± 0.00292536 (W 0.00282059) | 1.13206 ± 0.00169366 (W 0.00273474) | 1.23838 ± 0.00377888 (W 0.00731942) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.680916 ± 0.00654938 (W 0.0205234) | 0.688554 ± 0.0207834 (W 0.0216689) | 0.647978 ± 0.00346952 (W 0.00381446) | · | · | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.316126 ± 0.00277252 (W 0.00306479) | 0.31642 ± 0.00456968 (W 0.00164672) | 0.430863 ± 0.00376031 (W 0.00274172) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.31111 ± 0.00208155 (W 0.00447327) | 0.315929 ± 0.00313785 (W 0.00393695) | 0.3327 ± 0.00248504 (W 0.00196566) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.12497 ± 0.0269152 (W 0.0254901) | 1.14469 ± 0.0136522 (W 0.0168965) | 0.349244 ± 0.000891741 (W 0.00348725) | · | 🔴 faer-fork 3.22× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.198993 ± 0.00308564 (W 0.00416746) | 0.198534 ± 0.00107287 (W 0.00357586) | 0.294826 ± 0.000749382 (W 0.00131954) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.180178 ± 0.00398817 (W 0.00385246) | 0.181208 ± 0.00237786 (W 0.00328391) | 0.174896 ± 0.00192696 (W 0.00152979) | · | · |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.16229 ± 0.00771043 (W 0.0077329) | 4.1456 ± 0.00807375 (W 0.00423762) | 5.67473 ± 0.0450553 (W 0.0152994) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.33357 ± 0.0119297 (W 0.00434053) | 4.33372 ± 0.00179923 (W 0.00790994) | 5.62089 ± 0.0426625 (W 0.0313537) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.39544 ± 0.00494721 (W 0.00780475) | 4.40351 ± 0.00495831 (W 0.0113695) | 5.27157 ± 0.0245944 (W 0.0112312) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.6773 ± 0.00286427 (W 0.00591307) | 1.68289 ± 0.00141097 (W 0.00564703) | 1.95445 ± 0.00599184 (W 0.00734861) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.2071 ± 0.0152298 (W 0.0146135) | 1.19609 ± 0.000704694 (W 0.00579675) | 1.95387 ± 0.024165 (W 0.0385368) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.15793 ± 0.0078674 (W 0.00424002) | 1.16008 ± 0.011136 (W 0.00434815) | 2.05949 ± 0.00516539 (W 0.00409566) | · | 🔵 faer-fork 1.78× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.921128 ± 0.00994895 (W 0.0043178) | 0.924602 ± 0.0110565 (W 0.00691638) | 0.923833 ± 0.024891 (W 0.00421863) | · | · | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.644913 ± 0.00719801 (W 0.00523159) | 0.649241 ± 0.00890455 (W 0.00452787) | 1.0076 ± 0.120236 (W 0.00506026) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.607175 ± 0.00479095 (W 0.00488102) | 0.611914 ± 0.00267784 (W 0.00465816) | 0.754753 ± 0.00397405 (W 0.00219498) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.06713 ± 0.00644904 (W 0.00544482) | 4.06717 ± 0.0108205 (W 0.00715877) | 5.7246 ± 0.0265774 (W 0.0105901) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.34891 ± 0.0100077 (W 0.00208782) | 4.34927 ± 0.011213 (W 0.00472335) | 5.41381 ± 0.0234106 (W 0.0471293) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.45081 ± 0.00635287 (W 0.00744061) | 4.45276 ± 0.00166266 (W 0.00648783) | 5.73173 ± 0.0969262 (W 0.0138452) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.94732 ± 0.0147206 (W 0.0547614) | 1.9567 ± 0.00750446 (W 0.0383901) | 20.9493 ± 5.76948 (W 0.0123791) | · | 🔵 faer-fork 10.76× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.19687 ± 0.0115315 (W 0.00674254) | 1.19696 ± 0.0161893 (W 0.00883125) | 2.67788 ± 0.33182 (W 0.128997) | · | 🔵 faer-fork 2.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 1.20322 ± 0.0112311 (W 0.00620229) | 1.21083 ± 0.0116382 (W 0.0110373) | 2.06818 ± 0.0207691 (W 0.0175701) | · | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.55999 ± 0.00892619 (W 0.0374495) | 2.56989 ± 0.0251716 (W 0.0497199) | 3.91633 ± 3.7438 (W 0.00515001) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.64184 ± 0.00131805 (W 0.00367615) | 0.641349 ± 0.00206307 (W 0.00531673) | 1.74484 ± 0.130561 (W 0.0179589) | · | 🔵 faer-fork 2.72× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.620677 ± 0.00229656 (W 0.0050213) | 0.623222 ± 0.0043443 (W 0.0066256) | 1.1909 ± 0.0372152 (W 0.0259448) | · | 🔵 faer-fork 1.92× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.13266 ± 0.142463 (W 0.00242853) | 1.1233 ± 0.128552 (W 0.00170542) | 1.25858 ± 0.243581 (W 0.0098181) | · | · | `!` between-start range over 5% |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.311641 ± 0.0017752 (W 0.00377399) | 0.313204 ± 0.000424181 (W 0.00431404) | 0.332517 ± 0.00342846 (W 0.00166874) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.177332 ± 0.00233072 (W 0.00314816) | 0.180038 ± 0.00284892 (W 0.0032433) | 0.174946 ± 0.00200629 (W 0.00180528) | · | · |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08764 ± 0.0541216 (W 0.00570432) | 1.08943 ± 0.0591919 (W 0.00229217) | 1.55954 ± 0.385245 (W 0.0059733) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.306127 ± 0.00482483 (W 0.0102236) | 0.308351 ± 0.00416492 (W 0.00704085) | 0.390328 ± 0.00375564 (W 0.00132451) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.195745 ± 0.00562802 (W 0.0213885) | 0.209622 ± 0.00995654 (W 0.0144046) | 0.197588 ± 0.000409957 (W 0.000588771) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.44547 ± 0.30051 (W 0.00796641) | 4.45262 ± 0.29806 (W 0.00429454) | 5.76985 ± 0.342687 (W 0.020087) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.20288 ± 0.0111143 (W 0.00507561) | 1.2005 ± 0.0153198 (W 0.00866132) | 2.04873 ± 0.00462419 (W 0.0123743) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.620667 ± 0.00295195 (W 0.0042432) | 0.617544 ± 0.00162496 (W 0.00548191) | 1.18722 ± 0.129498 (W 0.031247) | · | 🔵 faer-fork 1.91× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.39264 ± 0.129153 (W 0.00697519) | 4.40159 ± 0.126704 (W 0.00741743) | 5.22927 ± 0.269745 (W 0.00667063) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.1454 ± 0.00233417 (W 0.00237971) | 1.14861 ± 0.00135257 (W 0.00369035) | 2.06593 ± 0.00547908 (W 0.00437542) | · | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.605539 ± 0.00549634 (W 0.0036913) | 0.607372 ± 0.0039379 (W 0.010757) | 0.760878 ± 0.00250438 (W 0.00275074) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.067406 ± 0.000780358 (W 0.000397689) | 0.070472 ± 0.00026939 (W 0.000292024) | 0.115255 ± 0.00158186 (W 0.00192299) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.388001 ± 0.00576029 (W 0.00260658) | 0.389123 ± 0.00442349 (W 0.00220135) | 0.640536 ± 0.00496149 (W 0.00294163) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.50561 ± 0.0102947 (W 0.00267773) | 2.52011 ± 0.00366024 (W 0.00416698) | 4.03355 ± 0.00940279 (W 0.0215742) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.26092 ± 0.00597035 (W 0.00275847) | 2.256 ± 0.000435759 (W 0.00219235) | 1.86058 ± 0.00272775 (W 0.00366087) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.81018 ± 0.0504736 (W 0.00456204) | 9.78619 ± 0.0363072 (W 0.00753079) | 10.0354 ± 0.0176801 (W 0.0279166) | · | · |  |
| `eigh/n512/b1` | 48.6568 ± 0.0390147 (W 0.0380474) | 48.5687 ± 0.106369 (W 0.0710599) | 61.1288 ± 0.143621 (W 0.377626) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.312089 ± 0.00276039 (W 0.00248859) | 0.311667 ± 0.00102137 (W 0.00183753) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70153 ± 0.00628998 (W 0.00803895) | 2.76549 ± 0.0185264 (W 0.00674711) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.9954 ± 0.0515707 (W 0.0486433) | 22.6746 ± 0.0174034 (W 0.070472) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259784 ± 0.000647136 (W 0.000389623) | 0.258526 ± 0.000910902 (W 0.00145538) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.259013 ± 0.000933191 (W 0.00155845) | 0.258773 ± 0.0007336 (W 0.00285166) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93805 ± 0.0198265 (W 0.00294314) | 1.90375 ± 0.0270907 (W 0.00487672) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.90977 ± 0.0251655 (W 0.00385048) | 1.91305 ± 0.0224704 (W 0.00872313) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8792 ± 0.0318509 (W 0.0192883) | 15.8176 ± 0.0525159 (W 0.0209042) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9186 ± 0.0316781 (W 0.021209) | 15.848 ± 0.047236 (W 0.020262) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134282 ± 0.000262124 (W 0.00153605) | 0.137436 ± 0.0177775 (W 0.00224236) | 0.170782 ± 0.0188599 (W 0.00148735) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.979375 ± 0.119081 (W 0.00215743) | 1.03523 ± 0.00485762 (W 0.00375242) | 0.969367 ± 0.137769 (W 0.000990039) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.625 ± 0.0341783 (W 0.00955995) | 7.2066 ± 0.05607 (W 0.0203516) | 6.93696 ± 0.0533855 (W 0.0114502) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |
| `qr/n128/b1` | 0.514434 ± 0.00120347 (W 0.00217034) | 0.514129 ± 0.00156341 (W 0.00229753) | 0.749161 ± 0.00286669 (W 0.00321634) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.88449 ± 0.00531091 (W 0.00184826) | 2.93057 ± 0.00591888 (W 0.00426981) | 4.33209 ± 0.0056659 (W 0.0153068) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.2411 ± 0.0599885 (W 0.0232548) | 20.8419 ± 0.106874 (W 0.0223796) | 30.5824 ± 0.0347105 (W 0.0377758) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.334921 ± 0.00402311 (W 0.00171056) | 0.531521 ± 0.00437468 (W 0.00306368) | 0.373493 ± 0.000974725 (W 0.00275972) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.60982 ± 0.0096251 (W 0.00347799) | 2.8625 ± 0.0171424 (W 0.00658837) | 2.03527 ± 0.0076353 (W 0.00525849) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.91962 ± 0.00422861 (W 0.0164928) | 17.5918 ± 0.0197388 (W 0.0273652) | 14.1622 ± 0.024368 (W 0.038557) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134022 ± 0.0011596 (W 0.000920482) | 0.137196 ± 0.000771727 (W 0.00244208) | 0.170961 ± 0.000715945 (W 0.00214067) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.752588 ± 0.00177106 (W 0.00248751) | 0.809467 ± 0.00160483 (W 0.00278706) | 0.970247 ± 0.0016343 (W 0.00179245) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.54986 ± 0.0160324 (W 0.0128276) | 7.09337 ± 0.0304838 (W 0.015379) | 5.96893 ± 0.0312075 (W 0.0171462) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.68898 ± 0.0127602 (W 0.00571227) | 3.6895 ± 0.00926579 (W 0.00588754) | 3.38984 ± 0.00608697 (W 0.0171845) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.449 ± 0.0346107 (W 0.0133346) | 18.4711 ± 0.0191604 (W 0.0218003) | 18.0701 ± 0.0220003 (W 0.0475401) | · | · |  |
| `svd_thin/n512/b1` | 105.939 ± 0.290216 (W 0.0669083) | 105.883 ± 0.148792 (W 0.0961337) | 116.891 ± 0.762201 (W 0.4415) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69825 ± 0.00579174 (W 0.0017658) | 2.69863 ± 0.00278764 (W 0.00592368) | 1.1969 ± 0.00200979 (W 0.00273308) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4764 ± 0.0154994 (W 0.0190906) | 12.4687 ± 0.015409 (W 0.00552399) | 6.9495 ± 0.0138918 (W 0.0108056) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.3781 ± 0.133734 (W 0.0590822) | 66.3909 ± 0.212031 (W 0.0558142) | 47.7458 ± 0.192877 (W 0.0239036) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004067 ± 0.000102715 (W 3.26986e-05) | 0.004068 ± 0.000196876 (W 4.48698e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012594 ± 0.000100351 (W 6.09442e-05) | 0.012323 ± 0.00021362 (W 7.64546e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.04263 ± 0.0021452 (W 0.000470755) | 0.043001 ± 0.00236899 (W 0.000150775) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.088466 ± 0.0027188 (W 0.00131439) | 0.10639 ± 0.00095502 (W 0.00275993) | 0.114906 ± 0.000622 (W 0.00146953) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.401595 ± 0.00685812 (W 0.0219991) | 0.422298 ± 0.00662311 (W 0.0302334) | 0.409334 ± 0.00135102 (W 0.0033418) | 🔵 faer-fork 1.05× faster than `faer-upstream` | · |  |
| `cholesky/n512/b1` | 1.58128 ± 0.0325828 (W 0.0252689) | 1.66091 ± 0.00785426 (W 0.0333243) | 1.92277 ± 0.0153166 (W 0.00887557) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.3125 ± 0.0331065 (W 0.0137409) | 2.27775 ± 0.00361494 (W 0.0098873) | 1.07547 ± 0.00354877 (W 0.00200289) | · | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.97403 ± 0.036906 (W 0.0277036) | 6.98979 ± 0.0321921 (W 0.0379963) | 4.77798 ± 0.0121729 (W 0.00730172) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.0772 ± 0.193888 (W 0.0389104) | 26.1365 ± 0.157618 (W 0.0704371) | 21.6938 ± 0.0557308 (W 0.0407009) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.311025 ± 0.0020403 (W 0.00175176) | 0.314429 ± 0.0021927 (W 0.00342771) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70764 ± 0.00783289 (W 0.0062063) | 2.77487 ± 0.0133328 (W 0.0128387) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4477 ± 0.0419535 (W 0.0364076) | 18.1959 ± 0.176353 (W 0.159188) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.084318 ± 0.000429906 (W 0.000901819) | 0.082715 ± 0.000466907 (W 0.000720337) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.085882 ± 0.000993964 (W 0.000496382) | 0.083556 ± 0.00119049 (W 0.00116573) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.523957 ± 0.00274498 (W 0.00314869) | 0.516964 ± 0.000798355 (W 0.00361317) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.530497 ± 0.00315627 (W 0.00434188) | 0.524696 ± 0.00682602 (W 0.00219868) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.14555 ± 0.00794914 (W 0.0131958) | 4.08203 ± 0.012904 (W 0.0125345) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.17073 ± 0.0166761 (W 0.0160753) | 4.08176 ± 0.00644421 (W 0.00467268) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134842 ± 0.018352 (W 0.0014725) | 0.206098 ± 0.0225067 (W 0.00461791) | 0.151824 ± 0.0134613 (W 0.00130346) | 🔵 faer-fork 1.53× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.990867 ± 0.117802 (W 0.00292655) | 1.18763 ± 0.0146032 (W 0.026189) | 0.382804 ± 0.110304 (W 0.00289596) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 2.59× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.80032 ± 0.0327942 (W 0.0562512) | 5.55034 ± 0.0891433 (W 0.0361671) | 2.63517 ± 0.00423544 (W 0.0125973) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.82× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.606997 ± 0.0149463 (W 0.039557) | 1.39051 ± 0.0342358 (W 0.0147959) | 0.482507 ± 0.001167 (W 0.00559342) | 🔵 faer-fork 2.29× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.95784 ± 0.00847649 (W 0.0331719) | 3.73626 ± 0.0340207 (W 0.0639891) | 2.01861 ± 0.0146228 (W 0.00565912) | 🔵 faer-fork 1.91× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 10.0291 ± 1.01474 (W 0.0592484) | 14.1022 ± 1.02429 (W 0.104177) | 12.0516 ± 0.0589154 (W 0.037379) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.384383 ± 0.0243156 (W 0.0157631) | 1.42291 ± 0.00042085 (W 0.0223556) | 0.197611 ± 0.000534834 (W 0.00125197) | 🔵 faer-fork 3.70× faster than `faer-upstream` | 🔴 faer-fork 1.95× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.39804 ± 0.0162154 (W 0.027565) | 5.48017 ± 0.0988855 (W 0.034375) | 0.673021 ± 0.00360573 (W 0.00333175) | 🔵 faer-fork 3.92× faster than `faer-upstream` | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.12507 ± 0.0169088 (W 0.0310768) | 21.9786 ± 0.0822401 (W 0.100825) | 3.87244 ± 0.00274263 (W 0.00851795) | 🔵 faer-fork 4.29× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.132649 ± 0.00180982 (W 0.000218395) | 0.201205 ± 0.00202102 (W 0.00908177) | 0.15026 ± 0.000450527 (W 0.00129636) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.762925 ± 0.00271347 (W 0.00279107) | 0.909406 ± 0.00895575 (W 0.0213918) | 0.365968 ± 0.00190127 (W 0.00247263) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.73313 ± 0.0334521 (W 0.0267365) | 5.40436 ± 0.00749001 (W 0.0324318) | 1.80133 ± 0.0235249 (W 0.00393719) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 2.63× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.0307 ± 0.00349151 (W 0.00886075) | 3.02597 ± 0.0253173 (W 0.0276615) | 2.63571 ± 0.00416708 (W 0.00450181) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6762 ± 0.0397256 (W 0.080395) | 13.691 ± 0.0525501 (W 0.0668594) | 12.4938 ± 0.037596 (W 0.0211813) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.6949 ± 0.2901 (W 0.411934) | 61.6142 ± 0.438872 (W 0.385504) | 58.2734 ± 2.34185 (W 0.0727174) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22302 ± 0.00756845 (W 0.00411904) | 2.22962 ± 0.00693939 (W 0.00542259) | 1.14149 ± 0.00361618 (W 0.00291045) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.856 ± 0.105454 (W 0.0540477) | 10.8573 ± 0.0120379 (W 0.0300604) | 6.11627 ± 0.00449813 (W 0.0104913) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.0428 ± 0.0763473 (W 0.532118) | 48.1439 ± 0.122305 (W 0.213609) | 25.8587 ± 0.101522 (W 0.0207162) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.003687 ± 0.000155027 (W 3.22366e-05) | 0.003737 ± 0.000140678 (W 4.30952e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.009778 ± 0.000690591 (W 5.48206e-05) | 0.009789 ± 0.000807628 (W 7.01427e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.041557 ± 0.00337083 (W 0.00330174) | 0.040756 ± 0.0050092 (W 0.00257778) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.091 ± 0.00085497 (W 0.00310538) | 0.105006 ± 0.00162446 (W 0.0024425) | 0.114714 ± 0.00112251 (W 0.00185081) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.402466 ± 0.0114104 (W 0.0249425) | 0.461825 ± 0.0182432 (W 0.0252727) | 0.360016 ± 0.00173245 (W 0.00211556) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.51332 ± 0.00432647 (W 0.0145684) | 1.62345 ± 0.0141414 (W 0.0168701) | 1.45882 ± 0.0109329 (W 0.0149394) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · |  |
| `eigh/n128/b1` | 2.40277 ± 0.00428715 (W 0.0530657) | 2.31201 ± 0.00868624 (W 0.0145327) | 1.00979 ± 0.00470529 (W 0.00363706) | · | 🔴 faer-fork 2.38× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.89904 ± 0.0428791 (W 0.0240185) | 7.08235 ± 0.0493955 (W 0.029633) | 4.01424 ± 0.00675135 (W 0.00733815) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 24.1892 ± 0.0564852 (W 0.0293378) | 24.8515 ± 0.0821987 (W 0.100156) | 15.2444 ± 0.0126932 (W 0.0557865) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309752 ± 0.000680362 (W 0.00141864) | 0.310642 ± 0.00151469 (W 0.00277744) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.69079 ± 0.0043037 (W 0.00630762) | 2.76454 ± 0.00876424 (W 0.0091777) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.2513 ± 0.0504271 (W 0.128474) | 17.9702 ± 0.0876927 (W 0.0856403) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.05873 ± 0.000100167 (W 0.000772727) | 0.099436 ± 0.000923018 (W 0.00224365) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.060574 ± 0.00144344 (W 0.00114603) | 0.102001 ± 0.00231207 (W 0.00212596) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.2841 ± 0.0031068 (W 0.00218525) | 0.413055 ± 0.00201236 (W 0.0227287) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.289743 ± 0.000822456 (W 0.00173498) | 0.398548 ± 0.0122706 (W 0.0172215) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.25231 ± 0.00295602 (W 0.0139967) | 2.50003 ± 0.121577 (W 0.129025) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.25376 ± 0.0097832 (W 0.0143075) | 2.68563 ± 0.117731 (W 0.322512) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.133629 ± 0.00045721 (W 0.00131498) | 0.218639 ± 0.00368015 (W 0.00480905) | 0.14898 ± 0.022418 (W 0.001482) | 🔵 faer-fork 1.64× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.995505 ± 0.137342 (W 0.0063749) | 1.26614 ± 0.0236224 (W 0.0261534) | 0.350588 ± 0.167066 (W 0.00384725) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 2.84× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.6281 ± 0.0103551 (W 0.0482994) | 5.76909 ± 0.0245663 (W 0.0835438) | 2.36305 ± 0.0853456 (W 0.0148316) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.96× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.58706 ± 0.0133612 (W 0.0241026) | 1.91572 ± 0.0303164 (W 0.0250346) | 0.430446 ± 0.0010868 (W 0.00258103) | 🔵 faer-fork 3.26× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.79167 ± 0.0116118 (W 0.0253919) | 4.81876 ± 0.0363948 (W 0.0498382) | 1.79563 ± 0.00812112 (W 0.00593643) | 🔵 faer-fork 2.69× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 8.79145 ± 0.0262591 (W 0.0744612) | 15.8371 ± 0.0267474 (W 0.243201) | 8.98696 ± 0.0299564 (W 0.0241015) | 🔵 faer-fork 1.80× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.346346 ± 0.00286087 (W 0.00695336) | 1.92082 ± 0.00769924 (W 0.0152386) | 0.156012 ± 0.000219304 (W 0.000920643) | 🔵 faer-fork 5.55× faster than `faer-upstream` | 🔴 faer-fork 2.22× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.38697 ± 0.0140828 (W 0.0108106) | 6.58373 ± 0.0236123 (W 0.0519449) | 0.574699 ± 0.00226192 (W 0.00276438) | 🔵 faer-fork 4.75× faster than `faer-upstream` | 🔴 faer-fork 2.41× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.74163 ± 0.00931623 (W 0.0209759) | 25.1131 ± 0.123628 (W 0.125699) | 2.32458 ± 0.00888401 (W 0.00648284) | 🔵 faer-fork 5.30× faster than `faer-upstream` | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133009 ± 0.00116773 (W 0.00174118) | 0.212015 ± 0.00354255 (W 0.00642945) | 0.146625 ± 0.00057988 (W 0.00135454) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.765898 ± 0.00758789 (W 0.00759946) | 0.942507 ± 0.0110034 (W 0.0275167) | 0.335866 ± 0.00232587 (W 0.00324032) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.58961 ± 0.0287452 (W 0.0460494) | 5.60856 ± 0.0954409 (W 0.0857535) | 1.29877 ± 0.0139861 (W 0.00615009) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 3.53× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.05794 ± 0.014288 (W 0.00984649) | 3.1115 ± 0.0164915 (W 0.0174316) | 2.51516 ± 0.010733 (W 0.00621673) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4492 ± 0.0416588 (W 0.0366871) | 13.7545 ± 0.0520991 (W 0.0289449) | 11.5187 ± 0.0281098 (W 0.0106365) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.1922 ± 0.224515 (W 0.445769) | 61.3505 ± 0.314691 (W 0.352159) | 48.5541 ± 2.40261 (W 0.0660612) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22147 ± 0.0443223 (W 0.00440886) | 2.29572 ± 0.0431029 (W 0.00384249) | 1.12653 ± 0.00233546 (W 0.00200058) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.9942 ± 0.0202311 (W 0.0144991) | 10.983 ± 0.0105288 (W 0.0230965) | 6.00464 ± 0.014675 (W 0.00746461) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.3345 ± 0.20506 (W 0.344911) | 49.3195 ± 0.163428 (W 0.41758) | 22.4653 ± 0.117351 (W 0.0250814) | · | 🔴 faer-fork 2.20× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.003887 ± 0.000127307 (W 4.66905e-05) | 0.003656 ± 0.000141811 (W 3.28055e-05) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.009798 ± 9.88956e-05 (W 7.97452e-05) | 0.009798 ± 4.56107e-05 (W 4.52902e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.038121 ± 0.00107886 (W 0.00084393) | 0.037441 ± 0.00151478 (W 0.000666634) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.060523 ± 0.000231625 (W 4.1833e-05) | 0.064169 ± 0.000842761 (W 0.000726338) | 0.093494 ± 0.000452367 (W 0.000264351) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.316396 ± 0.0018467 (W 0.00227939) | 0.322772 ± 0.00347954 (W 0.00207838) | 0.462887 ± 0.00162921 (W 0.00321911) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.05872 ± 0.0019367 (W 0.00151708) | 2.06537 ± 0.00157476 (W 0.00239336) | 3.40982 ± 0.0100566 (W 0.0319584) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.26093 ± 0.00349853 (W 0.00747436) | 2.25646 ± 0.00410245 (W 0.00377879) | 1.82498 ± 0.00430616 (W 0.00939923) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.77089 ± 0.0448436 (W 0.00840539) | 9.73341 ± 0.0387101 (W 0.00825297) | 9.84975 ± 0.00623054 (W 0.0129611) | · | · |  |
| `eigh/n512/b1` | 48.2349 ± 0.0159726 (W 0.0292446) | 48.2093 ± 0.0817836 (W 0.36719) | 60.193 ± 0.0564314 (W 0.0421005) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290648 ± 0.00234789 (W 0.000938585) | 0.28972 ± 0.00231027 (W 0.00170924) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61872 ± 0.00343987 (W 0.0117035) | 2.62725 ± 0.00584695 (W 0.0113867) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.4394 ± 0.0178287 (W 0.0355921) | 21.4658 ± 0.0625089 (W 0.0472502) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.253272 ± 0.00146984 (W 0.00169873) | 0.253933 ± 0.00047622 (W 0.00178157) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.254679 ± 0.000735544 (W 0.00192616) | 0.254755 ± 0.000270452 (W 0.00201237) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.86723 ± 0.0197009 (W 0.00276943) | 1.86664 ± 0.0236409 (W 0.00221248) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.8698 ± 0.00389126 (W 0.00229307) | 1.8686 ± 0.0013774 (W 0.0039418) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.7175 ± 0.0219741 (W 0.0266162) | 15.7558 ± 0.0282892 (W 0.0228204) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.6957 ± 0.0244958 (W 0.033551) | 15.7272 ± 0.0427316 (W 0.0256909) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145554 ± 0.000445249 (W 0.00179125) | 0.144319 ± 0.000395709 (W 0.00139724) | 0.133492 ± 0.000279502 (W 0.00152854) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.697361 ± 0.115018 (W 0.00242885) | 0.700646 ± 0.111766 (W 0.00228533) | 0.816923 ± 0.00174994 (W 0.00233707) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.13556 ± 0.00170238 (W 0.00750632) | 6.12554 ± 0.00951505 (W 0.0116044) | 5.21435 ± 0.0155316 (W 0.0081871) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.488095 ± 0.00050997 (W 0.00181165) | 0.492117 ± 0.0016918 (W 0.00215481) | 0.680599 ± 0.00272579 (W 0.00380763) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.77779 ± 0.00227514 (W 0.00553074) | 2.79035 ± 0.00292539 (W 0.00300514) | 4.30049 ± 0.00820072 (W 0.00691394) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.8089 ± 0.0680815 (W 0.0209048) | 19.6711 ± 0.111017 (W 0.0267041) | 30.2731 ± 0.0364861 (W 0.0206495) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.275203 ± 0.00048671 (W 0.00172733) | 0.279461 ± 0.00299622 (W 0.00195649) | 0.33251 ± 0.00213525 (W 0.00220397) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.37243 ± 0.0060121 (W 0.00345675) | 1.38035 ± 0.00733775 (W 0.00181981) | 1.8983 ± 0.00120005 (W 0.00719983) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.03751 ± 0.0245078 (W 0.00679162) | 8.01189 ± 0.0240306 (W 0.00507167) | 13.4603 ± 0.0749992 (W 0.0174694) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.11251 ± 0.000460726 (W 0.000299854) | 0.112411 ± 0.00070904 (W 0.000961012) | 0.13254 ± 0.000322525 (W 0.00150091) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.665768 ± 0.000279373 (W 0.00252513) | 0.66497 ± 0.00275244 (W 0.00238564) | 0.819274 ± 0.00223879 (W 0.00158673) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.03053 ± 0.0174998 (W 0.00884508) | 6.03904 ± 0.027343 (W 0.0145348) | 5.23136 ± 0.0148317 (W 0.0061583) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.6856 ± 0.00914548 (W 0.00664604) | 3.68551 ± 0.0083953 (W 0.00719876) | 3.31544 ± 0.0159119 (W 0.0181208) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3487 ± 0.0339199 (W 0.01109) | 18.3672 ± 0.0312686 (W 0.0203458) | 17.7023 ± 0.0313964 (W 0.016946) | · | · |  |
| `svd_thin/n512/b1` | 105.123 ± 0.286206 (W 0.104657) | 105.179 ± 0.388264 (W 0.136146) | 116.107 ± 0.18236 (W 0.105742) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.61983 ± 0.00414367 (W 0.00376871) | 2.62249 ± 0.00326807 (W 0.00300121) | 1.15732 ± 0.000340515 (W 0.00273644) | · | 🔴 faer-fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2797 ± 0.020195 (W 0.0187361) | 12.283 ± 0.0399832 (W 0.00926825) | 6.83599 ± 0.0180335 (W 0.00810161) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.3117 ± 0.152331 (W 0.0665468) | 65.3135 ± 0.156178 (W 0.0204573) | 47.1826 ± 0.378711 (W 0.0382937) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004929 ± 0.000442912 (W 3.49042e-05) | 0.00498 ± 0.000471 (W 3.22366e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013926 ± 0.00016563 (W 5.47723e-05) | 0.013986 ± 0.000193521 (W 3.83406e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.047248 ± 0.00118904 (W 0.000171296) | 0.047629 ± 0.00106378 (W 0.000362728) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.082444 ± 0.00130355 (W 0.00277082) | 0.098635 ± 0.000981684 (W 0.00275752) | 0.092783 ± 0.000964211 (W 0.00165148) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.338083 ± 0.00570359 (W 0.0239215) | 0.361399 ± 0.0263355 (W 0.0217405) | 0.238134 ± 0.00260177 (W 0.00328771) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.13327 ± 0.0129987 (W 0.0237329) | 1.22369 ± 0.0119196 (W 0.039547) | 1.41516 ± 0.0176843 (W 0.0102884) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.28619 ± 0.0299159 (W 0.022987) | 2.33691 ± 0.00925503 (W 0.0362922) | 1.05414 ± 0.00350638 (W 0.00321642) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.93668 ± 0.0165564 (W 0.0244943) | 6.93688 ± 0.0426228 (W 0.0257988) | 4.68613 ± 0.0198167 (W 0.00911) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 25.6606 ± 0.167727 (W 0.0732348) | 25.6885 ± 0.124864 (W 0.0463159) | 21.2098 ± 0.0338523 (W 0.0392996) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290381 ± 0.00097871 (W 0.00240323) | 0.292029 ± 0.000417133 (W 0.00289282) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61893 ± 0.0172274 (W 0.00554414) | 2.61431 ± 0.0198664 (W 0.0118482) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.0059 ± 0.159226 (W 0.0905422) | 16.9487 ± 0.0434082 (W 0.0355161) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.093706 ± 0.00023639 (W 0.00048208) | 0.083426 ± 0.000133167 (W 0.000439006) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.094999 ± 0.000661354 (W 0.00269113) | 0.08506 ± 0.000871079 (W 0.000655548) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.522989 ± 0.00297302 (W 0.00569893) | 0.519489 ± 0.00193862 (W 0.00349923) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.529678 ± 0.00264696 (W 0.00439969) | 0.525608 ± 0.00133027 (W 0.00170564) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.09685 ± 0.00869343 (W 0.0110993) | 4.08893 ± 0.00656039 (W 0.00931675) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.10183 ± 0.0311337 (W 0.0097305) | 4.10931 ± 0.0215994 (W 0.00832705) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146335 ± 0.00124885 (W 0.000572624) | 0.216097 ± 0.00560514 (W 0.00671562) | 0.133028 ± 0.00053347 (W 0.00180808) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.703683 ± 0.121937 (W 0.00287679) | 0.831481 ± 0.127914 (W 0.0186191) | 0.324638 ± 0.0024298 (W 0.00175973) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.26461 ± 0.0910315 (W 0.0633364) | 4.57237 ± 0.0118941 (W 0.0411271) | 1.6335 ± 0.0140434 (W 0.00690122) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 2.61× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.564868 ± 0.0197032 (W 0.0437617) | 1.3837 ± 0.0338001 (W 0.0285959) | 0.455175 ± 0.0216379 (W 0.00239895) | 🔵 faer-fork 2.45× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n256/b1` | 1.86213 ± 0.0195502 (W 0.0230805) | 3.52647 ± 0.0532844 (W 0.0834583) | 2.19449 ± 0.0180782 (W 0.00662007) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.50462 ± 1.00742 (W 0.133197) | 13.141 ± 0.982776 (W 0.121187) | 13.0603 ± 0.0600451 (W 0.0438786) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.355513 ± 0.0192604 (W 0.0113063) | 1.1543 ± 0.0324557 (W 0.0129068) | 0.181801 ± 0.00226164 (W 0.00176098) | 🔵 faer-fork 3.25× faster than `faer-upstream` | 🔴 faer-fork 1.96× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.30946 ± 0.00706348 (W 0.0273265) | 2.92578 ± 0.0511908 (W 0.0530275) | 0.621905 ± 0.00231494 (W 0.00324232) | 🔵 faer-fork 2.23× faster than `faer-upstream` | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.70979 ± 0.0153686 (W 0.0317293) | 8.12296 ± 0.0136913 (W 0.06179) | 3.66904 ± 0.00244846 (W 0.00655639) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111549 ± 0.00144929 (W 0.00133794) | 0.173845 ± 0.00417946 (W 0.00902853) | 0.131927 ± 0.000550682 (W 0.00182603) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.673586 ± 0.00428766 (W 0.0068771) | 0.758485 ± 0.00442811 (W 0.019348) | 0.314009 ± 0.00122793 (W 0.00277467) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.20004 ± 0.0708245 (W 0.0425045) | 4.43865 ± 0.03775 (W 0.0810541) | 1.61716 ± 0.00573066 (W 0.00328652) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.60× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.0082 ± 0.00556192 (W 0.0193198) | 3.01604 ± 0.00387819 (W 0.0234726) | 2.60092 ± 0.00270138 (W 0.0106792) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6334 ± 0.0430695 (W 0.0995832) | 13.6109 ± 0.0155688 (W 0.0697443) | 12.3781 ± 0.071956 (W 0.0222609) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.6164 ± 0.226193 (W 0.26643) | 60.8435 ± 0.354168 (W 0.380845) | 56.6655 ± 0.321447 (W 0.0527548) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.15603 ± 0.00588297 (W 0.00562593) | 2.15377 ± 0.00703014 (W 0.0041447) | 1.13852 ± 0.0124377 (W 0.00374498) | · | 🔴 faer-fork 1.89× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6906 ± 0.0236826 (W 0.0393322) | 10.6595 ± 0.0201683 (W 0.0252048) | 6.11638 ± 0.0688594 (W 0.00633961) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.0615 ± 0.257861 (W 0.227899) | 47.1775 ± 0.260774 (W 0.376554) | 25.5316 ± 0.0502879 (W 0.0130061) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004608 ± 0.000257489 (W 1.89526e-05) | 0.004619 ± 0.000237193 (W 2.32873e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.010971 ± 0.00113929 (W 0.000215891) | 0.010931 ± 0.00110169 (W 5.39185e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.040476 ± 0.00583647 (W 0.000725) | 0.040316 ± 0.00234732 (W 0.000323531) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.082875 ± 0.00327357 (W 0.00362955) | 0.097322 ± 0.00460481 (W 0.00386647) | 0.090861 ± 0.00064579 (W 0.00154738) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.334473 ± 0.00695955 (W 0.0149955) | 0.392102 ± 0.0091006 (W 0.0154088) | 0.194523 ± 0.00345981 (W 0.00378192) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 1.08596 ± 0.0271061 (W 0.032666) | 1.18579 ± 0.0145696 (W 0.0236764) | 0.977315 ± 0.0176955 (W 0.01089) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.39497 ± 0.0277663 (W 0.0249099) | 2.34374 ± 0.0103544 (W 0.0252519) | 0.989906 ± 0.002972 (W 0.00288198) | · | 🔴 faer-fork 2.42× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.82772 ± 0.0540092 (W 0.0263147) | 7.03731 ± 0.0434362 (W 0.0389372) | 3.9064 ± 0.00595951 (W 0.00957845) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.8157 ± 0.0682456 (W 0.0584978) | 24.5084 ± 0.072555 (W 0.0961954) | 14.8445 ± 0.0200866 (W 0.0282143) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.28969 ± 0.00148391 (W 0.00140287) | 0.290441 ± 0.00151664 (W 0.0022423) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61634 ± 0.00618373 (W 0.00424633) | 2.62209 ± 0.00770467 (W 0.00779681) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.723 ± 0.0759756 (W 0.104096) | 16.7858 ± 0.0684782 (W 0.0878582) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.068709 ± 0.00184408 (W 0.000703185) | 0.102983 ± 0.00146022 (W 0.00180778) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.068378 ± 0.000369942 (W 0.000673096) | 0.103785 ± 0.00187326 (W 0.00271405) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.294803 ± 0.00103393 (W 0.00141115) | 0.389711 ± 0.0133843 (W 0.0202981) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.302778 ± 0.0046915 (W 0.00179892) | 0.389319 ± 0.018514 (W 0.00872375) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.22045 ± 0.0298607 (W 0.0112022) | 2.62616 ± 0.182605 (W 0.341629) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.23531 ± 0.00784069 (W 0.00975719) | 2.58188 ± 0.19402 (W 0.111955) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.143929 ± 0.0170321 (W 0.00161397) | 0.21976 ± 0.0196337 (W 0.00381858) | 0.132317 ± 0.000751322 (W 0.000550314) | 🔵 faer-fork 1.53× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.709674 ± 0.117793 (W 0.00381474) | 0.922863 ± 0.129342 (W 0.0257457) | 0.317883 ± 0.00484212 (W 0.00329226) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 2.23× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.13693 ± 0.0457826 (W 0.0128356) | 4.76933 ± 0.028775 (W 0.096578) | 1.23536 ± 0.00430932 (W 0.00725655) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 3.35× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.561627 ± 0.0125203 (W 0.0160975) | 1.86916 ± 0.0137604 (W 0.0284442) | 0.42066 ± 0.001326 (W 0.00694075) | 🔵 faer-fork 3.33× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.68329 ± 0.00522946 (W 0.00876593) | 4.59821 ± 0.0449744 (W 0.0433437) | 2.02797 ± 0.0381251 (W 0.00662254) | 🔵 faer-fork 2.73× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 8.24185 ± 0.0185668 (W 0.0613875) | 14.6424 ± 0.177236 (W 0.161393) | 10.2872 ± 0.0162481 (W 0.0209729) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.321574 ± 0.0108574 (W 0.00583482) | 1.57158 ± 0.00866983 (W 0.0252709) | 0.145351 ± 0.00156201 (W 0.000837386) | 🔵 faer-fork 4.89× faster than `faer-upstream` | 🔴 faer-fork 2.21× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.27596 ± 0.00172603 (W 0.0128106) | 4.02526 ± 0.0185797 (W 0.0459274) | 0.543484 ± 0.00447748 (W 0.00317192) | 🔵 faer-fork 3.15× faster than `faer-upstream` | 🔴 faer-fork 2.35× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.46504 ± 0.0188309 (W 0.0160819) | 10.0239 ± 0.0245159 (W 0.0752082) | 2.19892 ± 0.00198804 (W 0.00314586) | 🔵 faer-fork 2.24× faster than `faer-upstream` | 🔴 faer-fork 2.03× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111178 ± 0.000875214 (W 0.000246233) | 0.188433 ± 0.00287736 (W 0.00288734) | 0.131617 ± 0.000520456 (W 0.00167205) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.674908 ± 0.0039855 (W 0.00245773) | 0.812432 ± 0.00336566 (W 0.0330346) | 0.302194 ± 0.00213804 (W 0.00242181) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 2.23× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.08093 ± 0.0102182 (W 0.0368145) | 4.52036 ± 0.036332 (W 0.104641) | 1.20036 ± 0.0132214 (W 0.00569304) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 3.40× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.03318 ± 0.0068531 (W 0.0154247) | 3.08778 ± 0.011347 (W 0.0273413) | 2.47155 ± 0.008273 (W 0.00625793) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3481 ± 0.0555423 (W 0.0377786) | 13.639 ± 0.0407601 (W 0.0603897) | 11.3683 ± 0.0382778 (W 0.0179047) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.7659 ± 0.0617949 (W 0.474483) | 59.9085 ± 0.038186 (W 0.432999) | 47.8927 ± 0.251384 (W 0.067203) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.19949 ± 0.0345503 (W 0.0137475) | 2.15757 ± 0.00564925 (W 0.0035658) | 1.11593 ± 0.00247551 (W 0.00329477) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.833 ± 0.0216414 (W 0.0286198) | 10.8123 ± 0.014916 (W 0.0283489) | 5.97781 ± 0.019929 (W 0.0159997) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.5464 ± 0.176767 (W 0.415906) | 48.6357 ± 0.128535 (W 0.180379) | 22.4367 ± 0.0341224 (W 0.0230002) | · | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004689 ± 0.000456009 (W 3.70135e-05) | 0.004248 ± 0.00069154 (W 4.05006e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011 ± 0.000226297 (W 0.000207944) | 0.01096 ± 0.000385077 (W 2.63306e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.045115 ± 0.00507165 (W 0.00296085) | 0.043611 ± 0.00151369 (W 0.000845913) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188343 ± 0.000694143 (W 0.00204252) | 0.188655 ± 0.00433817 (W 0.00126739) | 0.475356 ± 0.00184886 (W 0.0025533) | · | 🔵 faer-fork 2.52× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.24106 ± 0.0121182 (W 0.00247274) | 1.22253 ± 0.00324764 (W 0.00321091) | 1.85337 ± 0.019813 (W 0.00489873) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.90674 ± 0.0146394 (W 0.0113476) | 7.91221 ± 0.129447 (W 0.0134148) | 11.3928 ± 0.0187712 (W 0.0266818) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.27442 ± 0.010824 (W 0.00364446) | 3.28088 ± 0.00439448 (W 0.00258979) | 4.42076 ± 0.00275119 (W 0.00698707) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.4215 ± 0.0487551 (W 0.00777115) | 17.4432 ± 0.0374993 (W 0.0128283) | 26.4578 ± 0.0313913 (W 0.0376645) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.729 ± 0.0975268 (W 0.0667307) | 105.687 ± 0.272315 (W 0.103927) | 171.289 ± 0.378209 (W 0.124847) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.773149 ± 0.00574802 (W 0.00475436) | 0.784166 ± 0.00371721 (W 0.00821989) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.91061 ± 0.0103132 (W 0.00730683) | 6.07277 ± 0.0165785 (W 0.0115693) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.5169 ± 0.189784 (W 0.0938402) | 40.7734 ± 0.196756 (W 0.0405766) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.04723 ± 0.00489183 (W 0.000977399) | 1.05194 ± 0.00372592 (W 0.00154353) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05163 ± 0.00461452 (W 0.00183322) | 1.0543 ± 0.0025161 (W 0.00329941) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.48942 ± 0.0116232 (W 0.0068268) | 7.50143 ± 0.00582835 (W 0.00510648) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52165 ± 0.0253484 (W 0.0158348) | 7.49824 ± 0.0185122 (W 0.00993449) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.7794 ± 0.0483026 (W 0.033172) | 56.8806 ± 0.102498 (W 0.0630686) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.9871 ± 0.0238341 (W 0.0905631) | 56.9693 ± 0.0367031 (W 0.0772907) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.322782 ± 0.00126846 (W 0.00194652) | 0.327596 ± 0.000631157 (W 0.00188074) | 0.503072 ± 0.00151442 (W 0.00233185) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.10954 ± 0.00295421 (W 0.00216422) | 2.20505 ± 0.00649152 (W 0.00196339) | 3.32313 ± 0.00989277 (W 0.00982345) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 14.5902 ± 0.033441 (W 0.0308078) | 14.8516 ± 0.00476941 (W 0.015731) | 21.0923 ± 0.03005 (W 0.0391325) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.57252 ± 0.00363817 (W 0.00271013) | 1.5838 ± 0.0049542 (W 0.00398599) | 1.99528 ± 0.00233015 (W 0.00259958) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.1579 ± 0.0023692 (W 0.00395333) | 10.3138 ± 0.0640195 (W 0.0121612) | 12.3637 ± 0.012779 (W 0.0181051) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.6806 ± 0.041266 (W 0.0599038) | 69.8746 ± 0.0442766 (W 0.0181432) | 80.7629 ± 0.0579696 (W 0.0296655) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.805732 ± 0.00793 (W 0.00191432) | 1.06614 ± 0.00105718 (W 0.00146414) | 0.956029 ± 0.00205902 (W 0.00145873) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.8155 ± 0.017299 (W 0.0050915) | 6.53236 ± 0.0631848 (W 0.00834411) | 5.67268 ± 0.00549166 (W 0.00927221) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.7451 ± 0.134001 (W 0.0220843) | 37.581 ± 0.262942 (W 0.0292533) | 39.1068 ± 0.0356973 (W 0.0636573) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.318419 ± 0.0019542 (W 0.00158213) | 0.324979 ± 8.87543e-05 (W 0.00178919) | 0.489641 ± 0.00207727 (W 0.00307805) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.04827 ± 0.00255361 (W 0.00487724) | 2.14416 ± 0.00683016 (W 0.00305167) | 2.82364 ± 0.00424992 (W 0.00702337) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.683 ± 0.0415256 (W 0.0222123) | 14.8439 ± 0.0320374 (W 0.0385241) | 18.8033 ± 0.043243 (W 0.0409622) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.74594 ± 0.0128176 (W 0.00800182) | 5.74343 ± 0.0105581 (W 0.0087307) | 7.05176 ± 0.0283151 (W 0.00610567) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.1436 ± 0.219103 (W 0.0251326) | 34.1473 ± 0.275845 (W 0.0389503) | 43.7207 ± 0.215873 (W 0.0237927) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 210.553 ± 0.153076 (W 0.605007) | 210.996 ± 0.45721 (W 0.601418) | 277.68 ± 2.154 (W 0.674228) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.47111 ± 0.00797109 (W 0.00814085) | 3.46831 ± 0.00659853 (W 0.00551434) | 2.76223 ± 0.00567468 (W 0.00331161) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.3043 ± 0.0262405 (W 0.0488778) | 19.3668 ± 0.0863288 (W 0.0373956) | 18.0953 ± 0.0541426 (W 0.0210714) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 111.093 ± 0.765006 (W 0.385093) | 110.736 ± 0.942655 (W 0.433054) | 123.464 ± 0.606228 (W 0.398059) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007544 ± 0.00014526 (W 2.77489e-05) | 0.007604 ± 2.88675e-05 (W 3.50599e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023735 ± 0.000230565 (W 8.27647e-05) | 0.023735 ± 0.000151064 (W 6.74107e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.086361 ± 0.00034051 (W 0.000319153) | 0.086373 ± 0.000498069 (W 0.000288592) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.190047 ± 0.000801052 (W 0.00183705) | 0.202238 ± 0.00500835 (W 0.00535306) | 0.476413 ± 0.00110682 (W 0.00341009) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 2.51× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.835167 ± 0.00798225 (W 0.0109145) | 0.893316 ± 0.0028899 (W 0.0143493) | 0.798375 ± 0.00643772 (W 0.00647155) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · |  |
| `cholesky/n512/b1` | 3.36802 ± 0.0147181 (W 0.0180061) | 3.42095 ± 0.0104398 (W 0.0196258) | 3.66393 ± 0.00577502 (W 0.0119418) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.95385 ± 0.0363883 (W 0.0115564) | 2.96962 ± 0.00575 (W 0.032854) | 2.04966 ± 0.00105813 (W 0.00358542) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.4225 ± 0.0181113 (W 0.0575003) | 11.4596 ± 0.0603028 (W 0.0268328) | 10.166 ± 0.015399 (W 0.0131479) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.8196 ± 0.0711291 (W 0.0926057) | 46.6714 ± 0.0375043 (W 0.132771) | 53.1612 ± 0.12562 (W 0.0334326) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.772711 ± 0.00438427 (W 0.00715015) | 0.783672 ± 0.032848 (W 0.00333631) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.91063 ± 0.0258957 (W 0.0110023) | 6.07486 ± 0.121577 (W 0.0166527) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.9689 ± 0.0396869 (W 0.0953944) | 27.3025 ± 0.340872 (W 0.0621156) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.28752 ± 0.0019848 (W 0.00170899) | 0.291153 ± 0.00169504 (W 0.00156122) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.288921 ± 0.000801235 (W 0.00237293) | 0.290746 ± 0.00161062 (W 0.00134755) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93669 ± 0.0075269 (W 0.00188163) | 1.93588 ± 0.0119748 (W 0.004637) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94749 ± 0.00709343 (W 0.00420678) | 1.92945 ± 0.0100039 (W 0.00531328) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7183 ± 0.0558696 (W 0.0161121) | 14.6312 ± 0.0266809 (W 0.0304782) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8256 ± 0.0621622 (W 0.0155575) | 14.6915 ± 0.0288149 (W 0.0123284) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.322351 ± 0.000456215 (W 0.00201105) | 0.341677 ± 0.00597304 (W 0.00407084) | 0.484056 ± 0.00149258 (W 0.00254002) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.55099 ± 0.0181749 (W 0.0104938) | 1.6791 ± 0.0045185 (W 0.0107967) | 1.01488 ± 0.00438005 (W 0.00295441) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 7.25559 ± 0.0268527 (W 0.0314641) | 7.47013 ± 0.0125101 (W 0.0349005) | 6.14779 ± 0.0212415 (W 0.00735756) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.02604 ± 0.00659779 (W 0.0115505) | 1.89896 ± 0.00616107 (W 0.0233731) | 1.04251 ± 0.00513621 (W 0.00518423) | 🔵 faer-fork 1.85× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.59682 ± 0.0881425 (W 0.090183) | 6.22608 ± 0.0183322 (W 0.0619629) | 4.80111 ± 0.0142197 (W 0.0128202) | 🔵 faer-fork 1.35× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 23.4295 ± 0.0894016 (W 0.0694509) | 26.7954 ± 0.0434363 (W 0.075814) | 28.6223 ± 0.0889535 (W 0.0368638) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.616559 ± 0.0130373 (W 0.00878234) | 1.75571 ± 0.00938824 (W 0.0208798) | 0.455015 ± 0.00120791 (W 0.00132179) | 🔵 faer-fork 2.85× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.90246 ± 0.0212493 (W 0.0525399) | 7.34208 ± 0.0723668 (W 0.0459738) | 1.63487 ± 0.00243415 (W 0.0038686) | 🔵 faer-fork 2.53× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.0013 ± 0.0560348 (W 0.0583888) | 26.743 ± 0.285052 (W 0.0678501) | 11.453 ± 0.0153605 (W 0.0134882) | 🔵 faer-fork 2.23× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.319125 ± 0.0024245 (W 0.00220782) | 0.332452 ± 0.00359397 (W 0.00514304) | 0.46962 ± 0.00082836 (W 0.00204031) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.43236 ± 0.00904429 (W 0.0126508) | 1.54221 ± 0.0104052 (W 0.0159712) | 0.895292 ± 0.00257433 (W 0.003725) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 7.1833 ± 0.0428667 (W 0.0152478) | 7.28826 ± 0.0257186 (W 0.0357891) | 5.65467 ± 0.0136668 (W 0.0119141) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.36439 ± 0.0146161 (W 0.0275215) | 4.32372 ± 0.0225592 (W 0.0195985) | 4.16297 ± 0.0120084 (W 0.00908124) | · | · |  |
| `svd_thin/n256/b1` | 22.4793 ± 0.0303857 (W 0.262314) | 22.5493 ± 0.0214745 (W 0.0506891) | 21.2076 ± 0.0320455 (W 0.0214158) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.8337 ± 0.360587 (W 0.301028) | 95.0615 ± 0.308686 (W 0.433104) | 114.617 ± 0.455388 (W 0.0778891) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.06408 ± 0.0332144 (W 0.00561718) | 3.05186 ± 0.0104324 (W 0.0071356) | 2.04691 ± 0.0110268 (W 0.00273254) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.0781 ± 0.0374595 (W 0.0676417) | 17.0513 ± 0.178531 (W 0.0529398) | 11.074 ± 0.0144789 (W 0.013668) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.0019 ± 0.031922 (W 0.159819) | 64.9759 ± 0.0831014 (W 0.204099) | 55.9865 ± 0.312186 (W 0.109868) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007584 ± 5.03322e-05 (W 2.77489e-05) | 0.007555 ± 3.19427e-05 (W 5.72031e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023304 ± 0.000125831 (W 3.60444e-05) | 0.023394 ± 0.000165802 (W 6.96649e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.067958 ± 0.00294084 (W 0.00143203) | 0.068427 ± 0.00295557 (W 0.000966248) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.194354 ± 0.00226931 (W 0.00163846) | 0.211517 ± 0.00043998 (W 0.00369687) | 0.47923 ± 0.00464321 (W 0.00424241) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 2.47× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.837329 ± 0.012661 (W 0.0161913) | 0.882533 ± 0.0127971 (W 0.0156182) | 0.659438 ± 0.001243 (W 0.00243323) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.79405 ± 0.00259241 (W 0.0136602) | 2.87056 ± 0.0100922 (W 0.0159798) | 2.26903 ± 0.0488045 (W 0.0154454) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.93075 ± 0.0182263 (W 0.0292969) | 3.02577 ± 0.00584315 (W 0.0167771) | 1.69995 ± 0.000886905 (W 0.00359971) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.8343 ± 0.00982634 (W 0.030012) | 11.1612 ± 0.0612674 (W 0.0382623) | 8.01553 ± 0.0115595 (W 0.0122199) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 39.2587 ± 0.185654 (W 0.115047) | 40.0642 ± 0.212372 (W 0.235424) | 36.9248 ± 0.022295 (W 0.0318018) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.77233 ± 0.00138146 (W 0.0058054) | 0.771028 ± 0.00321533 (W 0.00441631) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.88316 ± 0.0188777 (W 0.00972626) | 6.0118 ± 0.0363961 (W 0.019607) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.3287 ± 0.0610226 (W 0.0436388) | 25.5373 ± 0.100393 (W 0.106862) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.183855 ± 0.000411481 (W 0.00239689) | 0.271359 ± 0.00108908 (W 0.00277202) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.182983 ± 0.000772134 (W 0.00116757) | 0.271556 ± 0.000497231 (W 0.00177721) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01385 ± 0.00569054 (W 0.0039003) | 1.28706 ± 0.0122595 (W 0.0604437) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.00821 ± 0.0020159 (W 0.00306946) | 1.2788 ± 0.00878377 (W 0.0125086) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.09651 ± 0.0992704 (W 0.048385) | 8.69953 ± 0.427848 (W 0.456098) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.09791 ± 0.0448591 (W 0.0355401) | 8.67682 ± 0.267218 (W 0.517706) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.322575 ± 0.00171308 (W 0.00257927) | 0.365385 ± 0.00145976 (W 0.00466219) | 0.487569 ± 0.00705763 (W 0.0018274) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.50267 ± 0.0168452 (W 0.0214343) | 1.68659 ± 0.0196989 (W 0.016038) | 0.694335 ± 0.0108206 (W 0.00443401) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.2086 ± 0.0376151 (W 0.0278212) | 6.47342 ± 0.0225381 (W 0.0322815) | 3.59395 ± 0.00957315 (W 0.00853905) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.982494 ± 0.00600913 (W 0.012938) | 2.44966 ± 0.0101817 (W 0.035175) | 0.780071 ± 0.00159006 (W 0.002062) | 🔵 faer-fork 2.49× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.46418 ± 0.0206287 (W 0.0247566) | 6.91035 ± 0.0619638 (W 0.0445312) | 3.84737 ± 0.00528828 (W 0.00600165) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 15.9728 ± 0.0334255 (W 0.0530216) | 23.0852 ± 0.152401 (W 0.163841) | 16.0627 ± 0.0322253 (W 0.0248618) | 🔵 faer-fork 1.45× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.614032 ± 0.00444206 (W 0.0035734) | 2.31101 ± 0.0254583 (W 0.02195) | 0.322654 ± 0.00105803 (W 0.00175327) | 🔵 faer-fork 3.76× faster than `faer-upstream` | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.41136 ± 0.00826266 (W 0.00990517) | 8.52207 ± 0.0725788 (W 0.0833837) | 1.62626 ± 0.00422546 (W 0.00171642) | 🔵 faer-fork 3.53× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.26698 ± 0.0314725 (W 0.0316282) | 27.5407 ± 0.00883151 (W 0.102354) | 5.81486 ± 0.0183069 (W 0.0129351) | 🔵 faer-fork 2.97× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.318338 ± 0.00109597 (W 0.00193261) | 0.35783 ± 0.00292111 (W 0.00571027) | 0.472661 ± 0.00691511 (W 0.00232698) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.38632 ± 0.00611224 (W 0.0147506) | 1.53791 ± 0.00638916 (W 0.0228354) | 0.665839 ± 0.00352944 (W 0.00320796) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.11478 ± 0.0360426 (W 0.0414351) | 6.30559 ± 0.0485734 (W 0.0354202) | 3.46672 ± 0.0125632 (W 0.00550116) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.25165 ± 0.0248515 (W 0.0169391) | 4.49841 ± 0.0122805 (W 0.0282742) | 3.64753 ± 0.00615343 (W 0.00839879) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.4789 ± 0.0240521 (W 0.0367959) | 22.0136 ± 0.0377724 (W 0.0572798) | 17.1866 ± 0.0427821 (W 0.0281404) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.1861 ± 0.101658 (W 0.202646) | 82.0976 ± 0.308271 (W 0.322859) | 83.9776 ± 0.937766 (W 0.0434869) | · | · |  |
| `svd_values/n128/b1` | 3.09231 ± 0.0077592 (W 0.007335) | 3.08032 ± 0.0252988 (W 0.0107688) | 1.91762 ± 0.0128243 (W 0.00571128) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.1298 ± 0.0765105 (W 0.0365544) | 17.1556 ± 0.0831832 (W 0.0284442) | 9.67274 ± 0.0138575 (W 0.0210145) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 61.3893 ± 0.187537 (W 0.30056) | 61.194 ± 0.0673881 (W 0.302857) | 43.035 ± 0.194257 (W 0.0267215) | · | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007604 ± 4.04145e-05 (W 2.30217e-05) | 0.007584 ± 1.52753e-05 (W 2.03765e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023524 ± 0.000211975 (W 8.31282e-05) | 0.023374 ± 0.000287286 (W 7.90076e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.077675 ± 0.00428078 (W 0.00297845) | 0.071253 ± 0.00127549 (W 0.00107776) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174866 ± 0.000444062 (W 0.00149315) | 0.175287 ± 0.00423409 (W 0.00140721) | 0.407948 ± 0.0028612 (W 0.00318746) | · | 🔵 faer-fork 2.33× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13197 ± 0.00233957 (W 0.00116295) | 1.13342 ± 0.00223664 (W 0.00140024) | 1.6022 ± 0.00167659 (W 0.00416326) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.54918 ± 0.00933146 (W 0.00769968) | 7.52839 ± 0.0220874 (W 0.0095569) | 12.0699 ± 0.0279595 (W 0.0157051) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.26478 ± 0.00546252 (W 0.00279649) | 3.26776 ± 0.00103865 (W 0.00393109) | 4.36107 ± 0.00857183 (W 0.00551836) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.373 ± 0.0305709 (W 0.00999449) | 17.3819 ± 0.0421524 (W 0.0172937) | 26.1971 ± 0.0487852 (W 0.0814727) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.489 ± 0.149932 (W 0.0404991) | 105.434 ± 0.252646 (W 0.354131) | 170.024 ± 0.225545 (W 0.361363) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.748248 ± 0.00395693 (W 0.00347584) | 0.747023 ± 0.00335405 (W 0.00731781) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.77273 ± 0.0109764 (W 0.00756989) | 5.76959 ± 0.00773697 (W 0.00766069) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 39.8963 ± 0.198498 (W 0.0352596) | 39.8865 ± 0.177175 (W 0.030886) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03537 ± 0.00193515 (W 0.00112156) | 1.0372 ± 0.00372649 (W 0.00126282) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.03686 ± 0.00396528 (W 0.00172067) | 1.04104 ± 0.00210664 (W 0.00106384) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.39739 ± 0.00692081 (W 0.0100947) | 7.41239 ± 0.017023 (W 0.00838282) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.41321 ± 0.0170959 (W 0.00742583) | 7.40484 ± 0.0125497 (W 0.00738711) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8126 ± 0.0254096 (W 0.44544) | 56.7491 ± 0.0681523 (W 0.0556424) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7388 ± 0.0426662 (W 0.0477405) | 56.6174 ± 0.0367306 (W 0.0421555) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295797 ± 0.000463792 (W 0.00150118) | 0.295734 ± 0.00148123 (W 0.00232139) | 0.457963 ± 0.00172084 (W 0.00234682) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.00203 ± 0.00937377 (W 0.00200676) | 1.99847 ± 0.00565205 (W 0.00186792) | 3.1603 ± 0.00240063 (W 0.0075626) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 13.8212 ± 0.011877 (W 0.0104625) | 13.8345 ± 0.0150822 (W 0.0129534) | 19.7666 ± 0.00732261 (W 0.0341673) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.54351 ± 0.00265917 (W 0.00289476) | 1.55012 ± 0.00174435 (W 0.00227242) | 1.97779 ± 0.00229355 (W 0.00376341) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.052 ± 0.0180797 (W 0.00497736) | 10.1037 ± 0.0106207 (W 0.0107388) | 12.3516 ± 0.0311604 (W 0.0101434) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 68.78 ± 0.098962 (W 0.0340062) | 68.8952 ± 0.328532 (W 0.0428318) | 80.0044 ± 0.104909 (W 0.0438718) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.742001 ± 0.000951984 (W 0.00205945) | 0.751248 ± 0.00136376 (W 0.00192047) | 0.909454 ± 0.000748541 (W 0.00349245) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.45622 ± 0.0111229 (W 0.00581015) | 4.49991 ± 0.00606227 (W 0.004189) | 5.49767 ± 0.0191133 (W 0.0143804) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.9284 ± 0.0731873 (W 0.0237646) | 29.0238 ± 0.0175628 (W 0.0149234) | 38.0181 ± 0.0451819 (W 0.0299301) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.291839 ± 0.000957118 (W 0.00190045) | 0.291406 ± 0.000803764 (W 0.0018657) | 0.444226 ± 0.000434887 (W 0.0023759) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93338 ± 0.00284209 (W 0.00198574) | 1.93248 ± 0.0033209 (W 0.00302496) | 2.66617 ± 0.0010716 (W 0.00853054) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 13.8682 ± 0.0165746 (W 0.0215175) | 13.8664 ± 0.0044632 (W 0.0431798) | 18.0166 ± 0.0450374 (W 0.0286155) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.71493 ± 0.0114438 (W 0.00685025) | 5.70597 ± 0.0101106 (W 0.00821623) | 6.95813 ± 0.0161659 (W 0.00609224) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.9068 ± 0.238228 (W 0.0503654) | 33.8753 ± 0.233445 (W 0.0423056) | 43.0076 ± 0.196188 (W 0.0937601) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 209.592 ± 0.887394 (W 0.168191) | 209.439 ± 0.197967 (W 0.295284) | 304.731 ± 0.761264 (W 0.550817) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.4465 ± 0.00504494 (W 0.00446424) | 3.45175 ± 0.011282 (W 0.0153444) | 2.7104 ± 0.00740772 (W 0.00395392) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.0101 ± 0.0328103 (W 0.0303965) | 19.0147 ± 0.063197 (W 0.0454042) | 17.9513 ± 0.0331933 (W 0.014807) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 109.925 ± 0.406465 (W 0.119326) | 109.636 ± 0.38483 (W 0.10201) | 149.228 ± 0.94901 (W 0.129902) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007975 ± 0.000669957 (W 4.3359e-05) | 0.008095 ± 0.000651615 (W 3.90807e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022783 ± 0.00122327 (W 0.000184435) | 0.022202 ± 0.000310877 (W 0.000191257) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.087293 ± 0.00158055 (W 0.00189735) | 0.088605 ± 0.00212754 (W 0.00129032) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176941 ± 0.0016521 (W 0.00438732) | 0.190316 ± 0.0017423 (W 0.00454489) | 0.408742 ± 0.00052057 (W 0.00246688) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 2.31× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.754954 ± 0.004843 (W 0.00866074) | 0.785275 ± 0.00473456 (W 0.0127335) | 0.594859 ± 0.00473994 (W 0.010296) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.99483 ± 0.0253516 (W 0.0277726) | 3.04849 ± 0.0144448 (W 0.0219532) | 3.22298 ± 0.0105878 (W 0.00849799) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.96901 ± 0.0175486 (W 0.0258899) | 2.95084 ± 0.022255 (W 0.0326765) | 2.00941 ± 0.00695266 (W 0.00436878) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.392 ± 0.0344056 (W 0.0416532) | 11.4141 ± 0.034639 (W 0.0493291) | 9.99897 ± 0.00645543 (W 0.0132449) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.3471 ± 0.136751 (W 0.0916093) | 46.387 ± 0.0523187 (W 0.0670016) | 52.5965 ± 0.00657246 (W 0.0271568) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.745256 ± 0.00386121 (W 0.00595621) | 0.751703 ± 0.0350566 (W 0.00502677) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.75204 ± 0.0196884 (W 0.0174937) | 5.77476 ± 0.108977 (W 0.0102558) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.2111 ± 0.0479402 (W 0.0755226) | 26.221 ± 0.338509 (W 0.0692118) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.296503 ± 0.00213628 (W 0.00452258) | 0.28848 ± 0.00134874 (W 0.0011349) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.296585 ± 0.00138452 (W 0.00275582) | 0.290033 ± 0.00107929 (W 0.00111043) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91861 ± 0.0038356 (W 0.00609434) | 1.92456 ± 0.00336968 (W 0.00330801) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92583 ± 0.010203 (W 0.00617978) | 1.92297 ± 0.0175261 (W 0.00250736) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7873 ± 0.00803198 (W 0.0179108) | 14.7261 ± 0.0412742 (W 0.0176164) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8086 ± 0.0335186 (W 0.0205063) | 14.7522 ± 0.0125749 (W 0.0156139) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296457 ± 0.000362133 (W 0.00174069) | 0.30973 ± 0.00483605 (W 0.00429015) | 0.459203 ± 0.0016615 (W 0.00229007) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.44327 ± 0.00640891 (W 0.0211833) | 1.48511 ± 0.00660471 (W 0.0209778) | 0.975603 ± 0.00357293 (W 0.0025428) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.50018 ± 0.0188769 (W 0.0333451) | 6.56706 ± 0.0125067 (W 0.0259366) | 5.83008 ± 0.0278155 (W 0.00974363) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.995456 ± 0.00534343 (W 0.00552465) | 1.88712 ± 0.0163721 (W 0.0185228) | 1.05584 ± 0.00454777 (W 0.00450331) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 4.42727 ± 0.0250715 (W 0.033974) | 5.98409 ± 0.0579811 (W 0.0669942) | 5.05839 ± 0.0312037 (W 0.00653472) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 22.509 ± 0.130189 (W 0.0824886) | 25.9387 ± 0.0606896 (W 0.0777834) | 29.1845 ± 0.0703874 (W 0.0370112) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.545602 ± 0.00384158 (W 0.00303305) | 1.36136 ± 0.0127805 (W 0.0200758) | 0.437542 ± 0.00146085 (W 0.00185164) | 🔵 faer-fork 2.50× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.71018 ± 0.0293268 (W 0.0350042) | 4.23442 ± 0.0226859 (W 0.0249917) | 1.57752 ± 0.000317849 (W 0.00386345) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.2595 ± 0.137005 (W 0.094166) | 14.6111 ± 0.0359865 (W 0.0444616) | 11.0408 ± 0.13701 (W 0.0132409) | 🔵 faer-fork 1.30× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.292265 ± 0.001844 (W 0.00201294) | 0.303526 ± 0.00527182 (W 0.0047885) | 0.44524 ± 0.00109567 (W 0.00256405) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.31591 ± 0.00969277 (W 0.0110287) | 1.33473 ± 0.00471366 (W 0.022471) | 0.861839 ± 0.00364649 (W 0.00357803) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.38547 ± 0.0291855 (W 0.024866) | 6.38548 ± 0.00514117 (W 0.0341134) | 5.34327 ± 0.102452 (W 0.0123139) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.35725 ± 0.157917 (W 0.0262314) | 4.3256 ± 0.0248019 (W 0.039194) | 4.10185 ± 0.0127189 (W 0.0127156) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 22.3006 ± 0.0488217 (W 0.0607379) | 22.2292 ± 0.0521425 (W 0.145729) | 21.0305 ± 0.0082177 (W 0.0370086) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 93.9038 ± 0.0718497 (W 0.301246) | 93.8294 ± 0.306172 (W 0.2055) | 112.561 ± 0.835271 (W 0.149561) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.02821 ± 0.010715 (W 0.00821182) | 3.01977 ± 0.0166391 (W 0.00454751) | 2.01544 ± 0.00691119 (W 0.0036554) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.8491 ± 0.0319386 (W 0.0774945) | 16.8101 ± 0.0316884 (W 0.0943881) | 11.0412 ± 0.0219375 (W 0.00570084) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 63.9396 ± 0.14004 (W 0.317912) | 63.9281 ± 0.0637296 (W 0.385087) | 55.6837 ± 6.15948 (W 0.12778) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `triangular_solve/n128/b1` | 0.007154 ± 0.00043704 (W 2.67264e-05) | 0.007213 ± 0.00040548 (W 3.57533e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.020348 ± 5.1316e-05 (W 6.57267e-05) | 0.020198 ± 0.000205218 (W 5.09637e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.070502 ± 0.00443705 (W 0.00437457) | 0.07512 ± 0.00413726 (W 0.00270706) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.183354 ± 0.000662518 (W 0.00124009) | 0.200897 ± 0.00201742 (W 0.00223744) | 0.409759 ± 0.00208164 (W 0.00317123) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 2.23× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.744688 ± 0.014395 (W 0.0162179) | 0.787435 ± 0.00906537 (W 0.0247648) | 0.464527 ± 0.00220019 (W 0.00438337) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.43295 ± 0.00437328 (W 0.0230921) | 2.49282 ± 0.0077489 (W 0.0159988) | 1.86203 ± 0.0175886 (W 0.0153843) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.92409 ± 0.0250653 (W 0.0381175) | 3.01551 ± 0.021975 (W 0.0346078) | 1.65393 ± 0.00288754 (W 0.00408762) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7514 ± 0.0255439 (W 0.0253244) | 11.1243 ± 0.0154277 (W 0.0460129) | 7.887 ± 0.0127129 (W 0.00961954) | · | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.8336 ± 0.190025 (W 0.0998155) | 39.8558 ± 0.197401 (W 0.206845) | 36.4918 ± 0.0216616 (W 0.0294484) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.741158 ± 0.00363307 (W 0.00686873) | 0.744188 ± 0.00286717 (W 0.00464881) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74615 ± 0.026831 (W 0.00907862) | 5.71951 ± 0.0200743 (W 0.0228445) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.5378 ± 0.0690261 (W 0.0662893) | 24.5724 ± 0.0362155 (W 0.0724627) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.193604 ± 0.00181914 (W 0.00222672) | 0.276878 ± 0.00172446 (W 0.00196323) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.194604 ± 0.00201923 (W 0.00166852) | 0.279084 ± 0.00123009 (W 0.00146409) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01882 ± 0.00696327 (W 0.00291739) | 1.27816 ± 0.00449667 (W 0.0586147) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.02189 ± 0.000560803 (W 0.00451134) | 1.28276 ± 0.00587437 (W 0.0630611) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.25328 ± 0.0286919 (W 0.0337282) | 8.72474 ± 0.0295966 (W 0.506969) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.22438 ± 0.0567685 (W 0.041924) | 8.7939 ± 0.0134464 (W 0.540258) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295053 ± 0.0034177 (W 0.00192726) | 0.338781 ± 0.00294447 (W 0.00622775) | 0.458625 ± 0.00163187 (W 0.00212198) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.41434 ± 0.0102413 (W 0.0198004) | 1.46401 ± 0.0164496 (W 0.0267847) | 0.67626 ± 0.00263835 (W 0.00489292) | · | 🔴 faer-fork 2.09× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 5.41919 ± 0.0235024 (W 0.0358084) | 5.54361 ± 0.0106249 (W 0.0416572) | 3.4748 ± 0.0280636 (W 0.0138633) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.951793 ± 0.00703287 (W 0.0167917) | 2.42369 ± 0.0136749 (W 0.0246811) | 0.798395 ± 0.00182376 (W 0.00514432) | 🔵 faer-fork 2.55× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.29677 ± 0.0287482 (W 0.0191964) | 6.74579 ± 0.0485069 (W 0.0552651) | 4.08194 ± 0.0307107 (W 0.00722119) | 🔵 faer-fork 2.05× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 15.0486 ± 0.0428882 (W 0.0317898) | 22.3749 ± 0.105259 (W 0.155015) | 17.0338 ± 0.0108924 (W 0.0255605) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.55941 ± 0.00109856 (W 0.00370031) | 1.90725 ± 0.0168549 (W 0.0217021) | 0.306925 ± 0.00021504 (W 0.00178791) | 🔵 faer-fork 3.41× faster than `faer-upstream` | 🔴 faer-fork 1.82× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.27865 ± 0.0089281 (W 0.0107075) | 5.29837 ± 0.0272534 (W 0.0486818) | 1.58691 ± 0.0024669 (W 0.00385892) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.70688 ± 0.0261744 (W 0.026046) | 14.9104 ± 0.147759 (W 0.118151) | 5.61756 ± 0.00153312 (W 0.0086012) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292248 ± 0.000719556 (W 0.00236369) | 0.326723 ± 0.00267656 (W 0.00656631) | 0.44842 ± 0.0018637 (W 0.00234819) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.27333 ± 0.014383 (W 0.0150227) | 1.32064 ± 0.018196 (W 0.0225334) | 0.649497 ± 0.00630816 (W 0.00462876) | · | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.24669 ± 0.0292099 (W 0.0159068) | 5.37086 ± 0.0133429 (W 0.0286394) | 3.309 ± 0.0147675 (W 0.0149954) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.26733 ± 0.0212057 (W 0.00827321) | 4.48039 ± 0.0177226 (W 0.0239328) | 3.59668 ± 0.00866209 (W 0.00705052) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.2285 ± 0.0351406 (W 0.0575453) | 21.865 ± 0.0584916 (W 0.060251) | 17.1086 ± 0.0346795 (W 0.0323781) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 79.1492 ± 0.218703 (W 0.155726) | 81.0091 ± 0.159846 (W 0.315051) | 81.8458 ± 0.212311 (W 0.0891317) | · | · |  |
| `svd_values/n128/b1` | 3.05713 ± 0.0279963 (W 0.00629263) | 3.05281 ± 0.0259969 (W 0.00616578) | 1.90717 ± 0.00446897 (W 0.00485715) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.9067 ± 0.0463461 (W 0.0337201) | 16.9214 ± 0.0593517 (W 0.031511) | 9.64193 ± 0.0328166 (W 0.0106988) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.7914 ± 0.378516 (W 0.28864) | 60.3583 ± 0.213383 (W 0.189944) | 42.8348 ± 0.201994 (W 0.0407682) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007193 ± 0.000496831 (W 2.61209e-05) | 0.007183 ± 0.000519835 (W 2.58844e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.020478 ± 0.00162644 (W 7.59355e-05) | 0.020478 ± 0.00148158 (W 7.85252e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.080651 ± 0.00313513 (W 0.00179888) | 0.078597 ± 0.00342274 (W 0.00464441) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.81552 ± 0.00266049 (W 0.00197806) | 0.816581 ± 0.0070806 (W 0.00769024) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.3192 ± 0.286069 (W 0.111308) | 54.7382 ± 1.42788 (W 1.00027) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.556733 ± 0.00150158 (W 0.00225989) | 0.555482 ± 0.00406182 (W 0.00239697) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.557164 ± 0.00158215 (W 0.00269915) | 0.553929 ± 0.00257716 (W 0.00212392) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1032 ± 0.156551 (W 0.0643099) | 35.1851 ± 0.702928 (W 0.135204) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.0295 ± 0.211673 (W 0.0144197) | 35.1813 ± 0.17966 (W 0.0309365) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.471254 ± 0.00114832 (W 0.00324067) | 0.467345 ± 0.00293857 (W 0.00506779) | 0.664537 ± 0.136304 (W 0.0032679) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.2873 ± 0.193371 (W 0.0295823) | 18.9721 ± 0.0471533 (W 0.0380171) | 17.8745 ± 2.57342 (W 0.0779882) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.57319 ± 0.00703809 (W 0.00268929) | 1.55223 ± 0.00247786 (W 0.00492749) | 1.85893 ± 0.0064522 (W 0.00487467) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 66.7802 ± 2.52577 (W 0.0873664) | 69.7065 ± 2.53223 (W 0.0975273) | 81.5431 ± 0.490775 (W 0.158145) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.05953 ± 0.00611305 (W 0.00325218) | 1.87808 ± 0.00980547 (W 0.00588475) | 0.906681 ± 0.000613792 (W 0.00123124) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 31.7908 ± 0.239246 (W 0.095367) | 78.2999 ± 0.14201 (W 0.461448) | 35.1561 ± 0.184251 (W 0.124125) | 🔵 faer-fork 2.46× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50154 ± 0.00822849 (W 0.00482764) | 2.50686 ± 0.00915927 (W 0.00575345) | 3.04964 ± 0.00582228 (W 0.00393521) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.2628 ± 0.33178 (W 0.0692497) | 87.9829 ± 0.14629 (W 0.106167) | 120.275 ± 0.716122 (W 0.198215) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48619 ± 0.00287924 (W 0.00334026) | 1.48942 ± 0.00885716 (W 0.00607805) | 1.38827 ± 0.00182052 (W 0.00215447) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.8166 ± 0.0397327 (W 0.0544178) | 44.8313 ± 0.0167784 (W 0.0349206) | 46.6115 ± 0.0962934 (W 0.100398) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814434 ± 0.0139984 (W 0.00182862) | 0.8157 ± 0.00592455 (W 0.00574789) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.9009 ± 0.0940011 (W 0.239151) | 26.0101 ± 0.322634 (W 0.760116) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.185243 ± 0.00205114 (W 0.00843083) | 0.159682 ± 0.00278523 (W 0.002325) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.184432 ± 0.00388143 (W 0.00250925) | 0.161298 ± 0.0038298 (W 0.00176737) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.2153 ± 0.154106 (W 0.0469923) | 9.41094 ± 0.213284 (W 0.0389572) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.1235 ± 0.105262 (W 0.0569287) | 9.44739 ± 0.160317 (W 0.0366906) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.494938 ± 0.00210162 (W 0.0116279) | 0.497733 ± 0.00168048 (W 0.00848796) | 0.532058 ± 0.119869 (W 0.0049634) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.40946 ± 0.102902 (W 0.0210446) | 12.9844 ± 0.0348542 (W 0.0290439) | 13.4752 ± 1.90094 (W 0.0233361) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.26406 ± 0.0148078 (W 0.0124062) | 1.69058 ± 0.0101669 (W 0.0105003) | 1.05498 ± 0.00394431 (W 0.00321335) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 28.3308 ± 0.199514 (W 0.334643) | 35.4703 ± 0.0438466 (W 0.113314) | 30.3041 ± 0.368626 (W 0.0796717) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.05143 ± 0.00866964 (W 0.00671964) | 3.89964 ± 0.0488052 (W 0.0907279) | 0.454462 ± 0.00475396 (W 0.00435927) | 🔵 faer-fork 3.71× faster than `faer-upstream` | 🔴 faer-fork 2.31× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 15.7842 ± 0.119714 (W 0.159366) | 77.2372 ± 0.283361 (W 0.589507) | 12.8552 ± 0.14095 (W 0.0647481) | 🔵 faer-fork 4.89× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.35787 ± 0.00798964 (W 0.0156538) | 2.77088 ± 0.0149493 (W 0.0186554) | 1.89996 ± 0.0102698 (W 0.0111876) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 46.8633 ± 0.124017 (W 0.18818) | 50.4003 ± 0.0410733 (W 0.17483) | 48.6526 ± 2.41568 (W 0.132337) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.64528 ± 0.029837 (W 0.0183832) | 2.08696 ± 0.0150387 (W 0.0273631) | 0.944715 ± 0.00370459 (W 0.00901171) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 31.4225 ± 0.239848 (W 0.189597) | 35.3543 ± 0.130138 (W 0.160196) | 22.7633 ± 0.405651 (W 0.0539679) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814549 ± 0.00144851 (W 0.00151507) | 0.820267 ± 0.0050174 (W 0.00575995) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.8243 ± 0.00978057 (W 0.0778799) | 20.4313 ± 0.502913 (W 1.36802) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.159061 ± 0.00339923 (W 0.00283257) | 0.136085 ± 0.00226384 (W 0.00253904) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.156277 ± 0.00436507 (W 0.00205074) | 0.137944 ± 0.00099664 (W 0.00264883) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.4774 ± 0.0621459 (W 0.0503173) | 5.07879 ± 1.22255 (W 1.12778) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.56357 ± 0.0657111 (W 0.0340066) | 5.01969 ± 0.0578784 (W 1.03147) | - | 🔴 faer-fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.484027 ± 0.00319806 (W 0.00500391) | 0.533735 ± 0.00271953 (W 0.0123061) | 0.598182 ± 0.165847 (W 0.00268908) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.68624 ± 0.182164 (W 0.0379129) | 12.2222 ± 0.00802053 (W 0.0258402) | 4.14579 ± 1.81225 (W 0.0266181) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔴 faer-fork 2.10× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.39729 ± 0.00973365 (W 0.0182771) | 2.01031 ± 0.0337029 (W 0.0230723) | 0.886806 ± 0.000920803 (W 0.00299265) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.1319 ± 0.0551163 (W 0.138608) | 35.5577 ± 0.710186 (W 0.802041) | 20.8793 ± 0.215314 (W 0.0763181) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.09999 ± 0.00615337 (W 0.0123764) | 4.33688 ± 0.088263 (W 0.117849) | 0.322285 ± 0.000515863 (W 0.00198946) | 🔵 faer-fork 3.94× faster than `faer-upstream` | 🔴 faer-fork 3.41× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 12.8929 ± 0.0666194 (W 0.0731303) | 76.7059 ± 0.890114 (W 0.38719) | 7.35871 ± 0.0248983 (W 0.0637313) | 🔵 faer-fork 5.95× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.49986 ± 0.0103059 (W 0.015311) | 3.14162 ± 0.0318246 (W 0.0372606) | 1.67826 ± 0.00502347 (W 0.00432657) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.6031 ± 0.0917349 (W 0.097876) | 50.6132 ± 0.384171 (W 0.570353) | 36.6039 ± 0.284855 (W 0.0851246) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.75076 ± 0.0420563 (W 0.0159804) | 2.48282 ± 0.0171626 (W 0.0429905) | 0.812113 ± 0.00265467 (W 0.00243731) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 29.6878 ± 0.817247 (W 0.067555) | 38.6983 ± 1.12014 (W 0.722197) | 16.8419 ± 0.195799 (W 0.0536169) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730739 ± 0.00115616 (W 0.00307598) | 0.733033 ± 0.00168186 (W 0.00294816) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.2194 ± 0.217717 (W 0.0603161) | 47.0466 ± 0.293468 (W 0.0772841) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.595375 ± 0.0135356 (W 0.00129409) | 0.594366 ± 0.0138415 (W 0.00238869) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.57551 ± 0.0185488 (W 0.00217585) | 0.572544 ± 0.0151342 (W 0.00199809) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.8143 ± 0.150079 (W 0.0410223) | 35.6607 ± 0.174224 (W 0.0291111) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.7554 ± 0.294899 (W 0.0436682) | 35.7999 ± 0.240863 (W 0.0276565) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.385362 ± 9.85951e-05 (W 0.00297846) | 0.38389 ± 0.00140764 (W 0.00261452) | 0.287399 ± 0.00169652 (W 0.00153251) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2857 ± 0.0506638 (W 0.0218223) | 13.2753 ± 0.0684971 (W 0.0241448) | 11.7381 ± 0.0328361 (W 0.0146141) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.45858 ± 0.0028724 (W 0.00420398) | 1.46252 ± 0.00292026 (W 0.00232463) | 1.57951 ± 0.00429851 (W 0.00377317) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 63.8453 ± 2.58061 (W 0.0773227) | 63.9621 ± 2.63576 (W 0.0490497) | 69.7643 ± 0.340636 (W 0.16962) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.791764 ± 0.000991583 (W 0.00178642) | 0.791813 ± 0.0105867 (W 0.00211968) | 0.763541 ± 0.000800003 (W 0.00257115) | · | · |  |
| `qr_factor/4096x256/b1` | 25.9609 ± 0.0374947 (W 0.0201833) | 25.9911 ± 0.0522642 (W 0.0232417) | 29.0532 ± 0.0164802 (W 0.0167853) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.45526 ± 0.00414598 (W 0.0118918) | 2.45567 ± 0.00399783 (W 0.00290012) | 2.81496 ± 0.00561819 (W 0.00462395) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.7378 ± 0.357202 (W 0.11625) | 82.7521 ± 0.350336 (W 0.126516) | 109.909 ± 0.568061 (W 0.190123) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39918 ± 0.00269892 (W 0.00381525) | 1.39833 ± 0.00205514 (W 0.00178308) | 1.24504 ± 0.00429512 (W 0.00337162) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 39.1098 ± 0.0136581 (W 0.0353854) | 39.2007 ± 0.0726389 (W 0.0464339) | 40.4907 ± 0.0544287 (W 0.123265) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.728911 ± 0.0146062 (W 0.00234318) | 0.730898 ± 0.0268691 (W 0.00262756) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 17.7472 ± 0.0556261 (W 0.0718707) | 17.8683 ± 0.115284 (W 0.20386) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.19176 ± 0.00499179 (W 0.00927501) | 0.17619 ± 0.00529252 (W 0.00223705) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.197046 ± 0.00102542 (W 0.00590014) | 0.175465 ± 0.00412324 (W 0.00209096) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.2996 ± 0.0779082 (W 0.0166809) | 10.9971 ± 0.152302 (W 0.029883) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.333 ± 0.0514451 (W 0.0276766) | 11.2302 ± 0.00606886 (W 0.0173933) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.412012 ± 0.00281621 (W 0.00354883) | 0.429121 ± 0.00183416 (W 0.00849469) | 0.285588 ± 0.00130913 (W 0.00221913) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.34731 ± 0.0115604 (W 0.0301445) | 7.39548 ± 0.0186927 (W 0.0358873) | 11.5972 ± 0.00898861 (W 0.0155423) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.17365 ± 0.00304957 (W 0.00867211) | 1.60943 ± 0.00740084 (W 0.0140631) | 0.985594 ± 0.00425654 (W 0.00389713) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.0747 ± 0.106063 (W 0.207064) | 29.6365 ± 0.0785302 (W 0.112154) | 27.029 ± 0.168644 (W 0.0717446) | 🔵 faer-fork 1.14× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.8942 ± 0.00219583 (W 0.00703183) | 1.34842 ± 0.00759551 (W 0.0166896) | 0.415928 ± 0.00288834 (W 0.00384766) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.3722 ± 0.298077 (W 0.18398) | 17.544 ± 0.251868 (W 0.118182) | 11.32 ± 0.0386192 (W 0.0317248) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.30863 ± 0.0063868 (W 0.0201509) | 2.71227 ± 0.0215831 (W 0.0242598) | 1.82496 ± 0.000751975 (W 0.00805496) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 41.2528 ± 0.126813 (W 0.231685) | 44.756 ± 0.0212289 (W 0.162362) | 45.8209 ± 0.107706 (W 0.0539457) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.55544 ± 0.0122937 (W 0.0162382) | 2.01751 ± 0.0121065 (W 0.0291702) | 0.915749 ± 0.00653256 (W 0.0067119) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.6251 ± 0.133523 (W 0.185591) | 29.7611 ± 0.121979 (W 0.11523) | 20.965 ± 0.062863 (W 0.0758377) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.732693 ± 0.000742475 (W 0.00337287) | 0.731041 ± 0.00898678 (W 0.00208943) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6901 ± 0.0604331 (W 0.0498838) | 13.7352 ± 0.0738595 (W 0.0630024) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.161653 ± 0.000119378 (W 0.00200846) | 0.162497 ± 0.00146865 (W 0.00176422) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.159372 ± 0.0023328 (W 0.00205297) | 0.164228 ± 0.00379717 (W 0.00270786) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.69602 ± 0.116671 (W 0.696198) | 6.69386 ± 0.0761006 (W 0.274124) | - | 🔴 faer-fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.51019 ± 0.26887 (W 0.190701) | 6.98952 ± 0.77121 (W 0.892988) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.393469 ± 0.00447567 (W 0.00441662) | 0.442671 ± 0.00252556 (W 0.0106681) | 0.286391 ± 0.000858828 (W 0.00256418) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.62275 ± 0.00932567 (W 0.0255617) | 6.68534 ± 0.0598788 (W 0.0290829) | 3.14673 ± 0.0101555 (W 0.0107573) | · | 🔴 faer-fork 2.10× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.31476 ± 0.0188133 (W 0.0127762) | 1.89741 ± 0.0166849 (W 0.019254) | 0.84772 ± 0.0030546 (W 0.00454932) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 19.896 ± 0.124038 (W 0.0720749) | 29.7417 ± 0.119642 (W 0.306617) | 19.2265 ± 0.158585 (W 0.0491305) | 🔵 faer-fork 1.49× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.996044 ± 0.0068526 (W 0.0101721) | 1.66183 ± 0.00796839 (W 0.0219151) | 0.300567 ± 0.00172659 (W 0.00162707) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔴 faer-fork 3.31× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.6105 ± 0.027504 (W 0.0765223) | 19.2861 ± 0.263441 (W 0.157553) | 6.501 ± 0.0202312 (W 0.0222424) | 🔵 faer-fork 1.66× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.46433 ± 0.0211049 (W 0.0142387) | 3.08004 ± 0.0136168 (W 0.0241299) | 1.63771 ± 0.00430932 (W 0.00424231) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 35.055 ± 0.135195 (W 0.113916) | 44.8737 ± 0.415421 (W 0.590653) | 34.3041 ± 0.20325 (W 0.152618) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.6629 ± 0.0157462 (W 0.0200164) | 2.3739 ± 0.0169464 (W 0.0329878) | 0.790441 ± 0.0060832 (W 0.00556018) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 2.10× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.1215 ± 0.0482601 (W 0.0856446) | 31.759 ± 0.0833951 (W 0.0912012) | 15.8338 ± 0.31762 (W 0.0413544) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78146 ± 0.00196568 (W 0.00509646) | 1.80385 ± 0.0177578 (W 0.00518791) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.86 ± 0.198157 (W 0.627453) | 155.225 ± 1.38411 (W 0.796096) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.20068 ± 0.00135514 (W 0.0028775) | 2.20856 ± 0.0178375 (W 0.00357891) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.19988 ± 0.00288644 (W 0.00199055) | 2.20061 ± 0.0236589 (W 0.00184774) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.893 ± 0.111051 (W 0.403669) | 137.99 ± 0.0971349 (W 0.0901858) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.064 ± 0.00983608 (W 0.111121) | 138.138 ± 0.0460233 (W 0.337588) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.989397 ± 0.00205562 (W 0.0016139) | 0.998901 ± 0.00674244 (W 0.00119566) | 1.19442 ± 0.000711981 (W 0.00156692) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.7471 ± 0.179223 (W 0.11427) | 53.6543 ± 0.078915 (W 0.0811221) | 65.5723 ± 4.87365 (W 0.470545) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 4.71826 ± 0.00365236 (W 0.0025321) | 4.74032 ± 0.00315727 (W 0.00494901) | 5.11802 ± 0.00605355 (W 0.00942016) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 249.089 ± 0.106852 (W 0.351921) | 255.491 ± 0.112088 (W 0.138436) | 236.86 ± 4.59361 (W 0.620193) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.4906 ± 0.038987 (W 0.00412533) | 4.0597 ± 0.0218569 (W 0.017588) | 2.38281 ± 0.00600542 (W 0.00445549) | 🔵 faer-fork 1.63× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 100.099 ± 0.520172 (W 0.114118) | 176.708 ± 0.849273 (W 0.370135) | 109.824 ± 2.4328 (W 0.404047) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.98052 ± 0.00689564 (W 0.00416998) | 5.99584 ± 0.00555504 (W 0.00507652) | 8.77732 ± 0.0109247 (W 0.0137742) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 280.418 ± 0.293597 (W 1.0209) | 281.144 ± 0.264107 (W 0.625655) | 379.197 ± 0.596094 (W 0.478011) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.0601 ± 0.00373515 (W 0.00376275) | 3.07366 ± 0.00316943 (W 0.00315205) | 3.80999 ± 0.00813767 (W 0.0045802) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 122.432 ± 0.885542 (W 0.1103) | 122.389 ± 0.959539 (W 0.0743985) | 144.489 ± 0.655032 (W 0.496696) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77514 ± 0.00963957 (W 0.00336381) | 1.80023 ± 0.0169085 (W 0.00407445) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.0979 ± 0.0976166 (W 0.541182) | 66.043 ± 0.272455 (W 1.58673) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.634126 ± 0.00354565 (W 0.0131147) | 0.595844 ± 0.00802997 (W 0.00331824) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.623327 ± 0.0229852 (W 0.00768079) | 0.605913 ± 0.0143119 (W 0.00191556) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.2272 ± 0.10187 (W 0.171118) | 37.0522 ± 0.181628 (W 0.0366992) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.1117 ± 0.0505589 (W 0.0510824) | 37.1403 ± 0.224553 (W 0.181484) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.816845 ± 0.00639628 (W 0.0132214) | 0.812233 ± 0.00956236 (W 0.00982644) | 1.09416 ± 0.00686935 (W 0.00151617) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.9879 ± 0.219983 (W 0.0591355) | 29.6654 ± 0.0405351 (W 0.0797186) | 53.0983 ± 3.5787 (W 0.287797) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 2.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.65662 ± 0.0807196 (W 0.0230646) | 3.02 ± 0.0204853 (W 0.0286363) | 3.12571 ± 0.0524751 (W 0.0030861) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 84.0067 ± 0.205085 (W 0.216941) | 98.7513 ± 0.140201 (W 0.0832048) | 79.9685 ± 0.260834 (W 0.362991) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.98115 ± 0.0615606 (W 0.0797742) | 4.46751 ± 0.00466902 (W 0.0452202) | 1.39013 ± 0.00464712 (W 0.00300382) | 🔵 faer-fork 2.26× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 40.3481 ± 0.329078 (W 0.150688) | 124.738 ± 0.366345 (W 0.559178) | 33.7567 ± 0.286936 (W 0.231031) | 🔵 faer-fork 3.09× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.12294 ± 0.074745 (W 0.0890414) | 4.36204 ± 0.0267804 (W 0.0366263) | 5.49038 ± 0.00681277 (W 0.00817611) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 115.277 ± 0.134218 (W 0.156576) | 122.446 ± 0.261603 (W 0.179467) | 139.29 ± 3.5527 (W 0.642049) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.6346 ± 0.0199155 (W 0.0594652) | 2.99195 ± 0.0315222 (W 0.0358439) | 2.82352 ± 0.0316725 (W 0.0036263) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 66.6845 ± 0.70943 (W 0.616906) | 75.0912 ± 0.173893 (W 0.162381) | 51.5218 ± 0.204853 (W 0.244072) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77555 ± 0.00675173 (W 0.0031429) | 1.79405 ± 0.0124884 (W 0.00252726) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.4752 ± 0.432869 (W 0.653057) | 41.4601 ± 0.363896 (W 0.444037) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.417456 ± 0.00692292 (W 0.00801226) | 0.413208 ± 0.000636483 (W 0.00204776) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.416864 ± 0.0118776 (W 0.00636159) | 0.416083 ± 0.00142726 (W 0.00420979) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.0396 ± 0.093829 (W 0.417322) | 18.8308 ± 0.0319575 (W 3.79526) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.3125 ± 0.2193 (W 4.12719) | 18.6964 ± 0.0367979 (W 3.50153) | - | 🔴 faer-fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.791904 ± 0.0103873 (W 0.0101074) | 0.800981 ± 0.027314 (W 0.00871917) | 1.08188 ± 0.00160515 (W 0.00197626) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 18.8301 ± 0.0294003 (W 0.16937) | 25.7928 ± 0.0345446 (W 0.0709873) | 57.4426 ± 3.50429 (W 0.141842) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 3.05× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.44799 ± 0.0154465 (W 0.0225617) | 3.26428 ± 0.0371822 (W 0.0279257) | 2.32346 ± 0.00547327 (W 0.00368518) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 57.9011 ± 6.32033 (W 0.276335) | 81.8248 ± 5.96916 (W 0.809705) | 46.027 ± 0.179374 (W 0.173651) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.84459 ± 0.00595409 (W 0.0219398) | 5.04208 ± 0.14381 (W 0.0622723) | 0.871555 ± 0.00505018 (W 0.00212794) | 🔵 faer-fork 2.73× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 30.5771 ± 0.0600606 (W 0.0929829) | 122.512 ± 0.982062 (W 0.74518) | 19.8311 ± 0.0531836 (W 0.154653) | 🔵 faer-fork 4.01× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.84085 ± 0.0176873 (W 0.0232208) | 4.67549 ± 0.0331593 (W 0.024666) | 4.47542 ± 0.0197995 (W 0.00797765) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.4223 ± 0.174023 (W 0.161777) | 105.361 ± 0.168139 (W 0.950478) | 82.8999 ± 3.98263 (W 0.283177) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.65134 ± 0.0275828 (W 0.0157966) | 3.35434 ± 0.0266665 (W 0.0247757) | 2.31403 ± 0.0276125 (W 0.00638117) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 58.4635 ± 0.149905 (W 0.118644) | 72.5639 ± 0.189274 (W 0.120476) | 34.3676 ± 0.180437 (W 0.12311) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66834 ± 0.00516356 (W 0.00357552) | 1.665 ± 0.00202266 (W 0.00324894) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.479 ± 0.493904 (W 0.365528) | 143.276 ± 0.269807 (W 0.63639) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.2552 ± 0.0200945 (W 0.0035003) | 2.26145 ± 0.0152947 (W 0.0028705) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.24222 ± 0.01997 (W 0.00340267) | 2.24416 ± 0.0122434 (W 0.00224793) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.679 ± 0.184524 (W 0.0925368) | 138.848 ± 0.253081 (W 0.0798743) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.591 ± 0.211075 (W 0.112497) | 138.839 ± 0.189383 (W 0.394022) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.870919 ± 0.00153143 (W 0.00176591) | 0.872682 ± 0.000967428 (W 0.00203649) | 1.05287 ± 0.0403537 (W 0.00296644) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 41.5819 ± 0.11295 (W 0.0382168) | 41.4856 ± 0.0915743 (W 0.0229369) | 51.0379 ± 0.675004 (W 0.0594063) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.59751 ± 0.00296604 (W 0.00927977) | 4.61062 ± 0.0133368 (W 0.00238818) | 4.85137 ± 0.0178125 (W 0.00879405) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 243.482 ± 0.269964 (W 0.395522) | 244.325 ± 0.276183 (W 0.432026) | 217.128 ± 1.75299 (W 0.356252) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.28353 ± 0.00935914 (W 0.00663758) | 2.26136 ± 0.0292026 (W 0.00298804) | 2.24001 ± 0.00956959 (W 0.00379535) | · | · |  |
| `qr_factor/4096x256/b1` | 90.0525 ± 0.0506873 (W 0.0533158) | 90.2828 ± 0.147833 (W 0.0635643) | 104.476 ± 0.682467 (W 0.169175) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.88147 ± 0.00691825 (W 0.00808597) | 5.89208 ± 0.0105182 (W 0.00438929) | 8.49351 ± 0.0279203 (W 0.0148159) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 268.052 ± 0.150899 (W 0.510781) | 269.186 ± 0.306064 (W 0.455175) | 363.949 ± 5.50882 (W 1.61682) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.94738 ± 0.00154015 (W 0.00396528) | 2.95847 ± 0.00809829 (W 0.00242184) | 3.66543 ± 0.0138289 (W 0.00434457) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 110.104 ± 0.140919 (W 0.119936) | 110.185 ± 0.220758 (W 0.36404) | 140.365 ± 2.34222 (W 0.587744) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66253 ± 0.003599 (W 0.00337023) | 1.65686 ± 0.00936176 (W 0.00286798) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.8751 ± 0.0578986 (W 0.681727) | 52.8125 ± 0.397619 (W 0.49752) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.645017 ± 0.0105398 (W 0.0111328) | 0.629879 ± 0.00678425 (W 0.00435937) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.656519 ± 0.0118254 (W 0.00616694) | 0.651309 ± 0.0196589 (W 0.00314329) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.3178 ± 0.0823206 (W 0.0436098) | 39.7156 ± 0.110738 (W 0.0384881) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.3154 ± 0.0691316 (W 0.0402014) | 39.7268 ± 0.0724047 (W 0.105106) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.707266 ± 0.00169555 (W 0.00979073) | 0.703122 ± 0.00850577 (W 0.0142793) | 1.06706 ± 0.0022192 (W 0.00162757) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.3295 ± 0.0489537 (W 0.0577007) | 17.39 ± 0.0322258 (W 0.0551451) | 49.604 ± 0.203517 (W 0.0723556) | · | 🔵 faer-fork 2.86× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.62928 ± 0.0553052 (W 0.110691) | 2.89305 ± 0.00855836 (W 0.0220135) | 3.04549 ± 0.0065677 (W 0.00592647) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 78.6318 ± 0.225787 (W 0.275237) | 86.5843 ± 0.110719 (W 0.137744) | 74.2977 ± 0.298041 (W 0.26499) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.74609 ± 0.0731679 (W 0.0142421) | 2.12444 ± 0.0176575 (W 0.0221352) | 1.35284 ± 0.00119116 (W 0.0476732) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 35.7497 ± 0.055731 (W 0.0620054) | 44.1729 ± 0.0336159 (W 0.146681) | 30.8593 ± 0.160684 (W 0.223062) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.91009 ± 0.0810325 (W 0.109271) | 4.22837 ± 0.0130327 (W 0.018143) | 5.40873 ± 0.0675487 (W 0.0441744) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 103.15 ± 0.101575 (W 0.226522) | 110.563 ± 0.246775 (W 0.169337) | 129.218 ± 0.482738 (W 0.566844) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.52742 ± 0.0928716 (W 0.0448337) | 2.92745 ± 0.0171375 (W 0.0327284) | 2.7807 ± 0.0106963 (W 0.00323599) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 54.8755 ± 0.0836391 (W 0.0701361) | 63.0948 ± 0.0613055 (W 0.0710157) | 48.3617 ± 0.297771 (W 0.179462) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6648 ± 0.00824303 (W 0.0036905) | 1.66328 ± 0.00627318 (W 0.00277383) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.5957 ± 0.687897 (W 0.690407) | 30.1603 ± 0.853242 (W 0.646608) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.4201 ± 0.00202139 (W 0.0100688) | 0.448882 ± 0.00523593 (W 0.00444046) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.426592 ± 0.00809172 (W 0.0107679) | 0.469129 ± 0.00834346 (W 0.00294003) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.6678 ± 0.240882 (W 0.440826) | 21.3851 ± 0.142346 (W 0.416195) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.3381 ± 0.291333 (W 0.324528) | 21.1704 ± 0.227721 (W 3.18836) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.688237 ± 0.00217237 (W 0.0126169) | 0.694973 ± 0.00309902 (W 0.00599239) | 1.06135 ± 0.00883349 (W 0.00398459) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.4141 ± 0.0535833 (W 0.0516607) | 13.517 ± 0.034917 (W 0.0391049) | 49.4207 ± 0.0501677 (W 0.0544805) | · | 🔵 faer-fork 3.68× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.31259 ± 0.00108849 (W 0.0122428) | 3.14595 ± 0.0257075 (W 0.0304651) | 2.27906 ± 0.00473268 (W 0.00454765) | 🔵 faer-fork 1.36× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 52.2261 ± 6.25502 (W 0.268021) | 69.6338 ± 6.07531 (W 0.619643) | 42.2653 ± 0.194085 (W 0.202275) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.7114 ± 0.00435742 (W 0.0210701) | 2.45508 ± 0.00310282 (W 0.0353821) | 0.851887 ± 0.000249658 (W 0.00175239) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 2.01× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.6667 ± 0.134428 (W 0.051655) | 41.5631 ± 0.268799 (W 0.119696) | 17.6418 ± 0.101278 (W 0.0724089) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.73688 ± 0.0193867 (W 0.0180452) | 4.55076 ± 0.0466491 (W 0.0326858) | 4.41161 ± 0.0120404 (W 0.0126566) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 76.1818 ± 0.0334862 (W 0.167045) | 93.1598 ± 2.86336 (W 0.174704) | 73.9688 ± 0.498486 (W 0.256163) | 🔵 faer-fork 1.22× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.52496 ± 0.0121003 (W 0.019128) | 3.27106 ± 0.0156003 (W 0.0304533) | 2.30135 ± 0.0082339 (W 0.00282002) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 47.0917 ± 0.277441 (W 0.105154) | 60.8045 ± 0.171627 (W 0.503927) | 32.4787 ± 0.287213 (W 0.102973) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
