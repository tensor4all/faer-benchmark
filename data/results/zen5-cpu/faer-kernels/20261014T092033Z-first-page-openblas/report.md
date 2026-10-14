# `faer-kernels` on `zen5-cpu`

- t4a-faer (fork, measured) commit: `bfe4041cd9918815e3b3f766ac0332b792badb7d`
- t4a-faer version: `0.24.4`
- upstream faer commit: `0539947ffb757a739d7e703a7d2fa0c792a909c1`
- upstream faer ref/version: `faer-v0.24.4` / `0.24.4`
- features: `fbench/link-openblas`
- faer rows: `faer-fork` (the provider in the measured revision; see library and upstream above); `faer-upstream` (the provider in the measured revision; see library and upstream above)
- harness commit: `aa55fba63d51fca50862dabfebeb35fddc3aa734`
- hardware profile: `zen5-cpu`
- timestamp: `2026-10-14T10:15:00.765495Z`
- timing policy: v1, best of 5 reps, priming 500 ms (time-based, identical on every row)
- guards: idle window 3 s, max busy 5.0% including SMT siblings, 3 attempts
- command: `scripts/record_run.py zen5-cpu faer-kernels --checkout /tmp/fork-faer-rec --upstream /tmp/upstream-faer --vendor openblas --label first-page-openblas`
- raw data: `data/results/zen5-cpu/faer-kernels/20261014T092033Z-first-page-openblas/`

## What was measured

- **Workload** — Direct calls into one faer revision: square and rectangular dense matrices, C (row-major) and F (column-major) order, `f64` and `c64`. A shape is `N` for square, `MxN` for rectangular, or `MxKxN` for `gemm`, which is a three-index operation and cannot be written as two. Sizes are the matrix dimensions, not a memory budget, so a case name says exactly what was factored. `gemm` measures `linalg::matmul::matmul` into a caller-prepared destination with `Accum::Replace`; there is no operator path, so one shape is one work.
  Source: The fork's own public API (`faer/src/linalg`): `matmul`, the QR factor and composite, `upgrade_householder_factor`, the block/sequence Householder apply, LU and full-pivot LU, Cholesky, triangular solve, solve, thin SVD, singular values and the symmetric/nonsymmetric eigensolvers. Inputs are seeded from the case, so `verify` and `run` measure the same matrices and a rerun is reproducible.
  Known blind spot: Only the faer entry points are measured. tlinalg's packing, batch loop and lane policy, tenferro's tensor construction and dtype dispatch, and the small-`m` decode-projection shapes are other repositories' rows (tlinalg-benchmark, tenferro-benchmark).
  Known blind spot: The C-order vendor route is per family and is resolved by the harness, not here: a row-major LAPACK driver is a different operation from its transpose, so a vendor C-order cell is either a native row-major route, a timed adaptation, or an explicitly labelled prepared-layout comparison, and the manifest records which.
  Known blind spot: `gemm` covers the tall class's two Householder legs (a 16-wide basis and a 240-column target over 4096 rows: the reduction and the write-back) beside a vendor `?gemm` on the same leg. A single leg beside a vendor gemm is a diagnostic reference, not the equivalent implementation of the whole update, and the row is labelled accordingly.
  Known blind spot: `householder_apply` measures the block apply with an explicit basis width and target width, and the sequence form, as two rows; a reflector count the suite does not declare is not covered.
  Known blind spot: Allocation performed inside the measured call stays inside the clock. The fork's two row splits allocate their partial buffers inside the public call, and the public scratch function does not expose them; the campaign reports that as it is instead of changing faer's API to make the boundary look cleaner.
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
- CPU sets: 1T -> `4`, 4T -> `4-7`, 8T -> `4-11`

Every row below passed `fbench verify` on the same grid before timing: each provider's
factorizations are checked against that provider's documented convention
(residual, reconstruction, orthonormality, no NaN), never against another provider's
floating-point output. Times are milliseconds, the best wall time per case and engine
row; with more than one complete set repeat the table shows the best repeat, and the
A/A spread is reported at its foot. C and F order are separate cells, because the order
decides which path each provider takes.

## gemm-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0003 | 0.0002 | 0.0002 |
| `gemm/32x32x32/b1` | 0.0014 | 0.0014 | 0.0013 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0104 | 0.0103 | 0.0101 |
| `gemm/8x8x8/b1` | 0.0001 | 0.0001 | 0.0001 |

## gemm-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0002 | 0.0003 | 0.0002 |
| `gemm/32x32x32/b1` | 0.0054 | 0.0053 | 0.0013 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0109 | 0.0112 | 0.0101 |
| `gemm/8x8x8/b1` | 0.0001 | 0.0001 | 0.0001 |

## gemm-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0003 | 0.0003 | 0.0002 |
| `gemm/32x32x32/b1` | 0.0077 | 0.0072 | 0.0013 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0106 | 0.0106 | 0.0101 |
| `gemm/8x8x8/b1` | 0.0001 | 0.0001 | 0.0001 |

## gemm-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0003 | 0.0003 | 0.0002 |
| `gemm/32x32x32/b1` | 0.0014 | 0.0014 | 0.0013 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0103 | 0.0103 | 0.0101 |
| `gemm/8x8x8/b1` | 0.0001 | 0.0001 | 0.0001 |

## gemm-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0002 | 0.0003 | 0.0002 |
| `gemm/32x32x32/b1` | 0.0046 | 0.0047 | 0.0013 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0104 | 0.0105 | 0.0101 |
| `gemm/8x8x8/b1` | 0.0001 | 0.0001 | 0.0001 |

## gemm-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0003 | 0.0003 | 0.0002 |
| `gemm/32x32x32/b1` | 0.0078 | 0.0070 | 0.0013 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0110 | 0.0104 | 0.0101 |
| `gemm/8x8x8/b1` | 0.0001 | 0.0001 | 0.0001 |

## gemm-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0012 | 0.0012 | 0.0010 |
| `gemm/32x32x32/b1` | 0.0053 | 0.0053 | 0.0069 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0411 | 0.0411 | 0.0517 |
| `gemm/8x8x8/b1` | 0.0002 | 0.0002 | 0.0002 |

## gemm-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0012 | 0.0012 | 0.0011 |
| `gemm/32x32x32/b1` | 0.0053 | 0.0053 | 0.0070 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0207 | 0.0212 | 0.0156 |
| `gemm/8x8x8/b1` | 0.0002 | 0.0002 | 0.0003 |

## gemm-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0013 | 0.0012 | 0.0011 |
| `gemm/32x32x32/b1` | 0.0053 | 0.0053 | 0.0070 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0206 | 0.0220 | 0.0151 |
| `gemm/8x8x8/b1` | 0.0002 | 0.0002 | 0.0003 |

## gemm-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0012 | 0.0013 | 0.0010 |
| `gemm/32x32x32/b1` | 0.0053 | 0.0053 | 0.0069 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0410 | 0.0409 | 0.0516 |
| `gemm/8x8x8/b1` | 0.0002 | 0.0002 | 0.0002 |

## gemm-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0012 | 0.0012 | 0.0011 |
| `gemm/32x32x32/b1` | 0.0053 | 0.0053 | 0.0069 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0218 | 0.0218 | 0.0156 |
| `gemm/8x8x8/b1` | 0.0002 | 0.0002 | 0.0003 |

## gemm-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x16x16/b1` | 0.0012 | 0.0012 | 0.0011 |
| `gemm/32x32x32/b1` | 0.0053 | 0.0053 | 0.0070 |
| `gemm/4x4x4/b1` | 0.0001 | 0.0001 | 0.0001 |
| `gemm/64x64x64/b1` | 0.0201 | 0.0228 | 0.0152 |
| `gemm/8x8x8/b1` | 0.0002 | 0.0002 | 0.0003 |

## gemm-medium, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.9004 | 0.6563 | 0.7600 |

## gemm-medium, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.2579 | 0.1790 | 0.2033 |

## gemm-medium, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.1606 | 0.1521 | 0.1440 |

## gemm-medium, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.6442 | 0.6439 | 0.7606 |

## gemm-medium, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.1792 | 0.1796 | 0.2029 |

## gemm-medium, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.1102 | 0.1071 | 0.1072 |

## gemm-medium, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 2.5735 | 2.5756 | 3.1107 |

## gemm-medium, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.6767 | 0.6735 | 0.7946 |

## gemm-medium, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.3587 | 0.3583 | 0.4073 |

## gemm-medium, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 2.5743 | 2.5766 | 3.1091 |

## gemm-medium, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.6756 | 0.6736 | 0.7963 |

## gemm-medium, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/256x256x256/b1` | 0.3601 | 0.3605 | 0.4076 |

## gemm-large, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 7.2852 | 6.9225 | 8.4870 |

## gemm-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 1.8805 | 1.8833 | 2.1504 |

## gemm-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 0.9942 | 1.0091 | 1.0978 |

## gemm-large, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 6.3105 | 5.2137 | 6.0873 |

## gemm-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 1.8754 | 1.3565 | 1.5616 |

## gemm-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 0.9943 | 0.7340 | 0.7838 |

## gemm-large, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 20.8247 | 20.8360 | 24.7651 |

## gemm-large, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 5.3303 | 5.3044 | 6.3149 |

## gemm-large, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 2.7931 | 2.7947 | 3.1882 |

## gemm-large, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 20.8409 | 20.8334 | 24.7556 |

## gemm-large, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 5.3452 | 5.3208 | 6.3184 |

## gemm-large, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/512x512x512/b1` | 2.7876 | 2.7838 | 3.1908 |

## gemm-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.8337 | 0.8085 | 1.0560 |
| `gemm/4096x16x240/b1` | 0.6602 | 0.6593 | 0.9611 |
| `gemm/4096x64x64/b1` | 0.9114 | 0.6522 | 0.8179 |

## gemm-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.2776 | 0.3089 | 0.3160 |
| `gemm/4096x16x240/b1` | 0.2208 | 0.2276 | 0.3473 |
| `gemm/4096x64x64/b1` | 0.2616 | 0.1885 | 0.2083 |

## gemm-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.3734 | 0.3083 | 0.1832 |
| `gemm/4096x16x240/b1` | 0.1525 | 0.1548 | 0.1710 |
| `gemm/4096x64x64/b1` | 0.1361 | 0.1429 | 0.1081 |

## gemm-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.6316 | 0.6316 | 1.1077 |
| `gemm/4096x16x240/b1` | 0.6823 | 0.6823 | 0.8682 |
| `gemm/4096x64x64/b1` | 0.6986 | 0.6949 | 0.8285 |

## gemm-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.4121 | 0.4141 | 0.2750 |
| `gemm/4096x16x240/b1` | 0.2033 | 0.2031 | 0.3059 |
| `gemm/4096x64x64/b1` | 0.1863 | 0.1866 | 0.2195 |

## gemm-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.6842 | 0.6721 | 0.1373 |
| `gemm/4096x16x240/b1` | 0.1735 | 0.1719 | 0.2166 |
| `gemm/4096x64x64/b1` | 0.1049 | 0.1053 | 0.1159 |

## gemm-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.5594 | 2.5521 | 3.6671 |
| `gemm/4096x16x240/b1` | 2.6464 | 2.6424 | 3.6143 |
| `gemm/4096x64x64/b1` | 2.6696 | 2.6692 | 3.3107 |

## gemm-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.1779 | 1.1931 | 1.0743 |
| `gemm/4096x16x240/b1` | 0.7434 | 0.7524 | 1.3085 |
| `gemm/4096x64x64/b1` | 0.6980 | 0.6969 | 0.8593 |

## gemm-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 0.5765 | 0.5713 | 0.6103 |
| `gemm/4096x16x240/b1` | 0.4436 | 0.4389 | 0.8244 |
| `gemm/4096x64x64/b1` | 0.3684 | 0.3664 | 0.4246 |

## gemm-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 2.4412 | 2.4403 | 3.7484 |
| `gemm/4096x16x240/b1` | 2.6736 | 2.6755 | 3.6229 |
| `gemm/4096x64x64/b1` | 2.7741 | 2.7725 | 3.3506 |

## gemm-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.1573 | 1.1633 | 0.9869 |
| `gemm/4096x16x240/b1` | 0.7503 | 0.7551 | 1.2141 |
| `gemm/4096x64x64/b1` | 0.7664 | 0.7850 | 0.8712 |

## gemm-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/16x4096x240/b1` | 1.4815 | 1.5061 | 0.5236 |
| `gemm/4096x16x240/b1` | 0.4696 | 0.4815 | 0.7495 |
| `gemm/4096x64x64/b1` | 0.3740 | 0.3784 | 0.4638 |

## gemm-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.9512 | 0.7924 | 0.8292 |

## gemm-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.2598 | 0.2532 | 0.2821 |

## gemm-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.1466 | 0.1461 | 0.1377 |

## gemm-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.6522 | 0.6521 | 0.8222 |

## gemm-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.1755 | 0.1767 | 0.2076 |

## gemm-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.1003 | 0.0966 | 0.1076 |

## gemm-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 2.7550 | 2.7761 | 3.3435 |

## gemm-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.7473 | 0.7718 | 0.8812 |

