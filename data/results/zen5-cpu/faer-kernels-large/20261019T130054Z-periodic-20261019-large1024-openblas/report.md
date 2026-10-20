# `faer-kernels-large` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a5e6b7d239466fb0d685edc20db6c4f3f3a71411`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `bfb9ef1f43aaefb5c227363a4a5a4d78d7b6b60c`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `a0b78b917535d259ec45220ada7eab9d24080927acc06f70feb70fd4cb128003`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T16:05:22.621534Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels-large --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor openblas --engines faer-fork,lapack-openblas --regimes linalg-large,gemm-large,linalg-boundary --shapes 1024,1024x1024x1024,255,257,511,513 --threads 4,8 --dtypes f64,c64 --reps 5 --aa 6 --prime-ms 250 --label periodic-20261019-large1024-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels-large/20261019T130054Z-periodic-20261019-large1024-openblas/`

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
  - `lapack-openblas` — CBLAS `?gemm` plus LAPACK drivers linked against OpenBLAS: vendor calls and their marshalling, vendor-owned threading. The vendor's own thread budget is set by the harness before the row and read back, and the vendor identity and the dispatched kernel are recorded in the manifest.
    Identity: the OpenBLAS build recorded in this run's manifest (`providers[openblas]`)
    Caveat: LAPACK and BLAS own their threading, so this row's thread budget is the vendor's, not the harness pool's. Where a family has no LAPACK route the row is absent and the CSV says the case was skipped for it.
    As measured: linked static; openblas 0.3.32; kernel dispatched to `Cooperlake`; pthread threading; config `OpenBLAS 0.3.32 DYNAMIC_ARCH NO_AFFINITY Cooperlake MAX_THREADS=24`

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
Each process retains 5 chronological calls; 6 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 1.39%, worst 43.73% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 114 of 736 engine cells exceed 5% and carry `!`; median within-process relative SD 0.36%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 7.54087 ± 0.0501881 (W 0.0282347) | 21.0223 ± 0.10513 (W 0.0669869) | 🔵 fork 2.79× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 120.853 ± 6.5656 (W 0.335947) | 143.251 ± 0.890202 (W 0.198706) | 🔵 fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `full_piv_lu/n1024/b1` | 77.0706 ± 0.261598 (W 0.419446) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 22.1918 ± 3.60213 (W 0.192248) | 33.3357 ± 1.23175 (W 0.528333) | 🔵 fork 1.50× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 50.664 ± 3.89334 (W 0.228189) | 111.894 ± 1.73067 (W 0.362147) | 🔵 fork 2.21× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n1024/b1` | 23.9869 ± 0.112769 (W 0.0841209) | 51.9797 ± 1.15178 (W 0.0657389) | 🔵 fork 2.17× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n1024/b1` | 19.6897 ± 3.71151 (W 0.181583) | 28.8601 ± 1.90417 (W 0.0441658) | 🔵 fork 1.47× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n1024/b1` | 308.328 ± 1.00133 (W 1.4616) | 464.511 ± 6.78951 (W 4.77726) | 🔵 fork 1.51× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 211.982 ± 0.954504 (W 1.26617) | 236.185 ± 3.52794 (W 0.30149) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `triangular_solve/n1024/b1` | 0.113002 ± 0.0131239 (W 0.00249133) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 6.25631 ± 0.0606669 (W 0.040757) | 19.1743 ± 0.145311 (W 0.104428) | 🔵 fork 3.06× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 99.1073 ± 0.760332 (W 0.18991) | 115.709 ± 0.609073 (W 0.0967703) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 68.2845 ± 0.257753 (W 0.374638) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 16.7123 ± 3.12589 (W 0.131481) | 26.8286 ± 2.01829 (W 0.106153) | 🔵 fork 1.61× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 36.7553 ± 3.88972 (W 0.288851) | 98.1407 ± 2.1121 (W 1.13929) | 🔵 fork 2.67× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 18.6531 ± 0.0463911 (W 0.0559366) | 47.6025 ± 1.20455 (W 0.139134) | 🔵 fork 2.55× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n1024/b1` | 16.9198 ± 3.45711 (W 0.233189) | 21.6509 ± 1.95447 (W 0.114375) | 🔵 fork 1.28× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n1024/b1` | 262.562 ± 0.363599 (W 1.14357) | 415.136 ± 6.10487 (W 3.51957) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 198.219 ± 1.01184 (W 1.16911) | 214.655 ± 1.15458 (W 0.445623) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `triangular_solve/n1024/b1` | 0.106729 ± 0.00796078 (W 0.0034649) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 5.47689 ± 0.0218834 (W 0.0309137) | 7.64858 ± 0.0391893 (W 0.0232277) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 118.574 ± 0.196148 (W 0.334574) | 129.121 ± 0.532199 (W 0.289433) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 74.5037 ± 0.199143 (W 0.343306) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 16.9714 ± 2.86911 (W 0.0923714) | 13.8569 ± 0.235551 (W 0.0120091) | 🔴 fork 1.22× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 51.7281 ± 3.00758 (W 0.286882) | 83.95 ± 1.30815 (W 0.26202) | 🔵 fork 1.62× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n1024/b1` | 21.7594 ± 0.135729 (W 0.0718669) | 37.98 ± 0.140706 (W 0.0407973) | 🔵 fork 1.75× faster than `lapack-openblas` |  |
| `solve/n1024/b1` | 17.1567 ± 3.46599 (W 0.211322) | 13.491 ± 0.29143 (W 0.0133185) | 🔴 fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n1024/b1` | 300.339 ± 0.474103 (W 0.783313) | 407.264 ± 9.15861 (W 1.05409) | 🔵 fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n1024/b1` | 204.662 ± 0.696429 (W 0.580345) | 213.131 ± 4.2233 (W 0.579863) | · | `!` between-start range over 5% |
| `triangular_solve/n1024/b1` | 0.127944 ± 0.00388665 (W 0.00224888) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 4.13319 ± 0.019581 (W 0.0483229) | 5.82734 ± 0.031521 (W 0.0314258) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 96.825 ± 0.836523 (W 0.131666) | 101.672 ± 0.3767 (W 0.269941) | · |  |
| `full_piv_lu/n1024/b1` | 63.0138 ± 2.75915 (W 0.100118) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n1024/b1` | 14.1777 ± 2.85998 (W 0.150836) | 7.95325 ± 0.220479 (W 0.052015) | 🔴 fork 1.78× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n1024/b1` | 33.7999 ± 4.13645 (W 0.260826) | 68.4773 ± 0.606912 (W 0.0716095) | 🔵 fork 2.03× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 16.9105 ± 0.0596665 (W 0.155791) | 30.9867 ± 0.497009 (W 0.0784953) | 🔵 fork 1.83× faster than `lapack-openblas` |  |
| `solve/n1024/b1` | 14.3039 ± 3.27853 (W 0.100114) | 7.64754 ± 0.226699 (W 0.0218639) | 🔴 fork 1.87× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n1024/b1` | 255.384 ± 0.858505 (W 1.80347) | 352.277 ± 3.6166 (W 0.53341) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 191.558 ± 0.590454 (W 0.497735) | 201.687 ± 0.417735 (W 0.553716) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `triangular_solve/n1024/b1` | 0.137383 ± 0.0103996 (W 0.00412527) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 20.0032 ± 0.198482 (W 0.180493) | 35.9322 ± 0.164475 (W 0.114674) | 🔵 fork 1.80× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 257.885 ± 0.377385 (W 0.6491) | 419.777 ± 6.13293 (W 0.968128) | 🔵 fork 1.63× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 166.492 ± 0.663659 (W 0.952447) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 41.7069 ± 0.112503 (W 0.129004) | 52.2775 ± 1.20551 (W 1.1321) | 🔵 fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n1024/b1` | 155.111 ± 0.313421 (W 0.518896) | 216.898 ± 2.35637 (W 1.82306) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `qr_factor/n1024/b1` | 70.6412 ± 0.258246 (W 0.319218) | 108.051 ± 2.70809 (W 0.559653) | 🔵 fork 1.53× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n1024/b1` | 42.0271 ± 0.117067 (W 0.200022) | 50.8966 ± 1.91358 (W 0.700957) | 🔵 fork 1.21× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n1024/b1` | 626.725 ± 0.781015 (W 2.05436) | 760.22 ± 9.86512 (W 2.81851) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 393.742 ± 1.56979 (W 1.23397) | 347.353 ± 2.63373 (W 0.821878) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `triangular_solve/n1024/b1` | 0.298604 ± 0.00863336 (W 0.00760776) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 13.7611 ± 0.203173 (W 0.298211) | 27.4939 ± 0.141735 (W 0.093604) | 🔵 fork 2.00× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 181.586 ± 0.497276 (W 0.733661) | 231.799 ± 1.66867 (W 0.686652) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 109.77 ± 0.722012 (W 1.19217) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 30.6397 ± 0.150708 (W 0.139084) | 37.3407 ± 1.57724 (W 1.08505) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n1024/b1` | 102.434 ± 9.0382 (W 1.22325) | 151.327 ± 5.20294 (W 1.66014) | 🔵 fork 1.48× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 46.6923 ± 0.11554 (W 0.40947) | 75.6765 ± 1.80348 (W 1.36367) | 🔵 fork 1.62× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n1024/b1` | 30.4827 ± 0.170503 (W 0.211454) | 33.115 ± 0.303683 (W 0.556143) | 🔵 fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n1024/b1` | 435.781 ± 1.83747 (W 3.33714) | 588.641 ± 6.4855 (W 4.6807) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 293.313 ± 1.76191 (W 6.05272) | 280.335 ± 1.47753 (W 0.986122) | · |  |
| `triangular_solve/n1024/b1` | 0.242592 ± 0.0106138 (W 0.00837691) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 17.1985 ± 0.0352138 (W 0.0804396) | 21.7075 ± 0.156415 (W 0.0121942) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 255.137 ± 0.289798 (W 0.658013) | 402.196 ± 5.65881 (W 0.922327) | 🔵 fork 1.58× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 161.403 ± 0.719753 (W 1.29733) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 36.8425 ± 0.0352231 (W 0.0806345) | 34.69 ± 0.0697793 (W 0.038507) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `qr/n1024/b1` | 150.022 ± 0.30887 (W 0.33925) | 188.279 ± 0.79358 (W 0.32158) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `qr_factor/n1024/b1` | 66.6911 ± 0.203441 (W 0.29192) | 88.8467 ± 0.328957 (W 0.0913753) | 🔵 fork 1.33× faster than `lapack-openblas` |  |
| `solve/n1024/b1` | 36.9991 ± 0.0646598 (W 0.0819808) | 34.6686 ± 0.778591 (W 0.0169956) | 🔴 fork 1.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n1024/b1` | 619.078 ± 1.62309 (W 1.98928) | 705.564 ± 5.98954 (W 1.75261) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 386.889 ± 2.47592 (W 1.40205) | 329.206 ± 2.88984 (W 0.882003) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `triangular_solve/n1024/b1` | 0.323936 ± 0.0123244 (W 0.00504116) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-large, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n1024/b1` | 11.1148 ± 0.0254945 (W 0.0465223) | 13.2033 ± 0.0860214 (W 0.0120548) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `eigh/n1024/b1` | 179.286 ± 0.418759 (W 0.48439) | 213.071 ± 1.50886 (W 0.93181) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n1024/b1` | 104.959 ± 1.40781 (W 0.574893) | - | - | `*` one row has no measurement here |
| `lu/n1024/b1` | 25.4921 ± 0.102698 (W 0.504555) | 18.7672 ± 0.0190359 (W 0.0303367) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `qr/n1024/b1` | 97.1181 ± 8.69783 (W 0.316029) | 128.317 ± 1.43013 (W 0.350862) | 🔵 fork 1.32× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n1024/b1` | 43.4627 ± 0.154789 (W 0.0768012) | 59.9705 ± 0.169795 (W 0.408075) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `solve/n1024/b1` | 25.4503 ± 0.07294 (W 0.170707) | 19.1478 ± 0.019569 (W 0.0484048) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `svd_thin/n1024/b1` | 429.078 ± 1.06798 (W 2.56392) | 523.08 ± 7.65193 (W 2.00714) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `svd_values/n1024/b1` | 285.347 ± 1.1404 (W 1.02167) | 261.347 ± 0.708132 (W 0.717353) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `triangular_solve/n1024/b1` | 0.285328 ± 0.0169271 (W 0.00680534) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/1024`, `triangular_solve/1024`.

