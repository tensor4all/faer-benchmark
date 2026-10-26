# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `1477bdfbd3d73d5935b2c3c408b3332e9929d943`
- t4a-faer version: `0.25.0`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `f37f989c38a5a0d6eba98e5ec7c9dd3c8078b726`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `3b1e821eb0f57375a9173dcfd5597ee8032224784b4a2b2d39ff058d0c2aae36`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-26T15:55:42.155023Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /home/shinaoka/projects/tensor4all/faer-0.25-cand --engines faer-fork,faer-upstream,lapack-mkl --aa 3 --reps 5 --prime-ms 250 --vendor mkl --no-publish --upstream extern/upstream-faer --label pair-cand-1 --threads 1,4,8 --dtypes f64,c64 --shapes 64,256,1024x64,64x1024,64x64x64,256x256x256,4096x64x64,16x4096x240,4096x16x240,64x64x4096 --families gemm,lu,qr_factor,cholesky,svd_values,svd_thin,eigh,householder_apply,solve`
- raw data: `data/results/zen5-cpu/faer-kernels/20261026T152757Z-pair-cand-1/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.94%, worst 1184.70% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 152 of 1152 engine cells exceed 5% and carry `!`; median within-process relative SD 0.37%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/64x64x64/b1` | 0.017092 ± 6.9282e-05 (W 3.36155e-05) | 0.017122 ± 4.56107e-05 (W 2.73861e-05) | 0.024326 ± 3.04467e-05 (W 4.85304e-05) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017172 ± 3.46458e-05 (W 3.27109e-05) | 0.019907 ± 0.000401374 (W 0.000855128) | 0.013986 ± 4.09512e-05 (W 0.000138669) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017122 ± 5.61278e-05 (W 4.219e-05) | 0.01077 ± 0.000259679 (W 0.00032159) | 0.009928 ± 4.95681e-05 (W 0.000109038) | 🔴 faer-fork 1.59× slower than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017212 ± 8.75233e-05 (W 3.24037e-05) | 0.017152 ± 4.82113e-05 (W 2.23607e-05) | 0.024325 ± 2.36714e-05 (W 2.82542e-05) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017132 ± 0.000100664 (W 2.60768e-05) | 0.018956 ± 0.000550002 (W 0.0010527) | 0.014287 ± 8.18535e-05 (W 7.67997e-05) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017122 ± 4.16333e-05 (W 2.62145e-05) | 0.01064 ± 0.000131607 (W 0.000246496) | 0.009959 ± 0.000114806 (W 0.00016072) | 🔴 faer-fork 1.61× slower than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067887 ± 0.000101129 (W 4.72229e-05) | 0.067616 ± 9.37248e-05 (W 4.9942e-05) | 0.083887 ± 0.00143377 (W 0.00151407) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.029745 ± 0.000160376 (W 0.000206355) | 0.040917 ± 0.000326083 (W 0.00180973) | 0.035958 ± 0.00039887 (W 0.000403667) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.028013 ± 6.7159e-05 (W 0.000231264) | 0.027913 ± 0.000164925 (W 0.00023355) | 0.016661 ± 0.000367075 (W 0.000256387) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067856 ± 4.07962e-05 (W 4.30116e-05) | 0.067757 ± 0.000116435 (W 8.87311e-05) | 0.082304 ± 0.000686152 (W 0.00102475) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.029755 ± 0.000115659 (W 0.000371219) | 0.040195 ± 0.00220281 (W 0.00183024) | 0.035827 ± 0.000405537 (W 0.000292682) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027923 ± 8.99463e-05 (W 0.000122956) | 0.028023 ± 0.000211069 (W 0.000222689) | 0.01646 ± 0.000226385 (W 0.000256555) | · | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07134 ± 0.00190697 (W 0.0018433) | 1.07297 ± 0.000937542 (W 0.000664356) | 1.20278 ± 0.00360389 (W 0.00212018) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.292157 ± 0.000892654 (W 0.00189414) | 0.305371 ± 0.00694926 (W 0.00878077) | 0.342143 ± 0.00103673 (W 0.0018595) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.166162 ± 0.00232494 (W 0.00163629) | 0.24468 ± 0.0229297 (W 0.0261311) | 0.178863 ± 0.000792229 (W 0.00163145) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.0703 ± 0.0030133 (W 0.00104204) | 1.0741 ± 0.00195164 (W 0.00156055) | 1.20356 ± 0.00216764 (W 0.00170963) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.290256 ± 0.000461455 (W 0.00192835) | 0.309519 ± 0.00237746 (W 0.0114819) | 0.342083 ± 0.00185436 (W 0.00137741) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.16567 ± 0.000409671 (W 0.00152296) | 0.255787 ± 0.0170818 (W 0.0153823) | 0.178553 ± 0.00234474 (W 0.00199398) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28122 ± 0.00808657 (W 0.00223941) | 4.27298 ± 0.00384074 (W 0.00317221) | 5.12458 ± 0.0518323 (W 0.010496) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.11115 ± 0.00247845 (W 0.00149233) | 1.10848 ± 0.00125044 (W 0.00259888) | 1.80868 ± 0.0155656 (W 0.00395082) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.581558 ± 0.0010948 (W 0.00211074) | 0.608123 ± 0.000937344 (W 0.00163817) | 0.696499 ± 0.0131981 (W 0.00222867) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27979 ± 0.0101351 (W 0.00295727) | 4.27474 ± 0.00758401 (W 0.00331229) | 5.20751 ± 0.0321151 (W 0.00705829) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.11144 ± 0.00233464 (W 0.000999231) | 1.10874 ± 0.0017579 (W 0.00119796) | 1.80181 ± 0.0142219 (W 0.004765) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.581334 ± 0.00164835 (W 0.00226554) | 0.606816 ± 0.000894608 (W 0.00226449) | 0.684757 ± 0.0130475 (W 0.00203306) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26742 ± 0.07171 (W 0.00360132) | 1.26992 ± 0.0706736 (W 0.00508229) | 1.64022 ± 0.0677234 (W 0.00667733) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.07597 ± 0.00754001 (W 0.00872617) | 1.07331 ± 0.00241181 (W 0.00835437) | 1.51943 ± 0.019038 (W 0.0144219) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08514 ± 0.00162628 (W 0.00123777) | 1.08471 ± 0.000685687 (W 0.00140121) | 1.55419 ± 0.00354943 (W 0.00324779) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.428128 ± 0.00234208 (W 0.00389532) | 0.426385 ± 0.00142196 (W 0.00319918) | 0.418674 ± 0.0103027 (W 0.00514324) | · | · |  |
| `gemm/4096x16x240/b1` | 0.306416 ± 0.00344317 (W 0.00269986) | 0.305084 ± 0.0033591 (W 0.00213298) | 0.42745 ± 0.00122035 (W 0.00271715) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.278411 ± 0.000269256 (W 0.00158778) | 0.300933 ± 0.00108031 (W 0.00200218) | 0.389196 ± 0.00161267 (W 0.00195953) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.429336 ± 0.00195845 (W 0.0036006) | 0.425493 ± 0.00325412 (W 0.00411065) | 0.264193 ± 0.00446853 (W 0.0035189) | · | 🔴 faer-fork 1.63× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.188612 ± 1.2858 (W 0.0050424) | 0.186841 ± 0.00654981 (W 0.00334453) | 0.287776 ± 0.000624 (W 0.00174084) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.142555 ± 0.00107508 (W 0.00065811) | 0.201259 ± 0.00311885 (W 0.00648748) | 0.196316 ± 0.000644795 (W 0.00118592) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.03481 ± 0.0178372 (W 0.0026917) | 1.01572 ± 0.0199054 (W 0.00256114) | 2.63752 ± 0.0130588 (W 0.00789494) | · | 🔵 faer-fork 2.55× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.09487 ± 0.00992077 (W 0.00225737) | 1.09593 ± 0.0081561 (W 0.00619177) | 1.5196 ± 0.025184 (W 0.0212323) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.11289 ± 0.0124715 (W 0.00110095) | 1.11733 ± 0.00796576 (W 0.00144408) | 1.22837 ± 0.0105583 (W 0.00366667) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.333035 ± 0.00221306 (W 0.00427703) | 0.719702 ± 0.00778601 (W 0.0071677) | 0.645995 ± 0.00305413 (W 0.0041633) | 🔵 faer-fork 2.16× faster than `faer-upstream` | 🔵 faer-fork 1.94× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.299418 ± 1.18029 (W 0.002383) | 0.293351 ± 0.0022711 (W 0.000548905) | 0.430058 ± 0.00153003 (W 0.00350318) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.297364 ± 0.00144819 (W 0.00202811) | 0.295521 ± 0.00126441 (W 0.00238929) | 0.33015 ± 0.00267527 (W 0.00214844) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.20739 ± 0.00135866 (W 0.00481536) | 1.14019 ± 0.010997 (W 0.0128047) | 0.353955 ± 0.00407641 (W 0.00322791) | 🔵 faer-fork 5.50× faster than `faer-upstream` | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.181221 ± 0.00294289 (W 0.00280198) | 0.181288 ± 0.00448115 (W 0.00511702) | 0.295716 ± 0.00313188 (W 0.0019572) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.157373 ± 0.00109598 (W 0.00190143) | 0.156431 ± 0.000785761 (W 0.00126991) | 0.172594 ± 0.00135425 (W 0.00149646) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.15381 ± 0.013216 (W 0.00512766) | 4.14382 ± 0.0202256 (W 0.0121766) | 5.73614 ± 0.0251976 (W 0.0105281) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.38103 ± 0.0408261 (W 0.00400482) | 4.37082 ± 0.0422137 (W 0.00307532) | 5.67059 ± 0.327789 (W 0.0319882) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 4.38748 ± 0.013584 (W 0.00442905) | 4.39814 ± 0.010181 (W 0.00469386) | 5.25829 ± 0.0101095 (W 0.00394193) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.65952 ± 0.00434281 (W 0.00414732) | 1.66184 ± 0.00137006 (W 0.00348178) | 1.94913 ± 0.00465054 (W 0.00385714) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.15864 ± 0.00563035 (W 0.00225994) | 1.15011 ± 0.00815393 (W 0.00448258) | 2.01647 ± 0.124412 (W 0.0208185) | · | 🔵 faer-fork 1.74× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.12326 ± 0.00129415 (W 0.00271207) | 1.12816 ± 0.00303808 (W 0.00237908) | 2.06261 ± 0.0144502 (W 0.00277037) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.926119 ± 0.0208625 (W 0.0216485) | 0.904587 ± 0.00210515 (W 0.00831779) | 0.946016 ± 0.00654122 (W 0.00325526) | · | · |  |
| `gemm/4096x16x240/b1` | 0.597993 ± 0.00430506 (W 0.00350946) | 0.598219 ± 0.000386544 (W 0.00179248) | 0.987478 ± 0.00938267 (W 0.0226684) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.571443 ± 0.00238922 (W 0.00214381) | 0.614124 ± 0.00845708 (W 0.011009) | 0.759937 ± 0.00622293 (W 0.00232537) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07648 ± 0.0159194 (W 0.00995089) | 4.06459 ± 0.0100408 (W 0.00383061) | 5.73387 ± 0.0743493 (W 0.008939) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.37485 ± 0.0186307 (W 0.0116955) | 4.37317 ± 0.0231119 (W 0.0046404) | 5.70139 ± 0.0390892 (W 0.0331365) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.43052 ± 0.00511188 (W 0.00327749) | 4.42696 ± 0.0077716 (W 0.00646568) | 5.84393 ± 0.0506227 (W 0.0234609) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.18464 ± 0.00516729 (W 0.00184851) | 1.95403 ± 0.00539449 (W 0.00657316) | 20.3962 ± 4.35029 (W 0.0192639) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 17.22× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.16043 ± 0.00458268 (W 0.00465588) | 1.15139 ± 0.00161143 (W 0.00173622) | 2.16789 ± 0.112351 (W 0.0721918) | · | 🔵 faer-fork 1.87× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.18575 ± 0.000911551 (W 0.012354) | 1.16978 ± 0.0137238 (W 0.0081495) | 2.05623 ± 0.0344146 (W 0.012627) | · | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.660971 ± 0.00367013 (W 0.00458201) | 2.59047 ± 0.00831719 (W 0.0217836) | 4.4222 ± 3.44945 (W 0.0175003) | 🔵 faer-fork 3.92× faster than `faer-upstream` | 🔵 faer-fork 6.69× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.60634 ± 0.00182179 (W 0.00449513) | 0.598991 ± 0.00344867 (W 0.00210432) | 1.52928 ± 0.048725 (W 0.00931066) | · | 🔵 faer-fork 2.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.579043 ± 0.00354339 (W 0.00458523) | 0.57762 ± 0.00374932 (W 0.00439031) | 1.18353 ± 0.119704 (W 0.0921892) | · | 🔵 faer-fork 2.04× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.13057 ± 0.0102556 (W 0.00189996) | 1.12872 ± 0.00994501 (W 0.00204013) | 1.23553 ± 0.00395471 (W 0.00230033) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.295693 ± 0.00266585 (W 0.00218396) | 0.295535 ± 0.000958313 (W 0.00150009) | 0.331588 ± 0.00244075 (W 0.00230305) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.157085 ± 0.000252631 (W 0.000974836) | 0.156382 ± 0.000644016 (W 0.001563) | 0.17174 ± 0.00154542 (W 0.00153472) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.09368 ± 0.0032665 (W 0.00246149) | 1.08768 ± 0.00252765 (W 0.00172637) | 1.55629 ± 0.003567 (W 0.00292994) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.277721 ± 0.000908058 (W 0.00158377) | 0.300923 ± 0.00386908 (W 0.00313318) | 0.385511 ± 0.00291003 (W 0.00185288) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.144381 ± 0.000917775 (W 0.00176778) | 0.200384 ± 0.00322289 (W 0.00792668) | 0.196317 ± 0.00212663 (W 0.00124989) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.43712 ± 0.00336444 (W 0.00657538) | 4.43195 ± 0.00216496 (W 0.00321735) | 5.81166 ± 0.035565 (W 0.0117772) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.17095 ± 0.0222155 (W 0.00339295) | 1.15465 ± 0.0118838 (W 0.00200368) | 2.07186 ± 0.0428602 (W 0.0194115) | · | 🔵 faer-fork 1.77× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.578432 ± 0.00623685 (W 0.00359951) | 0.579511 ± 0.0045584 (W 0.00384077) | 1.15107 ± 0.106422 (W 0.0306685) | · | 🔵 faer-fork 1.99× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.38816 ± 0.0172148 (W 0.00352662) | 4.39438 ± 0.0148027 (W 0.0042607) | 5.25366 ± 0.018702 (W 0.00900512) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12284 ± 0.00257939 (W 0.00185413) | 1.1252 ± 0.00125451 (W 0.00284931) | 2.08783 ± 0.00625741 (W 0.00355945) | · | 🔵 faer-fork 1.86× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.575992 ± 0.00175558 (W 0.00251705) | 0.589437 ± 0.0163337 (W 0.0134533) | 0.759916 ± 0.00441712 (W 0.00320262) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014878 ± 0.0012661 (W 2.80927e-05) | 0.017002 ± 0.00217171 (W 3.79104e-05) | 0.017192 ± 0.000168226 (W 6.20427e-05) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.48668 ± 0.00162221 (W 0.00185427) | 0.483477 ± 0.000717954 (W 0.00119564) | 0.395357 ± 0.000462217 (W 0.00148489) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040856 ± 7.37111e-05 (W 0.000106677) | 0.040125 ± 9.65419e-05 (W 0.000122222) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.041057 ± 0.000156142 (W 9.05666e-05) | 0.040446 ± 0.000174261 (W 6.81909e-05) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.030887 ± 0.000441102 (W 0.000285374) | 0.02669 ± 7.63763e-05 (W 0.000117601) | 0.04294 ± 0.000155522 (W 0.000137586) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.091079 ± 0.000252233 (W 0.00133449) | 0.129762 ± 2.19393e-05 (W 0.00118338) | 0.298506 ± 0.13332 (W 0.00133588) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 3.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n64/b1` | 0.03195 ± 8.5049e-05 (W 0.000113668) | 0.027722 ± 0.000187172 (W 0.000105187) | 0.043292 ± 5.87963e-05 (W 8.90292e-05) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.916519 ± 0.00131454 (W 0.00063694) | 0.918247 ± 0.0087658 (W 0.00136077) | 0.718098 ± 0.00226319 (W 0.0021178) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.519652 ± 0.00433024 (W 0.00160965) | 0.516713 ± 0.00364792 (W 0.00155851) | 0.265869 ± 0.000351543 (W 0.00167378) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016691 ± 0.001063 (W 4.87975e-05) | 0.012202 ± 0.00276179 (W 5.86362e-05) | 0.016852 ± 0.00015885 (W 7.65539e-05) | 🔴 faer-fork 1.37× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.487344 ± 0.00141072 (W 0.00213585) | 0.480406 ± 0.00259496 (W 0.00160575) | 0.271987 ± 0.000693372 (W 0.00164285) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020649 ± 0.000903486 (W 0.000182311) | 0.019717 ± 0.000686658 (W 0.000475005) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020849 ± 9.50438e-05 (W 0.000615521) | 0.020077 ± 0.000425089 (W 0.00181307) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.030837 ± 0.000115889 (W 0.000161479) | 0.030266 ± 0.00121887 (W 0.00122969) | 0.04279 ± 0.00010583 (W 0.00012341) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.094237 ± 0.000386218 (W 0.000155481) | 0.206055 ± 0.000970565 (W 0.00184095) | 0.067697 ± 0.00032741 (W 0.00015227) | 🔵 faer-fork 2.19× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.032812 ± 0.000233017 (W 0.000106768) | 0.031329 ± 0.000387467 (W 0.000786884) | 0.043111 ± 4.98029e-05 (W 0.000142791) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.923627 ± 0.00544678 (W 0.00222281) | 0.909491 ± 0.0046197 (W 0.00443264) | 0.702508 ± 0.003484 (W 0.00183027) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.516215 ± 0.000960004 (W 0.00173502) | 0.514973 ± 0.00123384 (W 0.00246481) | 0.271227 ± 0.00185703 (W 0.00152065) | · | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.015069 ± 0.00114052 (W 4.02032e-05) | 0.016911 ± 3.17857e-05 (W 3.39116e-05) | 0.016981 ± 8.00021e-05 (W 7.19027e-05) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.487521 ± 0.00107486 (W 0.0016767) | 0.481253 ± 0.00294929 (W 0.00204861) | 0.262783 ± 0.00141665 (W 0.00115528) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.015158 ± 0.00124699 (W 0.000223849) | 0.019296 ± 0.000605658 (W 0.000365322) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.016712 ± 0.000173494 (W 0.0004277) | 0.020359 ± 0.000181934 (W 0.000336634) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031249 ± 0.0001205 (W 0.00020204) | 0.030738 ± 0.000291411 (W 0.000191911) | 0.04291 ± 0.000153385 (W 0.000164901) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.096722 ± 0.000786232 (W 0.00174872) | 0.243806 ± 0.00130903 (W 0.00274172) | 0.067727 ± 0.000749125 (W 9.53373e-05) | 🔵 faer-fork 2.52× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.03215 ± 0.000297271 (W 8.80341e-05) | 0.03193 ± 0.000176627 (W 0.00151752) | 0.043231 ± 5.83124e-05 (W 7.73835e-05) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.923692 ± 0.00518176 (W 0.00310007) | 0.919554 ± 0.00489244 (W 0.00235921) | 0.693741 ± 0.00180855 (W 0.00319033) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.517147 ± 0.00148171 (W 0.00246317) | 0.516075 ± 0.00115235 (W 0.00218553) | 0.270596 ± 0.000678716 (W 0.00150608) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014938 ± 0.0012325 (W 4.02492e-05) | 0.016902 ± 0.0012403 (W 4.97996e-05) | 0.014347 ± 9.53939e-05 (W 7.70065e-05) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.487429 ± 0.000749575 (W 0.00141903) | 0.483348 ± 0.000262696 (W 0.00204764) | 0.389359 ± 0.00079794 (W 0.00231675) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040606 ± 0.000140119 (W 0.000103127) | 0.040255 ± 9.0185e-05 (W 9.39681e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040746 ± 9.53939e-05 (W 5.4123e-05) | 0.040215 ± 4.89932e-05 (W 6.42277e-05) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.025708 ± 0.000171144 (W 0.000150174) | 0.02613 ± 0.000200784 (W 0.00021304) | 0.033824 ± 6.12127e-05 (W 0.000164312) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.076203 ± 0.00059551 (W 0.00019715) | 0.074379 ± 0.000517168 (W 0.000235107) | 0.289262 ± 0.00028895 (W 0.00143312) | · | 🔵 faer-fork 3.80× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.02619 ± 8.41843e-05 (W 9.07193e-05) | 0.026409 ± 0.000142339 (W 5.96674e-05) | 0.033302 ± 0.000183413 (W 0.000123172) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.958738 ± 0.0015852 (W 0.000703608) | 0.957457 ± 0.00558636 (W 0.00075681) | 0.699348 ± 0.00530365 (W 0.00321144) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538904 ± 0.00417712 (W 0.00179366) | 0.53992 ± 0.00319764 (W 0.00201248) | 0.255368 ± 0.000290248 (W 0.00147655) | · | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016732 ± 0.00110814 (W 3.85136e-05) | 0.017031 ± 0.00322611 (W 1.86091e-05) | 0.014217 ± 4.99032e-05 (W 4.66905e-05) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.485651 ± 0.00127822 (W 0.00192272) | 0.481182 ± 0.000309013 (W 0.00150202) | 0.265408 ± 0.00113823 (W 0.00154232) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019687 ± 5.1316e-05 (W 0.000341395) | 0.019376 ± 0.000439436 (W 0.000382365) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.019907 ± 9.50438e-05 (W 0.000419996) | 0.019026 ± 0.000196054 (W 0.000169724) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025669 ± 8.22456e-05 (W 0.000161103) | 0.029586 ± 0.00110888 (W 0.00126472) | 0.033533 ± 7.50555e-05 (W 0.000137055) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.077646 ± 0.000705136 (W 0.00139377) | 0.14449 ± 0.00059419 (W 0.0018396) | 0.05843 ± 0.000281255 (W 0.00153157) | 🔵 faer-fork 1.86× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.02645 ± 0.00045975 (W 0.000151566) | 0.029856 ± 9.07377e-05 (W 0.000406897) | 0.033252 ± 0.000144684 (W 5.54076e-05) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.967725 ± 0.00476268 (W 0.00266304) | 0.954235 ± 0.00385632 (W 0.00365358) | 0.656167 ± 0.00597343 (W 0.0033138) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537378 ± 0.00106832 (W 0.00219281) | 0.535569 ± 0.000865416 (W 0.00213371) | 0.261269 ± 0.00102107 (W 0.00163346) | · | 🔴 faer-fork 2.06× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.015069 ± 0.0017985 (W 2.54421e-05) | 0.016982 ± 7.20208e-05 (W 3.85136e-05) | 0.014277 ± 8.05005e-05 (W 5.29934e-05) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.48776 ± 0.000348527 (W 0.00172775) | 0.482835 ± 0.00168898 (W 0.00136078) | 0.257071 ± 0.00131859 (W 0.00168663) | · | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.015128 ± 0.000214554 (W 0.000397575) | 0.019616 ± 8.20183e-05 (W 0.000278506) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.015309 ± 0.000118323 (W 0.000208196) | 0.019376 ± 0.000241475 (W 0.000282752) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026069 ± 0.000221678 (W 0.000224083) | 0.030597 ± 8.0829e-05 (W 0.000293026) | 0.033583 ± 0.00013 (W 0.000195298) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.077194 ± 0.000328406 (W 0.000226353) | 0.184714 ± 0.000992604 (W 0.00304115) | 0.057587 ± 0.000226232 (W 0.000257249) | 🔵 faer-fork 2.39× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.02647 ± 0.000205525 (W 0.000128496) | 0.030136 ± 0.000552981 (W 0.00106347) | 0.033212 ± 2.95014e-05 (W 8.9617e-05) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.967489 ± 0.00722977 (W 0.00267931) | 0.961283 ± 0.00430159 (W 0.00261913) | 0.655219 ± 0.0139494 (W 0.00484436) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537111 ± 0.000738547 (W 0.00177302) | 0.537565 ± 0.000130457 (W 0.00227274) | 0.259916 ± 0.000647562 (W 0.00119391) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030287 ± 0.000150766 (W 0.000116405) | 0.030337 ± 0.000299674 (W 8.82451e-05) | 0.050664 ± 0.000796048 (W 0.000254343) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.649349 ± 0.0011791 (W 0.00204869) | 0.648002 ± 0.00120069 (W 0.00179998) | 0.80982 ± 0.000568368 (W 0.00225501) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.160481 ± 0.000582275 (W 0.00152134) | 0.158857 ± 0.000463777 (W 0.00132789) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.16053 ± 0.000537422 (W 0.00131641) | 0.159577 ± 0.000233612 (W 0.00155163) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.060063 ± 0.000306627 (W 0.000705794) | 0.053329 ± 9.32577e-05 (W 0.000124809) | 0.09641 ± 0.000107058 (W 0.000146285) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.182942 ± 0.000413686 (W 0.00115685) | 0.238047 ± 0.000819614 (W 0.00188938) | 0.16606 ± 0.000134644 (W 0.0012069) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.061936 ± 0.000221886 (W 0.00124856) | 0.055624 ± 8.73689e-05 (W 0.000315585) | 0.094517 ± 7.95634e-05 (W 0.00147048) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2238 ± 0.00158601 (W 0.00273166) | 1.22012 ± 0.0031236 (W 0.00189555) | 1.33984 ± 0.00368138 (W 0.00261039) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.650571 ± 0.000858473 (W 0.00184735) | 0.651395 ± 0.000917389 (W 0.0018365) | 0.490605 ± 0.00186986 (W 0.0019266) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030427 ± 0.00025056 (W 0.000127065) | 0.030227 ± 7.15565e-05 (W 7.58175e-05) | 0.051937 ± 0.000445084 (W 0.00150933) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.648009 ± 0.00137808 (W 0.00321876) | 0.617314 ± 0.000612007 (W 0.00176896) | 0.565524 ± 0.000317835 (W 0.0022619) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060914 ± 0.000132035 (W 0.000378203) | 0.061174 ± 0.000181934 (W 0.000271859) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.060463 ± 0.000642325 (W 0.000393635) | 0.060523 ± 0.000436954 (W 0.000309977) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.059853 ± 0.000200502 (W 0.000431559) | 0.05343 ± 0.000180093 (W 0.000693355) | 0.09628 ± 0.000772167 (W 0.00113679) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.186417 ± 0.00121602 (W 0.00162595) | 0.287556 ± 0.00277888 (W 0.00139748) | 0.163847 ± 0.000329956 (W 0.00141299) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.062638 ± 0.000572015 (W 0.000261741) | 0.055694 ± 0.000840805 (W 0.00104101) | 0.092943 ± 0.000731375 (W 0.00178738) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22393 ± 0.00484395 (W 0.00169338) | 1.15037 ± 0.00163829 (W 0.00132147) | 1.09068 ± 0.00408396 (W 0.00286475) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.654143 ± 0.00122824 (W 0.00329954) | 0.653048 ± 0.00261401 (W 0.00211258) | 0.493253 ± 0.000995732 (W 0.00131923) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030467 ± 0.000155522 (W 8.10821e-05) | 0.030297 ± 0.000159897 (W 8.26438e-05) | 0.051245 ± 0.000365579 (W 0.00123242) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.646986 ± 0.00226428 (W 0.00193093) | 0.618881 ± 0.000959555 (W 0.00151759) | 0.53858 ± 0.00139288 (W 0.00213946) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.037039 ± 0.000150921 (W 0.000264447) | 0.060222 ± 0.000253154 (W 0.000136599) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.037149 ± 0.000301613 (W 0.000471097) | 0.060493 ± 0.000217869 (W 0.000844116) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.060863 ± 0.000651669 (W 0.000415505) | 0.05347 ± 0.000939591 (W 0.000690927) | 0.09629 ± 8.38272e-05 (W 0.000507935) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.188163 ± 0.000398499 (W 0.0015021) | 0.317352 ± 0.00698638 (W 0.00565804) | 0.163395 ± 0.000256602 (W 0.00130879) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.062628 ± 0.000225145 (W 0.000456052) | 0.055874 ± 0.000798985 (W 0.00072268) | 0.093505 ± 0.00036781 (W 0.00107637) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22369 ± 0.00179558 (W 0.00153662) | 1.15553 ± 0.00226219 (W 0.00156891) | 1.0582 ± 0.00436565 (W 0.00520335) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.652306 ± 0.00259104 (W 0.00174205) | 0.649244 ± 0.00126152 (W 0.00176926) | 0.490425 ± 0.00113286 (W 0.00163347) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029866 ± 0.000119459 (W 0.000216518) | 0.029996 ± 0.000298714 (W 7.96869e-05) | 0.043792 ± 0.000734352 (W 0.000123225) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.650082 ± 0.000728591 (W 0.00186551) | 0.647481 ± 0.000777504 (W 0.00119808) | 0.798438 ± 0.000394546 (W 0.00251698) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157885 ± 0.000232466 (W 0.00143888) | 0.157365 ± 5.31131e-05 (W 0.00131647) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158668 ± 0.000521692 (W 0.000213543) | 0.157623 ± 0.000436361 (W 0.000149185) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.053401 ± 0.000297766 (W 0.000480605) | 0.051647 ± 9.06661e-05 (W 0.000210306) | 0.086 ± 0.000281285 (W 0.00137879) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.164689 ± 0.000943067 (W 0.00138787) | 0.164347 ± 0.000850365 (W 0.00143448) | 0.755078 ± 5.70117e-05 (W 0.00170591) | · | 🔵 faer-fork 4.58× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.054742 ± 0.000173877 (W 0.000267563) | 0.05357 ± 8.73689e-05 (W 8.73281e-05) | 0.083216 ± 0.000135525 (W 0.00126315) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25334 ± 0.00303653 (W 0.00241685) | 1.25062 ± 0.00245551 (W 0.00269302) | 1.31079 ± 0.00111051 (W 0.00202785) | · | · |  |
| `svd_values/n64/b1` | 0.625757 ± 0.000572867 (W 0.00142272) | 0.626151 ± 0.000551337 (W 0.00146523) | 0.478846 ± 0.00153317 (W 0.00158789) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030157 ± 0.000201859 (W 6.71885e-05) | 0.029926 ± 0.000172143 (W 8.04363e-05) | 0.043812 ± 0.00104421 (W 0.000216689) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.646686 ± 0.0012244 (W 0.00292323) | 0.616493 ± 0.00119305 (W 0.00198728) | 0.555081 ± 0.000743547 (W 0.00117142) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060573 ± 0.000415761 (W 0.000511118) | 0.060473 ± 0.000412975 (W 0.000215147) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.060913 ± 0.000593023 (W 0.00153901) | 0.061035 ± 0.000493393 (W 0.000658665) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.053079 ± 0.000223383 (W 0.0010563) | 0.051677 ± 0.000312395 (W 0.00165866) | 0.08548 ± 9.95707e-05 (W 0.00164415) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.165391 ± 0.000859174 (W 0.000552484) | 0.210212 ± 0.00379103 (W 0.00249257) | 0.155831 ± 0.000241054 (W 0.00161731) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.055554 ± 0.000265513 (W 0.000253354) | 0.055283 ± 0.00122434 (W 0.00177869) | 0.082744 ± 0.000336705 (W 0.00236763) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25337 ± 0.00242727 (W 0.00155717) | 1.18386 ± 0.00090171 (W 0.00211494) | 1.00804 ± 0.000799164 (W 0.00139498) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.627326 ± 0.000702667 (W 0.00127601) | 0.626869 ± 0.00124581 (W 0.00216063) | 0.480719 ± 0.00182666 (W 0.00181414) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029916 ± 0.000139658 (W 0.000100598) | 0.030036 ± 0.000110092 (W 7.19458e-05) | 0.043392 ± 0.000195372 (W 0.000174972) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.648189 ± 0.00193882 (W 0.00220278) | 0.617983 ± 0.00145312 (W 0.00187758) | 0.526998 ± 0.00102502 (W 0.00220545) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.03727 ± 0.000221435 (W 0.000451908) | 0.060564 ± 0.000346367 (W 0.000248846) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.03769 ± 0.000423734 (W 0.000405907) | 0.060794 ± 1.52753e-05 (W 0.000385287) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.05325 ± 7.57188e-05 (W 0.000379287) | 0.051816 ± 0.00024216 (W 0.00072207) | 0.08549 ± 7.03586e-05 (W 0.000182144) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.164677 ± 0.000280716 (W 0.00185449) | 0.246042 ± 0.000872621 (W 0.00141508) | 0.15504 ± 0.000235204 (W 0.00128855) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.055283 ± 0.000221736 (W 0.000209608) | 0.053821 ± 0.000565546 (W 0.000567709) | 0.082845 ± 0.00018037 (W 0.000194819) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25459 ± 0.00801414 (W 0.00295262) | 1.18688 ± 0.00141486 (W 0.00229096) | 0.972914 ± 0.0010074 (W 0.00203536) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.629012 ± 0.00200069 (W 0.0025218) | 0.626872 ± 0.00116467 (W 0.00195848) | 0.479373 ± 0.00151341 (W 0.00146682) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/64`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.390358 ± 0.00524377 (W 0.00235717) | 0.386393 ± 0.00772121 (W 0.00204271) | 0.636384 ± 0.0017248 (W 0.0133656) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.98261 ± 0.0113033 (W 0.00683764) | 9.78563 ± 0.0136077 (W 0.0106817) | 10.012 ± 0.0167334 (W 0.0178392) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90764 ± 0.00330221 (W 0.00423029) | 1.91096 ± 0.00733828 (W 0.00389394) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.91185 ± 0.00558154 (W 0.00320222) | 1.9076 ± 0.00499971 (W 0.00238645) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.974803 ± 0.112825 (W 0.00244154) | 1.04484 ± 0.00908612 (W 0.0042587) | 0.967158 ± 0.00150883 (W 0.0015421) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.61932 ± 0.0016085 (W 0.0100897) | 2.84676 ± 0.00636826 (W 0.00779496) | 2.04549 ± 0.00867385 (W 0.00662304) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.98629 ± 0.139017 (W 0.00336588) | 1.06007 ± 0.146152 (W 0.00373283) | 0.969598 ± 0.00378259 (W 0.00290573) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n256/b1` | 18.5039 ± 0.00966971 (W 0.011391) | 18.4354 ± 0.0234452 (W 0.0156834) | 18.0617 ± 0.0826033 (W 0.0493323) | · | · |  |
| `svd_values/n256/b1` | 12.4669 ± 0.0176795 (W 0.0126701) | 12.4107 ± 0.00998887 (W 0.0165594) | 6.94753 ± 0.0118625 (W 0.00734741) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.296443 ± 0.00616454 (W 0.00256717) | 0.369831 ± 0.00688561 (W 0.0161904) | 0.4109 ± 0.00230738 (W 0.00262798) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.98793 ± 0.00663266 (W 0.0143324) | 6.75279 ± 0.0245595 (W 0.0158067) | 4.77494 ± 0.00958644 (W 0.00430954) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.521753 ± 0.00334721 (W 0.00224218) | 0.520223 ± 0.00276751 (W 0.00260785) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.526687 ± 0.0026922 (W 0.00169668) | 0.51494 ± 0.00156373 (W 0.00296777) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.666032 ± 0.00468653 (W 0.00451606) | 0.787877 ± 0.0145082 (W 0.0100268) | 0.378299 ± 0.00148588 (W 0.00298608) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.12835 ± 0.00375655 (W 0.00189812) | 3.09018 ± 0.0400949 (W 0.0184599) | 0.670734 ± 0.000743275 (W 0.00262628) | 🔵 faer-fork 2.74× faster than `faer-upstream` | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.637108 ± 0.00879365 (W 0.00405652) | 0.727293 ± 0.00992829 (W 0.00530943) | 0.366246 ± 0.000697668 (W 0.0018753) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3029 ± 0.0164191 (W 0.0112717) | 13.1989 ± 0.00765847 (W 0.0114039) | 12.4391 ± 0.0146995 (W 0.0168139) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.496 ± 0.0102052 (W 0.0116126) | 10.434 ± 0.0128495 (W 0.0119526) | 6.11246 ± 0.0116541 (W 0.0114619) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.306253 ± 0.00160117 (W 0.00234113) | 0.358172 ± 0.012355 (W 0.0154095) | 0.35979 ± 0.00204383 (W 0.00309417) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.77687 ± 0.0176545 (W 0.00913094) | 6.78533 ± 0.0249307 (W 0.0185504) | 3.99291 ± 0.0233607 (W 0.0102161) | · | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.284441 ± 0.00238394 (W 0.00142325) | 0.399886 ± 0.0107768 (W 0.0186767) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.284653 ± 0.00129308 (W 0.00229109) | 0.395558 ± 0.0057415 (W 0.0134985) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.639766 ± 0.00461643 (W 0.00225103) | 0.771028 ± 0.0196711 (W 0.0274815) | 0.345795 ± 0.00217157 (W 0.00547611) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔴 faer-fork 1.85× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.03043 ± 0.01377 (W 0.00111065) | 3.3448 ± 0.0190541 (W 0.00947531) | 0.580413 ± 0.000550815 (W 0.00262874) | 🔵 faer-fork 3.25× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.599568 ± 0.00599301 (W 0.00243786) | 0.739833 ± 0.0136616 (W 0.0229579) | 0.334314 ± 0.00175319 (W 0.00170541) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.9357 ± 0.018923 (W 0.0154055) | 13.2714 ± 0.0489797 (W 0.0178643) | 11.4824 ± 0.503566 (W 0.0247864) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 10.5722 ± 0.0111085 (W 0.0187567) | 10.5236 ± 0.00322741 (W 0.011253) | 5.99819 ± 0.0449125 (W 0.00833077) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.328623 ± 0.0042747 (W 0.001938) | 0.329839 ± 0.00370633 (W 0.00196589) | 0.45843 ± 0.00717874 (W 0.00309976) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.92676 ± 0.00896245 (W 0.00479473) | 9.74764 ± 0.0126876 (W 0.00703434) | 9.83716 ± 0.0113763 (W 0.00795471) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.88046 ± 0.0167269 (W 0.00127633) | 1.87641 ± 0.0101934 (W 0.00475998) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.88568 ± 0.00158813 (W 0.00443678) | 1.88157 ± 0.00970044 (W 0.00383682) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.696088 ± 0.115545 (W 0.00339535) | 0.703672 ± 0.113919 (W 0.00336604) | 0.812934 ± 0.00232752 (W 0.00342929) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.38443 ± 0.00732044 (W 0.00251242) | 1.36762 ± 0.0041457 (W 0.0021224) | 1.88957 ± 0.00642234 (W 0.00653333) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.903434 ± 0.140648 (W 0.00202127) | 0.903264 ± 0.13451 (W 0.00334957) | 0.811893 ± 0.00143211 (W 0.00262522) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n256/b1` | 18.3561 ± 0.0277222 (W 0.0235853) | 18.2799 ± 0.0644328 (W 0.0179324) | 17.6551 ± 0.018338 (W 0.0245079) | · | · |  |
| `svd_values/n256/b1` | 12.2487 ± 0.0300886 (W 0.00694244) | 12.2309 ± 0.0187111 (W 0.0201501) | 6.8129 ± 0.0157185 (W 0.0063107) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.243103 ± 0.0035115 (W 0.00192339) | 0.314089 ± 0.00336103 (W 0.0209588) | 0.270217 ± 0.00762963 (W 0.0136886) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.94745 ± 0.0161795 (W 0.0163162) | 6.71855 ± 0.0669183 (W 0.010141) | 4.6671 ± 0.00458829 (W 0.00831664) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.523361 ± 0.00285701 (W 0.00216937) | 0.523278 ± 0.00282472 (W 0.00255948) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.522765 ± 0.00102998 (W 0.00186929) | 0.523308 ± 0.00240862 (W 0.00221174) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.5828 ± 0.0023229 (W 0.0041298) | 0.642047 ± 0.00568808 (W 0.00916108) | 0.334383 ± 0.00293464 (W 0.00167923) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.884027 ± 0.00532401 (W 0.000886949) | 1.29889 ± 0.0135489 (W 0.00447107) | 0.618353 ± 0.00283612 (W 0.00317184) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.546695 ± 0.00353907 (W 0.00220169) | 0.584486 ± 0.0018187 (W 0.00791377) | 0.317414 ± 0.000679206 (W 0.00174184) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.2043 ± 0.0144919 (W 0.0130124) | 13.1011 ± 0.0213891 (W 0.0149651) | 12.4626 ± 0.066188 (W 0.0212367) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.2902 ± 0.00654946 (W 0.0113585) | 10.2743 ± 0.00398589 (W 0.0107106) | 6.12142 ± 0.0383271 (W 0.0139829) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.246299 ± 0.000918029 (W 0.0018071) | 0.297788 ± 0.0149104 (W 0.0243954) | 0.195805 ± 0.0474318 (W 0.00315131) | 🔵 faer-fork 1.21× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.73924 ± 0.00685268 (W 0.00864185) | 6.73212 ± 0.0291114 (W 0.0224897) | 3.90516 ± 0.006752 (W 0.0086985) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.284353 ± 0.00132089 (W 0.00205079) | 0.396754 ± 0.00454286 (W 0.0154405) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.28848 ± 0.0017978 (W 0.00239897) | 0.399255 ± 0.0121192 (W 0.025092) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 0.559418 ± 0.00445992 (W 0.00176748) | 0.640928 ± 0.0205958 (W 0.024222) | 0.325299 ± 0.00383796 (W 0.00315464) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.780014 ± 0.00178012 (W 0.00221052) | 1.59397 ± 0.0204582 (W 0.00851971) | 0.547444 ± 0.00389152 (W 0.0022631) | 🔵 faer-fork 2.04× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.507566 ± 0.00168523 (W 0.00228626) | 0.596165 ± 0.0252569 (W 0.0250068) | 0.303468 ± 0.00236825 (W 0.00297915) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.67× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 12.8393 ± 0.0227119 (W 0.0150973) | 13.1533 ± 0.0344023 (W 0.0151034) | 11.4632 ± 0.0491651 (W 0.0178765) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.3736 ± 0.0159258 (W 0.013503) | 10.364 ± 0.00631769 (W 0.0165396) | 6.03335 ± 0.026325 (W 0.0109278) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.22687 ± 0.00171329 (W 0.00252578) | 1.22023 ± 0.0110744 (W 0.00200495) | 1.8711 ± 0.00972881 (W 0.00492329) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.6454 ± 0.0502117 (W 0.0116655) | 17.3804 ± 0.00313963 (W 0.0118116) | 26.4438 ± 0.0418778 (W 0.032291) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.50503 ± 0.0252203 (W 0.00267941) | 7.50369 ± 0.0228948 (W 0.0120977) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52067 ± 0.0147722 (W 0.00901632) | 7.50573 ± 0.00236148 (W 0.00939152) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.13214 ± 0.00193831 (W 0.00316775) | 2.21802 ± 0.00698384 (W 0.00618026) | 3.30933 ± 0.0319557 (W 0.00955976) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.83695 ± 0.0490263 (W 0.00331176) | 6.40383 ± 0.00548203 (W 0.00772866) | 5.65978 ± 0.0400805 (W 0.00537608) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.06756 ± 0.00380031 (W 0.00310457) | 2.14987 ± 0.00581905 (W 0.00726974) | 2.82257 ± 0.0116851 (W 0.00353865) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.9992 ± 0.119804 (W 0.0308203) | 34.1916 ± 0.151661 (W 0.0291335) | 43.9431 ± 0.0646011 (W 0.0285655) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.3303 ± 0.0348366 (W 0.025123) | 19.311 ± 0.0272475 (W 0.0118956) | 18.1661 ± 0.0308221 (W 0.0243542) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.773025 ± 0.017005 (W 0.0117278) | 0.811591 ± 0.0124467 (W 0.00703643) | 0.791165 ± 0.00316202 (W 0.00902262) | · | · |  |
| `eigh/n256/b1` | 9.61238 ± 0.00584097 (W 0.00826511) | 11.3527 ± 0.0185335 (W 0.010031) | 10.1193 ± 0.018697 (W 0.00838776) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92676 ± 0.00537109 (W 0.00233745) | 1.91758 ± 0.0077366 (W 0.00257477) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93305 ± 0.00245139 (W 0.00241879) | 1.92001 ± 0.008307 (W 0.00410927) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.4477 ± 0.0100111 (W 0.0067562) | 1.56416 ± 0.0151419 (W 0.00992378) | 1.01971 ± 0.00248069 (W 0.00123918) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.4738 ± 0.00826862 (W 0.00232057) | 4.74821 ± 0.088081 (W 0.0170979) | 1.63426 ± 0.00297116 (W 0.00504126) | 🔵 faer-fork 1.92× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.36426 ± 0.00575359 (W 0.00985921) | 1.43248 ± 0.00920862 (W 0.0185082) | 0.894498 ± 0.00424764 (W 0.00290991) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.9391 ± 0.383895 (W 0.0176958) | 21.5863 ± 0.106534 (W 0.0344191) | 21.208 ± 0.0343483 (W 0.0299316) | · | · |  |
| `svd_values/n256/b1` | 15.6307 ± 0.212123 (W 0.0175118) | 16.3093 ± 0.091635 (W 0.0229741) | 11.025 ± 0.0206391 (W 0.0216102) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.730392 ± 0.0100793 (W 0.00217523) | 0.789442 ± 0.0127101 (W 0.00702117) | 0.661614 ± 0.00240599 (W 0.00591385) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 8.3694 ± 0.00603026 (W 0.00443211) | 11.1665 ± 0.00881571 (W 0.0321238) | 8.00428 ± 0.0252701 (W 0.0152704) | 🔵 faer-fork 1.33× faster than `faer-upstream` | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00165 ± 0.0006193 (W 0.00120927) | 1.30533 ± 0.0208059 (W 0.0784183) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01508 ± 0.007632 (W 0.00509101) | 1.14588 ± 0.0802979 (W 0.0948345) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 1.37134 ± 0.00370104 (W 0.00719684) | 1.48804 ± 0.0280532 (W 0.00928869) | 0.694411 ± 0.00639609 (W 0.00351034) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.09853 ± 0.0213741 (W 0.00339195) | 4.83801 ± 0.049532 (W 0.0107177) | 1.62805 ± 0.00475505 (W 0.00291555) | 🔵 faer-fork 2.31× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.26121 ± 0.000749228 (W 0.0043353) | 1.34 ± 0.0117963 (W 0.00771061) | 0.664118 ± 0.00555849 (W 0.00370197) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.5816 ± 0.0194594 (W 0.0615248) | 21.2584 ± 0.205128 (W 0.0854908) | 17.1864 ± 0.0517347 (W 0.0295461) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 15.1508 ± 0.124996 (W 0.027199) | 16.419 ± 0.202204 (W 0.0225273) | 9.61768 ± 0.0280567 (W 0.0229196) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.137 ± 0.00234386 (W 0.00161311) | 1.12771 ± 0.00320888 (W 0.0019206) | 1.61534 ± 0.125526 (W 0.00330701) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 17.5502 ± 0.0220184 (W 0.0202217) | 17.3295 ± 0.0423857 (W 0.0122757) | 26.2673 ± 0.0901536 (W 0.0295231) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.42134 ± 0.0242801 (W 0.00477512) | 7.41174 ± 0.0209324 (W 0.0146863) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44707 ± 0.00716494 (W 0.00346933) | 7.43449 ± 0.00469124 (W 0.00802965) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.02307 ± 0.014455 (W 0.00597578) | 2.00464 ± 0.0030356 (W 0.00366736) | 3.14844 ± 0.00679662 (W 0.00806725) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.50346 ± 0.034346 (W 0.00658223) | 4.53707 ± 0.0398905 (W 0.00505191) | 5.56141 ± 0.0464022 (W 0.00857559) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.95461 ± 0.00408696 (W 0.00200308) | 1.94073 ± 0.00277294 (W 0.00710577) | 2.73423 ± 0.0432279 (W 0.00946625) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.715 ± 0.0991725 (W 0.0294219) | 33.7358 ± 0.103216 (W 0.0752982) | 45.051 ± 1.16384 (W 0.0623694) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 18.9961 ± 0.00826356 (W 0.0230057) | 18.9191 ± 0.0126353 (W 0.0311139) | 19.83 ± 1.11438 (W 0.0818198) | · | · | `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.67901 ± 0.0105858 (W 0.0133574) | 0.710678 ± 0.00679091 (W 0.00802392) | 0.617868 ± 0.0341482 (W 0.0105899) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 9.53267 ± 0.0118925 (W 0.00758672) | 11.278 ± 0.0143121 (W 0.00933682) | 9.9861 ± 0.0469051 (W 0.0100399) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.9194 ± 0.00968287 (W 0.00213855) | 1.91122 ± 0.0101645 (W 0.00187116) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92187 ± 0.00810469 (W 0.00119904) | 1.91819 ± 0.00687626 (W 0.00179678) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.36578 ± 0.00915922 (W 0.0108523) | 1.35208 ± 0.0070192 (W 0.0173358) | 0.966487 ± 0.00152422 (W 0.0029817) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.2008 ± 0.0170553 (W 0.00246436) | 2.57773 ± 0.0291889 (W 0.00428429) | 1.58343 ± 0.0172592 (W 0.00290044) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.25843 ± 0.00909634 (W 0.0078086) | 1.24891 ± 0.013489 (W 0.0156883) | 0.852239 ± 0.0188395 (W 0.004461) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.4331 ± 0.353989 (W 0.0221778) | 21.2817 ± 0.164367 (W 0.0162185) | 22.2667 ± 0.743579 (W 0.0343343) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 15.4201 ± 0.185785 (W 0.0164882) | 16.0473 ± 0.0881624 (W 0.0225954) | 11.9701 ± 0.687184 (W 0.0204601) | · | 🔴 faer-fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.634436 ± 0.00179168 (W 0.00214367) | 0.704183 ± 0.00326073 (W 0.00804912) | 0.46164 ± 0.00755925 (W 0.00337479) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 8.3064 ± 0.00221133 (W 0.00707028) | 11.1042 ± 0.0202768 (W 0.0486632) | 7.85728 ± 0.0296248 (W 0.0162697) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00055 ± 0.00581867 (W 0.00131884) | 1.29808 ± 0.108839 (W 0.0826086) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01679 ± 0.00563271 (W 0.000836345) | 1.31312 ± 0.00652924 (W 0.0989648) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.27351 ± 0.0103249 (W 0.0078623) | 1.26592 ± 0.00310755 (W 0.0112484) | 0.68328 ± 0.0125905 (W 0.00479492) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.77792 ± 0.00640835 (W 0.0029555) | 2.68916 ± 0.00427553 (W 0.0166133) | 1.58576 ± 0.00120997 (W 0.00312063) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.14572 ± 0.000171834 (W 0.0040429) | 1.14193 ± 0.0119191 (W 0.0130754) | 0.653465 ± 0.00616956 (W 0.00512442) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.3544 ± 0.377369 (W 0.0242562) | 20.8613 ± 0.126701 (W 0.0942315) | 17.144 ± 0.129771 (W 0.0268659) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 14.9075 ± 0.284031 (W 0.0319288) | 15.9638 ± 0.131324 (W 0.0205891) | 9.59635 ± 0.110965 (W 0.0199749) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/256`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.553311 ± 0.000688358 (W 0.00174114) | 0.555396 ± 0.0106045 (W 0.00179492) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.556072 ± 0.00146413 (W 0.00168298) | 0.566216 ± 0.00767561 (W 0.00219234) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.467652 ± 0.0025297 (W 0.00216065) | 0.469496 ± 0.00386426 (W 0.00283809) | 0.659509 ± 0.133921 (W 0.00395785) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.06159 ± 0.00452526 (W 0.00259552) | 1.85626 ± 0.0131355 (W 0.00476472) | 0.907342 ± 0.00253671 (W 0.00131973) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.51663 ± 0.00757893 (W 0.005295) | 2.501 ± 0.011943 (W 0.00393578) | 3.04884 ± 0.00659559 (W 0.00381738) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.50807 ± 0.0112725 (W 0.0033845) | 1.48441 ± 0.0104896 (W 0.00397813) | 1.38971 ± 0.153652 (W 0.00457877) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.403035 ± 0.0645475 (W 0.00200013) | 0.161161 ± 0.020288 (W 0.00134373) | - | 🔴 faer-fork 2.50× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.388688 ± 0.0652776 (W 0.00222383) | 0.159558 ± 0.0311202 (W 0.0023378) | - | 🔴 faer-fork 2.44× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.44944 ± 0.057649 (W 0.00310336) | 0.429202 ± 0.0235175 (W 0.0050662) | 0.327662 ± 0.049497 (W 0.00260754) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.00642 ± 0.0764069 (W 0.00374259) | 3.40466 ± 0.353218 (W 0.199871) | 0.454751 ± 0.028222 (W 0.00487762) | 🔵 faer-fork 3.38× faster than `faer-upstream` | 🔴 faer-fork 2.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/1024x64/b1` | 2.28535 ± 0.101272 (W 0.0194378) | 2.14398 ± 0.0886462 (W 0.0134461) | 2.1505 ± 0.119138 (W 0.00854671) | 🔴 faer-fork 1.07× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.41624 ± 0.0445962 (W 0.00447874) | 1.53772 ± 0.0375011 (W 0.00583498) | 1.03582 ± 0.123183 (W 0.00406786) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.399599 ± 0.0194891 (W 0.00657697) | 0.144823 ± 0.00325803 (W 0.00713309) | - | 🔴 faer-fork 2.76× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.425962 ± 0.00969271 (W 0.00695432) | 0.146634 ± 0.00734626 (W 0.00646499) | - | 🔴 faer-fork 2.90× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.436776 ± 0.000696163 (W 0.00231861) | 0.427595 ± 0.0025796 (W 0.00544709) | 0.30954 ± 0.00177396 (W 0.00205453) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.00507 ± 0.00412722 (W 0.00288995) | 3.02749 ± 0.185025 (W 0.0952265) | 0.32114 ± 0.000373256 (W 0.00222634) | 🔵 faer-fork 3.01× faster than `faer-upstream` | 🔴 faer-fork 3.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.31119 ± 0.0144631 (W 0.00422082) | 2.23413 ± 0.00716453 (W 0.0084854) | 1.67452 ± 0.326692 (W 0.00468907) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.42791 ± 0.00567931 (W 0.00545253) | 1.61604 ± 0.0113053 (W 0.00662094) | 0.811738 ± 0.199124 (W 0.00262616) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.575723 ± 0.0167708 (W 0.0020538) | 0.592981 ± 0.0156243 (W 0.00185076) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.581314 ± 0.012928 (W 0.00192871) | 0.572507 ± 0.0157172 (W 0.00217275) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.384859 ± 0.0017504 (W 0.00345719) | 0.384748 ± 0.00099743 (W 0.00263069) | 0.288147 ± 0.00160543 (W 0.00144069) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.77927 ± 0.000994131 (W 0.0020179) | 0.773677 ± 0.0123184 (W 0.00364917) | 0.761594 ± 0.00112398 (W 0.00164183) | · | · |  |
| `svd_thin/1024x64/b1` | 2.46281 ± 0.0073917 (W 0.00368366) | 2.4489 ± 0.00716621 (W 0.00288309) | 2.81174 ± 0.00196126 (W 0.00444879) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.40918 ± 0.00141007 (W 0.00622028) | 1.39984 ± 0.00341411 (W 0.00209863) | 1.23838 ± 0.00288535 (W 0.00256977) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.427188 ± 0.0414825 (W 0.00178588) | 0.195676 ± 0.0292256 (W 0.0018628) | - | 🔴 faer-fork 2.18× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.426647 ± 0.0446546 (W 0.00332641) | 0.198301 ± 0.0351274 (W 0.00218363) | - | 🔴 faer-fork 2.15× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.361916 ± 0.01268 (W 0.00362204) | 0.354052 ± 0.0118197 (W 0.00346629) | 0.287899 ± 0.0163053 (W 0.00219703) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.725459 ± 0.0026933 (W 0.00481726) | 0.833254 ± 0.00187131 (W 0.00401272) | 0.425355 ± 0.00325036 (W 0.00483221) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.23504 ± 0.0853179 (W 0.00376796) | 2.10139 ± 0.0985672 (W 0.127005) | 1.83219 ± 0.0924231 (W 0.00782245) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.34161 ± 0.0316038 (W 0.00420374) | 1.45952 ± 0.0291236 (W 0.00651531) | 0.904865 ± 0.0287466 (W 0.00409727) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.439423 ± 0.0166217 (W 0.0065767) | 0.187882 ± 0.0211601 (W 0.00750733) | - | 🔴 faer-fork 2.34× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.41678 ± 0.0165008 (W 0.00677943) | 0.165542 ± 0.0121964 (W 0.00579948) | - | 🔴 faer-fork 2.52× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.358429 ± 0.94937 (W 0.00266033) | 0.355045 ± 0.000425507 (W 0.00224513) | 0.287537 ± 0.00186055 (W 0.00199912) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.730137 ± 0.0090845 (W 0.00305255) | 0.923219 ± 0.0118406 (W 0.00353502) | 0.301984 ± 0.00164796 (W 0.00272017) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 2.42× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.26424 ± 0.00360957 (W 0.00564687) | 2.18311 ± 0.0077885 (W 0.00703811) | 1.6331 ± 0.00295644 (W 0.00569681) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.35077 ± 0.00158047 (W 0.00301983) | 1.53978 ± 0.00279557 (W 0.00484396) | 0.786039 ± 0.00149778 (W 0.00384949) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.20616 ± 0.00796924 (W 0.00286136) | 2.20014 ± 0.0219465 (W 0.00293848) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20304 ± 0.0012455 (W 0.00450408) | 2.2432 ± 0.00412442 (W 0.00254379) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.00579 ± 0.00145958 (W 0.00100118) | 1.01092 ± 0.00318509 (W 0.0112321) | 1.22238 ± 0.249792 (W 0.00388015) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 2.56581 ± 0.0333655 (W 0.00209834) | 4.01764 ± 0.0502102 (W 0.021058) | 2.39232 ± 0.013935 (W 0.00500894) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.97826 ± 0.0186716 (W 0.00637215) | 6.01692 ± 0.0252185 (W 0.00569513) | 9.69982 ± 0.155561 (W 0.0187108) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.0784 ± 0.020363 (W 0.00397021) | 3.07705 ± 0.0160429 (W 0.00388212) | 3.82615 ± 0.0200326 (W 0.00447571) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.41113 ± 0.0614272 (W 0.00253619) | 0.596074 ± 0.0977766 (W 0.00270578) | - | 🔴 faer-fork 2.37× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.40787 ± 0.051554 (W 0.00122364) | 0.578872 ± 0.104243 (W 0.00618457) | - | 🔴 faer-fork 2.43× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.769068 ± 0.173166 (W 0.00360144) | 0.762678 ± 0.153828 (W 0.0055593) | 1.40771 ± 0.242593 (W 0.00401601) | · | 🔵 faer-fork 1.83× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 2.19489 ± 0.319849 (W 0.00419838) | 4.04531 ± 0.308729 (W 0.0646529) | 1.37561 ± 0.0638063 (W 0.0031123) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/1024x64/b1` | 4.87645 ± 0.344187 (W 0.00468636) | 3.67725 ± 0.323824 (W 0.00474494) | 5.54016 ± 0.40334 (W 0.0337301) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.74571 ± 0.148112 (W 0.00866708) | 2.44045 ± 0.144559 (W 0.00378079) | 3.23144 ± 0.144821 (W 0.0367362) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.34587 ± 0.0493908 (W 0.0281977) | 0.475104 ± 0.00519561 (W 0.038306) | - | 🔴 faer-fork 2.83× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.40265 ± 0.0340295 (W 0.00259659) | 0.471892 ± 0.0452853 (W 0.0326269) | - | 🔴 faer-fork 2.97× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.717782 ± 0.00483202 (W 0.00174186) | 0.701471 ± 0.0254612 (W 0.00472442) | 1.48196 ± 0.00269743 (W 0.00637942) | · | 🔵 faer-fork 2.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 2.1843 ± 0.00695641 (W 0.012229) | 3.82346 ± 0.0382699 (W 0.0651568) | 0.869195 ± 0.00328777 (W 0.00243276) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 2.51× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.08768 ± 0.181907 (W 0.194618) | 3.67479 ± 0.00694201 (W 0.0340634) | 4.39028 ± 0.0239546 (W 0.0103537) | 🔴 faer-fork 1.38× slower than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.72633 ± 0.0204903 (W 0.00392192) | 2.48101 ± 0.00513167 (W 0.00392935) | 2.76818 ± 0.284248 (W 0.0239114) | 🔴 faer-fork 1.10× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26767 ± 0.0148515 (W 0.00191321) | 2.25882 ± 0.0100511 (W 0.00143309) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26474 ± 0.0168779 (W 0.00502323) | 2.25498 ± 0.00674044 (W 0.00227344) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.888464 ± 0.0133225 (W 0.00179538) | 0.877035 ± 0.00251446 (W 0.00220739) | 1.11209 ± 0.00373027 (W 0.00337907) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.27384 ± 0.0141681 (W 0.00287164) | 2.25215 ± 0.0387188 (W 0.00282998) | 2.26213 ± 0.0112715 (W 0.0041442) | · | · |  |
| `svd_thin/1024x64/b1` | 5.88855 ± 0.0121039 (W 0.00272312) | 5.90859 ± 0.0224496 (W 0.00381895) | 8.55203 ± 0.0415354 (W 0.0112299) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.95816 ± 0.0231177 (W 0.00192741) | 2.956 ± 0.019095 (W 0.00289412) | 3.6749 ± 0.00826675 (W 0.00864061) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.45925 ± 0.177474 (W 0.00341203) | 0.638273 ± 0.155743 (W 0.00151537) | - | 🔴 faer-fork 2.29× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.43334 ± 0.204391 (W 0.00310382) | 0.621411 ± 0.184317 (W 0.00134205) | - | 🔴 faer-fork 2.31× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.657979 ± 0.0432748 (W 0.00478613) | 0.648533 ± 0.0440457 (W 0.00512275) | 1.07398 ± 0.161996 (W 0.0019874) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.90279 ± 0.099629 (W 0.00323145) | 1.58919 ± 0.073996 (W 0.00452932) | 1.34347 ± 0.0212577 (W 0.00657109) | 🔴 faer-fork 1.20× slower than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 4.76041 ± 0.265398 (W 0.00435073) | 3.5805 ± 0.235145 (W 0.00630391) | 5.43118 ± 0.225699 (W 0.00536998) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.64459 ± 0.095416 (W 0.00499644) | 2.34377 ± 0.0813098 (W 0.00293924) | 2.76455 ± 0.0635611 (W 0.0045086) | 🔴 faer-fork 1.13× slower than `faer-upstream` | · | `!` between-start range over 5% |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.43554 ± 0.0406959 (W 0.0350428) | 0.530503 ± 0.0491313 (W 0.0479745) | - | 🔴 faer-fork 2.71× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.43323 ± 0.000982702 (W 0.0341665) | 0.531815 ± 0.0011021 (W 0.0362381) | - | 🔴 faer-fork 2.69× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.612767 ± 0.00339201 (W 0.0018676) | 0.60441 ± 0.00275878 (W 0.0057863) | 1.0934 ± 0.014021 (W 0.0022631) | · | 🔵 faer-fork 1.78× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.88153 ± 0.00478045 (W 0.0114925) | 1.63492 ± 0.0119178 (W 0.0118346) | 0.85972 ± 0.00547139 (W 0.000959799) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.71066 ± 0.0133579 (W 0.254437) | 3.59135 ± 0.32017 (W 0.0349764) | 4.36236 ± 0.0194113 (W 0.00660007) | 🔴 faer-fork 1.31× slower than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 2.63201 ± 0.00214298 (W 0.0092278) | 2.39009 ± 0.00276595 (W 0.00943523) | 2.29344 ± 0.011115 (W 0.00476106) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `eigh/1024x64`, `householder_apply/1024x64`, `solve/1024x64`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.397128 ± 0.00230155 (W 0.00274063) | 0.513051 ± 0.00514022 (W 0.0024014) | 0.927877 ± 0.132976 (W 0.00326167) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 2.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 1.00184 ± 0.0123236 (W 0.00651745) | 1.01646 ± 0.00367616 (W 0.00390184) | 1.33982 ± 0.00202355 (W 0.0021464) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.45262 ± 0.0054179 (W 0.00307848) | 2.44676 ± 0.00427429 (W 0.00368541) | 4.14096 ± 0.0728012 (W 0.00608438) | · | 🔵 faer-fork 1.69× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.42235 ± 0.00599208 (W 0.00196514) | 1.41204 ± 0.00215511 (W 0.00250326) | 2.6039 ± 0.0203521 (W 0.00969683) | · | 🔵 faer-fork 1.83× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.312764 ± 0.024331 (W 0.0214304) | 0.360244 ± 0.00815987 (W 0.0139461) | 0.300283 ± 0.01125 (W 0.00458769) | 🔵 faer-fork 1.15× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.613608 ± 0.00360206 (W 0.00451406) | 0.690011 ± 0.00674642 (W 0.00486563) | 0.428242 ± 0.00383604 (W 0.00204228) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.22653 ± 0.00674351 (W 0.0037102) | 2.09517 ± 0.00445626 (W 0.00392463) | 3.07064 ± 0.217117 (W 0.00623532) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.35713 ± 0.00290312 (W 0.00341376) | 1.46384 ± 0.00587679 (W 0.00409436) | 2.09041 ± 0.0145338 (W 0.00402525) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.276848 ± 0.00113356 (W 0.00193159) | 0.335757 ± 0.00106651 (W 0.00706306) | 0.169098 ± 0.00229772 (W 0.00129877) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔴 faer-fork 1.64× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.54625 ± 0.00119752 (W 0.00485837) | 0.73706 ± 0.00399948 (W 0.00676426) | 0.258934 ± 0.00253639 (W 0.00205129) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.26582 ± 0.00203463 (W 0.00248721) | 2.19224 ± 0.020865 (W 0.00934287) | 3.21171 ± 0.0122223 (W 0.0110632) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.36554 ± 0.00383319 (W 0.00247186) | 1.55424 ± 0.00304 (W 0.00575814) | 2.07613 ± 0.0151885 (W 0.00474508) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.312303 ± 0.000956007 (W 0.00207041) | 0.311166 ± 0.00143373 (W 0.00207273) | 3.13421 ± 0.00848088 (W 0.00221545) | · | 🔵 faer-fork 10.04× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.566048 ± 0.00274819 (W 0.00211087) | 0.563516 ± 0.00696205 (W 0.00247811) | 6.29504 ± 0.00504431 (W 0.00517172) | · | 🔵 faer-fork 11.12× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.53009 ± 0.010415 (W 0.00522013) | 2.51269 ± 0.00349205 (W 0.0035976) | 3.851 ± 0.107368 (W 0.00763088) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.47709 ± 0.00373562 (W 0.00685271) | 1.46969 ± 0.00198723 (W 0.00549183) | 2.42385 ± 0.0553236 (W 0.0101956) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.185868 ± 0.0013542 (W 0.0240831) | 0.156542 ± 0.00994226 (W 0.0118127) | 0.247934 ± 0.00700014 (W 0.00426546) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.205514 ± 0.00176067 (W 0.00144849) | 0.261031 ± 0.000574203 (W 0.00200487) | 0.370644 ± 0.0017205 (W 0.00193774) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.28971 ± 0.00199995 (W 0.00389625) | 2.15719 ± 0.00389986 (W 0.0057823) | 3.05506 ± 0.0733921 (W 0.00769358) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.4091 ± 0.00177786 (W 0.00660442) | 1.50918 ± 0.00983494 (W 0.00750012) | 2.0514 ± 0.0179373 (W 0.00557296) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.192221 ± 0.000981785 (W 0.00228936) | 0.13856 ± 0.000746473 (W 0.00422753) | 0.134342 ± 0.000698124 (W 0.0017776) | 🔴 faer-fork 1.39× slower than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.158046 ± 0.00183139 (W 0.00105466) | 0.317414 ± 0.00686966 (W 0.00214288) | 0.218489 ± 0.00122745 (W 0.00242885) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.32894 ± 0.0101042 (W 0.005929) | 2.26092 ± 0.0030097 (W 0.00763561) | 2.84953 ± 0.0601022 (W 0.00983967) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.41869 ± 0.0056883 (W 0.00132858) | 1.61088 ± 0.0073878 (W 0.00640603) | 2.05583 ± 0.0126349 (W 0.00419478) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 1.00903 ± 0.00359366 (W 0.00305515) | 1.05259 ± 0.022399 (W 0.00318275) | 2.32979 ± 0.00193185 (W 0.00328028) | · | 🔵 faer-fork 2.31× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.56663 ± 0.0125821 (W 0.00463516) | 2.60538 ± 0.0218962 (W 0.00406108) | 3.56359 ± 0.0081332 (W 0.00610346) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.91984 ± 0.0298297 (W 0.00358187) | 5.89941 ± 0.012839 (W 0.00673769) | 12.6317 ± 0.141284 (W 0.0991552) | · | 🔵 faer-fork 2.13× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.95182 ± 0.0150107 (W 0.00198865) | 2.93766 ± 0.0189894 (W 0.00510552) | 5.56057 ± 0.0492523 (W 0.0084991) | · | 🔵 faer-fork 1.88× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.659951 ± 0.101334 (W 0.0795591) | 0.563303 ± 0.0382196 (W 0.0456882) | 0.945489 ± 0.00701842 (W 0.00734097) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.985502 ± 0.00960054 (W 0.00283359) | 1.07633 ± 0.0127593 (W 0.00316871) | 1.35572 ± 0.0017016 (W 0.00339426) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.80585 ± 0.176463 (W 0.0112713) | 3.59857 ± 0.0125358 (W 0.00377757) | 7.80668 ± 0.107268 (W 0.0431423) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.63981 ± 0.0076138 (W 0.00318926) | 2.33046 ± 0.0117006 (W 0.00456647) | 3.74172 ± 0.0198208 (W 0.0112187) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.495292 ± 0.00187887 (W 0.00289907) | 0.442742 ± 0.00637169 (W 0.0188011) | 0.727252 ± 0.0241814 (W 0.00839867) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.715837 ± 0.00404388 (W 0.00451528) | 1.02226 ± 0.00952044 (W 0.0104043) | 0.758538 ± 0.0027801 (W 0.00200937) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.80846 ± 0.147237 (W 0.251481) | 3.89127 ± 0.160345 (W 0.278498) | 6.27247 ± 0.0571792 (W 0.0181251) | 🔴 faer-fork 1.24× slower than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.62432 ± 0.00476447 (W 0.00635737) | 2.37862 ± 0.00361311 (W 0.00994843) | 3.26602 ± 0.0473906 (W 0.00997998) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.895356 ± 0.00307212 (W 0.00293611) | 0.894281 ± 0.00402939 (W 0.00342928) | 2.12255 ± 0.00456015 (W 0.00558377) | · | 🔵 faer-fork 2.37× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.218 ± 0.00420421 (W 0.00375541) | 2.22906 ± 0.00829252 (W 0.0018737) | 16.877 ± 0.0061662 (W 0.0161149) | · | 🔵 faer-fork 7.61× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 6.04258 ± 0.0277483 (W 0.00265934) | 6.02828 ± 0.0144925 (W 0.00380688) | 11.9326 ± 0.0637025 (W 0.0205148) | · | 🔵 faer-fork 1.97× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 3.09078 ± 0.0181562 (W 0.00458141) | 3.06526 ± 0.0246739 (W 0.00183454) | 5.37407 ± 0.0476719 (W 0.00976319) | · | 🔵 faer-fork 1.74× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.545747 ± 0.00241309 (W 0.0953029) | 0.335246 ± 0.0359428 (W 0.0534672) | 0.58311 ± 0.00661417 (W 0.00379073) | 🔴 faer-fork 1.63× slower than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.664782 ± 0.000441644 (W 0.0021664) | 0.721581 ± 0.00194511 (W 0.00150054) | 1.28328 ± 0.0039646 (W 0.00380207) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.93× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.91448 ± 0.00838082 (W 0.00315837) | 3.71144 ± 0.00222048 (W 0.0092173) | 7.98168 ± 0.329918 (W 0.0260456) | 🔴 faer-fork 1.32× slower than `faer-upstream` | 🔵 faer-fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.74003 ± 0.00503673 (W 0.00301185) | 2.42637 ± 0.0080686 (W 0.00459307) | 3.73836 ± 0.0323378 (W 0.0131649) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.381593 ± 0.00119928 (W 0.0411396) | 0.277799 ± 0.00142299 (W 0.00262234) | 0.40931 ± 0.00149012 (W 0.0025247) | 🔴 faer-fork 1.37× slower than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.409751 ± 0.00169947 (W 0.00128174) | 0.681342 ± 0.00570084 (W 0.0115748) | 0.708482 ± 0.000327436 (W 0.00200999) | 🔵 faer-fork 1.66× faster than `faer-upstream` | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.88307 ± 0.0448675 (W 0.276509) | 3.72898 ± 0.0114983 (W 0.0319016) | 6.25423 ± 0.076 (W 0.02545) | 🔴 faer-fork 1.31× slower than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.72861 ± 0.00717567 (W 0.010708) | 2.48314 ± 0.00782817 (W 0.00895365) | 3.25273 ± 0.0345207 (W 0.0188095) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/64x1024`, `eigh/64x1024`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
