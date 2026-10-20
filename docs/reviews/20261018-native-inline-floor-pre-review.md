## Files reviewed
- `/tmp/native-inline-floor-pre.md` (lines 1–270), complete, including supplied baseline/native-call/helper excerpts. No repository discovery, commands, tests, builds, or edits.

## Status
- **COMPLETE — bounded PRE review.** All requested design areas assessed against the supplied plan and excerpts. This approves a proposed implementation, not an implemented diff or performance result. POST remains required.

## Focus area verdicts

1. **Minimal implementation versus source-layout fiddling: PASS.** Two direct expressions at the two consumers remove the helper, its attributes, and dense-root registration without introducing machine/shape specializations or changing compiler settings. Keeping the entire dense-owning module unchanged is a defensible scope reduction, not evidence that generated dense code will remain unchanged (`/tmp/native-inline-floor-pre.md:9–16`, `:27–32`). The explicit HOLD rather than placement/flag tweaking is important (`:52–55`).

2. **Arithmetic, including zero and `usize::MAX`: PASS.** The proposed expression is equivalent to the supplied helper: real cutoff is the threshold; complex cutoff is its ceiling divided by four (`:18–21`, `:255–264`).
   - Threshold zero gives cutoff zero and therefore preserves the caller budget.
   - Division by one or four is nonzero-divisor arithmetic; `div_ceil` avoids an overflowing handwritten addition.
   - Saturating multiplication preserves the comparison against any representable cutoff: an overflowing positive product exceeds every such cutoff. A zero factor still produces zero, including after earlier saturation.
   - At maximum threshold, both real and complex cutoffs remain representable.

   No claim of hardening the untouched dense expression is warranted or made (`:27–30`).

3. **Caller budget and cfg: PASS at design level.** Each result is exactly `1` or `par.degree()`, never an independently selected larger budget (`:18–21`, `:30`). Embedding the expression in the existing native call avoids adding a separately cfg-gated helper (`:188–226`, `:247–266`). **POST must confirm** that both expressions remain inside the existing native cfg boundaries and that the relocated tests retain appropriate feature/import guards; those enclosing boundaries and test imports are not included here.

4. **Effective dimensions and fallback preservation: PASS at design level.** The triangular expression uses the dimensions actually passed after `skip_diag` slicing (`:180–204`). The internal expression likewise uses the native call’s `nrows/ncols/depth` (`:23–26`, `:115–118`). Moving the old gate below the native early return prevents it from pre-clamping the native caller budget; the supplied fallback retains its original expression (`:84–90`, `:151–163`). Preserve the original fallback dimensions and incoming budget exactly as specified—do not accidentally reuse native-only adjusted values. The adjustment block itself is not supplied, so implementation confirmation belongs in POST.

5. **Tests and honest coverage limits: PASS.** Retaining genuine numerical/oracle coverage and moving registration into the owning implementation module is sufficient for this PRE; no new production test hook, macro, parser, or replacement helper is required (`:34–45`). Numerical equality does **not** establish selected budgets or worker utilization, and the plan correctly separates those claims. Historical arithmetic proof is supporting evidence for the formula, not execution coverage of the new expressions. No demonstrated required coverage gap justifies expanding the API.

6. **Static/performance gates and provenance: PASS as a proposed protocol.** Fresh four-body size/body equality precedes any timing; mismatch means HOLD without selective retries. The unchanged 648-stage gate precedes conditional 2688/all-14 testing, with no third LU pair or strict/unit correctness waiver (`:52–60`). The reported same-source ELF equality neither explains 7cd nor establishes this candidate’s equality or performance (`:3–7`). Ownership/MIT provenance is stated, not independently authenticated in this bounded review (`:62`).

## Findings
- **No must-fix design findings.**
- Acceptable limitations: no implemented-code verification, feature-build verification, selected-budget observation, new timing evidence, or independent provenance/archive audit.

## Summary
**Approve this minimal candidate for implementation and subsequent POST review.** Keep the two expressions identical, retain original fallback semantics, and leave the entire dense root byte-identical. This approval grants no assembly-equality, performance, final-freeze, or release claim.
