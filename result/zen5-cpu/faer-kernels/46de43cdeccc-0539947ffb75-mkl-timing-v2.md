<!-- generated from data/results/zen5-cpu/faer-kernels/20261019T161954Z-cand-row-major-floor/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `46de43cdecccb033994ca509091c51bcdcb0cd60`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `18e2166d94f08638293872b262ccc6e539c3f52c`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `b9405106261a9f0eea3ce7e42033e9262334fc008574ae55d64fec40efddb2c9`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T16:30:31.171682Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small --threads 4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label cand-row-major-floor`
- raw data: `data/results/zen5-cpu/faer-kernels/20261019T161954Z-cand-row-major-floor/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.18%, worst 290.87% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 116 of 768 engine cells exceed 5% and carry `!`; median within-process relative SD 0.77%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `cholesky/n32/b1` | 0.003256 ± 0.000159478 (W 1.64317e-05) | 0.003446 ± 1.12694e-05 (W 3.98271e-05) | 0.004148 ± 3.10966e-05 (W 2.9955e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015038 ± 0.00121484 (W 5.31037e-05) | 0.016631 ± 0.000152306 (W 5.07464e-05) | 0.016841 ± 3.64737e-05 (W 6.38224e-05) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050133 ± 0.000966046 (W 0.00316877) | 0.060984 ± 0.00529016 (W 0.00134498) | 0.0483 ± 0.000226053 (W 0.000101657) | 🔵 fork 1.22× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.11297 ± 0.000110666 (W 0.00155189) | 0.11325 ± 0.000722615 (W 0.000185284) | 0.105647 ± 4.39356e-05 (W 0.00023642) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.503287 ± 0.00104485 (W 0.00216717) | 0.506974 ± 0.00799749 (W 0.00397808) | 0.273078 ± 0.00101307 (W 0.00159765) | · | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.22388 ± 0.0266047 (W 0.0125964) | 1.21825 ± 0.0114154 (W 0.0135521) | 0.594037 ± 0.000378789 (W 0.00209831) | · | 🔴 fork 2.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011781 ± 0.000221249 (W 5.54094e-05) | 0.01092 ± 0.000176163 (W 0.000118567) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.050995 ± 0.000147986 (W 0.000187607) | 0.047398 ± 0.000616934 (W 0.000168482) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144449 ± 0.000786448 (W 0.00200507) | 0.13429 ± 0.000186815 (W 0.00225317) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008165 ± 6.16468e-05 (W 4.342e-05) | 0.008356 ± 5.00033e-05 (W 8.33565e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008275 ± 6.80686e-05 (W 6.13457e-05) | 0.008446 ± 0.000110151 (W 5.12835e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.036598 ± 0.00101559 (W 0.00206667) | 0.024796 ± 0.000677268 (W 0.000817959) | - | 🔴 fork 1.48× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.037539 ± 0.00111399 (W 0.00145505) | 0.024776 ± 0.000584794 (W 0.000710601) | - | 🔴 fork 1.52× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.060613 ± 0.00017673 (W 0.000434259) | 0.050995 ± 0.000744716 (W 0.00114782) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.061014 ± 0.000678743 (W 0.00172617) | 0.050665 ± 0.00127421 (W 0.00165984) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008525 ± 0.000298235 (W 6.58027e-05) | 0.007423 ± 0.000172917 (W 3.34843e-05) | 0.012193 ± 6.1101e-05 (W 5.87393e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030697 ± 0.000342667 (W 0.000154066) | 0.045345 ± 0.0031209 (W 0.00207939) | 0.042879 ± 0.000193202 (W 0.000118035) | 🔵 fork 1.48× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.075631 ± 0.000339565 (W 0.00146179) | 0.102271 ± 0.001611 (W 0.00816398) | 0.093645 ± 0.00117991 (W 0.00275788) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.032901 ± 0.000223578 (W 0.000172166) | 0.100637 ± 0.00626181 (W 0.00772778) | 0.026389 ± 0.0336503 (W 0.000128957) | 🔵 fork 3.06× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.17225 ± 0.00136504 (W 0.00236174) | 0.48826 ± 0.0047497 (W 0.0150242) | 0.146493 ± 0.000751493 (W 0.00153505) | 🔵 fork 2.83× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.381932 ± 0.00493218 (W 0.0139309) | 1.0329 ± 0.00184634 (W 0.024489) | 0.332961 ± 0.00253075 (W 0.0025933) | 🔵 fork 2.70× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.024165 ± 0.000165198 (W 0.000140496) | 0.092372 ± 0.00209772 (W 0.00435105) | 0.014186 ± 0.0001155 (W 5.36656e-05) | 🔵 fork 3.82× faster than `faer-upstream` | 🔴 fork 1.70× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.137015 ± 0.00829089 (W 0.00144673) | 0.471739 ± 0.0208124 (W 0.00779562) | 0.300058 ± 0.135181 (W 0.00179888) | 🔵 fork 3.44× faster than `faer-upstream` | 🔵 fork 2.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.29486 ± 0.0211593 (W 0.00763934) | 0.978342 ± 0.0067593 (W 0.0150193) | 0.942936 ± 0.00111576 (W 0.00080521) | 🔵 fork 3.32× faster than `faer-upstream` | 🔵 fork 3.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.009488 ± 0.000104403 (W 6.76018e-05) | 0.008166 ± 6.68356e-05 (W 4.48576e-05) | 0.012804 ± 5.03322e-05 (W 6.26099e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0318 ± 0.000565209 (W 0.000122145) | 0.046016 ± 0.00115251 (W 0.0031743) | 0.043662 ± 0.000207983 (W 0.000138374) | 🔵 fork 1.45× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077595 ± 0.000498036 (W 6.26762e-05) | 0.103864 ± 0.00516233 (W 0.00289548) | 0.087573 ± 0.000227156 (W 0.00110868) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.183792 ± 0.00023567 (W 0.00126473) | 0.182911 ± 0.000129526 (W 0.00112709) | 0.186438 ± 0.000405242 (W 0.00121058) | · | · |  |
| `svd_thin/n64/b1` | 0.950921 ± 0.00286018 (W 0.00481301) | 0.951061 ± 0.00221532 (W 0.00224881) | 0.670409 ± 0.00122877 (W 0.00323028) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.3194 ± 0.036898 (W 0.0155108) | 2.28395 ± 0.0433803 (W 0.0182735) | 1.41424 ± 0.0482846 (W 0.00398818) | · | 🔴 fork 1.64× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.141023 ± 0.00057642 (W 0.00124527) | 0.140562 ± 0.000727765 (W 0.00158579) | 0.06432 ± 0.0430095 (W 0.000172694) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.522273 ± 0.00359142 (W 0.00217816) | 0.516843 ± 0.00125902 (W 0.00191518) | 0.269031 ± 0.000266346 (W 0.00120038) | · | 🔴 fork 1.94× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18573 ± 0.00276213 (W 0.00218521) | 1.1842 ± 0.000632868 (W 0.00197293) | 0.606239 ± 0.000427809 (W 0.00211995) | · | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 1e-05 (W 1.9601e-05) | 0.000671 ± 1e-05 (W 1.47037e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001482 ± 2.62742e-05 (W 2.54951e-05) | 0.001473 ± 1.58219e-05 (W 1.31643e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002565 ± 4.6188e-05 (W 4.03733e-05) | 0.002564 ± 3.61985e-05 (W 3.08221e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003497 ± 0.000179519 (W 2.19591e-05) | 0.003437 ± 2.46374e-05 (W 2.65556e-05) | 0.004178 ± 6.245e-05 (W 4.50555e-05) | · | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.017102 ± 0.00123207 (W 3.56371e-05) | 0.016511 ± 0.00171268 (W 5.05895e-05) | 0.016892 ± 0.000175009 (W 6.29706e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.059861 ± 0.00227023 (W 0.00345377) | 0.073166 ± 0.00152186 (W 0.0022093) | 0.04844 ± 0.000101489 (W 0.000119788) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113681 ± 0.00060248 (W 0.000322841) | 0.113722 ± 0.000391767 (W 0.0020315) | 0.106458 ± 0.00025149 (W 0.00146576) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.508107 ± 0.00141387 (W 0.00305261) | 0.509248 ± 0.000874545 (W 0.00333753) | 0.263471 ± 0.00117447 (W 0.00159308) | · | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.26172 ± 0.0262629 (W 0.021902) | 1.23418 ± 0.0149703 (W 0.0212739) | 0.576183 ± 0.00209811 (W 0.00249387) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011652 ± 0.000284178 (W 0.000106322) | 0.01074 ± 0.000532423 (W 0.00014076) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051396 ± 0.000507528 (W 0.00168372) | 0.047198 ± 0.000239571 (W 0.000155404) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143768 ± 0.000681898 (W 0.00232325) | 0.133318 ± 0.00213077 (W 0.00160189) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008145 ± 3.27159e-05 (W 3.73938e-05) | 0.008376 ± 3.17857e-05 (W 8.31523e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008215 ± 3.46458e-05 (W 5.28413e-05) | 0.008375 ± 2.00083e-05 (W 9.76079e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.029475 ± 0.000475757 (W 0.00099154) | 0.02728 ± 0.00114652 (W 0.00353276) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.031419 ± 0.00113401 (W 0.00108381) | 0.028343 ± 0.000514251 (W 0.00168637) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.051796 ± 0.000381634 (W 0.00105733) | 0.064149 ± 0.000555871 (W 0.00162345) | - | 🔵 fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.051887 ± 0.00112279 (W 0.00108524) | 0.063639 ± 0.00279296 (W 0.00144886) | - | 🔵 fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.008677 ± 0.00012822 (W 3.51027e-05) | 0.007234 ± 0.000180602 (W 4.38178e-05) | 0.012263 ± 6.68356e-05 (W 9.44103e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031278 ± 0.000513852 (W 0.000174942) | 0.049783 ± 0.00245766 (W 0.00289247) | 0.04279 ± 0.000121655 (W 0.000165421) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.07552 ± 0.000445527 (W 0.00224933) | 0.115575 ± 0.00573407 (W 0.00519937) | 0.086101 ± 0.00326665 (W 0.000176146) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n32/b1` | 0.033001 ± 5.51392e-05 (W 0.000113425) | 0.145922 ± 0.000439436 (W 0.00325729) | 0.02643 ± 0.0335462 (W 0.000122365) | 🔵 fork 4.42× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.164185 ± 0.0143813 (W 0.00333077) | 0.690276 ± 0.0206294 (W 0.0150268) | 0.158966 ± 0.00109901 (W 0.00108125) | 🔵 fork 4.20× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.416897 ± 0.00941273 (W 0.0253215) | 1.44799 ± 0.0449264 (W 0.0280431) | 0.339904 ± 0.00726463 (W 0.00278664) | 🔵 fork 3.47× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023824 ± 3.60555e-05 (W 0.000167479) | 0.122037 ± 0.00480551 (W 0.00846388) | 0.014066 ± 3e-05 (W 5.89678e-05) | 🔵 fork 5.12× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.132727 ± 0.00896101 (W 0.00464857) | 0.635955 ± 0.0200897 (W 0.0142497) | 0.298396 ± 0.134062 (W 0.00171856) | 🔵 fork 4.79× faster than `faer-upstream` | 🔵 fork 2.25× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.320517 ± 0.00816653 (W 0.0144113) | 1.28326 ± 0.00671776 (W 0.0163729) | 0.93949 ± 0.00031749 (W 0.00102811) | 🔵 fork 4.00× faster than `faer-upstream` | 🔵 fork 2.93× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009528 ± 7.50555e-05 (W 8.24579e-05) | 0.008155 ± 0.000162543 (W 5.80517e-05) | 0.012724 ± 0.00010116 (W 5.17687e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031598 ± 0.000176922 (W 0.000128107) | 0.052328 ± 0.00329026 (W 0.00333785) | 0.043561 ± 0.000211732 (W 9.77405e-05) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077795 ± 0.00359854 (W 0.00177255) | 0.121296 ± 0.00832023 (W 0.00429131) | 0.085339 ± 0.000353016 (W 0.000183244) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.183702 ± 0.00029896 (W 0.0051585) | 0.183922 ± 0.000874451 (W 0.00274087) | 0.186728 ± 0.000386011 (W 0.0013584) | · | · |  |
| `svd_thin/n64/b1` | 0.967953 ± 0.00478168 (W 0.00111101) | 0.964587 ± 0.00166036 (W 0.00470871) | 0.664027 ± 0.00366273 (W 0.00493873) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.29239 ± 0.0445363 (W 0.0245645) | 2.33339 ± 0.0412619 (W 0.0127331) | 1.3589 ± 0.0509403 (W 0.00510032) | · | 🔴 fork 1.69× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140862 ± 0.000552501 (W 0.000182006) | 0.140792 ± 0.000175728 (W 0.00167545) | 0.064179 ± 0.0429976 (W 0.000524765) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.52071 ± 0.00449701 (W 0.00197317) | 0.519428 ± 0.00345113 (W 0.00218612) | 0.271135 ± 0.00085981 (W 0.00135111) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18851 ± 0.000710589 (W 0.0024861) | 1.18319 ± 0.00168799 (W 0.00179558) | 0.599847 ± 0.000699732 (W 0.00237476) | · | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 6.08276e-06 (W 1.7782e-05) | 0.000671 ± 6.35085e-06 (W 1.69204e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001483 ± 5.68624e-05 (W 1.81989e-05) | 0.001463 ± 3.78594e-05 (W 1.88733e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002675 ± 6.48614e-05 (W 3.5344e-05) | 0.002635 ± 6.02771e-05 (W 3.27109e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003145 ± 0.000165554 (W 1.62542e-05) | 0.003336 ± 3.05505e-05 (W 2.20499e-05) | 0.003366 ± 1.52753e-05 (W 3.36482e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014898 ± 0.00121158 (W 5.72556e-05) | 0.016351 ± 0.0020179 (W 2.94822e-05) | 0.013956 ± 0.000216888 (W 6.79279e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050133 ± 0.0020098 (W 0.0021875) | 0.060393 ± 0.00129293 (W 0.00192353) | 0.038061 ± 0.000469696 (W 0.000170474) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113201 ± 0.000583824 (W 0.00199136) | 0.11274 ± 0.000316013 (W 0.00319269) | 0.103472 ± 0.000216842 (W 0.000318552) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.506213 ± 0.00423345 (W 0.00341126) | 0.503247 ± 0.00272249 (W 0.00289359) | 0.265154 ± 0.00199731 (W 0.00181978) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.22053 ± 0.00494294 (W 0.0175383) | 1.22155 ± 0.00465118 (W 0.0191838) | 0.580331 ± 0.00198254 (W 0.00222292) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010519 ± 6.05833e-05 (W 2.83408e-05) | 0.01065 ± 0.000145029 (W 0.000106838) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046146 ± 8.0829e-05 (W 0.00123913) | 0.046377 ± 0.000482743 (W 0.000155722) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131675 ± 7.81025e-05 (W 0.00241978) | 0.132687 ± 0.000411 (W 0.00236338) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008195 ± 5.19615e-05 (W 3.16228e-05) | 0.008395 ± 4.74377e-05 (W 7.35133e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008205 ± 4.04145e-05 (W 3.04187e-05) | 0.008566 ± 5.03322e-05 (W 0.000118508) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.034865 ± 0.00310086 (W 0.00291948) | 0.024215 ± 0.000435811 (W 0.000877833) | - | 🔴 fork 1.44× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.034494 ± 0.00331646 (W 0.00307044) | 0.024366 ± 0.000119528 (W 0.000550153) | - | 🔴 fork 1.42× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.059801 ± 0.000721052 (W 0.00303573) | 0.050264 ± 0.000463854 (W 0.00159743) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060693 ± 0.000540778 (W 0.00370633) | 0.051165 ± 0.00159159 (W 0.00190423) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007153 ± 0.000125819 (W 0.000121009) | 0.007063 ± 8.0829e-05 (W 0.000120092) | 0.009678 ± 5.2915e-05 (W 6.26099e-05) | · | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025518 ± 0.000328863 (W 0.000149265) | 0.04275 ± 0.00363711 (W 0.00291208) | 0.033643 ± 4.56107e-05 (W 0.000176242) | 🔵 fork 1.68× faster than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.063779 ± 0.000403436 (W 0.00224411) | 0.099436 ± 0.00327263 (W 0.00277104) | 0.074589 ± 8.88819e-05 (W 0.000175942) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031269 ± 0.000221518 (W 0.000141881) | 0.110956 ± 0.00201212 (W 0.00512224) | 0.021229 ± 0.000130128 (W 0.000118183) | 🔵 fork 3.55× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.148587 ± 0.00326143 (W 0.00238993) | 0.487097 ± 0.00561996 (W 0.0144762) | 0.127358 ± 0.000580587 (W 0.00204765) | 🔵 fork 3.28× faster than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.372153 ± 0.0158691 (W 0.0257756) | 1.03984 ± 0.0234077 (W 0.0176166) | 0.294318 ± 0.00130155 (W 0.00193907) | 🔵 fork 2.79× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017623 ± 0.000150997 (W 8.87694e-05) | 0.082714 ± 0.0014158 (W 0.00391064) | 0.011511 ± 5.05008e-05 (W 4.66926e-05) | 🔵 fork 4.69× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.099515 ± 0.00954597 (W 0.00791077) | 0.408371 ± 0.0203257 (W 0.0188337) | 0.2899 ± 0.000290443 (W 0.00170869) | 🔵 fork 4.10× faster than `faer-upstream` | 🔵 fork 2.91× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.194062 ± 0.011769 (W 0.00484386) | 0.874408 ± 0.00799429 (W 0.0402606) | 0.930553 ± 0.000527972 (W 0.000496401) | 🔵 fork 4.51× faster than `faer-upstream` | 🔵 fork 4.80× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007695 ± 9.78621e-05 (W 3.50043e-05) | 0.007824 ± 8.01686e-05 (W 3.19421e-05) | 0.009818 ± 6.86319e-05 (W 5.04599e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026028 ± 0.000475507 (W 8.83816e-05) | 0.045034 ± 0.00235664 (W 0.00329759) | 0.033612 ± 0.000207753 (W 0.000122496) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065902 ± 0.000660977 (W 0.00251308) | 0.103242 ± 0.00217139 (W 0.00353427) | 0.073697 ± 0.000267208 (W 9.9686e-05) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.185426 ± 0.00050327 (W 0.00157975) | 0.184394 ± 0.00130388 (W 0.00144604) | 0.175817 ± 0.000228802 (W 0.0017078) | · | 🔴 fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.994733 ± 0.00359823 (W 0.00167012) | 0.994602 ± 0.0120435 (W 0.00363726) | 0.640463 ± 0.0015915 (W 0.0016656) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32195 ± 0.0413458 (W 0.0285953) | 2.29991 ± 0.0396477 (W 0.0201343) | 1.38047 ± 0.000322249 (W 0.00262592) | · | 🔴 fork 1.68× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142886 ± 0.000640082 (W 0.00133162) | 0.142315 ± 0.000877374 (W 0.00133566) | 0.0591 ± 0.000233582 (W 5.76134e-05) | · | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.541318 ± 0.00216623 (W 0.00242009) | 0.539194 ± 0.00129095 (W 0.00188877) | 0.258621 ± 0.00100566 (W 0.000987649) | · | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19048 ± 0.00327635 (W 0.00291078) | 1.19274 ± 0.00226208 (W 0.002897) | 0.605547 ± 0.00193703 (W 0.0021341) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000762 ± 3.00056e-05 (W 2.41516e-05) | 0.000762 ± 2.04206e-05 (W 1.33154e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001823 ± 8.14453e-05 (W 1.64317e-05) | 0.001773 ± 4.16333e-05 (W 1.81466e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003046 ± 0.000150334 (W 3.11448e-05) | 0.002855 ± 0.000133742 (W 2.75717e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003106 ± 0.000179845 (W 2.30695e-05) | 0.003306 ± 0.000115902 (W 1.78382e-05) | 0.003346 ± 3.21455e-05 (W 2.57934e-05) | · | 🔵 fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016851 ± 0.0012294 (W 2.93292e-05) | 0.016281 ± 0.00186616 (W 3.89397e-05) | 0.014056 ± 0.00011628 (W 6.57898e-05) | · | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.054582 ± 0.00300527 (W 0.00238636) | 0.072014 ± 0.00088268 (W 0.00157647) | 0.038261 ± 0.00024325 (W 0.000126491) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113491 ± 0.000260832 (W 0.000296804) | 0.113141 ± 0.000263319 (W 0.00158529) | 0.104685 ± 1.52753e-05 (W 0.00124417) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.511953 ± 0.000483171 (W 0.00288218) | 0.508106 ± 0.00252501 (W 0.00340423) | 0.256778 ± 0.000717825 (W 0.00156222) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.25313 ± 0.0176037 (W 0.0178236) | 1.24007 ± 0.00640722 (W 0.0101685) | 0.565494 ± 0.00286112 (W 0.00205242) | · | 🔴 fork 2.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010429 ± 2.51661e-05 (W 4.59489e-05) | 0.010529 ± 0.00010208 (W 6.57062e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046196 ± 0.000176163 (W 0.000122732) | 0.046116 ± 1.1547e-05 (W 0.000238318) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131305 ± 0.00171486 (W 0.00236927) | 0.132456 ± 0.00399795 (W 0.00210265) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008175 ± 1.1547e-05 (W 5.66675e-05) | 0.008376 ± 1.21244e-05 (W 5.29179e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008245 ± 3.09892e-05 (W 1.64985e-05) | 0.008466 ± 1.58219e-05 (W 4.9952e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.029044 ± 0.00745683 (W 0.00154481) | 0.028243 ± 0.00043612 (W 0.0015079) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.028293 ± 0.000442505 (W 0.000885865) | 0.027942 ± 0.000396915 (W 0.00139984) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.043871 ± 0.0037926 (W 0.00499612) | 0.062326 ± 0.00113135 (W 0.00304354) | - | 🔵 fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.047549 ± 0.00326162 (W 0.0046882) | 0.062877 ± 0.00197131 (W 0.00237231) | - | 🔵 fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007323 ± 2.66521e-05 (W 9.39149e-05) | 0.007094 ± 5.55908e-05 (W 4.96991e-05) | 0.009709 ± 0.000107193 (W 5.18479e-05) | · | 🔵 fork 1.33× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026169 ± 0.000269669 (W 0.000157468) | 0.052709 ± 0.00322655 (W 0.00330117) | 0.033672 ± 0.000115803 (W 0.000100126) | 🔵 fork 2.01× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063458 ± 0.00254597 (W 0.00166899) | 0.119362 ± 0.013057 (W 0.00651822) | 0.074338 ± 0.000214337 (W 0.00013259) | 🔵 fork 1.88× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031138 ± 0.000273582 (W 0.000194616) | 0.146293 ± 0.00273571 (W 0.00380626) | 0.021129 ± 0.00013027 (W 7.14297e-05) | 🔵 fork 4.70× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.149368 ± 0.00362908 (W 0.00715723) | 0.662544 ± 0.0121996 (W 0.00984465) | 0.13977 ± 0.000276533 (W 0.00148235) | 🔵 fork 4.44× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.403472 ± 0.0197459 (W 0.0159197) | 1.45408 ± 0.0354445 (W 0.0372773) | 0.30575 ± 0.00124373 (W 0.00280301) | 🔵 fork 3.60× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017643 ± 7.50555e-05 (W 6.85507e-05) | 0.113531 ± 0.00351033 (W 0.00404429) | 0.011511 ± 5.63057e-05 (W 5.69315e-05) | 🔵 fork 6.43× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.092763 ± 0.000955951 (W 0.00129068) | 0.597934 ± 0.00488412 (W 0.0141744) | 0.290711 ± 0.000580262 (W 0.00192857) | 🔵 fork 6.45× faster than `faer-upstream` | 🔵 fork 3.13× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.204621 ± 0.0111147 (W 0.00960425) | 1.16503 ± 0.0077036 (W 0.0195554) | 0.930704 ± 0.000589402 (W 0.00157171) | 🔵 fork 5.69× faster than `faer-upstream` | 🔵 fork 4.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007795 ± 1.21244e-05 (W 6.95507e-05) | 0.007815 ± 7.76745e-05 (W 6.25004e-05) | 0.009818 ± 5.7735e-07 (W 3.19719e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025818 ± 0.00028564 (W 7.2383e-05) | 0.052979 ± 0.00132184 (W 0.00244539) | 0.033562 ± 0.000150622 (W 9.80015e-05) | 🔵 fork 2.05× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065362 ± 0.00420615 (W 0.000133612) | 0.117519 ± 0.0373185 (W 0.00845773) | 0.073407 ± 0.000135769 (W 9.2651e-05) | 🔵 fork 1.80× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.185806 ± 0.000231042 (W 0.0032025) | 0.185996 ± 0.000400163 (W 0.00612707) | 0.17714 ± 0.000256368 (W 0.00198544) | · | · |  |
| `svd_thin/n64/b1` | 1.01341 ± 0.00480455 (W 0.00411237) | 1.01172 ± 0.00739675 (W 0.00499743) | 0.633229 ± 0.00328051 (W 0.00340832) | · | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.30325 ± 0.0325331 (W 0.0123286) | 2.3135 ± 0.0392423 (W 0.014159) | 1.32702 ± 0.00185483 (W 0.00230596) | · | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142415 ± 0.000562189 (W 0.00148418) | 0.142135 ± 0.000160936 (W 0.00158644) | 0.059101 ± 0.00022581 (W 0.000121148) | · | 🔴 fork 2.41× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.543432 ± 0.00217574 (W 0.00252236) | 0.540486 ± 0.00352524 (W 0.00116577) | 0.258501 ± 0.00041244 (W 0.00184825) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.19412 ± 0.00203739 (W 0.00294578) | 1.19043 ± 0.00297127 (W 0.00151337) | 0.599226 ± 0.000305341 (W 0.00196579) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000781 ± 1.47309e-05 (W 1.62265e-05) | 0.000761 ± 1.58219e-05 (W 1.7672e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001894 ± 0.000297725 (W 2.39646e-05) | 0.001813 ± 6.95725e-05 (W 1.63493e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003096 ± 0.000118462 (W 2.57546e-05) | 0.002926 ± 0.000101474 (W 3.55711e-05) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005169 ± 6.12127e-05 (W 3.58636e-05) | 0.00529 ± 6.80686e-05 (W 3.95247e-05) | 0.008877 ± 9.84395e-05 (W 4.30116e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030277 ± 0.000426345 (W 0.000147737) | 0.030226 ± 9.0185e-05 (W 7.83913e-05) | 0.051135 ± 0.000391383 (W 0.000269862) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.104806 ± 0.000471934 (W 0.00108065) | 0.105196 ± 0.000657521 (W 0.00108722) | 0.138348 ± 0.00105824 (W 0.00116058) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142145 ± 0.000452726 (W 0.0011591) | 0.142085 ± 0.000666798 (W 0.00150891) | 0.156321 ± 0.000210587 (W 0.00138485) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.639561 ± 0.00233446 (W 0.00275935) | 0.638379 ± 0.0160925 (W 0.01867) | 0.566946 ± 0.000611992 (W 0.00159165) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54463 ± 0.00462151 (W 0.0120593) | 1.54313 ± 0.00762479 (W 0.0120246) | 1.1597 ± 0.0012544 (W 0.00278181) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017683 ± 6.65833e-05 (W 7.04982e-05) | 0.015899 ± 0.000181907 (W 6.9601e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097151 ± 0.000195244 (W 0.00145617) | 0.092292 ± 0.000468657 (W 0.000593712) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.278879 ± 0.000823124 (W 0.0018575) | 0.265755 ± 0.00132572 (W 0.00180983) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028033 ± 7.68136e-05 (W 5.13644e-05) | 0.028373 ± 0.000166694 (W 7.85443e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028002 ± 7.42765e-05 (W 0.000119708) | 0.028453 ± 0.000157735 (W 0.000111334) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.071413 ± 0.000584388 (W 0.00173111) | 0.069479 ± 0.00151595 (W 0.00163252) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.071292 ± 0.00455793 (W 0.000576671) | 0.06962 ± 0.000552009 (W 0.00389118) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.165047 ± 0.00234556 (W 0.00274207) | 0.15549 ± 0.000265142 (W 0.00165281) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.167111 ± 0.000769096 (W 0.00398056) | 0.15595 ± 0.000684126 (W 0.00146317) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013094 ± 0.000233432 (W 0.000182618) | 0.01122 ± 0.000138276 (W 7.49153e-05) | 0.019867 ± 2.88675e-05 (W 0.000145705) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057498 ± 0.000170998 (W 0.000178453) | 0.052688 ± 0.000275953 (W 0.000184573) | 0.095989 ± 0.000400505 (W 0.00118846) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.150561 ± 0.000353036 (W 0.000237868) | 0.154247 ± 0.00137475 (W 0.00165407) | 0.243724 ± 1e-05 (W 0.00159381) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070852 ± 0.000554354 (W 0.000256204) | 0.15597 ± 0.0184204 (W 0.0198101) | 0.05365 ± 0.0899165 (W 0.00107048) | 🔵 fork 2.20× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.299748 ± 0.0122918 (W 0.00597404) | 0.654729 ± 0.00740163 (W 0.00787921) | 0.306731 ± 3.05505e-05 (W 0.0014388) | 🔵 fork 2.18× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr/n96/b1` | 0.697099 ± 0.0128835 (W 0.00502324) | 1.3707 ± 0.0459679 (W 0.0191931) | 0.769874 ± 0.000858598 (W 0.00162313) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.041177 ± 0.000406409 (W 0.00167139) | 0.106799 ± 0.00137894 (W 0.00320998) | 0.028853 ± 0.000144627 (W 7.80404e-05) | 🔵 fork 2.59× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.222434 ± 0.00691959 (W 0.00248449) | 0.619113 ± 0.00605909 (W 0.0175017) | 0.761999 ± 0.346005 (W 0.00109504) | 🔵 fork 2.78× faster than `faer-upstream` | 🔵 fork 3.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.420212 ± 0.00610647 (W 0.00402647) | 1.16845 ± 0.00438333 (W 0.013626) | 2.45781 ± 0.002715 (W 0.00191592) | 🔵 fork 2.78× faster than `faer-upstream` | 🔵 fork 5.85× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014347 ± 0.000133167 (W 6.73053e-05) | 0.012504 ± 0.000140631 (W 6.26897e-05) | 0.020318 ± 6e-05 (W 7.51545e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060393 ± 0.000829516 (W 0.000148658) | 0.054732 ± 0.000828711 (W 0.000140798) | 0.093164 ± 0.00046756 (W 0.00121554) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.154508 ± 0.000555231 (W 0.00152882) | 0.157283 ± 0.00128345 (W 0.00215254) | 0.236851 ± 0.000343114 (W 0.0016393) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.23644 ± 0.00152609 (W 0.00193155) | 0.235218 ± 0.000331326 (W 0.00225948) | 0.261157 ± 0.000600223 (W 0.00180224) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20016 ± 0.00820678 (W 0.00307655) | 1.20078 ± 0.00217625 (W 0.00407081) | 1.03154 ± 0.00130196 (W 0.00407327) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.99914 ± 0.0142044 (W 0.0167781) | 3.00035 ± 0.0209547 (W 0.0438383) | 2.52996 ± 0.0056081 (W 0.00526743) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.16094 ± 0.000187511 (W 0.00186541) | 0.161651 ± 8.20183e-05 (W 0.00165536) | 0.10217 ± 0.122699 (W 0.000124371) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.652124 ± 0.000787467 (W 0.00245888) | 0.650692 ± 0.00253596 (W 0.00170225) | 0.489913 ± 0.000216419 (W 0.00154351) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51278 ± 0.00390267 (W 0.00220276) | 1.50558 ± 0.00614361 (W 0.00255313) | 1.35901 ± 0.00173627 (W 0.00167059) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 5.7735e-06 (W 1.94936e-05) | 0.001062 ± 5.7735e-06 (W 2.07364e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002735 ± 4.16333e-05 (W 3.23296e-05) | 0.002695 ± 2.13776e-05 (W 2.48998e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004949 ± 5.2915e-05 (W 3.20936e-05) | 0.004909 ± 7.14866e-05 (W 2.5501e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00526 ± 5.61278e-05 (W 4.2145e-05) | 0.005299 ± 8.34286e-05 (W 4.94975e-05) | 0.008986 ± 0.000173811 (W 4.43847e-05) | · | 🔵 fork 1.71× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030246 ± 4.3589e-05 (W 6.96872e-05) | 0.030196 ± 0.000159312 (W 0.000114018) | 0.050594 ± 0.000210072 (W 0.000224593) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111899 ± 0.00047371 (W 0.00290499) | 0.111087 ± 0.000916276 (W 0.00228466) | 0.13964 ± 0.000187705 (W 0.00163259) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142065 ± 4.55741e-05 (W 0.00151193) | 0.142175 ± 0.000411101 (W 0.00151759) | 0.157183 ± 0.000761286 (W 0.00164797) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.650331 ± 0.00245628 (W 0.00392428) | 0.663486 ± 0.0082318 (W 0.0104877) | 0.543262 ± 0.000523043 (W 0.00275213) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54399 ± 0.00580413 (W 0.0101079) | 1.59781 ± 0.00912221 (W 0.0135202) | 1.04339 ± 0.0731549 (W 0.00204196) | · | 🔴 fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.017543 ± 0.000132288 (W 0.000142056) | 0.01599 ± 0.000125033 (W 0.000109248) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09668 ± 4.04145e-05 (W 0.000392585) | 0.092211 ± 0.000325556 (W 0.00180966) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.27882 ± 0.00109921 (W 0.00212884) | 0.267157 ± 0.000729543 (W 0.0022122) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027972 ± 0.000129152 (W 6.12062e-05) | 0.028483 ± 0.000305942 (W 0.000146404) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027892 ± 0.000124231 (W 8.67825e-05) | 0.028453 ± 4.04145e-05 (W 6.60545e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.052779 ± 0.00099594 (W 0.000645965) | 0.071102 ± 0.000853282 (W 0.0018317) | - | 🔵 fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.053139 ± 0.000806809 (W 0.00119453) | 0.070712 ± 0.000964448 (W 0.00474324) | - | 🔵 fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.106208 ± 0.000436143 (W 0.00459455) | 0.161651 ± 0.000316544 (W 0.000916843) | - | 🔵 fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.107059 ± 0.00021997 (W 0.00476221) | 0.162693 ± 0.000278845 (W 0.00210459) | - | 🔵 fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013255 ± 0.000172096 (W 0.00011736) | 0.01118 ± 0.000120652 (W 0.000105803) | 0.019777 ± 0.000138564 (W 7.12039e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.49× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057327 ± 0.000442934 (W 0.000262851) | 0.052578 ± 0.000169214 (W 0.000256666) | 0.095959 ± 0.000297698 (W 0.000377319) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.149959 ± 0.000371282 (W 0.00154141) | 0.164787 ± 0.00201101 (W 0.00197642) | 0.244004 ± 0.000718006 (W 0.00170157) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.0696 ± 4.72582e-05 (W 0.000352432) | 0.194402 ± 0.0112527 (W 0.00874774) | 0.053519 ± 0.089781 (W 8.59779e-05) | 🔵 fork 2.79× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.313524 ± 0.000997674 (W 0.00343892) | 0.871834 ± 0.0152333 (W 0.0304795) | 0.285171 ± 0.000444972 (W 0.00194162) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.62827 ± 0.00691178 (W 0.0134355) | 1.7267 ± 0.020474 (W 0.0396076) | 0.704011 ± 0.001004 (W 0.00151184) | 🔵 fork 2.75× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.040616 ± 9.34719e-05 (W 0.00018639) | 0.140041 ± 0.00229102 (W 0.00705161) | 0.028833 ± 0.000211346 (W 0.000143726) | 🔵 fork 3.45× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.22012 ± 0.00173395 (W 0.0024855) | 0.773681 ± 0.0103038 (W 0.0137056) | 0.762991 ± 0.346021 (W 0.00117625) | 🔵 fork 3.51× faster than `faer-upstream` | 🔵 fork 3.47× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.432275 ± 0.00400695 (W 0.00270991) | 1.53735 ± 0.00491656 (W 0.0432738) | 2.45543 ± 0.00217902 (W 0.0027562) | 🔵 fork 3.56× faster than `faer-upstream` | 🔵 fork 5.68× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014417 ± 7.50555e-05 (W 6.8775e-05) | 0.012473 ± 7.81025e-05 (W 5.44977e-05) | 0.020298 ± 4.58258e-05 (W 9.08295e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059831 ± 0.000454438 (W 0.000258929) | 0.054391 ± 0.000155907 (W 0.000211791) | 0.093495 ± 8.98907e-05 (W 0.00133423) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.153486 ± 0.000830627 (W 0.00177208) | 0.165658 ± 0.00170321 (W 0.00517424) | 0.23641 ± 0.00158963 (W 0.00208361) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.235729 ± 0.00142329 (W 0.00228326) | 0.236851 ± 0.0013501 (W 0.00197795) | 0.263651 ± 0.000366153 (W 0.00178345) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21401 ± 0.00334064 (W 0.00366167) | 1.22321 ± 0.0051858 (W 0.00386386) | 0.99848 ± 0.0050003 (W 0.00217112) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.97126 ± 0.0010204 (W 0.0104185) | 3.0942 ± 0.0057077 (W 0.0186923) | 2.3526 ± 0.0010849 (W 0.00352707) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.16082 ± 0.000303167 (W 0.00145409) | 0.161912 ± 0.000512329 (W 0.00131238) | 0.102671 ± 0.121571 (W 0.00136307) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.650612 ± 0.00131744 (W 0.00198386) | 0.651222 ± 0.00153218 (W 0.00223649) | 0.491505 ± 0.00229772 (W 0.00219644) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50599 ± 0.00386249 (W 0.00203114) | 1.51001 ± 0.00296527 (W 0.00257758) | 1.3586 ± 0.00305412 (W 0.00164821) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 1.1547e-05 (W 8.94427e-06) | 0.001082 ± 0.000390321 (W 2.80393e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002665 ± 1.73205e-05 (W 2.16795e-05) | 0.002715 ± 1.1547e-05 (W 4.43847e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0049 ± 6.64605e-05 (W 2.47225e-05) | 0.004909 ± 1.1547e-05 (W 3.84708e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 0.000149923 (W 3.28634e-05) | 0.005259 ± 4.0501e-05 (W 2.88323e-05) | 0.007985 ± 0.000102632 (W 3.64692e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029896 ± 0.000291994 (W 5.04975e-05) | 0.030076 ± 0.000174443 (W 7.96637e-05) | 0.04325 ± 0.000232006 (W 0.000123958) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103994 ± 0.000968244 (W 0.00249316) | 0.103893 ± 0.00060071 (W 0.00179395) | 0.125464 ± 0.000589345 (W 0.00197997) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142916 ± 0.00084337 (W 0.00134236) | 0.142195 ± 0.000235139 (W 0.000314668) | 0.153867 ± 4.07063e-05 (W 0.000295082) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.639471 ± 0.00537488 (W 0.00565049) | 0.642276 ± 0.000668716 (W 0.00340282) | 0.555544 ± 0.000587011 (W 0.00196299) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54278 ± 0.0107751 (W 0.00996905) | 1.55951 ± 0.0107524 (W 0.00969598) | 1.1433 ± 0.000394318 (W 0.00234535) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015919 ± 7.60723e-05 (W 0.000108043) | 0.015889 ± 0.00012546 (W 8.67364e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090158 ± 0.000353412 (W 0.000371901) | 0.090158 ± 0.000147309 (W 0.000173963) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264653 ± 0.000415172 (W 0.0014376) | 0.264773 ± 0.000181934 (W 0.00197296) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027882 ± 5.19615e-05 (W 6.19613e-05) | 0.028183 ± 0.000101474 (W 9.48857e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027992 ± 4.16333e-05 (W 6.30016e-05) | 0.028123 ± 0.000220878 (W 0.000114801) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.06952 ± 0.00408512 (W 0.00138061) | 0.068268 ± 0.00125213 (W 0.00202608) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.072385 ± 0.00317251 (W 0.00340161) | 0.06965 ± 0.00145792 (W 0.00188269) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.164666 ± 0.00168919 (W 0.00364648) | 0.154578 ± 0.00112037 (W 0.00164157) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.162392 ± 0.00341303 (W 0.00309679) | 0.154157 ± 0.000503549 (W 0.00197597) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011392 ± 7.54343e-05 (W 9.41876e-05) | 0.011261 ± 9.34719e-05 (W 8.92749e-05) | 0.017573 ± 0.000993501 (W 7.04982e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051335 ± 7.50555e-05 (W 0.000276136) | 0.051386 ± 0.00024966 (W 0.00150633) | 0.085509 ± 0.000325515 (W 0.000289699) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136414 ± 8.13654e-05 (W 0.00145593) | 0.15008 ± 0.00432054 (W 0.00127315) | 0.224899 ± 0.000739452 (W 0.00228985) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.068197 ± 0.000505065 (W 0.000427308) | 0.159857 ± 0.0174717 (W 0.0200471) | 0.048019 ± 0.000193443 (W 9.44987e-05) | 🔵 fork 2.34× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.299097 ± 0.0012492 (W 0.00577381) | 0.647936 ± 0.0096489 (W 0.0122149) | 0.288427 ± 0.0012807 (W 0.00167048) | 🔵 fork 2.17× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.678113 ± 0.0665783 (W 0.00450924) | 1.3583 ± 0.0591876 (W 0.0103025) | 0.73545 ± 0.000986678 (W 0.00183241) | 🔵 fork 2.00× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033783 ± 0.000451801 (W 0.000255295) | 0.093584 ± 0.0031494 (W 0.00456411) | 0.026109 ± 6.15386e-05 (W 7.3371e-05) | 🔵 fork 2.77× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.157643 ± 0.00134765 (W 0.00336237) | 0.505451 ± 0.00616631 (W 0.0160739) | 0.756799 ± 0.000309462 (W 0.0018715) | 🔵 fork 3.21× faster than `faer-upstream` | 🔵 fork 4.80× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.337869 ± 0.00489013 (W 0.00570362) | 1.00398 ± 0.0150477 (W 0.00680713) | 2.44494 ± 0.00245 (W 0.00550492) | 🔵 fork 2.97× faster than `faer-upstream` | 🔵 fork 7.24× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012483 ± 3.21455e-05 (W 7.008e-05) | 0.012373 ± 0.000194251 (W 8.06802e-05) | 0.017263 ± 9.66454e-05 (W 4.72567e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052918 ± 5.08626e-05 (W 0.000149859) | 0.053109 ± 0.000217601 (W 0.000143154) | 0.082974 ± 0.000384275 (W 0.00164821) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.13955 ± 0.000289759 (W 0.00162139) | 0.153847 ± 0.000302804 (W 0.00151811) | 0.217996 ± 0.000422114 (W 0.00203585) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232473 ± 0.000889353 (W 0.00183307) | 0.232804 ± 0.000227172 (W 0.001877) | 0.25766 ± 0.000289425 (W 0.00169446) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23802 ± 0.00956809 (W 0.00291398) | 1.23561 ± 0.00962518 (W 0.00716899) | 1.01177 ± 0.000428798 (W 0.00119813) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.93599 ± 0.00257215 (W 0.0205409) | 2.9469 ± 0.0156594 (W 0.0157855) | 2.51154 ± 0.0112573 (W 0.00284982) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158475 ± 0.000231733 (W 0.000404412) | 0.159607 ± 0.000566487 (W 0.00112328) | 0.100477 ± 0.000149778 (W 0.00159628) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625365 ± 0.000688274 (W 0.00224634) | 0.626366 ± 0.00103896 (W 0.00187129) | 0.479413 ± 0.00213025 (W 0.00167333) | · | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48424 ± 0.00249254 (W 0.00199271) | 1.48226 ± 0.00350227 (W 0.00198459) | 1.33936 ± 0.00192286 (W 0.00228648) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001202 ± 2.70247e-05 (W 2.00075e-05) | 0.001183 ± 0.000198671 (W 1.10589e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002795 ± 0.00024327 (W 1.94936e-05) | 0.002815 ± 0.000274567 (W 2.99533e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004849 ± 0.000252963 (W 2.19089e-05) | 0.005039 ± 0.000211188 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005239 ± 5.1449e-05 (W 4.97222e-05) | 0.0053 ± 1.48436e-05 (W 4.16317e-05) | 0.007915 ± 0.000178298 (W 3.85655e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029876 ± 0.000105532 (W 5.94138e-05) | 0.029926 ± 7.63763e-05 (W 5.35724e-05) | 0.043211 ± 0.000342862 (W 0.000167389) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.110996 ± 0.00112695 (W 0.00279546) | 0.110526 ± 0.00241907 (W 0.00314397) | 0.125725 ± 0.000833693 (W 0.00150927) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142115 ± 0.000127986 (W 0.00158579) | 0.142205 ± 0.000786093 (W 0.00154167) | 0.154928 ± 0.00047278 (W 0.00160625) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.645272 ± 0.00504119 (W 0.00334196) | 0.645001 ± 0.0073434 (W 0.00285606) | 0.531931 ± 0.00145279 (W 0.00233427) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54744 ± 0.00238262 (W 0.0247212) | 1.58925 ± 0.00845776 (W 0.0221605) | 1.02725 ± 1.60756 (W 0.00290917) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.015999 ± 5.0797e-05 (W 0.000116156) | 0.015969 ± 0.00011845 (W 0.000149015) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090057 ± 0.000146186 (W 0.000226994) | 0.089988 ± 0.000226053 (W 0.000383321) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264663 ± 0.000877134 (W 0.00225287) | 0.263772 ± 0.000165198 (W 0.00129711) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027982 ± 9.34719e-05 (W 5.61249e-05) | 0.028112 ± 7.2111e-05 (W 0.000197847) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027962 ± 9.0185e-05 (W 4.219e-05) | 0.028152 ± 0.000104644 (W 8.20683e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.051085 ± 0.000218351 (W 0.00125081) | 0.072115 ± 0.00121708 (W 0.00349267) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.051546 ± 0.000464134 (W 0.0032003) | 0.072636 ± 0.000524856 (W 0.00148491) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.102431 ± 0.00209379 (W 0.00278911) | 0.160258 ± 9.13072e-05 (W 0.00193648) | - | 🔵 fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.106187 ± 0.0023695 (W 0.00414572) | 0.16115 ± 0.000271809 (W 0.00280194) | - | 🔵 fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011542 ± 8.07486e-05 (W 7.0273e-05) | 0.011231 ± 8.66622e-05 (W 0.000107583) | 0.017333 ± 0.000105642 (W 0.000109185) | · | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051045 ± 0.000274908 (W 0.000205614) | 0.050794 ± 0.000178298 (W 0.000158111) | 0.08541 ± 0.000147582 (W 0.00147423) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136414 ± 0.00030531 (W 0.00161507) | 0.162723 ± 0.000253246 (W 0.00214554) | 0.2251 ± 0.000342774 (W 0.00189935) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068187 ± 0.000112073 (W 0.0002705) | 0.184924 ± 0.00479991 (W 0.00738413) | 0.048229 ± 6.11583e-05 (W 0.000106256) | 🔵 fork 2.71× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.308815 ± 0.00268612 (W 0.00581915) | 0.871564 ± 0.00712365 (W 0.0195396) | 0.264212 ± 0.000567751 (W 0.00195293) | 🔵 fork 2.82× faster than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.624543 ± 0.0134569 (W 0.0183062) | 1.70919 ± 0.0314195 (W 0.0333638) | 0.67123 ± 0.00139754 (W 0.00193104) | 🔵 fork 2.74× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.033703 ± 0.000212211 (W 0.000142724) | 0.12856 ± 0.00175256 (W 0.0024245) | 0.026139 ± 1.18462e-05 (W 3.8304e-05) | 🔵 fork 3.81× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.166611 ± 0.000742794 (W 0.00393811) | 0.67084 ± 0.00988931 (W 0.00478561) | 0.757871 ± 0.00139329 (W 0.0019775) | 🔵 fork 4.03× faster than `faer-upstream` | 🔵 fork 4.55× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.356574 ± 0.0071182 (W 0.00675286) | 1.37031 ± 0.015509 (W 0.0230247) | 2.44465 ± 0.00275554 (W 0.00376644) | 🔵 fork 3.84× faster than `faer-upstream` | 🔵 fork 6.86× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012623 ± 7.55667e-05 (W 5.90703e-05) | 0.012403 ± 5.03322e-05 (W 5.86967e-05) | 0.017212 ± 3.60555e-05 (W 7.85493e-05) | · | 🔵 fork 1.36× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052919 ± 0.000164135 (W 0.000276552) | 0.052929 ± 0.000174738 (W 0.00196532) | 0.083515 ± 0.000491732 (W 9.98499e-05) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.13946 ± 0.000141774 (W 0.00155126) | 0.165498 ± 0.000346864 (W 0.00158323) | 0.218406 ± 0.00025552 (W 0.00134872) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.234406 ± 0.000564617 (W 0.00203551) | 0.233586 ± 0.00166817 (W 0.00185031) | 0.259313 ± 0.000786638 (W 0.00127541) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24627 ± 0.00606844 (W 0.00497532) | 1.25743 ± 0.00236516 (W 0.0105457) | 0.976309 ± 0.00137021 (W 0.00172553) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.91834 ± 0.0109857 (W 0.0221663) | 3.04536 ± 0.0112279 (W 0.0144765) | 2.33852 ± 0.00500225 (W 0.00246165) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158225 ± 0.000527811 (W 0.00161842) | 0.160259 ± 0.000568596 (W 0.00147132) | 0.100747 ± 0.000535501 (W 0.000175913) | · | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.625175 ± 0.00236279 (W 0.00179577) | 0.626497 ± 0.00274994 (W 0.00178911) | 0.480715 ± 0.00139486 (W 0.00179548) | · | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.47563 ± 0.00519466 (W 0.00244575) | 1.47839 ± 0.00168119 (W 0.00152581) | 1.33927 ± 0.00396844 (W 0.0022849) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001192 ± 3.05505e-05 (W 2.30911e-05) | 0.001242 ± 2.3388e-05 (W 2.36685e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003005 ± 0.000121985 (W 2.2698e-05) | 0.002796 ± 0.000109986 (W 3.06301e-05) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004749 ± 0.000454402 (W 1.58114e-05) | 0.004789 ± 0.000259866 (W 2.44949e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
