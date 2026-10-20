## Files reviewed

Paths relative to `/home/shinaoka/projects/tensor4all/faer-benchmark/`, unless noted. Reviewed exclusively from `/tmp/native-control-isolation-post-bundle.md`.

- `data/probes/20261018-native-gemm-budget/isolate_controls.py` — lines 1–206, complete.
- `docs/reviews/20261018-native-control-isolation-plan.md` — lines 1–96, complete.
- `docs/reviews/20261018-native-control-isolation-pre-review.md` — lines 1–67, complete.
- `benchmarks/scripts/pinned.sh` — lines 1–80, complete.
- `fbench/src/timing.rs` — lines 1–77, complete.
- `fbench/src/main.rs` — supplied excerpts, lines 348–395 and 482–600.
- Adjacent `campaign-toolkit/campaign_toolkit/record_run.py` — supplied helper excerpt, lines 51–150.

No commands, edits, builds, tests, or timing performed. Reported offline checks are the main agent’s evidence, not reviewer execution.

## Status

**COMPLETE — bounded source POST review. Two IMPORTANT findings must be resolved before diagnostic recording.**

This is not performance approval or adoption approval. External-input and provenance limits are listed below.

## Focus area verdicts

| Focus area | Verdict and evidence |
|---|---|
| **Diagnostic/adoption boundary** | **PASS.** The corrected plan preserves canonical refusal, prohibits stage2 and another LU adoption pair, and explicitly rejects causal/adoption conclusions from noncontemporaneous measurements (`…plan.md:74–96`). Driver metadata marks the run diagnostic-only and adoption false (`isolate_controls.py:175–180,198–200`). |
| **Production arguments and row isolation** | **PASS.** Commands explicitly request upstream-only rows, batch 1, f64/c64, the declared shapes and budget, and median/5/250 for timing (`isolate_controls.py:47–54`). Runtime filtering precedes operation construction (`main.rs:482–567`). The plan correctly acknowledges that provider thread initialization remains (`…plan.md:41–45`; `main.rs:369–380`). |
| **Full identities, not counts/intersections** | **PASS structurally, subject to Finding 2.** The audit compares a full `Counter` containing regime, family, dtype, layout, dimensions, batch, row, threads, note and status; it also checks Rayon/vendor readback and five finite positive timing samples (`isolate_controls.py:28–44,57–66`). This is exact multiset equality, not an intersection. The referenced grid itself was not included, so its literal contents remain unchecked. |
| **Schedule and verification-first ordering** | **PASS.** `ABBABAAB`, three families and three budgets produce 72 fresh timing invocations and 768 declared cells. Both sides’ nine verification invocations finish before the timing loop starts (`isolate_controls.py:31–33,69–83,181–196`). Six additional `info` invocations are separate from the 72+18 count. |
| **1/4/8T, topology, observer, boost and power** | **FINDING — IMPORTANT.** The ordinary execution path has explicit budgets, information readback, dynamic L3 discovery, recorder/Pi-thread affinity checks, and boost/power checks (`isolate_controls.py:107–148,181–189`). However, optimized Python removes most enforcement; see Finding 2. Actual host state was not checked. |
| **Source/binary identity and campaign lock** | **FINDING — IMPORTANT.** Verification/timing commands receive before/after source and binary checks, and the nonblocking campaign lock covers information, verification and timing (`isolate_controls.py:150–174`). The six information commands bypass per-command guards and durable failure recording; see Finding 1. |
| **Retries, deadlines and evidence retention** | **FINDING — IMPORTANT, limited to the information path.** Verification/timing commands use the declared timeout, explicit idle/retry policy, no outer retry, retained logs/CSV/rejected archives, and recorded return status (`isolate_controls.py:47–54,126–129,150–169`; `pinned.sh:28–80`). Information-command failures lose captured evidence; see Finding 1. |
| **Terminal marker** | **PASS structurally, subject to Finding 2.** `complete.json` is written only after all loops, audits and a final guard return successfully; output-directory creation refuses reuse (`isolate_controls.py:109,190–200`). No early-success branch exists. |

## Findings

### 1. IMPORTANT — Information commands bypass the guarded, evidence-preserving execution path

