# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a5e6b7d239466fb0d685edc20db6c4f3f3a71411`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `9b3d2a063afa1a99419f8f52f731123547e22a7f`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `a0b78b917535d259ec45220ada7eab9d24080927acc06f70feb70fd4cb128003`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T08:18:28.949900Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor openblas --engines faer-fork,lapack-openblas --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 6 --prime-ms 250 --label periodic-20261019-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels/20261019T052233Z-periodic-20261019-openblas/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.48%, worst 140.38% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 302 of 2328 engine cells exceed 5% and carry `!`; median within-process relative SD 0.44%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023445 ± 1.67412e-05 (W 9.59113e-06) | 0.002234 ± 1.0328e-05 (W 2.18123e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017127 ± 7.34166e-05 (W 4.19752e-05) | 0.0168015 ± 6.47014e-05 (W 1.71223e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0567765 ± 6.94579e-05 (W 6.54529e-05) | 0.056345 ± 9.71056e-05 (W 0.000579263) | · |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023345 ± 4.41697e-05 (W 1.90234e-05) | 0.002234 ± 1.50555e-05 (W 1.98848e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017097 ± 0.000131098 (W 2.31951e-05) | 0.0167965 ± 3.30298e-05 (W 1.70383e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.048169 ± 0.0113417 (W 0.0130903) | 0.0562405 ± 8.57034e-05 (W 4.21859e-05) | · | `!` between-start range over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 4.23812e-05 (W 1.52385e-05) | 0.002219 ± 1.20111e-05 (W 2.15428e-05) | 🔴 fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0171165 ± 0.000163296 (W 2.95553e-05) | 0.0168315 ± 4.432e-05 (W 2.11643e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0307925 ± 0.000978211 (W 0.00157402) | 0.056245 ± 0.000109387 (W 5.67151e-05) | 🔵 fork 1.83× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 1.30486e-05 (W 1.9072e-05) | 0.002224 ± 1.16905e-05 (W 1.47965e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0170965 ± 3.17327e-05 (W 2.08279e-05) | 0.0168365 ± 5.63113e-05 (W 2.38122e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0567765 ± 0.000172687 (W 0.000529744) | 0.0562745 ± 6.26738e-05 (W 3.92807e-05) | · |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 1.66213e-05 (W 1.82384e-05) | 0.002219 ± 1.47196e-05 (W 1.2723e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017092 ± 0.000107455 (W 2.00686e-05) | 0.0168065 ± 1.76342e-05 (W 1.73569e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0513215 ± 0.0126043 (W 0.0122204) | 0.056345 ± 0.00019906 (W 7.98211e-05) | · | `!` between-start range over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.00233 ± 3.91186e-05 (W 1.3572e-05) | 0.002224 ± 1.7224e-05 (W 1.93028e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017187 ± 0.000146772 (W 3.25678e-05) | 0.0168315 ± 2.17624e-05 (W 2.05208e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.031524 ± 0.00106598 (W 0.00199358) | 0.0562605 ± 8.44174e-05 (W 4.32675e-05) | 🔵 fork 1.78× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008836 ± 4.80278e-05 (W 1.03981e-05) | 0.011586 ± 2.23674e-05 (W 2.89208e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0676765 ± 0.000134671 (W 0.000569811) | 0.0858755 ± 0.000336534 (W 0.000709817) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.226707 ± 0.000547992 (W 0.00152939) | 0.276045 ± 0.000505234 (W 0.00148452) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008811 ± 3.56506e-05 (W 1.43924e-05) | 0.011581 ± 3.32906e-05 (W 2.68089e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.045595 ± 0.00436152 (W 0.0038393) | 0.025918 ± 0.000192516 (W 0.000320265) | 🔴 fork 1.76× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.088345 ± 0.00358435 (W 0.00694445) | 0.0790775 ± 0.000535037 (W 0.00131066) | 🔴 fork 1.12× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008907 ± 6.97722e-05 (W 1.73578e-05) | 0.0116115 ± 3.09887e-05 (W 2.51768e-05) | 🔵 fork 1.30× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.036162 ± 0.000668715 (W 0.0016335) | 0.025638 ± 0.000456536 (W 0.000168378) | 🔴 fork 1.41× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.0512655 ± 0.00114477 (W 0.00188716) | 0.055263 ± 0.000543019 (W 0.000358023) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088365 ± 5.96847e-05 (W 1.79748e-05) | 0.0115665 ± 6.68601e-05 (W 3.49809e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0677165 ± 0.000146455 (W 0.000486981) | 0.0858455 ± 0.000191051 (W 0.00125546) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.226793 ± 0.000429309 (W 0.00154806) | 0.276103 ± 0.000380274 (W 0.00167842) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088115 ± 2.9489e-05 (W 1.86146e-05) | 0.0115715 ± 1.3914e-05 (W 2.36111e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.04002 ± 0.0045317 (W 0.00421765) | 0.026094 ± 3.7518e-05 (W 0.000249756) | 🔴 fork 1.53× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.088204 ± 0.00513415 (W 0.00591072) | 0.0786615 ± 0.000425983 (W 0.000386174) | 🔴 fork 1.12× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008892 ± 6.67403e-05 (W 1.81563e-05) | 0.011592 ± 1.89807e-05 (W 2.45701e-05) | 🔵 fork 1.30× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0368085 ± 0.000765288 (W 0.00160509) | 0.0255775 ± 0.000381049 (W 0.000149345) | 🔴 fork 1.44× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.050795 ± 0.000718852 (W 0.00185822) | 0.0550125 ± 0.000351495 (W 0.000286397) | 🔵 fork 1.08× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133574 ± 0.000172135 (W 0.00108351) | 0.163105 ± 0.000490145 (W 0.00126862) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.451924 ± 0.0025563 (W 0.00201312) | 0.538614 ± 0.000939172 (W 0.00210762) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07593 ± 0.00405099 (W 0.0022189) | 1.26781 ± 0.00413259 (W 0.00223544) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.61778 ± 0.00798158 (W 0.00519615) | 4.22935 ± 0.030498 (W 0.0104274) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.60881 ± 0.00985712 (W 0.00886878) | 10.0947 ± 0.048366 (W 0.0144708) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4509 ± 0.0421402 (W 0.0281506) | 33.7517 ± 0.152183 (W 0.0476472) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.087273 ± 0.0139474 (W 0.0186153) | 0.0507895 ± 0.000241537 (W 0.000687479) | 🔴 fork 1.72× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.147845 ± 0.00785878 (W 0.0153329) | 0.150111 ± 0.000776083 (W 0.00162776) | · | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.302266 ± 0.00413771 (W 0.00404917) | 0.3435 ± 0.00146058 (W 0.00244583) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.934494 ± 0.00369485 (W 0.0030096) | 1.10469 ± 0.0057523 (W 0.00356826) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.24842 ± 0.00635973 (W 0.00744086) | 2.59692 ± 0.00679355 (W 0.00327785) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.54593 ± 0.00863012 (W 0.0128764) | 8.73934 ± 0.0302874 (W 0.00999407) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0908795 ± 0.0212999 (W 0.0261035) | 0.0283125 ± 0.00128358 (W 0.000422399) | 🔴 fork 3.21× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.175427 ± 0.0268662 (W 0.0354075) | 0.083311 ± 0.00136574 (W 0.00114285) | 🔴 fork 2.11× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.209594 ± 0.0212659 (W 0.0282572) | 0.181823 ± 0.00237185 (W 0.00155941) | 🔴 fork 1.15× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.565658 ± 0.00399601 (W 0.0112923) | 0.554053 ± 0.00273928 (W 0.00248069) | · |  |
| `gemm/512x512x512/b1` | 1.19487 ± 0.00684923 (W 0.0101443) | 1.3158 ± 0.00748291 (W 0.0027073) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.94906 ± 0.0154816 (W 0.0175707) | 4.55228 ± 0.0036674 (W 0.00839533) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133835 ± 0.000443157 (W 0.00138125) | 0.162853 ± 0.000473702 (W 0.00138063) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.454614 ± 0.00243659 (W 0.00193436) | 0.53912 ± 0.00179157 (W 0.00206412) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07818 ± 0.00280801 (W 0.001137) | 1.27048 ± 0.00768694 (W 0.00226324) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.61758 ± 0.00965899 (W 0.00699089) | 4.22468 ± 0.0112351 (W 0.00925305) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.59473 ± 0.0271975 (W 0.0136462) | 10.0807 ± 0.0243834 (W 0.0162531) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4258 ± 0.0446798 (W 0.02962) | 33.7258 ± 0.076137 (W 0.0251165) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.083476 ± 0.01465 (W 0.0205994) | 0.0505895 ± 0.000380331 (W 0.00107953) | 🔴 fork 1.65× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.157177 ± 0.00671633 (W 0.0140566) | 0.149344 ± 0.000504533 (W 0.00218686) | 🔴 fork 1.05× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.300856 ± 0.00456059 (W 0.00407066) | 0.345692 ± 0.0011805 (W 0.00275055) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.932556 ± 0.0027106 (W 0.00649714) | 1.09946 ± 0.00600382 (W 0.00391868) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.24366 ± 0.00955578 (W 0.00716919) | 2.58726 ± 0.00605323 (W 0.00315337) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.53376 ± 0.0167453 (W 0.0180588) | 8.7216 ± 0.0281453 (W 0.0187032) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.084633 ± 0.019027 (W 0.0232292) | 0.028613 ± 0.00156648 (W 0.000192965) | 🔴 fork 2.96× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.172932 ± 0.0155629 (W 0.0448173) | 0.0818135 ± 0.000265989 (W 0.000334699) | 🔴 fork 2.11× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.196046 ± 0.00939107 (W 0.0381857) | 0.178756 ± 0.0016234 (W 0.00143371) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.556937 ± 0.00438247 (W 0.010727) | 0.555539 ± 0.00277874 (W 0.00261917) | · |  |
| `gemm/512x512x512/b1` | 1.18296 ± 0.00619362 (W 0.0114133) | 1.31143 ± 0.00595451 (W 0.00318683) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.94823 ± 0.0388421 (W 0.0212131) | 4.55353 ± 0.00572539 (W 0.00768428) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539458 ± 0.001827 (W 0.0020009) | 0.659631 ± 0.00135035 (W 0.00209032) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81444 ± 0.00179857 (W 0.00210221) | 2.17748 ± 0.00412755 (W 0.00225629) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28542 ± 0.00334896 (W 0.00738465) | 5.1774 ± 0.00577751 (W 0.0118366) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4548 ± 0.0294039 (W 0.0227667) | 17.3155 ± 0.0278071 (W 0.0235829) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3184 ± 0.0332037 (W 0.0359501) | 41.0067 ± 0.079718 (W 0.0268777) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.664 ± 0.183764 (W 0.0756206) | 137.475 ± 0.21514 (W 0.0738872) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.161666 ± 0.00079392 (W 0.00177263) | 0.178161 ± 0.0009487 (W 0.00115483) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.475051 ± 0.0011065 (W 0.00281523) | 0.559469 ± 0.00244846 (W 0.00167597) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.12777 ± 0.00299689 (W 0.00437607) | 1.33231 ± 0.00680132 (W 0.0016019) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.66909 ± 0.00816496 (W 0.00456187) | 4.40221 ± 0.0124609 (W 0.00512244) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.69992 ± 0.0179516 (W 0.0109054) | 10.4456 ± 0.0281052 (W 0.00678869) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.437 ± 0.0572308 (W 0.0189047) | 34.8913 ± 0.0654669 (W 0.0171302) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.115832 ± 0.00889437 (W 0.0139646) | 0.0930245 ± 0.000267167 (W 0.000284084) | 🔴 fork 1.25× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.27667 ± 0.00781823 (W 0.00994064) | 0.295293 ± 0.00108056 (W 0.00205887) | 🔵 fork 1.07× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.606316 ± 0.00555546 (W 0.0105266) | 0.68096 ± 0.00257002 (W 0.00229811) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.87628 ± 0.0112904 (W 0.00672236) | 2.19907 ± 0.00394065 (W 0.00282482) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.51263 ± 0.00598292 (W 0.0106669) | 5.26829 ± 0.0164458 (W 0.00937092) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 14.9766 ± 0.0111219 (W 0.0178985) | 17.7667 ± 0.0267558 (W 0.0196364) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539103 ± 0.000845389 (W 0.00180246) | 0.660239 ± 0.000777674 (W 0.00200515) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81516 ± 0.00164554 (W 0.00225856) | 2.17912 ± 0.00389331 (W 0.00323182) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28634 ± 0.00437048 (W 0.00747493) | 5.17971 ± 0.00745919 (W 0.0119952) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4437 ± 0.0206571 (W 0.0200041) | 17.3227 ± 0.0221475 (W 0.0257737) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3154 ± 0.0573529 (W 0.0371973) | 41.041 ± 0.0644875 (W 0.0369426) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.529 ± 0.179823 (W 0.0665446) | 137.622 ± 0.19953 (W 0.235298) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.161 ± 0.000386967 (W 0.00172434) | 0.177717 ± 0.00091821 (W 0.00186671) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.475494 ± 0.00121047 (W 0.00245653) | 0.559712 ± 0.00154324 (W 0.00228549) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.12606 ± 0.00264612 (W 0.00315331) | 1.33135 ± 0.00410921 (W 0.00235942) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.66943 ± 0.011003 (W 0.00675819) | 4.3914 ± 0.00904934 (W 0.00441978) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.69056 ± 0.0141283 (W 0.0117909) | 10.4343 ± 0.0252927 (W 0.00890104) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4225 ± 0.082309 (W 0.0205638) | 34.8555 ± 0.0558292 (W 0.0238451) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.118585 ± 0.00574831 (W 0.0149004) | 0.093329 ± 0.000354923 (W 0.00145507) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.274605 ± 0.00670151 (W 0.0117992) | 0.295306 ± 0.000469411 (W 0.00173285) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.605542 ± 0.00384483 (W 0.00807219) | 0.680504 ± 0.00220614 (W 0.00180845) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.87447 ± 0.00383181 (W 0.00695385) | 2.19676 ± 0.00501712 (W 0.00299421) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.50839 ± 0.00743955 (W 0.0099796) | 5.26337 ± 0.00876796 (W 0.00565859) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 14.9855 ± 0.0313199 (W 0.0234384) | 17.7564 ± 0.0229971 (W 0.0179171) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26937 ± 0.00268314 (W 0.00364822) | 1.64316 ± 0.00949947 (W 0.00476606) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.07129 ± 0.00906078 (W 0.00504789) | 1.45611 ± 0.00453395 (W 0.00736676) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.08978 ± 0.00521961 (W 0.00190638) | 1.36529 ± 0.0158599 (W 0.00307018) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.439728 ± 0.00397442 (W 0.0038038) | 0.498749 ± 0.0119905 (W 0.00461397) | 🔵 fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.332784 ± 0.00100691 (W 0.00400229) | 0.47712 ± 0.0045681 (W 0.0144187) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.307609 ± 0.00695058 (W 0.00909076) | 0.347677 ± 0.00173565 (W 0.00196997) | 🔵 fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.442156 ± 0.00712958 (W 0.00556687) | 0.275715 ± 0.00772433 (W 0.00385908) | 🔴 fork 1.60× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.204883 ± 0.00852077 (W 0.00323893) | 0.312521 ± 0.0017978 (W 0.00207456) | 🔵 fork 1.53× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.199818 ± 0.0139611 (W 0.0203427) | 0.179379 ± 0.000790759 (W 0.00152329) | 🔴 fork 1.11× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.04657 ± 0.00747772 (W 0.00213452) | 1.6902 ± 0.00580298 (W 0.0109051) | 🔵 fork 1.61× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.09174 ± 0.00943278 (W 0.00322545) | 1.40965 ± 0.0212586 (W 0.00767131) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.11998 ± 0.00597672 (W 0.00196988) | 1.36057 ± 0.000937536 (W 0.00378308) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.705626 ± 0.015197 (W 0.0227633) | 0.427211 ± 0.00396489 (W 0.00301464) | 🔴 fork 1.65× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.316843 ± 0.00336979 (W 0.00202936) | 0.486605 ± 0.00239945 (W 0.00217111) | 🔵 fork 1.54× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.312458 ± 0.00148514 (W 0.00420285) | 0.365589 ± 0.00206629 (W 0.00241452) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.14147 ± 0.0147215 (W 0.0236558) | 0.223221 ± 0.000729967 (W 0.00272666) | 🔴 fork 5.11× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.201421 ± 0.00343687 (W 0.00432689) | 0.321037 ± 0.00276016 (W 0.00257918) | 🔵 fork 1.59× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.178237 ± 0.00137058 (W 0.00371634) | 0.195871 ± 0.00128773 (W 0.00138096) | 🔵 fork 1.10× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.14166 ± 0.0125398 (W 0.0132249) | 6.00537 ± 0.0262344 (W 0.0121522) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.35 ± 0.0140264 (W 0.01496) | 5.77228 ± 0.0281177 (W 0.0197845) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.38577 ± 0.0190209 (W 0.0100868) | 5.42743 ± 0.0118711 (W 0.00931576) | 🔵 fork 1.24× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.6822 ± 0.00273437 (W 0.00553294) | 1.74615 ± 0.0300314 (W 0.00618654) | · |  |
| `gemm/4096x16x240/b1` | 1.20752 ± 0.00178822 (W 0.00487825) | 1.67484 ± 0.0115581 (W 0.0137233) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.15308 ± 0.00296128 (W 0.00261265) | 1.38909 ± 0.00329407 (W 0.00345122) | 🔵 fork 1.20× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.924594 ± 0.0101784 (W 0.00662036) | 0.940571 ± 0.0105512 (W 0.00576522) | · |  |
| `gemm/4096x16x240/b1` | 0.644011 ± 0.00399518 (W 0.00396689) | 1.00309 ± 0.00158532 (W 0.00519399) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.609195 ± 0.00373866 (W 0.00540834) | 0.698831 ± 0.00326148 (W 0.00287007) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.08449 ± 0.00978273 (W 0.00783678) | 5.80749 ± 0.0174378 (W 0.0144427) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.37677 ± 0.00982682 (W 0.00770247) | 5.80065 ± 0.0146556 (W 0.0157436) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.44626 ± 0.00724174 (W 0.0162889) | 5.56139 ± 0.00872852 (W 0.00833778) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.94667 ± 0.0290356 (W 0.0447265) | 1.503 ± 0.00522302 (W 0.00440398) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.20316 ± 0.00655577 (W 0.00999832) | 1.74585 ± 0.00544837 (W 0.00518925) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.20925 ± 0.0116597 (W 0.00597221) | 1.45888 ± 0.00351309 (W 0.00476256) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.52858 ± 0.0270473 (W 0.0502834) | 0.823925 ± 0.00810361 (W 0.00398341) | 🔴 fork 3.07× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.644842 ± 0.00342035 (W 0.00503237) | 1.00759 ± 0.00102432 (W 0.00481299) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.617407 ± 0.00118643 (W 0.0031174) | 0.770521 ± 0.00138518 (W 0.00193236) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12998 ± 0.00428671 (W 0.00269283) | 1.36824 ± 0.00756031 (W 0.004135) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.312975 ± 0.00185476 (W 0.00431291) | 0.365789 ± 0.000775521 (W 0.00160435) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.179761 ± 0.00179472 (W 0.00341742) | 0.196942 ± 0.00184911 (W 0.00128637) | 🔵 fork 1.10× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08343 ± 0.000956585 (W 0.00152984) | 1.36322 ± 0.00432461 (W 0.0023443) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.305804 ± 0.00626026 (W 0.0096754) | 0.347367 ± 0.00128665 (W 0.00186154) | 🔵 fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.188828 ± 0.0182929 (W 0.0186596) | 0.179106 ± 0.000481775 (W 0.00167334) | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.43837 ± 0.0103364 (W 0.0121205) | 5.57138 ± 0.00848052 (W 0.0192272) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.21054 ± 0.0135353 (W 0.00789195) | 1.45408 ± 0.00752516 (W 0.00425893) | 🔵 fork 1.20× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.613958 ± 0.00437917 (W 0.00451267) | 0.771942 ± 0.00291941 (W 0.00252452) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.36861 ± 0.00951708 (W 0.00555048) | 5.42312 ± 0.0130587 (W 0.0094884) | 🔵 fork 1.24× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.15649 ± 0.00557452 (W 0.00480017) | 1.38898 ± 0.00468462 (W 0.00343247) | 🔵 fork 1.20× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.60631 ± 0.00385462 (W 0.0056981) | 0.699593 ± 0.00215791 (W 0.00356553) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003151 ± 3.95495e-05 (W 2.69731e-05) | 0.004037 ± 4.58723e-05 (W 3.28471e-05) | 🔵 fork 1.28× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014863 ± 0.000140162 (W 4.54543e-05) | 0.018389 ± 0.000233881 (W 8.92206e-05) | 🔵 fork 1.24× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0306775 ± 0.00108265 (W 9.96735e-05) | 0.043972 ± 0.000279997 (W 0.000111768) | 🔵 fork 1.43× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113142 ± 0.000390399 (W 0.000785431) | 0.119713 ± 0.000415268 (W 0.000736466) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.485337 ± 0.000933454 (W 0.0023172) | 0.430022 ± 0.00147182 (W 0.00192894) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.15929 ± 0.00517951 (W 0.00202821) | 0.943715 ± 0.00347347 (W 0.00198904) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0121525 ± 0.000108445 (W 7.0768e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051942 ± 0.00019942 (W 0.000125408) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.146184 ± 0.00060642 (W 0.00234259) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0082355 ± 5.27159e-05 (W 3.6627e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008295 ± 8.23019e-05 (W 3.08927e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040781 ± 0.000116179 (W 0.000545121) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040751 ± 0.000243112 (W 0.000101598) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.121277 ± 0.000398759 (W 0.000848146) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.12118 ± 0.000669753 (W 0.000978807) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008947 ± 7.25948e-05 (W 5.46044e-05) | 0.009723 ± 9.57615e-05 (W 8.06088e-05) | 🔵 fork 1.09× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.032145 ± 0.000152997 (W 0.000147328) | 0.0377105 ± 0.000456278 (W 0.000138321) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.078461 ± 0.000506424 (W 0.00228355) | 0.0961245 ± 0.00111851 (W 0.00176826) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0330365 ± 0.00015849 (W 0.000127655) | 0.0319895 ± 0.00035804 (W 0.000133056) | · |  |
| `qr/n64/b1` | 0.122198 ± 0.00136596 (W 0.00133878) | 0.127733 ± 0.000619236 (W 0.00107208) | · |  |
| `qr/n96/b1` | 0.295181 ± 0.01029 (W 0.00367428) | 0.379778 ± 0.0105761 (W 0.00282317) | 🔵 fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.022166 ± 0.000101555 (W 0.000108688) | 0.017192 ± 0.000588276 (W 0.000105176) | 🔴 fork 1.29× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.089517 ± 0.000236611 (W 0.000167214) | 0.0652265 ± 0.000804698 (W 0.000184345) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.196268 ± 0.000966071 (W 0.00171346) | 0.180236 ± 0.00146099 (W 0.00151429) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0100085 ± 0.000163875 (W 6.40744e-05) | 0.010139 ± 0.000172743 (W 4.51443e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0330765 ± 5.70403e-05 (W 0.0001394) | 0.0371545 ± 0.000624378 (W 0.000138321) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0807115 ± 0.00073845 (W 0.00246766) | 0.08815 ± 0.000399941 (W 0.00015435) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183362 ± 0.0017021 (W 0.00145332) | 0.181728 ± 0.00151929 (W 0.00163155) | · |  |
| `svd_thin/n64/b1` | 0.922525 ± 0.0100583 (W 0.00301652) | 0.674443 ± 0.0116534 (W 0.00447573) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.19249 ± 0.0339948 (W 0.00659117) | 1.6151 ± 0.0107489 (W 0.00420005) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140746 ± 0.000335903 (W 0.00128183) | 0.07772 ± 0.000548465 (W 0.000115758) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.518355 ± 0.00136913 (W 0.00193338) | 0.275709 ± 0.00316515 (W 0.00170106) | 🔴 fork 1.88× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18388 ± 0.00192024 (W 0.0019725) | 0.657984 ± 0.00357609 (W 0.00237456) | 🔴 fork 1.80× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 5.19294e-06 (W 8.98089e-06) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0014625 ± 1.0469e-05 (W 6.34344e-06) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0025745 ± 7.80011e-05 (W 1.75234e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003146 ± 1.16905e-05 (W 3.18345e-05) | 0.0041025 ± 7.43478e-05 (W 3.87447e-05) | 🔵 fork 1.30× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0147525 ± 0.00140389 (W 5.06039e-05) | 0.018279 ± 0.000184583 (W 5.16409e-05) | 🔵 fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0487655 ± 0.00193509 (W 0.00302739) | 0.043617 ± 0.000829439 (W 0.000139521) | 🔴 fork 1.12× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113341 ± 0.000616342 (W 0.00169497) | 0.103748 ± 0.00020664 (W 0.000687682) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.500374 ± 0.00237236 (W 0.0028685) | 0.354635 ± 0.00118844 (W 0.00170883) | 🔴 fork 1.41× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.21381 ± 0.00697545 (W 0.0202799) | 0.758185 ± 0.00269748 (W 0.00207249) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.012108 ± 7.43974e-05 (W 6.90766e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051952 ± 0.000399921 (W 0.00125397) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.146288 ± 0.000938011 (W 0.00252225) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008391 ± 4.94385e-05 (W 5.46856e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0084655 ± 5.23211e-05 (W 3.84857e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.025102 ± 0.000316546 (W 0.00071158) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0253925 ± 0.00135022 (W 0.000818489) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.050214 ± 0.0159531 (W 0.00123748) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.049983 ± 0.000274529 (W 0.000394277) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008866 ± 9.26369e-05 (W 4.60816e-05) | 0.009754 ± 0.00020803 (W 0.000101307) | 🔵 fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.03207 ± 0.000236365 (W 0.000160791) | 0.0374645 ± 0.000465339 (W 0.000164028) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.078392 ± 0.000884079 (W 0.00221747) | 0.093254 ± 0.00379191 (W 0.00198881) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.0331315 ± 0.000200048 (W 0.00014123) | 0.0317495 ± 0.000188012 (W 9.92214e-05) | · |  |
| `qr/n64/b1` | 0.166446 ± 0.0229848 (W 0.00371064) | 0.128015 ± 0.000805675 (W 0.00171774) | 🔴 fork 1.30× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.394018 ± 0.0151367 (W 0.0222471) | 0.363107 ± 0.00353961 (W 0.00191451) | 🔴 fork 1.09× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.039855 ± 0.00455628 (W 0.000494489) | 0.0171625 ± 0.000267255 (W 0.000101683) | 🔴 fork 2.32× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.118356 ± 0.00809704 (W 0.00231039) | 0.064841 ± 0.000697482 (W 0.000204179) | 🔴 fork 1.83× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.218592 ± 0.00126452 (W 0.00234405) | 0.182971 ± 0.000935807 (W 0.00143047) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.009918 ± 4.75633e-05 (W 6.27069e-05) | 0.010089 ± 0.00012875 (W 7.89443e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033152 ± 0.000117956 (W 9.89521e-05) | 0.037665 ± 0.0003923 (W 0.000123013) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.080294 ± 0.00113738 (W 0.00139615) | 0.088425 ± 0.000581832 (W 0.00126948) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183553 ± 0.00784525 (W 0.00156366) | 0.182045 ± 0.000721595 (W 0.00151385) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.948541 ± 0.00509839 (W 0.00222803) | 0.628285 ± 0.00148293 (W 0.00198273) | 🔴 fork 1.51× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.34023 ± 0.0125942 (W 0.0164032) | 1.46716 ± 0.030456 (W 0.00241305) | 🔴 fork 1.60× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140668 ± 0.00043677 (W 0.00147898) | 0.0779955 ± 0.000636288 (W 0.000698384) | 🔴 fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.518138 ± 0.00177821 (W 0.00204678) | 0.273912 ± 0.00255956 (W 0.00209643) | 🔴 fork 1.89× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18929 ± 0.00461104 (W 0.00257258) | 0.65471 ± 0.00224683 (W 0.00174298) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000662 ± 1.60924e-05 (W 1.5788e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0015475 ± 6.78638e-05 (W 2.80915e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002595 ± 0.000106659 (W 3.02075e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0031605 ± 4.32223e-05 (W 3.17923e-05) | 0.0040675 ± 0.00011328 (W 4.79312e-05) | 🔵 fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014793 ± 8.26091e-05 (W 5.44448e-05) | 0.018109 ± 0.000506805 (W 8.37321e-05) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.055955 ± 0.00141369 (W 0.00341304) | 0.043261 ± 0.00104476 (W 0.000147929) | 🔴 fork 1.29× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112911 ± 0.000397269 (W 0.000925175) | 0.101861 ± 0.000976766 (W 0.000731475) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.510232 ± 0.00303519 (W 0.00383587) | 0.345967 ± 0.00160699 (W 0.0015471) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.24077 ± 0.0104767 (W 0.0204307) | 0.739913 ± 0.00326619 (W 0.00187074) | 🔴 fork 1.68× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.012148 ± 0.000162807 (W 6.49877e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0517115 ± 0.000217872 (W 0.000226937) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145442 ± 0.000650331 (W 0.00241745) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0084205 ± 4.33147e-05 (W 5.61049e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008471 ± 4.76095e-05 (W 5.97655e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020383 ± 0.000353078 (W 0.000848312) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020709 ± 0.000299069 (W 0.000620243) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0383565 ± 0.000612062 (W 0.00084505) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0377655 ± 0.000717268 (W 0.000666367) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.0089415 ± 8.55112e-05 (W 6.90876e-05) | 0.0098635 ± 5.05991e-05 (W 7.35424e-05) | 🔵 fork 1.10× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.03221 ± 0.000264281 (W 0.000163481) | 0.037956 ± 0.000488231 (W 0.000108128) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0785815 ± 0.00042818 (W 0.00227759) | 0.092087 ± 0.00421629 (W 0.00231951) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.0331315 ± 0.000114318 (W 0.000126025) | 0.03201 ± 0.000161895 (W 0.000122108) | · |  |
| `qr/n64/b1` | 0.165483 ± 0.00491904 (W 0.00324155) | 0.128199 ± 0.000451869 (W 0.00093966) | 🔴 fork 1.29× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.421588 ± 0.010291 (W 0.0232309) | 0.365371 ± 0.00336899 (W 0.00160501) | 🔴 fork 1.15× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.041177 ± 0.00411348 (W 0.000880948) | 0.0172125 ± 0.000241892 (W 8.66743e-05) | 🔴 fork 2.39× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.114069 ± 0.000790394 (W 0.00195668) | 0.0652165 ± 0.000463652 (W 0.000334109) | 🔴 fork 1.75× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.220356 ± 0.0106664 (W 0.00925362) | 0.182837 ± 0.00128884 (W 0.00131481) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.0099785 ± 5.32879e-05 (W 4.19257e-05) | 0.010139 ± 0.000107914 (W 7.6488e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033373 ± 0.000336432 (W 0.000333743) | 0.03748 ± 0.000432852 (W 7.94885e-05) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0804855 ± 0.00096449 (W 0.00257013) | 0.0881595 ± 0.000965639 (W 0.00143751) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.18268 ± 0.000706425 (W 0.00172284) | 0.181394 ± 0.000912598 (W 0.0013751) | · |  |
| `svd_thin/n64/b1` | 0.962761 ± 0.00174348 (W 0.00307912) | 0.632744 ± 0.00178809 (W 0.00266471) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.35574 ± 0.012371 (W 0.0156675) | 1.47319 ± 0.00432918 (W 0.00244731) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140307 ± 0.000303623 (W 0.00082379) | 0.0777655 ± 0.000637568 (W 0.000839179) | 🔴 fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.519564 ± 0.00108315 (W 0.00308095) | 0.273116 ± 0.000371172 (W 0.00158143) | 🔴 fork 1.90× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18537 ± 0.00499762 (W 0.00242463) | 0.655283 ± 0.00157971 (W 0.00168289) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0006665 ± 1.18434e-05 (W 1.44246e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0015025 ± 1.34263e-05 (W 2.23803e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002555 ± 1.41421e-05 (W 3.08365e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0030355 ± 1.8392e-05 (W 1.88288e-05) | 0.0034715 ± 4.48732e-05 (W 5.57972e-05) | 🔵 fork 1.14× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0145325 ± 0.000134794 (W 2.90921e-05) | 0.015514 ± 0.000126365 (W 7.33506e-05) | 🔵 fork 1.07× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0297855 ± 0.00106611 (W 5.07834e-05) | 0.036903 ± 0.000146361 (W 0.000156483) | 🔵 fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113423 ± 0.000471884 (W 0.000983625) | 0.119168 ± 0.00047486 (W 0.00129178) | · |  |
| `eigh/n64/b1` | 0.486134 ± 0.00206799 (W 0.00173974) | 0.427343 ± 0.00135944 (W 0.0016452) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.15989 ± 0.00519717 (W 0.00194792) | 0.934482 ± 0.00318523 (W 0.00152872) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010304 ± 4.1307e-05 (W 5.07971e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0456905 ± 0.000286965 (W 0.000222483) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131897 ± 0.000735791 (W 0.00222014) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0082755 ± 4.34235e-05 (W 5.37418e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0084155 ± 6.98868e-05 (W 5.45893e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0403205 ± 0.000176664 (W 0.000682394) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040501 ± 0.000119741 (W 0.000104186) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.123921 ± 0.00033615 (W 0.0016499) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.123345 ± 0.00035743 (W 0.00122837) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007074 ± 6.88208e-05 (W 4.18107e-05) | 0.0084305 ± 0.000101667 (W 7.25652e-05) | 🔵 fork 1.19× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0258535 ± 0.000295957 (W 0.000228431) | 0.033793 ± 0.000385327 (W 0.00015184) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0637085 ± 0.000483742 (W 0.00224434) | 0.078517 ± 0.000285469 (W 0.000215019) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.031253 ± 9.2153e-05 (W 0.000143304) | 0.030041 ± 0.000393517 (W 0.000758073) | · |  |
| `qr/n64/b1` | 0.114258 ± 0.00142649 (W 0.000788461) | 0.119703 ± 0.000437352 (W 0.00127718) | · |  |
| `qr/n96/b1` | 0.278971 ± 0.0103307 (W 0.00293056) | 0.343356 ± 0.00535581 (W 0.00250725) | 🔵 fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017663 ± 5.81091e-05 (W 0.000111339) | 0.01617 ± 0.00022554 (W 8.92328e-05) | 🔴 fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.073803 ± 0.000196021 (W 0.000223266) | 0.0614645 ± 0.000935984 (W 0.00020221) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.161768 ± 0.00143883 (W 0.00175149) | 0.170762 ± 0.00125825 (W 0.00154249) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.008 ± 0.00014773 (W 3.88187e-05) | 0.0088165 ± 5.82947e-05 (W 5.51282e-05) | 🔵 fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026209 ± 0.000134805 (W 0.000117459) | 0.0330215 ± 0.000271132 (W 0.000105891) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.066019 ± 0.000875602 (W 0.00152143) | 0.0769085 ± 0.000274896 (W 0.000145629) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.185015 ± 0.001545 (W 0.00158085) | 0.176084 ± 0.000941782 (W 0.00130383) | · |  |
| `svd_thin/n64/b1` | 0.968636 ± 0.0107038 (W 0.00249084) | 0.637098 ± 0.0113593 (W 0.00255927) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.18093 ± 0.033985 (W 0.0032856) | 1.52609 ± 0.0435566 (W 0.00283011) | 🔴 fork 1.43× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.14222 ± 0.000390774 (W 0.00123038) | 0.074063 ± 0.000241497 (W 0.000157728) | 🔴 fork 1.92× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.536652 ± 0.00116538 (W 0.00202053) | 0.27081 ± 0.00331248 (W 0.00164935) | 🔴 fork 1.98× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.1899 ± 0.00226004 (W 0.00196554) | 0.651342 ± 0.00239965 (W 0.00227532) | 🔴 fork 1.83× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000741 ± 1.05956e-05 (W 1.55086e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0016935 ± 1.94319e-05 (W 1.61447e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002876 ± 2.23644e-05 (W 1.59639e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003046 ± 0.000141064 (W 3.58129e-05) | 0.0033715 ± 3.94838e-05 (W 3.25183e-05) | 🔵 fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014447 ± 0.00141077 (W 3.52874e-05) | 0.015319 ± 0.000249656 (W 4.53648e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.047324 ± 0.00175623 (W 0.00289741) | 0.036774 ± 0.000226675 (W 0.000111733) | 🔴 fork 1.29× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113252 ± 0.000839607 (W 0.00027547) | 0.102556 ± 0.000621892 (W 0.00127083) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.50138 ± 0.00256312 (W 0.00292447) | 0.351264 ± 0.00106205 (W 0.00174603) | 🔴 fork 1.43× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.2156 ± 0.0125993 (W 0.023358) | 0.750074 ± 0.00109696 (W 0.00155371) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010204 ± 3.2744e-05 (W 6.23612e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0455055 ± 0.00029677 (W 0.000156468) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131445 ± 0.00101912 (W 0.00222209) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008225 ± 5.2967e-05 (W 3.47987e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008385 ± 4.31463e-05 (W 5.71239e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.035336 ± 0.000275899 (W 0.00228189) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0346545 ± 0.00337491 (W 0.00171287) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.059877 ± 0.000422637 (W 0.00298894) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0599065 ± 0.000942759 (W 0.00308202) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007148 ± 6.06973e-05 (W 4.83863e-05) | 0.008561 ± 8.8261e-05 (W 7.36833e-05) | 🔵 fork 1.20× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0259085 ± 0.000383214 (W 0.000162273) | 0.0335425 ± 0.000143346 (W 0.000106063) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0633435 ± 0.000466826 (W 0.000287894) | 0.077395 ± 0.000444039 (W 0.000197286) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.031229 ± 0.000163622 (W 0.000138796) | 0.029525 ± 0.000169548 (W 9.91813e-05) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.143519 ± 0.00478325 (W 0.00197724) | 0.118272 ± 0.00101029 (W 0.00173872) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.380534 ± 0.0105589 (W 0.0228939) | 0.339534 ± 0.00141085 (W 0.00154819) | 🔴 fork 1.12× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017608 ± 0.000169906 (W 9.9801e-05) | 0.0159195 ± 0.000168215 (W 9.33835e-05) | 🔴 fork 1.11× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.10417 ± 0.00861091 (W 0.00789027) | 0.060583 ± 0.0084627 (W 0.000174127) | 🔴 fork 1.72× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.198075 ± 0.0123162 (W 0.00528209) | 0.172052 ± 0.000876655 (W 0.00126347) | 🔴 fork 1.15× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.0079095 ± 2.63091e-05 (W 4.69166e-05) | 0.0087615 ± 4.63354e-05 (W 4.69938e-05) | 🔵 fork 1.11× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026109 ± 0.000154898 (W 0.000100741) | 0.033182 ± 0.000251766 (W 0.00145515) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0653465 ± 0.00124542 (W 0.00144826) | 0.076643 ± 0.000280055 (W 0.000695619) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.185566 ± 0.0082459 (W 0.00156755) | 0.173874 ± 0.000467238 (W 0.00121414) | 🔴 fork 1.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.994234 ± 0.00321257 (W 0.00201315) | 0.615159 ± 0.00253268 (W 0.0019438) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.26731 ± 0.0131497 (W 0.0187764) | 1.43483 ± 0.00219898 (W 0.00247026) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.141951 ± 0.000524624 (W 0.00123982) | 0.074023 ± 0.000548421 (W 0.000131418) | 🔴 fork 1.92× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.538419 ± 0.00129086 (W 0.00196884) | 0.267379 ± 0.000853012 (W 0.00125926) | 🔴 fork 2.01× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19387 ± 0.00581687 (W 0.00207696) | 0.652243 ± 0.00225407 (W 0.00206076) | 🔴 fork 1.83× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007415 ± 4.35507e-06 (W 1.46401e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001708 ± 2.80476e-05 (W 1.48717e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00286 ± 2.48328e-05 (W 2.26293e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0030405 ± 1.7309e-05 (W 2.03269e-05) | 0.0034115 ± 9.05332e-05 (W 4.20375e-05) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014537 ± 0.000107778 (W 5.97974e-05) | 0.015304 ± 0.000101677 (W 5.20079e-05) | 🔵 fork 1.05× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.054953 ± 0.0021163 (W 0.00334364) | 0.0367135 ± 9.1336e-05 (W 0.000129864) | 🔴 fork 1.50× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.11288 ± 0.000481058 (W 0.000314842) | 0.101039 ± 0.000955071 (W 0.00121465) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.509562 ± 0.00225345 (W 0.00443752) | 0.342178 ± 0.00179855 (W 0.00187337) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.25087 ± 0.0395539 (W 0.0205898) | 0.727915 ± 0.00253893 (W 0.00176659) | 🔴 fork 1.72× slower than `lapack-openblas` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.0102945 ± 6.65745e-05 (W 8.88918e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045405 ± 0.000397302 (W 0.000133361) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.13088 ± 0.000403666 (W 0.0027132) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.00824 ± 3.5378e-05 (W 5.12132e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0083355 ± 7.24679e-05 (W 6.5458e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.029345 ± 0.00244812 (W 0.0017431) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0292545 ± 0.00238849 (W 0.00144269) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0499085 ± 0.00313738 (W 0.00392206) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0466825 ± 0.00300616 (W 0.00387323) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.0071235 ± 6.91539e-05 (W 4.5916e-05) | 0.008576 ± 6.82947e-05 (W 8.67425e-05) | 🔵 fork 1.20× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0259185 ± 0.000177849 (W 0.000158085) | 0.0335025 ± 0.000170783 (W 0.000120178) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.063719 ± 0.000600855 (W 0.00230099) | 0.077906 ± 0.000262117 (W 0.000189979) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0312035 ± 0.000136627 (W 0.000167665) | 0.029756 ± 0.000392936 (W 0.000206019) | · |  |
| `qr/n64/b1` | 0.148693 ± 0.00446121 (W 0.00148558) | 0.11738 ± 0.000319606 (W 0.00167365) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.395923 ± 0.00601786 (W 0.0148073) | 0.341326 ± 0.0012228 (W 0.00189343) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.017663 ± 0.000141421 (W 0.000128532) | 0.016185 ± 0.000256173 (W 9.7128e-05) | 🔴 fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.093034 ± 0.00118219 (W 0.00123689) | 0.0604785 ± 0.00010975 (W 0.000250683) | 🔴 fork 1.54× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.204007 ± 0.0156737 (W 0.0129118) | 0.172287 ± 0.00124587 (W 0.00150143) | 🔴 fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007965 ± 7.39741e-05 (W 3.78122e-05) | 0.0087715 ± 8.14387e-05 (W 6.1313e-05) | 🔵 fork 1.10× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0261535 ± 0.000114631 (W 6.74609e-05) | 0.0326565 ± 0.000242269 (W 0.000104126) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0653415 ± 0.00083334 (W 0.00241189) | 0.076758 ± 0.000338281 (W 0.000156717) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.184339 ± 0.000528748 (W 0.00138488) | 0.174115 ± 0.000833408 (W 0.00134981) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 1.00265 ± 0.00340929 (W 0.003013) | 0.617637 ± 0.00212698 (W 0.00237051) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.28812 ± 0.0146922 (W 0.0239416) | 1.43906 ± 0.00199319 (W 0.00181414) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.141931 ± 0.000341998 (W 0.00135694) | 0.0743685 ± 0.000488183 (W 0.00068508) | 🔴 fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.539326 ± 0.0012431 (W 0.00264361) | 0.267328 ± 0.00108257 (W 0.00182424) | 🔴 fork 2.02× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18767 ± 0.00189818 (W 0.00195458) | 0.651434 ± 0.00156178 (W 0.0018778) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007365 ± 1.32275e-05 (W 1.77873e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0016885 ± 1.20069e-05 (W 1.4209e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0028505 ± 3.36492e-05 (W 4.55035e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052095 ± 4.31076e-05 (W 4.10907e-05) | 0.0066175 ± 0.000139522 (W 4.52483e-05) | 🔵 fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0303465 ± 8.5757e-05 (W 0.000137041) | 0.0394435 ± 0.000427247 (W 0.000161831) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.0843325 ± 0.000411172 (W 0.000178449) | 0.0957495 ± 0.000564327 (W 0.00129798) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.14202 ± 0.000419735 (W 0.0008782) | 0.151477 ± 0.000322321 (W 0.0013638) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.649853 ± 0.000778393 (W 0.00179576) | 0.657574 ± 0.00192138 (W 0.00203609) | · |  |
| `eigh/n96/b1` | 1.61542 ± 0.00420626 (W 0.00337532) | 1.63368 ± 0.00466328 (W 0.00284657) | · |  |
| `full_piv_lu/n32/b1` | 0.0178735 ± 0.000137284 (W 5.92843e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0984445 ± 0.000364626 (W 0.000342336) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.283024 ± 0.00122548 (W 0.00168261) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028163 ± 0.000134165 (W 4.28038e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028288 ± 5.07609e-05 (W 8.94332e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.159498 ± 0.000444324 (W 0.00136829) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.160029 ± 0.000748438 (W 0.000711458) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.467369 ± 0.000991541 (W 0.00067509) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.470898 ± 0.00256461 (W 0.000768003) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013756 ± 7.71848e-05 (W 9.33418e-05) | 0.013916 ± 0.00013252 (W 7.01404e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.060653 ± 0.000164208 (W 0.000284018) | 0.0675915 ± 0.000585189 (W 0.000304293) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.157891 ± 0.000613953 (W 0.0010685) | 0.181845 ± 0.00221189 (W 0.00170231) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070111 ± 0.000270228 (W 0.000788632) | 0.053956 ± 0.000156781 (W 0.000162655) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.319041 ± 0.000733649 (W 0.00171736) | 0.264114 ± 0.00162166 (W 0.0017015) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.781296 ± 0.00367334 (W 0.00214284) | 0.728854 ± 0.00481943 (W 0.00192868) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0383515 ± 0.000319563 (W 0.000177429) | 0.029931 ± 0.000197895 (W 7.32668e-05) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.179435 ± 0.00094802 (W 0.00120206) | 0.137849 ± 0.00144344 (W 0.00136059) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.431222 ± 0.00320539 (W 0.00195517) | 0.372132 ± 0.00365777 (W 0.00170513) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0151185 ± 0.000129044 (W 0.00010545) | 0.015479 ± 0.000150094 (W 5.62461e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.063103 ± 0.00035508 (W 9.47985e-05) | 0.071549 ± 0.00083616 (W 0.000326996) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.162228 ± 0.000319947 (W 0.00143993) | 0.188551 ± 0.00194199 (W 0.00188628) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.236507 ± 0.00114039 (W 0.00180214) | 0.227161 ± 0.000806109 (W 0.00168779) | · |  |
| `svd_thin/n64/b1` | 1.22653 ± 0.0035812 (W 0.00252268) | 0.962605 ± 0.00504414 (W 0.00190333) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.13628 ± 0.00524007 (W 0.00282107) | 2.64574 ± 0.115926 (W 0.00557625) | 🔴 fork 1.19× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.162378 ± 0.000426758 (W 0.000677817) | 0.103277 ± 0.00049993 (W 0.000147904) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.655838 ± 0.00165934 (W 0.00218389) | 0.408683 ± 0.00215956 (W 0.00202292) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51595 ± 0.00161949 (W 0.00249166) | 1.02142 ± 0.00126057 (W 0.00140346) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 2.13698e-05 (W 2.18921e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 2.09762e-05 (W 1.85672e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0049795 ± 2.16094e-05 (W 4.11316e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005185 ± 4.66065e-05 (W 2.71537e-05) | 0.006567 ± 0.000106708 (W 6.17159e-05) | 🔵 fork 1.27× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030036 ± 0.000182392 (W 8.71502e-05) | 0.038462 ± 0.000769512 (W 0.00058384) | 🔵 fork 1.28× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.103098 ± 0.00264358 (W 0.00273516) | 0.0968305 ± 0.000370192 (W 0.00127314) | 🔴 fork 1.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.142105 ± 0.0003666 (W 0.000885953) | 0.13616 ± 0.000281862 (W 0.000714649) | · |  |
| `eigh/n64/b1` | 0.642232 ± 0.00181806 (W 0.00296576) | 0.573166 ± 0.0018006 (W 0.00193052) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.54847 ± 0.00511188 (W 0.0118686) | 1.62243 ± 0.00359716 (W 0.00198036) | · |  |
| `full_piv_lu/n32/b1` | 0.0178585 ± 0.00135804 (W 6.91145e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097843 ± 0.00525887 (W 0.00129257) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n96/b1` | 0.283304 ± 0.011639 (W 0.00192018) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0283375 ± 4.03852e-05 (W 7.58367e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028393 ± 5.60952e-05 (W 0.000123694) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0655475 ± 0.000304238 (W 0.000639038) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0659985 ± 0.000541647 (W 0.00052522) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.15598 ± 0.00052819 (W 0.00111001) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.156644 ± 0.00175787 (W 0.00139864) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0137405 ± 9.42316e-05 (W 8.04075e-05) | 0.013881 ± 8.18545e-05 (W 5.68586e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0604075 ± 0.000300292 (W 0.000250233) | 0.0677015 ± 0.000726216 (W 0.00029963) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.158151 ± 0.000521359 (W 0.00154622) | 0.179496 ± 0.000639779 (W 0.00110319) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070226 ± 0.000281717 (W 0.00140336) | 0.0537905 ± 0.000337998 (W 0.000175033) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.299202 ± 0.00503745 (W 0.00336282) | 0.261983 ± 0.000609368 (W 0.00184775) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.697429 ± 0.03074 (W 0.00810064) | 0.930166 ± 0.00504916 (W 0.00201873) | 🔵 fork 1.33× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.052808 ± 0.000288771 (W 0.000545877) | 0.029856 ± 0.000193264 (W 8.92694e-05) | 🔴 fork 1.77× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.188153 ± 0.00481096 (W 0.00967886) | 0.137527 ± 0.00101303 (W 0.00143639) | 🔴 fork 1.37× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.378785 ± 0.00177423 (W 0.00305855) | 0.470751 ± 0.00179049 (W 0.00183414) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.015073 ± 0.000135883 (W 8.63987e-05) | 0.015534 ± 0.000118609 (W 5.26221e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.062722 ± 0.000282644 (W 0.000150936) | 0.0721895 ± 0.000500015 (W 0.00140161) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.161171 ± 0.000426681 (W 0.00166265) | 0.190225 ± 0.00181778 (W 0.00216841) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.237293 ± 0.00127187 (W 0.00218063) | 0.226153 ± 0.0010038 (W 0.00175564) | · |  |
| `svd_thin/n64/b1` | 1.20066 ± 0.00327354 (W 0.00231494) | 0.953117 ± 0.00337339 (W 0.00066782) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.99641 ± 0.0185968 (W 0.0233909) | 2.46978 ± 0.00540225 (W 0.00341148) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.162056 ± 0.000233619 (W 0.00154199) | 0.102512 ± 0.000626991 (W 0.000902406) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.651374 ± 0.00210047 (W 0.00171561) | 0.409822 ± 0.00220223 (W 0.00184688) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51439 ± 0.00363891 (W 0.00301926) | 1.28008 ± 0.00371127 (W 0.0028016) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001097 ± 7.81665e-05 (W 2.62508e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002715 ± 1.0328e-05 (W 2.31278e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004959 ± 3.42953e-05 (W 1.76309e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005195 ± 8.16833e-05 (W 4.43033e-05) | 0.0065325 ± 5.11876e-05 (W 6.87564e-05) | 🔵 fork 1.26× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030232 ± 0.000281105 (W 0.000108394) | 0.041848 ± 0.000513073 (W 0.000639327) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.112681 ± 0.000577115 (W 0.00346561) | 0.103904 ± 0.000705502 (W 0.00135662) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.141781 ± 0.000411239 (W 0.00173078) | 0.135633 ± 0.00110469 (W 0.000785125) | · |  |
| `eigh/n64/b1` | 0.646069 ± 0.00436718 (W 0.00492205) | 0.563302 ± 0.00205392 (W 0.00170624) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.53962 ± 0.00867478 (W 0.0184281) | 1.65272 ± 0.00441681 (W 0.00280366) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0178435 ± 0.000115546 (W 6.44193e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0975875 ± 0.000590139 (W 0.000596172) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.283218 ± 0.00112301 (W 0.00156677) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028328 ± 9.69201e-05 (W 5.49103e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028433 ± 9.76943e-05 (W 6.80814e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.042755 ± 0.000505155 (W 0.000617289) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0433665 ± 0.000308374 (W 0.000686242) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0923275 ± 0.000543542 (W 0.0014027) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0921125 ± 0.000544651 (W 0.00103307) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0137855 ± 9.35429e-05 (W 9.43391e-05) | 0.0138505 ± 9.98808e-05 (W 8.95977e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.060688 ± 0.000194073 (W 0.000916611) | 0.067782 ± 0.000870299 (W 0.00160833) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.157644 ± 0.000369718 (W 0.00146635) | 0.181532 ± 0.00179292 (W 0.00173131) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.069745 ± 0.000270342 (W 0.000256944) | 0.05353 ± 0.000353928 (W 0.00143696) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.311431 ± 0.0454324 (W 0.00390758) | 0.263041 ± 0.00104557 (W 0.0020119) | 🔴 fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.716193 ± 0.00766842 (W 0.0142575) | 0.990522 ± 0.0039099 (W 0.00259115) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0573065 ± 0.000710236 (W 0.000859546) | 0.029896 ± 0.000283733 (W 9.05858e-05) | 🔴 fork 1.92× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.183952 ± 0.00191672 (W 0.0034986) | 0.137542 ± 0.000477758 (W 0.00150193) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.395724 ± 0.00214136 (W 0.00339034) | 0.503362 ± 0.0025349 (W 0.00131097) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.015063 ± 0.000137478 (W 9.42539e-05) | 0.0154835 ± 5.02411e-05 (W 7.82805e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0626215 ± 0.000272673 (W 0.00014723) | 0.0715685 ± 0.000563797 (W 0.000354894) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.161191 ± 0.000608279 (W 0.00140806) | 0.188887 ± 0.000508899 (W 0.00186891) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.236212 ± 0.000404919 (W 0.00166953) | 0.226299 ± 0.000409953 (W 0.00174154) | · |  |
| `svd_thin/n64/b1` | 1.21132 ± 0.00243265 (W 0.00455346) | 0.957996 ± 0.00279617 (W 0.00137411) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.9633 ± 0.0146299 (W 0.0195698) | 2.55782 ± 0.00447596 (W 0.00705089) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.162569 ± 0.000599518 (W 0.0014178) | 0.102952 ± 0.000265203 (W 0.001385) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.65174 ± 0.00110213 (W 0.00214244) | 0.411122 ± 0.00217697 (W 0.00199951) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.513 ± 0.00448758 (W 0.00222831) | 1.37723 ± 0.00317923 (W 0.0053538) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 2.41695e-05 (W 1.85841e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0027 ± 2.54067e-05 (W 1.73308e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004949 ± 5.90446e-05 (W 2.20778e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0051695 ± 5.99914e-05 (W 3.59923e-05) | 0.005836 ± 8.47742e-05 (W 6.03557e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0298605 ± 0.000136094 (W 9.7401e-05) | 0.031904 ± 0.000124452 (W 7.79321e-05) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.0832805 ± 0.000265825 (W 0.000183363) | 0.086627 ± 0.000188942 (W 0.00149282) | · |  |
| `eigh/n32/b1` | 0.142065 ± 0.000364015 (W 0.000206948) | 0.150552 ± 0.0004427 (W 0.000700184) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.649606 ± 0.00076862 (W 0.00172426) | 0.649962 ± 0.00212975 (W 0.00217465) | · |  |
| `eigh/n96/b1` | 1.62113 ± 0.00316147 (W 0.00254253) | 1.62112 ± 0.00188697 (W 0.0022191) | · |  |
| `full_piv_lu/n32/b1` | 0.0158595 ± 0.000101992 (W 8.01194e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0906345 ± 0.000260302 (W 0.000787548) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.266773 ± 0.0010309 (W 0.00182398) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027967 ± 0.000116271 (W 7.22234e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028127 ± 0.000138664 (W 7.04971e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.158176 ± 0.000563285 (W 0.00145262) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158135 ± 0.000521236 (W 0.000436291) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.461873 ± 0.00208852 (W 0.000552899) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.462792 ± 0.00225937 (W 0.000771594) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011947 ± 0.000123618 (W 6.0696e-05) | 0.012814 ± 4.21505e-05 (W 8.04753e-05) | 🔵 fork 1.07× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0533745 ± 0.000210037 (W 0.000129465) | 0.0602275 ± 0.000305876 (W 0.000120963) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.141905 ± 0.000413231 (W 0.00152498) | 0.164447 ± 0.000447046 (W 0.00136518) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0682275 ± 0.000184394 (W 0.00136397) | 0.0516515 ± 0.00026069 (W 0.000300918) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.312184 ± 0.000681025 (W 0.00203228) | 0.251709 ± 0.00190214 (W 0.00152667) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.76488 ± 0.00332831 (W 0.0025279) | 0.697777 ± 0.00144539 (W 0.00210378) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0335475 ± 0.000193619 (W 0.000242116) | 0.028889 ± 0.000328883 (W 0.000128445) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.161947 ± 0.000675152 (W 0.00107371) | 0.130999 ± 0.00120345 (W 0.000331708) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.392544 ± 0.000580972 (W 0.00186666) | 0.354789 ± 0.00150979 (W 0.0019296) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0130845 ± 9.4722e-05 (W 9.65289e-05) | 0.0141165 ± 7.54427e-05 (W 7.7236e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0555935 ± 0.000345004 (W 0.000120664) | 0.0643505 ± 0.000363129 (W 9.30249e-05) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.145668 ± 0.000299442 (W 0.00140094) | 0.172707 ± 0.000324759 (W 0.00158942) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.233487 ± 0.00164125 (W 0.00153765) | 0.226328 ± 0.00104714 (W 0.00180865) | · |  |
| `svd_thin/n64/b1` | 1.25938 ± 0.0033715 (W 0.00300362) | 0.939605 ± 0.00247122 (W 0.00150514) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.10138 ± 0.0025686 (W 0.00497093) | 2.51599 ± 0.00982239 (W 0.00243861) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.16041 ± 0.00022763 (W 0.00142449) | 0.103608 ± 0.000385952 (W 0.0015204) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.629547 ± 0.00095881 (W 0.00178092) | 0.400628 ± 0.000702784 (W 0.00180377) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.48849 ± 0.00430367 (W 0.00284117) | 1.01176 ± 0.01027 (W 0.000910685) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001183 ± 1.96036e-05 (W 1.45944e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002811 ± 2.05977e-05 (W 1.1608e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0054805 ± 0.00041276 (W 1.56498e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0051445 ± 6.6455e-05 (W 3.93037e-05) | 0.0058255 ± 4.26165e-05 (W 5.7315e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029906 ± 0.000176833 (W 6.60698e-05) | 0.0331215 ± 0.000369796 (W 0.00028919) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.102602 ± 0.00349939 (W 0.00179894) | 0.08849 ± 0.00102128 (W 0.00112461) | 🔴 fork 1.16× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.142391 ± 0.000483464 (W 0.00168759) | 0.134841 ± 0.000223144 (W 0.000719515) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.64183 ± 0.00203925 (W 0.00295012) | 0.566225 ± 0.00255405 (W 0.00179456) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.54496 ± 0.00460277 (W 0.0141637) | 1.60762 ± 0.00457314 (W 0.00225159) | · |  |
| `full_piv_lu/n32/b1` | 0.0157045 ± 0.00150252 (W 8.43293e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.091145 ± 0.00537269 (W 0.000235574) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n96/b1` | 0.266925 ± 0.0114812 (W 0.00151714) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027927 ± 5.53919e-05 (W 9.59809e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0280775 ± 0.000144701 (W 4.06976e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0762325 ± 0.00377549 (W 0.00336969) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.073101 ± 0.00400417 (W 0.00120018) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.164307 ± 0.00170148 (W 0.00327373) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.164606 ± 0.00231289 (W 0.00317116) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011817 ± 9.7707e-05 (W 4.96064e-05) | 0.0127635 ± 0.000133552 (W 8.55448e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0531485 ± 0.000182293 (W 0.000107406) | 0.060162 ± 0.000166645 (W 0.000140714) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.14191 ± 0.000319516 (W 0.00109896) | 0.164196 ± 0.000388352 (W 0.000935374) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0682475 ± 0.000237531 (W 0.00140488) | 0.051421 ± 0.000177203 (W 0.000324034) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.300141 ± 0.00681984 (W 0.00415774) | 0.248152 ± 0.00210326 (W 0.00152227) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.685403 ± 0.0353972 (W 0.0124059) | 0.892758 ± 0.00422914 (W 0.00242827) | 🔵 fork 1.30× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0339135 ± 0.00019417 (W 0.000212575) | 0.028653 ± 5.8847e-05 (W 8.94933e-05) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.156968 ± 0.00873459 (W 0.00225114) | 0.129983 ± 0.00135003 (W 0.00158276) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.337508 ± 0.00396518 (W 0.00496644) | 0.453741 ± 0.00181654 (W 0.00158872) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0130745 ± 5.86984e-05 (W 0.000102161) | 0.0141115 ± 8.00392e-05 (W 6.1422e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0553285 ± 0.000172332 (W 0.000194916) | 0.0642145 ± 0.000195587 (W 0.000136441) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.144906 ± 0.000637406 (W 0.0011643) | 0.172632 ± 0.000275655 (W 0.00129161) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.234538 ± 0.001607 (W 0.00133656) | 0.225156 ± 0.000845725 (W 0.00146691) | · |  |
| `svd_thin/n64/b1` | 1.23174 ± 0.00270146 (W 0.00281456) | 0.934027 ± 0.00161054 (W 0.00133341) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.93761 ± 0.0189176 (W 0.0226988) | 2.43303 ± 0.00558596 (W 0.00412261) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.160129 ± 0.000266613 (W 0.00129029) | 0.102802 ± 0.000357207 (W 0.0013777) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.626603 ± 0.000680778 (W 0.00197769) | 0.401093 ± 0.00196916 (W 0.00182249) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.48791 ± 0.00258699 (W 0.00257046) | 1.26558 ± 0.00169411 (W 0.00263866) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001187 ± 8.33667e-06 (W 1.89072e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002815 ± 7.31437e-06 (W 1.77414e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004979 ± 0.000359258 (W 1.66936e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005134 ± 8.35163e-05 (W 3.49736e-05) | 0.005856 ± 7.94984e-05 (W 6.5298e-05) | 🔵 fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029831 ± 0.000143663 (W 0.00086831) | 0.03728 ± 0.000417724 (W 0.000869103) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.111368 ± 0.000649741 (W 0.00312952) | 0.095023 ± 0.00114175 (W 0.00135616) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.14195 ± 0.000251662 (W 0.00164241) | 0.134445 ± 0.00121545 (W 0.00129345) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.646274 ± 0.00239777 (W 0.00466325) | 0.556266 ± 0.00231628 (W 0.00216367) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.54566 ± 0.00794604 (W 0.0168926) | 1.63684 ± 0.00477876 (W 0.00270194) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0158095 ± 0.00016781 (W 4.65186e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090724 ± 0.0003271 (W 0.000309713) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.266246 ± 0.000512401 (W 0.00169902) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027917 ± 0.000131773 (W 0.000699617) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028093 ± 0.000160238 (W 9.04738e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0515315 ± 0.000745198 (W 0.00189235) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.051982 ± 0.00291493 (W 0.0016252) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.106845 ± 0.00222249 (W 0.00378714) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.101369 ± 0.00183289 (W 0.00405242) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.011822 ± 0.000115552 (W 5.29538e-05) | 0.012734 ± 6.61133e-05 (W 5.89744e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0535 ± 0.000671464 (W 0.000216636) | 0.0601665 ± 0.00022402 (W 0.000172419) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.141129 ± 0.000205409 (W 0.00143445) | 0.164297 ± 0.000596239 (W 0.00125739) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0682575 ± 0.000470813 (W 0.000337464) | 0.0514155 ± 0.000187163 (W 0.000225946) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.312812 ± 0.00299542 (W 0.00574677) | 0.248719 ± 0.00161293 (W 0.00180268) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.693142 ± 0.0090565 (W 0.0185993) | 0.950044 ± 0.00277718 (W 0.00295509) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.033573 ± 0.000210614 (W 0.000205175) | 0.028924 ± 0.000440286 (W 0.000116446) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.166316 ± 0.00224849 (W 0.00397648) | 0.130843 ± 0.000905103 (W 0.00158302) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.357148 ± 0.0123447 (W 0.00842897) | 0.485419 ± 0.00183251 (W 0.00174518) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.012959 ± 0.000105198 (W 8.93475e-05) | 0.014031 ± 8.57448e-05 (W 5.63933e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055393 ± 0.000295932 (W 0.000197058) | 0.0642 ± 0.000147739 (W 0.00016946) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.144975 ± 0.000626799 (W 0.00141357) | 0.172192 ± 0.000625237 (W 0.00161606) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.234211 ± 0.00130514 (W 0.00172308) | 0.225466 ± 0.000639022 (W 0.00159675) | · |  |
| `svd_thin/n64/b1` | 1.24226 ± 0.00229097 (W 0.00399346) | 0.934822 ± 0.00341948 (W 0.00176024) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.93272 ± 0.0100317 (W 0.0220305) | 2.51851 ± 0.00495649 (W 0.00589255) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.160349 ± 0.000813669 (W 0.00140184) | 0.102762 ± 0.000518209 (W 0.000823768) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.627632 ± 0.00104834 (W 0.00164272) | 0.401395 ± 0.00127001 (W 0.00189853) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.48677 ± 0.00590417 (W 0.00212638) | 1.35957 ± 0.00230506 (W 0.00364852) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0011825 ± 1.26596e-05 (W 1.45037e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0028105 ± 1.62162e-05 (W 1.44389e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0051745 ± 0.000231966 (W 1.74935e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.066394 ± 0.00238041 (W 0.000401053) | 0.158274 ± 0.00287417 (W 0.00227536) | 🔵 fork 2.38× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.387213 ± 0.00513156 (W 0.00211828) | 1.00453 ± 0.00673333 (W 0.00666757) | 🔵 fork 2.59× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.52023 ± 0.0393322 (W 0.00688272) | 5.91131 ± 0.0114705 (W 0.018957) | 🔵 fork 2.35× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.25792 ± 0.00601598 (W 0.00404725) | 1.8696 ± 0.00490994 (W 0.0106773) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.83314 ± 0.0308626 (W 0.0149726) | 9.13427 ± 0.00784863 (W 0.0189784) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 49.1879 ± 0.183249 (W 0.094128) | 51.8869 ± 0.344649 (W 0.0521941) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.313611 ± 0.000729977 (W 0.00182708) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71327 ± 0.0122491 (W 0.00910662) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.8697 ± 0.189963 (W 0.0421145) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.258858 ± 0.000715012 (W 0.00199964) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.259273 ± 0.00105207 (W 0.00205592) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90104 ± 0.00398943 (W 0.00278697) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.90905 ± 0.00235428 (W 0.0046847) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 16.0403 ± 0.0422703 (W 0.0434189) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9305 ± 0.045612 (W 0.0533951) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.168365 ± 0.00231784 (W 0.00165291) | 0.207694 ± 0.00353234 (W 0.00377626) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 1.00322 ± 0.00423435 (W 0.00277478) | 1.36294 ± 0.00537195 (W 0.0063772) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 6.67769 ± 0.0266378 (W 0.00913865) | 8.18191 ± 0.0300717 (W 0.0270969) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.517699 ± 0.0025419 (W 0.0024666) | 0.860216 ± 0.00420735 (W 0.00469438) | 🔵 fork 1.66× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.91818 ± 0.00363336 (W 0.00608477) | 4.36958 ± 0.0189082 (W 0.0105511) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 20.2747 ± 0.0272327 (W 0.0281102) | 30.7172 ± 0.0378497 (W 0.0585489) | 🔵 fork 1.52× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.338131 ± 0.00168261 (W 0.00179427) | 0.433524 ± 0.00611746 (W 0.00373747) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.62988 ± 0.00793243 (W 0.00273968) | 2.16843 ± 0.00807087 (W 0.00604865) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.96122 ± 0.0155918 (W 0.0185246) | 14.4535 ± 0.037909 (W 0.0279658) | 🔵 fork 1.61× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.137351 ± 0.000935309 (W 0.00143317) | 0.206011 ± 0.00291888 (W 0.00430729) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.772234 ± 0.00247597 (W 0.00272528) | 1.12804 ± 0.00371902 (W 0.00416807) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.61562 ± 0.0185106 (W 0.0206556) | 7.08075 ± 0.041047 (W 0.0113243) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.68486 ± 0.010818 (W 0.00534649) | 3.14548 ± 0.00576049 (W 0.0120789) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.4734 ± 0.0438942 (W 0.0295111) | 17.6268 ± 0.0717004 (W 0.0275982) | · |  |
| `svd_thin/n512/b1` | 105.76 ± 0.0978371 (W 0.0739278) | 123.519 ± 2.08202 (W 0.292698) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.68686 ± 0.00820258 (W 0.00428633) | 1.35238 ± 0.00561641 (W 0.00553062) | 🔴 fork 1.99× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.4814 ± 0.0291233 (W 0.0152009) | 7.91415 ± 0.0217826 (W 0.0186915) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 66.6349 ± 0.241984 (W 0.0702454) | 55.4649 ± 0.927567 (W 0.189217) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004043 ± 8.26013e-05 (W 7.24776e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0106695 ± 0.0011571 (W 7.45561e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.036293 ± 0.00453449 (W 0.000986512) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.085214 ± 0.000706422 (W 0.00171051) | 0.168874 ± 0.00339823 (W 0.00288205) | 🔵 fork 1.98× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.388665 ± 0.0101725 (W 0.0244531) | 0.848706 ± 0.00416579 (W 0.00545861) | 🔵 fork 2.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.57661 ± 0.0120578 (W 0.0249663) | 4.60773 ± 0.042285 (W 0.0216975) | 🔵 fork 2.92× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.28781 ± 0.0204196 (W 0.0209675) | 1.49568 ± 0.0032562 (W 0.00355986) | 🔴 fork 1.53× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 7.01048 ± 0.0502447 (W 0.0421403) | 6.0896 ± 0.0206755 (W 0.00976675) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 26.5019 ± 0.153379 (W 0.075885) | 28.9895 ± 0.263783 (W 0.0512941) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.31342 ± 0.001621 (W 0.00207008) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.72522 ± 0.00781391 (W 0.0073248) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.6086 ± 0.199574 (W 0.0740928) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0858405 ± 0.000693574 (W 0.000956344) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0869065 ± 0.000575122 (W 0.00107941) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.524859 ± 0.00172626 (W 0.00312206) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.532529 ± 0.00128247 (W 0.00315755) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.17419 ± 0.0122369 (W 0.0177685) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.20531 ± 0.0149148 (W 0.0187547) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.16909 ± 0.00135447 (W 0.00146706) | 0.204296 ± 0.00374234 (W 0.00484158) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 1.01306 ± 0.00816968 (W 0.00922238) | 1.05014 ± 0.00464188 (W 0.00367262) | · |  |
| `lu/n512/b1` | 4.884 ± 0.04253 (W 0.0945805) | 5.69027 ± 0.0813482 (W 0.0170058) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.617974 ± 0.0214867 (W 0.029339) | 0.892512 ± 0.008209 (W 0.00642191) | 🔵 fork 1.44× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.02089 ± 0.0170144 (W 0.0243736) | 3.5443 ± 0.00929893 (W 0.00713337) | 🔵 fork 1.75× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 10.3343 ± 0.0387472 (W 0.0799916) | 19.2337 ± 0.19409 (W 0.0214981) | 🔵 fork 1.86× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.411304 ± 0.0233804 (W 0.0145185) | 0.446103 ± 0.00590454 (W 0.00473253) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.45495 ± 0.0228798 (W 0.0187904) | 1.75959 ± 0.00324616 (W 0.00415548) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 5.2365 ± 0.0239434 (W 0.0270351) | 9.45177 ± 0.0760443 (W 0.0238266) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.138378 ± 0.000861121 (W 0.0013461) | 0.173789 ± 0.00363814 (W 0.00352956) | 🔵 fork 1.26× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.777124 ± 0.00376028 (W 0.00266422) | 0.794483 ± 0.00396917 (W 0.00299034) | · |  |
| `solve/n512/b1` | 4.81151 ± 0.0457046 (W 0.0746523) | 4.52178 ± 0.106419 (W 0.00676923) | 🔴 fork 1.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.04044 ± 0.0176005 (W 0.0279006) | 3.07697 ± 0.00597534 (W 0.00424701) | · |  |
| `svd_thin/n256/b1` | 13.702 ± 0.0318076 (W 0.058745) | 15.0094 ± 0.161237 (W 0.0149869) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 62.2686 ± 0.325794 (W 0.270114) | 94.3961 ± 2.36648 (W 0.408399) | 🔵 fork 1.52× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22927 ± 0.0118078 (W 0.00561596) | 1.39075 ± 0.00895867 (W 0.00561708) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.8335 ± 0.0400136 (W 0.0211517) | 7.71503 ± 0.0223137 (W 0.0102782) | 🔴 fork 1.40× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 48.6086 ± 0.217735 (W 0.379152) | 50.0238 ± 0.28807 (W 0.0409211) | · |  |
| `triangular_solve/n128/b1` | 0.0039225 ± 0.000336988 (W 5.72737e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.01103 ± 6.53322e-05 (W 4.96164e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.037791 ± 0.00415481 (W 0.00190451) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089878 ± 0.00224429 (W 0.00280445) | 0.164983 ± 0.0013593 (W 0.00293643) | 🔵 fork 1.84× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.412968 ± 0.0109198 (W 0.0206386) | 0.852961 ± 0.00471117 (W 0.00772779) | 🔵 fork 2.07× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.56339 ± 0.0379162 (W 0.0208348) | 4.44405 ± 0.0508617 (W 0.032334) | 🔵 fork 2.84× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.38502 ± 0.0226522 (W 0.0319092) | 1.43607 ± 0.00200461 (W 0.00393648) | 🔴 fork 1.66× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.91831 ± 0.0303279 (W 0.0329548) | 5.75491 ± 0.0288971 (W 0.00597177) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 24.3402 ± 0.145369 (W 0.0960083) | 25.3902 ± 0.631912 (W 0.0504957) | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.31334 ± 0.00113121 (W 0.00229423) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71035 ± 0.0171807 (W 0.0102472) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4037 ± 0.179715 (W 0.15958) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0594105 ± 0.000922155 (W 0.00074503) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.061179 ± 0.00121878 (W 0.00109943) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.285966 ± 0.00109933 (W 0.00285827) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.293354 ± 0.00205913 (W 0.00303594) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.26115 ± 0.00892577 (W 0.0157973) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.28167 ± 0.0155136 (W 0.0101284) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.169891 ± 0.000933348 (W 0.00239912) | 0.206972 ± 0.00322743 (W 0.00501557) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 1.0231 ± 0.01636 (W 0.0150686) | 0.977572 ± 0.00754858 (W 0.00430296) | · |  |
| `lu/n512/b1` | 4.75224 ± 0.0537805 (W 0.0380566) | 4.75711 ± 0.0839598 (W 0.0141424) | · | `!` between-start range over 5% |
| `qr/n128/b1` | 0.600958 ± 0.0115822 (W 0.0183333) | 0.894921 ± 0.00390159 (W 0.00557292) | 🔵 fork 1.49× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.83723 ± 0.00820807 (W 0.0155853) | 3.53114 ± 0.00805552 (W 0.0084646) | 🔵 fork 1.92× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 9.00716 ± 0.0468548 (W 0.0538445) | 17.996 ± 1.37454 (W 0.0461289) | 🔵 fork 2.00× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.363208 ± 0.0175758 (W 0.00929491) | 0.443131 ± 0.00488119 (W 0.00542971) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.41431 ± 0.00947509 (W 0.0111692) | 1.73981 ± 0.00962087 (W 0.00512075) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.88059 ± 0.0702015 (W 0.0469125) | 8.68212 ± 0.343919 (W 0.0109156) | 🔵 fork 1.78× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.138243 ± 0.000912013 (W 0.00148488) | 0.207477 ± 0.0031705 (W 0.00480898) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.787116 ± 0.00440024 (W 0.00380398) | 0.74746 ± 0.00682135 (W 0.00408137) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 4.68197 ± 0.117459 (W 0.0905466) | 3.69875 ± 0.0267234 (W 0.00910174) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.05782 ± 0.00886144 (W 0.0114068) | 3.06428 ± 0.00569798 (W 0.0117378) | · |  |
| `svd_thin/n256/b1` | 13.5014 ± 0.0444574 (W 0.0439613) | 14.6761 ± 0.0347414 (W 0.0235193) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 60.0731 ± 0.280344 (W 0.420555) | 92.0141 ± 1.88845 (W 0.274547) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.23178 ± 0.0305543 (W 0.00445992) | 1.38957 ± 0.00421943 (W 0.00748179) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 11.0039 ± 0.0275322 (W 0.0174638) | 7.57201 ± 0.0156656 (W 0.0107229) | 🔴 fork 1.45× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 49.9079 ± 0.384632 (W 0.526855) | 50.0691 ± 0.634376 (W 0.342991) | · |  |
| `triangular_solve/n128/b1` | 0.003922 ± 2.9262e-05 (W 6.40436e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0098585 ± 0.000670603 (W 9.1383e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.038993 ± 0.00264659 (W 0.00106616) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.059837 ± 0.00247372 (W 0.000106821) | 0.0715685 ± 0.000337361 (W 0.000180536) | 🔵 fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.315245 ± 0.00179456 (W 0.00215354) | 0.408662 ± 0.00175511 (W 0.00195613) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.05566 ± 0.0044369 (W 0.00261389) | 2.70484 ± 0.0156103 (W 0.00940626) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.24916 ± 0.00641787 (W 0.00235492) | 1.79152 ± 0.00684432 (W 0.00675686) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.78656 ± 0.0209209 (W 0.0206451) | 8.70437 ± 0.0143911 (W 0.0186483) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 48.8107 ± 0.216616 (W 0.0513309) | 49.5214 ± 0.127914 (W 0.0669433) | · |  |
| `full_piv_lu/n128/b1` | 0.289776 ± 0.00165598 (W 0.00181605) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61574 ± 0.00419587 (W 0.00788372) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.208 ± 0.22687 (W 0.03981) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.253594 ± 0.000977528 (W 0.00186278) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.254516 ± 0.000968452 (W 0.00196556) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.87305 ± 0.00950895 (W 0.00754484) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.87892 ± 0.00595169 (W 0.00415435) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8605 ± 0.103568 (W 0.0357144) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7444 ± 0.0456752 (W 0.0563637) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.129858 ± 0.01789 (W 0.00160295) | 0.153577 ± 0.000670884 (W 0.00146023) | 🔵 fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.894531 ± 0.00438838 (W 0.00432937) | 0.83894 ± 0.00214813 (W 0.00103365) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.12962 ± 0.0262841 (W 0.0196364) | 5.17018 ± 0.0290299 (W 0.00734302) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.488916 ± 0.00228611 (W 0.00212846) | 0.775559 ± 0.0197332 (W 0.00604568) | 🔵 fork 1.59× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.79174 ± 0.00643192 (W 0.0035631) | 4.06362 ± 0.0404613 (W 0.0094677) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.6561 ± 0.108129 (W 0.0299513) | 27.0917 ± 0.108264 (W 0.0332855) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.276052 ± 0.00234897 (W 0.00131755) | 0.374484 ± 0.00201411 (W 0.0021739) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.37237 ± 0.00571137 (W 0.00253658) | 1.8753 ± 0.0105937 (W 0.00381584) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 7.96726 ± 0.0153547 (W 0.0134666) | 12.4507 ± 0.0557361 (W 0.0230894) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111037 ± 0.00162947 (W 0.000900592) | 0.149193 ± 0.000463767 (W 0.00161438) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.666734 ± 0.00287113 (W 0.00263371) | 0.826358 ± 0.00426433 (W 0.00247355) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.06008 ± 0.0123895 (W 0.0198486) | 5.12195 ± 0.0137945 (W 0.0126833) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.69062 ± 0.0128256 (W 0.00462908) | 3.01736 ± 0.0129188 (W 0.00961061) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.3731 ± 0.0399587 (W 0.0283955) | 16.9608 ± 0.0387152 (W 0.0251208) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 104.979 ± 0.178348 (W 0.118455) | 117.365 ± 0.652522 (W 0.232924) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.61296 ± 0.0111342 (W 0.00801188) | 1.29 ± 0.00625309 (W 0.00296953) | 🔴 fork 2.03× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.2973 ± 0.0332399 (W 0.0262606) | 7.63122 ± 0.0205678 (W 0.0141998) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.6743 ± 0.336814 (W 0.0503088) | 53.0185 ± 0.456374 (W 0.122373) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004348 ± 0.000168678 (W 3.77842e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0117065 ± 0.00180441 (W 6.97016e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0414625 ± 0.0039778 (W 0.000204815) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.078336 ± 0.000455683 (W 0.00126296) | 0.078106 ± 0.00262235 (W 0.00198478) | · | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.331839 ± 0.0103431 (W 0.0229767) | 0.289825 ± 0.00473911 (W 0.00821719) | 🔴 fork 1.14× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.13878 ± 0.0154023 (W 0.0171883) | 1.32561 ± 0.0167476 (W 0.00463845) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.30161 ± 0.0232723 (W 0.0212532) | 1.42314 ± 0.00197396 (W 0.00433854) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.93505 ± 0.0907218 (W 0.0437508) | 5.64787 ± 0.013572 (W 0.0100149) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 26.061 ± 0.231602 (W 0.0476029) | 26.236 ± 0.17528 (W 0.027594) | · |  |
| `full_piv_lu/n128/b1` | 0.289034 ± 0.00211931 (W 0.00241195) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62131 ± 0.00841956 (W 0.00871976) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.0236 ± 0.108918 (W 0.133158) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0948965 ± 0.000360811 (W 0.00235276) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0966405 ± 0.00118098 (W 0.001817) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.526126 ± 0.00448584 (W 0.00500079) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.53112 ± 0.00820055 (W 0.00574259) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.11598 ± 0.0210058 (W 0.0120318) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.19276 ± 0.0164531 (W 0.0145597) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.130468 ± 0.0181231 (W 0.00111336) | 0.152549 ± 0.00102115 (W 0.000736186) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.913122 ± 0.00895075 (W 0.00527427) | 0.509618 ± 0.0152288 (W 0.0031935) | 🔴 fork 1.79× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 4.3425 ± 0.0672772 (W 0.0870851) | 2.64038 ± 0.0468901 (W 0.00542443) | 🔴 fork 1.64× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.586084 ± 0.0212058 (W 0.0357976) | 0.786548 ± 0.00427237 (W 0.00654297) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.91289 ± 0.00939507 (W 0.0225019) | 3.24804 ± 0.0306019 (W 0.00614838) | 🔵 fork 1.70× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 9.72506 ± 0.0532688 (W 0.10108) | 17.0168 ± 0.256017 (W 0.0519425) | 🔵 fork 1.75× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.346572 ± 0.025792 (W 0.0171461) | 0.394574 ± 0.00290759 (W 0.00158841) | 🔵 fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.34787 ± 0.026463 (W 0.0278261) | 1.45442 ± 0.0128281 (W 0.00442306) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n512/b1` | 4.86024 ± 0.0599476 (W 0.0726049) | 7.66401 ± 0.0836301 (W 0.0140367) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.112028 ± 0.000520905 (W 0.00139489) | 0.117255 ± 0.00115546 (W 0.00104824) | · |  |
| `solve/n256/b1` | 0.672222 ± 0.00506969 (W 0.00372971) | 0.49026 ± 0.00998667 (W 0.00274202) | 🔴 fork 1.37× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.19867 ± 0.0315762 (W 0.068129) | 2.58053 ± 0.0620506 (W 0.00318896) | 🔴 fork 1.63× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.03038 ± 0.0166378 (W 0.0292947) | 2.93541 ± 0.0132623 (W 0.00528594) | · |  |
| `svd_thin/n256/b1` | 13.6146 ± 0.0626659 (W 0.0873197) | 14.1705 ± 0.154026 (W 0.0126137) | · |  |
| `svd_thin/n512/b1` | 60.982 ± 0.172331 (W 0.26808) | 85.5108 ± 0.836416 (W 0.125068) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.16517 ± 0.015522 (W 0.00436263) | 1.3311 ± 0.00494831 (W 0.00263124) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.6647 ± 0.0330221 (W 0.0247092) | 7.31416 ± 0.0290769 (W 0.00782108) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 47.2936 ± 0.336503 (W 0.380514) | 48.4998 ± 0.496946 (W 0.037693) | · |  |
| `triangular_solve/n128/b1` | 0.0043835 ± 0.000150878 (W 4.26408e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012819 ± 0.000302267 (W 5.45441e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0427845 ± 0.00198922 (W 0.000864566) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.082809 ± 0.00219782 (W 0.00320024) | 0.075656 ± 0.000642828 (W 0.000757906) | 🔴 fork 1.09× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.338502 ± 0.0118263 (W 0.0201333) | 0.279521 ± 0.000941992 (W 0.00169413) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.07708 ± 0.01223 (W 0.0324414) | 1.21039 ± 0.00867235 (W 0.00602988) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.3845 ± 0.0433201 (W 0.0373557) | 1.36156 ± 0.00376597 (W 0.00344809) | 🔴 fork 1.75× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.86386 ± 0.0366304 (W 0.0369968) | 5.29486 ± 0.0148327 (W 0.00887698) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 23.8854 ± 0.076311 (W 0.0544276) | 22.7537 ± 0.217884 (W 0.0263817) | · |  |
| `full_piv_lu/n128/b1` | 0.28792 ± 0.00112624 (W 0.00155605) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62045 ± 0.00731096 (W 0.00715908) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.7996 ± 0.0850376 (W 0.178509) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.06989 ± 0.00124897 (W 0.00222367) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.070466 ± 0.00122339 (W 0.000844116) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.296156 ± 0.00181274 (W 0.00130997) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.299836 ± 0.00207077 (W 0.00248823) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.24086 ± 0.0150317 (W 0.011396) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.25 ± 0.848505 (W 0.0102724) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.130196 ± 0.0162073 (W 0.0012363) | 0.151833 ± 0.000668809 (W 0.00153628) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.909004 ± 0.00393943 (W 0.00258164) | 0.443356 ± 0.0131592 (W 0.00245585) | 🔴 fork 2.05× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 4.14132 ± 0.0419772 (W 0.0776371) | 1.8804 ± 0.0523014 (W 0.00788699) | 🔴 fork 2.20× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.56222 ± 0.0117895 (W 0.00988282) | 0.781683 ± 0.00552294 (W 0.00315624) | 🔵 fork 1.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.72656 ± 0.0118989 (W 0.0117212) | 3.2123 ± 0.0253962 (W 0.00755592) | 🔵 fork 1.86× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.33617 ± 0.0450028 (W 0.0761907) | 15.3478 ± 0.131562 (W 0.0692505) | 🔵 fork 1.84× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.327828 ± 0.0109007 (W 0.00792869) | 0.39068 ± 0.032126 (W 0.00183477) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.31813 ± 0.00872542 (W 0.0225747) | 1.4333 ± 0.00508085 (W 0.00520855) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.56039 ± 0.0262592 (W 0.0245542) | 6.81291 ± 0.138095 (W 0.0168414) | 🔵 fork 1.49× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111827 ± 0.000597581 (W 0.00155696) | 0.149543 ± 0.000897631 (W 0.00137053) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.682509 ± 0.00348224 (W 0.00356592) | 0.45057 ± 0.0106909 (W 0.00312428) | 🔴 fork 1.51× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.07967 ± 0.0413134 (W 0.0530243) | 1.74974 ± 0.0667055 (W 0.00874089) | 🔴 fork 2.33× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.0307 ± 0.00977495 (W 0.0121795) | 2.93344 ± 0.00573951 (W 0.00479798) | · |  |
| `svd_thin/n256/b1` | 13.3679 ± 0.0309739 (W 0.0377038) | 13.9258 ± 0.0557171 (W 0.0139911) | · |  |
| `svd_thin/n512/b1` | 58.8532 ± 0.577816 (W 0.294027) | 80.7133 ± 0.848103 (W 0.161539) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.15632 ± 0.0234593 (W 0.00291609) | 1.33481 ± 0.00288033 (W 0.00360496) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.8207 ± 0.0230968 (W 0.0294416) | 7.26574 ± 0.0184835 (W 0.0116977) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 49.1543 ± 0.115467 (W 0.511634) | 47.4277 ± 0.735467 (W 0.0474971) | · |  |
| `triangular_solve/n128/b1` | 0.004203 ± 1.94079e-05 (W 3.78397e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0113915 ± 0.000985774 (W 5.02854e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0454045 ± 0.00488444 (W 0.000862389) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.187805 ± 0.00047284 (W 0.00156888) | 0.327638 ± 0.00218519 (W 0.00281252) | 🔵 fork 1.74× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.2267 ± 0.0148623 (W 0.00400512) | 2.10875 ± 0.0103636 (W 0.00642336) | 🔵 fork 1.72× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.90735 ± 0.0175702 (W 0.00981489) | 12.6154 ± 0.100386 (W 0.0232192) | 🔵 fork 1.60× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.27614 ± 0.00898625 (W 0.00775545) | 3.36065 ± 0.0111049 (W 0.0039555) | · |  |
| `eigh/n256/b1` | 17.4794 ± 0.0503732 (W 0.0232974) | 20.2503 ± 0.0681418 (W 0.0205325) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.704 ± 0.183852 (W 0.0626118) | 141.056 ± 0.938501 (W 0.216128) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.775423 ± 0.0059427 (W 0.00508458) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.93584 ± 0.031605 (W 0.0140424) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.6345 ± 0.0586563 (W 0.102489) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05187 ± 0.00405002 (W 0.00258012) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05303 ± 0.004953 (W 0.00119189) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49932 ± 0.0135496 (W 0.0149076) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52627 ± 0.00858907 (W 0.0204954) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9523 ± 0.0554455 (W 0.0541386) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.9658 ± 0.0772735 (W 0.081641) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.336367 ± 0.0010456 (W 0.00227279) | 0.427146 ± 0.00267035 (W 0.00382995) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.163 ± 0.00464031 (W 0.00435112) | 2.77685 ± 0.028281 (W 0.00596502) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 14.8683 ± 0.0541556 (W 0.0675086) | 18.4483 ± 0.049608 (W 0.0349443) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.57567 ± 0.00424043 (W 0.00291057) | 1.62712 ± 0.00409059 (W 0.00373927) | · |  |
| `qr/n256/b1` | 10.2019 ± 0.027355 (W 0.0242797) | 11.3186 ± 0.0192726 (W 0.0243853) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 69.7737 ± 0.0881171 (W 0.112069) | 75.3332 ± 0.175119 (W 0.0708193) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.815187 ± 0.00593772 (W 0.0016762) | 0.820467 ± 0.00496305 (W 0.00403204) | · |  |
| `qr_factor/n256/b1` | 4.77501 ± 0.0430068 (W 0.00454321) | 5.65656 ± 0.00921042 (W 0.00863776) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 30.6968 ± 0.088015 (W 0.0659757) | 37.3652 ± 0.0645805 (W 0.0647251) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.332971 ± 0.00212116 (W 0.00206757) | 0.450585 ± 0.00289918 (W 0.00384751) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 2.09849 ± 0.0055698 (W 0.00464062) | 2.85258 ± 0.0359257 (W 0.00431969) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 14.8404 ± 0.0161791 (W 0.0391658) | 18.6338 ± 0.20442 (W 0.0306482) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.74851 ± 0.0127871 (W 0.0159581) | 5.65661 ± 0.0198876 (W 0.0131268) | · |  |
| `svd_thin/n256/b1` | 34.3472 ± 0.0967423 (W 0.0738949) | 37.1672 ± 0.293984 (W 0.0566207) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 210.958 ± 0.36654 (W 0.47863) | 236.268 ± 2.03945 (W 0.704056) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.47544 ± 0.00607573 (W 0.00622143) | 2.30686 ± 0.0204154 (W 0.00743124) | 🔴 fork 1.51× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.4326 ± 0.0604681 (W 0.0406163) | 16.2244 ± 0.0701294 (W 0.0216779) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 111.759 ± 0.455321 (W 0.248813) | 100.305 ± 0.958478 (W 0.338346) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0076645 ± 5.46467e-05 (W 5.71193e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023529 ± 0.000198066 (W 5.10038e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.086587 ± 0.000996513 (W 0.00196353) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189654 ± 0.00230299 (W 0.00220953) | 0.273124 ± 0.00590194 (W 0.00482005) | 🔵 fork 1.44× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.8471 ± 0.0103547 (W 0.0110266) | 1.40014 ± 0.00701452 (W 0.00372982) | 🔵 fork 1.65× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.39921 ± 0.0155478 (W 0.0261558) | 7.01154 ± 0.0216496 (W 0.016799) | 🔵 fork 2.06× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.98204 ± 0.0180951 (W 0.0282514) | 2.65705 ± 0.00687335 (W 0.00428386) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 11.5108 ± 0.0863753 (W 0.0494805) | 12.0266 ± 0.0349022 (W 0.0102253) | · |  |
| `eigh/n512/b1` | 46.8531 ± 0.124171 (W 0.0888424) | 55.7202 ± 0.384276 (W 0.0347909) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.77915 ± 0.00238273 (W 0.00495024) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.93742 ± 0.0211213 (W 0.0141356) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.2198 ± 0.0679241 (W 0.0857114) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.288342 ± 0.000443935 (W 0.00157718) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.290146 ± 0.00162293 (W 0.00193748) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.94775 ± 0.00887028 (W 0.0112532) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94609 ± 0.0119693 (W 0.00905041) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7911 ± 0.109716 (W 0.0290851) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8021 ± 0.0582181 (W 0.0342923) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.336557 ± 0.000673749 (W 0.00209357) | 0.313632 ± 0.000801255 (W 0.00278871) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.62301 ± 0.927274 (W 0.0139997) | 1.77704 ± 0.0540667 (W 0.00395387) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 7.57514 ± 0.0302042 (W 0.0485693) | 7.46715 ± 0.053056 (W 0.0108662) | · |  |
| `qr/n128/b1` | 1.03994 ± 0.00769796 (W 0.00828164) | 1.4732 ± 0.00797179 (W 0.00517097) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 4.65094 ± 0.0215614 (W 0.0379043) | 7.12942 ± 0.0153476 (W 0.00852531) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 23.5382 ± 0.047759 (W 0.0858922) | 34.9351 ± 0.487858 (W 0.0317748) | 🔵 fork 1.48× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.617103 ± 0.0392378 (W 0.00795283) | 0.737301 ± 0.00256305 (W 0.00426757) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.945 ± 0.0211894 (W 0.0339669) | 3.52697 ± 0.0123174 (W 0.00732503) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 12.1072 ± 0.0579475 (W 0.0619956) | 17.1964 ± 0.262335 (W 0.0217694) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.333296 ± 0.00105796 (W 0.00264083) | 0.311651 ± 0.00373086 (W 0.00374607) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.49155 ± 0.00663005 (W 0.0105598) | 1.67756 ± 0.00457857 (W 0.00368713) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 7.4307 ± 0.0197675 (W 0.031739) | 7.45763 ± 0.153401 (W 0.0170833) | · | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 4.37565 ± 0.00813361 (W 0.0253715) | 4.84289 ± 0.00791072 (W 0.00785685) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 22.7191 ± 0.0636597 (W 0.0915888) | 23.4748 ± 0.0910746 (W 0.023546) | · |  |
| `svd_thin/n512/b1` | 95.4699 ± 0.264096 (W 0.304638) | 120.21 ± 0.882905 (W 0.459227) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.05465 ± 0.00350851 (W 0.00829699) | 2.47479 ± 0.0060271 (W 0.00731683) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.2095 ± 0.0860775 (W 0.107902) | 12.0772 ± 0.048387 (W 0.0267133) | 🔴 fork 1.42× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.6046 ± 0.173293 (W 0.340926) | 54.2981 ± 0.300318 (W 0.0584129) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0075495 ± 3.97178e-05 (W 5.41218e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0233985 ± 0.00018272 (W 8.43242e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0719685 ± 0.00304143 (W 0.00198603) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.195004 ± 0.00199074 (W 0.00370495) | 0.301069 ± 0.00125562 (W 0.00284889) | 🔵 fork 1.54× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.841263 ± 0.0163748 (W 0.0142676) | 1.36378 ± 0.0128808 (W 0.0032178) | 🔵 fork 1.62× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 2.81989 ± 0.043253 (W 0.0196855) | 5.85001 ± 0.0206859 (W 0.0147543) | 🔵 fork 2.07× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.94617 ± 0.0194155 (W 0.0316476) | 2.54952 ± 0.00660836 (W 0.00438726) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.8538 ± 0.0253465 (W 0.0291478) | 10.8414 ± 0.055676 (W 0.00899354) | · |  |
| `eigh/n512/b1` | 39.2288 ± 0.0712405 (W 0.0886135) | 43.2102 ± 0.0512515 (W 0.0749045) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.77622 ± 0.00469076 (W 0.00441697) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.94895 ± 0.0374357 (W 0.0208489) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.5292 ± 0.065634 (W 0.119426) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.183561 ± 0.00221413 (W 0.00171436) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.187013 ± 0.00186379 (W 0.00151666) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01431 ± 0.0036573 (W 0.00321476) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01592 ± 0.0026906 (W 0.004828) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.15013 ± 0.0288239 (W 0.0804612) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.04644 ± 0.0414139 (W 0.049274) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.335736 ± 0.00073213 (W 0.00209239) | 0.304249 ± 0.00156038 (W 0.00339316) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.58176 ± 0.0328784 (W 0.0218271) | 1.34566 ± 0.0450845 (W 0.00425588) | 🔴 fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 6.37981 ± 0.03314 (W 0.0370043) | 5.14301 ± 0.0569836 (W 0.0121327) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.999334 ± 0.00446839 (W 0.0112794) | 1.45448 ± 0.00597559 (W 0.00340357) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.50754 ± 0.0115126 (W 0.0176179) | 6.51995 ± 0.0670531 (W 0.0112697) | 🔵 fork 1.86× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 16.1675 ± 0.0271423 (W 0.0481303) | 28.6816 ± 0.36712 (W 0.0533657) | 🔵 fork 1.77× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.618981 ± 0.00591198 (W 0.00421279) | 0.727901 ± 0.00237846 (W 0.0026885) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.46481 ± 0.0184952 (W 0.0257168) | 3.22351 ± 0.0321947 (W 0.00514616) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 9.45554 ± 0.0586294 (W 0.0584638) | 13.991 ± 0.201416 (W 0.0229351) | 🔵 fork 1.48× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.332394 ± 0.00164187 (W 0.0024237) | 0.30567 ± 0.0050572 (W 0.00367413) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.44583 ± 0.0210036 (W 0.0162263) | 1.30543 ± 0.0391325 (W 0.00461685) | 🔴 fork 1.11× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 6.28374 ± 0.0455415 (W 0.0452315) | 5.17998 ± 0.086332 (W 0.0163528) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.27593 ± 0.0182111 (W 0.0236368) | 4.77659 ± 0.00460885 (W 0.00987112) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 21.4992 ± 0.0337051 (W 0.0574105) | 21.8945 ± 0.143539 (W 0.03221) | · |  |
| `svd_thin/n512/b1` | 80.7537 ± 0.172629 (W 0.354546) | 100.725 ± 0.885775 (W 0.0899606) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.06563 ± 0.0170182 (W 0.00493569) | 2.57174 ± 0.0134771 (W 0.00700465) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.3519 ± 0.0781953 (W 0.048081) | 11.9303 ± 0.0271585 (W 0.0213099) | 🔴 fork 1.45× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 61.7295 ± 0.26098 (W 0.262499) | 48.6608 ± 0.339832 (W 0.0598946) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007584 ± 3.4448e-05 (W 3.26335e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023484 ± 0.000121118 (W 7.9678e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.072289 ± 0.00377834 (W 0.00221549) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175071 ± 0.000523994 (W 0.00142869) | 0.18449 ± 0.000718941 (W 0.00144776) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.13073 ± 0.00270516 (W 0.00156902) | 1.30201 ± 0.00993394 (W 0.00289983) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.54713 ± 0.0120306 (W 0.0169267) | 9.0291 ± 0.0759821 (W 0.025091) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.26403 ± 0.015737 (W 0.0102075) | 3.2431 ± 0.0154763 (W 0.00284007) | · |  |
| `eigh/n256/b1` | 17.3781 ± 0.0358463 (W 0.0251396) | 19.6348 ± 0.0769075 (W 0.0271723) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.468 ± 0.224886 (W 0.117163) | 138.41 ± 1.53163 (W 0.0893895) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.747922 ± 0.00327193 (W 0.00527559) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.77685 ± 0.0220178 (W 0.0103161) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 39.8643 ± 0.0890334 (W 0.0534743) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03836 ± 0.00183055 (W 0.000990338) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04241 ± 0.00234682 (W 0.00188797) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.39679 ± 0.0120393 (W 0.0191745) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44284 ± 0.330306 (W 0.0162508) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9419 ± 0.151295 (W 0.0842602) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7889 ± 0.0494808 (W 0.242968) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.306087 ± 0.00101973 (W 0.00198992) | 0.34851 ± 0.00146364 (W 0.00161606) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.04003 ± 0.0095561 (W 0.00234503) | 2.33523 ± 0.0134757 (W 0.0071002) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 13.962 ± 0.0193448 (W 0.0565971) | 16.3983 ± 0.0692629 (W 0.0473705) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.54145 ± 0.00248769 (W 0.0030195) | 1.54232 ± 0.00778257 (W 0.00364394) | · |  |
| `qr/n256/b1` | 10.0901 ± 0.0320945 (W 0.0178396) | 10.7579 ± 0.0386132 (W 0.0188046) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 68.7954 ± 0.293768 (W 0.0501318) | 72.9982 ± 0.274994 (W 0.251568) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.752509 ± 0.0046654 (W 0.0020999) | 0.750058 ± 0.0019725 (W 0.00175269) | · |  |
| `qr_factor/n256/b1` | 4.48381 ± 0.0263205 (W 0.0103609) | 5.21162 ± 0.0108356 (W 0.00783935) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 28.9585 ± 0.214813 (W 0.0280479) | 35.4092 ± 0.0841001 (W 0.0577345) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.30238 ± 0.0012956 (W 0.00206821) | 0.368453 ± 0.00418365 (W 0.0022273) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.97169 ± 0.00306622 (W 0.00398663) | 2.43819 ± 0.0454064 (W 0.00470637) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 13.99 ± 0.0295029 (W 0.0379148) | 16.5482 ± 0.0521821 (W 0.0223927) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.71381 ± 0.0145183 (W 0.0117211) | 5.49 ± 0.0119499 (W 0.0091126) | · |  |
| `svd_thin/n256/b1` | 34.0141 ± 0.0868675 (W 0.068957) | 35.8504 ± 0.0763859 (W 0.0500629) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 209.879 ± 0.60754 (W 0.526926) | 232.118 ± 1.13432 (W 0.692951) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.46132 ± 0.00566941 (W 0.00882777) | 2.23199 ± 0.0234501 (W 0.00761972) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.1066 ± 0.0274592 (W 0.0421673) | 15.68 ± 0.0517091 (W 0.034266) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 110.656 ± 0.567808 (W 0.229986) | 97.4337 ± 1.00935 (W 0.325009) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007785 ± 0.000410321 (W 1.73702e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023544 ± 0.000986466 (W 9.19231e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.089422 ± 0.00284071 (W 0.000395474) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176594 ± 0.0019509 (W 0.00262093) | 0.126995 ± 0.00508327 (W 0.00475248) | 🔴 fork 1.39× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.760939 ± 0.00661554 (W 0.00865484) | 0.595799 ± 0.00168362 (W 0.00268027) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.02619 ± 0.00963449 (W 0.0206557) | 3.60836 ± 0.122437 (W 0.0325223) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.9618 ± 0.0279572 (W 0.0320094) | 2.54449 ± 0.00444299 (W 0.00375337) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 11.4038 ± 0.0409731 (W 0.0473268) | 11.3797 ± 0.180747 (W 0.0140924) | · |  |
| `eigh/n512/b1` | 46.446 ± 0.165513 (W 0.102662) | 52.8983 ± 0.181337 (W 0.0575903) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.75226 ± 0.00372789 (W 0.00594029) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.77703 ± 0.00863371 (W 0.00997277) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.4129 ± 0.129931 (W 0.0853407) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.296886 ± 0.00325712 (W 0.00317935) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.299108 ± 0.0022486 (W 0.00296005) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92881 ± 0.00760114 (W 0.00438629) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94916 ± 0.0163236 (W 0.00679062) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7739 ± 0.0327524 (W 0.0291354) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.7849 ± 0.0226176 (W 0.0312443) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.305641 ± 0.00295591 (W 0.00226953) | 0.239146 ± 0.000820901 (W 0.00219832) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.49813 ± 0.0102542 (W 0.0200413) | 1.26678 ± 0.00178309 (W 0.00212083) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.68217 ± 0.0111095 (W 0.0368777) | 5.48982 ± 0.00883635 (W 0.00950749) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 1.00564 ± 0.0327608 (W 0.00270482) | 1.36647 ± 0.0077621 (W 0.00350425) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 4.49247 ± 0.0486823 (W 0.0531866) | 6.60375 ± 0.0251616 (W 0.0136402) | 🔵 fork 1.47× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 22.5997 ± 0.0897072 (W 0.0837078) | 32.4094 ± 0.045162 (W 0.0323261) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.562111 ± 0.00732616 (W 0.00902541) | 0.664497 ± 0.00338395 (W 0.00203596) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.79108 ± 0.0213126 (W 0.035316) | 3.10089 ± 0.00824085 (W 0.00680589) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 11.4328 ± 0.0439907 (W 0.0590938) | 15.3559 ± 0.0549682 (W 0.0178344) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.302354 ± 0.00107846 (W 0.00221125) | 0.237001 ± 0.0014633 (W 0.00152684) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.3575 ± 0.00703551 (W 0.014487) | 1.25907 ± 0.00165907 (W 0.00268087) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 6.55443 ± 0.0219788 (W 0.0339362) | 5.51956 ± 0.0270588 (W 0.0106556) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.36084 ± 0.0205438 (W 0.0214816) | 4.66317 ± 0.0136791 (W 0.00636378) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 22.4161 ± 0.0389846 (W 0.0664905) | 22.5031 ± 0.0607653 (W 0.0240278) | · |  |
| `svd_thin/n512/b1` | 94.527 ± 0.493666 (W 0.278325) | 114.804 ± 1.06801 (W 0.491389) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.02115 ± 0.00426994 (W 0.00408795) | 2.40598 ± 0.0298311 (W 0.00594433) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 16.9853 ± 0.11746 (W 0.0755026) | 11.7044 ± 0.0935412 (W 0.0227747) | 🔴 fork 1.45× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 64.7771 ± 0.142936 (W 0.339853) | 51.9664 ± 0.170631 (W 0.0548704) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007158 ± 0.000273482 (W 2.26883e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0207385 ± 0.001672 (W 4.4154e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.0764775 ± 0.00162955 (W 0.000554696) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.1829 ± 0.000934238 (W 0.00382084) | 0.158155 ± 0.00090185 (W 0.00181104) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.748881 ± 0.00704417 (W 0.0150989) | 0.549435 ± 0.00300814 (W 0.00336674) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.43969 ± 0.0280056 (W 0.0218333) | 2.46791 ± 0.0675698 (W 0.0159056) | · | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.91214 ± 0.0158785 (W 0.0262843) | 2.44111 ± 0.00769171 (W 0.00306291) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.7889 ± 0.0304629 (W 0.0334628) | 10.1923 ± 0.0125254 (W 0.0141996) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 38.9183 ± 0.0929662 (W 0.125773) | 40.3398 ± 0.0804518 (W 0.206688) | · |  |
| `full_piv_lu/n128/b1` | 0.748329 ± 0.00661865 (W 0.00407755) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.80644 ± 0.0385861 (W 0.0115471) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.725 ± 0.0913574 (W 0.0710246) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.196846 ± 0.00191106 (W 0.00119368) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.19838 ± 0.00289715 (W 0.00156537) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.02394 ± 0.00348662 (W 0.00512131) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.0263 ± 0.00275442 (W 0.00301893) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.20469 ± 1.52814 (W 0.0431494) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.16494 ± 0.0285703 (W 0.0414518) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.305955 ± 0.000560263 (W 0.00220681) | 0.226132 ± 0.00120578 (W 0.00122872) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.45704 ± 0.0156869 (W 0.0147408) | 0.88915 ± 0.00262288 (W 0.00295642) | 🔴 fork 1.64× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 5.5755 ± 0.0223706 (W 0.0293092) | 3.25511 ± 0.0226036 (W 0.00418674) | 🔴 fork 1.71× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.964007 ± 0.059027 (W 0.00969978) | 1.35541 ± 0.00706407 (W 0.00356528) | 🔵 fork 1.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 3.35062 ± 0.0177918 (W 0.0134926) | 5.98015 ± 0.0239475 (W 0.00908576) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 15.2625 ± 0.0647962 (W 0.0566178) | 25.8283 ± 0.0568015 (W 0.032975) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.562524 ± 0.0231709 (W 0.00726613) | 0.652697 ± 0.00174691 (W 0.00289295) | 🔵 fork 1.16× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.32283 ± 0.011629 (W 0.0169803) | 2.79006 ± 0.0100294 (W 0.00642825) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.85966 ± 0.0370687 (W 0.029509) | 12.0258 ± 0.148415 (W 0.0221379) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.303165 ± 0.00107713 (W 0.00219416) | 0.229106 ± 0.00179466 (W 0.00209105) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.32647 ± 0.0163727 (W 0.0183963) | 0.902089 ± 0.0039627 (W 0.0021555) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 5.41264 ± 0.0296592 (W 0.0298061) | 3.3363 ± 0.026109 (W 0.00716634) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.25528 ± 0.00973969 (W 0.0236577) | 4.62018 ± 0.0105788 (W 0.00780124) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 21.2264 ± 0.0975401 (W 0.115355) | 20.8198 ± 0.0904325 (W 0.0388138) | · |  |
| `svd_thin/n512/b1` | 79.5518 ± 0.136561 (W 0.364643) | 95.5224 ± 0.786389 (W 0.33153) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.02341 ± 0.0059466 (W 0.00774321) | 2.50345 ± 0.00602403 (W 0.00482766) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.0766 ± 0.0354035 (W 0.0454775) | 11.5417 ± 0.0368759 (W 0.0185018) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 60.7447 ± 0.34582 (W 0.370676) | 46.2773 ± 0.155862 (W 0.0382544) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0076145 ± 0.00065974 (W 2.78708e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0216305 ± 0.00124855 (W 5.80551e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.077524 ± 0.00295676 (W 0.000986691) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.832401 ± 0.00272539 (W 0.00278287) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 48.6964 ± 0.596722 (W 0.253837) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.552947 ± 0.0011085 (W 0.0021828) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554245 ± 0.00140266 (W 0.00261573) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.2221 ± 0.0676133 (W 0.0389524) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.2568 ± 0.0869641 (W 0.377473) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.492852 ± 0.00343303 (W 0.00231219) | 0.729156 ± 0.168791 (W 0.00414255) | 🔵 fork 1.48× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.5993 ± 0.145492 (W 0.0443878) | 28.0914 ± 0.186253 (W 0.0822877) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.59507 ± 0.00793236 (W 0.0042395) | 2.48763 ± 0.0217101 (W 0.0120697) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 71.2181 ± 0.161078 (W 0.132805) | 105.144 ± 1.74234 (W 0.938038) | 🔵 fork 1.48× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.06289 ± 0.0026893 (W 0.00195613) | 1.27028 ± 0.0054008 (W 0.00559718) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 31.9138 ± 0.172075 (W 0.124794) | 50.5399 ± 0.559162 (W 0.72072) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.51223 ± 0.00594583 (W 0.00466354) | 3.77047 ± 0.00545001 (W 0.0073954) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 88.6215 ± 0.251701 (W 0.194338) | 146.353 ± 0.951853 (W 1.25857) | 🔵 fork 1.65× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.4978 ± 0.00517753 (W 0.0076074) | 1.93238 ± 0.0108218 (W 0.00399403) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 44.8701 ± 0.059111 (W 0.0667385) | 69.5373 ± 2.47526 (W 0.640229) | 🔵 fork 1.55× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.830394 ± 0.0037826 (W 0.00234094) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 20.0729 ± 0.0821914 (W 0.232329) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.183989 ± 0.00117005 (W 0.00792513) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.183982 ± 0.00190841 (W 0.00388047) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.2887 ± 0.185557 (W 0.0745422) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.2496 ± 0.0945465 (W 0.0979316) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.511059 ± 0.00510953 (W 0.00974157) | 0.669249 ± 0.12107 (W 0.00235374) | 🔵 fork 1.31× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.70434 ± 0.160719 (W 0.0782577) | 22.3454 ± 0.187475 (W 0.395245) | 🔵 fork 2.30× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.31281 ± 0.00740659 (W 0.00751497) | 2.5935 ± 0.011556 (W 0.0140521) | 🔵 fork 1.98× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 28.8043 ± 0.26402 (W 0.158432) | 66.5898 ± 1.5643 (W 1.09613) | 🔵 fork 2.31× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.05282 ± 0.00616089 (W 0.00956702) | 1.31801 ± 0.00664868 (W 0.00308659) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 15.8293 ± 0.147866 (W 0.255912) | 32.1679 ± 0.602677 (W 0.144476) | 🔵 fork 2.03× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.39829 ± 0.0107918 (W 0.0264132) | 3.63062 ± 0.00494082 (W 0.00598105) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 47.096 ± 0.0937653 (W 0.272058) | 83.4606 ± 0.860687 (W 0.297485) | 🔵 fork 1.77× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.67495 ± 0.0149258 (W 0.0267921) | 1.9868 ± 0.00779953 (W 0.0138236) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 31.4056 ± 0.106781 (W 0.215527) | 48.2826 ± 0.879189 (W 0.306977) | 🔵 fork 1.54× faster than `lapack-openblas` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.834201 ± 0.00430915 (W 0.00281184) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 16.145 ± 0.131548 (W 0.124818) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.156362 ± 0.00706635 (W 0.00319637) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.155906 ± 0.00540757 (W 0.00476092) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.50786 ± 0.132156 (W 0.0708324) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.52023 ± 0.10137 (W 0.0686798) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.50083 ± 0.00306588 (W 0.00347155) | 0.657447 ± 0.129097 (W 0.00379641) | 🔵 fork 1.31× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.94345 ± 0.0622906 (W 0.0736175) | 19.6121 ± 0.188579 (W 0.0503852) | 🔵 fork 2.19× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.43859 ± 0.0697411 (W 0.0158449) | 2.59515 ± 0.0103239 (W 0.00752248) | 🔵 fork 1.80× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 22.376 ± 2.19708 (W 0.143976) | 62.5 ± 1.8508 (W 1.18494) | 🔵 fork 2.79× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.13058 ± 0.0181059 (W 0.0125382) | 1.32528 ± 0.0054938 (W 0.00283953) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 13.0232 ± 0.13496 (W 0.12523) | 30.413 ± 0.674371 (W 0.227084) | 🔵 fork 2.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.52155 ± 0.0158785 (W 0.0248695) | 3.59171 ± 0.0190851 (W 0.00685968) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 40.9904 ± 2.73443 (W 0.270748) | 76.7632 ± 1.11049 (W 0.812067) | 🔵 fork 1.87× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.79233 ± 0.0260334 (W 0.0234223) | 1.98662 ± 0.00976609 (W 0.00550904) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 29.8516 ± 0.856013 (W 0.496517) | 46.2523 ± 0.687121 (W 0.766987) | 🔵 fork 1.55× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729723 ± 0.00105419 (W 0.00271638) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.7564 ± 0.419409 (W 0.134715) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.586639 ± 0.0162729 (W 0.00192162) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.603866 ± 0.00344417 (W 0.00305377) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.9958 ± 0.680829 (W 0.0423009) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.949 ± 0.0422831 (W 0.0376895) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.388475 ± 0.0144576 (W 0.00268886) | 0.30564 ± 0.00167721 (W 0.0020907) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 13.2108 ± 0.0122123 (W 0.029496) | 12.9739 ± 0.053688 (W 0.0257835) | · |  |
| `qr/1024x64/b1` | 1.46837 ± 0.0712126 (W 0.00403982) | 1.87741 ± 0.02807 (W 0.00232208) | 🔵 fork 1.28× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 68.6644 ± 0.0849627 (W 0.121541) | 77.676 ± 0.358601 (W 0.215003) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.775304 ± 0.00182286 (W 0.00260122) | 0.958726 ± 0.00202251 (W 0.00141515) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 25.8636 ± 0.066826 (W 0.0560108) | 38.8645 ± 0.297559 (W 0.194594) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.4592 ± 0.125045 (W 0.00526222) | 3.25101 ± 0.00909115 (W 0.00645441) | 🔵 fork 1.32× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 83.1844 ± 0.214096 (W 0.115583) | 120.622 ± 0.605225 (W 0.243715) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.40479 ± 0.00341517 (W 0.00263424) | 1.61336 ± 0.00290041 (W 0.0035501) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 39.0585 ± 0.0577632 (W 0.0521992) | 54.832 ± 0.369814 (W 0.109045) | 🔵 fork 1.40× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731807 ± 0.00122224 (W 0.00315813) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6178 ± 0.133038 (W 0.200324) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.191101 ± 0.00308073 (W 0.00451927) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.200589 ± 0.00458419 (W 0.00428251) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.1819 ± 0.0665188 (W 0.0429073) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2526 ± 0.104161 (W 0.0394656) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.409844 ± 0.00227317 (W 0.00970708) | 0.252821 ± 0.000728728 (W 0.00230088) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 7.36787 ± 0.032072 (W 0.0488448) | 7.21707 ± 0.201377 (W 0.0108167) | · | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.20111 ± 0.0140732 (W 0.00966852) | 1.97508 ± 0.00864757 (W 0.00312972) | 🔵 fork 1.64× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 26.0908 ± 0.216874 (W 0.253927) | 41.1948 ± 0.338317 (W 0.164606) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.915086 ± 0.00412712 (W 0.0111037) | 1.02797 ± 0.00448244 (W 0.00226437) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 13.6826 ± 0.131625 (W 0.174161) | 20.6496 ± 0.148571 (W 0.0254458) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.32658 ± 0.0110443 (W 0.0219785) | 3.09733 ± 0.0111506 (W 0.0098101) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 41.2233 ± 0.0834456 (W 0.251905) | 67.0005 ± 0.369852 (W 0.207746) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.57537 ± 0.00940386 (W 0.0098679) | 1.68519 ± 0.0261202 (W 0.00280933) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 25.7816 ± 0.138435 (W 0.256041) | 36.1994 ± 0.327243 (W 0.0640443) | 🔵 fork 1.40× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730556 ± 0.00118893 (W 0.00238583) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.7162 ± 0.162071 (W 0.0930319) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.161712 ± 0.00394256 (W 0.00393785) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.162828 ± 0.00600002 (W 0.00343259) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.62109 ± 0.14273 (W 0.186013) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.63922 ± 0.0859099 (W 0.126128) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.395579 ± 0.00406901 (W 0.00571238) | 0.234893 ± 0.00149791 (W 0.00214668) | 🔴 fork 1.68× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 6.64355 ± 0.0221993 (W 0.0274839) | 4.75578 ± 0.0266128 (W 0.0104445) | 🔴 fork 1.40× slower than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.33807 ± 0.0162663 (W 0.0152559) | 1.98082 ± 0.0138999 (W 0.00283907) | 🔵 fork 1.48× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 19.912 ± 2.04617 (W 0.100125) | 36.6092 ± 0.297118 (W 0.0447459) | 🔵 fork 1.84× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.04454 ± 0.00889957 (W 0.0144264) | 1.02766 ± 0.00470726 (W 0.00198982) | · |  |
| `qr_factor/4096x256/b1` | 11.6106 ± 0.0735726 (W 0.0426304) | 18.2497 ± 0.224714 (W 0.0236937) | 🔵 fork 1.57× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.47307 ± 0.0153452 (W 0.0196855) | 3.06973 ± 0.0166783 (W 0.00435358) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 35.2955 ± 0.102425 (W 0.121755) | 59.698 ± 0.308087 (W 0.0940977) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.69011 ± 0.00797675 (W 0.0212189) | 1.68925 ± 0.00582767 (W 0.00249314) | · |  |
| `svd_values/4096x256/b1` | 24.1762 ± 0.0456896 (W 0.0696595) | 33.9952 ± 0.252649 (W 0.0520422) | 🔵 fork 1.41× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79951 ± 0.00726311 (W 0.00453095) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.97 ± 0.780366 (W 0.673402) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19844 ± 0.0054656 (W 0.0039566) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20078 ± 0.00371066 (W 0.0032114) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.815 ± 0.13207 (W 0.243731) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.022 ± 0.19772 (W 0.166401) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.0497 ± 0.00216589 (W 0.00287841) | 1.29661 ± 0.0038622 (W 0.0029608) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 47.5919 ± 0.338797 (W 0.137135) | 69.2045 ± 4.87077 (W 0.141143) | 🔵 fork 1.45× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 4.74449 ± 0.0376023 (W 0.00742676) | 4.34623 ± 0.0514658 (W 0.00627564) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 245.129 ± 6.23073 (W 0.217624) | 263.818 ± 4.15931 (W 1.47451) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 2.58498 ± 0.0182997 (W 0.00555374) | 2.20974 ± 0.0191702 (W 0.0038949) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 101.2 ± 0.448659 (W 0.132905) | 130.522 ± 2.49485 (W 0.569108) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.9962 ± 0.0359926 (W 0.00519647) | 6.90313 ± 0.0456343 (W 0.0189777) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 280.496 ± 1.52085 (W 1.53264) | 385.331 ± 2.4252 (W 0.915755) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 3.08675 ± 0.0176716 (W 0.00582882) | 3.13775 ± 0.0265657 (W 0.00499759) | · |  |
| `svd_values/4096x256/b1` | 123.04 ± 0.72779 (W 0.231648) | 154.412 ± 2.3021 (W 0.638813) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.796 ± 0.00944539 (W 0.00197104) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.069 ± 0.447385 (W 0.672039) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.635311 ± 0.22079 (W 0.00876192) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.634513 ± 0.0058586 (W 0.00768898) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.1957 ± 0.0702535 (W 0.173742) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.1697 ± 0.204866 (W 0.249859) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.873834 ± 0.00374447 (W 0.00761876) | 1.03802 ± 0.0245276 (W 0.00178885) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 23.4974 ± 0.274098 (W 0.137102) | 42.0915 ± 4.24462 (W 0.198412) | 🔵 fork 1.79× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 2.71131 ± 0.104613 (W 0.0954951) | 2.19174 ± 0.0395123 (W 0.0032833) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 84.4407 ± 0.141602 (W 0.218818) | 113.007 ± 2.82536 (W 0.568668) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.9548 ± 0.0227104 (W 0.0398874) | 1.13747 ± 0.015415 (W 0.00226008) | 🔴 fork 1.72× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 40.88 ± 0.239508 (W 0.0981875) | 56.3671 ± 1.90128 (W 0.252019) | 🔵 fork 1.38× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 4.09703 ± 0.0732286 (W 0.0959755) | 3.72108 ± 0.0598129 (W 0.00368603) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 115.369 ± 0.167526 (W 0.327258) | 153.042 ± 3.60701 (W 0.970105) | 🔵 fork 1.33× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.69872 ± 0.0390042 (W 0.0631178) | 2.07655 ± 0.0210748 (W 0.00362639) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 67.378 ± 0.173891 (W 0.443491) | 76.7787 ± 1.78559 (W 0.493834) | 🔵 fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.799 ± 0.0111999 (W 0.00307267) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.7263 ± 0.19885 (W 0.458518) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.409986 ± 0.0135282 (W 0.00731454) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.420853 ± 0.0112113 (W 0.0115035) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.666 ± 0.660279 (W 0.455613) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.6936 ± 0.271714 (W 0.445767) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.864725 ± 0.00794263 (W 0.0121121) | 0.905708 ± 0.0273509 (W 0.00266052) | · | `!` between-start range over 5% |
| `lu/4096x256/b1` | 19.6998 ± 0.20528 (W 0.20551) | 40.4212 ± 3.58792 (W 0.0887088) | 🔵 fork 2.05× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.49204 ± 0.024717 (W 0.0239187) | 1.95481 ± 0.0521605 (W 0.00652484) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 68.832 ± 4.37991 (W 0.377775) | 85.2144 ± 0.571358 (W 0.237658) | 🔵 fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.87835 ± 0.0652092 (W 0.0179917) | 1.00915 ± 0.0168033 (W 0.00293099) | 🔴 fork 1.86× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 30.9923 ± 0.213463 (W 0.123163) | 42.2729 ± 0.333432 (W 0.0826315) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.88811 ± 0.0133429 (W 0.0252727) | 3.2897 ± 0.0757621 (W 0.00602994) | 🔴 fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 88.9616 ± 0.130469 (W 0.233306) | 110.345 ± 0.282718 (W 0.371961) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.6721 ± 0.0144453 (W 0.0179429) | 1.9691 ± 0.0124842 (W 0.0078341) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 59.2656 ± 1.44617 (W 0.197243) | 62.0828 ± 0.703008 (W 0.392993) | · | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66912 ± 0.00351007 (W 0.00550676) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.082 ± 0.805907 (W 0.560291) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26748 ± 0.0109627 (W 0.00378364) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26473 ± 0.0139335 (W 0.00286873) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.712 ± 0.191443 (W 0.289773) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.836 ± 0.102539 (W 0.359077) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.916379 ± 0.00210568 (W 0.00165001) | 0.94246 ± 0.00636773 (W 0.00148453) | · |  |
| `lu/4096x256/b1` | 42.0755 ± 0.380488 (W 0.0615734) | 47.1743 ± 0.0959865 (W 0.0514255) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 4.61943 ± 0.0377298 (W 0.0100663) | 3.55493 ± 0.0240193 (W 0.00296934) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 239.354 ± 5.97258 (W 0.289773) | 221.746 ± 0.377724 (W 0.467514) | 🔴 fork 1.08× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 2.26879 ± 0.0145347 (W 0.00286036) | 1.82322 ± 0.0118889 (W 0.00367789) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 90.454 ± 0.506794 (W 0.0732185) | 111.412 ± 0.48103 (W 0.462081) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.92565 ± 0.0256856 (W 0.00942318) | 6.26778 ± 0.506537 (W 0.0103524) | · | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 268.637 ± 1.23949 (W 0.446173) | 352.292 ± 6.21012 (W 0.65969) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.96198 ± 0.0168254 (W 0.00167752) | 2.74746 ± 0.0171118 (W 0.00444) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 110.747 ± 0.515086 (W 0.265308) | 136.213 ± 0.565128 (W 0.325459) | 🔵 fork 1.23× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66617 ± 0.00610786 (W 0.00360441) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.2035 ± 0.241644 (W 0.845484) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.653475 ± 0.00632637 (W 0.0105268) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.652518 ± 0.229973 (W 0.00826178) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.311 ± 0.137143 (W 0.0637795) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.2552 ± 0.0965913 (W 0.0841494) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.752158 ± 0.00520971 (W 0.0118597) | 0.689092 ± 0.00239351 (W 0.00254418) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 17.893 ± 0.0520707 (W 0.0516779) | 24.2624 ± 0.126503 (W 0.0235777) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 2.5532 ± 0.107905 (W 0.0246589) | 1.47149 ± 0.0093116 (W 0.00349624) | 🔴 fork 1.74× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 78.864 ± 0.236702 (W 0.23628) | 73.6028 ± 0.139512 (W 0.125752) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.78484 ± 0.0725525 (W 0.0556071) | 0.788897 ± 0.00423326 (W 0.00267012) | 🔴 fork 2.26× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 36.2435 ± 0.115691 (W 0.103039) | 36.6401 ± 0.106316 (W 0.0445184) | · |  |
| `svd_thin/1024x64/b1` | 4.00356 ± 0.0955037 (W 0.123603) | 3.13355 ± 0.0102397 (W 0.00418346) | 🔴 fork 1.28× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 103.336 ± 0.277816 (W 0.27926) | 123.53 ± 0.431019 (W 0.157349) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.59496 ± 0.0517791 (W 0.0643109) | 1.73675 ± 0.00570703 (W 0.00225856) | 🔴 fork 1.49× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 55.5273 ± 0.195391 (W 0.161426) | 57.4035 ± 0.294795 (W 0.143957) | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66849 ± 0.00991626 (W 0.00523563) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.0188 ± 0.591985 (W 0.406258) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.424918 ± 0.0190247 (W 0.00866353) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.434145 ± 0.0181569 (W 0.00891035) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.846 ± 0.331352 (W 0.506825) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.2101 ± 0.248573 (W 0.345044) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.741718 ± 0.00607351 (W 0.00844863) | 0.567724 ± 0.00191897 (W 0.00277009) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.9082 ± 0.0465952 (W 0.0571933) | 14.5376 ± 0.0321237 (W 0.0199796) | · |  |
| `qr/1024x64/b1` | 2.36025 ± 0.00952379 (W 0.0214859) | 1.16959 ± 0.00655654 (W 0.0020283) | 🔴 fork 2.02× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 62.9686 ± 4.22699 (W 0.27683) | 50.2788 ± 0.503114 (W 0.108373) | 🔴 fork 1.25× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.74754 ± 0.0116034 (W 0.0160582) | 0.637898 ± 0.00588073 (W 0.00191954) | 🔴 fork 2.74× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 27.939 ± 0.127219 (W 0.0946262) | 25.019 ± 0.0657212 (W 0.0281682) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.76823 ± 0.02726 (W 0.0207524) | 2.69301 ± 0.0127758 (W 0.00387196) | 🔴 fork 1.40× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 76.5434 ± 0.790656 (W 0.246313) | 88.3414 ± 0.381291 (W 0.116758) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.57002 ± 0.00838851 (W 0.0214784) | 1.59292 ± 0.00768489 (W 0.00268018) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 47.6474 ± 0.159596 (W 0.136847) | 45.1263 ± 0.50398 (W 0.0385808) | 🔴 fork 1.06× slower than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 76.455 ± 1.19106 (W 0.413899) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.14786 ± 0.00693169 (W 0.00278072) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.1523 ± 0.0867076 (W 0.0418945) | 35.7643 ± 0.551858 (W 0.785478) | 🔵 fork 2.21× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.414809 ± 0.00305083 (W 0.0027346) | 1.14031 ± 0.136389 (W 0.00457881) | 🔵 fork 2.75× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 31.0395 ± 0.264759 (W 0.095334) | 73.664 ± 2.41818 (W 0.529611) | 🔵 fork 2.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.755839 ± 0.00422665 (W 0.00244368) | 1.90344 ± 0.00867385 (W 0.0196367) | 🔵 fork 2.52× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 26.9052 ± 0.207511 (W 0.0381444) | 64.4222 ± 2.78602 (W 0.31915) | 🔵 fork 2.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.991486 ± 0.0106063 (W 0.0064605) | 1.72273 ± 0.0143091 (W 0.0146646) | 🔵 fork 1.74× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 83.5444 ± 0.248494 (W 0.118527) | 222.583 ± 3.10489 (W 0.766717) | 🔵 fork 2.66× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.45574 ± 0.00646034 (W 0.00565886) | 5.03497 ± 0.0478378 (W 0.0105034) | 🔵 fork 2.05× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 39.1354 ± 0.125264 (W 0.0466109) | 107.293 ± 0.791361 (W 0.593358) | 🔵 fork 2.74× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.41496 ± 0.00482328 (W 0.00308897) | 2.57799 ± 0.0432701 (W 0.0169338) | 🔵 fork 1.82× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 38.0989 ± 0.548346 (W 0.224053) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.15052 ± 0.22386 (W 0.00437618) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 7.39431 ± 0.119696 (W 0.112021) | 26.6687 ± 0.452934 (W 0.24799) | 🔵 fork 3.61× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.246397 ± 0.00265372 (W 0.00306956) | 0.807554 ± 0.00517294 (W 0.00193743) | 🔵 fork 3.28× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 11.6042 ± 0.127703 (W 0.122214) | 44.6773 ± 1.15229 (W 0.927137) | 🔵 fork 3.85× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.461615 ± 0.00977097 (W 0.00828644) | 1.72052 ± 0.00649579 (W 0.0122836) | 🔵 fork 3.73× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 10.5575 ± 0.0497068 (W 0.0542773) | 41.0351 ± 0.613107 (W 0.148813) | 🔵 fork 3.89× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.670493 ± 0.00731586 (W 0.00902536) | 1.55699 ± 0.012909 (W 0.00599932) | 🔵 fork 2.32× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 41.4759 ± 0.242314 (W 0.164691) | 146.531 ± 1.60741 (W 0.515754) | 🔵 fork 3.53× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.31402 ± 0.0147603 (W 0.0282616) | 4.45664 ± 0.0592406 (W 0.00909874) | 🔵 fork 1.93× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 25.8588 ± 0.14565 (W 0.238899) | 77.7312 ± 0.80778 (W 0.709096) | 🔵 fork 3.01× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.58299 ± 0.014915 (W 0.0214405) | 2.47356 ± 0.0167875 (W 0.0125149) | 🔵 fork 1.56× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 33.1272 ± 0.166547 (W 0.127008) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.14656 ± 0.00797314 (W 0.00388978) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 6.09748 ± 0.11025 (W 0.132503) | 24.2501 ± 0.538029 (W 0.087786) | 🔵 fork 3.98× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.226246 ± 0.000992953 (W 0.00363465) | 0.88095 ± 0.133952 (W 0.00270905) | 🔵 fork 3.89× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 8.26147 ± 0.130566 (W 0.113628) | 39.1395 ± 2.05495 (W 0.178189) | 🔵 fork 4.74× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.40381 ± 0.00194089 (W 0.00416866) | 1.76115 ± 0.0509757 (W 0.0152981) | 🔵 fork 4.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 7.87567 ± 0.102895 (W 0.0529644) | 35.3483 ± 0.276757 (W 0.0599783) | 🔵 fork 4.49× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.611661 ± 0.00933524 (W 0.00654099) | 1.58086 ± 0.0489881 (W 0.00573598) | 🔵 fork 2.58× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 35.1982 ± 0.0741627 (W 0.115563) | 137.011 ± 6.10642 (W 0.31239) | 🔵 fork 3.89× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.46787 ± 0.00771191 (W 0.0202024) | 4.58126 ± 0.0572826 (W 0.0146587) | 🔵 fork 1.86× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 24.181 ± 0.743462 (W 0.0979904) | 71.723 ± 2.71836 (W 0.115854) | 🔵 fork 2.97× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.70584 ± 0.0128681 (W 0.0181585) | 2.5257 ± 0.0408036 (W 0.0126328) | 🔵 fork 1.48× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.2825 ± 2.06012 (W 0.350954) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.04757 ± 0.00626192 (W 0.0035049) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3012 ± 0.0372587 (W 0.0351335) | 20.3403 ± 0.236459 (W 0.0685954) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.312142 ± 0.00256703 (W 0.0024279) | 0.704419 ± 0.00302934 (W 0.00271981) | 🔵 fork 2.26× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 27.8616 ± 0.237524 (W 0.114375) | 74.5887 ± 1.7377 (W 0.378893) | 🔵 fork 2.68× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.629068 ± 0.00258673 (W 0.00253626) | 1.66991 ± 0.0302314 (W 0.00503828) | 🔵 fork 2.65× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 25.1281 ± 0.329116 (W 0.068268) | 54.7972 ± 2.3247 (W 0.49612) | 🔵 fork 2.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.564817 ± 0.00308668 (W 0.00254391) | 1.40277 ± 0.0135506 (W 0.00358521) | 🔵 fork 2.48× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 88.891 ± 0.228625 (W 0.0928413) | 198.788 ± 4.0341 (W 0.533922) | 🔵 fork 2.24× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.51894 ± 0.0112683 (W 0.00436286) | 4.58533 ± 0.0453612 (W 0.0127239) | 🔵 fork 1.82× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 44.9539 ± 0.100161 (W 0.0888779) | 93.8984 ± 2.20898 (W 0.223479) | 🔵 fork 2.09× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.47377 ± 0.00632931 (W 0.00651082) | 2.28108 ± 0.0392987 (W 0.0107696) | 🔵 fork 1.55× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.4057 ± 0.405107 (W 0.156346) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04607 ± 0.208416 (W 0.00353934) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 4.40576 ± 0.0168538 (W 0.0339708) | 12.2441 ± 0.204965 (W 0.0135968) | 🔵 fork 2.78× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.136315 ± 0.00223779 (W 0.00225121) | 0.493734 ± 0.00627409 (W 0.00227296) | 🔵 fork 3.62× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 8.37957 ± 0.0485999 (W 0.0506126) | 43.8611 ± 0.949035 (W 0.219055) | 🔵 fork 5.23× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.332541 ± 0.0113726 (W 0.0101631) | 1.46744 ± 0.00439703 (W 0.00552647) | 🔵 fork 4.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 7.22162 ± 0.0493593 (W 0.0387371) | 29.7715 ± 0.900992 (W 0.25303) | 🔵 fork 4.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.256255 ± 0.00260734 (W 0.00421513) | 1.23579 ± 0.00534799 (W 0.00262096) | 🔵 fork 4.82× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 47.061 ± 0.184809 (W 0.282053) | 128.852 ± 1.36428 (W 0.320832) | 🔵 fork 2.74× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.39476 ± 0.0221812 (W 0.0190045) | 4.04865 ± 0.0216796 (W 0.0130071) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 31.6611 ± 0.10402 (W 0.249837) | 66.9453 ± 0.61568 (W 0.217596) | 🔵 fork 2.11× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.64443 ± 0.0106161 (W 0.0269883) | 2.13802 ± 0.00232314 (W 0.00638142) | 🔵 fork 1.30× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.3715 ± 0.164752 (W 0.169972) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04201 ± 0.0100714 (W 0.00493956) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.92073 ± 0.0140592 (W 0.0185645) | 9.96689 ± 0.249384 (W 0.0143841) | 🔵 fork 3.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.117139 ± 0.00149822 (W 0.00207777) | 0.452178 ± 0.00644285 (W 0.0016883) | 🔵 fork 3.86× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 5.09654 ± 0.0694474 (W 0.0436353) | 38.6987 ± 3.05073 (W 0.170302) | 🔵 fork 7.59× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.272728 ± 0.00120501 (W 0.00247947) | 1.47458 ± 0.0120793 (W 0.00407696) | 🔵 fork 5.41× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 4.24599 ± 0.0158836 (W 0.0165843) | 25.2608 ± 0.0870519 (W 0.0901833) | 🔵 fork 5.95× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.197364 ± 0.00231335 (W 0.00342478) | 1.24672 ± 0.00563892 (W 0.00386639) | 🔵 fork 6.32× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 40.8381 ± 0.129045 (W 0.197992) | 118.815 ± 3.35129 (W 0.365494) | 🔵 fork 2.91× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.55841 ± 0.0116794 (W 0.0235992) | 4.05591 ± 0.0452873 (W 0.0108678) | 🔵 fork 1.59× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 29.8595 ± 0.0542696 (W 0.0962279) | 61.846 ± 0.448797 (W 0.25176) | 🔵 fork 2.07× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.77018 ± 0.00999634 (W 0.0228345) | 2.18372 ± 0.0300612 (W 0.00785259) | 🔵 fork 1.23× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 234.66 ± 4.53184 (W 0.702356) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.45808 ± 0.0281833 (W 0.012206) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.3848 ± 0.0864976 (W 0.0957795) | 82.3555 ± 0.500916 (W 0.147455) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 1.00967 ± 0.00682341 (W 0.00220041) | 1.66653 ± 0.0179779 (W 0.00280623) | 🔵 fork 1.65× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 107.174 ± 0.962204 (W 0.178527) | 184.514 ± 4.75046 (W 1.0712) | 🔵 fork 1.72× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 2.54165 ± 0.00803453 (W 0.00365915) | 3.62077 ± 0.0337509 (W 0.00664646) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 96.92 ± 0.403773 (W 0.247118) | 168.193 ± 4.43143 (W 1.54864) | 🔵 fork 1.74× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.57353 ± 0.00607248 (W 0.00503489) | 3.37042 ± 0.0524576 (W 0.00648498) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 269.23 ± 0.297607 (W 3.25554) | 690.032 ± 12.493 (W 2.94565) | 🔵 fork 2.56× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 5.93252 ± 0.0152964 (W 0.00955233) | 11.8677 ± 0.151994 (W 0.0216436) | 🔵 fork 2.00× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 110.651 ± 0.0709008 (W 0.0992083) | 309.753 ± 5.71917 (W 1.53415) | 🔵 fork 2.80× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.95631 ± 0.0192388 (W 0.00433342) | 5.61043 ± 0.0726666 (W 0.0120201) | 🔵 fork 1.90× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.7229 ± 2.72221 (W 0.390549) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.43671 ± 0.0404684 (W 0.0120327) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.6307 ± 0.0840319 (W 0.0811554) | 54.0522 ± 4.35085 (W 0.118587) | 🔵 fork 2.90× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.445944 ± 0.00161797 (W 0.00449611) | 1.20621 ± 0.0136573 (W 0.00526639) | 🔵 fork 2.70× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 33.5507 ± 0.382792 (W 0.184281) | 79.2593 ± 1.17261 (W 1.11207) | 🔵 fork 2.36× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.991933 ± 0.0197339 (W 0.0095342) | 1.67117 ± 0.0155551 (W 0.0112819) | 🔵 fork 1.68× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 28.3044 ± 0.135944 (W 0.118961) | 72.8427 ± 1.73848 (W 0.825115) | 🔵 fork 2.57× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 1.07604 ± 0.0279484 (W 0.0190992) | 1.36548 ± 0.0315148 (W 0.00413913) | 🔵 fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 104.127 ± 0.239967 (W 0.283562) | 441.647 ± 9.46584 (W 2.41517) | 🔵 fork 4.24× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.9883 ± 0.103615 (W 0.109091) | 9.83102 ± 0.0933174 (W 0.0508218) | 🔵 fork 2.46× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/256x4096/b1` | 55.5874 ± 0.154501 (W 0.102431) | 218.242 ± 2.77248 (W 0.573086) | 🔵 fork 3.93× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.59715 ± 0.0693063 (W 0.071314) | 5.15419 ± 0.0342448 (W 0.0318453) | 🔵 fork 1.98× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.1468 ± 1.70205 (W 0.361506) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.43994 ± 0.0375746 (W 0.00479698) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.0172 ± 0.166404 (W 0.140631) | 50.045 ± 5.89582 (W 0.125417) | 🔵 fork 3.84× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.366159 ± 0.00278705 (W 0.00384182) | 1.07243 ± 0.00605659 (W 0.00353784) | 🔵 fork 2.93× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 21.1995 ± 0.152767 (W 0.103064) | 61.13 ± 0.364813 (W 0.360259) | 🔵 fork 2.88× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.750754 ± 0.142499 (W 0.00612658) | 1.39104 ± 0.0274466 (W 0.00592332) | 🔵 fork 1.85× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 17.0068 ± 0.133348 (W 0.0941311) | 54.5652 ± 0.319555 (W 0.23616) | 🔵 fork 3.21× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.78464 ± 0.137527 (W 0.00654721) | 1.07764 ± 0.0171293 (W 0.00282897) | 🔵 fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/256x4096/b1` | 77.0832 ± 0.200445 (W 0.184707) | 389.383 ± 1.10889 (W 2.10838) | 🔵 fork 5.05× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.80573 ± 0.023087 (W 0.0250205) | 9.79716 ± 0.151999 (W 0.0607847) | 🔵 fork 2.57× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 47.7464 ± 0.222953 (W 0.144776) | 202.764 ± 1.78293 (W 0.577357) | 🔵 fork 4.25× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.55586 ± 0.0117393 (W 0.0197076) | 5.10819 ± 0.0344513 (W 0.0274803) | 🔵 fork 2.00× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 229.475 ± 4.9281 (W 0.967174) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.30558 ± 0.0252256 (W 0.00760386) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.0936 ± 0.101097 (W 0.0589756) | 55.91 ± 0.049433 (W 0.0457965) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.896627 ± 0.00288676 (W 0.00198417) | 1.26611 ± 0.00355144 (W 0.00272837) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 102.485 ± 0.584924 (W 0.21651) | 184.891 ± 1.61068 (W 2.66765) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.40944 ± 0.00593533 (W 0.00344375) | 3.78368 ± 0.0181942 (W 0.0162329) | 🔵 fork 1.57× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 95.7853 ± 0.338535 (W 0.361457) | 149.22 ± 2.83804 (W 1.81515) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.22123 ± 0.00654599 (W 0.00284872) | 2.98222 ± 0.0404602 (W 0.00445889) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 281.241 ± 0.406241 (W 0.361654) | 655.953 ± 3.46853 (W 1.90844) | 🔵 fork 2.33× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 6.04669 ± 0.0241299 (W 0.011193) | 11.2185 ± 0.247064 (W 0.0241874) | 🔵 fork 1.86× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/256x4096/b1` | 122.881 ± 1.03876 (W 0.199054) | 289.392 ± 0.748638 (W 1.64127) | 🔵 fork 2.36× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 3.08386 ± 0.0145475 (W 0.00357074) | 5.26746 ± 0.0616893 (W 0.01982) | 🔵 fork 1.71× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.742 ± 1.95318 (W 0.727592) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.32464 ± 0.0329128 (W 0.00750098) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.8804 ± 0.0433757 (W 0.0546532) | 30.4522 ± 0.0949119 (W 0.0371796) | 🔵 fork 2.19× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.326214 ± 0.00194379 (W 0.00489543) | 0.799617 ± 0.00209268 (W 0.00262706) | 🔵 fork 2.45× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 29.0395 ± 0.338074 (W 0.12032) | 75.5952 ± 3.59959 (W 0.42719) | 🔵 fork 2.60× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.877306 ± 0.0132114 (W 0.00537248) | 1.53161 ± 0.0641878 (W 0.0259012) | 🔵 fork 1.75× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 25.9704 ± 0.164968 (W 0.123665) | 54.2554 ± 0.39704 (W 0.118433) | 🔵 fork 2.09× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.703863 ± 0.0115649 (W 0.00355226) | 0.997018 ± 0.00446422 (W 0.00231561) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 116.253 ± 0.440538 (W 0.552209) | 399.81 ± 3.04295 (W 0.5661) | 🔵 fork 3.44× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.13086 ± 0.0502051 (W 0.104956) | 9.22623 ± 0.0911474 (W 0.0213851) | 🔵 fork 2.23× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 67.6021 ± 0.171495 (W 0.301468) | 201.2 ± 1.57585 (W 0.354739) | 🔵 fork 2.98× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.7514 ± 0.071303 (W 0.0931929) | 4.69554 ± 0.0568278 (W 0.0150476) | 🔵 fork 1.71× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 66.3612 ± 0.660578 (W 0.412577) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.29871 ± 0.0314778 (W 0.0101557) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.31839 ± 0.0224755 (W 0.0384591) | 23.6769 ± 0.0652605 (W 0.0155984) | 🔵 fork 2.85× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.242592 ± 0.00240584 (W 0.00459447) | 0.676686 ± 0.00180589 (W 0.00213645) | 🔵 fork 2.79× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 16.4152 ± 0.0739881 (W 0.0593302) | 56.7714 ± 0.306196 (W 0.240297) | 🔵 fork 3.46× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.64032 ± 0.00298311 (W 0.00283637) | 1.08812 ± 0.0702074 (W 0.0184987) | 🔵 fork 1.70× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 14.2315 ± 0.119453 (W 0.0385868) | 37.8139 ± 0.195281 (W 0.046591) | 🔵 fork 2.66× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.465681 ± 0.00133947 (W 0.0022217) | 0.72995 ± 0.00740765 (W 0.00265453) | 🔵 fork 1.57× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 89.6987 ± 0.270336 (W 0.435219) | 360.024 ± 1.95116 (W 0.68893) | 🔵 fork 4.01× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.924 ± 0.016386 (W 0.0269125) | 9.09325 ± 0.0885527 (W 0.0119776) | 🔵 fork 2.32× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 59.3284 ± 0.525104 (W 0.181291) | 184.867 ± 0.39157 (W 0.313156) | 🔵 fork 3.12× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.66635 ± 0.028209 (W 0.021545) | 4.69405 ± 0.0467982 (W 0.0133038) | 🔵 fork 1.76× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
