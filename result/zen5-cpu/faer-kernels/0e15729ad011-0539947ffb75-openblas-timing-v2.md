<!-- generated from data/results/zen5-cpu/faer-kernels/20261027T015921Z-pub-0e15729a-20261026-openblas/report.md by scripts/publish_report.py; the report below is the source of truth -->

# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `0e15729ad011e3813a41c168167ec61ed11a9dbb`
- t4a-faer version: `0.25.0`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above)
- harness commit: `fc1269a75a30c71d7001113b6cfa65e42fbf2b6d`
- toolkit commit: `467573e6e3e405b8ec30b3b61d096c1d0c9893c3`
- measured binary SHA-256: `7ac56d5ab52238845d866f7e8406ddcf2fcfa47d1c12ca23e06ad6be1183bbd6`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-27T04:37:44.357994Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --vendor openblas --engines faer-fork,lapack-openblas --threads 1,4,8 --dtypes f64,c64 --reps 5 --aa 6 --prime-ms 250 --label pub-0e15729a-20261026-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels/20261027T015921Z-pub-0e15729a-20261026-openblas/`

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
Each process retains 5 chronological calls; 6 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 1.15%, worst 335.18% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 180 of 2328 engine cells exceed 5% and carry `!`; median within-process relative SD 0.32%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002349 ± 1.26491e-05 (W 1.65439e-05) | 0.002234 ± 5.16398e-06 (W 1.68413e-05) | 🔴 faer-fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017127 ± 3.74166e-05 (W 1.68322e-05) | 0.016841 ± 1.85544e-05 (W 1.74064e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.056746 ± 3.99521e-05 (W 3.33976e-05) | 0.0562745 ± 7.27617e-05 (W 5.20868e-05) | · |  |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023745 ± 1.19833e-05 (W 2.05893e-05) | 0.002224 ± 1.23356e-05 (W 1.52745e-05) | 🔴 faer-fork 1.07× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.012042 ± 0.000177782 (W 0.000333211) | 0.016826 ± 2.13698e-05 (W 1.68345e-05) | 🔵 faer-fork 1.40× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.023699 ± 0.000198142 (W 0.000594295) | 0.0563005 ± 7.67865e-05 (W 2.82303e-05) | 🔵 faer-fork 2.38× faster than `lapack-openblas` |  |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023695 ± 1.59677e-05 (W 1.72978e-05) | 0.002219 ± 1.26491e-05 (W 1.85404e-05) | 🔴 faer-fork 1.07× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0110805 ± 0.000142179 (W 0.000184917) | 0.0168215 ± 2.45825e-05 (W 1.77866e-05) | 🔵 faer-fork 1.52× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0216155 ± 0.000161438 (W 0.000206175) | 0.0562745 ± 5.79669e-05 (W 4.81307e-05) | 🔵 faer-fork 2.60× faster than `lapack-openblas` |  |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0023395 ± 7.84857e-06 (W 1.83655e-05) | 0.002229 ± 1.36626e-05 (W 1.65255e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.017132 ± 4.32435e-05 (W 2.82921e-05) | 0.016842 ± 2.56255e-05 (W 1.78603e-05) | · | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.0567705 ± 3.79337e-05 (W 6.15459e-05) | 0.056295 ± 3.85249e-05 (W 0.000512004) | · |  |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002375 ± 1.61121e-05 (W 1.6047e-05) | 0.002209 ± 1.64317e-05 (W 1.65255e-05) | 🔴 faer-fork 1.08× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.012263 ± 0.000253432 (W 0.000314254) | 0.0168415 ± 2.15167e-05 (W 3.20257e-05) | 🔵 faer-fork 1.37× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.02426 ± 0.000244487 (W 0.000406942) | 0.05626 ± 4.8129e-05 (W 0.000561536) | 🔵 faer-fork 2.32× faster than `lapack-openblas` |  |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.002374 ± 1.46617e-05 (W 1.55241e-05) | 0.0021945 ± 1.31719e-05 (W 1.14578e-05) | 🔴 faer-fork 1.08× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0109855 ± 0.000165621 (W 0.000302975) | 0.016836 ± 1.17884e-05 (W 2.19196e-05) | 🔵 faer-fork 1.53× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/96x96x96/b1` | 0.02141 ± 7.88765e-05 (W 0.000218005) | 0.0563295 ± 6.01578e-05 (W 0.000485815) | 🔵 faer-fork 2.63× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088565 ± 4.90323e-05 (W 1.81865e-05) | 0.0115915 ± 2.75735e-05 (W 2.81376e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.067721 ± 0.000139522 (W 0.000561098) | 0.0859 ± 7.17152e-05 (W 0.00107647) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.226813 ± 0.000267969 (W 0.0012739) | 0.276371 ± 0.000428152 (W 0.00126053) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008851 ± 1.16175e-05 (W 2.25927e-05) | 0.011597 ± 1.82282e-05 (W 3.8793e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.029645 ± 0.000163146 (W 0.00018915) | 0.0262035 ± 0.000166608 (W 0.000195873) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.0795385 ± 0.000315922 (W 0.00044852) | 0.079122 ± 0.000423949 (W 0.000390835) | · |  |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088865 ± 3.36987e-05 (W 2.05938e-05) | 0.0116215 ± 4.68078e-05 (W 2.28925e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.027887 ± 0.000154351 (W 0.000257911) | 0.0255675 ± 0.000508056 (W 0.000159642) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.040686 ± 0.000157417 (W 0.000217646) | 0.0549725 ± 0.000603519 (W 0.000214429) | 🔵 faer-fork 1.35× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008856 ± 5.47993e-05 (W 2.11304e-05) | 0.0115715 ± 2.56184e-05 (W 2.63005e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0677415 ± 7.22791e-05 (W 3.84844e-05) | 0.0859805 ± 0.000125955 (W 0.00122937) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.226643 ± 0.000108199 (W 0.00108727) | 0.276375 ± 0.000398697 (W 0.00149055) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.008837 ± 1.40095e-05 (W 1.886e-05) | 0.0116115 ± 3.06638e-05 (W 4.05369e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.0297805 ± 0.000141054 (W 0.000183638) | 0.0261685 ± 7.61201e-05 (W 0.000251975) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `gemm/96x96x96/b1` | 0.079683 ± 0.000265165 (W 0.000307981) | 0.0791625 ± 0.000261754 (W 0.000552646) | · |  |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/32x32x32/b1` | 0.0088765 ± 4.29682e-05 (W 1.77231e-05) | 0.011592 ± 2.15445e-05 (W 2.754e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `gemm/64x64x64/b1` | 0.027782 ± 0.00015048 (W 0.000197026) | 0.025858 ± 0.000561506 (W 0.000211941) | 🔴 faer-fork 1.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/96x96x96/b1` | 0.040776 ± 0.000100454 (W 0.000224133) | 0.055038 ± 0.000527935 (W 0.000296518) | 🔵 faer-fork 1.35× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133694 ± 0.000573761 (W 8.48586e-05) | 0.162523 ± 0.000406204 (W 0.00124528) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.45213 ± 0.000923698 (W 0.00189895) | 0.53841 ± 0.000412166 (W 0.00212295) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07556 ± 0.00246123 (W 0.000682872) | 1.26463 ± 0.00504243 (W 0.00181663) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.60718 ± 0.00352877 (W 0.00340357) | 4.22033 ± 0.0140443 (W 0.00322929) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.59049 ± 0.00658139 (W 0.00710658) | 10.0524 ± 0.0138914 (W 0.00960795) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.3954 ± 0.0584656 (W 0.0253039) | 33.6828 ± 0.123824 (W 0.0316326) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0464415 ± 0.000319984 (W 0.000396132) | 0.049593 ± 0.000928394 (W 0.000428558) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.120679 ± 0.000571533 (W 0.00171917) | 0.148948 ± 0.00118294 (W 0.00144045) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.291023 ± 0.000678281 (W 0.00155047) | 0.343512 ± 0.000924341 (W 0.00201444) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.916127 ± 0.0020143 (W 0.00245421) | 1.10209 ± 0.00345481 (W 0.00331291) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.21132 ± 0.00264146 (W 0.00308711) | 2.58823 ± 0.0048704 (W 0.00446815) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.52029 ± 0.0125992 (W 0.00746349) | 8.7094 ± 0.00481595 (W 0.0310137) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.0344195 ± 0.000794694 (W 0.0012634) | 0.0296055 ± 0.000267557 (W 0.000612512) | 🔴 faer-fork 1.16× slower than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.087403 ± 0.000940379 (W 0.000798967) | 0.084037 ± 0.000344363 (W 0.000671342) | · |  |
| `gemm/256x256x256/b1` | 0.166822 ± 0.000983724 (W 0.00177605) | 0.182857 ± 0.000851868 (W 0.00117085) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.48065 ± 0.00167809 (W 0.00211435) | 0.556609 ± 0.00164066 (W 0.00251367) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 1.14143 ± 0.00521941 (W 0.00301585) | 1.32184 ± 0.00488562 (W 0.00211398) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.90431 ± 0.00322714 (W 0.00940627) | 4.55107 ± 0.0118648 (W 0.00871669) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.133749 ± 0.000660538 (W 0.00093109) | 0.162782 ± 0.00040588 (W 0.00102759) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.452599 ± 0.00182709 (W 0.00187143) | 0.53779 ± 0.000865035 (W 0.00153338) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.07561 ± 0.00119727 (W 0.00111544) | 1.26592 ± 0.00284339 (W 0.00238934) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.60082 ± 0.00625454 (W 0.00270737) | 4.22215 ± 0.00755734 (W 0.00524857) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.5672 ± 0.0240229 (W 0.00494609) | 10.0525 ± 0.0169138 (W 0.01119) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.3453 ± 0.0276515 (W 0.0266948) | 33.6755 ± 0.0595815 (W 0.0226727) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.046116 ± 0.000180378 (W 0.000282533) | 0.050925 ± 0.00102675 (W 0.00117614) | 🔵 faer-fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/192x192x192/b1` | 0.121783 ± 0.00135939 (W 0.00156444) | 0.14975 ± 0.000632498 (W 0.00181913) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.291787 ± 0.000511635 (W 0.00170727) | 0.3434 ± 0.00118909 (W 0.00223922) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.916412 ± 0.00134752 (W 0.00310771) | 1.10158 ± 0.00447049 (W 0.0033298) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 2.20786 ± 0.00269534 (W 0.00381152) | 2.58934 ± 0.00490915 (W 0.0042326) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 7.52747 ± 0.016954 (W 0.00947297) | 8.7061 ± 0.0135474 (W 0.0233716) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.033933 ± 0.000567009 (W 0.00141096) | 0.0301215 ± 0.000546408 (W 0.000570983) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.088265 ± 0.000986869 (W 0.00132872) | 0.084467 ± 0.000701781 (W 0.000992785) | · |  |
| `gemm/256x256x256/b1` | 0.166555 ± 0.000482856 (W 0.00146655) | 0.184439 ± 0.00129104 (W 0.00163363) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 0.478692 ± 0.000923153 (W 0.0031396) | 0.556902 ± 0.00414161 (W 0.00222277) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 1.14255 ± 0.00266919 (W 0.00310601) | 1.32122 ± 0.00389045 (W 0.00277313) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 3.92661 ± 0.00929153 (W 0.00986628) | 4.5432 ± 0.0081394 (W 0.0115766) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.53991 ± 0.00265649 (W 0.00201308) | 0.658247 ± 0.000436998 (W 0.00203723) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81184 ± 0.00828139 (W 0.00191509) | 2.17524 ± 0.00159583 (W 0.0017775) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28327 ± 0.00397534 (W 0.00291833) | 5.16429 ± 0.0186401 (W 0.00387377) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4193 ± 0.0149803 (W 0.00864008) | 17.2898 ± 0.0157178 (W 0.0122523) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.27 ± 0.0649452 (W 0.0238532) | 40.9736 ± 0.0663846 (W 0.0276284) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.401 ± 0.200507 (W 0.0591006) | 137.438 ± 0.202808 (W 0.0445248) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.154558 ± 0.000624609 (W 0.00047244) | 0.17776 ± 0.000732725 (W 0.00157594) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.458852 ± 0.00141624 (W 0.00140894) | 0.56125 ± 0.00177975 (W 0.00183013) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.11307 ± 0.00107358 (W 0.00193379) | 1.33495 ± 0.00384927 (W 0.00248887) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.63578 ± 0.00857093 (W 0.00344084) | 4.40253 ± 0.00424807 (W 0.00595407) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.66348 ± 0.0109873 (W 0.00880036) | 10.4522 ± 0.0195463 (W 0.00523374) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.415 ± 0.0543377 (W 0.0231907) | 34.902 ± 0.037665 (W 0.0183782) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.103854 ± 0.000746964 (W 0.000712891) | 0.094467 ± 0.000321122 (W 0.000918945) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.237482 ± 0.00101438 (W 0.00163866) | 0.297828 ± 0.00138126 (W 0.00113333) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.582906 ± 0.00135169 (W 0.00172084) | 0.683577 ± 0.00391907 (W 0.00191769) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.83487 ± 0.0033869 (W 0.00452796) | 2.20162 ± 0.0036312 (W 0.00402231) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.44644 ± 0.00479219 (W 0.00945457) | 5.26667 ± 0.00952939 (W 0.00845878) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 14.9704 ± 0.0299627 (W 0.0132304) | 17.7499 ± 0.027901 (W 0.0199182) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.539665 ± 0.00125994 (W 0.00180345) | 0.658959 ± 0.000578627 (W 0.00183608) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 1.81016 ± 0.0079157 (W 0.00232738) | 2.17595 ± 0.00184623 (W 0.00200591) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 4.28218 ± 0.00444962 (W 0.00177095) | 5.17113 ± 0.00515231 (W 0.0035404) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 14.4226 ± 0.0175289 (W 0.00638196) | 17.2857 ± 0.0148805 (W 0.00859971) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 34.2818 ± 0.0322832 (W 0.0164701) | 40.9543 ± 0.0706234 (W 0.0185524) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 116.219 ± 0.255368 (W 0.233615) | 137.439 ± 0.165661 (W 0.0876941) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.154589 ± 0.000319356 (W 0.000389361) | 0.178007 ± 0.000612855 (W 0.00132008) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.458539 ± 0.00225011 (W 0.0017125) | 0.561612 ± 0.00142452 (W 0.0020413) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 1.11215 ± 0.00179705 (W 0.00107783) | 1.33274 ± 0.00432757 (W 0.00239319) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 3.63213 ± 0.00327494 (W 0.0029139) | 4.39892 ± 0.00434549 (W 0.00578627) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 8.64874 ± 0.00329294 (W 0.00828914) | 10.4577 ± 0.0139044 (W 0.0102448) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 29.4248 ± 0.0487489 (W 0.0174867) | 34.8908 ± 0.0285693 (W 0.0413647) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |

## gemm-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/128x128x128/b1` | 0.104595 ± 0.000502909 (W 0.000520151) | 0.0943615 ± 0.000509801 (W 0.000504343) | 🔴 faer-fork 1.11× slower than `lapack-openblas` |  |
| `gemm/192x192x192/b1` | 0.236696 ± 0.000422197 (W 0.00155737) | 0.297374 ± 0.0013824 (W 0.00126113) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `gemm/256x256x256/b1` | 0.58278 ± 0.00115375 (W 0.00213565) | 0.686581 ± 0.0036898 (W 0.00160098) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/384x384x384/b1` | 1.83445 ± 0.00360038 (W 0.00346843) | 2.20355 ± 0.00215899 (W 0.00312546) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `gemm/512x512x512/b1` | 4.45196 ± 0.00172696 (W 0.00593959) | 5.25777 ± 0.0067651 (W 0.00844886) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `gemm/768x768x768/b1` | 15.015 ± 0.0131083 (W 0.0210027) | 17.7544 ± 0.0226235 (W 0.0146853) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.25418 ± 0.0147115 (W 0.00375733) | 1.64072 ± 0.022482 (W 0.00307087) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.07661 ± 0.00359904 (W 0.00101815) | 1.4432 ± 0.0040292 (W 0.00924334) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.08376 ± 0.00966796 (W 0.00137228) | 1.36492 ± 0.00187072 (W 0.00168438) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.429627 ± 0.00276317 (W 0.00397244) | 0.498029 ± 0.0150111 (W 0.00430965) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.307643 ± 0.00456885 (W 0.00215009) | 0.473773 ± 0.00427993 (W 0.00712151) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.278786 ± 0.0014158 (W 0.00155746) | 0.347118 ± 0.00108471 (W 0.00177973) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.427947 ± 0.00178652 (W 0.00330059) | 0.282583 ± 0.00138635 (W 0.00346426) | 🔴 faer-fork 1.51× slower than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.18735 ± 0.000900706 (W 0.00184635) | 0.313762 ± 0.00142217 (W 0.0015955) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.143041 ± 0.000244684 (W 0.00116777) | 0.179675 ± 0.000521883 (W 0.00124306) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.0421 ± 0.00331817 (W 0.00174029) | 1.69361 ± 0.00837445 (W 0.00489622) | 🔵 faer-fork 1.63× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.09834 ± 0.00175679 (W 0.00247397) | 1.43459 ± 0.00720342 (W 0.00654061) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.13263 ± 0.0086609 (W 0.00203533) | 1.37684 ± 0.00420275 (W 0.00185022) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.334576 ± 0.00329094 (W 0.00356533) | 0.425061 ± 0.00224221 (W 0.00391397) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.301077 ± 0.00148239 (W 0.0022154) | 0.48045 ± 0.00543751 (W 0.00220134) | 🔵 faer-fork 1.60× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.297341 ± 0.000708109 (W 0.00240332) | 0.36551 ± 0.000546059 (W 0.00170191) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.213358 ± 0.00375935 (W 0.00350453) | 0.222799 ± 0.00084717 (W 0.00211171) | · | `!` between-start range over 5% |
| `gemm/4096x16x240/b1` | 0.182816 ± 0.00190657 (W 0.00291496) | 0.322979 ± 0.00243632 (W 0.00184919) | 🔵 faer-fork 1.77× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.156948 ± 0.000388881 (W 0.00151973) | 0.198149 ± 0.000659705 (W 0.0012497) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.14466 ± 0.00811087 (W 0.00420628) | 6.01093 ± 0.0327955 (W 0.00822323) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.3832 ± 0.0058193 (W 0.00790414) | 5.75638 ± 0.00699117 (W 0.021051) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.38819 ± 0.0106931 (W 0.00353406) | 5.41694 ± 0.0187681 (W 0.00418068) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.66104 ± 0.00229792 (W 0.00373629) | 1.70504 ± 0.0201678 (W 0.00426242) | · |  |
| `gemm/4096x16x240/b1` | 1.16051 ± 0.0105805 (W 0.00353819) | 1.67638 ± 0.00503662 (W 0.00307475) | 🔵 faer-fork 1.44× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.12552 ± 0.0062167 (W 0.00272485) | 1.3873 ± 0.00690806 (W 0.00283386) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.898325 ± 0.00425835 (W 0.00662818) | 0.933725 ± 0.00422451 (W 0.00476932) | · |  |
| `gemm/4096x16x240/b1` | 0.601293 ± 0.00345235 (W 0.00272938) | 1.00013 ± 0.00133984 (W 0.00359734) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.5755 ± 0.00299108 (W 0.00291323) | 0.701633 ± 0.00158286 (W 0.00261694) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 4.07261 ± 0.0161756 (W 0.00449956) | 5.76396 ± 0.0269154 (W 0.00636384) | 🔵 faer-fork 1.42× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 4.40048 ± 0.00601989 (W 0.00430125) | 5.74978 ± 0.0471608 (W 0.0159964) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 4.4377 ± 0.0077259 (W 0.00370933) | 5.5445 ± 0.0149712 (W 0.00525372) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.18155 ± 0.00537834 (W 0.00192021) | 1.49069 ± 0.00494483 (W 0.00473519) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 1.16802 ± 0.00690933 (W 0.00305194) | 1.72955 ± 0.0126209 (W 0.0053018) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 1.17951 ± 0.0107338 (W 0.0118694) | 1.45106 ± 0.00209597 (W 0.00436267) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.661551 ± 0.00370826 (W 0.0070354) | 0.829715 ± 0.00167413 (W 0.00433777) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `gemm/4096x16x240/b1` | 0.609422 ± 0.00354275 (W 0.00360998) | 1.01121 ± 0.00237458 (W 0.0150457) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `gemm/4096x64x64/b1` | 0.581013 ± 0.00269514 (W 0.00358872) | 0.77107 ± 0.00244126 (W 0.00368135) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.12691 ± 0.00684973 (W 0.00144019) | 1.37394 ± 0.00406111 (W 0.00200279) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.297596 ± 0.000835875 (W 0.00234857) | 0.365857 ± 0.00260079 (W 0.00199113) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.156904 ± 0.000446736 (W 0.00119039) | 0.197864 ± 0.000287808 (W 0.00120347) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.09019 ± 0.00567376 (W 0.00119725) | 1.36344 ± 0.0015416 (W 0.00150598) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.277868 ± 0.00103361 (W 0.00143356) | 0.347046 ± 0.0010071 (W 0.00160376) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.143027 ± 0.000596029 (W 0.00103502) | 0.178462 ± 0.000338996 (W 0.00124935) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.42957 ± 0.0062871 (W 0.00880357) | 5.5592 ± 0.00804661 (W 0.00496577) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.17462 ± 0.0128805 (W 0.00306345) | 1.45412 ± 0.00797337 (W 0.00288538) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.57995 ± 0.00426035 (W 0.00409637) | 0.768317 ± 0.000835744 (W 0.00255714) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 4.39452 ± 0.0200904 (W 0.00502177) | 5.42902 ± 0.00589939 (W 0.00678884) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 1.13057 ± 0.00267188 (W 0.00214536) | 1.38775 ± 0.00555373 (W 0.00304605) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.575287 ± 0.00213148 (W 0.00249608) | 0.697928 ± 0.00258893 (W 0.00246432) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0033065 ± 0.000156291 (W 2.11848e-05) | 0.0040725 ± 0.000124762 (W 3.68766e-05) | 🔵 faer-fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014877 ± 0.000802234 (W 2.75432e-05) | 0.017928 ± 0.000112473 (W 8.64724e-05) | 🔵 faer-fork 1.21× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.031033 ± 0.000893981 (W 5.53133e-05) | 0.043451 ± 0.000275355 (W 0.000139929) | 🔵 faer-fork 1.40× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112306 ± 0.000329285 (W 0.0013417) | 0.12005 ± 0.000335862 (W 0.000184768) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.483758 ± 0.00358135 (W 0.00202998) | 0.431547 ± 0.00145182 (W 0.00168522) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.15366 ± 0.00142865 (W 0.0019872) | 0.945527 ± 0.00276403 (W 0.00145088) | 🔴 faer-fork 1.22× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.011937 ± 0.000122758 (W 4.31578e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051847 ± 0.000476878 (W 0.00013772) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.146514 ± 0.000613931 (W 0.00222196) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008361 ± 3.77911e-05 (W 6.00429e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008395 ± 5.83804e-05 (W 5.20438e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.041021 ± 7.49684e-05 (W 0.000114461) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.041202 ± 0.000183797 (W 7.74165e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.122092 ± 0.000663377 (W 0.000208906) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.122303 ± 0.000230087 (W 0.00119312) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008957 ± 0.000103371 (W 6.11798e-05) | 0.009388 ± 0.000160782 (W 9.57427e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.03225 ± 0.000192631 (W 0.000156779) | 0.0371395 ± 0.000362457 (W 0.000160795) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.079062 ± 0.000441681 (W 0.00224142) | 0.0948265 ± 0.000669135 (W 0.00228094) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0327815 ± 0.000128929 (W 0.000167478) | 0.032065 ± 0.00011559 (W 0.000142035) | · |  |
| `qr/n64/b1` | 0.122483 ± 0.000299348 (W 0.000946628) | 0.127252 ± 0.00072862 (W 0.00147668) | · |  |
| `qr/n96/b1` | 0.306461 ± 0.00121976 (W 0.00301549) | 0.379008 ± 0.0140388 (W 0.00304916) | 🔵 faer-fork 1.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023669 ± 7.27289e-05 (W 9.18972e-05) | 0.017197 ± 0.000131134 (W 8.68877e-05) | 🔴 faer-fork 1.38× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.0897325 ± 0.000399751 (W 0.00121149) | 0.065207 ± 0.000532542 (W 0.0001699) | 🔴 faer-fork 1.38× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.197973 ± 0.00108823 (W 0.00127872) | 0.181198 ± 0.00105933 (W 0.00141013) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.010154 ± 7.60011e-05 (W 8.68031e-05) | 0.009633 ± 0.000101253 (W 3.33909e-05) | 🔴 faer-fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0334725 ± 0.000185721 (W 0.000122751) | 0.036368 ± 0.000293082 (W 7.96413e-05) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0827595 ± 0.000366164 (W 0.00245238) | 0.087288 ± 0.000615059 (W 0.000837126) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183828 ± 0.00179824 (W 0.00121258) | 0.182094 ± 0.000775477 (W 0.00133144) | · |  |
| `svd_thin/n64/b1` | 0.923029 ± 0.00417781 (W 0.00139803) | 0.676578 ± 0.00410753 (W 0.00373118) | 🔴 faer-fork 1.36× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.22837 ± 0.00876304 (W 0.00359375) | 1.6219 ± 0.0284903 (W 0.00371164) | 🔴 faer-fork 1.37× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140352 ± 0.00038538 (W 0.00112151) | 0.078171 ± 0.000486877 (W 0.00137824) | 🔴 faer-fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.517446 ± 0.00157238 (W 0.00176298) | 0.277056 ± 0.00146149 (W 0.0016764) | 🔴 faer-fork 1.87× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18852 ± 0.00556917 (W 0.00208172) | 0.662366 ± 0.00260753 (W 0.0035204) | 🔴 faer-fork 1.79× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000686 ± 0.000156184 (W 1.83676e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0015125 ± 2.56418e-05 (W 2.86089e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.002565 ± 2.3184e-05 (W 3.38653e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003452 ± 0.000103055 (W 2.64371e-05) | 0.004042 ± 2.79213e-05 (W 3.54252e-05) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014933 ± 0.00178668 (W 3.11879e-05) | 0.018239 ± 0.000398636 (W 6.75232e-05) | 🔵 faer-fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0340885 ± 0.00160877 (W 0.000557865) | 0.043336 ± 0.000167989 (W 0.000139148) | 🔵 faer-fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112305 ± 0.000156731 (W 0.000182738) | 0.103813 ± 0.000399423 (W 0.00077329) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.482395 ± 0.00138004 (W 0.00172924) | 0.354021 ± 0.00117416 (W 0.00168239) | 🔴 faer-fork 1.36× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.13576 ± 0.00334477 (W 0.0018633) | 0.76196 ± 0.00254106 (W 0.00193074) | 🔴 faer-fork 1.49× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0120975 ± 0.000110876 (W 5.08476e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0520725 ± 0.000168179 (W 0.000224166) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145245 ± 0.000425335 (W 0.00225705) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008386 ± 3.80473e-05 (W 6.84566e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008406 ± 4.50943e-05 (W 6.9649e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019782 ± 0.000933672 (W 0.00030319) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.020604 ± 0.000397624 (W 0.000380785) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.044483 ± 0.00132344 (W 0.000632199) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.04573 ± 0.000338111 (W 0.000417004) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.008937 ± 8.28824e-05 (W 7.70918e-05) | 0.009387 ± 0.000101134 (W 0.000126431) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.032365 ± 5.39098e-05 (W 0.00015847) | 0.03724 ± 0.000271662 (W 0.000107698) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.07803 ± 0.000199359 (W 0.00219341) | 0.095974 ± 0.00100345 (W 0.00255665) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0334675 ± 0.000149507 (W 0.000157847) | 0.0323005 ± 0.000482031 (W 0.000206977) | · |  |
| `qr/n64/b1` | 0.124407 ± 0.000716015 (W 0.000888975) | 0.126501 ± 0.00136218 (W 0.00104907) | · |  |
| `qr/n96/b1` | 0.285388 ± 0.00196815 (W 0.00333025) | 0.371904 ± 0.00330647 (W 0.00254059) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.024175 ± 9.85706e-05 (W 0.000113892) | 0.017262 ± 0.00024432 (W 6.29515e-05) | 🔴 faer-fork 1.40× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.092552 ± 0.000330553 (W 0.000258608) | 0.0653965 ± 0.000720028 (W 0.000186049) | 🔴 faer-fork 1.42× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.194047 ± 0.000886888 (W 0.0011307) | 0.183468 ± 0.00149358 (W 0.00143529) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0102595 ± 7.62725e-05 (W 5.51448e-05) | 0.009673 ± 0.000195718 (W 3.58002e-05) | 🔴 faer-fork 1.06× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.033548 ± 0.000274106 (W 0.000180584) | 0.0368835 ± 0.000428239 (W 0.000114912) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0795685 ± 0.000390174 (W 0.00243994) | 0.0875935 ± 0.000724301 (W 0.000673869) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183858 ± 0.000243415 (W 0.00189495) | 0.182075 ± 0.000827027 (W 0.00174112) | · |  |
| `svd_thin/n64/b1` | 0.914156 ± 0.00202467 (W 0.000976443) | 0.641116 ± 0.0016823 (W 0.00236219) | 🔴 faer-fork 1.43× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.11891 ± 0.00280568 (W 0.00210004) | 1.59119 ± 0.014037 (W 0.00290341) | 🔴 faer-fork 1.33× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140166 ± 0.000102479 (W 0.00169911) | 0.0779955 ± 0.000349077 (W 0.00113952) | 🔴 faer-fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.516921 ± 0.000910471 (W 0.00174474) | 0.272949 ± 0.00125973 (W 0.00171804) | 🔴 faer-fork 1.89× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18062 ± 0.00279406 (W 0.00168134) | 0.656405 ± 0.00903383 (W 0.00164252) | 🔴 faer-fork 1.80× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007415 ± 1.40095e-05 (W 2.24159e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001643 ± 2.42212e-05 (W 2.03682e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003006 ± 7.75382e-05 (W 4.67404e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003437 ± 0.000188337 (W 3.29665e-05) | 0.004138 ± 3.2396e-05 (W 4.14396e-05) | 🔵 faer-fork 1.20× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0157845 ± 0.000990305 (W 2.47079e-05) | 0.018084 ± 0.000153285 (W 9.37582e-05) | 🔵 faer-fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.034339 ± 0.00200435 (W 0.000244541) | 0.043185 ± 0.000271357 (W 0.000102695) | 🔵 faer-fork 1.26× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112579 ± 0.00018516 (W 0.000240294) | 0.103729 ± 0.000934156 (W 0.00132608) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.48345 ± 0.00287078 (W 0.00184015) | 0.347373 ± 0.00213931 (W 0.00164218) | 🔴 faer-fork 1.39× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.12939 ± 0.00212949 (W 0.0012696) | 0.738155 ± 0.0026492 (W 0.00198947) | 🔴 faer-fork 1.53× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.011977 ± 0.000142463 (W 5.52826e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.051732 ± 0.000288151 (W 0.000116552) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.145211 ± 0.00021316 (W 0.002584) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.008401 ± 4.53317e-05 (W 7.32484e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008416 ± 6.88234e-05 (W 7.49166e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.015549 ± 0.000886414 (W 0.000329796) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.016601 ± 0.00019685 (W 0.000392315) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0327515 ± 0.000489432 (W 0.000674502) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.032661 ± 0.000360696 (W 0.000613541) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0088915 ± 5.27851e-05 (W 8.1692e-05) | 0.009377 ± 0.00019961 (W 7.75089e-05) | 🔵 faer-fork 1.05× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0320095 ± 0.000157929 (W 0.000186236) | 0.0372745 ± 0.000352642 (W 0.000135083) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.078196 ± 0.000377309 (W 0.00233066) | 0.096034 ± 0.00111183 (W 0.00286189) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.033207 ± 0.000184684 (W 0.00021976) | 0.03219 ± 0.00017127 (W 0.000171057) | · |  |
| `qr/n64/b1` | 0.123736 ± 0.000408856 (W 0.000265514) | 0.127453 ± 0.0012863 (W 0.00139868) | · |  |
| `qr/n96/b1` | 0.277127 ± 0.000624947 (W 0.00207082) | 0.3759 ± 0.00907836 (W 0.00206029) | 🔵 faer-fork 1.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.023965 ± 0.000153624 (W 0.000109903) | 0.0171675 ± 0.00027558 (W 0.000100162) | 🔴 faer-fork 1.40× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.095573 ± 0.000189304 (W 0.000793684) | 0.0657875 ± 0.00102747 (W 0.000238884) | 🔴 faer-fork 1.45× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.194222 ± 0.000468745 (W 0.00137445) | 0.183978 ± 0.00296093 (W 0.0013057) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.010274 ± 8.27053e-05 (W 6.26476e-05) | 0.009748 ± 0.000125857 (W 6.50939e-05) | 🔴 faer-fork 1.05× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0334025 ± 0.000447675 (W 0.000171272) | 0.036914 ± 0.000220673 (W 6.57889e-05) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.0796985 ± 7.3296e-05 (W 0.000211757) | 0.0877135 ± 0.000306951 (W 0.000783996) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.183638 ± 0.000418864 (W 0.00146349) | 0.183257 ± 0.000602528 (W 0.00120978) | · |  |
| `svd_thin/n64/b1` | 0.912586 ± 0.00187997 (W 0.00150573) | 0.643056 ± 0.0213443 (W 0.00250997) | 🔴 faer-fork 1.42× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n96/b1` | 2.10704 ± 0.00194618 (W 0.00179836) | 1.5914 ± 0.0187059 (W 0.00336293) | 🔴 faer-fork 1.32× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.140172 ± 0.000293885 (W 0.00150317) | 0.077925 ± 0.000496594 (W 0.000155642) | 🔴 faer-fork 1.80× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.515736 ± 0.00154761 (W 0.00193424) | 0.274627 ± 0.00240773 (W 0.00182206) | 🔴 faer-fork 1.88× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18005 ± 0.00213242 (W 0.00222865) | 0.667137 ± 0.0107042 (W 0.00169092) | 🔴 faer-fork 1.77× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0007265 ± 1.95695e-05 (W 1.98915e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001628 ± 2.60768e-05 (W 3.15124e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0029205 ± 0.000157352 (W 4.12047e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0030855 ± 0.000153337 (W 2.09404e-05) | 0.0033865 ± 2.52243e-05 (W 3.51969e-05) | 🔵 faer-fork 1.10× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014542 ± 0.000802617 (W 4.10435e-05) | 0.015319 ± 7.81042e-05 (W 9.55843e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0301565 ± 0.00089805 (W 4.54371e-05) | 0.036934 ± 0.000334298 (W 0.000100232) | 🔵 faer-fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.11236 ± 0.000317315 (W 0.000176467) | 0.119078 ± 0.000136766 (W 0.00172804) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.483491 ± 0.0012963 (W 0.00187693) | 0.42689 ± 0.000510578 (W 0.00177114) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.15478 ± 0.00101906 (W 0.001581) | 0.936716 ± 0.00219124 (W 0.00079216) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0100485 ± 0.000129546 (W 3.41699e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0453845 ± 0.00017934 (W 0.000196553) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.132312 ± 0.000494859 (W 0.00208758) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0084605 ± 4.53008e-05 (W 3.7274e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008536 ± 4.4572e-05 (W 5.27743e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.040761 ± 0.000168409 (W 7.83656e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.040876 ± 7.30764e-05 (W 7.90148e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.124177 ± 0.000484659 (W 0.000601355) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.124212 ± 7.2921e-05 (W 0.000172621) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007193 ± 2.4742e-05 (W 4.71356e-05) | 0.008236 ± 8.39938e-05 (W 5.96056e-05) | 🔵 faer-fork 1.15× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025903 ± 0.00024405 (W 0.000149832) | 0.032701 ± 0.000162778 (W 0.0006007) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.063779 ± 0.000497712 (W 0.000918217) | 0.076718 ± 0.000191377 (W 0.000744265) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.0309325 ± 0.000168844 (W 0.000170183) | 0.029926 ± 0.000284533 (W 0.000684126) | · |  |
| `qr/n64/b1` | 0.114624 ± 0.000285341 (W 0.00130233) | 0.119623 ± 0.00113342 (W 0.00141628) | · |  |
| `qr/n96/b1` | 0.289466 ± 0.000883439 (W 0.00296828) | 0.34329 ± 0.00314197 (W 0.00171986) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0174775 ± 0.000122761 (W 0.000103586) | 0.016175 ± 0.000226666 (W 0.000103248) | 🔴 faer-fork 1.08× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.0733465 ± 0.000178372 (W 0.000221368) | 0.0606775 ± 0.000321633 (W 0.000162725) | 🔴 faer-fork 1.21× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.162794 ± 0.000447246 (W 0.00126588) | 0.171355 ± 0.000543988 (W 0.000731414) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.00811 ± 6.50128e-05 (W 6.76072e-05) | 0.008461 ± 7.89092e-05 (W 4.22809e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026329 ± 0.000142282 (W 7.47138e-05) | 0.0323855 ± 0.000188351 (W 8.34446e-05) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.067366 ± 0.000283561 (W 0.00240094) | 0.075982 ± 0.000344024 (W 0.000761726) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.186231 ± 0.00161047 (W 0.00144921) | 0.175702 ± 0.0011013 (W 0.00141458) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 0.967492 ± 0.00436229 (W 0.00121334) | 0.637287 ± 0.00507011 (W 0.00195645) | 🔴 faer-fork 1.52× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.19274 ± 0.0412268 (W 0.0019148) | 1.52145 ± 0.0545582 (W 0.00272145) | 🔴 faer-fork 1.44× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.142216 ± 0.000436688 (W 0.000952262) | 0.074789 ± 0.000375255 (W 0.000733613) | 🔴 faer-fork 1.90× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.538867 ± 0.00171355 (W 0.00167592) | 0.273195 ± 0.00249515 (W 0.00161077) | 🔴 faer-fork 1.97× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.19579 ± 0.00476403 (W 0.00147882) | 0.656059 ± 0.00725026 (W 0.00167742) | 🔴 faer-fork 1.82× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.000757 ± 1.79518e-05 (W 2.38554e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001703 ± 2.07244e-05 (W 1.86915e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003026 ± 7.26517e-05 (W 3.45299e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0031755 ± 0.00013824 (W 2.38437e-05) | 0.003386 ± 2.62329e-05 (W 2.58474e-05) | 🔵 faer-fork 1.07× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014557 ± 0.00137525 (W 3.46017e-05) | 0.0151685 ± 7.76891e-05 (W 6.46977e-05) | · | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.0330515 ± 0.00145696 (W 0.000522962) | 0.036994 ± 0.000143082 (W 0.000101898) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.11239 ± 0.000188922 (W 0.000251771) | 0.102983 ± 0.000400561 (W 0.00126648) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.48336 ± 0.00154762 (W 0.0020439) | 0.350294 ± 0.00057895 (W 0.00173311) | 🔴 faer-fork 1.38× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.13644 ± 0.00277548 (W 0.00144866) | 0.751436 ± 0.00166143 (W 0.00157363) | 🔴 faer-fork 1.51× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010184 ± 0.000190221 (W 6.17375e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.04564 ± 0.000453348 (W 0.000167161) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.13074 ± 0.000348328 (W 0.00227903) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0084805 ± 5.16943e-05 (W 4.04109e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008541 ± 5.17832e-05 (W 4.71245e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.019767 ± 0.000289858 (W 0.000282043) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0196815 ± 0.000202612 (W 0.000306624) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0442175 ± 0.000432544 (W 0.000321961) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.044398 ± 0.000145967 (W 0.000238826) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0071835 ± 3.03359e-05 (W 6.59554e-05) | 0.00828 ± 0.000186473 (W 7.76738e-05) | 🔵 faer-fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.026079 ± 0.000168322 (W 0.000151302) | 0.033167 ± 0.000780628 (W 0.000112273) | 🔵 faer-fork 1.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n96/b1` | 0.063193 ± 0.000170814 (W 0.00220586) | 0.0768285 ± 0.000406781 (W 0.000924989) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.031579 ± 0.000230192 (W 0.000184693) | 0.0297255 ± 0.000349978 (W 0.000142471) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.116456 ± 0.000555795 (W 0.000255485) | 0.119147 ± 0.000556772 (W 0.00171326) | · |  |
| `qr/n96/b1` | 0.268255 ± 0.00105484 (W 0.00312345) | 0.344894 ± 0.00638014 (W 0.00181038) | 🔵 faer-fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n32/b1` | 0.017934 ± 9.42988e-05 (W 7.85898e-05) | 0.0161 ± 0.000168967 (W 0.00010615) | 🔴 faer-fork 1.11× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.07553 ± 0.000394221 (W 0.000202031) | 0.06128 ± 0.000574844 (W 0.000226796) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.156978 ± 0.000379845 (W 0.00110548) | 0.173654 ± 0.00298919 (W 0.00116272) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.0082005 ± 3.4373e-05 (W 0.000103188) | 0.0084405 ± 6.36417e-05 (W 5.29759e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0273055 ± 0.00038895 (W 0.000138848) | 0.032411 ± 0.000191351 (W 0.000107276) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.064986 ± 0.00022701 (W 0.00249905) | 0.0760265 ± 0.000589327 (W 0.000716789) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.185966 ± 0.000402399 (W 0.00125973) | 0.17666 ± 0.000587965 (W 0.00133964) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `svd_thin/n64/b1` | 0.956693 ± 0.00173997 (W 0.00112497) | 0.62334 ± 0.00814296 (W 0.00197325) | 🔴 faer-fork 1.53× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.11927 ± 0.00210992 (W 0.00214488) | 1.46843 ± 0.00795877 (W 0.00205498) | 🔴 faer-fork 1.44× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.14205 ± 0.000167519 (W 0.00142256) | 0.074294 ± 0.00035794 (W 0.00017065) | 🔴 faer-fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.536496 ± 0.00169167 (W 0.00193138) | 0.268711 ± 0.000863908 (W 0.00189419) | 🔴 faer-fork 2.00× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.1869 ± 0.00260201 (W 0.00195026) | 0.657315 ± 0.0110892 (W 0.00148024) | 🔴 faer-fork 1.81× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0008215 ± 1.64611e-05 (W 3.12159e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.001843 ± 2.02031e-05 (W 3.36656e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003296 ± 0.000161265 (W 6.93468e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.003266 ± 0.000142202 (W 2.92222e-05) | 0.003461 ± 5.24115e-05 (W 2.58134e-05) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.014472 ± 0.000821936 (W 4.05296e-05) | 0.0152485 ± 8.51328e-05 (W 8.48625e-05) | · | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `cholesky/n96/b1` | 0.033713 ± 0.0018791 (W 0.000219151) | 0.0368635 ± 0.00103223 (W 0.0001097) | 🔵 faer-fork 1.09× faster than `lapack-openblas` | `!` between-start range over 5% |
| `eigh/n32/b1` | 0.112965 ± 0.0005559 (W 0.00112444) | 0.103007 ± 0.000875773 (W 0.00135596) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.484804 ± 0.00318737 (W 0.00230655) | 0.343316 ± 0.00182481 (W 0.00177117) | 🔴 faer-fork 1.41× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.13152 ± 0.00293021 (W 0.00136657) | 0.730304 ± 0.00142283 (W 0.00215295) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.010194 ± 7.81665e-05 (W 5.06485e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.045455 ± 0.000218176 (W 0.000830658) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.130744 ± 0.000486708 (W 0.00245651) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0085605 ± 9.69132e-05 (W 4.56071e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.008596 ± 1.16905e-05 (W 5.76678e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0151185 ± 0.000184755 (W 0.000297973) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.015078 ± 0.000196704 (W 0.000339245) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.0301615 ± 0.000257204 (W 0.000299113) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0303165 ± 0.000108697 (W 0.00036668) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.007183 ± 3.50452e-05 (W 4.78613e-05) | 0.008305 ± 5.19131e-05 (W 8.71637e-05) | 🔵 faer-fork 1.16× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.025713 ± 9.8307e-05 (W 0.000199443) | 0.033217 ± 0.000297806 (W 0.000129959) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.0633135 ± 0.000293456 (W 0.00223147) | 0.0771035 ± 0.000254426 (W 0.000180138) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.031504 ± 0.000107301 (W 0.000228896) | 0.030036 ± 0.000323235 (W 0.000101694) | · |  |
| `qr/n64/b1` | 0.115756 ± 0.000405129 (W 0.000802204) | 0.119388 ± 0.0018131 (W 0.00165979) | · |  |
| `qr/n96/b1` | 0.260315 ± 0.00111235 (W 0.00235123) | 0.346703 ± 0.00231789 (W 0.00152401) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.017708 ± 0.000150081 (W 7.18327e-05) | 0.016311 ± 0.000264337 (W 8.32041e-05) | 🔴 faer-fork 1.09× slower than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.0750645 ± 0.000233148 (W 0.000220098) | 0.0612895 ± 0.00117749 (W 0.00171438) | 🔴 faer-fork 1.22× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.15544 ± 0.000861095 (W 0.00124657) | 0.173273 ± 0.00161608 (W 0.00125753) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.008215 ± 4.55357e-05 (W 5.85783e-05) | 0.008501 ± 5.46504e-05 (W 3.94069e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.026655 ± 0.000105174 (W 0.000111233) | 0.032305 ± 8.97589e-05 (W 8.12937e-05) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.064906 ± 0.000263273 (W 0.00122783) | 0.076117 ± 0.000252582 (W 0.000805024) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.185882 ± 0.000468543 (W 0.0017909) | 0.176945 ± 0.00053137 (W 0.00163343) | · |  |
| `svd_thin/n64/b1` | 0.957318 ± 0.00195395 (W 0.00106036) | 0.625802 ± 0.00919035 (W 0.00171181) | 🔴 faer-fork 1.53× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.10515 ± 0.00240148 (W 0.00240997) | 1.46042 ± 0.0429293 (W 0.00325613) | 🔴 faer-fork 1.44× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.142145 ± 0.000259893 (W 0.00137519) | 0.0745035 ± 0.000380454 (W 0.000177971) | 🔴 faer-fork 1.91× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.537753 ± 0.00143909 (W 0.00220004) | 0.27051 ± 0.00159298 (W 0.00171503) | 🔴 faer-fork 1.99× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.18728 ± 0.00151725 (W 0.00179501) | 0.667852 ± 0.00652539 (W 0.00174988) | 🔴 faer-fork 1.78× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0008065 ± 3.58553e-05 (W 3.42255e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0018385 ± 4.68078e-05 (W 2.18025e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.003351 ± 0.000162776 (W 3.50922e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050295 ± 5.78123e-05 (W 3.94381e-05) | 0.0066225 ± 8.4579e-05 (W 7.40018e-05) | 🔵 faer-fork 1.32× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029871 ± 9.17033e-05 (W 0.000122486) | 0.0394885 ± 0.000209142 (W 0.000264305) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.084798 ± 0.00018872 (W 0.000212811) | 0.095639 ± 0.000415284 (W 0.000654169) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.141439 ± 0.000315819 (W 0.00112943) | 0.151328 ± 0.000312052 (W 0.00134863) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.648262 ± 0.000940889 (W 0.00202222) | 0.657192 ± 0.00191341 (W 0.00187526) | · |  |
| `eigh/n96/b1` | 1.61384 ± 0.0017079 (W 0.00210548) | 1.63365 ± 0.00293143 (W 0.00288884) | · |  |
| `full_piv_lu/n32/b1` | 0.017788 ± 6.36252e-05 (W 8.05644e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.098223 ± 0.000376852 (W 0.000261357) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.282643 ± 0.0011797 (W 0.00174423) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028253 ± 5.82374e-05 (W 7.53558e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028438 ± 0.000120277 (W 6.7031e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.159618 ± 0.000249372 (W 0.00140513) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.160675 ± 0.000224034 (W 0.00148182) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.466992 ± 0.00152853 (W 0.000347881) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.473224 ± 0.00213126 (W 0.000593549) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0136105 ± 0.00019737 (W 3.19607e-05) | 0.013896 ± 6.15359e-05 (W 5.69284e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0591005 ± 0.000549129 (W 0.000667148) | 0.068272 ± 0.000184478 (W 0.00038172) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.153742 ± 0.00030972 (W 0.00123927) | 0.181841 ± 0.00148216 (W 0.00153924) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.069094 ± 0.000533828 (W 0.000763414) | 0.0537 ± 0.000352469 (W 0.000126865) | 🔴 faer-fork 1.29× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.318634 ± 0.00100487 (W 0.00183301) | 0.261453 ± 0.00209035 (W 0.00182281) | 🔴 faer-fork 1.22× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.778819 ± 0.00281002 (W 0.00233703) | 0.730365 ± 0.00324308 (W 0.00190427) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0405205 ± 0.000113626 (W 0.000183725) | 0.0300915 ± 0.000210536 (W 8.83954e-05) | 🔴 faer-fork 1.35× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.176805 ± 0.000832128 (W 0.00123612) | 0.137742 ± 0.00187865 (W 0.00117522) | 🔴 faer-fork 1.28× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.42616 ± 0.00137986 (W 0.00201352) | 0.37261 ± 0.00257341 (W 0.00146771) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.014928 ± 6.12658e-05 (W 3.99168e-05) | 0.0155035 ± 0.000143827 (W 6.44245e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0613845 ± 0.000575664 (W 0.000736012) | 0.0716485 ± 0.000601461 (W 0.000492537) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.157419 ± 0.000852032 (W 0.00138294) | 0.187366 ± 0.00201645 (W 0.00190744) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.236261 ± 0.000696192 (W 0.00145676) | 0.226954 ± 0.000771988 (W 0.00169368) | · |  |
| `svd_thin/n64/b1` | 1.22642 ± 0.00249065 (W 0.00180202) | 0.9623 ± 0.00297624 (W 0.000985087) | 🔴 faer-fork 1.27× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.13387 ± 0.00811224 (W 0.0020864) | 2.63483 ± 0.106829 (W 0.00202787) | 🔴 faer-fork 1.19× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.161492 ± 0.000241169 (W 0.00120909) | 0.102832 ± 0.000646615 (W 0.00106243) | 🔴 faer-fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.651739 ± 0.00182762 (W 0.00179928) | 0.4105 ± 0.00122985 (W 0.00176851) | 🔴 faer-fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.51262 ± 0.00399877 (W 0.00234139) | 1.02188 ± 0.00321788 (W 0.00094389) | 🔴 faer-fork 1.48× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001087 ± 1.51658e-05 (W 2.46086e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002755 ± 3.85249e-05 (W 2.32896e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004989 ± 3.33092e-05 (W 2.48795e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0050145 ± 6.86314e-05 (W 4.03608e-05) | 0.006547 ± 3.75255e-05 (W 4.57834e-05) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.029961 ± 0.000223348 (W 8.43558e-05) | 0.0404605 ± 0.00274311 (W 0.000616104) | 🔵 faer-fork 1.35× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n96/b1` | 0.087738 ± 0.000248806 (W 0.000713161) | 0.093124 ± 0.000855343 (W 0.000605938) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.141769 ± 0.000332176 (W 0.000325764) | 0.13703 ± 0.000955249 (W 0.000722518) | · |  |
| `eigh/n64/b1` | 0.593442 ± 0.000756858 (W 0.00144356) | 0.569964 ± 0.0016021 (W 0.0015579) | · |  |
| `eigh/n96/b1` | 1.40655 ± 0.00135921 (W 0.00182666) | 1.61221 ± 0.00959201 (W 0.00133056) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0177035 ± 0.000194001 (W 0.000111415) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0971215 ± 0.000347073 (W 0.000352196) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.279891 ± 0.000405146 (W 0.00142564) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.014943 ± 0.000134561 (W 0.000207465) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.014902 ± 0.000238761 (W 0.000229752) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060533 ± 0.000484433 (W 0.000319667) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0609735 ± 0.000192635 (W 0.000365016) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.150736 ± 0.000934362 (W 0.000601466) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.150656 ± 0.000590145 (W 0.00130649) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.01373 ± 0.00011607 (W 9.59151e-05) | 0.013666 ± 0.000133163 (W 5.64424e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.05932 ± 0.000211492 (W 0.000394309) | 0.0673705 ± 0.00052999 (W 0.000484982) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.152855 ± 0.00155074 (W 0.00271605) | 0.179766 ± 0.00094142 (W 0.0019425) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070296 ± 0.000434834 (W 0.000253824) | 0.0538505 ± 0.000597727 (W 0.000129766) | 🔴 faer-fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.235268 ± 0.00107654 (W 0.00131649) | 0.262844 ± 0.00355938 (W 0.00194719) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.474109 ± 0.00112373 (W 0.00206286) | 0.924646 ± 0.00364441 (W 0.00220338) | 🔵 faer-fork 1.95× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.041042 ± 6.20022e-05 (W 0.000161395) | 0.029765 ± 0.000257151 (W 0.000101438) | 🔴 faer-fork 1.38× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.156887 ± 0.000780339 (W 0.00140179) | 0.138127 ± 0.00148417 (W 0.00117515) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.325666 ± 0.00124141 (W 0.00151026) | 0.46963 ± 0.00189045 (W 0.00184251) | 🔵 faer-fork 1.44× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.015088 ± 8.09831e-05 (W 4.86011e-05) | 0.015439 ± 0.000112819 (W 6.32636e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0614495 ± 0.000357939 (W 0.000107593) | 0.0716035 ± 0.00112708 (W 0.000369316) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.154007 ± 0.00137791 (W 0.00165797) | 0.190696 ± 0.0010637 (W 0.00180982) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.2361 ± 0.000459098 (W 0.00129381) | 0.227243 ± 0.0007019 (W 0.00171765) | · |  |
| `svd_thin/n64/b1` | 1.11228 ± 0.00128249 (W 0.00104215) | 0.960099 ± 0.00330741 (W 0.00126923) | 🔴 faer-fork 1.16× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.77176 ± 0.00293971 (W 0.00383119) | 2.58071 ± 0.114734 (W 0.00354756) | 🔴 faer-fork 1.07× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.161502 ± 0.00019463 (W 0.000771249) | 0.102907 ± 0.000638766 (W 0.00157538) | 🔴 faer-fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.650875 ± 0.0013954 (W 0.0016232) | 0.408189 ± 0.0032362 (W 0.00203327) | 🔴 faer-fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.50569 ± 0.00299385 (W 0.00173441) | 1.28625 ± 0.00445108 (W 0.00176495) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0012075 ± 5.30723e-06 (W 2.10909e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0029705 ± 2.91713e-05 (W 3.322e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.005345 ± 3.0605e-05 (W 5.3168e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0049995 ± 7.73315e-05 (W 4.05128e-05) | 0.0066175 ± 5.98019e-05 (W 4.16667e-05) | 🔵 faer-fork 1.32× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0296805 ± 0.000221857 (W 0.000102898) | 0.04296 ± 0.00217546 (W 0.000612901) | 🔵 faer-fork 1.45× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.088751 ± 0.000209753 (W 0.000487259) | 0.0995505 ± 0.000755296 (W 0.00192046) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.141483 ± 0.00041963 (W 0.000276077) | 0.135698 ± 0.00132412 (W 0.000874168) | · |  |
| `eigh/n64/b1` | 0.577712 ± 0.00201681 (W 0.00231218) | 0.560256 ± 0.00486202 (W 0.00147075) | · |  |
| `eigh/n96/b1` | 1.37174 ± 0.00151132 (W 0.00208919) | 1.64854 ± 0.00484492 (W 0.00257053) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.0178285 ± 0.000103655 (W 8.22593e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.097166 ± 0.000302073 (W 0.000341278) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.279642 ± 0.00045417 (W 0.0017206) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0114915 ± 0.000131124 (W 0.000192776) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.012093 ± 0.00038805 (W 0.000298593) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.0373045 ± 0.000609716 (W 0.000339149) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.037645 ± 0.000296325 (W 0.000363711) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.085835 ± 0.000343587 (W 0.000712751) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.08581 ± 0.000391936 (W 0.000394957) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.0137155 ± 6.89657e-05 (W 5.31638e-05) | 0.013881 ± 0.000125286 (W 8.00199e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.058985 ± 0.000155263 (W 0.000959501) | 0.0682825 ± 0.000816165 (W 0.0002352) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.153786 ± 0.00151997 (W 0.00216106) | 0.181319 ± 0.00226319 (W 0.0017445) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.070016 ± 0.000325652 (W 0.000308939) | 0.0537655 ± 0.000242004 (W 9.24485e-05) | 🔴 faer-fork 1.30× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.229538 ± 0.00111936 (W 0.00178962) | 0.261047 ± 0.00207586 (W 0.00162961) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.427878 ± 0.00150207 (W 0.00222626) | 0.98461 ± 0.00332232 (W 0.00167266) | 🔵 faer-fork 2.30× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.040786 ± 0.000198189 (W 0.000215507) | 0.029866 ± 9.89352e-05 (W 0.000115082) | 🔴 faer-fork 1.37× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.157494 ± 0.000405955 (W 0.00097282) | 0.137076 ± 0.000862602 (W 0.001299) | 🔴 faer-fork 1.15× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.313075 ± 0.00155834 (W 0.00204842) | 0.502231 ± 0.00299811 (W 0.00151722) | 🔵 faer-fork 1.60× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.015018 ± 0.000120457 (W 4.51511e-05) | 0.0153485 ± 0.000205114 (W 5.45637e-05) | · | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.061595 ± 0.000218592 (W 8.90557e-05) | 0.071418 ± 0.000723285 (W 0.000397252) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.156286 ± 0.000653004 (W 0.00133376) | 0.187671 ± 0.00238005 (W 0.00198656) | 🔵 faer-fork 1.20× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.235911 ± 0.00727784 (W 0.001522) | 0.226653 ± 0.00136983 (W 0.00136472) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.09062 ± 0.00303821 (W 0.00146921) | 0.965461 ± 0.00819035 (W 0.00118814) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.71288 ± 0.00285877 (W 0.00263651) | 2.62695 ± 0.105369 (W 0.00407562) | · | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.161482 ± 0.000340933 (W 0.000130716) | 0.102867 ± 0.000213106 (W 0.00156272) | 🔴 faer-fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.649663 ± 0.000772497 (W 0.00180719) | 0.407997 ± 0.00150854 (W 0.00196985) | 🔴 faer-fork 1.59× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.50598 ± 0.00230236 (W 0.00207173) | 1.37533 ± 0.00241536 (W 0.00444296) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0011825 ± 1.44314e-05 (W 3.21306e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0029355 ± 3.66083e-05 (W 2.96221e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00528 ± 3.01662e-05 (W 3.55634e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004984 ± 3.22516e-05 (W 3.56044e-05) | 0.005871 ± 9.75098e-05 (W 4.24815e-05) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0296905 ± 0.000163363 (W 9.29005e-05) | 0.0317945 ± 0.000181815 (W 7.31391e-05) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `cholesky/n96/b1` | 0.0839265 ± 0.000139349 (W 0.000160868) | 0.086697 ± 0.000178983 (W 0.000222502) | · |  |
| `eigh/n32/b1` | 0.141364 ± 0.000408864 (W 0.00110008) | 0.150381 ± 0.000247259 (W 0.00115509) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `eigh/n64/b1` | 0.648285 ± 0.000636295 (W 0.00164174) | 0.648697 ± 0.00167997 (W 0.00138324) | · |  |
| `eigh/n96/b1` | 1.61095 ± 0.00140193 (W 0.00217815) | 1.61975 ± 0.00293219 (W 0.00231546) | · |  |
| `full_piv_lu/n32/b1` | 0.016085 ± 9.3553e-05 (W 8.31891e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0915605 ± 0.000296271 (W 0.000380555) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.267799 ± 0.00148258 (W 0.00141235) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.028373 ± 8.61974e-05 (W 7.75479e-05) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.028538 ± 0.000105414 (W 0.000595665) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.158019 ± 0.000263158 (W 0.000690728) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.158571 ± 0.00018165 (W 0.00075506) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.462342 ± 0.00187982 (W 0.00172615) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.466175 ± 0.00118776 (W 0.000945673) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.011963 ± 8.48939e-05 (W 0.000134717) | 0.012724 ± 6.54849e-05 (W 5.35074e-05) | 🔵 faer-fork 1.06× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052648 ± 0.000131246 (W 0.00031943) | 0.060207 ± 0.000230685 (W 0.00122639) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.139886 ± 0.00123018 (W 0.00133398) | 0.164006 ± 0.000559595 (W 0.00129095) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.067581 ± 0.000390111 (W 0.00128952) | 0.0516515 ± 0.000479578 (W 0.000234757) | 🔴 faer-fork 1.31× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.312358 ± 0.000828889 (W 0.00184961) | 0.250163 ± 0.00231244 (W 0.00201672) | 🔴 faer-fork 1.25× slower than `lapack-openblas` |  |
| `qr/n96/b1` | 0.764552 ± 0.00181513 (W 0.00154108) | 0.699448 ± 0.00555772 (W 0.00227349) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.033362 ± 0.000356529 (W 0.000225157) | 0.028924 ± 0.000127578 (W 7.10492e-05) | 🔴 faer-fork 1.15× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.161547 ± 0.000794192 (W 0.0012648) | 0.130048 ± 0.00100764 (W 0.000326853) | 🔴 faer-fork 1.24× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.390459 ± 0.00133848 (W 0.00210165) | 0.356787 ± 0.00267784 (W 0.0017303) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `solve/n32/b1` | 0.01319 ± 4.49329e-05 (W 5.92709e-05) | 0.0140965 ± 8.41562e-05 (W 8.80062e-05) | 🔵 faer-fork 1.07× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.055153 ± 0.000567276 (W 0.00012591) | 0.0646555 ± 0.000372272 (W 0.000162676) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.14234 ± 0.000171739 (W 0.00141605) | 0.172878 ± 0.000680462 (W 0.0014215) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.233491 ± 0.000857942 (W 0.00158987) | 0.225375 ± 0.000607643 (W 0.00164864) | · |  |
| `svd_thin/n64/b1` | 1.25784 ± 0.00346322 (W 0.00198653) | 0.939696 ± 0.00548729 (W 0.000620383) | 🔴 faer-fork 1.34× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 3.09096 ± 0.00792466 (W 0.00185368) | 2.50581 ± 0.0137392 (W 0.00266953) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.159463 ± 0.000189738 (W 0.00115472) | 0.103053 ± 0.000382419 (W 0.000667153) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.627717 ± 0.00162809 (W 0.00176693) | 0.40246 ± 0.00133671 (W 0.00162847) | 🔴 faer-fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.48735 ± 0.0050977 (W 0.00173197) | 1.00412 ± 0.0042151 (W 0.000786312) | 🔴 faer-fork 1.48× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.001172 ± 8.3666e-06 (W 1.79599e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.002925 ± 1.00797e-05 (W 1.95633e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.004984 ± 0.000259931 (W 2.61709e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.004939 ± 4.44597e-05 (W 2.90333e-05) | 0.0058055 ± 4.51176e-05 (W 5.15972e-05) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.0296 ± 0.000147434 (W 0.000120566) | 0.0332675 ± 0.00278403 (W 0.000273363) | 🔵 faer-fork 1.12× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `cholesky/n96/b1` | 0.0864615 ± 0.000556108 (W 0.000584032) | 0.0881145 ± 0.000946535 (W 0.000927117) | · |  |
| `eigh/n32/b1` | 0.141634 ± 0.000277949 (W 0.000289233) | 0.136014 ± 0.00101143 (W 0.000208525) | · |  |
| `eigh/n64/b1` | 0.593573 ± 0.00104875 (W 0.00174973) | 0.564008 ± 0.00101188 (W 0.00190482) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `eigh/n96/b1` | 1.40599 ± 0.00217233 (W 0.0018963) | 1.59776 ± 0.00995482 (W 0.00215207) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.01595 ± 0.000252904 (W 4.4918e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0908195 ± 0.000404189 (W 0.000297799) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.265652 ± 0.000445234 (W 0.00146149) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0152385 ± 0.000180882 (W 0.000320457) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.015409 ± 0.000215787 (W 0.000215138) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.060483 ± 0.000169706 (W 0.000281843) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.0605225 ± 0.000492656 (W 0.00034276) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.149103 ± 0.000294075 (W 0.000401506) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.149228 ± 0.000764495 (W 0.00126574) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012137 ± 9.37351e-05 (W 0.000115172) | 0.012759 ± 5.54076e-05 (W 7.68467e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.052994 ± 0.000543527 (W 0.000716743) | 0.060268 ± 0.000109174 (W 0.000641615) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.138068 ± 0.00184817 (W 0.00142578) | 0.164357 ± 0.000444081 (W 0.0014741) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.069064 ± 0.000370516 (W 0.000200639) | 0.051561 ± 0.000218239 (W 0.000189875) | 🔴 faer-fork 1.34× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.229518 ± 0.000825142 (W 0.00152014) | 0.249621 ± 0.00215614 (W 0.0018575) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.458796 ± 0.00112628 (W 0.00169751) | 0.894475 ± 0.00271357 (W 0.00238919) | 🔵 faer-fork 1.95× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0344295 ± 0.00010568 (W 0.00017486) | 0.0287935 ± 0.000160668 (W 6.43639e-05) | 🔴 faer-fork 1.20× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.138925 ± 0.000527342 (W 0.00141376) | 0.130053 ± 0.000881136 (W 0.00147294) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.28316 ± 0.0016741 (W 0.00167565) | 0.45282 ± 0.00343054 (W 0.00205531) | 🔵 faer-fork 1.60× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.013185 ± 8.07475e-05 (W 5.40577e-05) | 0.0140765 ± 7.58569e-05 (W 8.22708e-05) | 🔵 faer-fork 1.07× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.0549475 ± 0.000322996 (W 8.30977e-05) | 0.0645455 ± 0.000345981 (W 0.000121799) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.139866 ± 0.00155927 (W 0.00177833) | 0.172872 ± 0.000440449 (W 0.00114892) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.23383 ± 0.000633344 (W 0.00158563) | 0.225941 ± 0.000616621 (W 0.00162187) | · |  |
| `svd_thin/n64/b1` | 1.14238 ± 0.00220992 (W 0.00175498) | 0.949852 ± 0.00707526 (W 0.00125543) | 🔴 faer-fork 1.20× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.73077 ± 0.00295625 (W 0.00310768) | 2.449 ± 0.00395515 (W 0.00350022) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.159503 ± 0.0001593 (W 0.00129518) | 0.102901 ± 0.000305954 (W 0.000120158) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.625447 ± 0.00115042 (W 0.00178489) | 0.400527 ± 0.0031126 (W 0.0017773) | 🔴 faer-fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.47841 ± 0.00499667 (W 0.00148707) | 1.26811 ± 0.00360157 (W 0.00161074) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0012325 ± 1.53286e-05 (W 2.81857e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.0029855 ± 0.000225183 (W 2.86268e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.00551 ± 0.000342346 (W 3.96733e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n32/b1` | 0.0049995 ± 6.58101e-05 (W 3.01296e-05) | 0.005881 ± 8.36062e-05 (W 4.71538e-05) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `cholesky/n64/b1` | 0.02917 ± 0.000163679 (W 8.25e-05) | 0.037435 ± 0.0023458 (W 0.000782871) | 🔵 faer-fork 1.28× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n96/b1` | 0.0876135 ± 0.000199881 (W 0.000274687) | 0.0946215 ± 0.000538042 (W 0.0014429) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `eigh/n32/b1` | 0.141559 ± 0.000418847 (W 0.00024631) | 0.134696 ± 0.00137318 (W 0.000164575) | · |  |
| `eigh/n64/b1` | 0.575753 ± 0.00110805 (W 0.00155092) | 0.554386 ± 0.00497888 (W 0.00187881) | · |  |
| `eigh/n96/b1` | 1.37089 ± 0.000950556 (W 0.00199728) | 1.63472 ± 0.00395731 (W 0.00212649) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `full_piv_lu/n32/b1` | 0.016095 ± 0.000135776 (W 5.31109e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `full_piv_lu/n64/b1` | 0.0906645 ± 0.00024556 (W 0.000342724) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n96/b1` | 0.265134 ± 0.000239069 (W 0.00177374) | - | - | `*` one row has no measurement here |
| `householder_apply/n32/b1 [block(basis=32,target=32)]` | 0.0117875 ± 0.000141239 (W 0.000267009) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n32/b1 [sequence(basis=32,target=32)]` | 0.0119675 ± 0.00017035 (W 0.00018702) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `householder_apply/n64/b1 [block(basis=64,target=64)]` | 0.03759 ± 0.000228924 (W 0.000485727) | - | - | `*` one row has no measurement here |
| `householder_apply/n64/b1 [sequence(basis=64,target=64)]` | 0.038071 ± 0.000352428 (W 0.000326012) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [block(basis=96,target=96)]` | 0.085745 ± 0.000422195 (W 0.00043001) | - | - | `*` one row has no measurement here |
| `householder_apply/n96/b1 [sequence(basis=96,target=96)]` | 0.0858705 ± 0.000165409 (W 0.000364715) | - | - | `*` one row has no measurement here |
| `lu/n32/b1` | 0.012203 ± 0.000138203 (W 0.000136303) | 0.0127285 ± 6.89367e-05 (W 7.57719e-05) | · | dispatch-dominated (row under 20 us) |
| `lu/n64/b1` | 0.0526835 ± 0.000652922 (W 0.000698983) | 0.060137 ± 0.000269449 (W 0.000264394) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `lu/n96/b1` | 0.139965 ± 0.00144942 (W 0.00169966) | 0.164192 ± 0.000261535 (W 0.00165212) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `qr/n32/b1` | 0.068703 ± 0.000210704 (W 0.000283557) | 0.051922 ± 0.000344769 (W 0.000225268) | 🔴 faer-fork 1.32× slower than `lapack-openblas` |  |
| `qr/n64/b1` | 0.22299 ± 0.00100806 (W 0.00159579) | 0.24928 ± 0.00223757 (W 0.00181456) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `qr/n96/b1` | 0.413687 ± 0.00192993 (W 0.00220264) | 0.953844 ± 0.00217786 (W 0.00115234) | 🔵 faer-fork 2.31× faster than `lapack-openblas` |  |
| `qr_factor/n32/b1` | 0.0340285 ± 0.000279096 (W 0.000202208) | 0.0288835 ± 0.000195037 (W 0.000135405) | 🔴 faer-fork 1.18× slower than `lapack-openblas` |  |
| `qr_factor/n64/b1` | 0.137581 ± 0.000651806 (W 0.000995613) | 0.130503 ± 0.00109957 (W 0.000517594) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `qr_factor/n96/b1` | 0.271357 ± 0.00140222 (W 0.00156086) | 0.486762 ± 0.00161398 (W 0.00235451) | 🔵 faer-fork 1.79× faster than `lapack-openblas` |  |
| `solve/n32/b1` | 0.013149 ± 7.58958e-05 (W 4.94444e-05) | 0.0141915 ± 9.41929e-05 (W 9.02166e-05) | 🔵 faer-fork 1.08× faster than `lapack-openblas` | dispatch-dominated (row under 20 us) |
| `solve/n64/b1` | 0.054978 ± 0.00029228 (W 0.000122678) | 0.0645455 ± 0.000233436 (W 0.000146776) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `solve/n96/b1` | 0.142055 ± 0.00056623 (W 0.00103285) | 0.172342 ± 0.000325383 (W 0.00136194) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_thin/n32/b1` | 0.233401 ± 0.00710021 (W 0.00152391) | 0.225987 ± 0.000876121 (W 0.00188856) | · | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.11934 ± 0.00126681 (W 0.00169803) | 0.940384 ± 0.00554027 (W 0.0011337) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `svd_thin/n96/b1` | 2.67354 ± 0.00315905 (W 0.00418398) | 2.5293 ± 0.00650616 (W 0.00295321) | 🔴 faer-fork 1.06× slower than `lapack-openblas` |  |
| `svd_values/n32/b1` | 0.159463 ± 0.000436239 (W 0.00161604) | 0.102997 ± 0.000278486 (W 0.00156012) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n64/b1` | 0.62503 ± 0.000827673 (W 0.00172918) | 0.40242 ± 0.00278266 (W 0.00194233) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n96/b1` | 1.4795 ± 0.00301982 (W 0.0022319) | 1.35971 ± 0.00646059 (W 0.00282592) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `triangular_solve/n32/b1` | 0.0012475 ± 2.58895e-05 (W 3.25204e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n64/b1` | 0.00293 ± 8.61061e-05 (W 2.83582e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n96/b1` | 0.0052295 ± 0.000222118 (W 3.7235e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |

Not applicable to this population's shapes and reported as skipped: `eig/32`, `eig/64`, `eig/96`, `full_piv_lu/32`, `full_piv_lu/64`, `full_piv_lu/96`, `householder_apply/32`, `householder_apply/64`, `householder_apply/96`, `triangular_solve/32`, `triangular_solve/64`, `triangular_solve/96`, `upgrade_factor/32`, `upgrade_factor/64`, `upgrade_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0705765 ± 0.0019522 (W 0.000698085) | 0.156361 ± 0.00183087 (W 0.00311821) | 🔵 faer-fork 2.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.385263 ± 0.00898156 (W 0.00195894) | 0.99086 ± 0.00886693 (W 0.00802773) | 🔵 faer-fork 2.57× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 2.5172 ± 0.00357078 (W 0.00267716) | 5.94217 ± 0.0595632 (W 0.0177132) | 🔵 faer-fork 2.36× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.24602 ± 0.00220399 (W 0.00190176) | 1.87192 ± 0.00455534 (W 0.0111937) | 🔴 faer-fork 1.20× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.9426 ± 0.0534416 (W 0.00776306) | 9.12804 ± 0.0366525 (W 0.0131177) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 49.6137 ± 0.282702 (W 0.0321457) | 52.0766 ± 0.0676072 (W 0.0495119) | · |  |
| `full_piv_lu/n128/b1` | 0.315303 ± 0.00106839 (W 0.00205998) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.71825 ± 0.0108837 (W 0.00582135) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.8341 ± 0.227088 (W 0.044049) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.259308 ± 0.000324394 (W 0.00136103) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.260231 ± 0.000723511 (W 0.00173804) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.90295 ± 0.012334 (W 0.00320392) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.9094 ± 0.00872 (W 0.0040199) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 16.0001 ± 0.0597141 (W 0.0253501) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.9263 ± 0.0303309 (W 0.0234245) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.168685 ± 0.000823667 (W 0.0018115) | 0.206529 ± 0.0042939 (W 0.0035503) | 🔵 faer-fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.996165 ± 0.000829064 (W 0.00263561) | 1.36074 ± 0.00894403 (W 0.00498683) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 6.65444 ± 0.0367402 (W 0.0101168) | 8.19422 ± 0.0920016 (W 0.0188528) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.51996 ± 0.00154381 (W 0.00191879) | 0.864623 ± 0.0033274 (W 0.0063127) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.9039 ± 0.00630604 (W 0.00223421) | 4.36708 ± 0.0116896 (W 0.00886703) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 20.2092 ± 0.0281414 (W 0.0259442) | 30.6927 ± 0.134373 (W 0.0332535) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.33821 ± 0.00252661 (W 0.00166725) | 0.431361 ± 0.00614785 (W 0.00478791) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.62861 ± 0.00365059 (W 0.00306537) | 2.17324 ± 0.008218 (W 0.00502648) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.97884 ± 0.0470452 (W 0.00752173) | 14.4296 ± 0.0456652 (W 0.0125199) | 🔵 faer-fork 1.61× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.138367 ± 0.000306121 (W 0.00138581) | 0.201842 ± 0.00131064 (W 0.00610897) | 🔵 faer-fork 1.46× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.772433 ± 0.00227789 (W 0.00228483) | 1.13098 ± 0.00494828 (W 0.00183301) | 🔵 faer-fork 1.46× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.60072 ± 0.0142163 (W 0.0146743) | 7.08489 ± 0.0147696 (W 0.00604673) | 🔵 faer-fork 1.07× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.6941 ± 0.0132724 (W 0.00292631) | 3.1366 ± 0.0103514 (W 0.00864066) | 🔴 faer-fork 1.18× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.5148 ± 0.0407193 (W 0.0213456) | 17.561 ± 0.033158 (W 0.0186753) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 105.543 ± 0.396896 (W 0.0862849) | 120.577 ± 2.43796 (W 0.523366) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.68469 ± 0.00704 (W 0.00286485) | 1.34849 ± 0.00445175 (W 0.00474478) | 🔴 faer-fork 1.99× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.4922 ± 0.0392689 (W 0.0123749) | 7.93195 ± 0.033657 (W 0.00993073) | 🔴 faer-fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 66.2108 ± 0.385481 (W 0.0727217) | 55.5959 ± 0.9076 (W 0.326362) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0042175 ± 0.000134285 (W 5.56049e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012283 ± 0.00046599 (W 0.000111383) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0427145 ± 0.00168593 (W 0.000244618) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.071363 ± 0.000201485 (W 0.00111191) | 0.170913 ± 0.00343906 (W 0.00279892) | 🔵 faer-fork 2.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.303812 ± 0.00175309 (W 0.00357736) | 0.875198 ± 0.00871817 (W 0.00604091) | 🔵 faer-fork 2.88× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 1.40755 ± 0.00542991 (W 0.00545309) | 4.60778 ± 0.0454171 (W 0.0114739) | 🔵 faer-fork 3.27× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.15832 ± 0.0028175 (W 0.00208626) | 1.49414 ± 0.00361531 (W 0.00385243) | 🔴 faer-fork 1.44× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.53848 ± 0.0134483 (W 0.0160663) | 6.11283 ± 0.0200964 (W 0.0120273) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 26.0278 ± 0.589516 (W 0.627997) | 28.9533 ± 0.312187 (W 0.0481732) | 🔵 faer-fork 1.11× faster than `lapack-openblas` | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.313681 ± 0.00146933 (W 0.00186374) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.13863 ± 0.00645738 (W 0.00661524) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 12.0393 ± 0.0234947 (W 0.0149572) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.08326 ± 0.000527384 (W 0.00129661) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.083451 ± 0.000694205 (W 0.000959906) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.520806 ± 0.00328254 (W 0.00163789) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.521012 ± 0.00107577 (W 0.00161091) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.20195 ± 0.0116469 (W 0.00939328) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.16002 ± 0.0172487 (W 0.00647449) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.137526 ± 0.000883864 (W 0.00205201) | 0.204728 ± 0.00340324 (W 0.00513316) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.638836 ± 0.00523325 (W 0.00577832) | 1.04232 ± 0.00380276 (W 0.00407553) | 🔵 faer-fork 1.63× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 3.2463 ± 0.00632262 (W 0.0120553) | 5.60831 ± 0.0371702 (W 0.0130165) | 🔵 faer-fork 1.73× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.399475 ± 0.00164707 (W 0.00212966) | 0.899242 ± 0.00646925 (W 0.00726443) | 🔵 faer-fork 2.25× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.45694 ± 0.00417849 (W 0.00244574) | 3.55628 ± 0.0114554 (W 0.00848928) | 🔵 faer-fork 2.44× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 8.60093 ± 0.681851 (W 0.00879493) | 19.2627 ± 0.267666 (W 0.0271705) | 🔵 faer-fork 2.24× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.300579 ± 0.00218897 (W 0.00107592) | 0.44494 ± 0.00274391 (W 0.00488954) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.11583 ± 0.00603855 (W 0.00136053) | 1.75214 ± 0.00826895 (W 0.00427548) | 🔵 faer-fork 1.57× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 4.47679 ± 0.0408935 (W 0.00968516) | 9.48145 ± 0.0251747 (W 0.0109824) | 🔵 faer-fork 2.12× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.13723 ± 0.000954675 (W 0.00159858) | 0.169542 ± 0.00312885 (W 0.00548944) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.602784 ± 0.00450328 (W 0.00481534) | 0.789673 ± 0.00516555 (W 0.00327089) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 2.90982 ± 0.0132029 (W 0.0073919) | 4.48894 ± 0.0566339 (W 0.00643473) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 2.80289 ± 0.00862977 (W 0.0134964) | 3.09354 ± 0.00746327 (W 0.00620087) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 13.4214 ± 0.0748192 (W 0.0439718) | 14.9819 ± 0.122238 (W 0.0155216) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 55.7779 ± 0.0588671 (W 0.0497886) | 93.7011 ± 3.57671 (W 0.344079) | 🔵 faer-fork 1.68× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.17346 ± 0.00689731 (W 0.00586817) | 1.39846 ± 0.00683393 (W 0.00438551) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.6238 ± 0.024929 (W 0.0154612) | 7.58416 ± 0.0490228 (W 0.00787838) | 🔴 faer-fork 1.40× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 41.9488 ± 0.0174074 (W 0.0337753) | 49.4684 ± 0.557309 (W 0.0182181) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004223 ± 7.5473e-05 (W 6.23678e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.011732 ± 0.000155195 (W 4.68626e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.028348 ± 0.00201523 (W 0.00016939) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.070431 ± 0.00184884 (W 0.000888773) | 0.169095 ± 0.00171545 (W 0.00317198) | 🔵 faer-fork 2.40× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.30286 ± 0.00485391 (W 0.00198437) | 0.881021 ± 0.00597807 (W 0.004936) | 🔵 faer-fork 2.91× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 1.28921 ± 0.00772045 (W 0.0037608) | 4.48808 ± 0.0821421 (W 0.0105431) | 🔵 faer-fork 3.48× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.14544 ± 0.00313952 (W 0.00317083) | 1.43748 ± 0.00366938 (W 0.00437056) | 🔴 faer-fork 1.49× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.23551 ± 0.0153187 (W 0.00755274) | 5.71967 ± 0.0154595 (W 0.00779706) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 22.1702 ± 0.0242696 (W 0.0271692) | 25.2893 ± 0.195546 (W 0.0454053) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.312423 ± 0.00127269 (W 0.00185392) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.07592 ± 0.00994083 (W 0.00787282) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 10.9059 ± 0.0334142 (W 0.0140998) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.057858 ± 0.000587347 (W 0.00104268) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.058268 ± 0.000494789 (W 0.00141786) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.28382 ± 0.00251777 (W 0.00224015) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.28394 ± 0.00228215 (W 0.00236607) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.28181 ± 0.022969 (W 0.0158807) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.27344 ± 0.0105836 (W 0.00926906) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.138844 ± 0.000228144 (W 0.00121955) | 0.207056 ± 0.0032992 (W 0.00313976) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.61661 ± 0.00553578 (W 0.00356241) | 0.97955 ± 0.00558274 (W 0.0037446) | 🔵 faer-fork 1.59× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 3.00612 ± 0.0156321 (W 0.00833203) | 4.7241 ± 0.0337967 (W 0.0168449) | 🔵 faer-fork 1.57× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.383884 ± 0.000654347 (W 0.00164299) | 0.904078 ± 0.00739858 (W 0.00617737) | 🔵 faer-fork 2.36× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.22093 ± 0.00509428 (W 0.00221015) | 3.52529 ± 0.0164352 (W 0.00935624) | 🔵 faer-fork 2.89× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 6.77422 ± 0.0113175 (W 0.0114224) | 17.641 ± 0.0270138 (W 0.0298347) | 🔵 faer-fork 2.60× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.294743 ± 0.00146426 (W 0.00155594) | 0.448344 ± 0.00466437 (W 0.00543182) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.02877 ± 0.00291485 (W 0.00188683) | 1.74121 ± 0.00418365 (W 0.00469454) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 3.73951 ± 0.0153395 (W 0.00585241) | 8.71052 ± 0.0208996 (W 0.015346) | 🔵 faer-fork 2.33× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.13969 ± 0.000659854 (W 0.000700708) | 0.204983 ± 0.00349443 (W 0.0046263) | 🔵 faer-fork 1.47× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.582012 ± 0.00210746 (W 0.0028481) | 0.740909 ± 0.00874972 (W 0.00428335) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 2.64986 ± 0.0154852 (W 0.00770174) | 3.65313 ± 0.0298052 (W 0.0060977) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 2.77602 ± 0.0052908 (W 0.00459564) | 3.09523 ± 0.00531774 (W 0.00687557) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 13.2024 ± 0.0498 (W 0.0434013) | 14.7277 ± 0.0333246 (W 0.0151795) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 50.8028 ± 0.0564864 (W 0.0527855) | 89.9017 ± 2.00155 (W 0.101162) | 🔵 faer-fork 1.77× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.17045 ± 0.00418335 (W 0.00295421) | 1.40171 ± 0.00229492 (W 0.00502501) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.7004 ± 0.0267133 (W 0.0181566) | 7.6032 ± 0.0426542 (W 0.0110259) | 🔴 faer-fork 1.41× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 40.3696 ± 0.00885562 (W 0.0370027) | 49.2896 ± 0.601145 (W 0.0469894) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0040375 ± 0.00014423 (W 3.2804e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.01081 ± 0.000752693 (W 3.24691e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.025823 ± 0.00104591 (W 0.000313273) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0602125 ± 0.00207343 (W 0.00101191) | 0.0716895 ± 0.000633346 (W 0.000118628) | 🔵 faer-fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.317823 ± 0.0038426 (W 0.00185524) | 0.406607 ± 0.00155915 (W 0.00192742) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.06913 ± 0.00556617 (W 0.00182377) | 2.70479 ± 0.00666874 (W 0.00385617) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.24192 ± 0.00110315 (W 0.00255815) | 1.79607 ± 0.00742638 (W 0.00720461) | 🔴 faer-fork 1.25× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 9.89691 ± 0.0353963 (W 0.00697025) | 8.72979 ± 0.0198334 (W 0.01) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 49.1938 ± 0.274768 (W 0.0240254) | 49.4428 ± 0.232773 (W 0.0385468) | · |  |
| `full_piv_lu/n128/b1` | 0.290267 ± 0.00157921 (W 0.0021517) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.61178 ± 0.00976042 (W 0.010923) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 21.2313 ± 0.192558 (W 0.0329912) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.255191 ± 0.000430816 (W 0.00159607) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.256744 ± 0.000706783 (W 0.00176878) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.89048 ± 0.0119687 (W 0.00435913) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.88108 ± 0.0111378 (W 0.00341677) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 15.6975 ± 0.12772 (W 0.0196712) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 15.739 ± 0.0475406 (W 0.02339) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.128761 ± 0.0176447 (W 0.00138249) | 0.151568 ± 0.000766114 (W 0.00093492) | 🔵 faer-fork 1.18× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.891731 ± 0.00192868 (W 0.00226163) | 0.834777 ± 0.00134335 (W 0.00196036) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 6.11454 ± 0.0264766 (W 0.010067) | 5.15413 ± 0.051132 (W 0.0053221) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.490013 ± 0.000886473 (W 0.00198761) | 0.754052 ± 0.009247 (W 0.00203871) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.77887 ± 0.00370205 (W 0.00260277) | 4.10114 ± 0.0345027 (W 0.00656071) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 19.5949 ± 0.0966143 (W 0.0215635) | 27.0074 ± 0.234991 (W 0.032013) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.27569 ± 0.000820594 (W 0.00149575) | 0.374224 ± 0.00500317 (W 0.00159974) | 🔵 faer-fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.37422 ± 0.00722108 (W 0.00175557) | 1.89344 ± 0.0147409 (W 0.00426005) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 8.05753 ± 0.00614204 (W 0.00536333) | 12.54 ± 0.0623836 (W 0.0201408) | 🔵 faer-fork 1.56× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.111712 ± 0.000771694 (W 0.00146763) | 0.148242 ± 0.00092038 (W 0.00135739) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.663234 ± 0.00334878 (W 0.00241634) | 0.823443 ± 0.00294114 (W 0.00167481) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 6.04322 ± 0.0109796 (W 0.0118059) | 5.16406 ± 0.0708386 (W 0.00310189) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.69198 ± 0.00949386 (W 0.00298452) | 3.01875 ± 0.0109285 (W 0.00653014) | 🔴 faer-fork 1.22× slower than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.4123 ± 0.025738 (W 0.00986972) | 16.991 ± 0.0621389 (W 0.0188351) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 104.604 ± 0.374843 (W 0.271694) | 117.011 ± 0.30195 (W 0.150589) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.61223 ± 0.00598267 (W 0.00222026) | 1.28559 ± 0.00439305 (W 0.00176396) | 🔴 faer-fork 2.03× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.2964 ± 0.0275274 (W 0.00905083) | 7.67155 ± 0.0388396 (W 0.00825457) | 🔴 faer-fork 1.60× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 65.3111 ± 0.33628 (W 0.0371123) | 53.1401 ± 0.270986 (W 0.0506302) | 🔴 faer-fork 1.23× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004534 ± 2.32444e-05 (W 4.90664e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0135805 ± 0.000756959 (W 6.72076e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0472075 ± 0.00257256 (W 0.000363236) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.0647455 ± 0.00171989 (W 0.000706788) | 0.0790975 ± 0.00282059 (W 0.000724012) | 🔵 faer-fork 1.22× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.240513 ± 0.00490217 (W 0.00289819) | 0.285937 ± 0.00943422 (W 0.00189972) | 🔵 faer-fork 1.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 0.956408 ± 0.00498128 (W 0.00333982) | 1.34437 ± 0.0221678 (W 0.00563209) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.15529 ± 0.00681287 (W 0.00192695) | 1.42059 ± 0.00384689 (W 0.00338733) | 🔴 faer-fork 1.52× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.49369 ± 0.0144081 (W 0.00849244) | 5.66045 ± 0.00918133 (W 0.00763816) | 🔴 faer-fork 1.15× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 25.6589 ± 0.557919 (W 0.617053) | 26.1527 ± 0.233746 (W 0.0185982) | · | `!` between-start range over 5% |
| `full_piv_lu/n128/b1` | 0.288713 ± 0.00204665 (W 0.00188603) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 2.03739 ± 0.00794207 (W 0.00848103) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 11.6104 ± 0.0264603 (W 0.0298726) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.0831 ± 0.000319658 (W 0.000664401) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.083551 ± 0.00032986 (W 0.00102263) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.522255 ± 0.00260363 (W 0.00192862) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.532183 ± 0.00174598 (W 0.00238584) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 4.20382 ± 0.0142686 (W 0.00695076) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 4.15391 ± 0.0124442 (W 0.00672752) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.115256 ± 0.00138448 (W 0.00173275) | 0.151072 ± 0.000411745 (W 0.000328791) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.533022 ± 0.00208844 (W 0.00521923) | 0.506857 ± 0.00123236 (W 0.00228022) | 🔴 faer-fork 1.05× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 2.78596 ± 0.010011 (W 0.00798714) | 2.69788 ± 0.0744182 (W 0.00476108) | · | `!` between-start range over 5% |
| `qr/n128/b1` | 0.37065 ± 0.00181427 (W 0.00203389) | 0.810663 ± 0.0144833 (W 0.00611194) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.3377 ± 0.00325476 (W 0.00173118) | 3.25769 ± 0.0108592 (W 0.00919226) | 🔵 faer-fork 2.44× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 7.95494 ± 0.639768 (W 0.00917317) | 16.9612 ± 0.0762467 (W 0.0154934) | 🔵 faer-fork 2.13× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/n128/b1` | 0.23875 ± 0.000899641 (W 0.00148836) | 0.398092 ± 0.000912645 (W 0.00161894) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 0.858314 ± 0.00266967 (W 0.00178047) | 1.46472 ± 0.00482583 (W 0.00295261) | 🔵 faer-fork 1.71× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 3.47081 ± 0.00781648 (W 0.00637784) | 7.60203 ± 0.0359946 (W 0.0154409) | 🔵 faer-fork 2.19× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.11224 ± 0.0017561 (W 0.00168559) | 0.1153 ± 0.000832471 (W 0.00147061) | · |  |
| `solve/n256/b1` | 0.49847 ± 0.00143434 (W 0.00411703) | 0.490206 ± 0.00355271 (W 0.00207789) | · |  |
| `solve/n512/b1` | 2.46028 ± 0.00805174 (W 0.00653988) | 2.57899 ± 0.0625191 (W 0.00538786) | · | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 2.79623 ± 0.0129127 (W 0.0149064) | 2.9775 ± 0.00595945 (W 0.00491516) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 13.3451 ± 0.0821049 (W 0.0618967) | 14.3634 ± 0.0471442 (W 0.0207785) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 54.859 ± 0.049621 (W 0.0530584) | 89.1873 ± 0.698698 (W 0.0888567) | 🔵 faer-fork 1.63× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.11217 ± 0.0100071 (W 0.0068748) | 1.34868 ± 0.00848525 (W 0.00184942) | 🔴 faer-fork 1.57× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.4111 ± 0.0384254 (W 0.0202804) | 7.39534 ± 0.0303829 (W 0.00797526) | 🔴 faer-fork 1.41× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 40.967 ± 0.0416467 (W 0.0318202) | 48.4565 ± 0.554369 (W 0.0528721) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.004819 ± 6.8313e-05 (W 5.02991e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.013796 ± 0.000429378 (W 6.42456e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.036238 ± 0.000280149 (W 0.000228787) | - | - | `*` one row has no measurement here |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.064119 ± 0.00148174 (W 0.00069212) | 0.078852 ± 0.00278722 (W 0.000652665) | 🔵 faer-fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.241229 ± 0.00534012 (W 0.00190167) | 0.28149 ± 0.0034355 (W 0.00260923) | 🔵 faer-fork 1.17× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n512/b1` | 0.839951 ± 0.00419578 (W 0.00363477) | 1.21712 ± 0.00538091 (W 0.00396911) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.13973 ± 0.00266613 (W 0.0025795) | 1.36166 ± 0.00452577 (W 0.00346012) | 🔴 faer-fork 1.57× slower than `lapack-openblas` |  |
| `eigh/n256/b1` | 6.19624 ± 0.0160958 (W 0.011249) | 5.28273 ± 0.0184344 (W 0.00822736) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `eigh/n512/b1` | 21.7879 ± 0.0318666 (W 0.0211463) | 22.5004 ± 0.0816552 (W 0.0388164) | · |  |
| `full_piv_lu/n128/b1` | 0.288158 ± 0.00125286 (W 0.00169854) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 1.96749 ± 0.00307162 (W 0.00563028) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 10.4105 ± 0.0164184 (W 0.0178413) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.055358 ± 0.000464286 (W 0.000565227) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.055734 ± 0.000493281 (W 0.000925202) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.28382 ± 0.00230654 (W 0.00184459) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 0.290616 ± 0.0012774 (W 0.00209042) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 2.28972 ± 0.01135 (W 0.0106333) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 2.24977 ± 0.00566816 (W 0.00768088) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.116041 ± 0.000423071 (W 0.00151269) | 0.150906 ± 0.00067942 (W 0.00148573) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 0.51749 ± 0.00152238 (W 0.00184377) | 0.44001 ± 0.011295 (W 0.00244157) | 🔴 faer-fork 1.18× slower than `lapack-openblas` | `!` between-start range over 5% |
| `lu/n512/b1` | 2.54234 ± 0.00836311 (W 0.00556813) | 1.82939 ± 0.0710411 (W 0.00660818) | 🔴 faer-fork 1.39× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/n128/b1` | 0.353187 ± 0.00142177 (W 0.00145027) | 0.832179 ± 0.0115029 (W 0.00382144) | 🔵 faer-fork 2.36× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 1.10029 ± 0.00188144 (W 0.00236173) | 3.23308 ± 0.037585 (W 0.00715755) | 🔵 faer-fork 2.94× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 6.13424 ± 0.111487 (W 0.0157943) | 15.3689 ± 0.145897 (W 0.0323764) | 🔵 faer-fork 2.51× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.231486 ± 0.000585888 (W 0.00155765) | 0.398767 ± 0.00329989 (W 0.00149391) | 🔵 faer-fork 1.72× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 0.771889 ± 0.00151011 (W 0.0027751) | 1.45062 ± 0.0120895 (W 0.00501521) | 🔵 faer-fork 1.88× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 2.75402 ± 0.00524363 (W 0.00279087) | 6.84341 ± 0.0601497 (W 0.0182927) | 🔵 faer-fork 2.48× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.11275 ± 0.00100759 (W 0.00142114) | 0.150079 ± 0.00124653 (W 0.00176719) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 0.477328 ± 0.00218077 (W 0.00277619) | 0.448952 ± 0.0112698 (W 0.00261716) | 🔴 faer-fork 1.06× slower than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 2.20028 ± 0.00193968 (W 0.0045149) | 1.73898 ± 0.0596073 (W 0.00717902) | 🔴 faer-fork 1.27× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 2.74928 ± 0.00434484 (W 0.00511496) | 2.97134 ± 0.0102008 (W 0.00557417) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 13.0576 ± 0.0693135 (W 0.0206102) | 14.1783 ± 0.0827242 (W 0.0137167) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 49.9264 ± 0.164234 (W 0.060586) | 84.3452 ± 1.17532 (W 0.118692) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.10934 ± 0.00498993 (W 0.00312528) | 1.35169 ± 0.00383475 (W 0.00253466) | 🔴 faer-fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 10.5392 ± 0.0293364 (W 0.0145105) | 7.35457 ± 0.0358426 (W 0.0105006) | 🔴 faer-fork 1.43× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 39.3707 ± 0.0503265 (W 0.0370573) | 47.6875 ± 0.259933 (W 0.0545242) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0046185 ± 0.000257838 (W 4.31857e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.012203 ± 0.0010319 (W 0.000101581) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n512/b1` | 0.0314285 ± 0.00195882 (W 0.000746697) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.188892 ± 0.000593705 (W 0.00105479) | 0.331835 ± 0.00427856 (W 0.00290463) | 🔵 faer-fork 1.76× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 1.22863 ± 0.012933 (W 0.00196854) | 2.11449 ± 0.011407 (W 0.00620798) | 🔵 faer-fork 1.72× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.9155 ± 0.0109177 (W 0.00836285) | 12.577 ± 0.091864 (W 0.0137783) | 🔵 faer-fork 1.59× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.27086 ± 0.00375669 (W 0.00308027) | 3.36572 ± 0.00828522 (W 0.00520275) | · |  |
| `eigh/n256/b1` | 17.6316 ± 0.0315853 (W 0.0128358) | 20.173 ± 0.0557441 (W 0.0102153) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 106.108 ± 0.153083 (W 0.126893) | 140.981 ± 0.198947 (W 0.190407) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.780437 ± 0.00416633 (W 0.00293499) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.92237 ± 0.034109 (W 0.0100794) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 40.4348 ± 0.088038 (W 0.0256456) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.04954 ± 0.0031166 (W 0.000764155) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.05058 ± 0.00226381 (W 0.000908259) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.49956 ± 0.0205215 (W 0.00781881) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.51853 ± 0.0134158 (W 0.0093009) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.7608 ± 0.100887 (W 0.0357351) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.7821 ± 0.171881 (W 0.0433229) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.326624 ± 0.00129173 (W 0.00234762) | 0.424978 ± 0.00477813 (W 0.00443379) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.11709 ± 0.00497399 (W 0.00610922) | 2.77377 ± 0.0120266 (W 0.00366385) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 14.6828 ± 0.0433304 (W 0.0273013) | 18.3473 ± 0.0638934 (W 0.0312007) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.5707 ± 0.00308071 (W 0.0027082) | 1.63174 ± 0.0077028 (W 0.00525672) | · |  |
| `qr/n256/b1` | 10.1543 ± 0.0151801 (W 0.00491442) | 11.311 ± 0.0198233 (W 0.00811408) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 69.6948 ± 0.109804 (W 0.0473554) | 75.0817 ± 0.545087 (W 0.162193) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.817609 ± 0.00285061 (W 0.00141432) | 0.823331 ± 0.00470849 (W 0.00330093) | · |  |
| `qr_factor/n256/b1` | 4.79927 ± 0.00743822 (W 0.00481986) | 5.65407 ± 0.0117111 (W 0.00744472) | 🔵 faer-fork 1.18× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 30.6165 ± 0.0494733 (W 0.035035) | 37.2782 ± 0.124811 (W 0.0515367) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.32409 ± 0.00140083 (W 0.00213914) | 0.451102 ± 0.00215111 (W 0.0033127) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 2.06001 ± 0.00396387 (W 0.00202975) | 2.85585 ± 0.0213352 (W 0.00524874) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 14.6649 ± 0.030283 (W 0.0196588) | 18.5304 ± 0.0727168 (W 0.0160128) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.75136 ± 0.0213848 (W 0.00737234) | 5.67141 ± 0.034341 (W 0.00728875) | · |  |
| `svd_thin/n256/b1` | 34.166 ± 0.0392159 (W 0.035626) | 36.9957 ± 0.176317 (W 0.0419397) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 210.106 ± 0.503525 (W 0.303063) | 235.188 ± 0.911842 (W 0.399828) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.47212 ± 0.00489212 (W 0.00562627) | 2.29151 ± 0.00673253 (W 0.00429942) | 🔴 faer-fork 1.52× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.3371 ± 0.0589252 (W 0.0246137) | 16.1756 ± 0.0923084 (W 0.0257922) | 🔴 faer-fork 1.20× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 110.851 ± 0.159806 (W 0.106935) | 100.895 ± 1.05885 (W 0.443965) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.007644 ± 5.4191e-05 (W 3.8729e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.023614 ± 0.000297763 (W 7.51959e-05) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.0858855 ± 0.000657925 (W 0.00109117) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.168378 ± 0.000942944 (W 0.00166327) | 0.271231 ± 0.00673267 (W 0.00231152) | 🔵 faer-fork 1.61× faster than `lapack-openblas` | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.78503 ± 0.00350231 (W 0.0104289) | 1.42744 ± 0.025413 (W 0.00553321) | 🔵 faer-fork 1.82× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 3.18218 ± 0.00854635 (W 0.0153191) | 7.01827 ± 0.0252264 (W 0.0121944) | 🔵 faer-fork 2.21× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.67935 ± 0.00899967 (W 0.0050269) | 2.65787 ± 0.00894315 (W 0.00419347) | · |  |
| `eigh/n256/b1` | 8.84951 ± 0.0128412 (W 0.0114463) | 12.0977 ± 0.0441697 (W 0.0113342) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 41.6502 ± 0.0348669 (W 0.123825) | 55.5856 ± 0.139038 (W 0.0439738) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.712333 ± 0.00654129 (W 0.00621874) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.60353 ± 0.0107964 (W 0.00958138) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 17.7322 ± 0.0434426 (W 0.027319) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.286044 ± 0.00170767 (W 0.00197181) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.284767 ± 0.00122906 (W 0.0009659) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91976 ± 0.00248174 (W 0.00289851) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.94286 ± 0.00551023 (W 0.00352481) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.5718 ± 0.0355479 (W 0.0123635) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6142 ± 0.0296698 (W 0.0112539) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.291319 ± 0.00126952 (W 0.00203455) | 0.310009 ± 0.001734 (W 0.00290538) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 1.37219 ± 0.00851851 (W 0.0097338) | 1.71315 ± 0.00380768 (W 0.00288434) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 6.76773 ± 0.015655 (W 0.0230808) | 7.40898 ± 0.0152354 (W 0.0159081) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 0.812478 ± 0.00238311 (W 0.00195176) | 1.47084 ± 0.00369674 (W 0.00339506) | 🔵 faer-fork 1.81× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.893 ± 0.00933423 (W 0.005019) | 7.13726 ± 0.0491808 (W 0.00638373) | 🔵 faer-fork 1.83× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 22.1375 ± 0.0234816 (W 0.0423293) | 35.4438 ± 0.503152 (W 0.0658488) | 🔵 faer-fork 1.60× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.536843 ± 0.00210258 (W 0.00217938) | 0.738212 ± 0.00349005 (W 0.00239454) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.45029 ± 0.00464727 (W 0.00382959) | 3.56312 ± 0.0247192 (W 0.00664421) | 🔵 faer-fork 1.45× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 11.9959 ± 0.0410951 (W 0.024026) | 17.134 ± 0.0325199 (W 0.015829) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.283994 ± 0.00123664 (W 0.00183673) | 0.30887 ± 0.00300753 (W 0.0034126) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.2817 ± 0.00790798 (W 0.0101804) | 1.68227 ± 0.0394167 (W 0.00408612) | 🔵 faer-fork 1.31× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 6.59133 ± 0.015823 (W 0.0170315) | 7.40568 ± 0.0476763 (W 0.0156978) | 🔵 faer-fork 1.12× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.92524 ± 0.0165422 (W 0.0159195) | 4.8447 ± 0.0225453 (W 0.0102151) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.6057 ± 0.0582747 (W 0.0284104) | 23.4664 ± 0.0487595 (W 0.0430997) | 🔵 faer-fork 1.26× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 84.3954 ± 0.222209 (W 0.167502) | 118.962 ± 0.483898 (W 0.0947806) | 🔵 faer-fork 1.41× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.8852 ± 0.0114335 (W 0.00473009) | 2.49158 ± 0.00812777 (W 0.00779558) | 🔴 faer-fork 1.16× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 13.2765 ± 0.0196745 (W 0.0222197) | 12.0679 ± 0.0327929 (W 0.016935) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 54.6662 ± 0.115578 (W 0.0788976) | 54.2429 ± 0.253842 (W 0.053187) | · |  |
| `triangular_solve/n128/b1` | 0.008095 ± 5.04975e-05 (W 5.04562e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0247365 ± 0.000238263 (W 0.000123544) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.062211 ± 0.000515429 (W 0.00100246) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.167898 ± 0.000272705 (W 0.00149278) | 0.298776 ± 0.00198382 (W 0.00312587) | 🔵 faer-fork 1.78× faster than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.721642 ± 0.0133149 (W 0.00341103) | 1.36811 ± 0.0192685 (W 0.00433975) | 🔵 faer-fork 1.90× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.56986 ± 0.0119417 (W 0.0124152) | 5.89853 ± 0.0465637 (W 0.0105754) | 🔵 faer-fork 2.30× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.5752 ± 0.00313886 (W 0.0096799) | 2.5752 ± 0.0238106 (W 0.00500676) | · |  |
| `eigh/n256/b1` | 7.8221 ± 0.0193782 (W 0.00826924) | 10.8499 ± 0.0528407 (W 0.0103694) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 31.3864 ± 0.0505698 (W 0.0220716) | 43.2695 ± 0.0939502 (W 0.0300388) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.703774 ± 0.002665 (W 0.00621252) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.29097 ± 0.0106141 (W 0.010143) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 14.2934 ± 0.0251482 (W 0.0383701) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.17752 ± 0.00108409 (W 0.00130389) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.178156 ± 0.0004609 (W 0.00109124) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.998106 ± 0.00286185 (W 0.00295807) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.01443 ± 0.0027696 (W 0.00272474) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 7.92815 ± 0.0464321 (W 0.0426425) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 7.92433 ± 0.023422 (W 0.041023) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.290909 ± 0.00143391 (W 0.00202302) | 0.302635 ± 0.00339984 (W 0.00238551) | · |  |
| `lu/n256/b1` | 1.26611 ± 0.00204916 (W 0.00448208) | 1.33843 ± 0.0227245 (W 0.00347897) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 5.48169 ± 0.0220953 (W 0.0149101) | 5.10849 ± 0.0241039 (W 0.00974987) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.687478 ± 0.00244785 (W 0.00247426) | 1.46001 ± 0.00893088 (W 0.00509687) | 🔵 faer-fork 2.12× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.90718 ± 0.00769041 (W 0.00472797) | 6.53928 ± 0.0203407 (W 0.0119912) | 🔵 faer-fork 2.25× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 14.3898 ± 0.0319583 (W 0.0236914) | 28.3261 ± 0.0715185 (W 0.0270991) | 🔵 faer-fork 1.97× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.495984 ± 0.00194468 (W 0.00209559) | 0.733296 ± 0.00707347 (W 0.00431731) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.12282 ± 0.00857459 (W 0.00278783) | 3.2312 ± 0.00408707 (W 0.00552088) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 9.14549 ± 0.0963638 (W 0.0219116) | 13.8613 ± 0.0502293 (W 0.0208068) | 🔵 faer-fork 1.52× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.28456 ± 0.00157944 (W 0.00239073) | 0.300074 ± 0.00514309 (W 0.00238568) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.16679 ± 0.00305869 (W 0.00392633) | 1.32579 ± 0.0238109 (W 0.00495975) | 🔵 faer-fork 1.14× faster than `lapack-openblas` | `!` between-start range over 5% |
| `solve/n512/b1` | 5.24577 ± 0.024968 (W 0.0217168) | 5.11641 ± 0.0213833 (W 0.0127883) | · |  |
| `svd_thin/n128/b1` | 3.7635 ± 0.0120886 (W 0.0053566) | 4.80157 ± 0.0119978 (W 0.00753847) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 16.8586 ± 0.0332703 (W 0.0235567) | 21.8477 ± 0.0529045 (W 0.0217825) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 66.8555 ± 0.181824 (W 0.454696) | 99.6669 ± 0.767968 (W 0.241332) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.91619 ± 0.0107431 (W 0.0051745) | 2.58631 ± 0.0103662 (W 0.00612172) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.9115 ± 0.0161852 (W 0.0168819) | 11.9168 ± 0.0342555 (W 0.0155015) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 47.9276 ± 0.187054 (W 0.0826538) | 48.2345 ± 0.326115 (W 0.0499519) | · |  |
| `triangular_solve/n128/b1` | 0.008015 ± 9.68848e-05 (W 4.66657e-05) | - | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.0247305 ± 0.00033596 (W 0.000676039) | - | - | `*` one row has no measurement here |
| `triangular_solve/n512/b1` | 0.058629 ± 0.00039116 (W 0.000447254) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.176604 ± 0.000404194 (W 0.00116789) | 0.183863 ± 0.000489274 (W 0.00134392) | · |  |
| `cholesky/n256/b1` | 1.13733 ± 0.000815443 (W 0.00168015) | 1.29219 ± 0.00121931 (W 0.00294221) | 🔵 faer-fork 1.14× faster than `lapack-openblas` |  |
| `cholesky/n512/b1` | 7.54902 ± 0.0102552 (W 0.00749751) | 9.00083 ± 0.0199458 (W 0.0110597) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 3.26126 ± 0.00443614 (W 0.00224581) | 3.24146 ± 0.0051329 (W 0.00264877) | · |  |
| `eigh/n256/b1` | 17.5387 ± 0.0271608 (W 0.0196601) | 19.4975 ± 0.0360223 (W 0.00994879) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 105.703 ± 0.138269 (W 0.0696441) | 139.823 ± 1.6453 (W 0.0931588) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.757324 ± 0.0039185 (W 0.00602966) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 5.78991 ± 0.0348121 (W 0.00797409) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 39.6313 ± 0.123101 (W 0.0440243) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 1.03438 ± 0.00161873 (W 0.000632509) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 1.03944 ± 0.00115814 (W 0.00113404) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 7.39893 ± 0.01533 (W 0.00683351) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 7.41733 ± 0.0229833 (W 0.00592329) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 56.8121 ± 0.0460021 (W 0.237919) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 56.6554 ± 0.0616987 (W 0.0609721) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.30057 ± 0.00244646 (W 0.00251689) | 0.34895 ± 0.00177922 (W 0.00195712) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `lu/n256/b1` | 2.0097 ± 0.00754111 (W 0.00193255) | 2.33896 ± 0.0241861 (W 0.00320779) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `lu/n512/b1` | 13.8628 ± 0.0223395 (W 0.0152489) | 16.2573 ± 0.0635589 (W 0.0162767) | 🔵 faer-fork 1.17× faster than `lapack-openblas` |  |
| `qr/n128/b1` | 1.54494 ± 0.00184286 (W 0.00192437) | 1.54378 ± 0.00892339 (W 0.00281869) | · |  |
| `qr/n256/b1` | 10.0467 ± 0.0270031 (W 0.00611675) | 10.8279 ± 0.1219 (W 0.00890974) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 68.7449 ± 0.086421 (W 0.0288079) | 72.4934 ± 0.350194 (W 0.0626726) | 🔵 faer-fork 1.05× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.746279 ± 0.00709216 (W 0.00154316) | 0.751047 ± 0.0037101 (W 0.00189806) | · |  |
| `qr_factor/n256/b1` | 4.48889 ± 0.0291068 (W 0.00391182) | 5.21634 ± 0.0417928 (W 0.00830937) | 🔵 faer-fork 1.16× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 28.6735 ± 0.248148 (W 0.0124896) | 35.2864 ± 0.0938662 (W 0.0180496) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.29777 ± 0.0013923 (W 0.00195656) | 0.363903 ± 0.000660482 (W 0.00220107) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `solve/n256/b1` | 1.94873 ± 0.00359288 (W 0.00129223) | 2.38669 ± 0.00554412 (W 0.00282391) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 13.8539 ± 0.0254876 (W 0.0180754) | 16.4739 ± 0.0347298 (W 0.0164144) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 5.7166 ± 0.0191894 (W 0.00660845) | 5.50698 ± 0.0192349 (W 0.00826823) | · |  |
| `svd_thin/n256/b1` | 33.8392 ± 0.0540229 (W 0.038683) | 35.7342 ± 0.1398 (W 0.0355484) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 208.879 ± 0.605693 (W 0.475881) | 230.999 ± 2.27416 (W 0.527998) | 🔵 faer-fork 1.11× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 3.45496 ± 0.00528917 (W 0.00376017) | 2.21502 ± 0.00764535 (W 0.00387419) | 🔴 faer-fork 1.56× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 19.0599 ± 0.0759606 (W 0.0196221) | 15.697 ± 0.125845 (W 0.0184023) | 🔴 faer-fork 1.21× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 109.698 ± 0.158185 (W 0.0807337) | 97.601 ± 1.31381 (W 0.238995) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `triangular_solve/n128/b1` | 0.0073285 ± 0.000247735 (W 3.76226e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022637 ± 0.00100764 (W 0.0001255) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.0848535 ± 0.00153566 (W 0.000797893) | - | - | `*` one row has no measurement here |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.155871 ± 0.00106653 (W 0.00136519) | 0.124723 ± 0.00114954 (W 0.00140314) | 🔴 faer-fork 1.25× slower than `lapack-openblas` |  |
| `cholesky/n256/b1` | 0.687724 ± 0.010233 (W 0.012113) | 0.592164 ± 0.00258824 (W 0.00275756) | 🔴 faer-fork 1.16× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.81199 ± 0.0120684 (W 0.0144387) | 3.49785 ± 0.00407451 (W 0.00784383) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.68309 ± 0.0027853 (W 0.00379225) | 2.55292 ± 0.0116052 (W 0.00337722) | · |  |
| `eigh/n256/b1` | 8.77408 ± 0.00914922 (W 0.0133931) | 11.428 ± 0.0472213 (W 0.0099405) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 41.4434 ± 0.0886015 (W 0.356792) | 52.7224 ± 0.139503 (W 0.0352005) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.689786 ± 0.00404036 (W 0.00577297) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.46015 ± 0.0117508 (W 0.00787689) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 16.9768 ± 0.0244932 (W 0.0227868) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.28166 ± 0.000512938 (W 0.000564356) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.285994 ± 0.00146459 (W 0.000703694) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 1.91452 ± 0.00737608 (W 0.00228057) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.93922 ± 0.0092557 (W 0.00220512) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 14.6886 ± 0.0292915 (W 0.0258136) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 14.6655 ± 0.0247301 (W 0.0125535) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.265966 ± 0.000986904 (W 0.00212133) | 0.240457 ± 0.00180669 (W 0.00156643) | 🔴 faer-fork 1.11× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.2709 ± 0.00400512 (W 0.0115613) | 1.26582 ± 0.00182978 (W 0.00255296) | · |  |
| `lu/n512/b1` | 5.97558 ± 0.0160934 (W 0.0133967) | 5.5242 ± 0.00279162 (W 0.00948773) | 🔴 faer-fork 1.08× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.786361 ± 0.00252482 (W 0.00171011) | 1.38603 ± 0.00971507 (W 0.00340827) | 🔵 faer-fork 1.76× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 3.77783 ± 0.0137251 (W 0.0048264) | 6.59869 ± 0.0419968 (W 0.00927202) | 🔵 faer-fork 1.75× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 21.2049 ± 0.013281 (W 0.0147793) | 32.424 ± 0.066747 (W 0.0271276) | 🔵 faer-fork 1.53× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.464793 ± 0.00189524 (W 0.00176682) | 0.662707 ± 0.00248194 (W 0.00210325) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 2.16189 ± 0.00748759 (W 0.00314123) | 3.09629 ± 0.00697818 (W 0.00618873) | 🔵 faer-fork 1.43× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 10.4338 ± 0.0152365 (W 0.00900693) | 15.3016 ± 0.0554073 (W 0.0168716) | 🔵 faer-fork 1.47× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.258618 ± 0.000368846 (W 0.00177618) | 0.237847 ± 0.00137081 (W 0.00154906) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.18963 ± 0.0127009 (W 0.0108244) | 1.26148 ± 0.00256399 (W 0.00276518) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `solve/n512/b1` | 5.77561 ± 0.0204747 (W 0.0158045) | 5.50741 ± 0.0239262 (W 0.00602271) | · |  |
| `svd_thin/n128/b1` | 3.91019 ± 0.00971357 (W 0.0154551) | 4.66364 ± 0.0139747 (W 0.00464153) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 18.3558 ± 0.0388666 (W 0.0406952) | 22.4876 ± 0.12748 (W 0.0309198) | 🔵 faer-fork 1.23× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 83.2005 ± 0.155867 (W 0.166978) | 114.191 ± 0.332768 (W 0.0538682) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.86091 ± 0.0129338 (W 0.00431096) | 2.40806 ± 0.0154663 (W 0.00514212) | 🔴 faer-fork 1.19× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 13.0736 ± 0.0308457 (W 0.0294684) | 11.6563 ± 0.0470144 (W 0.0189118) | 🔴 faer-fork 1.12× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 53.5848 ± 0.0258338 (W 0.0775395) | 51.9663 ± 0.154304 (W 0.0423206) | · |  |
| `triangular_solve/n128/b1` | 0.007914 ± 0.00024042 (W 4.6958e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.022612 ± 0.0010408 (W 0.000131148) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.0619905 ± 0.00144571 (W 0.000195869) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `cholesky/n128/b1` | 0.155214 ± 0.000177398 (W 0.000766674) | 0.161311 ± 0.00566572 (W 0.00165803) | · | `!` between-start range over 5% |
| `cholesky/n256/b1` | 0.62749 ± 0.00197168 (W 0.00262758) | 0.550798 ± 0.0049174 (W 0.00275203) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `cholesky/n512/b1` | 2.20107 ± 0.00717003 (W 0.0106885) | 2.40141 ± 0.00689886 (W 0.00435054) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `eigh/n128/b1` | 2.56643 ± 0.00637148 (W 0.00344872) | 2.46214 ± 0.0197661 (W 0.00355582) | · |  |
| `eigh/n256/b1` | 7.73685 ± 0.0182711 (W 0.0094837) | 10.2144 ± 0.0684566 (W 0.0108426) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `eigh/n512/b1` | 31.0302 ± 0.0505466 (W 0.0228407) | 40.3753 ± 0.0513175 (W 0.0334087) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `full_piv_lu/n128/b1` | 0.677431 ± 0.00389772 (W 0.00276724) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n256/b1` | 3.15459 ± 0.0170061 (W 0.0106292) | - | - | `*` one row has no measurement here |
| `full_piv_lu/n512/b1` | 13.5423 ± 0.0490004 (W 0.0239376) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [block(basis=128,target=128)]` | 0.177371 ± 0.000765379 (W 0.00134585) | - | - | `*` one row has no measurement here |
| `householder_apply/n128/b1 [sequence(basis=128,target=128)]` | 0.178594 ± 0.00105949 (W 0.00114598) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [block(basis=256,target=256)]` | 0.99931 ± 0.00476644 (W 0.00282104) | - | - | `*` one row has no measurement here |
| `householder_apply/n256/b1 [sequence(basis=256,target=256)]` | 1.02045 ± 0.00266097 (W 0.00262104) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [block(basis=512,target=512)]` | 8.11234 ± 0.03685 (W 0.0635687) | - | - | `*` one row has no measurement here |
| `householder_apply/n512/b1 [sequence(basis=512,target=512)]` | 8.10101 ± 0.0191959 (W 0.0253121) | - | - | `*` one row has no measurement here |
| `lu/n128/b1` | 0.265771 ± 0.000537035 (W 0.00207714) | 0.226446 ± 0.000612336 (W 0.00140566) | 🔴 faer-fork 1.17× slower than `lapack-openblas` |  |
| `lu/n256/b1` | 1.16571 ± 0.00318784 (W 0.00523214) | 0.887872 ± 0.00254747 (W 0.00266612) | 🔴 faer-fork 1.31× slower than `lapack-openblas` |  |
| `lu/n512/b1` | 4.67954 ± 0.0203115 (W 0.0156006) | 3.27745 ± 0.0260842 (W 0.0072154) | 🔴 faer-fork 1.43× slower than `lapack-openblas` |  |
| `qr/n128/b1` | 0.663137 ± 0.00211601 (W 0.00186126) | 1.36085 ± 0.00914189 (W 0.00416527) | 🔵 faer-fork 2.05× faster than `lapack-openblas` |  |
| `qr/n256/b1` | 2.80699 ± 0.00710826 (W 0.00367513) | 5.97653 ± 0.0209171 (W 0.00719007) | 🔵 faer-fork 2.13× faster than `lapack-openblas` |  |
| `qr/n512/b1` | 13.4851 ± 0.0386812 (W 0.0120451) | 26.0249 ± 0.0749296 (W 0.0238708) | 🔵 faer-fork 1.93× faster than `lapack-openblas` |  |
| `qr_factor/n128/b1` | 0.423801 ± 0.00181067 (W 0.00185672) | 0.656178 ± 0.00427347 (W 0.00127805) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `qr_factor/n256/b1` | 1.82858 ± 0.00378592 (W 0.00287764) | 2.79317 ± 0.00556177 (W 0.004246) | 🔵 faer-fork 1.53× faster than `lapack-openblas` |  |
| `qr_factor/n512/b1` | 7.46419 ± 0.0185657 (W 0.00798195) | 12.0536 ± 0.0444031 (W 0.0134396) | 🔵 faer-fork 1.61× faster than `lapack-openblas` |  |
| `solve/n128/b1` | 0.256929 ± 0.00128374 (W 0.00133811) | 0.22838 ± 0.00205778 (W 0.00208532) | 🔴 faer-fork 1.13× slower than `lapack-openblas` |  |
| `solve/n256/b1` | 1.05993 ± 0.00473495 (W 0.00276728) | 0.901905 ± 0.00441745 (W 0.00262165) | 🔴 faer-fork 1.18× slower than `lapack-openblas` |  |
| `solve/n512/b1` | 4.45435 ± 0.0261924 (W 0.0160672) | 3.29611 ± 0.0193565 (W 0.00606281) | 🔴 faer-fork 1.35× slower than `lapack-openblas` |  |
| `svd_thin/n128/b1` | 3.74958 ± 0.00922611 (W 0.00687576) | 4.63192 ± 0.0122718 (W 0.00714149) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `svd_thin/n256/b1` | 16.5973 ± 0.033445 (W 0.0240036) | 20.7708 ± 0.0177484 (W 0.0258614) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `svd_thin/n512/b1` | 65.7275 ± 0.0815647 (W 0.102165) | 94.5476 ± 0.80276 (W 0.096555) | 🔵 faer-fork 1.44× faster than `lapack-openblas` |  |
| `svd_values/n128/b1` | 2.88633 ± 0.0129571 (W 0.00319689) | 2.49511 ± 0.00366002 (W 0.00515479) | 🔴 faer-fork 1.16× slower than `lapack-openblas` |  |
| `svd_values/n256/b1` | 12.7013 ± 0.0230108 (W 0.019403) | 11.5108 ± 0.0222619 (W 0.018141) | 🔴 faer-fork 1.10× slower than `lapack-openblas` |  |
| `svd_values/n512/b1` | 47.0191 ± 0.158886 (W 0.0689977) | 46.1892 ± 0.235712 (W 0.0361973) | · |  |
| `triangular_solve/n128/b1` | 0.0080005 ± 0.000485905 (W 3.62935e-05) | - | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `triangular_solve/n256/b1` | 0.024566 ± 0.000842767 (W 0.000189018) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `triangular_solve/n512/b1` | 0.0609085 ± 0.00303068 (W 0.000924044) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `eig/128`, `eig/256`, `eig/512`, `full_piv_lu/128`, `full_piv_lu/256`, `full_piv_lu/512`, `householder_apply/128`, `householder_apply/256`, `householder_apply/512`, `triangular_solve/128`, `triangular_solve/256`, `triangular_solve/512`, `upgrade_factor/128`, `upgrade_factor/256`, `upgrade_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.828032 ± 0.00238431 (W 0.00413587) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 49.1512 ± 0.302968 (W 0.126638) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.553625 ± 0.00209928 (W 0.0016806) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.553726 ± 0.0007366 (W 0.0016741) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.0074 ± 0.0243348 (W 0.0571352) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.0048 ± 0.652585 (W 0.155303) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.487002 ± 0.0019955 (W 0.00226289) | 0.728889 ± 0.123607 (W 0.00377614) | 🔵 faer-fork 1.50× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 15.6093 ± 0.146058 (W 0.0393063) | 27.9588 ± 0.155241 (W 0.0467998) | 🔵 faer-fork 1.79× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.59035 ± 0.00521874 (W 0.00304873) | 2.48468 ± 0.0137293 (W 0.0116491) | 🔵 faer-fork 1.56× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 70.8458 ± 0.137846 (W 0.0841073) | 105.357 ± 1.16847 (W 1.13661) | 🔵 faer-fork 1.49× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.06634 ± 0.00366701 (W 0.00184711) | 1.26615 ± 0.00770186 (W 0.00449519) | 🔵 faer-fork 1.19× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 32.0152 ± 0.387666 (W 0.0947057) | 50.6847 ± 0.481877 (W 0.571669) | 🔵 faer-fork 1.58× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.50526 ± 0.00296214 (W 0.00467574) | 3.76102 ± 0.00618076 (W 0.00367411) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 88.1176 ± 0.130854 (W 0.105878) | 146.214 ± 0.631616 (W 1.02631) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.49023 ± 0.00873975 (W 0.00546904) | 1.92309 ± 0.00427549 (W 0.00933833) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 44.8481 ± 0.0555578 (W 0.0603953) | 69.837 ± 3.92446 (W 0.793703) | 🔵 faer-fork 1.56× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.63006 ± 0.0090725 (W 0.00876946) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 17.2748 ± 0.0657526 (W 0.0707917) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.391053 ± 0.00375185 (W 0.0019528) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.388099 ± 0.00225104 (W 0.00260439) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.2813 ± 0.0667906 (W 0.0415124) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.404 ± 0.647934 (W 0.0179289) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.460017 ± 0.00435041 (W 0.00221669) | 0.562645 ± 0.00263828 (W 0.00260415) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 9.39225 ± 0.103328 (W 0.0301132) | 22.3026 ± 0.126532 (W 0.0312959) | 🔵 faer-fork 2.37× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.39748 ± 0.00193324 (W 0.00412773) | 2.57735 ± 0.0145577 (W 0.00654727) | 🔵 faer-fork 1.84× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 49.7279 ± 0.242099 (W 0.773732) | 69.3894 ± 1.80041 (W 1.01991) | 🔵 faer-fork 1.40× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.0345 ± 0.0100209 (W 0.00220116) | 1.32557 ± 0.0102186 (W 0.00234847) | 🔵 faer-fork 1.28× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 26.898 ± 0.579541 (W 0.10017) | 33.5597 ± 0.96671 (W 0.547441) | 🔵 faer-fork 1.25× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.30715 ± 0.00536914 (W 0.00368459) | 3.61643 ± 0.0157802 (W 0.00600236) | 🔵 faer-fork 1.57× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 68.4481 ± 0.218797 (W 1.20296) | 91.8235 ± 0.615034 (W 0.906165) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.45251 ± 0.00367812 (W 0.00575381) | 1.97629 ± 0.00604949 (W 0.00359119) | 🔵 faer-fork 1.36× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 37.6359 ± 0.0848145 (W 0.0632687) | 49.0226 ± 0.904404 (W 0.314034) | 🔵 faer-fork 1.30× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.615043 ± 0.00342688 (W 0.00259578) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 12.5667 ± 0.132714 (W 0.0704565) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.40271 ± 0.00222516 (W 0.00686112) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.404783 ± 0.00619085 (W 0.0061579) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 20.6487 ± 0.710738 (W 0.024975) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 21.5193 ± 0.971506 (W 0.0363671) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `lu/1024x64/b1` | 0.459776 ± 0.628231 (W 0.00235835) | 0.537266 ± 0.00444434 (W 0.00255107) | · | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/4096x256/b1` | 8.68307 ± 0.136313 (W 0.040007) | 19.6373 ± 0.150519 (W 0.0433946) | 🔵 faer-fork 2.26× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 1.44306 ± 0.00600101 (W 0.00589262) | 2.57934 ± 0.0173397 (W 0.0136404) | 🔵 faer-fork 1.79× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 49.9795 ± 2.45593 (W 1.35775) | 61.5638 ± 1.05146 (W 0.820707) | 🔵 faer-fork 1.23× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 1.06115 ± 0.0117953 (W 0.00343154) | 1.31708 ± 0.00962104 (W 0.00336275) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 26.5467 ± 0.29115 (W 0.0866575) | 30.5881 ± 0.81339 (W 0.463473) | 🔵 faer-fork 1.15× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/1024x64/b1` | 2.35162 ± 0.00382659 (W 0.00511175) | 3.62644 ± 0.0229513 (W 0.0059839) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 64.2336 ± 0.854457 (W 2.36368) | 83.3862 ± 1.14802 (W 0.815714) | 🔵 faer-fork 1.30× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.47103 ± 0.00221038 (W 0.00422067) | 1.99401 ± 0.010951 (W 0.00311875) | 🔵 faer-fork 1.36× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 37.2206 ± 0.0513467 (W 0.0600996) | 46.1842 ± 0.764295 (W 0.597695) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.735331 ± 0.0085305 (W 0.00860995) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.8725 ± 0.55514 (W 0.133458) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.594518 ± 0.00230029 (W 0.0020111) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.594067 ± 0.00233183 (W 0.00205684) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 35.8078 ± 0.0842125 (W 0.0442655) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 35.7747 ± 0.0226225 (W 0.0385089) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.386515 ± 0.00127479 (W 0.00214639) | 0.303826 ± 0.00193332 (W 0.00194338) | 🔴 faer-fork 1.27× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.1784 ± 0.0193794 (W 0.0278343) | 13.0267 ± 0.0659247 (W 0.0224491) | · |  |
| `qr/1024x64/b1` | 1.46529 ± 0.00666172 (W 0.00295879) | 1.86788 ± 0.00476364 (W 0.0029829) | 🔵 faer-fork 1.27× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 68.3832 ± 0.13052 (W 0.0580251) | 77.3883 ± 0.254653 (W 0.145049) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.78484 ± 0.0111124 (W 0.00240919) | 0.960749 ± 0.00223166 (W 0.00123941) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 25.7706 ± 0.050919 (W 0.0280039) | 39.0014 ± 0.22443 (W 0.0482507) | 🔵 faer-fork 1.51× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.4501 ± 0.00386096 (W 0.00403491) | 3.24392 ± 0.0182164 (W 0.00365345) | 🔵 faer-fork 1.32× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 82.7906 ± 0.0862354 (W 0.0655391) | 120.992 ± 0.254271 (W 0.230682) | 🔵 faer-fork 1.46× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.41269 ± 0.0030857 (W 0.00320415) | 1.60042 ± 0.00651357 (W 0.0033887) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 39.174 ± 0.0421261 (W 0.0325232) | 54.8487 ± 0.400817 (W 0.0756296) | 🔵 faer-fork 1.40× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.538395 ± 0.0125772 (W 0.00711267) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/4096x256/b1` | 14.7021 ± 0.0668764 (W 0.0767518) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.413803 ± 0.0141999 (W 0.00231228) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.414435 ± 0.0127834 (W 0.00143983) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 24.0099 ± 0.0408707 (W 0.0196148) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 24.2781 ± 0.0856602 (W 0.0224481) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.359631 ± 0.00190662 (W 0.00198044) | 0.253062 ± 0.00387211 (W 0.00239409) | 🔴 faer-fork 1.42× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 6.98757 ± 0.0125579 (W 0.017876) | 7.26356 ± 0.0299505 (W 0.0148839) | · |  |
| `qr/1024x64/b1` | 1.27969 ± 0.00214929 (W 0.00500476) | 1.98451 ± 0.0238228 (W 0.00250811) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 46.8327 ± 0.0765326 (W 0.067747) | 41.1246 ± 0.269016 (W 0.194235) | 🔴 faer-fork 1.14× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 0.756554 ± 0.0026936 (W 0.00204859) | 1.03144 ± 0.0172732 (W 0.00191621) | 🔵 faer-fork 1.36× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 20.3875 ± 0.0686704 (W 0.0274035) | 20.5516 ± 0.289399 (W 0.0203034) | · |  |
| `svd_thin/1024x64/b1` | 2.25776 ± 0.00526231 (W 0.00401769) | 3.09141 ± 0.00665363 (W 0.00468868) | 🔵 faer-fork 1.37× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 61.0077 ± 0.285186 (W 0.10692) | 66.8469 ± 0.376671 (W 0.240137) | 🔵 faer-fork 1.10× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 1.37182 ± 0.00251967 (W 0.00233117) | 1.67834 ± 0.00692996 (W 0.00359104) | 🔵 faer-fork 1.22× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 31.9819 ± 0.061264 (W 0.0417053) | 36.2676 ± 0.259248 (W 0.13481) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.516826 ± 0.00760141 (W 0.00666342) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 9.97022 ± 0.0646361 (W 0.0705793) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 0.443981 ± 0.00716285 (W 0.00229703) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 0.441999 ± 0.0036754 (W 0.00503847) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 22.4191 ± 0.233623 (W 0.22954) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 22.8051 ± 0.178632 (W 0.212351) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.355707 ± 0.00215847 (W 0.00172849) | 0.234301 ± 0.0028869 (W 0.00168598) | 🔴 faer-fork 1.52× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 6.18361 ± 0.0112932 (W 0.0111554) | 4.76803 ± 0.204016 (W 0.00755498) | 🔴 faer-fork 1.30× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 1.3193 ± 0.00367716 (W 0.00442605) | 1.97421 ± 0.00473903 (W 0.00302937) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `qr/4096x256/b1` | 47.0013 ± 2.23208 (W 1.59123) | 36.4189 ± 0.322392 (W 0.0378693) | 🔴 faer-fork 1.29× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/1024x64/b1` | 0.763918 ± 0.00969563 (W 0.00208221) | 1.02263 ± 0.0034683 (W 0.00207855) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 19.6593 ± 0.151151 (W 0.0517987) | 18.3297 ± 0.201528 (W 0.0268799) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 2.29497 ± 0.00508427 (W 0.00454295) | 3.07347 ± 0.0202087 (W 0.00458507) | 🔵 faer-fork 1.34× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 58.7979 ± 1.1796 (W 2.65442) | 60.0346 ± 0.779191 (W 0.233763) | · |  |
| `svd_values/1024x64/b1` | 1.39261 ± 0.00421732 (W 0.0033567) | 1.6899 ± 0.00815966 (W 0.00226367) | 🔵 faer-fork 1.21× faster than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 31.7487 ± 0.0403976 (W 0.0623283) | 33.7886 ± 0.128884 (W 0.0386079) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.78387 ± 0.0176681 (W 0.00428995) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 148.638 ± 1.01013 (W 0.483724) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.19953 ± 0.00288785 (W 0.00161865) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.1987 ± 0.00523965 (W 0.00205902) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 137.399 ± 0.116084 (W 0.0787231) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 137.302 ± 0.0561383 (W 0.0633404) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 1.00658 ± 0.00374875 (W 0.00147036) | 1.29663 ± 0.00268223 (W 0.0024965) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 47.0845 ± 0.218699 (W 0.058007) | 64.8176 ± 0.170134 (W 0.269657) | 🔵 faer-fork 1.38× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 4.71732 ± 0.0136435 (W 0.00387635) | 4.33209 ± 0.0218191 (W 0.00516356) | 🔴 faer-fork 1.09× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 239.539 ± 0.281384 (W 0.315976) | 261.373 ± 1.93032 (W 1.9483) | 🔵 faer-fork 1.09× faster than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.54116 ± 0.0167698 (W 0.00331259) | 2.19993 ± 0.0136892 (W 0.00369252) | 🔴 faer-fork 1.16× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 100.584 ± 0.326762 (W 0.0821425) | 131.385 ± 1.26288 (W 1.27209) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.97998 ± 0.014377 (W 0.00370846) | 6.90219 ± 0.0575227 (W 0.0143559) | 🔵 faer-fork 1.15× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 280.646 ± 0.245493 (W 0.428984) | 381.636 ± 2.50551 (W 1.77013) | 🔵 faer-fork 1.36× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 3.07056 ± 0.0168748 (W 0.00280627) | 3.14677 ± 0.0152447 (W 0.00364781) | · |  |
| `svd_values/4096x256/b1` | 122.25 ± 0.931868 (W 0.380184) | 157.431 ± 1.41744 (W 1.20774) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.957977 ± 0.0057157 (W 0.00331814) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 52.6977 ± 0.863219 (W 0.302036) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.39617 ± 0.00319702 (W 0.00161301) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.39882 ± 0.00452627 (W 0.00206785) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 85.6361 ± 0.136179 (W 0.372708) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 85.6656 ± 0.10013 (W 0.0326936) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.764695 ± 0.00181127 (W 0.00270442) | 1.01205 ± 0.0296833 (W 0.000934044) | 🔵 faer-fork 1.32× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 22.9408 ± 0.224229 (W 0.097167) | 42.1074 ± 1.57459 (W 0.104925) | 🔵 faer-fork 1.84× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/1024x64/b1` | 3.67015 ± 0.00752439 (W 0.0066426) | 2.18804 ± 0.0435088 (W 0.00257746) | 🔴 faer-fork 1.68× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 165.508 ± 0.482477 (W 0.148275) | 112.704 ± 1.66966 (W 1.1233) | 🔴 faer-fork 1.47× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.24984 ± 0.0326329 (W 0.0052796) | 1.13555 ± 0.0160268 (W 0.00292933) | 🔴 faer-fork 1.98× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 77.0062 ± 0.392644 (W 0.156187) | 55.1545 ± 0.768649 (W 0.925625) | 🔴 faer-fork 1.40× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 4.81196 ± 0.0099256 (W 0.00728168) | 3.70302 ± 0.0392074 (W 0.00339259) | 🔴 faer-fork 1.30× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 190.638 ± 0.291812 (W 0.124565) | 156.161 ± 2.4991 (W 0.799977) | 🔴 faer-fork 1.22× slower than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.77642 ± 0.00590248 (W 0.0038567) | 2.07218 ± 0.00513028 (W 0.0028341) | 🔴 faer-fork 1.34× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 92.2422 ± 0.198103 (W 0.295541) | 76.045 ± 1.29265 (W 0.52342) | 🔴 faer-fork 1.21× slower than `lapack-openblas` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.855666 ± 0.00982081 (W 0.00361258) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 30.3185 ± 0.232203 (W 0.152967) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.39345 ± 0.0430006 (W 0.0328654) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.39096 ± 0.0373142 (W 0.0334117) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 77.4743 ± 0.0706299 (W 0.0475077) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 77.4781 ± 0.100488 (W 0.0439225) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.721024 ± 0.00309742 (W 0.00301031) | 0.932969 ± 0.0284791 (W 0.00302929) | 🔵 faer-fork 1.29× faster than `lapack-openblas` | `!` between-start range over 5% |
| `lu/4096x256/b1` | 19.0093 ± 0.16025 (W 0.0995081) | 31.8 ± 0.403317 (W 0.0673287) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 3.67849 ± 0.0285368 (W 0.031616) | 1.93886 ± 0.0484017 (W 0.00418882) | 🔴 faer-fork 1.90× slower than `lapack-openblas` | `!` between-start range over 5% |
| `qr/4096x256/b1` | 155.921 ± 2.15693 (W 2.6716) | 85.3916 ± 0.632759 (W 0.202342) | 🔴 faer-fork 1.83× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 2.302 ± 0.0205844 (W 0.00921566) | 0.994885 ± 0.0132129 (W 0.00246916) | 🔴 faer-fork 2.31× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 73.5128 ± 0.166088 (W 0.153217) | 42.5998 ± 0.177058 (W 0.0651074) | 🔴 faer-fork 1.73× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 4.80459 ± 0.0175501 (W 0.0221896) | 3.24866 ± 0.00605913 (W 0.00338842) | 🔴 faer-fork 1.48× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 176.952 ± 3.10941 (W 0.760044) | 119.919 ± 0.210333 (W 0.242791) | 🔴 faer-fork 1.48× slower than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.8212 ± 0.00727781 (W 0.00756237) | 1.94579 ± 0.0166593 (W 0.00384808) | 🔴 faer-fork 1.45× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 88.551 ± 2.40009 (W 0.0647506) | 62.6552 ± 0.41416 (W 0.115774) | 🔴 faer-fork 1.41× slower than `lapack-openblas` | `!` between-start range over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 1.6671 ± 0.00832387 (W 0.00351338) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 142.704 ± 0.400674 (W 0.448259) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 2.26685 ± 0.00667497 (W 0.00282694) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 2.26343 ± 0.00926067 (W 0.00270342) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 138.519 ± 0.0706666 (W 0.0833082) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 138.491 ± 0.12481 (W 0.0889593) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.886463 ± 0.00187149 (W 0.0037303) | 0.942582 ± 0.00493448 (W 0.00117024) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 41.6165 ± 0.044109 (W 0.0434072) | 47.2147 ± 0.0481084 (W 0.0397917) | 🔵 faer-fork 1.13× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 4.59362 ± 0.0141191 (W 0.00349626) | 3.55665 ± 0.020816 (W 0.00383007) | 🔴 faer-fork 1.29× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 234.12 ± 0.301944 (W 0.213326) | 223.281 ± 1.18675 (W 0.525753) | · |  |
| `qr_factor/1024x64/b1` | 2.25722 ± 0.0177131 (W 0.00256131) | 1.82101 ± 0.0056781 (W 0.00268683) | 🔴 faer-fork 1.24× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 89.9666 ± 0.0896858 (W 0.185201) | 112.056 ± 0.663622 (W 0.158685) | 🔵 faer-fork 1.25× faster than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 5.88495 ± 0.0189115 (W 0.0056428) | 6.24504 ± 0.0236903 (W 0.00537373) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 268.435 ± 0.25803 (W 0.291652) | 347.546 ± 1.43573 (W 0.454427) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.94597 ± 0.0172473 (W 0.0024908) | 2.7504 ± 0.00861593 (W 0.00550643) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 110.053 ± 0.0872629 (W 0.101884) | 136.928 ± 0.756787 (W 0.146238) | 🔵 faer-fork 1.24× faster than `lapack-openblas` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.844656 ± 0.00886649 (W 0.00250511) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 46.925 ± 0.271584 (W 0.116782) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.44551 ± 0.0123532 (W 0.00316764) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.44686 ± 0.0118868 (W 0.00213898) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 88.9834 ± 0.116729 (W 0.0354664) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 89.1247 ± 0.121215 (W 0.0417654) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.65341 ± 0.00308235 (W 0.00313319) | 0.6953 ± 0.00234147 (W 0.00189173) | 🔵 faer-fork 1.06× faster than `lapack-openblas` |  |
| `lu/4096x256/b1` | 17.4835 ± 0.0733654 (W 0.0316541) | 24.2942 ± 0.0602737 (W 0.0212548) | 🔵 faer-fork 1.39× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 3.54521 ± 0.00513218 (W 0.00526706) | 1.47132 ± 0.00803046 (W 0.00251696) | 🔴 faer-fork 2.41× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 159.59 ± 0.390948 (W 0.125099) | 73.5631 ± 0.366974 (W 0.0657088) | 🔴 faer-fork 2.17× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.95386 ± 0.00347066 (W 0.00443802) | 0.790251 ± 0.00336706 (W 0.00242049) | 🔴 faer-fork 2.47× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 65.2604 ± 0.538754 (W 0.125801) | 36.5634 ± 0.233382 (W 0.063839) | 🔴 faer-fork 1.78× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 4.70509 ± 0.00238615 (W 0.00668403) | 3.14162 ± 0.00289275 (W 0.00423408) | 🔴 faer-fork 1.50× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 178.642 ± 0.371028 (W 0.161914) | 123.866 ± 0.39868 (W 0.232418) | 🔴 faer-fork 1.44× slower than `lapack-openblas` |  |
| `svd_values/1024x64/b1` | 2.6917 ± 0.00709556 (W 0.00437417) | 1.7375 ± 0.00332786 (W 0.00213943) | 🔴 faer-fork 1.55× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 80.288 ± 0.149524 (W 0.0919533) | 57.0086 ± 0.464083 (W 0.154743) | 🔴 faer-fork 1.41× slower than `lapack-openblas` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/1024x64/b1` | 0.751877 ± 0.00915876 (W 0.00287656) | - | - | `*` one row has no measurement here |
| `full_piv_lu/4096x256/b1` | 23.9247 ± 0.150993 (W 0.106482) | - | - | `*` one row has no measurement here |
| `householder_apply/1024x64/b1 [block(basis=64,target=64)]` | 1.37092 ± 0.0326133 (W 0.0386007) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/1024x64/b1 [sequence(basis=64,target=64)]` | 1.40004 ± 0.0374199 (W 0.0389354) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 80.7326 ± 0.143944 (W 0.369658) | - | - | `*` one row has no measurement here |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 80.6963 ± 0.263349 (W 0.408955) | - | - | `*` one row has no measurement here |
| `lu/1024x64/b1` | 0.60872 ± 0.00217559 (W 0.00258042) | 0.56838 ± 0.00211137 (W 0.00268686) | 🔴 faer-fork 1.07× slower than `lapack-openblas` |  |
| `lu/4096x256/b1` | 13.448 ± 0.0361351 (W 0.0271502) | 14.5464 ± 0.0172659 (W 0.0250498) | 🔵 faer-fork 1.08× faster than `lapack-openblas` |  |
| `qr/1024x64/b1` | 3.55588 ± 0.0112717 (W 0.0230058) | 1.16478 ± 0.00679264 (W 0.00218339) | 🔴 faer-fork 3.05× slower than `lapack-openblas` |  |
| `qr/4096x256/b1` | 152.332 ± 1.75659 (W 2.1021) | 50.5206 ± 0.1945 (W 0.0380647) | 🔴 faer-fork 3.02× slower than `lapack-openblas` |  |
| `qr_factor/1024x64/b1` | 1.96119 ± 0.017218 (W 0.00932577) | 0.638811 ± 0.00592854 (W 0.00246153) | 🔴 faer-fork 3.07× slower than `lapack-openblas` |  |
| `qr_factor/4096x256/b1` | 61.7923 ± 0.114393 (W 0.0751179) | 25.0843 ± 0.0855751 (W 0.027497) | 🔴 faer-fork 2.46× slower than `lapack-openblas` |  |
| `svd_thin/1024x64/b1` | 4.69466 ± 0.0132025 (W 0.0214386) | 2.69974 ± 0.00792173 (W 0.00301004) | 🔴 faer-fork 1.74× slower than `lapack-openblas` |  |
| `svd_thin/4096x256/b1` | 164.822 ± 3.36737 (W 0.720486) | 89.0416 ± 0.0638865 (W 0.133685) | 🔴 faer-fork 1.85× slower than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.74723 ± 0.00694429 (W 0.00850649) | 1.59127 ± 0.00620735 (W 0.00358138) | 🔴 faer-fork 1.73× slower than `lapack-openblas` |  |
| `svd_values/4096x256/b1` | 76.5196 ± 2.66475 (W 0.0845556) | 45.4499 ± 0.240608 (W 0.0363573) | 🔴 faer-fork 1.68× slower than `lapack-openblas` | `!` between-start range over 5% |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 74.3939 ± 0.565306 (W 0.248441) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.13191 ± 0.00761504 (W 0.00484623) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 16.0865 ± 0.0316126 (W 0.065019) | 35.3489 ± 0.157747 (W 0.0707552) | 🔵 faer-fork 2.20× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.41615 ± 0.00248114 (W 0.00246638) | 1.1361 ± 0.125873 (W 0.00595889) | 🔵 faer-fork 2.73× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/256x4096/b1` | 30.7161 ± 0.110905 (W 0.0824004) | 72.3437 ± 0.474866 (W 1.20752) | 🔵 faer-fork 2.36× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.75882 ± 0.00396589 (W 0.00199834) | 1.90562 ± 0.00980184 (W 0.0163696) | 🔵 faer-fork 2.51× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 27.4312 ± 0.305688 (W 0.049473) | 65.5519 ± 1.96601 (W 0.773971) | 🔵 faer-fork 2.39× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.9955 ± 0.00601498 (W 0.00455798) | 1.73296 ± 0.00748667 (W 0.0108215) | 🔵 faer-fork 1.74× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 83.3053 ± 0.231839 (W 0.0980687) | 223.513 ± 0.718508 (W 0.812713) | 🔵 faer-fork 2.68× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.45275 ± 0.00643023 (W 0.00393121) | 5.02943 ± 0.0481917 (W 0.00987762) | 🔵 faer-fork 2.05× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 39.1821 ± 0.0794045 (W 0.0333051) | 106.142 ± 2.02777 (W 0.375109) | 🔵 faer-fork 2.71× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.42704 ± 0.00444612 (W 0.00290732) | 2.57401 ± 0.073237 (W 0.0141654) | 🔵 faer-fork 1.80× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 33.4026 ± 0.0937743 (W 0.0550451) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.835252 ± 0.00241413 (W 0.00303089) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 6.83005 ± 0.0866668 (W 0.0637301) | 26.7572 ± 0.110563 (W 0.0311435) | 🔵 faer-fork 3.92× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.224249 ± 0.00119918 (W 0.00162214) | 0.796498 ± 0.00541766 (W 0.00155123) | 🔵 faer-fork 3.55× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 10.8711 ± 0.11354 (W 0.0347659) | 45.9358 ± 2.39324 (W 0.291869) | 🔵 faer-fork 4.23× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.388821 ± 0.00324615 (W 0.00196641) | 1.76599 ± 0.0291512 (W 0.0127395) | 🔵 faer-fork 4.54× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 9.53201 ± 0.142881 (W 0.0262286) | 39.5019 ± 0.568086 (W 0.192772) | 🔵 faer-fork 4.14× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.613552 ± 0.00612985 (W 0.00709867) | 1.58528 ± 0.0272012 (W 0.00658749) | 🔵 faer-fork 2.58× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 62.8905 ± 0.854776 (W 1.05599) | 151.539 ± 0.96439 (W 1.64111) | 🔵 faer-fork 2.41× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.25404 ± 0.00402204 (W 0.0046844) | 4.58574 ± 0.040288 (W 0.00999242) | 🔵 faer-fork 2.03× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 31.923 ± 0.0506708 (W 0.0402865) | 79.1805 ± 2.63724 (W 0.772549) | 🔵 faer-fork 2.48× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.38474 ± 0.00348727 (W 0.0037551) | 2.51997 ± 0.0380957 (W 0.0129042) | 🔵 faer-fork 1.82× faster than `lapack-openblas` |  |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 27.8396 ± 0.164559 (W 0.0650207) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.800898 ± 0.00351198 (W 0.00199635) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 5.31312 ± 0.0176957 (W 0.0191369) | 24.3655 ± 0.395563 (W 0.064422) | 🔵 faer-fork 4.59× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.197333 ± 0.00105961 (W 0.00142566) | 0.762521 ± 0.00807767 (W 0.00211256) | 🔵 faer-fork 3.86× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 7.49261 ± 0.0942132 (W 0.0216438) | 40.7006 ± 2.06934 (W 0.474466) | 🔵 faer-fork 5.43× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.340172 ± 0.00105434 (W 0.00159965) | 1.79944 ± 0.0336382 (W 0.0148844) | 🔵 faer-fork 5.29× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 6.63097 ± 0.108069 (W 0.0275997) | 35.5452 ± 1.28968 (W 0.0819303) | 🔵 faer-fork 5.36× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.549735 ± 0.067104 (W 0.00470816) | 1.61261 ± 0.0246544 (W 0.00495278) | 🔵 faer-fork 2.93× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 60.5225 ± 1.18433 (W 2.34758) | 143.632 ± 1.06396 (W 0.81328) | 🔵 faer-fork 2.37× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.29807 ± 0.00462259 (W 0.00578073) | 4.55721 ± 0.0402614 (W 0.00796515) | 🔵 faer-fork 1.98× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 31.5959 ± 0.0675371 (W 0.0779127) | 71.6498 ± 1.6073 (W 0.736316) | 🔵 faer-fork 2.27× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.40504 ± 0.0020207 (W 0.00309854) | 2.50171 ± 0.0335081 (W 0.008792) | 🔵 faer-fork 1.78× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 71.4833 ± 0.872893 (W 0.358191) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.02814 ± 0.0087631 (W 0.00350083) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.3712 ± 0.0673154 (W 0.0146143) | 20.4785 ± 0.216554 (W 0.0399257) | 🔵 faer-fork 1.53× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.312623 ± 0.000671215 (W 0.00181865) | 0.70682 ± 0.00272933 (W 0.0020358) | 🔵 faer-fork 2.26× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 27.7805 ± 0.197368 (W 0.0818489) | 70.1163 ± 3.63893 (W 0.546564) | 🔵 faer-fork 2.52× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.628201 ± 0.00304792 (W 0.00219854) | 1.69491 ± 0.0179951 (W 0.00886549) | 🔵 faer-fork 2.70× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 25.0602 ± 0.0791789 (W 0.0733571) | 54.3678 ± 0.933111 (W 0.539526) | 🔵 faer-fork 2.17× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.564005 ± 0.00160993 (W 0.0022486) | 1.39407 ± 0.0129653 (W 0.00297944) | 🔵 faer-fork 2.47× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 88.3973 ± 0.2535 (W 0.13479) | 195.051 ± 1.24832 (W 0.768449) | 🔵 faer-fork 2.21× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 2.52136 ± 0.00896345 (W 0.00425873) | 4.56833 ± 0.0459243 (W 0.0144649) | 🔵 faer-fork 1.81× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 44.9463 ± 0.133324 (W 0.0509333) | 91.0199 ± 0.659469 (W 0.206354) | 🔵 faer-fork 2.03× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.4783 ± 0.0134526 (W 0.00599968) | 2.27468 ± 0.0544164 (W 0.0089353) | 🔵 faer-fork 1.54× faster than `lapack-openblas` | `!` between-start range over 5% |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 30.4641 ± 0.22255 (W 0.070522) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.743939 ± 0.00195662 (W 0.00204943) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 4.09886 ± 0.00939114 (W 0.00785474) | 12.6635 ± 0.243196 (W 0.0264407) | 🔵 faer-fork 3.09× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.11753 ± 0.000821897 (W 0.000396835) | 0.493842 ± 0.00276579 (W 0.0014268) | 🔵 faer-fork 4.20× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 7.64349 ± 0.0396554 (W 0.0172738) | 46.6001 ± 3.23884 (W 0.239577) | 🔵 faer-fork 6.10× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr/64x1024/b1` | 0.260466 ± 0.000459235 (W 0.00148459) | 1.61208 ± 0.03093 (W 0.00844979) | 🔵 faer-fork 6.19× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 6.62475 ± 0.0284778 (W 0.00952893) | 29.5083 ± 0.367766 (W 0.151649) | 🔵 faer-fork 4.45× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.204069 ± 0.000656137 (W 0.00112422) | 1.31643 ± 0.0196703 (W 0.00335647) | 🔵 faer-fork 6.45× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 66.0524 ± 0.20515 (W 0.0970728) | 126.823 ± 2.83471 (W 0.688311) | 🔵 faer-fork 1.92× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.31649 ± 0.00481888 (W 0.00335047) | 4.16744 ± 0.0897692 (W 0.0116274) | 🔵 faer-fork 1.80× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 37.712 ± 0.0560258 (W 0.0422185) | 65.6138 ± 1.68015 (W 0.432718) | 🔵 faer-fork 1.74× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 1.43724 ± 0.0020955 (W 0.00423925) | 2.23358 ± 0.0386119 (W 0.00879758) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 25.071 ± 0.16235 (W 0.0577197) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 0.704719 ± 0.00284494 (W 0.0018146) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 2.57706 ± 0.00952697 (W 0.00643093) | 10.4244 ± 0.162678 (W 0.0137379) | 🔵 faer-fork 4.05× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.0904235 ± 0.000561767 (W 0.00131541) | 0.449912 ± 0.00268961 (W 0.00195855) | 🔵 faer-fork 4.98× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 4.38339 ± 0.00621701 (W 0.0113305) | 38.9507 ± 0.707783 (W 0.171294) | 🔵 faer-fork 8.89× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.211361 ± 0.00146817 (W 0.00143747) | 1.58401 ± 0.0352111 (W 0.017901) | 🔵 faer-fork 7.49× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 3.59709 ± 0.0226934 (W 0.00976024) | 25.7537 ± 0.73208 (W 0.060182) | 🔵 faer-fork 7.16× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.150421 ± 0.00284032 (W 0.00126396) | 1.2778 ± 0.0371014 (W 0.00567538) | 🔵 faer-fork 8.49× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 64.9472 ± 2.23437 (W 2.43003) | 122.084 ± 0.873516 (W 0.388602) | 🔵 faer-fork 1.88× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/64x1024/b1` | 2.3595 ± 0.00543507 (W 0.00518059) | 4.11327 ± 0.0520366 (W 0.00923409) | 🔵 faer-fork 1.74× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 37.2803 ± 0.0449113 (W 0.0578899) | 61.9968 ± 1.22646 (W 0.360125) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 1.45612 ± 0.00587885 (W 0.0059196) | 2.16105 ± 0.036434 (W 0.00736548) | 🔵 faer-fork 1.48× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 228.293 ± 5.242 (W 0.967512) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 2.42457 ± 0.0299083 (W 0.0121903) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 46.2045 ± 0.284227 (W 0.0548516) | 82.6068 ± 0.228283 (W 0.290477) | 🔵 faer-fork 1.79× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.995312 ± 0.00631794 (W 0.00260083) | 1.63858 ± 0.0246024 (W 0.00323326) | 🔵 faer-fork 1.65× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 107.437 ± 0.304452 (W 0.23531) | 178.422 ± 1.23068 (W 1.46989) | 🔵 faer-fork 1.66× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.505 ± 0.0175366 (W 0.00284792) | 3.61737 ± 0.0113053 (W 0.0076613) | 🔵 faer-fork 1.44× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 96.798 ± 0.375417 (W 0.117213) | 160.11 ± 1.12356 (W 1.81703) | 🔵 faer-fork 1.65× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.57496 ± 0.00791635 (W 0.00403659) | 3.32446 ± 0.0224315 (W 0.00412818) | 🔵 faer-fork 1.29× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 269.091 ± 0.235519 (W 3.19281) | 676.404 ± 2.49097 (W 2.32751) | 🔵 faer-fork 2.51× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 5.90887 ± 0.0182573 (W 0.0056006) | 11.8442 ± 0.0785655 (W 0.0281901) | 🔵 faer-fork 2.00× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 110.124 ± 0.21232 (W 0.0652141) | 304.627 ± 5.5799 (W 0.832263) | 🔵 faer-fork 2.77× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.93857 ± 0.0172646 (W 0.0021156) | 5.68264 ± 0.0879357 (W 0.0131788) | 🔵 faer-fork 1.93× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 86.2074 ± 1.94729 (W 0.253031) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.40141 ± 0.00595933 (W 0.00782731) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 17.5669 ± 0.068812 (W 0.0270077) | 56.7743 ± 0.2161 (W 0.0870534) | 🔵 faer-fork 3.23× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.411727 ± 0.00563295 (W 0.00220854) | 1.17576 ± 0.033863 (W 0.00236651) | 🔵 faer-fork 2.86× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 32.46 ± 0.154311 (W 0.0503873) | 87.7525 ± 1.93837 (W 1.06067) | 🔵 faer-fork 2.70× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.887099 ± 0.00203637 (W 0.00183605) | 1.69745 ± 0.0264896 (W 0.003888) | 🔵 faer-fork 1.91× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 27.4878 ± 0.0926715 (W 0.106199) | 70.6261 ± 0.90206 (W 0.321692) | 🔵 faer-fork 2.57× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.982452 ± 0.00309974 (W 0.00453917) | 1.37753 ± 0.00589676 (W 0.00269912) | 🔵 faer-fork 1.40× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 179.345 ± 0.365852 (W 1.42405) | 438.223 ± 3.82938 (W 2.52342) | 🔵 faer-fork 2.44× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.73912 ± 0.00859142 (W 0.00648739) | 9.89462 ± 0.131286 (W 0.0180223) | 🔵 faer-fork 2.09× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 80.2931 ± 0.139029 (W 0.103946) | 220.473 ± 5.76261 (W 0.374684) | 🔵 faer-fork 2.75× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.68677 ± 0.00505347 (W 0.00319496) | 5.03888 ± 0.051549 (W 0.00995158) | 🔵 faer-fork 1.88× faster than `lapack-openblas` |  |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 57.3825 ± 1.24501 (W 0.475906) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.2642 ± 0.00863509 (W 0.00675342) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 11.9178 ± 0.184958 (W 0.040367) | 50.2134 ± 0.353057 (W 0.108563) | 🔵 faer-fork 4.21× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.31313 ± 0.00220283 (W 0.00149189) | 1.04446 ± 0.0384499 (W 0.00209081) | 🔵 faer-fork 3.34× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 19.9632 ± 0.108368 (W 0.0910238) | 72.4959 ± 1.75319 (W 0.834558) | 🔵 faer-fork 3.63× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/64x1024/b1` | 0.623505 ± 0.001519 (W 0.00209756) | 1.42355 ± 0.0329377 (W 0.00538149) | 🔵 faer-fork 2.28× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/256x4096/b1` | 15.9045 ± 0.111629 (W 0.035849) | 56.338 ± 1.38045 (W 0.530898) | 🔵 faer-fork 3.54× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr_factor/64x1024/b1` | 0.721415 ± 0.024115 (W 0.00445483) | 1.0888 ± 0.0134714 (W 0.00201908) | 🔵 faer-fork 1.51× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_thin/256x4096/b1` | 165.44 ± 0.241608 (W 1.8157) | 394.592 ± 1.37028 (W 0.902462) | 🔵 faer-fork 2.39× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.74076 ± 0.0145409 (W 0.028369) | 9.84856 ± 0.135521 (W 0.0256339) | 🔵 faer-fork 2.08× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 76.6574 ± 0.0749472 (W 0.0718469) | 210.407 ± 6.64453 (W 0.801767) | 🔵 faer-fork 2.74× faster than `lapack-openblas` | `!` between-start range over 5% |
| `svd_values/64x1024/b1` | 2.73293 ± 0.00756393 (W 0.00911909) | 5.00662 ± 0.0309285 (W 0.0129451) | 🔵 faer-fork 1.83× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 223.773 ± 5.96476 (W 0.832236) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 2.29551 ± 0.0267233 (W 0.00720851) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 41.8877 ± 0.0786663 (W 0.0284783) | 55.6427 ± 0.126043 (W 0.0412369) | 🔵 faer-fork 1.33× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.894339 ± 0.00289166 (W 0.00552147) | 1.27317 ± 0.00442983 (W 0.00182603) | 🔵 faer-fork 1.42× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 103.127 ± 0.367638 (W 0.292174) | 182.737 ± 1.11061 (W 1.11074) | 🔵 faer-fork 1.77× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 2.41003 ± 0.00371719 (W 0.00326139) | 3.73311 ± 0.0315057 (W 0.0115613) | 🔵 faer-fork 1.55× faster than `lapack-openblas` |  |
| `qr_factor/256x4096/b1` | 95.9298 ± 0.607031 (W 0.136799) | 144.325 ± 2.88028 (W 1.68831) | 🔵 faer-fork 1.50× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 2.22743 ± 0.00479045 (W 0.00341807) | 2.91971 ± 0.034272 (W 0.00401897) | 🔵 faer-fork 1.31× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 281.447 ± 0.269864 (W 0.2621) | 645.86 ± 0.886059 (W 1.30958) | 🔵 faer-fork 2.29× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 6.03292 ± 0.0133304 (W 0.00356464) | 11.1091 ± 0.189526 (W 0.0187211) | 🔵 faer-fork 1.84× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 122.528 ± 0.628911 (W 0.421271) | 283.033 ± 0.724144 (W 0.652862) | 🔵 faer-fork 2.31× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 3.07441 ± 0.0150627 (W 0.00218581) | 5.26404 ± 0.0878126 (W 0.013055) | 🔵 faer-fork 1.71× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 81.4649 ± 1.40748 (W 0.31299) | - | - | `*` one row has no measurement here |
| `full_piv_lu/64x1024/b1` | 1.2794 ± 0.00460334 (W 0.00443827) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 13.446 ± 0.0221859 (W 0.0176309) | 30.5298 ± 0.215672 (W 0.0228063) | 🔵 faer-fork 2.27× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.300446 ± 0.00635255 (W 0.00213008) | 0.802375 ± 0.00229938 (W 0.00231831) | 🔵 faer-fork 2.67× faster than `lapack-openblas` | `!` between-start range over 5% |
| `qr/256x4096/b1` | 28.1777 ± 0.139301 (W 0.0285973) | 87.7961 ± 0.571159 (W 0.388666) | 🔵 faer-fork 3.12× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.783153 ± 0.00213708 (W 0.00179388) | 1.73545 ± 0.101437 (W 0.0153513) | 🔵 faer-fork 2.22× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 24.9696 ± 0.128781 (W 0.0304711) | 53.4712 ± 0.885675 (W 0.110266) | 🔵 faer-fork 2.14× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.667771 ± 0.00269388 (W 0.00204059) | 1.02747 ± 0.0108303 (W 0.00136572) | 🔵 faer-fork 1.54× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 191.587 ± 0.35089 (W 0.125791) | 412.881 ± 1.09804 (W 0.723794) | 🔵 faer-fork 2.16× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.85596 ± 0.00773577 (W 0.00587004) | 9.3652 ± 0.100591 (W 0.0177331) | 🔵 faer-fork 1.93× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 92.1067 ± 0.155515 (W 0.132479) | 200.148 ± 0.680889 (W 0.579124) | 🔵 faer-fork 2.17× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.78113 ± 0.0112358 (W 0.00520848) | 4.71198 ± 0.0341816 (W 0.0176678) | 🔵 faer-fork 1.69× faster than `lapack-openblas` |  |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | lapack-openblas (ms) | vs `lapack-openblas` | notes |
|---|---|---|---|---|
| `full_piv_lu/256x4096/b1` | 52.1905 ± 1.70326 (W 0.229602) | - | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `full_piv_lu/64x1024/b1` | 1.14479 ± 0.00750051 (W 0.00589968) | - | - | `*` one row has no measurement here |
| `lu/256x4096/b1` | 7.75466 ± 0.0121137 (W 0.0187708) | 23.6971 ± 0.0540012 (W 0.0143973) | 🔵 faer-fork 3.06× faster than `lapack-openblas` |  |
| `lu/64x1024/b1` | 0.207107 ± 0.0016395 (W 0.00136789) | 0.671961 ± 0.00324137 (W 0.00236477) | 🔵 faer-fork 3.24× faster than `lapack-openblas` |  |
| `qr/256x4096/b1` | 15.6167 ± 0.0514793 (W 0.0234291) | 71.9232 ± 0.23234 (W 0.427019) | 🔵 faer-fork 4.61× faster than `lapack-openblas` |  |
| `qr/64x1024/b1` | 0.52193 ± 0.00106585 (W 0.00207803) | 1.19668 ± 0.101403 (W 0.0125889) | 🔵 faer-fork 2.29× faster than `lapack-openblas` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/256x4096/b1` | 13.3997 ± 0.0921018 (W 0.0170082) | 37.9712 ± 0.268958 (W 0.0619158) | 🔵 faer-fork 2.83× faster than `lapack-openblas` |  |
| `qr_factor/64x1024/b1` | 0.409691 ± 0.00141012 (W 0.00183921) | 0.74671 ± 0.00761753 (W 0.00381784) | 🔵 faer-fork 1.82× faster than `lapack-openblas` |  |
| `svd_thin/256x4096/b1` | 177.618 ± 1.11974 (W 0.419312) | 372.402 ± 1.33496 (W 1.03889) | 🔵 faer-fork 2.10× faster than `lapack-openblas` |  |
| `svd_thin/64x1024/b1` | 4.8515 ± 0.0110124 (W 0.0246713) | 9.15963 ± 0.0726857 (W 0.0185164) | 🔵 faer-fork 1.89× faster than `lapack-openblas` |  |
| `svd_values/256x4096/b1` | 88.4792 ± 0.0311468 (W 0.0584087) | 187.461 ± 0.567585 (W 0.388142) | 🔵 faer-fork 2.12× faster than `lapack-openblas` |  |
| `svd_values/64x1024/b1` | 2.82023 ± 0.0179157 (W 0.00979259) | 4.70305 ± 0.0413545 (W 0.0139599) | 🔵 faer-fork 1.67× faster than `lapack-openblas` |  |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
