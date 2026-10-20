# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `2240b076a03011b2f128988fecf2967c4b1dda1c`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `a57194a4d232ff89b47d40c8eb0dfddf63b3a45d`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `21603d1c8a6ce3a545807f18e6c58de493b803686f4ee66cd64b7650910442db`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T05:53:09.287999Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor openblas --engines faer-fork,lapack-openblas --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 2 --prime-ms 250 --label final-full-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T044649Z-final-full-openblas/`

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
Each process retains 5 chronological calls; 2 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.56%, worst 45.28% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 128 of 2328 engine cells exceed 5% and carry `!`; median within-process relative SD 0.42%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.002359 ± 2.12132e-05 (W 1.26228e-05) | 0.002229 ± 3.53553e-05 (W 1.33127e-05) | 🔴 fork 1.06× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017087 ± 6.36396e-05 (W 4.78614e-05) | 0.0168515 ± 7.07107e-07 (W 1.33492e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0571015 ± 0.000163342 (W 0.00152985) | 0.0563755 ± 4.31335e-05 (W 0.000515836) | · |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 1.41421e-05 (W 1.74728e-05) | 0.002239 ± 7.07107e-06 (W 1.84226e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017127 ± 0.00013435 (W 0.000591972) | 0.0168265 ± 7.77817e-06 (W 1.75915e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0533045 ± 0.00390394 (W 0.0149181) | 0.056601 ± 0.000403051 (W 3.99368e-05) | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023495 ± 6.36396e-06 (W 2.44745e-05) | 0.002229 ± 7.07107e-06 (W 1.82769e-05) | 🔴 fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017152 ± 8.6267e-05 (W 2.20763e-05) | 0.0168215 ± 1.3435e-05 (W 2.00264e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.031359 ± 0.00126006 (W 0.00108842) | 0.0565205 ± 3.60624e-05 (W 0.00127097) | 🔵 fork 1.80× faster than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023245 ± 7.07107e-07 (W 1.97649e-05) | 0.0022095 ± 6.36396e-06 (W 1.80796e-05) | 🔴 fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017102 ± 4.24264e-05 (W 2.30651e-05) | 0.0168365 ± 2.05061e-05 (W 1.09857e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0567655 ± 1.48492e-05 (W 4.76834e-05) | 0.056501 ± 0.000106066 (W 0.000698168) | · |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 0 (W 1.40621e-05) | 0.0022295 ± 7.77817e-06 (W 2.13056e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0171225 ± 4.17193e-05 (W 0.000575484) | 0.0168515 ± 7.07107e-07 (W 2.28175e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.065037 ± 0.00612779 (W 0.0151701) | 0.056411 ± 6.36396e-05 (W 0.000644198) | 🔴 fork 1.15× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023345 ± 1.48492e-05 (W 2.35015e-05) | 0.002209 ± 2.12132e-05 (W 1.4522e-05) | 🔴 fork 1.06× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0174125 ± 0.000255266 (W 0.000742911) | 0.016881 ± 1.41421e-05 (W 2.40319e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.029615 ± 0.000708521 (W 0.00182773) | 0.05628 ± 3.53553e-05 (W 6.05869e-05) | 🔵 fork 1.90× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088265 ± 7.07107e-07 (W 1.95832e-05) | 0.0116065 ± 6.36396e-06 (W 1.50528e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067772 ± 0.00026163 (W 5.79073e-05) | 0.0859105 ± 0.000352846 (W 0.000167956) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.227115 ± 0.000168291 (W 0.00120605) | 0.276392 ± 0.000544472 (W 0.00162112) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088265 ± 1.48492e-05 (W 1.91173e-05) | 0.011612 ± 1.41421e-05 (W 3.59598e-05) | 🔵 fork 1.32× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0457755 ± 0.000893076 (W 0.00579208) | 0.025873 ± 0.000304056 (W 0.000138923) | 🔴 fork 1.77× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.089382 ± 0.00506571 (W 0.00849366) | 0.079303 ± 7.77817e-05 (W 0.00119718) | 🔴 fork 1.13× slower than `lapack-openblas` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088465 ± 4.31335e-05 (W 2.43344e-05) | 0.011627 ± 2.12132e-05 (W 4.27742e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0366685 ± 0.000439113 (W 0.00199957) | 0.0255575 ± 0.000622961 (W 0.000362864) | 🔴 fork 1.43× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.05089 ± 0.00149482 (W 0.00130538) | 0.054853 ± 0.000212132 (W 0.000208367) | 🔵 fork 1.08× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088315 ± 2.05061e-05 (W 1.6553e-05) | 0.0115765 ± 2.05061e-05 (W 2.23925e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0677565 ± 5.58614e-05 (W 3.58611e-05) | 0.086061 ± 0.000169706 (W 0.000685699) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.227716 ± 0.000907925 (W 0.00185552) | 0.277003 ± 0.000841457 (W 0.00145546) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008846 ± 1.41421e-05 (W 1.89903e-05) | 0.011601 ± 1.41421e-05 (W 4.67355e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.038041 ± 0.00222456 (W 0.00321223) | 0.0270005 ± 0.00117592 (W 0.000264612) | 🔴 fork 1.41× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.0861155 ± 0.00152382 (W 0.00553367) | 0.0788225 ± 0.000928431 (W 0.000995534) | 🔴 fork 1.09× slower than `lapack-openblas` |  |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088765 ± 5.58614e-05 (W 0.00106561) | 0.011612 ± 2.82843e-05 (W 2.9077e-05) | 🔵 fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0364235 ± 6.29325e-05 (W 0.00156039) | 0.025733 ± 0.000333754 (W 0.000735842) | 🔴 fork 1.42× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.049583 ± 0.000141421 (W 0.00195579) | 0.0549575 ± 0.000375474 (W 0.000936788) | 🔵 fork 1.11× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13378 ± 4.24264e-05 (W 0.000771888) | 0.163671 ± 0.000617304 (W 0.00214233) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.45452 ± 0.00444629 (W 0.00201762) | 0.541212 ± 5.37401e-05 (W 0.00263697) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07735 ± 0.00246568 (W 0.000885991) | 1.27324 ± 0.00639861 (W 0.00182273) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.61492 ± 0.00108117 (W 0.00215386) | 4.21792 ± 0.0117373 (W 0.00521197) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.60404 ± 0.00204707 (W 0.0149964) | 10.0918 ± 0.0368975 (W 0.0140707) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4371 ± 0.100285 (W 0.0205854) | 33.6861 ± 0.0917323 (W 0.207733) | 🔵 fork 1.14× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0775045 ± 0.0106271 (W 0.0179787) | 0.0505545 ± 8.55599e-05 (W 0.000578058) | 🔴 fork 1.53× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.159588 ± 0.00189717 (W 0.0193714) | 0.149424 ± 0.00210506 (W 0.00155468) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.307415 ± 0.00117804 (W 0.00711202) | 0.343778 ± 0.000392444 (W 0.00202679) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.928856 ± 0.0017911 (W 0.00408298) | 1.1026 ± 0.00153089 (W 0.00399374) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.23624 ± 0.00960039 (W 0.00405124) | 2.59007 ± 0.00812041 (W 0.00315974) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.56592 ± 0.0042879 (W 0.0302535) | 8.71054 ± 0.0205181 (W 0.02491) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.097307 ± 0.0183127 (W 0.0165616) | 0.0283425 ± 0.00170059 (W 0.000644472) | 🔴 fork 3.43× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.183057 ± 0.00153866 (W 0.034396) | 0.0832155 ± 0.00152947 (W 0.000548549) | 🔴 fork 2.20× slower than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.207097 ± 0.0035723 (W 0.03282) | 0.181479 ± 0.0034422 (W 0.00117017) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.563453 ± 0.00348745 (W 0.0139724) | 0.553825 ± 0.00440245 (W 0.00267664) | · |  |
| `gemm/512x512x512/b1` | 1.20261 ± 0.00384666 (W 0.010505) | 1.31829 ± 0.00392515 (W 0.00466082) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.93207 ± 0.0128227 (W 0.00813446) | 4.5562 ± 0.000294156 (W 0.00637912) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133771 ± 1.3435e-05 (W 0.00152731) | 0.1632 ± 0.000248902 (W 0.00123008) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.455356 ± 0.00524673 (W 0.00268011) | 0.5401 ± 4.52548e-05 (W 0.00210423) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07738 ± 0.00123319 (W 0.00347982) | 1.27144 ± 0.0026863 (W 0.00217232) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.6181 ± 0.00729239 (W 0.0066598) | 4.23053 ± 0.000289914 (W 0.00748999) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.59306 ± 0.0252126 (W 0.0171729) | 10.0814 ± 0.0135651 (W 0.00448396) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4182 ± 0.0360214 (W 0.0293777) | 33.6535 ± 0.113069 (W 0.0442933) | 🔵 fork 1.14× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.059797 ± 0.00829578 (W 0.0209883) | 0.05055 ± 0.000275772 (W 0.00105107) | 🔴 fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.153777 ± 0.0187461 (W 0.00739593) | 0.14965 ± 0.000410122 (W 0.00138843) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.305806 ± 0.00274287 (W 0.00380748) | 0.344444 ± 0.00156978 (W 0.00237475) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.932678 ± 0.0024671 (W 0.00501444) | 1.09846 ± 0.00547583 (W 0.00454952) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.23524 ± 0.012781 (W 0.00666935) | 2.59146 ± 0.00177696 (W 0.00367347) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.52428 ± 0.00989808 (W 0.0121373) | 8.70772 ± 0.0118822 (W 0.0134527) | 🔵 fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.09888 ± 0.0245479 (W 0.016141) | 0.0286235 ± 0.00191272 (W 0.000892951) | 🔴 fork 3.45× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.151999 ± 0.0217266 (W 0.0307456) | 0.081768 ± 0.00089944 (W 0.000582386) | 🔴 fork 1.86× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.252201 ± 0.0301213 (W 0.043424) | 0.178709 ± 5.09117e-05 (W 0.00158687) | 🔴 fork 1.41× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.56143 ± 0.00574949 (W 0.0124671) | 0.556771 ± 0.000762968 (W 0.00204431) | · |  |
| `gemm/512x512x512/b1` | 1.1892 ± 0.0158696 (W 0.0139252) | 1.3195 ± 0.00908208 (W 0.00302154) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.94626 ± 0.000424971 (W 0.0173039) | 4.55202 ± 0.00502682 (W 0.00867143) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.540836 ± 0.000599627 (W 0.00205589) | 0.660014 ± 0.000217082 (W 0.00219985) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81962 ± 0.00112854 (W 0.00204912) | 2.17935 ± 0.000977929 (W 0.00245541) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.2865 ± 0.00564766 (W 0.00290742) | 5.19631 ± 0.0163342 (W 0.00618134) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4794 ± 0.0367597 (W 0.01572) | 17.3197 ± 0.00698127 (W 0.0376934) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3475 ± 0.0504563 (W 0.0321406) | 41.053 ± 0.210805 (W 0.0117303) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.786 ± 0.0332397 (W 0.219722) | 137.729 ± 0.485114 (W 0.0655871) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160144 ± 0.000205061 (W 0.00174381) | 0.178013 ± 0.00151745 (W 0.0011033) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.471521 ± 0.00377171 (W 0.0041795) | 0.558123 ± 0.00187383 (W 0.00189545) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.12412 ± 0.00192687 (W 0.00435151) | 1.33106 ± 0.00817557 (W 0.0022575) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.65947 ± 0.00809708 (W 0.00786597) | 4.40069 ± 0.00835659 (W 0.00542667) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.71151 ± 0.0256461 (W 0.0135552) | 10.4356 ± 0.0426732 (W 0.00633226) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4642 ± 0.0305265 (W 0.0601062) | 34.9509 ± 0.029089 (W 0.00998361) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.118016 ± 0.00743169 (W 0.00868605) | 0.0933995 ± 0.0004179 (W 0.000720905) | 🔴 fork 1.26× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.280845 ± 0.00689853 (W 0.0153146) | 0.295748 ± 0.0014227 (W 0.00201089) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.61261 ± 0.00637245 (W 0.00627811) | 0.683723 ± 0.00166099 (W 0.00278725) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.87764 ± 0.00376534 (W 0.00781622) | 2.20109 ± 0.00136259 (W 0.00273436) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.53657 ± 0.00426244 (W 0.0223033) | 5.27717 ± 0.00562433 (W 0.00958614) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 15.0381 ± 0.0342289 (W 0.0296814) | 17.7839 ± 0.00847821 (W 0.0255358) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.540541 ± 0.00273085 (W 0.00266258) | 0.659964 ± 0.000817415 (W 0.00188545) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81769 ± 0.00155351 (W 0.00434281) | 2.17906 ± 0.000438406 (W 0.00148956) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28906 ± 0.000453963 (W 0.00428517) | 5.18441 ± 0.01027 (W 0.00969436) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4742 ± 0.00973332 (W 0.012175) | 17.327 ± 0.00657114 (W 0.0179813) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.3345 ± 0.0264062 (W 0.0400801) | 41.1176 ± 0.22046 (W 0.0303556) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.735 ± 0.0306778 (W 0.0337545) | 138.075 ± 0.831456 (W 0.103016) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160626 ± 0.00106985 (W 0.0074416) | 0.178474 ± 9.97021e-05 (W 0.00189974) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.474773 ± 0.00207819 (W 0.00188446) | 0.560793 ± 0.00120137 (W 0.0019597) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.12707 ± 0.00374059 (W 0.00411253) | 1.32972 ± 0.00590858 (W 0.00333857) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.66316 ± 0.0115548 (W 0.00739754) | 4.39543 ± 0.00689712 (W 0.00523037) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.70724 ± 0.0308461 (W 0.0106428) | 10.424 ± 0.0288287 (W 0.00597712) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4498 ± 0.0201716 (W 0.0209892) | 34.8446 ± 0.0728115 (W 0.208938) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.116758 ± 0.00535421 (W 0.00959587) | 0.0935805 ± 2.05061e-05 (W 0.00131703) | 🔴 fork 1.25× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.267535 ± 0.000927017 (W 0.0138031) | 0.295667 ± 0.000277893 (W 0.00200807) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.61278 ± 0.00408425 (W 0.0106833) | 0.686097 ± 0.00586899 (W 0.0013721) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.86785 ± 0.00733553 (W 0.00656272) | 2.20025 ± 0.00487197 (W 0.0031052) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.52307 ± 0.00319824 (W 0.0152881) | 5.26829 ± 0.00136754 (W 0.00388943) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 14.9839 ± 0.01752 (W 0.0340559) | 17.807 ± 0.0198711 (W 0.0186767) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.27851 ± 0.00520077 (W 0.00680848) | 1.64265 ± 0.00201313 (W 0.002607) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.08688 ± 0.0219847 (W 0.004637) | 1.45085 ± 0.0221954 (W 0.00678953) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.09072 ± 0.00902693 (W 0.00118248) | 1.36946 ± 0.00433598 (W 0.00646603) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.4416 ± 0.00365009 (W 0.00448829) | 0.494083 ± 0.0150161 (W 0.00713434) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.32686 ± 0.00515834 (W 0.00349613) | 0.476992 ± 0.000238295 (W 0.0143926) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.308201 ± 0.00931401 (W 0.00913195) | 0.347013 ± 0.000844285 (W 0.00174626) | 🔵 fork 1.13× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.440277 ± 0.00234689 (W 0.00293711) | 0.274954 ± 0.0106391 (W 0.00301928) | 🔴 fork 1.60× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.202864 ± 0.0137348 (W 0.00453027) | 0.31314 ± 0.000915703 (W 0.00146304) | 🔵 fork 1.54× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.201932 ± 0.00417193 (W 0.0232178) | 0.179405 ± 0.000806102 (W 0.00149144) | 🔴 fork 1.13× slower than `lapack-openblas` |  |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.04726 ± 0.0141803 (W 0.00472104) | 1.69151 ± 0.00349099 (W 0.00364194) | 🔵 fork 1.62× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.11637 ± 0.0356354 (W 0.0053263) | 1.41811 ± 0.0181359 (W 0.0058851) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.12965 ± 0.0031445 (W 0.00304254) | 1.36323 ± 0.00299672 (W 0.00250844) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.695654 ± 0.0152912 (W 0.0216823) | 0.427378 ± 0.00234972 (W 0.00337539) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.316868 ± 0.00275701 (W 0.00349428) | 0.484816 ± 0.00239709 (W 0.0023993) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.310932 ± 0.00548503 (W 0.00535317) | 0.363429 ± 0.00233911 (W 0.00196586) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.15744 ± 0.000129401 (W 0.0178718) | 0.228902 ± 0.00991222 (W 0.00886852) | 🔴 fork 5.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.200635 ± 0.000879641 (W 0.00468246) | 0.321751 ± 0.00297409 (W 0.0158915) | 🔵 fork 1.60× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.178979 ± 0.000686601 (W 0.00262912) | 0.195826 ± 0.00162917 (W 0.00120062) | 🔵 fork 1.09× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.15087 ± 0.00626284 (W 0.0054554) | 6.01097 ± 0.0393696 (W 0.0158327) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.42121 ± 0.0421011 (W 0.0103397) | 5.78262 ± 0.0194971 (W 0.0229663) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.40139 ± 0.0144674 (W 0.00610392) | 5.44169 ± 0.00154361 (W 0.00423021) | 🔵 fork 1.24× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.6648 ± 0.0249517 (W 0.00325305) | 1.74593 ± 0.00370665 (W 0.00678202) | · |  |
| `gemm/4096x16x240/b1` | 1.19897 ± 0.00079196 (W 0.00432953) | 1.68776 ± 0.00793303 (W 0.00190533) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.15125 ± 0.00468105 (W 0.00494119) | 1.39575 ± 0.0086069 (W 0.00378641) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.918521 ± 0.0151575 (W 0.00992045) | 0.943563 ± 0.0035518 (W 0.00643066) | · |  |
| `gemm/4096x16x240/b1` | 0.640597 ± 0.00372292 (W 0.0049067) | 0.99806 ± 0.00139159 (W 0.00209597) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.607906 ± 0.000436992 (W 0.00832891) | 0.70115 ± 0.00204354 (W 0.00350441) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.09572 ± 0.0271048 (W 0.00590367) | 5.83518 ± 0.00782696 (W 0.0135356) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.40654 ± 0.0273862 (W 0.00360688) | 5.79471 ± 0.00354897 (W 0.0118571) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.45812 ± 0.00286378 (W 0.00978505) | 5.5697 ± 0.0145084 (W 0.0113082) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.96189 ± 0.000151321 (W 0.0313937) | 1.5128 ± 0.00789131 (W 0.00690098) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.19589 ± 0.00424264 (W 0.00679105) | 1.7462 ± 0.00444699 (W 0.00406336) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.21193 ± 0.0060295 (W 0.0104786) | 1.46284 ± 0.000410829 (W 0.00376263) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.51693 ± 0.0396206 (W 0.0596699) | 0.825558 ± 0.00754907 (W 0.00469521) | 🔴 fork 3.05× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.641148 ± 0.00142836 (W 0.00507135) | 1.01254 ± 0.00280014 (W 0.00908038) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.619016 ± 0.00750665 (W 0.00537391) | 0.773595 ± 0.00599697 (W 0.00364098) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12921 ± 0.00625648 (W 0.00244902) | 1.3721 ± 0.00512865 (W 0.00337286) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.312153 ± 0.00242467 (W 0.00489223) | 0.366089 ± 0.000349311 (W 0.00196434) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.176575 ± 0.00224577 (W 0.00265962) | 0.196262 ± 0.00267004 (W 0.00208458) | 🔵 fork 1.11× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08497 ± 0.00254488 (W 0.00104153) | 1.36801 ± 0.00412385 (W 0.00241913) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.306026 ± 0.00734472 (W 0.00893463) | 0.345911 ± 0.00187878 (W 0.00166033) | 🔵 fork 1.13× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.179301 ± 0.0189498 (W 0.0197125) | 0.178167 ± 0.000190212 (W 0.000806494) | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.43726 ± 0.00346482 (W 0.00784151) | 5.57464 ± 0.0128701 (W 0.0114672) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.19905 ± 0.010876 (W 0.00744473) | 1.45628 ± 0.0106405 (W 0.00316081) | 🔵 fork 1.21× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.616973 ± 0.00073327 (W 0.00511906) | 0.770745 ± 0.000649124 (W 0.00148834) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.38945 ± 0.00816779 (W 0.00556274) | 5.42957 ± 0.0229279 (W 0.0107116) | 🔵 fork 1.24× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.14427 ± 0.00539593 (W 0.00275751) | 1.39656 ± 0.00879075 (W 0.00348261) | 🔵 fork 1.22× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.608516 ± 0.000201525 (W 0.00526967) | 0.700629 ± 0.00159806 (W 0.00521098) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0034515 ± 5.02046e-05 (W 0.000614851) | 0.0040875 ± 7.07107e-07 (W 4.71176e-05) | 🔵 fork 1.18× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0168865 ± 7.84889e-05 (W 5.4142e-05) | 0.018189 ± 6.36396e-05 (W 0.00172848) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.033157 ± 2.12132e-05 (W 4.97166e-05) | 0.0433515 ± 0.000439113 (W 0.000138288) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.114233 ± 0.000127986 (W 0.000103695) | 0.1206 ± 0.00146725 (W 0.00142412) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.488563 ± 0.000738927 (W 0.00145611) | 0.432628 ± 0.00222314 (W 0.00163851) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.16587 ± 0.00526158 (W 0.00273636) | 0.948607 ± 0.000933381 (W 0.00200415) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.011827 ± 0.000148492 (W 6.51576e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051301 ± 0.000318198 (W 0.000966303) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144936 ± 0.00140856 (W 0.00125228) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008295 ± 4.24264e-05 (W 2.31628e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008296 ± 2.82843e-05 (W 3.11221e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040446 ± 7.07107e-05 (W 0.000589946) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040701 ± 9.19239e-05 (W 9.61908e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.120891 ± 0.000277186 (W 0.00104147) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.120845 ± 0.000127986 (W 0.00108378) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008591 ± 0.000106066 (W 5.03979e-05) | 0.009849 ± 0.000141421 (W 0.00133661) | 🔵 fork 1.15× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031093 ± 4.94975e-05 (W 0.000112501) | 0.037405 ± 0.000743876 (W 0.000127934) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.077445 ± 0.00161503 (W 0.00216588) | 0.0950775 ± 0.00035426 (W 0.00250216) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0336385 ± 0.000985 (W 0.000149161) | 0.0323255 ± 0.000119501 (W 0.000131757) | · |  |
| `qr/n64/b1` | 0.122118 ± 0.000964494 (W 0.000578279) | 0.129672 ± 0.000198697 (W 0.00152103) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.295316 ± 0.00924401 (W 0.00477882) | 0.371609 ± 0.00108541 (W 0.00219672) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0221415 ± 0.000396687 (W 0.000159692) | 0.0173475 ± 0.000191626 (W 9.22705e-05) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.0885605 ± 0.000234052 (W 0.000147374) | 0.066284 ± 0.000141421 (W 0.000145033) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.19524 ± 0.00173665 (W 0.000779336) | 0.183262 ± 0.0010642 (W 0.00175976) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.009603 ± 2.12132e-05 (W 4.832e-05) | 0.009889 ± 2.82843e-05 (W 3.07357e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0315485 ± 0.000198697 (W 0.000116733) | 0.037485 ± 0.000190919 (W 0.00139404) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.077916 ± 0.000241831 (W 0.00245657) | 0.0891065 ± 0.000736098 (W 0.000619007) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.18444 ± 0.00143826 (W 0.00145873) | 0.182675 ± 7.77817e-06 (W 0.00132802) | · |  |
| `svd_thin/n64/b1` | 0.920234 ± 0.000640639 (W 0.00109976) | 0.67189 ± 0.0059694 (W 0.00492865) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.19865 ± 0.0363467 (W 0.00405946) | 1.61028 ± 0.0125186 (W 0.0054869) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140924 ± 0.000468812 (W 0.00140813) | 0.0783615 ± 0.000970858 (W 0.000834089) | 🔴 fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.518949 ± 0.00129188 (W 0.00207983) | 0.276101 ± 0.000742462 (W 0.00158652) | 🔴 fork 1.88× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19017 ± 0.00242467 (W 0.00255138) | 0.665022 ± 0.000569221 (W 0.00247157) | 🔴 fork 1.79× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000676 ± 7.07107e-06 (W 2.30812e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0015075 ± 2.05061e-05 (W 2.21607e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00262 ± 2.12132e-05 (W 2.21402e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0034315 ± 2.19203e-05 (W 3.35612e-05) | 0.0039775 ± 5.58614e-05 (W 4.75516e-05) | 🔵 fork 1.16× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0158245 ± 0.00138239 (W 5.07386e-05) | 0.017678 ± 0.000234759 (W 0.000284361) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049452 ± 0.00128976 (W 0.00263134) | 0.0432505 ± 0.000439113 (W 0.000837704) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.113392 ± 0.000410829 (W 0.000249958) | 0.10418 ± 0.000347189 (W 0.000695749) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.504041 ± 0.00061094 (W 0.00707728) | 0.353571 ± 7.2832e-05 (W 0.00157192) | 🔴 fork 1.43× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.21129 ± 0.00239144 (W 0.0233254) | 0.75998 ± 0.00030052 (W 0.00165635) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.011907 ± 0.00013435 (W 0.00105886) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0511855 ± 0.000269408 (W 0.000220668) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143773 ± 0.000105359 (W 0.00115945) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.00828 ± 7.07107e-06 (W 4.90965e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0083855 ± 7.07107e-07 (W 3.32116e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0242005 ± 0.000120915 (W 0.000347264) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0247665 ± 0.000113844 (W 0.00045716) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0494725 ± 1.3435e-05 (W 0.0028128) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.050444 ± 0.0013039 (W 0.000828586) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008791 ± 0.000219203 (W 7.14839e-05) | 0.0094825 ± 0.000177484 (W 0.000115493) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031038 ± 0.000509117 (W 0.000999536) | 0.037059 ± 0.000183848 (W 0.00100398) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.076198 ± 0.000659024 (W 0.00224854) | 0.0926925 ± 0.00582302 (W 0.00134115) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n32/b1` | 0.033182 ± 9.89949e-05 (W 0.00013672) | 0.0321105 ± 0.000241123 (W 0.000757196) | · |  |
| `qr/n64/b1` | 0.151788 ± 0.000631446 (W 0.00191005) | 0.126882 ± 0.00139583 (W 0.000897381) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.410046 ± 0.00615041 (W 0.0219643) | 0.362492 ± 0.00124097 (W 0.00181586) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.035176 ± 0.000282843 (W 0.000872082) | 0.0171015 ± 0.000113844 (W 0.00077815) | 🔴 fork 2.06× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.112666 ± 0.00690773 (W 0.00505543) | 0.065257 ± 0.000446891 (W 0.000948336) | 🔴 fork 1.73× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.246575 ± 0.0351015 (W 0.00715642) | 0.183528 ± 4.94975e-05 (W 0.00054006) | 🔴 fork 1.34× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.009558 ± 5.65685e-05 (W 0.00162626) | 0.0096325 ± 7.84889e-05 (W 3.4559e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031785 ± 7.77817e-05 (W 0.00107264) | 0.0373745 ± 0.000248194 (W 7.50835e-05) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0778955 ± 0.000226981 (W 0.00244291) | 0.08791 ± 0.000106066 (W 0.000888459) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.205338 ± 0.00228749 (W 0.00148915) | 0.181263 ± 0.000743169 (W 0.0014223) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 0.96351 ± 0.00944624 (W 0.00836689) | 0.629911 ± 0.00391525 (W 0.00163169) | 🔴 fork 1.53× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.33426 ± 0.000316784 (W 0.0136115) | 1.50436 ± 0.046056 (W 0.00434656) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.141289 ± 0.000347897 (W 0.000827001) | 0.0779905 ± 0.000375474 (W 0.000893235) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.522015 ± 0.00293449 (W 0.00244141) | 0.273972 ± 0.00108965 (W 0.00138588) | 🔴 fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19649 ± 0.000824487 (W 0.00271244) | 0.657168 ± 0.00109248 (W 0.00249826) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000686 ± 2.12132e-05 (W 1.952e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001523 ± 0 (W 2.07229e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00263 ± 6.36396e-05 (W 3.4764e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0032755 ± 0.000184555 (W 2.21111e-05) | 0.0040275 ± 1.3435e-05 (W 5.55543e-05) | 🔵 fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0165705 ± 0.00264953 (W 2.85238e-05) | 0.0175335 ± 0.000212839 (W 9.5324e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.058795 ± 0.00114127 (W 0.00347489) | 0.04288 ± 0.000468105 (W 0.000491259) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.113347 ± 0.000432042 (W 0.00127551) | 0.102365 ± 0.00021991 (W 0.000276604) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.510994 ± 0.000494975 (W 0.00364074) | 0.348757 ± 0.00235962 (W 0.00132372) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.25673 ± 0.0168072 (W 0.0265833) | 0.738729 ± 0.0025668 (W 0.00167409) | 🔴 fork 1.70× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.011837 ± 2.12132e-05 (W 9.86867e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.050895 ± 9.89949e-05 (W 0.00011166) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143919 ± 0.000736805 (W 0.00246657) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0083555 ± 4.17193e-05 (W 7.82559e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0084255 ± 4.17193e-05 (W 5.11919e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020093 ± 4.94975e-05 (W 0.000391585) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020403 ± 0.000205061 (W 0.000952724) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0370945 ± 0.000205768 (W 0.000903547) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.03751 ± 0.00019799 (W 0.000907126) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008611 ± 3.53553e-05 (W 4.60628e-05) | 0.009693 ± 0.000120208 (W 6.45514e-05) | 🔵 fork 1.13× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030938 ± 0.000141421 (W 0.000760974) | 0.0372495 ± 0.00035426 (W 0.000189882) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0769835 ± 0.00114763 (W 0.00249999) | 0.09384 ± 0.00533441 (W 0.00167759) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.033022 ± 4.24264e-05 (W 0.000109605) | 0.0319645 ± 0.000262337 (W 0.000135412) | · |  |
| `qr/n64/b1` | 0.172277 ± 0.0153089 (W 0.00244581) | 0.128044 ± 0.00128128 (W 0.000370498) | 🔴 fork 1.35× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.40734 ± 0.0087858 (W 0.0227115) | 0.362687 ± 0.00294864 (W 0.00235992) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.040546 ± 0.000240416 (W 0.00107869) | 0.0177685 ± 0.000276479 (W 0.000955646) | 🔴 fork 2.28× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.111212 ± 0.000191626 (W 0.00203985) | 0.065612 ± 0.00101965 (W 0.00124454) | 🔴 fork 1.70× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.215096 ± 0.00760069 (W 0.0118387) | 0.182887 ± 6.29325e-05 (W 0.00128057) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.009548 ± 5.65685e-05 (W 3.08572e-05) | 0.0097735 ± 2.05061e-05 (W 3.40706e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0316745 ± 0.000304763 (W 0.000319366) | 0.0366535 ± 0.000474469 (W 6.08017e-05) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0792375 ± 0.000538108 (W 0.00240785) | 0.087418 ± 0.000558614 (W 0.00175436) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.184269 ± 0.000291328 (W 0.00084861) | 0.181033 ± 0.000404465 (W 0.000926589) | · |  |
| `svd_thin/n64/b1` | 0.963734 ± 0.00116602 (W 0.00267151) | 0.635582 ± 0.00234264 (W 0.00318813) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.36505 ± 0.00931542 (W 0.0107207) | 1.47494 ± 0.000987121 (W 0.00259966) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140818 ± 0.00070145 (W 0.000641201) | 0.0774945 ± 0.000140714 (W 0.000720921) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.523713 ± 0.00212981 (W 0.0035599) | 0.273922 ± 0.00373989 (W 0.00133523) | 🔴 fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19204 ± 0.000442649 (W 0.00293357) | 0.656656 ± 0.00436214 (W 0.00163057) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0006715 ± 7.07107e-07 (W 7.14712e-06) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0014675 ± 2.19203e-05 (W 1.6542e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002545 ± 2.82843e-05 (W 3.53284e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003356 ± 1.41421e-05 (W 2.04145e-05) | 0.0034865 ± 1.48492e-05 (W 4.37711e-05) | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0165755 ± 3.60624e-05 (W 3.75822e-05) | 0.015238 ± 5.65685e-05 (W 0.000509961) | 🔴 fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0325155 ± 6.43467e-05 (W 5.91075e-05) | 0.0366785 ± 0.000297692 (W 0.000103685) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.114043 ± 0.00028355 (W 0.00135599) | 0.119258 ± 0.000970858 (W 0.000815624) | · |  |
| `eigh/n64/b1` | 0.488533 ± 0.000284964 (W 0.00189988) | 0.428911 ± 0.00175504 (W 0.00201966) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.16565 ± 0.00529694 (W 0.00239063) | 0.937622 ± 0.00201596 (W 0.00104232) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010209 ± 0.000155563 (W 5.03136e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045761 ± 0.000360624 (W 0.000116967) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132693 ± 0.000940452 (W 0.00251035) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0083305 ± 6.43467e-05 (W 4.01493e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008391 ± 0.000162635 (W 3.85213e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.04019 ± 4.94975e-05 (W 4.57855e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.04022 ± 7.07107e-06 (W 2.41886e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.12303 ± 0.000340825 (W 0.00229858) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.122659 ± 0.00028355 (W 0.00104025) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007028 ± 6.36396e-05 (W 1.85388e-05) | 0.008395 ± 1.41421e-05 (W 9.41139e-05) | 🔵 fork 1.19× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0261185 ± 7.14178e-05 (W 0.000162727) | 0.0329765 ± 0.000488611 (W 0.00012598) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0648215 ± 0.00135977 (W 0.00113527) | 0.0771195 ± 0.000234052 (W 0.00089104) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.03208 ± 0.000708521 (W 0.000218428) | 0.030151 ± 0.000459619 (W 0.00147858) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.11514 ± 0.00149624 (W 0.0012088) | 0.121066 ± 0.000185262 (W 0.000961927) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.280008 ± 0.00886146 (W 0.00311472) | 0.33996 ± 0.00179039 (W 0.00147234) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0179435 ± 0.00035426 (W 0.000759967) | 0.0162655 ± 4.87904e-05 (W 0.000108812) | 🔴 fork 1.10× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.0746245 ± 0.00126784 (W 0.000248261) | 0.06152 ± 4.94975e-05 (W 0.000156822) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.163716 ± 0.0016016 (W 0.00123956) | 0.170773 ± 0.000842164 (W 0.00140261) | · |  |
| `solve/n32/b1` | 0.0078395 ± 6.43467e-05 (W 5.82233e-05) | 0.008566 ± 0.000141421 (W 4.49245e-05) | 🔵 fork 1.09× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0257035 ± 6.43467e-05 (W 9.60635e-05) | 0.0325105 ± 0.000340118 (W 5.14293e-05) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.065698 ± 0.000461034 (W 0.0033378) | 0.0762575 ± 0.00119713 (W 0.000658276) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.185607 ± 0.000964494 (W 0.00118344) | 0.17664 ± 0.000227688 (W 0.00135453) | · |  |
| `svd_thin/n64/b1` | 0.963085 ± 0.00204283 (W 0.00109523) | 0.637972 ± 0.00137744 (W 0.00219174) | 🔴 fork 1.51× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.1676 ± 0.0156518 (W 0.00388088) | 1.4723 ± 0.000806809 (W 0.0025119) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.142631 ± 6.36396e-06 (W 0.00136387) | 0.0748345 ± 0.000871863 (W 0.000791257) | 🔴 fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.540905 ± 0.00258801 (W 0.0014795) | 0.27062 ± 0.00231577 (W 0.00156217) | 🔴 fork 2.00× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19614 ± 0.00151816 (W 0.00234865) | 0.661571 ± 0.00105288 (W 0.00218525) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000737 ± 7.07107e-06 (W 1.36101e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0016885 ± 2.05061e-05 (W 2.44337e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0029405 ± 7.84889e-05 (W 3.95492e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003351 ± 7.07107e-06 (W 3.14528e-05) | 0.0033515 ± 2.05061e-05 (W 4.7521e-05) | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0155535 ± 0.00132441 (W 4.76666e-05) | 0.015094 ± 6.36396e-05 (W 9.07725e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049347 ± 0.000800445 (W 0.00250112) | 0.036553 ± 0.000148492 (W 0.000148993) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.113346 ± 0.000672459 (W 0.00143952) | 0.103383 ± 0.000297692 (W 0.00088206) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.504287 ± 0.00457215 (W 0.00335268) | 0.349958 ± 0.00124097 (W 0.00148538) | 🔴 fork 1.44× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.21408 ± 0.0119911 (W 0.0221491) | 0.752536 ± 0.001463 (W 0.00182223) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0103845 ± 7.84889e-05 (W 5.38676e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046296 ± 7.07107e-05 (W 0.00021328) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131657 ± 2.75772e-05 (W 0.00250925) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008226 ± 1.41421e-05 (W 3.61292e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0082755 ± 1.3435e-05 (W 3.74372e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.031534 ± 0.00458347 (W 0.00203826) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.031108 ± 0.00525663 (W 0.00188289) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.059401 ± 0.000169706 (W 0.0015301) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0596265 ± 0.000730441 (W 0.00113858) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0073985 ± 0.000290621 (W 6.73623e-05) | 0.0084005 ± 0.000147785 (W 8.52264e-05) | 🔵 fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025884 ± 0.000162635 (W 0.00100457) | 0.032907 ± 7.07107e-06 (W 0.000174784) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0636945 ± 0.000248194 (W 0.00273109) | 0.076628 ± 0.000572756 (W 0.000244183) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.031579 ± 4.24264e-05 (W 0.00013666) | 0.02959 ± 0.000219203 (W 0.000745573) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.146689 ± 0.00729027 (W 0.00239773) | 0.118667 ± 0.00142482 (W 0.00131396) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.378161 ± 0.021641 (W 0.0199486) | 0.344279 ± 0.00101187 (W 0.00141583) | 🔴 fork 1.10× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017683 ± 0.000127279 (W 6.77814e-05) | 0.0160395 ± 7.14178e-05 (W 8.54728e-05) | 🔴 fork 1.10× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.10431 ± 7.77817e-05 (W 0.00804401) | 0.0605435 ± 1.3435e-05 (W 0.000892589) | 🔴 fork 1.72× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.21652 ± 0.0320722 (W 0.0124114) | 0.171941 ± 7.00036e-05 (W 0.00136641) | 🔴 fork 1.26× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.0078095 ± 0.000105359 (W 6.90377e-05) | 0.0084605 ± 3.60624e-05 (W 8.04892e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0260235 ± 0.000120915 (W 0.000117154) | 0.0322605 ± 2.75772e-05 (W 9.56927e-05) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0657075 ± 0.000163342 (W 0.00135755) | 0.075897 ± 0.000106066 (W 0.000817796) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.207222 ± 0.00247205 (W 0.00159645) | 0.175057 ± 0.00188373 (W 0.0023649) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 0.99832 ± 0.00430416 (W 0.002751) | 0.614293 ± 0.000600334 (W 0.00184931) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.2818 ± 0.0175497 (W 0.0185345) | 1.43659 ± 0.00238578 (W 0.00219524) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.142757 ± 0.000539522 (W 0.000803521) | 0.0741585 ± 0.000863377 (W 0.000117884) | 🔴 fork 1.93× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.538155 ± 0.00105076 (W 0.00191942) | 0.267454 ± 0.000856306 (W 0.00149863) | 🔴 fork 2.01× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.2021 ± 0.002786 (W 0.0017594) | 0.652975 ± 0.00056215 (W 0.00195699) | 🔴 fork 1.84× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007315 ± 7.07107e-07 (W 1.09236e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001718 ± 7.07107e-06 (W 1.98646e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0028855 ± 4.17193e-05 (W 3.41543e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003301 ± 0.000376181 (W 2.59983e-05) | 0.003352 ± 4.94975e-05 (W 3.15216e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0162505 ± 0.00263539 (W 4.51011e-05) | 0.014928 ± 0.000127279 (W 7.02444e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0554885 ± 0.00403122 (W 0.00360665) | 0.036598 ± 0 (W 0.00090365) | 🔴 fork 1.52× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113281 ± 0.0005671 (W 0.000858269) | 0.10144 ± 0.000694379 (W 0.000843963) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.513263 ± 0.000501339 (W 0.00381274) | 0.343341 ± 0.00140361 (W 0.00180033) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.23638 ± 2.26274e-05 (W 0.0127558) | 0.72885 ± 0.00136401 (W 0.00206656) | 🔴 fork 1.70× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010349 ± 1.41421e-05 (W 0.000547234) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045525 ± 0.000113137 (W 0.000646933) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132092 ± 0.000460327 (W 0.000791747) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0082505 ± 7.77817e-06 (W 3.02083e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0082755 ± 2.75772e-05 (W 2.89808e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0286885 ± 0.000587606 (W 0.000708051) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.027977 ± 0.000233345 (W 0.00214984) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.048746 ± 0.000758018 (W 0.00492719) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0433905 ± 0.00100621 (W 0.00394384) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0070885 ± 7.70746e-05 (W 0.000103329) | 0.0084005 ± 3.60624e-05 (W 5.74565e-05) | 🔵 fork 1.19× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025848 ± 1.41421e-05 (W 0.00205461) | 0.032971 ± 7.07107e-05 (W 0.000131547) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0640895 ± 0.000962372 (W 0.00132804) | 0.077214 ± 1.41421e-05 (W 0.00150258) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.031454 ± 0.000248902 (W 0.000107518) | 0.0297955 ± 0.000170413 (W 0.00116957) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.147516 ± 0.000990657 (W 0.0014792) | 0.117644 ± 2.05061e-05 (W 0.000966169) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.395959 ± 0.0166184 (W 0.0302931) | 0.341318 ± 0.000780646 (W 0.00140697) | 🔴 fork 1.16× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.0178235 ± 0.000198697 (W 8.45374e-05) | 0.0165255 ± 0.000361332 (W 9.76481e-05) | 🔴 fork 1.08× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.092813 ± 0.000169706 (W 0.000720548) | 0.0606635 ± 0.000962372 (W 9.37733e-05) | 🔴 fork 1.53× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.201702 ± 0.00877732 (W 0.0103863) | 0.172187 ± 0.000333047 (W 0.00100592) | 🔴 fork 1.17× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007935 ± 0.000141421 (W 5.55296e-05) | 0.0085115 ± 0.000120915 (W 5.46848e-05) | 🔵 fork 1.07× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0258935 ± 0.000304763 (W 0.00104429) | 0.032265 ± 7.77817e-05 (W 9.43983e-05) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0664645 ± 0.00124663 (W 0.00151482) | 0.075521 ± 0 (W 0.00103741) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.185893 ± 0.00136825 (W 0.00100184) | 0.17401 ± 0.000205061 (W 0.00123577) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 1.00521 ± 0.00924896 (W 0.00201243) | 0.616691 ± 0.0001393 (W 0.00158446) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.29569 ± 0.00213334 (W 0.01915) | 1.44564 ± 0.00180242 (W 0.00254438) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.142486 ± 4.24264e-05 (W 0.00161619) | 0.0737525 ± 0.000234052 (W 0.00147659) | 🔴 fork 1.93× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.543215 ± 0.000823779 (W 0.00231221) | 0.268486 ± 0.00249962 (W 0.00204365) | 🔴 fork 2.02× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19285 ± 0.000173241 (W 0.00150749) | 0.655364 ± 0.00135765 (W 0.00122082) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007415 ± 1.3435e-05 (W 2.79746e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0016835 ± 1.48492e-05 (W 1.26276e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00284 ± 7.07107e-06 (W 4.26136e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004914 ± 2.12132e-05 (W 4.7131e-05) | 0.0066475 ± 6.36396e-06 (W 8.47858e-05) | 🔵 fork 1.35× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0293845 ± 9.97021e-05 (W 8.12481e-05) | 0.039704 ± 0.000113137 (W 0.00018089) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.083371 ± 0.000233345 (W 0.000232836) | 0.0957935 ± 0.000205768 (W 0.00171438) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142747 ± 0.000978636 (W 0.000758847) | 0.151678 ± 0.000502753 (W 0.000766489) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.653766 ± 0.00124309 (W 0.00198614) | 0.655344 ± 0.00226981 (W 0.00152352) | · |  |
| `eigh/n96/b1` | 1.62102 ± 0.00485217 (W 0.00344645) | 1.64067 ± 0.000807516 (W 0.00500842) | · |  |
| `full_piv_lu/n32/b1` | 0.017738 ± 3.53553e-05 (W 5.94133e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0981985 ± 3.46482e-05 (W 0.000832438) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.281601 ± 0.000432749 (W 0.00143882) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028122 ± 0 (W 4.83602e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028243 ± 4.24264e-05 (W 0.000611614) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.159668 ± 0.000539522 (W 0.00192423) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.160284 ± 0.000135765 (W 0.000271453) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.468174 ± 0.00186888 (W 0.00171568) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.47122 ± 0.00326047 (W 0.000542013) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0136805 ± 3.60624e-05 (W 5.07507e-05) | 0.013916 ± 1.41421e-05 (W 5.93404e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.060112 ± 0.000510531 (W 0.000138446) | 0.0669405 ± 0.000105359 (W 0.00107951) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.156583 ± 0.000624375 (W 0.00130963) | 0.179205 ± 0.000453963 (W 0.0016822) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0703565 ± 3.46482e-05 (W 0.00118086) | 0.0536555 ± 0.000333047 (W 0.000156157) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.321406 ± 0.000546594 (W 0.00186763) | 0.263342 ± 0.00323006 (W 0.00144989) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.782987 ± 0.000145664 (W 0.00203851) | 0.733661 ± 0.00322794 (W 0.00255183) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.039198 ± 9.19239e-05 (W 0.000258986) | 0.029981 ± 0.000176777 (W 0.000701243) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.181504 ± 0.000473762 (W 0.00160134) | 0.138294 ± 0.00254205 (W 0.0017956) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.436631 ± 0.0022189 (W 0.00178239) | 0.374645 ± 0.000799031 (W 0.00211551) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.014953 ± 0.000176777 (W 3.91235e-05) | 0.015384 ± 0.000162635 (W 5.29441e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.062371 ± 0.000673166 (W 0.000136567) | 0.0722305 ± 0.000700743 (W 0.000246568) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.161262 ± 0.00167231 (W 0.00188575) | 0.191077 ± 0.00101965 (W 0.00147732) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.236872 ± 0.00017112 (W 0.0017159) | 0.228903 ± 0.00160938 (W 0.00139902) | · |  |
| `svd_thin/n64/b1` | 1.22955 ± 0.00322794 (W 0.00207901) | 0.960314 ± 0.00597435 (W 0.000674383) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.14757 ± 0.0131472 (W 0.00732352) | 2.64542 ± 0.133118 (W 0.00440384) | 🔴 fork 1.19× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.162223 ± 0.000383252 (W 0.00164154) | 0.103654 ± 0.000878227 (W 0.000880885) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.655294 ± 0.0022981 (W 0.00182799) | 0.409766 ± 0.00378514 (W 0.00162541) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51802 ± 0.000480833 (W 0.00721889) | 1.02424 ± 0.00161857 (W 0.000720966) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001057 ± 7.07107e-06 (W 2.40613e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002885 ± 0.00019799 (W 5.5263e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005065 ± 3.53553e-05 (W 0.00062664) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004934 ± 3.53553e-05 (W 4.09916e-05) | 0.0066075 ± 3.60624e-05 (W 2.79546e-05) | 🔵 fork 1.34× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0292245 ± 0.000325976 (W 9.14803e-05) | 0.038617 ± 7.07107e-06 (W 0.0049289) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.101901 ± 0.000197283 (W 0.00199255) | 0.095694 ± 0.00204778 (W 0.00140486) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142686 ± 0.000495682 (W 0.000224071) | 0.13663 ± 9.19239e-05 (W 0.000873451) | · |  |
| `eigh/n64/b1` | 0.639123 ± 0.00128764 (W 0.0033863) | 0.574949 ± 0.00153866 (W 0.00195289) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.55829 ± 0.0108555 (W 0.0336063) | 1.61867 ± 0.00470226 (W 0.00226645) | · |  |
| `full_piv_lu/n32/b1` | 0.0178685 ± 0.000403758 (W 7.82677e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0974525 ± 7.07107e-07 (W 0.0018725) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.283424 ± 0.00124097 (W 0.00174226) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028348 ± 2.12132e-05 (W 7.99822e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0285885 ± 0.000318905 (W 8.96205e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.065623 ± 0.000311127 (W 0.0012039) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0658375 ± 0.000771453 (W 0.00138306) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.155731 ± 0.000156978 (W 0.00154771) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.157409 ± 0.000957423 (W 0.00175453) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.01356 ± 6.36396e-05 (W 3.73038e-05) | 0.013891 ± 0.000120208 (W 5.20272e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0603875 ± 7.84889e-05 (W 0.00229602) | 0.0680365 ± 7.07107e-07 (W 0.000747797) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.157524 ± 5.65685e-05 (W 0.00151104) | 0.182631 ± 0.000581949 (W 0.00191374) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070427 ± 3.53553e-05 (W 0.00050251) | 0.05391 ± 0.000282843 (W 0.000104028) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.299339 ± 0.00546806 (W 0.00321588) | 0.262565 ± 0.00087257 (W 0.00187588) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.652514 ± 0.0563013 (W 0.00378083) | 0.927918 ± 0.000534573 (W 0.00136172) | 🔵 fork 1.42× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n32/b1` | 0.052954 ± 0.000219203 (W 0.0011602) | 0.0302765 ± 0.00011243 (W 7.0851e-05) | 🔴 fork 1.75× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.20308 ± 0.00130461 (W 0.00965952) | 0.13659 ± 0.000275772 (W 0.00159993) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.375341 ± 0.00232497 (W 0.00172655) | 0.472433 ± 0.0010741 (W 0.00138097) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.014918 ± 2.82843e-05 (W 3.96471e-05) | 0.015644 ± 6.36396e-05 (W 5.45821e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.062837 ± 5.65685e-05 (W 0.000803206) | 0.0719395 ± 0.000389616 (W 0.0012356) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.160766 ± 0.000658316 (W 0.00121045) | 0.189329 ± 0.00274145 (W 0.00117795) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.237814 ± 0.000721249 (W 0.00216812) | 0.226989 ± 0.000346482 (W 0.00148469) | · |  |
| `svd_thin/n64/b1` | 1.19994 ± 0.00120915 (W 0.00286409) | 0.95849 ± 0.00150472 (W 0.00226977) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.9905 ± 0.0124161 (W 0.0254264) | 2.47562 ± 0.00405738 (W 0.00823054) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.16293 ± 0.000119501 (W 0.00138761) | 0.103368 ± 0.000148492 (W 0.000321849) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.654037 ± 6.57609e-05 (W 0.00206097) | 0.410157 ± 0.00241053 (W 0.0016497) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.52127 ± 0.00530047 (W 0.00879416) | 1.28551 ± 0.0048557 (W 0.00289644) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001082 ± 1.41421e-05 (W 2.10802e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0027105 ± 7.77817e-06 (W 2.04128e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004944 ± 7.07107e-06 (W 3.05028e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004929 ± 5.65685e-05 (W 6.09444e-05) | 0.0066575 ± 7.84889e-05 (W 7.59755e-05) | 🔵 fork 1.35× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.02923 ± 0.000106066 (W 0.000136966) | 0.0416925 ± 0.000234052 (W 0.000527966) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.110837 ± 0.000312541 (W 0.00328332) | 0.103032 ± 0.000410122 (W 0.00175689) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142757 ± 0.00028355 (W 0.00184772) | 0.135468 ± 0.000403051 (W 0.00141943) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.648746 ± 0.00154856 (W 0.00694791) | 0.559264 ± 0.00139159 (W 0.00211621) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.53455 ± 0.00693601 (W 0.0119017) | 1.64914 ± 0.00755826 (W 0.00423395) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0178085 ± 0.000304763 (W 6.16546e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0983935 ± 0.000156271 (W 0.00109608) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.282823 ± 0.000700036 (W 0.00162499) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028248 ± 2.12132e-05 (W 0.000735862) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028378 ± 0.000176777 (W 0.000122981) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.042249 ± 0 (W 0.000909013) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.04287 ± 0.000934795 (W 0.000633355) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.091701 ± 0.00134633 (W 0.000777871) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.091491 ± 0.000411536 (W 0.000528783) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0136355 ± 0.000140714 (W 6.84995e-05) | 0.013926 ± 5.65685e-05 (W 0.000101813) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.060102 ± 0.000325269 (W 0.00205801) | 0.0677265 ± 0.000183141 (W 0.00210289) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.157354 ± 0.00017112 (W 0.0021959) | 0.180748 ± 0.00269196 (W 0.00198665) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070521 ± 0.000552958 (W 0.000418983) | 0.0539055 ± 0.000218496 (W 0.000722476) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.313786 ± 0.00606203 (W 0.00486658) | 0.264023 ± 0.000721249 (W 0.00276322) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.736204 ± 0.0548432 (W 0.00910991) | 0.985108 ± 0.00107268 (W 0.00238238) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n32/b1` | 0.058299 ± 0.000383252 (W 0.000805385) | 0.030051 ± 0.000517602 (W 0.00091145) | 🔴 fork 1.94× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.193552 ± 0.0155712 (W 0.00726179) | 0.136735 ± 0.000482247 (W 0.00169202) | 🔴 fork 1.42× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.398359 ± 0.00733058 (W 0.00446398) | 0.504938 ± 0.000788424 (W 0.00179742) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.014923 ± 0.000106066 (W 5.56616e-05) | 0.0154935 ± 0.000163342 (W 6.37261e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0623215 ± 0.000389616 (W 0.00139003) | 0.071934 ± 0.00101965 (W 0.00033883) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.160855 ± 0.000331633 (W 0.000779088) | 0.189619 ± 0.00163625 (W 0.00202916) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.236381 ± 0.000213546 (W 0.00176902) | 0.226142 ± 0.000367696 (W 0.00120145) | · |  |
| `svd_thin/n64/b1` | 1.21368 ± 0.000628618 (W 0.00303367) | 0.954717 ± 0.00222739 (W 0.00124269) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.96608 ± 0.0114672 (W 0.0233116) | 2.54743 ± 0.00311339 (W 0.00576048) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.162889 ± 0.00126855 (W 0.00177843) | 0.102977 ± 0.00013435 (W 0.000999024) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.653229 ± 0.000313955 (W 0.00158642) | 0.407956 ± 0.000349311 (W 0.00194215) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51722 ± 0.0026064 (W 0.00188206) | 1.37647 ± 0.00828022 (W 0.00304219) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001087 ± 7.07107e-06 (W 1.84628e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002705 ± 4.24264e-05 (W 1.96455e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0049795 ± 1.48492e-05 (W 3.30576e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004909 ± 0 (W 3.74232e-05) | 0.005896 ± 7.07107e-06 (W 5.95371e-05) | 🔵 fork 1.20× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.02926 ± 0.000289914 (W 0.000640941) | 0.0317145 ± 5.02046e-05 (W 0.000557004) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.082364 ± 0.000127279 (W 0.000809114) | 0.086717 ± 9.33381e-05 (W 0.000808821) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142662 ± 0.000178191 (W 0.000907215) | 0.150676 ± 0.000304056 (W 0.000757289) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.652709 ± 0.00330431 (W 0.00198479) | 0.646428 ± 8.27315e-05 (W 0.00160089) | · |  |
| `eigh/n96/b1` | 1.62056 ± 0.00267004 (W 0.00188256) | 1.62265 ± 0.00387495 (W 0.00324554) | · |  |
| `full_piv_lu/n32/b1` | 0.015795 ± 7.07107e-06 (W 0.000746751) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09095 ± 0.000270115 (W 0.00110164) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.266087 ± 1.55563e-05 (W 0.0015237) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028007 ± 2.12132e-05 (W 6.88749e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0281425 ± 0.000142128 (W 0.000610285) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157484 ± 0.000468105 (W 0.000933433) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158095 ± 0.000693672 (W 0.000750364) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.460795 ± 0.00162069 (W 0.000817542) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.464001 ± 0.00308369 (W 0.000928844) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011817 ± 4.94975e-05 (W 3.65852e-05) | 0.012644 ± 0.000113137 (W 5.70653e-05) | 🔵 fork 1.07× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052939 ± 0.000240416 (W 0.00145519) | 0.060067 ± 0.000219203 (W 0.000746659) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.14172 ± 9.19239e-05 (W 0.00170133) | 0.164678 ± 0.000113137 (W 0.000906643) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.068974 ± 2.12132e-05 (W 0.000893626) | 0.0519175 ± 0.00028355 (W 0.000223449) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.314342 ± 0.000688015 (W 0.00158973) | 0.250173 ± 0.00102601 (W 0.00182267) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.767854 ± 0.000924896 (W 0.00197518) | 0.698885 ± 0.000903682 (W 0.00216127) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.034114 ± 0.000367696 (W 0.000205509) | 0.028939 ± 0.000233345 (W 0.000731184) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.163791 ± 0.000560029 (W 0.000843772) | 0.130688 ± 0.000729027 (W 0.00105933) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.396446 ± 0.0023186 (W 0.00227694) | 0.356641 ± 0.00044477 (W 0.00195496) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.012884 ± 0.000155563 (W 5.43164e-05) | 0.0141365 ± 4.17193e-05 (W 0.00011346) | 🔵 fork 1.10× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055258 ± 0.000772161 (W 0.00128002) | 0.064801 ± 0.000183848 (W 0.000119989) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.145307 ± 0.000560029 (W 0.0011918) | 0.173204 ± 1.3435e-05 (W 0.00182688) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.234212 ± 0.000402344 (W 0.00168996) | 0.226373 ± 0.00168716 (W 0.00168292) | · |  |
| `svd_thin/n64/b1` | 1.26516 ± 0.00666448 (W 0.0040015) | 0.9367 ± 0.00890177 (W 0.00237842) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.10517 ± 0.0108873 (W 0.0039851) | 2.50975 ± 0.0140021 (W 0.00289575) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.160299 ± 0.000227688 (W 0.00198447) | 0.103463 ± 0.000382545 (W 0.000836405) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.629555 ± 0.00124946 (W 0.00287342) | 0.402382 ± 0.00408213 (W 0.00178888) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.48801 ± 0.00254488 (W 0.010661) | 1.00461 ± 0.00433315 (W 0.000663551) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0011725 ± 7.07107e-07 (W 1.24248e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0029105 ± 2.05061e-05 (W 8.2079e-06) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0050945 ± 0.000460327 (W 1.87415e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004874 ± 3.53553e-05 (W 5.37827e-05) | 0.0059365 ± 6.43467e-05 (W 7.27447e-05) | 🔵 fork 1.22× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.028819 ± 0.000190919 (W 6.28824e-05) | 0.0329365 ± 0.000333047 (W 0.000283592) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.102767 ± 0.00104086 (W 0.00284312) | 0.0877285 ± 0.000432042 (W 0.00160614) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142917 ± 0.000510531 (W 0.000158676) | 0.135468 ± 0.000333754 (W 0.000191109) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.643732 ± 0.000370524 (W 0.00317721) | 0.567125 ± 0.00142623 (W 0.00159025) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.54 ± 0.00296207 (W 0.0180815) | 1.60541 ± 0.00638942 (W 0.00208694) | · |  |
| `full_piv_lu/n32/b1` | 0.0156445 ± 7.84889e-05 (W 5.78948e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09091 ± 0.000185262 (W 0.00105732) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.26754 ± 0.000425678 (W 0.00197142) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0279675 ± 6.29325e-05 (W 8.31853e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0280275 ± 6.43467e-05 (W 0.000821263) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0758865 ± 0.0004179 (W 0.00290766) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0732665 ± 0.00355604 (W 0.00283794) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.16607 ± 0.000509117 (W 0.00325144) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.161471 ± 0.00551119 (W 0.00427924) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011682 ± 5.65685e-05 (W 0.000829782) | 0.012729 ± 7.77817e-05 (W 4.00069e-05) | 🔵 fork 1.09× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.053515 ± 6.36396e-05 (W 0.00019638) | 0.060278 ± 3.53553e-05 (W 0.000967419) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.141769 ± 5.02046e-05 (W 0.000341035) | 0.164467 ± 0.000523259 (W 0.0012273) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0686935 ± 2.05061e-05 (W 0.000991306) | 0.0516465 ± 0.000197283 (W 0.000218338) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.301904 ± 0.000823072 (W 0.00364254) | 0.248699 ± 0.000178191 (W 0.00181447) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.638508 ± 0.0528018 (W 0.0080713) | 0.892852 ± 0.00180949 (W 0.00132214) | 🔵 fork 1.40× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n32/b1` | 0.0339035 ± 0.000311834 (W 0.000288816) | 0.0291245 ± 0.000184555 (W 8.26388e-05) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.164056 ± 0.00100551 (W 0.00353953) | 0.130594 ± 0.000737512 (W 0.00236804) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.337566 ± 0.0018505 (W 0.00832143) | 0.454408 ± 0.00188303 (W 0.00186721) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.012829 ± 7.07107e-06 (W 1.97196e-05) | 0.0142415 ± 0.0001492 (W 6.06521e-05) | 🔵 fork 1.11× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055684 ± 0.000270115 (W 0.000879871) | 0.06448 ± 9.89949e-05 (W 0.00013568) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.144475 ± 0.00160796 (W 0.00628479) | 0.172527 ± 0.000346482 (W 0.00172922) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.234754 ± 0.000559321 (W 0.00211876) | 0.225862 ± 0.000608112 (W 0.00119091) | · |  |
| `svd_thin/n64/b1` | 1.23361 ± 0.000599627 (W 0.00317025) | 0.936529 ± 0.0033828 (W 0.00101919) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.95713 ± 0.0399947 (W 0.0243125) | 2.44137 ± 0.00536411 (W 0.00559054) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.160375 ± 6.29325e-05 (W 0.00133352) | 0.103238 ± 0.000374767 (W 0.00178738) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.627837 ± 0.000646296 (W 0.00159531) | 0.403458 ± 0.000164049 (W 0.00148948) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.49044 ± 0.00183353 (W 0.00840641) | 1.27229 ± 0.00557129 (W 0.00266121) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001197 ± 7.07107e-06 (W 2.29171e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0028205 ± 7.77817e-06 (W 1.93803e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00516 ± 0.0005671 (W 1.76807e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004949 ± 9.89949e-05 (W 0.000701532) | 0.005911 ± 4.24264e-05 (W 7.49957e-05) | 🔵 fork 1.19× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029014 ± 0.000270115 (W 0.000703131) | 0.0372795 ± 0.000610233 (W 0.00112953) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.11022 ± 0.00013435 (W 0.00267509) | 0.09378 ± 0.00070145 (W 0.00142331) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.142866 ± 0.000497096 (W 0.00161499) | 0.134411 ± 2.82843e-05 (W 0.00167214) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.649382 ± 0.00273226 (W 0.0039114) | 0.552215 ± 0.00132229 (W 0.00186375) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.53802 ± 0.0195798 (W 0.0139799) | 1.63361 ± 0.00104157 (W 0.00255034) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0156495 ± 2.89914e-05 (W 5.44747e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0906295 ± 0.000311834 (W 0.000353518) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.268827 ± 0.00026163 (W 0.00158775) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027907 ± 0.00013435 (W 0.000808039) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0279625 ± 4.17193e-05 (W 6.47102e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0532745 ± 0.00347826 (W 0.00286604) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.051952 ± 0.000360624 (W 0.00169945) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.101234 ± 0.000772161 (W 0.00378672) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.100738 ± 0.000141421 (W 0.00264531) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011857 ± 0.000148492 (W 0.00106576) | 0.012789 ± 0.000162635 (W 8.36935e-05) | 🔵 fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0530035 ± 0.000276479 (W 0.000932963) | 0.060483 ± 0.000254558 (W 0.000142059) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.141664 ± 7.14178e-05 (W 0.000904523) | 0.164667 ± 0.000538108 (W 0.00184596) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0686235 ± 0.000304763 (W 0.00110321) | 0.051316 ± 0.000367696 (W 0.00068915) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.352588 ± 0.0658967 (W 0.00749883) | 0.250268 ± 0.00162847 (W 0.00179096) | 🔴 fork 1.41× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.690528 ± 0.000924189 (W 0.00805932) | 0.95362 ± 0.00228537 (W 0.00205588) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.033979 ± 7.07107e-06 (W 0.000278979) | 0.028899 ± 2.12132e-05 (W 0.000173034) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.17943 ± 0.0116262 (W 0.00270127) | 0.13097 ± 0.000333754 (W 0.00141381) | 🔴 fork 1.37× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.352002 ± 0.000999849 (W 0.00475191) | 0.488341 ± 0.00573605 (W 0.00200559) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.012824 ± 9.89949e-05 (W 4.19386e-05) | 0.014067 ± 0 (W 7.65443e-05) | 🔵 fork 1.10× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055408 ± 0.000616597 (W 0.000104342) | 0.0643755 ± 0.000135057 (W 0.00074884) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.145136 ± 0.00026163 (W 0.000735543) | 0.172542 ± 0.000622254 (W 0.00119222) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.234077 ± 0.000298399 (W 0.00127063) | 0.224979 ± 0.000395273 (W 0.00133311) | · |  |
| `svd_thin/n64/b1` | 1.24112 ± 0.00188585 (W 0.00396682) | 0.935546 ± 0.00297126 (W 0.00154424) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.9266 ± 0.0104298 (W 0.0121236) | 2.51185 ± 0.0137617 (W 0.00770814) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.161276 ± 0.00128128 (W 0.0012443) | 0.102702 ± 5.65685e-05 (W 0.000811802) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.629941 ± 0.0015818 (W 0.00188164) | 0.400212 ± 0.0002885 (W 0.00248439) | 🔴 fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.49168 ± 0.00480974 (W 0.00209324) | 1.3569 ± 0.0105967 (W 0.0028313) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001197 ± 2.12132e-05 (W 1.77478e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0028805 ± 9.2631e-05 (W 9.73169e-06) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0051645 ± 6.36396e-06 (W 0.000736957) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070707 ± 6.36396e-05 (W 0.00117377) | 0.161126 ± 0.000162635 (W 0.00309965) | 🔵 fork 2.28× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.396771 ± 0.00226911 (W 0.00187697) | 1.01255 ± 0.00275135 (W 0.00530994) | 🔵 fork 2.55× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.55252 ± 0.0213412 (W 0.00335906) | 5.9716 ± 0.0263157 (W 0.00983559) | 🔵 fork 2.34× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.26832 ± 0.00332835 (W 0.0023206) | 1.87505 ± 0.0108887 (W 0.0133734) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.80061 ± 0.0200422 (W 0.00375846) | 9.15951 ± 0.0112274 (W 0.010919) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 48.8912 ± 0.138756 (W 0.0407446) | 51.6929 ± 0.311622 (W 0.22308) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.309883 ± 0.000532451 (W 0.00201375) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70646 ± 0.006487 (W 0.00766192) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.8499 ± 0.184351 (W 0.0461461) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259394 ± 0.0011342 (W 0.00192805) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.260111 ± 0.000263751 (W 0.00125958) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90581 ± 0.000276479 (W 0.00350069) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.911 ± 0.0055324 (W 0.00365004) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 16.0929 ± 0.0506119 (W 0.0191536) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9354 ± 0.0258709 (W 0.022004) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.164092 ± 0.000276479 (W 0.0022231) | 0.206415 ± 0.00426385 (W 0.00358838) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.981832 ± 0.000287792 (W 0.00232165) | 1.36632 ± 0.00628194 (W 0.00412353) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 6.61678 ± 0.0204538 (W 0.0160073) | 8.16269 ± 0.0116793 (W 0.00974962) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.515227 ± 0.00124239 (W 0.00218566) | 0.860581 ± 0.0118412 (W 0.00699908) | 🔵 fork 1.67× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.89319 ± 0.00135552 (W 0.00246018) | 4.36156 ± 0.00210152 (W 0.0120064) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 20.3252 ± 0.119527 (W 0.2133) | 30.7597 ± 0.0401545 (W 0.0679518) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.334213 ± 0.00579333 (W 0.00162929) | 0.432777 ± 0.000764382 (W 0.00408151) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.60096 ± 0.0178594 (W 0.00411581) | 2.17046 ± 0.0111949 (W 0.00476997) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.91299 ± 0.0296271 (W 0.0135691) | 14.4265 ± 0.023867 (W 0.0194405) | 🔵 fork 1.62× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.133745 ± 0.000856306 (W 0.00230296) | 0.204207 ± 0.00566039 (W 0.00513065) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.755665 ± 0.00343937 (W 0.00176402) | 1.131 ± 0.00481469 (W 0.00318033) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.55739 ± 0.00369251 (W 0.0133019) | 7.10917 ± 0.0129005 (W 0.00602225) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.69654 ± 0.011016 (W 0.00749071) | 3.14203 ± 0.013097 (W 0.0104825) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.4768 ± 0.053825 (W 0.0198532) | 17.5863 ± 0.0546792 (W 0.0288348) | · |  |
| `svd_thin/n512/b1` | 105.759 ± 0.0825894 (W 0.284106) | 123.246 ± 2.32778 (W 0.284594) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.70267 ± 0.0111546 (W 0.00496437) | 1.35251 ± 0.00609809 (W 0.00420018) | 🔴 fork 2.00× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.5006 ± 0.0186125 (W 0.0177749) | 7.92404 ± 0.0515651 (W 0.00749754) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 66.2155 ± 0.205881 (W 0.0435056) | 55.0813 ± 0.49511 (W 0.0802135) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004183 ± 0.000219203 (W 6.46273e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0108045 ± 0.00108399 (W 6.55241e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.036839 ± 0.00443497 (W 0.000411936) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.087839 ± 0.00360624 (W 0.00175297) | 0.169481 ± 0.00119784 (W 0.0025816) | 🔵 fork 1.93× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.395358 ± 0.000536694 (W 0.0190383) | 0.855056 ± 0.00711491 (W 0.00866813) | 🔵 fork 2.16× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 1.56709 ± 0.0158809 (W 0.0306866) | 4.61185 ± 0.0709857 (W 0.0207138) | 🔵 fork 2.94× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.29488 ± 0.00325976 (W 0.0150381) | 1.49602 ± 0.0025173 (W 0.00508877) | 🔴 fork 1.53× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.95877 ± 0.0404267 (W 0.226346) | 6.0973 ± 0.00406091 (W 0.0116098) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 26.2923 ± 0.22312 (W 0.0957692) | 29.5288 ± 0.583128 (W 0.0534323) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.310314 ± 0.00129542 (W 0.00247216) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71443 ± 0.0214013 (W 0.00749643) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.5402 ± 0.150299 (W 0.238289) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.085149 ± 0.000254558 (W 0.000941987) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0868665 ± 0.000290621 (W 0.00163371) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.523602 ± 0.00424476 (W 0.00632162) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.526928 ± 0.00196434 (W 0.00585774) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.16326 ± 0.00020294 (W 0.0203731) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.19937 ± 0.0244362 (W 0.018122) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.164351 ± 0.00191909 (W 0.00271801) | 0.201942 ± 0.000560029 (W 0.00233534) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.993549 ± 0.000690136 (W 0.0042342) | 1.04316 ± 0.000556493 (W 0.00761349) | · |  |
| `lu/n512/b1` | 4.87588 ± 0.0872704 (W 0.0860885) | 5.71738 ± 0.140359 (W 0.0261981) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.585538 ± 0.044371 (W 0.0409629) | 0.896794 ± 0.00447952 (W 0.00586042) | 🔵 fork 1.53× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n256/b1` | 1.97015 ± 0.00966898 (W 0.0298784) | 3.55528 ± 0.0345606 (W 0.0118528) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 10.1005 ± 0.0626532 (W 0.0773819) | 19.1749 ± 0.0502166 (W 0.0237911) | 🔵 fork 1.90× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.414168 ± 0.0206489 (W 0.0108092) | 0.446884 ± 0.00164473 (W 0.00529542) | 🔵 fork 1.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.42782 ± 0.00206617 (W 0.0269725) | 1.76296 ± 0.00524673 (W 0.00484008) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 5.14153 ± 0.00434234 (W 0.208017) | 9.41919 ± 0.0738446 (W 0.014178) | 🔵 fork 1.83× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.138283 ± 0.00238719 (W 0.00236774) | 0.168128 ± 0.000843578 (W 0.00233634) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.764637 ± 0.00634982 (W 0.0018498) | 0.795209 ± 0.00047659 (W 0.00276345) | · |  |
| `solve/n512/b1` | 4.69503 ± 0.0641395 (W 0.0676604) | 4.53897 ± 0.034516 (W 0.00575904) | · |  |
| `svd_thin/n128/b1` | 3.02054 ± 0.0200005 (W 0.0330392) | 3.07727 ± 0.000330926 (W 0.00666151) | · |  |
| `svd_thin/n256/b1` | 13.6895 ± 0.0117578 (W 0.0333041) | 14.9092 ± 0.042203 (W 0.0158566) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 61.7719 ± 0.42478 (W 0.314755) | 94.4916 ± 1.93302 (W 0.423214) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.23598 ± 0.00356948 (W 0.00868619) | 1.38945 ± 0.00292247 (W 0.00463119) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.9103 ± 0.0886613 (W 0.0403939) | 7.6867 ± 0.0296971 (W 0.00942298) | 🔴 fork 1.42× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 48.1066 ± 0.210859 (W 0.390221) | 49.8931 ± 0.486218 (W 0.0929348) | · |  |
| `triangular_solve/n128/b1` | 0.004028 ± 0.000468105 (W 5.96662e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.010554 ± 0.000772161 (W 7.14983e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0350455 ± 0.000255266 (W 0.000343168) | - | - | `*` one row has no measurement here |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.092147 ± 0.00350725 (W 0.00379553) | 0.166575 ± 0.0013527 (W 0.00374723) | 🔵 fork 1.81× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.4074 ± 0.0157847 (W 0.0153306) | 0.846599 ± 0.00419526 (W 0.0064465) | 🔵 fork 2.08× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.533 ± 0.000421436 (W 0.0249028) | 4.42765 ± 0.0155323 (W 0.031078) | 🔵 fork 2.89× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.38671 ± 0.030209 (W 0.0202983) | 1.43149 ± 0.00546523 (W 0.00430473) | 🔴 fork 1.67× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.871 ± 0.0913448 (W 0.0434815) | 5.73646 ± 0.0165866 (W 0.014947) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 24.2293 ± 0.182313 (W 0.0473776) | 25.3813 ± 0.0680406 (W 0.0302958) | · |  |
| `full_piv_lu/n128/b1` | 0.30806 ± 0.0001492 (W 0.00205896) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70235 ± 0.0166326 (W 0.0105767) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.3006 ± 0.204832 (W 0.0830901) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.060122 ± 0.000892369 (W 0.00118849) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.060308 ± 0.00050346 (W 0.00088503) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.283919 ± 0.00185616 (W 0.00158449) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.290392 ± 0.000524673 (W 0.00159695) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.26404 ± 0.0151201 (W 0.0131642) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.27125 ± 0.0107134 (W 0.012543) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.163991 ± 0.000758018 (W 0.00101896) | 0.199482 ± 0.00538391 (W 0.00259583) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.999594 ± 0.00635901 (W 0.0147168) | 0.977224 ± 0.00205273 (W 0.00339534) | · |  |
| `lu/n512/b1` | 4.71034 ± 0.120259 (W 0.165055) | 4.8052 ± 0.0894639 (W 0.0196292) | · |  |
| `qr/n128/b1` | 0.598221 ± 0.00923199 (W 0.0165529) | 0.899989 ± 0.00671751 (W 0.00842725) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.80004 ± 0.0105663 (W 0.0215319) | 3.51264 ± 0.0115605 (W 0.00822371) | 🔵 fork 1.95× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.82035 ± 0.00815577 (W 0.0571388) | 17.7055 ± 0.020371 (W 0.107501) | 🔵 fork 2.01× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.360412 ± 0.000412243 (W 0.00805485) | 0.45043 ± 0.000822365 (W 0.00364388) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.39919 ± 0.00507632 (W 0.0206026) | 1.73407 ± 0.00368049 (W 0.00413625) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 5.3346 ± 0.786565 (W 0.0437394) | 8.75076 ± 0.103185 (W 0.0173153) | 🔵 fork 1.64× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n128/b1` | 0.133785 ± 0.0013527 (W 0.00174378) | 0.205153 ± 0.000879641 (W 0.00389066) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.764327 ± 0.00235396 (W 0.00154258) | 0.745565 ± 0.00810981 (W 0.00364839) | · |  |
| `solve/n512/b1` | 4.64675 ± 0.0380812 (W 0.0632672) | 3.69656 ± 0.0496248 (W 0.0119776) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.03862 ± 0.00180029 (W 0.0194138) | 3.05852 ± 0.0060493 (W 0.0145113) | · |  |
| `svd_thin/n256/b1` | 13.4418 ± 0.0352592 (W 0.0220283) | 14.6046 ± 0.0176077 (W 0.0170104) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 59.6099 ± 0.433 (W 0.557554) | 90.2218 ± 2.94512 (W 0.1446) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.29691 ± 0.00418819 (W 0.00610785) | 1.38868 ± 0.00440315 (W 0.00381731) | 🔴 fork 1.65× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 11.024 ± 0.0305166 (W 0.0280819) | 7.57613 ± 0.00402839 (W 0.0164873) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 49.3665 ± 0.0306552 (W 0.455583) | 49.5799 ± 0.333717 (W 0.143485) | · |  |
| `triangular_solve/n128/b1` | 0.0039975 ± 2.75772e-05 (W 5.62716e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.009949 ± 1.41421e-05 (W 6.48314e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.039093 ± 0.00246497 (W 0.00064188) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.063769 ± 0.000339411 (W 0.000123679) | 0.071739 ± 0.000446891 (W 0.000172799) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.324836 ± 0.00103308 (W 0.00201331) | 0.407481 ± 0.00057912 (W 0.00222289) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.06475 ± 0.00391171 (W 0.00212663) | 2.71405 ± 0.000747412 (W 0.00590888) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.26937 ± 0.00519865 (W 0.00254643) | 1.79199 ± 0.00755897 (W 0.00553269) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.76387 ± 0.0084874 (W 0.0182036) | 8.72304 ± 0.00410546 (W 0.0062278) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 48.4091 ± 0.0185043 (W 0.0474743) | 49.3979 ± 0.0918093 (W 0.0502118) | · |  |
| `full_piv_lu/n128/b1` | 0.290507 ± 0.000941159 (W 0.00187777) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62772 ± 0.0124083 (W 0.0059531) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.2613 ± 0.311623 (W 0.0332302) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.253463 ± 0.000255973 (W 0.00203018) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.253964 ± 0.000213546 (W 0.00188499) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.87231 ± 0.00524249 (W 0.003806) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.87925 ± 0.00542634 (W 0.00474208) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8934 ± 0.025284 (W 0.0401488) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7422 ± 0.00888409 (W 0.0207353) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.129141 ± 0.0204453 (W 0.000742881) | 0.156972 ± 0.00430699 (W 0.00200039) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.897695 ± 0.00365928 (W 0.00355701) | 0.854445 ± 0.0158795 (W 0.00273359) | · |  |
| `lu/n512/b1` | 6.13034 ± 0.00564978 (W 0.00863233) | 5.23766 ± 0.0574751 (W 0.0064618) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.490355 ± 0.000281428 (W 0.00295056) | 0.783388 ± 0.0161765 (W 0.00843778) | 🔵 fork 1.60× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.78312 ± 0.00476519 (W 0.00405051) | 4.07899 ± 0.0416535 (W 0.00781661) | 🔵 fork 1.47× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.8088 ± 0.199074 (W 0.0717588) | 27.0819 ± 0.034178 (W 0.0232188) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.276611 ± 0.00182151 (W 0.00247772) | 0.37519 ± 0.00269266 (W 0.00188207) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.37316 ± 0.00196788 (W 0.00314223) | 1.87277 ± 0.0100452 (W 0.00241264) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.03177 ± 0.0120618 (W 0.00992141) | 12.5255 ± 0.0893458 (W 0.020462) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111743 ± 0.000559321 (W 0.000980268) | 0.149018 ± 0.000213546 (W 0.000932568) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.66461 ± 0.00154715 (W 0.0029903) | 0.8278 ± 0.00165392 (W 0.00208662) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.06352 ± 0.0151858 (W 0.0118456) | 5.18122 ± 0.0844229 (W 0.0128022) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.69003 ± 0.0188508 (W 0.00607464) | 3.02156 ± 0.00210859 (W 0.00493806) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.3393 ± 0.0377298 (W 0.0215274) | 16.9677 ± 0.0241081 (W 0.0286619) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 104.863 ± 0.13308 (W 0.114521) | 116.591 ± 0.275195 (W 0.126722) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.61888 ± 0.00881691 (W 0.00588143) | 1.28843 ± 0.00464569 (W 0.00236974) | 🔴 fork 2.03× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.3283 ± 0.01836 (W 0.0149134) | 7.67028 ± 0.0158894 (W 0.0103814) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.2384 ± 0.268133 (W 0.422627) | 52.5321 ± 0.0947035 (W 0.0371213) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004408 ± 0.000240416 (W 4.47709e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0119425 ± 0.00067953 (W 0.00019273) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0400995 ± 0.00303844 (W 0.00100459) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.080145 ± 0.00364867 (W 0.00269602) | 0.07773 ± 0.0035921 (W 0.00172321) | · | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.323518 ± 0.0360653 (W 0.0187912) | 0.282617 ± 0.00471923 (W 0.00646459) | 🔴 fork 1.14× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.14322 ± 0.0123722 (W 0.030812) | 1.32334 ± 0.01646 (W 0.0048404) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.30041 ± 0.0164013 (W 0.025857) | 1.42094 ± 0.000393151 (W 0.00426144) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.91211 ± 0.00192969 (W 0.0196405) | 5.65339 ± 0.0266798 (W 0.00488926) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 25.9343 ± 0.25748 (W 0.0698987) | 26.0955 ± 0.181466 (W 0.0191172) | · |  |
| `full_piv_lu/n128/b1` | 0.291695 ± 1.3435e-05 (W 0.00128438) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62364 ± 0.0152657 (W 0.00985321) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9535 ± 0.0838572 (W 0.108275) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0947315 ± 0.000375474 (W 0.00122089) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.09662 ± 0.000155563 (W 0.00178979) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.529143 ± 0.00516612 (W 0.0043819) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.532599 ± 0.000192333 (W 0.00467066) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.12295 ± 0.0109425 (W 0.0206644) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.19639 ± 0.0021496 (W 0.0107484) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.130234 ± 0.0231514 (W 0.00108489) | 0.151037 ± 0.000376181 (W 0.00160732) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.906176 ± 0.00284398 (W 0.00371503) | 0.651952 ± 0.208726 (W 0.0106531) | 🔴 fork 1.39× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.2837 ± 0.00230163 (W 0.140019) | 2.68755 ± 0.0832555 (W 0.00235106) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.573916 ± 0.00527572 (W 0.0335486) | 0.789648 ± 0.00536553 (W 0.00593179) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.886 ± 0.00410405 (W 0.0166676) | 3.24544 ± 0.0109333 (W 0.00783183) | 🔵 fork 1.72× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 9.50925 ± 0.0168723 (W 0.135977) | 16.867 ± 0.121604 (W 0.0402892) | 🔵 fork 1.77× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.325037 ± 0.0226119 (W 0.0131398) | 0.394466 ± 0.000567807 (W 0.000958626) | 🔵 fork 1.21× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.3284 ± 0.00064771 (W 0.0247855) | 1.46675 ± 0.0232765 (W 0.00262932) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.76429 ± 0.0776226 (W 0.0402715) | 7.70959 ± 0.118527 (W 0.0108849) | 🔵 fork 1.62× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.113317 ± 0.00132512 (W 0.000324052) | 0.115115 ± 0.00232355 (W 0.000916652) | · |  |
| `solve/n256/b1` | 0.672426 ± 0.00455023 (W 0.00316329) | 0.486548 ± 0.0027358 (W 0.00251156) | 🔴 fork 1.38× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 4.18277 ± 0.0047659 (W 0.0664703) | 2.57431 ± 0.00158038 (W 0.0207181) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.00038 ± 0.0104362 (W 0.0177917) | 2.93607 ± 0.0104574 (W 0.00813122) | · |  |
| `svd_thin/n256/b1` | 13.5403 ± 0.0785589 (W 0.105878) | 14.1904 ± 0.165032 (W 0.0317941) | · |  |
| `svd_thin/n512/b1` | 60.762 ± 0.138886 (W 0.449929) | 85.0577 ± 1.30715 (W 0.0698647) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.17028 ± 0.0120279 (W 0.00427032) | 1.33071 ± 0.000725492 (W 0.00253332) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.7167 ± 0.0948676 (W 0.0157314) | 7.28919 ± 0.0167881 (W 0.00861709) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 47.1972 ± 0.202747 (W 0.284596) | 47.7797 ± 0.824685 (W 0.0698748) | · |  |
| `triangular_solve/n128/b1` | 0.0044585 ± 0.000311834 (W 2.48712e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011802 ± 0.00123319 (W 6.30556e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0397995 ± 6.29325e-05 (W 0.000393489) | - | - | `*` one row has no measurement here |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.087132 ± 0.00123319 (W 0.003078) | 0.0748945 ± 0.000488611 (W 0.000555532) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.350915 ± 0.0105988 (W 0.0241472) | 0.279737 ± 0.000588313 (W 0.00210683) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 1.06976 ± 0.0144207 (W 0.0137134) | 1.22015 ± 0.0183452 (W 0.00910727) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.37412 ± 0.0371655 (W 0.040069) | 1.36153 ± 0.00195091 (W 0.00481771) | 🔴 fork 1.74× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.85379 ± 0.0459209 (W 0.030174) | 5.27164 ± 0.0048062 (W 0.00764842) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 23.8384 ± 0.163243 (W 0.0596149) | 22.6124 ± 0.0698416 (W 0.0327628) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.288693 ± 0.000446891 (W 0.00218962) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61603 ± 0.00345068 (W 0.00788794) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.7907 ± 0.0169988 (W 0.14384) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.069084 ± 0.00133926 (W 0.00192293) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.069264 ± 0.000786303 (W 0.00068893) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.299519 ± 0.00281994 (W 0.0018792) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.301412 ± 0.00236598 (W 0.0016334) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.28066 ± 0.0282143 (W 0.0112725) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.27268 ± 0.000519016 (W 0.009249) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.129402 ± 0.0206001 (W 0.00100645) | 0.15506 ± 0.00519936 (W 0.000919116) | 🔵 fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.919069 ± 0.00238507 (W 0.0100225) | 0.439966 ± 0.00033234 (W 0.00255023) | 🔴 fork 2.09× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 4.20144 ± 0.118093 (W 0.0621898) | 1.75316 ± 0.0200168 (W 0.00908857) | 🔴 fork 2.40× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.565515 ± 0.0024381 (W 0.0207304) | 0.787244 ± 0.00295288 (W 0.0039158) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.70597 ± 0.00910754 (W 0.0159729) | 3.18694 ± 0.0299743 (W 0.0040102) | 🔵 fork 1.87× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.24588 ± 0.014413 (W 0.0675464) | 15.4172 ± 0.100645 (W 0.095154) | 🔵 fork 1.87× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.326018 ± 0.001871 (W 0.00643371) | 0.392933 ± 0.00192616 (W 0.00467943) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.29423 ± 0.00403404 (W 0.01333) | 1.43745 ± 0.0140092 (W 0.00676403) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.50632 ± 0.0201299 (W 0.0132786) | 6.85232 ± 0.0562206 (W 0.0352115) | 🔵 fork 1.52× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111522 ± 0.000545179 (W 0.000143336) | 0.150184 ± 0.00167938 (W 0.00149618) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.678746 ± 0.00201384 (W 0.00288148) | 0.446017 ± 0.00168009 (W 0.00305646) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 4.06207 ± 0.0188889 (W 0.0208027) | 1.74477 ± 0.00461529 (W 0.0347747) | 🔴 fork 2.33× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.01189 ± 0.0019205 (W 0.00923791) | 2.93237 ± 0.00547583 (W 0.00540926) | · |  |
| `svd_thin/n256/b1` | 13.3571 ± 0.0112656 (W 0.0462367) | 13.891 ± 0.00858074 (W 0.0125428) | · |  |
| `svd_thin/n512/b1` | 58.5624 ± 0.204419 (W 0.341269) | 79.962 ± 0.377429 (W 0.159365) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.20607 ± 0.0121728 (W 0.0063502) | 1.33185 ± 0.000287792 (W 0.0038838) | 🔴 fork 1.66× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.8459 ± 0.00872994 (W 0.0349149) | 7.29008 ± 0.0172315 (W 0.00823423) | 🔴 fork 1.49× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 48.4592 ± 0.440168 (W 0.364955) | 46.9214 ± 0.458612 (W 0.102098) | · |  |
| `triangular_solve/n128/b1` | 0.004283 ± 9.19239e-05 (W 3.577e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0109805 ± 0.000212839 (W 0.000211411) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044929 ± 0.00166453 (W 0.00136665) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.185731 ± 0.000163342 (W 0.0015199) | 0.326956 ± 0.000757311 (W 0.0013222) | 🔵 fork 1.76× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.23748 ± 0.0238274 (W 0.00781067) | 2.11436 ± 0.00385302 (W 0.00621512) | 🔵 fork 1.71× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.92338 ± 0.0157911 (W 0.0164406) | 12.6448 ± 0.0588681 (W 0.205871) | 🔵 fork 1.60× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.28333 ± 0.0143776 (W 0.00271728) | 3.36747 ± 0.00820032 (W 0.00745518) | · |  |
| `eigh/n256/b1` | 17.5433 ± 0.051389 (W 0.0153179) | 20.3094 ± 0.0637379 (W 0.0185774) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.886 ± 0.0656457 (W 0.0628392) | 141.194 ± 0.00982383 (W 0.404208) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.80949 ± 0.0480564 (W 0.00657927) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 6.0538 ± 0.117882 (W 0.00794174) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.9032 ± 0.525409 (W 0.212756) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05053 ± 0.00164756 (W 0.00156941) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.0516 ± 0.00120774 (W 0.001696) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49789 ± 0.00979555 (W 0.00728061) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52766 ± 0.00508834 (W 0.0116363) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 57.0079 ± 0.0524935 (W 0.0613789) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 57.0324 ± 0.0393816 (W 0.212559) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.333182 ± 4.38406e-05 (W 0.00161818) | 0.425499 ± 0.00601606 (W 0.00404234) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.14863 ± 0.00745998 (W 0.00279076) | 2.77444 ± 0.00162705 (W 0.00331017) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 14.7472 ± 0.0562737 (W 0.04437) | 18.4964 ± 0.00248194 (W 0.0690543) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.57333 ± 0.000473054 (W 0.00356561) | 1.62892 ± 0.0110153 (W 0.00447703) | · |  |
| `qr/n256/b1` | 10.2424 ± 0.0202537 (W 0.0136007) | 11.3474 ± 0.00417617 (W 0.211073) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 69.83 ± 0.0393639 (W 0.0496165) | 75.5972 ± 0.311394 (W 0.285062) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.825741 ± 0.00929138 (W 0.00153587) | 0.820175 ± 0.00372221 (W 0.0033851) | · |  |
| `qr_factor/n256/b1` | 4.8146 ± 0.0483336 (W 0.00349536) | 5.65525 ± 0.00493278 (W 0.0096289) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 30.7603 ± 0.107397 (W 0.0509427) | 37.4729 ± 0.0443809 (W 0.0668156) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.32966 ± 0.00109602 (W 0.00247097) | 0.450496 ± 0.00760281 (W 0.00419401) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 2.08457 ± 0.00487409 (W 0.00196397) | 2.84573 ± 0.00207889 (W 0.00490701) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 14.7235 ± 0.0101922 (W 0.0205411) | 18.6321 ± 0.0337552 (W 0.026603) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.74825 ± 0.0142864 (W 0.0187312) | 5.66174 ± 0.00140785 (W 0.0119728) | · |  |
| `svd_thin/n256/b1` | 34.3748 ± 0.112342 (W 0.0476619) | 36.8148 ± 0.207413 (W 0.042478) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 212.435 ± 0.0411211 (W 0.220394) | 236.611 ± 0.373135 (W 0.608306) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.48289 ± 0.00499712 (W 0.0039077) | 2.31611 ± 0.0247466 (W 0.00413016) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.4205 ± 0.00369746 (W 0.0473122) | 16.24 ± 0.0420538 (W 0.0224872) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 112.334 ± 0.0114983 (W 0.0804108) | 100.769 ± 2.45178 (W 0.381555) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0075995 ± 7.84889e-05 (W 0.00010401) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023509 ± 2.12132e-05 (W 5.25107e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0866865 ± 0.0001492 (W 0.00167564) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.18512 ± 0.00288287 (W 0.00389882) | 0.27018 ± 0.00462519 (W 0.00618581) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.842672 ± 0.00591141 (W 0.0104793) | 1.39322 ± 0.00209374 (W 0.00282324) | 🔵 fork 1.65× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.36127 ± 0.00539735 (W 0.0273303) | 6.98842 ± 0.059858 (W 0.00925964) | 🔵 fork 2.08× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.97427 ± 0.0390705 (W 0.0201796) | 2.64891 ± 0.0135163 (W 0.00393324) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 11.466 ± 0.0733998 (W 0.0560245) | 12.0335 ± 0.0472948 (W 0.0182746) | · |  |
| `eigh/n512/b1` | 46.6742 ± 0.103716 (W 0.0902047) | 55.6172 ± 0.0813088 (W 0.0577807) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.774054 ± 0.0011646 (W 0.00537739) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.93192 ± 0.00136613 (W 0.0203289) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.982 ± 0.1461 (W 0.0722956) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.288484 ± 0.000730441 (W 0.00159128) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.288504 ± 0.00132441 (W 0.00153631) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93198 ± 0.00545957 (W 0.00597145) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93883 ± 0.00488399 (W 0.0031642) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7765 ± 0.0895162 (W 0.0443343) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8203 ± 0.00945826 (W 0.0608979) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.333322 ± 0.000114551 (W 0.00206629) | 0.313826 ± 0.000241831 (W 0.00244516) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 2.16669 ± 0.00196081 (W 0.006449) | 1.80513 ± 0.0161121 (W 0.00367773) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 8.18001 ± 0.0294913 (W 0.0559387) | 7.53283 ± 0.0484368 (W 0.0264589) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 1.01928 ± 0.00163342 (W 0.00306441) | 1.46957 ± 0.00413304 (W 0.00435784) | 🔵 fork 1.44× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 4.54906 ± 0.0273198 (W 0.0433049) | 7.11748 ± 0.0300266 (W 0.0181519) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 23.2799 ± 0.0359719 (W 0.275576) | 35.5131 ± 0.645488 (W 0.232478) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.612763 ± 0.00342664 (W 0.00784554) | 0.73651 ± 0.00599839 (W 0.0022049) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.92478 ± 0.0107254 (W 0.0306375) | 3.56725 ± 0.06761 (W 0.00976341) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 12.0433 ± 0.0579453 (W 0.0432018) | 17.1803 ± 0.0553064 (W 0.0217455) | 🔵 fork 1.43× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.331614 ± 0.00142482 (W 0.00177839) | 0.31091 ± 0.00220971 (W 0.00497831) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 2.10417 ± 0.00344502 (W 0.00537806) | 1.67242 ± 0.00520926 (W 0.00351669) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 8.18399 ± 0.0670811 (W 0.100553) | 7.63743 ± 0.308735 (W 0.020474) | 🔴 fork 1.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 4.34807 ± 0.0238493 (W 0.0361085) | 4.84044 ± 0.000975807 (W 0.00453402) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 22.6898 ± 0.0639373 (W 0.108511) | 23.4577 ± 0.0219903 (W 0.019428) | · |  |
| `svd_thin/n512/b1` | 95.5024 ± 0.252689 (W 0.260116) | 119.408 ± 0.306274 (W 0.232396) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.05506 ± 0.00766504 (W 0.00468059) | 2.46849 ± 0.00497945 (W 0.00695393) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.2686 ± 0.0291229 (W 0.0668283) | 12.0282 ± 0.0444176 (W 0.0195223) | 🔴 fork 1.44× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.4166 ± 0.265394 (W 0.192293) | 54.1804 ± 0.330927 (W 0.190411) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007554 ± 0 (W 4.24761e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023368 ± 3.53553e-05 (W 3.62425e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.072781 ± 0.000233345 (W 0.00139158) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.193306 ± 0.00123956 (W 0.00242202) | 0.299208 ± 0.0016716 (W 0.00288762) | 🔵 fork 1.55× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.827423 ± 0.000625082 (W 0.0166023) | 1.35187 ± 0.0124797 (W 0.00276447) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.79198 ± 0.00635618 (W 0.0207215) | 5.82938 ± 0.00655488 (W 0.0335891) | 🔵 fork 2.09× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.96202 ± 0.00232214 (W 0.0242416) | 2.54427 ± 0.00428082 (W 0.00377531) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.8669 ± 0.00738927 (W 0.0243624) | 10.821 ± 0.0259204 (W 0.0111919) | · |  |
| `eigh/n512/b1` | 39.2596 ± 0.141484 (W 0.235458) | 43.214 ± 0.0543546 (W 0.0597365) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.773362 ± 0.000497096 (W 0.00815614) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.91273 ± 0.00864792 (W 0.0154204) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.3814 ± 0.0802128 (W 0.0706743) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.183743 ± 0.000609526 (W 0.00363072) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.187249 ± 0.000581949 (W 0.00115764) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01139 ± 0.00552745 (W 0.00574786) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01784 ± 0.00301935 (W 0.00770485) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.14102 ± 0.040233 (W 0.120136) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.04709 ± 0.000631446 (W 0.0365828) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.33258 ± 0.00186959 (W 0.00210935) | 0.301928 ± 0.00547725 (W 0.00380646) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 2.16568 ± 0.00416839 (W 0.0293027) | 1.31475 ± 0.00242538 (W 0.00243613) | 🔴 fork 1.65× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 7.08276 ± 0.0357761 (W 0.0406737) | 5.16224 ± 0.0101491 (W 0.00830083) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.990358 ± 0.00615112 (W 0.0106366) | 1.45041 ± 0.000279307 (W 0.00481522) | 🔵 fork 1.46× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.48084 ± 0.0527424 (W 0.0272199) | 6.49868 ± 0.00326683 (W 0.0131291) | 🔵 fork 1.87× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 16.0046 ± 0.0359635 (W 0.0582189) | 28.8134 ± 0.815316 (W 0.0613721) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.61678 ± 0.00337361 (W 0.00562878) | 0.727542 ± 0.00271458 (W 0.00311115) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.4444 ± 0.0116234 (W 0.023278) | 3.21268 ± 0.00825335 (W 0.00985971) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 9.35525 ± 0.0193585 (W 0.0351226) | 14.0311 ± 0.343801 (W 0.0216185) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.329816 ± 0.00174231 (W 0.00198189) | 0.306056 ± 0.00401637 (W 0.00345275) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 2.11062 ± 0.0131882 (W 0.0195598) | 1.30293 ± 0.000394566 (W 0.00510322) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 7.05504 ± 0.0304346 (W 0.0396168) | 5.10088 ± 0.0103888 (W 0.008616) | 🔴 fork 1.38× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.24171 ± 0.0137419 (W 0.0290471) | 4.76436 ± 0.00457852 (W 0.01029) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 21.4422 ± 0.0696514 (W 0.0585949) | 21.8521 ± 0.0560934 (W 0.0446171) | · |  |
| `svd_thin/n512/b1` | 80.68 ± 0.383876 (W 0.230412) | 100.981 ± 0.0914402 (W 0.107385) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.07973 ± 0.0294694 (W 0.0201422) | 2.55137 ± 0.00576928 (W 0.0102889) | 🔴 fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.3066 ± 0.0152403 (W 0.0545837) | 11.9 ± 0.0466132 (W 0.0342068) | 🔴 fork 1.45× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 61.9857 ± 0.38836 (W 0.312197) | 48.6138 ± 0.17014 (W 0.0924842) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007615 ± 0 (W 3.76476e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023629 ± 2.12132e-05 (W 9.33433e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0705165 ± 0.00061589 (W 0.00120899) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.173594 ± 0.0005671 (W 0.000872835) | 0.184389 ± 0.00030547 (W 0.00119813) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.13235 ± 0.00257387 (W 0.00139209) | 1.30276 ± 0.0159163 (W 0.00267046) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.56562 ± 0.0321005 (W 0.0161668) | 9.04206 ± 0.00331209 (W 0.0186747) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.27544 ± 0.0100989 (W 0.00369727) | 3.23952 ± 0.0137037 (W 0.00264603) | · |  |
| `eigh/n256/b1` | 17.4281 ± 0.0089746 (W 0.0240876) | 19.6581 ± 0.149236 (W 0.0229911) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.549 ± 0.182172 (W 0.0830855) | 138.321 ± 0.035752 (W 0.287757) | 🔵 fork 1.31× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.788301 ± 0.048113 (W 0.00745809) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.90421 ± 0.122622 (W 0.00581994) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.1919 ± 0.485038 (W 0.212357) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03401 ± 0.00358857 (W 0.000940987) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04013 ± 0.001562 (W 0.000491811) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.40302 ± 0.00745149 (W 0.0117307) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44994 ± 0.0114714 (W 0.0108798) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 57.0734 ± 0.0189151 (W 0.0672291) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7621 ± 0.0516386 (W 0.221988) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.304713 ± 0.000631446 (W 0.00252018) | 0.349121 ± 0.000509117 (W 0.00149909) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.04092 ± 0.0161595 (W 0.00534737) | 2.33545 ± 0.0143118 (W 0.00623802) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 13.9876 ± 0.0176112 (W 0.206146) | 16.3836 ± 0.00185403 (W 0.202433) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.54898 ± 0.00249892 (W 0.00303425) | 1.55831 ± 0.0130963 (W 0.00365519) | · |  |
| `qr/n256/b1` | 10.1249 ± 0.023669 (W 0.0260391) | 10.7876 ± 0.0513529 (W 0.0196554) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 68.9075 ± 0.103522 (W 0.208932) | 73.1998 ± 0.133413 (W 0.113016) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.758871 ± 0.000656195 (W 0.00348652) | 0.753015 ± 0.00557059 (W 0.00178796) | · |  |
| `qr_factor/n256/b1` | 4.49031 ± 0.0104857 (W 0.00372278) | 5.22842 ± 0.00307874 (W 0.00986679) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 29.0443 ± 0.0226776 (W 0.0196569) | 35.5128 ± 0.00777747 (W 0.0326216) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.301423 ± 0.000596091 (W 0.00227868) | 0.36719 ± 0.00600192 (W 0.00289196) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.96744 ± 0.00539098 (W 0.00374424) | 2.4464 ± 0.0755056 (W 0.00448979) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 13.9769 ± 0.00380353 (W 0.0216429) | 16.5308 ± 0.00625012 (W 0.0105961) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.73172 ± 0.015789 (W 0.0220883) | 5.49364 ± 0.00879429 (W 0.00718858) | · |  |
| `svd_thin/n256/b1` | 34.0724 ± 0.0208003 (W 0.11072) | 35.7782 ± 0.178373 (W 0.0396489) | · |  |
| `svd_thin/n512/b1` | 211.237 ± 0.0178007 (W 0.374733) | 234.097 ± 2.93858 (W 0.795827) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.46857 ± 0.00062579 (W 0.0120535) | 2.24596 ± 0.0191994 (W 0.00350711) | 🔴 fork 1.54× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.1295 ± 0.0294135 (W 0.0290516) | 15.6879 ± 0.0549698 (W 0.0305703) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 111.582 ± 0.00431759 (W 0.295482) | 98.9412 ± 2.29899 (W 0.0944869) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0074185 ± 0.000304763 (W 2.74447e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0240895 ± 0.00183494 (W 8.03388e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.08862 ± 0.0016221 (W 0.00131594) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.17637 ± 0.00185616 (W 0.00405607) | 0.127458 ± 0.00586616 (W 0.00464459) | 🔴 fork 1.38× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.759386 ± 0.00761059 (W 0.0126025) | 0.592415 ± 0.00208102 (W 0.00348329) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.01299 ± 0.00381767 (W 0.037001) | 3.53886 ± 0.0602257 (W 0.0106402) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.97361 ± 0.023966 (W 0.0177926) | 2.54147 ± 0.0143232 (W 0.00193126) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 11.3723 ± 0.00577989 (W 0.0759157) | 11.3377 ± 0.0179223 (W 0.202979) | · |  |
| `eigh/n512/b1` | 46.3731 ± 0.0845191 (W 0.0513052) | 52.8242 ± 0.159208 (W 0.037158) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.746267 ± 0.00315016 (W 0.00368927) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.7828 ± 0.0119713 (W 0.0200677) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.3472 ± 0.0905535 (W 0.0780778) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.295843 ± 0.000707814 (W 0.00352128) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.296153 ± 0.00298823 (W 0.00284553) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92473 ± 0.0010451 (W 0.00525022) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93819 ± 0.0168631 (W 0.428682) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.8482 ± 0.00969019 (W 0.272125) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8232 ± 0.019531 (W 0.0360155) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.305094 ± 0.000206475 (W 0.00193744) | 0.239277 ± 0.00198485 (W 0.00148382) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 2.05772 ± 0.0113045 (W 0.0114897) | 1.26573 ± 0.00574878 (W 0.00276897) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 7.38837 ± 0.0509591 (W 0.0293714) | 5.50627 ± 0.0338775 (W 0.00642549) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.997272 ± 0.00164119 (W 0.00484033) | 1.37088 ± 0.0184647 (W 0.00371882) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 4.46366 ± 0.0286018 (W 0.0165829) | 6.57356 ± 0.0058209 (W 0.00732383) | 🔵 fork 1.47× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 22.4662 ± 0.0970066 (W 0.101501) | 32.4774 ± 0.159272 (W 0.0271615) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.562003 ± 0.00740412 (W 0.0182495) | 0.665322 ± 0.000553665 (W 0.0019367) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.77525 ± 0.00879146 (W 0.0519879) | 3.09617 ± 0.0131274 (W 0.00482647) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 11.3114 ± 0.0258073 (W 0.0591556) | 15.2403 ± 0.00609597 (W 0.0192587) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.303531 ± 0.00162281 (W 0.00210443) | 0.239982 ± 0.00102743 (W 0.00131493) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.99563 ± 0.0130016 (W 0.0109531) | 1.25825 ± 0.00329795 (W 0.00300372) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 7.38632 ± 0.00338846 (W 0.0287121) | 5.53056 ± 0.0512412 (W 0.0131009) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.35898 ± 0.0105451 (W 0.0301909) | 4.6755 ± 0.0108647 (W 0.0058206) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 22.4388 ± 0.042763 (W 0.0742404) | 22.4609 ± 0.0746981 (W 0.067341) | · |  |
| `svd_thin/n512/b1` | 94.1641 ± 0.116991 (W 0.29427) | 114.532 ± 0.771741 (W 0.236545) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.01907 ± 0.00039598 (W 0.0198252) | 2.4015 ± 0.0088756 (W 0.00446977) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.0907 ± 0.0366904 (W 0.0636229) | 11.6199 ± 0.00926593 (W 0.0174779) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 64.3755 ± 0.0920915 (W 0.197231) | 51.834 ± 0.126228 (W 0.045748) | 🔴 fork 1.24× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007735 ± 0.0008358 (W 3.17678e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.020458 ± 0 (W 0.000673469) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.081422 ± 0.00553947 (W 0.00200869) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.180803 ± 0.00138239 (W 0.00402053) | 0.157514 ± 0.00144533 (W 0.00202618) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.75259 ± 0.00851003 (W 0.0191779) | 0.548378 ± 0.00119642 (W 0.00245788) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.42892 ± 0.00648417 (W 0.0261207) | 2.46112 ± 0.00473479 (W 0.00702167) | · |  |
| `eigh/n128/b1` | 2.93253 ± 0.0340953 (W 0.0200622) | 2.43967 ± 0.000996313 (W 0.00267699) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 10.8063 ± 0.0371019 (W 0.0366018) | 10.169 ± 0.0328451 (W 0.0131035) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 38.9176 ± 0.118913 (W 0.145256) | 40.4641 ± 0.0285056 (W 0.040411) | · |  |
| `full_piv_lu/n128/b1` | 0.749999 ± 0.00180171 (W 0.00544183) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.7833 ± 0.024159 (W 0.0157718) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.5802 ± 0.0149687 (W 0.0850703) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.194387 ± 0.0018208 (W 0.00113613) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.197889 ± 0.00300238 (W 0.00355296) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01796 ± 0.00139441 (W 0.00916276) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.02185 ± 0.00139441 (W 0.00349358) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.26282 ± 0.125008 (W 0.0354932) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.19174 ± 0.00795424 (W 0.026368) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.304678 ± 0.00276267 (W 0.00235362) | 0.227434 ± 0.000439113 (W 0.00226899) | 🔴 fork 1.34× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 2.05386 ± 0.0043381 (W 0.00495947) | 0.893306 ± 0.00246356 (W 0.00347501) | 🔴 fork 2.30× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.33159 ± 0.0109177 (W 0.0299081) | 3.23414 ± 0.00447811 (W 0.00603461) | 🔴 fork 1.96× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.965671 ± 0.0115174 (W 0.0225677) | 1.35686 ± 0.0144469 (W 0.172786) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.32842 ± 0.053685 (W 0.0376125) | 5.98233 ± 0.00675711 (W 0.0155054) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 15.103 ± 0.0406841 (W 0.0358442) | 25.8904 ± 0.0503205 (W 0.0438775) | 🔵 fork 1.71× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.559524 ± 0.00267852 (W 0.00272856) | 0.652317 ± 0.00239568 (W 0.00284998) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.30744 ± 0.0123602 (W 0.0187136) | 2.7907 ± 0.00843932 (W 0.00574854) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.74179 ± 0.00705268 (W 0.0335233) | 12.0363 ± 0.105671 (W 0.0326362) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.300746 ± 0.00053033 (W 0.00176878) | 0.227971 ± 0.00223092 (W 0.00208736) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.99513 ± 0.00985848 (W 0.0150462) | 0.902199 ± 0.00966827 (W 0.00300659) | 🔴 fork 2.21× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 6.31306 ± 0.0156865 (W 0.0169741) | 3.34342 ± 0.00256538 (W 0.0117235) | 🔴 fork 1.89× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 4.21866 ± 0.00948089 (W 0.0262535) | 4.6085 ± 0.00184343 (W 0.012454) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 21.1866 ± 0.00532239 (W 0.0666642) | 20.8196 ± 0.0074621 (W 0.0298889) | · |  |
| `svd_thin/n512/b1` | 79.4332 ± 0.0502887 (W 0.266107) | 95.4356 ± 0.471741 (W 0.346931) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.04617 ± 0.0375764 (W 0.0134325) | 2.48831 ± 0.00395556 (W 0.00379642) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 17.0497 ± 0.0615006 (W 0.0815428) | 11.4946 ± 0.0308716 (W 0.0188054) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 60.8146 ± 0.735117 (W 0.315785) | 45.99 ± 0.0970447 (W 0.0567765) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0074685 ± 0.0004179 (W 2.93079e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0217055 ± 0.00180666 (W 5.9733e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.082289 ± 0.00641063 (W 0.00279465) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.824377 ± 0.0113469 (W 0.00242497) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.2077 ± 0.545641 (W 0.286398) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.552396 ± 0.00102601 (W 0.00217894) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554925 ± 0.000934088 (W 0.00174966) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1976 ± 0.0404769 (W 0.210809) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.2196 ± 0.182856 (W 0.408627) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.478067 ± 0.00512087 (W 0.0042919) | 0.732161 ± 0.147177 (W 0.00317402) | 🔵 fork 1.53× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.4454 ± 0.000574171 (W 0.0817349) | 28.0567 ± 0.0605757 (W 0.054176) | 🔵 fork 1.82× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.58198 ± 0.012904 (W 0.00677086) | 2.5044 ± 0.00585414 (W 0.00672216) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 71.0351 ± 0.0845516 (W 0.248794) | 106.418 ± 0.272422 (W 1.41602) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.0398 ± 0.00424547 (W 0.00328263) | 1.27089 ± 0.000497803 (W 0.00364517) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 31.8294 ± 0.616135 (W 0.255745) | 51.5727 ± 1.66337 (W 0.0406415) | 🔵 fork 1.62× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.51337 ± 0.00105925 (W 0.00497528) | 3.76732 ± 0.00999637 (W 0.00886508) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 88.5275 ± 0.101649 (W 0.0910031) | 147.706 ± 1.8631 (W 1.5338) | 🔵 fork 1.67× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.49846 ± 0.00961807 (W 0.00540318) | 1.93329 ± 0.00414152 (W 0.216618) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 44.8197 ± 0.110706 (W 0.0426321) | 70.0446 ± 4.83261 (W 0.786782) | 🔵 fork 1.56× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.810828 ± 2.19203e-05 (W 0.00135786) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.7746 ± 0.14588 (W 0.267338) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.184569 ± 0.00346482 (W 0.00876967) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.186217 ± 0.0042787 (W 0.00966254) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.2138 ± 0.0849907 (W 0.0929365) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.295 ± 0.000673873 (W 0.0920688) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.50165 ± 0.0101392 (W 0.0114631) | 0.682172 ± 0.168408 (W 0.00262381) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.43554 ± 0.0689507 (W 0.086336) | 22.1314 ± 0.213936 (W 0.361001) | 🔵 fork 2.35× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.2486 ± 0.00205627 (W 0.020094) | 2.58909 ± 0.0038502 (W 0.004626) | 🔵 fork 2.07× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 28.2896 ± 0.141547 (W 0.190144) | 67.7039 ± 0.546467 (W 0.576715) | 🔵 fork 2.39× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.02012 ± 0.00363948 (W 0.00485307) | 1.32734 ± 0.0141626 (W 0.00270452) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 15.9035 ± 0.168706 (W 0.213748) | 33.6346 ± 0.897652 (W 0.578314) | 🔵 fork 2.11× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.34535 ± 0.00287934 (W 0.0212255) | 3.64068 ± 0.0336335 (W 0.00831716) | 🔵 fork 1.55× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 46.5098 ± 0.113199 (W 0.148578) | 85.3903 ± 2.87014 (W 0.39905) | 🔵 fork 1.84× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.66029 ± 0.00761342 (W 0.034499) | 1.98431 ± 0.00742745 (W 0.00389444) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 31.1602 ± 0.100484 (W 0.0771308) | 48.0616 ± 0.640993 (W 0.458184) | 🔵 fork 1.54× faster than `lapack-openblas` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.821141 ± 0.00167231 (W 0.00317039) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.6634 ± 0.0186287 (W 0.20239) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.157859 ± 0.00303914 (W 0.00159486) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.184088 ± 0.0448079 (W 0.00273567) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.5534 ± 0.0572551 (W 0.0457379) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.67328 ± 0.12136 (W 0.0585943) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.48026 ± 0.00179252 (W 0.00394927) | 0.657617 ± 0.156407 (W 0.00795525) | 🔵 fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.79021 ± 0.319256 (W 0.0519663) | 20.1042 ± 0.452433 (W 0.499079) | 🔵 fork 2.29× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.42781 ± 0.014145 (W 0.0312603) | 2.58542 ± 0.0226104 (W 0.00979951) | 🔵 fork 1.81× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 22.2413 ± 0.0861765 (W 0.16079) | 62.0494 ± 3.27303 (W 1.1877) | 🔵 fork 2.79× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.10704 ± 0.00372504 (W 0.0116384) | 1.33213 ± 0.0114219 (W 0.00589718) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 12.9395 ± 0.0198138 (W 0.0662563) | 30.4301 ± 2.36862 (W 0.137218) | 🔵 fork 2.35× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/1024x64/b1` | 2.52173 ± 0.017375 (W 0.0207002) | 3.62355 ± 0.0565 (W 0.0154765) | 🔵 fork 1.44× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 40.4525 ± 0.103899 (W 0.147731) | 77.125 ± 0.827499 (W 0.249053) | 🔵 fork 1.91× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.78843 ± 0.00203859 (W 0.0252633) | 1.9942 ± 0.00408496 (W 0.00870887) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 29.9889 ± 0.60943 (W 0.275798) | 46.0955 ± 1.00238 (W 0.632273) | 🔵 fork 1.54× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730898 ± 0.00323572 (W 0.00196313) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.3421 ± 0.624939 (W 0.0971122) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.584931 ± 0.0153584 (W 0.00450866) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.596948 ± 0.00242891 (W 0.00254157) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.9501 ± 0.0481052 (W 0.0581356) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.9333 ± 0.153287 (W 0.0721991) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.387999 ± 0.0012834 (W 0.00229188) | 0.321175 ± 0.0200698 (W 0.00181624) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 13.2647 ± 0.084611 (W 0.0403271) | 13.3169 ± 0.268511 (W 0.0367649) | · |  |
| `qr/1024x64/b1` | 1.46637 ± 0.0107714 (W 0.00292979) | 1.87833 ± 0.00401354 (W 0.00220983) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 68.6465 ± 0.155358 (W 0.124966) | 77.1838 ± 0.398873 (W 0.401223) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.774986 ± 0.00327108 (W 0.00299152) | 0.976953 ± 0.0182087 (W 0.00135017) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 25.8261 ± 0.0865944 (W 0.0330503) | 38.7271 ± 0.144705 (W 0.243456) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.45629 ± 0.00439679 (W 0.00345343) | 3.25273 ± 0.00784747 (W 0.00373396) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 83.2837 ± 0.300819 (W 0.209484) | 120.671 ± 0.220711 (W 0.311612) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.40155 ± 0.00672812 (W 0.00276997) | 1.61174 ± 0.00220052 (W 0.00448167) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 39.0639 ± 0.054957 (W 0.238277) | 54.4378 ± 0.310133 (W 0.086761) | 🔵 fork 1.39× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731299 ± 0.00308086 (W 0.00358469) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6738 ± 0.0402853 (W 0.113028) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.187966 ± 0.000119501 (W 0.00164433) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.198756 ± 0.000473762 (W 0.00390049) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.1593 ± 0.0300294 (W 0.0387088) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.1376 ± 0.112384 (W 0.0345496) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.411463 ± 0.00223163 (W 0.00867765) | 0.251765 ± 0.0019205 (W 0.00203557) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 7.33424 ± 0.0185014 (W 0.0597707) | 7.1941 ± 0.0128474 (W 0.00605362) | · |  |
| `qr/1024x64/b1` | 1.17134 ± 0.00413587 (W 0.00977483) | 1.99729 ± 0.0358793 (W 0.00437772) | 🔵 fork 1.71× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 25.8528 ± 0.226973 (W 0.234557) | 41.4577 ± 1.13245 (W 0.0301219) | 🔵 fork 1.60× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.887636 ± 0.00402273 (W 0.00387595) | 1.028 ± 0.00415991 (W 0.00310923) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 13.4786 ± 0.0280728 (W 0.208264) | 20.495 ± 0.287388 (W 0.0255369) | 🔵 fork 1.52× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.28858 ± 0.00877449 (W 0.0214321) | 3.09631 ± 0.024835 (W 0.0022488) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 40.7488 ± 0.0981415 (W 0.466567) | 67.1152 ± 1.19645 (W 0.0448702) | 🔵 fork 1.65× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.54983 ± 0.00883954 (W 0.0243827) | 1.70649 ± 0.0167068 (W 0.00443933) | 🔵 fork 1.10× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 25.623 ± 0.0484418 (W 0.196421) | 36.0383 ± 0.827014 (W 0.0850355) | 🔵 fork 1.41× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.732011 ± 0.00295359 (W 0.00168751) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.7563 ± 0.00344785 (W 0.0958373) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.164522 ± 0.00209021 (W 0.00319013) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.163861 ± 0.000857013 (W 0.00407902) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.58559 ± 0.346465 (W 0.109335) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.89563 ± 0.00436992 (W 0.0742137) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.395673 ± 0.000941866 (W 0.00302963) | 0.234293 ± 0.000276479 (W 0.00171988) | 🔴 fork 1.69× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 6.67083 ± 0.030873 (W 0.0482891) | 4.72721 ± 0.00592414 (W 0.00445799) | 🔴 fork 1.41× slower than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.32588 ± 0.00680237 (W 0.0155784) | 1.98015 ± 0.00178757 (W 0.00273115) | 🔵 fork 1.49× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 19.9586 ± 0.0243429 (W 0.0712298) | 36.7682 ± 0.389662 (W 0.146083) | 🔵 fork 1.84× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.03511 ± 0.0145996 (W 0.0110918) | 1.02671 ± 0.00549846 (W 0.00368513) | · |  |
| `qr_factor/4096x256/b1` | 11.6107 ± 0.0441631 (W 0.0477604) | 18.1022 ± 0.159837 (W 0.0522487) | 🔵 fork 1.56× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.47397 ± 0.0339737 (W 0.0184144) | 3.0601 ± 0.0048062 (W 0.00543549) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 35.1151 ± 0.177967 (W 0.16952) | 59.7369 ± 0.890707 (W 0.0872714) | 🔵 fork 1.70× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.68528 ± 0.0129761 (W 0.0161048) | 1.69463 ± 0.00772797 (W 0.00182419) | · |  |
| `svd_values/4096x256/b1` | 24.1332 ± 0.122039 (W 0.203966) | 33.6556 ± 0.0447924 (W 0.138683) | 🔵 fork 1.39× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77934 ± 0.00127845 (W 0.00315794) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 150.081 ± 0.469176 (W 0.688622) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19451 ± 0.00604647 (W 0.00394756) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.19974 ± 0.00326966 (W 0.00353465) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.878 ± 1.3435e-05 (W 0.2168) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.922 ± 0.166374 (W 0.182237) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.03803 ± 0.00221254 (W 0.00215107) | 1.30223 ± 0.0080596 (W 0.00209373) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 47.3667 ± 0.113518 (W 0.0867121) | 69.1462 ± 6.24086 (W 0.61453) | 🔵 fork 1.46× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 4.72712 ± 0.00540583 (W 0.00367543) | 4.32063 ± 0.0541029 (W 0.0123529) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 245.269 ± 7.20657 (W 0.25719) | 264.506 ± 5.8874 (W 1.50704) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.59557 ± 0.0380897 (W 0.00590308) | 2.20995 ± 0.00868186 (W 0.00452724) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 100.701 ± 0.104411 (W 0.309202) | 130.724 ± 1.07226 (W 1.37123) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.98899 ± 0.00954099 (W 0.0115203) | 6.94114 ± 0.00907854 (W 0.0162931) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 281.437 ± 0.239979 (W 1.70568) | 384.7 ± 2.45088 (W 1.46621) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 3.0669 ± 0.000521845 (W 0.00689386) | 3.13692 ± 0.027114 (W 0.00590556) | · |  |
| `svd_values/4096x256/b1` | 122.757 ± 0.432152 (W 0.302475) | 154.697 ± 1.42112 (W 0.606126) | 🔵 fork 1.26× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78602 ± 0.00202303 (W 0.00256264) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.2356 ± 0.0479708 (W 0.551936) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.622331 ± 0.00559534 (W 0.00987226) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.628382 ± 0.0146074 (W 0.0103806) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.2297 ± 0.00366211 (W 0.28501) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.166 ± 0.00555291 (W 0.26211) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.905779 ± 0.0175815 (W 0.0173439) | 1.00893 ± 0.00134492 (W 0.0024017) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 23.2582 ± 0.380928 (W 0.16865) | 41.939 ± 0.0493186 (W 0.113095) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 2.73379 ± 0.133739 (W 0.103312) | 2.26671 ± 0.0270589 (W 0.00788538) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 83.8836 ± 0.312128 (W 0.281552) | 111.873 ± 2.62744 (W 2.53161) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.06797 ± 0.00375898 (W 0.0843034) | 1.12696 ± 0.00488328 (W 0.00226972) | 🔴 fork 1.84× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 40.3956 ± 0.0932978 (W 0.0564688) | 56.8062 ± 0.46178 (W 1.07907) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 4.11773 ± 0.0780137 (W 0.101285) | 3.71547 ± 0.0077909 (W 0.00820197) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 115.417 ± 0.0956822 (W 0.408277) | 149.14 ± 1.68216 (W 1.17095) | 🔵 fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.66552 ± 0.0321585 (W 0.0684343) | 2.08184 ± 0.0346518 (W 0.00445276) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 66.9176 ± 0.162119 (W 0.236955) | 76.6676 ± 0.309554 (W 0.466085) | 🔵 fork 1.15× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.7767 ± 0.00241336 (W 0.00253364) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 35.2399 ± 0.540326 (W 0.678079) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.421135 ± 0.00180029 (W 0.00576436) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.526812 ± 0.147522 (W 0.500447) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.9174 ± 0.0340889 (W 0.334551) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.055 ± 0.359881 (W 0.343392) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.894013 ± 0.0152961 (W 0.0115613) | 0.935836 ± 0.00991717 (W 0.00341456) | · |  |
| `lu/4096x256/b1` | 19.3385 ± 0.226335 (W 0.0517755) | 40.5432 ± 0.04067 (W 0.255924) | 🔵 fork 2.10× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 2.48353 ± 0.0030349 (W 0.0267107) | 1.96457 ± 0.00496813 (W 0.00627915) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 63.2148 ± 7.63431 (W 0.356426) | 84.7815 ± 0.213994 (W 0.981743) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.85489 ± 0.00314733 (W 0.0131758) | 1.0062 ± 0.018843 (W 0.0022568) | 🔴 fork 1.84× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 30.6035 ± 0.104653 (W 0.150329) | 42.4884 ± 0.0773306 (W 0.226348) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.8814 ± 0.0251673 (W 0.0147959) | 3.2897 ± 0.0776891 (W 0.0101846) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 88.7525 ± 0.226348 (W 0.523493) | 111.213 ± 0.339333 (W 0.691989) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.6666 ± 0.00743452 (W 0.0225246) | 1.97207 ± 0.00556352 (W 0.011159) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 58.6148 ± 0.149845 (W 1.84594) | 61.9055 ± 0.744124 (W 0.390066) | 🔵 fork 1.06× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6661 ± 0.00652942 (W 0.00583751) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 144.402 ± 0.717211 (W 0.938731) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26363 ± 0.00656407 (W 0.0025898) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.27027 ± 0.0123447 (W 0.00319472) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.713 ± 0.133071 (W 0.202908) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.864 ± 0.0532303 (W 0.284557) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.916049 ± 0.00211284 (W 0.00241071) | 0.943671 ± 0.0152297 (W 0.00333098) | · |  |
| `lu/4096x256/b1` | 42.0808 ± 0.0269493 (W 0.0453654) | 47.2546 ± 0.161514 (W 0.0761928) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 4.60399 ± 0.00433598 (W 0.00468612) | 3.54957 ± 0.00337997 (W 0.00519154) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 239.557 ± 6.77513 (W 0.384897) | 223.446 ± 0.343223 (W 0.680404) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.24284 ± 0.0744951 (W 0.00434858) | 1.81927 ± 0.000788424 (W 0.00348131) | 🔴 fork 1.23× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 90.1225 ± 0.0129888 (W 0.0398155) | 111.95 ± 0.0884315 (W 0.261652) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.88852 ± 0.000178898 (W 0.0123917) | 6.23769 ± 0.00118087 (W 0.0107768) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 269.041 ± 0.00946321 (W 0.432361) | 353.827 ± 7.08589 (W 0.726128) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.95163 ± 0.00556564 (W 0.00592485) | 2.74751 ± 0.000675994 (W 0.00292138) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 110.491 ± 0.0213539 (W 0.185202) | 137.562 ± 0.166959 (W 0.501799) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.67443 ± 0.00358927 (W 0.00335732) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.0253 ± 0.107296 (W 0.585435) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.652381 ± 0.010422 (W 0.0096163) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.647172 ± 0.00271246 (W 0.00563206) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.2797 ± 0.0367498 (W 0.0645836) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.304 ± 0.0889109 (W 0.0490866) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.799942 ± 0.00165887 (W 0.0113612) | 0.686756 ± 0.000603869 (W 0.00257487) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 17.8398 ± 0.000918532 (W 0.0830049) | 24.2313 ± 0.0195854 (W 0.0277685) | 🔵 fork 1.36× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 2.51943 ± 0.0209099 (W 0.0515802) | 1.4609 ± 0.00260852 (W 0.00481918) | 🔴 fork 1.72× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 78.5951 ± 0.307071 (W 0.17021) | 73.4953 ± 0.266005 (W 0.120026) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.73449 ± 0.0109121 (W 0.0275308) | 0.786572 ± 0.00483944 (W 0.0024216) | 🔴 fork 2.21× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 35.867 ± 0.115606 (W 0.265349) | 36.4966 ± 0.208069 (W 0.0281038) | · |  |
| `svd_thin/1024x64/b1` | 3.94212 ± 0.0554393 (W 0.102618) | 3.12593 ± 0.000577706 (W 0.00492776) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 103.4 ± 0.118164 (W 0.378676) | 123.604 ± 0.126288 (W 0.113349) | 🔵 fork 1.20× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.55052 ± 0.00277398 (W 0.0679499) | 1.73044 ± 0.00183636 (W 0.00431467) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 55.2028 ± 0.0199666 (W 0.186334) | 57.0097 ± 0.871124 (W 0.081928) | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66968 ± 0.00266509 (W 0.00496542) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 30.4742 ± 0.378928 (W 0.805552) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.429511 ± 0.00694237 (W 0.016897) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.438207 ± 0.0064474 (W 0.00754815) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.7068 ± 0.317283 (W 1.78057) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.475 ± 0.431206 (W 0.524778) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.768123 ± 0.00456296 (W 0.0093544) | 0.569327 ± 0.00421577 (W 0.00251243) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.9519 ± 0.0141676 (W 0.526749) | 14.6386 ± 0.109971 (W 0.0170475) | · |  |
| `qr/1024x64/b1` | 2.32448 ± 0.00183282 (W 0.0195852) | 1.16976 ± 0.0045467 (W 0.0075054) | 🔴 fork 1.99× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 57.6514 ± 7.3822 (W 0.125187) | 50.3862 ± 0.179281 (W 0.0566512) | 🔴 fork 1.14× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.70036 ± 0.0101505 (W 0.0191296) | 0.639733 ± 0.00195444 (W 0.00244959) | 🔴 fork 2.66× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 27.7045 ± 0.0369096 (W 0.042143) | 24.9662 ± 0.0715606 (W 0.065382) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 3.74041 ± 0.00675499 (W 0.018252) | 2.68634 ± 0.000101823 (W 0.00452651) | 🔴 fork 1.39× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 76.3843 ± 0.339553 (W 0.276599) | 88.5608 ± 0.085386 (W 0.102321) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.54879 ± 0.0163271 (W 0.0175906) | 1.59342 ± 0.00227547 (W 0.00543819) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 46.9596 ± 0.0870915 (W 0.25085) | 45.4466 ± 0.165954 (W 0.0622859) | · |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 77.5189 ± 3.21931 (W 0.303358) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.13443 ± 0.000756604 (W 0.00368593) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.0177 ± 0.155464 (W 0.045202) | 35.6244 ± 0.611673 (W 0.85769) | 🔵 fork 2.22× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.396354 ± 0.0027266 (W 0.00504877) | 1.14634 ± 0.171618 (W 0.00342087) | 🔵 fork 2.89× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 31.1905 ± 0.211834 (W 0.142328) | 73.9754 ± 3.76164 (W 0.823933) | 🔵 fork 2.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.740721 ± 0.00538533 (W 0.00158951) | 1.90543 ± 0.0166326 (W 0.0147143) | 🔵 fork 2.57× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 27.1571 ± 0.370298 (W 0.0274591) | 64.4785 ± 3.24641 (W 0.814953) | 🔵 fork 2.37× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.993467 ± 0.0162005 (W 0.00268763) | 1.75678 ± 0.0573881 (W 0.0304768) | 🔵 fork 1.77× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 83.4518 ± 0.187745 (W 0.192465) | 222.309 ± 4.92297 (W 0.904499) | 🔵 fork 2.66× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.44966 ± 0.00259084 (W 0.00603464) | 4.99215 ± 0.015888 (W 0.0115484) | 🔵 fork 2.04× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 39.1579 ± 0.0560241 (W 0.176051) | 107.134 ± 0.505299 (W 0.506271) | 🔵 fork 2.74× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.41458 ± 0.00266296 (W 0.00300748) | 2.57498 ± 0.0898471 (W 0.0120973) | 🔵 fork 1.82× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.664 ± 0.100138 (W 0.170449) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.14019 ± 0.00715592 (W 0.0039838) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.28923 ± 0.0758103 (W 0.128865) | 26.6299 ± 0.0900281 (W 0.041691) | 🔵 fork 3.65× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.224814 ± 0.000360624 (W 0.00258811) | 0.800082 ± 0.0025074 (W 0.00229282) | 🔵 fork 3.56× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 11.4688 ± 0.151258 (W 0.845378) | 45.4637 ± 0.872621 (W 1.00797) | 🔵 fork 3.96× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.446248 ± 0.0103075 (W 0.00866823) | 1.72182 ± 0.00662206 (W 0.0122335) | 🔵 fork 3.86× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 10.6468 ± 0.0967867 (W 0.0531214) | 41.2256 ± 0.649384 (W 1.0649) | 🔵 fork 3.87× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.66762 ± 0.00659518 (W 0.0085803) | 1.55256 ± 0.00323926 (W 0.00548547) | 🔵 fork 2.33× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 40.858 ± 0.297145 (W 0.232946) | 144.385 ± 1.90477 (W 0.599427) | 🔵 fork 3.53× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.29423 ± 0.0286859 (W 0.0232291) | 4.54381 ± 0.0751117 (W 0.0156539) | 🔵 fork 1.98× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 25.6409 ± 0.0221268 (W 0.227798) | 77.6497 ± 0.801404 (W 0.500168) | 🔵 fork 3.03× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.5587 ± 0.00256326 (W 0.0209832) | 2.45615 ± 0.0170851 (W 0.00783648) | 🔵 fork 1.58× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 33.0002 ± 0.327202 (W 0.133706) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.13826 ± 0.00381272 (W 0.0074593) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.93285 ± 0.0956701 (W 0.0814849) | 24.4103 ± 0.539569 (W 0.333814) | 🔵 fork 4.11× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.213929 ± 0.0088551 (W 0.00543723) | 0.887726 ± 0.189732 (W 0.00472591) | 🔵 fork 4.15× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 8.1554 ± 0.105918 (W 0.1112) | 39.2456 ± 0.362512 (W 0.0928671) | 🔵 fork 4.81× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.392643 ± 0.00545533 (W 0.00482568) | 1.73565 ± 0.00732563 (W 0.0128359) | 🔵 fork 4.42× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 7.6747 ± 0.264642 (W 0.0412091) | 35.3363 ± 0.324918 (W 0.0377356) | 🔵 fork 4.60× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.61098 ± 0.00288995 (W 0.0133635) | 1.55651 ± 0.00817415 (W 0.00699281) | 🔵 fork 2.55× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 34.9046 ± 0.0195374 (W 0.140854) | 135.914 ± 3.90543 (W 1.43399) | 🔵 fork 3.89× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.44831 ± 0.00904885 (W 0.0202899) | 4.58324 ± 0.0668711 (W 0.0303959) | 🔵 fork 1.87× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 24.0466 ± 0.064235 (W 0.0832876) | 71.5724 ± 0.991993 (W 0.276415) | 🔵 fork 2.98× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.69667 ± 0.0230828 (W 0.0374089) | 2.48442 ± 0.0193669 (W 0.00955935) | 🔵 fork 1.46× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 73.2285 ± 2.29402 (W 0.400128) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04872 ± 0.000551543 (W 0.00341401) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2644 ± 0.0457484 (W 0.0197584) | 20.3849 ± 0.147762 (W 0.0485379) | 🔵 fork 1.54× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.312237 ± 0.0032937 (W 0.00208908) | 0.709368 ± 0.00238719 (W 0.00215829) | 🔵 fork 2.27× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 28.0602 ± 0.138374 (W 0.12889) | 74.5664 ± 1.40293 (W 0.526711) | 🔵 fork 2.66× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.626128 ± 0.00128976 (W 0.00237793) | 1.69095 ± 0.000929845 (W 0.0094962) | 🔵 fork 2.70× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 24.9774 ± 0.244544 (W 0.0896129) | 54.9876 ± 3.87877 (W 0.595302) | 🔵 fork 2.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.560836 ± 0.00640497 (W 0.00238197) | 1.4102 ± 0.0253766 (W 0.00555409) | 🔵 fork 2.51× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 88.6153 ± 0.401 (W 0.0739433) | 198.267 ± 4.60359 (W 0.700799) | 🔵 fork 2.24× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.51715 ± 0.00386575 (W 0.00397874) | 4.57147 ± 0.00273792 (W 0.0206988) | 🔵 fork 1.82× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 45.0114 ± 0.0114474 (W 0.0559696) | 93.9848 ± 3.52773 (W 0.461808) | 🔵 fork 2.09× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.48065 ± 0.0111002 (W 0.00499606) | 2.26856 ± 0.0538384 (W 0.00665082) | 🔵 fork 1.53× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.0175 ± 0.0896244 (W 0.1456) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04771 ± 0.000468812 (W 0.00593497) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.37415 ± 0.0217881 (W 0.0318211) | 12.4772 ± 0.163274 (W 0.124848) | 🔵 fork 2.85× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.138834 ± 0.000644881 (W 0.00237388) | 0.490885 ± 0.00340189 (W 0.00110198) | 🔵 fork 3.54× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 8.25687 ± 0.00135411 (W 0.118218) | 43.4434 ± 1.93085 (W 0.583608) | 🔵 fork 5.26× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.328693 ± 0.000354968 (W 0.00749459) | 1.46246 ± 0.00266509 (W 0.00381415) | 🔵 fork 4.45× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 7.12179 ± 0.004348 (W 0.0285234) | 30.071 ± 0.946107 (W 0.353017) | 🔵 fork 4.22× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.245834 ± 0.0154651 (W 0.00282903) | 1.23424 ± 0.00232992 (W 0.00304058) | 🔵 fork 5.02× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 47.3779 ± 1.17046 (W 0.386228) | 127.628 ± 0.733262 (W 0.502801) | 🔵 fork 2.69× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.37256 ± 0.00867974 (W 0.0201513) | 4.01182 ± 0.0303045 (W 0.010827) | 🔵 fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 31.3097 ± 0.0231775 (W 0.174214) | 66.0246 ± 1.30783 (W 0.147691) | 🔵 fork 2.11× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.61841 ± 0.0157261 (W 0.0228845) | 2.16163 ± 0.0211877 (W 0.0127581) | 🔵 fork 1.34× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.1557 ± 0.0485613 (W 0.192737) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04262 ± 0.00952049 (W 0.00452875) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.92692 ± 0.0223849 (W 0.0467086) | 10.1005 ± 0.355262 (W 0.352822) | 🔵 fork 3.45× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.117824 ± 0.000730441 (W 0.00259868) | 0.453731 ± 4.94975e-05 (W 0.00163522) | 🔵 fork 3.85× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 5.10882 ± 0.0845756 (W 0.0235364) | 39.6644 ± 1.58753 (W 0.0545809) | 🔵 fork 7.76× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.271747 ± 0.00587959 (W 0.00299833) | 1.47738 ± 0.0112076 (W 0.00375682) | 🔵 fork 5.44× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 4.25375 ± 0.0328614 (W 0.0343698) | 25.2211 ± 0.142007 (W 0.0885226) | 🔵 fork 5.93× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.197459 ± 0.00425042 (W 0.00302297) | 1.24368 ± 0.00163695 (W 0.00226261) | 🔵 fork 6.30× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 40.6633 ± 0.0056017 (W 0.484732) | 118.763 ± 1.32008 (W 0.303046) | 🔵 fork 2.92× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.51107 ± 0.0063774 (W 0.0225973) | 4.05413 ± 0.00653437 (W 0.0087262) | 🔵 fork 1.61× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 29.7192 ± 0.0781098 (W 0.0677047) | 61.2664 ± 1.11393 (W 0.336176) | 🔵 fork 2.06× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.73404 ± 0.0135729 (W 0.0186739) | 2.16392 ± 0.010741 (W 0.00845571) | 🔵 fork 1.25× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 236.165 ± 10.8342 (W 3.47563) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.40061 ± 0.0162847 (W 0.0116233) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.076 ± 0.0450583 (W 0.0838275) | 82.5507 ± 0.21575 (W 0.150628) | 🔵 fork 1.79× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 1.00432 ± 0.0135298 (W 0.00236615) | 1.624 ± 0.0084577 (W 0.00222705) | 🔵 fork 1.62× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 107.341 ± 0.401905 (W 0.269933) | 185.522 ± 5.29438 (W 1.99438) | 🔵 fork 1.73× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.53538 ± 0.00516966 (W 0.00643661) | 3.60486 ± 0.0136903 (W 0.00598472) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 97.0818 ± 0.305353 (W 0.322994) | 166.74 ± 7.18773 (W 1.98148) | 🔵 fork 1.72× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.58331 ± 0.00473691 (W 0.00438831) | 3.36869 ± 0.0430416 (W 0.00442609) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 270.088 ± 0.0710027 (W 3.10497) | 694.637 ± 9.53524 (W 4.3856) | 🔵 fork 2.57× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 5.94123 ± 0.0227526 (W 0.0064477) | 12.0006 ± 0.0846117 (W 0.0284756) | 🔵 fork 2.02× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 110.242 ± 0.0384185 (W 0.0815497) | 310.501 ± 6.29656 (W 1.03656) | 🔵 fork 2.82× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.9523 ± 0.0213546 (W 0.00184826) | 5.66764 ± 0.0450795 (W 0.212197) | 🔵 fork 1.92× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 95.0185 ± 4.37478 (W 0.476931) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.47839 ± 0.0202381 (W 0.00799369) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.4025 ± 0.122932 (W 0.119188) | 52.2354 ± 6.48259 (W 0.0647747) | 🔵 fork 3.00× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.434932 ± 0.00264953 (W 0.00371251) | 1.1769 ± 0.0236541 (W 0.00245562) | 🔵 fork 2.71× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 33.32 ± 0.355343 (W 0.228729) | 77.3342 ± 0.54965 (W 0.150489) | 🔵 fork 2.32× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.994098 ± 0.0226479 (W 0.00790427) | 1.63542 ± 0.0309571 (W 0.00399431) | 🔵 fork 1.65× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 28.1868 ± 0.0275856 (W 0.203217) | 70.3354 ± 0.493824 (W 0.147382) | 🔵 fork 2.50× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 1.05458 ± 0.035209 (W 0.0155906) | 1.3714 ± 0.0398214 (W 0.00333368) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 103.783 ± 0.178709 (W 0.239016) | 437.445 ± 10.7418 (W 1.90211) | 🔵 fork 4.22× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.99649 ± 0.111474 (W 0.0664858) | 9.70972 ± 0.00286237 (W 0.254133) | 🔵 fork 2.43× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 55.1681 ± 0.0054023 (W 0.110547) | 220.993 ± 8.95961 (W 0.457711) | 🔵 fork 4.01× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.66451 ± 0.00650821 (W 0.0820892) | 5.0707 ± 0.101386 (W 0.0212682) | 🔵 fork 1.90× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 69.7687 ± 1.00169 (W 0.59373) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.35623 ± 0.0599061 (W 0.0145088) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 12.7718 ± 0.131662 (W 0.09403) | 49.9003 ± 0.228272 (W 2.10433) | 🔵 fork 3.91× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.353414 ± 0.00129683 (W 0.00642124) | 1.03091 ± 0.0487345 (W 0.00134546) | 🔵 fork 2.92× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 20.8298 ± 0.0275567 (W 0.20629) | 61.2045 ± 0.246117 (W 2.51354) | 🔵 fork 2.94× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.745526 ± 0.00293944 (W 0.00552698) | 1.40365 ± 0.0171233 (W 0.0125862) | 🔵 fork 1.88× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 16.993 ± 0.00771736 (W 0.144197) | 56.2371 ± 0.897827 (W 0.725307) | 🔵 fork 3.31× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.79361 ± 0.0126388 (W 0.00419601) | 1.09026 ± 0.0181154 (W 0.00336604) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 77.0221 ± 0.119083 (W 0.158002) | 390.497 ± 0.935379 (W 4.03264) | 🔵 fork 5.07× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 3.73769 ± 0.0128602 (W 0.0205763) | 9.73703 ± 0.0259628 (W 0.0980339) | 🔵 fork 2.61× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 47.2357 ± 0.0608607 (W 0.0972945) | 204.291 ± 0.956848 (W 2.46194) | 🔵 fork 4.32× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.52735 ± 0.00735886 (W 0.0138265) | 5.08602 ± 0.0213631 (W 0.0228125) | 🔵 fork 2.01× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 226.702 ± 8.41303 (W 1.22855) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.29987 ± 0.000767211 (W 0.00986327) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.2134 ± 0.0839293 (W 0.213442) | 56.0173 ± 0.164802 (W 0.0353574) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.896337 ± 0.00420021 (W 0.00386543) | 1.27562 ± 0.00325764 (W 0.00772338) | 🔵 fork 1.42× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 103.423 ± 0.154503 (W 0.267198) | 184.164 ± 0.893533 (W 1.89103) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.41514 ± 0.00587818 (W 0.00515424) | 3.73663 ± 0.0415461 (W 0.0118007) | 🔵 fork 1.55× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 95.9601 ± 0.396874 (W 0.337197) | 146.519 ± 0.587066 (W 1.22207) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.23553 ± 0.00459902 (W 0.00545184) | 2.94326 ± 0.0713018 (W 0.00956119) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 282.471 ± 0.394842 (W 0.214263) | 655.352 ± 4.5622 (W 1.75818) | 🔵 fork 2.32× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 6.05056 ± 0.028116 (W 0.00607718) | 11.3625 ± 0.106574 (W 0.0229594) | 🔵 fork 1.88× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 123.704 ± 1.59721 (W 0.118982) | 286.974 ± 0.72379 (W 1.47818) | 🔵 fork 2.32× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 3.07714 ± 0.0197106 (W 0.00485156) | 5.29901 ± 0.124608 (W 0.0109596) | 🔵 fork 1.72× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 91.853 ± 2.80132 (W 0.370131) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.33713 ± 0.0282503 (W 0.00569569) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.4973 ± 0.0733114 (W 0.0971508) | 30.4885 ± 0.0496743 (W 0.0315551) | 🔵 fork 2.26× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.323243 ± 0.00402344 (W 0.00284138) | 0.796867 ± 0.00106137 (W 0.00126607) | 🔵 fork 2.47× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 29.155 ± 0.38503 (W 0.112367) | 76.3053 ± 2.87408 (W 0.406049) | 🔵 fork 2.62× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.900309 ± 0.00939462 (W 0.00926324) | 1.43404 ± 0.11485 (W 0.0307224) | 🔵 fork 1.59× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 26.07 ± 0.373155 (W 0.052713) | 53.6677 ± 0.974872 (W 0.258945) | 🔵 fork 2.06× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.714006 ± 0.0158767 (W 0.00741576) | 0.990292 ± 0.00520713 (W 0.00222335) | 🔵 fork 1.39× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 116.05 ± 0.206562 (W 0.432975) | 404.132 ± 0.687507 (W 0.665507) | 🔵 fork 3.48× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.10189 ± 0.0344552 (W 0.110727) | 9.14371 ± 0.0590547 (W 0.0202313) | 🔵 fork 2.23× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 67.0681 ± 0.253556 (W 0.610608) | 203.536 ± 0.777763 (W 0.439357) | 🔵 fork 3.03× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.6464 ± 0.001323 (W 0.0582698) | 4.65296 ± 0.00834952 (W 0.0161557) | 🔵 fork 1.76× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 65.1342 ± 0.945876 (W 0.344877) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.24392 ± 0.0927208 (W 0.00905426) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 8.67975 ± 0.00913653 (W 0.0513706) | 23.6671 ± 0.000241123 (W 0.0205453) | 🔵 fork 2.73× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.242051 ± 0.000793374 (W 0.00352452) | 0.678856 ± 0.00602243 (W 0.00322125) | 🔵 fork 2.80× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 16.5607 ± 0.0359076 (W 0.224866) | 56.8789 ± 0.297008 (W 0.174188) | 🔵 fork 3.43× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.642262 ± 0.00449932 (W 0.00423877) | 1.28747 ± 0.00765231 (W 0.0446412) | 🔵 fork 2.00× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 14.2527 ± 0.121504 (W 0.0599264) | 38.3769 ± 0.118927 (W 0.0532754) | 🔵 fork 2.69× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.480075 ± 0.0214649 (W 0.0120224) | 0.729019 ± 0.00869953 (W 0.00212942) | 🔵 fork 1.52× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 89.6533 ± 0.156913 (W 6.30672) | 369.228 ± 14.025 (W 1.20904) | 🔵 fork 4.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 3.87815 ± 0.00186818 (W 0.0292056) | 9.25358 ± 0.00464569 (W 0.0144965) | 🔵 fork 2.39× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 58.6384 ± 0.160458 (W 0.0907372) | 185.827 ± 1.41595 (W 0.624835) | 🔵 fork 3.17× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.6217 ± 0.0145848 (W 0.0216976) | 4.70669 ± 0.0422185 (W 0.0068058) | 🔵 fork 1.80× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
