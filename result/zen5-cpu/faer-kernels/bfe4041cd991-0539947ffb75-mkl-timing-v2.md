<!-- generated from data/results/zen5-cpu/faer-kernels/20261015T130805Z-baseline-v2-faer-kernels-mkl/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `7f5b1e5100720722aad9f530f6afa02c1793357f`
- toolkit commit: `07d911e7fc44c6c944ec2cd08ddcf0cdf5ed7f2a`
- measured binary SHA-256: `7a0c2d6474f16fd0ff736e4d8b04932fbdfbf0ca57f21ea8391cc4d4e1707bfe`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-15T15:22:23.053987Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label baseline-v2-faer-kernels-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261015T130805Z-baseline-v2-faer-kernels-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.99%, worst 290.96% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 425 of 3684 engine cells exceed 5% and carry `!`; median within-process relative SD 0.52%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
`🔵 fork X faster` / `🔴 fork X slower`, `·` inside the band, `-` that row is not measured in
this arm. `notes` carries the cell warnings (`*` a declared row has no measurement,
`!` between-start range over 5%, `p` position effect over 5%, dispatch-dominated means the
row is under 20 us so 4T/8T pay thread-region start-up). Per-start ratios and every
chronological sample are in the run directory named at the top of this page (`run*.csv`).
These describe the recorded revisions; they are not a regression claim.

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 1.12694e-05 (W 8.78635e-06) | 0.002334 ± 6.08276e-06 (W 1.52086e-05) | 0.004529 ± 0 (W 3.78985e-05) | · | 🔵 fork 1.94× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017062 ± 6.46555e-05 (W 1.78662e-05) | 0.017062 ± 5.85947e-05 (W 2.70185e-05) | 0.024366 ± 8.02081e-05 (W 6.71506e-05) | · | 🔵 fork 1.43× faster | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056727 ± 5.48361e-05 (W 0.00115959) | 0.056766 ± 3.00056e-05 (W 8.41974e-05) | 0.062887 ± 0.000227831 (W 5.13352e-05) | · | 🔵 fork 1.11× faster |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.010359 ± 0.000241579 (W 0.00145826) | 0.01035 ± 0.000975164 (W 0.000605101) | 0.00509 ± 0.0001506 (W 0.000131823) | · | 🔴 fork 2.04× slower | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.025137 ± 0.00410875 (W 0.00241427) | 0.023924 ± 0.00318515 (W 0.00366461) | 0.014057 ± 6.70099e-05 (W 9.92784e-05) | · | 🔴 fork 1.79× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.066425 ± 0.00777767 (W 0.00728431) | 0.068408 ± 0.00112495 (W 0.0073775) | 0.022002 ± 0.000363905 (W 0.000140891) | · | 🔴 fork 3.02× slower | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.013234 ± 0.000496079 (W 0.00102686) | 0.013836 ± 0.00145323 (W 0.00176586) | 0.0049 ± 6.55769e-05 (W 0.000190956) | · | 🔴 fork 2.70× slower | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.019477 ± 0.000567654 (W 0.00188909) | 0.019536 ± 0.00363981 (W 0.00131996) | 0.009899 ± 9.07028e-05 (W 0.00020206) | · | 🔴 fork 1.97× slower | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.031299 ± 0.000550001 (W 0.00236395) | 0.029966 ± 0.000954831 (W 0.00173365) | 0.014797 ± 8.19776e-05 (W 0.000128647) | · | 🔴 fork 2.12× slower | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 5.7735e-06 (W 1.13225e-05) | 0.002324 ± 1.48436e-05 (W 2.04255e-05) | 0.004519 ± 2.02567e-05 (W 1.41527e-05) | · | 🔵 fork 1.95× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017132 ± 6.15386e-05 (W 2.97876e-05) | 0.017112 ± 3.78594e-05 (W 1.67332e-05) | 0.024356 ± 0.000202073 (W 3.08756e-05) | · | 🔵 fork 1.42× faster | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056838 ± 9.33881e-05 (W 7.10634e-05) | 0.056757 ± 5.38609e-05 (W 5.85662e-05) | 0.062799 ± 0.000220061 (W 0.000145362) | · | 🔵 fork 1.10× faster |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.01049 ± 0.000403101 (W 0.000388246) | 0.010239 ± 0.000394049 (W 0.000526841) | 0.005089 ± 3.51188e-05 (W 9.45156e-05) | · | 🔴 fork 2.06× slower | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.022141 ± 0.00289523 (W 0.0028477) | 0.024586 ± 0.00120812 (W 0.00422382) | 0.014116 ± 8.34286e-05 (W 8.26033e-05) | · | 🔴 fork 1.57× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.050474 ± 0.00658652 (W 0.013042) | 0.056696 ± 0.00824713 (W 0.0130577) | 0.022002 ± 0.000255513 (W 0.000150266) | · | 🔴 fork 2.29× slower | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.015139 ± 0.0017223 (W 0.00157892) | 0.013475 ± 0.000649131 (W 0.00121971) | 0.00502 ± 0.000147886 (W 0.000155844) | · | 🔴 fork 3.02× slower | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.019016 ± 0.000912483 (W 0.00172276) | 0.019868 ± 0.00161405 (W 0.00140962) | 0.010099 ± 0.000116435 (W 0.000251283) | · | 🔴 fork 1.88× slower | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030347 ± 0.00119889 (W 0.00113949) | 0.031479 ± 0.000818146 (W 0.00144936) | 0.014978 ± 0.000183957 (W 0.000218303) | · | 🔴 fork 2.03× slower | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008877 ± 2.0502e-05 (W 1.30384e-05) | 0.008857 ± 3.55012e-05 (W 1.35351e-05) | 0.011111 ± 8.73689e-05 (W 0.000103631) | · | 🔵 fork 1.25× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067758 ± 8.41249e-05 (W 2.91548e-05) | 0.067728 ± 0.000211983 (W 0.00112051) | 0.083226 ± 0.0010591 (W 0.000912223) | · | 🔵 fork 1.23× faster |  |
| `gemm/96x96x96/b1` | 0.226819 ± 0.000420753 (W 0.00125123) | 0.226724 ± 0.000456462 (W 0.00159215) | 0.268693 ± 0.00513296 (W 0.0054529) | · | 🔵 fork 1.18× faster |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008866 ± 3.80832e-05 (W 2.16795e-05) | 0.008877 ± 8.3865e-05 (W 2.16795e-05) | 0.014547 ± 0.000296025 (W 0.000153669) | · | 🔵 fork 1.64× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.04222 ± 0.00442424 (W 0.0058861) | 0.038923 ± 0.00184823 (W 0.00474751) | 0.035657 ± 0.000155671 (W 0.000411567) | · | 🔴 fork 1.18× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.087105 ± 0.00565141 (W 0.00921203) | 0.088996 ± 0.00185443 (W 0.00776708) | 0.098504 ± 0.000663706 (W 0.00104034) | · | 🔵 fork 1.13× faster | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008796 ± 5.7735e-07 (W 1.24619e-05) | 0.008877 ± 5.50757e-05 (W 3.17679e-05) | 0.024666 ± 0.0057102 (W 0.000239124) | · | 🔵 fork 2.80× faster | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.037149 ± 0.000571105 (W 0.00176851) | 0.038131 ± 0.00054776 (W 0.000916342) | 0.01587 ± 0.000779941 (W 0.000218484) | · | 🔴 fork 2.34× slower | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.051065 ± 0.00109172 (W 0.00122659) | 0.050294 ± 0.000835409 (W 0.00148568) | 0.04271 ± 0.000123977 (W 0.000518273) | · | 🔴 fork 1.20× slower |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008887 ± 4.72582e-05 (W 2.11967e-05) | 0.008907 ± 4.3589e-05 (W 2.1822e-05) | 0.011141 ± 6.35085e-05 (W 0.000138854) | · | 🔵 fork 1.25× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067737 ± 0.000273793 (W 5.15965e-05) | 0.067707 ± 0.000121919 (W 4.46117e-05) | 0.082244 ± 0.000633825 (W 0.00138926) | · | 🔵 fork 1.21× faster |  |
| `gemm/96x96x96/b1` | 0.227015 ± 0.000253977 (W 0.00143553) | 0.227069 ± 0.000942102 (W 0.00138602) | 0.271007 ± 0.00112927 (W 0.0047979) | · | 🔵 fork 1.19× faster |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008836 ± 3.80832e-05 (W 2.19089e-05) | 0.008877 ± 5.22526e-05 (W 1.41492e-05) | 0.014287 ± 0.000269092 (W 9.91524e-05) | · | 🔵 fork 1.62× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.035867 ± 0.00512251 (W 0.00600799) | 0.045335 ± 0.000181475 (W 0.00465712) | 0.035607 ± 0.000246395 (W 0.000266872) | 🔵 fork 1.26× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.091521 ± 0.00632673 (W 0.00927764) | 0.09069 ± 0.00329545 (W 0.00759003) | 0.098003 ± 0.000344335 (W 0.00144088) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008796 ± 5.7735e-06 (W 1.92354e-05) | 0.008846 ± 3.55949e-05 (W 1.30384e-05) | 0.024856 ± 0.000200716 (W 0.00015603) | · | 🔵 fork 2.83× faster | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.037511 ± 0.000823057 (W 0.00172862) | 0.036849 ± 0.000443412 (W 0.00160864) | 0.01595 ± 0.000197257 (W 0.000177162) | · | 🔴 fork 2.35× slower |  |
| `gemm/96x96x96/b1` | 0.051517 ± 0.00042138 (W 0.00129673) | 0.051807 ± 0.00107755 (W 0.00092734) | 0.042569 ± 0.000311193 (W 0.000394024) | · | 🔴 fork 1.21× slower |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133572 ± 0.000266635 (W 0.00128599) | 0.13375 ± 7.23948e-05 (W 0.000851189) | 0.166873 ± 0.000654688 (W 0.00119152) | · | 🔵 fork 1.25× faster |  |
| `gemm/192x192x192/b1` | 0.451666 ± 0.00125076 (W 0.00184028) | 0.450845 ± 0.00186858 (W 0.00187581) | 0.48196 ± 0.00185149 (W 0.00177987) | · | 🔵 fork 1.07× faster |  |
| `gemm/256x256x256/b1` | 1.07298 ± 0.00276179 (W 0.00171045) | 1.07428 ± 0.0034707 (W 0.000949293) | 1.1977 ± 0.00386598 (W 0.00146549) | · | 🔵 fork 1.12× faster |  |
| `gemm/384x384x384/b1` | 3.61071 ± 0.0112907 (W 0.00416878) | 3.6132 ± 0.00714466 (W 0.00293297) | 3.7253 ± 0.043448 (W 0.00355549) | · | · |  |
| `gemm/512x512x512/b1` | 8.59666 ± 0.0312868 (W 0.0041914) | 8.601 ± 0.0179967 (W 0.00978482) | 9.85752 ± 0.0184726 (W 0.00507704) | · | 🔵 fork 1.15× faster |  |
| `gemm/768x768x768/b1` | 29.3249 ± 0.0259846 (W 0.0160248) | 29.3732 ± 0.0463462 (W 0.0174428) | 30.4044 ± 0.187881 (W 0.0136798) | · | · |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.061245 ± 0.0188777 (W 0.0195939) | 0.085831 ± 0.0143197 (W 0.0165187) | 0.056637 ± 0.000479585 (W 0.000366484) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.145733 ± 0.0118203 (W 0.0120201) | 0.163438 ± 0.012577 (W 0.014678) | 0.135554 ± 0.00723623 (W 0.00101038) | 🔵 fork 1.12× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.306323 ± 0.0294867 (W 0.00782012) | 0.316326 ± 0.0243277 (W 0.00447369) | 0.34455 ± 0.0499768 (W 0.00789483) | · | · | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.927568 ± 0.0572373 (W 0.00388894) | 0.929873 ± 0.0604497 (W 0.00422881) | 1.01509 ± 0.147706 (W 0.0029825) | · | · | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 2.24664 ± 0.115995 (W 0.00520297) | 2.23988 ± 0.11521 (W 0.00804761) | 3.02909 ± 0.19433 (W 0.00684736) | · | 🔵 fork 1.35× faster | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.52887 ± 0.434946 (W 0.0298556) | 7.53233 ± 0.417347 (W 0.02456) | 8.48471 ± 0.231212 (W 0.00859332) | · | 🔵 fork 1.13× faster | `!` between-start range over 5% |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.110637 ± 0.021059 (W 0.0103071) | 0.081253 ± 0.00711189 (W 0.014752) | 0.033122 ± 0.000740452 (W 0.000368165) | 🔴 fork 1.36× slower | 🔴 fork 3.34× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.190176 ± 0.0165707 (W 0.0392644) | 0.187541 ± 0.0254601 (W 0.0334736) | 0.074029 ± 0.000400546 (W 0.000234178) | · | 🔴 fork 2.57× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.196147 ± 0.0139131 (W 0.0223197) | 0.208811 ± 0.0119497 (W 0.0369024) | 0.178484 ± 0.000567014 (W 0.00189354) | · | 🔴 fork 1.10× slower | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.559705 ± 0.00643372 (W 0.00669939) | 0.56273 ± 0.00369568 (W 0.0126506) | 0.514288 ± 0.000923452 (W 0.00193394) | · | 🔴 fork 1.09× slower |  |
| `gemm/512x512x512/b1` | 1.19284 ± 0.0115783 (W 0.0171786) | 1.20391 ± 0.00445145 (W 0.011195) | 1.53187 ± 0.0148108 (W 0.00651834) | · | 🔵 fork 1.28× faster |  |
| `gemm/768x768x768/b1` | 3.92921 ± 0.0104647 (W 0.0179117) | 3.94181 ± 0.0127081 (W 0.0157272) | 4.66828 ± 0.0159108 (W 0.0181) | · | 🔵 fork 1.19× faster |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133703 ± 0.000196502 (W 5.82254e-05) | 0.133602 ± 0.000129108 (W 0.00105905) | 0.167744 ± 0.0002127 (W 0.00156141) | · | 🔵 fork 1.25× faster |  |
| `gemm/192x192x192/b1` | 0.450981 ± 0.000726254 (W 0.00196049) | 0.454017 ± 0.0011476 (W 0.00306594) | 0.481709 ± 0.00139267 (W 0.00214892) | · | 🔵 fork 1.07× faster |  |
| `gemm/256x256x256/b1` | 1.07288 ± 0.00205686 (W 0.000580417) | 1.07505 ± 0.00154134 (W 0.00091364) | 1.20131 ± 0.0065468 (W 0.00187281) | · | 🔵 fork 1.12× faster |  |
| `gemm/384x384x384/b1` | 3.61421 ± 0.00654184 (W 0.0024372) | 3.61569 ± 0.00682163 (W 0.00340356) | 3.71949 ± 0.0400174 (W 0.00247945) | · | · |  |
| `gemm/512x512x512/b1` | 8.61607 ± 0.0210943 (W 0.0120582) | 8.60839 ± 0.0176519 (W 0.00787349) | 9.78725 ± 0.0219577 (W 0.00963901) | · | 🔵 fork 1.14× faster |  |
| `gemm/768x768x768/b1` | 29.437 ± 0.0703598 (W 0.017803) | 29.4536 ± 0.0610483 (W 0.0184187) | 30.4182 ± 0.247639 (W 0.0216261) | · | · |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.057618 ± 0.018417 (W 0.0176586) | 0.099738 ± 0.00858412 (W 0.0105472) | 0.055604 ± 0.000379039 (W 0.000241231) | 🔵 fork 1.73× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.146003 ± 0.00212426 (W 0.0122023) | 0.162236 ± 0.0034299 (W 0.0100465) | 0.135346 ± 0.00570479 (W 0.00133281) | 🔵 fork 1.11× faster | 🔴 fork 1.08× slower | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.310315 ± 0.0183657 (W 0.00843241) | 0.305321 ± 0.0255801 (W 0.00518683) | 0.343918 ± 0.0425413 (W 0.00172254) | · | · | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 0.932113 ± 0.054585 (W 0.00505031) | 0.92867 ± 0.0470412 (W 0.00509989) | 1.00589 ± 0.125078 (W 0.00330299) | · | · | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 2.23727 ± 0.125288 (W 0.00350841) | 2.2322 ± 0.110563 (W 0.0108278) | 3.04695 ± 0.2622 (W 0.013248) | · | 🔵 fork 1.36× faster | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.51223 ± 0.427517 (W 0.0119754) | 7.51857 ± 0.422858 (W 0.00696989) | 8.50002 ± 0.226687 (W 0.0195364) | · | 🔵 fork 1.13× faster | `!` between-start range over 5% |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.062848 ± 0.009626 (W 0.0313975) | 0.084067 ± 0.011472 (W 0.0275135) | 0.0319 ± 0.000185831 (W 0.000269335) | 🔵 fork 1.34× faster | 🔴 fork 1.97× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.151203 ± 0.0230476 (W 0.0265914) | 0.151945 ± 0.0151354 (W 0.0299456) | 0.074339 ± 0.000467984 (W 0.0013362) | · | 🔴 fork 2.03× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.254817 ± 0.0105209 (W 0.0260373) | 0.219049 ± 0.0294358 (W 0.0262462) | 0.179445 ± 0.00165161 (W 0.00136298) | 🔴 fork 1.16× slower | 🔴 fork 1.42× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.563662 ± 0.00611551 (W 0.0111681) | 0.561671 ± 0.000665795 (W 0.00764946) | 0.515865 ± 0.00429132 (W 0.00179229) | · | 🔴 fork 1.09× slower |  |
| `gemm/512x512x512/b1` | 1.19487 ± 0.00431787 (W 0.00783133) | 1.19012 ± 0.00960006 (W 0.012764) | 1.5269 ± 0.0158502 (W 0.0039966) | · | 🔵 fork 1.28× faster |  |
| `gemm/768x768x768/b1` | 3.93955 ± 0.0202324 (W 0.0141911) | 3.95778 ± 0.0185531 (W 0.0234574) | 4.6627 ± 0.0179941 (W 0.0147419) | · | 🔵 fork 1.18× faster |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538105 ± 0.001017 (W 0.00180393) | 0.537266 ± 0.000844418 (W 0.00167755) | 0.649366 ± 0.00702508 (W 0.00531994) | · | 🔵 fork 1.21× faster |  |
| `gemm/192x192x192/b1` | 1.81136 ± 0.00136105 (W 0.00214513) | 1.81 ± 0.000542385 (W 0.00169563) | 2.16016 ± 0.00354886 (W 0.0119342) | · | 🔵 fork 1.19× faster |  |
| `gemm/256x256x256/b1` | 4.28212 ± 0.0100227 (W 0.00150538) | 4.27945 ± 0.0112178 (W 0.00301276) | 5.07029 ± 0.0265307 (W 0.0159643) | · | 🔵 fork 1.18× faster |  |
| `gemm/384x384x384/b1` | 14.4416 ± 0.0331517 (W 0.0136404) | 14.4452 ± 0.0239487 (W 0.00658425) | 17.1834 ± 0.0478187 (W 0.0278159) | · | 🔵 fork 1.19× faster |  |
| `gemm/512x512x512/b1` | 34.3266 ± 0.0102292 (W 0.0245544) | 34.3212 ± 0.00451204 (W 0.0176901) | 40.808 ± 0.116312 (W 0.0546144) | · | 🔵 fork 1.19× faster |  |
| `gemm/768x768x768/b1` | 116.552 ± 0.0883773 (W 0.0341184) | 116.368 ± 0.248015 (W 0.0420079) | 136.911 ± 0.531706 (W 0.352443) | · | 🔵 fork 1.17× faster |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.16072 ± 0.0034846 (W 0.00197624) | 0.165492 ± 0.00301726 (W 0.00692357) | 0.235284 ± 0.00681964 (W 0.00226326) | · | 🔵 fork 1.46× faster | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.474788 ± 0.0259646 (W 0.00201474) | 0.476381 ± 0.016761 (W 0.00442659) | 0.742168 ± 0.0599838 (W 0.00697496) | · | 🔵 fork 1.56× faster | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 1.12595 ± 0.0523542 (W 0.00418879) | 1.12656 ± 0.0453205 (W 0.00393871) | 1.82248 ± 0.070512 (W 0.00612546) | · | 🔵 fork 1.62× faster | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 3.67226 ± 0.149696 (W 0.00590199) | 3.66729 ± 0.146453 (W 0.00755321) | 5.79874 ± 0.452623 (W 0.0116019) | · | 🔵 fork 1.58× faster | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 8.70264 ± 0.440307 (W 0.0324444) | 8.69683 ± 0.440378 (W 0.0229263) | 13.8689 ± 0.415191 (W 0.0217862) | · | 🔵 fork 1.59× faster | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 29.4266 ± 2.05572 (W 0.0240726) | 29.3889 ± 2.05491 (W 0.0109421) | 46.6602 ± 1.18934 (W 0.0603079) | · | 🔵 fork 1.59× faster | `!` between-start range over 5% |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.118924 ± 0.00254192 (W 0.0147528) | 0.116548 ± 0.00926231 (W 0.0144817) | 0.094698 ± 0.000477034 (W 0.00092273) | · | 🔴 fork 1.26× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.276978 ± 0.0103687 (W 0.0141781) | 0.27601 ± 0.00509444 (W 0.0120301) | 0.297507 ± 0.00152841 (W 0.00160711) | · | 🔵 fork 1.07× faster | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.608197 ± 0.00176464 (W 0.0113876) | 0.608809 ± 0.00842323 (W 0.0142072) | 0.70563 ± 0.00526709 (W 0.00435031) | · | 🔵 fork 1.16× faster |  |
| `gemm/384x384x384/b1` | 1.87629 ± 0.00245564 (W 0.0117538) | 1.86437 ± 0.00756076 (W 0.00473896) | 2.28237 ± 0.0058798 (W 0.00686698) | · | 🔵 fork 1.22× faster |  |
| `gemm/512x512x512/b1` | 4.51258 ± 0.0117513 (W 0.0122693) | 4.50172 ± 0.0199089 (W 0.0143633) | 5.54304 ± 0.0202063 (W 0.050082) | · | 🔵 fork 1.23× faster |  |
| `gemm/768x768x768/b1` | 14.9725 ± 0.019554 (W 0.0312698) | 14.972 ± 0.0282487 (W 0.0113306) | 18.5316 ± 0.284353 (W 0.101658) | · | 🔵 fork 1.24× faster |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538118 ± 0.00113852 (W 0.00169533) | 0.537875 ± 0.000413718 (W 0.00186825) | 0.648734 ± 0.00398192 (W 0.00650575) | · | 🔵 fork 1.21× faster |  |
| `gemm/192x192x192/b1` | 1.81317 ± 0.00310607 (W 0.00224695) | 1.81457 ± 0.00352166 (W 0.00189909) | 2.15831 ± 0.0050618 (W 0.00894128) | · | 🔵 fork 1.19× faster |  |
| `gemm/256x256x256/b1` | 4.28213 ± 0.00665453 (W 0.00243318) | 4.2802 ± 0.0090117 (W 0.00137597) | 5.14355 ± 0.0190449 (W 0.0126212) | · | 🔵 fork 1.20× faster |  |
| `gemm/384x384x384/b1` | 14.4317 ± 0.0287707 (W 0.0106109) | 14.4315 ± 0.0284874 (W 0.0142148) | 17.1684 ± 0.00359568 (W 0.0312136) | · | 🔵 fork 1.19× faster |  |
| `gemm/512x512x512/b1` | 34.3442 ± 0.0149229 (W 0.0164179) | 34.3193 ± 0.0192469 (W 0.0230619) | 40.9869 ± 0.0919963 (W 0.0396328) | · | 🔵 fork 1.19× faster |  |
| `gemm/768x768x768/b1` | 116.47 ± 0.0781905 (W 0.0456937) | 116.459 ± 0.0350872 (W 0.382729) | 137.096 ± 0.0795444 (W 0.123389) | · | 🔵 fork 1.18× faster |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.164518 ± 0.00475743 (W 0.00309278) | 0.164909 ± 0.00843912 (W 0.00298881) | 0.233671 ± 0.00256031 (W 0.00219276) | · | 🔵 fork 1.42× faster | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.474828 ± 0.0238985 (W 0.00304894) | 0.474434 ± 0.0221103 (W 0.00228698) | 0.745375 ± 0.0460666 (W 0.00532307) | · | 🔵 fork 1.57× faster | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 1.12683 ± 0.0449592 (W 0.0023797) | 1.12821 ± 0.0498172 (W 0.00319661) | 1.79982 ± 0.069571 (W 0.0056175) | · | 🔵 fork 1.60× faster | `!` between-start range over 5% |
| `gemm/384x384x384/b1` | 3.67191 ± 0.160417 (W 0.00738131) | 3.66568 ± 0.150462 (W 0.009522) | 5.78675 ± 0.425976 (W 0.0145112) | · | 🔵 fork 1.58× faster | `!` between-start range over 5% |
| `gemm/512x512x512/b1` | 8.69293 ± 0.458466 (W 0.00597554) | 8.70672 ± 0.448439 (W 0.0233066) | 13.7664 ± 0.460664 (W 0.00960445) | · | 🔵 fork 1.58× faster | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 29.4247 ± 2.09053 (W 0.0261578) | 29.3717 ± 2.08923 (W 0.0293128) | 46.5667 ± 1.1889 (W 0.0735169) | · | 🔵 fork 1.58× faster | `!` between-start range over 5% |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.112963 ± 0.000946163 (W 0.00806524) | 0.114494 ± 0.00370445 (W 0.0144864) | 0.094917 ± 0.000360772 (W 0.000837326) | · | 🔴 fork 1.19× slower | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.278451 ± 0.00759183 (W 0.00817903) | 0.279953 ± 0.00740146 (W 0.0090134) | 0.297787 ± 0.00259637 (W 0.00286723) | · | 🔵 fork 1.07× faster | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.607517 ± 0.00123724 (W 0.00705974) | 0.605523 ± 0.00636722 (W 0.0142499) | 0.715978 ± 0.0136868 (W 0.00194867) | · | 🔵 fork 1.18× faster |  |
| `gemm/384x384x384/b1` | 1.87443 ± 0.00942701 (W 0.00538131) | 1.86854 ± 0.0101992 (W 0.00923688) | 2.28317 ± 0.00937052 (W 0.00455887) | · | 🔵 fork 1.22× faster |  |
| `gemm/512x512x512/b1` | 4.50483 ± 0.00932341 (W 0.0113383) | 4.511 ± 0.0148013 (W 0.00992706) | 5.52245 ± 0.00833587 (W 0.0148602) | · | 🔵 fork 1.23× faster |  |
| `gemm/768x768x768/b1` | 14.9987 ± 0.0198561 (W 0.0441881) | 15.0476 ± 0.0334614 (W 0.0390303) | 18.6727 ± 0.103735 (W 0.0902429) | · | 🔵 fork 1.24× faster |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.27116 ± 0.0213006 (W 0.00270976) | 1.27503 ± 0.0603868 (W 0.00507376) | 1.66791 ± 0.013517 (W 0.00329543) | · | 🔵 fork 1.31× faster | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.0745 ± 0.0115294 (W 0.00763373) | 1.07009 ± 0.000426852 (W 0.00176584) | 1.51546 ± 0.00710153 (W 0.012325) | · | 🔵 fork 1.41× faster |  |
| `gemm/4096x64x64/b1` | 1.0839 ± 0.000829452 (W 0.000717359) | 1.0841 ± 0.00981404 (W 0.000766316) | 1.56142 ± 0.010035 (W 0.00251824) | · | 🔵 fork 1.44× faster |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.437939 ± 0.0050093 (W 0.00401326) | 0.434442 ± 0.00172946 (W 0.00466774) | 0.423046 ± 0.00582247 (W 0.00396108) | · | · |  |
| `gemm/4096x16x240/b1` | 0.330041 ± 0.00292703 (W 0.00269598) | 0.333053 ± 0.0040987 (W 0.0025752) | 0.425982 ± 0.00203173 (W 0.00221104) | · | 🔵 fork 1.29× faster |  |
| `gemm/4096x64x64/b1` | 0.308126 ± 0.00546839 (W 0.00943873) | 0.30476 ± 0.00487884 (W 0.00846384) | 0.393305 ± 0.0026957 (W 0.00251789) | · | 🔵 fork 1.28× faster |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.441571 ± 0.00279475 (W 0.00288174) | 0.440098 ± 0.00276547 (W 0.00534938) | 0.258526 ± 0.0146362 (W 0.00242265) | · | 🔴 fork 1.71× slower | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.210934 ± 0.000146429 (W 0.00378119) | 0.215134 ± 0.00258064 (W 0.0044865) | 0.28864 ± 0.00170417 (W 0.0306955) | · | 🔵 fork 1.37× faster |  |
| `gemm/4096x64x64/b1` | 0.205706 ± 0.00648863 (W 0.0203691) | 0.202258 ± 0.0022318 (W 0.00893953) | 0.198091 ± 0.00165556 (W 0.00145012) | · | · | `!` between-start range over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.0436 ± 0.0195823 (W 0.00251637) | 1.03582 ± 0.0157528 (W 0.00125386) | 2.64587 ± 0.0103643 (W 0.00709254) | · | 🔵 fork 2.54× faster |  |
| `gemm/4096x16x240/b1` | 1.09218 ± 0.00535181 (W 0.00655744) | 1.09352 ± 0.00419698 (W 0.00251265) | 1.42659 ± 0.00517584 (W 0.00982322) | · | 🔵 fork 1.31× faster |  |
| `gemm/4096x64x64/b1` | 1.12818 ± 0.00601943 (W 0.00233062) | 1.12876 ± 0.00648736 (W 0.00190143) | 1.23758 ± 0.0129502 (W 0.00303405) | · | 🔵 fork 1.10× faster |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.709165 ± 0.0102987 (W 0.0226168) | 0.697796 ± 0.0235857 (W 0.0225616) | 0.646148 ± 0.00178459 (W 0.00276363) | · | 🔴 fork 1.10× slower | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.318709 ± 0.00212883 (W 0.00257759) | 0.319421 ± 0.00294907 (W 0.00407132) | 0.43028 ± 0.000901866 (W 0.00257691) | · | 🔵 fork 1.35× faster |  |
| `gemm/4096x64x64/b1` | 0.311172 ± 0.0029475 (W 0.00368006) | 0.309403 ± 0.00200366 (W 0.00551866) | 0.333047 ± 0.00340494 (W 0.00223723) | · | 🔵 fork 1.07× faster |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.13082 ± 0.0122676 (W 0.0389218) | 1.1349 ± 0.00936161 (W 0.022072) | 0.348365 ± 0.00477205 (W 0.00345177) | · | 🔴 fork 3.25× slower |  |
| `gemm/4096x16x240/b1` | 0.197401 ± 0.00254227 (W 0.00569216) | 0.200067 ± 0.00216652 (W 0.00259497) | 0.295806 ± 0.00176043 (W 0.00193075) | · | 🔵 fork 1.50× faster |  |
| `gemm/4096x64x64/b1` | 0.180368 ± 0.00168585 (W 0.00654678) | 0.181361 ± 0.0034338 (W 0.00433392) | 0.175681 ± 0.00283348 (W 0.00190459) | · | · |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.14805 ± 0.00891803 (W 0.00621783) | 4.13771 ± 0.00501816 (W 0.00436042) | 5.67204 ± 0.0413942 (W 0.0128989) | · | 🔵 fork 1.37× faster |  |
| `gemm/4096x16x240/b1` | 4.3288 ± 0.0135934 (W 0.00192574) | 4.32982 ± 0.00631695 (W 0.00259722) | 5.60802 ± 0.0143458 (W 0.0378775) | · | 🔵 fork 1.30× faster |  |
| `gemm/4096x64x64/b1` | 4.38638 ± 0.0284256 (W 0.00296862) | 4.38976 ± 0.0319265 (W 0.00989567) | 5.25338 ± 0.0134153 (W 0.014399) | · | 🔵 fork 1.20× faster |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.67077 ± 0.0066321 (W 0.00396644) | 1.66649 ± 0.00557232 (W 0.00324771) | 1.92899 ± 0.00983693 (W 0.00562312) | · | 🔵 fork 1.15× faster |  |
| `gemm/4096x16x240/b1` | 1.20426 ± 0.00450028 (W 0.00589922) | 1.20332 ± 0.0018156 (W 0.00915351) | 2.17694 ± 0.130558 (W 0.0337722) | · | 🔵 fork 1.81× faster | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.14957 ± 0.00440445 (W 0.00397128) | 1.15338 ± 0.00217557 (W 0.00282174) | 2.06947 ± 0.00816423 (W 0.00288467) | · | 🔵 fork 1.80× faster |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.91994 ± 0.0117404 (W 0.00477297) | 0.922976 ± 0.00558378 (W 0.00664951) | 0.948774 ± 0.00404506 (W 0.0039392) | · | · |  |
| `gemm/4096x16x240/b1` | 0.640238 ± 0.00347888 (W 0.00321793) | 0.642949 ± 0.00674424 (W 0.00727989) | 0.997616 ± 0.188279 (W 0.00530423) | · | 🔵 fork 1.56× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.60418 ± 0.0005547 (W 0.00325676) | 0.607125 ± 0.0147691 (W 0.0169648) | 0.758589 ± 0.00860795 (W 0.00222289) | · | 🔵 fork 1.26× faster |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07181 ± 0.0252044 (W 0.00410231) | 4.0639 ± 0.0286241 (W 0.00701317) | 5.73485 ± 0.0124288 (W 0.0227804) | · | 🔵 fork 1.41× faster |  |
| `gemm/4096x16x240/b1` | 4.35496 ± 0.021857 (W 0.00307709) | 4.38292 ± 0.0170556 (W 0.00311088) | 5.40819 ± 0.0307515 (W 0.0358556) | · | 🔵 fork 1.24× faster |  |
| `gemm/4096x64x64/b1` | 4.45287 ± 0.00647679 (W 0.00444348) | 4.45018 ± 0.00890279 (W 0.00530554) | 5.74612 ± 0.0588749 (W 0.0115833) | · | 🔵 fork 1.29× faster |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.95178 ± 0.0116424 (W 0.0423529) | 1.91886 ± 0.0418058 (W 0.0175739) | 10.8137 ± 6.1468 (W 0.0229559) | · | 🔵 fork 5.54× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.21122 ± 0.00301407 (W 0.00502541) | 1.21 ± 0.00395776 (W 0.00459615) | 2.3802 ± 0.0137121 (W 0.0282082) | · | 🔵 fork 1.97× faster |  |
| `gemm/4096x64x64/b1` | 1.22122 ± 0.00973262 (W 0.0115254) | 1.21022 ± 0.00689089 (W 0.00716043) | 2.04013 ± 0.00727597 (W 0.0166817) | · | 🔵 fork 1.67× faster |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.56571 ± 0.00549991 (W 0.0400002) | 2.5512 ± 0.0259358 (W 0.0529382) | 11.097 ± 4.04045 (W 0.0237158) | · | 🔵 fork 4.33× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.639883 ± 0.00323696 (W 0.00580959) | 0.641687 ± 0.00390208 (W 0.00564921) | 1.52956 ± 0.14551 (W 0.0198026) | · | 🔵 fork 2.39× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.618393 ± 0.00571126 (W 0.00613364) | 0.620881 ± 0.00564465 (W 0.00500776) | 1.23851 ± 0.063919 (W 0.0819586) | · | 🔵 fork 2.00× faster | `!` between-start range over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12181 ± 0.0124145 (W 0.00329713) | 1.12539 ± 0.00801153 (W 0.00165813) | 1.23587 ± 0.00545257 (W 0.00174236) | · | 🔵 fork 1.10× faster |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.313139 ± 0.00353162 (W 0.00462548) | 0.311776 ± 0.00255719 (W 0.00302865) | 0.33171 ± 0.00240056 (W 0.00234052) | · | 🔵 fork 1.06× faster |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.180528 ± 0.00155914 (W 0.00347992) | 0.180658 ± 0.00464876 (W 0.00432876) | 0.174879 ± 0.00373979 (W 0.00143581) | · | · | `!` between-start range over 5% |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08889 ± 0.00740268 (W 0.00118808) | 1.08938 ± 0.00805372 (W 0.0013133) | 1.55293 ± 0.0150917 (W 0.00261649) | · | 🔵 fork 1.43× faster |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.310391 ± 0.00183455 (W 0.00589104) | 0.306874 ± 0.00485334 (W 0.00396822) | 0.389588 ± 0.00279273 (W 0.00190226) | · | 🔵 fork 1.26× faster |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.213138 ± 0.0248136 (W 0.0221676) | 0.199093 ± 0.0147478 (W 0.00864504) | 0.198443 ± 0.000539927 (W 0.00133969) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.44377 ± 0.00734757 (W 0.00871727) | 4.43889 ± 0.00436544 (W 0.00695904) | 5.76815 ± 0.00761868 (W 0.0186955) | · | 🔵 fork 1.30× faster |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.21642 ± 0.0139795 (W 0.00676563) | 1.21423 ± 0.00371543 (W 0.0149799) | 2.04494 ± 0.0125862 (W 0.0102124) | · | 🔵 fork 1.68× faster |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.622601 ± 0.0100118 (W 0.00530664) | 0.620751 ± 0.00568425 (W 0.00409297) | 1.16609 ± 0.159421 (W 0.0743658) | · | 🔵 fork 1.87× faster | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.40667 ± 0.0239676 (W 0.00495542) | 4.40782 ± 0.0274366 (W 0.00442828) | 5.22478 ± 0.0058716 (W 0.0122842) | · | 🔵 fork 1.19× faster |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.15527 ± 0.00933516 (W 0.00503926) | 1.14188 ± 0.0118161 (W 0.00425732) | 2.06226 ± 0.0099179 (W 0.00399951) | · | 🔵 fork 1.79× faster |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.601706 ± 0.00348646 (W 0.00590829) | 0.602313 ± 0.000761822 (W 0.00402278) | 0.758077 ± 0.00350507 (W 0.00237629) | · | 🔵 fork 1.26× faster |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003196 ± 0.000170392 (W 2.60768e-05) | 0.003406 ± 1.52753e-05 (W 2.18243e-05) | 0.004208 ± 6.08276e-05 (W 1.87083e-05) | 🔵 fork 1.07× faster | 🔵 fork 1.32× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015128 ± 0.0011785 (W 6.73372e-05) | 0.016671 ± 2.13776e-05 (W 4.20274e-05) | 0.016962 ± 5.03322e-05 (W 5.98331e-05) | 🔵 fork 1.10× faster | 🔵 fork 1.12× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.031249 ± 0.00137236 (W 5.70719e-05) | 0.032972 ± 0.000161298 (W 9.47011e-05) | 0.048411 ± 2.70247e-05 (W 0.000126512) | 🔵 fork 1.06× faster | 🔵 fork 1.55× faster | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112922 ± 0.000193357 (W 0.000214571) | 0.112892 ± 0.000110666 (W 0.00131108) | 0.100588 ± 0.000173267 (W 0.00114331) | · | 🔴 fork 1.12× slower |  |
| `eigh/n64/b1` | 0.484305 ± 0.00150593 (W 0.00138348) | 0.484871 ± 0.00163594 (W 0.00169437) | 0.393156 ± 0.00226621 (W 0.00155161) | · | 🔴 fork 1.23× slower |  |
| `eigh/n96/b1` | 1.15752 ± 0.00118224 (W 0.00247628) | 1.15896 ± 0.00609722 (W 0.00159044) | 0.90901 ± 0.00378969 (W 0.00641843) | · | 🔴 fork 1.27× slower |  |
| `full_piv_lu/n32/b1` | 0.01041 ± 0.000308923 (W 0.000161462) | 0.01084 ± 0.000263122 (W 7.42314e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.047028 ± 9.84886e-05 (W 0.000164864) | 0.046687 ± 0.000277921 (W 9.07811e-05) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.134602 ± 0.000958224 (W 0.00239062) | 0.134532 ± 0.00082837 (W 0.00246124) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008025 ± 4.50925e-05 (W 4.54973e-05) | 0.008106 ± 2.09841e-05 (W 2.16795e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008055 ± 2.3094e-05 (W 2.20045e-05) | 0.008105 ± 0.000119304 (W 2.63287e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040185 ± 9.89966e-05 (W 6.81909e-05) | 0.040125 ± 0.000147988 (W 3.25161e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040466 ± 8.72028e-05 (W 7.02659e-05) | 0.040646 ± 9.13072e-05 (W 8.28571e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.120586 ± 0.000122639 (W 0.000187132) | 0.120847 ± 0.000125261 (W 0.00150415) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.120837 ± 0.000121903 (W 0.00128105) | 0.120836 ± 0.000305485 (W 0.00145096) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007634 ± 5.2915e-05 (W 0.000152811) | 0.007443 ± 3.04467e-05 (W 0.000152414) | 0.012253 ± 2.51661e-05 (W 0.00109201) | · | 🔵 fork 1.61× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.02634 ± 0.00029611 (W 0.000120097) | 0.026249 ± 0.000433348 (W 0.000175029) | 0.043021 ± 0.000104644 (W 0.000122474) | · | 🔵 fork 1.63× faster |  |
| `lu/n96/b1` | 0.066605 ± 0.000884882 (W 0.00219921) | 0.066825 ± 0.000794394 (W 0.00266332) | 0.110737 ± 0.00082686 (W 0.00220982) | · | 🔵 fork 1.66× faster |  |
| `qr/n32/b1` | 0.031509 ± 0.000100664 (W 0.000109641) | 0.032481 ± 0.000255016 (W 0.000169921) | 0.026499 ± 0.0335433 (W 0.000105451) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.116528 ± 2.6839e-05 (W 0.00110282) | 0.11763 ± 1.0504e-05 (W 0.000324177) | 0.134201 ± 0.000379868 (W 0.000740604) | · | 🔵 fork 1.15× faster |  |
| `qr/n96/b1` | 0.292247 ± 0.00025918 (W 0.00305313) | 0.293198 ± 0.000285819 (W 0.00266844) | 0.409226 ± 0.0128377 (W 0.00359223) | · | 🔵 fork 1.40× faster | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023875 ± 0.000179556 (W 5.94138e-05) | 0.028483 ± 0.000125527 (W 0.000104782) | 0.014086 ± 4.14769e-05 (W 6.4064e-05) | 🔵 fork 1.19× faster | 🔴 fork 1.69× slower |  |
| `qr_factor/n64/b1` | 0.103925 ± 0.000451077 (W 0.00128543) | 0.129392 ± 0.000175291 (W 0.00122044) | 0.298358 ± 0.133646 (W 0.00108598) | 🔵 fork 1.25× faster | 🔵 fork 2.87× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.223588 ± 0.000229121 (W 0.0012735) | 0.284321 ± 0.000209677 (W 0.00143298) | 0.206218 ± 0.000847243 (W 0.00149984) | 🔵 fork 1.27× faster | 🔴 fork 1.08× slower |  |
| `solve/n32/b1` | 0.008576 ± 7.63763e-05 (W 7.23187e-05) | 0.008466 ± 0.000161658 (W 0.000138746) | 0.012774 ± 5.03322e-05 (W 6.37966e-05) | · | 🔵 fork 1.49× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026971 ± 0.00050669 (W 0.000186009) | 0.026941 ± 0.000333242 (W 0.000180428) | 0.043631 ± 0.000131226 (W 7.27344e-05) | · | 🔵 fork 1.62× faster |  |
| `solve/n96/b1` | 0.068669 ± 0.000975799 (W 0.00257535) | 0.068648 ± 0.000437555 (W 0.00235698) | 0.103954 ± 0.000145317 (W 0.00113334) | · | 🔵 fork 1.51× faster |  |
| `svd_thin/n32/b1` | 0.183844 ± 0.000107337 (W 0.00123437) | 0.183054 ± 0.000482702 (W 0.00149391) | 0.177282 ± 9.40284e-05 (W 0.00117639) | · | · |  |
| `svd_thin/n64/b1` | 0.918367 ± 0.00908145 (W 0.00116443) | 0.917064 ± 0.00920943 (W 0.00171957) | 0.740735 ± 0.0224394 (W 0.00536857) | · | 🔴 fork 1.24× slower | `!` between-start range over 5% |
| `svd_thin/n96/b1` | 2.2119 ± 0.0365952 (W 0.00296838) | 2.21041 ± 0.00227076 (W 0.00301172) | 1.68596 ± 0.0574894 (W 0.00471413) | · | 🔴 fork 1.31× slower | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.141023 ± 0.000727574 (W 0.00138696) | 0.140344 ± 0.000425939 (W 0.00124697) | 0.064351 ± 0.0427404 (W 0.000109724) | · | 🔴 fork 2.19× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.520508 ± 0.00274115 (W 0.0016503) | 0.517708 ± 0.00455534 (W 0.00179955) | 0.266017 ± 0.000290159 (W 0.00125244) | · | 🔴 fork 1.96× slower |  |
| `svd_values/n96/b1` | 1.18459 ± 0.000190421 (W 0.00174799) | 1.18054 ± 0.0010707 (W 0.00143189) | 0.638153 ± 0.00641534 (W 0.00187329) | · | 🔴 fork 1.86× slower |  |
| `triangular_solve/n32/b1` | 0.000672 ± 1.0504e-05 (W 7.95613e-06) | 0.000671 ± 5.7735e-06 (W 5.6745e-06) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001483 ± 1.52753e-05 (W 2.16795e-05) | 0.001492 ± 4.09512e-05 (W 2.4984e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002685 ± 7.81025e-05 (W 2.70185e-05) | 0.002575 ± 7.0946e-05 (W 3.04959e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003176 ± 0.000182511 (W 3.08221e-05) | 0.003386 ± 2.70247e-05 (W 2.13378e-05) | 0.004198 ± 9.50438e-06 (W 2.34585e-05) | 🔵 fork 1.07× faster | 🔵 fork 1.32× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015198 ± 0.00112167 (W 2.93292e-05) | 0.016681 ± 5.56776e-05 (W 5.22494e-05) | 0.016892 ± 8.56174e-05 (W 7.88302e-05) | 🔵 fork 1.10× faster | 🔵 fork 1.11× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.067657 ± 0.00554239 (W 0.00470544) | 0.063248 ± 0.00286275 (W 0.0064421) | 0.04857 ± 0.000142584 (W 0.0012652) | · | 🔴 fork 1.39× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113202 ± 0.000601741 (W 0.000242834) | 0.112401 ± 8.20183e-05 (W 0.00116224) | 0.105558 ± 0.000399351 (W 0.00123462) | · | 🔴 fork 1.07× slower |  |
| `eigh/n64/b1` | 0.498903 ± 0.00193677 (W 0.00392417) | 0.501057 ± 0.00127498 (W 0.00409895) | 0.27244 ± 0.000847907 (W 0.00178504) | · | 🔴 fork 1.83× slower |  |
| `eigh/n96/b1` | 1.2135 ± 0.00845535 (W 0.0192055) | 1.21242 ± 0.0034105 (W 0.018949) | 0.592683 ± 0.00109459 (W 0.00155251) | · | 🔴 fork 2.05× slower |  |
| `full_piv_lu/n32/b1` | 0.01042 ± 0.000213854 (W 0.000172134) | 0.010921 ± 0.000274083 (W 0.000100176) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046958 ± 0.000420574 (W 6.01598e-05) | 0.047479 ± 0.00017342 (W 0.000122038) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.1337 ± 0.000524447 (W 0.00214118) | 0.133831 ± 0.000934058 (W 0.00219454) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008385 ± 1.00167e-05 (W 7.27063e-05) | 0.008356 ± 8.66622e-05 (W 9.00178e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008506 ± 6.55744e-05 (W 6.91252e-05) | 0.008376 ± 0.000112694 (W 0.000109432) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.023514 ± 0.000145258 (W 0.000562302) | 0.023504 ± 0.00019713 (W 0.000312118) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.023975 ± 0.000481865 (W 0.00110926) | 0.024866 ± 0.0010315 (W 0.00163166) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049222 ± 0.000362809 (W 0.00134568) | 0.049533 ± 0.000317163 (W 0.00174654) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.048792 ± 0.000560352 (W 0.000797832) | 0.049543 ± 0.000887886 (W 0.00160021) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007464 ± 0.000154306 (W 0.000118614) | 0.007464 ± 7.76745e-05 (W 0.000223977) | 0.012143 ± 1.73205e-05 (W 9.37017e-05) | · | 🔵 fork 1.63× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.041277 ± 0.00238806 (W 0.00249928) | 0.046306 ± 0.00186236 (W 0.00126855) | 0.04287 ± 0.000136956 (W 0.000141401) | 🔵 fork 1.12× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n96/b1` | 0.097984 ± 0.0056665 (W 0.00725231) | 0.101961 ± 0.0022772 (W 0.00261723) | 0.093616 ± 0.000573992 (W 0.00360926) | · | · | `!` between-start range over 5% |
| `qr/n32/b1` | 0.116589 ± 0.00540228 (W 0.00571088) | 0.11763 ± 0.00409411 (W 0.00698315) | 0.026269 ± 0.0337225 (W 0.000204701) | · | 🔴 fork 4.44× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.471301 ± 0.00667286 (W 0.00573016) | 0.47918 ± 0.0156653 (W 0.0094549) | 0.145273 ± 0.000783129 (W 0.00161461) | · | 🔴 fork 3.24× slower | `!` between-start range over 5% |
| `qr/n96/b1` | 1.0271 ± 0.0156114 (W 0.0169998) | 1.00168 ± 0.0117835 (W 0.0150606) | 0.333003 ± 0.00426323 (W 0.00241249) | · | 🔴 fork 3.08× slower |  |
| `qr_factor/n32/b1` | 0.08521 ± 0.00278377 (W 0.00361002) | 0.091221 ± 0.001031 (W 0.00407436) | 0.014057 ± 0.000238957 (W 5.21536e-05) | 🔵 fork 1.07× faster | 🔴 fork 6.06× slower | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.439672 ± 0.0159116 (W 0.00943773) | 0.477894 ± 0.00507344 (W 0.0149746) | 0.298831 ± 0.133205 (W 0.00151347) | 🔵 fork 1.09× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.888692 ± 0.0158559 (W 0.0143681) | 0.945769 ± 0.00543924 (W 0.0102646) | 0.942339 ± 0.00109031 (W 0.00131056) | 🔵 fork 1.06× faster | 🔵 fork 1.06× faster |  |
| `solve/n32/b1` | 0.008516 ± 0.000170098 (W 0.000117388) | 0.008716 ± 9.50438e-05 (W 0.000120662) | 0.012784 ± 6.08276e-05 (W 4.72229e-05) | · | 🔵 fork 1.50× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.044985 ± 0.00086111 (W 0.0028879) | 0.047228 ± 0.00138528 (W 0.00103683) | 0.043641 ± 6.45523e-05 (W 0.000132821) | · | · | `!` between-start range over 5% |
| `solve/n96/b1` | 0.103856 ± 0.000300814 (W 0.00341589) | 0.102592 ± 0.0050957 (W 0.00301479) | 0.087414 ± 0.00331195 (W 0.000215012) | · | 🔴 fork 1.19× slower | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.185006 ± 0.0152488 (W 0.00151642) | 0.183993 ± 0.0158644 (W 0.00148604) | 0.185727 ± 0.000170412 (W 0.00116274) | · | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.950094 ± 0.00137505 (W 0.00144537) | 0.946298 ± 0.00327338 (W 0.00169833) | 0.668168 ± 0.00716424 (W 0.00149275) | · | 🔴 fork 1.42× slower |  |
| `svd_thin/n96/b1` | 2.31145 ± 0.0395919 (W 0.0195775) | 2.26932 ± 0.0295726 (W 0.0178825) | 1.48802 ± 0.0454577 (W 0.00651827) | · | 🔴 fork 1.55× slower | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140422 ± 0.000289628 (W 0.00102756) | 0.139833 ± 0.000353611 (W 0.000185898) | 0.0644 ± 0.0429777 (W 0.00115319) | · | 🔴 fork 2.18× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.519922 ± 0.00116416 (W 0.0013993) | 0.517577 ± 0.00114766 (W 0.00136648) | 0.270017 ± 0.00108292 (W 0.0015437) | · | 🔴 fork 1.93× slower |  |
| `svd_values/n96/b1` | 1.18508 ± 0.00139351 (W 0.00279152) | 1.18159 ± 0.00271523 (W 0.00158395) | 0.603277 ± 0.000915075 (W 0.00154571) | · | 🔴 fork 1.96× slower |  |
| `triangular_solve/n32/b1` | 0.000672 ± 6.35085e-06 (W 1.49097e-05) | 0.000671 ± 6.08276e-06 (W 9.28978e-06) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001503 ± 1.73205e-05 (W 2.68328e-05) | 0.001523 ± 3.60555e-05 (W 2.77489e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002625 ± 4.63717e-05 (W 3.08415e-05) | 0.002565 ± 2.64575e-05 (W 1.92666e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003497 ± 0.000197553 (W 2.63666e-05) | 0.003386 ± 1e-05 (W 2.50998e-05) | 0.004208 ± 6.245e-05 (W 2.56749e-05) | · | 🔵 fork 1.20× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.017082 ± 0.00122226 (W 3.93726e-05) | 0.016671 ± 0.00193916 (W 5.02991e-05) | 0.016831 ± 4.58258e-05 (W 6.27877e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.072165 ± 0.00199875 (W 0.002171) | 0.071605 ± 0.000324265 (W 0.00151284) | 0.048551 ± 0.000551871 (W 0.000122337) | · | 🔴 fork 1.49× slower | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113022 ± 8.34286e-05 (W 0.00150283) | 0.113101 ± 0.000315511 (W 0.0013413) | 0.10653 ± 0.000237748 (W 0.00110126) | · | 🔴 fork 1.06× slower |  |
| `eigh/n64/b1` | 0.506417 ± 0.00296022 (W 0.00455126) | 0.503645 ± 0.00226863 (W 0.00323549) | 0.263542 ± 0.000569656 (W 0.00148246) | · | 🔴 fork 1.92× slower |  |
| `eigh/n96/b1` | 1.24599 ± 0.0116158 (W 0.0192016) | 1.2418 ± 0.00753633 (W 0.0142941) | 0.576438 ± 0.00164548 (W 0.00116602) | · | 🔴 fork 2.16× slower |  |
| `full_piv_lu/n32/b1` | 0.010389 ± 0.000106068 (W 0.000162436) | 0.01086 ± 0.000298385 (W 3.42053e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046447 ± 0.000554354 (W 0.000323058) | 0.046698 ± 0.000101933 (W 0.000163175) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.134241 ± 0.00297114 (W 0.00137138) | 0.134071 ± 0.00318262 (W 0.00152485) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008376 ± 5.72742e-05 (W 0.000100156) | 0.008346 ± 6.07481e-05 (W 8.52309e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008556 ± 0.000150444 (W 0.000215365) | 0.008396 ± 0.000136137 (W 0.000102568) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.027562 ± 0.000858651 (W 0.0015393) | 0.027712 ± 0.000572452 (W 0.000816366) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.027742 ± 0.000423061 (W 0.00150344) | 0.028303 ± 0.00129374 (W 0.00133142) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.060793 ± 0.0014238 (W 0.00246799) | 0.06373 ± 0.00134002 (W 0.00197792) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.060603 ± 0.000943867 (W 0.00278528) | 0.063448 ± 0.00157823 (W 0.0017077) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007514 ± 9.33292e-05 (W 0.000138005) | 0.007434 ± 8.24035e-05 (W 0.000210048) | 0.012253 ± 7.93725e-05 (W 9.75705e-05) | · | 🔵 fork 1.63× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052479 ± 0.00140657 (W 0.00276881) | 0.0536 ± 0.00118105 (W 0.00271923) | 0.04293 ± 6.45781e-05 (W 0.00113879) | · | 🔴 fork 1.22× slower |  |
| `lu/n96/b1` | 0.118102 ± 0.00243117 (W 0.00321439) | 0.119374 ± 0.00407538 (W 0.00336702) | 0.085791 ± 0.00311485 (W 0.00122372) | · | 🔴 fork 1.38× slower | `!` between-start range over 5% |
| `qr/n32/b1` | 0.141695 ± 0.000669722 (W 0.00203697) | 0.143179 ± 0.0322784 (W 0.00411922) | 0.026249 ± 0.0336128 (W 8.86002e-05) | · | 🔴 fork 5.40× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.655926 ± 0.0155959 (W 0.0143931) | 0.65767 ± 0.0115739 (W 0.0166016) | 0.158125 ± 0.000318582 (W 0.00188142) | · | 🔴 fork 4.15× slower |  |
| `qr/n96/b1` | 1.3666 ± 0.0297285 (W 0.0229625) | 1.38708 ± 0.00419251 (W 0.0301859) | 0.33738 ± 0.00777545 (W 0.00378544) | · | 🔴 fork 4.05× slower |  |
| `qr_factor/n32/b1` | 0.116408 ± 0.00151847 (W 0.0043195) | 0.122549 ± 0.00156216 (W 0.00397227) | 0.014036 ± 7.63763e-05 (W 7.13814e-05) | 🔵 fork 1.05× faster | 🔴 fork 8.29× slower |  |
| `qr_factor/n64/b1` | 0.588841 ± 0.00450468 (W 0.0111619) | 0.631665 ± 0.00485872 (W 0.00970379) | 0.298438 ± 0.133945 (W 0.00173456) | 🔵 fork 1.07× faster | 🔴 fork 1.97× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 1.20217 ± 0.0170608 (W 0.0197298) | 1.27706 ± 0.00458175 (W 0.0141693) | 0.938681 ± 0.000962148 (W 0.000930911) | 🔵 fork 1.06× faster | 🔴 fork 1.28× slower |  |
| `solve/n32/b1` | 0.008526 ± 1.73205e-05 (W 0.000151015) | 0.008506 ± 0.000135769 (W 0.000143792) | 0.012794 ± 1.73205e-05 (W 3.72317e-05) | · | 🔵 fork 1.50× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053631 ± 0.0028892 (W 0.00352313) | 0.054041 ± 0.000317962 (W 0.00337386) | 0.043391 ± 6.60328e-05 (W 0.000119875) | · | 🔴 fork 1.24× slower | `!` between-start range over 5% |
| `solve/n96/b1` | 0.115295 ± 0.00512122 (W 0.00493383) | 0.114945 ± 0.00306862 (W 0.00488995) | 0.08546 ± 9.80833e-05 (W 0.000394686) | · | 🔴 fork 1.35× slower | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.184184 ± 0.0100506 (W 0.0014337) | 0.186438 ± 0.00909832 (W 0.00138114) | 0.187181 ± 0.0003196 (W 0.0012498) | · | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.966135 ± 0.00578253 (W 0.00205516) | 0.959123 ± 0.00697587 (W 0.00770838) | 0.660715 ± 0.00192585 (W 0.00407967) | · | 🔴 fork 1.46× slower |  |
| `svd_thin/n96/b1` | 2.39408 ± 0.0226868 (W 0.0292189) | 2.32008 ± 0.00436995 (W 0.0160177) | 1.35582 ± 0.0474159 (W 0.0019175) | · | 🔴 fork 1.77× slower | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140894 ± 0.000394574 (W 0.00113246) | 0.140343 ± 0.000275391 (W 0.00106655) | 0.064321 ± 0.0428183 (W 8.25833e-05) | · | 🔴 fork 2.19× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.519394 ± 0.00177119 (W 0.00217931) | 0.517601 ± 0.00189063 (W 0.00167155) | 0.269414 ± 0.00117723 (W 0.00160811) | · | 🔴 fork 1.93× slower |  |
| `svd_values/n96/b1` | 1.1831 ± 0.00113007 (W 0.00100592) | 1.18209 ± 0.00123297 (W 0.00205403) | 0.597176 ± 0.0017861 (W 0.00202931) | · | 🔴 fork 1.98× slower |  |
| `triangular_solve/n32/b1` | 0.000662 ± 5.19615e-06 (W 8.78635e-06) | 0.000671 ± 5.7735e-06 (W 1.14586e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001473 ± 2.3094e-05 (W 2.09332e-05) | 0.001493 ± 1.52753e-05 (W 1.66193e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002555 ± 5.7735e-06 (W 1.78885e-05) | 0.002585 ± 7e-05 (W 3.11448e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003136 ± 0.000157162 (W 3.9105e-05) | 0.003286 ± 1.48436e-05 (W 2.16171e-05) | 0.003376 ± 2.88675e-05 (W 2.15476e-05) | · | 🔵 fork 1.08× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014707 ± 0.00118588 (W 6.01681e-05) | 0.016391 ± 5.7735e-06 (W 1.92354e-05) | 0.014196 ± 3.5171e-05 (W 7.33485e-05) | 🔵 fork 1.11× faster | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030277 ± 0.00259602 (W 0.000100648) | 0.03218 ± 0.000145029 (W 5.41876e-05) | 0.038112 ± 0.000153461 (W 5.62245e-05) | · | 🔵 fork 1.26× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113012 ± 0.00054129 (W 0.00107313) | 0.113131 ± 0.000376816 (W 0.00133862) | 0.098825 ± 0.0001195 (W 0.000173304) | · | 🔴 fork 1.14× slower |  |
| `eigh/n64/b1` | 0.484927 ± 0.0016222 (W 0.00136315) | 0.484496 ± 0.000777465 (W 0.00167583) | 0.388727 ± 0.00133725 (W 0.00172251) | · | 🔴 fork 1.25× slower |  |
| `eigh/n96/b1` | 1.15725 ± 0.00192094 (W 0.00181026) | 1.15427 ± 0.00610823 (W 0.00177036) | 0.884353 ± 0.00821235 (W 0.00647497) | · | 🔴 fork 1.31× slower |  |
| `full_piv_lu/n32/b1` | 0.01053 ± 8.5049e-05 (W 0.00013755) | 0.01057 ± 0.000126295 (W 6.4135e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045876 ± 5.03322e-05 (W 0.00124084) | 0.046036 ± 0.000119626 (W 0.000103977) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132317 ± 0.00113329 (W 0.00237069) | 0.133049 ± 0.000634322 (W 0.0021625) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008235 ± 5.61278e-05 (W 4.8211e-05) | 0.008245 ± 4.89932e-05 (W 4.59053e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008335 ± 7.00024e-05 (W 2.84482e-05) | 0.008306 ± 6.55006e-05 (W 4.20619e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.039904 ± 2.00083e-05 (W 8.85618e-05) | 0.040066 ± 6.40859e-05 (W 8.07465e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040205 ± 0.000166626 (W 4.20975e-05) | 0.040336 ± 3.00056e-05 (W 9.39681e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.122108 ± 0.000560976 (W 9.72111e-05) | 0.12263 ± 0.000193357 (W 0.00019652) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.12304 ± 0.000298027 (W 0.000162315) | 0.122871 ± 0.00019597 (W 0.000110468) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007324 ± 1.52753e-05 (W 0.000120637) | 0.007364 ± 0.00015308 (W 0.000106926) | 0.009638 ± 0.000108167 (W 4.54445e-05) | · | 🔵 fork 1.32× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025828 ± 0.000296025 (W 0.000102078) | 0.025858 ± 0.000199525 (W 0.000244463) | 0.034003 ± 5.80259e-05 (W 0.000142798) | · | 🔵 fork 1.32× faster |  |
| `lu/n96/b1` | 0.06436 ± 0.000434363 (W 0.00228837) | 0.064071 ± 0.000659118 (W 0.00224872) | 0.07463 ± 0.00030055 (W 0.000136272) | · | 🔵 fork 1.16× faster |  |
| `qr/n32/b1` | 0.030938 ± 0.000425763 (W 0.000173142) | 0.03206 ± 0.000288023 (W 9.84896e-05) | 0.02157 ± 1.21244e-05 (W 7.52615e-05) | · | 🔴 fork 1.43× slower |  |
| `qr/n64/b1` | 0.113663 ± 0.000158219 (W 0.00128605) | 0.114734 ± 0.000263307 (W 0.00111239) | 0.116167 ± 0.000471644 (W 0.000231094) | · | · |  |
| `qr/n96/b1` | 0.285334 ± 0.000946303 (W 0.00336873) | 0.286656 ± 0.000591143 (W 0.00309065) | 0.342971 ± 0.00305436 (W 0.00184765) | · | 🔵 fork 1.20× faster |  |
| `qr_factor/n32/b1` | 0.017323 ± 0.00013308 (W 0.00013998) | 0.018374 ± 9.50438e-05 (W 0.00011068) | 0.011631 ± 5.02693e-05 (W 4.79812e-05) | 🔵 fork 1.06× faster | 🔴 fork 1.49× slower | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.073468 ± 0.000144212 (W 0.000238017) | 0.074359 ± 0.000343105 (W 0.00025237) | 0.289542 ± 0.000429469 (W 0.00153064) | · | 🔵 fork 3.94× faster |  |
| `qr_factor/n96/b1` | 0.162114 ± 0.000213378 (W 0.00127381) | 0.162976 ± 0.000636469 (W 0.00133641) | 0.929428 ± 0.000105453 (W 0.00107804) | · | 🔵 fork 5.73× faster |  |
| `solve/n32/b1` | 0.007865 ± 0.000136137 (W 0.000140464) | 0.008065 ± 0.000182045 (W 6.30872e-05) | 0.009869 ± 1.52753e-05 (W 5.06971e-05) | · | 🔵 fork 1.25× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025679 ± 0.000229064 (W 7.66159e-05) | 0.025668 ± 0.000627311 (W 0.000190855) | 0.033713 ± 0.000147309 (W 0.000188648) | · | 🔵 fork 1.31× faster |  |
| `solve/n96/b1` | 0.066495 ± 0.000768691 (W 0.0024553) | 0.066876 ± 0.000932392 (W 0.00227285) | 0.073908 ± 0.000170189 (W 6.46529e-05) | · | 🔵 fork 1.11× faster |  |
| `svd_thin/n32/b1` | 0.185699 ± 0.000375519 (W 0.00119693) | 0.185138 ± 0.00033102 (W 0.0014399) | 0.168225 ± 0.000278312 (W 0.00122388) | · | 🔴 fork 1.10× slower |  |
| `svd_thin/n64/b1` | 0.962429 ± 0.0110571 (W 0.00400298) | 0.960977 ± 0.00913971 (W 0.00207267) | 0.696493 ± 0.011026 (W 0.00195923) | · | 🔴 fork 1.38× slower |  |
| `svd_thin/n96/b1` | 2.14841 ± 0.00177759 (W 0.00195466) | 2.14582 ± 0.00266292 (W 0.00176381) | 1.62213 ± 0.00856445 (W 0.00889873) | · | 🔴 fork 1.32× slower |  |
| `svd_values/n32/b1` | 0.142879 ± 0.000537694 (W 0.00129453) | 0.142097 ± 0.000575709 (W 0.000132485) | 0.059362 ± 1.70392e-05 (W 7.67483e-05) | · | 🔴 fork 2.41× slower |  |
| `svd_values/n64/b1` | 0.539319 ± 0.00359826 (W 0.00145292) | 0.538036 ± 0.00253271 (W 0.00180183) | 0.255218 ± 0.000331005 (W 0.00113286) | · | 🔴 fork 2.11× slower |  |
| `svd_values/n96/b1` | 1.18969 ± 0.00171394 (W 0.0013469) | 1.18784 ± 0.0013105 (W 0.000820813) | 0.608288 ± 0.0013131 (W 0.00129072) | · | 🔴 fork 1.96× slower |  |
| `triangular_solve/n32/b1` | 0.000742 ± 1.76163e-05 (W 8.20366e-06) | 0.000742 ± 5.7735e-07 (W 1.32023e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001813 ± 0.000167989 (W 2.05499e-05) | 0.001723 ± 0.000194569 (W 2.43557e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003086 ± 2.60832e-05 (W 3.09726e-05) | 0.003075 ± 2.5697e-05 (W 2.41309e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003075 ± 0.000179556 (W 1.87136e-05) | 0.003306 ± 1.73205e-05 (W 2.09332e-05) | 0.003326 ± 2.04206e-05 (W 1.49064e-05) | 🔵 fork 1.08× faster | 🔵 fork 1.08× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014788 ± 0.00116866 (W 4.28871e-05) | 0.016401 ± 9.20887e-05 (W 2.94958e-05) | 0.014066 ± 0.000162112 (W 8.05003e-05) | 🔵 fork 1.11× faster | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.062878 ± 0.00457495 (W 0.00556168) | 0.059602 ± 0.00282068 (W 0.00410862) | 0.038161 ± 0.000101489 (W 0.000139747) | · | 🔴 fork 1.65× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n32/b1` | 0.113423 ± 0.000101425 (W 0.000156394) | 0.112861 ± 0.000265757 (W 0.00116594) | 0.104125 ± 0.000428284 (W 0.000836197) | · | 🔴 fork 1.09× slower |  |
| `eigh/n64/b1` | 0.500757 ± 0.00167638 (W 0.00406967) | 0.501318 ± 0.00121815 (W 0.00305274) | 0.267641 ± 0.00136703 (W 0.00172502) | · | 🔴 fork 1.87× slower |  |
| `eigh/n96/b1` | 1.20781 ± 0.00629195 (W 0.0109748) | 1.20421 ± 0.00239284 (W 0.0150326) | 0.580821 ± 0.0018609 (W 0.0020037) | · | 🔴 fork 2.08× slower |  |
| `full_piv_lu/n32/b1` | 0.01034 ± 0.000144431 (W 0.000121161) | 0.01065 ± 0.000377414 (W 7.4962e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045816 ± 0.00048324 (W 0.000373542) | 0.046066 ± 0.000500181 (W 0.000101746) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.131686 ± 0.000588111 (W 0.00164034) | 0.132147 ± 0.000762436 (W 0.00239699) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008406 ± 2.0502e-05 (W 7.8867e-05) | 0.008366 ± 3.49333e-05 (W 6.77067e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008445 ± 5.56507e-05 (W 6.53452e-05) | 0.008596 ± 6.65833e-05 (W 0.000108121) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.023594 ± 0.00011415 (W 0.000761974) | 0.023694 ± 0.00036722 (W 0.000900121) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.024276 ± 0.000716148 (W 0.00104945) | 0.023774 ± 0.000117772 (W 0.000727687) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049051 ± 0.000740154 (W 0.00193782) | 0.050885 ± 0.00185773 (W 0.00181042) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.051025 ± 0.000476727 (W 0.00125499) | 0.050675 ± 0.000453359 (W 0.00211684) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007223 ± 3.84318e-05 (W 9.76217e-05) | 0.007254 ± 0.000132855 (W 0.000151563) | 0.009618 ± 5.19615e-05 (W 8.03443e-05) | · | 🔵 fork 1.33× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.043261 ± 0.00263036 (W 0.00276924) | 0.045134 ± 0.00204031 (W 0.00316738) | 0.033473 ± 0.000144015 (W 8.32466e-05) | · | 🔴 fork 1.29× slower | `!` between-start range over 5% |
| `lu/n96/b1` | 0.096931 ± 0.00537341 (W 0.00551787) | 0.101309 ± 0.00317374 (W 0.00273263) | 0.074499 ± 0.000154794 (W 0.00116425) | · | 🔴 fork 1.30× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n32/b1` | 0.119804 ± 0.00712279 (W 0.00531469) | 0.109645 ± 0.00529228 (W 0.0119431) | 0.02099 ± 0.000112829 (W 4.63702e-05) | 🔴 fork 1.09× slower | 🔴 fork 5.71× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.470152 ± 0.0105996 (W 0.00974532) | 0.476194 ± 0.00796869 (W 0.00661015) | 0.126288 ± 0.000514477 (W 0.00059114) | · | 🔴 fork 3.72× slower |  |
| `qr/n96/b1` | 0.992122 ± 0.0196472 (W 0.0213463) | 1.00042 ± 0.0122269 (W 0.0119284) | 0.295913 ± 0.00306461 (W 0.0019024) | · | 🔴 fork 3.35× slower |  |
| `qr_factor/n32/b1` | 0.079057 ± 0.000295958 (W 0.00377224) | 0.081113 ± 0.00188889 (W 0.00577449) | 0.011491 ± 0.000155907 (W 5.69236e-05) | · | 🔴 fork 6.88× slower |  |
| `qr_factor/n64/b1` | 0.415667 ± 0.0110674 (W 0.0100843) | 0.396883 ± 0.0128593 (W 0.00919377) | 0.289912 ± 0.000508996 (W 0.00172392) | · | 🔴 fork 1.43× slower | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.817899 ± 0.0207275 (W 0.012514) | 0.827097 ± 0.02372 (W 0.00901284) | 0.930898 ± 0.00151256 (W 0.000761955) | · | 🔵 fork 1.14× faster | `!` between-start range over 5% |
| `solve/n32/b1` | 0.007955 ± 0.000302292 (W 0.000130822) | 0.007905 ± 0.000195021 (W 0.000101746) | 0.009878 ± 3.52184e-05 (W 7.02873e-05) | · | 🔵 fork 1.24× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.045135 ± 0.000285365 (W 0.00233649) | 0.044885 ± 0.00153065 (W 0.0033576) | 0.033713 ± 0.000150688 (W 5.8432e-05) | · | 🔴 fork 1.34× slower | `!` between-start range over 5% |
| `solve/n96/b1` | 0.101661 ± 0.00201957 (W 0.00393074) | 0.102141 ± 0.0020951 (W 0.00306963) | 0.073478 ± 0.000145029 (W 0.000157055) | · | 🔴 fork 1.38× slower |  |
| `svd_thin/n32/b1` | 0.186639 ± 0.0156723 (W 0.00241435) | 0.186018 ± 0.0154686 (W 0.00121002) | 0.176209 ± 0.000442887 (W 0.00110377) | · | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.993567 ± 0.00217639 (W 0.00235452) | 0.992605 ± 0.00451002 (W 0.00189228) | 0.639306 ± 0.00668985 (W 0.00158345) | · | 🔴 fork 1.55× slower |  |
| `svd_thin/n96/b1` | 2.31521 ± 0.0233364 (W 0.0137933) | 2.26892 ± 0.0453377 (W 0.0170569) | 1.37198 ± 0.000718972 (W 0.00363157) | · | 🔴 fork 1.69× slower |  |
| `svd_values/n32/b1` | 0.142176 ± 0.000313975 (W 0.00122954) | 0.141826 ± 0.000187378 (W 0.000160397) | 0.059231 ± 6.20833e-05 (W 0.000963973) | · | 🔴 fork 2.40× slower |  |
| `svd_values/n64/b1` | 0.538436 ± 0.0021575 (W 0.001723) | 0.537926 ± 0.00175444 (W 0.00182706) | 0.259224 ± 0.000414959 (W 0.00140262) | · | 🔴 fork 2.08× slower |  |
| `svd_values/n96/b1` | 1.19207 ± 0.00327761 (W 0.00187742) | 1.18681 ± 0.00181734 (W 0.00184401) | 0.60209 ± 0.00132034 (W 0.00200862) | · | 🔴 fork 1.98× slower |  |
| `triangular_solve/n32/b1` | 0.000761 ± 5.19615e-06 (W 1.62265e-05) | 0.000771 ± 1.70392e-05 (W 1.75585e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001704 ± 9.78621e-05 (W 1.84986e-05) | 0.001803 ± 1.52753e-05 (W 1.22597e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003396 ± 0.000207172 (W 4.05253e-05) | 0.003086 ± 1.52753e-05 (W 2.77489e-05) | - | 🔴 fork 1.10× slower | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003387 ± 0.000170969 (W 4.43847e-05) | 0.003306 ± 1.1547e-05 (W 2.71717e-05) | 0.003386 ± 8.5967e-05 (W 2.54401e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016722 ± 0.00277693 (W 4.05487e-05) | 0.016281 ± 0.00189746 (W 5.99525e-05) | 0.013956 ± 0.000131149 (W 3.70446e-05) | · | 🔴 fork 1.20× slower | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.070963 ± 0.000780878 (W 0.00154281) | 0.069249 ± 0.00256951 (W 0.00253241) | 0.038011 ± 6.4291e-05 (W 0.000167199) | · | 🔴 fork 1.87× slower | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113202 ± 0.000285868 (W 0.00112687) | 0.113232 ± 0.000426186 (W 0.00115874) | 0.104877 ± 0.000371601 (W 0.00134977) | · | 🔴 fork 1.08× slower |  |
| `eigh/n64/b1` | 0.509162 ± 0.00685416 (W 0.00478637) | 0.503451 ± 0.00298711 (W 0.00470643) | 0.25697 ± 0.00103751 (W 0.00132685) | · | 🔴 fork 1.98× slower |  |
| `eigh/n96/b1` | 1.24961 ± 0.00592267 (W 0.0186705) | 1.2328 ± 0.00382739 (W 0.0132842) | 0.563524 ± 0.00107424 (W 0.00187361) | · | 🔴 fork 2.22× slower |  |
| `full_piv_lu/n32/b1` | 0.010319 ± 8.55589e-05 (W 5.44977e-05) | 0.01053 ± 8.14453e-05 (W 2.58844e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045765 ± 8.16721e-05 (W 0.000110622) | 0.045906 ± 0.000656923 (W 0.000616332) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.127659 ± 0.00280012 (W 0.00151061) | 0.129022 ± 0.00237259 (W 0.00143304) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008416 ± 3.51188e-05 (W 6.80441e-05) | 0.008506 ± 6.55769e-05 (W 8.9041e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008566 ± 6.02771e-05 (W 6.2779e-05) | 0.008586 ± 6.4291e-05 (W 9.24148e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.027191 ± 0.000341307 (W 0.000918844) | 0.02713 ± 0.000286987 (W 0.00128041) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.027311 ± 0.000377361 (W 0.00132261) | 0.027782 ± 0.000924448 (W 0.00095869) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.060643 ± 0.00154975 (W 0.00217574) | 0.061736 ± 0.000637277 (W 0.0021582) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.061585 ± 0.000399325 (W 0.00217156) | 0.06379 ± 0.00363804 (W 0.00413858) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n32/b1` | 0.007174 ± 5.1316e-05 (W 0.000104466) | 0.007283 ± 6.37207e-05 (W 0.000148369) | 0.009668 ± 4.3589e-05 (W 9.2358e-05) | · | 🔵 fork 1.35× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0482 ± 0.00223066 (W 0.00346363) | 0.051316 ± 0.00023253 (W 0.00248662) | 0.033493 ± 8.66025e-05 (W 8.45577e-05) | 🔵 fork 1.06× faster | 🔴 fork 1.44× slower | `!` between-start range over 5% |
| `lu/n96/b1` | 0.110727 ± 0.00168793 (W 0.00276591) | 0.111909 ± 0.00251063 (W 0.00288832) | 0.074479 ± 0.000345332 (W 0.000185834) | · | 🔴 fork 1.49× slower |  |
| `qr/n32/b1` | 0.141425 ± 0.00116149 (W 0.0023698) | 0.144852 ± 0.00152234 (W 0.00319672) | 0.02108 ± 0.000162112 (W 8.27647e-05) | · | 🔴 fork 6.71× slower |  |
| `qr/n64/b1` | 0.653953 ± 0.033865 (W 0.0174204) | 0.646129 ± 0.025304 (W 0.019537) | 0.139511 ± 0.00029023 (W 0.00169395) | · | 🔴 fork 4.69× slower | `!` between-start range over 5% |
| `qr/n96/b1` | 1.39426 ± 0.0239071 (W 0.0298235) | 1.40645 ± 0.0345922 (W 0.0350369) | 0.303538 ± 0.00143487 (W 0.00232769) | · | 🔴 fork 4.59× slower |  |
| `qr_factor/n32/b1` | 0.110858 ± 0.0045199 (W 0.00702958) | 0.113523 ± 0.00396058 (W 0.0030253) | 0.011471 ± 4.3589e-05 (W 6.68154e-05) | · | 🔴 fork 9.66× slower | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.577751 ± 0.00444767 (W 0.00906852) | 0.580555 ± 0.00830065 (W 0.0122836) | 0.289401 ± 0.000492041 (W 0.00107033) | · | 🔴 fork 2.00× slower |  |
| `qr_factor/n96/b1` | 1.13245 ± 0.0123396 (W 0.0130867) | 1.13838 ± 0.019868 (W 0.0115701) | 0.929734 ± 0.00157084 (W 0.000422401) | · | 🔴 fork 1.22× slower |  |
| `solve/n32/b1` | 0.007895 ± 0.000131341 (W 3.76205e-05) | 0.007835 ± 4.16333e-05 (W 5.63915e-05) | 0.009808 ± 3.10966e-05 (W 4.44331e-05) | · | 🔵 fork 1.24× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.051988 ± 0.00223 (W 0.00317845) | 0.052469 ± 0.000649344 (W 0.00299131) | 0.033333 ± 0.000150921 (W 7.8775e-05) | · | 🔴 fork 1.56× slower | `!` between-start range over 5% |
| `solve/n96/b1` | 0.118231 ± 0.005483 (W 0.0087657) | 0.113302 ± 0.00639734 (W 0.00601763) | 0.073528 ± 8.97051e-05 (W 0.000165983) | · | 🔴 fork 1.61× slower | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.186499 ± 0.0103432 (W 0.00158264) | 0.186399 ± 0.0100538 (W 0.00144436) | 0.177612 ± 0.000322633 (W 0.00107112) | · | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.00732 ± 0.0120111 (W 0.00535119) | 1.00331 ± 0.00646575 (W 0.00314016) | 0.629461 ± 0.00240914 (W 0.00239897) | · | 🔴 fork 1.60× slower |  |
| `svd_thin/n96/b1` | 2.37834 ± 0.017296 (W 0.0279495) | 2.30902 ± 0.0142221 (W 0.017832) | 1.32334 ± 0.00248367 (W 0.00344396) | · | 🔴 fork 1.80× slower |  |
| `svd_values/n32/b1` | 0.143078 ± 0.000136297 (W 0.00099128) | 0.142026 ± 0.0001005 (W 0.00118588) | 0.059251 ± 3.84318e-05 (W 8.7574e-05) | · | 🔴 fork 2.41× slower |  |
| `svd_values/n64/b1` | 0.540784 ± 0.000732727 (W 0.00267519) | 0.536046 ± 0.00149522 (W 0.00185099) | 0.257614 ± 0.000655711 (W 0.00165428) | · | 🔴 fork 2.10× slower |  |
| `svd_values/n96/b1` | 1.18983 ± 0.00170079 (W 0.00124341) | 1.18531 ± 0.000883713 (W 0.00145199) | 0.596109 ± 0.00081444 (W 0.00176714) | · | 🔴 fork 2.00× slower |  |
| `triangular_solve/n32/b1` | 0.000761 ± 6.08276e-06 (W 1.74728e-05) | 0.000752 ± 1e-05 (W 1.48762e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001704 ± 6.89952e-05 (W 1.2054e-05) | 0.001703 ± 4.93288e-05 (W 1.27789e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003106 ± 2.08167e-05 (W 2.28035e-05) | 0.003075 ± 0.000123964 (W 3.48755e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 4.72582e-05 (W 2.35627e-05) | 0.00521 ± 3.60555e-05 (W 3.78153e-05) | 0.008977 ± 0.000135795 (W 8.41427e-05) | · | 🔵 fork 1.71× faster | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030447 ± 0.000106522 (W 8.35464e-05) | 0.030236 ± 0.000152451 (W 5.54283e-05) | 0.051276 ± 0.000160416 (W 0.000201743) | · | 🔵 fork 1.68× faster |  |
| `cholesky/n96/b1` | 0.084498 ± 0.000269092 (W 0.000133294) | 0.084187 ± 0.0030674 (W 0.000246601) | 0.138749 ± 0.000307053 (W 0.000171509) | · | 🔵 fork 1.64× faster | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.141556 ± 0.000387256 (W 0.00100727) | 0.142406 ± 0.000204287 (W 0.00117715) | 0.150512 ± 0.000203062 (W 0.000202217) | · | 🔵 fork 1.06× faster |  |
| `eigh/n64/b1` | 0.646164 ± 0.000736342 (W 0.00163387) | 0.648873 ± 0.00124969 (W 0.0015898) | 0.812409 ± 0.00205345 (W 0.00242899) | · | 🔵 fork 1.26× faster |  |
| `eigh/n96/b1` | 1.61177 ± 0.00398907 (W 0.00225673) | 1.6185 ± 0.00227023 (W 0.00260224) | 2.03241 ± 0.00264473 (W 0.00605012) | · | 🔵 fork 1.26× faster |  |
| `full_piv_lu/n32/b1` | 0.0158 ± 5.02693e-05 (W 0.000147812) | 0.01575 ± 0.000332311 (W 7.12741e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.092253 ± 0.000358196 (W 0.00109241) | 0.092313 ± 0.000382671 (W 0.00147256) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.26733 ± 0.000850947 (W 0.00131542) | 0.267373 ± 0.000221682 (W 0.00113531) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028093 ± 0.000144362 (W 5.99942e-05) | 0.028112 ± 2.00083e-05 (W 7.19875e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028113 ± 6.08276e-06 (W 8.43226e-05) | 0.028253 ± 6.50641e-05 (W 0.000105878) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.158807 ± 5.47449e-05 (W 0.00015336) | 0.158697 ± 0.000233964 (W 0.00137126) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159608 ± 0.000489326 (W 0.00164719) | 0.159811 ± 0.000297359 (W 0.00120658) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.465951 ± 0.00118721 (W 0.000532008) | 0.468456 ± 9.63483e-05 (W 0.00161868) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.470038 ± 0.0012152 (W 0.00168886) | 0.470434 ± 0.0022073 (W 0.00210364) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011541 ± 7.88057e-05 (W 0.000149978) | 0.011642 ± 0.000122748 (W 0.000145366) | 0.019917 ± 3.21455e-05 (W 0.00111013) | · | 🔵 fork 1.73× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.053039 ± 2.36714e-05 (W 0.00064629) | 0.0534 ± 0.000612743 (W 0.00048036) | 0.096742 ± 5.02693e-05 (W 0.00124108) | · | 🔵 fork 1.82× faster |  |
| `lu/n96/b1` | 0.139292 ± 0.000120006 (W 0.000858444) | 0.139772 ± 0.000636276 (W 0.00156967) | 0.258103 ± 0.000703236 (W 0.00140863) | · | 🔵 fork 1.85× faster |  |
| `qr/n32/b1` | 0.067827 ± 0.000497078 (W 0.000374392) | 0.068609 ± 0.00053442 (W 0.000309571) | 0.05368 ± 0.0896944 (W 0.00112193) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.314067 ± 0.00110375 (W 0.0024279) | 0.315052 ± 0.000881865 (W 0.00150845) | 0.339668 ± 0.000414685 (W 0.00159787) | · | 🔵 fork 1.08× faster |  |
| `qr/n96/b1` | 0.76989 ± 0.00034343 (W 0.00220703) | 0.77168 ± 0.00105882 (W 0.0016245) | 0.998446 ± 0.000401718 (W 0.0010665) | · | 🔵 fork 1.30× faster |  |
| `qr_factor/n32/b1` | 0.040155 ± 0.000131683 (W 0.000179478) | 0.046126 ± 7.05006e-05 (W 0.00012207) | 0.028834 ± 0.0001249 (W 5.59464e-05) | 🔵 fork 1.15× faster | 🔴 fork 1.39× slower |  |
| `qr_factor/n64/b1` | 0.210203 ± 0.000680088 (W 0.00179071) | 0.238628 ± 0.00129879 (W 0.00128801) | 0.166613 ± 0.000356341 (W 0.00135763) | 🔵 fork 1.14× faster | 🔴 fork 1.26× slower |  |
| `qr_factor/n96/b1` | 0.468566 ± 0.00151769 (W 0.00141926) | 0.536714 ± 0.00045955 (W 0.00172137) | 0.513791 ± 0.000799826 (W 0.00181495) | 🔵 fork 1.15× faster | 🔵 fork 1.10× faster |  |
| `solve/n32/b1` | 0.012804 ± 0.000141067 (W 0.000134856) | 0.012574 ± 0.000170392 (W 6.56529e-05) | 0.020408 ± 0.00012897 (W 4.20143e-05) | · | 🔵 fork 1.59× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055284 ± 0.000229566 (W 0.00120684) | 0.054983 ± 0.000146936 (W 0.000293337) | 0.094586 ± 0.0001945 (W 0.000295399) | · | 🔵 fork 1.71× faster |  |
| `solve/n96/b1` | 0.141815 ± 0.00114752 (W 0.00158887) | 0.142337 ± 0.000845165 (W 0.00145149) | 0.252993 ± 0.000436911 (W 0.00161134) | · | 🔵 fork 1.78× faster |  |
| `svd_thin/n32/b1` | 0.234819 ± 0.00102605 (W 0.00138107) | 0.234861 ± 0.00142692 (W 0.00164364) | 0.252284 ± 0.000215752 (W 0.00128535) | · | 🔵 fork 1.07× faster |  |
| `svd_thin/n64/b1` | 1.22446 ± 0.0035336 (W 0.00220365) | 1.22466 ± 0.00183985 (W 0.00147686) | 1.34123 ± 0.000852937 (W 0.00339626) | · | 🔵 fork 1.10× faster |  |
| `svd_thin/n96/b1` | 3.1342 ± 0.0074927 (W 0.00178208) | 3.13957 ± 0.00726032 (W 0.0042269) | 3.4818 ± 0.0586095 (W 0.00278535) | · | 🔵 fork 1.11× faster |  |
| `svd_values/n32/b1` | 0.161292 ± 0.00125791 (W 0.0010422) | 0.161494 ± 0.00100979 (W 0.00147835) | 0.102122 ± 0.122075 (W 0.000983809) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.649966 ± 0.000445216 (W 0.00159592) | 0.649881 ± 0.00049128 (W 0.00164676) | 0.490006 ± 0.000149082 (W 0.0021378) | · | 🔴 fork 1.33× slower |  |
| `svd_values/n96/b1` | 1.5078 ± 0.00318504 (W 0.00187688) | 1.50873 ± 0.000950517 (W 0.00179688) | 1.37244 ± 0.00221914 (W 0.00266087) | · | 🔴 fork 1.10× slower |  |
| `triangular_solve/n32/b1` | 0.001052 ± 1.1547e-05 (W 2.07364e-05) | 0.001051 ± 1.00167e-05 (W 1.22556e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002685 ± 1.52753e-05 (W 3.937e-05) | 0.002705 ± 3.05505e-05 (W 2.04939e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005009 ± 5.32948e-05 (W 5.67477e-05) | 0.005019 ± 4.07063e-05 (W 5.34911e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00529 ± 2.64575e-05 (W 4.39318e-05) | 0.005209 ± 3.17857e-05 (W 3.57771e-05) | 0.008947 ± 7.0713e-05 (W 4.71169e-05) | · | 🔵 fork 1.69× faster | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030507 ± 0.000172705 (W 5.38628e-05) | 0.030306 ± 4.64794e-05 (W 6.5202e-05) | 0.051526 ± 9.59184e-05 (W 0.000234862) | · | 🔵 fork 1.69× faster |  |
| `cholesky/n96/b1` | 0.102883 ± 0.00106724 (W 0.00243302) | 0.102943 ± 0.00152465 (W 0.00249484) | 0.137728 ± 0.00151129 (W 0.00165029) | · | 🔵 fork 1.34× faster |  |
| `eigh/n32/b1` | 0.141635 ± 0.000143807 (W 0.00140823) | 0.141867 ± 0.00040387 (W 0.00173138) | 0.155661 ± 0.000387792 (W 0.00161709) | · | 🔵 fork 1.10× faster |  |
| `eigh/n64/b1` | 0.634405 ± 0.0158731 (W 0.00302292) | 0.635878 ± 0.000871952 (W 0.00204325) | 0.568126 ± 0.0014961 (W 0.00185162) | · | 🔴 fork 1.12× slower |  |
| `eigh/n96/b1` | 1.5389 ± 0.00840625 (W 0.0148282) | 1.53844 ± 0.0116815 (W 0.0097512) | 1.15762 ± 0.0015792 (W 0.00206396) | · | 🔴 fork 1.33× slower |  |
| `full_piv_lu/n32/b1` | 0.01596 ± 2.51661e-05 (W 0.000111095) | 0.01584 ± 6.05007e-05 (W 0.0001355) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.092323 ± 0.000437818 (W 0.00123852) | 0.092132 ± 0.000384661 (W 0.00132562) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.266781 ± 0.000749923 (W 0.00137448) | 0.266067 ± 0.00020568 (W 0.00158978) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028503 ± 5e-05 (W 6.89797e-05) | 0.028573 ± 6.245e-05 (W 0.00010114) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028533 ± 8.77515e-05 (W 7.05422e-05) | 0.028734 ± 0.0001823 (W 9.38083e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.066644 ± 0.000323538 (W 0.0017879) | 0.068217 ± 0.00104307 (W 0.00728889) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.066915 ± 0.000730727 (W 0.00413152) | 0.067456 ± 0.00226991 (W 0.00152569) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.153868 ± 0.000519065 (W 0.00109288) | 0.154298 ± 0.000670647 (W 0.00107185) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.156061 ± 0.000737659 (W 0.0013576) | 0.155902 ± 0.000914229 (W 0.00163246) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011492 ± 3.17857e-05 (W 7.17447e-05) | 0.011471 ± 0.000111879 (W 7.71382e-05) | 0.019888 ± 5.18684e-05 (W 6.69873e-05) | · | 🔵 fork 1.73× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.053189 ± 0.000125048 (W 0.00119786) | 0.05322 ± 0.0011578 (W 0.00102529) | 0.095689 ± 9.29157e-05 (W 0.000358985) | · | 🔵 fork 1.80× faster |  |
| `lu/n96/b1` | 0.153287 ± 0.00161867 (W 0.00146429) | 0.153847 ± 0.000949334 (W 0.00136576) | 0.243785 ± 0.000619086 (W 0.00121594) | · | 🔵 fork 1.59× faster |  |
| `qr/n32/b1` | 0.14893 ± 0.00760217 (W 0.0133502) | 0.145452 ± 0.0270193 (W 0.0135328) | 0.053741 ± 0.0893732 (W 0.00130201) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.635102 ± 0.00649803 (W 0.0130327) | 0.643363 ± 0.0107556 (W 0.0119105) | 0.302836 ± 0.00197541 (W 0.00121855) | · | 🔴 fork 2.10× slower |  |
| `qr/n96/b1` | 1.33025 ± 0.0450835 (W 0.0135979) | 1.36181 ± 0.0566204 (W 0.0268146) | 0.768923 ± 0.0019925 (W 0.00181193) | · | 🔴 fork 1.73× slower | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.103643 ± 0.00313003 (W 0.00355919) | 0.110396 ± 0.000654149 (W 0.00371421) | 0.028734 ± 9.29157e-05 (W 4.65639e-05) | 🔵 fork 1.07× faster | 🔴 fork 3.61× slower | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.56713 ± 0.00997399 (W 0.0126721) | 0.598173 ± 0.00978615 (W 0.0152532) | 0.763297 ± 0.346285 (W 0.00138597) | 🔵 fork 1.05× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 1.05997 ± 0.00173763 (W 0.0168778) | 1.13497 ± 0.00512596 (W 0.0174094) | 2.45625 ± 0.00330228 (W 0.00099207) | 🔵 fork 1.07× faster | 🔵 fork 2.32× faster |  |
| `solve/n32/b1` | 0.012944 ± 7.97517e-05 (W 0.000156734) | 0.012844 ± 0.00016773 (W 0.000117069) | 0.020268 ± 8.14453e-05 (W 6.30079e-05) | · | 🔵 fork 1.57× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.054873 ± 0.000179918 (W 0.0013669) | 0.055053 ± 9.29157e-05 (W 0.000131058) | 0.093395 ± 0.000437722 (W 0.00104861) | · | 🔵 fork 1.70× faster |  |
| `solve/n96/b1` | 0.157776 ± 0.000745157 (W 0.00205643) | 0.156332 ± 0.00185663 (W 0.00215328) | 0.236652 ± 0.000451665 (W 0.00156321) | · | 🔵 fork 1.50× faster |  |
| `svd_thin/n32/b1` | 0.235171 ± 0.00299372 (W 0.00405138) | 0.234659 ± 0.00152709 (W 0.00371023) | 0.26108 ± 0.000922013 (W 0.00104993) | · | 🔵 fork 1.11× faster |  |
| `svd_thin/n64/b1` | 1.19509 ± 0.00348808 (W 0.00170763) | 1.19795 ± 0.00401533 (W 0.00218462) | 1.03195 ± 0.000610936 (W 0.00146256) | · | 🔴 fork 1.16× slower |  |
| `svd_thin/n96/b1` | 2.95665 ± 0.00609019 (W 0.0290455) | 2.95955 ± 0.00696849 (W 0.0343975) | 2.52407 ± 0.00137295 (W 0.00261267) | · | 🔴 fork 1.17× slower |  |
| `svd_values/n32/b1` | 0.161582 ± 0.000448924 (W 0.000169373) | 0.161322 ± 0.000558634 (W 0.00128868) | 0.102292 ± 0.121899 (W 0.00114921) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.649634 ± 0.000343241 (W 0.00160455) | 0.649685 ± 0.00139999 (W 0.00196207) | 0.490547 ± 0.00050566 (W 0.00146784) | · | 🔴 fork 1.32× slower |  |
| `svd_values/n96/b1` | 1.50588 ± 0.00443071 (W 0.00211996) | 1.50675 ± 0.00295466 (W 0.00155818) | 1.35928 ± 0.0020506 (W 0.00142346) | · | 🔴 fork 1.11× slower |  |
| `triangular_solve/n32/b1` | 0.001052 ± 1.73205e-05 (W 1.34164e-05) | 0.001082 ± 1.73205e-05 (W 1.67332e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002675 ± 1.52753e-05 (W 1.8363e-05) | 0.002685 ± 2.64575e-05 (W 2.53614e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004939 ± 0.000113271 (W 3.68551e-05) | 0.004919 ± 1.52753e-05 (W 4.09902e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00533 ± 2.51661e-05 (W 3.36155e-05) | 0.00527 ± 2.08167e-05 (W 5.11879e-05) | 0.008917 ± 0.000104644 (W 4.81165e-05) | · | 🔵 fork 1.67× faster | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030447 ± 0.000192718 (W 0.0013202) | 0.030146 ± 0.000415216 (W 0.000149607) | 0.051627 ± 0.000255513 (W 0.000237601) | · | 🔵 fork 1.70× faster |  |
| `cholesky/n96/b1` | 0.111909 ± 0.000280001 (W 0.00328598) | 0.110346 ± 0.00178606 (W 0.00234882) | 0.140753 ± 0.000491655 (W 0.000437964) | · | 🔵 fork 1.26× faster |  |
| `eigh/n32/b1` | 0.141405 ± 0.000602286 (W 0.00150849) | 0.142396 ± 0.000412868 (W 0.00149871) | 0.156584 ± 0.000297189 (W 0.00153047) | · | 🔵 fork 1.11× faster |  |
| `eigh/n64/b1` | 0.645757 ± 0.00364001 (W 0.00644622) | 0.658681 ± 0.00478443 (W 0.00939107) | 0.538377 ± 0.00291173 (W 0.00213988) | · | 🔴 fork 1.20× slower |  |
| `eigh/n96/b1` | 1.58162 ± 0.00752877 (W 0.0157652) | 1.59779 ± 0.00917096 (W 0.011227) | 1.03664 ± 0.00388555 (W 0.00108147) | · | 🔴 fork 1.53× slower |  |
| `full_piv_lu/n32/b1` | 0.01597 ± 8.5049e-05 (W 0.000131066) | 0.01587 ± 0.000196817 (W 0.000128869) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.091952 ± 7.63763e-05 (W 0.00160678) | 0.091772 ± 9.06661e-05 (W 0.000340308) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.266219 ± 0.000197662 (W 0.0014238) | 0.266268 ± 8.80965e-05 (W 0.00161951) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028474 ± 0.000137264 (W 0.000139317) | 0.028513 ± 0.000108214 (W 8.26438e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028494 ± 1.70392e-05 (W 8.52719e-05) | 0.028533 ± 0.000119304 (W 0.00012018) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.072656 ± 0.00105939 (W 0.00280676) | 0.072366 ± 0.000910935 (W 0.00293542) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.071233 ± 0.00106408 (W 0.00181127) | 0.072075 ± 0.00261515 (W 0.0015301) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.161451 ± 0.000807101 (W 0.00182688) | 0.160821 ± 0.00114883 (W 0.00134663) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.160921 ± 0.000675648 (W 0.00180922) | 0.159899 ± 0.000981542 (W 0.000763617) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011481 ± 0.000108307 (W 9.32218e-05) | 0.011691 ± 0.000108583 (W 0.000158279) | 0.019947 ± 4.3589e-05 (W 7.88302e-05) | · | 🔵 fork 1.74× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052919 ± 0.000100167 (W 0.000182724) | 0.053109 ± 0.000352313 (W 0.000758293) | 0.096099 ± 0.000374541 (W 0.000873172) | · | 🔵 fork 1.82× faster |  |
| `lu/n96/b1` | 0.167142 ± 0.000211472 (W 0.00305084) | 0.165821 ± 0.00370278 (W 0.00289775) | 0.243637 ± 0.000772768 (W 0.00140392) | · | 🔵 fork 1.46× faster |  |
| `qr/n32/b1` | 0.18738 ± 0.00370573 (W 0.0059834) | 0.185998 ± 0.000977396 (W 0.00806957) | 0.053461 ± 0.089746 (W 0.00010322) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.850751 ± 0.0105161 (W 0.0165213) | 0.8795 ± 0.0104332 (W 0.0221593) | 0.283843 ± 0.000414346 (W 0.00155029) | · | 🔴 fork 3.00× slower |  |
| `qr/n96/b1` | 1.77314 ± 0.070315 (W 0.0304378) | 1.78966 ± 0.084316 (W 0.0237874) | 0.701322 ± 0.00183564 (W 0.00178691) | · | 🔴 fork 2.53× slower | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.131075 ± 0.00131726 (W 0.00370527) | 0.13934 ± 0.00169951 (W 0.00227692) | 0.028744 ± 0.000122233 (W 0.000115236) | 🔵 fork 1.06× faster | 🔴 fork 4.56× slower |  |
| `qr_factor/n64/b1` | 0.716078 ± 0.00855859 (W 0.0215344) | 0.768882 ± 0.00645908 (W 0.0207896) | 0.761769 ± 0.345001 (W 0.00132279) | 🔵 fork 1.07× faster | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 1.40221 ± 0.012686 (W 0.0302253) | 1.49311 ± 0.0209559 (W 0.0388284) | 2.45087 ± 0.00286979 (W 0.00234804) | 🔵 fork 1.06× faster | 🔵 fork 1.75× faster |  |
| `solve/n32/b1` | 0.012774 ± 0.000210072 (W 0.000115928) | 0.012804 ± 0.000141774 (W 0.000107935) | 0.020278 ± 9.29157e-05 (W 7.97264e-05) | · | 🔵 fork 1.59× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055344 ± 5.55908e-05 (W 0.000708747) | 0.055123 ± 0.000352313 (W 0.000546695) | 0.092914 ± 0.000341781 (W 0.000364289) | · | 🔵 fork 1.68× faster |  |
| `solve/n96/b1` | 0.168364 ± 0.00399047 (W 0.00354931) | 0.169649 ± 0.00107628 (W 0.00218368) | 0.236523 ± 0.000184527 (W 0.00179396) | · | 🔵 fork 1.40× faster |  |
| `svd_thin/n32/b1` | 0.234728 ± 0.000492305 (W 0.00319458) | 0.23493 ± 0.00190492 (W 0.00314153) | 0.262463 ± 0.000232769 (W 0.00152801) | · | 🔵 fork 1.12× faster |  |
| `svd_thin/n64/b1` | 1.21746 ± 0.0149737 (W 0.00838728) | 1.22279 ± 0.00647933 (W 0.00811632) | 0.990733 ± 0.00164176 (W 0.00184289) | · | 🔴 fork 1.23× slower |  |
| `svd_thin/n96/b1` | 3.06604 ± 0.00538617 (W 0.0178755) | 3.06474 ± 0.0250062 (W 0.0106404) | 2.34101 ± 0.00316999 (W 0.00231635) | · | 🔴 fork 1.31× slower |  |
| `svd_values/n32/b1` | 0.161203 ± 0.000149503 (W 0.00138361) | 0.161592 ± 0.000265419 (W 0.00121823) | 0.102833 ± 0.121839 (W 0.00138931) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.65011 ± 0.00223119 (W 0.00184536) | 0.650467 ± 0.00179409 (W 0.00151486) | 0.490517 ± 0.00239454 (W 0.00154385) | · | 🔴 fork 1.33× slower |  |
| `svd_values/n96/b1` | 1.50646 ± 0.00641681 (W 0.00172175) | 1.5031 ± 0.00670353 (W 0.00204821) | 1.35564 ± 0.00545142 (W 0.00196616) | · | 🔴 fork 1.11× slower |  |
| `triangular_solve/n32/b1` | 0.001062 ± 2.51661e-05 (W 1.64317e-05) | 0.001072 ± 1e-05 (W 4.65833e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002675 ± 2.64575e-05 (W 1.81659e-05) | 0.002665 ± 1.1547e-05 (W 3.49285e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00491 ± 3.04467e-05 (W 4.41384e-05) | 0.00485 ± 4.30155e-05 (W 2.29826e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 0.000153385 (W 0.000122834) | 0.00519 ± 9.50438e-06 (W 1.15412e-05) | 0.008015 ± 0.000113578 (W 5.6403e-05) | · | 🔵 fork 1.53× faster | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030046 ± 0.000117189 (W 7.72218e-05) | 0.029926 ± 8.12835e-05 (W 8.6487e-05) | 0.044263 ± 0.000456016 (W 0.0012399) | · | 🔵 fork 1.47× faster |  |
| `cholesky/n96/b1` | 0.083396 ± 0.000338851 (W 0.00110095) | 0.083256 ± 0.00315492 (W 0.00131011) | 0.124814 ± 0.000461556 (W 0.00128846) | · | 🔵 fork 1.50× faster | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.141895 ± 0.000345008 (W 0.00129555) | 0.142376 ± 0.000391195 (W 0.00137543) | 0.148509 ± 0.000280579 (W 0.0012683) | · | · |  |
| `eigh/n64/b1` | 0.64733 ± 0.000508561 (W 0.00139765) | 0.64956 ± 0.000220926 (W 0.00185477) | 0.800907 ± 0.00132719 (W 0.00265559) | · | 🔵 fork 1.24× faster |  |
| `eigh/n96/b1` | 1.61498 ± 0.00256688 (W 0.00557937) | 1.61567 ± 0.00227463 (W 0.00234714) | 2.00681 ± 0.00267816 (W 0.00242853) | · | 🔵 fork 1.24× faster |  |
| `full_piv_lu/n32/b1` | 0.015869 ± 2.0664e-05 (W 8.57514e-05) | 0.015759 ± 5.25389e-05 (W 0.000108343) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090109 ± 9.29157e-05 (W 0.000265574) | 0.090178 ± 0.000435759 (W 0.000386982) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.265426 ± 0.000738995 (W 0.00159906) | 0.264585 ± 0.000560259 (W 0.00168088) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027892 ± 4.96689e-05 (W 5.82606e-05) | 0.027932 ± 1.58219e-05 (W 4e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027953 ± 6.22923e-05 (W 0.00130692) | 0.028093 ± 6.76782e-05 (W 6.28427e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157176 ± 0.000168171 (W 0.000112842) | 0.157366 ± 9.11482e-05 (W 0.00153179) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158127 ± 5.90028e-05 (W 0.00158947) | 0.157865 ± 9.63397e-05 (W 0.00156297) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.459854 ± 0.00299613 (W 0.00165209) | 0.461467 ± 0.00198375 (W 0.00038982) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.465271 ± 0.000814753 (W 0.00146272) | 0.461623 ± 0.00242405 (W 0.00131431) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011662 ± 0.000132288 (W 8.29458e-05) | 0.011632 ± 0.000195533 (W 0.00012518) | 0.017462 ± 7.57188e-05 (W 6.90377e-05) | · | 🔵 fork 1.50× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051367 ± 0.000265419 (W 0.000214006) | 0.051757 ± 0.000914021 (W 0.000185651) | 0.086021 ± 0.000127571 (W 0.000226233) | · | 🔵 fork 1.67× faster |  |
| `lu/n96/b1` | 0.137057 ± 0.000497172 (W 0.00130702) | 0.137647 ± 0.000741134 (W 0.00170681) | 0.225133 ± 0.000429151 (W 0.00147558) | · | 🔵 fork 1.64× faster |  |
| `qr/n32/b1` | 0.067928 ± 0.000447528 (W 0.000274423) | 0.068559 ± 0.000503001 (W 0.00113208) | 0.048381 ± 4.7648e-05 (W 0.000129604) | · | 🔴 fork 1.40× slower |  |
| `qr/n64/b1` | 0.312575 ± 0.000249658 (W 0.00149121) | 0.313349 ± 0.000811338 (W 0.00194644) | 0.323505 ± 0.00269947 (W 0.00186013) | · | · |  |
| `qr/n96/b1` | 0.762666 ± 0.0018215 (W 0.00192948) | 0.76634 ± 0.00152166 (W 0.00169936) | 0.932112 ± 0.000856584 (W 0.00118309) | · | 🔵 fork 1.22× faster |  |
| `qr_factor/n32/b1` | 0.033473 ± 6.1403e-05 (W 0.000264944) | 0.034244 ± 3.05505e-05 (W 0.00022682) | 0.026129 ± 0.000130767 (W 4.67568e-05) | · | 🔴 fork 1.28× slower |  |
| `qr_factor/n64/b1` | 0.162145 ± 0.000599968 (W 0.00114124) | 0.163856 ± 0.000388832 (W 0.00138548) | 0.75599 ± 0.00119211 (W 0.0013973) | · | 🔵 fork 4.66× faster |  |
| `qr_factor/n96/b1` | 0.391852 ± 0.00100934 (W 0.00197712) | 0.39387 ± 0.00195682 (W 0.0017158) | 2.44044 ± 0.00120943 (W 0.00278507) | · | 🔵 fork 6.23× faster |  |
| `solve/n32/b1` | 0.012713 ± 7.17658e-05 (W 8.00956e-05) | 0.012634 ± 5.53203e-05 (W 3.61012e-05) | 0.017393 ± 0.000107751 (W 6.60553e-05) | · | 🔵 fork 1.37× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053571 ± 0.00037834 (W 0.000152815) | 0.053299 ± 0.000173754 (W 0.000173664) | 0.083436 ± 0.00023084 (W 0.00139495) | · | 🔵 fork 1.56× faster |  |
| `solve/n96/b1` | 0.140452 ± 0.000599503 (W 0.00150567) | 0.140814 ± 0.000593095 (W 0.00149367) | 0.219502 ± 0.000362021 (W 0.00165871) | · | 🔵 fork 1.56× faster |  |
| `svd_thin/n32/b1` | 0.232166 ± 0.000475147 (W 0.00142848) | 0.231696 ± 0.00112679 (W 0.00157762) | 0.249146 ± 0.000463041 (W 0.00150672) | · | 🔵 fork 1.07× faster |  |
| `svd_thin/n64/b1` | 1.25805 ± 0.00336344 (W 0.00299108) | 1.25791 ± 0.00243798 (W 0.00145446) | 1.31518 ± 0.00383071 (W 0.00138216) | · | · |  |
| `svd_thin/n96/b1` | 3.09012 ± 0.00672315 (W 0.00195487) | 3.09468 ± 0.00951357 (W 0.00240674) | 3.41625 ± 0.00513968 (W 0.0042622) | · | 🔵 fork 1.11× faster |  |
| `svd_values/n32/b1` | 0.159027 ± 0.0010373 (W 0.00117947) | 0.158909 ± 0.00106013 (W 0.000215073) | 0.100357 ± 0.000129114 (W 9.55055e-05) | · | 🔴 fork 1.58× slower |  |
| `svd_values/n64/b1` | 0.625866 ± 0.00107968 (W 0.00160298) | 0.626973 ± 0.00133737 (W 0.00126706) | 0.479066 ± 0.00049485 (W 0.00154736) | · | 🔴 fork 1.31× slower |  |
| `svd_values/n96/b1` | 1.48368 ± 0.00331094 (W 0.00241257) | 1.48016 ± 0.0016302 (W 0.00186613) | 1.34005 ± 0.00342325 (W 0.00141262) | · | 🔴 fork 1.11× slower |  |
| `triangular_solve/n32/b1` | 0.001182 ± 4.3589e-05 (W 1.34164e-05) | 0.001182 ± 2.94449e-05 (W 1.17558e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002815 ± 0.000104978 (W 1.18406e-05) | 0.002895 ± 2.62742e-05 (W 1.7841e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004949 ± 0.000410727 (W 2.04939e-05) | 0.004959 ± 0.000411291 (W 2.09332e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00534 ± 2.94449e-05 (W 8.64772e-05) | 0.005259 ± 5.62168e-05 (W 3.68809e-05) | 0.008095 ± 0.000142116 (W 4.06202e-05) | · | 🔵 fork 1.52× faster | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030057 ± 0.000170608 (W 4.08656e-05) | 0.029936 ± 0.000155597 (W 2.9433e-05) | 0.04321 ± 0.000366364 (W 0.000111244) | · | 🔵 fork 1.44× faster |  |
| `cholesky/n96/b1` | 0.101951 ± 0.000482288 (W 0.00128135) | 0.102292 ± 0.00140927 (W 0.00142899) | 0.125735 ± 0.000795775 (W 0.00148696) | · | 🔵 fork 1.23× faster |  |
| `eigh/n32/b1` | 0.141676 ± 0.000125861 (W 0.00153834) | 0.141827 ± 0.000174015 (W 0.00114968) | 0.15415 ± 0.000355023 (W 0.00104553) | · | 🔵 fork 1.09× faster |  |
| `eigh/n64/b1` | 0.634987 ± 0.000837325 (W 0.0022689) | 0.636861 ± 0.00523128 (W 0.0014002) | 0.554386 ± 0.001055 (W 0.00136587) | · | 🔴 fork 1.15× slower |  |
| `eigh/n96/b1` | 1.5315 ± 0.01022 (W 0.00990439) | 1.54882 ± 0.0128213 (W 0.0165698) | 1.14096 ± 0.00221827 (W 0.00148174) | · | 🔴 fork 1.34× slower |  |
| `full_piv_lu/n32/b1` | 0.01589 ± 5.74195e-05 (W 0.00011006) | 0.015849 ± 7.59408e-05 (W 9.4177e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089727 ± 0.000678451 (W 0.000333024) | 0.089928 ± 0.000125301 (W 0.000314832) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264024 ± 0.000583876 (W 0.00135243) | 0.263502 ± 0.000572343 (W 0.00139824) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028183 ± 0.000115326 (W 0.000101833) | 0.028213 ± 0.000103184 (W 7.86333e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028233 ± 5.56776e-05 (W 0.000111469) | 0.028273 ± 0.000249227 (W 0.000137477) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.065483 ± 0.000741525 (W 0.00165894) | 0.065933 ± 0.00143449 (W 0.00341537) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.066615 ± 0.00153568 (W 0.00188948) | 0.066575 ± 0.000901533 (W 0.001309) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.152776 ± 0.000960405 (W 0.00178055) | 0.153368 ± 0.000378946 (W 0.00166436) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.153437 ± 0.000757722 (W 0.00162859) | 0.152716 ± 0.000709145 (W 0.00192739) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011722 ± 0.00020306 (W 0.000169912) | 0.011592 ± 0.00012741 (W 9.72384e-05) | 0.017413 ± 2.08167e-05 (W 6.91173e-05) | · | 🔵 fork 1.49× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051567 ± 7.81025e-05 (W 0.000222127) | 0.051747 ± 0.000813364 (W 0.000800254) | 0.08569 ± 0.0001495 (W 0.000249588) | · | 🔵 fork 1.66× faster |  |
| `lu/n96/b1` | 0.151002 ± 0.000453683 (W 0.00182573) | 0.151353 ± 0.000953369 (W 0.00207486) | 0.22422 ± 0.000368742 (W 0.00171807) | · | 🔵 fork 1.48× faster |  |
| `qr/n32/b1` | 0.152666 ± 0.0123471 (W 0.0143086) | 0.156253 ± 0.0162015 (W 0.00820117) | 0.04821 ± 0.000102144 (W 9.8001e-05) | · | 🔴 fork 3.17× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.633324 ± 0.00992365 (W 0.0151295) | 0.640929 ± 0.00203729 (W 0.00918898) | 0.28804 ± 0.000773246 (W 0.00159912) | · | 🔴 fork 2.20× slower |  |
| `qr/n96/b1` | 1.34458 ± 0.0540645 (W 0.0138838) | 1.35151 ± 0.0509678 (W 0.0160483) | 0.733446 ± 0.00204329 (W 0.00159488) | · | 🔴 fork 1.83× slower | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.094908 ± 0.0014416 (W 0.00390063) | 0.098294 ± 0.00348151 (W 0.00350535) | 0.02612 ± 5.55908e-05 (W 5.32466e-05) | · | 🔴 fork 3.63× slower | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.494227 ± 0.00660251 (W 0.0115713) | 0.499243 ± 0.00130585 (W 0.0111773) | 0.755718 ± 0.000612811 (W 0.00137027) | · | 🔵 fork 1.53× faster |  |
| `qr_factor/n96/b1` | 0.982063 ± 0.0122416 (W 0.00944765) | 0.986802 ± 0.0134812 (W 0.0137729) | 2.43996 ± 0.00207551 (W 0.00258891) | · | 🔵 fork 2.48× faster |  |
| `solve/n32/b1` | 0.012804 ± 6.02771e-05 (W 9.49737e-05) | 0.012684 ± 8.96289e-05 (W 7.04216e-05) | 0.017252 ± 5.54106e-05 (W 4.1833e-05) | · | 🔵 fork 1.35× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.05324 ± 2.62742e-05 (W 0.000163781) | 0.05352 ± 0.000248797 (W 0.000969941) | 0.083036 ± 0.000162225 (W 0.00128002) | · | 🔵 fork 1.56× faster |  |
| `solve/n96/b1` | 0.154861 ± 0.000751816 (W 0.00173408) | 0.155982 ± 0.000240069 (W 0.00166654) | 0.218679 ± 0.000567109 (W 0.00155612) | · | 🔵 fork 1.41× faster |  |
| `svd_thin/n32/b1` | 0.231765 ± 0.00129351 (W 0.00150145) | 0.232105 ± 0.00304445 (W 0.0019748) | 0.257313 ± 0.000566827 (W 0.00125729) | · | 🔵 fork 1.11× faster |  |
| `svd_thin/n64/b1` | 1.22605 ± 0.00250675 (W 0.00207989) | 1.22442 ± 0.00244397 (W 0.00334523) | 1.0085 ± 0.000632097 (W 0.000997987) | · | 🔴 fork 1.22× slower |  |
| `svd_thin/n96/b1` | 2.92422 ± 0.0174145 (W 0.0171814) | 2.91947 ± 0.0125176 (W 0.024138) | 2.50743 ± 0.00468356 (W 0.00355768) | · | 🔴 fork 1.17× slower |  |
| `svd_values/n32/b1` | 0.159418 ± 0.000676042 (W 0.0012425) | 0.159378 ± 0.000668404 (W 0.00125291) | 0.100939 ± 0.000292182 (W 0.00138537) | · | 🔴 fork 1.58× slower |  |
| `svd_values/n64/b1` | 0.625745 ± 0.00111809 (W 0.00194843) | 0.625669 ± 0.000845052 (W 0.00147772) | 0.47961 ± 0.000547543 (W 0.00139406) | · | 🔴 fork 1.30× slower |  |
| `svd_values/n96/b1` | 1.4764 ± 0.0016185 (W 0.00202163) | 1.4783 ± 0.00105037 (W 0.00205161) | 1.34079 ± 0.000944861 (W 0.00126493) | · | 🔴 fork 1.10× slower |  |
| `triangular_solve/n32/b1` | 0.001202 ± 2.04206e-05 (W 3.31693e-05) | 0.001202 ± 2.08167e-05 (W 2.12179e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002826 ± 2.5632e-05 (W 1.66223e-05) | 0.002795 ± 1.52753e-05 (W 1.14978e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00513 ± 0.000241475 (W 2.32852e-05) | 0.00513 ± 0.00011415 (W 2.19157e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00553 ± 0.000125301 (W 0.000104629) | 0.00521 ± 9.34897e-05 (W 2.88097e-05) | 0.008015 ± 4.16333e-05 (W 6.29778e-05) | 🔴 fork 1.06× slower | 🔵 fork 1.45× faster | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030207 ± 9.25761e-05 (W 9.86671e-05) | 0.029966 ± 0.000393998 (W 7.22925e-05) | 0.044393 ± 0.000509507 (W 0.000121161) | · | 🔵 fork 1.47× faster |  |
| `cholesky/n96/b1` | 0.110968 ± 0.000692062 (W 0.00268364) | 0.110187 ± 0.00184802 (W 0.00334469) | 0.125375 ± 0.000649597 (W 0.000231229) | · | 🔵 fork 1.13× faster |  |
| `eigh/n32/b1` | 0.141424 ± 0.000485086 (W 0.00136906) | 0.142276 ± 0.000195021 (W 0.00133989) | 0.154949 ± 0.000253457 (W 0.00144098) | · | 🔵 fork 1.10× faster |  |
| `eigh/n64/b1` | 0.641239 ± 0.00346751 (W 0.00327999) | 0.647269 ± 0.00198084 (W 0.00548255) | 0.527326 ± 0.00262123 (W 0.00254093) | · | 🔴 fork 1.22× slower |  |
| `eigh/n96/b1` | 1.59247 ± 0.0139443 (W 0.0109712) | 1.59444 ± 0.00150796 (W 0.0135897) | 1.02197 ± 0.00133697 (W 0.00107212) | · | 🔴 fork 1.56× slower |  |
| `full_piv_lu/n32/b1` | 0.01594 ± 8.63153e-05 (W 0.000149766) | 0.01592 ± 0.000117898 (W 0.000106232) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.089949 ± 0.000185689 (W 0.000338896) | 0.089979 ± 0.000378318 (W 0.000449437) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.263583 ± 0.000136756 (W 0.00142715) | 0.263875 ± 0.000636869 (W 0.00136464) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028122 ± 0.000106522 (W 8.78482e-05) | 0.028163 ± 0.000125301 (W 9.46958e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028203 ± 0.000166764 (W 0.000223951) | 0.028243 ± 1.0504e-05 (W 0.00012498) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.071443 ± 0.000137477 (W 0.00227805) | 0.071614 ± 0.000458432 (W 0.00215199) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.072505 ± 0.000283878 (W 0.000895897) | 0.073267 ± 0.00155941 (W 0.00227017) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.16028 ± 0.00112807 (W 0.00142737) | 0.161171 ± 0.000843239 (W 0.00109103) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.16043 ± 0.000231273 (W 0.00184375) | 0.160771 ± 0.000724797 (W 0.00207567) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011792 ± 0.000118462 (W 0.00011327) | 0.011852 ± 0.000188283 (W 0.000105751) | 0.017313 ± 9.33292e-05 (W 8.30199e-05) | · | 🔵 fork 1.47× faster | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051366 ± 3e-05 (W 0.00072224) | 0.051567 ± 0.000905391 (W 0.000364562) | 0.085491 ± 0.0001355 (W 0.00132138) | · | 🔵 fork 1.66× faster |  |
| `lu/n96/b1` | 0.163827 ± 0.000742104 (W 0.00364837) | 0.162173 ± 0.00111225 (W 0.00278652) | 0.2245 ± 0.000785042 (W 0.00135994) | · | 🔵 fork 1.37× faster |  |
| `qr/n32/b1` | 0.183533 ± 0.000851682 (W 0.00438569) | 0.188392 ± 0.000284342 (W 0.00662202) | 0.0482 ± 5.03322e-05 (W 9.16515e-05) | · | 🔴 fork 3.81× slower |  |
| `qr/n64/b1` | 0.836179 ± 0.0135184 (W 0.034037) | 0.855349 ± 0.0141466 (W 0.0198778) | 0.263824 ± 0.000496737 (W 0.00129684) | · | 🔴 fork 3.17× slower |  |
| `qr/n96/b1` | 1.74095 ± 0.0420757 (W 0.03257) | 1.76207 ± 0.0561169 (W 0.0431013) | 0.669015 ± 0.000270158 (W 0.00154151) | · | 🔴 fork 2.60× slower | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.125345 ± 0.0023162 (W 0.00290854) | 0.126626 ± 0.00358521 (W 0.00275698) | 0.026119 ± 4.2595e-05 (W 6.84105e-05) | · | 🔴 fork 4.80× slower | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.662139 ± 0.00442301 (W 0.0178439) | 0.666054 ± 0.00755406 (W 0.00516159) | 0.755583 ± 0.000454408 (W 0.00128578) | · | 🔵 fork 1.14× faster |  |
| `qr_factor/n96/b1` | 1.29537 ± 0.0192683 (W 0.0189563) | 1.3184 ± 0.0168219 (W 0.0143503) | 2.43787 ± 0.00134707 (W 0.00213366) | · | 🔵 fork 1.88× faster |  |
| `solve/n32/b1` | 0.012644 ± 3.05505e-05 (W 7.51212e-05) | 0.012604 ± 0.000125898 (W 6.05169e-05) | 0.017223 ± 2.85832e-05 (W 6.99593e-05) | · | 🔵 fork 1.36× faster | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053189 ± 3.66106e-05 (W 0.000700084) | 0.05335 ± 0.000176213 (W 0.000163943) | 0.082996 ± 0.00017091 (W 0.00128216) | · | 🔵 fork 1.56× faster |  |
| `solve/n96/b1` | 0.166341 ± 0.00127566 (W 0.00390507) | 0.16599 ± 0.000471453 (W 0.00306679) | 0.21848 ± 0.000336572 (W 0.00121623) | · | 🔵 fork 1.31× faster |  |
| `svd_thin/n32/b1` | 0.232394 ± 0.00098184 (W 0.00159223) | 0.232685 ± 0.00093269 (W 0.00165336) | 0.258223 ± 0.000341879 (W 0.00114786) | · | 🔵 fork 1.11× faster |  |
| `svd_thin/n64/b1` | 1.2551 ± 0.0137286 (W 0.0126357) | 1.25169 ± 0.00775251 (W 0.00990261) | 0.968206 ± 0.000279565 (W 0.00110425) | · | 🔴 fork 1.30× slower |  |
| `svd_thin/n96/b1` | 3.04344 ± 0.010281 (W 0.0183786) | 3.02545 ± 0.00546852 (W 0.014725) | 2.32452 ± 0.00321855 (W 0.00457063) | · | 🔴 fork 1.31× slower |  |
| `svd_values/n32/b1` | 0.15957 ± 0.00070398 (W 0.00273658) | 0.159358 ± 0.000399696 (W 0.00135422) | 0.100568 ± 0.00042601 (W 0.00131834) | · | 🔴 fork 1.59× slower |  |
| `svd_values/n64/b1` | 0.625233 ± 0.00277454 (W 0.00186308) | 0.626071 ± 0.00152514 (W 0.00184034) | 0.479837 ± 0.00143842 (W 0.00160798) | · | 🔴 fork 1.30× slower |  |
| `svd_values/n96/b1` | 1.47659 ± 0.00228849 (W 0.00231931) | 1.47826 ± 0.00529723 (W 0.0021314) | 1.33824 ± 0.00216712 (W 0.00128228) | · | 🔴 fork 1.10× slower |  |
| `triangular_solve/n32/b1` | 0.001192 ± 1.51767e-05 (W 1.52709e-05) | 0.001182 ± 3.4641e-05 (W 2.95686e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002995 ± 0.000156142 (W 2.85009e-05) | 0.002786 ± 0.000118462 (W 1.24619e-05) | - | 🔴 fork 1.08× slower | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004739 ± 6.69104e-05 (W 3.04959e-05) | 0.004739 ± 3.21455e-05 (W 2.34521e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.066905 ± 0.00247128 (W 0.000688631) | 0.070181 ± 0.000407031 (W 0.00108224) | 0.114784 ± 0.00158119 (W 0.00138119) | · | 🔵 fork 1.72× faster | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.38547 ± 0.00211145 (W 0.00211287) | 0.394107 ± 0.00197296 (W 0.0026174) | 0.641368 ± 0.00201755 (W 0.0028296) | · | 🔵 fork 1.66× faster |  |
| `cholesky/n512/b1` | 2.52008 ± 0.0470748 (W 0.00415518) | 2.5206 ± 0.0422485 (W 0.00766867) | 4.02665 ± 0.00513641 (W 0.00744307) | · | 🔵 fork 1.60× faster |  |
| `eigh/n128/b1` | 2.24921 ± 0.00623357 (W 0.00297992) | 2.25527 ± 0.00622212 (W 0.00484978) | 1.8603 ± 0.00800335 (W 0.0101221) | · | 🔴 fork 1.21× slower |  |
| `eigh/n256/b1` | 9.80511 ± 0.0449549 (W 0.00431109) | 9.77726 ± 0.0377035 (W 0.00580082) | 10.0307 ± 0.00956972 (W 0.0182635) | · | · |  |
| `eigh/n512/b1` | 48.8325 ± 0.293176 (W 0.0769042) | 48.8452 ± 0.200908 (W 0.0339963) | 61.3721 ± 0.23298 (W 0.0573945) | · | 🔵 fork 1.26× faster |  |
| `full_piv_lu/n128/b1` | 0.310531 ± 0.00114112 (W 0.00363084) | 0.312754 ± 0.00208251 (W 0.00251773) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.75483 ± 0.0124971 (W 0.00542911) | 2.76975 ± 0.0159957 (W 0.00721614) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 22.7761 ± 0.247037 (W 0.0420009) | 22.8545 ± 0.35305 (W 0.0445649) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.258162 ± 0.000632748 (W 0.00159072) | 0.257882 ± 0.000438452 (W 0.00183153) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.259345 ± 0.000313422 (W 0.00154166) | 0.259517 ± 0.000575112 (W 0.00139757) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90287 ± 0.0220639 (W 0.00326913) | 1.90651 ± 0.0167377 (W 0.00426242) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94671 ± 0.0354223 (W 0.00185255) | 1.94533 ± 0.0296301 (W 0.00274778) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8259 ± 0.0404288 (W 0.0161855) | 15.7957 ± 0.0259745 (W 0.0239097) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.8432 ± 0.0324462 (W 0.0137548) | 15.8312 ± 0.0270766 (W 0.0173963) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.135183 ± 0.00118567 (W 0.00111593) | 0.137056 ± 0.0160526 (W 0.0022418) | 0.170228 ± 0.0191285 (W 0.00139051) | · | 🔵 fork 1.26× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.03358 ± 0.119206 (W 0.00391442) | 1.03289 ± 0.000791256 (W 0.0029613) | 0.971682 ± 0.130652 (W 0.00297348) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 7.13608 ± 0.0666634 (W 0.0318463) | 7.14776 ± 0.022116 (W 0.0134463) | 6.97499 ± 0.0480385 (W 0.00880881) | · | · |  |
| `qr/n128/b1` | 0.511195 ± 0.000790215 (W 0.0017517) | 0.513863 ± 0.00236765 (W 0.00181338) | 0.749295 ± 0.0046381 (W 0.00222454) | · | 🔵 fork 1.47× faster |  |
| `qr/n256/b1` | 2.91775 ± 0.00411367 (W 0.00205265) | 2.92604 ± 0.00675647 (W 0.00255686) | 4.32077 ± 0.013179 (W 0.0124887) | · | 🔵 fork 1.48× faster |  |
| `qr/n512/b1` | 20.6886 ± 0.0699723 (W 0.0349638) | 20.9766 ± 0.121555 (W 0.0396754) | 30.6078 ± 0.107365 (W 0.0393021) | · | 🔵 fork 1.48× faster |  |
| `qr_factor/n128/b1` | 0.420506 ± 0.00185394 (W 0.00258374) | 0.530655 ± 0.00197752 (W 0.00239646) | 0.370545 ± 0.00202175 (W 0.00270015) | 🔵 fork 1.26× faster | 🔴 fork 1.13× slower |  |
| `qr_factor/n256/b1` | 2.43807 ± 0.00310647 (W 0.00734923) | 2.86981 ± 0.00467476 (W 0.00385713) | 2.04098 ± 0.00742928 (W 0.00816684) | 🔵 fork 1.18× faster | 🔴 fork 1.19× slower |  |
| `qr_factor/n512/b1` | 15.7947 ± 0.056323 (W 0.0259739) | 17.5134 ± 0.048288 (W 0.0188157) | 14.2007 ± 0.07238 (W 0.0187395) | 🔵 fork 1.11× faster | 🔴 fork 1.11× slower |  |
| `solve/n128/b1` | 0.136837 ± 0.0015808 (W 0.0019547) | 0.136595 ± 0.000326927 (W 0.00193396) | 0.169958 ± 0.000240624 (W 0.000962405) | · | 🔵 fork 1.24× faster |  |
| `solve/n256/b1` | 0.804974 ± 0.0039254 (W 0.00271161) | 0.807328 ± 0.00266763 (W 0.00350208) | 0.973215 ± 5.69766e-05 (W 0.00130352) | · | 🔵 fork 1.21× faster |  |
| `solve/n512/b1` | 7.07212 ± 0.0114802 (W 0.0103708) | 7.08422 ± 0.0603766 (W 0.0228318) | 5.96598 ± 0.0218826 (W 0.00499051) | · | 🔴 fork 1.19× slower |  |
| `svd_thin/n128/b1` | 3.69276 ± 0.0074478 (W 0.00247961) | 3.69832 ± 0.0132618 (W 0.00374957) | 3.39244 ± 0.00426966 (W 0.0148462) | · | 🔴 fork 1.09× slower |  |
| `svd_thin/n256/b1` | 18.4866 ± 0.0449403 (W 0.0250896) | 18.4639 ± 0.0479228 (W 0.0196179) | 18.0953 ± 0.0603111 (W 0.0265905) | · | · |  |
| `svd_thin/n512/b1` | 106.369 ± 0.244816 (W 0.0920506) | 106.16 ± 0.297255 (W 0.391507) | 115.983 ± 0.475706 (W 0.17274) | · | 🔵 fork 1.09× faster |  |
| `svd_values/n128/b1` | 2.69301 ± 0.00904381 (W 0.00315648) | 2.68566 ± 0.00863394 (W 0.00457718) | 1.19668 ± 0.00105014 (W 0.00256951) | · | 🔴 fork 2.25× slower |  |
| `svd_values/n256/b1` | 12.4531 ± 0.0202359 (W 0.0274135) | 12.4277 ± 0.032623 (W 0.0156659) | 6.96857 ± 0.0171572 (W 0.0108049) | · | 🔴 fork 1.79× slower |  |
| `svd_values/n512/b1` | 66.3018 ± 0.410036 (W 0.0619534) | 66.1317 ± 0.44116 (W 0.383577) | 47.6937 ± 0.464988 (W 0.0402974) | · | 🔴 fork 1.39× slower |  |
| `triangular_solve/n128/b1` | 0.003888 ± 0.000236025 (W 2.88652e-05) | 0.004038 ± 0.000238132 (W 5.04609e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012233 ± 0.000170392 (W 9.60208e-05) | 0.012483 ± 0.000146401 (W 0.000124183) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.039093 ± 0.0022249 (W 0.000247256) | 0.039775 ± 0.00237555 (W 0.000197072) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.099727 ± 0.00960315 (W 0.0081231) | 0.10696 ± 0.00180091 (W 0.00564879) | 0.115466 ± 0.000889945 (W 0.00137485) | · | 🔵 fork 1.16× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.404385 ± 0.0077742 (W 0.0169666) | 0.421828 ± 0.0174379 (W 0.0204863) | 0.408725 ± 0.00111609 (W 0.00368958) | · | · | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.68897 ± 0.0241695 (W 0.0441053) | 1.6649 ± 0.0105843 (W 0.0217989) | 1.94661 ± 0.0218547 (W 0.0157659) | · | 🔵 fork 1.15× faster |  |
| `eigh/n128/b1` | 2.28197 ± 0.024004 (W 0.0210667) | 2.28274 ± 0.0309796 (W 0.010581) | 1.07081 ± 0.00172798 (W 0.00313011) | · | 🔴 fork 2.13× slower |  |
| `eigh/n256/b1` | 7.00874 ± 0.0264771 (W 0.0295132) | 6.97275 ± 0.0208766 (W 0.0310863) | 4.77742 ± 0.0167426 (W 0.0104066) | · | 🔴 fork 1.47× slower |  |
| `eigh/n512/b1` | 26.3719 ± 0.176175 (W 0.0383599) | 26.2864 ± 0.1923 (W 0.0614616) | 21.6349 ± 0.0879578 (W 0.0494293) | · | 🔴 fork 1.22× slower |  |
| `full_piv_lu/n128/b1` | 0.313458 ± 0.00169456 (W 0.00171327) | 0.312483 ± 0.000706296 (W 0.00162545) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.75245 ± 0.00464041 (W 0.00696556) | 2.76064 ± 0.00471451 (W 0.00665038) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 18.0095 ± 0.0832493 (W 0.154403) | 18.1382 ± 0.196793 (W 0.269893) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.083246 ± 0.000393027 (W 0.00265046) | 0.082865 ± 0.000735216 (W 0.000535583) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.085089 ± 0.000856453 (W 0.00403001) | 0.084668 ± 0.00148071 (W 0.00142319) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.517178 ± 0.00180409 (W 0.00190803) | 0.516708 ± 0.0045808 (W 0.00192346) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.520762 ± 0.00615524 (W 0.00229539) | 0.524192 ± 0.00247586 (W 0.00588494) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.06648 ± 0.0247862 (W 0.0102953) | 4.10283 ± 0.0420237 (W 0.0168763) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.11701 ± 0.0456035 (W 0.0125728) | 4.14022 ± 0.0250792 (W 0.00844748) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.206556 ± 0.0246607 (W 0.0044716) | 0.208781 ± 0.0191062 (W 0.00718358) | 0.150322 ± 0.0169278 (W 0.0015817) | · | 🔴 fork 1.37× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.13751 ± 0.11523 (W 0.020001) | 1.16583 ± 0.0151737 (W 0.0258009) | 0.377535 ± 0.11563 (W 0.00277418) | · | 🔴 fork 3.01× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 5.54901 ± 0.0700253 (W 0.0576461) | 5.69339 ± 0.0915168 (W 0.0300406) | 2.6342 ± 0.00716786 (W 0.0106937) | · | 🔴 fork 2.11× slower |  |
| `qr/n128/b1` | 1.41502 ± 0.0154023 (W 0.0211062) | 1.41415 ± 0.0247806 (W 0.0238033) | 0.478163 ± 0.00247106 (W 0.00214417) | · | 🔴 fork 2.96× slower |  |
| `qr/n256/b1` | 3.66374 ± 0.119869 (W 0.0700218) | 3.7259 ± 0.0300125 (W 0.0561499) | 2.01466 ± 0.0119846 (W 0.00395624) | · | 🔴 fork 1.82× slower | `!` between-start range over 5% |
| `qr/n512/b1` | 14.0727 ± 1.06912 (W 0.0518483) | 14.0962 ± 1.06254 (W 0.0954172) | 12.0569 ± 0.0558302 (W 0.0383449) | · | 🔴 fork 1.17× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 1.36349 ± 0.00376987 (W 0.0134424) | 1.46761 ± 0.0136316 (W 0.027444) | 0.19744 ± 0.000800428 (W 0.00118896) | 🔵 fork 1.08× faster | 🔴 fork 6.91× slower |  |
| `qr_factor/n256/b1` | 4.87829 ± 0.0050772 (W 0.0468608) | 5.66593 ± 0.0518616 (W 0.0496617) | 0.668849 ± 0.00305828 (W 0.0019281) | 🔵 fork 1.16× faster | 🔴 fork 7.29× slower |  |
| `qr_factor/n512/b1` | 20.2542 ± 0.168653 (W 0.0666239) | 22.0421 ± 0.257833 (W 0.107972) | 3.86314 ± 0.00772285 (W 0.00770999) | 🔵 fork 1.09× faster | 🔴 fork 5.24× slower |  |
| `solve/n128/b1` | 0.20305 ± 0.00230027 (W 0.00746276) | 0.199943 ± 0.0033793 (W 0.00354127) | 0.150361 ± 0.000437139 (W 0.000868338) | · | 🔴 fork 1.35× slower |  |
| `solve/n256/b1` | 0.924987 ± 0.00592074 (W 0.0124715) | 0.911662 ± 0.0165702 (W 0.0215616) | 0.36969 ± 0.000589649 (W 0.0023258) | · | 🔴 fork 2.50× slower |  |
| `solve/n512/b1` | 5.46403 ± 0.0260933 (W 0.0461949) | 5.43877 ± 0.08621 (W 0.0450471) | 1.80776 ± 0.0158583 (W 0.0038589) | · | 🔴 fork 3.02× slower |  |
| `svd_thin/n128/b1` | 3.04506 ± 0.0243359 (W 0.0254112) | 3.01772 ± 0.0139245 (W 0.0186446) | 2.63282 ± 0.00632571 (W 0.0057922) | · | 🔴 fork 1.16× slower |  |
| `svd_thin/n256/b1` | 13.6224 ± 0.0747215 (W 0.0137711) | 13.6636 ± 0.0610793 (W 0.0596187) | 12.4568 ± 0.0417541 (W 0.0172391) | · | 🔴 fork 1.09× slower |  |
| `svd_thin/n512/b1` | 62.1216 ± 0.0997484 (W 0.321502) | 61.5069 ± 0.325892 (W 0.482777) | 57.812 ± 2.68211 (W 0.0728771) | · | 🔴 fork 1.07× slower | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22506 ± 0.0149118 (W 0.00394054) | 2.21686 ± 0.012807 (W 0.00441331) | 1.13657 ± 0.0015719 (W 0.00227793) | · | 🔴 fork 1.96× slower |  |
| `svd_values/n256/b1` | 10.8793 ± 0.0310118 (W 0.102831) | 10.7627 ± 0.0264701 (W 0.0520359) | 6.14714 ± 0.00811479 (W 0.010443) | · | 🔴 fork 1.77× slower |  |
| `svd_values/n512/b1` | 47.9862 ± 0.596476 (W 0.40981) | 48.0056 ± 0.466911 (W 0.502452) | 25.7113 ± 0.109802 (W 0.022525) | · | 🔴 fork 1.87× slower |  |
| `triangular_solve/n128/b1` | 0.003897 ± 0.00014 (W 4.5607e-05) | 0.003707 ± 0.000156205 (W 2.96648e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.009938 ± 0.00143379 (W 6.78027e-05) | 0.010059 ± 0.00145372 (W 0.000171406) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.041578 ± 0.00275428 (W 0.00254716) | 0.036739 ± 0.00134239 (W 0.000234594) | - | 🔴 fork 1.13× slower | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.102462 ± 0.00212301 (W 0.00301053) | 0.105777 ± 0.00073436 (W 0.00224952) | 0.115386 ± 0.000354365 (W 0.000444678) | · | 🔵 fork 1.13× faster |  |
| `cholesky/n256/b1` | 0.451614 ± 0.0210066 (W 0.0209258) | 0.472622 ± 0.017408 (W 0.0176605) | 0.362446 ± 0.00496805 (W 0.0056031) | · | 🔴 fork 1.25× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.63301 ± 0.0230716 (W 0.0353227) | 1.65734 ± 0.0228867 (W 0.0310717) | 1.47445 ± 0.00411573 (W 0.00960962) | · | 🔴 fork 1.11× slower |  |
| `eigh/n128/b1` | 2.33463 ± 0.0247449 (W 0.0239885) | 2.3318 ± 0.0137832 (W 0.0249099) | 1.00131 ± 0.00379541 (W 0.00359405) | · | 🔴 fork 2.33× slower |  |
| `eigh/n256/b1` | 7.09011 ± 0.0172707 (W 0.0461717) | 7.0677 ± 0.0313712 (W 0.0349448) | 4.01282 ± 0.00613781 (W 0.0104479) | · | 🔴 fork 1.77× slower |  |
| `eigh/n512/b1` | 24.8636 ± 0.170259 (W 0.0962879) | 24.934 ± 0.107961 (W 0.114037) | 15.2537 ± 0.0530181 (W 0.0344694) | · | 🔴 fork 1.63× slower |  |
| `full_piv_lu/n128/b1` | 0.312034 ± 0.00227141 (W 0.00235921) | 0.311854 ± 0.0010362 (W 0.00233065) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.76785 ± 0.00835896 (W 0.00630192) | 2.76391 ± 0.0131709 (W 0.0085807) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.9852 ± 0.193663 (W 0.135784) | 17.908 ± 0.287971 (W 0.0675629) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.101119 ± 0.000195533 (W 0.00162076) | 0.101549 ± 0.000252239 (W 0.00150615) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.100669 ± 0.000685501 (W 0.00154768) | 0.102401 ± 0.000944464 (W 0.00200276) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.404397 ± 0.00990996 (W 0.0231248) | 0.41176 ± 0.0179421 (W 0.0191288) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.39545 ± 0.0163787 (W 0.0236227) | 0.406561 ± 0.0142058 (W 0.0139576) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.68446 ± 0.117938 (W 0.173025) | 2.54184 ± 0.0859311 (W 0.0900418) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.54183 ± 0.0591322 (W 0.104042) | 2.79877 ± 0.0384706 (W 0.189575) | - | 🔵 fork 1.10× faster | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.225251 ± 0.00485411 (W 0.00441426) | 0.220934 ± 0.00179108 (W 0.00784455) | 0.148919 ± 0.024259 (W 0.00129116) | · | 🔴 fork 1.51× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.25881 ± 0.123246 (W 0.0187066) | 1.28176 ± 0.00521506 (W 0.0286993) | 0.349745 ± 0.158336 (W 0.00358908) | · | 🔴 fork 3.60× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 5.76137 ± 0.0636362 (W 0.0936224) | 5.78612 ± 0.204419 (W 0.05691) | 2.22311 ± 0.0627012 (W 0.0120658) | · | 🔴 fork 2.59× slower | `!` between-start range over 5% |
| `qr/n128/b1` | 1.94319 ± 0.00188543 (W 0.0187806) | 1.94658 ± 0.013251 (W 0.0248385) | 0.432528 ± 0.00145499 (W 0.00342582) | · | 🔴 fork 4.49× slower |  |
| `qr/n256/b1` | 4.78182 ± 0.0253202 (W 0.0570155) | 4.8544 ± 0.0170088 (W 0.074791) | 1.79506 ± 0.00621948 (W 0.0111239) | · | 🔴 fork 2.66× slower |  |
| `qr/n512/b1` | 15.6652 ± 0.0414836 (W 0.154809) | 15.7873 ± 0.0241501 (W 0.169096) | 9.00255 ± 0.00436262 (W 0.0221601) | · | 🔴 fork 1.74× slower |  |
| `qr_factor/n128/b1` | 1.83728 ± 0.00270197 (W 0.019758) | 1.95031 ± 0.012207 (W 0.0192971) | 0.156153 ± 0.00122273 (W 0.00266589) | 🔵 fork 1.06× faster | 🔴 fork 11.77× slower |  |
| `qr_factor/n256/b1` | 5.88884 ± 0.016034 (W 0.0363952) | 6.71652 ± 0.0718397 (W 0.0216608) | 0.575915 ± 0.00468516 (W 0.00335197) | 🔵 fork 1.14× faster | 🔴 fork 10.23× slower |  |
| `qr_factor/n512/b1` | 22.687 ± 0.116477 (W 0.11458) | 25.2055 ± 0.160697 (W 0.0779156) | 2.31678 ± 0.00618021 (W 0.00429608) | 🔵 fork 1.11× faster | 🔴 fork 9.79× slower |  |
| `solve/n128/b1` | 0.215573 ± 0.00441642 (W 0.00413236) | 0.21395 ± 0.00197224 (W 0.00702398) | 0.146203 ± 0.000593244 (W 0.00156832) | · | 🔴 fork 1.47× slower |  |
| `solve/n256/b1` | 0.963449 ± 0.0203223 (W 0.0298051) | 0.950069 ± 0.0291611 (W 0.0329043) | 0.334807 ± 0.000969439 (W 0.002927) | · | 🔴 fork 2.88× slower | `!` between-start range over 5% |
| `solve/n512/b1` | 5.63245 ± 0.0926069 (W 0.132615) | 5.66246 ± 0.0785768 (W 0.095125) | 1.31661 ± 0.00796575 (W 0.00771527) | · | 🔴 fork 4.28× slower |  |
| `svd_thin/n128/b1` | 3.13597 ± 0.00559983 (W 0.0212324) | 3.12688 ± 0.00535981 (W 0.0139532) | 2.5131 ± 0.00349047 (W 0.00300074) | · | 🔴 fork 1.25× slower |  |
| `svd_thin/n256/b1` | 13.7405 ± 0.0183826 (W 0.0449373) | 13.7713 ± 0.060328 (W 0.0387487) | 11.4697 ± 0.0167451 (W 0.0110882) | · | 🔴 fork 1.20× slower |  |
| `svd_thin/n512/b1` | 60.5852 ± 0.221783 (W 0.369865) | 60.7409 ± 0.0923401 (W 0.323328) | 49.2087 ± 2.20075 (W 0.0493449) | · | 🔴 fork 1.23× slower | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.26594 ± 0.033086 (W 0.00388001) | 2.27874 ± 0.0339794 (W 0.0123776) | 1.13119 ± 0.00193215 (W 0.00423266) | · | 🔴 fork 2.00× slower |  |
| `svd_values/n256/b1` | 11.0112 ± 0.0318912 (W 0.0269494) | 10.9593 ± 0.0303276 (W 0.0253773) | 6.0186 ± 0.0176983 (W 0.00855258) | · | 🔴 fork 1.83× slower |  |
| `svd_values/n512/b1` | 49.0381 ± 0.137776 (W 0.366727) | 49.0901 ± 0.102956 (W 0.346557) | 22.3816 ± 0.123237 (W 0.0327865) | · | 🔴 fork 2.19× slower |  |
| `triangular_solve/n128/b1` | 0.003897 ± 0.000135769 (W 4.27785e-05) | 0.003697 ± 0.000173102 (W 2.96699e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.01109 ± 4.57202e-05 (W 5.50563e-05) | 0.011021 ± 5.56776e-05 (W 8.08288e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.039023 ± 0.00171898 (W 0.000750375) | 0.03739 ± 0.00209808 (W 0.00088749) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.060414 ± 0.00138023 (W 0.000120208) | 0.063458 ± 2.62742e-05 (W 0.00136253) | 0.092343 ± 0.000372775 (W 0.00131136) | · | 🔵 fork 1.53× faster |  |
| `cholesky/n256/b1` | 0.316693 ± 0.00186367 (W 0.00261426) | 0.323166 ± 0.00157852 (W 0.00171781) | 0.460433 ± 0.0186628 (W 0.00294277) | · | 🔵 fork 1.45× faster | `!` between-start range over 5% |
| `cholesky/n512/b1` | 2.06244 ± 0.00403565 (W 0.00255398) | 2.06464 ± 0.0030774 (W 0.00179187) | 3.39692 ± 0.00711398 (W 0.00531361) | · | 🔵 fork 1.65× faster |  |
| `eigh/n128/b1` | 2.24631 ± 0.00675898 (W 0.00328947) | 2.25265 ± 0.00946682 (W 0.00253376) | 1.81829 ± 0.00383138 (W 0.0100572) | · | 🔴 fork 1.24× slower |  |
| `eigh/n256/b1` | 9.73333 ± 0.0437821 (W 0.0208289) | 9.73549 ± 0.0313231 (W 0.00564328) | 9.85659 ± 0.0155289 (W 0.00984514) | · | · |  |
| `eigh/n512/b1` | 48.5671 ± 0.357842 (W 0.0522361) | 48.2404 ± 0.14186 (W 0.0267177) | 60.0735 ± 0.243292 (W 0.0777627) | · | 🔵 fork 1.24× faster |  |
| `full_piv_lu/n128/b1` | 0.289281 ± 0.00126384 (W 0.00176842) | 0.288931 ± 0.000847786 (W 0.00245306) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62782 ± 0.00606743 (W 0.00971405) | 2.62576 ± 0.011178 (W 0.00581602) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.6463 ± 0.343599 (W 0.0383312) | 21.7514 ± 0.458212 (W 0.0377577) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.253975 ± 0.0010351 (W 0.00163348) | 0.253824 ± 0.000246417 (W 0.0017435) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.255037 ± 0.000925617 (W 0.00157285) | 0.254787 ± 0.0012201 (W 0.00227225) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.86568 ± 0.00159399 (W 0.00356079) | 1.8672 ± 0.0013011 (W 0.00409065) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.9181 ± 0.0137611 (W 0.0073031) | 1.91648 ± 0.0102339 (W 0.00183408) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.7322 ± 0.0468121 (W 0.0122689) | 15.7144 ± 0.0471474 (W 0.016535) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7411 ± 0.0078089 (W 0.026067) | 15.7514 ± 0.0220979 (W 0.0216652) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145132 ± 0.00140605 (W 0.00118542) | 0.1446 ± 0.00174465 (W 0.00136732) | 0.134182 ± 0.000942425 (W 0.00126501) | · | 🔴 fork 1.08× slower |  |
| `lu/n256/b1` | 0.699848 ± 0.113112 (W 0.00345724) | 0.697583 ± 0.113532 (W 0.0029885) | 0.819537 ± 0.0050794 (W 0.00188236) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.11767 ± 0.00837717 (W 0.0049357) | 6.11894 ± 0.0132804 (W 0.0115364) | 5.23217 ± 0.0154994 (W 0.00696256) | · | 🔴 fork 1.17× slower |  |
| `qr/n128/b1` | 0.486348 ± 0.000353967 (W 0.00152741) | 0.488023 ± 0.00207409 (W 0.00181223) | 0.718196 ± 0.0257118 (W 0.00403313) | · | 🔵 fork 1.48× faster | `!` between-start range over 5% |
| `qr/n256/b1` | 2.77632 ± 0.000351122 (W 0.00227432) | 2.77797 ± 0.0018236 (W 0.0020557) | 4.31823 ± 0.0194821 (W 0.00907321) | · | 🔵 fork 1.56× faster |  |
| `qr/n512/b1` | 19.7811 ± 0.142418 (W 0.183879) | 19.847 ± 0.173005 (W 0.026538) | 30.2555 ± 0.0776031 (W 0.053792) | · | 🔵 fork 1.53× faster |  |
| `qr_factor/n128/b1` | 0.274564 ± 0.000554888 (W 0.00137701) | 0.275465 ± 0.00190486 (W 0.00156854) | 0.333192 ± 0.00211254 (W 0.00314912) | · | 🔵 fork 1.21× faster |  |
| `qr_factor/n256/b1` | 1.36521 ± 0.00410641 (W 0.00346955) | 1.37048 ± 0.00437995 (W 0.00225896) | 1.89937 ± 0.00343826 (W 0.00730673) | · | 🔵 fork 1.39× faster |  |
| `qr_factor/n512/b1` | 7.99071 ± 0.0139217 (W 0.00343175) | 8.02489 ± 0.0599688 (W 0.0104092) | 13.3735 ± 0.0661045 (W 0.0164345) | · | 🔵 fork 1.67× faster |  |
| `solve/n128/b1` | 0.112179 ± 0.00102636 (W 0.000834525) | 0.11225 ± 0.00127007 (W 0.000227247) | 0.132046 ± 0.000552046 (W 0.00198393) | · | 🔵 fork 1.18× faster |  |
| `solve/n256/b1` | 0.662583 ± 0.00104192 (W 0.00227223) | 0.664764 ± 0.000505057 (W 0.00345139) | 0.817567 ± 0.00150944 (W 0.00177992) | · | 🔵 fork 1.23× faster |  |
| `solve/n512/b1` | 6.04232 ± 0.0191574 (W 0.00975631) | 6.04053 ± 0.0191702 (W 0.0144431) | 5.23156 ± 0.0076846 (W 0.00845239) | · | 🔴 fork 1.15× slower |  |
| `svd_thin/n128/b1` | 3.69004 ± 0.00720129 (W 0.00325397) | 3.68922 ± 0.0067242 (W 0.00253896) | 3.31083 ± 0.00309751 (W 0.0147885) | · | 🔴 fork 1.11× slower |  |
| `svd_thin/n256/b1` | 18.3453 ± 0.0298343 (W 0.0115746) | 18.3476 ± 0.046279 (W 0.0211391) | 17.7914 ± 0.0715467 (W 0.0290522) | · | · |  |
| `svd_thin/n512/b1` | 105.323 ± 0.168672 (W 0.109291) | 105.14 ± 0.0956509 (W 0.119731) | 115.775 ± 0.671584 (W 0.288697) | · | 🔵 fork 1.10× faster |  |
| `svd_values/n128/b1` | 2.61447 ± 0.0130432 (W 0.0106276) | 2.61196 ± 0.00458102 (W 0.00399023) | 1.15387 ± 0.00061378 (W 0.00240189) | · | 🔴 fork 2.27× slower |  |
| `svd_values/n256/b1` | 12.2805 ± 0.0158698 (W 0.00656278) | 12.2536 ± 0.014636 (W 0.00969584) | 6.84613 ± 0.00955333 (W 0.00905694) | · | 🔴 fork 1.79× slower |  |
| `svd_values/n512/b1` | 65.1827 ± 0.424198 (W 0.0754805) | 65.198 ± 0.377895 (W 0.145661) | 47.2283 ± 0.175011 (W 0.0481036) | · | 🔴 fork 1.38× slower |  |
| `triangular_solve/n128/b1` | 0.004248 ± 0.000598449 (W 1.82538e-05) | 0.004458 ± 0.000200575 (W 1.66193e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013976 ± 3.05505e-05 (W 4.05364e-05) | 0.013936 ± 4.16333e-05 (W 4.11242e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.043752 ± 0.00234674 (W 0.000406933) | 0.043732 ± 0.00238379 (W 0.000164388) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.095809 ± 0.00389511 (W 0.00773165) | 0.102391 ± 0.00684844 (W 0.00734781) | 0.091602 ± 0.00079527 (W 0.00155939) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n256/b1` | 0.344333 ± 0.0209848 (W 0.0256963) | 0.367708 ± 0.0115346 (W 0.0226905) | 0.242884 ± 0.0208307 (W 0.00416047) | · | 🔴 fork 1.42× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.19696 ± 0.010473 (W 0.0445848) | 1.20533 ± 0.00543574 (W 0.0301059) | 1.40095 ± 0.0103177 (W 0.00623076) | · | 🔵 fork 1.17× faster |  |
| `eigh/n128/b1` | 2.33006 ± 0.0292557 (W 0.0548665) | 2.28794 ± 0.0495815 (W 0.00846877) | 1.04661 ± 0.00324382 (W 0.00245159) | · | 🔴 fork 2.23× slower |  |
| `eigh/n256/b1` | 6.96226 ± 0.0690468 (W 0.0332587) | 6.91725 ± 0.0165755 (W 0.0327961) | 4.67429 ± 0.00226609 (W 0.00983513) | · | 🔴 fork 1.49× slower |  |
| `eigh/n512/b1` | 25.9334 ± 0.170713 (W 0.045298) | 25.886 ± 0.17065 (W 0.0631614) | 21.1541 ± 0.0620266 (W 0.0472707) | · | 🔴 fork 1.23× slower |  |
| `full_piv_lu/n128/b1` | 0.289812 ± 0.000459304 (W 0.00137412) | 0.290233 ± 0.000744762 (W 0.00130231) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61132 ± 0.00942054 (W 0.00762668) | 2.61415 ± 0.0120192 (W 0.00961805) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8773 ± 0.0571412 (W 0.131907) | 16.9 ± 0.103489 (W 0.105483) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.083656 ± 0.000206182 (W 0.000377345) | 0.083677 ± 0.000447885 (W 0.000429865) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.084688 ± 0.000596474 (W 0.00180488) | 0.084638 ± 0.000862365 (W 0.000714506) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.518301 ± 0.000674792 (W 0.00363508) | 0.521103 ± 0.0298974 (W 0.00202267) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.523597 ± 0.00206465 (W 0.00272315) | 0.52304 ± 0.00277761 (W 0.00328909) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.08169 ± 0.0305014 (W 0.0068625) | 4.08034 ± 0.0173719 (W 0.00501166) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.1529 ± 0.0582592 (W 0.0227849) | 4.14921 ± 0.0727931 (W 0.00932952) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.215213 ± 0.00449807 (W 0.0111229) | 0.214732 ± 0.00392894 (W 0.00650873) | 0.132547 ± 0.000556457 (W 0.00120847) | · | 🔴 fork 1.62× slower |  |
| `lu/n256/b1` | 0.840374 ± 0.131596 (W 0.0142099) | 0.960169 ± 0.109352 (W 0.026571) | 0.324608 ± 0.0013546 (W 0.00206346) | · | 🔴 fork 2.59× slower | `!` between-start range over 5% |
| `lu/n512/b1` | 4.58176 ± 0.00829929 (W 0.0809982) | 4.56179 ± 0.0584813 (W 0.0664962) | 1.64905 ± 0.0107585 (W 0.00499511) | · | 🔴 fork 2.78× slower |  |
| `qr/n128/b1` | 1.38289 ± 0.0156778 (W 0.0209195) | 1.3898 ± 0.0107848 (W 0.0198301) | 0.451766 ± 0.0023558 (W 0.0021145) | · | 🔴 fork 3.06× slower |  |
| `qr/n256/b1` | 3.54684 ± 0.0429768 (W 0.0389332) | 3.5063 ± 0.0930964 (W 0.0264175) | 2.18378 ± 0.0284628 (W 0.00989307) | · | 🔴 fork 1.62× slower |  |
| `qr/n512/b1` | 12.9368 ± 1.03507 (W 0.110162) | 13.092 ± 1.02523 (W 0.0888464) | 13.0983 ± 0.0547389 (W 0.0125037) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 1.1532 ± 0.02943 (W 0.0161292) | 1.16411 ± 0.0457633 (W 0.00689612) | 0.183152 ± 0.00111602 (W 0.00214945) | · | 🔴 fork 6.30× slower | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 3.01012 ± 0.0610014 (W 0.0623049) | 3.08123 ± 0.0726051 (W 0.0469376) | 0.619911 ± 0.00479351 (W 0.00439766) | · | 🔴 fork 4.86× slower |  |
| `qr_factor/n512/b1` | 8.35102 ± 0.0979036 (W 0.0745993) | 8.3211 ± 0.0792178 (W 0.0994642) | 3.65562 ± 0.0052562 (W 0.00477926) | · | 🔴 fork 2.28× slower |  |
| `solve/n128/b1` | 0.179375 ± 0.00294647 (W 0.0050728) | 0.183573 ± 0.00103852 (W 0.00565501) | 0.131435 ± 0.000459544 (W 0.00148717) | · | 🔴 fork 1.36× slower |  |
| `solve/n256/b1` | 0.753281 ± 0.00903349 (W 0.0217831) | 0.766183 ± 0.0138 (W 0.00959717) | 0.314107 ± 0.00142087 (W 0.00272412) | · | 🔴 fork 2.40× slower |  |
| `solve/n512/b1` | 4.42034 ± 0.0403466 (W 0.0850444) | 4.38746 ± 0.0507097 (W 0.0824684) | 1.61014 ± 0.0159049 (W 0.00408694) | · | 🔴 fork 2.75× slower |  |
| `svd_thin/n128/b1` | 3.02003 ± 0.0129744 (W 0.0345012) | 3.00682 ± 0.0096882 (W 0.0166947) | 2.60648 ± 0.00895949 (W 0.00376711) | · | 🔴 fork 1.16× slower |  |
| `svd_thin/n256/b1` | 13.5484 ± 0.0563151 (W 0.0527171) | 13.6135 ± 0.0645686 (W 0.0594725) | 12.3362 ± 0.0230433 (W 0.0148067) | · | 🔴 fork 1.10× slower |  |
| `svd_thin/n512/b1` | 60.9042 ± 0.0809374 (W 0.217334) | 61.1804 ± 1.16919 (W 0.266099) | 56.4732 ± 0.10481 (W 0.0597609) | · | 🔴 fork 1.08× slower |  |
| `svd_values/n128/b1` | 2.16678 ± 0.013769 (W 0.00465932) | 2.16051 ± 0.00825074 (W 0.00511672) | 1.12437 ± 0.0090577 (W 0.0042675) | · | 🔴 fork 1.93× slower |  |
| `svd_values/n256/b1` | 10.6662 ± 0.0188812 (W 0.0600585) | 10.6328 ± 0.0159323 (W 0.0173458) | 6.08748 ± 0.0429124 (W 0.00931028) | · | 🔴 fork 1.75× slower |  |
| `svd_values/n512/b1` | 47.2991 ± 0.302118 (W 0.584048) | 47.2235 ± 0.261258 (W 0.32855) | 25.5044 ± 0.0576732 (W 0.0125838) | · | 🔴 fork 1.85× slower |  |
| `triangular_solve/n128/b1` | 0.004248 ± 0.000272666 (W 2.34521e-05) | 0.004628 ± 0.000234628 (W 4.23462e-05) | - | 🔵 fork 1.09× faster | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011472 ± 0.00135138 (W 3.32611e-05) | 0.013535 ± 0.00145204 (W 4.47471e-05) | - | 🔵 fork 1.18× faster | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.043351 ± 0.00308929 (W 0.000799757) | 0.046488 ± 0.00343519 (W 0.00242414) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0961 ± 0.000623308 (W 0.00294767) | 0.098194 ± 0.00308073 (W 0.00242932) | 0.091131 ± 0.000991564 (W 0.000930914) | · | 🔴 fork 1.05× slower | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.379309 ± 0.00555814 (W 0.0213005) | 0.387556 ± 0.0137735 (W 0.0215611) | 0.193572 ± 0.00280843 (W 0.00291551) | · | 🔴 fork 1.96× slower | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.1659 ± 0.0245533 (W 0.0311408) | 1.19198 ± 0.0158792 (W 0.0336147) | 0.946667 ± 0.00512927 (W 0.0113391) | · | 🔴 fork 1.23× slower |  |
| `eigh/n128/b1` | 2.35121 ± 0.0394862 (W 0.029015) | 2.34466 ± 0.00681009 (W 0.0224749) | 0.982609 ± 0.00847492 (W 0.00261292) | · | 🔴 fork 2.39× slower |  |
| `eigh/n256/b1` | 7.03896 ± 0.020315 (W 0.0360588) | 7.00873 ± 0.0200668 (W 0.0279269) | 3.90378 ± 0.0106566 (W 0.00629863) | · | 🔴 fork 1.80× slower |  |
| `eigh/n512/b1` | 24.5409 ± 0.121438 (W 0.112065) | 24.5193 ± 0.0749038 (W 0.149976) | 14.7971 ± 0.0463923 (W 0.0349404) | · | 🔴 fork 1.66× slower |  |
| `full_piv_lu/n128/b1` | 0.288831 ± 0.00049091 (W 0.00174337) | 0.28863 ± 0.000603573 (W 0.00174041) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62149 ± 0.0179301 (W 0.00783798) | 2.62575 ± 0.0150998 (W 0.0118185) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.7755 ± 0.0993035 (W 0.155104) | 16.8212 ± 0.0757921 (W 0.135034) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.102832 ± 0.000602681 (W 0.00230617) | 0.10156 ± 0.00214902 (W 0.00129454) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.103994 ± 0.00148407 (W 0.00148015) | 0.102732 ± 0.00300659 (W 0.00159547) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.384779 ± 0.0146973 (W 0.0163622) | 0.390781 ± 0.00851376 (W 0.0159519) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.400088 ± 0.0182847 (W 0.0200219) | 0.381913 ± 0.0152946 (W 0.0125661) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.56986 ± 0.022646 (W 0.157515) | 2.573 ± 0.04248 (W 0.388689) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.64414 ± 0.155039 (W 0.312304) | 2.59232 ± 0.161239 (W 0.158653) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.231573 ± 0.0189029 (W 0.00961119) | 0.233195 ± 0.0269883 (W 0.0113835) | 0.132257 ± 0.000351412 (W 0.0014658) | · | 🔴 fork 1.75× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.94511 ± 0.123382 (W 0.0200656) | 0.951366 ± 0.124288 (W 0.0259959) | 0.318486 ± 0.00284502 (W 0.00254466) | · | 🔴 fork 2.97× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.77587 ± 0.0257226 (W 0.070394) | 4.71251 ± 0.0222561 (W 0.0423864) | 1.23561 ± 0.0129392 (W 0.00749222) | · | 🔴 fork 3.87× slower |  |
| `qr/n128/b1` | 1.90818 ± 0.0327653 (W 0.0315418) | 1.87491 ± 0.0101464 (W 0.0250365) | 0.415757 ± 0.00343125 (W 0.00597865) | · | 🔴 fork 4.59× slower |  |
| `qr/n256/b1` | 4.62286 ± 0.0449319 (W 0.0681993) | 4.72752 ± 0.0718644 (W 0.0274069) | 2.01784 ± 0.00701781 (W 0.00711554) | · | 🔴 fork 2.29× slower |  |
| `qr/n512/b1` | 14.6577 ± 0.179787 (W 0.126672) | 14.772 ± 0.00932451 (W 0.165689) | 10.3002 ± 0.0348401 (W 0.0210919) | · | 🔴 fork 1.42× slower |  |
| `qr_factor/n128/b1` | 1.59279 ± 0.0567583 (W 0.0310603) | 1.59468 ± 0.0109975 (W 0.013557) | 0.145483 ± 0.00114312 (W 0.00127061) | · | 🔴 fork 10.95× slower | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 4.03449 ± 0.0582195 (W 0.0657567) | 4.04665 ± 0.0357167 (W 0.0592121) | 0.540369 ± 0.000320506 (W 0.00239178) | · | 🔴 fork 7.47× slower |  |
| `qr_factor/n512/b1` | 10.1419 ± 0.17674 (W 0.133319) | 10.1218 ± 0.120843 (W 0.0873678) | 2.1984 ± 0.00161904 (W 0.00502) | · | 🔴 fork 4.61× slower |  |
| `solve/n128/b1` | 0.190557 ± 0.00228176 (W 0.00422151) | 0.189945 ± 0.00118984 (W 0.00444584) | 0.131967 ± 0.000671961 (W 0.000378197) | · | 🔴 fork 1.44× slower |  |
| `solve/n256/b1` | 0.838365 ± 0.0190965 (W 0.0174721) | 0.824073 ± 0.00493922 (W 0.0284338) | 0.300552 ± 0.0021016 (W 0.00314158) | · | 🔴 fork 2.79× slower |  |
| `solve/n512/b1` | 4.55188 ± 0.0289154 (W 0.976561) | 4.53823 ± 0.0275853 (W 0.0874388) | 1.19271 ± 0.00823053 (W 0.00385079) | · | 🔴 fork 3.82× slower |  |
| `svd_thin/n128/b1` | 3.11928 ± 0.0131927 (W 0.0206295) | 3.09916 ± 0.00975501 (W 0.0263951) | 2.46973 ± 0.00314989 (W 0.00714698) | · | 🔴 fork 1.26× slower |  |
| `svd_thin/n256/b1` | 13.6334 ± 0.0297655 (W 0.0408426) | 13.6635 ± 0.033861 (W 0.0329925) | 11.3824 ± 0.0406423 (W 0.0141463) | · | 🔴 fork 1.20× slower |  |
| `svd_thin/n512/b1` | 59.7811 ± 0.223987 (W 0.285639) | 59.9039 ± 0.0450536 (W 0.29555) | 47.8998 ± 0.0826365 (W 0.0887598) | · | 🔴 fork 1.25× slower |  |
| `svd_values/n128/b1` | 2.16672 ± 0.0390096 (W 0.00422456) | 2.1556 ± 0.0435418 (W 0.00186526) | 1.1166 ± 0.0016992 (W 0.00269546) | · | 🔴 fork 1.94× slower |  |
| `svd_values/n256/b1` | 10.8087 ± 0.031191 (W 0.0252966) | 10.8015 ± 0.0325149 (W 0.0378453) | 5.98747 ± 0.0113141 (W 0.00690908) | · | 🔴 fork 1.81× slower |  |
| `svd_values/n512/b1` | 47.7371 ± 0.277575 (W 0.482708) | 48.0589 ± 0.179754 (W 0.361385) | 22.3521 ± 0.184359 (W 0.0228331) | · | 🔴 fork 2.14× slower |  |
| `triangular_solve/n128/b1` | 0.004268 ± 3.09892e-05 (W 3.63318e-05) | 0.004668 ± 0.000481333 (W 4.3589e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012714 ± 0.000281308 (W 4.32435e-05) | 0.012703 ± 0.000153385 (W 5.99191e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.043111 ± 0.00180735 (W 0.000769979) | 0.046406 ± 0.00322822 (W 0.000579642) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188003 ± 0.000275144 (W 0.000960857) | 0.187381 ± 0.000466083 (W 0.000943374) | 0.47583 ± 0.000194099 (W 0.00203534) | · | 🔵 fork 2.53× faster |  |
| `cholesky/n256/b1` | 1.22065 ± 0.0111017 (W 0.00167579) | 1.21957 ± 0.0101178 (W 0.00192574) | 1.84608 ± 0.00874907 (W 0.00364093) | · | 🔵 fork 1.51× faster |  |
| `cholesky/n512/b1` | 8.15825 ± 0.149749 (W 0.0073734) | 8.08318 ± 0.103089 (W 0.017801) | 11.3953 ± 0.0297127 (W 0.0160588) | · | 🔵 fork 1.40× faster |  |
| `eigh/n128/b1` | 3.26549 ± 0.00146085 (W 0.00363587) | 3.27393 ± 0.00179802 (W 0.00480305) | 4.41351 ± 0.00272653 (W 0.00472758) | · | 🔵 fork 1.35× faster |  |
| `eigh/n256/b1` | 17.4097 ± 0.0244251 (W 0.0113037) | 17.45 ± 0.0253376 (W 0.0125591) | 26.3733 ± 0.0560238 (W 0.0202348) | · | 🔵 fork 1.51× faster |  |
| `eigh/n512/b1` | 105.462 ± 0.249798 (W 0.0669349) | 105.577 ± 0.111901 (W 0.404055) | 170.944 ± 0.112629 (W 0.0538483) | · | 🔵 fork 1.62× faster |  |
| `full_piv_lu/n128/b1` | 0.777458 ± 0.00382082 (W 0.00622259) | 0.773206 ± 0.0033165 (W 0.00609509) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 6.04225 ± 0.048622 (W 0.0086317) | 6.09297 ± 0.0346866 (W 0.0107903) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.9344 ± 0.320112 (W 0.0272473) | 40.9823 ± 0.299086 (W 0.0318708) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05539 ± 0.00868741 (W 0.000860581) | 1.05265 ± 0.0056341 (W 0.00171462) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04961 ± 0.00316567 (W 0.0011564) | 1.05574 ± 0.00280027 (W 0.00133097) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.50651 ± 0.0150022 (W 0.00708622) | 7.49493 ± 0.0194487 (W 0.00736029) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.51824 ± 0.00580265 (W 0.0115267) | 7.51482 ± 0.0108474 (W 0.00274632) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8552 ± 0.0770248 (W 0.032758) | 56.83 ± 0.103005 (W 0.0447616) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.9337 ± 0.0805349 (W 0.0354306) | 56.9229 ± 0.144277 (W 0.32105) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.330908 ± 0.00037256 (W 0.00234074) | 0.329806 ± 0.000547038 (W 0.00207483) | 0.501528 ± 0.00154275 (W 0.00208196) | · | 🔵 fork 1.52× faster |  |
| `lu/n256/b1` | 2.21624 ± 0.00179522 (W 0.00771854) | 2.21578 ± 0.00156423 (W 0.00977037) | 3.31249 ± 0.0109242 (W 0.0104857) | · | 🔵 fork 1.49× faster |  |
| `lu/n512/b1` | 14.9402 ± 0.139295 (W 0.0192935) | 15.0588 ± 0.115873 (W 0.0244048) | 21.1557 ± 0.0301324 (W 0.0180584) | · | 🔵 fork 1.42× faster |  |
| `qr/n128/b1` | 1.57893 ± 0.0038655 (W 0.00235937) | 1.58398 ± 0.00386019 (W 0.0024036) | 1.99164 ± 0.0025285 (W 0.0048374) | · | 🔵 fork 1.26× faster |  |
| `qr/n256/b1` | 10.2666 ± 0.013276 (W 0.00380755) | 10.285 ± 0.0634917 (W 0.00499031) | 12.3411 ± 0.00404467 (W 0.0194316) | · | 🔵 fork 1.20× faster |  |
| `qr/n512/b1` | 69.7506 ± 0.0410057 (W 0.0231824) | 69.9396 ± 0.0281285 (W 0.0411824) | 80.785 ± 0.0948536 (W 0.364422) | · | 🔵 fork 1.16× faster |  |
| `qr_factor/n128/b1` | 0.947051 ± 0.0017919 (W 0.00244623) | 1.06597 ± 0.00028227 (W 0.00218553) | 0.955975 ± 0.001162 (W 0.00254261) | 🔵 fork 1.13× faster | · |  |
| `qr_factor/n256/b1` | 5.91624 ± 0.0144827 (W 0.00966485) | 6.52215 ± 0.0254259 (W 0.0109233) | 5.66321 ± 0.00369118 (W 0.00994991) | 🔵 fork 1.10× faster | · |  |
| `qr_factor/n512/b1` | 35.6744 ± 0.246994 (W 0.0446521) | 37.5719 ± 0.263242 (W 0.0213247) | 39.038 ± 0.0895268 (W 0.0453472) | 🔵 fork 1.05× faster | 🔵 fork 1.09× faster |  |
| `solve/n128/b1` | 0.326843 ± 0.00345336 (W 0.00171638) | 0.327112 ± 0.00197488 (W 0.00241284) | 0.489407 ± 0.00245886 (W 0.00316799) | · | 🔵 fork 1.50× faster |  |
| `solve/n256/b1` | 2.14238 ± 0.0069123 (W 0.00476295) | 2.14954 ± 0.000979035 (W 0.00565545) | 2.83025 ± 0.00296033 (W 0.00569538) | · | 🔵 fork 1.32× faster |  |
| `solve/n512/b1` | 14.9039 ± 0.0580702 (W 0.0270633) | 14.9052 ± 0.107686 (W 0.0268785) | 18.802 ± 0.0350515 (W 0.0183556) | · | 🔵 fork 1.26× faster |  |
| `svd_thin/n128/b1` | 5.73638 ± 0.0103799 (W 0.00884244) | 5.73794 ± 0.0136001 (W 0.003837) | 7.05334 ± 0.00913582 (W 0.0119773) | · | 🔵 fork 1.23× faster |  |
| `svd_thin/n256/b1` | 34.1195 ± 0.0257723 (W 0.0305836) | 34.117 ± 0.0716671 (W 0.0368832) | 43.5811 ± 0.305288 (W 0.0393032) | · | 🔵 fork 1.28× faster |  |
| `svd_thin/n512/b1` | 211.008 ± 0.398999 (W 0.418825) | 210.887 ± 0.242348 (W 0.395515) | 277.064 ± 1.54678 (W 0.599203) | · | 🔵 fork 1.31× faster |  |
| `svd_values/n128/b1` | 3.46144 ± 0.0101636 (W 0.00538163) | 3.46158 ± 0.00922045 (W 0.00390355) | 2.75449 ± 0.00602292 (W 0.00330043) | · | 🔴 fork 1.26× slower |  |
| `svd_values/n256/b1` | 19.2533 ± 0.0614709 (W 0.0262495) | 19.275 ± 0.0249799 (W 0.0183357) | 18.0435 ± 0.0587846 (W 0.0218372) | · | 🔴 fork 1.07× slower |  |
| `svd_values/n512/b1` | 111.443 ± 0.869362 (W 0.122676) | 111.411 ± 0.737981 (W 0.329398) | 123.7 ± 0.821201 (W 0.110531) | · | 🔵 fork 1.11× faster |  |
| `triangular_solve/n128/b1` | 0.007584 ± 1.52753e-05 (W 2.93973e-05) | 0.007564 ± 3e-05 (W 3.22366e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023554 ± 0.000326558 (W 9.795e-05) | 0.023635 ± 0.000214898 (W 0.00127173) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.085881 ± 0.000741814 (W 0.00160583) | 0.08524 ± 0.000542955 (W 0.00137903) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.204122 ± 0.00213773 (W 0.0042875) | 0.202898 ± 0.00118758 (W 0.00409331) | 0.47497 ± 0.00368843 (W 0.00168511) | · | 🔵 fork 2.33× faster |  |
| `cholesky/n256/b1` | 0.876209 ± 0.0163856 (W 0.01373) | 0.876411 ± 0.022136 (W 0.0159064) | 0.793687 ± 0.001301 (W 0.00532362) | · | 🔴 fork 1.10× slower |  |
| `cholesky/n512/b1` | 3.41007 ± 0.01791 (W 0.0298359) | 3.40813 ± 0.00946368 (W 0.0265348) | 3.62119 ± 0.028749 (W 0.0118264) | · | 🔵 fork 1.06× faster |  |
| `eigh/n128/b1` | 2.99372 ± 0.0327831 (W 0.0445851) | 2.95293 ± 0.0148909 (W 0.0199605) | 2.04841 ± 0.00569195 (W 0.00554909) | · | 🔴 fork 1.46× slower |  |
| `eigh/n256/b1` | 11.4325 ± 0.0472345 (W 0.0432045) | 11.4396 ± 0.0555128 (W 0.037185) | 10.137 ± 0.0236165 (W 0.0160507) | · | 🔴 fork 1.13× slower |  |
| `eigh/n512/b1` | 46.591 ± 0.159223 (W 0.070954) | 46.534 ± 0.132533 (W 0.150121) | 53.0605 ± 0.136132 (W 0.051175) | · | 🔵 fork 1.14× faster |  |
| `full_piv_lu/n128/b1` | 0.77536 ± 0.0383001 (W 0.00570198) | 0.777024 ± 0.0414454 (W 0.00678745) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 6.02475 ± 0.118893 (W 0.0194737) | 6.00301 ± 0.139939 (W 0.0130533) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.1467 ± 0.267241 (W 0.0336264) | 27.1703 ± 0.314438 (W 0.0652695) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.287358 ± 0.00070926 (W 0.0012697) | 0.287157 ± 0.00189441 (W 0.0011478) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.289782 ± 0.00300284 (W 0.0016506) | 0.289602 ± 0.00261474 (W 0.00147368) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92995 ± 0.00658209 (W 0.00391159) | 1.93414 ± 0.00775122 (W 0.00300511) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92625 ± 0.0188735 (W 0.0106618) | 1.93735 ± 0.00923151 (W 0.00357899) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.6383 ± 0.00913156 (W 0.0164187) | 14.6691 ± 0.03398 (W 0.0147884) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6914 ± 0.0509184 (W 0.033865) | 14.7223 ± 0.019177 (W 0.0217367) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.350985 ± 0.00590873 (W 0.00711004) | 0.346396 ± 0.00129515 (W 0.00499222) | 0.481479 ± 0.00462336 (W 0.00294714) | · | 🔵 fork 1.37× faster |  |
| `lu/n256/b1` | 1.67962 ± 0.00937041 (W 0.0185883) | 1.7021 ± 0.0127999 (W 0.0133445) | 1.01192 ± 0.00645279 (W 0.00244387) | · | 🔴 fork 1.66× slower |  |
| `lu/n512/b1` | 7.45076 ± 0.0169489 (W 0.0331358) | 7.50691 ± 0.076994 (W 0.036375) | 6.2267 ± 0.0319886 (W 0.0181396) | · | 🔴 fork 1.20× slower |  |
| `qr/n128/b1` | 1.91336 ± 0.00613147 (W 0.0128778) | 1.91557 ± 0.0147899 (W 0.0254021) | 1.04273 ± 0.00236702 (W 0.00402127) | · | 🔴 fork 1.83× slower |  |
| `qr/n256/b1` | 6.21212 ± 0.0281521 (W 0.0369487) | 6.25294 ± 0.0164873 (W 0.0338668) | 4.78859 ± 0.029569 (W 0.0105527) | · | 🔴 fork 1.30× slower |  |
| `qr/n512/b1` | 26.5353 ± 0.0521638 (W 0.0430429) | 26.6652 ± 0.041386 (W 0.0471516) | 28.5857 ± 0.0208109 (W 0.0426906) | · | 🔵 fork 1.08× faster |  |
| `qr_factor/n128/b1` | 1.65929 ± 0.00981882 (W 0.0138117) | 1.78783 ± 0.0275262 (W 0.0269512) | 0.45387 ± 0.00122401 (W 0.00145552) | 🔵 fork 1.08× faster | 🔴 fork 3.66× slower |  |
| `qr_factor/n256/b1` | 6.60658 ± 0.0753932 (W 0.0394776) | 7.30955 ± 0.0333912 (W 0.0449441) | 1.63294 ± 0.0012666 (W 0.0036437) | 🔵 fork 1.11× faster | 🔴 fork 4.05× slower |  |
| `qr_factor/n512/b1` | 24.3447 ± 0.249712 (W 0.0965925) | 26.8747 ± 0.472478 (W 0.102841) | 11.4291 ± 0.0101387 (W 0.0123688) | 🔵 fork 1.10× faster | 🔴 fork 2.13× slower |  |
| `solve/n128/b1` | 0.33667 ± 0.00339327 (W 0.0047315) | 0.344132 ± 0.0017129 (W 0.00708722) | 0.468857 ± 0.000896287 (W 0.00228007) | · | 🔵 fork 1.39× faster |  |
| `solve/n256/b1` | 1.58159 ± 0.013613 (W 0.0121921) | 1.55083 ± 0.0207315 (W 0.0235795) | 0.895845 ± 0.00349278 (W 0.00284948) | · | 🔴 fork 1.77× slower |  |
| `solve/n512/b1` | 7.32105 ± 0.0251876 (W 0.03431) | 7.30491 ± 0.0407432 (W 0.027745) | 5.63998 ± 0.0251584 (W 0.0119908) | · | 🔴 fork 1.30× slower |  |
| `svd_thin/n128/b1` | 4.34461 ± 0.0242351 (W 0.0227121) | 4.33147 ± 0.00636167 (W 0.0201154) | 4.15905 ± 0.000629498 (W 0.00969425) | · | · |  |
| `svd_thin/n256/b1` | 22.4403 ± 0.132379 (W 0.103672) | 22.4577 ± 0.0916681 (W 0.0677425) | 21.2038 ± 0.0819595 (W 0.0377141) | · | 🔴 fork 1.06× slower |  |
| `svd_thin/n512/b1` | 95.056 ± 0.301394 (W 0.523522) | 94.8386 ± 0.200913 (W 0.457622) | 113.626 ± 0.19972 (W 0.420419) | · | 🔵 fork 1.20× faster |  |
| `svd_values/n128/b1` | 3.04438 ± 0.00722393 (W 0.00249091) | 3.04483 ± 0.00783408 (W 0.00882926) | 2.02941 ± 0.0147168 (W 0.00344766) | · | 🔴 fork 1.50× slower |  |
| `svd_values/n256/b1` | 17.0877 ± 0.0996704 (W 0.0790077) | 17.0747 ± 0.00782253 (W 0.0643703) | 11.0363 ± 0.00598222 (W 0.0177889) | · | 🔴 fork 1.55× slower |  |
| `svd_values/n512/b1` | 65.2167 ± 0.243131 (W 0.25356) | 64.8795 ± 0.0424593 (W 0.17678) | 55.6535 ± 0.101476 (W 0.0528296) | · | 🔴 fork 1.17× slower |  |
| `triangular_solve/n128/b1` | 0.007594 ± 1e-05 (W 4.94196e-05) | 0.007564 ± 3.05505e-05 (W 2.15685e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023464 ± 0.000167033 (W 5.24404e-05) | 0.023554 ± 0.000371291 (W 0.000155726) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.06933 ± 0.00128938 (W 0.00138003) | 0.06935 ± 0.00415513 (W 0.000959271) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.214462 ± 0.00244086 (W 0.00581537) | 0.213679 ± 0.00304694 (W 0.0043382) | 0.478685 ± 0.00352798 (W 0.00375837) | · | 🔵 fork 2.23× faster |  |
| `cholesky/n256/b1` | 0.8868 ± 0.0100135 (W 0.0168577) | 0.898006 ± 0.00719377 (W 0.0169958) | 0.66263 ± 0.00521779 (W 0.00310475) | · | 🔴 fork 1.34× slower |  |
| `cholesky/n512/b1` | 2.86741 ± 0.0176838 (W 0.0258536) | 2.83739 ± 0.0190102 (W 0.0391168) | 2.26809 ± 0.018173 (W 0.0161514) | · | 🔴 fork 1.26× slower |  |
| `eigh/n128/b1` | 3.00413 ± 0.0122137 (W 0.0136374) | 3.00893 ± 0.00397353 (W 0.0161055) | 1.7001 ± 0.00676475 (W 0.00576001) | · | 🔴 fork 1.77× slower |  |
| `eigh/n256/b1` | 11.1574 ± 0.0479961 (W 0.0141569) | 11.1875 ± 0.0442913 (W 0.0233076) | 8.03291 ± 0.00444765 (W 0.0126142) | · | 🔴 fork 1.39× slower |  |
| `eigh/n512/b1` | 40.2251 ± 0.25202 (W 0.175514) | 40.0475 ± 0.239604 (W 0.206102) | 37.0325 ± 0.0669608 (W 0.0239106) | · | 🔴 fork 1.09× slower |  |
| `full_piv_lu/n128/b1` | 0.773787 ± 0.00394841 (W 0.0035034) | 0.776439 ± 0.00260755 (W 0.00543448) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.98384 ± 0.0608388 (W 0.0263169) | 6.02663 ± 0.0353509 (W 0.0241177) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.5724 ± 0.0171492 (W 0.166929) | 25.5146 ± 0.209758 (W 0.107384) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.271868 ± 0.000722856 (W 0.00180135) | 0.27275 ± 0.00238377 (W 0.0031736) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.272069 ± 0.00347039 (W 0.00221551) | 0.27248 ± 0.00230859 (W 0.00154281) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.28425 ± 0.0155356 (W 0.0672636) | 1.29075 ± 0.0127538 (W 0.0181112) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.29514 ± 0.0201699 (W 0.0631124) | 1.27876 ± 0.0167648 (W 0.0645933) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.74724 ± 0.0129477 (W 0.207393) | 8.71014 ± 0.56948 (W 0.567601) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.804 ± 0.0286368 (W 0.629704) | 8.83756 ± 0.108313 (W 0.142519) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.364643 ± 0.00513732 (W 0.00605867) | 0.367228 ± 0.00522388 (W 0.00608016) | 0.485266 ± 0.00153522 (W 0.00304722) | · | 🔵 fork 1.33× faster |  |
| `lu/n256/b1` | 1.67684 ± 0.0198216 (W 0.0232192) | 1.70093 ± 0.000455676 (W 0.0175705) | 0.696243 ± 0.00206599 (W 0.00321818) | · | 🔴 fork 2.41× slower |  |
| `lu/n512/b1` | 6.49462 ± 0.0171034 (W 0.0550711) | 6.46926 ± 0.01284 (W 0.0306062) | 3.60563 ± 0.01242 (W 0.0110539) | · | 🔴 fork 1.80× slower |  |
| `qr/n128/b1` | 2.49979 ± 0.0258214 (W 0.0465589) | 2.44995 ± 0.00965726 (W 0.0327895) | 0.782611 ± 0.000863462 (W 0.00362959) | · | 🔴 fork 3.19× slower |  |
| `qr/n256/b1` | 6.93951 ± 0.0269711 (W 0.0714217) | 6.9424 ± 0.0649875 (W 0.0382089) | 3.84078 ± 0.00460131 (W 0.00452508) | · | 🔴 fork 1.81× slower |  |
| `qr/n512/b1` | 23.1331 ± 0.120259 (W 0.178475) | 23.2231 ± 0.0633138 (W 0.118357) | 16.1389 ± 0.0824859 (W 0.0209059) | · | 🔴 fork 1.43× slower |  |
| `qr_factor/n128/b1` | 2.1723 ± 0.022104 (W 0.0207688) | 2.33059 ± 0.00641968 (W 0.0261904) | 0.323215 ± 0.000763143 (W 0.00130188) | 🔵 fork 1.07× faster | 🔴 fork 6.72× slower |  |
| `qr_factor/n256/b1` | 7.75673 ± 0.0556505 (W 0.0584813) | 8.55277 ± 0.0859818 (W 0.0559509) | 1.62428 ± 0.00424591 (W 0.00284218) | 🔵 fork 1.10× faster | 🔴 fork 4.78× slower |  |
| `qr_factor/n512/b1` | 25.1616 ± 0.116126 (W 0.222493) | 27.5962 ± 0.401829 (W 0.15032) | 5.83874 ± 0.0111515 (W 0.0101077) | 🔵 fork 1.10× faster | 🔴 fork 4.31× slower |  |
| `solve/n128/b1` | 0.362828 ± 0.00395996 (W 0.00620651) | 0.359603 ± 0.00511009 (W 0.00465005) | 0.470028 ± 0.000726072 (W 0.00435488) | · | 🔵 fork 1.30× faster |  |
| `solve/n256/b1` | 1.53854 ± 0.00744384 (W 0.0159577) | 1.53309 ± 0.0112288 (W 0.0200661) | 0.668428 ± 0.0010085 (W 0.00327154) | · | 🔴 fork 2.30× slower |  |
| `solve/n512/b1` | 6.26634 ± 0.0191577 (W 0.0370056) | 6.2859 ± 0.0135247 (W 0.0278825) | 3.44872 ± 0.00375314 (W 0.0175617) | · | 🔴 fork 1.82× slower |  |
| `svd_thin/n128/b1` | 4.48237 ± 0.00971009 (W 0.0159115) | 4.46481 ± 0.0247977 (W 0.00960291) | 3.65648 ± 0.0166807 (W 0.00627761) | · | 🔴 fork 1.23× slower |  |
| `svd_thin/n256/b1` | 21.9929 ± 0.0498513 (W 0.0678563) | 22.0332 ± 0.0291419 (W 0.0902571) | 17.2578 ± 0.0133316 (W 0.0235689) | · | 🔴 fork 1.27× slower |  |
| `svd_thin/n512/b1` | 81.9649 ± 0.303144 (W 0.307125) | 81.681 ± 0.148564 (W 0.385946) | 83.2519 ± 0.673964 (W 0.166148) | · | · |  |
| `svd_values/n128/b1` | 3.05114 ± 0.027016 (W 0.010254) | 3.08548 ± 0.0192138 (W 0.00843022) | 1.91436 ± 0.00517388 (W 0.00317287) | · | 🔴 fork 1.59× slower |  |
| `svd_values/n256/b1` | 17.1784 ± 0.0443361 (W 0.0359707) | 17.2189 ± 0.0362609 (W 0.062529) | 9.65061 ± 0.088116 (W 0.0154904) | · | 🔴 fork 1.78× slower |  |
| `svd_values/n512/b1` | 61.2563 ± 0.303015 (W 0.308063) | 61.2721 ± 0.38217 (W 0.312446) | 43.0425 ± 0.180599 (W 0.039127) | · | 🔴 fork 1.42× slower |  |
| `triangular_solve/n128/b1` | 0.007544 ± 8.14453e-05 (W 4.64134e-05) | 0.007524 ± 4.3589e-05 (W 4.41837e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023354 ± 8.88819e-05 (W 0.000109541) | 0.023334 ± 6.60328e-05 (W 8.07465e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.071584 ± 0.00131195 (W 0.00120563) | 0.070131 ± 0.000366544 (W 0.000929919) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175067 ± 0.000195065 (W 0.0013009) | 0.174898 ± 0.000417278 (W 0.00152256) | 0.407644 ± 0.000311487 (W 0.00349778) | · | 🔵 fork 2.33× faster |  |
| `cholesky/n256/b1` | 1.12882 ± 0.0012646 (W 0.00164922) | 1.12938 ± 0.000520407 (W 0.00224092) | 1.59935 ± 0.0166382 (W 0.00350888) | · | 🔵 fork 1.42× faster |  |
| `cholesky/n512/b1` | 7.59901 ± 0.0708558 (W 0.00659786) | 7.56967 ± 0.0838078 (W 0.0357899) | 12.0453 ± 0.0311787 (W 0.0279131) | · | 🔵 fork 1.59× faster |  |
| `eigh/n128/b1` | 3.2542 ± 0.00313112 (W 0.00763355) | 3.26396 ± 0.00246588 (W 0.00226331) | 4.35991 ± 0.0013683 (W 0.00525691) | · | 🔵 fork 1.34× faster |  |
| `eigh/n256/b1` | 17.315 ± 0.0394234 (W 0.00933397) | 17.3232 ± 0.0442945 (W 0.40379) | 26.1494 ± 0.0196403 (W 0.0148271) | · | 🔵 fork 1.51× faster |  |
| `eigh/n512/b1` | 105.041 ± 0.124206 (W 0.0573362) | 105.095 ± 0.177353 (W 0.402932) | 169.679 ± 0.178084 (W 0.104924) | · | 🔵 fork 1.62× faster |  |
| `full_piv_lu/n128/b1` | 0.75204 ± 0.00771577 (W 0.00473022) | 0.748403 ± 0.00323953 (W 0.00431964) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.79256 ± 0.0386515 (W 0.00782709) | 5.81038 ± 0.06605 (W 0.00772875) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.0023 ± 0.357329 (W 0.0376875) | 39.9542 ± 0.366791 (W 0.0284066) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03884 ± 0.00509974 (W 0.000670236) | 1.04059 ± 0.00518962 (W 0.00156052) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04154 ± 0.00136098 (W 0.00121369) | 1.04134 ± 0.00171007 (W 0.000887535) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.42937 ± 0.0271745 (W 0.00577579) | 7.42876 ± 0.0294415 (W 0.00732741) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.4301 ± 0.0150253 (W 0.0037166) | 7.42918 ± 0.00710779 (W 0.00535592) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.7301 ± 0.112258 (W 0.0528449) | 56.7335 ± 0.0485124 (W 0.0644333) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.6648 ± 0.0471436 (W 0.0691215) | 56.6972 ± 0.0585961 (W 0.088951) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.298869 ± 0.00178566 (W 0.00249941) | 0.299121 ± 0.000857304 (W 0.00335201) | 0.458468 ± 0.00197107 (W 0.00226646) | · | 🔵 fork 1.53× faster |  |
| `lu/n256/b1` | 2.00111 ± 0.00732142 (W 0.00703955) | 2.00106 ± 0.0087976 (W 0.00894836) | 3.15196 ± 0.00530021 (W 0.0069299) | · | 🔵 fork 1.58× faster |  |
| `lu/n512/b1` | 13.882 ± 0.100306 (W 0.0194183) | 13.8983 ± 0.0929437 (W 0.0257739) | 19.77 ± 0.00652426 (W 0.0271417) | · | 🔵 fork 1.42× faster |  |
| `qr/n128/b1` | 1.54326 ± 0.00342493 (W 0.00275722) | 1.54828 ± 0.00209425 (W 0.00190262) | 1.97181 ± 0.00481926 (W 0.00561961) | · | 🔵 fork 1.28× faster |  |
| `qr/n256/b1` | 10.0351 ± 0.0261833 (W 0.00766358) | 10.0965 ± 0.0265944 (W 0.0145805) | 12.3503 ± 0.0161084 (W 0.0124622) | · | 🔵 fork 1.23× faster |  |
| `qr/n512/b1` | 68.8244 ± 0.0351574 (W 0.37515) | 68.8857 ± 0.0360675 (W 0.0523301) | 79.9933 ± 0.100271 (W 0.0462949) | · | 🔵 fork 1.16× faster |  |
| `qr_factor/n128/b1` | 0.741807 ± 0.00258143 (W 0.00294474) | 0.745257 ± 0.000785727 (W 0.0022295) | 0.911355 ± 0.00196859 (W 0.00264789) | · | 🔵 fork 1.23× faster |  |
| `qr_factor/n256/b1` | 4.45527 ± 0.00634503 (W 0.00334521) | 4.48445 ± 0.00733156 (W 0.00359436) | 5.50734 ± 0.00748301 (W 0.00599527) | · | 🔵 fork 1.24× faster |  |
| `qr_factor/n512/b1` | 28.8776 ± 0.058057 (W 0.0180748) | 28.9957 ± 0.057245 (W 0.00947196) | 37.9564 ± 0.0452387 (W 0.0481296) | · | 🔵 fork 1.31× faster |  |
| `solve/n128/b1` | 0.29437 ± 0.00134171 (W 0.00360777) | 0.292468 ± 0.00084456 (W 0.00246516) | 0.445252 ± 0.00128158 (W 0.00202308) | · | 🔵 fork 1.51× faster |  |
| `solve/n256/b1` | 1.93522 ± 0.00350535 (W 0.00382742) | 1.93718 ± 0.00581494 (W 0.00389284) | 2.6648 ± 0.00944022 (W 0.00919746) | · | 🔵 fork 1.38× faster |  |
| `solve/n512/b1` | 13.8967 ± 0.0516491 (W 0.0341073) | 13.9011 ± 0.070922 (W 0.0212258) | 18.0265 ± 0.0183708 (W 0.0288321) | · | 🔵 fork 1.30× faster |  |
| `svd_thin/n128/b1` | 5.71151 ± 0.0176969 (W 0.00614284) | 5.70483 ± 0.0128202 (W 0.00714889) | 6.97158 ± 0.0115839 (W 0.00442141) | · | 🔵 fork 1.22× faster |  |
| `svd_thin/n256/b1` | 33.7725 ± 0.0397085 (W 0.0263229) | 33.7958 ± 0.059433 (W 0.411503) | 43.206 ± 0.248301 (W 0.0634067) | · | 🔵 fork 1.28× faster |  |
| `svd_thin/n512/b1` | 210.128 ± 0.898659 (W 0.355149) | 209.984 ± 1.10487 (W 0.385124) | 304.893 ± 1.93586 (W 0.878247) | · | 🔵 fork 1.45× faster |  |
| `svd_values/n128/b1` | 3.44875 ± 0.015778 (W 0.00547853) | 3.43996 ± 0.0149824 (W 0.00481727) | 2.70834 ± 0.00558279 (W 0.0027478) | · | 🔴 fork 1.27× slower |  |
| `svd_values/n256/b1` | 18.9812 ± 0.0337512 (W 0.00996091) | 18.9789 ± 0.0542397 (W 0.0195745) | 17.9431 ± 0.0351655 (W 0.0122751) | · | 🔴 fork 1.06× slower |  |
| `svd_values/n512/b1` | 110.424 ± 0.812455 (W 0.50705) | 110.025 ± 0.438192 (W 0.484932) | 150.251 ± 1.03539 (W 0.411851) | · | 🔵 fork 1.36× faster |  |
| `triangular_solve/n128/b1` | 0.007764 ± 0.000347304 (W 3.28512e-05) | 0.007814 ± 0.000464149 (W 2.34521e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022603 ± 0.00157498 (W 9.47697e-05) | 0.022031 ± 0.0015474 (W 0.000138348) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.087564 ± 0.0029824 (W 0.000527239) | 0.086853 ± 0.00282134 (W 0.00169255) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.18709 ± 0.00644754 (W 0.00535641) | 0.190486 ± 0.00233561 (W 0.00363593) | 0.409477 ± 0.0015332 (W 0.0020845) | · | 🔵 fork 2.19× faster | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.777832 ± 0.00692397 (W 0.00916144) | 0.782203 ± 0.00731668 (W 0.00756563) | 0.589103 ± 0.00933826 (W 0.00814789) | · | 🔴 fork 1.32× slower |  |
| `cholesky/n512/b1` | 3.04083 ± 0.0198469 (W 0.0264118) | 3.0381 ± 0.00866953 (W 0.0288125) | 3.23011 ± 0.00839003 (W 0.0197765) | · | 🔵 fork 1.06× faster |  |
| `eigh/n128/b1` | 2.95558 ± 0.024 (W 0.0209128) | 2.95175 ± 0.0128831 (W 0.0206854) | 2.00052 ± 0.00641511 (W 0.00421215) | · | 🔴 fork 1.48× slower |  |
| `eigh/n256/b1` | 11.363 ± 0.0125445 (W 0.0404716) | 11.3047 ± 0.0375984 (W 0.0550006) | 9.97201 ± 0.0044447 (W 0.0190458) | · | 🔴 fork 1.14× slower |  |
| `eigh/n512/b1` | 46.1742 ± 0.181283 (W 0.0827919) | 46.2343 ± 0.159525 (W 0.140501) | 52.5885 ± 0.082066 (W 0.403913) | · | 🔵 fork 1.14× faster |  |
| `full_piv_lu/n128/b1` | 0.749793 ± 0.0389062 (W 0.00524746) | 0.745254 ± 0.038443 (W 0.00716625) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.74026 ± 0.117152 (W 0.0243036) | 5.73411 ± 0.126134 (W 0.0155747) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.2122 ± 0.263109 (W 0.0884956) | 26.3053 ± 0.292602 (W 0.0646405) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.287488 ± 0.000547001 (W 0.00220772) | 0.287557 ± 0.00013602 (W 0.00134268) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.287698 ± 0.000792265 (W 0.000982925) | 0.290383 ± 0.000524033 (W 0.00147503) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92291 ± 0.00655021 (W 0.0045164) | 1.91636 ± 0.00535177 (W 0.00378518) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.91816 ± 0.00444528 (W 0.00604886) | 1.92023 ± 0.00639708 (W 0.00417348) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7031 ± 0.0141822 (W 0.029287) | 14.734 ± 0.0477342 (W 0.0261904) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6962 ± 0.0507303 (W 0.0242898) | 14.7364 ± 0.0778237 (W 0.0211711) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.319637 ± 0.00562222 (W 0.00614232) | 0.314477 ± 0.00199951 (W 0.00280387) | 0.457034 ± 0.000930375 (W 0.00231617) | · | 🔵 fork 1.43× faster |  |
| `lu/n256/b1` | 1.48453 ± 0.016072 (W 0.0240457) | 1.47875 ± 0.00890653 (W 0.0114913) | 0.96912 ± 0.00604136 (W 0.00316803) | · | 🔴 fork 1.53× slower |  |
| `lu/n512/b1` | 6.53385 ± 0.0275117 (W 0.0383264) | 6.56034 ± 0.0556649 (W 0.0323469) | 5.83202 ± 0.0410406 (W 0.00956274) | · | 🔴 fork 1.12× slower |  |
| `qr/n128/b1` | 1.87583 ± 0.00642497 (W 0.0137093) | 1.87574 ± 0.0114073 (W 0.0144005) | 1.0594 ± 0.00745693 (W 0.00534093) | · | 🔴 fork 1.77× slower |  |
| `qr/n256/b1` | 5.92605 ± 0.0269104 (W 0.0527322) | 5.98993 ± 0.0258685 (W 0.043542) | 4.9993 ± 0.0152578 (W 0.016083) | · | 🔴 fork 1.19× slower |  |
| `qr/n512/b1` | 25.6726 ± 0.0311815 (W 0.0821386) | 25.7384 ± 0.0496214 (W 0.0496928) | 29.1416 ± 0.065749 (W 0.0333198) | · | 🔵 fork 1.14× faster |  |
| `qr_factor/n128/b1` | 1.42006 ± 0.0235801 (W 0.0143964) | 1.41701 ± 0.0231218 (W 0.0169666) | 0.436848 ± 0.00177926 (W 0.00259903) | · | 🔴 fork 3.25× slower |  |
| `qr_factor/n256/b1` | 4.25733 ± 0.0134754 (W 0.0397468) | 4.28078 ± 0.0533328 (W 0.0304152) | 1.57818 ± 0.00358537 (W 0.00366054) | · | 🔴 fork 2.70× slower |  |
| `qr_factor/n512/b1` | 14.5359 ± 0.0943906 (W 0.0701497) | 14.6602 ± 0.0524723 (W 0.0601613) | 11.0273 ± 0.0248853 (W 0.0218998) | · | 🔴 fork 1.32× slower |  |
| `solve/n128/b1` | 0.309529 ± 0.00293199 (W 0.00536828) | 0.309859 ± 0.00641857 (W 0.00645644) | 0.444029 ± 0.000857002 (W 0.00152856) | · | 🔵 fork 1.43× faster |  |
| `solve/n256/b1` | 1.34768 ± 0.00966379 (W 0.0143758) | 1.34761 ± 0.00186843 (W 0.0138866) | 0.863262 ± 0.00562417 (W 0.00258532) | · | 🔴 fork 1.56× slower |  |
| `solve/n512/b1` | 6.39395 ± 0.0112244 (W 0.0242963) | 6.41806 ± 0.0499975 (W 0.0202049) | 5.40556 ± 0.00615456 (W 0.0156451) | · | 🔴 fork 1.18× slower |  |
| `svd_thin/n128/b1` | 4.32831 ± 0.0231672 (W 0.0197927) | 4.32332 ± 0.0163968 (W 0.0223403) | 4.10242 ± 0.00599459 (W 0.00416774) | · | 🔴 fork 1.06× slower |  |
| `svd_thin/n256/b1` | 22.1278 ± 0.168643 (W 0.0925274) | 22.2031 ± 0.042068 (W 0.0715466) | 20.9834 ± 0.0203989 (W 0.0311352) | · | 🔴 fork 1.05× slower |  |
| `svd_thin/n512/b1` | 93.8598 ± 0.346248 (W 0.200027) | 93.5875 ± 0.146666 (W 0.187115) | 112.613 ± 1.53586 (W 0.141934) | · | 🔵 fork 1.20× faster |  |
| `svd_values/n128/b1` | 3.01477 ± 0.00439939 (W 0.0180084) | 3.01959 ± 0.0140661 (W 0.0138935) | 2.01424 ± 0.0021808 (W 0.00400197) | · | 🔴 fork 1.50× slower |  |
| `svd_values/n256/b1` | 16.8333 ± 0.0209966 (W 0.0670375) | 16.8892 ± 0.0262651 (W 0.090561) | 11.0091 ± 0.0254529 (W 0.0150761) | · | 🔴 fork 1.53× slower |  |
| `svd_values/n512/b1` | 64.1808 ± 0.159915 (W 0.198162) | 64.1813 ± 0.358494 (W 0.312907) | 55.5068 ± 0.0748345 (W 0.0632052) | · | 🔴 fork 1.16× slower |  |
| `triangular_solve/n128/b1` | 0.007134 ± 3.05505e-05 (W 3.12298e-05) | 0.007184 ± 5.34821e-05 (W 2.17325e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022913 ± 0.00171554 (W 8.80755e-05) | 0.022822 ± 0.00166035 (W 0.000313298) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.068909 ± 0.00640047 (W 0.00203836) | 0.075742 ± 0.00389296 (W 0.00059168) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.200165 ± 0.00212063 (W 0.00424574) | 0.201517 ± 0.00158377 (W 0.00346521) | 0.406909 ± 0.000978192 (W 0.00392139) | · | 🔵 fork 2.03× faster |  |
| `cholesky/n256/b1` | 0.800288 ± 0.0156888 (W 0.0182273) | 0.791548 ± 0.00654728 (W 0.0109876) | 0.461103 ± 0.00374146 (W 0.00335793) | · | 🔴 fork 1.74× slower |  |
| `cholesky/n512/b1` | 2.50733 ± 0.0162692 (W 0.02194) | 2.4984 ± 0.0216488 (W 0.0236017) | 1.86724 ± 0.0161294 (W 0.0152014) | · | 🔴 fork 1.34× slower |  |
| `eigh/n128/b1` | 3.00285 ± 0.00863062 (W 0.0142422) | 2.99797 ± 0.00393015 (W 0.0142958) | 1.65054 ± 0.00398041 (W 0.00360987) | · | 🔴 fork 1.82× slower |  |
| `eigh/n256/b1` | 11.0866 ± 0.0307217 (W 0.0358366) | 11.0986 ± 0.0698619 (W 0.0430565) | 7.87878 ± 0.0133539 (W 0.00394609) | · | 🔴 fork 1.41× slower |  |
| `eigh/n512/b1` | 39.7211 ± 0.0801447 (W 0.102838) | 39.6896 ± 0.0742281 (W 0.157252) | 36.5286 ± 0.0533629 (W 0.0367089) | · | 🔴 fork 1.09× slower |  |
| `full_piv_lu/n128/b1` | 0.745572 ± 0.00188521 (W 0.00667339) | 0.744129 ± 0.00319846 (W 0.00312399) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74805 ± 0.0257276 (W 0.0103148) | 5.75406 ± 0.0280819 (W 0.0289158) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.5277 ± 0.0691675 (W 0.218093) | 24.5138 ± 0.0918266 (W 0.14724) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.276407 ± 0.00139367 (W 0.00200282) | 0.276468 ± 0.000170845 (W 0.00152733) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.278011 ± 0.00229989 (W 0.00117322) | 0.27797 ± 0.00174704 (W 0.00293807) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.28015 ± 0.00648787 (W 0.0606526) | 1.2818 ± 0.00639298 (W 0.0618548) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.28742 ± 0.00500524 (W 0.0105231) | 1.28797 ± 0.00784382 (W 0.066734) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.70058 ± 0.44901 (W 0.483924) | 8.78543 ± 0.0239029 (W 0.423365) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.77677 ± 0.0168755 (W 0.580547) | 8.78876 ± 0.112012 (W 0.482337) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.335529 ± 0.00390457 (W 0.00635389) | 0.339323 ± 0.0031355 (W 0.00543417) | 0.458207 ± 0.00145122 (W 0.00264093) | · | 🔵 fork 1.37× faster |  |
| `lu/n256/b1` | 1.47728 ± 0.00697825 (W 0.0186125) | 1.47024 ± 0.00860344 (W 0.017407) | 0.681284 ± 0.00417808 (W 0.00131101) | · | 🔴 fork 2.17× slower |  |
| `lu/n512/b1` | 5.55415 ± 0.0249508 (W 0.0304297) | 5.58919 ± 0.0287823 (W 0.0310345) | 3.46225 ± 0.0167268 (W 0.0066664) | · | 🔴 fork 1.60× slower |  |
| `qr/n128/b1` | 2.40996 ± 0.0399147 (W 0.0257652) | 2.42726 ± 0.0359937 (W 0.0277395) | 0.796619 ± 0.00377798 (W 0.00523487) | · | 🔴 fork 3.03× slower |  |
| `qr/n256/b1` | 6.66889 ± 0.0763986 (W 0.0640384) | 6.76693 ± 0.0291614 (W 0.0475528) | 4.09141 ± 0.0175079 (W 0.0104759) | · | 🔴 fork 1.63× slower |  |
| `qr/n512/b1` | 22.1113 ± 0.223405 (W 0.205118) | 22.2826 ± 0.104679 (W 0.0960121) | 17.0875 ± 0.053713 (W 0.0272508) | · | 🔴 fork 1.29× slower |  |
| `qr_factor/n128/b1` | 1.88587 ± 0.0160172 (W 0.0288056) | 1.91322 ± 0.00944822 (W 0.0114952) | 0.307716 ± 0.00131466 (W 0.00146075) | · | 🔴 fork 6.13× slower |  |
| `qr_factor/n256/b1` | 5.25809 ± 0.0653824 (W 0.0481782) | 5.40526 ± 0.00449521 (W 0.0697215) | 1.58685 ± 0.00205879 (W 0.00244926) | · | 🔴 fork 3.31× slower |  |
| `qr_factor/n512/b1` | 14.8415 ± 0.0284671 (W 0.108423) | 15.0024 ± 0.240929 (W 0.0869925) | 5.62541 ± 0.00483476 (W 0.00328797) | · | 🔴 fork 2.64× slower |  |
| `solve/n128/b1` | 0.329396 ± 0.00367407 (W 0.0041789) | 0.323686 ± 0.00229769 (W 0.00559479) | 0.444893 ± 0.00138006 (W 0.00252314) | · | 🔵 fork 1.35× faster |  |
| `solve/n256/b1` | 1.32079 ± 0.0158754 (W 0.0235525) | 1.33591 ± 0.0109217 (W 0.0113718) | 0.653289 ± 0.00230658 (W 0.00267314) | · | 🔴 fork 2.02× slower |  |
| `solve/n512/b1` | 5.39134 ± 0.0519964 (W 0.0429406) | 5.40489 ± 0.0286862 (W 0.0342369) | 3.30223 ± 0.0152704 (W 0.00583209) | · | 🔴 fork 1.63× slower |  |
| `svd_thin/n128/b1` | 4.47085 ± 0.00498268 (W 0.0214185) | 4.45836 ± 0.0131065 (W 0.02087) | 3.6161 ± 0.0192156 (W 0.00523339) | · | 🔴 fork 1.24× slower |  |
| `svd_thin/n256/b1` | 21.739 ± 0.0315417 (W 0.0800168) | 21.7224 ± 0.126397 (W 0.0562354) | 17.1791 ± 0.061493 (W 0.0373458) | · | 🔴 fork 1.27× slower |  |
| `svd_thin/n512/b1` | 80.8859 ± 0.17375 (W 0.303498) | 80.7842 ± 0.248045 (W 0.345852) | 81.7399 ± 0.286263 (W 0.0278224) | · | · |  |
| `svd_values/n128/b1` | 3.07445 ± 0.0349067 (W 0.00767613) | 3.00641 ± 0.00408848 (W 0.0037947) | 1.90548 ± 0.00293697 (W 0.00474879) | · | 🔴 fork 1.61× slower |  |
| `svd_values/n256/b1` | 16.9719 ± 0.0570109 (W 0.0387282) | 16.8982 ± 0.0621807 (W 0.0324115) | 9.66024 ± 0.0603173 (W 0.0172701) | · | 🔴 fork 1.76× slower |  |
| `svd_values/n512/b1` | 60.4411 ± 0.159956 (W 0.238068) | 60.3046 ± 0.196825 (W 0.218918) | 42.8936 ± 0.341271 (W 0.0457633) | · | 🔴 fork 1.41× slower |  |
| `triangular_solve/n128/b1` | 0.007123 ± 0.000674364 (W 3.86562e-05) | 0.007124 ± 0.00056667 (W 3.64184e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.020298 ± 0.000166154 (W 4.76445e-05) | 0.020278 ± 5.2915e-05 (W 0.00141615) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.076052 ± 0.00418206 (W 0.00381122) | 0.075441 ± 0.00115303 (W 0.00347349) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.811174 ± 0.000620549 (W 0.00307174) | 0.815682 ± 0.000897335 (W 0.00322587) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 53.1945 ± 1.96693 (W 0.961391) | 52.4869 ± 1.65538 (W 1.02424) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.563945 ± 0.00786525 (W 0.00262581) | 0.56658 ± 0.00922776 (W 0.00186341) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554788 ± 0.00757331 (W 0.00332069) | 0.552643 ± 0.00961534 (W 0.00303152) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1827 ± 0.527948 (W 0.0208096) | 35.1756 ± 0.577844 (W 0.0432688) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.0176 ± 0.100948 (W 0.0395526) | 35.0293 ± 0.127629 (W 0.0213238) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.470709 ± 0.00601846 (W 0.00739345) | 0.472662 ± 0.004549 (W 0.00433323) | 0.658853 ± 0.133544 (W 0.00379862) | · | 🔵 fork 1.40× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 18.946 ± 0.0380149 (W 0.0276076) | 18.9386 ± 0.0594333 (W 0.0410964) | 17.8882 ± 2.54157 (W 0.0788143) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.54942 ± 0.00321965 (W 0.00386097) | 1.54822 ± 0.0039916 (W 0.00726276) | 1.86679 ± 0.014561 (W 0.00283498) | · | 🔵 fork 1.20× faster |  |
| `qr/4096x256/b1` | 69.6745 ± 0.0807282 (W 0.0855203) | 69.6364 ± 0.0724788 (W 0.0516616) | 81.8018 ± 0.649306 (W 0.284633) | · | 🔵 fork 1.17× faster |  |
| `qr_factor/1024x64/b1` | 1.83161 ± 0.00541313 (W 0.00392717) | 1.86138 ± 0.00979748 (W 0.00690612) | 0.908917 ± 0.00770626 (W 0.0015242) | · | 🔴 fork 2.02× slower |  |
| `qr_factor/4096x256/b1` | 77.9553 ± 0.231608 (W 0.0866215) | 78.3481 ± 0.218374 (W 0.0518114) | 35.1231 ± 0.0891311 (W 0.148689) | · | 🔴 fork 2.22× slower |  |
| `svd_thin/1024x64/b1` | 2.50767 ± 0.00234671 (W 0.0032761) | 2.50045 ± 0.00690215 (W 0.00244634) | 3.05018 ± 0.00641115 (W 0.00796441) | · | 🔵 fork 1.22× faster |  |
| `svd_thin/4096x256/b1` | 88.4374 ± 0.155055 (W 0.0498677) | 88.415 ± 0.154988 (W 0.430328) | 120.476 ± 0.099628 (W 0.356337) | · | 🔵 fork 1.36× faster |  |
| `svd_values/1024x64/b1` | 1.49673 ± 0.00984314 (W 0.00225655) | 1.49237 ± 0.00959635 (W 0.00525462) | 1.38591 ± 0.0166669 (W 0.00356287) | · | 🔴 fork 1.08× slower |  |
| `svd_values/4096x256/b1` | 44.7753 ± 0.08253 (W 0.0543348) | 44.8124 ± 0.0612959 (W 0.11559) | 46.7113 ± 0.14389 (W 0.12896) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.817566 ± 0.00515505 (W 0.00339145) | 0.810611 ± 0.00587495 (W 0.00499144) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 24.4087 ± 0.622666 (W 0.550438) | 24.4027 ± 0.983718 (W 0.175487) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.16021 ± 0.00379094 (W 0.00117724) | 0.157934 ± 0.00227248 (W 0.00116393) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.160329 ± 0.00283551 (W 0.00108107) | 0.16082 ± 0.00219372 (W 0.0013152) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 9.39231 ± 0.0132797 (W 0.0372388) | 9.37725 ± 0.0117424 (W 0.0295591) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 9.3995 ± 0.0621182 (W 0.0303736) | 9.40358 ± 0.0393919 (W 0.0568905) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.498583 ± 0.00540037 (W 0.0166206) | 0.505996 ± 0.00564037 (W 0.00709748) | 0.532376 ± 0.117895 (W 0.00280752) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 13.0279 ± 0.02673 (W 0.0379025) | 13.0039 ± 0.0353814 (W 0.0377702) | 13.4341 ± 1.91633 (W 0.0347931) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.69891 ± 0.0287829 (W 0.0171946) | 1.67962 ± 0.0049721 (W 0.0150765) | 1.05589 ± 0.00329881 (W 0.00685698) | · | 🔴 fork 1.61× slower |  |
| `qr/4096x256/b1` | 35.4054 ± 0.0421666 (W 0.115195) | 35.3753 ± 0.138163 (W 0.123355) | 30.115 ± 0.153318 (W 0.0528501) | · | 🔴 fork 1.18× slower |  |
| `qr_factor/1024x64/b1` | 3.91452 ± 0.240155 (W 0.0959875) | 3.85674 ± 0.0804238 (W 0.142557) | 0.453903 ± 0.00251171 (W 0.00822861) | · | 🔴 fork 8.62× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 76.8914 ± 9.79461 (W 0.492295) | 76.6081 ± 0.183642 (W 0.370277) | 12.8638 ± 0.0802018 (W 0.116648) | · | 🔴 fork 5.98× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/1024x64/b1` | 2.79454 ± 0.0376835 (W 0.0332523) | 2.78067 ± 0.0169158 (W 0.0142271) | 1.89336 ± 0.00253156 (W 0.00316192) | · | 🔴 fork 1.48× slower |  |
| `svd_thin/4096x256/b1` | 50.3908 ± 0.140301 (W 0.0824196) | 50.4665 ± 0.199247 (W 0.0698759) | 48.7094 ± 2.17336 (W 0.142644) | · | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.12752 ± 0.0304059 (W 0.0290734) | 2.08431 ± 0.00566644 (W 0.0295645) | 0.951877 ± 0.00699015 (W 0.00443824) | · | 🔴 fork 2.24× slower |  |
| `svd_values/4096x256/b1` | 35.4893 ± 1.04812 (W 0.177853) | 35.4475 ± 0.769817 (W 0.158188) | 22.7416 ± 0.291599 (W 0.0613181) | · | 🔴 fork 1.56× slower | `!` between-start range over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814444 ± 0.00776768 (W 0.00325099) | 0.808749 ± 0.00413427 (W 0.00514548) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.5237 ± 1.2146 (W 0.15361) | 19.5359 ± 0.0443116 (W 1.36859) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.135024 ± 0.000743505 (W 0.00234286) | 0.13781 ± 0.00285176 (W 0.00234471) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.136257 ± 0.00117668 (W 0.00215212) | 0.132327 ± 0.00225297 (W 0.00422864) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 4.97206 ± 0.0778618 (W 0.0249444) | 4.98637 ± 0.0433199 (W 0.0362465) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.03268 ± 0.0132729 (W 0.0611777) | 5.04174 ± 0.0137119 (W 1.02743) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.523157 ± 0.00304248 (W 0.0144189) | 0.525691 ± 0.00547459 (W 0.00908345) | 0.598467 ± 0.166588 (W 0.0017692) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 12.2526 ± 0.0630469 (W 0.024613) | 12.2829 ± 0.0404408 (W 0.0261579) | 4.20361 ± 1.80522 (W 0.0105197) | · | 🔴 fork 2.91× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.96606 ± 0.0271678 (W 0.0345413) | 2.00233 ± 0.00952632 (W 0.0260959) | 0.884702 ± 0.00506086 (W 0.00348413) | · | 🔴 fork 2.22× slower |  |
| `qr/4096x256/b1` | 35.3567 ± 0.47559 (W 0.779228) | 34.8624 ± 0.524313 (W 0.488165) | 20.8002 ± 0.137209 (W 0.0580877) | · | 🔴 fork 1.70× slower |  |
| `qr_factor/1024x64/b1` | 4.49291 ± 0.175519 (W 0.103488) | 4.46205 ± 0.251847 (W 0.13883) | 0.322474 ± 0.000194844 (W 0.00198415) | · | 🔴 fork 13.93× slower | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 77.023 ± 0.199457 (W 0.743137) | 77.2088 ± 0.530813 (W 0.499318) | 7.34964 ± 0.0318263 (W 0.0426093) | · | 🔴 fork 10.48× slower |  |
| `svd_thin/1024x64/b1` | 3.11762 ± 0.0280925 (W 0.0309581) | 3.13627 ± 0.023443 (W 0.0278467) | 1.67432 ± 0.00360836 (W 0.00891031) | · | 🔴 fork 1.86× slower |  |
| `svd_thin/4096x256/b1` | 50.4142 ± 0.0981878 (W 0.752214) | 50.2898 ± 0.00669844 (W 0.511509) | 36.6719 ± 0.266733 (W 0.0357259) | · | 🔴 fork 1.37× slower |  |
| `svd_values/1024x64/b1` | 2.44742 ± 0.0311552 (W 0.0305931) | 2.47451 ± 0.0137422 (W 0.0288393) | 0.811444 ± 0.00382118 (W 0.00182611) | · | 🔴 fork 3.02× slower |  |
| `svd_values/4096x256/b1` | 37.2713 ± 0.0660933 (W 2.26747) | 37.258 ± 0.0610924 (W 0.138465) | 16.8273 ± 0.192594 (W 0.039299) | · | 🔴 fork 2.21× slower |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729445 ± 0.000488493 (W 0.00246415) | 0.730393 ± 0.0029999 (W 0.00244507) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.4403 ± 0.841221 (W 0.0745133) | 46.3626 ± 0.666441 (W 0.0450415) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.606615 ± 0.00122119 (W 0.00180124) | 0.606291 ± 0.00192188 (W 0.00230466) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.583008 ± 0.00587068 (W 0.00173042) | 0.579842 ± 0.012087 (W 0.00232703) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.7648 ± 0.1236 (W 0.0202357) | 35.7031 ± 0.0736761 (W 0.019492) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.6896 ± 0.249102 (W 0.0210932) | 35.6781 ± 0.22921 (W 0.020213) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.384249 ± 0.000827939 (W 0.00322672) | 0.383586 ± 0.00113157 (W 0.00227225) | 0.289811 ± 0.00161699 (W 0.00208892) | · | 🔴 fork 1.33× slower |  |
| `lu/4096x256/b1` | 13.2472 ± 0.0194209 (W 0.0361706) | 13.23 ± 0.0207453 (W 0.0192408) | 11.7302 ± 0.0114011 (W 0.0200638) | · | 🔴 fork 1.13× slower |  |
| `qr/1024x64/b1` | 1.47148 ± 0.00991522 (W 0.00316963) | 1.46418 ± 0.00469252 (W 0.00236781) | 1.57776 ± 0.00761847 (W 0.00433583) | · | 🔵 fork 1.07× faster |  |
| `qr/4096x256/b1` | 63.8053 ± 0.0805874 (W 0.0496096) | 63.8174 ± 0.0905812 (W 0.396454) | 70.0307 ± 0.177728 (W 0.115183) | · | 🔵 fork 1.10× faster |  |
| `qr_factor/1024x64/b1` | 0.794157 ± 0.00356961 (W 0.00202837) | 0.792704 ± 0.00428551 (W 0.00237979) | 0.765108 ± 0.00242947 (W 0.00129548) | · | · |  |
| `qr_factor/4096x256/b1` | 25.9584 ± 0.0778239 (W 0.0217514) | 25.9704 ± 0.054539 (W 0.0214411) | 28.9248 ± 0.087146 (W 0.0263849) | · | 🔵 fork 1.11× faster |  |
| `svd_thin/1024x64/b1` | 2.46025 ± 0.00487717 (W 0.00417537) | 2.4533 ± 0.00219875 (W 0.00292935) | 2.82323 ± 0.0135183 (W 0.00457759) | · | 🔵 fork 1.15× faster |  |
| `svd_thin/4096x256/b1` | 83.1427 ± 0.212837 (W 0.0554028) | 82.9861 ± 0.205861 (W 0.0578043) | 109.702 ± 0.361209 (W 0.311712) | · | 🔵 fork 1.32× faster |  |
| `svd_values/1024x64/b1` | 1.40087 ± 0.00469921 (W 0.00252098) | 1.39956 ± 0.00233592 (W 0.00241834) | 1.24092 ± 0.00205907 (W 0.00294652) | · | 🔴 fork 1.13× slower |  |
| `svd_values/4096x256/b1` | 39.1496 ± 0.0253587 (W 0.054213) | 39.151 ± 0.0278744 (W 0.408078) | 40.273 ± 0.189884 (W 0.0442545) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.729482 ± 0.00171763 (W 0.00202073) | 0.730487 ± 0.00207045 (W 0.00230641) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.5987 ± 0.0398364 (W 0.22113) | 17.6146 ± 0.149 (W 0.112638) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.179763 ± 0.00400423 (W 0.000944657) | 0.182037 ± 0.0040744 (W 0.00215864) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.201472 ± 0.0115492 (W 0.00134172) | 0.200239 ± 0.0205231 (W 0.00283723) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.9435 ± 0.137156 (W 0.0281993) | 10.9364 ± 0.0654492 (W 0.148736) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.1194 ± 0.0513197 (W 0.0106119) | 11.1148 ± 0.0445401 (W 0.0171872) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.426268 ± 0.00633003 (W 0.00700042) | 0.424692 ± 0.00211676 (W 0.00821516) | 0.286414 ± 0.00171437 (W 0.00221729) | · | 🔴 fork 1.49× slower |  |
| `lu/4096x256/b1` | 7.36324 ± 0.0227469 (W 0.0243149) | 7.36505 ± 0.0199481 (W 0.0483733) | 11.5684 ± 0.0250999 (W 0.0106384) | · | 🔵 fork 1.57× faster |  |
| `qr/1024x64/b1` | 1.60931 ± 0.0131777 (W 0.00816137) | 1.60848 ± 0.0154809 (W 0.012444) | 0.994581 ± 0.00612892 (W 0.00751786) | · | 🔴 fork 1.62× slower |  |
| `qr/4096x256/b1` | 29.615 ± 0.176246 (W 0.0870382) | 29.6283 ± 0.168482 (W 0.0528822) | 26.7925 ± 0.101975 (W 0.259409) | · | 🔴 fork 1.11× slower |  |
| `qr_factor/1024x64/b1` | 1.35354 ± 0.0299969 (W 0.00860556) | 1.34754 ± 0.00624978 (W 0.0164371) | 0.420493 ± 0.00272396 (W 0.00389715) | · | 🔴 fork 3.22× slower |  |
| `qr_factor/4096x256/b1` | 17.5124 ± 0.103002 (W 0.117449) | 17.5339 ± 0.101438 (W 0.118586) | 11.2873 ± 0.0682537 (W 0.0873634) | · | 🔴 fork 1.55× slower |  |
| `svd_thin/1024x64/b1` | 2.69751 ± 0.0208076 (W 0.0162145) | 2.71725 ± 0.0113074 (W 0.0130316) | 1.80935 ± 0.0174029 (W 0.0092791) | · | 🔴 fork 1.49× slower |  |
| `svd_thin/4096x256/b1` | 44.7611 ± 0.0525144 (W 0.139475) | 44.7071 ± 0.138002 (W 0.177234) | 45.3298 ± 0.105549 (W 0.0864968) | · | · |  |
| `svd_values/1024x64/b1` | 1.98849 ± 0.01646 (W 0.012727) | 1.99823 ± 0.013511 (W 0.01682) | 0.910073 ± 0.00847086 (W 0.00712615) | · | 🔴 fork 2.18× slower |  |
| `svd_values/4096x256/b1` | 29.7566 ± 0.0520853 (W 0.123304) | 29.6659 ± 0.210035 (W 0.108951) | 20.847 ± 0.317297 (W 0.048327) | · | 🔴 fork 1.43× slower |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730342 ± 0.00166558 (W 0.001961) | 0.72956 ± 0.00125676 (W 0.00190487) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6954 ± 0.0741157 (W 0.0577893) | 13.6532 ± 0.14947 (W 0.0979397) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.158716 ± 0.00230531 (W 0.00197507) | 0.159668 ± 0.00312549 (W 0.00330839) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.1602 ± 0.00496464 (W 0.00252843) | 0.158347 ± 0.00343167 (W 0.00179686) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.81105 ± 0.0788157 (W 0.164653) | 6.78013 ± 0.063863 (W 0.191607) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.922 ± 0.108794 (W 0.192269) | 7.06906 ± 1.00398 (W 1.05637) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.447928 ± 0.00114449 (W 0.00902739) | 0.446235 ± 0.00264676 (W 0.00833933) | 0.288322 ± 0.000447891 (W 0.00214865) | · | 🔴 fork 1.55× slower |  |
| `lu/4096x256/b1` | 6.70365 ± 0.0122168 (W 0.025188) | 6.7276 ± 0.0308696 (W 0.0180712) | 3.17819 ± 0.0379072 (W 0.00780089) | · | 🔴 fork 2.11× slower |  |
| `qr/1024x64/b1` | 1.89448 ± 0.0418907 (W 0.0165358) | 1.89733 ± 0.0335719 (W 0.0249756) | 0.84972 ± 0.00252172 (W 0.00387201) | · | 🔴 fork 2.23× slower |  |
| `qr/4096x256/b1` | 29.7617 ± 0.213956 (W 0.677025) | 29.7758 ± 0.160957 (W 0.676674) | 19.2447 ± 0.178432 (W 0.0502406) | · | 🔴 fork 1.55× slower |  |
| `qr_factor/1024x64/b1` | 1.65014 ± 0.0281605 (W 0.0236548) | 1.6539 ± 0.0213737 (W 0.018233) | 0.301093 ± 0.000817313 (W 0.00172098) | · | 🔴 fork 5.48× slower |  |
| `qr_factor/4096x256/b1` | 19.2028 ± 0.0922018 (W 0.106268) | 19.1793 ± 0.00270228 (W 0.119852) | 6.45462 ± 0.00776242 (W 0.0286154) | · | 🔴 fork 2.98× slower |  |
| `svd_thin/1024x64/b1` | 3.07615 ± 0.0428172 (W 0.0223709) | 3.10768 ± 0.026009 (W 0.0288415) | 1.63319 ± 0.00613207 (W 0.00658063) | · | 🔴 fork 1.88× slower |  |
| `svd_thin/4096x256/b1` | 44.8121 ± 0.700756 (W 0.614923) | 44.8675 ± 0.227393 (W 0.392326) | 34.1226 ± 0.0354809 (W 0.058356) | · | 🔴 fork 1.31× slower |  |
| `svd_values/1024x64/b1` | 2.36599 ± 0.0309266 (W 0.0315159) | 2.40265 ± 0.0163984 (W 0.0332305) | 0.784464 ± 0.000503617 (W 0.00287096) | · | 🔴 fork 3.02× slower |  |
| `svd_values/4096x256/b1` | 31.7088 ± 0.0776925 (W 0.207369) | 31.7681 ± 0.199418 (W 0.278377) | 15.5761 ± 0.244781 (W 0.0506792) | · | 🔴 fork 2.04× slower |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.82582 ± 0.0297775 (W 0.00285191) | 1.82728 ± 0.0192539 (W 0.00347023) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 155.023 ± 0.619081 (W 1.29593) | 155.952 ± 0.962506 (W 0.809515) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.24486 ± 0.0256911 (W 0.00169178) | 2.24563 ± 0.0279847 (W 0.0038636) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.22892 ± 0.00118273 (W 0.00247611) | 2.23018 ± 0.00245744 (W 0.00183079) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.896 ± 0.245183 (W 0.0736711) | 138.001 ± 0.149907 (W 0.0663188) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.014 ± 0.239944 (W 0.103073) | 138.149 ± 0.194918 (W 0.197496) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.01683 ± 0.00263284 (W 0.0024877) | 1.02619 ± 0.00498064 (W 0.00836319) | 1.19276 ± 0.0026827 (W 0.00277582) | · | 🔵 fork 1.17× faster |  |
| `lu/4096x256/b1` | 53.8703 ± 0.0907608 (W 0.0769017) | 54.0004 ± 0.0454444 (W 0.0554089) | 65.6621 ± 4.74204 (W 0.546503) | · | 🔵 fork 1.22× faster | `!` between-start range over 5% |
| `qr/1024x64/b1` | 4.74171 ± 0.0113137 (W 0.0038392) | 4.74058 ± 0.0192539 (W 0.00299196) | 5.11761 ± 0.0490561 (W 0.00389392) | · | 🔵 fork 1.08× faster |  |
| `qr/4096x256/b1` | 255.266 ± 0.317353 (W 0.214203) | 255.333 ± 0.410827 (W 0.373487) | 236.236 ± 4.22956 (W 0.397074) | · | 🔴 fork 1.08× slower |  |
| `qr_factor/1024x64/b1` | 4.01771 ± 0.163148 (W 0.0159371) | 4.06557 ± 0.169121 (W 0.0161415) | 2.41441 ± 0.0226839 (W 0.00464639) | · | 🔴 fork 1.66× slower | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 176.307 ± 0.40413 (W 0.327893) | 177.394 ± 0.475954 (W 0.143148) | 110.12 ± 0.267293 (W 0.51078) | · | 🔴 fork 1.60× slower |  |
| `svd_thin/1024x64/b1` | 5.99491 ± 0.0236258 (W 0.00276472) | 6.0101 ± 0.023063 (W 0.0170398) | 8.75458 ± 0.0423469 (W 0.0194988) | · | 🔵 fork 1.46× faster |  |
| `svd_thin/4096x256/b1` | 281.2 ± 0.0997888 (W 1.04573) | 281.159 ± 0.283387 (W 0.507606) | 378.862 ± 0.40828 (W 0.433003) | · | 🔵 fork 1.35× faster |  |
| `svd_values/1024x64/b1` | 3.07524 ± 0.0198123 (W 0.00391422) | 3.0798 ± 0.0146445 (W 0.00242997) | 3.8082 ± 0.0228198 (W 0.00410841) | · | 🔵 fork 1.24× faster |  |
| `svd_values/4096x256/b1` | 123.935 ± 1.35855 (W 0.716766) | 123.957 ± 1.70768 (W 0.459716) | 143.967 ± 0.48917 (W 0.469167) | · | 🔵 fork 1.16× faster |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.82126 ± 0.0340029 (W 0.0038119) | 1.77882 ± 0.0258044 (W 0.0034458) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 65.1318 ± 0.857104 (W 1.10431) | 64.8125 ± 0.814941 (W 0.774928) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.582803 ± 0.00958615 (W 0.00196966) | 0.585738 ± 0.0086859 (W 0.0149338) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.587587 ± 0.00709392 (W 0.00183255) | 0.587937 ± 0.00756251 (W 0.00198101) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 36.9322 ± 0.269864 (W 0.158059) | 37.0418 ± 0.215258 (W 0.0710649) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 36.9506 ± 0.228784 (W 0.0364699) | 36.9771 ± 0.242176 (W 0.0141447) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.81783 ± 0.0103735 (W 0.00907823) | 0.832894 ± 0.00985258 (W 0.00993959) | 1.09526 ± 0.00767341 (W 0.00244775) | · | 🔵 fork 1.34× faster |  |
| `lu/4096x256/b1` | 29.6774 ± 0.0721661 (W 0.0923344) | 29.9246 ± 0.0231652 (W 0.0689313) | 58.9735 ± 3.51603 (W 0.180943) | · | 🔵 fork 1.99× faster | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.98728 ± 0.0322755 (W 0.0188912) | 2.99443 ± 0.00110181 (W 0.0102887) | 3.11453 ± 0.00645859 (W 0.0314096) | · | · |  |
| `qr/4096x256/b1` | 98.4496 ± 0.0237635 (W 0.349681) | 98.447 ± 0.167141 (W 0.0937219) | 79.8469 ± 0.509838 (W 0.405803) | · | 🔴 fork 1.23× slower |  |
| `qr_factor/1024x64/b1` | 4.5204 ± 0.165636 (W 0.0960881) | 4.67048 ± 0.21422 (W 0.0520427) | 1.3896 ± 0.00212758 (W 0.00354822) | · | 🔴 fork 3.25× slower | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 124.031 ± 0.732108 (W 0.554916) | 124.278 ± 0.246744 (W 0.447881) | 33.8873 ± 0.0134198 (W 0.137146) | · | 🔴 fork 3.66× slower |  |
| `svd_thin/1024x64/b1` | 4.33692 ± 0.0218829 (W 0.00970096) | 4.37481 ± 0.0290794 (W 0.0608595) | 5.50178 ± 0.0227148 (W 0.00995189) | · | 🔵 fork 1.27× faster |  |
| `svd_thin/4096x256/b1` | 122.469 ± 0.148565 (W 0.374105) | 122.498 ± 0.0675118 (W 0.29963) | 140.713 ± 0.545117 (W 0.443712) | · | 🔵 fork 1.15× faster |  |
| `svd_values/1024x64/b1` | 3.00306 ± 0.00982919 (W 0.0179562) | 3.01301 ± 0.0148012 (W 0.0319295) | 2.85704 ± 0.0459839 (W 0.0100643) | · | · |  |
| `svd_values/4096x256/b1` | 75.086 ± 0.135777 (W 0.0837209) | 75.2695 ± 0.17216 (W 0.268726) | 51.5608 ± 0.409097 (W 0.286239) | · | 🔴 fork 1.46× slower |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.81551 ± 0.0254668 (W 0.00512165) | 1.82774 ± 0.0336454 (W 0.00624791) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 41.444 ± 0.862188 (W 0.415174) | 41.0436 ± 0.902422 (W 0.159985) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.407852 ± 0.00401483 (W 0.00206382) | 0.411317 ± 0.00310561 (W 0.00337187) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.410388 ± 0.00243312 (W 0.00329845) | 0.413281 ± 0.00185896 (W 0.00318566) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 18.728 ± 0.0667132 (W 0.180195) | 18.8199 ± 0.098289 (W 3.78939) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 18.8087 ± 0.101222 (W 3.63767) | 18.8676 ± 0.198832 (W 3.67932) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.791961 ± 0.00991612 (W 0.00454062) | 0.814189 ± 0.00558434 (W 0.00771052) | 1.08458 ± 0.003925 (W 0.0018257) | · | 🔵 fork 1.37× faster |  |
| `lu/4096x256/b1` | 25.803 ± 0.00707483 (W 0.0654531) | 25.9955 ± 0.0602005 (W 0.0334641) | 57.4587 ± 3.21774 (W 0.229098) | · | 🔵 fork 2.23× faster | `!` between-start range over 5% |
| `qr/1024x64/b1` | 3.19476 ± 0.00622416 (W 0.0266501) | 3.20368 ± 0.0145026 (W 0.0183024) | 2.31659 ± 0.00289774 (W 0.00439421) | · | 🔴 fork 1.38× slower |  |
| `qr/4096x256/b1` | 81.7866 ± 0.0904486 (W 0.843873) | 81.9016 ± 0.124156 (W 0.389879) | 45.9648 ± 0.274497 (W 0.112418) | · | 🔴 fork 1.78× slower |  |
| `qr_factor/1024x64/b1` | 4.8924 ± 0.156279 (W 0.0877426) | 4.94374 ± 0.167789 (W 0.149364) | 0.871827 ± 0.000357769 (W 0.00155448) | · | 🔴 fork 5.61× slower | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 120.775 ± 0.159846 (W 0.611314) | 122.61 ± 41.5033 (W 12.5506) | 19.7448 ± 0.018972 (W 0.14865) | · | 🔴 fork 6.12× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/1024x64/b1` | 4.62047 ± 0.0194197 (W 0.0186737) | 4.64099 ± 0.0189969 (W 0.0321928) | 4.46946 ± 0.0121946 (W 0.00465125) | · | · |  |
| `svd_thin/4096x256/b1` | 106.999 ± 1.15868 (W 1.22365) | 105.351 ± 0.206059 (W 0.219755) | 77.5551 ± 3.4293 (W 0.219599) | · | 🔴 fork 1.38× slower | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 3.34515 ± 0.0269452 (W 0.0241358) | 3.35514 ± 0.0316138 (W 0.0295285) | 2.3581 ± 0.047113 (W 0.00291523) | · | 🔴 fork 1.42× slower |  |
| `svd_values/4096x256/b1` | 72.5384 ± 0.712182 (W 0.773247) | 72.7791 ± 0.780685 (W 0.521346) | 34.3348 ± 0.114311 (W 0.152927) | · | 🔴 fork 2.11× slower |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66438 ± 0.00189387 (W 0.00197751) | 1.67172 ± 0.00694637 (W 0.00262774) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 142.581 ± 0.240512 (W 0.504276) | 142.879 ± 0.377413 (W 0.530983) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26472 ± 0.010282 (W 0.00232666) | 2.26353 ± 0.0136545 (W 0.00329863) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.27903 ± 0.0123418 (W 0.00399012) | 2.2688 ± 0.0152885 (W 0.00179484) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.516 ± 0.0554885 (W 0.0758887) | 138.498 ± 0.126564 (W 0.0970317) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.666 ± 0.182291 (W 0.344183) | 138.669 ± 0.200521 (W 0.0680885) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.880859 ± 0.00858612 (W 0.00979658) | 0.890666 ± 0.0022162 (W 0.00151802) | 1.06632 ± 0.0178419 (W 0.0035362) | · | 🔵 fork 1.21× faster |  |
| `lu/4096x256/b1` | 41.7296 ± 0.0210937 (W 0.0471244) | 41.8444 ± 0.0682645 (W 0.0327539) | 51.2332 ± 0.109826 (W 0.290832) | · | 🔵 fork 1.23× faster |  |
| `qr/1024x64/b1` | 4.60331 ± 0.0177953 (W 0.00434908) | 4.61055 ± 0.0248799 (W 0.00270237) | 4.84358 ± 0.0452403 (W 0.00399172) | · | 🔵 fork 1.05× faster |  |
| `qr/4096x256/b1` | 244.193 ± 0.382469 (W 0.460065) | 243.906 ± 0.383308 (W 0.375494) | 217.334 ± 0.36549 (W 0.532381) | · | 🔴 fork 1.12× slower |  |
| `qr_factor/1024x64/b1` | 2.26545 ± 0.0182313 (W 0.00206992) | 2.26992 ± 0.0189695 (W 0.0019908) | 2.24073 ± 0.00528449 (W 0.00405219) | · | · |  |
| `qr_factor/4096x256/b1` | 90.1956 ± 0.0462766 (W 0.0787097) | 90.2462 ± 0.100357 (W 0.0677055) | 104.401 ± 0.168719 (W 0.425082) | · | 🔵 fork 1.16× faster |  |
| `svd_thin/1024x64/b1` | 5.89366 ± 0.0244855 (W 0.0072816) | 5.89862 ± 0.0242787 (W 0.0038303) | 8.48684 ± 0.0709713 (W 0.0105171) | · | 🔵 fork 1.44× faster |  |
| `svd_thin/4096x256/b1` | 269.047 ± 0.322248 (W 0.122895) | 268.864 ± 0.298887 (W 0.382635) | 371.184 ± 6.70345 (W 1.06747) | · | 🔵 fork 1.38× faster |  |
| `svd_values/1024x64/b1` | 2.95899 ± 0.0210178 (W 0.00475276) | 2.95891 ± 0.0188986 (W 0.00337887) | 3.64656 ± 0.0341 (W 0.00352469) | · | 🔵 fork 1.23× faster |  |
| `svd_values/4096x256/b1` | 110.235 ± 0.166303 (W 0.0943148) | 110.241 ± 0.194616 (W 0.10078) | 142.844 ± 1.574 (W 0.21137) | · | 🔵 fork 1.30× faster |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6566 ± 0.00186926 (W 0.00188589) | 1.65608 ± 0.00686552 (W 0.00336868) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.6284 ± 0.369019 (W 0.263335) | 52.8174 ± 0.203613 (W 0.504109) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.629027 ± 0.0066828 (W 0.00193652) | 0.627885 ± 0.00688232 (W 0.00266658) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.64832 ± 0.00519009 (W 0.00201741) | 0.649913 ± 0.0064716 (W 0.00458612) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.5247 ± 0.0908983 (W 0.0765428) | 39.5452 ± 0.154556 (W 0.103757) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.7002 ± 0.0867659 (W 0.0749618) | 39.7176 ± 0.0916455 (W 0.0524094) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.717122 ± 0.00373574 (W 0.0137731) | 0.725969 ± 0.00317662 (W 0.00507112) | 1.06182 ± 0.00651017 (W 0.00238005) | · | 🔵 fork 1.48× faster |  |
| `lu/4096x256/b1` | 17.4119 ± 0.0836293 (W 0.0789862) | 17.6101 ± 0.0658124 (W 0.0892806) | 49.5704 ± 0.517392 (W 0.0672039) | · | 🔵 fork 2.85× faster |  |
| `qr/1024x64/b1` | 2.86319 ± 0.0147307 (W 0.0211582) | 2.85683 ± 0.0213248 (W 0.0108346) | 3.03648 ± 0.00121039 (W 0.00338154) | · | 🔵 fork 1.06× faster |  |
| `qr/4096x256/b1` | 86.3886 ± 0.206166 (W 0.20149) | 86.3355 ± 0.230396 (W 0.165585) | 74.2902 ± 0.222053 (W 0.519648) | · | 🔴 fork 1.16× slower |  |
| `qr_factor/1024x64/b1` | 2.13057 ± 0.0159306 (W 0.0147175) | 2.09381 ± 0.00274075 (W 0.0240478) | 1.36096 ± 0.00930617 (W 0.00229481) | · | 🔴 fork 1.57× slower |  |
| `qr_factor/4096x256/b1` | 44.0078 ± 0.0488327 (W 0.0516667) | 44.1086 ± 0.0595256 (W 0.0547886) | 31.0494 ± 0.346571 (W 0.111796) | · | 🔴 fork 1.42× slower |  |
| `svd_thin/1024x64/b1` | 4.26849 ± 0.0439323 (W 0.0235638) | 4.27326 ± 0.0216096 (W 0.0331203) | 5.39672 ± 0.0192868 (W 0.011895) | · | 🔵 fork 1.26× faster |  |
| `svd_thin/4096x256/b1` | 110.557 ± 0.156263 (W 0.169857) | 110.711 ± 0.0730995 (W 0.291756) | 129.488 ± 1.2538 (W 0.332037) | · | 🔵 fork 1.17× faster |  |
| `svd_values/1024x64/b1` | 2.90966 ± 0.0088394 (W 0.0162843) | 2.92453 ± 0.0189284 (W 0.018045) | 2.79237 ± 0.0147183 (W 0.00251588) | · | · |  |
| `svd_values/4096x256/b1` | 62.996 ± 0.115903 (W 0.0722238) | 63.2244 ± 0.228512 (W 0.0759992) | 48.6668 ± 0.213716 (W 0.0769957) | · | 🔴 fork 1.29× slower |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66586 ± 0.00526108 (W 0.00519863) | 1.66634 ± 0.00990683 (W 0.00309438) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.3601 ± 0.312087 (W 0.912861) | 28.9932 ± 0.357736 (W 0.276046) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.440853 ± 0.00498076 (W 0.00488941) | 0.440404 ± 0.000167727 (W 0.004505) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.45577 ± 0.00679313 (W 0.00485875) | 0.457104 ± 0.00863184 (W 0.00658439) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.3725 ± 0.223399 (W 3.32717) | 21.5155 ± 3.97129 (W 3.43874) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.4461 ± 0.22702 (W 3.31707) | 21.142 ± 0.279635 (W 3.12306) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.698153 ± 0.00546378 (W 0.0147025) | 0.706181 ± 0.00689148 (W 0.0121567) | 1.05596 ± 0.00679804 (W 0.00229272) | · | 🔵 fork 1.51× faster |  |
| `lu/4096x256/b1` | 13.5818 ± 0.0512095 (W 0.0420205) | 13.7462 ± 0.0449637 (W 0.0583047) | 49.6237 ± 0.509147 (W 0.102991) | · | 🔵 fork 3.65× faster |  |
| `qr/1024x64/b1` | 3.08817 ± 0.0178109 (W 0.017992) | 3.12177 ± 0.00318181 (W 0.02242) | 2.27768 ± 0.000711085 (W 0.00337225) | · | 🔴 fork 1.36× slower |  |
| `qr/4096x256/b1` | 69.3889 ± 0.843477 (W 0.972146) | 69.3776 ± 0.0265151 (W 0.360303) | 42.1214 ± 0.325828 (W 0.204447) | · | 🔴 fork 1.65× slower |  |
| `qr_factor/1024x64/b1` | 2.41122 ± 0.0194327 (W 0.0182076) | 2.43432 ± 0.0244491 (W 0.0202935) | 0.851903 ± 0.00114427 (W 0.00159615) | · | 🔴 fork 2.83× slower |  |
| `qr_factor/4096x256/b1` | 41.2958 ± 0.077288 (W 0.121351) | 41.3587 ± 0.0324606 (W 0.523139) | 17.6538 ± 0.0499269 (W 0.09432) | · | 🔴 fork 2.34× slower |  |
| `svd_thin/1024x64/b1` | 4.50361 ± 0.0318049 (W 0.0411922) | 4.49703 ± 0.00918803 (W 0.0358703) | 4.39595 ± 0.0232217 (W 0.00551156) | · | · |  |
| `svd_thin/4096x256/b1` | 92.933 ± 0.216785 (W 0.378204) | 93.24 ± 0.146956 (W 0.428793) | 73.8198 ± 0.195164 (W 0.279596) | · | 🔴 fork 1.26× slower |  |
| `svd_values/1024x64/b1` | 3.2691 ± 0.0242681 (W 0.0267759) | 3.24823 ± 0.0160044 (W 0.0505238) | 2.29979 ± 0.00335753 (W 0.00282993) | · | 🔴 fork 1.42× slower |  |
| `svd_values/4096x256/b1` | 60.8377 ± 0.151093 (W 0.117877) | 60.9667 ± 0.0457803 (W 0.128522) | 32.4919 ± 0.0809069 (W 0.106054) | · | 🔴 fork 1.87× slower |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 78.0639 ± 1.10467 (W 0.374538) | 76.8592 ± 1.34892 (W 0.211368) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.25913 ± 0.00893158 (W 0.0017382) | 1.26524 ± 0.0177864 (W 0.00167364) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.0243 ± 0.171464 (W 0.0277252) | 18.0516 ± 0.433297 (W 0.0500059) | 76.9308 ± 0.815522 (W 1.23938) | · | 🔵 fork 4.27× faster |  |
| `lu/64x1024/b1` | 0.511051 ± 0.00211457 (W 0.00245233) | 0.510961 ± 0.00104635 (W 0.00316943) | 0.921274 ± 0.133333 (W 0.003629) | · | 🔵 fork 1.80× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 32.1891 ± 0.137581 (W 0.101628) | 32.2348 ± 0.0699428 (W 0.0879734) | 66.1079 ± 0.879847 (W 1.1789) | · | 🔵 fork 2.05× faster |  |
| `qr/64x1024/b1` | 0.836034 ± 0.0181096 (W 0.00207584) | 0.838288 ± 0.0196169 (W 0.00247505) | 1.51346 ± 0.0121041 (W 0.0100254) | · | 🔵 fork 1.81× faster |  |
| `qr_factor/256x4096/b1` | 26.9412 ± 0.170512 (W 0.0355718) | 27.7762 ± 0.378422 (W 0.0452695) | 58.8271 ± 0.767171 (W 0.112917) | · | 🔵 fork 2.18× faster |  |
| `qr_factor/64x1024/b1` | 0.994213 ± 0.00231188 (W 0.00351032) | 1.0157 ± 0.00169497 (W 0.00482416) | 1.34226 ± 0.00207031 (W 0.00211756) | · | 🔵 fork 1.35× faster |  |
| `svd_thin/256x4096/b1` | 82.8287 ± 0.167859 (W 0.048721) | 82.6103 ± 0.114872 (W 0.040135) | 240.398 ± 3.23242 (W 1.0549) | · | 🔵 fork 2.90× faster |  |
| `svd_thin/64x1024/b1` | 2.45325 ± 0.00567138 (W 0.00430031) | 2.44665 ± 0.00192602 (W 0.0023117) | 4.12868 ± 0.01131 (W 0.0104034) | · | 🔵 fork 1.68× faster |  |
| `svd_values/256x4096/b1` | 39.1417 ± 0.0456471 (W 0.0360126) | 39.1321 ± 0.0715527 (W 0.0429134) | 172.687 ± 0.584864 (W 0.680223) | · | 🔵 fork 4.41× faster |  |
| `svd_values/64x1024/b1` | 1.41206 ± 0.00334626 (W 0.003717) | 1.41028 ± 0.0031313 (W 0.0027802) | 2.62374 ± 0.0149706 (W 0.0060145) | · | 🔵 fork 1.86× faster |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 39.9642 ± 0.171944 (W 0.382713) | 40.1369 ± 0.162794 (W 0.325585) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.24066 ± 0.00668417 (W 0.00424462) | 1.25212 ± 0.0159361 (W 0.00395214) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 9.22377 ± 0.194987 (W 0.0343041) | 9.12045 ± 0.23481 (W 0.0485387) | 10.0245 ± 0.139494 (W 0.101259) | · | 🔵 fork 1.09× faster |  |
| `lu/64x1024/b1` | 0.383317 ± 0.0291152 (W 0.0113799) | 0.397064 ± 0.0102699 (W 0.0207319) | 0.295862 ± 0.00450812 (W 0.00161066) | · | 🔴 fork 1.30× slower | `!` between-start range over 5% |
| `qr/256x4096/b1` | 14.2344 ± 0.0374191 (W 0.37589) | 14.1329 ± 0.442957 (W 0.0543062) | 16.7386 ± 0.203543 (W 0.178363) | · | 🔵 fork 1.18× faster | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.78585 ± 0.011572 (W 0.0133496) | 0.781612 ± 0.0110555 (W 0.00998875) | 0.626811 ± 0.0128129 (W 0.0134894) | · | 🔴 fork 1.25× slower |  |
| `qr_factor/256x4096/b1` | 12.0882 ± 0.231372 (W 0.0566801) | 12.1943 ± 0.298137 (W 0.0568616) | 13.3731 ± 0.0873172 (W 0.0114293) | · | 🔵 fork 1.11× faster |  |
| `qr_factor/64x1024/b1` | 0.904939 ± 0.00926786 (W 0.00706007) | 0.90632 ± 0.00486231 (W 0.012915) | 0.428455 ± 0.00229808 (W 0.00194633) | · | 🔴 fork 2.11× slower |  |
| `svd_thin/256x4096/b1` | 44.722 ± 0.438988 (W 0.247474) | 44.7845 ± 0.166945 (W 0.111117) | 121.653 ± 1.7628 (W 0.699343) | · | 🔵 fork 2.72× faster |  |
| `svd_thin/64x1024/b1` | 2.73101 ± 0.00347332 (W 0.0230587) | 2.72155 ± 0.0139895 (W 0.0119253) | 3.04275 ± 0.00848432 (W 0.00487988) | · | 🔵 fork 1.11× faster |  |
| `svd_values/256x4096/b1` | 29.6035 ± 0.0349592 (W 0.135251) | 29.671 ± 0.0659129 (W 0.212458) | 90.4885 ± 1.74455 (W 0.374519) | · | 🔵 fork 3.06× faster |  |
| `svd_values/64x1024/b1` | 2.02426 ± 0.00702948 (W 0.0294991) | 2.01438 ± 0.0127539 (W 0.0146476) | 2.1012 ± 0.0116565 (W 0.0069856) | · | · |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.2078 ± 0.049084 (W 0.178449) | 35.2651 ± 0.436766 (W 0.138185) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.23857 ± 0.0190527 (W 0.00341675) | 1.2569 ± 0.00656492 (W 0.00274726) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.98837 ± 0.0913507 (W 0.0670567) | 7.88028 ± 0.0643993 (W 0.133407) | 6.86768 ± 1.59588 (W 0.0302728) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.376163 ± 0.0286513 (W 0.0186729) | 0.368878 ± 0.0206053 (W 0.0222464) | 0.170689 ± 0.00296695 (W 0.00116937) | · | 🔴 fork 2.20× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 13.2689 ± 0.148856 (W 0.287043) | 13.2988 ± 0.14322 (W 0.199187) | 10.2114 ± 0.0277893 (W 0.169378) | · | 🔴 fork 1.30× slower |  |
| `qr/64x1024/b1` | 0.91389 ± 0.00824132 (W 0.0138936) | 0.913529 ± 0.00594812 (W 0.0185847) | 0.45165 ± 0.0123733 (W 0.0133114) | · | 🔴 fork 2.02× slower | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 11.0474 ± 0.0406476 (W 0.283511) | 11.7955 ± 0.10074 (W 0.499931) | 6.95949 ± 0.27192 (W 0.00882823) | 🔵 fork 1.07× faster | 🔴 fork 1.59× slower | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 1.12164 ± 0.0267212 (W 0.0287909) | 1.13873 ± 0.0256259 (W 0.0154544) | 0.256406 ± 0.0023505 (W 0.00136361) | · | 🔴 fork 4.37× slower |  |
| `svd_thin/256x4096/b1` | 44.4469 ± 0.324158 (W 0.299251) | 44.8106 ± 1.02987 (W 1.12004) | 101.132 ± 1.23022 (W 0.271943) | · | 🔵 fork 2.28× faster |  |
| `svd_thin/64x1024/b1` | 3.07493 ± 0.0183851 (W 0.0361387) | 3.10544 ± 0.0117977 (W 0.0265967) | 2.9155 ± 0.00060027 (W 0.00720308) | · | 🔴 fork 1.05× slower |  |
| `svd_values/256x4096/b1` | 31.6784 ± 0.231117 (W 0.161163) | 31.5915 ± 0.0747745 (W 0.0941596) | 78.4147 ± 0.377348 (W 0.450636) | · | 🔵 fork 2.48× faster |  |
| `svd_values/64x1024/b1` | 2.43237 ± 0.0194423 (W 0.0331913) | 2.38265 ± 0.0251859 (W 0.0294331) | 2.08308 ± 0.0151515 (W 0.003922) | · | 🔴 fork 1.17× slower |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 72.8076 ± 0.833081 (W 0.44548) | 72.2623 ± 1.14266 (W 0.0739773) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.056 ± 0.0041366 (W 0.00151429) | 1.05827 ± 0.00755868 (W 0.00194197) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2226 ± 0.0262003 (W 0.017685) | 13.2365 ± 0.0463856 (W 0.0116098) | 210.15 ± 0.362563 (W 0.0997416) | · | 🔵 fork 15.89× faster |  |
| `lu/64x1024/b1` | 0.312082 ± 0.00107666 (W 0.00267292) | 0.312122 ± 0.00171644 (W 0.0018415) | 3.12776 ± 0.00223584 (W 0.00355249) | · | 🔵 fork 10.02× faster |  |
| `qr/256x4096/b1` | 27.4416 ± 0.242317 (W 0.0788213) | 27.5702 ± 0.329061 (W 0.0554142) | 66.632 ± 0.790716 (W 0.176456) | · | 🔵 fork 2.43× faster |  |
| `qr/64x1024/b1` | 0.626842 ± 0.00128497 (W 0.0022834) | 0.629138 ± 0.000361929 (W 0.00324812) | 1.41928 ± 0.068155 (W 0.00180105) | · | 🔵 fork 2.26× faster | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 25.5134 ± 0.348122 (W 0.0536891) | 25.805 ± 0.125777 (W 0.123028) | 52.3022 ± 0.685413 (W 0.50099) | · | 🔵 fork 2.05× faster |  |
| `qr_factor/64x1024/b1` | 0.563123 ± 0.000801587 (W 0.00326138) | 0.563287 ± 0.00127023 (W 0.00222432) | 6.29989 ± 0.00148139 (W 0.00359147) | · | 🔵 fork 11.19× faster |  |
| `svd_thin/256x4096/b1` | 88.1825 ± 0.110501 (W 0.0550514) | 87.9135 ± 0.0549887 (W 0.0952496) | 229.684 ± 10.2044 (W 3.4367) | · | 🔵 fork 2.60× faster | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.51211 ± 0.00187433 (W 0.00139389) | 2.50967 ± 0.00270261 (W 0.002811) | 3.94532 ± 0.0327943 (W 0.00567563) | · | 🔵 fork 1.57× faster |  |
| `svd_values/256x4096/b1` | 44.8294 ± 0.0115293 (W 0.032523) | 44.8545 ± 0.0225741 (W 0.0301486) | 165.49 ± 1.46594 (W 1.84174) | · | 🔵 fork 3.69× faster |  |
| `svd_values/64x1024/b1` | 1.47262 ± 0.00241376 (W 0.00537637) | 1.47574 ± 0.0132211 (W 0.00356016) | 2.49665 ± 0.0120245 (W 0.00572674) | · | 🔵 fork 1.70× faster |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.073 ± 0.165492 (W 0.142471) | 34.9641 ± 0.254947 (W 0.179353) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04782 ± 0.0113905 (W 0.00810516) | 1.05448 ± 0.0102635 (W 0.00277936) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.6472 ± 0.0197364 (W 0.0230468) | 4.64454 ± 0.063745 (W 0.0229766) | 5.28104 ± 0.0159044 (W 0.0144871) | · | 🔵 fork 1.14× faster |  |
| `lu/64x1024/b1` | 0.169287 ± 0.0024565 (W 0.00479266) | 0.171125 ± 0.00308915 (W 0.00458619) | 0.237013 ± 0.00514774 (W 0.00321305) | · | 🔵 fork 1.40× faster |  |
| `qr/256x4096/b1` | 9.44581 ± 0.0703649 (W 0.0378767) | 9.6058 ± 0.037386 (W 0.0462132) | 24.3907 ± 1.3408 (W 0.0626238) | · | 🔵 fork 2.58× faster | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.556141 ± 0.00565571 (W 0.00943126) | 0.561737 ± 0.00319064 (W 0.00444226) | 0.6095 ± 0.0467429 (W 0.00393872) | · | 🔵 fork 1.10× faster | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 8.46658 ± 0.0774414 (W 0.0531627) | 8.52111 ± 0.0865549 (W 0.0363059) | 11.3769 ± 0.0467175 (W 0.0113358) | · | 🔵 fork 1.34× faster |  |
| `qr_factor/64x1024/b1` | 0.477828 ± 0.00268396 (W 0.00749221) | 0.489149 ± 0.00811013 (W 0.00488289) | 0.366587 ± 0.00110285 (W 0.00128838) | · | 🔴 fork 1.30× slower |  |
| `svd_thin/256x4096/b1` | 50.7297 ± 0.277604 (W 0.187786) | 50.5199 ± 0.215031 (W 0.182914) | 113.455 ± 0.185712 (W 0.184152) | · | 🔵 fork 2.24× faster |  |
| `svd_thin/64x1024/b1` | 2.7636 ± 0.00408217 (W 0.0309992) | 2.77477 ± 0.027939 (W 0.021315) | 2.93577 ± 0.0187474 (W 0.0174121) | · | 🔵 fork 1.06× faster |  |
| `svd_values/256x4096/b1` | 35.3786 ± 0.144868 (W 0.122185) | 35.4428 ± 0.0973797 (W 0.124759) | 87.8451 ± 0.800408 (W 0.0894552) | · | 🔵 fork 2.48× faster |  |
| `svd_values/64x1024/b1` | 2.07024 ± 0.00846266 (W 0.0335773) | 2.10148 ± 0.0316455 (W 0.0287499) | 2.04896 ± 0.0200887 (W 0.00251777) | · | · |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.2831 ± 0.142699 (W 0.105321) | 30.2443 ± 0.124513 (W 0.129344) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.06777 ± 0.0041499 (W 0.0032468) | 1.059 ± 0.00395223 (W 0.00239707) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 3.33572 ± 0.0237294 (W 0.117269) | 3.31725 ± 0.0197697 (W 0.0960262) | 3.13866 ± 0.0290182 (W 0.00705811) | · | 🔴 fork 1.06× slower |  |
| `lu/64x1024/b1` | 0.151187 ± 0.00170436 (W 0.0057905) | 0.155606 ± 0.00466547 (W 0.00621413) | 0.13188 ± 0.000601572 (W 0.00176458) | · | 🔴 fork 1.15× slower | `!` between-start range over 5% |
| `qr/256x4096/b1` | 8.5816 ± 0.289477 (W 0.255638) | 8.70333 ± 0.146799 (W 0.199427) | 18.927 ± 0.16136 (W 0.0565625) | · | 🔵 fork 2.21× faster | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.721015 ± 0.00980454 (W 0.0201213) | 0.718249 ± 0.00820165 (W 0.0270522) | 0.47572 ± 0.00182406 (W 0.00258737) | · | 🔴 fork 1.52× slower |  |
| `qr_factor/256x4096/b1` | 7.19124 ± 0.067278 (W 0.167269) | 7.34089 ± 0.0482939 (W 0.198762) | 5.88771 ± 0.019245 (W 0.00911189) | · | 🔴 fork 1.22× slower |  |
| `qr_factor/64x1024/b1` | 0.6371 ± 0.00129091 (W 0.0221372) | 0.649753 ± 0.0148322 (W 0.0267268) | 0.214957 ± 0.0016838 (W 0.0025235) | · | 🔴 fork 2.96× slower |  |
| `svd_thin/256x4096/b1` | 50.2778 ± 0.280474 (W 0.444144) | 49.7465 ± 0.40519 (W 0.489969) | 98.7178 ± 1.11543 (W 0.52226) | · | 🔵 fork 1.96× faster |  |
| `svd_thin/64x1024/b1` | 3.15268 ± 0.0103416 (W 0.0197384) | 3.15211 ± 0.0127822 (W 0.0312044) | 2.8065 ± 0.0122264 (W 0.00589135) | · | 🔴 fork 1.12× slower |  |
| `svd_values/256x4096/b1` | 37.2597 ± 0.0400123 (W 0.207163) | 37.2927 ± 0.10352 (W 0.17393) | 76.373 ± 1.45033 (W 0.307732) | · | 🔵 fork 2.05× faster |  |
| `svd_values/64x1024/b1` | 2.49111 ± 0.0232729 (W 0.0230487) | 2.43719 ± 0.0182902 (W 0.0405593) | 2.01497 ± 0.0225043 (W 0.0039254) | · | 🔴 fork 1.24× slower |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 223.95 ± 6.46904 (W 0.403583) | 221.689 ± 7.54355 (W 0.919255) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.52176 ± 0.0610392 (W 0.0148774) | 2.51827 ± 0.0166855 (W 0.00885646) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.7712 ± 0.0676344 (W 0.0640552) | 46.7872 ± 0.239251 (W 0.124832) | 88.6208 ± 0.309782 (W 0.182304) | · | 🔵 fork 1.89× faster |  |
| `lu/64x1024/b1` | 1.05333 ± 0.00297279 (W 0.00383697) | 1.05435 ± 0.00297016 (W 0.00482341) | 2.28855 ± 0.0358085 (W 0.0031949) | · | 🔵 fork 2.17× faster |  |
| `qr/256x4096/b1` | 107.435 ± 0.0576277 (W 0.46834) | 107.65 ± 0.288189 (W 0.339019) | 178.318 ± 2.79355 (W 2.27788) | · | 🔵 fork 1.66× faster |  |
| `qr/64x1024/b1` | 2.63096 ± 0.00113704 (W 0.00282743) | 2.63072 ± 0.000589137 (W 0.00290471) | 3.83937 ± 0.0176063 (W 0.0026007) | · | 🔵 fork 1.46× faster |  |
| `qr_factor/256x4096/b1` | 96.5169 ± 0.120309 (W 0.0841536) | 97.2346 ± 0.132023 (W 0.417624) | 156.709 ± 0.821814 (W 0.10509) | · | 🔵 fork 1.62× faster |  |
| `qr_factor/64x1024/b1` | 2.57449 ± 0.0192322 (W 0.00383849) | 2.60948 ± 0.0121952 (W 0.00333733) | 3.53231 ± 0.0579281 (W 0.00356542) | · | 🔵 fork 1.37× faster |  |
| `svd_thin/256x4096/b1` | 269.341 ± 0.1357 (W 2.99181) | 269.462 ± 0.136688 (W 0.39042) | 539.88 ± 3.86607 (W 2.21527) | · | 🔵 fork 2.00× faster |  |
| `svd_thin/64x1024/b1` | 5.91042 ± 0.033415 (W 0.00218861) | 5.91909 ± 0.0337786 (W 0.00422793) | 12.3038 ± 0.0532506 (W 0.0178056) | · | 🔵 fork 2.08× faster |  |
| `svd_values/256x4096/b1` | 110.276 ± 0.165322 (W 0.0484548) | 109.987 ± 0.145229 (W 0.059135) | 204.801 ± 5.50944 (W 0.901502) | · | 🔵 fork 1.86× faster |  |
| `svd_values/64x1024/b1` | 2.93363 ± 0.0269795 (W 0.00306464) | 2.95099 ± 0.0203421 (W 0.00293937) | 5.58896 ± 0.00137317 (W 0.00585819) | · | 🔵 fork 1.91× faster |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 97.5627 ± 1.82148 (W 0.629334) | 97.6248 ± 1.8208 (W 0.465296) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.50721 ± 0.0396533 (W 0.0070984) | 2.51208 ± 0.0364812 (W 0.00866365) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.1616 ± 0.109702 (W 0.0890348) | 18.1463 ± 0.0523321 (W 0.103203) | 29.3639 ± 0.13019 (W 0.270938) | · | 🔵 fork 1.62× faster |  |
| `lu/64x1024/b1` | 0.486821 ± 0.00358425 (W 0.00314458) | 0.488866 ± 0.00365789 (W 0.00254522) | 0.63745 ± 0.00202649 (W 0.00389289) | · | 🔵 fork 1.31× faster |  |
| `qr/256x4096/b1` | 34.6729 ± 0.0994955 (W 0.104547) | 34.914 ± 0.186738 (W 0.248776) | 45.5995 ± 0.0880722 (W 0.056576) | · | 🔵 fork 1.32× faster |  |
| `qr/64x1024/b1` | 1.28976 ± 0.0196453 (W 0.00952248) | 1.30668 ± 0.0140155 (W 0.01356) | 1.65657 ± 0.00385125 (W 0.00525849) | · | 🔵 fork 1.28× faster |  |
| `qr_factor/256x4096/b1` | 29.9186 ± 0.181766 (W 0.053336) | 30.5802 ± 0.218055 (W 0.0892482) | 39.2221 ± 0.0569784 (W 0.0435927) | · | 🔵 fork 1.31× faster |  |
| `qr_factor/64x1024/b1` | 1.33251 ± 0.042136 (W 0.0118373) | 1.34577 ± 0.0510919 (W 0.0257045) | 1.35692 ± 0.00405503 (W 0.00556755) | · | · | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 111.137 ± 0.383266 (W 0.195219) | 111.066 ± 0.153613 (W 0.0920326) | 191.48 ± 1.28129 (W 0.935253) | · | 🔵 fork 1.72× faster |  |
| `svd_thin/64x1024/b1` | 4.24313 ± 0.00584414 (W 0.0275398) | 4.24157 ± 0.00851941 (W 0.0193292) | 7.34685 ± 0.0756041 (W 0.0197773) | · | 🔵 fork 1.73× faster |  |
| `svd_values/256x4096/b1` | 62.8973 ± 0.0747093 (W 0.142977) | 62.9749 ± 0.153398 (W 0.149947) | 84.7858 ± 0.345709 (W 0.308946) | · | 🔵 fork 1.35× faster |  |
| `svd_values/64x1024/b1` | 2.91075 ± 0.00398093 (W 0.0207895) | 2.92739 ± 0.0191933 (W 0.0168896) | 3.6853 ± 0.0182556 (W 0.00487414) | · | 🔵 fork 1.27× faster |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 70.4271 ± 1.9297 (W 0.685552) | 70.1006 ± 1.11792 (W 0.743518) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.39518 ± 0.0657679 (W 0.0173032) | 2.42375 ± 0.0682836 (W 0.012001) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 12.5362 ± 0.0107335 (W 0.0426988) | 12.5588 ± 0.233743 (W 0.0659556) | 18.9093 ± 3.08624 (W 0.0561548) | · | 🔵 fork 1.51× faster | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.403154 ± 0.00174676 (W 0.00252414) | 0.403124 ± 0.00290656 (W 0.0048785) | 0.447082 ± 0.00122057 (W 0.00207698) | · | 🔵 fork 1.11× faster |  |
| `qr/256x4096/b1` | 25.1416 ± 0.369965 (W 0.345256) | 25.8035 ± 0.320992 (W 0.855834) | 26.6397 ± 0.0565224 (W 0.116281) | · | 🔵 fork 1.06× faster |  |
| `qr/64x1024/b1` | 1.3577 ± 0.0284196 (W 0.0274215) | 1.43589 ± 0.0279508 (W 0.0448217) | 1.05131 ± 0.00317469 (W 0.00250065) | 🔵 fork 1.06× faster | 🔴 fork 1.29× slower |  |
| `qr_factor/256x4096/b1` | 21.1313 ± 0.374163 (W 1.2474) | 21.7434 ± 0.0790581 (W 0.390094) | 21.1354 ± 0.0388388 (W 0.0246351) | · | · |  |
| `qr_factor/64x1024/b1` | 1.3692 ± 0.00620168 (W 0.024746) | 1.39172 ± 0.0276873 (W 0.0300458) | 0.759446 ± 0.00154419 (W 0.00131879) | · | 🔴 fork 1.80× slower |  |
| `svd_thin/256x4096/b1` | 94.0106 ± 2.95645 (W 1.76938) | 94.0222 ± 0.720988 (W 0.716374) | 118.109 ± 2.90921 (W 0.443256) | · | 🔵 fork 1.26× faster | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 4.56289 ± 0.0105834 (W 0.0270188) | 4.56674 ± 0.0505475 (W 0.0329072) | 6.24255 ± 0.0649973 (W 0.0178671) | · | 🔵 fork 1.37× faster |  |
| `svd_values/256x4096/b1` | 60.8613 ± 0.0430142 (W 0.316439) | 60.8626 ± 0.13769 (W 0.208519) | 55.4378 ± 0.145188 (W 0.0829481) | · | 🔴 fork 1.10× slower |  |
| `svd_values/64x1024/b1` | 3.2512 ± 0.0107042 (W 0.0284342) | 3.25039 ± 0.0264325 (W 0.0374524) | 3.26368 ± 0.0270835 (W 0.0163564) | · | · |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 218.213 ± 6.70272 (W 0.737843) | 216.463 ± 6.3804 (W 0.494895) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.3081 ± 0.0215736 (W 0.00569872) | 2.30886 ± 0.0372884 (W 0.011763) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 41.9862 ± 0.0734354 (W 0.0356502) | 41.9821 ± 0.0783741 (W 0.0312648) | 73.233 ± 0.516923 (W 0.19092) | · | 🔵 fork 1.74× faster |  |
| `lu/64x1024/b1` | 0.895736 ± 0.00300369 (W 0.00249817) | 0.896197 ± 0.00255635 (W 0.00383585) | 2.12276 ± 0.00325252 (W 0.00198281) | · | 🔵 fork 2.37× faster |  |
| `qr/256x4096/b1` | 102.692 ± 0.422502 (W 0.253084) | 103.125 ± 0.454324 (W 0.37352) | 187.917 ± 0.636811 (W 0.729243) | · | 🔵 fork 1.83× faster |  |
| `qr/64x1024/b1` | 2.41239 ± 0.0042087 (W 0.0136559) | 2.41133 ± 0.00307741 (W 0.00290279) | 3.94934 ± 0.19812 (W 0.0129947) | · | 🔵 fork 1.64× faster | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 96.3194 ± 0.324227 (W 0.256756) | 96.3741 ± 0.179302 (W 0.486609) | 149.672 ± 0.82936 (W 0.517339) | · | 🔵 fork 1.55× faster |  |
| `qr_factor/64x1024/b1` | 2.21316 ± 0.00730506 (W 0.00264146) | 2.22002 ± 0.0058532 (W 0.0025787) | 16.8672 ± 0.00160887 (W 0.00609456) | · | 🔵 fork 7.62× faster |  |
| `svd_thin/256x4096/b1` | 281.652 ± 0.339112 (W 0.176841) | 281.774 ± 0.154815 (W 0.360635) | 539.561 ± 1.42725 (W 1.66114) | · | 🔵 fork 1.92× faster |  |
| `svd_thin/64x1024/b1` | 6.02773 ± 0.0308095 (W 0.00731247) | 6.03429 ± 0.0333481 (W 0.00430506) | 11.8693 ± 0.0470206 (W 0.0188828) | · | 🔵 fork 1.97× faster |  |
| `svd_values/256x4096/b1` | 123.815 ± 1.29008 (W 0.466606) | 122.991 ± 0.816758 (W 0.390725) | 194.04 ± 2.94066 (W 1.45795) | · | 🔵 fork 1.57× faster |  |
| `svd_values/64x1024/b1` | 3.07761 ± 0.0166051 (W 0.0021852) | 3.084 ± 0.015731 (W 0.00467522) | 5.3631 ± 0.017913 (W 0.0195639) | · | 🔵 fork 1.74× faster |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.1718 ± 1.31583 (W 0.521763) | 92.3158 ± 1.65737 (W 0.60612) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.27662 ± 0.0328151 (W 0.00835267) | 2.27696 ± 0.0203738 (W 0.0078759) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.8687 ± 0.0323641 (W 0.0605759) | 14.0201 ± 0.125928 (W 0.0663149) | 20.6346 ± 0.100081 (W 0.0323813) | · | 🔵 fork 1.49× faster |  |
| `lu/64x1024/b1` | 0.32681 ± 0.00513367 (W 0.0045322) | 0.324107 ± 0.0037734 (W 0.00339671) | 0.594873 ± 0.00457064 (W 0.00469746) | · | 🔵 fork 1.82× faster |  |
| `qr/256x4096/b1` | 30.0157 ± 0.135988 (W 0.101756) | 30.2915 ± 0.201845 (W 0.0808263) | 60.3936 ± 0.0301344 (W 0.333926) | · | 🔵 fork 2.01× faster |  |
| `qr/64x1024/b1` | 1.13176 ± 0.00467507 (W 0.00795232) | 1.14301 ± 0.0121353 (W 0.013498) | 1.67015 ± 0.00746785 (W 0.00963567) | · | 🔵 fork 1.48× faster |  |
| `qr_factor/256x4096/b1` | 27.057 ± 0.268368 (W 0.0692145) | 27.2429 ± 0.228953 (W 0.0456814) | 36.2729 ± 0.00736162 (W 0.0397246) | · | 🔵 fork 1.34× faster |  |
| `qr_factor/64x1024/b1` | 0.961373 ± 0.00399956 (W 0.00895702) | 0.963162 ± 0.00914395 (W 0.00637385) | 1.28584 ± 0.000635446 (W 0.00410745) | · | 🔵 fork 1.34× faster |  |
| `svd_thin/256x4096/b1` | 123.066 ± 0.104249 (W 0.460754) | 123.245 ± 0.142702 (W 0.292655) | 180.837 ± 0.548189 (W 0.492636) | · | 🔵 fork 1.47× faster |  |
| `svd_thin/64x1024/b1` | 4.36888 ± 0.0166346 (W 0.0227132) | 4.36479 ± 0.0228905 (W 0.0220663) | 7.27817 ± 0.112225 (W 0.0192968) | · | 🔵 fork 1.67× faster |  |
| `svd_values/256x4096/b1` | 74.8208 ± 0.109957 (W 0.18621) | 74.8441 ± 0.0741625 (W 0.127786) | 82.0248 ± 0.123573 (W 0.0845863) | · | 🔵 fork 1.10× faster |  |
| `svd_values/64x1024/b1` | 3.00526 ± 0.0174003 (W 0.0170467) | 3.03257 ± 0.0237808 (W 0.0250478) | 3.68948 ± 0.0320685 (W 0.0148559) | · | 🔵 fork 1.23× faster |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 63.6974 ± 1.65724 (W 0.588847) | 65.6344 ± 1.27027 (W 0.532514) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.25503 ± 0.0122915 (W 0.0130516) | 2.25645 ± 0.022861 (W 0.010994) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.41658 ± 0.0736685 (W 0.0441571) | 8.30406 ± 0.0275337 (W 0.0291121) | 11.2458 ± 0.0124513 (W 0.00995235) | · | 🔵 fork 1.34× faster |  |
| `lu/64x1024/b1` | 0.241788 ± 0.00134546 (W 0.00274894) | 0.238877 ± 0.000119488 (W 0.0022909) | 0.411997 ± 0.00449974 (W 0.00282926) | · | 🔵 fork 1.70× faster |  |
| `qr/256x4096/b1` | 20.8102 ± 0.540983 (W 0.519235) | 21.3535 ± 0.0897405 (W 0.892748) | 36.7849 ± 0.167591 (W 0.187424) | · | 🔵 fork 1.77× faster | `!` between-start range over 5% |
| `qr/64x1024/b1` | 1.21707 ± 0.0067632 (W 0.0218148) | 1.20613 ± 0.0145081 (W 0.0253901) | 1.08537 ± 0.10206 (W 0.0164834) | · | 🔴 fork 1.12× slower | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 18.0053 ± 0.243656 (W 1.30061) | 18.1607 ± 0.358863 (W 0.664743) | 18.7227 ± 0.0128574 (W 0.0284149) | · | · |  |
| `qr_factor/64x1024/b1` | 0.989933 ± 0.00778187 (W 0.0141735) | 1.00948 ± 0.0145531 (W 0.0247847) | 0.706421 ± 0.00101412 (W 0.00219489) | · | 🔴 fork 1.40× slower |  |
| `svd_thin/256x4096/b1` | 105.779 ± 0.100279 (W 0.190949) | 106.046 ± 0.435181 (W 0.751957) | 109.488 ± 0.54782 (W 0.363937) | · | · |  |
| `svd_thin/64x1024/b1` | 4.61824 ± 0.0322367 (W 0.0205971) | 4.64782 ± 0.0411321 (W 0.0377526) | 6.21422 ± 0.103325 (W 0.015842) | · | 🔵 fork 1.35× faster |  |
| `svd_values/256x4096/b1` | 72.7558 ± 0.391256 (W 0.753585) | 72.4712 ± 0.125896 (W 0.194623) | 52.6052 ± 0.433502 (W 0.0934101) | · | 🔴 fork 1.38× slower |  |
| `svd_values/64x1024/b1` | 3.34766 ± 0.0140818 (W 0.0290362) | 3.36015 ± 0.0289332 (W 0.0235162) | 3.22478 ± 0.0508113 (W 0.0159079) | · | · |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
