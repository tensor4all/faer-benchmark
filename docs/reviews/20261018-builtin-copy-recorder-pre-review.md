## Files reviewed
- `/tmp/builtin-copy-recorder-pre.md` (complete bundle, lines 1–318), read once.
  - Operational plan: lines 1–67.
  - Existing `run.py`: lines 70–125.
  - Existing Rust probe: lines 127–188.
  - Existing `pinned.sh`: lines 190–271.
  - Existing guard/capture pattern: lines 273–315.

## Status
**COMPLETE — bounded operational PRE.** All requested focus areas reviewed against the supplied bundle. **Two Important design gaps must be closed before recording.** No repository discovery, shell commands, edits, builds, tests, or timing performed.

This evaluates the proposed recorder, not the previously reviewed library or an implementation that does not yet exist.

## Focus area verdicts
1. **A/B provenance and immutable inputs: PASS at plan level.** Full-checkout build receipts, metadata/source locks, distinct immutable binaries, stable current extern B, and phase-wide source/hash checks are explicitly required (`/tmp/builtin-copy-recorder-pre.md:16–35`). A recording-time A checkout is unnecessary and correctly excluded. Actual receipts and guard coverage remain POST-review obligations.

2. **Observer/L3/power/1T isolation: PASS at plan level.** The plan requires runtime-derived cache peers, observer and all pi-thread affinities outside the domain, fixed expected power policy, and before/after checks (`:24–36`). The supplied guard checks pi identity, every enumerated pi thread, boost, power, commits and binary hashes (`:275–292`). The Rust probe explicitly creates a one-worker pool, verifies its worker count and selects `Par::Seq` (`:172–185`). These establish the declared configuration—not universal thread-utilization evidence.

3. **Public-copy measurement, coverage and ordering: PASS.** The supplied Rust measures allocation, copy and destruction, primes each method for 250 ms, then retains five individual samples (`:131–145`). Its eight shapes × two dtypes × two layouts × two methods produce exactly 64 rows (`:147–185`). Index-dependent method orders are AB, BA, BA, AB (`:159`, `:181`); the planned eight-process ABBABAAB sequence supplies four starts per binary (`:38–39`).

4. **Raw samples, keys and precision: PASS at plan level.** Exact-key coverage and five positive finite samples are required, rather than a row-count-only check (`:47–54`). Rust emits raw samples separately from the nine-decimal millisecond median (`:165`). Audit median consistency using that output precision; do not require exact equality between the rounded median field and an unrounded sample.

5. **Wrapper retry/rejection policy: PASS.** The new plan explicitly supersedes the old runner’s outer retry and `PINNED_RETRIES=1` (`:107–122`) with the standard wrapper policy and no outer retry (`:40–45`). The wrapper retains temporary evidence on command/archive failure and archives rejected stdout, CSV and checker output before reusing the paths (`:229–267`). Retention here is not permission to select only favorable accepted results.

6. **Failure capture and terminal evidence: FINDING — Important.** The required durable status ordering is not fully covered by the supplied capture pattern or the stated dummy checks. See finding 1.

7. **Deadlines and owned descendants: FINDING — Important.** Numerical deadlines are declared, but the timeout lifecycle is not specified sufficiently to implement safely. See finding 2.

8. **Offline qualification, minimality and interpretation: PASS at plan level.** The planned forged-data and failure-capture checks are appropriately offline (`:50–54`). The comparison retains all identities, starts, samples and flags, and explicitly cannot establish adoption or causality (`:56–67`). No new statistics, canonical-tool modification or generic capture framework is warranted.

## Findings

### 1. Important — Persist terminal status before evidence harvesting, including exceptional launch/timeout paths

**Evidence:** The plan promises status before the fallible after-guard (`/tmp/builtin-copy-recorder-pre.md:47–49`). However, the supplied capture pattern performs log parsing and `shutil.copy2` **before** writing the return code (`:303–308`). An archival error therefore leaves no durable command status. Also, an exception from `subprocess.run` bypasses that entire terminal-record path (`:301–308`). A fake command returning nonzero does not exercise those exceptional paths; the listed checks do not explicitly include them (`:52–54`).

**Suggested fix:** In the existing local capture function, write a terminal result immediately on completion or exception, before harvesting temporary evidence or running after-guards; retain archival/guard failures separately without replacing the original result. Add dummy launch-failure and evidence-copy-failure checks.

This is a small correction to capture ordering and coverage—not a reason for a new capture library.

### 2. Important — Define timeout ownership and evidence handling, not just timeout numbers

**Evidence:** The plan specifies 420 seconds per process and 1,200 seconds per phase, partial-evidence retention and descendant inspection (`/tmp/builtin-copy-recorder-pre.md:43–45`). The supplied capture uses an unbounded `subprocess.run` (`:301–302`), while the wrapper can be sleeping, checking idleness or waiting for the measured child (`:238–265`). Its temporary-evidence announcement depends on shell cleanup (`:230–237`).

Simply adding a Python subprocess timeout can terminate the wrapper without reliably terminating its descendants or obtaining that cleanup announcement. A surviving probe could continue loading the watched domain after the driver reports failure. The plan also does not state how the remaining phase budget limits the next process.

**Suggested fix:** Specify a monotonic phase deadline, cap each invocation by `min(420s, remaining_phase_budget)`, and explicitly own/reap the launched process group on timeout. Persist timeout status first; preserve available wrapper evidence without relying solely on an EXIT-trap message. Verify this with a dummy sleeping child/grandchild, not a benchmark.

The 1,200-second phase cap may legitimately produce an incomplete campaign under repeated wrapper rejection; do not enlarge it silently or retry the phase to obtain completion.

## Summary
The proposed thin paired recorder is appropriately scoped. The probe’s coverage, public methods, sample retention, ordering and explicit 1T/Seq configuration support the intended **diagnostic**, not adoption.

**Must fix before recording:** exceptional capture durability and deadline/descendant lifecycle. The finished driver still needs the promised POST review, offline checks and freeze.

**Delete / do not carry forward:**
- Old runner’s outer admission loop, sleep and `PINNED_RETRIES=1` override (`:107–122`).
- Old current-checkout-only identity as A/B build provenance (`:96–106`); use retained per-build receipts.
- Capture ordering that copies temporary evidence before persisting status (`:303–308`).
- Any new generic capture framework, canonical-tool changes, statistical acceptance logic or causal interpretation.

Fix the Critical/Important findings above, then request a fresh review.
