# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `0627828d965b4abbf5eb14cc012f524a42966e85`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `3c59451a45c29f2af56c74b5b58d073810b76a9c`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `7f53c095fa4ce2e7f2bb9356b147b5b1b15e47f1f2371fc1c1ef5373da4b3edc`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T01:29:10.514340Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid --shapes 64,128,256,512 --families qr_factor,qr,svd_values,svd_thin --threads 1,4,8 --dtypes f64 --reps 5 --aa 3 --prime-ms 250 --label candidate-qr-apply-split-only-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T011734Z-candidate-qr-apply-split-only-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.79%, worst 77.94% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 24 of 288 engine cells exceed 5% and carry `!`; median within-process relative SD 0.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `qr/n64/b1` | 0.121128 ± 0.000493889 (W 0.000433856) | 0.117822 ± 0.000432974 (W 0.00153989) | 0.134122 ± 8.59089e-05 (W 0.000999248) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.086813 ± 0.000130885 (W 0.00157498) | 0.129624 ± 0.000112518 (W 0.00141491) | 0.29831 ± 0.134025 (W 0.0014239) | 🔵 fork 1.49× faster than `faer-upstream` | 🔵 fork 3.44× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.910661 ± 0.00449421 (W 0.000917883) | 0.910966 ± 0.00367548 (W 0.00135185) | 0.722451 ± 0.00094126 (W 0.00265572) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.516372 ± 0.00378892 (W 0.00203371) | 0.515839 ± 0.00409753 (W 0.00258016) | 0.265919 ± 0.000250899 (W 0.000996225) | · | 🔴 fork 1.94× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.174206 ± 0.00459 (W 0.00824814) | 0.475543 ± 0.00593217 (W 0.010505) | 0.144802 ± 0.00103208 (W 0.000949774) | 🔵 fork 2.73× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.118504 ± 0.0109397 (W 0.00962325) | 0.48508 ± 0.0111455 (W 0.0169765) | 0.298701 ± 0.133787 (W 0.00151413) | 🔵 fork 4.09× faster than `faer-upstream` | 🔵 fork 2.52× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.952403 ± 0.00475323 (W 0.0037861) | 0.949959 ± 0.00258684 (W 0.00831632) | 0.667504 ± 0.00730015 (W 0.00201909) | · | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.516509 ± 0.000846076 (W 0.00195338) | 0.517 ± 0.00176444 (W 0.00182807) | 0.269727 ± 0.000151318 (W 0.00100973) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.162546 ± 0.00255316 (W 0.00227708) | 0.652725 ± 0.00803199 (W 0.0148263) | 0.158458 ± 0.00046695 (W 0.00221051) | 🔵 fork 4.02× faster than `faer-upstream` | · |  |
| `qr_factor/n64/b1` | 0.112361 ± 0.00106521 (W 0.00205966) | 0.620265 ± 0.00340471 (W 0.00900791) | 0.29817 ± 0.133758 (W 0.00165971) | 🔵 fork 5.52× faster than `faer-upstream` | 🔵 fork 2.65× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.964179 ± 0.00238387 (W 0.00263938) | 0.982405 ± 0.0196159 (W 0.0162703) | 0.66115 ± 0.00660617 (W 0.00200666) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.515991 ± 0.00191757 (W 0.00181522) | 0.515488 ± 0.00116966 (W 0.00195479) | 0.271612 ± 0.00111777 (W 0.0018973) | · | 🔴 fork 1.90× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.114094 ± 0.00021689 (W 0.000358218) | 0.114906 ± 0.000537793 (W 0.00148795) | 0.115747 ± 0.000463635 (W 0.00121792) | · | · |  |
| `qr_factor/n64/b1` | 0.073047 ± 0.000123452 (W 0.000212222) | 0.074751 ± 0.000564025 (W 0.00128241) | 0.289684 ± 0.000242155 (W 0.00153769) | · | 🔵 fork 3.97× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.95821 ± 0.00341204 (W 0.0010988) | 0.957108 ± 0.0032383 (W 0.0015657) | 0.698773 ± 0.00138155 (W 0.00632951) | · | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537562 ± 0.00516833 (W 0.00162487) | 0.534775 ± 0.00498715 (W 0.00175844) | 0.25515 ± 0.00150109 (W 0.00172586) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.149762 ± 0.000768202 (W 0.00430347) | 0.487105 ± 0.0147325 (W 0.00473719) | 0.126227 ± 0.000869667 (W 0.000948992) | 🔵 fork 3.25× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.103835 ± 0.00349355 (W 0.00750092) | 0.411792 ± 0.0226156 (W 0.007959) | 0.289414 ± 0.000145583 (W 0.00128523) | 🔵 fork 3.97× faster than `faer-upstream` | 🔵 fork 2.79× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.990297 ± 0.00289818 (W 0.00166393) | 0.993193 ± 0.002978 (W 0.00218697) | 0.648266 ± 0.000389432 (W 0.00259685) | · | 🔴 fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.535889 ± 0.000467701 (W 0.00179947) | 0.535779 ± 0.00188822 (W 0.00169486) | 0.259337 ± 0.00106666 (W 0.00184188) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.146014 ± 0.000140119 (W 0.00108655) | 0.668889 ± 0.0102803 (W 0.0192704) | 0.139071 ± 0.00129858 (W 0.00171567) | 🔵 fork 4.58× faster than `faer-upstream` | · |  |
| `qr_factor/n64/b1` | 0.092473 ± 0.00489985 (W 0.0140483) | 0.564723 ± 0.0142213 (W 0.0165166) | 0.289445 ± 6.06987e-05 (W 0.00154601) | 🔵 fork 6.11× faster than `faer-upstream` | 🔵 fork 3.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.00816 ± 0.00186737 (W 0.00576836) | 1.00653 ± 0.00186286 (W 0.00516094) | 0.641115 ± 0.00619472 (W 0.00264376) | · | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.535464 ± 0.00152194 (W 0.00151782) | 0.536578 ± 0.0018426 (W 0.00179864) | 0.259038 ± 0.000557122 (W 0.00136361) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.515007 ± 0.00380433 (W 0.00213071) | 0.511062 ± 0.000747263 (W 0.0029133) | 0.750753 ± 0.00402909 (W 0.00419594) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.8832 ± 0.00731305 (W 0.00418064) | 2.93517 ± 0.00109834 (W 0.00270795) | 4.32443 ± 0.00921669 (W 0.0112299) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.2306 ± 1.09342 (W 0.0248899) | 20.7316 ± 1.09323 (W 0.0592249) | 30.6322 ± 0.27276 (W 0.0478102) | · | 🔵 fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.328789 ± 0.00355982 (W 0.00177331) | 0.535063 ± 0.00303534 (W 0.0038021) | 0.368993 ± 0.0023632 (W 0.00213081) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.59459 ± 0.0137909 (W 0.0031946) | 2.88947 ± 0.00548969 (W 0.00716508) | 2.04522 ± 0.00986114 (W 0.00609414) | 🔵 fork 1.81× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.90158 ± 0.119038 (W 0.0111123) | 17.6047 ± 0.0293164 (W 0.0207956) | 14.1456 ± 0.0378718 (W 0.0193741) | 🔵 fork 1.98× faster than `faer-upstream` | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.68222 ± 0.00510209 (W 0.00421441) | 3.68922 ± 0.00317174 (W 0.006302) | 3.38978 ± 0.00437893 (W 0.0138787) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4517 ± 0.0242167 (W 0.0142842) | 18.4548 ± 0.00412549 (W 0.0170192) | 18.0406 ± 0.00853456 (W 0.0258151) | · | · |  |
| `svd_thin/n512/b1` | 105.976 ± 0.322907 (W 0.0624523) | 105.62 ± 0.275343 (W 0.084798) | 117.104 ± 0.367452 (W 0.532969) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69684 ± 0.00646401 (W 0.0051375) | 2.70058 ± 0.00845997 (W 0.00300604) | 1.19183 ± 0.00128696 (W 0.0026796) | · | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4626 ± 0.029306 (W 0.0195144) | 12.4811 ± 0.0424329 (W 0.015891) | 6.96267 ± 0.00534737 (W 0.008817) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.6155 ± 0.140162 (W 0.0749738) | 66.6671 ± 0.0943494 (W 0.0624349) | 48.1154 ± 0.469074 (W 0.0230386) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.592244 ± 0.0164259 (W 0.0281539) | 1.42077 ± 0.024953 (W 0.0240741) | 0.47989 ± 0.00228245 (W 0.00319255) | 🔵 fork 2.40× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.99058 ± 0.0140174 (W 0.0281517) | 3.80337 ± 0.0445212 (W 0.081452) | 2.01324 ± 0.00605074 (W 0.00778306) | 🔵 fork 1.91× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 9.5096 ± 0.860779 (W 0.0552878) | 13.7894 ± 0.940455 (W 0.0584703) | 12.094 ± 0.0824125 (W 0.026485) | 🔵 fork 1.45× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.381446 ± 0.01987 (W 0.0131672) | 1.47557 ± 0.0100476 (W 0.0157666) | 0.197982 ± 0.000652414 (W 0.00179298) | 🔵 fork 3.87× faster than `faer-upstream` | 🔴 fork 1.93× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.47206 ± 0.0200852 (W 0.0296777) | 5.64414 ± 0.0368103 (W 0.0631896) | 0.66984 ± 0.00338697 (W 0.00338909) | 🔵 fork 3.83× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.27254 ± 0.0484677 (W 0.0198488) | 22.2818 ± 0.197815 (W 0.0917142) | 3.8643 ± 0.00299065 (W 0.00283818) | 🔵 fork 4.23× faster than `faer-upstream` | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02801 ± 0.00957589 (W 0.0152426) | 3.0175 ± 0.00939306 (W 0.0396343) | 2.63619 ± 0.00607922 (W 0.00831689) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6652 ± 0.0296678 (W 0.0250333) | 13.6929 ± 0.0177259 (W 0.0809827) | 12.4858 ± 0.0350827 (W 0.0335529) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.5279 ± 0.267073 (W 0.375414) | 61.5162 ± 0.135486 (W 0.191832) | 57.6551 ± 0.150653 (W 0.0739039) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.23172 ± 0.00739708 (W 0.0033615) | 2.23021 ± 0.00545331 (W 0.00380517) | 1.14029 ± 0.00167281 (W 0.00245141) | · | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.811 ± 0.00409708 (W 0.0266256) | 10.8267 ± 0.0384716 (W 0.0547287) | 6.13049 ± 0.0137113 (W 0.00856963) | · | 🔴 fork 1.76× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.0854 ± 0.240571 (W 0.394434) | 47.9872 ± 0.0331378 (W 0.317758) | 25.7953 ± 0.103978 (W 0.0381874) | · | 🔴 fork 1.86× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.593362 ± 0.00436287 (W 0.011658) | 1.94205 ± 0.042331 (W 0.0180063) | 0.436008 ± 0.000782376 (W 0.00399837) | 🔵 fork 3.27× faster than `faer-upstream` | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.83698 ± 0.0058793 (W 0.0170427) | 4.84193 ± 0.0608939 (W 0.0778622) | 1.80009 ± 0.00453161 (W 0.00706054) | 🔵 fork 2.64× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 8.80261 ± 0.0317877 (W 0.0497606) | 15.8941 ± 0.0967112 (W 0.190211) | 10.538 ± 0.196163 (W 0.0318321) | 🔵 fork 1.81× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.363641 ± 0.00486166 (W 0.00334847) | 1.98572 ± 0.017821 (W 0.0265512) | 0.157866 ± 0.00111075 (W 0.00154355) | 🔵 fork 5.46× faster than `faer-upstream` | 🔴 fork 2.30× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.42988 ± 0.0140159 (W 0.0120667) | 6.70884 ± 0.0269088 (W 0.0571148) | 0.572423 ± 0.000912143 (W 0.00350825) | 🔵 fork 4.69× faster than `faer-upstream` | 🔴 fork 2.50× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.87851 ± 0.0229925 (W 0.0345506) | 25.2488 ± 0.147051 (W 0.119648) | 2.3179 ± 0.0040986 (W 0.00226185) | 🔵 fork 5.18× faster than `faer-upstream` | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.04948 ± 0.0115551 (W 0.0141222) | 3.14674 ± 0.0125931 (W 0.0121389) | 2.50775 ± 0.000592581 (W 0.00475636) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5264 ± 0.0294729 (W 0.0540089) | 13.8312 ± 0.0378191 (W 0.0342782) | 11.4736 ± 0.0119469 (W 0.0250492) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.5347 ± 0.374586 (W 0.441529) | 60.8006 ± 0.0857308 (W 0.270499) | 48.5624 ± 2.24594 (W 0.155902) | · | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.27805 ± 0.0346949 (W 0.00343861) | 2.28201 ± 0.0376621 (W 0.00640574) | 1.12519 ± 0.00276511 (W 0.00217261) | · | 🔴 fork 2.02× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.9704 ± 0.0236521 (W 0.0180152) | 10.9652 ± 0.0230767 (W 0.0202868) | 5.99929 ± 0.0040639 (W 0.00936117) | · | 🔴 fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.5578 ± 0.281899 (W 0.301249) | 49.2898 ± 0.571401 (W 0.272635) | 22.3498 ± 0.052941 (W 0.0281053) | · | 🔴 fork 2.22× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.487735 ± 0.000349412 (W 0.00270512) | 0.488407 ± 0.00299602 (W 0.00272786) | 0.715085 ± 0.0209823 (W 0.00509711) | · | 🔵 fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.77321 ± 0.0108888 (W 0.00502564) | 2.78596 ± 0.00495515 (W 0.00252457) | 4.34826 ± 0.00918095 (W 0.0144649) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.5762 ± 1.02863 (W 0.015517) | 19.65 ± 0.905391 (W 0.0298433) | 30.4107 ± 0.0629441 (W 0.0249619) | · | 🔵 fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.27688 ± 0.000553418 (W 0.00173731) | 0.279436 ± 0.00436372 (W 0.00168402) | 0.333528 ± 0.000593323 (W 0.00294489) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.36444 ± 0.00524589 (W 0.00190234) | 1.3815 ± 0.0106047 (W 0.00288623) | 1.89296 ± 0.00926993 (W 0.00610788) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.94249 ± 0.106528 (W 0.0115603) | 8.00955 ± 0.0929619 (W 0.0130283) | 13.3888 ± 0.0543571 (W 0.0175763) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67974 ± 0.00211511 (W 0.005403) | 3.68371 ± 0.00217488 (W 0.00328751) | 3.31473 ± 0.00187561 (W 0.0156523) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3423 ± 0.0117933 (W 0.0180141) | 18.3415 ± 0.0310767 (W 0.0223276) | 17.7776 ± 0.0454525 (W 0.0292445) | · | · |  |
| `svd_thin/n512/b1` | 105.029 ± 0.313448 (W 0.0787431) | 105.049 ± 0.251027 (W 0.131462) | 113.915 ± 0.964801 (W 0.327198) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.61398 ± 0.00703012 (W 0.00508334) | 2.62086 ± 0.00364562 (W 0.00528222) | 1.15995 ± 0.00171077 (W 0.00297994) | · | 🔴 fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2834 ± 0.0313111 (W 0.0188614) | 12.2863 ± 0.0324415 (W 0.01717) | 6.84503 ± 0.0125761 (W 0.0140285) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.6066 ± 0.0690586 (W 0.38099) | 65.6391 ± 0.170939 (W 0.038108) | 47.593 ± 0.301096 (W 0.0352286) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.5702 ± 0.0119739 (W 0.0357934) | 1.43179 ± 0.022814 (W 0.0245083) | 0.476304 ± 0.0232426 (W 0.00256196) | 🔵 fork 2.51× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.91209 ± 0.0122434 (W 0.0231977) | 3.65754 ± 0.0368947 (W 0.0299271) | 2.18437 ± 0.0256114 (W 0.00592486) | 🔵 fork 1.91× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 8.98903 ± 0.830374 (W 0.0835443) | 12.6424 ± 0.870356 (W 0.116737) | 13.026 ± 0.242267 (W 0.00886849) | 🔵 fork 1.41× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.313588 ± 0.0202814 (W 0.00893263) | 1.16411 ± 0.0265321 (W 0.0252971) | 0.183054 ± 0.000456072 (W 0.00227088) | 🔵 fork 3.71× faster than `faer-upstream` | 🔴 fork 1.71× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.36701 ± 0.0195488 (W 0.027652) | 3.06508 ± 0.04682 (W 0.0344063) | 0.622228 ± 0.00374666 (W 0.00273152) | 🔵 fork 2.24× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.88105 ± 0.0566381 (W 0.0369223) | 8.44989 ± 0.0971738 (W 0.0467002) | 3.69593 ± 0.0292344 (W 0.00459235) | 🔵 fork 1.73× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.99654 ± 0.00569209 (W 0.0180741) | 2.99873 ± 0.00387527 (W 0.034106) | 2.59649 ± 0.0112884 (W 0.0059688) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5476 ± 0.0757647 (W 0.0477086) | 13.521 ± 0.0691704 (W 0.0379023) | 12.4016 ± 0.0785252 (W 0.0180656) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.6072 ± 0.0984681 (W 0.178959) | 60.7332 ± 0.256456 (W 0.476091) | 56.4115 ± 0.0989782 (W 0.0997982) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.19296 ± 0.0205506 (W 0.0183877) | 2.16015 ± 0.00899197 (W 0.00533586) | 1.13973 ± 0.00741646 (W 0.0013849) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6597 ± 0.0135619 (W 0.0242853) | 10.6523 ± 0.0136057 (W 0.0345617) | 6.10698 ± 0.0359132 (W 0.00984141) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.2006 ± 0.301897 (W 0.289471) | 47.1102 ± 0.170899 (W 0.396595) | 25.5656 ± 0.0716642 (W 0.0293687) | · | 🔴 fork 1.85× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.562698 ± 0.00424333 (W 0.0202693) | 1.90031 ± 0.00633399 (W 0.0138313) | 0.423375 ± 0.0161463 (W 0.00368185) | 🔵 fork 3.38× faster than `faer-upstream` | 🔴 fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.742 ± 0.0096758 (W 0.0217016) | 4.68019 ± 0.0454735 (W 0.0532116) | 2.04723 ± 0.0114839 (W 0.00685799) | 🔵 fork 2.69× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 8.28052 ± 0.0341562 (W 0.0470166) | 14.7524 ± 0.0559455 (W 0.126209) | 10.6208 ± 0.206137 (W 0.0182336) | 🔵 fork 1.78× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.325962 ± 0.000995535 (W 0.00465904) | 1.6053 ± 0.0363771 (W 0.0226881) | 0.145623 ± 0.000822262 (W 0.000748467) | 🔵 fork 4.92× faster than `faer-upstream` | 🔴 fork 2.24× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.3429 ± 0.00738922 (W 0.0134912) | 4.14338 ± 0.0170016 (W 0.0755302) | 0.541809 ± 0.00259602 (W 0.00352317) | 🔵 fork 3.09× faster than `faer-upstream` | 🔴 fork 2.48× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.58783 ± 0.0246881 (W 0.0231582) | 10.259 ± 0.118306 (W 0.0538119) | 2.24175 ± 0.00548097 (W 0.00574414) | 🔵 fork 2.24× faster than `faer-upstream` | 🔴 fork 2.05× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02833 ± 0.0122483 (W 0.00943457) | 3.09641 ± 0.0164139 (W 0.0097722) | 2.47288 ± 0.00731698 (W 0.00376533) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3736 ± 0.0251913 (W 0.0142145) | 13.7237 ± 0.0263759 (W 0.0709074) | 11.3464 ± 0.024037 (W 0.019419) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.214 ± 0.0271326 (W 0.522009) | 59.5006 ± 0.386694 (W 0.412011) | 47.7389 ± 1.22588 (W 0.0986593) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.15487 ± 0.00342251 (W 0.00310676) | 2.15629 ± 0.0297368 (W 0.00527972) | 1.11497 ± 0.0033435 (W 0.00271843) | · | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8131 ± 0.0362925 (W 0.0152629) | 10.8128 ± 0.0176832 (W 0.0276262) | 6.00033 ± 0.033304 (W 0.0116639) | · | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.0046 ± 0.726512 (W 0.254822) | 48.1316 ± 0.380372 (W 0.474106) | 22.3038 ± 0.0733828 (W 0.0238667) | · | 🔴 fork 2.15× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
