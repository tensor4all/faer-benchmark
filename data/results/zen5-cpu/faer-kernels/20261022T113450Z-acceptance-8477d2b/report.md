# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `8477d2b8ad8cd906ed79061fa972900bf99a06c0`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `b09a1dc5bec4c327d94b4745cf3512c3695097f5`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `cdd86f983d5b1f9d779af609c9cf71798afe451480489a054d27c05c3333d752`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-22T13:02:53.477963Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-small,gemm-mid,gemm-tall,gemm-wide,linalg-mid,linalg-tall --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label acceptance-8477d2b --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261022T113450Z-acceptance-8477d2b/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.81%, worst 97.00% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 189 of 2124 engine cells exceed 5% and carry `!`; median within-process relative SD 0.42%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002354 ± 1.1547e-05 (W 1.8061e-05) | 0.002314 ± 6.35085e-06 (W 1.33116e-05) | 0.004569 ± 3.50761e-05 (W 3.93357e-05) | · | 🔵 faer-fork 1.94× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017102 ± 7.55447e-05 (W 4.19786e-05) | 0.017061 ± 7.95634e-05 (W 1.85553e-05) | 0.024315 ± 0.0001245 (W 5.09902e-05) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056806 ± 0.000221428 (W 5.41295e-05) | 0.056705 ± 2.22336e-05 (W 2.04768e-05) | 0.062676 ± 0.000141035 (W 8.17141e-05) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002325 ± 1.12694e-05 (W 1.33116e-05) | 0.01028 ± 0.000213909 (W 0.00128734) | 0.004989 ± 0.000175291 (W 0.00010723) | 🔵 faer-fork 4.42× faster than `faer-upstream` | 🔵 faer-fork 2.15× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017162 ± 6.9282e-05 (W 2.61954e-05) | 0.025818 ± 0.00319989 (W 0.00363197) | 0.014036 ± 0.000122882 (W 7.13043e-05) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.02101 ± 0.000207196 (W 0.000278523) | 0.068878 ± 0.00411739 (W 0.0142556) | 0.022221 ± 0.000541134 (W 9.04561e-05) | 🔵 faer-fork 3.28× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002354 ± 1.67432e-05 (W 1.52086e-05) | 0.014658 ± 0.000812091 (W 0.00150695) | 0.004759 ± 0.000301016 (W 0.000182113) | 🔵 faer-fork 6.23× faster than `faer-upstream` | 🔵 faer-fork 2.02× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017232 ± 7.76745e-05 (W 5.91549e-05) | 0.019286 ± 0.00131866 (W 0.00200833) | 0.009849 ± 0.000281017 (W 0.000119061) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.018895 ± 0.000539872 (W 0.000924182) | 0.029275 ± 0.000923444 (W 0.00157379) | 0.014727 ± 0.000180484 (W 0.000216484) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 1.21244e-05 (W 1.10136e-05) | 0.002344 ± 1.1547e-05 (W 1.63799e-05) | 0.004609 ± 5.34821e-05 (W 2.89879e-05) | · | 🔵 faer-fork 1.98× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017142 ± 7.37111e-05 (W 3.20656e-05) | 0.017051 ± 7.38941e-05 (W 2.07364e-05) | 0.024385 ± 4.61303e-05 (W 3.20936e-05) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056686 ± 4.14045e-05 (W 6.6106e-05) | 0.056776 ± 0.000140211 (W 7.26856e-05) | 0.062618 ± 0.000123049 (W 9.47908e-05) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 2.08167e-05 (W 3.6977e-05) | 0.010289 ± 0.000737051 (W 0.000903716) | 0.005269 ± 0.000168049 (W 8.68458e-05) | 🔵 faer-fork 4.41× faster than `faer-upstream` | 🔵 faer-fork 2.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017062 ± 0.000103184 (W 2.01296e-05) | 0.023414 ± 0.00168085 (W 0.00301373) | 0.014307 ± 0.000142163 (W 8.04363e-05) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.020998 ± 0.000100002 (W 0.000332834) | 0.066113 ± 0.0094493 (W 0.00830578) | 0.022261 ± 0.000284828 (W 0.000182905) | 🔵 faer-fork 3.15× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 6.35085e-06 (W 1.34611e-05) | 0.014086 ± 0.000240624 (W 0.0010021) | 0.004849 ± 7.2111e-05 (W 0.000141087) | 🔵 faer-fork 6.06× faster than `faer-upstream` | 🔵 faer-fork 2.09× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017242 ± 1.52753e-05 (W 2.16795e-05) | 0.019296 ± 0.000230934 (W 0.00186011) | 0.010069 ± 0.00022354 (W 0.00023329) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.018744 ± 0.000514166 (W 0.00122003) | 0.029265 ± 0.000691237 (W 0.00180216) | 0.014687 ± 0.000156195 (W 0.000167169) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008877 ± 9.50438e-06 (W 1.90053e-05) | 0.008877 ± 2.94449e-05 (W 1.89526e-05) | 0.011011 ± 6.32218e-05 (W 0.000105945) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067696 ± 0.000172427 (W 0.00141752) | 0.067748 ± 1.13578e-05 (W 0.000116294) | 0.081732 ± 0.000534254 (W 0.000644345) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226509 ± 8.19898e-05 (W 0.00130627) | 0.226673 ± 0.000124328 (W 0.00149621) | 0.269292 ± 0.00123049 (W 0.0022458) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008797 ± 6.11583e-05 (W 2.11471e-05) | 0.008897 ± 7.64875e-05 (W 2.61209e-05) | 0.014006 ± 0.000373778 (W 0.00110717) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.023314 ± 0.00044165 (W 0.000229424) | 0.036048 ± 0.0037991 (W 0.0025742) | 0.035257 ± 0.000421673 (W 0.000386536) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.063518 ± 0.00035197 (W 0.000240277) | 0.089576 ± 0.00631515 (W 0.00657087) | 0.098713 ± 0.000595483 (W 0.0017407) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008847 ± 4.56107e-05 (W 1.52086e-05) | 0.008876 ± 4.59021e-05 (W 1.14018e-05) | 0.024517 ± 0.0050624 (W 0.000221525) | · | 🔵 faer-fork 2.77× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.027542 ± 0.000360034 (W 0.000520177) | 0.036588 ± 0.00185454 (W 0.00143727) | 0.01575 ± 7.55667e-05 (W 8.77223e-05) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.048099 ± 0.000157684 (W 0.000693822) | 0.051095 ± 0.000775338 (W 0.000970341) | 0.042781 ± 0.000254547 (W 0.00131242) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008877 ± 2.51064e-05 (W 1.54693e-05) | 0.008877 ± 1.47309e-05 (W 1.43248e-05) | 0.011011 ± 7.0946e-05 (W 0.000116457) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067725 ± 3.40441e-05 (W 7.51152e-05) | 0.067746 ± 5.15073e-05 (W 4.03646e-05) | 0.082075 ± 0.000557373 (W 0.00177228) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226669 ± 0.000172861 (W 0.00142032) | 0.226813 ± 9.69484e-05 (W 0.00225953) | 0.270024 ± 0.0014605 (W 0.00347217) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008787 ± 3.76431e-05 (W 2.22329e-05) | 0.008877 ± 0.00010504 (W 1.64682e-05) | 0.013966 ± 0.000339907 (W 0.000144326) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.023865 ± 0.000126361 (W 0.000382674) | 0.04305 ± 0.00514745 (W 0.00492831) | 0.035075 ± 0.000377638 (W 0.000402562) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.064249 ± 0.000333242 (W 0.000485961) | 0.088865 ± 0.00381401 (W 0.00636001) | 0.097371 ± 0.00051934 (W 0.00205045) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008867 ± 2.58908e-05 (W 1.92354e-05) | 0.008857 ± 2.66521e-05 (W 1.63156e-05) | 0.024576 ± 0.000128791 (W 0.00013699) | · | 🔵 faer-fork 2.77× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.027571 ± 0.00021133 (W 0.000476868) | 0.036338 ± 0.000376431 (W 0.00186127) | 0.01568 ± 0.000195952 (W 0.000174052) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.048612 ± 0.000452118 (W 0.000392707) | 0.050596 ± 0.000187033 (W 0.00123386) | 0.042508 ± 0.000127798 (W 0.000217677) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133503 ± 0.000716556 (W 0.00138318) | 0.134304 ± 0.000486662 (W 0.00156794) | 0.16749 ± 0.00100653 (W 0.00125348) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.453691 ± 0.00216881 (W 0.00222497) | 0.453337 ± 0.00176719 (W 0.00223096) | 0.478648 ± 0.00107827 (W 0.00243019) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07524 ± 0.00273693 (W 0.00166855) | 1.07284 ± 0.00313626 (W 0.00106827) | 1.19599 ± 0.00396325 (W 0.00237882) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.61296 ± 0.0107672 (W 0.00288349) | 3.61283 ± 0.00332663 (W 0.00591392) | 3.73121 ± 0.0142396 (W 0.00445693) | · | · |  |
| `gemm/512x512x512/b1` | 8.63063 ± 0.0331321 (W 0.010443) | 8.59234 ± 0.0216668 (W 0.00980331) | 9.97146 ± 0.0475534 (W 0.0174786) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4122 ± 0.065179 (W 0.0235445) | 29.3341 ± 0.0761035 (W 0.0227776) | 30.5609 ± 0.255222 (W 0.0241232) | · | · |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.040367 ± 0.000234159 (W 0.000497067) | 0.068678 ± 0.0203084 (W 0.0208986) | 0.056087 ± 0.000422879 (W 0.000437196) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.152187 ± 0.00437189 (W 0.0175287) | 0.16116 ± 0.0210225 (W 0.0165771) | 0.136186 ± 0.000369273 (W 0.00148846) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.303095 ± 0.00190786 (W 0.00376929) | 0.303141 ± 0.00460058 (W 0.00534395) | 0.344131 ± 0.00184455 (W 0.00229562) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.932979 ± 0.00299364 (W 0.00744529) | 0.931135 ± 0.00433781 (W 0.00406) | 1.00157 ± 0.00353808 (W 0.0012675) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.22906 ± 0.00620299 (W 0.00584515) | 2.24372 ± 0.00753689 (W 0.00879247) | 2.91385 ± 0.0980398 (W 0.00882034) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.54022 ± 0.0186485 (W 0.00909375) | 7.5457 ± 0.022728 (W 0.0106543) | 8.51464 ± 0.0249863 (W 0.0118111) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.024015 ± 0.000431073 (W 0.000294245) | 0.078688 ± 0.00562241 (W 0.0178229) | 0.032803 ± 0.000190799 (W 0.000187894) | 🔵 faer-fork 3.28× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.195377 ± 0.0381567 (W 0.0453507) | 0.144193 ± 0.0326092 (W 0.0280892) | 0.074759 ± 0.000285274 (W 0.000290044) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 2.61× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.218487 ± 0.00808981 (W 0.0308608) | 0.226492 ± 0.0104422 (W 0.0195252) | 0.178763 ± 0.00095011 (W 0.001578) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.56358 ± 0.00284057 (W 0.00959746) | 0.563971 ± 0.00278914 (W 0.0171724) | 0.513727 ± 0.00160868 (W 0.00274562) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.20384 ± 0.0142563 (W 0.00935343) | 1.18488 ± 0.00997254 (W 0.0107362) | 1.51964 ± 0.0141452 (W 0.00499609) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.92662 ± 0.0236288 (W 0.0151893) | 3.92769 ± 0.00754824 (W 0.0188759) | 4.65254 ± 0.0220914 (W 0.023362) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133653 ± 0.000181428 (W 0.00148835) | 0.133829 ± 0.000450428 (W 0.00121662) | 0.168138 ± 0.000706118 (W 0.00147252) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.45073 ± 0.00241275 (W 0.00200398) | 0.454096 ± 0.00126404 (W 0.00242146) | 0.48482 ± 0.00168453 (W 0.00280658) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07262 ± 0.00250906 (W 0.00107456) | 1.07776 ± 0.00715714 (W 0.00133301) | 1.20136 ± 0.00284972 (W 0.00383086) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.62124 ± 0.00990727 (W 0.00529937) | 3.61613 ± 0.00141114 (W 0.0047343) | 3.71943 ± 0.00706386 (W 0.00435081) | · | · |  |
| `gemm/512x512x512/b1` | 8.61884 ± 0.0421391 (W 0.0118041) | 8.61228 ± 0.00309029 (W 0.0126931) | 9.87373 ± 0.0527393 (W 0.0190936) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4744 ± 0.0385974 (W 0.029436) | 29.4194 ± 0.0444146 (W 0.0243008) | 30.6061 ± 0.307023 (W 0.0363874) | · | · |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.040826 ± 0.000130745 (W 0.000550893) | 0.087854 ± 0.00706041 (W 0.0140989) | 0.055715 ± 0.000428113 (W 0.000160345) | 🔵 faer-fork 2.15× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.135468 ± 0.0202561 (W 0.0194485) | 0.152164 ± 0.00728332 (W 0.012768) | 0.135488 ± 0.00109449 (W 0.00025617) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.308612 ± 0.00132894 (W 0.00825271) | 0.308695 ± 0.00213144 (W 0.0082274) | 0.346353 ± 0.00292179 (W 0.00196657) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.93579 ± 0.00181482 (W 0.00280611) | 0.934601 ± 0.002782 (W 0.00367283) | 1.00404 ± 0.00347148 (W 0.00193006) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.24199 ± 0.00741692 (W 0.00485323) | 2.23805 ± 0.00773409 (W 0.00376346) | 2.8339 ± 0.0836829 (W 0.00650339) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.52109 ± 0.0195492 (W 0.00774125) | 7.53152 ± 0.029852 (W 0.00624233) | 8.4964 ± 0.0154287 (W 0.00908211) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.024846 ± 0.000531264 (W 0.00039621) | 0.082226 ± 0.0175187 (W 0.0115199) | 0.031711 ± 0.000523114 (W 0.00011347) | 🔵 faer-fork 3.31× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.190542 ± 0.0245488 (W 0.0293867) | 0.167335 ± 0.0164299 (W 0.0301128) | 0.074671 ± 0.000366986 (W 0.000226321) | · | 🔴 faer-fork 2.55× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.20423 ± 0.014588 (W 0.0420461) | 0.20959 ± 0.00695015 (W 0.0344129) | 0.17944 ± 0.000592204 (W 0.00156578) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.561285 ± 0.00419098 (W 0.0165864) | 0.559453 ± 0.00240068 (W 0.00819932) | 0.51655 ± 0.00328869 (W 0.00342133) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.18786 ± 0.00243026 (W 0.0142192) | 1.1958 ± 0.00551319 (W 0.0099601) | 1.53236 ± 0.0125851 (W 0.00542863) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.9395 ± 0.0165154 (W 0.0176247) | 3.96045 ± 0.0113733 (W 0.0143086) | 4.64312 ± 0.01678 (W 0.0210742) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538708 ± 0.00073082 (W 0.00199149) | 0.540132 ± 0.000289114 (W 0.00204599) | 0.652129 ± 0.00610127 (W 0.00605777) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81473 ± 0.00472217 (W 0.00268114) | 1.81557 ± 0.001437 (W 0.0021598) | 2.1642 ± 0.00459649 (W 0.01022) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.28964 ± 0.00655776 (W 0.00573392) | 4.27995 ± 0.00213875 (W 0.00206589) | 5.05973 ± 0.0425123 (W 0.0131528) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.45 ± 0.00534547 (W 0.0265892) | 14.4603 ± 0.0236999 (W 0.0143009) | 17.182 ± 0.0288139 (W 0.0329577) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.2586 ± 0.0687873 (W 0.0331365) | 34.2858 ± 0.00803735 (W 0.0267204) | 40.8138 ± 0.0727801 (W 0.0604088) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.38 ± 0.115662 (W 0.376911) | 116.548 ± 0.338577 (W 0.0321631) | 136.986 ± 0.849986 (W 0.0781593) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.14185 ± 0.000578547 (W 0.00133115) | 0.159888 ± 0.000994957 (W 0.00129943) | 0.234021 ± 0.00155548 (W 0.00139475) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.474744 ± 0.00132424 (W 0.00154398) | 0.474996 ± 0.00114298 (W 0.00357524) | 0.745986 ± 0.0054613 (W 0.00673282) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.1298 ± 0.00255088 (W 0.00378802) | 1.12759 ± 0.000833403 (W 0.00645235) | 1.79401 ± 0.0154684 (W 0.00359752) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.67525 ± 0.002835 (W 0.00305893) | 3.67413 ± 0.00144306 (W 0.00542684) | 5.79633 ± 0.0179688 (W 0.0081042) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.71291 ± 0.0109989 (W 0.02303) | 8.69787 ± 0.0165523 (W 0.0101197) | 13.8179 ± 0.0368021 (W 0.0269525) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4453 ± 0.0243323 (W 0.0359484) | 29.4569 ± 0.0765162 (W 0.0222033) | 46.4749 ± 0.123434 (W 0.0552492) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.074692 ± 0.000119968 (W 0.000410269) | 0.129535 ± 0.00983643 (W 0.015829) | 0.094419 ± 0.000101007 (W 0.000485283) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.275904 ± 0.0091009 (W 0.0116495) | 0.283278 ± 0.00336665 (W 0.0105294) | 0.296287 ± 0.00266522 (W 0.0027575) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.605358 ± 0.0197202 (W 0.00840306) | 0.613514 ± 0.00619136 (W 0.010068) | 0.682882 ± 0.0165326 (W 0.00170312) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 1.87225 ± 0.00203857 (W 0.00974903) | 1.88338 ± 0.00443846 (W 0.0103316) | 2.28861 ± 0.00981801 (W 0.00623875) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.51316 ± 0.00899374 (W 0.015667) | 4.51787 ± 0.0133098 (W 0.0118263) | 5.55332 ± 0.0359781 (W 0.0148951) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.9672 ± 0.00199075 (W 0.0192977) | 14.9716 ± 0.0128504 (W 0.0347956) | 18.8335 ± 0.274889 (W 0.0532104) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538547 ± 0.00170697 (W 0.00218522) | 0.538849 ± 0.00185887 (W 0.00235629) | 0.650817 ± 0.00284422 (W 0.00732244) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81059 ± 0.00234874 (W 0.0023404) | 1.81617 ± 0.000143075 (W 0.0021326) | 2.1529 ± 0.00787154 (W 0.0154825) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.28458 ± 0.00262224 (W 0.00269342) | 4.27917 ± 0.0074275 (W 0.00344943) | 5.14003 ± 0.0132945 (W 0.0266889) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4362 ± 0.00766814 (W 0.0149965) | 14.4532 ± 0.0369929 (W 0.0210201) | 17.1752 ± 0.00738375 (W 0.0205458) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.2937 ± 0.0472453 (W 0.0185697) | 34.3047 ± 0.0315015 (W 0.0204087) | 40.9532 ± 0.0390527 (W 0.0665074) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.375 ± 0.231953 (W 0.0792246) | 116.32 ± 0.104551 (W 0.0454422) | 137.139 ± 0.215099 (W 0.102168) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.143347 ± 0.00115091 (W 0.00182961) | 0.160412 ± 0.000568264 (W 0.00226623) | 0.233189 ± 0.000819933 (W 0.00281178) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.477217 ± 0.0024571 (W 0.00283221) | 0.472929 ± 0.00447414 (W 0.00274937) | 0.744477 ± 0.00163366 (W 0.00398974) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.12931 ± 0.00284522 (W 0.00234879) | 1.1267 ± 0.00294878 (W 0.00416966) | 1.81395 ± 0.0180664 (W 0.00577502) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.66929 ± 0.00735227 (W 0.0121452) | 3.67058 ± 0.00628214 (W 0.0065922) | 5.78553 ± 0.0117075 (W 0.0134423) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.71467 ± 0.0273464 (W 0.0155538) | 8.71786 ± 0.0195377 (W 0.0167395) | 13.7886 ± 0.0463654 (W 0.0248361) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4872 ± 0.0432481 (W 0.0102493) | 29.4735 ± 0.102706 (W 0.0165106) | 46.3273 ± 0.124603 (W 0.052138) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.076373 ± 0.000133762 (W 0.000234605) | 0.114695 ± 0.00773221 (W 0.00620765) | 0.095288 ± 0.00014078 (W 0.00166145) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.281495 ± 0.0110277 (W 0.0125921) | 0.282817 ± 0.00834375 (W 0.0120618) | 0.296157 ± 0.00120898 (W 0.00261935) | · | 🔵 faer-fork 1.05× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.604266 ± 0.0010286 (W 0.0147434) | 0.602833 ± 0.00146135 (W 0.0097082) | 0.697552 ± 0.0109094 (W 0.00403819) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.8684 ± 0.00564028 (W 0.00832653) | 1.86753 ± 0.0019159 (W 0.0096475) | 2.27037 ± 0.0108842 (W 0.00610133) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.52245 ± 0.00787089 (W 0.0111441) | 4.52195 ± 0.00556387 (W 0.0148626) | 5.54238 ± 0.0209776 (W 0.0152282) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.9845 ± 0.0199315 (W 0.0204855) | 14.9554 ± 0.0675962 (W 0.0572097) | 18.7344 ± 0.101528 (W 0.0915232) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26262 ± 0.0121473 (W 0.00391275) | 1.27438 ± 0.0176347 (W 0.00363812) | 1.54374 ± 0.0541176 (W 0.0102729) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.07029 ± 0.0032856 (W 0.00720921) | 1.07142 ± 0.000339813 (W 0.00689981) | 1.52115 ± 0.0234676 (W 0.00901145) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08939 ± 0.000357709 (W 0.0029074) | 1.08674 ± 0.00322201 (W 0.00179683) | 1.56281 ± 0.00715452 (W 0.00418281) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.332149 ± 0.00567679 (W 0.00735772) | 0.439485 ± 0.00336899 (W 0.00411736) | 0.426809 ± 0.00957264 (W 0.00432646) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.329784 ± 0.0018492 (W 0.00376708) | 0.330305 ± 0.0024308 (W 0.00227867) | 0.430011 ± 0.00234612 (W 0.00254116) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.310698 ± 0.00181683 (W 0.0083186) | 0.310594 ± 0.00853909 (W 0.00686275) | 0.391451 ± 0.00160318 (W 0.00173304) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.151674 ± 0.000864114 (W 0.00317619) | 0.438293 ± 0.00175754 (W 0.00371731) | 0.262246 ± 0.00558875 (W 0.00231627) | 🔵 faer-fork 2.89× faster than `faer-upstream` | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.213892 ± 0.00375031 (W 0.00400549) | 0.214252 ± 0.00379318 (W 0.00160186) | 0.288646 ± 0.00191353 (W 0.00189354) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.192465 ± 0.00856227 (W 0.0224118) | 0.196739 ± 0.00158862 (W 0.0184291) | 0.198305 ± 0.000665421 (W 0.000921039) | · | · | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.01689 ± 0.0202232 (W 0.00190596) | 1.01533 ± 0.0222311 (W 0.00200634) | 2.65412 ± 0.0155736 (W 0.00538947) | · | 🔵 faer-fork 2.61× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.08727 ± 0.0044399 (W 0.00293827) | 1.08922 ± 0.00377164 (W 0.0030134) | 1.4354 ± 0.0160927 (W 0.00710472) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.13445 ± 0.00515913 (W 0.00230714) | 1.13605 ± 0.012117 (W 0.00315873) | 1.25136 ± 0.0176549 (W 0.00320434) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.262974 ± 0.00017685 (W 0.00305711) | 0.710035 ± 0.0093383 (W 0.0225314) | 0.648057 ± 0.00214758 (W 0.00381489) | 🔵 faer-fork 2.70× faster than `faer-upstream` | 🔵 faer-fork 2.46× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.321639 ± 0.00123189 (W 0.00277258) | 0.320066 ± 0.00161458 (W 0.00274187) | 0.431347 ± 0.00132127 (W 0.0028864) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.313284 ± 0.00262384 (W 0.0039181) | 0.312952 ± 0.000587838 (W 0.00239203) | 0.334553 ± 0.00550862 (W 0.00143976) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.139642 ± 0.000402773 (W 0.00294306) | 1.13965 ± 0.0211207 (W 0.0186902) | 0.346625 ± 0.00173951 (W 0.00255531) | 🔵 faer-fork 8.16× faster than `faer-upstream` | 🔵 faer-fork 2.48× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.201217 ± 0.0042279 (W 0.00271536) | 0.203462 ± 0.00263808 (W 0.00393011) | 0.294397 ± 0.0010044 (W 0.00211001) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.181773 ± 0.00211723 (W 0.0031837) | 0.179156 ± 0.00364087 (W 0.00363535) | 0.175136 ± 0.00130628 (W 0.00182067) | · | · |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.15591 ± 0.0154723 (W 0.0093696) | 4.15454 ± 0.00980861 (W 0.00517222) | 5.67135 ± 0.0423202 (W 0.00690543) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.32521 ± 0.0039528 (W 0.00933927) | 4.32146 ± 0.00400864 (W 0.00536911) | 5.62845 ± 0.0112835 (W 0.0164167) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.39593 ± 0.00205608 (W 0.00938184) | 4.41017 ± 0.0108868 (W 0.00494403) | 5.25243 ± 0.00765602 (W 0.00809814) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.10232 ± 0.00477841 (W 0.00482812) | 1.67183 ± 0.00444826 (W 0.00425804) | 1.9296 ± 0.024664 (W 0.00800177) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.20657 ± 0.0042043 (W 0.0172801) | 1.19959 ± 0.00626549 (W 0.00658531) | 2.1173 ± 0.0161251 (W 0.021779) | · | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.15462 ± 0.00132322 (W 0.0047897) | 1.15704 ± 0.000725608 (W 0.00415137) | 2.06386 ± 0.0160067 (W 0.00446554) | · | 🔵 faer-fork 1.79× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.624574 ± 0.00715234 (W 0.00536645) | 0.922896 ± 0.0100264 (W 0.0101078) | 0.958716 ± 0.00684748 (W 0.00357471) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.647675 ± 0.00191422 (W 0.00392101) | 0.650702 ± 0.0058845 (W 0.00601875) | 0.982018 ± 0.216315 (W 0.00838568) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.605816 ± 0.00138279 (W 0.00677351) | 0.605226 ± 0.004126 (W 0.00479258) | 0.75549 ± 0.00888635 (W 0.00259506) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.10351 ± 0.0305022 (W 0.00561998) | 4.09012 ± 0.0307495 (W 0.00786762) | 5.73316 ± 0.0103353 (W 0.012949) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.35098 ± 0.00385627 (W 0.00616658) | 4.37257 ± 0.0192642 (W 0.0160783) | 5.39762 ± 0.0333295 (W 0.0529161) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.44474 ± 0.00646536 (W 0.00963398) | 4.45207 ± 0.00572419 (W 0.00237651) | 5.83567 ± 0.0551666 (W 0.0206464) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.02658 ± 0.00755081 (W 0.00563495) | 1.93592 ± 0.0248185 (W 0.0628655) | 10.649 ± 5.91661 (W 0.0163938) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔵 faer-fork 10.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.20671 ± 0.00393422 (W 0.00785871) | 1.2105 ± 0.00267137 (W 0.00590149) | 2.36069 ± 0.0349987 (W 0.0565697) | · | 🔵 faer-fork 1.96× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.22547 ± 0.0077451 (W 0.0058559) | 1.21464 ± 0.0195495 (W 0.00496519) | 2.05579 ± 0.0494623 (W 0.0120804) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.530579 ± 0.00584384 (W 0.00502937) | 2.5384 ± 0.0195613 (W 0.0509769) | 10.6391 ± 3.39665 (W 0.0210242) | 🔵 faer-fork 4.78× faster than `faer-upstream` | 🔵 faer-fork 20.05× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.642497 ± 0.00408299 (W 0.00280641) | 0.640121 ± 0.00744428 (W 0.00394827) | 1.52156 ± 0.144207 (W 0.0228001) | · | 🔵 faer-fork 2.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.619131 ± 0.00795879 (W 0.00596373) | 0.617679 ± 0.00667646 (W 0.00294825) | 1.25354 ± 0.0855191 (W 0.0622499) | · | 🔵 faer-fork 2.02× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.11923 ± 0.0122798 (W 0.0036212) | 1.12009 ± 0.00576739 (W 0.00214346) | 1.24213 ± 0.00425158 (W 0.00411755) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.297267 ± 0.003212 (W 0.00352916) | 0.313428 ± 0.0013735 (W 0.00477334) | 0.328432 ± 0.00535542 (W 0.00268214) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.156146 ± 0.000670051 (W 0.00143767) | 0.180321 ± 0.000377583 (W 0.00404759) | 0.172213 ± 0.00402384 (W 0.00149468) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08867 ± 0.00409438 (W 0.00316742) | 1.08745 ± 0.00178117 (W 0.00215932) | 1.52748 ± 0.0322158 (W 0.00676576) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.283061 ± 0.000929217 (W 0.00199636) | 0.305479 ± 0.00688662 (W 0.00952967) | 0.389535 ± 0.000754 (W 0.00136381) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.151554 ± 0.000822643 (W 0.0011607) | 0.199647 ± 0.00505975 (W 0.0241248) | 0.19856 ± 0.00099513 (W 0.0015336) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.43661 ± 0.0140337 (W 0.0111001) | 4.44341 ± 0.00239178 (W 0.00877338) | 5.77303 ± 0.00946235 (W 0.0206828) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.19051 ± 0.00888607 (W 0.00268578) | 1.2184 ± 0.00210811 (W 0.0116894) | 2.03663 ± 0.0250556 (W 0.00985033) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.590409 ± 0.00487844 (W 0.00295653) | 0.618542 ± 0.000720806 (W 0.00629417) | 1.19422 ± 0.016553 (W 0.0673061) | · | 🔵 faer-fork 2.02× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.3986 ± 0.00340002 (W 0.00974068) | 4.39839 ± 0.0137876 (W 0.00935646) | 5.23209 ± 0.00538643 (W 0.0145133) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.1058 ± 0.00407816 (W 0.00230132) | 1.15146 ± 0.00932487 (W 0.00344778) | 2.06693 ± 0.000401731 (W 0.00291817) | · | 🔵 faer-fork 1.87× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.566204 ± 0.00153388 (W 0.00161766) | 0.599797 ± 0.00483271 (W 0.00442108) | 0.759425 ± 0.00319166 (W 0.00253529) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070914 ± 0.00244999 (W 0.000550428) | 0.067618 ± 0.000431813 (W 0.000233776) | 0.114815 ± 0.00129432 (W 0.000485508) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.394284 ± 0.00763439 (W 0.00217316) | 0.388053 ± 0.00188778 (W 0.00260118) | 0.638347 ± 0.00147997 (W 0.0282015) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.56469 ± 0.0267304 (W 0.00604089) | 2.58182 ± 0.0353562 (W 0.00791714) | 4.03353 ± 0.0223911 (W 0.033409) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.25827 ± 0.00213146 (W 0.00308042) | 2.25482 ± 0.00874445 (W 0.00267528) | 1.85765 ± 0.00906057 (W 0.00891484) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.81761 ± 0.0462658 (W 0.0149042) | 9.79581 ± 0.0239848 (W 0.0120899) | 10.0217 ± 0.0298139 (W 0.0160309) | · | · |  |
| `eigh/n512/b1` | 48.8152 ± 0.11812 (W 0.0376106) | 48.7713 ± 0.168272 (W 0.0463008) | 61.3348 ± 0.091861 (W 0.107212) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.308464 ± 0.00218359 (W 0.000995237) | 0.311804 ± 0.000337811 (W 0.00318786) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70298 ± 0.0221858 (W 0.00876265) | 2.75856 ± 0.0150317 (W 0.0125757) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.9979 ± 0.16725 (W 0.0418677) | 22.5454 ± 0.150185 (W 0.0621873) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259897 ± 0.000976048 (W 0.00173919) | 0.258928 ± 0.000963274 (W 0.00164082) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.260024 ± 0.000526396 (W 0.00160346) | 0.259686 ± 0.000531379 (W 0.00178442) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.9485 ± 0.016226 (W 0.00444511) | 1.90744 ± 0.0380207 (W 0.00769642) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92951 ± 0.0186257 (W 0.00319334) | 1.91547 ± 0.0242973 (W 0.00364909) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.9041 ± 0.0143025 (W 0.0190941) | 15.823 ± 0.0266041 (W 0.0348921) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.915 ± 0.00628744 (W 0.0288018) | 15.8536 ± 0.0345152 (W 0.0217819) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134183 ± 0.000974175 (W 0.00109484) | 0.137227 ± 0.016246 (W 0.00232615) | 0.171043 ± 0.0183829 (W 0.00158721) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.986427 ± 0.116521 (W 0.00306398) | 1.04323 ± 0.011437 (W 0.00685273) | 0.966483 ± 0.135515 (W 0.00417512) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.63345 ± 0.000700413 (W 0.00444187) | 7.13617 ± 0.0648162 (W 0.00892856) | 7.00266 ± 0.0176701 (W 0.0108024) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 0.517547 ± 0.00137241 (W 0.00244969) | 0.516198 ± 0.00065231 (W 0.00148686) | 0.750296 ± 0.00463646 (W 0.00363462) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.89942 ± 0.00547612 (W 0.00478826) | 2.94976 ± 0.0233595 (W 0.00411603) | 4.33274 ± 0.0115488 (W 0.016441) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.4481 ± 0.0343843 (W 0.0238783) | 20.8215 ± 0.179186 (W 0.0421869) | 30.6067 ± 0.00752338 (W 0.0485085) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.33629 ± 0.000798576 (W 0.00161966) | 0.535201 ± 0.00255853 (W 0.0028644) | 0.371106 ± 0.00123257 (W 0.00335949) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.61303 ± 0.00286408 (W 0.0043912) | 2.85172 ± 0.0292684 (W 0.00602424) | 2.04659 ± 0.00290708 (W 0.00375718) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.9518 ± 0.0690302 (W 0.0165866) | 17.5704 ± 0.0318435 (W 0.0194437) | 14.2296 ± 0.00215257 (W 0.0165106) | 🔵 faer-fork 1.96× faster than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.134344 ± 0.000580815 (W 0.000929126) | 0.137276 ± 0.000498088 (W 0.00275941) | 0.170412 ± 0.000265852 (W 0.00167837) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.766188 ± 0.00421438 (W 0.00205805) | 0.810129 ± 0.0114584 (W 0.00368751) | 0.972567 ± 0.000650109 (W 0.00164205) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.59827 ± 0.0320825 (W 0.0106818) | 7.0807 ± 0.0455855 (W 0.0083687) | 6.00253 ± 0.018275 (W 0.0125885) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67801 ± 0.00899094 (W 0.00445048) | 3.67575 ± 0.00260326 (W 0.0116008) | 3.3987 ± 0.00793934 (W 0.0105984) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4976 ± 0.0243179 (W 0.0150911) | 18.4714 ± 0.0495131 (W 0.040565) | 18.1278 ± 0.0162507 (W 0.0621907) | · | · |  |
| `svd_thin/n512/b1` | 106.284 ± 0.566684 (W 0.12443) | 105.889 ± 0.406109 (W 0.0939215) | 116.924 ± 1.07076 (W 0.153382) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69716 ± 0.00571223 (W 0.00424189) | 2.68696 ± 0.0077092 (W 0.00622439) | 1.19867 ± 0.00189284 (W 0.00388523) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4742 ± 0.0425927 (W 0.0137839) | 12.4424 ± 0.0410575 (W 0.0169977) | 6.96668 ± 0.0109059 (W 0.00742524) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.4779 ± 0.236511 (W 0.0466215) | 66.307 ± 0.157278 (W 0.0549785) | 47.7061 ± 0.0729 (W 0.0472794) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004428 ± 2e-05 (W 4.03138e-05) | 0.004078 ± 8.0829e-05 (W 5.16362e-05) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012192 ± 0.000178214 (W 8.63134e-05) | 0.011321 ± 0.000185203 (W 6.90601e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.040916 ± 0.00321902 (W 0.000353248) | 0.039354 ± 0.00310935 (W 0.000478932) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089177 ± 0.00276853 (W 0.00172409) | 0.104905 ± 0.00210735 (W 0.00642019) | 0.114594 ± 0.000514366 (W 0.000637182) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.398815 ± 0.00978475 (W 0.0170214) | 0.417374 ± 0.0239957 (W 0.0201494) | 0.406759 ± 0.00409276 (W 0.00405765) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.56794 ± 0.0417756 (W 0.0241909) | 1.67667 ± 0.0140953 (W 0.0249141) | 1.94889 ± 0.0217892 (W 0.0118978) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.32102 ± 0.0454996 (W 0.0235779) | 2.29316 ± 0.0103026 (W 0.0265658) | 1.07181 ± 0.00172929 (W 0.00233635) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.02342 ± 0.077444 (W 0.0642931) | 6.94706 ± 0.0170655 (W 0.0313346) | 4.78591 ± 0.0239091 (W 0.012539) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.3089 ± 0.245479 (W 0.0419678) | 26.1273 ± 0.240348 (W 0.0571423) | 21.6494 ± 0.126858 (W 0.0488767) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309718 ± 0.00036121 (W 0.00158593) | 0.312153 ± 0.000595838 (W 0.00269469) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7033 ± 0.00818573 (W 0.0108417) | 2.76697 ± 0.0191101 (W 0.00606849) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.4958 ± 0.0302211 (W 0.0926455) | 18.0763 ± 0.0664454 (W 0.25471) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.085138 ± 0.000952959 (W 0.000769865) | 0.083436 ± 0.000690817 (W 0.000381196) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.086392 ± 0.000936481 (W 0.000278398) | 0.08499 ± 0.000547847 (W 0.00125564) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.526089 ± 0.00191627 (W 0.00169425) | 0.518677 ± 0.000762512 (W 0.00183549) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.53186 ± 0.00425324 (W 0.00357452) | 0.526027 ± 0.00371038 (W 0.00199255) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.16853 ± 0.00989754 (W 0.00822041) | 4.08756 ± 0.00473124 (W 0.011901) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.16566 ± 0.00763232 (W 0.0244808) | 4.08907 ± 0.00731541 (W 0.0068348) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.135564 ± 0.0176498 (W 0.000725206) | 0.205396 ± 0.0194082 (W 0.0114251) | 0.152186 ± 0.0158975 (W 0.00136596) | 🔵 faer-fork 1.52× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.00316 ± 0.127082 (W 0.00357702) | 1.1692 ± 0.00765763 (W 0.0241315) | 0.381667 ± 0.110556 (W 0.00187065) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 2.63× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.81103 ± 0.0134826 (W 0.0730558) | 5.63901 ± 0.0391407 (W 0.0356453) | 2.61842 ± 0.0239408 (W 0.0131668) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.604158 ± 0.0366863 (W 0.0384381) | 1.44888 ± 0.0229048 (W 0.0275548) | 0.480605 ± 0.00165908 (W 0.00272118) | 🔵 faer-fork 2.40× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.9709 ± 0.0179771 (W 0.0332259) | 3.79203 ± 0.0409982 (W 0.0564001) | 2.00591 ± 0.0118345 (W 0.00821186) | 🔵 faer-fork 1.92× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 10.0651 ± 1.01263 (W 0.0609338) | 14.4555 ± 1.05009 (W 0.0722633) | 12.0504 ± 0.0645148 (W 0.0301029) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.407164 ± 0.0329278 (W 0.0217005) | 1.47882 ± 0.0317217 (W 0.0189299) | 0.19698 ± 0.00126334 (W 0.00162986) | 🔵 faer-fork 3.63× faster than `faer-upstream` | 🔴 faer-fork 2.07× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.45332 ± 0.0120779 (W 0.0274631) | 5.6029 ± 0.057549 (W 0.0580894) | 0.669867 ± 0.000513094 (W 0.00318124) | 🔵 faer-fork 3.86× faster than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.17346 ± 0.0100252 (W 0.0450347) | 22.1293 ± 0.151749 (W 0.0927745) | 3.86406 ± 0.00630734 (W 0.00714805) | 🔵 faer-fork 4.28× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.135364 ± 0.00132825 (W 0.00157332) | 0.200635 ± 0.00208115 (W 0.00427809) | 0.15044 ± 0.000610312 (W 0.0010482) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.766821 ± 0.00240612 (W 0.00258691) | 0.914657 ± 0.0136648 (W 0.0147982) | 0.368498 ± 0.00255653 (W 0.00370226) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.74135 ± 0.0329228 (W 0.0864697) | 5.50616 ± 0.0301761 (W 0.0576043) | 1.83313 ± 0.0244389 (W 0.0013232) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 2.59× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.03439 ± 0.0159678 (W 0.0123233) | 3.03294 ± 0.00946009 (W 0.0206285) | 2.63632 ± 0.0106263 (W 0.00677977) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6936 ± 0.0169258 (W 0.052216) | 13.6883 ± 0.0113511 (W 0.0582071) | 12.4962 ± 0.042112 (W 0.0213107) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.8239 ± 0.0988508 (W 0.387782) | 61.5813 ± 0.476337 (W 0.391766) | 58.5931 ± 1.75509 (W 0.0677206) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22896 ± 0.00273724 (W 0.00443314) | 2.22373 ± 0.0059985 (W 0.00412749) | 1.13762 ± 0.00605225 (W 0.00299328) | · | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.9014 ± 0.0787745 (W 0.0981033) | 10.8641 ± 0.0167491 (W 0.0598311) | 6.12533 ± 0.0171948 (W 0.00961365) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.1669 ± 0.0611369 (W 0.427457) | 48.0208 ± 0.262118 (W 0.305024) | 25.8872 ± 0.0582222 (W 0.030925) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004038 ± 0.000159478 (W 3.07132e-05) | 0.003737 ± 0.0001545 (W 3e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011812 ± 0.000740231 (W 4.87883e-05) | 0.01101 ± 0.000699356 (W 7.52416e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.035857 ± 0.000176163 (W 0.000271844) | 0.034855 ± 0.000955724 (W 0.00161882) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089767 ± 0.00301313 (W 0.00141978) | 0.103172 ± 0.00330856 (W 0.00179017) | 0.113803 ± 0.00164701 (W 0.000773785) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.408912 ± 0.0127483 (W 0.0210428) | 0.449251 ± 0.00759453 (W 0.0263826) | 0.359941 ± 0.00415318 (W 0.00335403) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.52005 ± 0.0233503 (W 0.0310476) | 1.69131 ± 0.0533058 (W 0.0245991) | 1.45274 ± 0.0205869 (W 0.0135829) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.39706 ± 0.0404848 (W 0.0247164) | 2.31577 ± 0.00758846 (W 0.0236219) | 1.00896 ± 0.00601867 (W 0.00268735) | · | 🔴 faer-fork 2.38× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.95597 ± 0.0270745 (W 0.0299973) | 7.0753 ± 0.0129084 (W 0.0535344) | 4.01141 ± 0.024524 (W 0.00996122) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 24.2205 ± 0.0633321 (W 0.0325102) | 24.8706 ± 0.049537 (W 0.0786779) | 15.2003 ± 0.0354462 (W 0.037241) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.30945 ± 0.00153262 (W 0.00202455) | 0.312626 ± 0.00211165 (W 0.00103081) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6924 ± 0.0121289 (W 0.00708234) | 2.75752 ± 0.00366403 (W 0.00826333) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.1843 ± 0.0156492 (W 0.122256) | 17.8928 ± 0.0465654 (W 0.0748697) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.059682 ± 0.000331765 (W 0.000792134) | 0.10164 ± 0.000697557 (W 0.00116793) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.060823 ± 0.000407799 (W 0.00141901) | 0.101891 ± 0.00184564 (W 0.00725328) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.285915 ± 0.00194711 (W 0.00186825) | 0.40609 ± 0.0114276 (W 0.0130094) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.290469 ± 0.00359709 (W 0.00321241) | 0.418773 ± 0.00317183 (W 0.0146145) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.26188 ± 0.0107456 (W 0.014254) | 2.71972 ± 0.0668816 (W 0.140587) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.27752 ± 0.0201305 (W 0.0146772) | 2.56743 ± 0.155478 (W 0.146528) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.134923 ± 0.0172709 (W 0.00138306) | 0.219381 ± 0.0224058 (W 0.0055848) | 0.14932 ± 0.0217595 (W 0.00146638) | 🔵 faer-fork 1.63× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.999918 ± 0.142486 (W 0.00435352) | 1.26198 ± 0.0320444 (W 0.0275843) | 0.350863 ± 0.154845 (W 0.00236554) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 2.85× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.66499 ± 0.0274676 (W 0.0537363) | 5.73621 ± 0.0576633 (W 0.0814966) | 2.25718 ± 0.0674617 (W 0.0151742) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 2.07× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.604015 ± 0.0139108 (W 0.0327603) | 1.91159 ± 0.0339415 (W 0.0406269) | 0.429785 ± 0.00267111 (W 0.00260055) | 🔵 faer-fork 3.16× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.79965 ± 0.0120007 (W 0.0132628) | 4.81923 ± 0.0434161 (W 0.0721445) | 1.7922 ± 0.00110897 (W 0.00643476) | 🔵 faer-fork 2.68× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 8.76652 ± 0.0235339 (W 0.0549397) | 15.7145 ± 0.205472 (W 0.143581) | 9.08933 ± 0.0329109 (W 0.0220016) | 🔵 faer-fork 1.79× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.360265 ± 0.00258915 (W 0.0102704) | 1.96056 ± 0.0285116 (W 0.0327229) | 0.156252 ± 0.000617858 (W 0.00180845) | 🔵 faer-fork 5.44× faster than `faer-upstream` | 🔴 faer-fork 2.31× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.39255 ± 0.00126391 (W 0.0120924) | 6.61588 ± 0.0369991 (W 0.0614389) | 0.57611 ± 0.000259739 (W 0.00281872) | 🔵 faer-fork 4.75× faster than `faer-upstream` | 🔴 faer-fork 2.42× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.79683 ± 0.0176128 (W 0.029375) | 25.0755 ± 0.0427581 (W 0.0843323) | 2.32607 ± 0.00856776 (W 0.00642183) | 🔵 faer-fork 5.23× faster than `faer-upstream` | 🔴 faer-fork 2.06× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.135331 ± 0.000222663 (W 0.00171288) | 0.212809 ± 0.0024778 (W 0.00597398) | 0.145942 ± 0.000516643 (W 0.00144709) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.772006 ± 0.00153028 (W 0.00663404) | 0.951929 ± 0.0250217 (W 0.0121406) | 0.335615 ± 0.00083749 (W 0.00324415) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 2.30× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 4.62854 ± 0.0294355 (W 0.0237338) | 5.62461 ± 0.082006 (W 0.128139) | 1.31474 ± 0.0214571 (W 0.00601736) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 3.52× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.03761 ± 0.00401044 (W 0.0145065) | 3.12062 ± 0.0103242 (W 0.0132902) | 2.514 ± 0.00533545 (W 0.00535624) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4979 ± 0.0409204 (W 0.0299883) | 13.8082 ± 0.0880215 (W 0.028241) | 11.5063 ± 0.0463394 (W 0.0226586) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.5373 ± 0.412564 (W 0.524378) | 60.8359 ± 0.39856 (W 0.560366) | 48.9602 ± 2.4254 (W 0.0823006) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22276 ± 0.00919858 (W 0.00417985) | 2.22209 ± 0.0108567 (W 0.00417596) | 1.12604 ± 0.0036866 (W 0.00280725) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 11.0314 ± 0.0297994 (W 0.0243009) | 10.9728 ± 0.0307617 (W 0.0267844) | 6.00546 ± 0.00855328 (W 0.00480246) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.2524 ± 0.163254 (W 0.409279) | 49.609 ± 0.330437 (W 0.335314) | 22.5211 ± 0.0776569 (W 0.0315138) | · | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004047 ± 0.000142116 (W 3.12618e-05) | 0.003767 ± 0.000135758 (W 3.41658e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.01051 ± 0.000711928 (W 4.98929e-05) | 0.009859 ± 0.000740526 (W 0.000100724) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.039333 ± 0.00131491 (W 0.00168743) | 0.037529 ± 0.00105321 (W 0.00112985) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.064111 ± 0.0022599 (W 6.44073e-05) | 0.060554 ± 0.000223341 (W 0.000819451) | 0.094056 ± 0.0010683 (W 0.00142923) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.323781 ± 0.00449936 (W 0.00196459) | 0.319579 ± 0.00441581 (W 0.0021869) | 0.463897 ± 0.0118191 (W 0.00358993) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.07242 ± 0.00582167 (W 0.00464837) | 2.0606 ± 0.00419052 (W 0.00221104) | 3.40447 ± 0.0450845 (W 0.0627081) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.2515 ± 0.00620132 (W 0.00245602) | 2.24813 ± 0.00791698 (W 0.00198072) | 1.8198 ± 0.00320032 (W 0.00822588) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.77345 ± 0.0463711 (W 0.00959671) | 9.74635 ± 0.032607 (W 0.00916955) | 9.85876 ± 0.0124828 (W 0.00951645) | · | · |  |
| `eigh/n512/b1` | 48.4694 ± 0.0662116 (W 0.395029) | 48.5287 ± 0.119548 (W 0.0391601) | 60.1183 ± 0.112477 (W 0.0383739) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.288968 ± 0.000376746 (W 0.00268533) | 0.289467 ± 0.000475791 (W 0.00277556) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61239 ± 0.0241665 (W 0.00615045) | 2.62245 ± 0.0218046 (W 0.00906234) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.4872 ± 0.18656 (W 0.0439539) | 21.5353 ± 0.211618 (W 0.0408431) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254757 ± 0.000103016 (W 0.00185795) | 0.253712 ± 0.000492358 (W 0.00199798) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.256804 ± 0.00140187 (W 0.00209013) | 0.255596 ± 0.00045095 (W 0.00161996) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.88305 ± 0.0140691 (W 0.00231676) | 1.8691 ± 0.0230741 (W 0.00327488) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.89314 ± 0.00477903 (W 0.00568793) | 1.87342 ± 0.00397014 (W 0.00369175) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.7416 ± 0.00710758 (W 0.0241591) | 15.6843 ± 0.0212514 (W 0.0282279) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7897 ± 0.00384702 (W 0.0332074) | 15.7594 ± 0.0231961 (W 0.0296042) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145844 ± 0.00113254 (W 0.00173977) | 0.144541 ± 0.000875332 (W 0.00159831) | 0.133288 ± 0.000531673 (W 0.00151462) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.709351 ± 0.117881 (W 0.00437324) | 0.699321 ± 0.117749 (W 0.00278838) | 0.817302 ± 0.00304614 (W 0.0030687) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.13812 ± 0.0250561 (W 0.00829969) | 6.1271 ± 0.00479064 (W 0.00934208) | 5.21235 ± 0.0074386 (W 0.0102242) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.489904 ± 0.00132461 (W 0.00181404) | 0.492392 ± 0.00140847 (W 0.00210364) | 0.680387 ± 0.00236272 (W 0.00241753) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.78493 ± 0.00859922 (W 0.00663322) | 2.80312 ± 0.0054524 (W 0.00562846) | 4.31803 ± 0.0121234 (W 0.00719664) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.7454 ± 0.0428768 (W 0.0410345) | 19.8382 ± 0.0607034 (W 0.0264527) | 30.315 ± 0.0324711 (W 0.0248506) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.279834 ± 0.00245581 (W 0.00188776) | 0.284006 ± 0.00108211 (W 0.00148371) | 0.333716 ± 0.00210927 (W 0.00295762) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.37254 ± 0.00281597 (W 0.00266912) | 1.38487 ± 0.007465 (W 0.00228937) | 1.90235 ± 0.00285533 (W 0.0053661) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.96082 ± 0.0773686 (W 0.0116627) | 8.09108 ± 0.0784378 (W 0.0115014) | 13.4274 ± 0.0534922 (W 0.0126226) | · | 🔵 faer-fork 1.69× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.113082 ± 0.000238294 (W 0.00135426) | 0.113252 ± 0.000508131 (W 0.000275328) | 0.132428 ± 8.0181e-05 (W 0.00128183) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.673173 ± 0.00423514 (W 0.00257639) | 0.66602 ± 0.00186995 (W 0.00262829) | 0.815939 ± 0.0024119 (W 0.00276526) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.08188 ± 0.00407212 (W 0.00520068) | 6.07582 ± 0.00550781 (W 0.0161951) | 5.21665 ± 0.0221007 (W 0.00416875) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67592 ± 0.00818417 (W 0.00462477) | 3.66986 ± 0.00288991 (W 0.00836439) | 3.31869 ± 0.00444737 (W 0.0127546) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3638 ± 0.0161023 (W 0.0222125) | 18.3455 ± 0.0412256 (W 0.0109101) | 17.7577 ± 0.0127889 (W 0.018462) | · | · |  |
| `svd_thin/n512/b1` | 105.006 ± 0.327236 (W 0.0607282) | 104.83 ± 0.314288 (W 0.0418981) | 116.547 ± 1.06635 (W 0.184669) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.62156 ± 0.00507097 (W 0.00232861) | 2.61204 ± 0.00741295 (W 0.00395143) | 1.15679 ± 0.000727533 (W 0.00256442) | · | 🔴 faer-fork 2.27× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2967 ± 0.0125051 (W 0.0132001) | 12.265 ± 0.0133092 (W 0.0179543) | 6.84378 ± 0.0116372 (W 0.0113439) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.4845 ± 0.197715 (W 0.0503381) | 65.2031 ± 0.12257 (W 0.0426723) | 47.3995 ± 0.314828 (W 0.0564458) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.00527 ± 0.000383993 (W 3.07295e-05) | 0.004909 ± 0.000225965 (W 4.17289e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013545 ± 0.000136504 (W 3.96888e-05) | 0.012713 ± 0.000226187 (W 6.12479e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.045415 ± 0.00284253 (W 0.000271828) | 0.043261 ± 0.00233749 (W 0.000229922) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.082054 ± 0.00319373 (W 0.00133486) | 0.097673 ± 0.00528623 (W 0.00324214) | 0.093715 ± 0.000350506 (W 0.000695456) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.342042 ± 0.023909 (W 0.0207151) | 0.340159 ± 0.00559765 (W 0.0135896) | 0.239687 ± 0.00329583 (W 0.00321544) | · | 🔴 faer-fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.13592 ± 0.00896838 (W 0.0277) | 1.23103 ± 0.0239879 (W 0.0245878) | 1.41672 ± 0.0169011 (W 0.0118785) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.30053 ± 0.0261724 (W 0.0448985) | 2.30102 ± 0.0266257 (W 0.0253024) | 1.04582 ± 0.00435907 (W 0.00354768) | · | 🔴 faer-fork 2.20× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.95166 ± 0.0697195 (W 0.0301514) | 6.91546 ± 0.0347027 (W 0.029958) | 4.70188 ± 0.0168626 (W 0.00915096) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 25.9545 ± 0.24107 (W 0.0772236) | 25.7817 ± 0.176265 (W 0.147202) | 21.2124 ± 0.069004 (W 0.0364077) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.289494 ± 0.000741507 (W 0.00238024) | 0.290712 ± 0.000969888 (W 0.00237028) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6222 ± 0.0063439 (W 0.00829171) | 2.62943 ± 0.0135918 (W 0.00855676) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8853 ± 0.0563055 (W 0.0359667) | 16.9301 ± 0.0346748 (W 0.215305) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.094456 ± 0.000691232 (W 0.0027556) | 0.083996 ± 0.00027335 (W 0.00143535) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.097253 ± 0.00123702 (W 0.00231225) | 0.08613 ± 0.000761392 (W 0.00102617) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.53133 ± 0.00172439 (W 0.0042829) | 0.521142 ± 0.00265223 (W 0.00206281) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.537608 ± 0.00161589 (W 0.00460274) | 0.528295 ± 0.00207591 (W 0.00149271) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.12744 ± 0.0164617 (W 0.0187403) | 4.0827 ± 0.0127836 (W 0.00934276) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.11811 ± 0.0114341 (W 0.0127753) | 4.10725 ± 0.00938738 (W 0.00491164) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146833 ± 0.000597294 (W 0.00277118) | 0.213399 ± 0.00599106 (W 0.00728649) | 0.13294 ± 0.00030694 (W 0.00181705) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.71224 ± 0.11194 (W 0.00611255) | 0.839427 ± 0.109361 (W 0.0186389) | 0.324389 ± 0.00334839 (W 0.00294488) | · | 🔴 faer-fork 2.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.30533 ± 0.0164595 (W 0.0591399) | 4.60759 ± 0.0336373 (W 0.124226) | 1.62799 ± 0.00475853 (W 0.00186011) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 2.64× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.568789 ± 0.00677599 (W 0.028939) | 1.3917 ± 0.0319803 (W 0.0192284) | 0.4501 ± 0.00198466 (W 0.00302364) | 🔵 faer-fork 2.45× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.88001 ± 0.00762696 (W 0.0264497) | 3.64584 ± 0.0164958 (W 0.0434892) | 2.18769 ± 0.00829118 (W 0.00974961) | 🔵 faer-fork 1.94× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.5556 ± 1.00029 (W 0.110823) | 13.1106 ± 0.967986 (W 0.0818933) | 13.0767 ± 0.0506142 (W 0.0156273) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.350348 ± 0.0065592 (W 0.0207393) | 1.16285 ± 0.0404983 (W 0.0181055) | 0.1808 ± 0.000700874 (W 0.00134194) | 🔵 faer-fork 3.32× faster than `faer-upstream` | 🔴 faer-fork 1.94× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.32897 ± 0.0299838 (W 0.0334732) | 3.05586 ± 0.071534 (W 0.0517949) | 0.618572 ± 0.00267931 (W 0.00257067) | 🔵 faer-fork 2.30× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.75831 ± 0.018613 (W 0.0219337) | 8.39445 ± 0.00388568 (W 0.123737) | 3.66196 ± 0.00511801 (W 0.00392991) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.113403 ± 0.000744582 (W 0.000257125) | 0.178573 ± 0.00599186 (W 0.00831359) | 0.132086 ± 0.000537849 (W 0.00124745) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.681489 ± 0.00182997 (W 0.00294865) | 0.76267 ± 0.0068756 (W 0.0149466) | 0.313589 ± 0.00297058 (W 0.00156148) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.20266 ± 0.072754 (W 0.0969058) | 4.41315 ± 0.0395411 (W 0.0367821) | 1.61747 ± 0.0148041 (W 0.00391231) | · | 🔴 faer-fork 2.60× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02312 ± 0.00845703 (W 0.0196764) | 2.99495 ± 0.00403654 (W 0.0201533) | 2.5887 ± 0.00119787 (W 0.00353756) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6288 ± 0.0211295 (W 0.105072) | 13.6188 ± 0.00982607 (W 0.101539) | 12.3478 ± 0.0534802 (W 0.0197123) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.7435 ± 0.16193 (W 0.345718) | 60.7233 ± 0.1472 (W 0.253563) | 56.7938 ± 0.291523 (W 0.0403647) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.1608 ± 0.00890195 (W 0.00605327) | 2.16349 ± 0.0131949 (W 0.00891913) | 1.12344 ± 0.00336137 (W 0.00196765) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6999 ± 0.0155184 (W 0.0700255) | 10.6643 ± 0.0164867 (W 0.038646) | 6.09866 ± 0.0067127 (W 0.00636412) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.3232 ± 0.177637 (W 0.307867) | 47.2925 ± 0.289358 (W 0.356209) | 25.6391 ± 0.0185941 (W 0.0593151) | · | 🔴 faer-fork 1.85× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004999 ± 0.000263694 (W 4.42979e-05) | 0.004628 ± 0.00022026 (W 2.23652e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013355 ± 0.000699144 (W 5.97495e-05) | 0.012624 ± 0.000945422 (W 5.64119e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.040767 ± 0.000232195 (W 0.000335137) | 0.039755 ± 0.0011127 (W 0.00133358) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.088134 ± 0.00468269 (W 0.00433711) | 0.095137 ± 0.00473354 (W 0.00220631) | 0.090448 ± 0.000493889 (W 0.00043839) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.350847 ± 0.00225869 (W 0.028049) | 0.381364 ± 0.0200974 (W 0.0301363) | 0.195343 ± 0.0026937 (W 0.00545512) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.07564 ± 0.014782 (W 0.0292354) | 1.18661 ± 0.0403952 (W 0.0211068) | 0.969786 ± 0.0107724 (W 0.0177428) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.40268 ± 0.0113649 (W 0.0262862) | 2.32804 ± 0.00836574 (W 0.0163631) | 0.991276 ± 0.00737548 (W 0.00316477) | · | 🔴 faer-fork 2.42× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.8827 ± 0.0227284 (W 0.0363126) | 7.02256 ± 0.0130836 (W 0.0352558) | 3.90651 ± 0.0235707 (W 0.00724418) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.8257 ± 0.0886383 (W 0.0765754) | 24.4772 ± 0.0990995 (W 0.0695802) | 14.7651 ± 1.24537 (W 0.0504437) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.289392 ± 0.00166839 (W 0.00201751) | 0.288661 ± 0.00226848 (W 0.00239194) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6121 ± 0.00849776 (W 0.00662214) | 2.61036 ± 0.00371836 (W 0.00560084) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.5958 ± 0.0659626 (W 0.0517922) | 16.7456 ± 0.0257098 (W 0.129409) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.068367 ± 0.0013089 (W 0.00102999) | 0.10215 ± 0.000338466 (W 0.00179103) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.068707 ± 0.00023087 (W 0.00149669) | 0.103654 ± 0.000377916 (W 0.00163565) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.296422 ± 0.00151723 (W 0.00225607) | 0.393787 ± 0.0086494 (W 0.137561) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.301441 ± 0.00350846 (W 0.00224181) | 0.385051 ± 0.00818395 (W 0.0167676) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.24547 ± 0.0111208 (W 0.0145836) | 2.652 ± 0.146271 (W 0.24914) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.24126 ± 0.00262801 (W 0.00853583) | 2.64095 ± 0.0463801 (W 0.136158) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146904 ± 0.00041149 (W 0.00161912) | 0.226913 ± 0.0236873 (W 0.00736519) | 0.132447 ± 0.00042548 (W 0.00108991) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.711836 ± 0.12369 (W 0.00272758) | 0.91804 ± 0.114807 (W 0.0170824) | 0.31815 ± 0.00175397 (W 0.00372662) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 2.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.12126 ± 0.0213791 (W 0.0576265) | 4.73287 ± 0.0341855 (W 0.0652483) | 1.21799 ± 0.0148373 (W 0.00504441) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 3.38× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.561523 ± 0.0094918 (W 0.0197939) | 1.88732 ± 0.0291206 (W 0.0166968) | 0.411911 ± 0.00824674 (W 0.0239914) | 🔵 faer-fork 3.36× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.7003 ± 0.0172996 (W 0.0141073) | 4.65085 ± 0.0494835 (W 0.0538805) | 2.03956 ± 0.0327435 (W 0.00606821) | 🔵 faer-fork 2.74× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 8.24826 ± 0.0289239 (W 0.0234164) | 14.8507 ± 0.0403189 (W 0.142092) | 10.297 ± 0.110767 (W 0.0164974) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.331327 ± 0.00271489 (W 0.00599889) | 1.59808 ± 0.0353722 (W 0.028256) | 0.144369 ± 0.000721977 (W 0.00186175) | 🔵 faer-fork 4.82× faster than `faer-upstream` | 🔴 faer-fork 2.30× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.29495 ± 0.0028036 (W 0.0101391) | 4.00225 ± 0.0578476 (W 0.0418028) | 0.542249 ± 0.0021922 (W 0.00234192) | 🔵 faer-fork 3.09× faster than `faer-upstream` | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.49514 ± 0.00854021 (W 0.0269374) | 10.131 ± 0.057365 (W 0.0719202) | 2.20222 ± 0.00643444 (W 0.00419522) | 🔵 faer-fork 2.25× faster than `faer-upstream` | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.113824 ± 0.000814676 (W 0.00150788) | 0.189856 ± 0.0028513 (W 0.00513653) | 0.131323 ± 0.000385903 (W 0.00148355) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.684182 ± 0.000805903 (W 0.0022087) | 0.810909 ± 0.0103696 (W 0.0255602) | 0.299291 ± 0.00210047 (W 0.00220311) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.29× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.13475 ± 0.0219091 (W 0.0322906) | 4.52138 ± 0.0339398 (W 0.0487478) | 1.19055 ± 0.0102108 (W 0.00445059) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 3.47× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01914 ± 0.00698114 (W 0.0143434) | 3.08215 ± 0.019664 (W 0.0164728) | 2.47884 ± 0.00734995 (W 0.00380281) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3751 ± 0.0865524 (W 0.0521584) | 13.6305 ± 0.0709606 (W 0.0418964) | 11.3807 ± 0.0187704 (W 0.0276425) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.1817 ± 0.169398 (W 0.402009) | 59.8348 ± 0.180286 (W 0.349237) | 47.6604 ± 0.403566 (W 0.0878948) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.21529 ± 0.0313269 (W 0.00226423) | 2.16115 ± 0.0398349 (W 0.00553502) | 1.11444 ± 0.00215604 (W 0.00309059) | · | 🔴 faer-fork 1.99× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.7982 ± 0.0683954 (W 0.0216846) | 10.7814 ± 0.0170892 (W 0.048441) | 6.00094 ± 0.0128808 (W 0.00787182) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.2597 ± 0.24573 (W 0.455949) | 48.2213 ± 0.404332 (W 0.368695) | 22.411 ± 0.0748405 (W 0.0394287) | · | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.005049 ± 0.000301209 (W 1.63156e-05) | 0.004218 ± 0.000223361 (W 2.04524e-05) | - | 🔴 faer-fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011822 ± 0.00124771 (W 5.86362e-05) | 0.011121 ± 0.00131158 (W 5.83455e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044644 ± 0.000238875 (W 0.000500067) | 0.044012 ± 0.000772382 (W 0.000760587) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.185174 ± 0.000178832 (W 0.00187848) | 0.187042 ± 0.000306959 (W 0.0021838) | 0.476738 ± 0.00187848 (W 0.00370605) | · | 🔵 faer-fork 2.57× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.21791 ± 0.00242057 (W 0.00271384) | 1.22202 ± 0.0114161 (W 0.0031004) | 1.85275 ± 0.0229906 (W 0.00746801) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.94293 ± 0.0233826 (W 0.012781) | 7.91125 ± 0.00821814 (W 0.0197919) | 11.3797 ± 0.022833 (W 0.0215949) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.27473 ± 0.00217333 (W 0.00463807) | 3.27881 ± 0.0070623 (W 0.00649411) | 4.42018 ± 0.00917881 (W 0.0107658) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.4442 ± 0.0180196 (W 0.0195403) | 17.4274 ± 0.0359675 (W 0.0115496) | 26.4441 ± 0.0306074 (W 0.0409348) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.948 ± 0.211734 (W 0.0469832) | 105.941 ± 0.208379 (W 0.0616676) | 171.186 ± 0.0986451 (W 0.470461) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.776313 ± 0.0041497 (W 0.00360505) | 0.779973 ± 0.00586215 (W 0.00532721) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.9359 ± 0.0639257 (W 0.0124167) | 6.04223 ± 0.0186318 (W 0.0113485) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.7107 ± 0.292129 (W 0.0260595) | 41.0769 ± 0.295246 (W 0.0476894) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.04964 ± 0.000307516 (W 0.00358914) | 1.04698 ± 0.00417111 (W 0.000700319) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05478 ± 0.000897169 (W 0.00099144) | 1.05299 ± 0.00477402 (W 0.00287126) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49777 ± 0.00977672 (W 0.0137034) | 7.51364 ± 0.0157446 (W 0.0115318) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.53062 ± 0.0148875 (W 0.00582055) | 7.50294 ± 0.0175412 (W 0.00864992) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9787 ± 0.0772646 (W 0.0164234) | 56.8736 ± 0.0131755 (W 0.0354161) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.9716 ± 0.0392681 (W 0.0424876) | 57.0148 ± 0.0488405 (W 0.0306975) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.326846 ± 0.00195638 (W 0.00237216) | 0.330533 ± 0.000619137 (W 0.00241517) | 0.504424 ± 0.0014177 (W 0.00248946) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.11588 ± 0.00141869 (W 0.00282066) | 2.21596 ± 0.00552615 (W 0.0045144) | 3.31532 ± 0.010659 (W 0.0119696) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 14.7698 ± 0.086418 (W 0.043764) | 14.9641 ± 0.0314397 (W 0.0134107) | 21.1411 ± 0.0556198 (W 0.0515275) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.57466 ± 0.000564737 (W 0.00345793) | 1.58147 ± 0.00142048 (W 0.00280434) | 1.99589 ± 0.00142954 (W 0.00361618) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.1871 ± 0.0158191 (W 0.011412) | 10.3242 ± 0.00846226 (W 0.0107883) | 12.376 ± 0.0184321 (W 0.0239045) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.7732 ± 0.0520739 (W 0.0437653) | 69.9536 ± 0.160964 (W 0.0784999) | 80.7904 ± 0.0525934 (W 0.0678728) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.810597 ± 0.00459988 (W 0.00220712) | 1.06374 ± 0.00283684 (W 0.00205866) | 0.95631 ± 0.000503247 (W 0.0033906) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.8144 ± 0.0266071 (W 0.0031175) | 6.41174 ± 0.00846431 (W 0.0095962) | 5.68452 ± 0.0276763 (W 0.0165714) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.6388 ± 0.0265737 (W 0.0298419) | 37.5873 ± 0.192289 (W 0.0185038) | 39.0316 ± 0.0416549 (W 0.0416414) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.322377 ± 0.000190917 (W 0.00267902) | 0.33282 ± 0.000982792 (W 0.00178859) | 0.490674 ± 0.00116268 (W 0.00240794) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.05742 ± 0.000380198 (W 0.00334574) | 2.15085 ± 0.00157102 (W 0.00873283) | 2.82828 ± 0.00863655 (W 0.0115879) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.7181 ± 0.0379407 (W 0.0205438) | 14.8798 ± 0.0280371 (W 0.0182299) | 18.8215 ± 0.0362263 (W 0.0350354) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.75003 ± 0.0128698 (W 0.00836725) | 5.73813 ± 0.0102839 (W 0.00649582) | 7.05639 ± 0.00567395 (W 0.00624474) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.1587 ± 0.0891573 (W 0.0546924) | 34.149 ± 0.173674 (W 0.0270776) | 43.4147 ± 0.338356 (W 0.059537) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 210.555 ± 0.604692 (W 0.292989) | 210.683 ± 0.378082 (W 0.491429) | 276.585 ± 0.725428 (W 0.930116) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.47087 ± 0.0119438 (W 0.0100938) | 3.46648 ± 0.00895335 (W 0.00492888) | 2.75658 ± 0.0095689 (W 0.00601963) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.2993 ± 0.0418242 (W 0.0190964) | 19.3061 ± 0.0634234 (W 0.0213344) | 18.1931 ± 0.0282506 (W 0.019515) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 110.395 ± 0.2393 (W 0.0467632) | 110.531 ± 0.224061 (W 0.0392672) | 122.808 ± 0.492611 (W 0.068749) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008175 ± 7e-05 (W 5.82349e-05) | 0.007594 ± 3.55012e-05 (W 4.55445e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025107 ± 0.000194054 (W 0.000145705) | 0.023815 ± 7.97517e-05 (W 0.0013906) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.087282 ± 0.000313009 (W 0.00033259) | 0.084959 ± 0.000407308 (W 0.00155073) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.186607 ± 0.000533845 (W 0.00188585) | 0.201448 ± 0.00159518 (W 0.00559307) | 0.478572 ± 0.00437591 (W 0.00269324) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 2.56× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.83275 ± 0.00332731 (W 0.0107732) | 0.870473 ± 0.00159173 (W 0.0121855) | 0.802194 ± 0.00412877 (W 0.00890785) | · | · |  |
| `cholesky/n512/b1` | 3.34909 ± 0.0131739 (W 0.0229724) | 3.41518 ± 0.00080835 (W 0.0180598) | 3.64676 ± 0.00585816 (W 0.0128959) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.00343 ± 0.0184776 (W 0.0127983) | 2.97585 ± 0.0361312 (W 0.0253315) | 2.0484 ± 0.00466701 (W 0.00549009) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.4903 ± 0.0413958 (W 0.0505811) | 11.4815 ± 0.0374437 (W 0.0434771) | 10.1556 ± 0.0186628 (W 0.00898481) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.6552 ± 0.0933692 (W 0.0799254) | 46.6046 ± 0.0613645 (W 0.13425) | 53.1015 ± 0.12883 (W 0.0376402) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.769083 ± 0.00257032 (W 0.00651841) | 0.769824 ± 0.00193309 (W 0.00753646) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.87959 ± 0.011603 (W 0.0166328) | 6.02632 ± 0.0231884 (W 0.00944398) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.928 ± 0.109999 (W 0.0904232) | 27.1357 ± 0.0687767 (W 0.0774819) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.28785 ± 0.00206935 (W 0.00106845) | 0.289117 ± 0.00272384 (W 0.00160684) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.291882 ± 0.00097784 (W 0.00250468) | 0.288029 ± 0.00234408 (W 0.00244563) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93094 ± 0.00973382 (W 0.00677352) | 1.93103 ± 0.00271615 (W 0.00254013) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93269 ± 0.0088714 (W 0.00672797) | 1.92907 ± 0.0119498 (W 0.00370704) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7346 ± 0.0012822 (W 0.0303496) | 14.6807 ± 0.0458856 (W 0.00636208) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.7685 ± 0.0222374 (W 0.020199) | 14.6958 ± 0.0466874 (W 0.0192574) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.325396 ± 0.00223689 (W 0.00333629) | 0.350959 ± 0.0078303 (W 0.0056165) | 0.481133 ± 0.00080724 (W 0.00193817) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.51552 ± 0.00124013 (W 0.0153933) | 1.69369 ± 0.0127559 (W 0.0292942) | 1.01693 ± 0.00241755 (W 0.00221837) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 7.24693 ± 0.0130349 (W 0.0155639) | 7.48577 ± 0.0231079 (W 0.026459) | 6.12302 ± 0.0297184 (W 0.0113984) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.03123 ± 0.0115773 (W 0.014155) | 1.9405 ± 0.0264601 (W 0.0232099) | 1.03981 ± 0.00404635 (W 0.00342599) | 🔵 faer-fork 1.88× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.60798 ± 0.0215735 (W 0.0310289) | 6.23142 ± 0.0785124 (W 0.0396898) | 4.82362 ± 0.0196953 (W 0.01231) | 🔵 faer-fork 1.35× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 23.3296 ± 0.0799984 (W 0.0673621) | 26.7492 ± 0.0539111 (W 0.0838656) | 28.5544 ± 0.138279 (W 0.047209) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.607227 ± 0.00253389 (W 0.00252407) | 1.81558 ± 0.00570373 (W 0.0208579) | 0.455795 ± 0.000827951 (W 0.00236371) | 🔵 faer-fork 2.99× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.93051 ± 0.0205948 (W 0.0273859) | 7.29867 ± 0.0769543 (W 0.036767) | 1.64093 ± 0.00474829 (W 0.00510949) | 🔵 faer-fork 2.49× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.0102 ± 0.0646256 (W 0.0849598) | 26.2238 ± 0.55036 (W 0.355839) | 11.4388 ± 0.00751187 (W 0.00870105) | 🔵 faer-fork 2.18× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.324312 ± 0.00245323 (W 0.00246713) | 0.340773 ± 0.00370052 (W 0.00441813) | 0.468433 ± 0.00257737 (W 0.00267629) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.39949 ± 0.00882166 (W 0.0141857) | 1.57596 ± 0.0101707 (W 0.0184859) | 0.900359 ± 0.00426506 (W 0.00483639) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 7.16328 ± 0.0189249 (W 0.0422404) | 7.34364 ± 0.00783022 (W 0.0240037) | 5.64926 ± 0.0072698 (W 0.0106156) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.34527 ± 0.0234608 (W 0.0223335) | 4.33788 ± 0.0237357 (W 0.0253464) | 4.15681 ± 0.00699502 (W 0.00672982) | · | · |  |
| `svd_thin/n256/b1` | 22.5925 ± 0.0501353 (W 0.0718048) | 22.5271 ± 0.0662765 (W 0.0775398) | 21.1716 ± 0.0603136 (W 0.0273136) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.8011 ± 0.1367 (W 0.297684) | 95.1174 ± 0.328782 (W 0.208605) | 114.208 ± 0.395052 (W 0.12961) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.0612 ± 0.0333106 (W 0.00634405) | 3.04431 ± 0.00667097 (W 0.00736777) | 2.0245 ± 0.0182618 (W 0.00230724) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.1238 ± 0.0349805 (W 0.076801) | 17.1254 ± 0.0560094 (W 0.102899) | 11.0367 ± 0.0142413 (W 0.0107101) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 64.9504 ± 0.254281 (W 0.217476) | 65.086 ± 0.0989778 (W 0.336278) | 55.7816 ± 0.129795 (W 0.0703453) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008165 ± 4.58258e-05 (W 3.1469e-05) | 0.007594 ± 2.64575e-05 (W 3.1305e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024625 ± 0.000295794 (W 0.000153981) | 0.023434 ± 8.5967e-05 (W 5.82683e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.070692 ± 0.00070865 (W 0.000787966) | 0.068258 ± 0.000363988 (W 0.000707273) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.19366 ± 0.00214349 (W 0.00328042) | 0.212135 ± 0.0019407 (W 0.00238072) | 0.479327 ± 0.00293752 (W 0.0037022) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 2.48× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.808112 ± 0.0172817 (W 0.0147363) | 0.878144 ± 0.0126572 (W 0.0142768) | 0.657762 ± 0.00165762 (W 0.0038814) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.75289 ± 0.0137049 (W 0.0155393) | 2.84973 ± 0.0182275 (W 0.0273033) | 2.27607 ± 0.0548724 (W 0.00771475) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.92827 ± 0.0270401 (W 0.0288628) | 3.00324 ± 0.00745311 (W 0.0106474) | 1.70287 ± 0.00478307 (W 0.00517032) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.8297 ± 0.00630635 (W 0.0329891) | 11.1699 ± 0.0417062 (W 0.0319705) | 8.02635 ± 0.0172633 (W 0.00807305) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 39.1151 ± 0.162652 (W 0.0981391) | 40.1754 ± 0.075659 (W 0.126159) | 36.9738 ± 0.0379211 (W 0.0183472) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.770394 ± 0.00165403 (W 0.00615811) | 0.776866 ± 0.00332114 (W 0.00570166) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.86746 ± 0.00523709 (W 0.0132761) | 6.01384 ± 0.00635477 (W 0.00954064) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.3207 ± 0.0216708 (W 0.0617438) | 25.3957 ± 0.1277 (W 0.0863492) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.18283 ± 0.00154661 (W 0.00129268) | 0.270392 ± 0.00092025 (W 0.00159695) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.184515 ± 0.00104202 (W 0.00108106) | 0.271475 ± 0.00193069 (W 0.00182771) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01148 ± 0.00160159 (W 0.00472803) | 1.29387 ± 0.0156706 (W 0.0763448) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01294 ± 0.00474447 (W 0.0046783) | 1.28461 ± 0.0235473 (W 0.0768131) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.08901 ± 0.0398868 (W 0.0635619) | 8.91672 ± 0.0822645 (W 0.566848) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.10637 ± 0.0258223 (W 0.0531557) | 8.82192 ± 0.0519061 (W 0.483446) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.329387 ± 0.00183851 (W 0.00222646) | 0.369698 ± 0.00385581 (W 0.00661672) | 0.485622 ± 0.00266985 (W 0.00293344) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.47099 ± 0.0131784 (W 0.0198714) | 1.68851 ± 0.00501807 (W 0.0157142) | 0.693087 ± 0.00320722 (W 0.00518674) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.11461 ± 0.0194255 (W 0.0311502) | 6.47561 ± 0.0168718 (W 0.0216656) | 3.59608 ± 0.00705369 (W 0.00908652) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.991192 ± 0.0101986 (W 0.00719385) | 2.47522 ± 0.0267417 (W 0.0616334) | 0.782726 ± 0.0028724 (W 0.0047131) | 🔵 faer-fork 2.50× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.44223 ± 0.0230649 (W 0.0201254) | 6.98906 ± 0.0384508 (W 0.0661993) | 3.83723 ± 0.00807209 (W 0.00909006) | 🔵 faer-fork 2.03× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 15.9751 ± 0.0147841 (W 0.0426679) | 23.3166 ± 0.274689 (W 0.302258) | 16.0494 ± 0.0246226 (W 0.0134787) | 🔵 faer-fork 1.46× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.615645 ± 0.00341101 (W 0.00574579) | 2.30871 ± 0.0361801 (W 0.0311388) | 0.323162 ± 0.00131086 (W 0.0036956) | 🔵 faer-fork 3.75× faster than `faer-upstream` | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.43638 ± 0.00765533 (W 0.0195883) | 8.55263 ± 0.0162749 (W 0.0358691) | 1.62675 ± 0.0032488 (W 0.00241221) | 🔵 faer-fork 3.51× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.31935 ± 0.0325272 (W 0.0311118) | 27.5545 ± 0.131194 (W 0.188524) | 5.82107 ± 0.015499 (W 0.00893974) | 🔵 faer-fork 2.96× faster than `faer-upstream` | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.324082 ± 0.000990049 (W 0.00197069) | 0.361593 ± 0.0045369 (W 0.0082476) | 0.471066 ± 0.00259991 (W 0.00270014) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.33751 ± 0.0035606 (W 0.0207965) | 1.5677 ± 0.0243877 (W 0.0308972) | 0.665528 ± 0.00101021 (W 0.00457846) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 2.01× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.9912 ± 0.0102034 (W 0.0198042) | 6.25349 ± 0.00190009 (W 0.0340343) | 3.45055 ± 0.014234 (W 0.00863161) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.24921 ± 0.0183609 (W 0.0187535) | 4.48657 ± 0.00998987 (W 0.0200985) | 3.65539 ± 0.00881342 (W 0.00689186) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.5235 ± 0.153351 (W 0.0755203) | 22.1109 ± 0.381659 (W 0.0818158) | 17.2686 ± 0.0513128 (W 0.0248486) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.3965 ± 0.250649 (W 0.214566) | 82.0429 ± 0.196453 (W 0.186028) | 84.3849 ± 0.161935 (W 0.0617239) | · | · |  |
| `svd_values/n128/b1` | 3.05136 ± 0.0272704 (W 0.0176832) | 3.08281 ± 0.0188124 (W 0.00747057) | 1.91496 ± 0.00618625 (W 0.0048393) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.1224 ± 0.135775 (W 0.0307084) | 17.1245 ± 0.098329 (W 0.0341672) | 9.63442 ± 0.0399094 (W 0.0185602) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 61.6248 ± 0.156897 (W 0.223618) | 61.6601 ± 0.267803 (W 0.169363) | 42.9572 ± 0.170013 (W 0.0379787) | · | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008206 ± 2.70247e-05 (W 3.45297e-05) | 0.007584 ± 3.05505e-05 (W 3.83406e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024786 ± 0.000176069 (W 7.64853e-05) | 0.023363 ± 0.000819064 (W 9.0351e-05) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.072906 ± 0.00117712 (W 0.00165828) | 0.076793 ± 0.0043406 (W 0.00295628) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.172736 ± 0.000278095 (W 0.00158645) | 0.174196 ± 0.000335077 (W 0.00159448) | 0.410017 ± 0.000209724 (W 0.00221938) | · | 🔵 faer-fork 2.37× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13198 ± 0.00102643 (W 0.00188809) | 1.13142 ± 0.00446727 (W 0.00143938) | 1.60112 ± 0.00274877 (W 0.00564786) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.54376 ± 0.0192281 (W 0.00722774) | 7.5372 ± 0.00244584 (W 0.0147949) | 12.0779 ± 0.012113 (W 0.0253237) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.26379 ± 0.00282679 (W 0.00215184) | 3.26662 ± 0.00957595 (W 0.00554627) | 4.3666 ± 0.00764118 (W 0.0114098) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.3802 ± 0.0187072 (W 0.0146687) | 17.3315 ± 0.0184308 (W 0.0137264) | 26.1589 ± 0.0180299 (W 0.0366082) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.509 ± 0.278258 (W 0.0460375) | 105.638 ± 0.0870877 (W 0.0369999) | 170.152 ± 0.183992 (W 0.287492) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.74818 ± 0.00178793 (W 0.00668321) | 0.751285 ± 0.00812696 (W 0.00282995) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.80313 ± 0.0637422 (W 0.0136616) | 5.78394 ± 0.0305322 (W 0.00591602) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.029 ± 0.27174 (W 0.044366) | 40.0132 ± 0.187645 (W 0.0235344) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03923 ± 0.000694997 (W 0.00103202) | 1.03811 ± 0.00426145 (W 0.00122238) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04153 ± 0.00453131 (W 0.000664075) | 1.04156 ± 0.00166938 (W 0.000482934) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.40903 ± 0.0132219 (W 0.0114492) | 7.40212 ± 0.0140826 (W 0.00892146) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.42117 ± 0.00818325 (W 0.00782509) | 7.4167 ± 0.00911159 (W 0.0108864) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.775 ± 0.0356224 (W 0.0304598) | 56.6959 ± 0.0848523 (W 0.0426435) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.8098 ± 0.0517415 (W 0.0587203) | 56.7025 ± 0.0543707 (W 0.0532785) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.298105 ± 0.00157973 (W 0.00244186) | 0.298252 ± 0.00118572 (W 0.00312201) | 0.460532 ± 0.00165171 (W 0.00227101) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.00451 ± 0.00626417 (W 0.00289073) | 2.01531 ± 0.0100291 (W 0.00577983) | 3.15766 ± 0.00959482 (W 0.00856712) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 13.9322 ± 0.0140526 (W 0.0237182) | 13.9187 ± 0.0335648 (W 0.0203835) | 19.7842 ± 0.0131199 (W 0.0441165) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.5493 ± 0.00215293 (W 0.00237558) | 1.55216 ± 0.00399838 (W 0.00264428) | 1.97576 ± 0.0039139 (W 0.00508084) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.0754 ± 0.0314593 (W 0.00873157) | 10.1278 ± 0.0171263 (W 0.010966) | 12.344 ± 0.0119088 (W 0.0182067) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.006 ± 0.0877606 (W 0.0411399) | 69.0401 ± 0.0795264 (W 0.0250881) | 79.8642 ± 0.0330007 (W 0.0515372) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.741988 ± 0.00170771 (W 0.00144503) | 0.747392 ± 0.000423142 (W 0.00172783) | 0.909564 ± 0.00177183 (W 0.00195489) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.46181 ± 0.00642009 (W 0.00519879) | 4.49188 ± 0.0203604 (W 0.00404116) | 5.51081 ± 0.003534 (W 0.0131917) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.9754 ± 0.0446002 (W 0.0213572) | 29.0873 ± 0.0176366 (W 0.0153352) | 37.9267 ± 0.0198367 (W 0.0275864) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.296214 ± 0.00141873 (W 0.00226577) | 0.297745 ± 0.00350162 (W 0.00238223) | 0.444378 ± 0.00175157 (W 0.00292582) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.94847 ± 0.0101818 (W 0.00305763) | 1.94428 ± 0.00143131 (W 0.00515446) | 2.6609 ± 0.00183278 (W 0.00769442) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 13.9221 ± 0.0454338 (W 0.0188794) | 13.8898 ± 0.023202 (W 0.0214214) | 18.0307 ± 0.0144262 (W 0.0271969) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.71876 ± 0.0102001 (W 0.00890342) | 5.70938 ± 0.00331746 (W 0.00532363) | 6.96192 ± 0.0076624 (W 0.00936532) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.8114 ± 0.113369 (W 0.0373075) | 33.851 ± 0.102106 (W 0.0384631) | 43.1885 ± 0.133504 (W 0.273954) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 209.533 ± 0.3924 (W 0.503325) | 209.304 ± 0.522318 (W 0.367237) | 305.258 ± 1.39425 (W 0.728241) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.45661 ± 0.011317 (W 0.00466826) | 3.45669 ± 0.00819086 (W 0.00403871) | 2.70855 ± 0.00593608 (W 0.00437607) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.0213 ± 0.0380411 (W 0.0218786) | 19.0083 ± 0.0627121 (W 0.0175336) | 17.9525 ± 0.0312166 (W 0.0287145) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 109.477 ± 0.239409 (W 0.380085) | 109.409 ± 0.28456 (W 0.428582) | 150.172 ± 0.800893 (W 0.325947) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008135 ± 0.000593753 (W 4.0598e-05) | 0.007864 ± 0.000596958 (W 2.47649e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024846 ± 0.001536 (W 0.000112202) | 0.024025 ± 0.00167981 (W 6.76018e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.08631 ± 0.00253574 (W 0.00110102) | 0.085429 ± 0.00295245 (W 0.00163396) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.174785 ± 0.00159112 (W 0.00282005) | 0.188652 ± 0.00210409 (W 0.00655472) | 0.407033 ± 0.000905588 (W 0.00183242) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 2.33× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.741611 ± 0.00092225 (W 0.00969221) | 0.770585 ± 0.00944423 (W 0.00863574) | 0.593243 ± 0.00435771 (W 0.00796363) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.97804 ± 0.0344377 (W 0.0137137) | 3.05842 ± 0.00594537 (W 0.0278889) | 3.2409 ± 0.0192854 (W 0.0219836) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.9684 ± 0.0317234 (W 0.0213991) | 2.96893 ± 0.0144739 (W 0.0176976) | 2.00365 ± 0.00542457 (W 0.00375345) | · | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.3864 ± 0.0128364 (W 0.0435799) | 11.3636 ± 0.0371334 (W 0.0415801) | 10.0076 ± 0.0243435 (W 0.0128699) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.2812 ± 0.169532 (W 0.130352) | 46.2937 ± 0.0841956 (W 0.101539) | 52.5508 ± 0.109848 (W 0.376288) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.739867 ± 0.00668051 (W 0.0058533) | 0.743495 ± 0.00291503 (W 0.00419077) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74292 ± 0.012957 (W 0.0136886) | 5.73251 ± 0.0129882 (W 0.0115442) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.1867 ± 0.0239494 (W 0.07303) | 26.1856 ± 0.0620248 (W 0.158386) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.296421 ± 0.00060713 (W 0.0044503) | 0.286013 ± 0.000653973 (W 0.000868244) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.299016 ± 0.00115586 (W 0.00290624) | 0.289703 ± 0.00342505 (W 0.00240212) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92202 ± 0.0065467 (W 0.00279243) | 1.91953 ± 0.00230463 (W 0.00182711) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92162 ± 0.00331125 (W 0.00448527) | 1.91874 ± 0.00259228 (W 0.00475339) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7743 ± 0.0237735 (W 0.0175919) | 14.7294 ± 0.058981 (W 0.0275267) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.781 ± 0.0548836 (W 0.0273537) | 14.6815 ± 0.0564233 (W 0.039574) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.300233 ± 0.00382673 (W 0.00246496) | 0.318423 ± 0.00248935 (W 0.00586643) | 0.457418 ± 0.000842824 (W 0.00221933) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.41752 ± 0.00478838 (W 0.0183052) | 1.48618 ± 0.018723 (W 0.0238139) | 0.978806 ± 0.00183907 (W 0.00384011) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.44682 ± 0.0204214 (W 0.0286556) | 6.5586 ± 0.029892 (W 0.0385786) | 5.79344 ± 0.013226 (W 0.0142237) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.00331 ± 0.0435535 (W 0.0053929) | 1.91578 ± 0.0185396 (W 0.0137512) | 1.05963 ± 0.00608282 (W 0.0026504) | 🔵 faer-fork 1.91× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 4.44971 ± 0.00584228 (W 0.0261843) | 6.00763 ± 0.0662568 (W 0.0506) | 5.01958 ± 0.00534395 (W 0.00927197) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 22.4766 ± 0.0532408 (W 0.106073) | 26.0001 ± 0.0492407 (W 0.0761597) | 29.1166 ± 0.0920136 (W 0.110268) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.559213 ± 0.00693751 (W 0.00733783) | 1.43348 ± 0.0295354 (W 0.00964948) | 0.438615 ± 0.00187115 (W 0.00187218) | 🔵 faer-fork 2.56× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.76391 ± 0.0131279 (W 0.0233562) | 4.35562 ± 0.033552 (W 0.052444) | 1.57794 ± 0.00290639 (W 0.00333395) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.31 ± 0.016976 (W 0.0462714) | 14.8258 ± 0.0335523 (W 0.0525277) | 11.0385 ± 0.0189087 (W 0.0191316) | 🔵 faer-fork 1.31× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.299786 ± 0.00369021 (W 0.00281968) | 0.312263 ± 0.00405897 (W 0.00827136) | 0.445315 ± 0.00104408 (W 0.00274973) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.29124 ± 0.00892491 (W 0.00830378) | 1.35627 ± 0.00780785 (W 0.0142172) | 0.860764 ± 0.00474645 (W 0.00377562) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.35197 ± 0.00729018 (W 0.0245434) | 6.40878 ± 0.0168104 (W 0.0268284) | 5.34837 ± 0.0343607 (W 0.0140968) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.32242 ± 0.0127801 (W 0.0120575) | 4.31874 ± 0.00588675 (W 0.0235742) | 4.10491 ± 0.00166488 (W 0.00556201) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.2968 ± 0.133411 (W 0.106532) | 22.206 ± 0.10323 (W 0.122263) | 21.0857 ± 0.0261497 (W 0.0440378) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 93.8841 ± 0.200234 (W 0.291238) | 94.0192 ± 0.268976 (W 0.242161) | 112.457 ± 1.26546 (W 0.379063) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.01813 ± 0.0377714 (W 0.00605419) | 3.01882 ± 0.0161628 (W 0.00622799) | 2.0152 ± 0.00156969 (W 0.00362762) | · | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.8912 ± 0.0164367 (W 0.0678855) | 16.8866 ± 0.0133384 (W 0.0535307) | 11.0129 ± 0.0301891 (W 0.0108633) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 64.1156 ± 0.157888 (W 0.269716) | 64.1104 ± 0.169691 (W 0.27032) | 55.6161 ± 0.398477 (W 0.0502667) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008015 ± 0.000499691 (W 3.31391e-05) | 0.007754 ± 0.000502581 (W 3.01529e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.02116 ± 0.00329612 (W 9.94349e-05) | 0.020669 ± 0.00225321 (W 4.62731e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.07531 ± 0.00457159 (W 0.00324972) | 0.072736 ± 0.00565267 (W 0.00176755) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.179443 ± 0.00145351 (W 0.00112776) | 0.200092 ± 0.000259797 (W 0.00317955) | 0.407422 ± 0.00164859 (W 0.00279381) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 2.27× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.719065 ± 0.00581834 (W 0.022502) | 0.786532 ± 0.00294678 (W 0.0134129) | 0.463773 ± 0.000565951 (W 0.00237434) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.37775 ± 0.0223973 (W 0.0114349) | 2.51612 ± 0.0128179 (W 0.0195407) | 1.87434 ± 0.0125796 (W 0.0147796) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.93671 ± 0.0369908 (W 0.031359) | 3.00266 ± 0.00675712 (W 0.0172033) | 1.66087 ± 0.00663341 (W 0.00490687) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7893 ± 0.0370068 (W 0.0269841) | 11.1242 ± 0.0247666 (W 0.0232272) | 7.8805 ± 0.0156178 (W 0.00955563) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.8109 ± 0.185221 (W 0.0804602) | 39.7155 ± 0.13318 (W 0.110294) | 36.5493 ± 0.0294196 (W 0.0289231) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.747619 ± 0.00193717 (W 0.00459069) | 0.748934 ± 0.0071995 (W 0.00550131) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.73996 ± 0.00164062 (W 0.0175903) | 5.73916 ± 0.0143321 (W 0.0122322) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.5282 ± 0.068961 (W 0.100151) | 24.429 ± 0.142459 (W 0.102787) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.195133 ± 0.00167071 (W 0.000841622) | 0.276687 ± 0.00122876 (W 0.00142851) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.194613 ± 0.0291187 (W 0.00757107) | 0.277468 ± 0.00129757 (W 0.00225026) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.02105 ± 0.0012845 (W 0.0043045) | 1.28489 ± 0.0119379 (W 0.0602869) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.02382 ± 0.00175415 (W 0.00621401) | 1.28111 ± 0.0114419 (W 0.0149597) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.28319 ± 0.0359586 (W 0.0274539) | 8.77162 ± 0.541782 (W 0.378485) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.2215 ± 0.026339 (W 0.0307596) | 8.81686 ± 0.703641 (W 0.517886) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.30164 ± 0.003933 (W 0.00377346) | 0.336961 ± 0.0039405 (W 0.00532707) | 0.457301 ± 0.00143254 (W 0.0033927) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.35045 ± 0.014581 (W 0.00991827) | 1.49146 ± 0.00634591 (W 0.0184711) | 0.68344 ± 0.00332298 (W 0.00594734) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.98× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 5.32992 ± 0.00490275 (W 0.0272529) | 5.57307 ± 0.00653251 (W 0.0461704) | 3.47213 ± 0.0113888 (W 0.0061534) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.954345 ± 0.00621507 (W 0.00850896) | 2.42658 ± 0.0231949 (W 0.0231473) | 0.796019 ± 0.00528033 (W 0.00502997) | 🔵 faer-fork 2.54× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.32122 ± 0.0261063 (W 0.0351234) | 6.74377 ± 0.0472089 (W 0.0327144) | 4.0738 ± 0.0564234 (W 0.00665853) | 🔵 faer-fork 2.03× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 15.0863 ± 0.0280595 (W 0.0463839) | 22.2663 ± 0.147481 (W 0.199595) | 17.0366 ± 0.0213873 (W 0.022969) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.563607 ± 0.00236766 (W 0.0038021) | 1.86836 ± 0.0188257 (W 0.0302472) | 0.306831 ± 0.000623881 (W 0.00188507) | 🔵 faer-fork 3.32× faster than `faer-upstream` | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.28333 ± 0.00836616 (W 0.0217125) | 5.38006 ± 0.0127347 (W 0.0476139) | 1.58343 ± 0.00182724 (W 0.00272958) | 🔵 faer-fork 2.36× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.72653 ± 0.00760161 (W 0.0165115) | 14.829 ± 0.0858167 (W 0.170016) | 5.63414 ± 0.00704894 (W 0.00936429) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.298836 ± 0.00177765 (W 0.00376139) | 0.325836 ± 0.00195788 (W 0.0075013) | 0.444365 ± 0.00142969 (W 0.00287414) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.22628 ± 0.00924176 (W 0.0164017) | 1.33681 ± 0.0060963 (W 0.0250849) | 0.643245 ± 0.00529687 (W 0.00540884) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.15852 ± 0.00821652 (W 0.0175357) | 5.38166 ± 0.0348605 (W 0.0417024) | 3.30864 ± 0.0176482 (W 0.00796615) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.24984 ± 0.0224576 (W 0.0172836) | 4.47382 ± 0.00798663 (W 0.0246446) | 3.60311 ± 0.00508049 (W 0.0100151) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.2384 ± 0.27368 (W 0.072454) | 21.8176 ± 0.138753 (W 0.08625) | 17.0874 ± 0.0373529 (W 0.0280105) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 79.3577 ± 0.20334 (W 0.204665) | 81.1401 ± 0.343838 (W 0.377859) | 81.983 ± 0.988377 (W 0.0630755) | · | · |  |
| `svd_values/n128/b1` | 3.01598 ± 0.0307054 (W 0.00405562) | 3.01769 ± 0.027049 (W 0.00732385) | 1.90834 ± 0.00452354 (W 0.0053032) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.8862 ± 0.111357 (W 0.0325408) | 16.9374 ± 0.132912 (W 0.071225) | 9.66829 ± 0.0117358 (W 0.0161429) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.4953 ± 0.10216 (W 0.245553) | 60.6303 ± 0.0701048 (W 0.237563) | 42.865 ± 0.0580576 (W 0.0640776) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007424 ± 0.000445249 (W 1.98796e-05) | 0.007143 ± 0.000399351 (W 2.78622e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.02129 ± 0.00122637 (W 8.4518e-05) | 0.020548 ± 0.00132789 (W 0.000117572) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.079699 ± 0.00489407 (W 0.000808405) | 0.079558 ± 0.00345587 (W 0.0036516) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.813673 ± 0.00233368 (W 0.0031542) | 0.812781 ± 0.00298973 (W 0.00964593) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.0523 ± 0.817792 (W 0.0494247) | 53.4348 ± 1.14458 (W 0.564977) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.554851 ± 0.0020612 (W 0.00197601) | 0.559676 ± 0.0052601 (W 0.00200793) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554125 ± 0.00438593 (W 0.00201274) | 0.57028 ± 0.000861939 (W 0.00185015) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.0208 ± 0.0393342 (W 0.0212692) | 34.9886 ± 0.0647438 (W 0.04138) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.1246 ± 0.0214269 (W 0.379776) | 35.0059 ± 0.0145518 (W 0.0281566) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.471727 ± 0.00186397 (W 0.00224492) | 0.474487 ± 0.00888466 (W 0.00714736) | 0.663411 ± 0.13437 (W 0.00260494) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.493 ± 0.0867342 (W 0.0240561) | 19.0317 ± 0.0932786 (W 0.0334486) | 18.4578 ± 2.22392 (W 0.103362) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.57794 ± 0.00492526 (W 0.0040506) | 1.55556 ± 0.00473636 (W 0.00391801) | 1.86281 ± 0.00897803 (W 0.00668323) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 70.545 ± 2.44448 (W 0.0804416) | 74.074 ± 2.44903 (W 0.173738) | 80.9059 ± 0.446743 (W 0.238166) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.05663 ± 0.00255503 (W 0.00218222) | 1.86387 ± 0.00477626 (W 0.00420416) | 0.912977 ± 0.01016 (W 0.00328511) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 31.5042 ± 0.333 (W 0.0734079) | 78.1309 ± 0.138593 (W 0.079252) | 34.966 ± 0.307298 (W 0.129965) | 🔵 faer-fork 2.48× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50727 ± 0.00747158 (W 0.00496629) | 2.517 ± 0.00293518 (W 0.00494199) | 3.051 ± 0.00247073 (W 0.00522874) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.3389 ± 0.373779 (W 0.10909) | 88.3848 ± 0.262101 (W 0.171727) | 120.64 ± 0.169418 (W 0.368269) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.49585 ± 0.00135625 (W 0.00429107) | 1.4992 ± 0.00511275 (W 0.00707935) | 1.3939 ± 0.00562451 (W 0.00279306) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.864 ± 0.0999145 (W 0.0438424) | 44.8747 ± 0.130261 (W 0.0375951) | 46.4492 ± 0.319543 (W 0.421091) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.813131 ± 0.00629557 (W 0.00233712) | 0.817798 ± 0.0084428 (W 0.00813154) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.8415 ± 0.0902923 (W 0.253624) | 24.1434 ± 0.0646014 (W 0.398779) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.187508 ± 0.00163683 (W 0.00207935) | 0.159867 ± 0.00140859 (W 0.000838983) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.188381 ± 0.00535663 (W 0.00257298) | 0.162832 ± 0.00412047 (W 0.00200973) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.0344 ± 0.0520464 (W 0.123107) | 9.41969 ± 0.0297418 (W 0.0331166) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.0705 ± 0.174859 (W 0.090179) | 9.41136 ± 0.0493366 (W 0.0242848) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.495415 ± 0.00644985 (W 0.00486358) | 0.500364 ± 0.0100898 (W 0.00798191) | 0.531322 ± 0.117275 (W 0.00326332) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.40088 ± 0.134518 (W 0.0731242) | 13.0753 ± 0.0232917 (W 0.0296496) | 13.3617 ± 1.93192 (W 0.0498191) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.25604 ± 0.00956882 (W 0.00963041) | 1.70188 ± 0.00709102 (W 0.00917987) | 1.05977 ± 0.00348283 (W 0.00916581) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 28.3929 ± 0.105494 (W 0.236118) | 35.5095 ± 0.129523 (W 0.0831482) | 29.9979 ± 0.150761 (W 0.0990414) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.04604 ± 0.0118717 (W 0.00599207) | 3.89714 ± 0.0718084 (W 0.142652) | 0.461392 ± 0.007833 (W 0.00741651) | 🔵 faer-fork 3.73× faster than `faer-upstream` | 🔴 faer-fork 2.27× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 15.5955 ± 0.380918 (W 0.168954) | 77.7396 ± 0.495906 (W 0.522594) | 12.6596 ± 0.0116089 (W 0.0407167) | 🔵 faer-fork 4.98× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.35654 ± 0.0257735 (W 0.0255986) | 2.79459 ± 0.0271472 (W 0.0183469) | 1.89116 ± 0.00871908 (W 0.00610364) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 46.9263 ± 0.0400083 (W 0.172322) | 50.1806 ± 0.136366 (W 0.424655) | 48.8405 ± 2.04713 (W 0.159194) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.64118 ± 0.0138506 (W 0.0172766) | 2.10199 ± 0.0155939 (W 0.0241619) | 0.94817 ± 0.00110806 (W 0.00721414) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 31.4181 ± 0.126567 (W 0.199021) | 35.4283 ± 0.119406 (W 0.103605) | 22.434 ± 0.132448 (W 0.0986474) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.812581 ± 0.00211823 (W 0.00159581) | 0.814208 ± 0.00520912 (W 0.00452375) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.7693 ± 0.11689 (W 0.0971051) | 19.52 ± 0.158941 (W 1.01772) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.164036 ± 0.00796313 (W 0.00528355) | 0.137485 ± 0.000766726 (W 0.00287123) | - | 🔴 faer-fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.156741 ± 0.00200022 (W 0.00661613) | 0.135431 ± 0.00181312 (W 0.00258447) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.45725 ± 0.077293 (W 0.0987465) | 5.02094 ± 0.0077081 (W 0.987301) | - | 🔴 faer-fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.534 ± 0.0779516 (W 0.174905) | 5.03459 ± 0.0482603 (W 1.01981) | - | 🔴 faer-fork 1.30× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.478278 ± 0.00273631 (W 0.00498549) | 0.529778 ± 0.0044253 (W 0.0102843) | 0.592569 ± 0.166829 (W 0.00965111) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.70416 ± 0.160708 (W 0.0607192) | 12.2352 ± 0.0224397 (W 0.0370387) | 4.18041 ± 1.85502 (W 0.0203449) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔴 faer-fork 2.08× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.40799 ± 0.0100048 (W 0.0149412) | 1.97811 ± 0.0324862 (W 0.0221825) | 0.887066 ± 0.014141 (W 0.00289268) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.0356 ± 0.125018 (W 0.289359) | 36.039 ± 1.87123 (W 0.782325) | 20.8717 ± 0.103376 (W 0.0752353) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.13247 ± 0.00660063 (W 0.0133114) | 4.57557 ± 0.114988 (W 0.12057) | 0.320768 ± 0.00220355 (W 0.00258517) | 🔵 faer-fork 4.04× faster than `faer-upstream` | 🔴 faer-fork 3.53× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 12.7831 ± 0.14452 (W 0.0976819) | 76.7799 ± 0.434291 (W 0.448969) | 7.37531 ± 0.0418365 (W 0.0512404) | 🔵 faer-fork 6.01× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50215 ± 0.00350145 (W 0.0212805) | 3.14083 ± 0.00650796 (W 0.0526352) | 1.68194 ± 0.0128441 (W 0.00546058) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.7599 ± 0.102213 (W 0.125755) | 50.4252 ± 0.332008 (W 0.356224) | 36.5571 ± 0.117826 (W 0.081627) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.77177 ± 0.0107389 (W 0.0238406) | 2.48486 ± 0.0108751 (W 0.0317455) | 0.815771 ± 0.0174406 (W 0.00330238) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 29.6711 ± 0.0662797 (W 0.100072) | 37.295 ± 0.23367 (W 0.126963) | 16.834 ± 0.0925075 (W 0.0561365) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729977 ± 0.00223825 (W 0.00207908) | 0.730448 ± 0.0010535 (W 0.0104288) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.5034 ± 0.875735 (W 0.0551464) | 46.8185 ± 0.854788 (W 0.0869299) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.599684 ± 0.00445571 (W 0.00375837) | 0.598352 ± 0.00664343 (W 0.00272288) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.592758 ± 0.00395507 (W 0.00191849) | 0.603508 ± 0.0079633 (W 0.00242824) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.4243 ± 0.16499 (W 0.0363726) | 35.3647 ± 0.0784918 (W 0.0298095) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.4795 ± 0.365265 (W 0.058943) | 35.4694 ± 0.224237 (W 0.0266824) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.383332 ± 0.00150723 (W 0.00313169) | 0.38515 ± 0.00362812 (W 0.00350087) | 0.286162 ± 0.000991028 (W 0.00249994) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2505 ± 0.0256572 (W 0.029158) | 13.2668 ± 0.0102683 (W 0.0140955) | 11.6254 ± 0.0032902 (W 0.0203674) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.466 ± 0.00271413 (W 0.00400414) | 1.46152 ± 0.00391819 (W 0.00507965) | 1.5853 ± 0.00292872 (W 0.00278252) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 68.4429 ± 2.58043 (W 0.158986) | 68.4034 ± 2.53186 (W 0.063644) | 70.0832 ± 0.178195 (W 0.0468785) | · | · | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.774979 ± 0.000789826 (W 0.00250356) | 0.774729 ± 0.00237708 (W 0.00339249) | 0.766074 ± 0.00211588 (W 0.00214927) | · | · |  |
| `qr_factor/4096x256/b1` | 25.9871 ± 0.0485551 (W 0.0290725) | 26.0146 ± 0.0205204 (W 0.0233221) | 29.1988 ± 0.0717021 (W 0.0227515) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.46116 ± 0.00263622 (W 0.00375689) | 2.45942 ± 0.00544194 (W 0.00271045) | 2.82514 ± 0.00803154 (W 0.00695553) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.9953 ± 0.281863 (W 0.071204) | 82.8479 ± 0.389787 (W 0.421262) | 109.702 ± 0.580245 (W 0.0707727) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.40244 ± 0.00184739 (W 0.00317058) | 1.4064 ± 0.00320067 (W 0.00354769) | 1.24388 ± 0.00128286 (W 0.00222865) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 39.2611 ± 0.0332647 (W 0.111797) | 39.2396 ± 0.047664 (W 0.0394687) | 40.6247 ± 0.203097 (W 0.0346676) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.73174 ± 0.00168667 (W 0.00390557) | 0.735667 ± 0.00232579 (W 0.00286962) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.5794 ± 0.0567921 (W 0.106894) | 17.7212 ± 0.10245 (W 0.139039) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.196846 ± 0.00525394 (W 0.00169045) | 0.178642 ± 0.0184832 (W 0.00290779) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.205792 ± 0.00345517 (W 0.00338945) | 0.202347 ± 0.000288377 (W 0.00233412) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.1917 ± 0.0981601 (W 0.0297034) | 10.9019 ± 0.18019 (W 0.0148455) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.356 ± 0.101211 (W 0.0136969) | 11.2039 ± 0.0539316 (W 0.0152246) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.411163 ± 0.00316799 (W 0.0134754) | 0.430249 ± 0.0018571 (W 0.00861255) | 0.286084 ± 0.00131571 (W 0.00165715) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.32768 ± 0.0306109 (W 0.0257688) | 7.39628 ± 0.042209 (W 0.0310783) | 11.6033 ± 0.00381947 (W 0.0189146) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.18358 ± 0.00854972 (W 0.00670986) | 1.61757 ± 0.0114193 (W 0.00889345) | 0.991201 ± 0.0104662 (W 0.00882028) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.2035 ± 0.275435 (W 0.140572) | 29.5335 ± 0.113288 (W 0.142384) | 27.0288 ± 0.119924 (W 0.0585068) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.897198 ± 0.00939816 (W 0.00986447) | 1.35626 ± 0.00409808 (W 0.0153832) | 0.423506 ± 0.00416193 (W 0.00712797) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.5016 ± 0.226523 (W 0.248989) | 17.8939 ± 0.132071 (W 0.121509) | 11.3381 ± 0.104284 (W 0.0486323) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.30308 ± 0.0216099 (W 0.0226118) | 2.72147 ± 0.00693715 (W 0.0159719) | 1.82209 ± 0.00391573 (W 0.00738655) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 41.1335 ± 0.224843 (W 0.0834937) | 44.6762 ± 0.313958 (W 0.186617) | 45.6189 ± 0.154738 (W 0.114364) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.56765 ± 0.0221282 (W 0.0175984) | 2.02974 ± 0.0222454 (W 0.0359142) | 0.907674 ± 0.00101115 (W 0.00768291) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.7084 ± 0.0918709 (W 0.129545) | 29.7624 ± 0.123012 (W 0.0854484) | 21.0743 ± 0.295631 (W 0.0797425) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729344 ± 0.00335822 (W 0.00239432) | 0.731841 ± 0.000754619 (W 0.00312435) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6452 ± 0.0238567 (W 0.0787029) | 13.7265 ± 0.0568258 (W 0.0879349) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.162672 ± 0.00598995 (W 0.00715008) | 0.161559 ± 0.00503517 (W 0.00171477) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.162904 ± 0.00604924 (W 0.00352594) | 0.165447 ± 0.00464762 (W 0.00140527) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.49399 ± 0.220573 (W 0.23033) | 6.8134 ± 0.0572811 (W 0.130312) | - | 🔴 faer-fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.36064 ± 0.179549 (W 0.245573) | 6.88715 ± 0.1294 (W 0.146273) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.392793 ± 0.00197654 (W 0.00502632) | 0.444429 ± 0.00386318 (W 0.00816104) | 0.28553 ± 0.000380927 (W 0.00193685) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.64331 ± 0.0329147 (W 0.0287621) | 6.66644 ± 0.0472843 (W 0.0405298) | 3.15712 ± 0.0165627 (W 0.0111277) | · | 🔴 faer-fork 2.10× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.33378 ± 0.0312731 (W 0.0148422) | 1.90252 ± 0.0364247 (W 0.0274205) | 0.8512 ± 0.00153137 (W 0.00221007) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 19.7244 ± 0.100931 (W 0.0847203) | 29.6464 ± 0.273514 (W 0.402325) | 19.2989 ± 0.0969928 (W 0.0488965) | 🔵 faer-fork 1.50× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.01615 ± 0.00138262 (W 0.0131393) | 1.66145 ± 0.0276557 (W 0.016638) | 0.302143 ± 0.00201289 (W 0.00132259) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔴 faer-fork 3.36× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.5602 ± 0.0126464 (W 0.0303266) | 19.1772 ± 0.0428583 (W 0.0896565) | 6.47456 ± 0.0180427 (W 0.0364185) | 🔵 faer-fork 1.66× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.44997 ± 0.0304415 (W 0.0198234) | 3.10674 ± 0.0495961 (W 0.0208555) | 1.64513 ± 0.00469384 (W 0.00282376) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 35.1351 ± 0.219428 (W 0.0602285) | 44.7941 ± 0.532171 (W 0.657157) | 34.5687 ± 0.0917672 (W 0.0691005) | 🔵 faer-fork 1.27× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.67658 ± 0.0187546 (W 0.0264446) | 2.40404 ± 0.00667342 (W 0.0382088) | 0.788627 ± 0.00300658 (W 0.00316576) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.1741 ± 0.0950907 (W 0.0759272) | 31.7918 ± 0.0788449 (W 0.181474) | 15.8926 ± 0.103597 (W 0.0800555) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78777 ± 0.00149231 (W 0.0026958) | 1.82751 ± 0.00908886 (W 0.00432314) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.564 ± 0.63279 (W 0.712293) | 154.839 ± 0.378334 (W 0.288245) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.20025 ± 0.00902563 (W 0.00392534) | 2.19435 ± 0.0263401 (W 0.00257227) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20783 ± 0.00610268 (W 0.00469354) | 2.19894 ± 0.00124896 (W 0.00262716) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.95 ± 0.143336 (W 0.0805324) | 137.845 ± 0.168644 (W 0.363962) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.902 ± 0.174948 (W 0.0542502) | 137.806 ± 0.0935933 (W 0.0834365) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.01388 ± 0.0025675 (W 0.01063) | 1.02427 ± 0.00509233 (W 0.00280027) | 1.22656 ± 0.0202358 (W 0.00390238) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 47.2309 ± 0.30162 (W 0.120583) | 53.9688 ± 0.0490871 (W 0.0760242) | 67.0253 ± 0.126865 (W 0.161278) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.73596 ± 0.0140086 (W 0.00632246) | 4.79659 ± 0.00890834 (W 0.00984469) | 5.11256 ± 0.0135226 (W 0.00562995) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 250.094 ± 0.23442 (W 0.182519) | 256.65 ± 0.292404 (W 0.3722) | 238.757 ± 0.24573 (W 0.43393) | · | · |  |
| `qr_factor/1024x64/b1` | 2.49394 ± 0.0183027 (W 0.00803357) | 4.04288 ± 0.0450718 (W 0.0108568) | 2.38334 ± 0.00873035 (W 0.0050421) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 101.057 ± 0.212592 (W 0.285306) | 176.501 ± 0.273544 (W 0.242382) | 110.679 ± 0.0565089 (W 0.404394) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 6.02031 ± 0.0146345 (W 0.00780281) | 6.04782 ± 0.0160326 (W 0.0114737) | 8.7665 ± 0.0120964 (W 0.0206589) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 280.613 ± 0.311533 (W 1.30989) | 281.687 ± 0.479901 (W 0.394806) | 378.985 ± 0.674829 (W 0.773568) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.0825 ± 0.00746339 (W 0.00347742) | 3.12368 ± 0.0193716 (W 0.00833809) | 3.8009 ± 0.016859 (W 0.00437966) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 122.25 ± 0.081623 (W 0.0834617) | 122.745 ± 0.187783 (W 0.0712502) | 144.822 ± 6.52768 (W 0.600903) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77729 ± 0.0150752 (W 0.00462328) | 1.78582 ± 0.005716 (W 0.0022277) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.407 ± 0.765933 (W 0.515234) | 65.9578 ± 0.994451 (W 1.25895) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.629281 ± 0.00861 (W 0.00777155) | 0.583455 ± 0.0111578 (W 0.00242396) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.627555 ± 0.00418335 (W 0.00791634) | 0.601452 ± 0.010561 (W 0.00241483) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.0354 ± 0.243865 (W 0.315694) | 36.9714 ± 0.168699 (W 0.111241) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.1779 ± 0.113275 (W 0.208923) | 37.0912 ± 0.230284 (W 0.0650275) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.839447 ± 0.00224827 (W 0.0177911) | 0.827877 ± 0.00460364 (W 0.0115394) | 1.0983 ± 0.00486217 (W 0.00144752) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 23.1063 ± 0.0867431 (W 0.194275) | 29.9235 ± 0.042775 (W 0.0514599) | 59.0028 ± 3.46806 (W 0.097176) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 2.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.66167 ± 0.0134716 (W 0.108233) | 3.00264 ± 0.0099084 (W 0.0206075) | 3.1152 ± 0.0093107 (W 0.00452159) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 83.9856 ± 0.239253 (W 0.35928) | 98.8195 ± 0.225026 (W 0.204858) | 80.135 ± 0.180276 (W 0.388921) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.91667 ± 0.147292 (W 0.00795665) | 4.39172 ± 0.0602322 (W 0.044969) | 1.39251 ± 0.00323679 (W 0.00305444) | 🔵 faer-fork 2.29× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 40.8307 ± 0.31837 (W 0.153882) | 123.984 ± 0.202896 (W 0.384719) | 34.072 ± 0.303565 (W 0.202325) | 🔵 faer-fork 3.04× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.03744 ± 0.0836255 (W 0.123112) | 4.36028 ± 0.0138202 (W 0.0153565) | 5.50621 ± 0.0106011 (W 0.0101814) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 115.027 ± 0.040717 (W 0.174571) | 122.971 ± 0.122868 (W 0.207813) | 140.496 ± 0.601604 (W 0.357597) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.64878 ± 0.0276381 (W 0.0593558) | 3.02085 ± 0.00351245 (W 0.0289801) | 2.82585 ± 0.0168332 (W 0.00555766) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 66.869 ± 0.257591 (W 0.14293) | 75.502 ± 0.161631 (W 0.155232) | 51.4685 ± 0.695658 (W 0.260504) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.76745 ± 0.00241244 (W 0.00293161) | 1.77442 ± 0.00975815 (W 0.00355382) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.3852 ± 0.242405 (W 0.354543) | 41.1073 ± 0.295195 (W 0.234849) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.418607 ± 0.0116686 (W 0.00558857) | 0.405252 ± 0.00281298 (W 0.00430561) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.406824 ± 0.00899279 (W 0.00510797) | 0.407385 ± 0.00216214 (W 0.00251643) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.3464 ± 0.382106 (W 0.469932) | 18.7416 ± 0.0741778 (W 0.25229) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.9486 ± 0.119941 (W 0.675051) | 18.8176 ± 0.100731 (W 0.0734696) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.820646 ± 0.00279629 (W 0.00882472) | 0.810266 ± 0.00353059 (W 0.0155603) | 1.08187 ± 0.000754232 (W 0.00235131) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 19.4483 ± 0.0536781 (W 0.0850618) | 25.9992 ± 0.0755992 (W 0.0418495) | 57.7878 ± 0.422721 (W 0.123051) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 2.97× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.4617 ± 0.0188051 (W 0.017057) | 3.2014 ± 0.010225 (W 0.0408934) | 2.31846 ± 0.00594376 (W 0.00221218) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 57.7335 ± 6.64461 (W 0.208499) | 82.3196 ± 5.63331 (W 0.209126) | 45.8216 ± 0.229001 (W 0.174637) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.84785 ± 0.00555295 (W 0.0132393) | 5.0034 ± 0.190029 (W 0.0786098) | 0.870563 ± 0.00235875 (W 0.00156415) | 🔵 faer-fork 2.71× faster than `faer-upstream` | 🔴 faer-fork 2.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 30.5672 ± 0.0418286 (W 0.0888416) | 122.218 ± 0.253751 (W 0.890764) | 19.7389 ± 0.129052 (W 0.115516) | 🔵 faer-fork 4.00× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.84181 ± 0.0151735 (W 0.0258825) | 4.65476 ± 0.0095579 (W 0.0236828) | 4.4719 ± 0.00144559 (W 0.0134749) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.1433 ± 0.297603 (W 0.249849) | 106.191 ± 2.58393 (W 0.721074) | 82.9994 ± 2.98559 (W 0.225896) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.62227 ± 0.0225116 (W 0.019631) | 3.39152 ± 0.0236677 (W 0.0431958) | 2.30108 ± 0.00875818 (W 0.00265726) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 58.7262 ± 0.099103 (W 0.110751) | 73.0231 ± 0.140597 (W 0.109361) | 34.3526 ± 0.144667 (W 0.148144) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66965 ± 0.00377816 (W 0.00254597) | 1.6678 ± 0.00121145 (W 0.003107) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.494 ± 0.253147 (W 0.751402) | 142.888 ± 0.560109 (W 0.382242) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.2368 ± 0.0230428 (W 0.00532348) | 2.23355 ± 0.0184599 (W 0.00205627) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.27291 ± 0.00962331 (W 0.0020076) | 2.26354 ± 0.0118601 (W 0.00310754) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 139.073 ± 0.220246 (W 0.135908) | 138.866 ± 0.11472 (W 0.0714455) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 139.015 ± 0.159025 (W 0.0578646) | 138.943 ± 0.175596 (W 0.0536745) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.895624 ± 0.00399748 (W 0.00771982) | 0.889043 ± 0.0079686 (W 0.00831079) | 1.06449 ± 0.0151782 (W 0.00290112) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 42.0014 ± 0.0741243 (W 0.0720571) | 41.8713 ± 0.0356976 (W 0.0503238) | 49.7516 ± 0.0774698 (W 0.14678) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.61094 ± 0.00749912 (W 0.00398579) | 4.65581 ± 0.015936 (W 0.00487413) | 4.83709 ± 0.0299594 (W 0.00929485) | · | · |  |
| `qr/4096x256/b1` | 244.178 ± 0.473618 (W 0.537553) | 244.714 ± 0.349666 (W 0.397027) | 215.046 ± 0.760626 (W 0.352894) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.22492 ± 0.0526098 (W 0.00429704) | 2.2521 ± 0.0265539 (W 0.00410454) | 2.24451 ± 0.00885676 (W 0.0072745) | · | · |  |
| `qr_factor/4096x256/b1` | 89.1008 ± 0.0891927 (W 0.0542638) | 89.5326 ± 0.10526 (W 0.069849) | 103.258 ± 0.121051 (W 0.414492) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.90541 ± 0.0117081 (W 0.00843664) | 5.93916 ± 0.0162584 (W 0.00812588) | 8.43919 ± 0.0723005 (W 0.0109735) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 268.33 ± 0.364262 (W 0.21256) | 269.277 ± 0.140827 (W 0.350835) | 370.629 ± 0.517286 (W 1.14689) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.95544 ± 0.00487853 (W 0.00440724) | 3.00259 ± 0.0192474 (W 0.00274182) | 3.6635 ± 0.0161146 (W 0.00753933) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 110.071 ± 0.0864986 (W 0.0933976) | 110.537 ± 0.12087 (W 0.362141) | 138.001 ± 0.0973872 (W 0.714888) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6644 ± 0.00605005 (W 0.00266858) | 1.66123 ± 0.00257464 (W 0.00374127) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.6667 ± 0.26626 (W 0.675588) | 52.3897 ± 0.329101 (W 0.431507) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.641586 ± 0.0080259 (W 0.0102722) | 0.627274 ± 0.00159837 (W 0.00243925) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.64133 ± 0.00611114 (W 0.00761767) | 0.634768 ± 0.00842017 (W 0.00286177) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.1893 ± 0.174629 (W 0.0445154) | 39.6753 ± 0.217185 (W 0.0743168) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.324 ± 0.12207 (W 0.055995) | 39.757 ± 0.0968479 (W 0.0832461) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.729163 ± 0.00321706 (W 0.00961899) | 0.730977 ± 0.00203736 (W 0.0121736) | 1.06454 ± 0.00658913 (W 0.00277277) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.5382 ± 0.0111511 (W 0.0577869) | 17.5688 ± 0.0403304 (W 0.0611001) | 49.4814 ± 0.202262 (W 0.0818758) | · | 🔵 faer-fork 2.82× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.6298 ± 0.127315 (W 0.0869042) | 2.90692 ± 0.0181982 (W 0.011947) | 3.05956 ± 0.00768759 (W 0.0042156) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 78.5241 ± 0.359452 (W 0.129333) | 86.5877 ± 0.272553 (W 0.0881519) | 74.497 ± 0.432986 (W 0.207877) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.73825 ± 0.00309155 (W 0.0057394) | 2.14698 ± 0.0101876 (W 0.0248582) | 1.3519 ± 0.00398602 (W 0.00312721) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 35.8876 ± 0.0613944 (W 0.0615392) | 44.5329 ± 0.0572444 (W 0.132269) | 31.3404 ± 0.441448 (W 0.230906) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.92114 ± 0.015013 (W 0.0852531) | 4.26599 ± 0.0215976 (W 0.0253253) | 5.40062 ± 0.0741243 (W 0.0396492) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 103.097 ± 0.207645 (W 0.703891) | 111.032 ± 0.164762 (W 0.20104) | 130.215 ± 1.46538 (W 0.303888) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.55241 ± 0.0744979 (W 0.0962422) | 2.93801 ± 0.00946296 (W 0.0157882) | 2.77973 ± 0.00990633 (W 0.00273007) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 55.1108 ± 0.204456 (W 0.098494) | 63.5012 ± 0.0894827 (W 0.0946212) | 48.6498 ± 0.356869 (W 0.227852) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6592 ± 0.00180053 (W 0.0047214) | 1.65394 ± 0.0024824 (W 0.00306652) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.0122 ± 0.0815103 (W 0.181077) | 29.1308 ± 0.140627 (W 0.223188) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.414098 ± 0.00060937 (W 0.00824054) | 0.444517 ± 0.00209994 (W 0.00912996) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.42065 ± 0.00325567 (W 0.00918833) | 0.444937 ± 0.0106297 (W 0.00293819) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.1882 ± 0.332701 (W 0.504529) | 21.4375 ± 0.375825 (W 3.20797) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.294 ± 0.187681 (W 0.375846) | 21.504 ± 0.313985 (W 0.328536) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.710779 ± 0.0050245 (W 0.0105935) | 0.712081 ± 0.00333658 (W 0.010333) | 1.05019 ± 0.0356942 (W 0.00197887) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 13.6451 ± 0.0905095 (W 0.041308) | 13.7118 ± 0.0924003 (W 0.0430995) | 49.4764 ± 0.582936 (W 0.0940486) | · | 🔵 faer-fork 3.63× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.30329 ± 0.0187589 (W 0.0214903) | 3.12723 ± 0.00775863 (W 0.0126225) | 2.28303 ± 0.000743722 (W 0.00401453) | 🔵 faer-fork 1.36× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 52.2134 ± 6.23909 (W 0.142605) | 70.0507 ± 5.76506 (W 0.833692) | 42.1095 ± 0.0503789 (W 0.199571) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.70628 ± 0.00316996 (W 0.0117975) | 2.47142 ± 0.00901759 (W 0.0304317) | 0.85268 ± 0.00136806 (W 0.00215008) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔴 faer-fork 2.00× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.4553 ± 0.0979239 (W 0.0391198) | 41.9054 ± 0.120006 (W 0.0673671) | 17.6256 ± 0.0894597 (W 0.0628448) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.71502 ± 0.0220236 (W 0.026793) | 4.54268 ± 0.0154911 (W 0.0243499) | 4.39164 ± 0.0158685 (W 0.00690135) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 76.0493 ± 0.302306 (W 0.217674) | 93.6645 ± 0.868374 (W 0.714174) | 73.8199 ± 0.120668 (W 0.141311) | 🔵 faer-fork 1.23× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.56132 ± 0.00254207 (W 0.027512) | 3.29148 ± 0.0203772 (W 0.0244391) | 2.30177 ± 0.012382 (W 0.00562164) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 47.0746 ± 0.0585174 (W 0.118765) | 61.2723 ± 0.477987 (W 0.0850103) | 32.1925 ± 0.109779 (W 0.135563) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
