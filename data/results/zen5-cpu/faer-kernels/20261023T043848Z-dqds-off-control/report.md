# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `f2e122d90d68f479a02e4c0ca59e8f18bad084fd`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `7c1d7a5741a132606af955e837057e8da7bc8c4f`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `52713390d05c47e6209d6b3c4b99b33cd30de9dbf20be8a6479730b386ae3840`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T04:43:36.101253Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid --families qr_factor,svd_values --shapes 64,96,128 --dtypes f64,c64,f32,c32 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label dqds-off-control --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T043848Z-dqds-off-control/`

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
- CPU sets: 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.99%, worst 287.96% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 35 of 240 engine cells exceed 5% and carry `!`; median within-process relative SD 0.49%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.105596 ± 0.00875012 (W 0.00182475) | 0.479834 ± 0.0110949 (W 0.0103268) | 0.298767 ± 0.134039 (W 0.00177907) | 🔵 faer-fork 4.54× faster than `faer-upstream` | 🔵 faer-fork 2.83× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.226843 ± 0.0139937 (W 0.0164728) | 0.964637 ± 0.00302319 (W 0.0126132) | 0.942085 ± 0.00214117 (W 0.000510933) | 🔵 faer-fork 4.25× faster than `faer-upstream` | 🔵 faer-fork 4.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.516362 ± 0.00216348 (W 0.00188466) | 0.515952 ± 0.00061538 (W 0.00174766) | 0.270073 ± 0.000207983 (W 0.00160084) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18074 ± 0.00568045 (W 0.00166475) | 1.17958 ± 0.00728003 (W 0.00153283) | 0.605789 ± 0.00130241 (W 0.00219358) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.113362 ± 0.00447063 (W 0.00417407) | 0.630375 ± 0.00283777 (W 0.0105038) | 0.298836 ± 0.133712 (W 0.00132168) | 🔵 faer-fork 5.56× faster than `faer-upstream` | 🔵 faer-fork 2.64× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.206485 ± 0.000704189 (W 0.00390086) | 1.30024 ± 0.00586179 (W 0.0125486) | 0.93931 ± 0.000533655 (W 0.000847682) | 🔵 faer-fork 6.30× faster than `faer-upstream` | 🔵 faer-fork 4.55× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.517223 ± 0.00112751 (W 0.00195997) | 0.516051 ± 0.00248151 (W 0.00212605) | 0.270965 ± 0.000195021 (W 0.00176226) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18298 ± 0.00243242 (W 0.00361522) | 1.18317 ± 0.00243696 (W 0.000969751) | 0.598945 ± 0.0012378 (W 0.00173927) | · | 🔴 faer-fork 1.98× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.08594 ± 0.00901536 (W 0.00975835) | 0.423389 ± 0.00615028 (W 0.0137192) | 0.289549 ± 0.000395517 (W 0.00231098) | 🔵 faer-fork 4.93× faster than `faer-upstream` | 🔵 faer-fork 3.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.185185 ± 0.0201742 (W 0.0106061) | 0.869349 ± 0.00558261 (W 0.0131692) | 0.930173 ± 0.000767985 (W 0.00115344) | 🔵 faer-fork 4.69× faster than `faer-upstream` | 🔵 faer-fork 5.02× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.537731 ± 0.00149238 (W 0.00177525) | 0.537512 ± 0.000381429 (W 0.00285564) | 0.258892 ± 0.00114803 (W 0.00139305) | · | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18874 ± 0.00480327 (W 0.0017273) | 1.188 ± 0.0058798 (W 0.00184203) | 0.602943 ± 0.000598466 (W 0.00190492) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.089477 ± 0.00209328 (W 0.00205695) | 0.562618 ± 0.0070396 (W 0.0122188) | 0.289268 ± 0.0005642 (W 0.00165397) | 🔵 faer-fork 6.29× faster than `faer-upstream` | 🔵 faer-fork 3.23× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.181048 ± 0.00174922 (W 0.00707011) | 1.15023 ± 0.00931552 (W 0.0252834) | 0.930474 ± 0.000340686 (W 0.000920317) | 🔵 faer-fork 6.35× faster than `faer-upstream` | 🔵 faer-fork 5.14× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538352 ± 0.00180929 (W 0.00193944) | 0.536911 ± 0.00147966 (W 0.00164649) | 0.259584 ± 0.000440534 (W 0.00144707) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18781 ± 0.000747472 (W 0.00144404) | 1.18925 ± 0.00140407 (W 0.0022524) | 0.602202 ± 0.00176542 (W 0.00176246) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.190816 ± 0.013278 (W 0.0167172) | 0.616649 ± 0.0098464 (W 0.00800535) | 0.762831 ± 0.346091 (W 0.0014821) | 🔵 faer-fork 3.23× faster than `faer-upstream` | 🔵 faer-fork 4.00× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.371833 ± 0.0138047 (W 0.0021973) | 1.16535 ± 0.013538 (W 0.0181841) | 2.45582 ± 0.00166338 (W 0.00190557) | 🔵 faer-fork 3.13× faster than `faer-upstream` | 🔵 faer-fork 6.60× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.64962 ± 0.00149014 (W 0.00232565) | 0.64963 ± 0.000272581 (W 0.00161263) | 0.490834 ± 0.81546 (W 0.0011904) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n96/b1` | 1.5107 ± 0.00335182 (W 0.0115463) | 1.51114 ± 0.00372428 (W 0.0030173) | 1.35841 ± 0.00165959 (W 0.00192023) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.178112 ± 0.0203041 (W 0.00298447) | 0.755777 ± 0.00601683 (W 0.0105132) | 0.762931 ± 0.345266 (W 0.00137122) | 🔵 faer-fork 4.24× faster than `faer-upstream` | 🔵 faer-fork 4.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.393012 ± 0.00308261 (W 0.00315966) | 1.52276 ± 0.014416 (W 0.0497824) | 2.45345 ± 0.00284588 (W 0.00204198) | 🔵 faer-fork 3.87× faster than `faer-upstream` | 🔵 faer-fork 6.24× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.648478 ± 0.000321326 (W 0.00253147) | 0.649289 ± 0.00141919 (W 0.00225599) | 0.491986 ± 0.813582 (W 0.00152429) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n96/b1` | 1.5055 ± 0.000556747 (W 0.00268071) | 1.50344 ± 0.00336339 (W 0.00454589) | 1.35629 ± 0.000492708 (W 0.00116972) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.156622 ± 0.00136942 (W 0.00355428) | 0.50477 ± 0.00141823 (W 0.0087109) | 0.755748 ± 0.000431428 (W 0.00136653) | 🔵 faer-fork 3.22× faster than `faer-upstream` | 🔵 faer-fork 4.83× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.33809 ± 0.0201236 (W 0.00545356) | 0.998019 ± 0.00347706 (W 0.0105397) | 2.44058 ± 0.00326052 (W 0.00199746) | 🔵 faer-fork 2.95× faster than `faer-upstream` | 🔵 faer-fork 7.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.625225 ± 0.00100424 (W 0.00222595) | 0.625506 ± 0.0031428 (W 0.00216805) | 0.480185 ± 0.001026 (W 0.00164845) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.48325 ± 0.00238774 (W 0.00316592) | 1.48189 ± 0.00445143 (W 0.00314661) | 1.34132 ± 0.00109621 (W 0.0021713) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.16675 ± 0.00981924 (W 0.00368474) | 0.660661 ± 0.00883886 (W 0.0165848) | 0.75698 ± 0.000775164 (W 0.00179884) | 🔵 faer-fork 3.96× faster than `faer-upstream` | 🔵 faer-fork 4.54× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.348238 ± 0.0167191 (W 0.00436516) | 1.30481 ± 0.0315882 (W 0.0150603) | 2.44315 ± 0.0027054 (W 0.00218552) | 🔵 faer-fork 3.75× faster than `faer-upstream` | 🔵 faer-fork 7.02× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.624142 ± 0.000361258 (W 0.00242247) | 0.623131 ± 0.00120994 (W 0.00275221) | 0.481086 ± 0.00101649 (W 0.00151792) | · | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.47784 ± 0.00199256 (W 0.011354) | 1.48071 ± 0.000880577 (W 0.00202354) | 1.33864 ± 0.00154176 (W 0.00166054) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.101619 ± 0.00516628 (W 0.00140936) | 0.47254 ± 0.0119257 (W 0.0100951) | - | 🔵 faer-fork 4.65× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.239536 ± 0.0105744 (W 0.0221666) | 0.9285 ± 0.0063379 (W 0.0142364) | - | 🔵 faer-fork 3.88× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.400797 ± 0.00220789 (W 0.00156056) | 0.402119 ± 0.00289101 (W 0.00174222) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.88589 ± 0.000470635 (W 0.00172418) | 0.887333 ± 0.000179834 (W 0.00125952) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.106799 ± 0.00150447 (W 0.000870633) | 0.615547 ± 0.00535086 (W 0.00748297) | - | 🔵 faer-fork 5.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.207657 ± 0.00574191 (W 0.005559) | 1.23157 ± 0.0359278 (W 0.0206142) | - | 🔵 faer-fork 5.93× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.400666 ± 0.000923424 (W 0.00222346) | 0.401528 ± 0.00081886 (W 0.00175568) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.887814 ± 0.000985811 (W 0.00165628) | 0.887443 ± 0.000951908 (W 0.00126355) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.099605 ± 0.000231805 (W 0.00306579) | 0.418891 ± 0.00379643 (W 0.00664094) | - | 🔵 faer-fork 4.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.180627 ± 0.00105351 (W 0.00251575) | 0.817793 ± 0.0149715 (W 0.0152257) | - | 🔵 faer-fork 4.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.402129 ± 0.000801162 (W 0.00185982) | 0.402319 ± 0.00101209 (W 0.0021) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.871643 ± 0.00191363 (W 0.0013259) | 0.872105 ± 0.000535702 (W 0.00150015) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.086902 ± 0.00053262 (W 0.000929133) | 0.5687 ± 0.00866779 (W 0.0205908) | - | 🔵 faer-fork 6.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.182089 ± 0.00477145 (W 0.00332423) | 1.12088 ± 0.018269 (W 0.0173531) | - | 🔵 faer-fork 6.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.40269 ± 0.000253246 (W 0.00175978) | 0.403472 ± 0.000328863 (W 0.00206036) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.871874 ± 0.00122485 (W 0.00197667) | 0.871153 ± 0.00156813 (W 0.00134989) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.143738 ± 0.00437333 (W 0.00591264) | 0.527964 ± 0.00766608 (W 0.00802873) | - | 🔵 faer-fork 3.67× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.283689 ± 0.0148455 (W 0.00205447) | 1.04606 ± 0.011253 (W 0.00647522) | - | 🔵 faer-fork 3.69× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.456109 ± 0.00112477 (W 0.00250657) | 0.45612 ± 0.00306849 (W 0.00233957) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04689 ± 0.00710696 (W 0.000384045) | 1.05144 ± 0.00590177 (W 0.00126393) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.137587 ± 0.00403294 (W 0.00199242) | 0.702398 ± 0.0158377 (W 0.0171956) | - | 🔵 faer-fork 5.11× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.283338 ± 0.00351314 (W 0.00437369) | 1.36108 ± 0.0264818 (W 0.0261384) | - | 🔵 faer-fork 4.80× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.456561 ± 0.0013146 (W 0.00198379) | 0.456039 ± 0.00325764 (W 0.00203632) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04739 ± 0.00168255 (W 0.00157767) | 1.04995 ± 0.00121137 (W 0.000848317) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.115214 ± 0.000185581 (W 0.00146099) | 0.443035 ± 0.0127767 (W 0.00968818) | - | 🔵 faer-fork 3.85× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.253232 ± 0.0183268 (W 0.0122039) | 0.901751 ± 0.00911093 (W 0.0147232) | - | 🔵 faer-fork 3.56× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.448876 ± 0.00106068 (W 0.0018465) | 0.449427 ± 0.00218222 (W 0.00211443) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04466 ± 0.00608955 (W 0.00136162) | 1.04999 ± 0.00682751 (W 0.000566931) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n64/b1` | 0.119101 ± 0.000869277 (W 0.000790359) | 0.605338 ± 0.0117951 (W 0.0131576) | - | 🔵 faer-fork 5.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.260265 ± 0.00101071 (W 0.00353836) | 1.18764 ± 0.0179736 (W 0.0116477) | - | 🔵 faer-fork 4.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.450269 ± 0.0019109 (W 0.00173009) | 0.450709 ± 0.00125972 (W 0.00161205) | - | · | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 1.04742 ± 0.00257974 (W 0.00052251) | 1.04766 ± 0.00102255 (W 0.000950618) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/64`, `qr_factor/96`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.342178 ± 0.0218713 (W 0.00479448) | 1.48433 ± 0.0220132 (W 0.0207705) | 0.196857 ± 0.000900763 (W 0.00179247) | 🔵 faer-fork 4.34× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22674 ± 0.0111146 (W 0.00206911) | 2.22342 ± 0.0145387 (W 0.00241807) | 1.14113 ± 0.00568864 (W 0.00239954) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.346736 ± 0.00808183 (W 0.00623052) | 2.00767 ± 0.0100373 (W 0.0383048) | 0.156381 ± 0.00111631 (W 0.00228971) | 🔵 faer-fork 5.79× faster than `faer-upstream` | 🔴 faer-fork 2.22× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.22486 ± 0.00573999 (W 0.00543641) | 2.22475 ± 0.0278077 (W 0.00281708) | 1.13079 ± 0.00285558 (W 0.00276408) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.330005 ± 0.00367175 (W 0.0115879) | 1.22447 ± 0.0374858 (W 0.0119368) | 0.181919 ± 0.00136055 (W 0.00203067) | 🔵 faer-fork 3.71× faster than `faer-upstream` | 🔴 faer-fork 1.81× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.1776 ± 0.0111179 (W 0.00679983) | 2.15761 ± 0.00981443 (W 0.00406257) | 1.14012 ± 0.0124436 (W 0.0040892) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.31132 ± 0.00320599 (W 0.00771459) | 1.62851 ± 0.0264991 (W 0.0114233) | 0.144429 ± 0.000922889 (W 0.00170424) | 🔵 faer-fork 5.23× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.21381 ± 0.040056 (W 0.00417656) | 2.21352 ± 0.0379843 (W 0.00467124) | 1.11743 ± 0.00893275 (W 0.00287179) | · | 🔴 faer-fork 1.98× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.610958 ± 0.0034222 (W 0.00736492) | 1.81955 ± 0.0130335 (W 0.0203069) | 0.453806 ± 0.0013226 (W 0.00170479) | 🔵 faer-fork 2.98× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.06301 ± 0.0328655 (W 0.0127962) | 3.03357 ± 0.00282552 (W 0.0076422) | 2.0196 ± 0.0041706 (W 0.00463896) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.613853 ± 0.00195532 (W 0.00268485) | 2.34836 ± 0.00255874 (W 0.0317784) | 0.32216 ± 0.00186391 (W 0.00155387) | 🔵 faer-fork 3.83× faster than `faer-upstream` | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.0542 ± 0.0283677 (W 0.0365955) | 3.08738 ± 0.0252969 (W 0.0216267) | 1.90769 ± 0.00231571 (W 0.00489425) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.541518 ± 0.00708437 (W 0.00262671) | 1.44306 ± 0.00791812 (W 0.0163812) | 0.433908 ± 0.00103711 (W 0.00183228) | 🔵 faer-fork 2.66× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.02465 ± 0.0379817 (W 0.00494593) | 3.00827 ± 0.00957307 (W 0.023923) | 2.00557 ± 0.00365629 (W 0.00429263) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.559833 ± 0.0076316 (W 0.00664231) | 1.93754 ± 0.0192715 (W 0.0334107) | 0.305189 ± 0.0010618 (W 0.000827914) | 🔵 faer-fork 3.46× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.00906 ± 0.0346765 (W 0.0127901) | 3.00244 ± 0.0025265 (W 0.0161176) | 1.90292 ± 0.00515859 (W 0.00588553) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.330065 ± 0.0272441 (W 0.00758892) | 1.37143 ± 0.0153657 (W 0.0160209) | - | 🔵 faer-fork 4.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.47938 ± 0.0196309 (W 0.00402495) | 1.47707 ± 0.00401447 (W 0.00261086) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.334223 ± 0.00391397 (W 0.00845382) | 1.83772 ± 0.0184418 (W 0.011345) | - | 🔵 faer-fork 5.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.4804 ± 0.00197488 (W 0.00205681) | 1.48044 ± 0.00582269 (W 0.00316124) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.292394 ± 0.0160891 (W 0.0182933) | 1.19071 ± 0.0211896 (W 0.0183839) | - | 🔵 faer-fork 4.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.4431 ± 0.0166028 (W 0.00214752) | 1.45758 ± 0.0077987 (W 0.00410712) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.303976 ± 0.0287807 (W 0.0143303) | 1.66211 ± 0.0383687 (W 0.0160411) | - | 🔵 faer-fork 5.47× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.45549 ± 0.00206582 (W 0.00129392) | 1.45555 ± 0.000422138 (W 0.00237883) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.460017 ± 0.0139575 (W 0.0102533) | 1.54276 ± 0.026074 (W 0.0212472) | - | 🔵 faer-fork 3.35× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.90225 ± 0.03073 (W 0.00228995) | 1.91958 ± 0.0278769 (W 0.0036151) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.476978 ± 0.0157798 (W 0.0200592) | 2.03872 ± 0.0206934 (W 0.0165063) | - | 🔵 faer-fork 4.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.90967 ± 0.00913216 (W 0.00620027) | 1.90958 ± 0.00607726 (W 0.00592817) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.406728 ± 0.00191317 (W 0.00198886) | 1.2939 ± 0.00795013 (W 0.0183017) | - | 🔵 faer-fork 3.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.88452 ± 0.0303997 (W 0.00215153) | 1.89255 ± 0.0356948 (W 0.00498687) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.431514 ± 0.0131073 (W 0.0254735) | 1.77107 ± 0.016729 (W 0.0208962) | - | 🔵 faer-fork 4.10× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.87925 ± 0.00590292 (W 0.00337544) | 1.88785 ± 0.00988715 (W 0.0031591) | - | · | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/128`, `svd_values/128`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
