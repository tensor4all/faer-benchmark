# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a53774682edd4e96f0387a80ddaa7bec2f3d1d70`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9baafe6afe1b468b81b7b13f72ed64aa0da6678a`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `05d9af5eee5559bdc76f381b47d2237b8aee0eb1b930553195ab89648eef3bfe`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T08:04:00.293998Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --families lu,solve,full_piv_lu,cholesky,gemm --shapes 32,64,96,128,256,512,1024x64,4096x256,64x1024,256x4096,256x256x256 --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label upstream-lu-restored-budget --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T073559Z-upstream-lu-restored-budget/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.36%, worst 699.91% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 203 of 1068 engine cells exceed 5% and carry `!`; median within-process relative SD 0.64%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.0728 ± 0.00441947 (W 0.000802124) | 1.07308 ± 0.00561949 (W 0.00167498) | 1.19284 ± 0.00519058 (W 0.00187706) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.308695 ± 0.000767368 (W 0.00849431) | 0.303214 ± 0.0041522 (W 0.00580824) | 0.34355 ± 0.000945296 (W 0.00120482) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.197708 ± 0.0176412 (W 0.026043) | 0.214289 ± 0.00990084 (W 0.021562) | 0.18265 ± 0.00186716 (W 0.00057243) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07454 ± 0.00456141 (W 0.00127197) | 1.07311 ± 0.00412467 (W 0.0014026) | 1.20131 ± 0.00147398 (W 0.00254067) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.309696 ± 0.00585126 (W 0.00895493) | 0.301772 ± 0.00355632 (W 0.00547703) | 0.344353 ± 0.000510551 (W 0.00205942) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.20944 ± 0.0236638 (W 0.0305617) | 0.228994 ± 0.0130018 (W 0.0350718) | 0.179755 ± 0.00210319 (W 0.00173251) | · | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27901 ± 0.00267544 (W 0.00266444) | 4.27568 ± 0.00260197 (W 0.00186782) | 5.06422 ± 0.00592805 (W 0.011371) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12553 ± 0.00217707 (W 0.00359218) | 1.12332 ± 0.00275666 (W 0.00342271) | 1.80881 ± 0.0210619 (W 0.00523579) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.603825 ± 0.00109488 (W 0.00361399) | 0.611059 ± 0.00411656 (W 0.00866078) | 0.702158 ± 0.000484932 (W 0.00245935) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.27769 ± 0.00454208 (W 0.00323418) | 4.2761 ± 0.00464882 (W 0.00344715) | 5.14885 ± 0.0136048 (W 0.0183327) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.12634 ± 0.00067103 (W 0.00298985) | 1.12738 ± 0.00196234 (W 0.0040591) | 1.78986 ± 0.0183635 (W 0.00791168) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.605097 ± 0.00657669 (W 0.00986413) | 0.607943 ± 0.00561289 (W 0.0112645) | 0.688451 ± 0.0149841 (W 0.00305211) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003276 ± 2.3094e-05 (W 4.24264e-05) | 0.003457 ± 6.08276e-06 (W 4.64457e-05) | 0.004207 ± 5.31068e-05 (W 4.50555e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015139 ± 3.46458e-05 (W 3.98397e-05) | 0.016701 ± 0.000212768 (W 3.70135e-05) | 0.016841 ± 0.000115443 (W 5.64562e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030877 ± 0.000170471 (W 7.84423e-05) | 0.032712 ± 0.000136873 (W 5.94332e-05) | 0.048391 ± 0.000246964 (W 0.00121536) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011913 ± 0.000168465 (W 0.00012498) | 0.0107 ± 0.000196876 (W 3.68687e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.052157 ± 0.000519647 (W 0.000140126) | 0.046567 ± 0.000541762 (W 0.000127789) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144123 ± 0.000315991 (W 0.00246204) | 0.133358 ± 0.00098815 (W 0.00227857) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008446 ± 2.08167e-05 (W 5.94138e-05) | 0.007423 ± 9.27739e-05 (W 0.0001735) | 0.012162 ± 4.7648e-05 (W 7.45138e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030888 ± 0.000182812 (W 0.00023164) | 0.02614 ± 0.000239675 (W 0.000289469) | 0.043041 ± 9.97848e-05 (W 0.00013473) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075941 ± 0.000448565 (W 0.00229228) | 0.065461 ± 0.000361226 (W 0.000223411) | 0.112269 ± 0.00028828 (W 0.00464399) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009528 ± 8.06866e-05 (W 3.66374e-05) | 0.008096 ± 0.000242487 (W 0.000121463) | 0.012864 ± 7.23418e-05 (W 2.82878e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031659 ± 0.000233024 (W 0.000120529) | 0.02718 ± 0.000137652 (W 0.00017894) | 0.043691 ± 5.96769e-05 (W 6.64477e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.079237 ± 0.000500284 (W 0.00254919) | 0.069339 ± 0.000765683 (W 0.00247158) | 0.103843 ± 6.24206e-05 (W 0.000116731) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003286 ± 0.00015201 (W 4.42629e-05) | 0.003466 ± 3.78594e-05 (W 2.95669e-05) | 0.004198 ± 9.50807e-05 (W 5.07563e-05) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015068 ± 0.00124122 (W 6.53399e-05) | 0.016741 ± 0.00160824 (W 2.75717e-05) | 0.016811 ± 9.02053e-05 (W 6.65823e-05) | · | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049745 ± 0.000567853 (W 0.00203624) | 0.059372 ± 0.00273335 (W 0.00458355) | 0.0484 ± 7.59408e-05 (W 0.000125711) | 🔵 fork 1.19× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011982 ± 0.000418422 (W 0.000161964) | 0.01062 ± 0.000291212 (W 4.66905e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051256 ± 0.000307896 (W 0.000452745) | 0.046867 ± 0.000385246 (W 8.18425e-05) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143878 ± 0.000199385 (W 0.00239428) | 0.133959 ± 2.88675e-06 (W 0.0023764) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008496 ± 5e-05 (W 3.50714e-05) | 0.007424 ± 8.73689e-05 (W 0.000135204) | 0.012252 ± 5.55908e-05 (W 8.94494e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030707 ± 0.000222029 (W 0.000279725) | 0.043942 ± 0.00103985 (W 0.0029068) | 0.04282 ± 0.000243797 (W 0.000287566) | 🔵 fork 1.43× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075701 ± 0.000120338 (W 0.00223596) | 0.100207 ± 0.00291091 (W 0.00431952) | 0.094536 ± 0.0008125 (W 0.00350331) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009598 ± 0.000127163 (W 6.45469e-05) | 0.008436 ± 0.000246374 (W 0.000146018) | 0.012734 ± 4.55741e-05 (W 6.43444e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031689 ± 0.000163711 (W 0.000132519) | 0.045627 ± 9.18041e-05 (W 0.00319925) | 0.043491 ± 3.82143e-05 (W 9.90419e-05) | 🔵 fork 1.44× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.078306 ± 0.00078318 (W 0.00238207) | 0.103823 ± 0.00175186 (W 0.00362113) | 0.087723 ± 6.9217e-05 (W 0.000282126) | 🔵 fork 1.33× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003266 ± 0.000192147 (W 3.11336e-05) | 0.003437 ± 0.000149901 (W 3.63318e-05) | 0.004138 ± 4.3589e-05 (W 5.98331e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015029 ± 0.0012794 (W 2.58844e-05) | 0.014868 ± 0.00102422 (W 6.04839e-05) | 0.016781 ± 8.6122e-05 (W 6.08276e-05) | · | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.055557 ± 0.000578205 (W 0.00327157) | 0.070952 ± 0.00268288 (W 0.00119919) | 0.04831 ± 9.10439e-05 (W 0.000106828) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.011682 ± 0.000258283 (W 4.39318e-05) | 0.01047 ± 0.000107858 (W 4.54225e-05) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051449 ± 0.000109738 (W 0.000960963) | 0.046838 ± 0.000222091 (W 0.000277354) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.143662 ± 0.00277122 (W 0.00265251) | 0.134344 ± 0.000455312 (W 0.00190476) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008696 ± 0.000170998 (W 5.71839e-05) | 0.007314 ± 0.000108167 (W 0.000125978) | 0.012204 ± 0.000101115 (W 5.01926e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0308 ± 0.00020426 (W 0.000145013) | 0.053722 ± 0.000756082 (W 0.00302709) | 0.042801 ± 4.84183e-05 (W 0.000170353) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075733 ± 9.79098e-05 (W 0.000143604) | 0.120602 ± 0.00147382 (W 0.00358973) | 0.085905 ± 0.00306414 (W 0.00137788) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.009609 ± 9.37248e-05 (W 6.39476e-05) | 0.008466 ± 0.000152775 (W 0.000157947) | 0.012764 ± 8.92767e-05 (W 6.65079e-05) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0316 ± 0.000104548 (W 6.59644e-05) | 0.052922 ± 0.00259313 (W 0.00340744) | 0.043793 ± 0.000231093 (W 0.000152605) | 🔵 fork 1.67× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.077797 ± 0.0041318 (W 0.00214174) | 0.116861 ± 0.00354694 (W 0.00302667) | 0.084968 ± 0.000268314 (W 0.00032013) | 🔵 fork 1.50× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003105 ± 1.18462e-05 (W 2.50998e-05) | 0.003346 ± 4.50925e-05 (W 3.80789e-05) | 0.003367 ± 4.08697e-05 (W 2.53022e-05) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014707 ± 2.95014e-05 (W 3.9488e-05) | 0.016321 ± 0.000258496 (W 4.09329e-05) | 0.014116 ± 0.000115832 (W 8.37634e-05) | 🔵 fork 1.11× faster than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030017 ± 0.000293452 (W 0.000107842) | 0.031839 ± 0.00293187 (W 9.18161e-05) | 0.038111 ± 0.00018124 (W 8.83176e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n32/b1` | 0.01106 ± 0.000149534 (W 0.000248508) | 0.01041 ± 2.25167e-05 (W 2.60038e-05) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045785 ± 5.00133e-05 (W 0.000345083) | 0.045785 ± 0.00084295 (W 0.000508456) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132386 ± 0.000520208 (W 0.00238141) | 0.131545 ± 0.000675346 (W 0.000324907) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007024 ± 3.80832e-05 (W 3.56371e-05) | 0.007034 ± 4.00042e-05 (W 3.29287e-05) | 0.009678 ± 9.12707e-05 (W 9.41807e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025709 ± 0.000160521 (W 0.000148359) | 0.025538 ± 0.000272213 (W 0.000129086) | 0.033863 ± 0.000115443 (W 9.70567e-05) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063229 ± 0.000335366 (W 0.0021998) | 0.063288 ± 0.000485515 (W 0.00245693) | 0.074409 ± 0.000109134 (W 0.00112629) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007825 ± 7.5368e-05 (W 2.71717e-05) | 0.007884 ± 3.5171e-05 (W 5.85662e-05) | 0.009898 ± 1.73205e-05 (W 4.65425e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025998 ± 0.000155931 (W 0.000177495) | 0.026079 ± 0.000178979 (W 0.000172836) | 0.033674 ± 0.000110546 (W 0.000814397) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.066804 ± 0.000717078 (W 0.0013149) | 0.067586 ± 0.00104157 (W 0.00230997) | 0.073679 ± 0.00038771 (W 0.0012162) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003156 ± 0.000167094 (W 5.56345e-05) | 0.003276 ± 0.000194116 (W 2.30217e-05) | 0.003336 ± 1.58219e-05 (W 2.32852e-05) | · | 🔵 fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014797 ± 0.00120106 (W 4.36268e-05) | 0.014597 ± 0.00103045 (W 3.2145e-05) | 0.014106 ± 0.000138924 (W 5.54977e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.049311 ± 0.00174167 (W 0.0026615) | 0.060344 ± 0.000978153 (W 0.00478724) | 0.038032 ± 0.000207823 (W 0.000186859) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.010439 ± 0.000286119 (W 6.46529e-05) | 0.0105 ± 0.000150111 (W 5.93658e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045867 ± 0.00025552 (W 0.00021498) | 0.046136 ± 0.000156195 (W 0.000149517) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131625 ± 0.000186508 (W 0.000212923) | 0.132206 ± 0.000763981 (W 0.0022476) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007013 ± 6.1101e-05 (W 3.63758e-05) | 0.007023 ± 5.74195e-05 (W 4.08656e-05) | 0.009708 ± 6.02771e-05 (W 5.83095e-05) | · | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025557 ± 0.000119182 (W 0.000244174) | 0.0431 ± 0.000518709 (W 0.00209953) | 0.033433 ± 2.95014e-05 (W 0.00011471) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063037 ± 0.000448445 (W 0.00225597) | 0.097993 ± 0.00298373 (W 0.00411117) | 0.074479 ± 4.92747e-05 (W 0.000137534) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007694 ± 0.000170666 (W 7.60263e-05) | 0.007825 ± 0.000133167 (W 6.49484e-05) | 0.009819 ± 7.23418e-05 (W 5.82949e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025989 ± 0.000169214 (W 8.2573e-05) | 0.043302 ± 0.0030054 (W 0.00287429) | 0.033452 ± 2.46374e-05 (W 0.000128683) | 🔵 fork 1.67× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065331 ± 0.0011213 (W 0.000282666) | 0.1018 ± 0.00294913 (W 0.00245772) | 0.073557 ± 0.00013624 (W 0.000175944) | 🔵 fork 1.56× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003066 ± 0.000257962 (W 3.05663e-05) | 0.003407 ± 0.000182511 (W 2.20749e-05) | 0.003357 ± 4.33628e-05 (W 2.74099e-05) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014698 ± 0.00115648 (W 5.44977e-05) | 0.014938 ± 0.00126107 (W 6.8775e-05) | 0.013926 ± 0.000104403 (W 2.91548e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056936 ± 0.000893628 (W 0.00279053) | 0.072495 ± 0.00110431 (W 0.0029521) | 0.038031 ± 0.000105447 (W 0.000101539) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.50× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01037 ± 0.000121025 (W 5.80517e-05) | 0.0105 ± 0.000155907 (W 4.57515e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045705 ± 0.000278877 (W 0.0013346) | 0.045805 ± 0.000431859 (W 0.000148309) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131078 ± 0.00284602 (W 0.0013834) | 0.1322 ± 0.00253305 (W 0.00254475) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007123 ± 0.000115284 (W 5.94138e-05) | 0.007194 ± 9.53939e-05 (W 5.12757e-05) | 0.009648 ± 7.29178e-05 (W 4.76571e-05) | · | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025758 ± 0.000292987 (W 0.000146526) | 0.051517 ± 0.00347972 (W 0.00292681) | 0.033485 ± 0.000123419 (W 0.000113666) | 🔵 fork 2.00× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.063009 ± 0.00233987 (W 0.00210028) | 0.113174 ± 0.00345219 (W 0.00738707) | 0.074168 ± 0.000290338 (W 0.000179425) | 🔵 fork 1.80× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007795 ± 7.59408e-05 (W 3.56371e-05) | 0.007925 ± 6.20511e-05 (W 4.64467e-05) | 0.009808 ± 4.93288e-05 (W 6.24284e-05) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026138 ± 4.07962e-05 (W 9.68416e-05) | 0.049162 ± 0.00207844 (W 0.002834) | 0.033502 ± 0.00020849 (W 0.000100151) | 🔵 fork 1.88× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.065384 ± 0.00400682 (W 0.00160589) | 0.114113 ± 0.00493629 (W 0.00295672) | 0.073599 ± 0.000178063 (W 0.00145897) | 🔵 fork 1.75× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00522 ± 4.68722e-05 (W 2.25898e-05) | 0.004899 ± 6.35085e-05 (W 8.89843e-05) | 0.008927 ± 3.21455e-05 (W 3.39013e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.71× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030426 ± 0.000113715 (W 7.173e-05) | 0.029385 ± 6.48614e-05 (W 7.38241e-05) | 0.051115 ± 0.000454295 (W 0.00106968) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084166 ± 0.000280188 (W 0.000193866) | 0.082587 ± 0.000195132 (W 0.00014416) | 0.138117 ± 0.000949232 (W 0.00154289) | · | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017713 ± 2.12211e-05 (W 0.000119187) | 0.015719 ± 6.02771e-05 (W 5.86276e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097555 ± 3.95517e-05 (W 0.000323082) | 0.092795 ± 0.00020323 (W 0.00127205) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.320758 ± 0.00205276 (W 0.0020106) | 0.30615 ± 0.00309129 (W 0.00212003) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013205 ± 0.000114529 (W 0.000143538) | 0.011151 ± 0.000159478 (W 0.000104259) | 0.019937 ± 9.02053e-05 (W 7.68115e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.05788 ± 0.000632702 (W 0.00017423) | 0.052548 ± 0.000222731 (W 0.000271147) | 0.096743 ± 0.00031467 (W 0.000305857) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.190491 ± 0.00232988 (W 0.00292166) | 0.177486 ± 0.000292157 (W 0.00197491) | 0.300439 ± 0.000588298 (W 0.00238742) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014257 ± 0.00010116 (W 5.84568e-05) | 0.012353 ± 6.16468e-05 (W 9.96303e-05) | 0.020299 ± 7.31733e-05 (W 4.20274e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059983 ± 0.000643637 (W 0.000120881) | 0.054341 ± 9.75773e-05 (W 0.000221928) | 0.094279 ± 0.000225598 (W 0.00124089) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.207427 ± 0.000834534 (W 0.00268089) | 0.191032 ± 0.000824865 (W 0.00283263) | 0.25258 ± 0.000556313 (W 0.00148694) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00519 ± 5.2915e-05 (W 3.63318e-05) | 0.004959 ± 6.4291e-05 (W 4.13908e-05) | 0.008956 ± 0.000127738 (W 3.93217e-05) | · | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030277 ± 0.000346451 (W 9.39681e-05) | 0.029265 ± 0.000147039 (W 9.37406e-05) | 0.051456 ± 0.000430763 (W 0.000312945) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.103693 ± 0.00180416 (W 0.00222357) | 0.101158 ± 0.000267714 (W 0.00111857) | 0.137706 ± 0.000164482 (W 0.00138539) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017754 ± 5.50485e-05 (W 6.22093e-05) | 0.01571 ± 4.39356e-05 (W 6.65582e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097081 ± 0.000431162 (W 0.00139051) | 0.0915 ± 0.000234105 (W 0.00166269) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.319375 ± 0.000820637 (W 0.0024269) | 0.307432 ± 0.00214477 (W 0.00241469) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013165 ± 0.000115803 (W 0.000109636) | 0.011081 ± 3.05014e-05 (W 7e-05) | 0.019897 ± 5.03322e-05 (W 4.91253e-05) | 🔴 fork 1.19× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058158 ± 0.000212418 (W 0.000132929) | 0.052688 ± 0.000248001 (W 0.000177255) | 0.095729 ± 0.00029855 (W 0.00112786) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.191437 ± 0.0015909 (W 0.00245351) | 0.192388 ± 0.00246466 (W 0.00567268) | 0.26391 ± 0.0141007 (W 0.00443078) | · | 🔵 fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014547 ± 0.000233024 (W 7.62968e-05) | 0.012433 ± 0.000113227 (W 0.000121373) | 0.020277 ± 2.99054e-05 (W 9.36606e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060172 ± 0.000203424 (W 8.85624e-05) | 0.054462 ± 0.000291885 (W 0.000177489) | 0.092706 ± 0.000514312 (W 0.000902406) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.201916 ± 0.0031263 (W 0.00373934) | 0.205102 ± 0.00254998 (W 0.003992) | 0.23637 ± 0.000117066 (W 0.0017381) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00524 ± 4.58258e-05 (W 3.58357e-05) | 0.0049 ± 4.0129e-05 (W 3.59764e-05) | 0.008977 ± 1.52753e-05 (W 5.97495e-05) | 🔴 fork 1.07× slower than `faer-upstream` | 🔵 fork 1.71× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030587 ± 0.00240405 (W 0.00148773) | 0.029136 ± 4.95681e-05 (W 6.21394e-05) | 0.051287 ± 0.000201703 (W 0.00164479) | · | 🔵 fork 1.68× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.111494 ± 0.00227657 (W 0.00332138) | 0.110135 ± 0.000822684 (W 0.00333083) | 0.140512 ± 0.000254763 (W 0.001232) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017723 ± 1.0504e-05 (W 8.34865e-05) | 0.01568 ± 4.45758e-05 (W 8.34865e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097418 ± 0.000151918 (W 0.000236318) | 0.092031 ± 0.00036769 (W 0.000366528) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.320386 ± 0.000726112 (W 0.0025265) | 0.304667 ± 0.00206777 (W 0.00206271) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013104 ± 6.12127e-05 (W 7.93725e-05) | 0.011161 ± 0.000112073 (W 7.91031e-05) | 0.019847 ± 6.0803e-05 (W 9.41552e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057841 ± 0.000151764 (W 0.00111025) | 0.052469 ± 0.000206984 (W 0.00039285) | 0.096089 ± 0.000353717 (W 0.000465146) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.189282 ± 0.000578633 (W 0.0031185) | 0.207289 ± 0.00108843 (W 0.00402538) | 0.245087 ± 0.0115842 (W 0.0015981) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n32/b1` | 0.014417 ± 0.00013004 (W 7.92181e-05) | 0.012393 ± 7.55667e-05 (W 9.40744e-05) | 0.020279 ± 5.1449e-05 (W 3.60999e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059725 ± 0.000572212 (W 9.03881e-05) | 0.054144 ± 0.000246372 (W 0.000488742) | 0.093264 ± 0.000118882 (W 0.000432077) | 🔴 fork 1.10× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.205699 ± 0.00109707 (W 0.00263948) | 0.217451 ± 0.00101398 (W 0.00399363) | 0.236751 ± 0.000271036 (W 0.0010097) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00523 ± 3.10966e-05 (W 2.07364e-05) | 0.004929 ± 1e-05 (W 4.30488e-05) | 0.008155 ± 5.74195e-05 (W 8.90505e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029986 ± 2.6839e-05 (W 4.43847e-05) | 0.028755 ± 0.000164654 (W 8.72771e-05) | 0.043641 ± 0.000357912 (W 9.5551e-05) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083215 ± 0.000171832 (W 0.000147622) | 0.081742 ± 7.33689e-05 (W 0.00018402) | 0.125027 ± 0.000216592 (W 0.00158009) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015769 ± 5.11892e-05 (W 6.43832e-05) | 0.01579 ± 7.0713e-05 (W 7.72418e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090689 ± 0.000169252 (W 0.00160007) | 0.090659 ± 0.000234973 (W 0.001402) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.303885 ± 0.00115019 (W 0.002621) | 0.303495 ± 0.0025117 (W 0.00296773) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011271 ± 0.000102144 (W 4.80021e-05) | 0.011291 ± 6.4291e-05 (W 0.000130741) | 0.017433 ± 4.17971e-05 (W 6.85237e-05) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051047 ± 0.00045961 (W 0.00015618) | 0.050984 ± 0.000251082 (W 0.000149766) | 0.086201 ± 0.000137486 (W 0.000749052) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.17709 ± 0.00122746 (W 0.002668) | 0.174194 ± 0.00188454 (W 0.00205591) | 0.226291 ± 0.00019458 (W 0.0017102) | · | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012353 ± 0.000126623 (W 6.33032e-05) | 0.012463 ± 0.000162235 (W 7.62706e-05) | 0.017232 ± 4.87545e-05 (W 4.66905e-05) | · | 🔵 fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052901 ± 0.000618861 (W 0.000142496) | 0.052798 ± 0.000272108 (W 0.000153822) | 0.083438 ± 0.000255003 (W 0.00105451) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.1882 ± 0.00132567 (W 0.0025907) | 0.187348 ± 0.00122572 (W 0.00423118) | 0.219609 ± 0.000803804 (W 0.00117009) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005189 ± 9.60052e-05 (W 2.18472e-05) | 0.004899 ± 0.00015308 (W 5.12835e-05) | 0.007935 ± 0.000121655 (W 5.72294e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029937 ± 0.000551517 (W 6.1887e-05) | 0.028864 ± 0.000100167 (W 0.000171006) | 0.044042 ± 0.000624324 (W 0.00113601) | · | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.10214 ± 0.000227388 (W 0.00232231) | 0.101289 ± 0.00307117 (W 0.000983706) | 0.126104 ± 0.000712849 (W 0.000233334) | · | 🔵 fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.015719 ± 5.56776e-05 (W 4.99129e-05) | 0.015829 ± 2.58908e-05 (W 9.20326e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089657 ± 0.000198913 (W 0.00107084) | 0.089987 ± 0.000194824 (W 0.00155824) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.304096 ± 0.00140701 (W 0.00227682) | 0.304928 ± 0.000940786 (W 0.00242863) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011291 ± 0.0001555 (W 3.36155e-05) | 0.011311 ± 1.73205e-05 (W 0.000140641) | 0.017494 ± 5.65803e-05 (W 0.000163451) | · | 🔵 fork 1.55× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050875 ± 0.000222579 (W 0.000140874) | 0.050985 ± 0.000273242 (W 0.000215049) | 0.085549 ± 0.000262715 (W 0.000245002) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174154 ± 0.000911797 (W 0.00264492) | 0.19344 ± 0.00208088 (W 0.00190725) | 0.224044 ± 0.000153158 (W 0.00164522) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012273 ± 4.58258e-05 (W 7.31437e-05) | 0.012403 ± 3e-05 (W 0.000150739) | 0.017302 ± 4.96689e-05 (W 2.97859e-05) | · | 🔵 fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052959 ± 0.000290047 (W 0.00010673) | 0.053039 ± 0.00037018 (W 0.00027378) | 0.083188 ± 0.000258388 (W 0.00024951) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.185335 ± 0.00120271 (W 0.00232323) | 0.201171 ± 0.00309793 (W 0.00577458) | 0.218547 ± 0.000195069 (W 0.00114175) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0052 ± 1.48436e-05 (W 3.04959e-05) | 0.00492 ± 0.000154068 (W 6.11408e-05) | 0.008045 ± 0.00013742 (W 8.91583e-05) | 🔴 fork 1.06× slower than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029986 ± 0.00257762 (W 6.22093e-05) | 0.028756 ± 0.000154622 (W 9.56624e-05) | 0.043292 ± 0.0004915 (W 0.000124259) | · | 🔵 fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.111578 ± 0.000728934 (W 0.00307114) | 0.109397 ± 0.00334316 (W 0.0037485) | 0.125236 ± 0.000980197 (W 0.00130412) | · | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n32/b1` | 0.01578 ± 4.04145e-05 (W 7.98123e-05) | 0.01569 ± 8.44808e-05 (W 0.000103331) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090051 ± 0.000206545 (W 0.00130057) | 0.090177 ± 0.00043031 (W 0.00138499) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.302051 ± 0.00204093 (W 0.00206374) | 0.302513 ± 0.00194625 (W 0.00381779) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011271 ± 8.94446e-05 (W 0.000132023) | 0.011312 ± 0.000264859 (W 0.000138456) | 0.017384 ± 0.0001206 (W 6.1887e-05) | · | 🔵 fork 1.54× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.050777 ± 0.000167375 (W 0.000195172) | 0.050866 ± 0.000175169 (W 0.000137351) | 0.085619 ± 0.000148098 (W 0.000124387) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.174124 ± 0.000309193 (W 0.00356688) | 0.202059 ± 0.000368 (W 0.00249137) | 0.225053 ± 0.000277212 (W 0.00194526) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012423 ± 0.000220303 (W 5.16265e-05) | 0.012454 ± 0.000131149 (W 0.000149145) | 0.017353 ± 0.0001495 (W 7.40959e-05) | · | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.052531 ± 0.000246159 (W 9.69082e-05) | 0.052721 ± 0.000340031 (W 0.000285632) | 0.082857 ± 7.35119e-05 (W 0.00020204) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.184473 ± 0.000414447 (W 0.00234861) | 0.213324 ± 0.000288391 (W 0.00447487) | 0.218129 ± 0.00042137 (W 0.00133946) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.06747 ± 0.00219035 (W 0.00165608) | 0.070662 ± 5.57165e-05 (W 0.000421592) | 0.113768 ± 0.00122092 (W 0.000387832) | · | 🔵 fork 1.69× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.388425 ± 0.00905608 (W 0.0030428) | 0.393606 ± 0.00344405 (W 0.00282355) | 0.641263 ± 0.0029167 (W 0.00324857) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.55463 ± 0.0258315 (W 0.00313207) | 2.5345 ± 0.0254435 (W 0.00418321) | 4.02948 ± 0.0103763 (W 0.0119711) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.311839 ± 0.00287991 (W 0.00185143) | 0.314516 ± 0.00308528 (W 0.00203072) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71865 ± 0.00574431 (W 0.00554887) | 2.77691 ± 0.00893128 (W 0.00721843) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.6642 ± 0.18774 (W 0.0328338) | 22.2869 ± 0.151846 (W 0.0489638) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.13426 ± 0.0177864 (W 0.00140156) | 0.136094 ± 0.0197047 (W 0.00145447) | 0.170908 ± 0.0181053 (W 0.00126434) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.977468 ± 0.11594 (W 0.00353152) | 1.03695 ± 0.00293633 (W 0.00347298) | 0.970577 ± 0.129543 (W 0.00271429) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.59315 ± 0.0190097 (W 0.00448342) | 7.16368 ± 0.111944 (W 0.00737792) | 6.95594 ± 0.0311925 (W 0.0145427) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133867 ± 0.000531743 (W 0.00120876) | 0.137099 ± 0.000572732 (W 0.00292304) | 0.16974 ± 0.000253164 (W 0.00156223) | · | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.755287 ± 0.0110413 (W 0.00274318) | 0.806327 ± 0.00229802 (W 0.00272289) | 0.971996 ± 0.000936787 (W 0.00219183) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.55852 ± 0.118955 (W 0.0198291) | 7.17701 ± 0.0266125 (W 0.0132329) | 5.99921 ± 0.00872637 (W 0.0107321) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.085271 ± 0.000615371 (W 0.00118597) | 0.105008 ± 0.00253203 (W 0.00629812) | 0.114446 ± 0.00100621 (W 0.00161724) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.401348 ± 0.00615953 (W 0.0202694) | 0.423749 ± 0.00965586 (W 0.0169983) | 0.414702 ± 0.0183179 (W 0.00529591) | 🔵 fork 1.06× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.58331 ± 0.0943919 (W 0.0198265) | 1.68207 ± 0.0636405 (W 0.0321254) | 1.92234 ± 0.181208 (W 0.0154376) | · | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.309085 ± 0.000350503 (W 0.00253638) | 0.312602 ± 0.00228398 (W 0.00168528) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.72612 ± 0.0887793 (W 0.0114358) | 2.77867 ± 0.0470509 (W 0.00777698) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n512/b1` | 17.6413 ± 4.14884 (W 0.1582) | 18.0269 ± 4.15386 (W 0.364797) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.133896 ± 0.0183587 (W 0.00117606) | 0.214569 ± 0.0177432 (W 0.00898468) | 0.151827 ± 0.0140746 (W 0.00121418) | 🔵 fork 1.60× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.921516 ± 0.195439 (W 0.0203228) | 1.19251 ± 0.0825375 (W 0.0186737) | 0.379096 ± 0.160049 (W 0.0041203) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 2.43× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.6301 ± 0.447005 (W 0.0900828) | 5.62584 ± 0.482163 (W 0.0264777) | 2.63966 ± 0.299837 (W 0.0107399) | 🔵 fork 1.22× faster than `faer-upstream` | 🔴 fork 1.75× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.133999 ± 0.00043668 (W 0.000918304) | 0.204045 ± 0.00231424 (W 0.00893738) | 0.15036 ± 0.000323392 (W 0.00126788) | 🔵 fork 1.52× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.680146 ± 0.0988298 (W 0.0149958) | 0.903108 ± 0.0695511 (W 0.0227439) | 0.368286 ± 0.035236 (W 0.0023795) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.85× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.59493 ± 0.548023 (W 0.0391134) | 5.47151 ± 0.453915 (W 0.0666088) | 1.80195 ± 0.275947 (W 0.0038904) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.55× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089807 ± 0.00240419 (W 0.00299722) | 0.105539 ± 0.00337458 (W 0.00258163) | 0.113992 ± 0.00102882 (W 0.000553382) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.407919 ± 0.0059149 (W 0.0229659) | 0.452985 ± 0.0132356 (W 0.0295774) | 0.36063 ± 0.00267966 (W 0.00347235) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.51048 ± 0.0166187 (W 0.025221) | 1.67327 ± 0.0562335 (W 0.0239429) | 1.46828 ± 0.0140329 (W 0.0129727) | 🔵 fork 1.11× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.310553 ± 0.000960659 (W 0.00297755) | 0.313624 ± 0.000996737 (W 0.00187421) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7103 ± 0.0526015 (W 0.00905267) | 2.75076 ± 0.0217098 (W 0.00908745) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.2917 ± 0.219055 (W 0.187206) | 17.9583 ± 0.137956 (W 0.110329) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.164895 ± 0.000737208 (W 0.00232177) | 0.252502 ± 0.0178944 (W 0.00979195) | 0.17758 ± 0.0199649 (W 0.00426234) | 🔵 fork 1.53× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.93297 ± 0.135001 (W 0.0190652) | 1.25672 ± 0.00524685 (W 0.0156156) | 0.347434 ± 0.155403 (W 0.00395428) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 2.69× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.51751 ± 0.0504907 (W 0.0667787) | 5.73205 ± 0.0233643 (W 0.049946) | 2.30265 ± 0.110753 (W 0.00996301) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.96× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.133581 ± 0.00127472 (W 0.0014244) | 0.21473 ± 0.0031485 (W 0.00977745) | 0.146482 ± 0.000199547 (W 0.00130376) | 🔵 fork 1.61× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.692666 ± 0.0231085 (W 0.0188139) | 0.940491 ± 0.00597001 (W 0.0385301) | 0.337488 ± 0.00384607 (W 0.0038148) | 🔵 fork 1.36× faster than `faer-upstream` | 🔴 fork 2.05× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.43917 ± 0.0256285 (W 0.024015) | 5.57426 ± 0.0108114 (W 0.0491187) | 1.31129 ± 0.0224178 (W 0.00771114) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 3.39× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.060325 ± 0.00430159 (W 0.00102215) | 0.063651 ± 8.92132e-05 (W 9.1369e-05) | 0.094241 ± 0.00226864 (W 0.000237399) | · | 🔵 fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.316277 ± 0.00647658 (W 0.00170143) | 0.324232 ± 0.0036818 (W 0.00239147) | 0.450519 ± 0.00353869 (W 0.00285224) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06225 ± 0.00465174 (W 0.00111517) | 2.06487 ± 0.00368048 (W 0.00295864) | 3.33936 ± 0.0222556 (W 0.0258465) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.29118 ± 0.000363203 (W 0.00160089) | 0.290048 ± 0.000350219 (W 0.00264045) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.64089 ± 0.00258005 (W 0.00820523) | 2.63781 ± 0.00443304 (W 0.00865507) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.1349 ± 0.219554 (W 0.062924) | 21.1172 ± 0.192016 (W 0.0279461) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.14484 ± 0.00135971 (W 0.00201973) | 0.14607 ± 0.00154012 (W 0.00204217) | 0.133456 ± 0.000283107 (W 0.0014132) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.696998 ± 0.11576 (W 0.00305833) | 0.703359 ± 0.115464 (W 0.00321558) | 0.815208 ± 0.00052414 (W 0.00361371) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.11694 ± 0.00927304 (W 0.00943887) | 6.11672 ± 0.0301182 (W 0.0160055) | 5.20692 ± 0.00142621 (W 0.00599785) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.11141 ± 0.000396274 (W 0.00133255) | 0.11286 ± 0.000815817 (W 0.000716425) | 0.133145 ± 0.000692621 (W 0.00113002) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.663694 ± 0.00151172 (W 0.0022746) | 0.664086 ± 0.00354734 (W 0.00364962) | 0.815591 ± 0.000366274 (W 0.00244048) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.05616 ± 0.0178095 (W 0.0115087) | 6.06213 ± 0.0249172 (W 0.0063697) | 5.24653 ± 0.0099847 (W 0.00609965) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.077346 ± 0.000162961 (W 0.00120947) | 0.098273 ± 0.00174501 (W 0.00879875) | 0.092014 ± 0.00200984 (W 0.00172634) | 🔵 fork 1.27× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.337636 ± 0.0302949 (W 0.0257293) | 0.372273 ± 0.00427896 (W 0.0216701) | 0.241189 ± 0.0102665 (W 0.00537496) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.14849 ± 0.125106 (W 0.0342233) | 1.19669 ± 0.189992 (W 0.0382603) | 1.41401 ± 0.0744223 (W 0.0053889) | · | 🔵 fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `full_piv_lu/n128/b1` | 0.288527 ± 0.000791298 (W 0.00181251) | 0.29002 ± 0.00313739 (W 0.00244666) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.64992 ± 0.0515785 (W 0.0103147) | 2.65055 ± 0.153508 (W 0.0128043) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n512/b1` | 17.255 ± 4.06511 (W 0.221921) | 16.9092 ± 4.13872 (W 0.160625) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.145679 ± 0.00106403 (W 0.00138821) | 0.221013 ± 0.00197707 (W 0.00655058) | 0.132747 ± 0.000702667 (W 0.00148356) | 🔵 fork 1.52× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.64452 ± 0.194617 (W 0.0180339) | 0.826172 ± 0.195408 (W 0.0317187) | 0.328129 ± 0.0132142 (W 0.0029226) | · | 🔴 fork 1.96× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.16612 ± 0.399081 (W 0.0672372) | 4.62201 ± 0.390794 (W 0.0589249) | 1.65443 ± 0.0734758 (W 0.00315035) | · | 🔴 fork 2.52× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.112004 ± 0.000486096 (W 0.00121756) | 0.182644 ± 0.00395531 (W 0.00336691) | 0.131949 ± 0.000922538 (W 0.0017667) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.600339 ± 0.0553617 (W 0.0100162) | 0.771496 ± 0.0658492 (W 0.0201646) | 0.312608 ± 0.0159865 (W 0.00337168) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.92× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.07426 ± 0.547384 (W 0.0306104) | 4.41406 ± 0.498956 (W 0.0498074) | 1.64119 ± 0.0882994 (W 0.0038623) | · | 🔴 fork 2.48× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.08378 ± 0.00112814 (W 0.00411769) | 0.100277 ± 0.00442378 (W 0.00178069) | 0.090979 ± 0.0014351 (W 0.000884874) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.331938 ± 0.0174323 (W 0.027178) | 0.419401 ± 1.68822 (W 0.01406) | 0.194667 ± 0.0033569 (W 0.00340465) | · | 🔴 fork 1.71× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.0551 ± 0.00817532 (W 0.0249528) | 1.19151 ± 0.0160818 (W 0.0227535) | 0.971378 ± 0.0144602 (W 0.0104966) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290698 ± 0.00108429 (W 0.00190485) | 0.288785 ± 0.00275665 (W 0.0019697) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62787 ± 0.00607573 (W 0.0137618) | 2.62631 ± 0.0122824 (W 0.00814083) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8616 ± 0.0969927 (W 0.138602) | 16.8174 ± 0.236793 (W 0.146754) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.115731 ± 0.0176799 (W 0.00130504) | 0.202918 ± 0.0206734 (W 0.00603762) | 0.133802 ± 0.00146885 (W 0.00100049) | 🔵 fork 1.75× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.664648 ± 0.122942 (W 0.0180938) | 0.942721 ± 0.121774 (W 0.0216021) | 0.317902 ± 0.00296602 (W 0.00263485) | 🔵 fork 1.42× faster than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.02811 ± 0.0424716 (W 0.124302) | 4.71611 ± 0.037174 (W 0.0538358) | 1.22378 ± 0.00341477 (W 0.00855727) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 3.29× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111657 ± 0.000601482 (W 0.00147914) | 0.188956 ± 0.0102326 (W 0.00671472) | 0.131728 ± 0.000231012 (W 0.000315458) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.588143 ± 0.010346 (W 0.0175863) | 0.803123 ± 0.0192172 (W 0.0330155) | 0.298721 ± 0.00191458 (W 0.00270248) | 🔵 fork 1.37× faster than `faer-upstream` | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 3.89794 ± 0.0396643 (W 0.0398458) | 4.57011 ± 0.016538 (W 0.0877453) | 1.20392 ± 0.00620296 (W 0.00379961) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 3.24× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.187535 ± 0.000932519 (W 0.00135111) | 0.185746 ± 0.000388517 (W 0.00143958) | 0.476898 ± 0.00138265 (W 0.00300375) | · | 🔵 fork 2.54× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.25023 ± 0.019308 (W 0.00287451) | 1.24658 ± 0.019336 (W 0.00232902) | 1.84657 ± 0.0222789 (W 0.00300813) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.89302 ± 0.00658365 (W 0.00631436) | 7.89225 ± 0.00243433 (W 0.00819893) | 11.3515 ± 0.0145963 (W 0.0224663) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.77747 ± 0.00536615 (W 0.00449003) | 0.785955 ± 0.00147667 (W 0.00577638) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.89155 ± 0.0461085 (W 0.00759903) | 6.05014 ± 0.0318829 (W 0.00596967) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 43.2317 ± 0.279218 (W 0.0591567) | 43.252 ± 0.165983 (W 0.0666554) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.322971 ± 0.000624291 (W 0.00141074) | 0.325614 ± 0.00247186 (W 0.00239852) | 0.502315 ± 8.98165e-05 (W 0.00214876) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.10717 ± 0.00504496 (W 0.00478752) | 2.20063 ± 0.0100618 (W 0.00206772) | 3.30998 ± 0.00468588 (W 0.0113181) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 17.3398 ± 0.0453022 (W 0.0294085) | 17.4269 ± 0.0253951 (W 0.0280714) | 23.2028 ± 0.0254054 (W 0.0547476) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.321527 ± 0.000795871 (W 0.00327346) | 0.324825 ± 0.000391193 (W 0.00233197) | 0.486546 ± 0.00314057 (W 0.00209601) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.04718 ± 0.0034562 (W 0.00129418) | 2.14163 ± 0.00781983 (W 0.00233092) | 2.83085 ± 0.0131515 (W 0.010124) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 17.8743 ± 0.0272781 (W 0.0294435) | 17.8919 ± 0.0197533 (W 0.0226879) | 18.8184 ± 0.0465168 (W 0.0234856) | · | 🔵 fork 1.05× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189823 ± 0.00330253 (W 0.00201914) | 0.197257 ± 0.0036537 (W 0.00401425) | 0.474763 ± 0.00886973 (W 0.00273813) | · | 🔵 fork 2.50× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.850717 ± 0.0446031 (W 0.00843008) | 0.876356 ± 0.0402332 (W 0.00826214) | 0.794679 ± 0.0447664 (W 0.012422) | · | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 3.35984 ± 0.243954 (W 0.0218259) | 3.41732 ± 0.219097 (W 0.0212627) | 3.6371 ± 0.311646 (W 0.00912847) | · | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.77353 ± 0.0122732 (W 0.00910907) | 0.782267 ± 0.0107802 (W 0.00328444) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.85523 ± 1.44256 (W 0.0267662) | 6.00092 ± 1.1057 (W 0.0111494) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n512/b1` | 29.5433 ± 12.025 (W 0.0339037) | 29.6613 ± 12.0196 (W 0.164489) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.314906 ± 0.0222196 (W 0.00515529) | 0.343267 ± 0.0168255 (W 0.00481275) | 0.490373 ± 0.0132232 (W 0.00366519) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 1.58124 ± 0.188715 (W 0.0199735) | 1.6816 ± 0.122158 (W 0.0107752) | 1.01679 ± 0.0673386 (W 0.00517703) | · | 🔴 fork 1.56× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n512/b1` | 10.1018 ± 0.709437 (W 0.136737) | 9.95423 ± 0.628344 (W 0.0542854) | 7.64075 ± 0.584079 (W 0.0359352) | · | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.310849 ± 0.0251745 (W 0.00487999) | 0.334212 ± 0.0142344 (W 0.00543478) | 0.471968 ± 0.0130719 (W 0.00289416) | · | 🔵 fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 1.44385 ± 0.229912 (W 0.00888135) | 1.55301 ± 0.133192 (W 0.0211599) | 0.892401 ± 0.0764508 (W 0.00401001) | · | 🔴 fork 1.62× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 10.5091 ± 0.902544 (W 0.105118) | 10.4523 ± 0.764444 (W 0.0638517) | 5.72889 ± 0.5474 (W 0.0477196) | · | 🔴 fork 1.83× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.194697 ± 0.000405882 (W 0.00393093) | 0.208894 ± 0.000490465 (W 0.00309193) | 0.47768 ± 0.000804827 (W 0.00300865) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 2.45× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.830186 ± 0.00810704 (W 0.0185264) | 0.867735 ± 0.00606878 (W 0.0193403) | 0.664377 ± 0.00148621 (W 0.00313819) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.80025 ± 0.0192256 (W 0.0128772) | 2.85042 ± 0.00895515 (W 0.0138212) | 2.25527 ± 0.0216948 (W 0.0166128) | · | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.765082 ± 0.0324611 (W 0.00753549) | 0.775951 ± 0.00194312 (W 0.00509151) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.90718 ± 0.0871968 (W 0.0172013) | 6.03073 ± 0.0240068 (W 0.0138739) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.956 ± 0.153291 (W 0.126261) | 27.9081 ± 0.136877 (W 0.148516) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.322205 ± 0.00263196 (W 0.00413613) | 0.366241 ± 0.00244364 (W 0.00707823) | 0.487448 ± 0.00173382 (W 0.00255049) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.53752 ± 0.00975089 (W 0.0121879) | 1.68644 ± 0.00856006 (W 0.0206921) | 0.700858 ± 0.00453732 (W 0.00690728) | 🔵 fork 1.10× faster than `faer-upstream` | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 8.85245 ± 0.0464068 (W 0.0534425) | 8.80113 ± 0.0271318 (W 0.0512674) | 5.04115 ± 0.0284723 (W 0.0266696) | · | 🔴 fork 1.76× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.321636 ± 0.000779354 (W 0.00413825) | 0.356203 ± 0.0042227 (W 0.00425572) | 0.47167 ± 0.00118278 (W 0.00199614) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.40263 ± 0.00777132 (W 0.020171) | 1.5326 ± 0.0143019 (W 0.0252058) | 0.667798 ± 0.00164134 (W 0.00442672) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 9.32492 ± 0.0378026 (W 0.0528928) | 9.19465 ± 0.0905446 (W 0.0187563) | 3.42888 ± 0.00505901 (W 0.00545786) | · | 🔴 fork 2.72× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175045 ± 0.000537684 (W 0.000883698) | 0.172641 ± 0.000364342 (W 0.00105782) | 0.407189 ± 0.000131535 (W 0.00281957) | · | 🔵 fork 2.33× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.12961 ± 0.00203768 (W 0.00141347) | 1.12682 ± 0.00228572 (W 0.000908878) | 1.60002 ± 0.0041202 (W 0.00500857) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.5247 ± 0.00757233 (W 0.011697) | 7.51491 ± 0.00503609 (W 0.00351456) | 10.5728 ± 0.0190759 (W 0.0182613) | · | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.749485 ± 0.00346609 (W 0.00444967) | 0.756869 ± 0.00194908 (W 0.00439177) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.75621 ± 0.017739 (W 0.00703871) | 5.78553 ± 0.0195353 (W 0.0121103) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 42.1953 ± 0.197136 (W 0.042446) | 42.2747 ± 0.210523 (W 0.0836322) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.294418 ± 0.00112419 (W 0.00181171) | 0.294214 ± 0.000216385 (W 0.00217334) | 0.458229 ± 0.00157906 (W 0.00153867) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.00876 ± 0.0130824 (W 0.00380213) | 1.99348 ± 0.0104626 (W 0.00207126) | 3.22284 ± 0.00386233 (W 0.00793683) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 16.3309 ± 0.0234362 (W 0.0182681) | 16.3547 ± 0.0263288 (W 0.0223073) | 20.2602 ± 0.020282 (W 0.0331325) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.29225 ± 0.000435252 (W 0.00182427) | 0.292134 ± 0.00110852 (W 0.00176388) | 0.447688 ± 0.0260912 (W 0.0026024) | · | 🔵 fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 1.9302 ± 0.0114158 (W 0.00106344) | 1.93187 ± 0.0102356 (W 0.00107241) | 2.66253 ± 0.00928004 (W 0.0105608) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 16.8997 ± 0.0270571 (W 0.0697094) | 16.9045 ± 0.0168217 (W 0.0459154) | 17.515 ± 0.0243008 (W 0.0142765) | · | · |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.177511 ± 0.00290209 (W 0.00187696) | 0.178817 ± 0.0027858 (W 0.00609176) | 0.409773 ± 0.00054659 (W 0.00287415) | · | 🔵 fork 2.31× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.757669 ± 0.05984 (W 0.0126578) | 0.785372 ± 0.0658137 (W 0.015986) | 0.602912 ± 0.0362492 (W 0.00736776) | · | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 3.01469 ± 0.223909 (W 0.0388959) | 3.06264 ± 0.204788 (W 0.0307687) | 3.21409 ± 0.128143 (W 0.016035) | · | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.747431 ± 0.00580586 (W 0.00813657) | 0.743864 ± 0.0105362 (W 0.00490824) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74538 ± 1.03941 (W 0.0446365) | 5.72412 ± 1.02614 (W 0.0357091) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n512/b1` | 28.5477 ± 12.0964 (W 0.140608) | 28.5304 ± 12.0559 (W 0.217129) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.294103 ± 0.00958588 (W 0.00351297) | 0.321749 ± 0.0111497 (W 0.0045305) | 0.462361 ± 0.00928084 (W 0.00297792) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 1.43808 ± 0.124865 (W 0.0131532) | 1.48985 ± 0.0966036 (W 0.0225167) | 0.971248 ± 0.0456121 (W 0.00252591) | · | 🔴 fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n512/b1` | 8.96828 ± 0.680731 (W 0.054263) | 9.02493 ± 0.689802 (W 0.0498352) | 5.84971 ± 0.199523 (W 0.0216777) | · | 🔴 fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n128/b1` | 0.285021 ± 0.0114883 (W 0.00341578) | 0.299352 ± 0.0136778 (W 0.00596799) | 0.445371 ± 0.0116132 (W 0.00297246) | · | 🔵 fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 1.32908 ± 0.14603 (W 0.017366) | 1.34868 ± 0.157671 (W 0.0041961) | 0.868741 ± 0.0516249 (W 0.00362043) | · | 🔴 fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 9.37786 ± 0.812042 (W 0.0476769) | 9.48147 ± 0.836348 (W 0.039666) | 5.36832 ± 0.231891 (W 0.00852361) | · | 🔴 fork 1.75× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.182229 ± 0.000438505 (W 0.00167165) | 0.201526 ± 0.00626912 (W 0.00320651) | 0.407878 ± 0.00158497 (W 0.000735503) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 2.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.742543 ± 0.00690725 (W 0.0169853) | 0.793504 ± 0.0194154 (W 0.0239998) | 0.462021 ± 0.00334782 (W 0.00222639) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.43358 ± 0.020515 (W 0.0263306) | 2.50384 ± 0.00486868 (W 0.0228596) | 1.87305 ± 0.0187 (W 0.0186119) | · | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.744674 ± 0.029461 (W 0.00524928) | 0.750215 ± 0.00432711 (W 0.00657133) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.76854 ± 0.0727977 (W 0.0121529) | 5.75751 ± 0.0541002 (W 0.0131794) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.8844 ± 0.280137 (W 0.14615) | 26.9869 ± 0.086972 (W 0.120799) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.299297 ± 0.00181013 (W 0.00506188) | 0.341802 ± 0.00394125 (W 0.00457343) | 0.457472 ± 0.00105475 (W 0.00223654) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.39917 ± 0.00976214 (W 0.015078) | 1.47996 ± 1.27413 (W 0.022974) | 0.681625 ± 0.00412995 (W 0.0021582) | · | 🔴 fork 2.05× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 7.87639 ± 0.0320096 (W 0.0805588) | 8.01986 ± 0.0401093 (W 0.168915) | 3.47179 ± 0.0140352 (W 0.00878246) | · | 🔴 fork 2.27× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.293306 ± 0.0023433 (W 0.00333202) | 0.322708 ± 0.0015392 (W 0.00287116) | 0.44606 ± 0.00122251 (W 0.00279654) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.28183 ± 0.021166 (W 0.024055) | 1.31443 ± 0.0039029 (W 0.0157096) | 0.645211 ± 0.00395456 (W 0.00290269) | · | 🔴 fork 1.99× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 8.25419 ± 0.0493938 (W 0.0604485) | 8.38418 ± 0.0267964 (W 0.0769617) | 3.31982 ± 0.0220867 (W 0.010695) | · | 🔴 fork 2.49× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.829453 ± 0.00755612 (W 0.00369272) | 0.822959 ± 0.0068369 (W 0.00774637) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.2777 ± 0.459818 (W 0.0681264) | 54.5836 ± 1.67735 (W 0.621176) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.471298 ± 0.00187508 (W 0.00238161) | 0.46752 ± 0.00130266 (W 0.00356465) | 0.659598 ± 0.135663 (W 0.00238928) | · | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.4018 ± 0.111923 (W 0.0500407) | 19.0282 ± 0.0240728 (W 0.0435113) | 18.1473 ± 2.53378 (W 0.0494558) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.81679 ± 0.00436532 (W 0.00235902) | 0.818599 ± 0.00118118 (W 0.00313246) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.778 ± 0.0691581 (W 0.122262) | 24.9117 ± 1.26383 (W 0.326536) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.496435 ± 0.00363308 (W 0.0137129) | 0.497817 ± 0.00286927 (W 0.0134466) | 0.532422 ± 0.120224 (W 0.00734223) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.44852 ± 0.116525 (W 0.0641266) | 13.0342 ± 0.0490197 (W 0.0424337) | 13.5385 ± 1.78073 (W 0.0157548) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814056 ± 0.0014489 (W 0.00259783) | 0.811668 ± 0.00564126 (W 0.00467197) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.8417 ± 0.0508419 (W 0.121456) | 19.3853 ± 0.372427 (W 0.762004) | - | 🔵 fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.486035 ± 0.00717007 (W 0.00874151) | 0.53118 ± 0.013851 (W 0.00902703) | 0.594678 ± 0.166358 (W 0.00759663) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.69297 ± 0.129739 (W 0.0728184) | 12.2374 ± 0.0214423 (W 0.0446927) | 4.13109 ± 1.96574 (W 0.0311699) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 2.10× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731294 ± 0.00137517 (W 0.0123386) | 0.73078 ± 0.000729884 (W 0.00337558) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.1412 ± 0.552196 (W 0.125955) | 47.1013 ± 0.465464 (W 0.258652) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.383294 ± 0.00205987 (W 0.00358193) | 0.386248 ± 0.00100138 (W 0.00161895) | 0.2846 ± 0.000854423 (W 0.00185486) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2775 ± 0.0118832 (W 0.0405284) | 13.2528 ± 0.0346555 (W 0.0111338) | 11.6198 ± 0.0739275 (W 0.0213898) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.728236 ± 0.00257133 (W 0.00262243) | 0.733356 ± 0.00477136 (W 0.00320468) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.7071 ± 0.0939918 (W 0.117071) | 17.8312 ± 0.16898 (W 0.237464) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.410452 ± 0.00222317 (W 0.00361799) | 0.425902 ± 0.00761121 (W 0.00824252) | 0.287598 ± 0.000948589 (W 0.00211077) | · | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.35834 ± 0.0574093 (W 0.0419505) | 7.36073 ± 0.0324966 (W 0.0375701) | 11.562 ± 0.118797 (W 0.0104259) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.751105 ± 0.0143063 (W 0.0107699) | 0.73006 ± 0.00246499 (W 0.00715997) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6102 ± 0.119874 (W 0.0590641) | 13.8249 ± 0.063483 (W 0.0933402) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.391838 ± 0.00357426 (W 0.0036969) | 0.45177 ± 0.00486772 (W 0.00785123) | 0.286904 ± 0.00147709 (W 0.00224572) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.63441 ± 0.0499167 (W 0.0257299) | 6.70519 ± 0.0443636 (W 0.025124) | 3.13565 ± 0.0298414 (W 0.0066205) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78577 ± 0.00784947 (W 0.00243833) | 1.83034 ± 0.00616411 (W 0.00383162) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.887 ± 0.526485 (W 0.438085) | 155.6 ± 0.761204 (W 1.62141) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.992661 ± 0.00290718 (W 0.00147848) | 0.995263 ± 0.00247817 (W 0.00364681) | 1.19508 ± 0.0171804 (W 0.00279082) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.6038 ± 0.154106 (W 0.107666) | 53.728 ± 0.0996676 (W 0.0796541) | 56.2188 ± 6.13696 (W 0.121108) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77274 ± 0.00404116 (W 0.00210048) | 1.81556 ± 0.00896401 (W 0.00313156) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.057 ± 0.57462 (W 0.515213) | 65.5073 ± 0.787096 (W 0.921843) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.815536 ± 0.00453611 (W 0.0145823) | 0.804739 ± 0.00422351 (W 0.0151226) | 1.09455 ± 0.00752992 (W 0.00319226) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.8409 ± 0.229929 (W 0.142118) | 29.7301 ± 0.000313492 (W 0.0786606) | 52.1372 ± 0.185862 (W 0.0776946) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.28× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77184 ± 0.00256189 (W 0.00179213) | 1.80937 ± 0.0195618 (W 0.0041631) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.6207 ± 0.142212 (W 0.691491) | 41.6385 ± 0.16431 (W 0.398866) | - | 🔵 fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.798774 ± 0.00570613 (W 0.00989027) | 0.786611 ± 0.023991 (W 0.00995541) | 1.08873 ± 0.00510732 (W 0.00189206) | · | 🔵 fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 18.9084 ± 0.405113 (W 0.0692541) | 25.7789 ± 0.0808997 (W 0.0661903) | 58.089 ± 0.454044 (W 0.112849) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 3.07× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66713 ± 0.00421117 (W 0.00377006) | 1.70282 ± 0.00588092 (W 0.00255658) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.067 ± 0.966087 (W 0.660245) | 143.739 ± 0.88975 (W 0.499271) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.872784 ± 0.00465355 (W 0.0021919) | 0.871883 ± 0.00196937 (W 0.0025736) | 1.06765 ± 0.0361611 (W 0.00214452) | · | 🔵 fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 41.7301 ± 0.00921833 (W 0.0166211) | 41.7022 ± 0.0774941 (W 0.0440957) | 49.9108 ± 0.367332 (W 0.16382) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.65807 ± 0.00417117 (W 0.00248592) | 1.68921 ± 0.000208502 (W 0.00406089) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 51.6738 ± 0.593822 (W 0.560846) | 52.4991 ± 0.366087 (W 0.694587) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.70381 ± 0.00194982 (W 0.0134954) | 0.705794 ± 0.0034536 (W 0.00714967) | 1.06717 ± 0.00182463 (W 0.00180771) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.4115 ± 0.0169033 (W 0.0533524) | 17.4072 ± 0.0764127 (W 0.0779464) | 49.5345 ± 0.443336 (W 0.0880528) | · | 🔵 fork 2.84× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66028 ± 0.00178335 (W 0.00294721) | 1.68954 ± 0.00638357 (W 0.00346007) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.9272 ± 0.695489 (W 0.718956) | 29.6827 ± 0.554542 (W 0.852009) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.685507 ± 0.00160142 (W 0.011399) | 0.692748 ± 0.00618516 (W 0.00844198) | 1.06636 ± 0.0084371 (W 0.00262335) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.4264 ± 0.0773451 (W 0.038625) | 13.545 ± 0.064135 (W 0.0446523) | 50.2073 ± 0.710618 (W 0.0564906) | · | 🔵 fork 3.74× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `solve/1024x64`, `solve/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 75.0771 ± 0.794752 (W 0.600691) | 77.3214 ± 1.36853 (W 0.474246) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12487 ± 0.0213205 (W 0.00380447) | 1.25324 ± 0.0206201 (W 0.00257789) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.0314 ± 0.115859 (W 0.0253728) | 18.4018 ± 0.400151 (W 0.0431446) | 75.5591 ± 3.67058 (W 1.04743) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 4.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.39416 ± 0.00135795 (W 0.00171406) | 0.512265 ± 0.000893395 (W 0.00236658) | 0.92582 ± 0.136149 (W 0.00274296) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.6812 ± 0.240565 (W 0.24569) | 40.0991 ± 0.529132 (W 0.344675) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.1328 ± 0.00927691 (W 0.00249341) | 1.25667 ± 0.0123252 (W 0.00285652) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.23539 ± 0.0675257 (W 0.077746) | 9.38337 ± 0.120067 (W 0.0662436) | 9.87479 ± 0.201685 (W 0.0624354) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.228396 ± 0.00202209 (W 0.00180043) | 0.354426 ± 0.0271819 (W 0.0141833) | 0.28999 ± 0.00355557 (W 0.0034402) | 🔵 fork 1.55× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.6648 ± 0.610533 (W 0.207275) | 34.9302 ± 0.299356 (W 0.202204) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12346 ± 0.0117867 (W 0.00436825) | 1.24333 ± 0.0137742 (W 0.00314969) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.47893 ± 0.206604 (W 0.105985) | 8.03776 ± 0.320767 (W 0.339048) | 6.8209 ± 0.0575836 (W 0.0384797) | 🔵 fork 1.47× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.210732 ± 0.00138784 (W 0.00530566) | 0.346421 ± 0.0196874 (W 0.0245809) | 0.1701 ± 0.00111085 (W 0.00336136) | 🔵 fork 1.64× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.0302 ± 0.492232 (W 0.304639) | 71.4473 ± 0.70555 (W 0.362591) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05478 ± 0.00450068 (W 0.00563235) | 1.05445 ± 0.00472315 (W 0.00294436) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3158 ± 0.0259532 (W 0.0210002) | 13.3361 ± 0.0364797 (W 0.0125931) | 209.699 ± 0.218396 (W 0.0674924) | · | 🔵 fork 15.75× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.310488 ± 0.00262104 (W 0.00237283) | 0.309799 ± 0.00240928 (W 0.00212426) | 3.12953 ± 0.00592496 (W 0.00153451) | · | 🔵 fork 10.08× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.3175 ± 0.339092 (W 0.154251) | 35.2123 ± 0.224074 (W 0.220371) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05326 ± 0.00714897 (W 0.00174334) | 1.05372 ± 0.0099662 (W 0.00498679) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.29423 ± 0.0191419 (W 0.0418702) | 4.67523 ± 0.0221007 (W 0.0652269) | 5.26258 ± 0.0147691 (W 0.0119422) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.135728 ± 0.000695734 (W 0.00291446) | 0.168904 ± 0.00318235 (W 0.00244741) | 0.234321 ± 0.0018848 (W 0.00377498) | 🔵 fork 1.24× faster than `faer-upstream` | 🔵 fork 1.73× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.0247 ± 0.205861 (W 0.198153) | 30.094 ± 0.226919 (W 0.0973361) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.05503 ± 0.00422784 (W 0.00305678) | 1.04684 ± 0.0158571 (W 0.00651026) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.83091 ± 0.0292565 (W 0.0382501) | 3.37483 ± 0.00406168 (W 0.0522943) | 3.14275 ± 0.0210271 (W 0.00272464) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.114144 ± 0.000787596 (W 0.00171821) | 0.151543 ± 0.00589467 (W 0.00569845) | 0.131259 ± 0.00127854 (W 0.0018929) | 🔵 fork 1.33× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 232.056 ± 1.21311 (W 1.87215) | 238.274 ± 2.94274 (W 1.0813) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.37235 ± 0.0351485 (W 0.0182725) | 2.42239 ± 0.0665599 (W 0.0140356) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 45.7924 ± 0.193884 (W 0.101241) | 46.3738 ± 0.255646 (W 0.0322405) | 88.6488 ± 0.538995 (W 0.496734) | · | 🔵 fork 1.94× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 1.00629 ± 0.00506273 (W 0.00401146) | 1.0569 ± 0.0229886 (W 0.00273962) | 2.31725 ± 0.0182947 (W 0.00227401) | · | 🔵 fork 2.30× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.9387 ± 2.63821 (W 0.287251) | 97.3318 ± 3.60715 (W 0.500623) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.40166 ± 0.00822085 (W 0.0123987) | 2.51133 ± 0.0394766 (W 0.012134) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.0737 ± 0.00918158 (W 0.0653637) | 17.9478 ± 0.0200955 (W 0.433966) | 29.2034 ± 3.11591 (W 0.0582851) | · | 🔵 fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.433114 ± 0.00215717 (W 0.00411436) | 0.490703 ± 0.00271087 (W 0.00412509) | 0.639615 ± 0.00477892 (W 0.00344989) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.48× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.2678 ± 0.249499 (W 0.414387) | 70.7413 ± 1.06428 (W 0.441566) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.40998 ± 0.0295154 (W 0.00901548) | 2.50864 ± 0.042576 (W 0.00765425) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 12.4925 ± 0.159557 (W 0.0953114) | 12.4603 ± 0.206254 (W 0.0393911) | 13.5972 ± 3.0384 (W 0.0743633) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.351912 ± 0.00390964 (W 0.0045588) | 0.405182 ± 0.0135292 (W 0.00355119) | 0.45312 ± 0.00416427 (W 0.00145949) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 231.362 ± 2.02768 (W 1.09705) | 231.67 ± 1.14648 (W 1.27719) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.29494 ± 0.0243239 (W 0.0105191) | 2.2902 ± 0.0160088 (W 0.0068087) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 42.0034 ± 0.0798927 (W 0.0326805) | 41.9779 ± 0.0788078 (W 0.0757849) | 72.6484 ± 0.461927 (W 0.10978) | · | 🔵 fork 1.73× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.894663 ± 0.00448518 (W 0.00286092) | 0.894055 ± 0.00187836 (W 0.00321447) | 2.11736 ± 0.0090259 (W 0.00204217) | · | 🔵 fork 2.37× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.3792 ± 1.45498 (W 0.46973) | 92.2416 ± 1.69306 (W 0.579035) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.31014 ± 0.0383422 (W 0.00543483) | 2.29382 ± 0.0342098 (W 0.00696885) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.8424 ± 0.119005 (W 0.0579864) | 13.8349 ± 0.0853896 (W 0.079805) | 20.5231 ± 0.0455332 (W 0.0297605) | · | 🔵 fork 1.48× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.32668 ± 0.00414403 (W 0.00205842) | 0.321301 ± 0.0219972 (W 0.00461874) | 0.59081 ± 0.00449666 (W 0.00459164) | · | 🔵 fork 1.81× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 65.9233 ± 1.48807 (W 0.366691) | 65.8526 ± 0.767137 (W 0.619267) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.2908 ± 0.0275228 (W 0.00886407) | 2.29688 ± 0.0130526 (W 0.0102505) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.2712 ± 0.0410967 (W 0.056127) | 8.31801 ± 0.0662592 (W 0.0369949) | 11.2666 ± 0.0224857 (W 0.0216528) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.240307 ± 0.00276491 (W 0.00212874) | 0.240819 ± 0.000530329 (W 0.00399031) | 0.408909 ± 0.0045662 (W 0.00326604) | · | 🔵 fork 1.70× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
