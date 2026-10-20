# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `52b113acd2e22fe97f4ad1face143cff58d9b3ed`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `3c59451a45c29f2af56c74b5b58d073810b76a9c`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `e68bfcc44f04569d9656938f37133343b92850898b1986ab8d4051a57150f83b`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T01:11:25.470385Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-tall --shapes 4096x256,1024x64 --families qr_factor,qr,householder_apply,upgrade_factor --threads 4,8 --dtypes f64 --reps 5 --aa 3 --prime-ms 250 --no-publish --label candidate-tall-guard-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T010404Z-candidate-tall-guard-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.33%, worst 16.73% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 9 of 80 engine cells exceed 5% and carry `!`; median within-process relative SD 1.05%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.189034 ± 0.00663735 (W 0.00529515) | 0.161923 ± 0.00388264 (W 0.00142464) | - | 🔴 fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.188105 ± 0.00496205 (W 0.00235542) | 0.161253 ± 0.00306297 (W 0.00187773) | - | 🔴 fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 9.7799 ± 0.0591933 (W 0.0649809) | 9.37403 ± 0.0192084 (W 0.027244) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 9.83447 ± 0.125357 (W 0.0329458) | 9.42238 ± 0.0463251 (W 0.0377294) | - | · | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.3073 ± 0.0117927 (W 0.0166438) | 1.6952 ± 0.0124353 (W 0.0115246) | 1.06049 ± 0.00904196 (W 0.00673346) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 33.4992 ± 2.79222 (W 0.126001) | 40.182 ± 2.8306 (W 0.277036) | 30.1599 ± 1.90694 (W 0.0580674) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.09475 ± 0.0280185 (W 0.0099997) | 3.99506 ± 0.149684 (W 0.0955621) | 0.456888 ± 0.00434537 (W 0.00553561) | 🔵 fork 3.65× faster than `faer-upstream` | 🔴 fork 2.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 15.8732 ± 0.259942 (W 0.104941) | 77.2406 ± 0.30514 (W 0.472689) | 12.648 ± 0.0275699 (W 0.129347) | 🔵 fork 4.87× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.188652 ± 0.00121453 (W 0.00587699) | 0.135202 ± 0.000686834 (W 0.00132167) | - | 🔴 fork 1.40× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.188043 ± 0.00283538 (W 0.00207309) | 0.136952 ± 0.00264951 (W 0.00164523) | - | 🔴 fork 1.37× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.26423 ± 0.0243053 (W 0.0523252) | 5.03711 ± 0.0248294 (W 0.0444321) | - | 🔴 fork 1.24× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.28398 ± 0.0149236 (W 0.0689938) | 5.04555 ± 0.00911963 (W 1.01799) | - | 🔴 fork 1.25× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.49516 ± 0.00988182 (W 0.0172687) | 2.00164 ± 0.0167515 (W 0.0297252) | 0.882708 ± 0.00122772 (W 0.00432063) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 23.3217 ± 0.365495 (W 0.409152) | 35.4249 ± 0.154216 (W 0.566828) | 20.7794 ± 0.0522034 (W 0.0476241) | 🔵 fork 1.52× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.1373 ± 0.0111773 (W 0.0299887) | 4.46381 ± 0.0475567 (W 0.128127) | 0.321162 ± 0.0014701 (W 0.00170167) | 🔵 fork 3.92× faster than `faer-upstream` | 🔴 fork 3.54× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.3536 ± 0.166624 (W 0.0867473) | 76.5767 ± 0.0816491 (W 0.183374) | 7.25979 ± 0.0195035 (W 0.047633) | 🔵 fork 5.73× faster than `faer-upstream` | 🔴 fork 1.84× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.200963 ± 0.00208095 (W 0.00950846) | 0.20219 ± 0.000871351 (W 0.00269181) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.199387 ± 0.000989026 (W 0.00285273) | 0.202541 ± 0.00136276 (W 0.0024204) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.292 ± 0.0819095 (W 0.0183682) | 11.2276 ± 0.212008 (W 0.0123492) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.27 ± 0.067442 (W 0.0191436) | 11.1754 ± 0.125113 (W 0.0172182) | - | · | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.17538 ± 0.0135025 (W 0.0213274) | 1.62521 ± 0.00902285 (W 0.010311) | 0.988009 ± 0.006497 (W 0.00367818) | 🔵 fork 1.38× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 31.0084 ± 2.93708 (W 0.156215) | 34.4825 ± 2.78619 (W 0.102695) | 26.9198 ± 0.156914 (W 0.0722087) | · | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.89433 ± 0.00425763 (W 0.0101664) | 1.37258 ± 0.0157162 (W 0.0149764) | 0.415969 ± 0.00269239 (W 0.00849353) | 🔵 fork 1.53× faster than `faer-upstream` | 🔴 fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.5474 ± 0.014219 (W 0.198846) | 17.8962 ± 0.0767306 (W 0.132667) | 11.2053 ± 0.0951317 (W 0.0300547) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.185824 ± 0.00129028 (W 0.00342171) | 0.181496 ± 0.000512172 (W 0.00176623) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.184692 ± 0.00358954 (W 0.00299216) | 0.181811 ± 0.0125369 (W 0.00273539) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.72325 ± 0.219411 (W 0.145517) | 6.86866 ± 0.0422212 (W 0.83265) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.63858 ± 0.0509199 (W 0.0866589) | 6.96222 ± 0.112276 (W 0.757834) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.36567 ± 0.00744734 (W 0.0161945) | 1.91952 ± 0.00627952 (W 0.0278493) | 0.844601 ± 0.00407245 (W 0.00387606) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 20.5609 ± 0.178701 (W 0.385273) | 29.7211 ± 0.212314 (W 0.446509) | 19.2873 ± 0.283581 (W 0.0561159) | 🔵 fork 1.45× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.987553 ± 0.0115697 (W 0.0270517) | 1.69742 ± 0.00922028 (W 0.0433282) | 0.300647 ± 0.00061946 (W 0.00196102) | 🔵 fork 1.72× faster than `faer-upstream` | 🔴 fork 3.28× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 12.1823 ± 0.13792 (W 0.0439747) | 19.5175 ± 0.0947845 (W 0.239748) | 6.54183 ± 0.0254168 (W 0.0345921) | 🔵 fork 1.60× faster than `faer-upstream` | 🔴 fork 1.86× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/1024x64`, `householder_apply/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
