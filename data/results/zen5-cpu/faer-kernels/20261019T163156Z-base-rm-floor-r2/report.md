# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a5e6b7d239466fb0d685edc20db6c4f3f3a71411`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `6e2afddbaf8e59006f66257641a4928ecb8c1569`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `25dd94085a1ca1765a59d85901089cdf3a1a2756abb3ff4fbaf7f780363f7a4a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T16:42:40.289754Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small --threads 4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label base-rm-floor-r2 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261019T163156Z-base-rm-floor-r2/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.13%, worst 290.91% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 106 of 768 engine cells exceed 5% and carry `!`; median within-process relative SD 0.83%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `cholesky/n32/b1` | 0.003216 ± 0.000186405 (W 3.86161e-05) | 0.003406 ± 3.84318e-05 (W 6.36655e-05) | 0.004167 ± 1.51767e-05 (W 6.96419e-05) | · | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.017162 ± 0.00158321 (W 3.56371e-05) | 0.016621 ± 9.50438e-05 (W 3.78153e-05) | 0.016992 ± 0.000168573 (W 7.86142e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049602 ± 0.00193443 (W 0.00283397) | 0.060683 ± 0.000742495 (W 0.00202196) | 0.04828 ± 0.000108583 (W 0.000186805) | 🔵 fork 1.22× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113181 ± 0.000182814 (W 0.00168375) | 0.113221 ± 0.000492098 (W 0.000173768) | 0.105637 ± 0.000354119 (W 0.000732827) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.502957 ± 0.00167617 (W 0.00354238) | 0.502896 ± 0.000462105 (W 0.00370311) | 0.273539 ± 0.00250671 (W 0.00146651) | · | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21646 ± 0.00396393 (W 0.0232067) | 1.21877 ± 0.000482221 (W 0.0225852) | 0.594467 ± 0.000335585 (W 0.00222236) | · | 🔴 fork 2.05× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011451 ± 0.000307208 (W 0.000165246) | 0.01092 ± 0.000380356 (W 3.91152e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051456 ± 0.000471976 (W 0.000213517) | 0.047028 ± 0.000839583 (W 0.000195935) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143778 ± 0.000897826 (W 0.00233056) | 0.13422 ± 0.000231805 (W 0.00246836) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008326 ± 3.05014e-05 (W 6.58885e-05) | 0.008436 ± 8.52467e-05 (W 6.78476e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008406 ± 5.03322e-05 (W 3.37817e-05) | 0.008496 ± 6.50641e-05 (W 6.38224e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.024756 ± 0.00136627 (W 0.000927341) | 0.024025 ± 7.05006e-05 (W 0.000861968) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.024977 ± 0.000906378 (W 0.000887325) | 0.024526 ± 0.000562744 (W 0.000614237) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049562 ± 0.000130767 (W 0.00054761) | 0.050324 ± 0.000333798 (W 0.000782158) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.049873 ± 0.000260225 (W 0.000316948) | 0.049713 ± 0.000343105 (W 0.00106549) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008485 ± 4.50592e-05 (W 5.28129e-05) | 0.007274 ± 0.000205695 (W 0.000173655) | 0.012222 ± 0.000116863 (W 9.83143e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030627 ± 0.000494844 (W 0.000195485) | 0.045835 ± 0.00171549 (W 0.00244909) | 0.043 ± 0.000338246 (W 0.000143183) | 🔵 fork 1.50× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.076442 ± 0.000466984 (W 0.000172424) | 0.106608 ± 0.000758982 (W 0.00308673) | 0.093915 ± 0.000291033 (W 0.00124693) | 🔵 fork 1.39× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.033382 ± 0.000122202 (W 0.000169727) | 0.114573 ± 0.000980781 (W 0.00312136) | 0.026409 ± 0.0335718 (W 0.000175451) | 🔵 fork 3.43× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.174926 ± 0.0109509 (W 0.0026908) | 0.505462 ± 0.00694358 (W 0.0095318) | 0.145481 ± 0.00125299 (W 0.00137783) | 🔵 fork 2.89× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.410194 ± 0.00678154 (W 0.0185688) | 1.05712 ± 0.0177078 (W 0.0155495) | 0.3332 ± 0.00154811 (W 0.00454098) | 🔵 fork 2.58× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.036398 ± 0.00517153 (W 0.000685096) | 0.093384 ± 0.00474388 (W 0.00602097) | 0.014287 ± 0.000129526 (W 4.9992e-05) | 🔵 fork 2.57× faster than `faer-upstream` | 🔴 fork 2.55× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.121967 ± 0.00190543 (W 0.00958179) | 0.470516 ± 0.00495064 (W 0.00954057) | 0.298676 ± 0.134213 (W 0.00170783) | 🔵 fork 3.86× faster than `faer-upstream` | 🔵 fork 2.45× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.22535 ± 0.0043238 (W 0.00381025) | 1.02474 ± 0.0393986 (W 0.0231241) | 0.942305 ± 0.00119354 (W 0.000368953) | 🔵 fork 4.55× faster than `faer-upstream` | 🔵 fork 4.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009448 ± 0.000111879 (W 0.000102616) | 0.008246 ± 0.000150444 (W 7.41161e-05) | 0.012753 ± 0.0001138 (W 6.89725e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031529 ± 0.000162891 (W 0.000186006) | 0.046687 ± 0.00150637 (W 0.00211669) | 0.043601 ± 0.000280637 (W 0.000121886) | 🔵 fork 1.48× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077725 ± 0.000191398 (W 0.00293496) | 0.104735 ± 0.00224905 (W 0.00284661) | 0.087573 ± 0.000179528 (W 0.000255676) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.183812 ± 0.00282361 (W 0.0019984) | 0.184173 ± 0.000530284 (W 0.00232422) | 0.186106 ± 0.000576334 (W 0.00124036) | · | · |  |
| `svd_thin/n64/b1` | 0.95023 ± 0.00141582 (W 0.000943343) | 0.951111 ± 0.00249286 (W 0.00246085) | 0.668986 ± 0.00119289 (W 0.00210313) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32302 ± 0.0424422 (W 0.0152138) | 2.28907 ± 0.0109275 (W 0.0222214) | 1.41647 ± 0.0500455 (W 0.00280425) | · | 🔴 fork 1.64× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140662 ± 0.000200899 (W 0.000196003) | 0.140462 ± 0.000305043 (W 0.00130502) | 0.06464 ± 0.0430093 (W 0.0011277) | · | 🔴 fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.518776 ± 0.00160168 (W 0.00151238) | 0.518085 ± 0.00212429 (W 0.00189145) | 0.270433 ± 0.00036093 (W 0.00132982) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18169 ± 0.0021913 (W 0.00170061) | 1.18083 ± 0.00288172 (W 0.00206083) | 0.604856 ± 0.000383763 (W 0.00167687) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 5.7735e-06 (W 1.66523e-05) | 0.000662 ± 6.08276e-06 (W 1.32023e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001482 ± 6.08276e-06 (W 1.56939e-05) | 0.001483 ± 6.35085e-06 (W 1.81466e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002585 ± 5.89661e-05 (W 4.32701e-05) | 0.002584 ± 6.26126e-05 (W 3.33796e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003507 ± 0.000179519 (W 4.32435e-05) | 0.003447 ± 2.6839e-05 (W 3.80565e-05) | 0.004187 ± 4.38216e-05 (W 6.32084e-05) | · | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015098 ± 0.00112553 (W 4.80541e-05) | 0.016591 ± 0.000109697 (W 3.20936e-05) | 0.016861 ± 0.000250573 (W 7.39594e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.05931 ± 0.00111279 (W 0.00359248) | 0.072435 ± 0.000993196 (W 0.00233401) | 0.04844 ± 0.000233582 (W 0.00151792) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.11293 ± 0.000411933 (W 0.00014942) | 0.113221 ± 0.000176163 (W 0.00164041) | 0.106839 ± 0.000646367 (W 0.00153023) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.507656 ± 0.00480495 (W 0.00542341) | 0.505341 ± 0.00238557 (W 0.00343662) | 0.263772 ± 0.000333467 (W 0.00177434) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.26533 ± 0.0138806 (W 0.0269842) | 1.25929 ± 0.00849729 (W 0.0178184) | 0.577526 ± 0.00126036 (W 0.00191787) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011832 ± 0.00019126 (W 7.3927e-05) | 0.01075 ± 0.000340309 (W 8.59069e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051336 ± 0.000472593 (W 9.98499e-05) | 0.047469 ± 0.000202436 (W 0.00182752) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144049 ± 0.000237887 (W 0.00209303) | 0.133679 ± 0.00214716 (W 0.00201706) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008355 ± 3.61985e-05 (W 3.81484e-05) | 0.008455 ± 0.000100002 (W 8.00206e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008406 ± 3.01164e-05 (W 4.85005e-05) | 0.008446 ± 5.83124e-05 (W 0.000144233) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020949 ± 0.000482863 (W 0.000340565) | 0.027481 ± 0.0013441 (W 0.00361367) | - | 🔵 fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0215 ± 0.000435201 (W 0.00129716) | 0.0271 ± 0.00128211 (W 0.00178505) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.039123 ± 0.0185362 (W 0.00116236) | 0.061936 ± 0.00070885 (W 0.00200377) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.037951 ± 0.000374127 (W 0.000933927) | 0.062847 ± 0.000383137 (W 0.00150613) | - | 🔵 fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008606 ± 0.00010116 (W 9.58238e-05) | 0.007144 ± 0.000106663 (W 4.90541e-05) | 0.012263 ± 4.72582e-05 (W 0.000162056) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030867 ± 0.000120652 (W 0.000217424) | 0.049121 ± 0.00267989 (W 0.00363142) | 0.04286 ± 8.41249e-05 (W 0.00157477) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.076052 ± 0.000187271 (W 0.00210224) | 0.117859 ± 0.00422091 (W 0.00332036) | 0.08595 ± 0.00328258 (W 0.000304484) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.033582 ± 5.45008e-05 (W 0.000148176) | 0.143647 ± 0.00258645 (W 0.00171383) | 0.026319 ± 0.0338698 (W 0.000191341) | 🔵 fork 4.28× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.16638 ± 0.0109444 (W 0.0016195) | 0.682511 ± 0.0232503 (W 0.0264784) | 0.158034 ± 0.00185587 (W 0.00197824) | 🔵 fork 4.10× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n96/b1` | 0.425172 ± 0.0156001 (W 0.0177109) | 1.44202 ± 0.0163038 (W 0.0374947) | 0.338701 ± 0.00734075 (W 0.00328092) | 🔵 fork 3.39× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.041958 ± 0.000646468 (W 0.000485701) | 0.125404 ± 0.00269442 (W 0.00535457) | 0.014157 ± 0.000112962 (W 6.14679e-05) | 🔵 fork 2.99× faster than `faer-upstream` | 🔴 fork 2.96× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.1234 ± 0.00502514 (W 0.00166263) | 0.650351 ± 0.00939024 (W 0.0150393) | 0.299558 ± 0.134586 (W 0.00136792) | 🔵 fork 5.27× faster than `faer-upstream` | 🔵 fork 2.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.241329 ± 0.013234 (W 0.0108334) | 1.31477 ± 0.0171259 (W 0.0133757) | 0.940582 ± 0.000248308 (W 0.000667329) | 🔵 fork 5.45× faster than `faer-upstream` | 🔵 fork 3.90× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009798 ± 0.000248818 (W 3.95639e-05) | 0.008155 ± 5.32948e-05 (W 6.22093e-05) | 0.012884 ± 9.50807e-05 (W 5.36218e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031679 ± 9.84886e-05 (W 0.000145905) | 0.053981 ± 0.00157218 (W 0.00345637) | 0.043391 ± 8.18535e-05 (W 0.000138792) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077474 ± 0.00390739 (W 0.00250586) | 0.117478 ± 0.0053682 (W 0.00483489) | 0.085359 ± 9.60902e-05 (W 0.0013862) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.183662 ± 0.000587375 (W 0.00158594) | 0.183031 ± 0.000524767 (W 0.00152605) | 0.187138 ± 0.000532204 (W 0.00170914) | · | · |  |
| `svd_thin/n64/b1` | 0.965018 ± 0.00256353 (W 0.00587402) | 0.962132 ± 0.00223264 (W 0.00566116) | 0.662233 ± 0.00627912 (W 0.00327596) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32701 ± 0.0153649 (W 0.0142693) | 2.31124 ± 0.0375125 (W 0.0116483) | 1.36176 ± 0.0535637 (W 0.00259191) | · | 🔴 fork 1.71× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140773 ± 0.000316118 (W 0.00174053) | 0.140552 ± 0.000210405 (W 0.00119465) | 0.06435 ± 0.0429278 (W 0.000352271) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.519147 ± 0.00265807 (W 0.00198177) | 0.517524 ± 0.00155297 (W 0.00223084) | 0.270634 ± 0.000849683 (W 0.00150536) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18539 ± 0.004312 (W 0.00207361) | 1.17976 ± 0.00361919 (W 0.00205582) | 0.598725 ± 0.00354835 (W 0.0032809) | · | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 6.08276e-06 (W 1.89024e-05) | 0.000671 ± 6.08276e-06 (W 8.56154e-06) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001483 ± 2.51064e-05 (W 5.47723e-06) | 0.001502 ± 2.62742e-05 (W 2.0693e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002685 ± 6.55744e-05 (W 2.61572e-05) | 0.002575 ± 9.26661e-05 (W 3.43511e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003096 ± 0.000335619 (W 2.59654e-05) | 0.003366 ± 2.51661e-05 (W 1.41421e-05) | 0.003376 ± 1.73205e-05 (W 1.34164e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014927 ± 0.00107734 (W 3.85396e-05) | 0.016291 ± 9.06661e-05 (W 2.2298e-05) | 0.014006 ± 3.05505e-05 (W 3.92326e-05) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049102 ± 0.00142301 (W 0.00277827) | 0.060182 ± 0.00275687 (W 0.00138354) | 0.038 ± 0.000279018 (W 5.19452e-05) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113011 ± 0.000131074 (W 0.0021099) | 0.11267 ± 0.000582032 (W 0.00116794) | 0.103623 ± 0.000222344 (W 0.000382835) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.511643 ± 0.00444336 (W 0.017837) | 0.502205 ± 0.00324616 (W 0.00237649) | 0.266737 ± 0.000113271 (W 0.00165786) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21882 ± 0.0180775 (W 0.0213046) | 1.22175 ± 0.00322351 (W 0.0186729) | 0.583136 ± 0.00128543 (W 0.00217212) | · | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010329 ± 0.000128582 (W 4.3359e-05) | 0.01038 ± 0.000167572 (W 4.81165e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045975 ± 0.000279303 (W 0.000196113) | 0.046086 ± 0.000539669 (W 0.000118609) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131565 ± 0.00036722 (W 0.00259011) | 0.132146 ± 8.0829e-05 (W 0.00218487) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008225 ± 2.12211e-05 (W 8.73625e-05) | 0.008406 ± 8.17945e-05 (W 7.27344e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008326 ± 7.59627e-05 (W 4.45668e-05) | 0.008435 ± 6.56531e-05 (W 0.00012717) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.035115 ± 0.00300088 (W 0.00360687) | 0.024366 ± 0.000133742 (W 0.000716174) | - | 🔴 fork 1.44× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.034674 ± 0.00367317 (W 0.00289272) | 0.024425 ± 0.000257164 (W 0.000759354) | - | 🔴 fork 1.42× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.060693 ± 0.000109697 (W 0.00183689) | 0.049482 ± 0.000338089 (W 0.00112782) | - | 🔴 fork 1.23× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060503 ± 0.000286409 (W 0.000469992) | 0.051155 ± 0.000232136 (W 0.00161254) | - | 🔴 fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007053 ± 8.55395e-05 (W 3.44413e-05) | 0.007013 ± 8.06866e-05 (W 6.36647e-05) | 0.009688 ± 9.71253e-05 (W 8.21584e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025447 ± 0.000296279 (W 0.000162721) | 0.044313 ± 0.000892 (W 0.00313942) | 0.033683 ± 8.59089e-05 (W 0.000193999) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.06402 ± 4.99032e-05 (W 0.00214255) | 0.103313 ± 0.00227866 (W 0.00266792) | 0.074389 ± 0.00026674 (W 0.00145548) | 🔵 fork 1.61× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031839 ± 0.000101474 (W 0.000156558) | 0.108943 ± 0.00442734 (W 0.008102) | 0.02121 ± 0.000176721 (W 9.2727e-05) | 🔵 fork 3.42× faster than `faer-upstream` | 🔴 fork 1.50× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.152955 ± 0.00347489 (W 0.00266285) | 0.497626 ± 0.0112544 (W 0.0122294) | 0.127036 ± 0.000568115 (W 0.00158179) | 🔵 fork 3.25× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.388884 ± 0.0131268 (W 0.0157773) | 1.06617 ± 0.016488 (W 0.017648) | 0.293797 ± 0.00105003 (W 0.00230646) | 🔵 fork 2.74× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.018004 ± 0.000272838 (W 9.60172e-05) | 0.084498 ± 0.00540235 (W 0.00691696) | 0.011481 ± 1.52753e-05 (W 4.46912e-05) | 🔵 fork 4.69× faster than `faer-upstream` | 🔴 fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.089968 ± 0.0108624 (W 0.00305733) | 0.422356 ± 0.00752142 (W 0.00802334) | 0.28973 ± 0.000388108 (W 0.00147299) | 🔵 fork 4.69× faster than `faer-upstream` | 🔵 fork 3.22× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.210903 ± 0.0160104 (W 0.0145353) | 0.899545 ± 0.0508833 (W 0.0113359) | 0.932025 ± 0.00301382 (W 0.000993921) | 🔵 fork 4.27× faster than `faer-upstream` | 🔵 fork 4.42× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.007824 ± 0.0001155 (W 4.57854e-05) | 0.007784 ± 0.000185284 (W 2.86356e-05) | 0.009838 ± 1.52753e-05 (W 5.38071e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026019 ± 0.000186039 (W 0.000169717) | 0.043952 ± 0.00129779 (W 0.00267304) | 0.033753 ± 0.000168791 (W 7.07128e-05) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065171 ± 0.000563969 (W 0.00237266) | 0.104234 ± 0.00122031 (W 0.00246209) | 0.073537 ± 0.000223681 (W 0.00144022) | 🔵 fork 1.60× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.185365 ± 0.000333563 (W 0.00146263) | 0.185335 ± 0.000741202 (W 0.00167746) | 0.176258 ± 0.000496573 (W 0.00134371) | · | 🔴 fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.992869 ± 0.000845885 (W 0.0023009) | 0.992279 ± 0.00156016 (W 0.00157408) | 0.642357 ± 0.00260026 (W 0.00315366) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.33024 ± 0.0299545 (W 0.0169679) | 2.2823 ± 0.0450747 (W 0.0179129) | 1.3756 ± 0.00335064 (W 0.00325049) | · | 🔴 fork 1.69× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142185 ± 0.000526308 (W 0.000524117) | 0.142355 ± 0.000661596 (W 0.00113206) | 0.05915 ± 8.94446e-05 (W 0.000218726) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.539364 ± 0.0018522 (W 0.002713) | 0.535667 ± 0.00255012 (W 0.002021) | 0.258682 ± 0.000639266 (W 0.00156844) | · | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18744 ± 0.00266373 (W 0.00186185) | 1.18366 ± 0.00109237 (W 0.00201151) | 0.602152 ± 0.000957906 (W 0.0020212) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000742 ± 3.72872e-05 (W 1.79527e-05) | 0.000751 ± 1.58219e-05 (W 1.10589e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001803 ± 6.28517e-05 (W 1.9804e-05) | 0.001704 ± 5.16753e-05 (W 1.81163e-05) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003106 ± 1.73205e-05 (W 2.77489e-05) | 0.003096 ± 0.0001948 (W 2.50998e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003346 ± 0.000168306 (W 4.37858e-05) | 0.003336 ± 1.52753e-05 (W 2.19089e-05) | 0.003366 ± 7e-05 (W 3.437e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016711 ± 0.0010555 (W 3.12122e-05) | 0.01625 ± 0.000159478 (W 5.71244e-05) | 0.014147 ± 0.000160459 (W 4.64564e-05) | · | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056775 ± 0.000984065 (W 0.00333836) | 0.071694 ± 0.00142978 (W 0.00154115) | 0.037921 ± 0.000162525 (W 0.000278259) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.50× slower than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.113061 ± 0.000718919 (W 0.000206401) | 0.113221 ± 0.000458429 (W 0.00155114) | 0.105146 ± 0.000638106 (W 0.00175401) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.515079 ± 0.00411903 (W 0.0061634) | 0.511263 ± 0.000807593 (W 0.00392522) | 0.258913 ± 0.000717646 (W 0.00169031) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.23888 ± 0.00394901 (W 0.0178793) | 1.24806 ± 0.0127331 (W 0.0122119) | 0.568007 ± 0.00214488 (W 0.00136019) | · | 🔴 fork 2.18× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010469 ± 2.5632e-05 (W 7.01427e-05) | 0.01066 ± 0.000228649 (W 3.55711e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046366 ± 0.000443419 (W 0.00014881) | 0.046537 ± 0.000229993 (W 0.000237933) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131335 ± 0.00207377 (W 0.00227342) | 0.131384 ± 0.00325609 (W 0.00118103) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008265 ± 5.32948e-05 (W 5.79077e-05) | 0.008415 ± 4.00042e-05 (W 8.57456e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008275 ± 6.08276e-05 (W 3.57813e-05) | 0.008496 ± 4.50925e-05 (W 0.000119793) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.027992 ± 0.000912717 (W 0.00107144) | 0.027672 ± 0.000344848 (W 0.00139072) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.030016 ± 0.00368861 (W 0.00373508) | 0.027892 ± 0.000348282 (W 0.00084468) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.045955 ± 0.00321779 (W 0.00493639) | 0.062146 ± 0.0025639 (W 0.00210899) | - | 🔵 fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.050524 ± 0.000374607 (W 0.0033255) | 0.062406 ± 0.00214632 (W 0.00218103) | - | 🔵 fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007123 ± 0.000110151 (W 1.30384e-05) | 0.007093 ± 1.48436e-05 (W 8.8713e-05) | 0.009728 ± 1.47309e-05 (W 9.49753e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025618 ± 2.51661e-05 (W 0.000219823) | 0.05329 ± 0.000603657 (W 0.0022208) | 0.033623 ± 0.000215463 (W 0.000114723) | 🔵 fork 2.08× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.062967 ± 0.00212619 (W 0.00273604) | 0.114703 ± 0.00290523 (W 0.00312645) | 0.074238 ± 0.000172143 (W 0.000147361) | 🔵 fork 1.82× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031899 ± 0.000231467 (W 0.000134027) | 0.143978 ± 0.00119339 (W 0.00260988) | 0.021109 ± 0.000208351 (W 7.88682e-05) | 🔵 fork 4.51× faster than `faer-upstream` | 🔴 fork 1.51× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.150069 ± 0.00121132 (W 0.00338326) | 0.683072 ± 0.00561392 (W 0.0179773) | 0.140271 ± 0.000863292 (W 0.00138755) | 🔵 fork 4.55× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.402209 ± 0.0133649 (W 0.0133308) | 1.43923 ± 0.032944 (W 0.0298437) | 0.305308 ± 0.00170566 (W 0.00253031) | 🔵 fork 3.58× faster than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.018104 ± 0.000135031 (W 0.000101125) | 0.110376 ± 0.00168394 (W 0.00492166) | 0.011492 ± 2.51064e-05 (W 9.92638e-05) | 🔵 fork 6.10× faster than `faer-upstream` | 🔴 fork 1.58× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.095788 ± 0.0019674 (W 0.00224677) | 0.583316 ± 0.00616319 (W 0.0138252) | 0.29007 ± 0.000486262 (W 0.00158533) | 🔵 fork 6.09× faster than `faer-upstream` | 🔵 fork 3.03× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.198489 ± 0.00781107 (W 0.00870732) | 1.17673 ± 0.0233165 (W 0.0269693) | 0.933919 ± 0.00127312 (W 0.000746808) | 🔵 fork 5.93× faster than `faer-upstream` | 🔵 fork 4.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007885 ± 0.000189421 (W 7.31047e-05) | 0.007915 ± 0.000109986 (W 2.14079e-05) | 0.009819 ± 2.58908e-05 (W 4.73212e-05) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025848 ± 5.85947e-05 (W 0.000105572) | 0.049002 ± 0.00164522 (W 0.00332829) | 0.033602 ± 0.000205687 (W 9.95907e-05) | 🔵 fork 1.90× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065201 ± 0.00354949 (W 0.000190168) | 0.113982 ± 0.00739534 (W 0.00859657) | 0.073547 ± 0.000468915 (W 0.000190901) | 🔵 fork 1.75× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.185987 ± 0.000928709 (W 0.00149661) | 0.185275 ± 0.00152684 (W 0.00169864) | 0.1776 ± 0.000523569 (W 0.00168229) | · | · |  |
| `svd_thin/n64/b1` | 1.00759 ± 0.00202524 (W 0.00171219) | 1.0046 ± 0.00290064 (W 0.00611575) | 0.634121 ± 0.00100461 (W 0.00333002) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32654 ± 0.0453599 (W 0.0107963) | 2.31573 ± 0.044615 (W 0.0173659) | 1.32597 ± 0.00291017 (W 0.00268324) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142506 ± 0.000256321 (W 0.00135199) | 0.141764 ± 0.000351958 (W 0.00143142) | 0.05932 ± 8.92767e-05 (W 0.000151063) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.539345 ± 0.00115924 (W 0.00197565) | 0.537121 ± 0.0386772 (W 0.00227206) | 0.258471 ± 0.000761809 (W 0.00141517) | · | 🔴 fork 2.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n96/b1` | 1.18994 ± 0.000802514 (W 0.00204257) | 1.18609 ± 0.0021891 (W 0.00247102) | 0.598585 ± 0.00129912 (W 0.00215473) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000762 ± 1.1547e-05 (W 1.59154e-05) | 0.000761 ± 1e-05 (W 1.56939e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001814 ± 7.20902e-05 (W 1.53069e-05) | 0.001713 ± 3.78594e-05 (W 1.64317e-05) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002935 ± 8.94446e-05 (W 3.77796e-05) | 0.002916 ± 0.000306649 (W 2.11967e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 1.52753e-05 (W 2.86566e-05) | 0.00524 ± 3.60555e-05 (W 2.88097e-05) | 0.009037 ± 0.00017674 (W 9.02563e-05) | · | 🔵 fork 1.72× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030376 ± 0.000328311 (W 5.16072e-05) | 0.030276 ± 0.000174041 (W 6.4142e-05) | 0.050925 ± 0.00041772 (W 0.000263917) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102641 ± 0.00472803 (W 0.00364974) | 0.103974 ± 0.000302381 (W 0.000575669) | 0.137806 ± 0.000449638 (W 0.00118575) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.141704 ± 0.000847238 (W 0.000191518) | 0.141684 ± 0.000242776 (W 0.00026508) | 0.15592 ± 0.000171561 (W 0.000420741) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.637838 ± 0.000795739 (W 0.00267916) | 0.637667 ± 0.00228334 (W 0.00207559) | 0.567667 ± 0.00226044 (W 0.00190386) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.56386 ± 0.0283142 (W 0.0176741) | 1.55382 ± 0.0075199 (W 0.0191031) | 1.15699 ± 5.85947e-05 (W 0.00231757) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017402 ± 0.000253202 (W 6.59416e-05) | 0.01589 ± 6.50922e-05 (W 0.000121504) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09666 ± 0.000556849 (W 0.000416688) | 0.092322 ± 0.000255396 (W 0.000361027) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.278418 ± 0.00102282 (W 0.00192812) | 0.266737 ± 0.000773611 (W 0.00206401) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028153 ± 0.000117205 (W 5.58856e-05) | 0.028473 ± 7.02377e-05 (W 8.1561e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028383 ± 0.00344559 (W 0.000100535) | 0.028643 ± 8.44808e-05 (W 0.000113333) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.065622 ± 0.000389138 (W 0.00126706) | 0.067235 ± 0.00108806 (W 0.00183476) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.065622 ± 0.000135795 (W 0.00161814) | 0.068367 ± 0.00904664 (W 0.00216259) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.15563 ± 0.000582444 (W 0.00169193) | 0.155319 ± 0.000824043 (W 0.00198363) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.156301 ± 0.000275217 (W 0.0013577) | 0.156091 ± 0.000997827 (W 0.00136501) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013274 ± 0.000190736 (W 0.00153128) | 0.011241 ± 0.000130767 (W 0.000133005) | 0.019877 ± 2.13776e-05 (W 4.3359e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057858 ± 0.000341746 (W 0.000478089) | 0.053069 ± 0.000205516 (W 0.000450139) | 0.095819 ± 0.000263572 (W 0.00147888) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.151012 ± 0.000638411 (W 0.00149602) | 0.153757 ± 0.00204278 (W 0.00219033) | 0.243714 ± 0.000435811 (W 0.00186537) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070021 ± 0.000551 (W 0.00129038) | 0.15583 ± 0.00288907 (W 0.00952991) | 0.0537 ± 0.0895378 (W 7.56968e-05) | 🔵 fork 2.23× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.323613 ± 0.00288126 (W 0.00607713) | 0.661933 ± 0.00478461 (W 0.0153056) | 0.30622 ± 0.000282902 (W 0.00370641) | 🔵 fork 2.05× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.695586 ± 0.0526666 (W 0.0244162) | 1.3826 ± 0.0520393 (W 0.0230956) | 0.769072 ± 0.00137585 (W 0.00170674) | 🔵 fork 1.99× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.05384 ± 0.00385867 (W 0.000932279) | 0.113602 ± 0.00309246 (W 0.00484337) | 0.028804 ± 5.57704e-05 (W 0.00156616) | 🔵 fork 2.11× faster than `faer-upstream` | 🔴 fork 1.87× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.185335 ± 0.0189146 (W 0.0050029) | 0.616598 ± 0.00760181 (W 0.00669973) | 0.763142 ± 0.346667 (W 0.00153369) | 🔵 fork 3.33× faster than `faer-upstream` | 🔵 fork 4.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.380478 ± 0.00568058 (W 0.0155249) | 1.18512 ± 0.00852227 (W 0.0130666) | 2.46229 ± 0.00269028 (W 0.0031117) | 🔵 fork 3.11× faster than `faer-upstream` | 🔵 fork 6.47× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014447 ± 5.56776e-05 (W 4.51354e-05) | 0.012644 ± 0.00010583 (W 0.000130269) | 0.020388 ± 8.3865e-05 (W 9.42826e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060102 ± 0.000279376 (W 0.000203611) | 0.055102 ± 0.000459646 (W 0.00122509) | 0.093454 ± 0.00016553 (W 0.000236128) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.154487 ± 0.00039398 (W 0.000344279) | 0.158195 ± 0.00037118 (W 0.00215953) | 0.237903 ± 0.0271433 (W 0.00140136) | · | 🔵 fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.23643 ± 0.00191502 (W 0.00169176) | 0.23619 ± 0.000808741 (W 0.00175918) | 0.261487 ± 0.000186815 (W 0.00169225) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20588 ± 0.00111493 (W 0.00254263) | 1.20545 ± 0.00223886 (W 0.00765118) | 1.03371 ± 0.00121337 (W 0.00168618) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.02475 ± 0.0234588 (W 0.0228552) | 3.01265 ± 0.00743065 (W 0.0285729) | 2.53133 ± 0.00220149 (W 0.00224513) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.162012 ± 0.000162583 (W 0.00147715) | 0.162212 ± 0.000346497 (W 0.00152111) | 0.102551 ± 0.121644 (W 0.00015975) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.656813 ± 0.00201242 (W 0.00179616) | 0.657174 ± 0.00075857 (W 0.00187826) | 0.491175 ± 0.00122244 (W 0.00179348) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.54233 ± 0.00327367 (W 0.00334221) | 1.54077 ± 0.0019158 (W 0.00299239) | 1.35762 ± 0.00236142 (W 0.00212774) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 1e-05 (W 1.30384e-05) | 0.001082 ± 5.7735e-06 (W 1.78885e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 2.3094e-05 (W 3.22986e-05) | 0.002665 ± 1.1547e-05 (W 2.38789e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004909 ± 4.6188e-05 (W 3.11641e-05) | 0.004909 ± 6.08276e-06 (W 3.54006e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00526 ± 6.08276e-05 (W 3.70162e-05) | 0.00527 ± 4.2194e-05 (W 2.61572e-05) | 0.008966 ± 0.000104484 (W 7.10634e-05) | · | 🔵 fork 1.70× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030176 ± 4.95681e-05 (W 0.000153611) | 0.030287 ± 0.000135537 (W 4.86826e-05) | 0.051746 ± 0.00138218 (W 0.00031866) | · | 🔵 fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.112339 ± 0.00119107 (W 0.00207311) | 0.111358 ± 0.00249157 (W 0.00556604) | 0.140101 ± 0.000347031 (W 0.000322771) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142115 ± 0.00029896 (W 0.00157646) | 0.141543 ± 0.000179574 (W 0.00160505) | 0.156903 ± 0.000872963 (W 0.00119633) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.6444 ± 0.00465686 (W 0.00477614) | 0.643479 ± 0.00302543 (W 0.00361891) | 0.541699 ± 0.0035487 (W 0.00309725) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.5669 ± 0.0170444 (W 0.0194846) | 1.58927 ± 0.00869699 (W 0.0134851) | 1.04082 ± 0.00254047 (W 0.00295966) | · | 🔴 fork 1.51× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017533 ± 0.000207052 (W 7.65193e-05) | 0.015859 ± 0.000190579 (W 8.43996e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096961 ± 0.000654079 (W 0.00148705) | 0.091851 ± 0.000384808 (W 0.00142619) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.278939 ± 0.000603167 (W 0.00243176) | 0.266376 ± 0.00209015 (W 0.00223052) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028173 ± 3.60555e-05 (W 0.00125358) | 0.028523 ± 0.000107858 (W 0.00157209) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028342 ± 8.77895e-05 (W 4.76571e-05) | 0.028393 ± 5.7735e-06 (W 5.1002e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.042379 ± 0.00033925 (W 0.000728328) | 0.071684 ± 0.000430373 (W 0.00152301) | - | 🔵 fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.042429 ± 2.08167e-05 (W 0.000710923) | 0.071183 ± 0.000716704 (W 0.00246706) | - | 🔵 fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.091951 ± 0.000546371 (W 0.00110186) | 0.163294 ± 0.00250341 (W 0.000840078) | - | 🔵 fork 1.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.09164 ± 0.000342842 (W 0.000797294) | 0.162743 ± 0.00121285 (W 0.0023016) | - | 🔵 fork 1.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013105 ± 0.000113006 (W 0.000108283) | 0.011422 ± 0.00225598 (W 0.000161546) | 0.019847 ± 5.50757e-05 (W 0.000139356) | · | 🔵 fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057758 ± 0.00017091 (W 0.000269022) | 0.052779 ± 0.000213909 (W 0.000293806) | 0.096389 ± 0.000873074 (W 0.000506209) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.150591 ± 0.000203971 (W 0.00162117) | 0.166259 ± 0.000920063 (W 0.00428362) | 0.245397 ± 0.0010905 (W 0.00195222) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070041 ± 0.000178298 (W 0.00047179) | 0.184343 ± 0.00411358 (W 0.00891271) | 0.05358 ± 0.0898795 (W 0.00131408) | 🔵 fork 2.63× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.316139 ± 0.000538462 (W 0.00619401) | 0.878065 ± 0.0139047 (W 0.0146185) | 0.285351 ± 0.00410652 (W 0.00193796) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.7088 ± 0.0518726 (W 0.0179201) | 1.84663 ± 0.0758645 (W 0.0257319) | 0.704472 ± 0.00135222 (W 0.00185321) | 🔵 fork 2.61× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n32/b1` | 0.058208 ± 0.000698889 (W 0.00111483) | 0.142335 ± 0.00231968 (W 0.00336074) | 0.028663 ± 0.000106927 (W 8.49606e-05) | 🔵 fork 2.45× faster than `faer-upstream` | 🔴 fork 2.03× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.185345 ± 0.0173323 (W 0.00200469) | 0.772559 ± 0.011107 (W 0.0206572) | 0.763372 ± 0.346146 (W 0.00105008) | 🔵 fork 4.17× faster than `faer-upstream` | 🔵 fork 4.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.396789 ± 0.00523631 (W 0.0069063) | 1.53477 ± 0.0103698 (W 0.0148574) | 2.45908 ± 0.00283831 (W 0.00457108) | 🔵 fork 3.87× faster than `faer-upstream` | 🔵 fork 6.20× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014678 ± 0.000141811 (W 0.000210156) | 0.012824 ± 0.000222336 (W 0.000107621) | 0.020218 ± 7.53459e-05 (W 6.86826e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059801 ± 0.000876774 (W 0.000314121) | 0.055152 ± 0.000202057 (W 0.00041733) | 0.093374 ± 0.000358483 (W 0.0013429) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.155149 ± 0.000319511 (W 0.00176577) | 0.168514 ± 0.00316159 (W 0.00341209) | 0.236981 ± 0.000574786 (W 0.00125179) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.23657 ± 0.00287292 (W 0.00282282) | 0.235228 ± 0.00143273 (W 0.0017166) | 0.262889 ± 2.88675e-05 (W 0.00179402) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21196 ± 0.00163741 (W 0.00249564) | 1.22182 ± 0.00439775 (W 0.00506141) | 0.995955 ± 0.00270389 (W 0.00229308) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.97742 ± 0.021427 (W 0.0263964) | 3.10753 ± 0.00920147 (W 0.0159132) | 2.35274 ± 0.00311379 (W 0.00432167) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.162382 ± 0.000806773 (W 0.00158536) | 0.162363 ± 0.00110248 (W 0.00140449) | 0.10206 ± 0.122664 (W 0.00194984) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.6606 ± 0.00285978 (W 0.00205776) | 0.657214 ± 0.00525427 (W 0.00219971) | 0.490594 ± 0.000396031 (W 0.00173239) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.53817 ± 0.003523 (W 0.00206467) | 1.54069 ± 0.00160437 (W 0.00308779) | 1.35427 ± 0.00620776 (W 0.00119642) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001082 ± 2.51661e-05 (W 2.60768e-05) | 0.001072 ± 1.52753e-05 (W 2.07364e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002675 ± 1.1547e-05 (W 2.30217e-05) | 0.002674 ± 2.00083e-05 (W 3.11448e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004939 ± 1.76163e-05 (W 1.61307e-05) | 0.004869 ± 3.05505e-05 (W 0.00155722) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 6.1101e-05 (W 3.78153e-05) | 0.00527 ± 4.93288e-05 (W 1.81659e-05) | 0.007915 ± 0.000180484 (W 5.60116e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029916 ± 0.000175784 (W 7.84219e-05) | 0.030026 ± 0.000299962 (W 8.72651e-05) | 0.043341 ± 0.000233582 (W 0.000164916) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.101619 ± 0.00349636 (W 0.00325088) | 0.102952 ± 0.000766501 (W 0.00142643) | 0.126065 ± 0.00100235 (W 0.00165413) | · | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.141433 ± 8.24035e-05 (W 0.00171089) | 0.141574 ± 0.000265141 (W 0.00135485) | 0.154127 ± 6.65833e-05 (W 0.0012393) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.641124 ± 0.00294574 (W 0.0018436) | 0.641945 ± 0.00522976 (W 0.0032102) | 0.556747 ± 0.0011004 (W 0.00150552) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.55751 ± 0.0124206 (W 0.0164614) | 1.53842 ± 0.00332036 (W 0.0182942) | 1.14173 ± 0.000924849 (W 0.000694564) | · | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015699 ± 8.0829e-05 (W 0.000107955) | 0.01587 ± 0.000121533 (W 8.99461e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090338 ± 0.000282194 (W 0.000304471) | 0.090137 ± 0.000488714 (W 0.00138343) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264843 ± 0.000222711 (W 0.00194265) | 0.263841 ± 0.000381044 (W 0.00152223) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027892 ± 0.000117898 (W 6.84493e-05) | 0.028242 ± 9.60052e-05 (W 7.56194e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027972 ± 0.000146289 (W 0.00124542) | 0.028293 ± 0.000100732 (W 9.81326e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.077294 ± 0.00146262 (W 0.0047015) | 0.066684 ± 0.000164621 (W 0.00254067) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.069569 ± 0.00445609 (W 0.0036175) | 0.066954 ± 0.000833093 (W 0.00172335) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.164957 ± 0.000492951 (W 0.00351908) | 0.154057 ± 0.00047875 (W 0.00192105) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.164055 ± 0.00335762 (W 0.0032557) | 0.154448 ± 0.000194569 (W 0.000658738) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011602 ± 3.23574e-05 (W 8.39297e-05) | 0.011401 ± 9.13072e-05 (W 8.24942e-05) | 0.017462 ± 7.93725e-05 (W 4.95106e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051266 ± 0.000202609 (W 0.000237837) | 0.051536 ± 0.000283479 (W 0.00077455) | 0.08585 ± 0.000379018 (W 0.000292516) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136965 ± 0.000510871 (W 0.00132813) | 0.151111 ± 0.00104316 (W 0.00107654) | 0.22575 ± 0.000983682 (W 0.00210299) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068288 ± 8.53834e-05 (W 0.00170201) | 0.164707 ± 0.0102803 (W 0.0135377) | 0.04826 ± 0.000126361 (W 9.44987e-05) | 🔵 fork 2.41× faster than `faer-upstream` | 🔴 fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.299508 ± 0.00163607 (W 0.00339393) | 0.66038 ± 0.0033043 (W 0.0088371) | 0.288748 ± 0.00107429 (W 0.00180096) | 🔵 fork 2.20× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.684775 ± 0.046395 (W 0.0196979) | 1.39764 ± 0.0629191 (W 0.0160189) | 0.734578 ± 0.00201051 (W 0.00133572) | 🔵 fork 2.04× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.034174 ± 0.000191312 (W 9.95992e-05) | 0.098573 ± 0.00387195 (W 0.00440814) | 0.026149 ± 8.12835e-05 (W 4.0978e-05) | 🔵 fork 2.88× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.157353 ± 0.000651523 (W 0.00241308) | 0.524527 ± 0.00786487 (W 0.0110975) | 0.757922 ± 0.00211343 (W 0.00185301) | 🔵 fork 3.33× faster than `faer-upstream` | 🔵 fork 4.82× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.346295 ± 0.0069061 (W 0.0113915) | 1.03057 ± 0.0051526 (W 0.0148613) | 2.44804 ± 0.00208448 (W 0.00422416) | 🔵 fork 2.98× faster than `faer-upstream` | 🔵 fork 7.07× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012794 ± 8.67583e-05 (W 0.000145362) | 0.012533 ± 0.000104644 (W 0.000131823) | 0.017232 ± 2.51661e-05 (W 7.34847e-05) | · | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053579 ± 0.000477441 (W 0.000433842) | 0.053459 ± 0.000227355 (W 0.000187132) | 0.083396 ± 0.000232143 (W 0.000285425) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.140972 ± 0.000413962 (W 0.00139723) | 0.156191 ± 0.00361248 (W 0.00332759) | 0.219178 ± 0.000155885 (W 0.00158799) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.233675 ± 0.00131727 (W 0.00196186) | 0.233144 ± 0.000698634 (W 0.00170598) | 0.257379 ± 0.000504084 (W 0.00124541) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2351 ± 0.00401552 (W 0.00359242) | 1.23831 ± 0.00795013 (W 0.00461735) | 1.01058 ± 0.00146383 (W 0.00117602) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.97271 ± 0.00597484 (W 0.0249495) | 2.96038 ± 0.00677956 (W 0.0101184) | 2.515 ± 0.00324661 (W 0.00766955) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.159558 ± 0.000611164 (W 0.00143857) | 0.160438 ± 0.000208928 (W 0.00179338) | 0.100547 ± 0.000102715 (W 0.00132307) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.632468 ± 0.00131931 (W 0.00199378) | 0.63344 ± 0.00168206 (W 0.00224106) | 0.481768 ± 0.00154012 (W 0.00189089) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51036 ± 0.00236097 (W 0.00281465) | 1.51184 ± 0.00473021 (W 0.00215936) | 1.33929 ± 0.00233076 (W 0.00224091) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001202 ± 2.02567e-05 (W 2.0693e-05) | 0.001193 ± 1.51767e-05 (W 2.20499e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002965 ± 0.000234736 (W 1.68315e-05) | 0.002936 ± 1.00167e-05 (W 2.72452e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00531 ± 0.000172975 (W 1.59154e-05) | 0.0053 ± 0.000136504 (W 1.67332e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 7.0946e-05 (W 5.19827e-05) | 0.00522 ± 1.51767e-05 (W 5.42421e-05) | 0.008165 ± 5.7735e-07 (W 8.58487e-05) | · | 🔵 fork 1.57× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030046 ± 0.000350828 (W 7.41101e-05) | 0.029875 ± 0.00017406 (W 5.20605e-05) | 0.04322 ± 0.000159124 (W 7.57839e-05) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111438 ± 0.00200516 (W 0.00409368) | 0.111718 ± 0.000678652 (W 0.00371974) | 0.126606 ± 0.000675004 (W 0.0016296) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141694 ± 0.000172434 (W 0.00163819) | 0.141543 ± 0.000184609 (W 0.00153957) | 0.154959 ± 0.000771089 (W 0.00117521) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.645262 ± 0.00500228 (W 0.00446689) | 0.646464 ± 0.00232972 (W 0.0045728) | 0.530238 ± 0.00144704 (W 0.00181728) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53739 ± 0.00743693 (W 0.0278859) | 1.60004 ± 0.00958171 (W 0.0163338) | 1.02969 ± 0.0247573 (W 0.00375215) | · | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01588 ± 0.000213823 (W 4.1833e-05) | 0.01592 ± 0.000126623 (W 0.000142735) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090068 ± 0.000344848 (W 0.00147166) | 0.089957 ± 0.000331744 (W 0.00149458) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264432 ± 0.000842824 (W 0.00178402) | 0.264232 ± 0.000350828 (W 0.00157985) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027912 ± 7e-05 (W 5.19615e-05) | 0.028093 ± 6.69104e-05 (W 0.000106395) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027932 ± 2.51661e-05 (W 5.19538e-05) | 0.028192 ± 2.47049e-05 (W 0.000242323) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.052818 ± 0.00187012 (W 0.00167208) | 0.070662 ± 0.000307208 (W 0.00173357) | - | 🔵 fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.050714 ± 0.000291994 (W 0.00193639) | 0.071083 ± 0.000898334 (W 0.00213923) | - | 🔵 fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.102341 ± 0.00163153 (W 0.00314199) | 0.16114 ± 0.000993291 (W 0.00228037) | - | 🔵 fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.103773 ± 0.00200352 (W 0.0028034) | 0.160229 ± 0.000938969 (W 0.00150692) | - | 🔵 fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011571 ± 0.000193993 (W 0.000116255) | 0.011471 ± 4.16333e-05 (W 9.36173e-05) | 0.017463 ± 0.000155618 (W 0.00138487) | · | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051225 ± 0.000208663 (W 0.000193027) | 0.051376 ± 0.000211795 (W 0.000211849) | 0.08572 ± 0.000110636 (W 0.000206139) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136554 ± 0.000332591 (W 0.00161517) | 0.163785 ± 0.00128465 (W 0.00415645) | 0.224588 ± 0.000481841 (W 0.00143923) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.068799 ± 0.000393005 (W 0.0016321) | 0.186578 ± 0.00217706 (W 0.00635946) | 0.048179 ± 0.000127163 (W 4.23226e-05) | 🔵 fork 2.71× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.306962 ± 0.00480376 (W 0.00537613) | 0.870932 ± 0.0100449 (W 0.011799) | 0.264433 ± 0.000213909 (W 0.001926) | 🔵 fork 2.84× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.701287 ± 0.0575924 (W 0.0218515) | 1.82702 ± 0.0740277 (W 0.0342873) | 0.671822 ± 0.000982293 (W 0.00152818) | 🔵 fork 2.61× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n32/b1` | 0.034233 ± 0.000329485 (W 0.00027608) | 0.130282 ± 0.00118339 (W 0.00700236) | 0.026058 ± 7.54983e-05 (W 7.89132e-05) | 🔵 fork 3.81× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.167382 ± 0.000689017 (W 0.00350442) | 0.697339 ± 0.00352875 (W 0.0165637) | 0.756279 ± 0.000440576 (W 0.00211154) | 🔵 fork 4.17× faster than `faer-upstream` | 🔵 fork 4.52× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.357636 ± 0.00266004 (W 0.00413339) | 1.34409 ± 0.0285315 (W 0.032458) | 2.44781 ± 0.00434513 (W 0.00294416) | 🔵 fork 3.76× faster than `faer-upstream` | 🔵 fork 6.84× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012713 ± 9.50631e-05 (W 0.00010482) | 0.012563 ± 0.000110546 (W 3.53864e-05) | 0.017262 ± 3.78594e-05 (W 7.97446e-05) | · | 🔵 fork 1.36× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053329 ± 0.000240646 (W 0.000156429) | 0.05354 ± 0.000263022 (W 0.000208638) | 0.082805 ± 0.000185689 (W 0.000282937) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.140592 ± 0.000628077 (W 0.00155627) | 0.167121 ± 0.00158816 (W 0.00308921) | 0.218918 ± 6e-05 (W 0.00166216) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.233024 ± 0.000747008 (W 0.00167818) | 0.232594 ± 0.0013711 (W 0.00238819) | 0.259253 ± 0.000880457 (W 0.00124179) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24384 ± 0.00153764 (W 0.00354872) | 1.25644 ± 0.00565012 (W 0.00732433) | 0.973062 ± 0.000964072 (W 0.00270449) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96712 ± 0.0182457 (W 0.012362) | 3.0861 ± 0.0141672 (W 0.00989408) | 2.33569 ± 0.00329964 (W 0.00434941) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.159918 ± 0.000431868 (W 0.000930549) | 0.1609 ± 0.000991037 (W 0.000657998) | 0.100537 ± 0.000147886 (W 0.00170782) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.632719 ± 0.00241416 (W 0.001474) | 0.631737 ± 0.00370978 (W 0.00209754) | 0.478632 ± 0.00135092 (W 0.0018163) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51622 ± 0.00591345 (W 0.00250061) | 1.51465 ± 0.00268756 (W 0.00292676) | 1.33731 ± 0.000225456 (W 0.00256065) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001222 ± 2.6839e-05 (W 1.93985e-05) | 0.001203 ± 2.00083e-05 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003016 ± 0.00015201 (W 2.09093e-05) | 0.002966 ± 2.08167e-05 (W 3.09871e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0053 ± 0.000263122 (W 2.07364e-05) | 0.00524 ± 5.32948e-05 (W 2.42343e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
