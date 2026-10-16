# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `22a99b295247f785277800ae3c771d85dd3128e1`
- toolkit commit: `5e2b35c2197117414ca97372735938a1a3d958ac`
- measured binary SHA-256: `7b902aa706b7a981a7248eac2c7b479cb69b52d9832fad2bf0e0112c9f98aa98`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-16T11:17:55.715185Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-tall --shapes 4096x256 --families qr_factor,qr,lu --dtypes f64,c64 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label baseline-ref-tall-mkl --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T110534Z-baseline-ref-tall-mkl/`

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
- CPU sets: 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.82%, worst 20.44% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 8 of 72 engine cells exceed 5% and carry `!`; median within-process relative SD 0.43%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 13.1047 ± 0.0492484 (W 0.0576305) | 13.1018 ± 0.0254094 (W 0.0329596) | 13.3779 ± 0.073445 (W 0.0558742) | · | · |  |
| `qr/4096x256/b1` | 36.2006 ± 2.58038 (W 0.12807) | 39.8677 ± 0.207126 (W 0.282784) | 30.2642 ± 1.92593 (W 0.103818) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 70.8111 ± 0.436447 (W 0.373081) | 76.9053 ± 0.419753 (W 0.261291) | 12.7547 ± 0.0724792 (W 0.0949045) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 5.55× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 12.2551 ± 0.0144924 (W 0.0758159) | 12.2291 ± 0.0298163 (W 0.998104) | 4.1085 ± 0.0290641 (W 0.0245248) | · | 🔴 fork 2.98× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 30.3087 ± 2.56808 (W 0.479202) | 39.4375 ± 2.72893 (W 0.768638) | 20.7543 ± 0.00630539 (W 0.0569527) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 68.9891 ± 0.329909 (W 0.496936) | 76.7016 ± 0.271964 (W 0.563312) | 7.23436 ± 0.0633941 (W 0.031497) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 9.54× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 7.41967 ± 0.0943335 (W 0.0608022) | 7.38961 ± 0.0273562 (W 0.0363817) | 11.5703 ± 0.0325983 (W 0.0189212) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 31.023 ± 0.337365 (W 0.202927) | 34.5079 ± 0.136013 (W 0.150032) | 26.9974 ± 0.101168 (W 0.075119) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.5966 ± 0.187001 (W 0.147325) | 17.7667 ± 0.321817 (W 0.123405) | 11.2136 ± 0.0759017 (W 0.0495052) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 6.75696 ± 0.0597325 (W 0.0269592) | 6.71874 ± 0.0398479 (W 0.0480218) | 3.19479 ± 0.0296757 (W 0.00899976) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 25.0285 ± 2.85633 (W 0.524961) | 33.778 ± 2.34803 (W 0.616942) | 19.3419 ± 0.0593523 (W 0.0422402) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 11.5337 ± 0.11948 (W 0.0459624) | 19.2937 ± 0.158654 (W 0.413247) | 6.45277 ± 0.0504295 (W 0.0489773) | 🔵 fork 1.67× faster than `faer-upstream` | 🔴 fork 1.79× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 29.6745 ± 0.032515 (W 0.0597625) | 29.832 ± 0.0595954 (W 0.0877633) | 58.9414 ± 0.338464 (W 0.161128) | · | 🔵 fork 1.99× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 99.6805 ± 0.277858 (W 0.281744) | 107.278 ± 0.341471 (W 0.233061) | 85.9315 ± 0.390341 (W 0.388931) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 115.196 ± 0.481419 (W 0.445691) | 124.796 ± 0.568817 (W 0.621428) | 34.1581 ± 1.50393 (W 0.301589) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 3.37× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 25.8188 ± 0.0501495 (W 0.107005) | 25.9724 ± 0.0235293 (W 0.0636807) | 57.9566 ± 0.440614 (W 0.22396) | · | 🔵 fork 2.24× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 73.7439 ± 0.103628 (W 0.384777) | 90.4625 ± 0.313925 (W 0.83645) | 51.1798 ± 2.98141 (W 0.255227) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 106.862 ± 0.454422 (W 0.39832) | 121.526 ± 0.298623 (W 0.466158) | 19.6573 ± 0.0302036 (W 0.157137) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 5.44× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 17.3882 ± 0.0448128 (W 0.038574) | 17.582 ± 0.022696 (W 0.04927) | 49.4041 ± 0.00651914 (W 0.065184) | · | 🔵 fork 2.84× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 88.4762 ± 0.56037 (W 0.143511) | 95.898 ± 0.162833 (W 0.286309) | 74.0167 ± 0.198236 (W 0.381488) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 35.7006 ± 0.142475 (W 0.0954735) | 43.9715 ± 0.133419 (W 0.0616414) | 31.2828 ± 0.421452 (W 0.0927936) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/4096x256/b1` | 13.5415 ± 0.0386167 (W 0.0793739) | 13.677 ± 0.0802384 (W 0.0499676) | 49.5764 ± 0.059252 (W 0.41925) | · | 🔵 fork 3.66× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 61.8246 ± 0.196357 (W 0.255033) | 79.1806 ± 0.698578 (W 0.412757) | 41.9653 ± 0.161432 (W 0.144538) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.3279 ± 0.024064 (W 0.190032) | 41.4127 ± 0.0249936 (W 0.0846066) | 17.5872 ± 0.0471036 (W 0.113748) | 🔵 fork 1.52× faster than `faer-upstream` | 🔴 fork 1.55× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
