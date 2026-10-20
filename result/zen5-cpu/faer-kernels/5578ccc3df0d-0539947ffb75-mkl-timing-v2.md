<!-- generated from data/results/zen5-cpu/faer-kernels/20261018T000948Z-baseline-v2-diagnostic-mkl/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `5578ccc3df0d980374b2fda6327710d0dcb52c8c`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `976df2c6f9881d995824e9291961f663f6cf0364`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `51563e16906518834e6fb1cf27ffc122bbf7c87a9f31584c471bb02fdfa21906`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T00:21:22.878979Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid --shapes 64,128,256,512 --families qr_factor,qr,svd_values,svd_thin --threads 1,4,8 --dtypes f64 --reps 5 --aa 3 --prime-ms 250 --label baseline-v2-diagnostic-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T000948Z-baseline-v2-diagnostic-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.99%, worst 77.94% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 25 of 288 engine cells exceed 5% and carry `!`; median within-process relative SD 0.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `qr/n64/b1` | 0.122127 ± 0.000409151 (W 5.47923e-05) | 0.118009 ± 0.000135094 (W 0.00116194) | 0.13435 ± 0.000726257 (W 0.000755776) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.089436 ± 8.0829e-05 (W 0.000223661) | 0.130142 ± 0.000186566 (W 0.000177286) | 0.298506 ± 0.134028 (W 0.00199644) | 🔵 fork 1.46× faster than `faer-upstream` | 🔵 fork 3.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.916387 ± 0.00148128 (W 0.00199501) | 0.913742 ± 0.00144951 (W 0.0014211) | 0.720702 ± 0.00317956 (W 0.00302765) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.518346 ± 0.00385937 (W 0.00161655) | 0.516863 ± 0.00426382 (W 0.00176259) | 0.265395 ± 0.000407923 (W 0.00152887) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.168684 ± 0.0110996 (W 0.00333428) | 0.47256 ± 0.0113934 (W 0.00862578) | 0.145662 ± 0.0010338 (W 0.0011433) | 🔵 fork 2.80× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.120425 ± 0.00659106 (W 0.0107453) | 0.476668 ± 0.00745983 (W 0.00819205) | 0.297644 ± 0.133629 (W 0.00173509) | 🔵 fork 3.96× faster than `faer-upstream` | 🔵 fork 2.47× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.948096 ± 0.000780905 (W 0.00380315) | 0.949619 ± 0.00141961 (W 0.0027728) | 0.669237 ± 0.00402061 (W 0.00176705) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.516192 ± 0.00136435 (W 0.00179533) | 0.517564 ± 0.000779262 (W 0.00176864) | 0.269542 ± 0.00065277 (W 0.00149688) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.162142 ± 0.0123216 (W 0.00496754) | 0.655611 ± 0.00382166 (W 0.0149247) | 0.159036 ± 0.0011115 (W 0.00144159) | 🔵 fork 4.04× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.114954 ± 0.000919585 (W 0.00189775) | 0.625665 ± 0.00589948 (W 0.0114868) | 0.298266 ± 0.133533 (W 0.00194944) | 🔵 fork 5.44× faster than `faer-upstream` | 🔵 fork 2.59× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n64/b1` | 0.962082 ± 0.00419832 (W 0.00279261) | 0.96142 ± 0.0110651 (W 0.00569936) | 0.663305 ± 0.00496719 (W 0.00279949) | · | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.517584 ± 0.000459165 (W 0.00259788) | 0.515661 ± 0.000927864 (W 0.00200065) | 0.270805 ± 0.00060078 (W 0.00160424) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.115685 ± 0.000677836 (W 0.00133276) | 0.115234 ± 0.000742426 (W 0.000279361) | 0.116277 ± 0.00112532 (W 0.000825848) | · | · |  |
| `qr_factor/n64/b1` | 0.074158 ± 0.000373778 (W 0.000166395) | 0.07489 ± 0.000423589 (W 0.000190602) | 0.28976 ± 0.000229122 (W 0.0013985) | · | 🔵 fork 3.91× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.959127 ± 0.00137094 (W 0.00129677) | 0.959087 ± 0.00136987 (W 0.000861327) | 0.699643 ± 0.00326188 (W 0.00305864) | · | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.53662 ± 0.00344995 (W 0.00179249) | 0.538904 ± 0.00165969 (W 0.00190352) | 0.255065 ± 0.00026126 (W 0.00173425) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.144349 ± 0.00317108 (W 0.00105677) | 0.46748 ± 0.00753008 (W 0.011156) | 0.127147 ± 0.000978952 (W 0.00105111) | 🔵 fork 3.24× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.104265 ± 0.00326086 (W 0.00900608) | 0.404854 ± 0.00345689 (W 0.0117461) | 0.289239 ± 0.00184266 (W 0.00156409) | 🔵 fork 3.88× faster than `faer-upstream` | 🔵 fork 2.77× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.994743 ± 0.00170934 (W 0.00172798) | 0.996857 ± 0.00590292 (W 0.00864299) | 0.646444 ± 0.000768078 (W 0.00165618) | · | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536279 ± 0.00305121 (W 0.00231963) | 0.537321 ± 0.00151764 (W 0.00191181) | 0.260125 ± 0.00123241 (W 0.00138259) | · | 🔴 fork 2.06× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n64/b1` | 0.154728 ± 0.00541064 (W 0.00243625) | 0.635123 ± 0.0196709 (W 0.0183551) | 0.139309 ± 0.00186282 (W 0.00138671) | 🔵 fork 4.10× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.104665 ± 0.00727925 (W 0.00113311) | 0.582044 ± 0.0106587 (W 0.0131279) | 0.289419 ± 0.000171561 (W 0.00211179) | 🔵 fork 5.56× faster than `faer-upstream` | 🔵 fork 2.77× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.01178 ± 0.0156813 (W 0.00365655) | 1.00487 ± 0.000996269 (W 0.00383085) | 0.636216 ± 0.007684 (W 0.00262152) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537261 ± 0.00140981 (W 0.00186232) | 0.5371 ± 0.00277598 (W 0.00173345) | 0.259554 ± 0.0007596 (W 0.00108843) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.516482 ± 0.00145776 (W 0.0020068) | 0.512475 ± 0.00164916 (W 0.00172159) | 0.747923 ± 0.00145223 (W 0.00293185) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.89825 ± 0.00293074 (W 0.00298585) | 2.94279 ± 0.00104443 (W 0.00248176) | 4.32238 ± 0.00935898 (W 0.0130976) | · | 🔵 fork 1.49× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.1106 ± 0.871627 (W 0.0139128) | 20.8284 ± 0.895814 (W 0.0220318) | 30.6935 ± 0.28528 (W 0.0545677) | · | 🔵 fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.335335 ± 0.000742903 (W 0.0021051) | 0.5315 ± 0.00125042 (W 0.00209955) | 0.367665 ± 0.00180227 (W 0.00175315) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.60847 ± 0.00457096 (W 0.00283955) | 2.89408 ± 0.00425041 (W 0.00752016) | 2.04282 ± 0.0306121 (W 0.00853071) | 🔵 fork 1.80× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.9046 ± 0.0784281 (W 0.0165526) | 17.821 ± 0.520166 (W 0.0223123) | 14.2438 ± 0.0523374 (W 0.0172052) | 🔵 fork 2.00× faster than `faer-upstream` | 🔵 fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.68723 ± 0.00375288 (W 0.00458172) | 3.68119 ± 0.00683732 (W 0.00932334) | 3.39059 ± 0.0124335 (W 0.0191735) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.5217 ± 0.0427744 (W 0.0142948) | 18.5171 ± 0.0623639 (W 0.037285) | 18.066 ± 0.0302311 (W 0.0382279) | · | · |  |
| `svd_thin/n512/b1` | 105.889 ± 0.972664 (W 0.133403) | 105.62 ± 0.739466 (W 0.184204) | 116.453 ± 0.508001 (W 0.233383) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69478 ± 0.00812641 (W 0.00222071) | 2.69262 ± 0.00642006 (W 0.00405573) | 1.19191 ± 0.00253713 (W 0.0020246) | · | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4613 ± 0.0111553 (W 0.0218312) | 12.4401 ± 0.0258536 (W 0.0153473) | 6.96132 ± 0.023505 (W 0.0148725) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.2537 ± 0.808567 (W 0.0698449) | 66.4672 ± 0.561696 (W 0.075288) | 47.7135 ± 0.865186 (W 0.128722) | · | 🔴 fork 1.39× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.610838 ± 0.00753615 (W 0.0318297) | 1.42409 ± 0.021687 (W 0.0326521) | 0.481827 ± 0.000238426 (W 0.00288145) | 🔵 fork 2.33× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.00588 ± 0.0330243 (W 0.0227348) | 3.79097 ± 0.0481553 (W 0.0387803) | 2.0066 ± 0.00399218 (W 0.00546998) | 🔵 fork 1.89× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 10.0814 ± 0.254703 (W 0.146384) | 14.3318 ± 0.346248 (W 0.165928) | 12.1369 ± 0.410601 (W 0.0241145) | 🔵 fork 1.42× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.394816 ± 0.030824 (W 0.0139088) | 1.48072 ± 0.0242127 (W 0.0218916) | 0.197348 ± 0.000490514 (W 0.00132149) | 🔵 fork 3.75× faster than `faer-upstream` | 🔴 fork 2.00× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.50271 ± 0.0113913 (W 0.0263554) | 5.59882 ± 0.0453193 (W 0.0393335) | 0.669176 ± 0.00135128 (W 0.00299367) | 🔵 fork 3.73× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.33408 ± 0.0594491 (W 0.0553318) | 22.2339 ± 0.0713732 (W 0.108876) | 3.8574 ± 0.00804605 (W 0.007529) | 🔵 fork 4.17× faster than `faer-upstream` | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02123 ± 0.00226005 (W 0.0300246) | 3.02038 ± 0.00517829 (W 0.0120758) | 2.63972 ± 0.00368644 (W 0.00461628) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.669 ± 0.0270835 (W 0.0839264) | 13.6143 ± 0.12176 (W 0.0349863) | 12.5141 ± 0.00580547 (W 0.0138686) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.7384 ± 0.401372 (W 0.391049) | 61.6524 ± 0.318321 (W 0.324669) | 58.1505 ± 2.04726 (W 0.279481) | · | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22857 ± 0.00221793 (W 0.00409336) | 2.22551 ± 0.00401311 (W 0.00507676) | 1.14263 ± 0.00593303 (W 0.00350573) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.9182 ± 0.0342583 (W 0.0340915) | 10.8461 ± 0.0295154 (W 0.0346261) | 6.12145 ± 0.0101372 (W 0.00773671) | · | 🔴 fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.2447 ± 0.168697 (W 0.282994) | 48.2603 ± 0.129945 (W 0.262181) | 25.6925 ± 0.0744574 (W 0.0270017) | · | 🔴 fork 1.88× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.620546 ± 0.00127329 (W 0.0110294) | 1.91014 ± 0.0423073 (W 0.0304891) | 0.433697 ± 0.000955886 (W 0.00730642) | 🔵 fork 3.08× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.13455 ± 0.0199198 (W 0.0206084) | 4.80466 ± 0.0229427 (W 0.063686) | 1.80817 ± 0.0035206 (W 0.00599183) | 🔵 fork 2.25× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n512/b1` | 10.2394 ± 0.0255303 (W 0.0729516) | 15.599 ± 0.208941 (W 0.131941) | 10.2312 ± 0.121938 (W 0.0344735) | 🔵 fork 1.52× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.372013 ± 0.0034659 (W 0.00456722) | 1.9768 ± 0.00145758 (W 0.0218965) | 0.158085 ± 0.000707758 (W 0.0013075) | 🔵 fork 5.31× faster than `faer-upstream` | 🔴 fork 2.35× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.5568 ± 0.0244573 (W 0.0182516) | 6.75258 ± 0.0251551 (W 0.0369678) | 0.576514 ± 0.00231868 (W 0.0026214) | 🔵 fork 4.34× faster than `faer-upstream` | 🔴 fork 2.70× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.55631 ± 0.0470493 (W 0.360976) | 25.024 ± 0.182808 (W 0.189855) | 2.30885 ± 0.0106886 (W 0.00746736) | 🔵 fork 4.50× faster than `faer-upstream` | 🔴 fork 2.41× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.16039 ± 0.0332329 (W 0.0116627) | 3.12997 ± 0.0149892 (W 0.0118774) | 2.51209 ± 0.00602956 (W 0.00603057) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.8342 ± 0.040266 (W 0.0429351) | 13.8041 ± 0.0615925 (W 0.0374281) | 11.486 ± 0.0243065 (W 0.0124139) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.8014 ± 0.344728 (W 0.405257) | 61.0096 ± 0.0851625 (W 0.30151) | 49.3519 ± 1.95394 (W 0.0701899) | · | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22634 ± 0.0362351 (W 0.00598337) | 2.28053 ± 0.0373681 (W 0.00796089) | 1.12738 ± 0.00247697 (W 0.00291013) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 11.015 ± 0.0237962 (W 0.0274459) | 11.0219 ± 0.0565258 (W 0.0351758) | 5.99922 ± 0.0137189 (W 0.00822245) | · | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.1754 ± 0.260839 (W 0.214333) | 49.4988 ± 0.228929 (W 0.318835) | 22.5007 ± 0.0321768 (W 0.0376631) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.489452 ± 0.00134224 (W 0.00198458) | 0.490243 ± 0.00253577 (W 0.00199017) | 0.712838 ± 0.0209127 (W 0.00219477) | · | 🔵 fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 2.78762 ± 0.00605578 (W 0.00241106) | 2.79318 ± 0.00332263 (W 0.00302325) | 4.34089 ± 0.0103806 (W 0.0125819) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.6435 ± 1.06719 (W 0.0363289) | 19.5823 ± 0.909883 (W 0.0183144) | 30.4023 ± 0.16805 (W 0.0298971) | · | 🔵 fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.278528 ± 0.000749709 (W 0.00144802) | 0.281695 ± 0.000536278 (W 0.00161901) | 0.333621 ± 0.00165197 (W 0.00235967) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.36993 ± 0.00807049 (W 0.00213016) | 1.39268 ± 0.0127312 (W 0.00602076) | 1.89897 ± 0.00508293 (W 0.00517382) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.02415 ± 0.102497 (W 0.0028941) | 8.04207 ± 0.139196 (W 0.00610316) | 13.4377 ± 0.0129692 (W 0.387029) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.68249 ± 0.00579108 (W 0.00407655) | 3.67903 ± 0.00655686 (W 0.00492919) | 3.31422 ± 0.00779606 (W 0.0120176) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4095 ± 0.0609652 (W 0.0281199) | 18.3744 ± 0.0458446 (W 0.0153773) | 17.7138 ± 0.0218097 (W 0.0335146) | · | · |  |
| `svd_thin/n512/b1` | 104.582 ± 0.885778 (W 0.0788687) | 104.427 ± 1.00771 (W 0.0493351) | 113.928 ± 1.08334 (W 0.309381) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.6153 ± 0.0046178 (W 0.00333761) | 2.62082 ± 0.00638463 (W 0.00662228) | 1.15573 ± 0.000841557 (W 0.00242236) | · | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.29 ± 0.0235395 (W 0.0154503) | 12.284 ± 0.014854 (W 0.0190528) | 6.8425 ± 0.0374582 (W 0.0116783) | · | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.203 ± 0.566972 (W 0.103193) | 65.1571 ± 0.397222 (W 0.0630469) | 47.1063 ± 0.989105 (W 0.0484894) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.567958 ± 0.0264122 (W 0.0430758) | 1.41791 ± 0.0387952 (W 0.0251213) | 0.453725 ± 0.0236808 (W 0.00519084) | 🔵 fork 2.50× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.93002 ± 0.00399493 (W 0.026227) | 3.59716 ± 0.0885909 (W 0.0482712) | 2.19373 ± 0.0312857 (W 0.00933833) | 🔵 fork 1.86× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.5901 ± 0.312849 (W 0.0525246) | 13.0988 ± 0.271058 (W 0.10056) | 13.092 ± 0.264253 (W 0.0134798) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.345103 ± 0.0178329 (W 0.0261847) | 1.16182 ± 0.0127832 (W 0.0198062) | 0.18233 ± 0.000249981 (W 0.000972262) | 🔵 fork 3.37× faster than `faer-upstream` | 🔴 fork 1.89× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.37719 ± 0.00553633 (W 0.0259027) | 3.04511 ± 0.0685968 (W 0.0667182) | 0.618552 ± 0.00433218 (W 0.00235392) | 🔵 fork 2.21× faster than `faer-upstream` | 🔴 fork 2.23× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.88407 ± 0.0475337 (W 0.041363) | 8.52394 ± 0.147435 (W 0.111182) | 3.69558 ± 0.0359231 (W 0.00465967) | 🔵 fork 1.75× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01144 ± 0.0135862 (W 0.014453) | 2.99688 ± 0.0135891 (W 0.0377833) | 2.59813 ± 0.0178051 (W 0.00561704) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5065 ± 0.110862 (W 0.0393807) | 13.5415 ± 0.131512 (W 0.110574) | 12.4034 ± 0.0802599 (W 0.019373) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.0635 ± 0.525492 (W 0.197285) | 60.4118 ± 0.130463 (W 0.13013) | 57.2407 ± 0.413041 (W 0.0828508) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.16119 ± 0.0195724 (W 0.00404111) | 2.16374 ± 0.0215472 (W 0.00490566) | 1.12463 ± 0.00663535 (W 0.00202424) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.7105 ± 0.0563025 (W 0.0343169) | 10.693 ± 0.0196582 (W 0.0274528) | 6.1081 ± 0.0235955 (W 0.00727987) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.1743 ± 0.171974 (W 0.286004) | 47.005 ± 0.096082 (W 0.394726) | 25.4779 ± 0.46427 (W 0.028188) | · | 🔴 fork 1.85× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr/n128/b1` | 0.587985 ± 0.0051752 (W 0.00824548) | 1.89215 ± 0.0135304 (W 0.0295695) | 0.417598 ± 0.0019388 (W 0.00676802) | 🔵 fork 3.22× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.0494 ± 0.0226857 (W 0.0298214) | 4.66657 ± 0.0387984 (W 0.0473103) | 2.05502 ± 0.0103095 (W 0.00512991) | 🔵 fork 2.28× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 9.64417 ± 0.071753 (W 0.0763144) | 14.657 ± 0.0847165 (W 0.199986) | 10.4855 ± 0.143893 (W 0.020754) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.326579 ± 0.00235534 (W 0.00289982) | 1.60332 ± 0.0199382 (W 0.0153945) | 0.14531 ± 0.000642558 (W 0.00263062) | 🔵 fork 4.91× faster than `faer-upstream` | 🔴 fork 2.25× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.46792 ± 0.0122902 (W 0.0203262) | 4.16277 ± 0.0628261 (W 0.0392519) | 0.540917 ± 0.00132645 (W 0.00401748) | 🔵 fork 2.84× faster than `faer-upstream` | 🔴 fork 2.71× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.2297 ± 0.0229484 (W 0.103193) | 10.0661 ± 0.0836344 (W 0.16451) | 2.24298 ± 0.0063158 (W 0.00467474) | 🔵 fork 1.92× faster than `faer-upstream` | 🔴 fork 2.33× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.11607 ± 0.00771077 (W 0.0154087) | 3.09688 ± 0.0201225 (W 0.013299) | 2.47075 ± 0.00841709 (W 0.00606744) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6851 ± 0.0598714 (W 0.0367743) | 13.6905 ± 0.082187 (W 0.0241159) | 11.4127 ± 0.0364818 (W 0.0142595) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.0861 ± 0.42758 (W 0.467822) | 59.9564 ± 0.230658 (W 0.436301) | 47.7682 ± 0.402704 (W 0.0552738) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.22037 ± 0.035105 (W 0.00617928) | 2.16173 ± 0.0346035 (W 0.00488146) | 1.11892 ± 0.00781423 (W 0.00274371) | · | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8511 ± 0.0169183 (W 0.0343084) | 10.821 ± 0.0263645 (W 0.0203351) | 5.97328 ± 0.0555221 (W 0.0101161) | · | 🔴 fork 1.82× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.4126 ± 0.126275 (W 0.19907) | 48.178 ± 0.457761 (W 0.407659) | 22.4364 ± 0.117857 (W 0.0344197) | · | 🔴 fork 2.16× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
