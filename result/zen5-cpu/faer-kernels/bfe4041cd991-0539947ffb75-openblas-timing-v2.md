<!-- generated from data/results/zen5-cpu/faer-kernels/20261015T194810Z-baseline-v2-faer-kernels-openblas/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `e55c7e4059b6d6bb2792289aae6d5314f6f3d39d`
- toolkit commit: `07d911e7fc44c6c944ec2cd08ddcf0cdf5ed7f2a`
- measured binary SHA-256: `25322cf27657b8a0bfb24194340f08ff03d0d8651868dc74156f8d1750d81589`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-15T20:54:25.331303Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor openblas --engines faer-fork,lapack-openblas --dtypes f64,c64 --reps 5 --aa 2 --prime-ms 250 --label baseline-v2-faer-kernels-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels/20261015T194810Z-baseline-v2-faer-kernels-openblas/`

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
  - `lapack-openblas` — CBLAS `?gemm` plus LAPACK drivers linked against OpenBLAS: vendor calls and their marshalling, vendor-owned threading. The vendor's own thread budget is set by the harness before the row and read back, and the vendor identity and the dispatched kernel are recorded in the manifest.
    Identity: the OpenBLAS build recorded in this run's manifest (`providers[openblas]`)
    Caveat: LAPACK and BLAS own their threading, so this row's thread budget is the vendor's, not the harness pool's. Where a family has no LAPACK route the row is absent and the CSV says the case was skipped for it.
    As measured: linked static; openblas 0.3.32; kernel dispatched to `Cooperlake`; pthread threading; config `OpenBLAS 0.3.32 DYNAMIC_ARCH NO_AFFINITY Cooperlake MAX_THREADS=24`

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
Each process retains 5 chronological calls; 2 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.61%, worst 39.43%, and 125 of 2328 engine cells exceed 5% and carry `!`; median within-process relative SD 0.45%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.00233 ± 7.07107e-06 (W 8.84018e-06) | 0.002249 ± 7.07107e-06 (W 1.3444e-05) | `lapack-openblas` 0.9652 (0.965 0.965) |
| `gemm/64x64x64/b1` | 0.0171185 ± 8.98026e-05 (W 1.68244e-05) | 0.0168435 ± 2.6163e-05 (W 2.32737e-05) | `lapack-openblas` 0.9839 (0.987 0.981) |
| `gemm/96x96x96/b1` | 0.056707 ± 1.27279e-05 (W 3.89436e-05) | 0.056346 ± 2.68701e-05 (W 0.000864453) | `lapack-openblas` 0.9936 (0.994 0.993) |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.011207 ± 0.000178191 (W 0.00110523) | 0.0022395 ± 6.36396e-06 (W 1.8027e-05) | `lapack-openblas` 0.1998 (0.198 0.202) |
| `gemm/64x64x64/b1` | 0.025435 ± 0.000599627 (W 0.00330695) | 0.016838 ± 5.65685e-06 (W 2.34947e-05) | `lapack-openblas` 0.6621 (0.673 0.651) |
| `gemm/96x96x96/b1` | 0.058816 ± 0.00753069 (W 0.00871575) | 0.0562955 ± 2.89914e-05 (W 0.000666386) | ! p `lapack-openblas` 0.9611 (0.877 1.053) |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.013256 ± 0.000185262 (W 0.00117987) | 0.00221 ± 2.12132e-05 (W 1.67279e-05) | `lapack-openblas` 0.1667 (0.164 0.170) |
| `gemm/64x64x64/b1` | 0.019544 ± 0.000997021 (W 0.00124708) | 0.016818 ± 8.48528e-06 (W 0.000752654) | ! `lapack-openblas` 0.8611 (0.893 0.830) |
| `gemm/96x96x96/b1` | 0.0299435 ± 0.000939745 (W 0.00163597) | 0.056511 ± 0.000104652 (W 0.000915536) | `lapack-openblas` 1.888 (1.933 1.844) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002315 ± 0 (W 5.03339e-06) | 0.002229 ± 2.12132e-05 (W 1.8431e-05) | `lapack-openblas` 0.9628 (0.969 0.956) |
| `gemm/64x64x64/b1` | 0.0171635 ± 8.27315e-05 (W 0.000762219) | 0.0168535 ± 5.44472e-05 (W 1.7566e-05) | `lapack-openblas` 0.9819 (0.983 0.981) |
| `gemm/96x96x96/b1` | 0.0570175 ± 0.000468812 (W 9.23517e-05) | 0.056341 ± 2.26274e-05 (W 6.32007e-05) | `lapack-openblas` 0.9882 (0.994 0.983) |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.009193 ± 0.000347897 (W 0.000994017) | 0.0022295 ± 2.19203e-05 (W 2.28254e-05) | ! `lapack-openblas` 0.2426 (0.238 0.247) |
| `gemm/64x64x64/b1` | 0.0244875 ± 5.44472e-05 (W 0.00231874) | 0.016863 ± 0.000100409 (W 4.13156e-05) | `lapack-openblas` 0.6886 (0.693 0.685) |
| `gemm/96x96x96/b1` | 0.056661 ± 0.0101258 (W 0.0168684) | 0.056421 ± 0.000234759 (W 0.000898329) | ! p `lapack-openblas` 1.004 (1.136 0.887) |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.014098 ± 5.79828e-05 (W 0.00119104) | 0.002234 ± 0 (W 1.8643e-05) | `lapack-openblas` 0.1585 (0.158 0.159) |
| `gemm/64x64x64/b1` | 0.0198895 ± 0.000143543 (W 0.00142744) | 0.016828 ± 8.48528e-06 (W 2.63967e-05) | `lapack-openblas` 0.8461 (0.842 0.850) |
| `gemm/96x96x96/b1` | 0.032033 ± 0.000917825 (W 0.00141148) | 0.0563505 ± 9.2631e-05 (W 3.87211e-05) | `lapack-openblas` 1.759 (1.793 1.726) |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088725 ± 2.19203e-05 (W 1.51076e-05) | 0.011638 ± 3.67696e-05 (W 2.97222e-05) | `lapack-openblas` 1.312 (1.312 1.311) |
| `gemm/64x64x64/b1` | 0.067773 ± 2.12132e-05 (W 0.000445186) | 0.085919 ± 2.40416e-05 (W 0.000166384) | `lapack-openblas` 1.268 (1.268 1.267) |
| `gemm/96x96x96/b1` | 0.226832 ± 0.000166877 (W 0.00184628) | 0.276605 ± 0.000281428 (W 0.00127879) | `lapack-openblas` 1.219 (1.219 1.220) |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008912 ± 4.80833e-05 (W 1.94278e-05) | 0.011628 ± 6.22254e-05 (W 3.22615e-05) | `lapack-openblas` 1.305 (1.305 1.305) |
| `gemm/64x64x64/b1` | 0.035495 ± 0.00135765 (W 0.00241544) | 0.025836 ± 0.000726906 (W 0.000261892) | ! `lapack-openblas` 0.728 (0.695 0.763) |
| `gemm/96x96x96/b1` | 0.09661 ± 0.00502046 (W 0.00827512) | 0.078279 ± 0.00145805 (W 0.000457132) | ! `lapack-openblas` 0.8107 (0.830 0.792) |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088525 ± 6.36396e-06 (W 0.000813009) | 0.011593 ± 1.55563e-05 (W 2.40988e-05) | `lapack-openblas` 1.31 (1.311 1.308) |
| `gemm/64x64x64/b1` | 0.036732 ± 0.00184555 (W 0.00156832) | 0.026166 ± 6.6468e-05 (W 0.000221244) | ! `lapack-openblas` 0.7128 (0.689 0.737) |
| `gemm/96x96x96/b1` | 0.050374 ± 0.000455377 (W 0.00081647) | 0.055514 ± 1.27279e-05 (W 0.000569123) | `lapack-openblas` 1.102 (1.109 1.095) |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0089225 ± 2.19203e-05 (W 3.48216e-05) | 0.011623 ± 4.10122e-05 (W 3.01652e-05) | `lapack-openblas` 1.303 (1.297 1.308) |
| `gemm/64x64x64/b1` | 0.067734 ± 7.07107e-06 (W 0.00167397) | 0.0859945 ± 5.44472e-05 (W 0.0012188) | `lapack-openblas` 1.27 (1.269 1.270) |
| `gemm/96x96x96/b1` | 0.227082 ± 2.54558e-05 (W 0.00164941) | 0.276099 ± 7.77817e-06 (W 0.0013078) | `lapack-openblas` 1.216 (1.216 1.216) |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0089075 ± 5.58614e-05 (W 1.73148e-05) | 0.011623 ± 1.55563e-05 (W 3.08202e-05) | `lapack-openblas` 1.305 (1.312 1.298) |
| `gemm/64x64x64/b1` | 0.041066 ± 0.00541078 (W 0.00510526) | 0.025836 ± 0.0005572 (W 0.000681748) | ! p `lapack-openblas` 0.6318 (0.567 0.704) |
| `gemm/96x96x96/b1` | 0.0948165 ± 0.00543694 (W 0.00643161) | 0.0783835 ± 0.000799738 (W 0.00161081) | ! `lapack-openblas` 0.8273 (0.789 0.868) |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088375 ± 1.48492e-05 (W 1.4735e-05) | 0.011598 ± 5.65685e-06 (W 1.65406e-05) | `lapack-openblas` 1.312 (1.310 1.314) |
| `gemm/64x64x64/b1` | 0.037684 ± 0.0016122 (W 0.000910304) | 0.025991 ± 0.000323855 (W 0.000201245) | ! `lapack-openblas` 0.69 (0.705 0.675) |
| `gemm/96x96x96/b1` | 0.0512705 ± 0.00109955 (W 0.00138255) | 0.055304 ± 1.55563e-05 (W 0.00072109) | `lapack-openblas` 1.079 (1.095 1.063) |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133516 ± 2.33345e-05 (W 0.000938032) | 0.162698 ± 0.000214253 (W 0.00128547) | `lapack-openblas` 1.219 (1.220 1.217) |
| `gemm/192x192x192/b1` | 0.452391 ± 0.000205768 (W 0.00178863) | 0.539623 ± 0.00209869 (W 0.00296926) | `lapack-openblas` 1.193 (1.196 1.190) |
| `gemm/256x256x256/b1` | 1.07688 ± 0.00139795 (W 0.00189321) | 1.26511 ± 0.00488257 (W 0.00367976) | `lapack-openblas` 1.175 (1.171 1.179) |
| `gemm/384x384x384/b1` | 3.62184 ± 0.0124126 (W 0.00501534) | 4.2502 ± 0.000650538 (W 0.00254) | `lapack-openblas` 1.173 (1.171 1.176) |
| `gemm/512x512x512/b1` | 8.61611 ± 0.00881126 (W 0.0121799) | 10.1419 ± 0.10818 (W 0.0873986) | `lapack-openblas` 1.177 (1.169 1.185) |
| `gemm/768x768x768/b1` | 29.4639 ± 0.00502612 (W 0.0473811) | 33.8717 ± 0.0648622 (W 0.0267502) | `lapack-openblas` 1.15 (1.148 1.151) |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0915295 ± 0.0155655 (W 0.0126884) | 0.0500325 ± 0.00107975 (W 0.000757361) | ! p `lapack-openblas` 0.5506 (0.481 0.631) |
| `gemm/192x192x192/b1` | 0.138855 ± 0.0165039 (W 0.0122582) | 0.146636 ± 0.00231224 (W 0.00182122) | ! p `lapack-openblas` 1.06 (1.140 0.985) |
| `gemm/256x256x256/b1` | 0.309037 ± 9.68736e-05 (W 0.00578695) | 0.340063 ± 0.00361544 (W 0.00181229) | `lapack-openblas` 1.1 (1.092 1.108) |
| `gemm/384x384x384/b1` | 0.927196 ± 0.00233699 (W 0.00327894) | 1.09822 ± 0.00697137 (W 0.00344705) | `lapack-openblas` 1.184 (1.181 1.188) |
| `gemm/512x512x512/b1` | 2.23289 ± 0.00158604 (W 0.00537839) | 2.58096 ± 0.00464781 (W 0.00184243) | `lapack-openblas` 1.156 (1.155 1.157) |
| `gemm/768x768x768/b1` | 7.51841 ± 0.0119699 (W 0.0128248) | 8.69145 ± 0.00506925 (W 0.0235633) | `lapack-openblas` 1.156 (1.157 1.155) |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0980805 ± 0.00221678 (W 0.0286308) | 0.0301785 ± 0.000734684 (W 0.000944625) | `lapack-openblas` 0.3077 (0.298 0.318) |
| `gemm/192x192x192/b1` | 0.158643 ± 0.00419739 (W 0.0345946) | 0.0836375 ± 0.000197283 (W 0.000814875) | `lapack-openblas` 0.5273 (0.518 0.536) |
| `gemm/256x256x256/b1` | 0.209307 ± 0.0186323 (W 0.0214659) | 0.183731 ± 0.00105359 (W 0.00139262) | ! p `lapack-openblas` 0.8795 (0.829 0.933) |
| `gemm/384x384x384/b1` | 0.558242 ± 0.00166382 (W 0.0142257) | 0.553614 ± 0.00134067 (W 0.00339404) | `lapack-openblas` 0.9917 (0.996 0.988) |
| `gemm/512x512x512/b1` | 1.19703 ± 0.00165887 (W 0.0133818) | 1.31737 ± 0.00493348 (W 0.0015038) | `lapack-openblas` 1.101 (1.102 1.099) |
| `gemm/768x768x768/b1` | 3.92308 ± 0.000297692 (W 0.0161556) | 4.54904 ± 0.0168928 (W 0.0129169) | `lapack-openblas` 1.16 (1.157 1.163) |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133742 ± 0.000210718 (W 0.000604959) | 0.162614 ± 0.000317491 (W 0.000226235) | `lapack-openblas` 1.216 (1.213 1.219) |
| `gemm/192x192x192/b1` | 0.453404 ± 0.00267145 (W 0.00182073) | 0.53819 ± 0.00352705 (W 0.00187683) | `lapack-openblas` 1.187 (1.177 1.197) |
| `gemm/256x256x256/b1` | 1.07697 ± 0.00835022 (W 0.00137088) | 1.2696 ± 0.00182221 (W 0.00225349) | `lapack-openblas` 1.179 (1.184 1.174) |
| `gemm/384x384x384/b1` | 3.60835 ± 0.000811759 (W 0.00549522) | 4.24771 ± 0.00443568 (W 0.00837527) | `lapack-openblas` 1.177 (1.178 1.177) |
| `gemm/512x512x512/b1` | 8.60461 ± 0.0146675 (W 0.0182278) | 10.0813 ± 0.0388605 (W 0.0120791) | `lapack-openblas` 1.172 (1.167 1.176) |
| `gemm/768x768x768/b1` | 29.37 ± 0.0463084 (W 0.0334459) | 33.8768 ± 0.00422213 (W 0.228684) | `lapack-openblas` 1.153 (1.152 1.155) |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0884375 ± 0.000325976 (W 0.0152179) | 0.0501775 ± 0.00189434 (W 0.000922295) | ! `lapack-openblas` 0.5672 (0.554 0.581) |
| `gemm/192x192x192/b1` | 0.159145 ± 0.00677833 (W 0.0186208) | 0.148093 ± 0.00406233 (W 0.00128498) | ! p `lapack-openblas` 0.9308 (0.886 0.978) |
| `gemm/256x256x256/b1` | 0.304107 ± 0.00716653 (W 0.00283436) | 0.340458 ± 0.00469872 (W 0.00200063) | `lapack-openblas` 1.12 (1.127 1.112) |
| `gemm/384x384x384/b1` | 0.92939 ± 0.00440528 (W 0.00649856) | 1.09408 ± 0.00488187 (W 0.00689355) | `lapack-openblas` 1.177 (1.177 1.177) |
| `gemm/512x512x512/b1` | 2.23592 ± 0.00476944 (W 0.00670941) | 2.58384 ± 0.00941654 (W 0.00548245) | `lapack-openblas` 1.156 (1.151 1.160) |
| `gemm/768x768x768/b1` | 7.48233 ± 0.046621 (W 0.00633356) | 8.68764 ± 0.0119635 (W 0.00592657) | `lapack-openblas` 1.161 (1.155 1.167) |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0890035 ± 0.0131416 (W 0.0212524) | 0.028761 ± 0.00193606 (W 0.000164003) | ! p `lapack-openblas` 0.3246 (0.307 0.344) |
| `gemm/192x192x192/b1` | 0.170896 ± 0.00215809 (W 0.0324361) | 0.0839975 ± 0.00103591 (W 0.000879032) | `lapack-openblas` 0.4915 (0.483 0.500) |
| `gemm/256x256x256/b1` | 0.223924 ± 0.00104723 (W 0.0251162) | 0.181948 ± 0.00172393 (W 0.00189663) | `lapack-openblas` 0.8125 (0.810 0.815) |
| `gemm/384x384x384/b1` | 0.563538 ± 0.00250599 (W 0.0189956) | 0.552863 ± 0.00441517 (W 0.00233274) | `lapack-openblas` 0.981 (0.990 0.972) |
| `gemm/512x512x512/b1` | 1.18974 ± 0.0168058 (W 0.0126645) | 1.31253 ± 0.00488964 (W 0.00446017) | `lapack-openblas` 1.103 (1.095 1.111) |
| `gemm/768x768x768/b1` | 3.93472 ± 0.00615395 (W 0.0235658) | 4.53845 ± 0.00141633 (W 0.0321843) | `lapack-openblas` 1.153 (1.152 1.155) |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.540182 ± 0.000609526 (W 0.00235128) | 0.658743 ± 0.000501339 (W 0.0015875) | `lapack-openblas` 1.219 (1.220 1.219) |
| `gemm/192x192x192/b1` | 1.81755 ± 0.0012339 (W 0.00290703) | 2.17585 ± 0.00234264 (W 0.00151099) | `lapack-openblas` 1.197 (1.197 1.197) |
| `gemm/256x256x256/b1` | 4.28633 ± 0.0051739 (W 0.00580047) | 5.17669 ± 0.00994758 (W 0.00784644) | `lapack-openblas` 1.208 (1.207 1.208) |
| `gemm/384x384x384/b1` | 14.4421 ± 0.0091139 (W 0.0176181) | 17.3166 ± 0.0438166 (W 0.0261651) | `lapack-openblas` 1.199 (1.197 1.201) |
| `gemm/512x512x512/b1` | 34.3223 ± 0.0342699 (W 0.0214537) | 40.9596 ± 0.0431858 (W 0.0367382) | `lapack-openblas` 1.193 (1.193 1.193) |
| `gemm/768x768x768/b1` | 116.611 ± 0.0702171 (W 0.255661) | 137.418 ± 0.121757 (W 0.0817848) | `lapack-openblas` 1.178 (1.178 1.179) |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160442 ± 0.00167019 (W 0.00751244) | 0.176769 ± 0.00114198 (W 0.00174697) | `lapack-openblas` 1.102 (1.089 1.115) |
| `gemm/192x192x192/b1` | 0.472153 ± 0.00116248 (W 0.00435021) | 0.558872 ± 0.00401778 (W 0.0023204) | `lapack-openblas` 1.184 (1.180 1.188) |
| `gemm/256x256x256/b1` | 1.12411 ± 0.00423133 (W 0.00217808) | 1.33022 ± 0.00678893 (W 0.00234895) | `lapack-openblas` 1.183 (1.182 1.184) |
| `gemm/384x384x384/b1` | 3.66865 ± 0.0087858 (W 0.00403724) | 4.39818 ± 0.0144773 (W 0.00677045) | `lapack-openblas` 1.199 (1.198 1.200) |
| `gemm/512x512x512/b1` | 8.68331 ± 0.0187942 (W 0.011718) | 10.42 ± 0.0217817 (W 0.00864081) | `lapack-openblas` 1.2 (1.200 1.200) |
| `gemm/768x768x768/b1` | 29.3349 ± 0.0406855 (W 0.106857) | 34.7811 ± 0.0104807 (W 0.024717) | `lapack-openblas` 1.186 (1.187 1.184) |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.114728 ± 0.000977222 (W 0.0143064) | 0.094398 ± 6.92965e-05 (W 0.000827493) | `lapack-openblas` 0.8228 (0.828 0.817) |
| `gemm/192x192x192/b1` | 0.278921 ± 0.00138522 (W 0.0152222) | 0.295898 ± 0.000422143 (W 0.00241826) | `lapack-openblas` 1.061 (1.066 1.056) |
| `gemm/256x256x256/b1` | 0.604687 ± 0.00108046 (W 0.0111473) | 0.683559 ± 0.00233204 (W 0.00355058) | `lapack-openblas` 1.13 (1.132 1.129) |
| `gemm/384x384x384/b1` | 1.86947 ± 0.00662064 (W 0.00486877) | 2.19628 ± 0.00172605 (W 0.00407266) | `lapack-openblas` 1.175 (1.178 1.171) |
| `gemm/512x512x512/b1` | 4.50743 ± 0.00168079 (W 0.0098169) | 5.26525 ± 0.00211991 (W 0.00714674) | `lapack-openblas` 1.168 (1.169 1.167) |
| `gemm/768x768x768/b1` | 14.9855 ± 0.0333945 (W 0.0201219) | 17.765 ± 0.0048359 (W 0.024319) | `lapack-openblas` 1.185 (1.183 1.188) |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539897 ± 0.000164049 (W 0.00185946) | 0.659099 ± 0.000195869 (W 0.00698691) | `lapack-openblas` 1.221 (1.221 1.221) |
| `gemm/192x192x192/b1` | 1.81531 ± 0.00155069 (W 0.203215) | 2.18091 ± 0.00557271 (W 0.00243004) | `lapack-openblas` 1.201 (1.199 1.204) |
| `gemm/256x256x256/b1` | 4.27973 ± 0.00166948 (W 0.00209841) | 5.1718 ± 0.0100982 (W 0.00916945) | `lapack-openblas` 1.208 (1.207 1.210) |
| `gemm/384x384x384/b1` | 14.4305 ± 0.0282136 (W 0.023754) | 17.3236 ± 0.0582472 (W 0.0143139) | `lapack-openblas` 1.2 (1.199 1.202) |
| `gemm/512x512x512/b1` | 34.3173 ± 0.00681934 (W 0.0322032) | 40.9203 ± 0.106542 (W 0.0363647) | `lapack-openblas` 1.192 (1.190 1.194) |
| `gemm/768x768x768/b1` | 116.351 ± 0.00274004 (W 0.376632) | 137.435 ± 0.308802 (W 0.0536303) | `lapack-openblas` 1.181 (1.179 1.183) |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.160633 ± 0.00090439 (W 0.00413659) | 0.177225 ± 0.00239638 (W 0.00223984) | `lapack-openblas` 1.103 (1.088 1.118) |
| `gemm/192x192x192/b1` | 0.47311 ± 0.00234547 (W 0.00590458) | 0.56011 ± 0.0015026 (W 0.00155036) | `lapack-openblas` 1.184 (1.186 1.182) |
| `gemm/256x256x256/b1` | 1.12386 ± 0.00515339 (W 0.00419204) | 1.3286 ± 0.00418819 (W 0.00195743) | `lapack-openblas` 1.182 (1.183 1.181) |
| `gemm/384x384x384/b1` | 3.66476 ± 0.00174373 (W 0.00946992) | 4.39152 ± 0.0223219 (W 0.0038682) | `lapack-openblas` 1.198 (1.194 1.202) |
| `gemm/512x512x512/b1` | 8.68022 ± 0.0121283 (W 0.0115938) | 10.4149 ± 0.0284589 (W 0.012169) | `lapack-openblas` 1.2 (1.196 1.203) |
| `gemm/768x768x768/b1` | 29.3901 ± 0.0624962 (W 0.0146733) | 34.8254 ± 0.0785787 (W 0.207548) | `lapack-openblas` 1.185 (1.181 1.189) |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/128x128x128/b1` | 0.114056 ± 0.000240416 (W 0.0121979) | 0.0943025 ± 0.000317491 (W 0.000935569) | `lapack-openblas` 0.8268 (0.830 0.824) |
| `gemm/192x192x192/b1` | 0.278496 ± 0.0172555 (W 0.00940217) | 0.295358 ± 0.000393858 (W 0.00199385) | ! `lapack-openblas` 1.062 (1.017 1.108) |
| `gemm/256x256x256/b1` | 0.609746 ± 0.00287368 (W 0.00967025) | 0.680253 ± 0.0025866 (W 0.0024557) | `lapack-openblas` 1.116 (1.122 1.109) |
| `gemm/384x384x384/b1` | 1.86917 ± 0.0110493 (W 0.0118649) | 2.19826 ± 0.00434588 (W 0.00287836) | `lapack-openblas` 1.176 (1.173 1.179) |
| `gemm/512x512x512/b1` | 4.5046 ± 0.0101767 (W 0.0177863) | 5.27324 ± 0.00747553 (W 0.0103098) | `lapack-openblas` 1.171 (1.174 1.168) |
| `gemm/768x768x768/b1` | 14.9637 ± 0.0118688 (W 0.0354983) | 17.7709 ± 0.0559654 (W 0.0576357) | `lapack-openblas` 1.188 (1.190 1.186) |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.26889 ± 0.0067755 (W 0.00353902) | 1.64679 ± 0.00520289 (W 0.00185933) | `lapack-openblas` 1.298 (1.296 1.300) |
| `gemm/4096x16x240/b1` | 1.07666 ± 0.00145735 (W 0.00410345) | 1.45069 ± 0.0268566 (W 0.0054371) | `lapack-openblas` 1.347 (1.364 1.331) |
| `gemm/4096x64x64/b1` | 1.08702 ± 0.000963787 (W 0.00777855) | 1.36938 ± 0.00298399 (W 0.00196683) | `lapack-openblas` 1.26 (1.262 1.257) |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.439694 ± 0.00773928 (W 0.00407099) | 0.492571 ± 0.0187199 (W 0.00494876) | ! `lapack-openblas` 1.12 (1.077 1.165) |
| `gemm/4096x16x240/b1` | 0.330333 ± 0.0152785 (W 0.387793) | 0.473534 ± 0.000464569 (W 0.0241122) | ! `lapack-openblas` 1.434 (1.483 1.387) |
| `gemm/4096x64x64/b1` | 0.305034 ± 0.000930553 (W 0.00841959) | 0.346845 ± 0.00170271 (W 0.00183066) | `lapack-openblas` 1.137 (1.131 1.143) |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.444682 ± 0.000635689 (W 0.00364395) | 0.284303 ± 0.000475176 (W 0.00368533) | `lapack-openblas` 0.6393 (0.641 0.638) |
| `gemm/4096x16x240/b1` | 0.205452 ± 0.00885934 (W 0.00617437) | 0.313605 ± 0.000975807 (W 0.00147728) | ! `lapack-openblas` 1.527 (1.478 1.578) |
| `gemm/4096x64x64/b1` | 0.201865 ± 0.00125794 (W 0.0195193) | 0.179832 ± 0.000692965 (W 0.00144582) | `lapack-openblas` 0.8909 (0.892 0.889) |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.0468 ± 0.0112402 (W 0.00259959) | 1.69753 ± 0.00489389 (W 0.00744009) | `lapack-openblas` 1.622 (1.613 1.631) |
| `gemm/4096x16x240/b1` | 1.09626 ± 0.00879924 (W 0.00436738) | 1.41303 ± 0.0317922 (W 0.00842842) | `lapack-openblas` 1.289 (1.302 1.276) |
| `gemm/4096x64x64/b1` | 1.12916 ± 0.00282843 (W 0.00143929) | 1.3685 ± 0.0069445 (W 0.200424) | `lapack-openblas` 1.212 (1.214 1.210) |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.706862 ± 0.0294616 (W 0.0213451) | 0.430241 ± 0.000688722 (W 0.0030315) | ! `lapack-openblas` 0.6089 (0.592 0.626) |
| `gemm/4096x16x240/b1` | 0.313631 ± 0.0050346 (W 0.00228696) | 0.481655 ± 0.00825618 (W 0.00227588) | `lapack-openblas` 1.536 (1.535 1.537) |
| `gemm/4096x64x64/b1` | 0.310234 ± 0.00297975 (W 0.00477121) | 0.363842 ± 0.000303349 (W 0.00255581) | `lapack-openblas` 1.173 (1.182 1.164) |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.14024 ± 0.0159092 (W 0.0265592) | 0.223135 ± 0.00146442 (W 0.0027506) | `lapack-openblas` 0.1957 (0.199 0.193) |
| `gemm/4096x16x240/b1` | 0.196875 ± 0.00241194 (W 0.00575117) | 0.321284 ± 0.00163837 (W 0.00157123) | `lapack-openblas` 1.632 (1.624 1.640) |
| `gemm/4096x64x64/b1` | 0.184566 ± 0.00506854 (W 0.00349522) | 0.201719 ± 0.00752008 (W 0.00118367) | ! `lapack-openblas` 1.093 (1.100 1.085) |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.15537 ± 0.00526158 (W 0.0125312) | 6.01685 ± 0.0258539 (W 0.0167979) | `lapack-openblas` 1.448 (1.454 1.442) |
| `gemm/4096x16x240/b1` | 4.33384 ± 0.00352563 (W 0.0118273) | 5.73316 ± 0.0308652 (W 0.0112742) | `lapack-openblas` 1.323 (1.327 1.319) |
| `gemm/4096x64x64/b1` | 4.39987 ± 0.0233055 (W 0.00723962) | 5.40743 ± 0.000994192 (W 0.0088578) | `lapack-openblas` 1.229 (1.233 1.225) |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.67423 ± 0.00739422 (W 0.00453987) | 1.73228 ± 0.0486023 (W 0.00478633) | `lapack-openblas` 1.034 (1.052 1.017) |
| `gemm/4096x16x240/b1` | 1.206 ± 0.000524673 (W 0.00616963) | 1.67399 ± 8.90955e-05 (W 0.00376742) | `lapack-openblas` 1.388 (1.388 1.388) |
| `gemm/4096x64x64/b1` | 1.15222 ± 0.00518734 (W 0.00624234) | 1.38391 ± 0.00302217 (W 0.00332683) | `lapack-openblas` 1.201 (1.207 1.195) |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.921573 ± 0.000677408 (W 0.00474439) | 0.934407 ± 0.000497803 (W 0.00524795) | `lapack-openblas` 1.014 (1.013 1.015) |
| `gemm/4096x16x240/b1` | 0.633617 ± 0.00348957 (W 0.00531088) | 0.99836 ± 0.000552958 (W 0.00895717) | `lapack-openblas` 1.576 (1.582 1.569) |
| `gemm/4096x64x64/b1` | 0.605779 ± 0.00156129 (W 0.00856306) | 0.700927 ± 0.00279166 (W 0.00264197) | `lapack-openblas` 1.157 (1.158 1.156) |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07071 ± 0.00136472 (W 0.0103882) | 5.82627 ± 0.0083283 (W 0.0104749) | `lapack-openblas` 1.431 (1.429 1.433) |
| `gemm/4096x16x240/b1` | 4.35249 ± 0.00824345 (W 0.00712957) | 5.71168 ± 0.0127131 (W 0.0239331) | `lapack-openblas` 1.312 (1.313 1.312) |
| `gemm/4096x64x64/b1` | 4.46653 ± 0.0253781 (W 0.00651042) | 5.53459 ± 0.010695 (W 0.00524101) | `lapack-openblas` 1.239 (1.246 1.232) |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.95787 ± 0.00937199 (W 0.0317381) | 1.50418 ± 0.00915067 (W 0.00569291) | `lapack-openblas` 0.7683 (0.762 0.774) |
| `gemm/4096x16x240/b1` | 1.19331 ± 0.000580535 (W 0.0109422) | 1.74813 ± 0.00831699 (W 0.0064111) | `lapack-openblas` 1.465 (1.460 1.470) |
| `gemm/4096x64x64/b1` | 1.20315 ± 0.00404465 (W 0.00410473) | 1.44927 ± 0.00167231 (W 0.00306066) | `lapack-openblas` 1.205 (1.208 1.201) |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.52656 ± 0.0510305 (W 0.0548531) | 0.825667 ± 0.000870448 (W 0.00608723) | `lapack-openblas` 0.3268 (0.332 0.322) |
| `gemm/4096x16x240/b1` | 0.629003 ± 0.0133721 (W 0.00560078) | 0.999723 ± 0.000524673 (W 0.00207133) | `lapack-openblas` 1.59 (1.614 1.565) |
| `gemm/4096x64x64/b1` | 0.615487 ± 0.000258094 (W 0.00482519) | 0.76742 ± 0.00324774 (W 0.00318647) | `lapack-openblas` 1.247 (1.243 1.251) |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.14625 ± 0.0161885 (W 0.00429901) | 1.37045 ± 0.000266579 (W 0.00346195) | `lapack-openblas` 1.196 (1.207 1.184) |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.314955 ± 0.00396828 (W 0.0060502) | 0.364791 ± 0.00216658 (W 0.00173744) | `lapack-openblas` 1.158 (1.164 1.153) |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.177992 ± 0.0046266 (W 0.00471386) | 0.202358 ± 0.00644104 (W 0.00139529) | `lapack-openblas` 1.137 (1.142 1.132) |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.09448 ± 0.0186867 (W 0.00122368) | 1.36502 ± 0.0011639 (W 0.0023549) | `lapack-openblas` 1.247 (1.233 1.262) |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.309856 ± 0.010118 (W 0.00944854) | 0.347403 ± 0.000106066 (W 0.00191071) | `lapack-openblas` 1.121 (1.147 1.096) |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.201708 ± 0.003194 (W 0.0188998) | 0.178643 ± 0.000885298 (W 0.00297387) | `lapack-openblas` 0.8857 (0.899 0.873) |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.44589 ± 0.00417193 (W 0.00922052) | 5.57651 ± 0.00896046 (W 0.00972934) | `lapack-openblas` 1.254 (1.255 1.254) |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.20762 ± 0.0164438 (W 0.0103718) | 1.44929 ± 0.00418324 (W 0.004303) | `lapack-openblas` 1.2 (1.214 1.186) |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.617401 ± 0.00543765 (W 0.00307702) | 0.769147 ± 0.00389828 (W 0.0026381) | `lapack-openblas` 1.246 (1.258 1.234) |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.3803 ± 0.0138522 (W 0.00613546) | 5.41906 ± 0.00155493 (W 0.0067188) | `lapack-openblas` 1.237 (1.235 1.240) |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.14977 ± 0.00254134 (W 0.00433407) | 1.38685 ± 0.000956715 (W 0.0074969) | `lapack-openblas` 1.206 (1.205 1.207) |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.609451 ± 0.00263963 (W 0.0117304) | 0.697364 ± 0.00190495 (W 0.00211214) | `lapack-openblas` 1.144 (1.150 1.139) |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.003141 ± 7.07107e-06 (W 2.53927e-05) | 0.004083 ± 4.94975e-05 (W 4.88122e-05) | `lapack-openblas` 1.3 (1.313 1.287) |
| `cholesky/n64/b1` | 0.0149335 ± 6.43467e-05 (W 2.99038e-05) | 0.0180395 ± 0.000147785 (W 9.67872e-05) | `lapack-openblas` 1.208 (1.197 1.219) |
| `cholesky/n96/b1` | 0.030829 ± 4.10122e-05 (W 0.000551826) | 0.043879 ± 0.000373352 (W 0.000824368) | `lapack-openblas` 1.423 (1.416 1.431) |
| `eigh/n32/b1` | 0.113157 ± 0.00025173 (W 0.000800901) | 0.120862 ± 0.000108894 (W 0.00145767) | `lapack-openblas` 1.068 (1.069 1.067) |
| `eigh/n64/b1` | 0.485687 ± 0.00137815 (W 0.00195097) | 0.429855 ± 0.00152947 (W 0.00151606) | `lapack-openblas` 0.885 (0.885 0.885) |
| `eigh/n96/b1` | 1.16251 ± 0.00440386 (W 0.00212873) | 0.947407 ± 0.0015125 (W 0.00119756) | `lapack-openblas` 0.815 (0.812 0.818) |
| `full_piv_lu/n32/b1` | 0.0102045 ± 9.12168e-05 (W 0.000129554) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.046885 ± 7.63675e-05 (W 0.00106945) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.132956 ± 0.000377595 (W 0.00188068) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008116 ± 9.89949e-05 (W 4.26743e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008226 ± 1.41421e-05 (W 5.06483e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0404675 ± 0.000225567 (W 0.000637738) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040578 ± 5.79828e-05 (W 0.000831946) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.120827 ± 0.000328805 (W 0.00150826) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.121342 ± 0.000415072 (W 0.00101031) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.0073345 ± 0.000198697 (W 0.000178828) | 0.010104 ± 0.000275772 (W 0.000103698) | `lapack-openblas` 1.378 (1.326 1.432) |
| `lu/n64/b1` | 0.026326 ± 0.000263044 (W 0.000205267) | 0.0383085 ± 0.00064276 (W 0.000781256) | `lapack-openblas` 1.455 (1.428 1.483) |
| `lu/n96/b1` | 0.0658365 ± 0.000173241 (W 0.00128158) | 0.0971465 ± 0.000521138 (W 0.0020033) | `lapack-openblas` 1.476 (1.467 1.484) |
| `qr/n32/b1` | 0.031626 ± 7.63675e-05 (W 0.000338853) | 0.032382 ± 0.000622254 (W 0.000126743) | `lapack-openblas` 1.024 (1.012 1.036) |
| `qr/n64/b1` | 0.117726 ± 0.000250316 (W 0.000308356) | 0.128701 ± 0.00190141 (W 0.000497431) | `lapack-openblas` 1.093 (1.083 1.103) |
| `qr/n96/b1` | 0.286119 ± 0.0147396 (W 0.00276058) | 0.378661 ± 0.0141195 (W 0.00218255) | ! `lapack-openblas` 1.324 (1.337 1.311) |
| `qr_factor/n32/b1` | 0.024041 ± 2.12132e-05 (W 8.49033e-05) | 0.0174535 ± 0.00052538 (W 6.07122e-05) | `lapack-openblas` 0.7258 (0.742 0.710) |
| `qr_factor/n64/b1` | 0.105873 ± 0.000350018 (W 0.00135741) | 0.0661875 ± 0.000583363 (W 0.00125503) | `lapack-openblas` 0.6251 (0.631 0.620) |
| `qr_factor/n96/b1` | 0.227712 ± 0.000395273 (W 0.00141159) | 0.181003 ± 0.000822365 (W 0.00101495) | `lapack-openblas` 0.7949 (0.793 0.796) |
| `solve/n32/b1` | 0.008401 ± 0.000106066 (W 0.00090085) | 0.0104295 ± 2.89914e-05 (W 0.000647123) | `lapack-openblas` 1.242 (1.255 1.228) |
| `solve/n64/b1` | 0.0273475 ± 0.000345775 (W 0.000128511) | 0.0383235 ± 2.75772e-05 (W 7.17472e-05) | `lapack-openblas` 1.401 (1.413 1.390) |
| `solve/n96/b1` | 0.0680155 ± 9.40452e-05 (W 0.0024371) | 0.0897925 ± 0.000307591 (W 0.0013598) | `lapack-openblas` 1.32 (1.316 1.325) |
| `svd_thin/n32/b1` | 0.18499 ± 0.00250811 (W 0.00132832) | 0.183122 ± 0.00107056 (W 0.00113794) | `lapack-openblas` 0.9899 (0.995 0.985) |
| `svd_thin/n64/b1` | 0.924333 ± 0.00576363 (W 0.00352355) | 0.673536 ± 0.0151731 (W 0.00339307) | `lapack-openblas` 0.7286 (0.720 0.737) |
| `svd_thin/n96/b1` | 2.19308 ± 0.0283677 (W 0.00306366) | 1.62002 ± 0.0173291 (W 0.00529278) | `lapack-openblas` 0.7387 (0.751 0.726) |
| `svd_values/n32/b1` | 0.1407 ± 0.000660438 (W 0.000908342) | 0.077734 ± 2.40416e-05 (W 0.000698775) | `lapack-openblas` 0.5525 (0.554 0.551) |
| `svd_values/n64/b1` | 0.518034 ± 5.3033e-05 (W 0.00235486) | 0.276876 ± 0.00312895 (W 0.00204858) | `lapack-openblas` 0.5345 (0.530 0.539) |
| `svd_values/n96/b1` | 1.18364 ± 0.000205768 (W 0.00173861) | 0.65918 ± 0.00385161 (W 0.00212061) | `lapack-openblas` 0.5569 (0.555 0.559) |
| `triangular_solve/n32/b1` | 0.0007015 ± 1.48492e-05 (W 2.29778e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.001458 ± 7.07107e-06 (W 1.15902e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.002585 ± 7.07107e-05 (W 2.94485e-05) | - | * `lapack-openblas` - |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.003151 ± 2.12132e-05 (W 2.56897e-05) | 0.004153 ± 2.12132e-05 (W 0.000934949) | `lapack-openblas` 1.318 (1.320 1.316) |
| `cholesky/n64/b1` | 0.0148385 ± 7.07107e-07 (W 3.17752e-05) | 0.017844 ± 0.000282843 (W 0.00155193) | `lapack-openblas` 1.202 (1.189 1.216) |
| `cholesky/n96/b1` | 0.067103 ± 0.000954594 (W 0.00727177) | 0.043318 ± 0.000203647 (W 0.000112177) | `lapack-openblas` 0.6456 (0.650 0.641) |
| `eigh/n32/b1` | 0.112424 ± 0.000181726 (W 0.0016034) | 0.104119 ± 8.76812e-05 (W 0.00221156) | `lapack-openblas` 0.9261 (0.928 0.925) |
| `eigh/n64/b1` | 0.499149 ± 0.001154 (W 0.00451038) | 0.356542 ± 0.00319754 (W 0.00248759) | `lapack-openblas` 0.7143 (0.718 0.711) |
| `eigh/n96/b1` | 1.22283 ± 0.00612496 (W 0.0171772) | 0.759817 ± 0.00335876 (W 0.00189021) | `lapack-openblas` 0.6214 (0.617 0.626) |
| `full_piv_lu/n32/b1` | 0.01036 ± 1.41421e-05 (W 0.000154919) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.046379 ± 0.000154149 (W 0.000269429) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.132408 ± 0.000308299 (W 0.00252688) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008437 ± 8.48528e-05 (W 0.000621294) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0083865 ± 7.07107e-07 (W 6.33161e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.023605 ± 0.000155563 (W 0.00263361) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0237905 ± 0.000870448 (W 0.000805128) | - | * ! `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0490985 ± 4.87904e-05 (W 0.00101266) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0498405 ± 0.000416486 (W 0.000897922) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.007579 ± 4.94975e-05 (W 0.000173349) | 0.0099395 ± 0.000311834 (W 0.000113569) | `lapack-openblas` 1.311 (1.276 1.347) |
| `lu/n64/b1` | 0.0448555 ± 0.00188585 (W 0.00324072) | 0.0383435 ± 0.000480126 (W 0.000878517) | ! `lapack-openblas` 0.8552 (0.823 0.889) |
| `lu/n96/b1` | 0.101495 ± 0.0006965 (W 0.00408495) | 0.097151 ± 6.6468e-05 (W 0.00221027) | `lapack-openblas` 0.9572 (0.953 0.961) |
| `qr/n32/b1` | 0.112976 ± 0.00200041 (W 0.00451352) | 0.0326275 ± 0.000474469 (W 0.000106806) | `lapack-openblas` 0.2888 (0.282 0.295) |
| `qr/n64/b1` | 0.484516 ± 0.00828871 (W 0.0121763) | 0.127228 ± 0.00010253 (W 0.000777893) | `lapack-openblas` 0.2626 (0.259 0.266) |
| `qr/n96/b1` | 1.01103 ± 0.0299594 (W 0.0133292) | 0.383213 ± 0.0114735 (W 0.00292344) | `lapack-openblas` 0.379 (0.379 0.379) |
| `qr_factor/n32/b1` | 0.0866005 ± 0.00220547 (W 0.00348012) | 0.017283 ± 2.82843e-05 (W 0.000793708) | `lapack-openblas` 0.1996 (0.196 0.203) |
| `qr_factor/n64/b1` | 0.449535 ± 0.00483732 (W 0.00760899) | 0.0655505 ± 0.000983586 (W 0.000255971) | `lapack-openblas` 0.1458 (0.143 0.148) |
| `qr_factor/n96/b1` | 0.922929 ± 0.00625295 (W 0.0157815) | 0.185775 ± 0.00265872 (W 0.00137469) | `lapack-openblas` 0.2013 (0.198 0.204) |
| `solve/n32/b1` | 0.0082555 ± 0.000142128 (W 0.000152805) | 0.0102245 ± 0.000105359 (W 3.48751e-05) | `lapack-openblas` 1.239 (1.215 1.263) |
| `solve/n64/b1` | 0.042366 ± 0.00321026 (W 0.00363708) | 0.0377375 ± 0.000487197 (W 9.00643e-05) | ! p `lapack-openblas` 0.892 (0.838 0.950) |
| `solve/n96/b1` | 0.103063 ± 0.00414718 (W 0.00313774) | 0.0890905 ± 0.0014432 (W 0.00188034) | ! `lapack-openblas` 0.8647 (0.831 0.900) |
| `svd_thin/n32/b1` | 0.187724 ± 0.00171261 (W 0.00181641) | 0.181486 ± 0.000812466 (W 0.00150658) | `lapack-openblas` 0.9668 (0.964 0.970) |
| `svd_thin/n64/b1` | 0.94991 ± 0.00382121 (W 0.00185565) | 0.640169 ± 0.0158943 (W 0.0028936) | `lapack-openblas` 0.6738 (0.688 0.660) |
| `svd_thin/n96/b1` | 2.28992 ± 0.03314 (W 0.0162878) | 1.58723 ± 0.0123482 (W 0.00455485) | `lapack-openblas` 0.6932 (0.690 0.696) |
| `svd_values/n32/b1` | 0.140263 ± 0.000442649 (W 0.00109115) | 0.077689 ± 0.000295571 (W 0.00113285) | `lapack-openblas` 0.5539 (0.554 0.554) |
| `svd_values/n64/b1` | 0.5149 ± 0.00138169 (W 0.00166159) | 0.273297 ± 0.000424264 (W 0.00354406) | `lapack-openblas` 0.5308 (0.529 0.532) |
| `svd_values/n96/b1` | 1.18749 ± 0.00820102 (W 0.0017876) | 0.679018 ± 0.0308786 (W 0.00272085) | ! `lapack-openblas` 0.5715 (0.587 0.556) |
| `triangular_solve/n32/b1` | 0.000681 ± 0 (W 2.27098e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.0014825 ± 1.3435e-05 (W 2.17901e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.002525 ± 0 (W 1.43753e-05) | - | * `lapack-openblas` - |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.003186 ± 4.24264e-05 (W 4.78987e-05) | 0.004043 ± 7.77817e-05 (W 3.77382e-05) | `lapack-openblas` 1.269 (1.274 1.264) |
| `cholesky/n64/b1` | 0.0149835 ± 2.05061e-05 (W 3.85508e-05) | 0.017764 ± 1.41421e-05 (W 8.49844e-05) | `lapack-openblas` 1.186 (1.186 1.185) |
| `cholesky/n96/b1` | 0.069362 ± 0.00192899 (W 0.000879492) | 0.043368 ± 0.000586899 (W 0.000661491) | `lapack-openblas` 0.6253 (0.607 0.644) |
| `eigh/n32/b1` | 0.113201 ± 0.000685894 (W 0.00173027) | 0.102265 ± 0.000526087 (W 0.000746655) | `lapack-openblas` 0.9034 (0.911 0.896) |
| `eigh/n64/b1` | 0.507082 ± 0.000209304 (W 0.002558) | 0.345865 ± 0.000863377 (W 0.00155358) | `lapack-openblas` 0.6821 (0.683 0.681) |
| `eigh/n96/b1` | 1.2343 ± 0.00509046 (W 0.0152007) | 0.740106 ± 0.0025569 (W 0.00136208) | `lapack-openblas` 0.5996 (0.600 0.599) |
| `full_piv_lu/n32/b1` | 0.010866 ± 0.000616597 (W 0.000115093) | - | * ! `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.0465935 ± 0.000532451 (W 0.000233977) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.133244 ± 0.000994899 (W 0.00210131) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008456 ± 1.41421e-05 (W 5.55597e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008491 ± 9.19239e-05 (W 0.000133505) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.026987 ± 0.000362039 (W 0.000892609) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.027066 ± 0.000673166 (W 0.00140356) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.06038 ± 0.00139441 (W 0.00329479) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.06323 ± 0.000579828 (W 0.0021337) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.007289 ± 7.07107e-06 (W 7.31362e-05) | 0.0100145 ± 0.000333047 (W 0.000125151) | `lapack-openblas` 1.374 (1.341 1.407) |
| `lu/n64/b1` | 0.05246 ± 0.000608112 (W 0.00302531) | 0.0382635 ± 5.58614e-05 (W 0.000128735) | `lapack-openblas` 0.7294 (0.735 0.724) |
| `lu/n96/b1` | 0.118687 ± 0.00497662 (W 0.00211825) | 0.0942245 ± 0.00417122 (W 0.00110945) | ! p `lapack-openblas` 0.7939 (0.747 0.844) |
| `qr/n32/b1` | 0.141995 ± 0.000789838 (W 0.00928092) | 0.0318855 ± 0.00024678 (W 0.000173209) | `lapack-openblas` 0.2246 (0.222 0.227) |
| `qr/n64/b1` | 0.664753 ± 0.0139222 (W 0.0169192) | 0.128045 ± 0.00139936 (W 0.000671479) | `lapack-openblas` 0.1926 (0.194 0.191) |
| `qr/n96/b1` | 1.37796 ± 0.00695652 (W 0.0349956) | 0.370316 ± 0.0036911 (W 0.00432863) | `lapack-openblas` 0.2687 (0.266 0.272) |
| `qr_factor/n32/b1` | 0.116036 ± 0.00142128 (W 0.00626259) | 0.0170775 ± 6.43467e-05 (W 7.56047e-05) | `lapack-openblas` 0.1472 (0.149 0.146) |
| `qr_factor/n64/b1` | 0.60002 ± 0.00139371 (W 0.018029) | 0.0654595 ± 0.000560736 (W 0.000151201) | `lapack-openblas` 0.1091 (0.110 0.109) |
| `qr_factor/n96/b1` | 1.21763 ± 0.00520289 (W 0.0110731) | 0.183926 ± 0.00106632 (W 0.00119377) | `lapack-openblas` 0.1511 (0.151 0.151) |
| `solve/n32/b1` | 0.008286 ± 5.65685e-05 (W 0.000169008) | 0.0104145 ± 7.84889e-05 (W 6.43626e-05) | `lapack-openblas` 1.257 (1.258 1.256) |
| `solve/n64/b1` | 0.048968 ± 0.000459619 (W 0.00364175) | 0.0380275 ± 0.000842164 (W 0.000585432) | `lapack-openblas` 0.7765 (0.770 0.784) |
| `solve/n96/b1` | 0.121797 ± 0.00255973 (W 0.00445332) | 0.0899715 ± 0.00147149 (W 0.000220952) | `lapack-openblas` 0.7387 (0.719 0.759) |
| `svd_thin/n32/b1` | 0.183259 ± 0.00010253 (W 0.00096195) | 0.181301 ± 0.00118723 (W 0.00133982) | `lapack-openblas` 0.9893 (0.993 0.985) |
| `svd_thin/n64/b1` | 0.965982 ± 0.00807092 (W 0.00492704) | 0.637601 ± 0.0102099 (W 0.00236364) | `lapack-openblas` 0.66 (0.656 0.664) |
| `svd_thin/n96/b1` | 2.38588 ± 0.00916693 (W 0.0156411) | 1.52426 ± 0.0773469 (W 0.00162677) | ! `lapack-openblas` 0.6385 (0.614 0.664) |
| `svd_values/n32/b1` | 0.141074 ± 0.000548715 (W 0.00167283) | 0.0780335 ± 0.000374059 (W 0.000186559) | `lapack-openblas` 0.5531 (0.550 0.557) |
| `svd_values/n64/b1` | 0.519116 ± 0.000109602 (W 0.00190663) | 0.273973 ± 0.000731856 (W 0.00186895) | `lapack-openblas` 0.5278 (0.527 0.529) |
| `svd_values/n96/b1` | 1.18491 ± 0.00442437 (W 0.00191047) | 0.65816 ± 0.00479701 (W 0.0014836) | `lapack-openblas` 0.5554 (0.554 0.557) |
| `triangular_solve/n32/b1` | 0.000681 ± 1.41421e-05 (W 1.59528e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.001558 ± 7.07107e-06 (W 2.05865e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.0026605 ± 3.60624e-05 (W 3.98791e-05) | - | * `lapack-openblas` - |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.003046 ± 0 (W 2.50348e-05) | 0.003452 ± 3.53553e-05 (W 3.23521e-05) | `lapack-openblas` 1.133 (1.141 1.125) |
| `cholesky/n64/b1` | 0.0145785 ± 1.3435e-05 (W 2.34543e-05) | 0.015114 ± 0.000120208 (W 7.4848e-05) | `lapack-openblas` 1.037 (1.032 1.042) |
| `cholesky/n96/b1` | 0.0299675 ± 7.07107e-07 (W 7.01256e-05) | 0.0366905 ± 0.000197283 (W 0.00015794) | `lapack-openblas` 1.224 (1.220 1.229) |
| `eigh/n32/b1` | 0.113237 ± 0.000377595 (W 0.00104904) | 0.119729 ± 0.000316077 (W 0.000145638) | `lapack-openblas` 1.057 (1.062 1.053) |
| `eigh/n64/b1` | 0.484017 ± 0.000450427 (W 0.00195178) | 0.426764 ± 0.00109814 (W 0.00156335) | `lapack-openblas` 0.8817 (0.881 0.883) |
| `eigh/n96/b1` | 1.15678 ± 0.00229103 (W 0.00182295) | 0.934596 ± 8.27315e-05 (W 0.00135561) | `lapack-openblas` 0.8079 (0.809 0.807) |
| `full_piv_lu/n32/b1` | 0.0104405 ± 0.000396687 (W 0.000619004) | - | * ! `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.0451165 ± 0.000224153 (W 0.000210723) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.131297 ± 0.000408708 (W 0.00211187) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0081855 ± 1.48492e-05 (W 3.7624e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0082655 ± 5.72756e-05 (W 0.000894727) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0400715 ± 0.000105359 (W 0.00121923) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0401615 ± 0.000147785 (W 5.89332e-05) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.123056 ± 0.000103238 (W 0.000779439) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.122745 ± 9.19239e-06 (W 0.000135703) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.0070885 ± 2.05061e-05 (W 0.000121148) | 0.0087115 ± 6.36396e-06 (W 8.55988e-05) | `lapack-openblas` 1.229 (1.231 1.227) |
| `lu/n64/b1` | 0.025734 ± 0.000192333 (W 0.000204782) | 0.033845 ± 0.000480833 (W 0.000144681) | `lapack-openblas` 1.315 (1.295 1.335) |
| `lu/n96/b1` | 0.0636475 ± 0.000222739 (W 0.00216045) | 0.078646 ± 4.6669e-05 (W 0.000626867) | `lapack-openblas` 1.236 (1.232 1.239) |
| `qr/n32/b1` | 0.0314455 ± 0.000119501 (W 0.000222094) | 0.029917 ± 0.000154149 (W 0.00014975) | `lapack-openblas` 0.9514 (0.950 0.952) |
| `qr/n64/b1` | 0.115381 ± 5.16188e-05 (W 0.00111806) | 0.11984 ± 0.000343654 (W 0.00139735) | `lapack-openblas` 1.039 (1.041 1.036) |
| `qr/n96/b1` | 0.277812 ± 0.0142588 (W 0.00282932) | 0.341295 ± 0.00290621 (W 0.00219064) | ! `lapack-openblas` 1.229 (1.267 1.193) |
| `qr_factor/n32/b1` | 0.017724 ± 1.55563e-05 (W 7.57108e-05) | 0.016381 ± 0.000482247 (W 0.000106634) | `lapack-openblas` 0.924 (0.943 0.906) |
| `qr_factor/n64/b1` | 0.0749585 ± 0.000358503 (W 0.001615) | 0.0614425 ± 0.000844993 (W 0.00154737) | `lapack-openblas` 0.8197 (0.830 0.809) |
| `qr_factor/n96/b1` | 0.163614 ± 0.000702864 (W 0.000962014) | 0.170351 ± 0.000822365 (W 0.00127992) | `lapack-openblas` 1.041 (1.041 1.042) |
| `solve/n32/b1` | 0.0078105 ± 2.19203e-05 (W 8.66688e-05) | 0.009047 ± 7.07107e-05 (W 5.33162e-05) | `lapack-openblas` 1.158 (1.162 1.154) |
| `solve/n64/b1` | 0.025779 ± 0.000367696 (W 9.02641e-05) | 0.033314 ± 5.51543e-05 (W 6.05256e-05) | `lapack-openblas` 1.292 (1.304 1.281) |
| `solve/n96/b1` | 0.0654905 ± 0.000122329 (W 0.00279014) | 0.0778295 ± 0.000399515 (W 0.00102766) | `lapack-openblas` 1.188 (1.191 1.186) |
| `svd_thin/n32/b1` | 0.187068 ± 0.00323784 (W 0.000994897) | 0.176368 ± 0.00087257 (W 0.00129332) | `lapack-openblas` 0.9429 (0.951 0.935) |
| `svd_thin/n64/b1` | 0.969038 ± 0.00815577 (W 0.00198554) | 0.636976 ± 0.0137858 (W 0.0025323) | `lapack-openblas` 0.6573 (0.651 0.663) |
| `svd_thin/n96/b1` | 2.18855 ± 0.0288351 (W 0.0033109) | 1.53027 ± 0.0495816 (W 0.00341827) | `lapack-openblas` 0.6991 (0.690 0.709) |
| `svd_values/n32/b1` | 0.142548 ± 0.000469519 (W 0.00129585) | 0.0741675 ± 1.06066e-05 (W 0.000120262) | `lapack-openblas` 0.5203 (0.522 0.519) |
| `svd_values/n64/b1` | 0.540316 ± 0.00275772 (W 0.00202141) | 0.271155 ± 0.00322865 (W 0.00150525) | `lapack-openblas` 0.5018 (0.499 0.504) |
| `svd_values/n96/b1` | 1.18945 ± 0.00048154 (W 0.00326095) | 0.653223 ± 0.00310844 (W 0.0024714) | `lapack-openblas` 0.5492 (0.547 0.551) |
| `triangular_solve/n32/b1` | 0.000737 ± 7.07107e-06 (W 2.15941e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.001713 ± 1.41421e-05 (W 1.1716e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.002881 ± 7.07107e-06 (W 2.55775e-05) | - | * `lapack-openblas` - |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.003091 ± 4.94975e-05 (W 7.2704e-05) | 0.003512 ± 3.53553e-05 (W 2.95078e-05) | `lapack-openblas` 1.136 (1.115 1.157) |
| `cholesky/n64/b1` | 0.014613 ± 9.19239e-05 (W 3.55392e-05) | 0.014959 ± 8.48528e-05 (W 9.20561e-05) | `lapack-openblas` 1.024 (1.015 1.032) |
| `cholesky/n96/b1` | 0.061257 ± 0.00098005 (W 0.00615212) | 0.03662 ± 1.41421e-05 (W 0.000187396) | `lapack-openblas` 0.5978 (0.591 0.604) |
| `eigh/n32/b1` | 0.113032 ± 0.00040093 (W 0.00199878) | 0.103081 ± 0.000350018 (W 0.000744901) | `lapack-openblas` 0.912 (0.916 0.908) |
| `eigh/n64/b1` | 0.501203 ± 0.00197707 (W 0.00236364) | 0.349097 ± 0.00145381 (W 0.0016754) | `lapack-openblas` 0.6965 (0.701 0.693) |
| `eigh/n96/b1` | 1.21937 ± 0.00580535 (W 0.026637) | 0.750709 ± 8.69741e-05 (W 0.00185393) | `lapack-openblas` 0.6157 (0.618 0.614) |
| `full_piv_lu/n32/b1` | 0.010139 ± 7.07107e-05 (W 8.51308e-05) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.0451915 ± 0.000207182 (W 0.000267016) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.130921 ± 0.000492146 (W 0.00226325) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008401 ± 2.12132e-05 (W 9.002e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008466 ± 1.41421e-05 (W 6.38733e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.02343 ± 0.000120208 (W 0.000655738) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0241315 ± 0.000799738 (W 0.000423257) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.050401 ± 1.9799e-05 (W 0.00181522) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.050632 ± 0.001055 (W 0.00184209) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.0071785 ± 2.19203e-05 (W 0.000103563) | 0.008847 ± 0.000127279 (W 0.000113188) | `lapack-openblas` 1.232 (1.217 1.248) |
| `lu/n64/b1` | 0.042291 ± 0.00373918 (W 0.00308897) | 0.033579 ± 0.000106066 (W 0.000786674) | ! p `lapack-openblas` 0.7956 (0.845 0.749) |
| `lu/n96/b1` | 0.098939 ± 0.000308299 (W 0.00467886) | 0.0775485 ± 1.62635e-05 (W 0.000110214) | `lapack-openblas` 0.7838 (0.786 0.782) |
| `qr/n32/b1` | 0.11237 ± 0.0083778 (W 0.0100497) | 0.029842 ± 0.000417193 (W 0.000107836) | ! `lapack-openblas` 0.2659 (0.278 0.255) |
| `qr/n64/b1` | 0.475514 ± 0.00087257 (W 0.00811673) | 0.117705 ± 0.00118723 (W 0.00119884) | `lapack-openblas` 0.2475 (0.246 0.249) |
| `qr/n96/b1` | 1.00036 ± 0.0356912 (W 0.0131358) | 0.344058 ± 0.00101611 (W 0.002317) | ! `lapack-openblas` 0.344 (0.336 0.352) |
| `qr_factor/n32/b1` | 0.0838755 ± 0.0012933 (W 0.00401611) | 0.0162605 ± 0.000368403 (W 9.66137e-05) | `lapack-openblas` 0.1939 (0.193 0.195) |
| `qr_factor/n64/b1` | 0.417589 ± 0.0112055 (W 0.00639647) | 0.0614975 ± 0.00123107 (W 0.000797156) | `lapack-openblas` 0.1473 (0.142 0.152) |
| `qr_factor/n96/b1` | 0.825909 ± 0.00607405 (W 0.009576) | 0.173447 ± 0.000512652 (W 0.00148148) | `lapack-openblas` 0.21 (0.208 0.212) |
| `solve/n32/b1` | 0.0079605 ± 0.0001492 (W 0.000709741) | 0.009048 ± 8.48528e-05 (W 5.24461e-05) | `lapack-openblas` 1.137 (1.114 1.160) |
| `solve/n64/b1` | 0.0432675 ± 0.00350796 (W 0.00140214) | 0.0333135 ± 0.000184555 (W 0.000907299) | ! p `lapack-openblas` 0.7712 (0.731 0.814) |
| `solve/n96/b1` | 0.09908 ± 0.00232072 (W 0.00254904) | 0.077353 ± 0.000306884 (W 0.00153985) | `lapack-openblas` 0.7808 (0.796 0.766) |
| `svd_thin/n32/b1` | 0.189593 ± 0.000869741 (W 0.00181505) | 0.174909 ± 0.00109319 (W 0.0012402) | `lapack-openblas` 0.9225 (0.916 0.930) |
| `svd_thin/n64/b1` | 0.993569 ± 0.00426668 (W 0.00191462) | 0.61488 ± 0.0017614 (W 0.00211383) | `lapack-openblas` 0.6189 (0.619 0.618) |
| `svd_thin/n96/b1` | 2.27814 ± 0.0187348 (W 0.0202602) | 1.45711 ± 0.00317774 (W 0.00253083) | `lapack-openblas` 0.6396 (0.642 0.637) |
| `svd_values/n32/b1` | 0.141831 ± 2.40416e-05 (W 0.000890047) | 0.074467 ± 0.000585484 (W 0.000616582) | `lapack-openblas` 0.525 (0.522 0.528) |
| `svd_values/n64/b1` | 0.537161 ± 0.00184908 (W 0.00191665) | 0.267501 ± 0.00146654 (W 0.00179191) | `lapack-openblas` 0.498 (0.495 0.501) |
| `svd_values/n96/b1` | 1.19221 ± 0.00800303 (W 0.00195009) | 0.660492 ± 0.00902975 (W 0.00187172) | `lapack-openblas` 0.554 (0.557 0.551) |
| `triangular_solve/n32/b1` | 0.000736 ± 7.07107e-06 (W 2.27298e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.001693 ± 1.41421e-05 (W 1.12918e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.0028805 ± 7.77817e-06 (W 1.74666e-05) | - | * `lapack-openblas` - |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.003066 ± 4.24264e-05 (W 2.90743e-05) | 0.003356 ± 1.41421e-05 (W 3.10958e-05) | `lapack-openblas` 1.095 (1.087 1.102) |
| `cholesky/n64/b1` | 0.014638 ± 0.000254558 (W 3.6608e-05) | 0.0150685 ± 5.58614e-05 (W 6.64509e-05) | `lapack-openblas` 1.029 (1.039 1.020) |
| `cholesky/n96/b1` | 0.0685555 ± 0.00200323 (W 0.00138316) | 0.0365955 ± 3.46482e-05 (W 0.000104041) | `lapack-openblas` 0.5339 (0.545 0.523) |
| `eigh/n32/b1` | 0.113432 ± 0.000699329 (W 0.000469472) | 0.101008 ± 5.16188e-05 (W 0.00160924) | `lapack-openblas` 0.8905 (0.895 0.886) |
| `eigh/n64/b1` | 0.511526 ± 0.0122747 (W 0.0115567) | 0.342553 ± 0.000927724 (W 0.00173936) | `lapack-openblas` 0.6698 (0.683 0.657) |
| `eigh/n96/b1` | 1.24238 ± 0.00406233 (W 0.0130744) | 0.728599 ± 0.00361332 (W 0.00180597) | `lapack-openblas` 0.5865 (0.583 0.590) |
| `full_piv_lu/n32/b1` | 0.0101845 ± 0.000163342 (W 0.000116747) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.046168 ± 0.00126148 (W 0.000901461) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.131416 ± 0.000604576 (W 0.00237638) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008476 ± 0.000141421 (W 9.40936e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008456 ± 1.41421e-05 (W 7.78747e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.028529 ± 0.00176352 (W 0.0013647) | - | * ! `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.027011 ± 0.00123319 (W 0.000862575) | - | * ! `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0627645 ± 0.00135128 (W 0.00183304) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.063395 ± 0.00304056 (W 0.00183898) | - | * ! `lapack-openblas` - |
| `lu/n32/b1` | 0.0072185 ± 3.46482e-05 (W 0.000106974) | 0.008947 ± 0.000127279 (W 6.04523e-05) | `lapack-openblas` 1.239 (1.248 1.231) |
| `lu/n64/b1` | 0.0520345 ± 0.000249609 (W 0.0036406) | 0.0335245 ± 4.31335e-05 (W 0.000152584) | `lapack-openblas` 0.6443 (0.643 0.646) |
| `lu/n96/b1` | 0.119252 ± 0.00200253 (W 0.00415363) | 0.0775835 ± 0.000161927 (W 0.000212136) | `lapack-openblas` 0.6506 (0.657 0.644) |
| `qr/n32/b1` | 0.143138 ± 0.000576999 (W 0.00405813) | 0.0297765 ± 0.000468812 (W 0.000157535) | `lapack-openblas` 0.208 (0.210 0.206) |
| `qr/n64/b1` | 0.652494 ± 0.0276012 (W 0.0124578) | 0.118681 ± 0.00213476 (W 0.00111186) | ! `lapack-openblas` 0.182 (0.190 0.174) |
| `qr/n96/b1` | 1.3919 ± 0.0272328 (W 0.496197) | 0.340504 ± 7.07107e-07 (W 0.00498105) | `lapack-openblas` 0.2447 (0.248 0.241) |
| `qr_factor/n32/b1` | 0.109579 ± 0.00328451 (W 0.00761781) | 0.0160205 ± 0.000154856 (W 0.000110601) | `lapack-openblas` 0.1462 (0.148 0.144) |
| `qr_factor/n64/b1` | 0.575111 ± 0.0143762 (W 0.0197718) | 0.0615775 ± 0.00119147 (W 0.00019664) | `lapack-openblas` 0.1071 (0.110 0.104) |
| `qr_factor/n96/b1` | 1.13662 ± 0.00632153 (W 0.0166003) | 0.171818 ± 0.000748119 (W 0.00105713) | `lapack-openblas` 0.1512 (0.150 0.152) |
| `solve/n32/b1` | 0.00786 ± 3.53553e-05 (W 4.66258e-05) | 0.008967 ± 7.07107e-05 (W 7.7935e-05) | `lapack-openblas` 1.141 (1.131 1.151) |
| `solve/n64/b1` | 0.0519145 ± 0.000700743 (W 0.0035711) | 0.033754 ± 0.000240416 (W 8.67542e-05) | `lapack-openblas` 0.6502 (0.653 0.647) |
| `solve/n96/b1` | 0.119644 ± 0.00206404 (W 0.00324449) | 0.077328 ± 8.6267e-05 (W 9.53612e-05) | `lapack-openblas` 0.6464 (0.639 0.654) |
| `svd_thin/n32/b1` | 0.185063 ± 0.000675994 (W 0.00179494) | 0.173731 ± 0.000804688 (W 0.00158189) | `lapack-openblas` 0.9388 (0.938 0.939) |
| `svd_thin/n64/b1` | 1.02113 ± 0.00783545 (W 0.0101107) | 0.616416 ± 5.86899e-05 (W 0.001876) | `lapack-openblas` 0.6037 (0.600 0.607) |
| `svd_thin/n96/b1` | 2.3537 ± 0.0410143 (W 0.0128708) | 1.4546 ± 0.0164141 (W 0.00208491) | `lapack-openblas` 0.618 (0.621 0.615) |
| `svd_values/n32/b1` | 0.142356 ± 9.54594e-05 (W 0.00143554) | 0.0743865 ± 0.000572049 (W 0.000141802) | `lapack-openblas` 0.5225 (0.519 0.526) |
| `svd_values/n64/b1` | 0.540461 ± 0.0026467 (W 0.0016004) | 0.267585 ± 0.000125865 (W 0.00147095) | `lapack-openblas` 0.4951 (0.494 0.497) |
| `svd_values/n96/b1` | 1.18964 ± 0.00414152 (W 0.0028676) | 0.653687 ± 0.00158745 (W 0.00193527) | `lapack-openblas` 0.5495 (0.550 0.549) |
| `triangular_solve/n32/b1` | 0.000732 ± 0 (W 1.38716e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.0018135 ± 0.000127986 (W 3.47846e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.00284 ± 3.53553e-05 (W 2.00487e-05) | - | * `lapack-openblas` - |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.0051495 ± 2.89914e-05 (W 2.31573e-05) | 0.006603 ± 8.48528e-05 (W 4.6101e-05) | `lapack-openblas` 1.282 (1.266 1.299) |
| `cholesky/n64/b1` | 0.0301825 ± 0.000204354 (W 0.000684058) | 0.03908 ± 0.000391737 (W 0.000201475) | `lapack-openblas` 1.295 (1.310 1.279) |
| `cholesky/n96/b1` | 0.083761 ± 1.69706e-05 (W 0.000175621) | 0.0954475 ± 0.00036416 (W 0.000293028) | `lapack-openblas` 1.14 (1.142 1.137) |
| `eigh/n32/b1` | 0.142578 ± 0.000243952 (W 0.000861915) | 0.15142 ± 0.000345068 (W 0.0010943) | `lapack-openblas` 1.062 (1.065 1.059) |
| `eigh/n64/b1` | 0.652599 ± 0.00272873 (W 0.0022481) | 0.658575 ± 0.00094823 (W 0.00198377) | `lapack-openblas` 1.009 (1.013 1.005) |
| `eigh/n96/b1` | 1.62201 ± 0.00240911 (W 0.00245479) | 1.6368 ± 0.0084174 (W 0.0040048) | `lapack-openblas` 1.009 (1.014 1.004) |
| `full_piv_lu/n32/b1` | 0.0159005 ± 0.000127986 (W 8.70901e-05) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.0926325 ± 0.000279307 (W 0.0012535) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.268645 ± 9.19239e-06 (W 0.00179466) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0280135 ± 0.000140714 (W 0.000103844) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0280935 ± 0.000154856 (W 0.00013688) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.159195 ± 0.000547301 (W 0.00140857) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.159521 ± 0.000200111 (W 0.00141244) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.466398 ± 0.00261417 (W 0.00178519) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.467099 ± 0.000148492 (W 0.000821319) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.0116525 ± 7.14178e-05 (W 5.97949e-05) | 0.014002 ± 9.19239e-05 (W 0.000505367) | `lapack-openblas` 1.202 (1.201 1.202) |
| `lu/n64/b1` | 0.0546495 ± 0.000160513 (W 0.000137373) | 0.0682505 ± 0.000224153 (W 0.000406342) | `lapack-openblas` 1.249 (1.249 1.249) |
| `lu/n96/b1` | 0.143726 ± 0.000207182 (W 0.000897624) | 0.182249 ± 0.000984293 (W 0.00172815) | `lapack-openblas` 1.268 (1.274 1.262) |
| `qr/n32/b1` | 0.0682455 ± 0.000350018 (W 0.000877394) | 0.0542945 ± 0.000341533 (W 0.000816379) | `lapack-openblas` 0.7956 (0.796 0.795) |
| `qr/n64/b1` | 0.313305 ± 0.000946109 (W 0.00239848) | 0.265273 ± 0.00355816 (W 0.00175726) | `lapack-openblas` 0.8467 (0.857 0.837) |
| `qr/n96/b1` | 0.766889 ± 0.00149765 (W 0.00250653) | 0.734627 ± 0.00188939 (W 0.00269751) | `lapack-openblas` 0.9579 (0.955 0.961) |
| `qr_factor/n32/b1` | 0.0400315 ± 0.000306177 (W 0.000271825) | 0.030373 ± 0.000390323 (W 0.000830819) | `lapack-openblas` 0.7587 (0.762 0.756) |
| `qr_factor/n64/b1` | 0.207257 ± 0.00111299 (W 0.00163896) | 0.138485 ± 0.000444063 (W 0.0015104) | `lapack-openblas` 0.6682 (0.672 0.664) |
| `qr_factor/n96/b1` | 0.465442 ± 0.000326683 (W 0.00205437) | 0.375835 ± 0.000103945 (W 0.0018419) | `lapack-openblas` 0.8075 (0.807 0.808) |
| `solve/n32/b1` | 0.012855 ± 0 (W 5.77668e-05) | 0.0155005 ± 7.07107e-07 (W 8.46106e-05) | `lapack-openblas` 1.206 (1.206 1.206) |
| `solve/n64/b1` | 0.056834 ± 0.000405879 (W 0.000849003) | 0.072439 ± 0.000441235 (W 0.000294034) | `lapack-openblas` 1.275 (1.274 1.276) |
| `solve/n96/b1` | 0.147417 ± 0.000144957 (W 0.00193338) | 0.191737 ± 0.000219203 (W 0.00187758) | `lapack-openblas` 1.301 (1.303 1.299) |
| `svd_thin/n32/b1` | 0.236127 ± 0.000184555 (W 0.0015409) | 0.229484 ± 0.0005671 (W 0.00190503) | `lapack-openblas` 0.9719 (0.974 0.970) |
| `svd_thin/n64/b1` | 1.2253 ± 0.000294864 (W 0.00175182) | 0.960374 ± 0.00132653 (W 0.00136115) | `lapack-openblas` 0.7838 (0.785 0.783) |
| `svd_thin/n96/b1` | 3.13292 ± 0.00774141 (W 0.00395476) | 2.65737 ± 0.138097 (W 0.00538185) | ! `lapack-openblas` 0.8476 (0.816 0.881) |
| `svd_values/n32/b1` | 0.161345 ± 2.6163e-05 (W 0.00147117) | 0.103658 ± 0.000626497 (W 0.001318) | `lapack-openblas` 0.6425 (0.645 0.640) |
| `svd_values/n64/b1` | 0.653627 ± 2.89914e-05 (W 0.00184276) | 0.410937 ± 0.00146088 (W 0.00187286) | `lapack-openblas` 0.6287 (0.627 0.630) |
| `svd_values/n96/b1` | 1.51185 ± 0.00226203 (W 0.00321429) | 1.0234 ± 0.00156341 (W 0.00148923) | `lapack-openblas` 0.6769 (0.678 0.675) |
| `triangular_solve/n32/b1` | 0.001077 ± 2.12132e-05 (W 3.11951e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.00272 ± 7.07107e-06 (W 2.8868e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.004945 ± 7.07107e-06 (W 3.67725e-05) | - | * `lapack-openblas` - |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.005165 ± 6.36396e-05 (W 4.12838e-05) | 0.006638 ± 0.000176777 (W 5.811e-05) | `lapack-openblas` 1.285 (1.321 1.250) |
| `cholesky/n64/b1` | 0.0300775 ± 8.55599e-05 (W 7.75204e-05) | 0.038684 ± 0.000511945 (W 0.000627328) | `lapack-openblas` 1.286 (1.296 1.277) |
| `cholesky/n96/b1` | 0.102982 ± 0.00071842 (W 0.00203277) | 0.094641 ± 0.00256255 (W 0.00093982) | `lapack-openblas` 0.9188 (0.897 0.941) |
| `eigh/n32/b1` | 0.141685 ± 7.56604e-05 (W 0.00127332) | 0.136741 ± 0.000379009 (W 0.0020243) | `lapack-openblas` 0.9651 (0.964 0.967) |
| `eigh/n64/b1` | 0.63946 ± 0.00280368 (W 0.0033274) | 0.572178 ± 0.000205768 (W 0.00168955) | `lapack-openblas` 0.8948 (0.897 0.892) |
| `eigh/n96/b1` | 1.54766 ± 0.00700601 (W 0.0159358) | 1.61437 ± 0.0034627 (W 0.00237325) | `lapack-openblas` 1.043 (1.045 1.041) |
| `full_piv_lu/n32/b1` | 0.015946 ± 7.07107e-06 (W 9.88456e-05) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.092326 ± 0.000521845 (W 0.00143793) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.270087 ± 0.000999142 (W 0.00164571) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028474 ± 4.24264e-05 (W 9.14357e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028399 ± 6.36396e-05 (W 6.096e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.07058 ± 0.00331067 (W 0.0120856) | - | * ! `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0689465 ± 0.000164756 (W 0.00663657) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.153934 ± 0.000265872 (W 0.00138883) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.15669 ± 0.000952473 (W 0.00179968) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.011507 ± 7.07107e-06 (W 4.19839e-05) | 0.013947 ± 4.24264e-05 (W 0.000103166) | `lapack-openblas` 1.212 (1.209 1.215) |
| `lu/n64/b1` | 0.05482 ± 0.000319612 (W 0.000889703) | 0.0674285 ± 0.000593263 (W 0.000241734) | `lapack-openblas` 1.23 (1.217 1.243) |
| `lu/n96/b1` | 0.157335 ± 0.000130108 (W 0.00179124) | 0.181707 ± 0.00117168 (W 0.00257621) | `lapack-openblas` 1.155 (1.150 1.159) |
| `qr/n32/b1` | 0.153503 ± 0.00353836 (W 0.0147758) | 0.054299 ± 0.00053033 (W 0.000217589) | `lapack-openblas` 0.3538 (0.357 0.350) |
| `qr/n64/b1` | 0.649601 ± 0.00953392 (W 0.0137984) | 0.263954 ± 0.000388909 (W 0.00177485) | `lapack-openblas` 0.4064 (0.411 0.402) |
| `qr/n96/b1` | 1.29015 ± 0.00318552 (W 0.0153058) | 0.930021 ± 0.00687096 (W 0.00171755) | `lapack-openblas` 0.7209 (0.718 0.723) |
| `qr_factor/n32/b1` | 0.106112 ± 0.000286378 (W 0.0038571) | 0.0302125 ± 0.00039103 (W 0.000690327) | `lapack-openblas` 0.2847 (0.287 0.283) |
| `qr_factor/n64/b1` | 0.571111 ± 0.0111228 (W 0.00569487) | 0.137894 ± 0.000639932 (W 0.00111976) | `lapack-openblas` 0.2415 (0.246 0.237) |
| `qr_factor/n96/b1` | 1.09127 ± 0.000951766 (W 0.0118882) | 0.471375 ± 0.00366564 (W 0.00239819) | `lapack-openblas` 0.4319 (0.430 0.434) |
| `solve/n32/b1` | 0.012864 ± 7.07107e-05 (W 4.68793e-05) | 0.0153445 ± 0.0001492 (W 7.83598e-05) | `lapack-openblas` 1.193 (1.206 1.180) |
| `solve/n64/b1` | 0.056648 ± 1.55563e-05 (W 0.000123843) | 0.072208 ± 5.79828e-05 (W 0.000587213) | `lapack-openblas` 1.275 (1.275 1.274) |
| `solve/n96/b1` | 0.160862 ± 0.00164614 (W 0.0022299) | 0.190869 ± 0.000965908 (W 0.00144521) | `lapack-openblas` 1.187 (1.191 1.182) |
| `svd_thin/n32/b1` | 0.23535 ± 0.000688015 (W 0.00157933) | 0.227675 ± 0.00246002 (W 0.00128096) | `lapack-openblas` 0.9674 (0.962 0.973) |
| `svd_thin/n64/b1` | 1.20002 ± 0.00134633 (W 0.00330172) | 0.959527 ± 0.00484792 (W 0.00117167) | `lapack-openblas` 0.7996 (0.802 0.797) |
| `svd_thin/n96/b1` | 2.99717 ± 0.00409486 (W 0.0200658) | 2.58302 ± 0.136665 (W 0.00520986) | ! `lapack-openblas` 0.8612 (0.829 0.895) |
| `svd_values/n32/b1` | 0.161012 ± 0.00103803 (W 0.00171857) | 0.103663 ± 0.000444063 (W 0.000600013) | `lapack-openblas` 0.6438 (0.645 0.643) |
| `svd_values/n64/b1` | 0.651293 ± 0.000934088 (W 0.00114515) | 0.414722 ± 0.000840043 (W 0.00213279) | `lapack-openblas` 0.6368 (0.637 0.637) |
| `svd_values/n96/b1` | 1.5067 ± 0.00301793 (W 0.0020039) | 1.28693 ± 0.00164119 (W 0.00667416) | `lapack-openblas` 0.8541 (0.855 0.854) |
| `triangular_solve/n32/b1` | 0.001102 ± 0 (W 4.75884e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.002725 ± 2.82843e-05 (W 2.14016e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.0049695 ± 5.72756e-05 (W 3.05433e-05) | - | * `lapack-openblas` - |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.0051445 ± 2.05061e-05 (W 2.63677e-05) | 0.0067025 ± 7.00036e-05 (W 7.46474e-05) | `lapack-openblas` 1.303 (1.309 1.297) |
| `cholesky/n64/b1` | 0.0300975 ± 0.000211425 (W 0.000944836) | 0.043077 ± 0.00210435 (W 0.00106176) | ! `lapack-openblas` 1.43 (1.389 1.473) |
| `cholesky/n96/b1` | 0.112595 ± 0.00123037 (W 0.00377996) | 0.103132 ± 0.00202091 (W 0.00170897) | `lapack-openblas` 0.9159 (0.936 0.896) |
| `eigh/n32/b1` | 0.142015 ± 0.000358503 (W 0.000267384) | 0.135413 ± 0.0005572 (W 0.000879938) | `lapack-openblas` 0.9535 (0.952 0.955) |
| `eigh/n64/b1` | 0.64827 ± 0.000774989 (W 0.00443895) | 0.560037 ± 0.000208597 (W 0.00209241) | `lapack-openblas` 0.8639 (0.865 0.863) |
| `eigh/n96/b1` | 1.59868 ± 0.00565261 (W 0.00766611) | 1.65163 ± 0.00425113 (W 0.00201848) | `lapack-openblas` 1.033 (1.038 1.029) |
| `full_piv_lu/n32/b1` | 0.0158605 ± 1.48492e-05 (W 8.69711e-05) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.092346 ± 0.000554372 (W 0.000958177) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.269629 ± 0.00155988 (W 0.00196126) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028364 ± 2.82843e-05 (W 7.84692e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0285245 ± 0.000142128 (W 9.81513e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.070434 ± 0.000241831 (W 0.00263715) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0725775 ± 0.000352846 (W 0.0022621) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.161748 ± 0.000753776 (W 0.00144949) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.163296 ± 0.00330643 (W 0.00229153) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.011552 ± 9.89949e-05 (W 7.66465e-05) | 0.0139715 ± 9.2631e-05 (W 6.83095e-05) | `lapack-openblas` 1.209 (1.223 1.197) |
| `lu/n64/b1` | 0.054905 ± 8.6267e-05 (W 0.000926522) | 0.067544 ± 0.000830143 (W 0.00133331) | `lapack-openblas` 1.23 (1.240 1.221) |
| `lu/n96/b1` | 0.169764 ± 0.000548715 (W 0.00226228) | 0.183374 ± 0.0011936 (W 0.00188095) | `lapack-openblas` 1.08 (1.078 1.083) |
| `qr/n32/b1` | 0.193223 ± 0.0080596 (W 0.00700174) | 0.0542035 ± 4.31335e-05 (W 0.00083204) | ! `lapack-openblas` 0.2806 (0.273 0.289) |
| `qr/n64/b1` | 0.86338 ± 0.0235155 (W 0.0202584) | 0.261408 ± 3.39411e-05 (W 0.00167594) | `lapack-openblas` 0.3028 (0.297 0.309) |
| `qr/n96/b1` | 1.70659 ± 0.0648056 (W 0.0347025) | 0.993603 ± 0.00146937 (W 0.00375467) | ! `lapack-openblas` 0.5824 (0.566 0.599) |
| `qr_factor/n32/b1` | 0.131806 ± 0.005502 (W 0.00673706) | 0.0302625 ± 0.000163342 (W 0.00161424) | ! `lapack-openblas` 0.2297 (0.237 0.222) |
| `qr_factor/n64/b1` | 0.714557 ± 0.000219203 (W 0.0192351) | 0.13601 ± 0.000583363 (W 0.00145851) | `lapack-openblas` 0.1903 (0.191 0.190) |
| `qr_factor/n96/b1` | 1.40791 ± 0.0162331 (W 0.0150929) | 0.50334 ± 0.00310773 (W 0.00209266) | `lapack-openblas` 0.3575 (0.359 0.356) |
| `solve/n32/b1` | 0.012974 ± 5.65685e-05 (W 6.53968e-05) | 0.0155595 ± 2.75772e-05 (W 7.48969e-05) | `lapack-openblas` 1.199 (1.201 1.197) |
| `solve/n64/b1` | 0.056803 ± 5.65685e-06 (W 0.000142513) | 0.071707 ± 0.000907925 (W 0.000288952) | `lapack-openblas` 1.262 (1.274 1.251) |
| `solve/n96/b1` | 0.172994 ± 0.000350018 (W 0.00377436) | 0.189951 ± 0.00279519 (W 0.00117429) | `lapack-openblas` 1.098 (1.108 1.088) |
| `svd_thin/n32/b1` | 0.235759 ± 0.00091641 (W 0.00134373) | 0.227899 ± 0.000541644 (W 0.00151331) | `lapack-openblas` 0.9667 (0.968 0.966) |
| `svd_thin/n64/b1` | 1.22214 ± 0.00227476 (W 0.00663296) | 0.957364 ± 0.00104581 (W 0.00121364) | `lapack-openblas` 0.7834 (0.782 0.785) |
| `svd_thin/n96/b1` | 3.08684 ± 0.000430628 (W 0.0159992) | 2.62263 ± 0.10569 (W 0.00624602) | ! `lapack-openblas` 0.8493 (0.825 0.874) |
| `svd_values/n32/b1` | 0.162265 ± 0.00194525 (W 0.00159984) | 0.103246 ± 3.04056e-05 (W 0.00156974) | `lapack-openblas` 0.6363 (0.642 0.631) |
| `svd_values/n64/b1` | 0.650886 ± 0.000473054 (W 0.00157786) | 0.410067 ± 0.000680944 (W 0.00172053) | `lapack-openblas` 0.63 (0.630 0.630) |
| `svd_values/n96/b1` | 1.50961 ± 0.000608112 (W 0.00179489) | 1.37046 ± 0.0101781 (W 0.00311664) | `lapack-openblas` 0.9078 (0.912 0.903) |
| `triangular_solve/n32/b1` | 0.0010925 ± 1.3435e-05 (W 2.18613e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.002775 ± 8.48528e-05 (W 3.55395e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.00497 ± 7.07107e-05 (W 2.9465e-05) | - | * `lapack-openblas` - |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.00518 ± 2.82843e-05 (W 3.89742e-05) | 0.005926 ± 0.00013435 (W 4.31165e-05) | `lapack-openblas` 1.144 (1.130 1.158) |
| `cholesky/n64/b1` | 0.029867 ± 0.000182434 (W 9.16486e-05) | 0.0320465 ± 0.000374059 (W 0.000780199) | `lapack-openblas` 1.073 (1.069 1.077) |
| `cholesky/n96/b1` | 0.0827135 ± 9.54594e-05 (W 7.51551e-05) | 0.0868715 ± 0.000222739 (W 0.00075197) | `lapack-openblas` 1.05 (1.051 1.049) |
| `eigh/n32/b1` | 0.142518 ± 0.000554372 (W 0.000556003) | 0.150162 ± 0.00050841 (W 0.000897611) | `lapack-openblas` 1.054 (1.059 1.048) |
| `eigh/n64/b1` | 0.651016 ± 0.000277893 (W 0.00215369) | 0.647835 ± 0.000183848 (W 0.00163432) | `lapack-openblas` 0.9951 (0.996 0.995) |
| `eigh/n96/b1` | 1.62174 ± 0.00291187 (W 0.00126958) | 1.61755 ± 3.60624e-05 (W 0.00221187) | `lapack-openblas` 0.9974 (0.999 0.996) |
| `full_piv_lu/n32/b1` | 0.0158095 ± 2.89914e-05 (W 6.86148e-05) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.0906685 ± 1.76777e-05 (W 0.00132431) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.2662 ± 0.00019304 (W 0.00157298) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.027999 ± 0.000104652 (W 3.91343e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0281235 ± 0.000126572 (W 5.33172e-05) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.157812 ± 0.000292742 (W 0.00179258) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.157672 ± 0.000259508 (W 0.000716978) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.460361 ± 0.00222385 (W 0.00112042) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.46256 ± 0.00213263 (W 0.000278497) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.011788 ± 2.12132e-05 (W 4.76377e-05) | 0.0129245 ± 0.000241123 (W 8.66766e-05) | `lapack-openblas` 1.096 (1.083 1.109) |
| `lu/n64/b1` | 0.0528165 ± 0.000204354 (W 9.45494e-05) | 0.060381 ± 0.000222032 (W 9.77611e-05) | `lapack-openblas` 1.143 (1.149 1.137) |
| `lu/n96/b1` | 0.141251 ± 0.00027365 (W 0.000934255) | 0.164611 ± 0.000295571 (W 0.00165218) | `lapack-openblas` 1.165 (1.165 1.166) |
| `qr/n32/b1` | 0.068406 ± 9.47523e-05 (W 0.00101341) | 0.0519195 ± 0.000383959 (W 0.000229708) | `lapack-openblas` 0.759 (0.762 0.756) |
| `qr/n64/b1` | 0.310225 ± 0.000301935 (W 0.00176999) | 0.249017 ± 0.00115541 (W 0.00175673) | `lapack-openblas` 0.8027 (0.806 0.800) |
| `qr/n96/b1` | 0.759389 ± 0.000719835 (W 0.00216431) | 0.698147 ± 0.0011837 (W 0.00245734) | `lapack-openblas` 0.9194 (0.921 0.918) |
| `qr_factor/n32/b1` | 0.033469 ± 0.000164049 (W 0.000205661) | 0.0288605 ± 2.05061e-05 (W 6.18447e-05) | `lapack-openblas` 0.8623 (0.859 0.866) |
| `qr_factor/n64/b1` | 0.159951 ± 0.000195869 (W 0.00123135) | 0.131055 ± 0.00203717 (W 0.000706505) | `lapack-openblas` 0.8193 (0.828 0.811) |
| `qr_factor/n96/b1` | 0.388714 ± 0.000196576 (W 0.00203438) | 0.357475 ± 0.00345422 (W 0.00172021) | `lapack-openblas` 0.9196 (0.926 0.914) |
| `solve/n32/b1` | 0.01287 ± 0.000120208 (W 5.25616e-05) | 0.014097 ± 2.68701e-05 (W 7.68998e-05) | `lapack-openblas` 1.095 (1.101 1.090) |
| `solve/n64/b1` | 0.055201 ± 0.00067458 (W 0.00069088) | 0.064824 ± 0.000582656 (W 0.000813527) | `lapack-openblas` 1.174 (1.172 1.177) |
| `solve/n96/b1` | 0.144902 ± 0.00042285 (W 0.000747993) | 0.173222 ± 0.000883883 (W 0.00148542) | `lapack-openblas` 1.195 (1.197 1.194) |
| `svd_thin/n32/b1` | 0.233086 ± 4.94975e-05 (W 0.00116837) | 0.226389 ± 0.000325976 (W 0.00164338) | `lapack-openblas` 0.9713 (0.970 0.972) |
| `svd_thin/n64/b1` | 1.25652 ± 0.00194525 (W 0.00312169) | 0.943491 ± 0.0013237 (W 0.00440852) | `lapack-openblas` 0.7509 (0.749 0.752) |
| `svd_thin/n96/b1` | 3.09147 ± 0.00168928 (W 0.00383935) | 2.51757 ± 0.0106766 (W 0.00392719) | `lapack-openblas` 0.8144 (0.816 0.812) |
| `svd_values/n32/b1` | 0.159125 ± 0.0002885 (W 0.00131704) | 0.103197 ± 0.000484368 (W 0.000927595) | `lapack-openblas` 0.6485 (0.650 0.647) |
| `svd_values/n64/b1` | 0.628018 ± 0.00302005 (W 0.00174708) | 0.402391 ± 1.27279e-05 (W 0.00167825) | `lapack-openblas` 0.6407 (0.643 0.639) |
| `svd_values/n96/b1` | 1.48666 ± 0.00115046 (W 0.0015706) | 1.0103 ± 0.0119621 (W 0.001375) | `lapack-openblas` 0.6796 (0.686 0.674) |
| `triangular_solve/n32/b1` | 0.001193 ± 0 (W 1.0249e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.0028355 ± 2.89914e-05 (W 2.01061e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.0054055 ± 0.000361332 (W 1.76174e-05) | - | * ! `lapack-openblas` - |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.0051 ± 2.82843e-05 (W 5.50086e-05) | 0.0058865 ± 7.84889e-05 (W 0.000897239) | `lapack-openblas` 1.154 (1.161 1.148) |
| `cholesky/n64/b1` | 0.0296965 ± 2.89914e-05 (W 0.000708224) | 0.032893 ± 0.00102106 (W 0.000950842) | `lapack-openblas` 1.107 (1.131 1.084) |
| `cholesky/n96/b1` | 0.101944 ± 0.000294864 (W 0.00136445) | 0.0880435 ± 0.000501339 (W 0.000833725) | `lapack-openblas` 0.8636 (0.862 0.865) |
| `eigh/n32/b1` | 0.142437 ± 0.000520431 (W 0.00175268) | 0.135684 ± 0.000159806 (W 0.00111843) | `lapack-openblas` 0.9526 (0.949 0.956) |
| `eigh/n64/b1` | 0.648052 ± 0.00724714 (W 0.00582345) | 0.564423 ± 0.00279944 (W 0.00188429) | `lapack-openblas` 0.871 (0.875 0.867) |
| `eigh/n96/b1` | 1.54892 ± 0.00800586 (W 0.0245346) | 1.60466 ± 0.00219486 (W 0.00225826) | `lapack-openblas` 1.036 (1.031 1.041) |
| `full_piv_lu/n32/b1` | 0.0158405 ± 8.41457e-05 (W 0.000118671) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.09179 ± 0.00103945 (W 0.00155634) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.267015 ± 0.00017112 (W 0.00219477) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0281835 ± 0.000113844 (W 7.86251e-05) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0282135 ± 0.00011243 (W 0.000755632) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0651595 ± 0.000461741 (W 0.00711075) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0652295 ± 0.00081388 (W 0.00197824) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.152416 ± 0.000329512 (W 0.00234071) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.153218 ± 0.000243952 (W 0.00311439) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.011677 ± 4.94975e-05 (W 0.000631522) | 0.012835 ± 0.000155563 (W 8.18209e-05) | `lapack-openblas` 1.099 (1.093 1.105) |
| `lu/n64/b1` | 0.0530815 ± 0.00031042 (W 0.000825045) | 0.0601295 ± 0.000232638 (W 0.000747292) | `lapack-openblas` 1.133 (1.134 1.131) |
| `lu/n96/b1` | 0.155121 ± 0.000258094 (W 0.00300317) | 0.163964 ± 0.000344361 (W 0.00103043) | `lapack-openblas` 1.057 (1.060 1.054) |
| `qr/n32/b1` | 0.152276 ± 0.0146682 (W 0.0103256) | 0.0518695 ± 0.000352846 (W 0.0007925) | ! p `lapack-openblas` 0.3414 (0.364 0.320) |
| `qr/n64/b1` | 0.631766 ± 0.0169168 (W 0.00961788) | 0.251956 ± 0.000680944 (W 0.00227458) | `lapack-openblas` 0.3989 (0.406 0.392) |
| `qr/n96/b1` | 1.28733 ± 0.00572898 (W 0.0107863) | 0.89546 ± 0.00636891 (W 0.00260354) | `lapack-openblas` 0.6956 (0.694 0.697) |
| `qr_factor/n32/b1` | 0.0930675 ± 0.000993485 (W 0.00348558) | 0.029146 ± 8.48528e-05 (W 0.000104208) | `lapack-openblas` 0.3132 (0.310 0.316) |
| `qr_factor/n64/b1` | 0.503943 ± 0.000890955 (W 0.00919165) | 0.131441 ± 0.00132936 (W 0.00190139) | `lapack-openblas` 0.2608 (0.259 0.263) |
| `qr_factor/n96/b1` | 0.988664 ± 0.00781848 (W 0.00982774) | 0.452589 ± 0.0032838 (W 0.00237693) | `lapack-openblas` 0.4578 (0.458 0.458) |
| `solve/n32/b1` | 0.0128645 ± 9.82878e-05 (W 8.31214e-05) | 0.014097 ± 0.000141421 (W 0.000829921) | `lapack-openblas` 1.096 (1.110 1.082) |
| `solve/n64/b1` | 0.05489 ± 8.48528e-06 (W 0.000130572) | 0.064428 ± 0.000420021 (W 0.000738614) | `lapack-openblas` 1.174 (1.179 1.168) |
| `solve/n96/b1` | 0.158293 ± 0.000811759 (W 0.000884329) | 0.172199 ± 0.000968736 (W 0.00175417) | `lapack-openblas` 1.088 (1.088 1.087) |
| `svd_thin/n32/b1` | 0.232459 ± 0.000426385 (W 0.00156728) | 0.225957 ± 0.000284964 (W 0.00163111) | `lapack-openblas` 0.972 (0.972 0.972) |
| `svd_thin/n64/b1` | 1.22819 ± 0.00135199 (W 0.00517441) | 0.934153 ± 0.000515481 (W 0.00146922) | `lapack-openblas` 0.7606 (0.761 0.760) |
| `svd_thin/n96/b1` | 2.94643 ± 0.00574383 (W 0.0210727) | 2.44648 ± 0.00394778 (W 0.00601849) | `lapack-openblas` 0.8303 (0.830 0.831) |
| `svd_values/n32/b1` | 0.158793 ± 0.00025173 (W 0.00145934) | 0.103734 ± 0.000245366 (W 0.000481444) | `lapack-openblas` 0.6533 (0.653 0.654) |
| `svd_values/n64/b1` | 0.625539 ± 0.00231577 (W 0.0018545) | 0.402088 ± 0.0025272 (W 0.00193405) | `lapack-openblas` 0.6428 (0.642 0.644) |
| `svd_values/n96/b1` | 1.48235 ± 0.00532098 (W 0.00330301) | 1.27258 ± 0.0107318 (W 0.00317749) | `lapack-openblas` 0.8585 (0.856 0.861) |
| `triangular_solve/n32/b1` | 0.0012175 ± 2.05061e-05 (W 2.26715e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.0028305 ± 2.19203e-05 (W 1.40056e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.00516 ± 0.000524673 (W 3.11527e-05) | - | * ! `lapack-openblas` - |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n32/b1` | 0.0051295 ± 7.07107e-07 (W 3.74487e-05) | 0.005891 ± 4.24264e-05 (W 8.26648e-05) | `lapack-openblas` 1.148 (1.154 1.143) |
| `cholesky/n64/b1` | 0.0296965 ± 1.3435e-05 (W 0.000108104) | 0.037046 ± 0.000234759 (W 0.000672572) | `lapack-openblas` 1.247 (1.253 1.242) |
| `cholesky/n96/b1` | 0.111016 ± 0.000175362 (W 0.00321519) | 0.0939195 ± 0.000668216 (W 0.00138999) | `lapack-openblas` 0.846 (0.851 0.841) |
| `eigh/n32/b1` | 0.141845 ± 0.000585484 (W 0.0011581) | 0.133995 ± 0.000365574 (W 0.000724437) | `lapack-openblas` 0.9447 (0.946 0.944) |
| `eigh/n64/b1` | 0.648154 ± 0.0029352 (W 0.00709118) | 0.550724 ± 0.00251871 (W 0.00147919) | `lapack-openblas` 0.8497 (0.850 0.850) |
| `eigh/n96/b1` | 1.60318 ± 0.00631871 (W 0.0154088) | 1.63606 ± 0.002955 (W 0.00288274) | `lapack-openblas` 1.021 (1.019 1.022) |
| `full_piv_lu/n32/b1` | 0.015875 ± 3.53553e-05 (W 7.79141e-05) | - | * `lapack-openblas` - |
| `full_piv_lu/n64/b1` | 0.091379 ± 0.000377595 (W 0.00145284) | - | * `lapack-openblas` - |
| `full_piv_lu/n96/b1` | 0.266889 ± 0.000136472 (W 0.00184984) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0282035 ± 2.75772e-05 (W 0.000850399) | - | * `lapack-openblas` - |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0282495 ± 0.000135057 (W 0.00015937) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.070349 ± 0.000118794 (W 0.00167479) | - | * `lapack-openblas` - |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.071196 ± 0.000608112 (W 0.00170939) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.159498 ± 0.00047164 (W 0.00101172) | - | * `lapack-openblas` - |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.160531 ± 0.000585484 (W 0.176676) | - | * `lapack-openblas` - |
| `lu/n32/b1` | 0.011787 ± 7.07107e-06 (W 7.76469e-05) | 0.0129295 ± 7.84889e-05 (W 9.93872e-05) | `lapack-openblas` 1.097 (1.101 1.093) |
| `lu/n64/b1` | 0.0531865 ± 0.000359917 (W 0.00012084) | 0.060285 ± 0.000226274 (W 0.000107944) | `lapack-openblas` 1.133 (1.136 1.131) |
| `lu/n96/b1` | 0.165475 ± 0.00378019 (W 0.00278196) | 0.164739 ± 0.000420729 (W 0.00189623) | `lapack-openblas` 0.9957 (1.014 0.978) |
| `qr/n32/b1` | 0.1839 ± 0.00270963 (W 0.00641481) | 0.0515135 ± 5.02046e-05 (W 0.000298038) | `lapack-openblas` 0.2801 (0.277 0.283) |
| `qr/n64/b1` | 0.874191 ± 0.00168079 (W 0.0216756) | 0.247316 ± 0.000380423 (W 0.00164541) | `lapack-openblas` 0.2829 (0.283 0.283) |
| `qr/n96/b1` | 1.73227 ± 0.0942496 (W 0.0239581) | 0.953101 ± 0.000760847 (W 0.00176152) | ! `lapack-openblas` 0.5506 (0.530 0.572) |
| `qr_factor/n32/b1` | 0.124532 ± 0.00150614 (W 0.0114866) | 0.0291705 ± 0.000178898 (W 5.20286e-05) | `lapack-openblas` 0.2342 (0.237 0.231) |
| `qr_factor/n64/b1` | 0.662527 ± 0.00637174 (W 0.0172458) | 0.130354 ± 0.00016617 (W 0.00100416) | `lapack-openblas` 0.1968 (0.198 0.195) |
| `qr_factor/n96/b1` | 1.3086 ± 0.0270949 (W 0.0121416) | 0.487749 ± 0.00428365 (W 0.00120127) | `lapack-openblas` 0.3728 (0.376 0.370) |
| `solve/n32/b1` | 0.012985 ± 0.000226274 (W 5.41381e-05) | 0.0141515 ± 6.43467e-05 (W 6.6843e-05) | `lapack-openblas` 1.09 (1.107 1.073) |
| `solve/n64/b1` | 0.0553355 ± 5.58614e-05 (W 0.000696699) | 0.064227 ± 3.67696e-05 (W 0.000666427) | `lapack-openblas` 1.161 (1.162 1.159) |
| `solve/n96/b1` | 0.172013 ± 0.00153442 (W 0.00168129) | 0.172609 ± 0.0010451 (W 0.00140307) | `lapack-openblas` 1.003 (1.006 1.001) |
| `svd_thin/n32/b1` | 0.233089 ± 0.000725492 (W 0.00140728) | 0.225364 ± 0.00016617 (W 0.00216407) | `lapack-openblas` 0.9669 (0.969 0.964) |
| `svd_thin/n64/b1` | 1.27298 ± 0.000284964 (W 0.00882684) | 0.938683 ± 0.000306884 (W 0.000918311) | `lapack-openblas` 0.7374 (0.737 0.737) |
| `svd_thin/n96/b1` | 3.03662 ± 0.00504874 (W 0.0248665) | 2.52066 ± 0.000890955 (W 0.00540984) | `lapack-openblas` 0.8301 (0.829 0.831) |
| `svd_values/n32/b1` | 0.159845 ± 0.000946109 (W 0.0010172) | 0.103431 ± 0.000419314 (W 0.000178966) | `lapack-openblas` 0.6471 (0.652 0.643) |
| `svd_values/n64/b1` | 0.626404 ± 0.000960958 (W 0.00235229) | 0.404054 ± 0.000495682 (W 0.00167962) | `lapack-openblas` 0.645 (0.644 0.646) |
| `svd_values/n96/b1` | 1.4826 ± 0.00258448 (W 0.00316344) | 1.35192 ± 0.00428295 (W 0.00362982) | `lapack-openblas` 0.9119 (0.913 0.911) |
| `triangular_solve/n32/b1` | 0.001197 ± 7.07107e-06 (W 1.93796e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n64/b1` | 0.0028205 ± 2.19203e-05 (W 1.90052e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n96/b1` | 0.00523 ± 0.000694379 (W 2.38775e-05) | - | * ! `lapack-openblas` - |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.066617 ± 0.000326683 (W 0.00102835) | 0.155952 ± 0.000944695 (W 0.00196337) | `lapack-openblas` 2.341 (2.343 2.339) |
| `cholesky/n256/b1` | 0.388926 ± 0.0013329 (W 0.00284686) | 0.99561 ± 0.00160584 (W 0.00608571) | `lapack-openblas` 2.56 (2.563 2.557) |
| `cholesky/n512/b1` | 2.51433 ± 0.0143408 (W 0.00790175) | 5.92223 ± 0.0201723 (W 0.0124854) | `lapack-openblas` 2.355 (2.359 2.352) |
| `eigh/n128/b1` | 2.25925 ± 0.00740129 (W 0.00564706) | 1.87767 ± 0.00474398 (W 0.010947) | `lapack-openblas` 0.8311 (0.835 0.828) |
| `eigh/n256/b1` | 9.82584 ± 0.0396319 (W 0.0102597) | 9.14045 ± 0.0139243 (W 0.0157727) | `lapack-openblas` 0.9302 (0.932 0.929) |
| `eigh/n512/b1` | 49.2429 ± 0.245925 (W 0.0528809) | 52.2222 ± 0.147613 (W 0.251458) | `lapack-openblas` 1.061 (1.066 1.055) |
| `full_piv_lu/n128/b1` | 0.311788 ± 0.000408708 (W 0.00132736) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 2.74632 ± 0.00840679 (W 0.0139227) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 22.4174 ± 0.262736 (W 0.0293727) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259153 ± 0.000641346 (W 0.00178661) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.258912 ± 0.000768625 (W 0.00160079) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.94443 ± 0.0142362 (W 0.00704565) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.92613 ± 0.0156815 (W 0.00598215) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.8671 ± 0.0110535 (W 0.0222949) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.8816 ± 0.00412455 (W 0.0377061) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.167579 ± 0.00335451 (W 0.00206593) | 0.211047 ± 0.00025173 (W 0.00110645) | `lapack-openblas` 1.26 (1.279 1.241) |
| `lu/n256/b1` | 1.04255 ± 0.003363 (W 0.00471114) | 1.37175 ± 0.00243952 (W 0.00693671) | `lapack-openblas` 1.316 (1.320 1.311) |
| `lu/n512/b1` | 7.2129 ± 0.0817762 (W 0.0289822) | 8.25871 ± 0.0876325 (W 0.0133869) | `lapack-openblas` 1.145 (1.163 1.127) |
| `qr/n128/b1` | 0.514389 ± 0.000998435 (W 0.00579598) | 0.86178 ± 0.0052439 (W 0.00700514) | `lapack-openblas` 1.675 (1.670 1.680) |
| `qr/n256/b1` | 2.91872 ± 0.00689146 (W 0.00340577) | 4.35786 ± 0.0176706 (W 0.00525934) | `lapack-openblas` 1.493 (1.500 1.486) |
| `qr/n512/b1` | 20.8087 ± 0.169794 (W 0.088141) | 30.7329 ± 0.0846032 (W 0.0322713) | `lapack-openblas` 1.477 (1.488 1.466) |
| `qr_factor/n128/b1` | 0.423982 ± 0.000496389 (W 0.00263121) | 0.431702 ± 0.0031247 (W 0.00642251) | `lapack-openblas` 1.018 (1.014 1.023) |
| `qr_factor/n256/b1` | 2.4474 ± 0.000917117 (W 0.00564753) | 2.17409 ± 0.0257585 (W 0.00890883) | `lapack-openblas` 0.8883 (0.896 0.881) |
| `qr_factor/n512/b1` | 15.8572 ± 0.0533752 (W 0.0218653) | 14.4012 ± 0.00271034 (W 0.0234363) | `lapack-openblas` 0.9082 (0.910 0.906) |
| `solve/n128/b1` | 0.136975 ± 0.00119996 (W 0.00244101) | 0.209879 ± 0.00139936 (W 0.00696446) | `lapack-openblas` 1.532 (1.516 1.549) |
| `solve/n256/b1` | 0.812622 ± 0.000330926 (W 0.00253875) | 1.13476 ± 0.00420516 (W 0.00351131) | `lapack-openblas` 1.396 (1.400 1.393) |
| `solve/n512/b1` | 7.07776 ± 0.0328713 (W 0.00574875) | 7.10235 ± 0.0197863 (W 0.0162468) | `lapack-openblas` 1.003 (1.002 1.005) |
| `svd_thin/n128/b1` | 3.68833 ± 0.00864721 (W 0.00405368) | 3.14532 ± 0.00599697 (W 0.00988077) | `lapack-openblas` 0.8528 (0.853 0.853) |
| `svd_thin/n256/b1` | 18.4726 ± 0.00508339 (W 0.0190914) | 17.6252 ± 0.0164664 (W 0.0289044) | `lapack-openblas` 0.9541 (0.954 0.955) |
| `svd_thin/n512/b1` | 105.62 ± 0.0982893 (W 0.0711604) | 120.803 ± 2.09039 (W 0.263343) | `lapack-openblas` 1.144 (1.130 1.157) |
| `svd_values/n128/b1` | 2.6985 ± 0.00162635 (W 0.00291001) | 1.35054 ± 0.00305117 (W 0.00511945) | `lapack-openblas` 0.5005 (0.501 0.500) |
| `svd_values/n256/b1` | 12.4982 ± 0.081622 (W 0.215529) | 7.90122 ± 0.00467751 (W 0.00461256) | `lapack-openblas` 0.6322 (0.635 0.629) |
| `svd_values/n512/b1` | 66.6956 ± 0.58901 (W 0.0361494) | 54.8118 ± 0.0800883 (W 0.213046) | `lapack-openblas` 0.8218 (0.828 0.816) |
| `triangular_solve/n128/b1` | 0.004163 ± 0.000162635 (W 7.23919e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.011702 ± 0.000934795 (W 3.25292e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.039465 ± 0.00425113 (W 0.000191347) | - | * ! `lapack-openblas` - |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.103492 ± 0.0042589 (W 0.00411795) | 0.168986 ± 0.00177908 (W 0.00243804) | ! `lapack-openblas` 1.633 (1.598 1.669) |
| `cholesky/n256/b1` | 0.393312 ± 0.0126494 (W 0.0228824) | 0.882425 ± 0.00244518 (W 0.00608217) | `lapack-openblas` 2.244 (2.198 2.291) |
| `cholesky/n512/b1` | 1.65318 ± 0.0189017 (W 0.0253155) | 4.57366 ± 0.00345422 (W 0.0593829) | `lapack-openblas` 2.767 (2.788 2.746) |
| `eigh/n128/b1` | 2.31494 ± 0.00851144 (W 0.0512679) | 1.49653 ± 0.00549422 (W 0.00486339) | `lapack-openblas` 0.6465 (0.643 0.650) |
| `eigh/n256/b1` | 6.94069 ± 0.00464074 (W 0.0357676) | 6.11137 ± 0.0379511 (W 0.0150479) | `lapack-openblas` 0.8805 (0.877 0.884) |
| `eigh/n512/b1` | 26.3609 ± 0.154752 (W 0.0209703) | 28.8606 ± 0.103537 (W 0.0276635) | `lapack-openblas` 1.095 (1.102 1.088) |
| `full_piv_lu/n128/b1` | 0.315203 ± 0.00101541 (W 0.00375251) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 2.77836 ± 0.00784606 (W 0.00679446) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 18.2628 ± 0.0488611 (W 0.265607) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.083158 ± 1.41421e-05 (W 0.00184486) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.085617 ± 4.94975e-05 (W 0.00212064) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.52221 ± 0.00744937 (W 0.00436164) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.527706 ± 0.00358079 (W 0.00487648) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.07752 ± 0.00257882 (W 0.00457124) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.11027 ± 0.0157197 (W 0.00797919) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.235377 ± 0.00476307 (W 0.0100615) | 0.208035 ± 0.00646013 (W 0.00329222) | `lapack-openblas` 0.8837 (0.852 0.916) |
| `lu/n256/b1` | 1.19081 ± 0.00953321 (W 0.0261769) | 1.04479 ± 0.00508127 (W 0.00247784) | `lapack-openblas` 0.8774 (0.885 0.869) |
| `lu/n512/b1` | 5.5824 ± 0.0324194 (W 0.0418741) | 5.62767 ± 0.0212316 (W 0.0172056) | `lapack-openblas` 1.008 (1.015 1.001) |
| `qr/n128/b1` | 1.44 ± 0.0247431 (W 0.0282299) | 0.904386 ± 0.00264246 (W 0.00663882) | `lapack-openblas` 0.6281 (0.619 0.637) |
| `qr/n256/b1` | 3.78254 ± 0.011202 (W 0.0479268) | 3.58163 ± 0.0198082 (W 0.00664771) | `lapack-openblas` 0.9469 (0.949 0.945) |
| `qr/n512/b1` | 14.3345 ± 0.0977646 (W 0.0852042) | 19.3065 ± 0.00365716 (W 0.0376981) | `lapack-openblas` 1.347 (1.341 1.353) |
| `qr_factor/n128/b1` | 1.36931 ± 0.00523259 (W 0.0259579) | 0.448927 ± 0.004587 (W 0.00498229) | `lapack-openblas` 0.3278 (0.329 0.326) |
| `qr_factor/n256/b1` | 4.84317 ± 0.0309055 (W 0.0342588) | 1.78643 ± 0.000531037 (W 0.00388432) | `lapack-openblas` 0.3689 (0.371 0.367) |
| `qr_factor/n512/b1` | 20.16 ± 0.0456883 (W 0.528766) | 9.42088 ± 0.000366281 (W 0.0132965) | `lapack-openblas` 0.4673 (0.467 0.468) |
| `solve/n128/b1` | 0.210073 ± 0.00409981 (W 0.00598792) | 0.170144 ± 0.0025774 (W 0.00359065) | `lapack-openblas` 0.81 (0.812 0.807) |
| `solve/n256/b1` | 0.908003 ± 0.00670974 (W 0.036006) | 0.795946 ± 0.00542775 (W 0.0040075) | `lapack-openblas` 0.8766 (0.868 0.885) |
| `solve/n512/b1` | 5.36589 ± 0.0584671 (W 0.0276681) | 4.554 ± 0.117898 (W 0.00706504) | `lapack-openblas` 0.8486 (0.840 0.858) |
| `svd_thin/n128/b1` | 3.0347 ± 0.00253427 (W 0.0228466) | 3.09797 ± 0.0071043 (W 0.00829327) | `lapack-openblas` 1.021 (1.020 1.022) |
| `svd_thin/n256/b1` | 13.7056 ± 0.00137108 (W 0.0781144) | 14.9973 ± 0.116914 (W 0.0122582) | `lapack-openblas` 1.094 (1.100 1.088) |
| `svd_thin/n512/b1` | 61.4764 ± 0.0346984 (W 0.211693) | 94.3888 ± 2.70752 (W 0.268956) | `lapack-openblas` 1.535 (1.505 1.566) |
| `svd_values/n128/b1` | 2.22874 ± 0.00194384 (W 0.00455977) | 1.41187 ± 0.0169918 (W 0.00477829) | `lapack-openblas` 0.6335 (0.628 0.639) |
| `svd_values/n256/b1` | 10.8278 ± 0.0731785 (W 0.0145996) | 7.66703 ± 0.0180135 (W 0.00976571) | `lapack-openblas` 0.7081 (0.710 0.706) |
| `svd_values/n512/b1` | 48.0669 ± 0.00419031 (W 0.238) | 49.6683 ± 0.180196 (W 0.0361738) | `lapack-openblas` 1.033 (1.031 1.036) |
| `triangular_solve/n128/b1` | 0.003722 ± 3.53553e-05 (W 7.34542e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0109655 ± 0.000135057 (W 2.8703e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.038373 ± 0.000496389 (W 0.000793889) | - | * `lapack-openblas` - |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.101462 ± 1.3435e-05 (W 0.00366555) | 0.165995 ± 0.00406586 (W 0.00288204) | `lapack-openblas` 1.636 (1.608 1.664) |
| `cholesky/n256/b1` | 0.463543 ± 0.0239264 (W 0.0150553) | 0.850677 ± 0.00306389 (W 0.0094508) | ! `lapack-openblas` 1.836 (1.766 1.910) |
| `cholesky/n512/b1` | 1.65541 ± 0.0717098 (W 0.0743007) | 4.44618 ± 0.015813 (W 0.038883) | ! `lapack-openblas` 2.687 (2.599 2.778) |
| `eigh/n128/b1` | 2.33789 ± 0.013749 (W 0.0182149) | 1.43306 ± 0.00292035 (W 0.00470257) | `lapack-openblas` 0.613 (0.615 0.611) |
| `eigh/n256/b1` | 7.05555 ± 0.053376 (W 0.0296808) | 5.7446 ± 0.0404875 (W 0.00765128) | `lapack-openblas` 0.8142 (0.814 0.814) |
| `eigh/n512/b1` | 24.8191 ± 0.0546594 (W 0.503081) | 25.269 ± 0.0731587 (W 0.0273091) | `lapack-openblas` 1.018 (1.019 1.018) |
| `full_piv_lu/n128/b1` | 0.312818 ± 7.9196e-05 (W 0.00280761) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 2.77253 ± 0.0229336 (W 0.00649595) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 17.9032 ± 0.0748911 (W 0.127917) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.099403 ± 0.000190919 (W 0.00115181) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.101056 ± 0.000573464 (W 0.00183744) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.404015 ± 0.0089251 (W 0.0196926) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.401867 ± 0.0135234 (W 0.0185532) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.55743 ± 0.315647 (W 0.135021) | - | * ! `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.6079 ± 0.0495441 (W 0.229954) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.254453 ± 0.0053429 (W 0.00804652) | 0.21132 ± 0.000638517 (W 0.00298764) | `lapack-openblas` 0.8306 (0.820 0.841) |
| `lu/n256/b1` | 1.30272 ± 0.0384397 (W 0.0192275) | 0.978705 ± 0.00544614 (W 0.00478934) | `lapack-openblas` 0.7514 (0.739 0.764) |
| `lu/n512/b1` | 5.76443 ± 0.156809 (W 0.0562417) | 4.7416 ± 0.0462427 (W 0.0124057) | `lapack-openblas` 0.8227 (0.844 0.801) |
| `qr/n128/b1` | 1.91526 ± 0.0249241 (W 0.0273006) | 0.904078 ± 0.000626497 (W 0.00716599) | `lapack-openblas` 0.4721 (0.468 0.477) |
| `qr/n256/b1` | 4.81072 ± 0.0586736 (W 0.0195995) | 3.49419 ± 0.0168624 (W 0.00424421) | `lapack-openblas` 0.7264 (0.723 0.730) |
| `qr/n512/b1` | 15.7423 ± 0.00499005 (W 0.126376) | 17.7978 ± 0.294398 (W 0.0615487) | `lapack-openblas` 1.13 (1.118 1.144) |
| `qr_factor/n128/b1` | 1.8403 ± 0.0213037 (W 0.0273126) | 0.45123 ± 0.00290974 (W 0.00623933) | `lapack-openblas` 0.2452 (0.242 0.248) |
| `qr_factor/n256/b1` | 5.88118 ± 0.0460829 (W 0.0188015) | 1.74098 ± 0.00306743 (W 0.00339472) | `lapack-openblas` 0.296 (0.294 0.298) |
| `qr_factor/n512/b1` | 22.6424 ± 0.108367 (W 0.108982) | 8.74624 ± 0.104309 (W 0.0217971) | `lapack-openblas` 0.3863 (0.382 0.391) |
| `solve/n128/b1` | 0.210004 ± 0.00285459 (W 0.00494224) | 0.205439 ± 0.00575231 (W 0.00429621) | `lapack-openblas` 0.9781 (0.968 0.988) |
| `solve/n256/b1` | 0.984727 ± 0.0109906 (W 0.0241239) | 0.746264 ± 0.00516824 (W 0.00533245) | `lapack-openblas` 0.7579 (0.760 0.756) |
| `solve/n512/b1` | 5.67474 ± 0.000493561 (W 0.0996155) | 3.65474 ± 0.00357301 (W 0.00837411) | `lapack-openblas` 0.644 (0.644 0.644) |
| `svd_thin/n128/b1` | 3.14771 ± 0.0136224 (W 0.0274951) | 3.06534 ± 0.0211701 (W 0.0135742) | `lapack-openblas` 0.9738 (0.966 0.982) |
| `svd_thin/n256/b1` | 13.7938 ± 0.0112154 (W 0.0288723) | 14.6427 ± 0.0876947 (W 0.0125179) | `lapack-openblas` 1.062 (1.067 1.056) |
| `svd_thin/n512/b1` | 61.0815 ± 0.0579927 (W 0.372919) | 88.6871 ± 4.7822 (W 0.384744) | ! `lapack-openblas` 1.451 (1.396 1.508) |
| `svd_values/n128/b1` | 2.23 ± 0.00334674 (W 0.00653605) | 1.39101 ± 0.000480833 (W 0.00483767) | `lapack-openblas` 0.6238 (0.623 0.624) |
| `svd_values/n256/b1` | 10.9937 ± 0.00519653 (W 0.0318495) | 7.58456 ± 0.00626567 (W 0.0090989) | `lapack-openblas` 0.6899 (0.690 0.690) |
| `svd_values/n512/b1` | 49.3731 ± 0.293637 (W 0.368827) | 49.203 ± 0.0166255 (W 0.185062) | `lapack-openblas` 0.9966 (0.993 1.001) |
| `triangular_solve/n128/b1` | 0.0038025 ± 0.000191626 (W 6.66585e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0103545 ± 0.000928431 (W 6.39872e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.03953 ± 0.00050346 (W 0.00052697) | - | * `lapack-openblas` - |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.06039 ± 0.000121622 (W 6.35027e-05) | 0.071396 ± 4.38406e-05 (W 0.00104622) | `lapack-openblas` 1.182 (1.181 1.183) |
| `cholesky/n256/b1` | 0.315971 ± 0.000703571 (W 0.0019032) | 0.404299 ± 0.00139512 (W 0.00196033) | `lapack-openblas` 1.28 (1.285 1.274) |
| `cholesky/n512/b1` | 2.06207 ± 0.00351644 (W 0.00279261) | 2.68952 ± 0.00914006 (W 0.00627355) | `lapack-openblas` 1.304 (1.309 1.300) |
| `eigh/n128/b1` | 2.25168 ± 0.0036317 (W 0.00203358) | 1.78844 ± 0.0116008 (W 0.00754899) | `lapack-openblas` 0.7943 (0.799 0.790) |
| `eigh/n256/b1` | 9.78304 ± 0.0199949 (W 0.0200915) | 8.74268 ± 0.0297961 (W 0.0160843) | `lapack-openblas` 0.8937 (0.897 0.890) |
| `eigh/n512/b1` | 48.6717 ± 0.0825964 (W 0.0583357) | 49.6894 ± 0.114541 (W 0.039805) | `lapack-openblas` 1.021 (1.024 1.018) |
| `full_piv_lu/n128/b1` | 0.287798 ± 0.00190777 (W 0.00229955) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 2.61598 ± 0.00726764 (W 0.0102582) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 21.2643 ± 0.355286 (W 0.0180258) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.254814 ± 0.0016617 (W 0.00164512) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.255151 ± 0.00120845 (W 0.00174677) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.89768 ± 0.00477933 (W 0.0048576) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.87436 ± 0.00530259 (W 0.00555548) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.5929 ± 0.0188069 (W 0.0264981) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.7265 ± 0.020161 (W 0.0089207) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.130167 ± 0.0222717 (W 0.00129301) | 0.153662 ± 0.000129401 (W 0.000885982) | ! p `lapack-openblas` 1.189 (1.344 1.052) |
| `lu/n256/b1` | 0.893711 ± 0.00031042 (W 0.00226936) | 0.842845 ± 0.00162917 (W 0.00770755) | `lapack-openblas` 0.9431 (0.942 0.944) |
| `lu/n512/b1` | 6.13951 ± 0.000832265 (W 0.0118234) | 5.16444 ± 0.0226055 (W 0.0136325) | `lapack-openblas` 0.8412 (0.839 0.844) |
| `qr/n128/b1` | 0.490348 ± 0.00476024 (W 0.00327792) | 0.758763 ± 0.0129818 (W 0.00573066) | `lapack-openblas` 1.547 (1.539 1.555) |
| `qr/n256/b1` | 2.77827 ± 0.0005671 (W 0.00181167) | 4.07778 ± 0.0176458 (W 0.00420597) | `lapack-openblas` 1.468 (1.472 1.463) |
| `qr/n512/b1` | 19.7317 ± 0.181808 (W 0.0267282) | 27.2197 ± 0.166273 (W 0.189743) | `lapack-openblas` 1.38 (1.395 1.365) |
| `qr_factor/n128/b1` | 0.27839 ± 0.000599627 (W 0.0018637) | 0.376041 ± 0.00729734 (W 0.00177868) | `lapack-openblas` 1.351 (1.330 1.371) |
| `qr_factor/n256/b1` | 1.37333 ± 0.0012537 (W 0.00263926) | 1.87869 ± 0.00676418 (W 0.00667004) | `lapack-openblas` 1.368 (1.364 1.372) |
| `qr_factor/n512/b1` | 7.95077 ± 0.00371726 (W 0.0089658) | 12.4827 ± 0.0615289 (W 0.221144) | `lapack-openblas` 1.57 (1.565 1.575) |
| `solve/n128/b1` | 0.112103 ± 0.000522552 (W 0.00118088) | 0.150737 ± 0.000323855 (W 0.00176768) | `lapack-openblas` 1.345 (1.347 1.342) |
| `solve/n256/b1` | 0.667651 ± 0.00339694 (W 0.00226574) | 0.827385 ± 0.00593545 (W 0.00289841) | `lapack-openblas` 1.239 (1.241 1.237) |
| `solve/n512/b1` | 6.03712 ± 0.0139102 (W 0.0108182) | 5.08576 ± 0.0325064 (W 0.0165028) | `lapack-openblas` 0.8424 (0.848 0.837) |
| `svd_thin/n128/b1` | 3.68681 ± 0.0159863 (W 0.00418199) | 3.02037 ± 0.00626214 (W 0.00868999) | `lapack-openblas` 0.8192 (0.816 0.823) |
| `svd_thin/n256/b1` | 18.3615 ± 0.0197665 (W 0.0232303) | 17.0094 ± 0.0177731 (W 0.0169965) | `lapack-openblas` 0.9264 (0.925 0.928) |
| `svd_thin/n512/b1` | 104.666 ± 0.155988 (W 0.0795176) | 117.405 ± 0.296276 (W 0.37185) | `lapack-openblas` 1.122 (1.125 1.119) |
| `svd_values/n128/b1` | 2.61947 ± 0.00500561 (W 0.00636727) | 1.29025 ± 0.00921219 (W 0.00273915) | `lapack-openblas` 0.4926 (0.491 0.494) |
| `svd_values/n256/b1` | 12.3223 ± 0.0865067 (W 0.0161189) | 7.67361 ± 0.0320136 (W 0.0173683) | `lapack-openblas` 0.6227 (0.628 0.618) |
| `svd_values/n512/b1` | 65.7156 ± 0.604819 (W 0.0466088) | 53.2868 ± 0.0568676 (W 0.252199) | `lapack-openblas` 0.8109 (0.816 0.806) |
| `triangular_solve/n128/b1` | 0.004524 ± 6.36396e-05 (W 5.59321e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.013546 ± 8.48528e-05 (W 3.24252e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.04469 ± 0.00325269 (W 0.000186832) | - | * ! `lapack-openblas` - |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.0967585 ± 0.00343725 (W 0.00460452) | 0.080959 ± 0.00128128 (W 0.00228962) | ! `lapack-openblas` 0.8369 (0.807 0.868) |
| `cholesky/n256/b1` | 0.342349 ± 0.0135291 (W 0.0223739) | 0.277977 ± 0.000876105 (W 0.0027508) | ! `lapack-openblas` 0.8123 (0.833 0.792) |
| `cholesky/n512/b1` | 1.19608 ± 0.0142079 (W 0.0324263) | 1.33505 ± 0.00924259 (W 0.00402255) | `lapack-openblas` 1.116 (1.131 1.101) |
| `eigh/n128/b1` | 2.30758 ± 0.0493341 (W 0.0425606) | 1.41973 ± 0.00181019 (W 0.00266777) | `lapack-openblas` 0.6153 (0.624 0.607) |
| `eigh/n256/b1` | 6.95274 ± 0.0424363 (W 0.0395606) | 5.65507 ± 0.0205973 (W 0.00705197) | `lapack-openblas` 0.8134 (0.815 0.812) |
| `eigh/n512/b1` | 27.5992 ± 2.49206 (W 0.883072) | 26.2696 ± 0.0517128 (W 0.0294286) | ! p `lapack-openblas` 0.9538 (1.015 0.896) |
| `full_piv_lu/n128/b1` | 0.29247 ± 0.00124239 (W 0.00199349) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 2.63642 ± 0.0176628 (W 0.00719099) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 16.9749 ± 0.188245 (W 0.0444144) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.083659 ± 0.000367696 (W 0.000842697) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.0862335 ± 0.000495682 (W 0.00104711) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.518964 ± 0.00182504 (W 0.00272442) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.52218 ± 0.00363099 (W 0.00345095) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.12565 ± 0.0345231 (W 0.00625725) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.16768 ± 0.0016221 (W 0.00873851) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.20074 ± 0.0263814 (W 0.0105731) | 0.154418 ± 0.00129542 (W 0.00101672) | ! p `lapack-openblas` 0.7726 (0.843 0.708) |
| `lu/n256/b1` | 1.03841 ± 0.00520501 (W 0.0154208) | 0.505245 ± 0.00194384 (W 0.00243622) | `lapack-openblas` 0.4866 (0.487 0.486) |
| `lu/n512/b1` | 4.59589 ± 0.00331916 (W 0.0333904) | 2.65061 ± 0.0014821 (W 0.0196507) | `lapack-openblas` 0.5767 (0.577 0.576) |
| `qr/n128/b1` | 1.39417 ± 0.00389404 (W 0.0176775) | 0.786733 ± 0.00152382 (W 0.00707564) | `lapack-openblas` 0.5643 (0.562 0.566) |
| `qr/n256/b1` | 3.63658 ± 0.0469703 (W 0.0586678) | 3.24009 ± 0.00932037 (W 0.00426818) | `lapack-openblas` 0.891 (0.885 0.897) |
| `qr/n512/b1` | 13.1716 ± 0.00770605 (W 0.109773) | 17.2332 ± 0.0293209 (W 0.0187902) | `lapack-openblas` 1.308 (1.310 1.306) |
| `qr_factor/n128/b1` | 1.18045 ± 0.00696147 (W 0.0239422) | 0.392996 ± 1.13137e-05 (W 0.00195715) | `lapack-openblas` 0.3329 (0.334 0.332) |
| `qr_factor/n256/b1` | 3.02876 ± 0.0102693 (W 0.0500232) | 1.45064 ± 0.000816708 (W 0.00397944) | `lapack-openblas` 0.479 (0.480 0.478) |
| `qr_factor/n512/b1` | 8.34727 ± 0.0576228 (W 0.0638847) | 7.64184 ± 0.0358234 (W 0.0121716) | `lapack-openblas` 0.9155 (0.923 0.908) |
| `solve/n128/b1` | 0.179536 ± 0.00444346 (W 0.00733168) | 0.116621 ± 0.00131663 (W 0.000463346) | `lapack-openblas` 0.6496 (0.633 0.666) |
| `solve/n256/b1` | 0.775086 ± 0.00695652 (W 0.0193853) | 0.610414 ± 0.170196 (W 0.00324346) | ! p `lapack-openblas` 0.7721 (0.937 0.636) |
| `solve/n512/b1` | 4.36283 ± 0.0512914 (W 0.031178) | 2.5761 ± 0.00497308 (W 0.0137088) | `lapack-openblas` 0.5905 (0.595 0.586) |
| `svd_thin/n128/b1` | 3.01486 ± 0.0174783 (W 0.0349966) | 2.94801 ± 0.0288903 (W 0.00467281) | `lapack-openblas` 0.9778 (0.967 0.989) |
| `svd_thin/n256/b1` | 13.6076 ± 0.00177272 (W 0.0592403) | 14.2636 ± 0.0602321 (W 0.00883772) | `lapack-openblas` 1.048 (1.051 1.045) |
| `svd_thin/n512/b1` | 60.6441 ± 0.0367335 (W 0.208509) | 86.3345 ± 1.26073 (W 0.392782) | `lapack-openblas` 1.424 (1.439 1.408) |
| `svd_values/n128/b1` | 2.15792 ± 0.00668994 (W 0.00301048) | 1.34879 ± 0.00370807 (W 0.00133614) | `lapack-openblas` 0.625 (0.625 0.625) |
| `svd_values/n256/b1` | 10.6714 ± 0.067668 (W 0.017882) | 7.31456 ± 0.0120597 (W 0.00649318) | `lapack-openblas` 0.6854 (0.688 0.683) |
| `svd_values/n512/b1` | 46.9926 ± 0.0495215 (W 0.181272) | 48.1506 ± 0.605131 (W 0.0691212) | `lapack-openblas` 1.025 (1.016 1.033) |
| `triangular_solve/n128/b1` | 0.0045785 ± 0.000509824 (W 3.6238e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0129045 ± 9.97021e-05 (W 2.05783e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.046243 ± 0.00390323 (W 0.00175129) | - | * ! `lapack-openblas` - |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.092475 ± 0.00226698 (W 0.00220602) | 0.07628 ± 0.000984293 (W 0.00174599) | `lapack-openblas` 0.825 (0.832 0.818) |
| `cholesky/n256/b1` | 0.372987 ± 0.00571201 (W 0.0265505) | 0.277942 ± 0.000560736 (W 0.0015644) | `lapack-openblas` 0.7452 (0.738 0.752) |
| `cholesky/n512/b1` | 1.20856 ± 0.00390818 (W 0.0335704) | 1.20486 ± 0.0112338 (W 0.00834885) | `lapack-openblas` 0.9969 (1.001 0.993) |
| `eigh/n128/b1` | 2.33538 ± 0.000582656 (W 0.0176849) | 1.36283 ± 0.0121375 (W 0.00381668) | `lapack-openblas` 0.5835 (0.580 0.587) |
| `eigh/n256/b1` | 6.98166 ± 0.0774487 (W 0.0350621) | 5.28747 ± 0.00749604 (W 0.00777475) | `lapack-openblas` 0.7574 (0.763 0.752) |
| `eigh/n512/b1` | 24.4868 ± 0.0444629 (W 0.0987102) | 22.4687 ± 0.175766 (W 0.0305589) | `lapack-openblas` 0.9176 (0.911 0.924) |
| `full_piv_lu/n128/b1` | 0.289845 ± 0.0034627 (W 0.00267969) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 2.62865 ± 0.0109396 (W 0.00785781) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 16.7164 ± 0.0352401 (W 0.0505011) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.10258 ± 2.05061e-05 (W 0.00143278) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.103246 ± 0.00301722 (W 0.00150759) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.389698 ± 0.0194666 (W 0.019583) | - | * ! `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.41481 ± 0.0115421 (W 0.0836755) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.62117 ± 0.0449465 (W 0.144213) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.72215 ± 0.0881918 (W 0.123242) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.212678 ± 0.0173064 (W 0.00518613) | 0.154593 ± 0.000453255 (W 0.000761367) | ! p `lapack-openblas` 0.7281 (0.770 0.689) |
| `lu/n256/b1` | 1.13246 ± 0.0260979 (W 0.021643) | 0.442028 ± 0.00201384 (W 0.00237807) | `lapack-openblas` 0.3904 (0.385 0.396) |
| `lu/n512/b1` | 4.75532 ± 0.0912889 (W 0.686366) | 1.75371 ± 0.00434446 (W 0.00489095) | `lapack-openblas` 0.3688 (0.375 0.363) |
| `qr/n128/b1` | 1.8702 ± 0.00173524 (W 0.020822) | 0.787462 ± 0.00156836 (W 0.00545438) | `lapack-openblas` 0.4211 (0.421 0.421) |
| `qr/n256/b1` | 4.61334 ± 0.0752715 (W 0.0430482) | 3.1674 ± 0.00400152 (W 0.00565141) | `lapack-openblas` 0.6866 (0.679 0.694) |
| `qr/n512/b1` | 17.024 ± 3.4809 (W 24.3564) | 15.3077 ± 0.0747772 (W 0.0781514) | ! p `lapack-openblas` 0.9087 (0.788 1.048) |
| `qr_factor/n128/b1` | 1.59007 ± 0.0317951 (W 0.032402) | 0.39354 ± 0.0024572 (W 0.0013489) | `lapack-openblas` 0.2475 (0.243 0.252) |
| `qr_factor/n256/b1` | 4.07872 ± 0.0972519 (W 1.40622) | 1.4313 ± 0.0024579 (W 0.00873363) | `lapack-openblas` 0.351 (0.357 0.345) |
| `qr_factor/n512/b1` | 9.89701 ± 0.0817981 (W 0.0620166) | 6.76567 ± 0.0484778 (W 0.0116152) | `lapack-openblas` 0.6836 (0.676 0.691) |
| `solve/n128/b1` | 0.188983 ± 0.00483802 (W 0.0041774) | 0.149704 ± 0.00130249 (W 0.00178365) | `lapack-openblas` 0.7923 (0.802 0.783) |
| `solve/n256/b1` | 0.796083 ± 0.000152028 (W 0.0311996) | 0.446887 ± 0.000734684 (W 0.00322781) | `lapack-openblas` 0.5614 (0.561 0.562) |
| `solve/n512/b1` | 4.56087 ± 0.106847 (W 0.0996878) | 1.72956 ± 0.00481681 (W 0.00453442) | `lapack-openblas` 0.3793 (0.372 0.386) |
| `svd_thin/n128/b1` | 3.09724 ± 0.0201575 (W 0.0221638) | 2.93371 ± 0.0118999 (W 0.0038815) | `lapack-openblas` 0.9472 (0.954 0.940) |
| `svd_thin/n256/b1` | 13.6294 ± 0.000816708 (W 0.0385773) | 13.8652 ± 0.000183141 (W 0.154457) | `lapack-openblas` 1.017 (1.017 1.017) |
| `svd_thin/n512/b1` | 59.9867 ± 0.4651 (W 0.29814) | 80.1173 ± 0.74935 (W 0.101867) | `lapack-openblas` 1.336 (1.352 1.320) |
| `svd_values/n128/b1` | 2.16518 ± 0.00202798 (W 0.00345136) | 1.33397 ± 0.00039103 (W 0.00192759) | `lapack-openblas` 0.6161 (0.616 0.617) |
| `svd_values/n256/b1` | 10.887 ± 0.123487 (W 0.0598964) | 7.28954 ± 0.0123178 (W 0.00789327) | `lapack-openblas` 0.6696 (0.674 0.665) |
| `svd_values/n512/b1` | 48.0052 ± 0.0833912 (W 0.207699) | 46.9008 ± 0.0531773 (W 0.0739654) | `lapack-openblas` 0.977 (0.977 0.977) |
| `triangular_solve/n128/b1` | 0.004248 ± 2.82843e-05 (W 3.45759e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0118475 ± 0.00129613 (W 0.000110265) | - | * ! `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.047214 ± 0.0020195 (W 0.00238012) | - | * ! `lapack-openblas` - |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.186891 ± 0.000358503 (W 0.00110333) | 0.328905 ± 0.00343937 (W 0.00233117) | `lapack-openblas` 1.76 (1.749 1.770) |
| `cholesky/n256/b1` | 1.21966 ± 0.00343654 (W 0.00289195) | 2.1266 ± 0.00607263 (W 0.00372467) | `lapack-openblas` 1.744 (1.737 1.751) |
| `cholesky/n512/b1` | 7.92784 ± 0.012624 (W 0.0132285) | 12.5212 ± 0.0464682 (W 0.01761) | `lapack-openblas` 1.579 (1.573 1.585) |
| `eigh/n128/b1` | 3.2897 ± 0.0115089 (W 0.00324763) | 3.37611 ± 0.018628 (W 0.00321758) | `lapack-openblas` 1.026 (1.020 1.033) |
| `eigh/n256/b1` | 17.4826 ± 0.0969861 (W 0.0192982) | 20.3332 ± 0.0189858 (W 0.0116381) | `lapack-openblas` 1.163 (1.168 1.158) |
| `eigh/n512/b1` | 105.785 ± 0.34132 (W 0.288184) | 141.698 ± 0.396818 (W 0.0939578) | `lapack-openblas` 1.339 (1.340 1.339) |
| `full_piv_lu/n128/b1` | 0.781596 ± 0.00296561 (W 0.00331907) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 6.08444 ± 0.0387021 (W 0.00690775) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 40.9024 ± 0.240591 (W 0.224095) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.05127 ± 0.00105854 (W 0.00101493) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05597 ± 0.00011738 (W 0.000972124) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.51896 ± 0.0150055 (W 0.00436857) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.52991 ± 0.00951624 (W 0.0121249) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.9618 ± 0.0108095 (W 0.0312801) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 57.0196 ± 0.0886952 (W 0.233086) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.338679 ± 0.00051336 (W 0.00288227) | 0.427212 ± 0.000345068 (W 0.00386724) | `lapack-openblas` 1.261 (1.263 1.259) |
| `lu/n256/b1` | 2.24554 ± 0.00143896 (W 0.0042706) | 2.79831 ± 0.00628971 (W 0.0081642) | `lapack-openblas` 1.246 (1.244 1.249) |
| `lu/n512/b1` | 15.0365 ± 0.0053924 (W 0.0304747) | 18.5705 ± 0.280791 (W 0.0339675) | `lapack-openblas` 1.235 (1.222 1.249) |
| `qr/n128/b1` | 1.56965 ± 0.00282277 (W 0.00327432) | 1.63332 ± 0.00514067 (W 0.00417043) | `lapack-openblas` 1.041 (1.042 1.040) |
| `qr/n256/b1` | 10.3011 ± 0.043014 (W 0.0146055) | 11.3821 ± 0.0052333 (W 0.0200314) | `lapack-openblas` 1.105 (1.101 1.109) |
| `qr/n512/b1` | 69.6929 ± 0.0112564 (W 0.0382135) | 75.2881 ± 0.0303016 (W 0.0168741) | `lapack-openblas` 1.08 (1.080 1.080) |
| `qr_factor/n128/b1` | 0.940643 ± 0.000911461 (W 0.00107809) | 0.826235 ± 0.00606698 (W 0.0031803) | `lapack-openblas` 0.8784 (0.882 0.874) |
| `qr_factor/n256/b1` | 5.99274 ± 0.0167754 (W 0.0147258) | 5.67924 ± 0.0135842 (W 0.0113696) | `lapack-openblas` 0.9477 (0.948 0.947) |
| `qr_factor/n512/b1` | 35.3099 ± 0.0278642 (W 0.0227393) | 37.3359 ± 0.0123376 (W 0.0278175) | `lapack-openblas` 1.057 (1.057 1.058) |
| `solve/n128/b1` | 0.334837 ± 0.00216375 (W 0.00248519) | 0.44975 ± 0.00467398 (W 0.00316547) | `lapack-openblas` 1.343 (1.359 1.327) |
| `solve/n256/b1` | 2.18513 ± 0.00160655 (W 0.00423242) | 2.8873 ± 0.00332977 (W 0.00332966) | `lapack-openblas` 1.321 (1.320 1.323) |
| `solve/n512/b1` | 14.9731 ± 0.031339 (W 0.0282432) | 18.5303 ± 0.067038 (W 0.0256383) | `lapack-openblas` 1.238 (1.236 1.239) |
| `svd_thin/n128/b1` | 5.75917 ± 0.0037314 (W 0.0100053) | 5.72017 ± 0.0070046 (W 0.0152851) | `lapack-openblas` 0.9932 (0.994 0.993) |
| `svd_thin/n256/b1` | 34.3115 ± 0.020154 (W 0.0483461) | 37.0307 ± 0.0551748 (W 0.0350259) | `lapack-openblas` 1.079 (1.081 1.078) |
| `svd_thin/n512/b1` | 211.943 ± 0.159054 (W 0.319299) | 235.079 ± 0.301713 (W 0.636594) | `lapack-openblas` 1.109 (1.110 1.109) |
| `svd_values/n128/b1` | 3.4679 ± 0.00315016 (W 0.00651126) | 2.29052 ± 0.00137744 (W 0.0066123) | `lapack-openblas` 0.6605 (0.661 0.660) |
| `svd_values/n256/b1` | 19.4281 ± 0.0463664 (W 0.0519692) | 16.3573 ± 0.15841 (W 0.0362459) | `lapack-openblas` 0.8419 (0.835 0.849) |
| `svd_values/n512/b1` | 112.355 ± 0.813138 (W 0.233323) | 101.33 ± 0.441254 (W 0.28854) | `lapack-openblas` 0.9019 (0.895 0.909) |
| `triangular_solve/n128/b1` | 0.0076745 ± 4.17193e-05 (W 0.000118635) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0234895 ± 6.43467e-05 (W 4.34581e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.084756 ± 0.000657609 (W 0.0013864) | - | * `lapack-openblas` - |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.20283 ± 0.00335169 (W 0.00379648) | 0.26357 ± 0.00372787 (W 0.00205141) | `lapack-openblas` 1.299 (1.297 1.302) |
| `cholesky/n256/b1` | 0.866404 ± 0.00843649 (W 0.0217864) | 1.41099 ± 0.00709652 (W 0.013374) | `lapack-openblas` 1.629 (1.612 1.646) |
| `cholesky/n512/b1` | 3.40546 ± 0.0145798 (W 0.0225141) | 6.94126 ± 0.0708825 (W 0.0414305) | `lapack-openblas` 2.038 (2.059 2.017) |
| `eigh/n128/b1` | 2.97453 ± 0.00872994 (W 0.0181869) | 2.6513 ± 0.013382 (W 0.00872254) | `lapack-openblas` 0.8913 (0.893 0.890) |
| `eigh/n256/b1` | 11.5384 ± 0.0694662 (W 0.0287728) | 12.0318 ± 0.0616922 (W 0.00569966) | `lapack-openblas` 1.043 (1.051 1.035) |
| `eigh/n512/b1` | 46.6828 ± 0.00904743 (W 0.10402) | 55.5985 ± 0.133604 (W 0.044372) | `lapack-openblas` 1.191 (1.189 1.193) |
| `full_piv_lu/n128/b1` | 0.782469 ± 0.00666095 (W 0.00534166) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 6.0614 ± 0.05551 (W 0.0261311) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 27.3417 ± 0.017998 (W 0.0634955) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.287631 ± 0.00172039 (W 0.00266213) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.289343 ± 5.65685e-06 (W 0.00213862) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92952 ± 0.00365221 (W 0.00576589) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94534 ± 0.0105748 (W 0.00614942) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.6153 ± 0.095219 (W 0.0277391) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.683 ± 0.0225532 (W 0.0186635) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.354958 ± 0.00075519 (W 0.00671559) | 0.309863 ± 0.000755897 (W 0.00466421) | `lapack-openblas` 0.873 (0.873 0.873) |
| `lu/n256/b1` | 1.73542 ± 0.000809637 (W 0.0178232) | 1.69651 ± 0.00198131 (W 0.00296055) | `lapack-openblas` 0.9776 (0.979 0.976) |
| `lu/n512/b1` | 7.60688 ± 0.0759942 (W 0.0247811) | 7.45376 ± 0.00663832 (W 0.0117981) | `lapack-openblas` 0.9799 (0.986 0.974) |
| `qr/n128/b1` | 1.92281 ± 0.025436 (W 0.0173488) | 1.47314 ± 0.00281428 (W 0.00483023) | `lapack-openblas` 0.7662 (0.774 0.758) |
| `qr/n256/b1` | 6.28273 ± 0.0346164 (W 0.0391833) | 7.12259 ± 0.00783545 (W 0.00893505) | `lapack-openblas` 1.134 (1.128 1.139) |
| `qr/n512/b1` | 26.724 ± 0.175848 (W 0.0571557) | 35.3844 ± 0.859 (W 0.0428618) | `lapack-openblas` 1.324 (1.295 1.353) |
| `qr_factor/n128/b1` | 1.67905 ± 0.0056717 (W 0.0197494) | 0.739397 ± 0.000634982 (W 0.00268895) | `lapack-openblas` 0.4404 (0.442 0.439) |
| `qr_factor/n256/b1` | 6.60774 ± 0.105898 (W 0.0378264) | 3.53533 ± 0.014693 (W 0.00939186) | `lapack-openblas` 0.5351 (0.527 0.543) |
| `qr_factor/n512/b1` | 24.3104 ± 0.305755 (W 0.110061) | 17.1281 ± 0.0740348 (W 0.0171945) | `lapack-openblas` 0.7046 (0.696 0.713) |
| `solve/n128/b1` | 0.349413 ± 0.00543836 (W 0.00674403) | 0.307979 ± 0.00207324 (W 0.00292541) | `lapack-openblas` 0.8815 (0.887 0.876) |
| `solve/n256/b1` | 1.60054 ± 0.00526087 (W 0.0165687) | 1.67233 ± 0.0113809 (W 0.00243356) | `lapack-openblas` 1.045 (1.042 1.047) |
| `solve/n512/b1` | 7.42294 ± 0.0249135 (W 0.0412619) | 7.39186 ± 0.0183515 (W 0.0120479) | `lapack-openblas` 0.9958 (0.992 1.000) |
| `svd_thin/n128/b1` | 4.37405 ± 0.00689005 (W 0.0225508) | 4.85968 ± 0.0725598 (W 0.0135184) | `lapack-openblas` 1.111 (1.098 1.124) |
| `svd_thin/n256/b1` | 22.6876 ± 0.00700601 (W 0.248992) | 23.4138 ± 0.00504167 (W 0.0315298) | `lapack-openblas` 1.032 (1.032 1.032) |
| `svd_thin/n512/b1` | 95.3235 ± 0.309126 (W 0.145702) | 117.281 ± 1.86144 (W 0.144176) | `lapack-openblas` 1.23 (1.214 1.247) |
| `svd_values/n128/b1` | 3.04789 ± 0.00175362 (W 0.00576905) | 2.46689 ± 0.00480338 (W 0.00693441) | `lapack-openblas` 0.8094 (0.810 0.809) |
| `svd_values/n256/b1` | 17.1885 ± 0.00557624 (W 0.0764909) | 12.0172 ± 0.0391263 (W 0.0166694) | `lapack-openblas` 0.6991 (0.701 0.697) |
| `svd_values/n512/b1` | 65.3431 ± 0.0587655 (W 0.146832) | 53.5973 ± 0.907557 (W 0.0380947) | `lapack-openblas` 0.8202 (0.811 0.830) |
| `triangular_solve/n128/b1` | 0.00778 ± 0.000176777 (W 0.000102208) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0235095 ± 0.000290621 (W 5.42362e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.0693015 ± 0.00140219 (W 0.00028551) | - | * `lapack-openblas` - |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.213043 ± 0.004109 (W 0.00471568) | 0.296678 ± 0.00249962 (W 0.00137421) | `lapack-openblas` 1.393 (1.403 1.382) |
| `cholesky/n256/b1` | 0.890106 ± 0.00701026 (W 0.0165652) | 1.3551 ± 0.00223587 (W 0.00281128) | `lapack-openblas` 1.522 (1.533 1.512) |
| `cholesky/n512/b1` | 3.0021 ± 0.00291611 (W 0.0184803) | 5.83421 ± 0.0504705 (W 0.0114484) | `lapack-openblas` 1.943 (1.930 1.957) |
| `eigh/n128/b1` | 3.0141 ± 0.0100798 (W 0.0304796) | 2.54623 ± 0.00546947 (W 0.00488012) | `lapack-openblas` 0.8448 (0.845 0.844) |
| `eigh/n256/b1` | 11.1505 ± 0.034533 (W 0.0431676) | 10.7884 ± 0.0266707 (W 0.00945565) | `lapack-openblas` 0.9675 (0.964 0.971) |
| `eigh/n512/b1` | 40.0961 ± 0.141535 (W 0.182325) | 43.097 ± 0.00274004 (W 0.0826332) | `lapack-openblas` 1.075 (1.078 1.072) |
| `full_piv_lu/n128/b1` | 0.782893 ± 0.0112048 (W 0.00616292) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 6.09103 ± 0.0672812 (W 0.0426751) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 25.5872 ± 0.129553 (W 0.455063) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.271138 ± 0.00250033 (W 0.00496269) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.273027 ± 0.00327249 (W 0.00225109) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.31094 ± 0.000902975 (W 0.0110197) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.31079 ± 0.000740341 (W 0.0616506) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.87579 ± 0.00495611 (W 0.330913) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.41953 ± 0.570982 (W 0.472878) | - | * ! `lapack-openblas` - |
| `lu/n128/b1` | 0.38054 ± 0.00187171 (W 0.00481096) | 0.29825 ± 0.00125511 (W 0.00342231) | `lapack-openblas` 0.7838 (0.783 0.784) |
| `lu/n256/b1` | 1.75206 ± 0.0101809 (W 0.0301562) | 1.31198 ± 0.00356594 (W 0.00426094) | `lapack-openblas` 0.7488 (0.750 0.747) |
| `lu/n512/b1` | 6.76529 ± 0.00503319 (W 0.0376955) | 5.13967 ± 0.0361423 (W 0.00905931) | `lapack-openblas` 0.7597 (0.763 0.756) |
| `qr/n128/b1` | 2.4703 ± 0.0231111 (W 0.0297768) | 1.45752 ± 0.0127406 (W 0.00293734) | `lapack-openblas` 0.59 (0.583 0.598) |
| `qr/n256/b1` | 6.91675 ± 0.0480663 (W 0.0538071) | 6.50667 ± 0.0225998 (W 0.0119205) | `lapack-openblas` 0.9407 (0.943 0.938) |
| `qr/n512/b1` | 23.5452 ± 0.166022 (W 0.263086) | 28.6881 ± 0.706842 (W 0.0394488) | `lapack-openblas` 1.218 (1.191 1.246) |
| `qr_factor/n128/b1` | 2.16165 ± 0.00468246 (W 0.0292498) | 0.73134 ± 0.00832194 (W 0.00509653) | `lapack-openblas` 0.3383 (0.336 0.341) |
| `qr_factor/n256/b1` | 7.77394 ± 0.0226437 (W 0.0341917) | 3.27192 ± 0.00231931 (W 0.00679652) | `lapack-openblas` 0.4209 (0.422 0.420) |
| `qr_factor/n512/b1` | 25.1949 ± 0.144274 (W 0.258255) | 13.8199 ± 0.0497443 (W 0.0164862) | `lapack-openblas` 0.5485 (0.545 0.552) |
| `solve/n128/b1` | 0.371719 ± 0.00315157 (W 0.00588803) | 0.298596 ± 0.000778525 (W 0.00460025) | `lapack-openblas` 0.8033 (0.807 0.800) |
| `solve/n256/b1` | 1.62194 ± 0.0111136 (W 0.0226932) | 1.32832 ± 0.033321 (W 0.00568802) | `lapack-openblas` 0.8188 (0.801 0.838) |
| `solve/n512/b1` | 6.52602 ± 0.0914897 (W 0.0741997) | 5.09825 ± 0.0212436 (W 0.00862099) | `lapack-openblas` 0.7813 (0.771 0.791) |
| `svd_thin/n128/b1` | 4.49329 ± 0.0111016 (W 0.0241546) | 4.79079 ± 0.000170413 (W 0.00712154) | `lapack-openblas` 1.066 (1.068 1.064) |
| `svd_thin/n256/b1` | 22.0811 ± 0.00912946 (W 0.112781) | 21.9887 ± 0.242876 (W 0.0237785) | `lapack-openblas` 0.9958 (0.988 1.003) |
| `svd_thin/n512/b1` | 81.5901 ± 0.190389 (W 0.257396) | 97.7156 ± 0.221244 (W 0.123075) | `lapack-openblas` 1.198 (1.198 1.198) |
| `svd_values/n128/b1` | 3.07085 ± 0.0270178 (W 0.00733844) | 2.55651 ± 0.00303844 (W 0.00580908) | `lapack-openblas` 0.8325 (0.837 0.828) |
| `svd_values/n256/b1` | 17.2935 ± 0.070693 (W 0.246893) | 11.9134 ± 0.0605305 (W 0.0194957) | `lapack-openblas` 0.6889 (0.693 0.684) |
| `svd_values/n512/b1` | 61.0914 ± 0.3396 (W 0.273438) | 48.2725 ± 0.100651 (W 0.0474779) | `lapack-openblas` 0.7902 (0.792 0.788) |
| `triangular_solve/n128/b1` | 0.007569 ± 7.07107e-06 (W 7.29225e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0234495 ± 0.000133643 (W 7.02042e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.0706935 ± 0.000127986 (W 0.00162855) | - | * `lapack-openblas` - |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.174061 ± 0.000507703 (W 0.00103183) | 0.184455 ± 0.000231224 (W 0.00118198) | `lapack-openblas` 1.06 (1.061 1.058) |
| `cholesky/n256/b1` | 1.12587 ± 0.00179252 (W 0.00834531) | 1.29607 ± 0.00159948 (W 0.00327388) | `lapack-openblas` 1.151 (1.151 1.151) |
| `cholesky/n512/b1` | 7.53377 ± 0.0162387 (W 0.205487) | 9.04077 ± 0.0303193 (W 0.0132897) | `lapack-openblas` 1.2 (1.201 1.199) |
| `eigh/n128/b1` | 3.27745 ± 0.00780363 (W 0.00823794) | 3.25119 ± 0.0150373 (W 0.00270225) | `lapack-openblas` 0.992 (0.987 0.997) |
| `eigh/n256/b1` | 17.3859 ± 0.0174776 (W 0.0144042) | 19.593 ± 0.00464569 (W 0.0219712) | `lapack-openblas` 1.127 (1.128 1.126) |
| `eigh/n512/b1` | 105.72 ± 0.1906 (W 0.24105) | 141.878 ± 0.389648 (W 0.221833) | `lapack-openblas` 1.342 (1.341 1.343) |
| `full_piv_lu/n128/b1` | 0.753638 ± 0.00120632 (W 0.00496652) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 5.80761 ± 0.0453086 (W 0.0140143) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 39.843 ± 0.236968 (W 0.0354992) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03614 ± 0.000429214 (W 0.00039865) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.04135 ± 0.000250316 (W 0.00294074) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.42836 ± 0.00360129 (W 0.202804) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.40869 ± 0.00854821 (W 0.00902298) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8035 ± 0.0214098 (W 0.0850411) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7566 ± 0.0751223 (W 0.0534063) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.304007 ± 0.000570635 (W 0.00197292) | 0.346504 ± 0.000380423 (W 0.00179159) | `lapack-openblas` 1.14 (1.139 1.140) |
| `lu/n256/b1` | 2.03873 ± 0.00203081 (W 0.00558261) | 2.34921 ± 0.000741755 (W 0.00340204) | `lapack-openblas` 1.152 (1.151 1.153) |
| `lu/n512/b1` | 14.0494 ± 0.00478358 (W 0.0238689) | 16.2714 ± 0.0186839 (W 0.0225525) | `lapack-openblas` 1.158 (1.159 1.157) |
| `qr/n128/b1` | 1.53726 ± 0.000505581 (W 0.00335352) | 1.53726 ± 0.00176777 (W 0.00515442) | `lapack-openblas` 1 (1.001 0.999) |
| `qr/n256/b1` | 10.0904 ± 0.0182009 (W 0.0199977) | 10.9425 ± 0.0366232 (W 0.0136284) | `lapack-openblas` 1.084 (1.086 1.083) |
| `qr/n512/b1` | 68.7229 ± 0.0264161 (W 0.0326565) | 72.3844 ± 0.0728348 (W 0.225397) | `lapack-openblas` 1.053 (1.054 1.053) |
| `qr_factor/n128/b1` | 0.737055 ± 0.00305894 (W 0.00165806) | 0.750697 ± 0.00390535 (W 0.00165879) | `lapack-openblas` 1.019 (1.025 1.012) |
| `qr_factor/n256/b1` | 4.53128 ± 0.00687449 (W 0.00484678) | 5.24139 ± 0.0173269 (W 0.0112867) | `lapack-openblas` 1.157 (1.161 1.153) |
| `qr_factor/n512/b1` | 28.4809 ± 0.111604 (W 0.0303849) | 35.3169 ± 0.0165322 (W 0.207116) | `lapack-openblas` 1.24 (1.243 1.237) |
| `solve/n128/b1` | 0.301027 ± 0.0016122 (W 0.00217605) | 0.363416 ± 0.000366281 (W 0.00259409) | `lapack-openblas` 1.207 (1.204 1.211) |
| `solve/n256/b1` | 1.97671 ± 0.00127916 (W 0.00188254) | 2.39885 ± 0.00505793 (W 0.0062332) | `lapack-openblas` 1.214 (1.212 1.215) |
| `solve/n512/b1` | 13.9989 ± 0.0223014 (W 0.0240179) | 16.5368 ± 0.000680944 (W 0.0142467) | `lapack-openblas` 1.181 (1.180 1.183) |
| `svd_thin/n128/b1` | 5.72106 ± 0.00125653 (W 0.00521731) | 5.53059 ± 0.00614759 (W 0.201105) | `lapack-openblas` 0.9667 (0.966 0.967) |
| `svd_thin/n256/b1` | 33.9747 ± 0.0148591 (W 0.036424) | 35.8306 ± 0.180089 (W 0.0302179) | `lapack-openblas` 1.055 (1.051 1.059) |
| `svd_thin/n512/b1` | 210.997 ± 0.547484 (W 0.468745) | 228.982 ± 0.529786 (W 0.622761) | `lapack-openblas` 1.085 (1.085 1.085) |
| `svd_values/n128/b1` | 3.45033 ± 0.00380211 (W 0.00595762) | 2.21649 ± 0.00549351 (W 0.00269442) | `lapack-openblas` 0.6424 (0.644 0.641) |
| `svd_values/n256/b1` | 19.1236 ± 0.0125554 (W 0.0360369) | 15.6463 ± 0.0267852 (W 0.0353737) | `lapack-openblas` 0.8182 (0.819 0.818) |
| `svd_values/n512/b1` | 111.646 ± 0.633505 (W 0.188352) | 95.8266 ± 0.412912 (W 0.276078) | `lapack-openblas` 0.8583 (0.852 0.864) |
| `triangular_solve/n128/b1` | 0.008025 ± 0.000595384 (W 5.91847e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.022027 ± 0.00160796 (W 7.1133e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.084295 ± 0.00327815 (W 0.00115402) | - | * ! `lapack-openblas` - |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.188733 ± 0.00186111 (W 0.00516285) | 0.123465 ± 0.00067953 (W 0.00076719) | `lapack-openblas` 0.6542 (0.656 0.652) |
| `cholesky/n256/b1` | 0.7883 ± 0.00720966 (W 0.00930785) | 0.593831 ± 0.00113703 (W 0.00131327) | `lapack-openblas` 0.7533 (0.747 0.759) |
| `cholesky/n512/b1` | 3.04308 ± 0.0109333 (W 0.0184792) | 3.55562 ± 0.0636347 (W 0.0389787) | `lapack-openblas` 1.168 (1.186 1.151) |
| `eigh/n128/b1` | 2.95371 ± 0.00236527 (W 0.0213205) | 2.5386 ± 0.00691409 (W 0.00349977) | `lapack-openblas` 0.8595 (0.862 0.857) |
| `eigh/n256/b1` | 11.445 ± 0.0180616 (W 0.0462691) | 11.406 ± 0.0262315 (W 0.0161531) | `lapack-openblas` 0.9966 (0.999 0.994) |
| `eigh/n512/b1` | 46.4017 ± 0.248076 (W 0.116275) | 52.6888 ± 0.153092 (W 0.208487) | `lapack-openblas` 1.135 (1.137 1.134) |
| `full_piv_lu/n128/b1` | 0.75683 ± 0.00100763 (W 0.00457725) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 5.81342 ± 0.0107862 (W 0.0191787) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 26.3318 ± 0.00563635 (W 0.0585939) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.285932 ± 4.38406e-05 (W 0.000922687) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.288656 ± 0.00195374 (W 0.00130855) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.92274 ± 0.00187383 (W 0.00192776) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93983 ± 0.00164756 (W 0.00375809) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.7565 ± 0.017013 (W 0.0360196) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.7576 ± 0.0212712 (W 0.0328904) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.324721 ± 0.00156412 (W 0.00514871) | 0.238808 ± 0.00044477 (W 0.00157713) | `lapack-openblas` 0.7354 (0.737 0.734) |
| `lu/n256/b1` | 1.50637 ± 0.0199814 (W 0.0183792) | 1.26474 ± 0.00271175 (W 0.00271959) | `lapack-openblas` 0.8396 (0.831 0.849) |
| `lu/n512/b1` | 6.67066 ± 0.0127541 (W 0.0485797) | 5.47172 ± 0.00177272 (W 0.00349673) | `lapack-openblas` 0.8203 (0.819 0.821) |
| `qr/n128/b1` | 1.88807 ± 0.0286597 (W 0.018968) | 1.36761 ± 0.00619708 (W 0.0053595) | `lapack-openblas` 0.7244 (0.730 0.719) |
| `qr/n256/b1` | 5.96343 ± 0.0466019 (W 1.49373) | 6.58929 ± 0.030226 (W 0.00841579) | `lapack-openblas` 1.105 (1.115 1.095) |
| `qr/n512/b1` | 25.7046 ± 0.0649527 (W 0.0546862) | 32.2609 ± 0.0890049 (W 0.0202957) | `lapack-openblas` 1.255 (1.250 1.260) |
| `qr_factor/n128/b1` | 1.41727 ± 0.0288139 (W 0.00813805) | 0.660011 ± 0.0035815 (W 0.00145024) | `lapack-openblas` 0.4657 (0.457 0.474) |
| `qr_factor/n256/b1` | 4.28846 ± 0.0393887 (W 0.028241) | 3.08991 ± 0.00384949 (W 0.00372153) | `lapack-openblas` 0.7205 (0.715 0.726) |
| `qr_factor/n512/b1` | 14.5567 ± 0.000144957 (W 0.242241) | 15.2434 ± 0.0186676 (W 0.0137405) | `lapack-openblas` 1.047 (1.046 1.048) |
| `solve/n128/b1` | 0.315098 ± 0.00125936 (W 0.00770931) | 0.236734 ± 0.000632153 (W 0.00170374) | `lapack-openblas` 0.7513 (0.755 0.748) |
| `solve/n256/b1` | 1.39767 ± 0.0128701 (W 0.0153497) | 1.26007 ± 0.00221678 (W 0.00204184) | `lapack-openblas` 0.9016 (0.906 0.897) |
| `solve/n512/b1` | 6.53086 ± 0.0342233 (W 0.021146) | 5.53443 ± 0.0128573 (W 0.00678701) | `lapack-openblas` 0.8474 (0.846 0.849) |
| `svd_thin/n128/b1` | 4.33957 ± 0.016489 (W 0.0231983) | 4.64363 ± 0.00307662 (W 0.0105725) | `lapack-openblas` 1.07 (1.072 1.068) |
| `svd_thin/n256/b1` | 22.3519 ± 0.0262817 (W 0.0981654) | 22.5045 ± 0.146273 (W 0.0471049) | `lapack-openblas` 1.007 (1.011 1.003) |
| `svd_thin/n512/b1` | 93.8596 ± 0.162104 (W 0.193502) | 112.487 ± 1.50366 (W 0.0468923) | `lapack-openblas` 1.198 (1.211 1.186) |
| `svd_values/n128/b1` | 3.06082 ± 0.0201165 (W 0.00823477) | 2.38846 ± 0.00742533 (W 0.00971547) | `lapack-openblas` 0.7803 (0.782 0.778) |
| `svd_values/n256/b1` | 16.9315 ± 0.0357683 (W 0.0364001) | 11.637 ± 0.00931896 (W 0.0263144) | `lapack-openblas` 0.6873 (0.687 0.688) |
| `svd_values/n512/b1` | 64.2145 ± 0.0121375 (W 0.219441) | 51.5639 ± 0.0912033 (W 0.0332606) | `lapack-openblas` 0.803 (0.802 0.804) |
| `triangular_solve/n128/b1` | 0.0074995 ± 0.000446184 (W 4.53558e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.021661 ± 0.00150189 (W 7.05416e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.0732895 ± 0.00283338 (W 0.00135186) | - | * ! `lapack-openblas` - |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `cholesky/n128/b1` | 0.200676 ± 0.0017911 (W 0.00303508) | 0.15606 ± 0.003194 (W 0.00186674) | `lapack-openblas` 0.7776 (0.771 0.784) |
| `cholesky/n256/b1` | 0.786119 ± 0.00335522 (W 0.0171138) | 0.545373 ± 0.00310137 (W 0.00265503) | `lapack-openblas` 0.6938 (0.693 0.694) |
| `cholesky/n512/b1` | 2.51611 ± 0.00310491 (W 0.0186667) | 2.46083 ± 0.00711844 (W 0.00556129) | `lapack-openblas` 0.978 (0.975 0.981) |
| `eigh/n128/b1` | 2.99082 ± 0.00637527 (W 0.0293568) | 2.4348 ± 0.00570282 (W 0.00318474) | `lapack-openblas` 0.8141 (0.817 0.812) |
| `eigh/n256/b1` | 11.0707 ± 0.000578413 (W 0.0370245) | 10.1648 ± 0.0205026 (W 0.00985001) | `lapack-openblas` 0.9182 (0.920 0.917) |
| `eigh/n512/b1` | 39.7636 ± 0.0884046 (W 0.308189) | 40.2499 ± 0.12209 (W 0.116125) | `lapack-openblas` 1.012 (1.016 1.008) |
| `full_piv_lu/n128/b1` | 0.752466 ± 0.0114601 (W 0.00286693) | - | * `lapack-openblas` - |
| `full_piv_lu/n256/b1` | 5.78507 ± 0.000843578 (W 0.0323174) | - | * `lapack-openblas` - |
| `full_piv_lu/n512/b1` | 24.6503 ± 0.00664822 (W 0.156241) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.277225 ± 0.00161503 (W 0.00159534) | - | * `lapack-openblas` - |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.279148 ± 0.00134562 (W 0.00146723) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.28896 ± 0.00532451 (W 0.0653198) | - | * `lapack-openblas` - |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.29937 ± 0.0042688 (W 0.0367719) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.92167 ± 0.0637337 (W 0.447798) | - | * `lapack-openblas` - |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.74154 ± 0.0241633 (W 0.350583) | - | * `lapack-openblas` - |
| `lu/n128/b1` | 0.346216 ± 0.00201313 (W 0.00514264) | 0.226224 ± 0.0025866 (W 0.00180952) | `lapack-openblas` 0.6534 (0.656 0.651) |
| `lu/n256/b1` | 1.52923 ± 0.00241689 (W 0.0210776) | 0.890672 ± 4.73762e-05 (W 0.00203222) | `lapack-openblas` 0.5824 (0.583 0.582) |
| `lu/n512/b1` | 5.70433 ± 0.0031742 (W 0.0246826) | 3.24545 ± 0.0372744 (W 0.00476868) | `lapack-openblas` 0.5689 (0.565 0.573) |
| `qr/n128/b1` | 2.40372 ± 0.00609314 (W 0.0332582) | 1.35629 ± 0.00747695 (W 0.00596546) | `lapack-openblas` 0.5642 (0.561 0.567) |
| `qr/n256/b1` | 6.69514 ± 0.0410907 (W 0.0346425) | 5.94199 ± 0.0103245 (W 0.00703045) | `lapack-openblas` 0.8875 (0.883 0.892) |
| `qr/n512/b1` | 22.2252 ± 0.0906907 (W 0.274512) | 25.6875 ± 0.040706 (W 0.0324468) | `lapack-openblas` 1.156 (1.158 1.154) |
| `qr_factor/n128/b1` | 1.88954 ± 0.023734 (W 0.0437558) | 0.652556 ± 0.000313955 (W 0.00160602) | `lapack-openblas` 0.3454 (0.349 0.342) |
| `qr_factor/n256/b1` | 5.26576 ± 0.0259819 (W 0.0581642) | 2.78876 ± 0.0170151 (W 0.00815948) | `lapack-openblas` 0.5296 (0.525 0.534) |
| `qr_factor/n512/b1` | 14.6851 ± 0.00587464 (W 0.16701) | 12.0007 ± 0.101751 (W 0.0127458) | `lapack-openblas` 0.8172 (0.813 0.822) |
| `solve/n128/b1` | 0.332916 ± 0.00530542 (W 0.00529567) | 0.230637 ± 0.00219557 (W 0.00179278) | `lapack-openblas` 0.6928 (0.696 0.690) |
| `solve/n256/b1` | 1.38336 ± 0.00889328 (W 0.0158039) | 0.903707 ± 0.00297975 (W 0.00275888) | `lapack-openblas` 0.6533 (0.655 0.652) |
| `solve/n512/b1` | 5.51841 ± 0.0226161 (W 0.026914) | 3.33446 ± 0.0111461 (W 0.00548965) | `lapack-openblas` 0.6042 (0.605 0.604) |
| `svd_thin/n128/b1` | 4.45976 ± 0.033857 (W 0.0246117) | 4.60754 ± 0.0254693 (W 0.00683254) | `lapack-openblas` 1.033 (1.035 1.032) |
| `svd_thin/n256/b1` | 21.7837 ± 0.00174938 (W 0.0732153) | 20.7599 ± 0.0402662 (W 0.0393728) | `lapack-openblas` 0.953 (0.954 0.952) |
| `svd_thin/n512/b1` | 80.5945 ± 0.465323 (W 0.277257) | 93.276 ± 0.217092 (W 0.0786068) | `lapack-openblas` 1.157 (1.160 1.155) |
| `svd_values/n128/b1` | 3.03951 ± 0.0227533 (W 0.00783737) | 2.48219 ± 0.00534926 (W 0.00661242) | `lapack-openblas` 0.8167 (0.822 0.811) |
| `svd_values/n256/b1` | 17.0379 ± 0.0940226 (W 0.110474) | 11.4985 ± 0.0488611 (W 0.0243156) | `lapack-openblas` 0.6749 (0.680 0.670) |
| `svd_values/n512/b1` | 60.1354 ± 0.328134 (W 0.0831929) | 45.9196 ± 0.100964 (W 0.035254) | `lapack-openblas` 0.7636 (0.765 0.762) |
| `triangular_solve/n128/b1` | 0.0071485 ± 7.84889e-05 (W 2.86713e-05) | - | * `lapack-openblas` - |
| `triangular_solve/n256/b1` | 0.0216005 ± 0.00185616 (W 6.78804e-05) | - | * ! `lapack-openblas` - |
| `triangular_solve/n512/b1` | 0.0837085 ± 0.000907218 (W 0.0031574) | - | * `lapack-openblas` - |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.825255 ± 0.0209608 (W 0.005918) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 52.9333 ± 0.525163 (W 0.941781) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.570857 ± 0.00238436 (W 0.00251028) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.569474 ± 0.00325481 (W 0.00228501) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.1801 ± 0.017829 (W 0.248632) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.2033 ± 0.0757806 (W 0.0380606) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.483156 ± 0.0100996 (W 0.00482161) | 0.744061 ± 0.169451 (W 0.00302582) | ! p `lapack-openblas` 1.52 (1.815 1.273) |
| `lu/4096x256/b1` | 19.014 ± 0.0519999 (W 0.0476813) | 28.1887 ± 0.0283854 (W 0.05666) | `lapack-openblas` 1.483 (1.484 1.481) |
| `qr/1024x64/b1` | 1.56178 ± 0.0173715 (W 0.0061258) | 2.53715 ± 0.0083679 (W 0.0171092) | `lapack-openblas` 1.625 (1.608 1.641) |
| `qr/4096x256/b1` | 74.2719 ± 0.213408 (W 0.0871648) | 105.353 ± 2.77636 (W 1.34548) | `lapack-openblas` 1.418 (1.395 1.442) |
| `qr_factor/1024x64/b1` | 1.82598 ± 0.000514067 (W 0.0064056) | 1.27799 ± 0.0140339 (W 0.00893469) | `lapack-openblas` 0.6999 (0.705 0.694) |
| `qr_factor/4096x256/b1` | 77.7071 ± 0.316432 (W 0.0624424) | 49.8088 ± 0.146553 (W 0.467201) | `lapack-openblas` 0.641 (0.641 0.640) |
| `svd_thin/1024x64/b1` | 2.51285 ± 0.0129238 (W 0.00339883) | 3.77133 ± 0.0111949 (W 0.0148708) | `lapack-openblas` 1.501 (1.503 1.499) |
| `svd_thin/4096x256/b1` | 88.4331 ± 0.0663846 (W 0.125975) | 146.822 ± 1.70427 (W 1.06313) | `lapack-openblas` 1.66 (1.648 1.673) |
| `svd_values/1024x64/b1` | 1.50593 ± 0.01098 (W 0.00422912) | 1.9338 ± 0.00464357 (W 0.00754049) | `lapack-openblas` 1.284 (1.293 1.275) |
| `svd_values/4096x256/b1` | 44.8515 ± 0.0136698 (W 0.234907) | 69.9941 ± 2.43573 (W 1.30178) | `lapack-openblas` 1.56 (1.522 1.599) |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.83363 ± 0.00367342 (W 0.00836746) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 25.991 ± 0.178935 (W 0.447504) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.159708 ± 0.000515481 (W 0.00112974) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.16106 ± 0.00194879 (W 0.00103309) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 9.48273 ± 0.0318389 (W 0.0398091) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 9.50874 ± 0.0394382 (W 0.0307709) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.502226 ± 0.00195939 (W 0.00760955) | 0.671933 ± 0.158441 (W 0.00391686) | ! p `lapack-openblas` 1.319 (1.565 1.112) |
| `lu/4096x256/b1` | 13.1011 ± 0.0216629 (W 0.047875) | 22.2237 ± 0.125197 (W 0.0563804) | `lapack-openblas` 1.696 (1.701 1.692) |
| `qr/1024x64/b1` | 1.68081 ± 0.00173524 (W 0.0126416) | 2.60202 ± 0.0290006 (W 0.00582365) | `lapack-openblas` 1.548 (1.535 1.561) |
| `qr/4096x256/b1` | 36.1714 ± 0.979032 (W 0.811273) | 66.9607 ± 2.11199 (W 0.456526) | `lapack-openblas` 1.851 (1.776 1.929) |
| `qr_factor/1024x64/b1` | 3.94468 ± 0.0952034 (W 0.156829) | 1.336 ± 0.00563423 (W 0.0106584) | `lapack-openblas` 0.3387 (0.332 0.346) |
| `qr_factor/4096x256/b1` | 76.0168 ± 0.376431 (W 0.286678) | 33.5508 ± 0.601102 (W 0.522043) | `lapack-openblas` 0.4413 (0.449 0.434) |
| `svd_thin/1024x64/b1` | 2.75948 ± 0.00441093 (W 0.0227193) | 3.60679 ± 0.00114834 (W 0.0113084) | `lapack-openblas` 1.307 (1.305 1.309) |
| `svd_thin/4096x256/b1` | 50.3651 ± 0.0994878 (W 0.736662) | 85.1145 ± 4.14868 (W 1.74561) | ! `lapack-openblas` 1.689 (1.629 1.751) |
| `svd_values/1024x64/b1` | 2.0974 ± 0.00516329 (W 0.0191664) | 1.98259 ± 0.0128312 (W 0.00490427) | `lapack-openblas` 0.9452 (0.951 0.939) |
| `svd_values/4096x256/b1` | 35.3701 ± 0.0617403 (W 0.0939002) | 48.9051 ± 1.39224 (W 0.183239) | `lapack-openblas` 1.382 (1.353 1.412) |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.826441 ± 0.0179061 (W 0.00762113) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 19.4693 ± 0.0651712 (W 0.14975) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.137456 ± 0.00106985 (W 0.00178273) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.136133 ± 0.0039598 (W 0.00194315) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 5.02996 ± 0.00718491 (W 1.00612) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.10578 ± 0.00293803 (W 0.524736) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.518522 ± 0.00567948 (W 0.014436) | 0.667158 ± 0.174812 (W 0.00333526) | ! p `lapack-openblas` 1.264 (1.537 1.040) |
| `lu/4096x256/b1` | 12.2395 ± 0.0151024 (W 0.0371219) | 19.6048 ± 0.0163639 (W 0.0493581) | `lapack-openblas` 1.602 (1.599 1.604) |
| `qr/1024x64/b1` | 2.00259 ± 0.0258646 (W 0.249944) | 2.60148 ± 0.00552675 (W 0.00579118) | `lapack-openblas` 1.299 (1.289 1.309) |
| `qr/4096x256/b1` | 35.4373 ± 0.0390726 (W 0.541793) | 63.098 ± 0.461635 (W 1.16876) | `lapack-openblas` 1.781 (1.770 1.791) |
| `qr_factor/1024x64/b1` | 4.52496 ± 0.00247346 (W 0.727039) | 1.31548 ± 0.00376605 (W 0.00630875) | `lapack-openblas` 0.2907 (0.291 0.290) |
| `qr_factor/4096x256/b1` | 76.1935 ± 0.352994 (W 0.390445) | 29.547 ± 0.833743 (W 0.301769) | `lapack-openblas` 0.3877 (0.397 0.379) |
| `svd_thin/1024x64/b1` | 3.12876 ± 0.0274548 (W 0.0369569) | 3.58779 ± 0.00465701 (W 0.00409052) | `lapack-openblas` 1.147 (1.139 1.155) |
| `svd_thin/4096x256/b1` | 50.3328 ± 0.0588334 (W 0.458773) | 76.7428 ± 0.195752 (W 0.16279) | `lapack-openblas` 1.525 (1.526 1.523) |
| `svd_values/1024x64/b1` | 2.45656 ± 0.00591495 (W 0.0254191) | 1.99586 ± 0.0140141 (W 0.0048607) | `lapack-openblas` 0.8124 (0.810 0.815) |
| `svd_values/4096x256/b1` | 37.3492 ± 0.0700637 (W 6.1914) | 46.4384 ± 0.0415807 (W 0.700312) | `lapack-openblas` 1.243 (1.241 1.246) |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.741851 ± 0.0180199 (W 0.00847719) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 47.1152 ± 0.0501805 (W 0.146924) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.587023 ± 0.0234894 (W 0.00258982) | - | * ! `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.600143 ± 0.00202233 (W 0.00226436) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.909 ± 0.0885071 (W 0.21811) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.8296 ± 0.0169119 (W 0.0234534) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.388205 ± 0.00442295 (W 0.00218563) | 0.308219 ± 0.00339482 (W 0.00194798) | `lapack-openblas` 0.794 (0.794 0.794) |
| `lu/4096x256/b1` | 13.2538 ± 0.0294538 (W 0.0362187) | 13.0778 ± 0.0944171 (W 0.0245422) | `lapack-openblas` 0.9867 (0.990 0.983) |
| `qr/1024x64/b1` | 1.46603 ± 0.00648275 (W 0.0034041) | 1.8817 ± 0.000576999 (W 0.00504914) | `lapack-openblas` 1.284 (1.279 1.288) |
| `qr/4096x256/b1` | 68.7824 ± 0.253795 (W 0.201155) | 77.6754 ± 0.0436737 (W 0.402093) | `lapack-openblas` 1.129 (1.132 1.127) |
| `qr_factor/1024x64/b1` | 0.782593 ± 0.00786798 (W 0.00240676) | 0.962244 ± 0.000123037 (W 0.00219012) | `lapack-openblas` 1.23 (1.221 1.238) |
| `qr_factor/4096x256/b1` | 25.7982 ± 0.00547654 (W 0.027716) | 38.7313 ± 0.184433 (W 0.0702731) | `lapack-openblas` 1.501 (1.496 1.506) |
| `svd_thin/1024x64/b1` | 2.46503 ± 0.00739704 (W 0.0065857) | 3.25281 ± 0.0102474 (W 0.00652924) | `lapack-openblas` 1.32 (1.325 1.314) |
| `svd_thin/4096x256/b1` | 83.1407 ± 0.0741394 (W 0.397803) | 120.693 ± 0.161541 (W 0.220318) | `lapack-openblas` 1.452 (1.451 1.452) |
| `svd_values/1024x64/b1` | 1.41264 ± 0.0195381 (W 0.00511516) | 1.61036 ± 0.00105005 (W 0.00336003) | `lapack-openblas` 1.14 (1.152 1.128) |
| `svd_values/4096x256/b1` | 39.0942 ± 0.00599485 (W 0.0296993) | 54.6049 ± 0.28922 (W 0.202752) | `lapack-openblas` 1.397 (1.391 1.402) |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.741661 ± 0.0152134 (W 0.0100229) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 17.7456 ± 0.168089 (W 0.101576) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.178934 ± 0.00327956 (W 0.00157007) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.201607 ± 0.000659731 (W 0.00168939) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 10.906 ± 0.0504761 (W 0.022266) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 11.2269 ± 0.023768 (W 0.0146165) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.432934 ± 0.0017515 (W 0.00781795) | 0.253746 ± 0.00104298 (W 0.00361447) | `lapack-openblas` 0.5861 (0.586 0.586) |
| `lu/4096x256/b1` | 7.39228 ± 0.0199517 (W 0.0306309) | 7.26522 ± 0.0479355 (W 0.0320165) | `lapack-openblas` 0.9828 (0.986 0.980) |
| `qr/1024x64/b1` | 1.60073 ± 0.00993273 (W 0.133589) | 1.98171 ± 0.00759574 (W 0.00331717) | `lapack-openblas` 1.238 (1.247 1.229) |
| `qr/4096x256/b1` | 29.6306 ± 0.0150953 (W 0.0691283) | 41.0015 ± 0.49 (W 0.0551649) | `lapack-openblas` 1.384 (1.395 1.373) |
| `qr_factor/1024x64/b1` | 1.35345 ± 0.00587818 (W 0.00690363) | 1.02608 ± 0.000265872 (W 0.00198414) | `lapack-openblas` 0.7581 (0.756 0.760) |
| `qr_factor/4096x256/b1` | 17.7946 ± 0.245836 (W 1.17667) | 20.5256 ± 0.0175992 (W 0.01843) | `lapack-openblas` 1.154 (1.164 1.143) |
| `svd_thin/1024x64/b1` | 2.69742 ± 0.0019304 (W 0.0187243) | 3.08777 ± 0.00536058 (W 0.00405454) | `lapack-openblas` 1.145 (1.146 1.144) |
| `svd_thin/4096x256/b1` | 44.7622 ± 0.014804 (W 0.158676) | 66.9014 ± 0.0982136 (W 0.311584) | `lapack-openblas` 1.495 (1.493 1.496) |
| `svd_values/1024x64/b1` | 1.99139 ± 0.00575868 (W 0.0175051) | 1.67471 ± 0.00293308 (W 0.00300759) | `lapack-openblas` 0.841 (0.842 0.840) |
| `svd_values/4096x256/b1` | 29.7797 ± 0.101342 (W 0.116993) | 36.1335 ± 0.0825363 (W 0.036991) | `lapack-openblas` 1.213 (1.212 1.214) |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.728609 ± 0.000280721 (W 0.00318315) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 13.7352 ± 0.071584 (W 0.0939278) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.15832 ± 0.00317279 (W 0.00196474) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.157999 ± 0.00141704 (W 0.0019095) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.75843 ± 0.0527806 (W 0.152455) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.79021 ± 0.0365772 (W 1.0293) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.450979 ± 0.00201667 (W 0.0153198) | 0.236878 ± 0.000353553 (W 0.00171508) | `lapack-openblas` 0.5253 (0.526 0.524) |
| `lu/4096x256/b1` | 6.72686 ± 0.0416641 (W 0.0407605) | 5.01544 ± 0.348512 (W 0.0178157) | ! p `lapack-openblas` 0.7447 (0.706 0.786) |
| `qr/1024x64/b1` | 1.91502 ± 0.00388909 (W 0.0348253) | 1.98537 ± 0.0189448 (W 0.00520847) | `lapack-openblas` 1.037 (1.028 1.045) |
| `qr/4096x256/b1` | 29.6467 ± 0.202038 (W 0.684287) | 36.4206 ± 0.588052 (W 0.0408864) | `lapack-openblas` 1.228 (1.209 1.249) |
| `qr_factor/1024x64/b1` | 1.6089 ± 0.0151059 (W 0.0198134) | 1.03076 ± 0.00563635 (W 0.00140876) | `lapack-openblas` 0.6407 (0.647 0.634) |
| `qr_factor/4096x256/b1` | 19.3848 ± 0.360245 (W 0.194723) | 18.0575 ± 0.166667 (W 0.0254914) | `lapack-openblas` 0.9316 (0.913 0.950) |
| `svd_thin/1024x64/b1` | 3.07961 ± 0.0168235 (W 0.0275598) | 3.08166 ± 0.00604576 (W 0.0073313) | `lapack-openblas` 1.001 (1.006 0.995) |
| `svd_thin/4096x256/b1` | 44.5352 ± 0.275724 (W 0.552627) | 59.5368 ± 0.191395 (W 0.128138) | `lapack-openblas` 1.337 (1.346 1.328) |
| `svd_values/1024x64/b1` | 2.35211 ± 0.00194879 (W 0.0392565) | 1.6939 ± 0.00220476 (W 0.00313518) | `lapack-openblas` 0.7202 (0.719 0.721) |
| `svd_values/4096x256/b1` | 31.714 ± 0.0840064 (W 0.0656855) | 33.8548 ± 0.35807 (W 0.128905) | `lapack-openblas` 1.067 (1.062 1.073) |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.84271 ± 0.0160443 (W 0.00518963) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 156.161 ± 0.728281 (W 1.95312) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.24172 ± 0.0126572 (W 0.00551574) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.21799 ± 0.027061 (W 0.00728174) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.98 ± 0.228977 (W 0.11905) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.73 ± 0.0328543 (W 0.263202) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 1.05278 ± 0.00427022 (W 0.00102378) | 1.32495 ± 0.0367335 (W 0.00313753) | `lapack-openblas` 1.258 (1.230 1.287) |
| `lu/4096x256/b1` | 54.321 ± 0.122419 (W 0.0577919) | 69.066 ± 5.71463 (W 0.232493) | ! p `lapack-openblas` 1.269 (1.344 1.199) |
| `qr/1024x64/b1` | 4.74874 ± 0.00571201 (W 0.0075228) | 4.3318 ± 0.0743367 (W 0.00809202) | `lapack-openblas` 0.9121 (0.922 0.902) |
| `qr/4096x256/b1` | 251.051 ± 5.79633 (W 0.271049) | 268.14 ± 10.5208 (W 1.39947) | ! `lapack-openblas` 1.068 (1.080 1.056) |
| `qr_factor/1024x64/b1` | 4.00545 ± 0.019618 (W 0.0133037) | 2.2055 ± 0.0261028 (W 0.00449583) | `lapack-openblas` 0.5506 (0.557 0.544) |
| `qr_factor/4096x256/b1` | 174.932 ± 0.311143 (W 0.0705467) | 131.946 ± 1.80252 (W 0.716275) | `lapack-openblas` 0.7542 (0.763 0.746) |
| `svd_thin/1024x64/b1` | 5.98218 ± 0.0169451 (W 0.00444542) | 6.87316 ± 0.0935113 (W 0.00650927) | `lapack-openblas` 1.149 (1.158 1.140) |
| `svd_thin/4096x256/b1` | 281.088 ± 0.112699 (W 1.34303) | 384.562 ± 2.20919 (W 0.99248) | `lapack-openblas` 1.368 (1.363 1.373) |
| `svd_values/1024x64/b1` | 3.07176 ± 0.013872 (W 0.00589299) | 3.14602 ± 0.0101526 (W 0.00924954) | `lapack-openblas` 1.024 (1.023 1.025) |
| `svd_values/4096x256/b1` | 122.475 ± 0.00857084 (W 0.257901) | 157.198 ± 1.8085 (W 0.879244) | `lapack-openblas` 1.283 (1.294 1.273) |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.83445 ± 0.00941583 (W 0.0107293) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 64.6085 ± 1.17607 (W 0.99043) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.589506 ± 0.0101753 (W 0.00203172) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.601776 ± 0.00162422 (W 0.00658549) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 36.9814 ± 0.0934951 (W 0.0858572) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 37.0447 ± 0.0413813 (W 0.0573912) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.866542 ± 0.00730795 (W 0.00794999) | 1.01415 ± 0.00377171 (W 0.00250458) | `lapack-openblas` 1.17 (1.174 1.166) |
| `lu/4096x256/b1` | 30.3096 ± 0.0900196 (W 0.0988635) | 46.0065 ± 6.28449 (W 0.125773) | ! p `lapack-openblas` 1.511 (1.668 1.368) |
| `qr/1024x64/b1` | 2.99695 ± 0.00334108 (W 0.0277736) | 2.23859 ± 0.0715033 (W 0.00349193) | `lapack-openblas` 0.7468 (0.730 0.764) |
| `qr/4096x256/b1` | 98.8812 ± 0.66735 (W 3.75822) | 107.096 ± 0.205422 (W 0.294604) | `lapack-openblas` 1.083 (1.087 1.079) |
| `qr_factor/1024x64/b1` | 4.69083 ± 0.00989313 (W 0.0667147) | 1.15367 ± 0.0328317 (W 0.00252224) | `lapack-openblas` 0.2459 (0.241 0.251) |
| `qr_factor/4096x256/b1` | 124.079 ± 0.796824 (W 0.597526) | 57.1644 ± 1.12657 (W 0.718857) | `lapack-openblas` 0.4607 (0.465 0.456) |
| `svd_thin/1024x64/b1` | 4.33976 ± 0.0264189 (W 0.0143021) | 3.75847 ± 0.0754914 (W 0.00545454) | `lapack-openblas` 0.866 (0.875 0.857) |
| `svd_thin/4096x256/b1` | 122.635 ± 0.0751612 (W 0.243129) | 149.219 ± 0.176901 (W 0.816772) | `lapack-openblas` 1.217 (1.215 1.218) |
| `svd_values/1024x64/b1` | 3.01559 ± 0.0260321 (W 0.0204767) | 2.09248 ± 0.011342 (W 0.00554291) | `lapack-openblas` 0.6939 (0.692 0.695) |
| `svd_values/4096x256/b1` | 75.3 ± 0.0824338 (W 0.085115) | 73.9427 ± 0.375868 (W 1.35848) | `lapack-openblas` 0.982 (0.985 0.979) |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.8506 ± 0.0247905 (W 0.0031179) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 41.7162 ± 0.0756823 (W 0.106101) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.408063 ± 0.00680095 (W 0.00371593) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.409666 ± 0.00536906 (W 0.00396616) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 18.6909 ± 0.126331 (W 1.97871) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 18.9553 ± 0.168139 (W 2.37627) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.837155 ± 0.0059899 (W 0.0153447) | 0.927472 ± 0.0110556 (W 0.00248173) | `lapack-openblas` 1.108 (1.104 1.112) |
| `lu/4096x256/b1` | 26.4429 ± 0.000874691 (W 0.0310837) | 40.7961 ± 0.380987 (W 0.0771431) | `lapack-openblas` 1.543 (1.553 1.533) |
| `qr/1024x64/b1` | 3.18469 ± 0.00701096 (W 0.0322274) | 1.95872 ± 0.00289914 (W 0.00654759) | `lapack-openblas` 0.615 (0.615 0.615) |
| `qr/4096x256/b1` | 81.7778 ± 0.207008 (W 1.01343) | 85.6792 ± 0.0463813 (W 0.413935) | `lapack-openblas` 1.048 (1.045 1.050) |
| `qr_factor/1024x64/b1` | 4.80822 ± 0.0350683 (W 0.0707118) | 0.992685 ± 0.01646 (W 0.00327316) | `lapack-openblas` 0.2064 (0.208 0.205) |
| `qr_factor/4096x256/b1` | 121.618 ± 0.705749 (W 1.22302) | 42.2684 ± 0.590578 (W 0.105798) | `lapack-openblas` 0.3475 (0.343 0.352) |
| `svd_thin/1024x64/b1` | 4.63532 ± 0.0008457 (W 0.0255303) | 3.2531 ± 0.00170342 (W 0.00570773) | `lapack-openblas` 0.7018 (0.702 0.702) |
| `svd_thin/4096x256/b1` | 105.667 ± 0.100795 (W 0.712049) | 115.097 ± 5.75422 (W 0.232728) | ! `lapack-openblas` 1.089 (1.050 1.129) |
| `svd_values/1024x64/b1` | 3.36747 ± 0.0144547 (W 0.027325) | 1.9682 ± 0.00844285 (W 0.00596855) | `lapack-openblas` 0.5845 (0.584 0.584) |
| `svd_values/4096x256/b1` | 73.7687 ± 1.40717 (W 3.37485) | 62.4658 ± 0.844254 (W 0.11074) | `lapack-openblas` 0.8468 (0.850 0.843) |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.7019 ± 0.00393293 (W 0.00398621) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 144.316 ± 0.389597 (W 1.70282) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26622 ± 0.0038707 (W 0.00232604) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.27283 ± 0.0130447 (W 0.00720899) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.84 ± 0.190298 (W 0.232889) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.872 ± 0.160325 (W 0.226418) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.927964 ± 0.00528209 (W 0.00327953) | 0.943277 ± 0.00118016 (W 0.000829239) | `lapack-openblas` 1.017 (1.013 1.020) |
| `lu/4096x256/b1` | 42.2633 ± 0.0260229 (W 0.039904) | 47.2998 ± 0.15686 (W 0.039347) | `lapack-openblas` 1.119 (1.116 1.122) |
| `qr/1024x64/b1` | 4.61174 ± 0.0058803 (W 0.00515364) | 3.54542 ± 0.00588242 (W 0.00315813) | `lapack-openblas` 0.7688 (0.769 0.769) |
| `qr/4096x256/b1` | 239.297 ± 6.5477 (W 0.385503) | 223.907 ± 0.54861 (W 0.305) | `lapack-openblas` 0.9359 (0.916 0.956) |
| `qr_factor/1024x64/b1` | 2.22948 ± 0.0479369 (W 0.00342493) | 1.81958 ± 0.000494268 (W 0.00183966) | `lapack-openblas` 0.8162 (0.829 0.804) |
| `qr_factor/4096x256/b1` | 90.2687 ± 0.0265108 (W 0.232487) | 112.483 ± 0.284247 (W 0.22547) | `lapack-openblas` 1.246 (1.249 1.244) |
| `svd_thin/1024x64/b1` | 5.88283 ± 0.00916552 (W 0.00113121) | 6.24646 ± 0.0213879 (W 0.01099) | `lapack-openblas` 1.062 (1.058 1.066) |
| `svd_thin/4096x256/b1` | 269.066 ± 0.0744173 (W 0.27852) | 355.784 ± 8.55873 (W 0.739881) | `lapack-openblas` 1.322 (1.345 1.300) |
| `svd_values/1024x64/b1` | 2.95188 ± 0.00520006 (W 0.00450799) | 2.75153 ± 0.0225871 (W 0.00767841) | `lapack-openblas` 0.9321 (0.926 0.939) |
| `svd_values/4096x256/b1` | 110.317 ± 0.403229 (W 0.0617341) | 138.403 ± 0.10276 (W 0.199411) | `lapack-openblas` 1.255 (1.251 1.259) |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.69742 ± 0.000106066 (W 0.00357052) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 51.3113 ± 1.75203 (W 0.956793) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.634782 ± 0.014029 (W 0.0017163) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.638289 ± 0.0125936 (W 0.00277904) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 39.5378 ± 0.0458792 (W 0.0373308) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 39.6144 ± 0.186259 (W 0.0590703) | - | * `lapack-openblas` - |
| `lu/1024x64/b1` | 0.760296 ± 0.00312188 (W 0.0151501) | 0.687147 ± 0.00432537 (W 0.00172781) | `lapack-openblas` 0.9038 (0.902 0.905) |
| `lu/4096x256/b1` | 18.1041 ± 0.00467751 (W 0.0638916) | 24.2372 ± 0.0179096 (W 0.0165035) | `lapack-openblas` 1.339 (1.338 1.339) |
| `qr/1024x64/b1` | 2.89522 ± 0.0101406 (W 0.0337438) | 1.45628 ± 0.00632861 (W 0.0034271) | `lapack-openblas` 0.503 (0.500 0.506) |
| `qr/4096x256/b1` | 86.3707 ± 0.0349912 (W 0.173389) | 73.3406 ± 0.167058 (W 0.140877) | `lapack-openblas` 0.8491 (0.848 0.850) |
| `qr_factor/1024x64/b1` | 2.12351 ± 0.00679317 (W 0.00948404) | 0.781531 ± 0.00180242 (W 0.00213843) | `lapack-openblas` 0.368 (0.369 0.367) |
| `qr_factor/4096x256/b1` | 44.1224 ± 0.104858 (W 3.58562) | 36.5211 ± 0.173492 (W 0.0354482) | `lapack-openblas` 0.8277 (0.829 0.826) |
| `svd_thin/1024x64/b1` | 4.23285 ± 0.0143755 (W 0.0338257) | 3.12718 ± 0.000266579 (W 0.00386103) | `lapack-openblas` 0.7388 (0.737 0.741) |
| `svd_thin/4096x256/b1` | 110.489 ± 0.00811122 (W 0.288364) | 123.444 ± 0.167683 (W 0.144196) | `lapack-openblas` 1.117 (1.116 1.118) |
| `svd_values/1024x64/b1` | 2.93116 ± 0.00278883 (W 0.0286656) | 1.73367 ± 0.0109884 (W 0.00319877) | `lapack-openblas` 0.5915 (0.589 0.594) |
| `svd_values/4096x256/b1` | 63.2947 ± 0.028425 (W 0.0636313) | 57.4288 ± 0.186803 (W 0.100256) | `lapack-openblas` 0.9073 (0.910 0.905) |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.71046 ± 0.00986343 (W 0.00139742) | - | * `lapack-openblas` - |
| `full_piv_lu/4096x256/b1` | 29.5832 ± 0.0043876 (W 0.192184) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.439651 ± 0.0034323 (W 0.00386777) | - | * `lapack-openblas` - |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.449239 ± 0.0100494 (W 0.00326712) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 21.1106 ± 0.070529 (W 0.334024) | - | * `lapack-openblas` - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 25.0254 ± 4.93638 (W 3.84417) | - | * ! `lapack-openblas` - |
| `lu/1024x64/b1` | 0.750296 ± 0.00424547 (W 0.0130482) | 0.571392 ± 0.00273297 (W 0.00245636) | `lapack-openblas` 0.7616 (0.756 0.767) |
| `lu/4096x256/b1` | 14.121 ± 0.020941 (W 0.0415195) | 14.5352 ± 0.0278508 (W 0.0233504) | `lapack-openblas` 1.029 (1.032 1.027) |
| `qr/1024x64/b1` | 3.10389 ± 0.0244107 (W 0.0183269) | 1.16867 ± 0.0022988 (W 0.00216612) | `lapack-openblas` 0.3765 (0.379 0.374) |
| `qr/4096x256/b1` | 69.5687 ± 0.0788007 (W 0.255742) | 50.9896 ± 0.63239 (W 0.33518) | `lapack-openblas` 0.7329 (0.726 0.740) |
| `qr_factor/1024x64/b1` | 2.43302 ± 0.0014531 (W 0.0318846) | 0.6367 ± 0.000703571 (W 0.00216293) | `lapack-openblas` 0.2617 (0.262 0.262) |
| `qr_factor/4096x256/b1` | 41.3824 ± 0.123466 (W 0.166743) | 24.9978 ± 0.107581 (W 0.0233064) | `lapack-openblas` 0.6041 (0.607 0.601) |
| `svd_thin/1024x64/b1` | 4.55769 ± 0.00712834 (W 0.0201564) | 2.68627 ± 0.00420587 (W 0.000964204) | `lapack-openblas` 0.5894 (0.589 0.589) |
| `svd_thin/4096x256/b1` | 93.5364 ± 0.273597 (W 3.59254) | 88.7901 ± 0.0166771 (W 0.232788) | `lapack-openblas` 0.9493 (0.951 0.947) |
| `svd_values/1024x64/b1` | 3.26914 ± 0.00348462 (W 0.0355645) | 1.59999 ± 0.018097 (W 0.00336499) | `lapack-openblas` 0.4894 (0.485 0.494) |
| `svd_values/4096x256/b1` | 61.1977 ± 0.0163921 (W 0.130552) | 45.3825 ± 0.0539466 (W 0.247019) | `lapack-openblas` 0.7416 (0.741 0.742) |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 77.1963 ± 0.0713563 (W 0.142392) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 1.23139 ± 0.0126996 (W 0.00460168) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 18.4226 ± 0.313328 (W 0.0525268) | 35.6475 ± 0.375778 (W 0.298947) | `lapack-openblas` 1.935 (1.944 1.926) |
| `lu/64x1024/b1` | 0.514472 ± 0.00457286 (W 0.00187819) | 1.14316 ± 0.154634 (W 0.00245359) | ! p `lapack-openblas` 2.212 (2.450 1.997) |
| `qr/256x4096/b1` | 32.5494 ± 0.594298 (W 0.308125) | 74.2926 ± 3.74263 (W 0.64684) | ! `lapack-openblas` 2.281 (2.334 2.230) |
| `qr/64x1024/b1` | 0.848649 ± 0.0233204 (W 0.00195739) | 1.88698 ± 0.00555927 (W 0.0209474) | `lapack-openblas` 2.224 (2.186 2.263) |
| `qr_factor/256x4096/b1` | 27.0676 ± 0.158949 (W 0.0413843) | 64.1093 ± 1.53554 (W 0.145912) | `lapack-openblas` 2.368 (2.399 2.338) |
| `qr_factor/64x1024/b1` | 0.999227 ± 0.00238578 (W 0.0047779) | 1.7252 ± 0.00372787 (W 0.0145092) | `lapack-openblas` 1.727 (1.727 1.726) |
| `svd_thin/256x4096/b1` | 83.2572 ± 0.296443 (W 0.24584) | 226.08 ± 0.818792 (W 1.12958) | `lapack-openblas` 2.715 (2.716 2.715) |
| `svd_thin/64x1024/b1` | 2.45324 ± 0.00215314 (W 0.00224816) | 4.95121 ± 0.0888536 (W 0.0104281) | `lapack-openblas` 2.018 (2.045 1.991) |
| `svd_values/256x4096/b1` | 39.1382 ± 0.182569 (W 0.240275) | 107.835 ± 1.72255 (W 0.324017) | `lapack-openblas` 2.755 (2.777 2.733) |
| `svd_values/64x1024/b1` | 1.41775 ± 0.00075024 (W 0.00199709) | 2.54443 ± 0.00824981 (W 0.196502) | `lapack-openblas` 1.795 (1.798 1.791) |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 39.9601 ± 0.630215 (W 0.438035) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 1.22966 ± 0.00563493 (W 0.0027664) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 9.34899 ± 0.131825 (W 0.0523048) | 27.2344 ± 0.764631 (W 0.170683) | `lapack-openblas` 2.913 (3.001 2.827) |
| `lu/64x1024/b1` | 0.387226 ± 0.0156384 (W 0.00812965) | 0.932373 ± 0.176876 (W 0.00241452) | ! p `lapack-openblas` 2.387 (2.655 2.146) |
| `qr/256x4096/b1` | 14.3683 ± 0.0832229 (W 0.0736153) | 43.1535 ± 0.527024 (W 0.338872) | `lapack-openblas` 3.003 (3.017 2.990) |
| `qr/64x1024/b1` | 0.772173 ± 0.00483237 (W 0.0126976) | 1.7408 ± 0.020207 (W 0.220562) | `lapack-openblas` 2.254 (2.263 2.246) |
| `qr_factor/256x4096/b1` | 12.0846 ± 0.0340917 (W 0.845178) | 39.0936 ± 0.227852 (W 0.208818) | `lapack-openblas` 3.235 (3.242 3.228) |
| `qr_factor/64x1024/b1` | 0.91274 ± 0.00749604 (W 0.00985062) | 1.55821 ± 0.0105946 (W 0.00523149) | `lapack-openblas` 1.707 (1.725 1.689) |
| `svd_thin/256x4096/b1` | 44.916 ± 0.399447 (W 0.140201) | 145.341 ± 1.16323 (W 0.753597) | `lapack-openblas` 3.236 (3.234 3.238) |
| `svd_thin/64x1024/b1` | 2.71586 ± 0.0171049 (W 0.01551) | 4.56445 ± 0.0868419 (W 0.0169097) | `lapack-openblas` 1.681 (1.711 1.651) |
| `svd_values/256x4096/b1` | 29.7727 ± 0.0621596 (W 0.110502) | 75.6567 ± 1.3751 (W 0.0701677) | `lapack-openblas` 2.541 (2.570 2.512) |
| `svd_values/64x1024/b1` | 2.02474 ± 0.014391 (W 0.0370305) | 2.45357 ± 0.0261516 (W 0.0129512) | `lapack-openblas` 1.212 (1.209 1.215) |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 34.8318 ± 0.365762 (W 0.23882) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 1.23216 ± 0.00443002 (W 0.00647573) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 8.01253 ± 0.123705 (W 0.0912715) | 24.3142 ± 0.031945 (W 0.0706681) | `lapack-openblas` 3.035 (3.071 2.999) |
| `lu/64x1024/b1` | 0.351576 ± 0.0373649 (W 0.021535) | 0.880353 ± 0.17009 (W 0.00193359) | ! p `lapack-openblas` 2.488 (3.077 2.011) |
| `qr/256x4096/b1` | 13.4256 ± 0.394268 (W 0.380715) | 38.9327 ± 0.0885213 (W 0.382665) | `lapack-openblas` 2.9 (2.966 2.836) |
| `qr/64x1024/b1` | 0.917876 ± 0.0190396 (W 0.0228378) | 1.7868 ± 0.0517008 (W 0.0287538) | `lapack-openblas` 1.946 (2.016 1.879) |
| `qr_factor/256x4096/b1` | 11.2456 ± 0.00451346 (W 0.611454) | 36.8643 ± 1.94598 (W 0.822973) | ! `lapack-openblas` 3.276 (3.157 3.400) |
| `qr_factor/64x1024/b1` | 1.0876 ± 0.0112982 (W 0.0287476) | 1.59704 ± 0.0492585 (W 0.00558303) | `lapack-openblas` 1.468 (1.512 1.426) |
| `svd_thin/256x4096/b1` | 44.7231 ± 0.646258 (W 0.646743) | 135.033 ± 4.9781 (W 0.398404) | ! `lapack-openblas` 3.018 (2.971 3.067) |
| `svd_thin/64x1024/b1` | 3.09424 ± 0.0173991 (W 0.0328437) | 4.49175 ± 0.0645504 (W 0.0118034) | `lapack-openblas` 1.452 (1.443 1.461) |
| `svd_values/256x4096/b1` | 31.988 ± 0.127444 (W 2.77818) | 72.2956 ± 0.579738 (W 0.746947) | `lapack-openblas` 2.26 (2.241 2.279) |
| `svd_values/64x1024/b1` | 2.36439 ± 0.0660155 (W 0.0333786) | 2.46575 ± 0.0407279 (W 0.0306977) | `lapack-openblas` 1.043 (1.011 1.076) |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 71.1657 ± 0.887778 (W 0.426768) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 1.02467 ± 0.0159368 (W 0.00528641) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 13.3174 ± 0.0130751 (W 0.223394) | 20.4641 ± 0.00557554 (W 0.100801) | `lapack-openblas` 1.537 (1.536 1.537) |
| `lu/64x1024/b1` | 0.311523 ± 0.00264599 (W 0.00190886) | 0.709704 ± 0.000678115 (W 0.00290991) | `lapack-openblas` 2.278 (2.263 2.293) |
| `qr/256x4096/b1` | 27.8473 ± 0.0440662 (W 0.110568) | 74.4976 ± 1.8343 (W 0.54833) | `lapack-openblas` 2.675 (2.719 2.632) |
| `qr/64x1024/b1` | 0.630961 ± 0.00337856 (W 0.00270993) | 1.6532 ± 0.0638588 (W 0.00841223) | ! `lapack-openblas` 2.619 (2.539 2.702) |
| `qr_factor/256x4096/b1` | 25.1335 ± 0.123338 (W 0.0653126) | 53.9066 ± 2.08327 (W 0.553476) | ! `lapack-openblas` 2.144 (2.196 2.093) |
| `qr_factor/64x1024/b1` | 0.563177 ± 0.00113279 (W 0.00251698) | 1.37877 ± 0.000692258 (W 0.0044433) | `lapack-openblas` 2.448 (2.453 2.444) |
| `svd_thin/256x4096/b1` | 88.5561 ± 0.408156 (W 0.112849) | 200.712 ± 4.99584 (W 0.596364) | `lapack-openblas` 2.266 (2.299 2.234) |
| `svd_thin/64x1024/b1` | 2.52232 ± 0.0103421 (W 0.0063924) | 4.535 ± 0.03666 (W 0.0127354) | `lapack-openblas` 1.798 (1.813 1.783) |
| `svd_values/256x4096/b1` | 44.9274 ± 0.205887 (W 0.0466109) | 93.1637 ± 3.76206 (W 0.258463) | ! `lapack-openblas` 2.073 (2.126 2.021) |
| `svd_values/64x1024/b1` | 1.48178 ± 0.00962514 (W 0.0029135) | 2.20119 ± 0.0338704 (W 0.00765952) | `lapack-openblas` 1.485 (1.463 1.509) |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 35.2189 ± 0.0705169 (W 0.323529) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 1.03007 ± 0.00219415 (W 0.00682479) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 4.68186 ± 0.0245585 (W 0.0881749) | 12.3834 ± 0.332331 (W 0.00963425) | `lapack-openblas` 2.645 (2.685 2.604) |
| `lu/64x1024/b1` | 0.164637 ± 0.00584424 (W 0.00646208) | 0.495895 ± 0.000630739 (W 0.00257946) | ! `lapack-openblas` 3.013 (3.087 2.941) |
| `qr/256x4096/b1` | 9.5203 ± 0.0308482 (W 0.0616083) | 43.6264 ± 1.68494 (W 0.221576) | ! `lapack-openblas` 4.581 (4.697 4.468) |
| `qr/64x1024/b1` | 0.566005 ± 0.00179676 (W 0.00663254) | 1.46936 ± 0.0106101 (W 0.0169081) | `lapack-openblas` 2.596 (2.577 2.615) |
| `qr_factor/256x4096/b1` | 8.4439 ± 0.0455066 (W 0.0316095) | 29.0846 ± 0.281498 (W 0.303352) | `lapack-openblas` 3.444 (3.434 3.455) |
| `qr_factor/64x1024/b1` | 0.491182 ± 0.00461741 (W 0.00666031) | 1.23617 ± 0.0019601 (W 0.00349188) | `lapack-openblas` 2.517 (2.503 2.531) |
| `svd_thin/256x4096/b1` | 50.6849 ± 0.241716 (W 0.105411) | 126.544 ± 2.44453 (W 0.58991) | `lapack-openblas` 2.496 (2.522 2.471) |
| `svd_thin/64x1024/b1` | 2.77807 ± 0.00304622 (W 0.0209179) | 4.08126 ± 0.0814453 (W 0.012213) | `lapack-openblas` 1.469 (1.449 1.489) |
| `svd_values/256x4096/b1` | 35.475 ± 0.172901 (W 0.162515) | 65.1364 ± 0.599537 (W 0.303122) | `lapack-openblas` 1.836 (1.842 1.830) |
| `svd_values/64x1024/b1` | 2.08407 ± 0.00852347 (W 0.0211297) | 2.12724 ± 0.00651952 (W 0.00540678) | `lapack-openblas` 1.021 (1.016 1.026) |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.0902 ± 0.173023 (W 0.159687) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 1.02786 ± 0.00472277 (W 0.00402877) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 3.32386 ± 0.10711 (W 0.0832187) | 10.3991 ± 0.148513 (W 0.0222287) | `lapack-openblas` 3.129 (3.234 3.028) |
| `lu/64x1024/b1` | 0.153633 ± 0.00274499 (W 0.00419445) | 0.452289 ± 0.00148987 (W 0.00207409) | `lapack-openblas` 2.944 (2.900 2.989) |
| `qr/256x4096/b1` | 8.58276 ± 0.134417 (W 0.289662) | 39.3807 ± 1.17401 (W 0.234284) | `lapack-openblas` 4.588 (4.442 4.738) |
| `qr/64x1024/b1` | 0.714778 ± 0.00791465 (W 0.0201662) | 1.47643 ± 0.00733199 (W 0.0259374) | `lapack-openblas` 2.066 (2.042 2.089) |
| `qr_factor/256x4096/b1` | 7.415 ± 0.06381 (W 0.275173) | 25.2465 ± 0.0443865 (W 0.113202) | `lapack-openblas` 3.405 (3.388 3.421) |
| `qr_factor/64x1024/b1` | 0.648073 ± 0.0150564 (W 0.0186761) | 1.25245 ± 0.00479701 (W 0.00537865) | `lapack-openblas` 1.933 (1.960 1.906) |
| `svd_thin/256x4096/b1` | 50.3385 ± 0.104254 (W 0.390504) | 118.742 ± 2.11799 (W 0.508942) | `lapack-openblas` 2.359 (2.326 2.392) |
| `svd_thin/64x1024/b1` | 3.16721 ± 0.0310894 (W 0.0353717) | 4.04036 ± 0.0332001 (W 0.0116908) | `lapack-openblas` 1.276 (1.260 1.292) |
| `svd_values/256x4096/b1` | 38.023 ± 0.778186 (W 0.80996) | 62.6332 ± 2.61735 (W 0.128635) | ! `lapack-openblas` 1.647 (1.576 1.721) |
| `svd_values/64x1024/b1` | 2.47061 ± 0.00971989 (W 0.0312991) | 2.16744 ± 0.0621292 (W 0.0736788) | `lapack-openblas` 0.8771 (0.862 0.893) |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 231.14 ± 9.1263 (W 1.19711) | - | * ! `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 2.52641 ± 0.0353631 (W 0.00999898) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 46.959 ± 0.0402676 (W 0.0601197) | 82.7178 ± 0.298394 (W 0.0496541) | `lapack-openblas` 1.761 (1.756 1.767) |
| `lu/64x1024/b1` | 1.05451 ± 0.00545674 (W 0.00393452) | 1.66118 ± 0.00808718 (W 0.00285132) | `lapack-openblas` 1.575 (1.575 1.576) |
| `qr/256x4096/b1` | 107.783 ± 0.570404 (W 0.301753) | 184.496 ± 5.25481 (W 1.27395) | `lapack-openblas` 1.711 (1.740 1.684) |
| `qr/64x1024/b1` | 2.6225 ± 0.00495328 (W 0.00245013) | 3.68339 ± 0.0178311 (W 0.00640643) | `lapack-openblas` 1.405 (1.407 1.402) |
| `qr_factor/256x4096/b1` | 96.6292 ± 0.0163773 (W 0.251242) | 166.187 ± 3.47318 (W 0.982545) | `lapack-openblas` 1.72 (1.745 1.695) |
| `qr_factor/64x1024/b1` | 2.56884 ± 0.0083573 (W 0.00854241) | 3.41493 ± 0.0328727 (W 0.00514866) | `lapack-openblas` 1.329 (1.323 1.335) |
| `svd_thin/256x4096/b1` | 269.801 ± 0.441171 (W 3.14951) | 687.693 ± 16.5043 (W 3.88846) | `lapack-openblas` 2.549 (2.589 2.509) |
| `svd_thin/64x1024/b1` | 5.91287 ± 0.0262768 (W 0.00367013) | 11.7705 ± 0.264808 (W 0.0172874) | `lapack-openblas` 1.99 (2.029 1.953) |
| `svd_values/256x4096/b1` | 110.248 ± 0.215671 (W 0.31665) | 308.386 ± 2.43167 (W 1.94353) | `lapack-openblas` 2.797 (2.778 2.817) |
| `svd_values/64x1024/b1` | 2.93521 ± 0.00683984 (W 0.0112227) | 5.5636 ± 0.0281089 (W 0.0119142) | `lapack-openblas` 1.895 (1.886 1.905) |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 95.5399 ± 3.62624 (W 0.521718) | - | * ! `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 2.54491 ± 0.0217944 (W 0.00996158) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 18.1699 ± 0.285607 (W 0.218762) | 52.2236 ± 6.35315 (W 0.411716) | ! p `lapack-openblas` 2.864 (3.087 2.656) |
| `lu/64x1024/b1` | 0.492466 ± 0.00406374 (W 0.00572833) | 1.1979 ± 0.0164233 (W 0.00251308) | `lapack-openblas` 2.432 (2.395 2.470) |
| `qr/256x4096/b1` | 34.8882 ± 0.0477085 (W 0.150938) | 81.7093 ± 1.73626 (W 1.31459) | `lapack-openblas` 2.342 (2.309 2.375) |
| `qr/64x1024/b1` | 1.30304 ± 0.00174019 (W 0.0131427) | 1.67619 ± 0.00682499 (W 0.00523732) | `lapack-openblas` 1.286 (1.291 1.281) |
| `qr_factor/256x4096/b1` | 29.6966 ± 0.0596855 (W 0.636486) | 73.2855 ± 0.865936 (W 0.897785) | `lapack-openblas` 2.468 (2.451 2.485) |
| `qr_factor/64x1024/b1` | 1.30845 ± 0.0104454 (W 0.0167963) | 1.38363 ± 0.0319527 (W 0.00357774) | `lapack-openblas` 1.057 (1.081 1.034) |
| `svd_thin/256x4096/b1` | 111.401 ± 0.0219083 (W 0.142303) | 439.885 ± 5.69649 (W 2.34664) | `lapack-openblas` 3.949 (3.984 3.913) |
| `svd_thin/64x1024/b1` | 4.2692 ± 0.0122117 (W 0.0351986) | 9.94113 ± 0.0938041 (W 0.032947) | `lapack-openblas` 2.329 (2.349 2.308) |
| `svd_values/256x4096/b1` | 63.4927 ± 0.00329582 (W 0.114182) | 215.71 ± 1.18903 (W 0.342319) | `lapack-openblas` 3.397 (3.384 3.411) |
| `svd_values/64x1024/b1` | 2.91279 ± 0.0399381 (W 0.0175601) | 4.97943 ± 0.0706407 (W 0.0108661) | `lapack-openblas` 1.709 (1.676 1.744) |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 69.8265 ± 1.08345 (W 0.684913) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 2.55854 ± 0.0254467 (W 0.00773399) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 12.5539 ± 0.0638694 (W 0.0446338) | 45.2884 ± 6.06733 (W 0.0661288) | ! p `lapack-openblas` 3.591 (3.254 3.964) |
| `lu/64x1024/b1` | 0.404732 ± 0.00177837 (W 0.00475088) | 1.04104 ± 0.0381604 (W 0.00147555) | ! `lapack-openblas` 2.571 (2.498 2.647) |
| `qr/256x4096/b1` | 25.3129 ± 0.0375205 (W 0.498265) | 62.088 ± 1.25752 (W 0.564622) | `lapack-openblas` 2.453 (2.420 2.485) |
| `qr/64x1024/b1` | 1.37089 ± 0.0239851 (W 0.0277151) | 1.37197 ± 0.0321889 (W 0.00583434) | `lapack-openblas` 1.001 (0.997 1.005) |
| `qr_factor/256x4096/b1` | 21.0755 ± 0.160867 (W 0.692659) | 55.3009 ± 1.18529 (W 0.297639) | `lapack-openblas` 2.624 (2.598 2.649) |
| `qr_factor/64x1024/b1` | 1.3769 ± 0.0134711 (W 0.0174832) | 1.10182 ± 0.0388513 (W 0.0034323) | `lapack-openblas` 0.8 (0.786 0.815) |
| `svd_thin/256x4096/b1` | 94.1664 ± 0.56029 (W 0.613006) | 387.402 ± 0.858849 (W 1.73579) | `lapack-openblas` 4.114 (4.103 4.125) |
| `svd_thin/64x1024/b1` | 4.588 ± 0.0165611 (W 0.0203844) | 9.7182 ± 0.191276 (W 0.0456145) | `lapack-openblas` 2.118 (2.094 2.142) |
| `svd_values/256x4096/b1` | 61.2946 ± 0.125593 (W 0.154979) | 201.746 ± 1.48075 (W 0.846576) | `lapack-openblas` 3.291 (3.270 3.313) |
| `svd_values/64x1024/b1` | 3.27163 ± 0.0517708 (W 0.0329812) | 5.09195 ± 0.0213681 (W 0.0155561) | `lapack-openblas` 1.556 (1.579 1.535) |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 225.455 ± 8.75409 (W 1.0123) | - | * ! `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 2.29348 ± 0.0297579 (W 0.0128849) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 42.2218 ± 0.105164 (W 0.0553397) | 58.0775 ± 2.87308 (W 2.22255) | ! `lapack-openblas` 1.375 (1.325 1.426) |
| `lu/64x1024/b1` | 0.897415 ± 0.000118794 (W 0.00388217) | 1.27303 ± 0.011779 (W 0.000833973) | `lapack-openblas` 1.419 (1.409 1.428) |
| `qr/256x4096/b1` | 103.457 ± 0.580156 (W 0.23379) | 185.553 ± 0.578302 (W 1.03685) | `lapack-openblas` 1.794 (1.790 1.797) |
| `qr/64x1024/b1` | 2.41186 ± 0.00897177 (W 0.00652552) | 3.8066 ± 0.0496467 (W 0.016444) | `lapack-openblas` 1.578 (1.568 1.589) |
| `qr_factor/256x4096/b1` | 96.7204 ± 1.49705 (W 4.83616) | 147.701 ± 3.77564 (W 1.54476) | `lapack-openblas` 1.527 (1.572 1.483) |
| `qr_factor/64x1024/b1` | 2.21936 ± 0.0149228 (W 0.00249479) | 2.97188 ± 0.0119345 (W 0.00349915) | `lapack-openblas` 1.339 (1.337 1.342) |
| `svd_thin/256x4096/b1` | 282.234 ± 0.263961 (W 3.95637) | 652.829 ± 5.87224 (W 1.60388) | `lapack-openblas` 2.313 (2.329 2.297) |
| `svd_thin/64x1024/b1` | 6.05521 ± 0.0541891 (W 0.015433) | 11.3999 ± 0.0390217 (W 0.0228854) | `lapack-openblas` 1.883 (1.899 1.866) |
| `svd_values/256x4096/b1` | 123.051 ± 1.11938 (W 0.413375) | 286.51 ± 2.70766 (W 1.53957) | `lapack-openblas` 2.328 (2.329 2.328) |
| `svd_values/64x1024/b1` | 3.08451 ± 0.0214685 (W 0.00170716) | 5.28578 ± 0.0620875 (W 0.0162553) | `lapack-openblas` 1.714 (1.708 1.719) |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 90.8965 ± 3.57603 (W 0.628652) | - | * ! `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 2.29379 ± 0.0160266 (W 0.00868197) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 13.8764 ± 0.011844 (W 0.0624005) | 30.5107 ± 0.0473231 (W 0.227792) | `lapack-openblas` 2.199 (2.195 2.202) |
| `lu/64x1024/b1` | 0.324572 ± 0.000491439 (W 0.00363779) | 0.80254 ± 0.00577989 (W 0.0023565) | `lapack-openblas` 2.473 (2.463 2.483) |
| `qr/256x4096/b1` | 29.9881 ± 0.0838798 (W 0.0595346) | 73.1921 ± 0.237943 (W 0.32908) | `lapack-openblas` 2.441 (2.430 2.451) |
| `qr/64x1024/b1` | 1.13464 ± 0.0175999 (W 0.00644778) | 1.60214 ± 0.344396 (W 0.00692011) | ! p `lapack-openblas` 1.396 (1.184 1.645) |
| `qr_factor/256x4096/b1` | 27.142 ± 0.366788 (W 0.0301799) | 53.9715 ± 1.45346 (W 0.143283) | `lapack-openblas` 1.988 (1.932 2.046) |
| `qr_factor/64x1024/b1` | 0.96838 ± 0.00638447 (W 0.00551652) | 1.01871 ± 0.0180185 (W 0.00180739) | `lapack-openblas` 1.052 (1.044 1.060) |
| `svd_thin/256x4096/b1` | 123.591 ± 0.00939603 (W 0.19995) | 397.076 ± 1.48534 (W 0.480055) | `lapack-openblas` 3.213 (3.204 3.221) |
| `svd_thin/64x1024/b1` | 4.40151 ± 0.0271211 (W 0.0200183) | 9.17864 ± 0.0103421 (W 0.0168949) | `lapack-openblas` 2.085 (2.075 2.096) |
| `svd_values/256x4096/b1` | 76.4888 ± 1.58693 (W 1.19651) | 199.181 ± 0.487639 (W 0.218748) | `lapack-openblas` 2.604 (2.647 2.562) |
| `svd_values/64x1024/b1` | 3.03764 ± 0.0074324 (W 0.0254538) | 4.61829 ± 0.00977787 (W 0.00998019) | `lapack-openblas` 1.52 (1.520 1.521) |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs faer-fork |
|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 66.2599 ± 0.218454 (W 0.447405) | - | * `lapack-openblas` - |
| `full_piv_lu/64x1024/b1` | 2.2954 ± 0.026327 (W 0.0113648) | - | * `lapack-openblas` - |
| `lu/256x4096/b1` | 8.42288 ± 0.0825073 (W 0.0296664) | 23.6904 ± 0.0100006 (W 0.0298818) | `lapack-openblas` 2.813 (2.831 2.794) |
| `lu/64x1024/b1` | 0.241099 ± 0.00187454 (W 0.00321269) | 0.672055 ± 0.0018109 (W 0.0013875) | `lapack-openblas` 2.787 (2.808 2.767) |
| `qr/256x4096/b1` | 20.7075 ± 0.459008 (W 0.755985) | 56.9811 ± 0.427829 (W 0.201936) | `lapack-openblas` 2.752 (2.695 2.810) |
| `qr/64x1024/b1` | 1.19693 ± 0.0161199 (W 0.0279285) | 1.1572 ± 0.0919656 (W 0.0236421) | ! p `lapack-openblas` 0.9653 (0.904 1.031) |
| `qr_factor/256x4096/b1` | 18.0408 ± 0.0556373 (W 0.881601) | 38.1017 ± 0.192339 (W 0.0511515) | `lapack-openblas` 2.112 (2.100 2.124) |
| `qr_factor/64x1024/b1` | 1.00233 ± 0.0070647 (W 0.0163188) | 0.724547 ± 0.00737512 (W 0.00476676) | `lapack-openblas` 0.7228 (0.732 0.714) |
| `svd_thin/256x4096/b1` | 106.276 ± 0.146128 (W 0.215076) | 355.222 ± 2.16421 (W 0.397255) | `lapack-openblas` 3.342 (3.354 3.331) |
| `svd_thin/64x1024/b1` | 4.72473 ± 0.0419427 (W 0.0329738) | 9.05369 ± 0.0971091 (W 0.0145743) | `lapack-openblas` 1.916 (1.914 1.919) |
| `svd_values/256x4096/b1` | 72.8292 ± 0.0669262 (W 0.26263) | 184.192 ± 0.243651 (W 0.321389) | `lapack-openblas` 2.529 (2.530 2.528) |
| `svd_values/64x1024/b1` | 3.35343 ± 0.0608331 (W 0.0368853) | 4.71512 ± 0.0309324 (W 0.00832932) | `lapack-openblas` 1.406 (1.418 1.395) |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
