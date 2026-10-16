<!-- generated from data/results/zen5-cpu/faer-kernels-large/20261016T080927Z-baseline-v2-large-1024-openblas/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels-large` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `86201665e0945d798e18a3b2a5278f67b6505e3f`
- toolkit commit: `884b638a744449a59ab1c98453fce4e242cb462d`
- measured binary SHA-256: `25322cf27657b8a0bfb24194340f08ff03d0d8651868dc74156f8d1750d81589`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-16T08:41:53.289089Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels-large --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor openblas --engines faer-fork,lapack-openblas --regimes gemm-large,linalg-large --shapes 1024,1024x1024x1024 --dtypes f64 --families lu,full_piv_lu,cholesky,qr_factor,qr,svd_values,svd_thin,eigh,gemm --reps 5 --aa 2 --prime-ms 250 --label baseline-v2-large-1024-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels-large/20261016T080927Z-baseline-v2-large-1024-openblas/`

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
- CPU sets: 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 2 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.73%, worst 33.65% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 9 of 68 engine cells exceed 5% and carry `!`; median within-process relative SD 0.33%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 7.91107 ± 0.00122683 (W 0.0546606) | 20.954 ± 0.0835447 (W 0.0626113) | 🔵 fork 2.65× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 120.692 ± 0.354673 (W 0.111962) | 142.71 ± 0.0362555 (W 0.325833) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 82.2486 ± 0.65778 (W 0.943794) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 24.7473 ± 3.35295 (W 0.0815234) | 33.0613 ± 0.144024 (W 0.708839) | 🔵 fork 1.34× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 63.2263 ± 0.476217 (W 0.306947) | 112.455 ± 0.174488 (W 0.397696) | 🔵 fork 1.78× faster than `lapack-openblas` |  |
| `qr_factor/n1024/b1` | 75.68 ± 0.36162 (W 0.27035) | 51.8532 ± 0.705017 (W 0.0937911) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `svd_thin/n1024/b1` | 307.169 ± 0.45538 (W 2.53935) | 468.604 ± 9.23103 (W 4.47171) | 🔵 fork 1.53× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 211.262 ± 0.267747 (W 1.0007) | 231.429 ± 4.416 (W 1.0284) | 🔵 fork 1.10× faster than `lapack-openblas` |  |

## linalg-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 6.82608 ± 0.319527 (W 0.107089) | 19.0363 ± 0.0709794 (W 0.0307536) | 🔵 fork 2.79× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n1024/b1` | 102.951 ± 1.30785 (W 0.527554) | 115.593 ± 0.311017 (W 0.29878) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 73.402 ± 1.34736 (W 0.447026) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 22.6229 ± 2.87695 (W 0.562169) | 29.2207 ± 0.160869 (W 0.36619) | 🔵 fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 56.4808 ± 5.12738 (W 0.91347) | 94.1746 ± 4.06385 (W 0.537699) | 🔵 fork 1.67× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 78.5392 ± 0.925161 (W 1.13837) | 46.5479 ± 1.25406 (W 0.947594) | 🔴 fork 1.69× slower than `lapack-openblas` |  |
| `svd_thin/n1024/b1` | 270.944 ± 0.594843 (W 1.09629) | 420.027 ± 1.37008 (W 4.20405) | 🔵 fork 1.55× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 198.049 ± 0.118067 (W 1.31367) | 216.895 ± 3.05126 (W 0.411427) | 🔵 fork 1.10× faster than `lapack-openblas` |  |

## linalg-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 5.71587 ± 0.0188515 (W 0.0597576) | 7.67209 ± 0.00515552 (W 0.0286857) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 118.328 ± 0.413745 (W 0.262446) | 128.798 ± 0.500233 (W 0.42272) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 74.3232 ± 0.105128 (W 0.356304) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 17.4674 ± 3.6198 (W 0.184682) | 14.0369 ± 0.334582 (W 0.0231225) | 🔴 fork 1.24× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 55.9837 ± 0.659992 (W 0.670778) | 83.9471 ± 1.52972 (W 0.0696535) | 🔵 fork 1.50× faster than `lapack-openblas` |  |
| `qr_factor/n1024/b1` | 26.0475 ± 0.00439962 (W 0.0556778) | 37.8475 ± 0.123529 (W 0.0493685) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `svd_thin/n1024/b1` | 299.638 ± 1.28406 (W 1.10497) | 407.866 ± 22.1629 (W 9.75994) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n1024/b1` | 203.538 ± 0.0841104 (W 0.442618) | 207.312 ± 2.30724 (W 0.297738) | · |  |

## linalg-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 4.45137 ± 0.0506402 (W 0.0748533) | 5.77694 ± 0.0544543 (W 0.0272148) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 101.349 ± 0.0525557 (W 0.474623) | 101.684 ± 0.646404 (W 0.090469) | · |  |
| `full_piv_lu/n1024/b1` | 59.9582 ± 0.313472 (W 0.138905) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 15.5013 ± 3.68865 (W 7.21155) | 7.75509 ± 0.0394905 (W 0.0226038) | 🔴 fork 2.00× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 49.7738 ± 4.52389 (W 1.66653) | 69.017 ± 0.915282 (W 0.107342) | 🔵 fork 1.39× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 27.3821 ± 0.373609 (W 0.369422) | 30.7959 ± 0.0979414 (W 0.034053) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n1024/b1` | 264.315 ± 0.703279 (W 0.882691) | 354.877 ± 6.09666 (W 0.710345) | 🔵 fork 1.34× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 190.028 ± 0.234659 (W 0.947545) | 204.608 ± 3.102 (W 0.770656) | 🔵 fork 1.08× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/1024`.

## gemm-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6032 ± 0.0190191 (W 0.0198661) | 20.5209 ± 0.0369895 (W 0.035951) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.05363 ± 0.00191131 (W 0.0150568) | 10.7594 ± 0.157588 (W 0.0153365) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6104 ± 0.00211496 (W 0.0162851) | 20.5278 ± 0.051336 (W 0.205324) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.03653 ± 0.000717713 (W 0.0154474) | 10.5648 ± 0.106033 (W 0.0393749) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
