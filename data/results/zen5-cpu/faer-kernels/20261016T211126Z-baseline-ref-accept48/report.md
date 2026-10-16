# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `01e9f81fdf1c082c862f6d9656ff6c444b799f21`
- toolkit commit: `ca3ffc988b745675988a403fb2837d3e4dfe5653`
- measured binary SHA-256: `7b902aa706b7a981a7248eac2c7b479cb69b52d9832fad2bf0e0112c9f98aa98`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-16T21:46:34.371732Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall,linalg-wide --shapes  --families qr_factor,qr,lu,full_piv_lu,solve --dtypes f64,c64 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label baseline-ref-accept48 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T211126Z-baseline-ref-accept48/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.31%, worst 695.41% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 125 of 1024 engine cells exceed 5% and carry `!`; median within-process relative SD 0.75%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `full_piv_lu/n32/b1` | 0.010399 ± 0.000279321 (W 8.98888e-05) | 0.010569 ± 0.00037834 (W 0.000137754) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046937 ± 0.000190526 (W 0.000249931) | 0.046486 ± 0.000383094 (W 0.000127004) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.134021 ± 0.000403387 (W 0.00218203) | 0.134191 ± 0.00138722 (W 0.000308358) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007303 ± 9.01684e-05 (W 0.000115162) | 0.007404 ± 0.000110274 (W 0.000180176) | 0.012192 ± 2.36714e-05 (W 4.74363e-05) | · | 🔵 fork 1.67× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.02669 ± 0.000107503 (W 0.000142078) | 0.044133 ± 0.00236259 (W 0.00309067) | 0.042739 ± 0.000166377 (W 7.92477e-05) | 🔵 fork 1.65× faster than `faer-upstream` | 🔵 fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.065894 ± 0.000212671 (W 0.00212263) | 0.101177 ± 0.00142805 (W 0.00540431) | 0.093864 ± 0.000663202 (W 0.00196632) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031729 ± 0.000150997 (W 0.00024321) | 0.109363 ± 0.00439241 (W 0.0104177) | 0.026329 ± 0.0337744 (W 7.91663e-05) | 🔵 fork 3.45× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.162551 ± 0.011078 (W 0.00658564) | 0.476362 ± 0.00760579 (W 0.00527897) | 0.145512 ± 0.000695573 (W 0.00120518) | 🔵 fork 2.93× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.380776 ± 0.00719488 (W 0.0228244) | 1.01293 ± 0.00619757 (W 0.0172924) | 0.33497 ± 0.0018224 (W 0.00381245) | 🔵 fork 2.66× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023674 ± 0.000271663 (W 5.61249e-05) | 0.088935 ± 0.00257235 (W 0.00368894) | 0.014096 ± 8.96289e-05 (W 5.795e-05) | 🔵 fork 3.76× faster than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.136252 ± 0.00085611 (W 0.00474349) | 0.470783 ± 0.00897471 (W 0.0117374) | 0.297973 ± 0.132722 (W 0.00151706) | 🔵 fork 3.46× faster than `faer-upstream` | 🔵 fork 2.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.261274 ± 0.0223744 (W 0.00686586) | 0.936948 ± 0.00673349 (W 0.0124708) | 0.943506 ± 0.00189324 (W 0.00111278) | 🔵 fork 3.59× faster than `faer-upstream` | 🔵 fork 3.61× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.008155 ± 5.50757e-05 (W 8.45577e-05) | 0.008206 ± 0.00016552 (W 0.000172233) | 0.012774 ± 1e-05 (W 4.50555e-05) | · | 🔵 fork 1.57× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.027381 ± 0.000389923 (W 0.000124528) | 0.046237 ± 0.00124122 (W 0.00384432) | 0.043521 ± 0.000262127 (W 0.000158282) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.067595 ± 0.000508725 (W 0.00248914) | 0.104193 ± 0.00103868 (W 0.00426602) | 0.087554 ± 0.000139432 (W 0.00104145) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.0104 ± 0.00026142 (W 0.000115673) | 0.01041 ± 0.000285745 (W 6.90312e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046496 ± 8.02932e-05 (W 0.000274763) | 0.046496 ± 0.000588784 (W 0.000108237) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.133729 ± 0.000101214 (W 0.00030026) | 0.133007 ± 0.00204649 (W 0.000327854) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007274 ± 7.60723e-05 (W 0.000131719) | 0.007614 ± 0.000126623 (W 0.000100411) | 0.012192 ± 5.50757e-06 (W 8.96449e-05) | · | 🔵 fork 1.68× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.02693 ± 0.000249065 (W 0.000238544) | 0.049121 ± 0.00239799 (W 0.00268053) | 0.04277 ± 0.000116991 (W 0.000176611) | 🔵 fork 1.82× faster than `faer-upstream` | 🔵 fork 1.59× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.066103 ± 0.000106397 (W 0.00235828) | 0.120263 ± 0.00492403 (W 0.00567315) | 0.090438 ± 0.00286022 (W 0.00144821) | 🔵 fork 1.82× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031729 ± 0.000189869 (W 0.000207592) | 0.142105 ± 0.00122214 (W 0.00451413) | 0.026258 ± 0.0334474 (W 0.00014697) | 🔵 fork 4.48× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.156119 ± 0.00413654 (W 0.00267415) | 0.651908 ± 0.0191775 (W 0.0137819) | 0.160099 ± 0.00153699 (W 0.00123595) | 🔵 fork 4.18× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr/n96/b1` | 0.41509 ± 0.0106176 (W 0.0134785) | 1.3846 ± 0.023935 (W 0.0231166) | 0.338657 ± 0.0094469 (W 0.00393428) | 🔵 fork 3.34× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023734 ± 0.000234948 (W 0.000196907) | 0.121337 ± 0.0018692 (W 0.00280103) | 0.014156 ± 8.5049e-05 (W 5.3873e-05) | 🔵 fork 5.11× faster than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.128248 ± 0.00078292 (W 0.00241118) | 0.621763 ± 0.00566284 (W 0.0126751) | 0.298704 ± 0.134071 (W 0.00159152) | 🔵 fork 4.85× faster than `faer-upstream` | 🔵 fork 2.33× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.277268 ± 0.0167301 (W 0.00550465) | 1.28445 ± 0.00172356 (W 0.0124524) | 0.938526 ± 0.00142482 (W 0.000909884) | 🔵 fork 4.63× faster than `faer-upstream` | 🔵 fork 3.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.008256 ± 0.000130539 (W 0.000122185) | 0.008446 ± 4.16333e-05 (W 0.000136398) | 0.012683 ± 5.7735e-05 (W 3.53879e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.027541 ± 0.000147422 (W 0.00016784) | 0.053259 ± 0.00260584 (W 0.00334427) | 0.04344 ± 8.36082e-05 (W 0.000106034) | 🔵 fork 1.93× faster than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.068247 ± 0.00375369 (W 0.00238672) | 0.116406 ± 0.0053147 (W 0.00277486) | 0.08518 ± 0.000158248 (W 0.000232164) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.01057 ± 0.000126623 (W 9.3254e-05) | 0.010369 ± 0.000155349 (W 0.000110694) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046025 ± 7.80833e-05 (W 0.000170541) | 0.045565 ± 0.000236159 (W 0.000141803) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131947 ± 0.00180084 (W 0.00222648) | 0.132288 ± 0.00146597 (W 0.00238725) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007063 ± 0.000138924 (W 0.000141492) | 0.007284 ± 0.000200301 (W 0.000119458) | 0.009839 ± 7.83603e-05 (W 9.88903e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026008 ± 0.000155757 (W 0.000282028) | 0.038642 ± 0.00299429 (W 0.0035965) | 0.033532 ± 0.000122231 (W 0.000120649) | 🔵 fork 1.49× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063658 ± 0.000542625 (W 0.000255124) | 0.099616 ± 0.0019732 (W 0.00341856) | 0.074278 ± 0.000470802 (W 0.00138583) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031549 ± 0.000124231 (W 0.000977452) | 0.11196 ± 0.00196546 (W 0.00791263) | 0.021219 ± 0.000166644 (W 9.88898e-05) | 🔵 fork 3.55× faster than `faer-upstream` | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.145871 ± 0.00378499 (W 0.00327146) | 0.479567 ± 0.00859228 (W 0.00453131) | 0.125495 ± 0.00182116 (W 0.000983233) | 🔵 fork 3.29× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.372777 ± 0.0141173 (W 0.0199068) | 1.01832 ± 0.0267129 (W 0.0160155) | 0.292788 ± 0.000894721 (W 0.00147994) | 🔵 fork 2.73× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017613 ± 8.17333e-05 (W 0.000138185) | 0.082143 ± 0.00499886 (W 0.00541694) | 0.011581 ± 4.10731e-05 (W 4.64467e-05) | 🔵 fork 4.66× faster than `faer-upstream` | 🔴 fork 1.52× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.102109 ± 0.00948729 (W 0.000695448) | 0.414789 ± 0.00862147 (W 0.00952115) | 0.289521 ± 0.000240801 (W 0.00183876) | 🔵 fork 4.06× faster than `faer-upstream` | 🔵 fork 2.84× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.192686 ± 0.0159015 (W 0.0101126) | 0.825681 ± 0.00891278 (W 0.0224203) | 0.93035 ± 0.000399403 (W 0.000973654) | 🔵 fork 4.29× faster than `faer-upstream` | 🔵 fork 4.83× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007875 ± 0.000145741 (W 6.90652e-05) | 0.007855 ± 3.9879e-05 (W 0.000143584) | 0.009919 ± 2.91605e-05 (W 6.68528e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026148 ± 2.0502e-05 (W 0.00010789) | 0.042839 ± 0.00249888 (W 0.00310407) | 0.033452 ± 0.000188247 (W 7.08682e-05) | 🔵 fork 1.64× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065721 ± 0.000146732 (W 0.00248842) | 0.101849 ± 0.0019645 (W 0.00351753) | 0.073346 ± 0.000515646 (W 0.000224422) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.010299 ± 0.000151438 (W 0.000120939) | 0.010289 ± 0.000262592 (W 5.27276e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045595 ± 0.000110666 (W 0.000176083) | 0.045715 ± 0.00035119 (W 0.000352623) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131514 ± 0.00242623 (W 0.0022441) | 0.132656 ± 0.00301234 (W 0.00239179) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007313 ± 0.000100683 (W 0.00014021) | 0.007444 ± 0.000102144 (W 8.50294e-05) | 0.009658 ± 4e-05 (W 7.86715e-05) | · | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026148 ± 0.000236341 (W 0.000130281) | 0.051687 ± 0.00220634 (W 0.00314064) | 0.033472 ± 0.000121244 (W 0.000135353) | 🔵 fork 1.98× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063768 ± 0.00232501 (W 0.00220288) | 0.11388 ± 0.00336222 (W 0.00373417) | 0.073847 ± 0.000328301 (W 0.00132473) | 🔵 fork 1.79× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031298 ± 0.000130512 (W 0.00012187) | 0.14058 ± 0.00227681 (W 0.00384673) | 0.021159 ± 0.000246395 (W 7.86588e-05) | 🔵 fork 4.49× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.157645 ± 0.00351658 (W 0.00816368) | 0.664422 ± 0.00587079 (W 0.0158275) | 0.137436 ± 0.00160132 (W 0.00171112) | 🔵 fork 4.21× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.403919 ± 0.0244096 (W 0.0248493) | 1.39022 ± 0.0171864 (W 0.022436) | 0.305365 ± 0.00264213 (W 0.00262551) | 🔵 fork 3.44× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017682 ± 6.55006e-05 (W 8.46481e-05) | 0.111968 ± 0.0018993 (W 0.00625125) | 0.011491 ± 6.55744e-05 (W 5.19057e-05) | 🔵 fork 6.33× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.100386 ± 0.00544201 (W 0.00201913) | 0.584542 ± 0.00320397 (W 0.0127313) | 0.289832 ± 0.000212925 (W 0.00168013) | 🔵 fork 5.82× faster than `faer-upstream` | 🔵 fork 2.89× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.203508 ± 0.00349727 (W 0.00669021) | 1.1386 ± 0.0229047 (W 0.023904) | 0.930368 ± 0.00147636 (W 0.00137469) | 🔵 fork 5.59× faster than `faer-upstream` | 🔵 fork 4.57× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007925 ± 0.000120139 (W 8.35464e-05) | 0.008055 ± 0.000108167 (W 0.000157376) | 0.009788 ± 5.85947e-05 (W 3.00865e-05) | · | 🔵 fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026209 ± 0.000340441 (W 8.56931e-05) | 0.052017 ± 0.000659156 (W 0.00286909) | 0.033452 ± 4.62637e-05 (W 0.00129759) | 🔵 fork 1.98× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065812 ± 0.00402699 (W 0.00228103) | 0.120242 ± 0.00882173 (W 0.00588387) | 0.073517 ± 0.000236112 (W 8.71051e-05) | 🔵 fork 1.83× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.015829 ± 0.000146857 (W 7.86333e-05) | 0.015749 ± 0.000133593 (W 4.98016e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.091789 ± 0.000105794 (W 0.00034872) | 0.09206 ± 0.000291826 (W 0.000553087) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.305946 ± 0.00208778 (W 0.00222276) | 0.306864 ± 0.00209881 (W 0.00428177) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011641 ± 5.7735e-07 (W 5.5797e-05) | 0.011491 ± 0.000119459 (W 7.89316e-05) | 0.019847 ± 0.00015695 (W 0.00012365) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.054601 ± 0.00079949 (W 0.000606615) | 0.053479 ± 0.00108124 (W 0.00038715) | 0.095757 ± 0.000302987 (W 0.000199877) | · | 🔵 fork 1.75× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.182111 ± 0.00182676 (W 0.00330562) | 0.193358 ± 0.000905285 (W 0.00183729) | 0.263709 ± 0.0130766 (W 0.00348698) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.067915 ± 0.000590569 (W 0.000506602) | 0.150682 ± 0.0148629 (W 0.00884761) | 0.05356 ± 0.0896314 (W 0.00160865) | 🔵 fork 2.22× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.310985 ± 0.00839613 (W 0.0115066) | 0.660665 ± 2.64594 (W 0.0195614) | 0.305497 ± 0.000636531 (W 0.00193865) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.697544 ± 0.0167838 (W 0.0170149) | 1.35779 ± 0.0138537 (W 0.0122441) | 0.768275 ± 0.000423572 (W 0.00212445) | 🔵 fork 1.95× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040556 ± 0.000209621 (W 0.000163396) | 0.109052 ± 0.00171813 (W 0.00381411) | 0.028684 ± 1.58219e-05 (W 7.89443e-05) | 🔵 fork 2.69× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.209863 ± 0.000816421 (W 0.00177383) | 0.599711 ± 0.0143853 (W 0.00540365) | 0.761002 ± 0.345447 (W 0.00190757) | 🔵 fork 2.86× faster than `faer-upstream` | 🔵 fork 3.63× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.414354 ± 0.00382819 (W 0.00343827) | 1.14623 ± 0.0079634 (W 0.0165548) | 2.45325 ± 0.00323407 (W 0.00318881) | 🔵 fork 2.77× faster than `faer-upstream` | 🔵 fork 5.92× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013225 ± 0.000130309 (W 0.000152971) | 0.012654 ± 7.54983e-05 (W 7.35887e-05) | 0.020318 ± 7.50555e-05 (W 0.00145484) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.056044 ± 0.000151596 (W 0.000826249) | 0.055043 ± 0.000210571 (W 0.000137543) | 0.092832 ± 0.000481747 (W 0.000258703) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.19451 ± 0.00221029 (W 0.00336242) | 0.205992 ± 0.000990435 (W 0.0056479) | 0.236508 ± 0.000256135 (W 0.0016525) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.015859 ± 8.63153e-05 (W 7.53406e-05) | 0.015759 ± 8.52467e-05 (W 0.000118837) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09197 ± 0.000780547 (W 0.00117589) | 0.09202 ± 0.000596616 (W 0.000375482) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.308842 ± 0.00247358 (W 0.00229497) | 0.306352 ± 0.00213425 (W 0.00384657) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011631 ± 0.000360085 (W 4.8211e-05) | 0.011512 ± 0.000153298 (W 7.04996e-05) | 0.019937 ± 0.000131341 (W 6.37966e-05) | · | 🔵 fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.05375 ± 0.000167004 (W 0.00143894) | 0.054852 ± 0.00109725 (W 0.000230837) | 0.09602 ± 0.000250624 (W 0.000280657) | · | 🔵 fork 1.79× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.181606 ± 0.0016186 (W 0.00236649) | 0.205971 ± 0.00111194 (W 0.00352222) | 0.244003 ± 0.0134319 (W 0.00172598) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.068067 ± 0.000314102 (W 0.00184088) | 0.186545 ± 0.00395906 (W 0.00682846) | 0.053319 ± 0.0899558 (W 0.00116716) | 🔵 fork 2.74× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.303954 ± 0.0026296 (W 0.00516139) | 0.868126 ± 0.00485639 (W 0.0189118) | 0.283454 ± 0.00065829 (W 0.00154114) | 🔵 fork 2.86× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.749489 ± 0.000604886 (W 0.0153829) | 1.77905 ± 0.0160371 (W 0.03949) | 0.736486 ± 0.000342789 (W 0.0055534) | 🔵 fork 2.37× faster than `faer-upstream` | · |  |
| `qr_factor/n32/b1` | 0.040255 ± 0.000109697 (W 0.00140958) | 0.137054 ± 0.00206251 (W 0.00365685) | 0.028593 ± 0.000138264 (W 6.26115e-05) | 🔵 fork 3.40× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.216522 ± 0.00109466 (W 0.00258962) | 0.769153 ± 0.0100688 (W 0.0206753) | 0.762945 ± 0.346091 (W 0.000954965) | 🔵 fork 3.55× faster than `faer-upstream` | 🔵 fork 3.52× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.44321 ± 0.00676146 (W 0.0096815) | 1.49619 ± 0.0144279 (W 0.0303978) | 2.44893 ± 0.000761952 (W 0.00227383) | 🔵 fork 3.38× faster than `faer-upstream` | 🔵 fork 5.53× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013315 ± 0.000120968 (W 8.87694e-05) | 0.012844 ± 0.0001 (W 0.000148685) | 0.020327 ± 0.000156845 (W 5.06883e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055993 ± 4.07962e-05 (W 0.000631092) | 0.055062 ± 0.000300495 (W 0.000303958) | 0.093453 ± 0.000383409 (W 0.00042175) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.191866 ± 0.000863881 (W 0.00328362) | 0.214388 ± 0.00242645 (W 0.0051182) | 0.236608 ± 0.000680589 (W 0.00177989) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.015789 ± 0.0001905 (W 8.46759e-05) | 0.015679 ± 0.000248818 (W 0.000101143) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090087 ± 0.000188585 (W 0.0015086) | 0.090139 ± 0.000182487 (W 0.00149018) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.303683 ± 0.00123609 (W 0.0022003) | 0.303417 ± 0.0015542 (W 0.0018754) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011782 ± 0.000126361 (W 0.000121734) | 0.011502 ± 3.05014e-05 (W 4.64575e-05) | 0.017342 ± 6.50641e-05 (W 0.000122594) | · | 🔵 fork 1.47× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052047 ± 0.000162194 (W 0.000861451) | 0.051526 ± 0.000885027 (W 0.000120641) | 0.085739 ± 0.000317856 (W 0.00203998) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.178123 ± 0.00138038 (W 0.00193598) | 0.189985 ± 0.000847758 (W 0.00451074) | 0.224767 ± 0.00137473 (W 0.00219562) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068256 ± 0.00016447 (W 0.000223565) | 0.14991 ± 0.0109142 (W 0.0174269) | 0.04832 ± 0.000164612 (W 0.00015873) | 🔵 fork 2.20× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.296911 ± 0.00179132 (W 0.003395) | 0.633805 ± 0.00288278 (W 0.0129406) | 0.287614 ± 0.000472923 (W 0.00195641) | 🔵 fork 2.13× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.674501 ± 0.0314451 (W 0.00414137) | 1.34377 ± 0.0250608 (W 0.0242032) | 0.732816 ± 0.000330592 (W 0.00183371) | 🔵 fork 1.99× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033312 ± 0.000710157 (W 0.000165071) | 0.093203 ± 0.00150303 (W 0.00604259) | 0.026079 ± 0.000111267 (W 5.88065e-05) | 🔵 fork 2.80× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.158242 ± 0.0031156 (W 0.00329742) | 0.50234 ± 0.00952401 (W 0.00896665) | 0.755458 ± 0.00123656 (W 0.00156241) | 🔵 fork 3.17× faster than `faer-upstream` | 🔵 fork 4.77× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.332246 ± 0.00463565 (W 0.00156056) | 1.00022 ± 0.0137718 (W 0.0153181) | 2.44028 ± 0.00231219 (W 0.00321757) | 🔵 fork 3.01× faster than `faer-upstream` | 🔵 fork 7.34× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013104 ± 7.07602e-05 (W 0.000117585) | 0.012583 ± 0.000125381 (W 8.94327e-05) | 0.017352 ± 6.70099e-05 (W 3.17994e-05) | · | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.054462 ± 9.54481e-05 (W 0.000772037) | 0.053368 ± 0.000115518 (W 0.000145654) | 0.083066 ± 0.000160628 (W 0.00027743) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.18726 ± 0.00223866 (W 0.00245914) | 0.202295 ± 0.00201121 (W 0.00338707) | 0.218104 ± 0.000169013 (W 0.00194911) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.015929 ± 1.70392e-05 (W 0.000136272) | 0.015589 ± 7.83603e-05 (W 4.84273e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090087 ± 0.000591496 (W 0.000547558) | 0.090107 ± 0.000505698 (W 0.000615455) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.305065 ± 0.00256705 (W 0.0017076) | 0.301858 ± 0.000609525 (W 0.0019634) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011792 ± 0.000143643 (W 1.94499e-05) | 0.011622 ± 0.000142339 (W 6.70395e-05) | 0.017413 ± 7.88057e-05 (W 4.33047e-05) | · | 🔵 fork 1.48× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052006 ± 0.000309744 (W 0.000635272) | 0.051887 ± 0.000200367 (W 0.000196825) | 0.085829 ± 0.000722351 (W 0.00012736) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.179332 ± 0.0018825 (W 0.00139588) | 0.203146 ± 0.00139666 (W 0.00289347) | 0.224446 ± 0.00088825 (W 0.00227982) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.067976 ± 0.00031607 (W 0.000334552) | 0.191365 ± 0.00719615 (W 0.00750661) | 0.048109 ± 3.72872e-05 (W 0.000124793) | 🔵 fork 2.82× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.299104 ± 0.00513498 (W 0.00613973) | 0.850738 ± 0.0162001 (W 0.0151754) | 0.263559 ± 0.00064803 (W 0.00190924) | 🔵 fork 2.84× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.752001 ± 0.00438066 (W 0.0127954) | 1.76745 ± 0.0368625 (W 0.0327873) | 0.669288 ± 0.00124123 (W 0.00161674) | 🔵 fork 2.35× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033693 ± 0.000100201 (W 0.000298195) | 0.124771 ± 0.00219917 (W 0.0026007) | 0.026169 ± 0.00012079 (W 8.18853e-05) | 🔵 fork 3.70× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.160838 ± 0.0010865 (W 0.00220736) | 0.67596 ± 0.00587889 (W 0.00545163) | 0.755277 ± 0.00249141 (W 0.00175807) | 🔵 fork 4.20× faster than `faer-upstream` | 🔵 fork 4.70× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.354983 ± 0.00346891 (W 0.00651641) | 1.32695 ± 0.0198281 (W 0.026207) | 2.44102 ± 0.0012213 (W 0.00353306) | 🔵 fork 3.74× faster than `faer-upstream` | 🔵 fork 6.88× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013395 ± 0.000162583 (W 0.000103586) | 0.012754 ± 0.00010116 (W 0.000117069) | 0.017383 ± 9.30609e-05 (W 0.00010065) | · | 🔵 fork 1.30× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.05435 ± 0.000126808 (W 0.000533513) | 0.053439 ± 0.000357338 (W 0.000254282) | 0.083034 ± 0.000226018 (W 0.000144942) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.189143 ± 0.00244571 (W 0.0023187) | 0.215208 ± 0.00330244 (W 0.00351571) | 0.218404 ± 0.000340855 (W 0.00234163) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.313251 ± 0.00158955 (W 0.00262812) | 0.311708 ± 0.000802513 (W 0.00345801) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.76378 ± 0.00866331 (W 0.00506483) | 2.7529 ± 0.0029446 (W 0.00851023) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 18.0446 ± 0.173424 (W 0.185699) | 18.0828 ± 0.177656 (W 0.201967) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.137497 ± 0.0181573 (W 0.00127769) | 0.203727 ± 0.0143137 (W 0.00697099) | 0.151381 ± 0.0146589 (W 0.00151455) | 🔵 fork 1.48× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.05221 ± 0.132149 (W 0.00749299) | 1.17259 ± 0.00945138 (W 0.0146483) | 0.379188 ± 0.112357 (W 0.00254805) | · | 🔴 fork 2.77× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 5.30413 ± 0.0940558 (W 0.071817) | 5.58727 ± 0.0352223 (W 0.0570022) | 2.60683 ± 0.0180549 (W 0.0127144) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 2.03× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.60983 ± 0.0393704 (W 0.0317138) | 1.42543 ± 0.0300609 (W 0.0283468) | 0.480921 ± 0.000662424 (W 0.00316567) | 🔵 fork 2.34× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.07877 ± 0.0244169 (W 0.0276251) | 3.7135 ± 0.0441291 (W 0.0727189) | 2.01607 ± 0.00935143 (W 0.00571369) | 🔵 fork 1.79× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 10.7616 ± 1.07077 (W 0.0977505) | 14.2067 ± 1.08715 (W 0.0984021) | 12.0259 ± 0.0379464 (W 0.0250327) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.481739 ± 0.0342527 (W 0.00309895) | 1.45243 ± 0.0173228 (W 0.0209655) | 0.196186 ± 0.000521874 (W 0.00135983) | 🔵 fork 3.01× faster than `faer-upstream` | 🔴 fork 2.46× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.74023 ± 0.0210384 (W 0.0334872) | 5.52147 ± 0.0709108 (W 0.0399943) | 0.670904 ± 0.00278501 (W 0.00278594) | 🔵 fork 2.01× faster than `faer-upstream` | 🔴 fork 4.08× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 16.118 ± 0.152825 (W 0.102282) | 22.0681 ± 0.185076 (W 0.0473772) | 3.85292 ± 0.00378004 (W 0.00775808) | 🔵 fork 1.37× faster than `faer-upstream` | 🔴 fork 4.18× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.137344 ± 0.000572058 (W 0.00124757) | 0.204339 ± 0.00213852 (W 0.00547784) | 0.150218 ± 0.000378402 (W 0.00133383) | 🔵 fork 1.49× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.819028 ± 0.00274462 (W 0.00341787) | 0.887235 ± 0.00402792 (W 0.0222136) | 0.36798 ± 0.00116513 (W 0.00264141) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 2.23× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.24218 ± 0.030077 (W 0.046684) | 5.41896 ± 0.0571833 (W 0.0374911) | 1.79564 ± 0.0180801 (W 0.00303829) | · | 🔴 fork 2.92× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.312458 ± 0.00404154 (W 0.00174503) | 0.311927 ± 0.00285928 (W 0.00158933) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.74985 ± 0.00925832 (W 0.00862896) | 2.76221 ± 0.00426888 (W 0.00868175) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.9891 ± 0.145323 (W 0.0957215) | 17.9429 ± 0.205574 (W 0.132934) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.136303 ± 0.0196627 (W 0.00119109) | 0.215599 ± 0.0187637 (W 0.00577207) | 0.150178 ± 0.0224842 (W 0.00151946) | 🔵 fork 1.58× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.05255 ± 0.123596 (W 0.00344138) | 1.25254 ± 0.0139438 (W 0.0299808) | 0.348105 ± 0.144069 (W 0.00216853) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 3.02× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 5.1774 ± 0.0184853 (W 0.0357548) | 5.66959 ± 0.0551663 (W 0.0702879) | 2.15514 ± 0.17422 (W 0.00689225) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 2.40× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n128/b1` | 0.609951 ± 0.00296457 (W 0.00499246) | 1.90968 ± 0.0166421 (W 0.0235247) | 0.430542 ± 0.00361514 (W 0.00330285) | 🔵 fork 3.13× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.15743 ± 0.00397457 (W 0.0222136) | 4.79798 ± 0.0453032 (W 0.073806) | 1.79392 ± 0.00245831 (W 0.00578035) | 🔵 fork 2.22× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr/n512/b1` | 10.7937 ± 0.0565199 (W 0.0876875) | 15.8017 ± 0.146695 (W 0.178337) | 8.99899 ± 0.006128 (W 0.0284748) | 🔵 fork 1.46× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.497117 ± 0.00358741 (W 0.00273812) | 1.96566 ± 0.0310245 (W 0.0144922) | 0.15643 ± 0.000611899 (W 0.00124054) | 🔵 fork 3.95× faster than `faer-upstream` | 🔴 fork 3.18× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.80315 ± 0.01207 (W 0.0158417) | 6.66934 ± 0.040588 (W 0.0452399) | 0.576908 ± 0.00259996 (W 0.00243874) | 🔵 fork 2.38× faster than `faer-upstream` | 🔴 fork 4.86× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 16.3819 ± 0.0537116 (W 0.0767415) | 24.921 ± 0.0696399 (W 0.123625) | 2.31357 ± 0.0119704 (W 0.00509454) | 🔵 fork 1.52× faster than `faer-upstream` | 🔴 fork 7.08× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.135502 ± 0.00114492 (W 0.00241743) | 0.213415 ± 0.00366902 (W 0.00730026) | 0.146781 ± 0.000969296 (W 0.00126028) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.821612 ± 0.00271518 (W 0.0040302) | 0.960249 ± 0.00837582 (W 0.0186641) | 0.336042 ± 0.00372847 (W 0.00410549) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 2.44× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.19973 ± 0.059152 (W 0.0523777) | 5.61215 ± 0.0494279 (W 0.0740979) | 1.29424 ± 0.0143167 (W 0.0125624) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 4.02× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.290017 ± 0.00149393 (W 0.00215276) | 0.289457 ± 0.000186039 (W 0.00203438) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61448 ± 0.00592729 (W 0.0109661) | 2.61886 ± 0.00364731 (W 0.00785947) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9296 ± 0.0851018 (W 0.0693063) | 16.9505 ± 0.101381 (W 0.134625) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.14614 ± 0.00198413 (W 0.00160801) | 0.215529 ± 0.00474978 (W 0.00421663) | 0.132826 ± 0.000193876 (W 0.00121905) | 🔵 fork 1.47× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.708814 ± 0.171189 (W 0.00494095) | 0.831331 ± 0.121267 (W 0.0158276) | 0.326766 ± 0.0016089 (W 0.00215921) | · | 🔴 fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.38511 ± 0.0691919 (W 0.0749816) | 4.57775 ± 0.0112465 (W 0.0541043) | 1.63137 ± 9.45216e-05 (W 0.00418019) | · | 🔴 fork 2.69× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.575904 ± 0.0229736 (W 0.0235312) | 1.38551 ± 0.0333968 (W 0.0270576) | 0.49328 ± 0.0253722 (W 0.0031339) | 🔵 fork 2.41× faster than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.92431 ± 0.0190315 (W 0.0226138) | 3.57985 ± 0.0672859 (W 0.0667964) | 2.19718 ± 0.0182117 (W 0.00920383) | 🔵 fork 1.86× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.45751 ± 0.909751 (W 0.0425422) | 13.0849 ± 1.00001 (W 0.109467) | 13.0675 ± 0.0526775 (W 0.0262671) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.362981 ± 0.0297084 (W 0.0293008) | 1.17729 ± 0.0325654 (W 0.0241702) | 0.183169 ± 0.000502355 (W 0.00194498) | 🔵 fork 3.24× faster than `faer-upstream` | 🔴 fork 1.98× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.35317 ± 0.0118215 (W 0.0258044) | 3.01517 ± 0.0591878 (W 0.0204926) | 0.619285 ± 0.00364515 (W 0.00272686) | 🔵 fork 2.23× faster than `faer-upstream` | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.79586 ± 0.0148626 (W 0.028979) | 8.28045 ± 0.123832 (W 0.0631373) | 3.65993 ± 0.00135602 (W 0.00547997) | 🔵 fork 1.73× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112367 ± 0.00056461 (W 0.00153637) | 0.174887 ± 0.00307057 (W 0.0049843) | 0.131463 ± 0.000539209 (W 0.00137743) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.674809 ± 0.00628248 (W 0.00469908) | 0.763001 ± 0.012668 (W 0.0227948) | 0.315328 ± 0.0017978 (W 0.00221256) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 2.14× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.3022 ± 0.0431536 (W 0.0310089) | 4.36512 ± 0.0321238 (W 0.0392986) | 1.61396 ± 0.012812 (W 0.00329938) | · | 🔴 fork 2.67× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.288694 ± 0.00313233 (W 0.00208084) | 0.289856 ± 0.001709 (W 0.00249482) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62583 ± 0.0115451 (W 0.00836956) | 2.62971 ± 0.00635603 (W 0.01231) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8495 ± 0.0607273 (W 0.0830687) | 16.6578 ± 0.107007 (W 0.0840495) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145721 ± 0.00120325 (W 0.000250367) | 0.223637 ± 0.00653245 (W 0.0094336) | 0.133016 ± 0.000706989 (W 0.00164228) | 🔵 fork 1.53× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.706556 ± 0.115898 (W 0.00443817) | 0.942807 ± 0.120296 (W 0.025302) | 0.31389 ± 0.00426313 (W 0.00298468) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.22614 ± 0.0234837 (W 0.0473483) | 4.66233 ± 0.0509381 (W 0.071628) | 1.22516 ± 0.0140834 (W 0.00781587) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 3.45× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.593445 ± 0.00348297 (W 0.0116876) | 1.88071 ± 0.0110835 (W 0.0217673) | 0.414246 ± 0.0021137 (W 0.00285866) | 🔵 fork 3.17× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.03602 ± 0.0112641 (W 0.0111847) | 4.67038 ± 0.0101005 (W 0.0312331) | 2.01607 ± 0.0268593 (W 0.00825336) | 🔵 fork 2.29× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 9.77768 ± 0.06748 (W 0.120819) | 14.8 ± 0.15577 (W 0.103232) | 10.2835 ± 0.0361954 (W 0.022892) | 🔵 fork 1.51× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.325196 ± 0.00189449 (W 0.00300157) | 1.57684 ± 0.0148223 (W 0.0226408) | 0.144277 ± 0.000370363 (W 0.0016243) | 🔵 fork 4.85× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.46535 ± 0.00786038 (W 0.0158241) | 4.07552 ± 0.0397841 (W 0.0437209) | 0.543536 ± 0.00161646 (W 0.00301205) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 2.70× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.13212 ± 0.0329632 (W 0.0931874) | 10.1157 ± 0.0556555 (W 0.100893) | 2.1983 ± 0.00107839 (W 0.00525246) | 🔵 fork 1.97× faster than `faer-upstream` | 🔴 fork 2.33× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112058 ± 0.000628382 (W 0.00157942) | 0.187289 ± 0.00169875 (W 0.00619356) | 0.132365 ± 0.000625655 (W 0.00146123) | 🔵 fork 1.67× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.677632 ± 0.00283118 (W 0.00195181) | 0.803918 ± 0.0280069 (W 0.0372198) | 0.302233 ± 0.00116888 (W 0.00340974) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.24× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.18563 ± 0.056311 (W 0.109026) | 4.54044 ± 0.0632644 (W 0.104037) | 1.19882 ± 0.0107678 (W 0.00695988) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 3.49× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.771547 ± 0.00454311 (W 0.00423206) | 0.7773 ± 0.00498452 (W 0.00506248) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 6.05564 ± 0.0539836 (W 0.0167937) | 5.99979 ± 0.0276822 (W 0.0120062) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.6305 ± 0.0984797 (W 0.0493714) | 29.705 ± 0.160185 (W 0.0533503) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.33228 ± 0.0031079 (W 0.00553673) | 0.352007 ± 0.00530106 (W 0.00519346) | 0.482204 ± 0.0016805 (W 0.00250822) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.22944 ± 0.00402747 (W 0.010307) | 1.68933 ± 0.00339875 (W 0.0183762) | 1.01351 ± 0.00325136 (W 0.00281232) | 🔴 fork 1.32× slower than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.6494 ± 0.0474136 (W 0.0702073) | 9.93419 ± 0.0480574 (W 0.0631721) | 7.60609 ± 0.0550952 (W 0.0255467) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.40× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.03053 ± 0.00964552 (W 0.00522349) | 1.93033 ± 0.00894987 (W 0.0126683) | 1.04067 ± 0.00264329 (W 0.00232787) | 🔵 fork 1.87× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.65008 ± 0.0045107 (W 0.020048) | 6.25075 ± 0.040347 (W 0.064708) | 4.79407 ± 0.033323 (W 0.0139275) | 🔵 fork 1.34× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 27.1091 ± 0.0715617 (W 0.194876) | 30.4833 ± 0.0888307 (W 0.108723) | 28.5672 ± 0.0603919 (W 0.0349513) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.757211 ± 0.00212802 (W 0.00400948) | 1.80705 ± 0.0157964 (W 0.0152017) | 0.450814 ± 0.00244841 (W 0.00158706) | 🔵 fork 2.39× faster than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.33756 ± 0.0200201 (W 0.0399173) | 7.19967 ± 0.0544528 (W 0.0332135) | 1.63338 ± 0.00334641 (W 0.00296275) | 🔵 fork 1.66× faster than `faer-upstream` | 🔴 fork 2.66× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 21.304 ± 0.174453 (W 0.0828804) | 26.2897 ± 0.168921 (W 0.103988) | 11.4013 ± 0.0280553 (W 0.0135783) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.87× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.335681 ± 0.00320893 (W 0.00292761) | 0.336297 ± 0.00196175 (W 0.00680035) | 0.465202 ± 0.00171295 (W 0.00245563) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.17291 ± 0.00431386 (W 0.0138137) | 1.5665 ± 0.014854 (W 0.0189156) | 0.896459 ± 0.00559786 (W 0.00443567) | 🔴 fork 1.39× slower than `faer-upstream` | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 11.3323 ± 0.0398391 (W 0.0501528) | 10.4607 ± 0.0104197 (W 0.0794571) | 5.63062 ± 0.00703772 (W 0.0102163) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 2.01× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.775747 ± 0.00279861 (W 0.00457925) | 0.779615 ± 0.0101112 (W 0.00783972) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 6.04069 ± 0.0728527 (W 0.0214278) | 6.02988 ± 0.0718323 (W 0.0126459) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.8852 ± 0.0113022 (W 0.117657) | 27.7737 ± 0.0810372 (W 0.108903) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.333346 ± 0.00336773 (W 0.00205323) | 0.366259 ± 0.00643211 (W 0.00352463) | 0.484583 ± 0.000742695 (W 0.00375598) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.26331 ± 0.0149291 (W 0.0220291) | 1.67986 ± 0.011271 (W 0.0103237) | 0.698241 ± 0.00261637 (W 0.0045973) | 🔴 fork 1.35× slower than `faer-upstream` | 🔴 fork 3.24× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.62422 ± 0.0353018 (W 0.0554404) | 8.80528 ± 0.00986151 (W 0.0326857) | 5.05693 ± 0.0230343 (W 0.0162331) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 1.90× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.14229 ± 0.0104644 (W 0.00914238) | 2.49733 ± 0.0355499 (W 0.0473748) | 0.782129 ± 0.00253119 (W 0.00368113) | 🔵 fork 2.19× faster than `faer-upstream` | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 4.27316 ± 0.0152952 (W 0.0215032) | 6.94848 ± 0.0254948 (W 0.0686703) | 3.82222 ± 0.0129062 (W 0.00684847) | 🔵 fork 1.63× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `qr/n512/b1` | 22.0082 ± 0.111583 (W 0.199151) | 27.0095 ± 0.0891219 (W 0.0917338) | 16.0219 ± 0.0124076 (W 0.0205425) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.80545 ± 0.0035743 (W 0.00358666) | 2.32177 ± 0.0373199 (W 0.0206523) | 0.322266 ± 0.00112418 (W 0.00141668) | 🔵 fork 2.88× faster than `faer-upstream` | 🔴 fork 2.50× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.364 ± 0.0197447 (W 0.0289254) | 8.48582 ± 0.0771327 (W 0.0896375) | 1.61567 ± 0.0048948 (W 0.0023543) | 🔵 fork 1.94× faster than `faer-upstream` | 🔴 fork 2.70× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 19.7613 ± 0.0603544 (W 0.194356) | 27.4083 ± 0.165633 (W 0.157874) | 5.79486 ± 0.0172934 (W 0.00937835) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 3.41× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.334614 ± 0.0051378 (W 0.00238481) | 0.359906 ± 0.00363631 (W 0.00730623) | 0.468863 ± 0.00202011 (W 0.00225355) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.18553 ± 0.0133564 (W 0.0094709) | 1.52513 ± 0.0224158 (W 0.0135021) | 0.666615 ± 0.00123034 (W 0.00467397) | 🔴 fork 1.43× slower than `faer-upstream` | 🔴 fork 3.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.1297 ± 0.109528 (W 0.207674) | 9.30151 ± 0.0953461 (W 0.0482564) | 3.40519 ± 0.0128429 (W 0.00731314) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.97× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.739188 ± 0.00126955 (W 0.00903565) | 0.739751 ± 0.00978697 (W 0.00456938) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.75541 ± 0.0289081 (W 0.0233721) | 5.74111 ± 0.0131609 (W 0.0167083) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.6788 ± 0.167777 (W 0.101278) | 28.5468 ± 0.0603478 (W 0.154643) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.299949 ± 0.00348604 (W 0.00366326) | 0.315414 ± 0.00492857 (W 0.00340694) | 0.45864 ± 0.00259925 (W 0.00244598) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.01952 ± 0.00544911 (W 0.0136788) | 1.48471 ± 0.00112743 (W 0.0161481) | 0.977602 ± 0.00344584 (W 0.00308921) | 🔴 fork 1.36× slower than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.74382 ± 0.0603725 (W 0.0626329) | 9.05399 ± 0.0212638 (W 0.0761361) | 5.86198 ± 0.0398872 (W 0.0127056) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 1.66× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.990752 ± 0.00355448 (W 0.00352581) | 1.89916 ± 0.0136614 (W 0.0103824) | 1.05008 ± 0.00393276 (W 0.00486106) | 🔵 fork 1.92× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 4.43762 ± 0.0244616 (W 0.0345674) | 6.01609 ± 0.0350183 (W 0.0500676) | 5.00952 ± 0.0241272 (W 0.0107324) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 26.17 ± 0.165777 (W 0.111103) | 29.3673 ± 0.199907 (W 0.147619) | 29.1042 ± 0.0339111 (W 0.0623326) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.547445 ± 0.00396072 (W 0.00866122) | 1.40629 ± 0.0169417 (W 0.0206264) | 0.434205 ± 0.000688278 (W 0.00141566) | 🔵 fork 2.57× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.72269 ± 0.00238706 (W 0.0362698) | 4.32325 ± 0.0223362 (W 0.033298) | 1.57648 ± 0.00188665 (W 0.00354955) | 🔵 fork 1.59× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.2772 ± 0.0660709 (W 0.052418) | 14.6546 ± 0.0728659 (W 0.06262) | 11.0025 ± 0.0309209 (W 0.0126345) | 🔵 fork 1.30× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.296239 ± 0.00413845 (W 0.00282557) | 0.306508 ± 0.00314317 (W 0.0061313) | 0.447044 ± 0.00270552 (W 0.00327343) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.97652 ± 0.00778561 (W 0.0140998) | 1.3445 ± 0.00951119 (W 0.020405) | 0.855904 ± 0.00134458 (W 0.00282298) | 🔴 fork 1.47× slower than `faer-upstream` | 🔴 fork 2.31× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.314 ± 0.0528535 (W 0.0843276) | 9.52728 ± 0.045634 (W 0.0584126) | 5.30968 ± 0.0637347 (W 0.0152859) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 1.94× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.745782 ± 0.00363841 (W 0.00594376) | 0.749466 ± 0.00843165 (W 0.00430344) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.757 ± 0.0469113 (W 0.00924228) | 5.73986 ± 0.0314662 (W 0.0104022) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.7518 ± 0.165454 (W 0.12456) | 26.872 ± 0.182676 (W 0.11425) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.302183 ± 0.000992715 (W 0.00352188) | 0.338306 ± 0.00172284 (W 0.00784997) | 0.461309 ± 0.00383829 (W 0.00230514) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.02056 ± 0.00878346 (W 0.0232631) | 1.47077 ± 0.00456467 (W 0.0152888) | 0.682926 ± 0.00220953 (W 0.00511661) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 2.96× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.68879 ± 0.0569245 (W 0.0864475) | 7.98756 ± 0.0314484 (W 0.0442372) | 3.47153 ± 0.0228079 (W 0.00705429) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.50× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.12743 ± 0.00465024 (W 0.0100096) | 2.41 ± 0.0136952 (W 0.025946) | 0.792107 ± 0.0042461 (W 0.00583928) | 🔵 fork 2.14× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 4.04261 ± 0.008695 (W 0.0324853) | 6.70745 ± 0.0470707 (W 0.0497938) | 4.06167 ± 0.0110054 (W 0.00751563) | 🔵 fork 1.66× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 21.1281 ± 0.0282015 (W 0.216503) | 26.0317 ± 0.0485664 (W 0.19106) | 16.999 ± 0.0524857 (W 0.0492829) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.594542 ± 0.0038132 (W 0.00636604) | 1.8987 ± 0.0209499 (W 0.0268479) | 0.30615 ± 0.00201862 (W 0.0024574) | 🔵 fork 3.19× faster than `faer-upstream` | 🔴 fork 1.94× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.66082 ± 0.0171559 (W 0.0182303) | 5.30206 ± 0.0567745 (W 0.0613251) | 1.58031 ± 0.00446972 (W 0.00323924) | 🔵 fork 1.99× faster than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 10.1038 ± 0.076275 (W 0.161407) | 14.9408 ± 0.0689188 (W 0.105405) | 5.60194 ± 0.00638508 (W 0.00672276) | 🔵 fork 1.48× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.296251 ± 0.000275039 (W 0.00213633) | 0.325612 ± 0.00303634 (W 0.00316998) | 0.442083 ± 0.00222405 (W 0.0024009) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.49× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.97904 ± 0.00998411 (W 0.00711394) | 1.3227 ± 0.00502813 (W 0.0119988) | 0.649623 ± 0.00507978 (W 0.00257182) | 🔴 fork 1.50× slower than `faer-upstream` | 🔴 fork 3.05× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.29242 ± 0.0518599 (W 0.0430376) | 8.38356 ± 0.0771793 (W 0.0524688) | 3.29428 ± 0.135727 (W 0.00911054) | 🔴 fork 1.11× slower than `faer-upstream` | 🔴 fork 2.82× slower than `lapack-mkl` | `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.810829 ± 0.00397114 (W 0.00638163) | 0.812693 ± 0.00493463 (W 0.00531091) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 24.5736 ± 1.09097 (W 1.16298) | 23.574 ± 1.32942 (W 1.07011) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.490912 ± 0.00461249 (W 0.0124309) | 0.508753 ± 0.00701604 (W 0.00650618) | 0.530247 ± 0.116848 (W 0.00271617) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 13.094 ± 0.0381522 (W 0.0300651) | 13.0277 ± 0.0184906 (W 0.0623435) | 13.3184 ± 1.95307 (W 0.0414304) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.27682 ± 0.0133858 (W 0.0202384) | 1.70228 ± 0.0103811 (W 0.011566) | 1.06099 ± 0.00651907 (W 0.00342731) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 31.8257 ± 0.178834 (W 0.210798) | 35.3737 ± 0.0685611 (W 0.108337) | 29.9793 ± 0.384848 (W 0.0850536) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 3.54858 ± 0.161126 (W 0.114882) | 4.08856 ± 0.184128 (W 0.0932299) | 0.464514 ± 0.00750407 (W 0.00523529) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 7.64× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 71.4211 ± 0.142954 (W 0.380513) | 77.6865 ± 0.414118 (W 0.391463) | 12.6711 ± 0.080107 (W 0.0903797) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 5.64× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.811408 ± 0.00471975 (W 0.00610501) | 0.810877 ± 0.00512484 (W 0.00607578) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.5042 ± 0.062028 (W 0.0744293) | 19.4681 ± 0.998953 (W 0.790711) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.472328 ± 0.0151642 (W 0.00791339) | 0.524882 ± 0.00382856 (W 0.0121827) | 0.59703 ± 0.167742 (W 0.00558043) | 🔵 fork 1.11× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 12.2077 ± 0.0273587 (W 0.0281396) | 12.2288 ± 0.0174075 (W 0.016099) | 4.09864 ± 1.86653 (W 0.0329067) | · | 🔴 fork 2.98× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.39087 ± 0.00472527 (W 0.0264346) | 1.99151 ± 0.0294082 (W 0.0159722) | 0.883646 ± 0.00448656 (W 0.0034142) | 🔵 fork 1.43× faster than `faer-upstream` | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.0398 ± 0.0997143 (W 0.203639) | 35.1467 ± 0.19279 (W 0.466651) | 20.7694 ± 0.211161 (W 0.0706856) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 3.82194 ± 0.0238778 (W 0.139928) | 4.71071 ± 0.134822 (W 0.147265) | 0.321985 ± 0.00148726 (W 0.00176504) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 11.87× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 68.97 ± 0.316058 (W 0.278295) | 76.4745 ± 0.162122 (W 0.400628) | 7.32727 ± 0.0226449 (W 0.0567422) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 9.41× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.72944 ± 0.00236895 (W 0.00282719) | 0.728827 ± 0.000858259 (W 0.0025908) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.5603 ± 0.041915 (W 0.334679) | 17.6155 ± 0.103948 (W 0.261314) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.41013 ± 0.00228466 (W 0.01399) | 0.427461 ± 0.00267287 (W 0.00849858) | 0.284667 ± 0.0016357 (W 0.00197503) | · | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.43757 ± 0.0377906 (W 0.0352139) | 7.37627 ± 0.021444 (W 0.0382443) | 11.5941 ± 0.018814 (W 0.020011) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.20817 ± 0.00676819 (W 0.00995672) | 1.61061 ± 0.010432 (W 0.0201338) | 0.980364 ± 0.00743078 (W 0.00928532) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.1785 ± 0.227619 (W 0.214259) | 29.7342 ± 0.0495473 (W 0.120996) | 26.9266 ± 0.0633737 (W 0.0171168) | 🔵 fork 1.14× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.913342 ± 0.00546389 (W 0.0127554) | 1.3527 ± 0.0166307 (W 0.013144) | 0.419761 ± 0.00403619 (W 0.00344824) | 🔵 fork 1.48× faster than `faer-upstream` | 🔴 fork 2.18× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.6405 ± 0.224853 (W 0.15253) | 17.8055 ± 0.349174 (W 0.123412) | 11.3577 ± 0.0470572 (W 0.0543904) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729612 ± 0.00352059 (W 0.00273938) | 0.732007 ± 0.00286289 (W 0.00265334) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.773 ± 0.178582 (W 0.104761) | 13.6931 ± 0.0776032 (W 0.082638) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.390666 ± 0.00214243 (W 0.00247879) | 0.44519 ± 0.011683 (W 0.00660185) | 0.285649 ± 0.000509886 (W 0.00184319) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.70787 ± 0.0165559 (W 0.0109076) | 6.69215 ± 0.0236619 (W 0.0241845) | 3.13958 ± 0.0421654 (W 0.0142198) | · | 🔴 fork 2.14× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.31789 ± 0.0100806 (W 0.0126595) | 1.89428 ± 0.0259059 (W 0.0213206) | 0.846593 ± 0.00122038 (W 0.00311119) | 🔵 fork 1.44× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 20.1942 ± 0.197488 (W 0.441496) | 29.5116 ± 0.21448 (W 0.541338) | 19.0783 ± 0.0945341 (W 0.0436904) | 🔵 fork 1.46× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.06008 ± 0.00290674 (W 0.0124056) | 1.64794 ± 0.0230704 (W 0.0164764) | 0.299935 ± 0.00036798 (W 0.00265309) | 🔵 fork 1.55× faster than `faer-upstream` | 🔴 fork 3.53× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.5648 ± 0.15292 (W 0.0906568) | 19.26 ± 0.0320973 (W 0.0720769) | 6.48645 ± 0.0701247 (W 0.0375372) | 🔵 fork 1.67× faster than `faer-upstream` | 🔴 fork 1.78× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.80406 ± 0.0277351 (W 0.00323612) | 1.78512 ± 0.0346118 (W 0.00292914) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 65.1278 ± 0.279622 (W 0.65168) | 66.0126 ± 0.463954 (W 1.06326) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.875598 ± 0.012534 (W 0.0103878) | 0.829308 ± 0.0027057 (W 0.0128366) | 1.09788 ± 0.00241932 (W 0.00124438) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 29.6851 ± 0.0451474 (W 0.0477143) | 29.92 ± 0.0848557 (W 0.136259) | 58.0118 ± 3.22431 (W 0.186747) | · | 🔵 fork 1.95× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.80125 ± 0.0903152 (W 0.0406657) | 3.02309 ± 0.0176255 (W 0.0275559) | 3.12889 ± 0.0136611 (W 0.00636254) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 90.6727 ± 0.18769 (W 0.261483) | 98.353 ± 0.0933971 (W 0.195762) | 80.2682 ± 0.252703 (W 0.299028) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 4.45308 ± 0.0601212 (W 0.0569573) | 4.63728 ± 0.142835 (W 0.130648) | 1.38828 ± 0.00319289 (W 0.00260647) | · | 🔴 fork 3.21× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 114.314 ± 0.235652 (W 0.43525) | 124.768 ± 0.38472 (W 0.606401) | 34.0579 ± 0.0357942 (W 0.21082) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 3.36× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78205 ± 0.0334356 (W 0.00307461) | 1.78561 ± 0.00720547 (W 0.00371231) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 41.1206 ± 0.0566775 (W 0.155787) | 41.228 ± 0.0731819 (W 0.925567) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.83975 ± 0.00450103 (W 0.0079973) | 0.809939 ± 0.0317646 (W 0.010567) | 1.08662 ± 0.000806232 (W 0.00192473) | · | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 25.7799 ± 0.0595247 (W 0.0654763) | 25.9922 ± 0.0591231 (W 0.0406837) | 51.6807 ± 3.83873 (W 0.100284) | · | 🔵 fork 2.00× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.41371 ± 0.0385725 (W 0.0194217) | 3.22161 ± 0.0404332 (W 0.0271526) | 2.32873 ± 0.0136236 (W 0.00597332) | 🔵 fork 1.33× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 64.8373 ± 4.92599 (W 0.17577) | 81.721 ± 5.36012 (W 0.347987) | 45.8957 ± 0.301477 (W 0.231972) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 4.29415 ± 0.0996987 (W 0.0754111) | 4.94264 ± 0.0997792 (W 0.149968) | 0.876422 ± 0.0188462 (W 0.00241813) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 4.90× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 107.653 ± 0.838512 (W 0.868398) | 121.947 ± 0.802668 (W 0.27801) | 19.6982 ± 0.140502 (W 0.122566) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 5.47× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66672 ± 0.00624714 (W 0.0025726) | 1.66004 ± 0.00484624 (W 0.00386136) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.5769 ± 0.583389 (W 0.410008) | 52.5314 ± 0.494571 (W 0.657279) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.764632 ± 0.0107899 (W 0.00952962) | 0.725574 ± 0.00587664 (W 0.00947188) | 1.06625 ± 0.00568199 (W 0.0031388) | 🔴 fork 1.05× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.4084 ± 0.0776966 (W 0.0858947) | 17.5047 ± 0.129751 (W 0.075898) | 49.5131 ± 0.124347 (W 0.10161) | · | 🔵 fork 2.84× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.60724 ± 0.119299 (W 0.110268) | 2.9 ± 0.0154 (W 0.0147108) | 3.06039 ± 0.053351 (W 0.00740483) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 78.6981 ± 0.210387 (W 0.483718) | 86.2556 ± 0.0964327 (W 0.172351) | 74.5054 ± 0.235463 (W 0.396234) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.74699 ± 0.0789327 (W 0.0763278) | 2.12695 ± 0.00872719 (W 0.0260678) | 1.3551 ± 0.00675352 (W 0.0419064) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 35.7193 ± 0.0577747 (W 0.0919923) | 43.9471 ± 0.148124 (W 0.0847102) | 31.193 ± 0.129465 (W 0.206269) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66142 ± 0.00553615 (W 0.00443934) | 1.65512 ± 0.00374665 (W 0.00453307) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 28.9542 ± 0.272933 (W 0.288895) | 29.2341 ± 0.313082 (W 0.218907) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.72957 ± 0.00461748 (W 0.00572242) | 0.706738 ± 0.00387016 (W 0.0112489) | 1.06271 ± 0.0100175 (W 0.00204479) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.5146 ± 0.0854396 (W 0.0364185) | 13.7437 ± 0.0173137 (W 0.059106) | 49.4853 ± 0.0634434 (W 0.112482) | · | 🔵 fork 3.66× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.31411 ± 0.0446531 (W 0.0132536) | 3.12547 ± 0.0411966 (W 0.0215106) | 2.2715 ± 0.0209012 (W 0.0052264) | 🔵 fork 1.35× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 52.108 ± 5.86019 (W 0.328485) | 70.5072 ± 5.50617 (W 0.849679) | 42.3139 ± 0.119382 (W 0.21298) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.72957 ± 0.0119573 (W 0.0147033) | 2.45379 ± 0.0328323 (W 0.0300147) | 0.850715 ± 0.000822441 (W 0.00190821) | 🔵 fork 1.42× faster than `faer-upstream` | 🔴 fork 2.03× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.3511 ± 0.0502816 (W 0.085763) | 41.3127 ± 0.125455 (W 0.0551653) | 17.636 ± 0.121336 (W 0.0466467) | 🔵 fork 1.51× faster than `faer-upstream` | 🔴 fork 1.55× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 39.5984 ± 0.422723 (W 0.362581) | 39.8697 ± 0.540686 (W 0.212183) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.24131 ± 0.0129843 (W 0.00313012) | 1.24385 ± 0.0142899 (W 0.00387061) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 9.40952 ± 0.278521 (W 0.0262859) | 9.32527 ± 0.159465 (W 0.0453272) | 10.1074 ± 0.145131 (W 0.034691) | · | 🔵 fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.343418 ± 0.00680236 (W 0.00316992) | 0.378362 ± 0.0170987 (W 0.0150078) | 0.29135 ± 0.00692119 (W 0.00345645) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 13.0235 ± 0.212612 (W 0.0916223) | 14.2913 ± 0.282916 (W 0.0560281) | 17.1029 ± 0.162925 (W 0.132724) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.533804 ± 0.0252923 (W 0.00299494) | 0.772777 ± 0.0117606 (W 0.00899288) | 0.612674 ± 0.00165912 (W 0.011391) | 🔵 fork 1.45× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 10.5256 ± 0.168643 (W 0.053375) | 12.5463 ± 0.187358 (W 0.0403924) | 13.3939 ± 0.0211678 (W 0.0392968) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.671046 ± 0.0168621 (W 0.010594) | 0.919446 ± 0.0074901 (W 0.0235363) | 0.429364 ± 0.00219157 (W 0.00238838) | 🔵 fork 1.37× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.297 ± 0.24578 (W 0.12848) | 34.594 ± 0.5589 (W 0.282972) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.24126 ± 0.0185761 (W 0.00223712) | 1.2602 ± 0.0177963 (W 0.00312975) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.88095 ± 0.103466 (W 0.113624) | 7.90089 ± 0.195067 (W 0.0862245) | 6.85332 ± 1.55031 (W 0.0153887) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.330877 ± 0.0128738 (W 0.00562598) | 0.366107 ± 0.0178106 (W 0.023274) | 0.169794 ± 0.00129473 (W 0.00129781) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.95× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 11.3038 ± 0.191687 (W 0.0915928) | 13.2325 ± 0.168096 (W 0.179458) | 10.1905 ± 0.0127686 (W 0.189099) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.555689 ± 0.027492 (W 0.0246528) | 0.900707 ± 0.0120514 (W 0.020702) | 0.45419 ± 0.0122153 (W 0.0111546) | 🔵 fork 1.62× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 8.76295 ± 0.242538 (W 0.343311) | 11.7185 ± 0.0256953 (W 0.174566) | 6.97479 ± 0.0264275 (W 0.0108791) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.673586 ± 0.00943169 (W 0.0188929) | 1.09891 ± 0.0103234 (W 0.0183956) | 0.256506 ± 0.00107255 (W 0.00202783) | 🔵 fork 1.63× faster than `faer-upstream` | 🔴 fork 2.63× slower than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.141 ± 0.227741 (W 0.148985) | 34.9658 ± 0.269265 (W 0.15085) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05195 ± 0.000846522 (W 0.00189329) | 1.05399 ± 0.00399216 (W 0.00435707) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.59851 ± 0.0203235 (W 0.0443793) | 4.66471 ± 0.00840913 (W 0.0231145) | 5.26692 ± 0.00528402 (W 0.00846372) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.145629 ± 0.00169028 (W 0.00214253) | 0.170173 ± 0.0018771 (W 0.00453879) | 0.236327 ± 0.00254371 (W 0.00338108) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 8.24625 ± 0.0642503 (W 0.064763) | 9.50579 ± 0.0441759 (W 0.0675047) | 26.5905 ± 0.076909 (W 0.0706069) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 3.22× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.326426 ± 0.00478292 (W 0.019466) | 0.554409 ± 0.0014746 (W 0.0119931) | 0.613085 ± 0.00673402 (W 0.0035405) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.88× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 7.2261 ± 0.0429269 (W 0.0457754) | 8.45882 ± 0.0418188 (W 0.0774895) | 11.3106 ± 0.0183044 (W 0.0211719) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.252949 ± 0.0138569 (W 0.0150779) | 0.488765 ± 0.00727352 (W 0.00836897) | 0.36829 ± 0.000877127 (W 0.00258582) | 🔵 fork 1.93× faster than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.0087 ± 0.394526 (W 0.133869) | 30.4552 ± 0.386561 (W 0.121339) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.054 ± 0.00653118 (W 0.00290502) | 1.05157 ± 0.0130856 (W 0.00585122) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 3.07488 ± 0.0307233 (W 0.115528) | 3.33165 ± 0.022503 (W 0.110824) | 3.17523 ± 0.0307851 (W 0.00799922) | 🔵 fork 1.08× faster than `faer-upstream` | · |  |
| `lu/64x1024/b1` | 0.124255 ± 0.00234719 (W 0.00695636) | 0.161269 ± 0.000981662 (W 0.00697871) | 0.132195 ± 0.00267926 (W 0.00125699) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 6.53257 ± 0.00878219 (W 0.367686) | 8.58375 ± 0.0557754 (W 0.298401) | 18.9506 ± 0.0815644 (W 0.0578409) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 2.90× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.334741 ± 0.00570115 (W 0.0191389) | 0.725424 ± 0.0139454 (W 0.0181693) | 0.476121 ± 0.00114862 (W 0.00279484) | 🔵 fork 2.17× faster than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 5.40576 ± 0.168039 (W 0.139698) | 7.26875 ± 0.145713 (W 0.212911) | 5.87081 ± 0.00715405 (W 0.00580204) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.261964 ± 0.00296777 (W 0.0116914) | 0.63341 ± 0.00213709 (W 0.0199802) | 0.21572 ± 0.00146858 (W 0.00270844) | 🔵 fork 2.42× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 97.5684 ± 3.28987 (W 0.746584) | 97.3666 ± 2.79905 (W 0.375185) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.37238 ± 0.0600629 (W 0.0140368) | 2.42458 ± 0.0335378 (W 0.0165479) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.6046 ± 0.0949021 (W 0.106075) | 18.0094 ± 0.162566 (W 0.0824364) | 23.6378 ± 3.19795 (W 0.118533) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.487856 ± 0.00258986 (W 0.00436418) | 0.494869 ± 0.00478041 (W 0.00519648) | 0.642078 ± 0.00185427 (W 0.00289642) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 33.1778 ± 0.219544 (W 0.155944) | 34.8171 ± 0.358251 (W 0.153371) | 45.5045 ± 0.103899 (W 0.0534355) | · | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 1.02846 ± 0.00466735 (W 0.00232655) | 1.29759 ± 0.0337628 (W 0.00973474) | 1.66184 ± 0.00479683 (W 0.00394076) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 28.1995 ± 1.40001 (W 0.189575) | 30.4473 ± 0.444068 (W 0.0558858) | 39.3849 ± 0.107108 (W 0.063802) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 1.0656 ± 0.0278148 (W 0.0213024) | 1.326 ± 0.00465164 (W 0.023245) | 1.35766 ± 0.00453641 (W 0.00242638) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 69.251 ± 0.471465 (W 0.379254) | 69.7701 ± 0.413575 (W 0.465553) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.53292 ± 0.0412668 (W 0.0114501) | 2.52648 ± 0.0352908 (W 0.00904432) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 12.9098 ± 0.159052 (W 0.0793905) | 12.3321 ± 0.149071 (W 0.0776715) | 18.6128 ± 2.96689 (W 0.105718) | · | 🔵 fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.402968 ± 0.00644276 (W 0.00463875) | 0.403368 ± 0.00579146 (W 0.00329552) | 0.447991 ± 0.00505341 (W 0.00188993) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 22.8247 ± 0.228299 (W 0.778107) | 25.4635 ± 0.318226 (W 0.535719) | 26.4843 ± 0.121277 (W 0.0744104) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.940811 ± 0.0197988 (W 0.00957816) | 1.37039 ± 0.0166685 (W 0.0285539) | 1.02267 ± 0.00068572 (W 0.00321681) | 🔵 fork 1.46× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 19.3789 ± 0.372236 (W 0.717476) | 21.5882 ± 0.503073 (W 0.693254) | 21.0847 ± 0.031055 (W 0.0503784) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.932334 ± 0.00541788 (W 0.0116702) | 1.40076 ± 0.00440769 (W 0.0233482) | 0.767663 ± 0.00066176 (W 0.00140408) | 🔵 fork 1.50× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.5406 ± 2.77103 (W 0.676206) | 92.2985 ± 2.45621 (W 0.534051) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.20061 ± 0.0794327 (W 0.00993709) | 2.20327 ± 0.0669101 (W 0.0114669) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 13.6397 ± 0.137502 (W 0.104809) | 13.9517 ± 0.0725692 (W 0.0446322) | 20.5497 ± 0.0547908 (W 0.0163924) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.324677 ± 0.00135363 (W 0.00249237) | 0.323971 ± 0.00237016 (W 0.00363848) | 0.588921 ± 0.00321268 (W 0.00352937) | · | 🔵 fork 1.81× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 29.0557 ± 0.114325 (W 0.0686644) | 30.1282 ± 0.208879 (W 0.0748915) | 55.4428 ± 2.8579 (W 0.127692) | · | 🔵 fork 1.91× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.897986 ± 0.0131279 (W 0.00637821) | 1.14975 ± 0.0146716 (W 0.0199704) | 1.66138 ± 0.00512098 (W 0.0108964) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 1.85× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 25.9843 ± 0.129034 (W 0.0817048) | 27.1282 ± 0.110068 (W 0.0463395) | 36.2727 ± 0.122073 (W 0.0354656) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.701077 ± 0.0138427 (W 0.00255724) | 0.960703 ± 0.00572811 (W 0.00793248) | 1.28131 ± 0.000746151 (W 0.00398124) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.83× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 65.2419 ± 0.225653 (W 0.577867) | 65.1092 ± 0.586362 (W 0.550881) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.29516 ± 0.0457598 (W 0.00679819) | 2.28959 ± 0.0279744 (W 0.00801526) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.61635 ± 0.0655196 (W 0.0490183) | 8.32031 ± 0.0584338 (W 0.0354117) | 11.2573 ± 0.0119784 (W 0.0268144) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.243351 ± 0.00602253 (W 0.00682767) | 0.242399 ± 0.00448941 (W 0.00322876) | 0.411792 ± 0.00342517 (W 0.00265003) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 19.0977 ± 0.58862 (W 0.641788) | 20.8417 ± 0.305804 (W 0.57917) | 37.0264 ± 0.554425 (W 0.0773648) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.94× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.784345 ± 0.0222125 (W 0.0160981) | 1.212 ± 0.0152934 (W 0.0216628) | 1.25208 ± 0.271097 (W 0.00563132) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 16.0934 ± 0.808025 (W 0.630303) | 18.6616 ± 0.65247 (W 0.619081) | 18.6812 ± 0.0503238 (W 0.0146197) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.598978 ± 0.00635498 (W 0.0103953) | 1.00778 ± 0.0167552 (W 0.0272073) | 0.70775 ± 0.00176428 (W 0.00183298) | 🔵 fork 1.68× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
