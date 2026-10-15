# Timing-v2 bounded POST review receipts

Three independent `openai/gpt-6.1-sol` reports completed. The raw reports below
are preserved without rewriting their verdicts. They review the captured,
line-numbered/SHA source packs, **before** the corrective edits below; they are
not blanket approvals of later source or unperformed measurements. None of the
reviewers executed builds/tests or independently verified performance evidence.
`receipts.json` identifies the byte-exact archived reports.

| Scope | Report | Result / disposition |
| --- | --- | --- |
| Core accounting/statistics | [core.md](core.md) | Two IMPORTANT findings reproduced and corrected: C/F cells remain separate even without configured display axes, and one-engine v2 requires at least two process sets so sample SD is defined. Regression checks fail under pre-fix behavior and pass after correction. |
| Numerical/runtime | [runtime.md](runtime.md) | No IMPORTANT/BLOCKER finding in the reviewed scope. MINOR corrections retain the variant in failed rows and replace the stale fresh-factorization comment. Numerical implementation is unchanged by these corrections. |
| Recorder/provenance | [recorder.md](recorder.md) | Two IMPORTANT findings corrected: editable own-Git-root provenance, and publication/index exit propagation. Tests reject enclosing/non-Git installs and propagate injected index status 37 through publisher/recorder; no-publish returns 0 without either mutation. |

The recorder's MINOR default-AA issue is explicitly deferred to protocol freeze:
three-engine v2 currently requires explicit `--aa 3`; provisional suite-wide
budgets must not be adopted as an accidental CLI default. The generic accepted
minimum is two sets plus complete engine-order cycles, not necessarily three
sets for one- or two-engine campaigns.

Corrective checks (no new review cycle is claimed):

- Toolkit: `python3 -m unittest discover -s tests -v` (28 tests), Ruff, schema
  mirror equality, and the fixture declaration gate.
- Harness: formatting, affected vendor-feature Rust checks, and corrected-source
  recorder smokes are required before control admission; their results are
  recorded in the campaign worklog as they actually finish.
- Diagnostic driver: explicit smoke-directory arguments avoid a source-identity
  cycle from committing generated timestamps. Its software-only write-safety
  test preserves an existing first-attempt metadata file. Driver/analysis source
  hashes and full argv are recorded at execution.

Broad numerical verification, representative stability controls, budget freeze,
and full baseline recording remain separate gates. Historical raw data/pages
are not corrected retroactively, and matching provider estimates are not a
validity criterion. The saved optimization candidate remains outside the baseline.
