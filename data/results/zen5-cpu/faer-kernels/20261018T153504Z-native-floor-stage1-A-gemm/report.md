# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `b7715c53ba75946d68a97d5655f481b198332447`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `651807301c4fd0d485a66038346388dffe289073`
- toolkit commit: `9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5`
- measured binary SHA-256: `2decf425848a5b0706f9c20de65084822a23d659071b38b6bf7c9dea9d347e4a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T15:39:54.433001Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families gemm --shapes 32x32x32,64x64x64,96x96x96,128x128x128 --no-publish --label native-floor-stage1-A-gemm`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T153504Z-native-floor-stage1-A-gemm/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.73%, worst 49.53% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 39 of 144 engine cells exceed 5% and carry `!`; median within-process relative SD 1.15%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.002354 ± 2.0502e-05 (W 1.95269e-05) | 0.002354 ± 6.1101e-05 (W 1.51427e-05) | 0.004509 ± 1.57162e-05 (W 2.74645e-05) | · | 🔵 fork 1.92× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017042 ± 0.000177043 (W 2.30716e-05) | 0.017062 ± 0.000197315 (W 1.7782e-05) | 0.024415 ± 0.000108214 (W 3.07295e-05) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056726 ± 0.000462566 (W 4.18366e-05) | 0.056806 ± 0.000216419 (W 8.11203e-05) | 0.062697 ± 0.000175594 (W 0.000249227) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 1.57162e-05 (W 1.31643e-05) | 0.010149 ± 0.000311256 (W 0.000703743) | 0.00502 ± 0.000306578 (W 0.000126174) | 🔵 fork 4.33× faster than `faer-upstream` | 🔵 fork 2.14× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017182 ± 7.86787e-05 (W 6.83374e-05) | 0.021991 ± 0.00308497 (W 0.00398315) | 0.014206 ± 0.000238426 (W 0.000109407) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056866 ± 0.0151723 (W 0.0106557) | 0.048911 ± 0.0104261 (W 0.0142218) | 0.022232 ± 0.000361775 (W 0.000144495) | · | 🔴 fork 2.56× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 0 (W 1.82291e-05) | 0.014177 ± 0.000267644 (W 0.00139804) | 0.00498 ± 0.00026266 (W 0.000116397) | 🔵 fork 6.12× faster than `faer-upstream` | 🔵 fork 2.15× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017072 ± 0.000124231 (W 4.67793e-05) | 0.019577 ± 0.00132563 (W 0.00173669) | 0.010078 ± 0.000371601 (W 0.000180475) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030146 ± 0.00102838 (W 0.000924435) | 0.031448 ± 0.00027146 (W 0.00158528) | 0.014888 ± 0.000200326 (W 0.000167229) | · | 🔴 fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002345 ± 5.11892e-05 (W 7.0852e-06) | 0.002345 ± 4.20357e-05 (W 1.85822e-05) | 0.004548 ± 2.08167e-05 (W 2.51456e-05) | · | 🔵 fork 1.94× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017092 ± 0.000153385 (W 1.6559e-05) | 0.017232 ± 0.00019193 (W 2.48998e-05) | 0.024445 ± 3.82143e-05 (W 0.00125919) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056897 ± 0.000151163 (W 0.00104194) | 0.056786 ± 0.000196299 (W 9.57194e-05) | 0.062737 ± 0.000246408 (W 3.40176e-05) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 1.1547e-05 (W 1.3274e-05) | 0.010179 ± 0.000621429 (W 0.000587189) | 0.005209 ± 0.000165016 (W 0.000104025) | 🔵 fork 4.38× faster than `faer-upstream` | 🔵 fork 2.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017122 ± 9.60902e-05 (W 3.11448e-05) | 0.020649 ± 0.00331887 (W 0.00325168) | 0.014167 ± 4.20357e-05 (W 9.42985e-05) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.046747 ± 0.0124046 (W 0.0143609) | 0.055283 ± 0.0107801 (W 0.0132347) | 0.022462 ± 0.000419901 (W 8.49706e-05) | · | 🔴 fork 2.08× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002314 ± 5.7735e-06 (W 8.72926e-06) | 0.012864 ± 0.000677385 (W 0.00147572) | 0.00513 ± 0.00020656 (W 0.000163494) | 🔵 fork 5.56× faster than `faer-upstream` | 🔵 fork 2.22× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017222 ± 0.000202609 (W 4.65972e-05) | 0.020187 ± 0.00117435 (W 0.0020346) | 0.009939 ± 0.000201396 (W 0.000175995) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.031168 ± 0.000651919 (W 0.00225335) | 0.03218 ± 0.00116872 (W 0.00111324) | 0.014697 ± 0.000196749 (W 0.000250191) | · | 🔴 fork 2.12× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008896 ± 5.82266e-05 (W 2.68384e-05) | 0.008926 ± 2.09841e-05 (W 2.50998e-05) | 0.01115 ± 4.95008e-05 (W 0.00012268) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067796 ± 0.000495703 (W 7.82304e-05) | 0.068468 ± 0.000405582 (W 4.86826e-05) | 0.082213 ± 0.000592802 (W 0.00176848) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.227064 ± 0.00135495 (W 0.00157656) | 0.227484 ± 0.00125717 (W 0.00164644) | 0.270003 ± 0.00202489 (W 0.00500588) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008786 ± 3.23574e-05 (W 2.5501e-05) | 0.008827 ± 5.68624e-05 (W 1.29345e-05) | 0.014036 ± 0.000446651 (W 0.000207964) | · | 🔵 fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.036117 ± 0.0053449 (W 0.00381437) | 0.036748 ± 0.00488327 (W 0.00326357) | 0.035807 ± 7.63763e-05 (W 0.000380717) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.087493 ± 0.0049723 (W 0.00738311) | 0.089777 ± 0.00196686 (W 0.00615145) | 0.098975 ± 0.000311433 (W 0.00141767) | · | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008807 ± 0.000106927 (W 1.93468e-05) | 0.008886 ± 6.55515e-05 (W 1.68315e-05) | 0.024526 ± 0.00580048 (W 0.000158019) | · | 🔵 fork 2.78× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.03765 ± 0.000784023 (W 0.00175986) | 0.038232 ± 0.000967732 (W 0.00166126) | 0.015809 ± 0.00017493 (W 0.000224336) | · | 🔴 fork 2.38× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.051946 ± 0.000347627 (W 0.00120095) | 0.051006 ± 0.000791202 (W 0.00139379) | 0.04286 ± 0.00012554 (W 0.00136074) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008946 ± 4.0129e-05 (W 1.6559e-05) | 0.008917 ± 4.08697e-05 (W 1.81659e-05) | 0.011141 ± 0.000150444 (W 0.000148056) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067877 ± 0.000421906 (W 5.34537e-05) | 0.067867 ± 0.000434551 (W 2.02559e-05) | 0.083025 ± 0.000712097 (W 0.00134514) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.227564 ± 0.000497015 (W 0.00200267) | 0.227555 ± 0.000333437 (W 0.00136816) | 0.269914 ± 0.00166301 (W 0.00297393) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008836 ± 2.08167e-05 (W 2.71901e-05) | 0.008857 ± 3.27159e-05 (W 2.59865e-05) | 0.014246 ± 0.000279786 (W 0.000176834) | · | 🔵 fork 1.61× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.040365 ± 0.00382822 (W 0.00460774) | 0.036478 ± 0.00502237 (W 0.00436323) | 0.035426 ± 0.000361539 (W 0.000343041) | · | 🔴 fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.086411 ± 0.00106988 (W 0.00119959) | 0.087013 ± 0.00734661 (W 0.00845361) | 0.098694 ± 0.00129144 (W 0.00112081) | · | 🔵 fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008887 ± 6.61085e-05 (W 2.27442e-05) | 0.008816 ± 6.68356e-05 (W 1.51658e-05) | 0.024666 ± 5.50757e-05 (W 0.000148746) | · | 🔵 fork 2.78× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.038162 ± 0.000995174 (W 0.00194512) | 0.038011 ± 0.0010155 (W 0.00137489) | 0.01582 ± 0.00012822 (W 0.000144594) | · | 🔴 fork 2.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.051807 ± 0.000330939 (W 0.000781114) | 0.051015 ± 0.000335311 (W 0.00125082) | 0.042429 ± 0.000263382 (W 0.000289314) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13404 ± 0.00103759 (W 0.00166886) | 0.13406 ± 0.000435298 (W 0.00148225) | 0.167101 ± 0.000388189 (W 0.00136813) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.077053 ± 0.00688225 (W 0.0248411) | 0.061975 ± 0.0160349 (W 0.0242632) | 0.057397 ± 0.000702302 (W 0.000475156) | · | 🔴 fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.108242 ± 0.0155289 (W 0.0223153) | 0.083316 ± 0.0171575 (W 0.0159798) | 0.0325 ± 0.000671604 (W 0.000190387) | 🔴 fork 1.30× slower than `faer-upstream` | 🔴 fork 3.33× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13399 ± 0.000396671 (W 0.00101524) | 0.13392 ± 0.00034253 (W 0.00124224) | 0.167803 ± 0.00048654 (W 0.00129664) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.083726 ± 0.00635642 (W 0.0169696) | 0.069109 ± 0.0131658 (W 0.0143129) | 0.055733 ± 0.000335107 (W 0.000310436) | · | 🔴 fork 1.50× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.070451 ± 0.0164442 (W 0.0290375) | 0.083085 ± 0.00609157 (W 0.0279036) | 0.03168 ± 0.000172502 (W 0.000233411) | · | 🔴 fork 2.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.537863 ± 0.00143618 (W 0.00175795) | 0.539667 ± 0.00132634 (W 0.00246149) | 0.643329 ± 0.0063427 (W 0.00444713) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.16095 ± 0.00598441 (W 0.00590875) | 0.16125 ± 0.00514221 (W 0.00717313) | 0.232714 ± 0.0016371 (W 0.00381075) | · | 🔵 fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.114002 ± 0.00133753 (W 0.00275876) | 0.115385 ± 0.00143032 (W 0.00980521) | 0.094426 ± 0.00117189 (W 0.000829727) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539797 ± 0.000974911 (W 0.00201102) | 0.539106 ± 0.00274009 (W 0.00236714) | 0.653508 ± 0.00373623 (W 0.0061681) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160228 ± 0.000682233 (W 0.00161276) | 0.160459 ± 0.000166433 (W 0.00628326) | 0.230951 ± 0.0003761 (W 0.00244152) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.1127 ± 0.0149955 (W 0.0135858) | 0.11267 ± 0.000816941 (W 0.0038934) | 0.095027 ± 0.000220303 (W 0.00141547) | · | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
