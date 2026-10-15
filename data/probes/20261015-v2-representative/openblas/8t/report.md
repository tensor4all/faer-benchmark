# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `198730904711fe841e87c8f027f8c953419d7dad`
- toolkit commit: `916dace82589f9066f824c5cbfaa311140df2fed`
- measured binary SHA-256: `d59f5a802112d8fe331fa7d3b683b5c2093abba3c409d4733c4f0024d3eeb651`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-15T08:38:03.614314+00:00`
- timing policy: v2, median of 30 reps, priming 3000 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 1 attempts
- command: `python3 data/probes/20261015-v2-representative/run.py (see metadata.json commands)`
- raw data: `data/probes/20261015-v2-representative/openblas/8t/`

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
- CPU sets: 8T -> `4-11`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 30 chronological calls; 3 complete process sets are recorded.

## qr, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/4096x256/b1` | 21.2021 ± 1.86391 (W 0.262543) | 28.6253 ± 1.09634 (W 0.539967) | 39.5813 ± 1.69204 (W 0.607695) |
| `qr_factor/4096x256/b1` | 58.4417 ± 0.11907 (W 0.324062) | 64.9345 ± 0.16383 (W 0.431321) | 18.7156 ± 4.42146 (W 0.434955) |

## qr, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/4096x256/b1` | 17.7766 ± 0.0650422 (W 0.303854) | 22.6672 ± 0.148917 (W 0.444648) | 22.4677 ± 0.269994 (W 0.0934978) |
| `qr_factor/4096x256/b1` | 7.29136 ± 0.0385011 (W 0.0403465) | 16.3557 ± 0.0796655 (W 2.34131) | 11.1972 ± 0.029465 (W 0.172454) |

## decompose, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.00733 ± 0.227119 (W 0.185192) | 1.05007 ± 0.208469 (W 0.0285574) | 2.7292 ± 1.14512 (W 0.0232357) |
| `eigh/n512/b1` | 16.0762 ± 0.0631759 (W 0.438009) | 16.0525 ± 0.141806 (W 0.519665) | 15.3038 ± 0.117123 (W 0.0355039) |
| `svd_values/n512/b1` | 30.4381 ± 0.125347 (W 0.465748) | 30.4514 ± 0.115621 (W 0.569908) | 29.5787 ± 0.181586 (W 0.0205947) |

## decompose, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 0.720266 ± 0.00311542 (W 0.0305092) | 0.732021 ± 0.0048398 (W 0.0334877) | 0.740913 ± 0.00217944 (W 0.0037215) |
| `eigh/n512/b1` | 15.9136 ± 0.199628 (W 0.473685) | 15.8732 ± 0.325889 (W 0.470944) | 13.6347 ± 0.100468 (W 0.0470114) |
| `svd_values/n512/b1` | 29.9982 ± 0.0992091 (W 0.498679) | 29.9279 ± 0.189794 (W 0.443207) | 28.6472 ± 0.314482 (W 0.0314755) |

## householder, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 5.27972 ± 1.09257 (W 0.510068) | 4.35616 ± 0.756244 (W 0.509278) | - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 5.33274 ± 1.03154 (W 0.47171) | 4.40425 ± 0.709914 (W 0.689419) | - |

Not applicable to these shapes and reported as skipped: `householder_apply/4096x256`.

## householder, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/4096x256/b1 [block(basis=256,target=256)]` | 6.85987 ± 0.799098 (W 0.483139) | 5.47797 ± 0.520013 (W 0.505171) | - |
| `householder_apply/4096x256/b1 [sequence(basis=256,target=256)]` | 6.79075 ± 0.977373 (W 0.545887) | 5.32215 ± 0.535165 (W 0.501099) | - |

Not applicable to these shapes and reported as skipped: `householder_apply/4096x256`.

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
