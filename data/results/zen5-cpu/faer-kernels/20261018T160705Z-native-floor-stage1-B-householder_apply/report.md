# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `7f713a1401f18546d1ef0c134df982be80626b2e`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `651807301c4fd0d485a66038346388dffe289073`
- toolkit commit: `9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5`
- measured binary SHA-256: `f8e8e3337463fe7219395de47c8161bba8c95fb604e743ca89266f587bcfce2a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T16:13:50.852469Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --families householder_apply --shapes 64,1024x64,4096x256 --no-publish --label native-floor-stage1-B-householder_apply`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T160705Z-native-floor-stage1-B-householder_apply/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.17%, worst 23.34% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 19 of 144 engine cells exceed 5% and carry `!`; median within-process relative SD 0.96%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040627 ± 0.000164621 (W 9.67693e-05) | 0.040496 ± 0.000163025 (W 0.00010944) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040877 ± 9.60902e-05 (W 5.76038e-05) | 0.040466 ± 0.000143643 (W 0.000101143) | - | · | - | `*` one row has no measurement here |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.024586 ± 0.000500341 (W 0.00082413) | 0.024416 ± 0.000531015 (W 0.00117268) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.025287 ± 0.000480397 (W 0.000565037) | 0.024667 ± 0.00059509 (W 0.000741024) | - | · | - | `*` one row has no measurement here |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020749 ± 0.00077353 (W 0.000532039) | 0.027642 ± 0.000798875 (W 0.00102497) | - | 🔵 fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.02148 ± 0.000122202 (W 0.00117641) | 0.028504 ± 0.00199621 (W 0.00266324) | - | 🔵 fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040336 ± 0.000172434 (W 5.78118e-05) | 0.040346 ± 0.00012108 (W 5.62334e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040416 ± 9.11976e-05 (W 7.80141e-05) | 0.040486 ± 0.000367788 (W 0.000113225) | - | · | - | `*` one row has no measurement here |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.034766 ± 0.00430279 (W 0.00344214) | 0.023163 ± 0.000171553 (W 0.000556182) | - | 🔴 fork 1.50× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.035377 ± 0.00455546 (W 0.00627387) | 0.024046 ± 0.000700444 (W 0.000492916) | - | 🔴 fork 1.47× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.027752 ± 0.000270814 (W 0.000814774) | 0.028413 ± 0.0017361 (W 0.0012045) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.028634 ± 9.71253e-05 (W 0.00171916) | 0.027211 ± 0.000515469 (W 0.00145042) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.1592 ± 0.0127015 (W 0.00152062) | 0.15894 ± 0.000600402 (W 0.00170778) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159911 ± 0.000159897 (W 0.00113488) | 0.160082 ± 0.000235968 (W 0.0013631) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.066095 ± 0.00062317 (W 0.0104089) | 0.067557 ± 0.00421474 (W 0.00256786) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.066585 ± 0.000136346 (W 0.00149938) | 0.068138 ± 0.0015377 (W 0.00832242) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.04275 ± 0.00020502 (W 0.000372497) | 0.070823 ± 0.001097 (W 0.00269548) | - | 🔵 fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.043572 ± 0.000646979 (W 0.000991388) | 0.071785 ± 0.000564583 (W 0.00149319) | - | 🔵 fork 1.65× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157667 ± 0.000897228 (W 0.00141359) | 0.157527 ± 0.000416103 (W 8.4854e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158799 ± 0.000373847 (W 0.00142851) | 0.158419 ± 0.0004145 (W 0.00164211) | - | · | - | `*` one row has no measurement here |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.071614 ± 0.00292972 (W 0.00299415) | 0.065002 ± 0.000100732 (W 0.00113455) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.077386 ± 0.00434867 (W 0.00173119) | 0.067087 ± 0.00192498 (W 0.00180112) | - | 🔴 fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.051928 ± 0.00356022 (W 0.00313554) | 0.073008 ± 0.00089038 (W 0.00180705) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.050826 ± 0.00102493 (W 0.000684394) | 0.071986 ± 0.000776365 (W 0.00314632) | - | 🔵 fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `householder_apply/64`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.556638 ± 0.000788258 (W 0.00211824) | 0.567718 ± 0.0116461 (W 0.00376806) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.555707 ± 0.000483279 (W 0.00521118) | 0.574472 ± 0.00610672 (W 0.00241059) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.0717 ± 0.0372985 (W 0.0189072) | 35.048 ± 0.0463402 (W 0.0348414) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.0753 ± 0.0306795 (W 0.0205103) | 35.0994 ± 0.344265 (W 0.0387363) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.194797 ± 0.00350754 (W 0.00290632) | 0.167606 ± 0.00231695 (W 0.000718012) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.194045 ± 0.0025396 (W 0.0024477) | 0.163708 ± 0.000586178 (W 0.00157697) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.3528 ± 0.0280007 (W 0.11207) | 9.43752 ± 0.0328635 (W 0.0183413) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.3284 ± 0.155508 (W 0.100593) | 9.41885 ± 0.0486972 (W 0.0291826) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.162426 ± 0.00375732 (W 0.00244451) | 0.13794 ± 0.00465023 (W 0.00218455) | - | 🔴 fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.161394 ± 0.00154708 (W 0.00255278) | 0.141277 ± 0.00569457 (W 0.00346075) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.4626 ± 0.0346691 (W 0.083302) | 5.04172 ± 0.029995 (W 1.0762) | - | 🔴 fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.41657 ± 0.0748207 (W 0.0952604) | 5.06851 ± 0.0545479 (W 1.04524) | - | 🔴 fork 1.27× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.599547 ± 0.00199309 (W 0.00244381) | 0.597426 ± 0.00322884 (W 0.00188435) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.597504 ± 0.00565889 (W 0.00182439) | 0.602957 ± 0.00532527 (W 0.00299114) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.8387 ± 0.0376477 (W 0.0266853) | 35.8608 ± 0.0311761 (W 0.37165) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.7908 ± 0.0442893 (W 0.0230176) | 35.7907 ± 0.0975304 (W 0.0225482) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.198844 ± 0.00431962 (W 0.00436615) | 0.200207 ± 0.000467081 (W 0.00211975) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.199326 ± 0.000205013 (W 0.00357271) | 0.20205 ± 0.000136504 (W 0.00238606) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.2126 ± 0.0157263 (W 0.0241902) | 11.2003 ± 0.0128545 (W 0.0160915) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2808 ± 0.0228563 (W 0.0264783) | 11.2331 ± 0.0122322 (W 0.0217206) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.160342 ± 0.00179766 (W 0.0032517) | 0.183465 ± 0.00551775 (W 0.00256303) | - | 🔵 fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.163077 ± 0.00532319 (W 0.00473838) | 0.182193 ± 0.00450915 (W 0.00228166) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.49561 ± 0.23523 (W 0.304479) | 7.05833 ± 0.0980928 (W 0.799384) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.59591 ± 0.0575894 (W 0.103498) | 6.8744 ± 0.101983 (W 0.92263) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.1974 ± 0.0045591 (W 0.00291353) | 2.22923 ± 0.0220377 (W 0.00181619) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20225 ± 0.00276429 (W 0.00352408) | 2.20496 ± 0.0228864 (W 0.00161256) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.762 ± 0.0720169 (W 0.13353) | 137.665 ± 0.0486083 (W 0.104132) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.736 ± 0.071776 (W 0.0816048) | 137.758 ± 0.0355952 (W 0.07699) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.634624 ± 0.00240157 (W 0.0135528) | 0.583648 ± 0.00245985 (W 0.00313446) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.629596 ± 0.0026251 (W 0.010629) | 0.605179 ± 0.00220805 (W 0.00248199) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.0683 ± 0.0512138 (W 0.213526) | 37.1629 ± 0.176151 (W 0.0334588) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.048 ± 0.0961493 (W 0.168225) | 37.2229 ± 0.071753 (W 0.230474) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.409161 ± 0.00399641 (W 0.00589998) | 0.41464 ± 0.00337307 (W 0.00329529) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.406665 ± 0.012667 (W 0.00377393) | 0.417155 ± 0.00699415 (W 0.00363784) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.9706 ± 0.13487 (W 0.484709) | 18.9847 ± 0.12295 (W 3.70519) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.7854 ± 0.142052 (W 0.262527) | 18.9733 ± 0.0687642 (W 0.0526967) | - | 🔴 fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.27231 ± 0.0169867 (W 0.003264) | 2.25827 ± 0.0131452 (W 0.00437272) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.28443 ± 0.0133273 (W 0.00293124) | 2.284 ± 0.0119453 (W 0.00206182) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.725 ± 0.128207 (W 0.421995) | 138.665 ± 0.148386 (W 0.140543) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.779 ± 0.0920574 (W 0.075348) | 138.854 ± 0.133317 (W 0.0706592) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.641147 ± 0.0115652 (W 0.00893346) | 0.634155 ± 0.00858801 (W 0.00416999) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.645404 ± 0.00624407 (W 0.0126797) | 0.651074 ± 0.00293769 (W 0.00230161) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.0444 ± 0.0324567 (W 0.0631344) | 39.5824 ± 0.032503 (W 0.060992) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.2433 ± 0.09126 (W 0.0662412) | 39.457 ± 0.0932422 (W 0.180236) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.417186 ± 0.00477756 (W 0.00593983) | 0.45727 ± 0.0050532 (W 0.00472914) | - | 🔵 fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.427454 ± 0.00868745 (W 0.00792062) | 0.461189 ± 0.00146956 (W 0.00426026) | - | 🔵 fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.0903 ± 0.0147626 (W 0.421448) | 21.1769 ± 0.214903 (W 3.22265) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.1794 ± 0.33716 (W 0.206348) | 21.2909 ± 0.0603728 (W 0.264854) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `householder_apply/1024x64`, `householder_apply/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
