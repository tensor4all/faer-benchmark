# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `50c2b989484f063f4e1b132adc333715391d8b73`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `34a75d77ed1fec5e94db10427c34b9ac95f01ad8`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `a4beb03b08d47248a05b164cb550a7eecfd39bb923413479091a3f3264486b57`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-22T22:44:49.193067Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small --families svd_values,svd_thin,qr_factor,eigh --shapes 32,64 --dtypes f64,c64,f32,c32 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label dqds-loop-baseline --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261022T223956Z-dqds-loop-baseline/`

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
- CPU sets: 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.75%, worst 287.34% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 34 of 320 engine cells exceed 5% and carry `!`; median within-process relative SD 0.65%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.113096 ± 0.00059838 (W 0.00147062) | 0.112996 ± 0.000783782 (W 0.000148615) | 0.105863 ± 0.000574752 (W 0.00160425) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.499367 ± 0.00163827 (W 0.00332532) | 0.502719 ± 0.00269161 (W 0.00397569) | 0.271716 ± 0.000874098 (W 0.00138348) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023353 ± 3.60555e-05 (W 9.43144e-05) | 0.090846 ± 0.00342072 (W 0.00431419) | 0.014015 ± 1.47309e-05 (W 5.58865e-05) | 🔵 faer-fork 3.89× faster than `faer-upstream` | 🔴 faer-fork 1.67× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.104881 ± 0.00108835 (W 0.000658536) | 0.475599 ± 0.0123685 (W 0.0157194) | 0.298103 ± 0.13381 (W 0.00149605) | 🔵 faer-fork 4.53× faster than `faer-upstream` | 🔵 faer-fork 2.84× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.182852 ± 0.00312084 (W 0.00193236) | 0.182652 ± 0.00380043 (W 0.0016263) | 0.185488 ± 7.9e-05 (W 0.00134356) | · | · |  |
| `svd_thin/n64/b1` | 0.950606 ± 0.00549718 (W 0.00361228) | 0.950988 ± 0.0079089 (W 0.00231057) | 0.669415 ± 0.00726764 (W 0.00204181) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.139715 ± 0.000249925 (W 0.000206996) | 0.139534 ± 0.000423461 (W 0.00113949) | 0.064527 ± 0.0428635 (W 0.000105187) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.516748 ± 0.00119037 (W 0.00187095) | 0.517455 ± 0.0012867 (W 0.00187227) | 0.269449 ± 4.71593e-05 (W 0.00192941) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112775 ± 0.000166103 (W 0.00153392) | 0.113006 ± 0.000213378 (W 0.0014973) | 0.106906 ± 0.000347018 (W 0.000429392) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.505756 ± 0.00241573 (W 0.00260611) | 0.508616 ± 0.00215365 (W 0.00419151) | 0.26346 ± 0.000599164 (W 0.00157223) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023523 ± 8.03762e-05 (W 0.00011922) | 0.121302 ± 0.00124968 (W 0.00826567) | 0.014075 ± 0.00015048 (W 7.32803e-05) | 🔵 faer-fork 5.16× faster than `faer-upstream` | 🔴 faer-fork 1.67× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.1095 ± 0.00403771 (W 0.00152867) | 0.633799 ± 0.0166271 (W 0.0086612) | 0.298604 ± 0.134492 (W 0.00203118) | 🔵 faer-fork 5.79× faster than `faer-upstream` | 🔵 faer-fork 2.73× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.182334 ± 0.00936088 (W 0.00169647) | 0.182775 ± 0.0091022 (W 0.00138338) | 0.187011 ± 0.000361576 (W 0.0013454) | · | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.974373 ± 0.00119701 (W 0.00516932) | 0.969078 ± 0.00384617 (W 0.00572958) | 0.660459 ± 0.00564866 (W 0.00254223) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.139886 ± 0.000493322 (W 0.00119598) | 0.139795 ± 0.000175274 (W 0.00107089) | 0.064708 ± 0.0429851 (W 0.00136504) | · | 🔴 faer-fork 2.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.515277 ± 0.00110504 (W 0.00189561) | 0.518096 ± 0.00293029 (W 0.0020174) | 0.269701 ± 0.000151004 (W 0.0014427) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112846 ± 0.000229993 (W 0.0019078) | 0.113085 ± 0.000813128 (W 0.00025254) | 0.103929 ± 0.000422004 (W 0.00136515) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.497925 ± 0.00850524 (W 0.0136397) | 0.502252 ± 0.00456529 (W 0.00410477) | 0.266146 ± 0.00136042 (W 0.00143386) | · | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017262 ± 6.37992e-05 (W 7.13036e-05) | 0.078222 ± 0.00159937 (W 0.00410634) | 0.011541 ± 2e-05 (W 7.50333e-05) | 🔵 faer-fork 4.53× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.084204 ± 0.00895175 (W 0.00513711) | 0.408614 ± 0.0101992 (W 0.0128277) | 0.289287 ± 0.000293355 (W 0.00134816) | 🔵 faer-fork 4.85× faster than `faer-upstream` | 🔵 faer-fork 3.44× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.186331 ± 0.00296478 (W 0.00175497) | 0.185257 ± 0.00368945 (W 0.00139985) | 0.175981 ± 0.000796327 (W 0.00156022) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.992313 ± 0.0116262 (W 0.00673735) | 0.993083 ± 0.00985888 (W 0.0028319) | 0.647914 ± 9.85343e-05 (W 0.00174464) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.141619 ± 0.000573063 (W 0.00123948) | 0.141768 ± 0.00044023 (W 0.00133583) | 0.059278 ± 0.000307198 (W 8.82853e-05) | · | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537269 ± 0.0022032 (W 0.00193158) | 0.539479 ± 0.00212808 (W 0.00202664) | 0.258329 ± 0.00127675 (W 0.00138406) | · | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112846 ± 0.000548725 (W 0.000180281) | 0.112586 ± 0.000341088 (W 0.00127675) | 0.105553 ± 0.000215516 (W 0.00113846) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.507218 ± 0.00255445 (W 0.00306795) | 0.508595 ± 0.00349751 (W 0.00583209) | 0.258183 ± 0.000451095 (W 0.0015891) | · | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017332 ± 0.000185599 (W 9.00122e-05) | 0.104551 ± 0.00655502 (W 0.00578327) | 0.011611 ± 0.000144222 (W 8.54119e-05) | 🔵 faer-fork 6.03× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.089945 ± 0.0080384 (W 0.00193788) | 0.559651 ± 0.018796 (W 0.0140819) | 0.289488 ± 0.00049823 (W 0.00176344) | 🔵 faer-fork 6.22× faster than `faer-upstream` | 🔵 faer-fork 3.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.18683 ± 0.00905122 (W 0.00162104) | 0.184787 ± 0.00947153 (W 0.00100714) | 0.177635 ± 0.000114372 (W 0.0014348) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.01382 ± 0.00531171 (W 0.00220899) | 1.0187 ± 0.00396654 (W 0.00424451) | 0.637367 ± 0.0018147 (W 0.00320846) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.141599 ± 0.000290047 (W 0.00122997) | 0.141468 ± 0.00029552 (W 0.00141065) | 0.059328 ± 0.000201859 (W 7.21401e-05) | · | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.539491 ± 0.000646108 (W 0.00193595) | 0.53697 ± 0.0025515 (W 0.00166745) | 0.258521 ± 0.00112301 (W 0.00152467) | · | 🔴 faer-fork 2.09× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141098 ± 0.000255645 (W 0.000282254) | 0.14243 ± 0.00065111 (W 0.000355725) | 0.155843 ± 0.000369431 (W 0.000167551) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.640885 ± 0.00835349 (W 0.00548213) | 0.636526 ± 0.000475337 (W 0.00300334) | 0.56677 ± 0.00118052 (W 0.00246676) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039522 ± 0.000115902 (W 0.000215244) | 0.110691 ± 0.00150593 (W 0.00375749) | 0.028992 ± 0.0479127 (W 0.00150785) | 🔵 faer-fork 2.80× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.184758 ± 0.00147362 (W 0.00492487) | 0.600547 ± 0.00704697 (W 0.0136903) | 0.761578 ± 0.345348 (W 0.00167113) | 🔵 faer-fork 3.25× faster than `faer-upstream` | 🔵 faer-fork 4.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.233885 ± 0.000569284 (W 0.00151316) | 0.234496 ± 0.000547624 (W 0.00169475) | 0.261518 ± 0.000340501 (W 0.00150058) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.19328 ± 0.00126563 (W 0.00202809) | 1.1944 ± 0.00262107 (W 0.00431072) | 1.09237 ± 0.035538 (W 0.00437651) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.159941 ± 0.000336613 (W 0.00124111) | 0.160783 ± 0.000143075 (W 0.00100895) | 0.102367 ± 0.122325 (W 0.00157771) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.648756 ± 0.000443198 (W 0.00179081) | 0.648615 ± 0.00145645 (W 0.00173955) | 0.49024 ± 0.00122094 (W 0.00126226) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141308 ± 0.000763915 (W 0.00141316) | 0.14216 ± 0.000617624 (W 0.00128823) | 0.157477 ± 0.000111879 (W 0.00137965) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.643816 ± 0.000719406 (W 0.00377891) | 0.646598 ± 0.00100678 (W 0.00776797) | 0.539244 ± 0.00112117 (W 0.00198983) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039832 ± 0.000392583 (W 0.00128555) | 0.138714 ± 0.0012928 (W 0.0031564) | 0.028893 ± 0.0479299 (W 9.48114e-05) | 🔵 faer-fork 3.48× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.177315 ± 0.00219108 (W 0.00227769) | 0.754401 ± 0.00245212 (W 0.0235666) | 0.763213 ± 0.346027 (W 0.0011093) | 🔵 faer-fork 4.25× faster than `faer-upstream` | 🔵 faer-fork 4.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.233635 ± 0.000672344 (W 0.00171845) | 0.235047 ± 0.000895995 (W 0.00160497) | 0.26264 ± 0.00161234 (W 0.00131675) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20821 ± 0.0053939 (W 0.00457265) | 1.2277 ± 0.00313725 (W 0.0078454) | 1.07185 ± 0.0476196 (W 0.00334856) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.160083 ± 0.000266423 (W 0.00138334) | 0.160724 ± 0.000519454 (W 0.00133772) | 0.102237 ± 0.12194 (W 0.000273785) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.650107 ± 0.0021133 (W 0.00231436) | 0.649266 ± 0.00106154 (W 0.00211945) | 0.491074 ± 0.00124786 (W 0.00160283) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.140978 ± 0.000357661 (W 0.00184327) | 0.141999 ± 0.000346813 (W 0.00125335) | 0.154261 ± 0.000780305 (W 0.00145473) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.636737 ± 0.0125269 (W 0.00282793) | 0.637428 ± 0.00207858 (W 0.00334443) | 0.554454 ± 0.000910224 (W 0.0018268) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.03288 ± 0.00010583 (W 0.000388755) | 0.092829 ± 0.00437361 (W 0.00278714) | 0.026158 ± 8.95005e-05 (W 5.48015e-05) | 🔵 faer-fork 2.82× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.15332 ± 0.000250229 (W 0.00233372) | 0.502844 ± 0.00237104 (W 0.00850535) | 0.756649 ± 0.00100624 (W 0.00138767) | 🔵 faer-fork 3.28× faster than `faer-upstream` | 🔵 faer-fork 4.94× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.23127 ± 0.00017874 (W 0.00130763) | 0.232074 ± 0.000400478 (W 0.00142434) | 0.256466 ± 0.00107422 (W 0.00179637) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22609 ± 0.00177459 (W 0.00370909) | 1.22618 ± 0.00353236 (W 0.00481307) | 1.03219 ± 0.0135339 (W 0.00287675) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158159 ± 0.000342126 (W 0.00164969) | 0.158838 ± 0.000297824 (W 0.000241429) | 0.100754 ± 0.000485553 (W 0.00113805) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.624922 ± 0.000282741 (W 0.00248124) | 0.624348 ± 0.0004675 (W 0.00234106) | 0.479083 ± 0.000597385 (W 0.00193566) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141038 ± 0.000431015 (W 0.00041332) | 0.141638 ± 0.000913166 (W 0.00117544) | 0.155804 ± 0.000620703 (W 0.00137393) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.642469 ± 0.00171168 (W 0.00393714) | 0.64654 ± 0.00617861 (W 0.00578544) | 0.53022 ± 0.00107808 (W 0.00147024) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.03296 ± 0.000174738 (W 0.000263232) | 0.12573 ± 0.00166817 (W 0.00256957) | 0.026208 ± 3.64737e-05 (W 8.32538e-05) | 🔵 faer-fork 3.81× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.161816 ± 0.000607752 (W 0.00415804) | 0.668135 ± 0.00623526 (W 0.00815051) | 0.755744 ± 0.000638251 (W 0.00154354) | 🔵 faer-fork 4.13× faster than `faer-upstream` | 🔵 faer-fork 4.67× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.231441 ± 0.00043724 (W 0.00170195) | 0.232744 ± 0.000720625 (W 0.00183152) | 0.257671 ± 0.000410416 (W 0.0014772) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23706 ± 0.00355552 (W 0.00365312) | 1.25873 ± 0.00407013 (W 0.0112789) | 0.973337 ± 0.0022929 (W 0.00204803) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158681 ± 0.000507476 (W 0.00132871) | 0.15883 ± 0.000716796 (W 0.00135763) | 0.100634 ± 5.72742e-05 (W 0.000201712) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625144 ± 0.000485853 (W 0.00187984) | 0.62491 ± 0.00146292 (W 0.00181975) | 0.481611 ± 0.0023304 (W 0.00193739) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087109 ± 0.000380974 (W 0.00155899) | 0.087229 ± 0.000237551 (W 0.000190274) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.337806 ± 0.00101407 (W 0.00236413) | 0.357432 ± 0.000806406 (W 0.00635906) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020457 ± 3.01164e-05 (W 7.74422e-05) | 0.087791 ± 0.00232561 (W 0.00331425) | - | 🔵 faer-fork 4.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.108067 ± 0.00479259 (W 0.0013562) | 0.447205 ± 0.0112507 (W 0.0118195) | - | 🔵 faer-fork 4.14× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.137531 ± 0.00107838 (W 0.00147927) | 0.137671 ± 0.00113838 (W 0.00166263) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.578328 ± 0.00119615 (W 0.00279901) | 0.613899 ± 0.00311365 (W 0.00586909) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.11002 ± 0.000338292 (W 0.000239145) | 0.110562 ± 0.000230104 (W 0.00137038) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.399511 ± 0.000338625 (W 0.00202047) | 0.399787 ± 0.000660509 (W 0.00209935) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087449 ± 0.000517823 (W 0.00112728) | 0.086958 ± 0.000388981 (W 0.000262214) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.346084 ± 0.002551 (W 0.00318037) | 0.385813 ± 0.00288937 (W 0.0094465) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020448 ± 5.04017e-05 (W 4.11497e-05) | 0.117715 ± 0.00453459 (W 0.00460784) | - | 🔵 faer-fork 5.76× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.106054 ± 0.0022024 (W 0.00170672) | 0.619023 ± 0.00294775 (W 0.00667856) | - | 🔵 faer-fork 5.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.138002 ± 0.00158666 (W 0.00135693) | 0.138152 ± 0.00164365 (W 0.00117306) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.588915 ± 0.00220343 (W 0.00239408) | 0.666603 ± 0.00720768 (W 0.0134589) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109971 ± 0.000146644 (W 0.000131643) | 0.110632 ± 0.000183391 (W 0.00157385) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.39954 ± 0.00225784 (W 0.00175185) | 0.401503 ± 0.00161348 (W 0.00169592) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087299 ± 9.45533e-05 (W 0.000244633) | 0.087059 ± 0.000206408 (W 0.00121995) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.337247 ± 0.000283914 (W 0.00327558) | 0.35633 ± 0.00180562 (W 0.00326697) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.016009 ± 4.04145e-05 (W 9.78887e-05) | 0.073955 ± 0.00308977 (W 0.00192251) | - | 🔵 faer-fork 4.62× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.094383 ± 0.00958124 (W 0.00343834) | 0.396012 ± 0.00842402 (W 0.0103292) | - | 🔵 faer-fork 4.20× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.146969 ± 0.00112446 (W 0.00144386) | 0.146958 ± 0.0014346 (W 0.000258519) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.578826 ± 0.00438988 (W 0.00312894) | 0.615712 ± 0.00203518 (W 0.00342352) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.10946 ± 0.000393127 (W 9.20994e-05) | 0.10983 ± 0.000138529 (W 8.06678e-05) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.402416 ± 0.000829423 (W 0.00193975) | 0.403225 ± 0.00191327 (W 0.00180018) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087249 ± 0.000404579 (W 0.000177871) | 0.086878 ± 0.000229698 (W 0.00153771) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.346032 ± 0.00286219 (W 0.00275655) | 0.391603 ± 0.00135631 (W 0.00591018) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.016009 ± 0.000234458 (W 7.30068e-05) | 0.109731 ± 0.0013001 (W 0.00553284) | - | 🔵 faer-fork 6.85× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.088371 ± 0.00610959 (W 0.00292358) | 0.578338 ± 0.0110667 (W 0.0165691) | - | 🔵 faer-fork 6.54× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.146938 ± 0.00181443 (W 0.00138023) | 0.147339 ± 0.00206606 (W 0.00123843) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.592572 ± 0.0027196 (W 0.00286803) | 0.676148 ± 0.00436183 (W 0.0110171) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.10931 ± 0.000374325 (W 0.00158126) | 0.110071 ± 8.23671e-05 (W 0.000273125) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.400542 ± 0.00260137 (W 0.0020215) | 0.401331 ± 0.00089376 (W 0.00181428) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104571 ± 0.00052194 (W 0.0015384) | 0.103909 ± 0.000155725 (W 0.000168941) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.407834 ± 0.0010807 (W 0.00310728) | 0.413983 ± 0.00566905 (W 0.0060252) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.031137 ± 8.88819e-05 (W 9.05539e-05) | 0.097408 ± 0.00300067 (W 0.00412684) | - | 🔵 faer-fork 3.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.140586 ± 0.00740329 (W 0.00229886) | 0.50447 ± 0.00442481 (W 0.0107421) | - | 🔵 faer-fork 3.59× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.172506 ± 0.00121673 (W 0.00148327) | 0.171643 ± 0.00123426 (W 0.00155147) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.691888 ± 0.000650923 (W 0.00380119) | 0.691184 ± 0.00113891 (W 0.00214082) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118617 ± 0.000116148 (W 0.00146464) | 0.118847 ± 0.000308754 (W 0.00140813) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.454702 ± 0.00021351 (W 0.00153975) | 0.456235 ± 0.00150461 (W 0.00228204) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.10455 ± 0.000474455 (W 0.00184482) | 0.104311 ± 0.000130539 (W 0.000156554) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.415259 ± 0.00227083 (W 0.00407724) | 0.415279 ± 0.00219685 (W 0.00381137) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.031267 ± 8.62168e-05 (W 8.53241e-05) | 0.127884 ± 0.000601549 (W 0.00254659) | - | 🔵 faer-fork 4.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.138392 ± 0.000294824 (W 0.00145447) | 0.689602 ± 0.00537216 (W 0.0149383) | - | 🔵 faer-fork 4.98× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.171864 ± 0.000562196 (W 0.00156481) | 0.171263 ± 0.000457202 (W 0.00146863) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.701111 ± 0.00255999 (W 0.00454451) | 0.706684 ± 0.00598252 (W 0.00546114) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118496 ± 0.000206463 (W 0.00142539) | 0.119088 ± 8.3865e-05 (W 0.00163253) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.457072 ± 0.00251941 (W 0.00171521) | 0.460178 ± 0.000525586 (W 0.00182664) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104189 ± 0.000191251 (W 0.000287014) | 0.103979 ± 0.000136297 (W 0.00164096) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.409545 ± 0.00128254 (W 0.00269555) | 0.417349 ± 0.00666215 (W 0.00477451) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025927 ± 0.000115036 (W 9.60729e-05) | 0.083432 ± 0.000465726 (W 0.00487802) | - | 🔵 faer-fork 3.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.11534 ± 0.0120578 (W 0.00248682) | 0.432056 ± 0.0127589 (W 0.00877391) | - | 🔵 faer-fork 3.75× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.174339 ± 0.0025223 (W 0.00129614) | 0.173988 ± 0.000871478 (W 0.00131164) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.701626 ± 0.00683462 (W 0.00586293) | 0.700988 ± 0.00127977 (W 0.00252195) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118226 ± 0.000505847 (W 0.00126898) | 0.118456 ± 0.00015969 (W 5.35724e-05) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.450549 ± 0.000812066 (W 0.00183098) | 0.450193 ± 0.000467968 (W 0.00182371) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104411 ± 0.000272416 (W 0.000121778) | 0.104841 ± 0.00043704 (W 0.00163773) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.413996 ± 0.000623524 (W 0.00342705) | 0.414237 ± 0.000560204 (W 0.0053887) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025997 ± 0.000214399 (W 6.30872e-05) | 0.118017 ± 0.0028483 (W 0.00780655) | - | 🔵 faer-fork 4.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.1201 ± 0.00236254 (W 0.000830837) | 0.59487 ± 0.00148457 (W 0.00895749) | - | 🔵 faer-fork 4.95× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.173728 ± 0.000678224 (W 0.00141199) | 0.173047 ± 0.000357128 (W 0.00155334) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.711048 ± 0.00344816 (W 0.00251205) | 0.711219 ± 0.0109126 (W 0.00528599) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.117935 ± 0.000348886 (W 0.00190559) | 0.118387 ± 0.000240604 (W 0.00130909) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.450743 ± 0.00227181 (W 0.00156434) | 0.453927 ± 0.000590477 (W 0.00193252) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/32`, `eigh/64`, `qr_factor/32`, `qr_factor/64`, `svd_thin/32`, `svd_thin/64`, `svd_values/32`, `svd_values/64`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
