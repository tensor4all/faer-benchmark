# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `std, rayon`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `201c4af0935cf3c68d94f04e20e6c91483f48892`
- toolkit commit: `5931b47ea6435c811730bc19c0ca25599b0952e6`
- measured binary SHA-256: `292be71f6cd130940a594dc4eee88a924fef3cbb44ac7564c28d63d0d5929de0`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-15T05:24:50.273230Z`
- timing policy: v2, median of 2 reps, priming 1 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 1 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout extern/t4a-faer --upstream extern/upstream-faer --vendor mkl --regimes gemm-small --families gemm --threads 1 --dtypes f64 --reps 2 --aa 3 --prime-ms 1 --label v2-smoke-mkl --no-publish`
- raw data: `data/results/zen5-cpu/faer-kernels/20261015T052425Z-v2-smoke-mkl/`

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
- CPU sets: 1T -> `4`

Every timed cell matches a successful verification census, including operation variants.
Each cell is median of process medians ± sample SD of those medians; W is the median
within-process sample SD. All values are milliseconds. These are descriptive spreads,
not confidence intervals. The between-process spread includes the rotating-order schedule.
Each process retains 2 chronological calls; 3 complete process sets are recorded.

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0003655 ± 1.23187e-05 (W 6.36396e-06) | 0.0003605 ± 4.75219e-06 (W 7.07107e-06) | 0.000841 ± 4.00656e-05 (W 2.82843e-05) |
| `gemm/32x32x32/b1` | 0.002104 ± 8.09835e-05 (W 0.000113137) | 0.001964 ± 0.00010251 (W 7.07107e-06) | 0.003847 ± 2.84312e-05 (W 2.82843e-05) |
| `gemm/4x4x4/b1` | 0.0001105 ± 3.17543e-06 (W 2.89914e-05) | 0.0001005 ± 5.92312e-06 (W 1.48492e-05) | 0.0009965 ± 4.79852e-05 (W 0.00101328) |
| `gemm/64x64x64/b1` | 0.014442 ± 2.51661e-05 (W 2.12132e-05) | 0.0144265 ± 9.92891e-06 (W 7.07107e-06) | 0.020588 ± 7.31386e-05 (W 2.19203e-05) |
| `gemm/8x8x8/b1` | 0.00013 ± 7.36546e-06 (W 1.48492e-05) | 0.000135 ± 1.52753e-05 (W 7.07107e-06) | 0.0002655 ± 9.75107e-06 (W 7.77817e-06) |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-mkl (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0003705 ± 9.75107e-06 (W 1.41421e-05) | 0.0003805 ± 1.04921e-05 (W 1.3435e-05) | 0.0008665 ± 8.12917e-06 (W 7.07107e-06) |
| `gemm/32x32x32/b1` | 0.001968 ± 1e-05 (W 2.12132e-05) | 0.001964 ± 6.06218e-06 (W 7.07107e-07) | 0.003892 ± 5.20416e-05 (W 5.65685e-05) |
| `gemm/4x4x4/b1` | 9.5e-05 ± 5e-06 (W 0) | 0.000105 ± 7.63763e-06 (W 2.12132e-05) | 0.0001705 ± 1.01283e-05 (W 7.77817e-06) |
| `gemm/64x64x64/b1` | 0.014457 ± 1.91572e-05 (W 2.82843e-05) | 0.0144415 ± 5.03322e-05 (W 2.05061e-05) | 0.020779 ± 6.76782e-05 (W 2.82843e-05) |
| `gemm/8x8x8/b1` | 0.0001305 ± 2.88675e-06 (W 6.36396e-06) | 0.00013 ± 8.94893e-06 (W 0) | 0.0002705 ± 8.94893e-06 (W 1.48492e-05) |

Repeated process sets describe observed repeatability under the recorded order schedule; they are not a paired baseline/candidate experiment and do not establish equal performance between engines.
