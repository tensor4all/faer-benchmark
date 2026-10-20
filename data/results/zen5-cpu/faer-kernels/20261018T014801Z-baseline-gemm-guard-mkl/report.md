# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `0627828d965b4abbf5eb14cc012f524a42966e85`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9b65ef9ea7de07a70d6f211ae12b47c9bce75b8e`
- toolkit commit: `c04ea318cf7f002a751d58212fe31fc79d915665`
- measured binary SHA-256: `7f53c095fa4ce2e7f2bb9356b147b5b1b15e47f1f2371fc1c1ef5373da4b3edc`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-18T01:53:21.702163Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-small,gemm-mid --shapes 32x32x32,64x64x64,96x96x96,128x128x128,192x192x192 --families gemm --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --no-publish --label baseline-gemm-guard-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261018T014801Z-baseline-gemm-guard-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.33%, worst 72.08% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 48 of 180 engine cells exceed 5% and carry `!`; median within-process relative SD 1.21%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002345 ± 1.53948e-05 (W 1.83112e-05) | 0.002344 ± 6.08276e-06 (W 1.1371e-05) | 0.004489 ± 5.7735e-06 (W 4.91559e-05) | · | 🔵 fork 1.91× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017061 ± 7.22519e-05 (W 1.88468e-05) | 0.017052 ± 4.62637e-05 (W 3.1305e-05) | 0.024476 ± 0.000157513 (W 6.67083e-05) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056806 ± 2.08167e-05 (W 5.95819e-05) | 0.056756 ± 0.000115902 (W 5.14782e-05) | 0.062677 ± 6.61085e-05 (W 8.61394e-05) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.010019 ± 0.000476194 (W 0.00104142) | 0.010219 ± 0.000561437 (W 0.000550405) | 0.005119 ± 0.000113578 (W 8.44405e-05) | · | 🔴 fork 1.96× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.024025 ± 0.00109572 (W 0.00366511) | 0.024826 ± 0.00384517 (W 0.00388744) | 0.014127 ± 0.000171349 (W 0.000104792) | · | 🔴 fork 1.70× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.052137 ± 0.00955769 (W 0.010018) | 0.047759 ± 0.0137383 (W 0.013684) | 0.022181 ± 0.000139237 (W 0.000102133) | · | 🔴 fork 2.35× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.013626 ± 0.00121402 (W 0.00106104) | 0.013125 ± 0.000269482 (W 0.00201532) | 0.004949 ± 0.000180278 (W 0.000199543) | · | 🔴 fork 2.75× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.019306 ± 0.000802994 (W 0.00192591) | 0.019466 ± 0.00041601 (W 0.00136366) | 0.009878 ± 0.000147886 (W 0.000218211) | · | 🔴 fork 1.95× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.029725 ± 0.00121705 (W 0.00166949) | 0.030697 ± 0.00038627 (W 0.00132522) | 0.014567 ± 0.000329237 (W 0.000162401) | · | 🔴 fork 2.04× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 6.08276e-06 (W 1.62265e-05) | 0.002324 ± 1.1547e-05 (W 1.63799e-05) | 0.004499 ± 2.64575e-05 (W 2.40479e-05) | · | 🔵 fork 1.92× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017102 ± 2.5632e-05 (W 1.80887e-05) | 0.017142 ± 6.55744e-05 (W 3.42053e-05) | 0.024455 ± 1.00167e-05 (W 0.00010884) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056986 ± 0.000116762 (W 7.20715e-05) | 0.056846 ± 7.02377e-05 (W 4.89306e-05) | 0.062757 ± 5.1316e-05 (W 6.7082e-05) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.01055 ± 0.000623323 (W 0.000986828) | 0.01058 ± 0.000153948 (W 0.000692942) | 0.005039 ± 0.000153266 (W 0.000120168) | · | 🔴 fork 2.09× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.022703 ± 0.00095295 (W 0.00304282) | 0.020538 ± 0.00222967 (W 0.00319326) | 0.014337 ± 0.000260571 (W 0.00015695) | · | 🔴 fork 1.58× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.057848 ± 0.0068148 (W 0.0127364) | 0.059881 ± 0.01161 (W 0.00930871) | 0.022182 ± 0.000351371 (W 0.00013037) | · | 🔴 fork 2.61× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.014226 ± 0.00132842 (W 0.00188595) | 0.013415 ± 0.000841658 (W 0.00113003) | 0.004829 ± 0.000289194 (W 9.21954e-05) | · | 🔴 fork 2.95× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.020869 ± 0.000834383 (W 0.00117209) | 0.019757 ± 0.00121604 (W 0.0016406) | 0.010108 ± 0.000151064 (W 0.000247275) | · | 🔴 fork 2.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.029154 ± 0.00130274 (W 0.00172568) | 0.029855 ± 0.00117251 (W 0.00179281) | 0.014578 ± 0.000296729 (W 0.000168111) | · | 🔴 fork 2.00× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008876 ± 1.73205e-05 (W 1.18025e-05) | 0.008877 ± 1.12694e-05 (W 8.94427e-06) | 0.011161 ± 0.000111355 (W 0.000109773) | · | 🔵 fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.068017 ± 0.000242715 (W 0.00141476) | 0.067977 ± 0.000149332 (W 0.0013273) | 0.083135 ± 0.000753975 (W 0.000975461) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.227044 ± 0.000152895 (W 0.00146663) | 0.227273 ± 0.000233733 (W 0.00132732) | 0.27307 ± 0.00240544 (W 0.0030384) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008787 ± 4.56107e-05 (W 2.98379e-05) | 0.008856 ± 3.23574e-05 (W 1.89024e-05) | 0.014207 ± 0.00031769 (W 0.000186723) | · | 🔵 fork 1.62× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.042409 ± 0.00438479 (W 0.00414746) | 0.041558 ± 0.00449147 (W 0.00624179) | 0.035746 ± 0.000102031 (W 0.000242051) | · | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.09092 ± 0.007291 (W 0.00798194) | 0.098032 ± 0.00562711 (W 0.00822679) | 0.098915 ± 0.000692491 (W 0.00110966) | · | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008867 ± 5.5109e-05 (W 2.5948e-05) | 0.008877 ± 4.3589e-05 (W 2.16171e-05) | 0.024576 ± 0.00495396 (W 0.000216703) | · | 🔵 fork 2.77× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.03795 ± 0.000662154 (W 0.00135835) | 0.038061 ± 0.000602351 (W 0.00121934) | 0.015829 ± 0.000165712 (W 0.00019733) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.051657 ± 0.000981648 (W 0.00136004) | 0.050604 ± 0.000647694 (W 0.00136803) | 0.042439 ± 0.00014526 (W 0.000344211) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008866 ± 4.67654e-05 (W 1.91128e-05) | 0.008896 ± 1.52753e-05 (W 2.68328e-05) | 0.01108 ± 8.34286e-05 (W 0.000186497) | · | 🔵 fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067897 ± 9.50807e-05 (W 6.71513e-05) | 0.067766 ± 7.60285e-05 (W 2.31149e-05) | 0.082013 ± 0.00139444 (W 0.00148127) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.227063 ± 0.000453351 (W 0.00150821) | 0.226873 ± 0.000639671 (W 0.00141842) | 0.272628 ± 0.00177246 (W 0.00257181) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008836 ± 1.52753e-05 (W 1.64985e-05) | 0.008866 ± 2.60832e-05 (W 2.07364e-05) | 0.014096 ± 0.000465507 (W 0.000117988) | · | 🔵 fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.038802 ± 0.00346908 (W 0.00537851) | 0.044814 ± 0.000704151 (W 0.00540355) | 0.035707 ± 0.000212054 (W 0.00049078) | 🔵 fork 1.15× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.086972 ± 0.00051916 (W 0.00629745) | 0.0909 ± 0.00386717 (W 0.00731232) | 0.098804 ± 0.00175177 (W 0.00127925) | · | 🔵 fork 1.14× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008867 ± 1.76163e-05 (W 1.66193e-05) | 0.008827 ± 3.78594e-05 (W 1.84743e-05) | 0.024696 ± 0.000347535 (W 9.65572e-05) | · | 🔵 fork 2.79× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.03792 ± 0.000469696 (W 0.00112487) | 0.036558 ± 0.000425512 (W 0.00157992) | 0.015649 ± 8.14453e-05 (W 0.000145204) | · | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.051015 ± 0.000547506 (W 0.00155761) | 0.050655 ± 0.000777466 (W 0.00139479) | 0.042359 ± 0.00011547 (W 0.000356647) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13402 ± 0.000265588 (W 0.000284993) | 0.13371 ± 0.000165581 (W 0.00151392) | 0.166721 ± 0.00109695 (W 0.00198157) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.452264 ± 0.000570984 (W 0.00233964) | 0.451341 ± 0.000747865 (W 0.00194665) | 0.480024 ± 0.00122647 (W 0.00290342) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.073687 ± 0.0103979 (W 0.0164549) | 0.078627 ± 0.0162167 (W 0.0152537) | 0.057277 ± 0.000925709 (W 0.000979302) | · | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.13417 ± 0.0107159 (W 0.0147877) | 0.15561 ± 0.00901894 (W 0.0163454) | 0.135903 ± 0.000851248 (W 0.00181857) | 🔵 fork 1.16× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.085339 ± 0.0069348 (W 0.0202641) | 0.08536 ± 0.00559309 (W 0.0274612) | 0.032882 ± 0.000566746 (W 0.000215686) | · | 🔴 fork 2.60× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.17717 ± 0.0226616 (W 0.0307971) | 0.162874 ± 0.0188438 (W 0.0421674) | 0.073387 ± 0.000735093 (W 0.00028575) | · | 🔴 fork 2.41× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133699 ± 4.07063e-05 (W 7.09225e-05) | 0.13381 ± 0.000125061 (W 0.00110093) | 0.167883 ± 0.000435982 (W 0.00198879) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.452434 ± 0.00176897 (W 0.00176423) | 0.451712 ± 0.000838313 (W 0.00189621) | 0.482379 ± 0.00149294 (W 0.00227443) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.056946 ± 0.0228237 (W 0.0109412) | 0.086952 ± 0.0145499 (W 0.0185384) | 0.055644 ± 0.000365582 (W 0.000323034) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.147154 ± 0.00183828 (W 0.0131782) | 0.13926 ± 0.00792632 (W 0.0120691) | 0.135984 ± 0.000578516 (W 0.00165789) | · | 🔴 fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.081572 ± 0.00801512 (W 0.0217499) | 0.095608 ± 0.0107899 (W 0.0264565) | 0.031779 ± 0.000232337 (W 0.000146851) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 2.57× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.180296 ± 0.0200447 (W 0.0280683) | 0.17703 ± 0.0292673 (W 0.0303899) | 0.073958 ± 0.000309171 (W 0.000427722) | · | 🔴 fork 2.44× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538444 ± 0.00152757 (W 0.00173398) | 0.538194 ± 0.00230294 (W 0.00207528) | 0.64375 ± 0.00278779 (W 0.00846088) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81194 ± 0.00449378 (W 0.00212266) | 1.81032 ± 0.00322266 (W 0.00169927) | 2.14877 ± 0.00479228 (W 0.00555602) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.16053 ± 0.000323791 (W 0.00133685) | 0.160469 ± 0.000818863 (W 0.00665352) | 0.234347 ± 0.000786048 (W 0.00252234) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.473893 ± 0.00296451 (W 0.00361445) | 0.472601 ± 0.0015155 (W 0.0046415) | 0.746392 ± 0.0020858 (W 0.00441032) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.114985 ± 0.014918 (W 0.013608) | 0.116608 ± 0.0099141 (W 0.00985872) | 0.093835 ± 0.000491671 (W 0.000690819) | · | 🔴 fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.270494 ± 0.00586482 (W 0.0100072) | 0.282747 ± 0.00352796 (W 0.0129392) | 0.293057 ± 0.0006132 (W 0.00213473) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539626 ± 0.00134078 (W 0.00220056) | 0.538524 ± 0.000932447 (W 0.00206463) | 0.648108 ± 0.00266142 (W 0.0100223) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.80977 ± 0.0012803 (W 0.00202599) | 1.81179 ± 0.00490354 (W 0.00203422) | 2.15602 ± 0.00948408 (W 0.0166578) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.16098 ± 0.00142279 (W 0.00703435) | 0.160038 ± 0.000131226 (W 0.00138931) | 0.231782 ± 0.000774583 (W 0.00263987) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.475537 ± 0.000691178 (W 0.00360243) | 0.472832 ± 0.00340015 (W 0.00282985) | 0.74013 ± 0.00483858 (W 0.00454151) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.114394 ± 0.000525342 (W 0.0105298) | 0.114814 ± 0.000932459 (W 0.0167256) | 0.093895 ± 0.00019975 (W 0.000932246) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.277047 ± 0.00195353 (W 0.0109921) | 0.279671 ± 0.00304155 (W 0.00864708) | 0.296373 ± 0.00201329 (W 0.00389684) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
