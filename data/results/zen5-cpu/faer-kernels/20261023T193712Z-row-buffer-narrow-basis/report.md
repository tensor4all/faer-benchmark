# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `23518196f21fc1aeeb61112c901bec95c8a762a9`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `f8d4122e8b66aa48675bf14600ef8ccab5da9f33`
- toolkit commit: `a4f24a7db0785a38612d767384ee8adfad31c343`
- measured binary SHA-256: `40569f30681315985f4ccf7f4171930fe367c490b05d9734b0c4ffc5db281464`
- hardware profile: `zen5-cpu`
- host role: `development` — **provisional**: recorded on a development host, superseded by the measurement host's dataset
- timestamp: `2026-10-23T20:42:51.874449Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes linalg-small,linalg-mid,linalg-tall --dtypes f64,c64,f32,c32 --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --no-publish --checkout ../faer --families svd_values,svd_thin,qr_factor --label row-buffer-narrow-basis`
- raw data: `data/results/zen5-cpu/faer-kernels/20261023T193712Z-row-buffer-narrow-basis/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 0.64%, worst 4230.20% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 42 of 1440 engine cells exceed 5% and carry `!`; median within-process relative SD 0.27%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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
| `qr_factor/n32/b1` | 0.021551 ± 3.17857e-05 (W 6.52319e-05) | 0.028232 ± 7.10422e-05 (W 0.000184082) | 0.014056 ± 2.3388e-05 (W 6.05657e-05) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.077184 ± 0.000382427 (W 0.000270981) | 0.129181 ± 0.000180694 (W 0.000187625) | 0.298405 ± 0.133828 (W 0.00119438) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 3.87× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.168945 ± 0.00118154 (W 0.00107715) | 0.284491 ± 0.00113561 (W 0.00210542) | 0.204512 ± 0.00109679 (W 0.00170995) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.167834 ± 8.68581e-05 (W 0.00124868) | 0.183972 ± 0.00167468 (W 0.00132845) | 0.177301 ± 0.000204158 (W 0.00134989) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.858056 ± 0.00245837 (W 0.0015741) | 0.912941 ± 0.000226058 (W 0.000671532) | 0.719518 ± 0.00162117 (W 0.0018628) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.03033 ± 0.00469794 (W 0.0022269) | 2.15511 ± 0.00130594 (W 0.00252676) | 1.78793 ± 0.0623442 (W 0.0101502) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.14× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.065893 ± 0.00051736 (W 0.000181456) | 0.140211 ± 0.000761762 (W 0.00128045) | 0.064561 ± 0.0430175 (W 0.000103035) | 🔵 faer-fork 2.13× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.23576 ± 0.00067432 (W 0.00123009) | 0.517536 ± 0.00122854 (W 0.0015674) | 0.264743 ± 0.000361202 (W 0.00115213) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.542313 ± 0.00247978 (W 0.00202701) | 1.18492 ± 0.00496952 (W 0.00184955) | 0.628754 ± 0.00104968 (W 0.00214757) | 🔵 faer-fork 2.18× faster than `faer-upstream` | 🔵 faer-fork 1.16× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.02157 ± 8.7178e-05 (W 0.000138203) | 0.042058 ± 0.000283931 (W 0.000410123) | 0.014026 ± 0.000130128 (W 5.26308e-05) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.076803 ± 0.000464429 (W 0.000400813) | 0.205573 ± 0.00197251 (W 0.00206234) | 0.066144 ± 0.000226378 (W 0.00132685) | 🔵 faer-fork 2.68× faster than `faer-upstream` | 🔴 faer-fork 1.16× slower than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.155199 ± 0.00107838 (W 0.000580279) | 0.413409 ± 0.00208937 (W 0.00168077) | 0.187339 ± 0.000471487 (W 0.00166723) | 🔵 faer-fork 2.66× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.168133 ± 0.000960867 (W 0.000487297) | 0.183942 ± 0.00185898 (W 0.00176331) | 0.185776 ± 5.23482e-05 (W 0.00119313) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.865142 ± 0.00211877 (W 0.00388176) | 0.916575 ± 0.00333746 (W 0.00359819) | 0.68738 ± 0.0113951 (W 0.0050746) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 1.96754 ± 0.00333288 (W 0.00189802) | 2.09184 ± 0.00240088 (W 0.00183736) | 1.53459 ± 0.0232203 (W 0.00545195) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.065411 ± 0.000750033 (W 0.000153552) | 0.140582 ± 0.000319197 (W 0.00147093) | 0.06431 ± 0.000120968 (W 0.000176145) | 🔵 faer-fork 2.15× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.234747 ± 0.0046069 (W 0.0015178) | 0.515583 ± 0.000778319 (W 0.00164166) | 0.270814 ± 0.00163844 (W 0.00237943) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.541658 ± 0.00124686 (W 0.0021497) | 1.18133 ± 0.00611606 (W 0.00142274) | 0.615469 ± 0.00517276 (W 0.00189444) | 🔵 faer-fork 2.18× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.02157 ± 0.000105357 (W 0.00011128) | 0.050744 ± 0.00101856 (W 0.00107455) | 0.014026 ± 7.99396e-05 (W 6.38224e-05) | 🔵 faer-fork 2.35× faster than `faer-upstream` | 🔴 faer-fork 1.54× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.081802 ± 1.0672 (W 0.00147093) | 0.24624 ± 0.00186533 (W 0.0042108) | 0.066294 ± 9.16515e-05 (W 0.000177396) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.157953 ± 0.000681562 (W 0.00115495) | 0.494169 ± 0.00296889 (W 0.00438792) | 0.185345 ± 0.00039145 (W 0.00106738) | 🔵 faer-fork 3.13× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.167874 ± 0.0014725 (W 0.00108009) | 0.182851 ± 0.00132013 (W 0.0017869) | 0.18749 ± 0.000742307 (W 0.00121329) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.863722 ± 0.000994355 (W 0.00304537) | 0.920583 ± 0.000538524 (W 0.00262336) | 0.660869 ± 0.00498345 (W 0.00240161) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 1.96873 ± 0.00183796 (W 0.00199359) | 2.11085 ± 0.00556856 (W 0.0025243) | 1.43737 ± 0.0494237 (W 0.00233608) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.37× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.065281 ± 0.000133742 (W 0.00015619) | 0.140513 ± 0.000491144 (W 0.00149205) | 0.06434 ± 0.000130512 (W 8.15855e-05) | 🔵 faer-fork 2.15× faster than `faer-upstream` | · |  |
| `svd_values/n64/b1` | 0.234316 ± 0.00135853 (W 0.00133923) | 0.517113 ± 0.00059103 (W 0.00179145) | 0.269382 ± 0.000217141 (W 0.00152026) | 🔵 faer-fork 2.21× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.539717 ± 0.00141498 (W 0.0023678) | 1.18176 ± 0.00133876 (W 0.00213924) | 0.600717 ± 0.00202818 (W 0.00176701) | 🔵 faer-fork 2.19× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.014638 ± 0.000105263 (W 0.000164849) | 0.018034 ± 0.000111894 (W 9.28773e-05) | 0.011431 ± 7.16961e-05 (W 4.0978e-05) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔴 faer-fork 1.28× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.061695 ± 0.000316551 (W 0.00034253) | 0.074078 ± 0.000433705 (W 0.000237516) | 0.289348 ± 0.000380633 (W 0.00148457) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 4.69× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.133528 ± 0.00189011 (W 0.00038745) | 0.162513 ± 0.00127205 (W 0.00124964) | 0.93008 ± 0.000955084 (W 0.000839409) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 6.97× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.170558 ± 0.00174281 (W 0.00144073) | 0.185946 ± 0.00208511 (W 0.00149661) | 0.168073 ± 0.000148224 (W 0.00130431) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |
| `svd_thin/n64/b1` | 0.90315 ± 0.00184384 (W 0.00107283) | 0.957861 ± 0.000983512 (W 0.000858485) | 0.696748 ± 0.00422698 (W 0.00245523) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.30× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.03413 ± 0.0061942 (W 0.00170636) | 2.14966 ± 0.00300755 (W 0.00204326) | 1.61917 ± 0.000911864 (W 0.00693141) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.26× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.065291 ± 0.000196817 (W 0.000129893) | 0.142066 ± 0.000349056 (W 0.000942292) | 0.059561 ± 0.000250067 (W 0.00136735) | 🔵 faer-fork 2.18× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.239065 ± 0.00100638 (W 0.00156714) | 0.538045 ± 0.000506826 (W 0.00157382) | 0.254574 ± 0.00114735 (W 0.00148151) | 🔵 faer-fork 2.25× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.548815 ± 0.00112786 (W 0.00146273) | 1.19081 ± 0.00131107 (W 0.0017854) | 0.608354 ± 0.00105929 (W 0.00179577) | 🔵 faer-fork 2.17× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.014867 ± 9.20887e-05 (W 0.00012518) | 0.031459 ± 0.000530284 (W 0.000322336) | 0.011531 ± 0.000118462 (W 7.10514e-05) | 🔵 faer-fork 2.12× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.059031 ± 0.000295229 (W 0.000206181) | 0.143867 ± 0.00249059 (W 0.00171283) | 0.057517 ± 9.29157e-05 (W 0.000132828) | 🔵 faer-fork 2.44× faster than `faer-upstream` | · |  |
| `qr_factor/n96/b1` | 0.115226 ± 0.000393854 (W 0.00136664) | 0.282435 ± 0.00171032 (W 0.00168247) | 0.174675 ± 0.000253574 (W 0.000990279) | 🔵 faer-fork 2.45× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.170217 ± 0.000952005 (W 0.00146908) | 0.185275 ± 0.00129928 (W 0.00175838) | 0.176869 ± 0.000599968 (W 0.00138223) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |
| `svd_thin/n64/b1` | 0.909628 ± 0.0013327 (W 0.0031091) | 0.962383 ± 0.00212855 (W 0.00303837) | 0.64977 ± 0.00108629 (W 0.00240466) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 1.96975 ± 0.00530969 (W 0.00300139) | 2.09056 ± 0.0014133 (W 0.00128752) | 1.4631 ± 0.0478397 (W 0.00194331) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n32/b1` | 0.064801 ± 0.000673724 (W 0.000156621) | 0.142225 ± 0.000646807 (W 0.000271358) | 0.05931 ± 6.67108e-05 (W 0.000115136) | 🔵 faer-fork 2.19× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.238184 ± 0.00319586 (W 0.00149733) | 0.536088 ± 0.000777857 (W 0.00223975) | 0.261068 ± 0.00185679 (W 0.00127587) | 🔵 faer-fork 2.25× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.55176 ± 0.00191302 (W 0.00216325) | 1.18882 ± 0.00634079 (W 0.00113303) | 0.603474 ± 0.000991314 (W 0.00156049) | 🔵 faer-fork 2.15× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.014818 ± 0.000115529 (W 0.000111329) | 0.038622 ± 0.000320725 (W 0.000860449) | 0.011512 ± 8.62168e-05 (W 6.77813e-05) | 🔵 faer-fork 2.61× faster than `faer-upstream` | 🔴 faer-fork 1.29× slower than `lapack-mkl` | dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.060472 ± 1.47679 (W 0.00147205) | 0.18794 ± 0.00275911 (W 0.00204159) | 0.057467 ± 0.000264059 (W 8.62972e-05) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n96/b1` | 0.120645 ± 0.00375223 (W 0.00723564) | 0.368876 ± 0.00138926 (W 0.00305945) | 0.174685 ± 0.000558756 (W 0.00163732) | 🔵 faer-fork 3.06× faster than `faer-upstream` | 🔵 faer-fork 1.45× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n32/b1` | 0.169296 ± 0.00142144 (W 0.00130839) | 0.184143 ± 0.00211526 (W 0.00167393) | 0.178101 ± 0.000446628 (W 0.000853289) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 0.903183 ± 0.000589855 (W 0.00251786) | 0.968855 ± 0.00229772 (W 0.00326502) | 0.643368 ± 0.00215284 (W 0.00262235) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 1.9686 ± 0.00118294 (W 0.00217092) | 2.10648 ± 0.00163249 (W 0.0047656) | 1.32539 ± 0.00338565 (W 0.0032308) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔴 faer-fork 1.49× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.064691 ± 0.000151438 (W 0.00011511) | 0.142475 ± 0.000283127 (W 0.00150675) | 0.059301 ± 8.56174e-05 (W 9.80673e-05) | 🔵 faer-fork 2.20× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.237502 ± 0.000984711 (W 0.00151351) | 0.536881 ± 0.00111241 (W 0.00151784) | 0.259112 ± 0.000489941 (W 0.00148449) | 🔵 faer-fork 2.26× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.548634 ± 0.000522747 (W 0.00249165) | 1.18801 ± 0.00560361 (W 0.00471286) | 0.599826 ± 0.00295954 (W 0.00231075) | 🔵 faer-fork 2.17× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.038852 ± 0.000171553 (W 0.000230784) | 0.045966 ± 0.000246579 (W 0.000311955) | 0.028803 ± 0.0480151 (W 8.70632e-05) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n64/b1` | 0.164336 ± 0.000173102 (W 0.0017006) | 0.236351 ± 0.000873624 (W 0.00143383) | 0.166461 ± 0.000230695 (W 0.00139407) | 🔵 faer-fork 1.44× faster than `faer-upstream` | · |  |
| `qr_factor/n96/b1` | 0.397719 ± 0.00262144 (W 0.00191952) | 0.534867 ± 0.00430718 (W 0.00234894) | 0.516775 ± 0.0019411 (W 0.00204877) | 🔵 faer-fork 1.34× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.218897 ± 0.00187032 (W 0.00112542) | 0.235309 ± 0.00175637 (W 0.00112005) | 0.25255 ± 0.000731937 (W 0.00126133) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.16769 ± 0.001629 (W 0.00154023) | 1.22918 ± 0.00135566 (W 0.00193145) | 1.34458 ± 0.00239835 (W 0.00247294) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 3.03097 ± 0.00305292 (W 0.00358088) | 3.16225 ± 0.000999518 (W 0.00312802) | 3.48555 ± 0.00219255 (W 0.00294121) | · | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081723 ± 0.000139249 (W 0.0015337) | 0.162061 ± 9.5974e-05 (W 0.00164901) | 0.102792 ± 0.12173 (W 0.00142234) | 🔵 faer-fork 1.98× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n64/b1` | 0.347627 ± 0.000447784 (W 0.00163564) | 0.657417 ± 0.00103087 (W 0.00153036) | 0.491374 ± 0.00323745 (W 0.00178028) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.886185 ± 0.0015769 (W 0.00130784) | 1.54393 ± 0.000954491 (W 0.00206616) | 1.3762 ± 0.00598051 (W 0.00203083) | 🔵 faer-fork 1.74× faster than `faer-upstream` | 🔵 faer-fork 1.55× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.038872 ± 0.000366074 (W 0.000241311) | 0.058579 ± 0.000737273 (W 0.00123987) | 0.028854 ± 0.000104083 (W 6.01664e-05) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.142055 ± 0.000552557 (W 0.00126998) | 0.284431 ± 0.00191735 (W 0.0022641) | 0.163574 ± 0.000488488 (W 0.00119378) | 🔵 faer-fork 2.00× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.285962 ± 0.0012443 (W 0.00146895) | 0.567996 ± 0.00553742 (W 0.00248491) | 0.499579 ± 0.001731 (W 0.00178899) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.218418 ± 0.000125144 (W 0.00134302) | 0.234688 ± 0.000321032 (W 0.00141888) | 0.261155 ± 0.000957627 (W 0.00129573) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.09154 ± 0.0010919 (W 0.00190861) | 1.15204 ± 0.000303429 (W 0.0020009) | 1.02909 ± 0.00228911 (W 0.00166303) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.70127 ± 0.00153963 (W 0.00420262) | 2.83006 ± 0.00314473 (W 0.0029129) | 2.525 ± 0.000587512 (W 0.00378695) | · | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081462 ± 4.96689e-05 (W 0.000129552) | 0.162293 ± 0.000467184 (W 0.00139526) | 0.102121 ± 0.00016202 (W 0.000194302) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.346666 ± 0.00113985 (W 0.00157672) | 0.657858 ± 0.000467089 (W 0.00163136) | 0.489173 ± 0.00027844 (W 0.00122429) | 🔵 faer-fork 1.90× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.88925 ± 0.000329741 (W 0.00195262) | 1.54197 ± 0.00357206 (W 0.00225847) | 1.35494 ± 0.00267375 (W 0.00122196) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.038723 ± 9.20887e-05 (W 0.00018566) | 0.067957 ± 0.000426768 (W 0.00113867) | 0.028784 ± 9.70069e-05 (W 8.47603e-05) | 🔵 faer-fork 1.75× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.143147 ± 0.000688573 (W 0.00154572) | 0.320436 ± 0.00318432 (W 0.00479563) | 0.163977 ± 0.000425677 (W 0.000944225) | 🔵 faer-fork 2.24× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.276696 ± 0.00212474 (W 0.00196618) | 0.618865 ± 0.0049298 (W 0.00802389) | 0.49833 ± 0.00034269 (W 0.00188728) | 🔵 faer-fork 2.24× faster than `faer-upstream` | 🔵 faer-fork 1.80× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.218949 ± 0.000856607 (W 0.00126646) | 0.235719 ± 0.000496689 (W 0.0019517) | 0.263991 ± 0.000913589 (W 0.00154867) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.08608 ± 0.00104682 (W 0.000898981) | 1.15634 ± 0.00198716 (W 0.00170555) | 0.992216 ± 0.00143711 (W 0.00113476) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.65709 ± 0.00284401 (W 0.00504424) | 2.85959 ± 0.00327425 (W 0.0028447) | 2.34199 ± 0.00175557 (W 0.00327096) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.13× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081973 ± 0.000366881 (W 0.00119986) | 0.162182 ± 0.000439615 (W 0.00173179) | 0.10215 ± 0.000111072 (W 0.00128384) | 🔵 faer-fork 1.98× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.34809 ± 0.00072304 (W 0.00154148) | 0.657203 ± 0.000597315 (W 0.00168855) | 0.489922 ± 0.00082368 (W 0.00166574) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.889461 ± 0.00123421 (W 0.000993001) | 1.53984 ± 0.00113332 (W 0.00202488) | 1.35481 ± 0.00118067 (W 0.00184372) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.030988 ± 0.000157608 (W 0.000290547) | 0.034073 ± 0.000189518 (W 0.000223717) | 0.026169 ± 0.000144222 (W 4.69042e-05) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.147514 ± 0.000420909 (W 0.00103114) | 0.162181 ± 0.000113715 (W 0.00144931) | 0.756056 ± 0.000309655 (W 0.00141662) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 5.13× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.363609 ± 0.00262494 (W 0.00194639) | 0.396758 ± 0.000112171 (W 0.00173732) | 2.44227 ± 0.00150572 (W 0.00210832) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 6.72× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.216172 ± 0.00110671 (W 0.00152987) | 0.233075 ± 0.000859234 (W 0.00200103) | 0.249504 ± 0.000305943 (W 0.00174075) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.19985 ± 0.00241104 (W 0.00198402) | 1.25981 ± 0.00137396 (W 0.00229998) | 1.31551 ± 0.00406052 (W 0.00214138) | · | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.98744 ± 0.00287165 (W 0.00168521) | 3.11747 ± 0.00200509 (W 0.00344739) | 3.41936 ± 0.0142039 (W 0.00361397) | · | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082023 ± 0.000240624 (W 0.0011446) | 0.159828 ± 0.000477885 (W 0.00140168) | 0.100878 ± 0.000366557 (W 0.000174397) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.34414 ± 0.000232883 (W 0.00184665) | 0.633042 ± 0.000219955 (W 0.0015077) | 0.479402 ± 0.00240141 (W 0.00150416) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.883843 ± 0.000226265 (W 0.00197787) | 1.51727 ± 0.00249559 (W 0.00213909) | 1.3381 ± 0.00437307 (W 0.00174997) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.031098 ± 0.000599075 (W 0.000308013) | 0.047309 ± 0.000566749 (W 0.000726392) | 0.026369 ± 0.000136077 (W 6.10434e-05) | 🔵 faer-fork 1.52× faster than `faer-upstream` | 🔴 faer-fork 1.18× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.124483 ± 0.00100456 (W 0.00102235) | 0.207558 ± 0.00274566 (W 0.00152701) | 0.155961 ± 0.000251191 (W 0.00166551) | 🔵 faer-fork 1.67× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.246771 ± 0.00122723 (W 0.00173523) | 0.419673 ± 0.00694138 (W 0.00189036) | 0.483379 ± 0.00127041 (W 0.00226323) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔵 faer-fork 1.96× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.215883 ± 0.000334569 (W 0.00156294) | 0.232382 ± 0.00113057 (W 0.00112068) | 0.25692 ± 0.000354685 (W 0.00123918) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.19× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.12239 ± 0.0007492 (W 0.00202871) | 1.18047 ± 0.00245778 (W 0.00268427) | 1.0098 ± 0.000543145 (W 0.00123013) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.65682 ± 0.00432455 (W 0.00310403) | 2.78917 ± 0.000786225 (W 0.00337052) | 2.50781 ± 0.0030474 (W 0.00413975) | · | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.081943 ± 0.000114692 (W 0.000237925) | 0.159688 ± 0.00035305 (W 0.00141243) | 0.100587 ± 0.000450463 (W 0.00183362) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.344341 ± 0.000168589 (W 0.0019763) | 0.631948 ± 0.000646437 (W 0.00173719) | 0.481205 ± 0.00202727 (W 0.00192495) | 🔵 faer-fork 1.84× faster than `faer-upstream` | 🔵 faer-fork 1.40× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.886505 ± 0.000891563 (W 0.00131749) | 1.51151 ± 0.0900265 (W 0.00284918) | 1.33838 ± 0.00150063 (W 0.00158906) | 🔵 faer-fork 1.71× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.031178 ± 7.50555e-05 (W 0.000141909) | 0.05394 ± 0.000182748 (W 0.000922515) | 0.0263 ± 0.0001245 (W 9.30054e-05) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.19× slower than `lapack-mkl` |  |
| `qr_factor/n64/b1` | 0.123911 ± 0.000762587 (W 0.000593817) | 0.244745 ± 0.00105167 (W 0.00222907) | 0.156051 ± 9.66971e-05 (W 0.00157396) | 🔵 faer-fork 1.98× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `qr_factor/n96/b1` | 0.237703 ± 0.00102095 (W 0.00168006) | 0.484041 ± 0.00137682 (W 0.00215145) | 0.483202 ± 0.000996935 (W 0.00163017) | 🔵 faer-fork 2.04× faster than `faer-upstream` | 🔵 faer-fork 2.03× faster than `lapack-mkl` |  |
| `svd_thin/n32/b1` | 0.216314 ± 0.00081669 (W 0.00195031) | 0.233074 ± 0.00134905 (W 0.00190579) | 0.258752 ± 0.000493802 (W 0.00153088) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_thin/n64/b1` | 1.11651 ± 0.00116399 (W 0.00136737) | 1.18647 ± 0.00105841 (W 0.00197333) | 0.970516 ± 0.00191305 (W 0.00177509) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔴 faer-fork 1.15× slower than `lapack-mkl` |  |
| `svd_thin/n96/b1` | 2.6121 ± 0.00505277 (W 0.00347145) | 2.81974 ± 0.00349843 (W 0.00363753) | 2.32913 ± 0.000259513 (W 0.00211233) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n32/b1` | 0.082214 ± 0.000301863 (W 0.00196672) | 0.159988 ± 0.000374396 (W 0.0014701) | 0.100348 ± 8.31084e-05 (W 0.000288122) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `svd_values/n64/b1` | 0.345845 ± 0.0008435 (W 0.00146511) | 0.632789 ± 0.00115301 (W 0.00175109) | 0.481076 ± 0.000482899 (W 0.0018424) | 🔵 faer-fork 1.83× faster than `faer-upstream` | 🔵 faer-fork 1.39× faster than `lapack-mkl` |  |
| `svd_values/n96/b1` | 0.888145 ± 0.00282079 (W 0.00117499) | 1.51093 ± 0.0022113 (W 0.00260608) | 1.33709 ± 0.00089917 (W 0.00110786) | 🔵 faer-fork 1.70× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |

