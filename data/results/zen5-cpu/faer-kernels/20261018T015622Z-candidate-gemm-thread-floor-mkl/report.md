# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `2000dd9067306b163cbc4d0f2541d039926551d0`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9b65ef9ea7de07a70d6f211ae12b47c9bce75b8e`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `9d14689ab8ea005412a100a46a6bd7b0301062ca0d4bd04b7880f38eb8b79ec6`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T02:01:09.233478Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-small,gemm-mid --shapes 32x32x32,64x64x64,96x96x96,128x128x128,192x192x192 --families gemm --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --no-publish --label candidate-gemm-thread-floor-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T015622Z-candidate-gemm-thread-floor-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.11%, worst 7079.25% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 41 of 180 engine cells exceed 5% and carry `!`; median within-process relative SD 1.02%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.002334 ± 1e-05 (W 1.66523e-05) | 0.002344 ± 1.1547e-05 (W 2.03544e-05) | 0.004498 ± 1.12694e-05 (W 2.0693e-05) | · | 🔵 fork 1.93× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017061 ± 6.26126e-05 (W 2.86356e-05) | 0.017062 ± 4.93288e-05 (W 2.21878e-05) | 0.024276 ± 6.97878e-05 (W 4.313e-05) | · | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056666 ± 4.62637e-05 (W 5.44977e-05) | 0.056666 ± 2.51661e-05 (W 7.67867e-05) | 0.062607 ± 1.1547e-05 (W 0.00099106) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002345 ± 2.04206e-05 (W 1.6559e-05) | 0.010259 ± 0.000181302 (W 0.000766111) | 0.00539 ± 0.000362809 (W 0.000105651) | 🔵 fork 4.37× faster than `faer-upstream` | 🔵 fork 2.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017162 ± 7.0946e-05 (W 3.74166e-05) | 0.024546 ± 0.0034786 (W 0.00126394) | 0.014176 ± 8.55589e-05 (W 0.000140642) | 🔵 fork 1.43× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.06445 ± 0.00848799 (W 0.0096596) | 0.064691 ± 0.0012732 (W 0.012168) | 0.022412 ± 0.000407297 (W 8.85844e-05) | · | 🔴 fork 2.88× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002335 ± 9.50438e-06 (W 1.93184e-05) | 0.013004 ± 0.000761526 (W 0.00119213) | 0.004959 ± 0.000295703 (W 0.000102539) | 🔵 fork 5.57× faster than `faer-upstream` | 🔵 fork 2.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017142 ± 8.13654e-05 (W 1.64317e-05) | 0.020589 ± 0.00191856 (W 0.00165729) | 0.009888 ± 0.000342063 (W 0.000284975) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030176 ± 0.0009976 (W 0.00115634) | 0.030998 ± 0.000607026 (W 0.0013498) | 0.014968 ± 0.000198109 (W 0.000197219) | · | 🔴 fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002325 ± 1.51767e-05 (W 1.27397e-05) | 0.002324 ± 2.04206e-05 (W 1.13225e-05) | 0.004489 ± 2.02567e-05 (W 1.60406e-05) | · | 🔵 fork 1.93× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017072 ± 4.93288e-05 (W 4.01896e-05) | 0.017142 ± 4.93288e-05 (W 4.91935e-05) | 0.024405 ± 0.000135795 (W 4.77839e-05) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056736 ± 0 (W 0.000938555) | 0.056776 ± 4.58258e-05 (W 8.58487e-05) | 0.062657 ± 0.000190788 (W 0.000106335) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 1.47309e-05 (W 8.26438e-06) | 0.010379 ± 0.000722081 (W 0.000497848) | 0.005109 ± 0.000155242 (W 0.000171082) | 🔵 fork 4.48× faster than `faer-upstream` | 🔵 fork 2.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017121 ± 8.24035e-05 (W 3.91701e-05) | 0.023334 ± 0.000809507 (W 0.0032756) | 0.014106 ± 0.000240271 (W 0.000108766) | 🔵 fork 1.36× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.066384 ± 0.00720699 (W 0.0105492) | 0.060903 ± 0.00498293 (W 0.0108947) | 0.022342 ± 0.000376865 (W 0.000208409) | · | 🔴 fork 2.97× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002314 ± 5.7735e-07 (W 1.22556e-05) | 0.013886 ± 0.567422 (W 0.00184468) | 0.004979 ± 0.000365541 (W 0.000121314) | · | 🔵 fork 2.15× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017122 ± 3.51188e-05 (W 2.97859e-05) | 0.020037 ± 0.000332658 (W 0.00110939) | 0.010239 ± 0.000252032 (W 0.000196317) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.67× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030337 ± 0.00150548 (W 0.00165016) | 0.031559 ± 0.00239304 (W 0.00187419) | 0.014838 ± 0.000178979 (W 0.000186846) | · | 🔴 fork 2.04× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008867 ± 3.21455e-05 (W 2.1312e-05) | 0.008856 ± 5.56507e-05 (W 1.10091e-05) | 0.011201 ± 9.60902e-05 (W 0.000115974) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067757 ± 1.51767e-05 (W 0.00101072) | 0.068207 ± 0.000344893 (W 0.000139822) | 0.081743 ± 0.000943643 (W 0.000669175) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226763 ± 0.000177764 (W 0.00157326) | 0.226793 ± 0.00140009 (W 0.00221955) | 0.275213 ± 0.00831745 (W 0.0043005) | · | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008787 ± 2.51064e-05 (W 1.29345e-05) | 0.008826 ± 2.95014e-05 (W 1.82016e-05) | 0.013986 ± 0.000476677 (W 0.000116543) | · | 🔵 fork 1.59× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.04296 ± 0.00479444 (W 0.00573586) | 0.043401 ± 0.000824721 (W 0.00528743) | 0.035506 ± 0.000182045 (W 0.00113696) | · | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.087493 ± 0.00600907 (W 0.0080375) | 0.095759 ± 0.00547034 (W 0.00811267) | 0.097973 ± 0.000191818 (W 0.00142171) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008787 ± 1.12694e-05 (W 1.31985e-05) | 0.008866 ± 3.72872e-05 (W 1.70675e-05) | 0.024536 ± 0.00519489 (W 0.000451877) | · | 🔵 fork 2.79× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.036048 ± 0.000126338 (W 0.00129453) | 0.036839 ± 0.000806871 (W 0.00179442) | 0.015689 ± 0.000179528 (W 0.000117197) | · | 🔴 fork 2.30× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.051146 ± 0.00103853 (W 0.0011961) | 0.051726 ± 0.000571446 (W 0.000969871) | 0.04272 ± 0.000235514 (W 0.000455474) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008906 ± 4.0501e-05 (W 2.43557e-05) | 0.008876 ± 4.67654e-05 (W 1.48324e-05) | 0.011121 ± 4.89932e-05 (W 0.000108505) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067787 ± 9e-05 (W 4.44106e-05) | 0.067736 ± 8.32666e-05 (W 5.72031e-05) | 0.081822 ± 0.000288271 (W 0.0010879) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.227013 ± 0.000524504 (W 0.001326) | 0.226733 ± 0.000682721 (W 0.0014399) | 0.272399 ± 0.00231793 (W 0.00380387) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008826 ± 3.5171e-05 (W 2.04768e-05) | 0.008817 ± 2.12211e-05 (W 1.78129e-05) | 0.013906 ± 0.000295195 (W 0.0001702) | · | 🔵 fork 1.58× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.044293 ± 0.00581462 (W 0.00474662) | 0.036368 ± 0.00270728 (W 0.00446047) | 0.035607 ± 8.34286e-05 (W 0.000979598) | 🔴 fork 1.22× slower than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.087483 ± 0.00199768 (W 0.00768598) | 0.08568 ± 0.0014469 (W 0.0077257) | 0.098574 ± 0.000310966 (W 0.0015901) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008786 ± 5.2915e-05 (W 2.16795e-05) | 0.008857 ± 1.1547e-05 (W 2.3776e-05) | 0.024526 ± 0.000185831 (W 0.000110635) | · | 🔵 fork 2.79× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.03751 ± 0.00096364 (W 0.00149006) | 0.038332 ± 0.000547614 (W 0.00125817) | 0.01582 ± 0.000128791 (W 0.000167446) | · | 🔴 fork 2.37× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.051596 ± 0.000425226 (W 0.00202463) | 0.051797 ± 0.000284781 (W 0.000638748) | 0.042489 ± 0.000140607 (W 0.000316758) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133449 ± 6.02771e-05 (W 0.00156066) | 0.133569 ± 0.000100167 (W 0.00141976) | 0.166691 ± 0.000645679 (W 0.00169009) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.451763 ± 0.00164837 (W 0.00218418) | 0.452805 ± 0.00105725 (W 0.00171813) | 0.48209 ± 0.000133717 (W 0.00209595) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.082283 ± 0.0169531 (W 0.0243592) | 0.077996 ± 0.0146662 (W 0.0181416) | 0.055975 ± 0.000190832 (W 0.000244708) | · | 🔴 fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.146664 ± 0.0117986 (W 0.0187922) | 0.139781 ± 0.0115355 (W 0.0111852) | 0.134992 ± 0.000556221 (W 0.000217081) | · | 🔴 fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.072465 ± 0.011362 (W 0.0183919) | 0.082985 ± 0.0236115 (W 0.0195279) | 0.032742 ± 0.000485706 (W 0.000209219) | · | 🔴 fork 2.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.190134 ± 0.00650467 (W 0.0374441) | 0.156632 ± 0.00983225 (W 0.0414318) | 0.073647 ± 0.000346319 (W 0.000258509) | 🔴 fork 1.21× slower than `faer-upstream` | 🔴 fork 2.58× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133619 ± 7.99396e-05 (W 0.0010555) | 0.133559 ± 4.59384e-05 (W 0.000123872) | 0.167573 ± 0.000857682 (W 0.00132137) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.453366 ± 0.0021211 (W 0.00216365) | 0.450721 ± 0.00258415 (W 0.00252335) | 0.480908 ± 0.00237114 (W 0.00278091) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.074348 ± 0.0153751 (W 0.0121821) | 0.06445 ± 0.00787242 (W 0.0211171) | 0.055653 ± 0.000200076 (W 0.000206476) | · | 🔴 fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.143167 ± 0.00358447 (W 0.0167398) | 0.142005 ± 0.0107866 (W 0.0155971) | 0.135272 ± 0.000293258 (W 0.00133418) | · | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.079909 ± 0.00778603 (W 0.0317056) | 0.087784 ± 0.0120941 (W 0.0206392) | 0.03199 ± 6.50922e-05 (W 0.000161448) | · | 🔴 fork 2.50× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.168344 ± 0.000962006 (W 0.0355823) | 0.192759 ± 0.039807 (W 0.0393578) | 0.074008 ± 0.000717091 (W 0.000210832) | · | 🔴 fork 2.27× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.537713 ± 0.00136301 (W 0.00197809) | 0.539216 ± 0.00188423 (W 0.00165948) | 0.64325 ± 0.0041253 (W 0.00435945) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81128 ± 0.00493677 (W 0.00217769) | 1.81664 ± 0.00567001 (W 0.00392492) | 2.14765 ± 0.00798196 (W 0.0118974) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160379 ± 0.00158569 (W 0.00477915) | 0.1608 ± 0.00330796 (W 0.00734732) | 0.233425 ± 0.00130574 (W 0.00113746) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.473453 ± 0.00191413 (W 0.00310023) | 0.474766 ± 0.00234123 (W 0.00314539) | 0.744729 ± 0.000612858 (W 0.00407333) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.113872 ± 0.00122375 (W 0.015221) | 0.113913 ± 0.00110373 (W 0.00951632) | 0.094597 ± 0.000324105 (W 0.000952998) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.283479 ± 0.00235315 (W 0.0127452) | 0.274602 ± 0.00265357 (W 0.0116942) | 0.294489 ± 0.00241586 (W 0.00154644) | · | · |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539146 ± 0.000990527 (W 0.00207644) | 0.539076 ± 0.00237457 (W 0.00207854) | 0.650253 ± 0.000685573 (W 0.0063452) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.82204 ± 0.00744522 (W 0.001901) | 1.81748 ± 0.00464174 (W 0.00324361) | 2.14946 ± 0.00861576 (W 0.011801) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.1604 ± 0.000605288 (W 0.000995569) | 0.1607 ± 0.00076135 (W 0.00152806) | 0.232594 ± 0.00190524 (W 0.00299767) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.475216 ± 0.00099422 (W 0.00182748) | 0.474155 ± 0.0031372 (W 0.00405428) | 0.746373 ± 0.00297027 (W 0.0041594) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.120294 ± 0.00667737 (W 0.00913378) | 0.113222 ± 0.000111447 (W 0.0137585) | 0.093895 ± 0.000708552 (W 0.00131687) | 🔴 fork 1.06× slower than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.283499 ± 0.00956477 (W 0.011229) | 0.282007 ± 0.00106176 (W 0.00993031) | 0.297645 ± 0.00215914 (W 0.00264359) | · | · | `!` between-start range over 5% |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