## gemm-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.3725 | 0.3777 | 0.4606 |

## gemm-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 2.6476 | 2.6735 | 3.2977 |

## gemm-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.6993 | 0.6938 | 0.8531 |

## gemm-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `gemm/64x64x4096/b1` | 0.3654 | 0.3714 | 0.4264 |

## linalg-small, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0006 | 0.0006 | 0.0008 |
| `cholesky/n32/b1` | 0.0019 | 0.0018 | 0.0027 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0081 | 0.0073 | 0.0118 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0179 | 0.0179 | 0.0190 |
| `eigh/n32/b1` | 0.0686 | 0.0683 | 0.0713 |
| `eigh/n4/b1` | 0.0018 | 0.0017 | 0.0022 |
| `eigh/n64/b1` | 0.2916 | 0.2915 | 0.2667 |
| `eigh/n8/b1` | 0.0052 | 0.0052 | 0.0062 |
| `full_piv_lu/n16/b1` | 0.0019 | 0.0019 | - |
| `full_piv_lu/n32/b1` | 0.0065 | 0.0064 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0003 | - |
| `full_piv_lu/n64/b1` | 0.0282 | 0.0282 | - |
| `full_piv_lu/n8/b1` | 0.0007 | 0.0007 | - |
| `householder_apply/n16/b1` | 0.0052 | 0.0061 | - |
| `householder_apply/n32/b1` | 0.0539 | 0.0593 | - |
| `householder_apply/n4/b1` | 0.0010 | 0.0010 | - |
| `householder_apply/n64/b1` | 0.1283 | 0.1456 | - |
| `householder_apply/n8/b1` | 0.0019 | 0.0021 | - |
| `lu/n16/b1` | 0.0017 | 0.0017 | 0.0018 |
| `lu/n32/b1` | 0.0045 | 0.0045 | 0.0061 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0163 | 0.0165 | 0.0243 |
| `lu/n8/b1` | 0.0006 | 0.0006 | 0.0005 |
| `qr/n16/b1` | 0.0052 | 0.0053 | 0.0059 |
| `qr/n32/b1` | 0.0191 | 0.0194 | 0.0190 |
| `qr/n4/b1` | 0.0007 | 0.0007 | 0.0009 |
| `qr/n64/b1` | 0.0705 | 0.0715 | 0.0770 |
| `qr/n8/b1` | 0.0017 | 0.0017 | 0.0022 |
| `qr_factor/n16/b1` | 0.0029 | 0.0037 | 0.0035 |
| `qr_factor/n32/b1` | 0.0146 | 0.0169 | 0.0111 |
| `qr_factor/n4/b1` | 0.0003 | 0.0004 | 0.0005 |
| `qr_factor/n64/b1` | 0.0633 | 0.0792 | 0.0412 |
| `qr_factor/n8/b1` | 0.0008 | 0.0011 | 0.0014 |
| `solve/n16/b1` | 0.0020 | 0.0020 | 0.0020 |
| `solve/n32/b1` | 0.0050 | 0.0051 | 0.0062 |
| `solve/n4/b1` | 0.0003 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0170 | 0.0170 | 0.0237 |
| `solve/n8/b1` | 0.0007 | 0.0008 | 0.0006 |
| `svd_thin/n16/b1` | 0.0297 | 0.0297 | 0.0321 |
| `svd_thin/n32/b1` | 0.1104 | 0.1094 | 0.1057 |
| `svd_thin/n4/b1` | 0.0025 | 0.0025 | 0.0049 |
| `svd_thin/n64/b1` | 0.5658 | 0.5665 | 0.4234 |
| `svd_thin/n8/b1` | 0.0082 | 0.0082 | 0.0112 |
| `svd_values/n16/b1` | 0.0214 | 0.0214 | 0.0153 |
| `svd_values/n32/b1` | 0.0845 | 0.0844 | 0.0457 |
| `svd_values/n4/b1` | 0.0021 | 0.0021 | 0.0033 |
| `svd_values/n64/b1` | 0.3106 | 0.3103 | 0.1809 |
| `svd_values/n8/b1` | 0.0060 | 0.0059 | 0.0061 |
| `triangular_solve/n16/b1` | 0.0002 | 0.0002 | - |
| `triangular_solve/n32/b1` | 0.0004 | 0.0004 | - |
| `triangular_solve/n4/b1` | 0.0000 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0009 | 0.0009 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0007 | 0.0006 | 0.0009 |
| `cholesky/n32/b1` | 0.0019 | 0.0017 | 0.0027 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0084 | 0.0074 | 0.0118 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0180 | 0.0180 | 0.0192 |
| `eigh/n32/b1` | 0.0687 | 0.0683 | 0.0621 |
| `eigh/n4/b1` | 0.0017 | 0.0017 | 0.0022 |
| `eigh/n64/b1` | 0.2993 | 0.3016 | 0.2169 |
| `eigh/n8/b1` | 0.0053 | 0.0053 | 0.0062 |
| `full_piv_lu/n16/b1` | 0.0020 | 0.0020 | - |
| `full_piv_lu/n32/b1` | 0.0067 | 0.0066 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0004 | - |
| `full_piv_lu/n64/b1` | 0.0288 | 0.0283 | - |
| `full_piv_lu/n8/b1` | 0.0008 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0055 | 0.0061 | - |
| `householder_apply/n32/b1` | 0.0537 | 0.0688 | - |
| `householder_apply/n4/b1` | 0.0010 | 0.0010 | - |
| `householder_apply/n64/b1` | 0.1529 | 0.2758 | - |
| `householder_apply/n8/b1` | 0.0019 | 0.0021 | - |
| `lu/n16/b1` | 0.0016 | 0.0017 | 0.0018 |
| `lu/n32/b1` | 0.0046 | 0.0045 | 0.0062 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0162 | 0.0254 | 0.0244 |
| `lu/n8/b1` | 0.0006 | 0.0006 | 0.0006 |
| `qr/n16/b1` | 0.0053 | 0.0053 | 0.0059 |
| `qr/n32/b1` | 0.0190 | 0.0658 | 0.0196 |
| `qr/n4/b1` | 0.0007 | 0.0007 | 0.0009 |
| `qr/n64/b1` | 0.0868 | 0.2718 | 0.0776 |
| `qr/n8/b1` | 0.0017 | 0.0018 | 0.0023 |
| `qr_factor/n16/b1` | 0.0029 | 0.0035 | 0.0035 |
| `qr_factor/n32/b1` | 0.0145 | 0.0480 | 0.0107 |
| `qr_factor/n4/b1` | 0.0003 | 0.0004 | 0.0006 |
| `qr_factor/n64/b1` | 0.0797 | 0.2687 | 0.0413 |
| `qr_factor/n8/b1` | 0.0008 | 0.0011 | 0.0014 |
| `solve/n16/b1` | 0.0020 | 0.0021 | 0.0020 |
| `solve/n32/b1` | 0.0050 | 0.0050 | 0.0062 |
| `solve/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0167 | 0.0244 | 0.0238 |
| `solve/n8/b1` | 0.0008 | 0.0007 | 0.0006 |
| `svd_thin/n16/b1` | 0.0299 | 0.0299 | 0.0322 |
| `svd_thin/n32/b1` | 0.1104 | 0.1097 | 0.1059 |
| `svd_thin/n4/b1` | 0.0026 | 0.0025 | 0.0050 |
| `svd_thin/n64/b1` | 0.5751 | 0.5743 | 0.4172 |
| `svd_thin/n8/b1` | 0.0082 | 0.0083 | 0.0111 |
| `svd_values/n16/b1` | 0.0211 | 0.0213 | 0.0155 |
| `svd_values/n32/b1` | 0.0850 | 0.0842 | 0.0462 |
| `svd_values/n4/b1` | 0.0021 | 0.0021 | 0.0033 |
| `svd_values/n64/b1` | 0.3105 | 0.3116 | 0.1764 |
| `svd_values/n8/b1` | 0.0060 | 0.0060 | 0.0061 |
| `triangular_solve/n16/b1` | 0.0002 | 0.0002 | - |
| `triangular_solve/n32/b1` | 0.0004 | 0.0004 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0009 | 0.0009 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0006 | 0.0006 | 0.0008 |
| `cholesky/n32/b1` | 0.0019 | 0.0017 | 0.0025 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0089 | 0.0073 | 0.0112 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0178 | 0.0177 | 0.0192 |
| `eigh/n32/b1` | 0.0685 | 0.0687 | 0.0613 |
| `eigh/n4/b1` | 0.0017 | 0.0017 | 0.0022 |
| `eigh/n64/b1` | 0.3014 | 0.3038 | 0.2167 |
| `eigh/n8/b1` | 0.0053 | 0.0052 | 0.0062 |
| `full_piv_lu/n16/b1` | 0.0020 | 0.0019 | - |
| `full_piv_lu/n32/b1` | 0.0065 | 0.0065 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0004 | - |
| `full_piv_lu/n64/b1` | 0.0283 | 0.0282 | - |
| `full_piv_lu/n8/b1` | 0.0008 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0054 | 0.0060 | - |
| `householder_apply/n32/b1` | 0.0538 | 0.0695 | - |
| `householder_apply/n4/b1` | 0.0010 | 0.0010 | - |
| `householder_apply/n64/b1` | 0.1550 | 0.3972 | - |
| `householder_apply/n8/b1` | 0.0019 | 0.0021 | - |
| `lu/n16/b1` | 0.0017 | 0.0017 | 0.0017 |
| `lu/n32/b1` | 0.0045 | 0.0045 | 0.0062 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0162 | 0.0297 | 0.0245 |
| `lu/n8/b1` | 0.0006 | 0.0006 | 0.0005 |
| `qr/n16/b1` | 0.0050 | 0.0051 | 0.0060 |
| `qr/n32/b1` | 0.0191 | 0.0818 | 0.0194 |
| `qr/n4/b1` | 0.0007 | 0.0007 | 0.0009 |
| `qr/n64/b1` | 0.0914 | 0.4252 | 0.0781 |
| `qr/n8/b1` | 0.0017 | 0.0017 | 0.0023 |
| `qr_factor/n16/b1` | 0.0029 | 0.0036 | 0.0035 |
| `qr_factor/n32/b1` | 0.0145 | 0.0717 | 0.0109 |
| `qr_factor/n4/b1` | 0.0003 | 0.0004 | 0.0006 |
| `qr_factor/n64/b1` | 0.0804 | 0.4034 | 0.0412 |
| `qr_factor/n8/b1` | 0.0008 | 0.0011 | 0.0014 |
| `solve/n16/b1` | 0.0020 | 0.0020 | 0.0020 |
| `solve/n32/b1` | 0.0050 | 0.0050 | 0.0062 |
| `solve/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0168 | 0.0308 | 0.0237 |
| `solve/n8/b1` | 0.0008 | 0.0008 | 0.0006 |
| `svd_thin/n16/b1` | 0.0298 | 0.0298 | 0.0321 |
| `svd_thin/n32/b1` | 0.1102 | 0.1095 | 0.1061 |
| `svd_thin/n4/b1` | 0.0025 | 0.0025 | 0.0049 |
| `svd_thin/n64/b1` | 0.5943 | 0.5926 | 0.4332 |
| `svd_thin/n8/b1` | 0.0081 | 0.0082 | 0.0113 |
| `svd_values/n16/b1` | 0.0212 | 0.0212 | 0.0155 |
| `svd_values/n32/b1` | 0.0848 | 0.0842 | 0.0462 |
| `svd_values/n4/b1` | 0.0021 | 0.0021 | 0.0033 |
| `svd_values/n64/b1` | 0.3093 | 0.3091 | 0.1700 |
| `svd_values/n8/b1` | 0.0059 | 0.0060 | 0.0061 |
| `triangular_solve/n16/b1` | 0.0002 | 0.0002 | - |
| `triangular_solve/n32/b1` | 0.0004 | 0.0004 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0009 | 0.0009 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0006 | 0.0006 | 0.0006 |
| `cholesky/n32/b1` | 0.0019 | 0.0017 | 0.0021 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0001 |
| `cholesky/n64/b1` | 0.0081 | 0.0073 | 0.0091 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0002 |
| `eigh/n16/b1` | 0.0180 | 0.0179 | 0.0187 |
| `eigh/n32/b1` | 0.0685 | 0.0685 | 0.0706 |
| `eigh/n4/b1` | 0.0017 | 0.0017 | 0.0021 |
| `eigh/n64/b1` | 0.2908 | 0.2922 | 0.2572 |
| `eigh/n8/b1` | 0.0053 | 0.0053 | 0.0060 |
| `full_piv_lu/n16/b1` | 0.0019 | 0.0018 | - |
| `full_piv_lu/n32/b1` | 0.0063 | 0.0063 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0003 | - |
| `full_piv_lu/n64/b1` | 0.0279 | 0.0281 | - |
| `full_piv_lu/n8/b1` | 0.0007 | 0.0007 | - |
| `householder_apply/n16/b1` | 0.0043 | 0.0044 | - |
| `householder_apply/n32/b1` | 0.0158 | 0.0163 | - |
| `householder_apply/n4/b1` | 0.0009 | 0.0009 | - |
| `householder_apply/n64/b1` | 0.0731 | 0.0735 | - |
| `householder_apply/n8/b1` | 0.0017 | 0.0017 | - |
| `lu/n16/b1` | 0.0016 | 0.0017 | 0.0015 |
| `lu/n32/b1` | 0.0044 | 0.0044 | 0.0050 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0158 | 0.0160 | 0.0201 |
| `lu/n8/b1` | 0.0006 | 0.0006 | 0.0004 |
| `qr/n16/b1` | 0.0052 | 0.0053 | 0.0053 |
| `qr/n32/b1` | 0.0189 | 0.0192 | 0.0171 |
| `qr/n4/b1` | 0.0007 | 0.0007 | 0.0008 |
| `qr/n64/b1` | 0.0694 | 0.0700 | 0.0697 |
| `qr/n8/b1` | 0.0017 | 0.0017 | 0.0021 |
| `qr_factor/n16/b1` | 0.0019 | 0.0021 | 0.0032 |
| `qr_factor/n32/b1` | 0.0107 | 0.0109 | 0.0097 |
| `qr_factor/n4/b1` | 0.0002 | 0.0003 | 0.0005 |
| `qr_factor/n64/b1` | 0.0442 | 0.0457 | 0.0377 |
| `qr_factor/n8/b1` | 0.0006 | 0.0006 | 0.0013 |
| `solve/n16/b1` | 0.0020 | 0.0019 | 0.0017 |
| `solve/n32/b1` | 0.0047 | 0.0049 | 0.0050 |
| `solve/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `solve/n64/b1` | 0.0161 | 0.0161 | 0.0193 |
| `solve/n8/b1` | 0.0007 | 0.0008 | 0.0005 |
| `svd_thin/n16/b1` | 0.0298 | 0.0297 | 0.0324 |
| `svd_thin/n32/b1` | 0.1117 | 0.1109 | 0.1052 |
| `svd_thin/n4/b1` | 0.0027 | 0.0026 | 0.0048 |
| `svd_thin/n64/b1` | 0.5904 | 0.5900 | 0.3983 |
| `svd_thin/n8/b1` | 0.0084 | 0.0083 | 0.0109 |
| `svd_values/n16/b1` | 0.0219 | 0.0219 | 0.0154 |
| `svd_values/n32/b1` | 0.0858 | 0.0854 | 0.0453 |
| `svd_values/n4/b1` | 0.0020 | 0.0020 | 0.0031 |
| `svd_values/n64/b1` | 0.3232 | 0.3222 | 0.1638 |
| `svd_values/n8/b1` | 0.0059 | 0.0059 | 0.0063 |
| `triangular_solve/n16/b1` | 0.0002 | 0.0002 | - |
| `triangular_solve/n32/b1` | 0.0004 | 0.0005 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0010 | 0.0011 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0007 | 0.0006 | 0.0007 |
| `cholesky/n32/b1` | 0.0019 | 0.0017 | 0.0021 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0001 |
| `cholesky/n64/b1` | 0.0085 | 0.0075 | 0.0092 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0180 | 0.0181 | 0.0190 |
| `eigh/n32/b1` | 0.0685 | 0.0687 | 0.0613 |
| `eigh/n4/b1` | 0.0017 | 0.0017 | 0.0022 |
| `eigh/n64/b1` | 0.2989 | 0.3016 | 0.2142 |
| `eigh/n8/b1` | 0.0053 | 0.0053 | 0.0061 |
| `full_piv_lu/n16/b1` | 0.0020 | 0.0020 | - |
| `full_piv_lu/n32/b1` | 0.0066 | 0.0064 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0004 | - |
| `full_piv_lu/n64/b1` | 0.0282 | 0.0278 | - |
| `full_piv_lu/n8/b1` | 0.0008 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0043 | 0.0045 | - |
| `householder_apply/n32/b1` | 0.0155 | 0.0220 | - |
| `householder_apply/n4/b1` | 0.0009 | 0.0009 | - |
| `householder_apply/n64/b1` | 0.0888 | 0.2373 | - |
| `householder_apply/n8/b1` | 0.0017 | 0.0018 | - |
| `lu/n16/b1` | 0.0017 | 0.0017 | 0.0015 |
| `lu/n32/b1` | 0.0043 | 0.0044 | 0.0051 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0157 | 0.0237 | 0.0202 |
| `lu/n8/b1` | 0.0006 | 0.0006 | 0.0004 |
| `qr/n16/b1` | 0.0052 | 0.0053 | 0.0054 |
| `qr/n32/b1` | 0.0190 | 0.0618 | 0.0175 |
| `qr/n4/b1` | 0.0007 | 0.0007 | 0.0008 |
| `qr/n64/b1` | 0.0895 | 0.2819 | 0.0693 |
| `qr/n8/b1` | 0.0018 | 0.0018 | 0.0021 |
| `qr_factor/n16/b1` | 0.0019 | 0.0020 | 0.0032 |
| `qr_factor/n32/b1` | 0.0107 | 0.0451 | 0.0098 |
| `qr_factor/n4/b1` | 0.0002 | 0.0003 | 0.0005 |
| `qr_factor/n64/b1` | 0.0511 | 0.2361 | 0.0378 |
| `qr_factor/n8/b1` | 0.0006 | 0.0007 | 0.0013 |
| `solve/n16/b1` | 0.0019 | 0.0020 | 0.0017 |
| `solve/n32/b1` | 0.0047 | 0.0048 | 0.0051 |
| `solve/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0158 | 0.0238 | 0.0195 |
| `solve/n8/b1` | 0.0007 | 0.0007 | 0.0006 |
| `svd_thin/n16/b1` | 0.0299 | 0.0299 | 0.0324 |
| `svd_thin/n32/b1` | 0.1116 | 0.1107 | 0.1054 |
| `svd_thin/n4/b1` | 0.0027 | 0.0027 | 0.0048 |
| `svd_thin/n64/b1` | 0.6011 | 0.6029 | 0.3910 |
| `svd_thin/n8/b1` | 0.0085 | 0.0085 | 0.0109 |
| `svd_values/n16/b1` | 0.0217 | 0.0218 | 0.0154 |
| `svd_values/n32/b1` | 0.0861 | 0.0855 | 0.0455 |
| `svd_values/n4/b1` | 0.0020 | 0.0020 | 0.0031 |
| `svd_values/n64/b1` | 0.3227 | 0.3226 | 0.1628 |
| `svd_values/n8/b1` | 0.0059 | 0.0059 | 0.0063 |
| `triangular_solve/n16/b1` | 0.0002 | 0.0002 | - |
| `triangular_solve/n32/b1` | 0.0004 | 0.0004 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0011 | 0.0010 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0006 | 0.0006 | 0.0007 |
| `cholesky/n32/b1` | 0.0019 | 0.0017 | 0.0020 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0090 | 0.0074 | 0.0091 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0177 | 0.0178 | 0.0190 |
| `eigh/n32/b1` | 0.0683 | 0.0690 | 0.0606 |
| `eigh/n4/b1` | 0.0017 | 0.0017 | 0.0022 |
| `eigh/n64/b1` | 0.3019 | 0.3046 | 0.2094 |
| `eigh/n8/b1` | 0.0053 | 0.0052 | 0.0062 |
| `full_piv_lu/n16/b1` | 0.0020 | 0.0020 | - |
| `full_piv_lu/n32/b1` | 0.0064 | 0.0063 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0004 | - |
| `full_piv_lu/n64/b1` | 0.0278 | 0.0276 | - |
| `full_piv_lu/n8/b1` | 0.0008 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0043 | 0.0044 | - |
| `householder_apply/n32/b1` | 0.0157 | 0.0238 | - |
| `householder_apply/n4/b1` | 0.0009 | 0.0009 | - |
| `householder_apply/n64/b1` | 0.1011 | 0.3305 | - |
| `householder_apply/n8/b1` | 0.0017 | 0.0018 | - |
| `lu/n16/b1` | 0.0016 | 0.0017 | 0.0016 |
| `lu/n32/b1` | 0.0043 | 0.0045 | 0.0052 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0156 | 0.0283 | 0.0203 |
| `lu/n8/b1` | 0.0006 | 0.0006 | 0.0005 |
| `qr/n16/b1` | 0.0050 | 0.0051 | 0.0055 |
| `qr/n32/b1` | 0.0191 | 0.0815 | 0.0172 |
| `qr/n4/b1` | 0.0007 | 0.0007 | 0.0009 |
| `qr/n64/b1` | 0.0910 | 0.4434 | 0.0701 |
| `qr/n8/b1` | 0.0016 | 0.0017 | 0.0021 |
| `qr_factor/n16/b1` | 0.0019 | 0.0020 | 0.0033 |
| `qr_factor/n32/b1` | 0.0109 | 0.0727 | 0.0097 |
| `qr_factor/n4/b1` | 0.0002 | 0.0003 | 0.0005 |
| `qr_factor/n64/b1` | 0.0612 | 0.3746 | 0.0375 |
| `qr_factor/n8/b1` | 0.0006 | 0.0006 | 0.0013 |
| `solve/n16/b1` | 0.0020 | 0.0019 | 0.0018 |
| `solve/n32/b1` | 0.0047 | 0.0048 | 0.0053 |
| `solve/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0159 | 0.0301 | 0.0194 |
| `solve/n8/b1` | 0.0008 | 0.0007 | 0.0006 |
| `svd_thin/n16/b1` | 0.0298 | 0.0297 | 0.0323 |
| `svd_thin/n32/b1` | 0.1113 | 0.1106 | 0.1060 |
| `svd_thin/n4/b1` | 0.0026 | 0.0027 | 0.0047 |
| `svd_thin/n64/b1` | 0.6159 | 0.6188 | 0.4031 |
| `svd_thin/n8/b1` | 0.0084 | 0.0083 | 0.0109 |
| `svd_values/n16/b1` | 0.0217 | 0.0217 | 0.0154 |
| `svd_values/n32/b1` | 0.0861 | 0.0852 | 0.0457 |
| `svd_values/n4/b1` | 0.0020 | 0.0021 | 0.0032 |
| `svd_values/n64/b1` | 0.3219 | 0.3223 | 0.1647 |
| `svd_values/n8/b1` | 0.0059 | 0.0059 | 0.0064 |
| `triangular_solve/n16/b1` | 0.0002 | 0.0002 | - |
| `triangular_solve/n32/b1` | 0.0004 | 0.0005 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0000 | - |
| `triangular_solve/n64/b1` | 0.0010 | 0.0011 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0008 | 0.0008 | 0.0011 |
| `cholesky/n32/b1` | 0.0030 | 0.0031 | 0.0039 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0176 | 0.0181 | 0.0237 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0004 |
| `eigh/n16/b1` | 0.0192 | 0.0191 | 0.0308 |
| `eigh/n32/b1` | 0.0855 | 0.0851 | 0.0909 |
| `eigh/n4/b1` | 0.0019 | 0.0019 | 0.0027 |
| `eigh/n64/b1` | 0.3893 | 0.3897 | 0.3892 |
| `eigh/n8/b1` | 0.0054 | 0.0055 | 0.0079 |
| `full_piv_lu/n16/b1` | 0.0023 | 0.0023 | - |
| `full_piv_lu/n32/b1` | 0.0095 | 0.0094 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0004 | - |
| `full_piv_lu/n64/b1` | 0.0559 | 0.0557 | - |
| `full_piv_lu/n8/b1` | 0.0008 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0112 | 0.0117 | - |
| `householder_apply/n32/b1` | 0.1343 | 0.1423 | - |
| `householder_apply/n4/b1` | 0.0014 | 0.0014 | - |
| `householder_apply/n64/b1` | 0.3381 | 0.3575 | - |
| `householder_apply/n8/b1` | 0.0030 | 0.0031 | - |
| `lu/n16/b1` | 0.0019 | 0.0018 | 0.0023 |
| `lu/n32/b1` | 0.0071 | 0.0070 | 0.0084 |
| `lu/n4/b1` | 0.0003 | 0.0003 | 0.0002 |
| `lu/n64/b1` | 0.0329 | 0.0329 | 0.0404 |
| `lu/n8/b1` | 0.0008 | 0.0007 | 0.0006 |
| `qr/n16/b1` | 0.0063 | 0.0066 | 0.0089 |
| `qr/n32/b1` | 0.0424 | 0.0417 | 0.0321 |
| `qr/n4/b1` | 0.0007 | 0.0008 | 0.0014 |
| `qr/n64/b1` | 0.2002 | 0.2011 | 0.1632 |
| `qr/n8/b1` | 0.0016 | 0.0017 | 0.0030 |
| `qr_factor/n16/b1` | 0.0046 | 0.0054 | 0.0056 |
| `qr_factor/n32/b1` | 0.0245 | 0.0275 | 0.0184 |
| `qr_factor/n4/b1` | 0.0004 | 0.0005 | 0.0009 |
| `qr_factor/n64/b1` | 0.1276 | 0.1437 | 0.0914 |
| `qr_factor/n8/b1` | 0.0011 | 0.0013 | 0.0020 |
| `solve/n16/b1` | 0.0025 | 0.0024 | 0.0028 |
| `solve/n32/b1` | 0.0078 | 0.0077 | 0.0093 |
| `solve/n4/b1` | 0.0004 | 0.0005 | 0.0004 |
| `solve/n64/b1` | 0.0339 | 0.0338 | 0.0433 |
| `solve/n8/b1` | 0.0009 | 0.0008 | 0.0009 |
| `svd_thin/n16/b1` | 0.0317 | 0.0318 | 0.0397 |
| `svd_thin/n32/b1` | 0.1424 | 0.1418 | 0.1373 |
| `svd_thin/n4/b1` | 0.0030 | 0.0030 | 0.0058 |
| `svd_thin/n64/b1` | 0.7360 | 0.7365 | 0.6515 |
| `svd_thin/n8/b1` | 0.0089 | 0.0089 | 0.0126 |
| `svd_values/n16/b1` | 0.0234 | 0.0234 | 0.0198 |
| `svd_values/n32/b1` | 0.0975 | 0.0969 | 0.0622 |
| `svd_values/n4/b1` | 0.0024 | 0.0024 | 0.0041 |
| `svd_values/n64/b1` | 0.3913 | 0.3927 | 0.2807 |
| `svd_values/n8/b1` | 0.0075 | 0.0075 | 0.0078 |
| `triangular_solve/n16/b1` | 0.0003 | 0.0003 | - |
| `triangular_solve/n32/b1` | 0.0006 | 0.0006 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0016 | 0.0016 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0008 | 0.0008 | 0.0011 |
| `cholesky/n32/b1` | 0.0029 | 0.0031 | 0.0040 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0176 | 0.0177 | 0.0252 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0004 |
| `eigh/n16/b1` | 0.0192 | 0.0192 | 0.0312 |
| `eigh/n32/b1` | 0.0851 | 0.0849 | 0.0829 |
| `eigh/n4/b1` | 0.0019 | 0.0019 | 0.0028 |
| `eigh/n64/b1` | 0.3813 | 0.3891 | 0.3436 |
| `eigh/n8/b1` | 0.0054 | 0.0054 | 0.0080 |
| `full_piv_lu/n16/b1` | 0.0025 | 0.0026 | - |
| `full_piv_lu/n32/b1` | 0.0096 | 0.0095 | - |
| `full_piv_lu/n4/b1` | 0.0005 | 0.0005 | - |
| `full_piv_lu/n64/b1` | 0.0560 | 0.0559 | - |
| `full_piv_lu/n8/b1` | 0.0009 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0111 | 0.0118 | - |
| `householder_apply/n32/b1` | 0.1345 | 0.1464 | - |
| `householder_apply/n4/b1` | 0.0014 | 0.0014 | - |
| `householder_apply/n64/b1` | 0.2979 | 0.4139 | - |
| `householder_apply/n8/b1` | 0.0030 | 0.0031 | - |
| `lu/n16/b1` | 0.0020 | 0.0019 | 0.0023 |
| `lu/n32/b1` | 0.0071 | 0.0071 | 0.0084 |
| `lu/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `lu/n64/b1` | 0.0326 | 0.0330 | 0.0396 |
| `lu/n8/b1` | 0.0008 | 0.0008 | 0.0006 |
| `qr/n16/b1` | 0.0065 | 0.0066 | 0.0089 |
| `qr/n32/b1` | 0.0406 | 0.0874 | 0.0317 |
| `qr/n4/b1` | 0.0008 | 0.0008 | 0.0014 |
| `qr/n64/b1` | 0.1957 | 0.4044 | 0.1565 |
| `qr/n8/b1` | 0.0016 | 0.0018 | 0.0030 |
| `qr_factor/n16/b1` | 0.0046 | 0.0054 | 0.0056 |
| `qr_factor/n32/b1` | 0.0242 | 0.0669 | 0.0183 |
| `qr_factor/n4/b1` | 0.0004 | 0.0005 | 0.0009 |
| `qr_factor/n64/b1` | 0.1249 | 0.3667 | 0.0835 |
| `qr_factor/n8/b1` | 0.0011 | 0.0013 | 0.0020 |
| `solve/n16/b1` | 0.0025 | 0.0025 | 0.0028 |
| `solve/n32/b1` | 0.0079 | 0.0078 | 0.0092 |
| `solve/n4/b1` | 0.0005 | 0.0005 | 0.0004 |
| `solve/n64/b1` | 0.0339 | 0.0339 | 0.0437 |
| `solve/n8/b1` | 0.0009 | 0.0009 | 0.0009 |
| `svd_thin/n16/b1` | 0.0318 | 0.0318 | 0.0397 |
| `svd_thin/n32/b1` | 0.1418 | 0.1412 | 0.1369 |
| `svd_thin/n4/b1` | 0.0030 | 0.0030 | 0.0058 |
| `svd_thin/n64/b1` | 0.7164 | 0.7187 | 0.6550 |
| `svd_thin/n8/b1` | 0.0091 | 0.0090 | 0.0126 |
| `svd_values/n16/b1` | 0.0234 | 0.0234 | 0.0199 |
| `svd_values/n32/b1` | 0.0974 | 0.0971 | 0.0620 |
| `svd_values/n4/b1` | 0.0024 | 0.0024 | 0.0042 |
| `svd_values/n64/b1` | 0.3911 | 0.3912 | 0.2787 |
| `svd_values/n8/b1` | 0.0075 | 0.0074 | 0.0078 |
| `triangular_solve/n16/b1` | 0.0003 | 0.0003 | - |
| `triangular_solve/n32/b1` | 0.0006 | 0.0006 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0016 | 0.0016 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0008 | 0.0008 | 0.0011 |
| `cholesky/n32/b1` | 0.0030 | 0.0031 | 0.0039 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0174 | 0.0181 | 0.0284 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0004 |
| `eigh/n16/b1` | 0.0191 | 0.0189 | 0.0313 |
| `eigh/n32/b1` | 0.0856 | 0.0850 | 0.0812 |
| `eigh/n4/b1` | 0.0019 | 0.0019 | 0.0028 |
| `eigh/n64/b1` | 0.3838 | 0.3871 | 0.3374 |
| `eigh/n8/b1` | 0.0054 | 0.0054 | 0.0081 |
| `full_piv_lu/n16/b1` | 0.0024 | 0.0024 | - |
| `full_piv_lu/n32/b1` | 0.0095 | 0.0095 | - |
| `full_piv_lu/n4/b1` | 0.0005 | 0.0005 | - |
| `full_piv_lu/n64/b1` | 0.0554 | 0.0554 | - |
| `full_piv_lu/n8/b1` | 0.0009 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0111 | 0.0119 | - |
| `householder_apply/n32/b1` | 0.1341 | 0.1532 | - |
| `householder_apply/n4/b1` | 0.0014 | 0.0014 | - |
| `householder_apply/n64/b1` | 0.3083 | 0.5155 | - |
| `householder_apply/n8/b1` | 0.0030 | 0.0032 | - |
| `lu/n16/b1` | 0.0020 | 0.0019 | 0.0023 |
| `lu/n32/b1` | 0.0070 | 0.0069 | 0.0084 |
| `lu/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `lu/n64/b1` | 0.0324 | 0.0328 | 0.0394 |
| `lu/n8/b1` | 0.0008 | 0.0008 | 0.0006 |
| `qr/n16/b1` | 0.0065 | 0.0066 | 0.0090 |
| `qr/n32/b1` | 0.0408 | 0.1104 | 0.0320 |
| `qr/n4/b1` | 0.0007 | 0.0008 | 0.0014 |
| `qr/n64/b1` | 0.1955 | 0.5581 | 0.1562 |
| `qr/n8/b1` | 0.0016 | 0.0018 | 0.0030 |
| `qr_factor/n16/b1` | 0.0046 | 0.0055 | 0.0056 |
| `qr_factor/n32/b1` | 0.0243 | 0.0950 | 0.0184 |
| `qr_factor/n4/b1` | 0.0004 | 0.0005 | 0.0009 |
| `qr_factor/n64/b1` | 0.1273 | 0.4751 | 0.0842 |
| `qr_factor/n8/b1` | 0.0011 | 0.0013 | 0.0021 |
| `solve/n16/b1` | 0.0025 | 0.0024 | 0.0029 |
| `solve/n32/b1` | 0.0078 | 0.0077 | 0.0093 |
| `solve/n4/b1` | 0.0005 | 0.0005 | 0.0004 |
| `solve/n64/b1` | 0.0337 | 0.0335 | 0.0436 |
| `solve/n8/b1` | 0.0009 | 0.0009 | 0.0009 |
| `svd_thin/n16/b1` | 0.0315 | 0.0315 | 0.0398 |
| `svd_thin/n32/b1` | 0.1422 | 0.1413 | 0.1366 |
| `svd_thin/n4/b1` | 0.0030 | 0.0030 | 0.0058 |
| `svd_thin/n64/b1` | 0.7363 | 0.7296 | 0.6458 |
| `svd_thin/n8/b1` | 0.0089 | 0.0089 | 0.0126 |
| `svd_values/n16/b1` | 0.0236 | 0.0235 | 0.0199 |
| `svd_values/n32/b1` | 0.0979 | 0.0975 | 0.0622 |
| `svd_values/n4/b1` | 0.0024 | 0.0024 | 0.0042 |
| `svd_values/n64/b1` | 0.3942 | 0.3934 | 0.2791 |
| `svd_values/n8/b1` | 0.0075 | 0.0074 | 0.0078 |
| `triangular_solve/n16/b1` | 0.0003 | 0.0003 | - |
| `triangular_solve/n32/b1` | 0.0006 | 0.0006 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0016 | 0.0016 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0007 | 0.0008 | 0.0009 |
| `cholesky/n32/b1` | 0.0029 | 0.0031 | 0.0034 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0173 | 0.0180 | 0.0191 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0192 | 0.0191 | 0.0306 |
| `eigh/n32/b1` | 0.0851 | 0.0851 | 0.0903 |
| `eigh/n4/b1` | 0.0019 | 0.0019 | 0.0027 |
| `eigh/n64/b1` | 0.3893 | 0.3903 | 0.3851 |
| `eigh/n8/b1` | 0.0054 | 0.0054 | 0.0077 |
| `full_piv_lu/n16/b1` | 0.0024 | 0.0023 | - |
| `full_piv_lu/n32/b1` | 0.0095 | 0.0095 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0004 | - |
| `full_piv_lu/n64/b1` | 0.0549 | 0.0545 | - |
| `full_piv_lu/n8/b1` | 0.0008 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0097 | 0.0098 | - |
| `householder_apply/n32/b1` | 0.0402 | 0.0406 | - |
| `householder_apply/n4/b1` | 0.0013 | 0.0013 | - |
| `householder_apply/n64/b1` | 0.2079 | 0.2098 | - |
| `householder_apply/n8/b1` | 0.0027 | 0.0027 | - |
| `lu/n16/b1` | 0.0019 | 0.0018 | 0.0020 |
| `lu/n32/b1` | 0.0071 | 0.0071 | 0.0077 |
| `lu/n4/b1` | 0.0004 | 0.0004 | 0.0002 |
| `lu/n64/b1` | 0.0319 | 0.0319 | 0.0364 |
| `lu/n8/b1` | 0.0007 | 0.0007 | 0.0005 |
| `qr/n16/b1` | 0.0063 | 0.0066 | 0.0085 |
| `qr/n32/b1` | 0.0424 | 0.0421 | 0.0305 |
| `qr/n4/b1` | 0.0007 | 0.0008 | 0.0013 |
| `qr/n64/b1` | 0.1998 | 0.2000 | 0.1459 |
| `qr/n8/b1` | 0.0016 | 0.0017 | 0.0029 |
| `qr_factor/n16/b1` | 0.0032 | 0.0034 | 0.0053 |
| `qr_factor/n32/b1` | 0.0201 | 0.0201 | 0.0176 |
| `qr_factor/n4/b1` | 0.0003 | 0.0003 | 0.0009 |
| `qr_factor/n64/b1` | 0.0978 | 0.0985 | 0.0790 |
| `qr_factor/n8/b1` | 0.0008 | 0.0009 | 0.0020 |
| `solve/n16/b1` | 0.0024 | 0.0023 | 0.0025 |
| `solve/n32/b1` | 0.0077 | 0.0077 | 0.0085 |
| `solve/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0329 | 0.0328 | 0.0388 |
| `solve/n8/b1` | 0.0009 | 0.0009 | 0.0008 |
| `svd_thin/n16/b1` | 0.0316 | 0.0317 | 0.0407 |
| `svd_thin/n32/b1` | 0.1408 | 0.1401 | 0.1347 |
| `svd_thin/n4/b1` | 0.0030 | 0.0030 | 0.0056 |
| `svd_thin/n64/b1` | 0.7547 | 0.7551 | 0.5757 |
| `svd_thin/n8/b1` | 0.0090 | 0.0089 | 0.0128 |
| `svd_values/n16/b1` | 0.0244 | 0.0244 | 0.0196 |
| `svd_values/n32/b1` | 0.0966 | 0.0959 | 0.0613 |
| `svd_values/n4/b1` | 0.0026 | 0.0025 | 0.0040 |
| `svd_values/n64/b1` | 0.3762 | 0.3768 | 0.2604 |
| `svd_values/n8/b1` | 0.0074 | 0.0074 | 0.0077 |
| `triangular_solve/n16/b1` | 0.0003 | 0.0003 | - |
| `triangular_solve/n32/b1` | 0.0007 | 0.0007 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0017 | 0.0017 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0008 | 0.0008 | 0.0009 |
| `cholesky/n32/b1` | 0.0029 | 0.0030 | 0.0035 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0173 | 0.0176 | 0.0233 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0191 | 0.0192 | 0.0309 |
| `eigh/n32/b1` | 0.0854 | 0.0850 | 0.0819 |
| `eigh/n4/b1` | 0.0019 | 0.0019 | 0.0028 |
| `eigh/n64/b1` | 0.3823 | 0.3833 | 0.3400 |
| `eigh/n8/b1` | 0.0054 | 0.0054 | 0.0079 |
| `full_piv_lu/n16/b1` | 0.0025 | 0.0025 | - |
| `full_piv_lu/n32/b1` | 0.0096 | 0.0096 | - |
| `full_piv_lu/n4/b1` | 0.0005 | 0.0005 | - |
| `full_piv_lu/n64/b1` | 0.0547 | 0.0548 | - |
| `full_piv_lu/n8/b1` | 0.0009 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0098 | 0.0098 | - |
| `householder_apply/n32/b1` | 0.0401 | 0.0442 | - |
| `householder_apply/n4/b1` | 0.0013 | 0.0013 | - |
| `householder_apply/n64/b1` | 0.1732 | 0.3223 | - |
| `householder_apply/n8/b1` | 0.0027 | 0.0028 | - |
| `lu/n16/b1` | 0.0020 | 0.0020 | 0.0021 |
| `lu/n32/b1` | 0.0072 | 0.0071 | 0.0076 |
| `lu/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `lu/n64/b1` | 0.0321 | 0.0321 | 0.0362 |
| `lu/n8/b1` | 0.0007 | 0.0007 | 0.0006 |
| `qr/n16/b1` | 0.0066 | 0.0066 | 0.0085 |
| `qr/n32/b1` | 0.0407 | 0.0860 | 0.0305 |
| `qr/n4/b1` | 0.0008 | 0.0008 | 0.0013 |
| `qr/n64/b1` | 0.1924 | 0.4058 | 0.1473 |
| `qr/n8/b1` | 0.0016 | 0.0017 | 0.0029 |
| `qr_factor/n16/b1` | 0.0031 | 0.0033 | 0.0054 |
| `qr_factor/n32/b1` | 0.0201 | 0.0531 | 0.0177 |
| `qr_factor/n4/b1` | 0.0003 | 0.0003 | 0.0009 |
| `qr_factor/n64/b1` | 0.0935 | 0.3036 | 0.0791 |
| `qr_factor/n8/b1` | 0.0008 | 0.0009 | 0.0019 |
| `solve/n16/b1` | 0.0025 | 0.0024 | 0.0026 |
| `solve/n32/b1` | 0.0079 | 0.0078 | 0.0085 |
| `solve/n4/b1` | 0.0004 | 0.0005 | 0.0003 |
| `solve/n64/b1` | 0.0331 | 0.0330 | 0.0388 |
| `solve/n8/b1` | 0.0009 | 0.0009 | 0.0008 |
| `svd_thin/n16/b1` | 0.0316 | 0.0317 | 0.0408 |
| `svd_thin/n32/b1` | 0.1403 | 0.1398 | 0.1356 |
| `svd_thin/n4/b1` | 0.0031 | 0.0030 | 0.0057 |
| `svd_thin/n64/b1` | 0.7329 | 0.7385 | 0.5643 |
| `svd_thin/n8/b1` | 0.0092 | 0.0090 | 0.0129 |
| `svd_values/n16/b1` | 0.0245 | 0.0244 | 0.0198 |
| `svd_values/n32/b1` | 0.0959 | 0.0957 | 0.0612 |
| `svd_values/n4/b1` | 0.0026 | 0.0025 | 0.0041 |
| `svd_values/n64/b1` | 0.3745 | 0.3758 | 0.2601 |
| `svd_values/n8/b1` | 0.0074 | 0.0073 | 0.0077 |
| `triangular_solve/n16/b1` | 0.0003 | 0.0003 | - |
| `triangular_solve/n32/b1` | 0.0007 | 0.0007 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0017 | 0.0017 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

## linalg-small, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n16/b1` | 0.0008 | 0.0008 | 0.0010 |
| `cholesky/n32/b1` | 0.0030 | 0.0031 | 0.0035 |
| `cholesky/n4/b1` | 0.0002 | 0.0002 | 0.0002 |
| `cholesky/n64/b1` | 0.0173 | 0.0179 | 0.0221 |
| `cholesky/n8/b1` | 0.0003 | 0.0003 | 0.0003 |
| `eigh/n16/b1` | 0.0191 | 0.0190 | 0.0313 |
| `eigh/n32/b1` | 0.0860 | 0.0854 | 0.0809 |
| `eigh/n4/b1` | 0.0019 | 0.0019 | 0.0028 |
| `eigh/n64/b1` | 0.3870 | 0.3878 | 0.3337 |
| `eigh/n8/b1` | 0.0054 | 0.0054 | 0.0080 |
| `full_piv_lu/n16/b1` | 0.0026 | 0.0024 | - |
| `full_piv_lu/n32/b1` | 0.0095 | 0.0096 | - |
| `full_piv_lu/n4/b1` | 0.0004 | 0.0005 | - |
| `full_piv_lu/n64/b1` | 0.0546 | 0.0548 | - |
| `full_piv_lu/n8/b1` | 0.0009 | 0.0008 | - |
| `householder_apply/n16/b1` | 0.0098 | 0.0099 | - |
| `householder_apply/n32/b1` | 0.0402 | 0.0478 | - |
| `householder_apply/n4/b1` | 0.0013 | 0.0013 | - |
| `householder_apply/n64/b1` | 0.1773 | 0.4415 | - |
| `householder_apply/n8/b1` | 0.0028 | 0.0027 | - |
| `lu/n16/b1` | 0.0020 | 0.0019 | 0.0021 |
| `lu/n32/b1` | 0.0071 | 0.0071 | 0.0076 |
| `lu/n4/b1` | 0.0004 | 0.0004 | 0.0003 |
| `lu/n64/b1` | 0.0319 | 0.0318 | 0.0361 |
| `lu/n8/b1` | 0.0007 | 0.0007 | 0.0006 |
| `qr/n16/b1` | 0.0065 | 0.0066 | 0.0084 |
| `qr/n32/b1` | 0.0410 | 0.1111 | 0.0307 |
| `qr/n4/b1` | 0.0007 | 0.0008 | 0.0013 |
| `qr/n64/b1` | 0.1991 | 0.5595 | 0.1467 |
| `qr/n8/b1` | 0.0016 | 0.0017 | 0.0029 |
| `qr_factor/n16/b1` | 0.0031 | 0.0034 | 0.0053 |
| `qr_factor/n32/b1` | 0.0201 | 0.0805 | 0.0176 |
| `qr_factor/n4/b1` | 0.0003 | 0.0003 | 0.0009 |
| `qr_factor/n64/b1` | 0.0968 | 0.4165 | 0.0793 |
| `qr_factor/n8/b1` | 0.0008 | 0.0009 | 0.0020 |
| `solve/n16/b1` | 0.0024 | 0.0024 | 0.0025 |
| `solve/n32/b1` | 0.0077 | 0.0077 | 0.0084 |
| `solve/n4/b1` | 0.0005 | 0.0004 | 0.0003 |
| `solve/n64/b1` | 0.0329 | 0.0328 | 0.0385 |
| `solve/n8/b1` | 0.0009 | 0.0009 | 0.0008 |
| `svd_thin/n16/b1` | 0.0316 | 0.0313 | 0.0407 |
| `svd_thin/n32/b1` | 0.1403 | 0.1398 | 0.1350 |
| `svd_thin/n4/b1` | 0.0031 | 0.0030 | 0.0056 |
| `svd_thin/n64/b1` | 0.7555 | 0.7539 | 0.5640 |
| `svd_thin/n8/b1` | 0.0090 | 0.0089 | 0.0129 |
| `svd_values/n16/b1` | 0.0247 | 0.0244 | 0.0197 |
| `svd_values/n32/b1` | 0.0966 | 0.0961 | 0.0616 |
| `svd_values/n4/b1` | 0.0026 | 0.0025 | 0.0041 |
| `svd_values/n64/b1` | 0.3788 | 0.3786 | 0.2581 |
| `svd_values/n8/b1` | 0.0074 | 0.0073 | 0.0077 |
| `triangular_solve/n16/b1` | 0.0003 | 0.0003 | - |
| `triangular_solve/n32/b1` | 0.0007 | 0.0007 | - |
| `triangular_solve/n4/b1` | 0.0001 | 0.0001 | - |
| `triangular_solve/n64/b1` | 0.0017 | 0.0017 | - |
| `triangular_solve/n8/b1` | 0.0001 | 0.0001 | - |

