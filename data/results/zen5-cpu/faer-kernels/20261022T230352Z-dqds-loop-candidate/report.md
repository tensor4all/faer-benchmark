# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `118e427276814315a5fe6b17ce0eb4962590c17e`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `34a75d77ed1fec5e94db10427c34b9ac95f01ad8`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `881fa0c6ae9d3d3ed8a930768aed3ea102fdcc1a1377b011ba4c2ff0151b3a1c`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-22T23:08:44.734844Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small --families svd_values,svd_thin,qr_factor,eigh --shapes 32,64 --dtypes f64,c64,f32,c32 --threads 4,8 --reps 5 --aa 3 --prime-ms 250 --label dqds-loop-candidate --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261022T230352Z-dqds-loop-candidate/`

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
- CPU sets: 4T -> `4-7`, 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 5 chronological calls; 3 complete process sets are recorded.
Spread guide (computed from this run's own rows): per-engine between-start range median 0.70%, worst 287.23% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 30 of 320 engine cells exceed 5% and carry `!`; median within-process relative SD 0.67%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112613 ± 0.000241137 (W 0.000388165) | 0.113093 ± 0.000286758 (W 0.00153467) | 0.105769 ± 0.000207625 (W 0.000828591) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.500567 ± 0.00135507 (W 0.00240504) | 0.504199 ± 0.00150963 (W 0.00282874) | 0.271782 ± 0.000630777 (W 0.00179851) | · | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023464 ± 7.02377e-05 (W 0.000142552) | 0.089329 ± 0.00130841 (W 0.00358638) | 0.014107 ± 2.70247e-05 (W 8.05748e-05) | 🔵 faer-fork 3.81× faster than `faer-upstream` | 🔴 faer-fork 1.66× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.105519 ± 0.00122578 (W 0.0020832) | 0.478315 ± 0.00104221 (W 0.00879982) | 0.299246 ± 0.134613 (W 0.00172541) | 🔵 faer-fork 4.53× faster than `faer-upstream` | 🔵 faer-fork 2.84× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.183486 ± 0.000992335 (W 0.00176837) | 0.183928 ± 0.000439819 (W 0.00175434) | 0.18539 ± 0.000411822 (W 0.00122483) | · | · |  |
| `svd_thin/n64/b1` | 0.94587 ± 0.000542296 (W 0.00171129) | 0.950277 ± 0.00488612 (W 0.00328951) | 0.670414 ± 0.00389019 (W 0.00208485) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.129324 ± 0.000229674 (W 0.00180336) | 0.140495 ± 0.000233804 (W 0.000181613) | 0.064451 ± 0.0427843 (W 0.00114717) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔴 faer-fork 2.01× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.479845 ± 0.00289024 (W 0.00192078) | 0.517135 ± 0.00137109 (W 0.00177319) | 0.270011 ± 0.00087273 (W 0.00183815) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.78× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112191 ± 0.000133493 (W 0.000289467) | 0.112933 ± 0.000513865 (W 0.00019374) | 0.106901 ± 0.000191547 (W 0.00157464) | · | · |  |
| `eigh/n64/b1` | 0.506784 ± 0.000888951 (W 0.00257343) | 0.508941 ± 0.00202737 (W 0.00651092) | 0.263545 ± 0.000575536 (W 0.00164506) | · | 🔴 faer-fork 1.92× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.023545 ± 7.99396e-05 (W 9.88433e-05) | 0.121709 ± 0.00135194 (W 0.00330217) | 0.013996 ± 7.25971e-05 (W 7.05642e-05) | 🔵 faer-fork 5.17× faster than `faer-upstream` | 🔴 faer-fork 1.68× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.110729 ± 0.00351543 (W 0.00143547) | 0.62971 ± 0.00962668 (W 0.00968431) | 0.298583 ± 0.134011 (W 0.00139807) | 🔵 faer-fork 5.69× faster than `faer-upstream` | 🔵 faer-fork 2.70× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.182583 ± 0.000744669 (W 0.00137903) | 0.183487 ± 0.000185032 (W 0.0011872) | 0.187144 ± 0.000789576 (W 0.00155211) | · | · |  |
| `svd_thin/n64/b1` | 0.967958 ± 0.001867 (W 0.00340961) | 0.970277 ± 0.00984582 (W 0.00589003) | 0.66176 ± 0.00530559 (W 0.00194263) | · | 🔴 faer-fork 1.46× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.129916 ± 0.000507794 (W 0.00137116) | 0.140615 ± 0.000761149 (W 0.00148369) | 0.064321 ± 0.0430617 (W 0.000160001) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 2.02× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.479186 ± 0.00103589 (W 0.00173236) | 0.517946 ± 0.00178733 (W 0.00183534) | 0.270751 ± 0.000513577 (W 0.00133918) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.77× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112593 ± 0.000410853 (W 0.000158974) | 0.113465 ± 0.000304392 (W 0.00149894) | 0.103855 ± 0.000236293 (W 0.00108304) | · | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.498257 ± 0.000946654 (W 0.00298082) | 0.501694 ± 0.00690747 (W 0.00349389) | 0.266152 ± 0.000933286 (W 0.00207764) | · | 🔴 faer-fork 1.87× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017173 ± 4.7085e-05 (W 9.27701e-05) | 0.077938 ± 0.0326719 (W 0.00503941) | 0.011462 ± 0.000117898 (W 8.42508e-05) | 🔵 faer-fork 4.54× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.102043 ± 0.00433427 (W 0.00752714) | 0.416965 ± 0.00960731 (W 0.00821267) | 0.289788 ± 2.62869e-05 (W 0.00156625) | 🔵 faer-fork 4.09× faster than `faer-upstream` | 🔵 faer-fork 2.84× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.18554 ± 0.00122692 (W 0.00143284) | 0.186091 ± 0.000565803 (W 0.000774582) | 0.176464 ± 0.000144341 (W 0.000489388) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.990874 ± 0.00141698 (W 0.00301354) | 0.993424 ± 0.00882668 (W 0.0156237) | 0.646864 ± 0.00324221 (W 0.00243617) | · | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.134544 ± 0.000181368 (W 0.000235509) | 0.142339 ± 0.000443602 (W 0.00122461) | 0.059353 ± 8.72372e-05 (W 0.00169124) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 2.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.47792 ± 0.00096053 (W 0.0022976) | 0.538345 ± 0.000303346 (W 0.00229885) | 0.258178 ± 0.00131581 (W 0.00192835) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.85× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.112401 ± 0.000873439 (W 0.00109995) | 0.113193 ± 0.000301271 (W 0.000183793) | 0.105398 ± 0.000327623 (W 0.00108448) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.507659 ± 0.00281057 (W 0.00297201) | 0.50805 ± 0.00668675 (W 0.00424434) | 0.257504 ± 0.000340031 (W 0.00154128) | · | 🔴 faer-fork 1.97× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.017192 ± 0.000180832 (W 0.000108122) | 0.112721 ± 0.00247365 (W 0.0104795) | 0.011552 ± 4.04145e-05 (W 5.46553e-05) | 🔵 faer-fork 6.56× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.090642 ± 0.000600992 (W 0.000826862) | 0.57816 ± 0.00559299 (W 0.0146908) | 0.289557 ± 0.000302591 (W 0.00150656) | 🔵 faer-fork 6.38× faster than `faer-upstream` | 🔵 faer-fork 3.19× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.184778 ± 0.00136243 (W 0.00163814) | 0.185329 ± 0.000584836 (W 0.00121673) | 0.178367 ± 0.00054182 (W 0.00126717) | · | · |  |
| `svd_thin/n64/b1` | 1.01285 ± 0.00255068 (W 0.0028944) | 1.01233 ± 0.00814073 (W 0.00491298) | 0.636456 ± 0.00517082 (W 0.00222958) | · | 🔴 faer-fork 1.59× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.135025 ± 0.000180666 (W 0.00126074) | 0.142348 ± 0.000561976 (W 0.00136846) | 0.059262 ± 0.000191808 (W 0.000167004) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 2.28× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.477147 ± 0.00154231 (W 0.00143946) | 0.538542 ± 0.00184852 (W 0.00153942) | 0.259019 ± 0.001238 (W 0.0014796) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔴 faer-fork 1.84× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141326 ± 0.00018124 (W 0.00167464) | 0.141687 ± 9.11976e-05 (W 0.00137741) | 0.156274 ± 0.000121865 (W 0.00116064) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.637897 ± 0.00347516 (W 0.00305637) | 0.636985 ± 0.00274194 (W 0.00445668) | 0.567203 ± 0.000217415 (W 0.001192) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039936 ± 0.000207608 (W 0.000261428) | 0.110799 ± 0.00212158 (W 0.00372712) | 0.029105 ± 0.0477642 (W 0.000117691) | 🔵 faer-fork 2.77× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.18527 ± 0.0111527 (W 0.0114519) | 0.615574 ± 0.0169973 (W 0.0112662) | 0.762057 ± 0.345439 (W 0.00104851) | 🔵 faer-fork 3.32× faster than `faer-upstream` | 🔵 faer-fork 4.11× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.233692 ± 0.000318437 (W 0.00118672) | 0.234471 ± 5.87736e-05 (W 0.00157019) | 0.261112 ± 0.00116697 (W 0.00130749) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.1938 ± 0.00199381 (W 0.00227199) | 1.19672 ± 0.00317847 (W 0.00360649) | 1.09035 ± 0.03639 (W 0.00267429) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.149281 ± 0.000370009 (W 0.00138133) | 0.161453 ± 9.942e-05 (W 0.00125673) | 0.102233 ± 0.122177 (W 0.00152895) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.589539 ± 0.00189878 (W 0.00240274) | 0.651171 ± 0.00107612 (W 0.00157277) | 0.490358 ± 0.000865494 (W 0.00146297) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141526 ± 0.000461683 (W 0.0014552) | 0.141957 ± 0.000151725 (W 0.00157525) | 0.157216 ± 0.000216943 (W 0.00113925) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.64095 ± 0.00375133 (W 0.00365102) | 0.646495 ± 0.00189919 (W 0.00549855) | 0.539816 ± 0.00225396 (W 0.00177221) | · | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.039915 ± 0.000165802 (W 0.00136957) | 0.137338 ± 0.00177601 (W 0.00396041) | 0.028944 ± 0.0479407 (W 0.000120484) | 🔵 faer-fork 3.44× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.176102 ± 0.000141083 (W 0.00443036) | 0.762056 ± 0.00461081 (W 0.0125436) | 0.763839 ± 0.345877 (W 0.00133867) | 🔵 faer-fork 4.33× faster than `faer-upstream` | 🔵 faer-fork 4.34× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n32/b1` | 0.232977 ± 0.00990294 (W 0.00209788) | 0.23443 ± 0.00898184 (W 0.00167466) | 0.263397 ± 0.000663102 (W 0.00123697) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.20793 ± 0.00517343 (W 0.00427168) | 1.225 ± 0.00210759 (W 0.0112154) | 1.07437 ± 0.0478886 (W 0.00495852) | · | 🔴 faer-fork 1.12× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.149593 ± 0.000398725 (W 0.00141219) | 0.161445 ± 0.000186658 (W 0.000183843) | 0.102924 ± 0.121532 (W 0.00148742) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.587918 ± 0.000416184 (W 0.00255045) | 0.650294 ± 0.00145432 (W 0.00154395) | 0.49342 ± 0.00286276 (W 0.00139787) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141456 ± 0.000353951 (W 0.00139506) | 0.141727 ± 0.000234962 (W 0.00147977) | 0.15375 ± 0.000123818 (W 0.000857604) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.638413 ± 0.00124943 (W 0.00253598) | 0.63615 ± 0.000537122 (W 0.00340603) | 0.555106 ± 0.00197244 (W 0.00208072) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.032641 ± 0.000351143 (W 0.000340665) | 0.095961 ± 0.000473014 (W 0.00501472) | 0.026239 ± 0.0001305 (W 7.48953e-05) | 🔵 faer-fork 2.94× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.154291 ± 0.00822585 (W 0.00316276) | 0.502858 ± 0.00461817 (W 0.00832377) | 0.755785 ± 0.00106629 (W 0.00134957) | 🔵 faer-fork 3.26× faster than `faer-upstream` | 🔵 faer-fork 4.90× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.230974 ± 0.0004556 (W 0.00133101) | 0.231998 ± 0.000877677 (W 0.000915317) | 0.257105 ± 0.000457447 (W 0.00132397) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.22316 ± 0.00361397 (W 0.00231477) | 1.22287 ± 0.00700973 (W 0.00343693) | 1.03237 ± 0.015154 (W 0.00370635) | · | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.152298 ± 0.000326523 (W 0.00167369) | 0.15921 ± 0.00025632 (W 0.00117193) | 0.100418 ± 0.000213125 (W 0.00130875) | · | 🔴 faer-fork 1.52× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.59214 ± 0.00122686 (W 0.00202717) | 0.627243 ± 0.000200397 (W 0.00199706) | 0.479655 ± 0.000716814 (W 0.00190006) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.141676 ± 0.000295705 (W 0.000260246) | 0.142157 ± 0.00012268 (W 0.00114709) | 0.155032 ± 0.000107472 (W 0.00121274) | · | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `eigh/n64/b1` | 0.645976 ± 0.00308444 (W 0.00380072) | 0.647492 ± 0.00548654 (W 0.00747308) | 0.529978 ± 0.00285893 (W 0.00145187) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `qr_factor/n32/b1` | 0.032832 ± 0.000388421 (W 0.000193353) | 0.125927 ± 0.00263757 (W 0.00298327) | 0.02628 ± 6.00028e-05 (W 9.59338e-05) | 🔵 faer-fork 3.84× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.166012 ± 0.00582765 (W 0.00236198) | 0.658698 ± 0.00883109 (W 0.00743584) | 0.757006 ± 0.000378651 (W 0.00230136) | 🔵 faer-fork 3.97× faster than `faer-upstream` | 🔵 faer-fork 4.56× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.230615 ± 0.00901043 (W 0.00166821) | 0.233841 ± 0.00886988 (W 0.00140211) | 0.259419 ± 0.000260085 (W 0.00158888) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n64/b1` | 1.24332 ± 0.00514441 (W 0.00423781) | 1.25717 ± 0.010856 (W 0.00699107) | 0.974946 ± 0.0033444 (W 0.00176692) | · | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.152246 ± 0.000111015 (W 0.00149686) | 0.159361 ± 0.000247885 (W 0.00136283) | 0.101 ± 0.000614527 (W 0.000140869) | · | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.591998 ± 0.0008169 (W 0.00209225) | 0.62637 ± 0.00115345 (W 0.00233142) | 0.482669 ± 0.0031804 (W 0.0020884) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087715 ± 5.13258e-05 (W 0.000142868) | 0.087565 ± 0.000250034 (W 0.00149991) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.33982 ± 0.00230252 (W 0.00247057) | 0.362173 ± 0.000474711 (W 0.00189754) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020469 ± 2.52389e-05 (W 4.97996e-05) | 0.089328 ± 0.00623444 (W 0.00380372) | - | 🔵 faer-fork 4.36× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.107302 ± 0.0053546 (W 0.00187987) | 0.456741 ± 0.00225103 (W 0.0136004) | - | 🔵 faer-fork 4.26× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.136887 ± 0.000875366 (W 0.00129488) | 0.138892 ± 0.00117485 (W 0.00145852) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.577015 ± 0.00856741 (W 0.00360378) | 0.610621 ± 0.000143465 (W 0.00438143) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.095821 ± 0.00058373 (W 0.00018107) | 0.110428 ± 0.000297041 (W 0.00157357) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.32978 ± 0.00100038 (W 0.00153431) | 0.402427 ± 0.000603807 (W 0.0014569) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087334 ± 0.000294965 (W 8.33199e-05) | 0.087485 ± 0.000569007 (W 0.00016497) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.345402 ± 0.001307 (W 0.00288844) | 0.395364 ± 0.00193883 (W 0.00689362) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.020368 ± 4.98698e-05 (W 6.80243e-05) | 0.118594 ± 0.00402325 (W 0.00628649) | - | 🔵 faer-fork 5.82× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.103705 ± 0.0011707 (W 0.00116126) | 0.607618 ± 0.0116429 (W 0.00807541) | - | 🔵 faer-fork 5.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.136928 ± 0.000543037 (W 0.00157978) | 0.13793 ± 0.000385125 (W 0.00192995) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.585075 ± 0.00126001 (W 0.00267927) | 0.67079 ± 0.00268126 (W 0.0105643) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.09504 ± 0.000394069 (W 0.000133414) | 0.110609 ± 0.000130679 (W 0.000974356) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.330302 ± 0.000638714 (W 0.00149563) | 0.402917 ± 0.00100872 (W 0.00206343) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087835 ± 0.000143063 (W 0.00103993) | 0.088045 ± 7.78481e-05 (W 0.000262622) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.340514 ± 0.00390369 (W 0.0027864) | 0.360778 ± 0.00283091 (W 0.00382169) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.016071 ± 0.000105642 (W 8.52309e-05) | 0.074841 ± 0.00331777 (W 0.0047515) | - | 🔵 faer-fork 4.66× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.098415 ± 0.00425414 (W 0.00600147) | 0.39893 ± 0.00188208 (W 0.0138747) | - | 🔵 faer-fork 4.05× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.145904 ± 0.000665918 (W 0.00126494) | 0.147017 ± 0.000692247 (W 0.00150045) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.579069 ± 0.00181045 (W 0.0023961) | 0.613306 ± 0.00120082 (W 0.0041957) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.096202 ± 0.000198789 (W 0.000191304) | 0.109797 ± 8.544e-05 (W 0.00127143) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.329409 ± 0.000216763 (W 0.00162771) | 0.40187 ± 0.00148089 (W 0.00159399) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.087635 ± 0.000193807 (W 0.00128407) | 0.087815 ± 0.000466526 (W 9.64121e-05) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.345182 ± 0.00212566 (W 0.00284684) | 0.391048 ± 0.00270441 (W 0.00331599) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.01603 ± 5.56776e-05 (W 5.37699e-05) | 0.109777 ± 0.00398792 (W 0.00415066) | - | 🔵 faer-fork 6.85× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5%; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.085461 ± 0.000855017 (W 0.00110175) | 0.579459 ± 0.00745247 (W 0.0222406) | - | 🔵 faer-fork 6.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.146135 ± 0.0022647 (W 0.00118669) | 0.146786 ± 0.000482786 (W 0.000222104) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.59301 ± 0.00409262 (W 0.00279724) | 0.677543 ± 0.0076124 (W 0.00983912) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.096031 ± 0.000426122 (W 0.000110545) | 0.110148 ± 0.00037822 (W 0.00162023) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.329152 ± 0.000602648 (W 0.00193256) | 0.401887 ± 0.00176551 (W 0.00208239) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104818 ± 0.00044165 (W 0.00127523) | 0.106702 ± 0.000108076 (W 0.00186838) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.410933 ± 0.00137712 (W 0.00328255) | 0.411898 ± 0.00690626 (W 0.00224298) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.030788 ± 5.7735e-06 (W 0.00011073) | 0.096212 ± 0.00159489 (W 0.00435018) | - | 🔵 faer-fork 3.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.147928 ± 0.00643136 (W 0.0121789) | 0.514307 ± 0.00891119 (W 0.0143649) | - | 🔵 faer-fork 3.48× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.171282 ± 0.00128836 (W 0.00146531) | 0.172394 ± 0.00112295 (W 0.00140266) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.693397 ± 0.00807538 (W 0.00874403) | 0.694252 ± 0.00138818 (W 0.00526043) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107753 ± 0.000323074 (W 0.000145128) | 0.118754 ± 6.02771e-05 (W 0.00118263) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.39366 ± 0.000935751 (W 0.00176849) | 0.459847 ± 0.00236281 (W 0.00224214) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104466 ± 0.000377467 (W 0.000204913) | 0.105979 ± 0.000453286 (W 0.00152574) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.414763 ± 0.00273768 (W 0.0031663) | 0.417097 ± 0.00140329 (W 0.00390564) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.030728 ± 4.12351e-05 (W 8.47349e-05) | 0.129053 ± 0.000699732 (W 0.00313331) | - | 🔵 faer-fork 4.20× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.139143 ± 0.00110937 (W 0.00126312) | 0.708668 ± 0.00872409 (W 0.015966) | - | 🔵 faer-fork 5.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.171232 ± 0.00111553 (W 0.00135994) | 0.171442 ± 0.000488166 (W 0.00125453) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.706463 ± 0.00232951 (W 0.0053187) | 0.714723 ± 0.00369771 (W 0.00485086) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107764 ± 0.000288053 (W 0.000108186) | 0.118603 ± 0.000319511 (W 0.0013171) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.394855 ± 0.00254178 (W 0.00188299) | 0.459323 ± 0.00139553 (W 0.00205444) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104928 ± 0.00025204 (W 0.000300013) | 0.106471 ± 0.000354288 (W 0.000308773) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.409743 ± 0.000168634 (W 0.00280716) | 0.412888 ± 0.0042172 (W 0.00303522) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025358 ± 0.000194679 (W 0.0001396) | 0.088728 ± 0.00359683 (W 0.00444766) | - | 🔵 faer-fork 3.50× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/n64/b1` | 0.115247 ± 0.000489078 (W 0.0017099) | 0.426253 ± 0.00682702 (W 0.007164) | - | 🔵 faer-fork 3.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.173387 ± 0.00143815 (W 0.00193724) | 0.17427 ± 0.00138722 (W 0.00108954) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.703523 ± 0.00119914 (W 0.00226688) | 0.709451 ± 0.00715571 (W 0.00360976) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107271 ± 0.000336057 (W 4.63498e-05) | 0.118965 ± 0.000330848 (W 0.00122848) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.391907 ± 0.00108658 (W 0.00182438) | 0.456974 ± 0.00273949 (W 0.00158289) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `eigh/n32/b1` | 0.104646 ± 8.55005e-05 (W 0.00143923) | 0.10609 ± 0.000366446 (W 0.000201607) | - | · | - | `*` one row has no measurement here |
| `eigh/n64/b1` | 0.413929 ± 0.00488507 (W 0.00368944) | 0.422848 ± 0.00401695 (W 0.00490699) | - | · | - | `*` one row has no measurement here |
| `qr_factor/n32/b1` | 0.025558 ± 9.50438e-05 (W 8.28269e-05) | 0.1174 ± 0.000940556 (W 0.00593747) | - | 🔵 faer-fork 4.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.120046 ± 0.00132996 (W 0.00203647) | 0.599291 ± 0.00171584 (W 0.0119706) | - | 🔵 faer-fork 4.99× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.173717 ± 0.000717703 (W 0.00172242) | 0.174329 ± 0.000292463 (W 0.00190679) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.714332 ± 0.003307 (W 0.00367803) | 0.719883 ± 0.00157705 (W 0.00627765) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.107182 ± 0.000288795 (W 0.00124241) | 0.118753 ± 0.000451541 (W 0.000112828) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.393142 ± 0.00226589 (W 0.00218254) | 0.454143 ± 0.000968215 (W 0.00182297) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `eigh/32`, `eigh/64`, `qr_factor/32`, `qr_factor/64`, `svd_thin/32`, `svd_thin/64`, `svd_values/32`, `svd_values/64`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
