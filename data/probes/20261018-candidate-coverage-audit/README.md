# Offline audit of candidate-comparison input coverage

**Confirmed CLI defect, not performance evidence.** No new timing was executed.
Source run: committed `20261018T070736Z-upstream-lu-baseline` (45 timing CSVs,
three complete starts,396 supported fork/control cells). `reproduce.py` builds
throwaway fixtures from read-only symlinks, removes a fixture symlink before
rewriting that fixture, and never edits original run evidence. The full baseline
fixture passes existing schema/declaration/git/v2 verification validation.

At toolkit8484fb54 and harness b86fde2 (fingerprints in `provenance.json`), the
actual official CLI returns0 in all five cases (`before.json`, full outputs):

| Fixture | CLI result | Existing run validator |
|---|---|---|
| empty result_files |0 controls,0 fork, exit0|rejects|
| no upstream rows |0 controls,396 fork, exit0|rejects|
|2 starts of declared3 |396/396, exit0|rejects|
| nonexistent --cells substring |0/0, exit0|both inputs valid|
| valid f64-only candidate without explicit subset |198-cell intersection, exit0|both inputs valid|

This establishes an end-to-end acceptance-input hole. It does NOT show that the
original paired runs had holes: they validated in full, and both LU pairs remain
refused for actual moved controls. No old failure is converted into adoption.
A comparator exit0 is already descriptive rather than automatic approval of a
slower fork; that statistical/adoption contract will not be changed here.

## Implemented and reviewed repair

Reuse existing `validate_run.validate` at the CLI. Pair nonempty equal selected
full identities and exact declared starts instead of intersections; every
requested substring must match. Preserve existing substring semantics and the
public six-part series key, but reject aliases/duplicates internally. Legitimate
explicit f64 subset remains supported. Preserve raw medians, range±5%, geometric
ratios, all skipped cases, and manifest-only result selection (no archive glob).

Plan: `docs/reviews/20261018-candidate-completeness-plan.md`. Independent bounded
PRE on gpt-6.1-sol is COMPLETE. Its mandatory correction was verified: selectors
match recorded identities including legitimate skips. Paired recorded sets also
retain skipped-cell completeness; timed support sets stay independent per engine.
The ordinary worker exhausted its budget with failed tests/incomplete CLI coverage;
its checkpoint is archived as INCOMPLETE, not an approval. Main finished the
implementation and tests. Bounded gpt-6.1-sol POST is now COMPLETE across all
requested areas, no findings/deletions. Full report archived in
`docs/reviews/20261018-candidate-completeness-post-review.{md,json}`. No independent
test execution or performance/adoption approval; supplied LICENSE paths were
absent, so reviewer did not independently verify license text. No threshold relaxation, library
source change, new API/framework, third LU pair or large-tier run follows.

## Observed after results

`after.json`: all5 previously exit-zero negatives now exit1. The first3 fail the
existing whole-run validator; unmatched selector and valid-but-undeclared-subset
fail explicit pairing. No threshold/statistical/adoption rule changed.
`positive-full.json` and `positive-f64.json` retain396/198 complete control+fork
cells respectively, with identical-data ratios1. Original manifest hash matches
`provenance.json`, and original tracked source-run files are clean. No timing.

Final tests: toolkit63pass; harness unittest9pass, including6 real CLI tests with
a synthetic fully-valid v2 census and temporary Git measured tree (no validator/
comparison mocks or local faer checkout dependency). Explicit lu,gemm accepts a
control lu skip while fork times both; bad token plus gemm refuses. Missing evidence
on either side is not excused by an f64 subset. YAML, missing file, CSV-parser and
output-I/O failures refuse; slower fork cells still yield descriptive exit0.
Ruff/py_compile/diff checks pass. Test logs retained adjacent. The real5-case after
capture preceded the additive CSV-error guard; that final guard is covered in
final CLI tests, not a changed pairing/statistical decision.

Offline rechecking the original TWO LU pairs still refuses396-cell controls
with exactly1 and12 failed cells (`old-pair-*-still-refused.log`). This is NOT a
third timing pair or reversal of their non-adoption. Toolkit9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5 is pushed on the existing
`fix/rejected-attempt-retention` feature branch; remote SHA verified. Harness
requirements now pin that reachable commit. No release/main merge. Remaining
local CI content gates are recorded in the worklog; new recordings remain separate.

Reproduce from any cwd:

```sh
python3 /path/to/faer-benchmark/data/probes/20261018-candidate-coverage-audit/reproduce.py \
  --json /tmp/candidate-coverage-current.json
```

The script prints/records actual outcomes; before/after comparison must inspect
refusal exits and valid explicit-subset positives, not hide a failure by changing
the expected result. Existing toolkit/YAML/CSV/Git facilities only; no foreign
implementation/tests or notice changes. The adjacent source reproducer is an
audit, not a benchmark or new declaration.