Not applicable to this population's shapes and reported as skipped: `eig/16`, `eig/32`, `eig/4`, `eig/64`, `eig/8`, `full_piv_lu/16`, `full_piv_lu/32`, `full_piv_lu/4`, `full_piv_lu/64`, `full_piv_lu/8`, `householder_apply/16`, `householder_apply/32`, `householder_apply/4`, `householder_apply/64`, `householder_apply/8`, `triangular_solve/16`, `triangular_solve/32`, `triangular_solve/4`, `triangular_solve/64`, `triangular_solve/8`, `upgrade_factor/16`, `upgrade_factor/32`, `upgrade_factor/4`, `upgrade_factor/64`, `upgrade_factor/8`.

## linalg-medium, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.2516 | 0.2629 | 0.6485 |
| `eigh/n256/b1` | 6.2727 | 6.2679 | 6.2189 |
| `full_piv_lu/n256/b1` | 2.0248 | 2.0467 | - |
| `householder_apply/n256/b1` | 3.4564 | 3.7926 | - |
| `lu/n256/b1` | 1.1608 | 0.9028 | 1.1175 |
| `qr/n256/b1` | 2.4101 | 2.4199 | 3.0123 |
| `qr_factor/n256/b1` | 1.5021 | 1.7708 | 1.4738 |
| `solve/n256/b1` | 0.9385 | 0.9260 | 0.7925 |
| `svd_thin/n256/b1` | 12.0426 | 12.0317 | 11.8830 |
| `svd_values/n256/b1` | 7.6909 | 7.6934 | 4.8909 |
| `triangular_solve/n256/b1` | 0.0069 | 0.0069 | - |

