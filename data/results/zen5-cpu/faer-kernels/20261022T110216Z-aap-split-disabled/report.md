# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bf63bf229207ab1d0cebc21b5f84878361fd7b35`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `b09a1dc5bec4c327d94b4745cf3512c3695097f5`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `581de1e250d41821db7fdfd3461e497799e19afb08110ba9e137b6bdb28c762c`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-22T11:10:49.013097Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-mid --families triangular_solve,lu,qr_factor,triangular_solve --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label aap-split-disabled --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261022T110216Z-aap-split-disabled/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.47%, worst 78.80% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 72 of 288 engine cells exceed 5% and carry `!`; median within-process relative SD 0.58%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.135187 ± 0.0171761 (W 0.00228944) | 0.13728 ± 0.0179158 (W 0.00374049) | 0.170482 ± 0.0195874 (W 0.00125318) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.988378 ± 0.119614 (W 0.00247986) | 1.0353 ± 0.00444003 (W 0.00274764) | 0.969291 ± 0.13412 (W 0.00336795) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.61598 ± 0.0174057 (W 0.0134523) | 7.32482 ± 0.0593804 (W 0.0155472) | 6.96485 ± 0.00443029 (W 0.00742145) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.332218 ± 0.00124534 (W 0.00174825) | 0.5364 ± 0.00192478 (W 0.00238165) | 0.372584 ± 0.000762992 (W 0.00231784) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.5944 ± 0.00546301 (W 0.00310296) | 2.84903 ± 0.0292284 (W 0.00466555) | 2.04104 ± 0.0060663 (W 0.0145804) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.84624 ± 0.0403019 (W 0.0136959) | 17.5628 ± 0.0397136 (W 0.0187017) | 14.0858 ± 0.0450542 (W 0.0202245) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004419 ± 2.62742e-05 (W 4.68103e-05) | 0.004097 ± 0.000132478 (W 4.53012e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012373 ± 0.000719597 (W 6.59416e-05) | 0.011421 ± 0.000622421 (W 6.05805e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.040283 ± 0.00413577 (W 0.000183793) | 0.039111 ± 0.00257006 (W 0.000226486) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.134646 ± 0.0188242 (W 0.00193327) | 0.207354 ± 0.0298947 (W 0.0121965) | 0.152249 ± 0.0103317 (W 0.00307997) | 🔵 faer-fork 1.54× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.993383 ± 0.11831 (W 0.00247026) | 1.18428 ± 0.0257853 (W 0.0177552) | 0.379122 ± 0.11469 (W 0.00183663) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.62× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.7893 ± 0.0242679 (W 0.0663965) | 5.61374 ± 0.0447946 (W 0.0590197) | 2.61747 ± 0.00349627 (W 0.00871101) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.356142 ± 0.0288394 (W 0.0100653) | 1.45676 ± 0.0189925 (W 0.0149357) | 0.195998 ± 0.000579814 (W 0.00149914) | 🔵 faer-fork 4.09× faster than `faer-upstream` | 🔴 faer-fork 1.82× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.44594 ± 0.0074234 (W 0.0242939) | 5.54474 ± 0.0553855 (W 0.0707776) | 0.672297 ± 0.00136934 (W 0.00258829) | 🔵 faer-fork 3.83× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.21375 ± 0.0722135 (W 0.0406107) | 22.125 ± 0.0645493 (W 0.083509) | 3.86752 ± 0.00610363 (W 0.00476561) | 🔵 faer-fork 4.24× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004599 ± 0.000159478 (W 6.12805e-05) | 0.004038 ± 0.00013308 (W 3.04335e-05) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012955 ± 0.000902965 (W 0.000101594) | 0.012394 ± 0.000801782 (W 8.7506e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.040156 ± 0.00103852 (W 0.000472775) | 0.040647 ± 0.0025664 (W 0.000505042) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.136019 ± 0.0175861 (W 0.00180257) | 0.2241 ± 0.0252998 (W 0.0108713) | 0.190468 ± 0.025059 (W 0.00347022) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.00001 ± 0.137864 (W 0.00610005) | 1.26059 ± 0.0244855 (W 0.0163388) | 0.354081 ± 0.158994 (W 0.00422114) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 2.82× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.65257 ± 0.0578938 (W 0.0585274) | 5.74122 ± 0.0419958 (W 0.0593621) | 2.44127 ± 0.0788815 (W 0.0145841) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.91× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.358454 ± 0.00267254 (W 0.0108648) | 1.97051 ± 0.0268494 (W 0.0207053) | 0.157128 ± 0.00168224 (W 0.00178498) | 🔵 faer-fork 5.50× faster than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.39378 ± 0.00831081 (W 0.0102749) | 6.57906 ± 0.0495879 (W 0.0701553) | 0.577865 ± 0.00255948 (W 0.00272688) | 🔵 faer-fork 4.72× faster than `faer-upstream` | 🔴 faer-fork 2.41× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.87482 ± 0.286765 (W 0.016974) | 24.8848 ± 0.20236 (W 0.120018) | 2.31882 ± 0.0102758 (W 0.00481088) | 🔵 faer-fork 5.10× faster than `faer-upstream` | 🔴 faer-fork 2.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `triangular_solve/n128/b1` | 0.004338 ± 0.000315119 (W 4.13195e-05) | 0.003968 ± 6.97161e-05 (W 4.22753e-05) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012213 ± 0.000723488 (W 6.58027e-05) | 0.011521 ± 0.000847598 (W 9.95651e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044233 ± 0.00129872 (W 0.000715015) | 0.041837 ± 0.000869628 (W 0.000654737) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.145255 ± 0.00108643 (W 0.00241087) | 0.145375 ± 0.000817515 (W 0.00218905) | 0.133111 ± 9.68108e-05 (W 0.00156968) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.702831 ± 0.11739 (W 0.0023466) | 0.701201 ± 0.117433 (W 0.0036188) | 0.817375 ± 0.0024632 (W 0.00244944) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.1458 ± 0.0172922 (W 0.0145756) | 6.13799 ± 0.0308017 (W 0.010789) | 5.21706 ± 0.00198167 (W 0.00845768) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.279431 ± 0.00227439 (W 0.00163457) | 0.281915 ± 0.00170316 (W 0.00190907) | 0.33423 ± 0.00335589 (W 0.00267787) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.37428 ± 0.00383888 (W 0.00215658) | 1.382 ± 0.00310175 (W 0.002371) | 1.8977 ± 0.0059628 (W 0.00650132) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.9416 ± 0.011037 (W 0.00567344) | 7.96874 ± 0.0168336 (W 0.005003) | 13.3761 ± 0.0451854 (W 0.0182311) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.00538 ± 0.000339506 (W 3.73938e-05) | 0.004558 ± 0.000477704 (W 4.88385e-05) | - | 🔴 faer-fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014017 ± 0.000401981 (W 3.9323e-05) | 0.013245 ± 0.000771673 (W 5.41295e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044752 ± 0.00462332 (W 0.000143577) | 0.045313 ± 0.00532477 (W 0.00029934) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.146007 ± 0.000873491 (W 0.00176182) | 0.220228 ± 0.000913085 (W 0.00799686) | 0.132983 ± 0.000586675 (W 0.00147193) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.708863 ± 0.120823 (W 0.00364267) | 0.821409 ± 0.116252 (W 0.0208473) | 0.321962 ± 0.00211257 (W 0.00190198) | · | 🔴 faer-fork 2.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.28685 ± 0.0860311 (W 0.0889169) | 4.60028 ± 0.0386301 (W 0.0476176) | 1.64663 ± 0.00660464 (W 0.00358868) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 2.60× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.31066 ± 0.0188901 (W 0.0196065) | 1.1444 ± 0.0269741 (W 0.0274781) | 0.180339 ± 0.00143037 (W 0.00151395) | 🔵 faer-fork 3.68× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.33799 ± 0.0094334 (W 0.0279157) | 3.01599 ± 0.0251275 (W 0.0669006) | 0.620159 ± 0.000222191 (W 0.00289171) | 🔵 faer-fork 2.25× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.8422 ± 0.0193399 (W 0.0109837) | 8.30039 ± 0.0713139 (W 0.100951) | 3.70627 ± 0.0120872 (W 0.00832721) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004909 ± 4.62637e-05 (W 3.62533e-05) | 0.004528 ± 0.000207126 (W 1.83929e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014808 ± 0.00199628 (W 5.28895e-05) | 0.013235 ± 0.00188896 (W 6.17754e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.047587 ± 0.00438543 (W 0.000495273) | 0.047857 ± 0.00431507 (W 0.000513864) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.116914 ± 0.0174941 (W 0.00145081) | 0.193203 ± 0.00226522 (W 0.00676253) | 0.13262 ± 0.000577895 (W 0.00137717) | 🔵 faer-fork 1.65× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.711909 ± 0.11914 (W 0.00365578) | 0.939791 ± 0.124605 (W 0.0291615) | 0.318381 ± 0.00566305 (W 0.00330468) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 2.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.15347 ± 0.0127808 (W 0.0941579) | 4.77648 ± 0.0659266 (W 0.0869517) | 1.21987 ± 0.0112692 (W 0.00864828) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 3.40× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.33268 ± 0.00350312 (W 0.00601743) | 1.5835 ± 0.00704132 (W 0.029793) | 0.145676 ± 0.00100125 (W 0.00106108) | 🔵 faer-fork 4.76× faster than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.29885 ± 0.00214173 (W 0.0135184) | 4.07062 ± 0.0212263 (W 0.104049) | 0.546087 ± 0.00216379 (W 0.00338388) | 🔵 faer-fork 3.13× faster than `faer-upstream` | 🔴 faer-fork 2.38× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.55292 ± 0.0513025 (W 0.032113) | 10.1792 ± 0.124802 (W 0.107328) | 2.23751 ± 0.0271212 (W 0.00522108) | 🔵 faer-fork 2.24× faster than `faer-upstream` | 🔴 faer-fork 2.03× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004629 ± 0.000196588 (W 2.70185e-05) | 0.004258 ± 0.000230723 (W 3.12282e-05) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014507 ± 0.000620677 (W 0.000204411) | 0.013396 ± 0.00079321 (W 5.85688e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.054012 ± 0.00201397 (W 0.00321319) | 0.050686 ± 0.00190812 (W 0.000973553) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.334171 ± 0.00187279 (W 0.00177606) | 0.339131 ± 0.00346446 (W 0.00288855) | 0.501474 ± 0.00115073 (W 0.00284558) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.15179 ± 0.00507326 (W 0.00525619) | 2.24406 ± 0.00276821 (W 0.00424528) | 3.31024 ± 0.00569918 (W 0.00477425) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.616 ± 0.094417 (W 0.0233588) | 17.517 ± 0.106788 (W 0.0310541) | 23.2385 ± 0.035771 (W 0.0501064) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.828652 ± 0.0078695 (W 0.00122235) | 1.06814 ± 0.00531662 (W 0.00499072) | 0.951256 ± 0.00245253 (W 0.00119547) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.77773 ± 0.0419485 (W 0.00860953) | 6.51615 ± 0.0392205 (W 0.0138406) | 5.65855 ± 0.00534543 (W 0.00963079) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.7142 ± 0.0665065 (W 0.0819763) | 37.8952 ± 0.080361 (W 0.0261216) | 38.9431 ± 0.0699092 (W 0.0464191) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008095 ± 4.46132e-05 (W 3.20936e-05) | 0.007494 ± 2.51661e-05 (W 4.20714e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025075 ± 6.62898e-05 (W 8.52643e-05) | 0.023994 ± 9.5469e-05 (W 0.000107393) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.090632 ± 0.00119706 (W 0.000487916) | 0.087389 ± 0.00160778 (W 0.00179869) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.335021 ± 0.00146618 (W 0.00217664) | 0.35571 ± 0.000889743 (W 0.00536795) | 0.482456 ± 0.00238241 (W 0.00302968) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.61233 ± 0.00748756 (W 0.0116251) | 1.72875 ± 0.0206472 (W 0.0119388) | 1.01904 ± 0.00302655 (W 0.00305001) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 10.2022 ± 0.0448131 (W 0.0811364) | 10.1116 ± 0.0367031 (W 0.0188392) | 7.57884 ± 0.0114713 (W 0.0134745) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.61603 ± 0.00742736 (W 0.00849562) | 1.78734 ± 0.0225976 (W 0.0167891) | 0.451807 ± 0.000461093 (W 0.00147837) | 🔵 faer-fork 2.90× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.96808 ± 0.00466427 (W 0.0364026) | 7.35539 ± 0.0964697 (W 0.0356675) | 1.63513 ± 0.0019743 (W 0.00309416) | 🔵 faer-fork 2.48× faster than `faer-upstream` | 🔴 faer-fork 1.82× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.2268 ± 0.0390811 (W 0.0642724) | 26.7326 ± 0.554047 (W 0.105172) | 11.4114 ± 0.0321719 (W 0.0171717) | 🔵 faer-fork 2.19× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008126 ± 5.83981e-05 (W 1.41421e-05) | 0.007534 ± 2.5697e-05 (W 4.32435e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024865 ± 0.000517718 (W 4.24264e-05) | 0.023593 ± 0.00038936 (W 6.65582e-05) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.075698 ± 0.00404992 (W 0.00197783) | 0.070192 ± 0.000565139 (W 0.000732337) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.334501 ± 0.000334653 (W 0.00202967) | 0.379253 ± 0.00153771 (W 0.00593138) | 0.486815 ± 0.000903597 (W 0.00227951) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.55584 ± 0.00360515 (W 0.0194183) | 1.71304 ± 0.0119573 (W 0.0101801) | 0.699133 ± 0.00445934 (W 0.00539458) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 2.23× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.99472 ± 0.0601009 (W 0.070725) | 8.9424 ± 0.0451214 (W 0.0520681) | 5.05696 ± 0.00763672 (W 0.0203003) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.625023 ± 0.00993849 (W 0.00646377) | 2.36143 ± 0.0225681 (W 0.0358563) | 0.320787 ± 0.000787005 (W 0.00161704) | 🔵 faer-fork 3.78× faster than `faer-upstream` | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.46316 ± 0.0104252 (W 0.0295653) | 8.49535 ± 0.0579118 (W 0.0557716) | 1.61665 ± 0.00539511 (W 0.00423311) | 🔵 faer-fork 3.45× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.4859 ± 0.0152249 (W 0.0320977) | 27.4301 ± 0.0941235 (W 0.218179) | 5.80557 ± 0.0130583 (W 0.00744715) | 🔵 faer-fork 2.89× faster than `faer-upstream` | 🔴 faer-fork 1.63× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008066 ± 6.08632e-05 (W 3.28664e-05) | 0.007524 ± 6.55769e-05 (W 3.84994e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024646 ± 0.000260178 (W 0.000109527) | 0.023384 ± 0.000217443 (W 5.69052e-05) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.077051 ± 0.00437987 (W 0.00146363) | 0.075648 ± 0.00437331 (W 0.00296971) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.306388 ± 0.000432851 (W 0.00189872) | 0.304697 ± 0.000786962 (W 0.00186661) | 0.462524 ± 0.00224067 (W 0.00320199) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.03519 ± 0.0014914 (W 0.00809073) | 2.0338 ± 0.00482057 (W 0.00287813) | 3.14632 ± 0.00736235 (W 0.00908974) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.5575 ± 0.0653205 (W 0.0203789) | 16.5312 ± 0.0854071 (W 0.0293379) | 19.7313 ± 0.0289803 (W 0.0403594) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.74373 ± 0.00272285 (W 0.0018703) | 0.745499 ± 0.000813371 (W 0.00269482) | 0.909257 ± 0.00283352 (W 0.00298957) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.47604 ± 0.00963006 (W 0.00487993) | 4.50125 ± 0.0141076 (W 0.00289026) | 5.49895 ± 0.00591979 (W 0.0110938) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.9092 ± 0.022516 (W 0.0238297) | 29.0029 ± 0.0817367 (W 0.020487) | 37.9678 ± 0.0339468 (W 0.0147869) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007494 ± 3.25115e-05 (W 2.54008e-05) | 0.007133 ± 1.57162e-05 (W 2.60768e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025216 ± 0.000186605 (W 9.78264e-05) | 0.024325 ± 0.000252655 (W 0.000131161) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.094673 ± 0.00227443 (W 0.00109876) | 0.093461 ± 0.00260797 (W 0.000475637) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.306299 ± 0.00042905 (W 0.00184594) | 0.32365 ± 0.00421483 (W 0.0058105) | 0.457986 ± 0.00247409 (W 0.00285913) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.49724 ± 0.0096846 (W 0.0168471) | 1.52476 ± 0.0183111 (W 0.0179065) | 0.971493 ± 0.00357869 (W 0.00434332) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 9.15835 ± 0.0553643 (W 0.046717) | 9.19088 ± 0.0382466 (W 0.0529283) | 5.84666 ± 0.17992 (W 0.0111461) | · | 🔴 faer-fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.561005 ± 0.0104552 (W 0.00808263) | 1.39824 ± 0.00515546 (W 0.0146869) | 0.433576 ± 0.00201339 (W 0.00171744) | 🔵 faer-fork 2.49× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.72602 ± 0.0496105 (W 0.0486206) | 4.24306 ± 0.046171 (W 0.0358665) | 1.57428 ± 0.00341604 (W 0.0046992) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.5288 ± 0.345753 (W 0.0682837) | 14.6343 ± 0.175672 (W 0.0810824) | 11.0191 ± 0.233497 (W 0.0121496) | 🔵 faer-fork 1.27× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `triangular_solve/n128/b1` | 0.008446 ± 0.000307832 (W 3.91152e-05) | 0.007955 ± 0.000193993 (W 3.74606e-05) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025256 ± 0.000828379 (W 5.92225e-05) | 0.025316 ± 0.000278857 (W 7.07107e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.079074 ± 0.00305223 (W 0.00119495) | 0.07675 ± 0.00335214 (W 0.00127374) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/n128/b1` | 0.30657 ± 0.000371436 (W 0.00253732) | 0.345781 ± 0.00168096 (W 0.00815205) | 0.45939 ± 0.00306915 (W 0.00263763) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.4489 ± 0.0149495 (W 0.0145299) | 1.51968 ± 0.0106522 (W 0.0187612) | 0.670866 ± 0.0031597 (W 0.00363616) | · | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.02773 ± 0.019873 (W 0.0728408) | 8.20571 ± 0.0255182 (W 0.0473227) | 3.48245 ± 0.0090402 (W 0.00814564) | · | 🔴 faer-fork 2.31× slower than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.562738 ± 0.00577367 (W 0.00301342) | 1.90279 ± 0.0375335 (W 0.0269296) | 0.307498 ± 0.00304361 (W 0.002316) | 🔵 faer-fork 3.38× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.32435 ± 0.0208908 (W 0.0133216) | 5.34693 ± 0.0534556 (W 0.0659518) | 1.58868 ± 0.00597511 (W 0.0033421) | 🔵 faer-fork 2.30× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.79229 ± 0.0937421 (W 0.0354218) | 14.7852 ± 0.235625 (W 0.084831) | 5.60698 ± 0.101752 (W 0.00988844) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008606 ± 0.000709954 (W 3.35157e-05) | 0.008466 ± 5.68624e-05 (W 3.64692e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025537 ± 0.000715676 (W 3.91152e-05) | 0.023564 ± 0.00210661 (W 0.000101741) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.090515 ± 0.00379271 (W 0.00101739) | 0.080588 ± 0.00328751 (W 0.00111114) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
