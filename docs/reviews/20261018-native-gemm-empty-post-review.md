# Independent POST report

Model: openai/gpt-6.1-sol. Run: `sa_42abaf44-5a87-418a-b4f2-9e55a8a3ff4c`. Completed bounded read-only review; not independent execution or performance approval.

## Files reviewed
All source evidence came from `/tmp/native-bounds-post-bundle.md`, read completely.

- `faer/src/linalg/matmul/internal/mod.rs:1–598` — complete **final** source: production and module-owned tests.
- `faer/src/linalg/matmul/triangular.rs:902–988` — unchanged structure contract and predicates.
- `faer/src/linalg/cholesky/ldlt/factor.rs:456–470,568–598` — three unchanged caller excerpts.
- `faer/src/sparse/linalg/cholesky.rs:3228–3242,3384–3398` — two unchanged caller excerpts.
- Dense empty-product convention, supplied lines `1188–1199` — unchanged reference excerpt; its file path was not identified in the bundle.
- Worklog and historical original-source excerpts — provenance and comparison only; **not treated as final source**.

## Status
**COMPLETE — all requested focus areas traced within the bounded snapshot. No mandatory fixes found.**

## Focus area verdicts

1. **Post-shift effective dimensions and empty output: PASS.**
   Lower strict/unit handling advances A and the destination row or row-index slice; upper handling advances B and the destination column or column-index slice (`internal/mod.rs:132–161`). Recomputing dimensions afterward and returning on either zero extent prevents the stale-size backend call (`:162–166,190–192`). The shadows are native-local; fallback dimensions remain unchanged (`:231–246`).

2. **Strict/unit and rectangular masks: PASS.**
   After a lower row shift, backend-inclusive `i′ >= j` corresponds to original `i > j`; the upper column shift similarly converts `j′ >= i` to original `j > i` (`:140–160,200–207`). The K=0 predicate explicitly handles dense, strict lower/upper, and generic diagonals (`:89–103`), consistent with the supplied enum contract (`triangular.rs:904–975`). This also handles nonsquare outputs without assuming a square diagonal extent.

3. **All four index-presence combinations and write bounds: PASS.**
   Dimension assertions establish mapping lengths, and existing loops validate every supplied destination index before the new K=0 handling (`internal/mod.rs:61–88`). Zero-product writes apply the logical mask **before** mapping row and column coordinates (`:92–102`). Native shifts adjust either the corresponding mapping slice or destination view, not both (`:140–160`); corrected dimensions bound their consumption (`:162–198`). Tests cover all four combinations with descending nonidentity maps and compare the complete parent matrix (`:464–485,504–507,527–549`).

4. **K=0 Replace/Add and D/conjugation/alpha: PASS.**
   Add performs no writes; Replace zeros only stored coordinates, then returns before dispatch or scratch use (`:89–108`). Ignoring D, conjugation and alpha for an empty product matches the supplied dense convention (`1188–1196`), rather than evaluating `alpha * 0`. Positive-depth parameter forwarding is unchanged (`internal/mod.rs:213–225`), and the fallback scaling/conjugation path is unchanged (`:252–303`).

5. **Tests and oracle independence: PASS.**
   The oracle explicitly matches all seven enum variants instead of calling the production storage predicate (`:489–495`), independently forms scalar products (`:497–513`), and checks the entire parent allocation (`:546–554`). Coverage includes empty, singleton, square and rectangular shapes, both accumulation modes, K=0/2, f64/c64, mappings, left conjugation, real D and complex alpha (`:445–481,537–542,562–571`). The original empty and nonempty guard reproducers remain present (`:410–438,574–597`).

6. **Caller compatibility and change scope: PASS.**
   All five supplied callers use inclusive lower or rectangular output and Add: dense callers at `factor.rs:456–470,568–597`; sparse callers at `cholesky.rs:3228–3242,3384–3398`. Their positive-depth paths therefore avoid the strict/unit adjustment. The additions introduce no unsafe block, signature, dependency, threshold or scratch-requirement change (`internal/mod.rs:21–59,72–78,89–108,162–167`).

## Findings
- **BLOCKER:** None.
- **IMPORTANT:** None.
- **MINOR:** No correctness finding in the added production code or tests.

## Delete list
1. `faer/src/linalg/matmul/internal/mod.rs:137–139,152–154`: **delete, optional/Minor** — the old pre-shift zero guards are unreachable after the existing return at `:69–71`. Replacement: nothing. These are unchanged lines; leaving them is acceptable and does not block this fix.

**net: −6 lines possible**, entirely optional.

## Limitations
- Read-only review: no builds, tests or commands executed. The four focused passes, 214 library passes/2 ignored, and no-Rayon compilation are **reported worklog evidence**, not independently reproduced results.
- No forced-generic numerical run, f32/c32 fixture, right-conjugation oracle case, u32-index fixture or parallel execution was demonstrated. Their absence does not invalidate these bounded control-flow changes.
- The private backend implementation and repository-wide diff were not supplied or independently audited. This verdict covers the requested wrapper additions and tests, not unrelated existing fallback/backend behavior.
- No performance or adoption approval is implied.

## Summary
**No must-fix changes before merge within the reviewed scope.** The final additions correctly bound native strict/unit output after shifting and implement common, masked K=0 semantics after existing index validation. The tests provide independent numerical expectations and parent-guard coverage; optional cleanup need not expand this patch.