## linalg-medium, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.2474 | 0.2248 | 0.5140 |
| `eigh/n256/b1` | 4.9555 | 4.9698 | 3.6512 |
| `full_piv_lu/n256/b1` | 1.8075 | 1.8035 | - |
| `householder_apply/n256/b1` | 2.1177 | 3.7665 | - |
| `lu/n256/b1` | 0.6514 | 0.7162 | 0.6510 |
| `qr/n256/b1` | 1.3863 | 2.4746 | 2.0865 |
| `qr_factor/n256/b1` | 1.6402 | 3.3004 | 1.0598 |
| `solve/n256/b1` | 0.6362 | 0.6771 | 0.4755 |
| `svd_thin/n256/b1` | 8.1822 | 8.1562 | 8.9705 |
| `svd_values/n256/b1` | 6.4898 | 6.4726 | 4.5848 |
| `triangular_solve/n256/b1` | 0.0073 | 0.0072 | - |

## linalg-medium, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.2373 | 0.2485 | 0.5378 |
| `eigh/n256/b1` | 4.2904 | 4.2912 | 3.4328 |
| `full_piv_lu/n256/b1` | 1.9311 | 1.9276 | - |
| `householder_apply/n256/b1` | 2.1435 | 4.5709 | - |
| `lu/n256/b1` | 0.6523 | 0.8153 | 0.6048 |
| `qr/n256/b1` | 1.5778 | 3.4460 | 2.0432 |
| `qr_factor/n256/b1` | 1.6838 | 4.1441 | 1.0389 |
| `solve/n256/b1` | 0.6442 | 0.7072 | 0.4500 |
| `svd_thin/n256/b1` | 8.3231 | 8.3632 | 8.9950 |
| `svd_values/n256/b1` | 6.5804 | 6.5845 | 4.5752 |
| `triangular_solve/n256/b1` | 0.0060 | 0.0058 | - |

