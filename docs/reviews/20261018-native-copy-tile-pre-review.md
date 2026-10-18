## Files reviewed
Read **all of `/tmp/native-copy-tile-pre.md` once**, including its plan and these embedded baseline excerpts:
- `faer/src/linalg/mod.rs:27–143`
- `faer/src/hacks.rs:1–34`
- `faer-traits/src/lib.rs:1224–1250,5102–5112`
- `faer/src/mat/matref.rs:1550–1654`
- `faer/src/linalg/lu/partial_pivoting/factor.rs:260–303`
- `faer/src/linalg/lu/full_pivoting/factor.rs:472–510`
- `faer/src/linalg/qr/no_pivoting/factor.rs:250–285`
- `faer/src/linalg/qr/col_pivoting/factor.rs:350–383`

## Status
**COMPLETE — bounded PRE.** All requested focus areas were assessed against the supplied plan and baseline excerpts. No repository discovery, edits, commands, builds, tests, or timing were performed. There is no production implementation to approve yet.

## Focus area verdicts
1. **Exact four-type dispatch and generic semantics: PASS.**  
   Exact identity checks avoid trusting implementor-controlled native flags (`faer-traits/src/lib.rs:1239–1246`). The complex aliases are specifically `Complex<f32>` and `Complex<f64>` (`faer-traits/src/lib.rs:5108–5109`), not arbitrary `ComplexField` implementations. Newtypes, alternate implementations, heap-owning values, and references do not become those concrete types merely through lifetime erasure. Keeping the entire fallback preserves its one source clone followed by a move into the destination (`faer/src/linalg/mod.rs:103–127`). This addresses d635’s extra custom `Zero`/`Clone` problem rather than assuming it away.

2. **Lifetime, bounds, and unsafe boundary: PASS within the stated scope.**  
   The existing helper accepts `T: ?Sized` without a public `'static` bound; its lifetime manipulation is already internal to that safe interface (`faer/src/hacks.rs:7–28`). Comparing its result with the four concrete `TypeId`s requires no pointer conversion or representation reinterpretation. The private copy entry can retain `T: Clone` (`faer/src/linalg/mod.rs:87–90`).  
   This verdict relies on the existing helper’s contract; it is **not** a fresh soundness proof of its internal unsafe implementation.

3. **Empty seed and write-before-read: PASS as specified.**  
   Returning on either zero dimension before reading `src[(0,0)]` prevents the newly introduced empty-input access. For nonempty inputs, every writeout index belongs to the same tile ranges populated immediately beforehand in both traversal branches (`faer/src/linalg/mod.rs:98–127`). Retaining these exact ranges and `(i - ib) * B + (j - jb)` indexing makes stale seeded or previous-tile slots irrelevant, including partial tiles. Extra seed/staging/writeout clones are confined to the four builtin scalar types.

4. **All nine call sites, traversal, and resource budgets: PASS.**  
   The supplied callers comprise:
   - Canonical row-strided `to_owned`: `faer/src/mat/matref.rs:1631–1644`.
   - Partial LU copy-in/out: `faer/src/linalg/lu/partial_pivoting/factor.rs:284–295`.
   - Full LU copy-in/out: `faer/src/linalg/lu/full_pivoting/factor.rs:489–502`.
   - Nonpivoted QR copy-in/out: `faer/src/linalg/qr/no_pivoting/factor.rs:274–279`.
   - Column-pivoted QR copy-in/out: `faer/src/linalg/qr/col_pivoting/factor.rs:365–379`.

   The proposed dispatch changes neither these allocation boundaries nor their arguments. Worker column partitioning remains at the existing wrapper (`faer/src/linalg/mod.rs:63–80`); tile size and traversal remain those of the baseline (`:91–132`). No additional scratch requirement is needed.

   **Important distinction:** public `cloned()` does **not** call this dispatcher; it remains `Mat::from_fn` plus elementwise cloning (`faer/src/mat/matref.rs:1588–1602`). It is an unchanged control, not an optimized route. Likewise, existing allocation-time zeros in `to_owned` and factorization callers are not removed by this proposal.

5. **Clone/Drop/heap test oracle: PASS as a PRE test specification.**  
   The baseline clones each source entry once and assigns over each destination once, moving the tile value via `take()` (`faer/src/linalg/mod.rs:106–113,119–126`). A Clone-only value with owned `Vec` storage, shared counters, and `Drop` can directly test that contract through the real private dispatcher. A complete dummy `ComplexField` implementation is unnecessary.

   The implementation should check counters at explicit stages: immediately after copying, and after destroying the matrices. Empty tests should include both zero-row and zero-column shapes. Shared counter ownership is expected; the cloned payload’s heap ownership must be independent.

6. **Native bit preservation and coverage: PASS as a PRE test specification.**  
   The proposed path performs cloning and assignment, not arithmetic or conjugation. Exact per-component `to_bits()` assertions are appropriate for signed zero, infinities, and NaN payloads. Numeric equality alone would miss signed-zero changes and reject preserved NaNs. Testing both traversal branches and reversed source/destination strides exercises the index mapping at `faer/src/linalg/mod.rs:95–127`.

   Preserve the existing canonical-only public routing: conjugated `to_owned()` deliberately retains `Conj::apply` (`faer/src/mat/matref.rs:1626–1647`). The plan correctly does not broaden that route.

7. **Minimality, provenance, and gate separation: PASS within this bundle.**  
   A single private native helper plus exact dispatch is a reasonable minimal safe representation split. The existing generic body relies on `Option::take()` to preserve one-clone/move semantics (`faer/src/linalg/mod.rs:106–126`); replacing it globally would reopen the custom-type problem. Reusing the existing identity helper also preserves its attribution (`faer/src/hacks.rs:4–7`).

   This is a distinct shared-copy optimization, not permission to amend the native-floor gate. Historical timings establish neither adoption nor composite-factorization benefit. **7cd/f013 HOLD and the original gate remain unchanged.** No performance acceptance is granted here.

## Findings
**No must-fix PRE findings.**

One minor implementation documentation follow-through: the current entry documentation promises an `Option` tile with no seed or second clone (`faer/src/linalg/mod.rs:82–86`). After adding dispatch, qualify that description as the **generic fallback** and briefly describe the builtin path. Preserve the fallback body, not an inaccurate entry-level description.

### Delete / do-not-add list
- No dummy `ComplexField`, production test hook, or alternate dispatcher replica.
- No `TileSlot` abstraction, macro framework, configurable tile size, or threshold.
- No new unsafe, reinterpretation, dependency, scratch allocation, native flag, or stronger bound.
- No initialization-hoist “fix”: the baseline already initializes its tile once per block invocation (`faer/src/linalg/mod.rs:96–98`).
- No claim that `cloned()` is accelerated, or that historical copy timings satisfy adoption gates.

## Summary
**The plan is suitable to implement within its stated constraints.** Exact builtin identity plus the entire original fallback preserves the generic Clone/Drop/heap/lifetime contract while allowing a seeded native tile. The specified tests target the real dispatch boundary without unnecessary trait scaffolding.

This is **PRE approval of the bounded approach only**—not approval of unseen code, correctness results, performance adoption, or any change to the native-floor HOLD/gate.
