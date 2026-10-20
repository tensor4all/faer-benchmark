# Completed bounded PRE: openai/gpt-6.1-sol

## Files reviewed
Read `/tmp/candidate-completeness-pre-bundle.md` completely, including the plan and five reproduction records. Source reviewed **as embedded in that bundle**:

- `campaign-toolkit/campaign_toolkit/candidate.py:1-165`
- `faer-benchmark/scripts/candidate_compare.py:1-92`
- `campaign-toolkit/campaign_toolkit/timing_evidence.py:1-139`
- `campaign-toolkit/campaign_toolkit/validate_run.py:64-93,183-259`
- `campaign-toolkit/tests/test_candidate.py:1-89`

Also read the ponytail and ponytail-review skills. No repository discovery, edits, builds, tests, or measurements performed.

## Status
**COMPLETE — bounded PRE review.**

The fail-closed approach addresses the reproduced defect without changing the statistics. **One IMPORTANT plan correction is required:** per-engine token-match enforcement conflicts with preserving legitimate skipped cells.

No BLOCKER finding. This is not implementation, performance, or merge approval.

## Focus area verdicts

1. **Validation at the CLI trust boundary: PASS.**
   The current CLI proceeds from manifest loading through identity checks directly to comparison without validating either run (`scripts/candidate_compare.py:51-66`). Reusing `validate_run.validate()` brings in result-file checks and v2 census/process validation (`validate_run.py:230-241`; `timing_evidence.py:79-139`). Validate **both complete runs**, not merely selected rows; an explicit subset must not excuse invalid evidence elsewhere.

2. **Equal, nonempty selected sets: PASS.**
   Current intersection pairing silently drops missing cells, and an empty control loop returns success (`candidate.py:126-143,152-165`). Equal nonempty sets per engine close that hole while still permitting an explicit `f64` subset. Keeping control and fork support sets independent is correct.

3. **Selectors combined with legitimate skips: FINDING — IMPORTANT.**
   The proposed shared helper checks every token separately within each engine’s timed series. That series excludes skipped rows (`candidate.py:104-105`), although the evidence validator explicitly accepts consistent skips (`timing_evidence.py:85-87,111-113,130-133`). See Finding 1.

4. **Full identity, aliases, variants, and public signatures: PASS, with a deliberate restriction.**
   The public key includes order, dimensions, and note but omits regime and batch (`candidate.py:108-111`); canonical identity includes those fields (`timing_evidence.py:11-16`). Tracking canonical identity internally and rejecting aliases prevents incorrect pairing without changing the public six-part key or function signatures. Notes must remain distinct. Legitimate grids that alias the old projection will be refused rather than fully supported—acceptable for this explicitly fail-closed scope.

5. **Complete process starts and duplicates: PASS.**
   Existing comparisons accept two starts despite a larger declared count and can silently overwrite duplicate projected cell/repeat entries (`candidate.py:101,110-111,134-135,156-158`). Exact declared repeat sets on both sides, equal `aa >= 2`, and duplicate rejection address these failures. Correcting the existing `aa: 3` fixture that writes only two starts is necessary (`tests/test_candidate.py:22,25`).

6. **Statistics and adoption contract: PASS.**
   Leave the baseline median/range ±5% calculation unchanged (`candidate.py:136-142`) and preserve the geometric mean of paired ratios and candidate sample SD (`candidate.py:159-164`). The CLI currently reports slower cells without making them an automatic refusal (`scripts/candidate_compare.py:78-88`); the plan correctly retains that descriptive behavior.

7. **Error handling and minimal structure: PASS as a design requirement.**
   One shared pairing helper and the existing validator are justified; a second validation framework is not. The CLI error boundary must cover validation, manifest parsing, comparison, and requested output I/O—not just the helper call (`scripts/candidate_compare.py:51-87`). Use explicit runtime checks raising `ValueError`, not optimization-removable Python `assert` statements.

## Findings

### 1. IMPORTANT — Per-engine selector coverage rejects valid skipped-cell subsets

**Evidence:** Plan B promises preservation of supported skips, while plan D places every-token matching inside the helper called separately for control and fork (`/tmp/candidate-completeness-pre-bundle.md:18,22`). Current extraction removes skipped rows (`candidate.py:104-105`); validation considers those rows legitimate evidence (`timing_evidence.py:85-87,111-113,130-133`).

**Concrete counterexample:** Both runs consistently record:

- control: `lu` skipped, `gemm` timed;
- fork: both `lu` and `gemm` timed.

Without selection, the proposed independent engine-set checks can accept these runs. With `--cells lu,gemm`, per-engine token enforcement rejects `lu` in the control series—even though both requested families are recorded, skips are legitimate, and both comparisons have nonzero timed coverage.

**Suggested fix:** Check token existence against recorded/declared cells including legitimate skips, then enforce equal nonempty **timed** sets independently for each engine.

**Mandatory acceptance test:** Exercise this mixed-support example with an explicit multi-token selection. Also retain rejection of a genuinely nonexistent token combined with a valid one.

## Delete list

1. `candidate.py:126-129,152-154`: **reuse:** remove duplicated intersection/filter logic; replace with shared validated pairing.
2. `candidate.py:134-135,157-158`: **delete:** remove silent insufficient-start skips; reject incomplete evidence before statistics.
3. `scripts/candidate_compare.py:65`: **shrink:** replace the truthiness distinction with an omitted-versus-present distinction, so `--cells ""` is rejected rather than treated as no selection.
4. **Do not add** another schema/census validator or unrelated cleanup of measured-code handling.

Net line reduction cannot be established before an implementation diff exists.

## Provenance and unchecked limits

- The bundle identifies toolkit `8484fb54` and harness `b86fde2`; those identities and the recorded reproduction outputs were **not independently reverified**.
- The source supports the reported failure mechanisms. The five observed exit-zero results are supplied reproduction evidence, not commands executed during this review.
- Unreviewed: wider callers, complete schema/declaration/git-resolution implementations, raw CSV contents, and any future diff.
- POST review must verify concrete exception handling, including malformed YAML and missing files; `ValueError`/`OSError` alone do not cover YAML parser exceptions.
- Preserve manifest-only reads and the rejected-archive regression (`candidate.py:100-102`; `tests/test_candidate.py:70-78`).

## Summary

**Safe to implement:** validator reuse, independent equal/nonempty engine sets, canonical-identity checks, duplicate refusal, exact complete-start checks, unchanged statistics, and the existing public API shape.

**Mandatory correction first:** resolve selector coverage over legitimate skipped cells and add the mixed-support regression above. Everything else can remain within the proposed small scope.

Archive this report and the supplied provenance as PRE evidence; no code or performance approval is implied.
