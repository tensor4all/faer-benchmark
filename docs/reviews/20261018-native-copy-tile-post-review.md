## Files reviewed
Read **all 732 lines of `/tmp/native-copy-tile-post.md` once**, including:
- `faer/src/linalg/mod.rs`: complete two-file diff and complete dispatcher, generic fallback, and native helper (`:82–193`).
- `faer/src/linalg/tests/copy_layouts.rs`: entire new file (`:1–301`).
- Existing `nonstatic_typeid` implementation, supplied source-equality evidence, worklog, provenance record, and complete PRE report.

## Status
**COMPLETE — bounded finished-code POST.** All requested source-correctness and numerical-preservation focus areas were assessed. **No must-fix findings.**

No repository discovery, commands, edits, builds, tests, or timing were performed. Unchanged callers and wrapper preservation are supported by the supplied diff, equality record, and embedded PRE—not a fresh checkout-wide inspection.

## Focus area verdicts
1. **Exact builtin dispatch and lifetime contract: PASS.**  
   The predicate compares exactly `f32`, `f64`, `crate::c32`, and `crate::c64` identities, not overridable flags. Both copy functions retain `T: Clone`, without a new `'static` bound (`faer/src/linalg/mod.rs:86–101,149–152`). The existing safe identity helper is reused unchanged; its lifetime erasure does not turn a borrowed custom type into one of those concrete scalar types (`faer/src/hacks.rs:7–28`, supplied excerpt/PRE). This is reliance on its existing contract, **not a new proof of its internal unsafe implementation**.

2. **Extra clones restricted to builtin Copy/no-Drop values: PASS.**  
   The only native-helper call introduced by this complete diff is behind the four-identity predicate (`faer/src/linalg/mod.rs:93–101`). Consequently, seed, staging, and writeout clones are restricted to the four builtin types; custom `Clone`/`Drop` implementations retain the fallback. The helper is private, and the supplied unchanged-module evidence supports the stated call-site scope.

3. **Empty axes, tile initialization, tails, and indexing: PASS.**  
   Either empty axis returns before `src[(0, 0)]` is accessed (`faer/src/linalg/mod.rs:153–159`). In both traversal branches, staging and writeout cover identical bounded ranges with identical `(i - ib) * B + (j - jb)` indexing (`:161–188`). Every consumed slot is overwritten first, including partial tiles. The seed and stale slots therefore cannot leak into results. Both branches assign the same logical source/destination indices without arithmetic or conjugation.

4. **Generic fallback, wrapper, traversal, and budgets: PASS within the supplied preservation evidence.**  
   The complete fallback still performs one source clone into `Some`, followed by `take()` and a move into each destination (`faer/src/linalg/mod.rs:102–145`). The diff and supplied byte-equality record show that this body and the parallel wrapper were not rewritten. Tile dimensions and traversal policy remain unchanged; there is no new scratch, heap allocation, threshold, or worker-budget policy.

5. **Genuine native numerical tests: PASS.**  
   The complete test file constructs all four real builtin dtypes and compares component bits, including signed zeros, infinities, and NaN payloads. It covers both layout directions, independent source/destination row/column reversals, empty and singleton axes, partial tiles, rectangular shapes, and whole-parent guards (`faer/src/linalg/tests/copy_layouts.rs:1–301`). Owned pools explicitly check effective sizes 1/4/8 and pass Seq or matching Rayon budgets. These assertions establish **pool configuration, not worker utilization**. Native coverage is Rayon-feature-gated; the no-Rayon check does not independently exercise those native bit tests.

6. **Real generic dispatcher and ownership oracle: PASS.**  
   `Counted<'a>` is Clone-only, owns a `Vec`, and borrows local atomic counters. The test calls the production `copy_across_layouts_block`, rather than a replicated classifier or dummy `ComplexField` implementation. It checks exactly `m*n` clones and overwritten-destination drops immediately after copying, independent live payload allocations, parent contents, and final drops of `pm*pn + 2*m*n` after destroying both matrices (`faer/src/linalg/tests/copy_layouts.rs:1–301`). Both empty axes and both layout directions are included.

7. **Scope, routing, provenance, and minimality: PASS within this bundle.**  
   Documentation now distinguishes the seeded builtin path from the generic one-clone/move path (`faer/src/linalg/mod.rs:82–85,146–148`). The production addition is one predicate and one private representation-specific loop—not a slot framework, test hook, new API, unsafe operation, dependency, or identity-utility rewrite. The supplied provenance record identifies an own-MIT-fork adaptation and preserves the existing helper attribution (`faer/src/hacks.rs:4–7`).  
   Unchanged public `cloned()`, canonical/conjugated routing, and allocation-time zeros remain controls, not claimed optimizations; their caller evidence is the embedded PRE and supplied preservation record.

## Findings
**No must-fix source findings. No additional code or abstraction is requested.**

Keep the delete/do-not-add boundary: no `Slot` framework, dispatcher replica, custom `ComplexField` fixture, production instrumentation hook, configurable tile policy, or new unsafe storage machinery.

## Summary
**The bounded finished-code source review passes.** The implementation preserves the generic Clone/Drop/ownership contract while restricting additional clones to the four exact builtin scalar types.

The reported **212 passing / 2 ignored tests**, focused checks, and no-Rayon check with **13 existing warnings** are supplied evidence, not reviewer-executed results.

**No performance or adoption approval is granted.** Before **any** performance verification or timing—including the public-copy probe—the existing four-dense-body size/normalized-body filter remains binding for this candidate. Any mismatch means **HOLD**, without flag/position tweaking or retries to evade it. The original **f013 HOLD remains unchanged**. No new performance build or campaign is established by this review, and unseen paths or broader final-goal completion are not approved.