## gemm-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6139 ± 0.0241507 (W 0.0130125) | 20.5235 ± 0.0392568 (W 0.0366573) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.05609 ± 0.00951039 (W 0.0170112) | 10.6469 ± 0.0179709 (W 0.018711) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 17.6106 ± 0.0287531 (W 0.0219987) | 20.5442 ± 0.0307784 (W 0.0396152) | 🔵 fork 1.17× faster than `lapack-openblas` |  |

## gemm-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 9.05517 ± 0.014643 (W 0.0171039) | 10.6453 ± 0.0189179 (W 0.0320127) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-large, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 70.0194 ± 0.1163 (W 0.0398687) | 82.3019 ± 0.161049 (W 0.0344268) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-large, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 35.3551 ± 0.0300575 (W 0.0326909) | 42.0763 ± 0.0414289 (W 0.050476) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## gemm-large, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 69.9356 ± 0.0814209 (W 0.0489242) | 82.4368 ± 0.171689 (W 0.0242134) | 🔵 fork 1.18× faster than `lapack-openblas` |  |

## gemm-large, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/1024x1024x1024/b1` | 35.2997 ± 0.0172345 (W 0.04472) | 42.1145 ± 0.0376657 (W 0.0686002) | 🔵 fork 1.19× faster than `lapack-openblas` |  |

