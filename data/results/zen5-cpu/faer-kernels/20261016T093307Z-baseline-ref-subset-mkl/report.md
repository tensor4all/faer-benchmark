# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `a845b77d8ed85e6a23e674743f4825b0513b5882`
- toolkit commit: `5e2b35c2197117414ca97372735938a1a3d958ac`
- measured binary SHA-256: `7b902aa706b7a981a7248eac2c7b479cb69b52d9832fad2bf0e0112c9f98aa98`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-16T09:36:42.802097Z`
- timing policy: v2, median of 5 reps, priming 250 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 8 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --regimes gemm-mid,linalg-mid --shapes 256,256x256x256 --dtypes f64 --families gemm,lu,cholesky,qr_factor --threads 1,4,8 --reps 5 --aa 3 --prime-ms 250 --label baseline-ref-subset-mkl --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261016T093307Z-baseline-ref-subset-mkl/`

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
Spread guide (computed from this run's own rows): per-engine between-start range median 1.81%, worst 44.79% among cells of 1 us or more (a sub-microsecond row is timer and scheduler jitter, not kernel time); 20 of 72 engine cells exceed 5% and carry `!`; median within-process relative SD 0.75%. A cell whose `±`, `!` or `p` is as large as the difference you are reading is not evidence of a regression.
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

## gemm-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07364 ± 0.00918336 (W 0.00276099) | 1.07606 ± 0.00546751 (W 0.00122424) | 1.21134 ± 0.012805 (W 0.00172339) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.309522 ± 0.000575485 (W 0.00454731) | 0.302097 ± 0.00341413 (W 0.00680595) | 0.344457 ± 0.00160192 (W 0.00211723) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.200787 ± 0.00796377 (W 0.0238149) | 0.209934 ± 0.0112658 (W 0.0327192) | 0.180869 ± 0.0023417 (W 0.000757538) | · | 🔴 fork 1.11× slower than `lapack-mkl` | `!` between-start range over 5% |

## gemm-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 1.07563 ± 0.00593819 (W 0.00122209) | 1.07436 ± 0.00652666 (W 0.00251681) | 1.2104 ± 0.00253403 (W 0.00256518) | · | 🔵 fork 1.13× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.30871 ± 0.00346163 (W 0.00451926) | 0.307648 ± 0.00503955 (W 0.00865193) | 0.343375 ± 0.000245724 (W 0.0018398) | · | 🔵 fork 1.11× faster than `lapack-mkl` |  |

## gemm-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `gemm/256x256x256/b1` | 0.240431 ± 0.0255321 (W 0.0359529) | 0.212229 ± 0.011783 (W 0.033093) | 0.181641 ± 0.00306787 (W 0.00193244) | 🔴 fork 1.13× slower than `faer-upstream` | 🔴 fork 1.32× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |

## linalg-mid, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.39457 ± 0.00282217 (W 0.00267476) | 0.380784 ± 0.00689715 (W 0.00198908) | 0.641465 ± 0.00376023 (W 0.00355095) | · | 🔵 fork 1.63× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 1.03164 ± 0.113565 (W 0.00225235) | 1.0353 ± 0.00333414 (W 0.00246666) | 0.968068 ± 0.00458227 (W 0.00231395) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 2.40894 ± 0.00785273 (W 0.00677124) | 2.86308 ± 0.00835182 (W 0.00701419) | 2.04458 ± 0.00539987 (W 0.0054125) | 🔵 fork 1.19× faster than `faer-upstream` | 🔴 fork 1.18× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.428925 ± 0.011077 (W 0.0270435) | 0.416732 ± 0.00994824 (W 0.0271684) | 0.405592 ± 0.00475939 (W 0.00482339) | · | 🔴 fork 1.06× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 1.04593 ± 0.122714 (W 0.0054895) | 1.18849 ± 0.00538667 (W 0.0289129) | 0.380355 ± 0.00263643 (W 0.00205801) | 🔵 fork 1.14× faster than `faer-upstream` | 🔴 fork 2.75× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 2.79692 ± 0.0358751 (W 0.0501946) | 5.68377 ± 0.0495986 (W 0.0419308) | 0.672673 ± 0.00191571 (W 0.00200087) | 🔵 fork 2.03× faster than `faer-upstream` | 🔴 fork 4.16× slower than `lapack-mkl` |  |

## linalg-mid, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.450446 ± 0.0185318 (W 0.0244214) | 0.466005 ± 0.00517281 (W 0.0304363) | 0.35688 ± 0.0017614 (W 0.00392279) | · | 🔴 fork 1.26× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 1.0521 ± 0.127479 (W 0.0087953) | 1.27226 ± 0.0118924 (W 0.0238422) | 0.345058 ± 0.00416585 (W 0.00335698) | 🔵 fork 1.21× faster than `faer-upstream` | 🔴 fork 3.05× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 2.83857 ± 0.0220474 (W 0.0321851) | 6.70533 ± 0.0918336 (W 0.0695337) | 0.57518 ± 0.0160667 (W 0.00299041) | 🔵 fork 2.36× faster than `faer-upstream` | 🔴 fork 4.94× slower than `lapack-mkl` | `!` between-start range over 5% |

## linalg-mid, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.323357 ± 0.000719951 (W 0.00230414) | 0.316294 ± 0.00438294 (W 0.00236191) | 0.460315 ± 0.00320741 (W 0.00246585) | · | 🔵 fork 1.42× faster than `lapack-mkl` |  |
| `lu/n256/b1` | 0.699283 ± 0.115465 (W 0.00178238) | 0.699824 ± 0.120224 (W 0.00474995) | 0.814699 ± 0.00186895 (W 0.00247003) | · | · | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.34991 ± 0.0015113 (W 0.00256111) | 1.3793 ± 0.00422225 (W 0.00558221) | 1.88954 ± 0.00397223 (W 0.00917036) | · | 🔵 fork 1.40× faster than `lapack-mkl` |  |

## linalg-mid, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.349306 ± 0.0185833 (W 0.0137251) | 0.365927 ± 0.000436521 (W 0.025243) | 0.239881 ± 0.00160081 (W 0.00268964) | · | 🔴 fork 1.46× slower than `lapack-mkl` | `!` between-start range over 5% |
| `lu/n256/b1` | 0.709452 ± 0.119047 (W 0.00343063) | 0.849935 ± 0.124294 (W 0.0183006) | 0.327484 ± 0.00270386 (W 0.00258856) | · | 🔴 fork 2.17× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.38101 ± 0.00839863 (W 0.0321781) | 3.09791 ± 0.0185273 (W 0.0469651) | 0.62839 ± 0.00273569 (W 0.00298395) | 🔵 fork 2.24× faster than `faer-upstream` | 🔴 fork 2.20× slower than `lapack-mkl` |  |

## linalg-mid, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) | vs `faer-upstream` | vs `lapack-mkl` | notes |
|---|---|---|---|---|---|---|
| `cholesky/n256/b1` | 0.385674 ± 0.0149976 (W 0.0195566) | 0.421 ± 0.0273557 (W 0.0199381) | 0.195547 ± 0.0487374 (W 0.00255969) | 🔵 fork 1.09× faster than `faer-upstream` | 🔴 fork 1.97× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `lu/n256/b1` | 0.713339 ± 0.119464 (W 0.00351546) | 0.923865 ± 0.122609 (W 0.0366019) | 0.315693 ± 0.00280491 (W 0.00361739) | 🔵 fork 1.30× faster than `faer-upstream` | 🔴 fork 2.26× slower than `lapack-mkl` | `!` between-start range over 5%; `p` position effect over 5% |
| `qr_factor/n256/b1` | 1.46522 ± 0.007283 (W 0.0155165) | 4.07662 ± 0.0861231 (W 0.0546303) | 0.539733 ± 0.0017943 (W 0.00302312) | 🔵 fork 2.78× faster than `faer-upstream` | 🔴 fork 2.71× slower than `lapack-mkl` |  |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
