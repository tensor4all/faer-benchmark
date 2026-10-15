## Files reviewed
Read the supplied source pack once, in full:
- `campaign_toolkit/timing_evidence.py:1–137`
- `campaign_toolkit/report_run.py:1–302`
- `tests/test_timing_evidence.py:1–144`

## Status
**COMPLETE — bounded review completed.** Two IMPORTANT findings; no BLOCKER findings. This is not approval of the unfinished implementation.

## Focus area verdicts
1. **V2 raw-sample validation: PASS.** Exact sample count, numeric/non-boolean values, finiteness, nonnegativity, positive median, aggregate consistency, and requested/observed thread-budget agreement are checked (`timing_evidence.py:19–25,116–129`). Readbacks are not presented as active-worker measurements.

2. **Census, variants, complete process sets, and rotation: PASS.** Notes participate in cell identity; declared bases must match the census; each process must reproduce its full census subset and statuses; duplicate/missing process groups and incorrect engine rotation are rejected (`timing_evidence.py:11–16,77–115,130–137`).

3. **Report cell/order accounting: FINDING — IMPORTANT.** Report grouping can omit an order dimension that validation distinguishes. See finding 1.

4. **Median/SD mathematics: FINDING — IMPORTANT.** For adequately repeated, correctly separated cells, the implementation correctly computes process medians, their median and sample SD, and median within-process sample SD without flattening raw calls (`report_run.py:70–75,232–235`). However, validation permits a one-process case for which the report cannot compute sample SD. See finding 2.

5. **V1 compatibility, as visible: PASS.** V1 continues to use recorded `total_ms`, minimum-across-repeat table values, and its existing A/A branch; v2 variants and statistics are conditional (`report_run.py:60–77,233–237,252–271`). Compatibility outside these files was not checked.

## Findings

### 1. IMPORTANT — Validated orders can be pooled into one report cell
**Evidence:** `timing_evidence.py:11,32–45` includes every declared `order` in the validated grid, but `report_run.py:58–63` keys results only by descriptor-provided axes. Table separation likewise uses only those axes (`report_run.py:208–219`).

The supplied test demonstrates a descriptor with no report case axis even though its manifest declares `order`: its expected report key contains no order component (`tests/test_timing_evidence.py:26,83–84`). Extending that setup to valid `c` and `f` evidence would pass the timing validator but append both orders’ medians into the same engine list. The resulting SD would mix distinct order cells rather than describe repeated processes for one cell.

**Suggested fix:** Ensure v2 report keys/tables retain every validated case dimension, including `order`, or reject a manifest/descriptor combination that would collapse distinct cells.

**Disposition:** Must fix before merge for the stated order-accounting guarantee.

### 2. IMPORTANT — An accepted single-process set crashes SD rendering
**Evidence:** `timing_evidence.py:65–68` permits one engine with `aa = 1`: this satisfies the rotation-cycle condition and the two-call requirement. Complete-set accounting also accepts that configuration (`timing_evidence.py:136–137`). However, `report_run.py:234` unconditionally calls `statistics.stdev(times)`, which requires at least two process medians.

Thus two or more valid chronological samples in one process pass validation but cannot produce the promised report.

**Suggested fix:** Require at least two complete process sets for v2, in addition to complete rotation cycles; alternatively render between-process SD as unavailable for a single process.

**Disposition:** Must fix before merge so accepted v2 evidence is reportable.

## Delete list
No justified deletion identified in this bounded scope. The census checks and separation of within-/between-process statistics are necessary, not speculative scaffolding.

**net: 0 lines proposed for deletion.**

## Summary
The core census and raw-sample checks are sound within the reviewed pack. Report grouping and the minimum process-count contract need correction.

**Unchecked:** numerical/backend correctness, actual thread-limit instrumentation, chronological recorder behavior, end-to-end recorder smoke, manifest/descriptor validation elsewhere, and other campaigns’ integration. The reported 24 passing toolkit tests were not rerun or independently verified; no commands, builds, tests, or edits were performed.