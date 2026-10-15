# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `198730904711fe841e87c8f027f8c953419d7dad`
- toolkit commit: `916dace82589f9066f824c5cbfaa311140df2fed`
- measured binary SHA-256: `cce1442034a105ef6ad8c59d9c85964c7cdad9b50c515a89c28f6894d3c34751`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-15T08:16:14.646371+00:00`
- timing policy: v2, median of 30 reps, priming 3000 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 1 attempts
- command: `python3 data/probes/20261015-v2-representative/run.py (see metadata.json commands)`
- raw data: `data/probes/20261015-v2-representative/mkl/8t/`

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
- CPU sets: 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 30 chronological calls; 3 complete process sets are recorded.

## qr, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `qr/4096x256/b1` | 22.6687 ± 2.48589 (W 0.334885) | 27.4482 ± 2.11932 (W 0.664006) | 13.8156 ± 0.112913 (W 0.0772011) |
| `qr_factor/4096x256/b1` | 58.3188 ± 0.3641 (W 0.336207) | 65.3524 ± 0.408465 (W 3.77728) | 4.71454 ± 0.00902942 (W 0.126788) |

## qr, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `qr/4096x256/b1` | 14.13 ± 0.0234734 (W 0.238366) | 25.5107 ± 0.222758 (W 2.13033) | 12.2696 ± 0.0376354 (W 0.0432257) |
| `qr_factor/4096x256/b1` | 7.37795 ± 0.0579031 (W 0.0507132) | 16.632 ± 0.0256344 (W 2.53531) | 3.99486 ± 0.0048654 (W 0.0245495) |

## decompose, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.02856 ± 0.217877 (W 0.0370955) | 0.995036 ± 0.218517 (W 0.0285935) | 0.880556 ± 0.00966698 (W 0.00708803) |
| `eigh/n512/b1` | 16.0238 ± 0.30182 (W 0.433471) | 16.6238 ± 0.407209 (W 0.49063) | 9.36703 ± 0.734504 (W 0.0340978) |
| `svd_values/n512/b1` | 30.7302 ± 0.0764203 (W 0.490715) | 30.4021 ± 0.148168 (W 0.434585) | 13.5588 ± 0.0530276 (W 0.01767) |

## decompose, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 0.725875 ± 0.00115124 (W 0.0263418) | 0.720218 ± 0.00581381 (W 0.0195147) | 0.615445 ± 0.0355543 (W 0.0150301) |
| `eigh/n512/b1` | 15.9762 ± 0.0655486 (W 0.606033) | 16.2007 ± 0.164304 (W 0.489766) | 9.0448 ± 0.0113436 (W 0.267229) |
| `svd_values/n512/b1` | 30.061 ± 0.0788462 (W 0.450509) | 29.9181 ± 0.304863 (W 0.446814) | 13.587 ± 0.0420786 (W 0.0239532) |

## householder, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 5.21899 ± 0.0618684 (W 0.611565) | 4.37183 ± 0.103079 (W 0.665769) | - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.25269 ± 0.208007 (W 0.520885) | 4.43065 ± 0.0944108 (W 0.771487) | - |

Not applicable to these shapes and reported as skipped: `householder_apply/4096x256`.

## householder, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 5.73046 ± 0.610951 (W 0.413375) | 5.34807 ± 0.389314 (W 0.388608) | - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.63841 ± 0.64344 (W 0.480575) | 5.11919 ± 0.0230208 (W 0.431491) | - |

Not applicable to these shapes and reported as skipped: `householder_apply/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
