# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `0627828d965b4abbf5eb14cc012f524a42966e85`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9b65ef9ea7de07a70d6f211ae12b47c9bce75b8e`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `7f53c095fa4ce2e7f2bb9356b147b5b1b15e47f1f2371fc1c1ef5373da4b3edc`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T01:39:12.566220Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-tall --shapes 4096x256,1024x64 --families qr_factor,qr,householder_apply,upgrade_factor --threads 4,8 --dtypes f64 --reps 5 --aa 3 --prime-ms 250 --no-publish --label candidate-split-only-tall-guard-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T013320Z-candidate-split-only-tall-guard-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.64%, worst 26.21% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 12 of 80 engine cells exceed 5% and carry `!`; median within-process relative SD 1.05%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.184773 ± 0.00134438 (W 0.00172127) | 0.165748 ± 0.00331691 (W 0.00225613) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.190243 ± 0.00316906 (W 0.00243809) | 0.164555 ± 0.00415145 (W 0.00173758) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.1691 ± 0.132614 (W 0.105492) | 9.85359 ± 0.206867 (W 0.0244467) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.3394 ± 0.0941676 (W 0.207881) | 9.50795 ± 0.0166202 (W 0.0360519) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.2855 ± 0.00529349 (W 0.013487) | 1.70453 ± 0.0106254 (W 0.00677743) | 1.05949 ± 0.00575566 (W 0.00711636) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 28.4197 ± 0.0290155 (W 0.283481) | 35.4153 ± 0.0868051 (W 0.111565) | 30.1894 ± 0.327629 (W 0.0767958) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.11046 ± 0.0075067 (W 0.0176024) | 3.98696 ± 0.193014 (W 0.120132) | 0.456365 ± 0.00959565 (W 0.00862989) | 🔵 fork 3.59× faster than `faer-upstream` | 🔴 fork 2.43× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 15.8288 ± 0.0913794 (W 0.302093) | 76.8016 ± 0.820072 (W 0.468494) | 12.6049 ± 0.181367 (W 0.0921734) | 🔵 fork 4.85× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.151892 ± 0.00567373 (W 0.0020888) | 0.137916 ± 0.00350431 (W 0.0015335) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.159395 ± 0.00864701 (W 0.0030501) | 0.138858 ± 0.00190635 (W 0.00226385) | - | 🔴 fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.45738 ± 0.121599 (W 0.0940101) | 5.0433 ± 0.0139876 (W 0.959687) | - | 🔴 fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.50902 ± 0.0113743 (W 0.0644538) | 5.0479 ± 0.0246135 (W 1.08388) | - | 🔴 fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.38576 ± 0.0142019 (W 0.0218142) | 2.01823 ± 0.0176848 (W 0.033234) | 0.881186 ± 0.0036439 (W 0.00672332) | 🔵 fork 1.46× faster than `faer-upstream` | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.3404 ± 3.33903 (W 0.266195) | 35.4615 ± 2.59443 (W 0.402062) | 20.9622 ± 0.181896 (W 0.0629322) | 🔵 fork 1.59× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.15748 ± 0.0201802 (W 0.0121807) | 4.30568 ± 0.217036 (W 0.112964) | 0.322137 ± 0.00232905 (W 0.00315827) | 🔵 fork 3.72× faster than `faer-upstream` | 🔴 fork 3.59× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 12.9844 ± 0.123975 (W 0.0521877) | 76.9795 ± 0.407703 (W 5.2097) | 7.24769 ± 0.0873605 (W 0.0941196) | 🔵 fork 5.93× faster than `faer-upstream` | 🔴 fork 1.79× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.198539 ± 0.00077283 (W 0.00203398) | 0.203017 ± 0.00406714 (W 0.00242825) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.197656 ± 0.000340412 (W 0.00274429) | 0.201684 ± 0.00309146 (W 0.00111327) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.2524 ± 0.0471722 (W 0.0168036) | 11.1886 ± 0.0268463 (W 0.0203979) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2823 ± 0.0235613 (W 0.0407959) | 11.1917 ± 0.0190909 (W 0.0162502) | - | · | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.2048 ± 0.00431869 (W 0.00931548) | 1.63883 ± 0.0099517 (W 0.0138954) | 0.986641 ± 0.00633874 (W 0.00407653) | 🔵 fork 1.36× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.1381 ± 0.113249 (W 0.275911) | 29.69 ± 0.0670637 (W 0.0826211) | 26.7883 ± 0.142105 (W 0.0498552) | 🔵 fork 1.14× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.931408 ± 0.00655414 (W 0.006356) | 1.38812 ± 0.00809922 (W 0.0128557) | 0.412215 ± 0.00354609 (W 0.00381455) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.4649 ± 0.306437 (W 0.272286) | 17.8617 ± 0.302149 (W 2.63052) | 11.2026 ± 0.0838156 (W 0.0226889) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.1617 ± 0.00227081 (W 0.00324348) | 0.182909 ± 0.00368785 (W 0.002547) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.15651 ± 0.00745649 (W 0.00326487) | 0.160798 ± 0.0170408 (W 0.00213197) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.49216 ± 0.239177 (W 0.924275) | 6.72645 ± 0.0187714 (W 0.993825) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.60353 ± 0.0456212 (W 0.200839) | 6.78055 ± 0.052126 (W 0.0666198) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.30763 ± 0.0102442 (W 0.0134415) | 1.92358 ± 0.0235611 (W 0.029554) | 0.847495 ± 0.00733399 (W 0.0023869) | 🔵 fork 1.47× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 20.4513 ± 2.92342 (W 0.327635) | 30.0556 ± 3.20521 (W 0.488213) | 19.1536 ± 0.122148 (W 0.0311189) | 🔵 fork 1.47× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.05107 ± 0.0153 (W 0.0116208) | 1.6896 ± 0.0346037 (W 0.0148821) | 0.301851 ± 0.00241635 (W 0.00196532) | 🔵 fork 1.61× faster than `faer-upstream` | 🔴 fork 3.48× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.7201 ± 0.140523 (W 0.0305108) | 19.5459 ± 0.216381 (W 0.0776267) | 6.50418 ± 0.0379106 (W 0.0376154) | 🔵 fork 1.67× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/1024x64`, `householder_apply/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
