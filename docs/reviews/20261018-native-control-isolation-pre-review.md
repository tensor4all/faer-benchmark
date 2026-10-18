## Files reviewed
Paths relative to `/home/shinaoka/projects/tensor4all/faer-benchmark/`:
- `docs/reviews/20261018-native-control-isolation-plan.md` — complete, lines 1–90.
- `fbench/src/main.rs` — lines 332–405, 470–810; selected argument/default excerpts at lines 139–301.
- `fbench/src/timing.rs` — complete, lines 1–77.
- `fbench/src/op.rs` — complete, lines 1–127.
- `benchmarks/scripts/pinned.sh` — complete, lines 1–81.

Read the ponytail and independent-review skills. No commands, edits, builds, tests, timing, or repository discovery performed.

## Status
**COMPLETE — bounded diagnostic PRE scope reviewed.**

No Critical or Important findings. The design is acceptable for **diagnostic-only implementation**, subject to the operational-driver POST already required by the plan. This is not execution approval, performance approval, or acceptance of `7f713a1`.

## Focus area verdicts

1. **Acceptance boundary: PASS.**
   The plan preserves the refusal, forbids stage2, excludes another LU adoption pair, and requires separate explicit approval for changes to the formal contract (`…plan.md:5–11,74–86`). Fixed-reference adoption and worker-policy changes are not smuggled into this experiment (`…plan.md:42–45`).

2. **Runtime intervention: PASS, with a wording finding below.**
   Row filtering precedes construction; dispatch for `faer-upstream` calls only the upstream operation builder (`main.rs:332–343,482–567`). Thread configuration nevertheless initializes vendor and both faer budgets (`main.rs:369–391`). Thus this removes fork/vendor **operation execution**, not every binary, initialization, or vendor influence—appropriately acknowledged at `…plan.md:44–45`.

3. **Family/shape/budget coverage: PASS.**
   For batch 1, the declared grid is exactly:
   - Cholesky: `3 × 2 dtypes × 2 layouts × 3 budgets = 36`.
   - GEMM: the same, 36.
   - Triangular solve: `2 × 2 × 2 × 3 = 24`.

   Total: **96 cells per schedule block**, 768 across eight blocks (`…plan.md:47–59`). The harness defaults batch to 1 (`main.rs:218–223`). The POST should check exact identities, including batch, rather than count alone. This grid must not be presented as coverage of all canonical stage1 cells.

4. **Retries and retention: PASS at design level.**
   The plan prohibits selective retries and success-based stopping (`…plan.md:53–67`). Existing `pinned.sh` stops on command failure and archives post-guard-rejected stdout, CSV, and guard evidence (`pinned.sh:55–76`). Its default is **three** attempts, so the driver must explicitly establish the planned eight-attempt maximum (`pinned.sh:30`).
   **Retention limit:** timed samples remain in memory until successful measurement return, and CSV is written only after the run loop (`timing.rs:16–31`; `main.rs:584–599,679–686`). “Raw incomplete evidence” cannot promise recovery of unflushed samples after failure or timeout. Retain everything actually available and state this limitation; do not change the harness.

5. **Bounds, identity, topology, and 1T safeguards: PASS as PRE requirements; implementation unverified.**
   Immutable hashes, campaign locking, topology/power/source checks, explicit 1T readback, single-L3 measurement, outside-domain observation, and process-group deadlines are required (`…plan.md:31–40,60–70`). The source validates requested Rayon/vendor thread counts (`main.rs:369–391`).
   `pinned.sh` alone does **not** enforce the complete safeguard set and can fall back to unpinned execution (`pinned.sh:33–36`); POST must verify fail-closed driver checks. A 120-second wrapper deadline can expire before eight attempts when prechecks incur 30-second waits (`pinned.sh:31,49–53`); that is acceptable as a documented abort, not a completed block or permission to retry externally.

6. **Interpretation and provenance: FINDING — Minor.**
   The final interpretation is appropriately non-causal and requires reporting all cells and spread (`…plan.md:78–86`). Two explanatory claims need narrowing below.

## Findings

### 1. Minor — “MKL alone cannot explain everything” is stronger than the evidence
**Evidence:** `…plan.md:22–24` dismisses an MKL-only explanation because triangular-solve vendor entries are skipped. But the same paragraph correctly recognizes preceding worker/allocation/cache history (`…plan.md:19–22`). Skipping that family’s vendor operation does not, by itself, exclude vendor initialization or preceding vendor work.

**Smallest correction:** Replace with: “Triangular solve also moved despite having no vendor row; this does not exclude vendor initialization or preceding vendor history.”

### 2. Minor — Distinguish schedule blocks from actual process starts
**Evidence:** `…plan.md:56–59` describes eight “binary starts,” each spanning three families and three budgets. The runtime has one thread budget per invocation and configures its global pool once (`main.rs:160,369–380,470–480`).

**Smallest correction:** Say **eight ABBABAAB schedule blocks, each containing nine fresh timing invocations: 72 timing processes, plus 18 verification invocations**. Each block contributes 96 cells. This avoids treating the block as one shared-history process.

### 3. Minor — Provenance statement overlooks the reused wrapper’s ancestry
**Evidence:** `…plan.md:88` says “Own project protocol,” while `pinned.sh:15–20` explicitly attributes its copy/adaptation to `tlinalg-rs` and `tprims-rs`, including MIT provenance.

**Smallest correction:** Say “Own experiment data; existing attributed protocol reused unchanged; no new foreign implementation/tests imported.” Preserve existing notices. No new import or license change is proposed; broader license compliance was not audited.

## Delete list
- `…plan.md:22–24`: **delete** the unsupported MKL exclusion; retain the narrower observation.
- No proposed framework, dependency, harness modification, extra acceptance pair, or redundant experiment needs adding. Keep source changes and recompilation out of scope.

## Summary
**No must-fix Critical/Important findings.** Three small wording corrections improve scientific accuracy, process-count precision, and provenance.

Canonical results, hashes, disassembly claims, and historical counts were supplied context—not independently reverified. Before execution, the bounded driver POST must verify the exact 96-cell identities, 72-process schedule, unchanged runtime policy, fail-closed safeguards, deadlines, and evidence retention. Canonical refusal and non-adoption remain unchanged.
