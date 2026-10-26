# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `5a27bcece2f9f0d1c1b94c9b42dd7bfc4a94dc39`
- t4a-faer version: `0.24.10`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `9f5cc57ba8f237a2283b5e1beb6689ab9d486d11`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `ac124d68b755974de69922cd51457f9f6235719f96180671a413f0571389e190`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-26T18:31:51.167769Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /home/shinaoka/projects/tensor4all/faer-0.25-base --engines faer-fork,faer-upstream,lapack-mkl --aa 3 --reps 5 --prime-ms 250 --vendor mkl --no-publish --upstream extern/upstream-faer --threads 1,4,8 --dtypes f64,c64 --shapes 64,256,1024x64,64x1024,64x64x64,256x256x256,4096x64x64,16x4096x240,4096x16x240,64x64x4096 --families gemm,lu,qr_factor,cholesky,svd_values,svd_thin,eigh,householder_apply,solve --label pair3-base-1`
- raw data: `data/results/zen5-cpu/faer-kernels/20261026T180406Z-pair3-base-1/`

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
- CPU sets: 1T -> `4`, 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.88%, worst 1054.43% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 98 of 1152 engine cells exceed 5% and carry `!`; median within-process relative SD 0.35%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/64x64x64/b1` | 0.017122 ± 6.50641e-05 (W 3.09079e-05) | 0.017132 ± 5.7735e-05 (W 2.9399e-05) | 0.024456 ± 4.56107e-05 (W 5.14714e-05) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017212 ± 1.1547e-05 (W 0.00103337) | 0.018234 ± 0.000366921 (W 0.00172239) | 0.014206 ± 9.53939e-05 (W 0.000158844) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017091 ± 1.21244e-05 (W 3.56413e-05) | 0.01077 ± 0.000231805 (W 0.000203245) | 0.009899 ± 0.000190386 (W 0.00016305) | 🔴 faer-fork 1.59× slower than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017042 ± 5.1316e-05 (W 2.40687e-05) | 0.017032 ± 5.54106e-05 (W 1.89816e-05) | 0.024336 ± 7.44782e-05 (W 5.1733e-05) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017212 ± 4.16333e-05 (W 2.23204e-05) | 0.019186 ± 0.000842646 (W 0.00102387) | 0.014047 ± 3.50761e-05 (W 0.000148143) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.017132 ± 6.35085e-05 (W 2.5499e-05) | 0.01077 ± 0.000126361 (W 0.000224162) | 0.009898 ± 3.66106e-05 (W 0.000211081) | 🔴 faer-fork 1.59× slower than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067767 ± 6.78994e-05 (W 6.43452e-05) | 0.067666 ± 6.48614e-05 (W 7.49413e-05) | 0.083365 ± 0.000935334 (W 0.0010021) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.040165 ± 0.000957054 (W 0.00128527) | 0.039233 ± 0.00165486 (W 0.00134943) | 0.035546 ± 0.000292005 (W 0.000242201) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027902 ± 8.88819e-05 (W 0.000137212) | 0.028132 ± 0.000191103 (W 0.000197053) | 0.016561 ± 7.6922e-05 (W 0.000148207) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.067786 ± 1.73205e-05 (W 0.00132289) | 0.067696 ± 7.93725e-05 (W 4.39318e-05) | 0.083085 ± 0.0013814 (W 0.000782616) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.039603 ± 0.00135454 (W 0.00197937) | 0.039093 ± 0.00177968 (W 0.00183346) | 0.035456 ± 0.000367075 (W 0.000498985) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x64/b1` | 0.027802 ± 0.000335441 (W 0.000276196) | 0.028172 ± 0.000173494 (W 0.000285577) | 0.016491 ± 0.000130512 (W 0.000300601) | · | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07182 ± 0.00164253 (W 0.0016074) | 1.07266 ± 0.000737409 (W 0.00124871) | 1.20591 ± 0.00290646 (W 0.00209476) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.30657 ± 0.00160848 (W 0.00672332) | 0.312171 ± 0.0114347 (W 0.00896092) | 0.342478 ± 0.000595629 (W 0.00177731) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.26357 ± 0.0174871 (W 0.0285647) | 0.255366 ± 0.0198808 (W 0.0302822) | 0.179103 ± 0.00082077 (W 0.00139108) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07421 ± 0.00306851 (W 0.00061841) | 1.07353 ± 0.00254224 (W 0.0017134) | 1.20545 ± 0.000550792 (W 0.0026735) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.306401 ± 0.00831434 (W 0.0108735) | 0.307923 ± 0.00402408 (W 0.00829306) | 0.342669 ± 0.00156818 (W 0.00165161) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.251889 ± 0.00928662 (W 0.0339388) | 0.24693 ± 0.00353305 (W 0.0254407) | 0.178603 ± 0.00234229 (W 0.00127187) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28381 ± 0.00974801 (W 0.00363898) | 4.28193 ± 0.00146807 (W 0.00362737) | 5.09456 ± 0.0287721 (W 0.00889685) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.10993 ± 0.00214563 (W 0.0015415) | 1.10885 ± 0.000969753 (W 0.00124513) | 1.81229 ± 0.0160799 (W 0.00486579) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.609564 ± 0.00239401 (W 0.00238234) | 0.608383 ± 0.000438825 (W 0.00167195) | 0.699131 ± 0.0108669 (W 0.00290584) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 4.28115 ± 0.0101528 (W 0.00283371) | 4.28153 ± 0.00117987 (W 0.00564522) | 5.16664 ± 0.0388704 (W 0.00906243) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.10966 ± 0.0017819 (W 0.000772297) | 1.10813 ± 0.000855823 (W 0.00139696) | 1.79446 ± 0.0158457 (W 0.00508473) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.609525 ± 0.00143363 (W 0.00197335) | 0.608113 ± 0.00120999 (W 0.00174822) | 0.688721 ± 0.0117781 (W 0.00306284) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26681 ± 0.0716429 (W 0.00319342) | 1.2622 ± 0.0601539 (W 0.00396169) | 1.67993 ± 0.0954098 (W 0.00450736) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.07284 ± 0.00365287 (W 0.00139888) | 1.07452 ± 0.00336939 (W 0.00661885) | 1.52809 ± 0.0120083 (W 0.00965394) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08689 ± 0.000771615 (W 0.00254979) | 1.08648 ± 0.00282217 (W 0.00197029) | 1.5607 ± 0.00510577 (W 0.00455898) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.423188 ± 0.00381857 (W 0.00428085) | 0.427286 ± 0.00412284 (W 0.00481377) | 0.420183 ± 0.00909237 (W 0.00384069) | · | · |  |
| `gemm/4096x16x240/b1` | 0.305739 ± 0.00645675 (W 0.00213164) | 0.305298 ± 0.00477086 (W 0.0018793) | 0.428198 ± 0.00147779 (W 0.00340202) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.301762 ± 0.00185503 (W 0.00165643) | 0.301121 ± 0.000416103 (W 0.00194809) | 0.388312 ± 0.00180409 (W 0.00193605) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.426034 ± 0.00127629 (W 0.00349605) | 0.425342 ± 0.00290127 (W 0.0039908) | 0.264612 ± 0.00526944 (W 0.00284837) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.18765 ± 0.00835195 (W 0.00307742) | 0.187108 ± 0.00581544 (W 0.00243105) | 0.287785 ± 0.000657193 (W 0.0217973) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.203599 ± 0.00178256 (W 0.00973187) | 0.202217 ± 0.00251746 (W 0.00506288) | 0.198789 ± 0.00552008 (W 0.00138859) | · | · | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.01446 ± 0.0214117 (W 0.00198859) | 1.01479 ± 0.0186941 (W 0.00176274) | 2.64977 ± 0.0147158 (W 0.00732851) | · | 🔵 faer-fork 2.61× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.0932 ± 0.00619254 (W 0.00475207) | 1.09443 ± 0.0126166 (W 0.00119806) | 1.5316 ± 0.0201243 (W 0.00921719) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.11643 ± 0.00817472 (W 0.00263957) | 1.11263 ± 0.011214 (W 0.00149881) | 1.24404 ± 0.0179695 (W 0.00306523) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.720662 ± 0.00549448 (W 0.00578667) | 0.718228 ± 0.00627154 (W 0.00378001) | 0.647946 ± 0.00453317 (W 0.00419579) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.296252 ± 0.00523739 (W 0.00282836) | 0.294127 ± 0.00210786 (W 0.00160198) | 0.431263 ± 0.00469725 (W 0.00323895) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.296873 ± 0.00170083 (W 0.00244142) | 0.295691 ± 0.00157358 (W 0.00172531) | 0.330035 ± 0.00261051 (W 0.0020127) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.14278 ± 0.00622966 (W 0.0167595) | 1.12778 ± 0.00808922 (W 0.0173647) | 0.351364 ± 0.0011625 (W 0.00262678) | · | 🔴 faer-fork 3.25× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.179014 ± 0.00212077 (W 0.0029426) | 0.181648 ± 0.00223359 (W 0.00260776) | 0.297234 ± 0.00428231 (W 0.00328604) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.156852 ± 0.000922736 (W 0.000478871) | 0.156421 ± 0.000714282 (W 0.00175188) | 0.173213 ± 0.00117307 (W 0.00188136) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.14499 ± 0.00450305 (W 0.00991846) | 4.138 ± 0.0114794 (W 0.00431135) | 5.72808 ± 0.0267957 (W 0.0167343) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.33792 ± 0.0333893 (W 0.00298458) | 4.34787 ± 0.0246607 (W 0.00741252) | 5.68929 ± 0.341063 (W 0.0276465) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 4.40325 ± 0.0185032 (W 0.00674732) | 4.39917 ± 0.0166055 (W 0.00531996) | 5.23282 ± 0.016047 (W 0.0161046) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.66 ± 0.00534081 (W 0.005407) | 1.66114 ± 0.00570763 (W 0.00416143) | 1.95394 ± 0.0216236 (W 0.00403258) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.14907 ± 0.00655476 (W 0.00377562) | 1.15247 ± 0.00761413 (W 0.00359693) | 2.02192 ± 0.0945989 (W 0.012911) | · | 🔵 faer-fork 1.76× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.1314 ± 0.00354675 (W 0.00218089) | 1.12754 ± 0.0024418 (W 0.0022983) | 2.06093 ± 0.00373466 (W 0.0031814) | · | 🔵 faer-fork 1.82× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.906066 ± 0.00378013 (W 0.0106877) | 0.898243 ± 0.00104362 (W 0.00379263) | 0.947635 ± 0.00303898 (W 0.00472465) | · | · |  |
| `gemm/4096x16x240/b1` | 0.597112 ± 0.00387706 (W 0.00471551) | 0.597152 ± 0.00268649 (W 0.00394372) | 0.985445 ± 0.0122291 (W 0.0047726) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.610847 ± 0.0104831 (W 0.0162393) | 0.616547 ± 0.00767057 (W 0.00728528) | 0.761196 ± 0.0020358 (W 0.00334799) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07597 ± 0.0252231 (W 0.00926441) | 4.06896 ± 0.0186633 (W 0.0129313) | 5.71858 ± 0.0389054 (W 0.0153072) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.37733 ± 0.0165328 (W 0.00501235) | 4.37448 ± 0.00943474 (W 0.00462802) | 5.66584 ± 0.0545087 (W 0.043889) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.43005 ± 0.00396744 (W 0.0111842) | 4.43061 ± 0.00659654 (W 0.00518428) | 5.69388 ± 0.0101368 (W 0.0244617) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.94905 ± 0.00305159 (W 0.00638521) | 1.95151 ± 0.00515023 (W 0.0114782) | 20.8571 ± 4.4364 (W 0.0174882) | · | 🔵 faer-fork 10.70× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.15222 ± 0.00333138 (W 0.00146893) | 1.15603 ± 0.00716181 (W 0.00365746) | 2.3301 ± 0.379162 (W 0.0558243) | · | 🔵 faer-fork 2.02× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 1.17092 ± 0.0117828 (W 0.00558252) | 1.17776 ± 0.0137114 (W 0.00952269) | 2.04531 ± 0.0191434 (W 0.0147534) | · | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.582 ± 0.0376215 (W 0.0238632) | 2.6063 ± 0.0225475 (W 0.0132472) | 4.79264 ± 3.30935 (W 0.0190302) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.601069 ± 0.00290518 (W 0.00444405) | 0.602621 ± 0.00621503 (W 0.00411712) | 1.52962 ± 0.0493473 (W 0.015201) | · | 🔵 faer-fork 2.54× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.576273 ± 0.00523035 (W 0.00385089) | 0.576214 ± 0.00508409 (W 0.00384078) | 1.16249 ± 0.0339767 (W 0.0833649) | · | 🔵 faer-fork 2.02× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12996 ± 0.00670342 (W 0.00222713) | 1.1321 ± 0.00891464 (W 0.00103732) | 1.24236 ± 0.00902189 (W 0.00239923) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.295961 ± 0.0010952 (W 0.00225589) | 0.296281 ± 0.00119231 (W 0.00192007) | 0.331847 ± 0.00340835 (W 0.00226186) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.157213 ± 0.000610329 (W 0.00145577) | 0.157263 ± 0.000801752 (W 0.00139485) | 0.17181 ± 0.00207164 (W 0.00172424) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.089 ± 0.00976062 (W 0.00148017) | 1.09011 ± 0.0105173 (W 0.00172993) | 1.54346 ± 0.0137694 (W 0.0031787) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.30085 ± 0.00171762 (W 0.00340532) | 0.301431 ± 0.00044036 (W 0.00250556) | 0.387962 ± 0.00162347 (W 0.00191374) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.204461 ± 1.24413 (W 0.00804958) | 0.201776 ± 0.00372672 (W 0.00867377) | 0.196847 ± 0.00088946 (W 0.00135991) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.44298 ± 0.000967349 (W 0.0102837) | 4.45042 ± 0.00791736 (W 0.00826977) | 5.77932 ± 0.0350034 (W 0.0272063) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.16957 ± 0.0186402 (W 0.00449497) | 1.16806 ± 0.010675 (W 0.00410765) | 2.06882 ± 0.0179532 (W 0.0139357) | · | 🔵 faer-fork 1.77× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.57436 ± 0.00604801 (W 0.00371577) | 0.57433 ± 0.00350527 (W 0.00392615) | 1.13712 ± 0.0683224 (W 0.0754393) | · | 🔵 faer-fork 1.98× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.40121 ± 0.0193831 (W 0.00378541) | 4.39204 ± 0.0142785 (W 0.00455056) | 5.243 ± 0.0116207 (W 0.00557485) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12916 ± 0.00421233 (W 0.00293154) | 1.1303 ± 0.00675623 (W 0.00323717) | 2.06472 ± 0.0116578 (W 0.00340752) | · | 🔵 faer-fork 1.83× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.616978 ± 0.00327534 (W 0.0166821) | 0.61264 ± 0.00559286 (W 0.0165297) | 0.760737 ± 0.00517361 (W 0.0030036) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016772 ± 0.00118055 (W 3.26696e-05) | 0.014687 ± 9.34719e-05 (W 2.8571e-05) | 0.016932 ± 0.000110395 (W 4.38178e-05) | 🔴 faer-fork 1.14× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.486606 ± 0.00161091 (W 0.00175308) | 0.487578 ± 0.00199895 (W 0.00131323) | 0.394173 ± 0.00134262 (W 0.00175943) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040245 ± 3.84318e-05 (W 7.30972e-05) | 0.040155 ± 0.000126361 (W 6.16944e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040666 ± 0.00015201 (W 9.23038e-05) | 0.040566 ± 0.000241475 (W 9.67068e-05) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.030778 ± 8.02517e-05 (W 0.000176177) | 0.026479 ± 0.000246354 (W 0.0002258) | 0.04272 ± 0.000176693 (W 0.000140663) | 🔴 faer-fork 1.16× slower than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.088966 ± 0.000577375 (W 0.000215518) | 0.130022 ± 0.000162112 (W 0.00102522) | 0.298105 ± 0.133319 (W 0.00131932) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔵 faer-fork 3.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n64/b1` | 0.031388 ± 0.000367375 (W 9.78581e-05) | 0.027461 ± 0.000190788 (W 6.2779e-05) | 0.043221 ± 0.00012108 (W 8.91588e-05) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.916417 ± 0.00437871 (W 0.000650001) | 0.913031 ± 0.0104089 (W 0.00348094) | 0.721133 ± 0.000667028 (W 0.00221908) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.522844 ± 0.00380365 (W 0.00142398) | 0.519117 ± 0.00233437 (W 0.00156622) | 0.266406 ± 0.000666077 (W 0.00138892) | · | 🔴 faer-fork 1.96× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.016711 ± 9.07377e-05 (W 3.14197e-05) | 0.014777 ± 9.49052e-05 (W 3.08594e-05) | 0.016952 ± 9.66454e-05 (W 3.74166e-05) | 🔴 faer-fork 1.13× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.482548 ± 0.00104863 (W 0.00207235) | 0.482268 ± 0.000702598 (W 0.00152298) | 0.272327 ± 0.00094179 (W 0.0018068) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020037 ± 0.00094773 (W 0.000405338) | 0.020418 ± 0.00109932 (W 0.000524095) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020058 ± 2.00083e-05 (W 0.000388717) | 0.020368 ± 0.000248261 (W 0.00053614) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.030717 ± 0.000123452 (W 0.00016484) | 0.030537 ± 0.000576007 (W 0.00114304) | 0.04284 ± 0.000225965 (W 0.000139032) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.089096 ± 6.15386e-05 (W 0.000433014) | 0.204501 ± 0.000731264 (W 0.00191171) | 0.067797 ± 0.000863859 (W 0.000177231) | 🔵 faer-fork 2.30× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.032741 ± 0.000380974 (W 0.000174161) | 0.030998 ± 0.000550001 (W 0.00101631) | 0.04309 ± 4.93288e-05 (W 9.34682e-05) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.911126 ± 0.00434962 (W 0.00313393) | 0.914454 ± 0.00612127 (W 0.003244) | 0.714912 ± 0.00636503 (W 0.00317357) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.517715 ± 0.000557102 (W 0.00268542) | 0.515992 ± 0.00150167 (W 0.00207101) | 0.270835 ± 0.000643291 (W 0.00167836) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014888 ± 0.00119983 (W 0.00174696) | 0.014777 ± 3.23574e-05 (W 3.496e-05) | 0.016792 ± 6.84617e-05 (W 4.57744e-05) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.481416 ± 0.00203524 (W 0.00135757) | 0.487047 ± 0.000333217 (W 0.00171588) | 0.263291 ± 0.0008606 (W 0.00150804) | · | 🔴 faer-fork 1.83× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.015148 ± 0.00101728 (W 0.000337143) | 0.018956 ± 0.000960641 (W 0.000403066) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.016561 ± 0.000271165 (W 0.000464618) | 0.020798 ± 0.000501147 (W 0.000500305) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030767 ± 0.000198747 (W 0.000159857) | 0.030798 ± 0.00037752 (W 0.000304246) | 0.042559 ± 8.5049e-05 (W 0.000146015) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.093334 ± 0.000137477 (W 0.000760576) | 0.243694 ± 0.00400433 (W 0.00175248) | 0.066584 ± 0.000835806 (W 0.000235011) | 🔵 faer-fork 2.61× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.031799 ± 0.000453906 (W 0.000115251) | 0.030988 ± 0.000295838 (W 0.000263004) | 0.04305 ± 4.72582e-05 (W 8.578e-05) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.916357 ± 0.0025775 (W 0.00234744) | 0.922659 ± 0.000672956 (W 0.00257626) | 0.702118 ± 0.0285086 (W 0.00413914) | · | 🔴 faer-fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n64/b1` | 0.515851 ± 0.000583701 (W 0.00178856) | 0.517024 ± 0.00162524 (W 0.00159598) | 0.270504 ± 0.000318172 (W 0.00132475) | · | 🔴 faer-fork 1.91× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014527 ± 3.21455e-05 (W 2.43557e-05) | 0.014357 ± 0.00143865 (W 1.64317e-05) | 0.014196 ± 8.7178e-05 (W 7.5221e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.486996 ± 0.00156943 (W 0.00242617) | 0.486737 ± 0.00129111 (W 0.00169661) | 0.387191 ± 0.00165354 (W 0.0023047) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040325 ± 0.000227172 (W 7.86206e-05) | 0.040144 ± 0.000240791 (W 6.46529e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040506 ± 0.000148987 (W 0.000103586) | 0.040425 ± 0.0002257 (W 0.000121344) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.025448 ± 0.000127307 (W 0.000211219) | 0.025728 ± 0.000401082 (W 0.000178402) | 0.033483 ± 6.84617e-05 (W 7.30363e-05) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.073757 ± 0.000645385 (W 0.000204684) | 0.07534 ± 0.000343896 (W 0.0010727) | 0.289348 ± 0.000164895 (W 0.00119741) | · | 🔵 faer-fork 3.92× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.025488 ± 0.000356525 (W 0.000162248) | 0.026349 ± 0.000202978 (W 0.00140093) | 0.033232 ± 3.78594e-05 (W 6.03017e-05) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.959157 ± 0.00482561 (W 0.000553368) | 0.955089 ± 0.00386112 (W 0.00124229) | 0.69785 ± 0.0052735 (W 0.00207566) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.543372 ± 0.00471836 (W 0.00152706) | 0.540046 ± 0.00279945 (W 0.00163161) | 0.255696 ± 0.000445137 (W 0.00129657) | · | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.01621 ± 0.00106243 (W 3.26833e-05) | 0.014387 ± 3.60555e-05 (W 2.79285e-05) | 0.014146 ± 2.5697e-05 (W 6.39398e-05) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.480555 ± 0.000868312 (W 0.00180781) | 0.481977 ± 0.00318465 (W 0.00216836) | 0.266106 ± 0.000759383 (W 0.00143625) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019426 ± 0.000148561 (W 0.000171318) | 0.018986 ± 0.000559137 (W 0.000205732) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.019676 ± 0.000220636 (W 0.00034259) | 0.019266 ± 0.000168226 (W 0.000169842) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025518 ± 0.000342287 (W 0.000274467) | 0.029225 ± 0.000245907 (W 0.00117629) | 0.033512 ± 0.000137477 (W 0.000101833) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.072385 ± 0.000222361 (W 0.00132993) | 0.144309 ± 0.00118653 (W 0.00149786) | 0.057628 ± 0.000855495 (W 0.00133085) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.026179 ± 0.000580827 (W 9.1833e-05) | 0.029765 ± 0.000587681 (W 0.000147947) | 0.033112 ± 6.65833e-05 (W 0.00137145) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.953334 ± 0.00629527 (W 0.00168057) | 0.959637 ± 0.00553458 (W 0.0027939) | 0.65992 ± 0.00714624 (W 0.00234923) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538493 ± 0.00179219 (W 0.00276454) | 0.538674 ± 0.0016226 (W 0.00189444) | 0.260385 ± 0.00206444 (W 0.00149558) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.014487 ± 0.0012004 (W 4.66905e-05) | 0.014517 ± 0.000111355 (W 4.42775e-05) | 0.014176 ± 4.72582e-05 (W 9.28989e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `eigh/n64/b1` | 0.481827 ± 0.00239742 (W 0.00174145) | 0.484352 ± 0.00161642 (W 0.001393) | 0.256858 ± 0.00127078 (W 0.00158274) | · | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014818 ± 9.07377e-05 (W 0.000345075) | 0.019496 ± 0.000215523 (W 0.000197914) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.015048 ± 0.00017407 (W 0.000155577) | 0.019807 ± 0.000319338 (W 0.000374617) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025648 ± 6.65833e-05 (W 0.000164719) | 0.029926 ± 0.000212166 (W 0.000638793) | 0.033422 ± 0.000165742 (W 0.00015304) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.073938 ± 0.000623692 (W 0.00135885) | 0.185675 ± 0.00178806 (W 0.00181277) | 0.057367 ± 0.000751639 (W 0.00142096) | 🔵 faer-fork 2.51× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.025868 ± 0.000160614 (W 0.000104284) | 0.030326 ± 0.000571371 (W 0.000903569) | 0.033222 ± 9.72471e-05 (W 0.000103867) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.960409 ± 0.00250798 (W 0.00285084) | 0.954489 ± 0.0066588 (W 0.00117193) | 0.657134 ± 0.0121171 (W 0.00311548) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.538423 ± 0.00270102 (W 0.00164117) | 0.53744 ± 0.00228598 (W 0.00232429) | 0.260215 ± 6.71342e-05 (W 0.000990383) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029946 ± 0.000133742 (W 9.86828e-05) | 0.030356 ± 5.27289e-05 (W 0.000128325) | 0.050834 ± 0.000206374 (W 0.000257644) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.65001 ± 0.00196257 (W 0.00755134) | 0.648879 ± 0.00211959 (W 0.00154877) | 0.809047 ± 0.00333694 (W 0.00250818) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.159918 ± 0.000701467 (W 0.00161796) | 0.158676 ± 0.000455472 (W 0.0019647) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159878 ± 0.000706136 (W 0.000385222) | 0.159256 ± 0.000481291 (W 0.000943914) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.058749 ± 0.000183567 (W 0.000196251) | 0.052949 ± 0.00010504 (W 0.00142518) | 0.096449 ± 0.000228685 (W 0.00113293) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.180797 ± 0.000555592 (W 0.00112369) | 0.239035 ± 0.00108861 (W 0.00162445) | 0.166229 ± 5e-05 (W 0.00137585) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `solve/n64/b1` | 0.061274 ± 0.000175214 (W 0.00110627) | 0.054922 ± 0.000666507 (W 0.000500563) | 0.094526 ± 0.000208495 (W 0.00121319) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22839 ± 0.00425708 (W 0.00156043) | 1.22636 ± 0.00360752 (W 0.00180135) | 1.34106 ± 0.000876741 (W 0.0023456) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.659066 ± 0.000412966 (W 0.00152594) | 0.658016 ± 0.000485365 (W 0.0018958) | 0.490874 ± 0.00190321 (W 0.00196948) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030056 ± 0.000121821 (W 6.40312e-05) | 0.030116 ± 0.000127986 (W 4.2957e-05) | 0.051115 ± 0.000134288 (W 0.000281397) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.618162 ± 0.0010959 (W 0.00161885) | 0.619825 ± 0.00118679 (W 0.00174061) | 0.567027 ± 0.000479939 (W 0.00185012) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060943 ± 0.000581333 (W 0.000286041) | 0.061114 ± 7.05006e-05 (W 0.00057324) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.060433 ± 0.000153819 (W 0.00127143) | 0.060993 ± 0.000524592 (W 0.000425146) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.05888 ± 0.000156771 (W 0.000282696) | 0.052699 ± 0.000207534 (W 0.001347) | 0.09661 ± 0.000727006 (W 0.0010424) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.158325 ± 0.000939775 (W 0.00123421) | 0.287876 ± 0.00323321 (W 0.0021829) | 0.164566 ± 0.000297171 (W 0.00123778) | 🔵 faer-fork 1.82× faster than `faer-upstream` | · |  |
| `solve/n64/b1` | 0.061604 ± 0.0002205 (W 0.000121175) | 0.055203 ± 0.000447907 (W 0.000224462) | 0.092913 ± 0.00047762 (W 0.000311802) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.15577 ± 0.000975163 (W 0.00162798) | 1.15854 ± 0.000488973 (W 0.00166612) | 1.09788 ± 0.00717925 (W 0.00584887) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.660539 ± 0.00194353 (W 0.00186058) | 0.657575 ± 0.000774158 (W 0.00144581) | 0.491125 ± 0.000921908 (W 0.0018099) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.030026 ± 3.05505e-05 (W 0.000123896) | 0.030176 ± 5.50757e-05 (W 0.000114586) | 0.051316 ± 0.00042912 (W 0.000248128) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.617339 ± 0.00137542 (W 0.00107064) | 0.619595 ± 0.000997504 (W 0.00148179) | 0.537982 ± 0.0014554 (W 0.00170991) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.037419 ± 0.000203716 (W 0.000385314) | 0.060172 ± 0.00048046 (W 0.00114103) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.03775 ± 0.000544691 (W 0.000559847) | 0.060823 ± 0.000159312 (W 0.000508435) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.05897 ± 0.000190553 (W 0.000177176) | 0.052878 ± 0.00022354 (W 0.000174142) | 0.09636 ± 0.000372089 (W 0.00126114) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.158907 ± 0.000128829 (W 0.000634831) | 0.320356 ± 0.00568363 (W 0.0058131) | 0.163935 ± 0.00036756 (W 0.00117801) | 🔵 faer-fork 2.02× faster than `faer-upstream` | · |  |
| `solve/n64/b1` | 0.061625 ± 0.000195679 (W 8.47838e-05) | 0.055193 ± 0.000461028 (W 6.92763e-05) | 0.093735 ± 0.000263022 (W 0.000404305) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.15205 ± 0.00240806 (W 0.00123422) | 1.16001 ± 0.00215222 (W 0.00154338) | 1.06354 ± 0.0022007 (W 0.00284892) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.660199 ± 0.000967292 (W 0.00185387) | 0.658246 ± 0.00200137 (W 0.00150675) | 0.495182 ± 0.00303845 (W 0.00204586) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029555 ± 6.46555e-05 (W 0.00014099) | 0.029926 ± 0.000126361 (W 7.33485e-05) | 0.043121 ± 0.000403113 (W 7.85188e-05) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.647095 ± 0.00206354 (W 0.00162921) | 0.648669 ± 0.00217827 (W 0.00244664) | 0.800161 ± 0.000347742 (W 0.00243638) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157253 ± 0.000157735 (W 0.0015014) | 0.156913 ± 2.60832e-05 (W 0.00128265) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.157853 ± 0.000293316 (W 0.00163954) | 0.156952 ± 0.000682777 (W 0.00123088) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.051566 ± 5.2915e-05 (W 0.00139771) | 0.051115 ± 0.000130767 (W 0.000152414) | 0.0859 ± 0.0002005 (W 0.00022077) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.162873 ± 0.00125166 (W 0.00113792) | 0.164406 ± 0.00103381 (W 0.00202252) | 0.755157 ± 0.00061275 (W 0.00153085) | · | 🔵 faer-fork 4.64× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.05396 ± 0.000227663 (W 0.000162238) | 0.05333 ± 0.000427069 (W 0.00010895) | 0.083475 ± 0.000200749 (W 0.000186245) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.26006 ± 0.0049614 (W 0.0046727) | 1.25926 ± 0.00346512 (W 0.00226789) | 1.31197 ± 0.00372945 (W 0.00263013) | · | · |  |
| `svd_values/n64/b1` | 0.634672 ± 0.000111894 (W 0.00179493) | 0.632098 ± 0.000573286 (W 0.0021341) | 0.478712 ± 0.00142466 (W 0.00191485) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029565 ± 0.00010504 (W 0.000122556) | 0.029755 ± 5.63057e-05 (W 0.000120291) | 0.043862 ± 0.000657521 (W 0.00204133) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.618572 ± 0.000376277 (W 0.00192039) | 0.619775 ± 0.00107973 (W 0.00171715) | 0.556907 ± 0.000648158 (W 0.00148539) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060973 ± 0.00022926 (W 0.000562519) | 0.060262 ± 0.00059931 (W 0.00136785) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.061444 ± 0.000381912 (W 0.000454842) | 0.060853 ± 0.000392883 (W 0.000400094) | - | · | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.051907 ± 2e-05 (W 0.000861796) | 0.051075 ± 0.000171555 (W 0.000130871) | 0.08585 ± 0.000403031 (W 0.00036651) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.137195 ± 0.00129548 (W 0.00110753) | 0.208508 ± 0.00201081 (W 0.00121654) | 0.155329 ± 0.000188813 (W 0.00140652) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.054401 ± 0.000322568 (W 0.00162419) | 0.053439 ± 0.000183849 (W 0.000113614) | 0.083024 ± 0.000109668 (W 0.00125583) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.18647 ± 0.00129663 (W 0.00179622) | 1.1912 ± 0.000494099 (W 0.00119546) | 1.0113 ± 0.000365955 (W 0.00180011) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.634902 ± 0.00139326 (W 0.00205408) | 0.631075 ± 0.000762709 (W 0.00178423) | 0.480394 ± 0.00193879 (W 0.00171745) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n64/b1` | 0.029675 ± 0.000109697 (W 0.000119307) | 0.029725 ± 0.000180436 (W 3.78061e-05) | 0.043261 ± 0.000278845 (W 0.000104959) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.617509 ± 0.000560088 (W 0.00149502) | 0.621648 ± 0.00156607 (W 0.00170755) | 0.528875 ± 0.00121109 (W 0.00201086) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.038321 ± 0.000210317 (W 0.000542622) | 0.060423 ± 0.000675014 (W 0.000408435) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.038372 ± 0.000301856 (W 0.000360497) | 0.060873 ± 0.000358674 (W 0.000408736) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n64/b1` | 0.051677 ± 0.000476019 (W 8.3709e-05) | 0.051135 ± 0.000297423 (W 0.000155628) | 0.08561 ± 0.0001155 (W 0.0018295) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.139139 ± 0.000726183 (W 0.000548014) | 0.247321 ± 0.00259559 (W 0.0026502) | 0.15541 ± 0.000111447 (W 0.00191661) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `solve/n64/b1` | 0.054291 ± 6.1101e-05 (W 8.40833e-05) | 0.053479 ± 0.000230001 (W 0.00013684) | 0.083005 ± 6.35085e-06 (W 0.00011812) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.17923 ± 0.00249374 (W 0.00166856) | 1.19356 ± 0.00259504 (W 0.00222005) | 0.979313 ± 0.00247336 (W 0.00211918) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.634521 ± 0.000889503 (W 0.00173641) | 0.631617 ± 0.00246826 (W 0.00165132) | 0.481337 ± 0.00324691 (W 0.00173233) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/64`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.388805 ± 0.00248864 (W 0.00281437) | 0.3813 ± 0.00572314 (W 0.00230242) | 0.63888 ± 0.00379649 (W 0.00451614) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.96457 ± 0.0162275 (W 0.0104032) | 9.76409 ± 0.0596811 (W 0.00474684) | 10.0072 ± 0.0423904 (W 0.0138548) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90054 ± 0.00217051 (W 0.00333674) | 1.90517 ± 0.00559159 (W 0.00409444) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.90698 ± 0.00840615 (W 0.00265928) | 1.91692 ± 0.00930806 (W 0.00769414) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.974995 ± 0.117452 (W 0.00288531) | 1.03247 ± 0.0107643 (W 0.00359431) | 0.969657 ± 0.00330792 (W 0.00170095) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.60177 ± 0.011484 (W 0.00245722) | 2.84861 ± 0.00308691 (W 0.0078425) | 2.03857 ± 0.0137339 (W 0.00799099) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.991718 ± 0.00229353 (W 0.00303803) | 1.06128 ± 0.00835105 (W 0.00239201) | 0.966962 ± 0.00241829 (W 0.000999359) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.5259 ± 0.0117565 (W 0.0178576) | 18.4416 ± 0.0112673 (W 0.0272304) | 18.0902 ± 0.0549136 (W 0.052878) | · | · |  |
| `svd_values/n256/b1` | 12.4722 ± 0.0312854 (W 0.0118069) | 12.4908 ± 0.0241305 (W 0.0101039) | 6.95648 ± 0.00258575 (W 0.00766479) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.357676 ± 0.0239879 (W 0.0157693) | 0.359234 ± 0.00143374 (W 0.0163641) | 0.411116 ± 0.00431446 (W 0.00402098) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.99951 ± 0.00808703 (W 0.00956978) | 6.83179 ± 0.0422474 (W 0.00959391) | 4.7761 ± 0.0116543 (W 0.00931672) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.516553 ± 0.00529766 (W 0.00241277) | 0.516712 ± 0.0114915 (W 0.00328542) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.517123 ± 0.000931451 (W 0.00188943) | 0.516392 ± 0.00594727 (W 0.00213184) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.771096 ± 0.00105559 (W 0.00176753) | 0.769754 ± 0.00863632 (W 0.0140644) | 0.377703 ± 0.00202997 (W 0.00203027) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.13529 ± 0.00137147 (W 0.00705729) | 3.07054 ± 0.0264538 (W 0.00988925) | 0.670879 ± 0.000929771 (W 0.00287196) | 🔵 faer-fork 2.70× faster than `faer-upstream` | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.747751 ± 0.00178332 (W 0.00177816) | 0.716505 ± 0.00201257 (W 0.00523084) | 0.369978 ± 0.00282829 (W 0.00247599) | · | 🔴 faer-fork 2.02× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.2637 ± 0.0229153 (W 0.0258743) | 13.2419 ± 0.0448621 (W 0.018635) | 12.5098 ± 0.473925 (W 0.0312433) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 10.4722 ± 0.0159334 (W 0.0177718) | 10.4803 ± 0.0353268 (W 0.00981598) | 6.12092 ± 0.012775 (W 0.00958858) | · | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.33539 ± 0.0297386 (W 0.0227397) | 0.342969 ± 0.0044609 (W 0.0128583) | 0.358052 ± 0.00355812 (W 0.00386438) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.78292 ± 0.02125 (W 0.0190933) | 6.81308 ± 0.0514224 (W 0.0178198) | 4.00514 ± 0.00770752 (W 0.0214504) | · | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.28271 ± 0.00337682 (W 0.0033099) | 0.407294 ± 0.00840375 (W 0.0149823) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.285071 ± 0.00524793 (W 0.00301157) | 0.400225 ± 0.00893128 (W 0.014251) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.772078 ± 0.000851963 (W 0.00227333) | 0.813535 ± 0.00454845 (W 0.0260385) | 0.34893 ± 0.0023504 (W 0.00267462) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 2.21× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.09276 ± 0.00413803 (W 0.00168143) | 3.33984 ± 0.0468775 (W 0.0138094) | 0.579737 ± 0.000500056 (W 0.00333843) | 🔵 faer-fork 3.06× faster than `faer-upstream` | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.747702 ± 0.00379811 (W 0.0019084) | 0.706737 ± 0.0347673 (W 0.0193886) | 0.334653 ± 0.00255339 (W 0.00229002) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 2.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 12.9592 ± 0.0191772 (W 0.0129782) | 13.2784 ± 0.0529526 (W 0.0278908) | 11.4964 ± 0.485221 (W 0.0153785) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 10.5655 ± 0.0230899 (W 0.0145171) | 10.572 ± 0.0263573 (W 0.0155487) | 6.00143 ± 0.0226593 (W 0.0052538) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.322861 ± 0.00530766 (W 0.00239015) | 0.31671 ± 0.00190467 (W 0.0015998) | 0.460528 ± 0.00892004 (W 0.00350348) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.91106 ± 0.0136496 (W 0.00876569) | 9.71689 ± 0.0533136 (W 0.00692159) | 9.835 ± 0.00639016 (W 0.0150132) | · | · |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.86268 ± 0.00227564 (W 0.00415156) | 1.86585 ± 0.0041542 (W 0.00401931) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.89013 ± 0.0070406 (W 0.00465025) | 1.88908 ± 0.00241598 (W 0.00620288) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.692188 ± 0.114143 (W 0.00236263) | 0.702278 ± 0.115163 (W 0.00332328) | 0.815089 ± 0.00337627 (W 0.00398942) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.37519 ± 0.0108066 (W 0.00217767) | 1.38133 ± 0.00215207 (W 0.00213729) | 1.89227 ± 0.00380294 (W 0.00563509) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.900486 ± 0.000539174 (W 0.00310868) | 0.908211 ± 0.00354338 (W 0.00278451) | 0.812123 ± 0.00269018 (W 0.00223048) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4201 ± 0.0121065 (W 0.0169528) | 18.3865 ± 0.0312576 (W 0.0160763) | 17.6816 ± 0.0443165 (W 0.0358215) | · | · |  |
| `svd_values/n256/b1` | 12.2786 ± 0.0482478 (W 0.00951361) | 12.2951 ± 0.0312205 (W 0.0087196) | 6.80783 ± 0.0503806 (W 0.00699973) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.292545 ± 0.00325488 (W 0.0174867) | 0.299568 ± 0.00294803 (W 0.00851243) | 0.242051 ± 0.0196553 (W 0.00369246) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 6.94358 ± 0.00802558 (W 0.00634318) | 6.81163 ± 0.0189631 (W 0.00591161) | 4.66945 ± 0.0130044 (W 0.00588918) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.514258 ± 0.00968645 (W 0.00175359) | 0.517614 ± 0.00545503 (W 0.00199276) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.519007 ± 0.000981703 (W 0.00178649) | 0.519567 ± 0.00165137 (W 0.00182188) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.688572 ± 0.0022489 (W 0.00121814) | 0.640172 ± 0.0111336 (W 0.01038) | 0.332955 ± 0.0041058 (W 0.00338083) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.894409 ± 0.00645064 (W 0.00149498) | 1.3032 ± 0.00719899 (W 0.00468504) | 0.624613 ± 0.0020729 (W 0.00261234) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.658046 ± 0.00316029 (W 0.00237022) | 0.581843 ± 0.00266036 (W 0.00747396) | 0.314295 ± 0.00611482 (W 0.00191774) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔴 faer-fork 2.09× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.1179 ± 0.0197619 (W 0.0111161) | 13.1435 ± 0.0200635 (W 0.0310784) | 12.4339 ± 0.00984786 (W 0.0189988) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.2696 ± 0.0242458 (W 0.0127051) | 10.2922 ± 0.0267893 (W 0.0179895) | 6.12749 ± 0.0204474 (W 0.00704296) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.276619 ± 0.0250642 (W 0.0212069) | 0.284399 ± 0.00201309 (W 0.0219947) | 0.195254 ± 0.0490986 (W 0.00419536) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n256/b1` | 6.7318 ± 0.0112732 (W 0.0210484) | 6.71334 ± 0.0337214 (W 0.012323) | 3.90782 ± 0.0150265 (W 0.0136155) | · | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.281768 ± 0.00227254 (W 0.00223205) | 0.38421 ± 0.00898971 (W 0.0225708) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.285632 ± 0.00114393 (W 0.00236703) | 0.400525 ± 0.00982004 (W 0.0130859) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 0.687471 ± 0.00425183 (W 0.00345961) | 0.631225 ± 0.0277508 (W 0.025162) | 0.315658 ± 0.0069288 (W 0.00184798) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔴 faer-fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.848552 ± 0.0114101 (W 0.00194798) | 1.59852 ± 0.0316981 (W 0.00690301) | 0.549663 ± 0.000971983 (W 0.00272402) | 🔵 faer-fork 1.88× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 0.661361 ± 0.001463 (W 0.00269342) | 0.598274 ± 0.0230992 (W 0.0219333) | 0.302302 ± 0.00220523 (W 0.00340779) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔴 faer-fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 12.8247 ± 0.032606 (W 0.0743741) | 13.1859 ± 0.0195644 (W 0.0193302) | 11.4923 ± 0.0220855 (W 0.0168234) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.3686 ± 0.0218065 (W 0.0100313) | 10.4236 ± 0.0281884 (W 0.00822477) | 6.00026 ± 0.048701 (W 0.00964675) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.22926 ± 0.0165087 (W 0.00373522) | 1.2159 ± 0.00526022 (W 0.00382754) | 1.87087 ± 0.0182262 (W 0.00306731) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.6759 ± 0.0243117 (W 0.0108829) | 17.413 ± 0.0119431 (W 0.00836173) | 26.5487 ± 0.0751507 (W 0.0279613) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49908 ± 0.0162569 (W 0.0153838) | 7.48856 ± 0.0312265 (W 0.0108604) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.53095 ± 0.0149774 (W 0.0112543) | 7.52337 ± 0.0271277 (W 0.00789274) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.12183 ± 0.00060917 (W 0.00243621) | 2.20707 ± 0.000941273 (W 0.00398534) | 3.31023 ± 0.00263251 (W 0.00606004) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.75747 ± 0.0317634 (W 0.00300599) | 6.41454 ± 0.0097441 (W 0.0071601) | 5.68122 ± 0.0108776 (W 0.011063) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.05811 ± 0.000702432 (W 0.0017987) | 2.14715 ± 0.0082738 (W 0.00344444) | 2.82572 ± 0.00540744 (W 0.00440721) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.8445 ± 0.0656832 (W 0.0269501) | 34.8663 ± 0.119319 (W 0.0636606) | 43.792 ± 0.0516883 (W 0.0827634) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 20.0459 ± 0.081447 (W 0.0174572) | 20.0265 ± 0.0267806 (W 0.0224172) | 18.2056 ± 0.0663644 (W 0.0144444) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.82149 ± 0.00352937 (W 0.0066519) | 0.808678 ± 0.00134836 (W 0.00676171) | 0.793308 ± 0.00537737 (W 0.015042) | · | · |  |
| `eigh/n256/b1` | 11.6575 ± 0.0223295 (W 0.0175014) | 11.4455 ± 0.0487516 (W 0.0147121) | 10.1384 ± 0.0123948 (W 0.0138862) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92285 ± 0.00557924 (W 0.00259651) | 1.92388 ± 0.00634601 (W 0.00152298) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92936 ± 0.00237302 (W 0.00207694) | 1.92749 ± 0.00885794 (W 0.00202141) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.49761 ± 0.0138213 (W 0.0182662) | 1.56769 ± 0.00288801 (W 0.00913318) | 1.01851 ± 0.00390962 (W 0.00279618) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.54558 ± 0.00389683 (W 0.00393783) | 4.71671 ± 0.0641933 (W 0.00680189) | 1.63009 ± 0.00711551 (W 0.0032463) | 🔵 faer-fork 1.85× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.39741 ± 0.004589 (W 0.0121585) | 1.43292 ± 0.0107587 (W 0.0107663) | 0.89504 ± 0.00809322 (W 0.00256961) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.4131 ± 0.142628 (W 0.033583) | 22.2846 ± 0.0766486 (W 0.0235378) | 21.2227 ± 0.0605235 (W 0.034011) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.8443 ± 0.166459 (W 0.0196808) | 17.0931 ± 0.0194683 (W 0.0230229) | 11.0338 ± 0.230757 (W 0.0104288) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.808145 ± 0.0163748 (W 0.0219258) | 0.796523 ± 0.010079 (W 0.016998) | 0.658476 ± 0.00398507 (W 0.00273229) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.9252 ± 0.000168111 (W 0.00987544) | 11.219 ± 0.024679 (W 0.0393644) | 7.99199 ± 0.0227045 (W 0.0123944) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00417 ± 0.0063103 (W 0.00420751) | 1.28913 ± 0.101936 (W 0.100887) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.0059 ± 0.00447567 (W 0.00271669) | 1.30447 ± 0.0128154 (W 0.0684507) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.4203 ± 0.00536087 (W 0.00938285) | 1.46669 ± 0.000943634 (W 0.0127153) | 0.695405 ± 0.00248414 (W 0.00324753) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.13056 ± 0.0153774 (W 0.00342475) | 4.79874 ± 0.113132 (W 0.0231925) | 1.627 ± 0.00544446 (W 0.00345726) | 🔵 faer-fork 2.25× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.29811 ± 0.00712539 (W 0.0132916) | 1.3303 ± 0.00209089 (W 0.0115465) | 0.665388 ± 0.00331747 (W 0.00397392) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.1196 ± 0.319283 (W 0.0880801) | 22.0706 ± 0.251801 (W 0.0506751) | 17.3029 ± 0.102453 (W 0.0314032) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.1974 ± 0.0302481 (W 0.0200188) | 17.1957 ± 0.0231499 (W 0.015157) | 9.64433 ± 0.0894753 (W 0.0210264) | · | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 1.13705 ± 0.00220465 (W 0.00111543) | 1.12916 ± 0.00249673 (W 0.00155474) | 1.61972 ± 0.00723462 (W 0.00585357) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.5781 ± 0.012386 (W 0.0111627) | 17.3626 ± 0.0358893 (W 0.0191084) | 26.1624 ± 0.014782 (W 0.0241356) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.43232 ± 0.0305082 (W 0.0055756) | 7.40355 ± 0.0232824 (W 0.00316345) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.44606 ± 0.035822 (W 0.00445273) | 7.44814 ± 0.0298723 (W 0.00605373) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 2.01861 ± 0.00839627 (W 0.00654716) | 1.99658 ± 0.00982016 (W 0.00201892) | 3.14792 ± 0.00847744 (W 0.010937) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.46781 ± 0.0401735 (W 0.00323825) | 4.47851 ± 0.0560001 (W 0.00554335) | 5.53393 ± 0.0362327 (W 0.0203526) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.94488 ± 0.00274591 (W 0.00168899) | 1.93183 ± 0.00153763 (W 0.00099345) | 2.66034 ± 0.0464595 (W 0.0064333) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.5566 ± 0.0286839 (W 0.0248107) | 34.5127 ± 0.0692853 (W 0.0196165) | 43.4466 ± 1.32417 (W 0.0735279) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n256/b1` | 19.73 ± 0.0746527 (W 0.0249513) | 19.722 ± 0.0597013 (W 0.0244938) | 18.0079 ± 1.19849 (W 0.0305592) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.727465 ± 0.0034523 (W 0.007438) | 0.709771 ± 0.00521226 (W 0.00527534) | 0.598264 ± 0.0325676 (W 0.0100493) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 11.5958 ± 0.013432 (W 0.0105225) | 11.3057 ± 0.0142265 (W 0.00567651) | 9.97313 ± 0.00505225 (W 0.0161566) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90683 ± 0.0118284 (W 0.00212204) | 1.90852 ± 0.0116568 (W 0.00195116) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.9226 ± 0.00730103 (W 0.00107626) | 1.92396 ± 0.00863567 (W 0.0017015) | - | · | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.40027 ± 0.0136569 (W 0.0155499) | 1.35586 ± 0.00820821 (W 0.018076) | 0.97204 ± 0.0211484 (W 0.00668841) | · | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.20897 ± 0.0206513 (W 0.0021693) | 2.53593 ± 0.0217441 (W 0.00780997) | 1.57511 ± 0.0249527 (W 0.00428658) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.29079 ± 0.0155252 (W 0.0161977) | 1.25163 ± 0.0115927 (W 0.0103846) | 0.857566 ± 0.0191779 (W 0.00369052) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.1315 ± 0.0408415 (W 0.0184431) | 21.9475 ± 0.123524 (W 0.0443314) | 21.1007 ± 0.629257 (W 0.0291121) | · | · | `!` between-start range over 5% |
| `svd_values/n256/b1` | 16.6895 ± 0.125563 (W 0.0227807) | 16.8517 ± 0.00363068 (W 0.0209926) | 11.033 ± 0.519245 (W 0.0144525) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.706295 ± 0.00437505 (W 0.0086357) | 0.696416 ± 0.00748758 (W 0.00891812) | 0.462853 ± 0.0135204 (W 0.00191761) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n256/b1` | 10.8524 ± 0.0262582 (W 0.0163928) | 11.088 ± 0.0100896 (W 0.0471696) | 7.85431 ± 0.0144996 (W 0.0119947) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00529 ± 0.00544905 (W 0.00262022) | 1.31071 ± 0.00491018 (W 0.0835021) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01118 ± 0.00722471 (W 0.00138063) | 1.31184 ± 0.0182451 (W 0.0776675) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n256/b1` | 1.31704 ± 0.0104588 (W 0.0101049) | 1.26162 ± 0.0044514 (W 0.00975891) | 0.681529 ± 0.00262473 (W 0.00428628) | · | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.80043 ± 0.00948207 (W 0.0029048) | 2.6902 ± 0.0257047 (W 0.0184825) | 1.58448 ± 0.0175919 (W 0.00332933) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `solve/n256/b1` | 1.19102 ± 0.00586468 (W 0.0113576) | 1.13014 ± 0.0115338 (W 0.0125827) | 0.652855 ± 0.00297581 (W 0.00299519) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔴 faer-fork 1.82× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.5706 ± 0.139756 (W 0.17852) | 21.5567 ± 0.16847 (W 0.160487) | 17.2967 ± 0.12543 (W 0.0286076) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.9662 ± 0.0345201 (W 0.0148885) | 16.9551 ± 0.249998 (W 0.0246766) | 9.62556 ± 0.158753 (W 0.0128749) | · | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `householder_apply/256`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.554372 ± 0.000362442 (W 0.00249006) | 0.553848 ± 0.00381965 (W 0.00199686) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.553951 ± 0.00062426 (W 0.0014607) | 0.554713 ± 0.00205748 (W 0.00221093) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.469794 ± 0.00378297 (W 0.00254601) | 0.473381 ± 0.00160101 (W 0.00436768) | 0.662865 ± 0.136255 (W 0.00251407) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.05763 ± 0.00307872 (W 0.00208936) | 1.8592 ± 0.00802214 (W 0.00529202) | 0.906298 ± 0.00143003 (W 0.00135628) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50258 ± 0.00359558 (W 0.00454732) | 2.5109 ± 0.00855956 (W 0.00400032) | 3.05642 ± 0.00506626 (W 0.00376403) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.49444 ± 0.00872858 (W 0.00549316) | 1.49272 ± 0.00262918 (W 0.00595203) | 1.38788 ± 0.151727 (W 0.00437436) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.389084 ± 0.0108076 (W 0.00181326) | 0.158135 ± 0.00165419 (W 0.00134069) | - | 🔴 faer-fork 2.46× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.390578 ± 0.00122294 (W 0.00226745) | 0.157423 ± 0.000973999 (W 0.00124735) | - | 🔴 faer-fork 2.48× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.446982 ± 0.0040462 (W 0.00246637) | 0.427938 ± 0.0100797 (W 0.00431571) | 0.326803 ± 0.0023709 (W 0.00219524) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.00158 ± 0.0114874 (W 0.00199796) | 3.30395 ± 0.165035 (W 0.089543) | 0.459736 ± 0.00381395 (W 0.00779573) | 🔵 faer-fork 3.30× faster than `faer-upstream` | 🔴 faer-fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.28297 ± 0.00143959 (W 0.00588743) | 2.14817 ± 0.00293345 (W 0.00646238) | 2.15968 ± 0.0952991 (W 0.0106039) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.43854 ± 0.00800972 (W 0.00652159) | 1.54121 ± 0.00285089 (W 0.00496774) | 0.948767 ± 0.161008 (W 0.00647236) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.40007 ± 0.00386806 (W 0.00558921) | 0.143347 ± 0.00350642 (W 0.00711291) | - | 🔴 faer-fork 2.79× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.415454 ± 0.0108348 (W 0.00661934) | 0.146182 ± 0.000788738 (W 0.00697338) | - | 🔴 faer-fork 2.84× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.443536 ± 0.00108499 (W 0.00184152) | 0.430637 ± 0.00588485 (W 0.00440987) | 0.312592 ± 0.000881678 (W 0.00168366) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.05269 ± 0.00877271 (W 0.00325028) | 3.13144 ± 0.218731 (W 0.0796653) | 0.320961 ± 0.000525382 (W 0.00174215) | 🔵 faer-fork 2.97× faster than `faer-upstream` | 🔴 faer-fork 3.28× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/1024x64/b1` | 2.36343 ± 0.00232459 (W 0.00307442) | 2.2431 ± 0.00277677 (W 0.00567211) | 1.67497 ± 0.282715 (W 0.00791304) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.48861 ± 0.00647712 (W 0.00354576) | 1.62229 ± 0.00459999 (W 0.00725668) | 0.815057 ± 0.183583 (W 0.00322837) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.83× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.572647 ± 0.0132862 (W 0.00209058) | 0.59041 ± 0.00897078 (W 0.00210553) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.572076 ± 0.0137896 (W 0.0017376) | 0.575131 ± 0.0131199 (W 0.00174402) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.384456 ± 0.00192141 (W 0.00196348) | 0.382663 ± 0.00268701 (W 0.00300022) | 0.286037 ± 0.000802043 (W 0.0017742) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.774492 ± 0.00194406 (W 0.00287783) | 0.775564 ± 0.012811 (W 0.00278431) | 0.763212 ± 0.000826366 (W 0.00335088) | · | · |  |
| `svd_thin/1024x64/b1` | 2.44989 ± 0.00212349 (W 0.00239602) | 2.44909 ± 0.00571463 (W 0.00324975) | 2.80444 ± 0.00661499 (W 0.00585848) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.40094 ± 0.00260427 (W 0.00368044) | 1.39893 ± 0.00164666 (W 0.00262629) | 1.23804 ± 0.00244114 (W 0.00458715) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.424751 ± 0.010419 (W 0.00132782) | 0.197868 ± 0.0163339 (W 0.00159825) | - | 🔴 faer-fork 2.15× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.424055 ± 0.0115375 (W 0.00159895) | 0.195957 ± 0.0147572 (W 0.0013081) | - | 🔴 faer-fork 2.16× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.362474 ± 0.00320106 (W 0.00199704) | 0.355443 ± 0.00156677 (W 0.00230097) | 0.286323 ± 0.00225202 (W 0.00189157) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.739337 ± 0.0091908 (W 0.00198303) | 0.834695 ± 0.00491429 (W 0.00303947) | 0.421766 ± 0.00448564 (W 0.0085469) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.23174 ± 0.00436558 (W 0.00332289) | 2.09509 ± 0.0073672 (W 0.00323299) | 1.82286 ± 0.00435815 (W 0.00851164) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.35718 ± 0.00321175 (W 0.0035302) | 1.45006 ± 0.00766907 (W 0.0031123) | 0.913462 ± 0.00405112 (W 0.00634807) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.439543 ± 0.00859553 (W 0.0070393) | 0.188872 ± 0.00735229 (W 0.00489798) | - | 🔴 faer-fork 2.33× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.439945 ± 0.0123793 (W 0.00402904) | 0.185325 ± 0.0136691 (W 0.006091) | - | 🔴 faer-fork 2.37× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.361394 ± 0.00252611 (W 0.00308621) | 0.353158 ± 0.00103395 (W 0.00143255) | 0.28772 ± 0.00126655 (W 0.00214921) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.778911 ± 0.00411269 (W 0.00222725) | 0.910186 ± 0.00908822 (W 0.00320567) | 0.303154 ± 0.00271701 (W 0.00222013) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 2.57× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.31239 ± 0.00619663 (W 0.00449774) | 2.17929 ± 0.00344886 (W 0.00768009) | 1.63207 ± 0.00175627 (W 0.00486846) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.40685 ± 0.00782622 (W 0.00372635) | 1.53231 ± 0.00124154 (W 0.00534101) | 0.788979 ± 0.00354366 (W 0.00317771) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19833 ± 0.00714321 (W 0.00550893) | 2.20608 ± 0.0267148 (W 0.0033688) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20452 ± 0.00408179 (W 0.00270001) | 2.20287 ± 0.0258615 (W 0.00238454) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.990087 ± 0.00190295 (W 0.00198223) | 0.997186 ± 0.00354965 (W 0.00189726) | 1.23168 ± 0.23341 (W 0.00266478) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 2.55546 ± 0.0460814 (W 0.0040107) | 4.06887 ± 0.0521195 (W 0.0153718) | 2.4016 ± 0.0154899 (W 0.00293648) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.99403 ± 0.00548432 (W 0.0105112) | 5.99418 ± 0.00303643 (W 0.00648012) | 9.61909 ± 0.160495 (W 0.0171534) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.08709 ± 0.0122365 (W 0.00438251) | 3.08489 ± 0.0173704 (W 0.00409977) | 3.80718 ± 0.0152885 (W 0.0069891) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.39706 ± 0.0210151 (W 0.00093499) | 0.594728 ± 0.00260254 (W 0.00228262) | - | 🔴 faer-fork 2.35× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.39958 ± 0.00624812 (W 0.00231132) | 0.575271 ± 0.0139335 (W 0.000687328) | - | 🔴 faer-fork 2.43× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.747292 ± 0.00141673 (W 0.0045845) | 0.739947 ± 0.00658569 (W 0.00192553) | 1.40409 ± 0.00112551 (W 0.0109925) | · | 🔵 faer-fork 1.88× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.3133 ± 0.00786518 (W 0.00435191) | 4.04991 ± 0.129302 (W 0.0395056) | 1.37795 ± 0.00283008 (W 0.00312819) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 1.68× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 4.95059 ± 0.0111548 (W 0.0108361) | 3.69086 ± 0.0137236 (W 0.00414237) | 5.4728 ± 0.0241433 (W 0.00528003) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.86394 ± 0.00408915 (W 0.00326509) | 2.45552 ± 0.0345572 (W 0.00334124) | 2.81766 ± 0.224666 (W 0.0324958) | 🔴 faer-fork 1.17× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.34904 ± 0.0449658 (W 0.0314055) | 0.474383 ± 0.0447484 (W 0.0408688) | - | 🔴 faer-fork 2.84× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.3775 ± 0.020116 (W 0.0325615) | 0.473547 ± 0.0431409 (W 0.0417885) | - | 🔴 faer-fork 2.91× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.706013 ± 0.00319186 (W 0.00167858) | 0.699012 ± 0.00547985 (W 0.00215128) | 1.47741 ± 0.0066412 (W 0.00557371) | · | 🔵 faer-fork 2.09× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.3726 ± 0.00928724 (W 0.0121227) | 3.94473 ± 0.143198 (W 0.0492284) | 0.870552 ± 0.00245318 (W 0.00222218) | 🔵 faer-fork 1.66× faster than `faer-upstream` | 🔴 faer-fork 2.73× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 4.95002 ± 0.0312092 (W 0.130405) | 3.7002 ± 0.01345 (W 0.028271) | 4.40745 ± 0.018039 (W 0.0160755) | 🔴 faer-fork 1.34× slower than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.9191 ± 0.028661 (W 0.00642182) | 2.49427 ± 0.0095246 (W 0.0083655) | 2.77405 ± 0.291617 (W 0.0154903) | 🔴 faer-fork 1.17× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26243 ± 0.00506436 (W 0.00226056) | 2.26836 ± 0.0125869 (W 0.00596627) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.25782 ± 0.0168894 (W 0.00175569) | 2.26292 ± 0.00949036 (W 0.00225909) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.872967 ± 0.00177484 (W 0.001976) | 0.870341 ± 0.00201788 (W 0.000790058) | 1.08813 ± 0.0137742 (W 0.00194589) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.2576 ± 0.0163691 (W 0.00208977) | 2.25619 ± 0.0398697 (W 0.00419524) | 2.26358 ± 0.00907886 (W 0.00480288) | · | · |  |
| `svd_thin/1024x64/b1` | 5.88895 ± 0.0096641 (W 0.0113519) | 5.89028 ± 0.00707509 (W 0.00402488) | 8.5705 ± 0.0225238 (W 0.0167077) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.9597 ± 0.0101568 (W 0.00183763) | 2.95429 ± 0.0209366 (W 0.003267) | 3.66937 ± 0.0121292 (W 0.0045392) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.4535 ± 0.0107479 (W 0.00196352) | 0.636787 ± 0.0105155 (W 0.00268015) | - | 🔴 faer-fork 2.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.43643 ± 0.0112935 (W 0.00316878) | 0.618041 ± 0.0134038 (W 0.00278888) | - | 🔴 faer-fork 2.32× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.638189 ± 0.00103167 (W 0.00282689) | 0.637716 ± 0.000670119 (W 0.00267597) | 1.07331 ± 0.0242661 (W 0.0022377) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.03387 ± 0.0264161 (W 0.00437942) | 1.58663 ± 0.0197697 (W 0.00570983) | 1.34172 ± 0.00998915 (W 0.00333155) | 🔴 faer-fork 1.28× slower than `faer-upstream` | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.83664 ± 0.0103654 (W 0.00519509) | 3.58455 ± 0.00874543 (W 0.00421359) | 5.42467 ± 0.0310577 (W 0.00921079) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.77317 ± 0.00151123 (W 0.0034236) | 2.35159 ± 0.00150298 (W 0.00730566) | 2.80009 ± 0.017516 (W 0.0093314) | 🔴 faer-fork 1.18× slower than `faer-upstream` | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.36372 ± 0.00453194 (W 0.0396654) | 0.530297 ± 0.0462742 (W 0.0473116) | - | 🔴 faer-fork 2.57× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.36497 ± 0.0421481 (W 0.0344007) | 0.450519 ± 0.0463358 (W 0.0466804) | - | 🔴 faer-fork 3.03× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.594815 ± 0.00231451 (W 0.00266695) | 0.59745 ± 0.000767862 (W 0.00265934) | 1.09465 ± 0.0227766 (W 0.00266857) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.05702 ± 0.0211308 (W 0.0093573) | 1.63766 ± 0.02561 (W 0.00720598) | 0.857267 ± 0.00572305 (W 0.00144627) | 🔴 faer-fork 1.26× slower than `faer-upstream` | 🔴 faer-fork 2.40× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.86739 ± 0.141842 (W 0.266417) | 3.6099 ± 0.0141404 (W 0.138742) | 4.39364 ± 0.0141591 (W 0.0149391) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.82286 ± 0.00612309 (W 0.00636093) | 2.39253 ± 0.00737464 (W 0.0119435) | 2.29428 ± 0.00941654 (W 0.00472043) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `eigh/1024x64`, `householder_apply/1024x64`, `solve/1024x64`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.393283 ± 0.000293005 (W 0.00353525) | 0.509786 ± 0.00273677 (W 0.00223667) | 0.924391 ± 0.136074 (W 0.00269093) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 2.35× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.999793 ± 0.00795632 (W 0.00350079) | 1.01764 ± 0.0070438 (W 0.00545442) | 1.34624 ± 0.0033243 (W 0.00372942) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.44934 ± 0.000686583 (W 0.00528377) | 2.4474 ± 0.0028668 (W 0.00586262) | 4.12597 ± 0.00376055 (W 0.00502986) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.41349 ± 0.00225092 (W 0.00294777) | 1.41187 ± 0.000766082 (W 0.00257433) | 2.6044 ± 0.0187152 (W 0.0082819) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.234467 ± 0.00973298 (W 0.0162165) | 0.34902 ± 0.027224 (W 0.0164178) | 0.301281 ± 0.0137899 (W 0.00274226) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.613022 ± 0.00341526 (W 0.00893731) | 0.689061 ± 0.00496479 (W 0.00430183) | 0.430667 ± 0.00273069 (W 0.0022687) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.22582 ± 0.00097548 (W 0.00268011) | 2.09629 ± 0.00444772 (W 0.00209267) | 3.05541 ± 0.2268 (W 0.0200709) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.36855 ± 0.00213395 (W 0.00450168) | 1.46424 ± 0.00207496 (W 0.00335878) | 2.0945 ± 0.0100548 (W 0.00570052) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.21507 ± 0.00165095 (W 0.00450832) | 0.338815 ± 0.00833103 (W 0.00363371) | 0.170689 ± 0.00219315 (W 0.00132817) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.55018 ± 0.0033899 (W 0.00515446) | 0.737965 ± 0.00169466 (W 0.00660941) | 0.258462 ± 0.00212913 (W 0.00188354) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.30924 ± 0.00355998 (W 0.00471292) | 2.185 ± 0.00537066 (W 0.00866171) | 3.22153 ± 0.0066733 (W 0.0164114) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.41587 ± 0.00417655 (W 0.00223533) | 1.55179 ± 0.007128 (W 0.00465939) | 2.0795 ± 0.00811846 (W 0.00483585) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.312713 ± 0.000317849 (W 0.00240811) | 0.312232 ± 0.000825553 (W 0.00183585) | 3.13476 ± 0.00310458 (W 0.0024669) | · | 🔵 faer-fork 10.02× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.561595 ± 0.00172289 (W 0.00205526) | 0.561877 ± 0.00157755 (W 0.00183291) | 6.30136 ± 0.00206591 (W 0.00333204) | · | 🔵 faer-fork 11.22× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.51334 ± 0.00236554 (W 0.00516932) | 2.51491 ± 0.00488581 (W 0.00193574) | 3.86436 ± 0.0284553 (W 0.00746355) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.47386 ± 0.00190577 (W 0.00500874) | 1.47315 ± 0.0056579 (W 0.00333417) | 2.43017 ± 0.020969 (W 0.00343088) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.149289 ± 0.00101682 (W 0.0156764) | 0.157493 ± 0.00507894 (W 0.021524) | 0.245898 ± 0.00749328 (W 0.00361988) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.65× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.203742 ± 0.00214498 (W 0.00140043) | 0.260705 ± 0.00259693 (W 0.0014805) | 0.369498 ± 0.00155941 (W 0.00273444) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.81× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.29484 ± 0.0133534 (W 0.00527939) | 2.16271 ± 0.00911185 (W 0.00357687) | 3.02734 ± 0.06369 (W 0.00874151) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.42276 ± 0.0182347 (W 0.00372441) | 1.51403 ± 0.00772813 (W 0.00622806) | 2.04581 ± 0.0466986 (W 0.00717063) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.124393 ± 0.000613244 (W 0.00587061) | 0.136906 ± 0.000742781 (W 0.0030395) | 0.135282 ± 0.00178136 (W 0.00218867) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.159258 ± 0.00156333 (W 0.00112445) | 0.317211 ± 0.00315838 (W 0.0049903) | 0.21906 ± 0.00182869 (W 0.00164373) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.37302 ± 0.00626517 (W 0.00562126) | 2.24731 ± 0.00643093 (W 0.00549612) | 2.89173 ± 0.0852212 (W 0.0104189) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.46607 ± 0.00162021 (W 0.0061621) | 1.60041 ± 0.0128085 (W 0.00572415) | 2.06118 ± 0.0269822 (W 0.00469526) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 1.00291 ± 0.00471652 (W 0.0036312) | 1.05321 ± 0.0261203 (W 0.00252164) | 2.33329 ± 0.0243928 (W 0.00204664) | · | 🔵 faer-fork 2.33× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.56648 ± 0.0112062 (W 0.00561097) | 2.60488 ± 0.00988347 (W 0.00445889) | 3.54679 ± 0.041983 (W 0.0038625) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.95196 ± 0.0221101 (W 0.00363498) | 5.91669 ± 0.0276948 (W 0.00254743) | 12.8758 ± 0.148706 (W 0.0943611) | · | 🔵 faer-fork 2.16× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.94473 ± 0.0217959 (W 0.00455578) | 2.95299 ± 0.0194584 (W 0.00285184) | 5.59199 ± 0.0272667 (W 0.0202189) | · | 🔵 faer-fork 1.90× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.442098 ± 0.00343964 (W 0.0660157) | 0.512581 ± 0.07033 (W 0.0486445) | 0.947155 ± 0.178288 (W 0.0071379) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 2.14× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.982631 ± 0.00441758 (W 0.00609124) | 1.07024 ± 0.00642988 (W 0.00471983) | 1.35886 ± 0.000405766 (W 0.00483626) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.86399 ± 0.00689591 (W 0.00487576) | 3.61451 ± 0.00582675 (W 0.0109877) | 7.84271 ± 0.268396 (W 0.0609748) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.61× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.77186 ± 0.00212959 (W 0.00230158) | 2.34418 ± 0.00832267 (W 0.00373586) | 3.74504 ± 0.0644228 (W 0.00872215) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.391183 ± 0.00493489 (W 0.0181547) | 0.441493 ± 0.00467985 (W 0.00446223) | 0.762208 ± 0.00359588 (W 0.00432761) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.95× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.723205 ± 0.00304632 (W 0.00367138) | 1.02525 ± 0.00761277 (W 0.0150812) | 0.771226 ± 0.00659731 (W 0.00177625) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.8877 ± 0.00357515 (W 0.27139) | 3.60946 ± 0.0164936 (W 0.0304688) | 6.20928 ± 0.178712 (W 0.0218803) | 🔴 faer-fork 1.35× slower than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.81756 ± 0.00939586 (W 0.00773819) | 2.393 ± 0.00805359 (W 0.00765873) | 3.24079 ± 0.0402771 (W 0.0146274) | 🔴 faer-fork 1.18× slower than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.893374 ± 0.000977747 (W 0.00274048) | 0.893274 ± 0.00112263 (W 0.00142981) | 2.12384 ± 0.00140283 (W 0.00130577) | · | 🔵 faer-fork 2.38× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.21762 ± 0.00221891 (W 0.00260022) | 2.21808 ± 0.00864628 (W 0.00372612) | 16.8716 ± 0.0136619 (W 0.0123114) | · | 🔵 faer-fork 7.61× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 6.06952 ± 0.0328107 (W 0.00580331) | 6.04021 ± 0.0178697 (W 0.00390751) | 11.7602 ± 0.245346 (W 0.0189479) | · | 🔵 faer-fork 1.94× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 3.08088 ± 0.0149877 (W 0.00287265) | 3.08177 ± 0.0229389 (W 0.0040904) | 5.33303 ± 0.105237 (W 0.0166296) | · | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.334427 ± 0.03829 (W 0.042823) | 0.33301 ± 0.0516112 (W 0.0654771) | 0.582224 ± 0.00940667 (W 0.00392983) | · | 🔵 faer-fork 1.74× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/64x1024/b1` | 0.670368 ± 0.00110069 (W 0.00100626) | 0.718659 ± 0.00261383 (W 0.00212396) | 1.28494 ± 0.00105911 (W 0.00405775) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.92× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.98964 ± 0.00747032 (W 0.00423826) | 3.73788 ± 0.00388476 (W 0.00428345) | 7.46093 ± 0.26951 (W 0.0280736) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.87393 ± 0.00401325 (W 0.00359815) | 2.44852 ± 0.000800258 (W 0.00524423) | 3.72631 ± 0.0390591 (W 0.00796549) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `lu/64x1024/b1` | 0.27729 ± 0.00565785 (W 0.0209134) | 0.277667 ± 0.00166945 (W 0.0143747) | 0.407904 ± 0.00547661 (W 0.00285277) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.422066 ± 0.00252988 (W 0.00198128) | 0.677902 ± 0.00140543 (W 0.0167922) | 0.709669 ± 0.00121319 (W 0.00174485) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.99989 ± 0.0195751 (W 0.033974) | 3.74799 ± 0.0105297 (W 0.283793) | 6.30123 ± 0.110895 (W 0.0107217) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.90795 ± 0.0139614 (W 0.00593128) | 2.48305 ± 0.00416263 (W 0.0089753) | 3.28066 ± 0.0622007 (W 0.019036) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/64x1024`, `eigh/64x1024`, `solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
