# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `7452d2457aeddab2a4f6535420e7f1eda82cc341`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `7c1d7a5741a132606af955e837057e8da7bc8c4f`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `419bee380e47f9cc73efb66461095f83363f08011468948aa36fce2d2277a51a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T01:18:00.738996Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin,qr_factor,eigh --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label dqds-blast --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T000823Z-dqds-blast/`

## What was measured

- **Workload** — Direct calls into one faer revision: square and rectangular dense matrices, C (row-major) and F (column-major) order, `f64` and `c64`. A shape is `N` for square, `MxN` for rectangular, or `MxKxN` for `gemm`, which is a three-index operation and cannot be written as two. Sizes are the matrix dimensions, not a memory budget, so a case name says exactly what was factored. `gemm` measures `linalg::matmul::matmul` into a caller-prepared destination with `Accum::Replace`; there is no operator path, so one shape is one work.
  Source: The fork's own public API (`faer/src/linalg`): `matmul`, the QR factor and composite, `upgrade_householder_factor`, the block/sequence Householder apply, LU and full-pivot LU, Cholesky, triangular solve, solve, thin SVD, singular values and the symmetric/nonsymmetric eigensolvers. Inputs are seeded from the case, so `verify` and `run` measure the same matrices and a rerun is reproducible.
  Known blind spot: Only the faer entry points are measured. tlinalg's packing, batch loop and lane policy, tenferro's tensor construction and dtype dispatch, and the small-`m` decode-projection shapes are other repositories' rows (tlinalg-benchmark, tenferro-benchmark).
  Known blind spot: Vendor C-order cells use CBLAS/LAPACKE row-major entry points. Workspace allocation or layout conversion internal to those APIs remains timed; these are not prepared-column-major or transpose measurements.
  Known blind spot: `gemm` covers the tall class's two Householder legs (a 16-wide basis and a 240-column target over 4096 rows: the reduction and the write-back) beside a vendor `?gemm` on the same leg. A single leg beside a vendor gemm is a diagnostic reference, not the equivalent implementation of the whole update, and the row is labelled accordingly.
  Known blind spot: `householder_apply` measures block apply and the one-block sequence form as two distinct rows, labelled with basis width min(m,n) and target width n. QR fixture preparation is outside timing. Independently varied basis/target widths and multi-panel sequences are not covered.
  Known blind spot: Allocation performed inside the measured call stays inside the clock. The fork's two row splits allocate their partial buffers inside the public call, and the public scratch function does not expose them; the campaign reports that as it is instead of changing faer's API to make the boundary look cleaner.
  Known blind spot: `cholesky`, `eigh`, `solve` and `triangular_solve` are measured on square shapes only: the matrix they factor or solve with is square by definition (self-adjoint for the first two, a triangular factor for the last). `lu` and `full_piv_lu` are not gated that way -- they take the declared rectangular shapes too, with `min(m, n)` pivots and a trapezoidal `L` or `U`, which is what `dgetrf` does as well -- so a rectangular LU cell is measured in both orders beside its square one.
  Known blind spot: `f32`/`c32` are declared and measured as of `docs/harness-dtype-axis.md`; the vendor arm has a route for `gemm` in those two dtypes and reports the LAPACK families as skipped for them. The large regime's 1024 shapes, BLIS, sparse, iterative and GPU arms are later declarations, not machinery built now.
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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.66%, worst 3223.38% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 78 of 1800 engine cells exceed 5% and carry `!`; median within-process relative SD 0.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
The `vs faer-fork` column is the rotation-averaged ratio
exp(mean over starts of log(engine median / faer-fork median)),
with the per-start ratios beside it: `R > 1`
means the engine was slower than that first-declared row in that start. It removes a
row-position
effect only under one position effect shared by the engines and stable across starts,
and only where every declared engine has a measured row (`*` marks a cell where one has
no row, so no ratio there is position-balanced). `!` marks a cell where some engine's own
per-start median range exceeds 5% of its median, and `p` a balanced cell whose estimated
position-effect ratio exceeds 1.05. Flagged cells are retained, not discarded; the
between-start variation can exceed the difference being compared.
The `vs` columns mark only differences larger than the spread this run recorded for those
two rows (combined between-start SD, floored at 5%), always with the measured library as the subject:
`🔵 <row> X faster than <row>` / `🔴 <row> X slower than <row>` (the subject is the first column of the table, the compared row is named in
the cell, not only in the column header), `·` inside the band, `-` that row is not
measured in this arm. `notes` carries the cell warnings (`*` a declared row has no measurement,
`!` between-start range over 5%, `p` position effect over 5%, dispatch-dominated means the
row is under 20 us so 4T/8T pay thread-region start-up). Per-start ratios and every
chronological sample are in the run directory named at the top of this page (`run*.csv`).
These describe the recorded revisions; they are not a regression claim.

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112742 ± 0.000623173 (W 0.00025723) | 0.112853 ± 0.000433505 (W 0.00145365) | 0.100529 ± 3.22335e-05 (W 0.000899979) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.488669 ± 0.00357929 (W 0.0017346) | 0.485003 ± 0.00158412 (W 0.00159334) | 0.395163 ± 0.000745338 (W 0.00183908) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16625 ± 0.0018262 (W 0.00186725) | 1.15805 ± 0.00453541 (W 0.00218133) | 0.911971 ± 0.00531229 (W 0.00612851) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.024346 ± 4.99032e-05 (W 0.000140475) | 0.028223 ± 5.63057e-05 (W 0.000147174) | 0.014197 ± 0.000105453 (W 4.57635e-05) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.0916 ± 0.000345231 (W 0.00107186) | 0.130443 ± 0.000143744 (W 0.000284347) | 0.298998 ± 0.134496 (W 0.00167151) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 3.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.201504 ± 0.00123097 (W 0.00156) | 0.286294 ± 0.000717526 (W 0.001458) | 0.204434 ± 0.000658016 (W 0.00158722) | 🔵 faer-fork 1.42× faster than `faer-upstream` | · |  |
| `svd_thin/n32/b1` | 0.185374 ± 0.00121327 (W 0.000897078) | 0.183621 ± 0.0012507 (W 0.00111931) | 0.17805 ± 0.000282164 (W 0.00150089) | · | · |  |
| `svd_thin/n64/b1` | 0.915669 ± 0.00316618 (W 0.0013329) | 0.914887 ± 0.00244307 (W 0.00121783) | 0.721057 ± 0.00416104 (W 0.00307962) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.16421 ± 0.00214973 (W 0.00186088) | 2.15252 ± 0.00294923 (W 0.0029708) | 1.78347 ± 0.00329645 (W 0.00385488) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.130195 ± 0.000759384 (W 0.000186894) | 0.140892 ± 0.000779758 (W 0.00111691) | 0.06442 ± 0.0429329 (W 0.00145737) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.47997 ± 0.000964934 (W 0.00177172) | 0.518997 ± 0.00339318 (W 0.00200297) | 0.264838 ± 0.000511578 (W 0.00156037) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06832 ± 0.00280897 (W 0.00107847) | 1.18569 ± 0.0031697 (W 0.0015412) | 0.627952 ± 0.000288512 (W 0.00182677) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112959 ± 0.000325426 (W 0.00132681) | 0.113052 ± 0.000404823 (W 0.00116732) | 0.105707 ± 0.000265757 (W 0.00017442) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.498571 ± 0.00396267 (W 0.00612256) | 0.502307 ± 0.00158159 (W 0.00240328) | 0.273077 ± 0.000691265 (W 0.00157667) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21605 ± 0.00699336 (W 0.0116328) | 1.2144 ± 0.00181788 (W 0.0270647) | 0.595099 ± 0.00248589 (W 0.0020625) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.024235 ± 7.16961e-05 (W 6.51782e-05) | 0.0909 ± 0.00130617 (W 0.00454177) | 0.014076 ± 0.00023918 (W 8.78595e-05) | 🔵 faer-fork 3.75× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.125226 ± 0.0148164 (W 0.00964863) | 0.450928 ± 0.00513196 (W 0.0112015) | 0.298441 ± 0.134198 (W 0.00175113) | 🔵 faer-fork 3.60× faster than `faer-upstream` | 🔵 faer-fork 2.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.230749 ± 0.0194667 (W 0.00899024) | 0.945734 ± 0.005778 (W 0.0151897) | 0.943541 ± 0.00111424 (W 0.000772918) | 🔵 faer-fork 4.10× faster than `faer-upstream` | 🔵 faer-fork 4.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.183501 ± 0.000385339 (W 0.0010043) | 0.182801 ± 0.000420344 (W 0.00120802) | 0.185847 ± 0.00037279 (W 0.00108301) | · | · |  |
| `svd_thin/n64/b1` | 0.949014 ± 0.00175116 (W 0.00231937) | 0.949812 ± 0.00312362 (W 0.00218153) | 0.677544 ± 0.00528226 (W 0.00242504) | · | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.2913 ± 0.0222702 (W 0.0216733) | 2.26837 ± 0.00668677 (W 0.0122507) | 1.49592 ± 0.0102705 (W 0.00714132) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.130474 ± 0.000128001 (W 0.00144874) | 0.140581 ± 0.00086742 (W 0.00139049) | 0.064451 ± 0.042849 (W 0.000117175) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.481033 ± 0.00104152 (W 0.00195524) | 0.518613 ± 0.00209989 (W 0.00182024) | 0.269547 ± 0.000453185 (W 0.00174463) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06623 ± 0.0011102 (W 0.00123715) | 1.18383 ± 0.00160147 (W 0.00214498) | 0.605293 ± 0.0057583 (W 0.00178392) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112661 ± 0.000384097 (W 0.00154143) | 0.112298 ± 0.00123296 (W 0.00100623) | 0.106438 ± 0.000252639 (W 0.000305161) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.510749 ± 0.00503953 (W 0.00499072) | 0.506862 ± 0.00237072 (W 0.00425853) | 0.263685 ± 0.000813329 (W 0.00124321) | · | 🔴 faer-fork 1.94× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.25558 ± 0.0139579 (W 0.022597) | 1.24155 ± 0.0135681 (W 0.0168089) | 0.577835 ± 0.00456739 (W 0.00241412) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.024225 ± 5.85947e-05 (W 5.69403e-05) | 0.121507 ± 0.00131877 (W 0.00809934) | 0.014066 ± 4.78226e-05 (W 5.26308e-05) | 🔵 faer-fork 5.02× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.12267 ± 0.0050173 (W 0.0023716) | 0.628971 ± 0.0136082 (W 0.0167433) | 0.298341 ± 0.13396 (W 0.00141733) | 🔵 faer-fork 5.13× faster than `faer-upstream` | 🔵 faer-fork 2.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.234187 ± 0.00372987 (W 0.00813293) | 1.29247 ± 0.0310073 (W 0.0189725) | 0.938801 ± 0.000738442 (W 0.000933579) | 🔵 faer-fork 5.52× faster than `faer-upstream` | 🔵 faer-fork 4.01× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.183911 ± 0.000339083 (W 0.00129353) | 0.183131 ± 0.000850512 (W 0.00178663) | 0.186731 ± 5.11599e-05 (W 0.00129816) | · | · |  |
| `svd_thin/n64/b1` | 0.96438 ± 0.00372388 (W 0.00317604) | 0.961786 ± 0.00204933 (W 0.00182701) | 0.660169 ± 0.00192528 (W 0.00209344) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.3078 ± 0.0104251 (W 0.0117502) | 2.3069 ± 0.00672166 (W 0.0153562) | 1.43401 ± 0.0035534 (W 0.00430555) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.129935 ± 0.000252951 (W 0.00138554) | 0.139973 ± 0.000498162 (W 0.00126361) | 0.06454 ± 0.0426986 (W 0.000107842) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 2.01× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.487114 ± 0.00204502 (W 0.00173215) | 0.523888 ± 0.00214604 (W 0.00215712) | 0.270013 ± 0.000764788 (W 0.00106257) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06719 ± 0.00153848 (W 0.00251894) | 1.18432 ± 0.00217504 (W 0.00193387) | 0.597165 ± 0.00102582 (W 0.00144148) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.113051 ± 0.000173765 (W 0.000250075) | 0.112833 ± 0.000245599 (W 0.00103378) | 0.098915 ± 0.000110871 (W 0.00136243) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.487781 ± 0.000571294 (W 0.00175078) | 0.486005 ± 0.00219246 (W 0.0014799) | 0.387623 ± 0.000364933 (W 0.0031153) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16428 ± 0.0040468 (W 0.00181767) | 1.1603 ± 0.00314103 (W 0.0018095) | 0.897866 ± 0.00257212 (W 0.00616132) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017933 ± 7.02163e-05 (W 0.000142433) | 0.018044 ± 0.000143643 (W 0.000106837) | 0.011581 ± 0.000140524 (W 6.0616e-05) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.075982 ± 0.000415861 (W 0.000188969) | 0.074189 ± 0.000384318 (W 0.000238794) | 0.28957 ± 0.000160851 (W 0.00133759) | · | 🔵 faer-fork 3.81× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.166503 ± 0.00113683 (W 0.00148637) | 0.163064 ± 0.00116574 (W 0.00153389) | 0.930186 ± 0.000645299 (W 0.00118393) | · | 🔵 faer-fork 5.59× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.187037 ± 0.00109456 (W 0.00125872) | 0.185765 ± 0.00147641 (W 0.00164999) | 0.168795 ± 0.000601592 (W 0.000852159) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.958569 ± 0.0024511 (W 0.00108104) | 0.957917 ± 0.0034363 (W 0.00111399) | 0.697594 ± 0.0023662 (W 0.00272235) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.1598 ± 0.00125203 (W 0.00279905) | 2.14726 ± 0.00085543 (W 0.00252463) | 1.61902 ± 0.00271956 (W 0.00573581) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.135693 ± 0.000554059 (W 0.000198855) | 0.142368 ± 0.000783047 (W 0.00124873) | 0.059422 ± 0.000100719 (W 0.00011887) | · | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.479375 ± 0.00128023 (W 0.00143585) | 0.540097 ± 0.00271433 (W 0.00189173) | 0.254121 ± 0.00077804 (W 0.00154423) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.89× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05627 ± 0.00238755 (W 0.000860798) | 1.19141 ± 0.0023572 (W 0.00121461) | 0.608576 ± 0.00100492 (W 0.00185065) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.113181 ± 0.000415284 (W 0.00153921) | 0.11279 ± 0.000372446 (W 0.00109091) | 0.103974 ± 0.000184131 (W 0.000191887) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.500714 ± 0.00164871 (W 0.00294242) | 0.503407 ± 0.00542003 (W 0.00273065) | 0.265355 ± 0.0006387 (W 0.00153579) | · | 🔴 faer-fork 1.89× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.2307 ± 0.0180409 (W 0.0168082) | 1.20779 ± 0.0056121 (W 0.0198866) | 0.579732 ± 0.00281142 (W 0.00174368) | · | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017964 ± 4.38216e-05 (W 0.000120462) | 0.077826 ± 0.00285336 (W 0.00286443) | 0.011591 ± 4.0501e-05 (W 0.00147706) | 🔵 faer-fork 4.33× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.094798 ± 0.00934758 (W 0.00734979) | 0.401595 ± 0.012325 (W 0.0102081) | 0.289394 ± 0.000249471 (W 0.00146562) | 🔵 faer-fork 4.24× faster than `faer-upstream` | 🔵 faer-fork 3.05× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.22851 ± 0.00685705 (W 0.0104165) | 0.826655 ± 0.0260019 (W 0.00788085) | 0.93042 ± 0.000647891 (W 0.000548258) | 🔵 faer-fork 3.62× faster than `faer-upstream` | 🔵 faer-fork 4.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.185576 ± 4.00791e-05 (W 0.00150709) | 0.184644 ± 0.000141896 (W 0.00112755) | 0.176279 ± 0.00030047 (W 0.000629059) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.995057 ± 0.00325348 (W 0.00316253) | 0.991343 ± 0.00263407 (W 0.00269316) | 0.641707 ± 0.00202471 (W 0.0017994) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.26456 ± 0.0408403 (W 0.0201503) | 2.25647 ± 0.00929588 (W 0.0222033) | 1.37366 ± 0.0015273 (W 0.00178597) | · | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.135315 ± 8.04301e-05 (W 0.00185535) | 0.142114 ± 0.000578927 (W 0.00121304) | 0.05944 ± 0.000188789 (W 9.83362e-05) | · | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.47996 ± 0.000439074 (W 0.0023721) | 0.538563 ± 0.00280605 (W 0.00176036) | 0.257798 ± 0.000692505 (W 0.00133144) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05701 ± 0.000144762 (W 0.00112655) | 1.18955 ± 0.000908337 (W 0.00166732) | 0.603646 ± 0.00154199 (W 0.00240725) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112932 ± 0.000427617 (W 0.00147245) | 0.112691 ± 0.000121248 (W 0.00136947) | 0.104885 ± 0.000138568 (W 0.000518786) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.504707 ± 0.00379251 (W 0.00352029) | 0.505559 ± 0.00159648 (W 0.00337646) | 0.259324 ± 0.000932465 (W 0.00217353) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.25515 ± 0.015114 (W 0.0254371) | 1.25381 ± 0.00536226 (W 0.0200243) | 0.564713 ± 0.00131203 (W 0.00209019) | · | 🔴 faer-fork 2.22× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.018014 ± 5.55608e-05 (W 8.79562e-05) | 0.116628 ± 2.16825 (W 0.00740017) | 0.011532 ± 3.46458e-05 (W 4.22528e-05) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.094826 ± 0.000391035 (W 0.00116012) | 0.571994 ± 0.0181119 (W 0.0125277) | 0.289885 ± 0.000382879 (W 0.00169419) | 🔵 faer-fork 6.03× faster than `faer-upstream` | 🔵 faer-fork 3.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.211322 ± 0.00170748 (W 0.0073388) | 1.13965 ± 0.014074 (W 0.0224696) | 0.929635 ± 0.00156383 (W 0.00160337) | 🔵 faer-fork 5.39× faster than `faer-upstream` | 🔵 faer-fork 4.40× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.186085 ± 0.000346852 (W 0.00159422) | 0.185086 ± 0.000454927 (W 0.00173327) | 0.177624 ± 0.000423949 (W 0.00146499) | · | · |  |
| `svd_thin/n64/b1` | 1.00623 ± 0.00236395 (W 0.00289013) | 1.00731 ± 0.000877684 (W 0.00521885) | 0.641236 ± 0.000207676 (W 0.00199382) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31305 ± 0.010241 (W 0.0187169) | 2.3085 ± 0.00478481 (W 0.0099231) | 1.32436 ± 0.00142674 (W 0.00215747) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.135241 ± 0.00026695 (W 0.00207542) | 0.141793 ± 0.000440388 (W 0.00210934) | 0.059361 ± 0.000101658 (W 7.82304e-05) | · | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.484715 ± 0.00170771 (W 0.00204282) | 0.544571 ± 0.00199819 (W 0.0022924) | 0.259484 ± 0.00133286 (W 0.00168972) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05637 ± 0.00237 (W 0.00130763) | 1.18918 ± 0.00105361 (W 0.00130265) | 0.602692 ± 0.00378094 (W 0.00178763) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.142378 ± 0.000371263 (W 0.00137188) | 0.141817 ± 0.000461392 (W 0.00132449) | 0.15105 ± 0.00018413 (W 0.00118161) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.651138 ± 0.00176169 (W 0.00146356) | 0.648991 ± 0.00132684 (W 0.00184864) | 0.814752 ± 0.000838634 (W 0.00454408) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.6224 ± 0.00129448 (W 0.00242655) | 1.61602 ± 0.00183339 (W 0.00184568) | 2.03276 ± 0.00302569 (W 0.00185229) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040947 ± 0.000208511 (W 0.000274424) | 0.045907 ± 0.000467752 (W 0.000419858) | 0.028864 ± 0.0479195 (W 6.80441e-05) | 🔵 faer-fork 1.12× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.181359 ± 0.00126543 (W 0.00133641) | 0.239104 ± 0.000662732 (W 0.00156094) | 0.166654 ± 0.000271331 (W 0.000188184) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.437511 ± 0.00308048 (W 0.00201914) | 0.542962 ± 0.00400517 (W 0.00174597) | 0.517013 ± 0.00110687 (W 0.00179803) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.235036 ± 0.00156237 (W 0.00181501) | 0.235911 ± 0.000795997 (W 0.00176262) | 0.253032 ± 0.000621941 (W 0.00207533) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23133 ± 0.00418121 (W 0.00204402) | 1.22504 ± 0.00441283 (W 0.0015146) | 1.34663 ± 0.00176445 (W 0.00250053) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.14537 ± 0.00643558 (W 0.00175689) | 3.1343 ± 0.0144743 (W 0.00352313) | 3.49029 ± 0.00745302 (W 0.00296614) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.151301 ± 0.000516164 (W 0.00135917) | 0.16174 ± 0.000664477 (W 0.00160006) | 0.102803 ± 0.121909 (W 0.000128881) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.589238 ± 0.00176206 (W 0.00155243) | 0.651739 ± 0.00140191 (W 0.00143458) | 0.493449 ± 0.000366839 (W 0.00194032) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.37718 ± 0.00137149 (W 0.00259054) | 1.51931 ± 0.00476353 (W 0.00195569) | 1.37561 ± 0.00535787 (W 0.00227636) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.142147 ± 0.000186652 (W 0.00137495) | 0.142005 ± 0.000389205 (W 0.000438657) | 0.156154 ± 0.000658959 (W 0.00136186) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.63855 ± 0.00202916 (W 0.0033501) | 0.635564 ± 0.00167716 (W 0.00235233) | 0.565269 ± 0.000583586 (W 0.00158166) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.5531 ± 0.0126084 (W 0.0190135) | 1.54075 ± 0.0118012 (W 0.00900409) | 1.15668 ± 0.00124754 (W 0.00280774) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040986 ± 0.00017872 (W 0.000275694) | 0.10741 ± 0.00177307 (W 0.00303693) | 0.029054 ± 0.0477632 (W 0.000108555) | 🔵 faer-fork 2.62× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.191688 ± 0.00694605 (W 0.00443846) | 0.599924 ± 0.00839795 (W 0.0186941) | 0.762313 ± 0.345593 (W 0.00148178) | 🔵 faer-fork 3.13× faster than `faer-upstream` | 🔵 faer-fork 3.98× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.385165 ± 0.0258284 (W 0.00315689) | 1.14412 ± 0.00501848 (W 0.0201731) | 2.45802 ± 0.00303784 (W 0.0030157) | 🔵 faer-fork 2.97× faster than `faer-upstream` | 🔵 faer-fork 6.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.234104 ± 0.000562921 (W 0.00128914) | 0.234752 ± 0.000272194 (W 0.00163669) | 0.260363 ± 0.000499989 (W 0.00115423) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.19805 ± 0.00252802 (W 0.00360674) | 1.19879 ± 0.00330436 (W 0.00205008) | 1.03205 ± 0.00192745 (W 0.00140804) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.99198 ± 0.0286306 (W 0.0201814) | 2.99214 ± 0.0103995 (W 0.018989) | 2.5276 ± 0.00108895 (W 0.00490528) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.150791 ± 0.000333605 (W 0.00110806) | 0.161441 ± 0.000254168 (W 0.0012552) | 0.102382 ± 0.121911 (W 0.00156643) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.588917 ± 0.00190918 (W 0.0019794) | 0.650625 ± 0.0019779 (W 0.00197945) | 0.490386 ± 0.000568177 (W 0.00158236) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36781 ± 0.00144208 (W 0.00163759) | 1.51102 ± 0.00341083 (W 0.00214217) | 1.38951 ± 0.0174158 (W 0.00533457) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.142236 ± 0.000215632 (W 0.00155447) | 0.142326 ± 0.00048727 (W 0.00152331) | 0.156784 ± 0.000160793 (W 0.0015724) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.64444 ± 0.000642391 (W 0.00410877) | 0.647983 ± 0.00371925 (W 0.00761396) | 0.541255 ± 0.00139752 (W 0.00216368) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.5414 ± 0.00671927 (W 0.0163093) | 1.58976 ± 0.0118842 (W 0.0201161) | 1.03794 ± 0.00274337 (W 0.00219671) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040957 ± 0.000108076 (W 0.000173794) | 0.136684 ± 0.000727896 (W 0.00278425) | 0.029305 ± 0.0476304 (W 0.000108163) | 🔵 faer-fork 3.34× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.182813 ± 0.0137122 (W 0.00145643) | 0.757947 ± 0.0214468 (W 0.0262381) | 0.762803 ± 0.345546 (W 0.00116466) | 🔵 faer-fork 4.15× faster than `faer-upstream` | 🔵 faer-fork 4.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.427978 ± 0.00715526 (W 0.00985648) | 1.49876 ± 0.0134361 (W 0.0288971) | 2.45433 ± 0.00341204 (W 0.00163483) | 🔵 faer-fork 3.50× faster than `faer-upstream` | 🔵 faer-fork 5.73× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.23627 ± 0.00034827 (W 0.00195148) | 0.235858 ± 0.000704433 (W 0.00105651) | 0.263321 ± 0.000520032 (W 0.00134767) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21385 ± 0.00352349 (W 0.00652007) | 1.22924 ± 0.00610969 (W 0.0118261) | 0.990949 ± 0.0010794 (W 0.00136234) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.97615 ± 0.00443298 (W 0.0189955) | 3.07823 ± 0.00954863 (W 0.0115465) | 2.34236 ± 0.00198586 (W 0.0033045) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.151111 ± 0.000792082 (W 0.0015236) | 0.162042 ± 0.000980658 (W 0.00135831) | 0.102593 ± 0.121897 (W 0.00120282) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.590091 ± 0.000283466 (W 0.00186277) | 0.653423 ± 0.00239994 (W 0.00151188) | 0.493546 ± 0.00224543 (W 0.00161149) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.37027 ± 0.00196244 (W 0.00191117) | 1.51054 ± 0.00669836 (W 0.00236648) | 1.36145 ± 0.0197 (W 0.0041128) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.142244 ± 0.000223974 (W 0.00120034) | 0.141727 ± 0.000248 (W 0.00169689) | 0.149188 ± 0.000256416 (W 0.00154118) | · | · |  |
| `eigh/n64/b1` | 0.650294 ± 0.000944437 (W 0.00170212) | 0.64858 ± 0.000538897 (W 0.00170914) | 0.802098 ± 0.00151026 (W 0.00287258) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.62547 ± 0.00320794 (W 0.0026329) | 1.61418 ± 0.00452259 (W 0.00274667) | 2.00911 ± 0.00227265 (W 0.00139975) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033843 ± 0.000204858 (W 0.000285511) | 0.033763 ± 0.000199826 (W 0.000273944) | 0.026199 ± 7.5831e-05 (W 6.55744e-05) | · | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.164517 ± 0.000446015 (W 0.000586578) | 0.163107 ± 0.000695245 (W 0.00157382) | 0.756304 ± 0.00043816 (W 0.00152416) | · | 🔵 faer-fork 4.60× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.404956 ± 0.00175645 (W 0.00225407) | 0.400083 ± 0.000783023 (W 0.00157319) | 2.44267 ± 0.00329857 (W 0.00521519) | · | 🔵 faer-fork 6.03× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232932 ± 0.00078111 (W 0.00176584) | 0.232692 ± 0.000586725 (W 0.00141494) | 0.249894 ± 0.000566667 (W 0.00155754) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.26392 ± 0.00528778 (W 0.00219008) | 1.25878 ± 0.0056493 (W 0.00175795) | 1.3157 ± 0.00168602 (W 0.00209403) | · | · |  |
| `svd_thin/n96/b1` | 3.10012 ± 0.00732669 (W 0.00321814) | 3.09047 ± 0.00979839 (W 0.00363371) | 3.43171 ± 0.00761978 (W 0.00379476) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.153979 ± 0.000825523 (W 0.000151213) | 0.160242 ± 0.00103348 (W 0.00132159) | 0.100456 ± 0.000473079 (W 0.000206088) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.594784 ± 0.000196924 (W 0.00163325) | 0.628433 ± 0.000737633 (W 0.00188953) | 0.480852 ± 0.00119439 (W 0.00187918) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.37478 ± 0.00278543 (W 0.00227671) | 1.4889 ± 0.00431017 (W 0.00188184) | 1.3414 ± 0.00273398 (W 0.00223488) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141855 ± 0.000535409 (W 0.000983665) | 0.141995 ± 0.000295935 (W 0.00145573) | 0.153737 ± 0.00022858 (W 0.00123241) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.641587 ± 0.0168824 (W 0.0120011) | 0.637188 ± 0.0014909 (W 0.00402995) | 0.555895 ± 0.0019057 (W 0.00189286) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54271 ± 0.00192539 (W 0.0156376) | 1.53605 ± 0.00435095 (W 0.0101745) | 1.13881 ± 0.00311651 (W 0.00224572) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033943 ± 0.000224829 (W 0.000419726) | 0.09581 ± 0.00138449 (W 0.00258247) | 0.026119 ± 8.3865e-05 (W 8.10555e-05) | 🔵 faer-fork 2.82× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.161281 ± 0.00246845 (W 0.00456874) | 0.493205 ± 0.00491864 (W 0.0103209) | 0.756672 ± 0.00098671 (W 0.0012772) | 🔵 faer-fork 3.06× faster than `faer-upstream` | 🔵 faer-fork 4.69× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.344036 ± 0.00247987 (W 0.00494952) | 0.965452 ± 0.0121187 (W 0.015478) | 2.44704 ± 0.0139852 (W 0.00440619) | 🔵 faer-fork 2.81× faster than `faer-upstream` | 🔵 faer-fork 7.11× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232173 ± 0.000745487 (W 0.00134033) | 0.232782 ± 0.000709617 (W 0.00175655) | 0.256809 ± 0.000611844 (W 0.000963932) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23137 ± 0.0214845 (W 0.00551609) | 1.23192 ± 0.0141697 (W 0.00463577) | 1.00887 ± 0.00288643 (W 0.00147124) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.93188 ± 0.009045 (W 0.019064) | 2.95095 ± 0.0297262 (W 0.0269691) | 2.51122 ± 0.00293735 (W 0.00200966) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.153365 ± 0.000216246 (W 0.00111363) | 0.159427 ± 0.000212798 (W 0.000952345) | 0.100768 ± 0.000180484 (W 0.000455571) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.593622 ± 0.00162931 (W 0.00169076) | 0.625637 ± 0.00254376 (W 0.00218272) | 0.480376 ± 0.00141871 (W 0.00202131) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36783 ± 0.00261375 (W 0.00248577) | 1.48327 ± 0.00629326 (W 0.00233737) | 1.33919 ± 0.000561143 (W 0.00157907) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.142638 ± 0.000940846 (W 0.00149264) | 0.142537 ± 0.000328287 (W 0.00157812) | 0.15517 ± 0.00018335 (W 0.00128549) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.644671 ± 0.00220246 (W 0.0030901) | 0.644319 ± 0.00819065 (W 0.00287147) | 0.527925 ± 0.00134669 (W 0.00192206) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.55748 ± 0.0101638 (W 0.0185639) | 1.59137 ± 0.00169022 (W 0.0158934) | 1.02157 ± 0.000842915 (W 0.00131868) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033653 ± 2.64575e-05 (W 0.00020336) | 0.125643 ± 0.00484636 (W 0.00475657) | 0.026358 ± 0.000164348 (W 5.31244e-05) | 🔵 faer-fork 3.73× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.16517 ± 0.00429405 (W 0.00340081) | 0.654351 ± 0.0154578 (W 0.01722) | 0.756093 ± 0.000843531 (W 0.00145661) | 🔵 faer-fork 3.96× faster than `faer-upstream` | 🔵 faer-fork 4.58× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.361945 ± 0.000679419 (W 0.00526791) | 1.31141 ± 0.0206998 (W 0.0235735) | 2.44394 ± 0.00381459 (W 0.00220556) | 🔵 faer-fork 3.62× faster than `faer-upstream` | 🔵 faer-fork 6.75× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.233275 ± 0.000245599 (W 0.00158735) | 0.233836 ± 0.000812269 (W 0.00145674) | 0.258656 ± 0.000333041 (W 0.00161303) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24436 ± 0.00121275 (W 0.0033372) | 1.25127 ± 0.00252555 (W 0.00901425) | 0.970702 ± 0.0033267 (W 0.00162274) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.94063 ± 0.0171134 (W 0.026023) | 3.03579 ± 0.00735032 (W 0.0134371) | 2.32681 ± 0.0047242 (W 0.0014275) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.153677 ± 0.00073946 (W 0.00141425) | 0.160108 ± 0.000642617 (W 0.00109163) | 0.100859 ± 0.000179344 (W 0.00022926) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.593027 ± 0.00182967 (W 0.00198097) | 0.628582 ± 0.00197435 (W 0.00159237) | 0.481925 ± 0.000932481 (W 0.00177672) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36842 ± 0.00244969 (W 0.00216132) | 1.48332 ± 0.00499465 (W 0.00175997) | 1.34168 ± 0.000265099 (W 0.00131165) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.088244 ± 0.000203726 (W 0.000167378) | 0.087934 ± 0.000106039 (W 0.000278325) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.325667 ± 0.00145558 (W 0.00167311) | 0.324476 ± 0.000441149 (W 0.0011792) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.765509 ± 0.00345955 (W 0.00187557) | 0.759469 ± 0.00404692 (W 0.00188213) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.02145 ± 3.41223e-05 (W 6.30183e-05) | 0.024896 ± 0.00017406 (W 0.000116103) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.087425 ± 4.9521e-05 (W 0.000172065) | 0.121315 ± 0.000458042 (W 0.00125299) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.190055 ± 0.000318783 (W 0.00167608) | 0.257471 ± 0.000837121 (W 0.00170988) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.138928 ± 0.000135348 (W 0.00158645) | 0.137886 ± 0.000379349 (W 0.0010031) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.542426 ± 0.0240049 (W 0.00166953) | 0.543151 ± 0.0206228 (W 0.00205981) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.5829 ± 0.0103855 (W 0.00190198) | 1.57712 ± 0.00877399 (W 0.00185819) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.097321 ± 6.5643e-05 (W 0.00108398) | 0.110165 ± 0.000285005 (W 0.00117274) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.333379 ± 0.000663799 (W 0.00148967) | 0.402191 ± 0.000909028 (W 0.00188892) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.730675 ± 0.000990897 (W 0.00174801) | 0.886875 ± 0.00215124 (W 0.00104404) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.088186 ± 0.000358573 (W 0.000223981) | 0.087624 ± 0.000360113 (W 0.000211499) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.345715 ± 0.00524976 (W 0.00551179) | 0.360878 ± 0.00076766 (W 0.00318601) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.817435 ± 0.00600146 (W 0.0194198) | 0.853292 ± 0.0015967 (W 0.0209451) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.02156 ± 0.000106927 (W 9.5374e-05) | 0.084809 ± 0.000423427 (W 0.00344556) | - | 🔵 faer-fork 3.93× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.115756 ± 0.00579544 (W 0.0012837) | 0.440447 ± 0.00934911 (W 0.00732155) | - | 🔵 faer-fork 3.80× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.224131 ± 0.00306986 (W 0.00186581) | 0.905019 ± 0.0103249 (W 0.0161781) | - | 🔵 faer-fork 4.04× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.138638 ± 0.00024457 (W 0.00114623) | 0.137619 ± 0.000332332 (W 0.00146966) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.594624 ± 0.0420211 (W 0.0114905) | 0.611595 ± 0.0432392 (W 0.0072238) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.69449 ± 0.00764957 (W 0.0183975) | 1.72715 ± 0.00792583 (W 0.00865713) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.097231 ± 0.000246293 (W 0.000280291) | 0.110344 ± 0.000124468 (W 0.00157577) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.332848 ± 0.00119632 (W 0.00170541) | 0.400578 ± 0.00154996 (W 0.00187905) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.729944 ± 0.00249397 (W 0.00150968) | 0.88906 ± 0.00339421 (W 0.00172818) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.088685 ± 0.000411496 (W 8.45476e-05) | 0.087895 ± 0.000361565 (W 0.00179947) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.346771 ± 0.00105588 (W 0.00216268) | 0.396064 ± 0.000430217 (W 0.0109744) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.844686 ± 0.00418884 (W 0.0114075) | 0.921971 ± 0.0052461 (W 0.0114289) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.02148 ± 3.21455e-05 (W 0.000114714) | 0.114653 ± 0.00111273 (W 0.00291056) | - | 🔵 faer-fork 5.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.110707 ± 0.000306959 (W 0.00207648) | 0.613812 ± 0.00227755 (W 0.0112254) | - | 🔵 faer-fork 5.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.234948 ± 0.00492665 (W 0.00771386) | 1.2434 ± 0.0306163 (W 0.0189454) | - | 🔵 faer-fork 5.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.140033 ± 0.00176537 (W 0.00101902) | 0.139231 ± 0.00193086 (W 0.00128849) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.58948 ± 0.00433099 (W 0.00532364) | 0.670849 ± 0.00368838 (W 0.0153826) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.71152 ± 0.00830818 (W 0.0133678) | 1.81886 ± 0.0106183 (W 0.0141048) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.097272 ± 0.000403026 (W 0.000156637) | 0.110355 ± 0.000496854 (W 0.00132786) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.332344 ± 0.00116129 (W 0.00165792) | 0.399872 ± 0.00179177 (W 0.00189056) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.730262 ± 0.00245246 (W 0.00127991) | 0.886614 ± 0.00211466 (W 0.00131456) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.088395 ± 0.000112654 (W 0.000169482) | 0.088114 ± 0.000131936 (W 0.000302939) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.325217 ± 0.000780019 (W 0.0016394) | 0.324483 ± 0.000688711 (W 0.0019441) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.76641 ± 0.00247574 (W 0.00207706) | 0.759137 ± 0.00261742 (W 0.00165722) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.017152 ± 6.245e-05 (W 5.14782e-05) | 0.016872 ± 0.000135044 (W 0.000117887) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.073698 ± 4.39356e-05 (W 0.000190537) | 0.069779 ± 0.00045791 (W 0.00018052) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.160032 ± 0.000183647 (W 0.00170802) | 0.151451 ± 0.000756042 (W 0.00154478) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.147698 ± 3.46987e-05 (W 0.00141013) | 0.147014 ± 0.000259396 (W 9.63182e-05) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.548227 ± 0.0216428 (W 0.00174095) | 0.546578 ± 0.0197548 (W 0.00161481) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.58126 ± 0.0132968 (W 0.00421327) | 1.56668 ± 0.0121128 (W 0.00210117) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.097872 ± 0.000351617 (W 0.00119481) | 0.109867 ± 8.46109e-05 (W 0.000151096) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.331454 ± 0.0014727 (W 0.00179768) | 0.40226 ± 0.000346665 (W 0.00184411) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.742156 ± 0.000458729 (W 0.0016388) | 0.869473 ± 0.00261532 (W 0.00214468) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.088454 ± 0.000334487 (W 0.00141425) | 0.087945 ± 0.000151276 (W 0.00022458) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.345278 ± 0.00221414 (W 0.00344628) | 0.360449 ± 0.00171114 (W 0.00597901) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.817787 ± 0.0225057 (W 0.0192867) | 0.852671 ± 0.00724801 (W 0.0231591) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.017152 ± 4.39356e-05 (W 7.52483e-05) | 0.075692 ± 0.00143427 (W 0.0025268) | - | 🔵 faer-fork 4.41× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.106529 ± 0.000265598 (W 0.00149356) | 0.400854 ± 0.0114021 (W 0.0103354) | - | 🔵 faer-fork 3.76× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.235156 ± 0.00476569 (W 0.0114422) | 0.825662 ± 0.0279883 (W 0.0189305) | - | 🔵 faer-fork 3.51× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.147444 ± 0.000713026 (W 0.00141628) | 0.146623 ± 0.000122696 (W 0.00170886) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.582491 ± 0.0473262 (W 0.00350918) | 0.617401 ± 0.0412606 (W 0.00635342) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.68825 ± 0.0127399 (W 0.0143011) | 1.71744 ± 0.00593039 (W 0.00696909) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.097701 ± 6.86464e-05 (W 0.00142603) | 0.109503 ± 0.000220789 (W 0.000129508) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.330634 ± 0.000326737 (W 0.0013887) | 0.40171 ± 0.000865916 (W 0.00173787) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.744529 ± 0.000927216 (W 0.0018315) | 0.870385 ± 0.00402387 (W 0.00097476) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.088536 ± 0.000311899 (W 0.000251933) | 0.087914 ± 0.000382639 (W 0.000199198) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.346784 ± 0.00282198 (W 0.00222854) | 0.394541 ± 0.00598828 (W 0.010071) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.845387 ± 0.0126431 (W 0.0162739) | 0.905722 ± 0.00971978 (W 0.0168703) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.017102 ± 5.03322e-05 (W 7.49667e-05) | 0.109473 ± 0.00240332 (W 0.00326705) | - | 🔵 faer-fork 6.40× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.092033 ± 0.00748767 (W 0.000979193) | 0.57564 ± 0.00846109 (W 0.0121603) | - | 🔵 faer-fork 6.25× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.202139 ± 0.00430885 (W 0.00497245) | 1.12109 ± 0.00877704 (W 0.019127) | - | 🔵 faer-fork 5.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.14904 ± 0.00168714 (W 0.00103188) | 0.147988 ± 0.00226778 (W 0.00142014) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.590091 ± 0.00134479 (W 0.00492353) | 0.675988 ± 0.0176907 (W 0.0161972) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.70719 ± 0.017203 (W 0.0204674) | 1.83139 ± 0.0151391 (W 0.0121618) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.097782 ± 0.000455741 (W 0.00142547) | 0.109684 ± 0.000180112 (W 0.00010152) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.331569 ± 0.000697424 (W 0.00158806) | 0.402375 ± 0.00209792 (W 0.00210091) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.741293 ± 0.000660173 (W 0.00116875) | 0.869001 ± 0.00314689 (W 0.00165574) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.105066 ± 0.000262508 (W 0.000217626) | 0.105836 ± 0.000872543 (W 0.000303697) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.40933 ± 0.000132842 (W 0.00149138) | 0.411243 ± 0.00231538 (W 0.00180222) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.989818 ± 0.000721916 (W 0.000685665) | 0.992426 ± 0.00390078 (W 0.000700672) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.031749 ± 9.06661e-05 (W 5.04975e-05) | 0.035246 ± 4.95681e-05 (W 0.000125005) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.131918 ± 0.000249482 (W 0.00135494) | 0.183701 ± 0.00047173 (W 0.00109197) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.304518 ± 0.00104111 (W 0.00188459) | 0.41298 ± 0.00124863 (W 0.00163418) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.172562 ± 0.0010495 (W 0.00127443) | 0.172661 ± 0.00217971 (W 0.00136512) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.694546 ± 0.00269845 (W 0.00191035) | 0.69093 ± 0.00371163 (W 0.0020867) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.06245 ± 0.00287596 (W 0.00246512) | 2.0527 ± 0.00329541 (W 0.00279183) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109233 ± 0.000167157 (W 0.00170663) | 0.118853 ± 0.000538138 (W 0.00116441) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.396346 ± 0.000883572 (W 0.00180752) | 0.460355 ± 0.00267685 (W 0.00175552) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.897759 ± 0.00200276 (W 0.00123254) | 1.06106 ± 0.00501772 (W 0.00107563) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104936 ± 0.000194562 (W 0.000192661) | 0.105268 ± 0.000645145 (W 0.0013691) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.411302 ± 0.00484859 (W 0.00226978) | 0.415812 ± 0.00108708 (W 0.00344919) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.985031 ± 0.0136507 (W 0.0166403) | 0.982917 ± 0.0192441 (W 0.0158914) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.031589 ± 2.17792e-05 (W 0.000120205) | 0.095509 ± 0.00373218 (W 0.00209708) | - | 🔵 faer-fork 3.02× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.144391 ± 0.0026947 (W 0.00166018) | 0.508937 ± 0.00542214 (W 0.00852025) | - | 🔵 faer-fork 3.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.333667 ± 0.0264942 (W 0.00785189) | 1.02163 ± 0.0335837 (W 0.0140379) | - | 🔵 faer-fork 3.06× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.172351 ± 0.000428636 (W 0.00120282) | 0.17125 ± 0.000607635 (W 0.00135799) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.702271 ± 0.00418346 (W 0.00371589) | 0.698332 ± 0.000706108 (W 0.00156767) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.01652 ± 0.00750483 (W 0.0123609) | 2.00967 ± 0.018327 (W 0.0154837) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.108795 ± 0.000437551 (W 0.00130146) | 0.118392 ± 0.000242792 (W 0.000153422) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.394847 ± 0.000565385 (W 0.0019774) | 0.458646 ± 0.00111145 (W 0.00211589) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.892395 ± 0.0023927 (W 0.0012332) | 1.05627 ± 0.0011396 (W 0.00208054) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104915 ± 0.000196268 (W 0.00134629) | 0.105428 ± 0.000412095 (W 0.00154871) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.41486 ± 0.00514436 (W 0.00553235) | 0.418587 ± 0.00251268 (W 0.00298619) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.990529 ± 0.00708631 (W 0.0187638) | 1.01827 ± 0.00954018 (W 0.0192017) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.03185 ± 0.00012766 (W 0.000106039) | 0.126536 ± 0.00241526 (W 0.00418188) | - | 🔵 faer-fork 3.97× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.143818 ± 0.00167528 (W 0.00236885) | 0.705684 ± 0.0130823 (W 0.0183661) | - | 🔵 faer-fork 4.91× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.329335 ± 0.0169617 (W 0.0105492) | 1.34882 ± 0.0321352 (W 0.0327091) | - | 🔵 faer-fork 4.10× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.173475 ± 0.00805633 (W 0.00216368) | 0.172403 ± 0.00759047 (W 0.00227462) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.71112 ± 0.00373953 (W 0.00614344) | 0.709908 ± 0.00371442 (W 0.00546462) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.0475 ± 0.0133313 (W 0.0220671) | 2.11646 ± 0.00646512 (W 0.0111365) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109083 ± 0.000285342 (W 0.00159742) | 0.11834 ± 0.000151681 (W 7.35479e-05) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.394973 ± 0.00104717 (W 0.00218823) | 0.458581 ± 0.000493228 (W 0.00172047) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.892687 ± 0.00360202 (W 0.00157269) | 1.05201 ± 0.0037766 (W 0.00101311) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104956 ± 0.00020402 (W 0.00146187) | 0.106089 ± 0.000846778 (W 0.0016718) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.409003 ± 0.000454393 (W 0.00166845) | 0.411845 ± 0.00314432 (W 0.00185823) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.989841 ± 0.000563582 (W 0.000868179) | 0.992962 ± 0.000416043 (W 0.000923806) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.0265 ± 0.000219864 (W 0.00120347) | 0.026038 ± 0.000166136 (W 8.99011e-05) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.115928 ± 0.000337842 (W 0.00163726) | 0.111769 ± 0.000496616 (W 0.00157007) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.269317 ± 0.0011881 (W 0.0013504) | 0.260009 ± 0.00158776 (W 0.00202293) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.174826 ± 0.00106289 (W 0.00168648) | 0.173742 ± 0.00243813 (W 0.00109036) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.702952 ± 0.00181345 (W 0.00150705) | 0.700046 ± 0.00330859 (W 0.00195904) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.0792 ± 0.00241387 (W 0.00137432) | 2.07089 ± 0.000740604 (W 0.00216958) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109223 ± 0.000315644 (W 0.000160188) | 0.118694 ± 0.000482621 (W 0.00098125) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.394743 ± 0.000839536 (W 0.00157279) | 0.453974 ± 0.00166732 (W 0.00193464) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.914189 ± 0.00281319 (W 0.00104607) | 1.06092 ± 0.00543553 (W 0.00144172) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104844 ± 0.00024574 (W 0.00109526) | 0.104956 ± 0.000759956 (W 0.000252771) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.412245 ± 0.00590568 (W 0.00290736) | 0.412906 ± 0.00151769 (W 0.00251552) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.970912 ± 0.00183868 (W 0.011549) | 0.966245 ± 0.00426546 (W 0.0188419) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.0263 ± 0.000112641 (W 0.000138655) | 0.08469 ± 0.00363604 (W 0.00281806) | - | 🔵 faer-fork 3.22× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.121157 ± 0.000372036 (W 0.00131135) | 0.42577 ± 0.0068736 (W 0.00571893) | - | 🔵 faer-fork 3.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.294583 ± 0.0241862 (W 0.00642392) | 0.853432 ± 0.00549482 (W 0.0128799) | - | 🔵 faer-fork 2.90× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.174267 ± 0.000439527 (W 0.000933816) | 0.174225 ± 0.000373594 (W 0.00173547) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.718951 ± 0.00568715 (W 0.00602812) | 0.710436 ± 0.00286854 (W 0.00439523) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05023 ± 0.0132621 (W 0.0122376) | 2.03245 ± 0.0117892 (W 0.0291867) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.108303 ± 0.000382859 (W 0.000118659) | 0.118482 ± 0.000209729 (W 0.00153063) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.393064 ± 0.00109125 (W 0.00209707) | 0.454413 ± 0.00148854 (W 0.00152259) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.909607 ± 0.00179089 (W 0.00165063) | 1.05478 ± 0.000988913 (W 0.000724436) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104907 ± 0.000221763 (W 0.000159437) | 0.105176 ± 0.000231656 (W 0.00110582) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.415831 ± 0.00371945 (W 0.0031496) | 0.418391 ± 0.00327241 (W 0.00336605) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.985219 ± 0.00454261 (W 0.00853126) | 1.02389 ± 0.00931582 (W 0.0128965) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.026379 ± 8.02081e-05 (W 0.000107742) | 0.122809 ± 0.00202452 (W 0.00405871) | - | 🔵 faer-fork 4.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.125142 ± 0.00250202 (W 0.00229876) | 0.597612 ± 0.00323541 (W 0.0166832) | - | 🔵 faer-fork 4.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.281775 ± 0.00179948 (W 0.00531736) | 1.18407 ± 0.00668214 (W 0.0139657) | - | 🔵 faer-fork 4.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.175439 ± 2.2301e-05 (W 0.00118311) | 0.174768 ± 0.000394368 (W 0.00105316) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.71793 ± 0.0026481 (W 0.00381128) | 0.718944 ± 0.0175653 (W 0.00693252) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05372 ± 0.00532029 (W 0.0155528) | 2.12123 ± 0.0104027 (W 0.0143465) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.108783 ± 0.000399888 (W 0.00128501) | 0.1187 ± 0.000240092 (W 0.00138476) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.39344 ± 0.00143433 (W 0.00186841) | 0.451317 ± 0.00142027 (W 0.00187827) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.910469 ± 0.00311813 (W 0.000635991) | 1.05159 ± 0.00459677 (W 0.000993065) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/32`, `eigh/64`, `eigh/96`, `qr_factor/32`, `qr_factor/64`, `qr_factor/96`, `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.26043 ± 0.00808303 (W 0.0035544) | 2.25352 ± 0.0087104 (W 0.00227545) | 1.85425 ± 0.00534334 (W 0.0129848) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.85069 ± 0.0358336 (W 0.0097818) | 9.85745 ± 0.0334671 (W 0.00849038) | 10.0343 ± 0.0333421 (W 0.0143495) | · | · |  |
| `eigh/n512/b1` | 48.971 ± 0.408151 (W 0.022147) | 48.7036 ± 0.317449 (W 0.0587751) | 61.1262 ± 0.0574385 (W 0.40775) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.346697 ± 0.00237156 (W 0.0015308) | 0.532574 ± 0.00190475 (W 0.00205377) | 0.369886 ± 0.00182869 (W 0.00294465) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.64983 ± 0.0110109 (W 0.00468238) | 2.88803 ± 0.0250658 (W 0.00795106) | 2.04744 ± 0.00568832 (W 0.00764188) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.02827 ± 0.0507775 (W 0.00777743) | 17.5976 ± 0.0135586 (W 0.0154645) | 14.1663 ± 0.0678066 (W 0.0341319) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.71381 ± 0.0076828 (W 0.00673264) | 3.69371 ± 0.0111453 (W 0.00421529) | 3.39993 ± 0.00415549 (W 0.0172379) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.5608 ± 0.0169416 (W 0.0139737) | 18.4839 ± 0.0286207 (W 0.0217242) | 18.0693 ± 0.00592052 (W 0.0623987) | · | · |  |
| `svd_thin/n512/b1` | 105.976 ± 0.198138 (W 0.119545) | 105.98 ± 0.801364 (W 0.39184) | 117.483 ± 0.816663 (W 0.228954) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.01469 ± 0.00378228 (W 0.00400317) | 2.69188 ± 0.00591764 (W 0.00380229) | 1.19702 ± 0.00219452 (W 0.00419476) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.4335 ± 0.0135703 (W 0.0152933) | 12.462 ± 0.0285126 (W 0.0182299) | 6.96752 ± 0.00451692 (W 0.0108123) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.6161 ± 0.10734 (W 0.0489234) | 66.4368 ± 0.043891 (W 0.0396131) | 48.0889 ± 0.390209 (W 0.0491975) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.29187 ± 0.0287311 (W 0.0206851) | 2.27482 ± 0.00757377 (W 0.0176401) | 1.07432 ± 0.00480241 (W 0.00390826) | · | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.02488 ± 0.0575615 (W 0.0434148) | 6.99617 ± 0.0124824 (W 0.02081) | 4.78908 ± 0.0058365 (W 0.01291) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.4857 ± 0.0792923 (W 0.0571499) | 26.5114 ± 0.177349 (W 0.0724145) | 21.7625 ± 0.0615476 (W 0.0585869) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.364337 ± 0.0326134 (W 0.0109696) | 1.46637 ± 0.0130035 (W 0.0184719) | 0.197369 ± 0.000361499 (W 0.00125497) | 🔵 faer-fork 4.02× faster than `faer-upstream` | 🔴 faer-fork 1.85× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.44992 ± 0.00594123 (W 0.02994) | 5.65752 ± 0.0984475 (W 0.0316377) | 0.670024 ± 0.00181407 (W 0.00386626) | 🔵 faer-fork 3.90× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.28097 ± 0.00615458 (W 0.0264781) | 22.3184 ± 0.254345 (W 0.0911187) | 3.86389 ± 0.00476869 (W 0.00603228) | 🔵 faer-fork 4.23× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.05404 ± 0.0159508 (W 0.0277444) | 3.03028 ± 0.00684131 (W 0.0236921) | 2.64028 ± 0.00864311 (W 0.00550187) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.7454 ± 0.0304334 (W 0.0270454) | 13.6562 ± 0.04538 (W 0.0505656) | 12.5265 ± 0.0376512 (W 0.0230685) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.9075 ± 0.0787864 (W 0.286154) | 61.6584 ± 0.202075 (W 0.277518) | 58.375 ± 2.06051 (W 0.0983175) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.02592 ± 0.00394365 (W 0.00215393) | 2.22615 ± 0.00518655 (W 0.00558682) | 1.14572 ± 0.00420446 (W 0.00320568) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8361 ± 0.0230939 (W 0.0570686) | 10.863 ± 0.0120718 (W 0.0656729) | 6.12573 ± 0.016631 (W 0.00924585) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 51.0683 ± 0.348883 (W 0.447381) | 48.245 ± 0.240253 (W 0.389855) | 25.9206 ± 0.0822312 (W 0.0372146) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.39664 ± 0.00749586 (W 0.0193167) | 2.34921 ± 0.0194074 (W 0.0188207) | 1.00661 ± 0.00239183 (W 0.00408655) | · | 🔴 faer-fork 2.38× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.87179 ± 0.0285727 (W 0.0273133) | 7.06387 ± 0.0419651 (W 0.0363931) | 3.98197 ± 0.00536402 (W 0.0143455) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 24.122 ± 0.0859469 (W 0.0566442) | 24.9974 ± 0.0561931 (W 0.171294) | 15.1782 ± 0.066455 (W 0.0260522) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.37449 ± 0.00346658 (W 0.00742442) | 1.99974 ± 0.0109615 (W 0.0259386) | 0.156689 ± 1.56205e-05 (W 0.00142677) | 🔵 faer-fork 5.34× faster than `faer-upstream` | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.42946 ± 0.0150704 (W 0.0081942) | 6.65445 ± 0.0538129 (W 0.0501326) | 0.573487 ± 0.00158991 (W 0.00165467) | 🔵 faer-fork 4.66× faster than `faer-upstream` | 🔴 faer-fork 2.49× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.86916 ± 0.0386357 (W 0.0331835) | 25.1745 ± 0.103284 (W 0.111278) | 2.31079 ± 0.00462334 (W 0.00767109) | 🔵 faer-fork 5.17× faster than `faer-upstream` | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.07019 ± 0.0202935 (W 0.0194116) | 3.12596 ± 0.0174984 (W 0.0276626) | 2.50464 ± 0.00679941 (W 0.0053938) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5216 ± 0.0422907 (W 0.0308093) | 13.7955 ± 0.019408 (W 0.0467985) | 11.4916 ± 0.0080969 (W 0.0227436) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.412 ± 0.10183 (W 0.20195) | 60.8627 ± 0.0925177 (W 0.485492) | 48.4319 ± 2.48528 (W 0.138439) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.01799 ± 0.00475479 (W 0.0021563) | 2.21935 ± 0.0395269 (W 0.00513451) | 1.12951 ± 0.00475524 (W 0.00258908) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8765 ± 0.0490538 (W 0.013283) | 10.9729 ± 0.034339 (W 0.0309951) | 5.99957 ± 0.0106929 (W 0.00909313) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 52.187 ± 0.0293192 (W 0.342835) | 49.2782 ± 0.102879 (W 0.28125) | 22.3679 ± 0.137078 (W 0.0233836) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 2.33× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.25534 ± 0.00928238 (W 0.00265979) | 2.2542 ± 0.00471974 (W 0.00453379) | 1.8197 ± 0.00226994 (W 0.00792553) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.81372 ± 0.0151201 (W 0.00536512) | 9.79163 ± 0.038001 (W 0.0130245) | 9.88506 ± 0.0632605 (W 0.0200297) | · | · |  |
| `eigh/n512/b1` | 48.5849 ± 0.553156 (W 0.0248382) | 48.2455 ± 0.623578 (W 0.0277024) | 60.0369 ± 0.265587 (W 0.0705607) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.286137 ± 0.00197484 (W 0.00127294) | 0.278563 ± 0.00205105 (W 0.00137998) | 0.334608 ± 0.00278884 (W 0.00187016) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.3955 ± 0.0108745 (W 0.00231716) | 1.37262 ± 0.00630509 (W 0.00225939) | 1.89453 ± 0.0132321 (W 0.00734503) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.0413 ± 0.0810711 (W 0.00886525) | 7.99034 ± 0.0722316 (W 0.00698299) | 13.4017 ± 0.0380265 (W 0.0217247) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.70494 ± 0.00830969 (W 0.00409701) | 3.68856 ± 0.0136933 (W 0.00594014) | 3.30422 ± 0.0145272 (W 0.0122416) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4435 ± 0.0167981 (W 0.0196777) | 18.366 ± 0.0261115 (W 0.0138093) | 17.7475 ± 0.0342757 (W 0.0271675) | · | · |  |
| `svd_thin/n512/b1` | 105.279 ± 0.166112 (W 0.0873998) | 104.98 ± 0.270118 (W 0.0770805) | 113.247 ± 1.6366 (W 0.453521) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.973 ± 0.00164043 (W 0.00275122) | 2.6117 ± 0.00517192 (W 0.00426357) | 1.15593 ± 0.00200493 (W 0.00257742) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.2685 ± 0.0175476 (W 0.0106492) | 12.3059 ± 0.0233365 (W 0.0258038) | 6.84209 ± 0.0156543 (W 0.00964145) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 59.0047 ± 0.105472 (W 0.036431) | 65.3261 ± 0.158568 (W 0.0500757) | 47.2285 ± 0.149139 (W 0.0386841) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.27923 ± 0.0478133 (W 0.052656) | 2.28774 ± 0.00263385 (W 0.012905) | 1.05039 ± 0.00176216 (W 0.00191053) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.95432 ± 0.0189449 (W 0.0370171) | 6.95247 ± 0.0322509 (W 0.0188393) | 4.67862 ± 0.0127779 (W 0.00981022) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.0322 ± 0.0889699 (W 0.0298773) | 26.0557 ± 0.0787581 (W 0.0454404) | 21.2761 ± 0.0560446 (W 0.0414357) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.367228 ± 0.0309569 (W 0.011043) | 1.15573 ± 0.0184895 (W 0.0174925) | 0.181848 ± 0.000571945 (W 0.00114313) | 🔵 faer-fork 3.15× faster than `faer-upstream` | 🔴 faer-fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.31361 ± 0.0135421 (W 0.0267952) | 3.09434 ± 0.0706986 (W 0.0611095) | 0.620182 ± 0.00167977 (W 0.00179894) | 🔵 faer-fork 2.36× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.79653 ± 0.0604444 (W 0.0169388) | 8.41776 ± 0.0659812 (W 0.0823045) | 3.66582 ± 0.0238974 (W 0.00675166) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.00778 ± 0.00179221 (W 0.013669) | 3.00915 ± 0.018232 (W 0.0136525) | 2.60681 ± 0.0015688 (W 0.00394318) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6012 ± 0.015164 (W 0.0559425) | 13.5152 ± 0.0446719 (W 0.104187) | 12.3393 ± 0.121609 (W 0.384938) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.9467 ± 0.231191 (W 0.23641) | 60.7911 ± 0.235432 (W 0.394123) | 57.0207 ± 0.98031 (W 0.0820828) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.97933 ± 0.0028119 (W 0.00619083) | 2.158 ± 0.0172486 (W 0.00370174) | 1.13656 ± 0.0023095 (W 0.00317608) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.7096 ± 0.0751731 (W 0.0769308) | 10.7075 ± 0.041113 (W 0.0281823) | 6.13118 ± 0.0230651 (W 0.00870905) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 50.3675 ± 0.390603 (W 0.25522) | 47.2415 ± 0.0835962 (W 0.32571) | 25.6448 ± 0.169169 (W 0.0587287) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.39178 ± 0.0237173 (W 0.031695) | 2.33941 ± 0.0155468 (W 0.0221099) | 0.984792 ± 0.00155924 (W 0.00301728) | · | 🔴 faer-fork 2.43× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.78513 ± 0.0769154 (W 0.0331266) | 6.9998 ± 0.0982686 (W 0.0361719) | 3.89406 ± 0.00556357 (W 0.00882152) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.7994 ± 0.0862189 (W 0.0560053) | 24.5445 ± 0.123381 (W 0.0888204) | 14.802 ± 0.0270441 (W 0.0297711) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.346068 ± 0.00850855 (W 0.00744578) | 1.6167 ± 0.0192262 (W 0.0291605) | 0.143897 ± 0.000772429 (W 0.000857756) | 🔵 faer-fork 4.67× faster than `faer-upstream` | 🔴 faer-fork 2.40× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.329 ± 0.0147027 (W 0.0201026) | 4.13063 ± 0.0146458 (W 0.0538751) | 0.547008 ± 0.00288979 (W 0.00279369) | 🔵 faer-fork 3.11× faster than `faer-upstream` | 🔴 faer-fork 2.43× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.62474 ± 0.0237663 (W 0.00984215) | 10.1779 ± 0.0237003 (W 0.144264) | 2.25032 ± 0.00785706 (W 0.00373703) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔴 faer-fork 2.06× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.04298 ± 0.00547334 (W 0.0185487) | 3.09164 ± 0.0131977 (W 0.0164788) | 2.49518 ± 0.0114576 (W 0.00435705) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4054 ± 0.04563 (W 0.00921541) | 13.6889 ± 0.0469315 (W 0.0639722) | 11.3526 ± 0.0452979 (W 0.012836) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.4783 ± 0.317661 (W 0.384943) | 59.9788 ± 0.492625 (W 0.491426) | 48.5832 ± 0.760127 (W 0.0632256) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.97598 ± 0.00378522 (W 0.00237238) | 2.15187 ± 0.0371892 (W 0.00488578) | 1.1154 ± 0.010383 (W 0.0022405) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.7133 ± 0.0184133 (W 0.0331917) | 10.8111 ± 0.0267599 (W 0.0300245) | 5.9915 ± 0.00653262 (W 0.00586188) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 51.0883 ± 0.106876 (W 0.513248) | 48.4778 ± 0.0540399 (W 0.394937) | 22.4179 ± 0.0667328 (W 0.0130358) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 3.28141 ± 0.00742404 (W 0.00466437) | 3.27198 ± 0.00735469 (W 0.00519758) | 4.42693 ± 0.0133828 (W 0.00674552) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.4572 ± 0.0555484 (W 0.0157423) | 17.4651 ± 0.0508498 (W 0.0165396) | 26.4277 ± 0.0567795 (W 0.0228467) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.438 ± 0.407103 (W 0.0383037) | 105.579 ± 0.520818 (W 0.385375) | 171.234 ± 0.27541 (W 0.363947) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.825779 ± 0.00194448 (W 0.00173745) | 1.0766 ± 0.0042121 (W 0.00190772) | 0.954951 ± 0.0028456 (W 0.00338252) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.84966 ± 0.0213984 (W 0.00362416) | 6.44821 ± 0.0566345 (W 0.00853183) | 5.67143 ± 0.00662649 (W 0.00727335) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.718 ± 0.0441921 (W 0.0294755) | 37.6422 ± 0.207053 (W 0.0169968) | 39.0212 ± 0.0708236 (W 0.0455186) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.76186 ± 0.00805007 (W 0.0117502) | 5.74259 ± 0.00813908 (W 0.00697352) | 7.05957 ± 0.00324403 (W 0.00557879) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.2266 ± 0.0742728 (W 0.04415) | 34.1558 ± 0.0657329 (W 0.0277543) | 43.8594 ± 0.0434414 (W 0.0246207) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 210.636 ± 0.279639 (W 0.471391) | 210.816 ± 0.503511 (W 0.482346) | 277.974 ± 6.86708 (W 0.745988) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.81536 ± 0.00491328 (W 0.00460261) | 3.47463 ± 0.0130424 (W 0.0059077) | 2.75428 ± 0.00805136 (W 0.00603445) | 🔵 faer-fork 1.23× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 17.2531 ± 0.0414003 (W 0.0350933) | 19.332 ± 0.0297575 (W 0.0296285) | 18.1813 ± 0.0396316 (W 0.0237526) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 104.667 ± 0.694002 (W 0.0678115) | 110.536 ± 0.436616 (W 0.366441) | 123.176 ± 0.487935 (W 0.068745) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.97884 ± 0.0103009 (W 0.0132452) | 2.95286 ± 0.00281242 (W 0.0195954) | 2.04419 ± 0.00266669 (W 0.00445326) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.3526 ± 0.0141887 (W 0.0534606) | 11.3277 ± 0.0139032 (W 0.0625753) | 10.1285 ± 0.0281509 (W 0.0105103) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.4536 ± 0.12653 (W 0.0952511) | 46.5813 ± 0.0606191 (W 0.0581364) | 52.8514 ± 0.130039 (W 0.0490144) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.609042 ± 0.0476343 (W 0.00160697) | 1.78839 ± 0.0275791 (W 0.0163886) | 0.452542 ± 0.00207259 (W 0.00156172) | 🔵 faer-fork 2.94× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.90945 ± 0.0263318 (W 0.0591713) | 7.3379 ± 0.0569145 (W 0.0470579) | 1.63016 ± 0.0054231 (W 0.00407918) | 🔵 faer-fork 2.52× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.1419 ± 0.0638052 (W 0.0347338) | 26.3682 ± 0.395104 (W 0.102146) | 11.3657 ± 0.0272725 (W 0.0184967) | 🔵 faer-fork 2.17× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.35236 ± 0.0278864 (W 0.0230291) | 4.33228 ± 0.00242154 (W 0.0190737) | 4.14536 ± 0.0115556 (W 0.00479434) | · | · |  |
| `svd_thin/n256/b1` | 22.4782 ± 0.20727 (W 0.0903498) | 22.4729 ± 0.222649 (W 0.0859598) | 21.2696 ± 0.057974 (W 0.0320937) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.8674 ± 0.38657 (W 0.284803) | 94.8684 ± 0.215381 (W 0.267043) | 114.903 ± 4.2951 (W 0.406189) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.80448 ± 0.00173676 (W 0.00360212) | 3.0273 ± 0.00302206 (W 0.0046704) | 2.02325 ± 0.0155354 (W 0.00680168) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.9909 ± 0.032309 (W 0.0714334) | 17.0672 ± 0.0392999 (W 0.0622299) | 11.102 ± 0.00908161 (W 0.0290007) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 67.7325 ± 0.116207 (W 0.352959) | 64.9813 ± 0.0908212 (W 0.275014) | 56.19 ± 0.123056 (W 0.0649713) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.91646 ± 0.0216359 (W 0.030669) | 3.01671 ± 0.0120974 (W 0.0243549) | 1.69903 ± 0.00177758 (W 0.00423468) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7484 ± 0.0159665 (W 0.0284754) | 11.1016 ± 0.0230939 (W 0.0322951) | 7.99991 ± 0.0118679 (W 0.016343) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.8084 ± 0.121315 (W 0.0789835) | 39.9933 ± 0.113221 (W 0.221668) | 36.9524 ± 0.0657517 (W 0.028874) | · | · |  |
| `qr_factor/n128/b1` | 0.631594 ± 0.0253264 (W 0.0323574) | 2.33508 ± 0.0157669 (W 0.0328997) | 0.320992 ± 0.00134676 (W 0.00177501) | 🔵 faer-fork 3.70× faster than `faer-upstream` | 🔴 faer-fork 1.97× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.4415 ± 0.0069175 (W 0.0161861) | 8.56218 ± 0.043935 (W 0.0486062) | 1.62486 ± 0.0020915 (W 0.00344732) | 🔵 faer-fork 3.51× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.47158 ± 0.014663 (W 0.049045) | 27.69 ± 0.188905 (W 0.128581) | 5.83379 ± 0.00516644 (W 0.00973102) | 🔵 faer-fork 2.92× faster than `faer-upstream` | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.23419 ± 0.0222946 (W 0.025601) | 4.47047 ± 0.0177991 (W 0.0221662) | 3.63879 ± 0.00429508 (W 0.00551112) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.6033 ± 0.122827 (W 0.0481452) | 22.202 ± 0.163123 (W 0.0815047) | 17.2316 ± 0.0140176 (W 0.0228644) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 79.9524 ± 0.225679 (W 0.408192) | 81.9526 ± 0.501231 (W 0.478773) | 85.0222 ± 3.85113 (W 0.0776565) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.81149 ± 0.00161403 (W 0.0044594) | 3.08689 ± 0.028583 (W 0.00735188) | 1.90707 ± 0.0018554 (W 0.00377485) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.7709 ± 0.286996 (W 0.163271) | 17.1551 ± 0.205652 (W 0.0799871) | 9.64669 ± 0.0201038 (W 0.0165892) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 63.4196 ± 0.216311 (W 0.300138) | 61.1685 ± 0.141308 (W 0.132731) | 43.2716 ± 0.167742 (W 0.0470797) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 3.26734 ± 0.00115428 (W 0.00217346) | 3.26644 ± 0.00514642 (W 0.00366426) | 4.36412 ± 0.00899064 (W 0.00780476) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.3653 ± 0.0365493 (W 0.0224466) | 17.3678 ± 0.0475438 (W 0.0113139) | 26.2135 ± 0.0204297 (W 0.0402159) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.057 ± 0.624086 (W 0.0402321) | 105.131 ± 0.402769 (W 0.046991) | 170.127 ± 0.355353 (W 0.357378) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.764486 ± 0.00896489 (W 0.00218347) | 0.761619 ± 0.00747712 (W 0.00236228) | 0.912362 ± 0.00194813 (W 0.0027243) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.51402 ± 0.0388519 (W 0.00722659) | 4.50294 ± 0.0407084 (W 0.00862772) | 5.50987 ± 0.00441303 (W 0.0098864) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.6232 ± 0.0786537 (W 0.0208747) | 28.6488 ± 0.0350308 (W 0.0198408) | 37.7992 ± 0.0520934 (W 0.0528846) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.73453 ± 0.00456039 (W 0.0068114) | 5.70575 ± 0.00987256 (W 0.00323478) | 6.97086 ± 0.0182616 (W 0.00908515) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.8218 ± 0.043826 (W 0.047662) | 33.8249 ± 0.0532018 (W 0.025396) | 43.7361 ± 0.704909 (W 0.0901138) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 209.415 ± 0.0255313 (W 0.163277) | 209.631 ± 0.302205 (W 0.37153) | 275.801 ± 0.763567 (W 1.00486) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.78996 ± 0.00516759 (W 0.00540149) | 3.45028 ± 0.0129472 (W 0.00569) | 2.71135 ± 0.00638424 (W 0.00336342) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 16.9812 ± 0.0346208 (W 0.0175628) | 18.9869 ± 0.0968107 (W 0.0326527) | 18.0465 ± 1.04486 (W 0.0245855) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 103.189 ± 0.400912 (W 0.392842) | 109.664 ± 0.411926 (W 0.0544722) | 122.214 ± 0.808532 (W 0.450357) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.95032 ± 0.0202841 (W 0.0239411) | 2.93727 ± 0.0364285 (W 0.0249628) | 1.99861 ± 0.00330358 (W 0.00397244) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.2947 ± 0.0906619 (W 0.0493508) | 11.2422 ± 0.0406559 (W 0.0411877) | 9.98166 ± 0.00397811 (W 0.0138997) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.1275 ± 0.0556864 (W 0.0686696) | 46.2613 ± 0.192085 (W 0.0778841) | 52.2865 ± 0.112594 (W 0.0464077) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.56113 ± 0.00259699 (W 0.00550536) | 1.42091 ± 0.028675 (W 0.0102963) | 0.43526 ± 0.00368237 (W 0.00240703) | 🔵 faer-fork 2.53× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.75634 ± 0.0335392 (W 0.0382176) | 4.31189 ± 0.0140797 (W 0.0376947) | 1.57585 ± 0.00208431 (W 0.00373666) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.2955 ± 0.0325739 (W 0.0574178) | 14.7782 ± 0.0454417 (W 0.0664528) | 10.9794 ± 0.00258233 (W 0.00853849) | 🔵 faer-fork 1.31× faster than `faer-upstream` | · |  |
| `svd_thin/n128/b1` | 4.33602 ± 0.0208916 (W 0.0144514) | 4.31883 ± 0.0237909 (W 0.0197223) | 4.11176 ± 0.0130412 (W 0.00569061) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.2104 ± 0.21973 (W 0.0886736) | 22.1951 ± 0.223023 (W 0.0869538) | 21.1295 ± 0.0623008 (W 0.0473035) | · | · |  |
| `svd_thin/n512/b1` | 93.8557 ± 0.188062 (W 0.331814) | 93.7563 ± 0.231882 (W 0.278585) | 112.564 ± 1.45737 (W 0.0795024) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.77806 ± 0.00398789 (W 0.00381631) | 2.99926 ± 0.0048143 (W 0.00615508) | 2.01543 ± 0.00399546 (W 0.00437116) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.7002 ± 0.0265926 (W 0.0457813) | 16.7726 ± 0.062539 (W 0.0388302) | 11.113 ± 0.0138305 (W 0.0265747) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.281 ± 0.130149 (W 0.222554) | 64.0133 ± 0.131511 (W 0.273372) | 55.9938 ± 0.316284 (W 0.137172) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.95178 ± 0.0277144 (W 0.0372439) | 2.99851 ± 0.00633066 (W 0.0271867) | 1.64847 ± 0.00308304 (W 0.00261215) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7033 ± 0.044671 (W 0.0437629) | 11.0122 ± 0.0345546 (W 0.0416067) | 7.85643 ± 0.0217938 (W 0.0107392) | · | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.4129 ± 0.250131 (W 0.082367) | 39.4661 ± 0.178711 (W 0.16818) | 36.4703 ± 0.0445649 (W 0.0285785) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.568453 ± 0.00303431 (W 0.00520497) | 1.92318 ± 0.0173089 (W 0.0218027) | 0.305348 ± 0.00203266 (W 0.00166107) | 🔵 faer-fork 3.38× faster than `faer-upstream` | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.3122 ± 0.0184556 (W 0.016087) | 5.3417 ± 0.0302579 (W 0.0454893) | 1.58284 ± 0.00276423 (W 0.00217958) | 🔵 faer-fork 2.31× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.9225 ± 0.0870885 (W 0.0378628) | 15.1232 ± 0.148049 (W 0.108062) | 5.80049 ± 0.103248 (W 0.0066564) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.23716 ± 0.00615502 (W 0.0168971) | 4.45903 ± 0.00358906 (W 0.0166488) | 3.60032 ± 0.00819259 (W 0.0067019) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.3417 ± 0.110981 (W 0.0553626) | 21.9568 ± 0.15264 (W 0.160755) | 17.084 ± 0.050438 (W 0.0277929) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 78.9263 ± 0.127284 (W 0.283987) | 80.5471 ± 0.0545257 (W 0.718031) | 83.2303 ± 0.739396 (W 0.111525) | · | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.78348 ± 0.00278115 (W 0.0053481) | 3.05659 ± 0.0357573 (W 0.00484187) | 1.90074 ± 0.0104975 (W 0.00338415) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.6638 ± 0.243859 (W 0.142546) | 16.928 ± 0.297156 (W 0.0586322) | 9.70244 ± 0.0873305 (W 0.016566) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 62.4235 ± 0.125728 (W 0.235304) | 60.2582 ± 0.246394 (W 0.256096) | 45.6524 ± 1.49944 (W 0.0407287) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.52735 ± 0.00235559 (W 0.00248624) | 1.52251 ± 0.00300152 (W 0.00231947) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 5.94639 ± 0.00519556 (W 0.005352) | 5.93325 ± 0.0105594 (W 0.00923881) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 28.215 ± 0.153004 (W 0.0273881) | 28.1986 ± 0.106057 (W 0.0241007) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.320531 ± 0.000196398 (W 0.00214985) | 0.449144 ± 0.00223966 (W 0.00208147) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.19904 ± 0.00260476 (W 0.0034007) | 1.78183 ± 0.00422402 (W 0.00546517) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.73702 ± 0.0365767 (W 0.0170299) | 10.3569 ± 0.0928573 (W 0.0103045) | - | 🔵 faer-fork 1.81× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.34068 ± 0.00509821 (W 0.00432428) | 2.31936 ± 0.000779966 (W 0.00269054) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2309 ± 0.0233946 (W 0.0139704) | 11.1866 ± 0.0075711 (W 0.0139047) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 61.6287 ± 0.00363584 (W 0.0864612) | 61.3183 ± 0.117999 (W 0.0204969) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30473 ± 0.00589591 (W 0.00185685) | 1.71426 ± 0.00146599 (W 0.00198626) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.13617 ± 0.0101195 (W 0.00806142) | 7.86147 ± 0.0407564 (W 0.0102615) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 34.1739 ± 0.274631 (W 0.0229802) | 40.2248 ± 0.299673 (W 0.0403208) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.57503 ± 0.0390306 (W 0.0292819) | 1.57215 ± 0.012522 (W 0.0250781) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.35802 ± 0.0177226 (W 0.0302638) | 4.42117 ± 0.0473215 (W 0.0307829) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 16.5116 ± 0.0796207 (W 0.0715251) | 16.5119 ± 0.0393016 (W 0.0841942) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.400273 ± 0.0218892 (W 0.0107923) | 1.33787 ± 0.0316904 (W 0.0187892) | - | 🔵 faer-fork 3.34× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.30271 ± 0.00871269 (W 0.020072) | 4.34843 ± 0.0409291 (W 0.0524021) | - | 🔵 faer-fork 3.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.2211 ± 0.0183118 (W 0.0430288) | 16.3873 ± 0.0711519 (W 0.10795) | - | 🔵 faer-fork 3.88× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.05687 ± 0.0110778 (W 0.0219446) | 2.0975 ± 0.0107671 (W 0.0248765) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.71415 ± 0.0153736 (W 0.0240157) | 8.70118 ± 0.0335806 (W 0.0159157) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.9594 ± 0.165752 (W 0.705839) | 42.2577 ± 0.268912 (W 0.338925) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.298 ± 0.00431528 (W 0.00161308) | 1.48897 ± 0.0063455 (W 0.00243074) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.50852 ± 0.0413723 (W 0.0394961) | 6.97591 ± 0.0144861 (W 0.0290092) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 34.3129 ± 0.922668 (W 0.621337) | 33.6783 ± 0.364054 (W 0.467296) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.55138 ± 0.0284592 (W 0.0267006) | 1.65105 ± 0.0157413 (W 0.0276767) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.4087 ± 0.0125445 (W 0.0202327) | 4.5369 ± 0.0636181 (W 0.0374637) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 15.7421 ± 0.115489 (W 0.025744) | 16.4272 ± 0.0871526 (W 0.0683704) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.351529 ± 0.00950808 (W 0.00492217) | 1.81039 ± 0.0127516 (W 0.0163204) | - | 🔵 faer-fork 5.15× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.27655 ± 0.00442369 (W 0.0136564) | 5.34281 ± 0.0533048 (W 0.0458483) | - | 🔵 faer-fork 4.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.18828 ± 0.00847899 (W 0.0178751) | 19.566 ± 0.100878 (W 0.124983) | - | 🔵 faer-fork 4.67× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.05434 ± 0.00417014 (W 0.0132337) | 2.26431 ± 0.00966834 (W 0.0222927) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.69742 ± 0.014194 (W 0.0196317) | 9.17182 ± 0.00742814 (W 0.0393204) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 42.3615 ± 0.343453 (W 0.389336) | 43.6461 ± 0.102746 (W 0.425659) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30132 ± 0.00297145 (W 0.00189393) | 1.48966 ± 0.0022439 (W 0.00170813) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.61826 ± 0.026916 (W 0.0361051) | 7.14818 ± 0.0162873 (W 0.0174361) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 35.972 ± 0.0928154 (W 0.367667) | 35.9331 ± 0.351899 (W 0.283682) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.52718 ± 0.000960092 (W 0.00232822) | 1.5215 ± 0.00184601 (W 0.0022358) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 5.91268 ± 0.00426306 (W 0.00514658) | 5.9173 ± 0.0114606 (W 0.0047996) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 28.0219 ± 0.15929 (W 0.0318022) | 28.0024 ± 0.115135 (W 0.043925) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.267848 ± 0.00138324 (W 0.00154983) | 0.256697 ± 0.0014375 (W 0.00175881) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.983675 ± 0.00436285 (W 0.00231497) | 0.956307 ± 0.0069524 (W 0.000930094) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.8253 ± 0.0102227 (W 0.00899965) | 4.77286 ± 0.00302836 (W 0.00428802) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.35444 ± 0.00639041 (W 0.0067671) | 2.33639 ± 0.00560545 (W 0.00756731) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2372 ± 0.0181305 (W 0.0175848) | 11.2071 ± 0.0140186 (W 0.0091711) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 61.0684 ± 0.0923695 (W 0.0374592) | 60.8435 ± 0.0851219 (W 0.0562528) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.2997 ± 0.00382313 (W 0.00108182) | 1.68056 ± 0.00144469 (W 0.00335643) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.05284 ± 0.00673603 (W 0.00528435) | 7.71096 ± 0.0321135 (W 0.0114402) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.4655 ± 0.257324 (W 0.0285639) | 39.6285 ± 0.295398 (W 0.0419522) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.57104 ± 0.0211061 (W 0.0338632) | 1.56371 ± 0.0279318 (W 0.0180249) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.34536 ± 0.045074 (W 0.0528267) | 4.29157 ± 0.049716 (W 0.042455) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 16.3484 ± 0.0406336 (W 0.0709606) | 16.2641 ± 0.0288556 (W 0.0478903) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.344444 ± 0.00468452 (W 0.0151852) | 1.11718 ± 0.046824 (W 0.0172789) | - | 🔵 faer-fork 3.24× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.17147 ± 0.0182137 (W 0.0283722) | 2.88782 ± 0.0629215 (W 0.064797) | - | 🔵 faer-fork 2.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.89103 ± 0.0165026 (W 0.0152049) | 7.47542 ± 0.0497537 (W 0.087023) | - | 🔵 faer-fork 1.92× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.04578 ± 0.0133164 (W 0.0321387) | 2.07898 ± 0.0203245 (W 0.0118869) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.67146 ± 0.00938567 (W 0.0474861) | 8.64994 ± 0.0315343 (W 0.0355541) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.3787 ± 0.434142 (W 0.604047) | 40.3915 ± 0.883079 (W 0.747146) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29917 ± 0.00616983 (W 0.00209665) | 1.46287 ± 0.0117226 (W 0.0185) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.3719 ± 0.0569313 (W 0.0797414) | 6.78872 ± 0.0201452 (W 0.028796) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.3837 ± 0.397523 (W 0.45185) | 34.0741 ± 0.776828 (W 0.299194) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.60251 ± 0.0144247 (W 0.0444665) | 1.6825 ± 0.0259862 (W 0.020258) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.35916 ± 0.0102751 (W 0.0316305) | 4.45777 ± 0.0220572 (W 0.0365186) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 15.5185 ± 0.0979756 (W 0.0207108) | 16.1611 ± 0.0312778 (W 0.103949) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.322605 ± 0.00122936 (W 0.00497898) | 1.58095 ± 0.00735275 (W 0.0168843) | - | 🔵 faer-fork 4.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.206 ± 0.000259425 (W 0.0108613) | 3.85894 ± 0.0362965 (W 0.060098) | - | 🔵 faer-fork 3.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.99367 ± 0.00748472 (W 0.0243982) | 9.50568 ± 0.0286087 (W 0.124812) | - | 🔵 faer-fork 2.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.07062 ± 0.00222799 (W 0.00892339) | 2.26997 ± 0.0065135 (W 0.0189534) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.66562 ± 0.0130574 (W 0.0150966) | 9.14869 ± 0.0238989 (W 0.0508549) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 42.074 ± 0.542656 (W 0.488071) | 42.8668 ± 0.259273 (W 0.406736) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30294 ± 0.00620491 (W 0.0026088) | 1.46077 ± 0.00602832 (W 0.00455948) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.51473 ± 0.0197107 (W 0.0543367) | 6.9302 ± 0.0239411 (W 0.0214161) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 35.2346 ± 0.173211 (W 0.489485) | 35.1716 ± 0.0974715 (W 0.564025) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.06472 ± 0.0014985 (W 0.00247331) | 2.06901 ± 0.00252137 (W 0.00215168) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 10.2686 ± 0.00984473 (W 0.00579026) | 10.3173 ± 0.00633719 (W 0.0113701) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 58.5339 ± 0.135387 (W 0.0404764) | 58.9604 ± 0.129144 (W 0.0642274) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.55462 ± 0.00436829 (W 0.00184957) | 0.760473 ± 0.00265765 (W 0.00125963) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.83541 ± 0.0137673 (W 0.00570592) | 3.83145 ± 0.00207795 (W 0.00486048) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 16.7035 ± 0.131434 (W 0.0139354) | 24.5154 ± 0.135265 (W 0.018002) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 3.40267 ± 0.0021535 (W 0.00317531) | 3.38234 ± 0.00585583 (W 0.00301946) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.8357 ± 0.0319889 (W 0.0111438) | 19.7731 ± 0.0114685 (W 0.0193594) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 123.354 ± 0.175837 (W 0.0637527) | 123.149 ± 0.084902 (W 0.0965622) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.76429 ± 0.00317209 (W 0.0025499) | 2.16837 ± 0.00648134 (W 0.004178) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.1391 ± 0.0068427 (W 0.00912259) | 11.8448 ± 0.0411816 (W 0.018653) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 64.6185 ± 0.177928 (W 0.0441351) | 70.6628 ± 0.179717 (W 0.0378882) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.91866 ± 0.0147783 (W 0.0174234) | 1.93162 ± 0.018393 (W 0.0383933) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 7.01492 ± 0.0134367 (W 0.0251199) | 7.07847 ± 0.0231838 (W 0.0125447) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 27.7064 ± 0.0150694 (W 0.078176) | 27.9352 ± 0.0439407 (W 0.0382675) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.474422 ± 0.0282061 (W 0.0109896) | 1.493 ± 0.0208646 (W 0.0159761) | - | 🔵 faer-fork 3.15× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.03344 ± 0.00948825 (W 0.0397688) | 5.60095 ± 0.0477932 (W 0.039889) | - | 🔵 faer-fork 2.75× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 7.73861 ± 0.0139992 (W 0.0585476) | 21.971 ± 0.324987 (W 0.196956) | - | 🔵 faer-fork 2.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.80972 ± 0.0195412 (W 0.028119) | 2.78511 ± 0.00481519 (W 0.0169046) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.9287 ± 0.0405463 (W 0.0964232) | 13.9036 ± 0.0684607 (W 0.0470871) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 64.8712 ± 0.122781 (W 0.273145) | 65.0529 ± 0.409954 (W 0.333342) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.76831 ± 0.00373175 (W 0.00286635) | 1.94854 ± 0.00516807 (W 0.00430761) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.2029 ± 0.00336018 (W 0.100586) | 10.7035 ± 0.0278193 (W 0.0873867) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 48.5925 ± 0.27508 (W 0.294292) | 48.3748 ± 0.343905 (W 0.405506) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.89132 ± 0.0124241 (W 0.0180572) | 1.9898 ± 0.00845129 (W 0.0153494) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 6.73663 ± 0.0234521 (W 0.0311909) | 6.9522 ± 0.010251 (W 0.0319728) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 23.8217 ± 0.0918256 (W 0.0585198) | 24.966 ± 0.181548 (W 0.175673) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.50333 ± 0.0292232 (W 0.020802) | 1.98183 ± 0.0256841 (W 0.0239614) | - | 🔵 faer-fork 3.94× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.84148 ± 0.00872108 (W 0.0185512) | 6.73146 ± 0.0757483 (W 0.0580077) | - | 🔵 faer-fork 3.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 6.54014 ± 0.00698875 (W 0.0375313) | 24.3365 ± 0.144485 (W 0.13387) | - | 🔵 faer-fork 3.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.76376 ± 0.00491174 (W 0.0156022) | 2.90616 ± 0.0149084 (W 0.0113037) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.3656 ± 0.0864004 (W 0.0554328) | 13.7624 ± 0.0770246 (W 0.0802974) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 59.1367 ± 0.174361 (W 0.303537) | 60.8189 ± 0.226348 (W 0.273971) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.76574 ± 0.00535817 (W 0.00343516) | 1.9467 ± 0.00995242 (W 0.00396867) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.2284 ± 0.0228729 (W 0.0119075) | 10.7826 ± 0.0529036 (W 0.0485964) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.8181 ± 0.146753 (W 0.392217) | 47.9487 ± 0.227443 (W 0.377177) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.06145 ± 0.00339367 (W 0.00445671) | 2.06641 ± 0.00290207 (W 0.00189749) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 10.2 ± 0.0192912 (W 0.00564508) | 10.2756 ± 0.0152846 (W 0.00415879) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 58.0515 ± 0.185965 (W 0.0322251) | 58.4647 ± 0.162087 (W 0.0364471) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.486433 ± 0.00292052 (W 0.00159907) | 0.475758 ± 0.00348961 (W 0.00143163) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.56038 ± 0.00940014 (W 0.00360183) | 2.53249 ± 0.00339536 (W 0.00254779) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 15.6281 ± 0.162473 (W 0.0105921) | 15.5049 ± 0.110892 (W 0.00992463) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 3.39886 ± 0.00326907 (W 0.0049562) | 3.37612 ± 0.00392359 (W 0.00407426) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.6828 ± 0.0318583 (W 0.0126061) | 19.628 ± 0.0292608 (W 0.0123588) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 122.322 ± 0.272106 (W 0.379861) | 122.046 ± 0.127547 (W 0.0762345) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.72813 ± 0.00425994 (W 0.00197497) | 2.14314 ± 0.00608279 (W 0.00183209) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.0176 ± 0.00947945 (W 0.0164372) | 11.6953 ± 0.0246903 (W 0.00850435) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 63.6646 ± 0.169903 (W 0.168936) | 69.6942 ± 0.169371 (W 0.035614) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.92912 ± 0.00942006 (W 0.0363257) | 1.94429 ± 0.0224634 (W 0.0202119) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 6.97333 ± 0.016753 (W 0.0203031) | 7.00157 ± 0.0231382 (W 0.0354941) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 27.3614 ± 0.0441249 (W 0.027095) | 27.4752 ± 0.0629404 (W 0.0396948) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.422084 ± 0.00289302 (W 0.0117893) | 1.23558 ± 0.00648235 (W 0.0197048) | - | 🔵 faer-fork 2.93× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.87848 ± 0.0180772 (W 0.0210261) | 3.51851 ± 0.00274563 (W 0.0428104) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 7.32124 ± 0.0269142 (W 0.0532413) | 10.6568 ± 0.125809 (W 0.106983) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.77489 ± 0.0577219 (W 0.0199561) | 2.77017 ± 0.0138315 (W 0.018169) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.8135 ± 0.0994643 (W 0.0686477) | 13.7136 ± 0.0330502 (W 0.107562) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 64.2424 ± 0.249876 (W 0.320673) | 63.7827 ± 0.132512 (W 0.164797) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.73431 ± 0.00276178 (W 0.00354316) | 1.93224 ± 0.0190721 (W 0.00470596) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.0478 ± 0.0385886 (W 0.0562444) | 10.5963 ± 0.115321 (W 0.0825976) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.1127 ± 0.175573 (W 0.333297) | 47.1823 ± 0.116072 (W 0.228651) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.90317 ± 0.0130922 (W 0.00949959) | 1.98714 ± 0.00485598 (W 0.0137424) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 6.67972 ± 0.0107471 (W 0.0340305) | 6.85361 ± 0.0307079 (W 0.0405418) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 23.4308 ± 0.0217001 (W 0.0738845) | 24.7611 ± 0.0593407 (W 0.220228) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.44418 ± 0.000192858 (W 0.0035188) | 1.71432 ± 0.0276157 (W 0.0141711) | - | 🔵 faer-fork 3.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.73859 ± 0.0141712 (W 0.0128518) | 4.42807 ± 0.0118 (W 0.0558356) | - | 🔵 faer-fork 2.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 6.21348 ± 0.0306745 (W 0.0203651) | 11.5483 ± 0.100045 (W 0.0894679) | - | 🔵 faer-fork 1.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.74169 ± 0.00709773 (W 0.0139115) | 2.89367 ± 0.00347841 (W 0.0166285) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.2574 ± 0.0466167 (W 0.0738603) | 13.5827 ± 0.058987 (W 0.0317692) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 58.3054 ± 0.276936 (W 0.259135) | 59.6272 ± 0.0718095 (W 0.518844) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.73095 ± 0.00494039 (W 0.0018197) | 1.99827 ± 0.045296 (W 0.00282975) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.1014 ± 0.0318447 (W 0.0381443) | 10.6389 ± 0.0372464 (W 0.0713107) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.1211 ± 0.199366 (W 0.24781) | 47.1438 ± 0.177112 (W 0.285193) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/128`, `eigh/256`, `eigh/512`, `qr_factor/128`, `qr_factor/256`, `qr_factor/512`, `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.07511 ± 0.00100053 (W 0.00191978) | 1.86787 ± 0.0102213 (W 0.00502609) | 0.907667 ± 0.00261703 (W 0.00302363) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 32.5136 ± 0.574025 (W 0.368141) | 78.1173 ± 0.135148 (W 0.0640009) | 35.0943 ± 0.0858983 (W 0.0708557) | 🔵 faer-fork 2.40× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.51619 ± 0.00456718 (W 0.00360629) | 2.51011 ± 0.00729393 (W 0.00543918) | 3.05031 ± 0.00230642 (W 0.00601919) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 89.1096 ± 0.081876 (W 0.084123) | 88.5945 ± 0.0718325 (W 0.369124) | 120.663 ± 0.90115 (W 0.446853) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.46317 ± 0.00371927 (W 0.00438852) | 1.48575 ± 0.0081844 (W 0.00577568) | 1.38913 ± 0.00425234 (W 0.00320616) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.2053 ± 0.0248214 (W 0.044416) | 44.9464 ± 0.0654349 (W 0.0412195) | 46.3825 ± 0.0847628 (W 0.113737) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.08384 ± 0.0235367 (W 0.0127132) | 3.80922 ± 0.179021 (W 0.084897) | 0.458519 ± 0.00738615 (W 0.00920516) | 🔵 faer-fork 3.51× faster than `faer-upstream` | 🔴 faer-fork 2.36× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 15.807 ± 0.0774579 (W 0.207388) | 76.7676 ± 0.344289 (W 0.688418) | 12.6964 ± 0.0607144 (W 0.0787152) | 🔵 faer-fork 4.86× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.38146 ± 0.025999 (W 0.03057) | 2.8138 ± 0.0205663 (W 0.022886) | 1.89966 ± 0.0084917 (W 0.0100573) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 46.9115 ± 0.0834401 (W 0.498538) | 50.3518 ± 0.0307396 (W 0.136118) | 49.0755 ± 2.89919 (W 0.128212) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.64353 ± 0.0194523 (W 0.0108203) | 2.12489 ± 0.0116891 (W 0.0315102) | 0.950876 ± 0.00110335 (W 0.00972925) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 32.3924 ± 0.120315 (W 0.189136) | 35.4479 ± 0.0937069 (W 0.195307) | 22.5883 ± 2.7093 (W 0.0962731) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.16571 ± 0.0231556 (W 0.0104247) | 4.30667 ± 0.107068 (W 0.105356) | 0.320815 ± 0.00239411 (W 0.00257787) | 🔵 faer-fork 3.69× faster than `faer-upstream` | 🔴 faer-fork 3.63× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 12.8637 ± 0.0378821 (W 0.0512407) | 76.7401 ± 0.417032 (W 0.494506) | 7.3692 ± 0.0871847 (W 0.0259551) | 🔵 faer-fork 5.97× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.53014 ± 0.00787301 (W 0.0247359) | 3.17825 ± 0.0264454 (W 0.0258661) | 1.67538 ± 0.0149133 (W 0.00507046) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.7182 ± 0.0258753 (W 0.103843) | 50.215 ± 0.365108 (W 0.883453) | 38.7746 ± 1.6683 (W 0.0724266) | 🔵 faer-fork 1.23× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.73421 ± 0.00473913 (W 0.0225432) | 2.49451 ± 0.00964199 (W 0.0223744) | 0.812722 ± 0.00376672 (W 0.00230949) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 30.638 ± 0.060704 (W 0.0734266) | 37.2896 ± 0.0705142 (W 0.125887) | 16.7575 ± 0.0977683 (W 0.070926) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.797853 ± 0.00171649 (W 0.00290447) | 0.793646 ± 0.00173484 (W 0.00226058) | 0.765554 ± 0.00313075 (W 0.00310916) | · | · |  |
| `qr_factor/4096x256/b1` | 26.0274 ± 0.0977861 (W 0.0314872) | 26.0532 ± 0.116194 (W 0.0222641) | 29.0302 ± 0.027703 (W 0.0387923) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.46866 ± 0.00614323 (W 0.00384589) | 2.45188 ± 0.00724882 (W 0.00291208) | 2.82532 ± 0.0153986 (W 0.00528345) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 83.5561 ± 0.220765 (W 0.095391) | 83.0536 ± 0.232868 (W 0.0443095) | 109.991 ± 0.547172 (W 0.325542) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39313 ± 0.00111926 (W 0.00164702) | 1.39786 ± 0.00604641 (W 0.00220244) | 1.25187 ± 0.0146633 (W 0.00167526) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 37.824 ± 0.139472 (W 0.0328384) | 39.2553 ± 0.110652 (W 0.0239983) | 40.3881 ± 0.048499 (W 0.0419749) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.911252 ± 0.00800641 (W 0.0100415) | 1.38191 ± 0.0049362 (W 0.0145487) | 0.417239 ± 0.00818038 (W 0.00984509) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 2.18× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.3713 ± 0.0530597 (W 0.213988) | 18.0032 ± 0.1061 (W 0.124332) | 11.3317 ± 0.0839486 (W 0.103751) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.30505 ± 0.0182961 (W 0.014468) | 2.72861 ± 0.0250031 (W 0.0264791) | 1.81891 ± 0.00348051 (W 0.00478099) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 41.3491 ± 0.0222853 (W 0.18323) | 44.6036 ± 0.136508 (W 0.116151) | 45.6132 ± 0.167548 (W 0.150425) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.55798 ± 0.00361637 (W 0.012958) | 2.03154 ± 0.0261463 (W 0.0256236) | 0.916063 ± 0.00927155 (W 0.00954972) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 26.2559 ± 0.0611506 (W 0.240112) | 29.8495 ± 0.149756 (W 0.158351) | 20.8125 ± 0.120726 (W 0.0900369) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.01895 ± 0.0151198 (W 0.0128929) | 1.67259 ± 0.0164123 (W 0.0212467) | 0.301138 ± 0.00143908 (W 0.0023194) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔴 faer-fork 3.38× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.7081 ± 0.146796 (W 0.0406536) | 19.5758 ± 0.299843 (W 0.171937) | 6.53368 ± 0.0570483 (W 0.0283477) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.46214 ± 0.00899535 (W 0.016353) | 3.0889 ± 0.00729715 (W 0.0419428) | 1.6327 ± 0.00297441 (W 0.00256328) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 35.1873 ± 0.0945106 (W 0.148061) | 44.7899 ± 0.479146 (W 0.630321) | 34.5132 ± 0.0781878 (W 0.035556) | 🔵 faer-fork 1.27× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.69461 ± 0.00102296 (W 0.0229819) | 2.40553 ± 0.011411 (W 0.0237749) | 0.785 ± 0.00219177 (W 0.00353968) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.7335 ± 0.0553448 (W 0.0746722) | 31.7342 ± 0.0761584 (W 0.171897) | 15.8677 ± 0.0239865 (W 0.0608326) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.49964 ± 0.0349745 (W 0.00279373) | 3.97711 ± 0.079973 (W 0.0107658) | 2.38864 ± 0.0024431 (W 0.00564063) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 100.836 ± 0.558916 (W 0.148355) | 176.005 ± 0.117817 (W 0.0897175) | 110.46 ± 0.90702 (W 0.221423) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 6.02396 ± 0.0195091 (W 0.00670515) | 6.03366 ± 0.0311506 (W 0.00236491) | 8.79083 ± 0.0171236 (W 0.0207357) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 280.699 ± 0.0544514 (W 1.0861) | 281.166 ± 0.112659 (W 0.496255) | 380.014 ± 0.056921 (W 0.441363) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.09376 ± 0.0454459 (W 0.00556881) | 3.10248 ± 0.0163208 (W 0.00470967) | 3.84146 ± 0.0223438 (W 0.00405203) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 120.695 ± 1.6095 (W 0.0999444) | 122.456 ± 1.60597 (W 0.104641) | 144.053 ± 0.978755 (W 0.963072) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.95248 ± 0.0208549 (W 0.0331559) | 4.59786 ± 0.148637 (W 0.0783067) | 1.39178 ± 0.00199235 (W 0.0397922) | 🔵 faer-fork 2.35× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 40.958 ± 0.181236 (W 0.111353) | 124.086 ± 0.379319 (W 1.14337) | 33.9098 ± 0.165866 (W 0.210782) | 🔵 faer-fork 3.03× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.03729 ± 0.102019 (W 0.0983607) | 4.36591 ± 0.0396755 (W 0.0307502) | 5.49026 ± 0.0155116 (W 0.00859277) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 115.145 ± 0.164398 (W 0.176599) | 122.371 ± 0.112795 (W 0.182815) | 140.511 ± 0.312706 (W 0.751756) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.69341 ± 0.0721468 (W 0.0487886) | 3.07484 ± 0.013996 (W 0.0162855) | 2.81183 ± 0.0108753 (W 0.00459609) | 🔵 faer-fork 1.14× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 67.3721 ± 0.58998 (W 0.11735) | 75.1561 ± 0.173435 (W 0.333454) | 51.7987 ± 5.23352 (W 0.420613) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.89072 ± 0.0321449 (W 0.0115398) | 4.98194 ± 0.105612 (W 0.102902) | 0.873219 ± 0.0018765 (W 0.00155676) | 🔵 faer-fork 2.63× faster than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 30.584 ± 0.134634 (W 0.122812) | 123.533 ± 0.287698 (W 1.13749) | 19.7119 ± 0.113731 (W 0.101539) | 🔵 faer-fork 4.04× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.8371 ± 0.0204969 (W 0.0183811) | 4.68558 ± 0.0182708 (W 0.0195113) | 4.43736 ± 0.0220361 (W 0.00864875) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.5069 ± 0.225425 (W 0.235034) | 105.123 ± 0.22746 (W 0.498852) | 83.9638 ± 0.312535 (W 0.495805) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.61557 ± 0.0359802 (W 0.0295962) | 3.38112 ± 0.0179881 (W 0.0232604) | 2.31816 ± 0.0306912 (W 0.00405917) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 58.8389 ± 0.115703 (W 0.161637) | 72.4774 ± 0.124229 (W 0.231062) | 34.2432 ± 4.89616 (W 0.200735) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.27363 ± 0.0161663 (W 0.00306916) | 2.26856 ± 0.0209987 (W 0.00338601) | 2.26042 ± 0.00552277 (W 0.00439278) | · | · |  |
| `qr_factor/4096x256/b1` | 90.1042 ± 0.651856 (W 0.0520042) | 90.3011 ± 0.621108 (W 0.0519581) | 105.306 ± 1.36735 (W 0.373101) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.90572 ± 0.0133566 (W 0.0039819) | 5.93411 ± 0.0204384 (W 0.00335698) | 8.56089 ± 0.0131898 (W 0.00829763) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 268.621 ± 0.169827 (W 0.170492) | 268.951 ± 0.242004 (W 0.429945) | 360.691 ± 3.65445 (W 0.464242) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.9851 ± 0.0256266 (W 0.00547101) | 2.98401 ± 0.0219684 (W 0.00272457) | 3.66467 ± 0.0055782 (W 0.00575073) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 108.475 ± 0.190995 (W 0.0565199) | 110.285 ± 0.145861 (W 0.325953) | 142.556 ± 4.12602 (W 0.785181) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.76341 ± 0.0255267 (W 0.0101126) | 2.17392 ± 0.036385 (W 0.0156442) | 1.36437 ± 0.00867093 (W 0.00501166) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 35.8023 ± 0.134624 (W 0.0820207) | 44.2084 ± 0.294834 (W 0.103606) | 31.2569 ± 0.481481 (W 0.13624) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.94755 ± 0.046597 (W 0.0882665) | 4.24204 ± 0.0208685 (W 0.0348306) | 5.38702 ± 0.0138264 (W 0.010805) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 103.21 ± 0.191706 (W 0.236986) | 110.458 ± 0.38978 (W 0.462474) | 128.861 ± 0.531968 (W 0.345362) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.53115 ± 0.0210544 (W 0.0141386) | 2.91966 ± 0.0358118 (W 0.022525) | 2.7873 ± 0.00484835 (W 0.0454891) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 55.5482 ± 0.0849943 (W 0.151391) | 63.3623 ± 0.0142807 (W 0.0977645) | 48.7999 ± 0.496738 (W 0.193554) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.72793 ± 0.0101657 (W 0.0103975) | 2.48037 ± 0.0189839 (W 0.0230331) | 0.862299 ± 0.00769489 (W 0.00246803) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 2.00× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.6739 ± 0.101255 (W 0.0573834) | 42.0864 ± 0.0454034 (W 0.558127) | 17.9564 ± 0.0191873 (W 0.0929894) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.73093 ± 0.022857 (W 0.0228371) | 4.55732 ± 0.0315581 (W 0.0282135) | 4.37756 ± 0.00529778 (W 0.00944287) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 76.4257 ± 0.260738 (W 0.19639) | 97.9264 ± 2.84875 (W 2.27157) | 73.8861 ± 0.222653 (W 0.264691) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.50952 ± 0.00937439 (W 0.0249189) | 3.28741 ± 0.0234111 (W 0.0251557) | 2.28796 ± 0.0108683 (W 0.00468634) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 47.3232 ± 0.149271 (W 0.102133) | 60.9272 ± 0.141975 (W 0.266172) | 32.5198 ± 0.308799 (W 0.107084) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.893561 ± 0.00171039 (W 0.00265646) | 1.52647 ± 0.00378029 (W 0.00271883) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 20.3441 ± 0.214695 (W 0.133281) | 51.365 ± 0.101491 (W 0.0812064) | - | 🔵 faer-fork 2.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.60483 ± 0.00608126 (W 0.00367247) | 1.59716 ± 0.0022631 (W 0.00252087) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.188 ± 0.0860066 (W 0.0777186) | 49.2996 ± 0.224973 (W 0.42419) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.12068 ± 0.00234901 (W 0.00285348) | 1.14257 ± 0.0053934 (W 0.00619426) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 26.6267 ± 0.0577309 (W 0.0384817) | 27.395 ± 0.201387 (W 0.0767671) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.918992 ± 0.00833036 (W 0.0112198) | 2.88589 ± 0.0650346 (W 0.0274409) | - | 🔵 faer-fork 3.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 10.5557 ± 0.0997463 (W 0.186161) | 54.5607 ± 0.0686775 (W 0.225352) | - | 🔵 faer-fork 5.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.7346 ± 0.0120782 (W 0.0222248) | 2.18367 ± 0.0149154 (W 0.0266895) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 27.7197 ± 0.129248 (W 0.222515) | 33.2559 ± 0.986016 (W 1.1226) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.31968 ± 0.0183315 (W 0.0328795) | 1.85968 ± 0.0159253 (W 0.0408406) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 20.9972 ± 0.0838717 (W 0.259018) | 24.3844 ± 0.0863302 (W 0.105099) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.997159 ± 0.010094 (W 0.0159193) | 3.16687 ± 0.0239081 (W 0.0268183) | - | 🔵 faer-fork 3.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 9.26542 ± 0.0537844 (W 0.0379886) | 56.6284 ± 0.541821 (W 0.398379) | - | 🔵 faer-fork 6.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.84684 ± 0.0109383 (W 0.0193236) | 2.52542 ± 0.0112229 (W 0.0358456) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.8038 ± 0.0444819 (W 0.100281) | 33.5529 ± 0.370595 (W 0.670891) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.42744 ± 0.00461067 (W 0.0319983) | 2.19135 ± 0.0174136 (W 0.0348095) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 20.1835 ± 0.0213935 (W 0.0426037) | 26.5711 ± 0.0540045 (W 0.115856) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.638937 ± 0.00629943 (W 0.00237978) | 0.632196 ± 0.00525403 (W 0.00240211) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 15.7908 ± 0.140457 (W 0.0139484) | 15.8338 ± 0.165974 (W 0.018026) | - | · | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.60808 ± 0.00475249 (W 0.00226438) | 1.59818 ± 0.00215865 (W 0.00248206) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.3499 ± 0.0800802 (W 0.0411387) | 46.2805 ± 0.117495 (W 0.0223369) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.07144 ± 0.00088214 (W 0.00128956) | 1.09824 ± 0.00243722 (W 0.00141378) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 22.9255 ± 0.0416286 (W 0.0177791) | 24.1532 ± 0.0885855 (W 0.395655) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.810393 ± 0.0020606 (W 0.00712381) | 1.28901 ± 0.00506057 (W 0.0130618) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 9.23213 ± 0.0658934 (W 0.147164) | 13.2574 ± 0.0874007 (W 0.0538074) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.73609 ± 0.00572524 (W 0.0220206) | 2.12242 ± 0.00186783 (W 0.0138628) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.1453 ± 0.183812 (W 0.323679) | 27.9685 ± 0.13626 (W 0.0910314) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.26752 ± 0.00997171 (W 0.0234375) | 1.79418 ± 0.00224932 (W 0.0116322) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.7795 ± 0.105515 (W 0.242401) | 20.9282 ± 0.135151 (W 0.0914109) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.912432 ± 0.00896411 (W 0.0118223) | 1.55591 ± 0.00580871 (W 0.025048) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 8.25835 ± 0.0211439 (W 0.034138) | 15.0742 ± 0.0533256 (W 0.175804) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.82992 ± 0.0136716 (W 0.0132443) | 2.5055 ± 0.0186183 (W 0.02601) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.3757 ± 0.0126342 (W 0.0568396) | 29.9815 ± 0.215322 (W 0.396275) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.37193 ± 0.0146061 (W 0.0154486) | 2.15817 ± 0.00805064 (W 0.023241) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.1635 ± 0.0564981 (W 0.0435316) | 23.0589 ± 0.0325148 (W 0.221237) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.7055 ± 0.0137691 (W 0.00378746) | 3.23334 ± 0.00739364 (W 0.00242493) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 57.0499 ± 0.0558621 (W 0.110509) | 97.9179 ± 0.0873014 (W 0.0726307) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 3.42398 ± 0.00332803 (W 0.00277947) | 3.40109 ± 0.00538929 (W 0.00524984) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 147.813 ± 2.23431 (W 0.486579) | 146.964 ± 0.189353 (W 0.176923) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.98788 ± 0.00265798 (W 0.00528128) | 2.01122 ± 0.00252936 (W 0.00415939) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 67.0186 ± 0.167321 (W 0.0665574) | 67.6087 ± 0.127591 (W 0.0874265) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.5031 ± 0.0116926 (W 0.0134389) | 3.87176 ± 0.0305551 (W 0.110784) | - | 🔵 faer-fork 2.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 24.9093 ± 0.0782082 (W 0.346088) | 75.2588 ± 0.345305 (W 0.330449) | - | 🔵 faer-fork 3.02× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.65761 ± 0.0137522 (W 0.0695658) | 2.98564 ± 0.0105199 (W 0.020126) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 63.6607 ± 0.201456 (W 0.290259) | 69.3702 ± 0.928227 (W 0.560286) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.96765 ± 0.00220816 (W 0.0445355) | 2.37187 ± 0.016446 (W 0.0163102) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 39.9367 ± 0.109977 (W 0.182299) | 45.4875 ± 0.0199369 (W 0.0830517) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.50916 ± 0.0037714 (W 0.00729397) | 4.13087 ± 0.0126541 (W 0.155047) | - | 🔵 faer-fork 2.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 19.6964 ± 0.102601 (W 0.0863032) | 76.4449 ± 0.402338 (W 1.31656) | - | 🔵 faer-fork 3.88× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.64887 ± 0.0197967 (W 0.0167637) | 3.3452 ± 0.0100594 (W 0.0258341) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 50.3166 ± 0.0861876 (W 0.0779396) | 63.4561 ± 0.753638 (W 0.903483) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.99577 ± 0.005287 (W 0.0164238) | 2.76964 ± 0.00873495 (W 0.0144785) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 35.6964 ± 0.0872021 (W 0.0777716) | 45.6978 ± 0.0912629 (W 0.0994208) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.44131 ± 0.00340264 (W 0.00282128) | 1.41909 ± 0.00165111 (W 0.00208272) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 50.3317 ± 0.456796 (W 0.0172555) | 49.8613 ± 0.582617 (W 0.0265363) | - | · | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 3.38304 ± 0.00166276 (W 0.0046567) | 3.3543 ± 0.00629817 (W 0.00337535) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 142.344 ± 0.0786186 (W 0.135884) | 141.308 ± 0.164895 (W 0.0692099) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.91729 ± 0.00431153 (W 0.00172718) | 1.92498 ± 0.00255583 (W 0.00140568) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 61.2567 ± 0.0476159 (W 0.0335212) | 61.7529 ± 0.0849641 (W 0.0286021) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.36155 ± 0.00569348 (W 0.0246761) | 1.72682 ± 0.0123868 (W 0.0146893) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 21.8406 ± 0.0695611 (W 0.161938) | 27.9666 ± 0.218964 (W 0.0820574) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.63085 ± 0.0125935 (W 0.0436559) | 2.94162 ± 0.00348205 (W 0.0290212) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 57.654 ± 0.262823 (W 0.135583) | 63.3926 ± 0.0307449 (W 0.218784) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.90083 ± 0.0235464 (W 0.0144701) | 2.26879 ± 0.00957763 (W 0.0162474) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 33.8238 ± 0.0100886 (W 0.101853) | 39.7283 ± 0.0270857 (W 0.172807) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.40206 ± 0.00839685 (W 0.00605023) | 2.07454 ± 0.0292772 (W 0.0300508) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 17.8604 ± 0.0245624 (W 0.0138513) | 28.2248 ± 0.193467 (W 0.0760276) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.61167 ± 0.00743587 (W 0.0150281) | 3.27027 ± 0.0328032 (W 0.028667) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 44.4586 ± 0.123228 (W 0.0837538) | 57.4829 ± 0.509075 (W 0.555813) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.93181 ± 0.0116268 (W 0.0169599) | 2.6636 ± 0.0229153 (W 0.0280589) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 29.9536 ± 0.0848126 (W 0.0669093) | 40.0793 ± 0.0916918 (W 0.271325) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/1024x64`, `eigh/4096x256`, `qr_factor/1024x64`, `qr_factor/4096x256`, `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
