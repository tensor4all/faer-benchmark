# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `50c2b989484f063f4e1b132adc333715391d8b73`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `a6057782696adc4570c7d108e2c43a6d2a1ab887`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `2a861f00554f7fbb34db33e463c615b6209813a97399a1516a65b9ee9e423476`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T12:05:34.396880Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --no-publish --checkout extern/t4a-faer --label caller-lock-baseline`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T112343Z-caller-lock-baseline/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.52%, worst 665.15% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 31 of 960 engine cells exceed 5% and carry `!`; median within-process relative SD 0.21%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `svd_thin/n32/b1` | 0.182851 ± 0.000500181 (W 0.00120466) | 0.183723 ± 0.000473435 (W 0.00163857) | 0.177692 ± 0.000125033 (W 0.00140041) | · | · |  |
| `svd_thin/n64/b1` | 0.913365 ± 0.00134856 (W 0.00144093) | 0.917263 ± 0.000921413 (W 0.0014012) | 0.761783 ± 0.00264653 (W 0.002816) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.21012 ± 0.0310898 (W 0.00295677) | 2.21519 ± 0.00575207 (W 0.00350642) | 1.68241 ± 0.0527396 (W 0.00252256) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140281 ± 0.000385072 (W 0.000119604) | 0.140442 ± 0.000162583 (W 0.00165745) | 0.064491 ± 0.000463929 (W 0.00115463) | · | 🔴 faer-fork 2.18× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.516815 ± 0.00142884 (W 0.00160515) | 0.517646 ± 0.000997888 (W 0.00164485) | 0.265235 ± 0.000407525 (W 0.00137196) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.1836 ± 0.00119681 (W 0.001988) | 1.18499 ± 0.00178465 (W 0.00124661) | 0.63754 ± 0.00249607 (W 0.00245449) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.181629 ± 0.000842979 (W 0.00147701) | 0.182521 ± 0.00109063 (W 0.00120688) | 0.185136 ± 0.000632024 (W 0.00154232) | · | · |  |
| `svd_thin/n64/b1` | 0.914528 ± 0.00171286 (W 0.00287309) | 0.91588 ± 0.00243882 (W 0.0022246) | 0.669049 ± 0.000435592 (W 0.00177875) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.10177 ± 0.0004914 (W 0.00130223) | 2.10632 ± 0.00164917 (W 0.00143821) | 1.41275 ± 0.00217115 (W 0.00136053) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.139982 ± 0.000121821 (W 0.00154388) | 0.140152 ± 0.000706422 (W 0.00117806) | 0.064331 ± 0.000121162 (W 0.000110592) | · | 🔴 faer-fork 2.18× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.515152 ± 0.000934872 (W 0.00219877) | 0.51445 ± 0.000898168 (W 0.00186432) | 0.270685 ± 0.00131295 (W 0.00197976) | · | 🔴 faer-fork 1.90× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18157 ± 0.00203362 (W 0.00147703) | 1.18371 ± 0.00111494 (W 0.000910694) | 0.605731 ± 0.00149725 (W 0.00189487) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.182841 ± 0.000599003 (W 0.00140407) | 0.183843 ± 0.000648 (W 0.00117772) | 0.187821 ± 0.000375661 (W 0.00173932) | · | · |  |
| `svd_thin/n64/b1` | 0.912733 ± 0.00312933 (W 0.00286255) | 0.919967 ± 0.00407023 (W 0.0023731) | 0.670081 ± 0.00721385 (W 0.0024102) | · | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09896 ± 0.00138558 (W 0.00152207) | 2.11701 ± 0.0042761 (W 0.00306547) | 1.35405 ± 0.0513445 (W 0.00242784) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.139701 ± 0.00032173 (W 0.00157496) | 0.140673 ± 0.000853464 (W 0.00135168) | 0.064511 ± 0.000457989 (W 0.000101046) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.515332 ± 0.00168578 (W 0.00193645) | 0.517195 ± 0.00143359 (W 0.00184756) | 0.270425 ± 0.00027521 (W 0.00154121) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18111 ± 0.00326259 (W 0.0015737) | 1.18639 ± 0.00178226 (W 0.00216747) | 0.59945 ± 0.000727321 (W 0.00176122) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.184123 ± 0.000814509 (W 0.0014612) | 0.185406 ± 0.000440194 (W 0.00138716) | 0.168525 ± 0.000161463 (W 0.00117213) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.957067 ± 0.00134996 (W 0.00114028) | 0.960693 ± 0.00087962 (W 0.0019193) | 0.70142 ± 0.0010326 (W 0.00274603) | · | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.15536 ± 0.034743 (W 0.0025126) | 2.15927 ± 0.0359249 (W 0.00239503) | 1.62324 ± 0.0590584 (W 0.00514607) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.141625 ± 0.000341821 (W 0.00116483) | 0.141815 ± 0.000100664 (W 0.00100332) | 0.059831 ± 0.000373579 (W 0.000152709) | · | 🔴 faer-fork 2.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538485 ± 0.00152619 (W 0.00142818) | 0.539026 ± 0.00115174 (W 0.00158151) | 0.255057 ± 0.000697927 (W 0.0015845) | · | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18938 ± 0.0020922 (W 0.00118514) | 1.18999 ± 0.00103569 (W 0.00127693) | 0.608866 ± 0.00122969 (W 0.00171255) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183883 ± 0.0003617 (W 0.0013196) | 0.184544 ± 0.000507327 (W 0.00125519) | 0.17661 ± 0.000781607 (W 0.00158318) | · | · |  |
| `svd_thin/n64/b1` | 0.956967 ± 0.00231572 (W 0.00257964) | 0.962397 ± 0.00530498 (W 0.00399911) | 0.644694 ± 0.00218761 (W 0.00259545) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09733 ± 0.00364763 (W 0.0013864) | 2.10174 ± 0.0031761 (W 0.00231875) | 1.38392 ± 0.00292601 (W 0.00318286) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.141233 ± 8.34286e-05 (W 0.00117914) | 0.141815 ± 0.000323729 (W 0.00199712) | 0.059391 ± 0.000196571 (W 9.8774e-05) | · | 🔴 faer-fork 2.38× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536312 ± 0.00237562 (W 0.00203784) | 0.538696 ± 0.00157541 (W 0.00217769) | 0.259465 ± 0.00149624 (W 0.00177928) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18287 ± 0.00123068 (W 0.00140324) | 1.1893 ± 0.000733405 (W 0.00210294) | 0.607034 ± 0.00180753 (W 0.00166164) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.184464 ± 0.000293184 (W 0.00111855) | 0.186598 ± 0.000856506 (W 0.00156697) | 0.179045 ± 0.000263439 (W 0.00125895) | · | · |  |
| `svd_thin/n64/b1` | 0.95405 ± 0.000503834 (W 0.000786034) | 0.962707 ± 0.0081804 (W 0.00215546) | 0.638251 ± 0.00505654 (W 0.00166351) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.097 ± 0.00436433 (W 0.00247299) | 2.11177 ± 0.00495837 (W 0.0026004) | 1.33434 ± 0.00182528 (W 0.00218899) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.141343 ± 0.00011358 (W 0.00111882) | 0.142937 ± 0.000859559 (W 0.00114626) | 0.059311 ± 0.000282236 (W 0.000136108) | · | 🔴 faer-fork 2.38× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538165 ± 0.000863841 (W 0.00205297) | 0.539888 ± 0.00193778 (W 0.00333693) | 0.258673 ± 0.00166385 (W 0.00139661) | · | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18471 ± 0.00172312 (W 0.00359008) | 1.19367 ± 0.00497411 (W 0.000907159) | 0.603537 ± 0.000396477 (W 0.00199192) | · | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234507 ± 0.000373101 (W 0.00132431) | 0.234267 ± 0.000773041 (W 0.00192644) | 0.252522 ± 0.000503343 (W 0.00115814) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22049 ± 0.0023983 (W 0.00153011) | 1.22266 ± 0.00351717 (W 0.00211754) | 1.34266 ± 0.0014146 (W 0.00270325) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.12698 ± 0.0102184 (W 0.00167041) | 3.1317 ± 0.00855035 (W 0.00430263) | 3.48278 ± 0.0061565 (W 0.00303705) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.16061 ± 0.000102031 (W 0.000153558) | 0.16079 ± 0.000107858 (W 0.00122299) | 0.102581 ± 0.121928 (W 0.00109807) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.651036 ± 0.00158909 (W 0.00209649) | 0.649512 ± 0.0002355 (W 0.00175603) | 0.493361 ± 0.00199696 (W 0.00187134) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51159 ± 0.00393497 (W 0.00439379) | 1.50826 ± 0.00260217 (W 0.00335583) | 1.37552 ± 0.0295244 (W 0.00197961) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233957 ± 0.000555771 (W 0.00186674) | 0.234748 ± 0.000539482 (W 0.00307924) | 0.261077 ± 0.000121244 (W 0.00215167) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.15032 ± 0.00198777 (W 0.0018394) | 1.14717 ± 0.00127355 (W 0.00168487) | 1.03077 ± 0.00255173 (W 0.00111327) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.79606 ± 0.00317527 (W 0.00430883) | 2.79915 ± 0.00531274 (W 0.00744723) | 2.52818 ± 0.00167742 (W 0.00426198) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.161071 ± 0.000324032 (W 0.00122689) | 0.160639 ± 0.000110636 (W 0.00139655) | 0.102521 ± 0.000317513 (W 0.000218523) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.651937 ± 0.00178158 (W 0.00194009) | 0.650024 ± 4.62637e-05 (W 0.00172609) | 0.490485 ± 0.000256145 (W 0.00118794) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50519 ± 0.00304279 (W 0.00234333) | 1.50671 ± 0.00360181 (W 0.00208661) | 1.35692 ± 0.00106217 (W 0.00155089) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233727 ± 6.02246e-05 (W 0.00135327) | 0.233716 ± 0.000241137 (W 0.0014863) | 0.263542 ± 0.000911966 (W 0.00163135) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.14635 ± 0.000699743 (W 0.00185991) | 1.1515 ± 0.000901729 (W 0.00199034) | 1.07265 ± 0.00278509 (W 0.0043369) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.75646 ± 0.00187144 (W 0.003891) | 2.82372 ± 0.00777727 (W 0.0035923) | 2.34225 ± 0.00213523 (W 0.00325603) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.16067 ± 0.000280935 (W 0.00138726) | 0.160559 ± 0.000180325 (W 0.00141389) | 0.102431 ± 0.000113006 (W 0.000157126) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.650755 ± 0.000862185 (W 0.00192012) | 0.649353 ± 0.000763039 (W 0.00176361) | 0.491107 ± 0.00252537 (W 0.00163542) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.5046 ± 0.00432267 (W 0.00239587) | 1.50588 ± 0.00171427 (W 0.00217931) | 1.39342 ± 0.00287937 (W 0.00641766) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231692 ± 0.000563171 (W 0.00104044) | 0.231502 ± 0.000157735 (W 0.0011657) | 0.249165 ± 0.000386887 (W 0.00156995) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25057 ± 0.00379218 (W 0.00109624) | 1.25225 ± 0.0053122 (W 0.00144367) | 1.30922 ± 0.00159097 (W 0.00306668) | · | · |  |
| `svd_thin/n96/b1` | 3.08415 ± 0.00696921 (W 0.0022756) | 3.0892 ± 0.00911776 (W 0.00161064) | 3.41288 ± 0.00641871 (W 0.0040393) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158616 ± 0.000219317 (W 0.00119513) | 0.158386 ± 0.000181934 (W 0.00105297) | 0.100637 ± 0.000342774 (W 0.000155808) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625318 ± 0.000633436 (W 0.00175693) | 0.625317 ± 0.00102386 (W 0.00166043) | 0.478895 ± 0.00208143 (W 0.00164097) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48248 ± 0.00423703 (W 0.00241632) | 1.48321 ± 0.00149293 (W 0.00314681) | 1.33856 ± 0.00256001 (W 0.00126629) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231963 ± 0.000564582 (W 0.00131006) | 0.231412 ± 0.000683873 (W 0.00152525) | 0.25714 ± 0.000606062 (W 0.00140547) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.17625 ± 0.00159354 (W 0.00246037) | 1.17805 ± 0.00110684 (W 0.00137973) | 1.0116 ± 0.00446368 (W 0.00140559) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.75701 ± 0.00241512 (W 0.00415384) | 2.75521 ± 0.00299868 (W 0.004974) | 2.50727 ± 0.000992674 (W 0.0029936) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158746 ± 0.000365541 (W 0.00170306) | 0.158616 ± 0.000432699 (W 0.00165314) | 0.100658 ± 0.000379285 (W 0.000135019) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.624736 ± 0.00116753 (W 0.00161419) | 0.626078 ± 0.000558815 (W 0.00216298) | 0.478583 ± 0.00201739 (W 0.00180146) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.47652 ± 0.00477911 (W 0.00227184) | 1.476 ± 0.00394934 (W 0.00482416) | 1.33883 ± 0.00281317 (W 0.0021491) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231502 ± 0.000214554 (W 0.00189388) | 0.231102 ± 0.000156387 (W 0.00186372) | 0.258964 ± 0.00042851 (W 0.00163361) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.17543 ± 4.51381 (W 0.00222431) | 1.18114 ± 0.00266918 (W 0.00146557) | 0.976143 ± 0.00185312 (W 0.00242198) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n96/b1` | 2.717 ± 0.00713055 (W 0.00982071) | 2.78755 ± 0.00340984 (W 0.0112905) | 2.3301 ± 0.00125476 (W 0.00349874) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158355 ± 0.000456598 (W 0.000217001) | 0.158496 ± 0.000325608 (W 0.00163393) | 0.100728 ± 0.000171553 (W 0.00151383) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625598 ± 0.00147406 (W 0.00200729) | 0.62657 ± 0.00128838 (W 0.00191851) | 0.478273 ± 0.00172415 (W 0.00202758) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.47965 ± 0.00315236 (W 0.00195657) | 1.47696 ± 0.00106419 (W 0.00210004) | 1.33471 ± 0.00176303 (W 0.00192593) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.138208 ± 0.00079144 (W 0.00166621) | 0.13877 ± 0.00188824 (W 0.00163202) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.540178 ± 0.00119884 (W 0.0024283) | 0.54169 ± 0.00161938 (W 0.00211999) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.57062 ± 0.0033965 (W 0.00240118) | 1.5755 ± 0.00555389 (W 0.00355678) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110777 ± 0.00108684 (W 0.00119391) | 0.111107 ± 0.00113813 (W 0.000203495) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.399796 ± 0.0014601 (W 0.00160567) | 0.404865 ± 0.00232762 (W 0.00164379) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.883839 ± 0.00454677 (W 0.000700358) | 0.887817 ± 0.00267656 (W 0.00119856) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137546 ± 0.000171349 (W 0.00160322) | 0.137847 ± 0.00100242 (W 0.00153755) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.534839 ± 0.00248013 (W 0.00183758) | 0.543846 ± 0.00161015 (W 0.00229581) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.5131 ± 0.00219579 (W 0.00202246) | 1.536 ± 0.00144819 (W 0.00469325) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110386 ± 0.000120139 (W 0.00194934) | 0.110907 ± 0.000477546 (W 0.00161831) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.397832 ± 0.000407206 (W 0.0017639) | 0.402711 ± 0.00106175 (W 0.00187791) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.894861 ± 0.00787845 (W 0.00247284) | 0.896985 ± 0.00789123 (W 0.00242599) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.136515 ± 0.000377361 (W 0.000193442) | 0.138118 ± 0.00086203 (W 0.000187941) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.530901 ± 0.00434175 (W 0.00230693) | 0.550667 ± 0.00262999 (W 0.0035557) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51591 ± 0.0048297 (W 0.00151218) | 1.56769 ± 0.00662864 (W 0.0049709) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110497 ± 0.000196588 (W 0.000240067) | 0.111107 ± 0.000110002 (W 0.00022025) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.398243 ± 0.00149584 (W 0.00235482) | 0.400919 ± 0.000956471 (W 0.00211774) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.882058 ± 0.000838134 (W 0.0011725) | 0.885523 ± 0.00256361 (W 0.00138814) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146734 ± 0.00124773 (W 0.00163583) | 0.148257 ± 0.00109785 (W 0.00165332) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.542454 ± 0.00143523 (W 0.00170097) | 0.545367 ± 0.00172316 (W 0.00191183) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56453 ± 0.00176344 (W 0.00332579) | 1.57266 ± 0.00531465 (W 0.0015638) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109665 ± 0.000930325 (W 0.00111276) | 0.110527 ± 0.000799624 (W 0.000139493) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.400017 ± 0.00181002 (W 0.00184663) | 0.403773 ± 0.00232449 (W 0.00175878) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.865296 ± 0.00330254 (W 0.00136445) | 0.870444 ± 0.0029111 (W 0.00116226) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146023 ± 0.000263231 (W 0.00141149) | 0.148618 ± 0.00124872 (W 0.00154166) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.534388 ± 0.000247557 (W 0.00170131) | 0.545298 ± 0.00108412 (W 0.00167362) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51169 ± 0.00194264 (W 0.00273897) | 1.52956 ± 0.00189974 (W 0.00474606) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109414 ± 0.000182483 (W 0.00133557) | 0.110076 ± 0.000749242 (W 0.000277555) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.398474 ± 0.00152611 (W 0.00162916) | 0.40211 ± 0.00208351 (W 0.00170279) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.877058 ± 0.00731675 (W 0.00340795) | 0.879052 ± 0.00789346 (W 0.00153315) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146123 ± 0.000132478 (W 0.00114036) | 0.146564 ± 0.00184696 (W 0.00129778) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.531142 ± 0.00142815 (W 0.0024445) | 0.55176 ± 0.00502419 (W 0.00234793) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51172 ± 0.00389762 (W 0.00253602) | 1.5613 ± 0.00686238 (W 0.00544544) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109284 ± 0.000115326 (W 0.000130339) | 0.110005 ± 0.000126295 (W 0.00101439) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.398654 ± 0.000391659 (W 0.00186195) | 0.400768 ± 0.000982656 (W 0.00164035) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.866097 ± 0.000480409 (W 0.00236985) | 0.86791 ± 0.000746463 (W 0.0010527) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170678 ± 0.00142508 (W 0.000979461) | 0.17147 ± 0.00125927 (W 0.0012168) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.687953 ± 0.0112922 (W 0.00206531) | 0.694175 ± 0.0112797 (W 0.00220406) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.0378 ± 0.0024647 (W 0.00205584) | 2.04726 ± 0.00435062 (W 0.00603274) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118611 ± 6.16468e-05 (W 0.000764085) | 0.118872 ± 0.000199249 (W 0.00155262) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.455991 ± 0.00244812 (W 0.00163831) | 0.458376 ± 0.00171294 (W 0.00165066) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04612 ± 0.00197737 (W 0.000823844) | 1.04671 ± 0.00429327 (W 0.00202975) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.17141 ± 0.00252299 (W 0.00124362) | 0.170479 ± 0.0023701 (W 0.00140436) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.651477 ± 0.00323291 (W 0.00155585) | 0.651377 ± 0.00275003 (W 0.00227027) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.83923 ± 0.00242845 (W 0.00248517) | 1.83703 ± 0.00385509 (W 0.00138285) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118391 ± 0.000311401 (W 0.000229491) | 0.118682 ± 0.00063056 (W 0.00124151) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.455231 ± 0.00193546 (W 0.00181936) | 0.459156 ± 0.00224742 (W 0.00158716) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04232 ± 0.00407008 (W 0.00112304) | 1.04545 ± 0.00514773 (W 0.000829264) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.17149 ± 0.00140868 (W 0.00115779) | 0.170749 ± 0.0022658 (W 0.00159125) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.642459 ± 0.000878681 (W 0.00209095) | 0.651536 ± 0.000303431 (W 0.00224417) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.81474 ± 0.0054926 (W 0.00342245) | 1.85113 ± 0.00179877 (W 0.00309055) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118591 ± 0.00028988 (W 0.000183673) | 0.118321 ± 0.000469671 (W 0.00134609) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.456432 ± 0.00220035 (W 0.00192784) | 0.456552 ± 0.00370688 (W 0.00188778) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04093 ± 0.00106442 (W 0.000879486) | 1.04342 ± 0.00232544 (W 0.000662747) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172663 ± 0.000578934 (W 0.00151844) | 0.173594 ± 0.000696242 (W 0.000324525) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.695458 ± 0.0117671 (W 0.00153753) | 0.698614 ± 0.0128688 (W 0.00391719) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05615 ± 0.00544672 (W 0.00198838) | 2.05829 ± 0.00454096 (W 0.00219003) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118591 ± 0.000173494 (W 9.84911e-05) | 0.118692 ± 0.000179723 (W 0.00115) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.448767 ± 0.00312515 (W 0.00164305) | 0.451713 ± 0.00203384 (W 0.00116283) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04363 ± 0.00236027 (W 0.00065279) | 1.04397 ± 0.00286798 (W 0.000585061) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173224 ± 0.0024747 (W 0.00111271) | 0.173714 ± 0.00224249 (W 0.00138076) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.661064 ± 0.00375169 (W 0.00198513) | 0.659581 ± 0.00313342 (W 0.00141692) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.85552 ± 0.000499529 (W 0.00163405) | 1.85289 ± 0.00736712 (W 0.00268174) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118191 ± 0.000140571 (W 0.00142693) | 0.11811 ± 0.00036561 (W 0.00192627) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.448708 ± 0.0025901 (W 0.00151519) | 0.451553 ± 0.000772283 (W 0.00175928) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04056 ± 0.0030695 (W 0.00103021) | 1.0429 ± 0.00508563 (W 0.000923386) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173704 ± 0.000893372 (W 0.00137722) | 0.172722 ± 0.00195559 (W 0.00163582) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.652298 ± 0.00152966 (W 0.00199639) | 0.659882 ± 0.0011394 (W 0.0017675) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.83108 ± 0.00274044 (W 0.00318362) | 1.86706 ± 0.00515116 (W 0.00339196) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118111 ± 0.000325781 (W 0.00156073) | 0.118581 ± 0.000521377 (W 0.000192016) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.449809 ± 0.00357241 (W 0.00174628) | 0.451914 ± 0.0053997 (W 0.00166021) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.03837 ± 0.00152327 (W 0.000846679) | 1.04221 ± 0.000602795 (W 0.00217758) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.68531 ± 0.012809 (W 0.00696221) | 3.68654 ± 0.0157651 (W 0.00399994) | 3.40591 ± 0.0114907 (W 0.0169419) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4451 ± 0.0775897 (W 0.010439) | 18.4359 ± 0.0628412 (W 0.0264529) | 18.0341 ± 0.0265169 (W 0.383638) | · | · |  |
| `svd_thin/n512/b1` | 105.651 ± 0.329724 (W 0.393685) | 105.978 ± 0.175931 (W 0.0725995) | 116.525 ± 0.643381 (W 0.347637) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.68723 ± 0.00969832 (W 0.00396615) | 2.6917 ± 0.0143717 (W 0.00344648) | 1.1923 ± 0.0283969 (W 0.00319721) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4277 ± 0.0112397 (W 0.0275437) | 12.4419 ± 0.0181853 (W 0.00815185) | 6.95925 ± 0.14715 (W 0.00500338) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.0931 ± 0.252128 (W 0.0489695) | 66.2269 ± 0.217579 (W 0.0407245) | 48.0713 ± 1.1194 (W 0.0441745) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.77621 ± 0.0143556 (W 0.0179717) | 2.80954 ± 0.0120991 (W 0.0152001) | 2.6351 ± 0.0100934 (W 0.00523686) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.1834 ± 0.0248117 (W 0.0128942) | 13.214 ± 0.0233695 (W 0.0124237) | 12.4712 ± 0.0107908 (W 0.020876) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 55.7458 ± 0.117005 (W 0.41753) | 55.6755 ± 0.0474083 (W 0.0467511) | 57.5837 ± 0.0663116 (W 0.0754919) | · | · |  |
| `svd_values/n128/b1` | 2.1792 ± 0.00446937 (W 0.0044055) | 2.18636 ± 0.00311248 (W 0.00391167) | 1.13407 ± 0.00999873 (W 0.00321066) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.4431 ± 0.0154893 (W 0.011436) | 10.4724 ± 0.00778801 (W 0.0158313) | 6.11355 ± 0.169906 (W 0.0136688) | · | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 41.7915 ± 0.0995836 (W 0.324204) | 41.9229 ± 0.13494 (W 0.052562) | 25.8022 ± 0.64349 (W 0.0324701) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.75914 ± 0.00284802 (W 0.00298343) | 2.81262 ± 0.00736615 (W 0.00332543) | 2.50489 ± 0.00724596 (W 0.00641346) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.8697 ± 0.0423917 (W 0.0672699) | 13.27 ± 0.0363302 (W 0.0221262) | 11.4948 ± 0.00131522 (W 0.0173134) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 50.6611 ± 0.157992 (W 0.0729864) | 52.6371 ± 0.0498355 (W 0.0769873) | 48.2747 ± 0.388881 (W 0.0769018) | · | · |  |
| `svd_values/n128/b1` | 2.17928 ± 0.00230893 (W 0.00290396) | 2.18484 ± 0.00270606 (W 0.00234054) | 1.11505 ± 0.0110147 (W 0.00266382) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.5232 ± 0.0104647 (W 0.0238347) | 10.5196 ± 0.00878937 (W 0.0124326) | 5.96343 ± 0.165535 (W 0.00571217) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.126 ± 0.0792161 (W 0.278095) | 40.1261 ± 0.092398 (W 0.0588483) | 22.3386 ± 0.792037 (W 0.0210286) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.67412 ± 0.0192955 (W 0.00387952) | 3.68618 ± 0.017562 (W 0.00408584) | 3.31613 ± 0.0103303 (W 0.00907536) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3028 ± 0.0448474 (W 0.0180505) | 18.3282 ± 0.0761561 (W 0.0126819) | 17.6834 ± 0.029763 (W 0.0220911) | · | · |  |
| `svd_thin/n512/b1` | 104.723 ± 0.00570318 (W 0.0384465) | 104.856 ± 0.0282963 (W 0.0716329) | 116.088 ± 0.292213 (W 0.101297) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.61031 ± 0.0026916 (W 0.0026256) | 2.61525 ± 0.00479924 (W 0.0035253) | 1.1596 ± 0.00339551 (W 0.00206594) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2433 ± 0.0102042 (W 0.0120578) | 12.2951 ± 0.0187864 (W 0.0123705) | 6.83755 ± 0.026652 (W 0.00949894) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.1495 ± 0.217809 (W 0.0467434) | 65.228 ± 0.26329 (W 0.0378523) | 47.4798 ± 0.474584 (W 0.0291099) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.76128 ± 0.00505308 (W 0.0147185) | 2.76602 ± 0.0135637 (W 0.0139493) | 2.6226 ± 0.0100142 (W 0.00685132) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.0596 ± 0.0160591 (W 0.0198286) | 13.1126 ± 0.00521477 (W 0.0166359) | 12.4241 ± 0.0649226 (W 0.0195421) | · | · |  |
| `svd_thin/n512/b1` | 54.6908 ± 0.135715 (W 0.0363334) | 54.8959 ± 0.0262457 (W 0.0755244) | 58.5007 ± 0.967938 (W 0.0314591) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.11372 ± 0.002689 (W 0.00258211) | 2.11771 ± 0.0053627 (W 0.00249877) | 1.13803 ± 0.00393629 (W 0.00180123) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.2673 ± 0.0150295 (W 0.0142834) | 10.312 ± 0.0104912 (W 0.00925791) | 6.13581 ± 0.0322325 (W 0.0100685) | · | 🔴 faer-fork 1.67× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.8848 ± 0.0357302 (W 0.0277319) | 40.991 ± 0.0793744 (W 0.04014) | 25.799 ± 0.258767 (W 0.018618) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.73622 ± 0.00733086 (W 0.00564658) | 2.78577 ± 0.019281 (W 0.00554596) | 2.48794 ± 0.0089171 (W 0.00265309) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.7177 ± 0.0567012 (W 0.011538) | 13.1713 ± 0.0175168 (W 0.0241227) | 11.4997 ± 0.0515292 (W 0.0150797) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 49.7703 ± 0.0474409 (W 0.136105) | 51.7361 ± 0.114192 (W 0.0698008) | 49.2633 ± 0.997136 (W 0.0591731) | · | · |  |
| `svd_values/n128/b1` | 2.11326 ± 0.00137391 (W 0.0024752) | 2.12062 ± 0.00259667 (W 0.00454339) | 1.12692 ± 0.011737 (W 0.00313452) | · | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.3454 ± 0.00894484 (W 0.0139716) | 10.3654 ± 0.0192132 (W 0.0144853) | 6.01372 ± 0.0328122 (W 0.0071506) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 39.11 ± 0.09153 (W 0.0618742) | 39.2714 ± 0.0824594 (W 0.0401134) | 22.3782 ± 0.117515 (W 0.0178836) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.73255 ± 0.00510104 (W 0.00976289) | 5.73037 ± 0.00474813 (W 0.0224067) | 7.04436 ± 0.0111003 (W 0.00502211) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.2139 ± 0.120785 (W 0.283434) | 34.2533 ± 0.0804307 (W 0.0922316) | 43.3832 ± 0.213223 (W 0.0382506) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 211.74 ± 0.164821 (W 0.482235) | 211.509 ± 0.170048 (W 0.297578) | 277.012 ± 2.54785 (W 0.658848) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.47029 ± 0.00737055 (W 0.00632785) | 3.46937 ± 0.00921865 (W 0.00874825) | 2.75879 ± 0.00822948 (W 0.00412138) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.4044 ± 0.058308 (W 0.0768517) | 19.428 ± 0.102358 (W 0.0911587) | 18.1565 ± 0.0793949 (W 0.0217413) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 111.633 ± 0.291614 (W 0.482843) | 111.228 ± 0.315168 (W 0.204375) | 123.193 ± 0.709776 (W 0.431615) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.0734 ± 0.00593742 (W 0.0172724) | 4.06414 ± 0.00964348 (W 0.0142339) | 4.15325 ± 0.00859231 (W 0.00581212) | · | · |  |
| `svd_thin/n256/b1` | 21.7304 ± 0.121919 (W 0.0690375) | 21.7867 ± 0.224168 (W 0.0906459) | 21.1891 ± 0.0762206 (W 0.044386) | · | · |  |
| `svd_thin/n512/b1` | 87.9287 ± 0.729187 (W 0.401097) | 87.8606 ± 0.234207 (W 0.622289) | 115.941 ± 2.18642 (W 0.386827) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.98368 ± 0.00434853 (W 0.00381172) | 2.98154 ± 0.00482117 (W 0.00445937) | 2.02117 ± 0.00708289 (W 0.0029621) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.2672 ± 0.187602 (W 0.0530468) | 16.4906 ± 0.122692 (W 0.0855011) | 11.1121 ± 0.0354195 (W 0.022993) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 57.8503 ± 0.284777 (W 0.104262) | 58.0117 ± 0.280345 (W 0.10085) | 56.3513 ± 0.0970941 (W 0.105157) | · | · |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.90187 ± 0.0103834 (W 0.00630749) | 4.07652 ± 0.00798988 (W 0.0208464) | 3.64481 ± 0.011474 (W 0.0047024) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.4596 ± 0.307643 (W 0.0821344) | 21.2914 ± 0.271173 (W 0.0633676) | 17.2897 ± 0.0721171 (W 0.0233761) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 70.479 ± 0.142851 (W 0.411139) | 74.8866 ± 0.145228 (W 0.247153) | 84.9103 ± 5.74474 (W 0.0988692) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.98206 ± 0.00509456 (W 0.00558978) | 2.98262 ± 0.00633261 (W 0.00473654) | 1.90769 ± 0.00842784 (W 0.00411366) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.5468 ± 0.114091 (W 0.0560766) | 16.4158 ± 0.185813 (W 0.0229068) | 9.64976 ± 0.0371828 (W 0.022871) | · | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 51.5302 ± 0.272631 (W 0.111538) | 51.6202 ± 0.314741 (W 0.156679) | 43.2869 ± 0.0651296 (W 0.103526) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.68921 ± 0.0135679 (W 0.00925556) | 5.70844 ± 0.00489432 (W 0.0127532) | 6.9596 ± 0.0260226 (W 0.0117207) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.8827 ± 0.0970927 (W 0.0418183) | 33.9242 ± 0.0589559 (W 0.0673647) | 42.7726 ± 1.31627 (W 0.0763916) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 210.715 ± 0.458381 (W 0.409409) | 210.65 ± 0.203977 (W 0.309396) | 273.447 ± 21.9758 (W 0.711826) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 3.45191 ± 0.00379832 (W 0.0101526) | 3.45631 ± 0.00292149 (W 0.00474505) | 2.70797 ± 0.0100056 (W 0.00173528) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.0985 ± 0.0799195 (W 0.121066) | 19.0797 ± 0.0598508 (W 0.0731447) | 17.9403 ± 1.21489 (W 0.0190429) | · | · | `!` between-start range over 5% |
| `svd_values/n512/b1` | 110.367 ± 0.437352 (W 0.137939) | 110.355 ± 0.302747 (W 0.4688) | 121.122 ± 19.3985 (W 0.22199) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.05572 ± 0.00641603 (W 0.0137875) | 4.05218 ± 0.00424592 (W 0.0152714) | 4.11249 ± 0.0034788 (W 0.00446072) | · | · |  |
| `svd_thin/n256/b1` | 21.4237 ± 0.1856 (W 0.0699803) | 21.5978 ± 0.0923881 (W 0.0611495) | 22.2053 ± 0.672148 (W 0.0212666) | · | · | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 86.5957 ± 0.25258 (W 0.124591) | 86.7035 ± 0.418648 (W 0.134418) | 124.42 ± 1.14568 (W 0.147845) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.95137 ± 0.00741973 (W 0.00397373) | 2.95055 ± 0.00184085 (W 0.00606643) | 2.01235 ± 0.00192855 (W 0.00240493) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.1133 ± 0.212697 (W 0.040028) | 16.2333 ± 0.239223 (W 0.100776) | 12.0362 ± 0.530905 (W 0.0432463) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 56.8459 ± 0.120562 (W 0.173833) | 56.9636 ± 0.0973799 (W 0.110546) | 64.8678 ± 5.23636 (W 0.0744241) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.87935 ± 0.00323947 (W 0.00647616) | 4.06865 ± 0.0155785 (W 0.0279805) | 3.63381 ± 0.0108702 (W 0.00632228) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.2049 ± 0.16469 (W 0.0672134) | 20.9875 ± 0.0510716 (W 0.15372) | 17.7162 ± 0.121974 (W 0.0340371) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 69.6134 ± 0.263991 (W 0.125885) | 73.94 ± 0.195564 (W 0.215082) | 85.8575 ± 1.34424 (W 0.101698) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.94354 ± 0.00216377 (W 0.00511245) | 2.94912 ± 0.0105203 (W 0.00459252) | 1.90508 ± 0.00458422 (W 0.00446126) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.2888 ± 0.121582 (W 0.0867788) | 16.1108 ± 0.0347371 (W 0.0415524) | 10.0677 ± 0.0693913 (W 0.0142933) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 50.6269 ± 0.310837 (W 0.143478) | 50.6461 ± 0.354503 (W 0.0949868) | 46.0342 ± 0.435969 (W 0.0485899) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.33068 ± 0.006286 (W 0.00313361) | 2.31813 ± 0.00184313 (W 0.00409114) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2181 ± 0.0163418 (W 0.0144584) | 11.1133 ± 0.0164684 (W 0.00817621) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 61.4825 ± 0.16467 (W 0.0908273) | 61.124 ± 0.187982 (W 0.0359439) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.717 ± 0.00347391 (W 0.00217094) | 1.7067 ± 0.00179151 (W 0.00272688) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.91767 ± 0.0152725 (W 0.0113538) | 7.82669 ± 0.0132726 (W 0.0074651) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 40.1642 ± 0.133007 (W 0.0502762) | 39.9179 ± 0.0938824 (W 0.0351002) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.80962 ± 0.0146922 (W 0.00680686) | 1.81138 ± 0.00492003 (W 0.00694275) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.39672 ± 0.0475659 (W 0.0574994) | 8.38774 ± 0.0413771 (W 0.0596741) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 35.7941 ± 0.0576665 (W 0.0430464) | 35.4583 ± 0.0917981 (W 0.0443832) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.44638 ± 0.00162835 (W 0.00325901) | 1.43561 ± 0.00366783 (W 0.00172891) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.69926 ± 0.0404276 (W 0.00344335) | 6.648 ± 0.0396462 (W 0.00875978) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 28.2338 ± 0.293181 (W 0.118581) | 27.993 ± 0.286121 (W 0.0349479) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.79522 ± 0.00510277 (W 0.00536635) | 1.97352 ± 0.0127857 (W 0.00664362) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.28553 ± 0.0658958 (W 0.0210701) | 8.63266 ± 0.0597433 (W 0.0299253) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 33.3161 ± 0.135296 (W 0.0401856) | 34.3999 ± 0.232965 (W 0.0585733) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.44294 ± 0.00306258 (W 0.00199497) | 1.43477 ± 0.00198598 (W 0.00296574) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.74835 ± 0.0128072 (W 0.007144) | 6.68877 ± 0.01501 (W 0.0140631) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 27.1612 ± 0.0151447 (W 0.027561) | 26.9112 ± 0.045283 (W 0.0292341) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.34956 ± 0.00706888 (W 0.00309777) | 2.33021 ± 0.00660072 (W 0.00280697) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2305 ± 0.0269681 (W 0.0105872) | 11.1435 ± 0.0119142 (W 0.0157878) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 60.8916 ± 0.175137 (W 0.0294209) | 60.5751 ± 0.122119 (W 0.0644762) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.67629 ± 0.00182705 (W 0.0020791) | 1.67056 ± 0.00331839 (W 0.00437308) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.76744 ± 0.0136789 (W 0.0067196) | 7.67376 ± 0.0189142 (W 0.00592771) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 39.6144 ± 0.134332 (W 0.0357944) | 39.3223 ± 0.122634 (W 0.0193005) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.81201 ± 0.0107337 (W 0.00355035) | 1.82446 ± 0.00951948 (W 0.00487161) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.44084 ± 0.0241594 (W 0.0595549) | 8.3095 ± 0.0601924 (W 0.0653853) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 35.0942 ± 0.0800185 (W 0.0411274) | 34.8172 ± 0.0636163 (W 0.0368512) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.41539 ± 0.00348407 (W 0.00210684) | 1.40461 ± 0.000902464 (W 0.00341482) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.49941 ± 0.0459013 (W 0.0101172) | 6.46479 ± 0.0283415 (W 0.00977754) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 27.4224 ± 0.144109 (W 0.0419352) | 27.2256 ± 0.173712 (W 0.0185731) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.80266 ± 0.0105581 (W 0.0036894) | 1.9747 ± 0.0135027 (W 0.0102777) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.18414 ± 0.0842523 (W 0.0260326) | 8.64357 ± 0.0630867 (W 0.0201455) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 32.8273 ± 0.145703 (W 0.0367607) | 33.9827 ± 0.13517 (W 0.0270916) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.41448 ± 0.00147087 (W 0.00426682) | 1.40329 ± 0.00322858 (W 0.0026949) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.58186 ± 0.0105686 (W 0.00923025) | 6.52724 ± 0.00659919 (W 0.0117169) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 26.616 ± 0.0655206 (W 0.0206412) | 26.3457 ± 0.0465696 (W 0.0360908) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.35683 ± 0.00362003 (W 0.00256878) | 3.34823 ± 0.00331177 (W 0.00203137) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.437 ± 0.0542122 (W 0.0248239) | 19.384 ± 0.0145972 (W 0.0203765) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 121.562 ± 0.280129 (W 0.0664803) | 121.375 ± 0.244551 (W 0.157265) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 2.1414 ± 0.00688623 (W 0.00113068) | 2.13427 ± 0.00772934 (W 0.0036481) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 11.5035 ± 0.0373106 (W 0.0418666) | 11.4693 ± 0.0281117 (W 0.0163882) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 68.743 ± 0.14447 (W 0.133077) | 68.4506 ± 0.213006 (W 0.0653847) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.49783 ± 0.0310887 (W 0.0234692) | 2.48632 ± 0.0080601 (W 0.0296891) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.0527 ± 0.103306 (W 0.0496194) | 13.051 ± 0.145516 (W 0.0745626) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 59.7095 ± 2.32181 (W 0.0616347) | 58.5801 ± 1.29022 (W 0.0748337) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.85828 ± 0.00732418 (W 0.00162382) | 1.8522 ± 0.00133332 (W 0.00344633) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.92732 ± 0.00864776 (W 0.020036) | 9.924 ± 0.0403042 (W 0.0157003) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 42.6391 ± 1.11429 (W 0.0541008) | 42.6124 ± 1.06236 (W 0.0617147) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.41829 ± 0.00694643 (W 0.00555416) | 2.50086 ± 0.0045381 (W 0.00457215) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.5194 ± 0.111583 (W 0.0214489) | 13.0223 ± 0.0299977 (W 0.0525922) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 49.7565 ± 0.111811 (W 0.0512323) | 52.218 ± 0.251266 (W 0.139438) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.85872 ± 0.000516765 (W 0.00591738) | 1.85509 ± 0.000866326 (W 0.0024135) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.97089 ± 0.0293438 (W 0.0251324) | 9.96561 ± 0.0217239 (W 0.0156989) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 38.8822 ± 0.00580691 (W 0.0725964) | 38.6746 ± 0.0167677 (W 0.0480867) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.35169 ± 0.00307661 (W 0.00240096) | 3.34461 ± 0.00427392 (W 0.00299973) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.3026 ± 0.124323 (W 0.030819) | 19.2516 ± 0.0161494 (W 0.0127833) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 120.941 ± 0.393335 (W 0.280246) | 120.607 ± 0.230281 (W 0.37151) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 2.11394 ± 0.00603359 (W 0.00376009) | 2.10453 ± 0.00627672 (W 0.00989641) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 11.298 ± 0.0376118 (W 0.0451693) | 11.2665 ± 0.028999 (W 0.0145033) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 67.4094 ± 0.296308 (W 0.0678359) | 67.258 ± 0.102936 (W 0.191681) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.48366 ± 0.00786104 (W 0.0217539) | 2.46079 ± 0.0039892 (W 0.00902478) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.0622 ± 0.0788874 (W 0.0712224) | 12.9072 ± 0.0921157 (W 0.0648631) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 57.5544 ± 0.570661 (W 0.0683224) | 56.6681 ± 0.86047 (W 0.0531456) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.84705 ± 0.00492998 (W 0.0023015) | 1.83677 ± 0.00166373 (W 0.00276789) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.8281 ± 0.0256607 (W 0.025799) | 9.80286 ± 0.0281043 (W 0.012574) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 40.2934 ± 0.91665 (W 0.040768) | 40.1418 ± 0.961507 (W 0.0584611) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.39384 ± 0.00856154 (W 0.00607889) | 2.48732 ± 0.00847381 (W 0.00486047) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.2819 ± 0.0834974 (W 0.0783457) | 12.8692 ± 0.0733059 (W 0.0428149) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 48.9318 ± 0.229336 (W 0.0761343) | 51.4373 ± 0.233521 (W 0.31984) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.84305 ± 0.000455362 (W 0.00250984) | 1.8376 ± 0.00222089 (W 0.00270914) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.86751 ± 0.0275252 (W 0.0304712) | 9.84555 ± 0.0263887 (W 0.00846525) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 37.9168 ± 0.047203 (W 0.087698) | 37.7647 ± 0.0178931 (W 0.0399927) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.49779 ± 0.00283291 (W 0.00488326) | 2.50796 ± 0.00329813 (W 0.00285808) | 3.04543 ± 0.00194946 (W 0.00513725) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 87.9896 ± 0.279484 (W 0.0651066) | 88.0001 ± 0.256117 (W 0.169493) | 120.415 ± 0.467794 (W 0.302033) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48674 ± 0.00586524 (W 0.00429509) | 1.49244 ± 0.00369886 (W 0.00606284) | 1.38699 ± 0.157202 (W 0.00420782) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 44.6646 ± 0.100608 (W 0.0301589) | 44.8103 ± 0.0581716 (W 0.359221) | 46.4327 ± 3.75135 (W 0.0886219) | · | · | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.27753 ± 0.00528599 (W 0.00801249) | 2.15067 ± 0.00449757 (W 0.00479082) | 1.8827 ± 0.00809257 (W 0.00637008) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 66.9764 ± 0.0832713 (W 0.381832) | 47.4274 ± 1.64141 (W 0.988944) | 48.721 ± 0.223262 (W 0.053702) | 🔴 faer-fork 1.41× slower than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.42919 ± 0.00482704 (W 0.00257023) | 1.53775 ± 0.00552345 (W 0.0044245) | 0.944544 ± 0.143038 (W 0.00997112) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 38.3637 ± 0.00586873 (W 0.0246053) | 32.6807 ± 0.0607452 (W 0.0762297) | 22.6246 ± 2.94822 (W 0.0881497) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.35877 ± 0.00267479 (W 0.00694479) | 2.2565 ± 0.0107469 (W 0.00642884) | 1.66967 ± 0.00152629 (W 0.00490216) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 66.583 ± 1.35826 (W 2.20349) | 46.5082 ± 0.0786483 (W 2.66081) | 36.481 ± 0.103556 (W 0.0499325) | 🔴 faer-fork 1.43× slower than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.47912 ± 0.00304647 (W 0.00602245) | 1.62479 ± 0.0128996 (W 0.00489614) | 0.810944 ± 0.198704 (W 0.00339292) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.82× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 37.9176 ± 0.097567 (W 0.0879847) | 33.6532 ± 0.0145317 (W 0.105961) | 16.8996 ± 2.61576 (W 0.0598966) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔴 faer-fork 2.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.44516 ± 0.00324614 (W 0.00327442) | 2.45447 ± 0.00225211 (W 0.00286168) | 2.80702 ± 0.00993203 (W 0.0110397) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.7814 ± 0.280053 (W 0.124898) | 83.0714 ± 0.260191 (W 0.103162) | 109.998 ± 0.58651 (W 0.171485) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39673 ± 0.00413124 (W 0.00464105) | 1.3983 ± 0.00216757 (W 0.00204593) | 1.23957 ± 0.00208041 (W 0.00262502) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 38.9756 ± 0.0693112 (W 0.0494568) | 39.0949 ± 0.0652671 (W 0.0224502) | 40.381 ± 0.333462 (W 0.0693186) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.23483 ± 0.00440395 (W 0.00289828) | 2.10522 ± 0.00170416 (W 0.00491284) | 1.81687 ± 0.00870678 (W 0.0104684) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 61.6432 ± 1.35992 (W 0.065614) | 42.0239 ± 0.172331 (W 0.0475789) | 45.7399 ± 0.254485 (W 0.102931) | 🔴 faer-fork 1.47× slower than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.35023 ± 0.0016973 (W 0.00340548) | 1.44691 ± 0.011268 (W 0.00358163) | 0.903587 ± 0.0040043 (W 0.00748778) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 32.5444 ± 0.0175443 (W 0.0278583) | 27.0312 ± 0.0635159 (W 0.0224556) | 20.7957 ± 0.236872 (W 0.0772082) | 🔴 faer-fork 1.20× slower than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.31464 ± 0.00195072 (W 0.00321814) | 2.19916 ± 0.0115593 (W 0.00611626) | 1.6361 ± 0.00469373 (W 0.00394683) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 59.312 ± 1.36263 (W 0.484279) | 42.9896 ± 1.26772 (W 2.38673) | 34.4792 ± 0.218941 (W 0.0740119) | 🔴 faer-fork 1.38× slower than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.39543 ± 0.00627327 (W 0.00389448) | 1.54168 ± 0.00108696 (W 0.00507979) | 0.785426 ± 0.00622932 (W 0.00348458) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 32.2901 ± 0.0450965 (W 0.0595122) | 28.0065 ± 0.109601 (W 0.0618154) | 15.7417 ± 0.116677 (W 0.0408028) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔴 faer-fork 2.05× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 6.02357 ± 0.0253004 (W 0.00411943) | 6.00625 ± 0.0196349 (W 0.00297018) | 8.75687 ± 0.0276251 (W 0.0288242) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 281.223 ± 0.146283 (W 2.56058) | 280.896 ± 0.152614 (W 0.171489) | 379.716 ± 0.454981 (W 0.528018) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.10285 ± 0.0185967 (W 0.00281409) | 3.08235 ± 0.0158687 (W 0.00230427) | 3.82754 ± 0.0267525 (W 0.00290659) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 123.152 ± 1.50335 (W 0.613462) | 122.599 ± 0.15006 (W 0.183885) | 144.737 ± 6.84014 (W 0.472089) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.94661 ± 0.00857697 (W 0.00583799) | 3.68116 ± 0.00893763 (W 0.00601609) | 5.48831 ± 0.0112344 (W 0.01208) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 195.723 ± 0.251428 (W 2.50181) | 118.289 ± 0.121867 (W 0.301107) | 138.497 ± 3.39059 (W 0.334196) | 🔴 faer-fork 1.65× slower than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.88793 ± 0.000475016 (W 0.00454107) | 2.448 ± 0.00181308 (W 0.00541364) | 2.81348 ± 0.00833107 (W 0.0041329) | 🔴 faer-fork 1.18× slower than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 97.3896 ± 0.179497 (W 0.198915) | 72.0677 ± 0.0879638 (W 0.0550291) | 51.4693 ± 5.89281 (W 0.253925) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 1.89× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.95544 ± 0.00762133 (W 0.0191671) | 3.70718 ± 0.0084038 (W 0.0258746) | 4.4249 ± 0.0142161 (W 0.00857806) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 186.963 ± 2.81093 (W 4.52994) | 107.501 ± 0.454851 (W 0.654939) | 83.119 ± 0.402587 (W 0.189316) | 🔴 faer-fork 1.74× slower than `faer-upstream` | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.91596 ± 0.00459663 (W 0.0103089) | 2.49974 ± 0.159759 (W 0.0126187) | 2.30798 ± 0.00889311 (W 0.00308125) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 94.404 ± 0.286225 (W 0.617358) | 69.5238 ± 0.474577 (W 0.488404) | 34.1258 ± 0.0835157 (W 0.0984781) | 🔴 faer-fork 1.36× slower than `faer-upstream` | 🔴 faer-fork 2.77× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.91085 ± 0.0180071 (W 0.00429837) | 5.90318 ± 0.0152155 (W 0.00457498) | 8.52801 ± 0.0348628 (W 0.011486) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 269.224 ± 0.119312 (W 0.432303) | 268.932 ± 0.287187 (W 0.459588) | 371.488 ± 2.83385 (W 1.68981) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.9798 ± 0.0189844 (W 0.0024889) | 2.96458 ± 0.0201346 (W 0.00268088) | 3.68689 ± 0.0183812 (W 0.00413013) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 110.772 ± 0.147145 (W 0.104571) | 110.408 ± 0.169749 (W 0.423566) | 142.267 ± 3.0425 (W 0.579975) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.84137 ± 0.00364316 (W 0.00700691) | 3.57363 ± 0.0112392 (W 0.00610391) | 5.41737 ± 0.0191321 (W 0.00528948) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 183.551 ± 0.442452 (W 0.136391) | 106.228 ± 0.214804 (W 0.309287) | 139.254 ± 6.18399 (W 0.517696) | 🔴 faer-fork 1.73× slower than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.7907 ± 0.00413627 (W 0.00482451) | 2.35632 ± 0.00421283 (W 0.0027059) | 2.78259 ± 0.0161173 (W 0.0104147) | 🔴 faer-fork 1.18× slower than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 85.2943 ± 0.096511 (W 0.0832775) | 59.9708 ± 0.107073 (W 0.0929017) | 50.1146 ± 0.131127 (W 0.17001) | 🔴 faer-fork 1.42× slower than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.83455 ± 0.0209412 (W 0.0292521) | 3.58532 ± 0.0241818 (W 0.0338816) | 4.37502 ± 0.0342933 (W 0.00598749) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 170.231 ± 0.219566 (W 2.03184) | 94.3153 ± 0.975191 (W 1.16674) | 74.7689 ± 2.24716 (W 0.14558) | 🔴 faer-fork 1.80× slower than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.83584 ± 0.00391515 (W 0.0123189) | 2.40129 ± 0.00370914 (W 0.00995036) | 2.30034 ± 0.0136244 (W 0.0049922) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 81.9439 ± 0.164292 (W 0.138176) | 57.7929 ± 0.118529 (W 0.524261) | 32.797 ± 0.238767 (W 0.137792) | 🔴 faer-fork 1.42× slower than `faer-upstream` | 🔴 faer-fork 2.50× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.59167 ± 0.00212898 (W 0.00470022) | 1.59067 ± 0.00439744 (W 0.00131667) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 50.1199 ± 0.920009 (W 0.0342703) | 50.0596 ± 0.96361 (W 0.0586282) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.12699 ± 0.00400699 (W 0.00276877) | 1.13609 ± 0.00212155 (W 0.00790165) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 28.3932 ± 0.891982 (W 0.0286393) | 28.2675 ± 0.923747 (W 0.0161968) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.50257 ± 0.00453964 (W 0.00163129) | 1.5233 ± 0.00805992 (W 0.00357263) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 38.1565 ± 0.0997762 (W 0.0876528) | 28.6313 ± 0.409636 (W 0.0512166) | - | 🔴 faer-fork 1.33× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.11309 ± 0.00420836 (W 0.00318505) | 1.25521 ± 0.00153305 (W 0.00467527) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.1649 ± 0.350286 (W 0.37337) | 21.7354 ± 0.307406 (W 0.027612) | - | 🔴 faer-fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.56902 ± 0.0222462 (W 0.00361544) | 1.62199 ± 0.00862139 (W 0.00605435) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 37.8833 ± 0.137579 (W 0.133301) | 29.4681 ± 0.637592 (W 0.16297) | - | 🔴 faer-fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.16216 ± 0.00309792 (W 0.00433343) | 1.33286 ± 0.005115 (W 0.0068564) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.4376 ± 0.015012 (W 0.0559986) | 22.8206 ± 0.0542363 (W 0.0630209) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.58532 ± 0.000951516 (W 0.00170836) | 1.59034 ± 0.00257703 (W 0.00219419) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.3997 ± 0.201685 (W 0.0391207) | 46.3036 ± 0.0992446 (W 0.052575) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.08626 ± 0.00154758 (W 0.00545759) | 1.08898 ± 0.00114151 (W 0.000510945) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.2464 ± 0.0842364 (W 0.014974) | 24.1577 ± 0.113249 (W 0.0383516) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.52046 ± 0.0065782 (W 0.00268292) | 1.52529 ± 0.00873449 (W 0.00445087) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 35.2974 ± 0.0942166 (W 0.0606888) | 25.7479 ± 0.106518 (W 0.0675083) | - | 🔴 faer-fork 1.37× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.06128 ± 0.00333089 (W 0.00176142) | 1.20669 ± 0.00573349 (W 0.00376299) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 20.6665 ± 0.0586788 (W 0.0343901) | 18.2035 ± 0.0162276 (W 0.0163605) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.56474 ± 0.00413983 (W 0.00329701) | 1.6197 ± 0.0070901 (W 0.00369261) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 35.1639 ± 0.146344 (W 0.0751204) | 26.4871 ± 0.133218 (W 0.103033) | - | 🔴 faer-fork 1.33× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.10427 ± 0.00291298 (W 0.0017027) | 1.30022 ± 0.00782975 (W 0.00198534) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 20.9767 ± 0.013722 (W 0.074475) | 19.2918 ± 0.0732499 (W 0.0634145) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.38865 ± 0.0053445 (W 0.00487182) | 3.39952 ± 0.00471504 (W 0.00368082) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 146.098 ± 0.182456 (W 0.156629) | 146.928 ± 0.241169 (W 0.442011) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 2.00229 ± 0.00702704 (W 0.00515012) | 2.02519 ± 0.00543478 (W 0.0042271) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 67.089 ± 0.0268427 (W 0.0596277) | 67.59 ± 0.0348693 (W 0.06786) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.76898 ± 0.0143885 (W 0.00489432) | 2.33571 ± 0.00673891 (W 0.00723081) | - | 🔴 faer-fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 103.541 ± 0.209498 (W 0.0876574) | 66.1741 ± 0.12043 (W 0.0845622) | - | 🔴 faer-fork 1.56× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.81355 ± 0.0118874 (W 0.00498828) | 1.80354 ± 0.00713307 (W 0.00595015) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 54.1207 ± 0.166405 (W 0.0563268) | 42.3407 ± 0.402177 (W 0.0294244) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.8245 ± 0.00212176 (W 0.00883656) | 2.43137 ± 0.0243113 (W 0.0109761) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 97.823 ± 0.0673879 (W 0.125072) | 61.4568 ± 0.44044 (W 0.667261) | - | 🔴 faer-fork 1.59× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.8635 ± 0.00245853 (W 0.00786882) | 1.8878 ± 0.0098973 (W 0.00503859) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 53.1176 ± 0.141629 (W 0.0526291) | 42.2936 ± 0.220383 (W 0.216855) | - | 🔴 faer-fork 1.26× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.34492 ± 0.00447962 (W 0.00269878) | 3.36055 ± 0.00475878 (W 0.00363858) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 141.059 ± 0.332309 (W 0.118545) | 141.763 ± 0.22488 (W 0.126012) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.90808 ± 0.00703144 (W 0.00196118) | 1.92664 ± 0.0033764 (W 0.00334999) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 61.5536 ± 0.141187 (W 0.0455591) | 61.9511 ± 0.0343831 (W 0.0384929) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.75124 ± 0.00500878 (W 0.00295976) | 2.30904 ± 0.000651206 (W 0.00626994) | - | 🔴 faer-fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 98.2518 ± 0.094667 (W 0.143466) | 60.5909 ± 0.0819924 (W 0.0503506) | - | 🔴 faer-fork 1.62× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.73002 ± 0.00368802 (W 0.00429039) | 1.72006 ± 0.00141496 (W 0.00271209) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 48.5654 ± 0.134278 (W 0.0351944) | 36.7483 ± 0.108834 (W 0.0320517) | - | 🔴 faer-fork 1.32× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.79615 ± 0.0229864 (W 0.00704217) | 2.38364 ± 0.0259938 (W 0.00661368) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 92.2758 ± 0.230541 (W 0.0688774) | 55.6102 ± 0.222433 (W 0.540305) | - | 🔴 faer-fork 1.66× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.77264 ± 0.00507274 (W 0.00360847) | 1.81154 ± 0.00805117 (W 0.00759733) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 47.5906 ± 0.0260899 (W 0.0793001) | 37.0479 ± 0.248994 (W 0.422554) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
