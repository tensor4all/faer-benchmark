## Files reviewed
Available evidence is truncated; full-file coverage cannot be certified.
- `/tmp/native-structured-floor-pre-bundle.md`: retained scope/plan references at lines 7–94.
- Prior production source: `mod.rs:24,1430`, `triangular.rs:641,679`, `internal/mod.rs:161,218`.
- Prior tests: `tests/native_threads.rs:33–66` (retained search matches only).
- Partial excerpts of `Par`, `Cargo.toml`, the experiment report, and triangular dispatch; complete line-numbered coverage unavailable.

## Status
**INCOMPLETE — investigation stopped as instructed.** No commands, edits, builds, tests, timing, or further investigation were performed after this checkpoint.

## Focus area verdicts
1. **Candidate scope: PASS at plan level only.** The bundle explicitly preserves the baseline dense expression and disclaims hardening its extreme-cutoff behavior (`/tmp/native-structured-floor-pre-bundle.md:39,46`). This does not verify a proposed implementation.
2. **Helper caller budget: prior source confirmed; candidate unverified.** Retained matches show the helper definition (`mod.rs:24`) and three prior production call sites: dense (`mod.rs:1430`), triangular (`triangular.rs:679`), and internal (`internal/mod.rs:218`). Removing the dense helper substitution would leave two listed structured callers; no candidate source was available to confirm that result.
3. **Performance sequencing: PASS at plan level only.** The bundle separates a static pre-filter from conditional performance stages (`/tmp/native-structured-floor-pre-bundle.md:68,76–90`). No fresh generated-code comparison or performance outcome was verified.
4. **Correctness, cfg, effective bounds, and fallback relocation: UNVERIFIED.** The retained excerpts do not support an end-to-end verdict.
5. **Full controls/guards, exact sample counts, rotations, and recording integrity: UNVERIFIED.** These cannot be certified from the surviving evidence.

## Findings
**No independently substantiated must-fix correctness defect is available in the retained evidence.** This is not approval: essential tracing remained unfinished.

**Required deletion/reversion in the proposed candidate:** remove the prior dense helper substitution at `mod.rs:1430` and retain the baseline expression, as explicitly required by the plan (`/tmp/native-structured-floor-pre-bundle.md:39`). Completion was not verified.

## Summary
The verified distinction is narrow: preserve dense behavior while retaining the helper for the two structured entry points. The prior source matches support that caller accounting, but not candidate correctness or performance acceptance.

**Provenance limits:** source/test references above concern the prior experiment, not an implemented candidate. Test/check successes in the experiment report are reported historical results, not independently executed verification. Diagnostic outcomes, normalized-code comparisons, adoption eligibility, and the complete bundle were not independently certified here.

**Best next review step:** when review resumes, inspect the frozen candidate’s exact production diff against the correctness-only baseline, then trace both structured callers’ effective dimensions and fallback bounds.
