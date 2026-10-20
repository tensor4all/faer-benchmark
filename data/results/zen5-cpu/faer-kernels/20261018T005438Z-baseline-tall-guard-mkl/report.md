# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `5578ccc3df0d980374b2fda6327710d0dcb52c8c`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `3c59451a45c29f2af56c74b5b58d073810b76a9c`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `51563e16906518834e6fb1cf27ffc122bbf7c87a9f31584c471bb02fdfa21906`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T01:00:00.416228Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-tall --shapes 4096x256,1024x64 --families qr_factor,qr,householder_apply,upgrade_factor --threads 4,8 --dtypes f64 --reps 5 --aa 3 --prime-ms 250 --no-publish --label baseline-tall-guard-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T005438Z-baseline-tall-guard-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.33%, worst 35.31% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 11 of 80 engine cells exceed 5% and carry `!`; median within-process relative SD 0.98%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.187537 ± 0.00196653 (W 0.0037301) | 0.160657 ± 0.00288806 (W 0.0014099) | - | 🔴 fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.183669 ± 0.00133344 (W 0.00313834) | 0.161128 ± 0.00261053 (W 0.00168162) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.124 ± 0.114798 (W 0.130875) | 9.40881 ± 0.019015 (W 0.0301563) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.0856 ± 0.0547839 (W 0.0665435) | 9.52204 ± 0.0379778 (W 0.0330923) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.28473 ± 0.0123316 (W 0.0104857) | 1.70892 ± 0.0121592 (W 0.0108427) | 1.06385 ± 0.0137272 (W 0.0105792) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 33.447 ± 0.0617698 (W 0.143696) | 40.094 ± 0.113928 (W 0.409789) | 29.9764 ± 2.04291 (W 0.103947) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.10805 ± 0.0329543 (W 0.0260013) | 3.85164 ± 0.10934 (W 0.141606) | 0.463887 ± 0.00725533 (W 0.00934443) | 🔵 fork 3.48× faster than `faer-upstream` | 🔴 fork 2.39× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 16.0055 ± 0.12891 (W 0.275488) | 76.8678 ± 0.056784 (W 0.287237) | 12.6523 ± 0.0332076 (W 0.0497812) | 🔵 fork 4.80× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.155568 ± 0.00499827 (W 0.00198326) | 0.134108 ± 0.00369941 (W 0.00144115) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.153965 ± 0.00232249 (W 0.00246102) | 0.135341 ± 0.00297248 (W 0.00317945) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.52346 ± 0.042816 (W 0.03637) | 5.0435 ± 0.031254 (W 0.0393917) | - | 🔴 fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.50454 ± 0.0316126 (W 0.101509) | 5.09963 ± 0.07518 (W 0.0503533) | - | 🔴 fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.40865 ± 0.0137991 (W 0.0159556) | 2.00186 ± 0.00983494 (W 0.0342126) | 0.884085 ± 0.00149471 (W 0.00321303) | 🔵 fork 1.42× faster than `faer-upstream` | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.595 ± 3.59857 (W 0.39266) | 35.4955 ± 2.8246 (W 0.684656) | 20.7995 ± 0.120809 (W 0.269506) | 🔵 fork 1.57× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.20057 ± 0.0211738 (W 0.0175717) | 4.29786 ± 0.07808 (W 0.121468) | 0.321554 ± 0.00174726 (W 0.00148167) | 🔵 fork 3.58× faster than `faer-upstream` | 🔴 fork 3.73× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.056 ± 0.167821 (W 0.0682582) | 76.5256 ± 0.207855 (W 0.365986) | 7.24744 ± 0.0310526 (W 0.0305344) | 🔵 fork 5.86× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.196804 ± 0.0170731 (W 0.0103801) | 0.201853 ± 0.00244954 (W 0.00212466) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.199028 ± 0.000672869 (W 0.00210339) | 0.202154 ± 0.00188963 (W 0.00173254) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.1705 ± 0.0656282 (W 0.0317319) | 10.8712 ± 0.216802 (W 0.0402707) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2766 ± 0.0495419 (W 0.0335326) | 11.0173 ± 0.149678 (W 0.0534489) | - | · | - | `*` one row has no measurement here |
| `qr/1024x64/b1` | 1.20631 ± 0.00626383 (W 0.0124893) | 1.61556 ± 0.00394535 (W 0.0116425) | 0.982267 ± 0.00232209 (W 0.00429257) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 30.852 ± 0.210248 (W 0.234405) | 34.4102 ± 0.167573 (W 0.223048) | 27.0209 ± 0.148211 (W 0.065226) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.919701 ± 0.00230591 (W 0.00991083) | 1.37106 ± 0.00638681 (W 0.0111903) | 0.415438 ± 0.00254511 (W 0.00235883) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.8579 ± 0.17943 (W 0.189137) | 17.8683 ± 0.0338553 (W 0.163607) | 11.2614 ± 0.0386158 (W 0.0787078) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.155999 ± 0.00333889 (W 0.00276617) | 0.182367 ± 0.00279215 (W 0.0030572) | - | 🔵 fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.155267 ± 0.00605708 (W 0.00282676) | 0.179772 ± 0.00329161 (W 0.00242785) | - | 🔵 fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.62521 ± 0.128569 (W 0.790061) | 6.90504 ± 0.0601502 (W 0.50458) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.64881 ± 0.0702302 (W 0.101508) | 6.93602 ± 1.27193 (W 0.811161) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.32238 ± 0.00471918 (W 0.024546) | 1.92476 ± 0.0236833 (W 0.0193742) | 0.844111 ± 0.00234413 (W 0.00334022) | 🔵 fork 1.46× faster than `faer-upstream` | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 20.3161 ± 2.73316 (W 0.404402) | 30.0026 ± 2.62692 (W 0.749416) | 19.3311 ± 0.04018 (W 0.0357658) | 🔵 fork 1.48× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.05972 ± 0.00235866 (W 0.011204) | 1.67978 ± 0.0118485 (W 0.0157187) | 0.299715 ± 0.000907812 (W 0.00254925) | 🔵 fork 1.59× faster than `faer-upstream` | 🔴 fork 3.54× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.7141 ± 0.0526319 (W 0.0476007) | 19.6509 ± 0.132819 (W 0.158623) | 6.50584 ± 0.0335638 (W 0.0572502) | 🔵 fork 1.68× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/1024x64`, `householder_apply/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
