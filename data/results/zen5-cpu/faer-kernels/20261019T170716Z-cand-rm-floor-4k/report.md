# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `30b4fde4f49cd760c421d7b1dd0855a4d9af9787`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `6e2afddbaf8e59006f66257641a4928ecb8c1569`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `cb28b8103eca9d14565dc5cc5f1a1f9d1b3f7609b96f17c4c81c8581f4fbd476`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T17:17:53.475347Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small --threads 4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label cand-rm-floor-4k --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261019T170716Z-cand-rm-floor-4k/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.11%, worst 1570.82% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 116 of 768 engine cells exceed 5% and carry `!`; median within-process relative SD 0.79%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003517 ± 0.000185284 (W 2.40687e-05) | 0.003406 ± 4.04145e-05 (W 4.11376e-05) | 0.004178 ± 7.50555e-05 (W 8.40833e-05) | · | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.012283 ± 0.00284027 (W 3.97492e-05) | 0.016581 ± 0.000217601 (W 5.80517e-05) | 0.016932 ± 7.89958e-05 (W 5.77607e-05) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049352 ± 0.00294596 (W 0.000936158) | 0.060924 ± 0.000890942 (W 0.00393148) | 0.048471 ± 0.000202237 (W 0.000163094) | 🔵 fork 1.23× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113442 ± 0.000691386 (W 0.0013314) | 0.112511 ± 0.000280571 (W 0.00105611) | 0.105487 ± 0.000239321 (W 0.00126061) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.505546 ± 0.00646953 (W 0.00590877) | 0.501089 ± 0.00555752 (W 0.00324863) | 0.273492 ± 0.000927864 (W 0.00176007) | · | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21931 ± 0.00528974 (W 0.0212108) | 1.21682 ± 0.00433769 (W 0.0127417) | 0.594753 ± 0.00280617 (W 0.00296116) | · | 🔴 fork 2.05× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011632 ± 0.000194679 (W 7.70065e-05) | 0.0108 ± 0.000340735 (W 4.95399e-05) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051046 ± 6.245e-05 (W 0.000127044) | 0.046868 ± 0.000285879 (W 0.00012836) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144581 ± 0.000935605 (W 0.00297547) | 0.13372 ± 0.000475322 (W 0.00230374) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008186 ± 6.18897e-05 (W 3.7085e-05) | 0.008286 ± 0.000173494 (W 7.88999e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008226 ± 1.21244e-05 (W 5.08458e-05) | 0.008276 ± 4.16333e-05 (W 9.09962e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.025057 ± 0.000326492 (W 0.00127237) | 0.024055 ± 0.000551907 (W 0.00108485) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.024966 ± 0.000385072 (W 0.000525219) | 0.025198 ± 0.000688558 (W 0.000814199) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049913 ± 0.000123843 (W 0.000338458) | 0.050635 ± 0.000370515 (W 0.000716688) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.050374 ± 0.000594646 (W 0.000588829) | 0.051337 ± 0.000634872 (W 0.00117983) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008756 ± 0.000227025 (W 6.45693e-05) | 0.007334 ± 8.66622e-05 (W 6.10737e-05) | 0.012413 ± 0.000133493 (W 7.21471e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030838 ± 0.000283455 (W 0.00023515) | 0.044072 ± 0.000280416 (W 0.00376252) | 0.043191 ± 0.000229129 (W 0.00200294) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075932 ± 0.000298532 (W 0.00208471) | 0.105387 ± 0.00229241 (W 0.00293182) | 0.093285 ± 0.000568066 (W 0.000357905) | 🔵 fork 1.39× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.032691 ± 0.000215686 (W 0.000189244) | 0.1073 ± 0.00784889 (W 0.00589854) | 0.026189 ± 0.0336416 (W 0.00132649) | 🔵 fork 3.28× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.172232 ± 0.00116782 (W 0.00280523) | 0.489135 ± 0.00147601 (W 0.0114768) | 0.145884 ± 0.000685573 (W 0.00157015) | 🔵 fork 2.84× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.383188 ± 0.0181556 (W 0.0249986) | 1.04678 ± 0.0506014 (W 0.021575) | 0.333163 ± 0.00253415 (W 0.00323705) | 🔵 fork 2.73× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023714 ± 5.61278e-05 (W 9.66757e-05) | 0.094046 ± 0.00336881 (W 0.00377595) | 0.014097 ± 2.25167e-05 (W 6.68154e-05) | 🔵 fork 3.97× faster than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.108293 ± 0.00049266 (W 0.00126535) | 0.468778 ± 0.00777765 (W 0.0109176) | 0.298629 ± 0.134148 (W 0.00153816) | 🔵 fork 4.33× faster than `faer-upstream` | 🔵 fork 2.76× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.220463 ± 0.00204859 (W 0.00332062) | 0.987191 ± 0.0239026 (W 0.011042) | 0.943486 ± 0.00177011 (W 0.000538649) | 🔵 fork 4.48× faster than `faer-upstream` | 🔵 fork 4.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009728 ± 8.7178e-05 (W 5.49545e-05) | 0.008185 ± 0.000111355 (W 4.3359e-05) | 0.012884 ± 4.72582e-05 (W 6.09918e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031899 ± 0.000496435 (W 0.000815133) | 0.045355 ± 0.00429446 (W 0.00143626) | 0.043641 ± 5.5109e-05 (W 0.00015763) | 🔵 fork 1.42× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n96/b1` | 0.077685 ± 0.0001155 (W 0.00137062) | 0.107181 ± 0.000300888 (W 0.00285877) | 0.087443 ± 0.000173517 (W 0.00128863) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.182722 ± 0.000674364 (W 0.00135394) | 0.183554 ± 0.000884334 (W 0.00134115) | 0.184606 ± 0.000235153 (W 0.0014475) | · | · |  |
| `svd_thin/n64/b1` | 0.950058 ± 0.00200967 (W 0.00494329) | 0.952954 ± 0.00273365 (W 0.0031188) | 0.667751 ± 0.000707937 (W 0.00569256) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.33189 ± 0.0365148 (W 0.0189559) | 2.27447 ± 0.0370474 (W 0.0130494) | 1.41188 ± 0.0501297 (W 0.00394496) | · | 🔴 fork 1.65× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140634 ± 4.03361e-05 (W 0.000147065) | 0.140012 ± 0.000293207 (W 0.00140487) | 0.06436 ± 0.0430586 (W 0.00108923) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.516819 ± 0.00141859 (W 0.00176502) | 0.516116 ± 0.00116839 (W 0.00183653) | 0.269925 ± 0.000419476 (W 0.001614) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18352 ± 0.00279822 (W 0.00185239) | 1.18647 ± 0.00493274 (W 0.0019716) | 0.606375 ± 0.0015209 (W 0.00199971) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000662 ± 5.7735e-06 (W 8.78635e-06) | 0.000662 ± 1.12694e-05 (W 1.50732e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001472 ± 3.23574e-05 (W 1.34164e-05) | 0.001463 ± 1.0504e-05 (W 1.67332e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002585 ± 1.52753e-05 (W 2.64575e-05) | 0.002595 ± 2.88675e-05 (W 4e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003246 ± 0.000147988 (W 2.08638e-05) | 0.003437 ± 4.07063e-05 (W 2.99717e-05) | 0.004117 ± 2.60832e-05 (W 3.18795e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014978 ± 0.00123122 (W 5.55275e-05) | 0.016481 ± 5.1316e-05 (W 5.89932e-05) | 0.016892 ± 0.000145717 (W 9.36712e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.059372 ± 0.00573352 (W 0.00335679) | 0.072215 ± 0.00601253 (W 0.00173014) | 0.048531 ± 0.000160935 (W 0.000173581) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113071 ± 0.000275645 (W 0.000304379) | 0.112892 ± 0.000301631 (W 0.000221678) | 0.1069 ± 0.000468032 (W 0.00114955) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.509725 ± 0.00311925 (W 0.00353508) | 0.508042 ± 0.00182749 (W 0.00379404) | 0.263484 ± 0.001172 (W 0.00195742) | · | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.2538 ± 0.0134425 (W 0.0278029) | 1.246 ± 0.0179993 (W 0.0186676) | 0.577591 ± 0.00337034 (W 0.00230186) | · | 🔴 fork 2.17× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011662 ± 0.000174738 (W 7.29328e-05) | 0.01052 ± 0.000439819 (W 0.000115954) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051326 ± 0.000351711 (W 0.000256034) | 0.047148 ± 0.000298604 (W 0.000158916) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.14392 ± 0.00156361 (W 0.00260963) | 0.134512 ± 0.00282622 (W 0.00269777) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008155 ± 4.09919e-05 (W 3.56371e-05) | 0.008396 ± 2e-05 (W 6.02594e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008246 ± 2.08167e-05 (W 3.74206e-05) | 0.008336 ± 7.63763e-05 (W 0.000100081) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020488 ± 0.000658353 (W 0.000580085) | 0.028203 ± 0.000455632 (W 0.00179342) | - | 🔵 fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.02132 ± 0.000764874 (W 0.000185338) | 0.027842 ± 0.000942844 (W 0.00174611) | - | 🔵 fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.038041 ± 0.000287855 (W 0.000747544) | 0.062878 ± 0.000381699 (W 0.00166597) | - | 🔵 fork 1.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.039203 ± 0.016513 (W 0.00123387) | 0.062257 ± 0.00105035 (W 0.00133593) | - | 🔵 fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.008616 ± 4e-05 (W 3.73256e-05) | 0.007223 ± 3.05505e-05 (W 5.86788e-05) | 0.012353 ± 0.000146289 (W 7.56968e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030938 ± 0.00023767 (W 0.000144042) | 0.049643 ± 0.00205046 (W 0.00325746) | 0.042931 ± 0.000117304 (W 0.00120803) | 🔵 fork 1.60× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.076163 ± 0.000514083 (W 0.00221656) | 0.116669 ± 0.00480123 (W 0.00326092) | 0.085961 ± 0.00299408 (W 0.00168649) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n32/b1` | 0.032811 ± 0.000362542 (W 0.000139378) | 0.143419 ± 0.00246992 (W 0.00421723) | 0.026349 ± 0.0338734 (W 0.000117984) | 🔵 fork 4.37× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.162114 ± 0.000942917 (W 0.00268248) | 0.673001 ± 0.0109548 (W 0.0212209) | 0.158236 ± 0.000240069 (W 0.0010236) | 🔵 fork 4.15× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.403676 ± 0.0110345 (W 0.0143374) | 1.43838 ± 0.0459955 (W 0.0319005) | 0.338443 ± 0.00734524 (W 0.00260942) | 🔵 fork 3.56× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023764 ± 9.88956e-05 (W 0.000117585) | 0.125565 ± 0.00245634 (W 0.00679582) | 0.014037 ± 7.0713e-05 (W 7.59355e-05) | 🔵 fork 5.28× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.111419 ± 0.000716507 (W 0.00197025) | 0.636781 ± 0.00940465 (W 0.0129224) | 0.29867 ± 0.134095 (W 0.00158572) | 🔵 fork 5.72× faster than `faer-upstream` | 🔵 fork 2.68× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.212739 ± 0.000864236 (W 0.00281034) | 1.32217 ± 0.0284266 (W 0.0242889) | 0.94009 ± 0.000677599 (W 0.000487177) | 🔵 fork 6.21× faster than `faer-upstream` | 🔵 fork 4.42× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009628 ± 0.00015695 (W 5.31977e-05) | 0.008356 ± 0.000102632 (W 5.30782e-05) | 0.012754 ± 3.66106e-05 (W 3.57113e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.03217 ± 0.000579576 (W 0.000104868) | 0.052518 ± 0.00243641 (W 0.0030706) | 0.043471 ± 4.6188e-05 (W 0.000154251) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077275 ± 0.00493365 (W 0.00174408) | 0.115867 ± 0.00464203 (W 0.0040688) | 0.08549 ± 0.00122403 (W 0.000226626) | 🔵 fork 1.50× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.183463 ± 3.82143e-05 (W 0.00265823) | 0.183223 ± 0.000515326 (W 0.0012534) | 0.18712 ± 0.000973333 (W 0.00156407) | · | · |  |
| `svd_thin/n64/b1` | 0.963646 ± 0.00393147 (W 0.00267935) | 0.965498 ± 0.00289498 (W 0.00363041) | 0.663291 ± 0.00252661 (W 0.00490382) | · | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32846 ± 0.0419359 (W 0.0217854) | 2.31637 ± 0.0462221 (W 0.0200799) | 1.36014 ± 0.0464724 (W 0.00751317) | · | 🔴 fork 1.71× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140613 ± 0.000417378 (W 0.0017849) | 0.140613 ± 0.000456404 (W 0.001146) | 0.064321 ± 0.042922 (W 0.00132251) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.521627 ± 0.00227099 (W 0.00213947) | 0.51828 ± 0.00134407 (W 0.00167332) | 0.270647 ± 0.00082483 (W 0.00152256) | · | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19029 ± 0.0052874 (W 0.00197693) | 1.18656 ± 0.00650411 (W 0.00207515) | 0.59813 ± 0.000769806 (W 0.00227287) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 2.70247e-05 (W 2.18701e-05) | 0.000671 ± 5.7735e-06 (W 8.3666e-06) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001513 ± 1.21244e-05 (W 1.78885e-05) | 0.001462 ± 3.17857e-05 (W 1.20499e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002665 ± 8.06866e-05 (W 2.48998e-05) | 0.002554 ± 1.52753e-05 (W 3.56371e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003106 ± 0.000316329 (W 4.13195e-05) | 0.003336 ± 3.05014e-05 (W 2.39019e-05) | 0.003396 ± 1e-05 (W 2.9416e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014537 ± 0.002405 (W 4.3014e-05) | 0.0164 ± 0.000111312 (W 2.34521e-05) | 0.014217 ± 0.000195517 (W 0.000107048) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.047759 ± 0.00379654 (W 0.00280912) | 0.060864 ± 0.000925969 (W 0.00272812) | 0.037971 ± 0.000106397 (W 0.00146883) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.112851 ± 0.000477441 (W 0.00132722) | 0.112621 ± 0.000331326 (W 0.00144262) | 0.103895 ± 5.52298e-05 (W 0.00102298) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.502762 ± 0.00208025 (W 0.0032978) | 0.501729 ± 0.000413523 (W 0.00282438) | 0.2672 ± 0.000170998 (W 0.0020309) | · | 🔴 fork 1.88× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21929 ± 0.0131419 (W 0.017928) | 1.21353 ± 0.00331307 (W 0.0223645) | 0.581499 ± 0.00214029 (W 0.00303773) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010399 ± 5e-05 (W 6.30079e-05) | 0.011011 ± 0.000367071 (W 9.39159e-05) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045956 ± 0.000119304 (W 0.00124269) | 0.046578 ± 0.000529161 (W 0.000168908) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132618 ± 0.000682721 (W 0.00267845) | 0.132037 ± 0.000357385 (W 0.00196114) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008176 ± 8.07486e-05 (W 5.81833e-05) | 0.008436 ± 4.39356e-05 (W 6.69343e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008246 ± 6.02522e-05 (W 5.12269e-05) | 0.008466 ± 4.93288e-05 (W 6.69328e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.029746 ± 0.00318336 (W 0.00316401) | 0.024556 ± 0.00438215 (W 0.000916019) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.035366 ± 0.00432651 (W 0.00117821) | 0.024406 ± 0.000418219 (W 0.000825159) | - | 🔴 fork 1.45× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.059942 ± 0.000216049 (W 0.000758998) | 0.050514 ± 0.00143048 (W 0.00121123) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060394 ± 0.000452447 (W 0.00270221) | 0.050143 ± 0.00153737 (W 0.00152191) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007394 ± 0.000110726 (W 0.00010594) | 0.007163 ± 7.16961e-05 (W 0.000131538) | 0.009698 ± 5.03322e-05 (W 5.66057e-05) | · | 🔵 fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025898 ± 0.000349996 (W 0.000149128) | 0.043462 ± 0.00167665 (W 0.00197943) | 0.033452 ± 9.31504e-05 (W 0.000110029) | 🔵 fork 1.68× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063629 ± 0.000126623 (W 0.00212378) | 0.099697 ± 0.000430647 (W 0.00252545) | 0.07478 ± 0.00021362 (W 0.00154382) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031078 ± 3.21455e-05 (W 0.000227485) | 0.108463 ± 0.00300954 (W 0.00485744) | 0.021179 ± 0.000185032 (W 0.00014398) | 🔵 fork 3.49× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.142727 ± 0.0046508 (W 0.00288126) | 0.485198 ± 0.00672762 (W 0.00695127) | 0.126827 ± 0.000677173 (W 0.00148645) | 🔵 fork 3.40× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.367949 ± 0.010879 (W 0.0157179) | 1.04411 ± 0.0364228 (W 0.0165491) | 0.29383 ± 0.000914879 (W 0.00248309) | 🔵 fork 2.84× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017653 ± 0.000153657 (W 8.04195e-05) | 0.08 ± 0.0029325 (W 0.00367061) | 0.011502 ± 5.61278e-05 (W 4.89898e-05) | 🔵 fork 4.53× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.103343 ± 0.00941488 (W 0.00851747) | 0.422391 ± 0.00649512 (W 0.0129323) | 0.289643 ± 5.0797e-05 (W 0.00181641) | 🔵 fork 4.09× faster than `faer-upstream` | 🔵 fork 2.80× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.192701 ± 0.00136876 (W 0.00299124) | 0.864179 ± 0.0102609 (W 0.0164085) | 0.930043 ± 0.00145853 (W 0.000794595) | 🔵 fork 4.48× faster than `faer-upstream` | 🔵 fork 4.83× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007884 ± 4.96689e-05 (W 4.4025e-05) | 0.007925 ± 0.000136346 (W 0.000104256) | 0.009798 ± 6.71342e-05 (W 5.27276e-05) | · | 🔵 fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026499 ± 0.000354284 (W 5.09333e-05) | 0.044122 ± 0.000664002 (W 0.00285055) | 0.033703 ± 8.47604e-05 (W 8.75785e-05) | 🔵 fork 1.67× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065593 ± 0.000187094 (W 0.000197275) | 0.101991 ± 0.00254992 (W 0.00555393) | 0.073608 ± 0.000324916 (W 0.00156225) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.185828 ± 0.000640709 (W 0.00116821) | 0.184926 ± 0.000788334 (W 0.00159958) | 0.175749 ± 0.00051304 (W 0.00099417) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.996858 ± 0.00305408 (W 0.00380287) | 0.996827 ± 0.00119542 (W 0.00159926) | 0.641541 ± 0.00308166 (W 0.00152538) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.3329 ± 0.0271233 (W 0.00949724) | 2.30575 ± 0.0190366 (W 0.0244342) | 1.37311 ± 0.00299255 (W 0.00335024) | · | 🔴 fork 1.70× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142066 ± 0.000466163 (W 0.000217369) | 0.142026 ± 0.00017088 (W 0.00122556) | 0.059231 ± 0.000177907 (W 0.00113832) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536706 ± 0.0012088 (W 0.00223204) | 0.536505 ± 0.0011784 (W 0.00193457) | 0.258754 ± 0.000427949 (W 0.002635) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19484 ± 0.00382698 (W 0.00226204) | 1.19183 ± 0.00349316 (W 0.002342) | 0.602759 ± 0.000926359 (W 0.00174327) | · | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000762 ± 2.04206e-05 (W 4.27785e-06) | 0.000742 ± 2.28108e-05 (W 1.68908e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001814 ± 5.22526e-05 (W 2.37318e-05) | 0.001813 ± 7e-05 (W 2.68552e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003105 ± 3.10966e-05 (W 2.77489e-05) | 0.003116 ± 2.51661e-05 (W 3.28634e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003056 ± 0.000311 (W 3.57771e-05) | 0.003296 ± 3.51188e-05 (W 2.77489e-05) | 0.003366 ± 2.64575e-05 (W 1.05972e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014457 ± 0.00192733 (W 5.75178e-05) | 0.01612 ± 6.65833e-05 (W 3.04959e-05) | 0.013866 ± 3.05505e-05 (W 5.54977e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056595 ± 0.0041529 (W 0.0029842) | 0.072827 ± 0.00110764 (W 0.00128486) | 0.038101 ± 0.000170587 (W 9.39681e-05) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113102 ± 0.000553285 (W 0.000159462) | 0.113413 ± 0.000700666 (W 0.000184104) | 0.104626 ± 0.000176627 (W 0.000475842) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.51335 ± 0.00297398 (W 0.00511947) | 0.505206 ± 0.00450992 (W 0.00469932) | 0.257422 ± 0.00106 (W 0.00167096) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.24409 ± 0.0299513 (W 0.0178964) | 1.25074 ± 0.00567415 (W 0.0158647) | 0.566161 ± 0.0013454 (W 0.0021915) | · | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010459 ± 0.000266721 (W 6.21796e-05) | 0.01056 ± 2.08167e-05 (W 6.6598e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046026 ± 0.000578225 (W 0.00026264) | 0.045796 ± 0.000200749 (W 0.000304617) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132388 ± 0.00304117 (W 0.00258914) | 0.131055 ± 0.00317287 (W 0.00234382) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008115 ± 5.50757e-05 (W 3.04959e-05) | 0.008405 ± 4.74377e-05 (W 8.65523e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008226 ± 6.89952e-05 (W 3.34544e-05) | 0.008556 ± 5.50757e-05 (W 0.000101638) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.028373 ± 0.000353329 (W 0.00158809) | 0.027742 ± 0.000596007 (W 0.0012763) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.028032 ± 0.000663567 (W 0.00117112) | 0.028243 ± 0.000853822 (W 0.00105302) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049854 ± 0.00373465 (W 0.00395967) | 0.062727 ± 0.000670584 (W 0.0019837) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.049683 ± 0.00320211 (W 0.00372268) | 0.062277 ± 0.00149199 (W 0.00180138) | - | 🔵 fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007184 ± 0.000149701 (W 0.000108514) | 0.007043 ± 8.14453e-05 (W 3.31994e-05) | 0.009688 ± 5.1316e-05 (W 6.32456e-05) | · | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025718 ± 0.000144212 (W 0.000123605) | 0.051276 ± 0.00160512 (W 0.00321693) | 0.033613 ± 0.000157735 (W 8.9768e-05) | 🔵 fork 1.99× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063278 ± 0.0019235 (W 0.00226089) | 0.113833 ± 0.00342037 (W 0.00663138) | 0.074159 ± 0.000196088 (W 0.00183142) | 🔵 fork 1.80× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031359 ± 0.0002705 (W 0.000161802) | 0.144791 ± 0.00333276 (W 0.00456796) | 0.021149 ± 0.000190553 (W 0.00012198) | 🔵 fork 4.62× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.14941 ± 0.00250972 (W 0.00271043) | 0.668321 ± 0.0185669 (W 0.0238912) | 0.139531 ± 0.000556607 (W 0.00142954) | 🔵 fork 4.47× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.383077 ± 0.016878 (W 0.0133781) | 1.41884 ± 0.0189842 (W 0.0226622) | 0.307707 ± 0.0021076 (W 0.00182405) | 🔵 fork 3.70× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017683 ± 7.09295e-05 (W 6.33735e-05) | 0.114945 ± 0.00319092 (W 0.00418383) | 0.011581 ± 0.000114282 (W 0.000162082) | 🔵 fork 6.50× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.092854 ± 0.000202978 (W 0.00124126) | 0.578923 ± 0.0172794 (W 0.0261688) | 0.289422 ± 0.000528284 (W 0.00183246) | 🔵 fork 6.23× faster than `faer-upstream` | 🔵 fork 3.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.188212 ± 0.00155375 (W 0.00211755) | 1.17469 ± 10.6419 (W 0.0426491) | 0.931044 ± 0.00242893 (W 0.00107067) | · | 🔵 fork 4.95× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.007804 ± 0.000136236 (W 0.000109664) | 0.007885 ± 0.000186388 (W 4.9295e-05) | 0.009858 ± 9.0185e-05 (W 0.000109331) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026099 ± 0.000247588 (W 0.000182785) | 0.052518 ± 0.00282382 (W 0.00415141) | 0.033312 ± 3.45977e-05 (W 6.25883e-05) | 🔵 fork 2.01× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065012 ± 0.00335326 (W 0.00239803) | 0.113933 ± 0.00341599 (W 0.00771033) | 0.073668 ± 0.000207172 (W 0.000119666) | 🔵 fork 1.75× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.185488 ± 0.000576097 (W 0.0011987) | 0.185428 ± 0.00124208 (W 0.00171041) | 0.177843 ± 0.000493158 (W 0.00118487) | · | · |  |
| `svd_thin/n64/b1` | 1.00861 ± 0.00206502 (W 0.00220105) | 1.01208 ± 0.00611886 (W 0.00319721) | 0.632374 ± 0.00201183 (W 0.00379101) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31892 ± 0.0320239 (W 0.019678) | 2.33902 ± 0.0311937 (W 0.0152525) | 1.32808 ± 0.00636485 (W 0.00199143) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142206 ± 0.000658879 (W 0.00131435) | 0.142437 ± 0.000722615 (W 0.00144298) | 0.059291 ± 0.000112694 (W 0.00012324) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536274 ± 0.00119451 (W 0.00315345) | 0.538989 ± 0.00143435 (W 0.00222182) | 0.258153 ± 0.000817129 (W 0.00158722) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19174 ± 0.00336111 (W 0.00230918) | 1.19014 ± 0.00432478 (W 0.00179664) | 0.598351 ± 0.000581585 (W 0.00237903) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000772 ± 1.70392e-05 (W 1.65015e-05) | 0.000731 ± 3.4641e-05 (W 1.63799e-05) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001833 ± 8.92767e-05 (W 2.07364e-05) | 0.001713 ± 5.68624e-05 (W 2.59673e-05) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003096 ± 0.000153353 (W 2.23607e-05) | 0.003096 ± 0.000168028 (W 2.94958e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00526 ± 4.41626e-05 (W 4.60467e-05) | 0.005229 ± 1.53948e-05 (W 3.27109e-05) | 0.008766 ± 0.000172357 (W 5.85517e-05) | · | 🔵 fork 1.67× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029986 ± 0.000426244 (W 0.000149671) | 0.030267 ± 0.000151438 (W 0.000129923) | 0.050755 ± 0.000650525 (W 0.000453112) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.104245 ± 0.00119663 (W 0.00116858) | 0.103845 ± 0.00116784 (W 0.00234445) | 0.139411 ± 0.00108055 (W 0.00036862) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141635 ± 0.000316986 (W 0.0014915) | 0.142297 ± 0.000298614 (W 0.00121262) | 0.155792 ± 0.000561847 (W 0.00166784) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.639418 ± 0.00100544 (W 0.00335619) | 0.64069 ± 0.00142966 (W 0.003931) | 0.567393 ± 0.000986862 (W 0.00190127) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.55206 ± 0.0109154 (W 0.00974249) | 1.5528 ± 0.00791177 (W 0.0138296) | 1.16159 ± 0.0744877 (W 0.00511147) | · | 🔴 fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017483 ± 0.000144684 (W 9.71082e-05) | 0.01586 ± 0.000223943 (W 6.85142e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096952 ± 0.000327522 (W 0.00139914) | 0.091932 ± 7.14866e-05 (W 0.00170811) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.278421 ± 0.000188486 (W 0.00148408) | 0.266669 ± 0.000569608 (W 0.00206581) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027982 ± 5.19615e-06 (W 8.56756e-05) | 0.028313 ± 0.000163127 (W 0.000180774) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028132 ± 0.000160894 (W 4.39318e-05) | 0.028604 ± 9.02053e-05 (W 8.31703e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.065813 ± 0.000441038 (W 0.00056535) | 0.067036 ± 0.00055196 (W 0.0100355) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.065954 ± 0.00039223 (W 0.000897125) | 0.068849 ± 0.00347209 (W 0.00395325) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.155801 ± 0.00105449 (W 0.000881866) | 0.158127 ± 0.00177911 (W 0.00176355) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.156333 ± 0.00177661 (W 0.00202067) | 0.157545 ± 0.00113237 (W 0.00169165) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013165 ± 0.000196088 (W 7.45466e-05) | 0.011041 ± 0.000132138 (W 3.21916e-05) | 0.019837 ± 5.85947e-05 (W 9.0461e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057488 ± 0.000323585 (W 0.000206852) | 0.052829 ± 0.00125017 (W 0.000864304) | 0.095449 ± 0.000503738 (W 0.000388391) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.150662 ± 0.000412868 (W 0.000403148) | 0.153648 ± 0.000169766 (W 0.00159628) | 0.243727 ± 0.00120779 (W 0.00125638) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.069881 ± 0.0004001 (W 0.00126054) | 0.158016 ± 0.0114674 (W 0.0201682) | 0.05332 ± 0.0900418 (W 0.00127316) | 🔵 fork 2.26× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.295784 ± 0.00149483 (W 0.00421872) | 0.665988 ± 0.0100683 (W 0.0214377) | 0.306213 ± 0.00110262 (W 0.00177632) | 🔵 fork 2.25× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.614882 ± 0.0475588 (W 0.00384677) | 1.33606 ± 0.0365418 (W 0.0157386) | 0.767328 ± 0.0017773 (W 0.00176739) | 🔵 fork 2.17× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.040726 ± 0.000281052 (W 0.00101238) | 0.110907 ± 0.00302007 (W 0.00349871) | 0.028734 ± 0.000108167 (W 6.0663e-05) | 🔵 fork 2.72× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.184115 ± 0.0209648 (W 0.00345401) | 0.607357 ± 0.00453238 (W 0.00720912) | 0.761607 ± 0.346223 (W 0.0014945) | 🔵 fork 3.30× faster than `faer-upstream` | 🔵 fork 4.14× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.402774 ± 0.0195467 (W 0.0179716) | 1.15585 ± 0.0336128 (W 0.016706) | 2.45585 ± 0.00421119 (W 0.00374876) | 🔵 fork 2.87× faster than `faer-upstream` | 🔵 fork 6.10× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.014227 ± 7.59408e-05 (W 5.36777e-05) | 0.012393 ± 4.17971e-05 (W 5.9349e-05) | 0.020298 ± 9.53939e-05 (W 6.41872e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059331 ± 0.000380142 (W 0.000154477) | 0.054613 ± 0.000165581 (W 0.000108606) | 0.093505 ± 0.000331362 (W 0.00114543) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.154119 ± 0.000465575 (W 0.00157638) | 0.157425 ± 0.000762192 (W 0.00151782) | 0.236844 ± 0.00497158 (W 0.00170303) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.235762 ± 0.0030666 (W 0.00158097) | 0.235672 ± 0.00503575 (W 0.00137851) | 0.260819 ± 0.000880122 (W 0.0014313) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20121 ± 0.00210146 (W 0.00272139) | 1.20292 ± 0.00175262 (W 0.00297544) | 1.03259 ± 0.00075772 (W 0.0018678) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.99798 ± 0.00295267 (W 0.0279392) | 2.99162 ± 0.0310496 (W 0.0268752) | 2.5248 ± 0.00389701 (W 0.00297652) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.1604 ± 0.00085829 (W 0.00114212) | 0.161984 ± 0.000782713 (W 0.00148693) | 0.102583 ± 0.122414 (W 0.00166373) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.649838 ± 0.00113133 (W 0.00214683) | 0.649516 ± 0.00151704 (W 0.00542509) | 0.490769 ± 0.00257641 (W 0.00188386) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51399 ± 0.00717402 (W 0.00327888) | 1.50455 ± 0.00951085 (W 0.00228166) | 1.35764 ± 0.00300629 (W 0.00179143) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 2.12211e-05 (W 1.48324e-05) | 0.001072 ± 5.7735e-06 (W 1.30384e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002675 ± 1.73205e-05 (W 2.40832e-05) | 0.002675 ± 2.08167e-05 (W 3.34664e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004919 ± 4.09512e-05 (W 2.12132e-05) | 0.004909 ± 3.78594e-05 (W 2.05718e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00518 ± 3e-05 (W 4.27785e-05) | 0.00526 ± 1.52753e-05 (W 0.00015844) | 0.008817 ± 0.000145523 (W 8.23972e-05) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030146 ± 0.00017674 (W 7.32953e-05) | 0.030346 ± 6.55769e-05 (W 9.56781e-05) | 0.050795 ± 0.00112537 (W 0.000219067) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.113172 ± 0.00072039 (W 0.00323881) | 0.1123 ± 0.000577342 (W 0.00119261) | 0.140604 ± 0.00127817 (W 0.000721213) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141886 ± 0.000441426 (W 0.00125566) | 0.142707 ± 0.00064993 (W 0.00160784) | 0.156844 ± 0.0005815 (W 0.00141432) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.645259 ± 0.00293396 (W 0.00363067) | 0.647663 ± 0.00223314 (W 0.00454444) | 0.541223 ± 0.000780533 (W 0.00218779) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54054 ± 0.00188952 (W 0.0164629) | 1.59638 ± 0.0035262 (W 0.0114378) | 1.04118 ± 0.00233573 (W 0.00146166) | · | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017583 ± 0.000285132 (W 0.000100349) | 0.0157 ± 0.000110092 (W 0.000104748) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097091 ± 0.000352534 (W 0.00160483) | 0.091862 ± 0.000380667 (W 0.00151231) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.279152 ± 0.000834395 (W 0.00205748) | 0.26703 ± 0.00071091 (W 0.00221706) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027943 ± 3.05505e-05 (W 0.000106284) | 0.028253 ± 0.000107503 (W 8.52836e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028042 ± 8.12219e-05 (W 6.61612e-05) | 0.028523 ± 0.000212619 (W 0.000130339) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.043231 ± 0.000560696 (W 0.000796494) | 0.072045 ± 0.00125313 (W 0.00212804) | - | 🔵 fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.043 ± 0.000324594 (W 0.000284137) | 0.072426 ± 0.000611377 (W 0.00271361) | - | 🔵 fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.092133 ± 0.000165802 (W 0.00155586) | 0.163987 ± 0.00152397 (W 0.00224312) | - | 🔵 fork 1.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.091932 ± 0.000816714 (W 0.00120218) | 0.161703 ± 0.000370824 (W 0.00168333) | - | 🔵 fork 1.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013235 ± 0.000147852 (W 0.000126069) | 0.01099 ± 9.50631e-05 (W 6.39085e-05) | 0.019887 ± 3.45977e-05 (W 0.000114866) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057788 ± 0.000342288 (W 0.00163681) | 0.052448 ± 0.000202806 (W 0.000348956) | 0.09605 ± 0.000957508 (W 0.000402892) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.150121 ± 0.000696296 (W 0.00156474) | 0.166251 ± 0.000163464 (W 0.00321784) | 0.243977 ± 0.000619377 (W 0.0013325) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070301 ± 0.000231128 (W 0.000253436) | 0.184786 ± 0.00476328 (W 0.00946744) | 0.05328 ± 0.0905043 (W 0.000104738) | 🔵 fork 2.63× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.314759 ± 0.00584239 (W 0.00383697) | 0.887412 ± 0.0116505 (W 0.0160881) | 0.285375 ± 0.000317065 (W 0.00233135) | 🔵 fork 2.82× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.622616 ± 0.0175605 (W 0.0105336) | 1.70681 ± 0.0221419 (W 0.032218) | 0.704409 ± 0.000506005 (W 0.00194008) | 🔵 fork 2.74× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.040767 ± 0.000282064 (W 0.000126895) | 0.141374 ± 0.00323987 (W 0.00342549) | 0.028804 ± 8.5049e-05 (W 0.00157336) | 🔵 fork 3.47× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.18173 ± 0.00182142 (W 0.00244405) | 0.783417 ± 0.00464391 (W 0.0171651) | 0.762759 ± 0.346462 (W 0.00205948) | 🔵 fork 4.31× faster than `faer-upstream` | 🔵 fork 4.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.392013 ± 0.00507107 (W 0.00529319) | 1.5332 ± 0.0216561 (W 0.0214048) | 2.46191 ± 0.00253293 (W 0.00306193) | 🔵 fork 3.91× faster than `faer-upstream` | 🔵 fork 6.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014217 ± 7.2111e-05 (W 9.01238e-05) | 0.012303 ± 9.33292e-05 (W 5.85662e-05) | 0.020248 ± 3.51188e-05 (W 7.46358e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059642 ± 0.000115326 (W 0.000120877) | 0.054371 ± 0.000172871 (W 0.00194351) | 0.093275 ± 0.000322306 (W 0.000414964) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.153968 ± 0.000613567 (W 0.00158684) | 0.168015 ± 0.000667325 (W 0.00422284) | 0.237344 ± 0.000541184 (W 0.00150919) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.23523 ± 0.00088787 (W 0.00156962) | 0.237885 ± 0.00201396 (W 0.00186528) | 0.263193 ± 0.00178479 (W 0.00196339) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20887 ± 0.00417286 (W 0.00376202) | 1.22069 ± 0.0035569 (W 0.0053327) | 0.996604 ± 0.00350237 (W 0.00278384) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96527 ± 0.00448508 (W 0.0331293) | 3.0964 ± 0.00820272 (W 0.0155262) | 2.35382 ± 0.00117672 (W 0.00326697) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.160531 ± 0.000512056 (W 0.000408934) | 0.161943 ± 0.000379285 (W 0.00048307) | 0.102582 ± 0.121968 (W 0.00015056) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.652762 ± 0.00107936 (W 0.00287885) | 0.651901 ± 0.00223354 (W 0.0023278) | 0.49194 ± 0.00392498 (W 0.00179514) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50688 ± 0.00180386 (W 0.00343314) | 1.50899 ± 0.00100984 (W 0.00216173) | 1.35901 ± 0.00544147 (W 0.00225815) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 1.52753e-05 (W 2.50998e-05) | 0.001082 ± 2.51661e-05 (W 2.34521e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 7.50555e-05 (W 3.70702e-05) | 0.002705 ± 2.08167e-05 (W 3.03315e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0049 ± 3.01164e-05 (W 2.95161e-05) | 0.004909 ± 1e-05 (W 2.34521e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00518 ± 0.000140119 (W 3.60042e-05) | 0.00519 ± 3.78594e-05 (W 4.61519e-05) | 0.007875 ± 0.000100167 (W 8.1426e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029886 ± 0.000408375 (W 6.29142e-05) | 0.029805 ± 0.000125341 (W 4.83042e-05) | 0.043371 ± 0.000507978 (W 0.000158162) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103013 ± 0.000271932 (W 0.000682059) | 0.102603 ± 0.00124591 (W 0.000981257) | 0.124473 ± 0.000432438 (W 0.00142207) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141545 ± 0.000390474 (W 0.000394389) | 0.141706 ± 0.000416474 (W 0.000329071) | 0.154058 ± 0.000556906 (W 0.000405825) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.639908 ± 0.00156613 (W 0.00377206) | 0.640098 ± 0.00446127 (W 0.00425631) | 0.558335 ± 0.00321839 (W 0.00251421) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.5438 ± 0.0181005 (W 0.0199363) | 1.54057 ± 0.00155542 (W 0.0149445) | 1.14328 ± 0.00320906 (W 0.00225741) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01579 ± 7.25282e-05 (W 7.42112e-05) | 0.01587 ± 0.0002405 (W 5.65438e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090138 ± 0.000428137 (W 0.0016128) | 0.089889 ± 0.000191636 (W 0.00108014) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.263524 ± 0.000787922 (W 0.00152345) | 0.263743 ± 0.000226187 (W 0.00238535) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027973 ± 4.50592e-05 (W 0.000115401) | 0.028012 ± 2.6839e-05 (W 7.76357e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028102 ± 2.91605e-05 (W 8.98627e-05) | 0.028163 ± 2.08167e-05 (W 6.52625e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.06926 ± 0.00496835 (W 0.000763146) | 0.067396 ± 0.00100567 (W 0.00286198) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.069691 ± 0.00426801 (W 0.00324013) | 0.067426 ± 0.00179879 (W 0.00149209) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.164939 ± 0.00127845 (W 0.00463509) | 0.153948 ± 0.00236976 (W 0.00194039) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.164588 ± 0.00279582 (W 0.00291308) | 0.15434 ± 0.00168458 (W 0.00227558) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011482 ± 0.000181751 (W 9.41876e-05) | 0.011241 ± 0.000218793 (W 4.43847e-05) | 0.017522 ± 0.000128829 (W 4.34546e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050905 ± 0.000282171 (W 0.000254215) | 0.051076 ± 0.000220659 (W 0.000799159) | 0.08575 ± 0.000309802 (W 0.000327086) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136235 ± 0.000300222 (W 0.00145123) | 0.150943 ± 0.000622421 (W 0.0013305) | 0.224781 ± 0.000328311 (W 0.00257238) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068458 ± 0.000317065 (W 0.000346535) | 0.158246 ± 0.0155811 (W 0.0121912) | 0.04811 ± 0.000269463 (W 0.00124683) | 🔵 fork 2.31× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.296566 ± 0.00110844 (W 0.00343861) | 0.650698 ± 0.0046362 (W 0.0103811) | 0.287028 ± 0.000900432 (W 0.00139389) | 🔵 fork 2.19× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.626564 ± 0.0424412 (W 0.0142795) | 1.3202 ± 0.0450208 (W 0.0191) | 0.733194 ± 0.000877037 (W 0.00238399) | 🔵 fork 2.11× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033903 ± 0.000410719 (W 0.000192534) | 0.098094 ± 0.00312006 (W 0.00593217) | 0.026179 ± 7.84241e-05 (W 6.25396e-05) | 🔵 fork 2.89× faster than `faer-upstream` | 🔴 fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.155532 ± 0.000499529 (W 0.00213027) | 0.513171 ± 0.0134264 (W 0.0110146) | 0.756617 ± 0.000473019 (W 0.00207914) | 🔵 fork 3.30× faster than `faer-upstream` | 🔵 fork 4.86× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.338024 ± 0.00556656 (W 0.00622806) | 0.999012 ± 0.000943582 (W 0.0114144) | 2.44195 ± 0.00125478 (W 0.00200755) | 🔵 fork 2.96× faster than `faer-upstream` | 🔵 fork 7.22× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012454 ± 0.000191808 (W 5.06083e-05) | 0.012303 ± 2.08167e-05 (W 4.76582e-05) | 0.017262 ± 3.72872e-05 (W 8.20366e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052919 ± 0.000335054 (W 0.000191494) | 0.052839 ± 0.000298714 (W 0.00125397) | 0.083046 ± 0.000210072 (W 8.53124e-05) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.139361 ± 7.55447e-05 (W 0.000247372) | 0.154369 ± 0.00422929 (W 0.00161747) | 0.218299 ± 0.00120386 (W 0.00165519) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232165 ± 0.00388929 (W 0.00170328) | 0.233076 ± 0.00358071 (W 0.0012908) | 0.256591 ± 0.000926951 (W 0.00153093) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23109 ± 0.00238048 (W 0.00264829) | 1.2341 ± 0.00795773 (W 0.015066) | 1.00812 ± 0.00153306 (W 0.00155699) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.92829 ± 0.0159571 (W 0.0250314) | 2.93105 ± 0.0142413 (W 0.0182313) | 2.51205 ± 0.0031242 (W 0.00415413) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158566 ± 8.69502e-05 (W 0.00112422) | 0.159599 ± 0.000911714 (W 0.0013697) | 0.100208 ± 0.000465494 (W 8.91695e-05) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625492 ± 0.000467555 (W 0.00159199) | 0.625051 ± 0.00153277 (W 0.0025581) | 0.479297 ± 0.00115747 (W 0.00204237) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48405 ± 0.0059759 (W 0.00346316) | 1.48255 ± 0.00746782 (W 0.001891) | 1.34322 ± 0.00473309 (W 0.00482923) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001193 ± 2.58908e-05 (W 2.4966e-05) | 0.001182 ± 6.35085e-06 (W 1.36821e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002946 ± 9.30609e-05 (W 2.56944e-05) | 0.002796 ± 0.00012741 (W 1.28919e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00518 ± 0.00024023 (W 3.42082e-05) | 0.00519 ± 0.000330606 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00518 ± 2.04206e-05 (W 3.73658e-05) | 0.0052 ± 5.7735e-06 (W 4.48698e-05) | 0.008145 ± 0.000174827 (W 0.00178145) | · | 🔵 fork 1.57× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030046 ± 0.00010843 (W 7.8613e-05) | 0.030087 ± 0.00013653 (W 8.08282e-05) | 0.043441 ± 0.000213776 (W 6.1887e-05) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.110918 ± 0.000786605 (W 0.00302833) | 0.111128 ± 0.0035728 (W 0.00342757) | 0.124985 ± 0.000157684 (W 0.00147347) | · | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.142427 ± 0.000298297 (W 0.0016109) | 0.142156 ± 0.000346747 (W 0.00156406) | 0.155571 ± 0.000284231 (W 0.00137896) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.642553 ± 0.0057083 (W 0.00367091) | 0.647532 ± 0.00163629 (W 0.0102382) | 0.533037 ± 0.00194181 (W 0.00245025) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53265 ± 0.00279229 (W 0.0166487) | 1.59528 ± 0.00411607 (W 0.0177272) | 1.02744 ± 0.00398858 (W 0.00454531) | · | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01578 ± 0.000164612 (W 5.06952e-05) | 0.01576 ± 0.000217026 (W 7.87102e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09059 ± 0.000341361 (W 0.00186936) | 0.09052 ± 0.000374257 (W 0.0013515) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.263363 ± 0.000983732 (W 0.00231414) | 0.263785 ± 0.000330001 (W 0.00170083) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027973 ± 0.000152895 (W 0.00179183) | 0.028133 ± 8.75233e-05 (W 0.0001759) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027942 ± 4.72582e-05 (W 5.96758e-05) | 0.028283 ± 5.03322e-05 (W 9.13192e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.051086 ± 0.000489041 (W 0.00110301) | 0.070923 ± 0.00229025 (W 0.00314498) | - | 🔵 fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.051316 ± 0.000648324 (W 0.00169145) | 0.072465 ± 0.00176867 (W 0.00345518) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.10656 ± 0.000691139 (W 0.00304145) | 0.161091 ± 0.0003805 (W 0.00173132) | - | 🔵 fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.10705 ± 0.00332122 (W 0.00404014) | 0.160641 ± 0.000426276 (W 0.00148696) | - | 🔵 fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.011642 ± 4.0501e-05 (W 9.96494e-05) | 0.011171 ± 4.3589e-05 (W 9.05384e-05) | 0.017443 ± 5.34821e-05 (W 4.61519e-05) | · | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051075 ± 0.000286504 (W 0.000183275) | 0.051146 ± 0.000393675 (W 0.000245757) | 0.08553 ± 0.000249065 (W 0.000236051) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136346 ± 0.000347156 (W 0.0017012) | 0.164047 ± 0.000662076 (W 0.0013375) | 0.22402 ± 0.000184906 (W 0.00163938) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068158 ± 0.000406409 (W 0.000288198) | 0.18675 ± 0.00179868 (W 0.00620737) | 0.04796 ± 0.000148436 (W 0.000115725) | 🔵 fork 2.74× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.311413 ± 0.00207303 (W 0.00747993) | 0.856363 ± 0.0222395 (W 0.0196559) | 0.264435 ± 0.000486402 (W 0.00160678) | 🔵 fork 2.75× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.626974 ± 0.016609 (W 0.0211257) | 1.6815 ± 0.00660101 (W 0.0237541) | 0.67336 ± 0.00162573 (W 0.00191761) | 🔵 fork 2.68× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033593 ± 9.55353e-05 (W 0.00018727) | 0.129803 ± 0.00185068 (W 0.00778882) | 0.026099 ± 6.80686e-05 (W 4.20714e-05) | 🔵 fork 3.86× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.169818 ± 0.0105473 (W 0.00491182) | 0.68957 ± 0.0117284 (W 0.0154122) | 0.755815 ± 0.000997247 (W 0.00161345) | 🔵 fork 4.06× faster than `faer-upstream` | 🔵 fork 4.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.358391 ± 0.00241759 (W 0.0041369) | 1.32258 ± 0.0319033 (W 0.0304105) | 2.4408 ± 0.0018576 (W 0.00215334) | 🔵 fork 3.69× faster than `faer-upstream` | 🔵 fork 6.81× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012353 ± 6.65833e-05 (W 6.37966e-05) | 0.012263 ± 0.000110151 (W 8.19756e-05) | 0.017272 ± 2.3388e-05 (W 4.86826e-05) | · | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052909 ± 0.000102144 (W 0.00120282) | 0.052769 ± 0.000337625 (W 0.000394428) | 0.082675 ± 0.000136956 (W 8.80182e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.13912 ± 0.000341629 (W 0.00032624) | 0.16537 ± 0.00237357 (W 0.00395659) | 0.218499 ± 0.000545812 (W 0.00144881) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.233277 ± 0.0013325 (W 0.00158678) | 0.233026 ± 0.000292005 (W 0.00232647) | 0.260037 ± 0.000635047 (W 0.00176608) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2428 ± 0.00218475 (W 0.00302596) | 1.25076 ± 0.0017597 (W 0.00588567) | 0.973523 ± 0.00550063 (W 0.00188185) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.92966 ± 0.00598708 (W 0.0199108) | 3.05074 ± 0.00777505 (W 0.0154041) | 2.33409 ± 0.00754156 (W 0.00402548) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.159128 ± 0.000554248 (W 0.00135746) | 0.159879 ± 0.000393219 (W 0.00169386) | 0.100538 ± 0.000553825 (W 0.000131039) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.62509 ± 0.00148663 (W 0.00203774) | 0.626413 ± 0.00139548 (W 0.00185937) | 0.479517 ± 0.00364258 (W 0.0017331) | · | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48001 ± 0.00380981 (W 0.0016737) | 1.48199 ± 0.00404832 (W 0.00195101) | 1.33697 ± 0.00621106 (W 0.0017154) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001183 ± 2.6839e-05 (W 1.92666e-05) | 0.001192 ± 5.7735e-07 (W 1.61307e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002966 ± 0.000112073 (W 1.31263e-05) | 0.002806 ± 6.35085e-06 (W 1.39714e-05) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00521 ± 0.000275228 (W 2e-05) | 0.00519 ± 5.62168e-05 (W 3.42096e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