## linalg-medium, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.2370 | 0.2300 | 0.2749 |
| `eigh/n256/b1` | 6.2189 | 6.2407 | 5.8662 |
| `full_piv_lu/n256/b1` | 1.8903 | 1.9049 | - |
| `householder_apply/n256/b1` | 2.9822 | 3.0703 | - |
| `lu/n256/b1` | 0.7801 | 0.7843 | 0.5683 |
| `qr/n256/b1` | 2.3238 | 2.3468 | 2.5419 |
| `qr_factor/n256/b1` | 0.8680 | 0.8738 | 1.2951 |
| `solve/n256/b1` | 0.7843 | 0.7672 | 0.5650 |
| `svd_thin/n256/b1` | 11.9454 | 11.9109 | 11.4240 |
| `svd_values/n256/b1` | 7.5792 | 7.5655 | 4.7309 |
| `triangular_solve/n256/b1` | 0.0074 | 0.0075 | - |

## linalg-medium, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.1978 | 0.2019 | 0.1668 |
| `eigh/n256/b1` | 4.9467 | 4.9792 | 3.3780 |
| `full_piv_lu/n256/b1` | 1.7232 | 1.7242 | - |
| `householder_apply/n256/b1` | 1.3198 | 2.3584 | - |
| `lu/n256/b1` | 0.5650 | 0.6395 | 0.3038 |
| `qr/n256/b1` | 1.2948 | 2.2557 | 1.7189 |
| `qr_factor/n256/b1` | 0.8043 | 1.8460 | 0.8837 |
| `solve/n256/b1` | 0.5552 | 0.5920 | 0.2930 |
| `svd_thin/n256/b1` | 8.1018 | 8.0937 | 8.5701 |
| `svd_values/n256/b1` | 6.3920 | 6.3909 | 4.3897 |
| `triangular_solve/n256/b1` | 0.0084 | 0.0083 | - |

