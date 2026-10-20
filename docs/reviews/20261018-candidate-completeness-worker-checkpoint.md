## Status: incomplete — budget exhausted mid-work

### Verified: files modified (edits reported successful)
- `/home/shinaoka/projects/tensor4all/campaign-toolkit/campaign_toolkit/candidate.py` — private pairing helper (`_paired_series`), selector check against recorded identities including skipped rows, exact aa-ID ≥2 both sides, duplicate/identity/regime/batch/variant guards replacing overwrite behavior, `control_check`/`fork_comparison` rewired.
- `/home/shinaoka/projects/tensor4all/faer-benchmark/scripts/candidate_compare.py` — CLI now runs existing `validate_run.validate` over **both** whole manifests, wraps parse/I/O failures as refusals, refuses on mismatch rather than overwriting.
- `/home/shinaoka/projects/tensor4all/campaign-toolkit/tests/test_candidate.py` — rewritten with fixture-based cases (missing/duplicate token, identity/variant, explicit legitimate subset, short/mismatched complete sets, unlisted rejected CSV, variant-notes distinctness).

### Verified: problems that were still present at last observed check
Last captured `pytest` run **failed**; errors seen:
- `ValueError: dict contains fields not in fieldnames: 'batch'` in the new `make_run` fixture writer (`make_run` CSV fieldnames incomplete) — later edited, but no green rerun captured.
- `UnboundLocalError: cannot access local variable 'key'` in `candidate._paired_series` (generator expression variable shadowing) — later edited, no green rerun captured.
- Same `_paired_series` failure surfacing via `fork_comparison` in `test_short_and_mismatched_complete_sets_are_refused` — later edited, no green rerun captured.

### Unverified / unfinished
- **No passing test run captured** for `campaign-toolkit/tests/test_candidate.py` after the final fixes; whether the `_paired_series` fix and the `make_run` fieldnames fix actually resolve all failures is unknown.
- **`faer-benchmark/scripts/test_candidate_compare.py` was never created/verified** — the required focused CLI end-to-end test (valid v2 evidence, real validators, temp Git fixture, positive full comparison + explicit legitimate subset) is **not evidenced**.
- **Ruff on changed files was never run/reported.**
- **Explicit scenario matrix not confirmed end-to-end**: `lu,gemm` passing when control consistently skips `lu` but times `gemm` while fork times both; missing-token-plus-valid-token refusal; five-case reproducer against `data/probes/20261018-candidate-coverage-audit/reproduce.py`+`before.json`.
- Statistics ±5%, geomean/SD, and descriptive slower-fork exit behavior are **unchanged-by-intent only** — not re-verified by test.
- Audit script/artifacts and shared docs/pin/push were not touched (consistent with ownership), but this is inferred from the edit list, not re-checked with `git status`.

### Exact commands / results available
- Edit tool calls: all reported "Successfully replaced/wrote" for the three paths above.
- `pytest tests/test_candidate.py` (exact invocation not preserved in the truncated log): **3+ errors listed above** at the time of capture; no subsequent result recorded.

Main agent should re-run the toolkit unit tests, write/validate `scripts/test_candidate_compare.py`, and run Ruff before integration.
