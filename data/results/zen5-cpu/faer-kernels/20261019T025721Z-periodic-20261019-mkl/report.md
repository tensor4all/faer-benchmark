# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `a5e6b7d239466fb0d685edc20db6c4f3f3a71411`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `3a4ad3fdbc41379a36e591bd9d4414acee56460f`
- toolkit commit: `95caeefa9ae7c8461ccdf75d3b65455d4ed799b0`
- measured binary SHA-256: `25dd94085a1ca1765a59d85901089cdf3a1a2756abb3ff4fbaf7f780363f7a4a`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-19T05:18:26.177758Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label periodic-20261019-mkl`
- raw data: `data/results/zen5-cpu/faer-kernels/20261019T025721Z-periodic-20261019-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.94%, worst 2143.34% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 350 of 3684 engine cells exceed 5% and carry `!`; median within-process relative SD 0.55%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.002325 ± 1.76163e-05 (W 2.53831e-05) | 0.002344 ± 2.51064e-05 (W 1.88468e-05) | 0.004529 ± 6.35085e-06 (W 5.7517e-05) | · | 🔵 fork 1.95× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017052 ± 6.55744e-05 (W 2.30911e-05) | 0.017062 ± 4.46132e-05 (W 1.59781e-05) | 0.024326 ± 6.82959e-05 (W 7.55328e-05) | · | 🔵 fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056775 ± 0.000139503 (W 6.05335e-05) | 0.056737 ± 0.000237812 (W 4.27107e-05) | 0.062617 ± 0.000233907 (W 7.65846e-05) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002324 ± 1.00167e-05 (W 1.28919e-05) | 0.01048 ± 0.000774072 (W 0.00118844) | 0.00521 ± 0.000133717 (W 7.56968e-05) | 🔵 fork 4.51× faster than `faer-upstream` | 🔵 fork 2.24× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017182 ± 0.000211947 (W 2.07364e-05) | 0.023072 ± 0.00195977 (W 0.00348816) | 0.014037 ± 0.000202693 (W 0.000107276) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.065464 ± 0.00699781 (W 0.0111109) | 0.056217 ± 0.010343 (W 0.0124455) | 0.022361 ± 0.000404156 (W 0.000162367) | · | 🔴 fork 2.93× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002325 ± 2.28108e-05 (W 1.50732e-05) | 0.013866 ± 0.000334027 (W 0.00133089) | 0.004919 ± 0.000203422 (W 0.00021945) | 🔵 fork 5.96× faster than `faer-upstream` | 🔵 fork 2.12× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017243 ± 7.02163e-05 (W 2.50998e-05) | 0.019916 ± 0.000613802 (W 0.00122804) | 0.010009 ± 0.0002045 (W 0.000185688) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030937 ± 0.00117401 (W 0.00131788) | 0.031098 ± 0.000979365 (W 0.00188259) | 0.014617 ± 0.00029896 (W 0.000252902) | · | 🔴 fork 2.12× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 2.46374e-05 (W 2.53239e-05) | 0.002344 ± 2.51661e-05 (W 6.02495e-06) | 0.004528 ± 3.05014e-05 (W 4.92057e-05) | · | 🔵 fork 1.93× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017162 ± 7.07602e-05 (W 2.73002e-05) | 0.017112 ± 4.93288e-05 (W 2.42961e-05) | 0.024425 ± 8.03264e-05 (W 4.03386e-05) | · | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056945 ± 0.000208308 (W 0.0015026) | 0.056778 ± 2.40278e-05 (W 0.00163223) | 0.062745 ± 0.000112623 (W 7.58288e-05) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002335 ± 5.22526e-05 (W 2.32873e-05) | 0.011081 ± 0.000397052 (W 0.00159611) | 0.00534 ± 0.000165581 (W 0.000129612) | 🔵 fork 4.75× faster than `faer-upstream` | 🔵 fork 2.29× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017091 ± 0.000162802 (W 3.37683e-05) | 0.024936 ± 0.000741636 (W 0.00331458) | 0.014257 ± 0.00016328 (W 0.0001032) | 🔵 fork 1.46× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.047226 ± 0.0143124 (W 0.0130806) | 0.053579 ± 0.00623544 (W 0.0146227) | 0.022451 ± 0.00023152 (W 0.000156526) | · | 🔴 fork 2.10× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 5.7735e-07 (W 9.33809e-06) | 0.013395 ± 0.000445009 (W 0.000777139) | 0.005119 ± 0.000110546 (W 0.000154124) | 🔵 fork 5.79× faster than `faer-upstream` | 🔵 fork 2.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017243 ± 4.56545e-05 (W 4.219e-05) | 0.019877 ± 0.000982371 (W 0.000839362) | 0.010189 ± 0.000173494 (W 0.000224455) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.69× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.030879 ± 0.000475694 (W 0.00119922) | 0.030669 ± 0.00105368 (W 0.00102177) | 0.014657 ± 0.000196531 (W 0.00017196) | · | 🔴 fork 2.11× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008856 ± 3.751e-05 (W 8.50294e-06) | 0.008866 ± 3.50761e-05 (W 1.39714e-05) | 0.011211 ± 0.000100167 (W 0.000146526) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067795 ± 0.000106744 (W 0.00128334) | 0.067769 ± 5.45069e-05 (W 4.63681e-05) | 0.081529 ± 0.00139101 (W 0.000803353) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226476 ± 0.000156 (W 0.00174095) | 0.226311 ± 0.000550769 (W 0.00148007) | 0.270724 ± 0.00484721 (W 0.00552401) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008826 ± 3.05505e-05 (W 2.78783e-05) | 0.008777 ± 4.64794e-05 (W 1.2973e-05) | 0.013916 ± 0.000122202 (W 9.49173e-05) | · | 🔵 fork 1.58× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.045817 ± 0.00242712 (W 0.00450283) | 0.044602 ± 0.00133557 (W 0.0045741) | 0.035407 ± 0.000131424 (W 0.000471762) | · | 🔴 fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.095986 ± 0.00449827 (W 0.00781761) | 0.095311 ± 0.00475184 (W 0.00824311) | 0.099182 ± 0.000853113 (W 0.00143) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008857 ± 4.38216e-05 (W 1.97053e-05) | 0.008896 ± 2.6839e-05 (W 1.78885e-05) | 0.024755 ± 0.0049492 (W 0.00017627) | · | 🔵 fork 2.79× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.03798 ± 0.00126586 (W 0.001575) | 0.038031 ± 0.0014255 (W 0.00134486) | 0.015769 ± 7.86787e-05 (W 0.000142408) | · | 🔴 fork 2.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.052126 ± 0.00126564 (W 0.00140592) | 0.051445 ± 0.000718449 (W 0.00123202) | 0.04275 ± 0.000229007 (W 0.000250638) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008907 ± 3.59212e-05 (W 2.68738e-05) | 0.008937 ± 2.88675e-05 (W 2.17325e-05) | 0.011 ± 5.50757e-05 (W 0.000164588) | · | 🔵 fork 1.23× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067745 ± 6.4392e-05 (W 4.16917e-05) | 0.067716 ± 8.43584e-05 (W 0.00146488) | 0.083644 ± 0.00137685 (W 0.00180743) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.22651 ± 5.39475e-05 (W 0.00159779) | 0.226701 ± 0.000407358 (W 0.00158981) | 0.27195 ± 0.00276444 (W 0.00593519) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008796 ± 3.17857e-05 (W 1.49432e-05) | 0.008786 ± 5.56507e-05 (W 9.28978e-06) | 0.013856 ± 0.000320364 (W 0.000176432) | · | 🔵 fork 1.58× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.044313 ± 0.000494031 (W 0.00550498) | 0.045674 ± 0.0024618 (W 0.00685225) | 0.035225 ± 0.00041399 (W 0.000310155) | · | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.086775 ± 0.000347494 (W 0.00547854) | 0.086802 ± 0.00737174 (W 0.00645947) | 0.09787 ± 0.00106631 (W 0.000994597) | · | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008856 ± 1e-05 (W 1.31985e-05) | 0.008856 ± 2.02567e-05 (W 1.47411e-05) | 0.024615 ± 0.000151486 (W 0.000240458) | · | 🔵 fork 2.78× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.037381 ± 0.000772393 (W 0.00187094) | 0.037178 ± 0.00136049 (W 0.00173822) | 0.015869 ± 0.000120956 (W 0.000131595) | · | 🔴 fork 2.36× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.051366 ± 0.00091872 (W 0.00119208) | 0.050927 ± 0.000660737 (W 0.00181975) | 0.042748 ± 0.000125861 (W 0.000553404) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133734 ± 0.000337713 (W 0.000190993) | 0.133563 ± 0.000420702 (W 0.00144995) | 0.167979 ± 0.00146156 (W 0.00142626) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.453203 ± 0.00106812 (W 0.00215848) | 0.454403 ± 0.00197565 (W 0.00206223) | 0.483098 ± 0.000669187 (W 0.00229563) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07262 ± 0.00286077 (W 0.000851966) | 1.07513 ± 0.00229266 (W 0.00165716) | 1.19804 ± 0.00745518 (W 0.00210323) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.60939 ± 0.00463728 (W 0.00386872) | 3.61128 ± 0.00929106 (W 0.00524015) | 3.73711 ± 0.00776717 (W 0.0114856) | · | · |  |
| `gemm/512x512x512/b1` | 8.60265 ± 0.0114544 (W 0.0141255) | 8.58575 ± 0.026351 (W 0.0174135) | 9.86649 ± 0.101431 (W 0.0220454) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4485 ± 0.0349294 (W 0.0384478) | 29.3812 ± 0.0431197 (W 0.037078) | 30.5604 ± 0.0627721 (W 0.0294603) | · | · |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.082684 ± 0.0162791 (W 0.0142013) | 0.075289 ± 0.0192912 (W 0.0211329) | 0.056447 ± 0.000191928 (W 0.000286102) | · | 🔴 fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.150557 ± 0.0174647 (W 0.016961) | 0.144288 ± 0.013101 (W 0.0135303) | 0.136121 ± 0.000695554 (W 0.00168705) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.302903 ± 0.00494735 (W 0.00390199) | 0.30071 ± 0.00628031 (W 0.00743868) | 0.343319 ± 0.000248359 (W 0.00180408) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.935673 ± 0.00414773 (W 0.00291322) | 0.932265 ± 0.00210114 (W 0.00333372) | 1.00673 ± 0.00285473 (W 0.00117498) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.24714 ± 0.00966187 (W 0.0035337) | 2.24124 ± 0.0126765 (W 0.00792304) | 2.92002 ± 0.0715594 (W 0.00513437) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 7.53175 ± 0.023576 (W 0.00665601) | 7.52572 ± 0.00562297 (W 0.0234169) | 8.50257 ± 0.0343056 (W 0.00751481) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.101428 ± 0.0147066 (W 0.0243182) | 0.096408 ± 0.0129294 (W 0.0201507) | 0.032801 ± 0.000227579 (W 0.000240076) | · | 🔴 fork 3.09× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.174956 ± 0.0383904 (W 0.0494907) | 0.147903 ± 0.00863388 (W 0.0328726) | 0.073726 ± 0.000713293 (W 0.00018913) | · | 🔴 fork 2.37× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.209399 ± 0.00201645 (W 0.0243631) | 0.194648 ± 0.00147622 (W 0.0388804) | 0.178929 ± 0.000888577 (W 0.00165031) | 🔴 fork 1.08× slower than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.55348 ± 0.00231187 (W 0.0159919) | 0.561986 ± 0.000837555 (W 0.0109122) | 0.51344 ± 0.00290329 (W 0.0034275) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.20853 ± 1.23076 (W 0.0127111) | 1.1972 ± 0.00630027 (W 0.0139363) | 1.53496 ± 0.0120488 (W 0.00403547) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/768x768x768/b1` | 3.9427 ± 0.0164059 (W 0.0244852) | 3.94031 ± 0.0110226 (W 0.00858975) | 4.66072 ± 0.00320933 (W 0.0225084) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133709 ± 0.000474137 (W 0.000757991) | 0.133794 ± 0.000118882 (W 0.00158153) | 0.168049 ± 0.000979821 (W 0.00146186) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.454436 ± 0.00124784 (W 0.00212708) | 0.452913 ± 0.00130739 (W 0.00242528) | 0.481947 ± 0.00245193 (W 0.00210659) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07291 ± 0.00132708 (W 0.000607688) | 1.07352 ± 0.00199737 (W 0.00126701) | 1.20376 ± 0.00288209 (W 0.0027916) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.62052 ± 0.00406104 (W 0.00848491) | 3.6155 ± 0.00347179 (W 0.00757335) | 3.72758 ± 0.00329816 (W 0.00457163) | · | · |  |
| `gemm/512x512x512/b1` | 8.61302 ± 0.0119013 (W 0.00673603) | 8.61504 ± 0.0118765 (W 0.394588) | 9.82034 ± 0.183483 (W 0.0275165) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4579 ± 0.0266703 (W 0.0361853) | 29.4592 ± 0.0219125 (W 0.0485192) | 30.5527 ± 0.04051 (W 0.0345889) | · | · |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.090778 ± 0.00710953 (W 0.0133657) | 0.059039 ± 0.0236142 (W 0.0127761) | 0.055612 ± 0.00016692 (W 0.000243775) | 🔴 fork 1.54× slower than `faer-upstream` | 🔴 fork 1.63× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.151962 ± 0.0100786 (W 0.0178144) | 0.145286 ± 0.00511243 (W 0.0162365) | 0.135176 ± 0.000444038 (W 0.00158263) | · | 🔴 fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.310949 ± 0.00561212 (W 0.00961717) | 0.307948 ± 0.00383157 (W 0.00395008) | 0.343231 ± 0.000692739 (W 0.00182779) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.931393 ± 0.00150416 (W 0.00272699) | 0.931105 ± 0.00496515 (W 0.00420769) | 1.00633 ± 0.00440657 (W 0.00171747) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.24458 ± 0.00445953 (W 0.00549692) | 2.24392 ± 0.00980833 (W 0.0053172) | 2.83573 ± 0.133174 (W 0.011999) | · | 🔵 fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.51741 ± 0.037204 (W 0.0227226) | 7.52181 ± 0.00746583 (W 0.0226315) | 8.47887 ± 0.0322454 (W 0.0180811) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.076481 ± 0.015261 (W 0.0333785) | 0.07422 ± 0.0231724 (W 0.018599) | 0.03181 ± 0.000263213 (W 0.000239072) | · | 🔴 fork 2.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.158672 ± 0.0203257 (W 0.0292169) | 0.173674 ± 0.0166317 (W 0.0238855) | 0.073369 ± 0.000625543 (W 0.000282322) | · | 🔴 fork 2.16× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.215892 ± 0.00792316 (W 0.030482) | 0.235909 ± 0.015046 (W 0.0331133) | 0.179671 ± 0.00123631 (W 0.00173195) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.559278 ± 0.00339445 (W 0.0107386) | 0.549954 ± 0.00780457 (W 0.0157141) | 0.516897 ± 0.00389473 (W 0.00304976) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.20882 ± 0.00249257 (W 0.011997) | 1.18976 ± 0.00488045 (W 0.0130235) | 1.51944 ± 0.0173831 (W 0.00403198) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.93674 ± 0.0331306 (W 0.020779) | 3.95075 ± 0.00261611 (W 0.0246044) | 4.66369 ± 0.00416047 (W 0.0180789) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.540947 ± 0.00364788 (W 0.00194122) | 0.539734 ± 0.00337298 (W 0.00215228) | 0.651366 ± 0.00543533 (W 0.00670871) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81034 ± 0.00271402 (W 0.00258448) | 1.81517 ± 0.00579449 (W 0.00352856) | 2.15911 ± 0.00913203 (W 0.0149409) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.28626 ± 0.00530555 (W 0.0100161) | 4.29087 ± 0.00949691 (W 0.00824669) | 5.05925 ± 0.0285273 (W 0.0209519) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4562 ± 0.0252778 (W 0.0241946) | 14.4801 ± 0.022248 (W 0.0169669) | 17.2243 ± 0.0153149 (W 0.0508172) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.3175 ± 0.088166 (W 0.396811) | 34.3716 ± 0.0900807 (W 0.0453881) | 40.9071 ± 0.137849 (W 0.0710452) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.717 ± 0.188711 (W 0.373005) | 116.686 ± 0.312079 (W 0.0830759) | 136.861 ± 1.01703 (W 0.109399) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.161859 ± 0.000564112 (W 0.00287528) | 0.160899 ± 0.00155172 (W 0.00249053) | 0.234154 ± 0.00113964 (W 0.00263988) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.477989 ± 0.00658153 (W 0.00363562) | 0.470585 ± 0.00392659 (W 0.0022292) | 0.744081 ± 0.00250467 (W 0.0059841) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.12988 ± 0.00161358 (W 0.00417243) | 1.12916 ± 0.00268574 (W 0.00325245) | 1.81512 ± 0.00677904 (W 0.00650909) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.66316 ± 0.00507834 (W 0.0137555) | 3.66287 ± 0.00425636 (W 0.0113702) | 5.78946 ± 0.0144555 (W 0.0114221) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.70773 ± 0.0207724 (W 0.015925) | 8.71816 ± 0.0128491 (W 0.0118808) | 13.7837 ± 0.0800704 (W 0.0128552) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4648 ± 0.0458615 (W 0.0254629) | 29.4697 ± 0.0333712 (W 0.0235224) | 46.636 ± 0.0449638 (W 0.0782782) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.117286 ± 0.00629454 (W 0.0144223) | 0.115162 ± 0.00513907 (W 0.0106353) | 0.094789 ± 0.000420365 (W 0.000949624) | · | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.273875 ± 0.0118523 (W 0.0129825) | 0.278824 ± 0.00648231 (W 0.0104666) | 0.296877 ± 0.00044685 (W 0.00232485) | · | 🔵 fork 1.08× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.610557 ± 0.00869236 (W 0.0133538) | 0.608202 ± 0.00200791 (W 0.00500122) | 0.710884 ± 0.00670667 (W 0.00358643) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.87436 ± 0.000925058 (W 0.0077775) | 1.87659 ± 0.00886173 (W 0.00726958) | 2.27198 ± 0.0166051 (W 0.008711) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.51022 ± 0.0104398 (W 0.00842666) | 4.51725 ± 0.00442403 (W 0.00616819) | 5.53913 ± 0.032095 (W 0.0368781) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.9587 ± 0.0778271 (W 0.0229973) | 14.9862 ± 0.0143324 (W 0.0302878) | 18.5109 ± 0.30171 (W 0.0739549) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539582 ± 0.0026222 (W 0.00172285) | 0.537961 ± 0.00123638 (W 0.00203533) | 0.650815 ± 0.00381782 (W 0.00498839) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81219 ± 0.00942943 (W 0.00857955) | 1.8159 ± 0.00498268 (W 0.0027334) | 2.16186 ± 0.0082073 (W 0.0109062) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.28367 ± 0.00806625 (W 0.00426253) | 4.29393 ± 0.0164605 (W 0.0134665) | 5.16075 ± 0.0229251 (W 0.0121775) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4693 ± 0.0160457 (W 0.0201617) | 14.4657 ± 0.0268207 (W 0.0223309) | 17.2124 ± 0.101774 (W 0.0334456) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.3744 ± 0.0353323 (W 0.0596615) | 34.3481 ± 0.0574498 (W 0.0444123) | 40.9867 ± 0.077892 (W 0.0346288) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.697 ± 0.255438 (W 0.0631267) | 116.569 ± 0.414258 (W 0.0774064) | 137.125 ± 0.396515 (W 0.107635) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160905 ± 0.000497109 (W 0.00209515) | 0.160885 ± 0.000120931 (W 0.00663498) | 0.233069 ± 0.000424819 (W 0.00299084) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.476728 ± 0.00147516 (W 0.00279859) | 0.476047 ± 0.00536671 (W 0.00341894) | 0.743901 ± 0.0035828 (W 0.00522636) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.1282 ± 0.00230507 (W 0.00313386) | 1.13037 ± 0.0036677 (W 0.00338298) | 1.79563 ± 0.00646608 (W 0.00511574) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.65848 ± 0.0205504 (W 0.00678149) | 3.65973 ± 0.00937725 (W 0.0115305) | 5.79094 ± 0.0256009 (W 0.0148158) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.68995 ± 0.0161618 (W 0.00969863) | 8.68013 ± 0.0344494 (W 0.0135365) | 13.7748 ± 0.0334407 (W 0.0287332) | · | 🔵 fork 1.59× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4599 ± 0.0843575 (W 0.0334044) | 29.4547 ± 0.0369938 (W 0.0304806) | 46.6221 ± 0.0322668 (W 0.0784225) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.11404 ± 0.0161652 (W 0.0176612) | 0.114887 ± 0.000897127 (W 0.0117036) | 0.095015 ± 0.00175379 (W 0.00129546) | · | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.27631 ± 0.0105039 (W 0.0134523) | 0.276405 ± 0.00139008 (W 0.0116209) | 0.30158 ± 0.0042147 (W 0.00296129) | · | 🔵 fork 1.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.60759 ± 0.0096259 (W 0.00828851) | 0.604646 ± 0.00391101 (W 0.00816504) | 0.708319 ± 0.0109509 (W 0.00325293) | · | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.87978 ± 0.0078634 (W 0.00426668) | 1.87633 ± 0.00401452 (W 0.0104837) | 2.28871 ± 0.00324187 (W 0.0056883) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.51915 ± 0.00364007 (W 0.0135427) | 4.51169 ± 0.00879203 (W 0.0121181) | 5.52726 ± 0.022754 (W 0.0197993) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.9804 ± 0.032329 (W 0.0305182) | 14.9827 ± 0.0700346 (W 0.0286094) | 18.6941 ± 0.148732 (W 0.0675045) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.27839 ± 0.0224738 (W 0.00472609) | 1.26984 ± 0.0154868 (W 0.00478298) | 1.53359 ± 0.102559 (W 0.00976469) | · | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.07173 ± 0.00478339 (W 0.00134254) | 1.0903 ± 0.0133779 (W 0.00969438) | 1.53542 ± 0.0312761 (W 0.0155527) | · | 🔵 fork 1.43× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08215 ± 0.00291079 (W 0.00208865) | 1.08375 ± 0.00697165 (W 0.00201112) | 1.57139 ± 0.0132641 (W 0.00413168) | · | 🔵 fork 1.45× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.438119 ± 0.00191228 (W 0.00254539) | 0.446291 ± 0.00343861 (W 0.00585774) | 0.421638 ± 0.00792652 (W 0.00495314) | · | · |  |
| `gemm/4096x16x240/b1` | 0.328036 ± 0.000445608 (W 0.00195823) | 0.330574 ± 0.000140657 (W 0.00351238) | 0.429038 ± 0.00216359 (W 0.00213058) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.312571 ± 0.00847737 (W 0.00995956) | 0.313494 ± 0.00671064 (W 0.00806587) | 0.393754 ± 0.00170389 (W 0.00291817) | · | 🔵 fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.443218 ± 0.00258203 (W 0.00333217) | 0.440774 ± 0.0021045 (W 0.0067482) | 0.256545 ± 0.0077221 (W 0.00336938) | · | 🔴 fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.212523 ± 0.00425791 (W 0.00395745) | 0.209936 ± 0.000784324 (W 0.00585341) | 0.288537 ± 0.00194254 (W 0.00177581) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.200188 ± 0.0213287 (W 0.019609) | 0.21159 ± 0.0220841 (W 0.0195808) | 0.197874 ± 0.000125926 (W 0.00159924) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.04849 ± 0.0111533 (W 0.00261514) | 1.04417 ± 0.00696163 (W 0.002151) | 2.66178 ± 0.0118652 (W 0.0133077) | · | 🔵 fork 2.54× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.0938 ± 0.00741624 (W 0.00848709) | 1.094 ± 0.00380275 (W 0.00759561) | 1.43448 ± 0.0149844 (W 0.0151543) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.13712 ± 0.00724002 (W 0.00424873) | 1.1348 ± 0.0076393 (W 0.00329862) | 1.24315 ± 0.0152565 (W 0.00567058) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.707627 ± 0.0134832 (W 0.0194011) | 0.681327 ± 0.0105153 (W 0.0177031) | 0.649679 ± 0.00076842 (W 0.00331873) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.320907 ± 0.00226936 (W 0.00320887) | 0.320416 ± 0.00142331 (W 0.00274291) | 0.431393 ± 0.00242578 (W 0.00266076) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.313844 ± 0.00225053 (W 0.00515973) | 0.312698 ± 0.00233112 (W 0.00288546) | 0.332704 ± 0.00343992 (W 0.00153915) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.13861 ± 0.0109153 (W 0.0489286) | 1.13278 ± 0.00773843 (W 0.0153886) | 0.347892 ± 0.00303511 (W 0.00599809) | · | 🔴 fork 3.27× slower than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.20169 ± 0.00423206 (W 0.00437203) | 0.202222 ± 0.00146859 (W 0.00344337) | 0.296298 ± 0.000474831 (W 0.00229702) | · | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.186144 ± 0.00279924 (W 0.00350013) | 0.181755 ± 0.00711062 (W 0.00468107) | 0.175614 ± 0.00201719 (W 0.00174441) | · | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.15722 ± 0.00602602 (W 0.0126363) | 4.14371 ± 0.00888669 (W 0.00966072) | 5.69328 ± 0.0611832 (W 0.0258105) | · | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.33458 ± 0.0128811 (W 0.00885741) | 4.33553 ± 0.0122282 (W 0.00462324) | 5.61891 ± 0.0243115 (W 0.0213764) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.40147 ± 0.0192346 (W 0.0203958) | 4.39538 ± 0.010869 (W 0.0142769) | 5.2508 ± 0.0134735 (W 0.0106623) | · | 🔵 fork 1.19× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.66885 ± 0.00574667 (W 0.00699936) | 1.67773 ± 0.00547621 (W 0.00429966) | 1.93104 ± 0.027869 (W 0.00521796) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.21977 ± 0.00959921 (W 0.0111008) | 1.20305 ± 0.00566682 (W 0.0163101) | 2.11211 ± 0.156754 (W 0.010683) | · | 🔵 fork 1.73× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 1.15439 ± 0.00563798 (W 0.00240238) | 1.15639 ± 0.00475553 (W 0.00250211) | 2.06236 ± 0.00633223 (W 0.00335285) | · | 🔵 fork 1.79× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.936399 ± 0.00698867 (W 0.00960411) | 0.922704 ± 0.00568295 (W 0.00645443) | 0.955173 ± 0.00879164 (W 0.0034406) | · | · |  |
| `gemm/4096x16x240/b1` | 0.644857 ± 0.00466629 (W 0.00361018) | 0.647996 ± 0.00385531 (W 0.00308371) | 0.986492 ± 0.209102 (W 0.00793394) | · | 🔵 fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.602627 ± 0.00609226 (W 0.00237459) | 0.603074 ± 0.000641374 (W 0.00434191) | 0.754994 ± 0.00809625 (W 0.00324473) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07146 ± 0.0107843 (W 0.0120485) | 4.05727 ± 0.0128125 (W 0.00606579) | 5.73168 ± 0.00254226 (W 0.0117863) | · | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.36495 ± 0.0040928 (W 0.0154615) | 4.38103 ± 0.00726972 (W 0.0123298) | 5.42211 ± 0.0371452 (W 0.0450525) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.44306 ± 0.00971804 (W 0.00341974) | 4.45883 ± 0.014376 (W 0.0189762) | 5.75647 ± 0.0769443 (W 0.0222071) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.95623 ± 0.0156366 (W 0.0337178) | 1.89743 ± 0.0513283 (W 0.0469895) | 10.7214 ± 5.6379 (W 0.0139007) | · | 🔵 fork 5.48× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.20324 ± 0.00240743 (W 0.00557902) | 1.20756 ± 0.00374012 (W 0.00640092) | 2.4213 ± 0.0543479 (W 0.0467073) | · | 🔵 fork 2.01× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.21387 ± 0.0175671 (W 0.00876402) | 1.20736 ± 0.0158818 (W 0.00737639) | 2.02903 ± 0.0214686 (W 0.012654) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.56229 ± 0.00300188 (W 0.0524424) | 2.57123 ± 0.0166599 (W 0.0417025) | 10.9371 ± 3.13384 (W 0.0692893) | · | 🔵 fork 4.27× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.644847 ± 0.00438693 (W 0.00432688) | 0.637948 ± 0.00575162 (W 0.00444847) | 1.53468 ± 0.136839 (W 0.0114495) | · | 🔵 fork 2.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.620642 ± 0.00359319 (W 0.00472232) | 0.616398 ± 1.29656 (W 0.00362799) | 1.19755 ± 0.099397 (W 0.0620384) | · | 🔵 fork 1.93× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12902 ± 0.00902584 (W 0.00367099) | 1.12237 ± 0.00724449 (W 0.00289512) | 1.24098 ± 0.00296251 (W 0.00182393) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.314411 ± 0.00237972 (W 0.00501724) | 0.315397 ± 0.000736698 (W 0.00398018) | 0.335132 ± 0.00384703 (W 0.00196408) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.180951 ± 0.00766588 (W 0.00246883) | 0.180977 ± 0.00276189 (W 0.00439734) | 0.17489 ± 0.00398272 (W 0.0013932) | · | · | `!` between-start range over 5% |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.08858 ± 0.00551029 (W 0.00205197) | 1.08816 ± 0.00397776 (W 0.00188892) | 1.5268 ± 0.0214204 (W 0.00391374) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.310987 ± 0.00777172 (W 0.00647064) | 0.314816 ± 0.00603978 (W 0.00898976) | 0.389245 ± 0.00408093 (W 0.00190705) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.172068 ± 0.0195306 (W 0.0217884) | 0.210226 ± 0.0169245 (W 0.0214228) | 0.197894 ± 0.000980044 (W 0.00110808) | 🔵 fork 1.22× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.46529 ± 0.00984085 (W 0.0147302) | 4.46034 ± 0.0144702 (W 0.0108956) | 5.80112 ± 0.0748194 (W 0.0195143) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.22089 ± 0.0179749 (W 0.00970571) | 1.22348 ± 0.00776653 (W 0.00838213) | 2.06387 ± 0.00480088 (W 0.0143696) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.617489 ± 0.00535522 (W 0.00479366) | 0.622791 ± 0.00428751 (W 0.00481621) | 1.27225 ± 0.0870343 (W 0.0722108) | · | 🔵 fork 2.06× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.39458 ± 0.0116277 (W 0.0109541) | 4.40007 ± 0.0122256 (W 0.00981745) | 5.25834 ± 0.0212448 (W 0.0187091) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.15129 ± 0.00386914 (W 0.00543138) | 1.16 ± 0.00256323 (W 0.00213055) | 2.07539 ± 0.00741802 (W 0.00264071) | · | 🔵 fork 1.80× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.60604 ± 0.00526798 (W 0.00303297) | 0.603033 ± 0.00401022 (W 0.00461261) | 0.761467 ± 0.0012709 (W 0.00428824) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003176 ± 3.84318e-05 (W 3.60555e-05) | 0.003396 ± 2e-05 (W 2.91428e-05) | 0.004188 ± 2.04206e-05 (W 3.56371e-05) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015169 ± 5.31068e-05 (W 5.9869e-05) | 0.016661 ± 5.18684e-05 (W 4.98618e-05) | 0.016911 ± 0.000123452 (W 4.22516e-05) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.031097 ± 2.72213e-05 (W 3.39013e-05) | 0.032712 ± 0.00201412 (W 7.06484e-05) | 0.048871 ± 0.000148463 (W 5.321e-05) | · | 🔵 fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112447 ± 0.000312617 (W 0.000225715) | 0.11269 ± 0.000811889 (W 0.00141029) | 0.10041 ± 0.000230937 (W 0.00143449) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.484706 ± 0.000636839 (W 0.00257181) | 0.484782 ± 0.00158497 (W 0.00220931) | 0.3946 ± 0.00100681 (W 0.00276276) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.16053 ± 0.00384937 (W 0.00220582) | 1.15953 ± 0.003747 (W 0.00212253) | 0.911779 ± 0.00475155 (W 0.00672265) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011953 ± 0.000221798 (W 9.67998e-05) | 0.01057 ± 0.000419142 (W 5.53381e-05) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051796 ± 8.27124e-05 (W 0.000218449) | 0.046927 ± 0.000216842 (W 0.000201483) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.146326 ± 0.00177249 (W 0.00248898) | 0.135741 ± 0.00148187 (W 0.00275157) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008165 ± 2.08167e-05 (W 8.64483e-05) | 0.008095 ± 2.3094e-05 (W 4.5607e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008205 ± 7.50555e-05 (W 2.96648e-05) | 0.008145 ± 5.50757e-05 (W 3.97492e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040555 ± 0.000162287 (W 0.000158279) | 0.040244 ± 0.000278156 (W 9.3644e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040646 ± 0.000168277 (W 0.00019518) | 0.040585 ± 0.000183794 (W 0.00128029) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.120643 ± 0.000289669 (W 0.00137302) | 0.120643 ± 0.000197864 (W 0.001646) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.120938 ± 0.000418146 (W 0.000224445) | 0.120753 ± 0.000210405 (W 0.0019217) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008426 ± 7.81025e-05 (W 5.87639e-05) | 0.007354 ± 0.00020352 (W 5.63933e-05) | 0.012122 ± 0.000101489 (W 6.15573e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031067 ± 0.000381996 (W 0.000111221) | 0.02664 ± 0.000317065 (W 0.000117813) | 0.04323 ± 0.000323994 (W 9.60432e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.077794 ± 0.00134929 (W 0.00226498) | 0.068006 ± 0.00135765 (W 0.0022784) | 0.110715 ± 0.0010137 (W 0.00262962) | 🔴 fork 1.14× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.032971 ± 0.000107364 (W 6.05805e-05) | 0.031749 ± 4.89932e-05 (W 0.000193479) | 0.026799 ± 0.0336653 (W 0.000110227) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.120664 ± 0.000359686 (W 0.00137658) | 0.117217 ± 8.95396e-05 (W 0.00165261) | 0.133356 ± 0.0012301 (W 0.000440582) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.301178 ± 0.00169554 (W 0.00214543) | 0.295788 ± 0.000424064 (W 0.00138958) | 0.410965 ± 0.00402278 (W 0.00288161) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.021991 ± 2.9e-05 (W 9.69562e-05) | 0.028092 ± 4.30155e-05 (W 0.000143608) | 0.014217 ± 7.13933e-05 (W 8.88217e-05) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.088054 ± 0.000416505 (W 0.00178145) | 0.130553 ± 0.000401301 (W 0.000200503) | 0.298793 ± 0.133409 (W 0.00147146) | 🔵 fork 1.48× faster than `faer-upstream` | 🔵 fork 3.39× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.19359 ± 0.00060452 (W 0.00173977) | 0.284948 ± 0.000452644 (W 0.00157449) | 0.204658 ± 0.000962804 (W 0.00183681) | 🔵 fork 1.47× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009768 ± 4.72582e-05 (W 3.63318e-05) | 0.008156 ± 0.000125527 (W 5.43811e-05) | 0.012954 ± 0.000109138 (W 4.95812e-05) | 🔴 fork 1.20× slower than `faer-upstream` | 🔵 fork 1.33× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031409 ± 0.000176922 (W 0.000166884) | 0.027291 ± 0.000161298 (W 4.97996e-05) | 0.04381 ± 0.000367477 (W 0.000100609) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.079487 ± 0.00188463 (W 0.00243712) | 0.070273 ± 0.00187934 (W 0.00256041) | 0.103876 ± 0.000279296 (W 0.000258624) | 🔴 fork 1.13× slower than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.182429 ± 0.00182108 (W 0.0016042) | 0.182795 ± 0.000474321 (W 0.0017132) | 0.178009 ± 0.000240851 (W 0.00147359) | · | · |  |
| `svd_thin/n64/b1` | 0.910904 ± 0.00359441 (W 0.00154568) | 0.913719 ± 0.00327661 (W 0.000646137) | 0.741059 ± 0.00324402 (W 0.00380125) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.21239 ± 0.0391362 (W 0.00262183) | 2.22279 ± 0.00743262 (W 0.00501665) | 1.69267 ± 0.0509962 (W 0.0104786) | · | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140856 ± 0.000420922 (W 0.00112742) | 0.140424 ± 9.73875e-05 (W 0.00133294) | 0.064361 ± 0.0428762 (W 6.36498e-05) | · | 🔴 fork 2.19× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.515452 ± 0.00203155 (W 0.00167145) | 0.517574 ± 0.00210253 (W 0.00216185) | 0.26535 ± 0.000730878 (W 0.00168467) | · | 🔴 fork 1.94× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18369 ± 0.00177495 (W 0.00169618) | 1.18368 ± 0.00258465 (W 0.00264365) | 0.634546 ± 0.00431222 (W 0.0021755) | · | 🔴 fork 1.87× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000671 ± 9.50438e-06 (W 8.94427e-06) | 0.000681 ± 6.08276e-06 (W 7.0852e-06) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001483 ± 4.04145e-05 (W 7.0852e-06) | 0.001513 ± 2.08167e-05 (W 2.30217e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002665 ± 0.000115326 (W 2.91548e-05) | 0.002725 ± 8.96289e-05 (W 3.96232e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003456 ± 0.000176466 (W 2.80571e-05) | 0.003417 ± 3.06649e-05 (W 5.2281e-05) | 0.004168 ± 1.57162e-05 (W 4.43847e-05) | · | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.017022 ± 0.00103524 (W 2.86234e-05) | 0.016501 ± 8.7178e-05 (W 3.55711e-05) | 0.016801 ± 0.000107858 (W 8.05556e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.050894 ± 0.00107622 (W 0.00241145) | 0.061336 ± 0.000207491 (W 0.00229534) | 0.048391 ± 0.000116509 (W 0.000105867) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 1.05× slower than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.113099 ± 0.000127424 (W 0.000207916) | 0.113664 ± 0.000930649 (W 0.000191774) | 0.105396 ± 2.51462e-05 (W 0.000979316) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.504981 ± 0.00548247 (W 0.00318185) | 0.502346 ± 0.00539428 (W 0.0035587) | 0.274782 ± 0.0347362 (W 0.00217489) | · | 🔴 fork 1.84× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `eigh/n96/b1` | 1.22561 ± 0.0140171 (W 0.0264517) | 1.21916 ± 0.0105672 (W 0.02059) | 0.590632 ± 0.00250204 (W 0.00140679) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011832 ± 0.000296142 (W 5.41221e-05) | 0.010619 ± 0.000185689 (W 5.53832e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051567 ± 0.00012676 (W 0.000262834) | 0.046797 ± 0.000191106 (W 9.03881e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144512 ± 0.000214063 (W 0.00414134) | 0.134243 ± 0.000163899 (W 0.00257712) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008235 ± 2.60832e-05 (W 3.50714e-05) | 0.008435 ± 5.80259e-05 (W 6.07882e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008426 ± 0.000155725 (W 6.1887e-05) | 0.008466 ± 0.00168326 (W 0.00148715) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.024485 ± 0.000256206 (W 0.000290311) | 0.024536 ± 0.000390871 (W 0.000901238) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.025007 ± 0.000600256 (W 0.000490041) | 0.024736 ± 0.000607744 (W 0.00069221) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.049672 ± 0.000199425 (W 0.00141002) | 0.049973 ± 0.000929676 (W 0.00119155) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.049772 ± 9.17624e-05 (W 0.000644734) | 0.050093 ± 0.000386513 (W 0.000569729) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008526 ± 3.27159e-05 (W 7.26512e-05) | 0.007223 ± 0.000106927 (W 1.92354e-05) | 0.012253 ± 1.52753e-05 (W 7.10634e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.031057 ± 1.00167e-05 (W 0.0017686) | 0.045105 ± 0.000961952 (W 0.00283118) | 0.042879 ± 8.66045e-05 (W 8.40833e-05) | 🔵 fork 1.45× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.07566 ± 0.000184511 (W 0.00229951) | 0.10262 ± 0.00285752 (W 0.00754758) | 0.093496 ± 8.56524e-05 (W 0.00131223) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.032851 ± 0.000138904 (W 0.000177559) | 0.113189 ± 0.0050744 (W 0.00498233) | 0.026318 ± 0.0335721 (W 8.59087e-05) | 🔵 fork 3.45× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.170116 ± 0.00140591 (W 0.00427466) | 0.502461 ± 0.0183938 (W 0.00794502) | 0.146491 ± 0.000222967 (W 0.00123134) | 🔵 fork 2.95× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.390976 ± 0.02643 (W 0.0232325) | 1.06389 ± 0.0160238 (W 0.0219697) | 0.332366 ± 0.000856374 (W 0.00465347) | 🔵 fork 2.72× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.042769 ± 0.00389319 (W 0.000871103) | 0.09169 ± 0.00391324 (W 0.00374847) | 0.014186 ± 0.000120652 (W 5.01827e-05) | 🔵 fork 2.14× faster than `faer-upstream` | 🔴 fork 3.01× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.109507 ± 0.0059913 (W 0.00262849) | 0.486466 ± 0.00938335 (W 0.00812) | 0.298182 ± 0.134076 (W 0.00125728) | 🔵 fork 4.44× faster than `faer-upstream` | 🔵 fork 2.72× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.21755 ± 0.000848071 (W 0.00280049) | 0.998368 ± 0.012822 (W 0.0138719) | 0.941994 ± 0.000415508 (W 0.0007989) | 🔵 fork 4.59× faster than `faer-upstream` | 🔵 fork 4.33× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009338 ± 4.6188e-05 (W 5.27286e-05) | 0.008145 ± 0.000219317 (W 0.000118386) | 0.012804 ± 0.00012766 (W 4.72462e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.031689 ± 0.000125607 (W 0.00158548) | 0.046236 ± 0.000813052 (W 0.00264985) | 0.04344 ± 6.57597e-05 (W 9.45902e-05) | 🔵 fork 1.46× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.077464 ± 0.000152451 (W 0.000302652) | 0.105589 ± 0.00326363 (W 0.00365458) | 0.087332 ± 0.000147222 (W 0.000297433) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.186842 ± 0.00392866 (W 0.00475867) | 0.187058 ± 0.00254893 (W 0.00433079) | 0.185796 ± 0.000739029 (W 0.00111933) | · | · |  |
| `svd_thin/n64/b1` | 0.949057 ± 0.00273235 (W 0.00118364) | 0.946953 ± 0.00308331 (W 0.00391466) | 0.670398 ± 0.00299437 (W 0.00235828) | · | 🔴 fork 1.42× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32213 ± 0.0268029 (W 0.0180428) | 2.28776 ± 0.0358415 (W 0.0248076) | 1.4068 ± 0.0488645 (W 0.00300528) | · | 🔴 fork 1.65× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140645 ± 0.000142116 (W 0.00161033) | 0.140382 ± 0.000130399 (W 0.00183075) | 0.064702 ± 0.0426417 (W 0.000118221) | · | 🔴 fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.517318 ± 0.00200988 (W 0.00172916) | 0.516647 ± 0.00130983 (W 0.00289039) | 0.269652 ± 0.0011598 (W 0.00134352) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18029 ± 0.00181686 (W 0.00192697) | 1.18169 ± 0.00319062 (W 0.00105504) | 0.602845 ± 0.001551 (W 0.0016846) | · | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000681 ± 9.50438e-06 (W 1.66223e-05) | 0.000682 ± 9.50438e-06 (W 2.07196e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001483 ± 1.09697e-05 (W 1.85796e-05) | 0.001493 ± 1.1547e-05 (W 8.94427e-06) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002595 ± 1.73205e-05 (W 2.58844e-05) | 0.002585 ± 8.7178e-05 (W 3.87595e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003456 ± 0.000185023 (W 4.89418e-05) | 0.003386 ± 1.52753e-05 (W 2.09093e-05) | 0.004178 ± 1e-05 (W 2.91428e-05) | · | 🔵 fork 1.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.017052 ± 0.00113237 (W 3.49285e-05) | 0.016571 ± 5.50757e-05 (W 3.89872e-05) | 0.016811 ± 7.02163e-05 (W 6.61309e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.056526 ± 0.00216314 (W 0.00325484) | 0.073208 ± 0.000403686 (W 0.0012537) | 0.04852 ± 0.000557055 (W 9.92336e-05) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.113213 ± 0.00044678 (W 0.000427675) | 0.113043 ± 0.000665967 (W 0.000467101) | 0.106237 ± 0.000109503 (W 0.0015232) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.50764 ± 0.00165025 (W 0.00374643) | 0.506559 ± 0.00227627 (W 0.00473782) | 0.263739 ± 0.000687716 (W 0.0013828) | · | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.25642 ± 0.0106149 (W 0.0187813) | 1.2551 ± 0.00573657 (W 0.0162292) | 0.575282 ± 0.00147828 (W 0.00317846) | · | 🔴 fork 2.18× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.011992 ± 0.000119304 (W 8.21906e-05) | 0.010489 ± 0.00012546 (W 2.85535e-05) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051606 ± 0.000310698 (W 0.000159559) | 0.046777 ± 0.000521671 (W 0.000233849) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.144422 ± 0.00244107 (W 0.00249643) | 0.133017 ± 0.00281649 (W 0.00235798) | - | 🔴 fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008225 ± 5.34821e-05 (W 7.33164e-05) | 0.008366 ± 7.53459e-05 (W 8.6487e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008336 ± 1.51767e-05 (W 3.84708e-05) | 0.008346 ± 4.39356e-05 (W 6.72109e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.020218 ± 0.00122033 (W 0.000493033) | 0.027531 ± 0.00094671 (W 0.00138348) | - | 🔵 fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020678 ± 0.000386283 (W 0.00139612) | 0.028714 ± 0.00296285 (W 0.00203689) | - | 🔵 fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.03731 ± 0.000344632 (W 0.000724157) | 0.062267 ± 0.00111387 (W 0.00271047) | - | 🔵 fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.03814 ± 0.000506164 (W 0.00168386) | 0.063279 ± 0.00142438 (W 0.00182943) | - | 🔵 fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008606 ± 8.5049e-05 (W 8.6036e-05) | 0.007113 ± 2.08167e-05 (W 3.6169e-05) | 0.012253 ± 0.000123977 (W 5.66242e-05) | 🔴 fork 1.21× slower than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.030708 ± 0.000228417 (W 0.000200732) | 0.052818 ± 0.000491922 (W 0.00291416) | 0.042549 ± 0.00020576 (W 0.000135179) | 🔵 fork 1.72× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.076192 ± 0.000355468 (W 0.00225079) | 0.116706 ± 0.00623891 (W 0.0064656) | 0.085799 ± 0.0029079 (W 0.000251784) | 🔵 fork 1.53× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.032681 ± 0.000107472 (W 0.000174465) | 0.142167 ± 0.00222475 (W 0.00491509) | 0.0264 ± 0.0336828 (W 0.00160302) | 🔵 fork 4.35× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.162251 ± 0.00200948 (W 0.00359212) | 0.679168 ± 0.0108095 (W 0.0184142) | 0.158204 ± 0.000637407 (W 0.00191983) | 🔵 fork 4.19× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.418115 ± 0.0127893 (W 0.0209467) | 1.41756 ± 0.0243899 (W 0.0222775) | 0.325823 ± 0.00807102 (W 0.00169512) | 🔵 fork 3.39× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.041097 ± 0.000354741 (W 0.00121941) | 0.126007 ± 0.000994973 (W 0.00684647) | 0.014016 ± 6.16468e-05 (W 5.61445e-05) | 🔵 fork 3.07× faster than `faer-upstream` | 🔴 fork 2.93× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.111727 ± 0.000686041 (W 0.00132079) | 0.65287 ± 0.00862511 (W 0.0141379) | 0.298603 ± 0.133598 (W 0.00126091) | 🔵 fork 5.84× faster than `faer-upstream` | 🔵 fork 2.67× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.210962 ± 0.00196408 (W 0.00893835) | 1.30556 ± 0.010362 (W 0.0228771) | 0.937818 ± 0.000891159 (W 0.000842086) | 🔵 fork 6.19× faster than `faer-upstream` | 🔵 fork 4.45× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.009508 ± 4.0501e-05 (W 4.16197e-05) | 0.008236 ± 0.000172143 (W 7.19674e-05) | 0.012824 ± 8.3865e-05 (W 5.80706e-05) | 🔴 fork 1.15× slower than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.03167 ± 0.000219682 (W 0.000110482) | 0.053609 ± 0.000893254 (W 0.00310122) | 0.043542 ± 0.000268753 (W 0.000133878) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.071272 ± 0.00373892 (W 0.00020737) | 0.112768 ± 0.00818472 (W 0.00523304) | 0.085209 ± 0.000361189 (W 0.000222565) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.18266 ± 0.000394536 (W 0.00178048) | 0.1835 ± 0.00123016 (W 0.00156571) | 0.186676 ± 0.00113704 (W 0.0015819) | · | · |  |
| `svd_thin/n64/b1` | 0.969725 ± 0.00323857 (W 0.00401114) | 0.973202 ± 0.00511223 (W 0.00773678) | 0.660873 ± 0.00109975 (W 0.00400815) | · | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.32803 ± 0.0322602 (W 0.016561) | 2.33861 ± 0.00916574 (W 0.0203693) | 1.35405 ± 0.0464464 (W 0.0023391) | · | 🔴 fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.140374 ± 0.000302378 (W 0.00015225) | 0.140261 ± 0.000314242 (W 0.00143051) | 0.06483 ± 0.0424393 (W 0.000112135) | · | 🔴 fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.516611 ± 0.000444815 (W 0.00170594) | 0.517153 ± 0.000986309 (W 0.00239823) | 0.26996 ± 0.000826487 (W 0.00151199) | · | 🔴 fork 1.91× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18118 ± 0.0046873 (W 0.00256379) | 1.18335 ± 0.00439774 (W 0.00211199) | 0.598494 ± 0.000999176 (W 0.00194386) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000661 ± 5.7735e-06 (W 1.62542e-05) | 0.000662 ± 6.08276e-06 (W 1.65318e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001473 ± 2.3388e-05 (W 1.66223e-05) | 0.001473 ± 2.51661e-05 (W 1.09179e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002655 ± 6.1403e-05 (W 2.00075e-05) | 0.002584 ± 1.00167e-05 (W 3.14356e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003116 ± 2e-05 (W 2.54598e-05) | 0.003296 ± 5.1316e-05 (W 3.22676e-05) | 0.003366 ± 2e-05 (W 1.65288e-05) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.08× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014788 ± 8.3668e-05 (W 3.29287e-05) | 0.01627 ± 0.00200029 (W 8.51481e-05) | 0.014146 ± 9.21973e-05 (W 3.42053e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.030196 ± 3.05014e-05 (W 5.56776e-05) | 0.028404 ± 0.00228515 (W 0.000101021) | 0.038312 ± 3.76431e-05 (W 7.50353e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112638 ± 0.000418075 (W 0.000155902) | 0.113204 ± 0.00018029 (W 0.001194) | 0.099057 ± 0.000576735 (W 0.000264073) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.483975 ± 0.00164403 (W 0.00193688) | 0.484703 ± 0.00151147 (W 0.00241123) | 0.388903 ± 0.00193037 (W 0.00309893) | · | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.15955 ± 0.00445307 (W 0.0024807) | 1.15841 ± 0.00482512 (W 0.00237184) | 0.890627 ± 0.00783369 (W 0.00617666) | · | 🔴 fork 1.30× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010439 ± 1.18462e-05 (W 0.0001251) | 0.010309 ± 0.00021443 (W 6.40796e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046717 ± 0.000310516 (W 0.00127734) | 0.045935 ± 4.63717e-05 (W 0.000199933) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.134343 ± 0.00138973 (W 0.00222022) | 0.133727 ± 0.00192534 (W 0.00225337) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008225 ± 3.45977e-05 (W 4.52769e-05) | 0.008125 ± 2.51661e-05 (W 3.83406e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008276 ± 6.4291e-05 (W 7.40426e-05) | 0.008275 ± 6.60328e-05 (W 1.11445e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040015 ± 7.01498e-05 (W 0.00016114) | 0.040195 ± 0.000110564 (W 7.25899e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040356 ± 0.000165258 (W 0.00149458) | 0.040545 ± 0.00012454 (W 0.000107439) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.122917 ± 0.000483945 (W 0.000160095) | 0.123029 ± 0.000840458 (W 0.000148318) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.123157 ± 0.00049787 (W 0.000180867) | 0.122777 ± 0.000473665 (W 0.000230135) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007083 ± 8.3668e-05 (W 4.97624e-05) | 0.007023 ± 0.000226297 (W 4.66905e-05) | 0.009718 ± 5.50757e-05 (W 0.000109655) | · | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025568 ± 0.000365711 (W 0.000176534) | 0.025859 ± 3.50761e-05 (W 0.000181301) | 0.033963 ± 0.000224502 (W 9.49437e-05) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.065301 ± 0.00134172 (W 0.0023298) | 0.065754 ± 0.00152989 (W 0.00232669) | 0.074588 ± 0.000215644 (W 0.000120836) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.031178 ± 2.74044e-05 (W 0.000145386) | 0.031628 ± 0.000205576 (W 0.000123204) | 0.02177 ± 0.000162287 (W 0.000137616) | · | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.114426 ± 0.000821992 (W 0.00142228) | 0.114325 ± 3.25167e-05 (W 0.000322127) | 0.115538 ± 0.00120876 (W 0.00154649) | · | · |  |
| `qr/n96/b1` | 0.28496 ± 0.00175116 (W 0.00352443) | 0.285879 ± 0.000540123 (W 0.00318184) | 0.344269 ± 0.00191627 (W 0.00207275) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017452 ± 0.000136297 (W 0.000122075) | 0.018084 ± 5.03322e-05 (W 0.000114761) | 0.011572 ± 3.17857e-05 (W 4.39318e-05) | · | 🔴 fork 1.51× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.073339 ± 0.000295273 (W 0.000356853) | 0.073759 ± 0.000709193 (W 0.00154906) | 0.289646 ± 0.00151819 (W 0.00140532) | · | 🔵 fork 3.95× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.160659 ± 0.000521016 (W 0.00151433) | 0.162115 ± 0.00037198 (W 0.000371511) | 0.92955 ± 0.000436206 (W 0.000780324) | · | 🔵 fork 5.79× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007784 ± 4.93288e-05 (W 3.3441e-05) | 0.007854 ± 0.0001245 (W 4.23474e-05) | 0.009868 ± 0.000108167 (W 5.65712e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025869 ± 0.000328788 (W 0.00121154) | 0.026219 ± 0.000273924 (W 9.28978e-05) | 0.033522 ± 0.000244924 (W 0.00010874) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.067786 ± 0.00139795 (W 0.00250287) | 0.06851 ± 0.000944595 (W 0.00237203) | 0.073726 ± 3.32014e-05 (W 0.000168908) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.185403 ± 0.000654818 (W 0.00139017) | 0.185293 ± 0.00105657 (W 0.00162116) | 0.168217 ± 0.000314701 (W 0.00188706) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.955646 ± 0.00280888 (W 0.00170368) | 0.958528 ± 0.00211144 (W 0.00130854) | 0.694422 ± 0.000311029 (W 0.00302097) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.15581 ± 0.00616585 (W 0.00602622) | 2.1514 ± 0.00140507 (W 0.00281036) | 1.62517 ± 0.00472766 (W 0.00687586) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142383 ± 0.000495512 (W 0.00143179) | 0.142389 ± 0.000471137 (W 0.00143585) | 0.059302 ± 0.000280858 (W 9.9996e-05) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537253 ± 0.00334316 (W 0.00176016) | 0.537343 ± 0.00178205 (W 0.00254065) | 0.254594 ± 0.000716972 (W 0.00129921) | · | 🔴 fork 2.11× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18633 ± 0.00535236 (W 0.00216818) | 1.18894 ± 0.00220499 (W 0.00228997) | 0.608555 ± 0.00239438 (W 0.00225849) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000741 ± 5.83124e-05 (W 1.38636e-05) | 0.000762 ± 5.80259e-05 (W 1.9139e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001883 ± 8.75043e-05 (W 1.08766e-05) | 0.001823 ± 0.000142432 (W 1.58209e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003356 ± 0.000137914 (W 1.91364e-05) | 0.003056 ± 9.81495e-05 (W 3.36497e-05) | - | 🔴 fork 1.10× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003356 ± 0.000151438 (W 3.00716e-05) | 0.003347 ± 2.94449e-05 (W 3.01712e-05) | 0.003366 ± 2.88675e-05 (W 3.35589e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.016751 ± 0.000952284 (W 2.8728e-05) | 0.01618 ± 6.1101e-05 (W 5.06389e-05) | 0.014167 ± 0.000211069 (W 5.92309e-05) | · | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.051406 ± 0.00135994 (W 0.000576985) | 0.059272 ± 0.00118508 (W 0.00173462) | 0.038201 ± 0.000291717 (W 0.000148655) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.113184 ± 0.000210013 (W 0.000209286) | 0.113682 ± 0.000762952 (W 0.000320601) | 0.103543 ± 0.000454822 (W 0.00124104) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.502056 ± 0.00231358 (W 0.00370105) | 0.503417 ± 0.00699957 (W 0.0026672) | 0.266644 ± 0.000125922 (W 0.00188678) | · | 🔴 fork 1.88× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.21962 ± 0.00358371 (W 0.018657) | 1.22056 ± 0.00920526 (W 0.0189898) | 0.580294 ± 0.00110877 (W 0.00144486) | · | 🔴 fork 2.10× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01039 ± 9.07377e-05 (W 3.84994e-05) | 0.010469 ± 0.000121698 (W 5.12835e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.046217 ± 0.000392022 (W 0.00147025) | 0.046226 ± 0.000419395 (W 0.000107337) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132075 ± 0.000698299 (W 0.00238223) | 0.131808 ± 0.000392814 (W 0.00176104) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008226 ± 5.0797e-05 (W 2.75717e-05) | 0.008416 ± 0.00015019 (W 0.000135446) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008275 ± 8.67583e-05 (W 5.44362e-05) | 0.008466 ± 6.68356e-05 (W 9.18161e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.035086 ± 0.00383867 (W 0.0032229) | 0.023934 ± 7.02875e-05 (W 0.00105631) | - | 🔴 fork 1.47× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.027822 ± 0.000471566 (W 0.00308231) | 0.024065 ± 0.000609502 (W 0.000688758) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.05947 ± 0.000124557 (W 0.000635318) | 0.049482 ± 0.000607408 (W 0.00176401) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.059911 ± 0.000181274 (W 0.000349111) | 0.049853 ± 0.000516941 (W 0.00142142) | - | 🔴 fork 1.20× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007064 ± 7.62693e-05 (W 6.64853e-05) | 0.007043 ± 0.000104403 (W 6.3539e-05) | 0.009648 ± 0.000117304 (W 8.62862e-05) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025919 ± 0.000194243 (W 0.001556) | 0.045575 ± 0.00121124 (W 0.000641273) | 0.033714 ± 0.000197335 (W 0.000171655) | 🔵 fork 1.76× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.063118 ± 2.9e-05 (W 0.00213598) | 0.102911 ± 0.00291512 (W 0.00395206) | 0.07442 ± 0.000352309 (W 0.000250813) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031198 ± 0.000159124 (W 0.00144897) | 0.114021 ± 0.000552428 (W 0.00553362) | 0.021169 ± 0.0001138 (W 0.00153792) | 🔵 fork 3.65× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.143758 ± 0.00148423 (W 0.0013141) | 0.493865 ± 0.0112236 (W 0.00822727) | 0.127236 ± 0.00145296 (W 0.00126873) | 🔵 fork 3.44× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.362991 ± 0.0292414 (W 0.027172) | 1.0553 ± 0.0149435 (W 0.0164717) | 0.29236 ± 0.00131006 (W 0.00276912) | 🔵 fork 2.91× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017592 ± 9.55214e-05 (W 8.39476e-05) | 0.080399 ± 0.00216425 (W 0.00228232) | 0.011481 ± 1.57162e-05 (W 5.01996e-05) | 🔵 fork 4.57× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.104257 ± 0.000353248 (W 0.00420883) | 0.418164 ± 0.0150698 (W 0.00763465) | 0.289669 ± 0.000496317 (W 0.0016877) | 🔵 fork 4.01× faster than `faer-upstream` | 🔵 fork 2.78× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.194633 ± 0.0282428 (W 0.00518973) | 0.880088 ± 0.0191995 (W 0.0119492) | 0.930211 ± 0.00142835 (W 0.00101638) | 🔵 fork 4.52× faster than `faer-upstream` | 🔵 fork 4.78× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.007714 ± 8.14453e-05 (W 7.76872e-05) | 0.007785 ± 4.6188e-05 (W 4.50577e-05) | 0.009858 ± 3.80832e-05 (W 4.08571e-05) | · | 🔵 fork 1.28× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026058 ± 8.92767e-05 (W 0.000149265) | 0.043962 ± 0.00116083 (W 0.00352113) | 0.033632 ± 0.00011185 (W 0.000103296) | 🔵 fork 1.69× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.065392 ± 0.000218275 (W 0.00249524) | 0.103074 ± 0.00847759 (W 0.00375685) | 0.074058 ± 0.000381843 (W 0.00020911) | 🔵 fork 1.58× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.190108 ± 0.00351062 (W 0.00346114) | 0.185579 ± 0.0027077 (W 0.00642262) | 0.175065 ± 0.000417948 (W 0.00154316) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.991376 ± 0.00161371 (W 0.00279702) | 0.994412 ± 0.00263555 (W 0.00180645) | 0.639881 ± 0.00320425 (W 0.00197) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.33724 ± 0.0500262 (W 0.0175151) | 2.26822 ± 0.0362999 (W 0.0158) | 1.37036 ± 0.00123305 (W 0.0055063) | · | 🔴 fork 1.71× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.141974 ± 0.000549757 (W 0.00149468) | 0.141927 ± 0.000270622 (W 0.00132496) | 0.0592 ± 0.000165995 (W 0.000192669) | · | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.536819 ± 0.00219665 (W 0.00165092) | 0.537392 ± 0.000691863 (W 0.00216394) | 0.257885 ± 0.000147421 (W 0.00139263) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18392 ± 0.0040348 (W 0.0132272) | 1.18338 ± 0.00446518 (W 0.00196061) | 0.600992 ± 0.000603869 (W 0.00204724) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000762 ± 2.00083e-05 (W 1.68018e-05) | 0.000761 ± 1.52753e-05 (W 3.16433e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001813 ± 2.51064e-05 (W 3.09063e-05) | 0.001803 ± 1.0504e-05 (W 2.04939e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003085 ± 0.000139249 (W 2.27002e-05) | 0.002896 ± 3.52184e-05 (W 3.51326e-05) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003367 ± 0.000206786 (W 2.82843e-05) | 0.003296 ± 2.64575e-05 (W 1.92354e-05) | 0.003366 ± 5.50757e-06 (W 2.44377e-05) | · | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.015189 ± 0.00178055 (W 2.92797e-05) | 0.016311 ± 0.0016779 (W 4.62958e-05) | 0.013966 ± 0.000190788 (W 5.88838e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.057307 ± 0.000128012 (W 0.00334773) | 0.072424 ± 0.000519824 (W 0.00310234) | 0.037811 ± 0.000222144 (W 7.36885e-05) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.52× slower than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.11278 ± 7.85005e-05 (W 0.00144012) | 0.112992 ± 0.000833368 (W 0.000254659) | 0.104735 ± 0.000175227 (W 0.00145811) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.506813 ± 0.00326358 (W 0.00353059) | 0.508787 ± 0.0039065 (W 0.00612006) | 0.25781 ± 0.000341008 (W 0.00172008) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.25895 ± 0.00393797 (W 0.0324538) | 1.2575 ± 0.0123564 (W 0.0209768) | 0.56314 ± 0.00227396 (W 0.00288363) | · | 🔴 fork 2.24× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.010389 ± 0.000144915 (W 0.00012818) | 0.01055 ± 7.37111e-05 (W 7.6021e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045876 ± 0.000314293 (W 0.000270588) | 0.045825 ± 0.000358316 (W 0.00150174) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.128748 ± 0.00215808 (W 0.00169681) | 0.128121 ± 0.00205808 (W 0.00378661) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008166 ± 1.53948e-05 (W 3.11448e-05) | 0.008416 ± 2.08167e-05 (W 0.000117146) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008195 ± 6.20511e-05 (W 5.74047e-05) | 0.008456 ± 3.21455e-05 (W 9.20451e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.027901 ± 0.00064279 (W 0.00117799) | 0.027962 ± 0.000660373 (W 0.00110219) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.028473 ± 0.00124426 (W 0.000778759) | 0.027772 ± 0.000123977 (W 0.00106292) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.043401 ± 0.00391613 (W 0.00428184) | 0.060832 ± 0.00189683 (W 0.00197036) | - | 🔵 fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.050354 ± 0.00023963 (W 0.00412653) | 0.062676 ± 0.000878398 (W 0.00170985) | - | 🔵 fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007183 ± 0.000144627 (W 4.40715e-05) | 0.007033 ± 8.92767e-05 (W 7.24583e-05) | 0.009628 ± 9.29157e-05 (W 8.40851e-05) | · | 🔵 fork 1.34× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025738 ± 0.000116477 (W 0.000285383) | 0.051998 ± 0.00158202 (W 0.00360692) | 0.033533 ± 2.3388e-05 (W 9.09021e-05) | 🔵 fork 2.02× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.05924 ± 0.00253653 (W 0.00168912) | 0.115315 ± 0.0026941 (W 0.00505686) | 0.074078 ± 0.000511536 (W 0.000118448) | 🔵 fork 1.95× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n32/b1` | 0.031119 ± 0.000246408 (W 0.000123605) | 0.14531 ± 0.00460347 (W 0.00420141) | 0.0212 ± 0.000125779 (W 7.09225e-05) | 🔵 fork 4.67× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.147193 ± 0.000919704 (W 0.00241387) | 0.666615 ± 0.021149 (W 0.0142323) | 0.138667 ± 0.00187061 (W 0.00214672) | 🔵 fork 4.53× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n96/b1` | 0.381698 ± 0.0106277 (W 0.0239783) | 1.41109 ± 0.0106595 (W 0.0274118) | 0.304146 ± 0.00118976 (W 0.00163566) | 🔵 fork 3.70× faster than `faer-upstream` | 🔴 fork 1.25× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017463 ± 0.000110666 (W 0.000130806) | 0.111367 ± 0.00207759 (W 0.005157) | 0.011512 ± 8.13654e-05 (W 5.09902e-05) | 🔵 fork 6.38× faster than `faer-upstream` | 🔴 fork 1.52× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.093213 ± 0.00124257 (W 0.000990912) | 0.59128 ± 0.00442275 (W 0.0164125) | 0.289238 ± 0.00029392 (W 0.0014498) | 🔵 fork 6.34× faster than `faer-upstream` | 🔵 fork 3.10× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.190538 ± 0.00468522 (W 0.00749535) | 1.17993 ± 0.0134012 (W 0.0147595) | 0.92951 ± 0.000708521 (W 0.000707835) | 🔵 fork 6.19× faster than `faer-upstream` | 🔵 fork 4.88× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.007815 ± 9.50438e-05 (W 4.02654e-05) | 0.007805 ± 5.45008e-05 (W 3.55711e-05) | 0.009958 ± 8.63153e-05 (W 4.66905e-05) | · | 🔵 fork 1.27× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.025858 ± 0.000216288 (W 0.00012705) | 0.053239 ± 0.00323082 (W 0.00330956) | 0.033423 ± 3.61663e-05 (W 0.000108694) | 🔵 fork 2.06× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `solve/n96/b1` | 0.059239 ± 0.00382037 (W 0.000169477) | 0.11156 ± 0.0130726 (W 0.00887991) | 0.074117 ± 0.000323198 (W 0.000220336) | 🔵 fork 1.88× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.184533 ± 0.000278525 (W 0.00118162) | 0.184412 ± 5.66951e-05 (W 0.00233412) | 0.177779 ± 0.000635535 (W 0.00159089) | · | · |  |
| `svd_thin/n64/b1` | 1.01368 ± 0.00341963 (W 0.00377742) | 1.01863 ± 0.00827968 (W 0.00619885) | 0.630879 ± 0.00215411 (W 0.00222418) | · | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31063 ± 0.044097 (W 0.0113552) | 2.32597 ± 0.0117894 (W 0.0143562) | 1.32381 ± 0.0111871 (W 0.00176062) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.142288 ± 0.000199256 (W 0.00134734) | 0.142265 ± 0.00112088 (W 0.00133557) | 0.059149 ± 4.10163e-05 (W 0.00011419) | · | 🔴 fork 2.41× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.537536 ± 0.00148663 (W 0.00250431) | 0.536855 ± 0.00150101 (W 0.00224755) | 0.258601 ± 0.000440504 (W 0.00114511) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.18849 ± 0.0035324 (W 0.00260827) | 1.18897 ± 0.00217151 (W 0.00198551) | 0.599566 ± 0.000974559 (W 0.00188916) | · | 🔴 fork 1.98× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.000792 ± 0.000165227 (W 2.18472e-05) | 0.000761 ± 0.000113271 (W 1.30384e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001773 ± 9.56399e-05 (W 1.54693e-05) | 0.001693 ± 5.47449e-05 (W 1.14018e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003086 ± 3.04467e-05 (W 3.20936e-05) | 0.003046 ± 0.000115889 (W 2.14523e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00521 ± 1.67432e-05 (W 3.0138e-05) | 0.0052 ± 9.50438e-06 (W 2.44949e-05) | 0.008796 ± 0.000118027 (W 4.0513e-05) | · | 🔵 fork 1.69× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030517 ± 0.000180093 (W 8.13634e-05) | 0.030206 ± 0.000163025 (W 5.58766e-05) | 0.051556 ± 0.0008676 (W 0.000318253) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.084396 ± 0.000268814 (W 0.000113886) | 0.084257 ± 0.000255429 (W 0.000170779) | 0.138747 ± 0.000355331 (W 0.0016115) | · | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141714 ± 0.000265671 (W 0.00157582) | 0.141644 ± 0.000449269 (W 0.00156025) | 0.150949 ± 0.000123016 (W 0.00156419) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.65025 ± 0.00169008 (W 0.00202504) | 0.647891 ± 0.000957292 (W 0.00214142) | 0.81151 ± 0.00115062 (W 0.00272295) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.62037 ± 0.00593014 (W 0.00624026) | 1.61673 ± 0.00172411 (W 0.00235808) | 2.03219 ± 0.00315566 (W 0.00108209) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017473 ± 4.59021e-05 (W 8.14248e-05) | 0.01579 ± 3.50761e-05 (W 5.31977e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097732 ± 0.000471145 (W 0.00158217) | 0.092294 ± 0.000676707 (W 0.000294969) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.28115 ± 0.000766992 (W 0.00319819) | 0.267405 ± 0.000279448 (W 0.00183523) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028053 ± 0.000115284 (W 8.17447e-05) | 0.028122 ± 0.000145332 (W 0.00129485) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028123 ± 0.000122639 (W 4.51907e-05) | 0.028294 ± 0.000100732 (W 8.01081e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.15909 ± 0.000526908 (W 0.00160285) | 0.15897 ± 0.000340738 (W 0.0015938) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.160072 ± 0.000791525 (W 0.00152522) | 0.158886 ± 0.000740381 (W 0.00168818) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.466037 ± 0.00307333 (W 0.000473794) | 0.465286 ± 0.00342649 (W 0.00169646) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.472023 ± 0.00140634 (W 0.000923428) | 0.469354 ± 0.0025828 (W 0.00196065) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013294 ± 8.73002e-05 (W 0.000101144) | 0.011261 ± 0.000211369 (W 0.00015791) | 0.019887 ± 0.000137041 (W 7.37041e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057879 ± 8.02143e-05 (W 0.00113735) | 0.053019 ± 0.000147075 (W 0.00054736) | 0.096909 ± 0.000343561 (W 0.000243774) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.15098 ± 0.000925464 (W 0.00165654) | 0.139287 ± 0.000418481 (W 0.00172961) | 0.257976 ± 0.000908343 (W 0.00234327) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.71× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.071202 ± 0.000104806 (W 0.000508475) | 0.068157 ± 0.000257294 (W 0.000259747) | 0.053519 ± 0.0899161 (W 0.00166781) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.319612 ± 0.000536377 (W 0.00180133) | 0.316194 ± 0.00107294 (W 0.00193282) | 0.339221 ± 0.00104604 (W 0.00215408) | · | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr/n96/b1` | 0.782514 ± 0.00277782 (W 0.0023209) | 0.773521 ± 0.00326364 (W 0.00246694) | 0.999258 ± 0.00592891 (W 0.00172257) | · | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039223 ± 4.32474e-05 (W 0.000273479) | 0.045957 ± 0.000241001 (W 0.00130888) | 0.028713 ± 4.0501e-05 (W 9.68824e-05) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.37× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.181432 ± 0.000136122 (W 0.0014406) | 0.240242 ± 0.00122166 (W 0.00152983) | 0.166971 ± 0.000655466 (W 0.00170915) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.433682 ± 0.00385787 (W 0.00185151) | 0.540837 ± 0.00320976 (W 0.00156757) | 0.517453 ± 0.00127843 (W 0.00218779) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014607 ± 9.66282e-05 (W 0.000130251) | 0.012634 ± 4.56107e-05 (W 0.000145431) | 0.020388 ± 4.52806e-05 (W 6.34531e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.060001 ± 0.000127008 (W 0.000106463) | 0.055333 ± 0.00035019 (W 0.00169442) | 0.094766 ± 0.000176672 (W 0.000162814) | 🔴 fork 1.08× slower than `faer-upstream` | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.156014 ± 0.000827925 (W 0.000349539) | 0.143259 ± 0.000217542 (W 0.000436575) | 0.252868 ± 0.00076646 (W 0.00149098) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.235098 ± 0.000309298 (W 0.00176444) | 0.234677 ± 0.000939146 (W 0.00167423) | 0.252846 ± 0.00075268 (W 0.00252856) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23095 ± 0.0041855 (W 0.00332252) | 1.23264 ± 0.00554185 (W 0.00243103) | 1.34737 ± 0.00463252 (W 0.00451641) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.16631 ± 0.00228951 (W 0.00905167) | 3.16921 ± 0.011756 (W 0.00401241) | 3.48376 ± 0.0638471 (W 0.00859366) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.161539 ± 0.000471099 (W 0.00123344) | 0.162152 ± 0.000168075 (W 0.00162524) | 0.102283 ± 0.123173 (W 0.00177505) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.656236 ± 0.00161695 (W 0.00166472) | 0.658145 ± 0.00060955 (W 0.0018567) | 0.493092 ± 0.00124052 (W 0.00224618) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.54049 ± 0.00323996 (W 0.00202355) | 1.54609 ± 0.00265866 (W 0.00347063) | 1.3724 ± 0.0039125 (W 0.00227252) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001082 ± 5.7735e-06 (W 2.02534e-05) | 0.001072 ± 3.21455e-05 (W 2.52626e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 1e-05 (W 2.40832e-05) | 0.002705 ± 3e-05 (W 8.3666e-06) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005019 ± 4.09512e-05 (W 4.20036e-05) | 0.00499 ± 8.75233e-05 (W 2.99199e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00522 ± 5e-05 (W 3.78153e-05) | 0.00525 ± 2.51661e-05 (W 3.42053e-05) | 0.009047 ± 8.18535e-05 (W 3.78985e-05) | · | 🔵 fork 1.73× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030327 ± 0.00017407 (W 8.5897e-05) | 0.030096 ± 0.00040683 (W 5.98013e-05) | 0.051155 ± 0.000774481 (W 0.000281708) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102821 ± 0.000946791 (W 0.00121705) | 0.102671 ± 0.00316886 (W 0.00268083) | 0.137545 ± 0.000946129 (W 0.00100856) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.141824 ± 0.000657117 (W 0.00142229) | 0.141286 ± 0.000368162 (W 0.000367104) | 0.155279 ± 0.000377354 (W 0.00115648) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.63765 ± 0.00197836 (W 0.00266752) | 0.635325 ± 0.00374046 (W 0.00291085) | 0.567708 ± 0.00132945 (W 0.00173778) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.57123 ± 0.0205189 (W 0.0187366) | 1.53631 ± 0.0156594 (W 0.0129012) | 1.15459 ± 0.00165883 (W 0.00192657) | · | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017683 ± 0.000208663 (W 6.81909e-05) | 0.015949 ± 0.000107643 (W 6.19621e-05) | - | 🔴 fork 1.11× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096339 ± 0.000566452 (W 0.000532827) | 0.09163 ± 0.000330032 (W 0.000412802) | - | 🔴 fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.27926 ± 0.00125663 (W 0.00162202) | 0.266373 ± 0.000469597 (W 0.00153014) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028213 ± 0.000140607 (W 0.000948101) | 0.028413 ± 6.08276e-06 (W 0.000106536) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028272 ± 9.18041e-05 (W 5.1733e-05) | 0.028604 ± 8.90524e-05 (W 0.000123952) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.065812 ± 0.000733092 (W 0.000316157) | 0.066263 ± 0.00131982 (W 0.00189017) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.065642 ± 0.000134244 (W 0.000417478) | 0.068748 ± 0.000984126 (W 0.00281957) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.155197 ± 0.000628892 (W 0.00176454) | 0.15673 ± 0.00134612 (W 0.00169347) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.155242 ± 0.000363501 (W 0.00199804) | 0.155312 ± 0.00175045 (W 0.00218904) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013164 ± 0.000278083 (W 0.000174529) | 0.011351 ± 0.000121138 (W 0.000144209) | 0.019917 ± 5.68624e-05 (W 8.73739e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057518 ± 0.000348489 (W 0.000216979) | 0.05295 ± 7.73822e-05 (W 0.000142724) | 0.095557 ± 0.00085134 (W 0.00104436) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.151014 ± 0.000646289 (W 0.00172047) | 0.153776 ± 0.000839708 (W 0.0011453) | 0.243949 ± 0.000677655 (W 0.00162343) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070721 ± 0.000247286 (W 0.000312723) | 0.148596 ± 0.00648221 (W 0.0207659) | 0.054002 ± 0.0900213 (W 0.00159265) | 🔵 fork 2.10× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.299525 ± 0.0157321 (W 0.005078) | 0.667436 ± 0.0106465 (W 0.0144828) | 0.304494 ± 0.00200668 (W 0.00178912) | 🔵 fork 2.23× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr/n96/b1` | 0.697071 ± 0.0448067 (W 0.00603667) | 1.40271 ± 0.036152 (W 0.0163397) | 0.769061 ± 0.00194989 (W 0.0018583) | 🔵 fork 2.01× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.053219 ± 0.000368161 (W 0.000665905) | 0.108414 ± 0.00195677 (W 0.00515946) | 0.028903 ± 0.000196031 (W 6.01664e-05) | 🔵 fork 2.04× faster than `faer-upstream` | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.188549 ± 0.000874638 (W 0.00310195) | 0.628354 ± 0.00982221 (W 0.00874342) | 0.760218 ± 0.345446 (W 0.00125666) | 🔵 fork 3.33× faster than `faer-upstream` | 🔵 fork 4.03× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.381567 ± 0.00181401 (W 0.00261478) | 1.18081 ± 0.0105282 (W 0.0144332) | 2.45269 ± 0.00618563 (W 0.00547711) | 🔵 fork 3.09× faster than `faer-upstream` | 🔵 fork 6.43× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014638 ± 4.99032e-05 (W 0.000146405) | 0.012524 ± 0.000238607 (W 0.000143207) | 0.020238 ± 3.51188e-05 (W 7.87096e-05) | 🔴 fork 1.17× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059911 ± 0.000117053 (W 0.00127103) | 0.055162 ± 0.000120666 (W 0.000212611) | 0.092913 ± 0.000109692 (W 0.000228417) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.154367 ± 0.000239477 (W 0.00165408) | 0.158966 ± 0.00107797 (W 0.00187911) | 0.236279 ± 0.00113011 (W 0.00199242) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.234457 ± 0.000735462 (W 0.00163645) | 0.235914 ± 0.00117002 (W 0.00171895) | 0.260465 ± 0.000325839 (W 0.00154519) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2096 ± 0.00389396 (W 0.00197228) | 1.20652 ± 0.00580509 (W 0.00407243) | 1.03106 ± 0.000437753 (W 0.00254449) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.02414 ± 0.012797 (W 0.0308813) | 3.01333 ± 0.00452139 (W 0.0115531) | 2.52529 ± 0.0017968 (W 0.00368446) | · | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.16142 ± 0.000155593 (W 0.00167516) | 0.162242 ± 0.000212853 (W 0.00162942) | 0.102273 ± 0.122187 (W 0.00140044) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.657885 ± 0.00289563 (W 0.00292761) | 0.656696 ± 0.00322764 (W 0.00221669) | 0.491254 ± 0.00104594 (W 0.0015179) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.54068 ± 0.00582714 (W 0.00168257) | 1.53617 ± 0.00622223 (W 0.00169664) | 1.354 ± 0.00554298 (W 0.0013452) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001072 ± 1.1547e-05 (W 1.30384e-05) | 0.001082 ± 1.1547e-05 (W 2.53417e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002665 ± 3.21455e-05 (W 1.93442e-05) | 0.002665 ± 3.21455e-05 (W 1.92354e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004909 ± 3.05505e-05 (W 3.99287e-05) | 0.00491 ± 2.09841e-05 (W 2.87785e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005279 ± 4.57202e-05 (W 2.95855e-05) | 0.00528 ± 3.60555e-05 (W 5.53922e-05) | 0.008896 ± 0.00016552 (W 4.51243e-05) | · | 🔵 fork 1.69× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030377 ± 0.0002605 (W 0.000169499) | 0.030456 ± 0.000230717 (W 0.00127801) | 0.051245 ± 0.000324594 (W 0.00127393) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111898 ± 0.000386959 (W 0.00123503) | 0.111607 ± 0.000610531 (W 0.00452382) | 0.140875 ± 0.000747039 (W 0.000872967) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141263 ± 7.30365e-05 (W 0.00175344) | 0.141714 ± 0.000128347 (W 0.00184758) | 0.156334 ± 6.40651e-05 (W 0.00160005) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.643854 ± 0.00607663 (W 0.00377576) | 0.647758 ± 0.00568172 (W 0.00788515) | 0.54226 ± 0.00264664 (W 0.00307368) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53859 ± 0.00859904 (W 0.0296906) | 1.59158 ± 0.00702085 (W 0.0148353) | 1.03894 ± 0.00435033 (W 0.00251903) | · | 🔴 fork 1.48× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.017683 ± 3.60555e-05 (W 0.00176365) | 0.01581 ± 0.000225456 (W 0.000137245) | - | 🔴 fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.096872 ± 0.000336909 (W 0.00142747) | 0.092434 ± 0.000357956 (W 0.00252319) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.278708 ± 0.00106839 (W 0.00259322) | 0.267458 ± 0.00206659 (W 0.00191075) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028242 ± 7.18424e-05 (W 7.17586e-05) | 0.028302 ± 0.000143392 (W 6.59037e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028182 ± 3.9879e-05 (W 5.38999e-05) | 0.028402 ± 7.95634e-05 (W 0.000116624) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.043001 ± 0.022967 (W 0.00110843) | 0.070984 ± 0.00195767 (W 0.0025329) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.041998 ± 0.00117229 (W 0.000701704) | 0.070462 ± 0.000477827 (W 0.00146072) | - | 🔵 fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.091032 ± 0.00141832 (W 0.00198891) | 0.160879 ± 0.00114579 (W 0.00159283) | - | 🔵 fork 1.77× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.09123 ± 0.00105382 (W 0.00163775) | 0.161219 ± 0.000257749 (W 0.000718065) | - | 🔵 fork 1.77× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.013285 ± 0.00018577 (W 4.8777e-05) | 0.011281 ± 9.0185e-05 (W 0.00010924) | 0.019888 ± 7.20902e-05 (W 7.9594e-05) | 🔴 fork 1.18× slower than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.057416 ± 0.000214355 (W 0.00022115) | 0.052689 ± 7.62693e-05 (W 0.000240662) | 0.096752 ± 0.000492359 (W 0.00133809) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.150353 ± 0.000474515 (W 0.00171356) | 0.166019 ± 0.00124866 (W 0.00265152) | 0.243842 ± 0.000910957 (W 0.00122919) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.070943 ± 0.000199876 (W 0.000385864) | 0.189927 ± 0.00322839 (W 0.00824471) | 0.05338 ± 0.0897078 (W 0.00152778) | 🔵 fork 2.68× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.315966 ± 0.00133006 (W 0.00701786) | 0.865808 ± 0.0150597 (W 0.0166945) | 0.283418 ± 0.00427503 (W 0.00169177) | 🔵 fork 2.74× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.703675 ± 0.0458619 (W 0.0143992) | 1.78019 ± 0.0733293 (W 0.029881) | 0.70119 ± 0.000625235 (W 0.00192659) | 🔵 fork 2.53× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.058278 ± 0.000378392 (W 0.000929894) | 0.139117 ± 0.0010381 (W 0.00321355) | 0.028754 ± 7.02163e-05 (W 6.19048e-05) | 🔵 fork 2.39× faster than `faer-upstream` | 🔴 fork 2.03× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.182499 ± 0.000872883 (W 0.00202736) | 0.77344 ± 0.0200863 (W 0.0263189) | 0.761652 ± 0.345466 (W 0.00126568) | 🔵 fork 4.24× faster than `faer-upstream` | 🔵 fork 4.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.402419 ± 0.00689473 (W 0.00778746) | 1.53054 ± 0.00232627 (W 0.015724) | 2.45216 ± 0.00128186 (W 0.00170788) | 🔵 fork 3.80× faster than `faer-upstream` | 🔵 fork 6.09× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.014657 ± 0.000140275 (W 6.21072e-05) | 0.012673 ± 0.000205938 (W 9.32003e-05) | 0.020177 ± 2.12211e-05 (W 5.77062e-05) | 🔴 fork 1.16× slower than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.059742 ± 8.13654e-05 (W 8.27484e-05) | 0.055043 ± 9.80833e-05 (W 0.000252351) | 0.093535 ± 0.000264955 (W 0.000558848) | 🔴 fork 1.09× slower than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.154902 ± 0.000279743 (W 0.00199275) | 0.170606 ± 0.000399555 (W 0.00248263) | 0.23617 ± 0.000242588 (W 0.0014582) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.235607 ± 0.0022422 (W 0.00213891) | 0.235697 ± 0.0026231 (W 0.00268236) | 0.261795 ± 0.00046688 (W 0.00176014) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.21609 ± 0.000433184 (W 0.00549917) | 1.23457 ± 0.0166533 (W 0.00545057) | 0.990473 ± 0.000940113 (W 0.00191698) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.9892 ± 0.00504424 (W 0.0212235) | 3.11584 ± 0.00400643 (W 0.015799) | 2.33576 ± 0.00333158 (W 0.00156926) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.161824 ± 0.00036109 (W 0.00170604) | 0.16204 ± 0.000303447 (W 0.00133029) | 0.102132 ± 0.122346 (W 0.00178169) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.653767 ± 0.00197284 (W 0.00181007) | 0.656197 ± 0.00156151 (W 0.00159124) | 0.489902 ± 0.00124962 (W 0.00191951) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.54225 ± 0.00141878 (W 0.00418612) | 1.53932 ± 0.00466763 (W 0.00260816) | 1.35506 ± 0.000483997 (W 0.00278819) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001092 ± 1.52753e-05 (W 1.64317e-05) | 0.001072 ± 1e-05 (W 2.10523e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002695 ± 3.51188e-05 (W 2.3816e-05) | 0.002655 ± 1.73205e-05 (W 1.31985e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004929 ± 2.12211e-05 (W 2.05475e-05) | 0.004919 ± 1.52753e-05 (W 2e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005229 ± 1.70392e-05 (W 3.7526e-05) | 0.005189 ± 3.00056e-05 (W 2.89189e-05) | 0.008005 ± 5.74195e-05 (W 5.92647e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.030056 ± 0.000156462 (W 5.51389e-05) | 0.030056 ± 0.000171885 (W 4.39238e-05) | 0.043852 ± 0.000150699 (W 0.00150655) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.083284 ± 0.000222738 (W 0.00132372) | 0.083615 ± 0.000506966 (W 0.000116805) | 0.125041 ± 0.000611711 (W 0.000157861) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.142635 ± 0.000531271 (W 0.00131009) | 0.141432 ± 5.86884e-05 (W 0.000522123) | 0.148897 ± 0.000353793 (W 0.00146965) | · | · |  |
| `eigh/n64/b1` | 0.648911 ± 0.00164755 (W 0.00229877) | 0.647986 ± 0.00105803 (W 0.00204098) | 0.801612 ± 0.000914506 (W 0.00188783) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.61403 ± 0.00261987 (W 0.00201734) | 1.6125 ± 0.00400763 (W 0.00393314) | 2.00966 ± 0.00646853 (W 0.00470666) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015799 ± 0.000104083 (W 9.31681e-05) | 0.01584 ± 1.21244e-05 (W 8.68648e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09055 ± 0.000471407 (W 0.00166744) | 0.091132 ± 0.000441616 (W 0.0011588) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.265821 ± 0.00194073 (W 0.00170142) | 0.265351 ± 0.000370441 (W 0.00204391) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028082 ± 0.00010504 (W 0.00165565) | 0.028063 ± 4.95681e-05 (W 7.1624e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028132 ± 0.00013027 (W 0.000130454) | 0.028152 ± 8.84892e-05 (W 0.00156381) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157336 ± 0.000204368 (W 0.00153663) | 0.157467 ± 0.00101745 (W 0.000168393) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.157654 ± 0.000368256 (W 0.000201018) | 0.157964 ± 0.000253869 (W 0.00161568) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.461639 ± 0.0019967 (W 0.00198538) | 0.458589 ± 0.00240057 (W 0.00106308) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.461529 ± 0.00304064 (W 0.000894688) | 0.46486 ± 0.00173305 (W 0.00178154) | - | · | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011422 ± 5.2915e-05 (W 9.46694e-05) | 0.011352 ± 0.000201098 (W 0.000142707) | 0.017463 ± 7.55447e-05 (W 4.81165e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051165 ± 7.7e-05 (W 0.000144569) | 0.051137 ± 0.000169335 (W 0.00174585) | 0.085758 ± 0.000164192 (W 0.000308781) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136745 ± 0.000710634 (W 0.00188016) | 0.136788 ± 0.000142865 (W 0.00239831) | 0.226281 ± 0.00111271 (W 0.00151888) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.06974 ± 0.000226018 (W 0.000421565) | 0.068246 ± 0.000227026 (W 0.00136588) | 0.048099 ± 0.000285553 (W 0.000176477) | · | 🔴 fork 1.45× slower than `lapack-mkl` |  |
| `qr/n64/b1` | 0.316867 ± 0.00281574 (W 0.00167779) | 0.313842 ± 0.0013534 (W 0.00149943) | 0.318581 ± 0.00182385 (W 0.00190734) | · | · |  |
| `qr/n96/b1` | 0.767807 ± 0.00049665 (W 0.00181131) | 0.767809 ± 0.00219144 (W 0.00241882) | 0.933677 ± 0.00258183 (W 0.00165124) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.034825 ± 0.000150766 (W 0.00018476) | 0.033772 ± 0.000197689 (W 0.000239636) | 0.026168 ± 0.000140096 (W 5.71839e-05) | · | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.1645 ± 0.000679742 (W 0.00124042) | 0.163763 ± 0.000580858 (W 0.00153916) | 0.755987 ± 0.000997086 (W 0.00131003) | · | 🔵 fork 4.60× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.396798 ± 0.00126336 (W 0.00211075) | 0.396558 ± 0.000895983 (W 0.0019905) | 2.43905 ± 0.00275292 (W 0.00353768) | · | 🔵 fork 6.15× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012704 ± 6.0803e-05 (W 7.3418e-05) | 0.012463 ± 0.000108214 (W 0.000159196) | 0.017332 ± 5.72742e-05 (W 7.813e-05) | · | 🔵 fork 1.36× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053742 ± 0.000125045 (W 0.00198627) | 0.053189 ± 0.000269067 (W 0.000191435) | 0.083234 ± 0.000119176 (W 0.000168819) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.140109 ± 0.000217249 (W 0.00139649) | 0.14046 ± 0.000296774 (W 0.000194705) | 0.218875 ± 0.00078887 (W 0.00128289) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.23335 ± 0.000319714 (W 0.0014986) | 0.232963 ± 0.000842256 (W 0.00271117) | 0.24941 ± 0.000103184 (W 0.0016195) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.26286 ± 0.00172501 (W 0.00305353) | 1.26804 ± 0.0049108 (W 0.00355876) | 1.31408 ± 0.00713871 (W 0.00339928) | · | · |  |
| `svd_thin/n96/b1` | 3.1221 ± 0.0082773 (W 0.00695145) | 3.12754 ± 0.00247655 (W 0.00357036) | 3.42897 ± 0.0104931 (W 0.00721844) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.159421 ± 0.00053176 (W 0.00151322) | 0.160068 ± 0.000847814 (W 0.0015226) | 0.100339 ± 0.000196869 (W 0.000189962) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.632297 ± 0.000722503 (W 0.00217522) | 0.632792 ± 0.0003507 (W 0.00188781) | 0.478752 ± 0.00264209 (W 0.00197998) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51187 ± 0.00739444 (W 0.00250748) | 1.51824 ± 0.00433651 (W 0.00189055) | 1.33929 ± 0.00477309 (W 0.00153356) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001183 ± 1.70392e-05 (W 1.6288e-05) | 0.001192 ± 2.70247e-05 (W 3.57813e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002926 ± 5.7735e-06 (W 1.34648e-05) | 0.002945 ± 1.52753e-05 (W 1.38311e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00539 ± 0.000108583 (W 2.50639e-05) | 0.00531 ± 7e-05 (W 3.34664e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.00525 ± 4.16333e-05 (W 4.61519e-05) | 0.00517 ± 4.04145e-05 (W 1.87083e-05) | 0.008165 ± 0.000147422 (W 4.64564e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029955 ± 9.71665e-05 (W 3.46165e-05) | 0.029815 ± 0.000439934 (W 4.37401e-05) | 0.04314 ± 0.000695267 (W 9.06548e-05) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.102493 ± 0.000987074 (W 0.00117692) | 0.102861 ± 0.00149339 (W 0.00161721) | 0.125532 ± 0.000824006 (W 0.00141706) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.141654 ± 0.00017494 (W 0.00158716) | 0.141694 ± 0.000489969 (W 0.00123976) | 0.153795 ± 0.000474526 (W 0.00118526) | · | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.641727 ± 0.00379947 (W 0.00891464) | 0.638542 ± 0.00256022 (W 0.00329071) | 0.555284 ± 0.00111979 (W 0.00143979) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.53747 ± 0.0219552 (W 0.0181274) | 1.53929 ± 0.00925857 (W 0.0130137) | 1.13992 ± 0.00138454 (W 0.00196698) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.015679 ± 8.44413e-05 (W 0.00013841) | 0.015899 ± 0.000136297 (W 0.000100485) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.09017 ± 0.000431524 (W 0.000394785) | 0.089928 ± 0.00066661 (W 0.00026569) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.264508 ± 0.000616449 (W 0.00245384) | 0.263718 ± 0.000626994 (W 0.00237739) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027823 ± 9.78621e-05 (W 3.43511e-05) | 0.028042 ± 2.91605e-05 (W 7.69103e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027912 ± 2.88675e-05 (W 7.26313e-05) | 0.028182 ± 0.000159813 (W 9.40744e-05) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.068778 ± 0.00151998 (W 0.00154916) | 0.067074 ± 0.00032713 (W 0.00160052) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.076292 ± 0.00392864 (W 0.00293493) | 0.067224 ± 0.00160152 (W 0.00135958) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.163793 ± 0.00288467 (W 0.00290452) | 0.153999 ± 0.00257193 (W 0.00118358) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.163788 ± 0.00289867 (W 0.00343368) | 0.153539 ± 0.00143752 (W 0.00160569) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011462 ± 9.17624e-05 (W 0.000100758) | 0.011501 ± 0.000104245 (W 0.000125057) | 0.017433 ± 0.000123977 (W 6.89202e-05) | · | 🔵 fork 1.52× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051296 ± 0.000263129 (W 0.00025922) | 0.051026 ± 0.000286812 (W 0.000235568) | 0.085682 ± 0.00042543 (W 0.000136302) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136146 ± 0.00056414 (W 0.0013577) | 0.144468 ± 0.00133483 (W 0.00542541) | 0.225555 ± 0.00157141 (W 0.00152733) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.66× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.069191 ± 0.000180701 (W 0.000254893) | 0.151751 ± 0.0167685 (W 0.015974) | 0.04801 ± 0.000563167 (W 9.0111e-05) | 🔵 fork 2.19× faster than `faer-upstream` | 🔴 fork 1.44× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n64/b1` | 0.298111 ± 0.00379755 (W 0.00650153) | 0.658646 ± 0.00848986 (W 0.0144468) | 0.287942 ± 0.000555511 (W 0.00171258) | 🔵 fork 2.21× faster than `faer-upstream` | · |  |
| `qr/n96/b1` | 0.684588 ± 0.0479521 (W 0.00754134) | 1.38285 ± 0.0300737 (W 0.014978) | 0.732212 ± 0.000717862 (W 0.0024243) | 🔵 fork 2.02× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.034684 ± 0.000117649 (W 0.00147843) | 0.102652 ± 0.00290541 (W 0.0033624) | 0.026169 ± 0.000200326 (W 3.31662e-05) | 🔵 fork 2.96× faster than `faer-upstream` | 🔴 fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.160241 ± 0.00116652 (W 0.00235174) | 0.518045 ± 0.00625099 (W 0.00827747) | 0.756203 ± 0.00193555 (W 0.00129854) | 🔵 fork 3.23× faster than `faer-upstream` | 🔵 fork 4.72× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.346522 ± 0.0286917 (W 0.00368983) | 1.02112 ± 0.0144407 (W 0.0135925) | 2.44341 ± 0.00192628 (W 0.00330767) | 🔵 fork 2.95× faster than `faer-upstream` | 🔵 fork 7.05× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n32/b1` | 0.012533 ± 0.000133742 (W 0.000153721) | 0.012584 ± 4.58258e-05 (W 0.000139872) | 0.017172 ± 2.51661e-05 (W 0.000102011) | · | 🔵 fork 1.37× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.05357 ± 0.00011628 (W 0.000103102) | 0.053409 ± 0.000339866 (W 0.000267077) | 0.082926 ± 5.99361e-05 (W 0.00132775) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.139921 ± 0.000252282 (W 0.00164478) | 0.156442 ± 0.0012912 (W 0.00358877) | 0.219336 ± 0.00059921 (W 0.00150267) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232272 ± 0.000275398 (W 0.00157821) | 0.232182 ± 0.00104599 (W 0.00201859) | 0.257244 ± 0.000858201 (W 0.00162216) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.24103 ± 0.00539732 (W 0.00857171) | 1.2402 ± 0.0110735 (W 0.00459176) | 1.00745 ± 0.000155671 (W 0.00316777) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.98564 ± 0.0365086 (W 0.0190173) | 2.97149 ± 0.0284324 (W 0.0209921) | 2.50505 ± 0.00513162 (W 0.00270922) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.159487 ± 0.00016752 (W 0.00142264) | 0.159956 ± 0.000603382 (W 0.00104732) | 0.100347 ± 0.000418003 (W 0.000125579) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.631325 ± 0.000776005 (W 0.0018862) | 0.63212 ± 0.00246166 (W 0.00204129) | 0.482543 ± 0.000920907 (W 0.00175725) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.51759 ± 0.00627292 (W 0.00192835) | 1.51214 ± 0.00484183 (W 0.00198824) | 1.33542 ± 0.00568336 (W 0.00200067) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001183 ± 5.50757e-06 (W 1.92354e-05) | 0.001223 ± 3.06649e-05 (W 1.66493e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002935 ± 5.50757e-06 (W 1.51427e-05) | 0.003006 ± 7.57188e-05 (W 2.45825e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00518 ± 5.7735e-07 (W 2.3776e-05) | 0.005199 ± 1.53948e-05 (W 1.87083e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n32/b1` | 0.005239 ± 5.02693e-05 (W 3.20936e-05) | 0.00524 ± 6.02771e-05 (W 1.91128e-05) | 0.008014 ± 8.34286e-05 (W 2.98044e-05) | · | 🔵 fork 1.53× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029845 ± 0.000458786 (W 5.81309e-05) | 0.029876 ± 0.000226628 (W 8.31276e-05) | 0.04311 ± 8.11193e-05 (W 0.00010835) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `cholesky/n96/b1` | 0.111477 ± 0.00128438 (W 0.00186525) | 0.111186 ± 0.000485558 (W 0.00382318) | 0.125105 ± 0.000895469 (W 0.00157179) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `eigh/n32/b1` | 0.140923 ± 0.000965969 (W 0.00156469) | 0.141286 ± 0.00026101 (W 0.000214719) | 0.154791 ± 0.00020427 (W 0.00112681) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.642631 ± 0.00275405 (W 0.00425071) | 0.64362 ± 0.00270492 (W 0.00575162) | 0.529535 ± 0.000497724 (W 0.00226942) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n96/b1` | 1.54133 ± 0.00244089 (W 0.0119133) | 1.59295 ± 0.0102517 (W 0.0190391) | 1.01968 ± 0.00204454 (W 0.00197955) | · | 🔴 fork 1.51× slower than `lapack-mkl` |  |
| `full_piv_lu/n32/b1` | 0.01577 ± 7.68136e-05 (W 9.72744e-05) | 0.01594 ± 0.000148325 (W 0.000123147) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.090078 ± 0.000321466 (W 0.00154096) | 0.090218 ± 0.000304714 (W 0.00139972) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.265153 ± 0.000963818 (W 0.0019508) | 0.26475 ± 0.000658523 (W 0.00215013) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028073 ± 0.000144362 (W 0.000128873) | 0.028192 ± 1.51767e-05 (W 0.000116778) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.027982 ± 0.000151889 (W 4.79583e-05) | 0.028132 ± 7.53459e-05 (W 0.00100225) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.050946 ± 0.0009315 (W 0.00278109) | 0.072254 ± 0.000311769 (W 0.00280865) | - | 🔵 fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.051497 ± 0.00407324 (W 0.00307433) | 0.071082 ± 0.002069 (W 0.00227283) | - | 🔵 fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.10268 ± 0.0029763 (W 0.00290061) | 0.161915 ± 0.00186931 (W 0.00151667) | - | 🔵 fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.102851 ± 0.00151895 (W 0.00413116) | 0.160789 ± 0.000926468 (W 0.00154225) | - | 🔵 fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011551 ± 0.000341088 (W 0.000117504) | 0.011402 ± 9.07028e-05 (W 0.000110105) | 0.017442 ± 3.60555e-05 (W 6.89949e-05) | · | 🔵 fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.051295 ± 0.000379685 (W 0.000216144) | 0.051425 ± 0.000300312 (W 0.0016908) | 0.085709 ± 0.000350058 (W 0.00137073) | · | 🔵 fork 1.67× faster than `lapack-mkl` |  |
| `lu/n96/b1` | 0.136316 ± 0.000555756 (W 0.000209754) | 0.163372 ± 0.000429099 (W 0.0034771) | 0.224602 ± 0.000397512 (W 0.00188202) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/n32/b1` | 0.06927 ± 0.000257663 (W 0.00138143) | 0.186115 ± 0.00922311 (W 0.00450239) | 0.0484 ± 0.000229566 (W 0.000127123) | 🔵 fork 2.69× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n64/b1` | 0.311307 ± 0.000983885 (W 0.00662703) | 0.861814 ± 0.0164355 (W 0.0240755) | 0.263405 ± 0.00256101 (W 0.00213704) | 🔵 fork 2.77× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |
| `qr/n96/b1` | 0.710247 ± 0.0549837 (W 0.014223) | 1.82056 ± 0.0866565 (W 0.0437335) | 0.670073 ± 0.000634591 (W 0.0030176) | 🔵 fork 2.56× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.034724 ± 6.82422e-05 (W 0.000197268) | 0.131445 ± 0.00274244 (W 0.0114206) | 0.026059 ± 0.000153189 (W 5.31977e-05) | 🔵 fork 3.79× faster than `faer-upstream` | 🔴 fork 1.33× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.169979 ± 0.00508969 (W 0.00310209) | 0.691126 ± 0.00966985 (W 0.00818694) | 0.755801 ± 0.000519316 (W 0.00201488) | 🔵 fork 4.07× faster than `faer-upstream` | 🔵 fork 4.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n96/b1` | 0.358697 ± 0.00513555 (W 0.00638753) | 1.36111 ± 0.0154623 (W 0.0329263) | 2.44029 ± 0.0015211 (W 0.00232298) | 🔵 fork 3.79× faster than `faer-upstream` | 🔵 fork 6.80× faster than `lapack-mkl` |  |
| `solve/n32/b1` | 0.012744 ± 8.02081e-05 (W 0.000182039) | 0.012423 ± 3.9879e-05 (W 0.00011973) | 0.017302 ± 4.63717e-05 (W 7.6186e-05) | · | 🔵 fork 1.36× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.053289 ± 0.000107151 (W 0.000288231) | 0.053278 ± 0.000211851 (W 0.000233588) | 0.082924 ± 7.2581e-05 (W 8.80699e-05) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `solve/n96/b1` | 0.140013 ± 0.000185292 (W 0.00166379) | 0.167455 ± 0.000215282 (W 0.00156665) | 0.218547 ± 0.000845678 (W 0.00174538) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.232884 ± 0.00260848 (W 0.00239293) | 0.233553 ± 0.00200813 (W 0.00168371) | 0.25787 ± 0.000435068 (W 0.00119891) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2443 ± 0.000821079 (W 0.00335707) | 1.24903 ± 0.00437105 (W 0.00622813) | 0.969723 ± 0.014016 (W 0.00135159) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96664 ± 0.0120305 (W 0.0339827) | 3.07491 ± 0.00445108 (W 0.0206456) | 2.32143 ± 0.00113623 (W 0.00249839) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.159145 ± 0.000588977 (W 0.00146353) | 0.160046 ± 0.000189534 (W 0.00160625) | 0.100276 ± 2.62869e-05 (W 0.0012078) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.63153 ± 0.00174534 (W 0.00183902) | 0.631896 ± 0.00160929 (W 0.00282787) | 0.479461 ± 0.00311153 (W 0.00281446) | · | 🔴 fork 1.32× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 1.5133 ± 0.0014143 (W 0.00418473) | 1.51243 ± 0.00941902 (W 0.00407705) | 1.33921 ± 0.000916002 (W 0.00321766) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `triangular_solve/n32/b1` | 0.001222 ± 3.51188e-05 (W 2.39625e-05) | 0.001222 ± 6.08276e-06 (W 2.21427e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.003025 ± 7.40968e-05 (W 2.36707e-05) | 0.002956 ± 4.7085e-05 (W 2.63496e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0053 ± 6.4291e-05 (W 2.94958e-05) | 0.005471 ± 0.00016383 (W 1.78382e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.066984 ± 0.000124917 (W 0.00042502) | 0.070383 ± 0.000210621 (W 0.00165308) | 0.114923 ± 0.00142377 (W 0.000687146) | · | 🔵 fork 1.72× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.389372 ± 0.00146699 (W 0.00252606) | 0.397127 ± 0.00974314 (W 0.00276864) | 0.638434 ± 0.000853282 (W 0.00342218) | · | 🔵 fork 1.64× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.52592 ± 0.00959873 (W 0.00192403) | 2.5219 ± 0.0055667 (W 0.00418207) | 4.03733 ± 0.0189071 (W 0.0452308) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.25465 ± 0.00932558 (W 0.00443057) | 2.2611 ± 0.0145179 (W 0.00194967) | 1.86481 ± 0.00648604 (W 0.00974121) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.8053 ± 0.0206209 (W 0.020329) | 9.82621 ± 0.0335904 (W 0.0229393) | 10.0317 ± 0.0225104 (W 0.020286) | · | · |  |
| `eigh/n512/b1` | 49.217 ± 0.0344281 (W 0.0560684) | 49.2847 ± 0.154226 (W 0.108261) | 61.4798 ± 0.21641 (W 0.0536348) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.310072 ± 0.00128365 (W 0.00180032) | 0.312431 ± 0.00064781 (W 0.00377547) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7179 ± 0.00464073 (W 0.00786501) | 2.77887 ± 0.0150246 (W 0.00908693) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 22.1438 ± 0.231209 (W 0.0665663) | 22.7803 ± 0.367748 (W 0.0734819) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259311 ± 0.00180781 (W 0.00155351) | 0.259107 ± 0.00167045 (W 0.00205557) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.259127 ± 0.00138602 (W 0.00217793) | 0.258541 ± 0.00105945 (W 0.000282268) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90544 ± 0.0244728 (W 0.00226344) | 1.91434 ± 0.0195028 (W 0.00766654) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.91684 ± 0.0269413 (W 0.00471492) | 1.92684 ± 0.0205528 (W 0.00227795) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8803 ± 0.0166845 (W 0.0335696) | 15.8402 ± 0.0188596 (W 0.0458694) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9567 ± 0.0375847 (W 0.0504858) | 15.8612 ± 0.0378184 (W 0.044238) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.133491 ± 0.00110236 (W 0.000348216) | 0.136486 ± 0.0184615 (W 0.00171202) | 0.172121 ± 0.0186831 (W 0.00191636) | · | 🔵 fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.979952 ± 0.117154 (W 0.0021686) | 1.03487 ± 0.00511014 (W 0.00570508) | 0.966172 ± 0.134248 (W 0.00138166) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.60811 ± 0.0112026 (W 0.0137495) | 7.14779 ± 0.0600149 (W 0.0184453) | 6.96657 ± 0.0284843 (W 0.0154925) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 0.514023 ± 0.00220038 (W 0.00207914) | 0.511742 ± 0.00340137 (W 0.00276439) | 0.751272 ± 0.00586894 (W 0.00541433) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.88629 ± 0.0112064 (W 0.00341759) | 2.92712 ± 0.00668432 (W 0.0039716) | 4.32462 ± 0.0256218 (W 0.0220341) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.4716 ± 0.160186 (W 0.0692797) | 21.0883 ± 0.135639 (W 0.0720933) | 30.6403 ± 0.203634 (W 0.0556971) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.33297 ± 0.000884432 (W 0.00181778) | 0.530376 ± 0.00362277 (W 0.00152082) | 0.37068 ± 0.00180648 (W 0.00246387) | 🔵 fork 1.59× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.60335 ± 0.0036501 (W 0.00287184) | 2.84679 ± 0.0338878 (W 0.00526894) | 2.04326 ± 0.00675798 (W 0.00650759) | 🔵 fork 1.78× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.95192 ± 0.0696638 (W 0.0233175) | 17.621 ± 0.04788 (W 0.0448035) | 14.3491 ± 0.118119 (W 0.0341887) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133298 ± 0.000276955 (W 0.000256476) | 0.136854 ± 0.00148268 (W 0.00118606) | 0.169976 ± 0.00113318 (W 0.000371699) | · | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.751884 ± 0.00369904 (W 0.00257413) | 0.810944 ± 0.0033217 (W 0.00366869) | 0.974191 ± 0.00483496 (W 0.00174909) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.56368 ± 0.0320321 (W 0.0254527) | 7.09549 ± 0.0323117 (W 0.0289715) | 5.97628 ± 0.00570566 (W 0.0141771) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.68705 ± 0.00449823 (W 0.00276685) | 3.68172 ± 0.0101368 (W 0.00697526) | 3.4 ± 0.00413564 (W 0.0101823) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4965 ± 0.0328078 (W 0.0328758) | 18.483 ± 0.00574709 (W 0.0316509) | 18.1323 ± 0.0140629 (W 0.39921) | · | · |  |
| `svd_thin/n512/b1` | 106.126 ± 0.0645787 (W 0.062143) | 106.358 ± 0.426988 (W 0.42195) | 116.933 ± 0.854702 (W 0.161685) | · | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69479 ± 0.00703836 (W 0.00447391) | 2.69353 ± 0.00793536 (W 0.00467904) | 1.2021 ± 0.00458084 (W 0.00442724) | · | 🔴 fork 2.24× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4744 ± 0.0219195 (W 0.0183307) | 12.4209 ± 0.0299694 (W 0.0217394) | 6.98264 ± 0.0189947 (W 0.0120768) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.2808 ± 0.226651 (W 0.108658) | 66.6 ± 0.2114 (W 0.0409017) | 47.9312 ± 0.363648 (W 0.0919644) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004018 ± 6.05558e-05 (W 6.31609e-05) | 0.004047 ± 0.000179519 (W 4.78257e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011542 ± 0.000323744 (W 4.97996e-05) | 0.011482 ± 0.000275441 (W 8.3614e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.039264 ± 0.00356181 (W 0.00188372) | 0.039024 ± 0.003084 (W 0.000274207) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.085721 ± 0.000845738 (W 0.00214086) | 0.10753 ± 0.00110506 (W 0.00791782) | 0.114445 ± 0.000226003 (W 0.00170964) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.397225 ± 0.00798222 (W 0.0170101) | 0.432131 ± 0.00611633 (W 0.021148) | 0.4104 ± 0.00192617 (W 0.00550311) | 🔵 fork 1.09× faster than `faer-upstream` | · |  |
| `cholesky/n512/b1` | 1.59738 ± 0.0649866 (W 0.0186667) | 1.69682 ± 0.0449419 (W 0.0600728) | 1.91536 ± 0.00265595 (W 0.0113013) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.32052 ± 0.0403508 (W 0.0393697) | 2.29706 ± 0.0107867 (W 0.0106785) | 1.07309 ± 0.00129443 (W 0.00310186) | · | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.00121 ± 0.018388 (W 0.0398895) | 7.00159 ± 0.0295657 (W 0.0227134) | 4.78283 ± 0.0133285 (W 0.00959196) | · | 🔴 fork 1.46× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.3951 ± 0.149331 (W 0.179064) | 26.2564 ± 0.162401 (W 0.0391044) | 21.7239 ± 0.0265104 (W 0.0296899) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.308163 ± 0.00175407 (W 0.00163574) | 0.3144 ± 0.00210736 (W 0.00222463) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.70283 ± 0.00535974 (W 0.012354) | 2.76755 ± 0.0027483 (W 0.0103479) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.5386 ± 0.068404 (W 0.0669061) | 17.9782 ± 0.147793 (W 0.165011) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.084628 ± 0.000399405 (W 0.00156372) | 0.083766 ± 0.000485009 (W 0.000741545) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.08634 ± 0.00143167 (W 0.000587518) | 0.084276 ± 0.00128479 (W 0.00121823) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.524735 ± 0.00407902 (W 0.00589241) | 0.524362 ± 0.00559412 (W 0.00452475) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.523693 ± 0.0021824 (W 0.00417069) | 0.519944 ± 0.0109409 (W 0.00367067) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.15536 ± 0.00970618 (W 0.0145915) | 4.08204 ± 0.00108843 (W 0.0113129) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.18967 ± 0.0244478 (W 0.016886) | 4.09612 ± 0.0193833 (W 0.0184649) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.13441 ± 0.0183033 (W 0.00171219) | 0.214669 ± 0.0163634 (W 0.00706714) | 0.152723 ± 0.0139652 (W 0.00147198) | 🔵 fork 1.60× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.984856 ± 0.117106 (W 0.0025695) | 1.18423 ± 0.00919741 (W 0.0240923) | 0.377421 ± 0.11378 (W 0.00248576) | 🔵 fork 1.20× faster than `faer-upstream` | 🔴 fork 2.61× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.85169 ± 0.0420003 (W 0.0493107) | 5.69829 ± 2.29117 (W 0.157386) | 2.62289 ± 0.0136936 (W 0.0111478) | · | 🔴 fork 1.85× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n128/b1` | 0.596328 ± 0.0116963 (W 0.0328968) | 1.48026 ± 0.0224352 (W 0.0257102) | 0.480583 ± 0.000353329 (W 0.00248341) | 🔵 fork 2.48× faster than `faer-upstream` | 🔴 fork 1.24× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.98511 ± 0.0340217 (W 0.0264464) | 3.8746 ± 0.0290409 (W 0.0541031) | 2.00947 ± 0.0106883 (W 0.00637203) | 🔵 fork 1.95× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 10.2094 ± 1.04233 (W 0.101371) | 14.6592 ± 1.02609 (W 0.0929662) | 12.0241 ± 0.154852 (W 0.0186214) | 🔵 fork 1.44× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.39976 ± 0.00980253 (W 0.0282952) | 1.51875 ± 0.0200213 (W 0.0160185) | 0.196349 ± 0.00122129 (W 0.00266118) | 🔵 fork 3.80× faster than `faer-upstream` | 🔴 fork 2.04× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.44291 ± 0.0174844 (W 0.0306738) | 5.67711 ± 0.00664768 (W 0.0389428) | 0.668434 ± 0.000930046 (W 0.00282008) | 🔵 fork 3.93× faster than `faer-upstream` | 🔴 fork 2.16× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.21544 ± 0.0204592 (W 0.0421547) | 22.2691 ± 0.109945 (W 0.120042) | 3.86649 ± 0.00929673 (W 0.00814359) | 🔵 fork 4.27× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133628 ± 0.000621303 (W 0.00132286) | 0.2101 ± 0.00390269 (W 0.00788205) | 0.149778 ± 0.00046895 (W 0.0016015) | 🔵 fork 1.57× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.760868 ± 0.00657325 (W 0.00770836) | 0.908264 ± 0.00496436 (W 0.0264744) | 0.367151 ± 0.000495265 (W 0.00272377) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.72379 ± 0.011338 (W 0.076716) | 5.41777 ± 0.0593804 (W 0.0418715) | 1.79648 ± 0.0282842 (W 0.00370051) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 2.63× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.0477 ± 0.0138203 (W 0.0194377) | 3.04311 ± 0.0114316 (W 0.0115745) | 2.6357 ± 0.0143661 (W 0.00418919) | · | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.7176 ± 0.0595386 (W 0.114475) | 13.7149 ± 0.0488625 (W 0.0772199) | 12.5042 ± 0.00568741 (W 0.0298253) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.8956 ± 0.172039 (W 0.359773) | 61.8089 ± 0.139269 (W 0.435255) | 57.6307 ± 0.363768 (W 0.286707) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.22258 ± 0.0106512 (W 0.00334467) | 2.22339 ± 0.0113532 (W 0.00868) | 1.13484 ± 0.00832432 (W 0.00281935) | · | 🔴 fork 1.96× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8453 ± 0.0272979 (W 0.0831424) | 10.7996 ± 0.0268474 (W 0.030748) | 6.14172 ± 0.00458556 (W 0.00929593) | · | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.8038 ± 0.44749 (W 0.476395) | 48.1953 ± 0.216913 (W 0.267691) | 25.8545 ± 0.0515408 (W 0.03847) | · | 🔴 fork 1.89× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.003737 ± 0.000131149 (W 4.37413e-05) | 0.003687 ± 0.000155027 (W 5.20413e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011181 ± 0.000255891 (W 7.46994e-05) | 0.011161 ± 0.000258908 (W 5.40768e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.037429 ± 0.0050983 (W 0.00191566) | 0.03758 ± 0.00553254 (W 0.00041386) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.090898 ± 0.000880884 (W 0.00276445) | 0.10691 ± 0.0011677 (W 0.00212046) | 0.115484 ± 0.00111558 (W 0.0018987) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.399279 ± 0.00697169 (W 0.0274247) | 0.474873 ± 0.0119732 (W 0.00975651) | 0.362029 ± 0.00346564 (W 0.00371824) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.51804 ± 0.0231858 (W 0.0364574) | 1.61414 ± 0.0386299 (W 0.0317164) | 1.46482 ± 0.00717396 (W 0.0127175) | 🔵 fork 1.06× faster than `faer-upstream` | · |  |
| `eigh/n128/b1` | 2.39295 ± 0.00511685 (W 0.0207264) | 2.35015 ± 0.0267299 (W 0.0248381) | 1.00517 ± 0.00307567 (W 0.00325759) | · | 🔴 fork 2.38× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.90007 ± 0.0454906 (W 0.0381583) | 7.0836 ± 0.0609906 (W 0.0436923) | 4.0081 ± 0.178584 (W 0.00659311) | · | 🔴 fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n512/b1` | 24.2211 ± 0.0404987 (W 0.0341089) | 25.0154 ± 0.043482 (W 0.0869758) | 15.2743 ± 0.0139877 (W 0.0332677) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309345 ± 0.00182488 (W 0.00170343) | 0.31258 ± 0.00351303 (W 0.00201248) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.7136 ± 0.0112341 (W 0.0120395) | 2.76506 ± 0.00690551 (W 0.00721863) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.3171 ± 0.13505 (W 0.0556002) | 17.8146 ± 0.173996 (W 0.153192) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.059892 ± 0.000307078 (W 0.00163868) | 0.10139 ± 0.000625659 (W 0.001091) | - | 🔵 fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.059631 ± 0.000756019 (W 0.000960518) | 0.101841 ± 0.000631001 (W 0.00248365) | - | 🔵 fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.284739 ± 0.00225223 (W 0.00234892) | 0.406184 ± 0.00663469 (W 0.0201422) | - | 🔵 fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.289448 ± 0.00459513 (W 0.00258477) | 0.415443 ± 0.0120926 (W 0.0136552) | - | 🔵 fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.24702 ± 0.00611478 (W 0.0238167) | 2.59635 ± 0.128703 (W 0.0709257) | - | 🔵 fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.2809 ± 1.13568 (W 0.0171622) | 2.59612 ± 0.0996338 (W 0.326343) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.13427 ± 0.0172892 (W 0.00192842) | 0.221004 ± 0.022104 (W 0.00541192) | 0.149949 ± 0.025007 (W 0.00137681) | 🔵 fork 1.65× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.995958 ± 0.134613 (W 0.0166941) | 1.257 ± 0.00287183 (W 0.0229293) | 0.347948 ± 0.164433 (W 0.00301589) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 2.86× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.60347 ± 0.00755943 (W 0.0495527) | 5.76885 ± 0.0688589 (W 0.0629718) | 2.39213 ± 0.044058 (W 0.0145042) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 1.92× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.613408 ± 0.0612419 (W 0.0246188) | 1.97148 ± 0.01537 (W 0.0202258) | 0.433915 ± 0.00593508 (W 0.00295268) | 🔵 fork 3.21× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n256/b1` | 1.81633 ± 0.0140305 (W 0.0265248) | 4.81391 ± 0.0914819 (W 0.0364024) | 1.79706 ± 0.00242719 (W 0.00650354) | 🔵 fork 2.65× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 8.84781 ± 0.0128479 (W 0.0432756) | 16.033 ± 0.148149 (W 0.177186) | 9.02776 ± 0.0186079 (W 0.0189132) | 🔵 fork 1.81× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.357483 ± 0.0058904 (W 0.00745431) | 2.00209 ± 0.010979 (W 0.0242625) | 0.156974 ± 0.00104976 (W 0.0024024) | 🔵 fork 5.60× faster than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.4019 ± 0.0103372 (W 0.010918) | 6.69058 ± 0.024289 (W 0.0693405) | 0.578173 ± 0.00153113 (W 0.00276465) | 🔵 fork 4.77× faster than `faer-upstream` | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.85153 ± 0.0177901 (W 0.0376852) | 25.2257 ± 0.214261 (W 0.207099) | 2.32602 ± 0.0106669 (W 0.00735824) | 🔵 fork 5.20× faster than `faer-upstream` | 🔴 fork 2.09× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.133317 ± 0.000696058 (W 0.000192394) | 0.215911 ± 0.00432173 (W 0.0109789) | 0.146311 ± 0.000306354 (W 0.00162957) | 🔵 fork 1.62× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.765281 ± 0.00314423 (W 0.00355273) | 0.944111 ± 0.00320639 (W 0.016371) | 0.335422 ± 0.00242674 (W 0.00175568) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 2.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.60844 ± 0.107206 (W 0.040955) | 5.65399 ± 0.0508008 (W 0.0516531) | 1.29398 ± 0.0173237 (W 0.00576129) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 3.56× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.06464 ± 0.0188631 (W 0.0195839) | 3.12174 ± 0.0159766 (W 0.0224127) | 2.53424 ± 0.0483321 (W 0.0115681) | · | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4879 ± 0.0521238 (W 0.0387272) | 13.7727 ± 0.0412198 (W 0.0325892) | 11.4916 ± 0.0129684 (W 0.0204645) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.9035 ± 0.358569 (W 0.538761) | 61.394 ± 0.124146 (W 0.56277) | 50.5628 ± 1.60018 (W 0.131481) | · | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.29128 ± 0.0440594 (W 0.00360567) | 2.27878 ± 0.0451274 (W 0.00346309) | 1.12926 ± 0.00695356 (W 0.00297124) | · | 🔴 fork 2.03× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 11.0001 ± 0.0687167 (W 0.0706302) | 10.9654 ± 0.0320205 (W 0.0166118) | 6.00751 ± 0.00695358 (W 0.0108828) | · | 🔴 fork 1.83× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.3807 ± 0.375008 (W 0.551409) | 49.5115 ± 0.168277 (W 0.368822) | 22.4155 ± 0.0643934 (W 0.031843) | · | 🔴 fork 2.20× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.003646 ± 0.000176976 (W 4.94389e-05) | 0.003747 ± 0.000131149 (W 5.88243e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.009778 ± 0.000844723 (W 5.44977e-05) | 0.009768 ± 0.00072342 (W 7.1624e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.038231 ± 0.00144508 (W 0.00137917) | 0.037259 ± 0.00030568 (W 0.000601186) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.060463 ± 0.000167721 (W 0.00132784) | 0.063459 ± 0.000283403 (W 0.00012518) | 0.094278 ± 0.000909141 (W 0.000209387) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.316557 ± 0.0058959 (W 0.00201444) | 0.322539 ± 0.00442488 (W 0.00187074) | 0.461556 ± 0.00852483 (W 0.00267068) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06334 ± 0.00472463 (W 0.00768071) | 2.06089 ± 0.00117504 (W 0.00254248) | 3.40512 ± 0.0297317 (W 0.0119101) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.25422 ± 0.00600787 (W 0.00578916) | 2.26266 ± 8.05543e-05 (W 0.00425349) | 1.83284 ± 0.00702029 (W 0.0110507) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.73811 ± 0.0194558 (W 0.0200852) | 9.76431 ± 0.0227392 (W 0.0238651) | 9.8964 ± 0.014969 (W 0.0276544) | · | · |  |
| `eigh/n512/b1` | 48.8173 ± 0.0788868 (W 0.0796984) | 48.6926 ± 0.0802587 (W 0.0287796) | 60.2906 ± 0.344889 (W 0.124563) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290529 ± 0.00260735 (W 0.00174966) | 0.291029 ± 0.00326852 (W 0.0021476) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.64117 ± 0.0134589 (W 0.00754867) | 2.62874 ± 0.00913219 (W 0.00708169) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.6309 ± 0.263553 (W 0.0278967) | 21.6709 ± 0.377116 (W 0.0527562) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254067 ± 0.000514929 (W 0.00178106) | 0.253997 ± 0.00048427 (W 0.00198513) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.254353 ± 0.000474902 (W 0.00165177) | 0.255386 ± 0.000604525 (W 0.00264286) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.86813 ± 0.0190542 (W 0.0071457) | 1.86063 ± 0.0213706 (W 0.00345332) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.87859 ± 0.00566417 (W 0.00383234) | 1.87705 ± 0.00121565 (W 0.00562521) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.7306 ± 0.0359893 (W 0.0332512) | 15.7227 ± 0.0189482 (W 0.0354289) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7841 ± 0.0356404 (W 0.0396733) | 15.7439 ± 0.0326769 (W 0.0581356) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145163 ± 0.000926623 (W 0.00251115) | 0.144839 ± 0.000732858 (W 0.00233889) | 0.133218 ± 9.08424e-05 (W 0.00129291) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.699185 ± 0.112001 (W 0.0034392) | 0.702611 ± 0.112591 (W 0.002774) | 0.82017 ± 0.00266114 (W 0.00249999) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.11114 ± 0.0208417 (W 0.0272368) | 6.12072 ± 0.00968697 (W 0.017246) | 5.20994 ± 0.0062824 (W 0.0132405) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.486896 ± 0.00130359 (W 0.003648) | 0.489952 ± 0.00114813 (W 0.00269372) | 0.683648 ± 0.00163285 (W 0.0050701) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.78754 ± 0.0077814 (W 0.00486515) | 2.78885 ± 0.00332499 (W 0.0045693) | 4.32829 ± 0.0244448 (W 0.015142) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.8943 ± 0.202844 (W 0.0518963) | 19.8385 ± 0.137676 (W 0.0426059) | 30.3095 ± 0.162219 (W 0.0448264) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.274349 ± 0.00147539 (W 0.00141634) | 0.277637 ± 0.00168024 (W 0.00168361) | 0.33474 ± 0.000403734 (W 0.00246756) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.36465 ± 0.00236222 (W 0.00225687) | 1.36705 ± 0.00586789 (W 0.0034326) | 1.89863 ± 0.00271694 (W 0.00900729) | · | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.95578 ± 0.0273992 (W 0.0122535) | 7.97001 ± 0.0626218 (W 0.0205015) | 13.4019 ± 0.127748 (W 0.028175) | · | 🔵 fork 1.68× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.111707 ± 0.000460284 (W 0.0016601) | 0.11305 ± 0.000723395 (W 0.00293145) | 0.132316 ± 0.000170688 (W 0.00150302) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.661938 ± 0.00485316 (W 0.00185097) | 0.665735 ± 0.00441507 (W 0.00310066) | 0.817036 ± 0.00312263 (W 0.00220402) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.07587 ± 0.0533204 (W 0.0243204) | 6.04627 ± 0.0406589 (W 0.0128095) | 5.26415 ± 0.0345838 (W 0.0151116) | · | 🔴 fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.6898 ± 0.00688152 (W 0.00722001) | 3.68606 ± 0.00556092 (W 0.00322639) | 3.31553 ± 0.0129921 (W 0.00960571) | · | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3738 ± 0.0658424 (W 0.0364803) | 18.3586 ± 0.0437881 (W 0.0409375) | 17.8479 ± 0.0929025 (W 0.0542173) | · | · |  |
| `svd_thin/n512/b1` | 105.478 ± 0.188322 (W 0.0695262) | 105.443 ± 0.186306 (W 0.100656) | 116.64 ± 0.463028 (W 0.482112) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.6216 ± 0.00741957 (W 0.00591102) | 2.61632 ± 0.0124373 (W 0.00330962) | 1.15717 ± 0.00556169 (W 0.00317876) | · | 🔴 fork 2.27× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.3036 ± 0.0205552 (W 0.0179201) | 12.2767 ± 0.01538 (W 0.0187961) | 6.86385 ± 0.0159006 (W 0.0175924) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.5743 ± 0.238384 (W 0.0425717) | 65.5742 ± 0.230009 (W 0.0565905) | 47.4374 ± 0.150355 (W 0.0390612) | · | 🔴 fork 1.38× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.00494 ± 0.000330546 (W 5.18585e-05) | 0.004969 ± 0.000266654 (W 4.40363e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012704 ± 7.60723e-05 (W 3.49314e-05) | 0.012694 ± 0.000137914 (W 4.12214e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044303 ± 0.003314 (W 0.000228194) | 0.045065 ± 0.00266959 (W 0.000349781) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.081221 ± 0.00177539 (W 0.00148522) | 0.100136 ± 0.00134116 (W 0.00509965) | 0.092995 ± 0.000784534 (W 0.000813358) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.318632 ± 0.010419 (W 0.0174611) | 0.361469 ± 0.00655818 (W 0.0228749) | 0.240275 ± 0.0023212 (W 0.00414047) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.33× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.10538 ± 0.0347201 (W 0.03199) | 1.21663 ± 0.00810951 (W 0.0353464) | 1.41161 ± 0.00282482 (W 0.0100164) | 🔵 fork 1.10× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.3425 ± 0.0433554 (W 0.0411591) | 2.32179 ± 0.0437493 (W 0.0176337) | 1.04758 ± 0.0020412 (W 0.00219113) | · | 🔴 fork 2.24× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.95088 ± 0.0283547 (W 0.0469101) | 6.93138 ± 0.0296838 (W 0.0319499) | 4.67194 ± 0.0171669 (W 0.00860147) | · | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 25.9103 ± 0.183065 (W 0.0929822) | 25.8784 ± 0.179994 (W 0.106353) | 21.2302 ± 0.0288564 (W 0.0283384) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290679 ± 0.000247003 (W 0.00166013) | 0.289176 ± 0.000266263 (W 0.00203557) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61734 ± 0.00533663 (W 0.00830399) | 2.62053 ± 0.00608495 (W 0.00529148) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9496 ± 0.0132429 (W 0.0543273) | 16.9614 ± 0.0642035 (W 0.109677) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.095459 ± 0.00156333 (W 0.00332847) | 0.083785 ± 0.000268228 (W 0.00164564) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.096481 ± 0.00112918 (W 0.00140889) | 0.084868 ± 0.000337641 (W 0.0010014) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.525595 ± 0.00447899 (W 0.00449292) | 0.523402 ± 0.00339493 (W 0.00304384) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.535012 ± 0.00312433 (W 0.00532473) | 0.527059 ± 0.000392039 (W 0.0037371) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.11799 ± 0.00153087 (W 0.0170031) | 4.09222 ± 0.0486035 (W 0.0326072) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.12876 ± 0.0185386 (W 0.0117241) | 4.10823 ± 0.0246012 (W 0.0102944) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145039 ± 0.00107251 (W 0.00200191) | 0.219822 ± 0.00882725 (W 0.00910367) | 0.133417 ± 0.000360644 (W 0.000402654) | 🔵 fork 1.52× faster than `faer-upstream` | 🔴 fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.702525 ± 0.117736 (W 0.00270798) | 0.849674 ± 0.115083 (W 0.0157847) | 0.323497 ± 0.000347812 (W 0.00282392) | · | 🔴 fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.27517 ± 0.0828999 (W 0.0745652) | 4.58294 ± 0.0646465 (W 0.0592645) | 1.64481 ± 0.0105856 (W 0.00658678) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 2.60× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.538009 ± 0.0221116 (W 0.0296198) | 1.48682 ± 0.0208128 (W 0.0324426) | 0.450245 ± 0.00221254 (W 0.00360509) | 🔵 fork 2.76× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.9096 ± 0.00521241 (W 0.0217473) | 3.76797 ± 0.0129989 (W 0.0664066) | 2.18617 ± 0.00404381 (W 0.00918072) | 🔵 fork 1.97× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.6654 ± 0.986829 (W 0.112088) | 13.1889 ± 0.829777 (W 0.426676) | 13.2791 ± 1.24369 (W 0.0266067) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.324692 ± 0.016364 (W 0.0092119) | 1.21718 ± 0.0400691 (W 0.0157362) | 0.182509 ± 0.000764847 (W 0.00172003) | 🔵 fork 3.75× faster than `faer-upstream` | 🔴 fork 1.78× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.34326 ± 0.00559977 (W 0.0187217) | 3.15063 ± 0.045824 (W 0.0633461) | 0.62016 ± 0.00354859 (W 0.00232654) | 🔵 fork 2.35× faster than `faer-upstream` | 🔴 fork 2.17× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.81681 ± 0.013979 (W 0.0274586) | 8.60394 ± 0.117344 (W 0.0837218) | 3.6633 ± 0.0081643 (W 0.00557448) | 🔵 fork 1.79× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.11183 ± 0.000269149 (W 0.00173187) | 0.181601 ± 0.00323679 (W 0.00375996) | 0.132335 ± 0.000256929 (W 0.00104816) | 🔵 fork 1.62× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.676164 ± 0.00116245 (W 0.00555043) | 0.776222 ± 0.00919319 (W 0.0129059) | 0.31221 ± 0.00196022 (W 0.00207725) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 2.17× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.20356 ± 0.0019354 (W 0.106327) | 4.40555 ± 0.0326326 (W 0.0390378) | 1.63495 ± 0.0126839 (W 0.00962921) | · | 🔴 fork 2.57× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.02591 ± 0.0129673 (W 0.0205696) | 3.02624 ± 0.00688431 (W 0.0246518) | 2.59251 ± 0.0132576 (W 0.00380343) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6092 ± 0.0196402 (W 0.0930813) | 13.6132 ± 0.0732036 (W 0.129629) | 12.3508 ± 0.0911329 (W 0.0150062) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.5775 ± 0.15454 (W 0.244153) | 60.8593 ± 0.219567 (W 0.536164) | 56.7666 ± 0.655469 (W 0.18032) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.18205 ± 0.0150957 (W 0.0140558) | 2.1608 ± 0.013184 (W 0.00475347) | 1.12156 ± 0.00713242 (W 0.00348019) | · | 🔴 fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.6636 ± 0.0058826 (W 0.0309995) | 10.647 ± 0.00929473 (W 0.0314476) | 6.08962 ± 0.0151126 (W 0.00962243) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.1814 ± 0.158689 (W 0.33441) | 47.1831 ± 0.123416 (W 0.345052) | 25.524 ± 0.0302288 (W 0.039433) | · | 🔴 fork 1.85× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004679 ± 0.000335998 (W 4.00911e-05) | 0.004698 ± 0.000183794 (W 3.23002e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012704 ± 0.000709679 (W 6.09852e-05) | 0.012724 ± 0.000532592 (W 3.64692e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044433 ± 0.00250871 (W 0.000610205) | 0.044642 ± 0.00347522 (W 0.000390316) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.083897 ± 9.67178e-05 (W 0.00236054) | 0.097922 ± 0.00145077 (W 0.00455045) | 0.09107 ± 0.000328075 (W 0.00142794) | 🔵 fork 1.17× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.341263 ± 0.00397072 (W 0.0202917) | 0.404843 ± 0.01374 (W 0.0145072) | 0.195687 ± 0.00320639 (W 0.00397796) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 1.74× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.0513 ± 0.00770294 (W 0.0408206) | 1.18642 ± 0.0371809 (W 0.0254682) | 0.953408 ± 0.00865978 (W 0.00984993) | 🔵 fork 1.13× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.37609 ± 0.0237168 (W 0.0287094) | 2.31943 ± 0.0312517 (W 0.0176674) | 0.987834 ± 0.00250934 (W 0.00483882) | · | 🔴 fork 2.41× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.85658 ± 0.0386347 (W 0.0282612) | 7.05674 ± 0.071353 (W 0.0371929) | 3.90652 ± 0.00587393 (W 0.0109079) | · | 🔴 fork 1.76× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.8458 ± 0.0545049 (W 0.0631482) | 24.5923 ± 0.139707 (W 0.173752) | 14.8352 ± 0.0225483 (W 0.0483173) | · | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290465 ± 0.00103446 (W 0.00176762) | 0.290299 ± 0.00122502 (W 0.00220646) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61154 ± 0.01389 (W 0.0113539) | 2.61697 ± 0.00706363 (W 0.00645547) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8211 ± 0.104642 (W 0.0988998) | 16.8759 ± 0.0991819 (W 0.125274) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.068747 ± 0.000359038 (W 0.00127646) | 0.101959 ± 0.00114303 (W 0.00167104) | - | 🔵 fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.06999 ± 0.000881083 (W 0.00120252) | 0.103492 ± 0.00129765 (W 0.00195414) | - | 🔵 fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.294687 ± 0.00180696 (W 0.00076587) | 0.376911 ± 0.0176904 (W 0.0167611) | - | 🔵 fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.296772 ± 0.00313065 (W 0.00258794) | 0.38186 ± 0.00668485 (W 0.018739) | - | 🔵 fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.23423 ± 0.00726695 (W 0.0172487) | 2.81627 ± 0.120348 (W 0.159993) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.24549 ± 0.00690647 (W 0.0136286) | 2.53039 ± 0.0111183 (W 0.0764447) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.14528 ± 0.000863186 (W 0.00101755) | 0.230348 ± 0.0165348 (W 0.0072554) | 0.132068 ± 0.000759659 (W 0.00144014) | 🔵 fork 1.59× faster than `faer-upstream` | 🔴 fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.712836 ± 0.118412 (W 0.00258474) | 0.917951 ± 0.123393 (W 0.0275757) | 0.316068 ± 0.00224436 (W 0.00432616) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 2.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.11269 ± 0.0397372 (W 0.0447734) | 4.76406 ± 0.0192689 (W 0.098912) | 1.22706 ± 0.0123742 (W 0.00628163) | 🔵 fork 1.16× faster than `faer-upstream` | 🔴 fork 3.35× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.560411 ± 0.00596056 (W 0.0201825) | 1.89675 ± 0.025826 (W 0.0362965) | 0.416744 ± 0.00129018 (W 0.00306691) | 🔵 fork 3.38× faster than `faer-upstream` | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.71755 ± 0.00548119 (W 0.0125303) | 4.78879 ± 0.00950761 (W 0.070488) | 2.02654 ± 0.0247072 (W 0.00370332) | 🔵 fork 2.79× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 8.31936 ± 0.0353413 (W 0.0315364) | 14.85 ± 0.0134841 (W 0.0848647) | 10.2774 ± 0.0213948 (W 0.0268569) | 🔵 fork 1.78× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.32332 ± 0.00375541 (W 0.00920546) | 1.64137 ± 0.0264024 (W 0.0216771) | 0.146152 ± 0.000792374 (W 0.00246568) | 🔵 fork 5.08× faster than `faer-upstream` | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.31422 ± 0.0122867 (W 0.0128444) | 4.11831 ± 0.0583802 (W 0.0715467) | 0.54284 ± 0.00202828 (W 0.00320955) | 🔵 fork 3.13× faster than `faer-upstream` | 🔴 fork 2.42× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.53758 ± 0.00689189 (W 0.0181749) | 10.2939 ± 0.074277 (W 0.160018) | 2.20194 ± 0.00490204 (W 0.00429014) | 🔵 fork 2.27× faster than `faer-upstream` | 🔴 fork 2.06× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.112038 ± 0.000727484 (W 0.00158323) | 0.190984 ± 0.00205051 (W 0.00666187) | 0.131795 ± 0.000325515 (W 0.000576248) | 🔵 fork 1.70× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.67224 ± 0.00595806 (W 0.00354915) | 0.830251 ± 0.0249279 (W 0.0298736) | 0.301661 ± 0.0344679 (W 0.00230155) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 2.23× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `solve/n512/b1` | 4.06915 ± 0.0329506 (W 0.0472003) | 4.53619 ± 0.0110123 (W 0.107799) | 1.20467 ± 0.0135946 (W 0.0072583) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 3.38× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01869 ± 0.00504622 (W 0.012954) | 3.0981 ± 0.0106204 (W 0.015861) | 2.48296 ± 0.0128128 (W 0.00706585) | · | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3481 ± 0.0607029 (W 0.0461447) | 13.6561 ± 0.025869 (W 0.0483193) | 11.4141 ± 0.0272394 (W 0.033428) | · | 🔴 fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.8964 ± 0.233824 (W 0.428095) | 60.5661 ± 0.1595 (W 0.614863) | 47.9042 ± 0.239168 (W 0.0663777) | · | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.19797 ± 0.0405732 (W 0.00625889) | 2.16679 ± 0.0342631 (W 0.00296477) | 1.11754 ± 0.00141156 (W 0.00268006) | · | 🔴 fork 1.97× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8285 ± 0.0286288 (W 0.0268136) | 10.793 ± 0.0138774 (W 0.00926329) | 5.99686 ± 0.0209808 (W 0.0257653) | · | 🔴 fork 1.81× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.691 ± 0.132522 (W 0.487562) | 48.6297 ± 0.222291 (W 0.53843) | 22.3069 ± 0.0381606 (W 0.295366) | · | 🔴 fork 2.18× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004248 ± 0.00024327 (W 3.03315e-05) | 0.004649 ± 0.000446233 (W 4.20714e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011492 ± 0.000700337 (W 5.21277e-05) | 0.011341 ± 0.000775381 (W 7.34861e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044252 ± 0.0035233 (W 0.00154889) | 0.049552 ± 0.00276485 (W 0.00277557) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.187789 ± 0.00114234 (W 0.00219486) | 0.187579 ± 0.00065745 (W 0.00110381) | 0.480753 ± 0.00402877 (W 0.0035204) | · | 🔵 fork 2.56× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.23246 ± 0.0147986 (W 0.00360617) | 1.22513 ± 0.0123963 (W 0.00360292) | 1.84886 ± 0.0189098 (W 0.00471744) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.92729 ± 0.0286207 (W 0.031189) | 7.93838 ± 0.0196959 (W 0.0207334) | 11.4302 ± 0.0174964 (W 0.0658283) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.27602 ± 0.00977373 (W 0.00768135) | 3.26744 ± 0.0165131 (W 0.00150964) | 4.42113 ± 0.00676139 (W 0.00829463) | · | 🔵 fork 1.35× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.5338 ± 0.073674 (W 0.0142063) | 17.4994 ± 0.0222023 (W 0.0301967) | 26.5937 ± 0.0787123 (W 0.0441516) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.827 ± 0.23629 (W 0.0804409) | 105.87 ± 0.10308 (W 0.107273) | 172.084 ± 0.339305 (W 0.47769) | · | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.778439 ± 0.00292023 (W 0.00498376) | 0.781337 ± 0.00201675 (W 0.00528438) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.92147 ± 0.0398046 (W 0.0151572) | 6.04021 ± 0.0315428 (W 0.0101119) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 41.0109 ± 0.36244 (W 0.0863038) | 41.2391 ± 0.441012 (W 0.0770358) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.04684 ± 0.00603689 (W 0.00218161) | 1.04569 ± 0.00593108 (W 0.00288479) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05551 ± 0.00407097 (W 0.00163825) | 1.05824 ± 0.0024956 (W 0.00177225) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.50666 ± 0.00395248 (W 0.0151191) | 7.49898 ± 0.0193238 (W 0.0171126) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.53501 ± 0.0202742 (W 0.0244745) | 7.50595 ± 0.0205436 (W 0.0165139) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9662 ± 0.0198977 (W 0.0673372) | 56.9825 ± 0.0565255 (W 0.09693) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.9417 ± 0.0452369 (W 0.0479189) | 57.1158 ± 0.0180114 (W 0.0853721) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.32349 ± 0.0014749 (W 0.00231553) | 0.329492 ± 0.00290178 (W 0.00429246) | 0.503616 ± 0.00141034 (W 0.00288932) | · | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.10909 ± 0.0026247 (W 0.00205944) | 2.21172 ± 0.00188889 (W 0.00695007) | 3.32658 ± 0.0118316 (W 0.00785763) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 14.6825 ± 0.0394631 (W 0.0580398) | 14.9376 ± 0.0190238 (W 0.0444422) | 21.1582 ± 0.0297944 (W 0.0289899) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.57801 ± 0.00384488 (W 0.00322671) | 1.58166 ± 0.00348983 (W 0.0029277) | 1.99552 ± 0.00177862 (W 0.00474946) | · | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.2482 ± 0.126629 (W 0.0194534) | 10.2996 ± 0.0300097 (W 0.0228292) | 12.3627 ± 0.0335605 (W 0.0325066) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.9694 ± 0.253785 (W 0.118373) | 70.0293 ± 0.0528924 (W 0.0327754) | 80.8149 ± 0.070179 (W 0.132982) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.81928 ± 0.00686337 (W 0.00319365) | 1.06439 ± 0.00120178 (W 0.00236098) | 0.954767 ± 0.00215384 (W 0.00229393) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.85067 ± 0.0201787 (W 0.00654885) | 6.52971 ± 0.0578298 (W 0.0133934) | 5.68301 ± 0.035522 (W 0.0149262) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.8433 ± 0.049956 (W 0.0803773) | 37.6057 ± 0.219668 (W 0.0324994) | 39.0686 ± 0.0327492 (W 0.0826259) | 🔵 fork 1.22× faster than `faer-upstream` | 🔵 fork 1.27× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.321349 ± 0.00138859 (W 0.00225414) | 0.329952 ± 0.00324916 (W 0.00347377) | 0.490091 ± 0.00139455 (W 0.00242021) | · | 🔵 fork 1.53× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.04825 ± 0.00288066 (W 0.00211341) | 2.14817 ± 0.00407753 (W 0.00305211) | 2.83466 ± 0.00355653 (W 0.00845752) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.6284 ± 0.0472239 (W 0.0501922) | 14.8733 ± 0.0136628 (W 0.0330645) | 18.815 ± 0.0190946 (W 0.0701956) | · | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.85058 ± 0.0469085 (W 0.0110082) | 5.83678 ± 0.0104323 (W 0.00858391) | 7.05916 ± 0.0136185 (W 0.0143013) | · | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.9333 ± 0.0837988 (W 0.0445054) | 35.0533 ± 0.0682081 (W 0.0683703) | 43.7597 ± 0.303136 (W 0.0573412) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 215.141 ± 0.310305 (W 0.471505) | 215.011 ± 0.356343 (W 0.24007) | 278.324 ± 2.20161 (W 0.577122) | · | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.56031 ± 0.00594592 (W 0.00291837) | 3.55941 ± 0.00698597 (W 0.00630084) | 2.7744 ± 0.00521661 (W 0.00827911) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 20.0237 ± 0.0377246 (W 0.0492941) | 20.0144 ± 0.0204335 (W 0.0377237) | 18.172 ± 0.0417877 (W 0.0463596) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 114.829 ± 0.143249 (W 0.400847) | 114.771 ± 0.223992 (W 0.0685475) | 123.466 ± 0.570009 (W 0.38073) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007584 ± 0.000175784 (W 2.795e-05) | 0.007574 ± 3.51188e-05 (W 3.78153e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023845 ± 0.000661955 (W 7.32953e-05) | 0.023745 ± 0.000815256 (W 6.65582e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.085609 ± 0.000729155 (W 0.00144275) | 0.085449 ± 0.000375948 (W 0.002157) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.190703 ± 0.00140062 (W 0.0020239) | 0.200222 ± 0.000943581 (W 0.00354403) | 0.480913 ± 0.00396944 (W 0.00254091) | · | 🔵 fork 2.52× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.84634 ± 0.0230916 (W 0.010129) | 0.879179 ± 0.0189218 (W 0.0100615) | 0.799484 ± 0.00319643 (W 0.0130329) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.37169 ± 0.0166951 (W 0.0209596) | 3.41856 ± 0.00691207 (W 0.0293773) | 3.65615 ± 0.00301327 (W 0.0115309) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.00185 ± 0.0121125 (W 0.0305518) | 3.00039 ± 0.0183471 (W 0.0264014) | 2.04371 ± 0.0022911 (W 0.00576731) | · | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.4255 ± 0.0298129 (W 0.052917) | 11.4862 ± 0.0580354 (W 0.0339758) | 10.1398 ± 0.0174276 (W 0.0164765) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.6351 ± 0.122764 (W 0.110028) | 46.707 ± 0.136735 (W 0.133766) | 53.2122 ± 0.0687935 (W 0.0663077) | · | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.77307 ± 0.000497279 (W 0.00601706) | 0.779432 ± 0.00815453 (W 0.00615879) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.92955 ± 0.0181817 (W 0.0146669) | 6.04522 ± 0.0347404 (W 0.0177415) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 27.0095 ± 0.212089 (W 0.0958933) | 27.2387 ± 0.0539883 (W 0.0564896) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.285982 ± 0.00136277 (W 0.00165833) | 0.286111 ± 0.000420257 (W 0.000959271) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.289597 ± 0.00256519 (W 0.00154947) | 0.288957 ± 0.000715618 (W 0.0017426) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93881 ± 0.0128682 (W 0.00182131) | 1.92974 ± 0.00650149 (W 0.00290805) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93771 ± 0.0057014 (W 0.0049618) | 1.92978 ± 0.00785639 (W 0.00501999) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.819 ± 0.0742967 (W 0.0457442) | 14.7309 ± 0.0441812 (W 0.027163) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.7502 ± 0.0812711 (W 0.0498136) | 14.7517 ± 0.0351795 (W 0.0218842) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.321457 ± 0.000193083 (W 0.00286715) | 0.34543 ± 0.00663757 (W 0.00428725) | 0.482496 ± 0.00165942 (W 0.00298854) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.56034 ± 0.00637638 (W 0.0196174) | 1.70158 ± 0.0192452 (W 0.0226302) | 1.01642 ± 0.00138948 (W 0.00125119) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.54× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 7.32187 ± 0.0208519 (W 0.0613382) | 7.49651 ± 0.0447136 (W 0.0291659) | 6.13604 ± 0.0444318 (W 0.0143641) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.03235 ± 0.00344654 (W 0.00629618) | 2.00012 ± 0.0288674 (W 0.0152632) | 1.03923 ± 0.0030021 (W 0.00251511) | 🔵 fork 1.94× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.6298 ± 0.00817705 (W 0.0398092) | 6.35895 ± 0.00835292 (W 0.0639663) | 4.78524 ± 0.0101206 (W 0.0116386) | 🔵 fork 1.37× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 23.4728 ± 0.0427143 (W 0.091033) | 27.3394 ± 0.102782 (W 0.106739) | 28.7032 ± 0.104473 (W 0.144688) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.614062 ± 0.00398194 (W 0.0119929) | 1.84907 ± 0.035441 (W 0.0145465) | 0.453262 ± 0.00153842 (W 0.0019974) | 🔵 fork 3.01× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.95734 ± 0.0817878 (W 0.0625976) | 7.29286 ± 0.0814809 (W 0.0532441) | 1.63464 ± 0.00290138 (W 0.0043255) | 🔵 fork 2.47× faster than `faer-upstream` | 🔴 fork 1.81× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n512/b1` | 12.0942 ± 0.0212315 (W 0.0846713) | 26.9184 ± 0.349026 (W 0.114432) | 11.4411 ± 0.0170885 (W 0.0300368) | 🔵 fork 2.23× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.318901 ± 0.000765478 (W 0.00210495) | 0.345461 ± 0.00109318 (W 0.00363197) | 0.467479 ± 0.00152922 (W 0.00230579) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.44395 ± 0.00797278 (W 0.0215457) | 1.56504 ± 0.00280882 (W 0.0147488) | 0.893708 ± 0.000833997 (W 0.0028733) | 🔵 fork 1.08× faster than `faer-upstream` | 🔴 fork 1.62× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 7.19798 ± 0.0214362 (W 0.0288289) | 7.34021 ± 0.0182909 (W 0.0377449) | 5.66717 ± 0.0562951 (W 0.0168031) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.44472 ± 0.0266196 (W 0.0261964) | 4.44407 ± 0.0364982 (W 0.00809547) | 4.16048 ± 0.003075 (W 0.00810459) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 23.0863 ± 0.142948 (W 0.0917679) | 23.2633 ± 0.0739373 (W 0.15499) | 21.2421 ± 0.0413878 (W 0.0650582) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 96.396 ± 0.0538332 (W 0.39554) | 96.4021 ± 0.334099 (W 0.312057) | 114.1 ± 0.174022 (W 0.339755) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.13146 ± 0.0209892 (W 0.0077511) | 3.15703 ± 0.02635 (W 0.0123914) | 2.02594 ± 0.00266546 (W 0.00321086) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.7581 ± 0.0465413 (W 0.0591392) | 17.7741 ± 0.0253203 (W 0.0933447) | 11.0395 ± 0.0223649 (W 0.0384738) | · | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.4923 ± 0.0520947 (W 0.314789) | 66.4149 ± 0.145433 (W 0.245023) | 55.8859 ± 0.317364 (W 0.0785696) | · | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007555 ± 3.04467e-05 (W 5.09333e-05) | 0.007614 ± 3.05505e-05 (W 3.945e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023324 ± 0.000313072 (W 8.75054e-05) | 0.023514 ± 5.56507e-05 (W 9.09395e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.070531 ± 0.000977847 (W 0.00160934) | 0.06958 ± 0.00104782 (W 0.00193092) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.195965 ± 0.00141349 (W 0.00236405) | 0.211814 ± 0.00352867 (W 0.00647119) | 0.478177 ± 0.00129059 (W 0.00340533) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.44× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.832621 ± 0.0140177 (W 0.0209976) | 0.886763 ± 0.0132873 (W 0.0182565) | 0.660278 ± 0.00259863 (W 0.00347163) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.81373 ± 0.00684258 (W 0.0333282) | 2.8669 ± 0.00869688 (W 0.0144911) | 2.24377 ± 0.0267471 (W 0.030298) | · | 🔴 fork 1.25× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.95425 ± 0.0488228 (W 0.0229844) | 3.00711 ± 0.00688089 (W 0.0131506) | 1.69347 ± 0.00502477 (W 0.00684874) | · | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.859 ± 0.045371 (W 0.0357677) | 11.1327 ± 0.0936997 (W 0.0445335) | 8.03023 ± 0.0212083 (W 0.017031) | · | 🔴 fork 1.35× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 39.1558 ± 0.216946 (W 0.096292) | 40.154 ± 0.108577 (W 0.188699) | 37.0816 ± 0.122268 (W 0.021405) | · | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.774983 ± 0.00469107 (W 0.00538251) | 0.78096 ± 0.00661701 (W 0.00460175) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.86941 ± 0.0130876 (W 0.0109448) | 5.9927 ± 0.0374392 (W 0.0165715) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.2673 ± 0.0953368 (W 0.0626322) | 25.5879 ± 0.039462 (W 0.181287) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.182853 ± 0.00172912 (W 0.00156002) | 0.270873 ± 0.00122951 (W 0.00226548) | - | 🔵 fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.185505 ± 0.00252984 (W 0.00149644) | 0.270252 ± 0.0010615 (W 0.00102469) | - | 🔵 fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01148 ± 0.00397837 (W 0.00591914) | 1.28529 ± 0.0789214 (W 0.0817343) | - | 🔵 fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01081 ± 0.00123002 (W 0.00519846) | 1.28683 ± 0.0143353 (W 0.0617191) | - | 🔵 fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.10632 ± 0.0173835 (W 0.0432473) | 8.77365 ± 0.610232 (W 0.597259) | - | 🔵 fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.13805 ± 0.0665471 (W 0.0855884) | 8.85584 ± 0.130356 (W 0.47701) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.324147 ± 0.00156412 (W 0.00270667) | 0.369052 ± 0.0013507 (W 0.00706529) | 0.486805 ± 0.0079832 (W 0.00134559) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.53681 ± 0.00659994 (W 0.0193298) | 1.68277 ± 0.00907406 (W 0.0228303) | 0.694632 ± 0.0050142 (W 0.00411555) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.22771 ± 0.0395255 (W 0.0495747) | 6.46958 ± 0.0144577 (W 0.0541579) | 3.58758 ± 0.00688799 (W 0.00747033) | · | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.00474 ± 0.137186 (W 0.0157072) | 2.47491 ± 0.00772939 (W 0.0244568) | 0.782803 ± 0.00740882 (W 0.00468904) | 🔵 fork 2.46× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/n256/b1` | 3.48714 ± 0.030335 (W 0.0216892) | 7.04469 ± 0.0122554 (W 0.0542266) | 3.85487 ± 0.0409258 (W 0.0123083) | 🔵 fork 2.02× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 16.1084 ± 0.0017951 (W 0.0499839) | 23.5392 ± 0.169537 (W 0.25663) | 16.0688 ± 0.0267843 (W 0.030269) | 🔵 fork 1.46× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.629439 ± 0.00350542 (W 0.00592346) | 2.35617 ± 29.1448 (W 0.0288406) | 0.323701 ± 0.00101249 (W 0.00193566) | · | 🔴 fork 1.94× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 2.47747 ± 0.0166055 (W 0.0280479) | 8.62426 ± 0.0692377 (W 1.01092) | 1.62376 ± 0.00187892 (W 0.00235368) | 🔵 fork 3.48× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.41549 ± 0.0223964 (W 0.0404724) | 27.874 ± 0.0637054 (W 0.206675) | 5.83745 ± 0.00763769 (W 0.0109899) | 🔵 fork 2.96× faster than `faer-upstream` | 🔴 fork 1.61× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.322113 ± 0.00199694 (W 0.00230378) | 0.357674 ± 0.0073354 (W 0.00580367) | 0.474459 ± 0.00416906 (W 0.00323562) | 🔵 fork 1.11× faster than `faer-upstream` | 🔵 fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.38749 ± 0.0088431 (W 0.0198637) | 1.54681 ± 0.00900934 (W 0.0198557) | 0.671729 ± 0.00720094 (W 0.00279208) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.06494 ± 0.0266373 (W 0.023501) | 6.26455 ± 0.0178576 (W 0.0490121) | 3.45596 ± 0.0158411 (W 0.0212931) | · | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.35373 ± 0.0127697 (W 0.0270871) | 4.57707 ± 0.0173001 (W 0.0302705) | 3.65659 ± 0.00409069 (W 0.00794478) | 🔵 fork 1.05× faster than `faer-upstream` | 🔴 fork 1.19× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.046 ± 0.009383 (W 0.0795594) | 22.6873 ± 0.0687813 (W 0.0447581) | 17.2805 ± 0.0454113 (W 0.0227581) | · | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 81.2884 ± 0.133449 (W 0.45921) | 82.8297 ± 0.235559 (W 0.354076) | 84.6807 ± 1.18191 (W 0.474193) | · | · |  |
| `svd_values/n128/b1` | 3.17821 ± 0.0309366 (W 0.00465397) | 3.17874 ± 0.0226264 (W 0.0207942) | 1.91941 ± 0.00574438 (W 0.00362833) | · | 🔴 fork 1.66× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.8167 ± 0.0852714 (W 0.0218604) | 17.8181 ± 0.0673931 (W 0.0392426) | 9.66681 ± 0.114955 (W 0.0111584) | · | 🔴 fork 1.84× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 62.0493 ± 0.188989 (W 0.233194) | 62.1727 ± 0.136828 (W 0.238725) | 42.9661 ± 0.0916477 (W 0.0953513) | · | 🔴 fork 1.44× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007594 ± 5.7735e-07 (W 4.28042e-05) | 0.007554 ± 6.35085e-06 (W 4.75836e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023333 ± 0.000292167 (W 0.00126152) | 0.023304 ± 0.000354119 (W 4.05623e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.070271 ± 0.00395745 (W 0.00123) | 0.077936 ± 0.00472338 (W 0.00289987) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175006 ± 0.000775011 (W 0.00163637) | 0.174905 ± 0.000594887 (W 0.00163534) | 0.40859 ± 0.0022219 (W 0.00383313) | · | 🔵 fork 2.33× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13204 ± 0.00292345 (W 0.00245354) | 1.13162 ± 0.00486378 (W 0.00143789) | 1.60063 ± 0.000866562 (W 0.0115817) | · | 🔵 fork 1.41× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.54255 ± 0.0119679 (W 0.010485) | 7.53992 ± 0.016769 (W 0.0139031) | 12.0864 ± 0.00795493 (W 0.0296735) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.26778 ± 0.0104509 (W 0.00451493) | 3.25635 ± 0.000916597 (W 0.0044398) | 4.36886 ± 0.00338898 (W 0.00671139) | · | 🔵 fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.4175 ± 0.0623856 (W 0.033969) | 17.3856 ± 0.0323332 (W 0.0224827) | 26.3193 ± 0.0297297 (W 0.0624122) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.643 ± 0.184679 (W 0.0727655) | 105.52 ± 0.0111837 (W 0.129062) | 170.071 ± 0.2462 (W 0.409453) | · | 🔵 fork 1.61× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.753318 ± 0.00239571 (W 0.00357334) | 0.74673 ± 0.00544069 (W 0.00482338) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.76588 ± 0.0254268 (W 0.017542) | 5.76127 ± 0.0356422 (W 0.0116096) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.1802 ± 0.511935 (W 0.0350136) | 40.1279 ± 0.360475 (W 0.0454892) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03683 ± 0.00203529 (W 0.00260077) | 1.03696 ± 0.00438953 (W 0.000822173) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04061 ± 0.00145471 (W 0.00091206) | 1.0416 ± 0.00349755 (W 0.00121954) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.40221 ± 0.00448498 (W 0.0222286) | 7.40422 ± 0.0125718 (W 0.0127947) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.41679 ± 0.00233856 (W 0.0178329) | 7.42109 ± 0.00660324 (W 0.0151118) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8951 ± 0.0770202 (W 0.237388) | 56.7776 ± 0.0404217 (W 0.169242) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7787 ± 0.0996595 (W 0.0597001) | 56.7354 ± 0.0433509 (W 0.0757569) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296921 ± 0.00123262 (W 0.00191439) | 0.296968 ± 0.0015511 (W 0.00187513) | 0.458601 ± 0.00125711 (W 0.0025136) | · | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.99921 ± 0.00994882 (W 0.00154857) | 1.99759 ± 0.0122773 (W 0.00125866) | 3.16128 ± 0.00656875 (W 0.00996919) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 13.8609 ± 0.0310865 (W 0.0366416) | 13.8802 ± 0.0130645 (W 0.0694355) | 19.7909 ± 0.0473314 (W 0.0473327) | · | 🔵 fork 1.43× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.55204 ± 0.0123525 (W 0.00296957) | 1.55209 ± 0.000937751 (W 0.00270647) | 1.98181 ± 0.00421882 (W 0.00565005) | · | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.1125 ± 0.0279481 (W 0.0183229) | 10.1236 ± 0.0213614 (W 0.018635) | 12.3564 ± 0.0321036 (W 0.0378769) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.0826 ± 0.260792 (W 0.048976) | 69.1018 ± 0.0826698 (W 0.0394849) | 79.882 ± 0.0487468 (W 0.134589) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.748243 ± 0.00134315 (W 0.00248077) | 0.749497 ± 0.00222702 (W 0.00245844) | 0.910896 ± 0.00123516 (W 0.00258786) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.48473 ± 0.0114092 (W 0.00590088) | 4.49138 ± 0.00437305 (W 0.00378003) | 5.51016 ± 0.0333998 (W 0.00963131) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 29.0004 ± 0.0157145 (W 0.0482098) | 29.0616 ± 0.0883741 (W 0.031736) | 37.9484 ± 0.0202255 (W 0.0660553) | · | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.293782 ± 0.00062934 (W 0.00234901) | 0.293546 ± 0.000750139 (W 0.00197198) | 0.444815 ± 0.000626184 (W 0.00189058) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.93573 ± 0.00937637 (W 0.0021389) | 1.93889 ± 0.0115646 (W 0.00213422) | 2.66541 ± 0.0104719 (W 0.00739879) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 13.8773 ± 0.01466 (W 0.104566) | 13.9003 ± 0.0369846 (W 0.0725141) | 18.068 ± 0.0165104 (W 0.0454452) | · | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.81259 ± 0.00429608 (W 0.0152065) | 5.80518 ± 0.0100244 (W 0.0131396) | 6.97295 ± 0.00804553 (W 0.0110886) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.6501 ± 0.0181487 (W 0.0600273) | 34.6642 ± 0.0454856 (W 0.0345833) | 43.3223 ± 0.103376 (W 0.0433529) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 214.374 ± 0.462561 (W 0.354834) | 214.092 ± 0.396819 (W 0.421195) | 307.984 ± 0.903969 (W 0.482564) | · | 🔵 fork 1.44× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.54368 ± 0.00863223 (W 0.00973508) | 3.54239 ± 0.00727427 (W 0.00462045) | 2.71168 ± 0.0043369 (W 0.00408242) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.6934 ± 0.036695 (W 0.0338123) | 19.7375 ± 0.0267654 (W 0.0385602) | 17.9458 ± 0.102315 (W 0.0483064) | · | 🔴 fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 113.792 ± 0.205362 (W 0.0611916) | 113.826 ± 0.284689 (W 0.135823) | 150.935 ± 0.451025 (W 0.271049) | · | 🔵 fork 1.33× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008215 ± 0.000205183 (W 2.45418e-05) | 0.008276 ± 0.000176163 (W 3.17222e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025457 ± 0.000576007 (W 3.36779e-05) | 0.025117 ± 0.000502003 (W 0.00198978) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.091601 ± 0.0026896 (W 0.00115906) | 0.091831 ± 0.00187765 (W 0.000680579) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.170206 ± 0.00564031 (W 0.00346051) | 0.190624 ± 0.0012809 (W 0.00411967) | 0.409511 ± 0.00228655 (W 0.00344371) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 2.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.751524 ± 0.0046382 (W 0.00470592) | 0.77839 ± 0.011463 (W 0.0139783) | 0.596048 ± 0.0070836 (W 0.0111032) | · | 🔴 fork 1.26× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 3.00329 ± 0.0148774 (W 0.0111672) | 3.05647 ± 0.0289296 (W 0.0349535) | 3.22139 ± 0.00292426 (W 0.0105417) | · | 🔵 fork 1.07× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.99462 ± 0.0222885 (W 0.0230836) | 2.95618 ± 0.0284151 (W 0.0267928) | 2.00098 ± 0.00610865 (W 0.00575994) | · | 🔴 fork 1.50× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.3669 ± 0.0173185 (W 0.0406853) | 11.3551 ± 0.061091 (W 0.0484645) | 9.99089 ± 0.128258 (W 0.0442871) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.3039 ± 0.165784 (W 0.134533) | 46.2423 ± 0.016284 (W 0.128808) | 52.5194 ± 0.102994 (W 0.0405862) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.750104 ± 0.000420154 (W 0.00365895) | 0.749791 ± 0.00204214 (W 0.0051563) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.7919 ± 0.0314686 (W 0.021326) | 5.76712 ± 0.027478 (W 0.016151) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.3014 ± 0.11036 (W 0.110433) | 26.3076 ± 0.085302 (W 0.107968) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.296015 ± 0.000897217 (W 0.00416376) | 0.287183 ± 0.00136096 (W 0.000453588) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.299295 ± 0.000500696 (W 0.00230274) | 0.289693 ± 0.00161416 (W 0.0018308) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92311 ± 0.00130237 (W 0.00418706) | 1.92259 ± 0.00887253 (W 0.00474114) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.9222 ± 0.00531096 (W 0.00532059) | 1.91964 ± 0.0103642 (W 0.00400995) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7974 ± 0.0349684 (W 0.0879383) | 14.7723 ± 0.0271285 (W 0.0201318) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.7614 ± 0.0105196 (W 0.0190896) | 14.7857 ± 0.0560727 (W 0.0247725) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296536 ± 0.000549229 (W 0.00279725) | 0.31796 ± 0.00259066 (W 0.00667977) | 0.45855 ± 0.00198974 (W 0.00177915) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.4556 ± 0.0112484 (W 0.0114271) | 1.48523 ± 0.021406 (W 0.0216562) | 0.974949 ± 0.00274211 (W 0.00310596) | · | 🔴 fork 1.49× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.49743 ± 0.0243395 (W 0.018093) | 6.53974 ± 0.0565551 (W 0.0356476) | 5.80939 ± 0.0317035 (W 0.0143649) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.01026 ± 0.00355063 (W 0.00485653) | 1.95723 ± 0.0214286 (W 0.0240827) | 1.05738 ± 0.00554204 (W 0.00544441) | 🔵 fork 1.94× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.48911 ± 0.00601702 (W 0.0508726) | 6.03759 ± 0.0402659 (W 0.0456156) | 4.99799 ± 0.00877972 (W 0.00888522) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 22.6132 ± 0.0850584 (W 0.412759) | 26.2396 ± 0.00553156 (W 0.11042) | 29.1309 ± 0.134514 (W 0.0550426) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.557284 ± 0.0331498 (W 0.00321917) | 1.44512 ± 0.0125677 (W 0.00866872) | 0.436499 ± 0.00229252 (W 0.00292446) | 🔵 fork 2.59× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 2.78916 ± 0.0288414 (W 0.0569153) | 4.43706 ± 0.0335654 (W 0.0387134) | 1.57993 ± 0.00415246 (W 0.00329328) | 🔵 fork 1.59× faster than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.4421 ± 0.0873021 (W 0.0762272) | 14.9807 ± 0.0605826 (W 0.0667852) | 11.027 ± 0.16262 (W 0.0172133) | 🔵 fork 1.31× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.294065 ± 0.000688401 (W 0.00275138) | 0.307761 ± 0.0019767 (W 0.00980411) | 0.444203 ± 0.00146807 (W 0.00231574) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.32622 ± 0.0123366 (W 0.0144664) | 1.3712 ± 0.012064 (W 0.00902888) | 0.863995 ± 0.00399735 (W 0.00422316) | · | 🔴 fork 1.53× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.41639 ± 0.441988 (W 0.023441) | 6.43974 ± 0.0191662 (W 0.0270449) | 5.33675 ± 0.111088 (W 0.0158679) | · | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 4.43568 ± 0.00902363 (W 0.0199052) | 4.42778 ± 0.00637863 (W 0.0247964) | 4.10187 ± 0.00407632 (W 0.013262) | · | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.9237 ± 0.0786852 (W 0.148724) | 22.9246 ± 0.0737509 (W 0.0747225) | 21.0313 ± 0.0290766 (W 0.0307983) | · | 🔴 fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 95.2935 ± 0.160513 (W 0.465987) | 94.8755 ± 0.206775 (W 0.56034) | 112.736 ± 0.787925 (W 0.141253) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.11334 ± 0.0301239 (W 0.00641295) | 3.10139 ± 0.00492358 (W 0.00526198) | 2.01411 ± 0.00674974 (W 0.00396964) | · | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.5554 ± 0.04117 (W 0.0636602) | 17.5396 ± 0.0642316 (W 0.054025) | 10.998 ± 0.00545389 (W 0.0522274) | · | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.6683 ± 0.29542 (W 0.280528) | 65.4568 ± 0.177229 (W 0.212932) | 55.4616 ± 6.46795 (W 0.0722341) | · | 🔴 fork 1.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `triangular_solve/n128/b1` | 0.008145 ± 0.000285062 (W 1.68285e-05) | 0.008125 ± 0.000212784 (W 3.66101e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024956 ± 0.000263439 (W 3.36155e-05) | 0.024615 ± 8.7409e-05 (W 0.000193624) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.076364 ± 0.00452145 (W 0.00259176) | 0.078417 ± 0.00439216 (W 0.0016368) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.183173 ± 0.00140816 (W 0.00334501) | 0.197651 ± 0.00172888 (W 0.0040117) | 0.409783 ± 0.0027687 (W 0.00371103) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.24× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.744692 ± 0.0071542 (W 0.00882049) | 0.795817 ± 0.0098501 (W 0.0141685) | 0.464391 ± 0.00292021 (W 0.00341002) | 🔵 fork 1.07× faster than `faer-upstream` | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.4282 ± 0.00536161 (W 0.024712) | 2.51307 ± 0.0024728 (W 0.0167197) | 1.85565 ± 0.00581848 (W 0.0208153) | · | 🔴 fork 1.31× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.95715 ± 0.00780762 (W 0.0199078) | 3.01747 ± 0.0130816 (W 0.0298507) | 1.65632 ± 0.0036376 (W 0.00445311) | · | 🔴 fork 1.79× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.7853 ± 0.036488 (W 0.0347176) | 11.0951 ± 0.0792292 (W 0.0538119) | 7.90247 ± 0.243169 (W 0.0153434) | · | 🔴 fork 1.36× slower than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n512/b1` | 39.1018 ± 0.33743 (W 0.142806) | 39.7674 ± 0.0266245 (W 0.176368) | 36.5832 ± 0.0637623 (W 0.0695687) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.753669 ± 0.00617293 (W 0.00432256) | 0.746489 ± 0.00304062 (W 0.00429983) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.73421 ± 0.0102739 (W 0.0106809) | 5.72844 ± 0.00840853 (W 0.0144529) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.616 ± 0.129353 (W 0.0721868) | 24.5605 ± 0.0968802 (W 0.146853) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.196615 ± 0.0050836 (W 0.00590821) | 0.277296 ± 0.000688505 (W 0.0030152) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.196425 ± 0.00175524 (W 0.00171421) | 0.277851 ± 0.00233656 (W 0.00164274) | - | 🔵 fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01925 ± 0.000414145 (W 0.00533161) | 1.28307 ± 0.00322071 (W 0.0580943) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01962 ± 0.00701536 (W 0.00922743) | 1.27978 ± 0.00779485 (W 0.0173694) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.2192 ± 0.0321968 (W 0.0384627) | 8.7652 ± 0.602407 (W 0.650032) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.23035 ± 0.108383 (W 0.0231076) | 8.82322 ± 0.0411437 (W 0.484053) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.296927 ± 0.00144012 (W 0.00216054) | 0.334307 ± 0.00817824 (W 0.00777407) | 0.456435 ± 0.00202864 (W 0.00226785) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.54× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.41185 ± 0.00777304 (W 0.0157929) | 1.4781 ± 0.00509755 (W 0.0192074) | 0.67727 ± 0.00328837 (W 0.0060395) | · | 🔴 fork 2.08× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 5.42303 ± 0.0114776 (W 0.0355065) | 5.59165 ± 0.0144417 (W 0.0393736) | 3.46264 ± 0.0135999 (W 0.00908899) | · | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.98181 ± 0.0143251 (W 0.0145253) | 2.47991 ± 0.0145028 (W 0.0253234) | 0.795531 ± 0.00190489 (W 0.00527128) | 🔵 fork 2.53× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.36507 ± 0.0180344 (W 0.0160673) | 6.80201 ± 0.0369254 (W 0.0695736) | 4.12187 ± 0.035424 (W 0.0110864) | 🔵 fork 2.02× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 15.212 ± 0.00971411 (W 0.038627) | 22.4541 ± 0.09625 (W 0.128814) | 17.0919 ± 0.0446381 (W 0.030523) | 🔵 fork 1.48× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.572594 ± 0.00489918 (W 0.00644304) | 1.92632 ± 0.0163126 (W 0.0153397) | 0.307081 ± 0.00161691 (W 0.00261474) | 🔵 fork 3.36× faster than `faer-upstream` | 🔴 fork 1.86× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.32686 ± 0.00498987 (W 0.0191093) | 5.42327 ± 0.0454206 (W 0.0639381) | 1.58656 ± 0.00620015 (W 0.00300024) | 🔵 fork 2.33× faster than `faer-upstream` | 🔴 fork 1.47× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.83072 ± 0.0260756 (W 0.0301714) | 15.1177 ± 0.0895368 (W 0.128064) | 5.62866 ± 0.00827745 (W 0.0112062) | 🔵 fork 1.71× faster than `faer-upstream` | 🔴 fork 1.57× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.295374 ± 0.00298036 (W 0.00239081) | 0.332734 ± 0.00172275 (W 0.00470138) | 0.443885 ± 0.00340202 (W 0.00234725) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.26199 ± 0.00834612 (W 0.0135574) | 1.33722 ± 0.0156273 (W 0.0153258) | 0.653546 ± 0.0043095 (W 0.00502722) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.93× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.25406 ± 0.00669235 (W 0.0479686) | 5.38203 ± 0.0175733 (W 0.0370698) | 3.30585 ± 0.0262199 (W 0.0123929) | · | 🔴 fork 1.59× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.34046 ± 0.0432324 (W 0.0151656) | 4.58997 ± 0.0660505 (W 0.0265103) | 3.61267 ± 0.453678 (W 0.0100572) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n256/b1` | 21.7575 ± 0.0683529 (W 0.0404774) | 22.4171 ± 0.0124183 (W 0.0341362) | 17.1239 ± 0.0281555 (W 0.0208084) | · | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.2075 ± 0.286965 (W 0.698912) | 82.1135 ± 0.185365 (W 0.456079) | 81.8837 ± 0.0208597 (W 0.0599428) | · | · |  |
| `svd_values/n128/b1` | 3.13019 ± 0.0266884 (W 0.0186764) | 3.11436 ± 0.00363802 (W 0.00552818) | 1.90613 ± 0.0278156 (W 0.00412792) | · | 🔴 fork 1.64× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.5499 ± 0.102743 (W 0.0416488) | 17.5997 ± 0.122834 (W 0.0520952) | 9.6548 ± 0.131749 (W 0.0163612) | · | 🔴 fork 1.82× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 61.1169 ± 0.192469 (W 0.148919) | 61.5648 ± 0.0972536 (W 0.18554) | 42.8311 ± 0.0778106 (W 0.0558618) | · | 🔴 fork 1.43× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008205 ± 0.000108583 (W 4.15933e-05) | 0.008235 ± 0.000115902 (W 4.61433e-05) | - | · | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024806 ± 0.000305855 (W 0.00145172) | 0.025357 ± 0.000560762 (W 3.18795e-05) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.076814 ± 0.00109627 (W 0.00157996) | 0.081571 ± 0.0017026 (W 0.00324238) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.81814 ± 0.00126937 (W 0.00240152) | 0.814236 ± 0.00405493 (W 0.00660681) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 48.5728 ± 0.665032 (W 0.121812) | 52.2046 ± 2.23111 (W 0.157834) | - | 🔵 fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.557175 ± 0.00261694 (W 0.00350336) | 0.557937 ± 0.00873019 (W 0.00299824) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.554621 ± 0.00291449 (W 0.00200507) | 0.559269 ± 0.00780582 (W 0.00318082) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 34.9935 ± 0.0120791 (W 0.0893071) | 35.0733 ± 0.12474 (W 0.0412218) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.0269 ± 0.0571926 (W 0.0912276) | 35.0843 ± 0.0415127 (W 0.0379715) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.471573 ± 0.00147719 (W 0.00315967) | 0.470872 ± 0.00140796 (W 0.00464239) | 0.659626 ± 0.133854 (W 0.00353345) | · | 🔵 fork 1.40× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.4993 ± 0.131976 (W 0.0348866) | 19.0679 ± 0.0806638 (W 0.0688224) | 18.4084 ± 2.16494 (W 0.141785) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.58324 ± 0.0112812 (W 0.00419038) | 1.54916 ± 0.00641191 (W 0.00363925) | 1.86071 ± 0.0097966 (W 0.00188406) | · | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 70.7987 ± 2.50925 (W 0.167598) | 73.9567 ± 2.36349 (W 0.209356) | 81.5238 ± 0.43694 (W 0.30995) | · | 🔵 fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.05731 ± 0.00527864 (W 0.00159362) | 1.85994 ± 0.0137449 (W 0.00598676) | 0.909129 ± 0.00333671 (W 0.00194255) | 🔵 fork 1.76× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 31.6609 ± 0.305149 (W 0.106782) | 78.074 ± 0.273813 (W 0.0778456) | 34.854 ± 0.520379 (W 0.127219) | 🔵 fork 2.47× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.5046 ± 0.00659893 (W 0.0103279) | 2.49926 ± 0.00718532 (W 0.00357441) | 3.0552 ± 0.00473397 (W 0.008358) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.5614 ± 0.355884 (W 0.142241) | 88.451 ± 0.384505 (W 0.191919) | 120.85 ± 0.140377 (W 0.171651) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48455 ± 0.00322534 (W 0.00714994) | 1.49092 ± 0.00281938 (W 0.00716033) | 1.38757 ± 0.00224468 (W 0.00382732) | · | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.8835 ± 0.0481968 (W 0.0589321) | 44.8762 ± 0.0989255 (W 0.0702512) | 46.2026 ± 0.189831 (W 0.14058) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.81221 ± 0.00203792 (W 0.00296267) | 0.817109 ± 0.0180256 (W 0.00493444) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.9209 ± 0.132192 (W 0.426255) | 25.7174 ± 1.12728 (W 1.11642) | - | 🔵 fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.187057 ± 0.0020416 (W 0.00193356) | 0.161992 ± 0.00451989 (W 0.00198794) | - | 🔴 fork 1.15× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.184646 ± 0.00324672 (W 0.00788924) | 0.161273 ± 0.00390391 (W 0.00108523) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.0728 ± 0.0477584 (W 0.0826373) | 9.44182 ± 0.0121843 (W 0.0270016) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.1947 ± 0.0902384 (W 0.0919605) | 9.45032 ± 0.181268 (W 0.0342843) | - | 🔴 fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.495258 ± 0.0117532 (W 0.0127672) | 0.504054 ± 0.0061576 (W 0.00454216) | 0.531125 ± 0.118147 (W 0.00462575) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.45829 ± 0.115641 (W 0.151772) | 13.063 ± 0.0253468 (W 0.0350775) | 13.4767 ± 1.87338 (W 0.0618304) | 🔵 fork 1.38× faster than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.28715 ± 0.00904679 (W 0.01278) | 1.73428 ± 0.0138609 (W 0.0107981) | 1.0668 ± 0.00445607 (W 0.00632245) | 🔵 fork 1.35× faster than `faer-upstream` | 🔴 fork 1.21× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 28.4341 ± 0.211288 (W 0.216561) | 35.6769 ± 0.0546949 (W 0.0983964) | 30.0792 ± 0.0489832 (W 0.060699) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.07181 ± 0.00720551 (W 0.0188524) | 3.97288 ± 0.0641599 (W 0.14851) | 0.454004 ± 0.0101097 (W 0.00508672) | 🔵 fork 3.71× faster than `faer-upstream` | 🔴 fork 2.36× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 15.5482 ± 0.347006 (W 0.158349) | 76.4063 ± 0.629213 (W 0.540355) | 12.7228 ± 0.0482468 (W 0.0504495) | 🔵 fork 4.91× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.39045 ± 0.0144274 (W 0.0255078) | 2.8139 ± 0.0162879 (W 0.0157717) | 1.88788 ± 0.00856503 (W 0.00857021) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 47.1123 ± 0.11834 (W 0.201531) | 50.5369 ± 0.138305 (W 0.108233) | 48.8158 ± 2.22069 (W 0.130272) | 🔵 fork 1.07× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.65842 ± 0.0220234 (W 0.0246374) | 2.10258 ± 0.031939 (W 0.0221492) | 0.947982 ± 0.0127493 (W 0.00338227) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 31.4496 ± 0.208072 (W 0.167537) | 35.3749 ± 0.0777167 (W 0.166831) | 22.4992 ± 0.199272 (W 0.0791637) | 🔵 fork 1.12× faster than `faer-upstream` | 🔴 fork 1.40× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.814555 ± 0.00213401 (W 0.00395336) | 0.810598 ± 0.0020441 (W 0.00701156) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.9104 ± 0.132693 (W 0.107093) | 20.0027 ± 0.38259 (W 0.314272) | - | 🔵 fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.159617 ± 0.00594997 (W 0.00271968) | 0.137095 ± 0.00131687 (W 0.00126147) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.157152 ± 0.00564553 (W 0.00294419) | 0.137876 ± 0.00183134 (W 0.0018831) | - | 🔴 fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.50591 ± 0.0917243 (W 0.0857923) | 4.96655 ± 0.055895 (W 1.09966) | - | 🔴 fork 1.31× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.49816 ± 0.148977 (W 0.194352) | 5.02012 ± 0.0263815 (W 0.0403937) | - | 🔴 fork 1.29× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.477177 ± 0.00334844 (W 0.00513241) | 0.520638 ± 0.00828696 (W 0.0170305) | 0.597622 ± 0.164755 (W 0.00541499) | 🔵 fork 1.09× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.74702 ± 0.118839 (W 0.0501507) | 12.2129 ± 0.0215692 (W 0.0411093) | 4.23115 ± 1.79994 (W 0.0502038) | 🔵 fork 1.40× faster than `faer-upstream` | 🔴 fork 2.07× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.42173 ± 0.00267793 (W 0.0199175) | 2.02389 ± 0.0361455 (W 0.0206748) | 0.886699 ± 0.00444597 (W 0.00335353) | 🔵 fork 1.42× faster than `faer-upstream` | 🔴 fork 1.60× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.0562 ± 0.405932 (W 0.119449) | 35.6579 ± 0.143901 (W 0.423146) | 20.878 ± 0.127685 (W 0.055611) | 🔵 fork 1.62× faster than `faer-upstream` | 🔴 fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.13244 ± 0.00654741 (W 0.0171842) | 4.29642 ± 0.137781 (W 0.135577) | 0.323292 ± 0.0021821 (W 0.00308703) | 🔵 fork 3.79× faster than `faer-upstream` | 🔴 fork 3.50× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 12.9439 ± 0.066934 (W 0.131654) | 76.7048 ± 0.390026 (W 0.426594) | 7.29516 ± 0.0748585 (W 0.0354845) | 🔵 fork 5.93× faster than `faer-upstream` | 🔴 fork 1.77× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.5361 ± 0.0237458 (W 0.0261004) | 3.2026 ± 0.038475 (W 0.0227646) | 1.67677 ± 0.00394763 (W 0.00672316) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.7804 ± 0.0820108 (W 0.210334) | 50.6844 ± 0.20577 (W 0.426317) | 36.7255 ± 0.282409 (W 0.142755) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.7897 ± 0.00333245 (W 0.0298054) | 2.52452 ± 0.00826977 (W 0.0360512) | 0.811289 ± 0.00291586 (W 0.00239525) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 2.21× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 29.8303 ± 0.391879 (W 0.136697) | 37.2874 ± 0.574322 (W 0.238895) | 16.7669 ± 0.162558 (W 0.0842143) | 🔵 fork 1.25× faster than `faer-upstream` | 🔴 fork 1.78× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.73231 ± 0.000929502 (W 0.00235877) | 0.730249 ± 0.000663584 (W 0.00278195) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.3148 ± 0.274743 (W 0.0972304) | 46.3856 ± 0.858707 (W 0.417451) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.599022 ± 0.00430752 (W 0.00299436) | 0.606957 ± 0.00451169 (W 0.00295671) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.592361 ± 0.00200036 (W 0.0030003) | 0.593192 ± 0.00537204 (W 0.00322878) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.4089 ± 0.113343 (W 0.0251082) | 35.3579 ± 0.0195595 (W 0.0669131) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.4135 ± 0.168068 (W 0.0689475) | 35.4931 ± 0.213454 (W 0.0283706) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.385416 ± 0.00134306 (W 0.00239787) | 0.383129 ± 0.00176332 (W 0.00355558) | 0.287273 ± 0.000775928 (W 0.00222613) | · | 🔴 fork 1.34× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2284 ± 0.0049564 (W 0.0404248) | 13.2528 ± 0.0494882 (W 0.0352318) | 11.6312 ± 0.00207486 (W 0.027098) | · | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.4641 ± 0.00405606 (W 0.00383668) | 1.45728 ± 0.00185863 (W 0.00312522) | 1.58412 ± 0.00226429 (W 0.00302649) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 68.4558 ± 2.72815 (W 0.424679) | 68.4261 ± 2.49816 (W 0.162649) | 70.0195 ± 0.0679297 (W 0.10948) | · | · | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.772365 ± 0.00439993 (W 0.0026266) | 0.771436 ± 0.00204531 (W 0.00233151) | 0.766193 ± 0.00314961 (W 0.00351329) | · | · |  |
| `qr_factor/4096x256/b1` | 26.0041 ± 0.0592791 (W 0.0412896) | 26.0001 ± 0.0349384 (W 0.0422871) | 29.0937 ± 0.0540747 (W 0.0256799) | · | 🔵 fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.44537 ± 0.0120184 (W 0.00685434) | 2.45424 ± 0.00535931 (W 0.00927071) | 2.81926 ± 0.00719234 (W 0.0100065) | · | 🔵 fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 83.0716 ± 0.431981 (W 0.125424) | 83.1673 ± 0.330436 (W 0.135007) | 109.614 ± 0.919693 (W 0.238603) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.39502 ± 0.00151763 (W 0.00321929) | 1.39975 ± 0.00174895 (W 0.00149781) | 1.24034 ± 0.00263439 (W 0.00288339) | · | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 39.2351 ± 0.0439341 (W 0.0460818) | 39.2447 ± 0.00480041 (W 0.044608) | 40.6939 ± 0.185284 (W 0.0245824) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.733204 ± 0.00205801 (W 0.00398383) | 0.730588 ± 0.00782403 (W 0.00374419) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.6165 ± 0.0327324 (W 0.364708) | 17.5819 ± 0.138223 (W 0.116804) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.191889 ± 0.00766536 (W 0.00517803) | 0.18266 ± 0.014251 (W 0.00269809) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.197477 ± 0.00395353 (W 0.0041264) | 0.205993 ± 0.0144297 (W 0.00309689) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.2774 ± 0.0323745 (W 0.0194614) | 11.1948 ± 0.0377526 (W 0.0317981) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2441 ± 0.0549882 (W 0.0433555) | 11.1433 ± 0.0283898 (W 0.0208007) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.408395 ± 0.0121095 (W 0.0120004) | 0.431893 ± 0.00356359 (W 0.00466101) | 0.286442 ± 0.000245296 (W 0.0028921) | 🔵 fork 1.06× faster than `faer-upstream` | 🔴 fork 1.43× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 7.32495 ± 0.0273925 (W 0.0388516) | 7.39426 ± 0.0396805 (W 0.0469205) | 11.6073 ± 0.024657 (W 0.0289295) | · | 🔵 fork 1.58× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.20407 ± 0.0100304 (W 0.011167) | 1.65188 ± 0.0124123 (W 0.0177039) | 0.986815 ± 0.0095045 (W 0.00772145) | 🔵 fork 1.37× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.246 ± 0.168817 (W 0.17653) | 29.8627 ± 0.0276232 (W 0.207189) | 26.9069 ± 0.132913 (W 0.039031) | 🔵 fork 1.14× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.917896 ± 0.00887896 (W 0.00645047) | 1.36871 ± 0.00670941 (W 0.0172671) | 0.418888 ± 0.00174138 (W 0.00785092) | 🔵 fork 1.49× faster than `faer-upstream` | 🔴 fork 2.19× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.4753 ± 0.113119 (W 0.182223) | 17.784 ± 0.239571 (W 0.124179) | 11.2389 ± 0.0447349 (W 0.104562) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.33085 ± 0.0114087 (W 0.0148608) | 2.75773 ± 0.00896809 (W 0.0192164) | 1.82138 ± 0.0055473 (W 0.0050289) | 🔵 fork 1.18× faster than `faer-upstream` | 🔴 fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 41.34 ± 0.370135 (W 0.309248) | 45.0231 ± 0.138714 (W 0.215985) | 45.6778 ± 0.128413 (W 0.178826) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.57778 ± 0.0183684 (W 0.0214397) | 2.03778 ± 0.0081884 (W 0.0138384) | 0.906718 ± 0.00507887 (W 0.0112289) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.9138 ± 0.108357 (W 0.106244) | 29.789 ± 0.113895 (W 0.0791691) | 21.0504 ± 0.231629 (W 0.0985695) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.23× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731871 ± 0.00259748 (W 0.00291381) | 0.733053 ± 0.00257563 (W 0.00289122) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6755 ± 0.109383 (W 0.0965492) | 13.8299 ± 0.176522 (W 0.109371) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.156932 ± 0.00243548 (W 0.00280927) | 0.163404 ± 0.00302056 (W 0.00347723) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.16135 ± 0.00275633 (W 0.00439381) | 0.162692 ± 0.00415594 (W 0.00369025) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.72504 ± 0.00466706 (W 0.110505) | 6.54979 ± 0.0695713 (W 0.351442) | - | 🔴 fork 1.18× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.71911 ± 0.0947706 (W 0.13815) | 6.80912 ± 0.11417 (W 0.936146) | - | 🔴 fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.389319 ± 0.00391004 (W 0.00523962) | 0.454596 ± 0.00597539 (W 0.00701692) | 0.285782 ± 0.000937384 (W 0.00245005) | 🔵 fork 1.17× faster than `faer-upstream` | 🔴 fork 1.36× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.70183 ± 0.08381 (W 0.0662157) | 6.71482 ± 0.0238639 (W 0.0222538) | 3.16063 ± 0.0173964 (W 0.00837502) | · | 🔴 fork 2.12× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.33889 ± 0.00712899 (W 0.0155478) | 1.9689 ± 0.0449459 (W 0.0365277) | 0.848618 ± 0.000991792 (W 0.00352008) | 🔵 fork 1.47× faster than `faer-upstream` | 🔴 fork 1.58× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 19.9191 ± 0.181535 (W 0.103101) | 29.5125 ± 0.344261 (W 0.772584) | 19.2808 ± 0.0537247 (W 0.0407512) | 🔵 fork 1.48× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.03076 ± 0.00717506 (W 0.0157558) | 1.65753 ± 0.0183193 (W 0.0344418) | 0.300936 ± 0.000977788 (W 0.00229194) | 🔵 fork 1.61× faster than `faer-upstream` | 🔴 fork 3.43× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.8015 ± 0.0436515 (W 0.0942009) | 19.3899 ± 0.140658 (W 0.23815) | 6.49534 ± 0.0526248 (W 0.0413291) | 🔵 fork 1.64× faster than `faer-upstream` | 🔴 fork 1.82× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.49732 ± 0.0215858 (W 0.0226557) | 3.13728 ± 0.0254086 (W 0.0623027) | 1.63621 ± 0.00029552 (W 0.00247253) | 🔵 fork 1.26× faster than `faer-upstream` | 🔴 fork 1.53× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 35.1918 ± 0.0591344 (W 0.105185) | 44.781 ± 0.993646 (W 1.0958) | 34.4599 ± 0.14526 (W 0.0944625) | 🔵 fork 1.27× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.69129 ± 0.0106812 (W 0.0131089) | 2.41561 ± 0.00646579 (W 0.0287446) | 0.786653 ± 0.00169632 (W 0.0030487) | 🔵 fork 1.43× faster than `faer-upstream` | 🔴 fork 2.15× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.1616 ± 0.0991821 (W 0.0828105) | 31.89 ± 0.0530231 (W 0.583247) | 15.8665 ± 0.112744 (W 0.0494293) | 🔵 fork 1.32× faster than `faer-upstream` | 🔴 fork 1.52× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.81399 ± 0.00591508 (W 0.00341149) | 1.79772 ± 0.0245088 (W 0.00474772) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 149.141 ± 0.906407 (W 0.7305) | 158.298 ± 2.12512 (W 1.40128) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19674 ± 0.00439068 (W 0.00388597) | 2.2174 ± 0.0251993 (W 0.00519425) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20112 ± 0.00208012 (W 0.00265655) | 2.20278 ± 0.00123844 (W 0.00899773) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.948 ± 0.0889826 (W 0.148565) | 138.041 ± 0.153386 (W 0.0640823) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.912 ± 0.127494 (W 0.234305) | 138.028 ± 0.0719072 (W 0.354786) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.999373 ± 0.00077806 (W 0.00208376) | 1.0138 ± 0.00308574 (W 0.00169613) | 1.23299 ± 0.0218726 (W 0.00336963) | · | 🔵 fork 1.23× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 46.712 ± 0.250607 (W 0.164728) | 53.953 ± 0.0261209 (W 0.0544829) | 67.0305 ± 0.0754192 (W 0.151539) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.43× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.7329 ± 0.0207569 (W 0.0162) | 4.74265 ± 0.00228415 (W 0.00714332) | 5.11354 ± 0.0132483 (W 0.0132096) | · | 🔵 fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 249.888 ± 0.141661 (W 0.234871) | 255.631 ± 0.488687 (W 0.31702) | 238.405 ± 0.277996 (W 0.837069) | · | · |  |
| `qr_factor/1024x64/b1` | 2.4992 ± 0.0242329 (W 0.00682383) | 4.04844 ± 0.079355 (W 0.0105029) | 2.3981 ± 0.0251364 (W 0.00931194) | 🔵 fork 1.62× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 101.08 ± 0.0349777 (W 0.440543) | 176.355 ± 0.177866 (W 0.292707) | 110.617 ± 0.065225 (W 0.292475) | 🔵 fork 1.74× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 6.02563 ± 0.0152504 (W 0.00498753) | 6.02148 ± 0.0253648 (W 0.0174008) | 8.77136 ± 0.0240863 (W 0.0357952) | · | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 281.554 ± 0.592998 (W 0.953962) | 282.826 ± 1.38217 (W 0.628879) | 379.579 ± 0.543816 (W 0.773379) | · | 🔵 fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.0788 ± 0.0184815 (W 0.00497601) | 3.09049 ± 0.0123392 (W 0.00824466) | 3.82147 ± 0.0120553 (W 0.0152649) | · | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 122.951 ± 1.37817 (W 0.128505) | 123.15 ± 0.94989 (W 0.454932) | 144.901 ± 7.34609 (W 0.630184) | · | 🔵 fork 1.18× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.81224 ± 0.0122279 (W 0.00282549) | 1.80219 ± 0.0262199 (W 0.0082171) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 58.4196 ± 0.388667 (W 0.849514) | 64.9201 ± 0.842964 (W 1.0682) | - | 🔵 fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.649247 ± 0.318875 (W 0.0083633) | 0.583673 ± 0.0120438 (W 0.0028806) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.61864 ± 0.00707084 (W 0.0103689) | 0.585276 ± 0.00954161 (W 0.00200615) | - | 🔴 fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.2481 ± 0.232012 (W 0.169127) | 36.9028 ± 0.252791 (W 0.0817231) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.1949 ± 0.112304 (W 0.250418) | 37.0723 ± 0.141539 (W 0.0393634) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.826908 ± 0.00356615 (W 0.00956149) | 0.82787 ± 0.000323316 (W 0.0118082) | 1.09341 ± 0.00611588 (W 0.00165681) | · | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 22.6852 ± 0.20275 (W 0.206921) | 29.9288 ± 0.00820198 (W 0.077263) | 59.1445 ± 0.0658578 (W 0.458848) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 2.61× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.6698 ± 0.0291654 (W 0.0247402) | 3.04011 ± 0.014178 (W 0.0130234) | 3.11711 ± 0.0066682 (W 0.0299125) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.17× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 83.9841 ± 0.721484 (W 0.283271) | 98.771 ± 0.0923037 (W 0.228525) | 80.3896 ± 0.384284 (W 0.194155) | 🔵 fork 1.18× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.95988 ± 0.0753859 (W 0.0651658) | 4.41859 ± 0.133386 (W 0.0767593) | 1.39258 ± 0.00378467 (W 0.00342935) | 🔵 fork 2.25× faster than `faer-upstream` | 🔴 fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 40.6574 ± 0.247174 (W 0.081521) | 124.174 ± 0.121281 (W 0.374027) | 33.91 ± 0.149764 (W 0.149294) | 🔵 fork 3.05× faster than `faer-upstream` | 🔴 fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.07856 ± 0.0627723 (W 0.116599) | 4.41247 ± 0.0200293 (W 0.0212012) | 5.50481 ± 0.016924 (W 0.014618) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 115.814 ± 0.706602 (W 0.19353) | 123.636 ± 0.96558 (W 0.229635) | 139.676 ± 0.709134 (W 0.539498) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.65881 ± 0.0288882 (W 0.0535912) | 3.07436 ± 0.0105364 (W 0.0312449) | 2.80793 ± 0.024321 (W 0.0321336) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 69.0296 ± 0.997664 (W 0.887808) | 76.5126 ± 0.9236 (W 0.871581) | 51.3011 ± 0.280687 (W 0.368848) | 🔵 fork 1.11× faster than `faer-upstream` | 🔴 fork 1.35× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.80893 ± 0.00425359 (W 0.00245809) | 1.78962 ± 0.0116471 (W 0.00310274) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 35.4158 ± 0.257252 (W 0.358196) | 41.4253 ± 0.481822 (W 0.255532) | - | 🔵 fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.407628 ± 0.0102644 (W 0.00445148) | 0.415302 ± 0.00423379 (W 0.0020516) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.411666 ± 0.0104558 (W 0.00652606) | 0.413379 ± 0.00877724 (W 0.00153238) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.782 ± 0.109591 (W 0.606055) | 18.5514 ± 0.128391 (W 0.110963) | - | 🔴 fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.6182 ± 0.619823 (W 3.9848) | 18.7115 ± 0.117759 (W 0.115792) | - | 🔴 fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.809495 ± 0.00535729 (W 0.0142853) | 0.816418 ± 0.0312163 (W 0.00754965) | 1.08332 ± 0.000620633 (W 0.00149557) | · | 🔵 fork 1.34× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 19.1778 ± 0.14563 (W 0.226809) | 25.9907 ± 0.103071 (W 0.0929229) | 58.0116 ± 0.407314 (W 0.115368) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 3.02× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.4737 ± 0.0147515 (W 0.0188528) | 3.28189 ± 0.0626846 (W 0.0439355) | 2.32015 ± 0.00534402 (W 0.00492433) | 🔵 fork 1.33× faster than `faer-upstream` | 🔴 fork 1.07× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 67.7845 ± 5.97513 (W 0.319354) | 90.6265 ± 4.99448 (W 0.576146) | 45.916 ± 0.0518258 (W 0.27611) | 🔵 fork 1.34× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.8739 ± 0.0041528 (W 0.0154246) | 5.07248 ± 0.208055 (W 0.0370729) | 0.872434 ± 0.00530752 (W 0.00331426) | 🔵 fork 2.71× faster than `faer-upstream` | 🔴 fork 2.15× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 30.5536 ± 0.23562 (W 0.0688242) | 122.32 ± 0.926714 (W 0.898921) | 19.7429 ± 0.0642087 (W 0.0777476) | 🔵 fork 4.00× faster than `faer-upstream` | 🔴 fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.90403 ± 0.0146028 (W 0.0268993) | 4.70162 ± 0.0239498 (W 0.044647) | 4.47004 ± 0.0139255 (W 0.0103223) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.14× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 89.2409 ± 0.121536 (W 0.145497) | 109.911 ± 2.07386 (W 1.44934) | 82.9139 ± 0.486484 (W 0.934702) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.68843 ± 0.0266346 (W 0.0188969) | 3.45138 ± 0.0161978 (W 0.0291364) | 2.30818 ± 0.0146994 (W 0.00434663) | 🔵 fork 1.28× faster than `faer-upstream` | 🔴 fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 59.325 ± 0.144816 (W 0.184967) | 73.4303 ± 0.694199 (W 0.123051) | 34.323 ± 0.317164 (W 0.135607) | 🔵 fork 1.24× faster than `faer-upstream` | 🔴 fork 1.73× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.69988 ± 0.0032711 (W 0.00233394) | 1.67473 ± 0.00252478 (W 0.00553651) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 143.147 ± 1.23481 (W 0.909477) | 142.967 ± 1.09381 (W 0.64712) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.24728 ± 0.0185459 (W 0.00350972) | 2.25448 ± 0.0188565 (W 0.00511093) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26971 ± 0.0108927 (W 0.00561708) | 2.27107 ± 0.010457 (W 0.00606385) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.893 ± 0.277093 (W 0.367556) | 139.033 ± 0.312986 (W 0.365058) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.962 ± 0.20928 (W 0.365488) | 139.216 ± 0.217799 (W 0.138714) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.876469 ± 0.00410217 (W 0.00175645) | 0.888651 ± 0.00492927 (W 0.00211769) | 1.0689 ± 0.0121886 (W 0.0024605) | · | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 41.5459 ± 0.148181 (W 0.11482) | 41.849 ± 0.094089 (W 0.043635) | 49.7785 ± 0.0528653 (W 0.13937) | · | 🔵 fork 1.20× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.60547 ± 0.0141724 (W 0.00382561) | 4.61407 ± 0.00393845 (W 0.0138956) | 4.85053 ± 0.0385157 (W 0.0110924) | · | 🔵 fork 1.05× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 243.719 ± 0.332628 (W 0.423715) | 244.168 ± 0.510721 (W 0.153743) | 215.066 ± 0.0492337 (W 0.569882) | · | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.2114 ± 0.0302884 (W 0.00855628) | 2.22661 ± 0.0383075 (W 0.00321918) | 2.24824 ± 0.0097065 (W 0.00413174) | · | · |  |
| `qr_factor/4096x256/b1` | 89.1146 ± 0.1579 (W 0.103967) | 89.3467 ± 0.109392 (W 0.161119) | 103.383 ± 0.19771 (W 0.419397) | · | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.93007 ± 0.0321959 (W 0.00996464) | 5.89539 ± 0.0291429 (W 0.0161167) | 8.42111 ± 0.0863066 (W 0.0158063) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 269.116 ± 0.673257 (W 0.212218) | 269.96 ± 0.585731 (W 0.47472) | 370.313 ± 0.236589 (W 0.826228) | · | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.95166 ± 0.0198217 (W 0.00817322) | 2.95516 ± 0.0201858 (W 0.00250407) | 3.68698 ± 0.041726 (W 0.0133544) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 110.818 ± 0.168006 (W 0.199904) | 111.111 ± 0.15754 (W 0.0716795) | 138.404 ± 0.305366 (W 0.772189) | · | 🔵 fork 1.25× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.69539 ± 0.00485786 (W 0.00304797) | 1.66177 ± 0.00228549 (W 0.00500305) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 53.4904 ± 0.266345 (W 0.87062) | 52.5133 ± 0.144462 (W 0.647417) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.639159 ± 0.00176878 (W 0.00956309) | 0.63008 ± 0.000901358 (W 0.00355187) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.65114 ± 0.0151275 (W 0.0102879) | 0.632977 ± 0.0214333 (W 0.00241078) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.0611 ± 0.168353 (W 0.0848024) | 39.7232 ± 0.118818 (W 0.0618932) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.2897 ± 0.0346877 (W 0.0565129) | 39.7991 ± 0.106778 (W 0.0671634) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.710741 ± 0.00767212 (W 0.0155589) | 0.72079 ± 0.0086481 (W 0.0139831) | 1.06705 ± 0.00758471 (W 0.00123501) | · | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.2961 ± 0.0835296 (W 0.0508588) | 17.6327 ± 0.0560769 (W 0.0774849) | 49.9134 ± 0.422315 (W 0.135914) | · | 🔵 fork 2.89× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.56256 ± 0.0878717 (W 0.0496609) | 2.95303 ± 0.0315307 (W 0.0178631) | 3.13787 ± 0.00192656 (W 0.0509881) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 78.6277 ± 0.162881 (W 0.141523) | 86.5317 ± 0.105371 (W 0.284912) | 75.2731 ± 0.565036 (W 0.324728) | 🔵 fork 1.10× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.76899 ± 0.0865758 (W 0.0134979) | 2.1823 ± 0.00823339 (W 0.0166778) | 1.34721 ± 0.0011565 (W 0.00239634) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.31× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 35.865 ± 0.0767376 (W 0.232464) | 44.195 ± 0.146562 (W 0.109644) | 31.3399 ± 0.24814 (W 0.0842001) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.14× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.91873 ± 0.0376672 (W 0.114032) | 4.28486 ± 0.0168932 (W 0.0355339) | 5.39049 ± 0.00612112 (W 0.00789553) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 103.923 ± 0.166889 (W 0.301508) | 111.355 ± 0.277729 (W 0.131965) | 130.381 ± 1.59458 (W 0.431637) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.61045 ± 0.0771402 (W 0.0989892) | 2.98561 ± 0.0172621 (W 0.027686) | 2.78083 ± 0.0182735 (W 0.00268069) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 55.5129 ± 0.101641 (W 0.151667) | 63.8941 ± 0.143441 (W 0.164185) | 48.966 ± 0.53275 (W 0.340565) | 🔵 fork 1.15× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.69412 ± 0.00687529 (W 0.00268149) | 1.66131 ± 0.0101673 (W 0.00428887) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 29.508 ± 0.696182 (W 0.254828) | 29.0796 ± 0.323221 (W 0.311672) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.421314 ± 0.00786978 (W 0.00408371) | 0.44649 ± 0.00365117 (W 0.00435646) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.425311 ± 0.0106435 (W 0.00369014) | 0.464173 ± 0.0137693 (W 0.00255552) | - | 🔵 fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.4782 ± 0.27051 (W 3.37923) | 21.4624 ± 0.201871 (W 0.253444) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.7585 ± 0.358744 (W 0.288072) | 21.3649 ± 0.0818737 (W 3.15118) | - | 🔴 fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.702686 ± 0.00995486 (W 0.00737993) | 0.701325 ± 0.0127846 (W 0.0114244) | 1.06183 ± 0.0128506 (W 0.00321661) | · | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.5193 ± 0.0326317 (W 0.0526507) | 13.7361 ± 0.0235491 (W 0.0537195) | 49.6251 ± 0.616354 (W 0.100147) | · | 🔵 fork 3.67× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.34262 ± 0.0106187 (W 0.0206437) | 3.19973 ± 0.0156926 (W 0.0216628) | 2.27286 ± 0.0196467 (W 0.00441697) | 🔵 fork 1.37× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 62.3643 ± 5.91623 (W 0.212496) | 78.988 ± 5.37669 (W 0.340532) | 42.2642 ± 0.0994277 (W 0.16268) | 🔵 fork 1.27× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.72961 ± 0.0127908 (W 0.0186683) | 2.49644 ± 0.0219939 (W 0.0246501) | 0.853858 ± 0.00101157 (W 0.00258841) | 🔵 fork 1.44× faster than `faer-upstream` | 🔴 fork 2.03× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.6085 ± 0.12828 (W 0.0493648) | 41.7788 ± 0.273224 (W 0.103535) | 17.6805 ± 0.0663241 (W 0.123896) | 🔵 fork 1.51× faster than `faer-upstream` | 🔴 fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.74467 ± 0.0238806 (W 0.0209022) | 4.55387 ± 0.027723 (W 0.0338206) | 4.42876 ± 0.0260631 (W 0.0707371) | 🔵 fork 1.22× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 76.7504 ± 0.137597 (W 0.200507) | 94.1986 ± 0.338344 (W 1.4191) | 73.7383 ± 0.307537 (W 0.493514) | 🔵 fork 1.23× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.57257 ± 0.00573319 (W 0.021192) | 3.30712 ± 0.0199644 (W 0.0247256) | 2.29472 ± 0.0129742 (W 0.00373749) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 47.8087 ± 0.136656 (W 0.109088) | 61.7995 ± 0.249851 (W 0.193585) | 32.3057 ± 0.0921998 (W 0.16069) | 🔵 fork 1.29× faster than `faer-upstream` | 🔴 fork 1.48× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 76.0097 ± 1.3024 (W 0.127385) | 79.7438 ± 1.96992 (W 0.31551) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.12367 ± 0.0053276 (W 0.0042712) | 1.25906 ± 0.0213551 (W 0.00384677) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 15.8878 ± 0.0814364 (W 0.0409271) | 18.1147 ± 0.0540381 (W 0.0599561) | 76.6613 ± 0.175982 (W 1.52558) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 4.83× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.395065 ± 0.007911 (W 0.0025652) | 0.511641 ± 0.00145162 (W 0.00364417) | 0.924398 ± 0.13423 (W 0.00452209) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 2.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 30.9033 ± 0.557324 (W 0.465752) | 32.3179 ± 0.166308 (W 0.0630809) | 66.4784 ± 0.713147 (W 1.86798) | · | 🔵 fork 2.15× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.742482 ± 0.001927 (W 0.00186518) | 0.843154 ± 0.0142816 (W 0.00329388) | 1.52339 ± 0.0106153 (W 0.00942463) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 2.05× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 27.512 ± 0.137367 (W 0.17365) | 27.6784 ± 0.266665 (W 0.112233) | 58.6645 ± 0.504624 (W 1.0202) | · | 🔵 fork 2.13× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.994646 ± 0.00422651 (W 0.00386983) | 1.01116 ± 0.00253487 (W 0.00676985) | 1.34303 ± 0.00346212 (W 0.00187109) | · | 🔵 fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 83.215 ± 0.266913 (W 0.23016) | 82.9264 ± 0.186297 (W 0.0933517) | 241.638 ± 6.66171 (W 2.13238) | · | 🔵 fork 2.90× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.44704 ± 0.00634056 (W 0.00452368) | 2.4475 ± 0.00253809 (W 0.00312329) | 4.14006 ± 0.0219559 (W 0.00771713) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 39.0077 ± 0.0775832 (W 0.0479505) | 39.0489 ± 0.0619383 (W 0.0521526) | 173.633 ± 4.77819 (W 0.42064) | · | 🔵 fork 4.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.40385 ± 0.0011596 (W 0.00277046) | 1.40851 ± 0.00431734 (W 0.00297087) | 2.63989 ± 0.0435329 (W 0.0060318) | · | 🔵 fork 1.88× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 37.5854 ± 0.159358 (W 0.284709) | 39.8728 ± 0.210484 (W 0.16168) | - | 🔵 fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.11568 ± 0.0126235 (W 0.00507891) | 1.24401 ± 0.0506147 (W 0.00401442) | - | 🔵 fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/256x4096/b1` | 7.18675 ± 0.0512535 (W 0.0592325) | 9.3944 ± 2.41739 (W 0.0372409) | 10.1287 ± 0.106796 (W 0.0892168) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.229237 ± 0.00147257 (W 0.00433585) | 0.370124 ± 0.011325 (W 0.0161959) | 0.300567 ± 0.00925217 (W 0.00328985) | 🔵 fork 1.61× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 11.1993 ± 0.0936858 (W 0.196268) | 14.3188 ± 0.176619 (W 0.0779571) | 16.8884 ± 0.0361206 (W 0.157871) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 1.51× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.44452 ± 0.00306612 (W 0.00801882) | 0.786223 ± 0.00366041 (W 0.0137766) | 0.610366 ± 0.0138449 (W 0.0127163) | 🔵 fork 1.77× faster than `faer-upstream` | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 10.4754 ± 0.0752119 (W 0.0736969) | 12.609 ± 0.0497562 (W 0.0817552) | 13.3829 ± 0.0112394 (W 0.0215667) | 🔵 fork 1.20× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.666951 ± 0.044822 (W 0.0096473) | 0.939668 ± 0.00444897 (W 0.00752999) | 0.429152 ± 0.0013566 (W 0.00154529) | 🔵 fork 1.41× faster than `faer-upstream` | 🔴 fork 1.55× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 41.5324 ± 0.091328 (W 0.166218) | 44.8374 ± 0.0664459 (W 0.16086) | 121.952 ± 0.194036 (W 0.580256) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.94× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.33464 ± 0.017131 (W 0.0178668) | 2.75254 ± 0.0223623 (W 0.0140997) | 3.03414 ± 0.0152079 (W 0.013891) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.30× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 25.7927 ± 0.169772 (W 0.177818) | 29.8295 ± 0.0729011 (W 0.132631) | 90.2372 ± 0.132298 (W 0.234299) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 3.50× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.58919 ± 0.0236818 (W 0.0272021) | 2.07411 ± 0.015744 (W 0.0288817) | 2.09286 ± 0.00955183 (W 0.00495913) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 32.818 ± 0.16052 (W 0.101227) | 35.3388 ± 0.295558 (W 0.163014) | - | 🔵 fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.10314 ± 0.020627 (W 0.00218925) | 1.24843 ± 0.0088953 (W 0.00340039) | - | 🔵 fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.88937 ± 0.234659 (W 0.123859) | 7.97353 ± 0.120247 (W 0.0476207) | 6.74105 ± 1.54312 (W 0.04735) | 🔵 fork 1.35× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.208782 ± 0.000959547 (W 0.00345311) | 0.359389 ± 0.0263341 (W 0.0282048) | 0.170843 ± 0.000511086 (W 0.00237444) | 🔵 fork 1.72× faster than `faer-upstream` | 🔴 fork 1.22× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 8.23261 ± 0.0670062 (W 0.12707) | 13.429 ± 0.056265 (W 0.216982) | 10.3054 ± 0.0625764 (W 0.10294) | 🔵 fork 1.63× faster than `faer-upstream` | 🔵 fork 1.25× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.394103 ± 0.00787873 (W 0.011968) | 0.921988 ± 0.0083837 (W 0.0248328) | 0.451621 ± 0.0122088 (W 0.0136504) | 🔵 fork 2.34× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 7.88385 ± 0.00791729 (W 0.095137) | 11.8905 ± 0.127259 (W 0.503528) | 6.99041 ± 0.00454157 (W 0.0170135) | 🔵 fork 1.51× faster than `faer-upstream` | 🔴 fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.615505 ± 0.00477543 (W 0.00547749) | 1.10289 ± 0.00142077 (W 0.028775) | 0.255988 ± 0.000656546 (W 0.00115344) | 🔵 fork 1.79× faster than `faer-upstream` | 🔴 fork 2.40× slower than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 35.2509 ± 0.0666237 (W 0.117522) | 45.1931 ± 0.827142 (W 6.26724) | 101.022 ± 0.623236 (W 0.529032) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 2.87× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.47744 ± 0.0104647 (W 0.011823) | 3.11962 ± 0.0184005 (W 0.0224258) | 2.92356 ± 0.0090723 (W 0.00977787) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 24.1734 ± 0.0703275 (W 0.0835791) | 31.854 ± 0.088695 (W 0.230231) | 77.993 ± 0.327017 (W 0.346314) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 3.23× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.69635 ± 0.0208884 (W 0.020853) | 2.44971 ± 0.0123129 (W 0.0340334) | 2.07523 ± 0.0052523 (W 0.00635353) | 🔵 fork 1.44× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 73.1251 ± 1.5321 (W 0.1419) | 74.0718 ± 1.1804 (W 0.184832) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04413 ± 0.0150201 (W 0.00339624) | 1.05774 ± 0.00434402 (W 0.00450074) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.2692 ± 0.0254747 (W 0.0451341) | 13.2617 ± 0.00585099 (W 0.0314111) | 210.361 ± 0.247386 (W 0.148384) | · | 🔵 fork 15.85× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.311339 ± 0.00188017 (W 0.00198977) | 0.311009 ± 0.00114424 (W 0.00231389) | 3.1322 ± 0.00486662 (W 0.00726528) | · | 🔵 fork 10.06× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 27.8307 ± 0.203807 (W 0.136279) | 27.8711 ± 0.0794575 (W 0.117104) | 66.1528 ± 0.759183 (W 0.285111) | · | 🔵 fork 2.38× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.630473 ± 0.00411068 (W 0.00277218) | 0.627003 ± 0.00362429 (W 0.00228816) | 1.42795 ± 0.00657972 (W 0.00322549) | · | 🔵 fork 2.26× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 25.4104 ± 0.627546 (W 0.27259) | 25.5782 ± 0.106654 (W 0.440978) | 52.9602 ± 0.568166 (W 0.13933) | · | 🔵 fork 2.08× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.563057 ± 0.00413316 (W 0.00265343) | 0.562908 ± 0.00544916 (W 0.00244671) | 6.3003 ± 0.00187066 (W 0.00744677) | · | 🔵 fork 11.19× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 88.701 ± 0.172343 (W 0.190606) | 88.3769 ± 0.0779889 (W 0.128492) | 228.528 ± 0.473155 (W 0.445574) | · | 🔵 fork 2.58× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.50731 ± 0.00406858 (W 0.0053279) | 2.51354 ± 0.00344502 (W 0.0064528) | 3.92818 ± 0.037753 (W 0.0126035) | · | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 44.8848 ± 0.0663525 (W 0.058978) | 44.821 ± 0.0570812 (W 0.0548685) | 167.677 ± 1.62403 (W 0.659908) | · | 🔵 fork 3.74× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.46667 ± 0.0016538 (W 0.00508915) | 1.46568 ± 0.0106912 (W 0.00606097) | 2.48531 ± 0.0151363 (W 0.00638155) | · | 🔵 fork 1.69× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.0265 ± 0.0654554 (W 0.279093) | 34.879 ± 0.327784 (W 0.18656) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04622 ± 0.00503228 (W 0.00326054) | 1.04113 ± 0.00283683 (W 0.00370966) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.3772 ± 0.0278011 (W 0.0465294) | 4.67551 ± 0.0114617 (W 0.0691188) | 5.32822 ± 0.0244879 (W 0.0156347) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.136895 ± 0.000589047 (W 0.00190183) | 0.172394 ± 0.0021591 (W 0.00638425) | 0.242431 ± 0.00675078 (W 0.00422185) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 1.77× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 8.25388 ± 0.0161823 (W 0.0963577) | 9.59492 ± 0.124823 (W 0.0859288) | 26.5909 ± 0.0369386 (W 0.0859731) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 3.22× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.325575 ± 0.0130077 (W 0.0101059) | 0.578326 ± 0.00486896 (W 0.00798211) | 0.614023 ± 0.00311821 (W 0.00235007) | 🔵 fork 1.78× faster than `faer-upstream` | 🔵 fork 1.89× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 7.25491 ± 0.0640247 (W 0.0390434) | 8.54489 ± 0.0879554 (W 0.040276) | 11.3257 ± 0.0213939 (W 0.0293745) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.56× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.254032 ± 0.00283357 (W 0.0130211) | 0.505832 ± 0.00126405 (W 0.0074665) | 0.369677 ± 0.00452526 (W 0.00325563) | 🔵 fork 1.99× faster than `faer-upstream` | 🔵 fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 47.1605 ± 0.156243 (W 0.162945) | 50.7504 ± 0.131776 (W 0.135126) | 114.302 ± 2.98435 (W 0.727641) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 2.42× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.38186 ± 0.0181019 (W 0.0165067) | 2.83922 ± 0.0218059 (W 0.0303286) | 2.95396 ± 0.024187 (W 0.017811) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 31.2714 ± 0.160498 (W 0.234131) | 35.4113 ± 0.067695 (W 0.0900588) | 92.0303 ± 0.702542 (W 0.296768) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 2.94× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.64329 ± 0.00478605 (W 0.0140867) | 2.13358 ± 0.0118904 (W 0.0208575) | 2.03362 ± 0.0193387 (W 0.00867472) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.24× faster than `lapack-mkl` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.5924 ± 0.162342 (W 0.192513) | 30.5772 ± 0.127541 (W 0.281547) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.04373 ± 0.0112079 (W 0.00256639) | 1.05481 ± 0.00338624 (W 0.00477887) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.89516 ± 0.0231222 (W 0.0230848) | 3.30147 ± 0.00602797 (W 0.0937031) | 3.15457 ± 0.0108346 (W 0.00826977) | 🔵 fork 1.14× faster than `faer-upstream` | 🔵 fork 1.09× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.116092 ± 0.00119615 (W 0.00182012) | 0.155309 ± 0.00618354 (W 0.00488232) | 0.13154 ± 0.00117842 (W 0.0014894) | 🔵 fork 1.34× faster than `faer-upstream` | 🔵 fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 5.07401 ± 0.0321808 (W 0.0522926) | 8.41886 ± 0.182035 (W 0.294743) | 18.9273 ± 0.0549316 (W 0.0664559) | 🔵 fork 1.66× faster than `faer-upstream` | 🔵 fork 3.73× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.27295 ± 0.00175358 (W 0.00285216) | 0.739186 ± 0.00839205 (W 0.0192843) | 0.477203 ± 0.00208539 (W 0.00468401) | 🔵 fork 2.71× faster than `faer-upstream` | 🔵 fork 1.75× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 4.25261 ± 0.0245891 (W 0.0331087) | 7.36551 ± 0.0348071 (W 0.141999) | 5.88269 ± 0.0255745 (W 0.0085721) | 🔵 fork 1.73× faster than `faer-upstream` | 🔵 fork 1.38× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.19332 ± 0.00117494 (W 0.00220078) | 0.673693 ± 0.0224786 (W 0.0200501) | 0.216974 ± 0.00159473 (W 0.00175359) | 🔵 fork 3.48× faster than `faer-upstream` | 🔵 fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 40.747 ± 0.0490094 (W 0.149724) | 50.8645 ± 0.431184 (W 5.4001) | 98.1519 ± 0.627992 (W 0.685119) | 🔵 fork 1.25× faster than `faer-upstream` | 🔵 fork 2.41× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 2.54086 ± 0.0246353 (W 0.0216133) | 3.19767 ± 0.00912631 (W 0.0305413) | 2.81387 ± 0.0368502 (W 0.0236951) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 29.8953 ± 0.041549 (W 0.124919) | 37.5353 ± 0.113109 (W 0.223548) | 75.7611 ± 0.791363 (W 0.279155) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 2.53× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 1.7646 ± 0.00984062 (W 0.0262392) | 2.4793 ± 0.00818581 (W 0.0165891) | 2.03597 ± 0.0163378 (W 0.00639982) | 🔵 fork 1.41× faster than `faer-upstream` | 🔵 fork 1.15× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 232.123 ± 6.64938 (W 2.09812) | 232.623 ± 6.0014 (W 1.62213) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.3764 ± 0.046106 (W 0.0179111) | 2.46164 ± 0.0468233 (W 0.015168) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.0688 ± 0.0332541 (W 0.0289785) | 46.461 ± 0.2622 (W 0.150216) | 88.3636 ± 0.273001 (W 0.273653) | · | 🔵 fork 1.92× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 1.00442 ± 0.0026729 (W 0.00235845) | 1.05248 ± 0.0303443 (W 0.00404642) | 2.28833 ± 0.0344356 (W 0.00340832) | · | 🔵 fork 2.28× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 107.281 ± 0.28362 (W 0.496984) | 108.097 ± 0.277691 (W 0.240801) | 176.636 ± 0.419847 (W 1.10403) | · | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 2.53029 ± 0.00621068 (W 0.00556783) | 2.64118 ± 0.00508758 (W 0.00489484) | 3.85788 ± 0.0401117 (W 0.0122259) | · | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 96.5949 ± 0.100593 (W 0.175984) | 97.4635 ± 0.4415 (W 0.320532) | 156.203 ± 0.994514 (W 0.509244) | · | 🔵 fork 1.62× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 2.58534 ± 0.0280239 (W 0.00801287) | 2.60218 ± 0.0050256 (W 0.00545491) | 3.55225 ± 0.0214571 (W 0.00479179) | · | 🔵 fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 269.992 ± 0.347447 (W 3.03027) | 270.344 ± 0.280775 (W 0.346104) | 546.42 ± 4.51647 (W 1.48081) | · | 🔵 fork 2.02× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 5.91646 ± 0.0226338 (W 0.0089904) | 5.92059 ± 0.0206787 (W 0.0119022) | 12.0797 ± 0.0372489 (W 0.0475025) | · | 🔵 fork 2.04× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 110.819 ± 0.0259582 (W 0.0756664) | 110.962 ± 0.0752521 (W 0.0603534) | 204.686 ± 6.55844 (W 1.13947) | · | 🔵 fork 1.85× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.94977 ± 0.020918 (W 0.00281659) | 2.94541 ± 0.0112238 (W 0.00996242) | 5.56926 ± 0.107154 (W 0.0131126) | · | 🔵 fork 1.89× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 96.9672 ± 0.576294 (W 0.560644) | 97.0402 ± 0.508868 (W 0.254479) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.40531 ± 0.0149257 (W 0.0120659) | 2.46242 ± 0.0423637 (W 0.0119155) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 18.3569 ± 0.125375 (W 0.0736121) | 18.1603 ± 0.106443 (W 0.0831088) | 29.3067 ± 0.0607059 (W 0.200093) | · | 🔵 fork 1.60× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.429433 ± 0.00268917 (W 0.00268853) | 0.494252 ± 0.00241775 (W 0.00398301) | 0.643664 ± 0.00401193 (W 0.00476276) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.50× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 33.4444 ± 0.0192684 (W 0.136819) | 35.007 ± 0.331658 (W 0.131022) | 45.4571 ± 0.0484488 (W 0.0673824) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.974499 ± 0.00951831 (W 0.0039164) | 1.32477 ± 0.052696 (W 0.0119827) | 1.65587 ± 0.00350609 (W 0.00494968) | 🔵 fork 1.36× faster than `faer-upstream` | 🔵 fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 28.1447 ± 0.0843563 (W 0.0707355) | 30.4681 ± 0.02758 (W 0.427465) | 39.2521 ± 0.01942 (W 0.0505915) | 🔵 fork 1.08× faster than `faer-upstream` | 🔵 fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 1.03403 ± 0.00669746 (W 0.00630407) | 1.35542 ± 0.00931554 (W 0.018639) | 1.35528 ± 0.0025797 (W 0.00398639) | 🔵 fork 1.31× faster than `faer-upstream` | 🔵 fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 104.433 ± 0.223475 (W 0.170233) | 112.157 ± 0.113204 (W 0.172508) | 191.03 ± 0.478028 (W 0.717562) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.83× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 3.99684 ± 0.0829656 (W 0.110373) | 4.33658 ± 0.0286399 (W 0.0313527) | 7.34508 ± 0.058594 (W 0.0144152) | 🔵 fork 1.09× faster than `faer-upstream` | 🔵 fork 1.84× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 55.6531 ± 0.0753385 (W 0.140502) | 63.9049 ± 0.0806455 (W 0.125035) | 84.8232 ± 0.106307 (W 0.0998755) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.56352 ± 0.0197806 (W 0.0320886) | 2.98522 ± 0.0190515 (W 0.0289456) | 3.70615 ± 0.0470519 (W 0.00897008) | 🔵 fork 1.16× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 69.4558 ± 2.44847 (W 0.36996) | 70.4775 ± 1.09596 (W 0.513832) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.40835 ± 0.0138655 (W 0.0091608) | 2.51824 ± 0.00408208 (W 0.0114645) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 12.7737 ± 0.0363666 (W 0.0963235) | 12.4989 ± 0.179816 (W 0.0612213) | 18.4504 ± 2.87077 (W 0.0767986) | · | 🔵 fork 1.44× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/64x1024/b1` | 0.350141 ± 0.00313544 (W 0.00467533) | 0.40315 ± 0.00323523 (W 0.00574334) | 0.448975 ± 0.00318137 (W 0.00232512) | 🔵 fork 1.15× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 21.0849 ± 0.0805868 (W 0.0800923) | 24.9251 ± 0.236237 (W 1.06507) | 26.4911 ± 0.1481 (W 0.10553) | 🔵 fork 1.18× faster than `faer-upstream` | 🔵 fork 1.26× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.738263 ± 0.0023625 (W 0.00651225) | 1.41403 ± 0.0179114 (W 0.0266677) | 1.05078 ± 0.0171394 (W 0.00202734) | 🔵 fork 1.92× faster than `faer-upstream` | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `qr_factor/256x4096/b1` | 17.1178 ± 0.077911 (W 0.122129) | 22.2089 ± 0.700737 (W 1.50374) | 21.0981 ± 0.0383667 (W 0.0274852) | 🔵 fork 1.30× faster than `faer-upstream` | 🔵 fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.784539 ± 0.00624123 (W 0.00434262) | 1.42543 ± 0.0293034 (W 0.0210723) | 0.76276 ± 0.00179069 (W 0.00274916) | 🔵 fork 1.82× faster than `faer-upstream` | · |  |
| `svd_thin/256x4096/b1` | 77.6326 ± 0.106816 (W 0.231081) | 95.3568 ± 0.695557 (W 1.39197) | 112.823 ± 2.26688 (W 0.405608) | 🔵 fork 1.23× faster than `faer-upstream` | 🔵 fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 3.79048 ± 0.00682039 (W 0.0271757) | 4.60042 ± 0.00691169 (W 0.0365634) | 6.24498 ± 0.0342661 (W 0.0174063) | 🔵 fork 1.21× faster than `faer-upstream` | 🔵 fork 1.65× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 47.8766 ± 0.102292 (W 0.150353) | 61.8118 ± 0.195662 (W 0.178611) | 55.772 ± 0.0457749 (W 0.163913) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 1.16× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.55768 ± 0.0118409 (W 0.0311273) | 3.29935 ± 0.0293774 (W 0.0347583) | 3.2864 ± 0.0390877 (W 0.0184086) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 1.28× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 228.879 ± 6.68529 (W 0.897483) | 228.121 ± 6.64606 (W 0.4403) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.28451 ± 0.0365516 (W 0.0119775) | 2.26805 ± 0.055059 (W 0.0153529) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 41.9619 ± 0.0736144 (W 0.0338668) | 41.9766 ± 0.0448288 (W 0.0475734) | 72.9348 ± 0.111883 (W 0.0746858) | · | 🔵 fork 1.74× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.896137 ± 0.00128696 (W 0.00185603) | 0.899844 ± 0.0062724 (W 0.00483186) | 2.12021 ± 0.00809606 (W 0.0051558) | · | 🔵 fork 2.37× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 103.165 ± 0.259067 (W 0.388281) | 103.206 ± 0.141135 (W 0.43877) | 189.563 ± 4.32767 (W 0.959749) | · | 🔵 fork 1.84× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 2.42162 ± 0.00840515 (W 0.00327816) | 2.41126 ± 0.00362956 (W 0.00352496) | 3.92205 ± 0.244967 (W 0.0234115) | · | 🔵 fork 1.62× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 96.324 ± 0.5317 (W 0.391644) | 96.4201 ± 0.778416 (W 0.298969) | 149.488 ± 5.75823 (W 0.320661) | · | 🔵 fork 1.55× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 2.22565 ± 0.0141469 (W 0.0027601) | 2.22622 ± 0.00206364 (W 0.00275522) | 16.877 ± 0.0166406 (W 0.0165498) | · | 🔵 fork 7.58× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 282.187 ± 0.264413 (W 0.452503) | 282.726 ± 0.211506 (W 0.381959) | 535.797 ± 6.24607 (W 1.80987) | · | 🔵 fork 1.90× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 6.0462 ± 0.00620817 (W 0.00560962) | 6.04249 ± 0.0418475 (W 0.0201601) | 11.7673 ± 0.067584 (W 0.0459908) | · | 🔵 fork 1.95× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 123.194 ± 0.324317 (W 0.0584357) | 123.228 ± 0.987542 (W 0.294281) | 191.246 ± 3.01258 (W 1.46496) | · | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 3.07934 ± 0.023936 (W 0.00427123) | 3.07391 ± 0.0129731 (W 0.00258345) | 5.29641 ± 0.028411 (W 0.0138076) | · | 🔵 fork 1.72× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 92.3262 ± 0.475095 (W 0.583627) | 92.2291 ± 0.491446 (W 0.386805) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.26936 ± 0.0452714 (W 0.00754036) | 2.24145 ± 0.0478083 (W 0.00967925) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.8342 ± 0.0538065 (W 0.0523089) | 13.8241 ± 0.0649685 (W 0.047825) | 20.5571 ± 0.0699914 (W 0.0201021) | · | 🔵 fork 1.49× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.321407 ± 0.00334272 (W 0.00991875) | 0.323512 ± 0.000478891 (W 0.00244211) | 0.595899 ± 0.00460432 (W 0.00552218) | · | 🔵 fork 1.85× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 28.977 ± 0.0489141 (W 0.112224) | 30.5325 ± 0.293885 (W 0.139096) | 60.5991 ± 3.26559 (W 0.162111) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 2.09× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.877272 ± 0.0139468 (W 0.0233511) | 1.15569 ± 0.0074578 (W 0.0124625) | 1.67606 ± 0.0818793 (W 0.0131386) | 🔵 fork 1.32× faster than `faer-upstream` | 🔵 fork 1.91× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 25.9567 ± 0.0503339 (W 0.156291) | 27.319 ± 0.132526 (W 0.349658) | 36.3387 ± 0.0642843 (W 0.0262827) | 🔵 fork 1.05× faster than `faer-upstream` | 🔵 fork 1.40× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.724018 ± 0.019652 (W 0.00533061) | 0.978296 ± 0.00929093 (W 0.0122596) | 1.2848 ± 0.00162805 (W 0.00508129) | 🔵 fork 1.35× faster than `faer-upstream` | 🔵 fork 1.77× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 116.712 ± 0.221767 (W 0.346189) | 124.273 ± 0.0696537 (W 1.96603) | 180.882 ± 0.909198 (W 0.638129) | 🔵 fork 1.06× faster than `faer-upstream` | 🔵 fork 1.55× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 4.13061 ± 0.0488981 (W 0.0855419) | 4.4326 ± 0.028767 (W 0.0199049) | 7.28254 ± 0.0417667 (W 0.0181634) | 🔵 fork 1.07× faster than `faer-upstream` | 🔵 fork 1.76× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 67.5078 ± 0.0793364 (W 0.335098) | 75.7541 ± 0.0228662 (W 0.065151) | 82.0942 ± 0.312634 (W 0.089974) | 🔵 fork 1.12× faster than `faer-upstream` | 🔵 fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.71018 ± 0.0644712 (W 0.0748333) | 3.05776 ± 0.0395008 (W 0.028015) | 3.63461 ± 0.0185359 (W 0.0121776) | 🔵 fork 1.13× faster than `faer-upstream` | 🔵 fork 1.34× faster than `lapack-mkl` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 64.9752 ± 1.73337 (W 0.498467) | 64.3678 ± 2.85515 (W 0.553778) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.29553 ± 0.0192275 (W 0.00648099) | 2.26928 ± 0.0239033 (W 0.0090259) | - | · | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 8.3071 ± 0.0348391 (W 0.0458289) | 8.33549 ± 0.00216461 (W 0.037647) | 11.2715 ± 0.0241582 (W 0.0274472) | · | 🔵 fork 1.36× faster than `lapack-mkl` |  |
| `lu/64x1024/b1` | 0.239028 ± 0.00431474 (W 0.00278385) | 0.24169 ± 0.0018437 (W 0.00278551) | 0.411285 ± 0.00437395 (W 0.00162743) | · | 🔵 fork 1.72× faster than `lapack-mkl` |  |
| `qr/256x4096/b1` | 16.549 ± 0.0662078 (W 0.0785271) | 20.7906 ± 0.249798 (W 0.56301) | 36.9837 ± 0.272053 (W 0.0929736) | 🔵 fork 1.26× faster than `faer-upstream` | 🔵 fork 2.23× faster than `lapack-mkl` |  |
| `qr/64x1024/b1` | 0.641544 ± 0.00354734 (W 0.00393064) | 1.21423 ± 0.0161599 (W 0.0263758) | 1.07108 ± 0.100017 (W 0.0112524) | 🔵 fork 1.89× faster than `faer-upstream` | 🔵 fork 1.67× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 14.2313 ± 0.0227131 (W 0.051297) | 18.3998 ± 0.364974 (W 0.587168) | 18.7279 ± 0.0230744 (W 0.0235088) | 🔵 fork 1.29× faster than `faer-upstream` | 🔵 fork 1.32× faster than `lapack-mkl` |  |
| `qr_factor/64x1024/b1` | 0.466638 ± 0.000556267 (W 0.00380031) | 1.0225 ± 0.00902634 (W 0.0180185) | 0.707746 ± 0.000281894 (W 0.00148442) | 🔵 fork 2.19× faster than `faer-upstream` | 🔵 fork 1.52× faster than `lapack-mkl` |  |
| `svd_thin/256x4096/b1` | 89.8413 ± 0.109009 (W 0.261805) | 106.992 ± 0.147611 (W 0.323445) | 108.884 ± 0.401995 (W 0.212722) | 🔵 fork 1.19× faster than `faer-upstream` | 🔵 fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/64x1024/b1` | 3.91985 ± 0.0113538 (W 0.0288063) | 4.7533 ± 0.0063918 (W 0.0472883) | 6.16462 ± 0.0688499 (W 0.0306833) | 🔵 fork 1.21× faster than `faer-upstream` | 🔵 fork 1.57× faster than `lapack-mkl` |  |
| `svd_values/256x4096/b1` | 59.3482 ± 0.132434 (W 0.0984914) | 73.2795 ± 0.0877871 (W 0.398341) | 53.2365 ± 0.158193 (W 0.0893471) | 🔵 fork 1.23× faster than `faer-upstream` | 🔴 fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/64x1024/b1` | 2.65669 ± 0.00943567 (W 0.0157123) | 3.40138 ± 0.0109054 (W 0.0249268) | 3.18041 ± 0.0355128 (W 0.0181756) | 🔵 fork 1.28× faster than `faer-upstream` | 🔵 fork 1.20× faster than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