## linalg-medium, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.2327 | 0.2229 | 0.1645 |
| `eigh/n256/b1` | 4.2614 | 4.2332 | 3.1614 |
| `full_piv_lu/n256/b1` | 1.8407 | 1.8312 | - |
| `householder_apply/n256/b1` | 1.3046 | 3.0473 | - |
| `lu/n256/b1` | 0.5778 | 0.7154 | 0.2653 |
| `qr/n256/b1` | 1.4919 | 3.2879 | 1.7111 |
| `qr_factor/n256/b1` | 0.8809 | 2.7073 | 0.8782 |
| `solve/n256/b1` | 0.5527 | 0.6111 | 0.2676 |
| `svd_thin/n256/b1` | 8.3217 | 8.2954 | 8.5663 |
| `svd_values/n256/b1` | 6.4736 | 6.5026 | 4.4663 |
| `triangular_solve/n256/b1` | 0.0066 | 0.0066 | - |

## linalg-medium, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.9568 | 0.9009 | 1.4499 |
| `eigh/n256/b1` | 11.7967 | 11.8503 | 17.4826 |
| `full_piv_lu/n256/b1` | 5.6989 | 5.5887 | - |
| `householder_apply/n256/b1` | 10.1900 | 10.5346 | - |
| `lu/n256/b1` | 1.7082 | 1.6872 | 2.0125 |
| `qr/n256/b1` | 7.7653 | 7.8043 | 7.8472 |
| `qr_factor/n256/b1` | 3.9521 | 4.3329 | 3.9113 |
| `solve/n256/b1` | 1.6927 | 1.7977 | 2.0182 |
| `svd_thin/n256/b1` | 25.0832 | 25.3158 | 29.4131 |
| `svd_values/n256/b1` | 15.0346 | 15.0780 | 14.4018 |
| `triangular_solve/n256/b1` | 0.0197 | 0.0199 | - |

## linalg-medium, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.5118 | 0.5217 | 0.8447 |
| `eigh/n256/b1` | 8.0894 | 7.8009 | 7.2865 |
| `full_piv_lu/n256/b1` | 3.6185 | 3.6203 | - |
| `householder_apply/n256/b1` | 4.3446 | 5.9014 | - |
| `lu/n256/b1` | 1.3769 | 1.0285 | 1.0265 |
| `qr/n256/b1` | 2.7717 | 3.6592 | 4.2360 |
| `qr_factor/n256/b1` | 2.6535 | 4.3883 | 2.2157 |
| `solve/n256/b1` | 1.3519 | 0.9467 | 1.0137 |
| `svd_thin/n256/b1` | 13.5807 | 13.9024 | 14.2364 |
| `svd_values/n256/b1` | 10.0456 | 10.0491 | 7.3360 |
| `triangular_solve/n256/b1` | 0.0142 | 0.0142 | - |

## linalg-medium, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.5279 | 0.5309 | 0.8144 |
| `eigh/n256/b1` | 7.1266 | 6.9215 | 6.6425 |
| `full_piv_lu/n256/b1` | 3.6238 | 3.6518 | - |
| `householder_apply/n256/b1` | 4.0371 | 6.3093 | - |
| `lu/n256/b1` | 1.3757 | 1.0345 | 0.8670 |
| `qr/n256/b1` | 2.5495 | 4.1846 | 4.0266 |
| `qr_factor/n256/b1` | 2.6360 | 5.1436 | 2.0473 |
| `solve/n256/b1` | 1.3235 | 0.9368 | 0.7967 |
| `svd_thin/n256/b1` | 14.3287 | 13.8201 | 13.2908 |
| `svd_values/n256/b1` | 11.0693 | 11.4184 | 7.2942 |
| `triangular_solve/n256/b1` | 0.0143 | 0.0143 | - |

## linalg-medium, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.8505 | 0.8647 | 0.9037 |
| `eigh/n256/b1` | 11.7194 | 11.7578 | 16.9577 |
| `full_piv_lu/n256/b1` | 5.3587 | 5.2421 | - |
| `householder_apply/n256/b1` | 9.5714 | 9.6161 | - |
| `lu/n256/b1` | 1.6056 | 1.6164 | 1.7216 |
| `qr/n256/b1` | 7.5262 | 7.5636 | 7.0434 |
| `qr_factor/n256/b1` | 3.1332 | 3.2309 | 3.5605 |
| `solve/n256/b1` | 1.6479 | 1.6608 | 1.7352 |
| `svd_thin/n256/b1` | 24.5909 | 25.1941 | 27.6416 |
| `svd_values/n256/b1` | 14.7489 | 14.8063 | 13.6475 |
| `triangular_solve/n256/b1` | 0.0236 | 0.0257 | - |

## linalg-medium, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.4585 | 0.4640 | 0.3886 |
| `eigh/n256/b1` | 7.9474 | 7.9734 | 6.8677 |
| `full_piv_lu/n256/b1` | 3.4656 | 3.4726 | - |
| `householder_apply/n256/b1` | 3.3286 | 4.1918 | - |
| `lu/n256/b1` | 1.2372 | 0.9133 | 0.7705 |
| `qr/n256/b1` | 2.6879 | 3.5805 | 3.7190 |
| `qr_factor/n256/b1` | 1.6738 | 2.5528 | 1.9114 |
| `solve/n256/b1` | 1.2089 | 0.8323 | 0.7584 |
| `svd_thin/n256/b1` | 13.8006 | 13.8643 | 13.4874 |
| `svd_values/n256/b1` | 9.9482 | 9.9513 | 7.0268 |
| `triangular_solve/n256/b1` | 0.0140 | 0.0138 | - |

## linalg-medium, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n256/b1` | 0.4625 | 0.4797 | 0.3278 |
| `eigh/n256/b1` | 7.1634 | 6.8766 | 6.2162 |
| `full_piv_lu/n256/b1` | 3.4605 | 3.4688 | - |
| `householder_apply/n256/b1` | 2.9745 | 4.4161 | - |
| `lu/n256/b1` | 1.2410 | 0.9078 | 0.5357 |
| `qr/n256/b1` | 2.4299 | 4.1232 | 3.3518 |
| `qr_factor/n256/b1` | 1.6081 | 3.2517 | 1.7316 |
| `solve/n256/b1` | 1.2152 | 0.8223 | 0.5405 |
| `svd_thin/n256/b1` | 13.8345 | 13.6273 | 12.5712 |
| `svd_values/n256/b1` | 11.1089 | 10.5092 | 6.9604 |
| `triangular_solve/n256/b1` | 0.0132 | 0.0134 | - |

Not applicable to this population's shapes and reported as skipped: `eig/256`, `full_piv_lu/256`, `householder_apply/256`, `triangular_solve/256`, `upgrade_factor/256`.

## linalg-large, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.5136 | 1.5105 | 3.5977 |
| `eigh/n512/b1` | 29.4381 | 29.4586 | 31.3161 |
| `full_piv_lu/n512/b1` | 13.6218 | 13.6574 | - |
| `lu/n512/b1` | 6.1367 | 4.4553 | 5.0651 |
| `qr/n512/b1` | 12.9162 | 12.9341 | 17.8581 |
| `qr_factor/n512/b1` | 9.4445 | 10.4972 | 9.3446 |
| `solve/n512/b1` | 4.3637 | 4.3005 | 4.2333 |
| `svd_thin/n512/b1` | 64.0969 | 64.1550 | 72.3848 |
| `svd_values/n512/b1` | 40.3198 | 40.3206 | 32.7074 |
| `triangular_solve/n512/b1` | 0.0232 | 0.0231 | - |

## linalg-large, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 0.9707 | 1.0252 | 2.7994 |
| `eigh/n512/b1` | 16.9028 | 16.9212 | 17.3711 |
| `full_piv_lu/n512/b1` | 10.9320 | 10.9478 | - |
| `lu/n512/b1` | 4.6537 | 4.9079 | 3.4981 |
| `qr/n512/b1` | 6.9993 | 9.1896 | 11.3472 |
| `qr_factor/n512/b1` | 9.8093 | 18.9782 | 5.9462 |
| `solve/n512/b1` | 3.2889 | 3.3458 | 2.6848 |
| `svd_thin/n512/b1` | 38.3169 | 38.1252 | 56.1098 |
| `svd_values/n512/b1` | 29.3694 | 29.2982 | 30.3755 |
| `triangular_solve/n512/b1` | 0.0207 | 0.0207 | - |

## linalg-large, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.0136 | 0.9865 | 2.7148 |
| `eigh/n512/b1` | 15.9229 | 15.8301 | 15.1275 |
| `full_piv_lu/n512/b1` | 11.1329 | 11.0809 | - |
| `lu/n512/b1` | 4.5857 | 5.0859 | 3.0715 |
| `qr/n512/b1` | 6.4709 | 9.8524 | 10.3709 |
| `qr_factor/n512/b1` | 9.8112 | 20.9710 | 7.3188 |
| `solve/n512/b1` | 3.2058 | 3.5124 | 2.1856 |
| `svd_thin/n512/b1` | 37.1404 | 37.7342 | 52.2784 |
| `svd_values/n512/b1` | 29.5346 | 30.0548 | 29.3999 |
| `triangular_solve/n512/b1` | 0.0249 | 0.0247 | - |

## linalg-large, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.2490 | 1.2477 | 1.6234 |
| `eigh/n512/b1` | 29.1053 | 29.2417 | 30.0616 |
| `full_piv_lu/n512/b1` | 12.9833 | 12.9647 | - |
| `lu/n512/b1` | 3.8436 | 3.8344 | 3.1321 |
| `qr/n512/b1` | 12.1630 | 12.1887 | 14.8988 |
| `qr_factor/n512/b1` | 4.7768 | 4.8027 | 7.5187 |
| `solve/n512/b1` | 3.6794 | 3.6828 | 3.0708 |
| `svd_thin/n512/b1` | 63.5807 | 63.4942 | 70.3757 |
| `svd_values/n512/b1` | 39.6027 | 39.5613 | 31.8133 |
| `triangular_solve/n512/b1` | 0.0258 | 0.0258 | - |

## linalg-large, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 0.7147 | 0.7344 | 0.7929 |
| `eigh/n512/b1` | 16.8031 | 16.7267 | 15.7962 |
| `full_piv_lu/n512/b1` | 10.3016 | 10.3410 | - |
| `lu/n512/b1` | 2.8045 | 2.9604 | 1.5971 |
| `qr/n512/b1` | 6.3210 | 8.4290 | 9.1729 |
| `qr_factor/n512/b1` | 2.9353 | 5.0993 | 4.6175 |
| `solve/n512/b1` | 2.6371 | 2.6975 | 1.5496 |
| `svd_thin/n512/b1` | 37.9347 | 37.2015 | 53.9456 |
| `svd_values/n512/b1` | 28.5415 | 28.9662 | 29.4997 |
| `triangular_solve/n512/b1` | 0.0253 | 0.0241 | - |

## linalg-large, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 0.7382 | 0.7127 | 0.7310 |
| `eigh/n512/b1` | 15.1629 | 15.3196 | 13.4920 |
| `full_piv_lu/n512/b1` | 10.3858 | 10.3322 | - |
| `lu/n512/b1` | 2.7072 | 3.0232 | 1.0562 |
| `qr/n512/b1` | 6.0736 | 9.1605 | 8.1820 |
| `qr_factor/n512/b1` | 3.0690 | 6.3422 | 4.1737 |
| `solve/n512/b1` | 2.5669 | 2.8178 | 1.0408 |
| `svd_thin/n512/b1` | 36.9551 | 37.4022 | 50.2366 |
| `svd_values/n512/b1` | 29.5598 | 29.4240 | 28.3374 |
| `triangular_solve/n512/b1` | 0.0281 | 0.0276 | - |

