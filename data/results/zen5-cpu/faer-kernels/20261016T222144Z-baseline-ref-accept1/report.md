# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `01e9f81fdf1c082c862f6d9656ff6c444b799f21`
- toolkit commit: `ca3ffc988b745675988a403fb2837d3e4dfe5653`
- measured binary SHA-256: `7b902aa706b7a981a7248eac2c7b479cb69b52d9832fad2bf0e0112c9f98aa98`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-16T22:30:16.038504Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall,linalg-wide --shapes 4096x256,256x256x256,512x512x512,64x1024 --families qr_factor,qr,lu,full_piv_lu,solve --dtypes f64,c64 --threads 1 --reps 5 --aa 3 --prime-ms 250 --label baseline-ref-accept1 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T222144Z-baseline-ref-accept1/`

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
- CPU sets: 1T -> `4`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.90%, worst 28.03% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 3 of 88 engine cells exceed 5% and carry `!`; median within-process relative SD 0.29%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 53.3087 ± 0.98944 (W 1.09656) | 53.1544 ± 0.79765 (W 1.03212) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 19.039 ± 0.126935 (W 0.05878) | 19.0871 ± 0.0786738 (W 0.055083) | 17.8805 ± 0.0566106 (W 0.0847274) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 74.4761 ± 0.443326 (W 0.214657) | 74.4561 ± 0.195303 (W 0.209513) | 82.7886 ± 2.10867 (W 0.259761) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 77.8657 ± 0.406554 (W 0.133919) | 78.167 ± 0.196283 (W 0.0617118) | 35.5089 ± 0.236473 (W 0.103263) | · | 🔴 fork 2.19× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 47.5026 ± 0.423991 (W 0.160947) | 47.2057 ± 0.689118 (W 0.187439) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 13.2885 ± 0.0233039 (W 0.0589043) | 13.3806 ± 0.0542765 (W 0.069852) | 11.7623 ± 0.0880054 (W 0.0174971) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 68.764 ± 0.0257175 (W 0.209327) | 68.8722 ± 0.151218 (W 0.075789) | 70.166 ± 0.323339 (W 0.0839039) | · | · |  |
| `qr_factor/4096x256/b1` | 25.6037 ± 0.294157 (W 0.0462949) | 25.6233 ± 0.362041 (W 0.0637946) | 28.9546 ± 0.290161 (W 0.0682533) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 156.83 ± 0.562326 (W 1.20443) | 156.557 ± 2.04301 (W 1.26956) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 53.7426 ± 0.0811318 (W 0.0534706) | 53.9088 ± 0.0340326 (W 0.0543646) | 66.187 ± 0.823431 (W 0.623469) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 255.656 ± 0.44171 (W 0.434652) | 255.768 ± 0.242819 (W 0.352096) | 238.133 ± 0.445141 (W 0.418912) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 175.687 ± 0.461041 (W 0.467781) | 176.329 ± 0.840631 (W 0.447178) | 110.802 ± 0.0910888 (W 0.291846) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/4096x256/b1` | 144.25 ± 0.22098 (W 0.65605) | 144.23 ± 1.06105 (W 0.372278) | - | · | - | `*` one row has no measurement here |
| `lu/4096x256/b1` | 41.6221 ± 0.0240762 (W 0.0639666) | 41.8698 ± 0.0190626 (W 0.0552454) | 49.6277 ± 0.97563 (W 0.0643981) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 244.237 ± 0.359969 (W 0.293815) | 244.16 ± 0.121647 (W 0.206282) | 215.24 ± 0.374712 (W 0.683613) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 89.2167 ± 0.778223 (W 0.0715012) | 89.1841 ± 0.709706 (W 0.0660387) | 103.822 ± 0.510497 (W 0.239395) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/4096x256`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 1.25182 ± 0.00565204 (W 0.00415935) | 1.27416 ± 0.0310473 (W 0.00545258) | - | · | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 0.513628 ± 0.00641801 (W 0.00310278) | 0.511242 ± 0.00246435 (W 0.00326813) | 0.929122 ± 0.142451 (W 0.0101335) | · | 🔵 fork 1.81× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.837742 ± 0.0155376 (W 0.00195191) | 0.837492 ± 0.0187028 (W 0.00188897) | 1.53263 ± 0.0143888 (W 0.0142559) | · | 🔵 fork 1.83× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.983774 ± 0.00999091 (W 0.00652385) | 1.00632 ± 0.00507311 (W 0.0060295) | 1.34612 ± 0.0037689 (W 0.00277383) | · | 🔵 fork 1.37× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 1.06648 ± 0.0106213 (W 0.00146778) | 1.06781 ± 0.0100413 (W 0.00207329) | - | · | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 0.315308 ± 0.00241613 (W 0.00197353) | 0.312523 ± 0.000694661 (W 0.00269078) | 3.13801 ± 0.00747947 (W 0.00343758) | · | 🔵 fork 9.95× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.62829 ± 0.000784656 (W 0.0032086) | 0.629894 ± 0.00115408 (W 0.00289985) | 1.46234 ± 0.0343079 (W 0.00347557) | · | 🔵 fork 2.33× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.566777 ± 0.00494042 (W 0.00199213) | 0.565424 ± 0.00377711 (W 0.00192985) | 6.30672 ± 0.00133135 (W 0.00563334) | · | 🔵 fork 11.13× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 2.48129 ± 0.0616133 (W 0.0110491) | 2.52208 ± 0.0473899 (W 0.00892534) | - | · | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 1.05504 ± 0.00561381 (W 0.00337632) | 1.05301 ± 0.00300117 (W 0.00327561) | 2.32917 ± 0.255674 (W 0.00505626) | · | 🔵 fork 2.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 2.62993 ± 0.009438 (W 0.00510905) | 2.62858 ± 0.00713361 (W 0.00483634) | 3.86461 ± 0.0103447 (W 0.0132974) | · | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.58173 ± 0.0114993 (W 0.00600371) | 2.60515 ± 0.00674935 (W 0.00725619) | 3.56056 ± 0.0266603 (W 0.0127028) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/64x1024/b1` | 2.31065 ± 0.0531142 (W 0.011083) | 2.29977 ± 0.0308025 (W 0.0127228) | - | · | - | `*` one row has no measurement here |
| `lu/64x1024/b1` | 0.896342 ± 0.00263012 (W 0.00260953) | 0.891743 ± 0.00336008 (W 0.00299955) | 2.1288 ± 0.001179 (W 0.00269463) | · | 🔵 fork 2.37× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 2.40712 ± 0.00850972 (W 0.0076773) | 2.4121 ± 0.00503058 (W 0.00244208) | 3.83183 ± 0.151432 (W 0.0208738) | · | 🔵 fork 1.59× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.21181 ± 0.00616863 (W 0.00371683) | 2.22249 ± 0.0104088 (W 0.00900365) | 16.8924 ± 0.0333774 (W 0.0151142) | · | 🔵 fork 7.64× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/64x1024`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
