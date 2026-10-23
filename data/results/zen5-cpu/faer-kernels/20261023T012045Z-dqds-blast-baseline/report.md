# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `50c2b989484f063f4e1b132adc333715391d8b73`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `7c1d7a5741a132606af955e837057e8da7bc8c4f`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `e8c73ab62e08d01cc19737841d5bed2e52d1417edca08126b1423942eb7d59c6`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T02:30:38.359799Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin,qr_factor,eigh --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label dqds-blast-baseline --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T012045Z-dqds-blast-baseline/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.69%, worst 288.91% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 65 of 1800 engine cells exceed 5% and carry `!`; median within-process relative SD 0.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `eigh/n32/b1` | 0.113029 ± 0.000149219 (W 0.000175014) | 0.112158 ± 0.000114001 (W 0.00143052) | 0.100677 ± 0.000254072 (W 0.000156193) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.488435 ± 0.000791051 (W 0.00250802) | 0.484798 ± 0.00215411 (W 0.00204) | 0.394928 ± 0.000712572 (W 0.00151347) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16178 ± 0.00550854 (W 0.00182277) | 1.15766 ± 0.00383855 (W 0.00145361) | 0.915457 ± 0.0044481 (W 0.00680865) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023945 ± 6.28517e-05 (W 0.000117326) | 0.027711 ± 9.28134e-05 (W 0.000160575) | 0.014046 ± 5.34821e-05 (W 6.46243e-05) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.088303 ± 0.00137659 (W 0.000172602) | 0.130004 ± 0.000690436 (W 0.00167995) | 0.298369 ± 0.134075 (W 0.0011593) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 3.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.193298 ± 0.000522937 (W 0.00167396) | 0.284182 ± 0.0015732 (W 0.00148275) | 0.204016 ± 0.000501694 (W 0.00124587) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.184852 ± 0.00159839 (W 0.00146709) | 0.183961 ± 0.00190749 (W 0.00144994) | 0.177378 ± 0.000217829 (W 0.00131464) | · | · |  |
| `svd_thin/n64/b1` | 0.915024 ± 0.0012367 (W 0.00129419) | 0.915675 ± 0.00141903 (W 0.00082576) | 0.722448 ± 0.00617617 (W 0.00385079) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.15767 ± 0.000427404 (W 0.00430533) | 2.15626 ± 0.00149989 (W 0.00184224) | 1.7833 ± 0.0020581 (W 0.00487662) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.140263 ± 0.000594704 (W 0.00129464) | 0.14045 ± 0.000551349 (W 0.00121339) | 0.064501 ± 0.0428137 (W 9.78264e-05) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.517709 ± 0.00128847 (W 0.00157489) | 0.518241 ± 0.000792413 (W 0.00175269) | 0.265241 ± 0.000409271 (W 0.00145269) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18288 ± 0.000667717 (W 0.00137958) | 1.18611 ± 0.00105928 (W 0.00172673) | 0.62832 ± 0.00100929 (W 0.00201522) | · | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112984 ± 0.000146957 (W 0.000211356) | 0.11239 ± 0.00030763 (W 0.00015582) | 0.10596 ± 0.000296352 (W 0.0013085) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.501838 ± 0.00182376 (W 0.00193347) | 0.501158 ± 0.00261201 (W 0.00241669) | 0.272015 ± 0.00136617 (W 0.00180798) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21069 ± 0.00416339 (W 0.021985) | 1.20097 ± 0.00100937 (W 0.0136303) | 0.59344 ± 0.00229049 (W 0.00239494) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023924 ± 5.17397e-05 (W 7.33021e-05) | 0.087714 ± 0.00181386 (W 0.0016919) | 0.014017 ± 7.07602e-05 (W 4.20714e-05) | 🔵 faer-fork 3.67× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.119025 ± 0.0075573 (W 0.00570449) | 0.456437 ± 0.00380263 (W 0.0142707) | 0.298284 ± 0.133921 (W 0.00187112) | 🔵 faer-fork 3.83× faster than `faer-upstream` | 🔵 faer-fork 2.51× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.227901 ± 0.0162597 (W 0.0106431) | 0.946242 ± 0.00481566 (W 0.0133854) | 0.942034 ± 0.000493487 (W 0.00135744) | 🔵 faer-fork 4.15× faster than `faer-upstream` | 🔵 faer-fork 4.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.182829 ± 0.000357878 (W 0.00169137) | 0.182575 ± 0.000198349 (W 0.00124072) | 0.185618 ± 0.000107853 (W 0.00101552) | · | · |  |
| `svd_thin/n64/b1` | 0.950147 ± 0.00152798 (W 0.00205322) | 0.949455 ± 0.00104007 (W 0.00312099) | 0.67804 ± 0.00819961 (W 0.00190309) | · | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.30701 ± 0.033322 (W 0.0139228) | 2.26586 ± 0.0107424 (W 0.0175745) | 1.49944 ± 0.00816917 (W 0.00558162) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.139799 ± 0.000248037 (W 0.00121301) | 0.139895 ± 0.000204912 (W 0.00126523) | 0.064492 ± 0.0427852 (W 5.72713e-05) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.517849 ± 0.000886852 (W 0.00198164) | 0.517759 ± 0.000723033 (W 0.00216143) | 0.26971 ± 0.00061911 (W 0.00122442) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18261 ± 0.000924996 (W 0.00198281) | 1.1844 ± 0.00250282 (W 0.00127859) | 0.604062 ± 0.00266398 (W 0.00151462) | · | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.113222 ± 0.000434882 (W 0.000356168) | 0.11227 ± 7.63042e-05 (W 0.000159732) | 0.106932 ± 0.000405947 (W 0.000201095) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.507502 ± 0.00288513 (W 0.00374678) | 0.506759 ± 0.00138273 (W 0.0054693) | 0.262932 ± 0.00132962 (W 0.00173978) | · | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.23203 ± 0.00821402 (W 0.0267312) | 1.25706 ± 0.00539709 (W 0.0235195) | 0.575698 ± 0.00246143 (W 0.00148528) | · | 🔴 faer-fork 2.14× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023905 ± 0.000135758 (W 8.63134e-05) | 0.123031 ± 0.00249207 (W 0.0033498) | 0.014056 ± 6.50641e-05 (W 6.64552e-05) | 🔵 faer-fork 5.15× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.114222 ± 0.0039612 (W 0.00173634) | 0.620532 ± 0.00812564 (W 0.00629174) | 0.298369 ± 0.134083 (W 0.00158387) | 🔵 faer-fork 5.43× faster than `faer-upstream` | 🔵 faer-fork 2.61× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.235577 ± 0.0154474 (W 0.0166731) | 1.28528 ± 0.00738832 (W 0.0146636) | 0.940275 ± 0.00125326 (W 0.00127944) | 🔵 faer-fork 5.46× faster than `faer-upstream` | 🔵 faer-fork 3.99× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.182779 ± 0.000981291 (W 0.00118949) | 0.182579 ± 0.00108108 (W 0.0015548) | 0.186182 ± 0.000348753 (W 0.00133917) | · | · |  |
| `svd_thin/n64/b1` | 0.965984 ± 0.00251638 (W 0.00461275) | 0.965061 ± 0.00115854 (W 0.00470557) | 0.658101 ± 0.00264887 (W 0.00177532) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31363 ± 0.00995439 (W 0.0201723) | 2.31136 ± 0.0171375 (W 0.0140001) | 1.43617 ± 0.00683741 (W 0.00438988) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.14007 ± 0.000650792 (W 0.000184581) | 0.139994 ± 0.000510449 (W 0.00151736) | 0.064381 ± 0.04297 (W 9.35853e-05) | · | 🔴 faer-fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.521868 ± 0.00314961 (W 0.00160556) | 0.523628 ± 0.00531247 (W 0.00157479) | 0.269979 ± 6.77225e-05 (W 0.00145573) | · | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18155 ± 0.00129306 (W 0.00149496) | 1.18517 ± 0.00257074 (W 0.00265274) | 0.598059 ± 0.00097933 (W 0.00223809) | · | 🔴 faer-fork 1.98× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.11345 ± 0.00044481 (W 0.000268853) | 0.112381 ± 0.000355051 (W 0.00110722) | 0.098826 ± 0.000332073 (W 0.00124322) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.487163 ± 0.000949234 (W 0.00183582) | 0.483826 ± 0.00078938 (W 0.00171658) | 0.387435 ± 0.00235616 (W 0.00204578) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.15947 ± 0.00368613 (W 0.00191147) | 1.1566 ± 0.00175879 (W 0.0018094) | 0.893246 ± 0.00403424 (W 0.0057628) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.018204 ± 7.63763e-05 (W 0.000149286) | 0.017863 ± 2.85832e-05 (W 0.000137222) | 0.011492 ± 7.2111e-05 (W 3.27613e-05) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.074161 ± 0.000177207 (W 0.00025557) | 0.07391 ± 0.00102858 (W 0.000228369) | 0.289627 ± 0.000324865 (W 0.00182817) | · | 🔵 faer-fork 3.91× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.161863 ± 0.0007205 (W 0.00108942) | 0.162347 ± 0.00176319 (W 0.00101997) | 0.929601 ± 0.0012333 (W 0.00138309) | · | 🔵 faer-fork 5.74× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.186896 ± 0.00250451 (W 0.0014256) | 0.186646 ± 0.00222282 (W 0.00109567) | 0.169187 ± 0.000244273 (W 0.00172505) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.959559 ± 0.000760843 (W 0.00255996) | 0.958936 ± 0.000701253 (W 0.00122536) | 0.699146 ± 0.00330133 (W 0.00167511) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.15465 ± 0.00106333 (W 0.00466262) | 2.15456 ± 0.00285602 (W 0.00220375) | 1.62085 ± 0.00566437 (W 0.0110013) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142617 ± 0.000428893 (W 0.00168336) | 0.142387 ± 0.000492049 (W 0.00137402) | 0.059553 ± 0.000232259 (W 0.000153415) | · | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537396 ± 0.00081555 (W 0.00189746) | 0.537436 ± 0.00246577 (W 0.002465) | 0.254742 ± 0.000393275 (W 0.00144198) | · | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19056 ± 0.00187499 (W 0.00169731) | 1.19289 ± 0.000502739 (W 0.00119477) | 0.609021 ± 0.00123795 (W 0.00154105) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.113212 ± 8.83403e-05 (W 0.00106599) | 0.112423 ± 0.000265583 (W 9.70077e-05) | 0.103855 ± 0.000278705 (W 0.00123867) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.499156 ± 0.00377913 (W 0.00272863) | 0.498632 ± 0.00439444 (W 0.00439091) | 0.266103 ± 0.00129067 (W 0.00145454) | · | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.23168 ± 0.0127848 (W 0.0225714) | 1.20896 ± 0.00514181 (W 0.02059) | 0.579745 ± 0.00177718 (W 0.00236344) | · | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.018245 ± 8.72372e-05 (W 4.87873e-05) | 0.078306 ± 0.00370301 (W 0.00548541) | 0.011522 ± 5.64535e-05 (W 7.51219e-05) | 🔵 faer-fork 4.29× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.088704 ± 0.00986088 (W 0.00163241) | 0.413935 ± 0.0125558 (W 0.00504372) | 0.289512 ± 0.000165973 (W 0.00150426) | 🔵 faer-fork 4.67× faster than `faer-upstream` | 🔵 faer-fork 3.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.219956 ± 0.015298 (W 0.00432052) | 0.813539 ± 0.0139987 (W 0.015225) | 0.93092 ± 0.000501265 (W 0.00229674) | 🔵 faer-fork 3.70× faster than `faer-upstream` | 🔵 faer-fork 4.23× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.1851 ± 0.000365221 (W 0.0010841) | 0.184756 ± 0.000273666 (W 0.00149215) | 0.176059 ± 0.000432878 (W 0.0012092) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.992461 ± 0.00336686 (W 0.00148237) | 0.991868 ± 0.00218185 (W 0.00201237) | 0.644998 ± 0.00679697 (W 0.00181414) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.26654 ± 0.0276671 (W 0.0195705) | 2.26502 ± 0.00729582 (W 0.0170109) | 1.37532 ± 0.0028595 (W 0.00241114) | · | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.141878 ± 4.89524e-05 (W 0.00135914) | 0.141567 ± 0.000187351 (W 0.000179831) | 0.059392 ± 0.000267561 (W 0.00156471) | · | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538348 ± 0.00138103 (W 0.00193414) | 0.537226 ± 0.00252116 (W 0.00192785) | 0.258229 ± 0.00108043 (W 0.00234363) | · | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19063 ± 0.00133704 (W 0.00179254) | 1.19016 ± 0.00342418 (W 0.0018183) | 0.603741 ± 0.000944977 (W 0.00168362) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.113572 ± 0.000219619 (W 0.00147724) | 0.112049 ± 0.000555645 (W 0.000177021) | 0.104864 ± 0.000543379 (W 0.000327515) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.508443 ± 0.00249993 (W 0.00305148) | 0.50341 ± 0.00109069 (W 0.00309055) | 0.258534 ± 0.000845557 (W 0.00186357) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.25757 ± 0.0204205 (W 0.0349365) | 1.23723 ± 0.0127203 (W 0.0148958) | 0.562892 ± 0.000387372 (W 0.00136476) | · | 🔴 faer-fork 2.23× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.018244 ± 8.5049e-05 (W 0.000105006) | 0.108515 ± 0.00138281 (W 0.00348932) | 0.011642 ± 0.000128582 (W 5.80517e-05) | 🔵 faer-fork 5.95× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.092653 ± 0.000152935 (W 0.00173006) | 0.583612 ± 0.0138442 (W 0.0204238) | 0.289477 ± 0.000324877 (W 0.00152482) | 🔵 faer-fork 6.30× faster than `faer-upstream` | 🔵 faer-fork 3.12× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.209565 ± 0.00359549 (W 0.0131799) | 1.16187 ± 0.0107827 (W 0.0146343) | 0.929871 ± 0.0010127 (W 0.000505826) | 🔵 faer-fork 5.54× faster than `faer-upstream` | 🔵 faer-fork 4.44× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.185584 ± 0.000728303 (W 0.00171009) | 0.185294 ± 0.000879197 (W 0.00121199) | 0.177415 ± 0.000753014 (W 0.00131301) | · | · |  |
| `svd_thin/n64/b1` | 1.00677 ± 0.00767589 (W 0.00227451) | 1.00982 ± 0.00577664 (W 0.0038073) | 0.641361 ± 0.00113204 (W 0.00312469) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.30726 ± 0.00879106 (W 0.01712) | 2.33391 ± 0.0143095 (W 0.0186619) | 1.32211 ± 0.00656902 (W 0.00206511) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142194 ± 0.000594789 (W 0.000164321) | 0.142239 ± 0.000642757 (W 0.00114972) | 0.059441 ± 0.000116809 (W 0.000123601) | · | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.544199 ± 0.00343019 (W 0.00171302) | 0.542024 ± 0.00323042 (W 0.00193933) | 0.258294 ± 0.00105169 (W 0.00209429) | · | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19025 ± 0.000807704 (W 0.00191124) | 1.19313 ± 0.00111062 (W 0.00219244) | 0.598911 ± 0.00329557 (W 0.00207183) | · | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141636 ± 0.000197279 (W 0.00148464) | 0.14258 ± 0.000410104 (W 0.00132813) | 0.151317 ± 0.000570845 (W 0.00134394) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.649074 ± 0.000943338 (W 0.00243658) | 0.650361 ± 0.00143219 (W 0.0014408) | 0.811715 ± 0.00133726 (W 0.00211495) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.61592 ± 0.00306045 (W 0.00275153) | 1.61657 ± 0.000818339 (W 0.00306243) | 2.03142 ± 0.00155086 (W 0.00217424) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039714 ± 0.000206505 (W 0.0012503) | 0.045546 ± 7.35686e-05 (W 0.000151661) | 0.028765 ± 0.0479189 (W 6.88709e-05) | 🔵 faer-fork 1.15× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.175863 ± 0.00033264 (W 0.00045268) | 0.23727 ± 0.0012546 (W 0.00130674) | 0.166375 ± 0.000170555 (W 0.00137272) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.424126 ± 0.00334426 (W 0.00171751) | 0.533649 ± 0.00239774 (W 0.00207236) | 0.516247 ± 0.00170585 (W 0.00195573) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.234184 ± 0.00296781 (W 0.00162228) | 0.235176 ± 0.00232205 (W 0.00121734) | 0.253024 ± 0.000721077 (W 0.00134159) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22534 ± 0.00256361 (W 0.00167234) | 1.22821 ± 0.00183205 (W 0.00228924) | 1.34469 ± 0.00234507 (W 0.00210764) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.14181 ± 0.00437605 (W 0.00210536) | 3.13959 ± 0.0035671 (W 0.00333075) | 3.48874 ± 0.00189474 (W 0.00319379) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.160317 ± 0.000275516 (W 0.00141791) | 0.160794 ± 0.000207018 (W 0.00127824) | 0.103096 ± 0.121652 (W 0.00135581) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.648782 ± 0.000154733 (W 0.00185376) | 0.651868 ± 0.000483347 (W 0.00245364) | 0.490799 ± 0.00227157 (W 0.00151813) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50887 ± 0.00536496 (W 0.00185506) | 1.51115 ± 0.00415261 (W 0.0015718) | 1.37715 ± 0.0040639 (W 0.00207955) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141365 ± 0.0003685 (W 0.00122871) | 0.14275 ± 0.000385213 (W 0.00110382) | 0.155789 ± 0.000357206 (W 0.00115357) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.635872 ± 0.00179758 (W 0.00283749) | 0.640971 ± 0.00140861 (W 0.00369183) | 0.568935 ± 0.000663823 (W 0.00252263) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.5434 ± 0.012165 (W 0.00843634) | 1.53503 ± 0.00305234 (W 0.0135496) | 1.1573 ± 0.00217729 (W 0.00189064) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040216 ± 0.000261402 (W 0.000292251) | 0.112212 ± 0.00272915 (W 0.00419947) | 0.028824 ± 0.0479504 (W 4.81664e-05) | 🔵 faer-fork 2.79× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.184389 ± 0.00270074 (W 0.00385613) | 0.612897 ± 0.00620684 (W 0.0063587) | 0.76187 ± 0.345658 (W 0.00101189) | 🔵 faer-fork 3.32× faster than `faer-upstream` | 🔵 faer-fork 4.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.375156 ± 0.0100166 (W 0.0118756) | 1.14241 ± 0.00998098 (W 0.0234344) | 2.45571 ± 0.00237272 (W 0.00263246) | 🔵 faer-fork 3.05× faster than `faer-upstream` | 🔵 faer-fork 6.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.233117 ± 0.000665514 (W 0.00155601) | 0.234232 ± 0.000423756 (W 0.00118071) | 0.261284 ± 0.000223812 (W 0.00158827) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.19896 ± 0.00448244 (W 0.00702522) | 1.19463 ± 0.00426373 (W 0.00229946) | 1.03017 ± 0.00148867 (W 0.00114143) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.95417 ± 0.0107349 (W 0.0132792) | 2.96289 ± 0.00171544 (W 0.0388078) | 2.52699 ± 0.00155964 (W 0.00210656) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.160072 ± 0.000183315 (W 0.00152181) | 0.160864 ± 0.000397152 (W 0.00131986) | 0.102163 ± 0.122058 (W 0.00161936) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.648295 ± 0.00163003 (W 0.00255731) | 0.65146 ± 0.000112594 (W 0.00215389) | 0.490778 ± 0.000989184 (W 0.0019245) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50512 ± 0.00312611 (W 0.00228418) | 1.5077 ± 0.00124949 (W 0.00435179) | 1.35739 ± 0.000838173 (W 0.00159512) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141522 ± 0.000226913 (W 0.00134203) | 0.141915 ± 0.000610251 (W 0.0014407) | 0.156796 ± 0.000381308 (W 0.00110387) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.642503 ± 0.00400645 (W 0.00434424) | 0.651149 ± 0.00241255 (W 0.00511948) | 0.54011 ± 0.00207229 (W 0.00204017) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54081 ± 0.00822888 (W 0.0243541) | 1.59504 ± 0.00596911 (W 0.00900547) | 1.03678 ± 0.00272925 (W 0.00352209) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039756 ± 0.000250003 (W 0.00127133) | 0.13901 ± 0.0021973 (W 0.00204294) | 0.028855 ± 0.0480956 (W 0.00139987) | 🔵 faer-fork 3.50× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.176347 ± 0.00122665 (W 0.00226577) | 0.751955 ± 0.00786753 (W 0.00589088) | 0.762969 ± 0.345946 (W 0.00170885) | 🔵 faer-fork 4.26× faster than `faer-upstream` | 🔵 faer-fork 4.33× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.391709 ± 0.000620689 (W 0.00401726) | 1.52154 ± 0.0163977 (W 0.0250632) | 2.45346 ± 0.000415523 (W 0.00256162) | 🔵 faer-fork 3.88× faster than `faer-upstream` | 🔵 faer-fork 6.26× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.234916 ± 0.00051731 (W 0.00133846) | 0.235515 ± 0.000531146 (W 0.00209127) | 0.262415 ± 0.000331853 (W 0.000984577) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20932 ± 0.00276618 (W 0.00318174) | 1.22767 ± 0.011205 (W 0.00639807) | 0.992874 ± 0.0027311 (W 0.00185085) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96249 ± 0.0249234 (W 0.0222534) | 3.07386 ± 0.0139794 (W 0.0118771) | 2.34442 ± 0.00509545 (W 0.00387475) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.161084 ± 0.000861166 (W 0.00149216) | 0.160913 ± 0.00093872 (W 0.00125307) | 0.102243 ± 0.122101 (W 0.00159294) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.648755 ± 0.000235649 (W 0.00167317) | 0.650138 ± 0.000590498 (W 0.0022275) | 0.489366 ± 0.000553518 (W 0.00137382) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50623 ± 0.00163552 (W 0.00203276) | 1.51031 ± 0.00338612 (W 0.00235375) | 1.39105 ± 0.0240096 (W 0.00188341) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141185 ± 0.000294883 (W 0.00142869) | 0.142379 ± 0.000336379 (W 0.00137943) | 0.148999 ± 0.000330443 (W 0.00129174) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.649254 ± 0.000838351 (W 0.00133312) | 0.651052 ± 0.00382378 (W 0.00192594) | 0.803981 ± 0.00167745 (W 0.00289724) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.61669 ± 0.00296728 (W 0.00198413) | 1.6154 ± 0.0010128 (W 0.00214162) | 2.00901 ± 0.00236984 (W 0.00297282) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.032992 ± 0.000349859 (W 0.000206711) | 0.033333 ± 0.000237593 (W 0.000355064) | 0.026169 ± 3.69369e-05 (W 5.02991e-05) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.157365 ± 0.000997259 (W 0.000288403) | 0.162167 ± 0.000803663 (W 0.00161402) | 0.756111 ± 0.000323791 (W 0.00154795) | · | 🔵 faer-fork 4.80× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.38869 ± 0.00105669 (W 0.00161447) | 0.397114 ± 0.00051649 (W 0.00196713) | 2.43961 ± 0.00196543 (W 0.00188171) | · | 🔵 faer-fork 6.28× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.231329 ± 0.00221706 (W 0.00163884) | 0.232751 ± 0.00348881 (W 0.00175606) | 0.248901 ± 0.000248369 (W 0.00152657) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25844 ± 0.00304928 (W 0.00128997) | 1.2614 ± 0.00278045 (W 0.0041745) | 1.31589 ± 0.00218219 (W 0.00323438) | · | · |  |
| `svd_thin/n96/b1` | 3.09493 ± 0.00369312 (W 0.00478084) | 3.09412 ± 0.00489747 (W 0.00246123) | 3.42294 ± 0.00358753 (W 0.0066938) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158264 ± 0.000216879 (W 0.00127752) | 0.158637 ± 0.000219991 (W 0.00130396) | 0.100456 ± 0.000364522 (W 0.000149249) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625722 ± 0.000186984 (W 0.00199648) | 0.627167 ± 0.0020391 (W 0.00248734) | 0.479299 ± 0.00192314 (W 0.00177224) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48339 ± 0.00585902 (W 0.00233824) | 1.4858 ± 0.00588088 (W 0.00223655) | 1.33992 ± 0.00446802 (W 0.00163013) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141264 ± 0.000361751 (W 0.00166601) | 0.142344 ± 0.000735027 (W 0.001124) | 0.154141 ± 0.000367492 (W 0.00168541) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.648135 ± 0.00584679 (W 0.00425793) | 0.640489 ± 0.000320916 (W 0.00291495) | 0.556151 ± 0.00281521 (W 0.00241375) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54073 ± 0.0121823 (W 0.0171839) | 1.54066 ± 0.00512961 (W 0.0112068) | 1.14056 ± 0.00187535 (W 0.00162823) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033462 ± 0.000301955 (W 0.000274819) | 0.09527 ± 0.000403676 (W 0.00460977) | 0.026209 ± 5.54106e-05 (W 9.87183e-05) | 🔵 faer-fork 2.85× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.155334 ± 0.00993074 (W 0.00533581) | 0.502892 ± 0.00416657 (W 0.00727631) | 0.755628 ± 0.000348721 (W 0.00146026) | 🔵 faer-fork 3.24× faster than `faer-upstream` | 🔵 faer-fork 4.86× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.33322 ± 0.00187136 (W 0.00512945) | 0.984821 ± 0.0136683 (W 0.016534) | 2.44139 ± 0.00234333 (W 0.00261519) | 🔵 faer-fork 2.96× faster than `faer-upstream` | 🔵 faer-fork 7.33× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.231133 ± 0.000380529 (W 0.00139284) | 0.231477 ± 0.000115786 (W 0.00173154) | 0.256816 ± 0.00277604 (W 0.00206978) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22359 ± 0.00189881 (W 0.00175254) | 1.23077 ± 0.0237022 (W 0.0258985) | 1.00898 ± 0.00279305 (W 0.00151097) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.91651 ± 0.00613086 (W 0.0279542) | 2.94005 ± 0.00552009 (W 0.0234771) | 2.50866 ± 0.00269807 (W 0.00255735) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.157775 ± 0.000104543 (W 0.00117013) | 0.15902 ± 0.000312692 (W 0.00120104) | 0.100538 ± 0.000151186 (W 0.000225819) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.624219 ± 0.000675006 (W 0.00156498) | 0.624338 ± 0.00181972 (W 0.00158558) | 0.481532 ± 0.000643221 (W 0.00203494) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.47903 ± 0.00334619 (W 0.00239239) | 1.481 ± 0.00435507 (W 0.00190008) | 1.34175 ± 0.00201086 (W 0.00191791) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.140801 ± 0.000138262 (W 0.000335782) | 0.141833 ± 0.000231487 (W 0.00134658) | 0.154379 ± 0.000151368 (W 0.00109465) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.644446 ± 0.00213759 (W 0.00358697) | 0.650367 ± 0.00196462 (W 0.00372858) | 0.530444 ± 0.00105594 (W 0.00232106) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53795 ± 0.0109474 (W 0.0199313) | 1.59635 ± 0.00485754 (W 0.0153922) | 1.01903 ± 0.00316007 (W 0.00254019) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.032441 ± 0.000596667 (W 0.00042222) | 0.128262 ± 0.00150741 (W 0.00327218) | 0.026219 ± 0.0001 (W 6.87546e-05) | 🔵 faer-fork 3.95× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.161062 ± 0.0121415 (W 0.00667399) | 0.689481 ± 0.0213425 (W 0.0256751) | 0.75775 ± 0.00102907 (W 0.0021276) | 🔵 faer-fork 4.28× faster than `faer-upstream` | 🔵 faer-fork 4.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.351472 ± 0.00244117 (W 0.00578712) | 1.31291 ± 0.0133398 (W 0.0265746) | 2.44069 ± 0.00224448 (W 0.00200854) | 🔵 faer-fork 3.74× faster than `faer-upstream` | 🔵 faer-fork 6.94× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232469 ± 0.000741786 (W 0.00162172) | 0.233681 ± 0.000847374 (W 0.00186948) | 0.257637 ± 0.00100671 (W 0.00139624) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2357 ± 0.00687589 (W 0.0029593) | 1.25197 ± 0.00825328 (W 0.00786368) | 0.975221 ± 0.00345234 (W 0.00177629) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.93127 ± 0.0125171 (W 0.0218705) | 3.04707 ± 0.0149188 (W 0.0128513) | 2.33185 ± 0.00304268 (W 0.00287326) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158409 ± 0.000603826 (W 0.00148059) | 0.159 ± 0.000735684 (W 0.00132905) | 0.10046 ± 0.000108519 (W 0.000117539) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.624519 ± 0.000141774 (W 0.00232464) | 0.62473 ± 0.000472416 (W 0.00218317) | 0.479467 ± 0.000689354 (W 0.0018559) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48167 ± 0.00389805 (W 0.00395635) | 1.4802 ± 0.00255462 (W 0.00297363) | 1.33801 ± 0.00133943 (W 0.00180586) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087296 ± 0.000215168 (W 0.00153012) | 0.086984 ± 0.000103365 (W 0.000140961) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.322198 ± 0.000156845 (W 0.00189259) | 0.321378 ± 0.0010537 (W 0.00175257) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.756163 ± 0.000965622 (W 0.00142953) | 0.754539 ± 0.00111748 (W 0.00165957) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020779 ± 0.0001005 (W 5.2098e-05) | 0.024076 ± 7.53459e-05 (W 8.07855e-05) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.082134 ± 0.000307906 (W 0.000112952) | 0.119151 ± 0.000318961 (W 0.00126796) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.178478 ± 0.000719868 (W 0.00128768) | 0.253926 ± 0.000278941 (W 0.00140919) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.139278 ± 0.000705902 (W 0.0014765) | 0.139488 ± 0.000930285 (W 0.00133378) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.542816 ± 0.000858381 (W 0.00215501) | 0.542046 ± 0.00385585 (W 0.00218796) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.57583 ± 0.00496165 (W 0.00472596) | 1.57551 ± 0.00316883 (W 0.00228327) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110597 ± 0.00028424 (W 0.00108515) | 0.11089 ± 0.000295425 (W 0.00103487) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.399859 ± 0.00112357 (W 0.00148353) | 0.401329 ± 0.00126524 (W 0.00167993) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.887302 ± 0.00245899 (W 0.00173723) | 0.887552 ± 0.000370355 (W 0.00138972) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087004 ± 9.0633e-05 (W 0.00108374) | 0.086602 ± 0.000264664 (W 0.000246824) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.338179 ± 0.00182992 (W 0.00267325) | 0.358207 ± 0.000990858 (W 0.00255872) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.823197 ± 0.00499165 (W 0.0154243) | 0.84627 ± 0.00491735 (W 0.0214266) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020728 ± 9.64434e-05 (W 7.99512e-05) | 0.085812 ± 0.000376264 (W 0.00351295) | - | 🔵 faer-fork 4.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.109657 ± 0.00546612 (W 0.00130832) | 0.439305 ± 0.0111046 (W 0.00988723) | - | 🔵 faer-fork 4.01× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.229039 ± 0.029363 (W 0.0230515) | 0.906162 ± 0.017314 (W 0.0164729) | - | 🔵 faer-fork 3.96× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.137655 ± 0.000505255 (W 0.00175058) | 0.137455 ± 0.000630508 (W 0.00148201) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.583001 ± 0.0190104 (W 0.00335895) | 0.618968 ± 0.0101256 (W 0.00288506) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.68306 ± 0.00352694 (W 0.0162951) | 1.72994 ± 0.0070778 (W 0.00697061) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.11111 ± 0.000342667 (W 0.00153856) | 0.110679 ± 0.000100286 (W 0.00136539) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.40079 ± 0.00194345 (W 0.00184287) | 0.401114 ± 0.0020002 (W 0.00192034) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.888003 ± 0.00354367 (W 0.0020876) | 0.887186 ± 0.00524219 (W 0.00131039) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.086954 ± 0.000591206 (W 0.000226101) | 0.086993 ± 0.00018244 (W 0.00115628) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.342201 ± 5.37153e-05 (W 0.00330635) | 0.390531 ± 0.00639119 (W 0.00620562) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.831453 ± 0.0149851 (W 0.0132688) | 0.919797 ± 0.00567167 (W 0.0167372) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020769 ± 9.02792e-05 (W 7.15542e-05) | 0.121716 ± 0.00153804 (W 0.00712312) | - | 🔵 faer-fork 5.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.108852 ± 0.00436497 (W 0.00228493) | 0.616435 ± 0.00535853 (W 0.00542939) | - | 🔵 faer-fork 5.66× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.210658 ± 0.00804033 (W 0.00980872) | 1.25117 ± 0.0118665 (W 0.0238251) | - | 🔵 faer-fork 5.94× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.139261 ± 0.00150844 (W 0.00149602) | 0.138961 ± 0.000462071 (W 0.00157953) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.589684 ± 0.000823603 (W 0.0037231) | 0.668481 ± 0.00772448 (W 0.00995807) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.71199 ± 0.0142411 (W 0.0132445) | 1.81452 ± 0.00177135 (W 0.0192601) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110428 ± 0.000106265 (W 0.00137458) | 0.110477 ± 0.000319 (W 0.000155276) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.400139 ± 0.000801002 (W 0.00216306) | 0.400035 ± 0.000494122 (W 0.0017916) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.886506 ± 0.00163627 (W 0.00153511) | 0.888649 ± 0.00211307 (W 0.00101636) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087472 ± 0.000135803 (W 0.00143483) | 0.087163 ± 0.000401149 (W 0.000232958) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.32229 ± 0.00188048 (W 0.00157811) | 0.32064 ± 0.000318375 (W 0.0019046) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.75772 ± 0.000365232 (W 0.00152843) | 0.754984 ± 0.000353415 (W 0.00209956) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.016111 ± 4.33628e-05 (W 6.20484e-05) | 0.016412 ± 4.14045e-05 (W 4.89918e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.068268 ± 8.79261e-05 (W 0.000101637) | 0.068088 ± 0.000158689 (W 0.000115975) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.148247 ± 0.000212524 (W 0.00131568) | 0.147904 ± 0.00024415 (W 0.00147288) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.14813 ± 0.000683178 (W 0.00179442) | 0.148175 ± 0.000942594 (W 0.00140044) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.544188 ± 0.00441355 (W 0.00229769) | 0.542957 ± 0.00509345 (W 0.00189752) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.57025 ± 0.00164919 (W 0.00261686) | 1.57397 ± 0.00452271 (W 0.00299271) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110066 ± 0.000324043 (W 0.000154679) | 0.110124 ± 0.000126503 (W 0.00113303) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.401542 ± 0.00161527 (W 0.00195526) | 0.402416 ± 0.000137488 (W 0.00173793) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.871509 ± 0.00145703 (W 0.00114077) | 0.871478 ± 0.00232467 (W 0.00147092) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.086934 ± 6.13922e-05 (W 0.00130621) | 0.086722 ± 6.15007e-05 (W 0.00016002) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.338599 ± 0.000211798 (W 0.00190547) | 0.359604 ± 0.00286225 (W 0.00436749) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.821658 ± 0.00633216 (W 0.0187001) | 0.849696 ± 0.00293175 (W 0.016155) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.016181 ± 3.80832e-05 (W 0.000113446) | 0.07405 ± 0.00159329 (W 0.00514745) | - | 🔵 faer-fork 4.58× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.095217 ± 0.00721902 (W 0.00637154) | 0.409046 ± 0.00618307 (W 0.00941785) | - | 🔵 faer-fork 4.30× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.214298 ± 0.0143075 (W 0.0204851) | 0.805482 ± 0.027346 (W 0.0150197) | - | 🔵 faer-fork 3.76× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.147053 ± 0.000237591 (W 0.00101485) | 0.146873 ± 0.000473962 (W 0.00150113) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.583923 ± 0.0084156 (W 0.00245464) | 0.620901 ± 0.00784122 (W 0.00949177) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.66691 ± 0.00775401 (W 0.0160461) | 1.73547 ± 0.00155677 (W 0.0124437) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.110226 ± 0.00038759 (W 0.00188453) | 0.110078 ± 0.000253327 (W 0.000121784) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.402657 ± 0.000995419 (W 0.00211237) | 0.403202 ± 0.00151385 (W 0.00157962) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.872834 ± 0.00271752 (W 0.00137812) | 0.873291 ± 0.00278357 (W 0.00193764) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.086934 ± 0.000358366 (W 0.000152053) | 0.086823 ± 0.000484909 (W 0.000255433) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.341995 ± 0.000876714 (W 0.00282807) | 0.392599 ± 0.00481036 (W 0.0106628) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.831377 ± 0.0146587 (W 0.0118325) | 0.924194 ± 0.00957476 (W 0.0151377) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.016191 ± 4.39356e-05 (W 4.60435e-05) | 0.111036 ± 0.00274168 (W 0.00359036) | - | 🔵 faer-fork 6.86× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.088386 ± 0.00791162 (W 0.00148696) | 0.568222 ± 0.00302354 (W 0.0117305) | - | 🔵 faer-fork 6.43× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.192156 ± 0.00958202 (W 0.0065692) | 1.12969 ± 0.00998848 (W 0.0183145) | - | 🔵 faer-fork 5.88× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.148398 ± 0.00109486 (W 0.0015336) | 0.148178 ± 0.000913096 (W 0.000169577) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.591867 ± 0.00282426 (W 0.00367657) | 0.66193 ± 0.00813072 (W 0.00840675) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.69618 ± 0.00985793 (W 0.0138135) | 1.8176 ± 0.00866819 (W 0.0225018) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.109994 ± 0.000440657 (W 0.00127558) | 0.109725 ± 0.000176434 (W 0.00125218) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.401872 ± 0.000605786 (W 0.00181506) | 0.402489 ± 0.000875663 (W 0.00179575) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.871598 ± 0.00226632 (W 0.00166413) | 0.870306 ± 0.000631034 (W 0.0016602) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104227 ± 0.000695106 (W 0.00130388) | 0.103982 ± 5.90452e-05 (W 0.00132342) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.407563 ± 0.00205511 (W 0.00143399) | 0.405818 ± 0.00044355 (W 0.00171582) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.986559 ± 0.00360849 (W 0.00119401) | 0.977944 ± 0.00274636 (W 0.000822895) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.030566 ± 0.000119885 (W 0.000117132) | 0.034826 ± 1.00167e-05 (W 0.00015363) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.124726 ± 0.000481782 (W 0.00106879) | 0.18121 ± 0.000744295 (W 0.00133765) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.291606 ± 0.000397814 (W 0.00225743) | 0.408753 ± 0.00201398 (W 0.00169691) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.170927 ± 0.000322872 (W 0.0014902) | 0.170997 ± 0.000130573 (W 0.0024558) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.685166 ± 0.00185705 (W 0.00177654) | 0.686757 ± 0.000282484 (W 0.00213572) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.03451 ± 0.00217614 (W 0.00146796) | 2.0451 ± 0.00130164 (W 0.00309456) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118754 ± 0.000114692 (W 0.00119524) | 0.119211 ± 0.000281953 (W 0.00112448) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.453732 ± 0.000937686 (W 0.00147577) | 0.457265 ± 0.00283181 (W 0.00126921) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04313 ± 0.00157066 (W 0.00238533) | 1.04978 ± 0.00204936 (W 0.000863432) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.103853 ± 0.000108546 (W 0.00016979) | 0.104174 ± 0.000341896 (W 0.0017326) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.408325 ± 0.00261927 (W 0.00209601) | 0.407944 ± 0.00134684 (W 0.00269295) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.96384 ± 0.0165058 (W 0.0298478) | 0.981311 ± 0.0109313 (W 0.0351165) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.030737 ± 2.3388e-05 (W 8.31865e-05) | 0.093934 ± 0.000304503 (W 0.00467018) | - | 🔵 faer-fork 3.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.13877 ± 0.00598318 (W 0.0118327) | 0.514865 ± 0.0103377 (W 0.0128745) | - | 🔵 faer-fork 3.71× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.310707 ± 0.021066 (W 0.00593555) | 1.03759 ± 0.0244433 (W 0.015438) | - | 🔵 faer-fork 3.34× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.170897 ± 0.000215428 (W 0.00143012) | 0.17111 ± 0.000364907 (W 0.00140266) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.690682 ± 0.0100677 (W 0.00275588) | 0.692839 ± 0.00113723 (W 0.00378714) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.01016 ± 0.00730434 (W 0.0249489) | 1.9959 ± 0.00201302 (W 0.019358) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118532 ± 0.000498075 (W 0.00155917) | 0.119183 ± 0.000308976 (W 0.00150297) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.455079 ± 0.000984253 (W 0.0020964) | 0.457266 ± 0.00141434 (W 0.00167196) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04368 ± 0.00116129 (W 0.000624844) | 1.04778 ± 0.000227227 (W 0.00141361) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.103632 ± 0.00030041 (W 0.00123427) | 0.103776 ± 8.45715e-05 (W 0.00143236) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.413247 ± 0.000769353 (W 0.00596644) | 0.411557 ± 0.000295798 (W 0.00351984) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.978797 ± 0.0117587 (W 0.0181775) | 1.01742 ± 0.0147745 (W 0.0134498) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.030647 ± 9.34897e-05 (W 0.000172131) | 0.126747 ± 0.00147914 (W 0.00560446) | - | 🔵 faer-fork 4.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.136648 ± 0.000685351 (W 0.00157318) | 0.706162 ± 0.0177723 (W 0.0107155) | - | 🔵 faer-fork 5.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.285684 ± 0.00829347 (W 0.00383516) | 1.3356 ± 0.0262125 (W 0.0226753) | - | 🔵 faer-fork 4.68× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.170331 ± 0.00232829 (W 0.00155778) | 0.170342 ± 0.0022285 (W 0.00159824) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.699648 ± 0.00296904 (W 0.00370192) | 0.707133 ± 0.0136583 (W 0.00482826) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.02839 ± 0.0113593 (W 0.0146105) | 2.11095 ± 0.0037615 (W 0.0176399) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118294 ± 0.000189755 (W 0.00138886) | 0.118409 ± 0.000237072 (W 0.00135676) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.45276 ± 0.00125658 (W 0.00141026) | 0.45574 ± 0.000671819 (W 0.00209175) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.0408 ± 0.00247226 (W 0.000828101) | 1.04861 ± 0.00144307 (W 0.00112829) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104087 ± 0.000562768 (W 0.000282442) | 0.103782 ± 0.000342264 (W 0.00178086) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.407143 ± 0.001928 (W 0.00180568) | 0.406481 ± 0.00109438 (W 0.00177497) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.983001 ± 0.00355617 (W 0.00064752) | 0.977599 ± 0.00258751 (W 0.000668297) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025537 ± 0.000106588 (W 0.000103799) | 0.025808 ± 0.000167482 (W 0.000115513) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.108185 ± 0.000535905 (W 0.00167713) | 0.109357 ± 0.000357654 (W 0.0012465) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.254642 ± 0.00104283 (W 0.00146955) | 0.257588 ± 0.00231328 (W 0.00138786) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.1727 ± 0.000177348 (W 0.00125317) | 0.172967 ± 0.00123472 (W 0.0012678) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.693622 ± 0.00149197 (W 0.00186085) | 0.694333 ± 0.00108281 (W 0.00165885) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05151 ± 0.00569407 (W 0.00317041) | 2.05713 ± 0.00369245 (W 0.00236309) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118139 ± 0.000211013 (W 0.0015073) | 0.11849 ± 0.000125767 (W 0.000142444) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.44766 ± 0.0014257 (W 0.00158074) | 0.450715 ± 0.00136213 (W 0.00182146) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04179 ± 0.00102923 (W 0.000843088) | 1.04634 ± 0.00111939 (W 0.00188245) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.103714 ± 0.000360434 (W 0.00111596) | 0.104728 ± 0.000539284 (W 0.000197272) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.408872 ± 0.00168702 (W 0.00267607) | 0.409223 ± 0.00247063 (W 0.00255929) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.965293 ± 0.0036328 (W 0.0188715) | 0.961514 ± 0.0125627 (W 0.0158834) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025458 ± 0.000108029 (W 9.342e-05) | 0.0867 ± 0.00181662 (W 0.00404439) | - | 🔵 faer-fork 3.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.114244 ± 0.00076982 (W 0.00140204) | 0.432507 ± 0.00470711 (W 0.0104108) | - | 🔵 faer-fork 3.79× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.250002 ± 0.0035519 (W 0.00506216) | 0.874993 ± 0.0217665 (W 0.0117413) | - | 🔵 faer-fork 3.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.17274 ± 6.48254e-05 (W 0.00139674) | 0.172546 ± 0.000376044 (W 0.00139915) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.702834 ± 0.00269736 (W 0.00358016) | 0.700854 ± 0.0105293 (W 0.00498081) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.03503 ± 0.0157066 (W 0.0166491) | 2.0449 ± 0.0128751 (W 0.026085) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.118251 ± 0.000663719 (W 0.00128547) | 0.118672 ± 0.00021243 (W 0.00123269) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.447669 ± 0.00046617 (W 0.00194147) | 0.451412 ± 0.00106953 (W 0.00167543) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04242 ± 0.00201243 (W 0.000976355) | 1.04599 ± 0.00252092 (W 0.000805392) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.103632 ± 0.000360708 (W 0.00013609) | 0.103652 ± 0.000212486 (W 0.00108673) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.414773 ± 0.00151118 (W 0.00334319) | 0.411333 ± 0.00696083 (W 0.00339969) | - | · | - | `*` one row has no measurement here |
| `eigh/n96/b1` | 0.990639 ± 0.00148977 (W 0.0129763) | 1.0142 ± 0.0171125 (W 0.0124442) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025307 ± 7.05006e-05 (W 9.53058e-05) | 0.121436 ± 0.0044229 (W 0.00951703) | - | 🔵 faer-fork 4.80× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.118273 ± 0.000812967 (W 0.00109158) | 0.611836 ± 0.0144959 (W 0.0122562) | - | 🔵 faer-fork 5.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.262675 ± 0.0120688 (W 0.00564067) | 1.20084 ± 0.0182424 (W 0.0290286) | - | 🔵 faer-fork 4.57× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.172526 ± 0.00244259 (W 0.00137072) | 0.17236 ± 0.00238904 (W 0.00128713) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.71001 ± 0.00516409 (W 0.00461381) | 0.714276 ± 0.00934347 (W 0.00567966) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.04909 ± 0.00179532 (W 0.014222) | 2.13458 ± 0.00953051 (W 0.022762) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.117722 ± 0.00017806 (W 0.00117547) | 0.118079 ± 8.43267e-05 (W 0.000122173) | - | · | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.448913 ± 0.00264472 (W 0.00172364) | 0.448322 ± 0.000749172 (W 0.00246871) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04241 ± 0.00303756 (W 0.00106632) | 1.046 ± 0.00155155 (W 0.00136414) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/32`, `eigh/64`, `eigh/96`, `qr_factor/32`, `qr_factor/64`, `qr_factor/96`, `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.25569 ± 0.00339331 (W 0.00254889) | 2.25286 ± 0.00249245 (W 0.00569116) | 1.85997 ± 0.0157313 (W 0.00360018) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.83755 ± 0.0468027 (W 0.00589321) | 9.8527 ± 0.0761246 (W 0.0107311) | 10.0566 ± 0.0529311 (W 0.01539) | · | · |  |
| `eigh/n512/b1` | 49.0938 ± 0.308433 (W 0.0374938) | 48.8736 ± 0.284897 (W 0.194483) | 61.1383 ± 0.150259 (W 0.0405983) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.331024 ± 0.00144916 (W 0.00247928) | 0.531407 ± 0.00246226 (W 0.00266643) | 0.367723 ± 0.0010921 (W 0.00144607) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.61137 ± 0.0184652 (W 0.0012499) | 2.87322 ± 0.00453387 (W 0.00632237) | 2.03641 ± 0.0039292 (W 0.00305581) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.90437 ± 0.0557524 (W 0.00379406) | 17.5702 ± 0.00839041 (W 0.0164025) | 14.2435 ± 0.0217147 (W 0.0258803) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.69206 ± 0.00804378 (W 0.0041529) | 3.68961 ± 0.00471521 (W 0.00785379) | 3.39424 ± 0.000274491 (W 0.0105131) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.505 ± 0.0281071 (W 0.0205727) | 18.5084 ± 0.028366 (W 0.0185793) | 18.0845 ± 0.0303717 (W 0.0272284) | · | · |  |
| `svd_thin/n512/b1` | 105.91 ± 0.0899973 (W 0.0256674) | 105.699 ± 0.135904 (W 0.106853) | 116.672 ± 0.701797 (W 0.095972) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69296 ± 0.0139276 (W 0.00454686) | 2.68546 ± 0.0101353 (W 0.00442567) | 1.19733 ± 0.00402859 (W 0.00220251) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.468 ± 0.0360585 (W 0.018) | 12.4675 ± 0.0432036 (W 0.018432) | 6.99684 ± 0.0364477 (W 0.0133725) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.4692 ± 0.21745 (W 0.0458953) | 66.4473 ± 0.195327 (W 0.0250893) | 47.8895 ± 0.363658 (W 0.046213) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.31464 ± 0.0238904 (W 0.0228478) | 2.27538 ± 0.0261372 (W 0.0119618) | 1.07505 ± 0.00408477 (W 0.0046592) | · | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.04961 ± 0.0610895 (W 0.0328665) | 6.9967 ± 0.100569 (W 0.029866) | 4.79499 ± 0.013175 (W 0.00856402) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.538 ± 0.0348779 (W 0.0845051) | 26.4072 ± 0.161381 (W 0.0460335) | 21.7427 ± 0.033576 (W 0.0326) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.393256 ± 0.0698949 (W 0.0146691) | 1.48876 ± 0.00539577 (W 0.0133531) | 0.197166 ± 0.000642654 (W 0.00135754) | 🔵 faer-fork 3.79× faster than `faer-upstream` | 🔴 faer-fork 1.99× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.45465 ± 0.0103348 (W 0.0293418) | 5.66921 ± 0.0313179 (W 0.0483962) | 0.666969 ± 0.00178354 (W 0.00168444) | 🔵 faer-fork 3.90× faster than `faer-upstream` | 🔴 faer-fork 2.18× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.21 ± 0.0247181 (W 0.0308692) | 22.3037 ± 0.102446 (W 0.0972617) | 3.84925 ± 0.0112541 (W 0.00662948) | 🔵 faer-fork 4.28× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02796 ± 0.0109482 (W 0.0278734) | 3.01775 ± 0.00696512 (W 0.0240832) | 2.63995 ± 0.00218411 (W 0.00628946) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6157 ± 0.0687272 (W 0.0708407) | 13.662 ± 0.0972117 (W 0.0376817) | 12.5518 ± 0.0522698 (W 0.0137381) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.577 ± 0.36236 (W 0.2876) | 61.8611 ± 0.126219 (W 0.457858) | 58.3277 ± 2.08042 (W 0.0546137) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22709 ± 0.00761006 (W 0.00464886) | 2.23039 ± 0.00846465 (W 0.00393296) | 1.13965 ± 0.00119381 (W 0.00140786) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8707 ± 0.0162768 (W 0.0238488) | 10.786 ± 0.0208375 (W 0.0527092) | 6.11751 ± 0.00678157 (W 0.00899556) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.4414 ± 0.275572 (W 0.395475) | 48.1713 ± 0.160365 (W 0.20297) | 25.815 ± 0.0276089 (W 0.0306973) | · | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.39773 ± 0.00355356 (W 0.0273044) | 2.32979 ± 0.0210596 (W 0.0178034) | 1.00335 ± 0.0076344 (W 0.00207522) | · | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.96176 ± 0.0123581 (W 0.0258012) | 7.11761 ± 0.0272691 (W 0.0253021) | 4.01087 ± 0.00344686 (W 0.012242) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 24.2924 ± 0.108854 (W 0.0521443) | 24.8679 ± 0.122882 (W 0.0989101) | 15.2041 ± 0.118154 (W 0.0425231) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.380678 ± 0.0122858 (W 0.0158024) | 1.99435 ± 0.0229103 (W 0.0255788) | 0.155029 ± 0.000536804 (W 0.00227906) | 🔵 faer-fork 5.24× faster than `faer-upstream` | 🔴 faer-fork 2.46× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.41309 ± 0.00739306 (W 0.014125) | 6.63249 ± 0.0484521 (W 0.0471454) | 0.577538 ± 0.00283236 (W 0.00377605) | 🔵 faer-fork 4.69× faster than `faer-upstream` | 🔴 faer-fork 2.45× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.84547 ± 0.0549956 (W 0.018211) | 24.9915 ± 0.072717 (W 0.0843622) | 2.31474 ± 0.00458383 (W 0.00347428) | 🔵 faer-fork 5.16× faster than `faer-upstream` | 🔴 faer-fork 2.09× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.03284 ± 0.00776127 (W 0.00830226) | 3.11518 ± 0.00533247 (W 0.0204304) | 2.51011 ± 0.00852409 (W 0.00545313) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5108 ± 0.0240781 (W 0.065873) | 13.7336 ± 0.0495153 (W 0.0288588) | 11.478 ± 0.0397532 (W 0.0165093) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.3603 ± 0.150653 (W 0.286469) | 60.726 ± 0.0641523 (W 0.503684) | 48.5383 ± 2.3875 (W 0.0610803) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.23301 ± 0.0406636 (W 0.0038238) | 2.28544 ± 0.0341201 (W 0.00571613) | 1.12798 ± 0.00286749 (W 0.00326234) | · | 🔴 faer-fork 1.98× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 11.0274 ± 0.0247519 (W 0.0196657) | 10.9713 ± 0.0256811 (W 0.0233331) | 5.99194 ± 0.0121142 (W 0.00610059) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.0326 ± 0.0820023 (W 0.46855) | 48.9433 ± 0.146766 (W 0.452632) | 22.3893 ± 0.0219362 (W 0.0229518) | · | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.25116 ± 0.00403343 (W 0.00300315) | 2.25261 ± 0.00367597 (W 0.00246796) | 1.83027 ± 0.0130863 (W 0.0103725) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.78085 ± 0.0562035 (W 0.0102594) | 9.78523 ± 0.0564741 (W 0.0144863) | 9.85657 ± 0.0184211 (W 0.0224986) | · | · |  |
| `eigh/n512/b1` | 48.527 ± 0.164977 (W 0.0333184) | 48.2553 ± 0.273943 (W 0.0203026) | 60.1273 ± 0.118543 (W 0.0955067) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.278295 ± 0.000783111 (W 0.00227716) | 0.277169 ± 0.000118051 (W 0.00155617) | 0.332558 ± 0.00209157 (W 0.00261058) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.37747 ± 0.00704311 (W 0.00201589) | 1.37897 ± 0.0102733 (W 0.00239797) | 1.90482 ± 0.0082901 (W 0.00564014) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.97667 ± 0.109422 (W 0.0082107) | 8.00126 ± 0.0948463 (W 0.00356489) | 13.4063 ± 0.0159573 (W 0.0231911) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.69233 ± 0.00501775 (W 0.0034515) | 3.68035 ± 0.0068325 (W 0.00435376) | 3.31294 ± 0.0050259 (W 0.014466) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3871 ± 0.0277468 (W 0.0211854) | 18.3633 ± 0.0109205 (W 0.0108059) | 17.707 ± 0.0111007 (W 0.0216385) | · | · |  |
| `svd_thin/n512/b1` | 104.986 ± 0.187103 (W 0.0919859) | 104.907 ± 0.110898 (W 0.0519535) | 114.701 ± 1.17208 (W 0.338014) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.6167 ± 0.0086445 (W 0.00314196) | 2.61391 ± 0.0151421 (W 0.00219082) | 1.15722 ± 0.00257329 (W 0.00404655) | · | 🔴 faer-fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2836 ± 0.0223511 (W 0.00849361) | 12.2893 ± 0.0248912 (W 0.0125253) | 6.85842 ± 0.0350704 (W 0.0129929) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.4187 ± 0.224524 (W 0.3629) | 65.3521 ± 0.237018 (W 0.0241723) | 47.1722 ± 0.286883 (W 0.0498975) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.29586 ± 0.0544065 (W 0.0467954) | 2.32514 ± 0.0198831 (W 0.0508963) | 1.05005 ± 0.00362793 (W 0.00260342) | · | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.00503 ± 0.00590453 (W 0.0283019) | 6.9508 ± 0.0183554 (W 0.0308256) | 4.67946 ± 0.00991111 (W 0.00603702) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.1069 ± 0.0354977 (W 0.0619104) | 25.998 ± 0.0313704 (W 0.067615) | 21.2164 ± 0.00933409 (W 0.0354706) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.352612 ± 0.0128467 (W 0.0105332) | 1.19663 ± 0.0105624 (W 0.017771) | 0.181731 ± 0.00107505 (W 0.00165349) | 🔵 faer-fork 3.39× faster than `faer-upstream` | 🔴 faer-fork 1.94× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.32901 ± 0.000747585 (W 0.0222043) | 3.10035 ± 0.0188027 (W 0.0267278) | 0.615909 ± 0.00565604 (W 0.00160457) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.82591 ± 0.0480189 (W 0.0316323) | 8.48184 ± 0.0814013 (W 0.0776923) | 3.69244 ± 0.0190539 (W 0.00374224) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.99885 ± 0.0183802 (W 0.0272223) | 2.99405 ± 0.00590104 (W 0.0320962) | 2.61379 ± 0.00323737 (W 0.00365114) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5881 ± 0.0478272 (W 0.0863618) | 13.5887 ± 0.0309194 (W 0.0890776) | 12.4295 ± 0.0899899 (W 0.0163171) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.7466 ± 0.2027 (W 0.204034) | 60.2194 ± 0.169711 (W 0.218097) | 57.1614 ± 1.01285 (W 0.038932) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.16108 ± 0.00772854 (W 0.0031477) | 2.1598 ± 0.00716019 (W 0.00567734) | 1.12539 ± 0.0072152 (W 0.00168839) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6755 ± 0.0166712 (W 0.040294) | 10.651 ± 0.0198258 (W 0.0252441) | 6.09354 ± 0.0251149 (W 0.00774755) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.3462 ± 0.13624 (W 0.256736) | 47.5735 ± 0.351156 (W 0.406066) | 25.8955 ± 0.191266 (W 0.0335893) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.39834 ± 0.0403485 (W 0.0249306) | 2.32242 ± 0.0702541 (W 0.0242691) | 0.987725 ± 0.00252085 (W 0.00440371) | · | 🔴 faer-fork 2.43× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.92067 ± 0.0345532 (W 0.0329567) | 7.06407 ± 0.00846352 (W 0.0288014) | 3.89295 ± 0.0108524 (W 0.010659) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.8897 ± 0.103085 (W 0.051377) | 24.5284 ± 0.106001 (W 0.0943453) | 14.8175 ± 0.0253108 (W 0.0382173) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.32997 ± 0.00266995 (W 0.00555413) | 1.61383 ± 0.011938 (W 0.0153985) | 0.14511 ± 0.000645387 (W 0.00275932) | 🔵 faer-fork 4.89× faster than `faer-upstream` | 🔴 faer-fork 2.27× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.30958 ± 0.0119709 (W 0.0130943) | 4.16385 ± 0.0458593 (W 0.0297328) | 0.542238 ± 0.00112148 (W 0.00265822) | 🔵 faer-fork 3.18× faster than `faer-upstream` | 🔴 faer-fork 2.42× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.55455 ± 0.0118843 (W 0.0196249) | 10.2191 ± 0.0415491 (W 0.0932038) | 2.24454 ± 0.00314863 (W 0.00415042) | 🔵 faer-fork 2.24× faster than `faer-upstream` | 🔴 faer-fork 2.03× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01568 ± 0.00932136 (W 0.00924074) | 3.10658 ± 0.0123026 (W 0.0256513) | 2.49308 ± 0.00598888 (W 0.00385419) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4112 ± 0.0454847 (W 0.0280769) | 13.6568 ± 0.0357008 (W 0.0272995) | 11.5273 ± 0.0829862 (W 0.0111069) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.3313 ± 0.126712 (W 0.339117) | 59.9865 ± 0.436693 (W 0.243858) | 47.7453 ± 0.835021 (W 0.0465056) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.2297 ± 0.0348805 (W 0.00616541) | 2.17028 ± 0.0299732 (W 0.00360344) | 1.12784 ± 0.00970898 (W 0.0015607) | · | 🔴 faer-fork 1.98× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8611 ± 0.0413931 (W 0.0289383) | 10.8025 ± 0.0308302 (W 0.0127499) | 5.98683 ± 0.0119647 (W 0.00704807) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.4952 ± 0.769727 (W 0.445924) | 48.1708 ± 0.297171 (W 0.315686) | 22.4584 ± 0.174223 (W 0.024429) | · | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 3.27122 ± 0.00343398 (W 0.00317342) | 3.27362 ± 0.00381852 (W 0.00820083) | 4.41421 ± 0.00547783 (W 0.00361076) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.4492 ± 0.0129452 (W 0.0171977) | 17.414 ± 0.00993138 (W 0.0146685) | 26.471 ± 0.0700603 (W 0.0283072) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.718 ± 0.227764 (W 0.0872482) | 105.25 ± 0.0138779 (W 0.462431) | 170.881 ± 0.114314 (W 0.0680208) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.809376 ± 0.00232542 (W 0.00226095) | 1.07141 ± 0.00198032 (W 0.00202736) | 0.954383 ± 0.00143739 (W 0.00210804) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.79232 ± 0.00324485 (W 0.00587503) | 6.4206 ± 0.00413494 (W 0.00777736) | 5.66441 ± 0.00714617 (W 0.00912683) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.7099 ± 0.0393872 (W 0.0269414) | 37.5368 ± 0.257034 (W 0.031358) | 38.983 ± 0.0342489 (W 0.0445449) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.74249 ± 0.00825062 (W 0.0289683) | 5.7373 ± 0.0233868 (W 0.0120095) | 7.05193 ± 0.0118158 (W 0.00838862) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.1694 ± 0.125892 (W 0.0786273) | 34.1481 ± 0.140002 (W 0.123554) | 43.3474 ± 0.267549 (W 0.0327529) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 211.423 ± 0.583647 (W 0.454521) | 211.429 ± 0.631342 (W 0.47115) | 280.066 ± 5.23938 (W 1.20963) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.4711 ± 0.00331879 (W 0.00892206) | 3.46995 ± 0.00298605 (W 0.0107356) | 2.75341 ± 0.00841968 (W 0.00355556) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.3229 ± 0.0480774 (W 0.0614646) | 19.3357 ± 0.0402531 (W 0.101592) | 18.2194 ± 0.0395325 (W 0.015686) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 111.607 ± 0.342416 (W 0.156309) | 111.79 ± 0.658679 (W 0.438268) | 123.187 ± 0.0384946 (W 0.0973262) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.99793 ± 0.0265518 (W 0.0228339) | 2.96344 ± 0.0146505 (W 0.0204272) | 2.04014 ± 0.00278486 (W 0.00386554) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.3871 ± 0.0205869 (W 0.0464273) | 11.3372 ± 0.0470806 (W 0.0463241) | 10.1059 ± 0.0398412 (W 0.0189628) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.6044 ± 0.0271692 (W 0.087999) | 46.3892 ± 0.131739 (W 0.079997) | 52.8844 ± 0.0951049 (W 0.0331936) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.603771 ± 0.00640502 (W 0.00253699) | 1.83196 ± 0.0242452 (W 0.0235356) | 0.451704 ± 0.0005295 (W 0.00204278) | 🔵 faer-fork 3.03× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.90661 ± 0.0107241 (W 0.0214934) | 7.40982 ± 0.146793 (W 0.0313641) | 1.62772 ± 0.00427846 (W 0.00226588) | 🔵 faer-fork 2.55× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.1787 ± 0.0866491 (W 0.0548627) | 26.8797 ± 0.457951 (W 0.0789225) | 11.3623 ± 0.0155522 (W 0.0131961) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.34164 ± 0.0149246 (W 0.0116745) | 4.34168 ± 0.0239799 (W 0.0309792) | 4.15247 ± 0.00918916 (W 0.00508037) | · | · |  |
| `svd_thin/n256/b1` | 22.5126 ± 0.0504445 (W 0.132163) | 22.5534 ± 0.0789266 (W 0.123298) | 21.3415 ± 0.0586914 (W 0.0406784) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 95.0513 ± 0.111483 (W 0.438321) | 94.6177 ± 0.0896749 (W 0.311214) | 114.623 ± 4.49959 (W 0.191443) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 3.04046 ± 0.0310993 (W 0.00934043) | 3.04104 ± 0.00307293 (W 0.00830271) | 2.02277 ± 0.0152785 (W 0.00313977) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.0406 ± 0.223186 (W 0.0900671) | 17.1152 ± 0.187011 (W 0.158989) | 11.1276 ± 0.0797279 (W 0.018423) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.082 ± 0.15905 (W 0.194718) | 64.9916 ± 0.355358 (W 0.290628) | 56.3332 ± 0.100976 (W 0.174563) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.93833 ± 0.0202725 (W 0.0323368) | 2.99932 ± 0.0163901 (W 0.0130639) | 1.69256 ± 0.0022794 (W 0.00464587) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7866 ± 0.027496 (W 0.034907) | 11.0893 ± 0.0448874 (W 0.0506221) | 7.98686 ± 0.0261699 (W 0.0121545) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.99 ± 0.225725 (W 0.134225) | 39.5944 ± 0.274785 (W 0.150802) | 36.8487 ± 0.0181718 (W 0.0275667) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.603146 ± 0.0151208 (W 0.00464824) | 2.34186 ± 0.0186945 (W 0.0297602) | 0.322231 ± 0.00185928 (W 0.00318069) | 🔵 faer-fork 3.88× faster than `faer-upstream` | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.4087 ± 0.0132089 (W 0.0181324) | 8.55989 ± 0.0420912 (W 0.10723) | 1.62391 ± 0.00442851 (W 0.0021554) | 🔵 faer-fork 3.55× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.41179 ± 0.0107921 (W 0.0241759) | 27.5772 ± 0.197463 (W 0.209538) | 5.82064 ± 0.00752097 (W 0.00936511) | 🔵 faer-fork 2.93× faster than `faer-upstream` | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.22199 ± 0.0134843 (W 0.0116318) | 4.46517 ± 0.0122715 (W 0.0275571) | 3.62921 ± 0.00321529 (W 0.00657818) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.2855 ± 0.0315014 (W 0.0379318) | 21.8155 ± 0.125406 (W 0.0847693) | 17.2045 ± 0.0346568 (W 0.0344441) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.0971 ± 0.0669289 (W 0.114157) | 81.393 ± 0.160812 (W 0.308965) | 84.9569 ± 4.36277 (W 0.428829) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 3.09414 ± 0.0365725 (W 0.004999) | 3.09128 ± 0.00320807 (W 0.0227954) | 1.90558 ± 0.00725326 (W 0.0029934) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.1355 ± 0.0367405 (W 0.041814) | 17.0587 ± 0.103747 (W 0.0763997) | 9.65548 ± 0.0199326 (W 0.0118526) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 61.2871 ± 0.515936 (W 0.47965) | 61.0359 ± 0.371975 (W 0.237665) | 43.1484 ± 0.44627 (W 0.0651553) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 3.25955 ± 0.00531473 (W 0.00302038) | 3.26558 ± 0.00909506 (W 0.00370514) | 4.35699 ± 0.000975518 (W 0.00399387) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.3595 ± 0.010485 (W 0.00711415) | 17.3383 ± 0.0262111 (W 0.00841255) | 26.196 ± 0.0518254 (W 0.0322538) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.219 ± 0.255749 (W 0.0533196) | 105.08 ± 0.0621908 (W 0.134034) | 169.697 ± 0.0684059 (W 0.214965) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.740596 ± 0.00107631 (W 0.00175994) | 0.755833 ± 0.00340106 (W 0.00208865) | 0.912748 ± 0.00216903 (W 0.00297769) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.44095 ± 0.0480176 (W 0.00346812) | 4.49593 ± 0.0396218 (W 0.00437378) | 5.49568 ± 0.00607062 (W 0.010736) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.4198 ± 0.0258707 (W 0.0178815) | 28.6224 ± 0.0237702 (W 0.0231135) | 37.738 ± 0.0578808 (W 0.0325479) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.71174 ± 0.0105254 (W 0.0130518) | 5.71029 ± 0.0153272 (W 0.00653981) | 6.97173 ± 0.0164218 (W 0.0087066) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.8974 ± 0.103324 (W 0.0617719) | 33.839 ± 0.165016 (W 0.0596247) | 43.1441 ± 0.999459 (W 0.0395642) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 210.492 ± 0.561352 (W 0.205161) | 210.42 ± 0.632599 (W 0.40132) | 274.871 ± 3.15663 (W 0.852797) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.44723 ± 0.00579883 (W 0.00551329) | 3.44431 ± 0.00512655 (W 0.00632913) | 2.70846 ± 0.00481063 (W 0.00426936) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 18.994 ± 0.048202 (W 0.0241645) | 19.0659 ± 0.125609 (W 0.150107) | 18.0951 ± 0.972664 (W 0.0324301) | · | · | `!` between-start range over 5% |
| `svd_values/n512/b1` | 110.699 ± 0.405884 (W 0.124418) | 110.502 ± 0.342631 (W 0.178312) | 121.473 ± 0.504179 (W 0.328783) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.98391 ± 0.0137026 (W 0.0193396) | 2.94094 ± 0.0194587 (W 0.0247689) | 1.9961 ± 0.00243195 (W 0.00422863) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.3236 ± 0.0370828 (W 0.0498338) | 11.322 ± 0.0847658 (W 0.0378916) | 9.97563 ± 0.00559557 (W 0.0184232) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.1912 ± 0.0101991 (W 0.0805911) | 46.0315 ± 0.0816148 (W 0.19226) | 52.2947 ± 0.0825168 (W 0.0861932) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.543462 ± 0.0312874 (W 0.013136) | 1.45127 ± 0.0327099 (W 0.01268) | 0.435178 ± 0.00130024 (W 0.00188407) | 🔵 faer-fork 2.67× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.69846 ± 0.00685363 (W 0.0295937) | 4.37035 ± 0.022441 (W 0.0436059) | 1.57059 ± 0.00159303 (W 0.00340932) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.2895 ± 0.118272 (W 0.0644121) | 14.7988 ± 0.0617635 (W 0.061428) | 10.9703 ± 0.00327064 (W 0.014848) | 🔵 faer-fork 1.31× faster than `faer-upstream` | · |  |
| `svd_thin/n128/b1` | 4.31877 ± 0.0136002 (W 0.0235384) | 4.3406 ± 0.0182711 (W 0.0301853) | 4.10088 ± 0.0106714 (W 0.00688465) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.2626 ± 0.0970536 (W 0.153846) | 22.2466 ± 0.0585889 (W 0.0911441) | 21.1666 ± 0.0647769 (W 0.0944926) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 93.6214 ± 0.349224 (W 0.304838) | 93.6455 ± 0.0253072 (W 0.229567) | 112.434 ± 0.915176 (W 0.157085) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.00738 ± 0.0145176 (W 0.00563891) | 3.00563 ± 0.0290281 (W 0.0188978) | 2.01334 ± 0.00276494 (W 0.00251419) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.8778 ± 0.154003 (W 0.116627) | 16.927 ± 0.165307 (W 0.126051) | 11.141 ± 0.107185 (W 0.0213412) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 64.2752 ± 0.313125 (W 0.268973) | 63.956 ± 0.496129 (W 0.170566) | 56.1685 ± 0.107523 (W 0.0900193) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.94343 ± 0.027271 (W 0.0257156) | 3.00908 ± 0.0103084 (W 0.0148605) | 1.64417 ± 0.00344405 (W 0.00257686) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7147 ± 0.0223019 (W 0.0349276) | 11.0318 ± 0.0335825 (W 0.0562989) | 7.82639 ± 0.00672835 (W 0.0107291) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.6799 ± 0.216872 (W 0.0813944) | 39.415 ± 0.0590342 (W 0.149329) | 36.414 ± 0.0408462 (W 0.0363314) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.545264 ± 0.00855163 (W 0.0040243) | 1.88567 ± 0.0244391 (W 0.028069) | 0.307725 ± 0.00158743 (W 0.00227358) | 🔵 faer-fork 3.46× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.25057 ± 0.0336852 (W 0.0201909) | 5.36458 ± 0.0714795 (W 0.0501497) | 1.58169 ± 0.00227079 (W 0.00186984) | 🔵 faer-fork 2.38× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.82814 ± 0.049351 (W 0.13232) | 15.1744 ± 0.150043 (W 0.162772) | 5.79706 ± 0.00384729 (W 0.00769672) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.19949 ± 0.00290077 (W 0.0145806) | 4.44659 ± 0.00602093 (W 0.0141125) | 3.58711 ± 0.00826354 (W 0.00665667) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.0641 ± 0.0403132 (W 0.0996508) | 21.5831 ± 0.0425003 (W 0.0580722) | 17.0642 ± 0.0152088 (W 0.0317828) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 79.131 ± 0.181157 (W 0.218994) | 80.5529 ± 0.287303 (W 0.392506) | 81.8436 ± 0.184452 (W 0.0701038) | · | · |  |
| `svd_values/n128/b1` | 3.0651 ± 0.0451539 (W 0.00609115) | 2.99589 ± 0.0340434 (W 0.0130809) | 1.89312 ± 0.00538978 (W 0.00284951) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.9002 ± 0.0810759 (W 0.0612779) | 16.8466 ± 0.05795 (W 0.0655908) | 9.6604 ± 0.0202608 (W 0.0215867) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.3358 ± 0.218408 (W 0.106729) | 60.266 ± 0.271247 (W 0.367966) | 45.5072 ± 0.0486259 (W 0.0361082) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.51099 ± 0.00344435 (W 0.00378756) | 1.51141 ± 0.00116185 (W 0.0019703) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 5.91515 ± 0.0145843 (W 0.00605355) | 5.93168 ± 0.0164664 (W 0.0114314) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 28.0281 ± 0.0977557 (W 0.0781476) | 28.1415 ± 0.135982 (W 0.0220731) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.303725 ± 0.00103763 (W 0.00178805) | 0.447091 ± 0.00174087 (W 0.00159482) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.16207 ± 0.00188249 (W 0.0024963) | 1.7736 ± 0.000363892 (W 0.00379451) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.63246 ± 0.0435425 (W 0.00867278) | 10.3205 ± 0.0609881 (W 0.0141567) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.33594 ± 0.00193859 (W 0.00264542) | 2.33381 ± 0.00243674 (W 0.00432205) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2104 ± 0.0588279 (W 0.00859425) | 11.1707 ± 0.0512425 (W 0.0145822) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 61.2954 ± 0.28043 (W 0.0279253) | 61.3641 ± 0.302479 (W 0.0450937) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.71686 ± 0.0173257 (W 0.0043244) | 1.71317 ± 0.0172088 (W 0.00276452) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.85003 ± 0.0234529 (W 0.0150525) | 7.83887 ± 0.0256485 (W 0.0123153) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 40.107 ± 0.138717 (W 0.0382188) | 40.1778 ± 0.120102 (W 0.0612451) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.56631 ± 0.00907308 (W 0.0367114) | 1.55547 ± 0.014114 (W 0.017303) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.31723 ± 0.0196337 (W 0.0200513) | 4.35638 ± 0.0191118 (W 0.0265908) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 16.6644 ± 0.0975567 (W 0.0765041) | 16.7272 ± 0.0705738 (W 0.0580523) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.325345 ± 0.00409714 (W 0.00272736) | 1.37498 ± 0.0198708 (W 0.0112478) | - | 🔵 faer-fork 4.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.26643 ± 0.00206591 (W 0.030197) | 4.40987 ± 0.00481282 (W 0.0388328) | - | 🔵 faer-fork 3.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.15592 ± 0.0228756 (W 0.0260871) | 16.5832 ± 0.0258839 (W 0.0776332) | - | 🔵 faer-fork 3.99× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.05173 ± 0.00594222 (W 0.0259057) | 2.08003 ± 0.0136556 (W 0.0184091) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.74228 ± 0.0122224 (W 0.0169279) | 8.72638 ± 0.00415862 (W 0.0261548) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.7143 ± 0.507769 (W 0.33252) | 41.7776 ± 0.142903 (W 0.460932) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.47613 ± 0.00211312 (W 0.00150114) | 1.47789 ± 0.001713 (W 0.0023817) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.97008 ± 0.0282851 (W 0.0262366) | 6.9664 ± 0.0251317 (W 0.0212616) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.6882 ± 0.387012 (W 0.481799) | 33.5633 ± 0.357989 (W 0.359704) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.56563 ± 0.0242121 (W 0.03334) | 1.64706 ± 0.018432 (W 0.017457) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.38112 ± 0.0290291 (W 0.0305224) | 4.49004 ± 0.0364769 (W 0.0266833) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 15.7954 ± 0.0632975 (W 0.0515185) | 16.3798 ± 0.0642926 (W 0.103131) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.33215 ± 0.00294305 (W 0.00546987) | 1.80168 ± 0.0371831 (W 0.0345011) | - | 🔵 faer-fork 5.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.24485 ± 0.00322339 (W 0.0124982) | 5.32717 ± 0.0390386 (W 0.0245885) | - | 🔵 faer-fork 4.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.13591 ± 0.0209997 (W 0.0124016) | 19.306 ± 0.112686 (W 0.0564242) | - | 🔵 faer-fork 4.67× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.05049 ± 0.00647922 (W 0.014378) | 2.25577 ± 0.0098344 (W 0.0295001) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.70081 ± 0.0167721 (W 0.0223245) | 9.18251 ± 0.0203061 (W 0.0598645) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 42.1036 ± 0.151212 (W 0.392934) | 43.4827 ± 0.103417 (W 0.334706) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.48022 ± 0.00226319 (W 0.00332702) | 1.47878 ± 0.00343198 (W 0.00250882) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.11175 ± 0.0381531 (W 0.014695) | 7.10917 ± 0.0250169 (W 0.0190035) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 35.7173 ± 0.274957 (W 0.213329) | 35.5712 ± 0.26588 (W 0.389425) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.50936 ± 0.00425784 (W 0.00205155) | 1.50814 ± 0.00261216 (W 0.00304318) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 5.89053 ± 0.0262379 (W 0.0097944) | 5.89926 ± 0.0217479 (W 0.00273922) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 27.8611 ± 0.11629 (W 0.0334748) | 27.8848 ± 0.142333 (W 0.0231116) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.250962 ± 0.000471265 (W 0.00134612) | 0.250141 ± 0.0021268 (W 0.00158613) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.9482 ± 0.00267195 (W 0.00109402) | 0.949532 ± 0.00263726 (W 0.00174496) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.7304 ± 0.00192282 (W 0.00593605) | 4.74259 ± 0.00492504 (W 0.00878429) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.34842 ± 0.00559432 (W 0.00268557) | 2.34854 ± 0.00518506 (W 0.00570413) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.2184 ± 0.0470537 (W 0.0117912) | 11.1881 ± 0.0585676 (W 0.0163982) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 60.8196 ± 0.171885 (W 0.0386797) | 60.8673 ± 0.25347 (W 0.0408817) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.67942 ± 0.0166573 (W 0.00231251) | 1.67779 ± 0.0174656 (W 0.00247812) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.68998 ± 0.0201728 (W 0.00715902) | 7.68104 ± 0.0212618 (W 0.0143521) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 39.5677 ± 0.126344 (W 0.0180542) | 39.6467 ± 0.152932 (W 0.064295) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.56606 ± 0.0183545 (W 0.0298625) | 1.56028 ± 0.0180213 (W 0.0246967) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.35216 ± 0.07435 (W 0.0282387) | 4.28643 ± 0.0129825 (W 0.013504) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 16.4082 ± 0.0588588 (W 0.0946152) | 16.4765 ± 0.0621066 (W 0.0545032) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.30623 ± 0.0428431 (W 0.00342184) | 1.15879 ± 0.0289201 (W 0.0174945) | - | 🔵 faer-fork 3.78× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.15823 ± 0.0120814 (W 0.0191073) | 2.90712 ± 0.029354 (W 0.0335837) | - | 🔵 faer-fork 2.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.81828 ± 0.00687004 (W 0.0301147) | 7.49821 ± 0.0647173 (W 0.131218) | - | 🔵 faer-fork 1.96× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.04695 ± 0.00944097 (W 0.0147764) | 2.09896 ± 0.00453133 (W 0.0128705) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.70813 ± 0.0282767 (W 0.0172604) | 8.70217 ± 0.0124483 (W 0.0300127) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.025 ± 0.173375 (W 0.550371) | 41.3706 ± 0.222102 (W 0.514604) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.45243 ± 0.00263156 (W 0.00193702) | 1.4559 ± 0.00392546 (W 0.00189247) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.77325 ± 0.0394608 (W 0.0147039) | 6.81105 ± 0.0339798 (W 0.0324733) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 33.2961 ± 0.282743 (W 0.504239) | 33.1877 ± 0.265025 (W 0.655874) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.54926 ± 0.029908 (W 0.0326034) | 1.62142 ± 0.0422477 (W 0.019507) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 4.33338 ± 0.0140181 (W 0.0192293) | 4.44844 ± 0.0174039 (W 0.0468568) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 15.5791 ± 0.0722961 (W 0.0522738) | 16.2848 ± 0.108973 (W 0.150579) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.300642 ± 0.00536828 (W 0.00654808) | 1.5796 ± 0.00615506 (W 0.0154004) | - | 🔵 faer-fork 5.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.16486 ± 0.00428986 (W 0.0104873) | 3.87977 ± 0.0266367 (W 0.0305348) | - | 🔵 faer-fork 3.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.92351 ± 0.00186128 (W 0.0183697) | 9.44303 ± 0.0464109 (W 0.0928681) | - | 🔵 faer-fork 2.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.04784 ± 0.00665866 (W 0.015426) | 2.26154 ± 0.0254917 (W 0.0276592) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.68621 ± 0.0324478 (W 0.02251) | 9.13895 ± 0.0328952 (W 0.04402) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 41.347 ± 0.0660416 (W 0.488202) | 43.0107 ± 0.187194 (W 0.4224) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.454 ± 0.00335172 (W 0.00257541) | 1.45454 ± 0.00728495 (W 0.00224689) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.9614 ± 0.0223395 (W 0.0189729) | 6.94935 ± 0.0152269 (W 0.0158959) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 35.0561 ± 0.182112 (W 0.436123) | 35.2155 ± 0.249864 (W 0.267516) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.05592 ± 0.00212519 (W 0.00187271) | 2.04989 ± 0.00354957 (W 0.00146832) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 10.3087 ± 0.00946751 (W 0.00922772) | 10.2281 ± 0.0114699 (W 0.00766919) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 58.8138 ± 0.134297 (W 0.400392) | 58.5798 ± 0.0185095 (W 0.0339478) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.534205 ± 0.00294208 (W 0.00201835) | 0.754771 ± 0.0016597 (W 0.0019246) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.79317 ± 0.0117129 (W 0.00532053) | 3.82208 ± 0.0068002 (W 0.00280773) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 16.5386 ± 0.127953 (W 0.0200349) | 24.4502 ± 0.105928 (W 0.0293048) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 3.36355 ± 0.000934395 (W 0.00555214) | 3.3713 ± 0.00673038 (W 0.0047515) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.4509 ± 0.131643 (W 0.0148107) | 19.5258 ± 0.0857213 (W 0.0192224) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 121.318 ± 0.151309 (W 0.355046) | 121.475 ± 0.460708 (W 0.161753) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 2.13005 ± 0.0118399 (W 0.00247877) | 2.13968 ± 0.00604478 (W 0.00601481) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 11.5493 ± 0.0501038 (W 0.0140182) | 11.5402 ± 0.0375805 (W 0.0401495) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 68.5782 ± 0.0934778 (W 0.0403815) | 68.9651 ± 0.277677 (W 0.078234) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.92056 ± 0.0285331 (W 0.0364119) | 1.92738 ± 0.0286466 (W 0.0376509) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 7.08659 ± 0.0105751 (W 0.0449679) | 7.00639 ± 0.0366112 (W 0.0272591) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 27.9322 ± 0.0261003 (W 0.0671165) | 27.8274 ± 0.0153897 (W 0.057014) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.463818 ± 0.0113914 (W 0.00757116) | 1.52262 ± 0.0174837 (W 0.0180863) | - | 🔵 faer-fork 3.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.97256 ± 0.0396678 (W 0.0199875) | 5.64195 ± 0.0655852 (W 0.0363449) | - | 🔵 faer-fork 2.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 7.70455 ± 0.0137005 (W 0.063417) | 22.2962 ± 0.254933 (W 0.0625406) | - | 🔵 faer-fork 2.89× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.7386 ± 0.0426853 (W 0.0492581) | 2.74226 ± 0.0350214 (W 0.0422504) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.5627 ± 0.0300554 (W 0.0457743) | 13.6031 ± 0.00529093 (W 0.0782857) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 64.4598 ± 0.432373 (W 0.183384) | 64.4338 ± 0.261623 (W 0.339662) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.91187 ± 0.00169296 (W 0.0051233) | 1.91543 ± 0.00704864 (W 0.00369396) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.3345 ± 0.0357202 (W 0.0533433) | 10.3714 ± 0.0265699 (W 0.0889602) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.7489 ± 0.340062 (W 0.354581) | 47.8005 ± 0.23821 (W 0.376394) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.90791 ± 0.0111701 (W 0.0201609) | 1.97906 ± 0.00685394 (W 0.0121942) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 6.79297 ± 0.016726 (W 0.0402488) | 6.83599 ± 0.0451356 (W 0.049467) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 24.1967 ± 0.0945847 (W 0.123321) | 24.9702 ± 0.179289 (W 0.130611) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.470495 ± 0.0022255 (W 0.0025937) | 1.98272 ± 0.0335296 (W 0.0241394) | - | 🔵 faer-fork 4.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.80052 ± 0.00977294 (W 0.00615049) | 6.70072 ± 0.0349854 (W 0.0574412) | - | 🔵 faer-fork 3.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 6.4987 ± 0.00951291 (W 0.0272796) | 24.2932 ± 0.0633038 (W 0.131098) | - | 🔵 faer-fork 3.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.71889 ± 0.00710706 (W 0.0163081) | 2.89897 ± 0.0118099 (W 0.014477) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.0089 ± 0.093906 (W 0.0493582) | 13.3816 ± 0.114636 (W 0.0438333) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 59.193 ± 0.125624 (W 0.302997) | 61.102 ± 0.072661 (W 0.472451) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.90167 ± 0.00319342 (W 0.00368648) | 1.90879 ± 0.00437569 (W 0.00355218) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.3755 ± 0.0351212 (W 0.0156332) | 10.4349 ± 0.00659351 (W 0.0240336) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.7556 ± 0.180028 (W 0.320978) | 48.0375 ± 0.0599772 (W 0.256692) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 2.05032 ± 0.00309958 (W 0.00195427) | 2.05179 ± 0.00783004 (W 0.00505342) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 10.2589 ± 0.0124194 (W 0.0101509) | 10.1855 ± 0.0103227 (W 0.00733484) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 58.3679 ± 0.0504671 (W 0.0195587) | 58.1611 ± 0.0154738 (W 0.0218196) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.464744 ± 0.00135355 (W 0.00216555) | 0.468231 ± 0.00289374 (W 0.00149962) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.51711 ± 0.0101326 (W 0.00317845) | 2.53096 ± 0.0053153 (W 0.00319821) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 15.5179 ± 0.127522 (W 0.00767974) | 15.6008 ± 0.12881 (W 0.011017) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 3.35537 ± 0.00483615 (W 0.00564935) | 3.36297 ± 0.00696534 (W 0.00271535) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.3177 ± 0.122516 (W 0.0243259) | 19.3566 ± 0.0802389 (W 0.0210229) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 120.43 ± 0.237414 (W 0.0412447) | 120.545 ± 0.120789 (W 0.0638185) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 2.10535 ± 0.00880622 (W 0.00207732) | 2.10886 ± 0.00617696 (W 0.00491401) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 11.366 ± 0.0289819 (W 0.0115271) | 11.3812 ± 0.0284204 (W 0.013803) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 67.7065 ± 0.200376 (W 0.0371621) | 67.9592 ± 0.241715 (W 0.186929) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.93108 ± 0.0440708 (W 0.0251157) | 1.9375 ± 0.00193654 (W 0.0276968) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 7.02495 ± 0.00392877 (W 0.0257619) | 6.96865 ± 0.0262516 (W 0.0591832) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 27.5378 ± 0.00747401 (W 0.0270509) | 27.4342 ± 0.0296255 (W 0.0251472) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.401995 ± 0.00474756 (W 0.0141594) | 1.28105 ± 0.0148215 (W 0.0127858) | - | 🔵 faer-fork 3.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.84796 ± 0.0113676 (W 0.0362868) | 3.54985 ± 0.0203129 (W 0.027112) | - | 🔵 faer-fork 1.92× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 7.27675 ± 0.0245327 (W 0.0326759) | 10.6813 ± 0.0130357 (W 0.0625619) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.74677 ± 0.0126653 (W 0.0305785) | 2.75487 ± 0.0176745 (W 0.0314361) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.4463 ± 0.0804187 (W 0.0729749) | 13.4434 ± 0.0116477 (W 0.0587954) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 63.41 ± 0.411391 (W 0.210747) | 63.4445 ± 0.217159 (W 0.255578) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.89372 ± 0.00134136 (W 0.00491395) | 1.8974 ± 0.00232147 (W 0.00306642) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.3429 ± 0.0549722 (W 0.0726676) | 10.2179 ± 0.0504176 (W 0.0625735) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 46.6659 ± 0.251241 (W 0.285309) | 46.6454 ± 0.1732 (W 0.199689) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n128/b1` | 1.88158 ± 0.00791526 (W 0.0145613) | 1.97239 ± 0.00688382 (W 0.0282264) | - | · | - | `*` one row has no measurement here |
| `eigh/n256/b1` | 6.72466 ± 0.00340794 (W 0.0258759) | 6.84193 ± 0.0276406 (W 0.0432109) | - | · | - | `*` one row has no measurement here |
| `eigh/n512/b1` | 23.8996 ± 0.0422907 (W 0.0907547) | 24.5444 ± 0.0720865 (W 0.227491) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n128/b1` | 0.425429 ± 0.00798728 (W 0.00775496) | 1.70397 ± 0.0210729 (W 0.0245785) | - | 🔵 faer-fork 4.01× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.69763 ± 0.00680038 (W 0.0146518) | 4.4179 ± 0.0595967 (W 0.0390946) | - | 🔵 faer-fork 2.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 6.15887 ± 0.0120147 (W 0.0274668) | 11.6064 ± 0.108673 (W 0.0792685) | - | 🔵 faer-fork 1.88× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.70713 ± 0.012899 (W 0.0240621) | 2.8533 ± 0.0077589 (W 0.0186615) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.8357 ± 0.132022 (W 0.0770531) | 13.2603 ± 0.10507 (W 0.0324821) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 58.1844 ± 0.320447 (W 0.369289) | 59.9377 ± 0.146369 (W 0.337947) | - | · | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.89337 ± 0.034214 (W 0.00333181) | 1.89059 ± 0.00395856 (W 0.00400347) | - | · | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 10.2756 ± 0.0178093 (W 0.0214143) | 10.2884 ± 0.0425931 (W 0.0317647) | - | · | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 47.0444 ± 0.278103 (W 0.405518) | 46.963 ± 0.201547 (W 0.299126) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/128`, `eigh/256`, `eigh/512`, `qr_factor/128`, `qr_factor/256`, `qr_factor/512`, `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.04133 ± 0.0185192 (W 0.00146649) | 1.8719 ± 0.00944228 (W 0.00513285) | 0.908615 ± 0.0026402 (W 0.00330436) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 32.5148 ± 0.31428 (W 0.400646) | 78.1413 ± 0.302035 (W 0.0808977) | 35.0293 ± 0.417677 (W 0.100111) | 🔵 faer-fork 2.40× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50034 ± 0.00396858 (W 0.00239504) | 2.50535 ± 0.00468172 (W 0.00472431) | 3.04727 ± 0.00575133 (W 0.00509545) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.6356 ± 0.178571 (W 0.409594) | 88.7722 ± 0.125399 (W 0.0726122) | 120.491 ± 0.0899452 (W 0.222128) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48853 ± 0.0201345 (W 0.00366043) | 1.48349 ± 0.00268769 (W 0.00539613) | 1.39331 ± 0.0171728 (W 0.00362594) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.8836 ± 0.0945178 (W 0.0686214) | 44.9612 ± 0.0527276 (W 0.0664598) | 46.639 ± 0.423632 (W 0.0734094) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.08211 ± 0.0201131 (W 0.0212579) | 3.69135 ± 0.0741597 (W 0.0703707) | 0.462341 ± 0.00538274 (W 0.00778509) | 🔵 faer-fork 3.41× faster than `faer-upstream` | 🔴 faer-fork 2.34× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 15.811 ± 0.202705 (W 0.309824) | 77.0267 ± 0.298498 (W 0.330276) | 12.5816 ± 0.0874857 (W 0.0816145) | 🔵 faer-fork 4.87× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.3634 ± 0.026771 (W 0.0292315) | 2.82177 ± 0.0426927 (W 0.0168981) | 1.88533 ± 0.00254834 (W 0.00633416) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 46.6053 ± 0.274588 (W 0.203496) | 50.5171 ± 0.146585 (W 0.225397) | 48.6986 ± 2.97779 (W 0.103671) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.65465 ± 0.0122738 (W 0.0243525) | 2.12202 ± 0.00666464 (W 0.0191265) | 0.943289 ± 0.0014995 (W 0.00374986) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 31.2749 ± 0.0791354 (W 0.187907) | 35.5019 ± 0.842955 (W 0.139516) | 22.7032 ± 2.70407 (W 0.205522) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.17795 ± 0.0366047 (W 0.0145811) | 4.14244 ± 0.174785 (W 0.0796243) | 0.321053 ± 0.000297653 (W 0.00206927) | 🔵 faer-fork 3.52× faster than `faer-upstream` | 🔴 faer-fork 3.67× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 12.9921 ± 0.0324926 (W 0.0725324) | 76.2879 ± 0.594359 (W 0.39231) | 7.27407 ± 0.0399771 (W 0.0278609) | 🔵 faer-fork 5.87× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50562 ± 0.00929754 (W 0.0191334) | 3.19051 ± 0.0332376 (W 0.0313031) | 1.67437 ± 0.0163297 (W 0.00384215) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.7506 ± 0.149211 (W 0.100307) | 50.3482 ± 1.47129 (W 0.637639) | 36.6442 ± 2.41895 (W 0.163894) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.77273 ± 0.0132658 (W 0.0231806) | 2.4845 ± 0.0303269 (W 0.0369752) | 0.81122 ± 0.00450509 (W 0.00336926) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 29.6068 ± 0.0428471 (W 0.0742149) | 37.1948 ± 0.0935755 (W 0.118093) | 16.5693 ± 0.185317 (W 0.0562553) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.792278 ± 0.00353532 (W 0.00116596) | 0.792779 ± 0.00306289 (W 0.00255824) | 0.766526 ± 0.00162814 (W 0.00273639) | · | · |  |
| `qr_factor/4096x256/b1` | 25.8907 ± 0.221057 (W 0.0256293) | 25.884 ± 0.185321 (W 0.0250773) | 28.8508 ± 0.169395 (W 0.0284542) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.44932 ± 0.00603019 (W 0.00513935) | 2.45019 ± 0.00803684 (W 0.00504538) | 2.81449 ± 0.0421364 (W 0.00546207) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 83.1543 ± 0.109815 (W 0.0907581) | 83.4163 ± 0.145887 (W 0.107411) | 109.473 ± 0.314863 (W 0.131313) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.40784 ± 0.00449297 (W 0.00289288) | 1.40768 ± 0.0014451 (W 0.00216448) | 1.24398 ± 0.00211734 (W 0.00337772) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 39.1483 ± 0.0837719 (W 0.0462099) | 39.1703 ± 0.0775456 (W 0.0280761) | 40.2386 ± 0.325556 (W 0.0370296) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.901384 ± 0.0111547 (W 0.00672667) | 1.373 ± 0.00271303 (W 0.0146497) | 0.424194 ± 0.00701832 (W 0.00428104) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.3725 ± 0.142036 (W 0.16104) | 17.9408 ± 0.101028 (W 0.146169) | 11.299 ± 0.0809733 (W 0.0615019) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.34682 ± 0.051196 (W 0.0243881) | 2.7598 ± 0.0338868 (W 0.0194784) | 1.81758 ± 0.00379343 (W 0.00848849) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.8857 ± 0.262296 (W 0.177251) | 44.5156 ± 0.143268 (W 0.182637) | 45.4722 ± 0.266916 (W 0.110149) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.54736 ± 0.00567528 (W 0.0155711) | 2.0141 ± 0.0246194 (W 0.0360716) | 0.902712 ± 0.00495941 (W 0.00580811) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.5398 ± 0.254694 (W 0.166087) | 29.716 ± 0.160467 (W 0.0979668) | 20.8143 ± 0.108104 (W 0.0689768) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.03553 ± 0.0172335 (W 0.0151086) | 1.68601 ± 0.0139287 (W 0.0312405) | 0.299875 ± 0.00129877 (W 0.00204256) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔴 faer-fork 3.45× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.4408 ± 0.170202 (W 0.0237999) | 19.2763 ± 0.277163 (W 0.182778) | 6.48945 ± 0.0545292 (W 0.0377772) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.47035 ± 0.0181361 (W 0.0200894) | 3.11268 ± 0.00838351 (W 0.0222223) | 1.6383 ± 0.00467735 (W 0.00337952) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 34.9628 ± 0.187579 (W 0.0711354) | 44.7317 ± 0.0977699 (W 0.672238) | 34.3955 ± 0.141187 (W 0.0778842) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.67548 ± 0.00775164 (W 0.0152729) | 2.41437 ± 0.0150922 (W 0.0496095) | 0.785594 ± 0.00274794 (W 0.00343331) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.0453 ± 0.0964799 (W 0.0891122) | 31.7096 ± 0.101358 (W 0.0797606) | 15.8203 ± 0.0198566 (W 0.0431575) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.54982 ± 0.00811753 (W 0.0038906) | 4.02247 ± 0.157349 (W 0.0154131) | 2.37977 ± 0.00416507 (W 0.00518298) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 100.816 ± 0.366771 (W 0.182665) | 176.08 ± 0.617725 (W 0.195433) | 110.334 ± 0.524509 (W 0.447038) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.97453 ± 0.0181503 (W 0.00239358) | 5.994 ± 0.00475187 (W 0.0122272) | 8.75839 ± 0.0195916 (W 0.0161211) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 280.057 ± 0.0318273 (W 1.10759) | 280.707 ± 0.250467 (W 0.543951) | 380.13 ± 0.0683279 (W 0.869898) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.05756 ± 0.0206487 (W 0.00201913) | 3.07502 ± 0.00822921 (W 0.00519276) | 3.80833 ± 0.00240831 (W 0.00342776) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 122.437 ± 1.34037 (W 0.138869) | 122.38 ± 0.519149 (W 0.163606) | 144.903 ± 0.552151 (W 0.492996) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.92719 ± 0.021757 (W 0.0118981) | 4.48953 ± 0.0921204 (W 0.102961) | 1.3908 ± 0.00214964 (W 0.0027887) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 40.9646 ± 0.0739518 (W 0.124023) | 124.97 ± 0.289541 (W 0.515687) | 33.8533 ± 0.232196 (W 0.171407) | 🔵 faer-fork 3.05× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.01702 ± 0.0404657 (W 0.134335) | 4.35519 ± 0.0524619 (W 0.0255935) | 5.4777 ± 0.141411 (W 0.00779225) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 114.767 ± 0.26361 (W 0.397381) | 122.444 ± 0.288241 (W 0.10752) | 139.976 ± 0.512455 (W 0.419142) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.62383 ± 0.0703282 (W 0.0119256) | 3.06914 ± 0.0284675 (W 0.0326778) | 2.79997 ± 0.140735 (W 0.0348984) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 66.6353 ± 0.338226 (W 0.286933) | 74.9833 ± 1.43408 (W 0.205039) | 51.1108 ± 5.14107 (W 0.237622) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.88278 ± 0.024735 (W 0.0155532) | 4.88537 ± 0.0775388 (W 0.0838178) | 0.872315 ± 0.0023141 (W 0.0018673) | 🔵 faer-fork 2.59× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 30.6418 ± 0.117049 (W 0.0788649) | 122.517 ± 0.814928 (W 0.671001) | 19.5753 ± 0.060127 (W 0.0797357) | 🔵 faer-fork 4.00× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.79656 ± 0.0193965 (W 0.016634) | 4.64381 ± 0.02663 (W 0.0308346) | 4.39931 ± 0.027306 (W 0.00742676) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.15 ± 0.239381 (W 0.236398) | 109.841 ± 0.288892 (W 2.78719) | 83.8686 ± 0.163555 (W 0.319201) | 🔵 faer-fork 1.25× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.62277 ± 0.0236609 (W 0.0176955) | 3.34361 ± 0.024818 (W 0.020677) | 2.29255 ± 0.0260663 (W 0.00306649) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 58.6758 ± 0.131855 (W 0.320181) | 72.6704 ± 0.0468095 (W 0.335635) | 34.1818 ± 4.71964 (W 0.124713) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.24834 ± 0.0413823 (W 0.00233334) | 2.25272 ± 0.0546653 (W 0.0027048) | 2.25203 ± 0.0147827 (W 0.00317786) | · | · |  |
| `qr_factor/4096x256/b1` | 89.1177 ± 0.492151 (W 0.0684351) | 89.1117 ± 0.699429 (W 0.0199977) | 104.314 ± 1.31352 (W 0.378735) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.87283 ± 0.0145375 (W 0.00347501) | 5.89243 ± 0.0145267 (W 0.00803977) | 8.54818 ± 0.0100021 (W 0.00829273) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 267.804 ± 0.0543274 (W 0.457715) | 268.486 ± 0.130919 (W 0.319636) | 358.211 ± 5.93481 (W 1.0473) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.93537 ± 0.0216131 (W 0.00411828) | 2.95112 ± 0.00798995 (W 0.00797613) | 3.66918 ± 0.00603633 (W 0.00735839) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 110.085 ± 0.208098 (W 0.0852425) | 110.296 ± 0.0577461 (W 0.129818) | 135.182 ± 3.34505 (W 1.13594) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.75991 ± 0.0161961 (W 0.00789682) | 2.18573 ± 0.00760939 (W 0.0235791) | 1.36823 ± 0.00115352 (W 0.00203223) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 35.9688 ± 0.243142 (W 0.0473511) | 44.7842 ± 0.521513 (W 0.114243) | 31.7645 ± 0.290156 (W 0.155746) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.94611 ± 0.0987965 (W 0.122582) | 4.24509 ± 0.0306731 (W 0.0428062) | 5.39579 ± 0.134619 (W 0.0379621) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 102.71 ± 0.271159 (W 0.420901) | 110.304 ± 0.215444 (W 0.0780638) | 127.981 ± 0.452675 (W 0.502255) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.61117 ± 0.056738 (W 0.0940869) | 2.95539 ± 0.0134969 (W 0.0349784) | 2.79386 ± 0.135515 (W 0.0346019) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 54.7501 ± 0.280921 (W 0.12686) | 62.983 ± 0.264039 (W 0.089535) | 48.703 ± 0.436832 (W 0.0948007) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.72446 ± 0.0145877 (W 0.0137673) | 2.4661 ± 0.0137962 (W 0.0279862) | 0.853483 ± 0.00480952 (W 0.00312903) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 2.02× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.4093 ± 0.126264 (W 0.323587) | 41.5508 ± 0.331907 (W 0.656249) | 17.5601 ± 0.24485 (W 0.0521592) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.70599 ± 0.0234021 (W 0.02062) | 4.53572 ± 0.0518122 (W 0.0344903) | 4.38018 ± 0.0130679 (W 0.00632743) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 75.8114 ± 0.0722272 (W 0.366106) | 93.1929 ± 0.216038 (W 2.33545) | 73.6989 ± 0.491616 (W 0.230388) | 🔵 faer-fork 1.23× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.53234 ± 0.0120202 (W 0.0129959) | 3.27764 ± 0.0206913 (W 0.0305205) | 2.29189 ± 0.00367247 (W 0.00142569) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 46.9312 ± 0.0329502 (W 0.0985884) | 60.8928 ± 0.0908513 (W 0.145845) | 32.3296 ± 0.365979 (W 0.215367) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.872286 ± 0.00628883 (W 0.00221904) | 1.51956 ± 0.00394357 (W 0.00206866) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 20.7523 ± 0.0899169 (W 0.168267) | 51.1212 ± 0.0416932 (W 0.0489989) | - | 🔵 faer-fork 2.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.59535 ± 0.0101291 (W 0.00228376) | 1.60807 ± 0.00860123 (W 0.0018904) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.4956 ± 0.872507 (W 0.0635921) | 48.8693 ± 1.04629 (W 0.0583168) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.1418 ± 0.00159886 (W 0.00109912) | 1.14244 ± 0.00410265 (W 0.00236369) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 27.3864 ± 0.142755 (W 0.0285735) | 27.3264 ± 0.978551 (W 0.021324) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.903732 ± 0.00390331 (W 0.0029397) | 2.82705 ± 0.0287087 (W 0.0285123) | - | 🔵 faer-fork 3.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 10.4869 ± 0.11771 (W 0.141398) | 54.5893 ± 0.404111 (W 0.10894) | - | 🔵 faer-fork 5.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.70141 ± 0.0250144 (W 0.020851) | 2.20128 ± 0.0140117 (W 0.0170479) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 27.4312 ± 0.332715 (W 0.208295) | 31.5581 ± 0.0957984 (W 0.153108) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.33703 ± 0.0239023 (W 0.0217848) | 1.84617 ± 0.0113168 (W 0.0287092) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 20.2781 ± 0.0919185 (W 0.290389) | 24.4912 ± 0.474825 (W 0.130385) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.985686 ± 0.0241196 (W 0.0161965) | 3.17207 ± 0.0255197 (W 0.0263098) | - | 🔵 faer-fork 3.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 9.2714 ± 0.109624 (W 0.0438798) | 56.432 ± 0.226887 (W 0.215935) | - | 🔵 faer-fork 6.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.858 ± 0.0128121 (W 0.0182984) | 2.55597 ± 0.0151138 (W 0.0314749) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.9866 ± 0.136863 (W 0.0879355) | 33.2484 ± 0.220384 (W 0.506553) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.44497 ± 0.00474906 (W 0.0139436) | 2.17829 ± 0.0312146 (W 0.0459919) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.7528 ± 0.0339299 (W 0.0317735) | 26.5928 ± 0.0529131 (W 0.121279) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.617138 ± 0.00558272 (W 0.00244446) | 0.617128 ± 0.007323 (W 0.00196903) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 15.5279 ± 0.0586064 (W 0.0103677) | 15.4375 ± 0.11359 (W 0.0136939) | - | · | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.59344 ± 0.0107142 (W 0.00332497) | 1.5892 ± 0.00741665 (W 0.00237689) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.3725 ± 0.142375 (W 0.0335414) | 46.3602 ± 0.207955 (W 0.0501393) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.10339 ± 0.00252609 (W 0.00108338) | 1.10717 ± 0.00329819 (W 0.00595343) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.3784 ± 0.0671538 (W 0.0202021) | 24.2654 ± 0.0967092 (W 0.0239037) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.801983 ± 0.00328972 (W 0.00620301) | 1.27896 ± 0.0108427 (W 0.0106645) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 9.04894 ± 0.11325 (W 0.0709799) | 13.1666 ± 0.148046 (W 0.073805) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.70568 ± 0.028035 (W 0.0181034) | 2.14658 ± 0.0117289 (W 0.0233883) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.502 ± 0.227449 (W 0.283137) | 28.2217 ± 0.173689 (W 0.189094) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.29458 ± 0.00605271 (W 0.00890099) | 1.80365 ± 0.0140444 (W 0.0280545) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.9479 ± 0.0813199 (W 0.244792) | 21.1818 ± 0.208455 (W 0.145567) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.908341 ± 0.0130472 (W 0.0119041) | 1.57219 ± 0.0290261 (W 0.0157837) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 8.25009 ± 0.0441202 (W 0.0340868) | 15.2462 ± 0.361308 (W 0.274296) | - | 🔵 faer-fork 1.85× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.85315 ± 0.00136694 (W 0.0246258) | 2.5332 ± 0.00730256 (W 0.0267214) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.5169 ± 0.130579 (W 0.0657786) | 29.6911 ± 0.243617 (W 0.409679) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.40042 ± 0.0121596 (W 0.0157136) | 2.15941 ± 0.0335979 (W 0.0404037) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 16.3129 ± 0.0557759 (W 0.0466242) | 22.9816 ± 0.0315782 (W 0.15819) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.70423 ± 0.0062986 (W 0.00278444) | 3.23192 ± 0.00708454 (W 0.00295075) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 57.5311 ± 0.436281 (W 0.0269002) | 97.5665 ± 0.19628 (W 0.0640605) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 3.41676 ± 0.0102045 (W 0.00509041) | 3.41335 ± 0.00548748 (W 0.00276429) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 146.877 ± 0.0879609 (W 0.115654) | 146.606 ± 0.214548 (W 0.142452) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 2.029 ± 0.0178986 (W 0.00555307) | 2.04359 ± 0.00765534 (W 0.00213431) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 67.5686 ± 0.097856 (W 0.0568012) | 67.5611 ± 0.0835505 (W 0.0611461) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.48509 ± 0.0333287 (W 0.0157498) | 3.93866 ± 0.0674261 (W 0.117956) | - | 🔵 faer-fork 2.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 24.7704 ± 0.117415 (W 0.0937332) | 74.8367 ± 0.398186 (W 0.364569) | - | 🔵 faer-fork 3.02× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.67895 ± 0.0500166 (W 0.0765534) | 3.01276 ± 0.0248541 (W 0.0269583) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 63.505 ± 1.4225 (W 1.2976) | 69.5268 ± 1.44243 (W 0.192471) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 2.00986 ± 0.0226607 (W 0.0354727) | 2.39927 ± 0.0306491 (W 0.0201221) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 39.1309 ± 0.0533547 (W 0.174815) | 45.5334 ± 0.237711 (W 0.103768) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.4929 ± 0.00199825 (W 0.00705879) | 4.19038 ± 0.0274898 (W 0.105704) | - | 🔵 faer-fork 2.81× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 19.5749 ± 0.0783363 (W 0.0718695) | 75.2023 ± 1.09078 (W 5.6705) | - | 🔵 faer-fork 3.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.64542 ± 0.0224968 (W 0.0154531) | 3.35283 ± 0.0145718 (W 0.022065) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.882 ± 0.085305 (W 0.0886752) | 63.3589 ± 0.914559 (W 1.0584) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 2.05057 ± 0.00738389 (W 0.0134191) | 2.76036 ± 0.0173184 (W 0.0295276) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 35.1477 ± 0.0564012 (W 0.0874614) | 45.9061 ± 0.106633 (W 0.108339) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.42031 ± 0.0171803 (W 0.00328288) | 1.42048 ± 0.0115146 (W 0.00207852) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 49.4174 ± 0.0687094 (W 0.037388) | 49.4266 ± 0.0152368 (W 0.0612162) | - | · | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 3.37929 ± 0.00538826 (W 0.00559391) | 3.37357 ± 0.00400895 (W 0.00241382) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 141.493 ± 0.0630174 (W 0.078382) | 141.291 ± 0.0691801 (W 0.414348) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.93717 ± 0.00471838 (W 0.00412099) | 1.9424 ± 0.00424348 (W 0.00172477) | - | · | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 61.984 ± 0.0437169 (W 0.0790702) | 61.9729 ± 0.0977895 (W 0.0433205) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.3656 ± 0.00748532 (W 0.0217856) | 1.7605 ± 0.00673852 (W 0.0152371) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 21.7862 ± 0.0493822 (W 0.134112) | 28.2692 ± 0.0817779 (W 0.0917917) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.60967 ± 0.00918937 (W 0.0423089) | 2.97461 ± 0.0072701 (W 0.0234243) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 57.2586 ± 0.192637 (W 0.0554365) | 63.584 ± 0.0230685 (W 0.118067) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.95193 ± 0.017077 (W 0.0512395) | 2.30411 ± 0.00851101 (W 0.0197406) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 33.3448 ± 0.0619702 (W 0.142431) | 39.7723 ± 0.210618 (W 0.126569) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.39952 ± 0.00345375 (W 0.00939103) | 2.08317 ± 0.0107194 (W 0.020415) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 17.8448 ± 0.0616295 (W 0.0449143) | 28.7946 ± 0.11777 (W 0.221025) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 2.59557 ± 0.0123697 (W 0.0157595) | 3.32124 ± 0.00626496 (W 0.0318741) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 44.1958 ± 0.0819222 (W 0.156399) | 56.9937 ± 0.187151 (W 0.926123) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.9549 ± 0.00567064 (W 0.0161319) | 2.69998 ± 0.0297252 (W 0.0143208) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 29.4456 ± 0.00597248 (W 0.099362) | 40.3409 ± 0.0761785 (W 0.217463) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/1024x64`, `eigh/4096x256`, `qr_factor/1024x64`, `qr_factor/4096x256`, `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