## linalg-large, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 4.7649 | 4.7710 | 7.5705 |
| `eigh/n512/b1` | 63.6985 | 63.7034 | 85.2051 |
| `full_piv_lu/n512/b1` | 24.7532 | 24.8067 | - |
| `lu/n512/b1` | 9.2072 | 9.1997 | 11.2919 |
| `qr/n512/b1` | 42.4262 | 42.4937 | 45.0933 |
| `qr_factor/n512/b1` | 21.3845 | 22.6939 | 22.7523 |
| `solve/n512/b1` | 9.2872 | 9.2692 | 11.4087 |
| `svd_thin/n512/b1` | 128.9514 | 129.0897 | 143.7621 |
| `svd_values/n512/b1` | 66.9322 | 67.6030 | 60.5039 |
| `triangular_solve/n512/b1` | 0.0527 | 0.0525 | - |

## linalg-large, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 2.0668 | 2.0783 | 4.2407 |
| `eigh/n512/b1` | 29.8520 | 29.8105 | 34.0724 |
| `full_piv_lu/n512/b1` | 16.9738 | 16.9294 | - |
| `lu/n512/b1` | 5.2343 | 4.7903 | 4.6005 |
| `qr/n512/b1` | 14.3136 | 16.5424 | 20.9086 |
| `qr_factor/n512/b1` | 12.7971 | 16.2986 | 10.6113 |
| `solve/n512/b1` | 5.2445 | 4.7062 | 4.5655 |
| `svd_thin/n512/b1` | 60.9691 | 60.7189 | 72.7300 |
| `svd_values/n512/b1` | 40.0968 | 40.1097 | 32.8646 |
| `triangular_solve/n512/b1` | 0.0424 | 0.0424 | - |

## linalg-large, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.7435 | 1.7371 | 3.6096 |
| `eigh/n512/b1` | 25.6588 | 25.8926 | 26.4943 |
| `full_piv_lu/n512/b1` | 15.9549 | 16.0082 | - |
| `lu/n512/b1` | 4.5928 | 4.0995 | 3.1852 |
| `qr/n512/b1` | 11.3372 | 14.4488 | 16.7835 |
| `qr_factor/n512/b1` | 12.0409 | 16.4874 | 8.5089 |
| `solve/n512/b1` | 4.5629 | 4.0082 | 3.1803 |
| `svd_thin/n512/b1` | 52.8151 | 51.6338 | 61.7607 |
| `svd_values/n512/b1` | 37.6964 | 37.7735 | 29.5744 |
| `triangular_solve/n512/b1` | 0.0426 | 0.0408 | - |

## linalg-large, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 4.5523 | 4.5484 | 5.5289 |
| `eigh/n512/b1` | 63.4873 | 63.4987 | 83.8496 |
| `full_piv_lu/n512/b1` | 24.1263 | 24.1347 | - |
| `lu/n512/b1` | 8.5609 | 8.5549 | 9.8656 |
| `qr/n512/b1` | 41.7736 | 41.7499 | 42.5230 |
| `qr_factor/n512/b1` | 17.3631 | 17.4596 | 21.4189 |
| `solve/n512/b1` | 8.6420 | 8.6272 | 10.0738 |
| `svd_thin/n512/b1` | 128.0264 | 128.2462 | 140.2074 |
| `svd_values/n512/b1` | 66.9555 | 67.2082 | 58.5989 |
| `triangular_solve/n512/b1` | 0.0569 | 0.0577 | - |

## linalg-large, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.8742 | 1.8838 | 2.1451 |
| `eigh/n512/b1` | 29.8666 | 29.9083 | 32.5466 |
| `full_piv_lu/n512/b1` | 16.3844 | 16.1946 | - |
| `lu/n512/b1` | 4.6103 | 4.1146 | 3.3366 |
| `qr/n512/b1` | 13.7749 | 15.8981 | 18.3538 |
| `qr_factor/n512/b1` | 6.7601 | 8.8655 | 9.4013 |
| `solve/n512/b1` | 4.6203 | 4.0884 | 3.3780 |
| `svd_thin/n512/b1` | 60.5663 | 59.1489 | 69.0645 |
| `svd_values/n512/b1` | 39.5888 | 39.4769 | 31.6094 |
| `triangular_solve/n512/b1` | 0.0453 | 0.0457 | - |

## linalg-large, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `cholesky/n512/b1` | 1.5266 | 1.5386 | 1.4767 |
| `eigh/n512/b1` | 25.2869 | 25.3112 | 24.6344 |
| `full_piv_lu/n512/b1` | 15.2079 | 15.2339 | - |
| `lu/n512/b1` | 3.9804 | 3.4853 | 2.0271 |
| `qr/n512/b1` | 10.7349 | 13.7695 | 14.4122 |
| `qr_factor/n512/b1` | 6.1812 | 9.2279 | 7.3919 |
| `solve/n512/b1` | 4.0032 | 3.3974 | 2.0193 |
| `svd_thin/n512/b1` | 50.9776 | 51.4573 | 57.1222 |
| `svd_values/n512/b1` | 37.1781 | 37.3173 | 27.9920 |
| `triangular_solve/n512/b1` | 0.0458 | 0.0453 | - |

Not applicable to this population's shapes and reported as skipped: `full_piv_lu/512`, `triangular_solve/512`.

## linalg-tall, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 1.4723 | 1.4966 | - |
| `householder_apply/4096x256/b1` | 70.2549 | 70.9722 | - |
| `qr/1024x64/b1` | 7.1711 | 7.1711 | 1.5626 |
| `qr/4096x256/b1` | 489.6954 | 491.7385 | 61.0359 |
| `qr_factor/1024x64/b1` | 1.5444 | 1.5709 | 0.9610 |
| `qr_factor/4096x256/b1` | 63.6559 | 48.1748 | 31.0848 |
| `svd_thin/1024x64/b1` | 1.5049 | 1.5017 | 2.2931 |
| `svd_thin/4096x256/b1` | 55.9096 | 55.9001 | 90.0107 |
| `svd_values/1024x64/b1` | 0.8903 | 0.8872 | 1.1990 |
| `svd_values/4096x256/b1` | 27.8852 | 27.9714 | 40.4793 |

## linalg-tall, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 2.2885 | 2.4847 | - |
| `householder_apply/4096x256/b1` | 72.9343 | 78.2586 | - |
| `qr/1024x64/b1` | 2.5012 | 2.8173 | 1.6155 |
| `qr/4096x256/b1` | 162.0453 | 161.5976 | 38.6600 |
| `qr_factor/1024x64/b1` | 2.6844 | 3.1680 | 0.9820 |
| `qr_factor/4096x256/b1` | 59.8548 | 64.2307 | 19.2258 |
| `svd_thin/1024x64/b1` | 1.4488 | 1.7012 | 2.2141 |
| `svd_thin/4096x256/b1` | 31.3854 | 32.7366 | 58.2098 |
| `svd_values/1024x64/b1` | 1.0073 | 1.2619 | 1.2401 |
| `svd_values/4096x256/b1` | 20.0475 | 22.1630 | 32.9292 |

## linalg-tall, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 2.3742 | 3.9020 | - |
| `householder_apply/4096x256/b1` | 68.6626 | 75.7237 | - |
| `qr/1024x64/b1` | 1.9980 | 2.4723 | 1.6235 |
| `qr/4096x256/b1` | 118.6426 | 128.3960 | 36.7618 |
| `qr_factor/1024x64/b1` | 2.8555 | 3.6384 | 0.9902 |
| `qr_factor/4096x256/b1` | 57.9796 | 64.7653 | 18.7183 |
| `svd_thin/1024x64/b1` | 1.5234 | 1.9264 | 2.2051 |
| `svd_thin/4096x256/b1` | 27.3256 | 32.2175 | 46.5794 |
| `svd_values/1024x64/b1` | 1.0927 | 1.5084 | 1.2256 |
| `svd_values/4096x256/b1` | 18.8101 | 23.5744 | 27.8195 |

## linalg-tall, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 0.8858 | 0.8882 | - |
| `householder_apply/4096x256/b1` | 42.0704 | 42.0602 | - |
| `qr/1024x64/b1` | 7.0800 | 7.0932 | 1.1215 |
| `qr/4096x256/b1` | 487.7246 | 489.2499 | 47.1458 |
| `qr_factor/1024x64/b1` | 0.4735 | 0.4743 | 0.5853 |
| `qr_factor/4096x256/b1` | 15.8577 | 15.9075 | 24.0549 |
| `svd_thin/1024x64/b1` | 1.4713 | 1.4697 | 1.9514 |
| `svd_thin/4096x256/b1` | 52.1011 | 52.0008 | 73.2749 |
| `svd_values/1024x64/b1` | 0.8388 | 0.8401 | 0.9830 |
| `svd_values/4096x256/b1` | 24.0273 | 24.0616 | 33.6476 |

## linalg-tall, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 0.7416 | 1.0169 | - |
| `householder_apply/4096x256/b1` | 27.0615 | 31.9577 | - |
| `qr/1024x64/b1` | 2.4338 | 2.7060 | 1.1799 |
| `qr/4096x256/b1` | 155.5050 | 161.8509 | 24.2029 |
| `qr_factor/1024x64/b1` | 0.5493 | 0.8325 | 0.6273 |
| `qr_factor/4096x256/b1` | 8.5140 | 11.1041 | 12.9746 |
| `svd_thin/1024x64/b1` | 1.3985 | 1.6284 | 1.8583 |
| `svd_thin/4096x256/b1` | 27.1427 | 29.0389 | 40.5920 |
| `svd_values/1024x64/b1` | 0.9503 | 1.2283 | 1.0388 |
| `svd_values/4096x256/b1` | 16.2608 | 18.5163 | 21.6206 |

## linalg-tall, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 0.7886 | 1.2216 | - |
| `householder_apply/4096x256/b1` | 22.0563 | 27.8205 | - |
| `qr/1024x64/b1` | 1.9001 | 2.4065 | 1.1877 |
| `qr/4096x256/b1` | 115.3655 | 120.0460 | 22.2087 |
| `qr_factor/1024x64/b1` | 0.6410 | 1.0402 | 0.6333 |
| `qr_factor/4096x256/b1` | 7.3715 | 12.2378 | 11.2822 |
| `svd_thin/1024x64/b1` | 1.4903 | 1.8839 | 1.8622 |
| `svd_thin/4096x256/b1` | 23.9840 | 28.7350 | 36.8515 |
| `svd_values/1024x64/b1` | 1.0299 | 1.4546 | 1.0280 |
| `svd_values/4096x256/b1` | 15.2091 | 19.7523 | 20.7749 |

## linalg-tall, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 3.9514 | 3.9767 | - |
| `householder_apply/4096x256/b1` | 200.1965 | 200.8852 | - |
| `qr/1024x64/b1` | 25.9534 | 25.9860 | 2.6158 |
| `qr/4096x256/b1` | 1596.9629 | 1595.5673 | 164.0127 |
| `qr_factor/1024x64/b1` | 2.3532 | 2.3662 | 1.3611 |
| `qr_factor/4096x256/b1` | 107.5996 | 108.1468 | 82.6495 |
| `svd_thin/1024x64/b1` | 3.5931 | 3.6106 | 4.1985 |
| `svd_thin/4096x256/b1` | 176.5956 | 177.0984 | 242.1877 |
| `svd_values/1024x64/b1` | 1.8608 | 1.8565 | 1.8982 |
| `svd_values/4096x256/b1` | 76.2630 | 76.5808 | 98.4364 |

## linalg-tall, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 3.0262 | 2.9929 | - |
| `householder_apply/4096x256/b1` | 119.9507 | 144.8252 | - |
| `qr/1024x64/b1` | 8.0061 | 8.2543 | 1.3054 |
| `qr/4096x256/b1` | 478.1443 | 484.1140 | 77.4511 |
| `qr_factor/1024x64/b1` | 3.5453 | 2.7929 | 0.7038 |
| `qr_factor/4096x256/b1` | 76.9768 | 105.7388 | 42.8895 |
| `svd_thin/1024x64/b1` | 2.4238 | 2.6608 | 2.3239 |
| `svd_thin/4096x256/b1` | 75.0281 | 80.4175 | 99.0611 |
| `svd_values/1024x64/b1` | 1.5838 | 1.8611 | 1.2792 |
| `svd_values/4096x256/b1` | 42.9375 | 47.9283 | 59.7207 |

## linalg-tall, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 2.7836 | 3.2565 | - |
| `householder_apply/4096x256/b1` | 113.9484 | 123.1251 | - |
| `qr/1024x64/b1` | 5.4851 | 5.9765 | 1.1829 |
| `qr/4096x256/b1` | 315.8167 | 318.3203 | 60.8826 |
| `qr_factor/1024x64/b1` | 3.6516 | 4.1648 | 0.6440 |
| `qr_factor/4096x256/b1` | 90.4515 | 102.7312 | 35.5267 |
| `svd_thin/1024x64/b1` | 2.2669 | 2.8064 | 2.0066 |
| `svd_thin/4096x256/b1` | 60.4158 | 69.0839 | 76.0817 |
| `svd_values/1024x64/b1` | 1.5726 | 2.0267 | 1.1599 |
| `svd_values/4096x256/b1` | 38.2541 | 46.7674 | 51.5332 |

