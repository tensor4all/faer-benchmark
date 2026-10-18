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

## Proposed minimum repair (not yet implemented)

Reuse existing `validate_run.validate` at the CLI. Pair nonempty equal selected
full identities and exact declared starts instead of intersections; every
requested substring must match. Preserve existing substring semantics and the
public six-part series key, but reject aliases/duplicates internally. Legitimate
explicit f64 subset remains supported. Preserve raw medians, range±5%, geometric
ratios, all skipped cases, and manifest-only result selection (no archive glob).

Plan: `docs/reviews/20261018-candidate-completeness-plan.md`. Independent bounded
PRE on the same gpt-6.1-sol is pending. Final implementation needs focused and
full Python/CLI checks plus completed POST. No threshold relaxation, library
source change, new API/framework, third LU pair or large-tier run follows.

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
