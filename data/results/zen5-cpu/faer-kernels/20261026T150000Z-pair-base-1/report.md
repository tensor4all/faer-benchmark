# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `5a27bcece2f9f0d1c1b94c9b42dd7bfc4a94dc39`
- t4a-faer version: `0.24.10`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `f37f989c38a5a0d6eba98e5ec7c9dd3c8078b726`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `ac124d68b755974de69922cd51457f9f6235719f96180671a413f0571389e190`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-26T15:27:53.503780Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /home/shinaoka/projects/tensor4all/faer-0.25-base --engines faer-fork,faer-upstream,lapack-mkl --aa 3 --reps 5 --prime-ms 250 --vendor mkl --no-publish --upstream extern/upstream-faer --label pair-base-1 --threads 1,4,8 --dtypes f64,c64 --shapes 64,256,1024x64,64x1024,64x64x64,256x256x256,4096x64x64,16x4096x240,4096x16x240,64x64x4096 --families gemm,lu,qr_factor,cholesky,svd_values,svd_thin,eigh,householder_apply,solve`
- raw data: `data/results/zen5-cpu/faer-kernels/20261026T150000Z-pair-base-1/`

## What was measured

- **Workload** — Direct calls into one faer revision: square and rectangular dense matrices, C (row-major) and F (column-major) order, `f64` and `c64`. A shape is `N` for square, `MxN` for rectangular, or `MxKxN` for `gemm`, which is a three-index operation and cannot be written as two. Sizes are the matrix dimensions, not a memory budget, so a case name says exactly what was factored. `gemm` measures `linalg::matmul::matmul` into a caller-prepared destination with `Accum::Replace`; there is no operator path, so one shape is one work.
  Source: The fork's own public API (`faer/src/linalg`): `matmul`, the QR factor and composite, `upgrade_householder_factor`, the block/sequence Householder apply, LU and full-pivot LU, Cholesky, triangular solve, solve, thin SVD, singular values and the symmetric/nonsymmetric eigensolvers. Inputs are seeded from the case, so `verify` and `run` measure the same matrices and a rerun is reproducible.
  Known blind spot: Only the faer entry points are measured. tlinalg's packing, batch loop and lane policy, tenferro's tensor construction and dtype dispatch, and the small-`m` decode-projection shapes are other repositories' rows (tlinalg-benchmark, tenferro-benchmark).
  Known blind spot: Vendor C-order cells use CBLAS/LAPACKE row-major entry points. Workspace allocation or layout conversion internal to those APIs remains timed; these are not prepared-column-major or transpose measurements.
  Known blind spot: `gemm` covers the tall class's two Householder legs (a 16-wide basis and a 240-column target over 4096 rows: the reduction and the write-back) beside a vendor `?gemm` on the same leg. A single leg beside a vendor gemm is a diagnostic reference, not the equivalent implementation of the whole update, and the row is labelled accordingly.
  Known blind spot: `householder_apply` measures block apply and the one-block sequence form as two distinct rows, labelled with basis width min(m,n) and target width n. QR fixture preparation is outside timing. Independently varied basis/target widths and multi-panel sequences are not covered.
  Known blind spot: Allocation performed inside the measured call stays inside the clock. The fork's two row splits allocate their partial buffers inside the public call, and the public scratch function does not expose them; the campaign reports that as it is instead of changing faer's API to make the boundary look cleaner.
  Known blind spot: `cholesky`, `eigh`, `solve` and `triangular_solve` are measured on square shapes only: the matrix they factor or solve with is square by definition (self-adjoint for the first two, a triangular factor for the last). `lu` and `full_piv_lu` are not gated that way -- they take the declared rectangular shapes too, with `min(m, n)` pivots and a trapezoidal `L` or `U`, which is what `dgetrf` does as well -- so a rectangular LU cell is measured in both orders beside its square one.
  Known blind spot: `f32`/`c32` are declared and measured as of `docs/harness-dtype-axis.md`; the vendor arm has a route for `gemm` in those two dtypes and reports the LAPACK families as skipped for them. The large regime's 1024 shapes, BLIS, sparse, iterative and GPU arms are later declarations, not machinery built now.
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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.86%, worst 1298.31% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 113 of 1152 engine cells exceed 5% and carry `!`; median within-process relative SD 0.35%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/64x64x64/b1` | 0.017042 ± 5.54106e-05 (W 2.30217e-05) | 0.017092 ± 1.52753e-05 (W 3.002e-05) | 0.024416 ± 0.000125033 (W 0.00180829) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017162 ± 6.08276e-05 (W 2.61381e-05) | 0.019537 ± 0.000384605 (W 0.00122535) | 0.013996 ± 7.14866e-05 (W 7.79744e-05) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017032 ± 2.08167e-05 (W 2.50998e-05) | 0.010679 ± 0.000183222 (W 0.000271938) | 0.009839 ± 6.89952e-05 (W 0.000267907) | 🔴 faer-fork 1.59× slower than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017142 ± 7e-05 (W 3.78153e-05) | 0.017152 ± 6.65833e-05 (W 3.78153e-05) | 0.024285 ± 4.87545e-05 (W 8.21359e-05) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017072 ± 7.57188e-05 (W 2.30217e-05) | 0.018204 ± 0.000583862 (W 0.000948871) | 0.014277 ± 0.000102144 (W 8.68003e-05) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017042 ± 1.52753e-05 (W 4.16917e-05) | 0.01086 ± 0.000261152 (W 0.000168645) | 0.009778 ± 0.000160594 (W 0.000209727) | 🔴 faer-fork 1.57× slower than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067706 ± 9e-05 (W 0.0014271) | 0.067737 ± 5.83981e-05 (W 0.00141722) | 0.081913 ± 0.00111483 (W 0.00165603) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.040155 ± 0.000527675 (W 0.00148669) | 0.040145 ± 0.00126497 (W 0.00144434) | 0.035907 ± 0.000319788 (W 0.000242074) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027912 ± 0.000253812 (W 0.000160873) | 0.027932 ± 3.05505e-05 (W 0.0001403) | 0.01644 ± 0.000152863 (W 0.000186183) | · | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067586 ± 3.05505e-05 (W 5.27257e-05) | 0.067626 ± 9.29157e-05 (W 5.50926e-05) | 0.083606 ± 0.00134592 (W 0.00121786) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.040786 ± 0.000518287 (W 0.000974991) | 0.039965 ± 0.00154417 (W 0.00229315) | 0.035356 ± 0.000460902 (W 0.000385183) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027752 ± 8.11193e-05 (W 0.000203475) | 0.027942 ± 4.3589e-05 (W 0.000220464) | 0.01625 ± 0.000239166 (W 0.000221507) | · | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.06912 ± 0.00312968 (W 0.000421047) | 1.07137 ± 0.00218562 (W 0.00152295) | 1.20555 ± 0.00359993 (W 0.00273379) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.309448 ± 0.00217024 (W 0.00409146) | 0.306202 ± 0.00167448 (W 0.0109644) | 0.34324 ± 0.00130205 (W 0.001825) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.241592 ± 0.0138149 (W 0.0267078) | 0.224579 ± 0.012059 (W 0.0370406) | 0.179725 ± 0.000953831 (W 0.00190683) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.06948 ± 0.00404331 (W 0.00104172) | 1.07021 ± 0.00276046 (W 0.00100366) | 1.20129 ± 0.00126979 (W 0.00213117) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.307725 ± 0.00396154 (W 0.0091925) | 0.306712 ± 0.00662627 (W 0.00917241) | 0.345153 ± 0.00300483 (W 0.00186684) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.284381 ± 1.23021 (W 0.0319931) | 0.234948 ± 0.0186901 (W 0.0301139) | 0.178373 ± 0.00224818 (W 0.00118338) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27796 ± 0.00459497 (W 0.00566125) | 4.28518 ± 0.00645472 (W 0.00737591) | 5.12513 ± 0.0195991 (W 0.00890937) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.11048 ± 0.00308611 (W 0.00110239) | 1.10688 ± 0.00151318 (W 0.000762901) | 1.81608 ± 0.0176641 (W 0.00553791) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.608335 ± 0.00083379 (W 0.00203246) | 0.608034 ± 0.000155095 (W 0.0017457) | 0.70122 ± 0.0121841 (W 0.00356905) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27951 ± 0.00141702 (W 0.00191055) | 4.28075 ± 0.00441533 (W 0.00810172) | 5.16485 ± 0.0355115 (W 0.00853935) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.10908 ± 0.0010508 (W 0.00188191) | 1.1078 ± 0.00166026 (W 0.00180991) | 1.79787 ± 0.0244829 (W 0.00914222) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.608977 ± 0.000762698 (W 0.00206857) | 0.608767 ± 0.00148785 (W 0.0017992) | 0.681403 ± 0.0127499 (W 0.00211169) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26118 ± 0.0691806 (W 0.00394706) | 1.26556 ± 0.0595041 (W 0.00389182) | 1.65459 ± 0.0849987 (W 0.00472828) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.07369 ± 0.00593235 (W 0.00619624) | 1.07362 ± 0.00502899 (W 0.00706871) | 1.52419 ± 0.0119971 (W 0.0103601) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08591 ± 0.0039846 (W 0.00190995) | 1.08453 ± 0.0020519 (W 0.000775817) | 1.55518 ± 0.00515672 (W 0.00332191) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.425374 ± 0.00271952 (W 0.00411605) | 0.424893 ± 0.000175021 (W 0.00498787) | 0.420186 ± 0.00523037 (W 0.00364568) | · | · |  |
| `gemm/4096x16x240/b1` | 0.304239 ± 0.00238973 (W 0.00202032) | 0.303396 ± 0.00185676 (W 0.00232544) | 0.4291 ± 0.00340226 (W 0.00179378) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.303537 ± 0.00146862 (W 0.00357419) | 0.300932 ± 0.00266812 (W 0.00232222) | 0.387945 ± 0.00270498 (W 0.00212223) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.424151 ± 0.00257774 (W 0.00454024) | 0.425093 ± 0.00337274 (W 0.00504395) | 0.261097 ± 0.00437831 (W 0.00300521) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.189344 ± 0.00129862 (W 0.00529403) | 0.185676 ± 0.00694458 (W 0.00407777) | 0.287477 ± 0.000619208 (W 0.00249445) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.198581 ± 0.00654749 (W 0.00623504) | 0.20293 ± 0.00362223 (W 0.00671821) | 0.197028 ± 0.00695001 (W 0.00147696) | · | · | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.01629 ± 0.0206236 (W 0.00213017) | 1.01924 ± 0.00286742 (W 0.0032687) | 2.61481 ± 0.020235 (W 0.00809985) | · | 🔵 faer-fork 2.57× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.09515 ± 0.00873774 (W 0.0032688) | 1.09719 ± 0.00886717 (W 0.00127091) | 1.51458 ± 0.0282711 (W 0.0269779) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.11673 ± 0.00926019 (W 0.00158428) | 1.11429 ± 0.00783145 (W 0.00269035) | 1.23372 ± 0.0253353 (W 0.00273802) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.713441 ± 0.00598227 (W 0.00407972) | 0.709373 ± 0.0141729 (W 0.00475786) | 0.646668 ± 0.00428467 (W 0.00275171) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.296663 ± 0.00201209 (W 0.00280283) | 0.29466 ± 0.000446643 (W 0.00231778) | 0.429481 ± 0.00162171 (W 0.00426511) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.298558 ± 0.00208471 (W 0.00288551) | 0.296314 ± 0.00244366 (W 0.00146454) | 0.33221 ± 0.000811514 (W 0.00190535) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.15299 ± 0.0114091 (W 0.0127483) | 1.14244 ± 0.01047 (W 0.0204422) | 0.347408 ± 0.00178176 (W 0.00251235) | · | 🔴 faer-fork 3.32× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.180527 ± 0.00414111 (W 0.00291981) | 0.180126 ± 0.00317464 (W 0.0035715) | 0.29452 ± 0.00374209 (W 0.001646) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.156803 ± 0.000874786 (W 0.00152615) | 0.156712 ± 0.000520885 (W 0.0012095) | 0.172623 ± 0.00117632 (W 0.00119054) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.13834 ± 0.0145105 (W 0.00437172) | 4.13372 ± 0.0105469 (W 0.00614431) | 5.7401 ± 0.0288588 (W 0.0134441) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.37398 ± 0.0346563 (W 0.00884342) | 4.38848 ± 0.0468315 (W 0.00437066) | 5.65713 ± 0.344087 (W 0.0449604) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 4.3842 ± 0.00989805 (W 0.00501745) | 4.39939 ± 0.005622 (W 0.00278248) | 5.24048 ± 0.0129224 (W 0.0108502) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.66513 ± 0.00902757 (W 0.004272) | 1.65415 ± 0.00227412 (W 0.00348473) | 1.93329 ± 0.033623 (W 0.0075261) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.13984 ± 0.00539479 (W 0.00370754) | 1.14133 ± 0.00713215 (W 0.00425343) | 2.09991 ± 0.231878 (W 0.00829567) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 1.12679 ± 0.000234628 (W 0.00378186) | 1.12653 ± 0.00251615 (W 0.00257409) | 2.07489 ± 0.0125535 (W 0.00532139) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.898225 ± 0.00359353 (W 0.0058506) | 0.905061 ± 0.00532463 (W 0.0059494) | 0.943643 ± 0.00798658 (W 0.00475673) | · | · |  |
| `gemm/4096x16x240/b1` | 0.592816 ± 0.00668123 (W 0.00161851) | 0.595552 ± 0.00472369 (W 0.00368995) | 0.988545 ± 0.00668651 (W 0.00401694) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.607323 ± 0.0152135 (W 0.0136344) | 0.614818 ± 0.00437891 (W 0.0117421) | 0.758566 ± 0.0054864 (W 0.00292318) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.06833 ± 0.0255539 (W 0.00272485) | 4.07733 ± 0.00683273 (W 0.00725585) | 5.72409 ± 0.0487409 (W 0.0125133) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.36279 ± 0.0118327 (W 0.00528445) | 4.36637 ± 0.0171475 (W 0.00488745) | 5.67526 ± 0.0281493 (W 0.0405542) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.43576 ± 0.00656976 (W 0.0043048) | 4.43324 ± 0.00776513 (W 0.00837873) | 5.86091 ± 0.13993 (W 0.0188101) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.94872 ± 0.00347772 (W 0.0132435) | 1.94012 ± 0.00477799 (W 0.00479356) | 21.4055 ± 5.19805 (W 0.0294622) | · | 🔵 faer-fork 10.98× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.14427 ± 0.00347644 (W 0.00226935) | 1.14441 ± 0.00645384 (W 0.00302546) | 2.3672 ± 0.0758601 (W 0.0984983) | · | 🔵 faer-fork 2.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.17372 ± 0.0124493 (W 0.00753857) | 1.17853 ± 0.0102887 (W 0.00735779) | 2.05483 ± 0.0310724 (W 0.00905617) | · | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.58015 ± 0.00819798 (W 0.0263808) | 2.57699 ± 0.00556641 (W 0.0226064) | 10.2938 ± 2.60671 (W 0.0119792) | · | 🔵 faer-fork 3.99× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.594669 ± 0.0010089 (W 0.00594329) | 0.598617 ± 0.00476481 (W 0.0029015) | 1.54818 ± 0.0570205 (W 0.0537626) | · | 🔵 faer-fork 2.60× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.575274 ± 0.00186007 (W 0.00394096) | 0.582368 ± 0.00575461 (W 0.00424751) | 1.14185 ± 0.0208341 (W 0.0550982) | · | 🔵 faer-fork 1.98× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.13282 ± 0.013248 (W 0.00319528) | 1.12436 ± 0.0112343 (W 0.00271041) | 1.23749 ± 0.00270178 (W 0.00264144) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.29488 ± 0.00143276 (W 0.00207664) | 0.29496 ± 0.00152774 (W 0.00259924) | 0.328524 ± 0.00361648 (W 0.00225396) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.156943 ± 1.17603 (W 0.00188872) | 0.156533 ± 0.000527827 (W 0.00117235) | 0.170298 ± 0.00248228 (W 0.00177244) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08874 ± 0.00290371 (W 0.00316232) | 1.08636 ± 0.00548069 (W 0.00123218) | 1.54362 ± 0.0052834 (W 0.00429445) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.303966 ± 0.380497 (W 0.00262039) | 0.298738 ± 0.000948785 (W 0.00298156) | 0.387453 ± 0.00168541 (W 0.00278343) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.201055 ± 0.00297718 (W 0.00948255) | 0.195935 ± 0.00866284 (W 0.00833611) | 0.200975 ± 0.00273536 (W 0.00165413) | · | · | `!` between-start range over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.43209 ± 0.00333622 (W 0.00180846) | 4.44015 ± 0.00882807 (W 0.0114733) | 5.80171 ± 0.144671 (W 0.0209984) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.16257 ± 0.0162105 (W 0.00208565) | 1.15265 ± 0.013821 (W 0.00407983) | 2.06102 ± 0.0410903 (W 0.00762031) | · | 🔵 faer-fork 1.77× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.578068 ± 0.0037498 (W 0.00383945) | 0.578772 ± 0.00258879 (W 0.00304482) | 1.15331 ± 0.104311 (W 0.0288627) | · | 🔵 faer-fork 2.00× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.38869 ± 0.0134719 (W 0.00589385) | 4.39407 ± 0.00925064 (W 0.00735981) | 5.21995 ± 0.0271471 (W 0.0130229) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12664 ± 0.00238805 (W 0.00265459) | 1.12993 ± 0.00373156 (W 0.00310011) | 2.08457 ± 0.00606369 (W 0.00505994) | · | 🔵 faer-fork 1.85× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.615878 ± 0.0160502 (W 0.0157998) | 0.613274 ± 0.0182985 (W 0.0198392) | 0.761172 ± 0.00333476 (W 0.00277682) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014848 ± 0.00107032 (W 3.31662e-05) | 0.014818 ± 0.000105453 (W 3.2746e-05) | 0.017062 ± 4.04145e-05 (W 4.20714e-05) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.484444 ± 0.00315711 (W 0.0029704) | 0.485575 ± 0.00171495 (W 0.00166733) | 0.394737 ± 0.0011746 (W 0.00241739) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040355 ± 0.000136504 (W 8.54944e-05) | 0.040105 ± 0.000166626 (W 4.58716e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040436 ± 9.07377e-05 (W 7.10859e-05) | 0.040275 ± 0.000156195 (W 7.6565e-05) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.030837 ± 0.00016 (W 0.000193714) | 0.02673 ± 7.63763e-05 (W 0.00021025) | 0.043101 ± 0.000167989 (W 0.000162367) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.088906 ± 0.000188813 (W 0.000350229) | 0.130514 ± 0.000390662 (W 0.00121038) | 0.298227 ± 0.133305 (W 0.00150764) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 3.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n64/b1` | 0.03197 ± 0.000356469 (W 0.0010955) | 0.027561 ± 6.55769e-05 (W 9.3473e-05) | 0.043301 ± 0.00017091 (W 9.12705e-05) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.914545 ± 0.00370333 (W 0.000921956) | 0.912962 ± 0.010851 (W 0.00194308) | 0.719211 ± 0.00400611 (W 0.00300638) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.519449 ± 0.00324626 (W 0.00154868) | 0.518507 ± 0.00143171 (W 0.00187002) | 0.265736 ± 0.000841902 (W 0.00151195) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016781 ± 0.00114845 (W 2.89517e-05) | 0.014797 ± 6.1403e-05 (W 3.50714e-05) | 0.016872 ± 5.7735e-05 (W 5.77694e-05) | 🔴 faer-fork 1.13× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.480917 ± 0.000648364 (W 0.00188483) | 0.485065 ± 0.00265006 (W 0.00197501) | 0.272548 ± 0.000678986 (W 0.00116346) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020068 ± 0.000805663 (W 0.000215405) | 0.020097 ± 0.0010443 (W 0.000623753) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020178 ± 0.000215948 (W 0.000260892) | 0.020278 ± 0.000117189 (W 0.00035654) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.030717 ± 8.7178e-05 (W 0.000149697) | 0.030287 ± 0.000230804 (W 0.00142161) | 0.04294 ± 0.000330454 (W 0.000118133) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.088435 ± 0.000381912 (W 0.00123043) | 0.206305 ± 0.00261029 (W 0.00159533) | 0.066734 ± 0.000571836 (W 7.39074e-05) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.032571 ± 0.000456812 (W 9.88246e-05) | 0.031008 ± 0.000560063 (W 0.000875102) | 0.043071 ± 0.0001249 (W 0.000122915) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.909015 ± 0.00456336 (W 0.00344727) | 0.909158 ± 0.00536568 (W 0.00143414) | 0.71148 ± 0.00139311 (W 0.00581839) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.51508 ± 0.00201275 (W 0.00226007) | 0.516012 ± 0.00101671 (W 0.00184816) | 0.269863 ± 0.000284427 (W 0.00135596) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.015038 ± 0.00111389 (W 3.33512e-05) | 0.014827 ± 2.00083e-05 (W 3.1305e-05) | 0.016871 ± 4.58258e-05 (W 5.74656e-05) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.480147 ± 0.002091 (W 0.00236106) | 0.483211 ± 0.00145422 (W 0.00188987) | 0.261969 ± 0.000880385 (W 0.001811) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014848 ± 0.00103759 (W 0.000317701) | 0.018875 ± 0.00101523 (W 0.000235585) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.016491 ± 0.000305452 (W 0.000586424) | 0.020689 ± 0.000167094 (W 0.000326831) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030827 ± 4.10731e-05 (W 0.00016514) | 0.030838 ± 0.00056417 (W 0.000412537) | 0.042809 ± 0.000350186 (W 0.000115656) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.093234 ± 0.000307106 (W 0.00135243) | 0.243965 ± 0.00521439 (W 0.00170027) | 0.066754 ± 0.000406532 (W 0.000179773) | 🔵 faer-fork 2.62× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.03227 ± 0.00032551 (W 0.00014458) | 0.031208 ± 0.000761264 (W 0.000345986) | 0.04322 ± 0.000481146 (W 0.000150054) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.913093 ± 0.00343503 (W 0.00239363) | 0.910741 ± 0.00732497 (W 0.00141546) | 0.695497 ± 0.00124937 (W 0.00450395) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.51502 ± 0.00197312 (W 0.00191868) | 0.517617 ± 0.000942106 (W 0.00245945) | 0.269864 ± 0.000812797 (W 0.0016503) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014548 ± 2.00083e-05 (W 3.56371e-05) | 0.014517 ± 0.000111355 (W 3.63318e-05) | 0.014177 ± 8.3865e-05 (W 6.01855e-05) | · | · | dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.484584 ± 0.00130629 (W 0.002806) | 0.485666 ± 0.00394198 (W 0.00194706) | 0.388506 ± 0.00118378 (W 0.00154455) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040185 ± 0.000220198 (W 6.83908e-05) | 0.040055 ± 0.000311856 (W 0.000114155) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040516 ± 0.000238517 (W 6.97438e-05) | 0.040065 ± 0.000133167 (W 9.20326e-05) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.025688 ± 0.000275136 (W 0.000222377) | 0.026068 ± 6.69104e-05 (W 0.000199595) | 0.033773 ± 8.747e-05 (W 0.000122479) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.074389 ± 0.00029365 (W 0.000182785) | 0.0752 ± 0.000506942 (W 0.00132043) | 0.289039 ± 0.000281356 (W 0.00107648) | · | 🔵 faer-fork 3.89× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.025968 ± 0.000281947 (W 0.000108075) | 0.026299 ± 0.000186566 (W 0.000173776) | 0.033322 ± 5.1316e-05 (W 0.00125318) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.960434 ± 0.00410594 (W 0.00129232) | 0.957245 ± 0.00498019 (W 0.00126303) | 0.695116 ± 0.004816 (W 0.00206305) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.540848 ± 0.00227967 (W 0.00179756) | 0.542113 ± 0.00139244 (W 0.00404236) | 0.254956 ± 0.000748981 (W 0.00153604) | · | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014537 ± 0.00101214 (W 3.63483e-05) | 0.014487 ± 0.00155048 (W 3.4831e-05) | 0.014276 ± 0.000115529 (W 7.57648e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.482211 ± 0.00125743 (W 0.00154567) | 0.482111 ± 0.00162968 (W 0.00191572) | 0.266087 ± 0.00164756 (W 0.00140236) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019476 ± 0.000201098 (W 0.000333363) | 0.018965 ± 0.000169214 (W 0.00037779) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.019517 ± 0.00019 (W 0.00041428) | 0.019046 ± 3.4356e-05 (W 0.000304269) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025497 ± 0.00011739 (W 0.00190254) | 0.029345 ± 0.000793545 (W 0.00107031) | 0.033653 ± 0.000171407 (W 6.36805e-05) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.072455 ± 0.000417689 (W 0.00136733) | 0.141594 ± 0.00210468 (W 0.00162958) | 0.057567 ± 0.000938153 (W 0.00122932) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.026069 ± 0.000564025 (W 0.000126215) | 0.029626 ± 0.000751995 (W 0.000458551) | 0.033212 ± 2.3094e-05 (W 0.000104672) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.953588 ± 0.00368112 (W 0.00252007) | 0.949932 ± 0.00259636 (W 0.00137267) | 0.657646 ± 0.0100208 (W 0.00223665) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.535901 ± 0.00190519 (W 0.00170885) | 0.537964 ± 0.00125461 (W 0.00200213) | 0.260345 ± 0.00155636 (W 0.00140781) | · | 🔴 faer-fork 2.06× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014617 ± 0.00101315 (W 0.00144944) | 0.014517 ± 0.00161111 (W 2.7098e-05) | 0.014306 ± 8.92767e-05 (W 5.26431e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.480266 ± 0.00125644 (W 0.00171024) | 0.483082 ± 0.000469416 (W 0.00148268) | 0.255457 ± 0.000780834 (W 0.00159506) | · | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014537 ± 0.000399184 (W 0.000254308) | 0.019506 ± 0.000221209 (W 0.000277679) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.014788 ± 0.000264513 (W 0.000283637) | 0.019186 ± 0.000456794 (W 0.00024521) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025628 ± 0.000104083 (W 0.000267587) | 0.029916 ± 0.000287855 (W 0.00120191) | 0.033583 ± 0.000351876 (W 0.000126954) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.072775 ± 0.000780811 (W 0.000361802) | 0.183944 ± 0.00672698 (W 0.00189758) | 0.057487 ± 0.000306014 (W 0.000125969) | 🔵 faer-fork 2.53× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n64/b1` | 0.026149 ± 0.000333182 (W 0.000143925) | 0.029796 ± 0.000211188 (W 0.0011047) | 0.033112 ± 0.000492191 (W 5.22705e-05) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.958528 ± 0.00451725 (W 0.00261057) | 0.962896 ± 0.00703859 (W 0.00277472) | 0.653058 ± 0.013091 (W 0.00286511) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537112 ± 0.00218486 (W 0.00208206) | 0.538104 ± 0.000458893 (W 0.00223608) | 0.259614 ± 0.000443074 (W 0.00136522) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030047 ± 6.02246e-05 (W 0.00011845) | 0.030217 ± 2.46374e-05 (W 0.0010712) | 0.051536 ± 0.001049 (W 0.00131116) | · | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.649451 ± 0.000838028 (W 0.00122613) | 0.649932 ± 0.000648637 (W 0.00183145) | 0.810892 ± 0.00102144 (W 0.00225465) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.159348 ± 0.000443306 (W 0.00129705) | 0.158826 ± 0.000654493 (W 0.000237083) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159387 ± 0.000202806 (W 0.00164421) | 0.159518 ± 0.000349287 (W 7.87547e-05) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.05889 ± 0.000502347 (W 0.000104428) | 0.052758 ± 0.00013 (W 0.000189901) | 0.09646 ± 0.00038648 (W 0.000149694) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.179785 ± 0.000401182 (W 0.0016827) | 0.237142 ± 0.000974947 (W 0.00251511) | 0.16612 ± 0.000274161 (W 0.00136686) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.061405 ± 0.000100732 (W 9.82258e-05) | 0.055393 ± 0.00031925 (W 0.00123865) | 0.094606 ± 6.68356e-05 (W 0.000188102) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22879 ± 0.00092578 (W 0.00160418) | 1.23398 ± 0.00654583 (W 0.00186042) | 1.33805 ± 0.00230376 (W 0.00280903) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.657466 ± 0.000987966 (W 0.00151832) | 0.656336 ± 0.00148401 (W 0.0013103) | 0.490176 ± 0.00138407 (W 0.00159064) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029985 ± 8.50314e-05 (W 0.000160777) | 0.030136 ± 4.6188e-05 (W 5.65685e-05) | 0.051195 ± 0.000436521 (W 0.00118261) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.619327 ± 0.00215302 (W 0.0024228) | 0.618854 ± 0.00242115 (W 0.00183015) | 0.565294 ± 0.00221075 (W 0.0021612) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060322 ± 0.000638352 (W 0.000326779) | 0.061354 ± 0.000453013 (W 0.00147041) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.060403 ± 0.000954254 (W 0.00113017) | 0.061495 ± 0.000672191 (W 0.00048704) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.05864 ± 8.75043e-05 (W 0.000261078) | 0.052619 ± 6.55006e-05 (W 0.00106437) | 0.095789 ± 0.000811364 (W 0.00106298) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.157234 ± 0.000859124 (W 0.00129586) | 0.285904 ± 0.00154103 (W 0.00122059) | 0.163846 ± 0.00022053 (W 0.0013548) | 🔵 faer-fork 1.82× faster than `faer-upstream` | · |  |
| `solve/n64/b1` | 0.061495 ± 0.000266896 (W 7.49613e-05) | 0.055253 ± 0.000252032 (W 0.000145915) | 0.093174 ± 0.000763143 (W 0.00162534) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.15508 ± 0.00317455 (W 0.0014922) | 1.15543 ± 0.00189895 (W 0.00171209) | 1.0928 ± 0.00622498 (W 0.0025165) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.658769 ± 0.00207365 (W 0.00184465) | 0.656554 ± 0.000667661 (W 0.00227457) | 0.491138 ± 0.00357121 (W 0.00175966) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030036 ± 4.93288e-05 (W 0.000117898) | 0.030096 ± 0.000105987 (W 8.80755e-05) | 0.051466 ± 0.000803419 (W 0.00109011) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.617612 ± 0.000822025 (W 0.00217755) | 0.619496 ± 0.000284427 (W 0.00186247) | 0.538776 ± 4.57202e-05 (W 0.00205306) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.036738 ± 0.000175519 (W 0.000410641) | 0.060452 ± 0.000251291 (W 0.000441154) | - | 🔵 faer-fork 1.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.03758 ± 0.000404353 (W 0.000262898) | 0.060634 ± 0.000604503 (W 0.000441533) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.05895 ± 4.04145e-05 (W 0.000168084) | 0.052618 ± 0.000275893 (W 0.000175129) | 0.096229 ± 0.000196571 (W 0.00108854) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.159157 ± 0.00040104 (W 0.00115666) | 0.318424 ± 0.00685414 (W 0.00722554) | 0.163836 ± 0.000217869 (W 0.00126971) | 🔵 faer-fork 2.00× faster than `faer-upstream` | · |  |
| `solve/n64/b1` | 0.061485 ± 0.000377338 (W 0.000121737) | 0.055223 ± 0.000250034 (W 0.000349683) | 0.092993 ± 0.00044867 (W 0.00138294) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.15181 ± 0.00500176 (W 0.00186304) | 1.16021 ± 0.00166179 (W 0.00135955) | 1.05946 ± 0.00300924 (W 0.00349246) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.660823 ± 0.00120535 (W 0.00446124) | 0.657087 ± 0.00106228 (W 0.00196829) | 0.490766 ± 0.00169983 (W 0.00191699) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029505 ± 0.000209381 (W 0.000125758) | 0.029866 ± 0.000136137 (W 8.92737e-05) | 0.043672 ± 0.000561517 (W 0.000150987) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.64881 ± 0.000646194 (W 0.00158476) | 0.649782 ± 0.000942714 (W 0.00124112) | 0.798109 ± 0.000638357 (W 0.00236238) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157474 ± 0.000460393 (W 0.00115392) | 0.156883 ± 0.000621613 (W 0.0021429) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.157925 ± 0.00017674 (W 0.00146015) | 0.157585 ± 0.000623299 (W 0.00129967) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.051757 ± 0.000346012 (W 0.00139119) | 0.051225 ± 7.55667e-05 (W 0.000143235) | 0.08563 ± 0.000165995 (W 0.00101717) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.16095 ± 0.0011017 (W 0.0012337) | 0.162954 ± 0.00100876 (W 0.000365553) | 0.754788 ± 0.000775925 (W 0.00124329) | · | 🔵 faer-fork 4.69× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.0539 ± 0.000216002 (W 0.00100235) | 0.05335 ± 0.000195031 (W 9.12316e-05) | 0.083225 ± 5.85947e-05 (W 0.000149179) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25884 ± 0.000638405 (W 0.00117173) | 1.26198 ± 0.00473956 (W 0.00199535) | 1.31039 ± 0.0035168 (W 0.00266696) | · | · |  |
| `svd_values/n64/b1` | 0.633151 ± 0.000953437 (W 0.00159681) | 0.631419 ± 0.00132922 (W 0.00163209) | 0.480358 ± 0.000499952 (W 0.00155142) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029485 ± 0.000171144 (W 0.000127657) | 0.029665 ± 0.000215484 (W 7.83658e-05) | 0.044783 ± 0.000633091 (W 0.00146077) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.618053 ± 0.000782418 (W 0.00174326) | 0.618015 ± 0.000343961 (W 0.00242942) | 0.554564 ± 0.00397381 (W 0.00234655) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060993 ± 5.11892e-05 (W 0.000341397) | 0.060252 ± 0.000336018 (W 0.00110484) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.061415 ± 0.000548024 (W 0.000377632) | 0.060663 ± 0.000195594 (W 0.00113584) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.051457 ± 0.000146186 (W 0.000152863) | 0.051085 ± 4.10731e-05 (W 0.000173344) | 0.085279 ± 9.84886e-05 (W 0.000154658) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.137166 ± 0.00113795 (W 0.000714162) | 0.207437 ± 0.00114169 (W 0.00117932) | 0.15526 ± 0.000233232 (W 0.00122429) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.054442 ± 0.000157735 (W 0.00144862) | 0.053861 ± 0.000497856 (W 7.35139e-05) | 0.083095 ± 4.72582e-05 (W 0.000122447) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.18483 ± 0.00100118 (W 0.00121898) | 1.18594 ± 0.00186908 (W 0.00118547) | 1.00979 ± 0.00192092 (W 0.00170596) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.633592 ± 0.000553531 (W 0.00208699) | 0.631758 ± 0.0012729 (W 0.0017196) | 0.480267 ± 0.000619377 (W 0.00175225) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029415 ± 0.000110259 (W 9.72173e-05) | 0.029285 ± 0.000281704 (W 7.96699e-05) | 0.043351 ± 0.000379018 (W 0.000269902) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.617263 ± 0.000907629 (W 0.00241953) | 0.620068 ± 0.000595893 (W 0.00174849) | 0.526542 ± 0.00158619 (W 0.00155602) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.037801 ± 0.000177455 (W 0.000271204) | 0.060173 ± 0.000214888 (W 0.000320555) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.038252 ± 0.00036332 (W 0.00123252) | 0.060723 ± 0.00051715 (W 0.000347541) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.051767 ± 0.000314325 (W 0.00011647) | 0.051035 ± 0.00022786 (W 0.000902725) | 0.085479 ± 0.000216002 (W 0.00167169) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.137456 ± 0.000968185 (W 0.000981854) | 0.247152 ± 0.00239002 (W 0.00206113) | 0.15522 ± 0.00016773 (W 0.00126684) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.05394 ± 0.000170119 (W 4.86446e-05) | 0.053289 ± 0.00115856 (W 0.000250043) | 0.082745 ± 0.000160053 (W 0.000217657) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.1797 ± 0.000536951 (W 0.00137987) | 1.19327 ± 0.00146632 (W 0.00176423) | 0.975049 ± 0.00117967 (W 0.00123435) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.633563 ± 0.00147666 (W 0.00162637) | 0.630927 ± 0.00102178 (W 0.00195603) | 0.479314 ± 0.00206417 (W 0.0019518) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/64`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.385258 ± 0.00321898 (W 0.0033924) | 0.381422 ± 0.0010209 (W 0.0016397) | 0.639192 ± 0.00274062 (W 0.025262) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.94279 ± 0.00362712 (W 0.010922) | 9.77182 ± 0.010887 (W 0.00528575) | 10.0141 ± 0.00919723 (W 0.00939627) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90098 ± 0.00410807 (W 0.00312979) | 1.91081 ± 0.00535809 (W 0.0027564) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.91223 ± 0.00646777 (W 0.00329797) | 1.91915 ± 0.00158754 (W 0.00413352) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.976634 ± 0.118777 (W 0.00478503) | 1.05069 ± 0.0104477 (W 0.00464074) | 0.964732 ± 0.00278808 (W 0.0020523) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.615 ± 0.00351273 (W 0.00339543) | 2.846 ± 0.00641412 (W 0.00929434) | 2.04065 ± 0.00581473 (W 0.00865102) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.988173 ± 0.143365 (W 0.00249816) | 1.05979 ± 0.147088 (W 0.00530872) | 0.966785 ± 0.00352345 (W 0.00142421) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n256/b1` | 18.4772 ± 0.025912 (W 0.0167814) | 18.4362 ± 0.048135 (W 0.015848) | 18.0335 ± 0.0429888 (W 0.0509762) | · | · |  |
| `svd_values/n256/b1` | 12.4682 ± 0.0159579 (W 0.0149158) | 12.4415 ± 0.0256756 (W 0.00841397) | 6.95911 ± 0.0752878 (W 0.00878562) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.349552 ± 0.0100378 (W 0.0202326) | 0.360393 ± 0.00563234 (W 0.0110425) | 0.408241 ± 0.00143034 (W 0.00404194) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.99794 ± 0.0124048 (W 0.00745582) | 6.82593 ± 0.0363891 (W 0.00941971) | 4.77658 ± 0.00637577 (W 0.0111889) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.522965 ± 0.00489538 (W 0.00335027) | 0.518437 ± 0.00466157 (W 0.00178196) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.518869 ± 0.00207188 (W 0.00269138) | 0.517585 ± 0.0026756 (W 0.00111249) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.770918 ± 0.00474934 (W 0.00283702) | 0.769575 ± 0.00901411 (W 0.010132) | 0.377364 ± 0.00302183 (W 0.0025276) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.14326 ± 0.00346329 (W 0.00127284) | 3.05279 ± 0.0334828 (W 0.0110464) | 0.671653 ± 0.00338937 (W 0.00265423) | 🔵 faer-fork 2.67× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.748077 ± 0.00465305 (W 0.0026416) | 0.715256 ± 0.00195298 (W 0.00822351) | 0.366595 ± 0.000741145 (W 0.0019944) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.2067 ± 0.0173411 (W 0.0200564) | 13.2281 ± 0.0146014 (W 0.01624) | 12.4378 ± 0.0224992 (W 0.018447) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.4812 ± 0.00741916 (W 0.0111183) | 10.4233 ± 0.0352102 (W 0.015427) | 6.10557 ± 0.00202539 (W 0.00833483) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.340946 ± 0.0104619 (W 0.0230305) | 0.348891 ± 0.0234479 (W 0.0223554) | 0.358599 ± 0.00153476 (W 0.00301082) | · | 🔵 faer-fork 1.05× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.77411 ± 0.00979168 (W 0.0174348) | 6.79084 ± 0.0395663 (W 0.0104066) | 3.9992 ± 0.00984284 (W 0.0175018) | · | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.280984 ± 0.00336408 (W 0.00312618) | 0.394495 ± 0.00404551 (W 0.0135264) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.283629 ± 0.00306077 (W 0.00368568) | 0.417499 ± 0.00519554 (W 0.0101012) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.772932 ± 0.00418431 (W 0.00158777) | 0.813538 ± 0.00325383 (W 0.018815) | 0.34817 ± 0.00306609 (W 0.00290858) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 2.22× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.10098 ± 0.00676033 (W 0.00249078) | 3.34764 ± 0.0487883 (W 0.0195522) | 0.57877 ± 0.00284547 (W 0.0024095) | 🔵 faer-fork 3.04× faster than `faer-upstream` | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.751263 ± 0.00652316 (W 0.00286339) | 0.732937 ± 0.0186545 (W 0.0224946) | 0.336367 ± 0.0023316 (W 0.00229427) | · | 🔴 faer-fork 2.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 12.9569 ± 0.0135942 (W 0.0138968) | 13.3034 ± 0.0138376 (W 0.0156415) | 11.4773 ± 0.473775 (W 0.0197247) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 10.562 ± 0.00824911 (W 0.0112472) | 10.5521 ± 0.0314119 (W 0.0222338) | 5.97497 ± 0.0239545 (W 0.00337751) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.322552 ± 0.0067318 (W 0.00249072) | 0.315439 ± 0.000560901 (W 0.00183318) | 0.458265 ± 0.00638855 (W 0.00318625) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.91435 ± 0.0302133 (W 0.011627) | 9.71098 ± 0.0280102 (W 0.0084524) | 9.80413 ± 0.0201654 (W 0.0105406) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.86784 ± 0.00317971 (W 0.00533036) | 1.87354 ± 0.0043486 (W 0.00464073) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.87939 ± 0.0071623 (W 0.00400175) | 1.88193 ± 0.00200321 (W 0.00396638) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.691622 ± 0.11716 (W 0.00370839) | 0.699927 ± 0.113996 (W 0.00346024) | 0.812438 ± 0.00298797 (W 0.00169174) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.37123 ± 0.00785423 (W 0.00241955) | 1.37628 ± 0.00610094 (W 0.00262405) | 1.88937 ± 0.00807953 (W 0.0101601) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.897907 ± 0.14061 (W 0.00336087) | 0.89987 ± 0.136185 (W 0.00326595) | 0.812987 ± 0.00225123 (W 0.00275397) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n256/b1` | 18.3827 ± 0.0379825 (W 0.0311622) | 18.3185 ± 0.0244257 (W 0.0134301) | 17.6362 ± 0.0302496 (W 0.0319705) | · | · |  |
| `svd_values/n256/b1` | 12.2575 ± 0.019729 (W 0.00935327) | 12.273 ± 0.00530194 (W 0.00830896) | 6.82188 ± 0.0118864 (W 0.00800233) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.292887 ± 0.00748608 (W 0.0121573) | 0.301483 ± 0.0103979 (W 0.008123) | 0.27865 ± 0.0273063 (W 0.0108541) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.94272 ± 0.00347955 (W 0.00759183) | 6.79833 ± 0.052722 (W 0.00979352) | 4.66942 ± 0.0158151 (W 0.00918633) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.517715 ± 0.00418182 (W 0.00205095) | 0.522495 ± 0.000461093 (W 0.00268805) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.520901 ± 0.0017941 (W 0.00316017) | 0.522135 ± 0.00207652 (W 0.00250902) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.685228 ± 0.00145578 (W 0.0019481) | 0.646105 ± 0.0073304 (W 0.0129114) | 0.336649 ± 0.00164662 (W 0.00168067) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.897125 ± 0.00484901 (W 0.00108392) | 1.29714 ± 0.0123231 (W 0.00463355) | 0.620649 ± 0.00269555 (W 0.00318182) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.660091 ± 0.00342408 (W 0.00412407) | 0.581224 ± 0.00582676 (W 0.0137311) | 0.319246 ± 0.00117069 (W 0.00174584) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.1127 ± 0.0199805 (W 0.012924) | 13.1188 ± 0.0157393 (W 0.012708) | 12.4074 ± 0.0152599 (W 0.0199604) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.2784 ± 0.00391377 (W 0.00973192) | 10.308 ± 0.0332878 (W 0.00824408) | 6.1073 ± 0.0380745 (W 0.00581364) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.276617 ± 0.00537799 (W 0.0237861) | 0.286103 ± 0.00185159 (W 0.0281154) | 0.274202 ± 0.0446549 (W 0.0044321) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.72393 ± 0.0110092 (W 0.0169948) | 6.69239 ± 0.0500516 (W 0.384697) | 3.90036 ± 0.00412577 (W 0.00800088) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.282507 ± 0.00314912 (W 0.0025127) | 0.378946 ± 0.0130827 (W 0.0151853) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.286735 ± 0.00194099 (W 0.00308382) | 0.397993 ± 0.0131943 (W 0.016123) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 0.686512 ± 0.00286856 (W 0.00227564) | 0.643602 ± 0.0213975 (W 0.0196647) | 0.319977 ± 0.00495595 (W 0.00245201) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.844527 ± 0.00777277 (W 0.00163983) | 1.60242 ± 0.0159141 (W 0.008766) | 0.546541 ± 0.00282569 (W 0.00312209) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.657837 ± 0.00101994 (W 0.00102686) | 0.599359 ± 0.0262468 (W 0.0239327) | 0.306491 ± 0.0049099 (W 0.00238564) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 12.8469 ± 0.0327787 (W 0.0195818) | 13.2031 ± 0.0514884 (W 0.046887) | 11.5404 ± 0.0718562 (W 0.0267573) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.3783 ± 0.00326318 (W 0.010787) | 10.3816 ± 0.00339225 (W 0.0130899) | 6.03942 ± 0.100941 (W 0.00678111) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.22808 ± 0.00215142 (W 0.00257163) | 1.21843 ± 0.00133496 (W 0.00193072) | 1.85636 ± 0.0127639 (W 0.00919633) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.6469 ± 0.0344602 (W 0.0117912) | 17.4421 ± 0.0571845 (W 0.00954919) | 26.4252 ± 0.0877546 (W 0.0343033) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.51086 ± 0.00927237 (W 0.00867734) | 7.49605 ± 0.0280016 (W 0.00404685) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.51638 ± 0.0129487 (W 0.00891336) | 7.51011 ± 0.00996349 (W 0.0145945) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.11754 ± 0.00219586 (W 0.00310364) | 2.21207 ± 0.0049556 (W 0.00327456) | 3.30201 ± 0.0338551 (W 0.0090048) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.80498 ± 0.0412693 (W 0.00338732) | 6.41666 ± 0.0089218 (W 0.00824319) | 5.66398 ± 0.0128433 (W 0.0131819) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.05472 ± 0.00253791 (W 0.00164855) | 2.14199 ± 0.00455841 (W 0.00466443) | 2.82428 ± 0.0014193 (W 0.00820573) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.921 ± 0.0920812 (W 0.061296) | 34.7441 ± 0.0576365 (W 0.0304314) | 43.766 ± 0.140822 (W 0.0194915) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 20.0371 ± 0.0702867 (W 0.0159028) | 20.024 ± 0.0898636 (W 0.0104984) | 18.0987 ± 0.0180125 (W 0.0221282) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.820972 ± 0.00280669 (W 0.0053024) | 0.800722 ± 0.0135124 (W 0.00734658) | 0.791859 ± 0.00141714 (W 0.00526484) | · | · |  |
| `eigh/n256/b1` | 11.6285 ± 0.0112511 (W 0.00442778) | 11.3778 ± 0.0278732 (W 0.00781806) | 10.1439 ± 0.0168819 (W 0.0101957) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92192 ± 0.00417672 (W 0.00321271) | 1.91369 ± 0.00776899 (W 0.00183996) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92178 ± 0.00249791 (W 0.00168698) | 1.92645 ± 0.00945167 (W 0.00277528) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.50252 ± 0.00434721 (W 0.0144405) | 1.55773 ± 0.0069206 (W 0.0165451) | 1.01672 ± 0.00413169 (W 0.00197108) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.53031 ± 0.00327963 (W 0.00374437) | 4.72144 ± 0.0543801 (W 0.0179595) | 1.63106 ± 0.0031059 (W 0.00339009) | 🔵 faer-fork 1.87× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.39741 ± 0.00269735 (W 0.0154956) | 1.43973 ± 0.013777 (W 0.0118691) | 0.895491 ± 0.00614843 (W 0.00373728) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.3651 ± 0.135688 (W 0.0263068) | 22.1542 ± 0.164375 (W 0.0366811) | 21.2994 ± 0.0811257 (W 0.0299178) | · | · |  |
| `svd_values/n256/b1` | 17.0849 ± 0.14396 (W 0.0187523) | 17.0924 ± 0.0609256 (W 0.0227183) | 11.0187 ± 0.252416 (W 0.0347248) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.799792 ± 0.00140229 (W 0.0108748) | 0.788622 ± 0.0176424 (W 0.0153367) | 0.656726 ± 0.00644718 (W 0.00396617) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.9365 ± 0.0131197 (W 0.01503) | 11.2251 ± 0.0107578 (W 0.0276224) | 8.00156 ± 0.0297905 (W 0.0196192) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00258 ± 0.00545035 (W 0.00316317) | 1.13336 ± 0.0860387 (W 0.0948066) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.00688 ± 0.00121256 (W 0.00338105) | 1.29629 ± 0.0976798 (W 0.0973629) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 1.41952 ± 0.00864651 (W 0.0140438) | 1.45072 ± 0.0406838 (W 0.00656808) | 0.695679 ± 0.00580197 (W 0.0046969) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.11295 ± 0.00541305 (W 0.00291857) | 4.80435 ± 0.0370981 (W 0.0179274) | 1.62267 ± 0.00446852 (W 0.00335949) | 🔵 faer-fork 2.27× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.29472 ± 0.0119987 (W 0.0107152) | 1.32019 ± 0.00258287 (W 0.0107649) | 0.663068 ± 0.00435686 (W 0.00180619) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.0761 ± 0.243014 (W 0.0422276) | 21.987 ± 0.254204 (W 0.0896238) | 17.1723 ± 0.0481054 (W 0.0209662) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.6534 ± 0.0798942 (W 0.0346958) | 16.8254 ± 0.21117 (W 0.0136666) | 9.62499 ± 0.0394871 (W 0.0258334) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.13626 ± 0.00222413 (W 0.00118552) | 1.1273 ± 0.00175138 (W 0.0016403) | 1.61883 ± 0.114227 (W 0.00344314) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 17.57 ± 0.0248612 (W 0.00831289) | 17.3176 ± 0.0325982 (W 0.0129236) | 26.1734 ± 0.102506 (W 0.0395914) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.43322 ± 0.0293899 (W 0.00824414) | 7.41775 ± 0.028338 (W 0.0062906) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44329 ± 0.0150347 (W 0.00640032) | 7.43764 ± 0.00694067 (W 0.00633995) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.00432 ± 0.0113438 (W 0.00162773) | 2.00041 ± 0.00668859 (W 0.00259238) | 3.16401 ± 0.00937496 (W 0.00760922) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.457 ± 0.0495881 (W 0.004522) | 4.53349 ± 0.0326694 (W 0.00354184) | 5.57484 ± 0.0130275 (W 0.012331) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93762 ± 0.00229935 (W 0.00181704) | 1.92849 ± 0.00420005 (W 0.00138405) | 2.73708 ± 0.0606783 (W 0.0081052) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.5472 ± 0.126316 (W 0.0182784) | 34.5156 ± 0.057541 (W 0.0311493) | 45.041 ± 1.21571 (W 0.0801972) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.7357 ± 0.105705 (W 0.0278327) | 19.6739 ± 0.0796538 (W 0.020295) | 19.7455 ± 1.04082 (W 0.0573901) | · | · | `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.722689 ± 0.00521389 (W 0.00495274) | 0.713561 ± 0.00247404 (W 0.00526871) | 0.604358 ± 0.0321955 (W 0.0147847) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 11.5361 ± 0.0125705 (W 0.00986298) | 11.3188 ± 0.00470023 (W 0.0127401) | 9.97574 ± 0.0225985 (W 0.0173349) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91069 ± 0.0098875 (W 0.00145281) | 1.91215 ± 0.00500398 (W 0.00166402) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.91635 ± 0.0101016 (W 0.00304137) | 1.91834 ± 0.00459848 (W 0.0018618) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.40256 ± 0.0097423 (W 0.0114013) | 1.3576 ± 0.0156491 (W 0.0154505) | 0.972125 ± 0.00330676 (W 0.00329761) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.22894 ± 0.0250993 (W 0.0030703) | 2.54907 ± 0.0164346 (W 0.0054851) | 1.58355 ± 0.0258581 (W 0.00403743) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.28773 ± 0.00120049 (W 0.0142647) | 1.23454 ± 0.0156883 (W 0.0133883) | 0.859193 ± 0.0198114 (W 0.00303264) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.9483 ± 0.09921 (W 0.0176582) | 22.1022 ± 0.0600512 (W 0.0225793) | 22.1684 ± 0.781126 (W 0.0195979) | · | · | `!` between-start range over 5% |
| `svd_values/n256/b1` | 16.6606 ± 0.144862 (W 0.0203742) | 16.6263 ± 0.0567573 (W 0.0184392) | 11.9097 ± 0.680498 (W 0.0170192) | · | 🔴 faer-fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.695357 ± 0.0148304 (W 0.0194941) | 0.698695 ± 0.00798176 (W 0.0134738) | 0.463104 ± 0.011106 (W 0.00467531) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.8051 ± 0.0164865 (W 0.0238489) | 11.1076 ± 0.0120188 (W 0.0315032) | 7.83697 ± 0.0228533 (W 0.0212677) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00806 ± 0.00970866 (W 0.00304043) | 1.12706 ± 0.00245876 (W 0.097332) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01139 ± 0.00751031 (W 0.00070716) | 1.15186 ± 0.0923712 (W 0.0972119) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 1.29895 ± 0.00615715 (W 0.00977696) | 1.25716 ± 0.000489609 (W 0.0083026) | 0.679499 ± 0.00134313 (W 0.00376128) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.78411 ± 0.00518507 (W 0.00235068) | 2.65134 ± 0.0360394 (W 0.0149142) | 1.5825 ± 0.0019981 (W 0.00335362) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.18859 ± 0.0100296 (W 0.00938922) | 1.13331 ± 0.00704972 (W 0.0140291) | 0.649532 ± 0.00329577 (W 0.00331046) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.6145 ± 0.250921 (W 0.149061) | 21.7721 ± 0.0445446 (W 0.0707317) | 17.1344 ± 0.0423518 (W 0.0246934) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.5928 ± 0.0392035 (W 0.0350334) | 16.6338 ± 0.187369 (W 0.0152047) | 9.61607 ± 0.0309627 (W 0.0134757) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/256`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.551689 ± 0.00319707 (W 0.00193241) | 0.553253 ± 0.00106006 (W 0.00222621) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.552179 ± 0.00256595 (W 0.00223492) | 0.552811 ± 0.00264839 (W 0.0017206) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.467393 ± 0.00184204 (W 0.00323904) | 0.468102 ± 0.014925 (W 0.00450851) | 0.661204 ± 0.134959 (W 0.00290081) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.05956 ± 0.00145229 (W 0.00271226) | 1.86356 ± 0.00759561 (W 0.00468867) | 0.90615 ± 0.00309463 (W 0.00243375) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50109 ± 0.00547575 (W 0.00316495) | 2.50061 ± 0.0018491 (W 0.00366972) | 3.04581 ± 0.00336762 (W 0.0054365) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48805 ± 0.00120463 (W 0.00260712) | 1.48527 ± 0.131491 (W 0.00567753) | 1.38369 ± 0.156608 (W 0.00434646) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.397261 ± 0.00660559 (W 0.00227263) | 0.155431 ± 0.00213024 (W 0.00151787) | - | 🔴 faer-fork 2.56× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.387813 ± 0.00206227 (W 0.00174133) | 0.156632 ± 0.0014057 (W 0.00136498) | - | 🔴 faer-fork 2.48× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.446273 ± 0.00375643 (W 0.00285505) | 0.440211 ± 0.00886678 (W 0.00306134) | 0.324776 ± 0.00131293 (W 0.00151788) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.00209 ± 0.0113371 (W 0.00239006) | 3.25626 ± 0.142487 (W 0.135244) | 0.452073 ± 0.000576569 (W 0.00341219) | 🔵 faer-fork 3.25× faster than `faer-upstream` | 🔴 faer-fork 2.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.27972 ± 0.0110953 (W 0.00497039) | 2.14441 ± 0.00296503 (W 0.00587232) | 2.15204 ± 0.215898 (W 0.00930056) | 🔴 faer-fork 1.06× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.43166 ± 0.0046647 (W 0.00581316) | 1.53067 ± 0.00326406 (W 0.00644685) | 0.945463 ± 0.143034 (W 0.00610533) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.410355 ± 0.0122496 (W 0.0064873) | 0.14446 ± 0.00317525 (W 0.00771202) | - | 🔴 faer-fork 2.84× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.41282 ± 0.0083798 (W 0.00597327) | 0.145611 ± 0.00521933 (W 0.0064677) | - | 🔴 faer-fork 2.84× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.446142 ± 0.00314162 (W 0.00174428) | 0.427106 ± 0.0056225 (W 0.00304494) | 0.310669 ± 0.00206884 (W 0.001266) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.05476 ± 0.00960677 (W 0.000985294) | 2.97312 ± 0.165346 (W 0.147042) | 0.320779 ± 0.00112584 (W 0.00214968) | 🔵 faer-fork 2.82× faster than `faer-upstream` | 🔴 faer-fork 3.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.35821 ± 0.0168539 (W 0.00463585) | 2.2531 ± 0.0100626 (W 0.00618276) | 2.01437 ± 0.249097 (W 0.00440897) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.49707 ± 0.010495 (W 0.00474203) | 1.63677 ± 0.005213 (W 0.00454289) | 0.817025 ± 0.189996 (W 0.000785514) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.5782 ± 0.0111701 (W 0.00175839) | 0.591443 ± 0.00986009 (W 0.0015809) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.571807 ± 0.0131722 (W 0.00180679) | 0.5735 ± 0.0159883 (W 0.00191344) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.384507 ± 0.0011266 (W 0.00126477) | 0.383786 ± 0.00116258 (W 0.00265282) | 0.285793 ± 0.000689031 (W 0.00183714) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.777109 ± 0.00187213 (W 0.00480721) | 0.778842 ± 0.00665229 (W 0.00279275) | 0.763364 ± 0.00126652 (W 0.00316515) | · | · |  |
| `svd_thin/1024x64/b1` | 2.4513 ± 0.00266748 (W 0.00263971) | 2.44312 ± 0.00125147 (W 0.00268814) | 2.8075 ± 0.00153021 (W 0.00545739) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.40112 ± 0.00328975 (W 0.0026693) | 1.39523 ± 0.00194263 (W 0.00357381) | 1.23754 ± 0.00369479 (W 0.00292654) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.395758 ± 0.0161322 (W 0.0016368) | 0.169196 ± 0.0155158 (W 0.00162226) | - | 🔴 faer-fork 2.34× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.401008 ± 0.015191 (W 0.00113274) | 0.174857 ± 0.0117879 (W 0.00139077) | - | 🔴 faer-fork 2.29× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.361565 ± 0.000385716 (W 0.00241655) | 0.35365 ± 0.0016019 (W 0.00336958) | 0.285373 ± 0.00205688 (W 0.00203965) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.736774 ± 0.00887197 (W 0.00317884) | 0.823747 ± 0.00681977 (W 0.00390185) | 0.414454 ± 0.00393015 (W 0.00492273) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.2274 ± 0.00225499 (W 0.00400299) | 2.08771 ± 0.00212397 (W 0.00558771) | 1.82572 ± 0.00432935 (W 0.0103313) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.35401 ± 0.00417395 (W 0.00168849) | 1.44764 ± 0.000955981 (W 0.00481153) | 0.905961 ± 0.00749264 (W 0.00668505) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.441163 ± 0.00143683 (W 0.00596336) | 0.181047 ± 0.00424908 (W 0.00613791) | - | 🔴 faer-fork 2.44× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.438427 ± 0.0123185 (W 0.00623617) | 0.188191 ± 0.0141354 (W 0.00552459) | - | 🔴 faer-fork 2.33× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.363659 ± 0.0012961 (W 0.00176665) | 0.351005 ± 0.0026357 (W 0.00367017) | 0.287095 ± 0.000802721 (W 0.00239587) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.782159 ± 0.00218453 (W 0.00277422) | 0.922891 ± 0.00687957 (W 0.00291298) | 0.302495 ± 0.00150314 (W 0.00337436) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 2.59× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.31318 ± 0.00211377 (W 0.00248017) | 2.19427 ± 0.00635753 (W 0.00551871) | 1.63418 ± 0.00539675 (W 0.00383014) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39984 ± 0.000446267 (W 0.00311551) | 1.54533 ± 0.00655545 (W 0.00552632) | 0.78802 ± 0.00211737 (W 0.00516368) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19622 ± 0.00285287 (W 0.00253015) | 2.23743 ± 0.00188819 (W 0.002201) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20061 ± 0.002863 (W 0.00284527) | 2.24028 ± 0.0246887 (W 0.00141206) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.992672 ± 0.00355008 (W 0.00321439) | 1.00025 ± 0.00240446 (W 0.00213915) | 1.22749 ± 0.251513 (W 0.00276904) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 2.55467 ± 0.0385869 (W 0.00219971) | 4.13354 ± 0.110433 (W 0.0107879) | 2.39835 ± 0.0163991 (W 0.00407334) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 5.99033 ± 0.0294179 (W 0.00280719) | 5.99766 ± 0.0301066 (W 0.00266083) | 9.72789 ± 0.117364 (W 0.0104729) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.07426 ± 0.0225284 (W 0.00294627) | 3.06638 ± 0.0134577 (W 0.0016552) | 3.80581 ± 0.0254388 (W 0.00575822) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.39352 ± 0.010711 (W 0.00243242) | 0.589068 ± 0.00954975 (W 0.00214647) | - | 🔴 faer-fork 2.37× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.39399 ± 0.0239608 (W 0.00233005) | 0.595521 ± 0.011836 (W 0.00263167) | - | 🔴 faer-fork 2.34× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.74496 ± 0.00303469 (W 0.00328682) | 0.740812 ± 0.00421635 (W 0.00482862) | 1.40957 ± 0.0039395 (W 0.00557575) | · | 🔵 faer-fork 1.89× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.30469 ± 0.00170189 (W 0.00475434) | 3.96236 ± 0.0501632 (W 0.0732637) | 1.3751 ± 0.00371214 (W 0.00257396) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.93021 ± 0.0106503 (W 0.00382826) | 3.67602 ± 0.0047244 (W 0.00578465) | 5.52727 ± 0.0224034 (W 0.0199745) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.86136 ± 0.00969508 (W 0.00634378) | 2.43363 ± 0.00478474 (W 0.00291633) | 3.22691 ± 0.242149 (W 0.0388382) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.38407 ± 0.0506224 (W 0.0287867) | 0.473814 ± 0.00669311 (W 0.0313306) | - | 🔴 faer-fork 2.92× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.40273 ± 0.0141972 (W 0.0321886) | 0.474896 ± 0.0477804 (W 0.0416761) | - | 🔴 faer-fork 2.95× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.703823 ± 0.00293235 (W 0.006331) | 0.700347 ± 0.00111851 (W 0.00245384) | 1.48348 ± 0.00867414 (W 0.00804645) | · | 🔵 faer-fork 2.11× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.3671 ± 0.00940977 (W 0.0113214) | 3.82621 ± 0.102394 (W 0.0432928) | 0.870824 ± 0.00299553 (W 0.00289784) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔴 faer-fork 2.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 4.92571 ± 0.029424 (W 0.143948) | 3.70076 ± 0.200408 (W 0.0253633) | 4.39317 ± 0.0112199 (W 0.00680475) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.90444 ± 0.0121795 (W 0.0083512) | 2.49701 ± 0.00182497 (W 0.010998) | 2.29059 ± 0.287863 (W 0.00440768) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.25361 ± 0.0163512 (W 0.0020013) | 2.27269 ± 0.0152864 (W 0.00201137) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26592 ± 0.0164605 (W 0.00222924) | 2.25803 ± 0.015611 (W 0.00272022) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.872637 ± 0.0020452 (W 0.00264938) | 0.872779 ± 0.00124808 (W 0.00259843) | 1.11304 ± 0.00785434 (W 0.00254142) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.25662 ± 0.0164929 (W 0.00646022) | 2.2585 ± 0.047856 (W 0.00354723) | 2.25695 ± 0.00863859 (W 0.00296135) | · | · |  |
| `svd_thin/1024x64/b1` | 5.8854 ± 0.0282437 (W 0.00370256) | 5.90457 ± 0.0237036 (W 0.00417863) | 8.55061 ± 0.0213774 (W 0.0147704) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.95325 ± 0.0170914 (W 0.00318475) | 2.95016 ± 0.00707728 (W 0.00608195) | 3.69344 ± 0.00963366 (W 0.00549034) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.45425 ± 0.00331332 (W 0.00260389) | 0.638762 ± 0.000155039 (W 0.00158703) | - | 🔴 faer-fork 2.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.45416 ± 0.0117162 (W 0.0029701) | 0.635465 ± 0.0118438 (W 0.0019705) | - | 🔴 faer-fork 2.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.638823 ± 0.00172176 (W 0.00304338) | 0.636507 ± 0.0012776 (W 0.00352498) | 1.06931 ± 0.00617107 (W 0.00407801) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.01781 ± 0.0148389 (W 0.00317424) | 1.58151 ± 0.0203804 (W 0.00427085) | 1.34156 ± 0.00226194 (W 0.00898427) | 🔴 faer-fork 1.28× slower than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.82569 ± 0.00573575 (W 0.0057511) | 3.57664 ± 0.0124453 (W 0.00647391) | 5.42258 ± 0.0211735 (W 0.00502008) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.77243 ± 0.00264013 (W 0.00605363) | 2.34268 ± 0.00266777 (W 0.00624514) | 2.79179 ± 0.0143289 (W 0.00572175) | 🔴 faer-fork 1.18× slower than `faer-upstream` | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.4326 ± 0.0111079 (W 0.0407668) | 0.529097 ± 0.0546927 (W 0.0463718) | - | 🔴 faer-fork 2.71× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.43075 ± 0.0114763 (W 0.0397747) | 0.531421 ± 0.00896138 (W 0.038728) | - | 🔴 faer-fork 2.69× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.595021 ± 0.00197188 (W 0.00282691) | 0.59524 ± 0.00388746 (W 0.00357925) | 1.10368 ± 0.00556308 (W 0.00344498) | · | 🔵 faer-fork 1.85× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.05869 ± 0.00292828 (W 0.00787449) | 1.65089 ± 0.0102159 (W 0.00572161) | 0.859533 ± 0.0009241 (W 0.00178466) | 🔴 faer-fork 1.25× slower than `faer-upstream` | 🔴 faer-fork 2.40× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.12867 ± 0.199818 (W 0.259445) | 3.58441 ± 0.0158426 (W 0.251933) | 4.37343 ± 0.00577146 (W 0.0048703) | 🔴 faer-fork 1.43× slower than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.81854 ± 0.00959258 (W 0.0116338) | 2.41102 ± 0.00329111 (W 0.00976102) | 2.29213 ± 0.00157044 (W 0.00360921) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `eigh/1024x64`, `householder_apply/1024x64`, `solve/1024x64`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.394697 ± 0.000877291 (W 0.00201219) | 0.511765 ± 0.00114446 (W 0.00330453) | 0.924676 ± 0.132373 (W 0.00317899) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 2.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.994657 ± 0.00335258 (W 0.0040716) | 1.01428 ± 0.0023495 (W 0.00414943) | 1.34111 ± 0.0030857 (W 0.00304187) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.44555 ± 0.00507203 (W 0.0022451) | 2.44124 ± 0.00539069 (W 0.00243364) | 4.16485 ± 0.138225 (W 0.00697963) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.4092 ± 0.00407247 (W 0.0034014) | 1.41041 ± 0.00273646 (W 0.00286018) | 2.59957 ± 0.0092855 (W 0.00587337) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.238524 ± 0.00526555 (W 0.0186313) | 0.34885 ± 0.00813864 (W 0.0171874) | 0.298808 ± 0.00932614 (W 0.00271073) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.612412 ± 0.00627142 (W 0.00529134) | 0.697891 ± 0.00315617 (W 0.00550184) | 0.426816 ± 0.00118624 (W 0.00233457) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.2275 ± 0.00601919 (W 0.00997087) | 2.09288 ± 0.00387451 (W 0.00924069) | 3.01745 ± 0.229709 (W 0.0114231) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.3669 ± 0.00135667 (W 0.00223986) | 1.46943 ± 0.00271289 (W 0.00435976) | 2.09562 ± 0.0089554 (W 0.0054836) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.21451 ± 0.000628382 (W 0.00140423) | 0.335025 ± 0.00297393 (W 0.00625259) | 0.168996 ± 0.000646707 (W 0.002) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.545918 ± 0.00574206 (W 0.00657574) | 0.739489 ± 0.00447673 (W 0.00655095) | 0.258102 ± 0.00245239 (W 0.00139598) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.30694 ± 0.00123417 (W 0.0479921) | 2.1837 ± 0.0106217 (W 0.00318283) | 3.19614 ± 0.0147512 (W 0.013392) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.41991 ± 0.00726143 (W 0.00320745) | 1.55654 ± 0.00523859 (W 0.00288206) | 2.06551 ± 0.0159918 (W 0.00647145) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.310579 ± 0.00204378 (W 0.00219575) | 0.31105 ± 0.00128377 (W 0.00232057) | 3.12737 ± 0.00200652 (W 0.00181914) | · | 🔵 faer-fork 10.07× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.563211 ± 0.00429801 (W 0.00206154) | 0.567478 ± 0.00685036 (W 0.00211933) | 6.29797 ± 0.00436074 (W 0.00406364) | · | 🔵 faer-fork 11.18× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.51608 ± 0.00580725 (W 0.00649258) | 2.51518 ± 0.00567939 (W 0.00440337) | 3.86603 ± 0.0188663 (W 0.0085979) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.47161 ± 0.000917388 (W 0.00458422) | 1.47015 ± 0.00696076 (W 0.00566688) | 2.43705 ± 0.0236451 (W 0.00322316) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.153597 ± 0.00336145 (W 0.0207026) | 0.158926 ± 0.0236204 (W 0.0203979) | 0.245097 ± 0.00515409 (W 0.00292584) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.20396 ± 0.00196351 (W 0.00114103) | 0.261207 ± 0.00119409 (W 0.00215271) | 0.368267 ± 0.0024978 (W 0.00167798) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.81× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.2938 ± 0.00300568 (W 0.00152166) | 2.15944 ± 0.00371479 (W 0.00582381) | 3.01933 ± 0.0930308 (W 0.00560106) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.41896 ± 0.00163336 (W 0.00310266) | 1.51987 ± 0.00405942 (W 0.00560193) | 2.05033 ± 0.0349813 (W 0.00333302) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.126376 ± 0.00140329 (W 0.00246191) | 0.137787 ± 0.00141866 (W 0.00292935) | 0.134931 ± 0.000492708 (W 0.00128066) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.158776 ± 0.000708568 (W 0.00100193) | 0.318855 ± 0.00469727 (W 0.00404568) | 0.216454 ± 0.000251615 (W 0.00218358) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.36828 ± 0.0041212 (W 0.00472978) | 2.27789 ± 0.0649222 (W 0.00874994) | 2.88486 ± 0.0806313 (W 0.00838873) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.46489 ± 0.008671 (W 0.00556603) | 1.60618 ± 0.0108643 (W 0.00435406) | 2.06879 ± 0.0324477 (W 0.0038357) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 1.00744 ± 0.00218734 (W 0.00345728) | 1.04746 ± 0.00306697 (W 0.00340566) | 2.3247 ± 0.00616123 (W 0.00332805) | · | 🔵 faer-fork 2.31× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.56728 ± 0.0166049 (W 0.00436897) | 2.60023 ± 0.0121652 (W 0.00589011) | 3.54468 ± 0.0427593 (W 0.00551707) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.94451 ± 0.0194689 (W 0.00298105) | 5.94212 ± 0.0226287 (W 0.00566078) | 12.8838 ± 0.0667326 (W 0.0670538) | · | 🔵 faer-fork 2.17× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.9436 ± 0.00310389 (W 0.00524127) | 2.94213 ± 0.00197565 (W 0.00633029) | 5.59088 ± 0.0445859 (W 0.00976168) | · | 🔵 faer-fork 1.90× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.512977 ± 0.0434751 (W 0.0522624) | 0.496627 ± 0.0522327 (W 0.040138) | 0.940375 ± 0.0103343 (W 0.00637207) | · | 🔵 faer-fork 1.83× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.984847 ± 0.00459149 (W 0.00406593) | 1.06627 ± 0.00321107 (W 0.00416027) | 1.35559 ± 0.00188808 (W 0.00395318) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.85761 ± 0.0142814 (W 0.00871197) | 3.59865 ± 0.00296286 (W 0.00529933) | 7.7307 ± 0.191863 (W 0.0753652) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.76487 ± 0.00460003 (W 0.00850685) | 2.3427 ± 0.000846235 (W 0.00486054) | 3.75593 ± 0.232465 (W 0.00561218) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.389507 ± 0.00602768 (W 0.0086807) | 0.445382 ± 0.00526012 (W 0.00117371) | 0.759376 ± 0.020354 (W 0.00355384) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.95× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.721336 ± 0.00164339 (W 0.00367454) | 1.03393 ± 0.00964175 (W 0.013641) | 0.761311 ± 0.00385894 (W 0.0016744) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.87044 ± 0.0181401 (W 0.261791) | 3.62706 ± 0.210812 (W 0.0362196) | 6.31183 ± 0.36637 (W 0.023598) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/64x1024/b1` | 2.81152 ± 0.008637 (W 0.0103388) | 2.38843 ± 0.00202223 (W 0.00835079) | 3.253 ± 0.0195861 (W 0.00886869) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.892574 ± 0.00316508 (W 0.00050151) | 0.891745 ± 0.00466768 (W 0.00489385) | 2.12037 ± 0.00133178 (W 0.00237365) | · | 🔵 faer-fork 2.38× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.21083 ± 0.00962655 (W 0.00279721) | 2.21659 ± 0.0083935 (W 0.00164785) | 16.8496 ± 0.0173878 (W 0.00579661) | · | 🔵 faer-fork 7.62× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 6.05129 ± 0.0245705 (W 0.00427368) | 6.04044 ± 0.0255021 (W 0.00505246) | 11.8182 ± 0.0689232 (W 0.019922) | · | 🔵 faer-fork 1.95× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 3.0672 ± 0.00592908 (W 0.00265463) | 3.06337 ± 0.00527966 (W 0.00167732) | 5.36417 ± 0.0145455 (W 0.0131491) | · | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.328713 ± 0.0530485 (W 0.0481109) | 0.331418 ± 0.0143897 (W 0.039782) | 0.585381 ± 0.00798788 (W 0.0038025) | · | 🔵 faer-fork 1.78× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.67036 ± 0.000445186 (W 0.00193812) | 0.719531 ± 0.00113584 (W 0.00172371) | 1.28409 ± 0.000747872 (W 0.00458451) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.92× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.97236 ± 0.0061369 (W 0.00872034) | 3.71465 ± 0.00552732 (W 0.00438797) | 7.53635 ± 0.312743 (W 0.0238064) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.89703 ± 0.0198344 (W 0.0062574) | 2.44289 ± 0.00899844 (W 0.00542353) | 3.77054 ± 0.0294672 (W 0.0117969) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.277679 ± 0.000536658 (W 0.00179362) | 0.274031 ± 0.00477676 (W 0.00570413) | 0.408262 ± 0.00334383 (W 0.00252622) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.422559 ± 0.00261555 (W 0.00227298) | 0.685349 ± 0.0115401 (W 0.0103032) | 0.70732 ± 0.00173826 (W 0.00242058) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.99871 ± 0.0454388 (W 0.288086) | 3.73424 ± 0.0126463 (W 0.0256314) | 6.28211 ± 0.0805126 (W 0.021449) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.91686 ± 0.036651 (W 0.0157187) | 2.48351 ± 0.0125713 (W 0.00468305) | 3.26283 ± 0.0472319 (W 0.0122615) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/64x1024`, `eigh/64x1024`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
