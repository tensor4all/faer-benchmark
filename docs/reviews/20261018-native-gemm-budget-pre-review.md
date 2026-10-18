# Completed bounded PRE: openai/gpt-6.1-sol

## Files reviewed
Read `/tmp/native-gemm-budget-pre-bundle.md` completely (lines 1–649), including the plan and these embedded baseline excerpts:
- `faer/src/linalg/matmul/mod.rs:1360–1432`
- `faer/src/linalg/matmul/triangular.rs:595–718`
- `faer/src/linalg/matmul/internal/mod.rs:45–240`
- `faer/src/linalg/cholesky/ldlt/factor.rs:416–480,507–519,565–599`
- `faer/src/sparse/linalg/cholesky.rs:3226–3245,3382–3401`
- `faer/src/linalg/lu/partial_pivoting/factor.rs:99–130`

Read the ponytail-review and ponytail skills completely. No repository discovery, edits, builds, or measurements.

## Status
**COMPLETE — bounded PRE review. Safe to implement the supplied plan.**

No BLOCKER, IMPORTANT, or MINOR finding established. This approves neither performance claims nor integration/merge.

## Focus area verdicts

1. **Normalization and overflow: PASS.**
   The existing comparison is at `faer/src/linalg/matmul/mod.rs:1417–1425`; the replacement is specified in `/tmp/native-gemm-budget-pre-bundle.md:11`.

   Let mathematical MAC work be \(W=M N K\), and threshold be \(t\). Then:
   - Real: \(2W \ge 2t \iff W \ge t\).
   - Complex: \(8W \ge 2t \iff W \ge \lceil t/4\rceil\).

   Comparing saturating `usize` MAC work against either representable cutoff preserves this mathematical decision, including overflowing products and zero dimensions. `t.div_ceil(4)` avoids an overflowing handwritten `(t + 3) / 4`. This matches the old expression where its arithmetic is representable; extreme-domain differences correctly remove the old unchecked `2 * threshold` hazard rather than introducing a new policy.

2. **Caller-budget bounds and configuration: PASS at plan level.**
   Returning only `1` or the supplied `par.degree()` cannot manufacture a larger parallel budget. One private helper under `cfg(all(target_arch = "x86_64", feature = "std"))`, with unchanged non-native routes, is the right boundary (`bundle:11–12`). Both structured native branches already have that configuration guard (`triangular.rs:613–619`; `internal/mod.rs:109–115`).

   Keep Rayon-specific test construction separately feature-gated. The planned no-Rayon check is necessary (`bundle:19,22`); no compiled-configuration result is claimed here.

3. **Triangular effective dimensions: PASS.**
   The skip-diagonal adjustment occurs at `triangular.rs:633–640`, and native extents come from those adjusted views at `655–657`. Using those same dimensions for the helper is correct. Changing only the final budget argument at `679` leaves pointers, strides, mask, accumulation, and conjugation unchanged. The existing generic fallback gate remains at `694–698`.

4. **Indexed/diagonal entry, fallback gate, and correctness baseline: PASS.**
   Index validation and the zero-depth path precede native dispatch (`internal/mod.rs:79–108`). Strict/unit adjustments and effective-empty return occur at `132–166`; native extents then use the adjusted dimensions (`190–192`).

   Moving the current gate from `72–78` to after native dispatch returns at `227–230`, before scratch allocation at `231`, preserves fallback policy while giving native dispatch the original caller budget. Keep this gate in the outer scope so fallback uses the original dimensions—not native-only shadowed dimensions.

   The existing partially unchecked fallback product at `72` is pre-existing and explicitly preserved; this proposal should not be advertised as globally hardening fallback size arithmetic.

5. **Tests and scope minimality: PASS.**
   Helper boundary/oracle checks, deterministic public triangular checks, and extension of existing internal fixtures directly cover the changed decisions (`bundle:19–22`). No new framework or public testing hook is warranted.

   Implementation checks: perform oracle multiplication in `u128` **before** scaling the threshold; exercise overflow followed by a zero dimension; retain mapping combinations, strict/unit canaries, and zero-K behavior. Use selected representative structured cases rather than an unnecessary full Cartesian expansion.

6. **Caller reach and claim boundaries: PASS.**
   Dense Cholesky reaches triangular and diagonal-backed internal products (`ldlt/factor.rs:436–469,568–596`). Sparse Cholesky reaches mapped internal products, both without and with a diagonal (`sparse/linalg/cholesky.rs:3228–3241,3384–3397`). These justify the proposed correctness coverage.

   LU still lowers its caller budget before downstream operations (`lu/partial_pivoting/factor.rs:110–128`). A helper downstream cannot restore that lost budget. The plan explicitly avoids this claim and the unrelated 1T linked-binary explanation (`bundle:5,15`).

7. **Measurement staging and rejection rules: PASS as a protocol, not evidence.**
   Fresh A/B identities, immutable inputs, explicit 1T, topology-based pins, recording serialization, and unchanged retention rules are specified at `bundle:26`. Focused targets, broad guards, declared coverage, and stop-on-regression precede wider acceptance (`28–30`).

   Exact grids/counts must be frozen before timing, as required—not inferred from whatever cells survive. Expensive **2048/3072/4096 square tiers remain final-only** (`5,30`); the separately listed thin `4096×256` Householder guard is not a square-tier development run. No performance conclusion follows from this PRE.

## Findings
**None requiring correction before implementation.** The implementation details above are acceptance checks for POST, not requests to expand scope.

## Delete list
No speculative abstraction, dependency, configuration, or validation layer to delete. Reusing one helper across three native entrances is appropriately minimal.

**net: −0 additional lines identified beyond the planned deduplication.**

## Provenance and unchecked scope
- Source evidence is the supplied baseline excerpts, not an independently inspected checkout. Baseline/branch identities and own-code/MIT provenance are declared at `bundle:5,26,34`; not independently verified.
- Not checked: actual helper/diff, kernel implementation, `Par` and threshold-getter implementation, existing fixture bodies, compilation, runtime correctness, worker census, or performance.
- Comparator complete-cell/start protection is deliberately excluded and remains the main agent’s concurrent audit.
- POST must verify the finished diff and observed checks before integration.

## Summary
**Safe to implement this isolated experiment as written.** Preserve the exact native/fallback boundary and effective dimensions; do not broaden claims to LU-budget recovery, 1T binary shifts, speedup, or merge readiness.
