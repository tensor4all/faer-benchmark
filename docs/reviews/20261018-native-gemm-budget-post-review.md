## Files reviewed

Paths below are relative to `/tmp/faer-native-gemm-budget/`.

- `faer/src/linalg/matmul/mod.rs` — lines 1–63, 1160–1495, 1770–1849.
- `faer/src/linalg/matmul/triangular.rs` — lines 595–780, 1077–1136, 1246–1496.
- `faer/src/linalg/matmul/internal/mod.rs` — production routes through line 398; fixtures and changed tests through line 586.
- `faer/src/linalg/matmul/tests/native_threads.rs` — all 265 lines.
- Supporting evidence: `faer/src/lib.rs:927–957`, `faer/Cargo.toml:1–90`, and `docs/worklogs/2026-10-18-native-gemm-work-floor.md:1–52`.
- Read `/tmp/native-gemm-budget-post-bundle.md` completely, including every changed production/test line. Consulted scoped metadata/provenance portions of `/tmp/native-gemm-budget-origin.diff`.

## Status

**COMPLETE: all requested bounded focus areas traced** for candidate `7f713a1401f18546d1ef0c134df982be80626b2e` against base `b7715c5`.

This is a source-correctness and complexity review of the budget delta—not performance, adoption, or integration approval.

## Focus area verdicts

1. **Mathematical work-floor normalization: PASS.**
   For mathematical MAC count \(W\), the original intended FLOP condition is `2W >= 2threshold` for real and `8W >= 2threshold` for complex. These reduce exactly to `W >= threshold` and `W >= ceil(threshold/4)`, as implemented at `faer/src/linalg/matmul/mod.rs:30–36`.

   Saturating MAC multiplication preserves this comparison because the cutoff never exceeds `usize::MAX`. A subsequent zero factor correctly restores zero even after intermediate saturation. Threshold zero admits every work count, including zero; `div_ceil(4)` avoids overflowing a rounded-up numerator. Thus extreme cases follow the mathematical policy rather than reproducing the old expression’s overflow behavior. Tests cover configured boundaries, saturated products, zero factors, and independent wide-FLOP comparisons at `faer/src/linalg/matmul/tests/native_threads.rs:11–75`.

2. **Dense native entry and cfg consistency: PASS.**
   The helper is private and gated on `x86_64 + std` (`faer/src/linalg/matmul/mod.rs:22–41`), matching the dense native branch (`:1383–1399`). The call passes the same `M`, `N`, and `K` used by native GEMM (`:1404–1406`, `:1430`). Empty-output/K0 handling, specialized routes, and nano dispatch precede this call; generic GEMM retains its original caller parallelism (`:1203–1225`, `:1230–1381`, `:1435–1467`).

3. **Triangular native entry and generic gate: PASS.**
   The helper receives exactly the dimensions passed to native GEMM **after** the skip-diagonal view adjustment: `dst.nrows()`, `dst.ncols()`, and `lhs.ncols()` (`faer/src/linalg/matmul/triangular.rs:633–657`, `:679`). Upper output still reaches this path through the existing operand/output transpose and conjugation swap (`:1434–1445`). The generic `128³` gate remains after the native branch and uses its original dimensions (`:686–698`). No triangular-half-work model or new threshold was introduced.

4. **Internal native, fallback, and K0 routes: PASS.**
   Index validation and K0 semantics remain before native dispatch (`faer/src/linalg/matmul/internal/mod.rs:72–101`). Strict/unit adjustments modify the existing views/maps, then effective dimensions are recomputed and checked before both the GEMM arguments and helper call (`:125–185`, `:218`).

   The original `32³` gate now applies only after native dispatch has failed to return. It retains the original outer dimensions, comparison, multiplication expression, and caller budget (`:224–230`). Scratch allocation and subsequent fallback operations remain downstream (`:231–398`). No fallback arithmetic hardening is claimed or required by this delta.

5. **Numerical oracles, mappings, canaries, and above-floor cases: PASS.**
   Public triangular tests independently calculate scalar products, including genuine complex left conjugation; cover representative lower/upper/strict/unit masks, Add/Replace, and C/F views; and compare the entire guarded parent after checking finiteness (`faer/src/linalg/matmul/tests/native_threads.rs:82–170`).

   The mapped fixture independently applies both reversed index maps and optional real diagonal weights, checking rectangular and strict-lower Add results over the entire parent (`:180–247`). Its effective strict-lower work is `127×96×64 = 780,288` MACs, above the documented default real floor of `589,824`; square 128 cases also exceed that floor. The existing small fixture retains all four mapping combinations, all masks, both accumulation modes, and depths 0/2, now also receiving an owned eight-worker budget (`faer/src/linalg/matmul/internal/mod.rs:441–586`). Pool size is asserted (`faer/src/linalg/matmul/tests/native_threads.rs:252–264`).

6. **Output/API/unsafe/scratch/LU scope: PASS.**
   The complete supplied delta changes the private budget helper, its three call sites, fallback-gate placement, and tests. Existing pointer, mapping, conjugation, accumulation, and scratch arguments are unchanged (`faer/src/linalg/matmul/mod.rs:1400–1431`; `triangular.rs:641–680`; `internal/mod.rs:160–249`). No public API, new unsafe block, dependency, or LU ancestor change appears in that delta. This cannot restore a budget already lowered by an ancestor.

7. **Per-file provenance and minimality: PASS.**
   `mod.rs` extracts existing fork policy; `triangular.rs` changes only the budget argument; `internal/mod.rs` relocates existing policy and extends its own fixture; `native_threads.rs` contains module-owned scalar/reference tests using existing APIs and dependencies. No vendor implementation or test code is introduced in the supplied changes. The package declares MIT (`faer/Cargo.toml:9`), consistent with the explicit provenance record (`docs/worklogs/2026-10-18-native-gemm-work-floor.md:51–52`). This is a source/provenance-consistency check, not independent historical authorship verification.

## Findings

**None.** No substantiated Critical, Important, or Minor finding in the bounded delta; no must-fix correction identified.

### Delete list

None. The helper has three real callers, uses existing policy and stdlib arithmetic, and the tests exercise distinct decision and numerical obligations. **Net: 0 lines recommended for deletion.**

## Summary

**Bounded POST approved for source correctness and minimality.**

Accepted limits: f32/c32 receive decision tests, not new structured numerical execution; hypothetical extreme cutoffs test algebra without mutating the global getter; the no-Rayon check does not force generic numerical execution; requesting eight threads does not prove native worker utilization (`native_threads.rs:11–75`, `:252–264`; worklog `:27–42`).

I ran no builds, tests, or timing. The reported **217 passed / 2 ignored** and no-Rayon check with **13 pre-existing warnings** are supplied execution evidence, not reviewer execution (`worklog:24–32`). Timing, adoption, and integration remain deliberately pending.
