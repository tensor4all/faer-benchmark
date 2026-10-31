# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `3a8edf02b82eb6c69362799591e0a970c4ceb8d3`
- t4a-faer version: `0.27.1`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `15cd9ab20a818e48f09156324aa0df83e07a6354`
- toolkit commit: `b71624bef111ce941bddaedcce3fdb6eab40f9eb`
- measured binary SHA-256: `08dfe05f486712df37b7465d2aa9bd81f89be689389ab4921466696ee14574f7`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-30T22:42:31.515625Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --vendor openblas --engines faer-fork,lapack-openblas --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 6 --prime-ms 250 --label weekly-20261030-openblas --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261030T200019Z-weekly-20261030-openblas/`

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
  - `lapack-openblas` — CBLAS `?gemm` plus LAPACK drivers linked against OpenBLAS: vendor calls and their marshalling, vendor-owned threading. The vendor's own thread budget is set by the harness before the row and read back, and the vendor identity and the dispatched kernel are recorded in the manifest.
    Identity: the OpenBLAS build recorded in this run's manifest (`providers[openblas]`)
    Caveat: LAPACK and BLAS own their threading, so this row's thread budget is the vendor's, not the harness pool's. Where a family has no LAPACK route the row is absent and the CSV says the case was skipped for it.
    As measured: linked static; openblas 0.3.32; kernel dispatched to `Cooperlake`; pthread threading; config `OpenBLAS 0.3.32 DYNAMIC_ARCH NO_AFFINITY Cooperlake MAX_THREADS=24`

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
Each process retains 5 chronological calls; 6 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 1.42%, worst 30131.54% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 246 of 2328 engine cells exceed 5% and carry `!`; median within-process relative SD 0.37%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023595 ± 1.60499e-05 (W 1.50424e-05) | 0.002214 ± 1.40807e-05 (W 2.06615e-05) | 🔴 faer-fork 1.07× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017127 ± 4.70053e-05 (W 0.000582452) | 0.016761 ± 5.88784e-05 (W 1.78885e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0564805 ± 0.000134574 (W 0.00132776) | 0.056029 ± 0.000183107 (W 2.91424e-05) | · |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002414 ± 2.90086e-05 (W 2.75815e-05) | 0.002214 ± 1.89737e-05 (W 2.55876e-05) | 🔴 faer-fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.011626 ± 0.000169435 (W 0.00062045) | 0.0167715 ± 7.1323e-05 (W 1.6954e-05) | 🔵 faer-fork 1.44× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.022958 ± 0.000312686 (W 0.000200448) | 0.0560245 ± 0.00024934 (W 4.45432e-05) | 🔵 faer-fork 2.44× faster than `lapack-openblas` |  |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.00239 ± 1.89631e-05 (W 2.31038e-05) | 0.002199 ± 3.39116e-05 (W 2.5987e-05) | 🔴 faer-fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.009894 ± 8.94964e-05 (W 6.44988e-05) | 0.0168765 ± 0.000107611 (W 2.70391e-05) | 🔵 faer-fork 1.71× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.020353 ± 8.46168e-05 (W 7.74365e-05) | 0.056385 ± 0.000219411 (W 4.72141e-05) | 🔵 faer-fork 2.77× faster than `lapack-openblas` |  |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002359 ± 2.69103e-05 (W 1.50323e-05) | 0.002209 ± 1.64975e-05 (W 1.37986e-05) | 🔴 faer-fork 1.07× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017097 ± 5.97676e-05 (W 2.66555e-05) | 0.0167665 ± 4.15243e-05 (W 1.78982e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0565205 ± 0.000592647 (W 0.000151779) | 0.056019 ± 0.000135515 (W 5.01413e-05) | · |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002395 ± 3.35306e-05 (W 1.29086e-05) | 0.002204 ± 2.2286e-05 (W 1.68761e-05) | 🔴 faer-fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0114165 ± 0.000137556 (W 0.000147015) | 0.016796 ± 8.13152e-05 (W 1.63259e-05) | 🔵 faer-fork 1.47× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.023479 ± 0.000160823 (W 0.000313491) | 0.056195 ± 0.000237183 (W 0.000815083) | 🔵 faer-fork 2.39× faster than `lapack-openblas` |  |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.00239 ± 2.59281e-05 (W 1.9279e-05) | 0.002204 ± 2.48227e-05 (W 2.51313e-05) | 🔴 faer-fork 1.08× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0098835 ± 5.13641e-05 (W 9.2236e-05) | 0.016776 ± 5.12471e-05 (W 2.09497e-05) | 🔵 faer-fork 1.70× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.020283 ± 0.000109509 (W 0.000100437) | 0.0563555 ± 0.000180124 (W 8.73347e-05) | 🔵 faer-fork 2.78× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088015 ± 3.30903e-05 (W 1.67094e-05) | 0.0115515 ± 2.87449e-05 (W 2.57977e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067401 ± 0.000252382 (W 0.00138418) | 0.085705 ± 0.000195817 (W 0.000816353) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.225565 ± 0.000845562 (W 0.0019517) | 0.275258 ± 0.000827311 (W 0.00207678) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0095375 ± 0.000169533 (W 0.000126571) | 0.011526 ± 5.76209e-05 (W 2.07037e-05) | 🔵 faer-fork 1.21× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.028879 ± 6.95921e-05 (W 0.000200722) | 0.025948 ± 0.000145021 (W 0.000283572) | 🔴 faer-fork 1.11× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.0787265 ± 0.000223764 (W 0.000400504) | 0.0784165 ± 0.000478353 (W 0.00115646) | · |  |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.009923 ± 1.22061 (W 0.000100268) | 0.0115715 ± 5.80884e-05 (W 4.23693e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.026965 ± 7.61577e-05 (W 8.25821e-05) | 0.026179 ± 0.00013349 (W 0.000266469) | · |  |
| `gemm/96x96x96/b1` | 0.039719 ± 0.00203978 (W 9.69807e-05) | 0.0549425 ± 0.00031292 (W 0.000248351) | 🔵 faer-fork 1.38× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008796 ± 4.43054e-05 (W 1.49561e-05) | 0.011532 ± 2.90086e-05 (W 3.03994e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067451 ± 0.000269267 (W 0.000109866) | 0.0857255 ± 0.000443966 (W 0.000149762) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.226708 ± 0.000768656 (W 0.00171312) | 0.275179 ± 0.00119892 (W 0.00212892) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0098935 ± 0.000226276 (W 0.000221598) | 0.0116015 ± 4.121e-05 (W 2.7014e-05) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.028924 ± 0.000148628 (W 0.000264685) | 0.026019 ± 0.000216625 (W 0.000264094) | 🔴 faer-fork 1.11× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.0783215 ± 0.000728694 (W 0.000327367) | 0.0786615 ± 0.000538453 (W 0.000607046) | · |  |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0098785 ± 9.19944e-05 (W 5.81988e-05) | 0.011557 ± 6.20121e-05 (W 2.84793e-05) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0270155 ± 0.000140186 (W 8.65402e-05) | 0.026029 ± 0.000111846 (W 0.000240419) | · |  |
| `gemm/96x96x96/b1` | 0.039638 ± 0.000108355 (W 0.000120584) | 0.055168 ± 0.000384457 (W 0.000304402) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.134005 ± 0.000144292 (W 0.00155861) | 0.163169 ± 0.000554902 (W 0.001592) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.452102 ± 0.00130302 (W 0.00219383) | 0.539648 ± 0.00153532 (W 0.00263617) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07879 ± 0.00237403 (W 0.00282671) | 1.27213 ± 0.00595602 (W 0.00383233) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.6162 ± 0.00795429 (W 0.00719868) | 4.2254 ± 0.00897699 (W 0.00760984) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.62506 ± 0.0434247 (W 0.0153256) | 10.0563 ± 0.0193513 (W 0.013294) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.495 ± 0.113156 (W 0.039486) | 33.6916 ± 0.0965869 (W 0.0407464) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.045615 ± 0.00024428 (W 0.000353948) | 0.0504185 ± 0.000633616 (W 0.000625791) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.118856 ± 0.000641443 (W 0.00152813) | 0.148332 ± 0.00124332 (W 0.00149318) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.288415 ± 0.0013972 (W 0.00175599) | 0.342639 ± 0.00234858 (W 0.00233936) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.909762 ± 0.00415364 (W 0.0023207) | 1.09894 ± 0.0052154 (W 0.00474934) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.19695 ± 0.00652095 (W 0.00358726) | 2.57194 ± 0.0140364 (W 0.00757249) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.47219 ± 0.016631 (W 0.0100016) | 8.68069 ± 0.0368332 (W 0.0074707) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.032416 ± 0.00045907 (W 0.000481157) | 0.02931 ± 0.000362039 (W 0.000447968) | 🔴 faer-fork 1.11× slower than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.086552 ± 0.000847324 (W 0.00117001) | 0.0841915 ± 0.000727822 (W 0.000653299) | · |  |
| `gemm/256x256x256/b1` | 0.16352 ± 0.00513433 (W 0.00142102) | 0.181027 ± 0.00201888 (W 0.0020337) | 🔵 faer-fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.474708 ± 0.0121765 (W 0.00238135) | 0.552491 ± 0.0215067 (W 0.00341671) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 1.13853 ± 0.0224598 (W 0.00357813) | 1.31651 ± 0.0456999 (W 0.00583553) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 3.90057 ± 0.0580262 (W 0.0147149) | 4.53636 ± 0.109378 (W 0.0151402) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13403 ± 0.000185592 (W 0.0015211) | 0.163149 ± 0.000281166 (W 0.00193982) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.45309 ± 0.00231639 (W 0.00259248) | 0.538485 ± 0.00134023 (W 0.00246595) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.0763 ± 0.00234386 (W 0.001949) | 1.27181 ± 0.0050234 (W 0.00220372) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.61748 ± 0.0055088 (W 0.00381352) | 4.23209 ± 0.00814961 (W 0.00746946) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.62459 ± 0.0505048 (W 0.00984615) | 10.0512 ± 0.0244745 (W 0.0126664) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4591 ± 0.0970512 (W 0.046734) | 33.7083 ± 0.0746194 (W 0.0402153) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.045184 ± 0.000333876 (W 0.000279144) | 0.0494965 ± 0.00104686 (W 0.00135081) | 🔵 faer-fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.119263 ± 0.000794784 (W 0.00146355) | 0.148523 ± 0.00164785 (W 0.0014446) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.288427 ± 0.00124732 (W 0.00144087) | 0.338726 ± 0.00273929 (W 0.00217236) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.909521 ± 0.00371822 (W 0.00290369) | 1.09576 ± 0.00877617 (W 0.00531966) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.1932 ± 0.00547751 (W 0.00349006) | 2.57226 ± 0.010243 (W 0.00690598) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.4671 ± 0.0330522 (W 0.00662025) | 8.66837 ± 0.0332336 (W 0.0119406) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.03247 ± 0.000788762 (W 0.000865195) | 0.0298105 ± 0.000448515 (W 0.000493894) | 🔴 faer-fork 1.09× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.086847 ± 0.000310548 (W 0.00103764) | 0.084152 ± 0.000429859 (W 0.00142907) | · |  |
| `gemm/256x256x256/b1` | 0.163601 ± 0.00478755 (W 0.00143132) | 0.180201 ± 0.00342728 (W 0.00203469) | 🔵 faer-fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.478509 ± 0.0113496 (W 0.00413188) | 0.551783 ± 0.0229058 (W 0.00255266) | 🔵 faer-fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 1.13802 ± 0.0243754 (W 0.00381402) | 1.31308 ± 0.0477291 (W 0.00490295) | 🔵 faer-fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 3.89746 ± 0.0493767 (W 0.00772655) | 4.53181 ± 0.1048 (W 0.0170571) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539074 ± 0.00226982 (W 0.00225509) | 0.65865 ± 0.000910072 (W 0.00245949) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81348 ± 0.00530185 (W 0.00289367) | 2.17995 ± 0.00267781 (W 0.00556737) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.2892 ± 0.011757 (W 0.00562593) | 5.1715 ± 0.00870567 (W 0.0127013) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4815 ± 0.0296624 (W 0.017972) | 17.3157 ± 0.0373863 (W 0.0142817) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3117 ± 0.0500258 (W 0.0348339) | 40.9959 ± 0.067816 (W 0.0506713) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.652 ± 0.282896 (W 0.0881868) | 137.64 ± 0.084065 (W 0.0992135) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.153095 ± 0.000650193 (W 0.000330234) | 0.176273 ± 0.0014321 (W 0.00174898) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.453805 ± 0.00282156 (W 0.00233057) | 0.55719 ± 0.00152465 (W 0.00232245) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.10352 ± 0.00285379 (W 0.00235601) | 1.32405 ± 0.0044556 (W 0.00427897) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.60757 ± 0.0113435 (W 0.0058079) | 4.3809 ± 0.0202066 (W 0.00663433) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.61977 ± 0.018878 (W 0.0163774) | 10.3832 ± 0.0316944 (W 0.0135911) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.2435 ± 0.0342256 (W 0.023088) | 34.6833 ± 0.0545892 (W 0.0283519) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.103077 ± 0.000403259 (W 0.000695776) | 0.0946505 ± 0.00043009 (W 0.00182809) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.234026 ± 0.00207186 (W 0.00203669) | 0.294526 ± 0.00195691 (W 0.00179519) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.580368 ± 0.010872 (W 0.00313994) | 0.683923 ± 0.00873826 (W 0.00306222) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.83273 ± 0.0322028 (W 0.00370946) | 2.2004 ± 0.0700413 (W 0.00550766) | 🔵 faer-fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 4.4517 ± 0.0739301 (W 0.0116092) | 5.26722 ± 0.118355 (W 0.00948357) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 14.9696 ± 0.318704 (W 0.0261596) | 17.782 ± 0.184877 (W 0.0232426) | 🔵 faer-fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.540784 ± 0.001963 (W 0.00254518) | 0.659736 ± 0.001056 (W 0.00264399) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81571 ± 0.00503955 (W 0.00334657) | 2.18005 ± 0.0029274 (W 0.00682529) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.29173 ± 0.00887798 (W 0.00869247) | 5.17172 ± 0.00561659 (W 0.00880433) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4628 ± 0.0323451 (W 0.0236253) | 17.3134 ± 0.0163807 (W 0.0111145) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3464 ± 0.0363067 (W 0.0256883) | 41.0334 ± 0.0545374 (W 0.0245372) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.621 ± 0.163208 (W 0.0697165) | 137.583 ± 0.172167 (W 0.115465) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.152444 ± 0.000767201 (W 0.000243711) | 0.177123 ± 0.00105319 (W 0.00162162) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.454193 ± 0.00233308 (W 0.00197074) | 0.557383 ± 0.00104923 (W 0.00289698) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.10466 ± 0.00401222 (W 0.00226663) | 1.32032 ± 0.00437997 (W 0.00314753) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.60745 ± 0.0136882 (W 0.0042745) | 4.376 ± 0.0147124 (W 0.00567476) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.62292 ± 0.0236158 (W 0.0126572) | 10.3868 ± 0.0254231 (W 0.0144878) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.2549 ± 0.0776395 (W 0.0343319) | 34.7049 ± 0.0710588 (W 0.0403258) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.103173 ± 0.000671703 (W 0.000427002) | 0.094186 ± 0.000449181 (W 0.00141416) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.235689 ± 0.00215078 (W 0.00160693) | 0.295438 ± 0.00186901 (W 0.00190368) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.582134 ± 0.0134537 (W 0.0022519) | 0.68406 ± 0.00889712 (W 0.00246684) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 1.83707 ± 0.0330441 (W 0.00376882) | 2.19654 ± 0.0708908 (W 0.00291196) | 🔵 faer-fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 4.46163 ± 0.0751455 (W 0.011011) | 5.27432 ± 0.106863 (W 0.0115331) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 14.9721 ± 0.313759 (W 0.0343734) | 17.7835 ± 0.175412 (W 0.0355356) | 🔵 faer-fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26014 ± 0.0148861 (W 0.00599993) | 1.63937 ± 0.0257586 (W 0.00671904) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.07766 ± 0.00466251 (W 0.00277893) | 1.45264 ± 0.00421224 (W 0.014787) | 🔵 faer-fork 1.35× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.09011 ± 0.00559643 (W 0.00142493) | 1.37097 ± 0.00774413 (W 0.00244632) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.424602 ± 0.00166836 (W 0.0045883) | 0.511607 ± 0.00776701 (W 0.00477865) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.317308 ± 0.00180332 (W 0.00199499) | 0.475752 ± 0.00353125 (W 0.00269947) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.276663 ± 0.00230967 (W 0.00140551) | 0.346801 ± 0.00182597 (W 0.00286164) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.422808 ± 0.00228978 (W 0.00307324) | 0.282468 ± 0.00175627 (W 0.00383023) | 🔴 faer-fork 1.50× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.188192 ± 0.00212639 (W 0.00193863) | 0.314285 ± 0.00180774 (W 0.00162784) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.141424 ± 0.000713439 (W 0.00146552) | 0.177361 ± 0.00111644 (W 0.00151362) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.04738 ± 0.00601794 (W 0.00283957) | 1.69298 ± 0.00541712 (W 0.00512852) | 🔵 faer-fork 1.62× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.10607 ± 0.00449462 (W 0.0035957) | 1.4387 ± 0.00447529 (W 0.00572289) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.13619 ± 0.00286108 (W 0.00243435) | 1.38405 ± 0.00467961 (W 0.00324843) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.329734 ± 0.00284674 (W 0.00354088) | 0.422818 ± 0.00480291 (W 0.00321043) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.298768 ± 0.00135021 (W 0.00308487) | 0.479224 ± 0.0048242 (W 0.00341836) | 🔵 faer-fork 1.60× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.295813 ± 0.001012 (W 0.00258368) | 0.362806 ± 0.00203045 (W 0.00208393) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.200564 ± 0.0011247 (W 0.0030065) | 0.223657 ± 0.0106018 (W 0.0037376) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.180785 ± 0.00152539 (W 0.00305959) | 0.322136 ± 0.00171298 (W 0.00213067) | 🔵 faer-fork 1.78× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.156655 ± 0.0016865 (W 0.00167692) | 0.194977 ± 0.00211561 (W 0.00182539) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.14523 ± 0.011927 (W 0.00830363) | 6.01835 ± 0.0418689 (W 0.0106532) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.40329 ± 0.00908738 (W 0.00893217) | 5.76357 ± 0.0239938 (W 0.0157073) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.40665 ± 0.00698862 (W 0.00768727) | 5.43316 ± 0.010516 (W 0.0101333) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.66226 ± 0.011218 (W 0.00495477) | 1.73695 ± 0.0062826 (W 0.0058656) | · |  |
| `gemm/4096x16x240/b1` | 1.16941 ± 0.00510422 (W 0.00485669) | 1.67517 ± 0.00728944 (W 0.00479199) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.11728 ± 0.00419424 (W 0.00133325) | 1.38267 ± 0.00544665 (W 0.00384645) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.901979 ± 0.0143555 (W 0.00980616) | 0.931168 ± 0.00843457 (W 0.00791661) | · |  |
| `gemm/4096x16x240/b1` | 0.593501 ± 0.00295161 (W 0.00278614) | 0.998949 ± 0.00184884 (W 0.00625257) | 🔵 faer-fork 1.68× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.569252 ± 0.00206226 (W 0.00318994) | 0.696681 ± 0.00197514 (W 0.00281996) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.0792 ± 0.0177074 (W 0.0120997) | 5.81438 ± 0.0272932 (W 0.0128542) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.43222 ± 0.015537 (W 0.0103595) | 5.75207 ± 0.0424344 (W 0.0176182) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.45888 ± 0.0120925 (W 0.0109765) | 5.54566 ± 0.0109734 (W 0.0103562) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.18387 ± 0.00229706 (W 0.00326954) | 1.49769 ± 0.00759854 (W 0.00524363) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.16557 ± 0.00541184 (W 0.00623684) | 1.74103 ± 0.0149078 (W 0.00787812) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.16728 ± 0.00779435 (W 0.0100697) | 1.44541 ± 0.00823622 (W 0.0043519) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.660467 ± 0.0044821 (W 0.006917) | 0.821701 ± 0.00289075 (W 0.00611545) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.59366 ± 0.00711793 (W 0.00254518) | 1.00555 ± 0.00203197 (W 0.00235196) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.576201 ± 0.00470359 (W 0.00464845) | 0.768433 ± 0.00362806 (W 0.00415534) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.13475 ± 0.00129634 (W 0.00252259) | 1.37458 ± 0.00608834 (W 0.00219689) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.296659 ± 0.000847091 (W 0.00199037) | 0.364936 ± 0.00144749 (W 0.0023692) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.155799 ± 2.36902 (W 0.00128881) | 0.194491 ± 0.00179006 (W 0.00180396) | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08881 ± 0.00435537 (W 0.00273379) | 1.36944 ± 0.00730212 (W 0.00335817) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.278053 ± 0.00149128 (W 0.0014261) | 0.347628 ± 0.001128 (W 0.00204655) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.143117 ± 0.000688539 (W 0.00163477) | 0.179565 ± 0.00149471 (W 0.00124347) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.44519 ± 0.00986072 (W 0.00659557) | 5.57605 ± 0.0171461 (W 0.0152149) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.16058 ± 0.00738339 (W 0.00456014) | 1.44398 ± 0.00764933 (W 0.00674512) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.571397 ± 0.00336767 (W 0.00379679) | 0.766495 ± 0.00349683 (W 0.00298869) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.39463 ± 0.0059925 (W 0.00942707) | 5.4313 ± 0.0159981 (W 0.00957718) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12478 ± 0.00286534 (W 0.00165857) | 1.38609 ± 0.00180912 (W 0.00336745) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.571869 ± 0.00448654 (W 0.00280877) | 0.69494 ± 0.00223984 (W 0.00251368) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0033565 ± 0.000175009 (W 3.69763e-05) | 0.004338 ± 4e-05 (W 4.37303e-05) | 🔵 faer-fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014948 ± 0.000796955 (W 3.40597e-05) | 0.019106 ± 6.46344e-05 (W 7.12118e-05) | 🔵 faer-fork 1.28× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0309125 ± 0.000897736 (W 6.40179e-05) | 0.0447485 ± 0.000222678 (W 0.00011569) | 🔵 faer-fork 1.45× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112309 ± 0.000353249 (W 0.00181608) | 0.123074 ± 0.000176671 (W 0.000656622) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.495134 ± 0.00162685 (W 0.0020465) | 0.435767 ± 0.00153426 (W 0.00209155) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.20091 ± 0.00586443 (W 0.00354512) | 0.971559 ± 0.00348124 (W 0.000759403) | 🔴 faer-fork 1.24× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0125085 ± 0.000112388 (W 7.54653e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.052829 ± 0.00053385 (W 0.000254907) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.146118 ± 0.000550805 (W 0.00253139) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0083205 ± 2.74038e-05 (W 5.1708e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008345 ± 5.13251e-05 (W 4.31926e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040771 ± 6.12985e-05 (W 0.000117256) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0410615 ± 0.000368218 (W 7.81149e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.121717 ± 0.000567907 (W 0.000927118) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.122312 ± 0.000921699 (W 0.00135038) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0090015 ± 0.000100765 (W 7.34149e-05) | 0.0100635 ± 0.000223759 (W 9.94507e-05) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0314435 ± 0.00028761 (W 0.00014431) | 0.039453 ± 0.000191966 (W 0.000170276) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0768585 ± 0.000438622 (W 0.00187673) | 0.0978475 ± 0.00118683 (W 0.00245527) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.030943 ± 0.000152952 (W 0.000143325) | 0.032701 ± 0.000788414 (W 0.00017565) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.11246 ± 0.000325856 (W 0.00152993) | 0.12938 ± 0.00209236 (W 0.00205264) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.272821 ± 0.0105531 (W 0.00384863) | 0.383601 ± 0.0149444 (W 0.00360908) | 🔵 faer-fork 1.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0225165 ± 0.000171881 (W 0.000124886) | 0.017648 ± 0.000364249 (W 9.83226e-05) | 🔴 faer-fork 1.28× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.079949 ± 0.000401799 (W 0.000323594) | 0.0668895 ± 0.00125245 (W 0.00025211) | 🔴 faer-fork 1.20× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.173303 ± 0.00114723 (W 0.00162417) | 0.186171 ± 0.00288184 (W 0.00109195) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.010199 ± 7.66822e-05 (W 6.09848e-05) | 0.010149 ± 0.000158058 (W 4.19033e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.032916 ± 0.000153975 (W 0.000116834) | 0.038737 ± 0.00124057 (W 0.000761104) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.0808005 ± 0.000536522 (W 0.00341651) | 0.0903685 ± 0.00125632 (W 0.000218901) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.168693 ± 0.000540805 (W 0.00158156) | 0.18472 ± 0.000611045 (W 0.00152175) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 0.871525 ± 0.00954276 (W 0.00287187) | 0.69832 ± 0.0138582 (W 0.00546028) | 🔴 faer-fork 1.25× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.07926 ± 0.0331378 (W 0.00196103) | 1.6297 ± 0.0534037 (W 0.00567497) | 🔴 faer-fork 1.28× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.066494 ± 0.000228189 (W 0.00150031) | 0.0780505 ± 0.000304731 (W 0.000236007) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.236789 ± 0.00129258 (W 0.00180429) | 0.273817 ± 0.00133082 (W 0.00196677) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.54199 ± 0.00266725 (W 0.00204432) | 0.672418 ± 0.00744419 (W 0.00276629) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000736 ± 1.3784e-05 (W 2.39294e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001588 ± 3.0605e-05 (W 2.55509e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0028505 ± 8.17941e-05 (W 2.93853e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0034665 ± 0.000124291 (W 3.2214e-05) | 0.004353 ± 3.25064e-05 (W 4.48257e-05) | 🔵 faer-fork 1.26× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0158845 ± 0.00140614 (W 4.42875e-05) | 0.019115 ± 0.000205748 (W 9.55222e-05) | 🔵 faer-fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0318745 ± 0.00165225 (W 4.98593e-05) | 0.044398 ± 0.000292037 (W 0.000159826) | 🔵 faer-fork 1.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113685 ± 0.000640062 (W 0.0001475) | 0.106408 ± 0.000563823 (W 0.00163957) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.486883 ± 0.00133904 (W 0.00259938) | 0.356539 ± 0.00419232 (W 0.00194816) | 🔴 faer-fork 1.37× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.15876 ± 0.00503029 (W 0.00467732) | 0.781373 ± 0.00148199 (W 0.00205559) | 🔴 faer-fork 1.48× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0138355 ± 0.000142927 (W 8.80596e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.055168 ± 0.00041617 (W 0.000275603) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.160778 ± 0.00260075 (W 0.0024445) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0061115 ± 0.000487125 (W 0.000122482) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.006953 ± 0.00032466 (W 0.000211696) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0190155 ± 0.000179244 (W 0.000297891) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0204785 ± 0.000248756 (W 0.000341819) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.043922 ± 0.00025052 (W 0.000252959) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.04557 ± 0.000111436 (W 0.0010664) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0090865 ± 2.87083e-05 (W 6.815e-05) | 0.010099 ± 0.000139719 (W 0.000156456) | 🔵 faer-fork 1.11× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0316735 ± 9.80689e-05 (W 0.00015313) | 0.0388475 ± 0.00131301 (W 0.00135109) | 🔵 faer-fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.0759665 ± 0.000334803 (W 0.0018822) | 0.098334 ± 0.00153293 (W 0.00251853) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0324205 ± 0.000119685 (W 0.000152956) | 0.032726 ± 0.000678556 (W 0.000727602) | · |  |
| `qr/n64/b1` | 0.106103 ± 0.000213124 (W 0.0016771) | 0.129535 ± 0.0015026 (W 0.00182396) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.230714 ± 0.000411284 (W 0.00275756) | 0.376246 ± 0.00810672 (W 0.00376427) | 🔵 faer-fork 1.63× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023489 ± 0.000129422 (W 0.000121713) | 0.0176175 ± 0.000293705 (W 9.6065e-05) | 🔴 faer-fork 1.33× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.0714725 ± 0.000496723 (W 0.000308885) | 0.066358 ± 0.00179191 (W 0.000226377) | 🔴 faer-fork 1.08× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.140055 ± 0.00080086 (W 0.000538791) | 0.185541 ± 0.0021215 (W 0.00212064) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.01065 ± 0.000127907 (W 6.67615e-05) | 0.0103145 ± 8.41205e-05 (W 4.78614e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033577 ± 0.000194056 (W 0.00015439) | 0.038742 ± 0.000407186 (W 0.000111726) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0853895 ± 0.000874274 (W 0.00252085) | 0.090403 ± 0.000942706 (W 0.000834424) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.170246 ± 0.000936049 (W 0.000828085) | 0.183812 ± 0.000556486 (W 0.00204602) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 0.84867 ± 0.00343291 (W 0.00271102) | 0.642357 ± 0.0165145 (W 0.0029761) | 🔴 faer-fork 1.32× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n96/b1` | 2.04414 ± 0.00591522 (W 0.00559008) | 1.61182 ± 0.0153095 (W 0.00643498) | 🔴 faer-fork 1.27× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.0676665 ± 0.000355838 (W 0.000166072) | 0.077975 ± 0.00081377 (W 0.000129691) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.242728 ± 0.00120647 (W 0.00144349) | 0.27335 ± 0.0018923 (W 0.00217891) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.575767 ± 0.00442858 (W 0.00213703) | 0.65459 ± 0.0119637 (W 0.00276716) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0009515 ± 1.42922e-05 (W 2.09551e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002054 ± 3.19312e-05 (W 1.96358e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003717 ± 4.13944e-05 (W 4.65977e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0034515 ± 0.000161118 (W 2.90272e-05) | 0.004353 ± 4.27785e-05 (W 4.61295e-05) | 🔵 faer-fork 1.26× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0161 ± 0.00172786 (W 3.37861e-05) | 0.01904 ± 0.000106997 (W 0.000104712) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0315035 ± 0.00254991 (W 8.78063e-05) | 0.044573 ± 0.000251914 (W 0.00017014) | 🔵 faer-fork 1.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113697 ± 0.000526264 (W 0.000243085) | 0.105436 ± 0.00101451 (W 0.00154911) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.484736 ± 0.00122292 (W 0.00206057) | 0.350917 ± 0.00103705 (W 0.00213313) | 🔴 faer-fork 1.38× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.1605 ± 0.00307742 (W 0.00263215) | 0.761445 ± 0.0024634 (W 0.00199429) | 🔴 faer-fork 1.52× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.013801 ± 9.12661e-05 (W 7.22157e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0555485 ± 0.000936273 (W 0.000417618) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.1687 ± 0.00148517 (W 0.00219558) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.006081 ± 0.00014224 (W 0.000175318) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.006297 ± 0.000389716 (W 0.000199934) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014847 ± 0.000117805 (W 0.000261419) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0164955 ± 0.000277939 (W 0.000487508) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.032115 ± 0.000806314 (W 0.000707916) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0321395 ± 0.000681364 (W 0.00043605) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.009052 ± 6.99161e-05 (W 6.68871e-05) | 0.010139 ± 0.000194325 (W 0.000145419) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0317245 ± 0.000262269 (W 0.00015984) | 0.0395435 ± 0.00128525 (W 0.000160456) | 🔵 faer-fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.077389 ± 0.000611638 (W 0.00233424) | 0.0982885 ± 0.00197384 (W 0.00252719) | 🔵 faer-fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.0324 ± 0.000407249 (W 0.000177447) | 0.032666 ± 0.000510641 (W 0.000802663) | · |  |
| `qr/n64/b1` | 0.104585 ± 0.000788983 (W 0.00252821) | 0.129115 ± 0.00200775 (W 0.00105417) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.226477 ± 0.0014107 (W 0.0034426) | 0.374619 ± 0.00187407 (W 0.00289337) | 🔵 faer-fork 1.65× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.023449 ± 0.000101303 (W 9.01408e-05) | 0.017678 ± 0.000317686 (W 8.89618e-05) | 🔴 faer-fork 1.33× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.0717135 ± 0.000177369 (W 0.000453429) | 0.0666335 ± 0.000886574 (W 0.000251044) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.135067 ± 0.000595839 (W 0.000449824) | 0.185657 ± 0.00299174 (W 0.00177212) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.01065 ± 0.000215936 (W 7.68865e-05) | 0.0103745 ± 0.000275791 (W 4.2656e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033898 ± 0.000408158 (W 0.000144381) | 0.038587 ± 0.00121594 (W 0.000147927) | 🔵 faer-fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.087288 ± 0.00135847 (W 0.00246383) | 0.0903435 ± 0.00184442 (W 0.00175774) | · |  |
| `svd_thin/n32/b1` | 0.171024 ± 0.00980633 (W 0.00173142) | 0.185013 ± 0.00168104 (W 0.00187325) | 🔵 faer-fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.844834 ± 0.00395415 (W 0.00209164) | 0.649596 ± 0.0048517 (W 0.00278373) | 🔴 faer-fork 1.30× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.05911 ± 0.00729487 (W 0.00352566) | 1.61316 ± 0.00810773 (W 0.00387316) | 🔴 faer-fork 1.28× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.0679165 ± 0.000240791 (W 0.0001562) | 0.07826 ± 0.000669667 (W 0.000178244) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.242565 ± 0.00180468 (W 0.00140805) | 0.274276 ± 0.00262268 (W 0.00228135) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.5935 ± 0.00320543 (W 0.00198338) | 0.67297 ± 0.00451054 (W 0.00257698) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0009715 ± 2.56963e-05 (W 2.0852e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002044 ± 4.95648e-05 (W 1.4569e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0034265 ± 0.000104854 (W 3.44949e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003086 ± 0.000137745 (W 3.04318e-05) | 0.003421 ± 5.67465e-05 (W 3.4426e-05) | 🔵 faer-fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014522 ± 0.000751067 (W 3.12349e-05) | 0.015719 ± 0.000160576 (W 7.39429e-05) | 🔵 faer-fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0301315 ± 0.00125105 (W 6.00411e-05) | 0.0376455 ± 0.000177407 (W 0.000164126) | 🔵 faer-fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112199 ± 0.000348933 (W 0.000839701) | 0.121717 ± 0.000322184 (W 0.000777449) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.495144 ± 0.00171705 (W 0.0022664) | 0.431748 ± 0.00177817 (W 0.00244897) | 🔴 faer-fork 1.15× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.20234 ± 0.00418068 (W 0.00225475) | 0.962957 ± 0.0019734 (W 0.0012667) | 🔴 faer-fork 1.25× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.01091 ± 0.000217997 (W 9.27195e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.047258 ± 0.000477224 (W 0.000263998) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.134341 ± 0.000548792 (W 0.00198297) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008471 ± 4.97996e-05 (W 4.28966e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008466 ± 3.93277e-05 (W 5.11742e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040465 ± 9.81305e-05 (W 8.51171e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040796 ± 0.000394556 (W 8.39651e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.123986 ± 0.000421097 (W 0.000904878) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.123851 ± 0.000282036 (W 0.00177494) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007489 ± 7.21122e-05 (W 8.54803e-05) | 0.008486 ± 0.000118216 (W 0.000113701) | 🔵 faer-fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026289 ± 0.000145438 (W 0.000744894) | 0.033277 ± 0.000343008 (W 0.000110086) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.064244 ± 0.000376687 (W 0.00230296) | 0.077128 ± 0.00010184 (W 0.000231078) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0292095 ± 0.000170819 (W 0.000158931) | 0.030101 ± 0.000122704 (W 0.000171142) | · |  |
| `qr/n64/b1` | 0.105176 ± 0.000394208 (W 0.000276094) | 0.12134 ± 0.000556202 (W 0.00142789) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.257032 ± 0.0102133 (W 0.00243762) | 0.343136 ± 0.00926723 (W 0.00306459) | 🔵 faer-fork 1.33× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.015549 ± 0.000103473 (W 9.48833e-05) | 0.016015 ± 0.00027698 (W 0.000131498) | · | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.064871 ± 0.000323829 (W 0.000218706) | 0.062056 ± 0.00086703 (W 0.00153449) | · |  |
| `qr_factor/n96/b1` | 0.139975 ± 0.0017758 (W 0.000778917) | 0.173266 ± 0.00292045 (W 0.0017467) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0082055 ± 9.95197e-05 (W 6.01197e-05) | 0.0086315 ± 8.86175e-05 (W 5.40235e-05) | 🔵 faer-fork 1.05× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.02689 ± 0.000186505 (W 0.000123362) | 0.03242 ± 0.000148536 (W 7.87077e-05) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0683475 ± 0.000523956 (W 0.000201466) | 0.076452 ± 0.000317431 (W 0.000107874) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.170697 ± 0.000438984 (W 0.00176623) | 0.178568 ± 0.00147762 (W 0.00150576) | · |  |
| `svd_thin/n64/b1` | 0.913329 ± 0.0108597 (W 0.00194351) | 0.648605 ± 0.00873679 (W 0.00282973) | 🔴 faer-fork 1.41× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.07215 ± 0.0335292 (W 0.0014759) | 1.56154 ± 0.0425132 (W 0.00482267) | 🔴 faer-fork 1.33× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.066063 ± 0.000258876 (W 0.000627045) | 0.074123 ± 0.000244443 (W 0.00016808) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.240953 ± 0.00127017 (W 0.00208441) | 0.268253 ± 0.00136612 (W 0.0016999) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.552949 ± 0.00304781 (W 0.00274953) | 0.666207 ± 0.00304617 (W 0.00223544) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000791 ± 7.36659e-06 (W 1.55497e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001788 ± 3.18355e-05 (W 1.82311e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003046 ± 7.81682e-05 (W 3.16225e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0033565 ± 0.000260254 (W 3.06872e-05) | 0.003361 ± 2.92147e-05 (W 4.00739e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0147075 ± 0.000774281 (W 3.81482e-05) | 0.015599 ± 0.000250701 (W 8.69669e-05) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0309175 ± 0.00167924 (W 6.62192e-05) | 0.03757 ± 0.000289559 (W 0.000168486) | 🔵 faer-fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.114138 ± 0.00045679 (W 0.000235784) | 0.104725 ± 0.0003215 (W 0.0015281) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.488446 ± 0.00201871 (W 0.00200965) | 0.352411 ± 0.00413859 (W 0.00273524) | 🔴 faer-fork 1.39× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.1606 ± 0.00448237 (W 0.0040028) | 0.770234 ± 0.00168157 (W 0.00190259) | 🔴 faer-fork 1.51× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0121125 ± 0.0001741 (W 7.8444e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.049943 ± 0.000301308 (W 0.000950899) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.148718 ± 0.00195183 (W 0.00192099) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.006482 ± 0.00010015 (W 0.000267472) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.006552 ± 0.000126792 (W 0.000192218) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019266 ± 0.000295674 (W 0.000228596) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0196465 ± 0.000279175 (W 0.00017943) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.044227 ± 0.000297745 (W 0.000254459) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.044643 ± 0.000243221 (W 0.000243307) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007494 ± 5.24404e-05 (W 7.80721e-05) | 0.0083605 ± 5.00416e-05 (W 0.00011324) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026489 ± 0.000199222 (W 0.000135662) | 0.032896 ± 0.000337136 (W 0.000760837) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.064931 ± 0.000819639 (W 0.00220616) | 0.076832 ± 0.000307054 (W 0.00176849) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.030732 ± 0.000221679 (W 0.000139389) | 0.029675 ± 0.000298888 (W 0.000151933) | · |  |
| `qr/n64/b1` | 0.098984 ± 0.000261187 (W 0.000495034) | 0.117513 ± 0.000856541 (W 0.00107278) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.216073 ± 0.00071385 (W 0.00303807) | 0.338676 ± 0.00417904 (W 0.00219561) | 🔵 faer-fork 1.57× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.016406 ± 7.36218e-05 (W 0.000134692) | 0.01597 ± 0.000167078 (W 9.78118e-05) | · | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.0642435 ± 0.000354666 (W 0.00144212) | 0.060753 ± 0.000315975 (W 0.000202989) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.125684 ± 0.000858793 (W 0.000323173) | 0.171629 ± 0.00121842 (W 0.000952057) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.008727 ± 6.85296e-05 (W 6.16165e-05) | 0.008551 ± 5.51014e-05 (W 5.43285e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0276965 ± 0.000223884 (W 0.000227293) | 0.0322705 ± 0.000245785 (W 9.70746e-05) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0729415 ± 0.000644218 (W 0.00267322) | 0.0756805 ± 0.00019858 (W 0.00092251) | · |  |
| `svd_thin/n32/b1` | 0.17198 ± 0.00106628 (W 0.00184771) | 0.176624 ± 0.000705337 (W 0.0018721) | · |  |
| `svd_thin/n64/b1` | 0.8922 ± 0.00334341 (W 0.0023404) | 0.61964 ± 0.00895816 (W 0.00252312) | 🔴 faer-fork 1.44× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.01552 ± 0.0360024 (W 0.00332172) | 1.47755 ± 0.0358165 (W 0.00378613) | 🔴 faer-fork 1.36× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.067421 ± 0.000315904 (W 0.000206159) | 0.0743185 ± 0.000432936 (W 0.000166601) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.246543 ± 0.0013605 (W 0.00150424) | 0.267559 ± 0.000880659 (W 0.00225012) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.589143 ± 0.00159093 (W 0.0023666) | 0.650463 ± 0.00258174 (W 0.00249227) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0009665 ± 1.28167e-05 (W 2.31776e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002144 ± 1.18954e-05 (W 3.23959e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003717 ± 2.29819e-05 (W 4.94809e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0033515 ± 0.00018978 (W 3.30148e-05) | 0.003427 ± 5.02689e-05 (W 2.92445e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014527 ± 0.0019457 (W 2.35868e-05) | 0.015864 ± 0.000107517 (W 0.000112157) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0308825 ± 0.00226718 (W 8.12415e-05) | 0.0377355 ± 0.000171989 (W 0.000195828) | 🔵 faer-fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113567 ± 0.000310403 (W 0.000263905) | 0.104385 ± 0.00105292 (W 0.00150255) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.48553 ± 0.00107633 (W 0.00223576) | 0.346062 ± 0.00154431 (W 0.00195866) | 🔴 faer-fork 1.40× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.15957 ± 0.00510246 (W 0.00222642) | 0.751134 ± 0.00156073 (W 0.00258046) | 🔴 faer-fork 1.54× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.012188 ± 7.84442e-05 (W 6.71541e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.049848 ± 0.000494187 (W 0.000253863) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.156397 ± 0.00112661 (W 0.00238636) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0058705 ± 0.000787647 (W 0.000150135) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.005881 ± 9.47453e-05 (W 0.000127729) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014662 ± 0.00014483 (W 0.000140286) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.014893 ± 0.000162229 (W 0.000176728) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0302915 ± 0.000227515 (W 0.000230186) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0302215 ± 0.000282369 (W 0.000208274) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007609 ± 0.000132271 (W 7.3048e-05) | 0.0084355 ± 0.00014333 (W 9.39648e-05) | 🔵 faer-fork 1.11× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026555 ± 0.000262496 (W 0.000113084) | 0.033262 ± 0.000284583 (W 0.000177714) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.065327 ± 0.000599897 (W 0.00235913) | 0.0770585 ± 0.000296946 (W 0.000208419) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0307775 ± 0.000318376 (W 0.000201456) | 0.0292645 ± 0.000202184 (W 8.89661e-05) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.098253 ± 0.000517325 (W 0.000429734) | 0.118441 ± 0.00136022 (W 0.00179421) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.211529 ± 0.00145141 (W 0.0036659) | 0.341635 ± 0.00115794 (W 0.00243907) | 🔵 faer-fork 1.62× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.01646 ± 0.000164281 (W 0.00011735) | 0.01605 ± 0.000128634 (W 0.000123031) | · | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.064415 ± 0.000382114 (W 0.000309385) | 0.060683 ± 0.000359337 (W 0.00035934) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.124627 ± 0.000684347 (W 0.000290224) | 0.172636 ± 0.000823924 (W 0.00168349) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0087615 ± 0.000106984 (W 8.71277e-05) | 0.0086265 ± 0.000169942 (W 3.46478e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0276165 ± 0.000381865 (W 0.000182561) | 0.032706 ± 0.000779466 (W 8.06074e-05) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.0746595 ± 0.00154563 (W 0.00253393) | 0.0760065 ± 0.000709441 (W 0.000950518) | · | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.173214 ± 0.0102518 (W 0.00178158) | 0.178488 ± 0.0013477 (W 0.0018068) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.888262 ± 0.00465367 (W 0.00212093) | 0.627298 ± 0.00729392 (W 0.00246611) | 🔴 faer-fork 1.42× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.01705 ± 0.034783 (W 0.00225502) | 1.47272 ± 0.00649 (W 0.00396361) | 🔴 faer-fork 1.37× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.067561 ± 0.000510503 (W 0.000154856) | 0.0741675 ± 0.000562187 (W 0.00143402) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.247737 ± 0.000909495 (W 0.00143915) | 0.267193 ± 0.000716376 (W 0.00223463) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.606235 ± 0.0032977 (W 0.00182314) | 0.670026 ± 0.00302721 (W 0.00218481) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000962 ± 1.2227e-05 (W 2.02081e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002149 ± 8.16497e-06 (W 3.58758e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0035765 ± 5.74073e-05 (W 3.68889e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050095 ± 0.000190166 (W 3.52251e-05) | 0.006863 ± 3.41394e-05 (W 4.95473e-05) | 🔵 faer-fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029946 ± 9.91237e-05 (W 0.000150043) | 0.0399345 ± 0.000216334 (W 0.000271571) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.085203 ± 0.000132833 (W 0.000597827) | 0.096109 ± 0.00050591 (W 0.000509969) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.141178 ± 0.000739107 (W 0.00178219) | 0.155313 ± 0.000283245 (W 0.00207836) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.662734 ± 0.00171266 (W 0.00222408) | 0.664662 ± 0.00229628 (W 0.00238624) | · |  |
| `eigh/n96/b1` | 1.66272 ± 0.00695241 (W 0.0035084) | 1.66472 ± 0.0161446 (W 0.00383198) | · |  |
| `full_piv_lu/n32/b1` | 0.019085 ± 0.00120907 (W 7.92076e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.101559 ± 0.00493436 (W 0.00178279) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n96/b1` | 0.288282 ± 0.0111571 (W 0.00223281) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028428 ± 0.000105034 (W 9.0442e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028553 ± 7.12039e-05 (W 7.7577e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.160104 ± 0.000744963 (W 0.00250612) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.161055 ± 0.000665302 (W 0.00204686) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.473032 ± 0.0127987 (W 0.00135229) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.471594 ± 0.00876076 (W 0.00102593) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0142715 ± 8.33043e-05 (W 5.9571e-05) | 0.014001 ± 0.000138624 (W 8.07887e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.061514 ± 0.000283763 (W 0.000962228) | 0.0683615 ± 0.000295876 (W 0.000486121) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.160207 ± 0.000246377 (W 0.00191651) | 0.178992 ± 0.00077552 (W 0.00213775) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.069655 ± 0.000369867 (W 0.00033001) | 0.0543905 ± 0.000274096 (W 0.00014846) | 🔴 faer-fork 1.28× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.311692 ± 0.000911667 (W 0.00217845) | 0.265943 ± 0.0027305 (W 0.00216858) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.759981 ± 0.012029 (W 0.00291746) | 0.730548 ± 0.00418723 (W 0.00157315) | · |  |
| `qr_factor/n32/b1` | 0.0397535 ± 0.000186894 (W 0.00025312) | 0.030271 ± 0.000209848 (W 7.26717e-05) | 🔴 faer-fork 1.31× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.171485 ± 0.000957094 (W 0.00174437) | 0.138967 ± 0.00164077 (W 0.00159885) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.410447 ± 0.00284352 (W 0.00256198) | 0.372425 ± 0.00116087 (W 0.00232314) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.015554 ± 5.31977e-05 (W 4.93372e-05) | 0.0155235 ± 9.25212e-05 (W 6.40148e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0637835 ± 0.000169798 (W 0.000146258) | 0.072385 ± 0.000382953 (W 0.000354666) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.16448 ± 0.000719969 (W 0.00187969) | 0.187543 ± 0.00335005 (W 0.00205182) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.22189 ± 0.00632696 (W 0.00167375) | 0.229808 ± 0.000695868 (W 0.0018712) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.1794 ± 0.00408299 (W 0.00254878) | 0.973403 ± 0.00787397 (W 0.00170262) | 🔴 faer-fork 1.21× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.06114 ± 0.0369042 (W 0.00178673) | 2.76111 ± 0.100857 (W 0.00473432) | 🔴 faer-fork 1.11× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.084767 ± 0.000231756 (W 0.00103034) | 0.103563 ± 0.000335807 (W 0.000670959) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.356029 ± 0.000682423 (W 0.00225975) | 0.411172 ± 0.00103869 (W 0.002159) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.904833 ± 0.00130943 (W 0.00161957) | 1.03025 ± 0.00777642 (W 0.00101403) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001172 ± 8.3666e-06 (W 1.80862e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0028705 ± 3.86816e-05 (W 2.54228e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005195 ± 3.96169e-05 (W 3.34816e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050145 ± 6.58048e-05 (W 4.18183e-05) | 0.006968 ± 7.97496e-05 (W 5.31385e-05) | 🔵 faer-fork 1.39× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0299255 ± 0.000268456 (W 0.000167355) | 0.040856 ± 0.00327259 (W 0.000625088) | 🔵 faer-fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n96/b1` | 0.0884045 ± 0.00131296 (W 0.000431676) | 0.0929435 ± 0.000966357 (W 0.000872831) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.137902 ± 0.00054182 (W 0.000321488) | 0.138799 ± 0.000228048 (W 0.00022725) | · |  |
| `eigh/n64/b1` | 0.574697 ± 0.00246573 (W 0.00234262) | 0.575133 ± 0.00265584 (W 0.00259903) | · |  |
| `eigh/n96/b1` | 1.36398 ± 0.00675685 (W 0.00270098) | 1.63671 ± 0.00583274 (W 0.00382686) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.020243 ± 0.000194032 (W 5.42377e-05) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n64/b1` | 0.104959 ± 0.00116683 (W 0.000762147) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.248366 ± 0.00211879 (W 0.00221146) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.014557 ± 0.000203737 (W 0.000199974) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0146125 ± 0.000332666 (W 0.000253602) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.061019 ± 0.00019151 (W 0.000806822) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.06159 ± 0.000348668 (W 0.000783917) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.152022 ± 0.00084423 (W 0.000481754) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.151458 ± 0.000668164 (W 0.000426061) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0142865 ± 7.81127e-05 (W 6.67922e-05) | 0.013951 ± 6.82398e-05 (W 0.000106529) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.062861 ± 0.00184982 (W 0.000976633) | 0.068253 ± 0.000404444 (W 0.000298239) | 🔵 faer-fork 1.09× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.158861 ± 0.00175756 (W 0.0023705) | 0.179304 ± 0.000783449 (W 0.00215614) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0635285 ± 0.000368154 (W 0.000349894) | 0.0544415 ± 0.000240268 (W 0.000759245) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.196219 ± 0.000389315 (W 0.00167232) | 0.263657 ± 0.00228979 (W 0.00231651) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.421526 ± 0.00165913 (W 0.00224551) | 0.923763 ± 0.00213758 (W 0.00169554) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.039293 ± 0.000414849 (W 0.00035527) | 0.0302165 ± 0.000278313 (W 7.81752e-05) | 🔴 faer-fork 1.30× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.125333 ± 0.00060768 (W 0.00147989) | 0.138118 ± 0.00100937 (W 0.000687078) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.264643 ± 0.00077461 (W 0.00212069) | 0.470353 ± 0.00150386 (W 0.00202262) | 🔵 faer-fork 1.78× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0161 ± 0.000131501 (W 4.01899e-05) | 0.015509 ± 8.97589e-05 (W 0.000230855) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0659125 ± 0.00168997 (W 0.000291979) | 0.072365 ± 0.000525134 (W 0.0010517) | 🔵 faer-fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.161501 ± 0.00128395 (W 0.00187742) | 0.187949 ± 0.000796994 (W 0.00211556) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.215714 ± 0.00196917 (W 0.00177303) | 0.230811 ± 0.000658332 (W 0.00191511) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 1.01536 ± 0.00314252 (W 0.00308638) | 0.969302 ± 0.00531602 (W 0.00131603) | · |  |
| `svd_thin/n96/b1` | 2.51775 ± 0.0113464 (W 0.00267475) | 2.59368 ± 0.110964 (W 0.0037938) | · | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.0867465 ± 0.000396075 (W 0.000202105) | 0.103548 ± 0.00108361 (W 0.000929679) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.359963 ± 0.00257168 (W 0.00223235) | 0.411985 ± 0.00293083 (W 0.00218796) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.81537 ± 0.00256974 (W 0.00249326) | 1.27962 ± 0.0035538 (W 0.00394013) | 🔵 faer-fork 1.57× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001413 ± 1.89737e-05 (W 2.66094e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0034615 ± 4.11129e-05 (W 2.41769e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005976 ± 5.76325e-05 (W 3.18678e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050195 ± 4.82935e-05 (W 3.95382e-05) | 0.0068575 ± 3.04675e-05 (W 4.4967e-05) | 🔵 faer-fork 1.37× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029986 ± 0.000246432 (W 0.000139985) | 0.0425235 ± 0.000749306 (W 0.000525035) | 🔵 faer-fork 1.42× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.089196 ± 0.000273348 (W 0.000307379) | 0.099018 ± 0.00229898 (W 0.00104069) | 🔵 faer-fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.138833 ± 0.000477257 (W 0.000211695) | 0.138863 ± 0.000573631 (W 0.000959583) | · |  |
| `eigh/n64/b1` | 0.569713 ± 0.00201603 (W 0.00227788) | 0.567529 ± 0.0013345 (W 0.00194759) | · |  |
| `eigh/n96/b1` | 1.33937 ± 0.00519203 (W 0.00276786) | 1.66868 ± 0.00585972 (W 0.00326464) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.020163 ± 0.000132326 (W 9.83107e-05) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n64/b1` | 0.108797 ± 0.00148403 (W 0.00160417) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.254904 ± 0.00174125 (W 0.00262135) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.010655 ± 0.000293857 (W 0.000207962) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0113215 ± 0.000131412 (W 0.000235512) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.036994 ± 0.000299177 (W 0.000407664) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0377105 ± 0.000444716 (W 0.000365197) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.086842 ± 0.00100088 (W 0.000645018) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0860945 ± 0.000982462 (W 0.000608382) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0142565 ± 7.6387e-05 (W 6.58751e-05) | 0.013966 ± 7.48075e-05 (W 7.32778e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0660975 ± 0.000380924 (W 0.000864152) | 0.0680525 ± 0.000223039 (W 0.000353232) | · |  |
| `lu/n96/b1` | 0.160429 ± 0.000595977 (W 0.00153393) | 0.179008 ± 0.000773741 (W 0.00194753) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0635235 ± 0.000325721 (W 0.000371184) | 0.054336 ± 0.000321531 (W 0.000842525) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.184348 ± 0.032981 (W 0.00188106) | 0.263455 ± 0.00167873 (W 0.00268459) | 🔵 faer-fork 1.43× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.366505 ± 0.000967278 (W 0.00224247) | 0.986534 ± 0.00370719 (W 0.00355368) | 🔵 faer-fork 2.69× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0385515 ± 0.00167453 (W 0.00130697) | 0.0301655 ± 0.000242513 (W 6.54907e-05) | 🔴 faer-fork 1.28× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.12143 ± 0.000750058 (W 0.00122154) | 0.138483 ± 0.00109449 (W 0.00130019) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.241794 ± 0.000837713 (W 0.00182513) | 0.502669 ± 0.00221846 (W 0.0020603) | 🔵 faer-fork 2.08× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0162405 ± 0.000194522 (W 5.7226e-05) | 0.015484 ± 5.24992e-05 (W 6.45263e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0691385 ± 0.000478755 (W 0.00091102) | 0.0717135 ± 0.000445077 (W 0.000279945) | · |  |
| `solve/n96/b1` | 0.160414 ± 0.000780918 (W 0.00159841) | 0.186563 ± 0.000711315 (W 0.0017749) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.216197 ± 0.00979588 (W 0.00164846) | 0.230739 ± 0.00168299 (W 0.00203659) | 🔵 faer-fork 1.07× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.00492 ± 0.00448157 (W 0.00128505) | 0.974435 ± 0.00564441 (W 0.00239369) | · |  |
| `svd_thin/n96/b1` | 2.47087 ± 0.00305998 (W 0.00553522) | 2.61961 ± 0.0780749 (W 0.00533675) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.086716 ± 0.0006446 (W 0.000165133) | 0.102941 ± 0.000450544 (W 0.000870901) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.37086 ± 0.00170887 (W 0.0020881) | 0.408307 ± 0.00150552 (W 0.00226775) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.837291 ± 0.0016434 (W 0.00245256) | 1.37104 ± 0.00857808 (W 0.00257735) | 🔵 faer-fork 1.64× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001413 ± 1.15873e-05 (W 2.29596e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0034265 ± 3.33806e-05 (W 2.6157e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.006001 ± 6.29529e-05 (W 1.96896e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050545 ± 3.75002e-05 (W 3.96538e-05) | 0.005871 ± 6.24233e-05 (W 5.97229e-05) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0296505 ± 0.000189122 (W 0.000104287) | 0.0318145 ± 0.000182672 (W 9.96955e-05) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.084306 ± 0.000125427 (W 0.000892381) | 0.0867165 ± 0.000442738 (W 0.000994891) | · |  |
| `eigh/n32/b1` | 0.141383 ± 0.000869314 (W 0.00181311) | 0.153515 ± 0.000882318 (W 0.00193184) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.663556 ± 0.00225803 (W 0.00242653) | 0.656159 ± 0.00157637 (W 0.00241618) | · |  |
| `eigh/n96/b1` | 1.6628 ± 0.00309218 (W 0.0053202) | 1.64688 ± 0.00786379 (W 0.00382428) | · |  |
| `full_piv_lu/n32/b1` | 0.017077 ± 0.00121844 (W 0.000101107) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.094536 ± 0.00475932 (W 0.00159382) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n96/b1` | 0.272122 ± 0.0117666 (W 0.00208263) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028368 ± 0.000141252 (W 6.88481e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028458 ± 0.000150601 (W 8.0367e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.158325 ± 0.000390481 (W 0.000166307) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158946 ± 0.000508703 (W 0.00189873) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.463404 ± 0.0132079 (W 0.00172574) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.468642 ± 0.00991087 (W 0.00199288) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.012388 ± 5.22319e-05 (W 4.91927e-05) | 0.0128185 ± 0.000133635 (W 8.0606e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.054432 ± 0.000431296 (W 0.000117708) | 0.0604125 ± 0.000344415 (W 9.6191e-05) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.144869 ± 0.000375906 (W 0.00173679) | 0.164406 ± 0.000526914 (W 0.00201331) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.06754 ± 0.0002443 (W 0.000188915) | 0.0516215 ± 0.000430846 (W 0.000113124) | 🔴 faer-fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.304573 ± 0.00148865 (W 0.00232701) | 0.248548 ± 0.00183655 (W 0.00193823) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.744128 ± 0.00771089 (W 0.00236938) | 0.699657 ± 0.00292226 (W 0.00192739) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0324355 ± 0.000272196 (W 0.000206779) | 0.0289685 ± 0.000294571 (W 8.22928e-05) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.152726 ± 0.000760458 (W 0.00135882) | 0.130163 ± 0.000933699 (W 0.000881716) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.368818 ± 0.00190319 (W 0.00260028) | 0.357901 ± 0.00199673 (W 0.00184339) | · |  |
| `solve/n32/b1` | 0.01341 ± 6.2849e-05 (W 5.12058e-05) | 0.014151 ± 7.32002e-05 (W 6.46888e-05) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0564745 ± 9.38637e-05 (W 0.000897508) | 0.064359 ± 0.000221017 (W 0.000178414) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.148176 ± 0.000554933 (W 0.00180426) | 0.172987 ± 0.00163327 (W 0.00193063) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.2196 ± 0.00573768 (W 0.00173045) | 0.229253 ± 0.000895705 (W 0.00180125) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.20874 ± 0.00260278 (W 0.00276432) | 0.9458 ± 0.0104129 (W 0.00163211) | 🔴 faer-fork 1.28× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.01573 ± 0.0314507 (W 0.00227766) | 2.53349 ± 0.0640973 (W 0.0032313) | 🔴 faer-fork 1.19× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.0853225 ± 0.000154129 (W 0.00093037) | 0.103498 ± 0.000384273 (W 0.00102999) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.353249 ± 0.000717944 (W 0.0020228) | 0.403698 ± 0.00106755 (W 0.00229484) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.904621 ± 0.00200233 (W 0.00316823) | 1.01172 ± 0.00670539 (W 0.000866815) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001142 ± 8.16497e-06 (W 1.77461e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.00287 ± 1.84436e-05 (W 3.45941e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0052445 ± 0.000145857 (W 3.58068e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050295 ± 5.64532e-05 (W 3.34446e-05) | 0.005886 ± 3.54495e-05 (W 3.99264e-05) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0295305 ± 0.000181444 (W 0.000135752) | 0.033212 ± 0.0026567 (W 0.00162587) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.08599 ± 0.00100578 (W 0.000198978) | 0.0878085 ± 0.000567265 (W 0.000796229) | · |  |
| `eigh/n32/b1` | 0.138216 ± 0.000104364 (W 0.00034191) | 0.13746 ± 0.00044139 (W 0.000257769) | · |  |
| `eigh/n64/b1` | 0.574012 ± 0.00266555 (W 0.00245215) | 0.568238 ± 0.00344028 (W 0.00236492) | · |  |
| `eigh/n96/b1` | 1.36265 ± 0.00317422 (W 0.00270687) | 1.62813 ± 0.00580296 (W 0.00349285) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.018214 ± 0.000112482 (W 7.5665e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0972465 ± 0.00110325 (W 0.000719505) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.232656 ± 0.00289617 (W 0.00250776) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.015003 ± 0.000139714 (W 0.000164924) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.014878 ± 0.000168263 (W 0.00014685) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0613795 ± 0.000441433 (W 0.000298631) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0618905 ± 0.000291032 (W 0.000361031) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.151637 ± 0.000295908 (W 0.00150124) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.151247 ± 0.000400573 (W 0.00172212) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012393 ± 6.253e-05 (W 4.08736e-05) | 0.012914 ± 0.000102961 (W 9.25438e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058874 ± 0.00139651 (W 0.000893696) | 0.060142 ± 0.000225304 (W 0.000153411) | · | `!` between-start range over 5% |
| `lu/n96/b1` | 0.143501 ± 0.00182968 (W 0.00169422) | 0.164611 ± 0.000387829 (W 0.00182198) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0615795 ± 0.00040757 (W 0.000331144) | 0.0518465 ± 0.000313814 (W 0.000147841) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.189339 ± 0.000723857 (W 0.00228077) | 0.248867 ± 0.00259507 (W 0.00201721) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.406608 ± 0.00125933 (W 0.00246387) | 0.892323 ± 0.00373292 (W 0.00166655) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.030822 ± 0.000320744 (W 0.00027851) | 0.0290695 ± 0.000171561 (W 6.21233e-05) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.11577 ± 0.000353468 (W 0.000488454) | 0.130103 ± 0.000296289 (W 0.00149103) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.244409 ± 0.0019738 (W 0.00172458) | 0.455159 ± 0.00142648 (W 0.00211214) | 🔵 faer-fork 1.86× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.013981 ± 0.000103811 (W 5.7444e-05) | 0.014106 ± 6.42301e-05 (W 6.02621e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0614295 ± 0.00178867 (W 0.00154655) | 0.064059 ± 0.000259527 (W 0.000151924) | · | `!` between-start range over 5% |
| `solve/n96/b1` | 0.145301 ± 0.000974223 (W 0.00194535) | 0.172806 ± 0.00106343 (W 0.00201029) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.213113 ± 0.00104737 (W 0.00139017) | 0.228827 ± 0.000656969 (W 0.00187697) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 1.04639 ± 0.00319961 (W 0.00269867) | 0.944032 ± 0.00657409 (W 0.0006832) | 🔴 faer-fork 1.11× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.46945 ± 0.0070639 (W 0.00570859) | 2.46191 ± 0.00372546 (W 0.00689319) | · |  |
| `svd_values/n32/b1` | 0.087593 ± 0.000358393 (W 0.000156365) | 0.103663 ± 0.00108655 (W 0.00155653) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.359893 ± 0.00207277 (W 0.00187878) | 0.403693 ± 0.00232345 (W 0.00226931) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.811333 ± 0.003947 (W 0.00228571) | 1.26764 ± 0.00261535 (W 0.00406761) | 🔵 faer-fork 1.56× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0013875 ± 1.04003e-05 (W 1.32381e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0033815 ± 0.000351882 (W 2.5015e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005941 ± 0.000105689 (W 2.61307e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004974 ± 5.71795e-05 (W 2.71053e-05) | 0.0058355 ± 6.74104e-05 (W 5.91633e-05) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029695 ± 0.000310171 (W 0.0001059) | 0.037594 ± 0.00033637 (W 0.00155954) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.08858 ± 0.000202259 (W 0.000324881) | 0.0953815 ± 0.000415226 (W 0.00114219) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.138803 ± 0.000392063 (W 0.000262095) | 0.137486 ± 0.000351833 (W 0.000755274) | · |  |
| `eigh/n64/b1` | 0.569669 ± 0.00128425 (W 0.00248938) | 0.558512 ± 0.00269739 (W 0.00210313) | · |  |
| `eigh/n96/b1` | 1.33772 ± 0.00312672 (W 0.00321345) | 1.65757 ± 0.00359123 (W 0.0023096) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.018129 ± 0.000129646 (W 0.000102844) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.101433 ± 0.00143441 (W 0.00136985) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.238086 ± 0.00175446 (W 0.00240853) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0109805 ± 0.000130242 (W 0.000162667) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0110805 ± 0.000297683 (W 0.000191037) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0382555 ± 0.000236108 (W 0.000420048) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.038526 ± 0.000400081 (W 0.000314414) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.088434 ± 0.000338068 (W 0.00153729) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0877985 ± 0.000338862 (W 0.000780326) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012453 ± 5.13436e-05 (W 8.57136e-05) | 0.0128085 ± 0.00010709 (W 7.79001e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.059005 ± 0.000328289 (W 0.000306829) | 0.0598265 ± 0.000140325 (W 0.000370332) | · |  |
| `lu/n96/b1` | 0.144058 ± 0.000878689 (W 0.000455496) | 0.163894 ± 0.000480694 (W 0.00164465) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.061704 ± 0.000224174 (W 0.000414806) | 0.0513595 ± 0.000262893 (W 5.51347e-05) | 🔴 faer-fork 1.20× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.17717 ± 0.000125643 (W 0.0017291) | 0.2492 ± 0.00441892 (W 0.00233991) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.352002 ± 0.00248592 (W 0.00214688) | 0.950752 ± 0.00480263 (W 0.00244781) | 🔵 faer-fork 2.70× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.030762 ± 0.000374759 (W 0.000281192) | 0.028844 ± 0.000198595 (W 5.42548e-05) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.112024 ± 0.000544662 (W 0.00159767) | 0.130012 ± 0.00112626 (W 0.00184521) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.228614 ± 0.00216586 (W 0.00171549) | 0.484752 ± 0.00311972 (W 0.00184596) | 🔵 faer-fork 2.12× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0140965 ± 0.000142789 (W 5.3324e-05) | 0.014051 ± 6.72686e-05 (W 6.0024e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.06182 ± 0.000194529 (W 0.0014455) | 0.0641385 ± 0.000417827 (W 0.000161814) | · |  |
| `solve/n96/b1` | 0.144639 ± 0.00100569 (W 0.00151865) | 0.171979 ± 0.000729113 (W 0.00197677) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.214599 ± 0.01025 (W 0.0016353) | 0.228185 ± 0.000715646 (W 0.00215464) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.03541 ± 0.00471839 (W 0.00337707) | 0.941846 ± 0.00638565 (W 0.0020181) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.42364 ± 0.00460922 (W 0.00418902) | 2.55168 ± 0.00667908 (W 0.00414842) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.0874375 ± 0.000423829 (W 9.18474e-05) | 0.103267 ± 0.000577602 (W 0.00163728) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.370156 ± 0.0016841 (W 0.00179651) | 0.400835 ± 0.00165446 (W 0.00232403) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_values/n96/b1` | 0.833484 ± 0.00452424 (W 0.00291441) | 1.35923 ± 0.00524225 (W 0.00278457) | 🔵 faer-fork 1.63× faster than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001383 ± 9.50088e-06 (W 1.71406e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0033615 ± 1.46116e-05 (W 2.25938e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005876 ± 5.42832e-05 (W 2.85967e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070967 ± 0.00053228 (W 0.000524075) | 0.159121 ± 0.00129019 (W 0.00203312) | 🔵 faer-fork 2.24× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.391515 ± 0.00129725 (W 0.003356) | 1.00357 ± 0.0024974 (W 0.00265157) | 🔵 faer-fork 2.56× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.53021 ± 0.0049271 (W 0.00334688) | 5.94643 ± 0.0620223 (W 0.0094113) | 🔵 faer-fork 2.35× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.33973 ± 0.00973115 (W 0.0031026) | 1.88812 ± 0.00410149 (W 0.00825343) | 🔴 faer-fork 1.24× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.1532 ± 0.0392953 (W 0.0091277) | 9.1931 ± 0.0253968 (W 0.0120327) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 50.3426 ± 0.184242 (W 0.107827) | 52.2328 ± 0.294121 (W 0.0676888) | · |  |
| `full_piv_lu/n128/b1` | 0.313466 ± 0.00159783 (W 0.00243585) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.719 ± 0.00957118 (W 0.0110292) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.8033 ± 0.230242 (W 0.0489142) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.260269 ± 0.00100171 (W 0.00201482) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.259834 ± 0.000642146 (W 0.00287514) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91601 ± 0.00385089 (W 0.00317528) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.9177 ± 0.00701837 (W 0.00512546) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 16.0394 ± 0.034376 (W 0.0252689) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9208 ± 0.0513114 (W 0.0364266) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.164747 ± 0.000760524 (W 0.0016941) | 0.213388 ± 0.00132103 (W 0.00544821) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.977086 ± 0.00430061 (W 0.00319071) | 1.38087 ± 0.0142143 (W 0.00642388) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 6.60843 ± 0.0197292 (W 0.011113) | 8.26163 ± 0.140437 (W 0.009279) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.48181 ± 0.00196541 (W 0.00229421) | 0.862509 ± 0.0126203 (W 0.00645542) | 🔵 faer-fork 1.79× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.7807 ± 0.00384349 (W 0.00403463) | 4.39483 ± 0.0404043 (W 0.0112937) | 🔵 faer-fork 1.58× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.9297 ± 0.0459673 (W 0.0270474) | 30.8978 ± 0.1449 (W 0.102767) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.301129 ± 0.000980427 (W 0.00242806) | 0.435152 ± 0.00572574 (W 0.0040594) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.50466 ± 0.00308663 (W 0.00456921) | 2.1947 ± 0.0194915 (W 0.00597748) | 🔵 faer-fork 1.46× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.56798 ± 0.011678 (W 0.0176112) | 14.5826 ± 0.0410096 (W 0.0200054) | 🔵 faer-fork 1.70× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.135121 ± 0.000675056 (W 0.00189659) | 0.209869 ± 0.00320537 (W 0.00366151) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.756933 ± 0.00272259 (W 0.00331284) | 1.16691 ± 0.0137828 (W 0.00275235) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.56304 ± 0.0122257 (W 0.0179758) | 7.22 ± 0.0520228 (W 0.0120419) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.39728 ± 0.00953895 (W 0.00368345) | 3.15395 ± 0.0131761 (W 0.0115897) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 16.9272 ± 0.0474546 (W 0.0191916) | 17.6111 ± 0.0225938 (W 0.0308726) | · |  |
| `svd_thin/n512/b1` | 95.0321 ± 0.282949 (W 0.0651499) | 122.479 ± 0.998113 (W 0.344446) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.03691 ± 0.00260019 (W 0.0034899) | 1.35877 ± 0.00491144 (W 0.0055918) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 6.34977 ± 0.0229822 (W 0.00676839) | 8.00584 ± 0.0376437 (W 0.0095534) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 41.2497 ± 0.168233 (W 0.0325631) | 55.2557 ± 1.08763 (W 0.161837) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004253 ± 5.78504e-05 (W 6.31555e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0121775 ± 0.000773771 (W 0.00082443) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0408415 ± 0.00285108 (W 0.000835463) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0717435 ± 0.00196108 (W 0.000721743) | 0.168673 ± 0.00196323 (W 0.00289379) | 🔵 faer-fork 2.35× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.29845 ± 0.00216218 (W 0.00286358) | 0.873961 ± 0.0065087 (W 0.00307746) | 🔵 faer-fork 2.93× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 1.41922 ± 0.0160808 (W 0.00551749) | 4.5575 ± 0.0369429 (W 0.0109445) | 🔵 faer-fork 3.21× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.20999 ± 0.0080311 (W 0.00615122) | 1.50086 ± 0.00353755 (W 0.00455513) | 🔴 faer-fork 1.47× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.41604 ± 0.0102642 (W 0.00675716) | 6.10032 ± 0.00592894 (W 0.0114253) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 24.1839 ± 0.0394414 (W 0.0291521) | 28.8284 ± 0.221177 (W 0.0346766) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.337077 ± 0.00273345 (W 0.00334007) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.01246 ± 0.0133416 (W 0.00721022) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 12.9687 ± 0.0518725 (W 0.0180097) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0818075 ± 0.000369614 (W 0.000546349) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0847075 ± 0.000772844 (W 0.000798549) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.517803 ± 0.00427491 (W 0.00296683) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.524526 ± 0.00360141 (W 0.00365186) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.12346 ± 0.0247222 (W 0.0104663) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.13462 ± 0.0142711 (W 0.0133806) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.162328 ± 0.00123832 (W 0.00212772) | 0.210947 ± 0.00461309 (W 0.00393701) | 🔵 faer-fork 1.30× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.795588 ± 0.0088289 (W 0.00583747) | 1.06874 ± 0.0101199 (W 0.0034758) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 4.22799 ± 0.0299719 (W 0.00966024) | 5.75758 ± 0.179622 (W 0.0203832) | 🔵 faer-fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.33838 ± 0.00115205 (W 0.00175001) | 0.903849 ± 0.00938037 (W 0.00554889) | 🔵 faer-fork 2.67× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.15617 ± 0.00580901 (W 0.00225936) | 3.59223 ± 0.0432631 (W 0.00947119) | 🔵 faer-fork 3.11× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.00694 ± 0.0177608 (W 0.0209659) | 19.5104 ± 0.105191 (W 0.0367638) | 🔵 faer-fork 2.44× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.212612 ± 0.000654532 (W 0.00163428) | 0.449069 ± 0.00313891 (W 0.0054586) | 🔵 faer-fork 2.11× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 0.642545 ± 0.00664245 (W 0.00255633) | 1.80122 ± 0.0193485 (W 0.00530947) | 🔵 faer-fork 2.80× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 3.1357 ± 0.0280681 (W 0.0135639) | 9.56687 ± 0.11045 (W 0.0136689) | 🔵 faer-fork 3.05× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.133119 ± 0.000933363 (W 0.00107913) | 0.174449 ± 0.00248917 (W 0.00329475) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.567359 ± 0.00569485 (W 0.00283129) | 0.79127 ± 0.016458 (W 0.00417703) | 🔵 faer-fork 1.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.10342 ± 0.026079 (W 0.0131191) | 4.62033 ± 0.0611429 (W 0.0132929) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 2.48621 ± 0.0107255 (W 0.00492583) | 3.09911 ± 0.0150772 (W 0.00927151) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 10.334 ± 0.0249913 (W 0.0146483) | 14.9423 ± 0.0928082 (W 0.0207161) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 41.1833 ± 0.0794387 (W 0.0388863) | 93.9001 ± 2.03109 (W 0.27201) | 🔵 faer-fork 2.28× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.07925 ± 0.00329394 (W 0.00335232) | 1.40084 ± 0.00368772 (W 0.00587592) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 5.09272 ± 0.0121101 (W 0.0085346) | 7.65675 ± 0.0343417 (W 0.0124632) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 22.6525 ± 0.0731552 (W 0.045715) | 49.6744 ± 0.494705 (W 0.0704872) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.005125 ± 6.64843e-05 (W 4.61919e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011958 ± 0.000541968 (W 8.14626e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0302105 ± 0.000518967 (W 0.000128495) | - | - | `*` one row has no measurement here |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0721895 ± 0.00164873 (W 0.000498439) | 0.168023 ± 0.00297208 (W 0.00402722) | 🔵 faer-fork 2.33× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.301025 ± 0.00611357 (W 0.00295588) | 0.881389 ± 0.00653858 (W 0.004494) | 🔵 faer-fork 2.93× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.31415 ± 0.0395667 (W 0.0080226) | 4.4339 ± 0.0245142 (W 0.00836987) | 🔵 faer-fork 3.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.21184 ± 0.00609072 (W 0.00296544) | 1.44618 ± 0.00447301 (W 0.00397624) | 🔴 faer-fork 1.53× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.19638 ± 0.0189265 (W 0.00485857) | 5.75507 ± 0.0118712 (W 0.00877522) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 21.5005 ± 0.0512041 (W 0.0257296) | 25.438 ± 0.163254 (W 0.0435772) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.344561 ± 0.00476746 (W 0.00495307) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.95243 ± 0.00857208 (W 0.00652892) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 11.69 ± 0.0282197 (W 0.0283581) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0547325 ± 0.000311868 (W 0.000933435) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0585695 ± 0.000180771 (W 0.00110048) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.281821 ± 0.00157576 (W 0.00258084) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.288285 ± 0.00213477 (W 0.00227441) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.22057 ± 0.0359393 (W 0.0114609) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.25783 ± 0.0166319 (W 0.0141656) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.163223 ± 9.73616 (W 0.000557549) | 0.212144 ± 0.00396915 (W 0.00499183) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.785786 ± 0.0078118 (W 0.00440009) | 0.98975 ± 0.0126948 (W 0.00470984) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 3.96802 ± 0.0237697 (W 0.00769644) | 4.82361 ± 0.0292975 (W 0.0157468) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.316875 ± 0.00195838 (W 0.00195499) | 0.906236 ± 0.00826895 (W 0.00762665) | 🔵 faer-fork 2.86× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 0.979011 ± 0.00583561 (W 0.00187141) | 3.57995 ± 0.0514406 (W 0.00981539) | 🔵 faer-fork 3.66× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 5.69856 ± 0.0186045 (W 0.0147223) | 17.8057 ± 0.286493 (W 0.0312565) | 🔵 faer-fork 3.12× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.198219 ± 0.000834367 (W 0.00207272) | 0.448826 ± 0.0033117 (W 0.00524691) | 🔵 faer-fork 2.26× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 0.593294 ± 0.00799809 (W 0.0029524) | 1.7692 ± 0.0145152 (W 0.00466534) | 🔵 faer-fork 2.98× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 1.8175 ± 0.0293831 (W 0.00456819) | 8.78038 ± 0.12727 (W 0.0146354) | 🔵 faer-fork 4.83× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.135026 ± 0.000725054 (W 0.000422115) | 0.208573 ± 0.00379322 (W 0.00458782) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.563673 ± 0.00340866 (W 0.00202008) | 0.778322 ± 0.0119109 (W 0.0033443) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 3.82823 ± 0.0157192 (W 0.00829273) | 3.79113 ± 0.149449 (W 0.0148566) | · | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 2.49114 ± 0.00890174 (W 0.00530149) | 3.12132 ± 0.00907612 (W 0.00943654) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 9.82579 ± 0.0248482 (W 0.00970363) | 14.7536 ± 0.143964 (W 0.0154602) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 35.3619 ± 0.142909 (W 0.0411748) | 89.347 ± 2.24416 (W 0.14717) | 🔵 faer-fork 2.53× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.13413 ± 0.0115183 (W 0.00327707) | 1.40901 ± 0.0159791 (W 0.00563464) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 5.01356 ± 0.0192874 (W 0.00890374) | 7.65799 ± 0.0569215 (W 0.0144167) | 🔵 faer-fork 1.53× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 20.6389 ± 0.0594565 (W 0.0302956) | 49.2193 ± 0.628345 (W 0.0773001) | 🔵 faer-fork 2.38× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0050995 ± 0.000117077 (W 3.40713e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012123 ± 0.000348574 (W 8.30601e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.029224 ± 0.0015542 (W 0.000179064) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.064315 ± 0.00220697 (W 7.2451e-05) | 0.073091 ± 0.000699365 (W 0.000200553) | 🔵 faer-fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.324365 ± 0.00420213 (W 0.00249703) | 0.408457 ± 0.000789426 (W 0.00246627) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.0718 ± 0.00293692 (W 0.00292473) | 2.70094 ± 0.00829912 (W 0.00273377) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.33543 ± 0.0117398 (W 0.00341429) | 1.81416 ± 0.0077463 (W 0.00857637) | 🔴 faer-fork 1.29× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.1019 ± 0.041713 (W 0.0100119) | 8.78709 ± 0.0130139 (W 0.0106522) | 🔴 faer-fork 1.15× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 49.8677 ± 0.177319 (W 0.0450074) | 49.6392 ± 0.332065 (W 0.0533443) | · |  |
| `full_piv_lu/n128/b1` | 0.292156 ± 0.00148098 (W 0.00255585) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.63564 ± 0.00825716 (W 0.00842098) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.2501 ± 0.284 (W 0.0435687) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254868 ± 0.000638323 (W 0.00209) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.256138 ± 0.000457323 (W 0.00238927) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.88679 ± 0.00509266 (W 0.00224884) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.88567 ± 0.00613737 (W 0.00377568) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.871 ± 0.0289128 (W 0.0228185) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.753 ± 0.0494967 (W 0.0387491) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.130441 ± 0.0172212 (W 0.00213843) | 0.152242 ± 0.000608222 (W 0.0017963) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.895439 ± 0.00275759 (W 0.00323053) | 0.839793 ± 0.00231146 (W 0.00222022) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.10957 ± 0.021745 (W 0.0107405) | 5.18932 ± 0.00694617 (W 0.00565522) | 🔴 faer-fork 1.18× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.455213 ± 0.0024678 (W 0.00241911) | 0.761482 ± 0.00365706 (W 0.00355642) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.67021 ± 0.00371191 (W 0.00295328) | 4.11655 ± 0.0108676 (W 0.00551267) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.3246 ± 0.0327641 (W 0.0192376) | 27.0408 ± 0.0410679 (W 0.025941) | 🔵 faer-fork 1.40× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.243964 ± 0.00167686 (W 0.00201443) | 0.377169 ± 0.00211158 (W 0.0022148) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.26629 ± 0.00396912 (W 0.00294846) | 1.88038 ± 0.00666325 (W 0.00488611) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 7.62869 ± 0.012856 (W 0.0113275) | 12.4709 ± 0.0241887 (W 0.0167911) | 🔵 faer-fork 1.63× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.112054 ± 0.000402251 (W 0.00111693) | 0.149177 ± 0.000980212 (W 0.00186074) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.667438 ± 0.002159 (W 0.00352387) | 0.820741 ± 0.00341323 (W 0.00232911) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.06744 ± 0.0116321 (W 0.0172632) | 5.09591 ± 0.0189043 (W 0.00549457) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.38628 ± 0.00820264 (W 0.00334701) | 3.0282 ± 0.0110366 (W 0.0104929) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 16.8359 ± 0.0338787 (W 0.0104337) | 16.9928 ± 0.0179623 (W 0.0200997) | · |  |
| `svd_thin/n512/b1` | 94.2967 ± 0.186876 (W 0.100522) | 117.547 ± 0.295081 (W 0.237334) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.01631 ± 0.00246884 (W 0.00154165) | 1.29153 ± 0.00405212 (W 0.00246593) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 6.23214 ± 0.0240869 (W 0.00838714) | 7.70233 ± 0.0136844 (W 0.00828246) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 40.0839 ± 0.113538 (W 0.0268266) | 52.8848 ± 0.507661 (W 0.0543572) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0046885 ± 8.66574e-05 (W 5.67793e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0142065 ± 0.000109195 (W 0.000118771) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.045715 ± 0.00278809 (W 0.00116143) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0642 ± 0.00338096 (W 0.000714619) | 0.080184 ± 0.000865509 (W 0.00158253) | 🔵 faer-fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.231556 ± 0.00358247 (W 0.0025063) | 0.278458 ± 0.00226083 (W 0.00298578) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 0.95276 ± 0.00522061 (W 0.00362623) | 1.33182 ± 0.00745804 (W 0.00489282) | 🔵 faer-fork 1.40× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.20279 ± 0.00884757 (W 0.00465198) | 1.4287 ± 0.004677 (W 0.00571052) | 🔴 faer-fork 1.54× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.36421 ± 0.0235389 (W 0.00599918) | 5.67278 ± 0.0113438 (W 0.0118542) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 23.7936 ± 0.03056 (W 0.0250135) | 26.201 ± 0.129835 (W 0.0359606) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.31848 ± 0.0027706 (W 0.00505253) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.9263 ± 0.0093867 (W 0.0070701) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 12.5247 ± 0.0488375 (W 0.0238516) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.082403 ± 0.000325027 (W 0.000487031) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0848535 ± 0.000445727 (W 0.000660215) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.519789 ± 0.00534766 (W 0.00290301) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.53218 ± 0.00543305 (W 0.00220364) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.08167 ± 0.0457496 (W 0.0101195) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.14358 ± 0.0441957 (W 0.00926577) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.126104 ± 0.0163043 (W 0.00242265) | 0.151321 ± 0.000600914 (W 0.00155595) | 🔵 faer-fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.712291 ± 0.00562757 (W 0.00517567) | 0.50256 ± 0.00168694 (W 0.00240226) | 🔴 faer-fork 1.42× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 3.75043 ± 0.0138054 (W 0.0135117) | 2.63723 ± 0.00798753 (W 0.00447176) | 🔴 faer-fork 1.42× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.311478 ± 0.00212809 (W 0.00201659) | 0.786028 ± 0.00587548 (W 0.00587673) | 🔵 faer-fork 2.52× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.05006 ± 0.00243344 (W 0.00205378) | 3.24393 ± 0.0144101 (W 0.00605301) | 🔵 faer-fork 3.09× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 7.43081 ± 0.0133952 (W 0.0110712) | 17.077 ± 0.122029 (W 0.0373538) | 🔵 faer-fork 2.30× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.193258 ± 0.00109367 (W 0.00185112) | 0.392232 ± 0.00233822 (W 0.00194377) | 🔵 faer-fork 2.03× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 0.560421 ± 0.0069107 (W 0.00296235) | 1.45907 ± 0.00791497 (W 0.00521263) | 🔵 faer-fork 2.60× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 2.92054 ± 0.011878 (W 0.00857981) | 7.67431 ± 0.0584533 (W 0.0159473) | 🔵 faer-fork 2.63× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.112605 ± 0.000904475 (W 0.000811586) | 0.115956 ± 0.000395993 (W 0.00197784) | · |  |
| `solve/n256/b1` | 0.480689 ± 0.00668186 (W 0.00320404) | 0.483185 ± 0.00327633 (W 0.0032519) | · |  |
| `solve/n512/b1` | 3.59734 ± 0.0124062 (W 0.00824128) | 2.57672 ± 0.0050902 (W 0.00513365) | 🔴 faer-fork 1.40× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 2.45157 ± 0.00834884 (W 0.00384239) | 2.97091 ± 0.00954813 (W 0.00651278) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 10.2039 ± 0.017292 (W 0.0145282) | 14.2882 ± 0.0352677 (W 0.0184701) | 🔵 faer-fork 1.40× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 40.2385 ± 0.0440768 (W 0.0344708) | 86.5832 ± 1.16153 (W 0.100739) | 🔵 faer-fork 2.15× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.05978 ± 0.00420011 (W 0.00285129) | 1.34146 ± 0.00552291 (W 0.00309832) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 4.95939 ± 0.0154816 (W 0.012247) | 7.2861 ± 0.046269 (W 0.00991561) | 🔵 faer-fork 1.47× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 21.649 ± 0.0192301 (W 0.0283907) | 48.3025 ± 0.396497 (W 0.0716804) | 🔵 faer-fork 2.23× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0051795 ± 7.25362e-05 (W 3.58375e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014888 ± 0.000314386 (W 0.00023425) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0380455 ± 0.000797117 (W 0.000423189) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063348 ± 0.00299132 (W 0.000438335) | 0.0789675 ± 0.00183442 (W 0.00208599) | 🔵 faer-fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.241224 ± 0.00419196 (W 0.00184985) | 0.28008 ± 0.00167213 (W 0.00316105) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 0.845319 ± 0.0023806 (W 0.003041) | 1.2062 ± 0.00456155 (W 0.00448037) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.20686 ± 0.00536385 (W 0.00327217) | 1.37252 ± 0.002671 (W 0.00427472) | 🔴 faer-fork 1.61× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.14595 ± 0.0145282 (W 0.0111634) | 5.30841 ± 0.00893758 (W 0.0120748) | 🔴 faer-fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 21.1469 ± 0.043544 (W 0.0268048) | 22.7025 ± 0.139931 (W 0.0304047) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.328213 ± 0.00186627 (W 0.00299759) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.86998 ± 0.010229 (W 0.00928877) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 11.1869 ± 0.0374799 (W 0.0149692) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.056129 ± 0.000631783 (W 0.000411537) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.056886 ± 0.000316917 (W 0.000761157) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.287289 ± 0.00257335 (W 0.00186241) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.291202 ± 0.00119783 (W 0.00236283) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.19833 ± 0.0290669 (W 0.00937966) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.25448 ± 0.0230467 (W 0.00882858) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.128603 ± 0.0165105 (W 0.00140395) | 0.151371 ± 0.0013423 (W 0.0015763) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.70095 ± 0.00240768 (W 0.00338692) | 0.438112 ± 0.00431519 (W 0.00346115) | 🔴 faer-fork 1.60× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 3.47556 ± 0.0237957 (W 0.0119812) | 1.75986 ± 0.0194345 (W 0.00952245) | 🔴 faer-fork 1.97× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.289079 ± 0.00206411 (W 0.00223575) | 0.806666 ± 0.017789 (W 0.0025907) | 🔵 faer-fork 2.79× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 0.870655 ± 0.00299314 (W 0.00204582) | 3.2217 ± 0.011085 (W 0.0070898) | 🔵 faer-fork 3.70× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 5.10902 ± 0.00688922 (W 0.0120409) | 15.7125 ± 0.0376503 (W 0.0162688) | 🔵 faer-fork 3.08× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.186032 ± 0.00118795 (W 0.00184469) | 0.390344 ± 0.0024289 (W 0.00240075) | 🔵 faer-fork 2.10× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 0.541656 ± 0.00865285 (W 0.00253848) | 1.43783 ± 0.0106125 (W 0.00398284) | 🔵 faer-fork 2.65× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 1.7362 ± 0.00225877 (W 0.00430657) | 6.87789 ± 0.0402978 (W 0.0139559) | 🔵 faer-fork 3.96× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.114208 ± 0.000929144 (W 0.000513246) | 0.150119 ± 0.00317929 (W 0.00154191) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.477301 ± 0.00220815 (W 0.00261168) | 0.442839 ± 0.00217521 (W 0.00457306) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 3.32436 ± 0.0141286 (W 0.0101818) | 1.73083 ± 0.00923033 (W 0.00624882) | 🔴 faer-fork 1.92× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 2.45798 ± 0.00725396 (W 0.00374262) | 2.98217 ± 0.0102668 (W 0.00470705) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 9.71626 ± 0.0250063 (W 0.0101683) | 14.0185 ± 0.0420175 (W 0.0125359) | 🔵 faer-fork 1.44× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 34.3506 ± 0.0683234 (W 0.0317839) | 83.4629 ± 1.58719 (W 0.0976798) | 🔵 faer-fork 2.43× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.11079 ± 0.00855112 (W 0.00301709) | 1.34591 ± 0.00397332 (W 0.00313105) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 4.8686 ± 0.0096085 (W 0.00934455) | 7.27778 ± 0.0419336 (W 0.00735754) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 19.5329 ± 0.0303806 (W 0.0181584) | 48.1683 ± 0.183159 (W 0.0408265) | 🔵 faer-fork 2.47× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.005145 ± 5.13709e-05 (W 5.10407e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014608 ± 0.000459771 (W 0.000157117) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0367985 ± 0.00162094 (W 0.000507332) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189891 ± 0.000467447 (W 0.00159306) | 0.326947 ± 0.00309851 (W 0.00243067) | 🔵 faer-fork 1.72× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.23427 ± 0.0147605 (W 0.00307666) | 2.10984 ± 0.0174198 (W 0.00543698) | 🔵 faer-fork 1.71× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.9546 ± 0.0143591 (W 0.00966125) | 12.6061 ± 0.036105 (W 0.0154618) | 🔵 faer-fork 1.58× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.35142 ± 0.00337973 (W 0.00456503) | 3.39382 ± 0.00773288 (W 0.00646458) | · |  |
| `eigh/n256/b1` | 17.702 ± 0.0185337 (W 0.0288054) | 20.2955 ± 0.0659313 (W 0.0187657) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 106.891 ± 0.314455 (W 0.0522112) | 141.878 ± 0.575046 (W 0.364369) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.797834 ± 0.00657822 (W 0.00543333) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.94187 ± 0.0275157 (W 0.0100447) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.5283 ± 0.213049 (W 0.0498453) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05618 ± 0.00450078 (W 0.00124005) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05749 ± 0.0031335 (W 0.00128333) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.52275 ± 0.0243927 (W 0.0103016) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.54372 ± 0.00809409 (W 0.0107809) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 57.1064 ± 0.0780621 (W 0.0935641) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 57.1126 ± 0.082822 (W 0.265755) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.339682 ± 0.00191438 (W 0.00267559) | 0.426156 ± 0.00410903 (W 0.00367776) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.16836 ± 0.00413942 (W 0.00267566) | 2.77258 ± 0.0416108 (W 0.00383008) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 14.8389 ± 0.0544607 (W 0.0351832) | 18.4834 ± 0.0838815 (W 0.0191239) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.54102 ± 0.00251165 (W 0.00291316) | 1.62978 ± 0.00784949 (W 0.00714972) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 10.0729 ± 0.0177612 (W 0.0108905) | 11.3647 ± 0.0242877 (W 0.0137039) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 69.4276 ± 0.0604352 (W 0.0873879) | 75.3393 ± 0.10478 (W 0.0548422) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.785728 ± 0.00172835 (W 0.00289372) | 0.818704 ± 0.00472798 (W 0.00292953) | · |  |
| `qr_factor/n256/b1` | 4.65615 ± 0.0447755 (W 0.00865879) | 5.6712 ± 0.0106344 (W 0.00850623) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 30.2404 ± 0.0588746 (W 0.0681065) | 37.4467 ± 0.046478 (W 0.032579) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.337249 ± 0.000474314 (W 0.00261294) | 0.45024 ± 0.00235799 (W 0.00281447) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 2.10961 ± 0.00238552 (W 0.00280112) | 2.84511 ± 0.00479939 (W 0.00451086) | 🔵 faer-fork 1.35× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 14.7777 ± 0.0304629 (W 0.0295602) | 18.6379 ± 0.20367 (W 0.0290351) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.39683 ± 0.00977081 (W 0.00617261) | 5.67505 ± 0.0132024 (W 0.00832243) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 32.7579 ± 0.0914027 (W 0.0285735) | 37.1519 ± 0.279387 (W 0.047112) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 208.068 ± 0.16336 (W 0.340932) | 235.902 ± 0.483874 (W 0.281278) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.86477 ± 0.00213848 (W 0.00281973) | 2.29586 ± 0.00856614 (W 0.00657039) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 13.4974 ± 0.036023 (W 0.0207567) | 16.281 ± 0.0424988 (W 0.0257189) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 93.639 ± 0.130963 (W 0.0914173) | 100.296 ± 0.637272 (W 0.213535) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.00787 ± 2.22748e-05 (W 2.71646e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.02421 ± 0.000254425 (W 5.12477e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0865665 ± 0.000733856 (W 0.000386043) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.16621 ± 0.00144636 (W 0.00168467) | 0.265348 ± 0.00197244 (W 0.00327391) | 🔵 faer-fork 1.60× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.753776 ± 0.00930638 (W 0.00274803) | 1.40623 ± 0.00424006 (W 0.00652801) | 🔵 faer-fork 1.87× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.15777 ± 0.0166088 (W 0.00927316) | 6.94483 ± 0.0678599 (W 0.0152522) | 🔵 faer-fork 2.20× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.59214 ± 0.00271615 (W 0.0049637) | 2.66088 ± 0.00816929 (W 0.00537996) | · |  |
| `eigh/n256/b1` | 8.67125 ± 0.0413818 (W 0.00861442) | 12.0499 ± 0.0650593 (W 0.0123823) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 39.4216 ± 0.126528 (W 0.0460213) | 55.5361 ± 0.126748 (W 0.0779462) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.609291 ± 0.00594516 (W 0.00431444) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.47574 ± 0.0193151 (W 0.00920843) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.3542 ± 0.0361942 (W 0.0318864) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.284126 ± 0.000853659 (W 0.00192961) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.284621 ± 0.00117229 (W 0.00182936) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92855 ± 0.00455086 (W 0.00469402) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94754 ± 0.00682944 (W 0.00333616) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.5919 ± 0.0345542 (W 0.0240617) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6251 ± 0.0318986 (W 0.0157941) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.299712 ± 0.00205985 (W 0.00233381) | 0.311561 ± 0.00125938 (W 0.00208993) | · |  |
| `lu/n256/b1` | 1.34242 ± 0.00325345 (W 0.00431059) | 1.70179 ± 0.0358676 (W 0.00307924) | 🔵 faer-fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 6.62559 ± 0.0175133 (W 0.0161602) | 7.44587 ± 0.0433281 (W 0.020182) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.746638 ± 0.00391686 (W 0.0025103) | 1.4625 ± 0.00365454 (W 0.00447616) | 🔵 faer-fork 1.96× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.25125 ± 0.00758716 (W 0.00671856) | 7.13727 ± 0.0761009 (W 0.00924068) | 🔵 faer-fork 2.20× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 20.6944 ± 0.0643489 (W 0.0518949) | 34.9003 ± 0.0692744 (W 0.0460911) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.438362 ± 0.00247477 (W 0.0022929) | 0.731382 ± 0.000858038 (W 0.00333651) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.61159 ± 0.0109533 (W 0.00287225) | 3.53296 ± 0.0126238 (W 0.00822105) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 9.31321 ± 0.0522484 (W 0.0166571) | 17.1751 ± 0.0466211 (W 0.0281979) | 🔵 faer-fork 1.84× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.293801 ± 0.00267735 (W 0.00323248) | 0.304627 ± 0.00137126 (W 0.00221643) | · |  |
| `solve/n256/b1` | 1.26972 ± 0.00536139 (W 0.00270035) | 1.67555 ± 0.0089206 (W 0.00285038) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.49249 ± 0.0292641 (W 0.0243385) | 7.35401 ± 0.174046 (W 0.0196279) | 🔵 faer-fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.2099 ± 0.00339432 (W 0.00585689) | 4.84406 ± 0.0185019 (W 0.00855894) | 🔵 faer-fork 1.51× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 15.4942 ± 0.0575265 (W 0.0210602) | 23.553 ± 0.15182 (W 0.0234834) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 74.6021 ± 0.126565 (W 0.0693146) | 118.277 ± 0.247606 (W 0.397399) | 🔵 faer-fork 1.59× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.45586 ± 0.00445243 (W 0.00308356) | 2.46559 ± 0.00291967 (W 0.00508182) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 7.83088 ± 0.0414561 (W 0.0110505) | 12.0432 ± 0.0385044 (W 0.0242137) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 40.3755 ± 0.128485 (W 0.0638107) | 54.0056 ± 0.21658 (W 0.0764163) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.009007 ± 6.56671e-05 (W 3.60531e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.02147 ± 0.000301826 (W 5.71047e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.055964 ± 0.000973142 (W 0.00046891) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.164471 ± 0.00047814 (W 0.00138919) | 0.296913 ± 0.00179806 (W 0.00322428) | 🔵 faer-fork 1.81× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.729471 ± 0.0140453 (W 0.00514734) | 1.35499 ± 0.0037266 (W 0.0047494) | 🔵 faer-fork 1.86× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 2.50062 ± 0.0135563 (W 0.00701251) | 5.75799 ± 0.0201212 (W 0.016152) | 🔵 faer-fork 2.30× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.49171 ± 0.0104271 (W 0.00465051) | 2.55922 ± 0.0142406 (W 0.00622752) | · |  |
| `eigh/n256/b1` | 7.68821 ± 0.0190548 (W 0.0158961) | 10.7872 ± 0.0298561 (W 0.0162527) | 🔵 faer-fork 1.40× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 30.5868 ± 0.0436042 (W 0.0315859) | 43.2311 ± 0.0978804 (W 0.0484388) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.600442 ± 0.00745056 (W 0.00451671) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.12532 ± 0.0192392 (W 0.0071734) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 13.8688 ± 0.0278641 (W 0.0469748) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.177926 ± 0.00165298 (W 0.00169622) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.178113 ± 0.00122654 (W 0.00162897) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.995663 ± 0.00294427 (W 0.00237216) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.00562 ± 0.00520464 (W 0.00490099) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 7.96653 ± 0.0454666 (W 0.0413736) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 7.95896 ± 0.0254325 (W 0.0301909) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.29498 ± 0.000884056 (W 0.00169603) | 0.295574 ± 0.00220609 (W 0.00337711) | · |  |
| `lu/n256/b1` | 1.22614 ± 0.00593375 (W 0.00314022) | 1.30993 ± 0.0291777 (W 0.00427504) | 🔵 faer-fork 1.07× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 5.19467 ± 0.0261425 (W 0.0114525) | 5.10188 ± 0.0247473 (W 0.0150454) | · |  |
| `qr/n128/b1` | 0.610106 ± 0.00229617 (W 0.00293825) | 1.45498 ± 0.0113911 (W 0.00465746) | 🔵 faer-fork 2.38× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.32121 ± 0.0134235 (W 0.00659742) | 6.50626 ± 0.0212916 (W 0.00945067) | 🔵 faer-fork 2.80× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 11.7563 ± 0.054305 (W 0.0403564) | 28.1758 ± 0.377769 (W 0.0268232) | 🔵 faer-fork 2.40× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.380023 ± 0.00204987 (W 0.00226573) | 0.722062 ± 0.00745888 (W 0.00418325) | 🔵 faer-fork 1.90× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.29552 ± 0.00259553 (W 0.00382635) | 3.20815 ± 0.0293786 (W 0.0112887) | 🔵 faer-fork 2.48× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 5.05071 ± 0.0521689 (W 0.0105961) | 13.7892 ± 0.298406 (W 0.0614728) | 🔵 faer-fork 2.73× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.290785 ± 0.00137827 (W 0.00156299) | 0.295799 ± 0.00185925 (W 0.00356591) | · |  |
| `solve/n256/b1` | 1.14302 ± 0.00647784 (W 0.00322667) | 1.36314 ± 0.0398786 (W 0.0105267) | 🔵 faer-fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 5.04319 ± 0.0387566 (W 0.0170726) | 5.24645 ± 0.218835 (W 0.0131471) | · | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.01033 ± 0.0111312 (W 0.00875167) | 4.78848 ± 0.0160499 (W 0.0120564) | 🔵 faer-fork 1.59× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 13.3604 ± 0.0391598 (W 0.0160937) | 21.9123 ± 0.194617 (W 0.0230075) | 🔵 faer-fork 1.64× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 55.3446 ± 0.104144 (W 0.101264) | 99.6831 ± 3.86324 (W 0.336288) | 🔵 faer-fork 1.80× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.44557 ± 0.00594762 (W 0.00453129) | 2.55518 ± 0.0153371 (W 0.00795086) | 🔵 faer-fork 1.77× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 7.14836 ± 0.0340197 (W 0.0109102) | 11.8766 ± 0.0370371 (W 0.0198414) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 32.0203 ± 0.0842472 (W 0.0376304) | 47.9308 ± 0.216039 (W 0.101705) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.008927 ± 5.2588e-05 (W 3.31037e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0209295 ± 8.64671e-05 (W 9.71577e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0503835 ± 0.0006494 (W 0.000247672) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.17689 ± 0.000244789 (W 0.00189135) | 0.184137 ± 0.00102051 (W 0.00162859) | · |  |
| `cholesky/n256/b1` | 1.1407 ± 0.00353804 (W 0.00234417) | 1.29995 ± 0.00266258 (W 0.00419505) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.56106 ± 0.0121299 (W 0.00834547) | 9.03416 ± 0.0146876 (W 0.0136251) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.34173 ± 0.00381046 (W 0.00480082) | 3.26072 ± 0.00691877 (W 0.005494) | · |  |
| `eigh/n256/b1` | 17.6268 ± 0.0193718 (W 0.0137859) | 19.6355 ± 0.0834552 (W 0.0180917) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 106.579 ± 0.236209 (W 0.0845636) | 139.253 ± 0.980193 (W 0.311637) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.770058 ± 0.00593289 (W 0.00556638) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.79722 ± 0.0297708 (W 0.0108355) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 39.8092 ± 0.150158 (W 0.0553392) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.04219 ± 0.00299455 (W 0.000829307) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04468 ± 0.00103734 (W 0.00150662) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.43311 ± 0.0257435 (W 0.00954249) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.46294 ± 0.00556371 (W 0.0124685) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 57.0409 ± 0.0689839 (W 0.0452243) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.774 ± 0.0762225 (W 0.0670412) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.311128 ± 0.00127249 (W 0.00223685) | 0.349992 ± 0.00172271 (W 0.00184936) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.05145 ± 0.00841848 (W 0.00346467) | 2.33581 ± 0.0117023 (W 0.00428947) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 14.039 ± 0.0232868 (W 0.0366914) | 16.3584 ± 0.0446534 (W 0.0182816) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.51123 ± 0.00332275 (W 0.00295648) | 1.54909 ± 0.00901063 (W 0.0029417) | · |  |
| `qr/n256/b1` | 9.95245 ± 0.0239876 (W 0.0114117) | 10.7949 ± 0.054883 (W 0.0163465) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 68.5433 ± 0.0579901 (W 0.0438807) | 73.139 ± 0.119197 (W 0.245741) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.712682 ± 0.00211335 (W 0.00183093) | 0.750217 ± 0.00428902 (W 0.00238828) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 4.31887 ± 0.0120348 (W 0.00394406) | 5.2251 ± 0.0195376 (W 0.00502629) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 28.4099 ± 0.0498401 (W 0.0281256) | 35.4658 ± 0.0374658 (W 0.0246621) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.308122 ± 0.00100965 (W 0.00263968) | 0.364565 ± 0.00199392 (W 0.00318817) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.9911 ± 0.00718466 (W 0.00209472) | 2.40202 ± 0.0151795 (W 0.00504293) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 14.0329 ± 0.0180936 (W 0.0199178) | 16.5083 ± 0.034074 (W 0.020913) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.37159 ± 0.00452531 (W 0.00495866) | 5.52309 ± 0.00455467 (W 0.00841596) | · |  |
| `svd_thin/n256/b1` | 32.4483 ± 0.0543094 (W 0.0438728) | 35.8706 ± 0.0874454 (W 0.0340875) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 206.962 ± 0.257562 (W 0.479128) | 233.517 ± 2.00792 (W 0.524339) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.84016 ± 0.00550417 (W 0.00258665) | 2.2301 ± 0.00635723 (W 0.00515243) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 13.2645 ± 0.0237388 (W 0.0156615) | 15.6866 ± 0.0843868 (W 0.0201732) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 92.6933 ± 0.191333 (W 0.252241) | 98.8834 ± 0.513464 (W 0.251575) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.00801 ± 0.000124387 (W 2.78398e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024686 ± 0.000352585 (W 7.05203e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0877225 ± 0.00081935 (W 0.000509983) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.154142 ± 0.001377 (W 0.00206286) | 0.125188 ± 0.00204008 (W 0.00175599) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.660955 ± 0.00410857 (W 0.00363392) | 0.5912 ± 0.00213033 (W 0.00272399) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.77717 ± 0.0119205 (W 0.00720251) | 3.49668 ± 0.0407464 (W 0.00878287) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.58567 ± 0.00777617 (W 0.0039542) | 2.55505 ± 0.00665259 (W 0.00487012) | · |  |
| `eigh/n256/b1` | 8.60015 ± 0.0313172 (W 0.0109201) | 11.3861 ± 0.0464122 (W 0.0168608) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 39.0818 ± 0.0615168 (W 0.0298039) | 52.8508 ± 0.187505 (W 0.0469638) | 🔵 faer-fork 1.35× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.582097 ± 0.00423822 (W 0.00380727) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.3269 ± 0.0138038 (W 0.00788287) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.6922 ± 0.0344349 (W 0.0218836) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.285112 ± 0.00133283 (W 0.00183971) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.285526 ± 0.000633486 (W 0.00152396) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92285 ± 0.00484879 (W 0.00345975) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93632 ± 0.0104675 (W 0.00464085) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.6114 ± 0.0332791 (W 0.0176303) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6155 ± 0.0458118 (W 0.0170177) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.272095 ± 0.00185841 (W 0.00307379) | 0.239244 ± 0.00103736 (W 0.00192451) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.23096 ± 0.00747693 (W 0.00424133) | 1.26797 ± 0.00255369 (W 0.00353941) | · |  |
| `lu/n512/b1` | 5.86069 ± 0.00921277 (W 0.00674861) | 5.4531 ± 0.0166786 (W 0.00943369) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.722761 ± 0.00219964 (W 0.00277509) | 1.36665 ± 0.00491251 (W 0.0043267) | 🔵 faer-fork 1.89× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.1376 ± 0.00919875 (W 0.00628424) | 6.59868 ± 0.0275332 (W 0.00740735) | 🔵 faer-fork 2.10× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.7959 ± 0.0383782 (W 0.0332216) | 32.3991 ± 0.127417 (W 0.0315911) | 🔵 faer-fork 1.64× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.409643 ± 0.00216993 (W 0.00260452) | 0.659616 ± 0.00257037 (W 0.00209608) | 🔵 faer-fork 1.61× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.51579 ± 0.00584305 (W 0.00429258) | 3.09705 ± 0.00866232 (W 0.00506863) | 🔵 faer-fork 2.04× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.78819 ± 0.0404497 (W 0.0103918) | 15.3023 ± 0.0338707 (W 0.0208896) | 🔵 faer-fork 1.74× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.267215 ± 0.0027845 (W 0.00191098) | 0.236115 ± 0.00114236 (W 0.00170335) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.16035 ± 0.00409928 (W 0.0037144) | 1.26287 ± 0.0043126 (W 0.00300188) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 5.72027 ± 0.0167407 (W 0.0147288) | 5.49296 ± 0.0241297 (W 0.0134958) | · |  |
| `svd_thin/n128/b1` | 3.19386 ± 0.00416476 (W 0.00603623) | 4.66947 ± 0.0121478 (W 0.00853849) | 🔵 faer-fork 1.46× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 15.1774 ± 0.0198846 (W 0.0173778) | 22.4826 ± 0.0294068 (W 0.0471446) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 73.522 ± 0.0998288 (W 0.0503413) | 113.564 ± 0.198394 (W 0.122454) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.43299 ± 0.00318708 (W 0.00388826) | 2.40234 ± 0.00511883 (W 0.00411667) | 🔵 faer-fork 1.68× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 7.63531 ± 0.0486172 (W 0.0147092) | 11.6417 ± 0.0156762 (W 0.0183381) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 39.2843 ± 0.104174 (W 0.156431) | 51.7473 ± 0.107806 (W 0.0359039) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.009052 ± 0.000164772 (W 1.70729e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0230075 ± 0.000234048 (W 0.000205153) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0607835 ± 0.00115469 (W 0.000438723) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.154243 ± 0.00173958 (W 0.0013264) | 0.15521 ± 0.00108683 (W 0.00212771) | · |  |
| `cholesky/n256/b1` | 0.612262 ± 0.0021532 (W 0.00206997) | 0.544555 ± 0.00305203 (W 0.00399631) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.1334 ± 0.00663555 (W 0.00459802) | 2.39131 ± 0.0094913 (W 0.00737774) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.48622 ± 0.0114105 (W 0.00783951) | 2.44214 ± 0.0102328 (W 0.00346216) | · |  |
| `eigh/n256/b1` | 7.57514 ± 0.0113273 (W 0.0115215) | 10.1311 ± 0.0169068 (W 0.0177164) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 30.2526 ± 0.0647567 (W 0.0349363) | 40.3296 ± 0.122856 (W 0.050161) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.570644 ± 0.00497817 (W 0.00539773) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.98537 ± 0.0122434 (W 0.0072041) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 13.1445 ± 0.0327049 (W 0.0219402) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.178557 ± 0.000910032 (W 0.00210393) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.179384 ± 0.00123723 (W 0.000780005) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00288 ± 0.00386631 (W 0.0047499) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01203 ± 0.0067714 (W 0.00334052) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.03506 ± 0.175232 (W 0.152516) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 7.90164 ± 0.115369 (W 0.132244) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.267348 ± 0.000890966 (W 0.00194714) | 0.224377 ± 0.00122679 (W 0.00289909) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.12133 ± 0.00532698 (W 0.00397139) | 0.889631 ± 0.00296176 (W 0.00409094) | 🔴 faer-fork 1.26× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 4.46879 ± 0.010893 (W 0.0145502) | 3.24543 ± 0.0161842 (W 0.0089754) | 🔴 faer-fork 1.38× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.58746 ± 0.00310137 (W 0.00276596) | 1.35196 ± 0.00736615 (W 0.00576869) | 🔵 faer-fork 2.30× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.20361 ± 0.0143448 (W 0.00580985) | 5.95245 ± 0.0415772 (W 0.0147655) | 🔵 faer-fork 2.70× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 10.9149 ± 0.0186536 (W 0.01601) | 25.6673 ± 0.0569892 (W 0.0479252) | 🔵 faer-fork 2.35× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.361052 ± 0.00178117 (W 0.0021559) | 0.650069 ± 0.00586698 (W 0.0031316) | 🔵 faer-fork 1.80× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.23511 ± 0.00327816 (W 0.00401631) | 2.78293 ± 0.0107625 (W 0.00908755) | 🔵 faer-fork 2.25× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.71982 ± 0.00974815 (W 0.0110019) | 11.9476 ± 0.040247 (W 0.0239336) | 🔵 faer-fork 2.53× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.260995 ± 0.00140978 (W 0.00204644) | 0.228902 ± 0.00298443 (W 0.00169388) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.03585 ± 0.00367515 (W 0.00211284) | 0.899588 ± 0.00409321 (W 0.00352813) | 🔴 faer-fork 1.15× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 4.2972 ± 0.0213603 (W 0.00896217) | 3.3247 ± 0.0122434 (W 0.00548622) | 🔴 faer-fork 1.29× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 2.98938 ± 0.0136304 (W 0.00752957) | 4.59803 ± 0.0194064 (W 0.0118158) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 13.0671 ± 0.00593452 (W 0.0205908) | 20.7385 ± 0.0985586 (W 0.0374231) | 🔵 faer-fork 1.59× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 54.4986 ± 0.0947375 (W 0.0654268) | 94.8282 ± 0.83846 (W 0.0823639) | 🔵 faer-fork 1.74× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 1.4205 ± 0.010947 (W 0.00428252) | 2.48879 ± 0.0127445 (W 0.00613557) | 🔵 faer-fork 1.75× faster than `lapack-openblas` |  |
| `svd_values/n256/b1` | 6.95967 ± 0.018995 (W 0.010347) | 11.4853 ± 0.0858361 (W 0.0223568) | 🔵 faer-fork 1.65× faster than `lapack-openblas` |  |
| `svd_values/n512/b1` | 31.052 ± 0.057129 (W 0.0372798) | 45.8021 ± 0.192291 (W 0.0512517) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.008912 ± 3.33107e-05 (W 2.01386e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023153 ± 0.000142045 (W 0.000163917) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0565105 ± 0.000608491 (W 0.000298363) | - | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.816844 ± 0.00273831 (W 0.00344405) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.2278 ± 0.539139 (W 0.448145) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.553603 ± 0.000737283 (W 0.00253193) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554126 ± 0.0035303 (W 0.00249483) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1032 ± 0.0684657 (W 0.0521194) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.1307 ± 0.0461344 (W 0.0474544) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.47034 ± 0.00399691 (W 0.00363505) | 0.762308 ± 0.119243 (W 0.00544893) | 🔵 faer-fork 1.62× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.1795 ± 0.130333 (W 0.0407322) | 28.4745 ± 0.204771 (W 0.0770899) | 🔵 faer-fork 1.88× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.42091 ± 0.00301005 (W 0.00444374) | 2.48679 ± 0.028125 (W 0.0121008) | 🔵 faer-fork 1.75× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 69.696 ± 0.178291 (W 0.122192) | 105.662 ± 1.35159 (W 1.54278) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.923425 ± 0.00410522 (W 0.00189996) | 1.29844 ± 0.00571244 (W 0.00574447) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 30.5759 ± 0.0894415 (W 0.0951007) | 50.7412 ± 1.32733 (W 0.420075) | 🔵 faer-fork 1.66× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.2931 ± 0.00932182 (W 0.00667301) | 3.77479 ± 0.0193548 (W 0.0069328) | 🔵 faer-fork 1.65× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 85.5824 ± 0.0690434 (W 0.160962) | 148.408 ± 0.908077 (W 1.41069) | 🔵 faer-fork 1.73× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.04058 ± 0.00349219 (W 0.00365542) | 1.94548 ± 0.00568512 (W 0.00342087) | 🔵 faer-fork 1.87× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 38.2761 ± 0.0790088 (W 0.0775727) | 69.5112 ± 3.75159 (W 0.786424) | 🔵 faer-fork 1.82× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.589289 ± 0.0104332 (W 0.00255705) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 16.5864 ± 0.0773464 (W 0.0345309) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.165748 ± 0.00157129 (W 0.00202386) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.165443 ± 0.00185478 (W 0.00220342) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 9.50146 ± 0.0516896 (W 0.126493) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 9.55448 ± 0.0284828 (W 0.0254455) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.437687 ± 3.49499 (W 0.00215484) | 0.701063 ± 0.128227 (W 0.00306787) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.04705 ± 0.125324 (W 0.0211785) | 22.882 ± 0.539493 (W 0.0425772) | 🔵 faer-fork 2.53× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 0.838059 ± 0.00485102 (W 0.00244602) | 2.61506 ± 0.0424999 (W 0.0119547) | 🔵 faer-fork 3.12× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 29.5306 ± 0.0568208 (W 0.0597378) | 70.1907 ± 3.40355 (W 1.12475) | 🔵 faer-fork 2.38× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.606402 ± 0.00619952 (W 0.00309054) | 1.35265 ± 0.0165744 (W 0.00890041) | 🔵 faer-fork 2.23× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 12.9301 ± 0.13893 (W 0.0339531) | 33.328 ± 1.20676 (W 0.442128) | 🔵 faer-fork 2.58× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 1.77094 ± 0.00939626 (W 0.00363552) | 3.63314 ± 0.0242112 (W 0.00921214) | 🔵 faer-fork 2.05× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 39.8055 ± 0.124771 (W 0.0926225) | 91.5135 ± 1.88094 (W 0.725033) | 🔵 faer-fork 2.30× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 0.911837 ± 0.00461066 (W 0.00512986) | 2.01034 ± 0.0132586 (W 0.00885323) | 🔵 faer-fork 2.20× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 23.1612 ± 1.16501 (W 0.0330579) | 48.514 ± 1.19053 (W 0.365991) | 🔵 faer-fork 2.09× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.574762 ± 0.0108486 (W 0.00362525) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 11.9149 ± 0.118557 (W 0.03649) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.103573 ± 0.00377129 (W 0.00245789) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.104691 ± 0.00179727 (W 0.00358144) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 5.54783 ± 0.089247 (W 0.0520943) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.65947 ± 0.0279637 (W 0.0585204) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.433358 ± 7.17129 (W 0.00238872) | 0.670354 ± 0.118985 (W 0.00384692) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.40615 ± 0.00811527 (W 0.0219173) | 20.4394 ± 0.277984 (W 0.0288161) | 🔵 faer-fork 2.43× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 0.742012 ± 0.00520143 (W 0.00414123) | 2.65773 ± 0.0354921 (W 0.00578895) | 🔵 faer-fork 3.58× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 23.7731 ± 0.126213 (W 0.0634086) | 65.3354 ± 2.78795 (W 0.959084) | 🔵 faer-fork 2.75× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.560222 ± 0.00401535 (W 0.00357718) | 1.36102 ± 0.0102472 (W 0.00644155) | 🔵 faer-fork 2.43× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 9.55153 ± 0.0456611 (W 0.0246033) | 30.8631 ± 0.783811 (W 0.636618) | 🔵 faer-fork 3.23× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 1.67208 ± 0.00691231 (W 0.00526302) | 3.6177 ± 0.0213067 (W 0.00763492) | 🔵 faer-fork 2.16× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 33.6663 ± 0.0176022 (W 0.0978798) | 84.3751 ± 1.29316 (W 0.589685) | 🔵 faer-fork 2.51× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 0.887247 ± 0.00352938 (W 0.00499821) | 2.0146 ± 0.00863076 (W 0.00567755) | 🔵 faer-fork 2.27× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 20.7242 ± 0.0535699 (W 0.0231458) | 46.6113 ± 1.00917 (W 0.366172) | 🔵 faer-fork 2.25× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731216 ± 0.00218153 (W 0.00520112) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.4955 ± 0.388548 (W 0.0712971) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.579877 ± 0.012982 (W 0.00292513) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.59438 ± 0.00542757 (W 0.00313453) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.7817 ± 0.098521 (W 0.0454904) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.7254 ± 0.104956 (W 0.0434548) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.385316 ± 0.00109341 (W 0.00257905) | 0.305826 ± 0.00294045 (W 0.00208967) | 🔴 faer-fork 1.26× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.1716 ± 0.0422773 (W 0.0475554) | 12.9746 ± 0.0899345 (W 0.0138163) | · |  |
| `qr/1024x64/b1` | 1.3034 ± 0.00209054 (W 0.00343559) | 1.87022 ± 0.00426978 (W 0.00419796) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 67.3246 ± 0.191754 (W 0.103194) | 77.2903 ± 0.35615 (W 0.130476) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.631829 ± 0.00798139 (W 0.00365151) | 0.955722 ± 0.0046006 (W 0.00261896) | 🔵 faer-fork 1.51× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 24.5816 ± 0.0539656 (W 0.0506988) | 38.6399 ± 0.187121 (W 0.0707093) | 🔵 faer-fork 1.57× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.2389 ± 0.00321287 (W 0.00711796) | 3.23973 ± 0.00660978 (W 0.0098869) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 80.3031 ± 0.137168 (W 0.121141) | 119.985 ± 0.38464 (W 0.271872) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 0.966719 ± 0.00332469 (W 0.0035821) | 1.60997 ± 0.00667419 (W 0.0056325) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 32.3353 ± 0.0523148 (W 0.0485342) | 54.5085 ± 0.413921 (W 0.112301) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.508822 ± 0.00562805 (W 0.00328213) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 14.4487 ± 0.0669545 (W 0.0309663) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.201775 ± 0.00313191 (W 0.000948659) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.20371 ± 0.00446309 (W 0.000957217) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.9367 ± 0.0463613 (W 0.0410351) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2175 ± 0.0332987 (W 0.0165592) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.353498 ± 0.00094539 (W 0.00254164) | 0.253829 ± 0.00185499 (W 0.0018961) | 🔴 faer-fork 1.39× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 6.9374 ± 0.0280448 (W 0.01918) | 7.22745 ± 0.0091114 (W 0.0061913) | · |  |
| `qr/1024x64/b1` | 0.729521 ± 0.00405517 (W 0.00417614) | 1.9856 ± 0.0100684 (W 0.00274952) | 🔵 faer-fork 2.72× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 27.1114 ± 0.114346 (W 0.0958872) | 41.1942 ± 0.229562 (W 0.0490478) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.504757 ± 0.0214874 (W 0.00328966) | 1.02564 ± 0.0029561 (W 0.00246091) | 🔵 faer-fork 2.03× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 10.6078 ± 0.246654 (W 0.0194526) | 20.611 ± 0.176859 (W 0.0403872) | 🔵 faer-fork 1.94× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 1.71731 ± 0.00164567 (W 0.00372717) | 3.11552 ± 0.0110309 (W 0.00395338) | 🔵 faer-fork 1.81× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 34.3579 ± 0.0435599 (W 0.0799288) | 66.9811 ± 0.234203 (W 0.0734854) | 🔵 faer-fork 1.95× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 0.836196 ± 0.00405735 (W 0.0021554) | 1.67946 ± 0.00487318 (W 0.00556933) | 🔵 faer-fork 2.01× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 17.3172 ± 0.025207 (W 0.0211757) | 36.1861 ± 0.347237 (W 0.0440152) | 🔵 faer-fork 2.09× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.492206 ± 0.00325783 (W 0.00894869) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 9.7716 ± 0.0677011 (W 0.022827) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.125599 ± 0.00540281 (W 0.00169963) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.129221 ± 0.00179009 (W 0.00149175) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 8.79404 ± 0.066104 (W 0.0470227) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 8.78016 ± 0.0366075 (W 0.0454196) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.348706 ± 7.20611 (W 0.00304712) | 0.233342 ± 0.000676006 (W 0.00210535) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 6.0665 ± 0.0231015 (W 0.0170336) | 4.77063 ± 0.0284495 (W 0.0100465) | 🔴 faer-fork 1.27× slower than `lapack-openblas` |  |
| `qr/1024x64/b1` | 0.635131 ± 0.00344262 (W 0.00387054) | 1.98298 ± 0.00666756 (W 0.00236534) | 🔵 faer-fork 3.12× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 21.2459 ± 0.0631519 (W 0.050809) | 36.8399 ± 0.202829 (W 0.0499655) | 🔵 faer-fork 1.73× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.461521 ± 0.00183251 (W 0.00328322) | 1.02678 ± 0.00490325 (W 0.00224886) | 🔵 faer-fork 2.22× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 8.22399 ± 0.28308 (W 0.0198184) | 18.4301 ± 0.138772 (W 0.037513) | 🔵 faer-fork 2.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 1.62174 ± 0.00577705 (W 0.00370955) | 3.08943 ± 0.0151352 (W 0.00802396) | 🔵 faer-fork 1.91× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 28.2705 ± 0.0929179 (W 0.0555911) | 60.1646 ± 0.59679 (W 0.0773904) | 🔵 faer-fork 2.13× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 0.812678 ± 0.00431219 (W 0.00306485) | 1.68876 ± 0.00482257 (W 0.00508623) | 🔵 faer-fork 2.08× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 14.8217 ± 0.0472744 (W 0.0305579) | 33.8442 ± 0.189273 (W 0.045704) | 🔵 faer-fork 2.28× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78985 ± 0.00985689 (W 0.00347407) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 149.084 ± 0.748408 (W 0.61582) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.18678 ± 0.0115884 (W 0.00567288) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.19318 ± 0.0079963 (W 0.00310327) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.461 ± 0.290948 (W 0.293655) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.445 ± 0.345043 (W 0.298318) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.03187 ± 0.00179959 (W 0.00262223) | 1.29701 ± 0.00920925 (W 0.0045878) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 46.883 ± 0.164151 (W 0.158064) | 68.4314 ± 4.78126 (W 0.138138) | 🔵 faer-fork 1.46× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 4.46825 ± 0.0161824 (W 0.00879179) | 4.34857 ± 0.0464812 (W 0.00590288) | · |  |
| `qr/4096x256/b1` | 241.516 ± 5.38241 (W 0.427463) | 265.538 ± 2.30591 (W 1.07561) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.3109 ± 0.0110039 (W 0.0044204) | 2.20198 ± 0.0169305 (W 0.00550667) | · |  |
| `qr_factor/4096x256/b1` | 97.737 ± 0.384832 (W 0.112076) | 130.559 ± 3.82099 (W 0.226454) | 🔵 faer-fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 5.68256 ± 0.0142626 (W 0.0117784) | 6.90853 ± 0.0562253 (W 0.0145133) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 276.115 ± 0.458484 (W 1.42771) | 382.864 ± 3.03403 (W 1.26502) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.53273 ± 0.0141386 (W 0.00343638) | 3.15361 ± 0.0142324 (W 0.0112547) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 114.216 ± 0.8806 (W 0.129953) | 155.315 ± 3.80266 (W 0.399691) | 🔵 faer-fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.937265 ± 0.0103116 (W 0.00400466) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 51.8924 ± 0.285208 (W 0.348278) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.5848 ± 0.00822716 (W 0.00261559) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.596034 ± 0.00438972 (W 0.00219659) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 36.9815 ± 0.10155 (W 0.0559002) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 36.9557 ± 0.0571642 (W 0.0559308) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.793192 ± 0.00103193 (W 0.00263696) | 1.02168 ± 0.0208717 (W 0.00201626) | 🔵 faer-fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 23.1049 ± 0.208654 (W 0.0511733) | 41.2296 ± 1.84237 (W 0.118818) | 🔵 faer-fork 1.78× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.98466 ± 0.0075546 (W 0.00665772) | 2.1884 ± 0.0373224 (W 0.00539459) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 78.224 ± 0.120387 (W 0.0970563) | 111.459 ± 4.54419 (W 0.902447) | 🔵 faer-fork 1.42× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.2697 ± 0.00721038 (W 0.00339464) | 1.1375 ± 0.015957 (W 0.00316344) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 35.776 ± 0.444235 (W 0.0723304) | 57.0487 ± 2.26631 (W 0.101748) | 🔵 faer-fork 1.59× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 3.12541 ± 0.0173129 (W 0.00489928) | 3.70601 ± 0.010805 (W 0.00685308) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 102.014 ± 0.218897 (W 0.176168) | 157.989 ± 2.03618 (W 0.508392) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.73001 ± 0.0245008 (W 0.00534187) | 2.07586 ± 0.0257076 (W 0.004765) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 53.7327 ± 0.0981987 (W 0.0807835) | 78.0337 ± 2.24077 (W 0.173086) | 🔵 faer-fork 1.45× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.829583 ± 0.00500315 (W 0.00455359) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 28.9117 ± 0.0497737 (W 0.205985) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.311493 ± 0.00605579 (W 0.00246085) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.314177 ± 0.00389991 (W 0.00248811) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 24.547 ± 0.227245 (W 0.177156) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 23.6319 ± 0.191263 (W 0.0772391) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.74371 ± 0.00183004 (W 0.00260148) | 0.927675 ± 0.0280331 (W 0.00350986) | 🔵 faer-fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 18.4268 ± 0.236589 (W 0.0675589) | 35.7102 ± 5.97679 (W 0.100146) | 🔵 faer-fork 1.94× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.60211 ± 0.00354732 (W 0.00411932) | 1.9882 ± 0.0196113 (W 0.00665524) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 60.4135 ± 6.11134 (W 0.218148) | 88.688 ± 5.15193 (W 0.195245) | 🔵 faer-fork 1.47× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.10638 ± 0.0163265 (W 0.00398959) | 1.00422 ± 0.00759909 (W 0.00273346) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 26.6176 ± 0.0958775 (W 0.0295004) | 41.8068 ± 1.89647 (W 0.0850377) | 🔵 faer-fork 1.57× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.71238 ± 0.0168783 (W 0.00365999) | 3.33399 ± 0.0225891 (W 0.0061983) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 77.5291 ± 0.109518 (W 0.140809) | 119.405 ± 0.520608 (W 0.295016) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.61364 ± 0.0223376 (W 0.00626519) | 1.95916 ± 0.0160535 (W 0.00473408) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 44.8556 ± 0.769159 (W 0.0695703) | 62.0981 ± 0.478028 (W 0.166624) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6746 ± 0.00744109 (W 0.00628491) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.436 ± 0.902977 (W 0.588965) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.25802 ± 0.0110224 (W 0.00775361) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26299 ± 0.00627001 (W 0.00909218) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.372 ± 0.380519 (W 0.122889) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.345 ± 0.330546 (W 0.134044) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.918094 ± 0.00485738 (W 0.00206906) | 0.937358 ± 0.00598318 (W 0.00220144) | · |  |
| `lu/4096x256/b1` | 41.9007 ± 0.0994087 (W 0.0331247) | 47.0536 ± 0.0845299 (W 0.0787858) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 4.36036 ± 0.0203988 (W 0.00667934) | 3.53538 ± 0.0146692 (W 0.00843725) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 235.654 ± 5.34639 (W 0.159703) | 223.35 ± 1.18868 (W 0.393324) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.9807 ± 0.0324335 (W 0.00328728) | 1.81403 ± 0.00698523 (W 0.00703481) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 87.0602 ± 0.104719 (W 0.390989) | 111.837 ± 0.697871 (W 0.423744) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.58609 ± 0.00919968 (W 0.0113167) | 6.24731 ± 0.0136621 (W 0.0121043) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 264.136 ± 0.531193 (W 0.415856) | 353.023 ± 4.39066 (W 0.780346) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.43079 ± 0.00867206 (W 0.0106286) | 2.74026 ± 0.0131299 (W 0.00473601) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 102.236 ± 0.107124 (W 0.138952) | 137.37 ± 0.442653 (W 0.541526) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.824647 ± 0.00877535 (W 0.00372311) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.7658 ± 0.145026 (W 0.139823) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.660571 ± 0.00813763 (W 0.00524856) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.65965 ± 0.00703632 (W 0.00378492) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.3203 ± 0.156273 (W 0.0409425) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.4978 ± 0.14776 (W 0.10727) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.681677 ± 0.0017348 (W 0.00270452) | 0.686401 ± 0.00171199 (W 0.00389407) | · |  |
| `lu/4096x256/b1` | 17.6232 ± 0.042319 (W 0.0322488) | 24.1193 ± 0.0985316 (W 0.0344045) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.86934 ± 0.00819872 (W 0.00383585) | 1.45947 ± 0.00523372 (W 0.00460173) | 🔴 faer-fork 1.28× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 72.8435 ± 0.110586 (W 0.07865) | 73.3032 ± 0.22794 (W 0.109078) | · |  |
| `qr_factor/1024x64/b1` | 1.12679 ± 0.00883699 (W 0.00373629) | 0.782838 ± 0.00573355 (W 0.00281528) | 🔴 faer-fork 1.44× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 31.3177 ± 0.0476265 (W 0.0507812) | 36.3588 ± 0.0957329 (W 0.0509311) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.00438 ± 0.0129493 (W 0.00637409) | 3.124 ± 0.00598381 (W 0.00910263) | · |  |
| `svd_thin/4096x256/b1` | 89.8254 ± 0.121223 (W 0.0989557) | 123.077 ± 0.238125 (W 0.213076) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.62839 ± 0.0105605 (W 0.00481565) | 1.72795 ± 0.00831472 (W 0.00382811) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 41.6998 ± 0.190691 (W 0.0664422) | 57.0394 ± 0.409642 (W 0.0928531) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.714106 ± 0.0138204 (W 0.00381109) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 23.8561 ± 0.201211 (W 0.077725) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.384233 ± 0.0105377 (W 0.00372257) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.377682 ± 0.00698929 (W 0.00253931) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 24.8435 ± 1.39355 (W 0.982669) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 24.0367 ± 0.769186 (W 1.19943) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.632348 ± 0.00217248 (W 0.00277677) | 0.56635 ± 0.00246209 (W 0.00362728) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.4733 ± 0.0489738 (W 0.0253645) | 14.4596 ± 0.0429946 (W 0.0326043) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.47735 ± 0.00850187 (W 0.00307054) | 1.16531 ± 0.0113175 (W 0.00412859) | 🔴 faer-fork 1.27× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 54.7357 ± 5.34779 (W 0.179396) | 50.3941 ± 0.135515 (W 0.0857185) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.01268 ± 0.00637214 (W 0.00457279) | 0.635856 ± 0.003219 (W 0.00335562) | 🔴 faer-fork 1.59× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 22.9948 ± 0.139957 (W 0.0779623) | 24.9291 ± 0.0843894 (W 0.0278967) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.60754 ± 0.00490294 (W 0.0078778) | 2.68029 ± 0.00477317 (W 0.00414059) | · |  |
| `svd_thin/4096x256/b1` | 65.1741 ± 0.118548 (W 0.109488) | 88.6264 ± 0.317177 (W 0.127348) | 🔵 faer-fork 1.36× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.53024 ± 0.00633826 (W 0.00732597) | 1.58053 ± 0.00428895 (W 0.00509955) | · |  |
| `svd_values/4096x256/b1` | 32.7712 ± 0.143896 (W 0.0461842) | 45.0399 ± 0.270365 (W 0.335984) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 75.4856 ± 1.01579 (W 0.398838) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.1176 ± 0.00409717 (W 0.00697716) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 15.9261 ± 0.058042 (W 0.0296479) | 35.7719 ± 0.275648 (W 0.0813407) | 🔵 faer-fork 2.25× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.392817 ± 0.00098758 (W 0.00330694) | 1.16751 ± 0.140649 (W 0.0119526) | 🔵 faer-fork 2.97× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 30.6628 ± 0.196384 (W 0.108237) | 70.3991 ± 4.69224 (W 0.517607) | 🔵 faer-fork 2.30× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.732105 ± 0.00321013 (W 0.00261974) | 1.89162 ± 0.0241042 (W 0.00821017) | 🔵 faer-fork 2.58× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 27.2508 ± 0.426571 (W 0.0388278) | 65.493 ± 1.93089 (W 0.74537) | 🔵 faer-fork 2.40× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.993111 ± 0.00317532 (W 0.00301209) | 1.73782 ± 0.0164379 (W 0.0150548) | 🔵 faer-fork 1.75× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 80.4561 ± 0.369563 (W 0.189699) | 219.958 ± 3.69945 (W 0.956165) | 🔵 faer-fork 2.73× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.23506 ± 0.00522241 (W 0.00560257) | 5.00779 ± 0.0313706 (W 0.015701) | 🔵 faer-fork 2.24× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 32.5009 ± 0.0919499 (W 0.0359678) | 103.229 ± 2.63703 (W 0.631266) | 🔵 faer-fork 3.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 0.964914 ± 0.00722674 (W 0.00331652) | 2.57296 ± 0.0380054 (W 0.0150256) | 🔵 faer-fork 2.67× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.7472 ± 0.16929 (W 0.140929) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.717962 ± 0.018783 (W 0.00318246) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 6.62456 ± 0.109625 (W 0.0587654) | 27.4069 ± 0.582926 (W 0.0837227) | 🔵 faer-fork 4.14× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.205763 ± 4.81471 (W 0.00164967) | 0.957774 ± 0.135249 (W 0.00269667) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 10.6001 ± 0.0561144 (W 0.0732059) | 45.4419 ± 2.65744 (W 0.0948241) | 🔵 faer-fork 4.29× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.36217 ± 0.00176209 (W 0.0027069) | 1.84631 ± 0.0130677 (W 0.00825221) | 🔵 faer-fork 5.10× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 9.99467 ± 0.194188 (W 0.0238168) | 39.6966 ± 0.549713 (W 0.414669) | 🔵 faer-fork 3.97× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.614226 ± 0.00460279 (W 0.00574306) | 1.67412 ± 0.00742737 (W 0.00842687) | 🔵 faer-fork 2.73× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 34.2561 ± 0.0607577 (W 0.0554665) | 146.653 ± 4.26127 (W 0.824349) | 🔵 faer-fork 4.28× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 1.70898 ± 0.00331173 (W 0.00372522) | 4.6418 ± 0.0361751 (W 0.0116568) | 🔵 faer-fork 2.72× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 17.3977 ± 0.0399915 (W 0.028692) | 76.54 ± 0.914136 (W 0.274623) | 🔵 faer-fork 4.40× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 0.837745 ± 0.00340318 (W 0.00188185) | 2.56578 ± 0.0375245 (W 0.00972358) | 🔵 faer-fork 3.06× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 27.1295 ± 0.310725 (W 0.100201) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.690661 ± 0.010484 (W 0.00277485) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.08209 ± 0.127444 (W 0.0286385) | 24.9435 ± 0.251727 (W 0.342188) | 🔵 faer-fork 4.91× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.179816 ± 3.00568 (W 0.00060191) | 0.915109 ± 0.143395 (W 0.0025975) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 7.12049 ± 0.0731594 (W 0.0301826) | 41.0533 ± 2.19756 (W 0.0808613) | 🔵 faer-fork 5.77× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.314076 ± 0.00167233 (W 0.00193531) | 1.84613 ± 0.0145772 (W 0.00684414) | 🔵 faer-fork 5.88× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 7.22011 ± 0.208736 (W 0.0178198) | 37.6025 ± 2.33572 (W 0.08337) | 🔵 faer-fork 5.21× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.556928 ± 0.00530241 (W 0.0043711) | 1.67226 ± 0.00925186 (W 0.00779597) | 🔵 faer-fork 3.00× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 28.4393 ± 0.0717523 (W 0.03323) | 145.731 ± 1.66087 (W 1.05863) | 🔵 faer-fork 5.12× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 1.61702 ± 0.00248003 (W 0.00491716) | 4.55236 ± 0.063996 (W 0.0146329) | 🔵 faer-fork 2.82× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 14.9383 ± 0.0263529 (W 0.0301375) | 73.4658 ± 1.58574 (W 0.141519) | 🔵 faer-fork 4.92× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 0.810148 ± 0.00198851 (W 0.00360161) | 2.56768 ± 0.0163429 (W 0.00898003) | 🔵 faer-fork 3.17× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.5121 ± 1.13973 (W 0.237056) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.0377 ± 0.00474926 (W 0.00385348) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2515 ± 0.0285367 (W 0.0227285) | 20.218 ± 0.0458 (W 0.0455693) | 🔵 faer-fork 1.53× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.313315 ± 0.00158273 (W 0.00278867) | 0.703148 ± 0.00464086 (W 0.00297021) | 🔵 faer-fork 2.24× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 27.6443 ± 0.20253 (W 0.13236) | 69.4778 ± 5.42727 (W 0.332574) | 🔵 faer-fork 2.51× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.621893 ± 0.00208697 (W 0.00260066) | 1.64382 ± 0.0438846 (W 0.00551127) | 🔵 faer-fork 2.64× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 25.2376 ± 0.346382 (W 0.0682595) | 52.5734 ± 2.14805 (W 0.236247) | 🔵 faer-fork 2.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.553882 ± 0.00172078 (W 0.00287692) | 1.37627 ± 0.00737821 (W 0.00500674) | 🔵 faer-fork 2.48× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 85.782 ± 0.351944 (W 0.261006) | 196.536 ± 3.66679 (W 0.804727) | 🔵 faer-fork 2.29× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.29803 ± 0.00755696 (W 0.0043698) | 4.54074 ± 0.0405653 (W 0.0129212) | 🔵 faer-fork 1.98× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 38.2104 ± 0.0924246 (W 0.0509983) | 91.2859 ± 2.63536 (W 0.500306) | 🔵 faer-fork 2.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.03191 ± 0.00719129 (W 0.00523842) | 2.24164 ± 0.0629899 (W 0.00873334) | 🔵 faer-fork 2.17× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.2109 ± 0.224487 (W 0.0467138) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.64424 ± 0.0195978 (W 0.00252075) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 4.02584 ± 0.0125692 (W 0.00759598) | 12.1214 ± 0.0880808 (W 0.0267392) | 🔵 faer-fork 3.01× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.116969 ± 0.00038041 (W 0.000485096) | 0.491756 ± 0.00283455 (W 0.00187785) | 🔵 faer-fork 4.20× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 7.62859 ± 0.748733 (W 0.0314186) | 45.3023 ± 4.16771 (W 0.0873025) | 🔵 faer-fork 5.94× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.246725 ± 0.00102276 (W 0.00186667) | 1.57434 ± 0.0153854 (W 0.00719532) | 🔵 faer-fork 6.38× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 6.60621 ± 0.0535282 (W 0.0113408) | 28.4949 ± 0.415406 (W 0.079773) | 🔵 faer-fork 4.31× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.194392 ± 0.002039 (W 0.00167224) | 1.28704 ± 0.0530677 (W 0.00478606) | 🔵 faer-fork 6.62× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 39.66 ± 0.106495 (W 0.0738441) | 126.011 ± 1.72213 (W 0.476789) | 🔵 faer-fork 3.18× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 1.77741 ± 0.0045545 (W 0.00361727) | 4.1819 ± 0.0926566 (W 0.00985181) | 🔵 faer-fork 2.35× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 23.0479 ± 0.0644882 (W 0.0338024) | 64.0737 ± 1.12449 (W 0.308002) | 🔵 faer-fork 2.78× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 0.906805 ± 0.0036579 (W 0.0052659) | 2.2129 ± 0.0343334 (W 0.00605858) | 🔵 faer-fork 2.44× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 24.6479 ± 0.362162 (W 0.0362686) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.612534 ± 0.00834364 (W 0.00304926) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.52923 ± 0.00584623 (W 0.00736909) | 9.87289 ± 0.0190627 (W 0.018163) | 🔵 faer-fork 3.90× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.089186 ± 0.000440256 (W 0.000408697) | 0.453447 ± 0.00183385 (W 0.00258323) | 🔵 faer-fork 5.08× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 4.33767 ± 0.0149397 (W 0.0147235) | 38.7498 ± 0.644795 (W 0.487053) | 🔵 faer-fork 8.93× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.197603 ± 0.00169073 (W 0.00141794) | 1.5689 ± 0.0206667 (W 0.018652) | 🔵 faer-fork 7.94× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 3.55237 ± 0.0163515 (W 0.00969126) | 25.1606 ± 0.110452 (W 0.04578) | 🔵 faer-fork 7.08× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.145641 ± 0.00391949 (W 0.00116589) | 1.26546 ± 0.0228791 (W 0.00357699) | 🔵 faer-fork 8.69× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 33.6185 ± 0.101546 (W 0.0744474) | 117.655 ± 1.03201 (W 0.329358) | 🔵 faer-fork 3.50× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 1.68708 ± 0.00336756 (W 0.00594636) | 4.0545 ± 0.0307562 (W 0.0102497) | 🔵 faer-fork 2.40× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 20.5839 ± 0.0561906 (W 0.0255927) | 61.4469 ± 0.494812 (W 0.156793) | 🔵 faer-fork 2.99× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 0.878725 ± 0.00552322 (W 0.00449514) | 2.17762 ± 0.0291295 (W 0.00855357) | 🔵 faer-fork 2.48× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 227.688 ± 6.37246 (W 0.732555) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.43088 ± 0.0241046 (W 0.00698172) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.01 ± 0.221367 (W 0.0838058) | 82.4337 ± 1.78505 (W 0.228428) | 🔵 faer-fork 1.79× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.995412 ± 0.00412579 (W 0.00300822) | 1.67816 ± 0.0270785 (W 0.00385016) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 107.336 ± 0.596357 (W 0.390233) | 180.743 ± 3.50591 (W 2.02075) | 🔵 faer-fork 1.68× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 2.50717 ± 0.0214101 (W 0.0062393) | 3.64858 ± 0.0582847 (W 0.00627923) | 🔵 faer-fork 1.46× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 96.6958 ± 0.254337 (W 0.147984) | 162.977 ± 1.91444 (W 1.14724) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.55217 ± 0.00868469 (W 0.011422) | 3.37082 ± 0.0598458 (W 0.00745096) | 🔵 faer-fork 1.32× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 264.497 ± 0.416354 (W 3.50489) | 681.793 ± 12.2779 (W 2.27566) | 🔵 faer-fork 2.58× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 5.623 ± 0.0223699 (W 0.00743389) | 11.9629 ± 0.169217 (W 0.0304261) | 🔵 faer-fork 2.13× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 102.119 ± 0.181286 (W 0.133604) | 304.865 ± 6.7654 (W 1.67601) | 🔵 faer-fork 2.99× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.41309 ± 0.0170097 (W 0.00580935) | 5.66885 ± 0.104901 (W 0.0155656) | 🔵 faer-fork 2.35× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 82.8667 ± 0.664598 (W 0.484787) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.33428 ± 0.00446225 (W 0.00406742) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.5274 ± 0.188216 (W 0.0458546) | 56.827 ± 0.228997 (W 0.0540847) | 🔵 faer-fork 3.24× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.456787 ± 0.0450279 (W 0.0390503) | 1.19592 ± 0.00454621 (W 0.00590048) | 🔵 faer-fork 2.62× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 31.8639 ± 0.231973 (W 0.10149) | 91.2759 ± 2.55539 (W 1.79067) | 🔵 faer-fork 2.86× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.875168 ± 0.00217005 (W 0.00251052) | 1.68907 ± 0.0121443 (W 0.00439841) | 🔵 faer-fork 1.93× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 27.7821 ± 0.271491 (W 0.0633811) | 71.2024 ± 2.58261 (W 0.489835) | 🔵 faer-fork 2.56× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.974505 ± 0.00422874 (W 0.00502877) | 1.38609 ± 0.0220404 (W 0.00553457) | 🔵 faer-fork 1.42× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 90.5775 ± 0.0862665 (W 0.25361) | 446.291 ± 3.75029 (W 2.33316) | 🔵 faer-fork 4.93× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.03128 ± 0.0052985 (W 0.00497448) | 9.87331 ± 0.0773832 (W 0.0188474) | 🔵 faer-fork 3.26× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 41.6395 ± 0.200316 (W 0.0477102) | 223.478 ± 6.39709 (W 0.707257) | 🔵 faer-fork 5.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.6252 ± 0.00459087 (W 0.00628174) | 5.04571 ± 0.0768047 (W 0.0150404) | 🔵 faer-fork 3.10× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 54.6955 ± 0.891026 (W 0.181741) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.20466 ± 0.00501632 (W 0.00561694) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 11.5866 ± 0.0554263 (W 0.0979409) | 49.9719 ± 0.272411 (W 0.0716392) | 🔵 faer-fork 4.31× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.363447 ± 0.00138989 (W 0.00213394) | 1.06154 ± 0.0116022 (W 0.00424368) | 🔵 faer-fork 2.92× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 19.4316 ± 0.157017 (W 0.077864) | 71.5425 ± 2.27323 (W 1.34471) | 🔵 faer-fork 3.68× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.609901 ± 0.00266453 (W 0.00243581) | 1.40974 ± 0.0215663 (W 0.00498306) | 🔵 faer-fork 2.31× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 16.2215 ± 0.137814 (W 0.0453846) | 55.8415 ± 1.51286 (W 0.520219) | 🔵 faer-fork 3.44× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.717453 ± 0.00360403 (W 0.00520924) | 1.1133 ± 0.0102452 (W 0.00464963) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 65.6747 ± 0.0897169 (W 0.0851625) | 397.228 ± 7.44862 (W 1.96783) | 🔵 faer-fork 6.05× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.64639 ± 0.0681 (W 0.00695399) | 9.82823 ± 0.0617743 (W 0.0243895) | 🔵 faer-fork 3.71× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/256x4096/b1` | 32.8005 ± 0.0680905 (W 0.0473431) | 207.882 ± 6.80806 (W 0.404797) | 🔵 faer-fork 6.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.51219 ± 0.00834779 (W 0.00554326) | 5.07122 ± 0.0807466 (W 0.0210102) | 🔵 faer-fork 3.35× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 223.684 ± 5.96165 (W 0.969345) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.3022 ± 0.0159068 (W 0.0126277) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 41.9032 ± 0.109479 (W 0.0455215) | 55.5102 ± 0.411193 (W 0.0836956) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.892924 ± 0.00436898 (W 0.00593001) | 1.26464 ± 0.0114846 (W 0.00307946) | 🔵 faer-fork 1.42× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 102.51 ± 0.375693 (W 0.294106) | 184.317 ± 2.3054 (W 1.73156) | 🔵 faer-fork 1.80× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.39742 ± 0.0185103 (W 0.00360652) | 3.6002 ± 0.223036 (W 0.0109238) | 🔵 faer-fork 1.50× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 95.504 ± 0.539323 (W 0.34639) | 146.962 ± 2.67653 (W 1.03403) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.20126 ± 0.0115209 (W 0.00500741) | 2.94661 ± 0.0342769 (W 0.00749102) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 276.355 ± 0.440587 (W 0.297498) | 649.171 ± 3.07379 (W 2.17706) | 🔵 faer-fork 2.35× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 5.74062 ± 0.0218256 (W 0.00999319) | 11.3064 ± 0.186492 (W 0.0206093) | 🔵 faer-fork 1.97× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 114.562 ± 0.981551 (W 0.447817) | 284.435 ± 2.13859 (W 0.989479) | 🔵 faer-fork 2.48× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.54811 ± 0.0235633 (W 0.0043418) | 5.2312 ± 0.0889111 (W 0.015132) | 🔵 faer-fork 2.05× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 78.9992 ± 0.758763 (W 0.444616) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.19933 ± 0.00556487 (W 0.004856) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2888 ± 0.0804442 (W 0.0225372) | 30.4815 ± 0.117547 (W 0.0390764) | 🔵 faer-fork 2.29× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.343925 ± 0.0465073 (W 0.00262895) | 0.795498 ± 0.00558856 (W 0.00244396) | 🔵 faer-fork 2.31× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 27.6589 ± 0.170918 (W 0.0768336) | 88.6183 ± 0.87709 (W 0.331588) | 🔵 faer-fork 3.20× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.764834 ± 0.00294496 (W 0.00240958) | 1.5956 ± 0.261629 (W 0.0080721) | 🔵 faer-fork 2.09× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 24.8399 ± 0.0718408 (W 0.0470362) | 54.2965 ± 0.383263 (W 0.134713) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.644317 ± 0.00194412 (W 0.0026557) | 0.998254 ± 0.00450771 (W 0.0031907) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 102.751 ± 0.0967346 (W 0.151484) | 396.714 ± 4.75045 (W 0.624044) | 🔵 faer-fork 3.86× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.16425 ± 0.0177192 (W 0.00494422) | 9.25566 ± 0.0857798 (W 0.0226087) | 🔵 faer-fork 2.93× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 53.7837 ± 0.580957 (W 0.0995907) | 198.206 ± 0.599927 (W 0.456991) | 🔵 faer-fork 3.69× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.72617 ± 0.00456509 (W 0.00632431) | 4.6689 ± 0.0450837 (W 0.0132734) | 🔵 faer-fork 2.70× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 50.8655 ± 0.568466 (W 0.205733) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.06817 ± 0.00218456 (W 0.004125) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.6992 ± 0.0758399 (W 0.0246053) | 23.5391 ± 0.130617 (W 0.0274657) | 🔵 faer-fork 3.06× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.248187 ± 0.000996738 (W 0.00163762) | 0.668505 ± 0.00393818 (W 0.00282339) | 🔵 faer-fork 2.69× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 15.3734 ± 0.0924095 (W 0.0314085) | 72.1985 ± 0.410659 (W 0.357336) | 🔵 faer-fork 4.70× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.502605 ± 0.00178748 (W 0.00279669) | 1.27692 ± 0.163097 (W 0.0206615) | 🔵 faer-fork 2.54× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 13.2263 ± 0.0398045 (W 0.0197977) | 37.736 ± 0.24565 (W 0.14101) | 🔵 faer-fork 2.85× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.391944 ± 0.00240629 (W 0.00250485) | 0.727074 ± 0.00483466 (W 0.00394532) | 🔵 faer-fork 1.86× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 78.0872 ± 0.0708332 (W 0.219599) | 355.442 ± 6.60804 (W 0.770516) | 🔵 faer-fork 4.55× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.75393 ± 0.00995771 (W 0.00621419) | 9.07618 ± 0.106354 (W 0.0186029) | 🔵 faer-fork 3.30× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 44.8351 ± 0.0843378 (W 0.0790118) | 183.456 ± 0.38847 (W 0.268596) | 🔵 faer-fork 4.09× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.61752 ± 0.0177051 (W 0.00565447) | 4.63855 ± 0.0600999 (W 0.0211982) | 🔵 faer-fork 2.87× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
