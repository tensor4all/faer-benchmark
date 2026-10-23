# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `1850d9e01dcf0650ed28c7fb7dddcd7752488926`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `4cb1ab5e19cbe878d61d68eaaeeeb11f75ecc3ef`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `7825a9a09dc04acf015177959314846874d1844af60090e1b1d1cd99a5ac1a61`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T13:35:07.204983Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label blocked-dqds-caller-lock-2 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T125347Z-blocked-dqds-caller-lock-2/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.52%, worst 205.60% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 36 of 960 engine cells exceed 5% and carry `!`; median within-process relative SD 0.21%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `svd_thin/n32/b1` | 0.183875 ± 0.000417737 (W 0.00127791) | 0.182753 ± 0.000307702 (W 0.000995121) | 0.178085 ± 0.000290119 (W 0.00140867) | · | · |  |
| `svd_thin/n64/b1` | 0.92763 ± 0.00102565 (W 0.00247322) | 0.925366 ± 0.00447431 (W 0.00379139) | 0.762642 ± 0.00467187 (W 0.00241372) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.2148 ± 0.0389127 (W 0.00183198) | 2.2148 ± 0.0090835 (W 0.00231045) | 1.68766 ± 0.0539466 (W 0.00896283) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.083107 ± 0.000470553 (W 0.000137424) | 0.139903 ± 0.000236616 (W 0.000945495) | 0.064752 ± 0.000675714 (W 0.000108241) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.293922 ± 0.00176242 (W 0.00175115) | 0.517656 ± 0.00101863 (W 0.00189893) | 0.265619 ± 5.02427e-05 (W 0.0014312) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.669257 ± 0.0019234 (W 0.00209913) | 1.18524 ± 0.00178268 (W 0.00306724) | 0.637808 ± 0.00289007 (W 0.00326325) | 🔵 faer-fork 1.77× faster than `faer-upstream` | · |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.184777 ± 0.00113634 (W 0.00138732) | 0.182863 ± 0.000566874 (W 0.00137817) | 0.185769 ± 0.00031642 (W 0.00152364) | · | · |  |
| `svd_thin/n64/b1` | 0.914586 ± 0.00145505 (W 0.00234516) | 0.908416 ± 0.00458027 (W 0.000449124) | 0.666181 ± 0.00194556 (W 0.00244364) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.10186 ± 0.00205118 (W 0.00172387) | 2.09543 ± 0.00137812 (W 0.00216486) | 1.41053 ± 0.00236374 (W 0.00274411) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082525 ± 0.000147852 (W 0.000217386) | 0.139923 ± 0.000642365 (W 0.000308062) | 0.064502 ± 0.000400401 (W 0.00112822) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.295585 ± 0.00193498 (W 0.00217107) | 0.517636 ± 0.002846 (W 0.00142258) | 0.27037 ± 0.000812242 (W 0.00132175) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.666792 ± 0.00141011 (W 0.00197501) | 1.18367 ± 0.00215111 (W 0.00127029) | 0.606818 ± 0.000995143 (W 0.0020926) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.184979 ± 0.00364401 (W 0.00133542) | 0.182994 ± 0.000264614 (W 0.0017197) | 0.187782 ± 0.000382035 (W 0.00151878) | · | · |  |
| `svd_thin/n64/b1` | 0.914858 ± 0.00321117 (W 0.00225402) | 0.918274 ± 0.00607174 (W 0.00270542) | 0.668585 ± 0.00216551 (W 0.00131482) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09748 ± 0.00328812 (W 0.00233067) | 2.11204 ± 0.00368376 (W 0.00216948) | 1.36002 ± 0.0466903 (W 0.00337468) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.083005 ± 0.000399162 (W 0.00111307) | 0.140515 ± 0.000162482 (W 0.00173889) | 0.065083 ± 0.000557727 (W 0.000176548) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.293261 ± 0.00173142 (W 0.001646) | 0.51735 ± 0.00210307 (W 0.00177574) | 0.270207 ± 0.000371201 (W 0.000931705) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.666551 ± 0.000849267 (W 0.00212265) | 1.18256 ± 0.00204548 (W 0.00216016) | 0.599124 ± 0.00248794 (W 0.00187551) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.18647 ± 0.000449189 (W 0.00125438) | 0.184988 ± 0.000315647 (W 0.00123791) | 0.168537 ± 0.000694807 (W 0.0010821) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.972274 ± 0.00191906 (W 0.000630078) | 0.966544 ± 0.00650683 (W 0.00226587) | 0.709663 ± 0.00589922 (W 0.00306357) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.15254 ± 0.0430409 (W 0.00200613) | 2.16037 ± 0.0337452 (W 0.00197979) | 1.63433 ± 0.0488489 (W 0.00740842) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.082666 ± 0.000274287 (W 0.000458411) | 0.142097 ± 0.000548923 (W 0.00123728) | 0.059542 ± 0.000381044 (W 0.000123508) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.297849 ± 0.00149739 (W 0.00214792) | 0.53812 ± 0.000608944 (W 0.0021021) | 0.255359 ± 0.000129786 (W 0.00132762) | 🔵 faer-fork 1.81× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.679125 ± 0.0021086 (W 0.00183335) | 1.19152 ± 0.00109721 (W 0.00188144) | 0.608477 ± 0.0013788 (W 0.00148835) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.186572 ± 0.00114491 (W 0.00100106) | 0.18556 ± 0.000594489 (W 0.00137583) | 0.176161 ± 0.00034651 (W 0.00136566) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.961143 ± 0.00193254 (W 0.00201563) | 0.949499 ± 0.00434888 (W 0.00124259) | 0.645612 ± 0.00285194 (W 0.00229474) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09396 ± 0.00185701 (W 0.00306538) | 2.08945 ± 0.00464274 (W 0.00124853) | 1.38319 ± 0.00286013 (W 0.00161491) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082466 ± 0.000121149 (W 0.000120392) | 0.142878 ± 0.000646461 (W 0.00187135) | 0.059572 ± 0.00015308 (W 0.00119737) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.299281 ± 0.0019931 (W 0.00201182) | 0.539296 ± 0.00217355 (W 0.00162137) | 0.258174 ± 0.00267712 (W 0.00131101) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.676174 ± 0.00106533 (W 0.00158821) | 1.18832 ± 0.00180737 (W 0.00189309) | 0.608307 ± 0.00222081 (W 0.00132688) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.1868 ± 0.00388004 (W 0.00144238) | 0.18639 ± 0.000431548 (W 0.00148588) | 0.178375 ± 0.000199703 (W 0.00128881) | · | · |  |
| `svd_thin/n64/b1` | 0.955753 ± 0.00316369 (W 0.00269797) | 0.958167 ± 0.00130628 (W 0.00258735) | 0.639465 ± 0.00108876 (W 0.00270809) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09539 ± 0.00148997 (W 0.00155633) | 2.10774 ± 0.00321748 (W 0.00249647) | 1.33166 ± 0.00241672 (W 0.00246223) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082906 ± 0.000456023 (W 0.00186884) | 0.142408 ± 0.000192268 (W 0.00141053) | 0.059573 ± 0.000433407 (W 0.000161751) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.297048 ± 0.00082453 (W 0.001889) | 0.539413 ± 0.00202196 (W 0.00167498) | 0.259368 ± 0.00057243 (W 0.00153342) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.67694 ± 0.00151363 (W 0.00181102) | 1.19033 ± 0.000730745 (W 0.00201498) | 0.604284 ± 0.00195209 (W 0.001587) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.236444 ± 0.000455511 (W 0.0017142) | 0.236604 ± 0.000739004 (W 0.00124885) | 0.253298 ± 0.000846501 (W 0.00156967) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22176 ± 0.0030642 (W 0.00216009) | 1.22761 ± 0.00107449 (W 0.00206664) | 1.33964 ± 0.00319966 (W 0.00271967) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.16458 ± 0.0020835 (W 0.00328822) | 3.15838 ± 0.00615296 (W 0.00236728) | 3.48644 ± 0.0051014 (W 0.00292821) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.098976 ± 0.00010116 (W 0.0013729) | 0.160973 ± 0.000162143 (W 0.00106569) | 0.102693 ± 0.121804 (W 0.0012157) | 🔵 faer-fork 1.63× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.405582 ± 0.000990152 (W 0.00159302) | 0.655661 ± 0.00214489 (W 0.00121052) | 0.49334 ± 0.000374636 (W 0.00167221) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.0156 ± 0.000292144 (W 0.000653722) | 1.54226 ± 0.00350292 (W 0.00205992) | 1.37444 ± 0.0349498 (W 0.00155778) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234952 ± 0.000318325 (W 0.00162387) | 0.234962 ± 0.000156666 (W 0.00113284) | 0.262062 ± 0.000317276 (W 0.0012344) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.15278 ± 0.00198032 (W 0.00161039) | 1.15492 ± 0.0015645 (W 0.00115937) | 1.03075 ± 0.000587627 (W 0.00113878) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.83573 ± 0.00222541 (W 0.00321333) | 2.83172 ± 0.00542204 (W 0.00317979) | 2.53032 ± 0.00149245 (W 0.00227714) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099357 ± 0.000324032 (W 0.000217899) | 0.161143 ± 0.000518336 (W 0.00110193) | 0.102093 ± 0.000213903 (W 0.00120154) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.40488 ± 0.00136245 (W 0.0019483) | 0.657926 ± 0.00113479 (W 0.0017782) | 0.490712 ± 0.00207036 (W 0.00183617) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.01225 ± 0.00117746 (W 0.00107365) | 1.53995 ± 0.00060286 (W 0.00193012) | 1.35727 ± 0.00145456 (W 0.00133603) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234671 ± 0.00145778 (W 0.00189589) | 0.234441 ± 0.000608083 (W 0.00201481) | 0.263447 ± 0.000221342 (W 0.00157187) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.14424 ± 0.00166871 (W 0.00179443) | 1.15909 ± 0.00220216 (W 0.00180829) | 1.07174 ± 0.00407621 (W 0.0037746) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.79242 ± 0.00388363 (W 0.00528917) | 2.85953 ± 0.00353077 (W 0.00504466) | 2.34175 ± 0.00259038 (W 0.00305726) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099097 ± 0.000275863 (W 0.00011607) | 0.160963 ± 9.65764e-05 (W 0.00179622) | 0.102413 ± 3.64737e-05 (W 0.00118197) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.405224 ± 0.000918353 (W 0.0015753) | 0.656417 ± 0.0015001 (W 0.00207025) | 0.493686 ± 0.000895813 (W 0.00206404) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.01268 ± 0.00189876 (W 0.00137305) | 1.54039 ± 0.0022886 (W 0.00242719) | 1.39566 ± 0.000942039 (W 0.00764091) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233438 ± 0.000357651 (W 0.0013199) | 0.232957 ± 0.000837989 (W 0.00121996) | 0.249608 ± 0.000393167 (W 0.00195173) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25676 ± 0.00312936 (W 0.00217493) | 1.25904 ± 0.00190815 (W 0.00160009) | 1.31195 ± 0.00235569 (W 0.00269232) | · | · |  |
| `svd_thin/n96/b1` | 3.1219 ± 0.00345549 (W 0.00298362) | 3.12152 ± 0.00240173 (W 0.00167191) | 3.42235 ± 0.00375367 (W 0.00481622) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099547 ± 0.000230565 (W 0.000156848) | 0.158577 ± 0.000668677 (W 0.00115102) | 0.100709 ± 0.000125033 (W 0.000148826) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.40319 ± 0.00039113 (W 0.00207886) | 0.632783 ± 0.000632769 (W 0.00197553) | 0.481574 ± 0.00105455 (W 0.00162162) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.01181 ± 0.000837007 (W 0.00120343) | 1.51546 ± 0.00247363 (W 0.00291578) | 1.33812 ± 0.00155417 (W 0.00161102) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.232528 ± 0.00038864 (W 0.00162131) | 0.232037 ± 0.000182083 (W 0.00162143) | 0.257192 ± 0.00015233 (W 0.00168298) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.18285 ± 0.00284024 (W 0.00138144) | 1.18633 ± 0.00144389 (W 0.00188983) | 1.01223 ± 0.00144667 (W 0.000825273) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.79723 ± 0.00232766 (W 0.00286362) | 2.79144 ± 0.00272187 (W 0.00153121) | 2.50817 ± 0.00322077 (W 0.00330104) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.100058 ± 0.00018695 (W 0.0010215) | 0.159029 ± 0.000369013 (W 0.000378248) | 0.100729 ± 0.00030679 (W 0.000946995) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.402035 ± 0.000983967 (W 0.00216538) | 0.631145 ± 0.000893685 (W 0.00173731) | 0.480275 ± 0.00083968 (W 0.00172696) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.00912 ± 0.00069879 (W 0.000920828) | 1.51381 ± 0.00401813 (W 0.00226445) | 1.3364 ± 0.00270224 (W 0.00138394) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.23328 ± 0.000715545 (W 0.00206399) | 0.231857 ± 0.000586789 (W 0.00147182) | 0.259186 ± 0.000217077 (W 0.00192575) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.17485 ± 0.00234788 (W 0.00179267) | 1.18837 ± 0.00169511 (W 0.00173056) | 0.9751 ± 0.00306019 (W 0.00203389) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.74817 ± 0.0042223 (W 0.00465055) | 2.82002 ± 0.00227561 (W 0.00349453) | 2.33147 ± 0.00307949 (W 0.0018227) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.099517 ± 0.000286758 (W 0.000156091) | 0.158668 ± 0.000450011 (W 0.00126836) | 0.100679 ± 8.0829e-05 (W 0.00169114) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.403047 ± 0.0009572 (W 0.00200925) | 0.631259 ± 0.00119434 (W 0.00183148) | 0.480011 ± 0.00135873 (W 0.00160803) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.00892 ± 0.0011493 (W 0.00105244) | 1.51119 ± 0.00348184 (W 0.0018437) | 1.33676 ± 0.00131728 (W 0.00132482) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.138561 ± 0.0040114 (W 0.0011356) | 0.137749 ± 0.0043807 (W 0.00131434) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.539332 ± 0.00100036 (W 0.00183661) | 0.536672 ± 0.00143332 (W 0.00136148) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56697 ± 0.00222921 (W 0.00185939) | 1.56802 ± 0.00389239 (W 0.00241279) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.06903 ± 0.00150751 (W 0.00102275) | 0.110698 ± 0.00040939 (W 0.000135997) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.231384 ± 0.00081669 (W 0.00136605) | 0.400241 ± 0.000641982 (W 0.00172872) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.513414 ± 0.00218223 (W 0.00143388) | 0.884541 ± 0.000765092 (W 0.00154066) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.138119 ± 0.0019783 (W 0.000442629) | 0.137188 ± 0.0018394 (W 0.000380312) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.535434 ± 0.00270798 (W 0.00153688) | 0.544742 ± 0.00291005 (W 0.00260338) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51316 ± 0.00217052 (W 0.00251659) | 1.53232 ± 0.0026927 (W 0.00199325) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068369 ± 0.000972185 (W 0.00102312) | 0.110257 ± 0.000205525 (W 0.000288975) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.231115 ± 0.000732211 (W 0.00109829) | 0.400244 ± 0.000636127 (W 0.00175276) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.514807 ± 0.00150546 (W 0.00148035) | 0.885539 ± 0.00231807 (W 0.00206992) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137408 ± 0.000330137 (W 0.00147518) | 0.137127 ± 0.000621589 (W 0.00165692) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.533645 ± 0.00416275 (W 0.00146447) | 0.549766 ± 0.00349967 (W 0.00143301) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.51775 ± 0.00288815 (W 0.00225268) | 1.5684 ± 0.000939001 (W 0.0041232) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.06879 ± 0.00056667 (W 0.000294491) | 0.110518 ± 0.0003505 (W 0.00159605) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.231786 ± 0.00026234 (W 0.00119876) | 0.401404 ± 0.000852846 (W 0.00190355) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.514706 ± 0.00517203 (W 0.00178254) | 0.887266 ± 0.00476215 (W 0.00162059) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.147507 ± 0.00483032 (W 0.00123367) | 0.147147 ± 0.0048626 (W 0.00139891) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.54124 ± 0.000510187 (W 0.00206207) | 0.542288 ± 0.00164264 (W 0.00215051) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56107 ± 0.00151991 (W 0.00333136) | 1.56614 ± 0.00321803 (W 0.00181373) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.070112 ± 0.000499176 (W 0.00117969) | 0.110298 ± 0.000336711 (W 0.000174626) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.234112 ± 0.000958449 (W 0.0015193) | 0.401585 ± 0.000389685 (W 0.00142559) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.518302 ± 0.00248718 (W 0.00171112) | 0.869268 ± 0.0015325 (W 0.00140338) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146755 ± 0.000569574 (W 0.000220964) | 0.146476 ± 0.00195961 (W 0.00014888) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.539793 ± 0.00307269 (W 0.00166639) | 0.547609 ± 0.0212031 (W 0.00199519) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.51197 ± 0.00330578 (W 0.00176691) | 1.53099 ± 0.00138128 (W 0.00198904) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.070001 ± 0.000314325 (W 0.00133527) | 0.109756 ± 0.000185831 (W 0.00017859) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.23424 ± 0.0002255 (W 0.00181637) | 0.402057 ± 0.00133497 (W 0.00169043) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.520137 ± 0.00093069 (W 0.00193064) | 0.870773 ± 0.00155933 (W 0.000721984) | - | 🔵 faer-fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.147308 ± 0.00317752 (W 0.0015258) | 0.146625 ± 0.000728534 (W 0.00136727) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.531357 ± 0.00154087 (W 0.00181179) | 0.549641 ± 0.00102754 (W 0.00147413) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.50987 ± 0.000602357 (W 0.00289596) | 1.56608 ± 0.0038427 (W 0.00432147) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.069821 ± 0.000316223 (W 0.000200659) | 0.109766 ± 0.00016328 (W 0.00134137) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.234452 ± 0.000462195 (W 0.00129678) | 0.401817 ± 0.0010929 (W 0.00207813) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.520257 ± 0.00425243 (W 0.00158118) | 0.869452 ± 0.00557047 (W 0.00144577) | - | 🔵 faer-fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170389 ± 0.000602314 (W 0.00129516) | 0.172345 ± 0.000349627 (W 0.0012746) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.682261 ± 0.00210305 (W 0.00183254) | 0.689825 ± 0.00238089 (W 0.000947919) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.02813 ± 0.0023419 (W 0.00122056) | 2.04092 ± 0.0037847 (W 0.00130221) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077726 ± 0.000657588 (W 0.00163035) | 0.119795 ± 0.000623503 (W 0.00110617) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.287239 ± 0.00451535 (W 0.00153316) | 0.459222 ± 0.00503505 (W 0.00166699) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.687666 ± 0.00291993 (W 0.00141701) | 1.04983 ± 0.00206238 (W 0.00131) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.171311 ± 0.00117256 (W 0.00145357) | 0.172284 ± 0.00129793 (W 0.0014542) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.64498 ± 0.00439218 (W 0.00180187) | 0.651593 ± 0.00458008 (W 0.00172173) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.83091 ± 0.00608068 (W 0.00210176) | 1.849 ± 0.00372029 (W 0.00335607) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077205 ± 0.000261094 (W 7.90569e-05) | 0.119464 ± 0.000222803 (W 0.00109695) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.285718 ± 0.000528604 (W 0.00188767) | 0.45783 ± 0.000679541 (W 0.00168816) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.687095 ± 0.00779651 (W 0.00143394) | 1.05003 ± 0.00810693 (W 0.00118077) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.170039 ± 0.000316893 (W 0.00165405) | 0.172213 ± 0.000852714 (W 0.00147437) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.638498 ± 0.001218 (W 0.0016042) | 0.654302 ± 0.00146552 (W 0.00214065) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.80845 ± 0.00180711 (W 0.00194887) | 1.85745 ± 0.00442101 (W 0.00358599) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077695 ± 0.000289293 (W 0.00155349) | 0.120115 ± 0.000888242 (W 0.00110891) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.285236 ± 0.000116337 (W 0.00199948) | 0.457498 ± 0.00170163 (W 0.00187166) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.683983 ± 0.0018575 (W 0.00210312) | 1.04849 ± 0.00265759 (W 0.00101091) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172373 ± 0.000715757 (W 0.00147203) | 0.173896 ± 0.000470788 (W 0.00127606) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.690787 ± 0.00314811 (W 0.0017391) | 0.699412 ± 0.00339299 (W 0.00157849) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04428 ± 0.00230089 (W 0.00194669) | 2.05918 ± 0.00424209 (W 0.00241764) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.078868 ± 0.000345789 (W 0.000121009) | 0.119444 ± 0.00035104 (W 0.00124263) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.285486 ± 0.00452253 (W 0.00151282) | 0.453511 ± 0.00453061 (W 0.00177113) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.693929 ± 0.00184878 (W 0.00160869) | 1.04939 ± 0.00321573 (W 0.000736075) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172113 ± 0.00101091 (W 0.00148925) | 0.173988 ± 0.0011721 (W 0.00148691) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.654838 ± 0.00269499 (W 0.0017279) | 0.661221 ± 0.00409156 (W 0.00165311) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.84751 ± 0.00212403 (W 0.0025415) | 1.86441 ± 0.00300732 (W 0.00171842) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.078388 ± 0.000234706 (W 0.00126725) | 0.119225 ± 0.000312929 (W 0.00114402) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.283892 ± 0.000564831 (W 0.00140096) | 0.452032 ± 0.001437 (W 0.00153661) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.69014 ± 0.0079944 (W 0.00137549) | 1.04966 ± 0.00699048 (W 0.000749874) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172143 ± 0.00107868 (W 0.00121266) | 0.175361 ± 0.00413467 (W 0.00148234) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.647706 ± 0.000964247 (W 0.00203203) | 0.662884 ± 0.00114175 (W 0.00163775) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.82306 ± 0.00178608 (W 0.00237684) | 1.87726 ± 0.00642045 (W 0.00274215) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.077927 ± 4.58258e-05 (W 0.000126358) | 0.118984 ± 0.000337112 (W 0.00115969) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.283745 ± 0.000302769 (W 0.00210124) | 0.453792 ± 0.00284496 (W 0.00189663) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.689239 ± 0.00128366 (W 0.00167986) | 1.04807 ± 0.00267392 (W 0.000425027) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.60299 ± 0.0134669 (W 0.00616374) | 3.69367 ± 0.00658778 (W 0.00389578) | 3.39531 ± 0.00759309 (W 0.0170259) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 17.0544 ± 0.0447517 (W 0.0277097) | 18.5759 ± 0.0375404 (W 0.0351086) | 18.1048 ± 0.0537023 (W 0.0286111) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.985 ± 0.183333 (W 0.10604) | 105.91 ± 0.477015 (W 0.0682778) | 117.121 ± 0.193001 (W 0.186481) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.25882 ± 0.0110992 (W 0.00483731) | 2.69964 ± 0.00720905 (W 0.00324346) | 1.19694 ± 0.0242255 (W 0.00177564) | 🔵 faer-fork 2.14× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.55999 ± 0.00997302 (W 0.00690743) | 12.487 ± 0.0198569 (W 0.0119171) | 6.96903 ± 0.127462 (W 0.00607097) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 41.623 ± 0.0610012 (W 0.0883702) | 66.344 ± 0.152234 (W 0.0370238) | 47.8232 ± 0.705815 (W 0.0597097) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.71574 ± 0.015952 (W 0.0155514) | 2.79869 ± 0.0130731 (W 0.0134516) | 2.6338 ± 0.00603836 (W 0.00410216) | · | · |  |
| `svd_thin/n256/b1` | 11.816 ± 0.0365251 (W 0.030384) | 13.2874 ± 0.0142946 (W 0.0119504) | 12.4723 ± 0.0422439 (W 0.0319954) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 45.6038 ± 0.171526 (W 1.27626) | 55.9907 ± 0.119826 (W 0.111591) | 57.7153 ± 0.55511 (W 0.0846707) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.25935 ± 0.0031992 (W 0.00183945) | 2.18767 ± 0.00661095 (W 0.00355851) | 1.13568 ± 0.0104698 (W 0.00246102) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.4406 ± 0.025002 (W 0.00842036) | 10.4799 ± 0.0216517 (W 0.0107142) | 6.12218 ± 0.12782 (W 0.0110024) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 24.4013 ± 0.0159148 (W 0.0408042) | 41.9943 ± 0.025429 (W 0.0506186) | 25.765 ± 0.762866 (W 0.0301757) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.6903 ± 0.0127749 (W 0.00638221) | 2.82129 ± 0.00438464 (W 0.00509397) | 2.50993 ± 0.00898536 (W 0.00600985) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 11.3689 ± 0.026032 (W 0.0164334) | 13.2949 ± 0.013139 (W 0.0163743) | 11.5119 ± 0.0217712 (W 0.0141808) | 🔵 faer-fork 1.17× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 38.5563 ± 0.0506507 (W 0.245697) | 52.5455 ± 0.171115 (W 0.133865) | 48.3535 ± 0.0152459 (W 0.0579949) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.25752 ± 0.0033429 (W 0.0028878) | 2.18888 ± 0.00526574 (W 0.00291134) | 1.11616 ± 0.012924 (W 0.00507037) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.48139 ± 0.009297 (W 0.00718878) | 10.5675 ± 0.0132229 (W 0.00749294) | 5.9586 ± 0.199947 (W 0.00643554) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 22.78 ± 0.0686292 (W 0.0223525) | 40.3486 ± 0.0783757 (W 0.0351982) | 22.3677 ± 0.622833 (W 0.0159079) | 🔵 faer-fork 1.77× faster than `faer-upstream` | · | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.59579 ± 0.0104759 (W 0.00323174) | 3.69178 ± 0.010817 (W 0.00475717) | 3.31107 ± 0.00326918 (W 0.0115654) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 16.9912 ± 0.0335053 (W 0.0186063) | 18.4152 ± 0.0330212 (W 0.0121788) | 17.71 ± 0.0580224 (W 0.0283507) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 94.2441 ± 0.537681 (W 0.0987208) | 105.266 ± 0.395028 (W 0.081745) | 116.408 ± 0.338965 (W 0.115392) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.23765 ± 0.00150141 (W 0.00197254) | 2.61806 ± 0.00571698 (W 0.0014262) | 1.1583 ± 0.00338802 (W 0.00203311) | 🔵 faer-fork 2.12× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.43092 ± 0.00771744 (W 0.00401989) | 12.3135 ± 0.0247602 (W 0.00876254) | 6.82228 ± 0.0194787 (W 0.00697431) | 🔵 faer-fork 1.91× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.5165 ± 0.0693977 (W 0.0267837) | 65.7078 ± 0.165667 (W 0.0949924) | 47.5748 ± 0.371318 (W 0.0330763) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.67198 ± 0.0131716 (W 0.0145366) | 2.77523 ± 0.0127208 (W 0.0136115) | 2.61638 ± 0.00270612 (W 0.00822021) | · | · |  |
| `svd_thin/n256/b1` | 11.6351 ± 0.043101 (W 0.0332049) | 13.1801 ± 0.00735109 (W 0.0109594) | 12.4421 ± 0.0578846 (W 0.0242796) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 44.4793 ± 1.25836 (W 1.25627) | 54.9169 ± 0.0159068 (W 0.0429798) | 58.6522 ± 0.332098 (W 0.0624865) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.23905 ± 0.00252295 (W 0.00189297) | 2.11795 ± 0.00743463 (W 0.00176413) | 1.14052 ± 0.003561 (W 0.00197286) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.32681 ± 0.0184941 (W 0.00645435) | 10.326 ± 0.0216471 (W 0.0120174) | 6.14702 ± 0.0323676 (W 0.00884906) | 🔵 faer-fork 1.63× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 23.3713 ± 0.00971552 (W 0.0172853) | 41.0111 ± 0.0711077 (W 0.0367181) | 25.8013 ± 0.126188 (W 0.0187455) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.65375 ± 0.0012574 (W 0.00503066) | 2.7945 ± 0.00227051 (W 0.00394892) | 2.48208 ± 0.0106688 (W 0.00473301) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 11.283 ± 0.0102003 (W 0.027527) | 13.191 ± 0.0138623 (W 0.0261966) | 11.5491 ± 0.0245261 (W 0.0189802) | 🔵 faer-fork 1.17× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 37.5666 ± 0.0998859 (W 0.0859588) | 51.6572 ± 0.0498643 (W 0.0880473) | 49.6332 ± 0.633289 (W 0.0758836) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.23891 ± 0.000609265 (W 0.0016336) | 2.11851 ± 0.00327467 (W 0.00176388) | 1.12595 ± 0.0085255 (W 0.00306987) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.34413 ± 0.0202267 (W 0.00777264) | 10.4088 ± 0.0250438 (W 0.00871228) | 5.99303 ± 0.037294 (W 0.0102957) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 21.7298 ± 0.0423474 (W 0.028772) | 39.3505 ± 0.105042 (W 0.0480965) | 22.3592 ± 0.0948258 (W 0.0157111) | 🔵 faer-fork 1.81× faster than `faer-upstream` | · |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.60657 ± 0.00830222 (W 0.00208829) | 5.84914 ± 0.0187761 (W 0.00905908) | 7.04363 ± 0.0980999 (W 0.0207692) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 32.8732 ± 0.188588 (W 0.0479886) | 34.9705 ± 0.160588 (W 0.0605127) | 43.7713 ± 0.31798 (W 0.0567795) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 208.526 ± 0.738232 (W 0.391775) | 214.769 ± 0.205776 (W 0.395462) | 279.298 ± 1.21816 (W 0.583034) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.05399 ± 0.00891265 (W 0.00303438) | 3.55916 ± 0.00575088 (W 0.00454056) | 2.77295 ± 0.00280657 (W 0.00324305) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.734 ± 0.0256491 (W 0.0213964) | 20.0727 ± 0.025573 (W 0.0322228) | 18.1835 ± 0.0723359 (W 0.0140366) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 94.2743 ± 0.161964 (W 0.0917239) | 115.117 ± 0.0550634 (W 0.178784) | 122.794 ± 0.569618 (W 0.111362) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.94043 ± 0.00789961 (W 0.0153534) | 4.17323 ± 0.0136731 (W 0.0114096) | 4.14587 ± 0.00174154 (W 0.00712213) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.3034 ± 0.0162689 (W 0.022136) | 22.248 ± 0.105987 (W 0.0758013) | 21.2371 ± 0.0403263 (W 0.0351903) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 82.7881 ± 1.14493 (W 1.33114) | 88.9501 ± 0.216382 (W 0.937869) | 114.885 ± 0.729033 (W 0.394461) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.04865 ± 0.00478086 (W 0.00273332) | 3.08228 ± 0.00373897 (W 0.00612868) | 2.0226 ± 0.00515297 (W 0.00616933) | 🔵 faer-fork 1.50× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.6833 ± 0.0365063 (W 0.0258807) | 16.9438 ± 0.098324 (W 0.0156332) | 11.1177 ± 0.014597 (W 0.0290679) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 45.5095 ± 0.114195 (W 0.0497974) | 59.207 ± 0.0797127 (W 0.0478483) | 56.4425 ± 0.0439688 (W 0.147838) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.76248 ± 0.0045673 (W 0.00330002) | 4.17144 ± 0.0101315 (W 0.00539945) | 3.6452 ± 0.00239497 (W 0.00688637) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.8076 ± 0.0461278 (W 0.0355164) | 21.7622 ± 0.214513 (W 0.0648161) | 17.2789 ± 0.0275646 (W 0.0202819) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 62.3733 ± 0.0584889 (W 0.51863) | 75.5533 ± 0.329297 (W 0.328996) | 84.6806 ± 5.6922 (W 0.386906) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.04717 ± 0.00164243 (W 0.00381418) | 3.09353 ± 0.0057169 (W 0.0341608) | 1.91218 ± 0.00186713 (W 0.00484226) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.5272 ± 0.0262051 (W 0.0294139) | 16.835 ± 0.0503126 (W 0.0247699) | 9.70527 ± 0.0740057 (W 0.0245079) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 37.9898 ± 0.0769819 (W 0.0358809) | 52.4304 ± 0.239084 (W 0.0634455) | 43.2725 ± 0.179436 (W 0.0657159) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.57161 ± 0.0382332 (W 0.00266427) | 5.82061 ± 0.0230308 (W 0.00944908) | 6.96667 ± 0.110754 (W 0.00956834) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 32.6657 ± 0.100916 (W 0.0367484) | 34.6687 ± 0.0527399 (W 0.0329094) | 45.509 ± 1.37891 (W 0.129506) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 207.301 ± 0.584483 (W 0.14883) | 213.735 ± 0.267179 (W 0.168844) | 309.462 ± 21.6124 (W 0.260344) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.03034 ± 0.00602616 (W 0.00425145) | 3.54004 ± 0.00532469 (W 0.00251046) | 2.7182 ± 0.00652458 (W 0.00418081) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.4747 ± 0.0267769 (W 0.0150113) | 19.7857 ± 0.0449936 (W 0.0205989) | 19.7415 ± 1.44971 (W 0.111008) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 93.2123 ± 0.758582 (W 0.47077) | 113.91 ± 0.307715 (W 0.182788) | 155.702 ± 20.2474 (W 0.153365) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.67× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.92559 ± 0.00835201 (W 0.015231) | 4.1505 ± 0.0125155 (W 0.0156276) | 4.11906 ± 0.0058828 (W 0.00831236) | 🔵 faer-fork 1.06× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 20.0552 ± 0.0351662 (W 0.0293482) | 22.0987 ± 0.0769742 (W 0.0264914) | 22.2064 ± 0.647977 (W 0.0303381) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 79.595 ± 1.22662 (W 0.097282) | 87.7907 ± 0.128452 (W 0.0520622) | 123.254 ± 0.224778 (W 0.1068) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.01744 ± 0.00403864 (W 0.00210551) | 3.05077 ± 0.00418737 (W 0.00417388) | 2.01041 ± 0.00401564 (W 0.00289099) | 🔵 faer-fork 1.51× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.4397 ± 0.0585055 (W 0.0183346) | 16.6921 ± 0.14013 (W 0.0199122) | 12.0641 ± 0.570705 (W 0.0189706) | 🔵 faer-fork 1.34× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/n512/b1` | 44.3709 ± 0.104628 (W 0.0443153) | 58.1917 ± 0.044157 (W 0.0592452) | 64.8976 ± 5.12828 (W 0.0950634) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.75105 ± 0.0154377 (W 0.00419685) | 4.15841 ± 0.00392519 (W 0.00762133) | 3.63964 ± 0.00153064 (W 0.00842723) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.5717 ± 0.0413647 (W 0.0320519) | 21.7243 ± 0.126478 (W 0.0354934) | 17.5032 ± 0.0879731 (W 0.0243665) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.4049 ± 0.125671 (W 0.117445) | 74.8005 ± 0.112254 (W 0.324698) | 85.6252 ± 2.11401 (W 0.0735459) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.0153 ± 0.00266408 (W 0.00406337) | 3.05862 ± 0.00383387 (W 0.00428124) | 1.91449 ± 0.0107008 (W 0.00444596) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.3146 ± 0.0360706 (W 0.0285495) | 16.6584 ± 0.192304 (W 0.03213) | 9.99807 ± 0.0320387 (W 0.00956979) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 36.9783 ± 0.0382713 (W 0.0533267) | 51.4802 ± 0.176903 (W 0.0392152) | 46.0159 ± 0.493138 (W 0.020184) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.326 ± 0.0242662 (W 0.00247116) | 2.33053 ± 0.0238232 (W 0.00394466) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.76 ± 0.0104075 (W 0.00666389) | 11.2424 ± 0.0186274 (W 0.0135015) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 55.4899 ± 0.148419 (W 0.0490321) | 61.1973 ± 0.267959 (W 0.0581722) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.922541 ± 0.00339158 (W 0.00161231) | 1.70718 ± 0.00093526 (W 0.00258491) | - | 🔵 faer-fork 1.85× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.30129 ± 0.00870577 (W 0.00340655) | 7.8584 ± 0.0550227 (W 0.00977953) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.8406 ± 0.0718008 (W 0.0116282) | 40.2194 ± 0.160423 (W 0.0203743) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.8149 ± 0.0120195 (W 0.00744717) | 1.82462 ± 0.00725872 (W 0.0100625) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.94863 ± 0.00519099 (W 0.063678) | 8.47072 ± 0.0655239 (W 0.0614142) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 29.0318 ± 0.102015 (W 0.901094) | 35.6549 ± 0.215783 (W 0.0460788) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.924179 ± 0.00182151 (W 0.000743971) | 1.43221 ± 0.00283618 (W 0.00166671) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.26324 ± 0.0132392 (W 0.00501695) | 6.67585 ± 0.0251777 (W 0.0111642) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 17.1907 ± 0.0420475 (W 0.0357773) | 27.7545 ± 0.0513093 (W 0.0263387) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.79062 ± 0.00727423 (W 0.00382142) | 1.98277 ± 0.0149438 (W 0.0140568) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.68223 ± 0.0355103 (W 0.0222236) | 8.7366 ± 0.00614021 (W 0.0153742) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 26.6511 ± 0.119214 (W 0.0292997) | 34.5052 ± 0.0505143 (W 0.0486663) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.923717 ± 0.00178026 (W 0.000394236) | 1.43454 ± 0.00517712 (W 0.00300696) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.31845 ± 0.00816214 (W 0.0115728) | 6.71766 ± 0.032045 (W 0.00978169) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.5386 ± 0.0354014 (W 0.0171319) | 27.0258 ± 0.0826992 (W 0.0321562) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.33942 ± 0.0286327 (W 0.00307484) | 2.34184 ± 0.0310389 (W 0.00277702) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.7246 ± 0.0105661 (W 0.0115423) | 11.2216 ± 0.0362401 (W 0.0148524) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 54.7844 ± 0.167974 (W 0.0271528) | 60.7822 ± 0.198016 (W 0.40088) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.917602 ± 0.00162084 (W 0.00145003) | 1.67376 ± 0.000788404 (W 0.00215776) | - | 🔵 faer-fork 1.82× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.19252 ± 0.00758316 (W 0.00375155) | 7.71787 ± 0.0505415 (W 0.0126962) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.3696 ± 0.10066 (W 0.0175309) | 39.6577 ± 0.127214 (W 0.0515791) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.82052 ± 0.00342027 (W 0.0121777) | 1.83307 ± 0.0126114 (W 0.00916908) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.77821 ± 0.0658149 (W 0.0708571) | 8.47296 ± 0.0528932 (W 0.0632161) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 30.3808 ± 0.997591 (W 1.05366) | 35.1451 ± 0.193426 (W 0.0317492) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 0.91672 ± 0.00122067 (W 0.000638492) | 1.40652 ± 0.000806457 (W 0.00404915) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.14921 ± 0.00771575 (W 0.00830254) | 6.51109 ± 0.0315016 (W 0.00775158) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.6789 ± 0.0174905 (W 0.0287603) | 27.1944 ± 0.0430375 (W 0.0318191) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 1.79898 ± 0.0061545 (W 0.0198169) | 1.98297 ± 0.0218215 (W 0.00727345) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.65645 ± 0.0184435 (W 0.0206561) | 8.73113 ± 0.0168045 (W 0.0312144) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 26.2935 ± 0.0470615 (W 0.0308204) | 34.0434 ± 0.0746532 (W 0.0767823) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.918953 ± 0.00139952 (W 0.00209888) | 1.4084 ± 0.00329949 (W 0.00616986) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.20583 ± 0.0146156 (W 0.0127917) | 6.56623 ± 0.0272015 (W 0.00518804) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.0114 ± 0.0227915 (W 0.0270943) | 26.5235 ± 0.0735387 (W 0.0165733) | - | 🔵 faer-fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.28769 ± 0.0252445 (W 0.00311411) | 3.36787 ± 0.0145037 (W 0.00328492) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 18.4517 ± 0.0340378 (W 0.0207815) | 19.4817 ± 0.0168412 (W 0.0109375) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 111.973 ± 0.118376 (W 0.247991) | 121.579 ± 0.264751 (W 0.0695814) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.32082 ± 0.00533615 (W 0.00383038) | 2.13583 ± 0.0030426 (W 0.00212989) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.58425 ± 0.00997224 (W 0.0304533) | 11.4709 ± 0.0101414 (W 0.0180146) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 49.597 ± 0.194906 (W 0.205713) | 68.6191 ± 0.153152 (W 0.0620519) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.41358 ± 0.0198257 (W 0.00895661) | 2.50725 ± 0.00560142 (W 0.00627175) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.9705 ± 0.058676 (W 0.0508228) | 13.1625 ± 0.0459883 (W 0.0543127) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 47.6516 ± 0.773373 (W 0.976328) | 57.8912 ± 0.314284 (W 0.0634177) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.31906 ± 0.00657428 (W 0.00247963) | 1.85858 ± 0.00506068 (W 0.00313727) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.08897 ± 0.0113681 (W 0.0181105) | 9.85772 ± 0.0327671 (W 0.0133261) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 26.8949 ± 0.342841 (W 0.0660074) | 41.349 ± 0.203419 (W 0.0249759) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.33819 ± 0.00504878 (W 0.00757353) | 2.52402 ± 0.00186232 (W 0.0086041) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2518 ± 0.0340545 (W 0.0146355) | 13.0339 ± 0.0498651 (W 0.0390508) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 38.6976 ± 0.070151 (W 0.0420102) | 52.1741 ± 0.27977 (W 0.205526) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.31773 ± 0.0116472 (W 0.00207972) | 1.86098 ± 0.00782413 (W 0.00182312) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.10141 ± 0.0239137 (W 0.0305925) | 9.95494 ± 0.0173848 (W 0.016785) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 24.1362 ± 0.0976641 (W 0.0295115) | 38.7158 ± 0.0341564 (W 0.0315427) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.27814 ± 0.0315794 (W 0.00407997) | 3.37958 ± 0.0102514 (W 0.00283369) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 18.2909 ± 0.0244069 (W 0.0199637) | 19.3208 ± 0.0341974 (W 0.0252291) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 110.915 ± 0.118357 (W 0.184535) | 120.641 ± 0.0551426 (W 0.134202) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30265 ± 0.00208242 (W 0.0019057) | 2.11256 ± 0.00325935 (W 0.0021776) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.4352 ± 0.0161565 (W 0.0178852) | 11.3103 ± 0.00695098 (W 0.0139075) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 48.4217 ± 0.283575 (W 0.0437129) | 67.7783 ± 0.201524 (W 0.0254632) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.39731 ± 0.0109752 (W 0.00691252) | 2.48539 ± 0.00634777 (W 0.00760427) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.8898 ± 0.0312673 (W 0.0424968) | 13.0093 ± 0.0693287 (W 0.0505449) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 46.0626 ± 0.935162 (W 0.988989) | 56.8061 ± 0.262123 (W 0.042012) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29967 ± 0.00730228 (W 0.00150314) | 1.83967 ± 0.0372057 (W 0.00532155) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.95343 ± 0.0135554 (W 0.017242) | 9.74639 ± 0.0311317 (W 0.011013) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 25.7534 ± 0.0224552 (W 0.0340492) | 40.2447 ± 0.500807 (W 0.0318398) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.31741 ± 0.000702614 (W 0.00605843) | 2.50057 ± 0.00702505 (W 0.00735997) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.0701 ± 0.0264738 (W 0.0217537) | 12.9194 ± 0.0674959 (W 0.0315514) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 38.0071 ± 0.0700367 (W 0.0292234) | 52.5713 ± 0.247642 (W 0.404605) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30079 ± 0.0100729 (W 0.00177904) | 1.84275 ± 0.0101656 (W 0.00246436) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.95719 ± 0.0112924 (W 0.0165409) | 9.83182 ± 0.023364 (W 0.0108251) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.2347 ± 0.0716244 (W 0.0193457) | 37.7966 ± 0.028492 (W 0.0315199) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.50105 ± 0.00360814 (W 0.00448494) | 2.50839 ± 0.00271783 (W 0.00307237) | 3.05596 ± 0.0086072 (W 0.00487887) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 86.7125 ± 0.0957809 (W 0.137462) | 88.0801 ± 0.219205 (W 0.366553) | 120.644 ± 0.2301 (W 0.256258) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.24562 ± 0.00485986 (W 0.00491832) | 1.49225 ± 0.00189082 (W 0.0042197) | 1.38894 ± 0.158691 (W 0.00509476) | 🔵 faer-fork 1.20× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 39.7252 ± 0.10608 (W 0.0730338) | 44.7962 ± 0.105837 (W 0.0816165) | 47.0333 ± 3.52497 (W 0.206065) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.92925 ± 0.0073633 (W 0.00564214) | 2.15853 ± 0.0129762 (W 0.00258764) | 1.89239 ± 0.00586617 (W 0.00370926) | 🔵 faer-fork 1.12× faster than `faer-upstream` | · |  |
| `svd_thin/4096x256/b1` | 45.1169 ± 2.60298 (W 1.94958) | 47.736 ± 0.125718 (W 0.527643) | 48.606 ± 0.103267 (W 0.0721107) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.04023 ± 0.011241 (W 0.00450807) | 1.54122 ± 0.0116144 (W 0.00437903) | 0.961655 ± 0.138511 (W 0.0102197) | 🔵 faer-fork 1.48× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 25.3278 ± 0.0352919 (W 0.0405359) | 32.8416 ± 0.0205536 (W 0.0491298) | 22.674 ± 2.89209 (W 0.231299) | 🔵 faer-fork 1.30× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.93659 ± 0.00782639 (W 0.00491147) | 2.24456 ± 0.00968397 (W 0.00607634) | 1.68219 ± 0.0148564 (W 0.00275929) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 38.9487 ± 1.31374 (W 2.34924) | 46.7205 ± 0.186046 (W 1.13146) | 36.2061 ± 0.261341 (W 0.0750617) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.04816 ± 0.0141342 (W 0.00698384) | 1.62066 ± 0.00744499 (W 0.00733522) | 0.80998 ± 0.195257 (W 0.00398702) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 23.3991 ± 0.142331 (W 0.0679724) | 33.6884 ± 0.0270136 (W 0.0874136) | 16.7624 ± 2.44787 (W 0.0475614) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.45748 ± 0.00736688 (W 0.00359096) | 2.45704 ± 0.0103298 (W 0.00427234) | 2.817 ± 0.0142974 (W 0.00368331) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 81.3694 ± 0.191759 (W 0.118712) | 82.8311 ± 0.0657602 (W 0.0630328) | 109.515 ± 0.553428 (W 0.41191) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.17265 ± 0.00355951 (W 0.00495849) | 1.41224 ± 0.00240961 (W 0.00289542) | 1.23941 ± 0.00147744 (W 0.00326544) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 33.785 ± 0.122081 (W 0.0321735) | 39.1242 ± 0.101641 (W 0.0656706) | 40.5526 ± 0.337193 (W 0.0282719) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.86478 ± 0.00264271 (W 0.00208037) | 2.09759 ± 0.00706006 (W 0.00552398) | 1.82513 ± 0.00555413 (W 0.0086041) | 🔵 faer-fork 1.12× faster than `faer-upstream` | · |  |
| `svd_thin/4096x256/b1` | 37.228 ± 0.180196 (W 0.060711) | 42.3095 ± 0.394546 (W 0.0402245) | 45.6604 ± 0.158099 (W 0.143047) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 0.962716 ± 0.00288673 (W 0.00268459) | 1.4502 ± 0.00404126 (W 0.00571723) | 0.910809 ± 0.00283236 (W 0.00693981) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 19.4294 ± 0.0139554 (W 0.015443) | 27.0142 ± 0.0674241 (W 0.0290116) | 20.786 ± 0.134297 (W 0.06247) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.88302 ± 0.00970266 (W 0.00395241) | 2.18902 ± 0.00755496 (W 0.00335853) | 1.64119 ± 0.00335261 (W 0.00323486) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 33.8203 ± 0.16905 (W 2.41566) | 41.3046 ± 0.299447 (W 0.328538) | 34.4533 ± 0.0989106 (W 0.358637) | 🔵 faer-fork 1.22× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 0.978015 ± 0.00596414 (W 0.00247436) | 1.5479 ± 0.00838387 (W 0.00649489) | 0.788078 ± 0.0047569 (W 0.00259181) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 17.4773 ± 0.122244 (W 0.0880411) | 28.0105 ± 0.108454 (W 0.0454262) | 15.7057 ± 0.277068 (W 0.060297) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.9882 ± 0.0169111 (W 0.00459909) | 5.9928 ± 0.00610955 (W 0.00258636) | 8.75481 ± 0.0145808 (W 0.0104497) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 278.811 ± 0.219063 (W 2.8794) | 282.247 ± 0.700401 (W 0.338919) | 380.063 ± 0.748244 (W 0.888073) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.81968 ± 0.0255832 (W 0.00270439) | 3.07513 ± 0.00539696 (W 0.00280053) | 3.80853 ± 0.0346523 (W 0.00596819) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 117.46 ± 0.462985 (W 0.426304) | 123.239 ± 0.347148 (W 0.073249) | 144.431 ± 6.35311 (W 0.754358) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.42255 ± 0.00737358 (W 0.00471281) | 3.69859 ± 0.00946014 (W 0.00780689) | 5.48023 ± 0.00934913 (W 0.025349) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 109.423 ± 0.73147 (W 0.562327) | 119.442 ± 0.106573 (W 0.195567) | 131.781 ± 3.35173 (W 0.35013) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.90892 ± 0.0263834 (W 0.00240794) | 2.447 ± 0.00655839 (W 0.0067148) | 2.82337 ± 0.0130459 (W 0.00313103) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 62.2745 ± 1.16452 (W 0.265305) | 72.5036 ± 0.191114 (W 0.152697) | 59.1282 ± 4.50975 (W 0.385219) | 🔵 faer-fork 1.16× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.13282 ± 0.0101686 (W 0.0144447) | 3.69861 ± 0.018057 (W 0.0171556) | 4.44895 ± 0.0107442 (W 0.00559273) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 86.8912 ± 0.78266 (W 0.933632) | 108.17 ± 0.515708 (W 1.64327) | 82.8971 ± 0.311016 (W 0.474672) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.80333 ± 0.0123495 (W 0.00787101) | 2.50008 ± 0.0101297 (W 0.0106557) | 2.31112 ± 0.0153094 (W 0.00314243) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 53.3283 ± 1.02443 (W 0.51749) | 70.2841 ± 0.351825 (W 0.523735) | 34.2122 ± 0.170643 (W 0.160184) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.87781 ± 0.0181872 (W 0.00230184) | 5.88838 ± 0.00890284 (W 0.00276428) | 8.48661 ± 0.0589211 (W 0.0156583) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 266.708 ± 0.368109 (W 0.447035) | 269.528 ± 0.357409 (W 0.356399) | 365.22 ± 5.78129 (W 1.36419) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.70648 ± 0.0257783 (W 0.00357771) | 2.95626 ± 0.00542601 (W 0.00269659) | 3.67462 ± 0.0228587 (W 0.00401835) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 105.228 ± 0.0817728 (W 0.0932624) | 110.689 ± 0.289396 (W 0.37686) | 139.373 ± 5.65204 (W 0.44626) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.30727 ± 0.00935472 (W 0.00604091) | 3.58316 ± 0.00415171 (W 0.00428165) | 5.42222 ± 0.0203063 (W 0.00520458) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 97.136 ± 0.240817 (W 0.165424) | 107.309 ± 0.150139 (W 0.0552262) | 129.074 ± 6.25643 (W 0.290954) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.83414 ± 0.00624764 (W 0.00211959) | 2.36593 ± 0.00498885 (W 0.00506109) | 2.7959 ± 0.0169008 (W 0.00445674) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 48.5507 ± 0.0569346 (W 0.0864103) | 60.3078 ± 0.220358 (W 0.0509025) | 50.0607 ± 0.220291 (W 0.0721426) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.04266 ± 0.0112007 (W 0.0209034) | 3.60762 ± 0.016475 (W 0.0253707) | 4.39856 ± 0.0132704 (W 0.0110731) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 73.6453 ± 0.169894 (W 0.603811) | 95.7167 ± 0.37857 (W 1.18115) | 75.0134 ± 1.39706 (W 0.2628) | 🔵 faer-fork 1.30× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.73908 ± 0.00723636 (W 0.00753986) | 2.40769 ± 0.0056576 (W 0.00980343) | 2.28449 ± 0.00803765 (W 0.0029998) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 40.4993 ± 0.0317284 (W 0.2277) | 58.0899 ± 0.254682 (W 0.247356) | 32.4374 ± 0.312508 (W 0.0969973) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.59078 ± 0.00408304 (W 0.00291003) | 1.59524 ± 0.00249594 (W 0.00198129) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 48.5349 ± 1.20693 (W 0.0455489) | 50.9264 ± 1.29498 (W 0.0575477) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.990782 ± 0.000357413 (W 0.00551801) | 1.13287 ± 0.00320702 (W 0.00544375) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.8215 ± 0.0467372 (W 0.0218756) | 29.3774 ± 1.21773 (W 0.0477636) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.28596 ± 0.00229487 (W 0.00478437) | 1.5168 ± 0.00433503 (W 0.00353084) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.8255 ± 0.466233 (W 0.0974118) | 28.6768 ± 0.0150552 (W 0.0515036) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.861496 ± 0.00352822 (W 0.00259314) | 1.25819 ± 0.00646501 (W 0.0053634) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.49 ± 0.0149952 (W 0.0196806) | 21.7454 ± 0.0516872 (W 0.0224138) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.31055 ± 0.0196925 (W 0.00107094) | 1.62149 ± 0.00868889 (W 0.00397786) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 22.3712 ± 0.115957 (W 0.0900425) | 29.6087 ± 0.145874 (W 0.105845) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.880444 ± 0.00394525 (W 0.0036203) | 1.34593 ± 0.00732617 (W 0.00377978) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 15.7231 ± 0.012899 (W 0.0671935) | 22.9542 ± 0.0173981 (W 0.127992) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.5852 ± 0.00147295 (W 0.00271028) | 1.59303 ± 0.00455798 (W 0.00318576) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 45.7279 ± 0.202357 (W 0.0712532) | 46.4292 ± 0.318789 (W 0.0561619) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.955662 ± 0.000198547 (W 0.0016019) | 1.10581 ± 0.00368289 (W 0.00155663) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 21.5559 ± 0.0819837 (W 0.0125193) | 24.4652 ± 0.149257 (W 0.0198088) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.29604 ± 0.00557479 (W 0.012119) | 1.52532 ± 0.00595333 (W 0.00445129) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.8662 ± 0.0182838 (W 0.0863303) | 25.8282 ± 0.068267 (W 0.0678751) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.820659 ± 0.000913029 (W 0.00168978) | 1.22565 ± 0.000808232 (W 0.00423881) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 13.0618 ± 0.0643096 (W 0.0138758) | 18.3906 ± 0.0177749 (W 0.019753) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.30733 ± 0.0180808 (W 0.00217142) | 1.6323 ± 0.00730386 (W 0.00679628) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 19.4128 ± 0.0805135 (W 0.0787616) | 26.5343 ± 0.0688331 (W 0.0858755) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.841694 ± 0.0049002 (W 0.00167728) | 1.31712 ± 0.00515249 (W 0.00496976) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 12.195 ± 0.010994 (W 0.0453621) | 19.6003 ± 0.0231792 (W 0.0580072) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.38554 ± 0.00745166 (W 0.00540186) | 3.39532 ± 0.00532895 (W 0.00544733) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 145.177 ± 0.117593 (W 0.148807) | 146.275 ± 0.0613782 (W 0.171433) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.83488 ± 0.00562843 (W 0.00464975) | 2.01692 ± 0.005035 (W 0.0045986) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 63.8829 ± 0.0669273 (W 0.0903009) | 67.0971 ± 0.077273 (W 0.0759238) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.04324 ± 0.00458978 (W 0.00389336) | 2.33026 ± 0.00696825 (W 0.00448084) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 58.684 ± 0.0452295 (W 0.10757) | 65.701 ± 1.01631 (W 0.206672) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.32318 ± 0.00962253 (W 0.00400928) | 1.7943 ± 0.0106022 (W 0.00908557) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 33.9637 ± 0.123975 (W 0.0386747) | 41.8916 ± 0.0319309 (W 0.0493438) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.95183 ± 0.00340202 (W 0.0120438) | 2.40147 ± 0.00758652 (W 0.00886995) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.5057 ± 0.42479 (W 0.426888) | 60.7357 ± 0.32188 (W 0.574156) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.29917 ± 0.00151621 (W 0.00654837) | 1.87077 ± 0.0063723 (W 0.00959795) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 29.9761 ± 0.936257 (W 0.263681) | 41.9659 ± 0.0109766 (W 0.136654) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.34218 ± 0.0045355 (W 0.00553869) | 3.36055 ± 0.00669249 (W 0.00375446) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 139.869 ± 0.178537 (W 0.0726209) | 141.027 ± 0.17349 (W 0.401611) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.77243 ± 0.00263599 (W 0.00309654) | 1.91583 ± 0.00185512 (W 0.00151979) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 58.2585 ± 0.0551695 (W 0.0316666) | 61.4563 ± 0.128385 (W 0.061812) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.01552 ± 0.0046746 (W 0.00339805) | 2.30586 ± 0.0119888 (W 0.00318482) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 53.2717 ± 0.0633959 (W 0.0605814) | 60.1442 ± 0.0487256 (W 0.076444) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.26048 ± 0.00137826 (W 0.00285393) | 1.7103 ± 0.00371134 (W 0.00645127) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 28.2593 ± 0.0836693 (W 0.0223742) | 36.3278 ± 0.0671724 (W 0.0334292) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.92764 ± 0.00792249 (W 0.00878643) | 2.37549 ± 0.00428799 (W 0.0126999) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 41.6218 ± 0.200065 (W 0.491726) | 54.9913 ± 0.461585 (W 0.74218) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.23714 ± 0.00283357 (W 0.00333019) | 1.78654 ± 0.00724318 (W 0.00527912) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.257 ± 0.184642 (W 0.273847) | 36.4718 ± 0.158893 (W 0.143374) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
