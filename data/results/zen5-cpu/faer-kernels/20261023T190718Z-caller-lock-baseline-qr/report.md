# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `50c2b989484f063f4e1b132adc333715391d8b73`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `f8d4122e8b66aa48675bf14600ef8ccab5da9f33`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `2a861f00554f7fbb34db33e463c615b6209813a97399a1516a65b9ee9e423476`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T19:35:25.564484Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --no-publish --checkout extern/t4a-faer --families qr_factor --label caller-lock-baseline-qr`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T190718Z-caller-lock-baseline-qr/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.99%, worst 4152.26% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 17 of 480 engine cells exceed 5% and carry `!`; median within-process relative SD 0.40%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.023273 ± 7.05006e-05 (W 0.000137202) | 0.028323 ± 0.000169195 (W 8.46416e-05) | 0.014096 ± 1e-05 (W 5.94138e-05) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.085787 ± 0.000249081 (W 0.000134652) | 0.130133 ± 7.4009e-05 (W 0.000190741) | 0.298428 ± 0.134017 (W 0.00164949) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 3.48× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.187801 ± 0.000735727 (W 0.00126897) | 0.285064 ± 0.000429027 (W 0.0022133) | 0.203808 ± 0.000942669 (W 0.00143211) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.023173 ± 4.63717e-05 (W 9.11043e-05) | 0.042338 ± 0.000296014 (W 0.00092318) | 0.014277 ± 0.00014441 (W 7.35343e-05) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.085327 ± 0.000671053 (W 0.000269088) | 0.205909 ± 0.00167159 (W 0.00161876) | 0.066262 ± 0.000302809 (W 0.000132054) | 🔵 faer-fork 2.41× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.174612 ± 0.000568508 (W 0.00128266) | 0.413873 ± 0.00395432 (W 0.00207543) | 0.187199 ± 0.000283914 (W 0.00115317) | 🔵 faer-fork 2.37× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.023252 ± 4.95076e-05 (W 0.000202559) | 0.051265 ± 0.000716549 (W 0.00126626) | 0.014066 ± 0.000238132 (W 6.98656e-05) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔴 faer-fork 1.65× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.089977 ± 2.15699 (W 0.000439289) | 0.251793 ± 0.00405934 (W 0.00221682) | 0.066194 ± 0.000115547 (W 9.34949e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.177762 ± 0.000244502 (W 0.00152805) | 0.51075 ± 0.00549936 (W 0.00417175) | 0.185096 ± 0.000508741 (W 0.0014462) | 🔵 faer-fork 2.87× faster than `faer-upstream` | · |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.017372 ± 5.50757e-05 (W 8.61934e-05) | 0.018164 ± 0.000195517 (W 0.000126491) | 0.011622 ± 4.04145e-05 (W 0.000103707) | · | 🔴 faer-fork 1.49× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.071643 ± 0.000140657 (W 0.00100257) | 0.074359 ± 0.000933962 (W 0.000341391) | 0.289252 ± 0.000267574 (W 0.00171037) | · | 🔵 faer-fork 4.04× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.1574 ± 0.000459118 (W 0.000265929) | 0.162614 ± 0.00038192 (W 0.0016948) | 0.928752 ± 0.00035177 (W 0.000838534) | · | 🔵 faer-fork 5.90× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.017293 ± 8.01686e-05 (W 0.000143597) | 0.03213 ± 0.000541185 (W 0.000615132) | 0.011562 ± 0.000127738 (W 5.96087e-05) | 🔵 faer-fork 1.86× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.070149 ± 0.000286985 (W 0.00112327) | 0.144175 ± 0.000311523 (W 0.00127982) | 0.057737 ± 4.0501e-05 (W 0.000170819) | 🔵 faer-fork 2.06× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.139647 ± 0.000957191 (W 0.00111224) | 0.282107 ± 0.00604776 (W 0.00217452) | 0.174554 ± 0.000329215 (W 0.00192063) | 🔵 faer-fork 2.02× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.017322 ± 4.04145e-05 (W 0.000108477) | 0.041015 ± 0.00134154 (W 0.00123864) | 0.011592 ± 3.95011e-05 (W 4.65833e-05) | 🔵 faer-fork 2.37× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` | `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.071943 ± 1.06813 (W 0.00102701) | 0.192911 ± 0.0022896 (W 0.00216541) | 0.057566 ± 0.000300257 (W 0.000211585) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.142294 ± 0.000496423 (W 0.00141162) | 0.377545 ± 0.00678267 (W 0.00259676) | 0.175265 ± 0.000384573 (W 0.00175475) | 🔵 faer-fork 2.65× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.039834 ± 0.000211 (W 0.00012478) | 0.044932 ± 0.00012967 (W 0.000281865) | 0.029083 ± 0.0478797 (W 8.1989e-05) | 🔵 faer-fork 1.13× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.177411 ± 0.000977932 (W 0.00116693) | 0.235758 ± 0.000906042 (W 0.000931687) | 0.166719 ± 0.000233447 (W 0.00193262) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.431914 ± 0.000765819 (W 0.00192263) | 0.53295 ± 0.00206729 (W 0.00209866) | 0.515083 ± 0.00134522 (W 0.0018865) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.040154 ± 0.000192323 (W 0.000183922) | 0.05914 ± 0.000251478 (W 0.000712262) | 0.028853 ± 0.000179723 (W 6.01664e-05) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔴 faer-fork 1.39× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.155348 ± 1.26542 (W 0.0012307) | 0.287003 ± 0.00112529 (W 0.00193738) | 0.163541 ± 0.000173329 (W 0.00123115) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.319819 ± 0.00127251 (W 0.00170013) | 0.570937 ± 0.00554465 (W 0.00317702) | 0.497913 ± 0.000704706 (W 0.00229156) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔵 faer-fork 1.56× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.040154 ± 6.95725e-05 (W 0.000159102) | 0.068768 ± 0.000261742 (W 0.00100832) | 0.028763 ± 0.000123923 (W 4.94186e-05) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.15748 ± 0.00020815 (W 0.00118091) | 0.320078 ± 0.000491176 (W 0.00511417) | 0.164282 ± 0.00032187 (W 0.000400626) | 🔵 faer-fork 2.03× faster than `faer-upstream` | · |  |
| `qr_factor/n96/b1` | 0.313552 ± 0.00136957 (W 0.00158341) | 0.635168 ± 0.000843398 (W 0.00865087) | 0.49769 ± 0.000597935 (W 0.00173954) | 🔵 faer-fork 2.03× faster than `faer-upstream` | 🔵 faer-fork 1.59× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.033062 ± 0.000328599 (W 0.000199225) | 0.033282 ± 0.000161298 (W 0.000220748) | 0.026288 ± 0.000149778 (W 5.37243e-05) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.159789 ± 0.00139 (W 0.00107547) | 0.161767 ± 0.00108721 (W 0.00147096) | 0.75451 ± 0.000682081 (W 0.00141646) | · | 🔵 faer-fork 4.72× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.392814 ± 0.00276588 (W 0.00180053) | 0.396121 ± 0.00289799 (W 0.00168237) | 2.44008 ± 0.00146938 (W 0.00159376) | · | 🔵 faer-fork 6.21× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.033311 ± 9.12707e-05 (W 0.000181569) | 0.046486 ± 0.000215064 (W 0.000686782) | 0.026309 ± 7.6922e-05 (W 4.31648e-05) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.137222 ± 0.000334626 (W 0.000791552) | 0.210995 ± 0.00311553 (W 0.00178834) | 0.155857 ± 0.000195032 (W 0.00161281) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.278651 ± 0.00172956 (W 0.00161801) | 0.421515 ± 0.000278105 (W 0.00253125) | 0.483354 ± 0.00124754 (W 0.00154126) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔵 faer-fork 1.73× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.033331 ± 0.000242929 (W 0.00149) | 0.056715 ± 0.00109648 (W 0.000940034) | 0.026218 ± 0.000121496 (W 6.8207e-05) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.137056 ± 0.00038714 (W 0.000386336) | 0.252662 ± 0.00441843 (W 0.00226305) | 0.155879 ± 0.000148233 (W 0.00176046) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.267826 ± 0.00131035 (W 0.00122527) | 0.507949 ± 0.0027475 (W 0.0028162) | 0.481733 ± 0.00132988 (W 0.00207384) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.020408 ± 0.000147604 (W 3.69757e-05) | 0.025096 ± 0.00114561 (W 0.00107344) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.08138 ± 0.0018201 (W 0.000219507) | 0.121463 ± 0.00238075 (W 0.00123394) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.178137 ± 0.00308764 (W 0.00133937) | 0.258134 ± 0.00225249 (W 0.00119799) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.020318 ± 6.48614e-05 (W 7.19027e-05) | 0.038652 ± 0.000785257 (W 0.00055653) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.081741 ± 0.00044298 (W 0.000189653) | 0.197238 ± 0.00149124 (W 0.00229628) | - | 🔵 faer-fork 2.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.165587 ± 0.000814003 (W 0.00165837) | 0.400653 ± 0.00520478 (W 0.00213463) | - | 🔵 faer-fork 2.42× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.020267 ± 7.26659e-05 (W 0.000121401) | 0.048409 ± 0.00203975 (W 0.000667615) | - | 🔵 faer-fork 2.39× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.088475 ± 0.00191701 (W 0.000749494) | 0.238993 ± 0.00359673 (W 0.00297385) | - | 🔵 faer-fork 2.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.170158 ± 0.000645114 (W 0.00124006) | 0.481042 ± 0.00737512 (W 0.0055836) | - | 🔵 faer-fork 2.83× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.016169 ± 0.000471453 (W 8.40851e-05) | 0.016951 ± 0.00111518 (W 5.25852e-05) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.067886 ± 0.00181187 (W 0.000123572) | 0.069028 ± 0.00160033 (W 0.000188972) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.147554 ± 0.00335663 (W 0.000252185) | 0.152553 ± 0.00293081 (W 0.000349804) | - | · | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.01611 ± 0.000131683 (W 0.00156855) | 0.030246 ± 0.000404045 (W 0.000215001) | - | 🔵 faer-fork 1.88× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.066164 ± 0.000409964 (W 0.000177964) | 0.139822 ± 0.00163329 (W 0.00139678) | - | 🔵 faer-fork 2.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.131826 ± 0.00160952 (W 0.00174946) | 0.27785 ± 0.00270718 (W 0.00257782) | - | 🔵 faer-fork 2.11× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.016771 ± 0.000410983 (W 6.14817e-05) | 0.040545 ± 0.00134656 (W 0.00100313) | - | 🔵 faer-fork 2.42× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.067445 ± 0.00025322 (W 0.000275429) | 0.184773 ± 0.0022386 (W 0.00168913) | - | 🔵 faer-fork 2.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.133306 ± 0.00057505 (W 0.00162608) | 0.3723 ± 0.00812375 (W 0.00437989) | - | 🔵 faer-fork 2.79× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.030797 ± 4.04145e-05 (W 0.000194803) | 0.035035 ± 0.000134128 (W 8.2117e-05) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.125873 ± 0.000563691 (W 0.00135093) | 0.180477 ± 0.000320431 (W 0.00119179) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.292556 ± 0.00128848 (W 0.00135054) | 0.407862 ± 0.000546028 (W 0.0015148) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.030756 ± 5.10327e-05 (W 6.54164e-05) | 0.049492 ± 0.00023774 (W 0.000506237) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.115843 ± 0.000178164 (W 0.000752617) | 0.247569 ± 0.00212967 (W 0.00174081) | - | 🔵 faer-fork 2.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.235501 ± 0.000397055 (W 0.00109645) | 0.490783 ± 0.00275768 (W 0.00285188) | - | 🔵 faer-fork 2.08× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.030717 ± 8.14269e-05 (W 0.000114583) | 0.058277 ± 0.00104552 (W 0.000587475) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.117297 ± 0.000327894 (W 0.00127791) | 0.274065 ± 0.00122026 (W 0.00420677) | - | 🔵 faer-fork 2.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.232354 ± 0.000144001 (W 0.00148585) | 0.54997 ± 0.00615342 (W 0.0078362) | - | 🔵 faer-fork 2.37× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.025397 ± 0.000134536 (W 0.000100121) | 0.026038 ± 0.000210792 (W 0.000100842) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.109062 ± 0.00043516 (W 0.00122218) | 0.109856 ± 9.1e-05 (W 0.00118271) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.255017 ± 0.00146001 (W 0.00147948) | 0.256069 ± 0.00185359 (W 0.00161082) | - | · | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.025427 ± 0.000111355 (W 0.000114324) | 0.039343 ± 0.000349309 (W 0.000378078) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.097462 ± 0.000101106 (W 0.00106642) | 0.170764 ± 0.000644252 (W 0.0010389) | - | 🔵 faer-fork 1.75× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.195559 ± 0.00033278 (W 0.000991665) | 0.341308 ± 0.00133296 (W 0.00225058) | - | 🔵 faer-fork 1.75× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.025417 ± 6.17333e-05 (W 9.32647e-05) | 0.047778 ± 0.000362326 (W 0.000523438) | - | 🔵 faer-fork 1.88× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.098111 ± 0.000482473 (W 0.00128972) | 0.215116 ± 0.000620991 (W 0.00285761) | - | 🔵 faer-fork 2.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.191425 ± 0.00111274 (W 0.00134346) | 0.421312 ± 0.00451558 (W 0.00214946) | - | 🔵 faer-fork 2.20× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/32`, `qr_factor/64`, `qr_factor/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.325694 ± 0.00174029 (W 0.001628) | 0.531188 ± 0.00109201 (W 0.00263892) | 0.370021 ± 0.00192692 (W 0.00334964) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.58008 ± 0.0102005 (W 0.00249015) | 2.88095 ± 0.00359987 (W 0.00479177) | 2.0476 ± 0.00943231 (W 0.00444616) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.83211 ± 0.0926512 (W 0.0174914) | 17.5794 ± 0.0282276 (W 0.0201744) | 14.2186 ± 0.0238915 (W 0.0302145) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.61× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.274055 ± 0.000503597 (W 0.00162828) | 0.714245 ± 0.00460917 (W 0.00248954) | 0.1983 ± 0.00133972 (W 0.001056) | 🔵 faer-fork 2.61× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.10995 ± 0.0167179 (W 0.00285541) | 3.11181 ± 0.0118043 (W 0.0134002) | 0.669241 ± 0.00116188 (W 0.00365518) | 🔵 faer-fork 2.80× faster than `faer-upstream` | 🔴 faer-fork 1.66× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.39418 ± 0.0305926 (W 0.00803308) | 16.5187 ± 0.111245 (W 0.0643027) | 3.86349 ± 0.00852446 (W 0.00764302) | 🔵 faer-fork 3.76× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.273715 ± 0.00261386 (W 0.00269039) | 0.818941 ± 0.00639526 (W 0.00413585) | 0.156318 ± 0.000253963 (W 0.00173828) | 🔵 faer-fork 2.99× faster than `faer-upstream` | 🔴 faer-fork 1.75× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.07283 ± 0.00671048 (W 0.00397468) | 3.33741 ± 0.0190037 (W 0.0180624) | 0.574982 ± 0.00217273 (W 0.00209086) | 🔵 faer-fork 3.11× faster than `faer-upstream` | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 3.8354 ± 0.0343984 (W 0.0150614) | 16.7682 ± 0.120409 (W 0.047032) | 2.30116 ± 0.00959368 (W 0.00398714) | 🔵 faer-fork 4.37× faster than `faer-upstream` | 🔴 faer-fork 1.67× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.271911 ± 0.00267962 (W 0.00162621) | 0.276609 ± 0.0021777 (W 0.00141941) | 0.333964 ± 0.000833041 (W 0.00244838) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.36573 ± 0.00959738 (W 0.00260221) | 1.37489 ± 0.00883088 (W 0.00243029) | 1.8935 ± 0.0110566 (W 0.00721394) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.92725 ± 0.079034 (W 0.00766498) | 7.97081 ± 0.0805683 (W 0.00472793) | 13.4167 ± 0.0497872 (W 0.0159032) | · | 🔵 faer-fork 1.69× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.21723 ± 0.00219195 (W 0.00157973) | 0.418226 ± 0.00660749 (W 0.001306) | 0.183233 ± 6.03573e-05 (W 0.00214522) | 🔵 faer-fork 1.93× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.87757 ± 0.00551625 (W 0.00247159) | 1.31219 ± 0.00720639 (W 0.00411617) | 0.617915 ± 0.00204811 (W 0.00357967) | 🔵 faer-fork 1.50× faster than `faer-upstream` | 🔴 faer-fork 1.42× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 3.52309 ± 0.0449394 (W 0.00428853) | 4.41321 ± 0.0141905 (W 0.00749974) | 3.6638 ± 0.0259743 (W 0.0059372) | 🔵 faer-fork 1.25× faster than `faer-upstream` | · |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.214128 ± 0.00175188 (W 0.00102138) | 0.536129 ± 0.0141053 (W 0.0033797) | 0.145622 ± 5.40278e-05 (W 0.00168228) | 🔵 faer-fork 2.50× faster than `faer-upstream` | 🔴 faer-fork 1.47× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.838287 ± 0.00312697 (W 0.00337634) | 1.5818 ± 0.0161059 (W 0.00837638) | 0.541359 ± 0.00510148 (W 0.00231312) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 2.96133 ± 0.0167743 (W 0.00483898) | 4.77768 ± 0.0659551 (W 0.0296355) | 2.24774 ± 0.0123624 (W 0.00314932) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔴 faer-fork 1.32× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.820141 ± 0.00560917 (W 0.00224036) | 1.06589 ± 0.00543835 (W 0.00175233) | 0.954859 ± 0.000970434 (W 0.00106999) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.82419 ± 0.03981 (W 0.00627786) | 6.47918 ± 0.0886159 (W 0.00750596) | 5.66335 ± 0.0123862 (W 0.00778833) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.6776 ± 0.186273 (W 0.0212661) | 37.8756 ± 0.0183688 (W 0.0211761) | 38.9985 ± 0.0597012 (W 0.0495318) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.537351 ± 0.00284569 (W 0.00291516) | 1.00363 ± 0.00607212 (W 0.00379055) | 0.452674 ± 0.00201562 (W 0.00152103) | 🔵 faer-fork 1.87× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.53551 ± 0.0172573 (W 0.00651434) | 4.80973 ± 0.104091 (W 0.0129174) | 1.63023 ± 0.00421892 (W 0.00354474) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔴 faer-fork 1.56× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 11.709 ± 0.206892 (W 0.0463836) | 21.681 ± 0.123588 (W 0.0558989) | 11.3843 ± 0.0366161 (W 0.0174754) | 🔵 faer-fork 1.85× faster than `faer-upstream` | · |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.496748 ± 0.0037723 (W 0.00230756) | 1.07563 ± 0.0113635 (W 0.00783423) | 0.32143 ± 0.00180674 (W 0.00308402) | 🔵 faer-fork 2.17× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.11271 ± 0.0157801 (W 0.00534189) | 4.78685 ± 0.0954905 (W 0.019028) | 1.61641 ± 0.00437597 (W 0.00528868) | 🔵 faer-fork 2.27× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.15231 ± 0.0336467 (W 0.0344105) | 20.2268 ± 0.153433 (W 0.203456) | 5.78888 ± 0.00404713 (W 0.00662648) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.746675 ± 0.00614928 (W 0.00212845) | 0.754811 ± 0.00639698 (W 0.00179255) | 0.91062 ± 0.00177954 (W 0.00160657) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.46891 ± 0.0113374 (W 0.00296059) | 4.49859 ± 0.00818806 (W 0.00224013) | 5.49754 ± 0.00768603 (W 0.00917926) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 28.9445 ± 0.0343401 (W 0.0107344) | 29.019 ± 0.0386313 (W 0.00636094) | 37.9661 ± 0.052366 (W 0.032686) | · | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.45787 ± 0.00152399 (W 0.00195696) | 0.660115 ± 0.00688568 (W 0.00163992) | 0.434521 ± 0.00334584 (W 0.0021564) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.24607 ± 0.0187615 (W 0.00255503) | 2.59112 ± 0.0289449 (W 0.00391901) | 1.6041 ± 0.0216604 (W 0.00355878) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.89038 ± 0.0875292 (W 0.0117917) | 10.7491 ± 0.102531 (W 0.00922979) | 10.9919 ± 0.135294 (W 0.011518) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.417655 ± 0.001134 (W 0.00163104) | 0.755804 ± 0.0145518 (W 0.00244668) | 0.307695 ± 0.00247545 (W 0.00233051) | 🔵 faer-fork 1.81× faster than `faer-upstream` | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.78783 ± 0.00509491 (W 0.00362395) | 2.67023 ± 0.0320864 (W 0.0165476) | 1.57628 ± 0.00302929 (W 0.00257117) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.38187 ± 0.0206548 (W 0.0115856) | 9.9474 ± 0.0421007 (W 0.106511) | 5.79134 ± 0.0143503 (W 0.00851145) | 🔵 faer-fork 1.35× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.300964 ± 0.00141209 (W 0.0015327) | 0.445931 ± 0.00156174 (W 0.0014751) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.15496 ± 0.00111033 (W 0.00211646) | 1.77603 ± 0.00428597 (W 0.00270659) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.6226 ± 0.0126704 (W 0.0258999) | 10.3588 ± 0.0343635 (W 0.00889049) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.259786 ± 0.00100186 (W 0.00173795) | 0.646268 ± 0.00152888 (W 0.00596492) | - | 🔵 faer-fork 2.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.948992 ± 0.00224869 (W 0.00210553) | 2.33737 ± 0.0270086 (W 0.0106226) | - | 🔵 faer-fork 2.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.45884 ± 0.0240598 (W 0.0110715) | 10.8715 ± 0.0579601 (W 0.0398386) | - | 🔵 faer-fork 3.14× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.258613 ± 0.00111146 (W 0.00197604) | 0.752309 ± 0.0251553 (W 0.00832314) | - | 🔵 faer-fork 2.91× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n256/b1` | 0.949244 ± 0.00312093 (W 0.00260758) | 2.6157 ± 0.0312439 (W 0.0168091) | - | 🔵 faer-fork 2.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.25733 ± 0.0276384 (W 0.0229664) | 11.2085 ± 0.0611232 (W 0.0437045) | - | 🔵 faer-fork 3.44× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.248628 ± 0.000589241 (W 0.00122088) | 0.251203 ± 0.0029556 (W 0.00191054) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.946477 ± 0.000255125 (W 0.0009086) | 0.953159 ± 0.00145645 (W 0.00190604) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.73449 ± 0.0142264 (W 0.00281772) | 4.74904 ± 0.0255506 (W 0.00447311) | - | · | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.202416 ± 0.00126898 (W 0.0011731) | 0.405182 ± 0.00285887 (W 0.00221865) | - | 🔵 faer-fork 2.00× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.728842 ± 0.00408943 (W 0.00180211) | 1.17001 ± 0.0135378 (W 0.00357998) | - | 🔵 faer-fork 1.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 2.57028 ± 0.00491722 (W 0.00985002) | 3.51192 ± 0.0235578 (W 0.0105202) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.201184 ± 0.000445121 (W 0.0015618) | 0.540343 ± 0.00110532 (W 0.00151601) | - | 🔵 faer-fork 2.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.72806 ± 0.002505 (W 0.00205172) | 1.43751 ± 0.00848261 (W 0.00468199) | - | 🔵 faer-fork 1.97× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 2.33279 ± 0.0227555 (W 0.00291716) | 4.09622 ± 0.0486757 (W 0.0144942) | - | 🔵 faer-fork 1.76× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.535601 ± 0.000719412 (W 0.00165641) | 0.752286 ± 0.00454468 (W 0.00206446) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.76591 ± 0.0105747 (W 0.00492776) | 3.80648 ± 0.00578996 (W 0.00574763) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 16.3725 ± 0.144043 (W 0.00852304) | 24.3736 ± 0.109675 (W 0.0442403) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.383843 ± 0.00296567 (W 0.00192589) | 0.809282 ± 0.0119926 (W 0.00468763) | - | 🔵 faer-fork 2.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.62912 ± 0.00938073 (W 0.00236155) | 3.30351 ± 0.00927979 (W 0.0113429) | - | 🔵 faer-fork 2.03× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 6.91323 ± 0.0777764 (W 0.010001) | 17.3359 ± 0.125576 (W 0.0626272) | - | 🔵 faer-fork 2.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.366046 ± 0.00060472 (W 0.00281697) | 0.848496 ± 0.00737355 (W 0.0114684) | - | 🔵 faer-fork 2.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.47927 ± 0.0129738 (W 0.00306762) | 3.42486 ± 0.0310798 (W 0.0178185) | - | 🔵 faer-fork 2.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.67705 ± 0.023353 (W 0.0143522) | 16.6315 ± 0.108325 (W 0.0708987) | - | 🔵 faer-fork 2.93× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.466422 ± 0.0038556 (W 0.00122098) | 0.470608 ± 0.00281161 (W 0.00144203) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.50368 ± 0.0103387 (W 0.00228239) | 2.517 ± 0.0100902 (W 0.00349865) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 15.2498 ± 0.0317164 (W 0.0135724) | 15.3107 ± 0.0388298 (W 0.0117536) | - | · | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.316287 ± 0.00185607 (W 0.00183228) | 0.513861 ± 0.00668944 (W 0.00189339) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.35378 ± 0.00374091 (W 0.00236786) | 1.78573 ± 0.0107331 (W 0.00449386) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.91708 ± 0.016728 (W 0.00343546) | 6.84317 ± 0.0165235 (W 0.00971667) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.296638 ± 0.000680895 (W 0.00225798) | 0.607258 ± 0.010671 (W 0.00251709) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.19445 ± 0.00378299 (W 0.0034447) | 1.95829 ± 0.0140858 (W 0.00856646) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.48564 ± 0.0199369 (W 0.00373806) | 6.47156 ± 0.0642096 (W 0.0659725) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/128`, `qr_factor/256`, `qr_factor/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.03728 ± 0.00808273 (W 0.00267316) | 1.87131 ± 0.0100529 (W 0.00537) | 0.906753 ± 0.00223441 (W 0.00291464) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 32.5238 ± 0.419686 (W 0.101383) | 78.085 ± 0.177776 (W 0.0695366) | 35.0773 ± 0.0228812 (W 0.072672) | 🔵 faer-fork 2.40× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.97808 ± 0.0135145 (W 0.0027869) | 3.04248 ± 0.055731 (W 0.0917392) | 0.456705 ± 0.00371365 (W 0.00560228) | 🔵 faer-fork 3.11× faster than `faer-upstream` | 🔴 faer-fork 2.14× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.5878 ± 0.563544 (W 0.157359) | 73.8942 ± 0.38433 (W 0.430264) | 12.7354 ± 0.0509531 (W 0.0800296) | 🔵 faer-fork 2.68× faster than `faer-upstream` | 🔴 faer-fork 2.17× slower than `lapack-mkl` |  |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.03795 ± 0.0199046 (W 0.00342076) | 3.09209 ± 0.0580773 (W 0.0929158) | 0.320536 ± 0.000552866 (W 0.00177279) | 🔵 faer-fork 2.98× faster than `faer-upstream` | 🔴 faer-fork 3.24× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 27.8332 ± 0.925191 (W 0.113417) | 71.6853 ± 0.12155 (W 0.176301) | 7.25218 ± 0.0738836 (W 0.0370091) | 🔵 faer-fork 2.58× faster than `faer-upstream` | 🔴 faer-fork 3.84× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.789557 ± 0.00262545 (W 0.00241147) | 0.788414 ± 0.000595119 (W 0.00256115) | 0.76794 ± 0.00315761 (W 0.00245595) | · | · |  |
| `qr_factor/4096x256/b1` | 25.962 ± 0.116154 (W 0.0337912) | 25.9728 ± 0.132781 (W 0.0346185) | 28.919 ± 0.127951 (W 0.018522) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.735646 ± 0.00153971 (W 0.00198412) | 0.829244 ± 0.000547526 (W 0.00414237) | 0.422551 ± 0.00469385 (W 0.00806546) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 21.2533 ± 0.187348 (W 0.0323469) | 15.5385 ± 0.210046 (W 0.0170774) | 11.3299 ± 0.12103 (W 0.0947921) | 🔴 faer-fork 1.37× slower than `faer-upstream` | 🔴 faer-fork 1.88× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.782636 ± 0.000562861 (W 0.00349865) | 0.927775 ± 0.00738095 (W 0.00545179) | 0.303221 ± 0.000522357 (W 0.00250119) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 2.58× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 20.8138 ± 0.0579604 (W 0.0594514) | 16.4715 ± 0.0722199 (W 0.0614206) | 6.52619 ± 0.00690001 (W 0.0480398) | 🔴 faer-fork 1.26× slower than `faer-upstream` | 🔴 faer-fork 3.19× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.54452 ± 0.0246825 (W 0.00427286) | 4.07196 ± 0.0887906 (W 0.0166164) | 2.38461 ± 0.00370709 (W 0.00328477) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 101.703 ± 0.103976 (W 0.0627471) | 175.605 ± 0.3157 (W 0.423684) | 109.991 ± 0.442839 (W 0.51189) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.35074 ± 0.0194686 (W 0.005499) | 3.91407 ± 0.18732 (W 0.0381016) | 1.39045 ± 0.00209122 (W 0.0399431) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔴 faer-fork 1.69× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 78.4681 ± 0.150581 (W 0.0740012) | 129.114 ± 0.555546 (W 0.555375) | 33.8952 ± 0.0146278 (W 0.180649) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 2.32× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.35854 ± 0.0216025 (W 0.0125523) | 3.8884 ± 0.0732771 (W 0.074739) | 0.87161 ± 0.00329409 (W 0.00250367) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 2.71× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 75.3542 ± 0.297064 (W 0.0760676) | 124.176 ± 1.30203 (W 1.30677) | 19.6436 ± 0.193979 (W 0.111477) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 3.84× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.31542 ± 0.0160519 (W 0.00384179) | 2.31121 ± 0.0258629 (W 0.00312392) | 2.2524 ± 0.0117978 (W 0.00440077) | · | · |  |
| `qr_factor/4096x256/b1` | 90.7593 ± 0.0655478 (W 0.04691) | 90.3929 ± 0.0801661 (W 0.0656009) | 105.004 ± 1.14621 (W 0.328572) | · | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.99773 ± 0.0232457 (W 0.00378064) | 1.56995 ± 0.0234409 (W 0.00463242) | 1.34867 ± 0.0118349 (W 0.00341649) | 🔴 faer-fork 1.27× slower than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 67.7926 ± 0.501501 (W 0.111751) | 42.2423 ± 0.472204 (W 0.024169) | 31.7884 ± 0.335416 (W 0.123036) | 🔴 faer-fork 1.60× slower than `faer-upstream` | 🔴 faer-fork 2.13× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.07686 ± 0.0102769 (W 0.00724657) | 1.66324 ± 0.00241413 (W 0.00958614) | 0.86072 ± 0.00123243 (W 0.00132945) | 🔴 faer-fork 1.25× slower than `faer-upstream` | 🔴 faer-fork 2.41× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 64.2987 ± 0.139076 (W 0.0958626) | 39.5634 ± 0.276546 (W 0.499995) | 17.823 ± 0.078051 (W 0.153573) | 🔴 faer-fork 1.63× slower than `faer-upstream` | 🔴 faer-fork 3.61× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.851826 ± 0.00916391 (W 0.00151421) | 1.52144 ± 0.00291858 (W 0.00168531) | - | 🔵 faer-fork 1.79× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 20.3782 ± 0.161706 (W 0.137616) | 51.2026 ± 0.264671 (W 0.0849729) | - | 🔵 faer-fork 2.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.85547 ± 0.00947969 (W 0.00647354) | 2.15934 ± 0.0155231 (W 0.0355038) | - | 🔵 faer-fork 2.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 18.1277 ± 0.153492 (W 0.127192) | 51.7385 ± 0.145497 (W 0.444172) | - | 🔵 faer-fork 2.85× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.927875 ± 0.00330155 (W 0.00399645) | 2.23156 ± 0.0184527 (W 0.0300557) | - | 🔵 faer-fork 2.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 18.4772 ± 0.585266 (W 0.11133) | 51.7278 ± 0.197766 (W 0.131393) | - | 🔵 faer-fork 2.80× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.617381 ± 0.00560451 (W 0.00203821) | 0.620267 ± 0.00602431 (W 0.00195982) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 15.6836 ± 0.184427 (W 0.00562553) | 15.7329 ± 0.154569 (W 0.00751283) | - | · | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.606167 ± 0.00235061 (W 0.00195588) | 0.740176 ± 0.000953114 (W 0.00315278) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 13.3734 ± 0.0752727 (W 0.0130766) | 10.9177 ± 0.105585 (W 0.0136072) | - | 🔴 faer-fork 1.22× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.642641 ± 0.00206457 (W 0.00293293) | 0.838274 ± 0.00565012 (W 0.00344889) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 13.4193 ± 0.0622558 (W 0.0538128) | 11.9795 ± 0.187597 (W 0.0387608) | - | 🔴 faer-fork 1.12× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.68071 ± 0.00325496 (W 0.00246808) | 3.22538 ± 0.00173208 (W 0.00171442) | - | 🔵 faer-fork 1.92× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 56.8463 ± 0.0776908 (W 0.112759) | 97.6702 ± 0.170227 (W 0.119038) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.50932 ± 0.0022459 (W 0.0035043) | 3.62631 ± 0.057078 (W 0.0727548) | - | 🔵 faer-fork 2.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 45.1721 ± 0.516324 (W 0.141558) | 76.2189 ± 0.66203 (W 0.340857) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.53718 ± 0.0114137 (W 0.00435056) | 3.35094 ± 0.10101 (W 0.107359) | - | 🔵 faer-fork 2.18× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 44.7149 ± 0.056326 (W 0.1554) | 74.2561 ± 0.450903 (W 0.324743) | - | 🔵 faer-fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.38315 ± 0.0166619 (W 0.00309203) | 1.40522 ± 0.0135505 (W 0.00252879) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 49.684 ± 0.0454864 (W 0.0212845) | 50.1913 ± 0.0781143 (W 0.0441171) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.20208 ± 0.000864001 (W 0.00258992) | 1.18814 ± 0.000925617 (W 0.00441544) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 38.242 ± 0.355232 (W 0.027638) | 26.4227 ± 0.427755 (W 0.0229577) | - | 🔴 faer-fork 1.45× slower than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.24113 ± 0.00654387 (W 0.00366476) | 1.29351 ± 0.00486851 (W 0.00628412) | - | · | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 36.6292 ± 0.0218366 (W 0.0613561) | 25.5468 ± 0.136814 (W 0.259506) | - | 🔴 faer-fork 1.43× slower than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/1024x64`, `qr_factor/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
