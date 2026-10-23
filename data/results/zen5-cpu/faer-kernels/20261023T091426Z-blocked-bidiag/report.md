# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `555d84f8f51ab6520dd7b46bf5ecba4b478dafa0`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `07779fe90bc6dc1572c0ac0460f95fe2170cd83a`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `648090ab8c6d746fa0d12b2e9082bad6d0f46e3136f78b56e33bb0758f01bf4b`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T09:52:22.410138Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label blocked-bidiag --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T091426Z-blocked-bidiag/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.58%, worst 207.03% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 35 of 960 engine cells exceed 5% and carry `!`; median within-process relative SD 0.32%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `svd_thin/n32/b1` | 0.183671 ± 0.00102508 (W 0.00124148) | 0.184011 ± 0.000708384 (W 0.00146478) | 0.178268 ± 0.00054312 (W 0.00134539) | · | · |  |
| `svd_thin/n64/b1` | 0.920453 ± 0.00893888 (W 0.00207249) | 0.921635 ± 0.00685991 (W 0.00233566) | 0.766824 ± 0.00863523 (W 0.00338442) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.21365 ± 0.0369018 (W 0.00224083) | 2.2221 ± 0.0061112 (W 0.00221979) | 1.69212 ± 0.0530056 (W 0.00944184) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.128359 ± 0.000354996 (W 0.000927623) | 0.140278 ± 0.000211821 (W 0.00126222) | 0.064399 ± 0.000104403 (W 0.000111679) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.478898 ± 0.00112721 (W 0.00220838) | 0.51785 ± 0.0010992 (W 0.00194905) | 0.266344 ± 0.000465869 (W 0.00173963) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.0662 ± 0.00178101 (W 0.000684939) | 1.18497 ± 0.00149464 (W 0.00173377) | 0.641021 ± 0.00196353 (W 0.00380741) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.66× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.182499 ± 0.00014031 (W 0.00168439) | 0.182839 ± 0.000308328 (W 0.00144128) | 0.185896 ± 0.00026837 (W 0.00143528) | · | · |  |
| `svd_thin/n64/b1` | 0.954426 ± 0.00527713 (W 0.00264315) | 0.951351 ± 0.00373203 (W 0.00304126) | 0.669942 ± 0.00269364 (W 0.00180418) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.28928 ± 0.0208245 (W 0.0179673) | 2.33732 ± 0.0547895 (W 0.0232495) | 1.41365 ± 0.00331216 (W 0.00307239) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.128238 ± 0.00028816 (W 0.00101816) | 0.139699 ± 0.000232095 (W 0.00130977) | 0.064379 ± 2.36714e-05 (W 8.12607e-05) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.479892 ± 0.0011095 (W 0.0016108) | 0.51751 ± 0.00214124 (W 0.0016326) | 0.270248 ± 0.000443347 (W 0.00110208) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06662 ± 0.00355869 (W 0.000871517) | 1.18576 ± 0.00301315 (W 0.00208235) | 0.606496 ± 0.000967938 (W 0.0017865) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.18338 ± 0.00311316 (W 0.00164063) | 0.18367 ± 0.00308174 (W 0.00162264) | 0.187615 ± 0.000515252 (W 0.000848589) | · | · |  |
| `svd_thin/n64/b1` | 0.969247 ± 0.00709079 (W 0.00517876) | 0.968947 ± 0.00677134 (W 0.00237419) | 0.669243 ± 0.0118665 (W 0.00291287) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.30124 ± 0.054047 (W 0.0278452) | 2.40027 ± 0.0574369 (W 0.0165683) | 1.44006 ± 0.0632074 (W 0.00548747) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.128548 ± 0.000140436 (W 0.000121698) | 0.140141 ± 0.000490156 (W 0.00158673) | 0.064459 ± 0.000167094 (W 0.00142251) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.477157 ± 0.00131034 (W 0.00217066) | 0.517281 ± 0.000545153 (W 0.0020394) | 0.270478 ± 0.000680688 (W 0.00139989) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.06626 ± 0.00386434 (W 0.000872033) | 1.18668 ± 0.000861817 (W 0.00185384) | 0.599774 ± 0.00149795 (W 0.00203989) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.1847 ± 0.00115039 (W 0.00169143) | 0.185474 ± 0.000766503 (W 0.00152239) | 0.168643 ± 0.000126012 (W 0.00127312) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.964233 ± 0.00919577 (W 0.0018706) | 0.963041 ± 0.00517098 (W 0.00103835) | 0.706092 ± 0.00471115 (W 0.00323345) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.15963 ± 0.0305006 (W 0.00270715) | 2.1612 ± 0.031634 (W 0.00322062) | 1.62023 ± 0.0522561 (W 0.00852713) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.133428 ± 0.000251796 (W 0.00169494) | 0.142021 ± 0.000120012 (W 0.0013074) | 0.05933 ± 6.56531e-05 (W 8.61394e-05) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.479379 ± 0.000142388 (W 0.00243763) | 0.537779 ± 0.00151947 (W 0.00192097) | 0.256311 ± 0.00108931 (W 0.00139407) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05676 ± 0.00134989 (W 0.000526031) | 1.19232 ± 0.00217767 (W 0.00144387) | 0.611395 ± 0.000724314 (W 0.00190148) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.184922 ± 0.000467437 (W 0.00147313) | 0.184662 ± 0.000494587 (W 0.00117067) | 0.176628 ± 0.000180816 (W 0.00113267) | · | · |  |
| `svd_thin/n64/b1` | 0.997309 ± 0.00525597 (W 0.00189711) | 0.996473 ± 0.00472475 (W 0.00869482) | 0.641952 ± 0.00276837 (W 0.00192841) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.26718 ± 0.010111 (W 0.0165312) | 2.25725 ± 0.0128482 (W 0.019366) | 1.3781 ± 0.00212946 (W 0.0025775) | · | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.133919 ± 0.000164239 (W 0.00131258) | 0.141731 ± 7.502e-05 (W 0.00123895) | 0.05927 ± 0.000197384 (W 0.000159013) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.477137 ± 0.000838708 (W 0.00169475) | 0.537066 ± 0.00170769 (W 0.00141819) | 0.259121 ± 0.00202209 (W 0.00119337) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.05774 ± 0.00163431 (W 0.00178419) | 1.19052 ± 0.00233631 (W 0.00214385) | 0.609039 ± 0.00373523 (W 0.0020655) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.185924 ± 0.00286487 (W 0.00166788) | 0.186866 ± 0.00274032 (W 0.00159307) | 0.178391 ± 0.000163867 (W 0.00146399) | · | · |  |
| `svd_thin/n64/b1` | 1.01333 ± 0.00925506 (W 0.00473144) | 1.01344 ± 0.0054223 (W 0.0042597) | 0.632004 ± 0.00695398 (W 0.00209098) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31431 ± 0.0359976 (W 0.0159478) | 2.39152 ± 0.0517502 (W 0.0138378) | 1.32732 ± 0.024643 (W 0.00140402) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.133618 ± 0.000203686 (W 0.000169261) | 0.142104 ± 0.000289061 (W 0.00138159) | 0.05936 ± 0.000148294 (W 0.000163949) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.478917 ± 0.00153572 (W 0.00185466) | 0.539753 ± 0.00127404 (W 0.00167884) | 0.25924 ± 0.000609567 (W 0.00190764) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.85× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.0602 ± 0.00262383 (W 0.00112897) | 1.19665 ± 0.00313513 (W 0.00133755) | 0.604621 ± 0.00236134 (W 0.00154162) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234655 ± 0.00922028 (W 0.00193658) | 0.234595 ± 0.00930566 (W 0.00149784) | 0.252689 ± 0.0011227 (W 0.00135366) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.22369 ± 0.00466133 (W 0.00216124) | 1.22562 ± 0.0072036 (W 0.0025089) | 1.34145 ± 0.00368903 (W 0.00242981) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.13294 ± 0.0066485 (W 0.00390778) | 3.13529 ± 0.0146758 (W 0.0024097) | 3.48517 ± 0.00117797 (W 0.00460291) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.149104 ± 0.000455569 (W 0.00131765) | 0.161069 ± 0.000328247 (W 0.00170393) | 0.102751 ± 0.121716 (W 0.00106251) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.586739 ± 0.00164444 (W 0.00164825) | 0.650876 ± 0.00146102 (W 0.00152691) | 0.491825 ± 0.000723368 (W 0.00185342) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36968 ± 0.0015665 (W 0.00409974) | 1.51095 ± 0.00343524 (W 0.00207312) | 1.375 ± 0.0300465 (W 0.00147866) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234572 ± 0.00100265 (W 0.0018274) | 0.234656 ± 0.00168245 (W 0.0015975) | 0.261381 ± 0.000113161 (W 0.00153446) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.19174 ± 0.00185325 (W 0.00231648) | 1.19628 ± 0.00173158 (W 0.00399463) | 1.03 ± 0.00120171 (W 0.00174188) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96611 ± 0.0224448 (W 0.031201) | 2.95102 ± 0.00791456 (W 0.0155908) | 2.52707 ± 0.00457809 (W 0.00647242) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.149275 ± 0.000101692 (W 0.00123966) | 0.160999 ± 0.00038482 (W 0.00174821) | 0.10259 ± 0.121919 (W 0.00144227) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.584917 ± 0.00230372 (W 0.00176706) | 0.648804 ± 0.00100604 (W 0.00181542) | 0.491074 ± 0.000985731 (W 0.0013119) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36282 ± 0.00237736 (W 0.00419328) | 1.50298 ± 0.0031377 (W 0.00198883) | 1.35754 ± 0.0023123 (W 0.00155697) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.234326 ± 0.000195434 (W 0.001584) | 0.234064 ± 0.000380797 (W 0.00147241) | 0.262834 ± 0.000466976 (W 0.00213501) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21035 ± 0.0121018 (W 0.00230577) | 1.22408 ± 0.0112349 (W 0.0061087) | 0.994798 ± 0.0245858 (W 0.00148086) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96251 ± 0.0249999 (W 0.0212337) | 3.10726 ± 0.0177219 (W 0.0113535) | 2.34684 ± 0.0451471 (W 0.00401866) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.149175 ± 0.000135208 (W 0.000156798) | 0.160808 ± 0.000147079 (W 0.00159712) | 0.102178 ± 0.122078 (W 0.00126691) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.58659 ± 0.0010202 (W 0.00214023) | 0.649978 ± 0.000704415 (W 0.00206354) | 0.489538 ± 0.0031443 (W 0.00173341) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36768 ± 0.00261705 (W 0.00157739) | 1.50609 ± 0.00085673 (W 0.013806) | 1.39696 ± 0.00506468 (W 0.0117716) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231445 ± 0.0093477 (W 0.00126562) | 0.233463 ± 0.00827803 (W 0.00199639) | 0.249594 ± 0.000343641 (W 0.00146287) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.25475 ± 0.00303452 (W 0.00287834) | 1.25641 ± 0.001974 (W 0.00124993) | 1.31203 ± 0.00307026 (W 0.00267482) | · | · |  |
| `svd_thin/n96/b1` | 3.0968 ± 0.00840921 (W 0.00188903) | 3.0944 ± 0.0108237 (W 0.00146518) | 3.41955 ± 0.00358356 (W 0.0067682) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.15245 ± 0.000238162 (W 0.00152751) | 0.159125 ± 0.000284261 (W 0.000958844) | 0.100697 ± 0.000261718 (W 0.000134425) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.591578 ± 0.00087648 (W 0.00234368) | 0.625562 ± 0.00176478 (W 0.00145822) | 0.479862 ± 0.00196517 (W 0.00149449) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36979 ± 0.00394978 (W 0.00171947) | 1.48614 ± 0.00566154 (W 0.00412123) | 1.33987 ± 0.0041855 (W 0.00208605) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231937 ± 0.0014572 (W 0.00191197) | 0.232772 ± 0.00132422 (W 0.00173076) | 0.256567 ± 0.000711378 (W 0.00117998) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22312 ± 0.0207171 (W 0.00257366) | 1.22567 ± 0.00120129 (W 0.00519079) | 1.00954 ± 0.000511849 (W 0.00107496) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.9133 ± 0.0331925 (W 0.022657) | 2.91577 ± 0.0102206 (W 0.00766262) | 2.50806 ± 0.00513678 (W 0.00563949) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.152522 ± 0.000171869 (W 0.00141583) | 0.158725 ± 0.000159004 (W 0.00115118) | 0.100928 ± 0.00034008 (W 0.000194119) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.590196 ± 0.000793017 (W 0.00225516) | 0.62461 ± 0.000913911 (W 0.00180141) | 0.480002 ± 0.00233803 (W 0.00181106) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.36073 ± 0.00158026 (W 0.00196175) | 1.47769 ± 0.00171624 (W 0.00177859) | 1.33968 ± 0.00382207 (W 0.00162589) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.23148 ± 0.000457246 (W 0.00113285) | 0.231727 ± 0.00028577 (W 0.001618) | 0.2589 ± 0.000299684 (W 0.00169554) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24682 ± 0.00871753 (W 0.00351779) | 1.25391 ± 0.00974753 (W 0.00985219) | 0.977216 ± 0.015022 (W 0.00570005) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.92095 ± 0.0223222 (W 0.018144) | 3.02967 ± 0.0313517 (W 0.00809568) | 2.32966 ± 0.0429431 (W 0.00316887) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.15216 ± 0.000447641 (W 0.00107357) | 0.158845 ± 0.000388135 (W 0.00137772) | 0.100637 ± 0.000447976 (W 0.00125219) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.590377 ± 0.0010175 (W 0.00184587) | 0.62582 ± 0.00132674 (W 0.0018613) | 0.481367 ± 0.00162533 (W 0.00176777) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.367 ± 0.00415833 (W 0.00470107) | 1.47957 ± 0.00203574 (W 0.00176915) | 1.34114 ± 0.00273073 (W 0.00168505) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137035 ± 1.5885e-05 (W 0.00140382) | 0.138024 ± 0.00292919 (W 0.00116391) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.537759 ± 0.00208966 (W 0.00198319) | 0.537649 ± 0.00487635 (W 0.00150064) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56935 ± 0.00333258 (W 0.00209648) | 1.5662 ± 0.00337127 (W 0.00280389) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095606 ± 0.000263485 (W 0.00114957) | 0.110754 ± 0.000165683 (W 0.000168726) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.331379 ± 0.00119453 (W 0.00128696) | 0.401145 ± 0.00105438 (W 0.00164604) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.726978 ± 0.00155236 (W 0.0013355) | 0.884767 ± 0.00334605 (W 0.0017046) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137053 ± 0.00047817 (W 0.000103586) | 0.138948 ± 0.000774107 (W 0.000163615) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.574948 ± 0.000456511 (W 0.00239276) | 0.610672 ± 0.00298295 (W 0.00503064) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.67153 ± 0.00990831 (W 0.015686) | 1.74531 ± 0.00108336 (W 0.0169481) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095678 ± 0.000186944 (W 0.000990967) | 0.111155 ± 0.000730273 (W 0.00117002) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.331069 ± 0.000970122 (W 0.00146232) | 0.401616 ± 0.000879746 (W 0.00140204) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.728083 ± 0.000962002 (W 0.00174719) | 0.885405 ± 0.00262343 (W 0.00148806) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137215 ± 0.000106369 (W 0.000200003) | 0.137584 ± 0.0013773 (W 0.00167413) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.588002 ± 0.000874945 (W 0.00323781) | 0.660406 ± 0.0064538 (W 0.0113157) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.71789 ± 0.00855417 (W 0.0207358) | 1.82977 ± 0.00230846 (W 0.0143264) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095648 ± 0.000452527 (W 0.000200338) | 0.110314 ± 0.000240069 (W 0.00152712) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.330623 ± 0.000334738 (W 0.001664) | 0.40146 ± 0.000410498 (W 0.00165383) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.728343 ± 0.00200222 (W 0.00174377) | 0.885241 ± 0.001601 (W 0.00305378) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146089 ± 0.000351346 (W 0.00124136) | 0.14683 ± 0.000605803 (W 0.00124661) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.539964 ± 0.00428358 (W 0.00204972) | 0.543059 ± 0.00504862 (W 0.00187384) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56277 ± 0.00217388 (W 0.0027189) | 1.56132 ± 0.00618984 (W 0.0027947) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.096428 ± 0.000427818 (W 0.00109785) | 0.110012 ± 0.000344009 (W 0.00128932) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.330428 ± 0.000373738 (W 0.00144859) | 0.40344 ± 0.0007495 (W 0.00125462) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.740973 ± 0.000850001 (W 0.00166919) | 0.86993 ± 0.00156378 (W 0.00141009) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.145981 ± 0.000901935 (W 0.0018088) | 0.148303 ± 0.00140353 (W 0.00151859) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.578594 ± 0.00123124 (W 0.00325862) | 0.615511 ± 0.000401425 (W 0.00443584) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.65775 ± 0.00661993 (W 0.0161441) | 1.73387 ± 0.00361249 (W 0.0120222) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.096239 ± 0.00020551 (W 0.00122475) | 0.110113 ± 0.0074812 (W 0.00126914) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.330072 ± 0.00064104 (W 0.00185223) | 0.40196 ± 0.000755196 (W 0.00161063) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.740315 ± 0.00221119 (W 0.00174284) | 0.870387 ± 0.00263746 (W 0.0014123) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.14642 ± 0.000222271 (W 0.00151795) | 0.146462 ± 0.000106964 (W 0.00134363) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.590147 ± 0.00112161 (W 0.0032676) | 0.676266 ± 0.0109807 (W 0.00830449) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.70577 ± 0.00358236 (W 0.0158271) | 1.79014 ± 0.0175278 (W 0.0148949) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.096238 ± 0.000222933 (W 0.00114264) | 0.109563 ± 0.000416172 (W 0.000142539) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.329172 ± 0.0016688 (W 0.00187298) | 0.40174 ± 0.000771421 (W 0.00134488) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.742347 ± 0.00188112 (W 0.0019696) | 0.870918 ± 0.00169426 (W 0.00266608) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.171626 ± 0.000689331 (W 0.00132524) | 0.171756 ± 0.00052067 (W 0.0015637) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.687347 ± 0.0012729 (W 0.00181094) | 0.688529 ± 0.00355433 (W 0.00186902) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.0327 ± 0.00593811 (W 0.00110917) | 2.0339 ± 0.00906855 (W 0.00167759) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.10794 ± 0.000276862 (W 0.000135659) | 0.118879 ± 0.000221249 (W 0.0013824) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.392839 ± 0.000900801 (W 0.00184769) | 0.457451 ± 0.00280917 (W 0.00195609) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.884774 ± 0.00394585 (W 0.00154461) | 1.04823 ± 0.00511814 (W 0.00107873) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.171107 ± 0.000213477 (W 0.000297421) | 0.171248 ± 0.00126159 (W 0.00130402) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.691031 ± 0.00621298 (W 0.00222767) | 0.701812 ± 0.0110512 (W 0.00894506) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.01373 ± 0.00899068 (W 0.0281045) | 2.01791 ± 0.0139139 (W 0.0158792) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.108111 ± 5.84323e-05 (W 6.10098e-05) | 0.118971 ± 0.000310664 (W 0.00122597) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.393144 ± 3.84751e-05 (W 0.00155219) | 0.459031 ± 0.00142434 (W 0.00160492) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.885872 ± 0.00516021 (W 0.00265484) | 1.05328 ± 0.0028805 (W 0.00154492) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.171317 ± 0.000134179 (W 0.00141198) | 0.171158 ± 0.000711987 (W 0.00140397) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.702725 ± 0.00973976 (W 0.00629056) | 0.707253 ± 0.00115393 (W 0.00582975) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04645 ± 0.0171037 (W 0.0249648) | 2.10834 ± 0.0137208 (W 0.0164848) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107839 ± 0.000732142 (W 0.00023438) | 0.119119 ± 0.000370595 (W 0.00131644) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.392969 ± 0.00287885 (W 0.00202293) | 0.460287 ± 0.00513367 (W 0.00178263) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.8848 ± 0.000400471 (W 0.00133024) | 1.04728 ± 0.00152069 (W 0.00104133) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173199 ± 0.000529942 (W 0.00114635) | 0.173412 ± 0.000608729 (W 0.00132588) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.695842 ± 0.000857236 (W 0.0013573) | 0.696303 ± 0.00265343 (W 0.00150004) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04827 ± 0.00828245 (W 0.00298062) | 2.05156 ± 0.0110618 (W 0.00225735) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107339 ± 9.82242e-05 (W 0.000122393) | 0.118538 ± 0.00040172 (W 0.00120329) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.389637 ± 0.00172738 (W 0.0017929) | 0.450419 ± 0.002273 (W 0.0022882) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.901404 ± 0.00334963 (W 0.000637731) | 1.04727 ± 0.0047424 (W 0.000753968) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173291 ± 0.0005107 (W 0.00134661) | 0.174194 ± 0.00111444 (W 0.00149265) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.702302 ± 0.0110662 (W 0.00356115) | 0.70668 ± 0.00235277 (W 0.00276574) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.02136 ± 0.017881 (W 0.0240432) | 2.03437 ± 0.0235077 (W 0.0129299) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107529 ± 0.000349056 (W 0.00121234) | 0.11856 ± 9.56452e-05 (W 0.000157627) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.390255 ± 0.000308312 (W 0.00197838) | 0.454683 ± 0.00117694 (W 0.00158816) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.899958 ± 0.000738731 (W 0.00126553) | 1.05002 ± 0.00405156 (W 0.000687864) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.173441 ± 0.000374156 (W 0.00148853) | 0.172871 ± 0.000273922 (W 0.00164431) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.709689 ± 0.00171555 (W 0.00311938) | 0.718235 ± 0.00598304 (W 0.00679182) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05172 ± 0.00609706 (W 0.0212694) | 2.13297 ± 0.00588995 (W 0.0109934) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107459 ± 0.000427552 (W 5.62788e-05) | 0.11892 ± 0.000440882 (W 0.00132444) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.389913 ± 0.00322042 (W 0.00192495) | 0.455449 ± 0.00283373 (W 0.0016592) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.900359 ± 0.00081803 (W 0.000870947) | 1.0466 ± 0.00365974 (W 0.000745849) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.69013 ± 0.00503943 (W 0.0027707) | 3.68686 ± 0.0042624 (W 0.00364331) | 3.39906 ± 0.00244808 (W 0.00936889) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 17.8491 ± 0.0253495 (W 0.00797102) | 18.5131 ± 0.0326724 (W 0.0109236) | 18.0394 ± 0.0439428 (W 0.0344469) | · | · |  |
| `svd_thin/n512/b1` | 99.0121 ± 0.283565 (W 0.0870279) | 105.633 ± 0.222552 (W 0.0449052) | 116.787 ± 0.652125 (W 0.303965) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.01927 ± 0.00852124 (W 0.00308082) | 2.71023 ± 0.0155492 (W 0.00515676) | 1.1933 ± 0.0306736 (W 0.00260187) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 9.80337 ± 0.0155617 (W 0.00995373) | 12.4667 ± 0.0253939 (W 0.0132327) | 7.08249 ± 0.125992 (W 0.00914382) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 54.1881 ± 0.175947 (W 0.0408708) | 66.3706 ± 0.0818834 (W 0.0530843) | 47.6518 ± 0.728784 (W 0.121052) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.04719 ± 0.00487468 (W 0.0290034) | 3.03102 ± 0.0155214 (W 0.0283448) | 2.63236 ± 0.00529968 (W 0.00570828) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.7429 ± 0.049644 (W 0.0388608) | 13.7266 ± 0.0514825 (W 0.0327601) | 12.4737 ± 0.0839137 (W 0.0195539) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 48.4785 ± 0.13218 (W 0.0688721) | 61.7385 ± 0.675258 (W 0.337818) | 58.0594 ± 0.603195 (W 0.0902) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.02332 ± 0.00572173 (W 0.00305622) | 2.2214 ± 0.00403331 (W 0.0041175) | 1.13699 ± 0.00984223 (W 0.00274973) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 9.91837 ± 0.0201694 (W 0.0144805) | 10.8258 ± 0.0731638 (W 0.0273768) | 6.13749 ± 0.132424 (W 0.00835988) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 34.8247 ± 0.0785773 (W 0.0507799) | 47.9289 ± 0.214904 (W 0.291108) | 25.9337 ± 0.543531 (W 0.0440845) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.04732 ± 0.0182798 (W 0.0152938) | 3.11791 ± 0.00968108 (W 0.017923) | 2.52199 ± 0.0067438 (W 0.00641036) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.3985 ± 0.0232174 (W 0.0387655) | 13.7867 ± 0.0426627 (W 0.0388326) | 11.541 ± 0.032676 (W 0.0144513) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 43.6088 ± 0.247148 (W 0.110349) | 60.6136 ± 0.0968538 (W 0.325178) | 49.0458 ± 2.21172 (W 0.0529285) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.02412 ± 0.00665796 (W 0.00274953) | 2.22217 ± 0.00669441 (W 0.00367375) | 1.12413 ± 0.0293087 (W 0.00299574) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.0171 ± 0.00795321 (W 0.0335545) | 10.9746 ± 0.0101948 (W 0.016443) | 6.0479 ± 0.177012 (W 0.0186964) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.66× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 33.553 ± 0.082766 (W 0.0592785) | 49.2674 ± 0.0360104 (W 0.290572) | 22.4833 ± 0.702149 (W 0.0213968) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.68668 ± 0.00368232 (W 0.00362923) | 3.68466 ± 0.00339955 (W 0.00390052) | 3.32631 ± 0.0150232 (W 0.0156088) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 17.744 ± 0.0240017 (W 0.0154233) | 18.4215 ± 0.0578747 (W 0.0192088) | 17.7193 ± 0.0302986 (W 0.0244728) | · | · |  |
| `svd_thin/n512/b1` | 98.2475 ± 0.432875 (W 0.0356251) | 104.676 ± 0.629373 (W 0.120091) | 116.321 ± 0.435724 (W 0.44063) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.97793 ± 0.00905369 (W 0.00300273) | 2.62896 ± 0.0168673 (W 0.00330537) | 1.15696 ± 0.00559087 (W 0.00192703) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 9.5865 ± 0.00967672 (W 0.00779783) | 12.2988 ± 0.0197081 (W 0.0123933) | 6.84162 ± 0.0210739 (W 0.00970951) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 52.7819 ± 0.312149 (W 0.0268912) | 65.2868 ± 0.0615591 (W 0.0533145) | 47.4653 ± 0.405854 (W 0.0439918) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.00415 ± 0.0129211 (W 0.0258208) | 3.00456 ± 0.0166709 (W 0.0328362) | 2.59925 ± 0.00630443 (W 0.00793134) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.6369 ± 0.0206347 (W 0.0260425) | 13.663 ± 0.0187081 (W 0.0524483) | 12.3217 ± 0.0408151 (W 0.0345327) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 47.4596 ± 0.0266655 (W 0.097712) | 60.7043 ± 0.191673 (W 0.447259) | 56.6609 ± 1.9221 (W 0.108496) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.98456 ± 0.00764182 (W 0.00288208) | 2.16725 ± 0.0232683 (W 0.00509864) | 1.12048 ± 0.00854079 (W 0.00276223) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 9.78033 ± 0.0461101 (W 0.0365052) | 10.6417 ± 0.0456138 (W 0.0180814) | 6.10068 ± 0.103284 (W 0.00756548) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 33.8315 ± 0.126358 (W 0.0593832) | 47.3085 ± 0.32088 (W 0.270917) | 25.5667 ± 0.229086 (W 0.0217783) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.02849 ± 0.00822179 (W 0.0124564) | 3.10667 ± 0.00613912 (W 0.0228617) | 2.47966 ± 0.00236425 (W 0.00875523) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.2702 ± 0.0238022 (W 0.0310904) | 13.6359 ± 0.0236221 (W 0.0514066) | 11.3919 ± 0.0350268 (W 0.0235723) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 42.6561 ± 0.160349 (W 0.367898) | 59.7239 ± 0.126355 (W 0.303611) | 48.111 ± 0.0738147 (W 0.116263) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.97795 ± 0.00451261 (W 0.00243133) | 2.162 ± 0.0292947 (W 0.00335196) | 1.13043 ± 0.00841143 (W 0.00411842) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 9.84533 ± 0.0396034 (W 0.0474625) | 10.8 ± 0.0330462 (W 0.0162936) | 6.00558 ± 0.0133846 (W 0.00749733) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.64× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 32.6113 ± 0.0494786 (W 0.0773575) | 48.4629 ± 0.0978167 (W 0.458673) | 22.268 ± 0.0387002 (W 0.0745344) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.73448 ± 0.00776078 (W 0.00487364) | 5.73369 ± 0.0088451 (W 0.00505004) | 7.05612 ± 0.00681655 (W 0.00753849) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.4314 ± 0.13685 (W 0.041309) | 34.1818 ± 0.18811 (W 0.0268825) | 43.8003 ± 0.328355 (W 0.0399471) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 207.687 ± 1.17065 (W 0.396227) | 209.902 ± 0.552953 (W 0.48835) | 277.169 ± 2.75129 (W 0.835877) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.80498 ± 0.00517287 (W 0.0102043) | 3.46301 ± 0.00914354 (W 0.00623897) | 2.75872 ± 0.00568789 (W 0.00403765) | 🔵 faer-fork 1.23× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 16.4633 ± 0.0657071 (W 0.079886) | 19.347 ± 0.0379559 (W 0.0395301) | 18.1861 ± 0.0733123 (W 0.0416042) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 101.505 ± 0.314034 (W 0.0934276) | 110.402 ± 0.5393 (W 0.122841) | 121.861 ± 1.8028 (W 0.0897332) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.31081 ± 0.0541844 (W 0.0172544) | 4.3647 ± 0.0356286 (W 0.0266714) | 4.15891 ± 0.0102092 (W 0.00533318) | · | · |  |
| `svd_thin/n256/b1` | 21.3705 ± 0.0663464 (W 0.0860961) | 22.4913 ± 0.0820822 (W 0.0632875) | 21.2852 ± 0.0117449 (W 0.0247598) | 🔵 faer-fork 1.05× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 83.9224 ± 0.262404 (W 0.184609) | 94.5154 ± 0.338335 (W 0.307259) | 114.681 ± 5.39005 (W 0.190699) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.80745 ± 0.00406736 (W 0.00784091) | 3.03436 ± 0.00183739 (W 0.00568826) | 2.02078 ± 0.00337088 (W 0.00444658) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 15.7734 ± 0.0203403 (W 0.0341574) | 16.9839 ± 0.0688393 (W 0.0989466) | 11.099 ± 0.0248056 (W 0.0322808) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 53.8849 ± 0.102356 (W 0.100761) | 65.0284 ± 0.172926 (W 0.207703) | 56.4225 ± 0.197431 (W 0.130324) | 🔵 faer-fork 1.21× faster than `faer-upstream` | · |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.23261 ± 0.010026 (W 0.0202014) | 4.47934 ± 0.00798681 (W 0.0239458) | 3.64456 ± 0.00676228 (W 0.00939044) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.8178 ± 0.098848 (W 0.0987842) | 21.9176 ± 0.0917082 (W 0.0421852) | 17.2908 ± 0.0250207 (W 0.020048) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 66.4885 ± 0.208453 (W 0.425436) | 81.4294 ± 0.371923 (W 0.665335) | 85.2971 ± 4.40308 (W 0.0928948) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.80396 ± 0.00913522 (W 0.0074804) | 3.0856 ± 0.00218807 (W 0.00565578) | 1.90998 ± 0.00361354 (W 0.00262656) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 15.7687 ± 0.0209968 (W 0.061457) | 17.0121 ± 0.0382915 (W 0.0255446) | 9.64953 ± 0.0119314 (W 0.0207791) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.63× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.1876 ± 0.211635 (W 0.0971246) | 61.3221 ± 0.221148 (W 0.322369) | 43.2438 ± 0.0353408 (W 0.0405911) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.70257 ± 0.00311562 (W 0.0127516) | 5.71396 ± 0.0143316 (W 0.00513208) | 6.97515 ± 0.0160411 (W 0.00710717) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.1219 ± 0.0981863 (W 0.0577786) | 33.9877 ± 0.222857 (W 0.0387658) | 44.8293 ± 1.33859 (W 0.131981) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 205.703 ± 0.802932 (W 0.515363) | 208.57 ± 0.960659 (W 0.38033) | 305.016 ± 19.201 (W 0.5332) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.78178 ± 0.0079873 (W 0.00535163) | 3.45701 ± 0.00854131 (W 0.00435688) | 2.71947 ± 0.00808309 (W 0.00403479) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 16.1717 ± 0.0542801 (W 0.0211187) | 19.0509 ± 0.0639743 (W 0.0274879) | 19.65 ± 1.00096 (W 0.0435282) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 100.302 ± 0.193357 (W 0.0887505) | 109.46 ± 0.564532 (W 0.347353) | 150.744 ± 17.3094 (W 0.135435) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.31655 ± 0.0273269 (W 0.0156212) | 4.32196 ± 0.0160467 (W 0.0188366) | 4.09665 ± 0.00707284 (W 0.00626608) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.0995 ± 0.0258984 (W 0.0810907) | 22.2349 ± 0.0949926 (W 0.0653832) | 21.1284 ± 0.0221374 (W 0.0331734) | 🔵 faer-fork 1.05× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 82.4791 ± 0.232677 (W 0.467374) | 93.5373 ± 0.074641 (W 0.358653) | 112.947 ± 0.863749 (W 0.408993) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.78318 ± 0.00184169 (W 0.00575039) | 3.00353 ± 0.00374477 (W 0.00492043) | 2.0041 ± 0.00692548 (W 0.00447631) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 15.5274 ± 0.0429358 (W 0.0668229) | 16.8115 ± 0.0510247 (W 0.0759061) | 11.0985 ± 0.0440118 (W 0.0203006) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 52.9416 ± 0.220265 (W 0.0381237) | 63.8991 ± 0.244374 (W 0.350677) | 56.0159 ± 0.0579035 (W 0.116991) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.22319 ± 0.0186416 (W 0.0284413) | 4.44676 ± 0.0125928 (W 0.0299772) | 3.59068 ± 0.0218012 (W 0.0150433) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.5182 ± 0.100886 (W 0.0870326) | 21.6031 ± 0.151656 (W 0.0520805) | 17.1013 ± 0.0177251 (W 0.0421346) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 64.9033 ± 0.252412 (W 0.23575) | 80.4899 ± 0.57867 (W 0.269335) | 82.4245 ± 0.825384 (W 0.118336) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.77621 ± 0.00384638 (W 0.00524571) | 3.04779 ± 0.0273405 (W 0.00600625) | 1.89287 ± 0.0103258 (W 0.00294603) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 15.541 ± 0.024859 (W 0.0654446) | 16.8172 ± 0.016089 (W 0.0689912) | 9.66624 ± 0.0367658 (W 0.0217322) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 46.2577 ± 0.131483 (W 0.0846849) | 60.3783 ± 0.440663 (W 0.275943) | 43.2509 ± 0.118769 (W 0.0462378) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.32395 ± 0.0020229 (W 0.00216953) | 2.33374 ± 0.00571179 (W 0.00327529) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.0979 ± 0.0264775 (W 0.0109203) | 11.2154 ± 0.00706608 (W 0.00875298) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 58.2541 ± 0.144875 (W 0.0329305) | 61.6887 ± 0.193555 (W 0.0266789) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29656 ± 0.00498492 (W 0.00248802) | 1.71338 ± 0.0046261 (W 0.00251158) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 5.92676 ± 0.0195829 (W 0.00758576) | 7.87813 ± 0.00254871 (W 0.0114621) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 30.8358 ± 0.0819247 (W 0.0139887) | 40.2765 ± 0.0450431 (W 0.0247494) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.03533 ± 0.014461 (W 0.0173046) | 2.096 ± 0.0177818 (W 0.0261586) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.5099 ± 0.0387074 (W 0.0522696) | 8.72894 ± 0.0210759 (W 0.00801123) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 32.5108 ± 0.0692545 (W 0.0439344) | 41.1156 ± 0.273789 (W 0.565854) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.30015 ± 0.00587993 (W 0.00780058) | 1.4883 ± 0.00926449 (W 0.00529246) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.59331 ± 0.0263828 (W 0.0350681) | 6.97386 ± 0.0103954 (W 0.0261202) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 24.4661 ± 0.0209983 (W 0.0663275) | 33.7066 ± 0.619884 (W 0.690888) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.04318 ± 0.0206277 (W 0.0101539) | 2.26378 ± 0.0105782 (W 0.011441) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.41995 ± 0.0304887 (W 0.0298814) | 9.20148 ± 0.0261495 (W 0.0501724) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 30.3591 ± 0.0606855 (W 0.0699608) | 43.7088 ± 0.44938 (W 0.392088) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29801 ± 0.0108433 (W 0.00274827) | 1.48888 ± 0.00432065 (W 0.00211118) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.67007 ± 0.0062702 (W 0.0154186) | 7.09592 ± 0.0360554 (W 0.00686808) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 24.2125 ± 0.0935566 (W 0.0446784) | 35.9358 ± 0.0478834 (W 0.376222) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.33437 ± 0.00204309 (W 0.0040818) | 2.34621 ± 0.0043439 (W 0.00163829) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.0845 ± 0.0184754 (W 0.011599) | 11.2257 ± 0.01039 (W 0.0285174) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 57.6236 ± 0.106292 (W 0.0460044) | 61.2048 ± 0.205245 (W 0.0308288) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29895 ± 0.00251566 (W 0.00282387) | 1.67903 ± 0.00580205 (W 0.00181913) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 5.89535 ± 0.00476831 (W 0.0034626) | 7.72645 ± 0.00654276 (W 0.0063471) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 30.2772 ± 0.0954421 (W 0.0115494) | 39.7552 ± 0.0690023 (W 0.0205532) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.04631 ± 0.0192448 (W 0.0265947) | 2.10861 ± 0.0377609 (W 0.0235682) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.39849 ± 0.0227647 (W 0.027488) | 8.70406 ± 0.010721 (W 0.0130021) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 31.9158 ± 0.0651985 (W 0.0522467) | 41.3039 ± 0.340333 (W 0.859327) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29885 ± 0.00870026 (W 0.0012114) | 1.46078 ± 0.00931464 (W 0.00176838) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.48208 ± 0.0290756 (W 0.0167948) | 6.79636 ± 0.0278427 (W 0.0691758) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.932 ± 0.0565904 (W 0.0680749) | 33.4631 ± 0.456091 (W 0.527799) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.06504 ± 0.00608883 (W 0.0238867) | 2.2895 ± 0.00121079 (W 0.0188196) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.31407 ± 0.0176695 (W 0.0245847) | 9.15711 ± 0.0403278 (W 0.0478379) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 29.7988 ± 0.0391019 (W 0.101162) | 43.2584 ± 0.256839 (W 0.415357) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.29981 ± 0.00953755 (W 0.00170816) | 1.46206 ± 0.00356182 (W 0.00274665) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.5752 ± 0.00958476 (W 0.0269535) | 6.93451 ± 0.0202865 (W 0.0133625) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.6412 ± 0.0783642 (W 0.0527657) | 34.8643 ± 0.354837 (W 0.632201) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.35503 ± 0.0122565 (W 0.00308097) | 3.37231 ± 0.0060929 (W 0.00463103) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.1799 ± 0.0273547 (W 0.0197639) | 19.5286 ± 0.0536968 (W 0.0183261) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 116.964 ± 0.460979 (W 0.202718) | 122.179 ± 0.42021 (W 0.0749069) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.74976 ± 0.00904147 (W 0.00358762) | 2.14757 ± 0.00423658 (W 0.00164461) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.56869 ± 0.053498 (W 0.0466682) | 11.5948 ± 0.0122439 (W 0.0240114) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 58.2794 ± 0.2808 (W 0.118795) | 69.198 ± 0.214691 (W 0.0917732) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.77146 ± 0.0513079 (W 0.0432957) | 2.74046 ± 0.0237495 (W 0.024322) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.9492 ± 0.0322842 (W 0.0779095) | 13.6114 ± 0.0899581 (W 0.0193869) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 52.5415 ± 0.156301 (W 0.0614721) | 64.8161 ± 0.291577 (W 0.351914) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.73577 ± 0.00245816 (W 0.00165116) | 1.91671 ± 0.00721172 (W 0.00301795) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.72618 ± 0.028544 (W 0.0194481) | 10.3862 ± 0.037161 (W 0.0408592) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 35.7895 ± 0.0294157 (W 0.0514202) | 47.7501 ± 0.179107 (W 0.318728) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.74112 ± 0.00557561 (W 0.0136171) | 2.90529 ± 0.00687799 (W 0.0113798) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.2732 ± 0.0489576 (W 0.0525738) | 13.4704 ± 0.0257799 (W 0.0406998) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 44.8182 ± 0.0223879 (W 0.0853661) | 61.1982 ± 0.29998 (W 0.347918) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.73914 ± 0.00215258 (W 0.00279586) | 1.91642 ± 0.0068001 (W 0.00510051) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.74834 ± 0.0125964 (W 0.0287711) | 10.4876 ± 0.122874 (W 0.0488726) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.5169 ± 0.0874817 (W 0.0674163) | 48.5099 ± 0.14111 (W 0.253659) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.35362 ± 0.0058404 (W 0.00420239) | 3.36856 ± 0.0078705 (W 0.00561103) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.0516 ± 0.00939905 (W 0.0313584) | 19.3904 ± 0.0402239 (W 0.024887) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 115.783 ± 0.272576 (W 0.102279) | 120.955 ± 0.297354 (W 0.127534) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.70955 ± 0.00676479 (W 0.00234746) | 2.12074 ± 0.0034723 (W 0.00177031) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.39727 ± 0.0388814 (W 0.0400299) | 11.3951 ± 0.0276257 (W 0.0308331) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 57.1741 ± 0.297219 (W 0.112869) | 68.1102 ± 0.177081 (W 0.0616508) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.73472 ± 0.0208022 (W 0.0153567) | 2.71845 ± 0.0286079 (W 0.0447281) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.7862 ± 0.0299538 (W 0.03796) | 13.4937 ± 0.111997 (W 0.0500128) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 51.5565 ± 0.119521 (W 0.0857451) | 63.7869 ± 0.450904 (W 0.233052) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.695 ± 0.00377926 (W 0.00529142) | 1.90047 ± 0.0052289 (W 0.00560856) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.69381 ± 0.0637202 (W 0.0322354) | 10.3391 ± 0.0351604 (W 0.0892442) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 34.853 ± 0.0241245 (W 0.0587309) | 47.1237 ± 0.301045 (W 0.28537) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.70356 ± 0.0147408 (W 0.0128019) | 2.88426 ± 0.0183937 (W 0.0239039) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.0761 ± 0.0253985 (W 0.0444455) | 13.3354 ± 0.0504571 (W 0.0388973) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 43.7606 ± 0.0767273 (W 0.105149) | 60.5452 ± 0.271065 (W 0.303166) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.69736 ± 0.00830035 (W 0.00349873) | 1.89775 ± 0.0013071 (W 0.00320406) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 9.64524 ± 0.0140531 (W 0.0384366) | 10.3795 ± 0.03363 (W 0.0261483) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 32.4318 ± 0.0788368 (W 0.0541344) | 47.4965 ± 0.276468 (W 0.511638) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.50744 ± 0.00535639 (W 0.00480214) | 2.50643 ± 0.00302633 (W 0.00398804) | 3.06337 ± 0.00843308 (W 0.00271087) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 87.7465 ± 0.0498118 (W 0.117809) | 88.259 ± 0.16722 (W 0.416348) | 120.229 ± 0.430762 (W 0.266487) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.46097 ± 0.00564742 (W 0.00540803) | 1.48638 ± 0.00489402 (W 0.00568644) | 1.3952 ± 0.161355 (W 0.00343694) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 43.2813 ± 0.0440646 (W 0.0336266) | 44.8698 ± 0.0745308 (W 0.0890195) | 46.6934 ± 3.26363 (W 0.0879556) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.38247 ± 0.0186043 (W 0.0215551) | 2.80547 ± 0.0171544 (W 0.0120255) | 1.88955 ± 0.00484853 (W 0.00581394) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 45.7938 ± 0.130908 (W 0.072271) | 50.4607 ± 0.150908 (W 0.207246) | 48.7474 ± 2.68789 (W 0.157815) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.63819 ± 0.00147752 (W 0.0154549) | 2.14735 ± 0.0170587 (W 0.0254413) | 0.945937 ± 0.145857 (W 0.00639711) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 30.3545 ± 0.0704816 (W 0.147731) | 35.4283 ± 0.113809 (W 0.168836) | 22.3079 ± 3.11598 (W 0.0463558) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.50844 ± 0.012499 (W 0.0192573) | 3.19218 ± 0.0248645 (W 0.0381276) | 1.69364 ± 0.0162702 (W 0.00568404) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 39.6827 ± 0.0744381 (W 0.151272) | 50.7816 ± 0.563143 (W 5.49434) | 36.4765 ± 0.141198 (W 0.066644) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.75104 ± 0.00808885 (W 0.00991039) | 2.50807 ± 0.0226834 (W 0.0260101) | 0.810706 ± 0.190613 (W 0.00337506) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 28.6738 ± 0.0851676 (W 0.0582292) | 37.2501 ± 0.0291915 (W 1.15507) | 16.8513 ± 2.71312 (W 0.0693994) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.45106 ± 0.00403335 (W 0.00345575) | 2.44838 ± 0.00405395 (W 0.00283848) | 2.81335 ± 0.00823179 (W 0.00636829) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.4272 ± 0.261616 (W 0.115795) | 83.1691 ± 0.253479 (W 0.0628639) | 110.594 ± 0.589323 (W 0.254055) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39893 ± 0.00323522 (W 0.00174722) | 1.41028 ± 0.00403656 (W 0.00281632) | 1.24371 ± 0.00448198 (W 0.00361396) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 36.9438 ± 0.00512041 (W 0.0423883) | 39.1031 ± 0.0172188 (W 0.0269568) | 40.4151 ± 0.245188 (W 0.0789018) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.31437 ± 0.00580489 (W 0.010691) | 2.73206 ± 0.00202224 (W 0.0234957) | 1.82589 ± 0.00164085 (W 0.00574791) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.0469 ± 0.0357628 (W 0.194978) | 44.5266 ± 0.136007 (W 0.179345) | 45.6615 ± 0.115194 (W 0.0871166) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.54402 ± 0.00641113 (W 0.0123088) | 2.04944 ± 0.0162429 (W 0.0228133) | 0.904224 ± 0.00533735 (W 0.00874976) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.5754 ± 0.0486866 (W 0.163623) | 29.7187 ± 0.0730609 (W 0.135066) | 20.8806 ± 0.126058 (W 0.0461758) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.45233 ± 0.00972985 (W 0.0164524) | 3.13406 ± 0.0368401 (W 0.0289857) | 1.62876 ± 0.00507904 (W 0.00433029) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 33.9919 ± 0.0143223 (W 0.186002) | 44.3975 ± 0.47651 (W 0.503262) | 34.4179 ± 0.129312 (W 0.061673) | 🔵 faer-fork 1.31× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.68807 ± 0.00965078 (W 0.0142389) | 2.42323 ± 0.0281326 (W 0.0297422) | 0.785579 ± 0.00336898 (W 0.00315237) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 22.8872 ± 0.0731133 (W 0.0924676) | 31.604 ± 0.0749669 (W 0.0843611) | 15.8763 ± 0.0828627 (W 0.0443942) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.97769 ± 0.00454438 (W 0.00555029) | 5.99934 ± 0.0117208 (W 0.00403376) | 8.76516 ± 0.0337193 (W 0.012757) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 279.644 ± 0.347885 (W 2.74568) | 280.898 ± 0.739361 (W 0.698028) | 379.723 ± 1.80697 (W 0.696386) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.0409 ± 0.00744904 (W 0.00464581) | 3.07335 ± 0.00569129 (W 0.00704392) | 3.80547 ± 0.0242032 (W 0.00887074) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 120.096 ± 0.0837244 (W 0.1158) | 122.274 ± 0.230743 (W 0.11224) | 145.18 ± 7.76106 (W 0.422092) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.01101 ± 0.112198 (W 0.123275) | 4.38229 ± 0.0396734 (W 0.0284565) | 5.50318 ± 0.0128342 (W 0.013861) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 113.442 ± 0.0741972 (W 0.318149) | 122.623 ± 0.0937653 (W 0.2073) | 140.599 ± 0.860588 (W 0.4983) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.62523 ± 0.0171301 (W 0.0162464) | 3.05581 ± 0.033361 (W 0.0151404) | 2.82367 ± 0.00621035 (W 0.00289331) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 65.9688 ± 0.838242 (W 0.289849) | 75.0306 ± 0.0862158 (W 0.155453) | 60.0478 ± 5.2043 (W 0.21409) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.82817 ± 0.0365376 (W 0.0226002) | 4.6261 ± 0.0288206 (W 0.0411795) | 4.41191 ± 0.00743928 (W 0.0126228) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 90.9647 ± 3.03661 (W 0.196764) | 105.567 ± 0.307387 (W 0.428569) | 83.7982 ± 0.263447 (W 0.49271) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.60025 ± 0.0233997 (W 0.0142975) | 3.34672 ± 0.0368429 (W 0.0247424) | 2.29037 ± 0.0146704 (W 0.00631599) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 57.1276 ± 0.15467 (W 0.0698752) | 72.5926 ± 0.0641684 (W 0.112984) | 34.2849 ± 4.79895 (W 0.0992694) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.67× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.87768 ± 0.00800497 (W 0.00444406) | 5.88582 ± 0.00361113 (W 0.00814985) | 8.57799 ± 0.0223516 (W 0.0109655) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 267.44 ± 0.301602 (W 0.399331) | 268.816 ± 0.229438 (W 0.422074) | 370.467 ± 1.92534 (W 1.14627) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.93822 ± 0.00783489 (W 0.00482677) | 2.95374 ± 0.00513921 (W 0.00295638) | 3.67799 ± 0.0392157 (W 0.0052893) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 107.957 ± 0.262613 (W 0.395319) | 110.166 ± 0.224369 (W 0.0711966) | 142.599 ± 0.185092 (W 0.538202) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.98389 ± 0.0883427 (W 0.105075) | 4.26521 ± 0.0097892 (W 0.025457) | 5.40509 ± 0.0126221 (W 0.0334745) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 101.127 ± 0.20502 (W 0.261975) | 110.686 ± 0.044114 (W 0.158669) | 129.211 ± 6.41318 (W 0.629957) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.57422 ± 0.0751721 (W 0.0592596) | 2.95306 ± 0.0380959 (W 0.0214575) | 2.77359 ± 0.00856972 (W 0.00432186) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 53.547 ± 0.0892759 (W 0.108531) | 62.8257 ± 0.102386 (W 0.13406) | 49.0935 ± 0.207163 (W 0.419576) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.73158 ± 0.012841 (W 0.0224728) | 4.55307 ± 0.0226126 (W 0.036157) | 4.35871 ± 0.0162368 (W 0.00451096) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 73.5045 ± 0.151048 (W 0.121835) | 93.0414 ± 0.467057 (W 0.6936) | 73.9121 ± 0.191375 (W 0.327837) | 🔵 faer-fork 1.27× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.54296 ± 0.0279837 (W 0.0347358) | 3.27576 ± 0.00967889 (W 0.0395415) | 2.28946 ± 0.00762417 (W 0.00340799) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 45.1998 ± 0.0602048 (W 0.0864739) | 60.8688 ± 0.094575 (W 0.601709) | 32.5962 ± 0.301475 (W 0.102473) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.59341 ± 0.00811416 (W 0.00305847) | 1.59792 ± 0.008314 (W 0.00269423) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.0576 ± 0.155095 (W 0.0431746) | 49.4183 ± 0.223121 (W 0.0704734) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.09616 ± 0.00256798 (W 0.00598487) | 1.13857 ± 0.00431425 (W 0.00443603) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 26.4724 ± 0.0811364 (W 0.0231098) | 27.5284 ± 0.109123 (W 0.0175361) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.72301 ± 0.00949692 (W 0.012578) | 2.18005 ± 0.0068895 (W 0.0279316) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 27.1929 ± 0.124375 (W 0.231999) | 31.5831 ± 0.0230719 (W 0.133068) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.31209 ± 0.008236 (W 0.0161881) | 1.82797 ± 0.00278029 (W 0.0345785) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.9897 ± 0.123412 (W 0.109381) | 24.3929 ± 0.0492275 (W 0.123083) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.83875 ± 0.0305273 (W 0.0337719) | 2.55486 ± 0.00589591 (W 0.0493415) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.68 ± 0.78632 (W 0.102431) | 33.5882 ± 0.755355 (W 0.566448) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.42136 ± 0.015347 (W 0.0190974) | 2.19032 ± 0.0219914 (W 0.0294429) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.4332 ± 0.070016 (W 0.0928619) | 27.5274 ± 0.480054 (W 0.381345) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.58975 ± 0.00840289 (W 0.00394439) | 1.59187 ± 0.00727745 (W 0.00232588) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.069 ± 0.207242 (W 0.0414141) | 46.3318 ± 0.156832 (W 0.0566716) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.06511 ± 0.00193408 (W 0.00128537) | 1.10688 ± 0.0017325 (W 0.00129758) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 22.819 ± 0.0446436 (W 0.0182625) | 24.4473 ± 0.0640268 (W 0.0119667) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.70706 ± 0.00777121 (W 0.0203379) | 2.13899 ± 0.0237892 (W 0.0221633) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 23.9912 ± 0.22505 (W 0.175292) | 28.2775 ± 0.140962 (W 0.128056) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.27558 ± 0.0164679 (W 0.0275331) | 1.82107 ± 0.00762398 (W 0.0256954) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.6123 ± 0.208719 (W 0.149107) | 21.1217 ± 0.13977 (W 0.107813) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.83319 ± 0.013607 (W 0.0239795) | 2.50756 ± 0.0206219 (W 0.0325529) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.3759 ± 0.12061 (W 0.118227) | 30.0063 ± 0.268838 (W 0.472367) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.3987 ± 0.0100185 (W 0.0227534) | 2.13096 ± 0.0225291 (W 0.0287906) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 15.8852 ± 0.076414 (W 0.0524717) | 23.1618 ± 0.0364971 (W 0.321078) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.42029 ± 0.00907852 (W 0.00353579) | 3.42376 ± 0.009294 (W 0.00527358) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 146.837 ± 0.0430876 (W 0.196995) | 147.228 ± 0.152332 (W 0.193187) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.98294 ± 0.00427164 (W 0.0039851) | 2.03829 ± 0.00252867 (W 0.00568844) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 66.4056 ± 0.117851 (W 0.0750825) | 67.8422 ± 0.202 (W 0.0626127) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.67811 ± 0.0534526 (W 0.0441773) | 3.00819 ± 0.0140668 (W 0.0155749) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 62.3996 ± 0.0975615 (W 0.268296) | 69.4859 ± 0.124835 (W 0.428619) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.97987 ± 0.031791 (W 0.0245809) | 2.39678 ± 0.00596932 (W 0.046211) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 38.5833 ± 0.114201 (W 0.254431) | 45.7059 ± 0.0315037 (W 0.157398) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.63793 ± 0.0117848 (W 0.0231394) | 3.34133 ± 0.014224 (W 0.0274012) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.0957 ± 0.0948454 (W 0.0860612) | 63.6792 ± 1.33382 (W 0.854878) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.99468 ± 0.00990237 (W 0.0164968) | 2.74477 ± 0.0099732 (W 0.0209569) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 34.5746 ± 0.0556706 (W 0.0747804) | 46.0345 ± 0.13115 (W 0.27823) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.37582 ± 0.00365788 (W 0.0033079) | 3.38442 ± 0.00166203 (W 0.0035074) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 141.478 ± 0.111098 (W 0.0838056) | 141.866 ± 0.180258 (W 0.0681532) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.90537 ± 0.00446772 (W 0.00231389) | 1.94596 ± 0.00137221 (W 0.0014932) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 60.6451 ± 0.0478053 (W 0.0322557) | 62.1812 ± 0.108609 (W 0.060361) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.65634 ± 0.0433435 (W 0.0475582) | 2.95739 ± 0.0181156 (W 0.0119185) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 56.4747 ± 0.0339063 (W 0.230819) | 63.7519 ± 0.122225 (W 0.141841) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.92279 ± 0.0419879 (W 0.0415791) | 2.30925 ± 0.0111677 (W 0.0218877) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 32.5832 ± 0.0583534 (W 0.111622) | 39.9847 ± 0.0889241 (W 0.101673) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.59528 ± 0.00465349 (W 0.0127571) | 3.33418 ± 0.0251181 (W 0.0423219) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 43.5602 ± 0.352474 (W 0.0989927) | 57.0695 ± 0.560567 (W 1.13059) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.94495 ± 0.00483924 (W 0.013818) | 2.66665 ± 0.0122182 (W 0.0207701) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 28.86 ± 0.0483138 (W 0.0859616) | 40.4146 ± 0.095662 (W 0.0728802) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
