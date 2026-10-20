<!-- generated from data/results/zen5-cpu/faer-kernels/20261020T033243Z-pub2-50c2b98-openblas/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `50c2b989484f063f4e1b132adc333715391d8b73`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `4e2150bdae768e531629b9c8c22efa52d8c9219b`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `b10cf8c5bcfed8b5ebd08b9908ba0aaa003e270cc196c142002a6d604d92cccc`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-20T06:24:44.817807Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor openblas --engines faer-fork,lapack-openblas --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 6 --prime-ms 250 --label pub2-50c2b98-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels/20261020T033243Z-pub2-50c2b98-openblas/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.55%, worst 310.53% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 286 of 2328 engine cells exceed 5% and carry `!`; median within-process relative SD 0.46%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.0023545 ± 2.13604e-05 (W 2.84897e-05) | 0.002244 ± 4.1833e-06 (W 1.96896e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017102 ± 4.76393e-05 (W 2.83219e-05) | 0.0168715 ± 0.000112013 (W 3.97461e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056741 ± 0.000128779 (W 0.000103984) | 0.0563545 ± 0.000202534 (W 4.75946e-05) | · |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.00235 ± 1.25007e-05 (W 2.05312e-05) | 0.002234 ± 1.0328e-05 (W 2.04147e-05) | 🔴 fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0171215 ± 4.93113e-05 (W 3.25753e-05) | 0.016811 ± 2.88265e-05 (W 2.80361e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.068198 ± 0.00958917 (W 0.010646) | 0.0564595 ± 0.000142088 (W 9.18521e-05) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002329 ± 1.20665e-05 (W 1.83197e-05) | 0.002224 ± 1.16905e-05 (W 2.01317e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017207 ± 7.65517e-05 (W 3.33387e-05) | 0.016842 ± 4.65432e-05 (W 1.66658e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.029786 ± 0.000308041 (W 0.00160417) | 0.056359 ± 5.28886e-05 (W 5.88608e-05) | 🔵 fork 1.89× faster than `lapack-openblas` |  |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 1.42934e-05 (W 1.70036e-05) | 0.002234 ± 2.41695e-05 (W 2.29426e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017112 ± 3.52727e-05 (W 2.54108e-05) | 0.016841 ± 0.000139285 (W 2.03833e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056716 ± 8.71229e-05 (W 5.37863e-05) | 0.0564555 ± 0.00024026 (W 0.0010172) | · |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 1.39104e-05 (W 2.31842e-05) | 0.002224 ± 1.0328e-05 (W 2.18706e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017137 ± 5.49242e-05 (W 2.44915e-05) | 0.016832 ± 4.50955e-05 (W 2.93739e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0632675 ± 0.0103497 (W 0.0110259) | 0.05636 ± 0.000173544 (W 0.000688578) | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 2.59666e-05 (W 1.62295e-05) | 0.0022195 ± 1.67382e-05 (W 1.54377e-05) | 🔴 fork 1.06× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0171915 ± 0.000133102 (W 1.89443e-05) | 0.016842 ± 3.63176e-05 (W 2.3653e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0307275 ± 0.00111156 (W 0.0017398) | 0.05626 ± 0.000211141 (W 3.02082e-05) | 🔵 fork 1.83× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008831 ± 1.00747e-05 (W 1.9428e-05) | 0.011577 ± 5.34478e-05 (W 2.90326e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0677415 ± 5.22673e-05 (W 5.37647e-05) | 0.08604 ± 0.0002342 (W 0.000172772) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.227031 ± 0.000538341 (W 0.00136656) | 0.276569 ± 0.000579823 (W 0.00156352) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008822 ± 4.14122e-05 (W 2.02772e-05) | 0.0115865 ± 1.77088e-05 (W 3.41814e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.04038 ± 0.00435811 (W 0.00460729) | 0.026124 ± 0.000206893 (W 0.000401043) | 🔴 fork 1.55× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.0891805 ± 0.00448739 (W 0.00601883) | 0.0792125 ± 0.000198201 (W 0.00064259) | 🔴 fork 1.13× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088565 ± 7.35321e-05 (W 1.66789e-05) | 0.0116265 ± 2.60032e-05 (W 2.58e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.037404 ± 0.000979405 (W 0.00180882) | 0.025683 ± 0.000305157 (W 0.000159211) | 🔴 fork 1.46× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.050865 ± 0.000701958 (W 0.00156354) | 0.0551765 ± 0.000585605 (W 0.000303157) | 🔵 fork 1.08× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008857 ± 3.84573e-05 (W 1.72689e-05) | 0.0115865 ± 3.50452e-05 (W 3.46263e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0676855 ± 9.1987e-05 (W 5.2186e-05) | 0.0861205 ± 0.000248388 (W 0.000737775) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.226997 ± 0.00049078 (W 0.00136676) | 0.276229 ± 0.000515489 (W 0.00148565) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088165 ± 3.57253e-05 (W 2.90201e-05) | 0.0116115 ± 2.31293e-05 (W 3.59987e-05) | 🔵 fork 1.32× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0444475 ± 0.00436008 (W 0.00542024) | 0.0262045 ± 0.00011674 (W 0.000239742) | 🔴 fork 1.70× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.0935495 ± 0.00596067 (W 0.00673987) | 0.078962 ± 0.000416449 (W 0.000575007) | 🔴 fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008872 ± 5.01026e-05 (W 2.12828e-05) | 0.0116165 ± 4.11129e-05 (W 2.72112e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0369885 ± 0.000793196 (W 0.00170061) | 0.025587 ± 0.000312419 (W 0.000192089) | 🔴 fork 1.45× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.0512815 ± 0.000894622 (W 0.00201065) | 0.0550985 ± 0.000318627 (W 0.000165806) | 🔵 fork 1.07× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.134052 ± 0.000458103 (W 0.00127665) | 0.163459 ± 0.00079777 (W 0.00130267) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.45216 ± 0.00192475 (W 0.0020743) | 0.538339 ± 0.00207928 (W 0.00275269) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.08088 ± 0.00136534 (W 0.00159596) | 1.27017 ± 0.0087456 (W 0.0022679) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.62277 ± 0.0112917 (W 0.0066099) | 4.25705 ± 0.0129714 (W 0.00777576) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.61953 ± 0.0182347 (W 0.0174472) | 10.1115 ± 0.0459945 (W 0.0208522) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4898 ± 0.0436335 (W 0.0445044) | 33.9498 ± 0.13889 (W 0.0453422) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0816425 ± 0.0098217 (W 0.0183208) | 0.050369 ± 0.000692111 (W 0.000631316) | 🔴 fork 1.62× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.152362 ± 0.0120439 (W 0.016784) | 0.149794 ± 0.000575337 (W 0.00160116) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.301202 ± 0.0047218 (W 0.00329584) | 0.34407 ± 0.000748855 (W 0.00195796) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.934281 ± 0.002832 (W 0.00463867) | 1.10366 ± 0.00408437 (W 0.00350331) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.23685 ± 0.00652823 (W 0.00897364) | 2.59219 ± 0.00380032 (W 0.00297607) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.54308 ± 0.0115515 (W 0.0085573) | 8.73883 ± 0.010672 (W 0.0167371) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0801985 ± 0.00731445 (W 0.0250957) | 0.028398 ± 0.00141384 (W 0.000481693) | 🔴 fork 2.82× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.17206 ± 0.0226965 (W 0.0349525) | 0.0841415 ± 0.00171314 (W 0.000672318) | 🔴 fork 2.04× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.218709 ± 0.00674981 (W 0.03179) | 0.181491 ± 0.00169508 (W 0.0016787) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.56205 ± 0.00393842 (W 0.00827142) | 0.555205 ± 0.00213854 (W 0.00226145) | · |  |
| `gemm/512x512x512/b1` | 1.20385 ± 0.010994 (W 0.0129559) | 1.31515 ± 0.00543122 (W 0.00204875) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.94092 ± 0.00915132 (W 0.0120661) | 4.56189 ± 0.0306442 (W 0.0111057) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.134212 ± 0.000593154 (W 0.000134985) | 0.163295 ± 0.000900093 (W 0.00123332) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.452087 ± 0.00225468 (W 0.00208698) | 0.539991 ± 0.00144967 (W 0.00216431) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.08103 ± 0.00527107 (W 0.00263623) | 1.27271 ± 0.00553463 (W 0.00305448) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.62214 ± 0.0114816 (W 0.00281622) | 4.25268 ± 0.022596 (W 0.00537522) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.59881 ± 0.0396854 (W 0.0172981) | 10.0859 ± 0.00925523 (W 0.0189997) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4452 ± 0.0705145 (W 0.0412178) | 33.9313 ± 0.124838 (W 0.0517211) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.074609 ± 0.0169287 (W 0.0172737) | 0.0501035 ± 0.000708404 (W 0.000855793) | 🔴 fork 1.49× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.142082 ± 0.0102027 (W 0.0161719) | 0.148934 ± 0.000873159 (W 0.00169316) | · | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.300589 ± 0.00440836 (W 0.00310918) | 0.343762 ± 0.00112581 (W 0.00258294) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.931749 ± 0.0019976 (W 0.00473579) | 1.10259 ± 0.00392253 (W 0.00351104) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.24108 ± 0.00753456 (W 0.00605443) | 2.58966 ± 0.00792022 (W 0.00408727) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.53732 ± 0.00549323 (W 0.0178566) | 8.73097 ± 0.00759977 (W 0.0183856) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.083035 ± 0.0199179 (W 0.0239898) | 0.028859 ± 0.00152558 (W 0.000212439) | 🔴 fork 2.88× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.187457 ± 0.0201436 (W 0.0298487) | 0.0820015 ± 0.000371429 (W 0.00027624) | 🔴 fork 2.29× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.214755 ± 0.0214351 (W 0.0306582) | 0.179326 ± 0.00124662 (W 0.0017058) | 🔴 fork 1.20× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.563998 ± 0.0127364 (W 0.0150707) | 0.554052 ± 0.00285927 (W 0.00219546) | · | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 1.19702 ± 0.0106338 (W 0.0103379) | 1.31623 ± 0.00645724 (W 0.00345506) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.93275 ± 0.00995498 (W 0.0190285) | 4.56087 ± 0.0125371 (W 0.0196842) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539555 ± 0.00241767 (W 0.00244108) | 0.65935 ± 0.000493352 (W 0.0019144) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81449 ± 0.00916808 (W 0.00196941) | 2.18071 ± 0.00411085 (W 0.00254947) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28907 ± 0.00933134 (W 0.0023286) | 5.18779 ± 0.0064505 (W 0.00746654) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4786 ± 0.0200771 (W 0.017876) | 17.344 ± 0.725235 (W 0.0290881) | 🔵 fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 34.3692 ± 0.0224905 (W 0.0259326) | 41.0688 ± 0.0279115 (W 0.0445823) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.768 ± 0.0617164 (W 0.0661873) | 137.76 ± 0.100079 (W 0.223958) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.161137 ± 0.00112099 (W 0.005208) | 0.178155 ± 0.000271201 (W 0.00144292) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.476932 ± 0.00537236 (W 0.00422032) | 0.560957 ± 0.000870218 (W 0.00182531) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.13089 ± 0.00354328 (W 0.00374509) | 1.33302 ± 0.0072636 (W 0.0031159) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.67721 ± 0.00700664 (W 0.00480308) | 4.40605 ± 0.00794129 (W 0.00365719) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.73773 ± 0.0216941 (W 0.0166751) | 10.4426 ± 0.02536 (W 0.00740477) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4768 ± 0.0308452 (W 0.0161647) | 34.9554 ± 0.0267996 (W 0.0220103) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.115941 ± 0.0112051 (W 0.0122505) | 0.0933045 ± 0.000383627 (W 0.000168767) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.27457 ± 0.00838585 (W 0.0149528) | 0.295585 ± 0.00122667 (W 0.00194014) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.60545 ± 0.00282967 (W 0.00863946) | 0.685079 ± 0.031957 (W 0.00227824) | 🔵 fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 1.87638 ± 0.00630529 (W 0.00797666) | 2.20123 ± 0.00370531 (W 0.00357325) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.51245 ± 0.0104485 (W 0.0121035) | 5.27212 ± 0.0122069 (W 0.0097976) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 14.9785 ± 0.0154391 (W 0.0262807) | 17.7669 ± 0.0493478 (W 0.0143611) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.540461 ± 0.00259056 (W 0.00205763) | 0.660775 ± 0.00225082 (W 0.00258636) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81943 ± 0.00943189 (W 0.00461143) | 2.18016 ± 0.00539258 (W 0.00235254) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28789 ± 0.00568291 (W 0.00298067) | 5.17968 ± 0.00612692 (W 0.0116651) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4854 ± 0.0355749 (W 0.025847) | 17.3527 ± 0.0219691 (W 0.0239177) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3633 ± 0.0281139 (W 0.0464957) | 41.0505 ± 0.0693637 (W 0.0501488) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.602 ± 0.10119 (W 0.0928235) | 137.846 ± 0.155156 (W 0.10938) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160653 ± 0.00639265 (W 0.00603934) | 0.178603 ± 0.000818521 (W 0.0015581) | 🔵 fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.476107 ± 0.00199741 (W 0.00155882) | 0.560569 ± 0.00109365 (W 0.00190433) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.12959 ± 0.00220034 (W 0.00342979) | 1.33565 ± 0.00685736 (W 0.00251935) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.67296 ± 0.00843283 (W 0.0108355) | 4.39447 ± 0.00819068 (W 0.00847107) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.7092 ± 0.0168694 (W 0.0137346) | 10.4433 ± 0.0261641 (W 0.00970415) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4823 ± 0.0348179 (W 0.0833427) | 34.8879 ± 0.0598291 (W 0.0123711) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.11573 ± 0.00374564 (W 0.0129755) | 0.093383 ± 0.001682 (W 0.000955229) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.274492 ± 0.00488938 (W 0.00945588) | 0.295483 ± 0.000743551 (W 0.00206347) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.608234 ± 0.0321573 (W 0.00680216) | 0.681604 ± 0.00188645 (W 0.00217603) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 1.87179 ± 0.0203893 (W 0.00641574) | 2.20078 ± 0.00244876 (W 0.00218231) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.51619 ± 0.00998892 (W 0.0105917) | 5.26593 ± 0.00388956 (W 0.00941296) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 14.9671 ± 0.0100268 (W 0.0362149) | 17.783 ± 0.0164023 (W 0.0149006) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.27289 ± 0.00312405 (W 0.00484058) | 1.64299 ± 0.0257841 (W 0.0033819) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.07476 ± 0.00996367 (W 0.00525876) | 1.46763 ± 0.00707161 (W 0.00804897) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.0904 ± 0.00407129 (W 0.00191393) | 1.36824 ± 0.00184363 (W 0.00539637) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.439405 ± 0.00285058 (W 0.00436413) | 0.500453 ± 0.0126793 (W 0.00533364) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.332901 ± 0.00226799 (W 0.0030645) | 0.47898 ± 0.00131275 (W 0.00272737) | 🔵 fork 1.44× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.310101 ± 0.0109416 (W 0.00954574) | 0.348268 ± 0.000973358 (W 0.00182394) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.439292 ± 0.00549481 (W 0.00639463) | 0.278568 ± 0.00742656 (W 0.00409895) | 🔴 fork 1.58× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.202181 ± 0.0091663 (W 0.00337547) | 0.312406 ± 0.00172795 (W 0.00194387) | 🔵 fork 1.55× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.196856 ± 0.0131586 (W 0.0168399) | 0.179004 ± 0.000340466 (W 0.00134001) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.04766 ± 0.0136853 (W 0.00245087) | 1.70117 ± 0.00929284 (W 0.00512219) | 🔵 fork 1.62× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.0975 ± 0.0164196 (W 0.00773874) | 1.41567 ± 0.020842 (W 0.005866) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.13107 ± 0.00722737 (W 0.00326001) | 1.37099 ± 0.00704255 (W 0.00422824) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.695362 ± 0.0135755 (W 0.020458) | 0.425876 ± 0.00442369 (W 0.00306079) | 🔴 fork 1.63× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.320496 ± 0.00233142 (W 0.00312319) | 0.485748 ± 0.0016223 (W 0.00284667) | 🔵 fork 1.52× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.313263 ± 0.000643317 (W 0.0046499) | 0.36505 ± 0.00163509 (W 0.001811) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.13621 ± 0.010437 (W 0.019956) | 0.223307 ± 0.00144872 (W 0.0024828) | 🔴 fork 5.09× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.199157 ± 0.00403967 (W 0.00340101) | 0.321562 ± 0.00295314 (W 0.00206551) | 🔵 fork 1.61× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.180972 ± 0.00103702 (W 0.00325638) | 0.196028 ± 0.00168035 (W 0.00188822) | 🔵 fork 1.08× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.16855 ± 0.016899 (W 0.00825521) | 6.01884 ± 0.0203588 (W 0.014274) | 🔵 fork 1.44× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.39275 ± 0.054604 (W 0.00982641) | 5.78308 ± 0.0201522 (W 0.020469) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.40892 ± 0.0154121 (W 0.0117906) | 5.43426 ± 0.0162901 (W 0.0123299) | 🔵 fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.68324 ± 0.0148379 (W 0.00272769) | 1.75339 ± 0.010031 (W 0.00506616) | · |  |
| `gemm/4096x16x240/b1` | 1.20919 ± 0.00381835 (W 0.00622467) | 1.6866 ± 0.0124171 (W 0.0033785) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.15476 ± 0.00527122 (W 0.00513721) | 1.38929 ± 0.00248704 (W 0.00366239) | 🔵 fork 1.20× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.922359 ± 0.0113738 (W 0.0054076) | 0.939323 ± 0.00731225 (W 0.00412137) | · |  |
| `gemm/4096x16x240/b1` | 0.640213 ± 0.00513002 (W 0.00405807) | 1.00121 ± 0.00121253 (W 0.0158903) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.606781 ± 0.00306938 (W 0.00343698) | 0.698701 ± 0.0310481 (W 0.00321397) | 🔵 fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07987 ± 0.00874498 (W 0.00862805) | 5.82741 ± 0.0266151 (W 0.020253) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.40127 ± 0.0303349 (W 0.0123587) | 5.80152 ± 0.011839 (W 0.0154445) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.46049 ± 0.0165849 (W 0.0107652) | 5.56798 ± 0.0128675 (W 0.00778225) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.93925 ± 0.0122412 (W 0.0364012) | 1.50887 ± 0.00351086 (W 0.00311068) | 🔴 fork 1.29× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.20675 ± 0.00403548 (W 0.00755631) | 1.75457 ± 0.068439 (W 0.00474043) | 🔵 fork 1.45× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.20189 ± 0.0066564 (W 0.0065149) | 1.46091 ± 0.00199771 (W 0.00576621) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.55015 ± 0.0305003 (W 0.0501272) | 0.829534 ± 0.0470658 (W 0.0074449) | 🔴 fork 3.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.643745 ± 0.00565365 (W 0.00459818) | 1.00981 ± 0.00324711 (W 0.0150042) | 🔵 fork 1.57× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.615173 ± 0.00345516 (W 0.00634224) | 0.770509 ± 0.00309835 (W 0.00374285) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12838 ± 0.00400332 (W 0.00353471) | 1.3766 ± 0.00637953 (W 0.00244268) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.314107 ± 0.00297905 (W 0.00457408) | 0.366526 ± 0.0013075 (W 0.002082) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.179033 ± 0.00210432 (W 0.00448461) | 0.196356 ± 0.00242481 (W 0.00165092) | 🔵 fork 1.10× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08609 ± 0.00741794 (W 0.00151711) | 1.37185 ± 0.00475711 (W 0.00289282) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.309947 ± 0.0023196 (W 0.00869609) | 0.346927 ± 0.00137386 (W 0.00180478) | 🔵 fork 1.12× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.201035 ± 0.019953 (W 0.0240032) | 0.178828 ± 0.000542196 (W 0.00156268) | 🔴 fork 1.12× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.45034 ± 0.00788578 (W 0.0118343) | 5.56775 ± 0.00592993 (W 0.0145977) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.20947 ± 0.01122 (W 0.0073395) | 1.45809 ± 0.00402681 (W 0.00492376) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.618189 ± 0.00432493 (W 0.00473865) | 0.777821 ± 0.00966915 (W 0.0043396) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.40062 ± 0.0250632 (W 0.0126071) | 5.43044 ± 0.0167281 (W 0.0155954) | 🔵 fork 1.23× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.15713 ± 0.00636589 (W 0.00310399) | 1.39227 ± 0.00899382 (W 0.00367079) | 🔵 fork 1.20× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.607217 ± 0.00350494 (W 0.00472805) | 0.69965 ± 0.00120785 (W 0.00381701) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003151 ± 8.33667e-06 (W 2.59712e-05) | 0.0040675 ± 9.95269e-05 (W 3.87562e-05) | 🔵 fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0148275 ± 8.17411e-05 (W 3.37762e-05) | 0.017959 ± 0.000448233 (W 7.67252e-05) | 🔵 fork 1.21× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030727 ± 0.000167362 (W 8.32148e-05) | 0.043636 ± 0.000969141 (W 0.000162445) | 🔵 fork 1.42× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113958 ± 0.000539174 (W 0.000783239) | 0.119844 ± 0.000612905 (W 0.00147608) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.489055 ± 0.00120286 (W 0.00196969) | 0.433783 ± 0.00337297 (W 0.00168646) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.16367 ± 0.00431852 (W 0.0017859) | 0.950012 ± 0.00320328 (W 0.0011391) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0118925 ± 0.000152559 (W 5.06913e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0521075 ± 0.000347242 (W 0.000190933) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.147436 ± 0.00149077 (W 0.00254845) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0083655 ± 6.91773e-05 (W 4.02975e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008411 ± 6.3692e-05 (W 3.79826e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040856 ± 7.76677e-05 (W 9.43111e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.041117 ± 0.000187544 (W 9.3219e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.121911 ± 0.000538715 (W 0.00200165) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.122163 ± 0.000339378 (W 0.000240334) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0089865 ± 8.06986e-05 (W 6.1496e-05) | 0.0095475 ± 0.000185063 (W 6.57592e-05) | 🔵 fork 1.06× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031979 ± 0.00014098 (W 0.000142573) | 0.0370185 ± 0.000593088 (W 7.88692e-05) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0801795 ± 0.00138623 (W 0.00236112) | 0.0957185 ± 0.000845898 (W 0.00227682) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0333475 ± 0.000202268 (W 0.000113224) | 0.0323755 ± 0.000195603 (W 0.000127136) | · |  |
| `qr/n64/b1` | 0.123033 ± 0.000540517 (W 0.00152891) | 0.128259 ± 0.000994764 (W 0.000517696) | · |  |
| `qr/n96/b1` | 0.294838 ± 0.00987617 (W 0.00351959) | 0.371134 ± 0.00262825 (W 0.00275093) | 🔵 fork 1.26× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023944 ± 0.000208577 (W 8.66086e-05) | 0.0173875 ± 0.000223917 (W 8.16143e-05) | 🔴 fork 1.38× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.0895865 ± 0.000321838 (W 0.00129645) | 0.0662385 ± 0.000772243 (W 0.0011928) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.196898 ± 0.000947562 (W 0.00151127) | 0.184507 ± 0.00132 (W 0.00165783) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.010004 ± 6.35788e-05 (W 5.39862e-05) | 0.009863 ± 0.000126642 (W 4.53896e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0329615 ± 0.000250621 (W 0.000145863) | 0.037469 ± 0.00053421 (W 9.0648e-05) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.080484 ± 0.00038439 (W 0.00186675) | 0.088264 ± 0.00100692 (W 0.000212388) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183644 ± 0.000847645 (W 0.00141626) | 0.184388 ± 0.00115306 (W 0.00154256) | · |  |
| `svd_thin/n64/b1` | 0.921078 ± 0.00485835 (W 0.00157882) | 0.67501 ± 0.00352832 (W 0.0038995) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.1978 ± 0.0332174 (W 0.00211054) | 1.60988 ± 0.010247 (W 0.00470681) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140651 ± 0.000834532 (W 0.000706918) | 0.078666 ± 0.000348525 (W 0.000148442) | 🔴 fork 1.79× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.519325 ± 0.00156465 (W 0.00178578) | 0.275838 ± 0.00182656 (W 0.00169355) | 🔴 fork 1.88× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19036 ± 0.00269609 (W 0.00190652) | 0.666783 ± 0.00143138 (W 0.00187426) | 🔴 fork 1.79× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0006765 ± 1.82647e-05 (W 1.13789e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001488 ± 2.11699e-05 (W 1.71442e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00261 ± 4.91952e-05 (W 3.13261e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003141 ± 3.68782e-05 (W 2.04551e-05) | 0.0039925 ± 6.4495e-05 (W 3.10048e-05) | 🔵 fork 1.27× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0146925 ± 0.00105531 (W 5.90891e-05) | 0.017648 ± 0.000120914 (W 0.000100483) | 🔵 fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0477035 ± 0.0020193 (W 0.00295231) | 0.0432555 ± 0.000287446 (W 0.000850933) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113936 ± 0.000455083 (W 0.000257815) | 0.103393 ± 0.000291352 (W 0.00131635) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.504085 ± 0.00437822 (W 0.00319979) | 0.353277 ± 0.000818847 (W 0.00153736) | 🔴 fork 1.43× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.22233 ± 0.00693696 (W 0.0227149) | 0.760063 ± 0.00116898 (W 0.00163597) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0119875 ± 6.7337e-05 (W 5.10362e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0518915 ± 0.000234734 (W 0.000183518) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145826 ± 0.000534017 (W 0.00246321) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.00831 ± 3.82296e-05 (W 4.59914e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0083205 ± 2.90218e-05 (W 3.80057e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.024932 ± 0.000461634 (W 0.000925663) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0252915 ± 0.000516802 (W 0.000647956) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0499375 ± 0.000299501 (W 0.000917661) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.050289 ± 0.000650401 (W 0.000869799) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008957 ± 8.23205e-05 (W 0.000106987) | 0.0095175 ± 0.00014446 (W 0.000114583) | 🔵 fork 1.06× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031949 ± 0.00017098 (W 0.000171701) | 0.0376105 ± 0.000437014 (W 0.000142758) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0783565 ± 0.000667604 (W 0.00118042) | 0.0919865 ± 0.00348853 (W 0.00171496) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.0332975 ± 0.000240151 (W 0.000140764) | 0.0323405 ± 0.000481395 (W 0.000127426) | · |  |
| `qr/n64/b1` | 0.176083 ± 0.00971491 (W 0.00272353) | 0.129125 ± 0.00101167 (W 0.00157204) | 🔴 fork 1.36× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.402832 ± 0.022431 (W 0.0264273) | 0.364777 ± 0.00170669 (W 0.0017367) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0236545 ± 0.000173744 (W 8.62646e-05) | 0.0173175 ± 0.000323943 (W 7.71399e-05) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.118662 ± 0.0127546 (W 0.00510107) | 0.0654315 ± 0.000939709 (W 0.000290399) | 🔴 fork 1.81× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.225977 ± 0.00966918 (W 0.00712202) | 0.182955 ± 0.0016799 (W 0.00143714) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009883 ± 6.86549e-05 (W 8.16954e-05) | 0.0098335 ± 0.000167369 (W 4.56334e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033202 ± 0.00031268 (W 0.0012762) | 0.0366325 ± 0.000574684 (W 4.87448e-05) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.080545 ± 0.00107635 (W 0.00295963) | 0.0868465 ± 0.000818914 (W 0.000197481) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183443 ± 0.00851118 (W 0.00128264) | 0.181515 ± 0.00118199 (W 0.00160224) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.952322 ± 0.0087934 (W 0.00346466) | 0.634292 ± 0.00283036 (W 0.00231763) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.34444 ± 0.0128744 (W 0.0243032) | 1.47181 ± 0.00247853 (W 0.00198294) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140753 ± 0.000291941 (W 0.00155203) | 0.07791 ± 0.000437518 (W 0.000753907) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.52079 ± 0.00139798 (W 0.00231673) | 0.274979 ± 0.00163675 (W 0.00203045) | 🔴 fork 1.89× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19625 ± 0.00449975 (W 0.00179621) | 0.657776 ± 0.00177455 (W 0.00188965) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000681 ± 5.30723e-06 (W 1.28373e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0015275 ± 2.07886e-05 (W 1.53251e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0026245 ± 6.69938e-05 (W 3.68527e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003161 ± 3.617e-05 (W 3.04534e-05) | 0.004027 ± 6.74112e-05 (W 4.77836e-05) | 🔵 fork 1.27× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014747 ± 0.00136916 (W 6.64971e-05) | 0.017618 ± 0.000484773 (W 0.000110355) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.055779 ± 0.0033595 (W 0.0030015) | 0.0429055 ± 0.000215918 (W 0.000156429) | 🔴 fork 1.30× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.114134 ± 0.000431988 (W 0.00155653) | 0.101576 ± 0.000498499 (W 0.000171617) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.512829 ± 0.00198338 (W 0.00433303) | 0.345601 ± 0.00100062 (W 0.00115038) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.2548 ± 0.0110367 (W 0.0166874) | 0.740032 ± 0.00192199 (W 0.00169384) | 🔴 fork 1.70× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0120575 ± 0.000129508 (W 3.40065e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.052393 ± 0.00040299 (W 0.000227327) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145916 ± 0.000466516 (W 0.0020691) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008346 ± 3.72581e-05 (W 4.04881e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.00839 ± 9.6507e-05 (W 4.47916e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020904 ± 0.00391916 (W 0.000647723) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020648 ± 0.000444507 (W 0.000700682) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.038246 ± 0.000438901 (W 0.000782085) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.038311 ± 0.000412971 (W 0.000773822) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0089865 ± 0.000116666 (W 9.0089e-05) | 0.0094675 ± 0.000188807 (W 0.000106918) | 🔵 fork 1.05× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.032135 ± 0.000160332 (W 0.000197228) | 0.0374145 ± 0.000559027 (W 0.000177538) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.078195 ± 0.000165834 (W 0.00174467) | 0.092708 ± 0.00306095 (W 0.00102615) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.033117 ± 0.000157048 (W 0.000117113) | 0.03215 ± 0.000236798 (W 0.000112324) | · |  |
| `qr/n64/b1` | 0.164029 ± 0.0116179 (W 0.00292639) | 0.128087 ± 0.0013079 (W 0.000843988) | 🔴 fork 1.28× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.411735 ± 0.00980491 (W 0.0295534) | 0.365756 ± 0.00186047 (W 0.00200931) | 🔴 fork 1.13× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0238395 ± 0.00018391 (W 8.70106e-05) | 0.017197 ± 0.000157023 (W 0.000123771) | 🔴 fork 1.39× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.113432 ± 0.000869982 (W 0.00222201) | 0.065016 ± 0.000210705 (W 0.000319378) | 🔴 fork 1.74× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.220255 ± 0.0112753 (W 0.00534485) | 0.183565 ± 0.00127148 (W 0.00131226) | 🔴 fork 1.20× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009858 ± 7.97088e-05 (W 5.334e-05) | 0.009788 ± 9.87801e-05 (W 4.50121e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0330065 ± 0.000537714 (W 0.000116096) | 0.036708 ± 0.000402307 (W 9.7791e-05) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0804 ± 0.000773128 (W 0.00241341) | 0.087012 ± 0.000726615 (W 0.00156874) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.182825 ± 0.000243276 (W 0.00157502) | 0.182231 ± 0.00106289 (W 0.00152057) | · |  |
| `svd_thin/n64/b1` | 0.965888 ± 0.00710492 (W 0.00276284) | 0.635034 ± 0.00283145 (W 0.00185347) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.36177 ± 0.00851374 (W 0.0244922) | 1.47613 ± 0.00302371 (W 0.00251884) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140511 ± 0.000289958 (W 0.000823386) | 0.077696 ± 0.000418069 (W 0.000740205) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.521891 ± 0.00172196 (W 0.00227101) | 0.273068 ± 0.000804758 (W 0.00168426) | 🔴 fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18783 ± 0.00385605 (W 0.00293563) | 0.656446 ± 0.00120485 (W 0.00181741) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000681 ± 1.83712e-05 (W 2.01743e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001488 ± 2.97349e-05 (W 1.90535e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002565 ± 2.71416e-05 (W 3.18575e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0030605 ± 1.0015e-05 (W 2.76514e-05) | 0.003471 ± 9.16639e-05 (W 2.93803e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014492 ± 6.43708e-05 (W 4.36465e-05) | 0.015158 ± 0.000180838 (W 7.65549e-05) | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.029966 ± 9.38092e-05 (W 5.72408e-05) | 0.036939 ± 0.000173535 (W 8.21402e-05) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.114107 ± 0.000448666 (W 0.000789282) | 0.119022 ± 0.000444047 (W 0.000197884) | · |  |
| `eigh/n64/b1` | 0.487983 ± 0.00108111 (W 0.00182758) | 0.428302 ± 0.00169525 (W 0.00187138) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.16838 ± 0.00696282 (W 0.00234677) | 0.938594 ± 0.00159321 (W 0.00144261) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010099 ± 0.000107083 (W 3.82513e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045345 ± 0.000252243 (W 0.000145116) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132728 ± 0.00104186 (W 0.00268498) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0084455 ± 5.48112e-05 (W 4.98726e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008526 ± 7.48343e-05 (W 5.34623e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0405365 ± 7.04348e-05 (W 8.22366e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0405965 ± 0.000167041 (W 7.41279e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.124272 ± 0.00057996 (W 0.0015929) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.1239 ± 0.000619315 (W 0.000920738) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007168 ± 7.18909e-05 (W 4.98059e-05) | 0.0082905 ± 5.20986e-05 (W 8.53741e-05) | 🔵 fork 1.16× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025628 ± 0.000180221 (W 0.000154193) | 0.032946 ± 0.000602808 (W 0.000151327) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.065132 ± 0.00156612 (W 0.00228776) | 0.077043 ± 0.000474488 (W 0.000134967) | 🔵 fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.0313785 ± 0.000140557 (W 0.000176354) | 0.0301215 ± 0.000267403 (W 7.90288e-05) | · |  |
| `qr/n64/b1` | 0.114698 ± 0.000623084 (W 0.000827257) | 0.120339 ± 0.000772189 (W 0.00180985) | · |  |
| `qr/n96/b1` | 0.280034 ± 0.00892261 (W 0.00351099) | 0.340743 ± 0.00421185 (W 0.0017989) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017708 ± 0.000238651 (W 7.5508e-05) | 0.0162305 ± 0.000175921 (W 8.13735e-05) | 🔴 fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.073772 ± 0.000318605 (W 0.000288391) | 0.061114 ± 0.0016963 (W 0.000193506) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.16232 ± 0.0011105 (W 0.00145709) | 0.1713 ± 0.00172187 (W 0.00153451) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.00797 ± 7.55645e-05 (W 7.62402e-05) | 0.0085755 ± 5.00816e-05 (W 4.72997e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0261335 ± 0.000218483 (W 0.000710994) | 0.03262 ± 0.000333912 (W 0.000140222) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0655465 ± 0.000317988 (W 0.00260038) | 0.076106 ± 0.000377761 (W 0.000160481) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.184964 ± 0.000927683 (W 0.00120977) | 0.178109 ± 0.000586682 (W 0.00147784) | · |  |
| `svd_thin/n64/b1` | 0.964624 ± 0.0062059 (W 0.00137845) | 0.636263 ± 0.00209318 (W 0.0017194) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.16399 ± 0.00905247 (W 0.00207902) | 1.47744 ± 0.00246173 (W 0.00337543) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.142205 ± 0.000415364 (W 0.00133667) | 0.0748735 ± 0.000487898 (W 0.000125374) | 🔴 fork 1.90× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.5401 ± 0.00188836 (W 0.00181083) | 0.270572 ± 0.00289773 (W 0.00189918) | 🔴 fork 2.00× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19547 ± 0.00190566 (W 0.00258059) | 0.663251 ± 0.00308578 (W 0.00190569) | 🔴 fork 1.80× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007465 ± 1.62573e-05 (W 1.60578e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0017035 ± 1.4148e-05 (W 1.50221e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0029705 ± 8.11848e-05 (W 2.22013e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0030305 ± 0.000130362 (W 3.22551e-05) | 0.003341 ± 3.17516e-05 (W 4.28815e-05) | 🔵 fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014402 ± 0.00135369 (W 5.37543e-05) | 0.015013 ± 0.000118714 (W 5.91578e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0482505 ± 0.000933778 (W 0.00302279) | 0.0364835 ± 0.000211913 (W 9.32522e-05) | 🔴 fork 1.32× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113591 ± 0.000448923 (W 0.00166572) | 0.1022 ± 0.000193649 (W 0.000177609) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.50586 ± 0.00207388 (W 0.00350786) | 0.349606 ± 0.00107317 (W 0.00151413) | 🔴 fork 1.45× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.22038 ± 0.00441009 (W 0.0232349) | 0.75115 ± 0.00212117 (W 0.00164612) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010119 ± 0.000175059 (W 5.08815e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0454045 ± 0.000464857 (W 0.000379152) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132146 ± 0.00107775 (W 0.00235007) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0084405 ± 6.22267e-05 (W 7.58823e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008506 ± 4.49073e-05 (W 5.53637e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.03496 ± 0.00269585 (W 0.00281484) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0352655 ± 0.000174514 (W 0.00250189) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.060407 ± 0.000155015 (W 0.00305273) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060608 ± 0.000548741 (W 0.00237914) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007119 ± 0.000122356 (W 4.59164e-05) | 0.0083405 ± 9.98674e-05 (W 9.70062e-05) | 🔵 fork 1.17× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025658 ± 0.000231116 (W 0.0001909) | 0.032871 ± 0.000188277 (W 0.000107016) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0635185 ± 0.000983252 (W 0.00223649) | 0.076398 ± 0.000284366 (W 0.00149228) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0313485 ± 0.000201157 (W 0.000154301) | 0.0297555 ± 0.000367075 (W 0.000136888) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.147985 ± 0.00596649 (W 0.00185592) | 0.118357 ± 0.000688939 (W 0.000814442) | 🔴 fork 1.25× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.387 ± 0.0190663 (W 0.0250951) | 0.340332 ± 0.00305969 (W 0.0018055) | 🔴 fork 1.14× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017618 ± 9.26148e-05 (W 0.000700455) | 0.01603 ± 0.000324342 (W 0.000107259) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.102878 ± 0.00725896 (W 0.00557689) | 0.060838 ± 0.0004195 (W 0.000844166) | 🔴 fork 1.69× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.198966 ± 0.0157077 (W 0.0134285) | 0.17199 ± 0.00120005 (W 0.00125636) | 🔴 fork 1.16× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.0078595 ± 9.29745e-05 (W 4.24838e-05) | 0.0084705 ± 3.34006e-05 (W 8.19697e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026024 ± 0.000291926 (W 0.000147244) | 0.0320895 ± 0.000169588 (W 8.59722e-05) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0656315 ± 0.00127541 (W 0.00205373) | 0.0756455 ± 0.000432206 (W 0.000100472) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.184665 ± 0.00786082 (W 0.00153336) | 0.174947 ± 0.000921108 (W 0.00154973) | 🔴 fork 1.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.99684 ± 0.00470458 (W 0.00244036) | 0.616762 ± 0.00222794 (W 0.00249276) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.27898 ± 0.0113389 (W 0.0138516) | 1.44174 ± 0.00359201 (W 0.00208074) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.142184 ± 0.000268644 (W 0.00174771) | 0.0741435 ± 0.000254596 (W 0.0001287) | 🔴 fork 1.92× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.540541 ± 0.00212834 (W 0.00190099) | 0.268753 ± 0.00124288 (W 0.00166791) | 🔴 fork 2.01× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19998 ± 0.00564819 (W 0.00180474) | 0.654901 ± 0.00244929 (W 0.00169748) | 🔴 fork 1.83× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007465 ± 1.61741e-05 (W 1.32286e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0017085 ± 1.52414e-05 (W 1.31152e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00286 ± 2.04687e-05 (W 3.36112e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003045 ± 2.45818e-05 (W 2.10374e-05) | 0.0033965 ± 8.93174e-05 (W 2.66341e-05) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014342 ± 0.00136179 (W 4.48016e-05) | 0.0149825 ± 8.70992e-05 (W 6.24911e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.053765 ± 0.00276121 (W 0.00336548) | 0.036453 ± 0.000205944 (W 0.000141334) | 🔴 fork 1.47× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113957 ± 0.000581995 (W 0.000221211) | 0.100487 ± 0.000318755 (W 0.00135864) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.514131 ± 0.00345484 (W 0.00392625) | 0.341384 ± 0.000803151 (W 0.00179294) | 🔴 fork 1.51× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.24265 ± 0.0172985 (W 0.0176014) | 0.72951 ± 0.00205034 (W 0.00161489) | 🔴 fork 1.70× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010229 ± 7.44759e-05 (W 8.28186e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.04557 ± 0.000265158 (W 0.000284291) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.1317 ± 0.000448246 (W 0.00230934) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008441 ± 7.0693e-05 (W 8.1016e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008521 ± 6.73214e-05 (W 5.29586e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.030527 ± 0.00335716 (W 0.00261647) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0287945 ± 0.00298354 (W 0.00166671) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0506595 ± 0.00321221 (W 0.00397607) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0507485 ± 0.0034805 (W 0.00428799) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.0071885 ± 5.6465e-05 (W 0.000101655) | 0.00835 ± 7.58393e-05 (W 7.0715e-05) | 🔵 fork 1.16× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025853 ± 0.000119466 (W 0.00017887) | 0.0327255 ± 0.000169957 (W 0.000155331) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.063408 ± 0.000259411 (W 0.0017753) | 0.0767235 ± 0.000296662 (W 0.00020037) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0314935 ± 0.000163206 (W 0.000162088) | 0.0296555 ± 0.000438662 (W 0.000139904) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.148401 ± 0.00383624 (W 0.00117313) | 0.118566 ± 0.000298734 (W 0.00107349) | 🔴 fork 1.25× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.400189 ± 0.0119961 (W 0.0148501) | 0.341975 ± 0.00215193 (W 0.00165879) | 🔴 fork 1.17× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0176875 ± 0.000134611 (W 9.34427e-05) | 0.01601 ± 0.000207492 (W 8.22163e-05) | 🔴 fork 1.10× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.092157 ± 0.00572456 (W 0.001652) | 0.0609285 ± 0.000650645 (W 0.000230855) | 🔴 fork 1.51× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.190086 ± 0.0114946 (W 0.00826482) | 0.172521 ± 0.00115039 (W 0.00170346) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.0078295 ± 8.09296e-05 (W 4.32567e-05) | 0.008521 ± 6.09098e-05 (W 0.000641266) | 🔵 fork 1.09× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0260585 ± 0.00025597 (W 0.000111116) | 0.0323 ± 0.000186347 (W 0.000113128) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.065056 ± 0.000208783 (W 0.00125129) | 0.076001 ± 0.000283649 (W 0.000712311) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.184779 ± 0.000698403 (W 0.00139779) | 0.174046 ± 0.00068669 (W 0.00146408) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 1.00948 ± 0.00342269 (W 0.00311876) | 0.617298 ± 0.00140719 (W 0.00244581) | 🔴 fork 1.64× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.30101 ± 0.0156337 (W 0.012922) | 1.44382 ± 0.00336978 (W 0.0025998) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.142146 ± 0.000295613 (W 0.0011539) | 0.0741225 ± 0.00045357 (W 0.000122768) | 🔴 fork 1.92× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.543145 ± 0.00204731 (W 0.00324728) | 0.267359 ± 0.000875684 (W 0.0020158) | 🔴 fork 2.03× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19234 ± 0.00236679 (W 0.00208914) | 0.653551 ± 0.00153583 (W 0.00223116) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007415 ± 1.59677e-05 (W 1.71112e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0017035 ± 1.47513e-05 (W 2.49111e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002861 ± 3.47313e-05 (W 3.21305e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00521 ± 2.824e-05 (W 3.66414e-05) | 0.006613 ± 6.55612e-05 (W 4.75368e-05) | 🔵 fork 1.27× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030157 ± 0.000205607 (W 0.000174513) | 0.039789 ± 0.000372968 (W 0.00037724) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.0841515 ± 0.000305718 (W 0.000248368) | 0.0954575 ± 0.00058179 (W 0.00039632) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142592 ± 0.000661732 (W 0.00143124) | 0.151481 ± 0.000537929 (W 0.00149209) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.653009 ± 0.00171149 (W 0.00179993) | 0.656438 ± 0.00088873 (W 0.00188298) | · |  |
| `eigh/n96/b1` | 1.62262 ± 0.00475638 (W 0.00258207) | 1.63497 ± 0.0048827 (W 0.00314989) | · |  |
| `full_piv_lu/n32/b1` | 0.0179435 ± 9.07247e-05 (W 0.000102811) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0987785 ± 0.000506841 (W 0.000881187) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.283889 ± 0.00112669 (W 0.00145448) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028273 ± 7.47005e-05 (W 7.45855e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0284675 ± 0.000115772 (W 8.7854e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.160743 ± 0.000651159 (W 0.00159697) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.16089 ± 0.000122372 (W 0.00170627) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.469089 ± 0.00327971 (W 0.000655583) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.469811 ± 0.00221209 (W 0.000776574) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.01333 ± 4.24284e-05 (W 0.000116897) | 0.0139055 ± 0.000115228 (W 0.000103886) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0586345 ± 0.000344676 (W 0.000847649) | 0.0678205 ± 0.000566336 (W 0.00148629) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.15341 ± 0.000508135 (W 0.00150775) | 0.180916 ± 0.00113514 (W 0.00178345) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.069665 ± 0.000357326 (W 0.00123959) | 0.0541255 ± 0.000394337 (W 0.000155063) | 🔴 fork 1.29× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.318468 ± 0.000707007 (W 0.00168084) | 0.264767 ± 0.00167841 (W 0.00160688) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.77935 ± 0.00130309 (W 0.001978) | 0.733216 ± 0.00267051 (W 0.00205772) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0406455 ± 0.000236627 (W 0.000252777) | 0.0299805 ± 0.00019706 (W 9.28483e-05) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.177329 ± 0.000656098 (W 0.00136278) | 0.13826 ± 0.00161022 (W 0.00153273) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.427225 ± 0.00196668 (W 0.00313509) | 0.37385 ± 0.00141938 (W 0.00203063) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.014742 ± 0.000112001 (W 7.79642e-05) | 0.015599 ± 0.000168618 (W 5.35937e-05) | 🔵 fork 1.06× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.061009 ± 0.000123063 (W 0.000193733) | 0.072856 ± 0.000590106 (W 0.000277944) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.157558 ± 0.000534698 (W 0.00150382) | 0.191586 ± 0.00147197 (W 0.0018087) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.235674 ± 0.002535 (W 0.0013961) | 0.228539 ± 0.00139197 (W 0.001287) | · |  |
| `svd_thin/n64/b1` | 1.23052 ± 0.00308315 (W 0.00154358) | 0.959907 ± 0.00784956 (W 0.00158521) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.16441 ± 0.010947 (W 0.00308967) | 2.65329 ± 0.0982805 (W 0.00394185) | 🔴 fork 1.19× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.161996 ± 0.000535803 (W 0.00160668) | 0.103177 ± 0.000705499 (W 0.00167234) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.660548 ± 0.00259037 (W 0.00152421) | 0.409708 ± 0.000827572 (W 0.00192548) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.54747 ± 0.00580328 (W 0.00359939) | 1.02639 ± 0.00460165 (W 0.00191985) | 🔴 fork 1.51× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001077 ± 9.83192e-06 (W 2.47891e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.00275 ± 1.91877e-05 (W 2.77965e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0049395 ± 2.49299e-05 (W 1.861e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052195 ± 7.20111e-05 (W 4.83207e-05) | 0.0066225 ± 6.46189e-05 (W 3.95259e-05) | 🔵 fork 1.27× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030121 ± 0.000121943 (W 0.00012295) | 0.0381665 ± 0.000845838 (W 0.00142336) | 🔵 fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.103376 ± 0.00151974 (W 0.00137673) | 0.0968555 ± 0.000739994 (W 0.00114846) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142251 ± 0.000323531 (W 0.00143179) | 0.136439 ± 0.000355228 (W 0.00117472) | · |  |
| `eigh/n64/b1` | 0.643706 ± 0.00106738 (W 0.0033042) | 0.573427 ± 0.00191352 (W 0.00180053) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.55246 ± 0.0151779 (W 0.0135341) | 1.61975 ± 0.00332006 (W 0.00229812) | · |  |
| `full_piv_lu/n32/b1` | 0.017939 ± 7.96007e-05 (W 0.000114471) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0977965 ± 0.000389117 (W 0.00083084) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.283071 ± 0.000535338 (W 0.00171511) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028207 ± 7.73796e-05 (W 7.09839e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028328 ± 0.000111557 (W 8.62802e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0655925 ± 0.000315694 (W 0.00105237) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0655625 ± 0.000188812 (W 0.000437559) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.156186 ± 0.000801899 (W 0.00137783) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.155523 ± 0.00061499 (W 0.00152798) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.01331 ± 0.000136461 (W 5.77051e-05) | 0.013806 ± 9.69895e-05 (W 6.50103e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.05864 ± 0.000151026 (W 0.000221953) | 0.066729 ± 0.000672358 (W 0.00133436) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.152956 ± 0.000459194 (W 0.00169341) | 0.180356 ± 0.00231628 (W 0.00169714) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.069715 ± 0.000229906 (W 0.000337113) | 0.053726 ± 0.000458144 (W 9.71954e-05) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.297976 ± 0.0117635 (W 0.00183451) | 0.263216 ± 0.00270074 (W 0.00238209) | 🔴 fork 1.13× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.694764 ± 0.046983 (W 0.00954397) | 0.929229 ± 0.00279166 (W 0.00180554) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.040726 ± 0.00017716 (W 0.000184072) | 0.029876 ± 8.93659e-05 (W 7.60466e-05) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.187619 ± 0.0150394 (W 0.00318642) | 0.138499 ± 0.00100106 (W 0.00127419) | 🔴 fork 1.35× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.375344 ± 0.00273295 (W 0.0048932) | 0.472587 ± 0.00221718 (W 0.00179464) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0148125 ± 0.000102815 (W 0.000134965) | 0.015509 ± 9.13185e-05 (W 5.75013e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0608685 ± 0.00038277 (W 0.000213733) | 0.072305 ± 0.000789189 (W 0.00110769) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.157274 ± 0.000535587 (W 0.00127204) | 0.189559 ± 0.0019413 (W 0.00169672) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.235919 ± 0.00177331 (W 0.00209372) | 0.227034 ± 0.000334174 (W 0.00139154) | · |  |
| `svd_thin/n64/b1` | 1.20462 ± 0.00284466 (W 0.00262027) | 0.95579 ± 0.00203545 (W 0.000989413) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.0196 ± 0.0109703 (W 0.0206816) | 2.46794 ± 0.00454316 (W 0.00298071) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.161606 ± 0.000501368 (W 0.00163559) | 0.103247 ± 0.00026792 (W 0.00188246) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.65892 ± 0.00226534 (W 0.00244603) | 0.40965 ± 0.00224184 (W 0.00224505) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.54508 ± 0.00248453 (W 0.00244121) | 1.28581 ± 0.00328756 (W 0.00261652) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001067 ± 1.26491e-05 (W 2.1726e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.00272 ± 2.19089e-05 (W 1.94512e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0049445 ± 6.03448e-05 (W 2.46377e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005154 ± 6.12068e-05 (W 5.79111e-05) | 0.0066425 ± 7.77192e-05 (W 3.81469e-05) | 🔵 fork 1.29× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030126 ± 0.000229617 (W 0.000117279) | 0.0421985 ± 0.000301342 (W 0.000541145) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.112183 ± 0.00034893 (W 0.00343984) | 0.103474 ± 0.00106939 (W 0.00145649) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.1424 ± 0.00092593 (W 0.0016437) | 0.135057 ± 0.000419159 (W 0.00112766) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.650286 ± 0.00254468 (W 0.00408406) | 0.561801 ± 0.00211096 (W 0.00203925) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.55109 ± 0.00732339 (W 0.0154078) | 1.64776 ± 0.00332321 (W 0.00354369) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0178835 ± 6.52393e-05 (W 0.000115801) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.098248 ± 0.000646726 (W 0.000354832) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.282579 ± 0.000638683 (W 0.0019945) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028268 ± 0.000136439 (W 7.58333e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028448 ± 9.93051e-05 (W 6.89481e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0425445 ± 0.000669333 (W 0.000534152) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.04273 ± 0.000226474 (W 0.000562869) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0915795 ± 0.000578875 (W 0.000829885) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0920765 ± 0.000656949 (W 0.000951297) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0133655 ± 9.49477e-05 (W 0.000105149) | 0.013991 ± 0.000116562 (W 9.18546e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0583035 ± 0.000306712 (W 0.000118664) | 0.0677455 ± 0.000701952 (W 0.000321698) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.152925 ± 0.000443505 (W 0.000953396) | 0.182537 ± 0.00102449 (W 0.00191441) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070036 ± 0.000163984 (W 0.0014959) | 0.053896 ± 0.000242466 (W 0.000126016) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.311586 ± 0.00268021 (W 0.00567752) | 0.26185 ± 0.00204126 (W 0.00193714) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.715633 ± 0.0102355 (W 0.0158715) | 0.988482 ± 0.00525696 (W 0.00224272) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0405355 ± 0.000287478 (W 0.000303263) | 0.0299665 ± 0.000180281 (W 7.98691e-05) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.180637 ± 0.00103451 (W 0.00220988) | 0.137746 ± 0.00128115 (W 0.00163459) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.395227 ± 0.00151084 (W 0.0047451) | 0.500718 ± 0.00197295 (W 0.00134871) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0147225 ± 8.71338e-05 (W 0.000119828) | 0.015474 ± 0.00014854 (W 7.17552e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0606835 ± 0.000378052 (W 0.000213137) | 0.0723835 ± 0.000549952 (W 0.000204392) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.156981 ± 0.0003047 (W 0.00168209) | 0.189688 ± 0.00241705 (W 0.00184144) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.235741 ± 0.00136574 (W 0.00206009) | 0.226203 ± 0.00108059 (W 0.00157759) | · |  |
| `svd_thin/n64/b1` | 1.21992 ± 0.00296115 (W 0.0037072) | 0.954003 ± 0.00175855 (W 0.00107775) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.99766 ± 0.00606591 (W 0.0188923) | 2.55391 ± 0.00651 (W 0.00397455) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.161815 ± 0.000916594 (W 0.00143091) | 0.103233 ± 0.000662567 (W 0.000809205) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.658714 ± 0.00113018 (W 0.00211531) | 0.411376 ± 0.00244685 (W 0.00223018) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.54566 ± 0.00403046 (W 0.00277866) | 1.38165 ± 0.00812726 (W 0.00351719) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001082 ± 2.07364e-05 (W 2.53853e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.00274 ± 2.63944e-05 (W 2.96699e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004954 ± 2.40333e-05 (W 2.13694e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005215 ± 2.70832e-05 (W 4.53886e-05) | 0.0058605 ± 8.4215e-05 (W 5.00796e-05) | 🔵 fork 1.12× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0298305 ± 0.000140206 (W 9.19198e-05) | 0.031784 ± 0.000149253 (W 9.26115e-05) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.0832255 ± 0.00033012 (W 0.00122665) | 0.086611 ± 8.94861e-05 (W 0.00119109) | · |  |
| `eigh/n32/b1` | 0.142802 ± 0.000357573 (W 0.00161983) | 0.149964 ± 0.000984249 (W 0.00143073) | · |  |
| `eigh/n64/b1` | 0.653582 ± 0.00204837 (W 0.0018882) | 0.648875 ± 0.00159047 (W 0.00183996) | · |  |
| `eigh/n96/b1` | 1.62461 ± 0.00294602 (W 0.00343557) | 1.62137 ± 0.00446537 (W 0.00307716) | · |  |
| `full_piv_lu/n32/b1` | 0.0158595 ± 6.50766e-05 (W 7.53738e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090954 ± 0.000371726 (W 0.000387486) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.26656 ± 0.000691769 (W 0.00176878) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0283225 ± 0.00013197 (W 5.6422e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028358 ± 0.000101735 (W 5.57024e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.15811 ± 0.000428948 (W 0.00138729) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158035 ± 0.000244227 (W 0.00125199) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.463099 ± 0.00226273 (W 0.000702169) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.466088 ± 0.00202468 (W 0.000581847) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0113915 ± 0.000143658 (W 5.77343e-05) | 0.0126985 ± 8.82211e-05 (W 8.09415e-05) | 🔵 fork 1.11× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0512455 ± 0.000232101 (W 0.000136301) | 0.060357 ± 0.000126467 (W 0.00017419) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.136681 ± 0.000486548 (W 0.00136381) | 0.164471 ± 0.000303823 (W 0.00161434) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.067836 ± 0.000117692 (W 0.000406062) | 0.0516765 ± 0.000238227 (W 0.000126676) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.312043 ± 0.00149718 (W 0.00167589) | 0.249798 ± 0.00263766 (W 0.0017934) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.763691 ± 0.00267099 (W 0.0022307) | 0.698659 ± 0.00313264 (W 0.00211013) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0336925 ± 0.000187845 (W 0.000245837) | 0.0287985 ± 0.000240192 (W 5.64472e-05) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.160305 ± 0.000601512 (W 0.00131899) | 0.131244 ± 0.00111832 (W 0.001206) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.389169 ± 0.00165929 (W 0.00183492) | 0.356468 ± 0.00111399 (W 0.0022011) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0125785 ± 0.000109412 (W 9.83579e-05) | 0.0141365 ± 2.87449e-05 (W 5.63986e-05) | 🔵 fork 1.12× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0535755 ± 0.000131046 (W 0.000592155) | 0.0648355 ± 0.000175731 (W 0.000102455) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.140856 ± 0.000622981 (W 0.00108979) | 0.172722 ± 0.000607603 (W 0.00198207) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.232999 ± 0.00273668 (W 0.00167694) | 0.225498 ± 0.000826451 (W 0.00142719) | · |  |
| `svd_thin/n64/b1` | 1.26081 ± 0.00211816 (W 0.00179255) | 0.936272 ± 0.00386289 (W 0.00200496) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.1271 ± 0.00540633 (W 0.00223985) | 2.51361 ± 0.0123344 (W 0.00686724) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.159483 ± 0.000540784 (W 0.00126903) | 0.102977 ± 0.00050401 (W 0.000187432) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.634324 ± 0.000943737 (W 0.00210706) | 0.402092 ± 0.00172634 (W 0.0019076) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51897 ± 0.00787033 (W 0.00426503) | 1.004 ± 0.00344072 (W 0.00167548) | 🔴 fork 1.51× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0012025 ± 1.63177e-05 (W 1.43717e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002971 ± 3.38275e-05 (W 1.98818e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0053505 ± 0.000194557 (W 1.69264e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005145 ± 5.15393e-05 (W 3.44269e-05) | 0.005856 ± 5.34478e-05 (W 6.3169e-05) | 🔵 fork 1.14× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029685 ± 0.000158548 (W 7.03695e-05) | 0.032951 ± 0.000238361 (W 0.000488385) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.102171 ± 0.00244673 (W 0.0016833) | 0.087719 ± 0.000471439 (W 0.000831081) | 🔴 fork 1.16× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.142441 ± 0.000557336 (W 0.00196643) | 0.135122 ± 0.000134073 (W 0.00150253) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.643533 ± 0.00211414 (W 0.00399558) | 0.565665 ± 0.00217203 (W 0.00202381) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.55246 ± 0.00704995 (W 0.0107016) | 1.60631 ± 0.00364706 (W 0.00224364) | · |  |
| `full_piv_lu/n32/b1` | 0.015804 ± 0.000112263 (W 8.35223e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0912355 ± 0.000296287 (W 0.00080723) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.267215 ± 0.00105508 (W 0.00191199) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028138 ± 0.000140959 (W 0.000100908) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0282475 ± 0.000158737 (W 8.4072e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0698605 ± 0.00353668 (W 0.00259685) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.06977 ± 0.00394854 (W 0.00178131) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.163677 ± 0.000581927 (W 0.00344742) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.163859 ± 0.000535257 (W 0.00402333) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011402 ± 0.000183732 (W 0.000132199) | 0.012729 ± 0.000101949 (W 5.8893e-05) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0511505 ± 0.000306775 (W 0.000388233) | 0.0602525 ± 0.000169636 (W 0.000109605) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.13723 ± 0.000624728 (W 0.00162239) | 0.164311 ± 0.00025194 (W 0.00162308) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.068172 ± 0.000482162 (W 0.000606592) | 0.051586 ± 0.000275261 (W 0.000301301) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.297336 ± 0.0018546 (W 0.00668127) | 0.250797 ± 0.00238356 (W 0.00156601) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.677593 ± 0.0444745 (W 0.0123105) | 0.893619 ± 0.0034638 (W 0.00149722) | 🔵 fork 1.32× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0336225 ± 0.000181042 (W 0.000236265) | 0.028959 ± 0.000267211 (W 0.000164877) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.159457 ± 0.00854901 (W 0.00364705) | 0.130473 ± 0.000989519 (W 0.000835343) | 🔴 fork 1.22× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.337715 ± 0.00447713 (W 0.00849229) | 0.454199 ± 0.000594661 (W 0.00168908) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0125185 ± 0.000176412 (W 9.26378e-05) | 0.014121 ± 6.89202e-05 (W 6.20999e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053419 ± 0.000399239 (W 0.000131284) | 0.0643555 ± 0.00029569 (W 0.000830516) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.140721 ± 0.000494804 (W 0.00149224) | 0.172596 ± 0.000566616 (W 0.00167855) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.233482 ± 0.00139862 (W 0.00200897) | 0.22543 ± 0.000452078 (W 0.00149841) | · |  |
| `svd_thin/n64/b1` | 1.23849 ± 0.00299967 (W 0.00298233) | 0.934373 ± 0.00151894 (W 0.001062) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.97164 ± 0.0205743 (W 0.0291874) | 2.4366 ± 0.00474755 (W 0.00291852) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.159463 ± 0.000573737 (W 0.00176232) | 0.103058 ± 0.000294349 (W 0.00170975) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.632833 ± 0.00165939 (W 0.00207696) | 0.401402 ± 0.00158922 (W 0.00182417) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51811 ± 0.00181348 (W 0.00274902) | 1.26786 ± 0.00240718 (W 0.00261275) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001202 ± 1.4838e-05 (W 1.49811e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0029205 ± 2.5119e-05 (W 1.55963e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00556 ± 0.000368695 (W 1.49534e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0051445 ± 7.98265e-05 (W 3.8863e-05) | 0.005916 ± 8.57681e-05 (W 6.51122e-05) | 🔵 fork 1.15× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029871 ± 0.000143764 (W 7.2529e-05) | 0.037354 ± 0.000501074 (W 0.000766994) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.110602 ± 0.00118073 (W 0.0024718) | 0.095223 ± 0.000565338 (W 0.00215502) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142571 ± 0.000538175 (W 0.00175579) | 0.13435 ± 0.000420614 (W 0.00118044) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.647362 ± 0.00443394 (W 0.00443551) | 0.5541 ± 0.00149516 (W 0.00169437) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.54365 ± 0.0103771 (W 0.0147016) | 1.63456 ± 0.00446904 (W 0.00258941) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.015745 ± 0.000167265 (W 8.0984e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090954 ± 0.000311103 (W 0.000365316) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.266551 ± 0.000508879 (W 0.00167238) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0282675 ± 0.000139972 (W 9.78011e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0283075 ± 0.000131401 (W 8.10861e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0512305 ± 0.00267905 (W 0.00285028) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.051085 ± 0.000648586 (W 0.00229762) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.105359 ± 0.00230364 (W 0.00369884) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.106328 ± 0.000662961 (W 0.00331507) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0112565 ± 9.85097e-05 (W 4.86403e-05) | 0.012759 ± 5.54392e-05 (W 8.20051e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.05117 ± 0.000302298 (W 0.000337749) | 0.060161 ± 0.000102317 (W 0.00015941) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.136574 ± 0.000340444 (W 0.00170282) | 0.165001 ± 0.000693983 (W 0.00187432) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.068057 ± 0.000241782 (W 0.00162322) | 0.051456 ± 0.000109064 (W 0.000173602) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.307831 ± 0.00364768 (W 0.00618378) | 0.246895 ± 0.00192166 (W 0.00196076) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.696174 ± 0.0124216 (W 0.0147148) | 0.951665 ± 0.0060977 (W 0.00218298) | 🔵 fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033587 ± 0.000263406 (W 0.000208645) | 0.0288935 ± 0.000175055 (W 6.26648e-05) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.164496 ± 0.00992057 (W 0.00227151) | 0.129446 ± 0.00122289 (W 0.00105264) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.355129 ± 0.0160356 (W 0.00564821) | 0.484407 ± 0.0019517 (W 0.00190856) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.012543 ± 0.000109362 (W 0.000117383) | 0.014141 ± 3.89872e-05 (W 7.28099e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0535845 ± 0.000368072 (W 0.000768128) | 0.064279 ± 0.000281833 (W 0.000125387) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.140191 ± 0.000793127 (W 0.00140263) | 0.172843 ± 0.0006308 (W 0.00163804) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.232967 ± 0.00201401 (W 0.00194957) | 0.225374 ± 0.000568605 (W 0.00167348) | · |  |
| `svd_thin/n64/b1` | 1.25311 ± 0.0034937 (W 0.00391266) | 0.935171 ± 0.00113323 (W 0.00181526) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.95421 ± 0.0243843 (W 0.0152956) | 2.51823 ± 0.0151629 (W 0.0068798) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.159593 ± 0.000654812 (W 0.00132681) | 0.103512 ± 0.00078899 (W 0.000781837) | 🔴 fork 1.54× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.633798 ± 0.00200106 (W 0.00231117) | 0.403434 ± 0.00227321 (W 0.00205696) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.5186 ± 0.00193253 (W 0.00250253) | 1.36523 ± 0.00424914 (W 0.00487623) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001212 ± 1.36626e-05 (W 1.98418e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0029305 ± 1.47071e-05 (W 8.67737e-06) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005305 ± 4.0301e-05 (W 2.40807e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0663535 ± 0.000186857 (W 0.000646258) | 0.156402 ± 0.00259904 (W 0.00267538) | 🔵 fork 2.36× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.386475 ± 0.00273662 (W 0.00208801) | 1.00005 ± 0.00440498 (W 0.00630073) | 🔵 fork 2.59× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.51227 ± 0.0223872 (W 0.00325679) | 5.94745 ± 0.0360677 (W 0.0220757) | 🔵 fork 2.37× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.27668 ± 0.00999868 (W 0.0064015) | 1.87618 ± 0.00508183 (W 0.00838049) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.8329 ± 0.0376549 (W 0.00901531) | 9.15633 ± 0.00951222 (W 0.0196808) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 48.9962 ± 0.267442 (W 0.053247) | 52.2892 ± 0.120781 (W 0.0923735) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.314516 ± 0.00124961 (W 0.00202037) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.73023 ± 0.0272572 (W 0.0102624) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.9988 ± 0.169642 (W 0.0564216) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.260564 ± 0.00135082 (W 0.00213971) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.260169 ± 0.00112573 (W 0.00198716) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92705 ± 0.014715 (W 0.00634781) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.91351 ± 0.0134921 (W 0.00423091) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 16.0722 ± 0.058618 (W 0.0440914) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.8866 ± 0.0290252 (W 0.0438211) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.167926 ± 0.0010811 (W 0.00174106) | 0.207844 ± 0.00398567 (W 0.00517737) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.998799 ± 0.00224414 (W 0.00302269) | 1.35928 ± 0.00757352 (W 0.00571743) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 6.69794 ± 0.0220322 (W 0.0164711) | 8.24208 ± 0.102314 (W 0.0244743) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.519964 ± 0.00332371 (W 0.00237379) | 0.862762 ± 0.005252 (W 0.00487188) | 🔵 fork 1.66× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.90376 ± 0.00730982 (W 0.00822796) | 4.36997 ± 0.0055185 (W 0.0124571) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 20.3565 ± 0.0792811 (W 0.0569749) | 30.6897 ± 0.103212 (W 0.0705245) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.335911 ± 0.00190627 (W 0.0021957) | 0.430509 ± 0.00355244 (W 0.00482895) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.62103 ± 0.00640566 (W 0.00438913) | 2.16679 ± 0.00660702 (W 0.00522788) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.95548 ± 0.0552304 (W 0.0159061) | 14.4403 ± 0.0161117 (W 0.0311446) | 🔵 fork 1.61× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.137767 ± 0.000428882 (W 0.00154658) | 0.199451 ± 0.00353516 (W 0.00447267) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.774252 ± 0.00387161 (W 0.00231477) | 1.12639 ± 0.00680534 (W 0.00435295) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.61335 ± 0.0125906 (W 0.0107704) | 7.07379 ± 0.042979 (W 0.0174534) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.69231 ± 0.0092221 (W 0.00683516) | 3.14654 ± 0.0228778 (W 0.0135361) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.5096 ± 0.0321336 (W 0.028946) | 17.609 ± 0.0275571 (W 0.0377148) | · |  |
| `svd_thin/n512/b1` | 105.869 ± 0.282355 (W 0.0694713) | 122.587 ± 2.14313 (W 0.299667) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.6993 ± 0.0100346 (W 0.00643755) | 1.35513 ± 0.00527008 (W 0.00485442) | 🔴 fork 1.99× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.5021 ± 0.0379516 (W 0.0239336) | 7.94091 ± 0.0553867 (W 0.0151109) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 66.5045 ± 0.265756 (W 0.067277) | 54.4259 ± 0.801685 (W 0.161437) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0039675 ± 0.000113026 (W 5.0338e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.01062 ± 0.00114645 (W 0.000106844) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0367485 ± 0.00462235 (W 0.000416502) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.084722 ± 0.00200208 (W 0.00247865) | 0.166342 ± 0.00125412 (W 0.00238134) | 🔵 fork 1.96× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.397659 ± 0.0125639 (W 0.0227753) | 0.852118 ± 0.00664287 (W 0.00904476) | 🔵 fork 2.14× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.5648 ± 0.0582099 (W 0.0221968) | 4.59333 ± 0.053213 (W 0.0142269) | 🔵 fork 2.94× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.33255 ± 0.0273633 (W 0.0292848) | 1.49501 ± 0.00637454 (W 0.00246399) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 7.04027 ± 0.0434797 (W 0.0302837) | 6.09623 ± 0.0298112 (W 0.0152952) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 26.3298 ± 0.136221 (W 0.0755201) | 29.0463 ± 0.479193 (W 0.0492155) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.312268 ± 0.00165108 (W 0.00220483) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7242 ± 0.0193574 (W 0.0112994) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.6137 ± 0.147448 (W 0.16646) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0851635 ± 0.000479559 (W 0.00105336) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.086801 ± 0.000926849 (W 0.00101239) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.527624 ± 0.00400262 (W 0.0034032) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.534166 ± 0.00368817 (W 0.00399494) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.18343 ± 0.0106389 (W 0.0143678) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.21185 ± 0.0192404 (W 0.0246684) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.169044 ± 0.00143554 (W 0.0020193) | 0.206741 ± 0.00331282 (W 0.0054435) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 1.01072 ± 0.00561646 (W 0.0083792) | 1.04251 ± 0.00921612 (W 0.00303077) | · |  |
| `lu/n512/b1` | 4.84764 ± 0.0433605 (W 0.107345) | 5.67849 ± 0.485931 (W 0.0158954) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.605947 ± 0.0244775 (W 0.033267) | 0.895271 ± 0.00570668 (W 0.00592257) | 🔵 fork 1.48× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.00662 ± 0.01002 (W 0.0356549) | 3.56674 ± 0.0112442 (W 0.00728085) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 10.2389 ± 0.0934852 (W 0.0853336) | 19.4161 ± 0.154779 (W 0.0339236) | 🔵 fork 1.90× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.405064 ± 0.0346437 (W 0.0236047) | 0.449242 ± 0.00451688 (W 0.00303874) | 🔵 fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.45747 ± 0.00476059 (W 0.0135637) | 1.76094 ± 0.00210048 (W 0.00332055) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 5.21814 ± 0.0261097 (W 0.0323217) | 9.57641 ± 0.245277 (W 0.015329) | 🔵 fork 1.84× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.138082 ± 0.000927351 (W 0.000901486) | 0.170321 ± 0.00280544 (W 0.00491993) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.783696 ± 0.00347318 (W 0.00234151) | 0.781564 ± 0.00616601 (W 0.00476291) | · |  |
| `solve/n512/b1` | 4.78281 ± 0.0497917 (W 0.0562362) | 4.76656 ± 0.195907 (W 0.012128) | · | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.05723 ± 0.029566 (W 0.0260712) | 3.07269 ± 0.0100596 (W 0.00862038) | · |  |
| `svd_thin/n256/b1` | 13.706 ± 0.0905668 (W 0.0682843) | 14.9018 ± 0.116653 (W 0.0139356) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 62.2214 ± 0.27466 (W 0.28812) | 93.9693 ± 2.21282 (W 0.618628) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.23183 ± 0.0110353 (W 0.00682533) | 1.38861 ± 0.00501997 (W 0.00429247) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.881 ± 0.0605021 (W 0.0475121) | 7.68395 ± 0.0104503 (W 0.0117265) | 🔴 fork 1.42× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 48.4946 ± 0.482411 (W 0.322083) | 50.0231 ± 3.08161 (W 0.335328) | · | `!` between-start range over 5% |
| `triangular_solve/n128/b1` | 0.003952 ± 0.000375287 (W 4.37924e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0109705 ± 0.000508334 (W 6.50662e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0424795 ± 0.00458633 (W 0.00256286) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089046 ± 0.00217817 (W 0.00375082) | 0.165677 ± 0.00153119 (W 0.00242983) | 🔵 fork 1.86× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.403112 ± 0.0161441 (W 0.0203669) | 0.850422 ± 0.00838484 (W 0.00664518) | 🔵 fork 2.11× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.54085 ± 0.0272022 (W 0.023887) | 4.43852 ± 0.0230628 (W 0.0211012) | 🔵 fork 2.88× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.42162 ± 0.018478 (W 0.0301251) | 1.43581 ± 0.00708797 (W 0.00444167) | 🔴 fork 1.69× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.92513 ± 0.034745 (W 0.0286134) | 5.74721 ± 0.0246027 (W 0.0082906) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 24.3395 ± 0.0736365 (W 0.0424038) | 25.3535 ± 0.175367 (W 0.0460127) | · |  |
| `full_piv_lu/n128/b1` | 0.313624 ± 0.000961394 (W 0.00164063) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.72859 ± 0.0128001 (W 0.0102747) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4092 ± 0.0909 (W 0.0957459) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0597395 ± 0.000618955 (W 0.00101197) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.060292 ± 0.000688948 (W 0.00119282) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.286449 ± 0.00117104 (W 0.0020894) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.292596 ± 0.00276169 (W 0.00245956) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.27309 ± 0.0100295 (W 0.0183281) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.27959 ± 0.027098 (W 0.0127806) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.169335 ± 0.000769662 (W 0.00236062) | 0.207948 ± 0.00302904 (W 0.00382852) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 1.01418 ± 0.0248893 (W 0.00964436) | 0.970566 ± 0.00521359 (W 0.00456301) | · | `!` between-start range over 5% |
| `lu/n512/b1` | 4.76425 ± 0.196375 (W 0.0914382) | 4.7666 ± 0.115739 (W 0.0102183) | · | `!` between-start range over 5% |
| `qr/n128/b1` | 0.603133 ± 0.013402 (W 0.0169638) | 0.891822 ± 0.00805773 (W 0.00593127) | 🔵 fork 1.48× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.82268 ± 0.0192007 (W 0.0188813) | 3.52259 ± 0.0295516 (W 0.00852649) | 🔵 fork 1.93× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.94676 ± 0.0372286 (W 0.0670527) | 18.1763 ± 0.842342 (W 0.0513381) | 🔵 fork 2.03× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.36234 ± 0.0673576 (W 0.0100448) | 0.445983 ± 0.00523288 (W 0.00457334) | 🔵 fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.40434 ± 0.0108742 (W 0.0136817) | 1.73792 ± 0.00271609 (W 0.00510144) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.86736 ± 0.0174403 (W 0.0465756) | 8.68916 ± 0.0438213 (W 0.0122039) | 🔵 fork 1.79× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.138095 ± 0.000836093 (W 0.000930286) | 0.208162 ± 0.00377367 (W 0.00434585) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.785886 ± 0.00338665 (W 0.00372707) | 0.749745 ± 0.00444019 (W 0.00434608) | · |  |
| `solve/n512/b1` | 4.70311 ± 0.0327471 (W 0.0764958) | 3.84923 ± 0.43311 (W 0.0070129) | 🔴 fork 1.22× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n128/b1` | 3.0597 ± 0.0141203 (W 0.0108653) | 3.06269 ± 0.0102622 (W 0.0120651) | · |  |
| `svd_thin/n256/b1` | 13.4752 ± 0.056764 (W 0.0512278) | 14.6419 ± 0.0402237 (W 0.019672) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 60.1701 ± 0.418216 (W 0.546537) | 90.0837 ± 1.80246 (W 0.172542) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.2966 ± 0.00790294 (W 0.00484924) | 1.38887 ± 0.00605623 (W 0.00590942) | 🔴 fork 1.65× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 11.0124 ± 0.0249083 (W 0.0310299) | 7.567 ± 0.0453209 (W 0.0129646) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 49.9405 ± 0.19683 (W 0.4293) | 49.4003 ± 1.8269 (W 0.0904558) | · | `!` between-start range over 5% |
| `triangular_solve/n128/b1` | 0.003927 ± 2.93189e-05 (W 5.93505e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0098885 ± 0.000605943 (W 8.85981e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0399395 ± 0.00117661 (W 0.000602128) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.059937 ± 0.00018839 (W 0.000105953) | 0.0713875 ± 0.000386359 (W 0.000131311) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.316636 ± 0.00149525 (W 0.00174958) | 0.405997 ± 0.00200409 (W 0.002151) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.06506 ± 0.0105628 (W 0.0028339) | 2.70478 ± 0.00641711 (W 0.00797922) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.27135 ± 0.00983135 (W 0.0037422) | 1.79732 ± 0.0104506 (W 0.00893254) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.7779 ± 0.0319885 (W 0.0196978) | 8.72545 ± 0.012014 (W 0.0162323) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 48.5919 ± 0.275807 (W 0.061059) | 49.6524 ± 0.103041 (W 0.0791057) | · |  |
| `full_piv_lu/n128/b1` | 0.288874 ± 0.00147408 (W 0.00244424) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.63507 ± 0.0279109 (W 0.00921891) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.3353 ± 0.285519 (W 0.0477936) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254773 ± 0.000861318 (W 0.00210513) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.255045 ± 0.000828425 (W 0.00179542) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.87424 ± 0.0157547 (W 0.00471073) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.88026 ± 0.0120192 (W 0.00413837) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8583 ± 0.0883048 (W 0.041339) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7388 ± 0.021121 (W 0.0421527) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.129346 ± 0.0161303 (W 0.000981846) | 0.151487 ± 0.000416222 (W 0.00159262) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.895846 ± 0.00459608 (W 0.00365372) | 0.837254 ± 0.00248704 (W 0.0025945) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.12239 ± 0.0284761 (W 0.0137983) | 5.1744 ± 0.0247306 (W 0.00872089) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.487071 ± 0.00238943 (W 0.00257795) | 0.785181 ± 0.0232034 (W 0.00723221) | 🔵 fork 1.61× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.77918 ± 0.00589759 (W 0.00552744) | 4.09211 ± 0.0329294 (W 0.0129634) | 🔵 fork 1.47× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.6993 ± 0.0809718 (W 0.0605671) | 27.0506 ± 0.115597 (W 0.0328044) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.275552 ± 0.00176978 (W 0.00178407) | 0.374509 ± 0.00214598 (W 0.00203179) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.36827 ± 0.003112 (W 0.00264195) | 1.88104 ± 0.00915555 (W 0.00500681) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 7.98821 ± 0.0518019 (W 0.0169122) | 12.4952 ± 0.0756235 (W 0.026701) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111962 ± 0.000614097 (W 0.00164718) | 0.147803 ± 0.000449306 (W 0.00159216) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.666098 ± 0.00188516 (W 0.00297724) | 0.825673 ± 0.00248283 (W 0.0022824) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.05495 ± 0.0104989 (W 0.0195624) | 5.10925 ± 0.00856711 (W 0.010548) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.68753 ± 0.00869873 (W 0.00565356) | 3.02122 ± 0.00431674 (W 0.00608995) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.3817 ± 0.0391627 (W 0.027869) | 17.0492 ± 0.111017 (W 0.0337054) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 105.125 ± 0.17237 (W 0.123691) | 116.708 ± 1.34496 (W 0.399106) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.61859 ± 0.00630202 (W 0.0050581) | 1.29095 ± 0.0050068 (W 0.00241807) | 🔴 fork 2.03× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.3159 ± 0.0374468 (W 0.0217377) | 7.68751 ± 0.0435729 (W 0.0168794) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.5196 ± 0.163188 (W 0.138499) | 52.4931 ± 0.444981 (W 0.0617079) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004363 ± 0.000180887 (W 4.02805e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011912 ± 0.00130661 (W 5.79401e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.041432 ± 0.00358713 (W 0.000274492) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.077463 ± 0.000589529 (W 0.00239246) | 0.076227 ± 0.00148188 (W 0.00129062) | · |  |
| `cholesky/n256/b1` | 0.327516 ± 0.0155888 (W 0.0203453) | 0.287048 ± 0.00485981 (W 0.00664642) | 🔴 fork 1.14× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.10478 ± 0.013879 (W 0.0228975) | 1.32821 ± 0.00390004 (W 0.00417185) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.31129 ± 0.0203141 (W 0.0264204) | 1.42415 ± 0.00388327 (W 0.00326565) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.99729 ± 0.0402116 (W 0.0312204) | 5.65771 ± 0.0166265 (W 0.00802391) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 26.0134 ± 0.17891 (W 0.0578051) | 26.0324 ± 0.150783 (W 0.0250143) | · |  |
| `full_piv_lu/n128/b1` | 0.288515 ± 0.00154782 (W 0.00225216) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62367 ± 0.0132546 (W 0.00854329) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9803 ± 0.128127 (W 0.102995) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0945845 ± 0.000943998 (W 0.00262623) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0969245 ± 0.0292327 (W 0.00350639) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.534256 ± 0.0012441 (W 0.00446762) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.535859 ± 0.00453193 (W 0.00420161) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.12383 ± 0.0216539 (W 0.0127698) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.18949 ± 0.0200596 (W 0.0213004) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.129264 ± 0.0171616 (W 0.00176545) | 0.151071 ± 0.000819517 (W 0.00158189) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.903873 ± 0.00449136 (W 0.0022614) | 0.504662 ± 0.00189136 (W 0.0022017) | 🔴 fork 1.79× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 4.2998 ± 0.0820818 (W 0.0830256) | 2.62873 ± 0.00827159 (W 0.00347405) | 🔴 fork 1.64× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.575072 ± 0.0225256 (W 0.037648) | 0.782523 ± 0.0045788 (W 0.00424737) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.90095 ± 0.008595 (W 0.0132401) | 3.24503 ± 0.00704758 (W 0.00726232) | 🔵 fork 1.71× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 9.61594 ± 0.0501734 (W 0.0913825) | 17.0738 ± 0.194342 (W 0.0451325) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.348726 ± 0.0303693 (W 0.0171461) | 0.392612 ± 0.00629408 (W 0.00142702) | 🔵 fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.34352 ± 0.0112023 (W 0.025579) | 1.45368 ± 0.0146851 (W 0.00437647) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.86864 ± 0.0500688 (W 0.0329481) | 7.59927 ± 0.086941 (W 0.0160192) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111068 ± 0.000626532 (W 0.00125406) | 0.115424 ± 0.00308811 (W 0.000962227) | · | `!` between-start range over 5% |
| `solve/n256/b1` | 0.679997 ± 0.00542703 (W 0.00304608) | 0.486142 ± 0.00186918 (W 0.00209558) | 🔴 fork 1.40× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 4.21903 ± 0.0490359 (W 0.0361504) | 2.57896 ± 0.012106 (W 0.00328245) | 🔴 fork 1.64× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.02926 ± 0.0159128 (W 0.0241421) | 2.9386 ± 0.00928225 (W 0.00561662) | · |  |
| `svd_thin/n256/b1` | 13.6046 ± 0.0820746 (W 0.0978391) | 14.1936 ± 0.102211 (W 0.0145798) | · |  |
| `svd_thin/n512/b1` | 61.0168 ± 0.245178 (W 0.351081) | 85.3337 ± 1.31779 (W 0.194776) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.1663 ± 0.00934435 (W 0.00410129) | 1.33186 ± 0.00145764 (W 0.00330375) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.6687 ± 0.0289193 (W 0.0589323) | 7.28416 ± 0.0182117 (W 0.00684856) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 47.4687 ± 0.538302 (W 0.405422) | 48.4243 ± 0.680416 (W 0.052182) | · |  |
| `triangular_solve/n128/b1` | 0.0043885 ± 0.000187386 (W 3.56226e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0126735 ± 0.000570608 (W 0.000139942) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0416425 ± 0.00424545 (W 0.00106247) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0832045 ± 0.00441614 (W 0.00446334) | 0.074785 ± 0.000392672 (W 0.000584364) | 🔴 fork 1.11× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.33091 ± 0.0125014 (W 0.0220086) | 0.27779 ± 0.00176772 (W 0.00251515) | 🔴 fork 1.19× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.06994 ± 0.0126999 (W 0.0231973) | 1.20164 ± 0.004727 (W 0.00495952) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.41047 ± 0.0324163 (W 0.0256004) | 1.36169 ± 0.00335337 (W 0.00291846) | 🔴 fork 1.77× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.8692 ± 0.0368462 (W 0.0305087) | 5.29419 ± 0.0109292 (W 0.00873769) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 23.886 ± 0.0766079 (W 0.0443484) | 22.6759 ± 0.121788 (W 0.025981) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.288994 ± 0.00102395 (W 0.00210948) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62844 ± 0.00568616 (W 0.00814262) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8168 ± 0.180507 (W 0.155627) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0699045 ± 0.000742728 (W 0.00134915) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.069664 ± 0.000679332 (W 0.00201298) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.297119 ± 0.00257995 (W 0.00249324) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.300725 ± 0.00228126 (W 0.00172129) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.24434 ± 0.00437606 (W 0.0103999) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.24938 ± 0.0197994 (W 0.0120832) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.128905 ± 0.0175381 (W 0.000463011) | 0.150492 ± 0.000896353 (W 0.00150964) | 🔵 fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.912735 ± 0.0102291 (W 0.00597022) | 0.444121 ± 0.0127548 (W 0.00165092) | 🔴 fork 2.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 4.19723 ± 0.0833475 (W 0.0727819) | 1.75687 ± 0.0109723 (W 0.00728495) | 🔴 fork 2.39× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.567132 ± 0.00909644 (W 0.0130217) | 0.784216 ± 0.00454026 (W 0.00804578) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.71704 ± 0.00823336 (W 0.0140225) | 3.16168 ± 0.0258177 (W 0.00586916) | 🔵 fork 1.84× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.30112 ± 0.36532 (W 0.0685457) | 15.4279 ± 0.168734 (W 0.0369454) | 🔵 fork 1.86× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.322465 ± 0.00474325 (W 0.00644693) | 0.38857 ± 0.0015611 (W 0.00182172) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.31239 ± 0.0154482 (W 0.0191118) | 1.43707 ± 0.013591 (W 0.00391993) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.56248 ± 0.0422424 (W 0.0604517) | 6.78861 ± 0.0401665 (W 0.0143996) | 🔵 fork 1.49× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111703 ± 0.000899651 (W 0.00165264) | 0.149982 ± 0.00217435 (W 0.00176435) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.683759 ± 0.00395543 (W 0.00328085) | 0.448238 ± 0.0113682 (W 0.00299635) | 🔴 fork 1.53× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.11697 ± 0.0265831 (W 0.0605012) | 1.74596 ± 0.0459516 (W 0.00718548) | 🔴 fork 2.36× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.02691 ± 0.0101962 (W 0.0134092) | 2.93235 ± 0.00969126 (W 0.011346) | · |  |
| `svd_thin/n256/b1` | 13.3958 ± 0.0670444 (W 0.0370357) | 13.9067 ± 0.0296258 (W 0.013361) | · |  |
| `svd_thin/n512/b1` | 58.9276 ± 0.310506 (W 0.374733) | 79.9909 ± 1.55914 (W 0.156317) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.18805 ± 0.0356914 (W 0.00592774) | 1.32986 ± 0.00283562 (W 0.00259273) | 🔴 fork 1.65× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.8206 ± 0.0261564 (W 0.0328391) | 7.26104 ± 0.0145278 (W 0.00957961) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 48.7983 ± 0.295983 (W 0.362478) | 46.8777 ± 0.253349 (W 0.0355095) | · |  |
| `triangular_solve/n128/b1` | 0.004228 ± 3.22516e-05 (W 3.51565e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011541 ± 0.00105903 (W 9.30898e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.045925 ± 0.00452831 (W 0.00336986) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.187781 ± 0.000922995 (W 0.00161422) | 0.328279 ± 0.00446607 (W 0.00326148) | 🔵 fork 1.75× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.22518 ± 0.00865308 (W 0.00443181) | 2.1171 ± 0.0163739 (W 0.00715904) | 🔵 fork 1.73× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.92038 ± 0.0314204 (W 0.0170991) | 12.6245 ± 0.0961082 (W 0.0217161) | 🔵 fork 1.59× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.28653 ± 0.0138807 (W 0.00570255) | 3.37862 ± 0.0162074 (W 0.00536637) | · |  |
| `eigh/n256/b1` | 17.5411 ± 0.057733 (W 0.033794) | 20.316 ± 0.0997336 (W 0.0360291) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.806 ± 0.133689 (W 0.241173) | 141.251 ± 0.519014 (W 0.23929) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.777915 ± 0.00195798 (W 0.00544198) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.9497 ± 0.0215549 (W 0.0140593) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.594 ± 0.12742 (W 0.0894729) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05065 ± 0.0061689 (W 0.00237655) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05395 ± 0.00422618 (W 0.00135987) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.51264 ± 0.012365 (W 0.0183504) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52885 ± 0.017274 (W 0.0122351) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9827 ± 0.0951061 (W 0.134435) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 57.0148 ± 0.0393256 (W 0.0598973) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.326153 ± 0.00116673 (W 0.00216629) | 0.427045 ± 0.00214852 (W 0.00330054) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.12531 ± 0.00588027 (W 0.00460547) | 2.77827 ± 0.0115199 (W 0.00972526) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 14.7436 ± 0.0538885 (W 0.0416896) | 18.4946 ± 0.204254 (W 0.042452) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.57118 ± 0.00172317 (W 0.002879) | 1.62954 ± 0.00569131 (W 0.00626821) | · |  |
| `qr/n256/b1` | 10.1991 ± 0.0113781 (W 0.0243472) | 11.3609 ± 0.0122828 (W 0.0209704) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 69.8898 ± 0.15236 (W 0.0888038) | 75.4519 ± 0.209369 (W 0.138273) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.811729 ± 0.00641288 (W 0.00148066) | 0.820156 ± 0.00424658 (W 0.0032116) | · |  |
| `qr_factor/n256/b1` | 4.76891 ± 0.0380585 (W 0.0120315) | 5.67666 ± 0.0111805 (W 0.0135367) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 30.7226 ± 0.033023 (W 0.0556688) | 37.4278 ± 0.144171 (W 0.0596694) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.323324 ± 0.00154193 (W 0.00196769) | 0.452585 ± 0.00271785 (W 0.00486119) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 2.06863 ± 0.0128058 (W 0.00432172) | 2.86257 ± 0.0132604 (W 0.003513) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 14.7321 ± 0.0398891 (W 0.029361) | 18.686 ± 0.232323 (W 0.0339405) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.83235 ± 0.0112228 (W 0.00687769) | 5.665 ± 0.0219049 (W 0.014314) | · |  |
| `svd_thin/n256/b1` | 34.9475 ± 0.15971 (W 0.0391965) | 37.058 ± 0.255402 (W 0.078387) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 214.787 ± 0.235287 (W 0.302608) | 236.429 ± 2.2589 (W 0.664452) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.57387 ± 0.0123338 (W 0.0085402) | 2.31237 ± 0.0149996 (W 0.0096554) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 20.0986 ± 0.125789 (W 0.0331224) | 16.2856 ± 0.194651 (W 0.0410296) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 115.033 ± 0.0646251 (W 0.104781) | 99.82 ± 0.950644 (W 0.314254) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007664 ± 6.23017e-05 (W 8.02305e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0235285 ± 0.000158306 (W 7.6083e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.086101 ± 0.000847112 (W 0.00165304) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189083 ± 0.00261602 (W 0.002334) | 0.267834 ± 0.00418243 (W 0.00544615) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.851878 ± 0.00969906 (W 0.00724249) | 1.39839 ± 0.00960515 (W 0.00432414) | 🔵 fork 1.64× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.38708 ± 0.0283658 (W 0.0208644) | 7.01022 ± 0.063355 (W 0.0274101) | 🔵 fork 2.07× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.98365 ± 0.0151919 (W 0.0273754) | 2.65143 ± 0.00348213 (W 0.00414012) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 11.4713 ± 0.0331964 (W 0.0490092) | 12.0876 ± 0.0459632 (W 0.0119123) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 46.7814 ± 0.124543 (W 0.086599) | 55.716 ± 0.187288 (W 0.0657368) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.78073 ± 0.00456704 (W 0.00359307) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.93193 ± 0.0238476 (W 0.0209199) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.1988 ± 0.100896 (W 0.0861671) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.288706 ± 0.000672539 (W 0.00180594) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.290795 ± 0.107578 (W 0.00231776) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.95105 ± 0.00928031 (W 0.00429857) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94446 ± 0.0126811 (W 0.0053628) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7874 ± 0.0828301 (W 0.0190549) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8474 ± 0.0425321 (W 0.0247786) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.325952 ± 0.000823894 (W 0.00224561) | 0.314913 ± 0.00221978 (W 0.00283271) | · |  |
| `lu/n256/b1` | 1.56981 ± 0.0105435 (W 0.0181573) | 1.70406 ± 0.0535904 (W 0.00466813) | 🔵 fork 1.09× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 7.38256 ± 0.0285403 (W 0.0250851) | 7.49326 ± 0.0357907 (W 0.0291649) | · |  |
| `qr/n128/b1` | 1.02823 ± 0.00480623 (W 0.00779142) | 1.46931 ± 0.00442737 (W 0.00558742) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 4.61061 ± 0.0305813 (W 0.0370729) | 7.11763 ± 0.0205051 (W 0.00876863) | 🔵 fork 1.54× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 23.5375 ± 0.0405493 (W 0.0729085) | 34.9376 ± 0.0783031 (W 0.0397317) | 🔵 fork 1.48× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.607473 ± 0.00315228 (W 0.00206718) | 0.737274 ± 0.00183071 (W 0.00273741) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.93788 ± 0.0293224 (W 0.0522326) | 3.53392 ± 0.0207463 (W 0.00568348) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 12.1331 ± 0.0911042 (W 0.0735118) | 17.2256 ± 0.0376284 (W 0.0418566) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.323987 ± 0.000426076 (W 0.00222498) | 0.30989 ± 0.00433987 (W 0.00318201) | · |  |
| `solve/n256/b1` | 1.45694 ± 0.00593867 (W 0.0140905) | 1.6729 ± 0.00447048 (W 0.00362423) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 7.28835 ± 0.0106095 (W 0.0306461) | 7.62789 ± 0.246922 (W 0.0220203) | · | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 4.44871 ± 0.0165026 (W 0.0270099) | 4.83879 ± 0.0202737 (W 0.0114184) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 23.2584 ± 0.0917972 (W 0.0942506) | 23.5055 ± 0.0878662 (W 0.0262404) | · |  |
| `svd_thin/n512/b1` | 96.3658 ± 0.264271 (W 0.272112) | 119.429 ± 2.42494 (W 0.212133) | 🔵 fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 3.14144 ± 0.00851355 (W 0.00712717) | 2.47408 ± 0.00656855 (W 0.00509628) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.7816 ± 0.0749276 (W 0.0628451) | 12.0849 ± 0.111418 (W 0.0280976) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 66.4355 ± 0.259922 (W 0.201132) | 54.0025 ± 0.385683 (W 0.0466044) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007584 ± 3.48162e-05 (W 3.34664e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023438 ± 0.000179665 (W 6.21119e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0717735 ± 0.00418487 (W 0.00133494) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.195152 ± 0.110407 (W 0.00369993) | 0.299855 ± 0.00167685 (W 0.0026983) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.837948 ± 0.0131434 (W 0.0161881) | 1.36854 ± 0.0127886 (W 0.00319319) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.81293 ± 0.0468359 (W 0.0212804) | 5.84397 ± 0.0247094 (W 0.0193317) | 🔵 fork 2.08× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.95948 ± 0.088517 (W 0.0315654) | 2.5598 ± 0.00933956 (W 0.00712377) | 🔴 fork 1.16× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n256/b1` | 10.8401 ± 0.026946 (W 0.0283694) | 10.8511 ± 0.040669 (W 0.0164236) | · |  |
| `eigh/n512/b1` | 39.2524 ± 0.0959545 (W 0.0971937) | 43.2261 ± 0.0577785 (W 0.103145) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.780568 ± 0.00342904 (W 0.00479796) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.94645 ± 0.0253385 (W 0.0122258) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.4881 ± 0.54194 (W 0.114875) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.185124 ± 0.00133589 (W 0.00133281) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.186002 ± 0.00116771 (W 0.00146925) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01479 ± 0.00302437 (W 0.00397374) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01528 ± 0.00538606 (W 0.00320559) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.13904 ± 0.0419895 (W 0.0950121) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.08904 ± 0.0724984 (W 0.0519088) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.325381 ± 0.00252002 (W 0.00210069) | 0.303939 ± 0.00164364 (W 0.00230471) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.54002 ± 0.0100971 (W 0.0124283) | 1.31489 ± 0.00118542 (W 0.00377859) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.27728 ± 0.0556116 (W 0.0443542) | 5.13347 ± 0.138177 (W 0.0129622) | 🔴 fork 1.22× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 1.0012 ± 0.00737542 (W 0.0232848) | 1.4622 ± 0.00753017 (W 0.00589678) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.49131 ± 0.00950964 (W 0.016979) | 6.53456 ± 0.0126936 (W 0.0120537) | 🔵 fork 1.87× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 16.1881 ± 0.0768602 (W 0.0717874) | 28.3856 ± 0.576564 (W 0.0365238) | 🔵 fork 1.75× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.615999 ± 0.0394917 (W 0.00510099) | 0.73205 ± 0.00344847 (W 0.00441212) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.45392 ± 0.0169771 (W 0.0207423) | 3.24108 ± 0.0266594 (W 0.00690736) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 9.41251 ± 0.0152781 (W 0.0368303) | 13.8803 ± 0.393808 (W 0.0189962) | 🔵 fork 1.47× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.324918 ± 0.00203129 (W 0.00232221) | 0.303721 ± 0.00235333 (W 0.00374589) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.40333 ± 0.00994941 (W 0.0187751) | 1.30707 ± 0.0459512 (W 0.00446714) | 🔴 fork 1.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 6.14697 ± 0.0417525 (W 0.0416315) | 5.13885 ± 0.068371 (W 0.00735501) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.35777 ± 0.0219052 (W 0.020563) | 4.79077 ± 0.00876144 (W 0.00473141) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 22.0211 ± 0.0664352 (W 0.117682) | 21.9411 ± 0.352671 (W 0.0442228) | · |  |
| `svd_thin/n512/b1` | 81.331 ± 0.215013 (W 0.20737) | 100.982 ± 2.34082 (W 0.316176) | 🔵 fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 3.14424 ± 0.0230948 (W 0.0117461) | 2.57866 ± 0.00695385 (W 0.00784467) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.8091 ± 0.0521697 (W 0.0405001) | 11.9436 ± 0.0992402 (W 0.0227063) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 62.0544 ± 0.248794 (W 0.27035) | 48.4801 ± 0.246033 (W 0.0596235) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007589 ± 2.43619e-05 (W 7.04431e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023489 ± 0.000217192 (W 7.27333e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0722545 ± 0.00311134 (W 0.00229092) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174926 ± 0.000942422 (W 0.00149587) | 0.184785 ± 0.00121435 (W 0.00132899) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.13367 ± 0.00235999 (W 0.00194613) | 1.30361 ± 0.0108972 (W 0.0033068) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.53884 ± 0.100994 (W 0.0159453) | 9.02533 ± 0.0105538 (W 0.0250814) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.27856 ± 0.00753702 (W 0.00784499) | 3.25004 ± 0.00943567 (W 0.00720257) | · |  |
| `eigh/n256/b1` | 17.4163 ± 0.0439071 (W 0.0379305) | 19.5957 ± 0.0889953 (W 0.0315496) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.521 ± 0.158953 (W 0.0975563) | 138.398 ± 1.4738 (W 0.319544) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.749428 ± 0.00287979 (W 0.00560788) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.7879 ± 0.0189404 (W 0.0102016) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 39.7639 ± 0.0539903 (W 0.0502919) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03921 ± 0.00213658 (W 0.00246373) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04318 ± 0.00213379 (W 0.0015461) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.41766 ± 0.0414396 (W 0.0207653) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44703 ± 0.014246 (W 0.013977) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9056 ± 0.134333 (W 0.12075) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7011 ± 0.101458 (W 0.0998192) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.294398 ± 0.00155868 (W 0.00193051) | 0.350127 ± 0.00187079 (W 0.00228441) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.01333 ± 0.0133469 (W 0.00357007) | 2.3328 ± 0.0208637 (W 0.00392272) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 13.8507 ± 0.0563661 (W 0.0354383) | 16.3434 ± 0.098592 (W 0.0395246) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.5416 ± 0.00177553 (W 0.00245151) | 1.5447 ± 0.00803159 (W 0.00441573) | · |  |
| `qr/n256/b1` | 10.0764 ± 0.0233504 (W 0.0233655) | 10.792 ± 0.04006 (W 0.0195681) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 68.987 ± 0.118988 (W 0.0913761) | 73.0795 ± 0.463819 (W 0.072577) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.752483 ± 0.00424932 (W 0.00216874) | 0.750587 ± 0.00316452 (W 0.00223836) | · |  |
| `qr_factor/n256/b1` | 4.47177 ± 0.0300503 (W 0.0074097) | 5.22321 ± 0.013577 (W 0.00907655) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 28.9502 ± 0.187513 (W 0.0387383) | 35.4634 ± 0.151848 (W 0.0522627) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.293944 ± 0.00146544 (W 0.0020187) | 0.367765 ± 0.0037283 (W 0.00216164) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.94001 ± 0.00720582 (W 0.00196635) | 2.42998 ± 0.047577 (W 0.00786023) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 13.8777 ± 0.0221519 (W 0.0346221) | 16.5504 ± 0.0694206 (W 0.0316217) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.80229 ± 0.0154204 (W 0.0101246) | 5.49951 ± 0.0191166 (W 0.0147482) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 34.5823 ± 0.124518 (W 0.0607764) | 35.7956 ± 0.151683 (W 0.0522473) | · |  |
| `svd_thin/n512/b1` | 213.516 ± 0.225961 (W 0.532452) | 232.247 ± 1.20914 (W 0.470387) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.54704 ± 0.00974549 (W 0.00451668) | 2.24115 ± 0.0168049 (W 0.00378514) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.7789 ± 0.114295 (W 0.0314402) | 15.7129 ± 0.0540148 (W 0.0230344) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 114.017 ± 0.123761 (W 0.192858) | 97.9454 ± 1.00327 (W 0.18188) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0080905 ± 0.000109217 (W 5.78572e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0252125 ± 0.000342205 (W 3.63207e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0895905 ± 0.00159076 (W 0.000954491) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.177164 ± 0.00176504 (W 0.00239924) | 0.125461 ± 0.00125201 (W 0.00446839) | 🔴 fork 1.41× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.756135 ± 0.00755384 (W 0.0095944) | 0.592395 ± 0.00283419 (W 0.00185245) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.02307 ± 0.012911 (W 0.0227729) | 3.55833 ± 0.0967642 (W 0.0150235) | 🔵 fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n128/b1` | 3.00976 ± 0.0134264 (W 0.0256926) | 2.54252 ± 0.00435199 (W 0.00333488) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 11.4398 ± 0.0370618 (W 0.0607201) | 11.3858 ± 0.0353692 (W 0.0114506) | · |  |
| `eigh/n512/b1` | 46.3834 ± 0.167701 (W 0.0938796) | 52.9342 ± 0.265772 (W 0.0437552) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.753552 ± 0.00520184 (W 0.00525307) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.79506 ± 0.0217807 (W 0.0157522) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.3484 ± 0.155877 (W 0.11156) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.297263 ± 0.00197094 (W 0.00382837) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.299128 ± 0.00229585 (W 0.00291137) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93323 ± 0.00383014 (W 0.00732947) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94499 ± 0.0171407 (W 0.00370633) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.8357 ± 0.0209377 (W 0.0277924) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8105 ± 0.0254746 (W 0.0337311) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.295707 ± 0.000746588 (W 0.0021223) | 0.23928 ± 0.00059547 (W 0.00156859) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.45258 ± 0.0119359 (W 0.0185052) | 1.2671 ± 0.00353551 (W 0.0017698) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.52841 ± 0.0308666 (W 0.0321747) | 5.49989 ± 0.0223313 (W 0.00940798) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.99959 ± 0.0499448 (W 0.00481355) | 1.36999 ± 0.00459594 (W 0.00510468) | 🔵 fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 4.49144 ± 0.0214776 (W 0.0340456) | 6.57103 ± 0.0350907 (W 0.0133889) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 22.6186 ± 0.0287086 (W 0.0557737) | 32.3922 ± 0.209955 (W 0.0362473) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.550442 ± 0.00251476 (W 0.00335459) | 0.663131 ± 0.00314542 (W 0.00196412) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.79938 ± 0.032599 (W 0.0341471) | 3.08797 ± 0.00557064 (W 0.00556449) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 11.3844 ± 0.0337782 (W 0.103215) | 15.2901 ± 0.0486121 (W 0.0161039) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.293303 ± 0.00146474 (W 0.0022682) | 0.238187 ± 0.0011984 (W 0.0019148) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.33474 ± 0.0079228 (W 0.0173203) | 1.25603 ± 0.000621152 (W 0.00280352) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 6.40631 ± 0.0222512 (W 0.0264429) | 5.51929 ± 0.0182569 (W 0.00866703) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.4094 ± 0.0122764 (W 0.0187051) | 4.6558 ± 0.00544164 (W 0.00600029) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 22.9707 ± 0.068968 (W 0.0980955) | 22.4972 ± 0.111133 (W 0.0359348) | · |  |
| `svd_thin/n512/b1` | 95.587 ± 1.12529 (W 0.194803) | 114.033 ± 1.73573 (W 0.387481) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.11738 ± 0.00943562 (W 0.00918282) | 2.39819 ± 0.0032558 (W 0.00511836) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.5013 ± 0.082715 (W 0.0477963) | 11.6539 ± 0.0892092 (W 0.0158185) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.5201 ± 0.300096 (W 0.296439) | 51.9852 ± 0.351848 (W 0.0306447) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.008125 ± 0.000195796 (W 2.55168e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024706 ± 0.000449621 (W 7.23414e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.077268 ± 0.00240829 (W 0.00165869) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.182688 ± 0.000569741 (W 0.00170873) | 0.157632 ± 0.000767998 (W 0.00176299) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.743975 ± 0.00523804 (W 0.0206919) | 0.551001 ± 0.00427029 (W 0.00318989) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.44598 ± 0.0280379 (W 0.0235376) | 2.46444 ± 0.00924894 (W 0.00900075) | · |  |
| `eigh/n128/b1` | 2.9598 ± 0.024862 (W 0.0244422) | 2.45053 ± 0.00615645 (W 0.00522254) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.7983 ± 0.0199244 (W 0.0402877) | 10.1837 ± 0.0280025 (W 0.0198619) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 38.9471 ± 0.206643 (W 0.106944) | 40.4 ± 1.68781 (W 0.222384) | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.751416 ± 0.0064282 (W 0.00540532) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.796 ± 0.0269955 (W 0.0136482) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.6459 ± 0.093169 (W 0.123203) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.195454 ± 0.000887569 (W 0.00234058) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.198672 ± 0.00181122 (W 0.00324643) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.02159 ± 0.00251329 (W 0.00402288) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.0284 ± 0.00501609 (W 0.00502396) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.2453 ± 0.0880946 (W 0.0369658) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.20571 ± 0.0332036 (W 0.0381739) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.29532 ± 0.00309437 (W 0.00185792) | 0.226606 ± 0.00144814 (W 0.00215701) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.41412 ± 0.00625903 (W 0.0140274) | 0.888911 ± 0.00292684 (W 0.00254496) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 5.43827 ± 0.0354945 (W 0.0410907) | 3.2352 ± 0.00804843 (W 0.00452975) | 🔴 fork 1.68× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.962365 ± 0.0174496 (W 0.0166821) | 1.363 ± 0.00714601 (W 0.00402439) | 🔵 fork 1.42× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n256/b1` | 3.3414 ± 0.0193226 (W 0.017578) | 6.00407 ± 0.0431526 (W 0.00896414) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 15.2331 ± 0.0309971 (W 0.0318788) | 25.806 ± 0.107702 (W 0.0404504) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.558465 ± 0.00410415 (W 0.00357347) | 0.655699 ± 0.00404515 (W 0.00238295) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.30983 ± 0.0164047 (W 0.0149128) | 2.79516 ± 0.028966 (W 0.00565412) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.83319 ± 0.0337925 (W 0.027891) | 12.0354 ± 0.0289885 (W 0.0163344) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.293058 ± 0.00252881 (W 0.00220834) | 0.228607 ± 0.00265147 (W 0.00217906) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.28831 ± 0.00611901 (W 0.0145727) | 0.905987 ± 0.00463576 (W 0.00338875) | 🔴 fork 1.42× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 5.28879 ± 0.0335268 (W 0.0317247) | 3.31318 ± 0.0178177 (W 0.00628593) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.33595 ± 0.0168973 (W 0.0141099) | 4.63252 ± 0.0131384 (W 0.0116229) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 21.781 ± 0.0342691 (W 0.116269) | 20.8024 ± 0.0710592 (W 0.0473293) | · |  |
| `svd_thin/n512/b1` | 79.95 ± 0.213187 (W 0.268159) | 95.2125 ± 2.01306 (W 0.344795) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 3.15299 ± 0.0278032 (W 0.00607186) | 2.50759 ± 0.00659712 (W 0.005101) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.5826 ± 0.0491925 (W 0.0823897) | 11.5108 ± 0.648771 (W 0.0247866) | 🔴 fork 1.53× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 61.2644 ± 0.108424 (W 0.195654) | 46.3053 ± 0.132795 (W 0.0473595) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0082055 ± 0.000116669 (W 2.87046e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0248415 ± 0.000288643 (W 6.7856e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.078797 ± 0.00388299 (W 0.00211239) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.835955 ± 0.00341933 (W 0.00537386) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.1932 ± 0.746858 (W 0.280862) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.552923 ± 0.00178092 (W 0.00226829) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.555744 ± 0.0028775 (W 0.00226525) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.2651 ± 0.0330234 (W 0.0497722) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.3592 ± 0.85362 (W 0.0650458) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.491362 ± 0.00316314 (W 0.00303246) | 0.737832 ± 0.128768 (W 0.00337961) | 🔵 fork 1.50× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.5966 ± 0.137637 (W 0.0851513) | 28.1133 ± 0.858759 (W 0.067019) | 🔵 fork 1.80× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.59055 ± 0.00191408 (W 0.0037999) | 2.49236 ± 0.00866413 (W 0.012706) | 🔵 fork 1.57× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 71.1886 ± 0.19937 (W 0.0756162) | 106.143 ± 1.53809 (W 1.24098) | 🔵 fork 1.49× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.0591 ± 0.00264175 (W 0.0023439) | 1.26741 ± 0.00828765 (W 0.0108459) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 31.8366 ± 0.637801 (W 0.134991) | 50.4938 ± 1.09039 (W 0.587082) | 🔵 fork 1.59× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.50325 ± 0.00982853 (W 0.00776655) | 3.76466 ± 0.0255042 (W 0.00712835) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 88.4542 ± 0.0884266 (W 0.17486) | 147.766 ± 1.05435 (W 1.29539) | 🔵 fork 1.67× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.49366 ± 0.00369593 (W 0.00541901) | 1.92012 ± 0.00466698 (W 0.00366711) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 44.8651 ± 0.0446733 (W 0.0692139) | 69.0914 ± 3.37119 (W 0.592044) | 🔵 fork 1.54× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.831058 ± 0.00284211 (W 0.00194552) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 20.076 ± 0.173205 (W 0.131912) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.186457 ± 0.0027522 (W 0.00152293) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.188775 ± 0.00376902 (W 0.00579207) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.2707 ± 0.104718 (W 0.125651) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.2796 ± 0.12536 (W 0.106335) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.515224 ± 0.005751 (W 0.0118367) | 0.679347 ± 0.131279 (W 0.00274274) | 🔵 fork 1.32× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.72031 ± 0.194982 (W 0.0596085) | 22.3628 ± 0.364803 (W 0.0662903) | 🔵 fork 2.30× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.31804 ± 0.00807989 (W 0.0161111) | 2.59988 ± 0.0164991 (W 0.00496903) | 🔵 fork 1.97× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 28.6737 ± 0.175253 (W 0.240864) | 67.1132 ± 1.73026 (W 0.411183) | 🔵 fork 2.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.04967 ± 0.011692 (W 0.00948951) | 1.32058 ± 0.0109145 (W 0.00371683) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 15.8838 ± 0.138095 (W 0.243643) | 32.4578 ± 0.723184 (W 0.157993) | 🔵 fork 2.04× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.41337 ± 0.0876585 (W 0.0248668) | 3.63603 ± 0.030993 (W 0.0107585) | 🔵 fork 1.51× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 46.7149 ± 0.251693 (W 0.300532) | 84.4097 ± 1.20345 (W 0.694466) | 🔵 fork 1.81× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.66756 ± 0.0205257 (W 0.0149054) | 1.98627 ± 0.0103569 (W 0.00388305) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 31.4318 ± 0.123037 (W 0.219748) | 48.9323 ± 0.880391 (W 0.131253) | 🔵 fork 1.56× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.835804 ± 0.00517158 (W 0.00291591) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 16.1279 ± 0.121496 (W 0.116016) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.154914 ± 0.00578555 (W 0.00260454) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.158796 ± 0.00535943 (W 0.00339338) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.57043 ± 0.0427302 (W 0.0780692) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.62063 ± 0.059153 (W 0.107512) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.499888 ± 0.0019536 (W 0.00675923) | 0.654816 ± 0.128153 (W 0.00330743) | 🔵 fork 1.31× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.00505 ± 0.106408 (W 0.0375332) | 19.8445 ± 0.422459 (W 0.0710099) | 🔵 fork 2.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.43205 ± 0.0197163 (W 0.0231884) | 2.58686 ± 0.0184232 (W 0.00614971) | 🔵 fork 1.81× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 22.4024 ± 2.21952 (W 0.159277) | 62.2498 ± 0.344389 (W 1.01588) | 🔵 fork 2.78× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.1282 ± 0.0098544 (W 0.0148448) | 1.3289 ± 0.00757482 (W 0.00413527) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 13.0149 ± 0.146568 (W 0.087561) | 30.0692 ± 0.953646 (W 0.46625) | 🔵 fork 2.31× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.53742 ± 0.0192017 (W 0.0163625) | 3.58804 ± 0.0279443 (W 0.0113754) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 40.8385 ± 3.71744 (W 0.869334) | 77.3266 ± 0.889019 (W 0.79051) | 🔵 fork 1.89× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.77873 ± 0.016393 (W 0.015775) | 1.98826 ± 0.0114572 (W 0.0075468) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 29.7649 ± 0.881566 (W 0.282012) | 45.4815 ± 0.501898 (W 0.377844) | 🔵 fork 1.53× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731563 ± 0.00185544 (W 0.00998397) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.0053 ± 0.425331 (W 0.110535) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.581242 ± 0.0131582 (W 0.0022595) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.597931 ± 0.00652116 (W 0.00269474) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.9006 ± 0.0829151 (W 0.0686242) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.9386 ± 0.0664387 (W 0.0500851) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.386114 ± 0.0023524 (W 0.00242943) | 0.305557 ± 0.000904355 (W 0.00231011) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.2287 ± 0.0370202 (W 0.0225389) | 12.9735 ± 0.116534 (W 0.0360306) | · |  |
| `qr/1024x64/b1` | 1.47134 ± 0.00468936 (W 0.0038399) | 1.87207 ± 0.00680946 (W 0.00257403) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 68.6834 ± 0.226917 (W 0.0958926) | 77.7772 ± 0.635008 (W 0.2682) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.773786 ± 0.0034521 (W 0.00388887) | 0.957815 ± 0.00250982 (W 0.0020207) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 25.7923 ± 0.0386885 (W 0.0394549) | 38.7496 ± 0.310181 (W 0.315321) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.45107 ± 0.00930416 (W 0.00407842) | 3.23835 ± 0.00720617 (W 0.00754735) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 83.0424 ± 0.101878 (W 0.0793033) | 120.511 ± 0.890621 (W 0.337138) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.40363 ± 0.00385898 (W 0.00357653) | 1.60524 ± 0.00422182 (W 0.00389614) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 39.0874 ± 0.083345 (W 0.0875739) | 54.8666 ± 0.700355 (W 0.120127) | 🔵 fork 1.40× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.733722 ± 0.00333791 (W 0.00512104) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.7813 ± 0.101321 (W 0.169466) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.199358 ± 0.00691323 (W 0.0037881) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.206035 ± 0.00605203 (W 0.00737381) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.332 ± 0.0525892 (W 0.0423432) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.252 ± 0.050378 (W 0.0251749) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.408132 ± 0.00364138 (W 0.0123333) | 0.251714 ± 0.0128673 (W 0.00216895) | 🔴 fork 1.62× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 7.36625 ± 0.0341667 (W 0.0336645) | 7.22651 ± 0.0365481 (W 0.00825374) | · |  |
| `qr/1024x64/b1` | 1.20673 ± 0.0104835 (W 0.00771812) | 1.96561 ± 0.0231269 (W 0.00257973) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 25.9353 ± 0.224405 (W 0.291797) | 41.3134 ± 0.20941 (W 0.0387516) | 🔵 fork 1.59× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.916146 ± 0.00513872 (W 0.00658255) | 1.02364 ± 0.00482594 (W 0.0034489) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 13.6037 ± 0.209413 (W 0.237464) | 20.6739 ± 0.13255 (W 0.0264746) | 🔵 fork 1.52× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.33136 ± 0.0248079 (W 0.0321293) | 3.08525 ± 0.013069 (W 0.00364867) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 41.2629 ± 0.188514 (W 0.283495) | 67.2685 ± 0.256311 (W 0.26288) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.57739 ± 0.0113175 (W 0.0182451) | 1.68597 ± 0.0130624 (W 0.00296246) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 25.8412 ± 0.18519 (W 0.184491) | 36.3895 ± 0.198258 (W 0.0461483) | 🔵 fork 1.41× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731672 ± 0.00661481 (W 0.00240928) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.7334 ± 0.0835998 (W 0.119495) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.161545 ± 0.00527706 (W 0.00363672) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.164128 ± 0.00564793 (W 0.00353068) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.65663 ± 0.0869293 (W 0.467482) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.63508 ± 0.141043 (W 0.156506) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.391019 ± 0.00532993 (W 0.00406026) | 0.235648 ± 0.00136109 (W 0.00172797) | 🔴 fork 1.66× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 6.64655 ± 0.0227565 (W 0.0319887) | 4.73858 ± 0.204586 (W 0.0101591) | 🔴 fork 1.40× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.3375 ± 0.0483558 (W 0.018246) | 1.98553 ± 0.0102604 (W 0.00281193) | 🔵 fork 1.48× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 19.9588 ± 2.01856 (W 0.0923518) | 36.824 ± 0.451476 (W 0.0481273) | 🔵 fork 1.84× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.03143 ± 0.00878757 (W 0.0175104) | 1.02937 ± 0.00369837 (W 0.00204755) | · |  |
| `qr_factor/4096x256/b1` | 11.6394 ± 0.0590081 (W 0.0442881) | 18.0835 ± 0.236885 (W 0.0352512) | 🔵 fork 1.55× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.47801 ± 0.0191766 (W 0.0193829) | 3.07761 ± 0.0226283 (W 0.00389031) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 35.2693 ± 0.148359 (W 0.142517) | 59.6594 ± 0.288234 (W 0.283743) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.71157 ± 0.01495 (W 0.0209898) | 1.6847 ± 0.00865339 (W 0.00249333) | · |  |
| `svd_values/4096x256/b1` | 24.1936 ± 0.0623609 (W 0.0614198) | 33.7889 ± 0.44189 (W 0.0443292) | 🔵 fork 1.40× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79565 ± 0.00861782 (W 0.00473764) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 149.578 ± 0.704034 (W 0.608018) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19504 ± 0.00571259 (W 0.00372247) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20393 ± 0.00268993 (W 0.00453367) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.792 ± 0.0968777 (W 0.136408) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.071 ± 0.136015 (W 0.348951) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.01794 ± 0.00533419 (W 0.00182053) | 1.29696 ± 0.0062604 (W 0.00553877) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 47.3142 ± 0.224364 (W 0.0986305) | 69.288 ± 4.86867 (W 0.294232) | 🔵 fork 1.46× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 4.74973 ± 0.0149628 (W 0.0118144) | 4.33816 ± 0.0256999 (W 0.00905367) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 245.019 ± 5.85365 (W 0.438847) | 262.72 ± 4.16237 (W 1.62303) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.55058 ± 0.0271219 (W 0.00600255) | 2.19654 ± 0.0121268 (W 0.00421474) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 101.092 ± 0.211661 (W 0.256558) | 131.14 ± 1.65521 (W 0.498052) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 6.00216 ± 0.0281513 (W 0.0095314) | 6.8894 ± 0.0705916 (W 0.014366) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 281.647 ± 0.461416 (W 1.31658) | 385.336 ± 2.81353 (W 1.237) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 3.07605 ± 0.0169059 (W 0.00644995) | 3.15395 ± 0.0251845 (W 0.00758504) | · |  |
| `svd_values/4096x256/b1` | 124.039 ± 1.23481 (W 0.48235) | 155.686 ± 0.849367 (W 1.01879) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.79095 ± 0.00932539 (W 0.00404594) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.451 ± 0.307514 (W 0.672038) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.629842 ± 0.0146881 (W 0.0119316) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.62028 ± 0.00954157 (W 0.00658493) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.279 ± 0.0929957 (W 0.17566) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.1145 ± 0.0831285 (W 0.225063) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.847269 ± 0.00611262 (W 0.0131908) | 1.01894 ± 0.031032 (W 0.00207043) | 🔵 fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 23.2622 ± 0.275553 (W 0.176716) | 42.0348 ± 3.30028 (W 0.144132) | 🔵 fork 1.81× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.71532 ± 0.0951512 (W 0.0589575) | 2.22448 ± 0.0620093 (W 0.00396238) | 🔴 fork 1.22× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 84.3105 ± 0.135504 (W 0.225937) | 113.228 ± 2.49033 (W 1.67023) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.96704 ± 0.101817 (W 0.0885357) | 1.15159 ± 0.0187797 (W 0.00163077) | 🔴 fork 1.71× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 40.5107 ± 0.168643 (W 0.117438) | 57.4352 ± 1.02764 (W 0.893967) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 4.09531 ± 0.0934255 (W 0.0988281) | 3.74675 ± 0.0721095 (W 0.00596152) | 🔴 fork 1.09× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 115.451 ± 0.15787 (W 0.265957) | 151.146 ± 2.64101 (W 0.530955) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.67941 ± 0.0756931 (W 0.0443071) | 2.09043 ± 0.0139483 (W 0.00446666) | 🔴 fork 1.28× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 67.5792 ± 0.411169 (W 0.243791) | 78.3551 ± 1.65133 (W 0.72249) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.7964 ± 0.00899241 (W 0.00359327) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.6413 ± 0.387895 (W 0.728353) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.414938 ± 0.00949093 (W 0.00709263) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.418982 ± 0.011402 (W 0.00753101) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.657 ± 0.147212 (W 0.373104) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.776 ± 0.303151 (W 0.343015) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.833895 ± 0.00400115 (W 0.0136735) | 0.934041 ± 0.0162132 (W 0.00280147) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 19.2392 ± 0.283085 (W 0.334785) | 40.1431 ± 4.48033 (W 0.135816) | 🔵 fork 2.09× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 2.48647 ± 0.00854642 (W 0.0205938) | 1.9728 ± 0.0564492 (W 0.0147967) | 🔴 fork 1.26× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 68.5008 ± 5.61711 (W 0.372693) | 84.8461 ± 0.729182 (W 0.294169) | 🔵 fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.87751 ± 0.00881712 (W 0.0127772) | 0.985974 ± 0.0100325 (W 0.00250832) | 🔴 fork 1.90× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 30.6271 ± 0.121843 (W 0.106631) | 42.1683 ± 0.407739 (W 0.20549) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.89173 ± 0.0391617 (W 0.0225412) | 3.36852 ± 0.0629985 (W 0.00840559) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 89.0879 ± 0.335405 (W 0.331511) | 111.007 ± 0.807356 (W 0.818462) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.68781 ± 0.0170652 (W 0.0197607) | 1.97209 ± 0.0141374 (W 0.00483546) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 59.471 ± 0.404108 (W 0.519084) | 62.7245 ± 0.399544 (W 0.258496) | 🔵 fork 1.05× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.67091 ± 0.00736095 (W 0.00337978) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.739 ± 0.647709 (W 0.561728) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.2618 ± 0.0148844 (W 0.00515285) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26784 ± 0.0126089 (W 0.00857785) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.779 ± 0.20506 (W 0.381785) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.825 ± 0.20319 (W 0.23373) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.883622 ± 0.00399973 (W 0.00202604) | 0.941038 ± 0.00470673 (W 0.00159185) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 41.7933 ± 0.126978 (W 0.0753409) | 47.2455 ± 0.0272917 (W 0.0634834) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 4.62568 ± 0.013463 (W 0.0140399) | 3.55453 ± 0.0274925 (W 0.00465307) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 239.295 ± 5.51932 (W 0.376134) | 222.571 ± 0.451307 (W 0.421465) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.23623 ± 0.0423757 (W 0.00431106) | 1.82282 ± 0.0118062 (W 0.00264284) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 90.1994 ± 0.107613 (W 0.267248) | 111.636 ± 0.120475 (W 0.274903) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.90161 ± 0.0217442 (W 0.0132943) | 6.25172 ± 0.0385426 (W 0.0126657) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 269.377 ± 0.149051 (W 0.335225) | 353.108 ± 5.96656 (W 0.715485) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.9583 ± 0.0108647 (W 0.00616259) | 2.75204 ± 0.0164286 (W 0.00585386) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 110.985 ± 0.155908 (W 0.117565) | 136.832 ± 0.273284 (W 0.479323) | 🔵 fork 1.23× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6675 ± 0.00710067 (W 0.00426676) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.6392 ± 0.397981 (W 0.430084) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.652805 ± 0.014376 (W 0.00853971) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.65196 ± 0.0114953 (W 0.00814954) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.3977 ± 0.0809966 (W 0.0729242) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.2767 ± 0.167723 (W 0.0805492) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.722522 ± 0.00413307 (W 0.011246) | 0.688526 ± 0.0021016 (W 0.00262267) | · |  |
| `lu/4096x256/b1` | 17.5702 ± 0.0886062 (W 0.0740999) | 24.2684 ± 0.024332 (W 0.0317581) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 2.55639 ± 0.0930027 (W 0.0256355) | 1.46423 ± 0.00142441 (W 0.00245701) | 🔴 fork 1.75× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 78.6541 ± 0.421553 (W 0.310297) | 73.5477 ± 0.245126 (W 0.113497) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.76563 ± 0.0481445 (W 0.0534844) | 0.784085 ± 0.00133748 (W 0.00208737) | 🔴 fork 2.25× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 35.9159 ± 0.0502882 (W 0.238554) | 36.6489 ± 0.106969 (W 0.0421606) | · |  |
| `svd_thin/1024x64/b1` | 3.97784 ± 0.0652968 (W 0.0950096) | 3.12888 ± 0.00794317 (W 0.00463939) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 103.682 ± 0.147815 (W 0.278775) | 123.572 ± 0.200265 (W 0.190418) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.57525 ± 0.00797944 (W 0.0120436) | 1.7352 ± 0.0176904 (W 0.00318008) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 55.8802 ± 0.1151 (W 0.176936) | 57.0446 ± 0.418462 (W 0.0741812) | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66654 ± 0.0121699 (W 0.00363837) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.0725 ± 0.462543 (W 0.745954) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.420905 ± 0.00977284 (W 0.0068267) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.421231 ± 0.0127748 (W 0.0084316) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.2722 ± 0.268749 (W 0.35305) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.3693 ± 0.344899 (W 1.92215) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.709658 ± 0.897919 (W 0.0149821) | 0.568124 ± 0.0035081 (W 0.00211884) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 13.6079 ± 0.11563 (W 0.0597575) | 14.5856 ± 0.0372868 (W 0.0518045) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 2.35245 ± 0.0153029 (W 0.0188008) | 1.16986 ± 0.00738463 (W 0.00320677) | 🔴 fork 2.01× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 62.5167 ± 5.33294 (W 0.261743) | 50.4632 ± 0.145488 (W 0.0746399) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.74308 ± 0.00997687 (W 0.0102803) | 0.640215 ± 0.00676295 (W 0.00187522) | 🔴 fork 2.72× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 27.7042 ± 0.209209 (W 0.0660904) | 25.0391 ± 0.217858 (W 0.0340968) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.77245 ± 0.0300678 (W 0.020399) | 2.69597 ± 0.00599573 (W 0.00326983) | 🔴 fork 1.40× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 76.7672 ± 0.180086 (W 0.38758) | 89.13 ± 0.472574 (W 0.0826181) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.59392 ± 0.0168161 (W 0.0226957) | 1.59087 ± 0.00613929 (W 0.00375854) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 47.9833 ± 0.105623 (W 0.15326) | 45.3838 ± 0.331854 (W 0.0483463) | 🔴 fork 1.06× slower than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 76.3614 ± 1.71852 (W 0.510365) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.12976 ± 0.00973402 (W 0.00501171) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.1163 ± 0.0784113 (W 0.0530634) | 35.3064 ± 0.226221 (W 0.113935) | 🔵 fork 2.19× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.414783 ± 0.00225099 (W 0.00225371) | 1.14204 ± 0.140883 (W 0.00479425) | 🔵 fork 2.75× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 30.8416 ± 0.248931 (W 0.109021) | 74.039 ± 2.16976 (W 0.322074) | 🔵 fork 2.40× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.757799 ± 0.00250693 (W 0.00222789) | 1.90699 ± 0.0125672 (W 0.0119344) | 🔵 fork 2.52× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 26.8593 ± 0.183688 (W 0.0726601) | 64.8302 ± 2.41916 (W 0.293265) | 🔵 fork 2.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.986296 ± 0.00968572 (W 0.00425525) | 1.72825 ± 0.0158012 (W 0.00894885) | 🔵 fork 1.75× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 83.3582 ± 0.215575 (W 0.223879) | 222.738 ± 2.8183 (W 1.12829) | 🔵 fork 2.67× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.45472 ± 0.00634363 (W 0.00363669) | 5.00347 ± 0.0254197 (W 0.0143005) | 🔵 fork 2.04× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 39.1499 ± 0.0476649 (W 0.0885359) | 106.708 ± 0.637164 (W 0.540349) | 🔵 fork 2.73× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.41409 ± 0.00461401 (W 0.00329401) | 2.58385 ± 0.0481973 (W 0.0199652) | 🔵 fork 1.83× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.8436 ± 0.373286 (W 0.183944) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.1343 ± 0.00597541 (W 0.00302256) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.22077 ± 0.169205 (W 0.0765946) | 26.5506 ± 0.141873 (W 0.0467191) | 🔵 fork 3.68× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.245878 ± 0.00199165 (W 0.00417583) | 0.798993 ± 0.00489867 (W 0.00164801) | 🔵 fork 3.25× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 11.6928 ± 0.11726 (W 0.111895) | 44.6314 ± 2.26539 (W 0.322347) | 🔵 fork 3.82× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.457123 ± 0.00329029 (W 0.00649198) | 1.72326 ± 0.00888641 (W 0.0110991) | 🔵 fork 3.77× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 10.5565 ± 0.174768 (W 0.056624) | 41.0904 ± 1.31445 (W 0.717641) | 🔵 fork 3.89× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.672169 ± 0.0157598 (W 0.00765092) | 1.54571 ± 0.016553 (W 0.0043848) | 🔵 fork 2.30× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 41.3529 ± 0.218114 (W 0.209014) | 146.261 ± 2.76951 (W 1.20212) | 🔵 fork 3.54× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.32373 ± 0.0129741 (W 0.0240005) | 4.49 ± 0.0719341 (W 0.014107) | 🔵 fork 1.93× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 25.7551 ± 0.167502 (W 0.26245) | 77.3057 ± 1.5535 (W 0.794729) | 🔵 fork 3.00× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.58762 ± 0.0056038 (W 0.0192499) | 2.4695 ± 0.020304 (W 0.00697882) | 🔵 fork 1.56× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 33.1917 ± 0.249667 (W 0.172006) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.13595 ± 0.0100108 (W 0.0029912) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.97696 ± 0.0545235 (W 0.0713735) | 24.1893 ± 1.40574 (W 0.0602989) | 🔵 fork 4.05× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.22555 ± 0.003147 (W 0.00310375) | 0.877974 ± 0.131757 (W 0.00219528) | 🔵 fork 3.89× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 8.45156 ± 0.058528 (W 0.103377) | 39.1137 ± 2.01491 (W 0.13259) | 🔵 fork 4.63× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.404965 ± 0.00254828 (W 0.00537801) | 1.78467 ± 0.0523943 (W 0.0148059) | 🔵 fork 4.41× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 7.92125 ± 0.0895028 (W 0.0625733) | 35.239 ± 0.231939 (W 0.0431863) | 🔵 fork 4.45× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.607251 ± 0.00340263 (W 0.00520098) | 1.59891 ± 0.0489026 (W 0.00717684) | 🔵 fork 2.63× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 35.2041 ± 0.097586 (W 0.113851) | 136.55 ± 5.50791 (W 1.34539) | 🔵 fork 3.88× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.48247 ± 0.00842905 (W 0.0152888) | 4.55317 ± 0.0172183 (W 0.0196609) | 🔵 fork 1.83× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 24.1868 ± 0.042591 (W 0.0847443) | 72.4483 ± 2.33773 (W 0.556713) | 🔵 fork 3.00× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.71625 ± 0.0112081 (W 0.0187949) | 2.51365 ± 0.0404233 (W 0.0116211) | 🔵 fork 1.46× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.9693 ± 1.56655 (W 0.386021) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.02814 ± 0.00814235 (W 0.00255467) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3207 ± 0.0432292 (W 0.0295558) | 20.302 ± 0.253607 (W 0.0622665) | 🔵 fork 1.52× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.310363 ± 0.000843312 (W 0.00202248) | 0.705919 ± 0.00298669 (W 0.00333453) | 🔵 fork 2.27× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 27.741 ± 0.12055 (W 0.0822934) | 75.1623 ± 1.90092 (W 0.44731) | 🔵 fork 2.71× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.628271 ± 0.00146753 (W 0.00211089) | 1.66895 ± 0.027671 (W 0.00848829) | 🔵 fork 2.66× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 24.8813 ± 0.287868 (W 0.0433517) | 54.9732 ± 2.5066 (W 0.307203) | 🔵 fork 2.21× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.566234 ± 0.00500926 (W 0.00217339) | 1.39198 ± 0.025189 (W 0.00510921) | 🔵 fork 2.46× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 88.6554 ± 0.283722 (W 0.215145) | 198.632 ± 4.09538 (W 0.739653) | 🔵 fork 2.24× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.51786 ± 0.00596499 (W 0.00646946) | 4.58234 ± 0.0278362 (W 0.0120165) | 🔵 fork 1.82× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 45.022 ± 0.0813102 (W 0.129851) | 93.736 ± 2.16989 (W 0.351099) | 🔵 fork 2.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.47819 ± 0.00519051 (W 0.00490188) | 2.2694 ± 0.041057 (W 0.0114604) | 🔵 fork 1.54× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 34.8085 ± 0.153887 (W 0.185593) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.03313 ± 0.00409318 (W 0.00320125) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.41493 ± 0.026056 (W 0.0269641) | 12.5894 ± 0.163664 (W 0.0147857) | 🔵 fork 2.85× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.136904 ± 0.00310129 (W 0.00348404) | 0.48998 ± 0.00220185 (W 0.00256541) | 🔵 fork 3.58× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 8.36035 ± 0.0777275 (W 0.0940572) | 43.9935 ± 1.4506 (W 0.0995729) | 🔵 fork 5.26× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.332305 ± 0.032947 (W 0.0137447) | 1.46791 ± 0.0116127 (W 0.00691062) | 🔵 fork 4.42× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 7.19991 ± 0.0650414 (W 0.0417541) | 29.9181 ± 0.548892 (W 0.458504) | 🔵 fork 4.16× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.252748 ± 0.00940138 (W 0.00185897) | 1.23729 ± 0.0131913 (W 0.0030548) | 🔵 fork 4.90× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 47.0624 ± 0.151199 (W 0.175349) | 128.484 ± 1.15802 (W 0.49254) | 🔵 fork 2.73× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.3988 ± 0.0242517 (W 0.0208953) | 4.04499 ± 0.0244355 (W 0.00948616) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 31.6952 ± 0.184297 (W 0.280407) | 66.3502 ± 0.695651 (W 0.13673) | 🔵 fork 2.09× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.6438 ± 0.0153832 (W 0.0123432) | 2.14669 ± 0.0227453 (W 0.00767005) | 🔵 fork 1.31× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.23 ± 0.340741 (W 0.156633) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.02928 ± 0.00314924 (W 0.00568609) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.92597 ± 0.0442406 (W 0.0175117) | 10.1245 ± 0.236049 (W 0.0225453) | 🔵 fork 3.46× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.115674 ± 0.00127148 (W 0.0018622) | 0.451806 ± 0.00592686 (W 0.00226813) | 🔵 fork 3.91× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 5.10327 ± 0.0834939 (W 0.0783417) | 38.9921 ± 2.58563 (W 0.361929) | 🔵 fork 7.64× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.271386 ± 0.00214441 (W 0.00310874) | 1.46767 ± 0.00711208 (W 0.00348913) | 🔵 fork 5.41× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 4.28054 ± 0.0574385 (W 0.0459735) | 25.2471 ± 0.14626 (W 0.0651978) | 🔵 fork 5.90× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.197072 ± 0.00112197 (W 0.00268659) | 1.24651 ± 0.00240919 (W 0.00389403) | 🔵 fork 6.33× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 40.8426 ± 0.0970206 (W 0.476377) | 118.695 ± 2.85149 (W 0.26326) | 🔵 fork 2.91× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.55863 ± 0.012937 (W 0.01933) | 4.0661 ± 0.047552 (W 0.009354) | 🔵 fork 1.59× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 29.9292 ± 0.56197 (W 0.346498) | 61.4255 ± 0.408395 (W 0.121668) | 🔵 fork 2.05× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.77907 ± 0.0127819 (W 0.0160419) | 2.14745 ± 0.0259062 (W 0.00660399) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 231.628 ± 5.1131 (W 0.8909) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.44582 ± 0.0124994 (W 0.0103507) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.3571 ± 0.161493 (W 0.109051) | 82.6184 ± 0.398305 (W 0.171945) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 1.00262 ± 0.00484911 (W 0.00618712) | 1.6459 ± 0.0194646 (W 0.00290778) | 🔵 fork 1.64× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 107.631 ± 0.526299 (W 0.450281) | 185.869 ± 3.50787 (W 2.05474) | 🔵 fork 1.73× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.54348 ± 0.00702642 (W 0.00847563) | 3.62821 ± 0.0385955 (W 0.00600227) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 96.7461 ± 0.699368 (W 0.222656) | 166.765 ± 3.97268 (W 1.74655) | 🔵 fork 1.72× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.57599 ± 0.0154172 (W 0.0070865) | 3.35116 ± 0.0345477 (W 0.00611442) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 270.24 ± 1.4038 (W 3.12559) | 694.949 ± 12.7533 (W 3.12148) | 🔵 fork 2.57× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 5.93358 ± 0.036445 (W 0.0132751) | 11.9508 ± 0.115007 (W 0.0249067) | 🔵 fork 2.01× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 110.922 ± 0.63927 (W 0.1031) | 309.523 ± 4.06272 (W 1.441) | 🔵 fork 2.79× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.94276 ± 0.0230289 (W 0.0064829) | 5.64833 ± 0.0610815 (W 0.014012) | 🔵 fork 1.92× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.6827 ± 2.37192 (W 0.398551) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.41386 ± 0.041598 (W 0.0102595) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.5303 ± 0.137944 (W 0.0896547) | 52.3905 ± 5.02732 (W 0.070222) | 🔵 fork 2.83× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.447773 ± 0.0223865 (W 0.00522617) | 1.20037 ± 0.0082116 (W 0.00382662) | 🔵 fork 2.68× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 33.684 ± 0.245204 (W 0.197302) | 79.0341 ± 1.78959 (W 0.935951) | 🔵 fork 2.35× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 1.01889 ± 0.0211673 (W 0.00529209) | 1.6611 ± 0.0141279 (W 0.00755655) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 28.3653 ± 0.41359 (W 0.160722) | 72.0429 ± 3.05824 (W 0.845704) | 🔵 fork 2.54× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 1.02949 ± 0.0325513 (W 0.0191463) | 1.3807 ± 0.019241 (W 0.00368208) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 104.463 ± 0.463138 (W 0.24154) | 443.302 ± 8.69771 (W 2.49272) | 🔵 fork 4.24× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.98073 ± 0.0216479 (W 0.0911263) | 9.78985 ± 0.100201 (W 0.0521814) | 🔵 fork 2.46× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 55.817 ± 0.12901 (W 0.500548) | 218.368 ± 2.44018 (W 0.543842) | 🔵 fork 3.91× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.56655 ± 0.0584477 (W 0.0726372) | 5.11002 ± 0.0563763 (W 0.0228297) | 🔵 fork 1.99× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 71.8552 ± 1.78135 (W 0.392643) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.44554 ± 0.0550109 (W 0.0104647) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 13.0826 ± 0.140498 (W 0.104277) | 49.5474 ± 3.79548 (W 0.193348) | 🔵 fork 3.79× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.363067 ± 0.00249453 (W 0.00559836) | 1.06815 ± 0.00813116 (W 0.0033392) | 🔵 fork 2.94× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 21.2106 ± 0.159481 (W 0.0956754) | 61.9644 ± 1.34862 (W 0.514389) | 🔵 fork 2.92× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.751009 ± 0.00497485 (W 0.00536618) | 1.41121 ± 0.016824 (W 0.00741108) | 🔵 fork 1.88× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 17.1233 ± 1.48951 (W 0.0779905) | 54.7877 ± 0.661904 (W 0.0973648) | 🔵 fork 3.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.786596 ± 0.00299569 (W 0.00709709) | 1.08399 ± 0.0221494 (W 0.00248011) | 🔵 fork 1.38× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 77.5113 ± 0.135562 (W 0.251211) | 389.468 ± 1.58382 (W 2.75362) | 🔵 fork 5.02× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.80833 ± 0.0148016 (W 0.0213069) | 9.82469 ± 0.0953339 (W 0.0586577) | 🔵 fork 2.58× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 48.0057 ± 0.253442 (W 0.115158) | 203.08 ± 0.986455 (W 0.634123) | 🔵 fork 4.23× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.57591 ± 0.0191506 (W 0.0166381) | 5.14884 ± 0.0942374 (W 0.0253111) | 🔵 fork 2.00× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 227.406 ± 6.30502 (W 1.2662) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.30163 ± 0.0164448 (W 0.00693363) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.0178 ± 0.193623 (W 0.0445993) | 55.9286 ± 0.0932759 (W 0.105994) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.891933 ± 0.00287077 (W 0.00356243) | 1.27108 ± 0.00709456 (W 0.00434975) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 103.115 ± 0.721677 (W 0.357609) | 186.51 ± 0.57302 (W 1.22572) | 🔵 fork 1.81× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.42266 ± 0.00902764 (W 0.00586096) | 3.77664 ± 0.0224853 (W 0.0120363) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 95.8063 ± 0.817664 (W 0.317821) | 148.783 ± 1.60323 (W 1.29599) | 🔵 fork 1.55× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.22753 ± 0.00740251 (W 0.00665294) | 2.95389 ± 0.0232645 (W 0.00439805) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 282.253 ± 1.4375 (W 0.482474) | 654.62 ± 3.78348 (W 2.18535) | 🔵 fork 2.32× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 6.03661 ± 0.0490464 (W 0.0118992) | 11.4301 ± 0.0887457 (W 0.0259776) | 🔵 fork 1.89× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 123.837 ± 1.27186 (W 0.593646) | 288.328 ± 1.20612 (W 1.05399) | 🔵 fork 2.33× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 3.08138 ± 0.0201406 (W 0.00714673) | 5.29696 ± 0.0588546 (W 0.0170069) | 🔵 fork 1.72× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.1994 ± 1.99679 (W 0.94085) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.28467 ± 0.0553235 (W 0.00852927) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 13.8319 ± 0.0301299 (W 0.0707035) | 30.4205 ± 0.053118 (W 0.0230122) | 🔵 fork 2.20× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.32397 ± 0.00494038 (W 0.00345128) | 0.802466 ± 0.00242939 (W 0.00181757) | 🔵 fork 2.48× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 29.1224 ± 0.143352 (W 0.103938) | 75.1936 ± 2.64202 (W 0.308091) | 🔵 fork 2.58× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.879018 ± 0.011029 (W 0.00467812) | 1.53081 ± 0.0322878 (W 0.0287174) | 🔵 fork 1.74× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 26.0994 ± 0.252356 (W 0.0728807) | 54.2625 ± 0.944911 (W 0.335492) | 🔵 fork 2.08× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.711066 ± 0.0145351 (W 0.00558325) | 1.00006 ± 0.00829953 (W 0.00202254) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 116.55 ± 0.473379 (W 0.433729) | 399.535 ± 0.905128 (W 0.454306) | 🔵 fork 3.43× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.08889 ± 0.0508434 (W 0.116499) | 9.28403 ± 0.119807 (W 0.0512579) | 🔵 fork 2.27× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 67.6115 ± 0.11938 (W 0.202073) | 200.485 ± 0.976143 (W 0.356614) | 🔵 fork 2.97× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.70218 ± 0.0706945 (W 0.0450687) | 4.66557 ± 0.0553786 (W 0.013976) | 🔵 fork 1.73× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 66.7397 ± 0.907426 (W 0.42313) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.31241 ± 0.0221419 (W 0.0103071) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.29507 ± 0.0618871 (W 0.0270245) | 23.6603 ± 0.0665262 (W 0.0315191) | 🔵 fork 2.85× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.241162 ± 0.00192857 (W 0.0027492) | 0.681144 ± 0.0120621 (W 0.00289882) | 🔵 fork 2.82× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 16.4601 ± 0.0697126 (W 0.0564377) | 57.0973 ± 0.311028 (W 0.369638) | 🔵 fork 3.47× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.640905 ± 0.0645993 (W 0.00751064) | 1.09368 ± 0.0870052 (W 0.0121348) | 🔵 fork 1.71× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 14.2197 ± 0.0901159 (W 0.0598829) | 38.4567 ± 0.481423 (W 0.163425) | 🔵 fork 2.70× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.464646 ± 0.00523684 (W 0.00375759) | 0.725721 ± 0.049536 (W 0.00217893) | 🔵 fork 1.56× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 89.8402 ± 0.52857 (W 0.220597) | 361.054 ± 1.34688 (W 0.595512) | 🔵 fork 4.02× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.95439 ± 0.0595972 (W 0.0246287) | 9.15386 ± 0.104824 (W 0.0346478) | 🔵 fork 2.31× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 59.3917 ± 0.187721 (W 0.315545) | 186.071 ± 0.710814 (W 0.655603) | 🔵 fork 3.13× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.68112 ± 0.0230337 (W 0.022884) | 4.76165 ± 0.0534447 (W 0.0168329) | 🔵 fork 1.78× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