## linalg-small, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.018214 ± 2.3094e-05 (W 5.38516e-05) | 0.024906 ± 0.000209716 (W 8.12484e-05) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.068568 ± 0.000174261 (W 8.96103e-05) | 0.120434 ± 0.000438029 (W 0.000126053) | - | 🔵 faer-fork 1.76× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.149078 ± 0.000269222 (W 0.000275565) | 0.254423 ± 0.000902304 (W 0.00134308) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.125394 ± 0.000199015 (W 0.00121696) | 0.137446 ± 0.000373875 (W 0.00115374) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.49503 ± 0.00288077 (W 0.0016967) | 0.537149 ± 0.00329406 (W 0.00171108) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.47363 ± 0.00133223 (W 0.00272403) | 1.56711 ± 0.00107016 (W 0.00283644) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.0539 ± 0.000130128 (W 0.00114355) | 0.110406 ± 0.000116762 (W 0.000165648) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.19275 ± 0.00433088 (W 0.00142584) | 0.401289 ± 0.00386282 (W 0.00156135) | - | 🔵 faer-fork 2.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.421778 ± 0.00232939 (W 0.00194736) | 0.885703 ± 0.00046401 (W 0.00183262) | - | 🔵 faer-fork 2.10× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.018224 ± 6.4291e-05 (W 5.89067e-05) | 0.038462 ± 0.000861349 (W 0.000439045) | - | 🔵 faer-fork 2.11× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.068508 ± 0.000189297 (W 0.000281567) | 0.194723 ± 0.00151683 (W 0.00186166) | - | 🔵 faer-fork 2.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.136414 ± 0.000509926 (W 0.00145946) | 0.394384 ± 0.00321878 (W 0.00293887) | - | 🔵 faer-fork 2.89× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.12394 ± 0.000350089 (W 0.00029478) | 0.136645 ± 0.000546196 (W 0.000230011) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.490713 ± 0.0242063 (W 0.00265609) | 0.541538 ± 0.00053553 (W 0.00238262) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n96/b1` | 1.42141 ± 0.0027251 (W 0.00153996) | 1.53008 ± 0.0024978 (W 0.00292374) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.053519 ± 0.000281214 (W 0.000176565) | 0.109915 ± 0.000347132 (W 0.00103613) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.190465 ± 0.000939888 (W 0.00140246) | 0.399685 ± 0.00280064 (W 0.00198723) | - | 🔵 faer-fork 2.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.423409 ± 0.0011065 (W 0.00143602) | 0.887511 ± 0.00627214 (W 0.00123593) | - | 🔵 faer-fork 2.10× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.018234 ± 1.52753e-05 (W 6.02495e-05) | 0.046577 ± 0.00101677 (W 0.000452453) | - | 🔵 faer-fork 2.55× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.072655 ± 0.000397027 (W 0.000380888) | 0.23097 ± 0.00257572 (W 0.00409683) | - | 🔵 faer-fork 3.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.139671 ± 0.000741931 (W 0.00133631) | 0.46701 ± 0.00274013 (W 0.00536537) | - | 🔵 faer-fork 3.34× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.125023 ± 0.000768752 (W 0.00170382) | 0.138658 ± 0.00044679 (W 0.0010107) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.491616 ± 0.00429073 (W 0.00141172) | 0.549817 ± 0.00477075 (W 0.0026387) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.42426 ± 0.000659091 (W 0.00185058) | 1.55786 ± 0.00396385 (W 0.00529563) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.053751 ± 0.000350543 (W 0.000250979) | 0.110035 ± 0.000304927 (W 0.00129541) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.190745 ± 0.000262063 (W 0.00131448) | 0.400836 ± 0.00168301 (W 0.00188306) | - | 🔵 faer-fork 2.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.421545 ± 0.000946931 (W 0.0024514) | 0.886129 ± 0.00100033 (W 0.00164846) | - | 🔵 faer-fork 2.10× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.012834 ± 4.3589e-05 (W 4.81664e-05) | 0.016611 ± 2.51661e-05 (W 4.08656e-05) | - | 🔵 faer-fork 1.29× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.055023 ± 0.000230072 (W 0.000142145) | 0.068759 ± 0.000248967 (W 0.00010782) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.118792 ± 0.000495702 (W 0.00121891) | 0.149418 ± 0.000275893 (W 0.00159229) | - | 🔵 faer-fork 1.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.134319 ± 0.000618806 (W 0.000141422) | 0.146283 ± 6.45781e-05 (W 0.000274416) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.497258 ± 0.0016398 (W 0.00221776) | 0.542143 ± 0.00441718 (W 0.00178822) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.47157 ± 0.00324197 (W 0.00258557) | 1.56391 ± 0.0014494 (W 0.00260868) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.055834 ± 0.000405586 (W 0.00117839) | 0.109464 ± 0.000143643 (W 0.00014753) | - | 🔵 faer-fork 1.96× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.195886 ± 0.004619 (W 0.00149604) | 0.402409 ± 0.00354704 (W 0.00166239) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.424522 ± 0.00160812 (W 0.00173882) | 0.869012 ± 0.000638198 (W 0.00110651) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.012794 ± 3.84318e-05 (W 8.84873e-05) | 0.029625 ± 0.000282479 (W 0.000487115) | - | 🔵 faer-fork 2.32× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.05359 ± 0.000289425 (W 0.000185847) | 0.136144 ± 0.000869146 (W 0.00086048) | - | 🔵 faer-fork 2.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.103252 ± 0.000373658 (W 0.00106749) | 0.272948 ± 0.00327725 (W 0.00187153) | - | 🔵 faer-fork 2.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.133629 ± 0.000276117 (W 0.00127561) | 0.145622 ± 0.00150762 (W 0.00153035) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.489963 ± 0.0012923 (W 0.00184092) | 0.544393 ± 0.00259981 (W 0.00197193) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.41636 ± 0.00250334 (W 0.0016426) | 1.53211 ± 0.00508981 (W 0.00306316) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.055013 ± 0.000275645 (W 0.000149132) | 0.109103 ± 0.000293746 (W 0.00112507) | - | 🔵 faer-fork 1.98× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.195464 ± 0.000709212 (W 0.00183627) | 0.400347 ± 0.00186315 (W 0.00143314) | - | 🔵 faer-fork 2.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.426025 ± 0.00151697 (W 0.00151411) | 0.869189 ± 0.000414298 (W 0.00194845) | - | 🔵 faer-fork 2.04× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.012784 ± 0.000151438 (W 0.00010576) | 0.037239 ± 0.000413696 (W 0.000767181) | - | 🔵 faer-fork 2.91× faster than `faer-upstream` | - | `*` one row has no measurement here; dispatch-dominated (row under 20 us) |
| `qr_factor/n64/b1` | 0.054471 ± 0.000384279 (W 0.000278676) | 0.178853 ± 0.000821601 (W 0.00143744) | - | 🔵 faer-fork 3.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.103623 ± 0.00041156 (W 0.000635871) | 0.350554 ± 0.000258722 (W 0.00196629) | - | 🔵 faer-fork 3.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.13417 ± 0.00223051 (W 0.00186573) | 0.147505 ± 0.000867946 (W 0.00108347) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.488412 ± 0.0067136 (W 0.00154508) | 0.551438 ± 0.00395117 (W 0.0031682) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.41836 ± 0.00138858 (W 0.00297622) | 1.55364 ± 0.00176796 (W 0.00445039) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.055123 ± 0.000150111 (W 0.000163845) | 0.109174 ± 0.000320776 (W 0.00116656) | - | 🔵 faer-fork 1.98× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.195845 ± 0.000657264 (W 0.00155245) | 0.400198 ± 0.00121548 (W 0.00277736) | - | 🔵 faer-fork 2.04× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.426404 ± 0.00188014 (W 0.00183468) | 0.86821 ± 4.15492e-05 (W 0.00166169) | - | 🔵 faer-fork 2.04× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.029716 ± 0.000201793 (W 6.88426e-05) | 0.035155 ± 4.63717e-05 (W 0.000139041) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.114132 ± 0.000171079 (W 0.00110055) | 0.18238 ± 6.1101e-05 (W 0.00107434) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.262881 ± 0.000836776 (W 0.00131756) | 0.41262 ± 0.00112288 (W 0.0015517) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.159358 ± 0.000486568 (W 0.00130636) | 0.171028 ± 0.000506667 (W 0.000937415) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.653931 ± 0.00867097 (W 0.00217436) | 0.685175 ± 0.0128206 (W 0.00178575) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.93588 ± 0.00547062 (W 0.00216869) | 2.03543 ± 0.00486938 (W 0.00133088) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.064049 ± 0.00100911 (W 0.000214836) | 0.1184 ± 0.000863762 (W 0.00128626) | - | 🔵 faer-fork 1.85× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.245779 ± 0.000299847 (W 0.00134379) | 0.454839 ± 0.00143422 (W 0.00191686) | - | 🔵 faer-fork 1.85× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.603793 ± 0.00502206 (W 0.00203171) | 1.04608 ± 0.00537807 (W 0.0015106) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.029645 ± 7.63763e-05 (W 9.4092e-05) | 0.04832 ± 0.000519404 (W 0.000293807) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.103814 ± 0.000522642 (W 0.00133773) | 0.244846 ± 0.00192716 (W 0.00160173) | - | 🔵 faer-fork 2.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.205282 ± 0.000431442 (W 0.00142323) | 0.486125 ± 0.00543789 (W 0.0021616) | - | 🔵 faer-fork 2.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.159387 ± 0.00122202 (W 0.00130482) | 0.169986 ± 0.000430852 (W 0.00143507) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.61266 ± 0.00235358 (W 0.00215921) | 0.652254 ± 0.00530802 (W 0.00169483) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.73716 ± 0.000641402 (W 0.00250106) | 1.83506 ± 0.00620429 (W 0.00331436) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.063298 ± 0.00063195 (W 0.000145108) | 0.117479 ± 0.000244365 (W 0.00173673) | - | 🔵 faer-fork 1.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.247542 ± 0.00379499 (W 0.00188398) | 0.455591 ± 0.00346944 (W 0.00157183) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.600989 ± 0.000669629 (W 0.00184915) | 1.0447 ± 0.00115329 (W 0.000580664) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.029615 ± 4.58258e-05 (W 9.82003e-05) | 0.058078 ± 0.00139795 (W 0.000938019) | - | 🔵 faer-fork 1.96× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.104905 ± 0.0002805 (W 0.00122048) | 0.275021 ± 0.00191392 (W 0.00667434) | - | 🔵 faer-fork 2.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.201045 ± 0.000632401 (W 0.000965662) | 0.532682 ± 0.00701545 (W 0.00905751) | - | 🔵 faer-fork 2.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.157593 ± 0.000406198 (W 0.00165646) | 0.169916 ± 0.000439296 (W 0.00129349) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.606619 ± 0.00107086 (W 0.00174635) | 0.652749 ± 0.00112751 (W 0.00220063) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.71385 ± 0.00339664 (W 0.00424948) | 1.85053 ± 0.00387623 (W 0.00237219) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.063248 ± 0.00126542 (W 0.000204461) | 0.11786 ± 0.000296352 (W 0.00134349) | - | 🔵 faer-fork 1.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.246259 ± 0.000494765 (W 0.00123677) | 0.454195 ± 0.000775663 (W 0.00215007) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.600468 ± 0.000997325 (W 0.00246947) | 1.04574 ± 0.00126543 (W 0.000471909) | - | 🔵 faer-fork 1.74× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.023033 ± 0.000190788 (W 9.97612e-05) | 0.026299 ± 0.000110259 (W 0.000178043) | - | 🔵 faer-fork 1.14× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.097401 ± 0.000259854 (W 0.000258502) | 0.111608 ± 0.000317591 (W 0.000318131) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.22492 ± 0.00257393 (W 0.00216252) | 0.259193 ± 0.00128084 (W 0.00163724) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.159367 ± 0.000924606 (W 0.00207174) | 0.172731 ± 0.000880081 (W 0.00135672) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.657373 ± 0.0116447 (W 0.00246952) | 0.694892 ± 0.0126063 (W 0.00176018) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.93582 ± 0.00742783 (W 0.00416721) | 2.05626 ± 0.00267839 (W 0.00148293) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.06451 ± 0.00119141 (W 0.000216668) | 0.11825 ± 0.000567741 (W 0.00133369) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.245426 ± 0.000659182 (W 0.00125833) | 0.447735 ± 0.000450367 (W 0.00189268) | - | 🔵 faer-fork 1.82× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.605456 ± 0.0066173 (W 0.00155868) | 1.04441 ± 0.00566829 (W 0.000778359) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.022993 ± 4.2194e-05 (W 0.000124745) | 0.039414 ± 0.000431688 (W 0.000431012) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.085168 ± 0.000509687 (W 0.000332578) | 0.169065 ± 0.00285878 (W 0.00148963) | - | 🔵 faer-fork 1.99× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.164717 ± 0.000422966 (W 0.00114911) | 0.332789 ± 0.00103042 (W 0.00191582) | - | 🔵 faer-fork 2.02× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.160829 ± 0.00253204 (W 0.00113281) | 0.17117 ± 0.00190007 (W 0.00152251) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.621777 ± 0.00316286 (W 0.00163187) | 0.66062 ± 0.00624175 (W 0.00164168) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.73542 ± 0.00310337 (W 0.00148429) | 1.85401 ± 0.00302957 (W 0.00354461) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.063779 ± 0.000510524 (W 0.000184424) | 0.117129 ± 0.000106308 (W 0.0014831) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.25233 ± 0.00435358 (W 0.00192931) | 0.448878 ± 0.00372011 (W 0.00185033) | - | 🔵 faer-fork 1.78× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.604548 ± 0.000833139 (W 0.00209489) | 1.04339 ± 0.000702022 (W 0.00133687) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-small, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n32/b1` | 0.022803 ± 9.11976e-05 (W 5.74648e-05) | 0.046206 ± 0.00126391 (W 0.00135218) | - | 🔵 faer-fork 2.03× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n64/b1` | 0.085229 ± 0.000552513 (W 0.000390827) | 0.207778 ± 0.00229985 (W 0.00179577) | - | 🔵 faer-fork 2.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n96/b1` | 0.159919 ± 0.000232281 (W 0.00165842) | 0.407961 ± 0.00148211 (W 0.00204085) | - | 🔵 faer-fork 2.55× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n32/b1` | 0.158215 ± 0.000275228 (W 0.00173391) | 0.172171 ± 0.00131514 (W 0.000285159) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n64/b1` | 0.613743 ± 0.00211198 (W 0.00181267) | 0.660893 ± 0.000806929 (W 0.00113339) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n96/b1` | 1.71547 ± 0.00484992 (W 0.00263623) | 1.86635 ± 0.00161645 (W 0.00259475) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n32/b1` | 0.06402 ± 0.000314506 (W 0.000319753) | 0.11772 ± 0.000110259 (W 0.00113456) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n64/b1` | 0.245046 ± 0.000512172 (W 0.00141548) | 0.447183 ± 0.00148789 (W 0.00181184) | - | 🔵 faer-fork 1.82× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n96/b1` | 0.604839 ± 0.00444462 (W 0.00221702) | 1.04329 ± 0.00216165 (W 0.000835969) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/32`, `qr_factor/64`, `qr_factor/96`, `svd_thin/32`, `svd_thin/64`, `svd_thin/96`, `svd_values/32`, `svd_values/64`, `svd_values/96`.

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.296813 ± 0.00113492 (W 0.00135641) | 0.532993 ± 0.00274185 (W 0.00210517) | 0.368787 ± 0.000743078 (W 0.00163285) | 🔵 faer-fork 1.80× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.48893 ± 0.0107489 (W 0.0028414) | 2.87372 ± 0.00534755 (W 0.00659446) | 2.03778 ± 0.00219748 (W 0.00598265) | 🔵 faer-fork 1.93× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 8.55612 ± 0.0727341 (W 0.00792045) | 17.5451 ± 0.0347296 (W 0.0279438) | 14.1495 ± 0.0549815 (W 0.0284103) | 🔵 faer-fork 2.05× faster than `faer-upstream` | 🔵 faer-fork 1.65× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.37148 ± 0.00257066 (W 0.00663851) | 3.68569 ± 0.00372967 (W 0.00398092) | 3.38821 ± 0.0104228 (W 0.0161359) | 🔵 faer-fork 1.09× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 16.8094 ± 0.0192745 (W 0.00702484) | 18.46 ± 0.0226922 (W 0.016625) | 18.0015 ± 0.051229 (W 0.0209782) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 94.6539 ± 0.260295 (W 0.134751) | 105.652 ± 0.0815136 (W 0.0732994) | 116.248 ± 0.0048219 (W 0.103207) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.03472 ± 0.0022791 (W 0.00252229) | 2.68252 ± 0.00713758 (W 0.00332288) | 1.19464 ± 0.0250498 (W 0.00376429) | 🔵 faer-fork 2.59× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.3411 ± 0.0253405 (W 0.00667592) | 12.472 ± 0.0320438 (W 0.0124705) | 6.9427 ± 0.00287181 (W 0.00602039) | 🔵 faer-fork 1.97× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 41.2638 ± 0.221982 (W 0.0594276) | 66.5202 ± 0.252715 (W 0.0821559) | 48.1438 ± 0.161859 (W 0.0263387) | 🔵 faer-fork 1.61× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.245921 ± 0.00174154 (W 0.00124627) | 0.714919 ± 0.00568085 (W 0.00203588) | 0.197629 ± 0.106059 (W 0.00171067) | 🔵 faer-fork 2.91× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.00459 ± 0.0090109 (W 0.00139808) | 3.09772 ± 0.0215024 (W 0.0161092) | 0.668975 ± 0.00225482 (W 0.00275696) | 🔵 faer-fork 3.08× faster than `faer-upstream` | 🔴 faer-fork 1.50× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 4.12075 ± 0.0572278 (W 0.00642442) | 16.4165 ± 0.0800945 (W 0.0622804) | 3.86064 ± 0.00373221 (W 0.0047571) | 🔵 faer-fork 3.98× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.4941 ± 0.00906273 (W 0.0162959) | 2.81434 ± 0.0162283 (W 0.0147945) | 2.63255 ± 0.00687327 (W 0.00448932) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 11.4878 ± 0.023365 (W 0.0274457) | 13.2528 ± 0.0196034 (W 0.0159661) | 12.5341 ± 0.0328266 (W 0.0194132) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 45.0267 ± 1.10324 (W 1.21079) | 55.5627 ± 0.133999 (W 0.0702604) | 57.441 ± 0.096725 (W 0.0721345) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.28× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.03559 ± 0.00292806 (W 0.00237085) | 2.17688 ± 0.00613565 (W 0.0039507) | 1.13857 ± 0.00529041 (W 0.00294774) | 🔵 faer-fork 2.10× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.21939 ± 0.0072004 (W 0.00962784) | 10.4903 ± 0.031647 (W 0.0084839) | 6.12279 ± 0.0112407 (W 0.0123026) | 🔵 faer-fork 1.69× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 24.3027 ± 0.053618 (W 0.031953) | 41.8655 ± 0.0662746 (W 0.0526243) | 25.6933 ± 0.0849053 (W 0.0294197) | 🔵 faer-fork 1.72× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.243623 ± 0.000672455 (W 0.00157972) | 0.810577 ± 0.000968981 (W 0.00411203) | 0.157024 ± 0.00118718 (W 0.00150378) | 🔵 faer-fork 3.33× faster than `faer-upstream` | 🔴 faer-fork 1.55× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.938358 ± 0.00986512 (W 0.0030108) | 3.31913 ± 0.0181301 (W 0.0131921) | 0.576726 ± 0.000519338 (W 0.00329231) | 🔵 faer-fork 3.54× faster than `faer-upstream` | 🔴 faer-fork 1.63× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 3.43501 ± 0.0381289 (W 0.00514254) | 16.9371 ± 0.097963 (W 0.031025) | 2.31414 ± 0.00579373 (W 0.00441228) | 🔵 faer-fork 4.93× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.454 ± 0.00945211 (W 0.00448015) | 2.81557 ± 0.00357958 (W 0.00341686) | 2.5096 ± 0.00751638 (W 0.00470464) | 🔵 faer-fork 1.15× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 11.1902 ± 0.0103892 (W 0.0158369) | 13.3199 ± 0.0926144 (W 0.0172291) | 11.6331 ± 0.105499 (W 0.0223393) | 🔵 faer-fork 1.19× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 38.0621 ± 0.055015 (W 0.167867) | 52.6115 ± 0.162964 (W 0.0978459) | 48.9411 ± 2.22826 (W 0.0861336) | 🔵 faer-fork 1.38× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.03718 ± 0.000878623 (W 0.00173669) | 2.18203 ± 0.00418336 (W 0.00242113) | 1.12931 ± 0.00300762 (W 0.00427958) | 🔵 faer-fork 2.10× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.27049 ± 0.0120916 (W 0.0144957) | 10.5758 ± 0.0256927 (W 0.00908116) | 5.99777 ± 0.00886685 (W 0.0052493) | 🔵 faer-fork 1.69× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 22.4444 ± 0.0653869 (W 0.343734) | 40.2994 ± 0.0876019 (W 0.102873) | 22.4492 ± 0.0579879 (W 0.0212738) | 🔵 faer-fork 1.80× faster than `faer-upstream` | · |  |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.235148 ± 0.000420357 (W 0.00129299) | 0.277748 ± 0.00133439 (W 0.00170093) | 0.331528 ± 0.00149747 (W 0.00385045) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.24245 ± 0.0103134 (W 0.00148769) | 1.37098 ± 0.00560646 (W 0.00223483) | 1.89383 ± 0.00707846 (W 0.00395164) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.5728 ± 0.0663791 (W 0.00546161) | 7.96508 ± 0.0617304 (W 0.00320938) | 13.4057 ± 0.0945712 (W 0.0162451) | 🔵 faer-fork 1.05× faster than `faer-upstream` | 🔵 faer-fork 1.77× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.35796 ± 0.00643094 (W 0.00422358) | 3.68107 ± 0.00497755 (W 0.003523) | 3.31502 ± 0.0116746 (W 0.0116047) | 🔵 faer-fork 1.10× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 16.7639 ± 0.0346892 (W 0.0170083) | 18.3574 ± 0.0395659 (W 0.0185581) | 17.6989 ± 0.0310557 (W 0.0205311) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.06× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 93.7375 ± 0.102325 (W 0.0556407) | 104.82 ± 0.750377 (W 0.0613297) | 113.755 ± 1.37899 (W 0.127184) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.01193 ± 0.000602007 (W 0.000797491) | 2.6057 ± 0.00747928 (W 0.00268271) | 1.15739 ± 0.00126144 (W 0.0027403) | 🔵 faer-fork 2.57× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.17787 ± 0.00534213 (W 0.00558097) | 12.2936 ± 0.0180926 (W 0.0160202) | 6.8354 ± 0.0150481 (W 0.00952) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 40.1194 ± 0.0532801 (W 0.0217547) | 65.6246 ± 0.187747 (W 0.0301488) | 47.0044 ± 0.0963293 (W 0.0274676) | 🔵 faer-fork 1.64× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.18252 ± 0.000682373 (W 0.00132079) | 0.413665 ± 0.0061015 (W 0.00238067) | 0.183352 ± 0.000807159 (W 0.00141271) | 🔵 faer-fork 2.27× faster than `faer-upstream` | · |  |
| `qr_factor/n256/b1` | 0.727397 ± 0.00282254 (W 0.0013782) | 1.30038 ± 0.0119619 (W 0.0052079) | 0.621214 ± 0.00398302 (W 0.00205986) | 🔵 faer-fork 1.79× faster than `faer-upstream` | 🔴 faer-fork 1.17× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 3.07345 ± 0.0574865 (W 0.00617604) | 4.38324 ± 0.0679491 (W 0.00818933) | 3.69612 ± 0.0301686 (W 0.00486514) | 🔵 faer-fork 1.43× faster than `faer-upstream` | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.44585 ± 0.00264793 (W 0.0136666) | 2.77432 ± 0.0127427 (W 0.0137903) | 2.60775 ± 0.00691849 (W 0.00502659) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 11.4052 ± 0.0126121 (W 0.0252486) | 13.1402 ± 0.048108 (W 0.00789435) | 12.3842 ± 0.0449721 (W 0.0178372) | 🔵 faer-fork 1.15× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 43.2775 ± 1.00683 (W 1.30563) | 54.7566 ± 0.265245 (W 0.391516) | 58.4293 ± 0.560897 (W 0.106235) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.01604 ± 0.00273009 (W 0.00134291) | 2.10866 ± 0.00465115 (W 0.00671235) | 1.13434 ± 0.00672062 (W 0.00522233) | 🔵 faer-fork 2.08× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.08746 ± 0.00900247 (W 0.0113072) | 10.2973 ± 0.00896506 (W 0.00846159) | 6.12409 ± 0.0262429 (W 0.0120846) | 🔵 faer-fork 1.69× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 23.1273 ± 0.0630248 (W 0.0128151) | 40.9244 ± 0.0656942 (W 0.0672154) | 25.6746 ± 0.119407 (W 0.0194887) | 🔵 faer-fork 1.77× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.177531 ± 0.00165897 (W 0.00105297) | 0.521787 ± 0.00466966 (W 0.0035646) | 0.145573 ± 0.000649943 (W 0.00142088) | 🔵 faer-fork 2.94× faster than `faer-upstream` | 🔴 faer-fork 1.22× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 0.679882 ± 0.00121916 (W 0.00317225) | 1.55325 ± 0.0224212 (W 0.00619998) | 0.547915 ± 0.00136766 (W 0.00136905) | 🔵 faer-fork 2.28× faster than `faer-upstream` | 🔴 faer-fork 1.24× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 2.43419 ± 0.00968553 (W 0.00516041) | 4.75667 ± 0.0298101 (W 0.0284564) | 2.244 ± 0.00441684 (W 0.00411225) | 🔵 faer-fork 1.95× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 2.42946 ± 0.00474672 (W 0.00392708) | 2.80125 ± 0.0124478 (W 0.00531241) | 2.49134 ± 0.00941872 (W 0.00493268) | 🔵 faer-fork 1.15× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 11.1355 ± 0.0245891 (W 0.013793) | 13.1932 ± 0.0189858 (W 0.0217036) | 11.4873 ± 0.0501354 (W 0.0107612) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · |  |
| `svd_thin/n512/b1` | 37.2093 ± 0.0552257 (W 0.0169744) | 51.5822 ± 0.0390358 (W 0.0541127) | 50.8581 ± 0.673328 (W 0.0465283) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.01499 ± 0.00382868 (W 0.00153233) | 2.1163 ± 0.00412513 (W 0.00294006) | 1.12806 ± 0.0085754 (W 0.00157782) | 🔵 faer-fork 2.09× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 6.12418 ± 0.00944891 (W 0.00991681) | 10.4307 ± 0.0466323 (W 0.0171474) | 6.00644 ± 0.0556047 (W 0.00612902) | 🔵 faer-fork 1.70× faster than `faer-upstream` | · |  |
| `svd_values/n512/b1` | 21.436 ± 0.0471312 (W 0.0179191) | 39.2496 ± 0.130205 (W 0.039407) | 22.5164 ± 0.115804 (W 0.0204491) | 🔵 faer-fork 1.83× faster than `faer-upstream` | · |  |

