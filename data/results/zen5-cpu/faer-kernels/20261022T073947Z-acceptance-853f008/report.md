# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `853f008564ea5a0727c20fad07d6f03872d83e4f`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `b09a1dc5bec4c327d94b4745cf3512c3695097f5`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `718ac54b9cd5a73180fd75cbcb390dbb5263f416628655148394dec52e8e92c4`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-22T09:07:24.869738Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-small,gemm-mid,gemm-tall,gemm-wide,linalg-mid,linalg-tall --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label acceptance-853f008 --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261022T073947Z-acceptance-853f008/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.83%, worst 99.44% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 203 of 2124 engine cells exceed 5% and carry `!`; median within-process relative SD 0.44%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `gemm/32x32x32/b1` | 0.002325 ± 1.09697e-05 (W 1.85796e-05) | 0.002324 ± 4.89932e-05 (W 1.76153e-05) | 0.004529 ± 5.61278e-05 (W 4.15969e-05) | · | 🔵 faer-fork 1.95× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017012 ± 0.000109986 (W 2.50998e-05) | 0.017091 ± 0.00015972 (W 1.48324e-05) | 0.024456 ± 0.000137041 (W 6.18409e-05) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056736 ± 0.000213987 (W 3.52605e-05) | 0.056746 ± 6.61589e-05 (W 6.51022e-05) | 0.062576 ± 9.56574e-05 (W 4.86826e-05) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002344 ± 2.08167e-05 (W 1.52381e-05) | 0.009789 ± 0.000416474 (W 0.000391653) | 0.005189 ± 0.000130539 (W 9.49763e-05) | 🔵 faer-fork 4.18× faster than `faer-upstream` | 🔵 faer-fork 2.21× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017182 ± 1e-05 (W 3.57099e-05) | 0.020248 ± 0.00361641 (W 0.00299247) | 0.014207 ± 0.000195679 (W 0.000135522) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.020749 ± 0.000119304 (W 0.00019305) | 0.068468 ± 0.0137251 (W 0.00823357) | 0.022161 ± 0.000225167 (W 0.000116195) | 🔵 faer-fork 3.30× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 1.00167e-05 (W 1.30077e-05) | 0.013155 ± 0.000319922 (W 0.00124593) | 0.004889 ± 0.000110259 (W 7.0214e-05) | 🔵 faer-fork 5.64× faster than `faer-upstream` | 🔵 faer-fork 2.09× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017193 ± 0.000158557 (W 3.27292e-05) | 0.020148 ± 0.000664424 (W 0.00119006) | 0.009959 ± 0.000127123 (W 0.000130692) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.018975 ± 0.00036659 (W 0.00100805) | 0.030868 ± 0.000546374 (W 0.00168865) | 0.014818 ± 0.00028585 (W 0.000349614) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 1.52753e-05 (W 1.17132e-05) | 0.002344 ± 4.58258e-05 (W 1.61957e-05) | 0.004609 ± 3.84318e-05 (W 4.0015e-05) | · | 🔵 faer-fork 1.97× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017112 ± 5.91636e-05 (W 3.67328e-05) | 0.017072 ± 0.000170969 (W 3.58357e-05) | 0.024455 ± 6.80686e-05 (W 3.78153e-05) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056836 ± 7.81025e-05 (W 4.3359e-05) | 0.056826 ± 5.50757e-05 (W 5.66321e-05) | 0.062797 ± 0.000144684 (W 0.00105743) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002334 ± 6.08276e-06 (W 1.49064e-05) | 0.010048 ± 0.000481153 (W 0.000604131) | 0.005219 ± 0.00020297 (W 0.000166042) | 🔵 faer-fork 4.31× faster than `faer-upstream` | 🔵 faer-fork 2.24× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017082 ± 6.4291e-05 (W 1.56589e-05) | 0.024286 ± 0.00131077 (W 0.00356725) | 0.014246 ± 0.0001105 (W 0.000131339) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.021059 ± 0.000320718 (W 0.000383358) | 0.04822 ± 0.01578 (W 0.016324) | 0.022232 ± 0.000168009 (W 8.92143e-05) | 🔵 faer-fork 2.29× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002354 ± 6.08276e-06 (W 1.96545e-05) | 0.013335 ± 0.00133398 (W 0.0010943) | 0.004869 ± 0.000193993 (W 0.000116103) | 🔵 faer-fork 5.66× faster than `faer-upstream` | 🔵 faer-fork 2.07× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017333 ± 7.55006e-05 (W 2.40687e-05) | 0.021159 ± 0.00242919 (W 0.00168489) | 0.010099 ± 0.000215686 (W 0.000191545) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.72× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.019426 ± 0.000246538 (W 0.00053618) | 0.031258 ± 0.000225382 (W 0.000997258) | 0.014787 ± 0.000119039 (W 0.000118837) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008876 ± 2.0664e-05 (W 2.16795e-05) | 0.008876 ± 5.31068e-05 (W 1.98796e-05) | 0.01114 ± 4.08697e-05 (W 0.000136258) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067766 ± 0.000145041 (W 4.68967e-05) | 0.067725 ± 0.000143183 (W 3.55556e-05) | 0.083035 ± 0.00158991 (W 0.00140274) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.226862 ± 0.000369722 (W 0.00138957) | 0.227173 ± 0.0013278 (W 0.00151626) | 0.271054 ± 0.00124224 (W 0.0042244) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008807 ± 4.55741e-05 (W 2.30716e-05) | 0.008837 ± 9.33292e-05 (W 1.56301e-05) | 0.014126 ± 0.000435749 (W 0.000129112) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.023534 ± 0.000155963 (W 0.00162582) | 0.038862 ± 0.0018529 (W 0.00537654) | 0.035365 ± 0.000477977 (W 0.000486715) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.063589 ± 4.59384e-05 (W 0.00040295) | 0.094637 ± 0.00448172 (W 0.00720552) | 0.097682 ± 0.00163327 (W 0.00182569) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008836 ± 0.000104644 (W 1.90604e-05) | 0.008896 ± 5.03322e-05 (W 2.40687e-05) | 0.024896 ± 0.00495554 (W 0.000273169) | · | 🔵 faer-fork 2.82× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.028002 ± 0.00030315 (W 0.00172433) | 0.03766 ± 0.000602584 (W 0.00210609) | 0.015709 ± 7.57188e-05 (W 0.000108973) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.047919 ± 0.000179407 (W 0.000403956) | 0.050815 ± 0.000817042 (W 0.00130112) | 0.04273 ± 0.000123087 (W 0.000242224) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008847 ± 2e-05 (W 2.07364e-05) | 0.008897 ± 8.14453e-05 (W 2.12132e-05) | 0.011111 ± 8.0829e-05 (W 0.000150882) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067726 ± 0.0001205 (W 0.00138871) | 0.067746 ± 5.03322e-05 (W 4.94085e-05) | 0.083736 ± 0.00193283 (W 0.00158625) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.227002 ± 0.000325813 (W 0.00140851) | 0.226773 ± 0.000289684 (W 0.00150241) | 0.271938 ± 0.000950893 (W 0.00380104) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008817 ± 4.55741e-05 (W 2.04524e-05) | 0.008826 ± 9.02053e-05 (W 3.73001e-05) | 0.013886 ± 0.000442358 (W 0.000170545) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.023764 ± 5.50757e-05 (W 0.000992519) | 0.039273 ± 0.00477622 (W 0.00526702) | 0.035787 ± 0.000386782 (W 0.000946944) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/96x96x96/b1` | 0.06437 ± 0.000207399 (W 0.000216864) | 0.086692 ± 0.00289613 (W 0.00522158) | 0.098814 ± 0.000680479 (W 0.000877422) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008936 ± 5.50485e-05 (W 1.41421e-05) | 0.008856 ± 7.97308e-05 (W 1.67332e-05) | 0.024786 ± 4.50925e-05 (W 0.000271688) | · | 🔵 faer-fork 2.77× faster than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.027982 ± 0.000481349 (W 0.000338808) | 0.03769 ± 0.000861413 (W 0.00159209) | 0.015679 ± 0.000183058 (W 0.000161025) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |
| `gemm/96x96x96/b1` | 0.048911 ± 0.000284723 (W 0.00256751) | 0.051185 ± 0.000489614 (W 0.00205587) | 0.042839 ± 0.000166694 (W 0.00150588) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13371 ± 6.86319e-05 (W 0.00168291) | 0.13382 ± 0.000169555 (W 7.68713e-05) | 0.167042 ± 0.00106997 (W 0.00154989) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.451892 ± 0.00096038 (W 0.00194254) | 0.451369 ± 0.00154981 (W 0.00221382) | 0.480017 ± 0.000349623 (W 0.0022434) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07741 ± 0.00146086 (W 0.000758157) | 1.07732 ± 0.00448834 (W 0.00162504) | 1.20386 ± 0.00755399 (W 0.0022252) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.61919 ± 0.0210814 (W 0.00295146) | 3.61389 ± 0.00529595 (W 0.00266818) | 3.73619 ± 0.0021061 (W 0.00537942) | · | · |  |
| `gemm/512x512x512/b1` | 8.61926 ± 0.0578754 (W 0.00863669) | 8.60218 ± 0.00675687 (W 0.0116086) | 9.90747 ± 0.117905 (W 0.0173996) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.3891 ± 0.179501 (W 0.00878056) | 29.4331 ± 0.0659482 (W 0.0253385) | 30.6583 ± 0.0680588 (W 0.0205412) | · | · |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.040155 ± 0.000125381 (W 0.000357243) | 0.083315 ± 0.0127922 (W 0.0158948) | 0.056676 ± 0.0001 (W 0.000343629) | 🔵 faer-fork 2.07× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.138658 ± 0.010416 (W 0.018256) | 0.145751 ± 0.00557266 (W 0.0114585) | 0.137116 ± 0.00140662 (W 0.00156247) | · | · | `!` between-start range over 5% |
| `gemm/256x256x256/b1` | 0.308275 ± 0.000805529 (W 0.00643289) | 0.304677 ± 0.0034374 (W 0.00448157) | 0.344523 ± 0.000132342 (W 0.00187171) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.932123 ± 0.00253805 (W 0.00597748) | 0.936068 ± 0.00157529 (W 0.00528862) | 1.00419 ± 0.00248166 (W 0.00286501) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.23749 ± 0.00820906 (W 0.00339776) | 2.24094 ± 0.016206 (W 0.0101429) | 2.9117 ± 0.108955 (W 0.00181966) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.55224 ± 0.0260133 (W 0.0136471) | 7.56364 ± 0.0259588 (W 0.0146896) | 8.50279 ± 0.0135335 (W 0.01486) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.024065 ± 0.000401287 (W 0.000357769) | 0.109564 ± 0.0111862 (W 0.0184589) | 0.032841 ± 0.00024 (W 0.00131155) | 🔵 faer-fork 4.55× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.188921 ± 0.0385368 (W 0.0411313) | 0.173253 ± 0.0174564 (W 0.032474) | 0.074619 ± 0.000721478 (W 0.000169397) | · | 🔴 faer-fork 2.53× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.217236 ± 0.0106324 (W 0.0225022) | 0.228757 ± 0.00674582 (W 0.0304153) | 0.179103 ± 0.000869356 (W 0.00216299) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.572414 ± 0.00506783 (W 0.0105261) | 0.56837 ± 0.00306787 (W 0.0150666) | 0.51635 ± 0.00417398 (W 0.00149337) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.1926 ± 0.0116715 (W 0.0117839) | 1.19569 ± 0.00286889 (W 0.0162391) | 1.52242 ± 0.00645797 (W 0.0099724) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.92094 ± 0.0204575 (W 0.00977483) | 3.92993 ± 0.00555847 (W 0.0282887) | 4.66723 ± 0.033536 (W 0.019351) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.13382 ± 3.00056e-05 (W 0.000941289) | 0.133829 ± 1.1547e-05 (W 0.00135727) | 0.167872 ± 0.000104887 (W 0.00143117) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.454115 ± 0.00116016 (W 0.00201162) | 0.451803 ± 0.000314089 (W 0.00206422) | 0.481477 ± 0.000833282 (W 0.00190039) | · | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.07936 ± 0.00112215 (W 0.000744585) | 1.07589 ± 0.00218601 (W 0.00138753) | 1.20758 ± 0.00270486 (W 0.00363819) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.61749 ± 0.0206868 (W 0.00277592) | 3.61692 ± 0.00516353 (W 0.00222581) | 3.72865 ± 0.00608381 (W 0.00325815) | · | · |  |
| `gemm/512x512x512/b1` | 8.63439 ± 0.0431933 (W 0.0139194) | 8.62104 ± 0.0069683 (W 0.0180614) | 9.84942 ± 0.0766558 (W 0.0167598) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4963 ± 0.143389 (W 0.0484609) | 29.4819 ± 0.0480526 (W 0.0336656) | 30.6425 ± 0.0924034 (W 0.031758) | · | · |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.040486 ± 9.86425e-05 (W 0.000234368) | 0.068758 ± 0.0143275 (W 0.0151969) | 0.055413 ± 0.000771765 (W 0.000295745) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.146634 ± 0.0159151 (W 0.0168388) | 0.16127 ± 0.0160312 (W 0.0196554) | 0.135322 ± 0.00112343 (W 0.000417017) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.303444 ± 0.00355001 (W 0.0037463) | 0.307232 ± 0.00470325 (W 0.00386172) | 0.344533 ± 0.00283117 (W 0.00212903) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 0.930134 ± 0.00569047 (W 0.00817535) | 0.933671 ± 0.00347786 (W 0.00600089) | 1.00528 ± 0.00031664 (W 0.00139379) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 2.2393 ± 0.0104027 (W 0.00441225) | 2.23832 ± 0.00266124 (W 0.00513653) | 2.84604 ± 0.0949717 (W 0.00696407) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/768x768x768/b1` | 7.54176 ± 0.0247341 (W 0.0200395) | 7.53318 ± 0.013373 (W 0.0102441) | 8.48229 ± 0.0241748 (W 0.00728244) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.024656 ± 0.000373698 (W 0.000402435) | 0.107741 ± 0.0175257 (W 0.030805) | 0.031839 ± 0.000562413 (W 0.000229851) | 🔵 faer-fork 4.37× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.147796 ± 0.0336936 (W 0.0410875) | 0.185026 ± 0.0131842 (W 0.036347) | 0.074729 ± 0.00107077 (W 0.00143187) | · | 🔴 faer-fork 1.98× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/256x256x256/b1` | 0.207207 ± 0.0202268 (W 0.0269117) | 0.207447 ± 0.00149217 (W 0.0327887) | 0.179935 ± 0.000509039 (W 0.00148755) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/384x384x384/b1` | 0.557952 ± 0.00596906 (W 0.0128406) | 0.564183 ± 0.00226608 (W 0.0109193) | 0.514099 ± 0.000907868 (W 0.0020251) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 1.19183 ± 0.00586888 (W 0.00808826) | 1.20171 ± 0.0113769 (W 0.0094861) | 1.51529 ± 0.00967762 (W 0.00306933) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 3.93678 ± 0.0258586 (W 0.0182949) | 3.93649 ± 0.00583502 (W 0.0337194) | 4.66135 ± 0.0140403 (W 0.0176768) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538772 ± 0.00269575 (W 0.00168533) | 0.540445 ± 0.00286857 (W 0.00216412) | 0.654052 ± 0.00972845 (W 0.00576264) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.8097 ± 0.0032454 (W 0.0018874) | 1.81002 ± 0.00179481 (W 0.00219919) | 2.15553 ± 0.00468677 (W 0.0141855) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.29856 ± 0.0137621 (W 0.00550839) | 4.28687 ± 0.00783912 (W 0.00447077) | 5.08399 ± 0.0180498 (W 0.0172007) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4378 ± 0.0163378 (W 0.00832421) | 14.4707 ± 0.0165707 (W 0.0101261) | 17.1712 ± 0.0630683 (W 0.0477969) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.3309 ± 0.0208367 (W 0.0232135) | 34.2934 ± 0.0097546 (W 0.0201604) | 40.857 ± 0.100591 (W 0.0578589) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.543 ± 0.373443 (W 0.330284) | 116.606 ± 0.348814 (W 0.158227) | 136.792 ± 0.639289 (W 0.142111) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.141693 ± 0.000861663 (W 0.00121299) | 0.161011 ± 0.000337196 (W 0.00143819) | 0.231953 ± 0.00126623 (W 0.00118155) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.472481 ± 0.00289494 (W 0.00383965) | 0.475768 ± 0.00203945 (W 0.00272406) | 0.748105 ± 0.00570112 (W 0.00349607) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.13039 ± 0.00221293 (W 0.00358058) | 1.12652 ± 0.00389402 (W 0.00395866) | 1.79301 ± 0.0194929 (W 0.00617261) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.6665 ± 0.0125473 (W 0.00939675) | 3.6685 ± 0.00998593 (W 0.00840746) | 5.79779 ± 0.00158013 (W 0.00770689) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.71004 ± 0.0124666 (W 0.0140807) | 8.69394 ± 0.0280737 (W 0.00944206) | 13.773 ± 0.00559525 (W 0.0298809) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4755 ± 0.0520995 (W 0.034852) | 29.5249 ± 0.0350123 (W 0.0315794) | 46.5918 ± 0.173002 (W 0.0360193) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.074369 ± 0.000331195 (W 0.000421833) | 0.11313 ± 0.00114795 (W 0.0019749) | 0.094896 ± 0.0011657 (W 0.000782414) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.282044 ± 0.0044359 (W 0.00917781) | 0.282977 ± 0.0034656 (W 0.0138061) | 0.293708 ± 0.00182783 (W 0.00264739) | · | · |  |
| `gemm/256x256x256/b1` | 0.607444 ± 0.0120517 (W 0.00823328) | 0.603845 ± 0.0034913 (W 0.0137187) | 0.687241 ± 0.0146282 (W 0.00195284) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.86924 ± 0.00307079 (W 0.00577476) | 1.87251 ± 0.00105934 (W 0.00772636) | 2.27494 ± 0.00422317 (W 0.00601299) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.51011 ± 0.00666231 (W 0.0153205) | 4.51093 ± 0.0254656 (W 0.00837882) | 5.53174 ± 0.0178125 (W 0.0207769) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 14.9708 ± 0.0168534 (W 0.0302025) | 14.9489 ± 0.0630556 (W 0.0178053) | 18.5169 ± 0.312908 (W 0.0925588) | · | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.538756 ± 0.00261347 (W 0.00206707) | 0.537604 ± 0.00107901 (W 0.00194379) | 0.648416 ± 0.00265097 (W 0.00706088) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 1.81054 ± 0.00272771 (W 0.00191839) | 1.81148 ± 0.00502044 (W 0.001714) | 2.15588 ± 0.00789224 (W 0.0128944) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 4.30259 ± 0.0134186 (W 0.00545982) | 4.2811 ± 0.00467206 (W 0.00203133) | 5.14919 ± 0.0257248 (W 0.0128162) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 14.4343 ± 0.00371163 (W 0.0201045) | 14.4364 ± 0.0233508 (W 0.010222) | 17.1826 ± 0.0159612 (W 0.0353112) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 34.3454 ± 0.0236712 (W 0.0229461) | 34.2787 ± 0.0106672 (W 0.0230111) | 40.9595 ± 0.0693022 (W 0.0569363) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 116.52 ± 0.480803 (W 0.0654543) | 116.26 ± 0.0716455 (W 0.0345474) | 137.016 ± 0.24611 (W 0.0860272) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.144289 ± 0.00099474 (W 0.00139172) | 0.16077 ± 0.00149947 (W 0.00256001) | 0.231422 ± 0.000845345 (W 0.00266307) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `gemm/192x192x192/b1` | 0.475828 ± 0.00183709 (W 0.00273586) | 0.476279 ± 0.00139308 (W 0.00197874) | 0.742094 ± 0.00236998 (W 0.00432301) | · | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |
| `gemm/256x256x256/b1` | 1.12922 ± 0.00325017 (W 0.00280579) | 1.12707 ± 0.00190969 (W 0.00407293) | 1.80757 ± 0.00891783 (W 0.00520848) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 3.66706 ± 0.0119243 (W 0.0113939) | 3.67004 ± 0.0100308 (W 0.0103221) | 5.77721 ± 0.0217802 (W 0.0132755) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 8.68087 ± 0.0265024 (W 0.0302853) | 8.7109 ± 0.0371749 (W 0.00815874) | 13.7959 ± 0.0321599 (W 0.0148854) | · | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 29.4887 ± 0.0111089 (W 0.0329636) | 29.4875 ± 0.00960091 (W 0.0244465) | 46.3441 ± 0.253634 (W 0.0640247) | · | 🔵 faer-fork 1.57× faster than `lapack-mkl` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.076383 ± 0.000154371 (W 0.000368403) | 0.116096 ± 0.00576548 (W 0.00416417) | 0.095108 ± 0.00519913 (W 0.000849717) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/192x192x192/b1` | 0.281435 ± 0.00535473 (W 0.0108764) | 0.277777 ± 0.00452849 (W 0.00707268) | 0.294819 ± 0.00178815 (W 0.00200728) | · | · |  |
| `gemm/256x256x256/b1` | 0.608502 ± 0.00586089 (W 0.0150025) | 0.616 ± 0.00327755 (W 0.0136455) | 0.703528 ± 0.00884834 (W 0.00283422) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `gemm/384x384x384/b1` | 1.87682 ± 0.00241823 (W 0.00922298) | 1.88117 ± 0.0100233 (W 0.0043689) | 2.28137 ± 0.00840618 (W 0.00794129) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `gemm/512x512x512/b1` | 4.50373 ± 0.00540193 (W 0.0120607) | 4.51932 ± 0.0168197 (W 0.00921685) | 5.52424 ± 0.0268739 (W 0.0120712) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `gemm/768x768x768/b1` | 15.0003 ± 0.0590969 (W 0.0313695) | 14.9724 ± 0.0200203 (W 0.00770883) | 18.7393 ± 0.0283787 (W 0.0702403) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.2754 ± 0.0638031 (W 0.00396088) | 1.27761 ± 0.0552229 (W 0.00551924) | 1.52222 ± 0.00460773 (W 0.0051069) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 1.07283 ± 0.00167055 (W 0.00850928) | 1.07208 ± 0.00207217 (W 0.00709787) | 1.51745 ± 0.0152093 (W 0.0113431) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.08826 ± 0.00862848 (W 0.00195938) | 1.0841 ± 0.00247898 (W 0.00620857) | 1.56814 ± 0.00450233 (W 0.00410334) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.334963 ± 0.0107188 (W 0.00456342) | 0.434318 ± 0.00559908 (W 0.00529029) | 0.41909 ± 0.00975737 (W 0.00450918) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.331477 ± 0.00346709 (W 0.00306398) | 0.331256 ± 0.00430177 (W 0.00322395) | 0.428738 ± 0.0412154 (W 0.00442551) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.318785 ± 0.0101608 (W 0.0106171) | 0.315698 ± 0.0058725 (W 0.00766904) | 0.39266 ± 0.00175463 (W 0.00219432) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.152374 ± 0.00124943 (W 0.00249602) | 0.439467 ± 0.00245685 (W 0.00381865) | 0.25775 ± 0.00802734 (W 0.00269897) | 🔵 faer-fork 2.88× faster than `faer-upstream` | 🔵 faer-fork 1.69× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.212867 ± 0.00292105 (W 0.00322276) | 0.215552 ± 0.00497219 (W 0.00354352) | 0.288118 ± 0.0018621 (W 0.0283149) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.203478 ± 0.0130024 (W 0.0218674) | 0.200654 ± 0.00848023 (W 0.0224472) | 0.197649 ± 0.000395487 (W 0.00187136) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.01882 ± 0.0187623 (W 0.00128005) | 1.0228 ± 0.0180965 (W 0.00140219) | 2.65033 ± 0.0153242 (W 0.00670476) | · | 🔵 faer-fork 2.60× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.08892 ± 0.0108948 (W 0.0100016) | 1.08782 ± 0.000559901 (W 0.0110521) | 1.43197 ± 0.0068307 (W 0.0134487) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.12966 ± 0.00108611 (W 0.0016741) | 1.13363 ± 0.0027669 (W 0.0024128) | 1.24107 ± 0.0131215 (W 0.00267659) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.268902 ± 0.00138594 (W 0.00397375) | 0.694276 ± 0.0169855 (W 0.0184112) | 0.646376 ± 0.00172837 (W 0.00363933) | 🔵 faer-fork 2.58× faster than `faer-upstream` | 🔵 faer-fork 2.40× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.320267 ± 0.00359696 (W 0.00220566) | 0.319747 ± 0.000856332 (W 0.00443093) | 0.432988 ± 0.000751791 (W 0.00235288) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.31104 ± 0.00410764 (W 0.00469009) | 0.313185 ± 0.00182979 (W 0.00364225) | 0.333061 ± 0.00338919 (W 0.0020997) | · | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.139651 ± 0.000898188 (W 0.00342283) | 1.12894 ± 0.0158684 (W 0.0263899) | 0.350644 ± 0.00301494 (W 0.00325104) | 🔵 faer-fork 8.08× faster than `faer-upstream` | 🔵 faer-fork 2.51× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.202608 ± 0.000335644 (W 0.00144737) | 0.200063 ± 0.0027666 (W 0.00314038) | 0.297283 ± 0.00205147 (W 0.0119556) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 0.181016 ± 0.00716521 (W 0.0039463) | 0.183382 ± 0.00243592 (W 0.00430841) | 0.175427 ± 0.00229038 (W 0.00186174) | · | · | `!` between-start range over 5% |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.15305 ± 0.00368974 (W 0.0107876) | 4.15314 ± 0.00995634 (W 0.00886368) | 5.68803 ± 0.0428892 (W 0.0265822) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.33071 ± 0.0066743 (W 0.00618553) | 4.33881 ± 0.0121364 (W 0.0053465) | 5.63997 ± 0.0352161 (W 0.0349189) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.39381 ± 0.00373988 (W 0.00724385) | 4.3918 ± 0.00270346 (W 0.00849989) | 5.25525 ± 0.0188051 (W 0.00852577) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.10185 ± 0.0196742 (W 0.00214468) | 1.66793 ± 0.00608401 (W 0.00428032) | 1.92406 ± 0.0286051 (W 0.00780339) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 1.20928 ± 0.00533699 (W 0.00842961) | 1.19647 ± 0.00366989 (W 0.00466602) | 2.15637 ± 0.0485024 (W 0.00905831) | · | 🔵 faer-fork 1.78× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.15255 ± 0.00172168 (W 0.00385179) | 1.15361 ± 0.00271987 (W 0.00279227) | 2.05688 ± 0.00726533 (W 0.00174337) | · | 🔵 faer-fork 1.78× faster than `lapack-mkl` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.622492 ± 0.00816758 (W 0.00583004) | 0.928693 ± 0.019953 (W 0.00843673) | 0.948104 ± 0.00773403 (W 0.00437885) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 0.645982 ± 0.00211883 (W 0.00376427) | 0.648798 ± 0.00141599 (W 0.00532645) | 0.990799 ± 0.212563 (W 0.00760584) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x64x64/b1` | 0.604094 ± 0.00315586 (W 0.00403404) | 0.603623 ± 0.00166454 (W 0.00523811) | 0.756687 ± 0.00442956 (W 0.00393334) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.06466 ± 0.0160237 (W 0.00702499) | 4.07986 ± 0.010765 (W 0.00493239) | 5.73061 ± 0.0151803 (W 0.00941327) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `gemm/4096x16x240/b1` | 4.34832 ± 0.0118111 (W 0.00623499) | 4.35405 ± 0.0240541 (W 0.00484499) | 5.42951 ± 0.0286693 (W 0.0396269) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 4.44751 ± 0.00699688 (W 0.00491392) | 4.44475 ± 0.00946338 (W 0.0102165) | 5.84788 ± 0.0822151 (W 0.0190848) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.03746 ± 0.010362 (W 0.00715601) | 1.87291 ± 0.05302 (W 0.0428544) | 10.7737 ± 6.1763 (W 0.0143702) | 🔵 faer-fork 1.81× faster than `faer-upstream` | 🔵 faer-fork 10.38× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 1.20685 ± 0.0034572 (W 0.0051249) | 1.2048 ± 0.00163911 (W 0.00830164) | 2.33502 ± 0.0580571 (W 0.0340827) | · | 🔵 faer-fork 1.93× faster than `lapack-mkl` |  |
| `gemm/4096x64x64/b1` | 1.23966 ± 0.027425 (W 0.0106886) | 1.21024 ± 0.0166806 (W 0.00929097) | 2.04848 ± 0.0225177 (W 0.0175141) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.527304 ± 0.00244232 (W 0.00332147) | 2.56829 ± 0.0338118 (W 0.0468917) | 10.6361 ± 4.31488 (W 0.0165232) | 🔵 faer-fork 4.87× faster than `faer-upstream` | 🔵 faer-fork 20.17× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `gemm/4096x16x240/b1` | 0.648189 ± 0.00654358 (W 0.0161461) | 0.642988 ± 0.00136768 (W 0.00520319) | 1.54147 ± 0.14672 (W 0.0142258) | · | 🔵 faer-fork 2.38× faster than `lapack-mkl` | `!` between-start range over 5% |
| `gemm/4096x64x64/b1` | 0.615515 ± 0.0042957 (W 0.0065562) | 0.616401 ± 0.00252551 (W 0.00527187) | 1.17074 ± 0.123027 (W 0.025496) | · | 🔵 faer-fork 1.90× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12024 ± 0.00728254 (W 0.00252555) | 1.11839 ± 0.00762023 (W 0.00265451) | 1.23863 ± 0.00114427 (W 0.00285925) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.295421 ± 0.00575833 (W 0.00315132) | 0.311912 ± 0.00282088 (W 0.00400063) | 0.329213 ± 0.00178929 (W 0.0024962) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.155049 ± 0.00218365 (W 0.00134749) | 0.179735 ± 0.000492309 (W 0.00227952) | 0.174285 ± 0.0028162 (W 0.00148406) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.0916 ± 0.00421934 (W 0.00146738) | 1.089 ± 0.00240081 (W 0.00152716) | 1.54667 ± 0.00927177 (W 0.00307393) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.281414 ± 0.00109664 (W 0.0012443) | 0.313976 ± 0.0082781 (W 0.00849445) | 0.390417 ± 0.00154614 (W 0.00230493) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.152103 ± 0.00195598 (W 0.00125458) | 0.19314 ± 0.0125728 (W 0.0126595) | 0.198931 ± 0.000470904 (W 0.00176293) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.43909 ± 0.00531747 (W 0.0132673) | 4.44537 ± 0.00496383 (W 0.00307987) | 5.76346 ± 0.0138538 (W 0.0152961) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.19103 ± 0.0125235 (W 0.00435853) | 1.21614 ± 0.00486653 (W 0.0120296) | 2.04296 ± 0.0286376 (W 0.00983504) | · | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.588138 ± 0.00178365 (W 0.00369693) | 0.618924 ± 0.00521053 (W 0.00568533) | 1.18622 ± 0.106845 (W 0.0638998) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 2.02× faster than `lapack-mkl` | `!` between-start range over 5% |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.39189 ± 0.0091705 (W 0.00350791) | 4.39564 ± 0.0267643 (W 0.00469835) | 5.24275 ± 0.0028953 (W 0.00655914) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.10663 ± 0.00231101 (W 0.00338464) | 1.14931 ± 0.00675082 (W 0.00558303) | 2.06488 ± 0.00341669 (W 0.00547989) | · | 🔵 faer-fork 1.87× faster than `lapack-mkl` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.569692 ± 0.000462533 (W 0.00567324) | 0.60068 ± 0.00391887 (W 0.00547088) | 0.763044 ± 0.00323208 (W 0.00231541) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.067175 ± 0.00279034 (W 0.00040889) | 0.070652 ± 0.000553285 (W 0.00027069) | 0.116487 ± 0.00153286 (W 0.00037129) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.73× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.388383 ± 0.00313464 (W 0.00244802) | 0.397883 ± 0.00371692 (W 0.00256973) | 0.636998 ± 0.00378249 (W 0.00394254) | · | 🔵 faer-fork 1.64× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.52438 ± 0.038925 (W 0.00788488) | 2.5223 ± 0.0343547 (W 0.00536394) | 4.03077 ± 0.010982 (W 0.00699471) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.2581 ± 0.00483593 (W 0.00288014) | 2.25626 ± 0.00764078 (W 0.00336666) | 1.86369 ± 0.00549692 (W 0.0148003) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.81304 ± 0.0114135 (W 0.012747) | 9.80272 ± 0.0276162 (W 0.0119672) | 10.0115 ± 0.016099 (W 0.0214135) | · | · |  |
| `eigh/n512/b1` | 49.0306 ± 0.247621 (W 0.0443321) | 48.9016 ± 0.140644 (W 0.0838376) | 61.2953 ± 0.0569636 (W 0.0586313) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309847 ± 0.00242201 (W 0.00287265) | 0.314777 ± 0.0021711 (W 0.00206361) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71153 ± 0.0116106 (W 0.00688527) | 2.78785 ± 0.0287143 (W 0.0104215) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 22.0588 ± 0.0386471 (W 0.0360846) | 22.6808 ± 0.0662229 (W 0.0589906) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.261307 ± 0.00158405 (W 0.00215309) | 0.258782 ± 0.000628077 (W 0.00161042) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.259995 ± 0.000252589 (W 0.00238452) | 0.259144 ± 0.000281379 (W 0.00163404) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.95051 ± 0.00593027 (W 0.00580402) | 1.90759 ± 0.0270198 (W 0.00237661) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93096 ± 0.0168175 (W 0.0016355) | 1.91596 ± 0.0222387 (W 0.00227186) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.9399 ± 0.0283277 (W 0.0178329) | 15.8515 ± 0.0083431 (W 0.0198388) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9318 ± 0.0149547 (W 0.0153339) | 15.8328 ± 0.0307827 (W 0.0170302) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.135243 ± 0.000776085 (W 0.00158322) | 0.138307 ± 0.0170939 (W 0.00209402) | 0.170859 ± 0.0194877 (W 0.00164409) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.991004 ± 0.11738 (W 0.00296208) | 1.03739 ± 0.000531077 (W 0.0041553) | 0.970682 ± 0.134162 (W 0.00241587) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.66421 ± 0.0141404 (W 0.0181574) | 7.23593 ± 0.0875553 (W 0.0163581) | 6.98287 ± 0.0263255 (W 0.00788206) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |
| `qr/n128/b1` | 0.518568 ± 0.00145143 (W 0.00252103) | 0.517352 ± 0.00301452 (W 0.00235577) | 0.749207 ± 0.00229483 (W 0.00286272) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.90226 ± 0.00497113 (W 0.00613943) | 2.94056 ± 0.00749382 (W 0.00337892) | 4.32266 ± 0.00471351 (W 0.00755093) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 20.4537 ± 0.0206445 (W 0.0218505) | 20.967 ± 0.0957122 (W 0.0507875) | 30.5324 ± 0.0284767 (W 0.0574522) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.331228 ± 0.000676024 (W 0.00176193) | 0.537461 ± 0.00279248 (W 0.00279837) | 0.36973 ± 0.00153978 (W 0.0025004) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.6017 ± 0.00729671 (W 0.00540562) | 2.84556 ± 0.0274631 (W 0.00677747) | 2.04117 ± 0.00398743 (W 0.0100852) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.84482 ± 0.021858 (W 0.00982652) | 17.6787 ± 0.0550822 (W 0.0201341) | 14.1509 ± 0.00868889 (W 0.0270038) | 🔵 faer-fork 2.00× faster than `faer-upstream` | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.135423 ± 0.000355781 (W 0.000263989) | 0.136695 ± 0.000740197 (W 0.00160436) | 0.170207 ± 0.000332808 (W 0.00177026) | · | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.756402 ± 0.00499035 (W 0.00233843) | 0.807607 ± 0.00319356 (W 0.00201846) | 0.97084 ± 0.00308284 (W 0.00432292) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.59761 ± 0.00486098 (W 0.0127316) | 7.13271 ± 0.0691928 (W 0.0142178) | 6.00334 ± 0.00898323 (W 0.010992) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67884 ± 0.00832523 (W 0.00266097) | 3.67712 ± 0.00873962 (W 0.00343227) | 3.39126 ± 0.0105587 (W 0.0133614) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.4771 ± 0.00245084 (W 0.00986307) | 18.4762 ± 0.00529946 (W 0.011484) | 18.127 ± 0.120974 (W 0.0235764) | · | · |  |
| `svd_thin/n512/b1` | 106.072 ± 0.304402 (W 0.142657) | 105.92 ± 0.203143 (W 0.0738822) | 117.596 ± 0.275554 (W 0.512433) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.69078 ± 0.010052 (W 0.0032915) | 2.69068 ± 0.00511022 (W 0.00242754) | 1.19663 ± 0.00229684 (W 0.00295223) | · | 🔴 faer-fork 2.25× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4778 ± 0.00956375 (W 0.0164453) | 12.4624 ± 0.0104693 (W 0.00547309) | 6.96457 ± 0.00899791 (W 0.00753119) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 66.1945 ± 0.133582 (W 0.0466341) | 66.1999 ± 0.134384 (W 0.0378682) | 47.5821 ± 0.143401 (W 0.0684548) | · | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004409 ± 4.17971e-05 (W 5.89593e-05) | 0.004118 ± 0.000134288 (W 4.25476e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011983 ± 0.000859759 (W 6.64545e-05) | 0.011342 ± 0.000834341 (W 7.86785e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.041527 ± 0.00327122 (W 0.000268822) | 0.038952 ± 0.00301791 (W 0.000386737) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.089667 ± 0.00280116 (W 0.00214697) | 0.104196 ± 0.00424644 (W 0.00592485) | 0.113431 ± 0.000520194 (W 0.000472334) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.394184 ± 0.0227334 (W 0.0209652) | 0.39121 ± 0.0164449 (W 0.0125943) | 0.409013 ± 0.00190503 (W 0.00443086) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n512/b1` | 1.56436 ± 0.072676 (W 0.0243197) | 1.68046 ± 0.0130531 (W 0.0244582) | 1.93889 ± 0.0163491 (W 0.00874588) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |
| `eigh/n128/b1` | 2.35959 ± 0.0448857 (W 0.037879) | 2.28594 ± 0.0221443 (W 0.0114077) | 1.07131 ± 0.00189256 (W 0.00312699) | · | 🔴 faer-fork 2.20× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 7.01095 ± 0.0143013 (W 0.0470081) | 6.96948 ± 0.00902049 (W 0.0532925) | 4.78016 ± 0.00584502 (W 0.00834655) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 26.1138 ± 0.170096 (W 0.0936183) | 26.1905 ± 0.187384 (W 0.0660311) | 21.7202 ± 0.0411765 (W 0.042128) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.309393 ± 0.00115121 (W 0.00303019) | 0.316536 ± 0.00249689 (W 0.00248739) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71395 ± 0.0292275 (W 0.00983646) | 2.78066 ± 0.0314474 (W 0.0102581) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.3591 ± 0.0570794 (W 0.0579722) | 18.002 ± 0.0387305 (W 0.126771) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.085341 ± 0.000786392 (W 0.000525816) | 0.084156 ± 0.000781668 (W 0.000344646) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.086542 ± 0.000831746 (W 0.00115495) | 0.085349 ± 0.000711607 (W 0.00155966) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.527422 ± 0.00408304 (W 0.00404898) | 0.517273 ± 0.00308053 (W 0.00169941) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.532562 ± 0.00343936 (W 0.00313438) | 0.527512 ± 0.00139378 (W 0.00310557) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.18734 ± 0.0265686 (W 0.0137853) | 4.10267 ± 0.0249142 (W 0.0170188) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.17326 ± 0.0327558 (W 0.0150036) | 4.11109 ± 0.0321002 (W 0.0146512) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.134861 ± 0.0183447 (W 0.00188648) | 0.21446 ± 0.0195869 (W 0.00947666) | 0.153095 ± 0.0144397 (W 0.00180543) | 🔵 faer-fork 1.59× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.00174 ± 0.12534 (W 0.0042285) | 1.16362 ± 0.0357482 (W 0.0204741) | 0.380759 ± 0.113133 (W 0.00394285) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 2.63× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.90892 ± 0.0413437 (W 0.0602827) | 5.55659 ± 0.0373411 (W 0.0706992) | 2.61769 ± 0.00516721 (W 0.00833709) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.564633 ± 0.0417866 (W 0.0449182) | 1.4144 ± 0.0207052 (W 0.0284892) | 0.481647 ± 0.00111113 (W 0.00321699) | 🔵 faer-fork 2.50× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.98719 ± 0.036215 (W 0.0235278) | 3.7959 ± 0.0170158 (W 0.0788497) | 2.01318 ± 0.00401746 (W 0.00795204) | 🔵 faer-fork 1.91× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 10.1066 ± 0.980514 (W 0.0759782) | 14.4436 ± 1.06846 (W 0.0976841) | 12.0522 ± 0.0642449 (W 0.017725) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.393611 ± 0.0253635 (W 0.007393) | 1.4686 ± 0.0100793 (W 0.0106859) | 0.19839 ± 0.00104456 (W 0.00184245) | 🔵 faer-fork 3.73× faster than `faer-upstream` | 🔴 faer-fork 1.98× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.45167 ± 0.0134836 (W 0.0264092) | 5.61311 ± 0.026488 (W 0.0302341) | 0.674024 ± 0.00382098 (W 0.00247181) | 🔵 faer-fork 3.87× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 5.16941 ± 0.0345536 (W 0.0231847) | 22.1126 ± 0.132459 (W 0.100548) | 3.86497 ± 0.00771551 (W 0.00628835) | 🔵 faer-fork 4.28× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.136164 ± 0.00090696 (W 0.00157505) | 0.207125 ± 0.00370006 (W 0.00509738) | 0.150751 ± 0.000359446 (W 0.000856198) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.768283 ± 0.00382368 (W 0.00416006) | 0.9133 ± 0.016325 (W 0.0201231) | 0.367175 ± 0.000687574 (W 0.0036893) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.09× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.74406 ± 0.0216806 (W 0.0896748) | 5.42923 ± 0.0242162 (W 0.0428186) | 1.83542 ± 0.0221727 (W 0.00383168) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 2.58× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.04582 ± 0.00872724 (W 0.0185274) | 3.03645 ± 0.00936542 (W 0.021809) | 2.63747 ± 0.0023972 (W 0.00445796) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.6797 ± 0.0142062 (W 0.0380177) | 13.6596 ± 0.0334959 (W 0.0806282) | 12.4944 ± 0.0608647 (W 0.022352) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.5889 ± 0.23716 (W 0.15934) | 61.6181 ± 0.206881 (W 0.286542) | 58.7843 ± 2.12352 (W 0.383188) | · | · | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.2375 ± 0.0134413 (W 0.00231786) | 2.23638 ± 0.0128201 (W 0.00567872) | 1.14457 ± 0.00388689 (W 0.00322715) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8202 ± 0.040683 (W 0.0870087) | 10.7766 ± 0.0142873 (W 0.0171874) | 6.12849 ± 0.00143662 (W 0.0113865) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.189 ± 0.246276 (W 0.471774) | 47.9859 ± 0.252553 (W 0.33005) | 25.7661 ± 0.171473 (W 0.038041) | · | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004057 ± 0.000147582 (W 3.04187e-05) | 0.003617 ± 0.000144338 (W 4.01161e-05) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.010519 ± 3.50761e-05 (W 8.25064e-05) | 0.009859 ± 0.000650269 (W 7.61728e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.035997 ± 0.00567394 (W 0.000590991) | 0.034625 ± 0.00449885 (W 0.000279266) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.090088 ± 0.00315347 (W 0.00360612) | 0.108182 ± 0.00126345 (W 0.00238413) | 0.114545 ± 0.000616248 (W 0.000656088) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.401665 ± 0.0117716 (W 0.0184267) | 0.461631 ± 0.0190483 (W 0.0164128) | 0.364019 ± 0.00304708 (W 0.00403716) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.54649 ± 0.0165564 (W 0.0366517) | 1.65118 ± 0.031656 (W 0.0253555) | 1.46283 ± 0.0214257 (W 0.013363) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.36245 ± 0.0432768 (W 0.0255251) | 2.31439 ± 0.0176382 (W 0.0190406) | 1.01124 ± 0.00221568 (W 0.00367397) | · | 🔴 faer-fork 2.34× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.93041 ± 0.0255986 (W 0.0308948) | 7.05595 ± 0.0145026 (W 0.036279) | 4.01263 ± 0.0095636 (W 0.00952156) | · | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 24.1314 ± 0.0776691 (W 0.0541741) | 24.8566 ± 0.0527102 (W 0.105273) | 15.2189 ± 0.0599882 (W 0.0317211) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.31125 ± 0.00100336 (W 0.00275503) | 0.312062 ± 0.00150289 (W 0.0019551) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.69514 ± 0.00486794 (W 0.00652022) | 2.75173 ± 0.0088316 (W 0.00578901) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.2417 ± 0.0232671 (W 0.110387) | 17.8458 ± 0.0588865 (W 0.124793) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.060663 ± 0.000897052 (W 0.000938958) | 0.102942 ± 0.000996503 (W 0.00215708) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.060664 ± 0.00071606 (W 0.000578088) | 0.10231 ± 0.000243032 (W 0.00155316) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.285636 ± 0.00323382 (W 0.00265002) | 0.398754 ± 0.00402081 (W 0.0175571) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.291306 ± 0.00143985 (W 0.00410713) | 0.406578 ± 0.00399873 (W 0.0187659) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.28026 ± 0.0100583 (W 0.0125776) | 2.59421 ± 0.127242 (W 0.267114) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.30189 ± 0.0239435 (W 0.022055) | 2.53584 ± 0.0513787 (W 0.16679) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.135563 ± 0.0180611 (W 0.00191262) | 0.217505 ± 0.0194647 (W 0.0099524) | 0.148818 ± 0.0251426 (W 0.000533742) | 🔵 faer-fork 1.60× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 1.00177 ± 0.123684 (W 0.0065499) | 1.26497 ± 0.0141962 (W 0.0203262) | 0.348368 ± 0.144607 (W 0.00233189) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 2.88× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.62889 ± 0.0385663 (W 0.0240328) | 5.72661 ± 0.100641 (W 0.0762025) | 2.31663 ± 0.0719329 (W 0.00773017) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 2.00× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.602142 ± 0.0153341 (W 0.0210438) | 1.88518 ± 0.053567 (W 0.0266058) | 0.42907 ± 0.00289362 (W 0.00263235) | 🔵 faer-fork 3.13× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.81205 ± 0.0107757 (W 0.027692) | 4.82007 ± 0.091285 (W 0.0587148) | 1.79294 ± 0.00275527 (W 0.00858452) | 🔵 faer-fork 2.66× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 8.84117 ± 0.0404149 (W 0.0405973) | 15.8349 ± 0.0516979 (W 0.1486) | 9.03945 ± 0.118632 (W 0.0210139) | 🔵 faer-fork 1.79× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.373676 ± 0.00809335 (W 0.00577874) | 1.9623 ± 0.0369521 (W 0.0248466) | 0.156182 ± 0.00104632 (W 0.000966202) | 🔵 faer-fork 5.25× faster than `faer-upstream` | 🔴 faer-fork 2.39× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.3982 ± 0.00810268 (W 0.0153474) | 6.55897 ± 0.0294405 (W 0.0403111) | 0.576303 ± 0.00398511 (W 0.0039321) | 🔵 faer-fork 4.69× faster than `faer-upstream` | 🔴 faer-fork 2.43× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.82394 ± 0.0616673 (W 0.015677) | 24.9312 ± 0.216105 (W 0.101534) | 2.31723 ± 0.00583283 (W 0.00620916) | 🔵 faer-fork 5.17× faster than `faer-upstream` | 🔴 faer-fork 2.08× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.135623 ± 0.000242116 (W 0.00158069) | 0.215753 ± 0.00135375 (W 0.00610827) | 0.146072 ± 0.000131668 (W 0.000284881) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.772911 ± 0.00761011 (W 0.00417759) | 0.947605 ± 0.0140999 (W 0.0376285) | 0.334027 ± 0.00243523 (W 0.00253916) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 2.31× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.6201 ± 0.0381555 (W 0.0280706) | 5.53777 ± 0.0989036 (W 0.0849602) | 1.29308 ± 0.024134 (W 0.00559779) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 3.57× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.04415 ± 0.00856697 (W 0.00611982) | 3.12635 ± 0.0203622 (W 0.0168971) | 2.51828 ± 0.00466118 (W 0.00516946) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.4599 ± 0.0345319 (W 0.0333393) | 13.8015 ± 0.0476714 (W 0.0310178) | 11.4913 ± 0.0156983 (W 0.0126207) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 59.5299 ± 0.218439 (W 0.351878) | 60.9191 ± 0.188196 (W 0.266315) | 48.4552 ± 2.3741 (W 0.0795696) | · | 🔴 faer-fork 1.23× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.22085 ± 0.032748 (W 0.00512018) | 2.21665 ± 0.0351273 (W 0.00469276) | 1.13847 ± 0.00721645 (W 0.00420439) | · | 🔴 faer-fork 1.95× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.969 ± 0.0151973 (W 0.0165998) | 10.9485 ± 0.0124946 (W 0.0209534) | 6.01082 ± 0.0101416 (W 0.00760391) | · | 🔴 faer-fork 1.82× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 49.537 ± 0.503689 (W 0.260987) | 49.1457 ± 0.430346 (W 0.483612) | 22.3862 ± 0.0718052 (W 0.0287905) | · | 🔴 faer-fork 2.21× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004057 ± 0.0001345 (W 3.91446e-05) | 0.003747 ± 0.000115036 (W 2.60768e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.01063 ± 0.000659077 (W 7.98123e-05) | 0.009909 ± 0.00069384 (W 5.47193e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.038643 ± 0.00232825 (W 0.000714321) | 0.037931 ± 0.00124551 (W 0.00106078) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.056025 ± 0.00269693 (W 0.000566733) | 0.063999 ± 0.000949411 (W 0.000738498) | 0.094226 ± 0.00119022 (W 0.00139835) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.68× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.313464 ± 0.00168052 (W 0.00158654) | 0.324285 ± 0.00368403 (W 0.00210935) | 0.462553 ± 0.00944388 (W 0.00293042) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.06072 ± 0.00381555 (W 0.00151052) | 2.06552 ± 0.00175992 (W 0.00193608) | 3.39019 ± 0.0471007 (W 0.0101409) | · | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.25454 ± 0.00566225 (W 0.00302006) | 2.25731 ± 0.00488334 (W 0.00242794) | 1.82511 ± 0.00238371 (W 0.014267) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 9.75625 ± 0.0197623 (W 0.00940269) | 9.74958 ± 0.0148741 (W 0.0035633) | 9.85914 ± 0.0159384 (W 0.0255821) | · | · |  |
| `eigh/n512/b1` | 48.7392 ± 0.295811 (W 0.0384608) | 48.5799 ± 0.252019 (W 0.277171) | 60.0544 ± 0.145305 (W 0.0342458) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.291253 ± 0.00226421 (W 0.00199954) | 0.292314 ± 0.00228349 (W 0.00182648) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.62881 ± 0.0156855 (W 0.0117621) | 2.65311 ± 0.0181075 (W 0.00765528) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.4627 ± 0.103843 (W 0.0270538) | 21.476 ± 0.0237545 (W 0.0296776) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254925 ± 0.00132611 (W 0.0022037) | 0.254455 ± 0.00089433 (W 0.00204874) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.256478 ± 0.000826247 (W 0.00178834) | 0.255496 ± 0.000201331 (W 0.00179044) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.89125 ± 0.0126803 (W 0.00339217) | 1.86666 ± 0.0178506 (W 0.00228745) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.89095 ± 0.0140329 (W 0.00348439) | 1.8679 ± 0.011264 (W 0.00353834) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.7288 ± 0.0362344 (W 0.0230912) | 15.758 ± 0.0415595 (W 0.0194675) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7751 ± 0.0144727 (W 0.0147495) | 15.751 ± 0.0166779 (W 0.0204854) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.146974 ± 0.0011437 (W 0.00157327) | 0.146102 ± 0.000298001 (W 0.00165643) | 0.133228 ± 3.51188e-05 (W 0.00104095) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `lu/n256/b1` | 0.702998 ± 0.115525 (W 0.00246293) | 0.706074 ± 0.114569 (W 0.00361437) | 0.818864 ± 0.00270418 (W 0.00217529) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 6.14398 ± 0.008888 (W 0.0138715) | 6.15172 ± 0.0111624 (W 0.391888) | 5.20337 ± 0.00474041 (W 0.00371434) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.48913 ± 0.000501819 (W 0.00163662) | 0.491364 ± 0.00148777 (W 0.00206237) | 0.683185 ± 0.00248991 (W 0.00732179) | · | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 2.79147 ± 0.000938051 (W 0.0028721) | 2.79213 ± 0.00287686 (W 0.00367395) | 4.31205 ± 0.0103047 (W 0.0126089) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 19.8633 ± 0.029708 (W 0.0170237) | 19.7474 ± 0.0711946 (W 0.0294377) | 30.2737 ± 0.0492097 (W 0.0383596) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.277416 ± 0.0020624 (W 0.00181241) | 0.281255 ± 0.000660003 (W 0.00159014) | 0.333601 ± 0.00193618 (W 0.00226492) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.37025 ± 0.00558763 (W 0.00218353) | 1.38114 ± 0.00441223 (W 0.00215307) | 1.90012 ± 0.00242898 (W 0.0107233) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.00745 ± 0.0425226 (W 0.00349557) | 8.01161 ± 0.0294796 (W 0.00877455) | 13.3928 ± 0.0633499 (W 0.0231141) | · | 🔵 faer-fork 1.67× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.113782 ± 0.000404348 (W 0.00109017) | 0.114413 ± 0.000812099 (W 0.00138356) | 0.132287 ± 0.00035436 (W 0.00145448) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.666682 ± 0.00209149 (W 0.00278192) | 0.666713 ± 0.00641981 (W 0.00262483) | 0.815327 ± 0.00116056 (W 0.00241868) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 6.0853 ± 0.00600433 (W 0.0100602) | 6.08733 ± 0.0256411 (W 0.025895) | 5.2192 ± 0.0159344 (W 0.00953956) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67814 ± 0.00740151 (W 0.00398052) | 3.67438 ± 0.0121862 (W 0.0064562) | 3.31945 ± 0.0029833 (W 0.0138469) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 18.3591 ± 0.00708722 (W 0.0283102) | 18.3378 ± 0.0384043 (W 0.0174984) | 17.7772 ± 0.0243414 (W 0.0288378) | · | · |  |
| `svd_thin/n512/b1` | 105.14 ± 0.109168 (W 0.0548317) | 104.918 ± 0.259736 (W 0.394657) | 116.098 ± 0.710156 (W 0.231408) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.61874 ± 0.00722997 (W 0.000973449) | 2.6102 ± 0.00820258 (W 0.00272583) | 1.15684 ± 0.0016706 (W 0.00285814) | · | 🔴 faer-fork 2.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2925 ± 0.0112905 (W 0.00712187) | 12.279 ± 0.00674668 (W 0.0116438) | 6.82999 ± 0.0389849 (W 0.00947058) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.074 ± 0.167679 (W 0.41944) | 65.074 ± 0.133165 (W 0.0788791) | 47.4012 ± 0.235385 (W 0.0296403) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.005319 ± 0.000352649 (W 4.77001e-05) | 0.00502 ± 0.000140096 (W 6.55385e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013385 ± 0.000546932 (W 7.27276e-05) | 0.012624 ± 0.000283385 (W 7.66042e-05) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.045786 ± 0.00249136 (W 0.000128957) | 0.044533 ± 0.0020607 (W 0.000237372) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.078786 ± 0.00486235 (W 0.00167381) | 0.101679 ± 0.00136579 (W 0.00545157) | 0.093614 ± 0.00108739 (W 0.00164438) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.337448 ± 0.00882943 (W 0.027606) | 0.366063 ± 0.00906001 (W 0.0197745) | 0.243684 ± 0.00241472 (W 0.00285333) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 1.14546 ± 0.00180581 (W 0.0208848) | 1.20977 ± 0.0176867 (W 0.0343782) | 1.41172 ± 0.00485122 (W 0.00670076) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.29546 ± 0.0257214 (W 0.0128237) | 2.38028 ± 0.0606528 (W 0.0611681) | 1.04997 ± 0.00391 (W 0.00326159) | · | 🔴 faer-fork 2.19× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.95268 ± 0.0505164 (W 0.0612824) | 6.89626 ± 0.0493005 (W 0.0454273) | 4.67061 ± 0.031407 (W 0.00752094) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 25.6826 ± 0.184949 (W 0.0646735) | 25.6395 ± 0.195931 (W 0.112674) | 21.2461 ± 0.0200921 (W 0.032377) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.29044 ± 0.00179713 (W 0.0028153) | 0.290077 ± 0.00281618 (W 0.00175355) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61092 ± 0.00563871 (W 0.00736819) | 2.61576 ± 0.0117364 (W 0.0145799) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.8208 ± 0.0853982 (W 0.119127) | 16.9259 ± 0.142877 (W 0.167594) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.09607 ± 0.000542588 (W 0.0033354) | 0.083927 ± 0.000665974 (W 0.00231851) | - | 🔴 faer-fork 1.14× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.096721 ± 0.000587986 (W 0.00240276) | 0.086361 ± 0.000256028 (W 0.000387554) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.534586 ± 0.00448687 (W 0.00319949) | 0.519878 ± 0.00305295 (W 0.0031093) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.538735 ± 0.0048933 (W 0.00393256) | 0.528113 ± 0.00247935 (W 0.00216959) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.1273 ± 0.0112269 (W 0.0126746) | 4.08544 ± 0.0118456 (W 0.00827164) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.11605 ± 0.0192352 (W 0.00592886) | 4.11215 ± 0.0183937 (W 0.00766124) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.145641 ± 0.00145681 (W 0.00050275) | 0.22516 ± 0.00679898 (W 0.00542627) | 0.133529 ± 0.00043401 (W 0.000221247) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.709982 ± 0.119221 (W 0.00279045) | 0.851445 ± 0.124482 (W 0.0150479) | 0.325297 ± 0.00202604 (W 0.002689) | · | 🔴 faer-fork 2.18× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.36555 ± 0.0663094 (W 0.0734309) | 4.55386 ± 0.0313889 (W 0.0251951) | 1.63132 ± 0.00295179 (W 0.00307627) | · | 🔴 faer-fork 2.68× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.590139 ± 0.02897 (W 0.0203208) | 1.38904 ± 0.0187852 (W 0.0246307) | 0.455879 ± 0.00326013 (W 0.00346337) | 🔵 faer-fork 2.35× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr/n256/b1` | 1.86613 ± 0.015136 (W 0.0286068) | 3.68201 ± 0.0855756 (W 0.0732622) | 2.18388 ± 0.0102071 (W 0.00541822) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 9.6023 ± 0.983414 (W 0.078578) | 13.1358 ± 0.851179 (W 0.102683) | 13.0754 ± 0.0529418 (W 0.0218395) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n128/b1` | 0.361573 ± 0.00952119 (W 0.00827841) | 1.17469 ± 0.0273272 (W 0.018552) | 0.182991 ± 0.000117874 (W 0.00125011) | 🔵 faer-fork 3.25× faster than `faer-upstream` | 🔴 faer-fork 1.98× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 1.33 ± 0.0168507 (W 0.0261529) | 3.04091 ± 0.00954335 (W 0.05436) | 0.620729 ± 0.00363568 (W 0.00305541) | 🔵 faer-fork 2.29× faster than `faer-upstream` | 🔴 faer-fork 2.14× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.76472 ± 0.0158862 (W 0.0328771) | 8.47552 ± 0.0334404 (W 0.0587064) | 3.66411 ± 0.00241331 (W 0.00701038) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.113942 ± 0.00094237 (W 0.00171588) | 0.183712 ± 0.00287313 (W 0.00363143) | 0.133161 ± 0.000151186 (W 0.00122255) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.678984 ± 0.00202213 (W 0.00271001) | 0.7666 ± 0.00638159 (W 0.0170449) | 0.315354 ± 0.00657376 (W 0.00247353) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.21981 ± 0.0384927 (W 0.031642) | 4.36511 ± 0.0388795 (W 0.0554122) | 1.61761 ± 0.00558515 (W 0.00429314) | · | 🔴 faer-fork 2.61× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01928 ± 0.011665 (W 0.0114782) | 3.0078 ± 0.0209481 (W 0.0252626) | 2.59925 ± 0.00301973 (W 0.00587544) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.5967 ± 0.1145 (W 0.115319) | 13.5727 ± 0.0243864 (W 0.0254314) | 12.37 ± 0.0573923 (W 0.0142497) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.7551 ± 0.185407 (W 0.2738) | 60.6096 ± 0.254386 (W 0.331426) | 56.7624 ± 0.420967 (W 0.0807266) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.17394 ± 0.0372885 (W 0.00395502) | 2.17284 ± 0.0254669 (W 0.0090845) | 1.12406 ± 0.00429352 (W 0.00348036) | · | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.643 ± 0.0237339 (W 0.0351438) | 10.6309 ± 0.0156703 (W 0.0201801) | 6.09509 ± 0.0355728 (W 0.00716477) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.3319 ± 0.123061 (W 0.338081) | 47.3086 ± 0.259014 (W 0.337354) | 25.6132 ± 0.0264746 (W 0.0303219) | · | 🔴 faer-fork 1.85× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004699 ± 0.000259854 (W 5.61632e-05) | 0.004308 ± 0.000239166 (W 5.03607e-05) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012043 ± 0.000908949 (W 0.000151087) | 0.011412 ± 0.00092187 (W 3.39013e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.044723 ± 0.00416894 (W 0.000297469) | 0.039774 ± 0.00171384 (W 0.000459092) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.082935 ± 0.00109915 (W 0.00262402) | 0.099606 ± 0.00118339 (W 0.00312187) | 0.09084 ± 0.00166154 (W 0.00172754) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.334904 ± 0.00714212 (W 0.0255054) | 0.386496 ± 0.0112633 (W 0.0211167) | 0.197368 ± 0.00181819 (W 0.00405574) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.70× slower than `lapack-mkl` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 1.06981 ± 0.0145528 (W 0.0235515) | 1.18646 ± 0.00803633 (W 0.027633) | 0.948476 ± 0.00321465 (W 0.0143974) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.40733 ± 0.0178455 (W 0.0250369) | 2.32307 ± 0.0033817 (W 0.0298681) | 0.988744 ± 0.00687935 (W 0.00315103) | · | 🔴 faer-fork 2.43× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 6.84682 ± 0.01988 (W 0.0220068) | 7.03958 ± 0.0235968 (W 0.0413945) | 3.91156 ± 0.00606576 (W 0.0174107) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 23.8137 ± 0.0872296 (W 0.0431943) | 24.5411 ± 0.107586 (W 0.074776) | 14.854 ± 0.153612 (W 0.0322123) | · | 🔴 faer-fork 1.60× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.290271 ± 0.00168024 (W 0.00195686) | 0.289483 ± 0.000385697 (W 0.00267354) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61974 ± 0.00600031 (W 0.00957371) | 2.60767 ± 0.0137276 (W 0.00711327) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.6961 ± 0.0374995 (W 0.123039) | 16.743 ± 0.113479 (W 0.144557) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.071514 ± 0.00173484 (W 0.00212401) | 0.102282 ± 0.00197101 (W 0.00142844) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.070212 ± 0.000789538 (W 0.00386281) | 0.102922 ± 0.00118445 (W 0.00198618) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.296787 ± 0.00373705 (W 0.00100887) | 0.39958 ± 0.0116171 (W 0.01762) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.300514 ± 0.00254226 (W 0.00123253) | 0.38075 ± 0.00287964 (W 0.0170239) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.25065 ± 0.00764531 (W 0.00800523) | 2.61434 ± 0.130466 (W 0.226718) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.26965 ± 0.0297455 (W 0.0154866) | 2.6456 ± 0.1614 (W 0.251014) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.146776 ± 0.000952691 (W 0.00221516) | 0.24116 ± 0.0288701 (W 0.00563632) | 0.132737 ± 0.000106057 (W 0.00114262) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.710723 ± 0.117265 (W 0.00310236) | 0.902281 ± 0.113384 (W 0.0215465) | 0.317787 ± 0.00312308 (W 0.00213135) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 2.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 4.18472 ± 0.0270909 (W 0.0813699) | 4.75467 ± 0.068843 (W 0.0726931) | 1.22521 ± 0.00251082 (W 0.00662065) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 3.42× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.563929 ± 0.00334635 (W 0.00993127) | 1.90699 ± 0.00910035 (W 0.0325523) | 0.413221 ± 0.00329194 (W 0.0131213) | 🔵 faer-fork 3.38× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 1.70946 ± 0.0130556 (W 0.0125719) | 4.63795 ± 0.0356786 (W 0.0422377) | 2.01782 ± 0.00575858 (W 0.00682322) | 🔵 faer-fork 2.71× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 8.25833 ± 0.0753211 (W 0.0333296) | 14.721 ± 0.119982 (W 0.182301) | 10.2938 ± 0.0174349 (W 0.0220625) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.328452 ± 0.00668748 (W 0.00536659) | 1.58768 ± 0.0101044 (W 0.0206961) | 0.14468 ± 0.00057243 (W 0.00207186) | 🔵 faer-fork 4.83× faster than `faer-upstream` | 🔴 faer-fork 2.27× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.30007 ± 0.004497 (W 0.0106652) | 4.01146 ± 0.0754584 (W 0.0344181) | 0.539505 ± 0.0030323 (W 0.00295211) | 🔵 faer-fork 3.09× faster than `faer-upstream` | 🔴 faer-fork 2.41× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.47963 ± 0.0308158 (W 0.0264357) | 10.0965 ± 0.0722378 (W 0.0524564) | 2.1934 ± 0.00251924 (W 0.00270081) | 🔵 faer-fork 2.25× faster than `faer-upstream` | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.114294 ± 0.000697589 (W 0.00158898) | 0.190848 ± 0.00220116 (W 0.00291127) | 0.132037 ± 0.000365103 (W 0.000324159) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 0.68675 ± 0.00419527 (W 0.00349158) | 0.819186 ± 0.019935 (W 0.0269692) | 0.301151 ± 0.00156831 (W 0.00349555) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 4.08392 ± 0.0165954 (W 0.033093) | 4.59455 ± 0.0734105 (W 0.158556) | 1.20528 ± 0.00335395 (W 0.00304712) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 3.39× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.01317 ± 0.0146756 (W 0.00754703) | 3.07778 ± 0.0138831 (W 0.0183073) | 2.47527 ± 0.00727924 (W 0.00808988) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 13.3243 ± 0.00632358 (W 0.0500823) | 13.6383 ± 0.0668812 (W 0.0513178) | 11.3384 ± 0.00981661 (W 0.0260552) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 58.1753 ± 0.120157 (W 0.329097) | 59.8989 ± 0.0517906 (W 0.369666) | 47.7099 ± 0.223655 (W 0.0729669) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.15598 ± 0.0315699 (W 0.00224914) | 2.1511 ± 0.0331332 (W 0.00514631) | 1.11881 ± 0.00347603 (W 0.00211546) | · | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 10.8014 ± 0.0121214 (W 0.025168) | 10.7597 ± 0.0055716 (W 0.0175363) | 5.9925 ± 0.00398658 (W 0.0104473) | · | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 48.4201 ± 0.294931 (W 0.418432) | 48.2828 ± 0.233614 (W 0.530692) | 22.3139 ± 0.0366356 (W 0.0269212) | · | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.004949 ± 0.000245162 (W 1.35757e-05) | 0.004247 ± 9.17624e-05 (W 4.42854e-05) | - | 🔴 faer-fork 1.17× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012103 ± 0.000912503 (W 7.30363e-05) | 0.011271 ± 0.000854543 (W 6.59871e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.045686 ± 0.00529941 (W 0.000613611) | 0.043722 ± 0.00243476 (W 0.00115784) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188872 ± 0.000139105 (W 0.00161357) | 0.187419 ± 0.000997448 (W 0.00128207) | 0.475687 ± 0.00306363 (W 0.00443921) | · | 🔵 faer-fork 2.52× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.22141 ± 0.0120843 (W 0.00368381) | 1.2237 ± 0.00198436 (W 0.00314126) | 1.85052 ± 0.0178208 (W 0.0057229) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.91838 ± 0.137059 (W 0.0143665) | 7.91821 ± 0.0152102 (W 0.0141463) | 11.3994 ± 0.0120217 (W 0.0207337) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.27223 ± 0.00488089 (W 0.00631877) | 3.26687 ± 0.00674136 (W 0.00225549) | 4.41537 ± 0.00958833 (W 0.00732363) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.4369 ± 0.0744364 (W 0.00984108) | 17.413 ± 0.0439425 (W 0.0110927) | 26.4491 ± 0.0417084 (W 0.0269701) | · | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.642 ± 0.181664 (W 0.104136) | 105.477 ± 0.332088 (W 0.300557) | 171.371 ± 0.198169 (W 0.233508) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.778488 ± 0.0377895 (W 0.00681401) | 0.780855 ± 0.00387097 (W 0.0046109) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.9346 ± 0.172536 (W 0.00507113) | 6.07535 ± 0.0221786 (W 0.00612953) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n512/b1` | 40.6916 ± 0.605546 (W 0.0652021) | 41.3818 ± 0.276252 (W 0.0248691) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.04745 ± 0.000710589 (W 0.00105321) | 1.04539 ± 0.000566495 (W 0.000875017) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.0537 ± 0.000442098 (W 0.000790322) | 1.05585 ± 0.0038103 (W 0.000959105) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49887 ± 0.00353896 (W 0.00585838) | 7.49688 ± 0.00821708 (W 0.00633367) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52895 ± 0.0145152 (W 0.00661431) | 7.50595 ± 0.00442202 (W 0.00671712) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8817 ± 0.0799291 (W 0.0588569) | 56.8272 ± 0.0751022 (W 0.0427962) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.9121 ± 0.0387381 (W 0.402559) | 56.9031 ± 0.0420653 (W 0.410544) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.335706 ± 0.00043222 (W 0.00241268) | 0.340966 ± 0.00381869 (W 0.00274113) | 0.502084 ± 0.00178675 (W 0.00264601) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.15399 ± 0.00496737 (W 0.0021822) | 2.25438 ± 0.0012287 (W 0.00540876) | 3.32181 ± 0.0283461 (W 0.00691246) | · | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 14.762 ± 0.0325768 (W 0.0283209) | 15.0224 ± 0.0602192 (W 0.0266844) | 21.1444 ± 0.0757312 (W 0.0410768) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.57549 ± 0.00228705 (W 0.00185178) | 1.57656 ± 0.00143047 (W 0.00306132) | 2.00091 ± 0.00466184 (W 0.00379895) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.2066 ± 0.0139253 (W 0.00906372) | 10.302 ± 0.0100649 (W 0.00872764) | 12.3661 ± 0.011844 (W 0.0188764) | · | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 69.8057 ± 0.0874263 (W 0.408115) | 69.9261 ± 0.0742472 (W 0.0520743) | 80.7412 ± 0.17122 (W 0.0721672) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.816924 ± 0.00873474 (W 0.00198456) | 1.06505 ± 0.00278392 (W 0.00163952) | 0.95485 ± 0.00202742 (W 0.00210467) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.83768 ± 0.0119526 (W 0.0017693) | 6.42794 ± 0.0110052 (W 0.0124901) | 5.67139 ± 0.00713071 (W 0.0130698) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.6835 ± 0.0367827 (W 0.0287428) | 37.5535 ± 0.232404 (W 0.0246489) | 39.1288 ± 0.068103 (W 0.0782609) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.33278 ± 0.00241063 (W 0.0020326) | 0.33772 ± 0.0033322 (W 0.00328161) | 0.491075 ± 0.0014762 (W 0.00257506) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 2.0874 ± 0.0112835 (W 0.00228585) | 2.18561 ± 0.00893787 (W 0.00363337) | 2.83175 ± 0.00478256 (W 0.00917604) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.8126 ± 0.0811736 (W 0.0249692) | 15.0205 ± 0.0492174 (W 0.0210763) | 18.816 ± 0.0274537 (W 0.026565) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.76318 ± 0.0111451 (W 0.0117036) | 5.74574 ± 0.012125 (W 0.0120946) | 7.05325 ± 0.00511196 (W 0.00645228) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 34.2322 ± 0.0386636 (W 0.0541539) | 34.2232 ± 0.104177 (W 0.0680773) | 43.8008 ± 0.174216 (W 0.0705229) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 212.258 ± 0.348833 (W 0.400194) | 212.571 ± 0.944198 (W 0.306434) | 278.327 ± 1.71152 (W 0.520037) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.48162 ± 0.00860429 (W 0.00523775) | 3.47149 ± 0.00852857 (W 0.00714388) | 2.75625 ± 0.00861448 (W 0.00377682) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.3964 ± 0.0634161 (W 0.0882359) | 19.4543 ± 0.0145912 (W 0.0642111) | 18.1192 ± 0.0301552 (W 0.0166516) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 112.08 ± 0.435221 (W 0.159385) | 111.911 ± 0.556686 (W 0.291462) | 123.192 ± 1.51204 (W 0.141542) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008155 ± 2.6839e-05 (W 2.63097e-05) | 0.007584 ± 6.08276e-05 (W 4.46565e-05) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025317 ± 0.000300112 (W 9.38786e-05) | 0.024335 ± 0.000244199 (W 0.000152847) | - | · | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.086521 ± 0.00158815 (W 0.000506623) | 0.084127 ± 0.00200007 (W 0.00194645) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.189984 ± 0.00183078 (W 0.00341889) | 0.199973 ± 0.00498106 (W 0.00562614) | 0.47826 ± 0.00333166 (W 0.00496603) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 2.52× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.83511 ± 0.00691861 (W 0.00982802) | 0.873369 ± 0.0088404 (W 0.0126805) | 0.796609 ± 0.0075929 (W 0.0081963) | · | · |  |
| `cholesky/n512/b1` | 3.34263 ± 0.00590632 (W 0.0177001) | 3.41117 ± 0.0243433 (W 0.022111) | 3.65549 ± 0.0149484 (W 0.0188885) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.9686 ± 0.0244032 (W 0.0168085) | 2.96647 ± 0.0362002 (W 0.0159501) | 2.04789 ± 0.00369744 (W 0.00550274) | · | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.4716 ± 0.0257291 (W 0.0693073) | 11.4122 ± 0.0429296 (W 0.043833) | 10.1786 ± 0.0236458 (W 0.023355) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.4997 ± 0.0681706 (W 0.131833) | 46.3869 ± 0.11537 (W 0.130976) | 53.2267 ± 0.10864 (W 0.0353742) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.768912 ± 0.00289133 (W 0.00683123) | 0.777948 ± 0.00516834 (W 0.00514928) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.89376 ± 0.0149682 (W 0.0105805) | 6.06849 ± 0.0312907 (W 0.0337104) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.906 ± 0.0720688 (W 0.117969) | 27.2498 ± 0.145189 (W 0.0614294) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.28741 ± 0.00050898 (W 0.00163799) | 0.286565 ± 0.000774843 (W 0.00173972) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.294058 ± 0.00376662 (W 0.00179264) | 0.290592 ± 0.00152475 (W 0.0018738) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.95642 ± 0.00459246 (W 0.00721447) | 1.93171 ± 0.00682424 (W 0.0034697) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93391 ± 0.00320777 (W 0.00326984) | 1.92945 ± 0.00409781 (W 0.0028283) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7425 ± 0.0427194 (W 0.018817) | 14.6589 ± 0.0342357 (W 0.0187313) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.7933 ± 0.015271 (W 0.0181296) | 14.7403 ± 0.0623871 (W 0.0168129) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.336166 ± 0.000398221 (W 0.00151611) | 0.352457 ± 0.0038002 (W 0.00661423) | 0.483389 ± 0.000758044 (W 0.00180688) | · | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.56383 ± 0.00433034 (W 0.0134303) | 1.72567 ± 0.00265752 (W 0.0184793) | 1.02002 ± 0.000793213 (W 0.00290902) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 7.30594 ± 0.0349573 (W 0.0239708) | 7.58404 ± 0.0611667 (W 0.0280961) | 6.14304 ± 0.0203454 (W 0.0234535) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 1.02242 ± 0.00205408 (W 0.00212143) | 1.93923 ± 0.00749613 (W 0.024254) | 1.04069 ± 0.000242469 (W 0.00260785) | 🔵 faer-fork 1.90× faster than `faer-upstream` | · |  |
| `qr/n256/b1` | 4.57866 ± 0.0184411 (W 0.0658379) | 6.32597 ± 0.0656224 (W 0.0753109) | 4.81007 ± 0.0202252 (W 0.00858927) | 🔵 faer-fork 1.38× faster than `faer-upstream` | · |  |
| `qr/n512/b1` | 23.3624 ± 0.0557948 (W 0.106231) | 26.7979 ± 0.0887104 (W 0.0581972) | 28.6665 ± 0.0856782 (W 0.0302111) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.607211 ± 0.0045002 (W 0.00258692) | 1.81646 ± 0.00391963 (W 0.014494) | 0.456311 ± 0.000727585 (W 0.00243725) | 🔵 faer-fork 2.99× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.94787 ± 0.0169085 (W 0.0360732) | 7.41195 ± 0.147618 (W 0.0421367) | 1.63735 ± 0.00313507 (W 0.00572302) | 🔵 faer-fork 2.51× faster than `faer-upstream` | 🔴 faer-fork 1.80× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 12.0376 ± 0.0875451 (W 0.0455428) | 26.6515 ± 0.306284 (W 0.129333) | 11.4303 ± 0.0204979 (W 0.0161556) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.332459 ± 0.00279771 (W 0.00150865) | 0.33764 ± 0.00715382 (W 0.0119431) | 0.468764 ± 0.000392954 (W 0.00270123) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.431 ± 0.00189016 (W 0.00968002) | 1.60421 ± 0.0147327 (W 0.0204701) | 0.898316 ± 0.00421211 (W 0.00400539) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 7.21851 ± 0.0457845 (W 0.0388203) | 7.45092 ± 0.0357239 (W 0.0242282) | 5.64258 ± 0.0146463 (W 0.0121495) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.34673 ± 0.013488 (W 0.0216855) | 4.3595 ± 0.00373389 (W 0.0218739) | 4.1717 ± 0.00423142 (W 0.00792215) | · | · |  |
| `svd_thin/n256/b1` | 22.7255 ± 0.106243 (W 0.102374) | 22.7453 ± 0.0591411 (W 0.101655) | 21.2928 ± 0.0523641 (W 0.0144224) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 95.0295 ± 0.167126 (W 0.354024) | 95.1541 ± 0.254978 (W 0.243488) | 113.988 ± 0.74059 (W 0.0882541) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.05293 ± 0.00648201 (W 0.00946347) | 3.04014 ± 0.0168919 (W 0.0110897) | 2.02193 ± 0.0180468 (W 0.00311687) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.1056 ± 0.0617463 (W 0.0779249) | 17.1591 ± 0.0345607 (W 0.0760238) | 11.0568 ± 0.0845291 (W 0.0107596) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 65.3262 ± 0.17602 (W 0.22609) | 65.1695 ± 0.239977 (W 0.381723) | 55.9152 ± 0.0751764 (W 0.0779297) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008155 ± 2.0664e-05 (W 3.64993e-05) | 0.007594 ± 2.08167e-05 (W 4.36486e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024565 ± 0.00012822 (W 6.30079e-05) | 0.023314 ± 0.000254901 (W 6.38295e-05) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.072176 ± 0.000299457 (W 0.000777795) | 0.068578 ± 0.00146872 (W 0.000951207) | - | 🔴 faer-fork 1.05× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.194293 ± 0.00109816 (W 0.00336018) | 0.213668 ± 0.0027371 (W 0.00325005) | 0.479965 ± 0.00255591 (W 0.00383539) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 2.47× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.814237 ± 0.00403802 (W 0.010969) | 0.873718 ± 0.0107889 (W 0.0181473) | 0.657824 ± 0.00307225 (W 0.00422349) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.73983 ± 0.0073568 (W 0.0231478) | 2.85783 ± 0.0113735 (W 0.0195136) | 2.27422 ± 0.0337596 (W 0.007037) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.90628 ± 0.0468941 (W 0.0198496) | 3.01272 ± 0.0117827 (W 0.0206029) | 1.69776 ± 0.00373319 (W 0.00532361) | · | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.8209 ± 0.00503085 (W 0.0250558) | 11.1492 ± 0.0265452 (W 0.0236619) | 8.03251 ± 0.0291146 (W 0.0102954) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 39.1356 ± 0.077997 (W 0.0922247) | 40.0752 ± 0.134705 (W 0.178139) | 36.8593 ± 0.143881 (W 0.0457502) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.771148 ± 0.0058203 (W 0.00596516) | 0.777791 ± 0.00406096 (W 0.00728117) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.88873 ± 0.0123645 (W 0.005547) | 6.04246 ± 0.00658589 (W 0.0151749) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 25.3517 ± 0.107841 (W 0.166537) | 25.5596 ± 0.112271 (W 0.0478237) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.183172 ± 0.000608651 (W 0.00102626) | 0.270026 ± 0.00281148 (W 0.00268172) | - | 🔵 faer-fork 1.47× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.184053 ± 0.00288515 (W 0.00205178) | 0.27347 ± 0.00140775 (W 0.00428142) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.01137 ± 0.0031917 (W 0.0035843) | 1.29035 ± 0.0145787 (W 0.0801308) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01137 ± 0.00165805 (W 0.00324824) | 1.28129 ± 0.00704481 (W 0.0721554) | - | 🔵 faer-fork 1.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.13516 ± 0.0219594 (W 0.0457226) | 8.76673 ± 0.0321924 (W 0.571197) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.12972 ± 0.0815091 (W 0.0842711) | 8.76057 ± 0.506761 (W 0.536001) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.337048 ± 0.00208453 (W 0.00183799) | 0.376011 ± 0.00573982 (W 0.00414329) | 0.486944 ± 0.000654309 (W 0.0025001) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.44× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.50063 ± 0.00529346 (W 0.0148497) | 1.71943 ± 0.00786806 (W 0.0200257) | 0.691139 ± 0.00203931 (W 0.00515578) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |
| `lu/n512/b1` | 6.16273 ± 0.0266321 (W 0.0464132) | 6.56994 ± 0.0125454 (W 0.0422333) | 3.59793 ± 0.0104331 (W 0.00677424) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.984507 ± 0.00728005 (W 0.0138224) | 2.47174 ± 0.00564071 (W 0.0275609) | 0.784221 ± 0.00157959 (W 0.00368342) | 🔵 faer-fork 2.51× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.50018 ± 0.038716 (W 0.0189156) | 6.96003 ± 0.0145226 (W 0.0405046) | 3.83986 ± 0.0127331 (W 0.00629542) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 16.0239 ± 0.0279535 (W 0.0352522) | 23.3972 ± 0.195725 (W 0.170649) | 16.0716 ± 0.0734545 (W 0.0236329) | 🔵 faer-fork 1.46× faster than `faer-upstream` | · |  |
| `qr_factor/n128/b1` | 0.62354 ± 0.0041902 (W 0.00470029) | 2.3139 ± 0.00165412 (W 0.0259112) | 0.323447 ± 0.00165363 (W 0.00193533) | 🔵 faer-fork 3.71× faster than `faer-upstream` | 🔴 faer-fork 1.93× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.44257 ± 0.0161968 (W 0.0179238) | 8.57661 ± 0.0931705 (W 0.0480611) | 1.62625 ± 0.00323419 (W 0.00459889) | 🔵 faer-fork 3.51× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.34703 ± 0.0496579 (W 0.0176192) | 27.6397 ± 0.237765 (W 0.184883) | 5.81643 ± 0.0096699 (W 0.0148624) | 🔵 faer-fork 2.96× faster than `faer-upstream` | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.33269 ± 0.00185353 (W 0.00243266) | 0.363979 ± 0.00511264 (W 0.00382285) | 0.472126 ± 0.000139632 (W 0.00235482) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.35921 ± 0.0151689 (W 0.0168935) | 1.5624 ± 0.0118441 (W 0.0224397) | 0.66604 ± 0.00290594 (W 0.00347098) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 2.04× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.00932 ± 0.0359961 (W 0.0548217) | 6.38895 ± 0.0123313 (W 0.0649285) | 3.44188 ± 0.00948113 (W 0.006214) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.25103 ± 0.00734717 (W 0.0203819) | 4.47927 ± 0.0141142 (W 0.032312) | 3.64768 ± 0.0151397 (W 0.00660161) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.4153 ± 0.124605 (W 0.0811586) | 22.0922 ± 0.0744109 (W 0.0913565) | 17.1978 ± 0.0142627 (W 0.019845) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.453 ± 0.172908 (W 0.294467) | 82.0785 ± 0.197293 (W 0.320187) | 84.3266 ± 0.402343 (W 0.0597509) | · | · |  |
| `svd_values/n128/b1` | 3.08607 ± 0.0272883 (W 0.0174328) | 3.08021 ± 0.0267728 (W 0.00901782) | 1.91715 ± 0.00262485 (W 0.00372049) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.3222 ± 0.0925244 (W 0.0515973) | 17.2991 ± 0.0580017 (W 0.0582014) | 9.67009 ± 0.0323052 (W 0.0141439) | · | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 61.1411 ± 0.218303 (W 0.256704) | 61.3966 ± 0.153426 (W 0.143475) | 43.0477 ± 0.254093 (W 0.0393433) | · | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008146 ± 3.76431e-05 (W 4.63066e-05) | 0.007615 ± 4.09512e-05 (W 2.10071e-05) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024846 ± 0.000107286 (W 0.00010268) | 0.023544 ± 8.544e-05 (W 0.0001096) | - | 🔴 faer-fork 1.06× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.078446 ± 0.00448295 (W 0.00199869) | 0.072045 ± 0.00410765 (W 0.00276067) | - | 🔴 faer-fork 1.09× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.175838 ± 0.000976732 (W 0.00178345) | 0.174535 ± 0.000787259 (W 0.0011493) | 0.410133 ± 0.00204208 (W 0.00258113) | · | 🔵 faer-fork 2.33× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 1.13076 ± 0.00115297 (W 0.0015209) | 1.13089 ± 0.00294074 (W 0.000857378) | 1.59942 ± 0.0106804 (W 0.00473368) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `cholesky/n512/b1` | 7.5456 ± 0.0137922 (W 0.00783078) | 7.53745 ± 0.014072 (W 0.00760573) | 12.0768 ± 0.00821507 (W 0.0124434) | · | 🔵 faer-fork 1.60× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 3.2638 ± 0.00428289 (W 0.00368074) | 3.25725 ± 0.00827169 (W 0.00200275) | 4.36033 ± 0.00718095 (W 0.00478316) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `eigh/n256/b1` | 17.3603 ± 0.0507447 (W 0.011465) | 17.3259 ± 0.0200417 (W 0.0113722) | 26.1831 ± 0.0200427 (W 0.0199362) | · | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `eigh/n512/b1` | 105.286 ± 0.118778 (W 0.0410653) | 105.063 ± 0.35795 (W 0.0491759) | 170.12 ± 0.230486 (W 0.200664) | · | 🔵 faer-fork 1.62× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.751571 ± 0.0372258 (W 0.00593772) | 0.749368 ± 0.00689192 (W 0.00418629) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n256/b1` | 5.79467 ± 0.180106 (W 0.00934476) | 5.80652 ± 0.0115122 (W 0.00760436) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/n512/b1` | 40.2508 ± 0.673719 (W 0.0528405) | 40.2308 ± 0.270822 (W 0.0474055) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03815 ± 0.00305272 (W 0.00127134) | 1.0378 ± 0.00340643 (W 0.000746205) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.03955 ± 0.00188436 (W 0.00113692) | 1.03882 ± 0.00176402 (W 0.000872061) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.38971 ± 0.0101467 (W 0.0100126) | 7.39827 ± 0.014586 (W 0.00510245) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.40585 ± 0.00658817 (W 0.00591467) | 7.42863 ± 0.0177007 (W 0.00883829) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.7223 ± 0.0785879 (W 0.0514438) | 56.6918 ± 0.0231588 (W 0.0571288) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.6919 ± 0.0706876 (W 0.065129) | 56.7206 ± 0.0530193 (W 0.195407) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.307543 ± 0.000605735 (W 0.00230623) | 0.30531 ± 0.000192204 (W 0.00206764) | 0.459486 ± 0.00162029 (W 0.00128055) | · | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 2.04225 ± 0.003694 (W 0.00748547) | 2.03801 ± 0.00324261 (W 0.00239775) | 3.15585 ± 0.00222216 (W 0.00693952) | · | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |
| `lu/n512/b1` | 14.0077 ± 0.0495884 (W 0.0157381) | 13.9999 ± 0.0388876 (W 0.014789) | 19.7639 ± 0.0154065 (W 0.0197198) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `qr/n128/b1` | 1.55124 ± 0.00206505 (W 0.00324602) | 1.54301 ± 0.000400238 (W 0.00291008) | 1.97062 ± 0.001308 (W 0.00343681) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 10.0851 ± 0.033805 (W 0.0082286) | 10.0826 ± 0.0329676 (W 0.00594408) | 12.3416 ± 0.0124868 (W 0.0217594) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 68.9918 ± 0.0376001 (W 0.0393611) | 68.9277 ± 0.104561 (W 0.0310806) | 79.9004 ± 0.139868 (W 0.361972) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.744869 ± 0.00111254 (W 0.00218664) | 0.743457 ± 0.00265135 (W 0.00139877) | 0.911887 ± 0.000882775 (W 0.00256444) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.47418 ± 0.0109667 (W 0.00383476) | 4.48529 ± 0.0146966 (W 0.0048992) | 5.51162 ± 0.024977 (W 0.00907755) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.9831 ± 0.01373 (W 0.0180993) | 29.0804 ± 0.0603726 (W 0.0228692) | 37.9507 ± 0.0447781 (W 0.0455354) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `solve/n128/b1` | 0.30586 ± 0.0016504 (W 0.00151905) | 0.303005 ± 0.000966865 (W 0.00205847) | 0.446473 ± 0.000856461 (W 0.0021828) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.97726 ± 0.00744703 (W 0.00191088) | 1.97517 ± 0.00395197 (W 0.00147668) | 2.66288 ± 0.00218347 (W 0.0108152) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `solve/n512/b1` | 14.0019 ± 0.0181828 (W 0.020565) | 14 ± 0.0165816 (W 0.0160273) | 18.0298 ± 0.0205189 (W 0.0285891) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.72242 ± 0.00560029 (W 0.00819586) | 5.71111 ± 0.0105207 (W 0.0105231) | 6.95824 ± 0.0124986 (W 0.0051449) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 33.9037 ± 0.0597639 (W 0.0631579) | 33.9851 ± 0.0443903 (W 0.0674703) | 42.9578 ± 0.273077 (W 0.031251) | · | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 210.934 ± 0.344075 (W 0.332934) | 211.203 ± 0.550757 (W 0.231353) | 308.141 ± 0.643295 (W 0.849072) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.45269 ± 0.00397364 (W 0.00667043) | 3.45614 ± 0.0100025 (W 0.023108) | 2.71523 ± 0.00923996 (W 0.00403659) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 19.0817 ± 0.0550287 (W 0.0558632) | 19.1963 ± 0.0369798 (W 0.0701739) | 17.9568 ± 0.00649593 (W 0.0141659) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 110.892 ± 0.580567 (W 0.360076) | 111.147 ± 0.539351 (W 0.236719) | 151.218 ± 0.436981 (W 0.129265) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.007564 ± 0.000605002 (W 5.71778e-05) | 0.007153 ± 0.000675253 (W 2.6857e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.025457 ± 0.00148087 (W 0.000119768) | 0.024837 ± 0.00170909 (W 0.00143153) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.091821 ± 0.00310005 (W 0.00173268) | 0.085219 ± 0.00456106 (W 0.000641892) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176762 ± 0.000582694 (W 0.00177049) | 0.188601 ± 0.0025852 (W 0.00404092) | 0.407429 ± 0.000793643 (W 0.00299591) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 2.30× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.745452 ± 0.000511107 (W 0.007359) | 0.782539 ± 0.00314991 (W 0.0127259) | 0.586704 ± 0.000937083 (W 0.00875671) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.97012 ± 0.00340168 (W 0.0192215) | 3.03958 ± 0.00938113 (W 0.0213639) | 3.22529 ± 0.0171313 (W 0.0174991) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.97943 ± 0.0169477 (W 0.0209111) | 2.94234 ± 0.0221136 (W 0.0285072) | 2.00476 ± 0.00564798 (W 0.00470873) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 11.3876 ± 0.00727456 (W 0.0611942) | 11.3167 ± 0.0759479 (W 0.0489958) | 9.97642 ± 0.0332633 (W 0.0143768) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 46.221 ± 0.162016 (W 0.173114) | 46.0755 ± 0.0241012 (W 0.125649) | 52.5739 ± 0.122866 (W 0.0344604) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.741865 ± 0.00177832 (W 0.00689689) | 0.743729 ± 0.0027161 (W 0.00705739) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.75416 ± 0.0132337 (W 0.0236273) | 5.75162 ± 0.0487999 (W 0.0149965) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 26.1426 ± 0.0624407 (W 0.0399624) | 26.2753 ± 0.154525 (W 0.16232) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.295891 ± 0.00348183 (W 0.00274657) | 0.28756 ± 0.00208164 (W 0.000953811) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.301467 ± 0.000465532 (W 0.00352516) | 0.292625 ± 0.00199384 (W 0.00132206) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.93324 ± 0.00568641 (W 0.00627478) | 1.92688 ± 0.00520215 (W 0.00417091) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92774 ± 0.00394962 (W 0.00485391) | 1.92664 ± 0.00472604 (W 0.00411627) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7715 ± 0.0185244 (W 0.0283225) | 14.7116 ± 0.027931 (W 0.0409749) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.8067 ± 0.0348596 (W 0.0146685) | 14.8188 ± 0.0895544 (W 0.0142477) | - | · | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.308145 ± 0.001122 (W 0.002058) | 0.322356 ± 0.0020314 (W 0.00575089) | 0.456148 ± 0.00146521 (W 0.0018381) | · | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.45174 ± 0.074049 (W 0.0176785) | 1.51711 ± 0.00086553 (W 0.0164378) | 0.977393 ± 0.00221763 (W 0.00233886) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n512/b1` | 6.55229 ± 0.00691373 (W 0.0379682) | 6.69832 ± 0.0382565 (W 0.0445658) | 5.84912 ± 0.0430462 (W 0.0206488) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.998609 ± 0.0014972 (W 0.00172223) | 1.88916 ± 0.0179017 (W 0.011811) | 1.06327 ± 0.00917829 (W 0.00175905) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `qr/n256/b1` | 4.47092 ± 0.0276087 (W 0.0409391) | 6.02849 ± 0.0524468 (W 0.0425985) | 5.03584 ± 0.0180052 (W 0.00546523) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 22.4964 ± 0.11195 (W 0.0501827) | 25.9144 ± 0.0430282 (W 0.105777) | 29.0951 ± 0.103935 (W 0.0400381) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.551898 ± 0.00627653 (W 0.0032668) | 1.42246 ± 0.00435136 (W 0.0135844) | 0.437663 ± 0.00156941 (W 0.00188973) | 🔵 faer-fork 2.58× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.78401 ± 0.0355898 (W 0.0505786) | 4.33482 ± 0.00973489 (W 0.0292) | 1.57715 ± 0.00160048 (W 0.00317543) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.3804 ± 0.0321537 (W 0.0770765) | 14.7867 ± 0.0276586 (W 0.0728702) | 11.0366 ± 0.0125981 (W 0.0122923) | 🔵 faer-fork 1.30× faster than `faer-upstream` | · |  |
| `solve/n128/b1` | 0.304663 ± 0.000462225 (W 0.00227677) | 0.313304 ± 0.000794501 (W 0.00375594) | 0.449066 ± 0.0010865 (W 0.00296163) | · | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.3203 ± 0.0115384 (W 0.00967944) | 1.39838 ± 0.0160489 (W 0.012291) | 0.863629 ± 0.000818766 (W 0.0034385) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 6.44779 ± 0.00180398 (W 0.031882) | 6.54016 ± 0.0276297 (W 0.0321278) | 5.34096 ± 0.0129972 (W 0.00801403) | · | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.32639 ± 0.0131699 (W 0.0286381) | 4.33955 ± 0.0238469 (W 0.0309376) | 4.11282 ± 0.00455787 (W 0.0075062) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 22.3854 ± 0.0870845 (W 0.0367454) | 22.4227 ± 0.0724952 (W 0.047579) | 21.0581 ± 0.0660826 (W 0.0192295) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.0181 ± 0.16726 (W 0.48883) | 94.0073 ± 0.1341 (W 0.293254) | 112.222 ± 0.85561 (W 0.317885) | · | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 3.05684 ± 0.0261109 (W 0.0100269) | 3.01023 ± 0.0157283 (W 0.0101682) | 2.00986 ± 0.00359081 (W 0.00421139) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 16.9252 ± 0.0631061 (W 0.0956405) | 16.8618 ± 0.0210154 (W 0.040867) | 10.9975 ± 0.0364625 (W 0.0222143) | · | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 64.4946 ± 0.268662 (W 0.294086) | 64.1822 ± 0.116782 (W 0.132441) | 55.7253 ± 0.133371 (W 0.0908143) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008055 ± 0.000372219 (W 2.41102e-05) | 0.008155 ± 0.000621613 (W 2.42322e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.021319 ± 0.00341022 (W 7.03562e-05) | 0.020789 ± 0.0034867 (W 8.089e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.076091 ± 0.000417661 (W 0.000876113) | 0.073286 ± 0.0041626 (W 0.00169312) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n128/b1` | 0.182573 ± 0.00107123 (W 0.00349776) | 0.199561 ± 0.00213263 (W 0.00348233) | 0.408811 ± 0.000787305 (W 0.0032538) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 2.24× faster than `lapack-mkl` |  |
| `cholesky/n256/b1` | 0.73017 ± 0.00565266 (W 0.0123064) | 0.783992 ± 0.0105748 (W 0.0204667) | 0.461536 ± 0.00251501 (W 0.00297782) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `cholesky/n512/b1` | 2.38416 ± 0.00165234 (W 0.018845) | 2.49833 ± 0.00628117 (W 0.0231117) | 1.84818 ± 0.0264345 (W 0.0119557) | · | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `eigh/n128/b1` | 2.90268 ± 0.0107131 (W 0.0313998) | 2.99801 ± 0.0149963 (W 0.0128167) | 1.65718 ± 0.00845554 (W 0.00453811) | · | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `eigh/n256/b1` | 10.761 ± 0.0312405 (W 0.0424812) | 11.0565 ± 0.0716986 (W 0.0342024) | 7.88071 ± 0.00455774 (W 0.00818615) | · | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `eigh/n512/b1` | 38.8007 ± 0.0630233 (W 0.0770969) | 39.7411 ± 0.0730918 (W 0.240503) | 36.4883 ± 0.0657789 (W 0.0259615) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `full_piv_lu/n128/b1` | 0.745439 ± 0.00290211 (W 0.00616131) | 0.744638 ± 0.00696925 (W 0.00347633) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.74541 ± 0.0143351 (W 0.0148926) | 5.77373 ± 0.0266556 (W 0.0117239) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 24.5195 ± 0.111887 (W 0.0792494) | 24.4947 ± 0.133913 (W 0.0690049) | - | · | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.195384 ± 0.00196717 (W 0.00201263) | 0.277578 ± 0.000682041 (W 0.00107061) | - | 🔵 faer-fork 1.42× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.197611 ± 0.000845099 (W 0.00254628) | 0.27702 ± 0.000798377 (W 0.00262793) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.02139 ± 0.00320854 (W 0.00531976) | 1.28331 ± 0.00528446 (W 0.0131485) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.02131 ± 0.005078 (W 0.0036681) | 1.28422 ± 0.00372563 (W 0.011531) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.1835 ± 0.0761345 (W 0.0327994) | 8.75739 ± 0.481791 (W 0.491731) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.21306 ± 0.0171785 (W 0.0456926) | 8.15822 ± 0.419999 (W 0.487491) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/n128/b1` | 0.307287 ± 0.00182731 (W 0.00232604) | 0.347447 ± 0.00539129 (W 0.00580292) | 0.4563 ± 0.00227597 (W 0.00242952) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.48× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.38341 ± 0.291895 (W 0.0123071) | 1.50366 ± 0.0294235 (W 0.0135849) | 0.680658 ± 0.00324196 (W 0.00253496) | · | 🔴 faer-fork 2.03× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n512/b1` | 5.39065 ± 0.0199508 (W 0.0255999) | 5.69775 ± 0.0194174 (W 0.0278138) | 3.47369 ± 0.0105898 (W 0.0106243) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `qr/n128/b1` | 0.960531 ± 0.00417389 (W 0.0112018) | 2.42846 ± 0.0185342 (W 0.0176942) | 0.804911 ± 0.00464505 (W 0.00863232) | 🔵 faer-fork 2.53× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/n256/b1` | 3.33859 ± 0.0212001 (W 0.210305) | 6.75246 ± 0.0752914 (W 0.0552537) | 4.07161 ± 0.014921 (W 0.00971808) | 🔵 faer-fork 2.02× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr/n512/b1` | 15.1199 ± 0.0140907 (W 0.0501396) | 22.3863 ± 0.104791 (W 0.196544) | 17.0223 ± 0.0351656 (W 0.0248232) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `qr_factor/n128/b1` | 0.563551 ± 0.00123953 (W 0.00373665) | 1.88843 ± 0.0249994 (W 0.0363387) | 0.30639 ± 0.00107095 (W 0.0017245) | 🔵 faer-fork 3.35× faster than `faer-upstream` | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.30171 ± 0.00888354 (W 0.0217754) | 5.35194 ± 0.0104883 (W 0.0399521) | 1.584 ± 0.00363672 (W 0.00250429) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 1.45× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.77388 ± 0.0106513 (W 0.0327587) | 14.865 ± 0.0746181 (W 0.154995) | 5.61431 ± 0.0109801 (W 0.00797366) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `solve/n128/b1` | 0.305108 ± 0.00175306 (W 0.00191308) | 0.337649 ± 0.00450051 (W 0.00482171) | 0.447024 ± 0.00118601 (W 0.00253694) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `solve/n256/b1` | 1.24805 ± 0.013313 (W 0.0110442) | 1.35079 ± 0.00215849 (W 0.0210213) | 0.650821 ± 0.00438222 (W 0.00311034) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `solve/n512/b1` | 5.25471 ± 0.0181867 (W 0.0190404) | 5.47601 ± 0.0331048 (W 0.0510393) | 3.30593 ± 0.0151507 (W 0.0101877) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 4.23077 ± 0.00687511 (W 0.0179522) | 4.46138 ± 0.00907844 (W 0.0215469) | 3.60418 ± 0.00840286 (W 0.00575552) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 21.2487 ± 0.089102 (W 0.0684193) | 21.766 ± 0.0944564 (W 0.0650012) | 17.1131 ± 0.0326085 (W 0.0205857) | · | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 79.3835 ± 0.319186 (W 0.267699) | 81.0728 ± 0.214222 (W 0.3699) | 81.5746 ± 0.414445 (W 0.0900501) | · | · |  |
| `svd_values/n128/b1` | 3.01899 ± 0.0049847 (W 0.00870354) | 3.01111 ± 0.00177606 (W 0.00611522) | 1.90412 ± 0.00547802 (W 0.0036305) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 17.0877 ± 0.0435836 (W 0.0605427) | 17.0433 ± 0.0533261 (W 0.0293195) | 9.65538 ± 0.00407997 (W 0.00949639) | · | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 60.3069 ± 0.0678141 (W 0.228645) | 60.4017 ± 0.231711 (W 0.253733) | 42.7679 ± 0.0583962 (W 0.0363031) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `triangular_solve/n128/b1` | 0.008305 ± 0.00043704 (W 1.47716e-05) | 0.008035 ± 0.000462458 (W 2e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024155 ± 0.00105655 (W 5.80517e-05) | 0.023463 ± 0.0024813 (W 9.89859e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.077264 ± 0.00430234 (W 0.0026297) | 0.084768 ± 0.00583653 (W 0.00311246) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.815629 ± 0.000908633 (W 0.00336637) | 0.814527 ± 0.000472582 (W 0.00868731) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.2967 ± 0.0341605 (W 0.107845) | 54.964 ± 0.18476 (W 0.93627) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.561687 ± 0.00187644 (W 0.00262162) | 0.568866 ± 0.00305523 (W 0.00223454) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.555224 ± 0.00316781 (W 0.0019086) | 0.567307 ± 0.00624442 (W 0.00413054) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.0632 ± 0.0101463 (W 0.0286157) | 34.8972 ± 0.144284 (W 0.0317425) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.0699 ± 0.0934891 (W 0.0358636) | 34.9842 ± 0.132864 (W 0.0282948) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.47212 ± 0.00116816 (W 0.00327128) | 0.47206 ± 0.00326056 (W 0.0044402) | 0.664069 ± 0.135667 (W 0.00149158) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.4933 ± 0.134246 (W 0.0571668) | 18.9966 ± 0.0483755 (W 0.0249393) | 18.5759 ± 2.13734 (W 0.138125) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.58252 ± 0.00153653 (W 0.00273163) | 1.54759 ± 0.00323983 (W 0.00399991) | 1.86497 ± 0.00191699 (W 0.00508022) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 70.442 ± 2.32958 (W 0.0500461) | 73.8978 ± 2.30544 (W 0.146266) | 81.545 ± 0.330576 (W 0.258222) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.03794 ± 0.00190107 (W 0.00191977) | 1.8525 ± 0.000271473 (W 0.00387551) | 0.907761 ± 0.00215582 (W 0.00420075) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 31.4726 ± 0.460095 (W 0.140532) | 78.0687 ± 0.14767 (W 0.0302756) | 35.0857 ± 0.397728 (W 0.0939451) | 🔵 faer-fork 2.48× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.50395 ± 0.00703608 (W 0.00309787) | 2.50198 ± 0.00449187 (W 0.00613168) | 3.0481 ± 0.00574999 (W 0.00797107) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.3504 ± 0.378539 (W 0.407848) | 88.6147 ± 0.35781 (W 0.077962) | 120.678 ± 0.875128 (W 0.192862) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.48752 ± 0.000830675 (W 0.00567551) | 1.48795 ± 0.00255941 (W 0.0040066) | 1.39073 ± 0.00518966 (W 0.00440036) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 44.7379 ± 0.133493 (W 0.0329764) | 44.7638 ± 0.167999 (W 0.0482336) | 46.6477 ± 0.290955 (W 0.350687) | · | · |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.813313 ± 0.00265446 (W 0.00247164) | 0.817555 ± 0.00373861 (W 0.00603191) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 19.7813 ± 0.0250847 (W 0.0730564) | 25.8169 ± 0.259838 (W 0.862714) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.185395 ± 0.00417408 (W 0.00151704) | 0.164197 ± 0.00301441 (W 0.00184142) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.184203 ± 0.00420421 (W 0.00218397) | 0.164366 ± 0.00348706 (W 0.00152364) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.0481 ± 0.141869 (W 0.0705981) | 9.40399 ± 0.027914 (W 0.0142179) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 10.1477 ± 0.245744 (W 0.121698) | 9.41458 ± 0.0275177 (W 0.02445) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.496375 ± 0.00608248 (W 0.0177838) | 0.496095 ± 0.00141921 (W 0.0116952) | 0.533454 ± 0.118559 (W 0.00193513) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 9.38194 ± 0.261634 (W 0.0671652) | 13.0198 ± 0.0109842 (W 0.041665) | 13.4107 ± 1.92192 (W 0.0239142) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.26632 ± 0.0167662 (W 0.013213) | 1.70318 ± 0.0140474 (W 0.00781977) | 1.0643 ± 0.00908199 (W 0.00306092) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 28.3047 ± 0.0655623 (W 0.335932) | 35.6048 ± 0.0858004 (W 0.0765253) | 29.928 ± 0.14157 (W 0.035065) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.02745 ± 0.0271026 (W 0.0073746) | 3.94384 ± 0.0642726 (W 0.150281) | 0.464219 ± 0.00758814 (W 0.00913199) | 🔵 faer-fork 3.84× faster than `faer-upstream` | 🔴 faer-fork 2.21× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 15.6316 ± 0.107817 (W 0.154397) | 77.306 ± 0.598847 (W 0.448919) | 12.6914 ± 0.0210173 (W 0.0864061) | 🔵 faer-fork 4.95× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.36401 ± 0.015888 (W 0.0190235) | 2.77542 ± 0.00590464 (W 0.00880667) | 1.89445 ± 0.0082969 (W 0.0118894) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 46.7898 ± 0.036267 (W 0.258934) | 50.449 ± 0.0255219 (W 0.346695) | 48.763 ± 1.68391 (W 0.169063) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.63896 ± 0.032089 (W 0.0240569) | 2.11055 ± 0.0109012 (W 0.032472) | 0.946171 ± 0.00658092 (W 0.00772367) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.73× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 31.181 ± 0.139974 (W 0.168225) | 35.4071 ± 0.0891568 (W 0.121974) | 22.5507 ± 0.0552867 (W 0.0899548) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.811688 ± 0.00172509 (W 0.00276685) | 0.814334 ± 0.0042201 (W 0.0053106) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 15.8696 ± 0.0414322 (W 0.0590957) | 19.5352 ± 0.70879 (W 0.65879) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.158736 ± 0.002278 (W 0.00209818) | 0.137286 ± 0.00037848 (W 0.00162197) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.153537 ± 0.00492312 (W 0.00275143) | 0.135433 ± 0.00178216 (W 0.00213994) | - | 🔴 faer-fork 1.13× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.41387 ± 0.0494625 (W 0.0655001) | 5.00533 ± 0.0118595 (W 0.998607) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.41696 ± 0.0897577 (W 0.116041) | 5.01247 ± 0.0343773 (W 1.02738) | - | 🔴 faer-fork 1.28× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.476218 ± 0.00501116 (W 0.00455498) | 0.53103 ± 0.0161993 (W 0.00681004) | 0.59015 ± 0.162919 (W 0.00626876) | 🔵 faer-fork 1.12× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.88496 ± 0.170088 (W 0.0378444) | 12.212 ± 0.0158388 (W 0.0394611) | 4.15385 ± 1.86089 (W 0.0189243) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 2.14× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/1024x64/b1` | 1.40231 ± 0.00568066 (W 0.0151342) | 2.01685 ± 0.00958269 (W 0.0391631) | 0.886753 ± 0.00428422 (W 0.00346918) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 22.0897 ± 0.182873 (W 0.129488) | 35.5074 ± 0.114213 (W 0.563675) | 20.8142 ± 0.174299 (W 0.0906461) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.10254 ± 0.0124954 (W 0.00901426) | 4.40686 ± 0.135007 (W 0.125893) | 0.322152 ± 0.000727041 (W 0.00256077) | 🔵 faer-fork 4.00× faster than `faer-upstream` | 🔴 faer-fork 3.42× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 12.9197 ± 0.0685218 (W 0.0761903) | 76.9634 ± 0.31166 (W 0.324587) | 7.32481 ± 0.0197819 (W 0.0466162) | 🔵 faer-fork 5.96× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.52665 ± 0.019372 (W 0.0128556) | 3.14462 ± 0.0450551 (W 0.0501963) | 1.68028 ± 0.00276166 (W 0.00729656) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.7974 ± 0.0458801 (W 0.0731872) | 50.4139 ± 0.484458 (W 0.597247) | 36.4856 ± 0.162186 (W 0.0637751) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.75986 ± 0.0201222 (W 0.0187065) | 2.50639 ± 0.0361717 (W 0.0239102) | 0.814668 ± 0.00252463 (W 0.00306786) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 2.16× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 29.6103 ± 0.026764 (W 0.0412654) | 37.4712 ± 0.246566 (W 0.304222) | 16.7856 ± 0.221334 (W 0.0354957) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.76× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.730242 ± 0.000568217 (W 0.00272704) | 0.730772 ± 0.00142758 (W 0.00156797) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.9769 ± 0.121886 (W 0.0775241) | 47.0129 ± 0.206284 (W 0.0454722) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.609206 ± 0.00816718 (W 0.00238221) | 0.601011 ± 0.00619511 (W 0.00279832) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.596378 ± 0.00421106 (W 0.00254297) | 0.596768 ± 0.00443892 (W 0.00359731) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.412 ± 0.128454 (W 0.0309569) | 35.2999 ± 0.165896 (W 0.0285283) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.4962 ± 0.317615 (W 0.0263716) | 35.3113 ± 0.290523 (W 0.0205199) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.384256 ± 0.000714746 (W 0.00313598) | 0.383295 ± 0.00198961 (W 0.00197617) | 0.284761 ± 0.00142659 (W 0.00226221) | · | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.2271 ± 0.0420224 (W 0.0240356) | 13.2067 ± 0.0249995 (W 0.0313781) | 11.6416 ± 0.0231642 (W 0.0142377) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.46898 ± 0.00591038 (W 0.00367501) | 1.46 ± 0.00796765 (W 0.00390794) | 1.58298 ± 0.000760264 (W 0.00406009) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 68.2735 ± 2.45457 (W 0.0384166) | 68.3195 ± 2.43065 (W 0.109788) | 69.8518 ± 0.533555 (W 0.0643215) | · | · | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.773771 ± 0.0051091 (W 0.00263863) | 0.775103 ± 0.00343707 (W 0.00238922) | 0.764995 ± 0.000953437 (W 0.00233078) | · | · |  |
| `qr_factor/4096x256/b1` | 25.9087 ± 0.0297101 (W 0.0226912) | 26.0731 ± 0.00628048 (W 0.031498) | 29.0693 ± 0.192334 (W 0.0249994) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.45493 ± 0.00527164 (W 0.00379161) | 2.45583 ± 0.00217163 (W 0.00652296) | 2.81256 ± 0.00769756 (W 0.00552559) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.7621 ± 0.363414 (W 0.0693945) | 83.3563 ± 0.34516 (W 0.0748567) | 109.615 ± 0.574116 (W 0.263138) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.3983 ± 0.00298526 (W 0.00426216) | 1.396 ± 0.000934112 (W 0.0031111) | 1.24201 ± 0.0048718 (W 0.00390553) | · | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 39.1382 ± 0.0849037 (W 0.0223317) | 39.1812 ± 0.0735284 (W 0.03717) | 40.5537 ± 0.426904 (W 0.0411183) | · | · |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.731463 ± 0.00262715 (W 0.00317839) | 0.733868 ± 0.0059268 (W 0.00285982) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.4917 ± 0.0338558 (W 0.0852581) | 17.6194 ± 0.0972693 (W 0.119459) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.196307 ± 0.00691607 (W 0.00253443) | 0.201607 ± 0.013414 (W 0.00202249) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.198051 ± 0.00395737 (W 0.0038413) | 0.201948 ± 0.0121845 (W 0.00131103) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 11.2526 ± 0.0575393 (W 0.0173089) | 10.8737 ± 0.0148112 (W 0.0313767) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.3053 ± 0.0446099 (W 0.0202865) | 11.2186 ± 0.0398788 (W 0.0129619) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.405215 ± 0.00486531 (W 0.0114281) | 0.427851 ± 0.00206298 (W 0.0103734) | 0.286414 ± 0.000411291 (W 0.0017165) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 7.33115 ± 0.0650431 (W 0.0381601) | 7.36992 ± 0.0140004 (W 0.0197735) | 11.6049 ± 0.0101137 (W 0.0256735) | · | 🔵 faer-fork 1.58× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.18451 ± 0.00492917 (W 0.0123641) | 1.62436 ± 0.00939511 (W 0.00796836) | 0.983723 ± 0.00688211 (W 0.00904428) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 26.0552 ± 0.175547 (W 0.225911) | 29.7558 ± 0.0697611 (W 0.0968514) | 26.9994 ± 0.311803 (W 0.280176) | 🔵 faer-fork 1.14× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 0.901982 ± 0.00678123 (W 0.00974777) | 1.34418 ± 0.0158924 (W 0.0159493) | 0.422871 ± 0.00418238 (W 0.00705741) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 13.4299 ± 0.158566 (W 0.176551) | 17.8708 ± 0.268537 (W 0.110544) | 11.3359 ± 0.0901368 (W 0.0551275) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.29068 ± 0.00746283 (W 0.011105) | 2.72715 ± 0.00637714 (W 0.0198223) | 1.8264 ± 0.00403555 (W 0.00660348) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 41.2071 ± 0.0503428 (W 0.328319) | 44.5839 ± 0.23131 (W 0.141731) | 45.6307 ± 0.286726 (W 0.0852458) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.55819 ± 0.0164488 (W 0.0205191) | 2.02371 ± 0.0114464 (W 0.0231507) | 0.920326 ± 0.0119638 (W 0.00639708) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.69× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.6599 ± 0.190122 (W 0.302469) | 29.776 ± 0.135927 (W 0.0975543) | 20.9172 ± 0.0894128 (W 0.100435) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.73291 ± 0.00206469 (W 0.00169682) | 0.734343 ± 0.00217839 (W 0.00418981) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 13.6012 ± 0.0419369 (W 0.11973) | 13.6447 ± 0.0316436 (W 0.0972153) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.16075 ± 0.00508066 (W 0.00405394) | 0.163475 ± 0.00282202 (W 0.00285824) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.158255 ± 0.00322851 (W 0.00502876) | 0.159248 ± 0.00203129 (W 0.00161535) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 7.2087 ± 0.12856 (W 0.177578) | 6.69246 ± 0.109296 (W 0.822638) | - | 🔴 faer-fork 1.08× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 7.24301 ± 0.143707 (W 0.145872) | 6.76242 ± 0.375838 (W 0.168167) | - | 🔴 faer-fork 1.07× slower than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.394736 ± 0.00129695 (W 0.00393149) | 0.45057 ± 0.0030874 (W 0.00655842) | 0.286393 ± 0.000636837 (W 0.0027088) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `lu/4096x256/b1` | 6.61825 ± 0.00655755 (W 0.0436366) | 6.68593 ± 0.0402623 (W 0.0245063) | 3.15421 ± 0.0156466 (W 0.0141961) | · | 🔴 faer-fork 2.10× slower than `lapack-mkl` |  |
| `qr/1024x64/b1` | 1.33109 ± 0.00435524 (W 0.0175996) | 1.90403 ± 0.0152472 (W 0.0168742) | 0.846132 ± 0.00249787 (W 0.00338382) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 19.788 ± 0.117046 (W 0.0943296) | 30.0235 ± 0.697033 (W 0.51927) | 19.2215 ± 0.0827469 (W 0.0514441) | 🔵 faer-fork 1.52× faster than `faer-upstream` | · |  |
| `qr_factor/1024x64/b1` | 1.01899 ± 0.00842294 (W 0.0123935) | 1.63243 ± 0.0184309 (W 0.0254032) | 0.298709 ± 0.00103298 (W 0.00175291) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔴 faer-fork 3.41× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.5787 ± 0.111458 (W 0.03839) | 19.3528 ± 0.162879 (W 0.176398) | 6.45467 ± 0.0460867 (W 0.0388886) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔴 faer-fork 1.79× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.45954 ± 0.0128365 (W 0.0152434) | 3.06923 ± 0.0188407 (W 0.0284816) | 1.63687 ± 0.000653866 (W 0.00667472) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 35.1853 ± 0.0818219 (W 0.107115) | 44.9058 ± 0.341559 (W 0.800934) | 34.2267 ± 0.429466 (W 0.14876) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.69894 ± 0.00787182 (W 0.0204558) | 2.40313 ± 0.020498 (W 0.0235577) | 0.788815 ± 0.00161799 (W 0.00256297) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 24.1396 ± 0.0689656 (W 0.0697664) | 31.8458 ± 0.0170348 (W 0.218931) | 15.7951 ± 0.167823 (W 0.0566311) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.7875 ± 0.00558135 (W 0.00289779) | 1.83796 ± 0.0184768 (W 0.00220703) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.219 ± 0.720479 (W 0.550812) | 155.915 ± 1.42584 (W 1.47719) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19821 ± 0.00478142 (W 0.00287972) | 2.20444 ± 0.0192803 (W 0.00275371) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.20239 ± 0.000739501 (W 0.00354718) | 2.20615 ± 0.0239642 (W 0.00451287) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.031 ± 0.122877 (W 0.0937762) | 137.884 ± 0.0695682 (W 0.100694) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.821 ± 0.1026 (W 0.382485) | 137.771 ± 0.112194 (W 0.0794728) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.03585 ± 0.00191572 (W 0.00253978) | 1.05777 ± 0.00332625 (W 0.00235492) | 1.19733 ± 0.0195516 (W 0.00246696) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 47.3786 ± 0.225257 (W 0.155155) | 54.353 ± 0.0491989 (W 0.0579391) | 67.0402 ± 0.0974547 (W 0.0895891) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.74948 ± 0.0213722 (W 0.0077215) | 4.74374 ± 0.0226801 (W 0.016136) | 5.1169 ± 0.0339995 (W 0.0048741) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 250.375 ± 0.3636 (W 0.548649) | 255.901 ± 0.209078 (W 0.249106) | 237.978 ± 0.404171 (W 0.983473) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.52325 ± 0.0253651 (W 0.0037434) | 4.08327 ± 0.131392 (W 0.0160245) | 2.38273 ± 0.0207616 (W 0.00362523) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 101.252 ± 0.162608 (W 0.394623) | 175.735 ± 0.578781 (W 0.11186) | 110.541 ± 0.16745 (W 0.171208) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 6.01546 ± 0.0196838 (W 0.00514214) | 5.99911 ± 0.020903 (W 0.0066632) | 8.7756 ± 0.024462 (W 0.016116) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 281.162 ± 0.237598 (W 0.959333) | 281.08 ± 0.317113 (W 0.270628) | 379.255 ± 0.405873 (W 0.531217) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 3.09159 ± 0.0174245 (W 0.00694353) | 3.07369 ± 0.0177497 (W 0.00362892) | 3.80255 ± 0.0135208 (W 0.00535011) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 123.883 ± 0.698483 (W 0.443439) | 123.477 ± 0.546468 (W 0.405309) | 144.554 ± 6.95209 (W 0.17918) | · | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.77158 ± 0.00779851 (W 0.00323477) | 1.82753 ± 0.013331 (W 0.00311903) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 57.6878 ± 0.475405 (W 0.80179) | 65.8336 ± 0.946851 (W 1.04967) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.619595 ± 0.0205318 (W 0.0104486) | 0.598987 ± 0.0107438 (W 0.00200813) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.62525 ± 0.0108942 (W 0.00809805) | 0.603375 ± 0.0123531 (W 0.00265643) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 37.1811 ± 0.0675232 (W 0.118588) | 36.9512 ± 0.257918 (W 0.0308797) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.2396 ± 0.196378 (W 0.143472) | 37.2686 ± 0.159966 (W 0.0173809) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.856413 ± 0.00222298 (W 0.0157773) | 0.860009 ± 0.00139366 (W 0.0122406) | 1.09495 ± 0.0078584 (W 0.00247708) | · | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 23.1022 ± 0.0453665 (W 0.0798778) | 30.3858 ± 0.0146942 (W 0.0825687) | 59.2623 ± 4.04693 (W 0.177924) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 2.57× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.65682 ± 0.033103 (W 0.0476844) | 2.97831 ± 0.0520733 (W 0.0249871) | 3.11748 ± 0.0179733 (W 0.0402606) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 84.0007 ± 0.0894006 (W 0.227625) | 98.5879 ± 0.110773 (W 0.108207) | 79.8854 ± 0.255372 (W 0.390712) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.9632 ± 0.0569149 (W 0.0549098) | 4.56956 ± 0.120138 (W 0.0610676) | 1.39192 ± 0.00234372 (W 0.00358344) | 🔵 faer-fork 2.33× faster than `faer-upstream` | 🔴 faer-fork 1.41× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 41.1653 ± 0.201603 (W 0.101085) | 123.946 ± 0.248165 (W 0.451036) | 34.0261 ± 0.230738 (W 0.153743) | 🔵 faer-fork 3.01× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.04799 ± 0.0769212 (W 0.111621) | 4.40141 ± 0.0385974 (W 0.0211436) | 5.50661 ± 0.00228202 (W 0.00828352) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 115.295 ± 0.216639 (W 0.269294) | 122.876 ± 0.124121 (W 0.346086) | 139.668 ± 0.337848 (W 0.430177) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.63588 ± 0.0330362 (W 0.0371493) | 3.0536 ± 0.0205496 (W 0.0331997) | 2.80451 ± 0.0511823 (W 0.0339378) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 66.9795 ± 0.221536 (W 0.185021) | 75.0933 ± 0.0691578 (W 0.100697) | 51.6868 ± 0.470181 (W 0.249311) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.76584 ± 0.00575856 (W 0.00482235) | 1.86629 ± 0.0242382 (W 0.00460106) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 34.6217 ± 0.149743 (W 0.427242) | 41.6757 ± 0.189405 (W 0.084649) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.415535 ± 0.00467543 (W 0.00789044) | 0.415918 ± 0.00169869 (W 0.00546102) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.421988 ± 0.00501159 (W 0.01276) | 0.420565 ± 0.00483296 (W 0.00228443) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.7824 ± 0.0163345 (W 0.195483) | 18.8064 ± 0.0341846 (W 3.73752) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.7486 ± 0.163799 (W 0.265537) | 18.7789 ± 0.0648647 (W 0.201231) | - | 🔴 faer-fork 1.16× slower than `faer-upstream` | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.842867 ± 0.00446867 (W 0.0149464) | 0.85303 ± 0.0140599 (W 0.00585691) | 1.08382 ± 0.00165171 (W 0.00213426) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 19.2641 ± 0.160394 (W 0.127455) | 26.4019 ± 0.0251108 (W 0.0568234) | 52.5741 ± 3.7299 (W 0.0850486) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔵 faer-fork 2.73× faster than `lapack-mkl` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 2.4507 ± 0.00800812 (W 0.0120573) | 3.19249 ± 0.0552368 (W 0.0363033) | 2.32107 ± 0.00425925 (W 0.00398049) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr/4096x256/b1` | 58.0435 ± 5.98766 (W 0.149858) | 82.496 ± 5.53278 (W 0.884823) | 46.1027 ± 0.0790598 (W 0.205419) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.87051 ± 0.00555827 (W 0.0136212) | 5.15832 ± 0.034991 (W 0.0584975) | 0.871227 ± 0.00295017 (W 0.00170094) | 🔵 faer-fork 2.76× faster than `faer-upstream` | 🔴 faer-fork 2.15× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 30.8252 ± 0.101839 (W 0.0718313) | 121.948 ± 0.481646 (W 0.383485) | 19.7519 ± 0.0162257 (W 0.0812274) | 🔵 faer-fork 3.96× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.83543 ± 0.0441516 (W 0.018329) | 4.64646 ± 0.0448683 (W 0.0314378) | 4.4751 ± 0.00666809 (W 0.0183367) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 88.6152 ± 0.326916 (W 0.361948) | 106.359 ± 2.61003 (W 0.877787) | 77.4211 ± 3.86337 (W 0.163713) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.64661 ± 0.00596915 (W 0.0257454) | 3.35959 ± 0.0198399 (W 0.0393783) | 2.3085 ± 0.00525814 (W 0.00334194) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 58.9214 ± 0.0314811 (W 0.219668) | 72.6482 ± 0.230383 (W 0.383277) | 34.4255 ± 0.127431 (W 0.0689744) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.71× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6707 ± 0.00567729 (W 0.00306821) | 1.69365 ± 0.00686398 (W 0.00278192) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 142.967 ± 0.329654 (W 0.563356) | 142.85 ± 0.718618 (W 0.702392) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.23189 ± 0.0346655 (W 0.00468009) | 2.2341 ± 0.0308871 (W 0.00707469) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26715 ± 0.0140332 (W 0.00231692) | 2.27321 ± 0.00986622 (W 0.00181406) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.943 ± 0.19055 (W 0.370006) | 138.98 ± 0.0799744 (W 0.106156) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 139.054 ± 0.117423 (W 0.392174) | 138.913 ± 0.0626125 (W 0.0668568) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.91783 ± 0.000404724 (W 0.00132637) | 0.926937 ± 0.00039127 (W 0.00210751) | 1.06431 ± 0.0324828 (W 0.00248497) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 42.1609 ± 0.0851377 (W 0.0372017) | 42.2603 ± 0.0311073 (W 0.0243217) | 49.7682 ± 0.108719 (W 0.05256) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 4.62962 ± 0.0185549 (W 0.00689386) | 4.62314 ± 0.0217848 (W 0.0034169) | 4.83363 ± 0.0297167 (W 0.00675295) | · | · |  |
| `qr/4096x256/b1` | 244.184 ± 0.179384 (W 0.151133) | 244.309 ± 0.0718615 (W 0.325926) | 214.338 ± 0.454888 (W 0.669338) | · | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 2.22231 ± 0.0527049 (W 0.00329601) | 2.19015 ± 0.0406025 (W 0.00338102) | 2.24305 ± 0.00939942 (W 0.00602715) | · | · |  |
| `qr_factor/4096x256/b1` | 89.4556 ± 0.0460483 (W 0.0659105) | 89.164 ± 0.181859 (W 0.0759377) | 103.348 ± 0.158365 (W 0.256156) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.9078 ± 0.0152795 (W 0.00317148) | 5.9044 ± 0.0133592 (W 0.00593849) | 8.42703 ± 0.073367 (W 0.0228539) | · | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 268.919 ± 0.183268 (W 0.372808) | 268.767 ± 0.233919 (W 0.447049) | 370.018 ± 0.279236 (W 0.414001) | · | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.97711 ± 0.017224 (W 0.00659373) | 2.95839 ± 0.0202001 (W 0.0060558) | 3.65229 ± 0.0177732 (W 0.00854679) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 110.7 ± 0.133207 (W 0.0841614) | 110.445 ± 0.130991 (W 0.438011) | 138.086 ± 1.87493 (W 0.333355) | · | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.66285 ± 0.00920454 (W 0.00274981) | 1.6909 ± 0.00418797 (W 0.00341507) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.2431 ± 0.291277 (W 0.470935) | 53.1257 ± 0.331208 (W 0.444353) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.649786 ± 0.0117487 (W 0.00800853) | 0.630094 ± 0.00648971 (W 0.00186339) | - | · | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.662219 ± 0.0114404 (W 0.00913431) | 0.646315 ± 0.00841852 (W 0.00163341) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.3131 ± 0.142035 (W 0.0647076) | 39.6484 ± 0.201619 (W 0.103723) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.3937 ± 0.0402878 (W 0.0272511) | 39.7958 ± 0.063974 (W 0.108046) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.75337 ± 0.00308656 (W 0.00620329) | 0.764253 ± 0.00654666 (W 0.012303) | 1.06651 ± 0.00349164 (W 0.0024434) | · | 🔵 faer-fork 1.42× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 17.836 ± 0.0836636 (W 0.0619886) | 18.0413 ± 0.0287775 (W 0.0427937) | 49.4968 ± 0.125954 (W 0.0704052) | · | 🔵 faer-fork 2.78× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.55593 ± 0.0431706 (W 0.102592) | 2.89955 ± 0.0343486 (W 0.0204039) | 3.0602 ± 0.00661482 (W 0.0040108) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `qr/4096x256/b1` | 78.8042 ± 0.163413 (W 0.234304) | 86.3971 ± 0.138549 (W 0.173629) | 74.8606 ± 0.263065 (W 0.241933) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/1024x64/b1` | 1.74663 ± 0.14618 (W 0.021765) | 2.12542 ± 0.011193 (W 0.0148584) | 1.34867 ± 0.0122531 (W 0.0034526) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 36.064 ± 0.0472714 (W 0.100236) | 44.1562 ± 0.0796978 (W 0.0726184) | 30.863 ± 0.24628 (W 0.122647) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 4.11336 ± 0.0335222 (W 0.0939507) | 4.23763 ± 0.0246462 (W 0.0137841) | 5.39392 ± 0.0124541 (W 0.0112714) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 103.303 ± 0.211117 (W 0.266846) | 110.697 ± 0.0757885 (W 0.190897) | 130.202 ± 0.876913 (W 0.776493) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.59952 ± 0.0487727 (W 0.103514) | 2.94567 ± 0.0165309 (W 0.0234876) | 2.78669 ± 0.0181274 (W 0.00455967) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 55.2893 ± 0.173335 (W 0.257514) | 63.2336 ± 0.118582 (W 0.0923902) | 48.8128 ± 0.28655 (W 0.17749) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6624 ± 0.00394133 (W 0.00321469) | 1.68775 ± 0.00367801 (W 0.00343633) | - | · | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 28.988 ± 0.194427 (W 1.275) | 29.5997 ± 0.962761 (W 0.251401) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.420955 ± 0.00871663 (W 0.00951867) | 0.445572 ± 0.00081635 (W 0.00272254) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.430034 ± 0.0166374 (W 0.00865645) | 0.459239 ± 0.0105408 (W 0.00281175) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.4022 ± 0.136595 (W 0.363981) | 21.3555 ± 0.383728 (W 3.20441) | - | · | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.048 ± 0.143794 (W 0.147117) | 21.3737 ± 0.0576209 (W 3.39358) | - | · | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.731808 ± 0.00896969 (W 0.0183179) | 0.751506 ± 0.00302316 (W 0.00395906) | 1.06112 ± 0.000927099 (W 0.00164607) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `lu/4096x256/b1` | 13.8946 ± 0.048286 (W 0.0308767) | 14.1564 ± 0.0573629 (W 0.0487968) | 49.3853 ± 0.120172 (W 0.0321147) | · | 🔵 faer-fork 3.55× faster than `lapack-mkl` |  |
| `qr/1024x64/b1` | 2.33091 ± 0.00793525 (W 0.0177026) | 3.12259 ± 0.0152107 (W 0.012753) | 2.28266 ± 0.00555173 (W 0.00343842) | 🔵 faer-fork 1.34× faster than `faer-upstream` | · |  |
| `qr/4096x256/b1` | 52.6039 ± 6.28896 (W 0.23929) | 70.2855 ± 6.0214 (W 0.831168) | 42.4421 ± 0.259736 (W 0.281524) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/1024x64/b1` | 1.72201 ± 0.00376538 (W 0.013157) | 2.41905 ± 0.00979292 (W 0.0156738) | 0.853516 ± 0.0014995 (W 0.00167301) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 2.02× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.7951 ± 0.0498346 (W 0.0789743) | 41.689 ± 0.0968762 (W 0.11652) | 17.6244 ± 0.0749716 (W 0.134861) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.72279 ± 0.0246581 (W 0.0199694) | 4.4919 ± 0.0431205 (W 0.0298855) | 4.41043 ± 0.00582671 (W 0.00683069) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 76.3648 ± 0.254159 (W 0.195305) | 93.3438 ± 0.0253295 (W 0.502597) | 74.122 ± 0.298217 (W 0.302179) | 🔵 faer-fork 1.22× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.55465 ± 0.00660597 (W 0.0264299) | 3.26502 ± 0.0212395 (W 0.0292184) | 2.29481 ± 0.00354128 (W 0.00508214) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 47.4548 ± 0.00797146 (W 0.131915) | 61.1038 ± 0.112135 (W 0.157746) | 32.4611 ± 0.664354 (W 0.16928) | 🔵 faer-fork 1.29× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
