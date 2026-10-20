# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `46de43cdecccb033994ca509091c51bcdcb0cd60`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `6e2afddbaf8e59006f66257641a4928ecb8c1569`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `b9405106261a9f0eea3ce7e42033e9262334fc008574ae55d64fec40efddb2c9`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T16:54:25.405725Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small --threads 4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label cand-rm-floor-r2 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261019T164349Z-cand-rm-floor-r2/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.20%, worst 293.18% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 109 of 768 engine cells exceed 5% and carry `!`; median within-process relative SD 0.79%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `cholesky/n32/b1` | 0.003517 ± 0.00016547 (W 2.19591e-05) | 0.003367 ± 3.76431e-05 (W 2.21427e-05) | 0.004128 ± 3.4641e-05 (W 4.97996e-05) | · | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016912 ± 0.00103136 (W 4.05746e-05) | 0.016672 ± 0.000288185 (W 4.51907e-05) | 0.016821 ± 0.000140571 (W 6.52702e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.052047 ± 0.00164105 (W 0.00267153) | 0.062128 ± 0.00342013 (W 0.00153677) | 0.048482 ± 9.33881e-05 (W 0.000148511) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113812 ± 0.000205672 (W 0.000204293) | 0.113365 ± 0.000429088 (W 0.00157033) | 0.105547 ± 0.000490389 (W 0.00140543) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.504039 ± 0.00313443 (W 0.00309973) | 0.51055 ± 0.00739426 (W 0.00435316) | 0.272707 ± 0.00102933 (W 0.00136191) | · | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.22087 ± 0.0050209 (W 0.0188541) | 1.24026 ± 0.0157177 (W 0.0230669) | 0.593115 ± 0.00153205 (W 0.00218226) | · | 🔴 fork 2.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011641 ± 4.50592e-05 (W 4.65747e-05) | 0.01086 ± 0.000310624 (W 0.000228715) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051015 ± 0.000147314 (W 0.00138806) | 0.046908 ± 7.19328e-05 (W 0.000119951) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144439 ± 0.00103234 (W 0.00237198) | 0.133243 ± 0.00069798 (W 0.00229105) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008105 ± 1.52753e-05 (W 7.45735e-05) | 0.008355 ± 3.50761e-05 (W 6.07314e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008195 ± 3.4641e-05 (W 3.09887e-05) | 0.008406 ± 3e-05 (W 6.15321e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.035127 ± 0.00360403 (W 0.003295) | 0.023944 ± 0.000202981 (W 0.000407894) | - | 🔴 fork 1.47× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.037059 ± 0.00047892 (W 0.000668028) | 0.024967 ± 0.000241622 (W 0.000397176) | - | 🔴 fork 1.48× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.060613 ± 0.000796518 (W 0.00388317) | 0.050424 ± 0.000170317 (W 0.00101489) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060523 ± 0.000274714 (W 0.00161289) | 0.051026 ± 0.000477548 (W 0.00100924) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008706 ± 0.000158767 (W 4.24264e-05) | 0.007294 ± 5.87963e-05 (W 0.000175132) | 0.012302 ± 6.95054e-05 (W 7.6657e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030948 ± 0.000197714 (W 0.00020675) | 0.044354 ± 0.00252276 (W 0.0018217) | 0.04277 ± 0.000173644 (W 0.000214339) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.075825 ± 0.000230899 (W 0.000397439) | 0.102906 ± 0.00106817 (W 0.00441804) | 0.093795 ± 0.000261587 (W 0.00310407) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.03265 ± 0.000139861 (W 0.000155722) | 0.111287 ± 0.00213388 (W 0.00410409) | 0.026519 ± 0.033609 (W 0.000199726) | 🔵 fork 3.41× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.170708 ± 0.0126886 (W 0.00204743) | 0.489632 ± 0.0102551 (W 0.0135872) | 0.146042 ± 0.000383112 (W 0.00179781) | 🔵 fork 2.87× faster than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.384015 ± 0.00740745 (W 0.0118744) | 1.05877 ± 0.0100858 (W 0.0153408) | 0.33182 ± 0.00215361 (W 0.00394335) | 🔵 fork 2.76× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023804 ± 0.000156721 (W 9.41557e-05) | 0.092125 ± 0.00360346 (W 0.0046214) | 0.014136 ± 6.65833e-05 (W 4.35798e-05) | 🔵 fork 3.87× faster than `faer-upstream` | 🔴 fork 1.68× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.13675 ± 0.00954254 (W 0.00208884) | 0.469595 ± 0.0130279 (W 0.0184567) | 0.299077 ± 0.134133 (W 0.0020869) | 🔵 fork 3.43× faster than `faer-upstream` | 🔵 fork 2.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.274612 ± 0.0164616 (W 0.00727377) | 0.984353 ± 0.0127376 (W 0.0156737) | 0.942445 ± 0.000509715 (W 0.000609964) | 🔵 fork 3.58× faster than `faer-upstream` | 🔵 fork 3.43× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009628 ± 0.000112073 (W 6.42977e-05) | 0.008285 ± 0.000271271 (W 4.10159e-05) | 0.012794 ± 0.00011632 (W 5.07661e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031779 ± 0.000351552 (W 6.53452e-05) | 0.045054 ± 0.00114373 (W 0.00249634) | 0.043862 ± 0.000147075 (W 0.000114106) | 🔵 fork 1.42× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077575 ± 0.000511586 (W 0.00243944) | 0.102625 ± 0.00847621 (W 0.00498962) | 0.087553 ± 0.000271684 (W 0.000273131) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.183419 ± 0.0002557 (W 0.00142897) | 0.183251 ± 0.000649994 (W 0.0014975) | 0.185275 ± 0.000537132 (W 0.000526458) | · | · |  |
| `svd_thin/n64/b1` | 0.955105 ± 0.00491477 (W 0.00309354) | 0.952474 ± 0.00381254 (W 0.00347211) | 0.672342 ± 0.00657885 (W 0.00350358) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.3244 ± 0.041477 (W 0.0156787) | 2.27945 ± 0.047623 (W 0.0208795) | 1.40973 ± 0.0502656 (W 0.00485079) | · | 🔴 fork 1.65× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140713 ± 0.000122992 (W 0.00148166) | 0.140171 ± 0.000392123 (W 0.000148349) | 0.06439 ± 0.0430211 (W 0.0013449) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.518767 ± 0.00137368 (W 0.0023535) | 0.519077 ± 0.00229171 (W 0.0016814) | 0.270474 ± 0.00182569 (W 0.00166792) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18786 ± 0.00141317 (W 0.0019756) | 1.18524 ± 0.00769993 (W 0.00307829) | 0.604278 ± 0.000928178 (W 0.00202626) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000661 ± 6.35085e-06 (W 1.67093e-05) | 0.000671 ± 1.52753e-05 (W 1.30843e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001483 ± 1.52753e-05 (W 2.60768e-05) | 0.001492 ± 1.70392e-05 (W 1.67332e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002675 ± 6.4291e-05 (W 6.63325e-05) | 0.002605 ± 1.1547e-05 (W 2.54951e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003186 ± 3.60555e-05 (W 2.20045e-05) | 0.003416 ± 1.53948e-05 (W 4.64467e-05) | 0.004178 ± 8.0829e-05 (W 3.97492e-05) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014868 ± 0.00140354 (W 3.03694e-05) | 0.016551 ± 6.55744e-05 (W 3.7339e-05) | 0.016852 ± 7.82326e-05 (W 6.34823e-05) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.055854 ± 0.00365342 (W 0.00340765) | 0.072257 ± 0.00161233 (W 0.00142186) | 0.048502 ± 0.000110761 (W 0.000166177) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113942 ± 0.000273176 (W 0.000203753) | 0.113014 ± 0.000480496 (W 0.00166911) | 0.106924 ± 0.00051398 (W 0.00118412) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.51004 ± 0.0022 (W 0.00386318) | 0.506193 ± 0.00139836 (W 0.00633195) | 0.263561 ± 0.00084681 (W 0.00171319) | · | 🔴 fork 1.94× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.24952 ± 0.0151891 (W 0.0182557) | 1.25402 ± 0.00608142 (W 0.0189549) | 0.579234 ± 0.00182719 (W 0.00224955) | · | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011723 ± 6.56531e-05 (W 3.67423e-05) | 0.010589 ± 0.000350163 (W 0.000208299) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051588 ± 0.000254193 (W 0.000214362) | 0.04723 ± 0.00039784 (W 0.00149326) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144003 ± 0.00124771 (W 0.00159162) | 0.133764 ± 0.0030731 (W 0.00225334) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008136 ± 1.12694e-05 (W 3.0581e-05) | 0.008356 ± 7.97308e-05 (W 6.92329e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008146 ± 1.47309e-05 (W 4.36142e-05) | 0.008467 ± 5.74485e-05 (W 7.04358e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.029846 ± 0.000311401 (W 0.00164527) | 0.027933 ± 0.00083091 (W 0.00123294) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.029425 ± 0.000275621 (W 0.00130139) | 0.027512 ± 0.000784976 (W 0.00106442) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.052539 ± 0.000377276 (W 0.00139634) | 0.066244 ± 0.00849848 (W 0.00197708) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.052108 ± 0.000334451 (W 0.00168612) | 0.063952 ± 0.000859647 (W 0.00226061) | - | 🔵 fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008505 ± 9.37248e-05 (W 3.55711e-05) | 0.007124 ± 0.000128946 (W 5.12835e-05) | 0.012254 ± 0.000157259 (W 9.27701e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030988 ± 9.32577e-05 (W 0.000210262) | 0.053853 ± 0.00468445 (W 0.00394547) | 0.04291 ± 0.000119968 (W 0.000164665) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.076156 ± 0.000408857 (W 0.00239657) | 0.120719 ± 0.00310666 (W 0.00365481) | 0.086014 ± 0.00317932 (W 0.000215858) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.032611 ± 0.000291252 (W 0.000107616) | 0.143684 ± 0.00289541 (W 0.00276705) | 0.02638 ± 0.0336281 (W 8.8713e-05) | 🔵 fork 4.41× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.163244 ± 0.00165842 (W 0.00412719) | 0.700608 ± 0.0102521 (W 0.0244346) | 0.158573 ± 0.00158327 (W 0.00270356) | 🔵 fork 4.29× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.401175 ± 0.0129637 (W 0.0353185) | 1.43614 ± 0.0222455 (W 0.021047) | 0.339353 ± 0.00738372 (W 0.00248838) | 🔵 fork 3.58× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023844 ± 0.000106151 (W 9.07193e-05) | 0.123544 ± 0.00217058 (W 0.00569681) | 0.014086 ± 0.000279036 (W 2.91548e-05) | 🔵 fork 5.18× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.132283 ± 8.72716e-05 (W 0.00197442) | 0.645122 ± 0.0109629 (W 0.0104084) | 0.29897 ± 0.134308 (W 0.00158111) | 🔵 fork 4.88× faster than `faer-upstream` | 🔵 fork 2.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.309196 ± 0.0134903 (W 0.00863468) | 1.28791 ± 0.0206476 (W 0.0246239) | 0.93929 ± 0.000969098 (W 0.000668127) | 🔵 fork 4.17× faster than `faer-upstream` | 🔵 fork 3.04× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009518 ± 8.544e-05 (W 4.15933e-05) | 0.008105 ± 8.19776e-05 (W 4.72229e-05) | 0.012754 ± 1.73205e-05 (W 4.8737e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031669 ± 0.00031192 (W 0.00148654) | 0.05409 ± 0.000144507 (W 0.00373207) | 0.043592 ± 0.000289552 (W 8.21359e-05) | 🔵 fork 1.71× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077478 ± 0.00375545 (W 0.000287987) | 0.119095 ± 0.00528122 (W 0.00354964) | 0.085092 ± 4.22532e-05 (W 0.00110481) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.183321 ± 0.000462263 (W 0.001876) | 0.183367 ± 0.000261332 (W 0.00173318) | 0.186896 ± 0.000568773 (W 0.00190718) | · | · |  |
| `svd_thin/n64/b1` | 0.964307 ± 0.00610152 (W 0.00114785) | 0.962694 ± 0.00783294 (W 0.00437079) | 0.661913 ± 0.00171947 (W 0.00438153) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.29451 ± 0.0409395 (W 0.0117011) | 2.33932 ± 0.0281827 (W 0.0153268) | 1.35778 ± 0.052483 (W 0.00476976) | · | 🔴 fork 1.69× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140552 ± 0.000380022 (W 0.00123841) | 0.139961 ± 0.000518786 (W 0.00117201) | 0.06453 ± 0.0426989 (W 0.000151577) | · | 🔴 fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.518132 ± 0.00986836 (W 0.0020145) | 0.519861 ± 0.00901983 (W 0.00220047) | 0.269584 ± 0.000868807 (W 0.00163897) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.1828 ± 0.00496913 (W 0.00219949) | 1.18608 ± 0.00306198 (W 0.00271895) | 0.596871 ± 0.00153225 (W 0.00175586) | · | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000662 ± 1.12694e-05 (W 8.56154e-06) | 0.000662 ± 0 (W 2.37529e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001463 ± 1.57162e-05 (W 2.23897e-05) | 0.001463 ± 2.51661e-05 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002575 ± 7.26659e-05 (W 2.2832e-05) | 0.002575 ± 5.32948e-05 (W 1.93985e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003397 ± 0.000167989 (W 3.03694e-05) | 0.003337 ± 6.67108e-05 (W 3.80039e-05) | 0.003377 ± 2.5697e-05 (W 2.86234e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016802 ± 0.00120717 (W 2.30217e-05) | 0.016171 ± 0.000116234 (W 3.15785e-05) | 0.014056 ± 0.000108307 (W 8.12853e-05) | · | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049522 ± 0.00395503 (W 0.00229644) | 0.060886 ± 0.00198408 (W 0.00357128) | 0.038221 ± 6.97639e-05 (W 8.81476e-05) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113356 ± 0.000282788 (W 0.000265677) | 0.113641 ± 0.000556466 (W 0.0016831) | 0.103934 ± 0.000484563 (W 0.00138179) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.505621 ± 0.00162009 (W 0.00292539) | 0.500491 ± 0.00272485 (W 0.00282976) | 0.266657 ± 0.00135628 (W 0.00170151) | · | 🔴 fork 1.90× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21799 ± 0.0225143 (W 0.0159567) | 1.21566 ± 0.012124 (W 0.0229686) | 0.580872 ± 0.00120677 (W 0.00238181) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01045 ± 0.000100664 (W 6.59947e-05) | 0.01058 ± 9.50438e-05 (W 6.01432e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045596 ± 0.000609082 (W 0.00014889) | 0.046336 ± 0.000443223 (W 0.000216419) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132011 ± 0.000140785 (W 0.00223146) | 0.131846 ± 0.000239552 (W 0.00197906) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008165 ± 5.07642e-05 (W 3.89872e-05) | 0.008496 ± 0.000123452 (W 8.49253e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008275 ± 4.55741e-05 (W 4.93184e-05) | 0.008466 ± 0.000100664 (W 0.000104976) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.034935 ± 0.000135525 (W 0.0031623) | 0.024405 ± 0.000377036 (W 0.00207374) | - | 🔴 fork 1.43× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.029185 ± 0.00374516 (W 0.000288726) | 0.024455 ± 0.000201174 (W 0.000559693) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.059981 ± 0.000138226 (W 0.00330014) | 0.050223 ± 0.000827493 (W 0.00173727) | - | 🔴 fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060252 ± 0.000469099 (W 0.00136084) | 0.049444 ± 0.00117881 (W 0.00205184) | - | 🔴 fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007173 ± 8.98907e-05 (W 0.000139166) | 0.007123 ± 0.0001505 (W 4.83239e-05) | 0.009698 ± 8.77895e-05 (W 4.44432e-05) | · | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025908 ± 0.000113496 (W 0.000203338) | 0.045006 ± 0.00120984 (W 0.00128849) | 0.033574 ± 0.000101264 (W 0.000166461) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063559 ± 0.00012373 (W 0.00215717) | 0.0967 ± 0.00346929 (W 0.00446751) | 0.074642 ± 0.000285843 (W 0.00133269) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031138 ± 0.000207767 (W 0.000170968) | 0.10782 ± 0.00105443 (W 0.00644397) | 0.021291 ± 9.77974e-05 (W 6.76018e-05) | 🔵 fork 3.46× faster than `faer-upstream` | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.143607 ± 0.000945715 (W 0.000910612) | 0.487817 ± 0.0169907 (W 0.00779157) | 0.127281 ± 0.000622891 (W 0.00115486) | 🔵 fork 3.40× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.385148 ± 0.011388 (W 0.021734) | 1.03513 ± 0.00918691 (W 0.0224219) | 0.294619 ± 0.00141092 (W 0.00225916) | 🔵 fork 2.69× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017653 ± 0.000110907 (W 0.000121532) | 0.080811 ± 0.00369946 (W 0.00519761) | 0.011452 ± 7.35323e-05 (W 5.46004e-05) | 🔵 fork 4.58× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.087894 ± 0.00935525 (W 0.00178677) | 0.419752 ± 0.0154373 (W 0.0168334) | 0.290262 ± 0.00021537 (W 0.00195376) | 🔵 fork 4.78× faster than `faer-upstream` | 🔵 fork 3.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.19298 ± 0.000755748 (W 0.00492521) | 0.829968 ± 0.0246159 (W 0.0202612) | 0.931214 ± 0.000550918 (W 0.000715568) | 🔵 fork 4.30× faster than `faer-upstream` | 🔵 fork 4.83× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007825 ± 0.0001253 (W 7.35751e-05) | 0.007845 ± 0.000101489 (W 7.76679e-05) | 0.009909 ± 4.04145e-05 (W 3.04959e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025978 ± 0.000206369 (W 7.59816e-05) | 0.045216 ± 0.00504863 (W 0.00306171) | 0.033714 ± 0.0001948 (W 0.00163765) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n96/b1` | 0.065722 ± 0.000591236 (W 0.00267672) | 0.103763 ± 0.00110403 (W 0.00168757) | 0.073761 ± 0.000220012 (W 0.000166551) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.185305 ± 0.000507937 (W 0.00167284) | 0.184971 ± 0.000286079 (W 0.00171268) | 0.176037 ± 0.000596617 (W 0.00154135) | · | 🔴 fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.997097 ± 0.0121758 (W 0.00257278) | 1.00048 ± 0.0140116 (W 0.00383035) | 0.639902 ± 0.00110066 (W 0.00194813) | · | 🔴 fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.33931 ± 0.0421912 (W 0.0121397) | 2.31981 ± 0.0178375 (W 0.0222864) | 1.3734 ± 0.00117591 (W 0.00364674) | · | 🔴 fork 1.70× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.14226 ± 0.000169041 (W 0.00130581) | 0.14187 ± 0.000469634 (W 0.000281492) | 0.059423 ± 0.000120176 (W 0.000107941) | · | 🔴 fork 2.39× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536209 ± 0.00250196 (W 0.00236702) | 0.540016 ± 0.000639508 (W 0.00522678) | 0.258211 ± 0.000240639 (W 0.00158739) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18956 ± 0.00288393 (W 0.00255343) | 1.19432 ± 0.00349967 (W 0.00176033) | 0.602933 ± 0.000802938 (W 0.00148204) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000752 ± 5.7735e-06 (W 1.51427e-05) | 0.000761 ± 2.3094e-05 (W 1.85822e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001814 ± 6.48614e-05 (W 1.95013e-05) | 0.001703 ± 5.50757e-05 (W 1.62542e-05) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003096 ± 0.0001345 (W 2.23607e-05) | 0.002885 ± 0.000133418 (W 2.22329e-05) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003146 ± 0.000145717 (W 1.81659e-05) | 0.003287 ± 5.07642e-05 (W 4.42854e-05) | 0.003336 ± 2.08167e-05 (W 2.05475e-05) | · | 🔵 fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014657 ± 0.000991417 (W 3.39116e-05) | 0.016231 ± 0.000331182 (W 5.44086e-05) | 0.014006 ± 0.000101195 (W 5.44086e-05) | 🔵 fork 1.11× faster than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056084 ± 0.000854107 (W 0.00275623) | 0.072738 ± 0.000725298 (W 0.00102373) | 0.038 ± 0.000322154 (W 0.00133225) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.113401 ± 0.000291094 (W 0.000280448) | 0.112781 ± 0.000336071 (W 0.00129935) | 0.105075 ± 0.000381326 (W 0.00143466) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.51053 ± 0.00214533 (W 0.00551663) | 0.511198 ± 0.000974795 (W 0.00446866) | 0.259264 ± 0.0163301 (W 0.00173605) | · | 🔴 fork 1.97× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n96/b1` | 1.2509 ± 0.0116449 (W 0.0119127) | 1.24276 ± 0.0114478 (W 0.0195024) | 0.566113 ± 0.00248462 (W 0.00212665) | · | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010601 ± 0.00012356 (W 5.18295e-05) | 0.01061 ± 0.000421253 (W 7.23277e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046067 ± 0.000406264 (W 0.000229195) | 0.045757 ± 0.000423453 (W 0.00038121) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131461 ± 0.00133752 (W 0.00211366) | 0.132012 ± 0.00389176 (W 0.00207852) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008145 ± 4.58258e-05 (W 3.60042e-05) | 0.008426 ± 0.00013522 (W 0.000103678) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008176 ± 3e-05 (W 3.95891e-05) | 0.008476 ± 5.56507e-05 (W 8.08084e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.028042 ± 0.0045655 (W 0.00269959) | 0.028204 ± 0.000354177 (W 0.000894926) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.029164 ± 0.000789361 (W 0.00238553) | 0.028113 ± 0.00026022 (W 0.00131122) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049554 ± 0.00344187 (W 0.00385383) | 0.061216 ± 0.000677321 (W 0.00197335) | - | 🔵 fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0477 ± 0.00273622 (W 0.00391664) | 0.062759 ± 0.00117323 (W 0.00209631) | - | 🔵 fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007324 ± 0.000144777 (W 6.91607e-05) | 0.007133 ± 0.00223006 (W 9.59964e-05) | 0.009738 ± 7.60723e-05 (W 7.91783e-05) | · | 🔵 fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.02583 ± 0.000179224 (W 0.000217734) | 0.05221 ± 0.000620128 (W 0.0033241) | 0.033713 ± 0.000213474 (W 0.000139754) | 🔵 fork 2.02× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.06358 ± 0.00250842 (W 0.00215728) | 0.113567 ± 0.00383823 (W 0.00314308) | 0.074713 ± 0.000616796 (W 0.000205996) | 🔵 fork 1.79× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031069 ± 0.000207322 (W 0.000190555) | 0.142275 ± 0.00101415 (W 0.0102367) | 0.021411 ± 0.000191068 (W 0.000107564) | 🔵 fork 4.58× faster than `faer-upstream` | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.14771 ± 0.000803757 (W 0.00195333) | 0.695586 ± 0.0157307 (W 0.0181336) | 0.138755 ± 0.000882302 (W 0.00159792) | 🔵 fork 4.71× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.398505 ± 0.0166637 (W 0.0135593) | 1.42606 ± 0.0307953 (W 0.0393319) | 0.305072 ± 0.00136822 (W 0.00248288) | 🔵 fork 3.58× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017543 ± 4.12836e-05 (W 9.12973e-05) | 0.109319 ± 0.00146092 (W 0.00243) | 0.011602 ± 8.0829e-05 (W 0.00160521) | 🔵 fork 6.23× faster than `faer-upstream` | 🔴 fork 1.51× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.091565 ± 0.00252189 (W 0.00196973) | 0.580257 ± 0.0176632 (W 0.0166631) | 0.28987 ± 0.000458856 (W 0.00168034) | 🔵 fork 6.34× faster than `faer-upstream` | 🔵 fork 3.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.188291 ± 0.00581841 (W 0.00667028) | 1.17735 ± 0.0101268 (W 0.0174833) | 0.932046 ± 0.000512527 (W 0.00196475) | 🔵 fork 6.25× faster than `faer-upstream` | 🔵 fork 4.95× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007744 ± 7.38941e-05 (W 7.36906e-05) | 0.007674 ± 1.18462e-05 (W 3.79645e-05) | 0.009848 ± 1e-05 (W 4.77106e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.02627 ± 0.000144777 (W 0.000160905) | 0.051107 ± 0.00291652 (W 0.00324992) | 0.033524 ± 0.000196517 (W 6.99164e-05) | 🔵 fork 1.95× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065375 ± 0.00365429 (W 0.00249738) | 0.114328 ± 0.00259777 (W 0.00479289) | 0.073687 ± 0.000241904 (W 0.000112319) | 🔵 fork 1.75× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.184624 ± 0.000606238 (W 0.00153177) | 0.184844 ± 0.000672705 (W 0.00151937) | 0.177258 ± 0.000173 (W 0.00132746) | · | · |  |
| `svd_thin/n64/b1` | 1.00853 ± 0.00977447 (W 0.00544367) | 1.00962 ± 0.00476593 (W 0.00368207) | 0.630023 ± 0.000977544 (W 0.00238274) | · | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31818 ± 0.0249879 (W 0.0178762) | 2.32195 ± 0.0193802 (W 0.0102616) | 1.32543 ± 0.00432449 (W 0.00195827) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142903 ± 0.000573753 (W 0.00140706) | 0.14188 ± 0.000137478 (W 0.00172638) | 0.059243 ± 6.84178e-05 (W 0.000117525) | · | 🔴 fork 2.41× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.539378 ± 0.0116228 (W 0.00282561) | 0.540761 ± 0.0100508 (W 0.00285147) | 0.258072 ± 0.000473354 (W 0.00156654) | · | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18931 ± 0.00299302 (W 0.00222667) | 1.19044 ± 0.000955118 (W 0.00148128) | 0.596911 ± 0.00117627 (W 0.00199704) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000761 ± 2.0664e-05 (W 1.2054e-05) | 0.000741 ± 1.48436e-05 (W 1.56301e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001814 ± 2.91605e-05 (W 2.1822e-05) | 0.001703 ± 4.95681e-05 (W 1.66523e-05) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003126 ± 1.18462e-05 (W 3.80158e-05) | 0.002845 ± 0.00015102 (W 2.31776e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00527 ± 2.64575e-05 (W 2.70185e-05) | 0.00527 ± 0.000108583 (W 0.000109674) | 0.008937 ± 8.68927e-05 (W 0.000110318) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030376 ± 0.000194449 (W 6.18652e-05) | 0.030427 ± 0.00022646 (W 9.42666e-05) | 0.051135 ± 3.61663e-05 (W 0.000459404) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103413 ± 0.00148927 (W 0.00165675) | 0.103557 ± 0.000520343 (W 0.000932901) | 0.139069 ± 0.000766585 (W 0.00133562) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142265 ± 0.000237203 (W 0.000228513) | 0.142075 ± 0.000340742 (W 0.000308475) | 0.15557 ± 0.000320417 (W 0.000332303) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.639613 ± 0.00110266 (W 0.00373066) | 0.639421 ± 0.00186323 (W 0.00315267) | 0.567166 ± 0.000681522 (W 0.00214408) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54477 ± 0.0153947 (W 0.0194397) | 1.54305 ± 0.00572461 (W 0.0091436) | 1.15935 ± 0.00188466 (W 0.00272605) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017322 ± 8.67583e-05 (W 0.000114517) | 0.015669 ± 0.000193443 (W 9.11768e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096801 ± 0.000217442 (W 0.000158808) | 0.092071 ± 0.000100127 (W 0.000323737) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.277968 ± 0.000423684 (W 0.00208702) | 0.266276 ± 0.000479538 (W 0.00153036) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028052 ± 4.7648e-05 (W 9.65831e-05) | 0.028243 ± 0.000106775 (W 4.86333e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028002 ± 4.62637e-05 (W 5.8849e-05) | 0.028324 ± 4.99433e-05 (W 7.21131e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.071555 ± 0.00163768 (W 0.00124279) | 0.068129 ± 0.000235941 (W 0.0038184) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.078206 ± 0.00423471 (W 0.00250936) | 0.06832 ± 0.000172619 (W 0.0024173) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.16615 ± 0.000704015 (W 0.00436505) | 0.15555 ± 0.000390587 (W 0.00138111) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.166831 ± 0.00106217 (W 0.00379712) | 0.155535 ± 0.00135908 (W 0.00227766) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013175 ± 5.28299e-05 (W 0.000157262) | 0.01098 ± 0.000115889 (W 6.93924e-05) | 0.019867 ± 7e-05 (W 6.21715e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057479 ± 0.000325286 (W 0.000319147) | 0.052689 ± 0.000835962 (W 0.00159205) | 0.095959 ± 0.000217923 (W 0.00123396) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.151307 ± 0.000629862 (W 0.00169435) | 0.152524 ± 0.00220931 (W 0.00161258) | 0.243193 ± 0.00160711 (W 0.0011766) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070261 ± 0.000578161 (W 0.00167798) | 0.162238 ± 0.00624 (W 0.0109461) | 0.05338 ± 0.0902737 (W 0.000139571) | 🔵 fork 2.31× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.298116 ± 0.0013335 (W 0.00411911) | 0.648268 ± 0.0141078 (W 0.0110381) | 0.30564 ± 0.000763538 (W 0.00205932) | 🔵 fork 2.17× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.698516 ± 0.0197057 (W 0.00863783) | 1.37045 ± 0.0636368 (W 0.0164817) | 0.770305 ± 0.000384945 (W 0.00303664) | 🔵 fork 1.96× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.040487 ± 0.000483054 (W 0.000111893) | 0.108382 ± 0.00367351 (W 0.0040485) | 0.028834 ± 0.000133167 (W 6.73216e-05) | 🔵 fork 2.68× faster than `faer-upstream` | 🔴 fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.21054 ± 0.0011778 (W 0.00183414) | 0.607531 ± 0.00903677 (W 0.0160316) | 0.761558 ± 0.346019 (W 0.00127636) | 🔵 fork 2.89× faster than `faer-upstream` | 🔵 fork 3.62× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.418624 ± 0.00509058 (W 0.00350269) | 1.15029 ± 0.0148311 (W 0.0129222) | 2.45736 ± 0.00183555 (W 0.00212809) | 🔵 fork 2.75× faster than `faer-upstream` | 🔵 fork 5.87× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014296 ± 0.000145935 (W 8.80693e-05) | 0.012554 ± 2.66521e-05 (W 7.66433e-05) | 0.020268 ± 6.48614e-05 (W 6.43995e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059661 ± 0.000451311 (W 0.000181833) | 0.055063 ± 0.000182781 (W 0.000294856) | 0.093454 ± 0.000178355 (W 0.00127678) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.154117 ± 0.000827341 (W 0.00166951) | 0.157263 ± 0.000748827 (W 0.00416866) | 0.236901 ± 0.000856374 (W 0.00177139) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.234647 ± 0.000138897 (W 0.00174453) | 0.23606 ± 0.00174706 (W 0.00176211) | 0.261647 ± 0.00101792 (W 0.00159577) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20045 ± 0.00429847 (W 0.00240784) | 1.20289 ± 0.00652587 (W 0.00424378) | 1.03275 ± 0.00184509 (W 0.00128643) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.9927 ± 0.0218615 (W 0.0218501) | 2.96474 ± 0.010901 (W 0.0243511) | 2.52913 ± 0.00215914 (W 0.00323944) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.161261 ± 0.00039316 (W 0.00142294) | 0.162353 ± 0.000484022 (W 0.00139136) | 0.102381 ± 0.121991 (W 0.00148514) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.653019 ± 0.00294573 (W 0.00208991) | 0.652638 ± 0.00118379 (W 0.00206539) | 0.491635 ± 0.000702798 (W 0.00145566) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51155 ± 0.00476311 (W 0.00215699) | 1.51158 ± 0.00180174 (W 0.00256228) | 1.35714 ± 0.00222824 (W 0.00222038) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 1e-05 (W 2.70185e-05) | 0.001062 ± 2e-05 (W 2.68328e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002685 ± 3.51188e-05 (W 2.51635e-05) | 0.002695 ± 2.51661e-05 (W 2.94958e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004919 ± 3.49333e-05 (W 1.89024e-05) | 0.004879 ± 3.51188e-05 (W 2.51635e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00521 ± 3.21455e-05 (W 2.70185e-05) | 0.00521 ± 7.53459e-05 (W 0.000127005) | 0.009037 ± 7.93725e-05 (W 3.34664e-05) | · | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030257 ± 0.000174964 (W 0.000123896) | 0.030378 ± 6.60328e-05 (W 0.00148263) | 0.051837 ± 0.000142084 (W 0.00112721) | · | 🔵 fork 1.71× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111698 ± 0.000581815 (W 0.00286342) | 0.111752 ± 0.000427914 (W 0.00400012) | 0.139585 ± 0.000612125 (W 0.000392951) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142184 ± 0.000318077 (W 0.000253696) | 0.14249 ± 0.000453822 (W 0.00043483) | 0.157238 ± 0.000326942 (W 0.00133336) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.643745 ± 0.00113636 (W 0.00358426) | 0.646981 ± 0.00160353 (W 0.00686413) | 0.543137 ± 0.00134307 (W 0.00289744) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.55503 ± 0.00768825 (W 0.0219931) | 1.60949 ± 0.0120333 (W 0.0172014) | 1.0425 ± 0.0025635 (W 0.00368477) | · | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017502 ± 0.000210064 (W 0.000111478) | 0.015891 ± 0.00015972 (W 7.173e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096851 ± 0.000192918 (W 0.00036215) | 0.091664 ± 0.00050142 (W 0.000539843) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.27806 ± 0.00187873 (W 0.00282176) | 0.266054 ± 0.000825112 (W 0.00194831) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027953 ± 4.10731e-05 (W 8.23541e-05) | 0.028383 ± 7.26659e-05 (W 5.97177e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028012 ± 8.11665e-05 (W 7.30068e-05) | 0.028394 ± 0.000172476 (W 5.9844e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.053622 ± 0.00493847 (W 0.000627796) | 0.073088 ± 0.00119225 (W 0.00189752) | - | 🔵 fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.053001 ± 9.96812e-05 (W 0.000955266) | 0.073088 ± 0.0016285 (W 0.0014464) | - | 🔵 fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.105931 ± 0.00302847 (W 0.00322059) | 0.161627 ± 0.00013308 (W 0.00285119) | - | 🔵 fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.106318 ± 0.000933195 (W 0.00293896) | 0.162049 ± 0.000598024 (W 0.00387369) | - | 🔵 fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013275 ± 0.00012 (W 7.12741e-05) | 0.011141 ± 0.000135769 (W 9.22562e-05) | 0.019958 ± 0.000245968 (W 7.23339e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057597 ± 4.82942e-05 (W 0.000177753) | 0.0528 ± 0.000231145 (W 0.00167154) | 0.096524 ± 0.000194672 (W 0.00135605) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.150256 ± 0.000207447 (W 0.00227101) | 0.165624 ± 0.000753596 (W 0.00374428) | 0.244215 ± 0.00074916 (W 0.00134184) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.069822 ± 0.000265014 (W 0.00126386) | 0.187326 ± 0.00108814 (W 0.00657496) | 0.053429 ± 0.0895932 (W 0.000125652) | 🔵 fork 2.68× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.317661 ± 0.00306821 (W 0.00560017) | 0.879485 ± 0.0110388 (W 0.0219714) | 0.284228 ± 0.00130973 (W 0.0014731) | 🔵 fork 2.77× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.708109 ± 0.0570707 (W 0.0195979) | 1.83431 ± 0.0850364 (W 0.030707) | 0.703451 ± 0.00119114 (W 0.00646172) | 🔵 fork 2.59× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.040725 ± 0.000253779 (W 0.00136531) | 0.144213 ± 0.00275795 (W 0.00275834) | 0.028794 ± 9.51332e-05 (W 7.91833e-05) | 🔵 fork 3.54× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.220421 ± 0.00149473 (W 0.00179043) | 0.766309 ± 0.00602494 (W 0.0133461) | 0.7628 ± 0.345773 (W 0.00126206) | 🔵 fork 3.48× faster than `faer-upstream` | 🔵 fork 3.46× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.431231 ± 0.00362609 (W 0.00275172) | 1.52669 ± 0.0216992 (W 0.023398) | 2.45532 ± 0.0030996 (W 0.00478412) | 🔵 fork 3.54× faster than `faer-upstream` | 🔵 fork 5.69× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014467 ± 0.000188107 (W 8.161e-05) | 0.012514 ± 6.07481e-05 (W 8.4907e-05) | 0.020318 ± 3.05505e-05 (W 6.88426e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059731 ± 0.000572421 (W 0.000223691) | 0.054681 ± 0.000271669 (W 0.000274883) | 0.093374 ± 0.00026504 (W 0.000280512) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.153316 ± 0.000505792 (W 0.00197699) | 0.168764 ± 0.00195647 (W 0.00241995) | 0.236651 ± 0.000497438 (W 0.00114735) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.234817 ± 0.0010391 (W 0.00196443) | 0.235489 ± 0.000753313 (W 0.00145935) | 0.263171 ± 0.000408136 (W 0.00166354) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21104 ± 0.00110333 (W 0.00394964) | 1.21836 ± 0.00602733 (W 0.00795508) | 0.99377 ± 0.00136555 (W 0.00223609) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.95977 ± 0.0147201 (W 0.0160314) | 3.08859 ± 0.0148995 (W 0.0136134) | 2.3502 ± 0.00139881 (W 0.00521685) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.161056 ± 0.000487246 (W 0.0014795) | 0.162002 ± 0.000130573 (W 0.00165127) | 0.102505 ± 0.121992 (W 0.000259223) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.649719 ± 0.00111522 (W 0.00188438) | 0.650551 ± 0.00360672 (W 0.00202212) | 0.490909 ± 0.000508819 (W 0.00188186) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.50545 ± 0.0192186 (W 0.00260022) | 1.50972 ± 0.0188136 (W 0.00195437) | 1.35689 ± 0.00279509 (W 0.00246165) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001092 ± 3.01164e-05 (W 3e-05) | 0.001102 ± 1.52753e-05 (W 2.40832e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002685 ± 2.12211e-05 (W 1.33116e-05) | 0.002645 ± 5.19615e-05 (W 3.08739e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00492 ± 5.50757e-06 (W 2.86758e-05) | 0.00489 ± 3.5171e-05 (W 3.43511e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00524 ± 5.03322e-05 (W 5e-05) | 0.005209 ± 4.38216e-05 (W 3.70135e-05) | 0.008095 ± 0.000248818 (W 3.66374e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029946 ± 0.000321865 (W 9.04229e-05) | 0.030086 ± 0.000133121 (W 0.00128195) | 0.043533 ± 0.000417216 (W 0.000141036) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102715 ± 0.000506086 (W 0.00153642) | 0.102681 ± 0.000789599 (W 0.000781655) | 0.124526 ± 0.00130827 (W 0.000113446) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142165 ± 0.0005145 (W 0.000280407) | 0.141789 ± 0.000115145 (W 0.000283567) | 0.153792 ± 0.000220334 (W 0.000386711) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.647076 ± 0.00699892 (W 0.00502034) | 0.638429 ± 0.00225781 (W 0.00392276) | 0.556827 ± 0.00196213 (W 0.00224564) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53954 ± 0.00984587 (W 0.0138839) | 1.54183 ± 0.00820609 (W 0.014264) | 1.13927 ± 0.00410184 (W 0.00144642) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015639 ± 7.93725e-05 (W 6.46475e-05) | 0.015729 ± 0.000147988 (W 9.84337e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089978 ± 0.000401748 (W 0.00145544) | 0.089728 ± 0.000276697 (W 0.00147888) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.263961 ± 0.000679398 (W 0.00167769) | 0.263671 ± 0.00065738 (W 0.00208579) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027922 ± 7.14866e-05 (W 7.0214e-05) | 0.028103 ± 0.000160894 (W 0.000104237) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027992 ± 3.27159e-05 (W 4.19547e-05) | 0.028302 ± 0.000172917 (W 0.00112289) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.076665 ± 0.00459636 (W 0.000927928) | 0.066554 ± 0.00117152 (W 0.00105103) | - | 🔴 fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.069111 ± 7.56461e-05 (W 0.0034854) | 0.066384 ± 0.00156273 (W 0.00233094) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.164762 ± 0.00354019 (W 0.00330592) | 0.155134 ± 0.000398937 (W 0.00122777) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.164987 ± 0.000436848 (W 0.00363618) | 0.157363 ± 0.000858707 (W 0.00237741) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011442 ± 0.000120168 (W 0.000116103) | 0.011181 ± 0.000110151 (W 7.49667e-05) | 0.017423 ± 0.000125819 (W 9.09406e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051287 ± 0.00015048 (W 0.00152992) | 0.050895 ± 0.00054663 (W 0.000278409) | 0.085392 ± 0.000330368 (W 0.000124392) | · | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.135823 ± 0.000224295 (W 0.00161024) | 0.15058 ± 0.00126459 (W 0.00154738) | 0.224698 ± 0.000393055 (W 0.00162976) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068046 ± 0.000315571 (W 0.000264466) | 0.159487 ± 0.0143547 (W 0.0132599) | 0.048079 ± 0.00023131 (W 0.000205283) | 🔵 fork 2.34× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.297164 ± 0.00206416 (W 0.00637041) | 0.655441 ± 0.00278217 (W 0.0102955) | 0.287846 ± 0.000408494 (W 0.001685) | 🔵 fork 2.21× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.676904 ± 0.0401122 (W 0.00542757) | 1.37852 ± 0.0550217 (W 0.0184335) | 0.734247 ± 0.00199126 (W 0.00180007) | 🔵 fork 2.04× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033664 ± 0.000173379 (W 0.000197046) | 0.09654 ± 0.00332702 (W 0.00366533) | 0.026099 ± 6.07481e-05 (W 5.13449e-05) | 🔵 fork 2.87× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.158055 ± 0.00122647 (W 0.00231296) | 0.511683 ± 0.0113067 (W 0.0117259) | 0.757537 ± 0.00171237 (W 0.00137164) | 🔵 fork 3.24× faster than `faer-upstream` | 🔵 fork 4.79× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.3373 ± 0.000178197 (W 0.00324261) | 1.00491 ± 0.00938315 (W 0.0119734) | 2.4432 ± 0.00063676 (W 0.00780483) | 🔵 fork 2.98× faster than `faer-upstream` | 🔵 fork 7.24× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012364 ± 0.000110183 (W 6.176e-05) | 0.012353 ± 0.000255969 (W 6.7248e-05) | 0.017202 ± 5.56507e-05 (W 5.20692e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.05298 ± 0.000368375 (W 0.000158768) | 0.053129 ± 0.000227478 (W 0.000437681) | 0.082905 ± 0.000198349 (W 0.00132036) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.13934 ± 0.000847512 (W 0.00145743) | 0.154313 ± 0.000716598 (W 0.0014398) | 0.218627 ± 0.0010899 (W 0.00146605) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232982 ± 0.00151883 (W 0.00198156) | 0.232561 ± 0.000592893 (W 0.00169015) | 0.257659 ± 0.000634698 (W 0.00121777) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23893 ± 0.00563462 (W 0.00382295) | 1.23229 ± 0.00590112 (W 0.00683097) | 1.00831 ± 0.00107968 (W 0.000952226) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.94897 ± 0.0139388 (W 0.0220018) | 2.95088 ± 0.0104707 (W 0.0133176) | 2.51065 ± 0.00173973 (W 0.00156422) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158405 ± 0.000282366 (W 0.00108356) | 0.159708 ± 0.000171892 (W 0.00124494) | 0.100828 ± 0.00024717 (W 0.000128725) | · | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.626166 ± 0.00132671 (W 0.00215739) | 0.626799 ± 0.000869658 (W 0.00175865) | 0.479373 ± 0.00052096 (W 0.00184338) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48515 ± 0.00351274 (W 0.00264477) | 1.48147 ± 0.00189259 (W 0.00247166) | 1.33725 ± 0.00155603 (W 0.00214583) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001203 ± 0.000104165 (W 2.2786e-05) | 0.001202 ± 2.51661e-05 (W 1.31605e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002806 ± 2.09841e-05 (W 1.91128e-05) | 0.002805 ± 0.000208663 (W 2.38747e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005189 ± 0.000237235 (W 2.60768e-05) | 0.00515 ± 0.00025064 (W 3.53553e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00519 ± 4.04145e-05 (W 3.91701e-05) | 0.005159 ± 9.88956e-05 (W 2.70185e-05) | 0.007805 ± 0.000192873 (W 8.35422e-05) | · | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029686 ± 0.000309744 (W 7.61991e-05) | 0.029796 ± 0.000349403 (W 7.82451e-05) | 0.043952 ± 0.000448766 (W 0.000159854) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.11096 ± 0.000263205 (W 0.00422322) | 0.110727 ± 0.00084968 (W 0.00294862) | 0.124716 ± 0.000228945 (W 0.00158846) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142291 ± 0.000192511 (W 0.0021001) | 0.142255 ± 0.000398215 (W 0.00151726) | 0.155303 ± 0.000710493 (W 0.00144087) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.645258 ± 0.0021072 (W 0.00453463) | 0.647665 ± 0.00316299 (W 0.00571324) | 0.530429 ± 0.00263815 (W 0.00229092) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53808 ± 0.0236634 (W 0.0360831) | 1.59959 ± 0.00748723 (W 0.0186789) | 1.02713 ± 0.00409012 (W 0.00168366) | · | 🔴 fork 1.50× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.0156 ± 3.76431e-05 (W 0.000121367) | 0.01588 ± 0.000202978 (W 0.000117466) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090191 ± 0.000129747 (W 0.00126374) | 0.08978 ± 0.00038045 (W 0.00150253) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264274 ± 0.000852175 (W 0.002223) | 0.263662 ± 0.000797679 (W 0.00168854) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028102 ± 1.00167e-05 (W 7.45205e-05) | 0.028183 ± 6.84617e-05 (W 0.000111706) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028083 ± 4.84183e-05 (W 5.98189e-05) | 0.028224 ± 5.72742e-05 (W 0.000100598) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.050936 ± 0.000477693 (W 0.00248668) | 0.071546 ± 0.00140124 (W 0.00277808) | - | 🔵 fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.050825 ± 0.00063541 (W 0.00260293) | 0.071796 ± 0.000610844 (W 0.00194515) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.107053 ± 0.0455204 (W 0.00384873) | 0.161666 ± 0.00241586 (W 0.00163271) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.103868 ± 0.0467241 (W 0.00563906) | 0.160408 ± 0.00186699 (W 0.00240168) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.011601 ± 0.000270623 (W 0.000123394) | 0.011281 ± 4.08697e-05 (W 5.44977e-05) | 0.017462 ± 0.000132503 (W 6.31292e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051255 ± 0.000357956 (W 0.000311994) | 0.051076 ± 0.000277525 (W 0.00138131) | 0.085622 ± 0.000210336 (W 0.000135286) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.135828 ± 7.3146e-05 (W 0.000361906) | 0.16373 ± 0.00142245 (W 0.00314893) | 0.224285 ± 0.00073546 (W 0.00145) | 🔵 fork 1.21× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068487 ± 3.38083e-05 (W 0.000361764) | 0.187529 ± 0.00389482 (W 0.0071782) | 0.048171 ± 0.000112385 (W 6.04152e-05) | 🔵 fork 2.74× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.314869 ± 0.00143301 (W 0.00540713) | 0.892379 ± 0.0215765 (W 0.0242211) | 0.26416 ± 0.00104865 (W 0.00194344) | 🔵 fork 2.83× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.69239 ± 0.0614669 (W 0.0269547) | 1.83336 ± 0.0852638 (W 0.0200904) | 0.672844 ± 0.00125224 (W 0.00135517) | 🔵 fork 2.65× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.033724 ± 0.000159615 (W 0.0010877) | 0.128986 ± 0.00326279 (W 0.00806969) | 0.0262 ± 8.84892e-05 (W 3.78153e-05) | 🔵 fork 3.82× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.168965 ± 0.00201529 (W 0.00358707) | 0.675007 ± 0.00764822 (W 0.0178368) | 0.756742 ± 9.77804e-05 (W 0.00225852) | 🔵 fork 3.99× faster than `faer-upstream` | 🔵 fork 4.48× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.356906 ± 0.00294425 (W 0.00415703) | 1.35104 ± 0.0204011 (W 0.032869) | 2.44171 ± 0.000981149 (W 0.00443184) | 🔵 fork 3.79× faster than `faer-upstream` | 🔵 fork 6.84× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012534 ± 0.000113271 (W 7.827e-05) | 0.012403 ± 0.00016328 (W 5.19452e-05) | 0.017232 ± 0.00012079 (W 3.57771e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052619 ± 0.000397627 (W 0.000341531) | 0.053039 ± 0.000206137 (W 0.00025124) | 0.082908 ± 5.91805e-05 (W 0.0014215) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.140398 ± 0.000542639 (W 0.00183316) | 0.165198 ± 0.00219558 (W 0.00310974) | 0.218355 ± 0.000568319 (W 0.00195086) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.233104 ± 0.00117775 (W 0.00219758) | 0.233004 ± 0.000104843 (W 0.00233173) | 0.258431 ± 0.000553997 (W 0.0015059) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24205 ± 0.00180402 (W 0.00576624) | 1.24841 ± 0.0045251 (W 0.00865398) | 0.970948 ± 0.00257581 (W 0.00176373) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.9276 ± 0.0166741 (W 0.0118537) | 3.04779 ± 0.0219469 (W 0.0114293) | 2.33298 ± 0.00229979 (W 0.00509883) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.158129 ± 0.000404334 (W 0.000482412) | 0.159842 ± 0.000506731 (W 0.00146168) | 0.100186 ± 0.000375054 (W 0.000184581) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.626352 ± 0.00221363 (W 0.00224212) | 0.626196 ± 0.00199057 (W 0.002503) | 0.47831 ± 0.000574902 (W 0.00178827) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48245 ± 0.0173574 (W 0.00297528) | 1.47821 ± 0.0178364 (W 0.00156271) | 1.34026 ± 0.000351158 (W 0.00370778) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001183 ± 3.49333e-05 (W 2.97372e-05) | 0.001202 ± 4.04145e-05 (W 2.1429e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002805 ± 0.00011547 (W 1.82291e-05) | 0.002815 ± 0.0001155 (W 1.37949e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00522 ± 0.000237868 (W 2.38747e-05) | 0.005189 ± 0.0002257 (W 2.06712e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
