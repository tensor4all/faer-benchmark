# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `3a8edf02b82eb6c69362799591e0a970c4ceb8d3`
- t4a-faer version: `0.27.1`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `15cd9ab20a818e48f09156324aa0df83e07a6354`
- toolkit commit: `b71624bef111ce941bddaedcce3fdb6eab40f9eb`
- measured binary SHA-256: `1ff1d5f2582afb1da8d206a6ae03ef7fe443f186e14eaf1e526a6f2eb214ea4d`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-30T19:49:59.020039Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label weekly-20261030-mkl --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261030T174024Z-weekly-20261030-mkl/`

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
    As measured: linked shared; mkl 2026.2; kernel not reported by the vendor

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.95%, worst 14544.39% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 335 of 3684 engine cells exceed 5% and carry `!`; median within-process relative SD 0.43%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.002334 ± 1.58219e-05 (W 1.81191e-05) | 0.002334 ± 1.1547e-05 (W 1.59154e-05) | 0.004468 ± 1.73205e-05 (W 5.85508e-05) | · | 🔵 faer-fork 1.91× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017111 ± 1.48436e-05 (W 2.9416e-05) | 0.017062 ± 1.1547e-05 (W 2.36685e-05) | 0.024155 ± 2.51661e-05 (W 3.36927e-05) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056786 ± 0.000139097 (W 0.000153646) | 0.056716 ± 0.000245495 (W 4.14729e-05) | 0.062646 ± 0.000128946 (W 6.56597e-05) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002404 ± 2.08167e-05 (W 2.53239e-05) | 0.003967 ± 0.000185041 (W 0.00012283) | 0.00552 ± 0.000324146 (W 0.000121788) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 2.30× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.011181 ± 0.000132035 (W 5.88405e-05) | 0.019706 ± 0.000545878 (W 0.00159158) | 0.013896 ± 0.00024392 (W 0.000139972) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.023133 ± 0.00022786 (W 0.000552862) | 0.063798 ± 0.000698058 (W 0.0031684) | 0.022262 ± 6.07481e-05 (W 0.000134336) | 🔵 faer-fork 2.76× faster than `faer-upstream` | · |  |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002405 ± 1.70392e-05 (W 2.50859e-05) | 0.004148 ± 2.46374e-05 (W 0.000238464) | 0.004608 ± 0.000180408 (W 0.000200413) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔵 faer-fork 1.92× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.009879 ± 8.02932e-05 (W 5.32475e-05) | 0.01079 ± 0.000147309 (W 0.000217969) | 0.009487 ± 0.000101737 (W 0.000159563) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.020368 ± 4.58258e-05 (W 0.000101688) | 0.021199 ± 0.000300245 (W 0.000175762) | 0.014707 ± 0.000180666 (W 0.000170442) | · | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002345 ± 2.64575e-05 (W 1.44326e-05) | 0.002344 ± 2.95014e-05 (W 2.07196e-05) | 0.004448 ± 1.48436e-05 (W 1.66223e-05) | · | 🔵 faer-fork 1.90× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017132 ± 1.18462e-05 (W 2.89689e-05) | 0.017122 ± 2.5697e-05 (W 1.81659e-05) | 0.024205 ± 4.09512e-05 (W 2.91548e-05) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056826 ± 0.000171553 (W 0.000319108) | 0.056826 ± 0.000226321 (W 6.38295e-05) | 0.062878 ± 0.000303976 (W 0.000136196) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002405 ± 1.48436e-05 (W 1.9857e-05) | 0.003938 ± 0.000158336 (W 0.000219791) | 0.00514 ± 0.000139177 (W 8.47485e-05) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔵 faer-fork 2.14× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.011191 ± 8.77895e-05 (W 0.000136508) | 0.019637 ± 0.00116522 (W 0.00127059) | 0.013796 ± 0.000285832 (W 0.000155523) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.022953 ± 0.000238106 (W 0.000575197) | 0.063459 ± 0.00101467 (W 0.00119948) | 0.022401 ± 0.000113873 (W 0.000123888) | 🔵 faer-fork 2.76× faster than `faer-upstream` | · |  |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002414 ± 2.00083e-05 (W 1.89816e-05) | 0.004198 ± 8.544e-05 (W 0.000225868) | 0.004479 ± 0.000179536 (W 0.000107871) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔵 faer-fork 1.86× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.009779 ± 7.54343e-05 (W 5.82769e-05) | 0.010941 ± 0.000182045 (W 0.000297718) | 0.009859 ± 0.000323483 (W 0.000105206) | 🔵 faer-fork 1.12× faster than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.020308 ± 7.37111e-05 (W 6.22093e-05) | 0.02139 ± 2.08167e-05 (W 0.000202905) | 0.014918 ± 9.65419e-05 (W 0.000193303) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008826 ± 0.000100732 (W 1.64317e-05) | 0.008766 ± 4.04145e-05 (W 2.09809e-05) | 0.011171 ± 4.04145e-05 (W 0.000119457) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067846 ± 0.000237502 (W 0.00164252) | 0.067907 ± 5.7977e-05 (W 0.0016482) | 0.081732 ± 0.00019 (W 0.00139123) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.225992 ± 0.000861589 (W 0.00160212) | 0.227014 ± 0.00109354 (W 0.0017406) | 0.275044 ± 0.0011655 (W 0.0052624) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.009898 ± 0.000179574 (W 0.000211342) | 0.008786 ± 1.52753e-05 (W 2.09595e-05) | 0.013305 ± 0.000216288 (W 0.000104591) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.029164 ± 2.3094e-05 (W 0.000409614) | 0.039844 ± 0.000651731 (W 0.00111171) | 0.035716 ± 0.00029541 (W 0.000366288) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.078005 ± 0.00070071 (W 0.000686915) | 0.098181 ± 0.000648454 (W 0.00169282) | 0.097392 ± 0.000473456 (W 0.00112681) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.010019 ± 6.05007e-05 (W 7.20784e-05) | 0.008877 ± 6.08276e-06 (W 1.67332e-05) | 0.022492 ± 0.000168573 (W 0.000134934) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 2.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.02687 ± 0.000136346 (W 8.65292e-05) | 0.027712 ± 0.000161091 (W 0.000232087) | 0.01603 ± 0.000172879 (W 0.000130527) | · | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.039924 ± 0.00020306 (W 6.53452e-05) | 0.040566 ± 0.000308594 (W 0.000234073) | 0.042779 ± 0.0001948 (W 0.000285509) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008766 ± 4.2194e-05 (W 1.33116e-05) | 0.008806 ± 5.61278e-05 (W 2.32422e-05) | 0.01106 ± 9.13072e-05 (W 8.31763e-05) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067826 ± 6.37992e-05 (W 0.00151469) | 0.067847 ± 0.000121496 (W 6.18061e-05) | 0.084215 ± 0.000704398 (W 0.00173433) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226633 ± 0.000948241 (W 0.0015952) | 0.227183 ± 0.000413892 (W 0.00169857) | 0.266634 ± 0.00213055 (W 0.00494327) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.009778 ± 0.000187751 (W 4.40829e-05) | 0.008846 ± 6.60328e-05 (W 3.62533e-05) | 0.013304 ± 0.000543514 (W 7.8613e-05) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.028874 ± 0.000142163 (W 0.000217745) | 0.039353 ± 0.00110305 (W 0.00166028) | 0.035986 ± 0.000720223 (W 0.000440496) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.078245 ± 0.000433163 (W 0.000688205) | 0.095629 ± 0.00290132 (W 0.00323289) | 0.096238 ± 0.00147254 (W 0.00157421) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.009929 ± 5.50757e-05 (W 6.95723e-05) | 0.008796 ± 6.10765e-05 (W 1.67332e-05) | 0.022372 ± 0.000222442 (W 0.000166973) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 2.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.02699 ± 0.000130908 (W 8.95059e-05) | 0.027822 ± 0.000175519 (W 0.000235203) | 0.016 ± 0.000245386 (W 0.000162367) | · | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.039634 ± 0.00010843 (W 6.72309e-05) | 0.040826 ± 6.35085e-05 (W 0.00085739) | 0.04293 ± 0.00031585 (W 0.000384014) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.132986 ± 0.0013415 (W 0.00012227) | 0.132928 ± 0.000543175 (W 8.5943e-05) | 0.168825 ± 0.000753719 (W 0.00177572) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.452889 ± 0.00514129 (W 0.00224512) | 0.449609 ± 0.00209227 (W 0.00240567) | 0.486027 ± 0.00295198 (W 0.00223053) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07072 ± 0.00616127 (W 0.00245061) | 1.0738 ± 0.00350279 (W 0.000789068) | 1.20619 ± 0.00743593 (W 0.00220818) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.61234 ± 0.0186169 (W 0.00580429) | 3.60072 ± 0.0113944 (W 0.00313506) | 3.72759 ± 0.0175428 (W 0.00456311) | · | · |  |
| `gemm/512x512x512/b1` | 8.59743 ± 0.0491599 (W 0.0135259) | 8.59237 ± 0.0217472 (W 0.0145435) | 9.90141 ± 0.0263609 (W 0.0134496) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.3278 ± 0.079625 (W 0.0312079) | 29.2272 ± 0.120642 (W 0.0278778) | 30.4037 ± 0.0955303 (W 0.0373276) | · | · |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.045424 ± 7.26659e-05 (W 0.000296032) | 0.072575 ± 0.00283954 (W 0.0130088) | 0.055684 ± 0.000225345 (W 0.000234244) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.120413 ± 0.000801313 (W 0.00138551) | 0.159237 ± 0.00149459 (W 0.00345925) | 0.136434 ± 0.00111066 (W 0.00116081) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 0.290198 ± 0.00016809 (W 0.00203482) | 0.309858 ± 0.00436504 (W 0.00718386) | 0.345064 ± 0.0028447 (W 0.00238691) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.915025 ± 0.00200516 (W 0.00231012) | 0.91659 ± 0.00529138 (W 0.00246888) | 1.00467 ± 0.00576442 (W 0.00264966) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.20193 ± 0.00586603 (W 0.00582133) | 2.20366 ± 0.00249915 (W 0.0029625) | 2.85155 ± 0.108629 (W 0.00804078) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.50717 ± 0.0199889 (W 0.00831077) | 7.49527 ± 0.0264824 (W 0.0059832) | 8.49217 ± 0.0327067 (W 0.00876679) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.032651 ± 0.000319324 (W 0.00111334) | 0.111977 ± 0.00121532 (W 0.0209483) | 0.031429 ± 6.69104e-05 (W 0.000174356) | 🔵 faer-fork 3.43× faster than `faer-upstream` | · |  |
| `gemm/192x192x192/b1` | 0.085979 ± 0.000976426 (W 0.00135896) | 0.182868 ± 0.0292329 (W 0.0299356) | 0.074909 ± 0.000547977 (W 0.000211472) | 🔵 faer-fork 2.13× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.164517 ± 0.00326418 (W 0.00214954) | 0.232892 ± 0.0104992 (W 0.0223392) | 0.178673 ± 0.000166016 (W 0.00220689) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.48068 ± 0.00341236 (W 0.00432051) | 0.560816 ± 0.004459 (W 0.00406965) | 0.51757 ± 0.00478071 (W 0.00227841) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.14433 ± 0.00448137 (W 0.00326574) | 1.19196 ± 0.00217856 (W 0.0049454) | 1.50643 ± 0.0304454 (W 0.0041094) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.92933 ± 0.0099858 (W 0.00914748) | 3.9127 ± 0.0105452 (W 0.00946222) | 4.69204 ± 0.0227022 (W 0.0243266) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133659 ± 0.000825529 (W 0.0010816) | 0.132906 ± 0.000602498 (W 0.000103403) | 0.165569 ± 0.00044536 (W 0.0014776) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.449633 ± 0.00487817 (W 0.00243331) | 0.451923 ± 0.0015725 (W 0.00256286) | 0.481248 ± 0.00138567 (W 0.00309169) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.0751 ± 0.00507826 (W 0.00811671) | 1.07111 ± 0.00523185 (W 0.00156341) | 1.19254 ± 0.00536966 (W 0.00317273) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.59134 ± 0.0146107 (W 0.0100524) | 3.5903 ± 0.0142641 (W 0.00331018) | 3.73096 ± 0.0155307 (W 0.00693374) | · | · |  |
| `gemm/512x512x512/b1` | 8.57676 ± 0.0104616 (W 0.014299) | 8.56884 ± 0.00736098 (W 0.0147779) | 9.91143 ± 0.0799181 (W 0.0168599) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.2796 ± 0.13787 (W 0.0219933) | 29.2906 ± 0.123349 (W 0.0347659) | 30.3436 ± 0.150774 (W 0.029522) | · | · |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.045364 ± 0.000180484 (W 0.000419052) | 0.075301 ± 0.00740004 (W 0.00660022) | 0.054682 ± 0.000887382 (W 0.000280679) | 🔵 faer-fork 1.66× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.119833 ± 0.000428123 (W 0.0023954) | 0.162841 ± 0.00221671 (W 0.00232147) | 0.135673 ± 0.00143141 (W 0.00146998) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 0.289791 ± 0.00256337 (W 0.00192658) | 0.309046 ± 0.00337902 (W 0.00788099) | 0.341387 ± 0.00163252 (W 0.00235242) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.913633 ± 0.00265962 (W 0.00406886) | 0.911951 ± 0.00220669 (W 0.00295715) | 1.00505 ± 0.0014436 (W 0.00253196) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.20534 ± 0.00886387 (W 0.00377472) | 2.2082 ± 0.00463374 (W 0.00489797) | 2.84449 ± 0.0902101 (W 0.0093503) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.49065 ± 0.0279211 (W 0.0105886) | 7.50988 ± 0.0434012 (W 0.0106873) | 8.43875 ± 0.0255966 (W 0.0172983) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.034163 ± 0.0275312 (W 0.00197638) | 0.11334 ± 0.000506491 (W 0.0200975) | 0.032059 ± 0.000490015 (W 0.000124981) | 🔵 faer-fork 3.32× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.085608 ± 0.000403908 (W 0.000909593) | 0.184632 ± 0.00980806 (W 0.0318674) | 0.074087 ± 0.000511548 (W 0.000420876) | 🔵 faer-fork 2.16× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.165427 ± 0.00152007 (W 0.00162318) | 0.238421 ± 0.0213315 (W 0.0185141) | 0.179432 ± 0.000693035 (W 0.00213448) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.479094 ± 0.000316814 (W 0.0043147) | 0.563644 ± 0.00430041 (W 0.00375154) | 0.516213 ± 0.00548062 (W 0.0022427) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.14375 ± 0.00270679 (W 0.00525053) | 1.1835 ± 0.00158744 (W 0.00755134) | 1.50569 ± 0.0226875 (W 0.00306494) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.91586 ± 0.00281069 (W 0.00692837) | 3.92028 ± 0.00842847 (W 0.00806039) | 4.66912 ± 0.00503254 (W 0.0157219) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539557 ± 0.00424612 (W 0.00236213) | 0.539476 ± 0.00236699 (W 0.00337449) | 0.651587 ± 0.0101889 (W 0.00398267) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.80641 ± 0.00957551 (W 0.00175313) | 1.80644 ± 0.00807089 (W 0.00183572) | 2.14791 ± 0.00310046 (W 0.006384) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.26471 ± 0.01894 (W 0.00255955) | 4.26906 ± 0.0151857 (W 0.00814177) | 5.12776 ± 0.0222367 (W 0.0121976) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4357 ± 0.0653193 (W 0.0280036) | 14.3654 ± 0.0833965 (W 0.0138646) | 17.0792 ± 0.0824771 (W 0.0396565) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.2235 ± 0.123462 (W 0.113152) | 34.2002 ± 0.138185 (W 0.030634) | 40.5167 ± 0.128711 (W 0.413067) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.236 ± 0.390621 (W 0.0750599) | 116.154 ± 0.384366 (W 0.0414909) | 137.931 ± 0.546119 (W 0.181327) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.153366 ± 0.000901743 (W 0.000520588) | 0.169106 ± 0.000679373 (W 0.0060063) | 0.233636 ± 0.00229678 (W 0.00297888) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.457108 ± 0.00082624 (W 0.00268991) | 0.458526 ± 0.00367032 (W 0.0027986) | 0.742946 ± 0.00190156 (W 0.00307256) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.10937 ± 0.00167136 (W 0.00288824) | 1.11161 ± 0.00508278 (W 0.000757733) | 1.78705 ± 0.0152535 (W 0.0040924) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.62568 ± 0.0112221 (W 0.00571574) | 3.62703 ± 0.0102536 (W 0.00396537) | 5.77206 ± 0.0207517 (W 0.0108095) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.64492 ± 0.022886 (W 0.0150975) | 8.6417 ± 0.0299481 (W 0.00959915) | 13.7683 ± 0.0364568 (W 0.0319661) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.3791 ± 0.0359855 (W 0.0198948) | 29.3871 ± 0.0702979 (W 0.0212859) | 46.3887 ± 0.168383 (W 0.0697116) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.102931 ± 0.000621158 (W 0.00059277) | 0.138739 ± 0.00926321 (W 0.0116362) | 0.095638 ± 0.000740948 (W 0.0014826) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.235847 ± 0.00106743 (W 0.00176438) | 0.278417 ± 0.00110903 (W 0.00351799) | 0.297943 ± 0.00208671 (W 0.00277843) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 0.581639 ± 0.00127309 (W 0.00199173) | 0.609487 ± 0.00213049 (W 0.00255984) | 0.692662 ± 0.0102866 (W 0.00520232) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.83777 ± 0.00297175 (W 0.00392991) | 1.83769 ± 0.00171182 (W 0.00343609) | 2.28363 ± 0.00306708 (W 0.00811134) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.46476 ± 0.0038759 (W 0.00569984) | 4.46029 ± 0.00822328 (W 0.00570334) | 5.5815 ± 0.0270215 (W 0.0303302) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 15.0487 ± 0.0166473 (W 0.0248724) | 15.0222 ± 0.00550464 (W 0.0149325) | 18.6637 ± 0.106252 (W 0.134429) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.537606 ± 0.00408415 (W 0.00272066) | 0.537897 ± 0.00426833 (W 0.00291747) | 0.644935 ± 0.00767552 (W 0.00970332) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.80583 ± 0.00836682 (W 0.00372382) | 1.81408 ± 0.00713701 (W 0.00320656) | 2.14654 ± 0.0156584 (W 0.0105172) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.27 ± 0.0182902 (W 0.00707733) | 4.27274 ± 0.0143619 (W 0.00662431) | 5.08734 ± 0.0349612 (W 0.0210346) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4167 ± 0.0437662 (W 0.0151229) | 14.3718 ± 0.0491789 (W 0.00923538) | 17.0751 ± 0.0557568 (W 0.0262041) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.1837 ± 0.077548 (W 0.0310626) | 34.1843 ± 0.111506 (W 0.391261) | 40.602 ± 0.157809 (W 0.0520961) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.108 ± 0.34519 (W 0.082723) | 116.157 ± 0.219842 (W 0.0706715) | 137.439 ± 0.855865 (W 0.368642) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.153266 ± 0.000247388 (W 0.00162612) | 0.169274 ± 0.000418992 (W 0.00238872) | 0.231953 ± 0.00158796 (W 0.00176996) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.4586 ± 0.00165765 (W 0.00248043) | 0.459852 ± 0.000579471 (W 0.00268435) | 0.743207 ± 0.00224548 (W 0.00516245) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.10969 ± 0.00541021 (W 0.00219239) | 1.11138 ± 0.0047946 (W 0.00307046) | 1.81631 ± 0.0219405 (W 0.00664852) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.63101 ± 0.0186589 (W 0.00906925) | 3.6388 ± 0.0195085 (W 0.00904767) | 5.76669 ± 0.0243393 (W 0.0109236) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.65605 ± 0.0357536 (W 0.00886791) | 8.64199 ± 0.0266694 (W 0.0116258) | 13.764 ± 0.0423022 (W 0.0185198) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.363 ± 0.0450772 (W 0.0176533) | 29.3743 ± 0.0713156 (W 0.0287348) | 46.3129 ± 0.251376 (W 0.0735429) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.102682 ± 0.00027238 (W 0.000909944) | 0.137425 ± 0.00987107 (W 0.00985821) | 0.094956 ± 0.000474658 (W 0.00130696) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.236429 ± 3.31949 (W 0.00126476) | 0.277047 ± 0.000844825 (W 0.00357347) | 0.294967 ± 0.00141745 (W 0.00286219) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.583358 ± 0.000575795 (W 0.00275566) | 0.611774 ± 0.00135407 (W 0.00242321) | 0.697904 ± 0.004433 (W 0.00362108) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.83483 ± 0.00424929 (W 0.00355312) | 1.83588 ± 0.0012725 (W 0.00379352) | 2.28058 ± 0.00626295 (W 0.00654795) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.46932 ± 0.0110413 (W 0.0141062) | 4.45443 ± 0.00447966 (W 0.0102687) | 5.50326 ± 0.0151452 (W 0.0182349) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 15.0178 ± 0.0205697 (W 0.00824404) | 15.0242 ± 0.0130214 (W 0.0144682) | 18.6781 ± 0.0237357 (W 0.0701033) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.2433 ± 0.0544917 (W 0.00682628) | 1.23634 ± 0.0609981 (W 0.00458618) | 1.60062 ± 0.0356216 (W 0.0100379) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.06442 ± 0.0063636 (W 0.00235585) | 1.07521 ± 0.00779514 (W 0.00803631) | 1.52004 ± 0.00666368 (W 0.0103193) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08247 ± 0.00323814 (W 0.00291328) | 1.07944 ± 0.00249204 (W 0.00119076) | 1.56715 ± 0.0179898 (W 0.00459338) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.426215 ± 0.00407899 (W 0.00435915) | 0.425263 ± 0.000410786 (W 0.00476837) | 0.435057 ± 0.0198631 (W 0.00412614) | · | · | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.308345 ± 0.003933 (W 0.00423015) | 0.310015 ± 0.00414415 (W 0.00231825) | 0.425449 ± 0.000469213 (W 0.00968515) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.275912 ± 0.000894977 (W 0.00195741) | 0.298687 ± 0.00202748 (W 0.00256557) | 0.385594 ± 0.00195247 (W 0.00209134) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.424252 ± 0.00138219 (W 0.00377436) | 0.426075 ± 0.00270785 (W 0.0045144) | 0.265182 ± 0.00202276 (W 0.00287042) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.185827 ± 0.00136234 (W 0.00159702) | 0.1892 ± 0.00242931 (W 0.00267411) | 0.286264 ± 0.000322593 (W 0.0275887) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.141272 ± 0.00161144 (W 0.0018961) | 0.202378 ± 0.00195279 (W 0.00547373) | 0.198739 ± 0.000727074 (W 0.00146814) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.03602 ± 0.0185487 (W 0.00182283) | 1.03517 ± 0.01899 (W 0.00319108) | 2.59226 ± 0.0284334 (W 0.00418884) | · | 🔵 faer-fork 2.50× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.08943 ± 0.0102871 (W 0.00509106) | 1.08163 ± 0.0154474 (W 0.00271661) | 1.51596 ± 0.0591667 (W 0.0123415) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.13093 ± 0.00868623 (W 0.00248159) | 1.13335 ± 0.00508467 (W 0.00226919) | 1.24279 ± 0.00802713 (W 0.00153722) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.327087 ± 0.0023148 (W 0.00430698) | 0.71648 ± 0.00393723 (W 0.0046225) | 0.632413 ± 0.00365473 (W 0.00409244) | 🔵 faer-fork 2.19× faster than `faer-upstream` | 🔵 faer-fork 1.93× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.29708 ± 0.00193564 (W 0.00304378) | 0.297746 ± 0.00267651 (W 0.00419552) | 0.424327 ± 0.00197912 (W 0.00243582) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.295902 ± 0.00183845 (W 0.00195864) | 0.29639 ± 0.00154206 (W 0.00266083) | 0.331576 ± 0.00409116 (W 0.00296306) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.199772 ± 0.00308656 (W 0.0027107) | 1.15927 ± 0.0103519 (W 0.0103977) | 0.34477 ± 0.00390447 (W 0.00285567) | 🔵 faer-fork 5.80× faster than `faer-upstream` | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.180114 ± 0.0016035 (W 0.00196527) | 0.179803 ± 0.00193742 (W 0.00251958) | 0.289957 ± 0.00153895 (W 0.00210102) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.157213 ± 0.00166831 (W 0.00257437) | 0.158655 ± 0.00396817 (W 0.00185008) | 0.174063 ± 0.00307653 (W 0.00145698) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.12709 ± 0.00845786 (W 0.00412201) | 4.13431 ± 0.00734831 (W 0.0066338) | 5.69013 ± 0.0169284 (W 0.0144742) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.30757 ± 0.0282019 (W 0.0126881) | 4.29573 ± 0.0458405 (W 0.00534423) | 6.20347 ± 0.0773315 (W 0.0353489) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.37329 ± 0.00505906 (W 0.00821151) | 4.35168 ± 0.0333122 (W 0.0088126) | 5.22703 ± 0.00720687 (W 0.00802199) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.65301 ± 0.00865127 (W 0.00375287) | 1.65795 ± 0.00614451 (W 0.00439259) | 1.96726 ± 0.0082821 (W 0.0056358) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.1497 ± 0.00351251 (W 0.00349518) | 1.14705 ± 0.000753399 (W 0.00497297) | 1.94276 ± 0.139501 (W 0.0120343) | · | 🔵 faer-fork 1.69× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.11993 ± 0.0049835 (W 0.0030443) | 1.12514 ± 0.00697708 (W 0.0060501) | 2.06743 ± 0.0170741 (W 0.0035428) | · | 🔵 faer-fork 1.85× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.896224 ± 0.00545312 (W 0.0128084) | 0.89525 ± 0.00384244 (W 0.00810664) | 0.954772 ± 0.00198928 (W 0.00612084) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.599382 ± 0.00747361 (W 0.0034601) | 0.593902 ± 0.00428005 (W 0.00281828) | 0.971383 ± 0.0404149 (W 0.0194391) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.571349 ± 0.000574794 (W 0.00184526) | 0.620648 ± 0.00705774 (W 0.0168058) | 0.764859 ± 0.000449905 (W 0.00424149) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.04991 ± 0.0210158 (W 0.00583202) | 4.05914 ± 0.0146003 (W 0.00780602) | 5.66937 ± 0.0139543 (W 0.0134597) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.37523 ± 0.0108394 (W 0.0105022) | 4.37052 ± 0.012873 (W 0.0141541) | 6.20973 ± 0.369325 (W 0.100177) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 4.42468 ± 0.00711743 (W 0.0114521) | 4.42298 ± 0.00522064 (W 0.00632146) | 5.80436 ± 0.0161268 (W 0.023036) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.18352 ± 0.00350994 (W 0.00223814) | 1.95 ± 0.0118927 (W 0.0193266) | 36.5692 ± 0.0828631 (W 0.0253257) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 30.90× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.16119 ± 0.00816865 (W 0.00376098) | 1.15519 ± 0.00825972 (W 0.0041412) | 2.26648 ± 0.414848 (W 0.270608) | · | 🔵 faer-fork 1.95× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 1.19061 ± 0.0162898 (W 0.00809636) | 1.19065 ± 0.018431 (W 0.0102607) | 2.0299 ± 0.0299146 (W 0.00857461) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.663572 ± 0.00248178 (W 0.00437071) | 2.57283 ± 0.00577497 (W 0.024843) | 9.95941 ± 0.349936 (W 0.00945491) | 🔵 faer-fork 3.88× faster than `faer-upstream` | 🔵 faer-fork 15.01× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.603105 ± 0.00247926 (W 0.00427399) | 0.601763 ± 0.00300662 (W 0.00373819) | 1.59906 ± 0.0347378 (W 0.0167544) | · | 🔵 faer-fork 2.65× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.580577 ± 0.00657084 (W 0.00475256) | 0.587225 ± 0.00694167 (W 0.00526016) | 1.14542 ± 0.0347731 (W 0.0803334) | · | 🔵 faer-fork 1.97× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12467 ± 0.0033587 (W 0.00189683) | 1.12513 ± 0.00195271 (W 0.00142093) | 1.24216 ± 0.00980073 (W 0.00271029) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.2961 ± 0.000735362 (W 0.00275859) | 0.295772 ± 0.00111114 (W 0.00220761) | 0.326897 ± 0.00395368 (W 0.0028023) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.156631 ± 0.000976252 (W 0.0012167) | 0.156861 ± 0.00302351 (W 0.00189448) | 0.170216 ± 0.00223938 (W 0.00228896) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08882 ± 0.00544105 (W 0.00564865) | 1.08725 ± 0.0092472 (W 0.00345603) | 1.51479 ± 0.0194916 (W 0.00606857) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.277949 ± 0.00120875 (W 0.00198988) | 0.30129 ± 0.00183457 (W 0.00259857) | 0.38816 ± 0.00130496 (W 0.00248787) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.142446 ± 0.00146275 (W 0.00210429) | 0.203279 ± 0.00288157 (W 0.00802937) | 0.203677 ± 0.00456401 (W 0.00262305) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.42366 ± 0.00356061 (W 0.00858057) | 4.42587 ± 0.0053221 (W 0.0108247) | 5.67386 ± 0.072329 (W 0.0228313) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.17349 ± 0.0182794 (W 0.00728481) | 1.17407 ± 0.00270643 (W 0.00380544) | 2.03222 ± 0.0328561 (W 0.0126909) | · | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.578183 ± 3.08412 (W 0.00490855) | 0.578624 ± 0.00485225 (W 0.00420539) | 1.14454 ± 0.0219285 (W 0.022914) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.37431 ± 0.0105998 (W 0.0108637) | 4.36694 ± 0.0156326 (W 0.00936725) | 5.22917 ± 0.00619285 (W 0.0114134) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12127 ± 0.00441533 (W 0.00292021) | 1.12228 ± 0.00200731 (W 0.00347024) | 2.0649 ± 0.00703324 (W 0.00591909) | · | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.570098 ± 0.00290365 (W 0.00294316) | 0.613985 ± 0.00867309 (W 0.0147763) | 0.76565 ± 0.00148904 (W 0.00442787) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003417 ± 4.32474e-05 (W 3.032e-05) | 0.003176 ± 2.64575e-05 (W 2.58844e-05) | 0.004308 ± 3.21455e-05 (W 5.84825e-05) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016861 ± 6.35085e-05 (W 2.54814e-05) | 0.014888 ± 0.000133368 (W 3.94119e-05) | 0.016621 ± 0.000312507 (W 0.000115195) | 🔴 faer-fork 1.13× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.033242 ± 0.000278479 (W 7.0214e-05) | 0.030767 ± 0.000252805 (W 6.75818e-05) | 0.048721 ± 0.000632024 (W 0.00194904) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.112209 ± 0.000569738 (W 0.00201498) | 0.113571 ± 0.000186444 (W 0.00160529) | 0.098113 ± 0.000442562 (W 0.000128725) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.495065 ± 0.00230205 (W 0.00290953) | 0.487265 ± 0.000526377 (W 0.00238807) | 0.390941 ± 0.000437244 (W 0.00207331) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.19976 ± 0.00322466 (W 0.00247225) | 1.16338 ± 0.0011357 (W 0.00338175) | 0.903568 ± 0.00610063 (W 0.00304527) | · | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.013014 ± 0.000228685 (W 6.37966e-05) | 0.01071 ± 0.00028746 (W 4.15006e-05) | - | 🔴 faer-fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.054762 ± 0.000291143 (W 0.000146831) | 0.046305 ± 0.00058772 (W 0.00011494) | - | 🔴 faer-fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145099 ± 0.000120193 (W 0.00159832) | 0.12937 ± 0.00033573 (W 0.00180177) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008325 ± 5.16753e-05 (W 7.17447e-05) | 0.008046 ± 2.51064e-05 (W 4.03733e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008325 ± 5.22526e-05 (W 4.69393e-05) | 0.008075 ± 5.50757e-05 (W 3.89872e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040796 ± 2.25167e-05 (W 5.39926e-05) | 0.040195 ± 0.000227597 (W 0.00134577) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.041036 ± 0.00018273 (W 0.00147925) | 0.040495 ± 0.000135094 (W 5.9466e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.121977 ± 0.000130424 (W 0.000271716) | 0.120255 ± 0.000115154 (W 0.0027506) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.122407 ± 0.000244043 (W 0.00316811) | 0.120904 ± 0.000188152 (W 0.0019302) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.009047 ± 0.000100683 (W 7.22496e-05) | 0.007605 ± 6.94286e-05 (W 0.000163073) | 0.013615 ± 6.26126e-05 (W 7.27482e-05) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.03228 ± 0.000375509 (W 0.000908623) | 0.026389 ± 0.000532411 (W 0.000309997) | 0.046407 ± 0.000352138 (W 0.000243976) | 🔴 faer-fork 1.22× slower than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.074989 ± 0.00276941 (W 0.000230085) | 0.066072 ± 0.00245425 (W 0.00207447) | 0.109814 ± 0.00030817 (W 0.00206341) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031549 ± 0.000265688 (W 7.96448e-05) | 0.03255 ± 0.000111447 (W 0.00111458) | 0.027 ± 0.0308041 (W 0.000123369) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.114734 ± 0.000115518 (W 0.000177238) | 0.119672 ± 0.00188889 (W 0.000387813) | 0.136373 ± 0.00310046 (W 0.00248655) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.267108 ± 0.00155515 (W 0.00304972) | 0.281202 ± 0.00212928 (W 0.00269526) | 0.406925 ± 0.00323746 (W 0.00402914) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.022712 ± 0.000125607 (W 0.000153916) | 0.028253 ± 0.000260674 (W 0.000104457) | 0.014507 ± 0.000273008 (W 2.91548e-05) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.081111 ± 0.000433387 (W 0.000309528) | 0.131806 ± 0.000616195 (W 0.00204303) | 0.280951 ± 0.122624 (W 0.0018055) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 3.46× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.176337 ± 0.000432 (W 0.00170961) | 0.289357 ± 0.000735897 (W 0.00237633) | 0.201756 ± 0.00050331 (W 0.00219731) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.01042 ± 0.000120625 (W 5.17996e-05) | 0.008756 ± 0.000126808 (W 0.000250417) | 0.014086 ± 4.3589e-05 (W 9.76535e-05) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033804 ± 0.000249885 (W 0.000204718) | 0.028052 ± 0.000372729 (W 0.000157465) | 0.045644 ± 0.000379194 (W 0.000151724) | 🔴 faer-fork 1.21× slower than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.086521 ± 0.00251282 (W 0.00225854) | 0.069389 ± 0.000482695 (W 0.0043468) | 0.108591 ± 0.000283244 (W 0.000339856) | 🔴 faer-fork 1.25× slower than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.170036 ± 0.0016113 (W 0.00192379) | 0.186257 ± 0.00265771 (W 0.00194408) | 0.17696 ± 0.000751576 (W 0.00139993) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_thin/n64/b1` | 0.866066 ± 0.00385767 (W 0.00403341) | 0.921128 ± 0.00310591 (W 0.00406071) | 0.703085 ± 0.00266353 (W 0.00390097) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.09302 ± 0.0447189 (W 0.00607257) | 2.21726 ± 0.00399031 (W 0.00497819) | 1.65376 ± 0.0525502 (W 0.00299795) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.066524 ± 0.00028564 (W 0.00116442) | 0.141935 ± 0.000940512 (W 0.000318257) | 0.063629 ± 0.03902 (W 0.000139335) | 🔵 faer-fork 2.13× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.237731 ± 0.00197175 (W 0.00250627) | 0.51998 ± 0.000843696 (W 0.00322322) | 0.261486 ± 0.00105772 (W 0.00204745) | 🔵 faer-fork 2.19× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.541705 ± 0.00409986 (W 0.00240732) | 1.19026 ± 0.00253463 (W 0.00233108) | 0.616244 ± 0.00188675 (W 0.00266135) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000731 ± 6.35085e-06 (W 2.16795e-05) | 0.000701 ± 6.08276e-06 (W 1.83085e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001583 ± 4.72582e-05 (W 3.11448e-05) | 0.001502 ± 2.04206e-05 (W 1.65318e-05) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002675 ± 7.82326e-05 (W 2.1661e-05) | 0.002595 ± 3.60555e-05 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003436 ± 3.01164e-05 (W 5.75091e-05) | 0.003176 ± 8.14453e-05 (W 3.937e-05) | 0.004258 ± 9.06661e-05 (W 4.5607e-05) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.013625 ± 0.00199442 (W 7.01235e-05) | 0.014717 ± 0.00161661 (W 8.70534e-05) | 0.016911 ± 0.000288722 (W 8.45577e-05) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030106 ± 0.00216512 (W 7.39885e-05) | 0.036037 ± 0.00025552 (W 0.000533718) | 0.049031 ± 0.000104403 (W 0.000135526) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.1131 ± 0.000239952 (W 0.00193301) | 0.113762 ± 0.000613824 (W 0.000314602) | 0.103674 ± 0.000127375 (W 0.00016635) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.487345 ± 0.00144701 (W 0.00174019) | 0.4821 ± 0.00364213 (W 0.00179828) | 0.269303 ± 0.00233606 (W 0.00166327) | · | 🔴 faer-fork 1.81× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16245 ± 0.00346961 (W 0.0022253) | 1.12767 ± 0.00136013 (W 0.00235511) | 0.589114 ± 0.00250599 (W 0.00264468) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.014457 ± 0.0002545 (W 8.26511e-05) | 0.01067 ± 0.000186083 (W 5.84808e-05) | - | 🔴 faer-fork 1.35× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.056024 ± 0.000576688 (W 7.93549e-05) | 0.046396 ± 0.000258052 (W 0.000248047) | - | 🔴 faer-fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.16072 ± 0.00268761 (W 0.000886285) | 0.13372 ± 0.000757102 (W 0.00188822) | - | 🔴 faer-fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.007143 ± 0.000672191 (W 0.000231787) | 0.008335 ± 6.0803e-05 (W 7.52409e-05) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.007293 ± 0.000227156 (W 0.000240355) | 0.008235 ± 1.57162e-05 (W 8.94835e-05) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.018935 ± 0.00022598 (W 0.00024929) | 0.018494 ± 0.000312006 (W 0.000223585) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020698 ± 8.90524e-05 (W 0.000489098) | 0.020017 ± 0.0003095 (W 0.000497293) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.044573 ± 0.000922617 (W 0.000482054) | 0.046115 ± 0.000905088 (W 0.00132605) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.045805 ± 0.000503105 (W 0.000694362) | 0.045755 ± 0.000185831 (W 0.000399543) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.009087 ± 0.000177305 (W 9.78264e-05) | 0.007474 ± 1.76163e-05 (W 0.000111889) | 0.013616 ± 6.08276e-06 (W 9.98158e-05) | 🔴 faer-fork 1.22× slower than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.032821 ± 0.000425114 (W 0.000113156) | 0.030216 ± 0.000446233 (W 0.00128549) | 0.045975 ± 0.000277995 (W 0.000106331) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.07523 ± 0.00288952 (W 0.00181772) | 0.071654 ± 0.00186063 (W 0.00157001) | 0.093934 ± 0.000225382 (W 0.000206817) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.032661 ± 0.000215663 (W 0.000170779) | 0.045685 ± 0.000381817 (W 0.000380155) | 0.08048 ± 0.0310851 (W 0.00145427) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 2.46× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.108301 ± 6.98665e-05 (W 0.000224867) | 0.182711 ± 0.000514848 (W 0.00156745) | 0.145721 ± 0.00115304 (W 0.00207281) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.22117 ± 0.011028 (W 0.00294447) | 0.368224 ± 0.00113354 (W 0.00260271) | 0.33939 ± 0.00415334 (W 0.00557025) | 🔵 faer-fork 1.66× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023785 ± 0.000333158 (W 0.000126338) | 0.042269 ± 0.000545561 (W 0.000650035) | 0.014768 ± 0.000121903 (W 7.50333e-05) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.073586 ± 0.000776875 (W 0.000242182) | 0.20447 ± 0.00318184 (W 0.00239922) | 0.067505 ± 0.12469 (W 0.00163075) | 🔵 faer-fork 2.78× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.143938 ± 0.000861039 (W 0.000849738) | 0.417826 ± 0.00735771 (W 0.00265951) | 0.905082 ± 0.00241215 (W 0.00152305) | 🔵 faer-fork 2.90× faster than `faer-upstream` | 🔵 faer-fork 6.29× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.010901 ± 0.000100002 (W 7.95877e-05) | 0.008586 ± 1.52753e-05 (W 0.000102461) | 0.014216 ± 0.000100167 (W 8.03629e-05) | 🔴 faer-fork 1.27× slower than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.034665 ± 0.000341585 (W 0.000210132) | 0.030397 ± 0.000504342 (W 0.000714424) | 0.045785 ± 0.000369506 (W 0.000156468) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.087854 ± 0.00190234 (W 0.00267896) | 0.066274 ± 0.000622264 (W 0.000862051) | 0.092582 ± 0.000444579 (W 0.000299926) | 🔴 faer-fork 1.33× slower than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.17183 ± 0.0122448 (W 0.00138516) | 0.184503 ± 0.001271 (W 0.002064) | 0.185055 ± 0.00035527 (W 0.00186423) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.854406 ± 0.00134993 (W 0.00294596) | 0.9097 ± 0.00265408 (W 0.00136458) | 0.672139 ± 0.00699903 (W 0.00592865) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.05143 ± 0.0419071 (W 0.00164552) | 2.09263 ± 0.00752947 (W 0.00132134) | 1.47466 ± 0.0197734 (W 0.00653332) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.067886 ± 0.000474377 (W 0.000156097) | 0.141563 ± 0.000868582 (W 0.000405944) | 0.131043 ± 0.0394793 (W 8.75346e-05) | 🔵 faer-fork 2.09× faster than `faer-upstream` | 🔵 faer-fork 1.93× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.243064 ± 0.000183052 (W 0.00147415) | 0.522832 ± 0.0034175 (W 0.00197291) | 0.265165 ± 0.00126875 (W 0.00193175) | 🔵 faer-fork 2.15× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.578595 ± 0.0030886 (W 0.00246651) | 1.18707 ± 0.00458917 (W 0.0026996) | 0.594595 ± 0.0081019 (W 0.00239373) | 🔵 faer-fork 2.05× faster than `faer-upstream` | · |  |
| `triangular_solve/n32/b1` | 0.000962 ± 3.78594e-05 (W 2.77489e-05) | 0.000692 ± 3.09892e-05 (W 2.22531e-05) | - | 🔴 faer-fork 1.39× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002054 ± 3.05505e-05 (W 1.71231e-05) | 0.001523 ± 5.03322e-05 (W 1.52381e-05) | - | 🔴 faer-fork 1.35× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003456 ± 0.000130985 (W 1.34164e-05) | 0.002645 ± 8.02081e-05 (W 3.27109e-05) | - | 🔴 faer-fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003446 ± 2.00083e-05 (W 5.2491e-05) | 0.003126 ± 4.58258e-05 (W 4.94186e-05) | 0.004268 ± 4.72582e-05 (W 5.02991e-05) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016892 ± 9.53939e-05 (W 5.61186e-05) | 0.014677 ± 0.00157443 (W 3.04959e-05) | 0.016861 ± 0.000300733 (W 8.04811e-05) | 🔴 faer-fork 1.15× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.033352 ± 0.00229639 (W 7.82943e-05) | 0.037149 ± 0.00198808 (W 0.000382463) | 0.049102 ± 0.000564686 (W 0.00014487) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.11254 ± 0.000422881 (W 0.000137004) | 0.11282 ± 0.000112398 (W 0.000189958) | 0.104585 ± 0.000273545 (W 0.00225146) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.488618 ± 0.00160057 (W 0.00154118) | 0.485022 ± 0.00106229 (W 0.00276653) | 0.260875 ± 0.00128364 (W 0.00204537) | · | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16203 ± 0.00161548 (W 0.00287944) | 1.14237 ± 0.00228231 (W 0.00220061) | 0.568988 ± 0.0013973 (W 0.00191673) | · | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.014106 ± 9.0185e-05 (W 0.000107564) | 0.010349 ± 0.00023084 (W 0.00010305) | - | 🔴 faer-fork 1.36× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.055905 ± 0.000174701 (W 0.000472062) | 0.046297 ± 0.000201465 (W 0.000108694) | - | 🔴 faer-fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.168373 ± 0.00166373 (W 0.000542582) | 0.133638 ± 0.000137588 (W 0.00251925) | - | 🔴 faer-fork 1.26× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.007254 ± 0.608755 (W 0.000322606) | 0.008376 ± 7.63763e-05 (W 5.56974e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.006212 ± 7.93725e-05 (W 0.000194651) | 0.008335 ± 5.08626e-05 (W 0.000106814) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014567 ± 0.000125301 (W 0.000188314) | 0.019075 ± 0.000179918 (W 0.000239404) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.01631 ± 0.000312779 (W 0.000639009) | 0.020709 ± 0.000179519 (W 0.00191857) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.03227 ± 0.00101895 (W 0.000692731) | 0.056575 ± 0.000533811 (W 0.000516844) | - | 🔵 faer-fork 1.75× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.03223 ± 0.000437185 (W 0.000454546) | 0.057848 ± 0.000925781 (W 0.00151064) | - | 🔵 faer-fork 1.79× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.009047 ± 0.000102051 (W 7.59289e-05) | 0.007604 ± 0.000185689 (W 0.000152807) | 0.013736 ± 2.00083e-05 (W 6.48074e-05) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.032781 ± 0.000326492 (W 0.00017214) | 0.030427 ± 0.000287855 (W 0.000400013) | 0.046096 ± 0.000282544 (W 0.000190237) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.075861 ± 0.00261894 (W 0.000215337) | 0.073897 ± 0.000774373 (W 0.00250441) | 0.091761 ± 0.00029915 (W 0.000321204) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.032881 ± 0.000232143 (W 0.000156939) | 0.05369 ± 0.00076695 (W 0.000479925) | 0.080108 ± 0.0307397 (W 0.00144851) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 2.44× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.106528 ± 0.000259828 (W 0.000384891) | 0.225061 ± 0.00269503 (W 0.00190221) | 0.157464 ± 0.000732417 (W 0.0021273) | 🔵 faer-fork 2.11× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.229546 ± 0.00990524 (W 0.00347206) | 0.451493 ± 0.00625088 (W 0.00238858) | 0.347706 ± 0.00248022 (W 0.00712529) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023504 ± 0.00016773 (W 0.000126263) | 0.049242 ± 0.000592509 (W 0.000980996) | 0.014537 ± 0.000138924 (W 6.94262e-05) | 🔵 faer-fork 2.10× faster than `faer-upstream` | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.073117 ± 0.000471637 (W 0.00157375) | 0.242844 ± 0.00205003 (W 0.00169815) | 0.066533 ± 0.125925 (W 0.000490859) | 🔵 faer-fork 3.32× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.136514 ± 0.000200097 (W 0.000247845) | 0.49248 ± 0.00214099 (W 0.00280776) | 0.90403 ± 0.00106837 (W 0.00137228) | 🔵 faer-fork 3.61× faster than `faer-upstream` | 🔵 faer-fork 6.62× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.01085 ± 0.000159813 (W 9.40064e-05) | 0.008466 ± 5.56776e-05 (W 0.00015449) | 0.014227 ± 8.07279e-05 (W 3.27109e-05) | 🔴 faer-fork 1.28× slower than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.034344 ± 4.89932e-05 (W 0.000152251) | 0.031078 ± 0.000180093 (W 0.000185627) | 0.045755 ± 9.75722e-05 (W 0.000185173) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.092934 ± 0.00135749 (W 0.00165482) | 0.067316 ± 0.000494237 (W 0.00138863) | 0.090217 ± 0.000114548 (W 0.000260439) | 🔴 faer-fork 1.38× slower than `faer-upstream` | · |  |
| `svd_thin/n32/b1` | 0.169276 ± 0.00109095 (W 0.00172525) | 0.183193 ± 0.000556043 (W 0.0018452) | 0.18742 ± 0.00141732 (W 0.00190806) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.84984 ± 0.00195288 (W 0.0024776) | 0.912456 ± 0.00441627 (W 0.00173961) | 0.667821 ± 0.0159534 (W 0.00543014) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.06458 ± 0.0448311 (W 0.00275242) | 2.10948 ± 0.00660725 (W 0.00506369) | 1.42196 ± 0.014203 (W 0.0131059) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.066944 ± 0.000279859 (W 0.000120919) | 0.141462 ± 0.000317254 (W 0.00184759) | 0.130793 ± 0.0387861 (W 0.000124427) | 🔵 faer-fork 2.11× faster than `faer-upstream` | 🔵 faer-fork 1.95× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.24202 ± 0.00310586 (W 0.00172924) | 0.519115 ± 0.00130133 (W 0.00225639) | 0.265694 ± 0.000173517 (W 0.00154047) | 🔵 faer-fork 2.14× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.597551 ± 0.00213173 (W 0.00229572) | 1.185 ± 0.00457279 (W 0.00456561) | 0.588639 ± 0.00330699 (W 0.00362423) | 🔵 faer-fork 1.98× faster than `faer-upstream` | · |  |
| `triangular_solve/n32/b1` | 0.000942 ± 2.64575e-05 (W 2.07171e-05) | 0.000702 ± 1.1547e-05 (W 2.08399e-05) | - | 🔴 faer-fork 1.34× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002074 ± 4.32474e-05 (W 1.41421e-05) | 0.001563 ± 3.21455e-05 (W 1.34164e-05) | - | 🔴 faer-fork 1.33× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003607 ± 3.51188e-05 (W 3.42053e-05) | 0.002836 ± 3.23574e-05 (W 4.11983e-05) | - | 🔴 faer-fork 1.27× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003296 ± 1e-05 (W 2.05475e-05) | 0.003085 ± 4.0501e-05 (W 2.54421e-05) | 0.003357 ± 9.11976e-05 (W 3.56693e-05) | 🔴 faer-fork 1.07× slower than `faer-upstream` | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016591 ± 6.07481e-05 (W 5.06952e-05) | 0.014587 ± 0.000157513 (W 2.96648e-05) | 0.014246 ± 0.000231157 (W 4.91935e-05) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.03229 ± 0.000291515 (W 3.93738e-05) | 0.029865 ± 0.000401528 (W 8.29295e-05) | 0.038121 ± 0.000400476 (W 7.10648e-05) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.112038 ± 0.000633728 (W 0.00210733) | 0.113672 ± 0.000360289 (W 0.00157983) | 0.096481 ± 0.000360012 (W 0.000320971) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.494528 ± 0.000941945 (W 0.00206052) | 0.487596 ± 0.00107479 (W 0.00232911) | 0.383702 ± 0.000421673 (W 0.00209834) | · | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.20017 ± 0.00361472 (W 0.00335636) | 1.16456 ± 0.00082627 (W 0.00245438) | 0.879864 ± 0.00166556 (W 0.00108352) | · | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011491 ± 0.000195192 (W 0.000290181) | 0.01034 ± 0.000242192 (W 7.03242e-05) | - | 🔴 faer-fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.048069 ± 0.000129384 (W 0.000105049) | 0.045725 ± 0.000322249 (W 0.0021448) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.130784 ± 0.000675778 (W 0.00151135) | 0.127168 ± 0.000267291 (W 0.00189808) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008426 ± 4.57202e-05 (W 3.86044e-05) | 0.008215 ± 3.05505e-05 (W 5.97495e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008485 ± 9.88956e-05 (W 5.57512e-05) | 0.008306 ± 3.80832e-05 (W 4.97524e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040404 ± 5.04017e-05 (W 0.00144001) | 0.040044 ± 4.17971e-05 (W 0.000430082) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040656 ± 6.4291e-05 (W 0.000127802) | 0.040286 ± 0.000142388 (W 0.000114543) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.124161 ± 0.000546736 (W 0.00212816) | 0.122598 ± 0.00105615 (W 0.000446536) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.12389 ± 0.000150334 (W 0.00201534) | 0.122799 ± 0.000168968 (W 0.00176206) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007394 ± 0.000115036 (W 8.95612e-05) | 0.007363 ± 5.50757e-06 (W 0.000122533) | 0.011051 ± 0.000130679 (W 0.000110668) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026108 ± 8.53834e-05 (W 0.000147481) | 0.025708 ± 0.00019713 (W 0.000185203) | 0.035957 ± 0.000266884 (W 0.000132552) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.060081 ± 0.00036955 (W 0.000359831) | 0.05937 ± 0.000205687 (W 0.00155327) | 0.079918 ± 0.000196574 (W 0.00031617) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.029495 ± 0.000121244 (W 0.000145479) | 0.0321 ± 0.000337027 (W 0.00022634) | 0.0217 ± 0.000397091 (W 0.000326985) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.106708 ± 0.00033473 (W 0.00177392) | 0.117299 ± 0.0014463 (W 0.00182255) | 0.115514 ± 0.000495392 (W 0.00225823) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.249964 ± 0.00158236 (W 0.00224926) | 0.272776 ± 0.00252964 (W 0.00332817) | 0.338708 ± 0.00039039 (W 0.00236474) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.015629 ± 4.93288e-05 (W 9.68504e-05) | 0.018484 ± 5.83124e-05 (W 7.42179e-05) | 0.012063 ± 0.000157357 (W 5.05094e-05) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.065241 ± 0.000126361 (W 0.000238793) | 0.076482 ± 0.000457745 (W 0.0017024) | 0.272719 ± 0.00106065 (W 0.00160449) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 4.18× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.141904 ± 0.000496718 (W 0.000590797) | 0.16655 ± 0.00085831 (W 0.00114552) | 0.893307 ± 0.0034001 (W 0.000806836) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 6.30× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.008276 ± 3.60555e-05 (W 6.90746e-05) | 0.008135 ± 0.000245663 (W 9.6853e-05) | 0.010951 ± 7.25282e-05 (W 5.44904e-05) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.02688 ± 0.000180666 (W 0.00014487) | 0.026409 ± 0.000101489 (W 0.000160693) | 0.035316 ± 0.000121533 (W 0.000150566) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.071644 ± 0.0020776 (W 0.00251206) | 0.067426 ± 0.000627341 (W 0.000381846) | 0.078716 ± 0.000165802 (W 0.00181425) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.172341 ± 0.00164949 (W 0.00178583) | 0.188251 ± 0.0019995 (W 0.00180222) | 0.16611 ± 0.000803767 (W 0.00168271) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |
| `svd_thin/n64/b1` | 0.910148 ± 0.00305344 (W 0.00197507) | 0.963198 ± 0.00485039 (W 0.00149612) | 0.686991 ± 0.00217251 (W 0.00275481) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.0287 ± 0.0477629 (W 0.00843506) | 2.15329 ± 0.0394434 (W 0.0020451) | 1.57866 ± 0.0494534 (W 0.00514055) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.065953 ± 0.000397774 (W 0.000151464) | 0.143055 ± 0.000731896 (W 0.00117202) | 0.058209 ± 0.000408694 (W 0.00163382) | 🔵 faer-fork 2.17× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.239334 ± 0.00105552 (W 0.00166899) | 0.543228 ± 0.00248352 (W 0.00284671) | 0.250187 ± 0.00213368 (W 0.00239319) | 🔵 faer-fork 2.27× faster than `faer-upstream` | · |  |
| `svd_values/n96/b1` | 0.549701 ± 0.00132892 (W 0.0034007) | 1.19494 ± 0.00349564 (W 0.00457033) | 0.595215 ± 0.00169356 (W 0.00310463) | 🔵 faer-fork 2.17× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000761 ± 4.89932e-05 (W 2.32444e-05) | 0.000791 ± 1.67432e-05 (W 1.52709e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001833 ± 0.000129114 (W 2.4684e-05) | 0.001743 ± 6.4291e-05 (W 1.83358e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003266 ± 0.000183058 (W 2.82843e-05) | 0.003145 ± 0.000278162 (W 1.82811e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003307 ± 0.000100732 (W 0.000113993) | 0.003046 ± 0.000178979 (W 6.83374e-05) | 0.003436 ± 6.55744e-05 (W 4.67579e-05) | 🔴 faer-fork 1.09× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.013395 ± 0.00189859 (W 3.89872e-05) | 0.014366 ± 0.000124808 (W 3.68402e-05) | 0.014217 ± 0.000207445 (W 4.51918e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.032801 ± 0.00206841 (W 9.27265e-05) | 0.035396 ± 0.000164418 (W 0.000658394) | 0.038311 ± 0.000183576 (W 0.00013274) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113231 ± 3.87857e-05 (W 0.0017449) | 0.114102 ± 0.000374207 (W 0.00192164) | 0.101619 ± 0.000489553 (W 0.000271581) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.487185 ± 0.00203377 (W 0.00181911) | 0.480944 ± 0.00191116 (W 0.00210049) | 0.261286 ± 0.000729918 (W 0.00227326) | · | 🔴 faer-fork 1.86× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16654 ± 0.00100681 (W 0.00185339) | 1.12798 ± 0.00202812 (W 0.00257138) | 0.578966 ± 0.0020811 (W 0.00221642) | · | 🔴 faer-fork 2.01× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.012443 ± 0.000133167 (W 9.9996e-05) | 0.010259 ± 0.000461676 (W 7.24569e-05) | - | 🔴 faer-fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.049563 ± 0.000350929 (W 0.00019341) | 0.045334 ± 0.00029929 (W 0.000190971) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.147296 ± 0.0042564 (W 0.00114134) | 0.130242 ± 0.00229767 (W 0.000515372) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.006622 ± 7.0713e-05 (W 0.000217514) | 0.008326 ± 3.80832e-05 (W 6.25084e-05) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.006472 ± 4.04145e-05 (W 0.000121532) | 0.008355 ± 2.60832e-05 (W 6.32866e-05) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019496 ± 0.00027675 (W 0.000225158) | 0.019266 ± 9.29157e-05 (W 0.000443617) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.019586 ± 0.000187705 (W 0.000350055) | 0.019046 ± 8.72372e-05 (W 0.000278798) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.044382 ± 0.000442901 (W 0.000195126) | 0.044182 ± 0.000240389 (W 0.00048371) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.044693 ± 0.000201636 (W 0.00155871) | 0.044323 ± 0.000236221 (W 0.000404751) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007374 ± 5.32948e-05 (W 0.000127103) | 0.007333 ± 7.0713e-05 (W 0.000106072) | 0.01096 ± 8.12835e-05 (W 8.02571e-05) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026499 ± 0.000269072 (W 0.000170998) | 0.029745 ± 0.000673485 (W 0.000318359) | 0.036067 ± 0.000359875 (W 0.000160338) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.060994 ± 0.000142339 (W 0.0004888) | 0.069369 ± 0.0021289 (W 0.000935735) | 0.079929 ± 0.000220298 (W 0.000173788) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.030927 ± 0.000365048 (W 9.95053e-05) | 0.045575 ± 0.000699108 (W 0.000470763) | 0.021299 ± 0.000425512 (W 0.000260721) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.099646 ± 0.00074121 (W 0.000619778) | 0.180357 ± 0.00352277 (W 0.00210722) | 0.12904 ± 0.00169876 (W 0.000597672) | 🔵 faer-fork 1.81× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.201935 ± 0.0115938 (W 0.00365018) | 0.361395 ± 0.00358537 (W 0.00249426) | 0.302565 ± 0.0010941 (W 0.00406142) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.016771 ± 0.00017407 (W 9.93982e-05) | 0.031539 ± 0.000875418 (W 0.000436656) | 0.011822 ± 4.16333e-05 (W 4.51132e-05) | 🔵 faer-fork 1.88× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.065572 ± 0.000588561 (W 0.000211597) | 0.145141 ± 0.00287359 (W 0.00205388) | 0.273047 ± 0.00129842 (W 0.00165907) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔵 faer-fork 4.16× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.127387 ± 0.000656643 (W 0.000606014) | 0.282444 ± 0.00367779 (W 0.00197401) | 0.889342 ± 0.00356531 (W 0.00177849) | 🔵 faer-fork 2.22× faster than `faer-upstream` | 🔵 faer-fork 6.98× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.008615 ± 2.00083e-05 (W 8.89944e-05) | 0.008115 ± 8.7178e-05 (W 0.00011262) | 0.01097 ± 5.56776e-05 (W 9.14019e-05) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.027652 ± 0.000241144 (W 9.61769e-05) | 0.029205 ± 0.000245968 (W 0.000641212) | 0.035406 ± 0.000111505 (W 5.50454e-05) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.073787 ± 0.00171502 (W 0.00236379) | 0.064219 ± 0.000458927 (W 0.000615144) | 0.079147 ± 0.000672742 (W 0.00174223) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.17233 ± 0.0119552 (W 0.00237316) | 0.185126 ± 0.00107957 (W 0.00170956) | 0.175857 ± 0.0004115 (W 0.000378927) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.89388 ± 0.00189303 (W 0.00274027) | 0.959072 ± 0.00663053 (W 0.00276325) | 0.629079 ± 0.00535942 (W 0.00268556) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 1.9903 ± 0.0366057 (W 0.00270031) | 2.09313 ± 0.0044561 (W 0.000680136) | 1.34105 ± 0.0415664 (W 0.0022596) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.067024 ± 0.00070674 (W 0.000137914) | 0.142486 ± 0.000769445 (W 0.0019783) | 0.058659 ± 0.000260832 (W 0.000140347) | 🔵 faer-fork 2.13× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.245245 ± 0.00139377 (W 0.00271555) | 0.541696 ± 0.00331696 (W 0.00246096) | 0.254693 ± 0.000443562 (W 0.0029717) | 🔵 faer-fork 2.21× faster than `faer-upstream` | · |  |
| `svd_values/n96/b1` | 0.587221 ± 0.00419134 (W 0.00185479) | 1.18744 ± 0.00450337 (W 0.0020947) | 0.59717 ± 0.00324428 (W 0.00240775) | 🔵 faer-fork 2.02× faster than `faer-upstream` | · |  |
| `triangular_solve/n32/b1` | 0.000972 ± 6.35085e-06 (W 1.92354e-05) | 0.000762 ± 1.53948e-05 (W 1.31985e-05) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002304 ± 0 (W 3.20811e-05) | 0.001743 ± 1.48436e-05 (W 1.84201e-05) | - | 🔴 faer-fork 1.32× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003847 ± 0.000157513 (W 6.84105e-05) | 0.002886 ± 0.000115659 (W 2.53831e-05) | - | 🔴 faer-fork 1.33× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003336 ± 5.7735e-06 (W 3.36155e-05) | 0.003036 ± 3.05505e-05 (W 1.66223e-05) | 0.003426 ± 5.45924e-05 (W 5.38544e-05) | 🔴 faer-fork 1.10× slower than `faer-upstream` | · | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016481 ± 5.80259e-05 (W 4.66905e-05) | 0.014467 ± 0.00149541 (W 6.04152e-05) | 0.013786 ± 0.000137914 (W 2.91084e-05) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0323 ± 0.00203051 (W 0.000107862) | 0.035836 ± 0.00194386 (W 0.00121808) | 0.03789 ± 0.000246982 (W 0.000153916) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.1131 ± 0.000180417 (W 0.00176577) | 0.113251 ± 0.000269967 (W 0.00139561) | 0.102371 ± 0.000606665 (W 0.000307131) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.488002 ± 0.00268802 (W 0.00262993) | 0.484184 ± 0.00135544 (W 0.00167966) | 0.252782 ± 0.00212838 (W 0.00174395) | · | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16066 ± 0.00167066 (W 0.00247396) | 1.14312 ± 0.00104415 (W 0.00575535) | 0.55955 ± 0.00188265 (W 0.00258598) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.012223 ± 0.000299962 (W 8.31276e-05) | 0.010109 ± 0.000155907 (W 6.90688e-05) | - | 🔴 faer-fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.049862 ± 0.000401846 (W 0.000169786) | 0.045675 ± 0.000416422 (W 0.0001916) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.152344 ± 0.00241976 (W 0.000993846) | 0.127577 ± 0.00280695 (W 0.000226343) | - | 🔴 faer-fork 1.19× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.005851 ± 0.000142339 (W 0.000101016) | 0.008466 ± 5e-05 (W 7.94185e-05) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.005941 ± 4.72582e-05 (W 0.000156228) | 0.008436 ± 8.49725e-05 (W 7.89513e-05) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.014587 ± 2.58908e-05 (W 0.000245755) | 0.019457 ± 6.55744e-05 (W 0.000342225) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.014708 ± 0.000231128 (W 0.000127821) | 0.019868 ± 0.000410895 (W 0.000350984) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.030517 ± 0.000464695 (W 0.000233149) | 0.055653 ± 0.00044559 (W 0.000856107) | - | 🔵 faer-fork 1.82× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.030367 ± 0.000132855 (W 0.000192118) | 0.055303 ± 0.000267844 (W 0.000622965) | - | 🔵 faer-fork 1.82× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007284 ± 0.000120968 (W 5.50291e-05) | 0.007123 ± 0.000159124 (W 0.000113165) | 0.01102 ± 7.84241e-05 (W 8.34865e-05) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026228 ± 0.000474596 (W 0.000129958) | 0.029875 ± 0.000253792 (W 0.000213207) | 0.036428 ± 0.000149901 (W 0.00155285) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.060814 ± 0.000556203 (W 0.000326114) | 0.071924 ± 0.00166893 (W 0.00233388) | 0.079598 ± 0.000235443 (W 0.000228245) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031108 ± 0.00022745 (W 0.000169936) | 0.053419 ± 0.00092052 (W 0.00109441) | 0.02143 ± 5e-05 (W 0.00031032) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.099946 ± 0.000438145 (W 0.000526252) | 0.223298 ± 0.00265085 (W 0.00294721) | 0.138798 ± 0.00129263 (W 0.00238909) | 🔵 faer-fork 2.23× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.211423 ± 0.0117921 (W 0.00411243) | 0.448728 ± 0.000938971 (W 0.00418875) | 0.3122 ± 0.00119962 (W 0.00332686) | 🔵 faer-fork 2.12× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.016621 ± 3.78594e-05 (W 0.000115542) | 0.038702 ± 0.000187705 (W 0.000640879) | 0.011862 ± 3.21455e-05 (W 3.28634e-05) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.065262 ± 0.000455867 (W 0.00023386) | 0.185276 ± 0.00184651 (W 0.00385254) | 0.273238 ± 0.000236982 (W 0.00178143) | 🔵 faer-fork 2.84× faster than `faer-upstream` | 🔵 faer-fork 4.19× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.126045 ± 0.00049152 (W 0.000514777) | 0.366103 ± 0.000352313 (W 0.00362362) | 0.890142 ± 0.000952253 (W 0.00265445) | 🔵 faer-fork 2.90× faster than `faer-upstream` | 🔵 faer-fork 7.06× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.008717 ± 0.000166764 (W 6.00933e-05) | 0.007935 ± 0.000160935 (W 0.000122744) | 0.01091 ± 8.5967e-05 (W 6.71885e-05) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.027562 ± 0.000175291 (W 0.000160363) | 0.029906 ± 0.000524863 (W 0.000715661) | 0.035126 ± 0.000280726 (W 9.28289e-05) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.079299 ± 0.590276 (W 0.00299026) | 0.066304 ± 0.00101566 (W 0.000606608) | 0.078465 ± 0.000256167 (W 0.00215822) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.171819 ± 0.000975466 (W 0.00164895) | 0.185136 ± 0.000327 (W 0.00212487) | 0.176808 ± 0.000674101 (W 0.00131571) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `svd_thin/n64/b1` | 0.892699 ± 0.00157233 (W 0.00164284) | 0.956797 ± 0.00127545 (W 0.00264181) | 0.62977 ± 0.00265173 (W 0.00274339) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.00108 ± 0.0368364 (W 0.00183389) | 2.09877 ± 0.00642312 (W 0.00495126) | 1.28214 ± 0.00377517 (W 0.00236734) | · | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.066585 ± 0.00022715 (W 0.000202486) | 0.143267 ± 6.02771e-05 (W 0.00201412) | 0.058389 ± 0.000297725 (W 0.00011929) | 🔵 faer-fork 2.15× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.245329 ± 0.00131375 (W 0.00184192) | 0.538211 ± 0.00116788 (W 0.00168212) | 0.254563 ± 0.000520082 (W 0.00150744) | 🔵 faer-fork 2.19× faster than `faer-upstream` | · |  |
| `svd_values/n96/b1` | 0.606487 ± 0.00153931 (W 0.00211686) | 1.19038 ± 0.0038069 (W 0.00204204) | 0.59223 ± 0.00232324 (W 0.0020583) | 🔵 faer-fork 1.96× faster than `faer-upstream` | · |  |
| `triangular_solve/n32/b1` | 0.000972 ± 1.52753e-05 (W 1.87083e-05) | 0.000741 ± 1e-05 (W 2.6987e-05) | - | 🔴 faer-fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002214 ± 8.544e-05 (W 2.50998e-05) | 0.001693 ± 2.60832e-05 (W 2.12132e-05) | - | 🔴 faer-fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003807 ± 0.000101489 (W 3.04959e-05) | 0.003216 ± 0.00018 (W 2.38747e-05) | - | 🔴 faer-fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00555 ± 5.1316e-05 (W 1.69204e-05) | 0.00556 ± 0.000226789 (W 0.00136576) | 0.008867 ± 9.01684e-05 (W 5.67301e-05) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.031629 ± 0.000131036 (W 5.2509e-05) | 0.030296 ± 7.59627e-05 (W 0.000100648) | 0.050734 ± 0.000484088 (W 0.000273716) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.086251 ± 0.000860665 (W 0.000191899) | 0.083997 ± 0.000721618 (W 0.000452252) | 0.13896 ± 0.00138763 (W 0.000256311) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141032 ± 0.00120204 (W 0.00163847) | 0.142435 ± 0.000810837 (W 0.00205707) | 0.145001 ± 0.000504323 (W 0.00147634) | · | · |  |
| `eigh/n64/b1` | 0.660433 ± 0.000622803 (W 0.00201697) | 0.64788 ± 0.00113151 (W 0.00330851) | 0.792831 ± 0.00286989 (W 0.00244595) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.66366 ± 0.00422559 (W 0.0026638) | 1.61864 ± 0.00469343 (W 0.00233725) | 2.00869 ± 0.00326777 (W 0.00265364) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.019016 ± 0.000104644 (W 8.51422e-05) | 0.015689 ± 0.000110274 (W 9.07204e-05) | - | 🔴 faer-fork 1.21× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.100167 ± 0.00106386 (W 0.00164977) | 0.092203 ± 0.000842917 (W 0.00172811) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.284913 ± 0.000435675 (W 0.0017648) | 0.267547 ± 0.000459343 (W 0.00215851) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028543 ± 9.71253e-05 (W 3.50885e-05) | 0.028001 ± 6.6335e-05 (W 6.50385e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028574 ± 8.17333e-05 (W 9.23434e-05) | 0.028112 ± 8.5049e-05 (W 0.000104738) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.160347 ± 0.00010845 (W 0.00032362) | 0.159227 ± 0.000726757 (W 0.00208128) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.160107 ± 0.000388961 (W 0.00221125) | 0.159827 ± 0.000155886 (W 0.00160083) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.468941 ± 0.00211987 (W 0.00163767) | 0.468215 ± 0.00149238 (W 0.00200354) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.472477 ± 0.00295739 (W 0.000763342) | 0.46863 ± 0.00220449 (W 0.00202499) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.014036 ± 7.54983e-05 (W 4.26052e-05) | 0.011792 ± 5.1316e-05 (W 7.99137e-05) | 0.019566 ± 7.2111e-05 (W 8.52426e-05) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.060603 ± 5.25389e-05 (W 0.000122152) | 0.054472 ± 0.000404279 (W 0.000205751) | 0.094154 ± 0.000142693 (W 0.00193153) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.158235 ± 0.000939789 (W 0.00212816) | 0.143486 ± 0.0010483 (W 0.000375569) | 0.243703 ± 0.00215799 (W 0.00236466) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.069389 ± 0.000284623 (W 0.000470325) | 0.068557 ± 0.000311079 (W 0.00174362) | 0.054752 ± 0.0846815 (W 0.000247901) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.311662 ± 0.000721861 (W 0.00166637) | 0.316472 ± 0.00120493 (W 0.00312997) | 0.339936 ± 0.000696584 (W 0.00270198) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.763918 ± 0.00239971 (W 0.00175827) | 0.774778 ± 0.000770495 (W 0.00269704) | 0.997504 ± 0.00158255 (W 0.00178649) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039474 ± 0.000176466 (W 0.000208111) | 0.046286 ± 0.00023516 (W 0.000242377) | 0.028894 ± 0.000546932 (W 0.000133286) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.167653 ± 0.000260719 (W 0.00181929) | 0.238025 ± 0.00174886 (W 0.00173218) | 0.163436 ± 0.00106907 (W 0.000169583) | 🔵 faer-fork 1.42× faster than `faer-upstream` | · |  |
| `qr_factor/n96/b1` | 0.402096 ± 0.00310194 (W 0.0023618) | 0.541676 ± 0.00549597 (W 0.00225599) | 0.505709 ± 0.00152434 (W 0.00251993) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.015249 ± 4.93288e-05 (W 6.03598e-05) | 0.013084 ± 0.000181475 (W 5.47101e-05) | 0.019947 ± 5.50757e-05 (W 3.70135e-05) | 🔴 faer-fork 1.17× slower than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.062517 ± 0.000149534 (W 0.000116975) | 0.056615 ± 0.000185716 (W 7.91088e-05) | 0.092243 ± 0.000722359 (W 0.00172033) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.16162 ± 0.000523733 (W 0.00189841) | 0.147374 ± 0.000642887 (W 0.00200714) | 0.237764 ± 0.000244957 (W 0.00167051) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.220031 ± 0.00149158 (W 0.00207748) | 0.23659 ± 0.000698164 (W 0.00166817) | 0.251877 ± 0.0017422 (W 0.0017315) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.16639 ± 0.0011665 (W 0.00170421) | 1.22922 ± 0.00404509 (W 0.00280514) | 1.32747 ± 0.00319642 (W 0.00221776) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.01297 ± 0.00208479 (W 0.00565709) | 3.1519 ± 0.0124196 (W 0.00346071) | 3.42071 ± 0.0758551 (W 0.00607352) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.083175 ± 0.000309823 (W 0.000120022) | 0.161892 ± 0.000283565 (W 0.00192238) | 0.10156 ± 0.114865 (W 0.00209102) | 🔵 faer-fork 1.95× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.342059 ± 0.000852038 (W 0.00268661) | 0.651437 ± 0.0021125 (W 0.00254975) | 0.481724 ± 0.00138544 (W 0.00248528) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.856841 ± 0.00279804 (W 0.0029012) | 1.51068 ± 0.00336514 (W 0.00546386) | 1.34697 ± 0.00136866 (W 0.00339145) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001162 ± 1e-05 (W 2.02534e-05) | 0.001082 ± 1e-05 (W 1.87083e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002855 ± 1.1547e-05 (W 2.6857e-05) | 0.002665 ± 3.21455e-05 (W 3.28634e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005249 ± 3.76431e-05 (W 3.33062e-05) | 0.005029 ± 2.08167e-05 (W 3.95752e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00555 ± 3.21455e-05 (W 4.01647e-05) | 0.00513 ± 8.02517e-05 (W 5.77001e-05) | 0.008857 ± 7.05715e-05 (W 9.37017e-05) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.031569 ± 0.000207445 (W 0.00013223) | 0.030136 ± 0.000641489 (W 0.000176344) | 0.052057 ± 0.000200749 (W 0.000263402) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.088575 ± 0.00155742 (W 0.000490437) | 0.087613 ± 0.001018 (W 0.0020082) | 0.138717 ± 0.00032299 (W 0.0017992) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.138128 ± 0.000196359 (W 0.000306413) | 0.141004 ± 0.000491553 (W 0.00035878) | 0.15065 ± 0.00017706 (W 0.000249706) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.575119 ± 0.00212154 (W 0.00307222) | 0.616842 ± 0.00143037 (W 0.00222766) | 0.542473 ± 0.000845925 (W 0.00215147) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.36326 ± 0.00277421 (W 0.00324001) | 1.4414 ± 0.00696882 (W 0.00219279) | 1.11484 ± 0.00247968 (W 0.00391527) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.020468 ± 0.000538975 (W 0.00197844) | 0.015669 ± 0.000133167 (W 7.15542e-05) | - | 🔴 faer-fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n64/b1` | 0.106299 ± 0.00189569 (W 0.000470794) | 0.09164 ± 0.000766147 (W 0.000427227) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.253674 ± 0.00375618 (W 0.00186648) | 0.264462 ± 0.0020595 (W 0.00243456) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.014467 ± 0.000159897 (W 0.000154919) | 0.028213 ± 0.000164895 (W 4.50555e-05) | - | 🔵 faer-fork 1.95× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.014767 ± 0.000287112 (W 0.000143577) | 0.028343 ± 0.000155242 (W 0.000149543) | - | 🔵 faer-fork 1.92× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.061204 ± 0.000177043 (W 0.000304985) | 0.060683 ± 0.000331805 (W 0.00130693) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.061574 ± 0.000570619 (W 0.00115846) | 0.060863 ± 0.000110092 (W 0.00156763) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.152444 ± 0.000187356 (W 0.000351612) | 0.14983 ± 0.000810399 (W 0.00154962) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.153495 ± 0.000798812 (W 0.0013819) | 0.15057 ± 0.0003868 (W 0.000767869) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.014016 ± 7.07602e-05 (W 6.07882e-05) | 0.011752 ± 8.28674e-05 (W 5.30613e-05) | 0.019696 ± 0.000140475 (W 9.63862e-05) | 🔴 faer-fork 1.19× slower than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.061865 ± 0.000240646 (W 0.001457) | 0.054803 ± 0.00029675 (W 0.00187745) | 0.093393 ± 0.000599222 (W 0.000846954) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.157202 ± 0.00228438 (W 0.00196655) | 0.144029 ± 0.0010737 (W 0.00217949) | 0.229136 ± 0.000134128 (W 0.00124162) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.063498 ± 0.00010055 (W 0.000537193) | 0.081892 ± 0.000390309 (W 0.00129861) | 0.201304 ± 0.0851551 (W 0.00176544) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 3.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.194944 ± 0.00122527 (W 0.00198693) | 0.319907 ± 0.00203015 (W 0.00225803) | 0.308937 ± 0.000494184 (W 0.00260895) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.420942 ± 0.00193217 (W 0.00297046) | 0.607835 ± 0.00208593 (W 0.00330694) | 0.762514 ± 0.00165064 (W 0.00249962) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.81× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039584 ± 0.000151725 (W 0.000296388) | 0.05922 ± 0.000145535 (W 0.000703152) | 0.028834 ± 0.000345008 (W 7.27757e-05) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.123982 ± 0.000523788 (W 0.000371418) | 0.285543 ± 0.00191407 (W 0.00214144) | 0.161129 ± 0.331014 (W 0.00184134) | 🔵 faer-fork 2.30× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.264554 ± 0.00107965 (W 0.0017322) | 0.565736 ± 0.00305366 (W 0.0022321) | 2.39056 ± 0.00209778 (W 0.00431172) | 🔵 faer-fork 2.14× faster than `faer-upstream` | 🔵 faer-fork 9.04× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.015709 ± 0.000145258 (W 5.01996e-05) | 0.012934 ± 8.5967e-05 (W 4.0598e-05) | 0.019827 ± 1.73205e-05 (W 5.46919e-05) | 🔴 faer-fork 1.21× slower than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.064771 ± 0.0018782 (W 0.00116368) | 0.056325 ± 0.000422785 (W 0.000108995) | 0.091461 ± 0.000546654 (W 0.00048658) | 🔴 faer-fork 1.15× slower than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.160049 ± 0.000656768 (W 0.000902141) | 0.143827 ± 0.00215951 (W 0.00224476) | 0.221902 ± 0.000483949 (W 0.0019141) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.214901 ± 0.000858582 (W 0.00166274) | 0.235688 ± 0.000426142 (W 0.00165779) | 0.260655 ± 0.000759072 (W 0.00176091) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.00936 ± 0.00314238 (W 0.000912936) | 1.14752 ± 0.00364498 (W 0.00310979) | 1.00843 ± 0.00244104 (W 0.00272325) | 🔵 faer-fork 1.14× faster than `faer-upstream` | · |  |
| `svd_thin/n96/b1` | 2.51917 ± 0.00444517 (W 0.00329848) | 2.777 ± 0.00646423 (W 0.0107744) | 2.46713 ± 0.0104401 (W 0.00748559) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_values/n32/b1` | 0.084408 ± 0.00059797 (W 0.00155128) | 0.161891 ± 0.000381139 (W 0.00243102) | 0.296611 ± 0.114298 (W 0.00171537) | 🔵 faer-fork 1.92× faster than `faer-upstream` | 🔵 faer-fork 3.51× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.35353 ± 0.000893452 (W 0.00192251) | 0.649413 ± 0.00265859 (W 0.00192074) | 0.47897 ± 4.80451e-05 (W 0.00217513) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.801369 ± 0.00371862 (W 0.00231965) | 1.5032 ± 0.00441904 (W 0.00467436) | 1.33006 ± 0.00181047 (W 0.00178805) | 🔵 faer-fork 1.88× faster than `faer-upstream` | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001423 ± 9.50438e-06 (W 2.20045e-05) | 0.001072 ± 5.7735e-06 (W 2.12132e-05) | - | 🔴 faer-fork 1.33× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003406 ± 3.66106e-05 (W 1.95269e-05) | 0.002695 ± 2.51661e-05 (W 2.40832e-05) | - | 🔴 faer-fork 1.26× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.006022 ± 4.90951e-05 (W 2.07364e-05) | 0.004929 ± 4.0501e-05 (W 4.33497e-05) | - | 🔴 faer-fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00565 ± 3.50761e-05 (W 3.93611e-05) | 0.00515 ± 4.20357e-05 (W 4.43543e-05) | 0.008867 ± 4.0129e-05 (W 6.7196e-05) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.031419 ± 0.000379387 (W 6.77886e-05) | 0.029896 ± 0.000146186 (W 0.000116954) | 0.051816 ± 0.00054443 (W 0.000303169) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.090368 ± 0.000925484 (W 0.000502538) | 0.087864 ± 0.000274609 (W 0.000909069) | 0.140421 ± 0.0010294 (W 0.000541207) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.138687 ± 0.000521145 (W 0.000348471) | 0.141493 ± 0.000404269 (W 0.000351431) | 0.151101 ± 0.000195526 (W 0.00209589) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.571662 ± 0.00259236 (W 0.00249738) | 0.619722 ± 0.00206849 (W 0.00252591) | 0.514567 ± 0.0025197 (W 0.0025639) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.33728 ± 0.0138081 (W 0.00637085) | 1.44841 ± 0.0015881 (W 0.00261686) | 0.996844 ± 0.00233752 (W 0.00267992) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.019937 ± 9.29157e-05 (W 0.000133803) | 0.015679 ± 8.62168e-05 (W 0.000116919) | - | 🔴 faer-fork 1.27× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.108201 ± 0.00208841 (W 0.000387886) | 0.0917 ± 0.000371896 (W 0.000501672) | - | 🔴 faer-fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.256046 ± 0.0032743 (W 0.00240316) | 0.264732 ± 0.00059176 (W 0.00217366) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.010821 ± 0.000349996 (W 9.40223e-05) | 0.028262 ± 4.08697e-05 (W 0.000105562) | - | 🔵 faer-fork 2.61× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.011171 ± 0.000185023 (W 0.000206413) | 0.028332 ± 7.22519e-05 (W 8.6487e-05) | - | 🔵 faer-fork 2.54× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.036929 ± 7.63763e-05 (W 0.000340537) | 0.059972 ± 0.0001367 (W 0.000345496) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.03753 ± 0.000373002 (W 0.000711468) | 0.060533 ± 6.08276e-05 (W 0.000680929) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.08647 ± 0.000310178 (W 0.00105741) | 0.148757 ± 0.00028803 (W 0.00193044) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.087083 ± 0.00109098 (W 0.00135907) | 0.15036 ± 0.000431155 (W 0.0013424) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.014027 ± 8.50314e-05 (W 6.94133e-05) | 0.011601 ± 2.08167e-05 (W 6.1887e-05) | 0.019516 ± 0.000141067 (W 6.82591e-05) | 🔴 faer-fork 1.21× slower than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.065602 ± 0.000341195 (W 0.000260702) | 0.054291 ± 0.000336527 (W 0.001512) | 0.093444 ± 0.000392726 (W 0.0012362) | 🔴 faer-fork 1.21× slower than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.158345 ± 0.000621249 (W 0.000318813) | 0.14459 ± 0.000646111 (W 0.00155531) | 0.228665 ± 0.00164829 (W 0.00171176) | 🔴 faer-fork 1.10× slower than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.063307 ± 0.000357627 (W 0.000489348) | 0.089145 ± 0.00124461 (W 0.00157119) | 0.200673 ± 0.0845488 (W 0.00174025) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔵 faer-fork 3.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.182571 ± 0.00071673 (W 0.00193185) | 0.358176 ± 0.000733271 (W 0.00254596) | 0.284999 ± 0.00106743 (W 0.00242261) | 🔵 faer-fork 1.96× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.367203 ± 0.00134294 (W 0.00248223) | 0.682434 ± 0.00339417 (W 0.0031218) | 0.695403 ± 0.00110007 (W 0.00398791) | 🔵 faer-fork 1.86× faster than `faer-upstream` | 🔵 faer-fork 1.89× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.042489 ± 0.0023833 (W 0.000463827) | 0.067516 ± 0.00115433 (W 0.00221046) | 0.028763 ± 0.00015019 (W 5.44546e-05) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.120484 ± 0.000505015 (W 0.000368137) | 0.31693 ± 0.00368444 (W 0.00673348) | 0.161179 ± 0.32968 (W 0.00248689) | 🔵 faer-fork 2.63× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.240499 ± 0.000753104 (W 0.00180146) | 0.617628 ± 0.00511726 (W 0.0075393) | 2.37613 ± 0.00886103 (W 0.00290994) | 🔵 faer-fork 2.57× faster than `faer-upstream` | 🔵 faer-fork 9.88× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.01586 ± 0.000116148 (W 4.85211e-05) | 0.012884 ± 2.08167e-05 (W 4.54973e-05) | 0.019977 ± 0.000183576 (W 6.18061e-05) | 🔴 faer-fork 1.23× slower than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.068998 ± 0.00019894 (W 0.000189078) | 0.056264 ± 0.000226872 (W 0.000285357) | 0.09113 ± 0.000898299 (W 0.0013426) | 🔴 faer-fork 1.23× slower than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.158776 ± 0.000329673 (W 0.00172039) | 0.146993 ± 0.000553915 (W 0.00172165) | 0.222304 ± 0.00132041 (W 0.00197836) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.215701 ± 0.00018974 (W 0.00262437) | 0.234977 ± 0.00407729 (W 0.00199645) | 0.261889 ± 0.00094025 (W 0.00164773) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.00124 ± 0.00542021 (W 0.000895499) | 1.15156 ± 0.00110164 (W 0.00146936) | 0.961227 ± 0.00478418 (W 0.00461859) | 🔵 faer-fork 1.15× faster than `faer-upstream` | · |  |
| `svd_thin/n96/b1` | 2.47766 ± 0.0130132 (W 0.00227874) | 2.79192 ± 0.00571717 (W 0.00266034) | 2.26156 ± 0.00393079 (W 0.00481854) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.084046 ± 0.000112829 (W 0.00013045) | 0.160559 ± 2.61598e-05 (W 0.00207318) | 0.296341 ± 0.113861 (W 0.00233651) | 🔵 faer-fork 1.91× faster than `faer-upstream` | 🔵 faer-fork 3.53× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.359291 ± 0.00107511 (W 0.00142322) | 0.647369 ± 0.00117246 (W 0.00234753) | 0.479164 ± 0.00146698 (W 0.00229976) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.826066 ± 0.00257636 (W 0.00237107) | 1.50422 ± 0.00440718 (W 0.00307423) | 1.3185 ± 0.00531202 (W 0.00292903) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001432 ± 6.35085e-06 (W 2.05256e-05) | 0.001062 ± 1e-05 (W 2.58844e-05) | - | 🔴 faer-fork 1.35× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003386 ± 1.1547e-05 (W 1.31985e-05) | 0.002655 ± 1.1547e-05 (W 1.1371e-05) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.006082 ± 7.80833e-05 (W 6.08046e-05) | 0.00493 ± 2.28108e-05 (W 2.86042e-05) | - | 🔴 faer-fork 1.23× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00559 ± 3.84318e-05 (W 4.6822e-05) | 0.005229 ± 6.6335e-05 (W 4.41497e-05) | 0.007835 ± 0.000121698 (W 5.21536e-05) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030937 ± 0.000134859 (W 5.59464e-05) | 0.029935 ± 7.26659e-05 (W 9.92134e-05) | 0.044112 ± 0.00056374 (W 0.000208519) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.086109 ± 0.00266233 (W 0.000172784) | 0.083185 ± 5.47449e-05 (W 0.000151004) | 0.125785 ± 0.000584228 (W 0.0018763) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.141033 ± 7.02163e-05 (W 0.00192317) | 0.142536 ± 0.000631856 (W 0.00196494) | 0.143206 ± 0.000325664 (W 0.00190528) | · | · |  |
| `eigh/n64/b1` | 0.659171 ± 0.00294468 (W 0.00275037) | 0.650558 ± 0.00233556 (W 0.00291531) | 0.781191 ± 0.00167838 (W 0.00369915) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.65769 ± 0.00484076 (W 0.00292984) | 1.61798 ± 0.00232165 (W 0.00231523) | 1.98423 ± 0.00401028 (W 0.0033223) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017092 ± 0.000115036 (W 8.47838e-05) | 0.015859 ± 0.000151438 (W 6.6583e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.093635 ± 0.000654526 (W 0.000290733) | 0.090339 ± 9.92018e-05 (W 0.000581829) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.270462 ± 0.00117272 (W 0.00179838) | 0.265152 ± 0.000230272 (W 0.00188401) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028363 ± 4.2194e-05 (W 7.92465e-05) | 0.027822 ± 5.56776e-05 (W 6.63641e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028413 ± 0.000161649 (W 3.2668e-05) | 0.027921 ± 0.000232726 (W 0.000102929) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.158256 ± 0.000590698 (W 0.00233953) | 0.157715 ± 0.000301818 (W 0.000259642) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158836 ± 0.000957084 (W 0.00233592) | 0.158063 ± 0.000285115 (W 0.00190559) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.462118 ± 0.0022669 (W 0.00217244) | 0.460445 ± 0.00280312 (W 0.00038297) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.46324 ± 0.00169337 (W 0.00247599) | 0.460911 ± 0.00353458 (W 0.00172364) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012393 ± 0.000130615 (W 4.0917e-05) | 0.011812 ± 7.42765e-05 (W 4.67782e-05) | 0.017142 ± 2.51661e-05 (W 3.27109e-05) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.054181 ± 0.000140119 (W 0.000117346) | 0.052979 ± 0.00034358 (W 0.000134652) | 0.083305 ± 0.00017493 (W 0.000243837) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.14401 ± 0.000664285 (W 0.00141482) | 0.141412 ± 0.000260858 (W 0.00181182) | 0.209712 ± 0.00177594 (W 0.00251275) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.067385 ± 0.000461129 (W 0.00180749) | 0.068397 ± 6.09945e-05 (W 0.00035406) | 0.049311 ± 0.00042752 (W 9.63546e-05) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.3052 ± 0.00147002 (W 0.00240395) | 0.314387 ± 0.00122448 (W 0.00263943) | 0.318602 ± 0.00100028 (W 0.00238575) | · | · |  |
| `qr/n96/b1` | 0.744453 ± 0.00154631 (W 0.00395488) | 0.769197 ± 0.00341971 (W 0.00195355) | 0.927773 ± 0.00498828 (W 0.00129142) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.03189 ± 0.00016553 (W 0.000191453) | 0.034214 ± 0.000475385 (W 0.00143889) | 0.026369 ± 0.000110259 (W 7.0852e-05) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.151833 ± 0.000563469 (W 0.00201297) | 0.163846 ± 0.000606033 (W 0.00151715) | 0.728061 ± 0.000282015 (W 0.0019338) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 4.80× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.367656 ± 0.000967914 (W 0.00291678) | 0.397282 ± 0.00194429 (W 0.00201589) | 2.3775 ± 0.00104954 (W 0.00261019) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 6.47× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013395 ± 0.00012108 (W 6.14191e-05) | 0.012954 ± 9.84886e-05 (W 5.94138e-05) | 0.017002 ± 8.75233e-05 (W 4.40829e-05) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055724 ± 0.000276466 (W 3.42812e-05) | 0.054862 ± 0.000172143 (W 0.00178159) | 0.081121 ± 0.000215516 (W 0.00018166) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.146672 ± 0.000968044 (W 0.00189803) | 0.145149 ± 0.000831599 (W 0.00185682) | 0.20378 ± 0.00075162 (W 0.00210481) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.217677 ± 0.000612867 (W 0.00229602) | 0.233734 ± 0.000811813 (W 0.00245479) | 0.24806 ± 0.00071428 (W 0.0018326) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.1946 ± 0.00248292 (W 0.00461449) | 1.26267 ± 0.00363596 (W 0.00325681) | 1.30317 ± 0.0040739 (W 0.0040854) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96668 ± 0.00101132 (W 0.0046774) | 3.1033 ± 0.00417238 (W 0.00375119) | 3.3693 ± 0.00879403 (W 0.00415108) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.083525 ± 0.000293343 (W 0.000134113) | 0.159346 ± 0.000179984 (W 0.00172494) | 0.099255 ± 0.00062706 (W 0.00157727) | 🔵 faer-fork 1.91× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.340592 ± 0.000242992 (W 0.00235623) | 0.629039 ± 0.0013351 (W 0.00303846) | 0.469381 ± 0.00253291 (W 0.00306824) | 🔵 faer-fork 1.85× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.851242 ± 0.00297137 (W 0.00233557) | 1.48829 ± 0.00355138 (W 0.00289169) | 1.31297 ± 0.000437705 (W 0.00196487) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001162 ± 1.09697e-05 (W 1.66193e-05) | 0.001222 ± 2.64575e-05 (W 1.81439e-05) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002715 ± 4.3589e-05 (W 1.51658e-05) | 0.002825 ± 3.05505e-05 (W 3.22056e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004919 ± 0.000248154 (W 2.38747e-05) | 0.005019 ± 0.000234159 (W 2.28101e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005571 ± 3.23574e-05 (W 2.77543e-05) | 0.0051 ± 0.000115544 (W 3.9488e-05) | 0.007895 ± 4.3589e-05 (W 5.47723e-05) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.031168 ± 8.3865e-05 (W 7.47877e-05) | 0.029645 ± 0.000552728 (W 0.000120491) | 0.044513 ± 0.000285512 (W 0.00145968) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.090027 ± 0.000557226 (W 0.000790379) | 0.086481 ± 0.00079026 (W 0.000308062) | 0.125934 ± 0.000216516 (W 0.00213496) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.138056 ± 0.000286394 (W 0.000542142) | 0.141983 ± 0.000751818 (W 0.00141053) | 0.149067 ± 0.0004145 (W 0.000370487) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.574357 ± 0.00167397 (W 0.0022628) | 0.617033 ± 0.000952312 (W 0.00243498) | 0.531037 ± 0.00198976 (W 0.00238024) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.36601 ± 0.00110953 (W 0.00238282) | 1.44259 ± 0.00708457 (W 0.00259114) | 1.10314 ± 0.00329227 (W 0.00308202) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.018194 ± 0.000604159 (W 8.97229e-05) | 0.015499 ± 7.23418e-05 (W 7.92035e-05) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.098554 ± 0.00245862 (W 0.000698286) | 0.089587 ± 0.000517816 (W 0.000409775) | - | 🔴 faer-fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.235607 ± 0.00248394 (W 0.00199553) | 0.262259 ± 0.00134196 (W 0.00230158) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.014948 ± 1.70392e-05 (W 0.000163044) | 0.027982 ± 8.88819e-05 (W 7.61282e-05) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.014998 ± 0.000271 (W 0.000111041) | 0.028072 ± 0.000161401 (W 8.83646e-05) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.061865 ± 0.000197495 (W 0.000497409) | 0.060433 ± 0.000165802 (W 0.00141489) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.061995 ± 0.000268576 (W 0.000602312) | 0.060332 ± 0.000303355 (W 0.0016133) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.151924 ± 0.000759012 (W 0.000739144) | 0.147564 ± 0.000512711 (W 0.00105737) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.152143 ± 0.000665663 (W 0.00174607) | 0.148296 ± 0.00062723 (W 0.00127625) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012524 ± 0.000155232 (W 6.05739e-05) | 0.011812 ± 0.00022 (W 3.15151e-05) | 0.017192 ± 6.7159e-05 (W 4.12941e-05) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.055784 ± 0.00126428 (W 0.00137658) | 0.052929 ± 0.000576428 (W 0.0015251) | 0.083175 ± 6.50641e-05 (W 0.000197781) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.14452 ± 0.0019999 (W 0.00149406) | 0.137395 ± 0.00258204 (W 0.00219937) | 0.209149 ± 0.000465604 (W 0.00131361) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.061565 ± 4.96689e-05 (W 0.000378451) | 0.081742 ± 0.000606846 (W 0.00148546) | 0.049442 ± 0.000336452 (W 0.000217291) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.189422 ± 0.000576834 (W 0.00154481) | 0.31571 ± 0.00175296 (W 0.00264785) | 0.289157 ± 0.000547576 (W 0.00168942) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.407247 ± 0.000855279 (W 0.00198924) | 0.611763 ± 0.00453675 (W 0.00361889) | 0.728493 ± 0.00218634 (W 0.00220336) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.79× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.030967 ± 6.60328e-05 (W 0.000300284) | 0.046617 ± 0.000229384 (W 0.000549895) | 0.026429 ± 0.000277357 (W 0.000135008) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.115005 ± 0.00116061 (W 0.000393645) | 0.20998 ± 0.00228641 (W 0.00128695) | 0.724176 ± 0.000966003 (W 0.00209542) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔵 faer-fork 6.30× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.244136 ± 0.00152843 (W 0.00199484) | 0.418001 ± 0.00562776 (W 0.00255092) | 2.3609 ± 0.0076918 (W 0.00648959) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔵 faer-fork 9.67× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013695 ± 8.75233e-05 (W 6.87917e-05) | 0.012944 ± 4.3589e-05 (W 0.0014529) | 0.017031 ± 9.06661e-05 (W 5.39101e-05) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.061485 ± 0.000236792 (W 0.00148122) | 0.054592 ± 0.000357827 (W 0.000131884) | 0.081171 ± 0.000181751 (W 0.00217419) | 🔴 faer-fork 1.13× slower than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.145951 ± 0.000569168 (W 0.000593184) | 0.141383 ± 0.000774608 (W 0.00174888) | 0.201745 ± 0.00106365 (W 0.00248292) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.212004 ± 0.00127859 (W 0.00155866) | 0.233474 ± 0.000558925 (W 0.00251399) | 0.256998 ± 0.0016561 (W 0.00245926) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.03963 ± 0.00154026 (W 0.00215811) | 1.1766 ± 0.00363289 (W 0.00381864) | 0.983658 ± 0.00292082 (W 0.00201755) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.47028 ± 0.00408943 (W 0.0041631) | 2.73822 ± 0.00584304 (W 0.00555931) | 2.44619 ± 0.00594366 (W 0.00870555) | 🔵 faer-fork 1.11× faster than `faer-upstream` | · |  |
| `svd_values/n32/b1` | 0.084839 ± 0.000620877 (W 0.000460468) | 0.159847 ± 0.000211758 (W 0.0010586) | 0.099196 ± 0.000831394 (W 0.00174714) | 🔵 faer-fork 1.88× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.349393 ± 0.00262062 (W 0.00203944) | 0.621094 ± 0.00272029 (W 0.00290008) | 0.470374 ± 0.00103005 (W 0.00263877) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.80163 ± 0.00303165 (W 0.00246799) | 1.47353 ± 0.0026155 (W 0.00695213) | 1.3054 ± 0.00476226 (W 0.00556259) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001392 ± 2.70247e-05 (W 1.96545e-05) | 0.001202 ± 5.7735e-06 (W 2.68198e-05) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003216 ± 0.000165802 (W 3.11336e-05) | 0.002815 ± 4.16333e-05 (W 3.80421e-05) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005611 ± 1.18462e-05 (W 2.84658e-05) | 0.004959 ± 0.000297955 (W 2.8146e-05) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00559 ± 4.10731e-05 (W 0.000140742) | 0.005139 ± 0.0001205 (W 6.06572e-05) | 0.007905 ± 0.000118462 (W 4.42866e-05) | 🔴 faer-fork 1.09× slower than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.031008 ± 0.000257734 (W 9.65049e-05) | 0.029465 ± 0.00018735 (W 0.000127496) | 0.044182 ± 0.000467081 (W 0.000153611) | 🔴 faer-fork 1.05× slower than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.089497 ± 0.000546215 (W 0.000203269) | 0.087052 ± 0.000117189 (W 0.000592455) | 0.124912 ± 0.000491814 (W 0.00228498) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.139028 ± 0.000420847 (W 0.000465833) | 0.141283 ± 0.000802533 (W 0.000285333) | 0.148446 ± 0.000815283 (W 0.000157385) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.569008 ± 0.0010895 (W 0.00147176) | 0.619336 ± 0.00215496 (W 0.00230688) | 0.503336 ± 0.00233625 (W 0.00427328) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.3363 ± 0.00271059 (W 0.00324635) | 1.44927 ± 0.0014547 (W 0.00300763) | 0.977356 ± 0.00246679 (W 0.00230412) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.018304 ± 7.56329e-05 (W 7.50333e-05) | 0.01583 ± 6.56531e-05 (W 7.85315e-05) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.10204 ± 0.00145703 (W 0.000487397) | 0.089587 ± 0.000671774 (W 0.000260921) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.239647 ± 0.000836512 (W 0.00132113) | 0.26359 ± 0.001184 (W 0.00232522) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.01117 ± 3.06649e-05 (W 0.000104811) | 0.028062 ± 0.000159478 (W 0.00156093) | - | 🔵 faer-fork 2.51× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.011031 ± 0.000150444 (W 9.00733e-05) | 0.028253 ± 2.36714e-05 (W 8.14506e-05) | - | 🔵 faer-fork 2.56× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.038201 ± 0.000568226 (W 0.000252625) | 0.060302 ± 0.00023767 (W 0.000209858) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.038502 ± 0.000106927 (W 0.000198847) | 0.060563 ± 0.000386096 (W 0.000378144) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.088344 ± 0.000246579 (W 0.00110382) | 0.147824 ± 0.000711816 (W 0.00138242) | - | 🔵 faer-fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.087793 ± 0.000444839 (W 0.000918403) | 0.148757 ± 0.000419415 (W 0.00156303) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012273 ± 9.57096e-05 (W 5.07957e-05) | 0.011772 ± 8.02081e-05 (W 3.24376e-05) | 0.017072 ± 0.0002582 (W 7.4364e-05) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058749 ± 0.000396234 (W 0.000286316) | 0.052748 ± 0.000833356 (W 0.00160188) | 0.082503 ± 0.000335719 (W 0.000143726) | 🔴 faer-fork 1.11× slower than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.14496 ± 0.000616272 (W 0.000496431) | 0.141824 ± 0.000601565 (W 0.000927385) | 0.20843 ± 0.00068693 (W 0.00149031) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.061133 ± 0.000402295 (W 0.000422453) | 0.089748 ± 0.000717093 (W 0.0015889) | 0.048911 ± 0.000494765 (W 0.000122521) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.176608 ± 0.00116851 (W 0.0018688) | 0.355752 ± 0.000662634 (W 0.00297092) | 0.266255 ± 0.00163756 (W 0.00313181) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.352285 ± 0.00185514 (W 0.00285185) | 0.67998 ± 0.00396299 (W 0.00217986) | 0.663363 ± 0.000687646 (W 0.00282435) | 🔵 faer-fork 1.93× faster than `faer-upstream` | 🔵 faer-fork 1.88× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.030627 ± 0.000246395 (W 0.00117009) | 0.054621 ± 0.000500721 (W 0.00101395) | 0.026229 ± 3.56417e-05 (W 7.16812e-05) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.111427 ± 0.000732417 (W 0.000561959) | 0.246338 ± 0.000539735 (W 0.00224222) | 0.724413 ± 0.00140998 (W 0.00202656) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔵 faer-fork 6.50× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.227203 ± 0.000907741 (W 0.00181919) | 0.488538 ± 0.00154174 (W 0.00351833) | 2.35864 ± 0.00190879 (W 0.00348737) | 🔵 faer-fork 2.15× faster than `faer-upstream` | 🔵 faer-fork 10.38× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.013716 ± 0.000111879 (W 5.74996e-05) | 0.012814 ± 0.000109697 (W 3.24037e-05) | 0.017012 ± 3.05505e-05 (W 4.45444e-05) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.062206 ± 0.000255637 (W 0.000191053) | 0.054421 ± 0.000228386 (W 0.00022396) | 0.08037 ± 0.000266884 (W 0.00120435) | 🔴 faer-fork 1.14× slower than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.144078 ± 0.00066165 (W 0.000545992) | 0.143958 ± 0.000551699 (W 0.000514637) | 0.201224 ± 5.25389e-05 (W 0.00172007) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.212967 ± 0.000737419 (W 0.00169913) | 0.232251 ± 0.00548191 (W 0.00232165) | 0.257281 ± 0.000693554 (W 0.00206469) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.03029 ± 0.00690417 (W 0.00250047) | 1.18275 ± 0.000530586 (W 0.00201043) | 0.94239 ± 0.0013045 (W 0.00320851) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.42893 ± 0.0108595 (W 0.00400116) | 2.75841 ± 0.00689821 (W 0.00330371) | 2.24868 ± 0.0076876 (W 0.00500611) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.084427 ± 0.000260577 (W 0.000278755) | 0.157963 ± 0.000266783 (W 0.00218985) | 0.098012 ± 0.000618343 (W 0.0020757) | 🔵 faer-fork 1.87× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.359799 ± 0.00132744 (W 0.00241617) | 0.623043 ± 0.00128204 (W 0.00257798) | 0.463956 ± 0.0043142 (W 0.00220857) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.826136 ± 0.00524401 (W 0.00244987) | 1.47626 ± 0.00403598 (W 0.00291006) | 1.30105 ± 0.00100868 (W 0.00243381) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001393 ± 4.3589e-05 (W 2.33067e-05) | 0.001182 ± 1e-05 (W 1.6769e-05) | - | 🔴 faer-fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003186 ± 5.7735e-07 (W 1.64682e-05) | 0.002795 ± 2.08167e-05 (W 2.4682e-05) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0057 ± 0.000197122 (W 2.9955e-05) | 0.005009 ± 0.000200326 (W 3.34843e-05) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070721 ± 0.000208127 (W 0.00156654) | 0.066624 ± 0.000470706 (W 0.000316582) | 0.114133 ± 0.00169889 (W 0.00251155) | 🔴 faer-fork 1.06× slower than `faer-upstream` | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.391608 ± 0.00391005 (W 0.00223026) | 0.384237 ± 0.00192431 (W 0.00322088) | 0.631714 ± 0.00818397 (W 0.00649877) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.53141 ± 0.00484362 (W 0.00672013) | 2.50918 ± 0.00820993 (W 0.00573783) | 3.94217 ± 0.0133882 (W 0.0352945) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.32934 ± 0.00944158 (W 0.00619462) | 2.25848 ± 0.00651118 (W 0.00599626) | 1.84016 ± 0.00724414 (W 0.006905) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.0181 ± 0.036139 (W 0.0207407) | 9.80905 ± 0.0120471 (W 0.0158063) | 10.0152 ± 0.0107481 (W 0.0231633) | · | · |  |
| `eigh/n512/b1` | 49.8142 ± 0.296607 (W 0.0489256) | 48.9323 ± 0.250137 (W 0.0338985) | 60.994 ± 0.0490873 (W 0.117686) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.31607 ± 0.000220366 (W 0.00265354) | 0.312032 ± 0.00198827 (W 0.00338673) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.72226 ± 0.00435221 (W 0.00878262) | 2.75773 ± 0.0163659 (W 0.00873153) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.049 ± 0.642469 (W 0.0396239) | 21.5312 ± 0.751368 (W 0.0503153) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259443 ± 0.000922546 (W 0.00161682) | 0.258963 ± 0.000652807 (W 0.0028672) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.260597 ± 0.00193443 (W 0.00186245) | 0.259833 ± 0.00271406 (W 0.00278938) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91307 ± 0.00836231 (W 0.00628891) | 1.90193 ± 0.00267908 (W 0.0058055) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.90883 ± 0.00632534 (W 0.00362917) | 1.91456 ± 0.00636744 (W 0.00475939) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.9512 ± 0.0955458 (W 0.0242259) | 15.937 ± 0.106649 (W 0.0447435) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.8886 ± 0.00423448 (W 0.0415181) | 15.8338 ± 0.0272955 (W 0.0367363) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.137997 ± 0.0174285 (W 0.00190366) | 0.137186 ± 0.0180381 (W 0.00213783) | 0.190444 ± 0.017967 (W 0.00207456) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.995652 ± 0.117081 (W 0.00355193) | 1.0358 ± 0.00307763 (W 0.004475) | 0.97921 ± 0.137619 (W 0.00198991) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.63548 ± 0.667327 (W 0.0229672) | 7.12391 ± 0.0708963 (W 0.027153) | 6.0124 ± 0.563433 (W 0.0155162) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n128/b1` | 0.487681 ± 0.00243706 (W 0.00256549) | 0.513334 ± 0.00474846 (W 0.00263031) | 0.761121 ± 0.00138067 (W 0.00208265) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.78922 ± 0.00440696 (W 0.00640948) | 2.93228 ± 0.00814826 (W 0.00875249) | 4.39832 ± 0.00794627 (W 0.0115199) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 18.0957 ± 0.99168 (W 0.0388715) | 18.9996 ± 0.976976 (W 0.0329653) | 30.7629 ± 0.0826348 (W 0.0751024) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.307562 ± 0.00196977 (W 0.00194606) | 0.536101 ± 0.00150276 (W 0.00369733) | 0.371083 ± 0.00125729 (W 0.00170851) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.51708 ± 0.00180656 (W 0.00674187) | 2.8715 ± 0.0144533 (W 0.00750023) | 2.07918 ± 0.00812818 (W 0.00421498) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.58113 ± 0.0227761 (W 0.0189059) | 17.5139 ± 0.0810579 (W 0.0260216) | 14.2858 ± 0.0165948 (W 0.0264205) | 🔵 faer-fork 2.04× faster than `faer-upstream` | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.139429 ± 0.00129591 (W 0.00181511) | 0.136535 ± 0.000925458 (W 0.00233804) | 0.185685 ± 0.00079176 (W 0.00213629) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.771671 ± 0.00732394 (W 0.00230543) | 0.807668 ± 0.00431435 (W 0.00347722) | 0.980944 ± 0.00527127 (W 0.00271088) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.60213 ± 0.0108877 (W 0.0202032) | 7.10191 ± 0.0268081 (W 0.019168) | 6.02016 ± 0.0397497 (W 0.0131041) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.36096 ± 0.00985517 (W 0.00780284) | 3.69117 ± 0.00984461 (W 0.00689711) | 3.29948 ± 0.00992661 (W 0.00742547) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 16.7885 ± 0.0172503 (W 0.0259828) | 18.4437 ± 0.0332585 (W 0.0183337) | 17.722 ± 0.0395956 (W 0.0412913) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.5551 ± 0.0501347 (W 0.11938) | 105.156 ± 0.500483 (W 0.0987278) | 115.749 ± 0.988029 (W 0.436916) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.03316 ± 0.00459038 (W 0.00439044) | 2.69689 ± 0.0138235 (W 0.00344098) | 1.16758 ± 0.00582357 (W 0.00624081) | 🔵 faer-fork 2.61× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.32528 ± 0.00120198 (W 0.0161567) | 12.4123 ± 0.0486051 (W 0.0250002) | 6.8948 ± 0.0198758 (W 0.0154375) | 🔵 faer-fork 1.96× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.9477 ± 0.311819 (W 0.0569583) | 66.1971 ± 0.439962 (W 0.0716821) | 48.1666 ± 0.111786 (W 0.0962062) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004238 ± 0.000173877 (W 5.78792e-05) | 0.004027 ± 1.52753e-05 (W 4.43193e-05) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011711 ± 0.00137477 (W 5.6269e-05) | 0.011431 ± 0.00129019 (W 6.48783e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.040274 ± 0.00469828 (W 0.000288125) | 0.039073 ± 0.00436718 (W 0.000249763) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.073057 ± 0.0014282 (W 0.000571472) | 0.07501 ± 0.00144007 (W 0.00239043) | 0.115105 ± 0.00107906 (W 0.00155771) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.297275 ± 0.00105746 (W 0.00215933) | 0.35962 ± 0.00413327 (W 0.0122005) | 0.407321 ± 0.00339197 (W 0.00602834) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 1.41842 ± 0.0225084 (W 0.00337633) | 1.56644 ± 0.0178348 (W 0.0257897) | 1.92861 ± 0.00861142 (W 0.0111837) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.21458 ± 0.00321094 (W 0.00312166) | 2.16838 ± 0.00178299 (W 0.00480319) | 1.06992 ± 0.00412575 (W 0.00368097) | · | 🔴 faer-fork 2.07× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.37414 ± 0.00367439 (W 0.0076099) | 6.84305 ± 0.0336839 (W 0.0136356) | 4.74677 ± 0.0136875 (W 0.0132118) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.9155 ± 0.110503 (W 0.0254919) | 25.0513 ± 0.0942302 (W 0.0208755) | 21.4822 ± 0.0404857 (W 0.0348322) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.338409 ± 0.00407824 (W 0.00369443) | 0.31152 ± 0.000781038 (W 0.00305327) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.02729 ± 0.00722612 (W 0.00408377) | 2.74953 ± 0.00900286 (W 0.00641085) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 12.9629 ± 0.0460541 (W 0.021312) | 15.3863 ± 0.0310037 (W 0.0185297) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.081391 ± 0.00172413 (W 0.000787526) | 0.079297 ± 0.000676561 (W 0.00116968) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.085058 ± 0.000218756 (W 0.00151953) | 0.082574 ± 0.000604105 (W 0.00107449) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.518966 ± 0.00175755 (W 0.00245383) | 0.513836 ± 0.00609383 (W 0.00335143) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.520969 ± 0.0100976 (W 0.00413313) | 0.521764 ± 0.00412555 (W 0.00224769) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.0922 ± 0.0133954 (W 0.00907676) | 4.06309 ± 0.0347816 (W 0.00878569) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.16922 ± 0.00880316 (W 0.0097581) | 4.10285 ± 0.00593197 (W 0.00566668) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.138018 ± 0.0175705 (W 0.00266046) | 0.152605 ± 0.00181244 (W 0.00503262) | 0.166992 ± 6.22923e-05 (W 0.00147355) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.818598 ± 0.115107 (W 0.00471688) | 0.776906 ± 0.00518716 (W 0.00835904) | 0.374988 ± 0.112524 (W 0.00491324) | · | 🔴 faer-fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.31277 ± 0.0348979 (W 0.0188271) | 4.11857 ± 0.0306353 (W 0.0384571) | 2.63694 ± 0.0328586 (W 0.0145842) | · | 🔴 faer-fork 1.64× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.344412 ± 0.00205455 (W 0.00217857) | 0.573938 ± 0.00485797 (W 0.00325024) | 0.482861 ± 0.0017752 (W 0.00409957) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 1.16833 ± 0.00271544 (W 0.00368896) | 1.95784 ± 0.015751 (W 0.00476463) | 2.00399 ± 0.00460011 (W 0.00606167) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 7.9761 ± 0.94224 (W 0.0122081) | 10.0647 ± 1.07301 (W 0.0228574) | 12.0901 ± 0.0589711 (W 0.0180024) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.219159 ± 0.0013484 (W 0.00214854) | 0.708097 ± 0.0107035 (W 0.0030601) | 0.195875 ± 0.00179894 (W 0.0022365) | 🔵 faer-fork 3.23× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.652277 ± 0.00817069 (W 0.00290196) | 3.06329 ± 0.0113165 (W 0.0186667) | 0.663028 ± 0.00234807 (W 0.00384786) | 🔵 faer-fork 4.70× faster than `faer-upstream` | · |  |
| `qr_factor/n512/b1` | 3.1191 ± 0.0690751 (W 0.00763842) | 16.6132 ± 0.12463 (W 0.356803) | 3.82688 ± 0.00547402 (W 0.00843741) | 🔵 faer-fork 5.33× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.139349 ± 0.00118889 (W 0.00144267) | 0.15024 ± 0.00217826 (W 0.00258943) | 0.165398 ± 0.0004272 (W 0.00223391) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.589691 ± 0.00192066 (W 0.00224103) | 0.719009 ± 0.00819871 (W 0.00831886) | 0.36533 ± 0.000382569 (W 0.00415862) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.14888 ± 0.0340731 (W 0.00897884) | 3.71724 ± 0.0271822 (W 0.0660262) | 1.79478 ± 0.00951979 (W 0.00560825) | 🔴 faer-fork 1.12× slower than `faer-upstream` | 🔴 faer-fork 2.31× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.4783 ± 0.000973756 (W 0.00360998) | 2.8066 ± 0.0216825 (W 0.0127857) | 2.54018 ± 0.00873496 (W 0.00499865) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 10.3564 ± 0.0257702 (W 0.0138905) | 13.4833 ± 0.19851 (W 0.0238851) | 12.0681 ± 0.0505661 (W 0.027487) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 41.1014 ± 0.0505272 (W 0.0250191) | 55.8126 ± 0.114975 (W 0.0971609) | 56.2587 ± 2.28984 (W 0.0728708) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.07325 ± 0.00474889 (W 0.00397355) | 2.18814 ± 0.00126252 (W 0.00481653) | 1.11403 ± 0.00844047 (W 0.00319001) | 🔵 faer-fork 2.04× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 5.11461 ± 0.0076879 (W 0.0128046) | 10.4348 ± 0.0394269 (W 0.0123941) | 6.09054 ± 0.0158754 (W 0.00876476) | 🔵 faer-fork 2.04× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 22.8054 ± 0.158398 (W 0.0325886) | 41.9141 ± 0.0813922 (W 0.048048) | 25.4919 ± 0.0508324 (W 0.0362176) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.00523 ± 9.90471e-05 (W 4.51918e-05) | 0.003667 ± 0.00021997 (W 2.87976e-05) | - | 🔴 faer-fork 1.43× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011682 ± 0.000701533 (W 0.000110051) | 0.010219 ± 0.00141765 (W 9.74279e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.028383 ± 0.00121784 (W 0.000226923) | 0.026449 ± 0.00171465 (W 0.000369166) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.072515 ± 0.000920295 (W 0.000672053) | 0.06992 ± 0.000428253 (W 0.000739356) | 0.115325 ± 0.00205989 (W 0.00249735) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.301101 ± 0.000724788 (W 0.00303016) | 0.349222 ± 0.00212714 (W 0.00529416) | 0.358267 ± 0.000987951 (W 0.00640411) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 1.28415 ± 0.00328127 (W 0.00664314) | 1.49245 ± 0.00432389 (W 0.0318906) | 1.46679 ± 0.0103686 (W 0.00702876) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.18943 ± 0.012919 (W 0.00346252) | 2.17633 ± 0.00499768 (W 0.00863975) | 1.00115 ± 0.0105611 (W 0.00280971) | · | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.14076 ± 0.00958651 (W 0.00929702) | 6.76499 ± 0.117615 (W 0.0224368) | 3.9698 ± 0.0266426 (W 0.00979594) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 21.3619 ± 0.0811643 (W 0.01641) | 23.6346 ± 0.112306 (W 0.0539953) | 15.0865 ± 0.0368732 (W 0.0545098) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.347227 ± 0.00309577 (W 0.00327294) | 0.311822 ± 0.00138961 (W 0.00280091) | - | 🔴 faer-fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.95548 ± 0.00748592 (W 0.00743689) | 2.77614 ± 0.0204759 (W 0.0101944) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 11.7244 ± 0.0706128 (W 0.0314638) | 14.492 ± 0.0493399 (W 0.0314299) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.053931 ± 0.000668911 (W 0.000658095) | 0.096039 ± 0.00120735 (W 0.0013634) | - | 🔵 faer-fork 1.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.057627 ± 0.00165808 (W 0.00126483) | 0.09693 ± 0.00112344 (W 0.00161898) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.278681 ± 0.00664649 (W 0.00311754) | 0.391981 ± 0.0110017 (W 0.0134334) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.287366 ± 0.00186077 (W 0.00272745) | 0.41865 ± 0.00734395 (W 0.0177364) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.24169 ± 0.0230912 (W 0.00945681) | 2.25988 ± 0.351903 (W 0.354805) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.24523 ± 0.0127005 (W 0.0137746) | 2.27088 ± 0.306864 (W 0.341963) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.168674 ± 0.0173272 (W 0.00227004) | 0.148297 ± 0.00264133 (W 0.00365719) | 0.164336 ± 0.000408494 (W 0.00163636) | 🔴 faer-fork 1.14× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.809721 ± 0.122894 (W 0.00231968) | 0.799097 ± 0.0247593 (W 0.0222675) | 0.345565 ± 0.159134 (W 0.00400036) | · | 🔴 faer-fork 2.34× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.00982 ± 0.0302363 (W 0.0149448) | 3.916 ± 0.0620514 (W 0.0685824) | 2.3029 ± 0.0788063 (W 0.0388931) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.319927 ± 0.00228504 (W 0.00177596) | 0.684508 ± 0.0129617 (W 0.00586643) | 0.434721 ± 0.000742694 (W 0.00350585) | 🔵 faer-fork 2.14× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 0.996755 ± 0.199678 (W 0.00236028) | 2.21367 ± 0.0196746 (W 0.00977984) | 1.81478 ± 0.00322173 (W 0.00832467) | 🔵 faer-fork 2.22× faster than `faer-upstream` | 🔵 faer-fork 1.82× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n512/b1` | 5.76073 ± 0.0267382 (W 0.0144179) | 8.44526 ± 0.365064 (W 0.411665) | 10.1631 ± 0.639642 (W 0.0216283) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.76× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.201366 ± 0.000527671 (W 0.00203441) | 0.809657 ± 0.0169634 (W 0.0049217) | 0.15553 ± 0.000922553 (W 0.00161608) | 🔵 faer-fork 4.02× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.596072 ± 0.00884576 (W 0.00306163) | 3.33204 ± 0.0408838 (W 0.0171646) | 0.580453 ± 0.00238057 (W 0.00360759) | 🔵 faer-fork 5.59× faster than `faer-upstream` | · |  |
| `qr_factor/n512/b1` | 1.85579 ± 0.0339681 (W 0.0047075) | 16.7519 ± 0.0563114 (W 0.0625563) | 2.30084 ± 0.00416637 (W 0.00850885) | 🔵 faer-fork 9.03× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.141093 ± 0.000444305 (W 0.00151259) | 0.143888 ± 0.0018594 (W 0.00231123) | 0.160949 ± 0.000280566 (W 0.00166127) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.578747 ± 0.0052795 (W 0.00279698) | 0.704752 ± 0.00721507 (W 0.0231977) | 0.335735 ± 0.00182887 (W 0.0039166) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 3.88735 ± 0.0150497 (W 0.0143761) | 3.59397 ± 0.0241271 (W 0.0588328) | 1.31492 ± 0.00220416 (W 0.00752963) | 🔴 faer-fork 1.08× slower than `faer-upstream` | 🔴 faer-fork 2.96× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.47089 ± 0.00921158 (W 0.00581229) | 2.80177 ± 0.00324409 (W 0.00807884) | 2.40203 ± 0.0172107 (W 0.00886661) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 9.75522 ± 0.0250924 (W 0.00743333) | 13.2859 ± 0.233466 (W 0.022126) | 11.0899 ± 0.0699376 (W 0.0296606) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 35.259 ± 0.0308405 (W 0.0354411) | 52.2222 ± 0.060076 (W 0.0866446) | 47.0254 ± 3.00737 (W 0.0910245) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.12034 ± 0.00833517 (W 0.00410955) | 2.18247 ± 0.0048049 (W 0.0073419) | 1.09341 ± 0.00537686 (W 0.00223885) | 🔵 faer-fork 1.95× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 5.01209 ± 0.0173061 (W 0.00872926) | 10.5405 ± 0.0289498 (W 0.00989615) | 5.94278 ± 0.0110169 (W 0.00785251) | 🔵 faer-fork 2.10× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 20.5254 ± 0.0210088 (W 0.0427912) | 40.1089 ± 0.0563731 (W 0.0393631) | 22.2968 ± 0.129317 (W 0.0605336) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.00506 ± 3.00056e-05 (W 3.09386e-05) | 0.003697 ± 0.000365541 (W 1.58114e-05) | - | 🔴 faer-fork 1.37× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012053 ± 0.000386044 (W 7.04578e-05) | 0.010981 ± 0.000721291 (W 0.000125695) | - | 🔴 faer-fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.02666 ± 0.00121195 (W 0.000192513) | 0.025057 ± 0.00111368 (W 0.000195405) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.064039 ± 0.000229761 (W 4.93173e-05) | 0.05958 ± 0.000112117 (W 0.000171663) | 0.094575 ± 0.00144711 (W 0.000251736) | 🔴 faer-fork 1.07× slower than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.323665 ± 0.00166987 (W 0.00187686) | 0.315186 ± 0.000871727 (W 0.00259507) | 0.455927 ± 0.010375 (W 0.00427012) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06646 ± 0.00958907 (W 0.00796246) | 2.05264 ± 0.00329381 (W 0.0056625) | 3.3241 ± 0.0518435 (W 0.0178886) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.33065 ± 0.00430415 (W 0.00537977) | 2.25253 ± 0.00761032 (W 0.00603758) | 1.81311 ± 0.00613126 (W 0.00685329) | · | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.95529 ± 0.0280213 (W 0.0190967) | 9.76217 ± 0.0163652 (W 0.0137418) | 9.82944 ± 0.0244124 (W 0.0117244) | · | · |  |
| `eigh/n512/b1` | 49.3174 ± 0.3025 (W 0.0744366) | 48.5361 ± 0.242374 (W 0.0722229) | 59.8741 ± 0.106201 (W 0.100514) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.291321 ± 0.000982438 (W 0.00226282) | 0.288849 ± 0.00240267 (W 0.00625185) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.6104 ± 0.0123704 (W 0.00781643) | 2.60582 ± 0.00662611 (W 0.00847258) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 20.6045 ± 0.459243 (W 0.0490105) | 20.4676 ± 0.599067 (W 0.0419626) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254744 ± 0.00138715 (W 0.00257806) | 0.253662 ± 0.000371688 (W 0.00245948) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.254686 ± 0.000599791 (W 0.00252202) | 0.253673 ± 0.000323714 (W 0.00180375) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.86715 ± 0.0274244 (W 0.006353) | 1.86575 ± 0.0257533 (W 0.00397183) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.87294 ± 0.0135117 (W 0.00617923) | 1.87454 ± 0.00574719 (W 0.00453376) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8236 ± 0.112428 (W 0.0518836) | 15.822 ± 0.0965241 (W 0.034186) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.6622 ± 0.0561603 (W 0.0545882) | 15.7176 ± 0.0278972 (W 0.0325349) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145762 ± 0.000535247 (W 0.0025546) | 0.146573 ± 0.00183066 (W 0.00212561) | 0.148367 ± 0.000854291 (W 0.000472971) | · | · |  |
| `lu/n256/b1` | 0.695182 ± 0.117259 (W 0.00408366) | 0.702922 ± 0.116842 (W 0.00398195) | 0.831406 ± 0.000696149 (W 0.00461798) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 5.01783 ± 0.637648 (W 0.00932588) | 5.04002 ± 0.6133 (W 0.011988) | 5.22585 ± 0.00527399 (W 0.00999098) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n128/b1` | 0.453663 ± 0.00279334 (W 0.00329667) | 0.494573 ± 0.000415363 (W 0.003303) | 0.689162 ± 0.00121543 (W 0.00601835) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.67089 ± 0.0125688 (W 0.00583889) | 2.79323 ± 0.010213 (W 0.00425889) | 4.34581 ± 0.0268521 (W 0.00835323) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 17.7605 ± 0.910877 (W 0.0871898) | 17.9525 ± 0.983592 (W 0.0311871) | 30.3325 ± 0.0715202 (W 0.0466746) | · | 🔵 faer-fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.245677 ± 0.00129783 (W 0.00197069) | 0.282746 ± 0.00218848 (W 0.00212594) | 0.335884 ± 0.00219056 (W 0.00239184) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.24731 ± 0.0150934 (W 0.00309595) | 1.37305 ± 0.011027 (W 0.00289965) | 1.9298 ± 0.00647544 (W 0.0060933) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.59349 ± 0.0089382 (W 0.0101885) | 7.98614 ± 0.0351452 (W 0.0134304) | 13.5239 ± 0.00957067 (W 0.0226311) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.78× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.11264 ± 0.00129904 (W 0.00133251) | 0.112129 ± 0.000521028 (W 0.0014494) | 0.146623 ± 0.000340447 (W 0.00206242) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.658169 ± 0.00476939 (W 0.00344822) | 0.659146 ± 0.00381753 (W 0.00249926) | 0.824834 ± 0.00307883 (W 0.00268032) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.0052 ± 0.0140677 (W 0.0119278) | 6.01126 ± 0.0137273 (W 0.0188677) | 5.21598 ± 0.0337822 (W 0.0117865) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.34331 ± 0.0155822 (W 0.00755581) | 3.6749 ± 0.00283822 (W 0.0077825) | 3.21426 ± 0.00552204 (W 0.00627889) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 16.7112 ± 0.00917141 (W 0.0240376) | 18.2994 ± 0.050793 (W 0.0367517) | 17.3185 ± 0.0992081 (W 0.0255566) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 93.8289 ± 0.196769 (W 0.13473) | 104.469 ± 0.360408 (W 0.139015) | 114.245 ± 0.512613 (W 0.574117) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.01203 ± 0.000796735 (W 0.00196068) | 2.60834 ± 0.0146666 (W 0.00357194) | 1.13356 ± 0.00182385 (W 0.00507373) | 🔵 faer-fork 2.58× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.20366 ± 0.0164716 (W 0.0202158) | 12.2312 ± 0.0407966 (W 0.0270068) | 6.77604 ± 0.0426916 (W 0.0143302) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 39.7522 ± 0.349505 (W 0.0328837) | 65.1907 ± 0.484224 (W 0.0572396) | 47.824 ± 0.203264 (W 0.0854827) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004688 ± 0.000462844 (W 2.9399e-05) | 0.004518 ± 0.00016885 (W 2.83602e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013214 ± 0.000820057 (W 7.04982e-05) | 0.012634 ± 0.00135976 (W 5.85423e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.04336 ± 0.00446326 (W 0.00028706) | 0.045304 ± 0.00567651 (W 0.00023885) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.066083 ± 0.00122454 (W 0.000562272) | 0.068798 ± 0.00359953 (W 0.00196198) | 0.091079 ± 0.00031042 (W 0.00222283) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.236031 ± 0.00361864 (W 0.00408367) | 0.293468 ± 0.00421958 (W 0.0141501) | 0.244345 ± 0.0201841 (W 0.0206576) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 0.971529 ± 0.00611462 (W 0.00406397) | 1.12439 ± 0.0140242 (W 0.0288946) | 1.41326 ± 0.0723833 (W 0.0167817) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.20828 ± 0.00377336 (W 0.00445702) | 2.16611 ± 0.00557948 (W 0.00484813) | 1.04835 ± 0.00416569 (W 0.00263975) | · | 🔴 faer-fork 2.11× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.33545 ± 0.00680351 (W 0.00862359) | 6.78551 ± 0.0200425 (W 0.00884087) | 4.64158 ± 0.00701513 (W 0.00472262) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.5229 ± 0.127026 (W 0.0263385) | 24.69 ± 0.0590101 (W 0.0385021) | 20.989 ± 0.0358101 (W 0.0459221) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.316589 ± 0.001755 (W 0.00492064) | 0.289258 ± 0.00125433 (W 0.00250856) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.92854 ± 0.0126906 (W 0.00731127) | 2.61582 ± 0.00972225 (W 0.00865432) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 12.4336 ± 0.0205492 (W 0.0222213) | 14.3617 ± 0.0574514 (W 0.0189645) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.081783 ± 0.000577507 (W 0.00053254) | 0.079689 ± 0.000395324 (W 0.00212972) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.084809 ± 0.00103033 (W 0.000753184) | 0.082554 ± 0.00130697 (W 0.00149108) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.520529 ± 0.00542552 (W 0.00354193) | 0.517263 ± 0.00477987 (W 0.00253181) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.524386 ± 0.00136516 (W 0.00224966) | 0.521922 ± 0.00408535 (W 0.00239885) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.04237 ± 0.00656413 (W 0.0102798) | 4.05936 ± 0.0288936 (W 0.007249) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.17064 ± 0.00689929 (W 0.0085472) | 4.15713 ± 0.00661347 (W 0.00786079) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.144128 ± 0.0187993 (W 0.0016208) | 0.12907 ± 0.000788848 (W 0.0053713) | 0.146292 ± 0.00210914 (W 0.00186506) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.508136 ± 0.116625 (W 0.0036507) | 0.643057 ± 0.00682077 (W 0.0122739) | 0.32274 ± 0.00728773 (W 0.00233476) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 3.76085 ± 0.0115536 (W 0.0115874) | 2.99347 ± 0.0648485 (W 0.0617534) | 1.63628 ± 0.0144779 (W 0.0037465) | 🔴 faer-fork 1.26× slower than `faer-upstream` | 🔴 faer-fork 2.30× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.313025 ± 0.00147548 (W 0.0025861) | 0.554873 ± 0.00538507 (W 0.0022773) | 0.48747 ± 0.0162063 (W 0.00352852) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.04735 ± 0.00231429 (W 0.00170096) | 1.82449 ± 0.0135074 (W 0.00622228) | 2.21125 ± 0.0199733 (W 0.00768798) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔵 faer-fork 2.11× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 7.3727 ± 0.919981 (W 0.00829391) | 8.97155 ± 0.954675 (W 0.014568) | 13.1344 ± 0.0150421 (W 0.0130653) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.78× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.195965 ± 0.00116205 (W 0.00214008) | 0.422749 ± 0.00128447 (W 0.00330903) | 0.181728 ± 0.000498602 (W 0.00193353) | 🔵 faer-fork 2.16× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.563518 ± 0.00526852 (W 0.00255308) | 1.3254 ± 0.00756219 (W 0.00585029) | 0.61253 ± 0.00339934 (W 0.00348007) | 🔵 faer-fork 2.35× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 2.91127 ± 0.00564537 (W 0.00420787) | 4.45848 ± 0.0105774 (W 0.010097) | 3.65692 ± 0.00953645 (W 0.00674184) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.113992 ± 0.000858718 (W 0.00091107) | 0.126186 ± 0.00335746 (W 0.00317762) | 0.146283 ± 0.000380063 (W 0.00207647) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n256/b1` | 0.484472 ± 0.00249104 (W 0.00366582) | 0.573207 ± 0.00665579 (W 0.0124538) | 0.314565 ± 0.00151932 (W 0.00228235) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 3.61452 ± 0.0121986 (W 0.00917512) | 2.7385 ± 0.047026 (W 0.0679955) | 1.61297 ± 0.00558716 (W 0.00581348) | 🔴 faer-fork 1.32× slower than `faer-upstream` | 🔴 faer-fork 2.24× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.45668 ± 0.00349285 (W 0.0035721) | 2.78362 ± 0.0101918 (W 0.00980612) | 2.49131 ± 0.0160537 (W 0.00625535) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 10.2025 ± 0.00978577 (W 0.010399) | 13.3897 ± 0.199876 (W 0.0159381) | 11.9056 ± 0.0878662 (W 0.0248021) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 40.175 ± 0.0266473 (W 0.0344651) | 54.7447 ± 0.0906778 (W 0.0631762) | 55.0483 ± 1.05794 (W 0.0674196) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.05433 ± 0.00304435 (W 0.00242366) | 2.11443 ± 0.00556368 (W 0.00501649) | 1.1097 ± 0.0128807 (W 0.00497756) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 4.98186 ± 0.0125497 (W 0.00522492) | 10.2641 ± 0.0460994 (W 0.0206289) | 6.09935 ± 0.0471759 (W 0.00492102) | 🔵 faer-fork 2.06× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 21.5574 ± 0.0492565 (W 0.0233934) | 40.9296 ± 0.0297419 (W 0.0420637) | 25.6148 ± 0.019841 (W 0.0367267) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.00518 ± 0.000206374 (W 5.81223e-05) | 0.004308 ± 0.00010843 (W 2.90052e-05) | - | 🔴 faer-fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014206 ± 0.000925709 (W 0.000158042) | 0.011692 ± 0.00152597 (W 5.89067e-05) | - | 🔴 faer-fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.036127 ± 0.00176205 (W 0.00042201) | 0.032069 ± 0.00184772 (W 0.000329593) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.066123 ± 0.000300799 (W 0.000339986) | 0.063107 ± 0.0113921 (W 0.000742233) | 0.092423 ± 0.00182878 (W 0.00164711) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.240447 ± 0.000755728 (W 0.00169392) | 0.285292 ± 0.00514889 (W 0.00874004) | 0.203659 ± 0.0388121 (W 0.04374) | 🔵 faer-fork 1.19× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 0.836321 ± 0.00770485 (W 0.00304649) | 1.0051 ± 0.0129651 (W 0.0317405) | 0.949908 ± 0.00924096 (W 0.010811) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.1843 ± 0.00758215 (W 0.00309083) | 2.17785 ± 0.00465935 (W 0.00688009) | 0.979645 ± 0.00504733 (W 0.00300303) | · | 🔴 faer-fork 2.23× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.08197 ± 0.0173407 (W 0.00900531) | 6.73029 ± 0.100045 (W 0.0290902) | 3.8831 ± 0.016361 (W 0.00898627) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 21.0138 ± 0.0805186 (W 0.018674) | 23.2659 ± 0.0678395 (W 0.0553472) | 14.6815 ± 0.0368482 (W 0.0271201) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.327009 ± 0.00155072 (W 0.00341773) | 0.287054 ± 0.00194479 (W 0.00185144) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.84799 ± 0.0191543 (W 0.0124878) | 2.60596 ± 0.00887159 (W 0.0101705) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 11.1759 ± 0.0589076 (W 0.0545563) | 13.4425 ± 0.0367353 (W 0.0206111) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.055073 ± 0.000401528 (W 0.000643989) | 0.096951 ± 0.000160998 (W 0.0010702) | - | 🔵 faer-fork 1.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.056335 ± 0.00134656 (W 0.000824667) | 0.098314 ± 0.000668083 (W 0.00101895) | - | 🔵 faer-fork 1.75× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.28445 ± 0.00295269 (W 0.00119447) | 0.372714 ± 0.00860729 (W 0.0102846) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.29007 ± 0.00137549 (W 0.00290104) | 0.398642 ± 0.0179063 (W 0.0174665) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.18378 ± 0.050723 (W 0.00774004) | 2.28751 ± 0.344869 (W 0.397915) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.24794 ± 0.0104809 (W 0.00993219) | 2.29155 ± 0.32484 (W 0.357868) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.144398 ± 0.0181904 (W 0.00246375) | 0.126767 ± 0.000472035 (W 0.00235149) | 0.148536 ± 0.00169304 (W 0.00210764) | 🔴 faer-fork 1.14× slower than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.499503 ± 23.9334 (W 0.00373365) | 0.630114 ± 0.0010466 (W 0.0182751) | 0.316128 ± 0.125877 (W 0.00213857) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 3.4675 ± 0.00484198 (W 0.00756988) | 2.89974 ± 0.0549632 (W 0.0589512) | 1.22874 ± 0.00278029 (W 0.00567701) | 🔴 faer-fork 1.20× slower than `faer-upstream` | 🔴 faer-fork 2.82× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.291634 ± 0.00248062 (W 0.00210662) | 0.660162 ± 0.00394264 (W 0.00377065) | 0.459446 ± 0.02761 (W 0.00447662) | 🔵 faer-fork 2.26× faster than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 0.879297 ± 0.00437218 (W 0.00208598) | 2.07197 ± 0.0175053 (W 0.00701586) | 2.0589 ± 0.00973657 (W 0.00985131) | 🔵 faer-fork 2.36× faster than `faer-upstream` | 🔵 faer-fork 2.34× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 5.13452 ± 0.0105318 (W 0.0107029) | 7.35215 ± 0.367679 (W 0.03941) | 10.425 ± 0.0179146 (W 0.0216315) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 2.03× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.187469 ± 0.00156058 (W 0.00163309) | 0.528524 ± 0.00769406 (W 0.00396098) | 0.144099 ± 0.00051727 (W 0.00243067) | 🔵 faer-fork 2.82× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.555377 ± 0.00362904 (W 0.00266446) | 1.55791 ± 0.00351578 (W 0.00653519) | 0.548642 ± 0.00322436 (W 0.00291786) | 🔵 faer-fork 2.81× faster than `faer-upstream` | · |  |
| `qr_factor/n512/b1` | 1.75233 ± 0.0039662 (W 0.0058495) | 4.63707 ± 0.0410989 (W 0.0288129) | 2.24578 ± 0.00970537 (W 0.0063517) | 🔵 faer-fork 2.65× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.114674 ± 0.00111576 (W 0.000467431) | 0.120735 ± 0.000837933 (W 0.00161178) | 0.147495 ± 0.000757326 (W 0.00190019) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.475157 ± 0.00166393 (W 0.00254507) | 0.55914 ± 0.0176011 (W 0.0207189) | 0.305018 ± 0.00476509 (W 0.00315664) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 3.33126 ± 0.0320757 (W 0.0124638) | 2.53822 ± 0.0252753 (W 0.0463457) | 1.20443 ± 0.00273999 (W 0.00428574) | 🔴 faer-fork 1.31× slower than `faer-upstream` | 🔴 faer-fork 2.77× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.43797 ± 0.0137066 (W 0.00285076) | 2.77569 ± 0.0034555 (W 0.00463281) | 2.36959 ± 0.00886984 (W 0.00846367) | 🔵 faer-fork 1.14× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 9.65053 ± 0.0183358 (W 0.00831586) | 13.1315 ± 0.209782 (W 0.0235396) | 10.9938 ± 0.0758944 (W 0.0187107) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 34.3559 ± 0.0465774 (W 0.0572214) | 51.3574 ± 0.0932236 (W 0.100883) | 47.1398 ± 0.983134 (W 0.102856) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.10319 ± 0.010452 (W 0.0026476) | 2.1202 ± 0.00506838 (W 0.00917616) | 1.08764 ± 0.0075414 (W 0.00279596) | 🔵 faer-fork 1.92× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 4.85987 ± 0.0113246 (W 0.0110766) | 10.3541 ± 0.0213544 (W 0.0110799) | 5.92021 ± 0.0396623 (W 0.00997318) | 🔵 faer-fork 2.13× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 19.4818 ± 0.0433223 (W 0.0166379) | 39.1241 ± 0.0790977 (W 0.0375141) | 22.4494 ± 0.176119 (W 0.0243362) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.006162 ± 0.000431533 (W 5.01996e-05) | 0.004258 ± 0.000396094 (W 2.29608e-05) | - | 🔴 faer-fork 1.45× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.014177 ± 0.000575877 (W 0.000198166) | 0.012854 ± 0.000888042 (W 3.70702e-05) | - | 🔴 faer-fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.034885 ± 0.00115192 (W 0.000445973) | 0.030557 ± 0.0020237 (W 0.000310519) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.193562 ± 0.00175151 (W 0.00185146) | 0.185747 ± 0.00136312 (W 0.0018395) | 0.474293 ± 0.00191287 (W 0.0022468) | · | 🔵 faer-fork 2.45× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.23232 ± 0.0137105 (W 0.00209148) | 1.23714 ± 0.00850231 (W 0.00523437) | 1.83468 ± 0.0170572 (W 0.00560096) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.93418 ± 0.0211436 (W 0.00844065) | 7.9078 ± 0.0151665 (W 0.0155368) | 11.3719 ± 0.0203616 (W 0.0362057) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.34711 ± 0.0112232 (W 0.00977158) | 3.27436 ± 0.00242705 (W 0.00633906) | 4.38521 ± 0.00420518 (W 0.0113427) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.7372 ± 0.0118005 (W 0.0255329) | 17.4299 ± 0.0162133 (W 0.0209593) | 26.3699 ± 0.0610351 (W 0.031908) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 107.037 ± 0.0772653 (W 0.449205) | 105.58 ± 0.243908 (W 0.117007) | 171.24 ± 0.265198 (W 0.288161) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.802703 ± 0.00760729 (W 0.00648731) | 0.779486 ± 0.00904683 (W 0.00497703) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.93807 ± 0.0470813 (W 0.0165721) | 6.07081 ± 0.00686924 (W 0.0138173) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.8116 ± 0.150319 (W 0.0526202) | 41.07 ± 0.206524 (W 0.0963552) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05178 ± 0.000751016 (W 0.00302794) | 1.05248 ± 0.000461526 (W 0.00408656) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05497 ± 0.00360681 (W 0.00385087) | 1.0466 ± 0.00500386 (W 0.00185337) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.54107 ± 0.0160334 (W 0.0174577) | 7.51534 ± 0.0429303 (W 0.0117409) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.57032 ± 0.0261729 (W 0.0166891) | 7.56565 ± 0.0462947 (W 0.0137661) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8962 ± 0.157353 (W 0.0563304) | 56.9255 ± 0.0777388 (W 0.0850322) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.8539 ± 0.101782 (W 0.100298) | 56.9137 ± 0.0496246 (W 0.0499824) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.336718 ± 0.00176675 (W 0.00275898) | 0.339391 ± 0.00338376 (W 0.00340556) | 0.488538 ± 0.00135623 (W 0.00335299) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.15942 ± 0.0084161 (W 0.00404874) | 2.2496 ± 0.00562808 (W 0.0105778) | 3.23954 ± 0.0139156 (W 0.00834718) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 14.8465 ± 0.0445528 (W 0.058055) | 14.9878 ± 0.060857 (W 0.0429921) | 20.7221 ± 0.0427141 (W 0.0604526) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.53025 ± 0.00500139 (W 0.00497672) | 1.57945 ± 0.00296616 (W 0.00645736) | 2.01154 ± 0.00288032 (W 0.0082183) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.0519 ± 0.023837 (W 0.026353) | 10.2998 ± 0.0170034 (W 0.0122444) | 12.4718 ± 0.0130703 (W 0.0272254) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.2773 ± 0.201622 (W 0.137549) | 69.9235 ± 0.0413921 (W 0.0779504) | 81.2855 ± 0.138245 (W 0.266497) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.771004 ± 0.00331999 (W 0.00218672) | 1.0636 ± 0.00332427 (W 0.00336332) | 0.952378 ± 0.00404779 (W 0.00527125) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.6412 ± 0.0293786 (W 0.00505902) | 6.42848 ± 0.00960048 (W 0.0140154) | 5.7078 ± 0.0280189 (W 0.019324) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.149 ± 0.0605523 (W 0.0623249) | 37.8829 ± 0.0817672 (W 0.0661266) | 39.2124 ± 0.0404482 (W 0.0813156) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.332879 ± 0.000737242 (W 0.00203952) | 0.335947 ± 0.0028689 (W 0.00360482) | 0.476005 ± 0.00176588 (W 0.00310234) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.08797 ± 0.00496781 (W 0.00859102) | 2.18094 ± 0.00756904 (W 0.00639715) | 2.77054 ± 0.00320193 (W 0.00952124) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.8115 ± 0.0718715 (W 0.0268088) | 14.9905 ± 0.0342867 (W 0.0386959) | 18.4559 ± 0.0263718 (W 0.0414391) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.29141 ± 0.00176156 (W 0.0124743) | 5.73612 ± 0.00607857 (W 0.0210768) | 6.96897 ± 0.002413 (W 0.0126696) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 31.8946 ± 0.154144 (W 0.0679802) | 34.1929 ± 0.100838 (W 0.0442205) | 42.9817 ± 0.154359 (W 0.0642537) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 204.101 ± 0.518368 (W 0.340189) | 210.423 ± 0.356119 (W 0.54701) | 277.277 ± 4.19918 (W 0.618824) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.7607 ± 0.00461195 (W 0.00743164) | 3.47246 ± 0.00352129 (W 0.0105913) | 2.7225 ± 0.00818818 (W 0.00822028) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.7783 ± 0.107807 (W 0.0415585) | 19.3379 ± 0.0389582 (W 0.0357259) | 18.068 ± 0.0393312 (W 0.0276985) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 89.1663 ± 0.319543 (W 0.575214) | 110.542 ± 0.778281 (W 0.41786) | 122.419 ± 0.822502 (W 0.257694) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007844 ± 3.27159e-05 (W 2.96648e-05) | 0.007534 ± 6.65833e-05 (W 5.21536e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025027 ± 0.000478123 (W 8.10821e-05) | 0.023955 ± 0.000229444 (W 0.00124073) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.087012 ± 0.000271073 (W 0.000257324) | 0.08591 ± 0.000546923 (W 0.00193773) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.168203 ± 0.000988464 (W 0.00263455) | 0.181007 ± 0.00136597 (W 0.00260801) | 0.477241 ± 0.00380596 (W 0.00304729) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 2.84× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.769517 ± 0.0198106 (W 0.00312187) | 0.803436 ± 0.0150583 (W 0.00784853) | 0.800053 ± 0.00105798 (W 0.0120415) | · | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 3.14199 ± 0.00393356 (W 0.00620742) | 3.38065 ± 0.0883711 (W 0.0866559) | 3.63733 ± 0.0228987 (W 0.0127425) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.58617 ± 0.00760367 (W 0.00266072) | 2.81486 ± 0.00777203 (W 0.00296898) | 1.98193 ± 0.00405191 (W 0.00604716) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 8.67063 ± 0.0233627 (W 0.0106596) | 11.4446 ± 0.0333381 (W 0.0239557) | 9.9622 ± 0.0101246 (W 0.0181367) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 39.5306 ± 0.102318 (W 0.0430557) | 45.1453 ± 0.199504 (W 0.0210154) | 52.4939 ± 0.0915704 (W 0.0694803) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.604399 ± 0.00354154 (W 0.00570418) | 0.774922 ± 0.00613954 (W 0.00383549) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.46497 ± 0.00486315 (W 0.00859419) | 6.04387 ± 0.0475242 (W 0.00752737) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.5199 ± 0.0771917 (W 0.0210156) | 25.5553 ± 0.0978461 (W 0.0157185) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.28482 ± 0.000471161 (W 0.00159321) | 0.281414 ± 0.00150088 (W 0.00188846) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.285682 ± 0.000769323 (W 0.00260398) | 0.282967 ± 0.0001948 (W 0.00134026) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92474 ± 0.0170429 (W 0.00322119) | 1.91883 ± 0.0149938 (W 0.00343685) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94159 ± 0.00905342 (W 0.00218138) | 1.92975 ± 0.021407 (W 0.00588385) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.6076 ± 0.0181562 (W 0.0191316) | 14.6066 ± 0.0449587 (W 0.0144874) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.5688 ± 0.0428888 (W 0.0213797) | 14.6542 ± 0.0370008 (W 0.0206482) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.298748 ± 0.00225877 (W 0.00192258) | 0.318843 ± 0.00221235 (W 0.00338561) | 0.469266 ± 0.00306323 (W 0.00221133) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.33825 ± 0.00310072 (W 0.00348283) | 1.57976 ± 0.0149316 (W 0.0189825) | 1.01467 ± 0.000745187 (W 0.00403126) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.69164 ± 0.0072301 (W 0.0282947) | 7.44646 ± 0.0400346 (W 0.111508) | 6.11554 ± 0.0574843 (W 0.0134383) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.747004 ± 0.00288108 (W 0.00197442) | 1.03954 ± 0.00513777 (W 0.00342812) | 1.07366 ± 0.00770619 (W 0.00393705) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 3.24999 ± 0.00632181 (W 0.0035826) | 4.37079 ± 0.0228336 (W 0.00647257) | 4.83975 ± 0.0175444 (W 0.00899538) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.7697 ± 0.00683245 (W 0.023508) | 22.7469 ± 0.0339933 (W 0.0178437) | 28.6045 ± 0.0700923 (W 0.039739) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.437096 ± 0.000253224 (W 0.00277323) | 1.00474 ± 0.001305 (W 0.00352733) | 0.471598 ± 0.000957864 (W 0.00223863) | 🔵 faer-fork 2.30× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.61062 ± 0.00903891 (W 0.0067318) | 4.69695 ± 0.0167802 (W 0.0182117) | 1.63555 ± 0.00615994 (W 0.00537846) | 🔵 faer-fork 2.92× faster than `faer-upstream` | · |  |
| `qr_factor/n512/b1` | 9.54256 ± 0.0101796 (W 0.0190986) | 21.6028 ± 0.252639 (W 0.0648904) | 11.2855 ± 0.0233718 (W 0.0179533) | 🔵 faer-fork 2.26× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.28921 ± 0.00409126 (W 0.00322995) | 0.312804 ± 0.00138343 (W 0.00304095) | 0.45664 ± 0.00101193 (W 0.00296059) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.27233 ± 0.0129221 (W 0.00536814) | 1.47258 ± 0.0450366 (W 0.0186775) | 0.899384 ± 0.00308659 (W 0.00361507) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n512/b1` | 6.48326 ± 0.0638633 (W 0.0118121) | 7.31589 ± 0.0385453 (W 0.142383) | 5.6891 ± 0.0287109 (W 0.020912) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.18125 ± 0.0125374 (W 0.00557983) | 4.05828 ± 0.00488873 (W 0.0110235) | 4.01387 ± 0.00561355 (W 0.00978536) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 15.1688 ± 0.0386758 (W 0.0271167) | 21.8382 ± 0.297949 (W 0.0224618) | 20.7983 ± 0.0419613 (W 0.0395275) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 73.1006 ± 0.0656025 (W 0.0939298) | 87.4038 ± 0.256826 (W 0.0679887) | 112.334 ± 5.4068 (W 0.178505) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.42413 ± 0.00558323 (W 0.00437641) | 2.97584 ± 0.00648771 (W 0.00567448) | 1.96989 ± 0.0215403 (W 0.00727788) | 🔵 faer-fork 2.09× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.439 ± 0.0706368 (W 0.0132106) | 16.3801 ± 0.0099068 (W 0.010176) | 10.8337 ± 0.0243834 (W 0.0193312) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 38.6901 ± 0.0376188 (W 0.126587) | 57.6619 ± 0.21741 (W 0.072766) | 55.3643 ± 0.142669 (W 0.0974042) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.009037 ± 6.80686e-05 (W 1.67332e-05) | 0.007404 ± 3.21455e-05 (W 3.03315e-05) | - | 🔴 faer-fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.021651 ± 0.000321823 (W 9.52276e-05) | 0.023313 ± 8.14269e-05 (W 6.41194e-05) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.055934 ± 0.000935372 (W 0.000392048) | 0.062537 ± 0.00215441 (W 0.000398762) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.167563 ± 0.00118252 (W 0.00109305) | 0.165879 ± 0.000769 (W 0.00137103) | 0.478731 ± 0.00470172 (W 0.00485066) | · | 🔵 faer-fork 2.86× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.701549 ± 0.0124976 (W 0.00320846) | 0.797789 ± 0.0177077 (W 0.00998863) | 0.659178 ± 0.00521414 (W 0.00487863) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.5275 ± 0.075587 (W 0.00663999) | 2.69972 ± 0.0524619 (W 0.0635862) | 2.28695 ± 0.00998889 (W 0.00999175) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.47375 ± 0.00333424 (W 0.00219643) | 2.80229 ± 0.00240377 (W 0.00430159) | 1.65259 ± 0.00548407 (W 0.00432263) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.70725 ± 0.033468 (W 0.0216544) | 11.0698 ± 0.0440863 (W 0.0260782) | 7.88939 ± 0.0152275 (W 0.0114782) | 🔵 faer-fork 1.44× faster than `faer-upstream` | · |  |
| `eigh/n512/b1` | 30.8144 ± 0.0645388 (W 0.0486777) | 38.8848 ± 0.166074 (W 0.119687) | 36.6705 ± 0.0812332 (W 0.0308424) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.59664 ± 0.00764788 (W 0.00339475) | 0.780257 ± 0.00444278 (W 0.00397687) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.12392 ± 0.0115205 (W 0.0105875) | 6.03899 ± 0.00684756 (W 0.0181453) | - | 🔵 faer-fork 1.93× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 14.0652 ± 0.0590475 (W 0.0377668) | 23.2563 ± 0.0807362 (W 0.0359681) | - | 🔵 faer-fork 1.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.17723 ± 0.000612101 (W 0.00171447) | 0.271537 ± 0.00231541 (W 0.00279646) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.177 ± 0.000446696 (W 0.00175911) | 0.275243 ± 0.000607652 (W 0.00542882) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.99305 ± 0.00146945 (W 0.00207077) | 1.1309 ± 0.0918016 (W 0.0881489) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01064 ± 0.00949539 (W 0.0057097) | 1.13853 ± 0.109707 (W 0.0855597) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 7.95334 ± 0.0451726 (W 0.102731) | 10.3002 ± 0.290168 (W 1.33736) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 7.96385 ± 0.024026 (W 0.0496118) | 10.0992 ± 0.018215 (W 1.32171) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.290973 ± 0.000972381 (W 0.00180684) | 0.301944 ± 0.00217297 (W 0.00144947) | 0.47302 ± 0.0018125 (W 0.00317465) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.21749 ± 0.00326836 (W 0.00374981) | 1.48664 ± 0.00213005 (W 0.0103136) | 0.696106 ± 0.00365578 (W 0.00717499) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 5.28869 ± 0.0446967 (W 0.0267572) | 5.93281 ± 0.0205718 (W 0.0222904) | 3.57564 ± 0.0066836 (W 0.00808789) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.615907 ± 0.00362857 (W 0.00377672) | 1.11824 ± 0.00946452 (W 0.00382693) | 0.806933 ± 0.00325091 (W 0.00300813) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.33895 ± 0.00729063 (W 0.0041533) | 4.26201 ± 0.00612813 (W 0.0402189) | 3.95872 ± 0.00573232 (W 0.00779849) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.69× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 11.8715 ± 0.0331827 (W 0.0155516) | 18.8787 ± 0.00105241 (W 0.234809) | 16.3265 ± 0.015914 (W 0.0299715) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.382724 ± 0.00192536 (W 0.00268026) | 1.06432 ± 0.00633572 (W 0.00540678) | 0.33328 ± 0.00151018 (W 0.0024588) | 🔵 faer-fork 2.78× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.30752 ± 0.00277563 (W 0.0033947) | 4.74847 ± 0.036653 (W 0.0162124) | 1.65931 ± 0.00117408 (W 0.00330943) | 🔵 faer-fork 3.63× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.05415 ± 0.0655633 (W 0.0126746) | 20.0645 ± 0.0824392 (W 0.141399) | 5.7821 ± 0.00865116 (W 0.0120823) | 🔵 faer-fork 3.97× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.285974 ± 0.000608582 (W 0.00242332) | 0.294749 ± 0.00194952 (W 0.00324485) | 0.460647 ± 0.00166912 (W 0.00254458) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.14463 ± 0.0123193 (W 0.00298386) | 1.35407 ± 0.00698154 (W 0.00493086) | 0.667596 ± 0.00321282 (W 0.00403524) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.11053 ± 0.0170372 (W 0.0135198) | 5.75533 ± 0.0291793 (W 0.0367977) | 3.42987 ± 0.0174258 (W 0.0129236) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.00366 ± 0.0167803 (W 0.00637132) | 4.03837 ± 0.0093861 (W 0.0130548) | 3.53057 ± 0.0012751 (W 0.00688141) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.2849 ± 0.0232165 (W 0.0212918) | 21.3044 ± 0.111959 (W 0.0430151) | 16.7739 ± 0.0542087 (W 0.0273073) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 54.6811 ± 0.0950371 (W 0.372613) | 74.4129 ± 0.0702987 (W 0.378314) | 82.9878 ± 0.0530465 (W 0.123669) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.4285 ± 0.00557238 (W 0.00467157) | 2.95876 ± 0.0102832 (W 0.00334454) | 1.874 ± 0.00570545 (W 0.00377496) | 🔵 faer-fork 2.07× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.97133 ± 0.0108272 (W 0.0196482) | 16.3832 ± 0.156154 (W 0.0418622) | 9.53802 ± 0.0132091 (W 0.0215069) | 🔵 faer-fork 2.35× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 31.1023 ± 0.0278672 (W 0.0448244) | 51.3675 ± 0.116227 (W 0.0867502) | 42.6631 ± 0.090591 (W 0.0679122) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.009097 ± 1.52753e-05 (W 2.34798e-05) | 0.007434 ± 5.56776e-05 (W 4.41497e-05) | - | 🔴 faer-fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.020709 ± 0.000121244 (W 8.02135e-05) | 0.023413 ± 0.000420544 (W 7.52144e-05) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.050394 ± 0.00105228 (W 0.000175998) | 0.056907 ± 0.000179918 (W 0.000300661) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.179044 ± 0.000848341 (W 0.0015769) | 0.173624 ± 0.00112214 (W 0.000531284) | 0.408162 ± 0.0024112 (W 0.00241643) | · | 🔵 faer-fork 2.28× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13636 ± 0.00519899 (W 0.00432157) | 1.12735 ± 0.00409749 (W 0.00469897) | 1.58361 ± 0.00975954 (W 0.00607873) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.54226 ± 0.0208915 (W 0.0210057) | 7.54108 ± 0.0121689 (W 0.018591) | 10.6005 ± 0.831923 (W 0.0258385) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 3.32842 ± 0.0199642 (W 0.00794012) | 3.2647 ± 0.010062 (W 0.00888802) | 4.33736 ± 0.00211054 (W 0.023202) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.6148 ± 0.0583971 (W 0.0171821) | 17.3524 ± 0.05768 (W 0.03208) | 26.086 ± 0.0444263 (W 0.0384769) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 106.436 ± 0.284101 (W 0.361466) | 105.197 ± 0.0823797 (W 0.0737434) | 169.944 ± 0.349254 (W 0.169609) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.77963 ± 0.0101692 (W 0.00638609) | 0.746043 ± 0.00860916 (W 0.00724142) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.81493 ± 0.0354271 (W 0.0225482) | 5.78 ± 0.00767787 (W 0.0192204) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 39.9362 ± 0.085727 (W 0.041485) | 39.988 ± 0.206866 (W 0.0640006) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.0393 ± 0.00254713 (W 0.00361107) | 1.03137 ± 0.00272516 (W 0.00295975) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.03953 ± 0.00222278 (W 0.00113775) | 1.03604 ± 0.00530355 (W 0.00306048) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.4556 ± 0.0276533 (W 0.0084308) | 7.40298 ± 0.0489732 (W 0.0184434) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.49724 ± 0.0444355 (W 0.0099839) | 7.50006 ± 0.0435301 (W 0.00735282) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.7049 ± 0.107865 (W 0.0784536) | 56.7638 ± 0.174365 (W 0.0579891) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7786 ± 0.119156 (W 0.0367007) | 56.6882 ± 0.0173113 (W 0.118885) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.309378 ± 0.00117771 (W 0.00261932) | 0.305501 ± 0.000371273 (W 0.00213314) | 0.448808 ± 0.00200753 (W 0.00228919) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.05111 ± 0.00771361 (W 0.00537566) | 2.04176 ± 0.00524566 (W 0.00584651) | 3.07622 ± 0.0121803 (W 0.00818796) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 13.9725 ± 0.0427396 (W 0.0237329) | 13.9538 ± 0.0337797 (W 0.0127612) | 19.8539 ± 0.268769 (W 0.0666796) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.50938 ± 0.00716805 (W 0.00275533) | 1.54955 ± 0.00260625 (W 0.00332409) | 1.98887 ± 0.00328184 (W 0.00568064) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 9.98791 ± 0.00552437 (W 0.0139946) | 10.0836 ± 0.00651257 (W 0.0237165) | 12.4518 ± 0.0182275 (W 0.0253773) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 68.5551 ± 0.11564 (W 0.142467) | 69.0025 ± 0.0414005 (W 0.0752172) | 80.4471 ± 0.0957427 (W 0.0950464) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.700127 ± 0.00187013 (W 0.00295315) | 0.74685 ± 0.00428894 (W 0.00284227) | 0.904993 ± 0.00111957 (W 0.00388578) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.32206 ± 0.0345805 (W 0.00863211) | 4.49992 ± 0.0308422 (W 0.0135698) | 5.58507 ± 0.0357777 (W 0.0191314) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.3605 ± 0.102152 (W 0.0378487) | 29.0176 ± 0.0180524 (W 0.039594) | 38.2419 ± 0.126282 (W 0.0526075) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.307141 ± 0.00156818 (W 0.00215417) | 0.302793 ± 0.0027089 (W 0.00321695) | 0.434037 ± 0.00268295 (W 0.00337887) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.98197 ± 0.00450221 (W 0.00499346) | 1.97623 ± 0.0067666 (W 0.00660882) | 2.61284 ± 0.0220774 (W 0.006277) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.0228 ± 0.0626592 (W 0.0389346) | 13.9649 ± 0.0570855 (W 0.047023) | 17.1907 ± 0.221584 (W 0.0407129) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.25071 ± 0.0107553 (W 0.0141779) | 5.71143 ± 0.0200179 (W 0.0168729) | 6.88086 ± 0.00625266 (W 0.0143652) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 31.6403 ± 0.14585 (W 0.0501893) | 33.8515 ± 0.134639 (W 0.064978) | 42.9886 ± 1.43055 (W 0.130851) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 202.741 ± 0.592407 (W 0.767163) | 209.218 ± 0.784523 (W 0.482294) | 307.542 ± 1.9087 (W 0.500066) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.7147 ± 0.0168107 (W 0.00475048) | 3.45075 ± 0.00829327 (W 0.00732851) | 2.67273 ± 0.0158867 (W 0.00642337) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4705 ± 0.0689163 (W 0.0759385) | 18.963 ± 0.0149651 (W 0.0315697) | 17.8982 ± 1.6311 (W 0.0267748) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 88.17 ± 0.454117 (W 0.503787) | 109.51 ± 0.363741 (W 0.469736) | 153.209 ± 2.27554 (W 0.401962) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.74× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.006923 ± 0.000465371 (W 4.02492e-05) | 0.007193 ± 0.000573099 (W 2.18678e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022191 ± 0.00150332 (W 0.000159988) | 0.022512 ± 0.00152086 (W 0.000123288) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.086881 ± 0.00222944 (W 0.000474389) | 0.086822 ± 0.00238427 (W 0.000476314) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.157203 ± 0.0016462 (W 0.00183493) | 0.167883 ± 0.000610813 (W 0.00296032) | 0.407389 ± 0.00383351 (W 0.00357649) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 2.59× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.665178 ± 0.00502629 (W 0.00247273) | 0.711303 ± 0.0045288 (W 0.00617017) | 0.589297 ± 0.00102306 (W 0.0102033) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.77458 ± 0.00849757 (W 0.00936364) | 3.01965 ± 0.00785359 (W 0.109525) | 3.18341 ± 0.00403832 (W 0.0163887) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.57933 ± 0.0140353 (W 0.00619475) | 2.8105 ± 0.00617632 (W 0.00149621) | 1.93654 ± 0.00256018 (W 0.0044899) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 8.58055 ± 0.019202 (W 0.0145116) | 11.3163 ± 0.0321857 (W 0.0178194) | 9.78978 ± 0.0204914 (W 0.0228168) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 39.1164 ± 0.0760349 (W 0.0286518) | 44.7676 ± 0.177591 (W 0.0348188) | 51.9712 ± 0.0662854 (W 0.0578179) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.583916 ± 0.00751036 (W 0.00309314) | 0.74113 ± 0.00778257 (W 0.00566401) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.32481 ± 0.00760667 (W 0.0118555) | 5.76263 ± 0.0301852 (W 0.0168351) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.7787 ± 0.0617178 (W 0.0216435) | 24.5376 ± 0.00411262 (W 0.039639) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.287355 ± 0.00174731 (W 0.00217586) | 0.279811 ± 0.00176921 (W 0.00116751) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.286775 ± 0.0012065 (W 0.00213695) | 0.281494 ± 0.00144205 (W 0.00248343) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92126 ± 0.00763253 (W 0.00296217) | 1.89968 ± 0.00565171 (W 0.0033817) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92286 ± 0.0116011 (W 0.00248824) | 1.90029 ± 0.012735 (W 0.00348789) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.641 ± 0.010277 (W 0.0287736) | 14.6334 ± 0.0193773 (W 0.023745) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6382 ± 0.0415925 (W 0.0266766) | 14.6829 ± 0.0275463 (W 0.0183324) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.272998 ± 0.00160111 (W 0.0020671) | 0.285812 ± 0.00288972 (W 0.00197177) | 0.444768 ± 0.00141026 (W 0.00245051) | · | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.23852 ± 0.00354768 (W 0.00355147) | 1.39196 ± 0.013058 (W 0.0121049) | 0.970717 ± 0.00182408 (W 0.00559936) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 5.83145 ± 0.0233587 (W 0.0138443) | 6.52738 ± 0.0570854 (W 0.154696) | 5.79109 ± 0.0132533 (W 0.0202555) | 🔵 faer-fork 1.12× faster than `faer-upstream` | · |  |
| `qr/n128/b1` | 0.721843 ± 0.00131971 (W 0.00272265) | 0.998003 ± 0.00755587 (W 0.00339655) | 1.08704 ± 0.00472052 (W 0.00459976) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 3.14209 ± 0.00892623 (W 0.0070902) | 4.15125 ± 0.00838758 (W 0.00363998) | 5.03501 ± 0.00924355 (W 0.0192345) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.842 ± 0.0311748 (W 0.0127367) | 21.6558 ± 0.0478559 (W 0.0156058) | 28.9068 ± 0.0722347 (W 0.0399384) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.406256 ± 0.00360316 (W 0.00236079) | 0.655303 ± 0.00264526 (W 0.0030218) | 0.453457 ± 0.00270751 (W 0.00285769) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.5228 ± 0.00602311 (W 0.00408904) | 2.53686 ± 0.00892456 (W 0.00733416) | 1.57329 ± 0.00267561 (W 0.00357641) | 🔵 faer-fork 1.67× faster than `faer-upstream` | · |  |
| `qr_factor/n512/b1` | 8.81396 ± 0.0135103 (W 0.0122337) | 10.6606 ± 0.0295017 (W 0.0132604) | 10.8681 ± 0.0192776 (W 0.0107124) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.261146 ± 0.00387784 (W 0.00182301) | 0.277849 ± 0.00142759 (W 0.00329316) | 0.433386 ± 0.00123949 (W 0.00305815) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.15071 ± 0.00729454 (W 0.00503431) | 1.26253 ± 0.0131888 (W 0.0132906) | 0.863527 ± 0.00195794 (W 0.00436531) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.68324 ± 0.0447425 (W 0.0168166) | 6.28237 ± 0.0718593 (W 0.0755431) | 5.33898 ± 0.0122347 (W 0.0157744) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.14508 ± 0.00172235 (W 0.00652146) | 4.03813 ± 0.00646792 (W 0.017534) | 3.94515 ± 0.0091047 (W 0.00436949) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 14.8538 ± 0.0128438 (W 0.0185972) | 21.6342 ± 0.245675 (W 0.041135) | 20.4998 ± 0.0265744 (W 0.0234101) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 72.1228 ± 0.236242 (W 0.125952) | 86.1008 ± 0.09953 (W 0.116671) | 110.474 ± 0.178259 (W 0.632979) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.39816 ± 0.00624648 (W 0.0037742) | 2.94329 ± 0.0126849 (W 0.00484107) | 1.95615 ± 0.00203191 (W 0.00472676) | 🔵 faer-fork 2.11× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.27114 ± 0.0269784 (W 0.0133995) | 16.188 ± 0.0341694 (W 0.0246315) | 10.8291 ± 0.0164259 (W 0.0231) | 🔵 faer-fork 2.23× faster than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 37.7582 ± 0.24679 (W 0.103458) | 56.7912 ± 0.206371 (W 0.0765091) | 54.952 ± 0.176662 (W 0.0825673) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007975 ± 2.46374e-05 (W 3.32009e-05) | 0.007133 ± 0.000506068 (W 3.08107e-05) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.02161 ± 0.00113319 (W 0.000230324) | 0.022692 ± 0.00135601 (W 0.000112456) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.057637 ± 0.00166607 (W 0.000770219) | 0.062187 ± 0.00339599 (W 0.000348729) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.15568 ± 0.0018127 (W 0.0018781) | 0.153626 ± 0.000799392 (W 0.00214554) | 0.411739 ± 0.00215058 (W 0.00168028) | · | 🔵 faer-fork 2.64× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.61075 ± 0.00278924 (W 0.00332355) | 0.691388 ± 0.0207308 (W 0.0175546) | 0.462974 ± 0.00396904 (W 0.00433486) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 2.1653 ± 0.0211021 (W 0.0075999) | 2.36146 ± 0.00789527 (W 0.0553007) | 1.82919 ± 0.0288658 (W 0.0256571) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.46811 ± 0.00130052 (W 0.0071182) | 2.79724 ± 0.00479505 (W 0.00299982) | 1.60716 ± 0.00688661 (W 0.00574529) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.60205 ± 0.00789435 (W 0.0124248) | 10.9723 ± 0.0408924 (W 0.0317231) | 7.74762 ± 0.017717 (W 0.0116349) | 🔵 faer-fork 1.44× faster than `faer-upstream` | · |  |
| `eigh/n512/b1` | 30.4168 ± 0.0345811 (W 0.0298448) | 38.5473 ± 0.114711 (W 0.175293) | 36.1943 ± 0.0482926 (W 0.0242333) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.577428 ± 0.00457201 (W 0.00519181) | 0.74098 ± 0.00445493 (W 0.0043881) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.98158 ± 0.00815163 (W 0.00910971) | 5.76044 ± 0.0251814 (W 0.0200715) | - | 🔵 faer-fork 1.93× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 13.2782 ± 0.00731721 (W 0.0238619) | 22.1072 ± 0.0227126 (W 0.0212114) | - | 🔵 faer-fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.180065 ± 0.00146284 (W 0.00203196) | 0.267488 ± 0.000537243 (W 0.00177954) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.179304 ± 0.00185832 (W 0.000575808) | 0.26795 ± 0.000747222 (W 0.00310952) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.00072 ± 0.00413444 (W 0.00382843) | 1.12763 ± 0.018075 (W 0.0905605) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01209 ± 0.00288643 (W 0.00267248) | 1.19303 ± 0.0902764 (W 0.0907679) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.07499 ± 0.180269 (W 0.0423703) | 10.0425 ± 1.28989 (W 1.35968) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.09588 ± 0.183647 (W 0.0811558) | 10.1148 ± 1.33756 (W 1.38117) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.263861 ± 0.00108274 (W 0.00218344) | 0.270445 ± 0.000980786 (W 0.00260636) | 0.447534 ± 0.000963594 (W 0.00295545) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.11464 ± 0.000782293 (W 0.00315509) | 1.2863 ± 0.00290703 (W 0.0116397) | 0.673724 ± 0.00799186 (W 0.00745006) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 4.48113 ± 0.0302126 (W 0.01192) | 5.05364 ± 0.0221518 (W 0.0219863) | 3.44672 ± 0.00734861 (W 0.0113596) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.588097 ± 0.00324916 (W 0.00203431) | 1.08392 ± 0.0055691 (W 0.00518142) | 0.825046 ± 0.00417725 (W 0.00531755) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.23807 ± 0.0142146 (W 0.00500328) | 4.07762 ± 0.0104744 (W 0.0356695) | 4.17839 ± 0.00508914 (W 0.00836115) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.87× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 10.9867 ± 0.0200532 (W 0.0106645) | 18.0383 ± 0.155006 (W 0.28981) | 17.1923 ± 0.244472 (W 0.024517) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.363248 ± 0.000598113 (W 0.00205493) | 0.734 ± 0.00395726 (W 0.00301285) | 0.31612 ± 0.000402963 (W 0.00243549) | 🔵 faer-fork 2.02× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.24401 ± 0.00214769 (W 0.00268774) | 2.61652 ± 0.00792465 (W 0.016047) | 1.6129 ± 0.0037916 (W 0.0029179) | 🔵 faer-fork 2.10× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.7369 ± 0.0119414 (W 0.0111048) | 9.72448 ± 0.0309828 (W 0.182973) | 5.60048 ± 0.0108731 (W 0.008994) | 🔵 faer-fork 2.05× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.258982 ± 0.00116581 (W 0.00197576) | 0.262258 ± 0.00193202 (W 0.00138146) | 0.433829 ± 0.00191927 (W 0.00279402) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.03546 ± 0.0149961 (W 0.00363164) | 1.15284 ± 0.011715 (W 0.01314) | 0.653349 ± 0.00390966 (W 0.00431574) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.31838 ± 0.0682034 (W 0.00909166) | 4.8853 ± 0.0246387 (W 0.022953) | 3.29181 ± 0.0155988 (W 0.00832629) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.97529 ± 0.00999424 (W 0.00660587) | 4.02694 ± 0.00694471 (W 0.00956986) | 3.47723 ± 0.00168605 (W 0.0155569) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.9516 ± 0.00890515 (W 0.0157142) | 20.9653 ± 0.125746 (W 0.0472536) | 16.656 ± 0.0190181 (W 0.0341715) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 53.6646 ± 0.190931 (W 0.0757401) | 73.6195 ± 0.237437 (W 0.313841) | 80.5893 ± 0.181908 (W 0.107145) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.4026 ± 0.00517781 (W 0.00332756) | 2.92883 ± 0.00309917 (W 0.00558567) | 1.86049 ± 0.00598665 (W 0.00431623) | 🔵 faer-fork 2.09× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.77901 ± 0.0237104 (W 0.0112568) | 16.1576 ± 0.150991 (W 0.0229985) | 9.53932 ± 0.0265386 (W 0.0289515) | 🔵 faer-fork 2.38× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 30.1513 ± 0.0827191 (W 0.0695166) | 50.3582 ± 0.159315 (W 0.0577224) | 42.3598 ± 0.293001 (W 0.043846) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007995 ± 3.78594e-05 (W 1.49064e-05) | 0.007183 ± 0.000104739 (W 3.3544e-05) | - | 🔴 faer-fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.020889 ± 0.00121402 (W 7.51479e-05) | 0.020839 ± 0.00135378 (W 0.00210086) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.055854 ± 0.000767556 (W 0.000431787) | 0.060533 ± 0.000281052 (W 0.000488364) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.836 ± 0.00236622 (W 0.00365731) | 0.816271 ± 0.00113692 (W 0.00525581) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 50.1451 ± 0.733397 (W 0.16301) | 54.2756 ± 0.548008 (W 0.983333) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.555386 ± 0.0017182 (W 0.00267114) | 0.553914 ± 0.0026794 (W 0.00373049) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.552912 ± 0.000981699 (W 0.0020929) | 0.550407 ± 0.00556959 (W 0.00338955) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1534 ± 0.146149 (W 0.0408419) | 35.141 ± 0.0977961 (W 0.0692509) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.2597 ± 0.0341063 (W 0.127176) | 35.1304 ± 0.0485635 (W 0.0686969) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.489283 ± 0.00130387 (W 0.00162359) | 0.468953 ± 0.00352183 (W 0.00346828) | 0.663288 ± 0.131569 (W 0.00440577) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.5488 ± 0.210728 (W 0.0473065) | 19.0038 ± 0.0104145 (W 0.0401358) | 18.5266 ± 2.73191 (W 0.0995283) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.44647 ± 0.00505061 (W 0.00452177) | 1.55291 ± 0.00376352 (W 0.00324401) | 1.88052 ± 0.0108416 (W 0.00698923) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 70.7493 ± 0.484602 (W 0.255813) | 74.6213 ± 0.212092 (W 0.482849) | 82.1227 ± 0.496815 (W 0.438486) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 0.938057 ± 0.00367604 (W 0.00291953) | 1.86982 ± 0.00504281 (W 0.00509059) | 0.917402 ± 0.00323072 (W 0.00431153) | 🔵 faer-fork 1.99× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 30.8944 ± 0.0933912 (W 0.134569) | 78.3783 ± 0.229158 (W 0.104318) | 35.0412 ± 0.243341 (W 0.130651) | 🔵 faer-fork 2.54× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.29636 ± 0.00566898 (W 0.00587421) | 2.50762 ± 0.00479219 (W 0.00748846) | 3.04569 ± 0.00242655 (W 0.00872958) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 86.1431 ± 0.0212099 (W 0.177688) | 89.0564 ± 0.25565 (W 0.394015) | 120.919 ± 3.9289 (W 0.190452) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.04765 ± 0.00234765 (W 0.00388406) | 1.48898 ± 0.00850288 (W 0.0132355) | 1.38532 ± 0.0121849 (W 0.00533354) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 38.4959 ± 0.127498 (W 0.101743) | 44.9399 ± 0.0736528 (W 0.0737315) | 46.7559 ± 0.139041 (W 0.177046) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.601691 ± 0.00552771 (W 0.00182269) | 0.814687 ± 0.0038817 (W 0.00532611) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.0358 ± 0.168605 (W 0.03238) | 21.4426 ± 0.589124 (W 0.0493318) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.165619 ± 0.00439998 (W 0.00362746) | 0.156762 ± 0.000735008 (W 0.00237263) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.168495 ± 0.00403198 (W 0.00427788) | 0.157264 ± 0.00410664 (W 0.00162783) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 9.47669 ± 0.030978 (W 0.024308) | 9.3466 ± 0.114775 (W 0.021473) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 9.48077 ± 0.0326415 (W 0.0125106) | 9.41748 ± 0.0111991 (W 0.0147026) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.456422 ± 0.00435995 (W 0.00278769) | 0.436042 ± 0.00772911 (W 0.00534337) | 0.325176 ± 0.116807 (W 0.00279161) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.45501 ± 0.132753 (W 0.0740692) | 12.7218 ± 0.0468487 (W 0.035957) | 16.8894 ± 2.0033 (W 0.0546023) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.79× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 0.844015 ± 0.00864818 (W 0.00325643) | 1.19838 ± 0.00537358 (W 0.0335335) | 1.06237 ± 0.00460741 (W 0.00752176) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 25.2281 ± 2.77297 (W 0.148108) | 34.1636 ± 0.0602132 (W 0.0607953) | 30.2298 ± 0.227727 (W 0.0666445) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.600251 ± 0.00306557 (W 0.00335918) | 3.27711 ± 0.256354 (W 0.161095) | 0.462041 ± 0.00644059 (W 0.00379305) | 🔵 faer-fork 5.46× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 12.882 ± 0.29934 (W 0.037796) | 73.232 ± 0.75942 (W 0.541003) | 12.7885 ± 0.125475 (W 0.0322994) | 🔵 faer-fork 5.68× faster than `faer-upstream` | · |  |
| `svd_thin/1024x64/b1` | 1.75919 ± 0.0038414 (W 0.00339993) | 2.1527 ± 0.00511619 (W 0.00823231) | 1.86893 ± 0.00721552 (W 0.00415826) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 39.9514 ± 0.194848 (W 0.0905215) | 47.9812 ± 0.396881 (W 0.108025) | 48.5103 ± 1.79428 (W 0.18329) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 0.907363 ± 0.0011215 (W 0.00411243) | 1.53944 ± 0.0114395 (W 0.00405817) | 0.938158 ± 0.0070058 (W 0.00720514) | 🔵 faer-fork 1.70× faster than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 23.1667 ± 0.0284098 (W 0.0452527) | 32.6758 ± 0.0562051 (W 0.0522369) | 22.5384 ± 0.160768 (W 0.0721487) | 🔵 faer-fork 1.41× faster than `faer-upstream` | · |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.592355 ± 0.00664562 (W 0.00327339) | 0.814638 ± 0.00409184 (W 0.00450225) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 12.1591 ± 0.0961608 (W 0.0801755) | 16.0799 ± 0.839297 (W 0.767722) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.1015 ± 0.00444456 (W 0.00611142) | 0.139921 ± 0.00629221 (W 0.00562009) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.102531 ± 0.00236706 (W 0.00401017) | 0.140752 ± 0.00664064 (W 0.008213) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 5.62143 ± 0.0838703 (W 0.0329146) | 5.05118 ± 0.934968 (W 0.892041) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.67605 ± 0.0175816 (W 0.067649) | 6.64715 ± 0.947478 (W 0.0555244) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.452394 ± 4.93727 (W 0.00369131) | 0.433697 ± 0.00391973 (W 0.00290468) | 0.309096 ± 0.174083 (W 0.00445001) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.28886 ± 0.233039 (W 0.0379516) | 11.7715 ± 0.02218 (W 0.0272498) | 7.29297 ± 1.89266 (W 0.0372853) | 🔵 faer-fork 1.42× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 0.754078 ± 0.00418903 (W 0.00189358) | 1.20328 ± 0.0105436 (W 0.0305953) | 0.882316 ± 0.00257537 (W 0.00886806) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 18.8939 ± 2.79183 (W 0.0592081) | 33.0372 ± 0.129921 (W 0.557551) | 20.8906 ± 0.098134 (W 0.0470202) | 🔵 faer-fork 1.75× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.561045 ± 0.00851369 (W 0.00324028) | 3.21174 ± 0.0809061 (W 0.133531) | 0.322551 ± 0.000901369 (W 0.00249448) | 🔵 faer-fork 5.72× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 9.78844 ± 0.0214061 (W 0.0341005) | 71.4153 ± 0.352263 (W 0.172533) | 7.31997 ± 0.0618172 (W 0.04114) | 🔵 faer-fork 7.30× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 1.66591 ± 0.00914809 (W 0.0082189) | 2.22461 ± 0.00962514 (W 0.00879128) | 1.65293 ± 0.00522497 (W 0.0052408) | 🔵 faer-fork 1.34× faster than `faer-upstream` | · |  |
| `svd_thin/4096x256/b1` | 33.7316 ± 0.926789 (W 0.0888087) | 46.5139 ± 0.422408 (W 0.541802) | 36.3658 ± 2.01459 (W 0.322313) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 0.878095 ± 0.00382508 (W 0.00725353) | 1.60448 ± 0.00526253 (W 0.00799013) | 0.805842 ± 0.00193999 (W 0.00189514) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 20.6158 ± 0.0271213 (W 0.0356352) | 33.3706 ± 0.0746828 (W 0.0748039) | 16.8019 ± 0.0223315 (W 0.0628536) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.734648 ± 0.00340309 (W 0.00567627) | 0.733676 ± 0.00421555 (W 0.00337843) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.5115 ± 0.756091 (W 0.0640165) | 47.5332 ± 0.153315 (W 0.109774) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.595198 ± 0.00296037 (W 0.00251255) | 0.595269 ± 0.00310708 (W 0.00196396) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.591522 ± 0.0123892 (W 0.00327843) | 0.588979 ± 0.011041 (W 0.00362293) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.6991 ± 0.0427662 (W 0.0358737) | 35.7795 ± 0.0675299 (W 0.0495325) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.7667 ± 0.0105203 (W 0.0593979) | 35.7891 ± 0.0657705 (W 0.0806482) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.383524 ± 0.0018649 (W 0.00325779) | 0.384547 ± 0.000382802 (W 0.00296783) | 0.284269 ± 0.00136582 (W 0.00234088) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2724 ± 0.0286318 (W 0.0297357) | 13.2753 ± 0.0435914 (W 0.0282215) | 11.9008 ± 0.0962673 (W 0.0201946) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.32459 ± 0.00671609 (W 0.0034555) | 1.46565 ± 0.00119366 (W 0.00317668) | 1.58778 ± 0.00205727 (W 0.00642583) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 67.8925 ± 0.26077 (W 0.416148) | 68.9387 ± 0.299194 (W 0.0882111) | 69.4563 ± 0.486852 (W 0.13802) | · | · |  |
| `qr_factor/1024x64/b1` | 0.624412 ± 0.0222141 (W 0.00314486) | 0.778389 ± 0.0132671 (W 0.00232655) | 0.768444 ± 0.00236457 (W 0.0018842) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 24.9863 ± 0.281486 (W 0.0412403) | 25.9669 ± 0.207837 (W 0.0564737) | 29.0785 ± 0.193626 (W 0.048647) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.24647 ± 0.00392942 (W 0.00583) | 2.45551 ± 0.00512607 (W 0.00632689) | 2.80818 ± 0.00482869 (W 0.00617655) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 80.6952 ± 0.100028 (W 0.120224) | 83.4363 ± 0.153748 (W 0.183543) | 108.969 ± 0.958644 (W 0.144804) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 0.954508 ± 0.00224414 (W 0.00233053) | 1.40426 ± 0.00612816 (W 0.0052573) | 1.23928 ± 0.00571082 (W 0.00385021) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 32.6506 ± 0.041512 (W 0.0752481) | 39.301 ± 0.00348001 (W 0.0610663) | 39.652 ± 0.529452 (W 0.0546573) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.50468 ± 0.00396451 (W 0.00438854) | 0.724489 ± 0.00354653 (W 0.00314579) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 14.5548 ± 0.0573117 (W 0.0741105) | 14.9617 ± 0.0901721 (W 0.0334251) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.202788 ± 0.00361636 (W 0.000865473) | 0.19861 ± 0.000617253 (W 0.00213629) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.205403 ± 0.00280215 (W 0.00139797) | 0.200353 ± 0.00132782 (W 0.00304296) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.8565 ± 0.202031 (W 0.0229774) | 10.8361 ± 0.166842 (W 0.0213248) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.1619 ± 0.156737 (W 0.0117379) | 11.1088 ± 0.142033 (W 0.0151751) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.351076 ± 0.00073775 (W 0.00306896) | 0.357736 ± 0.00402308 (W 0.00266229) | 0.281506 ± 0.00382131 (W 0.00228465) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.95641 ± 0.00864284 (W 0.0124186) | 7.00764 ± 0.0068754 (W 0.0148199) | 11.6829 ± 0.0200141 (W 0.0324602) | · | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 0.724342 ± 0.00378366 (W 0.00363111) | 1.13048 ± 0.00861445 (W 0.0315536) | 0.983695 ± 0.00655163 (W 0.00624078) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.1617 ± 2.82408 (W 0.0705672) | 28.1326 ± 0.0258785 (W 0.0726387) | 26.9234 ± 0.131202 (W 0.102589) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.485904 ± 0.0229366 (W 0.002709) | 0.81415 ± 0.00912884 (W 0.00357179) | 0.420232 ± 0.00375962 (W 0.00574779) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 10.4072 ± 0.244892 (W 0.0270525) | 15.1792 ± 0.241331 (W 0.0127688) | 11.2604 ± 0.118213 (W 0.0664767) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 1.70118 ± 0.00471816 (W 0.00572531) | 2.10281 ± 0.00289667 (W 0.00369567) | 1.80446 ± 0.00336627 (W 0.00813181) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 34.3665 ± 0.052935 (W 0.0770537) | 42.5546 ± 0.351751 (W 0.0649247) | 45.263 ± 0.277999 (W 0.0876428) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 0.833553 ± 0.00115581 (W 0.00245717) | 1.45676 ± 0.00238249 (W 0.00367716) | 0.900376 ± 0.00729655 (W 0.0100535) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 17.3489 ± 0.0223433 (W 0.0321117) | 26.969 ± 0.0117055 (W 0.0427553) | 20.9056 ± 0.0985225 (W 0.099171) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.495845 ± 0.00371425 (W 0.0028299) | 0.729628 ± 0.00391729 (W 0.00337668) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 9.77917 ± 0.077361 (W 0.0383123) | 10.3032 ± 0.00611903 (W 0.0151691) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.1287 ± 0.000527854 (W 0.00170084) | 0.184754 ± 0.00289696 (W 0.003226) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.131375 ± 0.00109477 (W 0.00183102) | 0.176799 ± 0.00131302 (W 0.0068359) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 8.70522 ± 0.134613 (W 0.0414191) | 8.01969 ± 0.049508 (W 0.624623) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 8.79134 ± 0.0964619 (W 0.0281008) | 7.10641 ± 0.546334 (W 0.696513) | - | 🔴 faer-fork 1.24× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.344692 ± 0.00142318 (W 0.00321314) | 0.355391 ± 0.00217261 (W 0.00287027) | 0.281345 ± 0.00164909 (W 0.00283337) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.05077 ± 0.00328657 (W 0.0154518) | 6.16489 ± 0.012476 (W 0.0171063) | 3.11962 ± 0.00482005 (W 0.0176072) | · | 🔴 faer-fork 1.94× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 0.635154 ± 0.00187738 (W 0.00253319) | 1.13332 ± 0.0056388 (W 0.0330642) | 0.84784 ± 0.00381151 (W 0.00344254) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 16.4547 ± 2.68535 (W 0.0406358) | 27.0078 ± 0.112383 (W 0.174899) | 19.0204 ± 0.299795 (W 0.0303236) | 🔵 faer-fork 1.64× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 0.465857 ± 0.0164361 (W 0.00316416) | 0.890969 ± 0.00692729 (W 0.00686918) | 0.303746 ± 0.00232791 (W 0.0025757) | 🔵 faer-fork 1.91× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 8.05692 ± 0.247284 (W 0.0166593) | 15.8338 ± 0.15033 (W 0.108043) | 6.50871 ± 0.0554717 (W 0.0540365) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 1.61221 ± 0.00450657 (W 0.00181839) | 2.17225 ± 0.00927861 (W 0.00831493) | 1.62264 ± 0.00643751 (W 0.00591179) | 🔵 faer-fork 1.35× faster than `faer-upstream` | · |  |
| `svd_thin/4096x256/b1` | 28.2863 ± 0.0528202 (W 0.0436055) | 41.002 ± 0.360869 (W 0.243637) | 34.0307 ± 0.218565 (W 0.0630787) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 0.802074 ± 0.00707655 (W 0.00314164) | 1.52821 ± 0.00988366 (W 0.00480185) | 0.780165 ± 0.00291393 (W 0.00405306) | 🔵 faer-fork 1.91× faster than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 14.9398 ± 0.0305366 (W 0.0197985) | 27.6391 ± 0.0520712 (W 0.0896042) | 15.4842 ± 0.38202 (W 0.0627728) | 🔵 faer-fork 1.85× faster than `faer-upstream` | · |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.8232 ± 0.00527827 (W 0.0026959) | 1.82848 ± 0.0326118 (W 0.0102481) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 151.434 ± 0.614577 (W 0.923486) | 156.73 ± 0.855879 (W 1.16129) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19194 ± 0.00237607 (W 0.00262331) | 2.192 ± 0.0238124 (W 0.00565386) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.19433 ± 0.0048249 (W 0.00679528) | 2.23347 ± 0.0271509 (W 0.00309064) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.337 ± 0.0740576 (W 0.1748) | 137.792 ± 0.441074 (W 0.0971619) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.418 ± 0.105566 (W 0.112559) | 137.721 ± 0.198247 (W 0.134971) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.0378 ± 0.00326594 (W 0.00372649) | 1.05798 ± 0.000895846 (W 0.00306128) | 1.14326 ± 0.00550999 (W 0.00363932) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 47.1355 ± 0.246797 (W 0.0812998) | 54.3295 ± 0.0464338 (W 0.0602771) | 56.0986 ± 4.68403 (W 0.429253) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 4.50359 ± 0.0143176 (W 0.00894258) | 4.77582 ± 0.0232338 (W 0.012769) | 5.18822 ± 0.0508513 (W 0.0133049) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 247.059 ± 0.234803 (W 0.497115) | 255.445 ± 0.298923 (W 0.447133) | 228.048 ± 5.03859 (W 0.555533) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.28866 ± 0.023352 (W 0.00481655) | 4.0715 ± 0.0979562 (W 0.0124345) | 2.38412 ± 0.00872128 (W 0.00550494) | 🔵 faer-fork 1.78× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 98.0544 ± 0.582195 (W 0.343421) | 175.989 ± 0.465539 (W 0.211215) | 110.406 ± 2.55639 (W 0.455576) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.70807 ± 0.000789639 (W 0.0136627) | 5.98554 ± 0.0238555 (W 0.00649502) | 8.87843 ± 0.091151 (W 0.0114429) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 275.563 ± 0.392912 (W 2.46535) | 280.752 ± 0.252734 (W 0.56618) | 377.983 ± 0.371434 (W 0.44568) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.54577 ± 0.00546495 (W 0.00404171) | 3.06198 ± 0.0222499 (W 0.00551043) | 3.82457 ± 0.0372354 (W 0.0105884) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 115.357 ± 0.922282 (W 0.539871) | 122.179 ± 0.520406 (W 0.137052) | 144.762 ± 6.69602 (W 0.348926) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.97665 ± 0.0139816 (W 0.00632001) | 1.82277 ± 0.0241496 (W 0.00463777) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.6542 ± 0.138794 (W 0.21666) | 63.8632 ± 0.110472 (W 0.977497) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.588196 ± 0.0043063 (W 0.00160244) | 0.591863 ± 0.010436 (W 0.00298053) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.593097 ± 0.00528363 (W 0.00260351) | 0.593117 ± 0.00718573 (W 0.00264923) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 36.9583 ± 0.131906 (W 0.0505571) | 36.8834 ± 0.12964 (W 0.0900477) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.195 ± 0.155817 (W 0.0354494) | 37.16 ± 0.0912903 (W 0.0931543) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.786948 ± 0.00130432 (W 0.00243393) | 0.796172 ± 0.0174931 (W 0.00224896) | 1.00609 ± 0.00982461 (W 0.00191257) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 23.0635 ± 0.0440183 (W 0.055256) | 29.9964 ± 0.101916 (W 0.0412888) | 57.5028 ± 0.16997 (W 0.205653) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 2.49× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.98675 ± 0.00101383 (W 0.00371353) | 2.46354 ± 0.0401745 (W 0.0345683) | 3.13812 ± 0.00843384 (W 0.00534636) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 89.3492 ± 0.30589 (W 0.288851) | 96.2379 ± 0.221762 (W 0.0674179) | 86.3898 ± 0.481717 (W 0.437928) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.25246 ± 0.0231994 (W 0.0036533) | 4.04776 ± 0.0739904 (W 0.0486345) | 1.39909 ± 0.00206294 (W 0.00395007) | 🔵 faer-fork 3.23× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 36.5621 ± 0.0560889 (W 0.134496) | 127.544 ± 0.384959 (W 0.372513) | 34.0391 ± 0.166501 (W 0.108475) | 🔵 faer-fork 3.49× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.10525 ± 0.0245781 (W 0.00609) | 3.66685 ± 0.0114123 (W 0.00417483) | 5.50097 ± 0.0349138 (W 0.0368525) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.77× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 102.072 ± 0.140694 (W 0.144325) | 118.045 ± 0.171872 (W 0.151445) | 140.239 ± 0.341808 (W 0.534464) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.7093 ± 0.0204716 (W 0.00328337) | 2.47153 ± 0.0361645 (W 0.00836058) | 2.84253 ± 0.0286777 (W 0.0350027) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 53.5818 ± 0.166633 (W 0.0974242) | 71.5306 ± 0.405995 (W 0.0827037) | 59.3618 ± 4.4917 (W 0.466747) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.860332 ± 0.00961425 (W 0.00531198) | 1.79592 ± 0.0311308 (W 0.00490657) | - | 🔵 faer-fork 2.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.2154 ± 0.10148 (W 0.147538) | 38.4837 ± 1.36054 (W 0.343112) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.313474 ± 0.00696008 (W 0.00163229) | 0.478912 ± 0.0055907 (W 0.0361818) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.310248 ± 0.006182 (W 0.00194004) | 0.473152 ± 0.0470444 (W 0.0320488) | - | 🔵 faer-fork 1.53× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 24.0993 ± 0.123636 (W 0.737609) | 19.3696 ± 3.42792 (W 3.51432) | - | 🔴 faer-fork 1.24× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 23.56 ± 0.0604186 (W 0.0805888) | 25.2934 ± 3.60321 (W 3.47072) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.740812 ± 0.00203123 (W 0.00408287) | 0.746793 ± 0.016643 (W 0.00301942) | 0.991981 ± 0.00151842 (W 0.00331482) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 18.5789 ± 0.0717619 (W 0.0727058) | 25.8317 ± 0.0311372 (W 0.0255509) | 55.9849 ± 0.647667 (W 0.0929475) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 3.01× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.59927 ± 0.0127368 (W 0.00721323) | 2.38799 ± 0.0223645 (W 0.046741) | 2.3257 ± 0.0104865 (W 0.016531) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 65.9446 ± 0.159608 (W 0.148581) | 83.4826 ± 3.73184 (W 0.647038) | 51.5673 ± 0.294011 (W 0.299941) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.11578 ± 0.0169695 (W 0.00484319) | 4.14138 ± 0.147066 (W 0.120906) | 0.877764 ± 0.00295366 (W 0.00185341) | 🔵 faer-fork 3.71× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 26.8542 ± 0.0953499 (W 0.0555691) | 124.012 ± 0.727557 (W 0.897785) | 19.6227 ± 0.0732738 (W 0.044687) | 🔵 faer-fork 4.62× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.70449 ± 0.0371918 (W 0.0105982) | 3.65643 ± 0.0206359 (W 0.0314525) | 4.44969 ± 0.011357 (W 0.0127361) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 77.6471 ± 0.0589434 (W 0.116313) | 106.821 ± 1.92462 (W 1.29916) | 83.4801 ± 0.514536 (W 0.329685) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.63357 ± 0.0283821 (W 0.0061339) | 2.48178 ± 0.0249158 (W 0.0096284) | 2.35858 ± 0.00467819 (W 0.00524508) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.7809 ± 0.0246004 (W 0.0716103) | 69.4311 ± 3.47317 (W 0.446369) | 34.0524 ± 4.61238 (W 0.206168) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.70159 ± 0.00773801 (W 0.0033911) | 1.66804 ± 0.00576454 (W 0.0052454) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 144.509 ± 0.633741 (W 0.43996) | 143.726 ± 0.872697 (W 0.920416) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.25121 ± 0.024029 (W 0.00437514) | 2.27339 ± 0.0351659 (W 0.00297587) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.27586 ± 0.0151456 (W 0.00294105) | 2.27832 ± 0.0135052 (W 0.00433166) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.024 ± 0.209231 (W 0.0872292) | 138.021 ± 0.199284 (W 0.115408) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.908 ± 0.291127 (W 0.083077) | 138.113 ± 0.241766 (W 0.116766) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.920514 ± 0.00282299 (W 0.00445445) | 0.928869 ± 0.00122691 (W 0.00313847) | 1.00063 ± 0.0316136 (W 0.00294761) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 41.9922 ± 0.0445931 (W 0.0633332) | 42.1811 ± 0.0157893 (W 0.044295) | 48.0948 ± 0.206146 (W 0.0593945) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.37865 ± 0.0116375 (W 0.00969607) | 4.61719 ± 0.0133906 (W 0.00972363) | 4.8645 ± 0.0544474 (W 0.00675439) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 240.747 ± 0.171507 (W 0.462146) | 243.738 ± 0.448075 (W 0.366528) | 214.705 ± 1.01339 (W 0.558147) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.03056 ± 0.0416228 (W 0.00460469) | 2.27458 ± 0.0455067 (W 0.00489686) | 2.26138 ± 0.00858134 (W 0.00490449) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 86.8529 ± 0.626429 (W 0.0551014) | 89.1811 ± 0.445911 (W 0.0612751) | 103.873 ± 0.373308 (W 0.25459) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.58623 ± 0.0158227 (W 0.0086969) | 5.87285 ± 0.0228672 (W 0.00807774) | 8.52457 ± 0.0570184 (W 0.0188874) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 263.405 ± 0.208041 (W 0.44376) | 268.24 ± 0.0462257 (W 0.213557) | 355.749 ± 7.39802 (W 0.836845) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.4223 ± 0.00395436 (W 0.00423888) | 2.93719 ± 0.0234375 (W 0.00630307) | 3.68374 ± 0.0128754 (W 0.00892636) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 101.968 ± 0.19062 (W 0.104368) | 110.061 ± 0.165093 (W 0.0923865) | 137.628 ± 0.432035 (W 0.582563) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.85713 ± 0.00349096 (W 0.00413935) | 1.6598 ± 0.00397095 (W 0.00697582) | - | 🔵 faer-fork 1.94× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 47.3055 ± 0.238765 (W 0.121068) | 48.6193 ± 0.136562 (W 0.296515) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.646044 ± 0.00793437 (W 0.00377455) | 0.634602 ± 0.0137121 (W 0.00299004) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.650875 ± 0.0100161 (W 0.00229001) | 0.635837 ± 0.0126299 (W 0.00210785) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.528 ± 0.146915 (W 0.0667864) | 39.4833 ± 0.0977521 (W 0.0837339) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.5963 ± 0.256223 (W 0.0767002) | 39.6526 ± 0.174891 (W 0.105556) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.681832 ± 0.000654869 (W 0.00176808) | 0.687142 ± 0.00319791 (W 0.00296771) | 0.974795 ± 0.0133038 (W 0.00275057) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.555 ± 0.0117116 (W 0.0275025) | 17.8427 ± 0.0171486 (W 0.045157) | 47.9708 ± 0.0643152 (W 0.048666) | · | 🔵 faer-fork 2.73× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.86738 ± 0.00918765 (W 0.00293902) | 2.35874 ± 0.0153642 (W 0.0395892) | 3.06353 ± 0.00195689 (W 0.0351945) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 82.9461 ± 0.109428 (W 0.121714) | 83.9134 ± 0.179832 (W 0.100218) | 74.7629 ± 0.181335 (W 0.331487) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.12759 ± 0.00407033 (W 0.00428143) | 1.54754 ± 0.00612407 (W 0.00670657) | 1.35976 ± 0.00201735 (W 0.00279481) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 31.7207 ± 0.054864 (W 0.0660529) | 41.0217 ± 0.0204779 (W 0.0904068) | 31.2629 ± 0.226118 (W 0.237722) | 🔵 faer-fork 1.29× faster than `faer-upstream` | · |  |
| `svd_thin/1024x64/b1` | 3.00011 ± 0.00341995 (W 0.00409001) | 3.55083 ± 0.00530388 (W 0.0105075) | 5.39354 ± 0.0326697 (W 0.00937889) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 90.0939 ± 0.0721804 (W 0.0812283) | 105.932 ± 0.0428485 (W 0.118044) | 141.658 ± 7.57741 (W 0.370841) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.61985 ± 0.00379974 (W 0.00207509) | 2.33857 ± 0.0133854 (W 0.00572887) | 2.78876 ± 0.0166886 (W 0.00756734) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 41.6577 ± 0.144528 (W 0.0882651) | 59.5331 ± 0.15409 (W 0.0447637) | 49.1487 ± 0.315339 (W 0.26405) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.749418 ± 0.0024575 (W 0.00515372) | 1.65469 ± 0.00142889 (W 0.00378651) | - | 🔵 faer-fork 2.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 24.3252 ± 0.122788 (W 0.0715937) | 26.5399 ± 0.0952669 (W 0.102437) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.383444 ± 0.0129515 (W 0.00407653) | 0.449618 ± 0.0346803 (W 0.0442243) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.370841 ± 0.0128972 (W 0.00364559) | 0.514409 ± 0.039319 (W 0.0350959) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 25.1649 ± 0.498489 (W 0.825649) | 26.3485 ± 0.0519693 (W 0.147642) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 24.1019 ± 1.45558 (W 1.68953) | 26.3625 ± 0.14231 (W 0.14544) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.631736 ± 0.00350509 (W 0.00391253) | 0.643308 ± 0.000984094 (W 0.00333002) | 0.979696 ± 0.00996259 (W 0.00318913) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.5179 ± 0.0409847 (W 0.0211812) | 13.7627 ± 0.0227836 (W 0.0348535) | 48.2207 ± 0.119011 (W 0.0841365) | · | 🔵 faer-fork 3.57× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.49031 ± 0.00926318 (W 0.00558031) | 2.29881 ± 0.0355117 (W 0.0261701) | 2.29096 ± 0.00680795 (W 0.00372735) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 59.9785 ± 0.107108 (W 0.120528) | 76.8385 ± 0.334432 (W 0.580277) | 42.692 ± 0.171444 (W 0.244282) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.00833 ± 0.0065609 (W 0.00586706) | 1.57651 ± 0.0055288 (W 0.00958822) | 0.85893 ± 0.000620598 (W 0.00286425) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 23.319 ± 0.0614877 (W 0.0388096) | 38.3926 ± 0.305049 (W 0.325265) | 17.5437 ± 0.0300873 (W 0.0525874) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.59855 ± 0.0124765 (W 0.00715905) | 3.55175 ± 0.024669 (W 0.0325542) | 4.39296 ± 0.0265876 (W 0.00952509) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.69× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 65.3349 ± 0.231463 (W 0.118041) | 93.5086 ± 0.331439 (W 1.02235) | 73.8549 ± 7.38041 (W 0.367502) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/1024x64/b1` | 1.5086 ± 0.000850288 (W 0.00770588) | 2.38247 ± 0.00617462 (W 0.00716861) | 2.30647 ± 0.0101707 (W 0.00318856) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 33.0397 ± 0.0590989 (W 0.037398) | 56.8312 ± 4.55148 (W 0.309911) | 32.452 ± 0.2725 (W 0.200634) | 🔵 faer-fork 1.72× faster than `faer-upstream` | · | `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 75.0416 ± 0.457931 (W 0.314133) | 76.347 ± 0.820822 (W 0.162594) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.1622 ± 0.0140694 (W 0.00413538) | 1.24592 ± 0.0275206 (W 0.00427356) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.134 ± 0.181274 (W 0.0277944) | 18.2519 ± 0.487109 (W 0.0483266) | 27.6523 ± 2.96127 (W 0.134899) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.414083 ± 0.00367685 (W 0.00267678) | 0.511624 ± 0.0047397 (W 0.00304479) | 0.630474 ± 0.00435641 (W 0.00375831) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 30.734 ± 0.104637 (W 0.131616) | 32.213 ± 0.126327 (W 0.120359) | 64.6626 ± 0.344178 (W 0.384883) | · | 🔵 faer-fork 2.10× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.753153 ± 0.00133525 (W 0.00245502) | 0.840425 ± 0.00368032 (W 0.00351295) | 1.52907 ± 0.018599 (W 0.00562342) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 2.03× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 27.9938 ± 0.0824003 (W 0.0635121) | 27.5174 ± 0.57372 (W 0.0403854) | 60.1513 ± 1.84237 (W 0.380919) | · | 🔵 faer-fork 2.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.998088 ± 0.0257899 (W 0.00637151) | 1.01624 ± 0.00340065 (W 0.00776883) | 1.35456 ± 0.00159488 (W 0.00526258) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 80.7696 ± 0.47767 (W 0.115013) | 83.5127 ± 0.382911 (W 0.143203) | 253.448 ± 3.64155 (W 4.86319) | · | 🔵 faer-fork 3.14× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.2491 ± 0.0112969 (W 0.00458475) | 2.46259 ± 0.00852965 (W 0.00539098) | 4.15632 ± 0.0227708 (W 0.00798357) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.85× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 32.6543 ± 0.0987779 (W 0.0323645) | 39.1707 ± 0.175955 (W 0.0466706) | 182.431 ± 6.90747 (W 3.25703) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 5.59× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 0.955329 ± 0.00143495 (W 0.00280926) | 1.41352 ± 0.00438869 (W 0.00645185) | 2.63429 ± 0.0505136 (W 0.0086929) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 2.76× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.6824 ± 0.0890594 (W 0.0963219) | 36.5912 ± 0.0616518 (W 0.360857) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.741093 ± 0.00800225 (W 0.00344772) | 1.25755 ± 0.013782 (W 0.00294581) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 6.82188 ± 0.127245 (W 0.0543302) | 9.89837 ± 0.422704 (W 0.386523) | 9.90055 ± 0.194175 (W 0.0457775) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.222825 ± 0.00116451 (W 0.00183709) | 0.377102 ± 0.00866853 (W 0.0116922) | 0.287266 ± 0.00667175 (W 0.00396628) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 10.702 ± 0.132568 (W 0.0386777) | 12.7936 ± 0.0307433 (W 0.0217029) | 16.6079 ± 1.75401 (W 0.0487386) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.377334 ± 0.00115863 (W 0.00238199) | 0.53128 ± 0.00114249 (W 0.00391931) | 0.615829 ± 0.00469195 (W 0.00493884) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 9.98243 ± 0.128656 (W 0.0598367) | 10.4923 ± 0.039529 (W 0.0364656) | 13.1865 ± 0.15973 (W 0.0174318) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.614144 ± 0.00548964 (W 0.00259821) | 0.687062 ± 0.00447992 (W 0.00489346) | 0.41882 ± 0.00333946 (W 0.00229332) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 34.1523 ± 0.152304 (W 0.0883435) | 42.1698 ± 0.155932 (W 1.17766) | 122.62 ± 2.85308 (W 0.191862) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 3.59× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 1.6961 ± 0.0100216 (W 0.00291688) | 2.10252 ± 0.0055969 (W 0.00930483) | 3.06626 ± 0.0378203 (W 0.0106026) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.81× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 17.4229 ± 0.0250103 (W 0.0302184) | 26.9712 ± 0.0635814 (W 0.0476619) | 98.6246 ± 2.09634 (W 0.381666) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔵 faer-fork 5.66× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 0.830427 ± 0.00111439 (W 0.00217532) | 1.46307 ± 0.0051007 (W 0.00530833) | 2.12163 ± 0.00980239 (W 0.00615909) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔵 faer-fork 2.55× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 27.2863 ± 0.228751 (W 0.195747) | 30.8162 ± 0.285168 (W 0.0498825) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.698422 ± 0.00729962 (W 0.00258618) | 1.27777 ± 0.0296494 (W 0.00480496) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.18866 ± 0.153455 (W 0.0289423) | 7.74575 ± 0.0517202 (W 0.0515548) | 6.82959 ± 0.0456631 (W 0.0338715) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.32× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.19846 ± 0.00168576 (W 0.00109678) | 0.340656 ± 0.0101935 (W 0.011654) | 0.167783 ± 0.00109643 (W 0.0024551) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 7.36583 ± 0.0191439 (W 0.0246484) | 10.8663 ± 0.172021 (W 0.122583) | 13.0748 ± 0.0559105 (W 0.0685043) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.78× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.32154 ± 0.00401051 (W 0.0014848) | 0.586263 ± 0.00978672 (W 0.00487178) | 0.45964 ± 0.00753353 (W 0.00219762) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 7.22383 ± 0.0593199 (W 0.0341524) | 8.74017 ± 0.167117 (W 0.105659) | 6.78807 ± 0.0105095 (W 0.0174539) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.544486 ± 0.00839542 (W 0.00470654) | 0.739129 ± 0.00841049 (W 0.00823076) | 0.251549 ± 0.00175826 (W 0.00175866) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 28.429 ± 0.0392088 (W 0.063845) | 40.9549 ± 1.41261 (W 0.216379) | 115.056 ± 1.68256 (W 0.809656) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 4.05× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 1.6078 ± 0.00150312 (W 0.0040073) | 2.17802 ± 0.01678 (W 0.00522724) | 2.96122 ± 0.0268168 (W 0.0114778) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 15.0041 ± 0.0150497 (W 0.0318032) | 27.7111 ± 0.076729 (W 0.0550845) | 84.2161 ± 2.52245 (W 1.16818) | 🔵 faer-fork 1.85× faster than `faer-upstream` | 🔵 faer-fork 5.61× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 0.80327 ± 0.00370576 (W 0.00339257) | 1.54455 ± 0.0150448 (W 0.00658698) | 2.08665 ± 0.0165464 (W 0.00397408) | 🔵 faer-fork 1.92× faster than `faer-upstream` | 🔵 faer-fork 2.60× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 71.8482 ± 0.752776 (W 0.315777) | 71.4342 ± 0.478946 (W 0.237541) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.0803 ± 0.0008988 (W 0.00294707) | 1.04409 ± 0.0146169 (W 0.00361829) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3056 ± 0.136106 (W 0.0223562) | 13.2919 ± 0.0117155 (W 0.0237971) | 21.3029 ± 0.0594146 (W 0.0315307) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.318364 ± 0.00369034 (W 0.00334198) | 0.312974 ± 0.00100959 (W 0.00174864) | 0.460297 ± 0.00310147 (W 0.00248314) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 27.7099 ± 0.145705 (W 0.076969) | 27.6503 ± 0.126451 (W 0.0616076) | 67.7694 ± 0.889086 (W 0.380111) | · | 🔵 faer-fork 2.45× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.62274 ± 0.0019013 (W 0.00219378) | 0.631699 ± 0.00105708 (W 0.0035231) | 1.48949 ± 0.0514091 (W 0.0123865) | · | 🔵 faer-fork 2.39× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 25.3517 ± 0.0348546 (W 0.0827786) | 25.7195 ± 0.191802 (W 0.0571476) | 53.5121 ± 0.453916 (W 0.363832) | · | 🔵 faer-fork 2.11× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.5587 ± 0.00379149 (W 0.00290926) | 0.570404 ± 0.00541905 (W 0.00308013) | 6.29591 ± 0.00373393 (W 0.00612522) | · | 🔵 faer-fork 11.27× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 86.0156 ± 0.395437 (W 0.379184) | 88.9769 ± 0.441877 (W 0.0803829) | 235.142 ± 1.39973 (W 0.841078) | · | 🔵 faer-fork 2.73× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.30488 ± 0.0115338 (W 0.00389947) | 2.51953 ± 0.00353371 (W 0.00501116) | 3.97014 ± 0.0522242 (W 0.0109633) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 38.4115 ± 0.0788326 (W 0.0770533) | 44.8485 ± 0.23137 (W 0.0597914) | 174.307 ± 2.30903 (W 3.03469) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 4.54× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.03183 ± 0.00570859 (W 0.00412027) | 1.47504 ± 0.00425426 (W 0.005067) | 2.53932 ± 0.0481568 (W 0.00771357) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 2.46× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.0279 ± 0.150572 (W 0.0858396) | 31.7123 ± 0.152618 (W 0.103985) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.657798 ± 0.0119528 (W 0.00405002) | 1.05848 ± 0.00853525 (W 0.00647169) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.03214 ± 0.0186272 (W 0.0140901) | 5.13898 ± 0.125319 (W 0.319911) | 5.259 ± 0.018062 (W 0.00859473) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.116447 ± 0.000697941 (W 0.000443468) | 0.157464 ± 0.0118082 (W 0.011743) | 0.228576 ± 0.00862456 (W 0.00309522) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.96× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 7.57886 ± 0.0436713 (W 0.0209426) | 8.00906 ± 0.0188771 (W 0.0373648) | 24.2517 ± 4.05445 (W 0.0671518) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 3.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.248033 ± 0.000274651 (W 0.00232014) | 0.318704 ± 0.000392591 (W 0.00223064) | 0.671451 ± 0.0470953 (W 0.00705925) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 2.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 6.58879 ± 0.0195159 (W 0.0132591) | 7.0061 ± 0.0653455 (W 0.0365376) | 11.1748 ± 0.0562271 (W 0.0230177) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.195484 ± 0.00202189 (W 0.00149525) | 0.259644 ± 0.000463467 (W 0.00171586) | 0.35952 ± 0.0030086 (W 0.00259053) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 39.6398 ± 0.0444243 (W 0.0829465) | 47.5588 ± 0.0411665 (W 0.112947) | 119.959 ± 1.70658 (W 0.146371) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 3.03× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 1.76954 ± 0.0112436 (W 0.00882572) | 2.16949 ± 0.0104223 (W 0.0059061) | 3.00817 ± 0.0531744 (W 0.0149487) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.70× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 22.9675 ± 0.0105286 (W 0.0420752) | 32.7748 ± 0.0539561 (W 0.0434367) | 96.0174 ± 1.64349 (W 0.29589) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 4.18× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 0.898075 ± 0.00319682 (W 0.00445789) | 1.53477 ± 0.00867773 (W 0.00561411) | 2.10119 ± 0.0277234 (W 0.0053088) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔵 faer-fork 2.34× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 24.6415 ± 0.151025 (W 0.0457934) | 26.0494 ± 0.0343346 (W 0.0322022) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.60631 ± 0.00573558 (W 0.0025372) | 1.05378 ± 0.00973809 (W 0.00437232) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.52908 ± 0.00359615 (W 0.00808125) | 3.26549 ± 0.0425634 (W 0.0819812) | 3.15305 ± 0.0233818 (W 0.00604177) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.088806 ± 0.00108205 (W 0.000435382) | 0.136148 ± 0.00353858 (W 0.0062076) | 0.130313 ± 0.003799 (W 0.000592782) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 4.35445 ± 0.0160645 (W 0.0154203) | 6.40233 ± 0.0813989 (W 0.217811) | 25.8305 ± 0.173517 (W 0.0366315) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 5.93× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.195735 ± 0.00195182 (W 0.00240938) | 0.377884 ± 0.00479217 (W 0.00611799) | 0.468743 ± 0.00361624 (W 0.00455024) | 🔵 faer-fork 1.93× faster than `faer-upstream` | 🔵 faer-fork 2.39× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 3.58744 ± 0.00611735 (W 0.00737127) | 5.27794 ± 0.0775409 (W 0.161505) | 5.85724 ± 0.0133673 (W 0.00990996) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.63× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.146804 ± 0.0052887 (W 0.000682962) | 0.315739 ± 0.0104278 (W 0.004445) | 0.211194 ± 0.000745118 (W 0.000794411) | 🔵 faer-fork 2.15× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 33.6708 ± 0.0554463 (W 0.075703) | 46.3668 ± 0.184044 (W 0.16364) | 105.885 ± 0.892115 (W 0.528882) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 3.14× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 1.67892 ± 0.00418749 (W 0.00456536) | 2.25247 ± 0.00807858 (W 0.00652895) | 3.01915 ± 0.0372986 (W 0.0303686) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 20.5773 ± 0.0272051 (W 0.043452) | 33.4827 ± 0.0598568 (W 0.0669615) | 84.3108 ± 1.93943 (W 0.469497) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 4.10× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 0.87428 ± 0.00318584 (W 0.00897256) | 1.59593 ± 0.0118659 (W 0.00559871) | 2.09526 ± 0.025131 (W 0.00596393) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔵 faer-fork 2.40× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 233.177 ± 6.15328 (W 0.834998) | 236.458 ± 7.90269 (W 1.01198) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.43598 ± 0.0085713 (W 0.00711069) | 2.53586 ± 0.0442776 (W 0.00968799) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.2868 ± 0.18591 (W 0.163434) | 47.0584 ± 0.34721 (W 0.0903123) | 88.5738 ± 0.186245 (W 0.0973798) | · | 🔵 faer-fork 1.91× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 1.00025 ± 0.0142055 (W 0.00407834) | 1.05459 ± 0.00146937 (W 0.00497371) | 2.32892 ± 0.00732611 (W 0.00629785) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 2.33× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 107.259 ± 0.604004 (W 0.444032) | 107.548 ± 0.389535 (W 0.106239) | 179.544 ± 3.66766 (W 2.2694) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 2.49726 ± 0.0166551 (W 0.0065716) | 2.55672 ± 0.0431575 (W 0.00523709) | 3.86066 ± 0.0488052 (W 0.00692497) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 96.979 ± 0.186597 (W 0.15937) | 97.2538 ± 0.175683 (W 0.137137) | 161.777 ± 0.387081 (W 1.61836) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.60052 ± 0.0386373 (W 0.00631708) | 2.60402 ± 0.00701208 (W 0.00442068) | 3.54477 ± 0.0308558 (W 0.00605498) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 264.153 ± 0.247095 (W 3.35885) | 269.004 ± 0.23008 (W 0.141858) | 543.022 ± 1.81611 (W 1.84661) | · | 🔵 faer-fork 2.06× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.61695 ± 0.0074085 (W 0.00966056) | 5.89115 ± 0.00627245 (W 0.0128662) | 12.3567 ± 0.24981 (W 0.0326501) | · | 🔵 faer-fork 2.20× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 101.776 ± 0.0860044 (W 0.117737) | 109.933 ± 0.183485 (W 0.359607) | 201.383 ± 7.29372 (W 1.74175) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.98× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.41642 ± 0.00289949 (W 0.00514302) | 2.95771 ± 0.0213501 (W 0.00656672) | 5.62707 ± 0.0506413 (W 0.014788) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 2.33× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 86.4961 ± 2.39609 (W 0.470712) | 92.5935 ± 2.30755 (W 0.32584) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.34581 ± 0.00480822 (W 0.00564217) | 2.51081 ± 0.064584 (W 0.0101474) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 17.3345 ± 0.124241 (W 0.0527056) | 22.0604 ± 0.571162 (W 1.1879) | 29.3567 ± 0.147707 (W 0.089616) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.69× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.411237 ± 0.00172595 (W 0.0362322) | 0.561798 ± 0.0452983 (W 0.0471257) | 0.641797 ± 0.00171897 (W 0.00362381) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 32.2178 ± 0.350751 (W 0.0810758) | 33.2457 ± 0.15708 (W 0.106201) | 50.5579 ± 0.100572 (W 0.138519) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.875584 ± 0.00145569 (W 0.00275399) | 1.03775 ± 0.0264151 (W 0.00177977) | 1.61481 ± 0.0191922 (W 0.00569472) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔵 faer-fork 1.84× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 27.807 ± 0.204382 (W 0.0448917) | 28.6116 ± 0.154166 (W 0.179093) | 38.2592 ± 0.145116 (W 0.0551833) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.979437 ± 0.00537937 (W 0.00577315) | 1.05445 ± 0.00862288 (W 0.00516129) | 1.29843 ± 0.0038059 (W 0.00493895) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 90.5979 ± 0.105196 (W 0.0709244) | 106.448 ± 0.570017 (W 0.0795047) | 190.474 ± 0.484106 (W 0.851318) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 2.10× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 3.03364 ± 0.0148454 (W 0.00783515) | 3.58044 ± 0.00276592 (W 0.00650147) | 7.38262 ± 0.0816798 (W 0.0199131) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 2.43× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 41.6315 ± 0.00667057 (W 0.0490108) | 59.2977 ± 0.19182 (W 0.0490658) | 85.2188 ± 4.66801 (W 0.352282) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 2.05× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.61115 ± 0.00946116 (W 0.00540464) | 2.32587 ± 0.0172914 (W 0.00629496) | 3.74158 ± 0.0535006 (W 0.00813654) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 2.32× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 54.9638 ± 0.179365 (W 0.120736) | 59.7124 ± 0.933596 (W 0.316089) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.20766 ± 0.006144 (W 0.00404609) | 2.4952 ± 0.0335308 (W 0.00779214) | - | 🔵 faer-fork 2.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 11.8694 ± 0.138412 (W 0.0408782) | 13.4828 ± 0.524358 (W 0.521931) | 18.9508 ± 0.0373322 (W 0.10068) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/64x1024/b1` | 0.35906 ± 0.00148005 (W 0.00231251) | 0.442326 ± 0.0279619 (W 0.00241259) | 0.452734 ± 0.00284277 (W 0.00188799) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 19.7416 ± 0.135155 (W 0.117412) | 24.651 ± 0.170124 (W 0.895446) | 31.3932 ± 0.0559775 (W 0.210353) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.610799 ± 0.00179686 (W 0.002106) | 0.989761 ± 0.0408408 (W 0.0111672) | 1.03941 ± 0.00278085 (W 0.00263098) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 16.4724 ± 0.148503 (W 0.124134) | 20.5809 ± 0.449703 (W 0.70207) | 20.5413 ± 0.0908365 (W 0.0528807) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.714634 ± 0.00198225 (W 0.00247356) | 1.02974 ± 0.00957305 (W 0.0174693) | 0.72972 ± 0.00409626 (W 0.00293086) | 🔵 faer-fork 1.44× faster than `faer-upstream` | · |  |
| `svd_thin/256x4096/b1` | 65.7451 ± 0.0876636 (W 0.0390662) | 94.7517 ± 0.750798 (W 0.852945) | 118.372 ± 0.943163 (W 0.322549) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.63751 ± 0.0106316 (W 0.00533118) | 3.58939 ± 0.0104686 (W 0.0343031) | 6.31525 ± 0.0617824 (W 0.0161215) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔵 faer-fork 2.39× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 33.026 ± 0.0566487 (W 0.056972) | 57.192 ± 0.148903 (W 0.3365) | 56.4162 ± 3.6817 (W 0.155949) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.71× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.50145 ± 0.00645604 (W 0.00720955) | 2.3705 ± 0.0151853 (W 0.005859) | 9.67784 ± 3.68219 (W 0.0100284) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔵 faer-fork 6.45× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 229.665 ± 6.58061 (W 0.616689) | 230.431 ± 7.32705 (W 1.00639) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.31892 ± 0.0239046 (W 0.0102659) | 2.30033 ± 0.0365705 (W 0.00643076) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 41.9687 ± 0.234344 (W 0.0386573) | 42.0251 ± 0.0351383 (W 0.0519088) | 72.5357 ± 0.121467 (W 0.132205) | · | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.895379 ± 0.00409874 (W 0.00273736) | 0.89489 ± 0.00494649 (W 0.00514161) | 2.12113 ± 0.00199457 (W 0.00316321) | · | 🔵 faer-fork 2.37× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 103.502 ± 0.240468 (W 0.6526) | 103.209 ± 0.356576 (W 0.275904) | 193.094 ± 5.57941 (W 0.637033) | · | 🔵 faer-fork 1.87× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 2.38047 ± 0.0209392 (W 0.00330518) | 2.38343 ± 0.0198135 (W 0.00407818) | 3.94747 ± 0.195067 (W 0.0303622) | · | 🔵 faer-fork 1.66× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 96.1931 ± 0.179077 (W 0.260374) | 96.2583 ± 0.392145 (W 0.182289) | 155.066 ± 5.73002 (W 0.621775) | · | 🔵 faer-fork 1.61× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.23665 ± 0.0143138 (W 0.0065274) | 2.22684 ± 0.00675328 (W 0.0081444) | 16.8548 ± 0.0110475 (W 0.0114829) | · | 🔵 faer-fork 7.54× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 276.328 ± 1.26381 (W 0.628794) | 281.019 ± 0.145833 (W 0.387946) | 530.399 ± 11.9476 (W 1.17502) | · | 🔵 faer-fork 1.92× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.73334 ± 0.00420483 (W 0.00881116) | 6.00689 ± 0.00677905 (W 0.00998449) | 11.8041 ± 0.135054 (W 0.0258732) | · | 🔵 faer-fork 2.06× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 113.789 ± 0.26098 (W 0.216156) | 121.937 ± 0.513616 (W 0.129901) | 192.245 ± 8.54679 (W 0.770097) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.69× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.54582 ± 0.00454866 (W 0.00588498) | 3.09058 ± 0.0124897 (W 0.00467086) | 5.36914 ± 0.0185217 (W 0.0152921) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 2.11× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 82.2692 ± 2.23307 (W 0.517923) | 88.1807 ± 2.02928 (W 0.325989) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.20773 ± 0.00577628 (W 0.00262803) | 2.25564 ± 0.070693 (W 0.00938118) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 13.2823 ± 0.0116228 (W 0.011081) | 16.3206 ± 0.358449 (W 1.37623) | 20.5424 ± 0.0285313 (W 0.0262915) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.383275 ± 0.0488053 (W 0.0456762) | 0.418551 ± 0.0135049 (W 0.0598274) | 0.58471 ± 0.00241827 (W 0.00279636) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 28.2575 ± 0.31923 (W 0.0870509) | 28.7053 ± 0.122742 (W 0.0387162) | 69.6435 ± 0.0969355 (W 0.300287) | · | 🔵 faer-fork 2.46× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.766764 ± 0.00411699 (W 0.00385805) | 0.866938 ± 0.00168172 (W 0.00215067) | 1.78058 ± 0.220166 (W 0.0134411) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 2.32× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 25.1768 ± 0.338054 (W 0.0288652) | 25.55 ± 0.351483 (W 0.052809) | 35.2196 ± 0.030251 (W 0.0208619) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.647037 ± 0.0023847 (W 0.00171222) | 0.714766 ± 0.00200687 (W 0.00425029) | 1.2217 ± 0.00508988 (W 0.0040029) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.89× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 102.72 ± 0.0771547 (W 0.110491) | 119.561 ± 0.555963 (W 0.136602) | 178.411 ± 7.88157 (W 0.409041) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.74× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 3.14342 ± 0.029053 (W 0.0085414) | 3.6934 ± 0.0137198 (W 0.0125114) | 7.26047 ± 0.0551167 (W 0.0192767) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 2.31× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 53.8473 ± 0.119848 (W 0.0480926) | 71.5504 ± 0.389442 (W 0.0714795) | 82.4184 ± 0.565767 (W 0.326374) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.71958 ± 0.0106151 (W 0.00448996) | 2.40743 ± 0.0409778 (W 0.0123639) | 3.6686 ± 0.0608591 (W 0.0117284) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 2.13× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 50.7681 ± 0.314416 (W 0.213886) | 55.5213 ± 1.23248 (W 0.324317) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.0601 ± 0.00816976 (W 0.00573572) | 2.2728 ± 0.0262731 (W 0.0120678) | - | 🔵 faer-fork 2.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.73979 ± 0.0854409 (W 0.011547) | 9.78754 ± 0.213608 (W 0.144684) | 11.2967 ± 0.02267 (W 0.0302261) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.252878 ± 0.00422499 (W 0.00494547) | 0.278028 ± 0.00233819 (W 0.0184704) | 0.420113 ± 0.00282793 (W 0.00226948) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.66× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 15.4734 ± 0.054281 (W 0.0270059) | 20.2702 ± 0.29759 (W 0.459291) | 51.8042 ± 0.514026 (W 0.409951) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔵 faer-fork 3.35× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.504794 ± 0.00189229 (W 0.00388013) | 0.848954 ± 0.00661605 (W 0.0139308) | 1.5366 ± 0.0486503 (W 0.00612725) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔵 faer-fork 3.04× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 13.2817 ± 0.0351224 (W 0.0311969) | 17.744 ± 1.00114 (W 0.900464) | 18.1213 ± 0.029676 (W 0.0205876) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.394085 ± 0.00312557 (W 0.004948) | 0.676461 ± 0.00792896 (W 0.01157) | 0.674858 ± 0.00101051 (W 0.00192179) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔵 faer-fork 1.71× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 78.1337 ± 0.103057 (W 0.156882) | 107.288 ± 1.59089 (W 1.52162) | 121.402 ± 6.26303 (W 0.213478) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.77748 ± 0.0237777 (W 0.006574) | 3.71274 ± 0.0383119 (W 0.0303312) | 6.13557 ± 0.108703 (W 0.0269291) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 2.21× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 44.9385 ± 0.0465707 (W 0.0562016) | 69.1223 ± 0.258624 (W 0.477163) | 54.2839 ± 0.231289 (W 0.0555366) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.60406 ± 0.00590724 (W 0.00405263) | 2.46331 ± 0.0138234 (W 0.00760548) | 3.2273 ± 0.0584536 (W 0.00805374) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 2.01× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
