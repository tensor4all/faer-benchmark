# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `fe41bbdfb88c0528e0726dca3b1764f47222ad56`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `a845b77d8ed85e6a23e674743f4825b0513b5882`
- toolkit commit: `5e2b35c2197117414ca97372735938a1a3d958ac`
- measured binary SHA-256: `b0781c1608511c2a7caf169f45c0ebb5dc8e143a33b8c7ac93679526d39558a4`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-16T09:41:03.758632Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /home/shinaoka/projects/tensor4all/faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-mid,linalg-mid --shapes 256,256x256x256 --dtypes f64 --families gemm,lu,cholesky,qr_factor --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label candidate-fe41bbd-mkl --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T093643Z-candidate-fe41bbd-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.68%, worst 29.89% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 17 of 72 engine cells exceed 5% and carry `!`; median within-process relative SD 0.78%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.08042 ± 0.00690987 (W 0.000984441) | 1.07671 ± 0.0130061 (W 0.00214984) | 1.20406 ± 0.00253432 (W 0.00217048) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.300053 ± 0.00649868 (W 0.00715477) | 0.30352 ± 0.00246032 (W 0.00354399) | 0.344587 ± 0.000448476 (W 0.00230059) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.236053 ± 0.0311641 (W 0.0287368) | 0.21864 ± 0.0176065 (W 0.0211408) | 0.179477 ± 0.00140767 (W 0.00156085) | · | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.08107 ± 0.00834851 (W 0.00138386) | 1.08049 ± 0.00852556 (W 0.000832525) | 1.20996 ± 0.00171787 (W 0.00227504) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.300795 ± 0.00484 (W 0.00198157) | 0.307948 ± 0.00616454 (W 0.00567696) | 0.344417 ± 0.00407787 (W 0.00257913) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.205816 ± 0.0203612 (W 0.0371372) | 0.219953 ± 0.0138111 (W 0.0225173) | 0.179677 ± 0.00225828 (W 0.00163942) | · | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.381697 ± 0.00177331 (W 0.00259183) | 0.387717 ± 0.00090653 (W 0.00239306) | 0.641674 ± 0.00380202 (W 0.00565055) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 0.976383 ± 0.115947 (W 0.00318234) | 1.03682 ± 0.00597137 (W 0.00309967) | 0.970161 ± 0.00300308 (W 0.00327829) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.60078 ± 0.00921476 (W 0.00620007) | 2.86526 ± 0.00779398 (W 0.00558149) | 2.05054 ± 0.00663242 (W 0.00889736) | 🔵 fork 1.79× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.416392 ± 0.00897705 (W 0.021917) | 0.411313 ± 0.00556225 (W 0.0107872) | 0.406814 ± 0.00309457 (W 0.00578215) | · | · |  |
| `lu/n256/b1` | 0.986412 ± 0.108998 (W 0.0125289) | 1.15213 ± 0.00844559 (W 0.0273274) | 0.376096 ± 0.00164982 (W 0.00190692) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 2.62× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.48349 ± 0.00992013 (W 0.0230682) | 5.58993 ± 0.0464094 (W 0.0428054) | 0.67119 ± 0.00291452 (W 0.00318874) | 🔵 fork 3.77× faster than `faer-upstream` | 🔴 fork 2.21× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.447259 ± 0.0107882 (W 0.030728) | 0.472607 ± 0.0182037 (W 0.0160045) | 0.359194 ± 0.00177507 (W 0.00220338) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.99615 ± 0.120682 (W 0.00349408) | 1.26409 ± 0.019536 (W 0.017816) | 0.347322 ± 0.000908175 (W 0.00271528) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 2.87× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.57897 ± 0.0106288 (W 0.0155937) | 6.6667 ± 0.0417598 (W 0.0473847) | 0.574308 ± 0.00327972 (W 0.00275727) | 🔵 fork 4.22× faster than `faer-upstream` | 🔴 fork 2.75× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.317606 ± 0.0018845 (W 0.0023835) | 0.323097 ± 0.00439495 (W 0.00192205) | 0.457789 ± 0.000927903 (W 0.00384941) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 0.698291 ± 0.113404 (W 0.00300999) | 0.697249 ± 0.116984 (W 0.00275631) | 0.816502 ± 0.0009934 (W 0.00277119) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.37157 ± 0.00344974 (W 0.00208184) | 1.38057 ± 0.00347469 (W 0.00308525) | 1.89704 ± 0.00502666 (W 0.00714069) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.353724 ± 0.00541495 (W 0.0229807) | 0.338225 ± 0.0227609 (W 0.0122978) | 0.241634 ± 0.00482375 (W 0.00314999) | · | 🔴 fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.703701 ± 0.118161 (W 0.00205228) | 0.812906 ± 0.11962 (W 0.0209136) | 0.334228 ± 0.00731356 (W 0.00259656) | · | 🔴 fork 2.11× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.36159 ± 0.012206 (W 0.0313294) | 3.03931 ± 0.0730937 (W 0.0986665) | 0.626335 ± 0.00616717 (W 0.00238989) | 🔵 fork 2.23× faster than `faer-upstream` | 🔴 fork 2.17× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.397797 ± 0.0192593 (W 0.010215) | 0.404209 ± 0.0115574 (W 0.0239953) | 0.194886 ± 0.00271773 (W 0.00417308) | · | 🔴 fork 2.04× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.706476 ± 0.120968 (W 0.00265905) | 0.924485 ± 0.112242 (W 0.03308) | 0.313308 ± 0.00525013 (W 0.00380085) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.47231 ± 0.012575 (W 0.0123606) | 4.08705 ± 0.0229168 (W 0.0598052) | 0.543199 ± 0.000766723 (W 0.00354591) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 2.71× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
