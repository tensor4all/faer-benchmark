# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `0e15729ad011e3813a41c168167ec61ed11a9dbb`
- t4a-faer version: `0.25.0`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9f5cc57ba8f237a2283b5e1beb6689ab9d486d11`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `0becc47a4cbf1677dbda0ae7497656bcb7a0e38f56864c132459a40d859f672e`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-26T19:01:25.752762Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /home/shinaoka/projects/tensor4all/faer-0.25-cand --engines faer-fork,faer-upstream,lapack-mkl --aa 3 --reps 5 --prime-ms 250 --vendor mkl --no-publish --upstream extern/upstream-faer --threads 1,4,8 --dtypes f64,c64 --shapes 64,256,1024x64,64x1024,64x64x64,256x256x256,4096x64x64,16x4096x240,4096x16x240,64x64x4096 --families gemm,lu,qr_factor,cholesky,svd_values,svd_thin,eigh,householder_apply,solve --label pair3-cand-1`
- raw data: `data/results/zen5-cpu/faer-kernels/20261026T183341Z-pair3-cand-1/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.86%, worst 1503.24% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 112 of 1152 engine cells exceed 5% and carry `!`; median within-process relative SD 0.36%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/64x64x64/b1` | 0.017202 ± 4.04145e-05 (W 4.45892e-05) | 0.017122 ± 1.52753e-05 (W 3.60999e-05) | 0.024436 ± 4.10731e-05 (W 7.30904e-05) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.012192 ± 4.7648e-05 (W 0.000276919) | 0.019286 ± 0.0009826 (W 0.00144313) | 0.014307 ± 0.000286952 (W 0.00010037) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.01078 ± 0.000142339 (W 0.000246429) | 0.01079 ± 0.000193521 (W 0.000212994) | 0.010129 ± 8.14064e-05 (W 0.000220591) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017122 ± 1.52753e-05 (W 1.94936e-05) | 0.017051 ± 3.80832e-05 (W 2.50998e-05) | 0.024345 ± 1.18462e-05 (W 2.77489e-05) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.012133 ± 0.000244841 (W 0.000357322) | 0.019306 ± 0.000387467 (W 0.00123862) | 0.014157 ± 0.000130001 (W 0.000154461) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.01095 ± 5.50485e-05 (W 0.000189592) | 0.01056 ± 0.000121655 (W 0.000281173) | 0.010068 ± 0.000141237 (W 0.000203898) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067877 ± 0.000134536 (W 0.00160565) | 0.067837 ± 3.56417e-05 (W 9.65401e-05) | 0.082714 ± 0.000591451 (W 0.0011919) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.029736 ± 0.000221202 (W 0.000201453) | 0.038953 ± 0.00138581 (W 0.00233776) | 0.035747 ± 0.000284869 (W 0.000354085) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027952 ± 0.00016552 (W 0.00070115) | 0.027751 ± 9.15114e-05 (W 0.000224009) | 0.01625 ± 0.00032551 (W 0.000216401) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067716 ± 9.59705e-05 (W 4.14512e-05) | 0.067706 ± 0.000334965 (W 0.00107319) | 0.081712 ± 0.00102727 (W 0.00110488) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.029896 ± 0.000216019 (W 0.000267717) | 0.039604 ± 0.000871478 (W 0.00143202) | 0.035386 ± 0.000251265 (W 0.000385377) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027862 ± 0.000179528 (W 0.000237382) | 0.028072 ± 0.000128946 (W 0.000210759) | 0.01624 ± 0.000344137 (W 0.000257959) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07236 ± 0.0053662 (W 0.000797358) | 1.07246 ± 0.00224295 (W 0.00123327) | 1.20622 ± 0.00250034 (W 0.00260447) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.291784 ± 0.000845177 (W 0.00186829) | 0.309768 ± 0.0019536 (W 0.00986528) | 0.343862 ± 0.00155752 (W 0.00198753) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.166301 ± 0.000442136 (W 0.00212989) | 0.225732 ± 0.0311787 (W 0.0339894) | 0.179485 ± 0.000529377 (W 0.00157281) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07443 ± 0.00541079 (W 0.00321434) | 1.07153 ± 0.00240637 (W 0.000577687) | 1.20223 ± 0.00378221 (W 0.00228071) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.291975 ± 0.000431155 (W 0.00183643) | 0.308527 ± 0.0013087 (W 0.00590535) | 0.341928 ± 0.00308913 (W 0.00173372) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.166601 ± 0.000528429 (W 0.00142807) | 0.256669 ± 0.0130275 (W 0.0326109) | 0.177963 ± 0.00289662 (W 0.00249081) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27946 ± 0.00221777 (W 0.00380762) | 4.28448 ± 0.00226141 (W 0.0041809) | 5.08431 ± 0.0362396 (W 0.0127065) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.11143 ± 0.00127757 (W 0.00122168) | 1.10866 ± 0.00105588 (W 0.000835123) | 1.81417 ± 0.0135395 (W 0.00507142) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.582628 ± 0.000845156 (W 0.00224328) | 0.608978 ± 0.000918262 (W 0.00234858) | 0.698896 ± 0.0174417 (W 0.00215135) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27609 ± 0.00623969 (W 0.00330851) | 4.28619 ± 0.00343843 (W 0.00572329) | 5.12829 ± 0.0168142 (W 0.0220918) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.11105 ± 0.000706492 (W 0.00151294) | 1.1081 ± 0.000733081 (W 0.000917518) | 1.79899 ± 0.0162246 (W 0.00566006) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.58307 ± 0.00113471 (W 0.00183889) | 0.607603 ± 0.00145983 (W 0.00184886) | 0.68523 ± 0.0129974 (W 0.00437688) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.2698 ± 0.0643209 (W 0.00477322) | 1.27124 ± 0.0572623 (W 0.00524829) | 1.5317 ± 0.0922625 (W 0.00550904) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.07561 ± 0.00770515 (W 0.00177553) | 1.08051 ± 0.0197581 (W 0.00690823) | 1.53822 ± 0.0129788 (W 0.00691421) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08729 ± 0.00234195 (W 0.000769294) | 1.08768 ± 0.000334287 (W 0.00226575) | 1.55918 ± 0.00688083 (W 0.00751783) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.428329 ± 0.00175526 (W 0.00449001) | 0.426857 ± 0.00281617 (W 0.005547) | 0.434761 ± 0.0161626 (W 0.00522447) | · | · | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.303797 ± 0.0052334 (W 0.00211544) | 0.304388 ± 0.00426265 (W 0.00212841) | 0.427107 ± 0.00231507 (W 0.00187418) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.278029 ± 0.00135269 (W 0.00175514) | 0.302925 ± 0.00468208 (W 0.00178165) | 0.388395 ± 0.0014736 (W 0.00211573) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.426997 ± 0.000386795 (W 0.00308111) | 0.427138 ± 0.00230477 (W 0.00500729) | 0.263623 ± 0.006998 (W 0.0028069) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.18722 ± 0.000576005 (W 0.00564202) | 0.189814 ± 0.00107653 (W 0.00627541) | 0.288057 ± 0.00049937 (W 0.021482) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.142867 ± 0.00083039 (W 0.000379195) | 0.198059 ± 0.00704637 (W 0.00893691) | 0.196557 ± 0.000881426 (W 0.00122318) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.01321 ± 0.0187489 (W 0.00142567) | 1.01715 ± 0.0181291 (W 0.00135806) | 2.64671 ± 0.00709056 (W 0.00438126) | · | 🔵 faer-fork 2.61× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.09523 ± 0.00938707 (W 0.00731676) | 1.09574 ± 0.025545 (W 0.00239058) | 1.53352 ± 0.0158039 (W 0.0180421) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.11611 ± 0.011085 (W 0.00182502) | 1.12231 ± 0.00743779 (W 0.00213677) | 1.23226 ± 0.0248403 (W 0.00302184) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.334765 ± 0.000768395 (W 0.00372531) | 0.716287 ± 0.00829844 (W 0.00416632) | 0.644993 ± 0.00448267 (W 0.00373811) | 🔵 faer-fork 2.14× faster than `faer-upstream` | 🔵 faer-fork 1.93× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.300861 ± 0.00229507 (W 0.00203589) | 0.296964 ± 0.00429624 (W 0.00266193) | 0.42875 ± 0.00264431 (W 0.00355973) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.297294 ± 0.00262437 (W 0.00227218) | 0.298186 ± 0.00235042 (W 0.00185885) | 0.329785 ± 0.00374781 (W 0.00225703) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.208469 ± 0.00143745 (W 0.00371767) | 1.14889 ± 0.000559625 (W 0.0191937) | 0.34842 ± 0.00217768 (W 0.00378467) | 🔵 faer-fork 5.51× faster than `faer-upstream` | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.182892 ± 0.000437662 (W 0.00297095) | 0.180868 ± 0.00103318 (W 0.00263606) | 0.293778 ± 0.00312781 (W 0.00410462) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.157504 ± 1.24804 (W 0.00183474) | 0.156343 ± 0.000926908 (W 0.00126347) | 0.174456 ± 0.000619888 (W 0.00216636) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.14291 ± 0.00997519 (W 0.00266536) | 4.1924 ± 0.277158 (W 0.0515019) | 5.73136 ± 0.0297497 (W 0.0104146) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 4.38334 ± 0.0386622 (W 0.0250641) | 4.36741 ± 0.0839309 (W 0.00530361) | 5.6666 ± 0.323985 (W 0.0195702) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 4.39642 ± 0.00351693 (W 0.00707287) | 4.41281 ± 0.00578724 (W 0.00686488) | 5.23382 ± 0.0295497 (W 0.0100967) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.66174 ± 0.00642717 (W 0.0042856) | 1.66668 ± 0.00364372 (W 0.00326033) | 1.95337 ± 0.0174178 (W 0.00437579) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.15714 ± 0.0100999 (W 0.00322937) | 1.15274 ± 0.0061734 (W 0.00390088) | 1.99817 ± 0.233261 (W 0.0262466) | · | 🔵 faer-fork 1.73× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 1.12611 ± 0.00146613 (W 0.00176038) | 1.12395 ± 0.00410397 (W 0.003108) | 2.06297 ± 0.00972698 (W 0.00644141) | · | 🔵 faer-fork 1.83× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.913297 ± 0.0167215 (W 0.00610707) | 0.896473 ± 0.0159117 (W 0.00576147) | 0.953448 ± 0.021025 (W 0.00434038) | · | · |  |
| `gemm/4096x16x240/b1` | 0.596373 ± 0.00538484 (W 0.00225855) | 0.598838 ± 0.00876254 (W 0.00410736) | 0.970462 ± 0.0669352 (W 0.0240179) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.571296 ± 0.00217176 (W 0.00334784) | 0.617635 ± 0.0209692 (W 0.00967238) | 0.759888 ± 0.00316307 (W 0.00249882) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07397 ± 0.0149779 (W 0.0066358) | 4.0866 ± 0.0109564 (W 0.00555171) | 5.72461 ± 0.0579081 (W 0.0111475) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.38909 ± 0.0231988 (W 0.00568585) | 4.36934 ± 0.0440297 (W 0.0111118) | 5.66449 ± 0.176573 (W 0.0471449) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 4.43489 ± 0.00939915 (W 0.00587864) | 4.43258 ± 0.00591796 (W 0.00588414) | 5.67557 ± 0.0146901 (W 0.0177469) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.18123 ± 0.00789778 (W 0.00238658) | 1.95158 ± 0.00776478 (W 0.0144051) | 20.4075 ± 5.13446 (W 0.0151733) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 17.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.16695 ± 0.00530073 (W 0.00451233) | 1.15086 ± 0.00265551 (W 0.00331954) | 2.16671 ± 0.12486 (W 0.044579) | · | 🔵 faer-fork 1.86× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.17738 ± 0.00946797 (W 0.00678449) | 1.17773 ± 0.00757799 (W 0.0047882) | 2.05373 ± 0.01788 (W 0.00977421) | · | 🔵 faer-fork 1.74× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.662126 ± 0.00351393 (W 0.00479943) | 2.58594 ± 0.00527133 (W 0.0309) | 4.15338 ± 3.78978 (W 0.0230065) | 🔵 faer-fork 3.91× faster than `faer-upstream` | 🔵 faer-fork 6.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.607505 ± 0.00367983 (W 0.00514696) | 0.593057 ± 0.0069882 (W 0.00300853) | 1.60653 ± 0.117093 (W 0.0168081) | · | 🔵 faer-fork 2.64× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.580773 ± 0.00288201 (W 0.00388713) | 0.578439 ± 0.00777874 (W 0.00432941) | 1.18088 ± 0.0352744 (W 0.059788) | · | 🔵 faer-fork 2.03× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.1275 ± 0.00873842 (W 0.00113449) | 1.12359 ± 0.0109497 (W 0.00280018) | 1.24469 ± 0.0092543 (W 0.00238783) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.297666 ± 0.00181586 (W 0.00186815) | 0.296233 ± 0.000522714 (W 0.00135357) | 0.331529 ± 0.00212542 (W 0.00202679) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.157173 ± 0.000546191 (W 0.000453954) | 0.157063 ± 0.000695064 (W 0.000719656) | 0.17128 ± 0.0012651 (W 0.00140507) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.09404 ± 0.0034679 (W 0.00158817) | 1.09198 ± 0.00267725 (W 0.00216159) | 1.56167 ± 0.00266996 (W 0.00390794) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.277658 ± 0.000331744 (W 0.00214232) | 0.302405 ± 0.0017344 (W 0.0019706) | 0.386801 ± 0.00221816 (W 0.00194864) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.145121 ± 1.25916 (W 0.00140989) | 0.198941 ± 0.00729273 (W 0.0067632) | 0.198189 ± 0.00158686 (W 0.00181469) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.44178 ± 0.00832226 (W 0.00927141) | 4.43317 ± 0.00941903 (W 0.0055025) | 5.78916 ± 0.0546775 (W 0.0285668) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.16397 ± 0.0188333 (W 0.00363572) | 1.16064 ± 0.0121346 (W 0.00467563) | 2.04773 ± 0.0390675 (W 0.00880366) | · | 🔵 faer-fork 1.76× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.5792 ± 0.00116252 (W 0.00350945) | 0.576287 ± 0.000629696 (W 0.00420484) | 1.14608 ± 0.0497633 (W 0.0292542) | · | 🔵 faer-fork 1.98× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.39758 ± 0.0155503 (W 0.00413949) | 4.4013 ± 0.0263926 (W 0.00596934) | 5.24087 ± 0.00861134 (W 0.0101634) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12335 ± 0.00103132 (W 0.000733232) | 1.12866 ± 0.00403395 (W 0.0028945) | 2.07363 ± 0.0132707 (W 0.00289825) | · | 🔵 faer-fork 1.85× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.57348 ± 0.000785649 (W 0.00242719) | 0.608658 ± 0.00621221 (W 0.0128229) | 0.759999 ± 0.00446003 (W 0.00363816) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.015109 ± 0.00110382 (W 3.29575e-05) | 0.016611 ± 6.71342e-05 (W 3.41365e-05) | 0.016891 ± 0.000107037 (W 6.1256e-05) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.486619 ± 0.00037896 (W 0.00178184) | 0.483191 ± 0.000650049 (W 0.0021526) | 0.395328 ± 0.000975462 (W 0.00134302) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040996 ± 0.0001405 (W 0.000111939) | 0.040346 ± 9.09414e-05 (W 6.6553e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.041167 ± 8.03762e-05 (W 8.96839e-05) | 0.040576 ± 7.37111e-05 (W 0.00128799) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.031388 ± 0.000403275 (W 0.000702618) | 0.02685 ± 6.4291e-05 (W 0.00030047) | 0.0425 ± 0.00031559 (W 0.00142612) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.087994 ± 0.000828901 (W 0.00116745) | 0.130082 ± 0.00019186 (W 0.00147459) | 0.298958 ± 0.133007 (W 0.00194601) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 3.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n64/b1` | 0.03233 ± 0.000135758 (W 0.000115543) | 0.027862 ± 0.000245764 (W 0.000129306) | 0.04327 ± 8.31084e-05 (W 0.000159193) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.919588 ± 0.00210158 (W 0.00431529) | 0.926228 ± 0.00741581 (W 0.00152807) | 0.719683 ± 0.00148701 (W 0.00200868) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.517566 ± 0.004478 (W 0.00160197) | 0.516724 ± 0.00332806 (W 0.00150924) | 0.266958 ± 0.000223943 (W 0.00196602) | · | 🔴 faer-fork 1.94× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016972 ± 0.000965211 (W 2.28035e-05) | 0.016551 ± 3.78594e-05 (W 5.26308e-05) | 0.016892 ± 6.71342e-05 (W 5.55995e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.487169 ± 0.00214298 (W 0.0018005) | 0.480307 ± 0.000733364 (W 0.00116367) | 0.273 ± 0.0234582 (W 0.00164568) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` | `!` between-start range over 5% |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.021019 ± 0.000929469 (W 0.000428162) | 0.020177 ± 0.000944612 (W 0.000376894) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020408 ± 9.13072e-05 (W 0.000293487) | 0.020127 ± 0.000499721 (W 0.000453065) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.031188 ± 0.000254808 (W 0.000107886) | 0.030708 ± 0.000510792 (W 0.00134013) | 0.042669 ± 0.000168791 (W 0.000171451) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.09097 ± 0.000771187 (W 0.000258994) | 0.205424 ± 0.00165153 (W 0.00144585) | 0.067336 ± 0.000266158 (W 0.000154659) | 🔵 faer-fork 2.26× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.032992 ± 0.000236855 (W 3.2453e-05) | 0.031058 ± 9.60902e-05 (W 0.00075527) | 0.04298 ± 5.2915e-05 (W 0.000135574) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.920089 ± 0.00374345 (W 0.00246336) | 0.908625 ± 0.00337952 (W 0.00275831) | 0.711778 ± 0.000865596 (W 0.0067282) | · | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.518557 ± 0.000504025 (W 0.00215058) | 0.513759 ± 0.0022698 (W 0.00209167) | 0.270976 ± 0.000834972 (W 0.00206398) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.015159 ± 0.0012621 (W 4.82525e-05) | 0.016511 ± 6.1101e-05 (W 2.77489e-05) | 0.016852 ± 4.74377e-05 (W 8.77912e-05) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.489262 ± 0.00270043 (W 0.0019505) | 0.482602 ± 0.00239787 (W 0.00125076) | 0.263622 ± 0.00116367 (W 0.00202187) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.015018 ± 0.00112925 (W 0.000348272) | 0.019356 ± 0.000760935 (W 0.00048242) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.016922 ± 0.000211732 (W 0.000742716) | 0.020748 ± 8.19776e-05 (W 0.000441039) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031789 ± 0.000316871 (W 0.000610666) | 0.030858 ± 0.000308627 (W 0.000328786) | 0.042549 ± 0.000173926 (W 9.36232e-05) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.095608 ± 0.00127213 (W 0.00179853) | 0.242743 ± 0.000819684 (W 0.00477207) | 0.067947 ± 0.000124231 (W 0.00124504) | 🔵 faer-fork 2.54× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.033021 ± 0.000436986 (W 6.61461e-05) | 0.031329 ± 0.000356316 (W 0.000614249) | 0.043171 ± 8.24035e-05 (W 8.9768e-05) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.921149 ± 0.00492843 (W 0.00287245) | 0.919969 ± 0.00573407 (W 0.00222959) | 0.693936 ± 0.00326551 (W 0.00240808) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.518558 ± 0.000145029 (W 0.00215073) | 0.517516 ± 0.00100245 (W 0.00293573) | 0.270685 ± 0.000444209 (W 0.00124168) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014527 ± 0.00241992 (W 3.70135e-05) | 0.016401 ± 0.000144639 (W 4.3188e-05) | 0.014157 ± 8.38272e-05 (W 8.67179e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.487089 ± 0.00613341 (W 0.00153802) | 0.483332 ± 0.00228888 (W 0.0017882) | 0.389577 ± 0.00158908 (W 0.0024094) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040857 ± 0.000205137 (W 0.000115398) | 0.040135 ± 8.32666e-05 (W 6.59545e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040896 ± 0.00016383 (W 0.00146158) | 0.040135 ± 8.3865e-05 (W 0.000139833) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.026009 ± 0.000201272 (W 0.000174986) | 0.026029 ± 0.000125831 (W 0.000150374) | 0.033442 ± 8.52467e-05 (W 9.45949e-05) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.074339 ± 0.000234458 (W 0.000241009) | 0.073868 ± 0.000219317 (W 0.000243092) | 0.289349 ± 0.000714203 (W 0.00148322) | · | 🔵 faer-fork 3.89× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.02647 ± 8.50314e-05 (W 0.000103094) | 0.026319 ± 0.000199149 (W 6.05805e-05) | 0.033102 ± 0.000171273 (W 9.22567e-05) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.963448 ± 0.00158968 (W 0.00136682) | 0.961464 ± 0.00640623 (W 0.00368834) | 0.695128 ± 0.00190353 (W 0.00206415) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538897 ± 0.00457211 (W 0.00177067) | 0.540077 ± 0.00261396 (W 0.00167094) | 0.256038 ± 0.000247049 (W 0.00199148) | · | 🔴 faer-fork 2.10× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016431 ± 0.0026477 (W 4.49032e-05) | 0.01622 ± 1.73205e-05 (W 3.58078e-05) | 0.014227 ± 6.30106e-05 (W 6.43529e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.4872 ± 0.000385366 (W 0.00132545) | 0.480167 ± 0.00156226 (W 0.00170131) | 0.265316 ± 0.00105314 (W 0.00152826) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019987 ± 0.000338173 (W 0.000464943) | 0.019206 ± 0.000185518 (W 0.000269709) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.019817 ± 0.000189297 (W 0.000385987) | 0.019016 ± 6.56531e-05 (W 0.0003123) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025869 ± 0.000215933 (W 0.000119349) | 0.029685 ± 0.000272783 (W 0.00121191) | 0.033422 ± 0.000250779 (W 9.73139e-05) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.076483 ± 0.000558607 (W 0.000205527) | 0.14489 ± 0.000320468 (W 0.00263369) | 0.058279 ± 0.00118286 (W 0.000106255) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.026579 ± 0.000584743 (W 9.16259e-05) | 0.029404 ± 0.000636529 (W 0.000711107) | 0.033252 ± 0.000166433 (W 7.56518e-05) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.963881 ± 0.0057015 (W 0.00251641) | 0.953359 ± 0.00508899 (W 0.0023344) | 0.657025 ± 0.00573411 (W 0.00483738) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.539076 ± 0.00217838 (W 0.00191516) | 0.53595 ± 0.00123423 (W 0.00158682) | 0.261428 ± 0.00101998 (W 0.00128681) | · | 🔴 faer-fork 2.06× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014497 ± 0.00263217 (W 4.78978e-05) | 0.01621 ± 0.000168306 (W 4.81892e-05) | 0.014246 ± 8.17945e-05 (W 7.05996e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.488001 ± 0.000670378 (W 0.00143198) | 0.481899 ± 0.00423366 (W 0.0019102) | 0.25744 ± 0.000685479 (W 0.00122931) | · | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.015288 ± 0.000256275 (W 0.000185686) | 0.019686 ± 0.0002071 (W 0.000375654) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.015459 ± 0.000183058 (W 0.000197378) | 0.019697 ± 0.000546698 (W 0.000413607) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026079 ± 0.00026181 (W 9.64365e-05) | 0.030396 ± 0.000576674 (W 0.000373966) | 0.033462 ± 0.000104739 (W 0.00157137) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.077053 ± 0.00125937 (W 0.00159151) | 0.185135 ± 0.0027596 (W 0.00270004) | 0.05882 ± 0.000393798 (W 0.00163197) | 🔵 faer-fork 2.40× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.02667 ± 0.000345789 (W 8.37807e-05) | 0.030437 ± 0.00041502 (W 0.000242699) | 0.033181 ± 8.87149e-05 (W 5.43139e-05) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.962636 ± 0.0096414 (W 0.00273215) | 0.964722 ± 0.0062708 (W 0.00293404) | 0.655393 ± 0.00961267 (W 0.00176171) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537915 ± 0.00290073 (W 0.00210534) | 0.536061 ± 0.000734635 (W 0.0019731) | 0.261217 ± 0.000917828 (W 0.000982605) | · | 🔴 faer-fork 2.06× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.031479 ± 0.000187806 (W 4.63282e-05) | 0.030416 ± 0.000119876 (W 0.00010895) | 0.050784 ± 0.000947034 (W 0.000339392) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.650113 ± 0.000805964 (W 0.00197875) | 0.648812 ± 0.00135081 (W 0.00221912) | 0.810292 ± 0.000740011 (W 0.00271852) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.160118 ± 0.000448765 (W 0.00176163) | 0.158566 ± 0.000661553 (W 0.00106995) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159929 ± 0.000647622 (W 0.000673334) | 0.159748 ± 0.000418248 (W 0.00175205) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.061204 ± 0.000312507 (W 8.69839e-05) | 0.054371 ± 0.000141139 (W 0.000174276) | 0.09657 ± 0.000185203 (W 0.000183601) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.179135 ± 0.000260769 (W 0.00167463) | 0.236882 ± 0.000391383 (W 0.00217005) | 0.16628 ± 0.000195671 (W 0.00134002) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.063598 ± 0.000261969 (W 9.34409e-05) | 0.056746 ± 0.000100167 (W 0.000142934) | 0.094657 ± 0.000243379 (W 0.00161641) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22588 ± 0.000342321 (W 0.00150323) | 1.22036 ± 0.000933023 (W 0.00198392) | 1.34279 ± 0.00283547 (W 0.00332102) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.651526 ± 0.000565092 (W 0.00153757) | 0.64839 ± 0.00133906 (W 0.00134698) | 0.493612 ± 0.00178829 (W 0.00189197) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.03204 ± 0.000104083 (W 8.10389e-05) | 0.030367 ± 7.02377e-05 (W 0.00114961) | 0.050895 ± 0.000445792 (W 0.000731604) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.594479 ± 0.00078435 (W 0.00353313) | 0.617584 ± 0.00182951 (W 0.00211817) | 0.566717 ± 0.00100175 (W 0.00229165) | · | · |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060723 ± 0.000477523 (W 0.000294425) | 0.061024 ± 0.00033946 (W 0.000231016) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.061324 ± 0.000611753 (W 0.000296059) | 0.060583 ± 0.000338364 (W 0.000392766) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.061635 ± 4.50925e-05 (W 0.00130147) | 0.054462 ± 2.3388e-05 (W 9.8297e-05) | 0.09595 ± 0.000744186 (W 0.000357617) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.158335 ± 0.000255376 (W 0.0019305) | 0.286215 ± 0.00171077 (W 0.00177177) | 0.163996 ± 0.00042601 (W 0.00112617) | 🔵 faer-fork 1.81× faster than `faer-upstream` | · |  |
| `solve/n64/b1` | 0.064089 ± 0.000211212 (W 0.00157132) | 0.056886 ± 0.000464759 (W 0.000271681) | 0.093204 ± 0.00045584 (W 0.000383238) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.1153 ± 0.00111823 (W 0.00120895) | 1.14513 ± 0.00313831 (W 0.00150236) | 1.09483 ± 0.00970861 (W 0.00486697) | · | · |  |
| `svd_values/n64/b1` | 0.653329 ± 0.000609667 (W 0.00142254) | 0.650194 ± 0.00135716 (W 0.00161487) | 0.490755 ± 0.00125095 (W 0.00139625) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.031849 ± 0.000419032 (W 7.82253e-05) | 0.030216 ± 7.29178e-05 (W 7.14934e-05) | 0.051667 ± 0.000865257 (W 0.00107097) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.57857 ± 0.00073558 (W 0.00179055) | 0.619005 ± 0.000645807 (W 0.00139211) | 0.537965 ± 0.00241547 (W 0.00123366) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.036869 ± 0.000213823 (W 0.000290399) | 0.060313 ± 0.000318957 (W 0.000385085) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.037099 ± 0.000315817 (W 0.00145024) | 0.061245 ± 0.000442773 (W 0.0011773) | - | 🔵 faer-fork 1.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.061324 ± 0.000376387 (W 0.000122186) | 0.054441 ± 0.000155027 (W 0.000241211) | 0.09648 ± 5.85947e-05 (W 0.000395666) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.159277 ± 0.000341425 (W 0.00131374) | 0.313545 ± 0.00431515 (W 0.00647233) | 0.163775 ± 0.000203284 (W 0.00144135) | 🔵 faer-fork 1.97× faster than `faer-upstream` | · |  |
| `solve/n64/b1` | 0.06394 ± 0.000624045 (W 0.000116644) | 0.056836 ± 0.000151527 (W 0.00197169) | 0.093114 ± 0.000608007 (W 0.000417557) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.08809 ± 0.00408275 (W 0.0013576) | 1.14931 ± 0.000197566 (W 0.00168995) | 1.06668 ± 0.00515112 (W 0.00332699) | 🔵 faer-fork 1.06× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.650513 ± 0.00108533 (W 0.00161527) | 0.648501 ± 0.00253626 (W 0.00191644) | 0.492019 ± 0.00195565 (W 0.00154631) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.031138 ± 0.00010583 (W 9.30054e-05) | 0.029916 ± 9.64365e-05 (W 4.83653e-05) | 0.043271 ± 0.000646165 (W 0.00102877) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.648742 ± 0.000553854 (W 0.00249781) | 0.648551 ± 0.000339547 (W 0.00169209) | 0.799923 ± 0.0018396 (W 0.00170601) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157714 ± 0.000396141 (W 0.00157092) | 0.157304 ± 0.000293207 (W 0.00189885) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159378 ± 0.000868276 (W 0.00138845) | 0.157524 ± 0.000762207 (W 0.00142638) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.053901 ± 0.000319531 (W 0.000105068) | 0.052858 ± 5.57704e-05 (W 0.000113544) | 0.086111 ± 0.00032075 (W 0.00165647) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.163094 ± 0.000816401 (W 0.00160143) | 0.161852 ± 0.000703295 (W 0.00103978) | 0.75558 ± 0.000166257 (W 0.00132337) | · | 🔵 faer-fork 4.63× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.055884 ± 0.000123249 (W 7.93108e-05) | 0.054853 ± 0.000141846 (W 0.00135325) | 0.083486 ± 0.000196088 (W 0.000211046) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.26131 ± 0.00532532 (W 0.00199525) | 1.25141 ± 0.00500699 (W 0.00195) | 1.31058 ± 0.00284414 (W 0.00252558) | · | · |  |
| `svd_values/n64/b1` | 0.627032 ± 0.00140151 (W 0.0016756) | 0.623323 ± 0.00207684 (W 0.00127581) | 0.481218 ± 0.00115222 (W 0.00181796) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.031458 ± 6.50922e-05 (W 6.10098e-05) | 0.029855 ± 0.000292962 (W 7.43996e-05) | 0.04307 ± 0.000409744 (W 8.64598e-05) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.593729 ± 0.00206676 (W 0.00309531) | 0.619135 ± 0.00212688 (W 0.00196832) | 0.556399 ± 0.00059551 (W 0.00235962) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060433 ± 0.000161401 (W 0.000273088) | 0.060183 ± 0.000307546 (W 0.000378779) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.060794 ± 0.000557854 (W 0.000308898) | 0.060663 ± 0.000262592 (W 0.00031566) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.054381 ± 0.000113578 (W 0.00106216) | 0.052838 ± 0.000144777 (W 0.000188296) | 0.08553 ± 0.000210072 (W 0.000215734) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.139129 ± 0.000190867 (W 0.00145531) | 0.208169 ± 0.00311594 (W 0.00143898) | 0.15555 ± 0.000392107 (W 0.0012134) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.057046 ± 0.000678248 (W 9.74433e-05) | 0.055483 ± 0.00030679 (W 7.36363e-05) | 0.082905 ± 0.000318073 (W 0.00177862) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.14676 ± 0.00182072 (W 0.00207025) | 1.17354 ± 0.00169285 (W 0.001261) | 1.01218 ± 0.00276657 (W 0.00356013) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.628483 ± 0.0017442 (W 0.00197591) | 0.624916 ± 0.0014505 (W 0.00180959) | 0.479775 ± 0.00167627 (W 0.00142036) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.031138 ± 0.000471349 (W 7.95318e-05) | 0.029906 ± 0.000103923 (W 8.13953e-05) | 0.04303 ± 0.000207172 (W 0.000124218) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.578319 ± 0.000777466 (W 0.00203979) | 0.619105 ± 0.000910288 (W 0.00158828) | 0.528577 ± 0.00134985 (W 0.00102793) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.037499 ± 0.000182155 (W 0.000282098) | 0.060713 ± 0.000341746 (W 0.000632688) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.03771 ± 3.17857e-05 (W 0.000241844) | 0.061174 ± 0.000220787 (W 0.000221378) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.054011 ± 0.000188008 (W 0.000156733) | 0.053009 ± 0.000136504 (W 0.00155454) | 0.08537 ± 0.000140524 (W 0.00151105) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.138067 ± 0.000636397 (W 0.00047183) | 0.246591 ± 0.00253985 (W 0.00231779) | 0.15548 ± 2.3094e-05 (W 0.00194042) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.056585 ± 0.000508498 (W 0.00216435) | 0.055113 ± 0.000113271 (W 0.000149687) | 0.083095 ± 8.02081e-05 (W 0.00149167) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.12135 ± 0.00236392 (W 0.00156449) | 1.17761 ± 0.00225471 (W 0.00221718) | 0.974418 ± 0.00305881 (W 0.00296408) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625016 ± 0.00121573 (W 0.00218891) | 0.622913 ± 0.000294213 (W 0.00220864) | 0.481349 ± 0.00354722 (W 0.00204211) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/64`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.383646 ± 0.00488058 (W 0.00208127) | 0.39653 ± 0.00683327 (W 0.00321378) | 0.63778 ± 0.00448882 (W 0.00376386) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.97011 ± 0.0369888 (W 0.00559449) | 9.82056 ± 0.0228288 (W 0.00925488) | 10.0159 ± 0.0279275 (W 0.0209448) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91242 ± 0.0065845 (W 0.00912873) | 1.91141 ± 0.00729162 (W 0.00544838) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92079 ± 0.00605151 (W 0.00547999) | 1.91841 ± 0.00617996 (W 0.00257044) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.97578 ± 0.115182 (W 0.00430236) | 1.04909 ± 0.0112328 (W 0.0040579) | 0.97008 ± 0.00295233 (W 0.00217356) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.5911 ± 0.0167225 (W 0.00476901) | 2.85023 ± 0.00239197 (W 0.00507563) | 2.04065 ± 0.0156073 (W 0.00740758) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.994686 ± 0.00582361 (W 0.00245045) | 1.05523 ± 0.00950905 (W 0.00384088) | 0.967788 ± 0.00368406 (W 0.00163921) | 🔵 faer-fork 1.06× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.5586 ± 0.0317413 (W 0.0142912) | 18.4224 ± 0.0242788 (W 0.0178647) | 18.0636 ± 0.020173 (W 0.0391922) | · | · |  |
| `svd_values/n256/b1` | 12.4932 ± 0.0711463 (W 0.00727017) | 12.4446 ± 0.0514543 (W 0.0109901) | 6.983 ± 0.0630323 (W 0.00793672) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.292987 ± 0.000789831 (W 0.00474952) | 0.36384 ± 0.007472 (W 0.0138641) | 0.404074 ± 0.00294674 (W 0.00265992) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.55353 ± 0.000966443 (W 0.012344) | 6.81537 ± 0.0237019 (W 0.0105268) | 4.77138 ± 0.00916364 (W 0.00618697) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.523727 ± 0.00908543 (W 0.00276) | 0.517686 ± 0.00630635 (W 0.00362044) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.51932 ± 0.00298716 (W 0.00199475) | 0.515052 ± 0.00382713 (W 0.00240449) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.62123 ± 0.00865313 (W 0.00386779) | 0.767262 ± 0.00814235 (W 0.00977939) | 0.379709 ± 0.00325147 (W 0.00261706) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.64× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.09314 ± 0.00413864 (W 0.00440127) | 3.08595 ± 0.0194736 (W 0.00930918) | 0.674919 ± 0.00327719 (W 0.00271494) | 🔵 faer-fork 2.82× faster than `faer-upstream` | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.586736 ± 0.00426568 (W 0.00542393) | 0.72309 ± 0.0141109 (W 0.00670634) | 0.367196 ± 0.000510491 (W 0.00187469) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.327 ± 0.0288003 (W 0.041943) | 13.1844 ± 0.0177991 (W 0.0168272) | 12.4886 ± 0.523604 (W 0.021639) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 10.5926 ± 0.0479648 (W 0.0131909) | 10.4527 ± 0.0219012 (W 0.00910437) | 6.12735 ± 0.0042891 (W 0.00745902) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.293788 ± 0.000493731 (W 0.0027041) | 0.350875 ± 0.0117015 (W 0.022856) | 0.357587 ± 0.00045069 (W 0.00297867) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.25247 ± 0.00720553 (W 0.00893858) | 6.81541 ± 0.0139288 (W 0.0211629) | 4.00838 ± 0.0181528 (W 0.0089234) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.286244 ± 0.00218894 (W 0.00251063) | 0.390189 ± 0.00702066 (W 0.0141685) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.284081 ± 0.00332357 (W 0.00426394) | 0.409164 ± 0.0135644 (W 0.014087) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 0.60034 ± 0.00214217 (W 0.00362345) | 0.772712 ± 0.00677071 (W 0.0243344) | 0.346658 ± 0.000264955 (W 0.00326736) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.999778 ± 0.00944182 (W 0.00202639) | 3.33089 ± 0.0202368 (W 0.0182448) | 0.577848 ± 0.00297647 (W 0.00293533) | 🔵 faer-fork 3.33× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.573921 ± 0.00551574 (W 0.00401301) | 0.744188 ± 0.00441375 (W 0.0207518) | 0.334324 ± 0.00202312 (W 0.00226259) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.0954 ± 0.0210096 (W 0.11817) | 13.2181 ± 0.037846 (W 0.0185671) | 11.4708 ± 0.502409 (W 0.0167757) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 10.6959 ± 0.0157542 (W 0.023201) | 10.5533 ± 0.0230076 (W 0.0157652) | 5.99228 ± 0.0081346 (W 0.0121663) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.317332 ± 0.00263503 (W 0.00297573) | 0.323263 ± 0.00109406 (W 0.00194061) | 0.456903 ± 0.00501058 (W 0.00266699) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.92554 ± 0.0259137 (W 0.0147234) | 9.77782 ± 0.0153658 (W 0.0084341) | 9.82859 ± 0.0312868 (W 0.0213103) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.87197 ± 0.00716035 (W 0.00405864) | 1.86846 ± 0.00295292 (W 0.00282231) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.8896 ± 0.00226049 (W 0.00408521) | 1.8906 ± 0.0031079 (W 0.00182474) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.693675 ± 0.114841 (W 0.00337309) | 0.700357 ± 0.115791 (W 0.00245333) | 0.816906 ± 0.0969841 (W 0.00164984) | · | · | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.37585 ± 0.0110577 (W 0.002531) | 1.37346 ± 0.00241228 (W 0.00270556) | 1.88851 ± 0.00711101 (W 0.00634761) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.903828 ± 0.00509016 (W 0.00428256) | 0.903327 ± 0.00696488 (W 0.0048126) | 0.814421 ± 0.00222457 (W 0.00149696) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4723 ± 0.034215 (W 0.0151904) | 18.3162 ± 0.0102307 (W 0.033624) | 17.6819 ± 0.0669707 (W 0.0702903) | · | · |  |
| `svd_values/n256/b1` | 12.2911 ± 0.0607857 (W 0.0114962) | 12.2582 ± 0.0527249 (W 0.0149446) | 6.79473 ± 0.0197394 (W 0.00453078) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.229929 ± 0.00337443 (W 0.00311479) | 0.309058 ± 0.00434308 (W 0.0144343) | 0.239768 ± 0.0209531 (W 0.00301433) | 🔵 faer-fork 1.34× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.5064 ± 0.00310024 (W 0.00654493) | 6.78204 ± 0.0219086 (W 0.0128959) | 4.66767 ± 0.0117179 (W 0.00440418) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.515622 ± 0.00747588 (W 0.00250367) | 0.515091 ± 0.00798169 (W 0.0029955) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.519499 ± 0.00079417 (W 0.00184243) | 0.518458 ± 0.00201866 (W 0.00360437) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.533085 ± 0.000214836 (W 0.00327934) | 0.638341 ± 0.00631975 (W 0.00976499) | 0.33245 ± 0.00837557 (W 0.0042611) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.851659 ± 0.00575469 (W 0.00154203) | 1.3041 ± 0.00677935 (W 0.00335061) | 0.623093 ± 0.00413655 (W 0.00228968) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.499462 ± 0.000983611 (W 0.0037035) | 0.570624 ± 0.00565621 (W 0.0113812) | 0.312684 ± 0.00537344 (W 0.00255574) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.2242 ± 0.00733172 (W 0.0132061) | 13.1031 ± 0.0260671 (W 0.013995) | 12.4637 ± 0.0418826 (W 0.0204439) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.3643 ± 0.0147163 (W 0.0177274) | 10.2527 ± 0.00636075 (W 0.0114467) | 6.16291 ± 0.0531045 (W 0.0118033) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.234007 ± 0.00190954 (W 0.00199768) | 0.293157 ± 0.00227458 (W 0.00730709) | 0.196878 ± 0.0429618 (W 0.00353522) | 🔵 faer-fork 1.25× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.1983 ± 0.00678169 (W 0.00532243) | 6.77545 ± 0.074043 (W 0.0189752) | 3.8887 ± 0.00938753 (W 0.0103825) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.28402 ± 0.00115484 (W 0.00265247) | 0.394466 ± 0.0137839 (W 0.0135803) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.287576 ± 0.00201582 (W 0.00235886) | 0.379758 ± 0.0123634 (W 0.0145451) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 0.515111 ± 0.000766056 (W 0.00235862) | 0.666192 ± 0.0232703 (W 0.0215654) | 0.325328 ± 0.00629672 (W 0.00240232) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.770728 ± 0.00966954 (W 0.0021558) | 1.55524 ± 0.0140991 (W 0.0102541) | 0.547343 ± 0.00222806 (W 0.00258146) | 🔵 faer-fork 2.02× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.478304 ± 0.000805167 (W 0.00329018) | 0.566328 ± 0.0200026 (W 0.0226145) | 0.300851 ± 0.00477997 (W 0.00312424) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 12.9666 ± 0.0165563 (W 0.0300905) | 13.1121 ± 0.032053 (W 0.0155847) | 11.5477 ± 0.0479503 (W 0.0168957) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.544 ± 0.0215607 (W 0.0246892) | 10.3568 ± 0.0217558 (W 0.00996382) | 6.01367 ± 0.0128611 (W 0.00944934) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.23673 ± 0.0176767 (W 0.00330165) | 1.22135 ± 0.00194134 (W 0.00265348) | 1.85044 ± 0.00707258 (W 0.0021899) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.5996 ± 0.0113485 (W 0.0117004) | 17.4173 ± 0.0143217 (W 0.0106799) | 26.4565 ± 0.0276648 (W 0.0286804) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49499 ± 0.0192265 (W 0.0128499) | 7.49141 ± 0.0180909 (W 0.00536824) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.53249 ± 0.00835245 (W 0.00799536) | 7.52379 ± 0.0204708 (W 0.00467409) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.1755 ± 0.00666168 (W 0.00400988) | 2.24794 ± 0.00651576 (W 0.00321993) | 3.31303 ± 0.00889824 (W 0.00682629) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.75963 ± 0.0614699 (W 0.00511224) | 6.42922 ± 0.016456 (W 0.00900349) | 5.67331 ± 0.00953353 (W 0.0150668) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.1069 ± 0.00193225 (W 0.00172089) | 2.18631 ± 0.00678314 (W 0.00171823) | 2.83061 ± 0.00737514 (W 0.00931236) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.1368 ± 0.103702 (W 0.0201234) | 34.1352 ± 0.127383 (W 0.150227) | 43.664 ± 0.300445 (W 0.0818703) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.232 ± 0.0518494 (W 0.0687538) | 19.2537 ± 0.0870293 (W 0.0176142) | 18.139 ± 0.0189738 (W 0.0163895) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.769606 ± 0.00669113 (W 0.0123829) | 0.806125 ± 0.00199569 (W 0.00460836) | 0.794923 ± 0.00162064 (W 0.00849308) | · | · |  |
| `eigh/n256/b1` | 8.8364 ± 0.0467339 (W 0.00914827) | 11.4087 ± 0.0327337 (W 0.00806745) | 10.1503 ± 0.0230846 (W 0.0520006) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92255 ± 0.0114533 (W 0.00336118) | 1.91496 ± 0.00787663 (W 0.00420719) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92785 ± 0.00383425 (W 0.00149872) | 1.92629 ± 0.00937414 (W 0.00227485) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.43719 ± 0.0125864 (W 0.0129257) | 1.59544 ± 0.00480489 (W 0.0133332) | 1.0215 ± 0.00679801 (W 0.00239029) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.48655 ± 0.00486756 (W 0.00386347) | 4.71961 ± 0.0605226 (W 0.00855785) | 1.63212 ± 0.000757762 (W 0.00437476) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.34653 ± 0.00813136 (W 0.00690327) | 1.49708 ± 0.0134471 (W 0.0147208) | 0.895652 ± 0.0017665 (W 0.00402528) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.5349 ± 0.0108555 (W 0.0257198) | 21.6491 ± 0.0543264 (W 0.0373621) | 21.1902 ± 0.0539524 (W 0.0279285) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.2262 ± 0.00465449 (W 0.0176337) | 16.2031 ± 0.118654 (W 0.0292795) | 11.457 ± 0.0432171 (W 0.0215996) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.722629 ± 0.0111564 (W 0.00444615) | 0.789714 ± 0.00559454 (W 0.0114505) | 0.661815 ± 0.00604296 (W 0.00444292) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.79039 ± 0.00893919 (W 0.00732568) | 11.2111 ± 0.0117887 (W 0.0499351) | 7.99776 ± 0.0220266 (W 0.0140476) | 🔵 faer-fork 1.44× faster than `faer-upstream` | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01042 ± 0.0137004 (W 0.00217355) | 1.28113 ± 0.0920623 (W 0.0767644) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.00769 ± 0.004788 (W 0.00391518) | 1.29144 ± 0.098206 (W 0.101293) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n256/b1` | 1.31948 ± 0.00536103 (W 0.00425995) | 1.49723 ± 0.049586 (W 0.00804036) | 0.700397 ± 0.00592292 (W 0.0047837) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.88× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.14881 ± 0.00134674 (W 0.00390537) | 4.74958 ± 0.0952682 (W 0.0226528) | 1.62275 ± 0.0036421 (W 0.00115962) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.21538 ± 0.0340164 (W 0.00237101) | 1.36698 ± 0.00141143 (W 0.00866125) | 0.664761 ± 0.00146026 (W 0.00402927) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 16.7901 ± 0.197683 (W 0.0260217) | 20.8371 ± 0.280686 (W 0.0679687) | 17.2159 ± 0.0967655 (W 0.0210921) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.8876 ± 0.0130227 (W 0.0173886) | 16.4297 ± 0.231613 (W 0.0294725) | 9.57804 ± 0.0462719 (W 0.0165641) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.14128 ± 0.00149021 (W 0.00192801) | 1.12919 ± 0.00271566 (W 0.00195027) | 1.61689 ± 0.00198621 (W 0.00362586) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.5484 ± 0.0316771 (W 0.0190597) | 17.3535 ± 0.0176316 (W 0.016155) | 26.2254 ± 0.0660986 (W 0.0211816) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.43135 ± 0.0270502 (W 0.00658584) | 7.39673 ± 0.0258544 (W 0.00525291) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44728 ± 0.0224709 (W 0.00489123) | 7.45968 ± 0.0178605 (W 0.00685708) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.05702 ± 0.0102422 (W 0.00106824) | 2.03604 ± 0.00623813 (W 0.00485309) | 3.15121 ± 0.0048595 (W 0.0118563) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.47632 ± 0.0485326 (W 0.00540485) | 4.48025 ± 0.0458865 (W 0.00483874) | 5.52029 ± 0.0368429 (W 0.00875476) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.98087 ± 0.00237528 (W 0.00162057) | 1.9722 ± 0.00408234 (W 0.00180071) | 2.6662 ± 0.0401024 (W 0.00973129) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.7788 ± 0.0545806 (W 0.0222181) | 33.7702 ± 0.0114207 (W 0.0111277) | 43.4812 ± 1.07727 (W 0.0503654) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.0218 ± 0.00976433 (W 0.0198571) | 18.9971 ± 0.027711 (W 0.0172868) | 18.1193 ± 1.08042 (W 0.0617092) | · | · | `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.690519 ± 0.0116304 (W 0.0117053) | 0.715537 ± 0.00245829 (W 0.00986277) | 0.586806 ± 0.038 (W 0.0102962) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 8.76049 ± 0.0102128 (W 0.00681599) | 11.3193 ± 0.0187643 (W 0.00834285) | 9.9946 ± 0.0181072 (W 0.0103484) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90431 ± 0.0148289 (W 0.00190852) | 1.9088 ± 0.0133173 (W 0.00253616) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92287 ± 0.00714685 (W 0.00173257) | 1.92221 ± 0.0062983 (W 0.00261129) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.30817 ± 0.00824843 (W 0.00851407) | 1.40361 ± 0.0080875 (W 0.0131015) | 0.972406 ± 0.0198797 (W 0.00297064) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.16855 ± 0.0246727 (W 0.00255907) | 2.54462 ± 0.022319 (W 0.00358324) | 1.57512 ± 0.022548 (W 0.00205386) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.23033 ± 0.00637644 (W 0.0092282) | 1.30227 ± 0.0106231 (W 0.0119516) | 0.85684 ± 0.0179506 (W 0.00460457) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.2626 ± 0.00744844 (W 0.0421284) | 21.3345 ± 0.0680316 (W 0.0452683) | 21.1149 ± 0.590809 (W 0.0215927) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.011 ± 0.0141931 (W 0.0156995) | 16.1384 ± 0.0160271 (W 0.0157409) | 11.1488 ± 0.495412 (W 0.0190204) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.627871 ± 0.00152621 (W 0.00399779) | 0.697031 ± 0.00567639 (W 0.0064581) | 0.459117 ± 0.0149114 (W 0.00234332) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 7.72349 ± 0.0136583 (W 0.012255) | 11.1239 ± 0.00705743 (W 0.0322488) | 7.85552 ± 0.0138498 (W 0.00981318) | 🔵 faer-fork 1.44× faster than `faer-upstream` | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00719 ± 0.00661867 (W 0.00186415) | 1.30443 ± 0.104932 (W 0.0822174) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01221 ± 0.00767321 (W 0.00181883) | 1.31062 ± 0.0128354 (W 0.0994303) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.20375 ± 0.00125201 (W 0.00389645) | 1.29067 ± 0.00840314 (W 0.00751711) | 0.678766 ± 0.00354308 (W 0.00274772) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.83001 ± 0.0174039 (W 0.00243158) | 2.65082 ± 0.0159325 (W 0.0142276) | 1.58692 ± 0.0133778 (W 0.00285651) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.09621 ± 0.00552288 (W 0.00264032) | 1.1779 ± 0.00843233 (W 0.00650941) | 0.651917 ± 0.00427054 (W 0.00525252) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 16.5175 ± 0.00177782 (W 0.0301376) | 20.9043 ± 0.111341 (W 0.0879409) | 17.1929 ± 0.166534 (W 0.0139417) | 🔵 faer-fork 1.27× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.67 ± 0.0208996 (W 0.0101004) | 16.0312 ± 0.168495 (W 0.0155127) | 9.63682 ± 0.147772 (W 0.0137967) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/256`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.556929 ± 0.00680463 (W 0.0023659) | 0.563181 ± 0.00747672 (W 0.00337985) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554545 ± 0.00318306 (W 0.00218714) | 0.564193 ± 0.00594077 (W 0.00300581) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.469066 ± 0.00483781 (W 0.00932901) | 0.469316 ± 0.00203463 (W 0.00297755) | 0.658478 ± 0.132946 (W 0.00373672) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.0489 ± 0.00464403 (W 0.00281383) | 1.85701 ± 0.00778799 (W 0.00337063) | 0.90531 ± 0.00096065 (W 0.002867) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50632 ± 0.0054477 (W 0.00257782) | 2.49362 ± 0.00581576 (W 0.00237769) | 3.05984 ± 0.035109 (W 0.00599007) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48774 ± 0.00378474 (W 0.00407207) | 1.48481 ± 0.00188443 (W 0.00562636) | 1.38731 ± 0.158989 (W 0.00332985) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.392141 ± 0.0032715 (W 0.00270882) | 0.157433 ± 0.00223783 (W 0.00130141) | - | 🔴 faer-fork 2.49× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.389486 ± 0.00607645 (W 0.0018132) | 0.157604 ± 0.00209146 (W 0.00169403) | - | 🔴 faer-fork 2.47× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.445372 ± 0.0014232 (W 0.00227232) | 0.434131 ± 0.00475546 (W 0.00575796) | 0.326169 ± 0.00214387 (W 0.00139563) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.00344 ± 0.00264453 (W 0.00230422) | 3.38977 ± 0.310071 (W 0.141598) | 0.45504 ± 0.00844693 (W 0.00910387) | 🔵 faer-fork 3.38× faster than `faer-upstream` | 🔴 faer-fork 2.21× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.31013 ± 0.00265492 (W 0.00436162) | 2.14029 ± 0.00355727 (W 0.00573785) | 2.14243 ± 0.23071 (W 0.00691445) | 🔴 faer-fork 1.08× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.45717 ± 0.00659571 (W 0.00555667) | 1.5277 ± 0.00659422 (W 0.00413402) | 0.946077 ± 0.144439 (W 0.0067804) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.414433 ± 0.00496091 (W 0.00654439) | 0.144991 ± 0.00331749 (W 0.00636998) | - | 🔴 faer-fork 2.86× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.412028 ± 0.00947879 (W 0.00505683) | 0.145572 ± 0.00550635 (W 0.00780137) | - | 🔴 faer-fork 2.83× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.440012 ± 0.000829332 (W 0.00269852) | 0.423841 ± 0.00670939 (W 0.00291849) | 0.31087 ± 0.000841304 (W 0.00193124) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.03603 ± 0.0213603 (W 0.00186057) | 3.08566 ± 0.0690132 (W 0.123321) | 0.320258 ± 0.000370515 (W 0.00242171) | 🔵 faer-fork 2.98× faster than `faer-upstream` | 🔴 faer-fork 3.23× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.37803 ± 0.0625095 (W 0.0156324) | 2.25585 ± 0.00511165 (W 0.058014) | 1.67592 ± 0.289713 (W 0.00252052) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.48027 ± 0.00200861 (W 0.00591974) | 1.62747 ± 0.00298667 (W 0.00599455) | 0.811023 ± 0.185254 (W 0.00221896) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.571306 ± 0.0182542 (W 0.00184693) | 0.58969 ± 0.0112573 (W 0.00229337) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.570175 ± 0.0147867 (W 0.00176631) | 0.56808 ± 0.016544 (W 0.00237606) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.384928 ± 0.00055197 (W 0.00204708) | 0.383936 ± 0.000201083 (W 0.00269678) | 0.285613 ± 0.000454578 (W 0.00211869) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.77706 ± 0.00154182 (W 0.00172395) | 0.770528 ± 0.0160877 (W 0.0026806) | 0.763004 ± 0.00288146 (W 0.00240576) | · | · |  |
| `svd_thin/1024x64/b1` | 2.45274 ± 0.127606 (W 0.00442223) | 2.44559 ± 0.0037429 (W 0.00301827) | 2.80936 ± 0.00483598 (W 0.00584054) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.39798 ± 0.0039173 (W 0.00254729) | 1.39682 ± 0.00237732 (W 0.00341942) | 1.24164 ± 0.00368654 (W 0.00421874) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.424993 ± 0.0149093 (W 0.00216221) | 0.193551 ± 0.0142125 (W 0.00279781) | - | 🔴 faer-fork 2.20× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.401369 ± 0.0145714 (W 0.00212453) | 0.17136 ± 0.0132139 (W 0.00174947) | - | 🔴 faer-fork 2.34× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.359431 ± 0.00151511 (W 0.00361313) | 0.353299 ± 0.00105368 (W 0.00258399) | 0.286004 ± 0.00125252 (W 0.00198397) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.754938 ± 0.0112962 (W 0.00174041) | 0.831281 ± 0.00755147 (W 0.00313845) | 0.417951 ± 0.00342464 (W 0.00830043) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.25378 ± 0.0102649 (W 0.00386382) | 2.09418 ± 0.00338086 (W 0.00272093) | 1.82439 ± 0.00232437 (W 0.00563825) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.37778 ± 0.00310171 (W 0.00258565) | 1.44545 ± 0.00604419 (W 0.00470739) | 0.907102 ± 0.00220599 (W 0.00547054) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.428961 ± 0.00985559 (W 0.00440479) | 0.187429 ± 0.0210863 (W 0.00617452) | - | 🔴 faer-fork 2.29× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.425765 ± 0.0159713 (W 0.00413096) | 0.163906 ± 0.0121912 (W 0.00604986) | - | 🔴 faer-fork 2.60× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.355864 ± 0.360814 (W 0.00189485) | 0.355663 ± 0.000291143 (W 0.00241461) | 0.287716 ± 0.00178354 (W 0.00191644) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.776038 ± 0.00899127 (W 0.00269708) | 0.928411 ± 0.0026224 (W 0.0033343) | 0.302665 ± 0.00269828 (W 0.00244169) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 2.56× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.29533 ± 0.00600987 (W 0.0118707) | 2.20768 ± 0.00656192 (W 0.00737343) | 1.63448 ± 0.00410244 (W 0.00234818) | · | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39967 ± 0.00205184 (W 0.00312795) | 1.54453 ± 0.00121138 (W 0.00506961) | 0.786638 ± 0.00228247 (W 0.00318351) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19856 ± 0.00490106 (W 0.00557061) | 2.19942 ± 0.0233032 (W 0.00199219) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.19701 ± 0.00186428 (W 0.0018834) | 2.20534 ± 0.0209575 (W 0.00490528) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.04825 ± 0.00298896 (W 0.00125602) | 1.05358 ± 0.00303133 (W 0.00167959) | 1.22808 ± 0.258611 (W 0.00397658) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 2.56617 ± 0.0531893 (W 0.00305255) | 3.91889 ± 0.112012 (W 0.0181198) | 2.37964 ± 0.0123596 (W 0.00598369) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 6.01174 ± 0.0130666 (W 0.0128742) | 5.98807 ± 0.0215928 (W 0.00237391) | 9.60881 ± 0.157189 (W 0.0224809) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.08908 ± 0.0224394 (W 0.00302071) | 3.06441 ± 0.0108522 (W 0.00347951) | 3.79664 ± 0.0207268 (W 0.00599365) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.39559 ± 0.00401312 (W 0.00183813) | 0.592787 ± 0.00954038 (W 0.0015123) | - | 🔴 faer-fork 2.35× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.39796 ± 0.00139825 (W 0.00272439) | 0.596414 ± 0.00311757 (W 0.00180644) | - | 🔴 faer-fork 2.34× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.803431 ± 0.00250874 (W 0.00265885) | 0.797979 ± 0.00644174 (W 0.00169813) | 1.40645 ± 0.00386834 (W 0.00674977) | · | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.27264 ± 0.021963 (W 0.00337059) | 3.90629 ± 0.0118098 (W 0.0704714) | 1.3798 ± 0.00144063 (W 0.00426635) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.84763 ± 0.166613 (W 0.260231) | 3.6615 ± 0.00909934 (W 0.00620683) | 5.47785 ± 0.0183764 (W 0.0485467) | 🔴 faer-fork 1.32× slower than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.79436 ± 0.00287987 (W 0.00363627) | 2.42294 ± 0.0062102 (W 0.00700126) | 3.20598 ± 0.256068 (W 0.0314221) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.34686 ± 0.044524 (W 0.0347707) | 0.408803 ± 0.0486701 (W 0.0371732) | - | 🔴 faer-fork 3.29× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.37498 ± 0.0304858 (W 0.0359713) | 0.472552 ± 0.0417696 (W 0.0368419) | - | 🔴 faer-fork 2.91× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.758265 ± 0.00120679 (W 0.00172117) | 0.750792 ± 0.000918749 (W 0.00272529) | 1.48184 ± 0.00354801 (W 0.00687761) | · | 🔵 faer-fork 1.95× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.33916 ± 0.00973939 (W 0.0105017) | 3.86637 ± 0.0417184 (W 0.0863768) | 0.869873 ± 0.00271984 (W 0.00180434) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 2.69× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.82032 ± 0.0115009 (W 0.298744) | 3.66474 ± 0.196819 (W 0.165217) | 4.41016 ± 0.00649235 (W 0.0113663) | 🔴 faer-fork 1.32× slower than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.84662 ± 0.00412199 (W 0.00786127) | 2.48161 ± 0.0104125 (W 0.00933635) | 2.75934 ± 0.289087 (W 0.0201258) | 🔴 faer-fork 1.15× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.24674 ± 0.0113472 (W 0.00117496) | 2.25466 ± 0.00848268 (W 0.0019071) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.25909 ± 0.0102669 (W 0.00295169) | 2.25471 ± 0.0104789 (W 0.00245066) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.92181 ± 0.00584916 (W 0.00224157) | 0.922122 ± 0.0031155 (W 0.00113784) | 1.08911 ± 0.0100978 (W 0.00482244) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.28977 ± 0.0166508 (W 0.00239463) | 2.2584 ± 0.0239661 (W 0.00466862) | 2.26418 ± 0.00874949 (W 0.00400706) | · | · |  |
| `svd_thin/1024x64/b1` | 5.90503 ± 0.00663815 (W 0.00407372) | 5.87926 ± 0.0242098 (W 0.00492141) | 8.55624 ± 0.0234268 (W 0.0117913) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.96605 ± 0.0195535 (W 0.00166458) | 2.9346 ± 0.00587923 (W 0.00190835) | 3.65961 ± 0.0261871 (W 0.00528479) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.45389 ± 0.00330366 (W 0.00227901) | 0.639303 ± 0.000702454 (W 0.00209944) | - | 🔴 faer-fork 2.27× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.45456 ± 0.00322064 (W 0.00272235) | 0.638852 ± 0.000601354 (W 0.00270432) | - | 🔴 faer-fork 2.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.682093 ± 0.00190878 (W 0.00364734) | 0.687713 ± 0.00272299 (W 0.00197878) | 1.0972 ± 0.0229696 (W 0.00302164) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.96131 ± 0.00307948 (W 0.00432302) | 1.58002 ± 0.00543606 (W 0.00425552) | 1.34971 ± 0.00379121 (W 0.00271986) | 🔴 faer-fork 1.24× slower than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.7206 ± 0.00181134 (W 0.00517558) | 3.55283 ± 0.00230286 (W 0.00317422) | 5.45334 ± 0.0143547 (W 0.0146444) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.69954 ± 0.00446053 (W 0.00325259) | 2.33345 ± 0.000903506 (W 0.012006) | 2.78858 ± 0.00891751 (W 0.00244995) | 🔴 faer-fork 1.16× slower than `faer-upstream` | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.36769 ± 0.0390808 (W 0.041603) | 0.53043 ± 0.0463213 (W 0.0474505) | - | 🔴 faer-fork 2.58× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.43444 ± 0.0438254 (W 0.0343215) | 0.533876 ± 0.00380663 (W 0.0428028) | - | 🔴 faer-fork 2.69× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.634744 ± 0.000663474 (W 0.00308775) | 0.648821 ± 0.00226861 (W 0.00255203) | 1.08124 ± 0.0156509 (W 0.0019747) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.00447 ± 0.0116691 (W 0.00872209) | 1.64894 ± 0.00780396 (W 0.00817814) | 0.859964 ± 0.00681483 (W 0.00317908) | 🔴 faer-fork 1.22× slower than `faer-upstream` | 🔴 faer-fork 2.33× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.72351 ± 0.157281 (W 0.031063) | 3.56944 ± 0.00354102 (W 0.0364748) | 4.3804 ± 0.0183375 (W 0.00711811) | 🔴 faer-fork 1.32× slower than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.75048 ± 0.00507689 (W 0.00633522) | 2.39004 ± 0.00389944 (W 0.00884439) | 2.28789 ± 0.0132031 (W 0.00278816) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `eigh/1024x64`, `householder_apply/1024x64`, `solve/1024x64`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.395879 ± 0.00253636 (W 0.00201379) | 0.511024 ± 0.0108514 (W 0.00256291) | 0.932781 ± 0.136522 (W 0.00344104) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 2.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.996661 ± 0.00374954 (W 0.00439896) | 1.01344 ± 0.0055364 (W 0.00576358) | 1.34059 ± 0.00141827 (W 0.00207902) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.45672 ± 0.00102177 (W 0.00517574) | 2.44799 ± 0.000949316 (W 0.00598832) | 4.13293 ± 0.0432396 (W 0.00551066) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.42014 ± 0.00930096 (W 0.00237783) | 1.41276 ± 0.00269995 (W 0.00242021) | 2.60316 ± 0.0117769 (W 0.0048317) | · | 🔵 faer-fork 1.83× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.206525 ± 0.000649721 (W 0.00148318) | 0.368257 ± 0.0138447 (W 0.0132334) | 0.297796 ± 0.0130087 (W 0.00123973) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.613976 ± 0.00474922 (W 0.00570479) | 0.694726 ± 0.00502386 (W 0.00404678) | 0.426566 ± 0.00142257 (W 0.00219531) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.25859 ± 0.00317984 (W 0.00285577) | 2.09592 ± 0.00256005 (W 0.0039885) | 3.04341 ± 0.215785 (W 0.0153562) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.39384 ± 0.000318858 (W 0.00212635) | 1.46058 ± 0.00688699 (W 0.00346421) | 2.09729 ± 0.0099691 (W 0.00327271) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.180197 ± 0.00151258 (W 0.00173634) | 0.336989 ± 0.0113516 (W 0.010201) | 0.171269 ± 0.00222906 (W 0.0016066) | 🔵 faer-fork 1.87× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.548664 ± 0.00647753 (W 0.00548578) | 0.748067 ± 0.00538795 (W 0.00644364) | 0.259104 ± 0.00122409 (W 0.00158877) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.30399 ± 0.00182051 (W 0.00569356) | 2.19891 ± 0.00280291 (W 0.00702645) | 3.20399 ± 0.0244092 (W 0.00759589) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.41196 ± 0.0027672 (W 0.00384739) | 1.56894 ± 0.00574666 (W 0.00819933) | 2.07952 ± 0.0211715 (W 0.00214657) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.313996 ± 0.000645004 (W 0.00191113) | 0.312834 ± 0.00199936 (W 0.0030147) | 3.1319 ± 0.0044102 (W 0.00323319) | · | 🔵 faer-fork 9.97× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.568181 ± 0.00332564 (W 0.0028775) | 0.561568 ± 0.00591314 (W 0.00232137) | 6.30007 ± 0.00888688 (W 0.00864777) | · | 🔵 faer-fork 11.09× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.52605 ± 0.0023402 (W 0.00589052) | 2.51349 ± 0.00260457 (W 0.00340018) | 3.84694 ± 0.00535407 (W 0.0106654) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.4767 ± 0.00667911 (W 0.00597105) | 1.4707 ± 0.00518735 (W 0.00495322) | 2.42738 ± 0.00189166 (W 0.00601313) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.11768 ± 0.000772573 (W 0.00185128) | 0.141855 ± 0.0157272 (W 0.0219921) | 0.242132 ± 0.00648539 (W 0.00329332) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 2.06× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.203499 ± 1.75046 (W 0.00118815) | 0.262249 ± 0.00187057 (W 0.00188036) | 0.368377 ± 0.0010964 (W 0.00292993) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/64x1024/b1` | 2.31761 ± 0.00429146 (W 0.00458187) | 2.16168 ± 0.00555735 (W 0.00359852) | 3.03611 ± 0.108996 (W 0.0126548) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.44484 ± 0.00281817 (W 0.00471339) | 1.51561 ± 0.0112872 (W 0.00622468) | 2.04298 ± 0.0414972 (W 0.00346893) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.089887 ± 0.000986413 (W 0.000640308) | 0.138158 ± 0.000762357 (W 0.00815457) | 0.134942 ± 0.00219891 (W 0.00184266) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.158275 ± 0.00255818 (W 0.00230088) | 0.320087 ± 0.00686304 (W 0.00316063) | 0.218507 ± 0.000885091 (W 0.0015636) | 🔵 faer-fork 2.02× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.3685 ± 0.00579397 (W 0.00936165) | 2.26334 ± 0.00684087 (W 0.0046384) | 2.85872 ± 0.0915013 (W 0.00422679) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.47093 ± 0.00954474 (W 0.00271826) | 1.61352 ± 0.0126696 (W 0.00895326) | 2.06586 ± 0.00622086 (W 0.00484775) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 1.02309 ± 0.0041405 (W 0.00301846) | 1.05663 ± 0.0010632 (W 0.00299431) | 2.32815 ± 0.0253823 (W 0.00325009) | · | 🔵 faer-fork 2.28× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.56862 ± 0.00752515 (W 0.00478012) | 2.60084 ± 0.00647618 (W 0.00466718) | 3.51126 ± 0.020391 (W 0.00334997) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.94295 ± 0.0164267 (W 0.00840765) | 5.91131 ± 0.0212008 (W 0.00309634) | 12.7603 ± 0.0395443 (W 0.0522745) | · | 🔵 faer-fork 2.15× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.9738 ± 0.0179772 (W 0.0024587) | 2.94816 ± 0.0155882 (W 0.00964253) | 5.55485 ± 0.030579 (W 0.0131448) | · | 🔵 faer-fork 1.87× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.418991 ± 0.000999567 (W 0.00182503) | 0.498641 ± 0.0486743 (W 0.0427471) | 0.948009 ± 0.00636226 (W 0.00566047) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔵 faer-fork 2.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.97502 ± 0.00682563 (W 0.00448892) | 1.06097 ± 0.00524179 (W 0.00347955) | 1.35952 ± 0.00595053 (W 0.00517472) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.7594 ± 0.00418611 (W 0.00554316) | 3.57819 ± 0.00409628 (W 0.00589278) | 7.87483 ± 0.250422 (W 0.0835093) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.65× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.7022 ± 0.00465244 (W 0.00374455) | 2.32165 ± 0.00484614 (W 0.00477833) | 3.66829 ± 0.061684 (W 0.0130078) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.329414 ± 0.000223773 (W 0.00140942) | 0.45004 ± 0.0225665 (W 0.00259857) | 0.726326 ± 0.0234615 (W 0.00402671) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 2.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.716788 ± 0.00166758 (W 0.00641455) | 1.04142 ± 0.0129973 (W 0.0136593) | 0.762814 ± 0.00508259 (W 0.00263035) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.77723 ± 0.171631 (W 0.192695) | 3.63913 ± 0.0173694 (W 0.273806) | 6.17408 ± 0.0709197 (W 0.0275015) | 🔴 faer-fork 1.31× slower than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.74065 ± 0.0114173 (W 0.00711464) | 2.38195 ± 0.00775219 (W 0.0117692) | 3.22522 ± 0.0177636 (W 0.0177672) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.898999 ± 0.00186479 (W 0.00229772) | 0.89557 ± 0.00324944 (W 0.00360527) | 2.12594 ± 0.00361977 (W 0.00216659) | · | 🔵 faer-fork 2.36× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.2255 ± 0.00853845 (W 0.00324753) | 2.22345 ± 0.0149579 (W 0.00199407) | 16.8751 ± 0.0152834 (W 0.0119647) | · | 🔵 faer-fork 7.58× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 6.0617 ± 0.0117254 (W 0.00500891) | 6.00906 ± 0.0274426 (W 0.00302411) | 11.7834 ± 0.131327 (W 0.0216266) | · | 🔵 faer-fork 1.94× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 3.09275 ± 0.0251608 (W 0.0014475) | 3.08429 ± 0.0197902 (W 0.00369137) | 5.34411 ± 0.0442543 (W 0.00862116) | · | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.30014 ± 0.00138346 (W 0.00136197) | 0.331398 ± 0.0536298 (W 0.0525031) | 0.584531 ± 0.0056243 (W 0.00380959) | · | 🔵 faer-fork 1.95× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.665012 ± 0.00119845 (W 0.00157491) | 0.719653 ± 0.000777934 (W 0.00157251) | 1.28794 ± 0.00222005 (W 0.00548264) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.94× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.87749 ± 0.00798512 (W 0.00637159) | 3.70339 ± 0.00120151 (W 0.00529489) | 7.49318 ± 0.362624 (W 0.0213772) | 🔴 faer-fork 1.32× slower than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.80186 ± 0.00459479 (W 0.0039802) | 2.42154 ± 0.00434289 (W 0.00491151) | 3.75232 ± 0.0638597 (W 0.00908862) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.208268 ± 0.000630889 (W 0.00115934) | 0.279211 ± 0.00224468 (W 0.0217863) | 0.407309 ± 0.00377369 (W 0.00216627) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.96× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.410646 ± 0.0023426 (W 0.0034124) | 0.691009 ± 0.00675779 (W 0.0116794) | 0.708082 ± 0.0016399 (W 0.00222812) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.84364 ± 0.189445 (W 0.0351582) | 3.72152 ± 0.0177056 (W 0.272453) | 6.13524 ± 0.164522 (W 0.0125194) | 🔴 faer-fork 1.30× slower than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.84284 ± 0.00416353 (W 0.011812) | 2.47848 ± 0.0194225 (W 0.00705363) | 3.2025 ± 0.0908454 (W 0.0141337) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `cholesky/64x1024`, `eigh/64x1024`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