## linalg-mid, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.760987 ± 0.000721636 (W 0.00175197) | 1.06756 ± 0.000722143 (W 0.00259221) | 0.954717 ± 0.00129383 (W 0.00187513) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.62806 ± 0.0141187 (W 0.00403108) | 6.47476 ± 0.0564391 (W 0.0106729) | 5.66498 ± 0.0111853 (W 0.0105427) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.22× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 30.0153 ± 0.0653846 (W 0.0453924) | 37.5435 ± 0.378027 (W 0.0245192) | 38.865 ± 0.099896 (W 0.0396048) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.36946 ± 0.00415453 (W 0.0063575) | 5.83057 ± 0.00985345 (W 0.00626491) | 7.04154 ± 0.0157474 (W 0.00596188) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 32.5536 ± 0.097672 (W 0.0203755) | 34.7784 ± 0.162974 (W 0.0408386) | 43.7595 ± 0.268333 (W 0.0402472) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 207.684 ± 0.27613 (W 0.494133) | 214.001 ± 0.432656 (W 0.460611) | 277.151 ± 6.72849 (W 0.771897) | · | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.84777 ± 0.00283549 (W 0.00485944) | 3.56702 ± 0.0114208 (W 0.00763492) | 2.75504 ± 0.00486327 (W 0.00333054) | 🔵 faer-fork 1.93× faster than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.4577 ± 0.0930448 (W 0.0129828) | 20.0314 ± 0.0318867 (W 0.0268417) | 18.1106 ± 0.0203598 (W 0.0149631) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_values/n512/b1` | 93.6134 ± 0.286235 (W 0.104644) | 114.665 ± 0.498237 (W 0.100808) | 121.833 ± 0.649267 (W 0.126474) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.476372 ± 0.00104122 (W 0.00149944) | 0.994526 ± 0.0152535 (W 0.00342803) | 0.45099 ± 0.00185592 (W 0.0016723) | 🔵 faer-fork 2.09× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 2.20854 ± 0.00166952 (W 0.00322918) | 4.64617 ± 0.0169059 (W 0.00716013) | 1.63234 ± 0.00320726 (W 0.00250105) | 🔵 faer-fork 2.10× faster than `faer-upstream` | 🔴 faer-fork 1.35× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 10.8145 ± 0.0236607 (W 0.0177042) | 21.558 ± 0.135006 (W 0.055657) | 11.3812 ± 0.010784 (W 0.0174405) | 🔵 faer-fork 1.99× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.70478 ± 0.0121018 (W 0.0145333) | 4.16429 ± 0.0176564 (W 0.0165921) | 4.15333 ± 0.00171807 (W 0.0076477) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 20.0537 ± 0.0232416 (W 0.0322189) | 22.3697 ± 0.0195506 (W 0.0275569) | 21.3624 ± 0.11059 (W 0.0486548) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.2364 ± 1.49796 (W 1.25626) | 88.7257 ± 0.343819 (W 0.0766021) | 120.465 ± 4.24953 (W 0.26511) | 🔵 faer-fork 1.11× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n128/b1` | 1.83651 ± 0.000229306 (W 0.0020565) | 3.07989 ± 0.00530139 (W 0.00405972) | 2.02388 ± 0.0192782 (W 0.00393116) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔵 faer-fork 1.10× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.4071 ± 0.0262437 (W 0.0182198) | 16.8852 ± 0.125666 (W 0.0249732) | 11.1112 ± 0.0378308 (W 0.0125096) | 🔵 faer-fork 1.36× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 45.0749 ± 0.0816524 (W 0.0425106) | 58.9771 ± 0.202912 (W 0.0731856) | 56.3427 ± 0.196765 (W 0.0747997) | 🔵 faer-fork 1.31× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-mid, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.441655 ± 0.00188761 (W 0.00225785) | 1.07588 ± 0.00660071 (W 0.00618672) | 0.321049 ± 0.00107517 (W 0.00244889) | 🔵 faer-fork 2.44× faster than `faer-upstream` | 🔴 faer-fork 1.38× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.80117 ± 0.00574307 (W 0.00202552) | 4.83259 ± 0.0806733 (W 0.0126489) | 1.61579 ± 0.00427127 (W 0.00188773) | 🔵 faer-fork 2.68× faster than `faer-upstream` | 🔴 faer-fork 1.11× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 7.78317 ± 0.0522701 (W 0.0102581) | 20.2785 ± 0.813159 (W 0.124971) | 5.81049 ± 0.0141947 (W 0.0134094) | 🔵 faer-fork 2.61× faster than `faer-upstream` | 🔴 faer-fork 1.34× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_thin/n128/b1` | 3.52916 ± 0.0188841 (W 0.00890296) | 4.15755 ± 0.00921521 (W 0.00695123) | 3.6452 ± 0.0114256 (W 0.00779918) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.5694 ± 0.0386693 (W 0.0319377) | 22.0683 ± 0.283601 (W 0.0353844) | 17.2327 ± 0.131976 (W 0.0180899) | 🔵 faer-fork 1.19× faster than `faer-upstream` | 🔴 faer-fork 1.08× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 61.8775 ± 0.130184 (W 0.118257) | 75.7916 ± 0.199504 (W 0.543889) | 86.9459 ± 1.93887 (W 0.272773) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.8356 ± 0.00356951 (W 0.00315674) | 3.08217 ± 0.0076861 (W 0.00566881) | 1.91306 ± 0.0059975 (W 0.00453407) | 🔵 faer-fork 1.68× faster than `faer-upstream` | · |  |
| `svd_values/n256/b1` | 12.3146 ± 0.0741098 (W 0.0260616) | 17.1466 ± 0.212548 (W 0.230174) | 9.67184 ± 0.0335318 (W 0.0201515) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 37.6321 ± 0.208421 (W 0.0471461) | 52.3761 ± 0.0225103 (W 0.0684608) | 43.3654 ± 0.0844868 (W 0.0653054) | 🔵 faer-fork 1.39× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.698524 ± 0.00192412 (W 0.00221008) | 0.752801 ± 0.000916887 (W 0.00139962) | 0.909783 ± 0.00304957 (W 0.00138941) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 4.27998 ± 0.00475612 (W 0.00635146) | 4.47754 ± 0.0113834 (W 0.00395091) | 5.50565 ± 0.00963477 (W 0.00784404) | · | 🔵 faer-fork 1.29× faster than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 27.8547 ± 0.00348444 (W 0.0152591) | 28.5837 ± 0.044701 (W 0.013684) | 37.6405 ± 0.0381168 (W 0.0342204) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 5.33745 ± 0.00505506 (W 0.00451449) | 5.79817 ± 0.00776689 (W 0.00293351) | 6.96557 ± 0.0085161 (W 0.00752369) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.31× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 32.2641 ± 0.0877532 (W 0.025811) | 34.5678 ± 0.155597 (W 0.0258319) | 43.7465 ± 0.756447 (W 0.0486942) | 🔵 faer-fork 1.07× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 206.847 ± 0.454244 (W 0.412106) | 213.017 ± 0.176171 (W 0.307314) | 273.565 ± 2.26249 (W 0.741031) | · | 🔵 faer-fork 1.32× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.80248 ± 0.0113024 (W 0.00548964) | 3.53851 ± 0.012189 (W 0.00525532) | 2.70829 ± 0.00402356 (W 0.00533665) | 🔵 faer-fork 1.96× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 13.2526 ± 0.0429792 (W 0.0142715) | 19.7325 ± 0.0258383 (W 0.0256795) | 17.9544 ± 0.960554 (W 0.0204994) | 🔵 faer-fork 1.49× faster than `faer-upstream` | 🔵 faer-fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/n512/b1` | 92.4503 ± 0.127022 (W 0.0626126) | 113.74 ± 0.480861 (W 0.369997) | 120.319 ± 1.01065 (W 0.0888567) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |

## linalg-mid, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.411016 ± 0.00544458 (W 0.00215372) | 0.653049 ± 0.00478055 (W 0.00264031) | 0.437759 ± 0.0018644 (W 0.00168583) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.93646 ± 0.00762046 (W 0.00202738) | 2.51977 ± 0.0153496 (W 0.00393018) | 1.5729 ± 0.00131534 (W 0.00298514) | 🔵 faer-fork 1.30× faster than `faer-upstream` | 🔴 faer-fork 1.23× slower than `lapack-mkl` |  |
| `qr_factor/n512/b1` | 9.06302 ± 0.103566 (W 0.00737907) | 10.6453 ± 0.148493 (W 0.0108327) | 10.9753 ± 0.226605 (W 0.0114516) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.67086 ± 0.013399 (W 0.0141689) | 4.14384 ± 0.0125251 (W 0.0197821) | 4.11524 ± 0.0175612 (W 0.00503934) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/n256/b1` | 19.7864 ± 0.0664754 (W 0.0139853) | 22.0908 ± 0.0933714 (W 0.0255378) | 21.1039 ± 0.0355564 (W 0.0367783) | 🔵 faer-fork 1.12× faster than `faer-upstream` | 🔵 faer-fork 1.07× faster than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 80.9949 ± 1.06286 (W 1.27789) | 87.9149 ± 0.249379 (W 0.466235) | 121.823 ± 7.96408 (W 0.278202) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `svd_values/n128/b1` | 1.80728 ± 0.00397513 (W 0.0025283) | 3.04832 ± 0.00471962 (W 0.00427035) | 2.01026 ± 0.00799308 (W 0.00420671) | 🔵 faer-fork 1.69× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.2112 ± 0.0221529 (W 0.0183066) | 16.6936 ± 0.102986 (W 0.0192026) | 11.0795 ± 0.0900525 (W 0.0328279) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 1.10× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 43.9844 ± 0.0739628 (W 0.0289362) | 57.9721 ± 0.056177 (W 0.0974532) | 56.9323 ± 5.23019 (W 0.0621729) | 🔵 faer-fork 1.32× faster than `faer-upstream` | 🔵 faer-fork 1.29× faster than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.372165 ± 0.00375221 (W 3.50397) | 0.744937 ± 0.00342501 (W 0.00318744) | 0.306463 ± 0.00250986 (W 0.00247513) | 🔵 faer-fork 2.00× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `qr_factor/n256/b1` | 1.52919 ± 0.00557006 (W 0.00292774) | 2.6566 ± 0.00660717 (W 0.0210365) | 1.57723 ± 0.00171122 (W 0.00408941) | 🔵 faer-fork 1.74× faster than `faer-upstream` | · |  |
| `qr_factor/n512/b1` | 6.19752 ± 0.0174483 (W 0.0104636) | 9.83157 ± 0.0832935 (W 0.127643) | 5.80487 ± 0.00919916 (W 0.00846759) | 🔵 faer-fork 1.59× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/n128/b1` | 3.51811 ± 0.00695141 (W 0.0040968) | 4.15099 ± 0.00585671 (W 0.00887049) | 3.60898 ± 0.00398993 (W 0.00817645) | 🔵 faer-fork 1.18× faster than `faer-upstream` | · |  |
| `svd_thin/n256/b1` | 18.3105 ± 0.0580537 (W 0.0162634) | 21.6117 ± 0.146562 (W 0.161689) | 17.2318 ± 0.0821595 (W 0.0292257) | 🔵 faer-fork 1.18× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_thin/n512/b1` | 60.8063 ± 0.0832962 (W 0.091256) | 74.7661 ± 0.468509 (W 0.367066) | 89.3572 ± 1.75975 (W 0.0693282) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.47× faster than `lapack-mkl` |  |
| `svd_values/n128/b1` | 1.80929 ± 0.00384604 (W 0.00247801) | 3.04701 ± 0.00752041 (W 0.0034286) | 1.90664 ± 0.00715674 (W 0.00356409) | 🔵 faer-fork 1.68× faster than `faer-upstream` | 🔵 faer-fork 1.05× faster than `lapack-mkl` |  |
| `svd_values/n256/b1` | 12.0909 ± 0.00826766 (W 0.00950526) | 16.6004 ± 0.0486091 (W 0.0274296) | 9.98371 ± 0.195069 (W 0.0136943) | 🔵 faer-fork 1.37× faster than `faer-upstream` | 🔴 faer-fork 1.21× slower than `lapack-mkl` |  |
| `svd_values/n512/b1` | 36.566 ± 0.0342208 (W 0.176831) | 51.3054 ± 0.0874448 (W 0.0602229) | 45.8375 ± 0.827322 (W 0.025568) | 🔵 faer-fork 1.40× faster than `faer-upstream` | 🔵 faer-fork 1.25× faster than `lapack-mkl` |  |

