# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `01e741cc92e48668b15f951ec9d7ef66f233b2ce`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `a6057782696adc4570c7d108e2c43a6d2a1ab887`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `fa7dc18d7187c775df58ecb47fb009cac3a0ea22b6fe07a02bd11cd73afcc5e2`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T12:47:19.821465Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --no-publish --checkout ../faer --label blocked-dqds-caller-lock`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T120538Z-blocked-dqds-caller-lock/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.49%, worst 205.73% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 35 of 960 engine cells exceed 5% and carry `!`; median within-process relative SD 0.22%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `svd_thin/n32/b1` | 0.183658 ± 0.000381996 (W 0.00109267) | 0.183181 ± 0.000477368 (W 0.00108923) | 0.17739 ± 0.000198827 (W 0.00147179) | · | · |  |
| `svd_thin/n64/b1` | 0.927909 ± 0.00128793 (W 0.00204768) | 0.922056 ± 0.00513798 (W 0.003585) | 0.76382 ± 0.00538213 (W 0.00304904) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.21428 ± 0.0297854 (W 0.00217617) | 2.21505 ± 0.00821224 (W 0.00276799) | 1.68378 ± 0.0587832 (W 0.00923433) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.082602 ± 0.000293776 (W 0.00159711) | 0.140591 ± 0.000105399 (W 0.00121593) | 0.064961 ± 0.000295873 (W 0.000105732) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.292875 ± 0.00124782 (W 0.000990502) | 0.515578 ± 0.000159962 (W 0.00161424) | 0.266261 ± 0.000727505 (W 0.00168415) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.66805 ± 0.00108832 (W 0.0019727) | 1.18622 ± 0.00663721 (W 0.00182728) | 0.639068 ± 0.00150265 (W 0.00297753) | 🔵 faer-fork 1.78× faster than `faer-upstream` | · |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183331 ± 0.000255312 (W 0.00163594) | 0.183598 ± 0.000250621 (W 0.00157996) | 0.185482 ± 0.000482383 (W 0.00133806) | · | · |  |
| `svd_thin/n64/b1` | 0.91306 ± 0.00329755 (W 0.00164418) | 0.905386 ± 0.00276151 (W 0.00161381) | 0.66595 ± 0.00185534 (W 0.00174788) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.10107 ± 0.00355901 (W 0.00320793) | 2.09137 ± 0.00329349 (W 0.00102775) | 1.41052 ± 0.0019497 (W 0.00235846) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082273 ± 7.07201e-05 (W 0.00015884) | 0.141984 ± 0.000478708 (W 0.00148068) | 0.06474 ± 0.000463291 (W 0.000123004) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.292014 ± 0.00164377 (W 0.00199138) | 0.518846 ± 0.00100069 (W 0.00217739) | 0.269782 ± 0.000331533 (W 0.00118291) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.665447 ± 0.00116165 (W 0.00141008) | 1.18354 ± 0.00122898 (W 0.00130092) | 0.608032 ± 0.00141793 (W 0.00173063) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183922 ± 0.0023407 (W 0.00125047) | 0.184172 ± 0.00205714 (W 0.00114578) | 0.188458 ± 0.000741391 (W 0.00131897) | · | · |  |
| `svd_thin/n64/b1` | 0.91418 ± 0.00255153 (W 0.00244807) | 0.911862 ± 0.0073781 (W 0.00311295) | 0.668936 ± 0.00645541 (W 0.000722967) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09747 ± 0.00153128 (W 0.00191099) | 2.1164 ± 0.00607151 (W 0.00239587) | 1.35541 ± 0.0500317 (W 0.00239023) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.082483 ± 0.000236119 (W 0.000219135) | 0.141253 ± 0.000579995 (W 0.000271983) | 0.06452 ± 0.000138601 (W 0.000100126) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.292444 ± 0.00057428 (W 0.00144954) | 0.517091 ± 0.00208498 (W 0.00166171) | 0.270582 ± 0.000622794 (W 0.00177394) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.667571 ± 0.000711822 (W 0.00252131) | 1.18317 ± 0.00184301 (W 0.00132776) | 0.600338 ± 0.0007321 (W 0.00183023) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.185545 ± 0.000248526 (W 0.00158526) | 0.185281 ± 0.000136001 (W 0.0012022) | 0.168393 ± 0.00040013 (W 0.00122633) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.972457 ± 0.00125994 (W 0.00186682) | 0.965338 ± 0.00662563 (W 0.00264757) | 0.711642 ± 0.00756977 (W 0.00424781) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.16555 ± 0.0382423 (W 0.00211463) | 2.15807 ± 0.0351031 (W 0.00255909) | 1.62147 ± 0.0537483 (W 0.00478102) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.082343 ± 0.000270167 (W 0.000266912) | 0.142696 ± 0.00123876 (W 0.000995278) | 0.05925 ± 0.000338674 (W 0.000117993) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.295544 ± 0.000710889 (W 0.0014362) | 0.536568 ± 0.00171079 (W 0.00143093) | 0.255521 ± 0.000463882 (W 0.00110991) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.67643 ± 0.00196464 (W 0.00168053) | 1.19141 ± 0.00774704 (W 0.00217695) | 0.609593 ± 0.000956352 (W 0.00166616) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.186016 ± 0.000362964 (W 0.00132028) | 0.185515 ± 0.000676884 (W 0.00146997) | 0.176966 ± 0.000330642 (W 0.00158427) | · | · |  |
| `svd_thin/n64/b1` | 0.957033 ± 0.0265176 (W 0.00232047) | 0.951824 ± 0.00716408 (W 0.00255692) | 0.647203 ± 0.00128498 (W 0.00205744) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09401 ± 0.00224551 (W 0.0023206) | 2.0941 ± 0.00305047 (W 0.00200957) | 1.38533 ± 0.000485727 (W 0.00245325) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082463 ± 0.000201227 (W 0.00128259) | 0.142304 ± 0.000313694 (W 0.00119717) | 0.05938 ± 0.000104978 (W 0.000108491) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.295019 ± 0.0021725 (W 0.00173929) | 0.538874 ± 0.00163065 (W 0.0021582) | 0.259493 ± 0.000804434 (W 0.00150003) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.674824 ± 0.00108992 (W 0.00198975) | 1.18839 ± 0.000845972 (W 0.00165735) | 0.606207 ± 0.00198287 (W 0.00199363) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.186095 ± 0.00235583 (W 0.00153094) | 0.185786 ± 0.00110549 (W 0.00132791) | 0.179013 ± 0.000188343 (W 0.00104817) | · | · |  |
| `svd_thin/n64/b1` | 0.953913 ± 0.00148691 (W 0.0024796) | 0.951676 ± 0.00373996 (W 0.00167545) | 0.645342 ± 0.0100202 (W 0.00189771) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09522 ± 0.00179349 (W 0.00245038) | 2.11004 ± 0.00481324 (W 0.00247897) | 1.335 ± 0.00254048 (W 0.0023796) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082122 ± 0.000155757 (W 0.000369504) | 0.142764 ± 0.000291277 (W 0.00187816) | 0.05934 ± 0.000120226 (W 0.000119093) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.294938 ± 0.000515722 (W 0.00179365) | 0.535936 ± 0.000736387 (W 0.00173623) | 0.260965 ± 0.00154091 (W 0.00130422) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.674614 ± 0.000808624 (W 0.00195017) | 1.1887 ± 0.000774599 (W 0.00153724) | 0.605618 ± 0.00107797 (W 0.00145508) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.237457 ± 0.00244474 (W 0.00153221) | 0.235223 ± 0.00236462 (W 0.00130884) | 0.25267 ± 4.31895e-05 (W 0.00133672) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21701 ± 0.00255341 (W 0.00133187) | 1.21979 ± 0.00104703 (W 0.00220082) | 1.34162 ± 0.00130264 (W 0.00282202) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.12896 ± 0.00612743 (W 0.00214913) | 3.12462 ± 0.00478205 (W 0.00394516) | 3.49247 ± 0.00154881 (W 0.00843913) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099012 ± 0.000522487 (W 0.00148109) | 0.159985 ± 6.49333e-05 (W 0.00121648) | 0.1025 ± 0.121624 (W 0.00012276) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.39706 ± 0.00126568 (W 0.00150436) | 0.646972 ± 0.00199853 (W 0.00118981) | 0.492607 ± 0.0015667 (W 0.0017468) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.978682 ± 0.00280347 (W 0.000974409) | 1.50531 ± 0.00341277 (W 0.0127369) | 1.3759 ± 0.0300502 (W 0.00221076) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.235494 ± 0.00112927 (W 0.00184708) | 0.235399 ± 0.00139765 (W 0.00125693) | 0.261957 ± 0.000859555 (W 0.00130499) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.1475 ± 0.00253122 (W 0.0020905) | 1.14502 ± 0.000470515 (W 0.00164969) | 1.03616 ± 0.00284443 (W 0.00152407) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.80025 ± 0.00355295 (W 0.0035679) | 2.79466 ± 0.00186214 (W 0.00294334) | 2.53119 ± 0.00229251 (W 0.00278943) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099085 ± 6.98642e-05 (W 0.000234003) | 0.160138 ± 0.000132525 (W 0.00123536) | 0.102991 ± 0.00015252 (W 0.0010611) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.399995 ± 0.00257233 (W 0.00269097) | 0.648946 ± 0.00184506 (W 0.00184954) | 0.493126 ± 0.00146362 (W 0.00217888) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.980417 ± 0.00209874 (W 0.000590463) | 1.50535 ± 0.00238365 (W 0.0147716) | 1.35988 ± 0.00391135 (W 0.00160003) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.235709 ± 0.00136953 (W 0.00171019) | 0.234141 ± 0.000445462 (W 0.00152493) | 0.263967 ± 0.000708772 (W 0.00131887) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.13904 ± 0.00227335 (W 0.000465259) | 1.1523 ± 0.00138942 (W 0.00130904) | 1.07185 ± 0.00495858 (W 0.0035925) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.75371 ± 0.00418972 (W 0.00438164) | 2.82306 ± 0.00142263 (W 0.00304509) | 2.34643 ± 0.00184018 (W 0.00346746) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.098915 ± 0.000228038 (W 0.00127777) | 0.160188 ± 0.000290496 (W 0.0012673) | 0.102429 ± 0.000239606 (W 0.00167469) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.398592 ± 0.00204247 (W 0.00200654) | 0.647966 ± 0.00141655 (W 0.00243899) | 0.493308 ± 0.000876891 (W 0.00141307) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.979817 ± 0.00241968 (W 0.00133069) | 1.50347 ± 0.00411256 (W 0.00157076) | 1.39344 ± 0.00096089 (W 0.00532841) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.235313 ± 0.00245258 (W 0.00119397) | 0.231848 ± 0.00264555 (W 0.00140623) | 0.249514 ± 0.000319573 (W 0.00178698) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24837 ± 0.00304247 (W 0.00192077) | 1.25079 ± 0.00144505 (W 0.00149255) | 1.31191 ± 0.00371549 (W 0.00288622) | · | · |  |
| `svd_thin/n96/b1` | 3.08862 ± 0.00642815 (W 0.00252793) | 3.08518 ± 0.00879395 (W 0.00359357) | 3.42372 ± 0.00494632 (W 0.00510052) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099535 ± 0.000159594 (W 0.00159857) | 0.158044 ± 6.41327e-05 (W 0.00149542) | 0.100906 ± 6.60908e-05 (W 9.86321e-05) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.395495 ± 0.000533653 (W 0.00203671) | 0.622867 ± 0.00109578 (W 0.00148951) | 0.480765 ± 0.000457202 (W 0.00157261) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.976328 ± 0.00248518 (W 0.00145986) | 1.47746 ± 0.00209655 (W 0.00135855) | 1.34067 ± 0.00164526 (W 0.0016886) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233204 ± 0.00134179 (W 0.00145589) | 0.232212 ± 0.000791683 (W 0.0018185) | 0.257759 ± 0.000482594 (W 0.00156922) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.17802 ± 0.00377963 (W 0.00152954) | 1.17519 ± 0.00304827 (W 0.002208) | 1.01136 ± 0.00191136 (W 0.000853427) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.7575 ± 0.00182936 (W 0.00306016) | 2.75305 ± 0.00387631 (W 0.00367535) | 2.50829 ± 0.00639743 (W 0.00454695) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099726 ± 2.57164e-05 (W 0.000207917) | 0.158572 ± 0.000159895 (W 0.000381107) | 0.101449 ± 0.00051589 (W 0.000131275) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.39709 ± 0.00231088 (W 0.0019057) | 0.623491 ± 0.00223636 (W 0.00209827) | 0.482316 ± 0.00137829 (W 0.00174155) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.975858 ± 0.0028387 (W 0.00148955) | 1.47576 ± 0.0023358 (W 0.00208429) | 1.34382 ± 0.00256253 (W 0.00210279) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233154 ± 0.000878192 (W 0.000954824) | 0.231361 ± 0.000184023 (W 0.00184976) | 0.259292 ± 0.000465184 (W 0.00188171) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.17056 ± 0.00181609 (W 0.00171179) | 1.18194 ± 0.000951662 (W 0.00114249) | 0.976168 ± 0.00201104 (W 0.00222882) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.71562 ± 0.00251618 (W 0.00429756) | 2.7871 ± 0.000896581 (W 0.00382418) | 2.33319 ± 0.000876639 (W 0.00236625) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099946 ± 0.000260501 (W 0.00148884) | 0.158615 ± 0.000151662 (W 0.00131635) | 0.100677 ± 0.000214742 (W 0.000151751) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.395667 ± 0.00166693 (W 0.00147675) | 0.623239 ± 0.00123151 (W 0.00197061) | 0.480112 ± 0.000311218 (W 0.00171836) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.976168 ± 0.00375943 (W 0.00103323) | 1.47628 ± 0.00728675 (W 0.00190595) | 1.33705 ± 0.00128222 (W 0.00124302) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137164 ± 0.000458887 (W 0.00117385) | 0.138627 ± 0.000436975 (W 0.00146857) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.53805 ± 0.000910336 (W 0.00204394) | 0.539404 ± 0.000597415 (W 0.00179219) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56695 ± 0.00143999 (W 0.00249051) | 1.56851 ± 0.00194657 (W 0.00187735) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068176 ± 0.000267459 (W 9.66499e-05) | 0.111427 ± 7.10023e-05 (W 0.00125457) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.230187 ± 0.000816481 (W 0.00163025) | 0.400324 ± 0.00104201 (W 0.00143864) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.510401 ± 0.00280031 (W 0.0019971) | 0.885171 ± 0.000519971 (W 0.00208316) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.136944 ± 0.00056974 (W 0.00187079) | 0.13955 ± 0.000855781 (W 0.001346) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.530636 ± 0.00059262 (W 0.00162285) | 0.542087 ± 0.000135005 (W 0.00204183) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.50821 ± 0.00397229 (W 0.00233735) | 1.53154 ± 0.00117433 (W 0.00160868) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068095 ± 0.000297973 (W 0.000247419) | 0.111466 ± 0.000265614 (W 0.00138219) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.230245 ± 0.00135631 (W 0.00129349) | 0.399703 ± 0.000898266 (W 0.00199468) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.510691 ± 0.00184091 (W 0.0020098) | 0.885255 ± 0.002392 (W 0.000904158) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.135882 ± 3.50856e-05 (W 0.00149236) | 0.138647 ± 0.00104697 (W 0.000129482) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.524096 ± 0.00137229 (W 0.00150719) | 0.54838 ± 0.00298443 (W 0.00324382) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51294 ± 0.00118741 (W 0.00257899) | 1.56514 ± 0.00293844 (W 0.00360397) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068207 ± 0.000252291 (W 0.000198462) | 0.111367 ± 0.000212789 (W 0.000143161) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.230715 ± 0.000643895 (W 0.0013694) | 0.401671 ± 0.000715679 (W 0.00217405) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.511073 ± 0.00152972 (W 0.00174634) | 0.885489 ± 0.000977929 (W 0.00109485) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146041 ± 0.000815691 (W 0.00121167) | 0.148423 ± 0.000413732 (W 0.000995988) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.541979 ± 0.00305711 (W 0.00182681) | 0.542688 ± 0.000411089 (W 0.0015745) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56148 ± 0.0045942 (W 0.00191754) | 1.56505 ± 0.001155 (W 0.0028166) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.069068 ± 0.000136654 (W 7.12741e-05) | 0.110726 ± 0.000120876 (W 0.00109424) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.232662 ± 0.000408015 (W 0.00143565) | 0.401167 ± 0.0003353 (W 0.00159255) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.515049 ± 0.00119851 (W 0.00195251) | 0.867375 ± 0.00146164 (W 0.00131009) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.145608 ± 0.000433547 (W 0.001544) | 0.147736 ± 0.00051918 (W 0.00132637) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.534846 ± 0.00132118 (W 0.00216656) | 0.546847 ± 0.00129461 (W 0.00221535) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.50351 ± 0.00230429 (W 0.00170093) | 1.52638 ± 0.00235438 (W 0.00227184) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068979 ± 0.000155931 (W 0.000144101) | 0.110616 ± 0.000282985 (W 0.00169036) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.232188 ± 0.000511393 (W 0.00143424) | 0.399686 ± 0.000798201 (W 0.00202163) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.513225 ± 0.00154824 (W 0.00194791) | 0.868267 ± 0.000420487 (W 0.0014824) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146072 ± 0.00074031 (W 0.00122561) | 0.147153 ± 0.00034128 (W 0.00133366) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.528472 ± 0.000323951 (W 0.00176214) | 0.551818 ± 0.00694793 (W 0.00263015) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51048 ± 0.00141461 (W 0.00302546) | 1.56748 ± 0.00718333 (W 0.0077529) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068978 ± 2.6839e-05 (W 0.000119746) | 0.110664 ± 0.000165735 (W 0.00159311) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.232964 ± 0.000528216 (W 0.00182259) | 0.402212 ± 0.000701027 (W 0.00213767) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.513958 ± 0.00210007 (W 0.00192117) | 0.867756 ± 0.000443334 (W 0.00139869) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.171629 ± 0.000384072 (W 0.00131504) | 0.171667 ± 0.000524326 (W 0.00133157) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.689661 ± 0.00266878 (W 0.00183293) | 0.686097 ± 0.00325835 (W 0.00153122) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.03908 ± 0.00344751 (W 0.00236169) | 2.03691 ± 0.001768 (W 0.0025549) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077986 ± 0.000373297 (W 0.000127593) | 0.118861 ± 0.000519423 (W 0.00129726) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.289929 ± 0.00281707 (W 0.00134574) | 0.457009 ± 0.004342 (W 0.0016873) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.68894 ± 0.0028973 (W 0.00193342) | 1.04734 ± 0.00382287 (W 0.00154399) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.171569 ± 0.000595134 (W 0.00137927) | 0.170945 ± 0.00120266 (W 0.00144608) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.652613 ± 0.00320532 (W 0.00144824) | 0.652042 ± 0.00428689 (W 0.00220975) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.84027 ± 0.00393931 (W 0.00452804) | 1.84036 ± 0.00184788 (W 0.00368159) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077543 ± 0.000448012 (W 0.00141649) | 0.119009 ± 0.000494777 (W 0.00155489) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.288606 ± 0.00113211 (W 0.00145468) | 0.456351 ± 0.0013888 (W 0.0017871) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.689742 ± 0.00298059 (W 0.00197685) | 1.04615 ± 0.00128071 (W 0.000882117) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170677 ± 0.000660091 (W 0.00202539) | 0.170525 ± 9.59236e-05 (W 0.00159084) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.648227 ± 0.0112548 (W 0.00206752) | 0.657353 ± 0.011344 (W 0.00232446) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.81758 ± 0.00645485 (W 0.0015956) | 1.85462 ± 0.00167662 (W 0.00412562) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077483 ± 0.000616822 (W 0.000264002) | 0.11933 ± 0.00105043 (W 0.00126479) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.289404 ± 0.00138293 (W 0.00142295) | 0.456823 ± 0.0012986 (W 0.00242767) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.689775 ± 0.00430229 (W 0.00281614) | 1.04727 ± 0.00447323 (W 0.0015801) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173332 ± 0.000855453 (W 0.00162161) | 0.173163 ± 0.00120095 (W 0.00138911) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.696276 ± 0.00241792 (W 0.0016766) | 0.695865 ± 0.00466831 (W 0.0022384) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05683 ± 0.00233777 (W 0.0015761) | 2.05347 ± 0.00122351 (W 0.00253022) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.078907 ± 0.000349333 (W 0.000148814) | 0.118541 ± 0.000462598 (W 0.00122742) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.288816 ± 0.00287598 (W 0.00147975) | 0.449806 ± 0.00399944 (W 0.00189559) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.695011 ± 0.00258469 (W 0.00218048) | 1.04558 ± 0.00328808 (W 0.00149219) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173112 ± 0.000408025 (W 0.00121825) | 0.173051 ± 0.000904345 (W 0.00106386) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.661469 ± 0.00347772 (W 0.00181328) | 0.660407 ± 0.00485735 (W 0.00125147) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.85542 ± 0.0048674 (W 0.00198279) | 1.85578 ± 0.000477182 (W 0.00278808) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.078575 ± 0.000363905 (W 7.89303e-05) | 0.1183 ± 0.000341898 (W 0.00122429) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.287119 ± 0.000599442 (W 0.00173315) | 0.449376 ± 0.00127116 (W 0.00209648) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.693269 ± 0.00102159 (W 0.00159354) | 1.04448 ± 0.00223201 (W 0.00194078) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172599 ± 0.00791991 (W 0.00150107) | 0.172468 ± 0.000831085 (W 0.00142929) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.654578 ± 0.011105 (W 0.00223079) | 0.664066 ± 0.0113449 (W 0.00150152) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.8338 ± 0.00599583 (W 0.00271658) | 1.87287 ± 0.00356845 (W 0.00223567) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.078605 ± 0.00127442 (W 0.000101021) | 0.118118 ± 9.24554e-05 (W 0.00146471) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.286619 ± 0.00140336 (W 0.00163355) | 0.450948 ± 0.00115058 (W 0.00220875) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.695014 ± 0.00502404 (W 0.00204945) | 1.04604 ± 0.00266308 (W 0.00126683) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.5847 ± 0.00231953 (W 0.00620103) | 3.68844 ± 0.00495734 (W 0.00492568) | 3.40093 ± 0.00439969 (W 0.0154093) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 17.0763 ± 0.0412781 (W 0.0156359) | 18.5088 ± 0.0407525 (W 0.016675) | 18.0406 ± 0.0361953 (W 0.0416452) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.8934 ± 0.269359 (W 0.0502695) | 105.68 ± 0.0922748 (W 0.0999654) | 116.536 ± 0.64669 (W 0.193509) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.2604 ± 0.00935764 (W 0.00236748) | 2.69902 ± 0.0199132 (W 0.00460565) | 1.18937 ± 0.0318923 (W 0.00330496) | 🔵 faer-fork 2.14× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.56668 ± 0.021343 (W 0.00694726) | 12.4893 ± 0.0393681 (W 0.0228575) | 6.97324 ± 0.138309 (W 0.00955375) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 41.4421 ± 0.172833 (W 0.0248645) | 66.2597 ± 0.151401 (W 0.385686) | 47.9597 ± 0.48521 (W 0.136207) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.71422 ± 0.0116574 (W 0.0135637) | 2.80495 ± 0.0140092 (W 0.0138359) | 2.62768 ± 0.00177523 (W 0.00671618) | · | · |  |
| `svd_thin/n256/b1` | 11.8051 ± 0.0388757 (W 0.035892) | 13.2484 ± 0.00797843 (W 0.0117649) | 12.4636 ± 0.0188426 (W 0.0123735) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 43.8118 ± 1.17613 (W 1.19167) | 55.7493 ± 0.0619842 (W 0.104085) | 57.6287 ± 0.463556 (W 0.0494472) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.25608 ± 0.000574128 (W 0.00318893) | 2.17443 ± 0.00288399 (W 0.00353919) | 1.13351 ± 0.00884376 (W 0.00246732) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.50606 ± 0.00717985 (W 0.00719962) | 10.4629 ± 0.0195247 (W 0.0126137) | 6.09858 ± 0.146859 (W 0.0112859) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 24.6111 ± 0.136271 (W 0.0171547) | 41.877 ± 0.102828 (W 0.0310834) | 25.7454 ± 0.619248 (W 0.0232755) | 🔵 faer-fork 1.70× faster than `faer-upstream` | · |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.67497 ± 0.00249716 (W 0.00319517) | 2.81636 ± 0.00715972 (W 0.00423369) | 2.51467 ± 0.004218 (W 0.00503001) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 11.4881 ± 0.0198328 (W 0.0367724) | 13.2785 ± 0.0186008 (W 0.0166879) | 11.4929 ± 0.00728669 (W 0.0141528) | 🔵 faer-fork 1.16× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 38.7648 ± 0.0446764 (W 0.141004) | 52.5787 ± 0.0667379 (W 0.149102) | 48.3097 ± 0.507784 (W 0.0354409) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.25338 ± 0.00123412 (W 0.00287648) | 2.17656 ± 0.00278749 (W 0.00172918) | 1.11758 ± 0.0127072 (W 0.00245514) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.56159 ± 0.000988548 (W 0.0100041) | 10.5274 ± 0.0316703 (W 0.0103454) | 5.98615 ± 0.181787 (W 0.00725315) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 23.1225 ± 0.137625 (W 0.0299205) | 40.3662 ± 0.128208 (W 0.0641221) | 22.3882 ± 0.762537 (W 0.0172211) | 🔵 faer-fork 1.75× faster than `faer-upstream` | · | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.58265 ± 0.00180895 (W 0.00224947) | 3.68142 ± 0.0063022 (W 0.00249498) | 3.3001 ± 0.0165621 (W 0.0110095) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 16.9681 ± 0.0328514 (W 0.00685191) | 18.3808 ± 0.0190394 (W 0.010866) | 17.72 ± 0.0537738 (W 0.0520748) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 94.2018 ± 0.0729557 (W 0.404567) | 104.826 ± 0.0907128 (W 0.0907214) | 115.751 ± 0.104684 (W 0.398092) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.2375 ± 0.00136038 (W 0.00208667) | 2.61757 ± 0.0133035 (W 0.00368441) | 1.15797 ± 0.00531992 (W 0.00261491) | 🔵 faer-fork 2.12× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.41743 ± 0.0179272 (W 0.00655418) | 12.2993 ± 0.0257144 (W 0.013581) | 6.83402 ± 0.00922322 (W 0.0143146) | 🔵 faer-fork 1.92× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.2672 ± 0.0887169 (W 0.0291927) | 65.4278 ± 0.198608 (W 0.0595632) | 47.3407 ± 0.149171 (W 0.0449043) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.69279 ± 0.0166869 (W 0.00990486) | 2.76067 ± 0.0105523 (W 0.0109994) | 2.61727 ± 0.00469677 (W 0.00603392) | · | · |  |
| `svd_thin/n256/b1` | 11.7379 ± 0.0441718 (W 0.0332492) | 13.1178 ± 0.0374021 (W 0.0210973) | 12.4419 ± 0.0495381 (W 0.0155885) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 42.8646 ± 1.38898 (W 0.917311) | 54.9446 ± 0.341503 (W 0.0452429) | 58.4809 ± 0.116468 (W 0.0641258) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.23151 ± 0.000399282 (W 0.00188538) | 2.1088 ± 0.00195522 (W 0.0044409) | 1.13797 ± 0.00328195 (W 0.0030453) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.37416 ± 0.00436947 (W 0.00647862) | 10.2917 ± 0.0119566 (W 0.0172736) | 6.12539 ± 0.0290575 (W 0.00704604) | 🔵 faer-fork 1.61× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 23.6464 ± 0.00465326 (W 0.0087734) | 40.8985 ± 0.0644871 (W 0.0486594) | 25.7358 ± 0.160819 (W 0.0296171) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.64875 ± 0.00149475 (W 0.00376104) | 2.78419 ± 0.00250542 (W 0.00354748) | 2.49059 ± 0.00398641 (W 0.00342496) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 11.3454 ± 0.0299144 (W 0.013971) | 13.1441 ± 0.0101006 (W 0.0236748) | 11.5415 ± 0.0636599 (W 0.013613) | 🔵 faer-fork 1.16× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 37.8557 ± 0.14286 (W 0.0501717) | 51.565 ± 0.377862 (W 0.369538) | 49.5386 ± 0.583264 (W 0.0456528) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.23248 ± 0.0016802 (W 0.00106215) | 2.11347 ± 0.0088311 (W 0.00367497) | 1.12509 ± 0.00638546 (W 0.00120792) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.43967 ± 0.00889509 (W 0.013561) | 10.3797 ± 0.0419216 (W 0.0158418) | 6.0161 ± 0.0323949 (W 0.0122733) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 22.0523 ± 0.0788312 (W 0.0217363) | 39.2298 ± 0.0530675 (W 0.0663077) | 22.4516 ± 0.110467 (W 0.0183987) | 🔵 faer-fork 1.78× faster than `faer-upstream` | · |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.49918 ± 0.00775381 (W 0.0109516) | 5.76133 ± 0.0210564 (W 0.0275568) | 7.03974 ± 0.00426037 (W 0.00912032) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 32.2734 ± 0.0158905 (W 0.0505335) | 34.2145 ± 0.0908342 (W 0.0519652) | 43.1861 ± 0.235764 (W 0.0427155) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 204.106 ± 0.300423 (W 0.547342) | 210.772 ± 0.410331 (W 0.478292) | 276.134 ± 1.94996 (W 0.799972) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.96946 ± 0.00213665 (W 0.0023445) | 3.47521 ± 0.0382598 (W 0.0318573) | 2.76339 ± 0.0160174 (W 0.00527323) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.0226 ± 0.0456333 (W 0.0183291) | 19.2747 ± 0.0378627 (W 0.018071) | 18.1242 ± 0.0634925 (W 0.0271561) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 90.275 ± 0.6913 (W 0.496806) | 110.56 ± 0.453378 (W 0.408138) | 122.588 ± 1.10147 (W 0.0804914) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.85365 ± 0.0222672 (W 0.0159197) | 4.07718 ± 0.0131665 (W 0.0225421) | 4.15471 ± 0.00761912 (W 0.00512915) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.976 ± 0.0247903 (W 0.0604049) | 21.6285 ± 0.0983874 (W 0.0552089) | 21.2919 ± 0.0233272 (W 0.0197457) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.8208 ± 0.0337271 (W 1.40784) | 87.3719 ± 0.302325 (W 0.108237) | 113.467 ± 1.09142 (W 0.0649724) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.9627 ± 0.0036336 (W 0.00245541) | 2.98955 ± 0.00236551 (W 0.0195634) | 2.02311 ± 0.0130781 (W 0.00525514) | 🔵 faer-fork 1.52× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.2581 ± 0.0836552 (W 0.0234089) | 16.3551 ± 0.105081 (W 0.0448127) | 11.1089 ± 0.00843811 (W 0.0172614) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 45.0679 ± 0.0206042 (W 0.0749172) | 57.8231 ± 0.384809 (W 0.0627767) | 56.2676 ± 0.0497049 (W 0.0671959) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.68126 ± 0.0100452 (W 0.00318217) | 4.07041 ± 0.00768221 (W 0.00989962) | 3.63696 ± 0.00329695 (W 0.00283105) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.4787 ± 0.030849 (W 0.0237798) | 21.0267 ± 0.268161 (W 0.0703875) | 17.2163 ± 0.0647601 (W 0.0298816) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 62.337 ± 0.12784 (W 0.223464) | 74.8125 ± 0.319706 (W 0.384129) | 84.8878 ± 5.4125 (W 0.0806893) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.95472 ± 0.00296346 (W 0.00335165) | 3.00032 ± 0.00727767 (W 0.0121041) | 1.90892 ± 0.000686068 (W 0.0032669) | 🔵 faer-fork 1.53× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.2342 ± 0.043594 (W 0.0191059) | 16.0973 ± 0.080331 (W 0.0295458) | 9.65627 ± 0.0224297 (W 0.0159368) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 38.1936 ± 0.159246 (W 0.0455118) | 51.4726 ± 0.0132474 (W 0.0989988) | 43.3363 ± 0.0391147 (W 0.0396053) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.4734 ± 0.00504888 (W 0.00307502) | 5.69957 ± 0.00430616 (W 0.0049486) | 6.9654 ± 0.0103177 (W 0.00561402) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 31.9145 ± 0.0439739 (W 0.0191883) | 33.8957 ± 0.097223 (W 0.0535664) | 44.9361 ± 1.36316 (W 0.111353) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 202.748 ± 0.250262 (W 0.48695) | 209.419 ± 0.259757 (W 0.47357) | 308.744 ± 22.0812 (W 0.442237) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.93622 ± 0.00269797 (W 0.00360678) | 3.45617 ± 0.00387963 (W 0.00937228) | 2.7153 ± 0.00137499 (W 0.00308977) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.7603 ± 0.0168209 (W 0.0252831) | 18.9775 ± 0.0536326 (W 0.0418789) | 19.8228 ± 1.39272 (W 0.104114) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 88.8847 ± 0.667297 (W 0.272014) | 109.612 ± 0.243078 (W 0.338393) | 156.003 ± 20.6536 (W 0.121655) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.76× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.83602 ± 0.0255985 (W 0.0142586) | 4.07744 ± 0.0205578 (W 0.0264568) | 4.11117 ± 0.01573 (W 0.00462529) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.6353 ± 0.0818819 (W 0.0289474) | 21.3301 ± 0.0525932 (W 0.0310646) | 22.2001 ± 0.627222 (W 0.0250844) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 81.0073 ± 0.111364 (W 1.10804) | 86.7733 ± 0.134847 (W 0.314692) | 123.063 ± 0.461001 (W 0.329661) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.92854 ± 0.00317315 (W 0.00230629) | 2.95178 ± 0.00297797 (W 0.00818016) | 2.01395 ± 0.00370113 (W 0.00414253) | 🔵 faer-fork 1.53× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 11.9974 ± 0.0294415 (W 0.0256674) | 16.1708 ± 0.0278773 (W 0.0190035) | 12.0794 ± 0.58235 (W 0.0324065) | 🔵 faer-fork 1.35× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/n512/b1` | 43.954 ± 0.0829048 (W 0.0582591) | 56.641 ± 0.0325861 (W 0.0713724) | 64.9616 ± 5.36917 (W 0.0694851) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.65296 ± 0.00403059 (W 0.00569331) | 4.06781 ± 0.0251367 (W 0.0189806) | 3.63758 ± 0.0146055 (W 0.0043652) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.1502 ± 0.0854971 (W 0.043489) | 20.9997 ± 0.144164 (W 0.0688879) | 17.5938 ± 0.0841467 (W 0.0270064) | 🔵 faer-fork 1.16× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 61.4003 ± 0.0730266 (W 0.398044) | 73.8155 ± 0.179515 (W 0.393104) | 85.4603 ± 2.43394 (W 0.0538555) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.92609 ± 0.00164978 (W 0.00255235) | 2.95882 ± 0.00546881 (W 0.0144659) | 1.91366 ± 0.0109376 (W 0.00484791) | 🔵 faer-fork 1.54× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 11.9949 ± 0.0144745 (W 0.0222486) | 16.0234 ± 0.0690135 (W 0.0257048) | 9.99978 ± 0.0390244 (W 0.0187569) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 36.9743 ± 0.0979578 (W 0.0562666) | 50.6505 ± 0.110139 (W 0.107056) | 45.93 ± 0.485169 (W 0.0300141) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.31376 ± 0.00234555 (W 0.00381876) | 2.32634 ± 0.00821547 (W 0.00184561) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.7048 ± 0.0076254 (W 0.00663245) | 11.1692 ± 0.0172095 (W 0.0148731) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 55.2743 ± 0.148832 (W 0.0224044) | 61.3404 ± 0.0358845 (W 0.0287861) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.917736 ± 0.00223057 (W 0.00252973) | 1.71381 ± 0.00326617 (W 0.00256038) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.29704 ± 0.00791444 (W 0.00611661) | 7.84476 ± 0.0290555 (W 0.00685049) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.9007 ± 0.10471 (W 0.0241823) | 40.2218 ± 0.14996 (W 0.0409742) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.7941 ± 0.00981797 (W 0.00601745) | 1.82305 ± 0.0121913 (W 0.00696737) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.94305 ± 0.0594259 (W 0.0564003) | 8.37621 ± 0.123942 (W 0.0706828) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 29.0235 ± 0.883044 (W 0.886846) | 35.4967 ± 0.100989 (W 0.0456032) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 0.917296 ± 0.000847554 (W 0.00179019) | 1.44179 ± 0.00115005 (W 0.0024064) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.30284 ± 0.0127963 (W 0.00752228) | 6.67134 ± 0.0361743 (W 0.00907497) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 17.2845 ± 0.0275519 (W 0.0213437) | 27.7905 ± 0.104018 (W 0.0216473) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.78087 ± 0.00217605 (W 0.00415052) | 1.96613 ± 0.0105693 (W 0.00787815) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.69328 ± 0.00638336 (W 0.0159813) | 8.69195 ± 0.0270833 (W 0.0250084) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 26.7136 ± 0.0976006 (W 0.0644872) | 34.4037 ± 0.0590324 (W 0.0433579) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.915974 ± 0.00355277 (W 0.000991531) | 1.4416 ± 0.000920601 (W 0.00253188) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.367 ± 0.0121026 (W 0.0154937) | 6.73033 ± 0.031812 (W 0.00676045) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.6756 ± 0.0384576 (W 0.0248293) | 27.0771 ± 0.0501382 (W 0.0187201) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.32315 ± 0.00588909 (W 0.00436354) | 2.34105 ± 0.00831363 (W 0.00265451) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.6679 ± 0.0115788 (W 0.00787079) | 11.1925 ± 0.0190678 (W 0.0356766) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 54.7293 ± 0.11563 (W 0.0370932) | 60.7285 ± 0.0208381 (W 0.0376338) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.910062 ± 0.00190001 (W 0.00169552) | 1.6764 ± 0.00167065 (W 0.00232081) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.17757 ± 0.0013305 (W 0.00351149) | 7.6854 ± 0.0276335 (W 0.00696565) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.2892 ± 0.087927 (W 0.0243152) | 39.6117 ± 0.141536 (W 0.0172361) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.81332 ± 0.00869286 (W 0.00583164) | 1.8276 ± 0.0131741 (W 0.0068717) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.82525 ± 0.0327623 (W 0.0480615) | 8.50977 ± 0.0712039 (W 0.0610931) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 28.6035 ± 0.057499 (W 0.946317) | 34.941 ± 0.0283062 (W 0.0355199) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.9087 ± 0.000622231 (W 0.00183046) | 1.4076 ± 0.000560116 (W 0.00255395) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.17923 ± 0.018169 (W 0.00851358) | 6.49968 ± 0.0334892 (W 0.0129677) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.7684 ± 0.010072 (W 0.015374) | 27.2628 ± 0.120194 (W 0.0192619) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.79239 ± 0.00304671 (W 0.00263327) | 1.97635 ± 0.0032643 (W 0.00885276) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.62689 ± 0.0111664 (W 0.017334) | 8.69057 ± 0.0339423 (W 0.0180612) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 26.4324 ± 0.115048 (W 0.0607898) | 34.0056 ± 0.0615913 (W 0.0445153) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.908651 ± 0.00260354 (W 0.00126234) | 1.40873 ± 0.00265687 (W 0.00317627) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.24169 ± 0.0099074 (W 0.0162754) | 6.55194 ± 0.0252784 (W 0.00610268) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.1359 ± 0.0460489 (W 0.0233412) | 26.4908 ± 0.0815169 (W 0.0225992) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.28876 ± 0.00306955 (W 0.00304543) | 3.35377 ± 0.0121453 (W 0.00589985) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 18.4474 ± 0.0667446 (W 0.0303349) | 19.5107 ± 0.0225738 (W 0.0567173) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 112.442 ± 0.491043 (W 0.142105) | 121.483 ± 0.598379 (W 0.204973) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.3255 ± 0.00724542 (W 0.00181029) | 2.14566 ± 0.0238748 (W 0.00872194) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.70807 ± 0.0218527 (W 0.0276548) | 11.572 ± 0.00986852 (W 0.0476326) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 49.8613 ± 0.48338 (W 0.0640563) | 68.8581 ± 0.481731 (W 0.119799) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.42471 ± 0.012745 (W 0.00593735) | 2.49974 ± 0.00565117 (W 0.0103892) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.1751 ± 0.0322431 (W 0.055274) | 13.0943 ± 0.0552376 (W 0.0722288) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 49.4656 ± 0.809619 (W 1.00424) | 57.7059 ± 0.0824232 (W 0.0675561) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.32434 ± 0.00277071 (W 0.00251537) | 1.85259 ± 0.00401836 (W 0.00562536) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.29426 ± 0.052676 (W 0.0298162) | 9.94603 ± 0.0221996 (W 0.0174264) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 27.7606 ± 0.247603 (W 0.0408519) | 41.4217 ± 0.492903 (W 0.0466738) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.35244 ± 0.00657628 (W 0.011072) | 2.52019 ± 0.00911558 (W 0.00520346) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.4716 ± 0.0244748 (W 0.0342689) | 13.075 ± 0.0137155 (W 0.0355443) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 39.8555 ± 0.137738 (W 0.0696055) | 52.4504 ± 0.184707 (W 0.231015) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.31796 ± 0.00179941 (W 0.00317467) | 1.85967 ± 0.00667362 (W 0.00508185) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.36596 ± 0.0530008 (W 0.0282386) | 9.9316 ± 0.0596855 (W 0.0257763) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 25.1755 ± 0.103909 (W 0.0187617) | 38.9613 ± 0.0779702 (W 0.0558451) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.28154 ± 0.0043105 (W 0.00394253) | 3.35412 ± 0.00655854 (W 0.00675381) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 18.3723 ± 0.0384244 (W 0.0790669) | 19.3819 ± 0.0496891 (W 0.0243184) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 111.468 ± 0.26418 (W 0.378214) | 120.511 ± 0.256383 (W 0.0824566) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30654 ± 0.00648785 (W 0.0020703) | 2.11252 ± 0.0250136 (W 0.00546971) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.51991 ± 0.0291405 (W 0.0382254) | 11.3675 ± 0.0464757 (W 0.0175734) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 48.8493 ± 0.215514 (W 0.0692234) | 67.9344 ± 0.117174 (W 0.0821617) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.40461 ± 0.0100332 (W 0.00568446) | 2.47653 ± 0.0113278 (W 0.0100413) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.0809 ± 0.0524301 (W 0.060218) | 13.0327 ± 0.0374412 (W 0.0607744) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 48.3399 ± 0.895835 (W 1.03017) | 57.1482 ± 0.728365 (W 0.140712) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30221 ± 0.00183396 (W 0.00245345) | 1.83782 ± 0.00337354 (W 0.00385341) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.16277 ± 0.0295696 (W 0.0280092) | 9.82824 ± 0.0444081 (W 0.0381679) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 26.7414 ± 0.140086 (W 0.0863803) | 40.3216 ± 0.563874 (W 0.059641) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.32509 ± 0.00445873 (W 0.00316706) | 2.48959 ± 0.00536311 (W 0.00659243) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.3503 ± 0.0323525 (W 0.027899) | 12.935 ± 0.0136363 (W 0.0418789) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 39.013 ± 0.110329 (W 0.0743931) | 51.967 ± 0.412101 (W 0.14824) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29891 ± 0.000941687 (W 0.00112759) | 1.84355 ± 0.00310562 (W 0.00793928) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.21452 ± 0.0110919 (W 0.0377841) | 9.88911 ± 0.0134001 (W 0.0397749) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 24.1907 ± 0.0396469 (W 0.0776805) | 37.9558 ± 0.0545314 (W 0.0591896) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.50604 ± 0.00461712 (W 0.00238995) | 2.50556 ± 0.0103433 (W 0.00462494) | 3.06016 ± 0.00857316 (W 0.0064989) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 86.7565 ± 0.193401 (W 0.0314186) | 88.2376 ± 0.104557 (W 0.136351) | 120.891 ± 0.365873 (W 0.136199) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.24332 ± 0.000949651 (W 0.00630801) | 1.48831 ± 0.0055398 (W 0.00577091) | 1.39162 ± 0.157698 (W 0.0031331) | 🔵 faer-fork 1.20× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 39.6455 ± 0.03946 (W 0.0383894) | 44.8168 ± 0.0990066 (W 0.0435254) | 46.643 ± 3.62388 (W 0.136007) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.2845 ± 0.00680895 (W 0.00430181) | 2.14469 ± 0.003331 (W 0.00425592) | 1.88079 ± 0.00886768 (W 0.00526285) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 67.0258 ± 2.7974 (W 2.59319) | 48.7909 ± 1.02239 (W 1.36276) | 48.7119 ± 0.0597475 (W 0.0820816) | 🔴 faer-fork 1.37× slower than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.19624 ± 0.00217392 (W 0.00359859) | 1.5337 ± 0.0111456 (W 0.0035444) | 0.94836 ± 0.156026 (W 0.0113051) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 35.2802 ± 0.00494718 (W 0.0350459) | 32.7666 ± 0.0529081 (W 0.0267841) | 22.4676 ± 3.06919 (W 0.0740283) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.35501 ± 0.00391313 (W 0.00387118) | 2.24293 ± 0.00539325 (W 0.00635174) | 1.67405 ± 0.0210523 (W 0.00380019) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 62.9716 ± 1.14121 (W 2.45374) | 46.4273 ± 0.291554 (W 0.130339) | 36.4079 ± 0.212526 (W 0.0395248) | 🔴 faer-fork 1.36× slower than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.24219 ± 0.00492116 (W 0.00473221) | 1.62994 ± 0.00694047 (W 0.00417117) | 0.811948 ± 0.193363 (W 0.00302028) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 34.9739 ± 0.229388 (W 0.0848893) | 33.6537 ± 0.0884966 (W 0.0686749) | 16.916 ± 2.57589 (W 0.0511756) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.44417 ± 0.00571625 (W 0.00348467) | 2.44526 ± 0.00302129 (W 0.00233458) | 2.81809 ± 0.00645513 (W 0.00516097) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 81.6892 ± 0.47357 (W 0.366679) | 83.0844 ± 0.206368 (W 0.0981271) | 109.173 ± 1.09428 (W 0.209433) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.16499 ± 0.00091171 (W 0.00311662) | 1.40118 ± 0.00113853 (W 0.00320654) | 1.24084 ± 0.00278426 (W 0.00374905) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 33.7262 ± 0.03997 (W 0.0210486) | 39.0376 ± 0.0661385 (W 0.0466379) | 40.3847 ± 0.258513 (W 0.0458194) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.24024 ± 0.00541071 (W 0.00358495) | 2.08893 ± 0.00487139 (W 0.00480661) | 1.81935 ± 0.00221839 (W 0.00847635) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 62.1892 ± 0.204493 (W 2.46096) | 41.9927 ± 0.0672 (W 0.0542437) | 45.847 ± 0.198115 (W 0.379341) | 🔴 faer-fork 1.48× slower than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.11828 ± 0.00629135 (W 0.00271329) | 1.45017 ± 0.00623876 (W 0.00409775) | 0.906804 ± 0.00425976 (W 0.00858088) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 29.2549 ± 0.0400207 (W 0.0391678) | 26.937 ± 0.0533001 (W 0.0336862) | 20.9248 ± 0.409835 (W 0.104297) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.30999 ± 0.00131738 (W 0.00514073) | 2.18565 ± 0.00746699 (W 0.00697729) | 1.64356 ± 0.00412017 (W 0.00298031) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 56.8118 ± 0.469237 (W 0.122333) | 40.8761 ± 0.0708492 (W 0.238634) | 34.3911 ± 0.0636209 (W 0.0439973) | 🔴 faer-fork 1.39× slower than `faer-upstream` | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.1603 ± 0.0026573 (W 0.00334507) | 1.54093 ± 0.00203846 (W 0.00438818) | 0.788638 ± 0.00670499 (W 0.00398728) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 28.8958 ± 0.060137 (W 0.0398865) | 27.8826 ± 0.0830865 (W 0.0839532) | 15.7827 ± 0.038698 (W 0.0522031) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.975 ± 0.00833147 (W 0.00280134) | 5.98958 ± 0.0373667 (W 0.00654951) | 8.73529 ± 0.0156032 (W 0.0187446) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 278.504 ± 0.157035 (W 2.81171) | 281.114 ± 0.318177 (W 0.429372) | 379.382 ± 0.496529 (W 0.678642) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.83387 ± 0.00695693 (W 0.00321524) | 3.07177 ± 0.00362283 (W 0.00244024) | 3.80745 ± 0.00140423 (W 0.00657651) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 116.539 ± 0.0543833 (W 0.408308) | 122.601 ± 0.902173 (W 0.652977) | 144.202 ± 6.04572 (W 0.496649) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.93783 ± 0.0164482 (W 0.0087685) | 3.67574 ± 0.00296709 (W 0.00565115) | 5.50257 ± 0.0119483 (W 0.0221201) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 194.246 ± 1.97847 (W 2.18719) | 118.082 ± 0.0351799 (W 0.21892) | 138.74 ± 3.64374 (W 0.444161) | 🔴 faer-fork 1.65× slower than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.61871 ± 0.00448899 (W 0.00483452) | 2.42221 ± 0.00903251 (W 0.00620779) | 2.81739 ± 0.0459196 (W 0.0043985) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 93.1323 ± 0.937526 (W 0.744762) | 71.6617 ± 0.0335391 (W 0.048121) | 59.3083 ± 5.17304 (W 0.213366) | 🔴 faer-fork 1.30× slower than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.94497 ± 0.0132115 (W 0.0176899) | 3.65835 ± 0.00602192 (W 0.0347708) | 4.40949 ± 0.126136 (W 0.00563562) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 179.33 ± 3.01624 (W 0.50506) | 106.261 ± 4.3214 (W 0.598501) | 82.6778 ± 0.386865 (W 0.366439) | 🔴 faer-fork 1.69× slower than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.65651 ± 0.00574112 (W 0.0107515) | 2.48515 ± 0.0180036 (W 0.00729159) | 2.31453 ± 0.115114 (W 0.00345674) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 90.6806 ± 0.666692 (W 0.395577) | 69.9081 ± 0.354022 (W 0.465853) | 34.3778 ± 0.202489 (W 0.153509) | 🔴 faer-fork 1.30× slower than `faer-upstream` | 🔴 faer-fork 2.64× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.87369 ± 0.00930151 (W 0.00686142) | 5.87345 ± 0.0108243 (W 0.00292438) | 8.45506 ± 0.0445807 (W 0.0102978) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 266.296 ± 0.333227 (W 0.373727) | 268.723 ± 0.330411 (W 0.452966) | 366.666 ± 6.81427 (W 1.44041) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.71441 ± 0.00448428 (W 0.00383109) | 2.94917 ± 0.00110277 (W 0.002697) | 3.64284 ± 0.0103374 (W 0.00384925) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 104.426 ± 0.12475 (W 0.0662415) | 110.267 ± 0.0664346 (W 0.0621635) | 139.325 ± 6.13323 (W 0.798004) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.80953 ± 0.00884013 (W 0.00563329) | 3.56512 ± 0.00857249 (W 0.0140119) | 5.41651 ± 0.0149066 (W 0.00644647) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 181.112 ± 0.35525 (W 0.268582) | 105.967 ± 0.0578746 (W 0.0848223) | 140.798 ± 6.72296 (W 0.562477) | 🔴 faer-fork 1.71× slower than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.52992 ± 0.0051088 (W 0.00605241) | 2.33168 ± 0.00439807 (W 0.00416338) | 2.79234 ± 0.0131583 (W 0.0032566) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 81.0057 ± 0.184648 (W 0.0801455) | 59.6378 ± 0.232524 (W 0.0341783) | 50.2016 ± 0.0785042 (W 0.138346) | 🔴 faer-fork 1.36× slower than `faer-upstream` | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.83086 ± 0.0112599 (W 0.0240108) | 3.58258 ± 0.00516401 (W 0.0245432) | 4.40366 ± 0.134173 (W 0.0075822) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/4096x256/b1` | 167.638 ± 0.382547 (W 0.191147) | 95.0342 ± 0.640313 (W 0.463741) | 74.8917 ± 1.80135 (W 0.323391) | 🔴 faer-fork 1.76× slower than `faer-upstream` | 🔴 faer-fork 2.24× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.56919 ± 0.00813783 (W 0.00976148) | 2.39181 ± 0.00642482 (W 0.00586366) | 2.2952 ± 0.130513 (W 0.00516479) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 77.6082 ± 0.108301 (W 0.125182) | 57.6762 ± 0.22315 (W 0.325934) | 32.8292 ± 0.444878 (W 0.133941) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 2.36× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.58756 ± 0.001986 (W 0.00235499) | 1.59626 ± 0.000806865 (W 0.00202309) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 48.4124 ± 1.16972 (W 0.0433199) | 48.9647 ± 1.18783 (W 0.05926) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.991215 ± 0.00573408 (W 0.00378263) | 1.13957 ± 0.00295189 (W 0.00209974) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.7898 ± 1.05505 (W 0.0245824) | 27.384 ± 1.06048 (W 0.0214313) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.5043 ± 0.000396045 (W 0.00189296) | 1.51311 ± 0.0108094 (W 0.0039493) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 37.6057 ± 0.072397 (W 0.0908319) | 29.956 ± 0.57853 (W 0.489399) | - | 🔴 faer-fork 1.26× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.975039 ± 0.00696116 (W 0.00293614) | 1.25129 ± 0.00340875 (W 0.00480226) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 22.9105 ± 0.0881568 (W 0.0153016) | 21.7223 ± 0.0698903 (W 0.0220957) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.56913 ± 0.00443757 (W 0.00292535) | 1.62334 ± 0.00679472 (W 0.00503943) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 37.4932 ± 0.0610049 (W 0.119696) | 29.4267 ± 0.0166559 (W 0.0970042) | - | 🔴 faer-fork 1.27× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.01846 ± 0.00362399 (W 0.00306518) | 1.34014 ± 0.00643321 (W 0.00249104) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 23.1983 ± 0.0744166 (W 0.0501022) | 22.9281 ± 0.0322713 (W 0.0626565) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.58512 ± 0.00256502 (W 0.0032579) | 1.59731 ± 0.00434199 (W 0.00253114) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 45.8724 ± 0.198525 (W 0.0308125) | 46.3168 ± 0.257337 (W 0.0439594) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.949978 ± 0.00274833 (W 0.00261749) | 1.1019 ± 0.000656496 (W 0.00211249) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 21.4164 ± 0.0489341 (W 0.0179209) | 24.2174 ± 0.075838 (W 0.0200688) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.51258 ± 0.00172492 (W 0.00248448) | 1.51544 ± 0.00643169 (W 0.00430481) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 34.7119 ± 0.0398 (W 0.0668309) | 25.8903 ± 0.108349 (W 0.0618078) | - | 🔴 faer-fork 1.34× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.930674 ± 0.00309083 (W 0.00187874) | 1.21407 ± 0.00396328 (W 0.00324785) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.2947 ± 0.0429394 (W 0.0148966) | 18.2328 ± 0.137417 (W 0.030069) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.56543 ± 0.0145149 (W 0.00394163) | 1.62693 ± 0.0048507 (W 0.00913206) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 34.5461 ± 0.0911799 (W 0.125687) | 26.4819 ± 0.0200274 (W 0.0939984) | - | 🔴 faer-fork 1.30× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.971689 ± 0.00271939 (W 0.00118493) | 1.30327 ± 0.00530669 (W 0.00417634) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.6061 ± 0.0380498 (W 0.0836896) | 19.4777 ± 0.0296613 (W 0.0610603) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.38672 ± 0.0205672 (W 0.00497881) | 3.39481 ± 0.0155917 (W 0.00438714) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 145.619 ± 0.193817 (W 0.0941588) | 146.416 ± 0.128852 (W 0.166827) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.83474 ± 0.00391263 (W 0.00602571) | 2.00663 ± 0.00639845 (W 0.00529489) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 64.1096 ± 0.0363882 (W 0.0348528) | 67.136 ± 0.0800584 (W 0.0575783) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.78184 ± 0.0059413 (W 0.00331198) | 2.32257 ± 0.00361997 (W 0.00487384) | - | 🔴 faer-fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 102.743 ± 0.216765 (W 0.23521) | 65.5971 ± 0.12372 (W 0.0560108) | - | 🔴 faer-fork 1.57× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.65875 ± 0.00195225 (W 0.00379258) | 1.78789 ± 0.011008 (W 0.00652548) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 52.5656 ± 0.00377312 (W 0.0350459) | 42.0107 ± 0.0669322 (W 0.0437735) | - | 🔴 faer-fork 1.25× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.83531 ± 0.0247032 (W 0.0119715) | 2.40555 ± 0.0105844 (W 0.0131742) | - | 🔴 faer-fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 96.862 ± 0.0812194 (W 0.26933) | 60.7957 ± 0.331779 (W 0.525944) | - | 🔴 faer-fork 1.59× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.70219 ± 0.0018821 (W 0.00369244) | 1.87031 ± 0.00406834 (W 0.00517028) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 51.6317 ± 0.10176 (W 0.102694) | 41.9113 ± 0.0389437 (W 0.266401) | - | 🔴 faer-fork 1.23× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.34506 ± 0.016079 (W 0.00190723) | 3.35206 ± 0.0123549 (W 0.00238998) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 140.252 ± 0.168623 (W 0.109654) | 141.037 ± 0.203551 (W 0.0477732) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.76827 ± 0.00676436 (W 0.00275772) | 1.91341 ± 0.00333662 (W 0.00275967) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 58.419 ± 0.0793347 (W 0.0495072) | 61.4817 ± 0.0322735 (W 0.0409958) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.75679 ± 0.00356653 (W 0.00332497) | 2.29613 ± 0.00919239 (W 0.00359554) | - | 🔴 faer-fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 97.5339 ± 0.211708 (W 0.403319) | 60.1269 ± 0.0396835 (W 0.106436) | - | 🔴 faer-fork 1.62× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.60132 ± 0.00473371 (W 0.0027923) | 1.70255 ± 0.00648467 (W 0.0048339) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 46.9567 ± 0.0626749 (W 0.0353878) | 36.3376 ± 0.064052 (W 0.0654874) | - | 🔴 faer-fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.78811 ± 0.0125212 (W 0.0138436) | 2.37865 ± 0.00843593 (W 0.0127916) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 91.3823 ± 0.113512 (W 0.139114) | 55.4975 ± 0.327984 (W 0.425806) | - | 🔴 faer-fork 1.65× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.64134 ± 0.0025866 (W 0.00280955) | 1.78779 ± 0.00160107 (W 0.00373366) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 45.9613 ± 0.0234956 (W 0.0683904) | 36.5337 ± 0.171617 (W 0.157716) | - | 🔴 faer-fork 1.26× slower than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
