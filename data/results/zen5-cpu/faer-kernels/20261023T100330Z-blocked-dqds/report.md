# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `7eebfd4118144a11930586b2531d4692699a41df`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `a740f128e67f3be0e2897f42c0c71f21894ab575`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `27b001844b11a6e9a437aae7fa5a14889ce746c561ffb503ff4571e333366f96`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T10:41:32.144462Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout ../faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --families svd_values,svd_thin --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label blocked-dqds --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T100330Z-blocked-dqds/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.69%, worst 205.74% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 91 of 960 engine cells exceed 5% and carry `!`; median within-process relative SD 0.32%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `svd_thin/n32/b1` | 0.184397 ± 0.000608359 (W 0.00170462) | 0.185736 ± 0.000385176 (W 0.00125574) | 0.177922 ± 0.000699597 (W 0.00153526) | · | · |  |
| `svd_thin/n64/b1` | 0.927739 ± 0.00677063 (W 0.00116003) | 0.926917 ± 0.00658397 (W 0.00235666) | 0.771785 ± 0.00538259 (W 0.00236719) | · | 🔴 faer-fork 1.20× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.22222 ± 0.032342 (W 0.00267672) | 2.23017 ± 0.00755718 (W 0.00314935) | 1.68967 ± 0.0565018 (W 0.00818063) | · | 🔴 faer-fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.081693 ± 0.00020751 (W 0.000213435) | 0.141334 ± 0.00018985 (W 0.0014158) | 0.064561 ± 0.000161 (W 0.000105594) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.291774 ± 0.000800476 (W 0.00110951) | 0.520833 ± 0.00211796 (W 0.00370211) | 0.265541 ± 0.000498136 (W 0.00190912) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.666126 ± 0.00247961 (W 0.00204067) | 1.18338 ± 0.00366035 (W 0.00162855) | 0.638133 ± 0.000825853 (W 0.00278611) | 🔵 faer-fork 1.78× faster than `faer-upstream` | · |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183583 ± 0.00235252 (W 0.000727294) | 0.185516 ± 0.00109845 (W 0.00151081) | 0.186541 ± 0.00102048 (W 0.00169265) | · | · |  |
| `svd_thin/n64/b1` | 0.954829 ± 0.00524652 (W 0.00159566) | 0.952415 ± 0.00178894 (W 0.00215956) | 0.675069 ± 0.00897479 (W 0.00243626) | · | 🔴 faer-fork 1.41× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.28247 ± 0.0177536 (W 0.0186555) | 2.28261 ± 0.0378291 (W 0.023832) | 1.40966 ± 0.00115788 (W 0.00690162) | · | 🔴 faer-fork 1.62× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081362 ± 0.000569163 (W 0.00032844) | 0.141314 ± 0.000723925 (W 0.000777373) | 0.06435 ± 0.000185014 (W 7.93643e-05) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.291109 ± 0.000840793 (W 0.00190248) | 0.518096 ± 0.00128852 (W 0.00191359) | 0.269914 ± 0.000654929 (W 0.00123006) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.665671 ± 0.00117225 (W 0.00158435) | 1.18381 ± 0.00346685 (W 0.00198567) | 0.604497 ± 0.000817126 (W 0.00167514) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.183035 ± 0.000354633 (W 0.00149928) | 0.185546 ± 0.000620581 (W 0.0014412) | 0.187533 ± 0.00053327 (W 0.00151636) | · | · |  |
| `svd_thin/n64/b1` | 0.97986 ± 0.00529113 (W 0.0122568) | 0.969275 ± 0.0022328 (W 0.00474968) | 0.668178 ± 0.0016261 (W 0.00180055) | · | 🔴 faer-fork 1.47× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.31379 ± 0.0351687 (W 0.0294591) | 2.31211 ± 0.0487039 (W 0.0138382) | 1.43853 ± 0.0476244 (W 0.00468394) | · | 🔴 faer-fork 1.61× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.081472 ± 0.000217443 (W 0.000331322) | 0.141797 ± 0.000224972 (W 0.001019) | 0.064352 ± 0.00033332 (W 0.000132734) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.291284 ± 0.000735659 (W 0.0026361) | 0.517214 ± 0.00344176 (W 0.00401303) | 0.270119 ± 0.0011154 (W 0.00126057) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.667918 ± 0.00170103 (W 0.0020522) | 1.18797 ± 0.0131174 (W 0.00196633) | 0.598777 ± 0.00094423 (W 0.00168945) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.186508 ± 0.000537671 (W 0.00172901) | 0.188335 ± 0.000557778 (W 0.00100598) | 0.168528 ± 0.00034468 (W 0.00114773) | · | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.970128 ± 0.0092367 (W 0.00255287) | 0.972704 ± 0.00839083 (W 0.00321677) | 0.710786 ± 0.00944968 (W 0.00259871) | · | 🔴 faer-fork 1.36× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.16706 ± 0.0364079 (W 0.00134934) | 2.16314 ± 0.040516 (W 0.00245176) | 1.62128 ± 0.0511443 (W 0.0103867) | · | 🔴 faer-fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.081672 ± 0.000864144 (W 0.00129944) | 0.143581 ± 0.000358433 (W 0.00139763) | 0.059631 ± 0.000424617 (W 7.41431e-05) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.295521 ± 0.00095235 (W 0.00195914) | 0.540239 ± 0.000672765 (W 0.0016754) | 0.25434 ± 0.00084066 (W 0.00137533) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.677798 ± 0.00216846 (W 0.00191866) | 1.1911 ± 0.00255227 (W 0.00214128) | 0.609529 ± 0.00156665 (W 0.0019612) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.185787 ± 0.00167928 (W 0.00148857) | 0.187559 ± 0.00155625 (W 0.00133499) | 0.176272 ± 0.000992696 (W 0.00106025) | · | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.996288 ± 0.0039841 (W 0.00214542) | 0.996437 ± 0.000991607 (W 0.00319114) | 0.643711 ± 0.00301957 (W 0.00258672) | · | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.27737 ± 0.0180515 (W 0.0277894) | 2.26236 ± 0.00828608 (W 0.014327) | 1.37399 ± 0.00079633 (W 0.00229956) | · | 🔴 faer-fork 1.66× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081353 ± 0.000332145 (W 0.000156248) | 0.143347 ± 0.000235551 (W 0.00127121) | 0.059331 ± 3.15331e-05 (W 0.00125048) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.294921 ± 0.000256995 (W 0.00145496) | 0.539967 ± 0.00077831 (W 0.0018316) | 0.258482 ± 0.000891435 (W 0.00105135) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.676011 ± 0.000347605 (W 0.00214832) | 1.1911 ± 0.00152931 (W 0.00105101) | 0.605491 ± 0.000560119 (W 0.00210776) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.185256 ± 0.000266243 (W 0.0014397) | 0.18733 ± 0.000477564 (W 0.0014874) | 0.178113 ± 0.000490769 (W 0.000928028) | · | · |  |
| `svd_thin/n64/b1` | 1.01364 ± 0.00342281 (W 0.00173783) | 1.01025 ± 0.00187463 (W 0.00254912) | 0.640836 ± 0.00787986 (W 0.00163856) | · | 🔴 faer-fork 1.58× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.30486 ± 0.0446361 (W 0.0150882) | 2.30105 ± 0.0561255 (W 0.0224905) | 1.3235 ± 0.00663992 (W 0.00274609) | · | 🔴 faer-fork 1.74× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081393 ± 0.000277789 (W 0.00135979) | 0.143528 ± 0.000348945 (W 0.000328924) | 0.059371 ± 0.000207967 (W 7.67613e-05) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.296272 ± 0.00077338 (W 0.0017646) | 0.541489 ± 0.000619017 (W 0.00192147) | 0.259054 ± 0.000101868 (W 0.00152063) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.67944 ± 0.0016399 (W 0.00194805) | 1.19634 ± 0.0119015 (W 0.00198361) | 0.604249 ± 0.00205327 (W 0.00196197) | 🔵 faer-fork 1.76× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233817 ± 0.000452588 (W 0.00145581) | 0.23562 ± 0.000312606 (W 0.00138963) | 0.253288 ± 0.00162874 (W 0.00157438) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2205 ± 0.00291 (W 0.00132926) | 1.22166 ± 0.00118909 (W 0.00236111) | 1.3421 ± 0.00103917 (W 0.00279819) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.12218 ± 0.00291924 (W 0.00246534) | 3.12689 ± 0.0103783 (W 0.0011836) | 3.48906 ± 0.00461732 (W 0.00395108) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.097925 ± 0.000404315 (W 0.00138513) | 0.161881 ± 0.000362633 (W 0.00144405) | 0.103022 ± 0.121659 (W 0.000121261) | 🔵 faer-fork 1.65× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.399085 ± 0.00109498 (W 0.00186674) | 0.650974 ± 0.00106095 (W 0.00159111) | 0.492541 ± 0.00178809 (W 0.00187688) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.97946 ± 0.00322593 (W 0.00152529) | 1.51011 ± 0.000923007 (W 0.00186132) | 1.37582 ± 0.0316886 (W 0.00180711) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233851 ± 0.00067542 (W 0.00165315) | 0.235033 ± 0.000401042 (W 0.00162512) | 0.260486 ± 0.000395235 (W 0.00191337) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.19179 ± 0.00162704 (W 0.0022936) | 1.19388 ± 0.0243185 (W 0.00299424) | 1.02972 ± 0.00158887 (W 0.000936053) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.95287 ± 0.023136 (W 0.0206345) | 2.96236 ± 0.016591 (W 0.0167716) | 2.52681 ± 0.00127039 (W 0.0031644) | · | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.097842 ± 0.000292637 (W 0.000294831) | 0.161712 ± 0.000211947 (W 0.00113672) | 0.102471 ± 0.121664 (W 0.000194222) | 🔵 faer-fork 1.65× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.39811 ± 0.00236826 (W 0.00173993) | 0.649922 ± 0.00197365 (W 0.00157496) | 0.492838 ± 0.00154724 (W 0.00167624) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.973255 ± 0.00282445 (W 0.00253532) | 1.50455 ± 0.000344863 (W 0.00156656) | 1.35564 ± 0.00163161 (W 0.00200632) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.233666 ± 0.000302755 (W 0.00178186) | 0.235063 ± 3.50048e-05 (W 0.00176657) | 0.263302 ± 0.000395782 (W 0.00173934) | · | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.20478 ± 0.0063886 (W 0.00910066) | 1.22818 ± 0.00496039 (W 0.0108951) | 0.991221 ± 0.00057616 (W 0.00117724) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.96139 ± 0.0277421 (W 0.0253511) | 3.06889 ± 0.00975886 (W 0.0182542) | 2.34663 ± 0.00301184 (W 0.00294545) | · | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.097973 ± 0.000254847 (W 0.000178214) | 0.161294 ± 0.000435604 (W 0.000253728) | 0.102791 ± 0.121546 (W 0.00149906) | 🔵 faer-fork 1.65× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.397881 ± 0.00192927 (W 0.00175999) | 0.649182 ± 0.000290624 (W 0.00229234) | 0.491708 ± 0.00175246 (W 0.00123964) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.973172 ± 0.00224857 (W 0.00122674) | 1.50426 ± 0.00336035 (W 0.002356) | 1.39362 ± 0.00364684 (W 0.00708263) | 🔵 faer-fork 1.55× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.231322 ± 0.000799075 (W 0.00156223) | 0.232765 ± 0.000293791 (W 0.00175572) | 0.249515 ± 0.000714846 (W 0.00152085) | · | 🔵 faer-fork 1.08× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.25307 ± 0.0024353 (W 0.00221447) | 1.25511 ± 0.00220596 (W 0.00176422) | 1.31167 ± 0.00315995 (W 0.00334172) | · | · |  |
| `svd_thin/n96/b1` | 3.08669 ± 0.00280055 (W 0.00376943) | 3.08935 ± 0.00625064 (W 0.00282136) | 3.42181 ± 0.00517098 (W 0.00430959) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.098636 ± 0.000508628 (W 0.000170869) | 0.159972 ± 0.000700869 (W 0.0013093) | 0.101029 ± 0.000498184 (W 0.00125222) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.398003 ± 0.00141191 (W 0.00226417) | 0.627733 ± 0.001279 (W 0.00176796) | 0.480728 ± 0.000724639 (W 0.00221936) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.97419 ± 0.00326042 (W 0.00112679) | 1.48634 ± 0.00280289 (W 0.00212886) | 1.34179 ± 0.00237731 (W 0.00196447) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.230991 ± 0.000388049 (W 0.00121558) | 0.232785 ± 0.000158229 (W 0.00142029) | 0.255968 ± 0.0012314 (W 0.00181126) | · | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.2258 ± 0.0166167 (W 0.00422717) | 1.2232 ± 0.000868615 (W 0.00328752) | 1.00852 ± 0.00250368 (W 0.000753638) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.91766 ± 0.00577445 (W 0.0209041) | 2.92041 ± 0.0194611 (W 0.0135541) | 2.50509 ± 0.00219244 (W 0.00316737) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.098223 ± 0.000111301 (W 0.000109864) | 0.159538 ± 0.000218212 (W 0.0010477) | 0.100307 ± 0.000273818 (W 0.00153432) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.397632 ± 0.00140901 (W 0.00191059) | 0.626167 ± 0.00167188 (W 0.0016284) | 0.479987 ± 0.00102395 (W 0.00181616) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.970202 ± 0.00242529 (W 0.000901389) | 1.48155 ± 0.00251449 (W 0.00291903) | 1.33867 ± 0.00122585 (W 0.00201696) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.232077 ± 0.000635366 (W 0.00144854) | 0.23363 ± 0.000778123 (W 0.00189583) | 0.260196 ± 0.00207031 (W 0.00135189) | · | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.23762 ± 0.00269452 (W 0.00316727) | 1.26055 ± 0.00680808 (W 0.0128572) | 0.971131 ± 0.00221771 (W 0.00130519) | · | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.90848 ± 0.0167636 (W 0.0152574) | 3.01949 ± 0.010274 (W 0.00925004) | 2.32974 ± 0.00349931 (W 0.00245722) | · | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.098584 ± 0.000205905 (W 0.00109326) | 0.15925 ± 0.000479212 (W 0.000373708) | 0.100588 ± 0.000594828 (W 0.00012145) | 🔵 faer-fork 1.62× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.395615 ± 0.000636258 (W 0.00159954) | 0.624636 ± 0.000779951 (W 0.00145987) | 0.480127 ± 0.0024892 (W 0.00174674) | 🔵 faer-fork 1.58× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.97051 ± 0.00210631 (W 0.000860551) | 1.47941 ± 0.00410941 (W 0.00228972) | 1.33877 ± 0.00250874 (W 0.0022875) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.38× faster than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137687 ± 0.000299724 (W 0.00119299) | 0.139533 ± 0.000471765 (W 0.000238693) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.538485 ± 0.00322188 (W 0.00214278) | 0.543324 ± 0.00364628 (W 0.00176872) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.5685 ± 0.00181162 (W 0.00307155) | 1.57523 ± 0.00179034 (W 0.00262886) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068669 ± 0.000266141 (W 0.00013158) | 0.11136 ± 0.000405332 (W 0.000310566) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.230901 ± 0.000181561 (W 0.00140187) | 0.402822 ± 0.00162319 (W 0.00171964) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.514439 ± 0.00140932 (W 0.0016914) | 0.888928 ± 0.00296922 (W 0.00105888) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.137299 ± 0.0127431 (W 0.00163133) | 0.140154 ± 0.0116647 (W 0.00139648) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.578379 ± 0.00912863 (W 0.00792718) | 0.616831 ± 0.00276198 (W 0.00417077) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.67862 ± 0.00955735 (W 0.0168258) | 1.73584 ± 0.00424908 (W 0.0162829) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068449 ± 0.000402135 (W 0.000111235) | 0.111278 ± 0.000402098 (W 0.00137271) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.23053 ± 0.00187823 (W 0.00106682) | 0.402121 ± 0.00240558 (W 0.00157004) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.512285 ± 0.00243366 (W 0.00196347) | 0.887568 ± 0.00231336 (W 0.00157517) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.139421 ± 0.001147 (W 0.00149307) | 0.141354 ± 0.00154648 (W 0.000965148) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.587235 ± 0.00510521 (W 0.00603936) | 0.664812 ± 0.00677568 (W 0.00558005) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.70349 ± 0.0130974 (W 0.0107182) | 1.82295 ± 0.0172177 (W 0.0224951) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.068688 ± 0.000736044 (W 0.000198167) | 0.112229 ± 0.000559823 (W 0.000212494) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.232024 ± 0.00066456 (W 0.00107514) | 0.403703 ± 0.00160027 (W 0.00153731) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.512505 ± 0.0021099 (W 0.00212228) | 0.890804 ± 0.00254115 (W 0.00210645) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146887 ± 0.00020307 (W 0.0012625) | 0.148731 ± 0.000345665 (W 0.00134003) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.543304 ± 0.00417612 (W 0.00148757) | 0.547582 ± 0.00277457 (W 0.00197911) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.56198 ± 0.00131815 (W 0.00241142) | 1.57408 ± 0.00213436 (W 0.00302586) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.069891 ± 0.00010479 (W 0.00132132) | 0.111288 ± 0.00036775 (W 0.00014938) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.233776 ± 0.000109089 (W 0.00100612) | 0.402911 ± 0.00126536 (W 0.0015855) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.519591 ± 0.00151207 (W 0.00189344) | 0.874461 ± 0.00427668 (W 0.000751876) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.146736 ± 0.0135771 (W 0.000783254) | 0.149512 ± 0.0130849 (W 0.000178744) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n64/b1` | 0.577989 ± 0.00281107 (W 0.0045107) | 0.622172 ± 0.00208164 (W 0.00645417) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.68095 ± 0.0106911 (W 0.0179839) | 1.73349 ± 0.0111013 (W 0.0142619) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.069761 ± 0.00038626 (W 0.000103827) | 0.110767 ± 0.000334695 (W 0.00133142) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.234261 ± 0.00063114 (W 0.00118915) | 0.404001 ± 0.00126988 (W 0.00156324) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.517374 ± 0.00242522 (W 0.00175804) | 0.87304 ± 0.00255469 (W 0.00131839) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.148848 ± 0.00142884 (W 0.00150148) | 0.151092 ± 0.00159665 (W 0.00161359) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.58952 ± 0.00274206 (W 0.00412916) | 0.668106 ± 0.0100725 (W 0.0118496) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.69131 ± 0.00673735 (W 0.0185254) | 1.83389 ± 0.0115004 (W 0.0154572) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.069921 ± 0.000408216 (W 0.00150913) | 0.111178 ± 0.00087962 (W 0.000110812) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.233921 ± 0.000360202 (W 0.00144078) | 0.405907 ± 0.00117987 (W 0.00148267) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.519519 ± 0.00103425 (W 0.00188101) | 0.874523 ± 0.00228655 (W 0.00172819) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172031 ± 0.000578673 (W 0.00129721) | 0.172986 ± 0.000314352 (W 0.00111503) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.692772 ± 0.00302603 (W 0.00179221) | 0.696582 ± 0.0693101 (W 0.00213462) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 2.04822 ± 0.00128417 (W 0.00139222) | 2.05143 ± 0.0045035 (W 0.00183737) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.079188 ± 0.000138601 (W 0.000107842) | 0.120455 ± 0.00021305 (W 0.00121947) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.295461 ± 0.000971523 (W 0.00162567) | 0.462655 ± 0.00147252 (W 0.0016523) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.705278 ± 0.00218104 (W 0.00157836) | 1.06517 ± 0.000461611 (W 0.0011647) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172692 ± 0.00080614 (W 0.00146007) | 0.173627 ± 0.00110823 (W 0.00133378) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.700368 ± 0.0123726 (W 0.00526059) | 0.70591 ± 0.00843357 (W 0.00361569) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.01411 ± 0.00873753 (W 0.0285129) | 2.02777 ± 0.00428094 (W 0.0269665) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.07951 ± 0.000271831 (W 0.00116142) | 0.119573 ± 0.000543421 (W 0.000203158) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.292536 ± 0.00110135 (W 0.00152053) | 0.461349 ± 0.00159192 (W 0.0017281) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.700007 ± 0.00345572 (W 0.00201707) | 1.0574 ± 0.00456685 (W 0.00146168) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.172552 ± 0.000707057 (W 0.00129219) | 0.173276 ± 0.000280949 (W 0.0011417) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.707372 ± 0.00443693 (W 0.00354493) | 0.710317 ± 0.00877377 (W 0.00591111) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05364 ± 0.0119239 (W 0.0170286) | 2.108 ± 0.0181789 (W 0.0205225) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.079359 ± 0.000115529 (W 0.00162603) | 0.119884 ± 0.000282448 (W 9.57095e-05) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.292256 ± 0.000874706 (W 0.00149365) | 0.46147 ± 0.00161968 (W 0.00152389) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.699286 ± 0.00214392 (W 0.00149021) | 1.05987 ± 0.00193524 (W 0.000663569) | - | 🔵 faer-fork 1.52× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.174346 ± 0.000440278 (W 0.00133935) | 0.174816 ± 0.000507139 (W 0.0013175) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.701899 ± 0.00367732 (W 0.00149944) | 0.703194 ± 0.0026031 (W 0.00251362) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.06358 ± 0.00119954 (W 0.00194333) | 2.06576 ± 0.00302562 (W 0.0048373) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.080331 ± 3.61985e-05 (W 0.000128609) | 0.119846 ± 0.000188977 (W 0.000964923) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.292687 ± 0.00068846 (W 0.00176346) | 0.455469 ± 0.00058983 (W 0.00144699) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.708353 ± 0.0017936 (W 0.00128339) | 1.06314 ± 0.000524355 (W 0.0010002) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.174565 ± 0.000782781 (W 0.00144206) | 0.174639 ± 0.000393519 (W 0.00142475) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.718129 ± 0.00360324 (W 0.00914634) | 0.707511 ± 0.00823914 (W 0.00275069) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.02446 ± 0.00679095 (W 0.0124322) | 2.03897 ± 0.026053 (W 0.0195774) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.08047 ± 0.000280431 (W 0.000809753) | 0.119303 ± 0.000336773 (W 0.00133104) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.290593 ± 0.000752259 (W 0.00150288) | 0.453247 ± 0.00174586 (W 0.00138659) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.704446 ± 0.00464393 (W 0.00146573) | 1.05541 ± 0.00582755 (W 0.00183957) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n32/b1` | 0.174526 ± 0.00131674 (W 0.00131477) | 0.175561 ± 0.000534131 (W 0.00153696) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.714676 ± 0.00374923 (W 0.00345721) | 0.719161 ± 0.00777404 (W 0.00261923) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 2.05068 ± 0.0150225 (W 0.0165787) | 2.14247 ± 0.0190815 (W 0.0181371) | - | · | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.080369 ± 0.000153659 (W 0.00128256) | 0.119405 ± 0.000196167 (W 0.000154807) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.291184 ± 0.000765881 (W 0.00152741) | 0.453283 ± 0.00206051 (W 0.00162894) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.705077 ± 0.00236118 (W 0.00150994) | 1.05597 ± 0.00292351 (W 0.00116141) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.69297 ± 0.062305 (W 0.00935297) | 3.68538 ± 0.063778 (W 0.0031119) | 3.39008 ± 0.196265 (W 0.00656107) | · | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 17.8946 ± 0.585199 (W 0.0157484) | 18.4967 ± 0.47947 (W 0.0182676) | 18.0901 ± 1.27818 (W 0.0413983) | · | · | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 99.2962 ± 18.5625 (W 0.336413) | 105.621 ± 17.2289 (W 0.0966856) | 116.951 ± 20.4187 (W 0.605364) | · | · | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.31952 ± 0.0331914 (W 0.00491074) | 2.69661 ± 0.00873503 (W 0.00668895) | 1.20671 ± 0.0219389 (W 0.00468898) | 🔵 faer-fork 2.04× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.05825 ± 0.127955 (W 0.00978386) | 12.4809 ± 0.126649 (W 0.0137763) | 7.20347 ± 0.185791 (W 0.0118233) | 🔵 faer-fork 1.77× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/n512/b1` | 44.5164 ± 13.8251 (W 0.398569) | 67.2005 ± 13.3255 (W 0.0777733) | 50.056 ± 14.3716 (W 0.385448) | 🔵 faer-fork 1.51× faster than `faer-upstream` | · | `!` between-start range over 5% |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.04728 ± 0.00446409 (W 0.0191145) | 3.02438 ± 0.00627848 (W 0.013945) | 2.63363 ± 0.00295589 (W 0.00463458) | · | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.735 ± 0.0819003 (W 0.0296168) | 13.6544 ± 0.0393102 (W 0.06613) | 12.4658 ± 0.0335609 (W 0.0246062) | 🔵 faer-fork 1.07× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 48.4454 ± 0.25106 (W 0.11196) | 61.5318 ± 0.167256 (W 0.516868) | 57.5115 ± 0.199404 (W 0.0561306) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.31931 ± 0.00587332 (W 0.0024006) | 2.21593 ± 0.0069578 (W 0.0056159) | 1.13791 ± 0.00622662 (W 0.00331443) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.13374 ± 0.00858385 (W 0.0248009) | 10.8289 ± 0.016381 (W 0.0255697) | 6.12928 ± 0.142072 (W 0.0109761) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 28.1853 ± 0.0290226 (W 0.0888153) | 48.0705 ± 0.29223 (W 0.464481) | 25.831 ± 0.58569 (W 0.044148) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.06611 ± 0.0217061 (W 0.0144543) | 3.12853 ± 0.0156817 (W 0.0258676) | 2.51084 ± 0.0045215 (W 0.00692274) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.4276 ± 0.0151903 (W 0.0386354) | 13.7827 ± 0.024647 (W 0.0366477) | 11.5088 ± 0.00471878 (W 0.0153595) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 43.6953 ± 0.124306 (W 0.15781) | 60.6014 ± 0.323703 (W 0.44445) | 48.9022 ± 2.28544 (W 0.080962) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.3296 ± 0.00565512 (W 0.00177481) | 2.27175 ± 0.0317323 (W 0.0041435) | 1.11964 ± 0.00192441 (W 0.00176904) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.16921 ± 0.0383471 (W 0.0422099) | 10.965 ± 0.029553 (W 0.0425775) | 5.97565 ± 0.195203 (W 0.00866171) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 26.8637 ± 0.0420932 (W 0.0682648) | 49.1721 ± 0.0952327 (W 0.289676) | 22.3319 ± 0.759967 (W 0.0258771) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔴 faer-fork 1.20× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.68838 ± 0.0641147 (W 0.00325717) | 3.6786 ± 0.0630184 (W 0.00525637) | 3.33851 ± 0.105647 (W 0.0165086) | · | 🔴 faer-fork 1.10× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 17.7936 ± 0.527251 (W 0.015639) | 18.3965 ± 0.420426 (W 0.0194555) | 17.742 ± 1.10546 (W 0.0186648) | · | · | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 98.4687 ± 18.7393 (W 0.143853) | 104.845 ± 16.7087 (W 0.369289) | 116.649 ± 20.0006 (W 0.438874) | · | · | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.30371 ± 0.0334937 (W 0.00223061) | 2.62127 ± 0.00678346 (W 0.00250007) | 1.15797 ± 0.00465826 (W 0.00220525) | 🔵 faer-fork 2.01× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.95285 ± 0.100785 (W 0.00629954) | 12.2588 ± 0.0783801 (W 0.01732) | 6.84733 ± 0.13663 (W 0.0100352) | 🔵 faer-fork 1.76× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 43.3064 ± 13.9864 (W 0.11936) | 66.1176 ± 12.9029 (W 0.392116) | 47.9686 ± 13.4279 (W 0.0408029) | 🔵 faer-fork 1.53× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.01767 ± 0.0253312 (W 0.0360072) | 2.98947 ± 0.0182578 (W 0.0211506) | 2.6208 ± 0.0145975 (W 0.00686047) | · | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.6641 ± 0.0337913 (W 0.0521658) | 13.6159 ± 0.0127011 (W 0.0333976) | 12.3255 ± 0.0515972 (W 0.0319389) | 🔵 faer-fork 1.08× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 47.4019 ± 0.0917179 (W 0.0959736) | 60.4844 ± 0.357811 (W 0.449148) | 56.7007 ± 1.09443 (W 0.0500938) | 🔵 faer-fork 1.28× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.30005 ± 0.00843424 (W 0.00202714) | 2.14981 ± 0.00479056 (W 0.00228884) | 1.11959 ± 0.0101088 (W 0.00298741) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.02177 ± 0.00930325 (W 0.0293064) | 10.6967 ± 0.0638042 (W 0.046662) | 6.1101 ± 0.0477065 (W 0.00763595) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 27.1276 ± 0.065491 (W 0.0775175) | 47.1145 ± 0.2166 (W 0.342385) | 25.615 ± 0.256467 (W 0.0476459) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.02727 ± 0.0070925 (W 0.0099562) | 3.10081 ± 0.00595925 (W 0.0203206) | 2.47329 ± 0.00521553 (W 0.00426383) | · | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 12.2425 ± 0.089587 (W 0.0251777) | 13.6132 ± 0.10596 (W 0.0406226) | 11.3194 ± 0.0100233 (W 0.0187598) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 42.7567 ± 0.0873967 (W 0.155258) | 59.8396 ± 0.30396 (W 0.324955) | 47.6344 ± 0.0826763 (W 0.031627) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.3092 ± 0.00392442 (W 0.00181449) | 2.16219 ± 0.0305887 (W 0.00515106) | 1.12871 ± 0.0095868 (W 0.00166604) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 7.05906 ± 0.000848387 (W 0.0294598) | 10.8449 ± 0.0252489 (W 0.0305535) | 5.98196 ± 0.0297591 (W 0.00717087) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 25.7631 ± 0.030969 (W 0.0773135) | 48.2094 ± 0.143877 (W 0.297902) | 22.3214 ± 0.0295615 (W 0.0278339) | 🔵 faer-fork 1.87× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.74145 ± 0.119108 (W 0.00577036) | 5.73514 ± 0.114869 (W 0.00379552) | 7.05572 ± 0.315938 (W 0.00496658) | · | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 33.633 ± 4.93434 (W 0.0234794) | 34.3196 ± 3.2172 (W 0.4306) | 43.8603 ± 2.68851 (W 0.0453519) | · | 🔵 faer-fork 1.30× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n512/b1` | 209.402 ± 51.1471 (W 0.545097) | 211.916 ± 41.8451 (W 0.427518) | 279.777 ± 54.718 (W 1.39461) | · | · | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.13581 ± 0.0079009 (W 0.00764402) | 3.47761 ± 0.0212669 (W 0.00613641) | 2.77092 ± 0.0436025 (W 0.00863208) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.8533 ± 3.46708 (W 0.0198521) | 19.3935 ± 2.15244 (W 0.035904) | 18.167 ± 1.47908 (W 0.0199375) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n512/b1` | 93.3107 ± 44.9159 (W 0.488659) | 111.832 ± 35.8515 (W 0.501021) | 122.983 ± 41.3173 (W 0.354306) | · | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.33182 ± 0.0197802 (W 0.0208299) | 4.35786 ± 0.0289475 (W 0.0235942) | 4.13695 ± 0.000411049 (W 0.00555109) | · | · |  |
| `svd_thin/n256/b1` | 21.2907 ± 0.110191 (W 0.037255) | 22.4416 ± 0.138662 (W 0.0956621) | 21.2611 ± 0.0620955 (W 0.0366626) | 🔵 faer-fork 1.05× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 84.0755 ± 0.0722313 (W 0.164872) | 94.703 ± 0.263797 (W 0.351952) | 114.164 ± 5.61238 (W 0.533964) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.12561 ± 0.00559933 (W 0.00415947) | 3.03595 ± 0.0120685 (W 0.00624954) | 2.0195 ± 0.0103432 (W 0.00273981) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔴 faer-fork 1.05× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.9364 ± 0.0295127 (W 0.0656128) | 17.0196 ± 0.0940033 (W 0.0593622) | 11.1296 ± 0.0234216 (W 0.0217917) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 47.3389 ± 0.122564 (W 0.139086) | 65.1161 ± 0.348362 (W 0.197273) | 56.2016 ± 0.176237 (W 0.133085) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.20919 ± 0.00292386 (W 0.00893867) | 4.44785 ± 0.0115215 (W 0.010668) | 3.63262 ± 0.0111005 (W 0.00480696) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.7933 ± 0.199724 (W 0.0927711) | 21.9831 ± 0.0629586 (W 0.0537319) | 17.2136 ± 0.033908 (W 0.0256202) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 66.818 ± 0.243914 (W 0.353283) | 81.6859 ± 0.337889 (W 0.298841) | 83.927 ± 5.21103 (W 0.0865839) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 2.12985 ± 0.0112899 (W 0.00815934) | 3.09237 ± 0.00335649 (W 0.00728509) | 1.90798 ± 0.00728016 (W 0.00455825) | 🔵 faer-fork 1.45× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.0039 ± 0.064288 (W 0.041023) | 17.0963 ± 0.0415393 (W 0.0364329) | 9.66532 ± 0.00963056 (W 0.0136794) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.1698 ± 0.299468 (W 0.206) | 61.0664 ± 0.158471 (W 0.199922) | 43.1621 ± 0.0726858 (W 0.0436833) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 5.70853 ± 0.113723 (W 0.00570454) | 5.71237 ± 0.112069 (W 0.00694681) | 6.98171 ± 0.206046 (W 0.00662145) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n256/b1` | 33.2296 ± 4.9038 (W 0.0738771) | 34.0239 ± 3.16588 (W 0.0256694) | 45.5235 ± 1.5687 (W 0.0771859) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_thin/n512/b1` | 207.326 ± 51.7004 (W 0.358723) | 210.167 ± 40.1989 (W 0.256626) | 309.977 ± 31.1397 (W 0.919859) | · | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n128/b1` | 2.11165 ± 0.00856784 (W 0.00486397) | 3.44921 ± 0.010111 (W 0.00607915) | 2.73041 ± 0.0101065 (W 0.00540566) | 🔵 faer-fork 1.63× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.6134 ± 3.30193 (W 0.0147039) | 19.0134 ± 2.47299 (W 0.0250981) | 20.0485 ± 0.514427 (W 0.0723944) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n512/b1` | 91.2361 ± 44.903 (W 0.278305) | 110.023 ± 35.9724 (W 0.532208) | 155.234 ± 21.7671 (W 0.373976) | · | 🔵 faer-fork 1.70× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.32941 ± 0.0256323 (W 0.0224146) | 4.29281 ± 0.0253363 (W 0.0275657) | 4.0939 ± 0.00335738 (W 0.00531788) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.9677 ± 0.0694548 (W 0.0564442) | 22.2415 ± 0.0915136 (W 0.067611) | 21.0507 ± 0.0260994 (W 0.0199364) | 🔵 faer-fork 1.06× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 82.9056 ± 0.16923 (W 0.123929) | 93.5742 ± 0.27099 (W 0.26754) | 112.765 ± 1.02123 (W 0.138109) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.09519 ± 0.00860162 (W 0.00602232) | 3.0008 ± 0.00871909 (W 0.00494259) | 2.01276 ± 0.00983134 (W 0.00288466) | 🔵 faer-fork 1.43× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.7467 ± 0.013936 (W 0.057561) | 16.7176 ± 0.0560751 (W 0.102333) | 11.0877 ± 0.0438836 (W 0.027529) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 46.1594 ± 0.180901 (W 0.108323) | 64.1802 ± 0.285869 (W 0.384956) | 56.0946 ± 0.0483822 (W 0.112053) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 4.19123 ± 0.0155677 (W 0.030873) | 4.42763 ± 0.0169992 (W 0.0282329) | 3.58946 ± 0.00514594 (W 0.00699782) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.5888 ± 0.177164 (W 0.0620131) | 21.7055 ± 0.126894 (W 0.061575) | 17.1233 ± 0.00982881 (W 0.0333383) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 65.08 ± 0.0909352 (W 0.157304) | 80.5584 ± 0.109653 (W 0.322215) | 81.8312 ± 0.21888 (W 0.0927933) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 2.09148 ± 0.00162326 (W 0.00673371) | 3.05755 ± 0.00335802 (W 0.00254243) | 1.8963 ± 0.00694788 (W 0.0042685) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.8436 ± 0.0428402 (W 0.0412876) | 16.8534 ± 0.0761047 (W 0.044757) | 9.64447 ± 0.0295588 (W 0.0113372) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 39.2505 ± 0.0710354 (W 0.0940069) | 60.1258 ± 0.123148 (W 0.088288) | 42.9644 ± 0.0551996 (W 0.0338657) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.32837 ± 0.0226944 (W 0.00251998) | 2.34511 ± 0.0194048 (W 0.00375389) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.1232 ± 0.194777 (W 0.0099967) | 11.2169 ± 0.172181 (W 0.0104603) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 58.6834 ± 6.74162 (W 0.0685306) | 61.6408 ± 4.84162 (W 0.0677831) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 0.919144 ± 0.00115669 (W 0.000946104) | 1.71843 ± 0.00727743 (W 0.00190299) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.48207 ± 0.027384 (W 0.0063427) | 7.89525 ± 0.0184102 (W 0.00806457) | - | 🔵 faer-fork 1.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 25.6856 ± 4.49269 (W 0.0214846) | 40.3994 ± 3.38625 (W 0.0453855) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.02646 ± 0.00560438 (W 0.0220842) | 2.08574 ± 0.0107183 (W 0.0183152) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.50973 ± 0.0094352 (W 0.0336404) | 8.74595 ± 0.0297587 (W 0.0511702) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 32.5059 ± 0.0726313 (W 0.040492) | 41.6582 ± 0.330209 (W 0.432797) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.919486 ± 0.00352694 (W 0.0015401) | 1.49027 ± 0.00330887 (W 0.00182142) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.63241 ± 0.00838538 (W 0.0121229) | 6.97223 ± 0.019897 (W 0.0171402) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 19.3439 ± 0.0410779 (W 0.038131) | 33.8767 ± 0.399263 (W 0.658271) | - | 🔵 faer-fork 1.75× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.05018 ± 0.00678228 (W 0.00738432) | 2.27691 ± 0.032823 (W 0.0232012) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.39403 ± 0.0347566 (W 0.03524) | 9.18622 ± 0.0117323 (W 0.0279073) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 30.3259 ± 0.0411025 (W 0.0723896) | 43.616 ± 0.425426 (W 0.446813) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.920769 ± 0.0117099 (W 0.00229376) | 1.49567 ± 0.0032506 (W 0.00128569) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.71113 ± 0.0075046 (W 0.0206846) | 7.10593 ± 0.0193199 (W 0.0171209) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 18.8639 ± 0.0333782 (W 0.0528054) | 35.3201 ± 0.296665 (W 0.646259) | - | 🔵 faer-fork 1.87× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.34242 ± 0.0184734 (W 0.00262975) | 2.35567 ± 0.020123 (W 0.00453475) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.0647 ± 0.189016 (W 0.0286895) | 11.2436 ± 0.168462 (W 0.0144851) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 58.091 ± 6.68598 (W 0.0378914) | 61.1164 ± 4.8394 (W 0.0292855) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 0.915923 ± 0.00080848 (W 0.00121319) | 1.68547 ± 0.00696663 (W 0.00192098) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.38844 ± 0.0142275 (W 0.00723498) | 7.73259 ± 0.0247192 (W 0.0117208) | - | 🔵 faer-fork 1.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 25.1332 ± 3.53989 (W 0.0119562) | 39.8447 ± 3.30195 (W 0.0422815) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.03586 ± 0.00738468 (W 0.0151096) | 2.09559 ± 0.00503329 (W 0.0152834) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.41231 ± 0.0491405 (W 0.0272986) | 8.66871 ± 0.0182924 (W 0.012632) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 31.9569 ± 0.0387774 (W 0.0879705) | 41.0736 ± 0.20862 (W 0.501019) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.915849 ± 0.00360036 (W 0.00220608) | 1.46525 ± 0.00407151 (W 0.00230789) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.51037 ± 0.0195785 (W 0.0131814) | 6.81236 ± 0.0179109 (W 0.0149874) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 18.8094 ± 0.0309115 (W 0.0177999) | 33.2757 ± 0.176718 (W 0.681199) | - | 🔵 faer-fork 1.77× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.07377 ± 0.0114933 (W 0.0114369) | 2.27914 ± 0.0164282 (W 0.0163184) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 8.33779 ± 0.018484 (W 0.0339418) | 9.11939 ± 0.0178543 (W 0.029831) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 29.8571 ± 0.0667063 (W 0.0633396) | 42.5757 ± 0.228204 (W 0.422515) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.917693 ± 0.0107855 (W 0.00220054) | 1.46784 ± 0.00174665 (W 0.00324688) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.61322 ± 0.00563682 (W 0.0329787) | 6.96445 ± 0.0124106 (W 0.0193734) | - | 🔵 faer-fork 1.51× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 18.381 ± 0.0567088 (W 0.0659012) | 35.3909 ± 0.0794705 (W 0.204895) | - | 🔵 faer-fork 1.93× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.40297 ± 0.0536289 (W 0.0119107) | 3.40404 ± 0.050639 (W 0.00250672) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.5836 ± 0.475848 (W 0.0144879) | 19.8372 ± 0.406076 (W 0.0217016) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 118.608 ± 23.0777 (W 0.0742527) | 123.4 ± 20.8293 (W 0.209022) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.3981 ± 0.0051434 (W 0.00272692) | 2.17621 ± 0.00558874 (W 0.00513495) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 8.52102 ± 0.187438 (W 0.0055902) | 11.8659 ± 0.0887494 (W 0.0146564) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 54.5547 ± 19.089 (W 0.037061) | 71.1729 ± 16.1557 (W 0.0807365) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.78884 ± 0.0261474 (W 0.0342579) | 2.78754 ± 0.0125249 (W 0.0175974) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.3113 ± 0.0546415 (W 0.033364) | 13.9035 ± 0.0519823 (W 0.0461125) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 53.3117 ± 0.156138 (W 0.0539727) | 65.0115 ± 0.162885 (W 0.237717) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.38421 ± 0.0088617 (W 0.00209494) | 1.9437 ± 0.0208832 (W 0.00312787) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 8.13959 ± 0.0286012 (W 0.0493284) | 10.7484 ± 0.0624834 (W 0.0767046) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 31.1315 ± 0.0713251 (W 0.0226998) | 48.4388 ± 0.270631 (W 0.336352) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.76747 ± 0.00553113 (W 0.018481) | 2.9322 ± 0.0369107 (W 0.0169061) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.6917 ± 0.0136884 (W 0.0382944) | 13.8002 ± 0.0546456 (W 0.0385465) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 45.2341 ± 0.00821995 (W 0.0530056) | 60.6291 ± 0.0647232 (W 0.208113) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.39259 ± 0.00461367 (W 0.0011697) | 1.9552 ± 0.00786933 (W 0.00353679) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 8.16097 ± 0.0414398 (W 0.0300405) | 10.7604 ± 0.0255838 (W 0.0227346) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 28.5327 ± 0.0451087 (W 0.0852099) | 47.6264 ± 0.116098 (W 0.399637) | - | 🔵 faer-fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 3.39588 ± 0.0691302 (W 0.00229922) | 3.40076 ± 0.0540044 (W 0.00388132) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 19.4161 ± 0.450156 (W 0.0213944) | 19.717 ± 0.36246 (W 0.0363358) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 117.453 ± 23.4845 (W 0.0761878) | 122.557 ± 20.5897 (W 0.18891) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.37161 ± 0.00375227 (W 0.00405353) | 2.14347 ± 0.00319078 (W 0.00126042) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 8.34207 ± 0.129365 (W 0.013911) | 11.7249 ± 0.0656648 (W 0.0183775) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 53.4033 ± 19.4315 (W 0.295184) | 70.0531 ± 16.2054 (W 0.0806723) | - | · | - | `*` one row has no measurement here; `!` between-start range over 5% |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.77927 ± 0.0115999 (W 0.0406964) | 2.74845 ± 0.0201192 (W 0.0142398) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 13.152 ± 0.0315966 (W 0.0345153) | 13.774 ± 0.0730855 (W 0.121347) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 52.4361 ± 0.0722079 (W 0.0738134) | 63.83 ± 0.186689 (W 0.319518) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.37038 ± 0.00462486 (W 0.00164449) | 1.92778 ± 0.000699218 (W 0.00281481) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 8.00919 ± 0.0248788 (W 0.0248111) | 10.5125 ± 0.055226 (W 0.0619949) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 30.1545 ± 0.154176 (W 0.0512479) | 47.2451 ± 0.171925 (W 0.170997) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/n128/b1` | 2.74116 ± 0.00551684 (W 0.0124871) | 2.92769 ± 0.0204275 (W 0.0283146) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 12.4969 ± 0.0290717 (W 0.0417153) | 13.6164 ± 0.0211577 (W 0.0342989) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 44.2844 ± 0.0449688 (W 0.0996638) | 59.9675 ± 0.295021 (W 0.459055) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.37443 ± 0.00454048 (W 0.00220346) | 1.94241 ± 0.0360557 (W 0.00460224) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 8.03461 ± 0.0242893 (W 0.0172584) | 10.6637 ± 0.00935362 (W 0.0388095) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 27.6502 ± 0.00899022 (W 0.0469318) | 47.0033 ± 0.174091 (W 0.358951) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.50544 ± 0.00520348 (W 0.00323894) | 2.51386 ± 0.00463799 (W 0.00479611) | 3.05194 ± 0.00301417 (W 0.00469505) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 87.7018 ± 0.0617781 (W 0.116841) | 88.0271 ± 0.0250667 (W 0.105685) | 119.99 ± 0.122145 (W 0.235379) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.24588 ± 0.00055543 (W 0.00411428) | 1.49176 ± 0.000396481 (W 0.00471494) | 1.38515 ± 0.161175 (W 0.00475604) | 🔵 faer-fork 1.20× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 40.1962 ± 0.114832 (W 0.0485529) | 44.8826 ± 0.0422059 (W 0.0585065) | 46.863 ± 3.11807 (W 0.29749) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.38445 ± 0.00305709 (W 0.0247824) | 2.78001 ± 0.0204142 (W 0.0153206) | 1.8854 ± 0.00546167 (W 0.00591587) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 45.827 ± 0.296769 (W 0.159427) | 50.3923 ± 0.0645457 (W 0.126148) | 48.7332 ± 2.85066 (W 0.092337) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.37746 ± 0.00772452 (W 0.0132376) | 2.1079 ± 0.00630512 (W 0.0273867) | 0.945714 ± 0.14197 (W 0.00755802) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔴 faer-fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 28.3317 ± 0.128854 (W 0.151493) | 35.337 ± 0.155029 (W 0.113067) | 22.5858 ± 2.81039 (W 0.100543) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.52289 ± 0.00407414 (W 0.0234545) | 3.16959 ± 0.019275 (W 0.0355858) | 1.67065 ± 0.00559869 (W 0.00399319) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.51× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 39.5179 ± 0.0588172 (W 0.302349) | 50.1645 ± 0.668932 (W 0.725204) | 36.4624 ± 2.84365 (W 0.103644) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.55352 ± 0.0859463 (W 0.0314028) | 2.52306 ± 0.0132091 (W 0.0213865) | 0.813637 ± 0.193234 (W 0.00419076) | 🔵 faer-fork 1.62× faster than `faer-upstream` | 🔴 faer-fork 1.91× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/4096x256/b1` | 26.6438 ± 1.4055 (W 0.0969459) | 37.3361 ± 0.0133301 (W 0.25804) | 16.732 ± 2.73877 (W 0.0858308) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.44484 ± 0.00336358 (W 0.00389385) | 2.45343 ± 0.00645328 (W 0.00337486) | 2.80916 ± 0.00153097 (W 0.005347) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 82.4233 ± 0.231019 (W 0.0559046) | 82.9061 ± 0.100134 (W 0.108047) | 110.01 ± 0.332982 (W 0.341223) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.16931 ± 0.00101396 (W 0.00371347) | 1.41121 ± 0.00395469 (W 0.00258991) | 1.2396 ± 0.00499938 (W 0.00336803) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 34.3271 ± 0.109459 (W 0.0353597) | 39.1351 ± 0.0340475 (W 0.03815) | 40.4889 ± 0.293345 (W 0.0326317) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.29663 ± 0.0152942 (W 0.0263215) | 2.75185 ± 0.0117642 (W 0.0234404) | 1.83506 ± 0.01097 (W 0.0074019) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 40.0195 ± 0.0574226 (W 0.16873) | 44.4265 ± 0.105425 (W 0.163422) | 45.2961 ± 0.252832 (W 0.0910753) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.13× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.30187 ± 0.0106117 (W 0.014597) | 2.03358 ± 0.0390115 (W 0.0304439) | 0.90647 ± 0.00540437 (W 0.00379183) | 🔵 faer-fork 1.56× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 22.1805 ± 0.0677656 (W 0.162972) | 29.7431 ± 0.155758 (W 0.159008) | 20.8248 ± 0.0428635 (W 0.137117) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.46328 ± 0.0062193 (W 0.0193058) | 3.10245 ± 0.00910761 (W 0.0268327) | 1.63947 ± 0.00532754 (W 0.00484726) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 33.6582 ± 0.115024 (W 0.132488) | 44.4716 ± 0.260929 (W 0.634619) | 34.4545 ± 0.185264 (W 0.0786076) | 🔵 faer-fork 1.32× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.46083 ± 0.107835 (W 0.0408869) | 2.41288 ± 0.0109743 (W 0.0264452) | 0.785884 ± 0.00275201 (W 0.00364356) | 🔵 faer-fork 1.65× faster than `faer-upstream` | 🔴 faer-fork 1.86× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/4096x256/b1` | 20.5806 ± 0.0591913 (W 0.075672) | 31.7066 ± 0.0759585 (W 0.132705) | 15.6928 ± 0.169139 (W 0.0467916) | 🔵 faer-fork 1.54× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 6.00237 ± 0.027035 (W 0.00397492) | 6.00753 ± 0.0121025 (W 0.00455813) | 8.76301 ± 0.0268367 (W 0.0105452) | · | 🔵 faer-fork 1.46× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 279.762 ± 0.0569468 (W 2.72603) | 280.705 ± 0.19178 (W 0.458828) | 379.669 ± 1.01774 (W 0.659238) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.83891 ± 0.0193738 (W 0.00314039) | 3.07749 ± 0.0132137 (W 0.00277929) | 3.83299 ± 0.0157 (W 0.00697245) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 118.998 ± 0.52594 (W 0.414547) | 122.274 ± 0.818817 (W 0.491783) | 144.657 ± 6.14246 (W 0.479806) | · | 🔵 faer-fork 1.22× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.0102 ± 0.104692 (W 0.0733093) | 4.34883 ± 0.0126973 (W 0.0211967) | 5.49971 ± 0.00227245 (W 0.0346066) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 113.801 ± 0.234142 (W 0.347807) | 122.105 ± 0.21976 (W 0.159596) | 140.036 ± 0.597114 (W 0.57767) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.40896 ± 0.032658 (W 0.057172) | 3.03951 ± 0.0114944 (W 0.0232421) | 2.82164 ± 0.0305 (W 0.00977927) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 63.7379 ± 0.909389 (W 0.282525) | 75.1041 ± 0.0794355 (W 0.173603) | 51.4867 ± 5.22101 (W 0.273352) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.7983 ± 0.0365593 (W 0.0218312) | 4.6261 ± 0.0354021 (W 0.0253015) | 4.42288 ± 0.00786119 (W 0.0171013) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 91.2018 ± 2.8024 (W 0.333199) | 104.918 ± 0.2961 (W 0.825436) | 83.8596 ± 0.556793 (W 0.35959) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.37069 ± 0.0211614 (W 0.0223608) | 3.36397 ± 0.0249269 (W 0.0193261) | 2.30052 ± 0.00568776 (W 0.00305612) | 🔵 faer-fork 1.42× faster than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 54.8494 ± 0.103009 (W 0.129028) | 72.5985 ± 0.047821 (W 0.136463) | 34.5829 ± 4.98518 (W 0.265586) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔴 faer-fork 1.59× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 5.89032 ± 0.0227863 (W 0.00844028) | 5.89095 ± 0.0200831 (W 0.00496894) | 8.56101 ± 0.0213628 (W 0.00884173) | · | 🔵 faer-fork 1.45× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 267.458 ± 0.357329 (W 0.145229) | 268.792 ± 0.302821 (W 0.24656) | 371.835 ± 0.798676 (W 1.10758) | · | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.71024 ± 0.018559 (W 0.00194699) | 2.94956 ± 0.0195467 (W 0.00259256) | 3.65474 ± 0.0380701 (W 0.00681338) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 105.563 ± 0.0175571 (W 0.0836115) | 110.12 ± 0.106348 (W 0.0759603) | 144.316 ± 1.66423 (W 1.02698) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 4.06347 ± 0.0925256 (W 0.0909375) | 4.26203 ± 0.0181429 (W 0.0367763) | 5.42776 ± 0.0472491 (W 0.00517242) | · | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 101.573 ± 0.183744 (W 0.210213) | 110.04 ± 0.132938 (W 0.0758637) | 128.568 ± 0.248914 (W 0.383095) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.27× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.35476 ± 0.0394125 (W 0.0818956) | 2.94271 ± 0.0199699 (W 0.0265959) | 2.77608 ± 0.0172167 (W 0.00590017) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 51.4204 ± 0.0317866 (W 0.0729245) | 63.0672 ± 0.0775478 (W 0.0702381) | 48.6056 ± 0.382368 (W 0.103848) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.73402 ± 0.0128388 (W 0.0294952) | 4.53665 ± 0.0116643 (W 0.0445868) | 4.36276 ± 0.0249085 (W 0.00910674) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 73.7314 ± 0.0626965 (W 0.199313) | 92.6368 ± 0.144307 (W 0.728479) | 73.6744 ± 0.0848924 (W 0.238478) | 🔵 faer-fork 1.26× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 2.28858 ± 0.0166601 (W 0.0301233) | 3.2704 ± 0.00382979 (W 0.0261804) | 2.28678 ± 0.0152344 (W 0.00337607) | 🔵 faer-fork 1.43× faster than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 43.0381 ± 0.0991829 (W 0.0713238) | 60.9437 ± 0.146665 (W 0.125684) | 32.411 ± 0.33057 (W 0.0768841) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 1.33× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.59166 ± 0.00930556 (W 0.00231418) | 1.60405 ± 0.0108503 (W 0.00258224) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.0374 ± 0.10367 (W 0.1208) | 49.2154 ± 0.416081 (W 0.0490073) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.99141 ± 0.00585529 (W 0.00198411) | 1.14056 ± 0.00542122 (W 0.00248617) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 25.0542 ± 0.305925 (W 0.0407119) | 27.4771 ± 0.275898 (W 0.0314605) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.69319 ± 0.0126999 (W 0.0198548) | 2.16033 ± 0.0135201 (W 0.0315376) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 27.2071 ± 0.119689 (W 0.203683) | 31.3575 ± 0.167673 (W 0.170314) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.19084 ± 0.0167611 (W 0.0230503) | 1.85029 ± 0.00821836 (W 0.0162815) | - | 🔵 faer-fork 1.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.0318 ± 0.177426 (W 0.101725) | 24.4807 ± 0.0408432 (W 0.197919) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.82635 ± 0.0188097 (W 0.0262555) | 2.55086 ± 0.0134099 (W 0.0316618) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.5559 ± 0.0705479 (W 0.0726875) | 33.5093 ± 0.510389 (W 0.589522) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.30183 ± 0.00811269 (W 0.0183792) | 2.19784 ± 0.00976228 (W 0.0306926) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 18.3956 ± 0.0816529 (W 0.100581) | 26.6098 ± 0.395071 (W 0.519693) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.58726 ± 0.0128101 (W 0.00313616) | 1.59954 ± 0.0111643 (W 0.00264018) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.1362 ± 0.239849 (W 0.0305173) | 46.5391 ± 0.276789 (W 0.0256319) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.95579 ± 0.00195135 (W 0.000543681) | 1.11218 ± 0.00181941 (W 0.00197088) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 21.7365 ± 0.0780003 (W 0.0665472) | 24.4597 ± 0.0966749 (W 0.0191366) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.72707 ± 0.00719864 (W 0.0209501) | 2.16799 ± 0.0182577 (W 0.0230928) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 23.6936 ± 0.159991 (W 0.2616) | 28.0675 ± 0.088892 (W 0.165655) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.14811 ± 0.0053684 (W 0.0176178) | 1.80894 ± 0.0145422 (W 0.027438) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 15.2 ± 0.192842 (W 0.172285) | 21.047 ± 0.072386 (W 0.112094) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 1.81577 ± 0.0121312 (W 0.0270151) | 2.52439 ± 0.00629853 (W 0.026157) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.1399 ± 0.0551973 (W 0.0654472) | 30.1864 ± 0.371767 (W 0.286597) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.26519 ± 0.00631994 (W 0.0131845) | 2.13733 ± 0.0426068 (W 0.0377637) | - | 🔵 faer-fork 1.69× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 14.6889 ± 0.0833697 (W 0.0464227) | 23.0803 ± 0.0403965 (W 0.161481) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.39945 ± 0.00604514 (W 0.003642) | 3.39426 ± 0.0128274 (W 0.00271651) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 146.923 ± 0.113017 (W 0.416685) | 146.864 ± 0.0966065 (W 0.413532) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.85136 ± 0.00301571 (W 0.00591712) | 2.01611 ± 0.00316275 (W 0.00463034) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 64.999 ± 0.0669503 (W 0.0463655) | 67.447 ± 0.0192915 (W 0.0988622) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.63216 ± 0.0059498 (W 0.0555024) | 2.98201 ± 0.0165367 (W 0.0255293) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 62.3794 ± 0.0701902 (W 0.149561) | 69.3563 ± 0.0866487 (W 0.123771) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.83254 ± 0.0186292 (W 0.0273063) | 2.36294 ± 0.0292431 (W 0.0298665) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 37.3734 ± 0.071775 (W 0.0886038) | 45.4227 ± 0.0631641 (W 0.123121) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.60707 ± 0.00846484 (W 0.012645) | 3.33055 ± 0.011728 (W 0.0273397) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 49.1724 ± 0.0788898 (W 0.0347378) | 63.011 ± 0.820258 (W 1.15941) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.86005 ± 0.0117436 (W 0.0113481) | 2.75763 ± 0.0186524 (W 0.0310156) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 33.2972 ± 0.0687866 (W 0.0492749) | 45.7923 ± 0.0732786 (W 0.154392) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 3.35634 ± 0.00568007 (W 0.00267419) | 3.3542 ± 0.0117476 (W 0.00374679) | - | · | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 141.56 ± 0.15067 (W 0.0844316) | 141.686 ± 0.0543912 (W 0.167721) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.78098 ± 0.000588023 (W 0.00229724) | 1.92129 ± 0.0030188 (W 0.00144613) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 59.3069 ± 0.0723675 (W 0.372295) | 61.8542 ± 0.0600706 (W 0.0570894) | - | · | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.5842 ± 0.0154665 (W 0.0249122) | 2.94787 ± 0.011674 (W 0.0367503) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 56.5262 ± 0.0409174 (W 0.145392) | 63.619 ± 0.0894064 (W 0.109562) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.75034 ± 0.0284408 (W 0.0599656) | 2.30599 ± 0.0197982 (W 0.02368) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 31.456 ± 0.0697581 (W 0.184641) | 39.7395 ± 0.066057 (W 0.205197) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `svd_thin/1024x64/b1` | 2.58174 ± 0.013195 (W 0.0148441) | 3.32348 ± 0.0238142 (W 0.0328665) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 43.5447 ± 0.142845 (W 0.0939226) | 58.2702 ± 0.639387 (W 0.912444) | - | 🔵 faer-fork 1.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.80072 ± 0.0056726 (W 0.0124577) | 2.66726 ± 0.0137676 (W 0.0256131) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 27.4898 ± 0.119905 (W 0.10476) | 40.1449 ± 0.135213 (W 0.351971) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
