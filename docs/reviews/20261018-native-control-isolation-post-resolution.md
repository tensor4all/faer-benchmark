# Native control-isolation POST resolutions

POST COMPLETE on immutable8d3f35d (gpt-6.1-sol), two IMPORTANT findings. Both
verified against actual source and corrected before any diagnostic recording.

1. All six information invocations now use the SAME guarded capture routine as
   verification/timing: per-command argv/before state, separate full stdout and
   stderr, return code persisted before after-guard, then checked fail-stop.
   Both information and pinned commands keep process-group timeout/kill bounds.
   No outer retry. Accepted/rejected/partial files remain available; unflushed
   harness samples cannot be recovered. Timing now stores accepted table stdout
   separately from guard/stderr; no clock/sampling/operation change.
2. Explicit NON-assert startup refusal for optimized Python, before third-party
   imports, output-directory creation or production commands. `python -O` and
   inherited PYTHONOPTIMIZE=1 both exit1;8d3f35d incorrectly exited0 in the same
   real offline-check invocation with its original __file__ location.

`post-fix-checks.log`: normal offline96-cell/72+18 schedule and real positive/
forged-identity CSV checks pass. `check_isolation_capture.py` extracts the ACTUAL
trusted nested function without running the recording entry point: real dummy
Python children exit0/3, and both retain stdout/stderr/argv/returncode/before/
after. Dummy guard intentionally does NOT claim live topology verification.
Ruff/compile/diff pass. No benchmark, fbench, build, source switch or diagnostic
CSV exists from these checks. Corrective checks, not a new design/review cycle.
No claim reviewer executed tests or independently rereviewed these corrections.

PRE's three wording findings and buffered-output limit are corrected. Added
noncontemporaneous-run confound explicitly: changed diagnostic ratios cannot
identify worker/MKL/alignment causality. Canonical comparison remains refused,
7f713a1 NOT ADOPTED; no stage2, source pin/main merge, large/final campaign.

Parallel artifact-only work: canonical-isolation-context.json references exactly
96 upstream cells×3 repeats×2 binaries (576 original records), retaining original
five-sample arrays in place with source hashes; not an intersected acceptance set.
Source selector receipt updated after non-selection-changing driver correction.

Hosted benchmark CI39145818271 initially failed ONLY because historical LU
candidatea537746 was not remotely reachable. Existing reviewed feature branch
perf/upstream-lu-scheduling at34d71508d6c085a19188f7a945213ccdf4002dda already
records BOTH refused pairs/NOT ADOPTED/no third pair; pushed to OWN fork and
remoteSHA verified, no code edit/main/release. Same CI rerun: all index-job steps
SUCCESS, including every manifest and index. Full original failure and rerun
JSON retained under runtime-stage1. Source validation was not weakened; all8
native manifests passed even in the initial red run. No timing repeated.

Provenance: own experiment/driver and source-function smoke adaptation; existing
attributed MIT wrapper unchanged. No new foreign implementation/tests imported.
