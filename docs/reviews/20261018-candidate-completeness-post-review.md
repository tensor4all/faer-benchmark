## Files reviewed

Complete source, as embedded in `/tmp/candidate-completeness-post-bundle.md`:
- `campaign-toolkit/campaign_toolkit/candidate.py` — lines 1–233.
- `campaign-toolkit/tests/test_candidate.py` — lines 1–245.
- `faer-benchmark/scripts/candidate_compare.py` — lines 1–110.
- `faer-benchmark/scripts/test_candidate_compare.py` — lines 1–182.
- `campaign-toolkit/campaign_toolkit/timing_evidence.py` — lines 1–139.
- `campaign-toolkit/campaign_toolkit/validate_run.py` — scoped excerpts, lines 64–93 and 183–259.

Also reviewed the **entire bounded bundle in the requested three chunks**, including corrected plan, exact production diffs, and supplied observations.

## Status

**COMPLETE: all requested bounded focus areas traced.**

Reviewed snapshots: toolkit `9daa5bc` against `8484fb54`; harness `fca1fd7` against `cad85a6`, as identified by the supplied bundle. No repository discovery, edits, commands, builds, tests, or measurements were performed.

## Focus area verdicts

1. **Whole-run validation at the actual CLI boundary: PASS.**
   Each run must pass `validate_run.validate()` before identity checks or comparison statistics (`scripts/candidate_compare.py:35–61`). Validation includes result-file/status checks, v2 timing evidence, and default Git checks (`validate_run.py:230–242`). The timing validator checks the verification census, complete process groups, samples, status consistency, and rotation (`timing_evidence.py:79–139`). An explicit subset does not bypass whole-run validation.

2. **Fail-closed selection and recorded skips: PASS.**
   Recorded identities are retained before filtering out skipped rows (`candidate.py:120–130`). Empty tokens and tokens unmatched on either side are rejected (`candidate.py:151–167`). Thus legitimate skipped controls satisfy selector existence without contributing fabricated timings.
   The mandatory `lu,gemm` scenario and unknown-token-plus-valid-token refusal are exercised through the real CLI (`scripts/test_candidate_compare.py:143–152`) and directly in toolkit tests (`tests/test_candidate.py:113–127,140–150`).

3. **Independent equal recorded sets and nonempty timed sets: PASS.**
   Selected recorded sets must match, including skips; timed sets must separately match and be nonempty (`candidate.py:168–178`). These checks run independently for the selected control and fork engines (`candidate.py:192–201,216–222`). There is no requirement that control and fork support sets equal one another.

4. **Full identity, aliases, duplicates, and exact starts: PASS.**
   Full identity includes regime, dimensions, batch, engine, threads, and note (`timing_evidence.py:11–16`). Projection aliases and duplicate cell/repeat records are rejected (`candidate.py:118–126`), and selected full identities must match across runs (`candidate.py:179–182`). Both sides must declare the same integer start count of at least two, and every timed cell must contain exactly the declared `run0…runN` IDs (`candidate.py:147–150,183–188`). The old intersections and insufficient-start `continue` paths are removed in the supplied exact diff.

5. **Compatibility and descriptive statistics: PASS.**
   Public `series()` retains its signature and six-part key (`candidate.py:118–119,134–136`). Reads remain restricted to manifest-listed result files (`candidate.py:110–113`); rejected-archive exclusion remains tested (`tests/test_candidate.py:94–102`). Control medians and range±5%, fork geometric ratios, and candidate sample SD remain unchanged (`candidate.py:206–211,224–232`). Slower fork results remain descriptive and return zero after the gates pass (`scripts/candidate_compare.py:72–83`), with a real CLI assertion (`scripts/test_candidate_compare.py:122–132`).

6. **Parsing/I/O refusal and end-to-end tests: PASS.**
   The CLI catches the specified I/O, key/value, CSV, YAML, and subprocess errors and returns one (`scripts/candidate_compare.py:102–106`). Tests cover CSV parser failure, malformed/empty/missing YAML, output-write failure, and missing evidence on either side despite subset selection (`scripts/test_candidate_compare.py:154–178`). The six CLI tests invoke an actual subprocess and use synthetic v2 evidence plus temporary Git—not validator/comparison mocks or a local faer checkout (`scripts/test_candidate_compare.py:26–118`).

7. **Scope and minimal implementation: PASS.**
   The change reuses the existing validator and timing identity/sample helpers, with one shared private pairing path (`scripts/candidate_compare.py:21,37–38`; `candidate.py:120,130,139–189`). No new dependency, validation framework, threshold, or public toolkit signature is introduced.

## Findings

**No substantiated Critical, Important, or Minor findings in the reviewed bounded scope. No must-fix issue identified.**

### Delete list

None justified. The recorded/timed distinction and shared pairing helper enforce separate required invariants; removing either would weaken the repair. **Lean already; net: 0 lines proposed.**

### Per-file provenance

| Changed file | Reviewed derivation |
|---|---|
| `campaign_toolkit/candidate.py` | Extracts the existing manifest/CSV reader, adds full-identity bookkeeping and shared pairing checks, preserves statistical formulas. |
| `tests/test_candidate.py` | Retains existing coverage and adds synthetic completeness, skip, identity, duplicate, and selection cases. |
| `scripts/candidate_compare.py` | Reuses existing whole-run validation and preserves measured-code, identity, control, and reporting paths. |
| `scripts/test_candidate_compare.py` | Generates temporary synthetic evidence and measured Git trees; invokes the real CLI. |

The bundle identifies these as project-owned changes with no foreign implementation (`/tmp/candidate-completeness-post-bundle.md:2`). The supplied license paths both returned `ENOENT`; license text and repository-wide provenance were therefore **not independently verified**.

## Summary

The bounded implementation satisfies the corrected completeness contract without changing statistical or adoption policy.

The **63 toolkit passes, nine harness passes, five real negative refusals, 396/198-cell positives, and preserved original LU failures of 1/12 cells are main-supplied observations**, not reviewer executions (`/tmp/candidate-completeness-post-bundle.md:92–111`). The incomplete worker checkpoint is not counted as review approval.

Unchecked: raw result/log contents beyond the embedded summaries, independent Git/SHA and clean-status verification, remote reachability/pin updates, and native-floor correctness. Native-floor POST remains separate; this report grants **no timing, performance, or adoption approval**.
