# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `5578ccc3df0d980374b2fda6327710d0dcb52c8c`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `01e9f81fdf1c082c862f6d9656ff6c444b799f21`
- toolkit commit: `ca3ffc988b745675988a403fb2837d3e4dfe5653`
- measured binary SHA-256: `b0781c1608511c2a7caf169f45c0ebb5dc8e143a33b8c7ac93679526d39558a4`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-16T22:21:43.666224Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall,linalg-wide --shapes  --families qr_factor,qr,lu,full_piv_lu,solve --dtypes f64,c64 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label merged-main-accept48 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T214635Z-merged-main-accept48/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.27%, worst 290.27% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 111 of 1024 engine cells exceed 5% and carry `!`; median within-process relative SD 0.75%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `full_piv_lu/n32/b1` | 0.011572 ± 7.02377e-05 (W 7.10634e-05) | 0.01066 ± 0.000194679 (W 4.5607e-05) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051165 ± 0.000425924 (W 0.000297614) | 0.047048 ± 0.000191364 (W 0.000218743) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143808 ± 0.000360289 (W 0.00182976) | 0.1334 ± 0.000130592 (W 0.00299629) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008666 ± 0.000162112 (W 0.00114321) | 0.007243 ± 2.12211e-05 (W 6.32234e-05) | 0.012233 ± 9.11976e-05 (W 6.57214e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031378 ± 0.000543106 (W 6.57974e-05) | 0.044724 ± 0.000757174 (W 0.00256497) | 0.04294 ± 0.000242143 (W 0.000109564) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075741 ± 0.000204378 (W 0.00253307) | 0.104346 ± 0.00175196 (W 0.00228657) | 0.093213 ± 0.000399852 (W 0.00114077) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.033443 ± 0.000169638 (W 0.000219885) | 0.111729 ± 0.00160278 (W 0.00730258) | 0.02631 ± 0.0335339 (W 0.000107309) | 🔵 fork 3.34× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.176399 ± 0.00570008 (W 0.00388043) | 0.479054 ± 0.00221595 (W 0.00996301) | 0.14474 ± 0.00129035 (W 0.00151776) | 🔵 fork 2.72× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.428138 ± 0.0172162 (W 0.019939) | 1.00247 ± 0.00974241 (W 0.0200513) | 0.332153 ± 0.00138686 (W 0.00255035) | 🔵 fork 2.34× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.043351 ± 0.000244759 (W 0.000486597) | 0.090999 ± 0.00436728 (W 0.00445061) | 0.014117 ± 6.22923e-05 (W 8.71447e-05) | 🔵 fork 2.10× faster than `faer-upstream` | 🔴 fork 3.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.118773 ± 0.00253248 (W 0.004511) | 0.464151 ± 0.00614596 (W 0.0168342) | 0.298159 ± 0.133505 (W 0.00139556) | 🔵 fork 3.91× faster than `faer-upstream` | 🔵 fork 2.51× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.24669 ± 0.0186658 (W 0.0121333) | 0.955843 ± 0.012315 (W 0.016996) | 0.941642 ± 0.00149891 (W 0.000825389) | 🔵 fork 3.87× faster than `faer-upstream` | 🔵 fork 3.82× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.009788 ± 0.000144684 (W 8.82111e-05) | 0.008386 ± 8.544e-05 (W 0.00011083) | 0.012814 ± 1.52753e-05 (W 5.39741e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.032019 ± 0.00015179 (W 0.000153617) | 0.046548 ± 0.000867551 (W 0.00348084) | 0.043541 ± 0.000134946 (W 0.000164833) | 🔵 fork 1.45× faster than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077746 ± 0.000371378 (W 0.00241251) | 0.104375 ± 0.0084916 (W 0.00425415) | 0.087634 ± 0.00016784 (W 0.001287) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.011481 ± 0.000137477 (W 0.000157893) | 0.010489 ± 0.000177455 (W 6.09779e-05) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.050836 ± 0.000290145 (W 0.000123115) | 0.046657 ± 0.000129384 (W 0.000139109) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144268 ± 0.00173246 (W 0.00252228) | 0.133719 ± 0.00274096 (W 0.0013189) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008486 ± 3.78594e-05 (W 5.70982e-05) | 0.007374 ± 5.34821e-05 (W 0.000190763) | 0.012223 ± 0.00016784 (W 0.00013695) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030908 ± 6.20511e-05 (W 0.000125618) | 0.051907 ± 0.00135136 (W 0.00270651) | 0.043 ± 7.97517e-05 (W 0.000148419) | 🔵 fork 1.68× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.07568 ± 0.000520648 (W 0.00229493) | 0.115256 ± 0.00249575 (W 0.00272069) | 0.090519 ± 0.0031248 (W 0.00251253) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.033061 ± 0.000112281 (W 0.000128981) | 0.143878 ± 0.00218707 (W 0.00362278) | 0.026379 ± 0.0335316 (W 0.000131415) | 🔵 fork 4.35× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.164629 ± 0.0119995 (W 0.00284922) | 0.653276 ± 0.0112658 (W 0.0209098) | 0.158435 ± 0.000777843 (W 0.00172727) | 🔵 fork 3.97× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr/n96/b1` | 0.420594 ± 0.00905696 (W 0.0220119) | 1.39487 ± 0.0315744 (W 0.0236941) | 0.336456 ± 0.00718425 (W 0.00279765) | 🔵 fork 3.32× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040245 ± 0.0004368 (W 0.000589857) | 0.121656 ± 0.00109152 (W 0.00639661) | 0.014076 ± 0.000153731 (W 4.36601e-05) | 🔵 fork 3.02× faster than `faer-upstream` | 🔴 fork 2.86× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.114625 ± 0.00464054 (W 0.00242432) | 0.628653 ± 0.00271051 (W 0.00943269) | 0.298389 ± 0.134101 (W 0.00166384) | 🔵 fork 5.48× faster than `faer-upstream` | 🔵 fork 2.60× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.240197 ± 0.00220865 (W 0.00390881) | 1.2786 ± 0.0220195 (W 0.0186792) | 0.938767 ± 0.000285542 (W 0.00205863) | 🔵 fork 5.32× faster than `faer-upstream` | 🔵 fork 3.91× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009517 ± 0.000134649 (W 9.24354e-05) | 0.008476 ± 0.000110666 (W 0.000198167) | 0.012844 ± 3.21455e-05 (W 7.52994e-05) | 🔴 fork 1.12× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031338 ± 0.000520796 (W 0.000121055) | 0.054642 ± 0.000865812 (W 0.00347932) | 0.043522 ± 5.25389e-05 (W 7.47951e-05) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.078276 ± 0.00406255 (W 0.00244465) | 0.121336 ± 0.00603788 (W 0.00247059) | 0.08533 ± 0.00013604 (W 0.00014144) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.0104 ± 0.000107858 (W 4.9295e-05) | 0.01058 ± 6.98594e-05 (W 6.42044e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045695 ± 0.000208351 (W 8.41202e-05) | 0.046056 ± 0.000198578 (W 0.000227663) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131696 ± 0.000643161 (W 0.00248864) | 0.132547 ± 0.000814114 (W 0.00026051) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007124 ± 1.12694e-05 (W 5.19163e-05) | 0.007143 ± 9.02053e-05 (W 0.000105736) | 0.009739 ± 7.75263e-05 (W 5.86191e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026159 ± 9.60902e-05 (W 0.000181523) | 0.043411 ± 0.000483184 (W 0.00305932) | 0.033443 ± 0.000118773 (W 0.00139784) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063868 ± 0.000603772 (W 0.00254719) | 0.100287 ± 0.00124611 (W 0.00233998) | 0.074589 ± 0.000109668 (W 0.000112367) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031789 ± 0.000155532 (W 0.000101143) | 0.111068 ± 0.00449253 (W 0.00486437) | 0.021009 ± 0.000142116 (W 8.26456e-05) | 🔵 fork 3.49× faster than `faer-upstream` | 🔴 fork 1.51× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.151853 ± 0.00530668 (W 0.00157877) | 0.47822 ± 0.00936456 (W 0.00775521) | 0.126495 ± 0.00220337 (W 0.00184133) | 🔵 fork 3.15× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.389471 ± 0.0144316 (W 0.0208103) | 1.01694 ± 0.012634 (W 0.016916) | 0.293436 ± 0.00153304 (W 0.00224221) | 🔵 fork 2.61× faster than `faer-upstream` | 🔴 fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.018064 ± 0.000223681 (W 0.000142374) | 0.078377 ± 0.00518908 (W 0.00333584) | 0.011591 ± 0.000100732 (W 5.44977e-05) | 🔵 fork 4.34× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.088425 ± 0.00816766 (W 0.00676142) | 0.410941 ± 0.00420187 (W 0.0133814) | 0.289399 ± 0.000281287 (W 0.0018379) | 🔵 fork 4.65× faster than `faer-upstream` | 🔵 fork 3.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.198162 ± 0.0109979 (W 0.00925854) | 0.81675 ± 0.0110972 (W 0.0078821) | 0.930126 ± 0.000900557 (W 0.000747591) | 🔵 fork 4.12× faster than `faer-upstream` | 🔵 fork 4.69× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007965 ± 3.60555e-05 (W 8.98888e-05) | 0.008025 ± 0.0001005 (W 5.06952e-05) | 0.009848 ± 7.07602e-05 (W 3.71927e-05) | · | 🔵 fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026299 ± 8.02081e-05 (W 0.000162451) | 0.043502 ± 0.00139894 (W 0.00304136) | 0.033562 ± 0.000116234 (W 9.60536e-05) | 🔵 fork 1.65× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065392 ± 0.000167572 (W 0.00156734) | 0.101069 ± 0.00163014 (W 0.00407219) | 0.073557 ± 0.00026 (W 9.13083e-05) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.010269 ± 6.48614e-05 (W 2.88097e-05) | 0.01048 ± 0.000110077 (W 4.60435e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045876 ± 0.000144915 (W 0.000106912) | 0.046177 ± 0.000208727 (W 0.00175726) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132657 ± 0.00403965 (W 0.00220769) | 0.131245 ± 0.00349739 (W 0.000238617) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007103 ± 4.04145e-05 (W 5.68331e-05) | 0.007133 ± 8.77895e-05 (W 3.98271e-05) | 0.009698 ± 9e-05 (W 5.24805e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025868 ± 2.6839e-05 (W 0.00181088) | 0.051436 ± 0.00296231 (W 0.00315478) | 0.033462 ± 6.1101e-05 (W 9.89308e-05) | 🔵 fork 1.99× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063439 ± 0.00242547 (W 0.00217164) | 0.113651 ± 0.0015349 (W 0.00356031) | 0.073908 ± 0.000268887 (W 0.00138703) | 🔵 fork 1.79× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.03173 ± 0.000142388 (W 9.8387e-05) | 0.140874 ± 0.00593278 (W 0.00427005) | 0.02125 ± 0.000115902 (W 0.000168956) | 🔵 fork 4.44× faster than `faer-upstream` | 🔴 fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.156333 ± 0.00299647 (W 0.00758894) | 0.656921 ± 0.0102439 (W 0.0153223) | 0.137386 ± 0.000719299 (W 0.000929156) | 🔵 fork 4.20× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.411728 ± 0.0217468 (W 0.0132983) | 1.38096 ± 0.0247703 (W 0.0323431) | 0.304057 ± 0.00189629 (W 0.00186266) | 🔵 fork 3.35× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017974 ± 5.2915e-05 (W 9.70634e-05) | 0.11262 ± 0.00521377 (W 0.00418216) | 0.011462 ± 8.53834e-05 (W 5.85081e-05) | 🔵 fork 6.27× faster than `faer-upstream` | 🔴 fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.095077 ± 0.00681447 (W 0.00248516) | 0.580322 ± 0.0144762 (W 0.0117932) | 0.289299 ± 0.000103058 (W 0.00143429) | 🔵 fork 6.10× faster than `faer-upstream` | 🔵 fork 3.04× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.21325 ± 0.00337299 (W 0.00526546) | 1.13623 ± 0.00403848 (W 0.020267) | 0.929863 ± 0.000370515 (W 0.00147177) | 🔵 fork 5.33× faster than `faer-upstream` | 🔵 fork 4.36× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007745 ± 0.000128582 (W 3.62808e-05) | 0.007785 ± 0.00012644 (W 6.72555e-05) | 0.009808 ± 0.000110151 (W 6.0583e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026079 ± 0.00037055 (W 0.000106218) | 0.049472 ± 0.00243392 (W 0.00336282) | 0.033693 ± 0.00019975 (W 9.40744e-05) | 🔵 fork 1.90× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065612 ± 0.00431486 (W 0.00247032) | 0.112499 ± 0.00698588 (W 0.00490002) | 0.073428 ± 2.88848e-05 (W 0.0016069) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.017824 ± 0.000106819 (W 8.13339e-05) | 0.015859 ± 0.000170666 (W 8.83533e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097441 ± 0.00030291 (W 0.000330075) | 0.09166 ± 0.000301967 (W 0.000362755) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.322742 ± 0.000219365 (W 0.00226278) | 0.307333 ± 0.00258244 (W 0.00370463) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013215 ± 0.000189201 (W 0.000145994) | 0.011121 ± 0.000179834 (W 6.01764e-05) | 0.020047 ± 4.58258e-05 (W 8.26335e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058148 ± 7.38941e-05 (W 0.00149628) | 0.052688 ± 0.000236369 (W 0.000306796) | 0.095558 ± 0.000303837 (W 0.000362001) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.192641 ± 0.00219471 (W 0.00245177) | 0.192561 ± 0.000661054 (W 0.00458109) | 0.263721 ± 0.0120857 (W 0.00521913) | · | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.06987 ± 0.000596046 (W 0.000389098) | 0.149008 ± 0.00183786 (W 0.0162722) | 0.05349 ± 0.0895147 (W 0.000139787) | 🔵 fork 2.13× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.30641 ± 0.011259 (W 0.00394194) | 0.643497 ± 0.00363418 (W 0.00756877) | 0.305348 ± 0.00108548 (W 0.00172659) | 🔵 fork 2.10× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr/n96/b1` | 0.685015 ± 0.0013164 (W 0.0203118) | 1.35836 ± 0.0140372 (W 0.0135177) | 0.767469 ± 0.000439747 (W 0.00291367) | 🔵 fork 1.98× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.052017 ± 0.000346541 (W 0.000436341) | 0.105656 ± 0.00269485 (W 0.00427661) | 0.028783 ± 0.0001155 (W 5.85508e-05) | 🔵 fork 2.03× faster than `faer-upstream` | 🔴 fork 1.81× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.191526 ± 0.00619285 (W 0.0131807) | 0.60238 ± 0.00765443 (W 0.00897815) | 0.761109 ± 0.34532 (W 0.00121481) | 🔵 fork 3.15× faster than `faer-upstream` | 🔵 fork 3.97× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.375129 ± 0.00631338 (W 0.00248654) | 1.13125 ± 0.00703275 (W 0.0145872) | 2.4551 ± 0.00176216 (W 0.00216628) | 🔵 fork 3.02× faster than `faer-upstream` | 🔵 fork 6.54× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014497 ± 0.000108167 (W 0.000103053) | 0.012543 ± 8.14453e-05 (W 3.27918e-05) | 0.020308 ± 0.000158085 (W 0.000144074) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060042 ± 0.000610665 (W 0.00014856) | 0.054782 ± 0.000193418 (W 0.00024294) | 0.093054 ± 0.000471453 (W 0.000975773) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.202507 ± 0.00339272 (W 0.00299197) | 0.206625 ± 0.000900722 (W 0.0031301) | 0.237005 ± 0.00304222 (W 0.00160436) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.017844 ± 4.0129e-05 (W 0.000163466) | 0.01592 ± 0.000178429 (W 0.000120955) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097832 ± 0.000636994 (W 0.00136103) | 0.092352 ± 0.000204598 (W 0.00135911) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.321933 ± 0.00119825 (W 0.00278645) | 0.306261 ± 0.00191996 (W 0.00363566) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013175 ± 0.000171407 (W 0.000113852) | 0.011191 ± 2.12211e-05 (W 5.531e-05) | 0.019867 ± 0.000135463 (W 7.39594e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058168 ± 0.00040991 (W 0.000165325) | 0.052418 ± 0.000179918 (W 0.000270704) | 0.096581 ± 0.00017433 (W 0.000438836) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.190316 ± 0.000201264 (W 0.00242109) | 0.203832 ± 0.00216934 (W 0.00261074) | 0.243286 ± 0.0153739 (W 0.00239727) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.069469 ± 0.000196016 (W 0.000308873) | 0.20259 ± 0.0392593 (W 0.0181629) | 0.05356 ± 0.0896903 (W 0.0011127) | 🔵 fork 2.92× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.311334 ± 0.00308695 (W 0.00660472) | 0.857158 ± 0.0164347 (W 0.0253571) | 0.284189 ± 0.000369938 (W 0.00190549) | 🔵 fork 2.75× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.769813 ± 0.0109866 (W 0.0128742) | 1.78051 ± 0.0238433 (W 0.0319587) | 0.740188 ± 0.00271519 (W 0.0059059) | 🔵 fork 2.31× faster than `faer-upstream` | · |  |
| `qr_factor/n32/b1` | 0.057266 ± 0.00070616 (W 0.00105119) | 0.135903 ± 0.00281815 (W 0.00397897) | 0.028714 ± 2.5697e-05 (W 5.26802e-05) | 🔵 fork 2.37× faster than `faer-upstream` | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.191139 ± 0.0020368 (W 0.00188021) | 0.766136 ± 0.0211212 (W 0.0163081) | 0.761971 ± 0.345327 (W 0.00123436) | 🔵 fork 4.01× faster than `faer-upstream` | 🔵 fork 3.99× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.405274 ± 0.00234988 (W 0.0125977) | 1.50952 ± 0.00515053 (W 0.0267121) | 2.45343 ± 0.00194125 (W 0.00265617) | 🔵 fork 3.72× faster than `faer-upstream` | 🔵 fork 6.05× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014568 ± 4.14769e-05 (W 0.000143827) | 0.012343 ± 9.07377e-05 (W 0.000120563) | 0.020278 ± 0.000100664 (W 3.80789e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060443 ± 0.000127884 (W 0.000189307) | 0.054612 ± 0.000227025 (W 0.000220421) | 0.093274 ± 5.66657e-05 (W 0.000604219) | 🔴 fork 1.11× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.202547 ± 0.00197761 (W 0.00379835) | 0.215715 ± 0.00150307 (W 0.00567327) | 0.236301 ± 0.000888865 (W 0.00177121) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.015809 ± 0.000109637 (W 0.000132406) | 0.015859 ± 0.000194569 (W 0.000104208) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090119 ± 0.000685216 (W 0.000599527) | 0.089717 ± 0.000224025 (W 0.000258257) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.30658 ± 0.000920965 (W 0.0021064) | 0.305893 ± 0.00179483 (W 0.00263605) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011362 ± 6.22923e-05 (W 0.000111446) | 0.011331 ± 7.50555e-05 (W 3.36155e-05) | 0.017453 ± 0.000180832 (W 5.4037e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051076 ± 0.000121025 (W 0.000360598) | 0.051115 ± 4.87545e-05 (W 0.000105119) | 0.08576 ± 0.00037118 (W 0.000133747) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.173526 ± 0.00070556 (W 0.00234733) | 0.189253 ± 0.00156243 (W 0.00446651) | 0.223627 ± 0.000792092 (W 0.00181177) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.067686 ± 0.000461586 (W 0.00139546) | 0.157756 ± 0.00802621 (W 0.0207494) | 0.04825 ± 2.95014e-05 (W 0.000130055) | 🔵 fork 2.33× faster than `faer-upstream` | 🔴 fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.294989 ± 0.00255854 (W 0.00369343) | 0.632237 ± 0.00549551 (W 0.00855842) | 0.286894 ± 0.00020033 (W 0.00149256) | 🔵 fork 2.14× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.676641 ± 0.002449 (W 0.009443) | 1.36062 ± 0.00732164 (W 0.0171189) | 0.733668 ± 0.000981519 (W 0.00217128) | 🔵 fork 2.01× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033192 ± 0.000598323 (W 0.000237483) | 0.097393 ± 0.001343 (W 0.00438576) | 0.026259 ± 6.70099e-05 (W 8.35117e-05) | 🔵 fork 2.93× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.159888 ± 0.000944871 (W 0.00217358) | 0.497073 ± 0.00611051 (W 0.0118138) | 0.756069 ± 0.000649431 (W 0.00145024) | 🔵 fork 3.11× faster than `faer-upstream` | 🔵 fork 4.73× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.336887 ± 0.0116113 (W 0.00564269) | 0.987699 ± 0.00472451 (W 0.0193945) | 2.44046 ± 0.00162124 (W 0.00372589) | 🔵 fork 2.93× faster than `faer-upstream` | 🔵 fork 7.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.012403 ± 0.000113227 (W 5.72302e-05) | 0.012384 ± 0.000110666 (W 6.92842e-05) | 0.017222 ± 5.85947e-05 (W 7.0214e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052809 ± 0.00016544 (W 0.000101332) | 0.053028 ± 0.000130564 (W 0.000231288) | 0.082996 ± 5.78302e-05 (W 0.000220541) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.185045 ± 0.000800238 (W 0.00398121) | 0.201708 ± 0.000840206 (W 0.00427355) | 0.218469 ± 0.000765964 (W 0.00175063) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n32/b1` | 0.01588 ± 0.000146857 (W 0.000187329) | 0.015889 ± 6.82422e-05 (W 9.41807e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089968 ± 0.000390615 (W 0.00171617) | 0.090499 ± 0.000461129 (W 0.00173862) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.302496 ± 0.00172516 (W 0.00419529) | 0.302012 ± 0.00173106 (W 0.00204245) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011302 ± 0.000263231 (W 0.000134273) | 0.011311 ± 4.04145e-05 (W 6.72473e-05) | 0.017583 ± 3.64737e-05 (W 6.92113e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051055 ± 0.000349713 (W 0.000240668) | 0.051066 ± 7.25282e-05 (W 0.000208469) | 0.085611 ± 0.000223297 (W 0.00138402) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.173714 ± 0.00248167 (W 0.00293979) | 0.201364 ± 0.000460023 (W 0.00490877) | 0.22411 ± 0.000141394 (W 0.00174682) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.067706 ± 0.000452903 (W 0.000349327) | 0.19215 ± 0.00365823 (W 0.00562028) | 0.04837 ± 0.000143643 (W 0.000171249) | 🔵 fork 2.84× faster than `faer-upstream` | 🔴 fork 1.40× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.304807 ± 0.00208779 (W 0.00783509) | 0.839523 ± 0.0242615 (W 0.0301884) | 0.263484 ± 0.000439425 (W 0.00174974) | 🔵 fork 2.75× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.764415 ± 0.0129804 (W 0.0131953) | 1.7862 ± 0.0196433 (W 0.0272217) | 0.671488 ± 0.00129197 (W 0.002433) | 🔵 fork 2.34× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033242 ± 0.000141539 (W 0.000312607) | 0.12833 ± 0.00156252 (W 0.00388572) | 0.026109 ± 4.58258e-05 (W 3.83406e-05) | 🔵 fork 3.86× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.163856 ± 0.00235822 (W 0.00263902) | 0.675025 ± 0.0122985 (W 0.01317) | 0.756949 ± 0.00108806 (W 0.00210875) | 🔵 fork 4.12× faster than `faer-upstream` | 🔵 fork 4.62× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.352436 ± 0.00304421 (W 0.00379395) | 1.34215 ± 0.00865475 (W 0.0275789) | 2.44412 ± 0.00289446 (W 0.00255402) | 🔵 fork 3.81× faster than `faer-upstream` | 🔵 fork 6.93× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012473 ± 0.000140358 (W 3.97152e-05) | 0.012243 ± 2.64575e-05 (W 6.59545e-05) | 0.017313 ± 0.000150865 (W 6.28991e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053009 ± 0.00035119 (W 0.000442458) | 0.052879 ± 0.000105357 (W 0.000179881) | 0.083015 ± 0.000161658 (W 0.000177526) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.184844 ± 0.00233304 (W 0.00254436) | 0.215925 ± 0.00243932 (W 0.00272012) | 0.218738 ± 9.96845e-05 (W 0.00223099) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.309206 ± 0.000888535 (W 0.00195876) | 0.311952 ± 0.00161104 (W 0.00264047) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70015 ± 0.0133107 (W 0.00862826) | 2.75829 ± 0.00371716 (W 0.0103483) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.2926 ± 0.0634335 (W 0.114366) | 18.1873 ± 0.226087 (W 0.111949) | - | 🔵 fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.135794 ± 0.0179585 (W 0.0020138) | 0.203058 ± 0.0233037 (W 0.00712542) | 0.151833 ± 0.0137476 (W 0.00167427) | 🔵 fork 1.50× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.98345 ± 0.116383 (W 0.00458283) | 1.16679 ± 0.0104582 (W 0.0212772) | 0.382867 ± 0.113415 (W 0.00198594) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.57× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.8454 ± 0.0356024 (W 0.0433415) | 5.52405 ± 0.0830321 (W 0.0483306) | 2.60139 ± 0.0253992 (W 0.00629647) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 1.86× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.629904 ± 0.0108675 (W 0.031124) | 1.42738 ± 0.00994538 (W 0.0205864) | 0.479804 ± 0.0012203 (W 0.00326692) | 🔵 fork 2.27× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.02681 ± 0.00593163 (W 0.0250298) | 3.76372 ± 0.0956613 (W 0.0297047) | 2.01185 ± 0.00698217 (W 0.00465635) | 🔵 fork 1.86× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr/n512/b1` | 10.195 ± 0.0605741 (W 0.094547) | 14.2293 ± 0.0757052 (W 0.149209) | 12.0284 ± 0.0304144 (W 0.0225221) | 🔵 fork 1.40× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.356498 ± 0.0262777 (W 0.022284) | 1.42664 ± 0.0192927 (W 0.011133) | 0.196566 ± 0.000477595 (W 0.00184537) | 🔵 fork 4.00× faster than `faer-upstream` | 🔴 fork 1.81× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.46124 ± 0.0193887 (W 0.0251068) | 5.49284 ± 0.0590419 (W 0.0699437) | 0.674106 ± 0.00134691 (W 0.00345967) | 🔵 fork 3.76× faster than `faer-upstream` | 🔴 fork 2.17× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.23387 ± 0.0143713 (W 0.0367555) | 21.9065 ± 0.231395 (W 0.0665982) | 3.87024 ± 0.0139846 (W 0.00564414) | 🔵 fork 4.19× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.13405 ± 0.000175211 (W 0.00140487) | 0.205372 ± 0.0120397 (W 0.00441016) | 0.150239 ± 0.000268898 (W 0.000987397) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.768991 ± 0.0201162 (W 0.00259527) | 0.883205 ± 0.00932595 (W 0.0216056) | 0.369467 ± 0.0024645 (W 0.00280352) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 2.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.78626 ± 0.0642609 (W 0.0634664) | 5.45208 ± 0.0236046 (W 0.0317166) | 1.82495 ± 0.0159296 (W 0.00544837) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 2.62× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.312234 ± 0.00391222 (W 0.00259218) | 0.312883 ± 0.00369774 (W 0.00312477) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.69794 ± 0.010623 (W 0.0116749) | 2.76592 ± 0.0103968 (W 0.00589576) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.3253 ± 0.174808 (W 0.0868149) | 17.8486 ± 0.143338 (W 0.0986829) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134973 ± 0.0170111 (W 0.0020679) | 0.222206 ± 0.0245451 (W 0.00916312) | 0.149408 ± 0.0243311 (W 0.00187874) | 🔵 fork 1.65× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.986456 ± 0.118581 (W 0.00366844) | 1.27984 ± 0.00673707 (W 0.0278203) | 0.352026 ± 0.154129 (W 0.00404787) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 2.80× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.77908 ± 0.0454995 (W 0.0876116) | 5.7523 ± 0.0810268 (W 0.0696682) | 2.28057 ± 0.058113 (W 0.0140143) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.622398 ± 0.00626571 (W 0.0153921) | 1.90908 ± 0.0251704 (W 0.0208325) | 0.433306 ± 0.00336972 (W 0.00372484) | 🔵 fork 3.07× faster than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.14914 ± 0.0198863 (W 0.028249) | 4.84872 ± 0.0394261 (W 0.0446482) | 1.79416 ± 0.00667204 (W 0.00854014) | 🔵 fork 2.26× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr/n512/b1` | 10.3449 ± 0.0309971 (W 0.147929) | 15.772 ± 0.148485 (W 0.144103) | 9.01372 ± 0.0202296 (W 0.0243739) | 🔵 fork 1.52× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.371502 ± 0.00131636 (W 0.00443202) | 1.96856 ± 0.00672173 (W 0.015984) | 0.155561 ± 0.00119043 (W 0.00264674) | 🔵 fork 5.30× faster than `faer-upstream` | 🔴 fork 2.39× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.55759 ± 0.00796164 (W 0.0211655) | 6.6371 ± 0.0551262 (W 0.0232255) | 0.577576 ± 0.00274208 (W 0.00397476) | 🔵 fork 4.26× faster than `faer-upstream` | 🔴 fork 2.70× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.4829 ± 0.0402542 (W 0.0471019) | 25.1122 ± 0.109074 (W 0.911772) | 2.31458 ± 0.00870046 (W 0.00373293) | 🔵 fork 4.58× faster than `faer-upstream` | 🔴 fork 2.37× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134061 ± 0.000882023 (W 0.000156398) | 0.215023 ± 0.00412798 (W 0.0062813) | 0.146573 ± 0.000356643 (W 0.00121436) | 🔵 fork 1.60× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.76756 ± 0.00331702 (W 0.00316289) | 0.964034 ± 0.00644256 (W 0.0285135) | 0.335766 ± 0.00248477 (W 0.00227654) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 2.29× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.73812 ± 0.0270351 (W 0.0874918) | 5.59185 ± 0.0417425 (W 0.0804098) | 1.2862 ± 0.00876127 (W 0.00519101) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 3.68× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.291937 ± 0.0016512 (W 0.00294809) | 0.289859 ± 0.0022159 (W 0.00190961) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.63089 ± 0.00879602 (W 0.00972617) | 2.6054 ± 0.017695 (W 0.00834576) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8407 ± 0.131404 (W 0.0413167) | 16.8983 ± 0.0530477 (W 0.300174) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145332 ± 0.000972522 (W 0.00292665) | 0.217067 ± 0.00285682 (W 0.00579531) | 0.132888 ± 0.00148351 (W 0.00152501) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.703291 ± 0.117295 (W 0.00358559) | 0.8273 ± 0.121347 (W 0.0163752) | 0.325796 ± 0.00292623 (W 0.00228416) | · | 🔴 fork 2.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.32032 ± 0.0234592 (W 0.058518) | 4.59579 ± 0.0321764 (W 0.0516555) | 1.63263 ± 0.0140903 (W 0.00345651) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 2.65× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.577074 ± 0.0197182 (W 0.0256486) | 1.40196 ± 0.0147131 (W 0.0213616) | 0.452604 ± 0.00150886 (W 0.00397879) | 🔵 fork 2.43× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.93338 ± 0.0215804 (W 0.0182368) | 3.60369 ± 0.0592703 (W 0.060526) | 2.18741 ± 0.0189502 (W 0.012156) | 🔵 fork 1.86× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.71572 ± 0.0947761 (W 0.0842358) | 13.3528 ± 0.0814153 (W 0.0891899) | 13.0711 ± 0.0461513 (W 0.0259196) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.365862 ± 0.00550441 (W 0.00649942) | 1.14301 ± 0.0146641 (W 0.009499) | 0.183412 ± 0.00181522 (W 0.00203525) | 🔵 fork 3.12× faster than `faer-upstream` | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.35996 ± 0.00956839 (W 0.0317012) | 2.9686 ± 0.00665987 (W 0.0392163) | 0.622606 ± 0.00371159 (W 0.00273603) | 🔵 fork 2.18× faster than `faer-upstream` | 🔴 fork 2.18× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.82231 ± 0.0407826 (W 0.040896) | 8.21667 ± 0.0953332 (W 0.0917686) | 3.66931 ± 0.00299746 (W 0.0058742) | 🔵 fork 1.70× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112481 ± 0.000226144 (W 0.00162829) | 0.179226 ± 0.00771028 (W 0.00712083) | 0.131725 ± 0.000747962 (W 0.00159433) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.675377 ± 0.0186853 (W 0.00255992) | 0.792855 ± 0.0107736 (W 0.0150097) | 0.310803 ± 0.00451036 (W 0.0027224) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.2368 ± 0.0599722 (W 0.110913) | 4.38203 ± 0.0254074 (W 0.0236985) | 1.63365 ± 0.0132112 (W 0.00331037) | · | 🔴 fork 2.59× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.289077 ± 0.00260353 (W 0.00245126) | 0.29 ± 0.00216532 (W 0.00164021) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61699 ± 0.00731298 (W 0.00724754) | 2.61895 ± 0.00471785 (W 0.00817842) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8446 ± 0.172809 (W 0.119788) | 16.7201 ± 0.111931 (W 0.118505) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146263 ± 0.000742594 (W 0.00230366) | 0.235259 ± 0.00665233 (W 0.00564229) | 0.132727 ± 0.00050854 (W 0.000327961) | 🔵 fork 1.61× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.706506 ± 0.117644 (W 0.00356345) | 0.925715 ± 0.118203 (W 0.0299786) | 0.318556 ± 0.00269175 (W 0.00232568) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 2.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.23705 ± 0.0804765 (W 0.0382392) | 4.73975 ± 0.0210089 (W 0.06315) | 1.22419 ± 0.00613975 (W 0.00493836) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 3.46× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.593531 ± 0.00308414 (W 0.0182804) | 1.88154 ± 0.0114989 (W 0.0198595) | 0.412592 ± 0.000874372 (W 0.00405565) | 🔵 fork 3.17× faster than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 2.04675 ± 0.0141613 (W 0.0178489) | 4.67513 ± 0.0399757 (W 0.0394829) | 2.01174 ± 0.0151591 (W 0.0150766) | 🔵 fork 2.28× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 9.74552 ± 0.0413372 (W 0.0989822) | 14.7148 ± 0.0743294 (W 0.109665) | 10.2293 ± 0.0271916 (W 0.0320563) | 🔵 fork 1.51× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.330225 ± 0.00219017 (W 0.00227882) | 1.59159 ± 0.00545241 (W 0.0143871) | 0.144329 ± 0.0019131 (W 0.0016949) | 🔵 fork 4.82× faster than `faer-upstream` | 🔴 fork 2.29× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.46344 ± 0.00532054 (W 0.0126614) | 3.98941 ± 0.0213882 (W 0.0402986) | 0.539364 ± 0.00525727 (W 0.00166968) | 🔵 fork 2.73× faster than `faer-upstream` | 🔴 fork 2.71× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.16184 ± 0.00296861 (W 0.0653345) | 10.0114 ± 0.148362 (W 0.0882862) | 2.20046 ± 0.00651542 (W 0.00378786) | 🔵 fork 1.94× faster than `faer-upstream` | 🔴 fork 2.35× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111929 ± 0.00104158 (W 0.000346255) | 0.186039 ± 0.00403506 (W 0.0028465) | 0.132168 ± 0.000471511 (W 0.00150892) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.680838 ± 0.001865 (W 0.00325793) | 0.808386 ± 0.00172741 (W 0.0251386) | 0.300783 ± 0.0022456 (W 0.00390392) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.26× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.19723 ± 0.0648746 (W 0.0617286) | 4.55044 ± 0.132591 (W 0.056981) | 1.19378 ± 0.00990416 (W 0.00634863) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 3.52× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.782516 ± 0.00227657 (W 0.00440151) | 0.776825 ± 0.00559743 (W 0.00538087) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.9276 ± 0.0180809 (W 0.0190627) | 6.01579 ± 0.0344255 (W 0.0143111) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 29.6577 ± 0.148314 (W 0.118833) | 29.5179 ± 0.0406692 (W 0.0886839) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.326261 ± 0.0015637 (W 0.00253743) | 0.345634 ± 0.0052344 (W 0.00812676) | 0.483121 ± 0.00251201 (W 0.00315939) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.13415 ± 0.00339999 (W 0.00983929) | 1.68498 ± 0.0142536 (W 0.0233398) | 1.02066 ± 0.00300077 (W 0.00344441) | 🔴 fork 1.27× slower than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.911 ± 0.068766 (W 0.0897969) | 9.89444 ± 0.0132466 (W 0.0393724) | 7.59441 ± 0.035387 (W 0.0293329) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.02453 ± 0.0054495 (W 0.00779566) | 1.91896 ± 0.0121634 (W 0.0181901) | 1.03933 ± 0.00552029 (W 0.00264751) | 🔵 fork 1.87× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.58015 ± 0.0144242 (W 0.0491034) | 6.22736 ± 0.0207868 (W 0.0441396) | 4.78033 ± 0.0209555 (W 0.0104401) | 🔵 fork 1.36× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 27.2839 ± 0.0197551 (W 0.115625) | 30.495 ± 0.203014 (W 0.123748) | 28.5491 ± 0.0585815 (W 0.040007) | 🔵 fork 1.12× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.610948 ± 0.00686975 (W 0.00690041) | 1.77841 ± 0.018344 (W 0.0152647) | 0.45379 ± 0.000618738 (W 0.0024851) | 🔵 fork 2.91× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.90934 ± 0.0191651 (W 0.0291783) | 7.2676 ± 0.02959 (W 0.0480101) | 1.63769 ± 0.00376406 (W 0.00349835) | 🔵 fork 2.50× faster than `faer-upstream` | 🔴 fork 1.78× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.0422 ± 0.0209702 (W 0.06066) | 26.2471 ± 0.471837 (W 0.129359) | 11.4075 ± 0.00887629 (W 0.0165641) | 🔵 fork 2.18× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.323085 ± 0.00270121 (W 0.0028821) | 0.335037 ± 0.00214316 (W 0.00643846) | 0.465757 ± 0.000411501 (W 0.00199012) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.07418 ± 0.00936505 (W 0.0153696) | 1.56387 ± 0.0138633 (W 0.0207934) | 0.902102 ± 0.00582792 (W 0.00242853) | 🔴 fork 1.33× slower than `faer-upstream` | 🔴 fork 2.30× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 11.4483 ± 0.0549536 (W 0.0838518) | 10.3059 ± 0.0720738 (W 0.0239743) | 5.6939 ± 0.0191865 (W 0.0156532) | 🔴 fork 1.11× slower than `faer-upstream` | 🔴 fork 2.01× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.775806 ± 0.00124475 (W 0.00628231) | 0.773577 ± 0.00224798 (W 0.00544063) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.9192 ± 0.0390366 (W 0.0111948) | 6.05837 ± 0.0252982 (W 0.0194879) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.1098 ± 0.0515211 (W 0.0879682) | 27.8448 ± 0.0308579 (W 0.074176) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.324635 ± 0.00169682 (W 0.00179241) | 0.367497 ± 0.00699803 (W 0.00420451) | 0.487737 ± 0.00203777 (W 0.0039723) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.14786 ± 0.0137367 (W 0.0115948) | 1.71769 ± 0.0203875 (W 0.0265008) | 0.699183 ± 0.00804881 (W 0.00341938) | 🔴 fork 1.25× slower than `faer-upstream` | 🔴 fork 3.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.97245 ± 0.0521738 (W 0.0818367) | 8.87048 ± 0.0420917 (W 0.0442441) | 5.02896 ± 0.0118081 (W 0.0360965) | 🔴 fork 1.12× slower than `faer-upstream` | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.14975 ± 0.000589964 (W 0.0107156) | 2.46273 ± 0.0200804 (W 0.0337236) | 0.782267 ± 0.0460115 (W 0.00430469) | 🔵 fork 2.14× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 4.2123 ± 0.0116126 (W 0.0338268) | 6.92726 ± 0.0299386 (W 0.032107) | 3.81732 ± 0.00543631 (W 0.00581373) | 🔵 fork 1.64× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `qr/n512/b1` | 22.3506 ± 0.0527561 (W 0.251195) | 26.8742 ± 0.13915 (W 0.257387) | 16.0233 ± 0.100295 (W 0.0212377) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 1.39× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.666161 ± 0.00623046 (W 0.0103297) | 2.31832 ± 0.0198243 (W 0.0276669) | 0.32059 ± 0.00289218 (W 0.00241373) | 🔵 fork 3.48× faster than `faer-upstream` | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.81532 ± 0.0111817 (W 0.0169132) | 8.44647 ± 0.101487 (W 0.931906) | 1.62043 ± 0.00449194 (W 0.00151231) | 🔵 fork 3.00× faster than `faer-upstream` | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 10.7557 ± 0.10851 (W 0.0877278) | 27.5819 ± 0.27726 (W 0.162598) | 5.79894 ± 0.0110145 (W 0.00908738) | 🔵 fork 2.56× faster than `faer-upstream` | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.322593 ± 0.00183082 (W 0.00230437) | 0.3544 ± 0.00639016 (W 0.00357579) | 0.467715 ± 0.00281342 (W 0.00257779) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.09864 ± 0.0250083 (W 0.0126148) | 1.52847 ± 0.0143333 (W 0.0358919) | 0.667353 ± 0.00506516 (W 0.00396982) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 3.14× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.3622 ± 0.0248842 (W 0.106608) | 9.19482 ± 0.0892173 (W 0.0436415) | 3.41645 ± 0.0083611 (W 0.00746118) | 🔴 fork 1.13× slower than `faer-upstream` | 🔴 fork 3.03× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.756206 ± 0.00404781 (W 0.00580467) | 0.750716 ± 0.0049052 (W 0.00393665) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.7818 ± 0.0264676 (W 0.0129563) | 5.72625 ± 0.0278662 (W 0.0151856) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 28.4827 ± 0.105864 (W 0.0695084) | 28.5143 ± 0.0806833 (W 0.0642291) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.297244 ± 0.0021113 (W 0.00259091) | 0.312562 ± 0.00453523 (W 0.00681598) | 0.45616 ± 0.00296224 (W 0.00235052) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.02314 ± 0.0109425 (W 0.0104835) | 1.48785 ± 0.0148499 (W 0.0223737) | 0.978202 ± 0.00252431 (W 0.00351083) | 🔴 fork 1.36× slower than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.73992 ± 0.0289725 (W 0.0445109) | 9.0442 ± 0.0546617 (W 0.0543611) | 5.79943 ± 0.0237157 (W 0.00673517) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.00173 ± 0.00771783 (W 0.00206179) | 1.88887 ± 0.000884846 (W 0.0160764) | 1.05693 ± 0.00130461 (W 0.00336701) | 🔵 fork 1.89× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 4.43067 ± 0.0172685 (W 0.026344) | 6.02932 ± 0.0440973 (W 0.0512859) | 4.99867 ± 0.00685155 (W 0.00884306) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 26.2025 ± 0.149739 (W 0.125775) | 29.5092 ± 0.0651403 (W 0.150636) | 29.0517 ± 0.0304923 (W 0.0301758) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.548657 ± 0.0027167 (W 0.0020938) | 1.40732 ± 0.038518 (W 0.00965294) | 0.434831 ± 0.000418144 (W 0.00236128) | 🔵 fork 2.57× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.72617 ± 0.0201054 (W 0.0335803) | 4.2597 ± 0.0255121 (W 0.0270896) | 1.57618 ± 0.00261223 (W 0.00416214) | 🔵 fork 1.56× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.2384 ± 0.0864802 (W 0.0293932) | 14.6551 ± 0.023896 (W 0.0601707) | 11.0038 ± 0.00198773 (W 0.0148099) | 🔵 fork 1.30× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.293627 ± 0.00212595 (W 0.00180225) | 0.303436 ± 0.00176872 (W 0.0042495) | 0.446192 ± 0.00112492 (W 0.00269591) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.95528 ± 0.0050259 (W 0.00385817) | 1.33369 ± 0.0149941 (W 0.0168093) | 0.85948 ± 0.00295571 (W 0.00466476) | 🔴 fork 1.47× slower than `faer-upstream` | 🔴 fork 2.27× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 10.329 ± 0.0413471 (W 0.0303236) | 9.41768 ± 0.0331409 (W 0.0460786) | 5.38417 ± 0.00768546 (W 0.0101516) | 🔴 fork 1.10× slower than `faer-upstream` | 🔴 fork 1.92× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/n128/b1` | 0.749835 ± 0.00335892 (W 0.00478595) | 0.74214 ± 0.000909004 (W 0.00448653) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.76883 ± 0.0252985 (W 0.0124018) | 5.75346 ± 0.0463514 (W 0.015449) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.0164 ± 0.0649583 (W 0.149778) | 26.9761 ± 0.13411 (W 0.192946) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296753 ± 0.00207138 (W 0.00227383) | 0.333344 ± 0.00323858 (W 0.0032481) | 0.458988 ± 0.00193783 (W 0.00239028) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.00595 ± 0.0399612 (W 0.013356) | 1.46668 ± 0.0100559 (W 0.0126633) | 0.682967 ± 0.0025448 (W 0.00337894) | 🔴 fork 1.37× slower than `faer-upstream` | 🔴 fork 2.94× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.73995 ± 0.0525669 (W 0.0582012) | 8.02337 ± 0.0124616 (W 0.0565143) | 3.48022 ± 0.00986044 (W 0.0125648) | 🔴 fork 1.09× slower than `faer-upstream` | 🔴 fork 2.51× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.13471 ± 0.00277559 (W 0.0145855) | 2.39769 ± 0.00256169 (W 0.0330784) | 0.797041 ± 0.0092759 (W 0.00403975) | 🔵 fork 2.11× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 4.04585 ± 0.0250427 (W 0.0239758) | 6.76167 ± 0.0944927 (W 0.0891405) | 4.05556 ± 0.00541593 (W 0.00926438) | 🔵 fork 1.67× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 21.3053 ± 0.187078 (W 0.193949) | 25.9319 ± 0.0364924 (W 0.240526) | 17.0826 ± 0.0589218 (W 0.0366133) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.59875 ± 0.00627113 (W 0.00480218) | 1.91334 ± 0.0127961 (W 0.0197717) | 0.30564 ± 0.00094081 (W 0.00158565) | 🔵 fork 3.20× faster than `faer-upstream` | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.70827 ± 0.0233558 (W 0.00957101) | 5.34457 ± 0.0691598 (W 0.0619662) | 1.5771 ± 0.00321943 (W 0.00206965) | 🔵 fork 1.97× faster than `faer-upstream` | 🔴 fork 1.72× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 10.1703 ± 0.040167 (W 0.127674) | 15.061 ± 0.180725 (W 0.152597) | 5.61574 ± 0.0139714 (W 0.00616325) | 🔵 fork 1.48× faster than `faer-upstream` | 🔴 fork 1.81× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.292305 ± 0.000534326 (W 0.00175221) | 0.32718 ± 0.00259171 (W 0.00597953) | 0.44274 ± 0.00113886 (W 0.00200382) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.96759 ± 0.00761809 (W 0.019265) | 1.32576 ± 0.00576516 (W 0.0168927) | 0.645698 ± 0.00583478 (W 0.00248838) | 🔴 fork 1.48× slower than `faer-upstream` | 🔴 fork 3.05× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.26331 ± 0.0468075 (W 0.0970149) | 8.38137 ± 0.0630902 (W 0.0971198) | 3.33471 ± 0.0345119 (W 0.00323603) | 🔴 fork 1.11× slower than `faer-upstream` | 🔴 fork 2.78× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.81575 ± 0.00423875 (W 0.00760511) | 0.815927 ± 0.00255131 (W 0.00638223) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.7296 ± 0.102556 (W 0.177871) | 23.5605 ± 0.132388 (W 0.148548) | - | 🔵 fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.493593 ± 0.0149725 (W 0.0130271) | 0.507756 ± 0.00919999 (W 0.0151819) | 0.532421 ± 0.119421 (W 0.00307997) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.52092 ± 0.145747 (W 0.0915314) | 13.0471 ± 0.0121388 (W 0.0318377) | 13.3674 ± 1.88557 (W 0.0560741) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.2847 ± 0.00753369 (W 0.00805158) | 1.69036 ± 0.0123013 (W 0.0176297) | 1.06166 ± 0.00691703 (W 0.00883856) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 28.3383 ± 0.121529 (W 0.203469) | 35.4798 ± 0.777885 (W 0.209057) | 30.041 ± 0.145388 (W 0.217179) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.05878 ± 0.00205537 (W 0.00858631) | 3.78448 ± 0.0965082 (W 0.0866502) | 0.457125 ± 0.00480228 (W 0.0076535) | 🔵 fork 3.57× faster than `faer-upstream` | 🔴 fork 2.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 15.8831 ± 0.0916623 (W 0.187203) | 76.956 ± 0.690592 (W 0.267682) | 12.7216 ± 0.116625 (W 0.0726666) | 🔵 fork 4.85× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.836067 ± 0.0123088 (W 0.0032653) | 0.812574 ± 0.00277575 (W 0.00636661) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.7275 ± 0.118225 (W 0.108197) | 19.4243 ± 0.0377399 (W 0.0923855) | - | 🔵 fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.473692 ± 0.00795471 (W 0.00433556) | 0.523097 ± 0.0100564 (W 0.0127723) | 0.595382 ± 0.164643 (W 0.00421626) | 🔵 fork 1.10× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.83377 ± 0.144904 (W 0.0425446) | 12.2555 ± 0.0221985 (W 0.0203556) | 4.13992 ± 1.77025 (W 0.0181743) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 2.13× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.4138 ± 0.00921307 (W 0.018356) | 1.98913 ± 0.0136603 (W 0.0253048) | 0.880274 ± 0.00486182 (W 0.00301911) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.6442 ± 0.280516 (W 0.312697) | 34.8766 ± 0.468453 (W 0.561312) | 20.9513 ± 0.225224 (W 0.0725315) | 🔵 fork 1.54× faster than `faer-upstream` | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.15209 ± 0.0145971 (W 0.0117832) | 4.39181 ± 0.100559 (W 0.142401) | 0.321491 ± 0.00160025 (W 0.00196511) | 🔵 fork 3.81× faster than `faer-upstream` | 🔴 fork 3.58× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 12.8475 ± 0.0832175 (W 0.0828341) | 76.2114 ± 0.433717 (W 0.566534) | 7.35172 ± 0.0372764 (W 0.0571167) | 🔵 fork 5.93× faster than `faer-upstream` | 🔴 fork 1.75× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731738 ± 0.00154478 (W 0.00280488) | 0.731182 ± 0.00251644 (W 0.00283125) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.632 ± 0.0424042 (W 0.129743) | 17.7188 ± 0.0490691 (W 0.108726) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.407141 ± 0.0110676 (W 0.0112473) | 0.42938 ± 0.00198745 (W 0.00753316) | 0.286576 ± 0.00132385 (W 0.00203035) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 7.37137 ± 0.0753834 (W 0.0319146) | 7.36702 ± 0.0230849 (W 0.0275097) | 11.6176 ± 0.0308732 (W 0.0307047) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.19886 ± 0.00648699 (W 0.0279699) | 1.61014 ± 0.00569843 (W 0.0145707) | 0.988037 ± 0.0046659 (W 0.00584617) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.1324 ± 0.0771822 (W 0.207104) | 29.7224 ± 0.193074 (W 0.095642) | 27.0366 ± 0.0861386 (W 0.0493868) | 🔵 fork 1.14× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.9252 ± 0.00643565 (W 0.0103086) | 1.35923 ± 0.0106825 (W 0.0148888) | 0.417581 ± 0.0054916 (W 0.00801711) | 🔵 fork 1.47× faster than `faer-upstream` | 🔴 fork 2.22× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.5361 ± 0.102541 (W 0.233703) | 17.8635 ± 0.197402 (W 0.124466) | 11.2308 ± 0.0501536 (W 0.0712846) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.732088 ± 0.00123837 (W 0.00158504) | 0.728326 ± 0.00383675 (W 0.00320504) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.5765 ± 0.100617 (W 0.100561) | 13.6715 ± 0.118188 (W 0.0694142) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.392624 ± 0.000282643 (W 0.00506602) | 0.44582 ± 0.00442969 (W 0.0110274) | 0.287017 ± 0.00159741 (W 0.00271955) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.68893 ± 0.0519437 (W 0.0279163) | 6.68984 ± 0.00952725 (W 0.0614988) | 3.14264 ± 0.0450998 (W 0.011938) | · | 🔴 fork 2.13× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.31717 ± 0.00782344 (W 0.0135315) | 1.8927 ± 0.0349556 (W 0.0269824) | 0.846381 ± 0.0011443 (W 0.00348303) | 🔵 fork 1.44× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 20.3289 ± 0.263394 (W 0.45329) | 29.7001 ± 0.19036 (W 1.01645) | 19.2532 ± 0.0630175 (W 0.0348179) | 🔵 fork 1.46× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.05977 ± 0.0113565 (W 0.0121936) | 1.65038 ± 0.0187369 (W 0.0247115) | 0.300971 ± 0.000660586 (W 0.00270342) | 🔵 fork 1.56× faster than `faer-upstream` | 🔴 fork 3.52× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.5417 ± 0.0753355 (W 0.0742108) | 19.2509 ± 0.26625 (W 0.166874) | 6.47021 ± 0.0444672 (W 0.0406514) | 🔵 fork 1.67× faster than `faer-upstream` | 🔴 fork 1.78× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.81839 ± 0.0101797 (W 0.00829024) | 1.8005 ± 0.036291 (W 0.00258165) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.8628 ± 0.165169 (W 0.544576) | 66.1587 ± 1.60475 (W 1.14113) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.865219 ± 0.0119835 (W 0.00894641) | 0.80677 ± 0.0341839 (W 0.0163393) | 1.09522 ± 0.00250283 (W 0.00233107) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 22.8599 ± 0.084648 (W 0.120342) | 29.6726 ± 0.0338165 (W 0.101054) | 52.3756 ± 3.98895 (W 0.115007) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.65938 ± 0.120543 (W 0.101248) | 2.99943 ± 0.00468125 (W 0.0170511) | 3.11964 ± 0.0150142 (W 0.0300787) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 83.8277 ± 0.171474 (W 0.192864) | 98.7261 ± 0.370016 (W 0.371865) | 80.0164 ± 0.117905 (W 0.30592) | 🔵 fork 1.18× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.91143 ± 0.064941 (W 0.0769013) | 4.49631 ± 0.0863032 (W 0.0323393) | 1.39083 ± 0.0029616 (W 0.00346546) | 🔵 fork 2.35× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 40.3086 ± 0.117113 (W 0.128477) | 124.117 ± 0.540895 (W 0.53894) | 33.9625 ± 0.125839 (W 0.184461) | 🔵 fork 3.08× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.82508 ± 0.00556072 (W 0.00646476) | 1.80328 ± 0.0311336 (W 0.00353337) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 35.5177 ± 0.306865 (W 0.588936) | 41.2744 ± 0.0851379 (W 0.108379) | - | 🔵 fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.84486 ± 0.0031298 (W 0.00464655) | 0.793888 ± 0.00194086 (W 0.00700724) | 1.08487 ± 0.00297515 (W 0.00221447) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 18.8674 ± 0.179934 (W 0.382803) | 25.7524 ± 0.0182791 (W 0.0570068) | 52.447 ± 2.78721 (W 0.127442) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 2.78× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.46234 ± 0.0199218 (W 0.0229594) | 3.22762 ± 0.00928956 (W 0.0365444) | 2.316 ± 0.0173558 (W 0.00655783) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 57.4737 ± 0.0497035 (W 0.236426) | 82.0702 ± 0.0949788 (W 0.521988) | 45.8524 ± 0.0610189 (W 0.0626693) | 🔵 fork 1.43× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.86386 ± 0.00442452 (W 0.0212438) | 4.79791 ± 0.227835 (W 0.068459) | 0.874625 ± 0.0023468 (W 0.00129934) | 🔵 fork 2.57× faster than `faer-upstream` | 🔴 fork 2.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 30.2829 ± 0.127116 (W 0.0488377) | 121.59 ± 0.5639 (W 1.01198) | 19.7598 ± 0.025714 (W 0.0815643) | 🔵 fork 4.02× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.69421 ± 0.00625852 (W 0.00231464) | 1.66783 ± 0.0132482 (W 0.00386081) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.7288 ± 0.323915 (W 0.495204) | 52.4146 ± 0.0568878 (W 0.371223) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.754646 ± 0.0109331 (W 0.00734214) | 0.706843 ± 0.00318068 (W 0.00728723) | 1.06577 ± 0.00786929 (W 0.00183471) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.3791 ± 0.021016 (W 0.0523456) | 17.3546 ± 0.00748853 (W 0.0417164) | 49.5027 ± 0.559681 (W 0.090284) | · | 🔵 fork 2.85× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.51707 ± 0.0944903 (W 0.0676793) | 2.90599 ± 0.00948538 (W 0.0178558) | 3.03827 ± 0.0622557 (W 0.0054328) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 78.3332 ± 0.109138 (W 0.15622) | 86.3598 ± 0.07522 (W 0.118286) | 74.7031 ± 0.106021 (W 0.265697) | 🔵 fork 1.10× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.75224 ± 0.0315396 (W 0.0619262) | 2.12587 ± 0.00179987 (W 0.0134766) | 1.3516 ± 0.00146248 (W 0.0417627) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 35.7538 ± 0.0315389 (W 0.0377674) | 44.4443 ± 0.125933 (W 0.299592) | 31.4146 ± 0.204171 (W 0.125896) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.69065 ± 0.00635838 (W 0.00358614) | 1.66084 ± 0.00474842 (W 0.00324451) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.5482 ± 0.217303 (W 0.193564) | 28.9807 ± 0.143622 (W 0.430328) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.719029 ± 0.00252426 (W 0.00706281) | 0.688266 ± 0.00319422 (W 0.011125) | 1.06557 ± 0.0097105 (W 0.00192893) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.5734 ± 0.0279772 (W 0.0668724) | 13.5316 ± 0.0544303 (W 0.0486888) | 49.5578 ± 0.0640338 (W 0.0640282) | · | 🔵 fork 3.65× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.29093 ± 0.0300032 (W 0.0133457) | 3.12833 ± 0.0117708 (W 0.0220717) | 2.27971 ± 0.00813357 (W 0.00361595) | 🔵 fork 1.37× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 51.8172 ± 0.15491 (W 0.105923) | 69.8907 ± 0.180799 (W 0.428326) | 42.0694 ± 0.217328 (W 0.170946) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.71797 ± 0.00790033 (W 0.0145258) | 2.44824 ± 0.0101584 (W 0.0245991) | 0.853159 ± 0.00164202 (W 0.00268233) | 🔵 fork 1.43× faster than `faer-upstream` | 🔴 fork 2.01× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.2312 ± 0.0634823 (W 0.126845) | 41.7033 ± 0.0879807 (W 2.34077) | 17.7179 ± 0.106782 (W 0.0517132) | 🔵 fork 1.53× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.5477 ± 0.131706 (W 0.142585) | 39.8896 ± 0.308909 (W 0.395456) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.10512 ± 0.0127217 (W 0.00301268) | 1.24476 ± 0.0368451 (W 0.00519584) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 7.32241 ± 0.109485 (W 0.0889444) | 9.33915 ± 0.161342 (W 0.0879402) | 10.1404 ± 0.141522 (W 0.0599072) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.238225 ± 0.0076895 (W 0.00500203) | 0.395408 ± 0.0237318 (W 0.0232326) | 0.28881 ± 0.00422794 (W 0.00173799) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 11.1213 ± 0.120374 (W 0.198326) | 14.4806 ± 0.383657 (W 0.27982) | 16.9202 ± 0.0757765 (W 0.117191) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.439488 ± 0.00308109 (W 0.00467539) | 0.778394 ± 0.0186103 (W 0.0122675) | 0.626931 ± 0.007158 (W 0.0126769) | 🔵 fork 1.77× faster than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 10.4696 ± 0.177081 (W 0.0452382) | 12.497 ± 0.144635 (W 0.0364755) | 13.411 ± 0.00999953 (W 0.0164894) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.669206 ± 0.00367093 (W 0.00709959) | 0.981784 ± 0.0895955 (W 0.0107131) | 0.432247 ± 0.00231324 (W 0.00218128) | 🔵 fork 1.47× faster than `faer-upstream` | 🔴 fork 1.55× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.6684 ± 0.155476 (W 0.199017) | 35.0077 ± 0.618704 (W 0.178938) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.10751 ± 0.00295573 (W 0.00683799) | 1.252 ± 0.00833464 (W 0.00541314) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.89645 ± 0.148867 (W 0.221082) | 8.05693 ± 0.175255 (W 0.0571566) | 6.82417 ± 0.056042 (W 0.0360411) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.212897 ± 0.00330257 (W 0.00321863) | 0.372684 ± 0.0213819 (W 0.0212577) | 0.172251 ± 0.00136399 (W 0.00187638) | 🔵 fork 1.75× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 9.36761 ± 0.0689456 (W 0.306141) | 13.4126 ± 0.158794 (W 0.214735) | 10.2446 ± 0.0307772 (W 0.166008) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.45646 ± 0.0090117 (W 0.017521) | 0.928929 ± 0.0162499 (W 0.0227837) | 0.45018 ± 0.00100566 (W 0.0119758) | 🔵 fork 2.04× faster than `faer-upstream` | · |  |
| `qr_factor/256x4096/b1` | 8.73082 ± 0.180902 (W 0.249482) | 11.7223 ± 0.102494 (W 0.380862) | 6.97938 ± 0.0161777 (W 0.0162079) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.694567 ± 0.0169894 (W 0.0291277) | 1.09024 ± 0.0223121 (W 0.0193467) | 0.256669 ± 0.00201266 (W 0.00199563) | 🔵 fork 1.57× faster than `faer-upstream` | 🔴 fork 2.71× slower than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 34.8107 ± 0.285527 (W 0.194789) | 34.8627 ± 0.318858 (W 0.168581) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04223 ± 0.0077415 (W 0.00196537) | 1.0455 ± 0.00574611 (W 0.0032412) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.60109 ± 0.032262 (W 0.0469965) | 4.69475 ± 0.00804016 (W 0.0337422) | 5.2964 ± 0.0334371 (W 0.00953107) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.146202 ± 0.00127719 (W 0.00231036) | 0.166371 ± 0.00275994 (W 0.00542267) | 0.234697 ± 0.00053085 (W 0.00264363) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 8.35101 ± 0.0570263 (W 0.0517707) | 9.50766 ± 0.0566294 (W 0.0563583) | 26.6531 ± 1.23537 (W 0.0490384) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 3.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.329215 ± 0.0143537 (W 0.00450354) | 0.560617 ± 0.00100383 (W 0.007107) | 0.613285 ± 0.00166524 (W 0.00223597) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.86× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 7.24725 ± 0.0344024 (W 0.0389253) | 8.47748 ± 0.0277829 (W 0.0384357) | 11.335 ± 0.0312691 (W 0.0135605) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.234627 ± 0.0111178 (W 0.00287395) | 0.477059 ± 0.00664351 (W 0.0106684) | 0.368698 ± 0.000496367 (W 0.00240611) | 🔵 fork 2.03× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.3856 ± 0.19782 (W 0.12794) | 30.2023 ± 0.0959795 (W 0.211633) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04706 ± 0.00557059 (W 0.00211792) | 1.05129 ± 0.00638326 (W 0.00234209) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 3.1015 ± 0.06332 (W 0.0528002) | 3.31437 ± 0.0719232 (W 0.127906) | 3.11847 ± 0.0408159 (W 0.0120626) | 🔵 fork 1.07× faster than `faer-upstream` | · |  |
| `lu/64x1024/b1` | 0.127187 ± 0.0026846 (W 0.00397222) | 0.153196 ± 0.00128363 (W 0.00644782) | 0.133709 ± 0.000852195 (W 0.00168039) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 6.60054 ± 0.115371 (W 0.223554) | 8.46173 ± 0.11786 (W 0.229832) | 18.9327 ± 0.0870343 (W 0.0455068) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 2.87× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.350284 ± 0.0100439 (W 0.0153713) | 0.718167 ± 0.0179045 (W 0.0268939) | 0.47648 ± 0.00267503 (W 0.00227765) | 🔵 fork 2.05× faster than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 5.34538 ± 0.152134 (W 0.219416) | 7.29906 ± 0.0929742 (W 0.22365) | 5.92064 ± 0.097318 (W 0.0111857) | 🔵 fork 1.37× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.260375 ± 0.00912783 (W 0.013971) | 0.635784 ± 0.00723186 (W 0.0167484) | 0.216374 ± 0.00160149 (W 0.0019067) | 🔵 fork 2.44× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 97.912 ± 3.25165 (W 0.424064) | 98.4135 ± 3.76406 (W 0.657174) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.4427 ± 0.0139138 (W 0.0100761) | 2.49248 ± 0.0544052 (W 0.0106294) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.9601 ± 0.143795 (W 0.108096) | 18.0202 ± 0.141472 (W 0.1285) | 23.7115 ± 3.10918 (W 0.140306) | · | 🔵 fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.440209 ± 0.00368591 (W 0.00721456) | 0.492928 ± 0.00322611 (W 0.00322234) | 0.64433 ± 0.00177335 (W 0.00456253) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 33.5068 ± 0.356392 (W 0.0919749) | 34.4808 ± 0.2824 (W 0.0738898) | 45.7253 ± 0.207787 (W 0.0355574) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 1.00468 ± 0.0181114 (W 0.00658905) | 1.29911 ± 0.0193742 (W 0.0185058) | 1.65482 ± 0.00826602 (W 0.00489857) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 28.6233 ± 0.32815 (W 0.216508) | 30.8444 ± 0.100208 (W 0.0546612) | 39.2901 ± 0.0896536 (W 0.0845175) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 1.01965 ± 0.00563578 (W 0.00713991) | 1.34522 ± 0.0161477 (W 0.0153265) | 1.3576 ± 0.00654726 (W 0.0034969) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.3923 ± 0.814093 (W 0.46755) | 69.5356 ± 0.384313 (W 0.668773) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.42621 ± 0.0417694 (W 0.0137156) | 2.48991 ± 0.0366172 (W 0.00956975) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.1982 ± 0.157779 (W 0.342461) | 12.1987 ± 0.0224657 (W 0.0427815) | 13.7311 ± 2.95702 (W 0.0452501) | 🔴 fork 1.08× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.360812 ± 0.00579048 (W 0.00426358) | 0.404395 ± 0.00155471 (W 0.00535493) | 0.448174 ± 0.0041054 (W 0.00331301) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 23.3681 ± 0.0909062 (W 1.01739) | 25.1919 ± 0.136072 (W 0.580762) | 26.5746 ± 0.1172 (W 0.0422101) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.916236 ± 0.00682557 (W 0.0160312) | 1.37966 ± 0.0358494 (W 0.0390846) | 1.02529 ± 0.00321756 (W 0.00190636) | 🔵 fork 1.51× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 19.2602 ± 0.22765 (W 0.634878) | 21.9521 ± 0.279288 (W 0.489394) | 21.1055 ± 0.0657988 (W 0.0503686) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.930938 ± 0.0726459 (W 0.0156706) | 1.40829 ± 0.00601627 (W 0.0335037) | 0.762489 ± 0.0030692 (W 0.00197619) | 🔵 fork 1.51× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 93.7 ± 2.69942 (W 0.462154) | 93.1942 ± 2.29015 (W 0.514063) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.2929 ± 0.0338965 (W 0.0112313) | 2.23815 ± 0.0464865 (W 0.0167352) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.4336 ± 0.0759732 (W 0.0896346) | 13.8136 ± 0.00418772 (W 0.0749278) | 20.5362 ± 0.0211693 (W 0.0136451) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.321961 ± 0.00306514 (W 0.00334299) | 0.321721 ± 0.0026036 (W 0.00427203) | 0.586625 ± 0.00298367 (W 0.0028594) | · | 🔵 fork 1.82× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 28.9825 ± 0.0320499 (W 0.0994261) | 30.1524 ± 0.189371 (W 0.0337181) | 55.7613 ± 2.99475 (W 0.160695) | · | 🔵 fork 1.92× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.874121 ± 0.0162254 (W 0.00891187) | 1.14659 ± 0.0160867 (W 0.009612) | 1.66759 ± 0.115903 (W 0.0141083) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.91× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 25.9368 ± 0.115338 (W 0.120934) | 27.2622 ± 0.21943 (W 0.0354337) | 36.3051 ± 0.0913033 (W 0.0267947) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.705366 ± 0.0136652 (W 0.00568697) | 0.971459 ± 0.00401004 (W 0.0093235) | 1.28615 ± 0.0029595 (W 0.00518777) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.82× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 64.6186 ± 0.888276 (W 0.413071) | 64.8961 ± 0.192181 (W 0.377043) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.26647 ± 0.0560812 (W 0.0148928) | 2.24104 ± 0.0519577 (W 0.0086366) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.53537 ± 0.108545 (W 0.0841734) | 8.30797 ± 0.0828236 (W 0.0460258) | 11.2506 ± 0.0844441 (W 0.0143436) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.238465 ± 0.00707334 (W 0.00227387) | 0.239305 ± 0.0330942 (W 0.00664147) | 0.410136 ± 0.00298211 (W 0.00161621) | · | 🔵 fork 1.72× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 18.4176 ± 0.65664 (W 0.969753) | 20.7676 ± 0.110311 (W 0.687714) | 36.8497 ± 0.123223 (W 0.0696765) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 2.00× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.791513 ± 0.00106895 (W 0.0146368) | 1.21181 ± 0.018081 (W 0.0345767) | 1.22087 ± 0.11275 (W 0.0278002) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 16.3708 ± 0.0969476 (W 0.825281) | 18.3852 ± 0.440517 (W 0.803938) | 18.7138 ± 0.0085315 (W 0.0147663) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.615065 ± 0.00590651 (W 0.0181566) | 1.01079 ± 0.0130311 (W 0.013916) | 0.709351 ± 0.00150452 (W 0.00277356) | 🔵 fork 1.64× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
