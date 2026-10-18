# PRE: reject incomplete candidate-comparison input, without changing statistics

## Reproduced CLI defect, not merely a helper concern

Pinned toolkit8484fb54, harness source b86fde2. Offline `data/probes/20261018-candidate-coverage-audit/reproduce.py` clones a real previously validated45-CSV/3-start run using read-only symlinks; original data never modified. Full baseline fixture validates via existing validate_run.validate including git. Existing official candidate_compare.py returns0 in ALL these cases:
1. Candidate result_files=[]: control over0 cells 'reproduces', fork0.
2. Remove upstream rows from candidate CSVs: control0 'reproduces', fork396.
3. Omit run2 files despite declared aa=3:2 starts accepted, control396/fork396.
4. --cells __no_declared_cell__:both0, accepts.
5. Valid candidate f64-only grid vs full f64/c64 baseline, NO --cells:each run individually validates, but CLI silently intersects down to198 cells instead of396.

before.json stores exact outputs, candidate validation errors and exits. Existing validate_run/timing_evidence already reject1–3 when called, but the CLI never calls them; they cannot catch4–5. This is a trust-boundary correctness fix, not new adoption criteria. Preserve all old failed LU controls and outcomes; do not rerun the pairs. No measurements, statistical thresholds or host settings changed.

## Smallest compatible implementation

A. CLI scripts/candidate_compare.py calls existing validate_run.validate on BOTH run.yaml inputs before comparison. Print refusal/errors and return1 for invalid evidence or parsing/I/O failure. Reuse current schema/census/group/rotation/sample/git checks, no new validation framework. Keep same measured-code and identity gates. Explicit cells splitting preserves current substring semantics, but rejects empty tokens; omitted --cells still means all recorded cells.

B. Toolkit candidate.py comparison pairing must use NONEMPTY equal selected sets, not an intersection; every requested substring must actually match recorded cells on each side, including legitimate skipped rows (not only timed rows). With no selection both full measured sets must match; a legitimate f64-focused candidate can still compare to a fuller baseline using explicit --cells f64. Preserve supported skips, and do not require fork/control engines to have identical supported sets to one another. Each comparison nevertheless needs nonzero controls AND nonzero fork cells; no success from an empty set.

C. Preserve public `series()` six-part key and signatures. Internally extract its existing read loop to `_series()` returning (old rows mapping, full timing_evidence.cell identity mapping). Public series() returns just the old mapping. Reject duplicate projected cell/repeat or distinct full identities aliasing one old key, rather than overwrite silently. Full identities include regime/batch/k/variant; assert baseline/candidate full identity matches for every selected projected key. This prevents same-key different-batch/regime comparisons without breaking existing output key shape. No source reads outside manifest-listed result_files; rejected archives stay excluded.

D. One private `_paired_series()` shared by control_check/fork_comparison reuses `_series`, normalizes nonblank requested substrings, checks each selector against recorded identities INCLUDING legitimate skips in both, then checks equal nonempty selected TIMED keys AND full identities independently per engine, and requires each selected cell's process IDs exactly {run0..run(aa-1)} on BOTH sides (aa equal and >=2). Raise ValueError with reason on invalid pairing. Valid series are returned to unchanged median/min-max±5% control and unchanged geometric/SD fork calculations. CLI catches ValueError/I/O/parse errors and refuses instead of traceback or success. Remove now-unneeded intersection/len<2 continue branches. Existing fixtures claiming aa3 while only writing2 starts must be corrected to aa2, not grandfathered in.

No target/guard cutoff change, threshold waiver, automatic adoption, selector exact-match redesign or public API added. Exit0 remains descriptive after identity/control/input gates; slower fork cells still printed, not silently adopted. No per-host tuning. No raw evidence edited; raw rejected archives preserved. This does not establish old accepted comparisons were incomplete; actual full datasets remain subject to validation.

## Focused checks / acceptance

PRE is COMPLETE (report `20261018-candidate-completeness-pre-review.md`). Mandatory correction verified against series()'s status filter: selector existence includes recorded skips. Both runs with control lu skipped/gemm timed and fork lu+gemm timed MUST pass explicit --cells lu,gemm; a nonexistent token plus gemm must refuse. Timed control/fork support sets remain independent and each nonempty.

- Existing toolkit tests continue with accurate fixture aa. Add negatives for empty sets/engines; missing whole cell;2 of3 starts; mismatched repeats; duplicate projected key; differing regime/batch identity; missing one of a multi-token selection; empty token. Add valid explicit subset and variant-note preservation; untouched rejects archive test stays.
- CLI test uses real validated fixture or small valid v2 fixture, proves all five reproducer cases return1 after fix, positive identical full396 passes, valid f64-only comparison passes only when explicitly selected, unrelated bad/missing rows refused by reused validator. No mocking away the actual timing validator or comparison functions in these end-to-end cases.
- Run focused tests, all toolkit Python tests, Ruff, script tests and diff checks. No Cargo or benchmark needed for this tool fix. Record before/after exactly; no relaxed statistical gate or timing/source edits.
- Bounded independent POST of final diff, source/caller scope and provenance required. Same existing toolkit feature branch may carry the related correction; push remotely reachable SHA/update requirements only after verification, batch the changes rather than inventing a release/PR. No library source changes in this slice.

## Ownership / provenance

Bounded writer scope if delegated: campaign-toolkit/campaign_toolkit/candidate.py and tests/test_candidate.py; faer-benchmark/scripts/candidate_compare.py and focused CLI tests; records/docs. Main retains integration/final checks. No overlapping writer in same files, no measured run/build concurrently. Own changes to existing repository code; MIT notices retained, no foreign implementation/tests.