## linalg-mid, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.258625 ± 0.00110835 (W 0.00160021) | 0.447553 ± 0.00319562 (W 0.00162542) | - | 🔵 faer-fork 1.73× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.01283 ± 0.00196288 (W 0.00108652) | 1.77684 ± 0.0017833 (W 0.0056559) | - | 🔵 faer-fork 1.75× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.19432 ± 0.0543128 (W 0.0045352) | 10.4405 ± 0.0595068 (W 0.0162834) | - | 🔵 faer-fork 2.01× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.16168 ± 0.0251506 (W 0.00173021) | 2.32329 ± 0.0201885 (W 0.00263145) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.4747 ± 0.013515 (W 0.00606047) | 11.1757 ± 0.0169866 (W 0.014298) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 55.1581 ± 0.260568 (W 0.036853) | 61.4062 ± 0.0704124 (W 0.0369488) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.75244 ± 0.00608086 (W 0.00172997) | 1.71199 ± 0.0022578 (W 0.00194471) | - | 🔵 faer-fork 2.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.13643 ± 0.00467855 (W 0.00350276) | 7.86472 ± 0.00867598 (W 0.00747207) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.7006 ± 0.0561871 (W 0.0128071) | 40.1918 ± 0.132293 (W 0.032666) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.21343 ± 0.00079181 (W 0.00193642) | 0.637804 ± 0.00741684 (W 0.00465336) | - | 🔵 faer-fork 2.99× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.789623 ± 0.00345904 (W 0.00160522) | 2.33368 ± 0.03444 (W 0.0123632) | - | 🔵 faer-fork 2.96× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 2.92474 ± 0.0332355 (W 0.00585073) | 10.7095 ± 0.114143 (W 0.0435758) | - | 🔵 faer-fork 3.66× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 1.63489 ± 0.00678504 (W 0.00927127) | 1.82239 ± 0.00930153 (W 0.00722528) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.63052 ± 0.0438015 (W 0.0640242) | 8.37442 ± 0.0636975 (W 0.0472944) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 28.8767 ± 0.081902 (W 0.840788) | 35.5503 ± 0.0225068 (W 0.0689478) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.748707 ± 0.00267393 (W 0.00227304) | 1.4418 ± 0.0038301 (W 0.00273065) | - | 🔵 faer-fork 1.93× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.11122 ± 0.0137161 (W 0.00624174) | 6.67403 ± 0.0175956 (W 0.00480428) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 17.0041 ± 0.0621164 (W 0.0270627) | 27.8354 ± 0.0798995 (W 0.0357592) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.213427 ± 0.000958437 (W 0.00170336) | 0.750213 ± 0.0102189 (W 0.00712877) | - | 🔵 faer-fork 3.52× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.780967 ± 0.00695424 (W 0.00314447) | 2.62698 ± 0.0333888 (W 0.0271164) | - | 🔵 faer-fork 3.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 2.69343 ± 0.0299443 (W 0.0052445) | 11.1184 ± 0.163588 (W 0.0500601) | - | 🔵 faer-fork 4.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 1.6263 ± 0.00568047 (W 0.00368873) | 1.96344 ± 0.00679134 (W 0.00626377) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.4233 ± 0.0327343 (W 0.00910631) | 8.68972 ± 0.0284878 (W 0.0207568) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 26.5225 ± 0.0773802 (W 0.0641371) | 34.4831 ± 0.114154 (W 0.051126) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.747278 ± 0.00407442 (W 0.00139056) | 1.44461 ± 0.00339737 (W 0.0023633) | - | 🔵 faer-fork 1.93× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.18127 ± 0.00942025 (W 0.0165991) | 6.77803 ± 0.0402137 (W 0.00975107) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.3604 ± 0.0660706 (W 0.0295021) | 27.1924 ± 0.102335 (W 0.0226745) | - | 🔵 faer-fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.204962 ± 0.000670771 (W 0.00115498) | 0.253985 ± 0.00123702 (W 0.00143599) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.806732 ± 0.00123339 (W 0.00113258) | 0.958827 ± 0.0022426 (W 0.00129438) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.25443 ± 0.010358 (W 0.00300548) | 4.75862 ± 0.00917992 (W 0.00212572) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.16117 ± 0.0232325 (W 0.00464508) | 2.33235 ± 0.0241166 (W 0.00302067) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.4704 ± 0.0155367 (W 0.00650014) | 11.1827 ± 0.0184873 (W 0.00854783) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 54.4372 ± 0.0784037 (W 0.0294551) | 60.9377 ± 0.0890584 (W 0.073101) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.747902 ± 0.00453346 (W 0.00204025) | 1.67521 ± 0.00838667 (W 0.0021238) | - | 🔵 faer-fork 2.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 3.99651 ± 0.00215403 (W 0.0042686) | 7.68214 ± 0.0114649 (W 0.0106759) | - | 🔵 faer-fork 1.92× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.1396 ± 0.0661181 (W 0.0155051) | 39.6822 ± 0.144855 (W 0.0262908) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.157906 ± 0.000717239 (W 0.00123548) | 0.391342 ± 0.00494568 (W 0.0022472) | - | 🔵 faer-fork 2.48× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.56933 ± 0.00488821 (W 0.00295907) | 1.15182 ± 0.0100714 (W 0.00467138) | - | 🔵 faer-fork 2.02× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 2.03402 ± 0.0212815 (W 0.00272962) | 3.47184 ± 0.0500542 (W 0.00795322) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 1.62056 ± 0.00859773 (W 0.00752716) | 1.82634 ± 0.00368012 (W 0.00892447) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.59977 ± 0.0765865 (W 0.0601277) | 8.38486 ± 0.131145 (W 0.0571365) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 28.4042 ± 0.92436 (W 1.01493) | 34.9679 ± 0.0960861 (W 0.0263045) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_values/n128/b1` | 0.741879 ± 0.0011985 (W 0.00156848) | 1.40893 ± 0.00422077 (W 0.00279059) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 3.96639 ± 0.0118878 (W 0.00941062) | 6.47917 ± 0.00817047 (W 0.00884297) | - | 🔵 faer-fork 1.63× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 16.4562 ± 0.0610054 (W 0.0250817) | 27.2607 ± 0.125571 (W 0.0237898) | - | 🔵 faer-fork 1.66× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.156553 ± 0.000462008 (W 0.00152079) | 0.537285 ± 0.00896564 (W 0.00310455) | - | 🔵 faer-fork 3.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.55556 ± 0.00817243 (W 0.00211099) | 1.4278 ± 0.0189183 (W 0.00432872) | - | 🔵 faer-fork 2.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 1.78708 ± 0.0369102 (W 0.00489175) | 4.03448 ± 0.0659184 (W 0.0107732) | - | 🔵 faer-fork 2.26× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 1.60855 ± 0.00447921 (W 0.00212926) | 1.96445 ± 0.00495464 (W 0.0124736) | - | 🔵 faer-fork 1.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 7.40913 ± 0.0167431 (W 0.018761) | 8.71785 ± 0.0275933 (W 0.0282761) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 26.0837 ± 0.0572056 (W 0.0600502) | 33.9853 ± 0.0655578 (W 0.0469311) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 0.741186 ± 0.00405265 (W 0.00289511) | 1.40998 ± 0.00136621 (W 0.00254567) | - | 🔵 faer-fork 1.90× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 4.042 ± 0.00869242 (W 0.0113668) | 6.61295 ± 0.0387961 (W 0.00819321) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 15.8487 ± 0.0319072 (W 0.033644) | 26.5453 ± 0.0863197 (W 0.0286813) | - | 🔵 faer-fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.484738 ± 0.00332263 (W 0.00181654) | 0.762319 ± 0.00196506 (W 0.00163956) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.61184 ± 0.0096872 (W 0.00216176) | 3.81892 ± 0.00240555 (W 0.00583365) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 15.7898 ± 0.107846 (W 0.0248616) | 24.6864 ± 0.289498 (W 0.0139224) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 3.12522 ± 0.0154824 (W 0.00429302) | 3.35289 ± 0.0115137 (W 0.00229275) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 18.1442 ± 0.028168 (W 0.0180977) | 19.4666 ± 0.0285935 (W 0.0386914) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 111.969 ± 0.789377 (W 0.208397) | 121.511 ± 0.972311 (W 0.0988398) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.16978 ± 0.00519394 (W 0.00270787) | 2.12793 ± 0.00427924 (W 0.00391319) | - | 🔵 faer-fork 1.82× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.37159 ± 0.0273416 (W 0.00714421) | 11.4943 ± 0.0123712 (W 0.0202099) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 49.4043 ± 0.58217 (W 0.130839) | 68.8392 ± 0.860867 (W 0.137581) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.333262 ± 0.00132416 (W 0.00140962) | 0.801185 ± 0.00866065 (W 0.00270922) | - | 🔵 faer-fork 2.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.41526 ± 0.00327087 (W 0.00257691) | 3.29162 ± 0.0205635 (W 0.01726) | - | 🔵 faer-fork 2.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 6.22693 ± 0.0148135 (W 0.00692659) | 17.2679 ± 0.633846 (W 0.0407531) | - | 🔵 faer-fork 2.77× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `svd_thin/n128/b1` | 2.2664 ± 0.0172074 (W 0.00753804) | 2.49544 ± 0.0061783 (W 0.00742153) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.7129 ± 0.0247839 (W 0.049126) | 13.1197 ± 0.0955177 (W 0.0598048) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 46.8638 ± 0.459037 (W 0.916176) | 57.6274 ± 0.0406765 (W 0.052446) | - | 🔵 faer-fork 1.23× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.17355 ± 0.0041036 (W 0.00283416) | 1.85678 ± 0.00841616 (W 0.00222314) | - | 🔵 faer-fork 1.58× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.92683 ± 0.0258045 (W 0.00876909) | 9.92264 ± 0.0147174 (W 0.0102045) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 26.8092 ± 0.0945226 (W 0.04569) | 41.3157 ± 0.0653155 (W 0.113767) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.315561 ± 0.000417842 (W 0.00230257) | 0.834966 ± 0.0138281 (W 0.0112954) | - | 🔵 faer-fork 2.65× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.2489 ± 0.00829477 (W 0.00317852) | 3.43161 ± 0.0150823 (W 0.018376) | - | 🔵 faer-fork 2.75× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 4.74366 ± 0.0147448 (W 0.00832951) | 16.7861 ± 0.0881979 (W 0.0949307) | - | 🔵 faer-fork 3.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.17831 ± 0.0108787 (W 0.00352988) | 2.52282 ± 0.00527638 (W 0.00707187) | - | 🔵 faer-fork 1.16× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.9896 ± 0.0229323 (W 0.0144161) | 13.0258 ± 0.069974 (W 0.0287019) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 38.9116 ± 0.0907526 (W 0.0355049) | 52.4563 ± 0.391298 (W 0.191386) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.17103 ± 0.00227969 (W 0.00434763) | 1.85698 ± 0.0046216 (W 0.00636613) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.99776 ± 0.0128969 (W 0.0115311) | 9.98578 ± 0.0522586 (W 0.0103717) | - | 🔵 faer-fork 1.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 24.1087 ± 0.142517 (W 0.020821) | 39.0494 ± 0.0428866 (W 0.0881102) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.423318 ± 0.00101133 (W 0.0015416) | 0.478551 ± 0.00193119 (W 0.0017956) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 2.33662 ± 0.0108178 (W 0.00180489) | 2.52809 ± 0.0124343 (W 0.001191) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 14.8317 ± 0.154976 (W 0.00723346) | 15.524 ± 0.121014 (W 0.0229302) | - | · | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 3.11439 ± 0.0105458 (W 0.00259677) | 3.35247 ± 0.013211 (W 0.00443551) | - | 🔵 faer-fork 1.08× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 18.0292 ± 0.0200057 (W 0.0137465) | 19.2932 ± 0.0307482 (W 0.0479816) | - | 🔵 faer-fork 1.07× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 110.981 ± 0.154191 (W 0.124612) | 120.583 ± 0.271753 (W 0.0635239) | - | 🔵 faer-fork 1.09× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.14431 ± 0.00291056 (W 0.000615635) | 2.09788 ± 0.00347544 (W 0.00289883) | - | 🔵 faer-fork 1.83× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 7.2226 ± 0.0347312 (W 0.00645176) | 11.3461 ± 0.0232181 (W 0.0122261) | - | 🔵 faer-fork 1.57× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 48.0686 ± 0.131825 (W 0.195054) | 67.8642 ± 0.283159 (W 0.280394) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.265284 ± 0.00143005 (W 0.00185063) | 0.510142 ± 0.00606176 (W 0.0023951) | - | 🔵 faer-fork 1.92× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 1.13921 ± 0.00309085 (W 0.0018318) | 1.77327 ± 0.01278 (W 0.003376) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 5.1056 ± 0.0523409 (W 0.00498867) | 6.73944 ± 0.0371266 (W 0.0092854) | - | 🔵 faer-fork 1.32× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.24291 ± 0.00667905 (W 0.00871064) | 2.47716 ± 0.00237456 (W 0.00909638) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 11.6018 ± 0.052627 (W 0.0616174) | 12.988 ± 0.0964435 (W 0.0697878) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 45.931 ± 0.943635 (W 1.00435) | 56.9039 ± 1.05839 (W 0.0784983) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.154 ± 0.00817887 (W 0.00189075) | 1.83974 ± 0.00993724 (W 0.00302682) | - | 🔵 faer-fork 1.59× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.78202 ± 0.036809 (W 0.0106786) | 9.80222 ± 0.0318128 (W 0.0133908) | - | 🔵 faer-fork 1.45× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 25.7982 ± 0.0670737 (W 0.051546) | 40.2708 ± 0.0397776 (W 0.098604) | - | 🔵 faer-fork 1.56× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-mid, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/n128/b1` | 0.244847 ± 0.00108319 (W 0.00179445) | 0.602764 ± 0.00775873 (W 0.00470265) | - | 🔵 faer-fork 2.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n256/b1` | 0.967472 ± 0.00435198 (W 0.0024519) | 1.94655 ± 0.00672077 (W 0.0106376) | - | 🔵 faer-fork 2.01× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/n512/b1` | 3.62372 ± 0.0103361 (W 0.00401156) | 6.47695 ± 0.0649416 (W 0.0365326) | - | 🔵 faer-fork 1.79× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n128/b1` | 2.16527 ± 0.00949787 (W 0.00265897) | 2.50012 ± 0.00608838 (W 0.00287011) | - | 🔵 faer-fork 1.15× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n256/b1` | 10.8959 ± 0.0186963 (W 0.00873731) | 12.8791 ± 0.0201962 (W 0.0225974) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/n512/b1` | 37.9614 ± 0.133265 (W 0.0806604) | 51.7206 ± 0.168093 (W 0.283941) | - | 🔵 faer-fork 1.36× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n128/b1` | 1.14999 ± 0.00239469 (W 0.00262362) | 1.8391 ± 0.00210505 (W 0.00282343) | - | 🔵 faer-fork 1.60× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n256/b1` | 6.84126 ± 0.00918149 (W 0.0146155) | 9.86284 ± 0.0114599 (W 0.0146825) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/n512/b1` | 23.0738 ± 0.0688736 (W 0.0267599) | 37.974 ± 0.40484 (W 0.0631624) | - | 🔵 faer-fork 1.65× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/128`, `qr_factor/256`, `qr_factor/512`, `svd_thin/128`, `svd_thin/256`, `svd_thin/512`, `svd_values/128`, `svd_values/256`, `svd_values/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.926917 ± 0.0150537 (W 0.00153309) | 1.86119 ± 0.00757911 (W 0.00987674) | 0.904826 ± 0.00179048 (W 0.00223743) | 🔵 faer-fork 2.01× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 31.8225 ± 0.41772 (W 0.112652) | 78.0585 ± 0.353703 (W 0.061022) | 35.497 ± 0.247743 (W 0.0662256) | 🔵 faer-fork 2.45× faster than `faer-upstream` | 🔵 faer-fork 1.12× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.29053 ± 0.00379269 (W 0.00414204) | 2.50457 ± 0.00758906 (W 0.00485157) | 3.05027 ± 0.00479471 (W 0.00377506) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.33× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 85.7147 ± 0.280768 (W 0.0658915) | 88.7357 ± 0.153705 (W 0.114466) | 120.583 ± 4.6578 (W 0.424507) | · | 🔵 faer-fork 1.41× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.03199 ± 0.0151852 (W 0.00442865) | 1.48989 ± 0.00551069 (W 0.00429867) | 1.38777 ± 0.00381287 (W 0.00302386) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔵 faer-fork 1.34× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 38.3902 ± 0.0932977 (W 0.0495186) | 44.8328 ± 0.0715043 (W 0.199423) | 47.3468 ± 3.38207 (W 0.0857924) | 🔵 faer-fork 1.17× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.705869 ± 0.0295225 (W 0.00944088) | 3.15717 ± 0.125843 (W 0.101583) | 0.461241 ± 0.00520531 (W 0.00619078) | 🔵 faer-fork 4.47× faster than `faer-upstream` | 🔴 faer-fork 1.53× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/4096x256/b1` | 18.1627 ± 0.471675 (W 0.201967) | 74.0543 ± 0.223711 (W 0.350637) | 12.6629 ± 0.0669258 (W 0.0511027) | 🔵 faer-fork 4.08× faster than `faer-upstream` | 🔴 faer-fork 1.43× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 1.74217 ± 0.00284 (W 0.00600208) | 2.15083 ± 0.0135052 (W 0.00468218) | 1.89642 ± 0.0115848 (W 0.00908785) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 42.2616 ± 1.42161 (W 0.124931) | 47.7471 ± 0.145815 (W 0.368961) | 48.6604 ± 0.157794 (W 0.0857542) | 🔵 faer-fork 1.13× faster than `faer-upstream` | 🔵 faer-fork 1.15× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 0.850816 ± 0.00560993 (W 0.00397558) | 1.54543 ± 0.00383523 (W 0.00522348) | 0.943803 ± 0.00339417 (W 0.00437716) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 25.1472 ± 0.0281364 (W 0.0284767) | 32.7888 ± 0.0286491 (W 0.0417682) | 22.5509 ± 2.9775 (W 0.0760266) | 🔵 faer-fork 1.30× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.75501 ± 0.0156406 (W 0.00360339) | 3.02321 ± 0.125181 (W 0.0934891) | 0.321359 ± 0.00111357 (W 0.00173779) | 🔵 faer-fork 4.00× faster than `faer-upstream` | 🔴 faer-fork 2.35× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 16.0175 ± 0.150124 (W 0.0734214) | 71.5427 ± 0.072729 (W 0.151113) | 7.226 ± 0.0293197 (W 0.0343631) | 🔵 faer-fork 4.47× faster than `faer-upstream` | 🔴 faer-fork 2.22× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 1.74646 ± 0.00451126 (W 0.00433307) | 2.236 ± 0.0209486 (W 0.00785021) | 1.67371 ± 0.00447812 (W 0.00265115) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · |  |
| `svd_thin/4096x256/b1` | 38.7535 ± 1.20568 (W 2.44086) | 46.3979 ± 0.304901 (W 0.244449) | 36.5298 ± 1.18767 (W 0.10367) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 0.861389 ± 0.00260944 (W 0.00485952) | 1.62805 ± 0.00695363 (W 0.00495784) | 0.811435 ± 0.00236999 (W 0.00257361) | 🔵 faer-fork 1.89× faster than `faer-upstream` | 🔴 faer-fork 1.06× slower than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 23.3871 ± 0.129891 (W 0.14877) | 33.6758 ± 0.152893 (W 0.10442) | 16.6573 ± 0.174933 (W 0.0449737) | 🔵 faer-fork 1.44× faster than `faer-upstream` | 🔴 faer-fork 1.40× slower than `lapack-mkl` |  |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.651869 ± 0.0120453 (W 0.00215924) | 0.790488 ± 0.00238821 (W 0.00197955) | 0.764627 ± 0.00399226 (W 0.00245651) | 🔵 faer-fork 1.21× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 24.4403 ± 0.0919244 (W 0.0268378) | 25.6316 ± 0.0487571 (W 0.408416) | 28.8746 ± 0.242356 (W 0.0259893) | · | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.23404 ± 0.00511428 (W 0.00505096) | 2.44953 ± 0.00313371 (W 0.00321752) | 2.81643 ± 0.000762238 (W 0.0047848) | 🔵 faer-fork 1.10× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 80.3787 ± 0.247417 (W 0.396766) | 83.3456 ± 0.23566 (W 0.0708345) | 109.49 ± 0.267212 (W 0.28767) | · | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 0.953877 ± 0.00252798 (W 0.00256811) | 1.40303 ± 0.00413665 (W 0.00375911) | 1.23864 ± 0.00301811 (W 0.00458695) | 🔵 faer-fork 1.47× faster than `faer-upstream` | 🔵 faer-fork 1.30× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 32.4773 ± 0.137656 (W 0.0258426) | 39.074 ± 0.0924257 (W 0.0429042) | 40.2548 ± 0.10429 (W 0.0483525) | 🔵 faer-fork 1.20× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.466771 ± 0.00230161 (W 0.00202874) | 0.830487 ± 0.00141728 (W 0.00367284) | 0.41807 ± 0.00242139 (W 0.00861182) | 🔵 faer-fork 1.78× faster than `faer-upstream` | 🔴 faer-fork 1.12× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 11.2532 ± 0.0893937 (W 0.0127272) | 15.1499 ± 0.265812 (W 0.021709) | 11.2265 ± 0.0292101 (W 0.113441) | 🔵 faer-fork 1.35× faster than `faer-upstream` | · |  |
| `svd_thin/1024x64/b1` | 1.68405 ± 0.00358042 (W 0.00423688) | 2.09913 ± 0.00288509 (W 0.00543411) | 1.83397 ± 0.00917045 (W 0.0074634) | 🔵 faer-fork 1.25× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 37.0789 ± 1.23126 (W 0.0968384) | 42.1409 ± 0.10528 (W 0.0564174) | 45.6184 ± 0.23676 (W 0.0948465) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.23× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 0.772301 ± 0.00174622 (W 0.00242864) | 1.45118 ± 0.00235909 (W 0.00569414) | 0.909287 ± 0.00759031 (W 0.00522669) | 🔵 faer-fork 1.88× faster than `faer-upstream` | 🔵 faer-fork 1.18× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 19.1204 ± 0.0304993 (W 0.0245144) | 26.9593 ± 0.0266811 (W 0.0386762) | 20.8393 ± 0.201557 (W 0.0910881) | 🔵 faer-fork 1.41× faster than `faer-upstream` | 🔵 faer-fork 1.09× faster than `lapack-mkl` |  |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.477612 ± 0.00271365 (W 0.0029171) | 0.917393 ± 0.00746047 (W 0.00333043) | 0.303706 ± 0.000628142 (W 0.00240107) | 🔵 faer-fork 1.92× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 9.45955 ± 0.104358 (W 0.120086) | 16.3245 ± 0.110399 (W 0.0627834) | 6.54876 ± 0.0317139 (W 0.0330473) | 🔵 faer-fork 1.73× faster than `faer-upstream` | 🔴 faer-fork 1.44× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 1.7019 ± 0.00936054 (W 0.00273373) | 2.18635 ± 0.0131939 (W 0.00602824) | 1.63932 ± 0.00620218 (W 0.00418318) | 🔵 faer-fork 1.28× faster than `faer-upstream` | · |  |
| `svd_thin/4096x256/b1` | 33.0992 ± 1.27921 (W 2.65105) | 41.2767 ± 1.39767 (W 2.58974) | 34.4974 ± 0.117012 (W 0.0754179) | 🔵 faer-fork 1.25× faster than `faer-upstream` | · | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 0.786108 ± 0.00146134 (W 0.00163159) | 1.53743 ± 0.00637913 (W 0.00754483) | 0.791888 ± 0.00221644 (W 0.00253699) | 🔵 faer-fork 1.96× faster than `faer-upstream` | · |  |
| `svd_values/4096x256/b1` | 17.4151 ± 0.058063 (W 0.109457) | 27.8961 ± 0.0647638 (W 0.0763696) | 15.9164 ± 0.166256 (W 0.0496264) | 🔵 faer-fork 1.60× faster than `faer-upstream` | 🔴 faer-fork 1.09× slower than `lapack-mkl` |  |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 2.30448 ± 0.0196038 (W 0.00411649) | 4.02261 ± 0.0450377 (W 0.0168777) | 2.38362 ± 0.00567312 (W 0.004432) | 🔵 faer-fork 1.75× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 97.0063 ± 0.694128 (W 0.171245) | 176.151 ± 0.540992 (W 0.35589) | 107.554 ± 2.08104 (W 0.47435) | 🔵 faer-fork 1.82× faster than `faer-upstream` | 🔵 faer-fork 1.11× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.70273 ± 0.0184104 (W 0.00277225) | 5.99065 ± 0.0266374 (W 0.00383785) | 8.75322 ± 0.0171446 (W 0.0102992) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 277.076 ± 0.19131 (W 1.11614) | 281.899 ± 0.367264 (W 0.597824) | 379.871 ± 0.211381 (W 0.693778) | · | 🔵 faer-fork 1.37× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 2.53305 ± 0.00665182 (W 0.00298338) | 3.08408 ± 0.0168696 (W 0.00389559) | 3.78675 ± 0.0146555 (W 0.00470059) | 🔵 faer-fork 1.22× faster than `faer-upstream` | 🔵 faer-fork 1.49× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 116.325 ± 1.14482 (W 0.364752) | 123.424 ± 1.11093 (W 0.153917) | 144.487 ± 6.81674 (W 0.347768) | 🔵 faer-fork 1.06× faster than `faer-upstream` | 🔵 faer-fork 1.24× faster than `lapack-mkl` | `!` between-start range over 5% |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.40971 ± 0.00457101 (W 0.00342709) | 3.97211 ± 0.0834074 (W 0.0526288) | 1.3897 ± 0.00308255 (W 0.00319923) | 🔵 faer-fork 2.82× faster than `faer-upstream` | · |  |
| `qr_factor/4096x256/b1` | 44.3247 ± 0.0739912 (W 0.0893225) | 129.379 ± 0.591081 (W 0.577958) | 33.8818 ± 0.081006 (W 0.0872083) | 🔵 faer-fork 2.92× faster than `faer-upstream` | 🔴 faer-fork 1.31× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.18085 ± 0.00338637 (W 0.00952675) | 3.68299 ± 0.00509849 (W 0.00406738) | 5.48468 ± 0.0227728 (W 0.0272696) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.72× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 109.936 ± 0.241138 (W 0.175638) | 118.922 ± 0.114635 (W 0.305784) | 138.785 ± 4.12178 (W 0.331858) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.26× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.67585 ± 0.000279015 (W 0.0031455) | 2.44173 ± 0.00154394 (W 0.00591291) | 2.81257 ± 0.00747987 (W 0.00304801) | 🔵 faer-fork 1.46× faster than `faer-upstream` | 🔵 faer-fork 1.68× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 60.8373 ± 0.698422 (W 0.0927221) | 72.4761 ± 0.192675 (W 0.161925) | 59.6431 ± 5.12327 (W 0.315028) | 🔵 faer-fork 1.19× faster than `faer-upstream` | · | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.36162 ± 0.00716921 (W 0.00903029) | 3.82202 ± 0.158415 (W 0.0902243) | 0.869323 ± 0.00263256 (W 0.00398963) | 🔵 faer-fork 2.81× faster than `faer-upstream` | 🔴 faer-fork 1.57× slower than `lapack-mkl` | `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 37.0622 ± 0.636368 (W 0.46357) | 123.958 ± 1.26212 (W 0.568914) | 19.5776 ± 0.0161556 (W 0.0799225) | 🔵 faer-fork 3.34× faster than `faer-upstream` | 🔴 faer-fork 1.89× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.92948 ± 0.0164232 (W 0.035457) | 3.68158 ± 0.0374212 (W 0.0220348) | 4.425 ± 0.0158262 (W 0.00800523) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.51× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 87.0824 ± 0.982052 (W 1.4955) | 107.02 ± 0.645033 (W 1.39852) | 83.7018 ± 0.549396 (W 0.370718) | 🔵 faer-fork 1.23× faster than `faer-upstream` | · |  |
| `svd_values/1024x64/b1` | 1.62349 ± 0.00850953 (W 0.00816101) | 2.48805 ± 0.0123005 (W 0.00872627) | 2.2868 ± 0.00736013 (W 0.00474769) | 🔵 faer-fork 1.53× faster than `faer-upstream` | 🔵 faer-fork 1.41× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 53.1013 ± 0.137006 (W 0.473091) | 70.422 ± 1.03341 (W 0.595548) | 41.8011 ± 4.24723 (W 0.188948) | 🔵 faer-fork 1.33× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.95818 ± 0.0510969 (W 0.0021389) | 2.22873 ± 0.0305731 (W 0.00377283) | 2.23779 ± 0.00888966 (W 0.00630002) | 🔵 faer-fork 1.14× faster than `faer-upstream` | 🔵 faer-fork 1.14× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 87.2643 ± 0.221541 (W 0.0652108) | 90.1391 ± 0.107266 (W 0.0467333) | 104.974 ± 2.20753 (W 0.253176) | · | 🔵 faer-fork 1.20× faster than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 5.60298 ± 0.0167781 (W 0.0054207) | 5.88992 ± 0.0232581 (W 0.00268996) | 8.56738 ± 0.0290577 (W 0.00786805) | · | 🔵 faer-fork 1.53× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 264.923 ± 0.21594 (W 0.483155) | 269.843 ± 0.190359 (W 0.475873) | 358.876 ± 10.408 (W 0.754201) | · | 🔵 faer-fork 1.35× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 2.41558 ± 0.00465705 (W 0.0057941) | 2.95967 ± 0.0165031 (W 0.00278821) | 3.66392 ± 0.00663222 (W 0.00547926) | 🔵 faer-fork 1.23× faster than `faer-upstream` | 🔵 faer-fork 1.52× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 102.55 ± 0.134235 (W 0.0508126) | 111.23 ± 0.116592 (W 0.0461667) | 139.937 ± 3.43276 (W 0.44057) | 🔵 faer-fork 1.08× faster than `faer-upstream` | 🔵 faer-fork 1.36× faster than `lapack-mkl` |  |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.12442 ± 0.0118394 (W 0.00324504) | 1.59267 ± 0.0155487 (W 0.00438488) | 1.36074 ± 0.00923565 (W 0.00238455) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔵 faer-fork 1.21× faster than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 33.9239 ± 0.249389 (W 0.0339671) | 42.1302 ± 0.493892 (W 0.0490739) | 31.5951 ± 0.347699 (W 0.186946) | 🔵 faer-fork 1.24× faster than `faer-upstream` | 🔴 faer-fork 1.07× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 3.07343 ± 0.00797889 (W 0.00535413) | 3.57307 ± 0.0101505 (W 0.006972) | 5.42237 ± 0.0256433 (W 0.00586882) | 🔵 faer-fork 1.16× faster than `faer-upstream` | 🔵 faer-fork 1.76× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 97.763 ± 0.0997782 (W 0.105793) | 106.85 ± 0.0947703 (W 0.136242) | 139.904 ± 6.0396 (W 0.335258) | 🔵 faer-fork 1.09× faster than `faer-upstream` | 🔵 faer-fork 1.43× faster than `lapack-mkl` | `!` between-start range over 5% |
| `svd_values/1024x64/b1` | 1.59621 ± 0.00428079 (W 0.00515605) | 2.3568 ± 0.0048312 (W 0.00730217) | 2.78733 ± 0.00703598 (W 0.00407668) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔵 faer-fork 1.75× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 48.6636 ± 0.142303 (W 0.0529583) | 60.3485 ± 0.186621 (W 0.0462708) | 49.8679 ± 1.22092 (W 0.198734) | 🔵 faer-fork 1.24× faster than `faer-upstream` | · |  |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.07498 ± 0.0145933 (W 0.00899745) | 1.62583 ± 0.025111 (W 0.00763654) | 0.860947 ± 0.00500713 (W 0.00209987) | 🔵 faer-fork 1.51× faster than `faer-upstream` | 🔴 faer-fork 1.25× slower than `lapack-mkl` |  |
| `qr_factor/4096x256/b1` | 26.5425 ± 0.398437 (W 0.366239) | 39.4107 ± 0.541073 (W 0.382755) | 17.9477 ± 0.261973 (W 0.0496494) | 🔵 faer-fork 1.48× faster than `faer-upstream` | 🔴 faer-fork 1.48× slower than `lapack-mkl` |  |
| `svd_thin/1024x64/b1` | 2.84277 ± 0.0242535 (W 0.0266708) | 3.59454 ± 0.0128355 (W 0.0238953) | 4.38793 ± 0.0081915 (W 0.00890314) | 🔵 faer-fork 1.26× faster than `faer-upstream` | 🔵 faer-fork 1.54× faster than `lapack-mkl` |  |
| `svd_thin/4096x256/b1` | 74.7761 ± 0.598369 (W 0.778992) | 95.0428 ± 0.699514 (W 0.540631) | 87.4538 ± 0.893752 (W 0.400892) | 🔵 faer-fork 1.27× faster than `faer-upstream` | 🔵 faer-fork 1.17× faster than `lapack-mkl` |  |
| `svd_values/1024x64/b1` | 1.53305 ± 0.00711311 (W 0.00722613) | 2.40009 ± 0.0128971 (W 0.00884784) | 2.29817 ± 0.00228687 (W 0.00395165) | 🔵 faer-fork 1.57× faster than `faer-upstream` | 🔵 faer-fork 1.50× faster than `lapack-mkl` |  |
| `svd_values/4096x256/b1` | 41.097 ± 0.197783 (W 0.325455) | 58.3646 ± 0.106469 (W 0.413522) | 32.42 ± 0.374115 (W 0.105129) | 🔵 faer-fork 1.42× faster than `faer-upstream` | 🔴 faer-fork 1.27× slower than `lapack-mkl` |  |

## linalg-tall, f32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.68521 ± 0.00585855 (W 0.00324304) | 1.52273 ± 0.00317896 (W 0.00583586) | - | 🔵 faer-fork 2.22× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 18.4153 ± 0.169863 (W 0.0780642) | 51.3143 ± 0.223667 (W 0.0676729) | - | 🔵 faer-fork 2.79× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.35363 ± 0.00348245 (W 0.00208341) | 1.59176 ± 0.00332635 (W 0.00363346) | - | 🔵 faer-fork 1.18× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 46.4113 ± 0.0939797 (W 0.0361655) | 48.897 ± 0.0679911 (W 0.0401808) | - | 🔵 faer-fork 1.05× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.757532 ± 0.00278865 (W 0.00481354) | 1.14002 ± 0.0060388 (W 0.0037278) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 22.7407 ± 0.0281407 (W 0.0250309) | 27.31 ± 0.0259657 (W 0.0239453) | - | 🔵 faer-fork 1.20× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.547764 ± 0.00154076 (W 0.0168563) | 2.14403 ± 0.0271536 (W 0.0254835) | - | 🔵 faer-fork 3.91× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 11.2286 ± 0.138713 (W 0.131996) | 51.8179 ± 0.208751 (W 0.26916) | - | 🔵 faer-fork 4.61× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.08405 ± 0.0069282 (W 0.00238239) | 1.50571 ± 0.00433208 (W 0.0044552) | - | 🔵 faer-fork 1.39× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 24.148 ± 0.0104273 (W 0.105127) | 28.7076 ± 0.0302708 (W 0.0819825) | - | 🔵 faer-fork 1.19× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.655813 ± 0.00272796 (W 0.00758336) | 1.24975 ± 0.00467487 (W 0.00572322) | - | 🔵 faer-fork 1.91× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 15.8358 ± 0.0380875 (W 0.0278839) | 21.6992 ± 0.0411535 (W 0.027094) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.588749 ± 0.00520132 (W 0.00311557) | 2.20226 ± 0.023023 (W 0.0200351) | - | 🔵 faer-fork 3.74× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 10.6118 ± 0.156851 (W 0.265853) | 51.5595 ± 0.191388 (W 0.172003) | - | 🔵 faer-fork 4.86× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.10007 ± 0.0105965 (W 0.0032798) | 1.60881 ± 0.0153671 (W 0.00562717) | - | 🔵 faer-fork 1.46× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.9193 ± 0.0427233 (W 0.183195) | 29.5301 ± 0.103919 (W 0.104343) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.67542 ± 0.00113264 (W 0.00354128) | 1.33411 ± 0.0178284 (W 0.00664864) | - | 🔵 faer-fork 1.98× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 15.2654 ± 0.0715585 (W 0.0518439) | 22.9011 ± 0.130898 (W 0.0399033) | - | 🔵 faer-fork 1.50× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.436434 ± 0.0101407 (W 0.00324523) | 0.630077 ± 0.00577635 (W 0.00165609) | - | 🔵 faer-fork 1.44× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 13.9019 ± 0.0335429 (W 0.0133591) | 15.7697 ± 0.0218483 (W 0.00875585) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.35681 ± 0.00211419 (W 0.00203999) | 1.59048 ± 0.00250657 (W 0.00276455) | - | 🔵 faer-fork 1.17× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 43.7178 ± 0.0673593 (W 0.0467193) | 46.2358 ± 0.0495205 (W 0.0285986) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.71279 ± 0.00149547 (W 0.00205405) | 1.0999 ± 0.00140205 (W 0.00171786) | - | 🔵 faer-fork 1.54× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 19.3689 ± 0.0179362 (W 0.0114161) | 24.1572 ± 0.026539 (W 0.0213202) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.325727 ± 0.00558078 (W 0.00216415) | 0.740011 ± 0.000402194 (W 0.00314819) | - | 🔵 faer-fork 2.27× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 6.50545 ± 0.0448995 (W 0.0114266) | 10.9379 ± 0.12287 (W 0.0182824) | - | 🔵 faer-fork 1.68× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.08658 ± 0.00171925 (W 0.00262594) | 1.5165 ± 0.00560237 (W 0.00342465) | - | 🔵 faer-fork 1.40× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 21.2276 ± 0.0199169 (W 0.0739831) | 25.7434 ± 0.0241444 (W 0.0585709) | - | 🔵 faer-fork 1.21× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.613506 ± 0.00117679 (W 0.00276036) | 1.21352 ± 0.000910705 (W 0.00371865) | - | 🔵 faer-fork 1.98× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 12.2613 ± 0.0206738 (W 0.0278204) | 18.2595 ± 0.0717616 (W 0.0190845) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, f32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.341488 ± 0.00416646 (W 0.00167019) | 0.831463 ± 0.0102876 (W 0.00306231) | - | 🔵 faer-fork 2.43× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 5.83366 ± 0.0335482 (W 0.0274736) | 11.9067 ± 0.189337 (W 0.0247086) | - | 🔵 faer-fork 2.04× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.08936 ± 0.00989639 (W 0.00273731) | 1.62153 ± 0.0165195 (W 0.00456035) | - | 🔵 faer-fork 1.49× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 18.8574 ± 0.0899188 (W 0.0859151) | 26.5456 ± 0.065802 (W 0.0888093) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 0.629895 ± 0.00286934 (W 0.00337489) | 1.29628 ± 0.0107536 (W 0.00541357) | - | 🔵 faer-fork 2.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 11.6701 ± 0.0264429 (W 0.0413684) | 19.4796 ± 0.096269 (W 0.0675497) | - | 🔵 faer-fork 1.67× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.412 ± 0.000108302 (W 0.00310247) | 3.23238 ± 0.00244638 (W 0.00316852) | - | 🔵 faer-fork 2.29× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 53.2352 ± 0.37908 (W 0.0354204) | 97.7057 ± 0.290196 (W 0.0995431) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 3.07061 ± 0.00417216 (W 0.00303581) | 3.39138 ± 0.00633682 (W 0.00383898) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 142.601 ± 0.235846 (W 0.160911) | 146.372 ± 0.248706 (W 0.101431) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.53899 ± 0.00665238 (W 0.00404078) | 2.00699 ± 0.0033489 (W 0.0056987) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 61.1699 ± 0.174339 (W 0.0401561) | 67.0954 ± 0.156184 (W 0.0197389) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.962458 ± 0.00318236 (W 0.00252426) | 3.70401 ± 0.140077 (W 0.133056) | - | 🔵 faer-fork 3.85× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 26.1519 ± 0.0846694 (W 0.0866955) | 77.4115 ± 0.1971 (W 0.231655) | - | 🔵 faer-fork 2.96× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.81498 ± 0.00270605 (W 0.00491098) | 2.32443 ± 0.00673302 (W 0.00486908) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 58.2845 ± 0.12606 (W 0.113534) | 65.5167 ± 0.231574 (W 0.122502) | - | 🔵 faer-fork 1.12× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.10026 ± 0.00935259 (W 0.00418372) | 1.78508 ± 0.00349384 (W 0.00753267) | - | 🔵 faer-fork 1.62× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 33.5739 ± 0.0574504 (W 0.0290437) | 41.9192 ± 0.0977832 (W 0.0238543) | - | 🔵 faer-fork 1.25× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.952887 ± 0.00728487 (W 0.00316141) | 3.1671 ± 0.292213 (W 0.0960348) | - | 🔵 faer-fork 3.32× faster than `faer-upstream` | - | `*` one row has no measurement here; `!` between-start range over 5% |
| `qr_factor/4096x256/b1` | 22.6627 ± 0.174664 (W 0.201887) | 75.0096 ± 0.747731 (W 0.558971) | - | 🔵 faer-fork 3.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.74876 ± 0.00578789 (W 0.0105845) | 2.392 ± 0.00726514 (W 0.0076601) | - | 🔵 faer-fork 1.37× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 47.3501 ± 0.0714376 (W 0.647688) | 60.6383 ± 0.976683 (W 0.459963) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.08918 ± 0.00344364 (W 0.00678291) | 1.85586 ± 0.0137834 (W 0.00719047) | - | 🔵 faer-fork 1.70× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 29.9738 ± 0.212776 (W 0.129304) | 42.1388 ± 0.258427 (W 0.236919) | - | 🔵 faer-fork 1.41× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 1.14073 ± 0.0113315 (W 0.00277225) | 1.41759 ± 0.0153458 (W 0.00288702) | - | 🔵 faer-fork 1.24× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 47.1422 ± 0.537521 (W 0.0354684) | 49.8167 ± 0.560803 (W 0.0201588) | - | 🔵 faer-fork 1.06× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 3.03742 ± 0.00337232 (W 0.00277501) | 3.35124 ± 0.00455419 (W 0.00236044) | - | 🔵 faer-fork 1.10× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 137.398 ± 0.20111 (W 0.066955) | 140.913 ± 0.118439 (W 0.10411) | - | · | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.46213 ± 0.00199833 (W 0.00277214) | 1.91426 ± 0.000898568 (W 0.00346607) | - | 🔵 faer-fork 1.31× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 55.5662 ± 0.126038 (W 0.019629) | 61.5549 ± 0.126506 (W 0.0332922) | - | 🔵 faer-fork 1.11× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.685158 ± 0.000175015 (W 0.0028264) | 1.17403 ± 0.00691241 (W 0.00504883) | - | 🔵 faer-fork 1.71× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 19.1525 ± 0.0210472 (W 0.0172807) | 25.921 ± 0.0225015 (W 0.0208451) | - | 🔵 faer-fork 1.35× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.78715 ± 0.00263755 (W 0.00566892) | 2.29305 ± 0.0055006 (W 0.0071442) | - | 🔵 faer-fork 1.28× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 52.8926 ± 0.0348387 (W 0.160965) | 59.9703 ± 0.0738196 (W 0.0914246) | - | 🔵 faer-fork 1.13× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.037 ± 0.00695474 (W 0.00335813) | 1.70285 ± 0.000305368 (W 0.00480564) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 27.8869 ± 0.0151432 (W 0.0396398) | 36.2402 ± 0.0516716 (W 0.0709037) | - | 🔵 faer-fork 1.30× faster than `faer-upstream` | - | `*` one row has no measurement here |

## linalg-tall, c32, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `qr_factor/1024x64/b1` | 0.688906 ± 0.00647288 (W 0.00239149) | 1.26673 ± 0.0192575 (W 0.0054766) | - | 🔵 faer-fork 1.84× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `qr_factor/4096x256/b1` | 15.5144 ± 0.0698597 (W 0.247014) | 25.4629 ± 0.300141 (W 0.155137) | - | 🔵 faer-fork 1.64× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/1024x64/b1` | 1.71206 ± 0.00635059 (W 0.00933846) | 2.35951 ± 0.0132206 (W 0.00793089) | - | 🔵 faer-fork 1.38× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_thin/4096x256/b1` | 41.4389 ± 0.273424 (W 0.405801) | 55.1545 ± 1.05759 (W 1.14209) | - | 🔵 faer-fork 1.33× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/1024x64/b1` | 1.03066 ± 0.00436404 (W 0.00312586) | 1.77587 ± 0.0129195 (W 0.0042403) | - | 🔵 faer-fork 1.72× faster than `faer-upstream` | - | `*` one row has no measurement here |
| `svd_values/4096x256/b1` | 24.3012 ± 0.0321651 (W 0.112236) | 36.0603 ± 0.25186 (W 0.166698) | - | 🔵 faer-fork 1.48× faster than `faer-upstream` | - | `*` one row has no measurement here |

Not applicable to this population's shapes and reported as skipped: `qr_factor/1024x64`, `qr_factor/4096x256`, `svd_thin/1024x64`, `svd_thin/4096x256`, `svd_values/1024x64`, `svd_values/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