## linalg-boundary, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.353245 ± 0.00868997 (W 0.019287) | 0.404505 ± 0.00679491 (W 0.00754891) | 🔵 fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n257/b1` | 0.313259 ± 0.00766245 (W 0.0144134) | 0.349629 ± 0.0059237 (W 0.00405317) | 🔵 fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n511/b1` | 1.15396 ± 0.0198192 (W 0.028456) | 1.59592 ± 0.0209821 (W 0.0172653) | 🔵 fork 1.38× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 1.10259 ± 0.0132024 (W 0.0310293) | 1.60334 ± 0.0198104 (W 0.0242793) | 🔵 fork 1.45× faster than `lapack-openblas` |  |
| `eigh/n255/b1` | 7.24096 ± 0.0166672 (W 0.0145253) | 4.83237 ± 0.0123732 (W 0.00604261) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `eigh/n257/b1` | 7.25268 ± 0.0422844 (W 0.0299858) | 4.8874 ± 0.0150162 (W 0.00566451) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `eigh/n511/b1` | 27.1216 ± 0.0509151 (W 0.0704749) | 19.8426 ± 0.0760913 (W 0.0187674) | 🔴 fork 1.37× slower than `lapack-openblas` |  |
| `eigh/n513/b1` | 27.2328 ± 0.149922 (W 0.0586523) | 20.2005 ± 0.0498549 (W 0.0313819) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `full_piv_lu/n255/b1` | 2.72473 ± 0.00961602 (W 0.0105786) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.99873 ± 0.00140004 (W 0.0018247) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 16.5731 ± 0.141146 (W 0.0655845) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 11.3024 ± 0.0782617 (W 0.0715259) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.003 ± 0.00584089 (W 0.00489848) | 0.703582 ± 0.129305 (W 0.00231202) | 🔴 fork 1.43× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n257/b1` | 0.935242 ± 0.00642903 (W 0.00640584) | 0.837924 ± 0.00770104 (W 0.00299455) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `lu/n511/b1` | 4.89378 ± 0.0478087 (W 0.0969267) | 4.00963 ± 0.0190629 (W 0.00800526) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 4.19647 ± 0.0417199 (W 0.0502175) | 4.06163 ± 0.0307565 (W 0.0107654) | · |  |
| `qr/n255/b1` | 2.00285 ± 0.00529987 (W 0.021896) | 2.49292 ± 0.0152329 (W 0.00402509) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 2.04936 ± 0.0181181 (W 0.0237909) | 2.38636 ± 0.0098015 (W 0.00421815) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 8.59828 ± 0.738077 (W 0.101601) | 10.1103 ± 0.0510138 (W 0.0408742) | 🔵 fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n513/b1` | 10.4726 ± 0.787105 (W 0.100929) | 10.519 ± 0.648011 (W 0.0262952) | · | `!` between-start range over 5% |
| `qr_factor/n255/b1` | 1.44852 ± 0.015479 (W 0.0309868) | 1.22123 ± 0.0177117 (W 0.00259514) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr_factor/n257/b1` | 1.5006 ± 0.0206638 (W 0.0276915) | 1.17175 ± 0.00349672 (W 0.00245478) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `qr_factor/n511/b1` | 5.28428 ± 0.0222067 (W 0.062129) | 4.90594 ± 0.135425 (W 0.0225039) | 🔴 fork 1.08× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n513/b1` | 5.22975 ± 0.0187589 (W 0.0348882) | 5.05421 ± 0.0282959 (W 0.0064114) | · |  |
| `solve/n255/b1` | 0.775106 ± 0.00347931 (W 0.00304358) | 0.563424 ± 0.00320413 (W 0.00198877) | 🔴 fork 1.38× slower than `lapack-openblas` |  |
| `solve/n257/b1` | 0.679631 ± 0.00283383 (W 0.00535921) | 0.575838 ± 0.00303997 (W 0.00222725) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `solve/n511/b1` | 3.48526 ± 0.682108 (W 0.0329409) | 2.91805 ± 0.0122155 (W 0.0044938) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n513/b1` | 4.42696 ± 0.617795 (W 0.0387233) | 2.95878 ± 0.0142767 (W 0.00481611) | 🔴 fork 1.50× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n255/b1` | 14.1378 ± 0.0558091 (W 0.0724999) | 11.1048 ± 0.0330796 (W 0.00950738) | 🔴 fork 1.27× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 10.6342 ± 0.0329557 (W 0.0645723) | 11.2667 ± 0.0400902 (W 0.0096352) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n511/b1` | 60.8738 ± 0.296954 (W 0.283591) | 59.8916 ± 2.6332 (W 0.22131) | · | `!` between-start range over 5% |
| `svd_thin/n513/b1` | 49.4297 ± 0.158212 (W 0.0992293) | 59.8506 ± 0.117982 (W 0.0706038) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/n255/b1` | 11.2024 ± 0.0703371 (W 0.0876734) | 6.23571 ± 0.0346325 (W 0.00355537) | 🔴 fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 8.54325 ± 0.0586983 (W 0.0477229) | 6.28368 ± 0.0149193 (W 0.00456465) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 47.4288 ± 0.42175 (W 0.356658) | 35.8877 ± 0.134192 (W 0.046057) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 37.2436 ± 0.145549 (W 0.0695117) | 36.6633 ± 0.243938 (W 0.0363156) | · |  |
| `triangular_solve/n255/b1` | 0.011442 ± 0.000114545 (W 7.89276e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.012283 ± 0.000493051 (W 8.72365e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.038126 ± 0.000522603 (W 0.000336499) | - | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.040716 ± 0.0032958 (W 0.00162448) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.359872 ± 0.0150466 (W 0.0218461) | 0.406558 ± 0.00595597 (W 0.00433645) | 🔵 fork 1.13× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n257/b1` | 0.364685 ± 0.00984442 (W 0.0281815) | 0.354874 ± 0.00445363 (W 0.00641167) | · | `!` between-start range over 5% |
| `cholesky/n511/b1` | 1.10636 ± 0.0167334 (W 0.0209813) | 1.43984 ± 0.0250804 (W 0.015951) | 🔵 fork 1.30× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 1.04755 ± 0.0196477 (W 0.0408491) | 1.46257 ± 0.018063 (W 0.0191996) | 🔵 fork 1.40× faster than `lapack-openblas` |  |
| `eigh/n255/b1` | 7.0945 ± 0.0262384 (W 0.0238664) | 4.45501 ± 0.0140072 (W 0.00696264) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `eigh/n257/b1` | 7.12927 ± 0.0139318 (W 0.0493193) | 4.45907 ± 0.0116706 (W 0.00886392) | 🔴 fork 1.60× slower than `lapack-openblas` |  |
| `eigh/n511/b1` | 24.7331 ± 0.0979387 (W 0.113286) | 16.1634 ± 0.0356594 (W 0.0322818) | 🔴 fork 1.53× slower than `lapack-openblas` |  |
| `eigh/n513/b1` | 25.0014 ± 0.0667923 (W 0.106774) | 16.6267 ± 0.0461188 (W 0.0289277) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `full_piv_lu/n255/b1` | 2.72425 ± 0.00998829 (W 0.012039) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.99476 ± 0.0104129 (W 0.00241389) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 17.5206 ± 0.0819775 (W 0.114484) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 10.7184 ± 0.0913532 (W 0.0356565) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.01482 ± 0.00956045 (W 0.00804549) | 0.651845 ± 0.127654 (W 0.00237233) | 🔴 fork 1.56× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n257/b1` | 0.968416 ± 0.0103186 (W 0.0171179) | 0.774131 ± 0.00412537 (W 0.00455543) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `lu/n511/b1` | 4.7198 ± 0.0302708 (W 0.0446742) | 3.10331 ± 0.0146577 (W 0.00663164) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 4.04876 ± 0.0354888 (W 0.0833277) | 3.15126 ± 0.0285614 (W 0.0136916) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `qr/n255/b1` | 1.83398 ± 0.0107311 (W 0.0232995) | 2.42385 ± 0.0121458 (W 0.00708951) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 1.84977 ± 0.00866321 (W 0.023612) | 2.34226 ± 0.0208464 (W 0.00649286) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 7.11825 ± 0.749222 (W 0.0542811) | 8.55613 ± 0.0581024 (W 0.0187848) | 🔵 fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n513/b1` | 8.99659 ± 0.0589192 (W 0.0629709) | 8.78421 ± 0.663851 (W 0.019751) | · | `!` between-start range over 5% |
| `qr_factor/n255/b1` | 1.39885 ± 0.0128718 (W 0.0160006) | 1.19139 ± 0.00663558 (W 0.00233399) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr_factor/n257/b1` | 1.44533 ± 0.0102356 (W 0.0121683) | 1.1532 ± 0.00531318 (W 0.00233365) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `qr_factor/n511/b1` | 4.85162 ± 0.0216514 (W 0.0288061) | 4.1038 ± 0.0160282 (W 0.00616938) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `qr_factor/n513/b1` | 4.81909 ± 0.0210284 (W 0.0237849) | 4.20309 ± 0.0102937 (W 0.0079694) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `solve/n255/b1` | 0.780202 ± 0.00329741 (W 0.00591694) | 0.521328 ± 0.00311445 (W 0.00259309) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `solve/n257/b1` | 0.698974 ± 0.0103458 (W 0.020424) | 0.531076 ± 0.00314147 (W 0.00333453) | 🔴 fork 1.32× slower than `lapack-openblas` |  |
| `solve/n511/b1` | 4.62919 ± 0.688451 (W 0.0465985) | 2.05069 ± 0.0181506 (W 0.00459325) | 🔴 fork 2.26× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n513/b1` | 4.26661 ± 0.0805111 (W 0.0920497) | 2.0743 ± 0.0121727 (W 0.00841669) | 🔴 fork 2.06× slower than `lapack-openblas` |  |
| `svd_thin/n255/b1` | 13.9271 ± 0.0393656 (W 0.0314676) | 10.9104 ± 0.018074 (W 0.0144374) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 10.3379 ± 0.0416344 (W 0.0328956) | 10.9512 ± 0.0351733 (W 0.00958068) | 🔵 fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n511/b1` | 58.8966 ± 0.15989 (W 0.513535) | 54.2639 ± 0.399546 (W 0.0587652) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 44.2043 ± 0.0751044 (W 0.0780763) | 55.1114 ± 0.41882 (W 0.0631759) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `svd_values/n255/b1` | 11.2712 ± 0.0292569 (W 0.0236773) | 6.18629 ± 0.0193481 (W 0.00468462) | 🔴 fork 1.82× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 8.74249 ± 0.0531879 (W 0.0313644) | 6.26982 ± 0.0272312 (W 0.00714474) | 🔴 fork 1.39× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 48.9376 ± 0.351657 (W 0.36823) | 35.1898 ± 0.374038 (W 0.0220681) | 🔴 fork 1.39× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 35.6394 ± 0.0793386 (W 0.108493) | 35.8922 ± 0.310911 (W 0.0371196) | · |  |
| `triangular_solve/n255/b1` | 0.011376 ± 0.000118412 (W 7.82256e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.012333 ± 0.000494113 (W 7.58681e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.041682 ± 0.00196281 (W 0.000232984) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.041267 ± 0.00130309 (W 0.000649656) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.348958 ± 0.0188077 (W 0.021626) | 0.360727 ± 0.00669135 (W 0.00203603) | · | `!` between-start range over 5% |
| `cholesky/n257/b1` | 0.30877 ± 0.0103423 (W 0.00739551) | 0.303478 ± 0.00655942 (W 0.0018702) | · | `!` between-start range over 5% |
| `cholesky/n511/b1` | 1.1385 ± 0.0153037 (W 0.0248539) | 1.38053 ± 0.0051376 (W 0.00470077) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 1.07319 ± 0.00964375 (W 0.0215148) | 1.37267 ± 0.00812621 (W 0.00401978) | 🔵 fork 1.28× faster than `lapack-openblas` |  |
| `eigh/n255/b1` | 7.24882 ± 0.0244267 (W 0.0108627) | 4.77279 ± 0.0327443 (W 0.00302707) | 🔴 fork 1.52× slower than `lapack-openblas` |  |
| `eigh/n257/b1` | 7.23012 ± 0.0376683 (W 0.0374541) | 4.82726 ± 0.00345116 (W 0.00699968) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `eigh/n511/b1` | 26.9912 ± 0.130585 (W 0.0933715) | 19.3576 ± 0.0540255 (W 0.025006) | 🔴 fork 1.39× slower than `lapack-openblas` |  |
| `eigh/n513/b1` | 27.1441 ± 0.124762 (W 0.0722415) | 19.7313 ± 0.0289263 (W 0.0176384) | 🔴 fork 1.38× slower than `lapack-openblas` |  |
| `full_piv_lu/n255/b1` | 2.6234 ± 0.00443098 (W 0.00770146) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.88966 ± 0.00392953 (W 0.00205031) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 16.0882 ± 0.185666 (W 0.101191) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 10.7962 ± 0.0507274 (W 0.125862) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 0.901431 ± 0.00372479 (W 0.00594953) | 0.507265 ± 0.0144349 (W 0.00220004) | 🔴 fork 1.78× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n257/b1` | 0.809661 ± 0.0028655 (W 0.00421964) | 0.518319 ± 0.00218868 (W 0.00290279) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `lu/n511/b1` | 4.35189 ± 0.0715929 (W 0.0802988) | 2.75946 ± 0.0614786 (W 0.00370601) | 🔴 fork 1.58× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 3.61502 ± 0.0643912 (W 0.0465118) | 2.67248 ± 0.0492765 (W 0.00359499) | 🔴 fork 1.35× slower than `lapack-openblas` |  |
| `qr/n255/b1` | 1.89563 ± 0.0165285 (W 0.0247254) | 2.30468 ± 0.0237969 (W 0.00351371) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 1.95133 ± 0.00662088 (W 0.0210775) | 2.22089 ± 0.0251368 (W 0.00505505) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 7.98691 ± 0.725997 (W 0.133551) | 9.43952 ± 0.150802 (W 0.0133847) | 🔵 fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n513/b1` | 9.80262 ± 0.737562 (W 0.076556) | 9.71871 ± 0.117056 (W 0.0116572) | · | `!` between-start range over 5% |
| `qr_factor/n255/b1` | 1.34051 ± 0.00670411 (W 0.0291984) | 1.13252 ± 0.0134641 (W 0.00165227) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `qr_factor/n257/b1` | 1.37627 ± 0.0181233 (W 0.0298967) | 1.09062 ± 0.0107685 (W 0.00178156) | 🔴 fork 1.26× slower than `lapack-openblas` |  |
| `qr_factor/n511/b1` | 4.87131 ± 0.228488 (W 0.0927743) | 4.59075 ± 0.0653052 (W 0.00657794) | 🔴 fork 1.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n513/b1` | 4.82428 ± 0.0200706 (W 0.0227945) | 4.69925 ± 0.074126 (W 0.0046975) | · |  |
| `solve/n255/b1` | 0.672652 ± 0.00386842 (W 0.00281716) | 0.490696 ± 0.0106144 (W 0.00237097) | 🔴 fork 1.37× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n257/b1` | 0.573112 ± 0.00227712 (W 0.00635383) | 0.499704 ± 0.00316906 (W 0.00276916) | 🔴 fork 1.15× slower than `lapack-openblas` |  |
| `solve/n511/b1` | 3.13437 ± 0.611898 (W 0.03661) | 2.59212 ± 0.045746 (W 0.00633433) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n513/b1` | 3.82677 ± 0.569009 (W 0.0613491) | 2.618 ± 0.0259398 (W 0.00558612) | 🔴 fork 1.46× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n255/b1` | 14.1644 ± 0.0192173 (W 0.0811362) | 10.8901 ± 0.0262848 (W 0.0136862) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 10.6446 ± 0.0402143 (W 0.0606473) | 11.0693 ± 0.0218314 (W 0.0138494) | · |  |
| `svd_thin/n511/b1` | 60.6215 ± 0.381157 (W 0.436196) | 56.8481 ± 0.285736 (W 0.159317) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 48.9985 ± 0.0497137 (W 0.0766903) | 58.3555 ± 0.169061 (W 0.0561437) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `svd_values/n255/b1` | 11.192 ± 0.029983 (W 0.0787079) | 6.09611 ± 0.01594 (W 0.00569913) | 🔴 fork 1.84× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 8.60104 ± 0.0149907 (W 0.0323539) | 6.22018 ± 0.0161904 (W 0.00420265) | 🔴 fork 1.38× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 47.6046 ± 0.189045 (W 0.286918) | 35.7132 ± 0.105432 (W 0.0200532) | 🔴 fork 1.33× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 36.9558 ± 0.102866 (W 0.0668284) | 36.1868 ± 0.231997 (W 0.0202336) | · |  |
| `triangular_solve/n255/b1` | 0.0122625 ± 0.000104289 (W 7.68708e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.013956 ± 0.000816279 (W 5.08239e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.0427345 ± 0.000817903 (W 0.000360691) | - | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.0493175 ± 0.0050321 (W 0.00273763) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.361715 ± 0.00666303 (W 0.0169723) | 0.361406 ± 0.00230432 (W 0.00284764) | · |  |
| `cholesky/n257/b1` | 0.368078 ± 0.014661 (W 0.0258126) | 0.304312 ± 0.00299999 (W 0.0020164) | 🔴 fork 1.21× slower than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n511/b1` | 1.08521 ± 0.0131332 (W 0.0168134) | 1.22287 ± 0.00772251 (W 0.00502484) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 1.01194 ± 0.0219062 (W 0.0353333) | 1.23701 ± 0.00823922 (W 0.00513484) | 🔵 fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n255/b1` | 7.09712 ± 0.050542 (W 0.0290475) | 4.4123 ± 0.0393816 (W 0.00787548) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `eigh/n257/b1` | 7.11145 ± 0.0348023 (W 0.0348374) | 4.39155 ± 0.0062744 (W 0.00526437) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `eigh/n511/b1` | 24.6181 ± 0.136439 (W 0.0735022) | 15.7374 ± 0.0319607 (W 0.020544) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `eigh/n513/b1` | 24.9443 ± 0.305675 (W 0.0594565) | 16.1034 ± 0.0477499 (W 0.0188156) | 🔴 fork 1.55× slower than `lapack-openblas` |  |
| `full_piv_lu/n255/b1` | 2.62698 ± 0.0149856 (W 0.00521944) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 1.88446 ± 0.00777659 (W 0.00326874) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 16.7532 ± 0.446429 (W 0.161626) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n513/b1` | 10.1384 ± 0.0923163 (W 0.0844393) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 0.906413 ± 0.00500486 (W 0.0123843) | 0.446584 ± 0.012004 (W 0.00212821) | 🔴 fork 2.03× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n257/b1` | 0.843923 ± 0.0229376 (W 0.0197075) | 0.455933 ± 0.0126794 (W 0.00279172) | 🔴 fork 1.85× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n511/b1` | 4.1173 ± 0.0835133 (W 0.116877) | 1.74289 ± 0.0488184 (W 0.00860585) | 🔴 fork 2.36× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n513/b1` | 3.41532 ± 0.080431 (W 0.0834893) | 1.76652 ± 0.0591814 (W 0.00511925) | 🔴 fork 1.93× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n255/b1` | 1.71263 ± 0.0101278 (W 0.0155671) | 2.26706 ± 0.0233056 (W 0.00452576) | 🔵 fork 1.32× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 1.75141 ± 0.0140321 (W 0.0139984) | 2.17264 ± 0.00719839 (W 0.0037338) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 6.55525 ± 0.70999 (W 0.0247527) | 8.0542 ± 0.133627 (W 0.0213744) | 🔵 fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n513/b1` | 8.32561 ± 0.0303788 (W 0.0659895) | 8.03555 ± 0.0742983 (W 0.0137537) | · |  |
| `qr_factor/n255/b1` | 1.30903 ± 0.00748539 (W 0.0106226) | 1.11731 ± 0.0107616 (W 0.0017025) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr_factor/n257/b1` | 1.34003 ± 0.00472625 (W 0.0173461) | 1.0738 ± 0.0125492 (W 0.00258218) | 🔴 fork 1.25× slower than `lapack-openblas` |  |
| `qr_factor/n511/b1` | 4.55648 ± 0.0182275 (W 0.0176683) | 3.84466 ± 0.0564388 (W 0.00521783) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `qr_factor/n513/b1` | 4.5298 ± 0.0290167 (W 0.0201158) | 3.911 ± 0.0791755 (W 0.00538691) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `solve/n255/b1` | 0.675339 ± 0.00154921 (W 0.00262843) | 0.448708 ± 0.0123102 (W 0.00319032) | 🔴 fork 1.51× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n257/b1` | 0.606624 ± 0.0174429 (W 0.021616) | 0.451703 ± 0.0133693 (W 0.00300623) | 🔴 fork 1.34× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n511/b1` | 4.02913 ± 0.669906 (W 0.0642864) | 1.85142 ± 0.0706081 (W 0.00623068) | 🔴 fork 2.18× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n513/b1` | 3.63723 ± 0.100651 (W 0.0859601) | 1.86903 ± 0.0612372 (W 0.00583581) | 🔴 fork 1.95× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n255/b1` | 13.9786 ± 0.0405275 (W 0.0310714) | 10.7162 ± 0.0211806 (W 0.0176186) | 🔴 fork 1.30× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 10.4017 ± 0.0185488 (W 0.0292665) | 10.7636 ± 0.0523535 (W 0.0120448) | · |  |
| `svd_thin/n511/b1` | 58.3906 ± 0.264021 (W 0.368403) | 52.7159 ± 0.298801 (W 0.286767) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 43.9389 ± 0.0438934 (W 0.128397) | 53.6929 ± 0.220879 (W 0.107608) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `svd_values/n255/b1` | 11.3175 ± 0.0330832 (W 0.026259) | 6.10089 ± 0.0146966 (W 0.0030085) | 🔴 fork 1.86× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 8.73775 ± 0.0386603 (W 0.0558894) | 6.19778 ± 0.00721052 (W 0.00291707) | 🔴 fork 1.41× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 48.5832 ± 0.310945 (W 0.526305) | 35.0455 ± 0.265178 (W 0.0480918) | 🔴 fork 1.39× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 35.4496 ± 0.0745289 (W 0.0853832) | 35.5899 ± 0.240174 (W 0.0434727) | · |  |
| `triangular_solve/n255/b1` | 0.012198 ± 8.33083e-05 (W 7.40549e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n257/b1` | 0.0137605 ± 0.000843583 (W 6.21713e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n511/b1` | 0.0461215 ± 0.00171953 (W 0.000357353) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.048365 ± 0.00310894 (W 0.00203444) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.768691 ± 0.00444208 (W 0.0126613) | 0.694079 ± 0.00563414 (W 0.00227094) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `cholesky/n257/b1` | 0.753931 ± 0.00471672 (W 0.0068389) | 0.679859 ± 0.00491615 (W 0.00213367) | 🔴 fork 1.11× slower than `lapack-openblas` |  |
| `cholesky/n511/b1` | 3.11389 ± 0.02271 (W 0.0158449) | 3.94002 ± 0.01819 (W 0.0148556) | 🔵 fork 1.27× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 3.08253 ± 0.108682 (W 0.0317678) | 3.95277 ± 0.0116363 (W 0.00715741) | 🔵 fork 1.28× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n255/b1` | 11.537 ± 0.0243759 (W 0.0394632) | 11.4039 ± 0.0439733 (W 0.0154926) | · |  |
| `eigh/n257/b1` | 11.5372 ± 0.0155031 (W 0.0286149) | 11.7244 ± 0.0631491 (W 0.0134131) | · |  |
| `eigh/n511/b1` | 46.5472 ± 0.0933212 (W 0.0860738) | 54.0235 ± 0.143475 (W 0.0821115) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `eigh/n513/b1` | 47.2553 ± 0.112586 (W 0.103129) | 54.5638 ± 0.723893 (W 0.0459627) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `full_piv_lu/n255/b1` | 5.92357 ± 0.0277079 (W 0.014572) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.57843 ± 0.0287966 (W 0.0194812) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 27.2 ± 0.110035 (W 0.153354) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 20.9783 ± 0.0924045 (W 0.279113) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.6036 ± 0.00731898 (W 0.0177657) | 1.33314 ± 0.0130171 (W 0.00305494) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `lu/n257/b1` | 1.46322 ± 0.00463764 (W 0.0146163) | 1.35199 ± 0.0114569 (W 0.00279951) | 🔴 fork 1.08× slower than `lapack-openblas` |  |
| `lu/n511/b1` | 7.46877 ± 0.0246416 (W 0.0433207) | 6.23758 ± 0.0582872 (W 0.0209401) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 7.23078 ± 0.0193194 (W 0.0330154) | 6.32241 ± 0.0950776 (W 0.0200952) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `qr/n255/b1` | 4.56085 ± 0.0427736 (W 0.0544425) | 5.28517 ± 0.0307237 (W 0.00584259) | 🔵 fork 1.16× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 4.67697 ± 0.0276633 (W 0.0548403) | 5.70726 ± 0.042107 (W 0.00783971) | 🔵 fork 1.22× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 23.4991 ± 0.0625216 (W 0.0707953) | 26.7731 ± 0.165084 (W 0.0442743) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `qr/n513/b1` | 24.1292 ± 0.044038 (W 0.0722975) | 28.1307 ± 0.0561109 (W 0.0626437) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `qr_factor/n255/b1` | 2.92946 ± 0.0267189 (W 0.0549303) | 2.62338 ± 0.00751903 (W 0.00540169) | 🔴 fork 1.12× slower than `lapack-openblas` |  |
| `qr_factor/n257/b1` | 2.99755 ± 0.0605569 (W 0.0548904) | 2.84306 ± 0.0134418 (W 0.00506975) | 🔴 fork 1.05× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n511/b1` | 12.149 ± 0.0613609 (W 0.0750865) | 13.1041 ± 0.11798 (W 0.0250644) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n513/b1` | 12.5131 ± 0.048161 (W 0.0568005) | 13.8924 ± 0.0546984 (W 0.0238665) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `solve/n255/b1` | 1.48769 ± 0.00876462 (W 0.016699) | 1.30368 ± 0.00200807 (W 0.00314949) | 🔴 fork 1.14× slower than `lapack-openblas` |  |
| `solve/n257/b1` | 1.44348 ± 0.0151413 (W 0.0171128) | 1.32747 ± 0.0141181 (W 0.00284834) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `solve/n511/b1` | 7.44835 ± 0.0244295 (W 0.0266824) | 6.122 ± 0.0343699 (W 0.00754742) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `solve/n513/b1` | 7.35056 ± 0.0119422 (W 0.033071) | 6.20799 ± 0.0636955 (W 0.00953027) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/n255/b1` | 22.7922 ± 0.0339448 (W 0.0526065) | 16.0979 ± 0.0378316 (W 0.0200177) | 🔴 fork 1.42× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 18.3991 ± 0.0622883 (W 0.0654986) | 16.9437 ± 0.0299716 (W 0.0252295) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `svd_thin/n511/b1` | 94.0818 ± 0.161092 (W 0.363864) | 81.0319 ± 0.273989 (W 0.0732531) | 🔴 fork 1.16× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 86.0059 ± 0.200511 (W 0.256024) | 84.0893 ± 0.278963 (W 0.0819191) | · |  |
| `svd_values/n255/b1` | 17.2725 ± 0.0766294 (W 0.0615763) | 8.01916 ± 0.0388627 (W 0.00950292) | 🔴 fork 2.15× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 13.7832 ± 0.0814116 (W 0.0549931) | 8.29991 ± 0.0363799 (W 0.0101836) | 🔴 fork 1.66× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 64.7699 ± 0.143043 (W 0.433983) | 36.6145 ± 0.111397 (W 0.118085) | 🔴 fork 1.77× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 57.3181 ± 0.0993144 (W 0.275665) | 37.5664 ± 0.114765 (W 0.0486437) | 🔴 fork 1.53× slower than `lapack-openblas` |  |
| `triangular_solve/n255/b1` | 0.02388 ± 0.000230979 (W 0.000129099) | - | - | `*` one row has no measurement here |
| `triangular_solve/n257/b1` | 0.0241855 ± 0.000151504 (W 7.22708e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.088249 ± 0.00273289 (W 0.00138655) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.071608 ± 0.001053 (W 0.00125894) | - | - | `*` one row has no measurement here |

## linalg-boundary, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.772637 ± 0.0093147 (W 0.0177473) | 0.954628 ± 0.00935463 (W 0.00196508) | 🔵 fork 1.24× faster than `lapack-openblas` |  |
| `cholesky/n257/b1` | 0.759051 ± 0.009957 (W 0.0143896) | 0.62416 ± 0.0035253 (W 0.00324238) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `cholesky/n511/b1` | 2.537 ± 0.0290804 (W 0.0251057) | 3.11067 ± 0.0434596 (W 0.0149069) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 2.46626 ± 0.00831515 (W 0.0197271) | 2.80013 ± 0.0119381 (W 0.00910404) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `eigh/n255/b1` | 10.9089 ± 0.0326941 (W 0.0300792) | 10.1716 ± 0.0433285 (W 0.0127631) | 🔴 fork 1.07× slower than `lapack-openblas` |  |
| `eigh/n257/b1` | 10.9087 ± 0.0227639 (W 0.0264193) | 10.4464 ± 0.0530174 (W 0.00871272) | · |  |
| `eigh/n511/b1` | 39.2541 ± 0.0248432 (W 0.122628) | 41.4086 ± 0.119186 (W 0.194099) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `eigh/n513/b1` | 39.8989 ± 0.0539717 (W 0.072987) | 41.6147 ± 0.311837 (W 0.0432533) | · |  |
| `full_piv_lu/n255/b1` | 5.90208 ± 0.014139 (W 0.0113023) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.54097 ± 0.033273 (W 0.0101083) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 25.5022 ± 0.111855 (W 0.0732522) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 18.9458 ± 0.137956 (W 0.102459) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.56108 ± 0.0129441 (W 0.0226739) | 0.954987 ± 0.0222867 (W 0.00222675) | 🔴 fork 1.63× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n257/b1` | 1.42401 ± 0.00620759 (W 0.0178627) | 0.963483 ± 0.0113437 (W 0.00236164) | 🔴 fork 1.48× slower than `lapack-openblas` |  |
| `lu/n511/b1` | 6.34163 ± 0.0721856 (W 0.045863) | 3.91073 ± 0.0273182 (W 0.0130257) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 6.09879 ± 0.0561595 (W 0.0483333) | 3.95334 ± 0.0758636 (W 0.0159708) | 🔴 fork 1.54× slower than `lapack-openblas` |  |
| `qr/n255/b1` | 3.47682 ± 0.0166769 (W 0.0219852) | 4.76334 ± 0.0223692 (W 0.00485159) | 🔵 fork 1.37× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 3.54308 ± 0.0203975 (W 0.0339793) | 5.00586 ± 0.025163 (W 0.00276469) | 🔵 fork 1.41× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 16.1457 ± 0.0867085 (W 0.0581896) | 20.2585 ± 0.293237 (W 0.024999) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `qr/n513/b1` | 16.5094 ± 0.053832 (W 0.0564419) | 20.8679 ± 0.18193 (W 0.05795) | 🔵 fork 1.26× faster than `lapack-openblas` |  |
| `qr_factor/n255/b1` | 2.43581 ± 0.0107425 (W 0.0293843) | 2.33068 ± 0.00968818 (W 0.0034369) | · |  |
| `qr_factor/n257/b1` | 2.49845 ± 0.0125102 (W 0.0212267) | 2.47761 ± 0.00730183 (W 0.00271379) | · |  |
| `qr_factor/n511/b1` | 9.47144 ± 0.0488929 (W 0.0428853) | 9.86177 ± 0.0852577 (W 0.0137019) | · |  |
| `qr_factor/n513/b1` | 9.62929 ± 0.0446685 (W 0.0353761) | 10.2816 ± 0.138073 (W 0.0193539) | 🔵 fork 1.07× faster than `lapack-openblas` |  |
| `solve/n255/b1` | 1.43525 ± 0.0185112 (W 0.0166677) | 0.956741 ± 0.0132862 (W 0.00138377) | 🔴 fork 1.50× slower than `lapack-openblas` |  |
| `solve/n257/b1` | 1.42024 ± 0.0414768 (W 0.0127629) | 0.959347 ± 0.00900783 (W 0.00183342) | 🔴 fork 1.48× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n511/b1` | 6.25208 ± 0.0179575 (W 0.042239) | 3.87563 ± 0.0585684 (W 0.0102821) | 🔴 fork 1.61× slower than `lapack-openblas` |  |
| `solve/n513/b1` | 6.17381 ± 0.976513 (W 0.04095) | 3.90672 ± 0.131765 (W 0.0141401) | 🔴 fork 1.58× slower than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n255/b1` | 21.6649 ± 0.0689392 (W 0.0641219) | 13.9151 ± 0.0274945 (W 0.0246265) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 17.2329 ± 0.12093 (W 0.0933247) | 14.6041 ± 0.0169919 (W 0.01778) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/n511/b1` | 79.5824 ± 0.296181 (W 0.276367) | 60.7171 ± 0.194588 (W 0.0715767) | 🔴 fork 1.31× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 69.0752 ± 0.236933 (W 0.146352) | 62.988 ± 0.272394 (W 0.0622235) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `svd_values/n255/b1` | 17.3532 ± 0.0270909 (W 0.0590989) | 7.33112 ± 0.0255594 (W 0.0071714) | 🔴 fork 2.37× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 13.9587 ± 0.122462 (W 0.034907) | 7.6169 ± 0.0122552 (W 0.0066814) | 🔴 fork 1.83× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 61.0201 ± 0.387356 (W 0.362672) | 29.0191 ± 0.0687232 (W 0.0473672) | 🔴 fork 2.10× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 51.3967 ± 0.247935 (W 0.0823821) | 29.6468 ± 0.121012 (W 0.0528074) | 🔴 fork 1.73× slower than `lapack-openblas` |  |
| `triangular_solve/n255/b1` | 0.0238195 ± 0.000216423 (W 0.000116536) | - | - | `*` one row has no measurement here |
| `triangular_solve/n257/b1` | 0.024366 ± 0.000179467 (W 9.7052e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.086421 ± 0.000625325 (W 0.0019763) | - | - | `*` one row has no measurement here |
| `triangular_solve/n513/b1` | 0.0810565 ± 0.00411113 (W 0.00294932) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-boundary, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.77595 ± 0.00511773 (W 0.00668181) | 0.646317 ± 0.00399913 (W 0.00249552) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `cholesky/n257/b1` | 0.756048 ± 0.00897607 (W 0.00567179) | 0.636142 ± 0.00277604 (W 0.00299013) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `cholesky/n511/b1` | 3.05265 ± 0.0114459 (W 0.0192956) | 3.56386 ± 0.0186841 (W 0.00469346) | 🔵 fork 1.17× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 3.01764 ± 0.012672 (W 0.0384809) | 3.57123 ± 0.00703765 (W 0.00456144) | 🔵 fork 1.18× faster than `lapack-openblas` |  |
| `eigh/n255/b1` | 11.5242 ± 0.0171463 (W 0.0275134) | 11.3396 ± 0.0224342 (W 0.00689972) | · |  |
| `eigh/n257/b1` | 11.5251 ± 0.0171972 (W 0.0371907) | 11.6422 ± 0.0246692 (W 0.0113069) | · |  |
| `eigh/n511/b1` | 46.5804 ± 0.0445562 (W 0.142044) | 53.1481 ± 0.152796 (W 0.0409742) | 🔵 fork 1.14× faster than `lapack-openblas` |  |
| `eigh/n513/b1` | 47.274 ± 0.0964644 (W 0.117406) | 53.5652 ± 0.0670076 (W 0.0258631) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `full_piv_lu/n255/b1` | 5.78628 ± 0.0362969 (W 0.00765595) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.4615 ± 0.0381533 (W 0.0172099) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 26.4879 ± 0.0445481 (W 0.108961) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 20.3317 ± 0.0546459 (W 0.0587498) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.48287 ± 0.0096468 (W 0.0118413) | 1.2551 ± 0.00222887 (W 0.00309652) | 🔴 fork 1.18× slower than `lapack-openblas` |  |
| `lu/n257/b1` | 1.3353 ± 0.0107993 (W 0.0216576) | 1.27612 ± 0.00350783 (W 0.00265539) | · |  |
| `lu/n511/b1` | 6.63059 ± 0.026169 (W 0.0223558) | 5.45591 ± 0.0200182 (W 0.00573708) | 🔴 fork 1.22× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 6.44388 ± 0.0237968 (W 0.0369255) | 5.51474 ± 0.0172672 (W 0.00961839) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `qr/n255/b1` | 4.47911 ± 0.0277741 (W 0.0579491) | 5.06899 ± 0.0174391 (W 0.00480979) | 🔵 fork 1.13× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 4.5607 ± 0.0386885 (W 0.0466263) | 5.52364 ± 0.0249769 (W 0.0056211) | 🔵 fork 1.21× faster than `lapack-openblas` |  |
| `qr/n511/b1` | 22.5239 ± 0.0761785 (W 0.0932929) | 25.1161 ± 0.0369302 (W 0.0315035) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `qr/n513/b1` | 23.1996 ± 0.0312536 (W 0.0547682) | 26.5935 ± 0.0929968 (W 0.0339569) | 🔵 fork 1.15× faster than `lapack-openblas` |  |
| `qr_factor/n255/b1` | 2.7433 ± 0.0367281 (W 0.0321297) | 2.51539 ± 0.00322893 (W 0.00464627) | 🔴 fork 1.09× slower than `lapack-openblas` |  |
| `qr_factor/n257/b1` | 2.82329 ± 0.0156818 (W 0.0483617) | 2.7453 ± 0.0110189 (W 0.00404791) | · |  |
| `qr_factor/n511/b1` | 11.4439 ± 0.0515311 (W 0.0855763) | 12.3763 ± 0.0145543 (W 0.0121692) | 🔵 fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n513/b1` | 11.777 ± 0.0699573 (W 0.0576719) | 13.1598 ± 0.0325376 (W 0.0110083) | 🔵 fork 1.12× faster than `lapack-openblas` |  |
| `solve/n255/b1` | 1.36936 ± 0.00206521 (W 0.0149156) | 1.24496 ± 0.00234517 (W 0.00289231) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `solve/n257/b1` | 1.33009 ± 0.00542764 (W 0.0123198) | 1.27241 ± 0.00210069 (W 0.00290352) | · |  |
| `solve/n511/b1` | 6.60204 ± 0.0225483 (W 0.028204) | 5.50693 ± 0.0190993 (W 0.00491727) | 🔴 fork 1.20× slower than `lapack-openblas` |  |
| `solve/n513/b1` | 6.50306 ± 0.0186785 (W 0.0502932) | 5.56842 ± 0.030553 (W 0.00872575) | 🔴 fork 1.17× slower than `lapack-openblas` |  |
| `svd_thin/n255/b1` | 22.7422 ± 0.0607885 (W 0.109774) | 15.8012 ± 0.052881 (W 0.0255002) | 🔴 fork 1.44× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 18.3179 ± 0.0305831 (W 0.0878311) | 16.6287 ± 0.0469777 (W 0.0227714) | 🔴 fork 1.10× slower than `lapack-openblas` |  |
| `svd_thin/n511/b1` | 94.0533 ± 0.177069 (W 0.219027) | 78.7797 ± 0.294799 (W 0.106141) | 🔴 fork 1.19× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 85.8154 ± 0.129008 (W 0.155957) | 81.6224 ± 0.210318 (W 0.108453) | 🔴 fork 1.05× slower than `lapack-openblas` |  |
| `svd_values/n255/b1` | 17.2838 ± 0.0769106 (W 0.0662643) | 7.8936 ± 0.0105522 (W 0.00777861) | 🔴 fork 2.19× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 13.8153 ± 0.0422767 (W 0.0637903) | 8.23813 ± 0.0162615 (W 0.00847781) | 🔴 fork 1.68× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 64.3689 ± 0.170103 (W 0.300768) | 35.6285 ± 0.0586172 (W 0.0486849) | 🔴 fork 1.81× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 57.1355 ± 0.133881 (W 0.222136) | 36.6796 ± 0.0827664 (W 0.0383716) | 🔴 fork 1.56× slower than `lapack-openblas` |  |
| `triangular_solve/n255/b1` | 0.02137 ± 0.00178959 (W 6.52505e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n257/b1` | 0.021871 ± 0.00137328 (W 9.6575e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n511/b1` | 0.0897825 ± 0.00329877 (W 0.000770671) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.07531 ± 0.00126702 (W 0.00102917) | - | - | `*` one row has no measurement here |

## linalg-boundary, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n255/b1` | 0.766139 ± 0.0133655 (W 0.0203412) | 0.91377 ± 0.00284345 (W 0.0032395) | 🔵 fork 1.19× faster than `lapack-openblas` |  |
| `cholesky/n257/b1` | 0.744946 ± 0.0108862 (W 0.0139475) | 0.581541 ± 0.00247849 (W 0.00151466) | 🔴 fork 1.28× slower than `lapack-openblas` |  |
| `cholesky/n511/b1` | 2.49478 ± 0.0194061 (W 0.0247747) | 2.76437 ± 0.0179376 (W 0.00805013) | 🔵 fork 1.11× faster than `lapack-openblas` |  |
| `cholesky/n513/b1` | 2.40775 ± 0.0134829 (W 0.0205976) | 2.4358 ± 0.0141496 (W 0.00640336) | · |  |
| `eigh/n255/b1` | 10.912 ± 0.411571 (W 0.0450208) | 10.0627 ± 0.134683 (W 0.0108164) | 🔴 fork 1.08× slower than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n257/b1` | 10.901 ± 0.0197014 (W 0.0258535) | 10.3209 ± 0.0306802 (W 0.0147462) | 🔴 fork 1.06× slower than `lapack-openblas` |  |
| `eigh/n511/b1` | 39.2447 ± 0.102765 (W 0.114822) | 40.4837 ± 0.132857 (W 0.0254765) | · |  |
| `eigh/n513/b1` | 39.8773 ± 0.0367514 (W 0.0534118) | 40.7295 ± 0.105773 (W 0.039201) | · |  |
| `full_piv_lu/n255/b1` | 5.73289 ± 0.0084 (W 0.00943403) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n257/b1` | 4.41304 ± 0.0240535 (W 0.00666228) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n511/b1` | 24.8685 ± 0.0853438 (W 0.11088) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n513/b1` | 18.1605 ± 0.0566788 (W 0.0856831) | - | - | `*` one row has no measurement here |
| `lu/n255/b1` | 1.43116 ± 0.00506451 (W 0.016377) | 0.883502 ± 0.00233793 (W 0.00244272) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `lu/n257/b1` | 1.2972 ± 0.0115935 (W 0.0193182) | 0.890268 ± 0.00209334 (W 0.00222975) | 🔴 fork 1.46× slower than `lapack-openblas` |  |
| `lu/n511/b1` | 5.5291 ± 0.0251542 (W 0.0331286) | 3.21026 ± 0.0200076 (W 0.0091216) | 🔴 fork 1.72× slower than `lapack-openblas` |  |
| `lu/n513/b1` | 5.27464 ± 0.0307491 (W 0.0259028) | 3.23759 ± 0.0210525 (W 0.00509927) | 🔴 fork 1.63× slower than `lapack-openblas` |  |
| `qr/n255/b1` | 3.35869 ± 0.0206799 (W 0.027456) | 4.52988 ± 0.0111101 (W 0.0081296) | 🔵 fork 1.35× faster than `lapack-openblas` |  |
| `qr/n257/b1` | 3.40126 ± 0.592014 (W 0.0167847) | 4.81537 ± 0.0134122 (W 0.00297854) | 🔵 fork 1.42× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n511/b1` | 15.1918 ± 0.050014 (W 0.0457106) | 18.6714 ± 0.18404 (W 0.0250443) | 🔵 fork 1.23× faster than `lapack-openblas` |  |
| `qr/n513/b1` | 15.5436 ± 0.0345913 (W 0.0547446) | 19.3711 ± 0.0588888 (W 0.0275857) | 🔵 fork 1.25× faster than `lapack-openblas` |  |
| `qr_factor/n255/b1` | 2.28865 ± 0.0125391 (W 0.0224358) | 2.24087 ± 0.00650367 (W 0.00398998) | · |  |
| `qr_factor/n257/b1` | 2.35392 ± 0.0146501 (W 0.0198191) | 2.38159 ± 0.00889563 (W 0.00412756) | · |  |
| `qr_factor/n511/b1` | 8.89229 ± 0.0285578 (W 0.0382453) | 9.15264 ± 0.014462 (W 0.0108584) | · |  |
| `qr_factor/n513/b1` | 9.04416 ± 0.0230234 (W 0.0297956) | 9.53941 ± 0.129262 (W 0.00937308) | 🔵 fork 1.05× faster than `lapack-openblas` |  |
| `solve/n255/b1` | 1.31459 ± 0.00761781 (W 0.0186444) | 0.89268 ± 0.00252542 (W 0.0023304) | 🔴 fork 1.47× slower than `lapack-openblas` |  |
| `solve/n257/b1` | 1.29385 ± 0.00694287 (W 0.0142537) | 0.903792 ± 0.00274546 (W 0.00261568) | 🔴 fork 1.43× slower than `lapack-openblas` |  |
| `solve/n511/b1` | 5.44131 ± 0.0378144 (W 0.0279847) | 3.28357 ± 0.087538 (W 0.00777514) | 🔴 fork 1.66× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n513/b1` | 5.34525 ± 0.022477 (W 0.0309645) | 3.29694 ± 0.0144859 (W 0.00751916) | 🔴 fork 1.62× slower than `lapack-openblas` |  |
| `svd_thin/n255/b1` | 21.6908 ± 0.07204 (W 0.0520116) | 13.6121 ± 0.0212583 (W 0.0175725) | 🔴 fork 1.59× slower than `lapack-openblas` |  |
| `svd_thin/n257/b1` | 17.1875 ± 0.579103 (W 0.109936) | 14.3227 ± 0.111418 (W 0.0197822) | 🔴 fork 1.20× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n511/b1` | 79.4914 ± 0.15411 (W 0.461005) | 58.5855 ± 0.124311 (W 0.118725) | 🔴 fork 1.36× slower than `lapack-openblas` |  |
| `svd_thin/n513/b1` | 68.9806 ± 0.215216 (W 0.14887) | 60.8213 ± 0.137569 (W 0.072504) | 🔴 fork 1.13× slower than `lapack-openblas` |  |
| `svd_values/n255/b1` | 17.3592 ± 0.0580459 (W 0.0440829) | 7.26339 ± 0.01875 (W 0.00648294) | 🔴 fork 2.39× slower than `lapack-openblas` |  |
| `svd_values/n257/b1` | 13.948 ± 0.0613892 (W 0.0398918) | 7.53778 ± 0.0790078 (W 0.00604561) | 🔴 fork 1.85× slower than `lapack-openblas` |  |
| `svd_values/n511/b1` | 60.6387 ± 0.327597 (W 0.260372) | 28.156 ± 0.0874865 (W 0.0281513) | 🔴 fork 2.15× slower than `lapack-openblas` |  |
| `svd_values/n513/b1` | 51.07 ± 0.210753 (W 0.107922) | 28.8315 ± 0.0866405 (W 0.0480267) | 🔴 fork 1.77× slower than `lapack-openblas` |  |
| `triangular_solve/n255/b1` | 0.0213 ± 0.00158585 (W 9.21997e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n257/b1` | 0.02176 ± 0.000229343 (W 0.000171317) | - | - | `*` one row has no measurement here |
| `triangular_solve/n511/b1` | 0.089968 ± 0.00248801 (W 0.000569489) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n513/b1` | 0.0820365 ± 0.00491987 (W 0.00238007) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/255`, `full_piv_lu/257`, `full_piv_lu/511`, `full_piv_lu/513`, `triangular_solve/255`, `triangular_solve/257`, `triangular_solve/511`, `triangular_solve/513`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