**Evidence:** `isolate_controls.py:181–189` runs each information command with `capture_output=True, check=True`, then extracts only `.stdout`.

Consequences:

- On a nonzero exit or timeout, the write at line 185 is never reached. Captured stdout and stderr are not persisted by this driver.
- On success, stderr is discarded.
- These commands have no per-command argv/status record or immediately paired source/binary guards, unlike verification/timing commands at lines 150–169.

Thus a failure in any of the six production information invocations aborts without the required durable available-output/status evidence. The surrounding initial/verification guards are not per-invocation checks.

**Suggested fix:** Give information invocations the same before/after guards and durable argv/stdout/stderr/return-code recording, saving evidence before raising; retain the existing fail-stop/no-retry behavior.

### 2. IMPORTANT — Optimized Python silently disables the safety and completion gates

**Evidence:** Essential checks use `assert` throughout:

- Exact identity, thread readback and sample validation: `isolate_controls.py:60–66`.
- Offline grid validation: `isolate_controls.py:69–101`.
- Linux/taskset prerequisites and source constraints: `isolate_controls.py:107–125`.
- Pi-thread isolation, boost/power, clean source and binary hashes: `isolate_controls.py:133–147`.
- Information readback: `isolate_controls.py:186–189`.

The entry point does not reject optimized execution (`isolate_controls.py:202–206`). With `python -O` or inherited `PYTHONOPTIMIZE`, those assertions disappear. The script can consequently reach `complete.json` without enforcing the promised CSV, power, binary-hash and Pi-thread gates. Some ordinary operations still fail naturally, but that does not restore fail-closed enforcement.

**Suggested fix:** Reject optimized Python explicitly at startup with a non-assert check, before creating output or running subprocesses; no framework or wholesale assertion rewrite is necessary.

## Delete list

- No unnecessary framework, abstraction, dependency or retry layer identified.
- Keep the small offline check and existing guards/evidence paths.
- **Net: 0 lines recommended for deletion solely as over-engineering.**

## Per-file provenance

- **`isolate_controls.py`:** Lines 1–6 name the existing own-project ABBA runner as its source and disclose reuse of `pinned.sh`. The predecessor was not supplied, so the adaptation/ancestry claim was **not independently verified**.
- **Corrected plan:** Lines 92–96 now distinguish own experiment data from the reused attributed protocol; the earlier overbroad provenance wording is corrected.
- **PRE report:** Reviewed as a prior report, not independent proof of its historical measurements or source claims.
- **`pinned.sh`:** Existing ancestry and MIT attribution are visible and preserved at lines 15–22. A baseline diff and complete license files were not supplied, so unchanged-file and full license-compliance claims remain unchecked.
- **Toolkit helpers:** Reused through an import, with toolkit commit/path checks at `isolate_controls.py:120–121`; no copied helper implementation is added by this driver. Only the supplied excerpt was reviewed.
- **Runtime sources:** Reviewed as supplied unchanged-runtime context, not as newly imported implementation/tests. Compiled-byte correspondence was not independently established.

## Unchecked limits

- Canonical `run.yaml` files, `stage1-grid.csv`, campaign configuration, actual binaries/hashes, and historical results were not supplied for independent inspection. The driver derives expected identities and binary references from those inputs.
- The supplied main-runtime excerpt does not include the `ops_for` dispatch implementation, complete CSV emission path, or argument parser; the prior PRE’s broader inspection was not re-executed.
- `boost_state()`, the idle-checker implementation, actual topology/power state, and every live Pi thread were not independently inspected.
- Buffered harness samples lost before CSV emission remain unrecoverable, as correctly acknowledged by the plan (`…plan.md:65–70`; `timing.rs:16–31`).
- No assertion is made that canonical and diagnostic measurements are contemporaneous or that any observed change establishes causality.

## Summary

The bounded driver implements the intended upstream-only schedule, exact multiset audit, verification-first ordering and no-outer-retry design. **The information-command evidence gap and optimized-Python fail-open behavior must be fixed before recording.** Canonical stage1 remains refused/not adopted; nothing here permits stage2, final measurement, or adoption.

Fix the Critical/Important findings above, then request a fresh review.