## linalg-tall, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 2.9069 | 2.9344 | - |
| `householder_apply/4096x256/b1` | 155.9883 | 156.2573 | - |
| `qr/1024x64/b1` | 25.5237 | 25.5485 | 2.1244 |
| `qr/4096x256/b1` | 1587.6288 | 1590.2330 | 140.9091 |
| `qr_factor/1024x64/b1` | 1.3587 | 1.3702 | 1.1180 |
| `qr_factor/4096x256/b1` | 54.8441 | 55.0784 | 71.8127 |
| `svd_thin/1024x64/b1` | 3.5314 | 3.5509 | 3.7683 |
| `svd_thin/4096x256/b1` | 168.3257 | 169.0775 | 216.4485 |
| `svd_values/1024x64/b1` | 1.7918 | 1.7807 | 1.6616 |
| `svd_values/4096x256/b1` | 68.2278 | 68.6191 | 86.2841 |

## linalg-tall, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 1.6630 | 1.9176 | - |
| `householder_apply/4096x256/b1` | 80.6328 | 65.8703 | - |
| `qr/1024x64/b1` | 7.7421 | 8.0675 | 0.8765 |
| `qr/4096x256/b1` | 470.1040 | 478.1154 | 45.8227 |
| `qr_factor/1024x64/b1` | 1.0516 | 1.2956 | 0.5117 |
| `qr_factor/4096x256/b1` | 23.1854 | 28.8721 | 23.5074 |
| `svd_thin/1024x64/b1` | 2.3502 | 2.5716 | 1.8804 |
| `svd_thin/4096x256/b1` | 67.5371 | 72.3008 | 86.9306 |
| `svd_values/1024x64/b1` | 1.5189 | 1.7665 | 1.0510 |
| `svd_values/4096x256/b1` | 35.6705 | 40.7303 | 36.1786 |

## linalg-tall, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `householder_apply/1024x64/b1` | 1.4849 | 1.9804 | - |
| `householder_apply/4096x256/b1` | 55.5057 | 65.1641 | - |
| `qr/1024x64/b1` | 5.3504 | 5.8314 | 0.6935 |
| `qr/4096x256/b1` | 305.8275 | 314.2339 | 31.4847 |
| `qr_factor/1024x64/b1` | 1.0580 | 1.4847 | 0.4243 |
| `qr_factor/4096x256/b1` | 17.6766 | 26.3721 | 16.5126 |
| `svd_thin/1024x64/b1` | 2.2371 | 2.7334 | 1.6237 |
| `svd_thin/4096x256/b1` | 52.3672 | 61.3935 | 64.3014 |
| `svd_values/1024x64/b1` | 1.5297 | 1.9690 | 0.9647 |
| `svd_values/4096x256/b1` | 31.3826 | 39.8228 | 28.3328 |

Not applicable to this population's shapes and reported as skipped: `cholesky/1024x64`, `cholesky/4096x256`, `eigh/1024x64`, `eigh/4096x256`, `full_piv_lu/1024x64`, `full_piv_lu/4096x256`, `householder_apply/1024x64`, `householder_apply/4096x256`, `lu/1024x64`, `lu/4096x256`, `solve/1024x64`, `solve/4096x256`, `triangular_solve/1024x64`, `triangular_solve/4096x256`, `upgrade_factor/1024x64`, `upgrade_factor/4096x256`.

## linalg-wide, f64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 21.0142 | 21.2935 | 41.3323 |
| `qr/64x1024/b1` | 0.5030 | 0.5047 | 1.1061 |
| `qr_factor/256x4096/b1` | 16.8530 | 17.4314 | 40.0444 |
| `qr_factor/64x1024/b1` | 0.8257 | 0.6047 | 1.0586 |
| `svd_thin/256x4096/b1` | 52.1022 | 52.0373 | 142.6803 |
| `svd_thin/64x1024/b1` | 1.4684 | 1.4686 | 3.0284 |
| `svd_values/256x4096/b1` | 23.9202 | 23.8749 | 66.7292 |
| `svd_values/64x1024/b1` | 0.8502 | 0.8487 | 1.5596 |

## linalg-wide, f64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 8.2242 | 9.2063 | 25.3913 |
| `qr/64x1024/b1` | 0.3041 | 0.4625 | 1.0446 |
| `qr_factor/256x4096/b1` | 6.5184 | 7.6631 | 23.8673 |
| `qr_factor/64x1024/b1` | 0.5523 | 0.7624 | 1.0068 |
| `svd_thin/256x4096/b1` | 26.9636 | 28.4285 | 97.0713 |
| `svd_thin/64x1024/b1` | 1.3814 | 1.6727 | 2.7892 |
| `svd_values/256x4096/b1` | 16.1695 | 18.5332 | 47.4155 |
| `svd_values/64x1024/b1` | 0.9465 | 1.2126 | 1.5455 |

## linalg-wide, f64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 7.0708 | 8.6410 | 22.9193 |
| `qr/64x1024/b1` | 0.3323 | 0.5472 | 0.9902 |
| `qr_factor/256x4096/b1` | 5.4053 | 7.1489 | 22.1680 |
| `qr_factor/64x1024/b1` | 0.5504 | 0.9392 | 1.0104 |
| `svd_thin/256x4096/b1` | 23.6641 | 28.3834 | 89.7655 |
| `svd_thin/64x1024/b1` | 1.4795 | 1.8505 | 2.7865 |
| `svd_values/256x4096/b1` | 15.1948 | 19.9596 | 45.9989 |
| `svd_values/64x1024/b1` | 1.0439 | 1.4946 | 1.5421 |

## linalg-wide, f64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 18.5146 | 18.7134 | 35.2579 |
| `qr/64x1024/b1` | 0.3767 | 0.3779 | 0.9012 |
| `qr_factor/256x4096/b1` | 16.3764 | 16.4687 | 34.7471 |
| `qr_factor/64x1024/b1` | 0.3371 | 0.3371 | 0.8682 |
| `svd_thin/256x4096/b1` | 56.0107 | 56.1455 | 124.2960 |
| `svd_thin/64x1024/b1` | 1.5043 | 1.5076 | 2.7793 |
| `svd_values/256x4096/b1` | 27.8955 | 27.7855 | 58.6367 |
| `svd_values/64x1024/b1` | 0.8845 | 0.8798 | 1.3521 |

## linalg-wide, f64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 5.4503 | 6.2114 | 18.9106 |
| `qr/64x1024/b1` | 0.1832 | 0.3393 | 0.7785 |
| `qr_factor/256x4096/b1` | 4.5769 | 5.4680 | 17.9570 |
| `qr_factor/64x1024/b1` | 0.1512 | 0.3001 | 0.8007 |
| `svd_thin/256x4096/b1` | 30.6412 | 32.6736 | 75.0451 |
| `svd_thin/64x1024/b1` | 1.4425 | 1.6889 | 2.4342 |
| `svd_values/256x4096/b1` | 19.7083 | 22.5677 | 39.2765 |
| `svd_values/64x1024/b1` | 0.9913 | 1.2530 | 1.3073 |

## linalg-wide, f64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 4.1814 | 5.2713 | 16.7549 |
| `qr/64x1024/b1` | 0.1958 | 0.4237 | 0.7960 |
| `qr_factor/256x4096/b1` | 3.3453 | 4.5023 | 15.9306 |
| `qr_factor/64x1024/b1` | 0.1486 | 0.3669 | 0.7647 |
| `svd_thin/256x4096/b1` | 27.8145 | 32.7750 | 72.6654 |
| `svd_thin/64x1024/b1` | 1.5421 | 1.9144 | 2.4748 |
| `svd_values/256x4096/b1` | 19.0062 | 23.3252 | 38.2542 |
| `svd_values/64x1024/b1` | 1.0803 | 1.5380 | 1.3202 |

## linalg-wide, c64, c order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 70.9386 | 71.7555 | 125.4438 |
| `qr/64x1024/b1` | 1.5380 | 1.5370 | 2.1270 |
| `qr_factor/256x4096/b1` | 61.1602 | 61.5305 | 122.2111 |
| `qr_factor/64x1024/b1` | 1.5457 | 1.5593 | 2.0484 |
| `svd_thin/256x4096/b1` | 168.5429 | 169.3091 | 435.8154 |
| `svd_thin/64x1024/b1` | 3.5553 | 3.5871 | 7.1597 |
| `svd_values/256x4096/b1` | 67.9730 | 68.2629 | 210.8083 |
| `svd_values/64x1024/b1` | 1.7666 | 1.7785 | 3.4045 |

## linalg-wide, c64, c order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 21.9455 | 22.9622 | 50.6854 |
| `qr/64x1024/b1` | 0.6141 | 0.8078 | 0.9139 |
| `qr_factor/256x4096/b1` | 17.7138 | 19.4617 | 48.1897 |
| `qr_factor/64x1024/b1` | 0.6183 | 0.7789 | 0.8333 |
| `svd_thin/256x4096/b1` | 68.2605 | 73.1422 | 275.0595 |
| `svd_thin/64x1024/b1` | 2.3394 | 2.6127 | 5.8819 |
| `svd_values/256x4096/b1` | 35.6598 | 40.8369 | 134.9218 |
| `svd_values/64x1024/b1` | 1.5069 | 1.7512 | 3.0341 |

## linalg-wide, c64, c order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 15.1321 | 16.9878 | 38.4232 |
| `qr/64x1024/b1` | 0.5842 | 0.8091 | 0.7726 |
| `qr_factor/256x4096/b1` | 12.0721 | 13.5732 | 36.2982 |
| `qr_factor/64x1024/b1` | 0.5529 | 0.8226 | 0.6995 |
| `svd_thin/256x4096/b1` | 52.7253 | 62.1818 | 245.4038 |
| `svd_thin/64x1024/b1` | 2.2514 | 2.7540 | 5.9513 |
| `svd_values/256x4096/b1` | 31.0629 | 39.3405 | 126.1300 |
| `svd_values/64x1024/b1` | 1.5173 | 1.9671 | 3.0730 |

## linalg-wide, c64, f order, 1T (CPU 4)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 68.8147 | 68.3520 | 105.1509 |
| `qr/64x1024/b1` | 1.4332 | 1.4345 | 1.8763 |
| `qr_factor/256x4096/b1` | 62.5479 | 62.7840 | 102.7083 |
| `qr_factor/64x1024/b1` | 1.3322 | 1.3349 | 1.8084 |
| `svd_thin/256x4096/b1` | 176.7212 | 178.0618 | 420.1908 |
| `svd_thin/64x1024/b1` | 3.6251 | 3.6596 | 6.8741 |
| `svd_values/256x4096/b1` | 75.8818 | 76.5161 | 185.3909 |
| `svd_values/64x1024/b1` | 1.8446 | 1.8541 | 3.1393 |

## linalg-wide, c64, f order, 4T (CPU 4-7)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 18.7541 | 19.7773 | 38.2196 |
| `qr/64x1024/b1` | 0.5274 | 0.6927 | 0.7082 |
| `qr_factor/256x4096/b1` | 16.2751 | 17.1427 | 36.0455 |
| `qr_factor/64x1024/b1` | 0.4194 | 0.5807 | 0.6415 |
| `svd_thin/256x4096/b1` | 75.6860 | 80.6441 | 248.6219 |
| `svd_thin/64x1024/b1` | 2.4526 | 2.6982 | 5.5826 |
| `svd_values/256x4096/b1` | 42.3042 | 48.1688 | 124.2063 |
| `svd_values/64x1024/b1` | 1.5584 | 1.8120 | 2.8280 |

## linalg-wide, c64, f order, 8T (CPU 4-11)

| case | faer-fork (ms) | faer-upstream (ms) | lapack-openblas (ms) |
|---|---|---|---|
| `qr/256x4096/b1` | 12.0759 | 13.2964 | 26.4287 |
| `qr/64x1024/b1` | 0.4701 | 0.6986 | 0.5491 |
| `qr_factor/256x4096/b1` | 10.2378 | 11.5787 | 24.7147 |
| `qr_factor/64x1024/b1` | 0.3590 | 0.6030 | 0.4791 |
| `svd_thin/256x4096/b1` | 60.8138 | 70.3669 | 222.3100 |
| `svd_thin/64x1024/b1` | 2.3175 | 2.8209 | 5.5775 |
| `svd_values/256x4096/b1` | 38.1014 | 46.6134 | 114.4248 |
| `svd_values/64x1024/b1` | 1.5629 | 2.0462 | 2.8472 |

Not applicable to this population's shapes and reported as skipped: `cholesky/256x4096`, `cholesky/64x1024`, `eigh/256x4096`, `eigh/64x1024`, `full_piv_lu/256x4096`, `full_piv_lu/64x1024`, `lu/256x4096`, `lu/64x1024`, `solve/256x4096`, `solve/64x1024`, `triangular_solve/256x4096`, `triangular_solve/64x1024`.

This run made a single complete set, so it carries no A/A: it is a scan, not a paired comparison.
