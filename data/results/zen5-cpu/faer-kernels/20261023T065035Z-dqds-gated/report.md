# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `9f777051d854a334011be54ab0d408e9c6159c72`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `7c1d7a5741a132606af955e837057e8da7bc8c4f`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `255e33cbf5dcfbb0dd5cf3396802025527ceb028eac38e4bcdaee5f2c598a447`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T07:28:35.905254Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label dqds-gated --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T065035Z-dqds-gated/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.57%, worst 206.75% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 42 of 960 engine cells exceed 5% and carry `!`; median within-process relative SD 0.34%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `svd_thin/n32/b1` | 0.181914 ± 0.000454419 (W 0.0013376) | 0.182067 ± 0.000500137 (W 0.00126932) | 0.177842 ± 0.000895596 (W 0.00150069) | · | · |  |
| `svd_thin/n64/b1` | 0.92122 ± 0.00662777 (W 0.00312248) | 0.9156 ± 0.00648876 (W 0.00109319) | 0.76557 ± 0.0116273 (W 0.0040308) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.21142 ± 0.0441245 (W 0.00200102) | 2.2165 ± 0.0110767 (W 0.00383527) | 1.68433 ± 0.053212 (W 0.00693359) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.128268 ± 0.000224571 (W 0.00113078) | 0.139688 ± 0.000589238 (W 0.000196304) | 0.06444 ± 0.000183143 (W 0.000115608) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.475912 ± 0.00392532 (W 0.00231964) | 0.51786 ± 0.00245767 (W 0.00167402) | 0.264915 ± 0.000336031 (W 0.00197764) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06311 ± 0.000753175 (W 0.00164819) | 1.18121 ± 0.0015213 (W 0.00131004) | 0.64228 ± 0.00337138 (W 0.00427717) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.66× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.181337 ± 0.000360894 (W 0.00131029) | 0.18203 ± 0.000252011 (W 0.00119855) | 0.186115 ± 0.000640746 (W 0.00109745) | · | · |  |
| `svd_thin/n64/b1` | 0.970122 ± 0.00789956 (W 0.0162222) | 0.948201 ± 0.00268627 (W 0.00314532) | 0.667717 ± 0.000560631 (W 0.00222736) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.29691 ± 0.0408881 (W 0.0139276) | 2.32162 ± 0.0380241 (W 0.0210784) | 1.40932 ± 0.000686767 (W 0.003744) | · | 🔴 faer-fork 1.63× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.127975 ± 0.000414061 (W 0.00170829) | 0.139566 ± 0.00020826 (W 0.000362748) | 0.06436 ± 0.000238123 (W 0.000139392) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.479148 ± 0.0010052 (W 0.00191798) | 0.516828 ± 0.00113923 (W 0.0018846) | 0.271318 ± 0.000727263 (W 0.0011109) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06255 ± 0.000918658 (W 0.00114202) | 1.18135 ± 0.00318886 (W 0.00124073) | 0.605973 ± 0.00091485 (W 0.00174778) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.188181 ± 0.010129 (W 0.00154309) | 0.188552 ± 0.0103194 (W 0.00179733) | 0.186563 ± 0.000927698 (W 0.00164196) | · | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.96292 ± 0.00414667 (W 0.00385236) | 0.961625 ± 0.00733854 (W 0.0105647) | 0.666334 ± 0.00137175 (W 0.00165753) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.29877 ± 0.0426176 (W 0.0205748) | 2.36261 ± 0.0444711 (W 0.00868941) | 1.43993 ± 0.00540334 (W 0.00561945) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.128326 ± 0.000294546 (W 0.00154962) | 0.139546 ± 0.000287065 (W 0.00216478) | 0.064461 ± 0.000327164 (W 0.00017562) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.477736 ± 0.00121502 (W 0.00233707) | 0.515643 ± 0.00108249 (W 0.00203844) | 0.269911 ± 0.000371215 (W 0.00122532) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06536 ± 0.00204907 (W 0.00227068) | 1.18439 ± 0.00180052 (W 0.00369952) | 0.596557 ± 0.00184344 (W 0.00170065) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183192 ± 0.000746713 (W 0.00151505) | 0.183861 ± 0.000593143 (W 0.00152541) | 0.168826 ± 0.000646286 (W 0.00171796) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.965271 ± 0.00738993 (W 0.00235208) | 0.964501 ± 0.00711654 (W 0.395486) | 0.705217 ± 0.00419478 (W 0.00265333) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.16125 ± 0.0357414 (W 0.00539719) | 2.16236 ± 0.0328019 (W 0.00368811) | 1.62381 ± 0.0512485 (W 0.00830664) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.133449 ± 5.91383e-05 (W 0.000122147) | 0.141272 ± 0.000239972 (W 0.00132719) | 0.059369 ± 0.000315554 (W 0.000134544) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.474479 ± 0.00218839 (W 0.00163018) | 0.535682 ± 0.00270607 (W 0.00192948) | 0.254983 ± 0.000851587 (W 0.0019598) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05114 ± 0.000936737 (W 0.000400773) | 1.18655 ± 0.00127176 (W 0.00141466) | 0.609297 ± 0.00141152 (W 0.00188101) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183807 ± 0.000367913 (W 0.00142134) | 0.183783 ± 0.000155359 (W 0.0015207) | 0.17703 ± 0.000602827 (W 0.00127984) | · | · |  |
| `svd_thin/n64/b1` | 0.994083 ± 0.00348925 (W 0.002837) | 0.992604 ± 0.00219245 (W 0.00265653) | 0.640606 ± 0.00634389 (W 0.00243932) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.27766 ± 0.015616 (W 0.0151489) | 2.26485 ± 0.0090685 (W 0.0254685) | 1.37576 ± 0.00103968 (W 0.00266457) | · | 🔴 faer-fork 1.66× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.133347 ± 0.000496084 (W 0.000142823) | 0.140881 ± 0.000609502 (W 0.000313816) | 0.059359 ± 0.00014817 (W 0.00108277) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.474967 ± 0.00171809 (W 0.00230572) | 0.538389 ± 0.00152142 (W 0.00167403) | 0.259922 ± 0.0015985 (W 0.00162181) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05221 ± 0.0005105 (W 0.00175899) | 1.1866 ± 0.00146534 (W 0.00169948) | 0.610772 ± 0.00242795 (W 0.00157943) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.189324 ± 0.010751 (W 0.00125352) | 0.190125 ± 0.00998556 (W 0.00153778) | 0.177309 ± 0.000193583 (W 0.00104248) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.00596 ± 0.00425119 (W 0.00230555) | 1.00616 ± 0.0153428 (W 0.00736864) | 0.629176 ± 0.00112421 (W 0.00214931) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.28957 ± 0.0163801 (W 0.0231368) | 2.35458 ± 0.0358421 (W 0.0115494) | 1.3238 ± 0.00131881 (W 0.00240956) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.13377 ± 0.000788982 (W 0.00154876) | 0.14151 ± 0.000204564 (W 0.00109503) | 0.059309 ± 0.000295654 (W 0.000116126) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.474256 ± 0.00104203 (W 0.00203374) | 0.536735 ± 0.000628747 (W 0.00168457) | 0.258253 ± 0.00114269 (W 0.00151038) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05331 ± 0.00190502 (W 0.000848167) | 1.18941 ± 0.00185105 (W 0.0029601) | 0.601656 ± 0.00193106 (W 0.00169292) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234224 ± 0.000225323 (W 0.00229208) | 0.23445 ± 0.000777149 (W 0.00218906) | 0.252704 ± 0.00086321 (W 0.00165586) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22083 ± 0.00596556 (W 0.00149965) | 1.22432 ± 0.00634684 (W 0.00313727) | 1.33985 ± 0.00136506 (W 0.0020962) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.13332 ± 0.00948575 (W 0.00389193) | 3.13975 ± 0.0106182 (W 0.00285854) | 3.48748 ± 0.00292384 (W 0.00404736) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.150008 ± 0.000140051 (W 0.00183388) | 0.161179 ± 0.000244099 (W 0.00136651) | 0.102451 ± 0.12183 (W 0.00185102) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.590214 ± 0.00195909 (W 0.00177133) | 0.650977 ± 0.001133 (W 0.00150194) | 0.494052 ± 7.34189e-05 (W 0.00163906) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.37028 ± 0.00206685 (W 0.00172648) | 1.50828 ± 0.00237089 (W 0.00402421) | 1.37357 ± 0.0343327 (W 0.00236408) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234802 ± 0.00918651 (W 0.00148529) | 0.234965 ± 0.00985749 (W 0.00181028) | 0.261324 ± 0.000149697 (W 0.00165426) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.20013 ± 0.00660491 (W 0.00224849) | 1.19759 ± 0.00458977 (W 0.00401481) | 1.03205 ± 0.0025989 (W 0.00127548) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.94593 ± 0.0226543 (W 0.0283902) | 2.9659 ± 0.0123917 (W 0.0167655) | 2.52793 ± 0.00371053 (W 0.00319362) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.149738 ± 0.000114343 (W 0.00129735) | 0.161171 ± 0.000257222 (W 0.00171343) | 0.102698 ± 0.121315 (W 0.00129628) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.58946 ± 0.00140827 (W 0.00201614) | 0.650554 ± 0.00111508 (W 0.00120769) | 0.492072 ± 0.00123864 (W 0.0014897) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.3674 ± 0.00241629 (W 0.00213815) | 1.50297 ± 0.00344122 (W 0.00195949) | 1.35938 ± 0.00230445 (W 0.00151004) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.23389 ± 0.000265782 (W 0.00143483) | 0.234258 ± 0.00049454 (W 0.00192719) | 0.263274 ± 0.000739625 (W 0.00180815) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20782 ± 0.00647149 (W 0.004779) | 1.21827 ± 0.00631195 (W 0.00997352) | 0.99237 ± 0.00176228 (W 0.0014074) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96616 ± 0.0221564 (W 0.0289733) | 3.07528 ± 0.00985147 (W 0.00768065) | 2.34286 ± 0.0028292 (W 0.00134471) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.14994 ± 0.000199731 (W 0.00166996) | 0.161128 ± 4.57857e-05 (W 0.00131415) | 0.102138 ± 0.121868 (W 0.00190798) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.589313 ± 0.000908388 (W 0.00214103) | 0.650646 ± 0.000750267 (W 0.00255314) | 0.490109 ± 0.00187566 (W 0.00201929) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.3675 ± 0.00208697 (W 0.00235229) | 1.50547 ± 0.00459819 (W 0.00218986) | 1.39323 ± 0.00459031 (W 0.00528615) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231603 ± 0.00019307 (W 0.00143656) | 0.232534 ± 0.000926354 (W 0.00151733) | 0.249423 ± 0.000491985 (W 0.00179358) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25636 ± 0.00599062 (W 0.00208027) | 1.25771 ± 0.00365089 (W 0.0020665) | 1.31423 ± 0.00196906 (W 0.00375651) | · | · |  |
| `svd_thin/n96/b1` | 3.08992 ± 0.010527 (W 0.00463979) | 3.09361 ± 0.00748915 (W 0.0127983) | 3.42005 ± 0.00212449 (W 0.0031715) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.152963 ± 0.000231093 (W 0.001261) | 0.158867 ± 0.000377742 (W 0.00116052) | 0.100687 ± 0.000127226 (W 0.000109381) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.594631 ± 0.0016758 (W 0.00210727) | 0.626701 ± 0.000621644 (W 0.00203911) | 0.480331 ± 0.00103303 (W 0.00195268) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.37218 ± 0.00253926 (W 0.00228815) | 1.48116 ± 0.0017344 (W 0.00160766) | 1.34108 ± 0.00279876 (W 0.00182993) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231997 ± 0.0101321 (W 0.00209223) | 0.231946 ± 0.00956786 (W 0.00164344) | 0.257478 ± 0.000401576 (W 0.00109713) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.22758 ± 0.00539417 (W 0.00175044) | 1.225 ± 0.00639011 (W 0.0024625) | 1.00961 ± 0.000661055 (W 0.00194141) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.92985 ± 0.00696423 (W 0.0221506) | 2.93458 ± 0.014797 (W 0.0140731) | 2.50785 ± 0.00389041 (W 0.00317093) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.152795 ± 0.000121233 (W 9.89353e-05) | 0.158897 ± 0.000114948 (W 0.00188957) | 0.100825 ± 0.000339694 (W 0.00206764) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.592426 ± 0.00109605 (W 0.00169674) | 0.6258 ± 0.00094865 (W 0.00175468) | 0.482717 ± 0.00104443 (W 0.00186646) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.3674 ± 0.000408775 (W 0.00239955) | 1.47896 ± 0.00275757 (W 0.00318559) | 1.34545 ± 0.00328704 (W 0.00191942) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231519 ± 0.00123937 (W 0.00190643) | 0.231212 ± 0.000415058 (W 0.00157627) | 0.25882 ± 0.000270252 (W 0.00209173) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23758 ± 0.00110104 (W 0.00320107) | 1.25682 ± 0.00330027 (W 0.00497941) | 0.970414 ± 0.00221913 (W 0.0016433) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.90646 ± 0.00787639 (W 0.0157575) | 3.03321 ± 0.00635385 (W 0.0229678) | 2.32908 ± 0.00506676 (W 0.00210103) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.152755 ± 0.000294257 (W 0.00177518) | 0.158692 ± 0.000165995 (W 0.00142975) | 0.100608 ± 0.000266973 (W 0.000154646) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.591965 ± 0.000939375 (W 0.00177894) | 0.624886 ± 0.00130784 (W 0.00170978) | 0.479134 ± 0.00355938 (W 0.00241529) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36434 ± 0.000482581 (W 0.00151624) | 1.47831 ± 0.0015964 (W 0.00602192) | 1.33731 ± 0.00300241 (W 0.00342036) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137016 ± 0.00226966 (W 0.00168654) | 0.137887 ± 0.00184864 (W 0.000334205) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.533368 ± 0.00235261 (W 0.00214821) | 0.538528 ± 0.00183777 (W 0.00276329) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56695 ± 0.00314503 (W 0.00273976) | 1.56816 ± 0.00164817 (W 0.00257338) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095318 ± 4.66083e-05 (W 0.000253839) | 0.110485 ± 0.000503345 (W 0.000177751) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.331674 ± 0.00195419 (W 0.0026404) | 0.401464 ± 0.00160802 (W 0.00187841) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.724754 ± 0.00140881 (W 0.00155231) | 0.886714 ± 0.00300598 (W 0.00130186) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.136793 ± 5.32666e-05 (W 0.000316947) | 0.137356 ± 0.000461578 (W 0.0013319) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.57707 ± 0.00502571 (W 0.00296156) | 0.608087 ± 0.00524057 (W 0.00437599) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.66337 ± 0.0182785 (W 0.0220911) | 1.71647 ± 0.0069173 (W 0.0168367) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095338 ± 0.000242539 (W 0.0014558) | 0.110274 ± 0.000685505 (W 0.000108505) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.329575 ± 0.000737424 (W 0.00180119) | 0.399616 ± 0.000586161 (W 0.00188931) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.724553 ± 0.00191798 (W 0.00174593) | 0.884732 ± 0.0021722 (W 0.00142095) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.138484 ± 0.00199095 (W 0.0013786) | 0.139026 ± 0.00170805 (W 0.0012281) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.583539 ± 0.00369079 (W 0.00246563) | 0.659162 ± 0.0046129 (W 0.0132187) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.69174 ± 0.0105365 (W 0.00939616) | 1.82176 ± 0.0145241 (W 0.0263442) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095515 ± 0.000420004 (W 0.00149374) | 0.110393 ± 0.000180145 (W 0.00141911) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.331164 ± 0.00158801 (W 0.0019536) | 0.40175 ± 0.00118445 (W 0.00184993) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.724883 ± 0.000974346 (W 0.00109927) | 0.885342 ± 0.000979975 (W 0.00420694) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.145753 ± 0.00169102 (W 0.00121426) | 0.147015 ± 0.00246415 (W 0.0013019) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.537537 ± 0.000849238 (W 0.00186074) | 0.543735 ± 0.00284254 (W 0.00273335) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56195 ± 0.00313028 (W 0.00221702) | 1.5654 ± 0.00373146 (W 0.00232729) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095706 ± 0.000356038 (W 0.00150522) | 0.109425 ± 0.00025322 (W 0.000107244) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.328694 ± 0.000948121 (W 0.00187687) | 0.401424 ± 0.0014483 (W 0.00177385) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.737076 ± 0.00198044 (W 0.00171628) | 0.868251 ± 0.00324919 (W 0.000961728) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.145652 ± 0.000329464 (W 0.00164291) | 0.145823 ± 0.000109877 (W 0.00173172) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.575667 ± 0.00168102 (W 0.004025) | 0.611634 ± 0.00606241 (W 0.00523556) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.67442 ± 0.0197458 (W 0.0231177) | 1.71766 ± 0.00825104 (W 0.0117398) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095427 ± 0.000364222 (W 0.0018437) | 0.109623 ± 0.000485976 (W 0.00143143) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.327998 ± 0.00111888 (W 0.00157554) | 0.400913 ± 0.000785032 (W 0.00272266) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.735874 ± 0.000760092 (W 0.0018728) | 0.865416 ± 0.00179418 (W 0.00123153) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.148052 ± 0.00227163 (W 0.000269979) | 0.148784 ± 0.00239554 (W 0.00134423) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.589714 ± 0.023779 (W 0.00502483) | 0.665663 ± 0.00612368 (W 0.0177563) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.70118 ± 0.00787631 (W 0.0196156) | 1.83277 ± 0.0047305 (W 0.0246881) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.096037 ± 0.000448164 (W 0.000156027) | 0.109922 ± 0.000300005 (W 0.00025856) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.328279 ± 0.00112204 (W 0.00184227) | 0.402532 ± 0.00177311 (W 0.00166684) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.735935 ± 0.0016186 (W 0.00185635) | 0.868601 ± 0.00050781 (W 0.00124753) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170488 ± 0.00637821 (W 0.00150414) | 0.171548 ± 0.00504014 (W 0.0019458) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.686934 ± 0.00307654 (W 0.00248201) | 0.689889 ± 0.00189309 (W 0.00216232) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04623 ± 0.00439387 (W 0.00187915) | 2.04776 ± 0.00171082 (W 0.00320016) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107146 ± 0.000282095 (W 0.00162637) | 0.118831 ± 6.74858e-05 (W 0.000156542) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.393129 ± 0.000670291 (W 0.00163964) | 0.459101 ± 0.000515252 (W 0.00245753) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.890623 ± 0.00130885 (W 0.00175) | 1.05861 ± 0.00233078 (W 0.000655938) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170719 ± 0.000540475 (W 0.00186054) | 0.171761 ± 0.000423352 (W 0.00142447) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.693114 ± 0.0159924 (W 0.00417504) | 0.698063 ± 0.0114103 (W 0.00308006) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.00814 ± 0.0127393 (W 0.0178246) | 2.02204 ± 0.0195785 (W 0.0312633) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107209 ± 0.000467009 (W 0.000113712) | 0.119423 ± 0.000168298 (W 0.00186816) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.392773 ± 0.00100796 (W 0.00165813) | 0.460791 ± 0.00201767 (W 0.00172862) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.89033 ± 0.00222316 (W 0.00153711) | 1.05996 ± 0.00478132 (W 0.00141797) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170847 ± 0.000528358 (W 0.00151309) | 0.171269 ± 0.00102768 (W 0.00169275) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.701169 ± 0.00375435 (W 0.00400949) | 0.711118 ± 0.0105931 (W 0.0114793) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04177 ± 0.00344677 (W 0.0181306) | 2.11342 ± 0.0129318 (W 0.0223441) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107288 ± 5.14684e-05 (W 0.00100448) | 0.119038 ± 0.000320433 (W 0.00132965) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.391787 ± 0.00059928 (W 0.00175081) | 0.458736 ± 0.00182279 (W 0.00236608) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.888187 ± 0.00196926 (W 0.00177301) | 1.0575 ± 0.00127715 (W 0.00149891) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172592 ± 0.00702527 (W 0.00162021) | 0.173935 ± 0.00576379 (W 0.00161461) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.696711 ± 0.0021374 (W 0.00140348) | 0.698545 ± 0.00302055 (W 0.00171716) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.06214 ± 0.00197115 (W 0.00237477) | 2.0662 ± 0.00289683 (W 0.00172576) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.106846 ± 0.000303531 (W 0.00164846) | 0.119 ± 0.000321842 (W 0.00119711) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.391231 ± 0.00106915 (W 0.00175971) | 0.452871 ± 0.00180065 (W 0.00167326) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.907032 ± 0.00175265 (W 0.00126052) | 1.05783 ± 0.00274971 (W 0.00118459) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172691 ± 0.0006635 (W 0.00176229) | 0.173441 ± 0.000545396 (W 0.00173756) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.701409 ± 0.00268484 (W 0.00595051) | 0.707541 ± 0.00708925 (W 0.00452163) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.03821 ± 0.0259378 (W 0.0321051) | 2.04037 ± 0.0144596 (W 0.0306991) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.106507 ± 0.000327098 (W 0.00010827) | 0.119343 ± 0.000227056 (W 0.00131746) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.391395 ± 0.00132967 (W 0.00241564) | 0.453641 ± 0.00266871 (W 0.00204031) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.906411 ± 0.00128468 (W 0.00127131) | 1.05754 ± 0.00288659 (W 0.00216376) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172971 ± 0.00038388 (W 0.000345826) | 0.17433 ± 9.13947e-05 (W 0.00131819) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.711899 ± 0.00185602 (W 0.0052478) | 0.71781 ± 0.000995454 (W 0.00660196) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04355 ± 0.0144168 (W 0.0128709) | 2.12554 ± 0.00918125 (W 0.0166204) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.106818 ± 0.0001165 (W 0.00151458) | 0.119289 ± 0.000379123 (W 0.000428466) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.390023 ± 0.000903683 (W 0.00202001) | 0.452685 ± 0.000875581 (W 0.00188227) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.904428 ± 0.00324819 (W 0.000477961) | 1.0545 ± 0.00218476 (W 0.000830369) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.68226 ± 0.0133361 (W 0.00597871) | 3.68415 ± 0.00783722 (W 0.00542592) | 3.40334 ± 0.00909345 (W 0.0179914) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.509 ± 0.00803269 (W 0.0225089) | 18.502 ± 0.00896138 (W 0.0205587) | 18.0683 ± 0.0243218 (W 0.0358008) | · | · |  |
| `svd_thin/n512/b1` | 106.117 ± 0.56332 (W 0.391324) | 106.067 ± 0.484506 (W 0.471717) | 117.26 ± 0.682007 (W 0.249961) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.01733 ± 0.00796464 (W 0.00269834) | 2.68759 ± 0.00549786 (W 0.00373896) | 1.19579 ± 0.0284362 (W 0.00202928) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.3997 ± 0.0257056 (W 0.0103257) | 12.4593 ± 0.00139927 (W 0.0133176) | 6.95023 ± 0.138528 (W 0.0117606) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.446 ± 0.228422 (W 0.034619) | 66.2608 ± 0.127677 (W 0.0611713) | 47.5297 ± 1.27215 (W 0.0680074) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.01626 ± 0.0171026 (W 0.0205072) | 3.0214 ± 0.0121004 (W 0.0225733) | 2.62923 ± 0.00431505 (W 0.00507818) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.738 ± 0.0552714 (W 0.0439752) | 13.6661 ± 0.0323459 (W 0.0259824) | 12.4844 ± 0.031473 (W 0.022988) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.6482 ± 0.178783 (W 0.300506) | 61.6849 ± 0.301588 (W 0.196995) | 57.8936 ± 0.103601 (W 0.0845353) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.01967 ± 0.00124335 (W 0.00329333) | 2.21689 ± 0.00173243 (W 0.00493532) | 1.1385 ± 0.00498516 (W 0.00217538) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8985 ± 0.0638336 (W 0.0779993) | 10.8369 ± 0.029224 (W 0.0285198) | 6.16535 ± 0.111887 (W 0.0105451) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.0822 ± 0.179373 (W 0.312671) | 48.206 ± 0.109259 (W 0.416352) | 25.8491 ± 0.511952 (W 0.113736) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.03764 ± 0.00809613 (W 0.0082912) | 3.09496 ± 0.0119866 (W 0.0251325) | 2.51303 ± 0.00449787 (W 0.00741236) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4769 ± 0.0444752 (W 0.0424168) | 13.7557 ± 0.0409434 (W 0.0350954) | 11.5006 ± 0.0318725 (W 0.0123366) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.2516 ± 0.183249 (W 0.553762) | 60.7262 ± 0.222882 (W 0.342821) | 49.0288 ± 2.14918 (W 0.0569434) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.02299 ± 0.00941139 (W 0.00343813) | 2.21054 ± 0.042883 (W 0.00399508) | 1.12119 ± 0.00134209 (W 0.00153552) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 11.027 ± 0.0227074 (W 0.0284785) | 10.9563 ± 0.0394033 (W 0.035294) | 6.01791 ± 0.1804 (W 0.0108189) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 49.0678 ± 0.420319 (W 0.484837) | 49.3598 ± 0.158088 (W 0.369017) | 22.389 ± 0.633512 (W 0.0377187) | · | 🔴 faer-fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.67802 ± 0.00826532 (W 0.00659325) | 3.68362 ± 0.0157585 (W 0.00489838) | 3.30572 ± 0.0145505 (W 0.0107867) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4086 ± 0.00828003 (W 0.0281356) | 18.3849 ± 0.0118142 (W 0.0222473) | 17.7568 ± 0.0462741 (W 0.030017) | · | · |  |
| `svd_thin/n512/b1` | 105.593 ± 0.571987 (W 0.14691) | 105.497 ± 0.63267 (W 0.0781053) | 115.367 ± 0.500703 (W 0.0951338) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.97342 ± 0.0134622 (W 0.00243505) | 2.61812 ± 0.00610461 (W 0.00481504) | 1.16077 ± 0.00513879 (W 0.00370984) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.2183 ± 0.0396194 (W 0.0113973) | 12.2794 ± 0.0139606 (W 0.0112205) | 6.85032 ± 0.0128106 (W 0.00955157) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 58.9135 ± 0.124732 (W 0.0446467) | 65.2451 ± 0.0462426 (W 0.383134) | 47.4821 ± 0.431665 (W 0.0712821) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.99522 ± 0.00333724 (W 0.0140479) | 2.99177 ± 0.0127259 (W 0.0160834) | 2.58646 ± 0.0100465 (W 0.00553434) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5996 ± 0.064371 (W 0.0798541) | 13.6218 ± 0.0236424 (W 0.0920338) | 12.2842 ± 0.0187239 (W 0.0340404) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.7303 ± 0.335996 (W 0.197684) | 60.8198 ± 0.144424 (W 0.31542) | 59.5651 ± 1.85393 (W 0.0731305) | · | · | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.97484 ± 0.00162895 (W 0.00180258) | 2.15071 ± 0.000949337 (W 0.0015462) | 1.12173 ± 0.00187112 (W 0.0021906) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6719 ± 0.0443744 (W 0.0376999) | 10.6445 ± 0.0263259 (W 0.0391714) | 6.09045 ± 0.0235622 (W 0.0117071) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.1353 ± 0.264272 (W 0.440079) | 47.355 ± 0.224371 (W 0.295112) | 25.6433 ± 0.208058 (W 0.0352271) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.01868 ± 0.0171751 (W 0.0140387) | 3.09586 ± 0.0064547 (W 0.01565) | 2.46899 ± 0.0108529 (W 0.00180235) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3474 ± 0.0096962 (W 0.0367427) | 13.6407 ± 0.00238283 (W 0.0535104) | 11.3555 ± 0.0226322 (W 0.018279) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.4643 ± 0.285176 (W 0.289349) | 59.8694 ± 0.362423 (W 0.475378) | 47.7199 ± 0.897339 (W 0.0778576) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.97288 ± 0.00462417 (W 0.00240199) | 2.14445 ± 0.041044 (W 0.00355652) | 1.11625 ± 0.0028848 (W 0.00235235) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.7995 ± 0.030708 (W 0.025369) | 10.7663 ± 0.0164499 (W 0.0221277) | 6.04794 ± 0.0187306 (W 0.003525) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.0473 ± 0.209038 (W 0.315513) | 48.0868 ± 0.153421 (W 0.406362) | 22.3786 ± 0.140941 (W 0.0336463) | · | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.74818 ± 0.0119646 (W 0.00552767) | 5.75069 ± 0.00913857 (W 0.00601992) | 7.05909 ± 0.00951481 (W 0.0117849) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.2057 ± 0.0742866 (W 0.0345773) | 34.2124 ± 0.0365357 (W 0.100105) | 43.656 ± 0.174408 (W 0.0478676) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 210.527 ± 0.0475866 (W 0.519939) | 211.449 ± 0.484607 (W 0.502316) | 275.475 ± 0.548058 (W 0.626923) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.80536 ± 0.00150116 (W 0.00475432) | 3.47776 ± 0.0104729 (W 0.0117666) | 2.76099 ± 0.00409794 (W 0.00262854) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 17.2457 ± 0.0215567 (W 0.0208535) | 19.2744 ± 0.0344186 (W 0.0329334) | 18.1376 ± 0.0246813 (W 0.0218081) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 104.313 ± 0.0697558 (W 0.363979) | 111.656 ± 0.539701 (W 0.504932) | 122.735 ± 0.763313 (W 0.0500711) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.3358 ± 0.00563552 (W 0.0234852) | 4.32431 ± 0.0438787 (W 0.0158808) | 4.14987 ± 0.000788623 (W 0.0111303) | · | · |  |
| `svd_thin/n256/b1` | 22.5003 ± 0.173212 (W 0.0679946) | 22.5928 ± 0.190014 (W 0.124458) | 21.3315 ± 0.0972278 (W 0.0396836) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.9889 ± 0.18596 (W 0.322615) | 94.8068 ± 0.151705 (W 0.362085) | 114.621 ± 5.06767 (W 0.249246) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.80291 ± 0.00537233 (W 0.00376474) | 3.03637 ± 0.0081692 (W 0.00777643) | 2.02137 ± 0.00206822 (W 0.00291164) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.9771 ± 0.204129 (W 0.106574) | 17.0124 ± 0.0564866 (W 0.0900323) | 11.1093 ± 0.0724377 (W 0.026241) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 64.8546 ± 0.210316 (W 0.270677) | 64.9046 ± 0.183114 (W 0.209397) | 56.4288 ± 0.0132438 (W 0.0504944) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.20232 ± 0.015328 (W 0.0367759) | 4.47636 ± 0.0155688 (W 0.0275444) | 3.64266 ± 0.00520912 (W 0.00599176) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.1605 ± 0.149623 (W 0.0741212) | 21.851 ± 0.0800698 (W 0.171963) | 17.2765 ± 0.0375809 (W 0.0371683) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 79.9835 ± 0.471536 (W 0.523486) | 81.7187 ± 0.247115 (W 0.407809) | 84.9998 ± 5.10327 (W 0.0696908) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.80721 ± 0.0058886 (W 0.00655562) | 3.09008 ± 0.0107699 (W 0.00983329) | 1.92143 ± 0.00711591 (W 0.00608084) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.0602 ± 0.107743 (W 0.0714111) | 17.1717 ± 0.107063 (W 0.0649611) | 9.6663 ± 0.0196998 (W 0.0214547) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 61.0538 ± 0.205396 (W 0.128997) | 60.8672 ± 0.28056 (W 0.301608) | 43.3295 ± 0.0683891 (W 0.0674602) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.71085 ± 0.0161703 (W 0.00851318) | 5.70547 ± 0.0104715 (W 0.00738726) | 6.97178 ± 0.0145217 (W 0.00802112) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.8766 ± 0.0509667 (W 0.0407274) | 33.8693 ± 0.00564548 (W 0.0382672) | 45.2244 ± 1.36912 (W 0.106171) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 209.085 ± 0.333556 (W 0.537169) | 209.598 ± 0.924647 (W 0.596605) | 305.983 ± 21.8909 (W 0.57753) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.77888 ± 0.00326428 (W 0.00409422) | 3.45599 ± 0.0105129 (W 0.0067185) | 2.72126 ± 0.001346 (W 0.00321146) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 16.9694 ± 0.0474042 (W 0.0163643) | 18.9561 ± 0.177493 (W 0.047933) | 19.88 ± 1.16342 (W 0.105094) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 103.023 ± 0.631004 (W 0.448976) | 110.016 ± 0.434887 (W 0.426125) | 151.781 ± 19.0112 (W 0.354489) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.32289 ± 0.01616 (W 0.0214514) | 4.32143 ± 0.0420432 (W 0.0245899) | 4.10004 ± 0.00879706 (W 0.00606527) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.2388 ± 0.201801 (W 0.0480092) | 22.2886 ± 0.215461 (W 0.0836622) | 21.1132 ± 0.0587165 (W 0.0363607) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 93.93 ± 0.13429 (W 0.359183) | 93.7433 ± 0.309302 (W 0.204766) | 113.223 ± 0.340944 (W 0.150078) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.7794 ± 0.00915604 (W 0.00550231) | 2.99972 ± 0.00945646 (W 0.00679833) | 2.01625 ± 0.0052556 (W 0.00482475) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.7917 ± 0.0822861 (W 0.0861315) | 16.763 ± 0.163322 (W 0.121285) | 11.0694 ± 0.0286771 (W 0.0283716) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 63.9934 ± 0.133806 (W 0.326011) | 64.0603 ± 0.327963 (W 0.184535) | 66.9744 ± 6.57878 (W 0.0811809) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.19309 ± 0.00625282 (W 0.0149611) | 4.44413 ± 0.0163148 (W 0.0276535) | 3.59665 ± 0.00272404 (W 0.00728716) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.0096 ± 0.0507386 (W 0.0590541) | 21.5149 ± 0.163003 (W 0.0496017) | 17.1113 ± 0.0379337 (W 0.0485165) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 78.864 ± 0.429737 (W 0.168754) | 80.4272 ± 0.82249 (W 0.665371) | 82.1186 ± 1.0482 (W 0.10584) | · | · |  |
| `svd_values/n128/b1` | 2.77387 ± 0.0138188 (W 0.00634107) | 3.0601 ± 0.0138076 (W 0.00855891) | 1.90314 ± 0.228564 (W 0.00395849) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n256/b1` | 16.9526 ± 0.0891136 (W 0.0727118) | 16.869 ± 0.0443739 (W 0.0624722) | 9.66396 ± 0.0217615 (W 0.0143193) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.1766 ± 0.125832 (W 0.247509) | 60.2363 ± 0.0974652 (W 0.256872) | 43.1094 ± 0.0789582 (W 0.0424321) | · | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.31878 ± 0.0230148 (W 0.00260297) | 2.32317 ± 0.0210933 (W 0.00261038) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2083 ± 0.00838904 (W 0.0124789) | 11.1882 ± 0.0155202 (W 0.00919924) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 61.7315 ± 0.115098 (W 0.0422092) | 61.6432 ± 0.131497 (W 0.071897) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30199 ± 0.00386227 (W 0.00296033) | 1.71963 ± 0.00625313 (W 0.0030294) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.13355 ± 0.0195496 (W 0.00885768) | 7.88274 ± 0.0286875 (W 0.0108816) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 34.213 ± 0.113321 (W 0.0314808) | 40.2 ± 0.0688465 (W 0.0272918) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.01933 ± 0.0151869 (W 0.0262797) | 2.0724 ± 0.00213528 (W 0.00908445) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.72238 ± 0.0113441 (W 0.0597707) | 8.71707 ± 0.0227363 (W 0.0167823) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.6521 ± 0.524583 (W 0.595316) | 42.075 ± 0.458761 (W 0.487487) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29687 ± 0.00194627 (W 0.00167946) | 1.48585 ± 0.0027214 (W 0.00390297) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.99208 ± 0.0175488 (W 0.0154002) | 6.99014 ± 0.0197754 (W 0.0214219) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.9136 ± 0.239575 (W 0.55274) | 33.9896 ± 0.103005 (W 0.354717) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.04518 ± 0.00349762 (W 0.0137958) | 2.26065 ± 0.00743647 (W 0.0169158) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.67906 ± 0.0564299 (W 0.0242422) | 9.17839 ± 0.0197704 (W 0.0426283) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 42.261 ± 0.0520876 (W 0.365203) | 43.7532 ± 0.584 (W 0.365533) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29614 ± 0.00195761 (W 0.00186952) | 1.49557 ± 0.0130784 (W 0.00376273) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.11477 ± 0.017272 (W 0.0109028) | 7.10061 ± 0.025917 (W 0.0247505) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 36.0485 ± 0.0721258 (W 0.405172) | 36.0018 ± 0.181708 (W 0.42452) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.33351 ± 0.0235253 (W 0.00346319) | 2.33737 ± 0.0224593 (W 0.00447258) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2202 ± 0.00444468 (W 0.0194585) | 11.2028 ± 0.00955063 (W 0.0152645) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 61.1816 ± 0.035509 (W 0.0688527) | 60.9921 ± 0.113383 (W 0.0591389) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30419 ± 0.00513783 (W 0.00240483) | 1.68502 ± 0.00568043 (W 0.00340548) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.04876 ± 0.0167785 (W 0.0108125) | 7.71488 ± 0.0296912 (W 0.00787811) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.4655 ± 0.0835008 (W 0.0244777) | 39.6124 ± 0.107388 (W 0.0367976) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.03355 ± 0.0071022 (W 0.0107772) | 2.07882 ± 0.0137446 (W 0.0134232) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.71052 ± 0.0230907 (W 0.0633837) | 8.68702 ± 0.0185974 (W 0.0313649) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.119 ± 0.152866 (W 0.599732) | 41.1822 ± 0.143168 (W 0.655313) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29502 ± 0.00118367 (W 0.0033321) | 1.45812 ± 0.0104748 (W 0.00969936) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.82711 ± 0.0119252 (W 0.0217953) | 6.81187 ± 0.0269049 (W 0.0330666) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.4031 ± 0.821792 (W 0.514843) | 33.8095 ± 0.433246 (W 0.925084) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.05968 ± 0.00490197 (W 0.0157819) | 2.26304 ± 0.0148965 (W 0.0190883) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.64705 ± 0.0358568 (W 0.0181653) | 9.17578 ± 0.0407438 (W 0.032076) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.2247 ± 0.0899848 (W 0.362432) | 42.9096 ± 0.384277 (W 0.486246) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29256 ± 0.00201947 (W 0.00146113) | 1.45647 ± 0.00477607 (W 0.00118258) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.94945 ± 0.0231758 (W 0.0179008) | 6.94792 ± 0.00234156 (W 0.018773) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 35.0275 ± 0.332648 (W 0.318107) | 35.3566 ± 0.312166 (W 0.386754) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.39545 ± 0.0147161 (W 0.004514) | 3.40202 ± 0.0107433 (W 0.00345158) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.8211 ± 0.0277616 (W 0.0166059) | 19.8175 ± 0.0158425 (W 0.0180799) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 123.456 ± 0.198926 (W 0.0900143) | 123.365 ± 0.219826 (W 0.0881448) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.76292 ± 0.00557882 (W 0.00313923) | 2.16859 ± 0.00653232 (W 0.00460171) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.11 ± 0.0317165 (W 0.0156579) | 11.8417 ± 0.0135747 (W 0.0192632) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 64.4325 ± 0.0949736 (W 0.044464) | 70.4761 ± 0.10564 (W 0.0532613) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.78978 ± 0.00577925 (W 0.0292132) | 2.81284 ± 0.0336016 (W 0.0389131) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.9417 ± 0.0166591 (W 0.0514685) | 13.9723 ± 0.0669089 (W 0.044754) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 64.9753 ± 0.0628042 (W 0.195477) | 64.8879 ± 0.0646648 (W 0.194873) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.76339 ± 0.00817919 (W 0.0112612) | 1.9554 ± 0.0116209 (W 0.00329299) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.7005 ± 0.0297587 (W 0.0573831) | 10.695 ± 0.0608432 (W 0.0590271) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 48.3251 ± 0.369886 (W 0.296489) | 48.3404 ± 0.158583 (W 0.290432) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.75137 ± 0.0117317 (W 0.0173954) | 2.93508 ± 0.0216163 (W 0.0194768) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.3637 ± 0.0657897 (W 0.054938) | 13.7049 ± 0.0653901 (W 0.0410718) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 59.0708 ± 0.284316 (W 0.305659) | 60.8001 ± 0.192441 (W 0.417262) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.75614 ± 0.00142089 (W 0.00326643) | 1.95599 ± 0.0514972 (W 0.00892016) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.7205 ± 0.0603109 (W 0.0367433) | 10.727 ± 0.0252182 (W 0.0174925) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 48.1497 ± 0.235317 (W 0.421322) | 47.7415 ± 0.190474 (W 0.268486) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.38287 ± 0.00356508 (W 0.00349546) | 3.39464 ± 0.00514336 (W 0.00258598) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.6758 ± 0.0332144 (W 0.0176295) | 19.697 ± 0.0240339 (W 0.019622) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 122.595 ± 0.233083 (W 0.0953298) | 122.442 ± 0.318586 (W 0.0710763) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.72702 ± 0.00601147 (W 0.00208279) | 2.13907 ± 0.00438845 (W 0.00118673) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.0091 ± 0.0106549 (W 0.0122114) | 11.7056 ± 0.0203756 (W 0.0194648) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 63.4608 ± 0.0560746 (W 0.074716) | 69.5684 ± 0.102416 (W 0.0404261) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.76511 ± 0.0177488 (W 0.0289913) | 2.7573 ± 0.0148485 (W 0.0376951) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.7919 ± 0.0186861 (W 0.0622269) | 13.7324 ± 0.0311874 (W 0.0520871) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 64.0168 ± 0.168805 (W 0.211324) | 63.745 ± 0.24867 (W 0.209902) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.72065 ± 0.00606323 (W 0.00140774) | 1.92282 ± 0.0114446 (W 0.0023791) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.5791 ± 0.0333123 (W 0.0518222) | 10.5899 ± 0.0217533 (W 0.0750437) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.2422 ± 0.284884 (W 0.200574) | 47.0885 ± 0.302892 (W 0.372002) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.72699 ± 0.00946818 (W 0.0150964) | 2.92097 ± 0.00877353 (W 0.0159937) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.2326 ± 0.0301384 (W 0.0538466) | 13.6163 ± 0.0310662 (W 0.0465421) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 58.0788 ± 0.101138 (W 0.280044) | 59.5637 ± 0.1962 (W 0.384283) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.71718 ± 0.00267766 (W 0.00256473) | 1.92753 ± 0.00523646 (W 0.00615888) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.6208 ± 0.0483604 (W 0.0171659) | 10.6281 ± 0.0342454 (W 0.0176265) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.1069 ± 0.192984 (W 0.299222) | 46.8867 ± 0.205147 (W 0.335378) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.4982 ± 0.0052632 (W 0.00315477) | 2.49499 ± 0.00582148 (W 0.00375925) | 3.0472 ± 0.0125647 (W 0.00484385) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 87.9358 ± 0.057012 (W 0.156711) | 88.3764 ± 0.159038 (W 0.136697) | 120.107 ± 0.641479 (W 0.243371) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.4559 ± 0.00219284 (W 0.00562924) | 1.48381 ± 0.00319572 (W 0.00576444) | 1.388 ± 0.160919 (W 0.00422914) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 43.8147 ± 0.062811 (W 0.0403982) | 44.8446 ± 0.082659 (W 0.0559461) | 46.5391 ± 3.66718 (W 0.0911092) | · | · | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.34204 ± 0.0129021 (W 0.0215768) | 2.79261 ± 0.00568132 (W 0.0211193) | 1.89101 ± 0.00434599 (W 0.00881873) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 46.5765 ± 0.0811018 (W 0.186002) | 50.3685 ± 0.0530523 (W 0.162695) | 53.459 ± 2.74442 (W 0.180443) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.60521 ± 0.0192116 (W 0.0136485) | 2.12074 ± 0.0347176 (W 0.020476) | 0.963919 ± 0.134485 (W 0.00765657) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.67× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 31.1012 ± 0.103244 (W 0.164843) | 35.3496 ± 0.0635571 (W 0.115702) | 22.4594 ± 2.94409 (W 0.109529) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.49399 ± 0.00275163 (W 0.0225365) | 3.17945 ± 0.0210487 (W 0.034637) | 1.6714 ± 0.0185737 (W 0.0045112) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.5925 ± 0.0581962 (W 0.114036) | 52.473 ± 1.67882 (W 1.22458) | 36.6284 ± 0.0454082 (W 0.0862579) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.73609 ± 0.0113146 (W 0.0224601) | 2.51991 ± 0.0235975 (W 0.0340547) | 0.816204 ± 0.193216 (W 0.00530233) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 29.5395 ± 0.0489905 (W 0.0944476) | 37.2455 ± 0.0146305 (W 0.136341) | 16.9208 ± 2.48024 (W 0.0543302) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.4398 ± 0.00314739 (W 0.00327421) | 2.44146 ± 0.00980923 (W 0.00311948) | 2.81988 ± 0.016741 (W 0.00818314) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.6621 ± 0.0853678 (W 0.0626631) | 82.9878 ± 0.145293 (W 0.148165) | 109.786 ± 0.556416 (W 0.208606) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.38303 ± 0.00189577 (W 0.00409333) | 1.39347 ± 0.00148431 (W 0.00293537) | 1.23986 ± 0.00422244 (W 0.00454717) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 37.5628 ± 0.0635614 (W 0.0566423) | 39.118 ± 0.0211733 (W 0.0361558) | 40.3813 ± 0.0931263 (W 0.041057) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.28987 ± 0.00953415 (W 0.0223191) | 2.73626 ± 0.0108043 (W 0.0305713) | 1.82657 ± 0.0111771 (W 0.00442724) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.9371 ± 0.102766 (W 0.140856) | 44.6814 ± 0.0793467 (W 0.124064) | 45.4436 ± 0.298707 (W 0.0738324) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.55422 ± 0.0153097 (W 0.0124225) | 2.01943 ± 0.0191123 (W 0.0285545) | 0.907636 ± 0.00276328 (W 0.00628643) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.6275 ± 0.264478 (W 0.172705) | 29.7281 ± 0.0397882 (W 0.119614) | 20.9549 ± 0.0897776 (W 0.0556082) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.44719 ± 0.0153841 (W 0.0129742) | 3.09413 ± 0.0078676 (W 0.0208896) | 1.63588 ± 0.00435916 (W 0.00325412) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 35.0227 ± 0.0502729 (W 0.128332) | 44.8061 ± 0.463637 (W 2.20587) | 34.3464 ± 0.0387926 (W 0.0991559) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.68571 ± 0.0186749 (W 0.0261069) | 2.41298 ± 0.0126296 (W 0.0233973) | 0.779607 ± 0.00610698 (W 0.00394193) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.0077 ± 0.0552194 (W 0.0772044) | 31.7616 ± 0.0211631 (W 0.236945) | 15.7527 ± 0.198647 (W 0.0477809) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.97221 ± 0.0156455 (W 0.00504731) | 5.99179 ± 0.0157343 (W 0.00727699) | 8.76289 ± 0.035448 (W 0.0240843) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 280.765 ± 0.594737 (W 2.49061) | 280.734 ± 1.23695 (W 0.449779) | 380.358 ± 0.123128 (W 0.514536) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.03348 ± 0.00855432 (W 0.0019533) | 3.06976 ± 0.00901819 (W 0.00487366) | 3.81052 ± 0.026163 (W 0.00554137) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 120.701 ± 0.100435 (W 0.400628) | 122.384 ± 0.0387085 (W 0.0810197) | 144.794 ± 7.03013 (W 0.448097) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.17406 ± 0.0902492 (W 0.122447) | 4.36982 ± 0.023714 (W 0.0197178) | 5.47928 ± 0.00934871 (W 0.00703543) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 114.662 ± 0.643621 (W 0.591565) | 122.245 ± 0.108789 (W 0.225756) | 140.354 ± 0.456016 (W 0.27012) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.62315 ± 0.0773179 (W 0.0700503) | 3.03417 ± 0.0170909 (W 0.0274829) | 2.80072 ± 0.0128973 (W 0.0362796) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 66.6675 ± 1.34922 (W 0.243419) | 75.1071 ± 0.652453 (W 0.425377) | 51.3946 ± 5.309 (W 0.328887) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.82068 ± 0.00850456 (W 0.0156913) | 4.66749 ± 0.0131092 (W 0.0311587) | 4.4227 ± 0.0218253 (W 0.0117644) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.6451 ± 0.204672 (W 0.384173) | 105.29 ± 0.0769561 (W 2.22643) | 83.3491 ± 0.378133 (W 0.353394) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.59157 ± 0.00676675 (W 0.0128574) | 3.3615 ± 0.023641 (W 0.0289193) | 2.32976 ± 0.00691765 (W 0.00370364) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 58.3898 ± 0.0142667 (W 0.357695) | 72.8362 ± 0.114482 (W 0.507658) | 34.4109 ± 4.901 (W 0.217079) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.87901 ± 0.00703015 (W 0.00547861) | 5.89387 ± 0.00824953 (W 0.00607607) | 8.53361 ± 0.0456468 (W 0.0117059) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 268.059 ± 0.0560505 (W 0.379422) | 268.018 ± 0.202272 (W 0.118255) | 375.602 ± 2.48566 (W 1.37702) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.93074 ± 0.00448982 (W 0.00377866) | 2.95227 ± 0.0101724 (W 0.00507953) | 3.67621 ± 0.0185124 (W 0.00231563) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 108.413 ± 0.0225667 (W 0.0963862) | 110.273 ± 0.0596732 (W 0.136297) | 146.073 ± 3.44742 (W 0.1347) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.8867 ± 0.0952631 (W 0.0532657) | 4.26799 ± 0.0164644 (W 0.0218494) | 5.39356 ± 0.0069554 (W 0.0103525) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 102.804 ± 0.153026 (W 0.139453) | 110.142 ± 0.0828649 (W 0.187175) | 128.518 ± 0.65098 (W 0.327963) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.5168 ± 0.0258031 (W 0.0649712) | 2.93834 ± 0.0259711 (W 0.0144543) | 2.78713 ± 0.00510268 (W 0.00637579) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 54.7511 ± 0.101818 (W 0.143101) | 63.1903 ± 0.0837836 (W 0.0581004) | 48.691 ± 0.0649065 (W 0.0598269) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.71687 ± 0.0232316 (W 0.0173261) | 4.55126 ± 0.0219554 (W 0.0190987) | 4.37806 ± 0.0210465 (W 0.00657822) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 76.1991 ± 0.229523 (W 0.206063) | 94.6145 ± 2.06412 (W 2.57322) | 73.658 ± 0.393911 (W 0.197184) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.5177 ± 0.0114509 (W 0.0241659) | 3.25594 ± 0.0366674 (W 0.0355763) | 2.2858 ± 0.0146534 (W 0.00244556) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 46.8406 ± 0.0774978 (W 0.082614) | 60.908 ± 0.147671 (W 0.110794) | 32.445 ± 0.211223 (W 0.254505) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.59105 ± 0.0174994 (W 0.00388388) | 1.594 ± 0.0140621 (W 0.00243059) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.0243 ± 0.107095 (W 0.0449476) | 49.2984 ± 0.262577 (W 0.0598137) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.09806 ± 0.00370193 (W 0.00410876) | 1.14029 ± 0.00242729 (W 0.00346411) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 26.6227 ± 0.0191992 (W 0.0575018) | 27.4837 ± 0.114586 (W 0.0373558) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.71063 ± 0.02238 (W 0.0283792) | 2.16057 ± 0.00865943 (W 0.0283048) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 27.4889 ± 0.0609549 (W 0.205387) | 31.3161 ± 0.10024 (W 0.14517) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.31062 ± 0.00612812 (W 0.0125546) | 1.86416 ± 0.0157129 (W 0.0230948) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 20.2158 ± 0.175681 (W 0.284666) | 24.3626 ± 0.0386963 (W 0.0747683) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.83541 ± 0.00338179 (W 0.0129386) | 2.53703 ± 0.00684853 (W 0.0321635) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.7349 ± 0.0642113 (W 0.0623438) | 33.2227 ± 0.0806202 (W 0.450693) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.41992 ± 0.00595894 (W 0.0152438) | 2.22921 ± 0.0262125 (W 0.0356643) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.8077 ± 0.0360775 (W 0.0565487) | 26.6381 ± 0.00794753 (W 0.243354) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.58741 ± 0.0145652 (W 0.00431428) | 1.58983 ± 0.0154178 (W 0.0033141) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.2608 ± 0.155839 (W 0.0616825) | 46.3916 ± 0.0988307 (W 0.0558301) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.05299 ± 0.000584661 (W 0.00129927) | 1.09351 ± 0.00268333 (W 0.00104767) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 22.8319 ± 0.0356021 (W 0.0275194) | 24.3007 ± 0.144271 (W 0.0170679) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.71521 ± 0.0106936 (W 0.0116578) | 2.12391 ± 0.0117898 (W 0.0150378) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.1015 ± 0.190676 (W 0.157995) | 27.9303 ± 0.0341729 (W 0.100827) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.25645 ± 0.0144178 (W 0.0287307) | 1.79154 ± 0.0131049 (W 0.0251618) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.8466 ± 0.225987 (W 0.208728) | 20.8555 ± 0.0765515 (W 0.16215) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.82507 ± 0.00202671 (W 0.0323509) | 2.50936 ± 0.0163155 (W 0.029117) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.3627 ± 0.00538057 (W 0.0680714) | 29.8607 ± 0.220197 (W 0.420835) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.37275 ± 0.00499723 (W 0.0142072) | 2.13664 ± 0.0209231 (W 0.021072) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.1841 ± 0.0502829 (W 0.323257) | 23.1972 ± 0.174328 (W 0.218329) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.3983 ± 0.0021525 (W 0.00508952) | 3.38927 ± 0.00561877 (W 0.00624046) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 147.312 ± 0.171496 (W 0.410518) | 146.488 ± 0.0937602 (W 0.420045) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.96697 ± 0.00379344 (W 0.0063312) | 2.00701 ± 0.00677352 (W 0.00554536) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 66.8579 ± 0.115613 (W 0.0811748) | 67.4854 ± 0.082119 (W 0.06354) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.64165 ± 0.0117384 (W 0.0574539) | 2.9889 ± 0.0162313 (W 0.0267185) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 63.4082 ± 0.0737251 (W 0.19931) | 69.267 ± 0.0356555 (W 0.101794) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 2.00392 ± 0.024794 (W 0.0410388) | 2.35285 ± 0.0319864 (W 0.0261135) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 39.2945 ± 0.0828316 (W 0.196187) | 45.3749 ± 0.0911687 (W 0.0812845) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.64674 ± 0.0197792 (W 0.010314) | 3.3518 ± 0.0351007 (W 0.0357396) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 50.225 ± 0.056106 (W 0.103211) | 63.3595 ± 0.821252 (W 0.973492) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.98176 ± 0.018945 (W 0.0100576) | 2.74921 ± 0.011866 (W 0.0282479) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 35.5203 ± 0.0607846 (W 0.0712278) | 45.6819 ± 0.127597 (W 0.267366) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.36469 ± 0.00361901 (W 0.00662162) | 3.34719 ± 0.00623607 (W 0.00400076) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 141.829 ± 0.0239082 (W 0.471141) | 140.936 ± 0.136224 (W 0.157826) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.90041 ± 0.00221873 (W 0.00488749) | 1.92751 ± 0.00700352 (W 0.00346089) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 61.1782 ± 0.0400182 (W 0.0481019) | 61.7822 ± 0.0118881 (W 0.0622724) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.61614 ± 0.0342416 (W 0.0160278) | 2.94361 ± 0.0168835 (W 0.0176718) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 57.4086 ± 0.103781 (W 0.166349) | 63.3594 ± 0.122004 (W 1.29001) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.88424 ± 0.0164107 (W 0.0179593) | 2.27874 ± 0.00750402 (W 0.0289305) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 33.5191 ± 0.0133463 (W 0.127097) | 39.6186 ± 0.13492 (W 0.105615) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.59081 ± 0.0222263 (W 0.0142072) | 3.31268 ± 0.006697 (W 0.0239663) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 44.4335 ± 0.00951457 (W 0.0773506) | 56.6221 ± 0.236923 (W 0.451672) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.94457 ± 0.00597481 (W 0.0185631) | 2.6596 ± 0.0297713 (W 0.0412741) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 29.6477 ± 0.0738941 (W 0.106627) | 40.0319 ± 0.10696 (W 0.334755) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
