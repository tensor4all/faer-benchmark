## Files reviewed
Read all five supplied source packs once, in order:
- `fbench/src/backend.rs` — lines 1–1030.
- `fbench/src/lapack.rs` — lines 690–1425.
- `fbench/src/main.rs` — lines 1–785.
- `fbench/src/op.rs` — lines 1–127.
- `fbench/src/timing.rs` — lines 1–77.
- `fbench/src/shared.rs` — lines 1–349.
- `docs/reliable-measurement.md` — lines 1–115.

## Status
**COMPLETE — bounded numerical/runtime POST review.** All supplied numerical implementations and their prepare → run → check → record paths were traced. No edits, commands, builds, or tests were performed.

**Verdict: acceptable within this scope; no BLOCKER or IMPORTANT findings.** Two MINOR corrections below. This is not approval to publish unperformed large-grid measurements.

## Focus area verdicts
1. **Common adapters and matching fixtures: PASS.** Both faer arms instantiate the same macro (`fbench/src/backend.rs:1029–1030`). Vendor constructors match the corresponding seeds and structured fixtures—for example QR (`backend.rs:233,350`; `lapack.rs:822–823`), solve (`backend.rs:571–572`; `lapack.rs:1121–1122`), and SVD (`backend.rs:687,754`; `lapack.rs:1190`). Different logical C/F fixtures are explicitly disclosed (`docs/reliable-measurement.md:21–25`).

2. **Retained outputs and allocation/drop boundaries: PASS.** Composites clear previous outputs in prepare and produce retained outputs inside run; examples include explicit-Q QR (`backend.rs:373–386`), LU (`backend.rs:442–450`), and vendor SVD (`lapack.rs:1212–1260`). Factor-only vendor QR retains its input/tau buffers and restores them outside run (`lapack.rs:835–865`). Temporary solve factors are created and destroyed inside the measured pipeline (`backend.rs:599–605`; `lapack.rs:1149–1165`), as permitted by the contract.

3. **Checks consume actual outputs: PASS.** Factor-only QR derives Q/R from the timed factors rather than re-factorizing input (`backend.rs:300–335`; `lapack.rs:921–957`). Composite QR checks retained Q and R (`backend.rs:393–407`; `lapack.rs:923–957`). LU, Cholesky, solve, SVD and EVD likewise consume retained factors/results. The permanent missing-execution test first checks a real execution, replaces run with a no-op, prepares again, and rejects a successful check (`op.rs:104–120`).

4. **Complex and rectangular mathematics: PASS.** Shared multiplication and Gram checks conjugate the appropriate operands (`shared.rs:215–270`). QR consistently uses `min(m,n)` for thin dimensions; vendor `orgqr` preserves the backing buffer’s leading dimension on wide matrices (`lapack.rs:890–909,948–957`). Rectangular LU reconstruction and pivot application are consistent (`lapack.rs:1024–1059`). Thin-SVD reconstruction correctly handles faer’s V versus LAPACK’s Vᴴ (`backend.rs:789–799`; `lapack.rs:1286–1300`).

5. **Nonfinite rejection and values-only limitations: PASS.** Residual accumulation turns nonfinite values into infinity, and `max_diff` rejects unequal lengths (`shared.rs:273–290`). Regression assertions cover the former NaN hole (`shared.rs:328–333`). Values-only SVD checks finiteness, ordering and Frobenius identity (`backend.rs:724–739`; `lapack.rs:1269–1285`); its limited assurance is explicitly disclosed (`docs/reliable-measurement.md:44–46`).

6. **Householder variants and timing: PASS.** Both separately labeled variants exist (`backend.rs:862–863,918`). Fixture QR occurs in prepare (`backend.rs:919–928`); run contains only the advertised apply operation (`backend.rs:930–943`). Checks compare the actual target against the alternate apply form (`backend.rs:945–974`). The one-block, non-multipanel limitation is explicit (`docs/reliable-measurement.md:45–46`).

7. **Timer, worker-budget orchestration and census: PASS with MINOR diagnostic finding.** Prepare and prior-output destruction occur outside the clock; the last retained result is checked before cleanup (`timing.rs:18–30`). Main creates one explicitly sized global Rayon pool, configures both adapters, and checks reported budgets before rows (`main.rs:349–368,510–513`); adapters select Seq at 1T and Rayon otherwise (`backend.rs:32–38`). Observations are recorded without claiming active-worker tracing (`main.rs:705–706`; `docs/reliable-measurement.md:58–61`). Verification failures produce nonzero exit status (`main.rs:607–609,662–665`), but failed variant labels are lost as described below.

## Findings
1. **MINOR — failed rows lose the operation’s variant identity.**  
   Successful rows retain `ops.note` (`fbench/src/main.rs:546–558,591–604`), but failure rows emit only the error (`main.rs:561–575,607–621`). Thus a failed Householder block/sequence row loses its explicit variant label (`backend.rs:918`), weakening the promised exact variant census (`docs/reliable-measurement.md:66–68`).  
   **Suggested fix:** preserve the variant label alongside the failure message. Acceptable without blocking this numerical baseline: failures already make the process unsuccessful.

2. **MINOR — vendor QR documentation describes the removed replacement-factorization behavior.**  
   `fbench/src/lapack.rs:813–814` says the check uses “a fresh factorization,” whereas the implementation correctly consumes actual compact factors (`lapack.rs:928–943`).  
   **Suggested fix:** delete or correct that stale sentence.

## Unchecked scope
- Actual Cargo path resolution, checkout cleanliness, frozen revisions, dependency unification, binary provenance and licensing provenance. The intended revisions are documented at `docs/reliable-measurement.md:5–17`, but documentation is not linkage evidence.
- LAPACK ABI shims above the supplied range, `vendor.rs` setter/readback internals, and underlying library implementations.
- Recorder/toolkit validation, cross-process statistics and publication gates, owned by the separate review.
- Execution evidence: supplied reports of successful builds, five tests and small-grid verification were **not independently executed or verified here**. Full large-grid validation and timing remain outstanding.

## Delete list
1. `fbench/src/lapack.rs:814`: **delete:** stale “fresh factorization” sentence; the implementation below already documents the correct behavior.

**net: −1 line possible.** No additional abstraction/dependency deletion is warranted in the reviewed scope.

## Summary
No must-fix numerical/runtime defect found in the supplied implementation. Retained-result checking, allocation boundaries, rectangular/complex math, both Householder variants and explicit worker-budget orchestration satisfy the bounded v2 contract. The two MINOR corrections are acceptable follow-ups; full measurement and provenance readiness remain separate gates.