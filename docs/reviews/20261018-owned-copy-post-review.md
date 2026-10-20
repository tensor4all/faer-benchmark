# Independent POST report

Model: openai/gpt-6.1-sol. Run: `sa_c5efdcda-a753-49a8-a1fe-dd2db4fa8a94`. Completed bounded read-only review; not independent execution or performance approval.

## Files reviewed

Authoritative input: **`/tmp/owned-copy-post-bundle.md`, all 638 lines**, for candidate **`d6358cad06e38850f74aaeb499d5587037b4ffa8`**. No live repository source was consulted.

Per-file provenance:
- `faer/src/linalg/mod.rs`: exact diff and complete candidate lines 1–145 (bundle lines 5–75, 284–431).
- `faer/src/linalg/tests/copy_layouts.rs`: complete 74-line added test, also reproduced as `candidate-tests.rs` (bundle lines 76–231).
- `worklog.md`: bundled decisions and verification claims (bundle lines 233–282).
- Unchanged `MatRef` implementation: source lines 1580–1655 (bundle lines 432–510).
- Unchanged `ComplexField` bounds: source lines 1224–1260 (bundle lines 511–550).
- Unchanged adaptation excerpts: non-pivoted QR, partial-pivoted LU, full-pivoted LU (bundle lines 551–638).

## Status

**COMPLETE — bounded static POST review.** No BLOCKER, IMPORTANT, or MINOR correctness finding in the supplied candidate.

This is **not performance or adoption approval**. No edits, builds, tests, or benchmark commands were run.

## Focus area verdicts

1. **Safe numeric tile replacement: PASS.**
   `core::array::from_fn` initializes all 256 entries with valid numeric zeros. Both branches overwrite every slot subsequently read; neither depends on the initial zero values. The two loops use the same tile-index formula and identical bounds. Evidence: `faer/src/linalg/mod.rs:91–129` (bundle lines 376–414).

2. **Indexing, partial tiles, empty and reversed layouts: PASS.**
   Each local coordinate is in `0..16`, so `(i - ib) * 16 + (j - jb)` stays within the tile. Partial tiles preserve matching write/read ranges. Empty shapes perform no source/destination access, although tile initialization still occurs. Matrix indexing respects signed strides; the orientation check uses `unsigned_abs()`. Evidence: `mod.rs:92–133` (bundle lines 377–418). The focused test covers zero/one dimensions, tile boundaries, rectangles, and source row/column reversals in both copy directions (bundle lines 164–210).

3. **Disjoint Rayon work: PASS within the supplied API contract.**
   Mutable destination column partitions are zipped with matching immutable source partitions, and each invocation owns its local tile. This change introduces no shared staging buffer or scheduling change. Evidence: `mod.rs:63–80, 97` (bundle lines 348–365, 382). Partition implementation internals were not supplied or independently audited.

4. **Private `T: ComplexField` bound: PASS.**
   The changed block helper is private, and its enclosing caller already requires `ComplexField`. That trait supplies both `Clone` and zero construction. No public bound is strengthened by this diff. Evidence: `mod.rs:58, 87, 97` (bundle lines 343, 372, 382); trait source lines 1224–1227 and 1252 (bundle lines 513–516, 541).

5. **Custom-field Clone/zero/drop costs: PASS — accepted limitation, not generic acceleration.**
   The replacement performs 256 zero constructions per block-helper invocation, including empty copies, and two clones per copied element instead of one. Assignments drop previous tile contents; initialized tile entries are dropped at function exit rather than moved out. These can add allocation, destruction, or panic opportunities for custom fields, but introduce no unsafe lifetime handling. Evidence: `mod.rs:96–127` (bundle lines 381–412). The worklog explicitly acknowledges expensive custom clones and withholds general performance acceptance (bundle lines 241–245, 270–282). No corrective code is required for the stated scope.

6. **Numerical values, conjugation and caller preservation: PASS for supplied paths.**
   Staging introduces no arithmetic or conjugation. `MatRef::to_owned` retains the canonical-only gate and conjugating fallback; generic `MatRef::cloned` remains a separate `T: Clone` elementwise implementation (bundle lines 442–488, 490–502). The supplied QR and LU adapters retain copy-in, unchanged factorization call, and copy-back sequencing (bundle lines 565–568, 592–602, 621–633). The test uses genuinely complex values and exact equality, not tolerances (bundle lines 220–229).

7. **No new unsafe, public API or scratch changes: PASS.**
   The exact diff changes private staging and adds test registration/test code only (bundle lines 5–155). Existing scratch computation is untouched (`mod.rs:38–54`, bundle lines 323–339).

## Findings

**None requiring correction before merge on bounded correctness grounds.**

### Limitations

- The reported **211 passed, 2 ignored** is a worklog claim, not independently executed verification (bundle lines 257–261).
- Tests directly cover reversed **sources**, not reversed destinations; custom fields and no-Rayon builds are not exercised by this Rayon-gated test.
- A pivoted-QR caller excerpt is **absent from the bundle** despite the worklog naming it (bundle lines 246–250). Its preservation is supported by the exact diff’s scope, not an independent end-to-end trace of that caller.
- Native-GEMM records being archived concurrently were outside this immutable review input.

## Delete list

No justified deletion. The focused regression test is useful, and the tile replacement adds no speculative abstraction or dependency.

**net: -0 lines possible.**

## Summary

The supplied change preserves copy correctness and caller behavior under the existing contracts. Extra initialization, clone, and drop costs remain an explicitly accepted custom-field limitation. **Correctness review complete; performance acceptance and adoption remain undecided.**
