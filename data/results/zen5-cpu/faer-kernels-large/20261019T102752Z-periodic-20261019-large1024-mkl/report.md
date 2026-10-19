# `faer-kernels-large` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a5e6b7d239466fb0d685edc20db6c4f3f3a71411`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `6bea2ec5213fedb9bac4e974d804fec5ce03ee05`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `25dd94085a1ca1765a59d85901089cdf3a1a2756abb3ff4fbaf7f780363f7a4a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T13:00:41.576001Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels-large --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-large,gemm-large,linalg-boundary --shapes 1024,1024x1024x1024,255,257,511,513 --threads 4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label periodic-20261019-large1024-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels-large/20261019T102752Z-periodic-20261019-large1024-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.81%, worst 911.39% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 104 of 1144 engine cells exceed 5% and carry `!`; median within-process relative SD 0.50%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 7.57713 ± 0.1174 (W 0.027742) | 7.88593 ± 0.0370801 (W 0.105828) | 8.49266 ± 0.109432 (W 0.0510885) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `eigh/n1024/b1` | 121.33 ± 0.608679 (W 0.175035) | 120.67 ± 0.569796 (W 0.175216) | 124.533 ± 0.216968 (W 0.214745) | · | · |  |
| `full_piv_lu/n1024/b1` | 71.772 ± 3.161 (W 0.301842) | 79.1019 ± 1.46715 (W 1.50999) | - | 🔵 fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n1024/b1` | 21.8639 ± 3.18688 (W 0.121354) | 27.3468 ± 0.0931216 (W 0.22481) | 11.5531 ± 1.86292 (W 0.0501574) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 1.89× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 53.9912 ± 0.141488 (W 0.292093) | 64.4269 ± 0.386998 (W 0.247828) | 61.006 ± 0.107759 (W 0.088776) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 24.1668 ± 0.0673901 (W 0.0660023) | 83.4272 ± 0.561561 (W 0.363686) | 21.0782 ± 0.114993 (W 0.0602124) | 🔵 fork 3.45× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `solve/n1024/b1` | 22.7434 ± 0.076594 (W 0.111946) | 27.9411 ± 0.160882 (W 0.153928) | 11.4496 ± 0.0777719 (W 0.0687068) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 307.581 ± 0.743309 (W 0.903143) | 307.857 ± 0.641231 (W 0.620679) | 298.723 ± 0.982918 (W 3.61843) | · | · |  |
| `svd_values/n1024/b1` | 212.314 ± 0.465191 (W 1.38257) | 212.463 ± 1.18328 (W 1.26643) | 123.094 ± 2.77433 (W 0.418588) | · | 🔴 fork 1.72× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.10145 ± 0.0118252 (W 0.00758198) | 0.117479 ± 0.0107087 (W 0.00197049) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 6.30864 ± 0.0925881 (W 0.0447155) | 6.63871 ± 0.0976154 (W 0.123917) | 5.25332 ± 0.0407106 (W 0.0230328) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `eigh/n1024/b1` | 99.6235 ± 0.607837 (W 0.282374) | 104.253 ± 0.814223 (W 0.738147) | 85.3245 ± 0.144729 (W 0.32156) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 62.6467 ± 0.235613 (W 0.303024) | 69.7187 ± 1.15327 (W 0.843559) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 19.317 ± 3.27534 (W 0.112217) | 25.4425 ± 0.344617 (W 0.144953) | 7.02279 ± 1.73051 (W 0.0152352) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 2.75× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 40.2525 ± 4.22521 (W 0.249974) | 61.9358 ± 4.9226 (W 1.43155) | 45.2009 ± 0.166104 (W 0.115101) | 🔵 fork 1.54× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 18.7741 ± 0.0722069 (W 0.0905416) | 86.7687 ± 0.461051 (W 0.423738) | 14.5395 ± 0.066508 (W 0.0223695) | 🔵 fork 4.62× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `solve/n1024/b1` | 19.8981 ± 0.265076 (W 0.222817) | 26.082 ± 0.172215 (W 0.159411) | 6.9728 ± 0.0474491 (W 0.050443) | 🔵 fork 1.31× faster than `faer-upstream` | 🔴 fork 2.85× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 262.065 ± 0.506287 (W 1.29179) | 271.922 ± 0.187805 (W 1.62297) | 232.92 ± 0.541443 (W 0.557454) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 198.185 ± 0.208055 (W 0.729671) | 197.541 ± 0.544788 (W 0.99118) | 94.535 ± 0.318045 (W 0.148314) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.106589 ± 0.00500014 (W 0.00254318) | 0.105356 ± 0.000638029 (W 0.00186984) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 5.48617 ± 0.0240594 (W 0.0294738) | 5.80179 ± 0.0763503 (W 0.114307) | 6.80536 ± 0.208377 (W 0.0312835) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n1024/b1` | 119.107 ± 0.641584 (W 0.130317) | 118.459 ± 1.14236 (W 0.190033) | 122.072 ± 0.515466 (W 0.094872) | · | · |  |
| `full_piv_lu/n1024/b1` | 69.5314 ± 0.487457 (W 0.478154) | 69.3873 ± 0.216365 (W 0.31945) | - | · | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 14.315 ± 2.88392 (W 0.11006) | 14.9213 ± 2.97208 (W 0.0412936) | 9.59539 ± 0.0461174 (W 0.0200093) | · | 🔴 fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 51.7579 ± 0.139772 (W 0.120019) | 56.7548 ± 0.112203 (W 0.203291) | 63.1727 ± 0.0745951 (W 0.0585486) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 21.813 ± 0.137945 (W 0.0421032) | 26.884 ± 0.108266 (W 0.116374) | 19.2834 ± 0.122013 (W 0.014661) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `solve/n1024/b1` | 20.3873 ± 0.0552586 (W 0.152472) | 20.781 ± 0.0668836 (W 0.132644) | 9.6702 ± 0.0777641 (W 0.0163325) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 299.427 ± 0.717824 (W 1.93955) | 300.505 ± 0.676582 (W 0.639632) | 278.21 ± 1.44814 (W 0.911033) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 205.156 ± 0.503735 (W 0.655461) | 205.008 ± 0.611409 (W 0.884155) | 123.744 ± 0.494027 (W 0.883467) | · | 🔴 fork 1.66× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.124021 ± 0.0144079 (W 0.00340402) | 0.12233 ± 0.00731222 (W 0.00143159) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 4.20698 ± 0.055219 (W 0.0353814) | 4.49371 ± 0.0667168 (W 0.0926838) | 3.99569 ± 0.0703684 (W 0.0168637) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.05× slower than `lapack-mkl` |  |
| `eigh/n1024/b1` | 97.6296 ± 0.655859 (W 0.125677) | 102.25 ± 0.939249 (W 0.535116) | 83.715 ± 0.173751 (W 0.109714) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 60.3385 ± 0.130491 (W 0.198191) | 60.4452 ± 0.190317 (W 0.343949) | - | · | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 16.6357 ± 13.4379 (W 2.34517) | 12.8115 ± 0.132684 (W 0.180936) | 5.98959 ± 0.00653849 (W 0.020284) | · | 🔴 fork 2.78× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 37.4462 ± 4.30307 (W 0.128737) | 53.7147 ± 4.78948 (W 1.02461) | 48.7408 ± 0.201576 (W 0.0710753) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 17.0067 ± 0.0867967 (W 0.0638701) | 28.1843 ± 0.269185 (W 0.587781) | 13.3225 ± 0.0879411 (W 0.0177119) | 🔵 fork 1.66× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `solve/n1024/b1` | 17.279 ± 0.0787956 (W 0.119962) | 18.5991 ± 0.192132 (W 0.303459) | 6.0321 ± 0.0616029 (W 0.0129704) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 2.86× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 255.167 ± 1.05619 (W 1.22309) | 264.474 ± 0.603483 (W 1.6167) | 213.906 ± 1.52252 (W 0.508223) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 189.886 ± 0.83053 (W 0.778705) | 190.865 ± 0.454983 (W 0.593019) | 93.1889 ± 0.239774 (W 0.106597) | · | 🔴 fork 2.04× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.130692 ± 0.00145028 (W 0.00464863) | 0.132977 ± 0.00563702 (W 0.0055034) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 19.9289 ± 0.417691 (W 0.294476) | 20.2354 ± 0.108344 (W 0.128848) | 21.5736 ± 0.0389505 (W 0.0433971) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n1024/b1` | 257.427 ± 0.646202 (W 0.650999) | 257.744 ± 1.60832 (W 0.863258) | 349.751 ± 1.61066 (W 3.13587) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 165.797 ± 0.355307 (W 1.29414) | 169.363 ± 1.15553 (W 0.648988) | - | · | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 41.2616 ± 0.0584076 (W 0.194891) | 44.3971 ± 0.270447 (W 0.292365) | 40.8087 ± 0.0611773 (W 0.0885775) | 🔵 fork 1.08× faster than `faer-upstream` | · |  |
| `qr/n1024/b1` | 154.423 ± 0.308908 (W 0.354066) | 165.263 ± 0.972065 (W 0.472055) | 183.256 ± 0.253447 (W 0.157991) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 70.3988 ± 0.246632 (W 0.255587) | 121.396 ± 0.171236 (W 1.3454) | 74.1815 ± 0.0450853 (W 0.146069) | 🔵 fork 1.72× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `solve/n1024/b1` | 41.2795 ± 0.167105 (W 0.185671) | 43.9014 ± 0.2194 (W 0.530323) | 38.6271 ± 0.0378346 (W 0.0566772) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 630.167 ± 2.29697 (W 1.84515) | 631.764 ± 0.340584 (W 1.02238) | 737.874 ± 1.99734 (W 2.41055) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 398.257 ± 0.764781 (W 1.41527) | 397.129 ± 1.10873 (W 1.17506) | 361.681 ± 1.51181 (W 0.99691) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.289409 ± 0.0293582 (W 0.00814695) | 0.304768 ± 0.0105849 (W 0.00687053) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 13.7957 ± 0.180398 (W 0.220791) | 13.9123 ± 0.269402 (W 0.181615) | 12.9329 ± 0.0629179 (W 0.0810894) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n1024/b1` | 180.607 ± 0.345378 (W 0.354322) | 187.262 ± 0.899116 (W 1.40076) | 218.056 ± 0.259649 (W 0.606367) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 109.286 ± 0.388617 (W 0.45755) | 113.106 ± 1.34046 (W 0.865551) | - | · | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 29.8786 ± 0.116361 (W 0.173108) | 32.3853 ± 0.267372 (W 1.24312) | 23.6354 ± 0.076001 (W 0.125191) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `qr/n1024/b1` | 93.7252 ± 0.172111 (W 0.273102) | 119.903 ± 0.259224 (W 3.20263) | 104.329 ± 0.203743 (W 0.209449) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 46.7193 ± 0.0875712 (W 0.086292) | 111.131 ± 1.47738 (W 1.77475) | 42.8304 ± 0.0585131 (W 0.109672) | 🔵 fork 2.38× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `solve/n1024/b1` | 29.9676 ± 0.25873 (W 0.219698) | 33.1121 ± 0.427915 (W 0.498664) | 23.0599 ± 0.126885 (W 0.0999658) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 439.824 ± 1.00099 (W 2.55707) | 454.572 ± 0.617722 (W 3.4515) | 472.596 ± 7.08709 (W 6.37209) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 295.847 ± 3.87166 (W 0.613561) | 296.204 ± 3.31238 (W 0.681692) | 231.527 ± 1.08949 (W 0.677082) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.231902 ± 0.0058751 (W 0.0125333) | 0.251778 ± 0.00971274 (W 0.00966057) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 17.2074 ± 0.0172435 (W 0.0699208) | 17.2772 ± 0.0194286 (W 0.0525644) | 19.4387 ± 0.198496 (W 0.0698012) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `eigh/n1024/b1` | 254.926 ± 0.216439 (W 0.519282) | 254.905 ± 0.739304 (W 0.652646) | 346.267 ± 0.463138 (W 0.674546) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 160.008 ± 1.76117 (W 0.916758) | 159.913 ± 0.636062 (W 1.24338) | - | · | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 36.4568 ± 0.0577768 (W 0.135618) | 36.5199 ± 0.079361 (W 0.0761861) | 37.5107 ± 0.00907401 (W 0.0453333) | · | · |  |
| `qr/n1024/b1` | 149.633 ± 0.315012 (W 0.330227) | 156.868 ± 0.256124 (W 0.29461) | 185.212 ± 0.393808 (W 0.406171) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 66.0996 ± 0.135822 (W 0.134616) | 72.8216 ± 0.266598 (W 0.0968975) | 71.1761 ± 0.151509 (W 0.0747703) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `solve/n1024/b1` | 36.6102 ± 0.0577256 (W 0.120606) | 36.6626 ± 0.101437 (W 0.128175) | 37.7928 ± 1.31679 (W 0.0432453) | · | · | `!` between-start range over 5% |
| `svd_thin/n1024/b1` | 623.885 ± 0.542033 (W 2.07109) | 625.502 ± 0.454139 (W 19.9329) | 713.938 ± 4.84745 (W 1.58268) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 389.75 ± 1.62055 (W 0.690413) | 392.3 ± 0.548489 (W 0.999038) | 362.47 ± 1.88692 (W 0.726422) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.328084 ± 0.00485287 (W 0.0052557) | 0.330375 ± 0.0111712 (W 0.00501648) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n1024/b1` | 11.1202 ± 0.0362727 (W 0.0506561) | 11.2404 ± 0.031037 (W 0.0446225) | 11.5554 ± 0.0265994 (W 0.0352018) | · | · |  |
| `eigh/n1024/b1` | 178.337 ± 0.0772287 (W 0.683194) | 186.189 ± 2.84936 (W 1.59014) | 216.613 ± 0.44296 (W 0.549404) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `full_piv_lu/n1024/b1` | 104.779 ± 0.392223 (W 0.719512) | 105.147 ± 1.44779 (W 1.05113) | - | · | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 25.0694 ± 0.115015 (W 0.103369) | 25.3987 ± 0.0441622 (W 0.131196) | 21.3606 ± 0.275043 (W 0.078085) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `qr/n1024/b1` | 88.7424 ± 0.236315 (W 0.309197) | 114.443 ± 1.28378 (W 2.21691) | 105.419 ± 0.085908 (W 0.830492) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n1024/b1` | 43.3224 ± 0.185495 (W 0.0788142) | 60.4099 ± 0.779154 (W 1.08096) | 40.4161 ± 0.027004 (W 0.0685457) | 🔵 fork 1.39× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `solve/n1024/b1` | 25.1836 ± 0.0429346 (W 0.896621) | 25.263 ± 0.101751 (W 0.131557) | 20.9002 ± 0.240739 (W 0.0579817) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n1024/b1` | 432.168 ± 0.626629 (W 3.04434) | 447.177 ± 1.15279 (W 5.36292) | 463.418 ± 3.06665 (W 0.689204) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/n1024/b1` | 289.985 ± 3.58834 (W 0.861367) | 289.42 ± 3.4056 (W 0.866515) | 232.026 ± 1.54341 (W 3.09559) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `triangular_solve/n1024/b1` | 0.261507 ± 0.011002 (W 0.00851273) | 0.264853 ± 0.0158835 (W 0.00714612) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/1024`, `triangular_solve/1024`.

## gemm-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6185 ± 0.0241235 (W 0.052072) | 17.5951 ± 0.0144996 (W 0.0146175) | 20.8022 ± 0.0682066 (W 0.0263141) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.06123 ± 0.0144849 (W 0.00732733) | 9.05687 ± 0.0494101 (W 0.0153638) | 11.6533 ± 0.0888838 (W 0.0605282) | · | 🔵 fork 1.29× faster than `lapack-mkl` |  |

## gemm-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6287 ± 0.0348035 (W 0.0218284) | 17.6188 ± 0.017377 (W 0.0168451) | 20.8939 ± 0.210756 (W 0.0354465) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.06154 ± 0.0108065 (W 0.0241781) | 9.05114 ± 0.0150515 (W 0.0131285) | 11.4291 ± 0.0938419 (W 0.0323609) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |

## gemm-large, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 69.8852 ± 0.0807466 (W 0.0233674) | 70.0261 ± 0.111781 (W 0.0346504) | 110.876 ± 0.465132 (W 0.090929) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## gemm-large, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 35.3159 ± 0.0448174 (W 0.0389745) | 35.3474 ± 0.0204353 (W 0.0488856) | 43.7981 ± 0.575375 (W 0.195013) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## gemm-large, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 69.809 ± 0.173471 (W 0.0725536) | 69.9417 ± 0.135982 (W 0.0220036) | 110.682 ± 0.755867 (W 0.122213) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## gemm-large, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 35.2641 ± 0.0838383 (W 0.025442) | 35.3382 ± 0.045692 (W 0.0411862) | 43.6823 ± 0.8896 (W 0.0729657) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-boundary, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.366224 ± 0.0133441 (W 0.0214598) | 0.368308 ± 0.00957937 (W 0.0252125) | 0.309049 ± 0.00302764 (W 0.00775708) | · | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n257/b1` | 0.326398 ± 0.0094887 (W 0.00951585) | 0.3862 ± 0.00545522 (W 0.0280623) | 0.319257 ± 0.00227434 (W 0.00706911) | 🔵 fork 1.18× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `cholesky/n511/b1` | 1.15738 ± 0.0217701 (W 0.0231616) | 1.2634 ± 0.00289046 (W 0.0273761) | 1.48102 ± 0.0202668 (W 0.0101379) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `cholesky/n513/b1` | 1.10201 ± 0.0146634 (W 0.0095443) | 1.20144 ± 0.0336978 (W 0.0294104) | 1.55002 ± 0.00976726 (W 0.0172702) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n255/b1` | 7.26255 ± 0.03223 (W 0.0211013) | 7.22377 ± 0.0353081 (W 0.0131689) | 4.4765 ± 0.015954 (W 0.00608464) | · | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 7.22245 ± 0.046317 (W 0.0446665) | 7.20634 ± 0.0180561 (W 0.0400381) | 4.56444 ± 0.006344 (W 0.00576637) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 26.6357 ± 0.0895192 (W 0.0529455) | 26.536 ± 0.19118 (W 0.074375) | 19.4996 ± 0.0210035 (W 0.0370787) | · | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `eigh/n513/b1` | 27.2756 ± 0.0238954 (W 0.0610218) | 27.2338 ± 0.1184 (W 0.0659756) | 19.9146 ± 0.0729481 (W 0.0376264) | · | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 2.73337 ± 0.0134952 (W 0.0116619) | 2.66957 ± 0.0113426 (W 0.00559711) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.99371 ± 0.00605493 (W 0.0154364) | 1.92144 ± 0.00898867 (W 0.00462361) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 17.4213 ± 0.634974 (W 0.174693) | 17.1707 ± 0.694599 (W 0.0391968) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n513/b1` | 11.3233 ± 0.0580032 (W 0.110214) | 10.9988 ± 0.0178097 (W 0.0990042) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 0.978543 ± 0.113078 (W 0.00340585) | 1.05651 ± 0.0276575 (W 0.0262216) | 0.386249 ± 0.00416726 (W 0.00266911) | · | 🔴 fork 2.53× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n257/b1` | 0.923552 ± 0.156077 (W 0.0120007) | 1.03737 ± 0.145485 (W 0.0153293) | 0.559202 ± 0.0930351 (W 0.00397933) | · | 🔴 fork 1.65× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n511/b1` | 4.9165 ± 0.0913872 (W 0.0743633) | 4.77784 ± 0.0464974 (W 0.0586954) | 2.47452 ± 0.0406565 (W 0.0115574) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `lu/n513/b1` | 4.14563 ± 0.0657528 (W 0.0307258) | 4.1703 ± 0.0223317 (W 0.0409816) | 2.52772 ± 0.0399735 (W 0.00737923) | · | 🔴 fork 1.64× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 1.99432 ± 0.0164866 (W 0.018689) | 3.67634 ± 0.0185685 (W 0.05678) | 1.62063 ± 0.00906663 (W 0.00612309) | 🔵 fork 1.84× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 2.0365 ± 0.00142546 (W 0.0186077) | 3.79081 ± 0.0379965 (W 0.0625626) | 1.6633 ± 0.00661858 (W 0.00698325) | 🔵 fork 1.86× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 8.4879 ± 0.0203136 (W 0.0929527) | 12.0251 ± 0.100624 (W 0.144004) | 8.50877 ± 0.0299231 (W 0.0162318) | 🔵 fork 1.42× faster than `faer-upstream` | · |  |
| `qr/n513/b1` | 10.3402 ± 0.0554395 (W 0.235116) | 12.5334 ± 0.0561633 (W 0.152889) | 8.61108 ± 0.0173961 (W 0.0166032) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `qr_factor/n255/b1` | 1.47273 ± 0.00062168 (W 0.0230534) | 4.25251 ± 0.0297557 (W 0.0325016) | 0.688843 ± 0.000989283 (W 0.00276541) | 🔵 fork 2.89× faster than `faer-upstream` | 🔴 fork 2.14× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 1.5092 ± 0.0138652 (W 0.0289683) | 4.33534 ± 0.0175554 (W 0.0271564) | 0.702193 ± 0.00227086 (W 0.0019741) | 🔵 fork 2.87× faster than `faer-upstream` | 🔴 fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 5.26897 ± 0.00813673 (W 0.0244008) | 15.6233 ± 0.0166146 (W 0.125455) | 3.8613 ± 0.0104958 (W 0.00896704) | 🔵 fork 2.97× faster than `faer-upstream` | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `qr_factor/n513/b1` | 5.21204 ± 0.0319324 (W 0.0266785) | 13.2526 ± 0.0548917 (W 0.0920629) | 3.97431 ± 0.0263862 (W 0.00744521) | 🔵 fork 2.54× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `solve/n255/b1` | 0.758554 ± 0.0016784 (W 0.00345406) | 0.784081 ± 0.0196243 (W 0.0242761) | 0.379948 ± 0.00128009 (W 0.00288458) | · | 🔴 fork 2.00× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 0.660962 ± 0.00189635 (W 0.00733972) | 0.751364 ± 0.0110351 (W 0.0237823) | 0.387523 ± 0.0307832 (W 0.0029313) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 1.71× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n511/b1` | 3.36992 ± 0.0363525 (W 0.036143) | 3.34141 ± 0.0177167 (W 0.0347558) | 1.78434 ± 0.0181453 (W 0.00561938) | · | 🔴 fork 1.89× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 4.42438 ± 0.0130992 (W 0.0158454) | 4.2686 ± 0.121626 (W 0.04085) | 1.8267 ± 0.0174731 (W 0.00498337) | · | 🔴 fork 2.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n255/b1` | 14.102 ± 0.035641 (W 0.13341) | 14.1483 ± 0.0325779 (W 0.0897013) | 10.4616 ± 0.0482571 (W 0.0173615) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 10.6446 ± 0.0402564 (W 0.0543876) | 10.64 ± 0.0402952 (W 0.0402905) | 10.6844 ± 0.0256414 (W 0.0115447) | · | · |  |
| `svd_thin/n511/b1` | 60.962 ± 0.0574002 (W 0.445418) | 60.8101 ± 0.290609 (W 0.385077) | 43.3347 ± 0.130164 (W 0.0561551) | · | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 49.3059 ± 0.218435 (W 0.0681013) | 49.2456 ± 0.108031 (W 0.0914307) | 43.5225 ± 0.0475626 (W 0.0734648) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n255/b1` | 11.1743 ± 0.0349092 (W 0.10164) | 11.1341 ± 0.0459807 (W 0.0240028) | 5.39436 ± 0.011197 (W 0.00371557) | · | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 8.64972 ± 0.00665635 (W 0.0251478) | 8.57878 ± 0.0777548 (W 0.0144609) | 5.44124 ± 0.0154605 (W 0.00578934) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 47.5691 ± 0.088856 (W 0.328248) | 47.3578 ± 0.156248 (W 0.350655) | 20.0805 ± 0.12244 (W 0.0297287) | · | 🔴 fork 2.37× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 36.9545 ± 0.183205 (W 0.0928452) | 36.9568 ± 0.130821 (W 0.141512) | 20.3239 ± 0.0297406 (W 0.0264129) | · | 🔴 fork 1.82× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.011341 ± 0.000517418 (W 0.000103102) | 0.011321 ± 0.000557657 (W 7.66812e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.011492 ± 0.000569767 (W 5.89067e-05) | 0.011602 ± 0.000457668 (W 7.52283e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.038883 ± 0.00187868 (W 0.000300432) | 0.038321 ± 0.000172434 (W 0.000313431) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.037721 ± 0.00134789 (W 0.000411079) | 0.040164 ± 0.00275505 (W 0.000407379) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.357972 ± 0.00423183 (W 0.0157392) | 0.413831 ± 0.00600404 (W 0.0162386) | 0.283504 ± 0.00150597 (W 0.00333832) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `cholesky/n257/b1` | 0.370129 ± 0.00509709 (W 0.0196323) | 0.412288 ± 0.00699074 (W 0.0225135) | 0.29682 ± 0.00241668 (W 0.00332665) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `cholesky/n511/b1` | 1.11839 ± 0.0221403 (W 0.0351742) | 1.2552 ± 2.44551 (W 0.0321343) | 1.0703 ± 0.00581014 (W 0.0135431) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n513/b1` | 1.06604 ± 0.0189885 (W 0.0281447) | 1.17804 ± 0.00902005 (W 0.0419632) | 1.12214 ± 0.0298235 (W 0.0157186) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `eigh/n255/b1` | 7.08021 ± 0.0368293 (W 0.0293188) | 7.2823 ± 0.0474825 (W 0.0371687) | 3.8628 ± 0.0130138 (W 0.0080511) | · | 🔴 fork 1.83× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 7.07654 ± 0.0361189 (W 0.034148) | 7.24134 ± 0.0416715 (W 0.0740278) | 3.92413 ± 0.013756 (W 0.0101694) | · | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 24.5593 ± 0.180765 (W 0.077682) | 25.3664 ± 0.11022 (W 0.0995602) | 13.9601 ± 0.782319 (W 0.0626597) | · | 🔴 fork 1.76× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n513/b1` | 24.9282 ± 0.0545379 (W 0.106191) | 25.8388 ± 0.184542 (W 0.115973) | 14.0758 ± 0.0215168 (W 0.0788381) | · | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 2.75087 ± 0.0416032 (W 0.00794263) | 2.64595 ± 0.0330736 (W 0.0128428) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.9773 ± 0.0139213 (W 0.00473646) | 1.90967 ± 0.00700549 (W 0.00204868) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 17.4271 ± 0.399727 (W 0.143123) | 17.0085 ± 0.117435 (W 0.13309) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 10.7131 ± 0.172504 (W 0.145957) | 10.4648 ± 0.101429 (W 0.0781728) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 0.989107 ± 0.124756 (W 0.00796028) | 1.09702 ± 0.0114617 (W 0.028911) | 0.35522 ± 0.00283514 (W 0.00152666) | · | 🔴 fork 2.78× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n257/b1` | 0.93961 ± 0.0133259 (W 0.0322335) | 1.08804 ± 0.0151186 (W 0.0392845) | 0.525371 ± 0.00869214 (W 0.0161239) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `lu/n511/b1` | 4.61294 ± 0.0505526 (W 0.0315824) | 4.94278 ± 0.0706662 (W 0.0670364) | 1.9637 ± 0.0572986 (W 0.0105916) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 2.35× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n513/b1` | 4.00328 ± 0.0480509 (W 0.0638449) | 4.22324 ± 0.0413758 (W 0.109912) | 2.00916 ± 0.0270688 (W 0.0102432) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 1.82009 ± 0.00953903 (W 0.0148002) | 4.77504 ± 0.0189098 (W 0.0873697) | 1.47206 ± 0.00212189 (W 0.00648163) | 🔵 fork 2.62× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 1.85709 ± 0.0151735 (W 0.0219102) | 4.89222 ± 0.0545569 (W 0.0493837) | 1.52509 ± 0.00578587 (W 0.00878604) | 🔵 fork 2.63× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 7.04691 ± 0.0048785 (W 0.0441363) | 13.7408 ± 4.20911 (W 10.094) | 5.67874 ± 0.0615651 (W 0.028538) | 🔵 fork 1.95× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n513/b1` | 8.87834 ± 0.0657705 (W 0.0515736) | 13.6328 ± 0.0840361 (W 0.199153) | 5.75049 ± 0.0228608 (W 0.0202897) | 🔵 fork 1.54× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `qr_factor/n255/b1` | 1.40695 ± 0.0147965 (W 0.0176905) | 5.18051 ± 0.0142478 (W 0.0448181) | 0.586653 ± 0.00196018 (W 0.00289645) | 🔵 fork 3.68× faster than `faer-upstream` | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 1.46157 ± 0.013337 (W 0.0167335) | 5.37015 ± 28.2363 (W 0.0719158) | 0.602513 ± 0.00334441 (W 0.00236606) | · | 🔴 fork 2.43× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n511/b1` | 4.8948 ± 0.0168046 (W 0.0276201) | 18.3022 ± 0.0604659 (W 0.137027) | 2.35981 ± 0.001702 (W 0.00601848) | 🔵 fork 3.74× faster than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `qr_factor/n513/b1` | 4.84561 ± 0.0266693 (W 0.0620818) | 15.204 ± 0.0357015 (W 0.164578) | 2.45134 ± 0.0230287 (W 0.00395725) | 🔵 fork 3.14× faster than `faer-upstream` | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `solve/n255/b1` | 0.76264 ± 0.00268409 (W 0.00622166) | 0.79477 ± 0.0176522 (W 0.0276697) | 0.345694 ± 0.00255263 (W 0.00272334) | · | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 0.673915 ± 0.0036446 (W 0.0392621) | 0.754913 ± 0.014718 (W 0.0257033) | 0.358438 ± 0.0022937 (W 0.00300573) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.88× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 3.23559 ± 0.00454732 (W 0.0355331) | 3.43358 ± 0.0434356 (W 0.0632862) | 1.25657 ± 0.0230646 (W 0.010489) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 2.57× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 4.20553 ± 0.0722357 (W 0.168382) | 4.38898 ± 0.083268 (W 0.079313) | 1.33147 ± 0.0118575 (W 0.00733573) | · | 🔴 fork 3.16× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 13.9597 ± 0.0519821 (W 0.0642133) | 14.2791 ± 0.033089 (W 0.0424572) | 9.59375 ± 0.0133565 (W 0.0155976) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 10.4357 ± 0.0564454 (W 0.0417113) | 10.696 ± 0.0261067 (W 0.0498386) | 9.85357 ± 0.0170571 (W 0.016819) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n511/b1` | 58.6816 ± 0.22218 (W 0.501974) | 60.3128 ± 0.302467 (W 0.26593) | 35.0387 ± 0.0569593 (W 0.0649817) | · | 🔴 fork 1.67× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 43.9955 ± 0.10323 (W 0.134951) | 46.0761 ± 0.550475 (W 0.26081) | 35.5306 ± 0.133475 (W 0.0660687) | · | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `svd_values/n255/b1` | 11.3058 ± 0.0410209 (W 0.0209099) | 11.2815 ± 0.0445345 (W 0.0241754) | 5.2351 ± 0.0180676 (W 0.00486006) | · | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 8.8033 ± 0.0173922 (W 0.0463649) | 8.76414 ± 0.0114686 (W 0.0204791) | 5.3246 ± 0.0147427 (W 0.00399868) | · | 🔴 fork 1.65× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 48.3578 ± 0.234801 (W 0.63307) | 48.8998 ± 0.195425 (W 0.452523) | 17.1225 ± 0.0309653 (W 0.0115862) | · | 🔴 fork 2.82× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 35.6061 ± 0.0271192 (W 0.0860126) | 35.5996 ± 0.0612386 (W 0.036387) | 17.3428 ± 0.00593745 (W 0.0219762) | · | 🔴 fork 2.05× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.011311 ± 0.000590052 (W 3.10532e-05) | 0.011361 ± 0.000587697 (W 5.54374e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.011281 ± 0.000691529 (W 7.24583e-05) | 0.011551 ± 0.00051272 (W 0.000123572) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.037861 ± 0.000917231 (W 0.000379954) | 0.038141 ± 0.000200749 (W 0.00160491) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.041287 ± 0.00100695 (W 0.000668448) | 0.041798 ± 0.00564238 (W 0.000836429) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.348742 ± 0.01702 (W 0.0230031) | 0.37051 ± 0.00257558 (W 0.021411) | 0.269576 ± 0.00673297 (W 0.00839457) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n257/b1` | 0.315608 ± 0.011559 (W 0.00631949) | 0.380439 ± 0.00491597 (W 0.0163711) | 0.277681 ± 0.00561634 (W 0.00985242) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n511/b1` | 1.13013 ± 0.0229803 (W 0.0187652) | 1.25856 ± 0.0993601 (W 0.032729) | 1.33455 ± 0.00161574 (W 0.0137433) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n513/b1` | 1.07389 ± 0.0243479 (W 0.0241324) | 1.24365 ± 0.0147566 (W 0.026668) | 1.38941 ± 0.0112078 (W 0.00483973) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `eigh/n255/b1` | 7.24722 ± 0.0313092 (W 0.013311) | 7.20538 ± 0.0480511 (W 0.0128263) | 4.40981 ± 0.0210083 (W 0.0058097) | · | 🔴 fork 1.64× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 7.22914 ± 0.0114336 (W 0.0410797) | 7.17794 ± 0.032862 (W 0.0357132) | 4.50362 ± 0.0160833 (W 0.00674707) | · | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 26.5735 ± 0.0824079 (W 0.0523849) | 26.4549 ± 0.171826 (W 0.0663348) | 19.1187 ± 0.0402029 (W 0.0309146) | · | 🔴 fork 1.39× slower than `lapack-mkl` |  |
| `eigh/n513/b1` | 27.1877 ± 0.024649 (W 0.0617541) | 27.0866 ± 0.0534832 (W 0.061279) | 19.4709 ± 0.0274362 (W 0.0248345) | · | 🔴 fork 1.40× slower than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 2.65726 ± 0.0122445 (W 0.0086489) | 2.6526 ± 0.00697297 (W 0.00674453) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.8988 ± 0.00259075 (W 0.00266966) | 1.89649 ± 0.00607761 (W 0.00191277) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 15.8933 ± 0.67354 (W 0.155735) | 15.8851 ± 0.682916 (W 0.108644) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n513/b1` | 10.8301 ± 0.121273 (W 0.178058) | 10.7588 ± 0.067403 (W 0.129241) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 0.698732 ± 0.116371 (W 0.00291153) | 0.823084 ± 0.103965 (W 0.018155) | 0.332011 ± 0.00136094 (W 0.00216155) | · | 🔴 fork 2.10× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n257/b1` | 0.815321 ± 0.00307224 (W 0.0111204) | 1.00882 ± 0.0102455 (W 0.0210767) | 0.336479 ± 0.00483418 (W 0.00165568) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `lu/n511/b1` | 4.29627 ± 0.0514762 (W 0.0930453) | 4.52344 ± 0.0322979 (W 0.068936) | 1.58073 ± 0.0063559 (W 0.00588135) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 2.72× slower than `lapack-mkl` |  |
| `lu/n513/b1` | 3.60827 ± 0.0396493 (W 0.0490678) | 3.91358 ± 0.0134186 (W 0.0349168) | 1.62721 ± 0.00428457 (W 0.00419711) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 2.22× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 1.89716 ± 0.0198121 (W 0.0208809) | 3.60512 ± 0.0735087 (W 0.0768362) | 1.50872 ± 0.00858748 (W 0.00683328) | 🔵 fork 1.90× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 1.9488 ± 0.00279163 (W 0.0185238) | 3.77014 ± 0.0556582 (W 0.0562001) | 1.54159 ± 0.00726056 (W 0.0054745) | 🔵 fork 1.93× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 7.92576 ± 0.0183654 (W 0.0562719) | 11.7127 ± 0.0844963 (W 0.0883805) | 7.95364 ± 0.0244225 (W 0.00910332) | 🔵 fork 1.48× faster than `faer-upstream` | · |  |
| `qr/n513/b1` | 9.90798 ± 0.145387 (W 0.0805247) | 12.2425 ± 0.0251288 (W 0.119401) | 8.04481 ± 0.0181074 (W 0.00737939) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr_factor/n255/b1` | 1.34104 ± 0.00133535 (W 0.0198933) | 3.19409 ± 0.0422899 (W 0.0578323) | 0.633106 ± 0.00217771 (W 0.00232085) | 🔵 fork 2.38× faster than `faer-upstream` | 🔴 fork 2.12× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 1.37707 ± 0.00521512 (W 0.0227272) | 3.2301 ± 0.00579961 (W 0.06807) | 0.64634 ± 0.00216974 (W 0.00177209) | 🔵 fork 2.35× faster than `faer-upstream` | 🔴 fork 2.13× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 4.88493 ± 0.0215783 (W 0.0338127) | 8.60383 ± 0.140688 (W 0.0861523) | 3.65835 ± 0.00513825 (W 0.00444467) | 🔵 fork 1.76× faster than `faer-upstream` | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `qr_factor/n513/b1` | 4.82386 ± 0.0174529 (W 0.0393581) | 7.20475 ± 0.0450196 (W 0.0522549) | 3.72769 ± 0.00631582 (W 0.0110808) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 1.29× slower than `lapack-mkl` |  |
| `solve/n255/b1` | 0.670655 ± 0.00320796 (W 0.00277297) | 0.750368 ± 0.0121381 (W 0.0243841) | 0.320327 ± 0.00189359 (W 0.00213612) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 0.571414 ± 0.00248719 (W 0.00425779) | 0.737224 ± 0.00505426 (W 0.0229625) | 0.325837 ± 0.00103288 (W 0.00204778) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 2.9406 ± 0.0143974 (W 0.0355804) | 3.14016 ± 0.0272761 (W 0.0330655) | 1.58115 ± 0.0132578 (W 0.00324851) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.86× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 3.84963 ± 0.0017241 (W 0.0974318) | 4.02626 ± 0.0152015 (W 0.0257239) | 1.60516 ± 0.0120659 (W 0.00526519) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 14.261 ± 0.0624832 (W 0.101908) | 14.2209 ± 0.0159629 (W 0.094842) | 10.2533 ± 0.0394764 (W 0.0288731) | · | 🔴 fork 1.39× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 10.6475 ± 0.0293446 (W 0.10901) | 10.6699 ± 0.023267 (W 0.0758338) | 10.5326 ± 0.0402419 (W 0.0156435) | · | · |  |
| `svd_thin/n511/b1` | 60.6831 ± 0.318232 (W 0.484217) | 60.5948 ± 0.22757 (W 0.267184) | 42.4675 ± 0.067489 (W 0.0552573) | · | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 48.841 ± 0.0649394 (W 0.0750534) | 48.9514 ± 0.131318 (W 0.177987) | 42.6207 ± 0.133348 (W 0.0406208) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/n255/b1` | 11.2185 ± 0.112685 (W 0.103131) | 11.2117 ± 0.053164 (W 0.0865704) | 5.34109 ± 0.020386 (W 0.008061) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 8.58523 ± 0.00189641 (W 0.0208862) | 8.55127 ± 0.0369108 (W 0.0186528) | 5.4283 ± 0.001877 (W 0.0125963) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 47.1402 ± 0.345645 (W 0.336987) | 47.5122 ± 0.0194387 (W 0.427726) | 19.926 ± 0.0420065 (W 0.013001) | · | 🔴 fork 2.37× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 36.7286 ± 0.166339 (W 0.0472346) | 36.694 ± 0.0940474 (W 0.12453) | 19.9802 ± 0.0181958 (W 0.0216855) | · | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.012183 ± 0.0005557 (W 9.38206e-05) | 0.012203 ± 0.000844723 (W 6.34216e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.012534 ± 0.000746507 (W 5.63321e-05) | 0.012443 ± 0.000801378 (W 0.000130243) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.044471 ± 0.00227593 (W 0.00104825) | 0.043801 ± 0.000405229 (W 0.00041019) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.043331 ± 0.00254674 (W 0.000421981) | 0.045104 ± 0.00136602 (W 0.000796243) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.357424 ± 0.0107726 (W 0.0245228) | 0.412733 ± 0.00688398 (W 0.0236948) | 0.240748 ± 0.00178848 (W 0.00195344) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n257/b1` | 0.364965 ± 0.0285731 (W 0.0271828) | 0.418053 ± 0.0253883 (W 0.0283989) | 0.253609 ± 0.000443182 (W 0.00472539) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n511/b1` | 1.09854 ± 0.0299336 (W 0.0374464) | 1.22464 ± 0.00727279 (W 0.0254236) | 0.931566 ± 0.00242486 (W 0.00499775) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n513/b1` | 1.02857 ± 0.0298154 (W 0.0335856) | 1.14368 ± 0.0267183 (W 0.041677) | 0.971792 ± 0.00596591 (W 0.00844079) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n255/b1` | 7.07115 ± 0.0301484 (W 0.0225959) | 7.245 ± 0.0314625 (W 0.016655) | 3.81964 ± 0.00357544 (W 0.0131847) | · | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 7.0575 ± 0.0282852 (W 0.0409491) | 7.21806 ± 0.0252213 (W 0.049997) | 3.87651 ± 0.00694469 (W 0.00550185) | · | 🔴 fork 1.82× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 24.5438 ± 0.0693305 (W 0.059687) | 25.2082 ± 0.0657892 (W 0.136956) | 13.674 ± 0.0346544 (W 0.0773903) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `eigh/n513/b1` | 24.8621 ± 0.0781077 (W 0.0855672) | 25.6605 ± 0.212572 (W 0.162119) | 13.7987 ± 0.0441978 (W 0.0164313) | · | 🔴 fork 1.80× slower than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 2.63435 ± 0.0204727 (W 0.0107198) | 2.63555 ± 0.0298155 (W 0.00757143) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.88961 ± 0.00956353 (W 0.00284534) | 1.88611 ± 0.0061534 (W 0.00521002) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 16.7575 ± 0.0762588 (W 0.0674757) | 16.6425 ± 0.093025 (W 0.0842494) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 10.144 ± 0.0548147 (W 0.115777) | 10.156 ± 0.0676692 (W 0.0951794) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 0.702519 ± 0.114297 (W 0.00790199) | 0.903634 ± 0.134335 (W 0.0320149) | 0.31656 ± 0.00170325 (W 0.00322459) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 2.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n257/b1` | 0.82143 ± 0.0107997 (W 0.0223168) | 1.08946 ± 0.0231008 (W 0.0107562) | 0.32232 ± 0.00182464 (W 0.00390995) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 2.55× slower than `lapack-mkl` |  |
| `lu/n511/b1` | 4.14313 ± 0.026991 (W 0.122042) | 4.71558 ± 0.0450873 (W 0.0856954) | 1.16978 ± 0.00349404 (W 0.00471381) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 3.54× slower than `lapack-mkl` |  |
| `lu/n513/b1` | 3.4512 ± 0.0305235 (W 0.0897783) | 4.01424 ± 0.0209409 (W 0.128606) | 1.2208 ± 0.00978021 (W 0.00559779) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 2.83× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 1.72045 ± 0.0117042 (W 0.0142881) | 4.78777 ± 0.0118639 (W 0.0674333) | 1.40073 ± 0.00737326 (W 0.00760278) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 1.74883 ± 0.00614972 (W 0.0132466) | 4.86782 ± 0.0813937 (W 0.0476387) | 1.44568 ± 0.00664588 (W 0.0075931) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 6.54551 ± 0.0173042 (W 0.0269996) | 13.0884 ± 0.0922021 (W 0.106267) | 5.39408 ± 0.0354409 (W 0.0116434) | 🔵 fork 2.00× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/n513/b1` | 8.33886 ± 0.0298616 (W 0.0687003) | 13.3704 ± 0.0807162 (W 0.197793) | 5.4536 ± 0.0191717 (W 0.0140967) | 🔵 fork 1.60× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` |  |
| `qr_factor/n255/b1` | 1.30785 ± 0.0154757 (W 0.0116239) | 4.18139 ± 0.0674078 (W 0.0477522) | 0.552712 ± 0.00237344 (W 0.00350384) | 🔵 fork 3.20× faster than `faer-upstream` | 🔴 fork 2.37× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 1.35152 ± 0.00909814 (W 0.00996056) | 4.20245 ± 0.0241126 (W 0.042119) | 0.564412 ± 0.000589542 (W 0.00365266) | 🔵 fork 3.11× faster than `faer-upstream` | 🔴 fork 2.39× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 4.55246 ± 0.0540843 (W 0.0574286) | 10.3631 ± 0.0457648 (W 0.0940108) | 2.23054 ± 0.0645014 (W 0.00685672) | 🔵 fork 2.28× faster than `faer-upstream` | 🔴 fork 2.04× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n513/b1` | 4.56377 ± 0.0596784 (W 0.0562176) | 8.60216 ± 0.0491044 (W 0.13652) | 2.28556 ± 0.0030479 (W 0.00550217) | 🔵 fork 1.88× faster than `faer-upstream` | 🔴 fork 2.00× slower than `lapack-mkl` |  |
| `solve/n255/b1` | 0.674286 ± 0.00270641 (W 0.00624157) | 0.800249 ± 0.00428275 (W 0.0195962) | 0.306891 ± 0.00360007 (W 0.00194251) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 0.601714 ± 0.00634132 (W 0.0246663) | 0.747892 ± 0.0106891 (W 0.0281274) | 0.312838 ± 0.000421573 (W 0.00263184) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 2.79299 ± 0.0308604 (W 0.066577) | 3.25177 ± 0.0315794 (W 0.0383914) | 1.15392 ± 0.00463979 (W 0.00737036) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 3.71991 ± 0.0142281 (W 0.0962252) | 4.05777 ± 0.0240528 (W 0.0721469) | 1.19415 ± 0.0124777 (W 0.00544506) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 3.12× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 14.0098 ± 0.0272861 (W 0.0225616) | 14.292 ± 0.0518931 (W 0.0343515) | 9.50705 ± 0.0233557 (W 0.0438737) | · | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 10.3807 ± 0.0125975 (W 0.0168077) | 10.7575 ± 0.0309275 (W 0.0720629) | 9.77029 ± 0.195598 (W 0.0138979) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n511/b1` | 58.3178 ± 0.0650912 (W 0.325475) | 59.8763 ± 0.306642 (W 0.462841) | 34.5611 ± 0.0601129 (W 0.0786277) | · | 🔴 fork 1.69× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 43.8409 ± 0.0676137 (W 0.0691941) | 45.6383 ± 0.0810263 (W 0.249702) | 35.0095 ± 0.085542 (W 0.0868067) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n255/b1` | 11.3436 ± 0.0298905 (W 0.0378063) | 11.3364 ± 0.0380343 (W 0.0356645) | 5.20978 ± 0.00868653 (W 0.00215091) | · | 🔴 fork 2.18× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 8.77685 ± 0.0235148 (W 0.0155559) | 8.72661 ± 0.0364637 (W 0.0178525) | 5.28561 ± 0.00817254 (W 0.00749149) | · | 🔴 fork 1.66× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 48.4077 ± 0.22699 (W 0.273866) | 48.8834 ± 0.34819 (W 0.889595) | 17.0682 ± 0.0183059 (W 0.00775099) | · | 🔴 fork 2.84× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 35.3555 ± 0.0262202 (W 0.065151) | 35.3993 ± 0.169234 (W 0.0719607) | 17.1419 ± 0.0681065 (W 0.0105265) | · | 🔴 fork 2.06× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.012263 ± 0.0011651 (W 7.23416e-05) | 0.012313 ± 0.00108102 (W 7.64212e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.012504 ± 0.000936751 (W 6.11817e-05) | 0.012474 ± 0.000847403 (W 8.39125e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.043731 ± 0.000515297 (W 0.000220075) | 0.043712 ± 0.000611716 (W 0.000224926) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.051377 ± 0.00106271 (W 0.00183376) | 0.046476 ± 0.0017501 (W 0.000502986) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.78626 ± 0.0092365 (W 0.010194) | 0.797606 ± 0.00495557 (W 0.00714464) | 0.555986 ± 0.00318442 (W 0.00747915) | · | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `cholesky/n257/b1` | 0.7427 ± 0.00948425 (W 0.00646115) | 0.774352 ± 0.01 (W 0.012293) | 0.583758 ± 0.0135252 (W 0.00912463) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `cholesky/n511/b1` | 3.14031 ± 0.0236332 (W 0.0171547) | 3.16668 ± 0.0420592 (W 0.0255018) | 2.93669 ± 0.00210725 (W 0.0159799) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `cholesky/n513/b1` | 3.07742 ± 0.0126999 (W 0.0212371) | 3.10481 ± 0.0727686 (W 0.0217346) | 3.04029 ± 0.00736225 (W 0.0109178) | · | · |  |
| `eigh/n255/b1` | 11.5001 ± 0.0407909 (W 0.0286819) | 11.5125 ± 0.0428427 (W 0.0266506) | 9.7282 ± 0.0361795 (W 0.0166543) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 11.5347 ± 0.0431993 (W 0.0240506) | 11.5541 ± 0.0370669 (W 0.0348295) | 9.87192 ± 0.0365635 (W 0.020534) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 46.4451 ± 0.190055 (W 0.118029) | 46.4053 ± 0.118795 (W 0.0876614) | 51.0418 ± 0.0793069 (W 0.0350029) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n513/b1` | 47.1782 ± 0.0706455 (W 0.0862837) | 47.2548 ± 0.119254 (W 0.142454) | 51.4107 ± 0.0801913 (W 0.0860303) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 5.86097 ± 0.0183485 (W 0.013519) | 5.73847 ± 0.0239252 (W 0.00948224) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.5007 ± 0.0168532 (W 0.00811718) | 4.37166 ± 0.00506667 (W 0.00320579) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 26.9337 ± 0.0692629 (W 0.052225) | 26.4483 ± 0.088738 (W 0.0632624) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 20.6897 ± 0.0810842 (W 0.0772118) | 20.4283 ± 0.00775889 (W 0.0736836) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.55757 ± 0.00593496 (W 0.0204077) | 1.47858 ± 0.0120082 (W 0.0264146) | 0.935696 ± 0.00156982 (W 0.00339631) | 🔴 fork 1.05× slower than `faer-upstream` | 🔴 fork 1.66× slower than `lapack-mkl` |  |
| `lu/n257/b1` | 1.42077 ± 0.00494453 (W 0.00854636) | 1.35284 ± 0.0157332 (W 0.0142377) | 0.983955 ± 0.00715914 (W 0.00186838) | · | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `lu/n511/b1` | 7.31375 ± 0.0119206 (W 0.0476936) | 6.87161 ± 0.03093 (W 0.0379702) | 5.52819 ± 0.00357098 (W 0.0156132) | 🔴 fork 1.06× slower than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `lu/n513/b1` | 7.07947 ± 0.14033 (W 0.0522191) | 6.64758 ± 0.00630156 (W 0.056744) | 5.64461 ± 0.00468475 (W 0.00769046) | 🔴 fork 1.06× slower than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 4.54262 ± 0.0398271 (W 0.0703887) | 6.17331 ± 0.0373852 (W 0.0492805) | 3.84259 ± 0.0405614 (W 0.0122444) | 🔵 fork 1.36× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 4.69277 ± 0.00676296 (W 0.033943) | 6.23007 ± 0.0357217 (W 0.0387751) | 3.97378 ± 0.0100749 (W 0.00680948) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 23.2315 ± 0.109497 (W 0.234825) | 26.3668 ± 0.0371663 (W 0.0972708) | 24.8171 ± 0.0314354 (W 0.0243652) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `qr/n513/b1` | 24.0031 ± 0.0636233 (W 0.0491941) | 25.7648 ± 0.0333305 (W 0.0790847) | 24.9955 ± 0.0431991 (W 0.0322464) | 🔵 fork 1.07× faster than `faer-upstream` | · |  |
| `qr_factor/n255/b1` | 2.92845 ± 0.0166001 (W 0.0488898) | 5.8454 ± 0.0300886 (W 0.0294491) | 1.64567 ± 0.00502735 (W 0.00332739) | 🔵 fork 2.00× faster than `faer-upstream` | 🔴 fork 1.78× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 3.02067 ± 0.00579709 (W 0.0343177) | 5.93631 ± 0.0427578 (W 0.0322441) | 1.70967 ± 0.00594289 (W 0.00212959) | 🔵 fork 1.97× faster than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 12.1184 ± 0.0576804 (W 0.0738298) | 21.1331 ± 0.0253386 (W 0.0919705) | 11.3627 ± 0.00936666 (W 0.00865702) | 🔵 fork 1.74× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr_factor/n513/b1` | 12.4043 ± 0.0230443 (W 0.0384512) | 19.2693 ± 0.0555822 (W 0.0682031) | 11.5315 ± 0.0159933 (W 0.00724189) | 🔵 fork 1.55× faster than `faer-upstream` | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `solve/n255/b1` | 1.42734 ± 0.0172064 (W 0.0124654) | 1.35038 ± 0.00449429 (W 0.0148603) | 0.894782 ± 0.00656446 (W 0.00228573) | 🔴 fork 1.06× slower than `faer-upstream` | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 1.40134 ± 0.00292013 (W 0.0148149) | 1.32356 ± 0.00694879 (W 0.0117379) | 0.947015 ± 0.00937322 (W 0.00217888) | 🔴 fork 1.06× slower than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 7.29461 ± 0.00192234 (W 0.0231267) | 6.76694 ± 0.0349037 (W 0.0256788) | 5.50993 ± 0.0114501 (W 0.0116615) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 7.21057 ± 0.0130379 (W 0.0456347) | 6.71829 ± 0.00368545 (W 0.0517458) | 5.62118 ± 0.0186288 (W 0.00715926) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 23.5113 ± 0.42974 (W 0.0857666) | 23.4763 ± 0.0341567 (W 0.149576) | 16.6226 ± 0.0168732 (W 0.0210531) | · | 🔴 fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 19.0262 ± 0.060314 (W 0.047347) | 19.0469 ± 0.111673 (W 0.165679) | 16.9635 ± 0.0717758 (W 0.0149074) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `svd_thin/n511/b1` | 95.1235 ± 0.16293 (W 0.168349) | 95.3112 ± 0.3932 (W 0.360312) | 86.674 ± 0.0706429 (W 0.114583) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 86.5672 ± 0.264498 (W 0.389909) | 86.9354 ± 0.258797 (W 0.0782935) | 87.301 ± 0.235629 (W 0.0649441) | · | · |  |
| `svd_values/n255/b1` | 17.9677 ± 0.0276506 (W 0.0550392) | 17.9745 ± 0.0348235 (W 0.0244287) | 8.37243 ± 0.273334 (W 0.0080469) | · | 🔴 fork 2.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n257/b1` | 14.3655 ± 0.0401098 (W 0.169636) | 14.3002 ± 0.103983 (W 0.0992889) | 8.11026 ± 0.0154865 (W 0.0100785) | · | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 65.7393 ± 0.150927 (W 0.24537) | 65.7187 ± 0.15051 (W 0.326092) | 41.5664 ± 0.118154 (W 0.0340145) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 58.0214 ± 0.089956 (W 0.0997769) | 58.0435 ± 0.0976699 (W 0.225388) | 42.0147 ± 0.0340311 (W 0.0245896) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.023805 ± 9.43416e-05 (W 0.000114997) | 0.023835 ± 0.000174261 (W 0.000173946) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n257/b1` | 0.024264 ± 0.000157611 (W 0.000124985) | 0.024325 ± 0.000469347 (W 5.77062e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.087676 ± 0.000624022 (W 0.000447613) | 0.087152 ± 0.00160009 (W 0.00185372) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.071335 ± 0.00102236 (W 0.000655344) | 0.071284 ± 0.00563992 (W 0.00156607) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.759185 ± 0.00633531 (W 0.0159751) | 0.818434 ± 0.00867323 (W 0.0107469) | 0.408035 ± 0.00616894 (W 0.00543119) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.86× slower than `lapack-mkl` |  |
| `cholesky/n257/b1` | 0.750503 ± 0.0155637 (W 0.0243764) | 0.802111 ± 0.0222124 (W 0.0201126) | 0.415829 ± 0.00754147 (W 0.00652504) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.80× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n511/b1` | 2.57144 ± 0.0053368 (W 0.0335161) | 2.61633 ± 0.020112 (W 0.0169888) | 1.77451 ± 0.00574375 (W 0.00748086) | · | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `cholesky/n513/b1` | 2.46521 ± 0.00962343 (W 0.0283929) | 2.51644 ± 0.0285151 (W 0.027187) | 1.84105 ± 0.00586325 (W 0.00818993) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `eigh/n255/b1` | 10.8811 ± 0.0448597 (W 0.0342123) | 11.2482 ± 0.0418383 (W 0.039642) | 7.80712 ± 0.00663601 (W 0.0138336) | · | 🔴 fork 1.39× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 10.9203 ± 0.0120153 (W 0.020322) | 11.2209 ± 0.0219681 (W 0.0698157) | 7.88658 ± 0.0108177 (W 0.013416) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 39.4628 ± 0.143782 (W 0.0891059) | 40.2194 ± 0.185767 (W 0.143389) | 35.8848 ± 0.0310987 (W 0.122756) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `eigh/n513/b1` | 39.8917 ± 0.0705421 (W 0.177738) | 41.266 ± 0.0646898 (W 0.34619) | 35.943 ± 0.0530487 (W 0.0815855) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 5.83 ± 0.0216413 (W 0.00913005) | 5.7622 ± 0.028334 (W 0.0080178) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.49609 ± 0.0262985 (W 0.0107232) | 4.37069 ± 0.0156572 (W 0.0089333) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 25.4544 ± 0.217595 (W 0.10698) | 24.97 ± 0.0996505 (W 0.182768) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 18.6222 ± 0.12008 (W 0.108145) | 18.2845 ± 0.55445 (W 0.196195) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n255/b1` | 1.50974 ± 0.00390568 (W 0.0197141) | 1.47966 ± 0.00715343 (W 0.0079896) | 0.690287 ± 0.000976633 (W 0.00448899) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `lu/n257/b1` | 1.37387 ± 0.0011439 (W 0.0161252) | 1.3036 ± 0.0024422 (W 0.0146041) | 0.712538 ± 0.00453891 (W 0.00365279) | 🔴 fork 1.05× slower than `faer-upstream` | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `lu/n511/b1` | 6.20387 ± 11.6289 (W 0.0767013) | 5.84136 ± 0.00824952 (W 0.041616) | 3.26546 ± 0.00889627 (W 0.00958155) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n513/b1` | 5.96554 ± 0.011547 (W 0.0229061) | 5.58081 ± 0.00609574 (W 0.0404207) | 3.33751 ± 0.0017733 (W 0.0111692) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 3.48324 ± 0.0425827 (W 0.0314005) | 6.91809 ± 0.0595608 (W 0.0412179) | 2.99845 ± 0.00666292 (W 0.00956324) | 🔵 fork 1.99× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 3.52682 ± 0.00312719 (W 0.0216688) | 6.92741 ± 0.0774209 (W 0.0742035) | 3.05258 ± 0.148379 (W 0.00402819) | 🔵 fork 1.96× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n511/b1` | 15.9729 ± 0.0415168 (W 0.0779346) | 22.856 ± 0.195044 (W 0.160469) | 12.9024 ± 0.00283058 (W 0.0247019) | 🔵 fork 1.43× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `qr/n513/b1` | 16.3339 ± 0.103063 (W 0.0409418) | 22.3901 ± 0.229947 (W 0.22147) | 12.9792 ± 0.024225 (W 0.0371921) | 🔵 fork 1.37× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n255/b1` | 2.45203 ± 0.00764134 (W 0.019273) | 6.60992 ± 0.0371943 (W 0.0463698) | 1.63399 ± 0.00396416 (W 0.00322867) | 🔵 fork 2.70× faster than `faer-upstream` | 🔴 fork 1.50× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 2.50359 ± 0.00272417 (W 0.0218912) | 6.68574 ± 0.0438249 (W 0.0619064) | 1.68969 ± 0.0048846 (W 0.00488677) | 🔵 fork 2.67× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 9.46048 ± 0.0248308 (W 0.0344707) | 21.9151 ± 0.135955 (W 0.375997) | 5.80669 ± 0.00905999 (W 0.0080349) | 🔵 fork 2.32× faster than `faer-upstream` | 🔴 fork 1.63× slower than `lapack-mkl` |  |
| `qr_factor/n513/b1` | 9.54806 ± 0.00559368 (W 0.0191746) | 19.1916 ± 0.0922867 (W 0.141577) | 5.98884 ± 0.0142164 (W 0.00975152) | 🔵 fork 2.01× faster than `faer-upstream` | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `solve/n255/b1` | 1.37114 ± 0.0104433 (W 0.0206697) | 1.33343 ± 0.00580462 (W 0.0198176) | 0.679639 ± 0.0033277 (W 0.00320114) | · | 🔴 fork 2.02× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 1.35573 ± 0.0116173 (W 0.0135877) | 1.30113 ± 0.0104201 (W 0.0249812) | 0.701037 ± 0.00421361 (W 0.00358758) | · | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 6.12754 ± 0.0114564 (W 0.0107061) | 5.72898 ± 0.00478402 (W 0.0299168) | 3.31684 ± 0.00540909 (W 0.0126211) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 5.97889 ± 0.0550384 (W 0.0422851) | 5.58754 ± 0.0163799 (W 0.941691) | 3.38698 ± 0.00459545 (W 0.00861067) | 🔴 fork 1.07× slower than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 22.3536 ± 0.0584481 (W 0.0775146) | 22.9188 ± 0.0240083 (W 0.0373855) | 12.8399 ± 0.0191194 (W 0.0146858) | · | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 17.81 ± 0.0211137 (W 0.0511008) | 18.3682 ± 0.0552591 (W 0.0988532) | 13.1521 ± 0.0279021 (W 0.0202426) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `svd_thin/n511/b1` | 80.2787 ± 0.0275855 (W 0.238208) | 81.8652 ± 0.159679 (W 0.418424) | 59.0274 ± 0.168338 (W 0.108372) | · | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 69.5082 ± 0.117265 (W 0.131298) | 72.8199 ± 0.417712 (W 0.756774) | 59.4047 ± 0.106764 (W 0.0680722) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n255/b1` | 18.0015 ± 0.0144963 (W 0.0448759) | 18.0201 ± 0.0552929 (W 0.0350898) | 6.50721 ± 0.0106652 (W 0.0074809) | · | 🔴 fork 2.77× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 14.5185 ± 0.0589694 (W 0.0252995) | 14.5525 ± 0.0332866 (W 0.0472793) | 6.61901 ± 0.00212004 (W 0.0106002) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 61.3624 ± 0.195449 (W 0.306208) | 61.512 ± 0.138941 (W 0.20518) | 29.0934 ± 0.0654874 (W 0.0313458) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 51.9288 ± 1.57037 (W 0.0929275) | 52.1148 ± 4.56354 (W 0.140584) | 29.3812 ± 0.0580877 (W 0.0588261) | · | 🔴 fork 1.77× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `triangular_solve/n255/b1` | 0.023754 ± 0.000975465 (W 0.000123267) | 0.023824 ± 0.000255637 (W 0.000102956) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n257/b1` | 0.024235 ± 0.000130128 (W 8.59145e-05) | 0.024255 ± 0.000177858 (W 9.04434e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.087733 ± 0.00112799 (W 0.0019887) | 0.087521 ± 0.00101792 (W 0.000493193) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.073156 ± 0.00096654 (W 0.0035187) | 0.074348 ± 0.000415405 (W 0.000897983) | - | · | - | `*` one row has no measurement here |

## linalg-boundary, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.777825 ± 0.00868775 (W 0.00655219) | 0.79168 ± 0.00651247 (W 0.00408706) | 0.538783 ± 0.00734967 (W 0.00825645) | · | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `cholesky/n257/b1` | 0.746922 ± 0.00179586 (W 0.00981542) | 0.776767 ± 0.00561914 (W 0.007924) | 0.556798 ± 0.00864825 (W 0.00360374) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `cholesky/n511/b1` | 3.07939 ± 0.0211984 (W 0.0280021) | 3.1198 ± 0.0120907 (W 0.0178314) | 2.81456 ± 0.0503976 (W 0.00756173) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `cholesky/n513/b1` | 3.01802 ± 0.0197427 (W 0.0210574) | 3.0585 ± 0.0381594 (W 0.0190391) | 2.9129 ± 0.00688486 (W 0.00978733) | · | · |  |
| `eigh/n255/b1` | 11.5507 ± 0.0477729 (W 0.397938) | 11.491 ± 0.0406289 (W 0.0234276) | 9.6208 ± 0.0319667 (W 0.00908461) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 11.5466 ± 0.0272386 (W 0.0348688) | 11.4952 ± 0.0309469 (W 0.0211863) | 9.77833 ± 0.0241692 (W 0.0109534) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 46.4508 ± 0.148242 (W 0.176255) | 46.3105 ± 0.159013 (W 0.120358) | 50.5259 ± 0.0883806 (W 0.0271608) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n513/b1` | 47.1931 ± 0.0856543 (W 0.122356) | 47.1559 ± 0.0455187 (W 0.0886525) | 50.9301 ± 0.0797564 (W 0.0295227) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 5.72985 ± 0.00799741 (W 0.00608804) | 5.72195 ± 0.0169199 (W 0.00775434) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.39446 ± 0.00690492 (W 0.00813721) | 4.37611 ± 0.0308965 (W 0.00616854) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 26.2421 ± 0.0384505 (W 0.0708765) | 26.1984 ± 0.0431618 (W 0.114137) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 20.1753 ± 0.158655 (W 0.05828) | 20.0904 ± 0.0765452 (W 0.0570117) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.44674 ± 0.00616314 (W 0.0136283) | 1.46325 ± 0.0144446 (W 0.0149987) | 0.894086 ± 0.00374256 (W 0.00287332) | · | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `lu/n257/b1` | 1.30663 ± 0.00617007 (W 0.0152505) | 1.34911 ± 2.90319 (W 0.0173702) | 0.934473 ± 0.00163186 (W 0.00189702) | · | 🔴 fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n511/b1` | 6.54174 ± 0.00601829 (W 0.020054) | 6.58809 ± 0.0491544 (W 0.0293483) | 5.20371 ± 0.0517386 (W 0.00746699) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `lu/n513/b1` | 6.29142 ± 0.0220015 (W 0.0397241) | 6.39124 ± 0.0383241 (W 0.0342419) | 5.32271 ± 0.011055 (W 0.0069817) | · | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 4.45139 ± 0.02162 (W 0.0532249) | 6.11082 ± 11.5941 (W 0.0550244) | 3.7232 ± 0.0251689 (W 0.00548003) | · | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n257/b1` | 4.55336 ± 0.00634275 (W 0.0151456) | 6.18261 ± 0.0293504 (W 0.0558495) | 3.82806 ± 0.00914325 (W 0.00369376) | 🔵 fork 1.36× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 22.449 ± 0.0528085 (W 0.0498028) | 26.1026 ± 0.0398881 (W 0.111818) | 23.9954 ± 0.0596675 (W 0.0438193) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `qr/n513/b1` | 23.0282 ± 0.0302257 (W 0.0492797) | 25.5093 ± 0.0754811 (W 0.0351182) | 24.1447 ± 0.0149298 (W 0.0355898) | 🔵 fork 1.11× faster than `faer-upstream` | · |  |
| `qr_factor/n255/b1` | 2.79422 ± 0.121742 (W 0.0274994) | 4.41072 ± 0.0237157 (W 0.0341978) | 1.59078 ± 0.0439219 (W 0.00268564) | 🔵 fork 1.58× faster than `faer-upstream` | 🔴 fork 1.76× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n257/b1` | 2.844 ± 0.0188218 (W 0.0511569) | 4.47574 ± 0.0184772 (W 0.0549223) | 1.64562 ± 0.00101011 (W 0.00267068) | 🔵 fork 1.57× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 11.4654 ± 0.0354086 (W 0.054229) | 15.0129 ± 0.0491729 (W 0.12222) | 10.9542 ± 0.0113091 (W 0.00940437) | 🔵 fork 1.31× faster than `faer-upstream` | · |  |
| `qr_factor/n513/b1` | 11.6923 ± 0.013158 (W 0.0380021) | 14.112 ± 0.0493021 (W 0.0394127) | 11.1262 ± 0.00551734 (W 0.0125483) | 🔵 fork 1.21× faster than `faer-upstream` | · |  |
| `solve/n255/b1` | 1.32861 ± 0.00727483 (W 0.0130675) | 1.33619 ± 0.009127 (W 0.0128213) | 0.864004 ± 0.00379506 (W 0.00358146) | · | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 1.28631 ± 0.0101813 (W 0.00724138) | 1.31906 ± 0.00289347 (W 0.0097972) | 0.903473 ± 0.0023756 (W 0.00205044) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 6.48475 ± 0.0139312 (W 0.0210492) | 6.493 ± 0.0510485 (W 0.0266916) | 5.19948 ± 0.0126446 (W 0.0061196) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 6.38093 ± 0.0111933 (W 0.0306683) | 6.44227 ± 0.0288456 (W 0.0435558) | 5.31096 ± 0.0123762 (W 0.011197) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 23.4338 ± 0.0508022 (W 0.0714724) | 23.4525 ± 0.0139748 (W 0.0638819) | 16.4087 ± 0.0527418 (W 0.041106) | · | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `svd_thin/n257/b1` | 18.8988 ± 0.0900429 (W 0.0803127) | 18.9134 ± 0.0773698 (W 0.0838354) | 16.7663 ± 0.0484829 (W 0.0276704) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `svd_thin/n511/b1` | 94.9088 ± 0.20567 (W 0.364886) | 95.1273 ± 0.071626 (W 0.310462) | 85.3795 ± 0.295166 (W 0.0618288) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n513/b1` | 86.4493 ± 0.262161 (W 0.127237) | 86.6428 ± 0.261019 (W 0.216625) | 85.9801 ± 0.201317 (W 0.134185) | · | · |  |
| `svd_values/n255/b1` | 17.9607 ± 0.039898 (W 0.0635805) | 17.9318 ± 0.017076 (W 0.0337545) | 7.91512 ± 0.0227902 (W 0.0043491) | · | 🔴 fork 2.27× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 14.4029 ± 0.0521077 (W 0.0551454) | 14.3912 ± 0.0517166 (W 0.1435) | 8.07948 ± 0.00504269 (W 0.0068067) | · | 🔴 fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 65.2988 ± 0.0162533 (W 0.272313) | 65.4258 ± 0.0707638 (W 0.208872) | 41.2466 ± 0.179854 (W 0.0197618) | · | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 57.7119 ± 0.111881 (W 0.104592) | 57.7345 ± 0.0793138 (W 0.115079) | 41.7244 ± 0.044552 (W 0.0987882) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.024586 ± 3.55106e-05 (W 7.37787e-05) | 0.024495 ± 5.62257e-05 (W 7.16819e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n257/b1` | 0.024937 ± 0.000102313 (W 0.000286904) | 0.025006 ± 4.45758e-05 (W 8.70632e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.090619 ± 0.00130984 (W 0.000621051) | 0.092084 ± 0.00208403 (W 0.00220649) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.076813 ± 0.00154805 (W 0.000867223) | 0.077475 ± 0.00540433 (W 0.0027619) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n255/b1` | 0.772219 ± 0.0138282 (W 0.0102347) | 0.812274 ± 0.007982 (W 0.0117581) | 0.386465 ± 0.00484051 (W 0.00256907) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 2.00× slower than `lapack-mkl` |  |
| `cholesky/n257/b1` | 0.745824 ± 0.00659874 (W 0.020258) | 0.797071 ± 1.23059 (W 0.0218509) | 0.391885 ± 0.00122252 (W 0.00980161) | · | 🔴 fork 1.90× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n511/b1` | 2.51558 ± 0.0299669 (W 0.0190692) | 2.56644 ± 0.00526887 (W 0.024642) | 1.70593 ± 0.00822465 (W 0.0111956) | · | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `cholesky/n513/b1` | 2.45777 ± 2.70624 (W 0.0332089) | 2.46484 ± 0.0306029 (W 0.0238902) | 1.76142 ± 0.00418758 (W 0.0130589) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n255/b1` | 10.8838 ± 0.0116624 (W 0.0399755) | 11.2165 ± 0.0391967 (W 0.0549383) | 7.7478 ± 0.0155656 (W 0.0358249) | · | 🔴 fork 1.40× slower than `lapack-mkl` |  |
| `eigh/n257/b1` | 10.8814 ± 0.0326987 (W 0.0243934) | 11.1905 ± 0.0566387 (W 0.0811846) | 7.83886 ± 0.0152501 (W 0.00974343) | · | 🔴 fork 1.39× slower than `lapack-mkl` |  |
| `eigh/n511/b1` | 39.3758 ± 0.194391 (W 0.0693623) | 40.2504 ± 0.0830739 (W 0.268374) | 35.5966 ± 0.0682755 (W 0.0519157) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `eigh/n513/b1` | 39.9623 ± 0.123414 (W 0.127142) | 41.4126 ± 0.144046 (W 0.472674) | 35.6373 ± 0.0445242 (W 0.0408883) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `full_piv_lu/n255/b1` | 5.7196 ± 0.018074 (W 0.00995176) | 5.73334 ± 0.0239003 (W 0.0126425) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.37232 ± 0.0282945 (W 0.00986958) | 4.38336 ± 0.0282052 (W 0.0111262) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 24.8898 ± 0.0821842 (W 0.154731) | 24.8961 ± 0.196053 (W 0.148753) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 17.9703 ± 0.0279274 (W 0.0965568) | 17.9427 ± 0.114929 (W 0.134586) | - | · | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.40155 ± 0.0129396 (W 0.0187813) | 1.46745 ± 0.0141618 (W 0.0124987) | 0.661533 ± 0.00174796 (W 0.00428005) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |
| `lu/n257/b1` | 1.27859 ± 0.0186775 (W 0.0151163) | 1.2993 ± 0.0183345 (W 0.00987197) | 0.683765 ± 0.00415667 (W 0.00437563) | · | 🔴 fork 1.87× slower than `lapack-mkl` |  |
| `lu/n511/b1` | 5.41894 ± 0.0195964 (W 0.0219164) | 5.54239 ± 0.0418031 (W 0.0376109) | 3.12242 ± 0.018009 (W 0.0134958) | · | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `lu/n513/b1` | 5.17861 ± 0.0202095 (W 0.0267079) | 5.27683 ± 0.0363073 (W 0.0350195) | 3.17965 ± 0.00813073 (W 0.00856331) | · | 🔴 fork 1.63× slower than `lapack-mkl` |  |
| `qr/n255/b1` | 3.35652 ± 0.0207894 (W 0.0349153) | 6.84467 ± 0.0910233 (W 0.0684046) | 2.89987 ± 0.0134045 (W 0.0133593) | 🔵 fork 2.04× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr/n257/b1` | 3.38977 ± 0.0316086 (W 0.0140863) | 6.95267 ± 0.1099 (W 0.0710281) | 2.95785 ± 0.00161826 (W 0.00610077) | 🔵 fork 2.05× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `qr/n511/b1` | 15.1344 ± 0.0585749 (W 0.396005) | 22.6124 ± 0.104024 (W 0.186841) | 12.3516 ± 0.0239082 (W 0.0133785) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/n513/b1` | 15.5164 ± 0.0270525 (W 0.0498448) | 21.8195 ± 0.202961 (W 0.285467) | 12.4215 ± 0.123487 (W 0.0327026) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/n255/b1` | 2.30562 ± 0.0342811 (W 0.0147631) | 5.33827 ± 0.0600279 (W 0.0655554) | 1.59435 ± 0.0056309 (W 0.0032158) | 🔵 fork 2.32× faster than `faer-upstream` | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `qr_factor/n257/b1` | 2.37029 ± 0.0180215 (W 0.0121866) | 5.5131 ± 0.0223091 (W 0.0875531) | 1.6471 ± 0.00112319 (W 0.00261219) | 🔵 fork 2.33× faster than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `qr_factor/n511/b1` | 8.89576 ± 0.0469645 (W 0.0372189) | 15.2224 ± 0.220041 (W 0.123491) | 5.59946 ± 0.018511 (W 0.0116167) | 🔵 fork 1.71× faster than `faer-upstream` | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `qr_factor/n513/b1` | 9.01139 ± 0.00377646 (W 0.0280928) | 14.0706 ± 0.184678 (W 0.400241) | 5.76296 ± 0.209267 (W 0.0111638) | 🔵 fork 1.56× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n255/b1` | 1.29804 ± 0.0144885 (W 0.0105906) | 1.33725 ± 0.00979194 (W 0.0113688) | 0.665463 ± 0.0016088 (W 0.00253333) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `solve/n257/b1` | 1.25008 ± 0.00325739 (W 0.0101018) | 1.28306 ± 0.0121422 (W 0.0204933) | 0.689335 ± 0.00374812 (W 0.00282557) | · | 🔴 fork 1.81× slower than `lapack-mkl` |  |
| `solve/n511/b1` | 5.32943 ± 0.0341151 (W 0.0415091) | 5.43409 ± 0.018608 (W 0.0522834) | 3.15492 ± 0.00228068 (W 0.0108385) | · | 🔴 fork 1.69× slower than `lapack-mkl` |  |
| `solve/n513/b1` | 5.22303 ± 0.0079359 (W 0.0464397) | 5.32159 ± 0.0163286 (W 0.0391913) | 3.22118 ± 0.0107624 (W 0.00579991) | · | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `svd_thin/n255/b1` | 22.2874 ± 0.0113315 (W 0.0394135) | 22.9405 ± 0.0191941 (W 0.0507908) | 12.6739 ± 0.636694 (W 0.0337967) | · | 🔴 fork 1.76× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n257/b1` | 17.8022 ± 0.0189183 (W 0.153449) | 18.3452 ± 0.0593344 (W 0.0985739) | 12.9691 ± 0.011362 (W 0.0296078) | · | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/n511/b1` | 80.1211 ± 4.78889 (W 0.619785) | 81.8244 ± 0.166202 (W 0.364878) | 58.0432 ± 0.0932478 (W 0.0610587) | · | 🔴 fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n513/b1` | 69.254 ± 0.0929568 (W 0.159822) | 72.5957 ± 0.267807 (W 0.346592) | 58.3057 ± 0.152169 (W 0.0555435) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n255/b1` | 18.0175 ± 0.0303636 (W 0.0332826) | 18.0258 ± 0.0586616 (W 0.0286527) | 6.50446 ± 0.0227353 (W 0.0161609) | · | 🔴 fork 2.77× slower than `lapack-mkl` |  |
| `svd_values/n257/b1` | 14.4979 ± 0.058367 (W 0.0250301) | 14.5201 ± 0.0572373 (W 0.0303584) | 6.62 ± 0.0078708 (W 0.00396131) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `svd_values/n511/b1` | 61.0112 ± 0.250448 (W 0.28757) | 61.0602 ± 0.174042 (W 0.188889) | 28.9017 ± 0.0308782 (W 0.0102242) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |
| `svd_values/n513/b1` | 51.7622 ± 0.224756 (W 0.101236) | 51.7849 ± 0.260171 (W 0.096133) | 29.3462 ± 0.0249689 (W 0.0438935) | · | 🔴 fork 1.76× slower than `lapack-mkl` |  |
| `triangular_solve/n255/b1` | 0.024586 ± 0.000265016 (W 8.78077e-05) | 0.024507 ± 0.000139965 (W 6.91614e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n257/b1` | 0.024876 ± 0.000164257 (W 3.84708e-05) | 0.025047 ± 0.000170317 (W 7.60342e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.094286 ± 0.00245523 (W 0.000537822) | 0.094606 ± 0.00192512 (W 0.00190729) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.085561 ± 0.0063886 (W 0.00153497) | 0.080309 ± 0.00584307 (W 0.00281887) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/255`, `full_piv_lu/257`, `full_piv_lu/511`, `full_piv_lu/513`, `triangular_solve/255`, `triangular_solve/257`, `triangular_solve/511`, `triangular_solve/513`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
