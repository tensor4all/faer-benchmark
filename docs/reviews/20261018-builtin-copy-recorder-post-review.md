## Files reviewed
Read `/tmp/builtin-copy-recorder-post.md` **once, completely (lines 1–936)**, including:
- `data/probes/20261018-native-copy-tile/record_public.py` (lines 1–268).
- `data/probes/20261018-native-copy-tile/check_public.py` (lines 1–150).
- Unchanged `data/probes/20261018-owned-copy/src/main.rs` (lines 1–58).
- Complete PRE report, resolution notes, preflight, dummy-check log, draft configuration, fresh static report, selected public-build receipts and scoped status.

Below, recorder/check/probe line references refer to those embedded source files.

## Status
**COMPLETE — bounded operational POST. Three Important findings must be fixed before freezing or recording.**

All requested focus areas were traced within the supplied evidence. No shell commands, repository discovery, edits, builds, tests or timing were performed. The supplied dummy-test results are reported evidence, not reviewer execution or runtime-host qualification.

## Focus area verdicts
1. **Actual recording route: PASS.** `--record PI_PID` reaches `record()`, requires frozen configuration, establishes identities and the campaign lock, and calls real `capture()`/`state()` (`record_public.py:210–258,261–268`). Mocked state is confined to dummy checks (`check_public.py:62–71,89–98`). The supplied draft remains deliberately blocked by the frozen-status assertion (`draft-public-config.json:2`; `record_public.py:212–215`).

2. **Terminal persistence and exceptional receipts: FINDING — Important.** Normal exit/timeout status precedes cleanup, inventory and after-guard, and launch failures get an exception receipt. However, failure of the terminal receipt itself loses the durable original result. See finding 1 (`record_public.py:161–175,192–202`).

3. **Owned-group timeout and interruption lifecycle: FINDING — Important.** New-session ownership, TERM/KILL escalation, bounded direct-child wait and live-group checks are implemented. Interruptible ownership/cleanup windows can nevertheless leave a launched group active. See finding 2 (`record_public.py:73–98,157–190,218–222`).

4. **Absolute phase/capture deadlines: FINDING — Important.** Invocation wait budgets use `min(now + 420, phase_deadline)`, and an expired prelaunch budget prevents launch. The completion path can still declare success after the phase deadline. See finding 3 (`record_public.py:154–165,237–258`).

5. **Coverage, ordering, precision and explicit 1T: PASS.** The probe emits eight shapes × two layouts × two dtypes × two methods, primes for 250 ms and retains five samples. Its index orders are AB, BA, BA, AB (`src/main.rs:3–16,19–40,45–56`). The recorder supplies ABBABAAB and four accepted indices per side; its audit verifies the exact 64-key multiset, five positive finite samples and median consistency at nine-decimal millisecond precision (`record_public.py:31–33,44–57,241–256`). The probe creates a one-worker pool with `Par::Seq`, and runtime acceptance checks its stderr readback (`src/main.rs:47–51`; `record_public.py:251–253`).

6. **Wrapper invocation, retention and retries: PASS within supplied evidence.** The actual route invokes the existing pinned wrapper with `PINNED_RETRIES=8`, `PINNED_CSV`, and no outer retry (`record_public.py:205–207,229–232,242–255`). Per-command `TMPDIR` is already inside retained evidence; inventory is not an evidence-copy prerequisite (`:101–104,144–159,192–195`). Rejection/archive behavior relies on the unchanged wrapper and its completed PRE review; its implementation was not re-supplied here.

7. **Source, probe, static-image and binary provenance: PASS, bounded.** Runtime checks cover four source HEADs and tracked cleanliness, expected toolkit/current extern B/upstream, the compiled-harness comparison, probe-source hashes, static-report hash and four matching/equal bodies, static-image hashes, and public-probe binary hashes/receipt equality (`record_public.py:124–140,223–228`). Selected build receipts agree with the draft A/B identities. This is not independent inspection of the omitted full build graph or reviewer rehashing of actual files.

8. **Runtime L3/observer/power policy and minimality: PASS at source-wiring level.** Real state checks derive cache domains, validate all enumerated pi-thread affinities against the watched L3, assert boost/power policy, and invoke the existing observer-affinity guard before and after each command (`record_public.py:107–123,154,197`). These are point-in-time checks—not continuous isolation proof—and no live host result is supplied. No new framework, statistics or canonical-tool modification was introduced.

## Findings

### 1. Important — Failure to write `terminal.json` discards the original durable result

**Evidence:** After `child.wait()`, `terminal` is assigned before its receipt is written (`record_public.py:162–166`). If that write raises, the outer handler sees a non-`None` terminal and saves only `repr(exc)` (`:167–175`). `errors.json` later contains only the error strings, and the final exception contains no original terminal dictionary (`:200–202`).

Thus, if **only `terminal.json` is unwritable while other receipts remain writable**, cleanup and inventory can finish but the original exit code/timeout classification is absent from durable output. This is a receipt-failure case, not an assumption that a completely failed filesystem can preserve evidence.

The supplied receipt-failure fixture fails `started.json` and `cleanup.json`, not `terminal.json` (`check_public.py:99–113`), so it does not falsify this case.

**Suggested fix:** Retain the original terminal dictionary in a fallback final receipt when its primary write fails; add one dummy case failing only the terminal receipt.

### 2. Important — Interrupts can bypass owned-group termination

**Evidence:**
- The signal handler raises `InterruptedError` (`record_public.py:218–222`).
- Cleanup first calls `group_members()` **before** installing temporary signal ignores (`:176–180`).
- An interrupt there is caught by `except Exception`, which merely appends a cleanup error and proceeds without retrying termination (`:190–191`).

For example, after a timeout receipt, an interrupt during that initial group scan leaves the timed-out command active. Likewise, after an initial interruption in `wait()`, a repeated interrupt in this window can bypass cleanup.

There is also a launch-ownership window: `child` remains `None` until `Popen(...)` returns (`:150,158–159`). An asynchronous exception during construction after OS child creation cannot be cleaned through the later `if child is not None` path (`:176`).

The dummy tests exercise child TERM handling and KILL fallback, but do not send interruption signals to the recorder during launch/cleanup (`check_public.py:117–142`).

**Suggested fix:** Defer interruption across launch/ownership establishment and protect cleanup from its first operation through termination/reaping; add recorder-interruption dummy cases for those windows.

### 3. Important — The phase can be marked complete after its absolute deadline

**Evidence:** The phase deadline is checked at block entry and used to cap the child wait (`record_public.py:237,243–249`). After that wait, capture performs inventory and a full after-guard without another deadline check (`:192–202`). The caller then audits CSV/stderr, performs final state validation, and writes `complete.json` without checking the phase deadline (`:250–258`).

A final child can exit just before the deadline; after-guard/hash/audit work can cross it, yet the run is still declared complete. That is ordinary phase work, not the separately allowed termination grace.

**Suggested fix:** Enforce the existing absolute deadline through post-command validation and immediately before completion; preserve partial evidence and omit completion if it expired. Add a dummy clock/slow-guard boundary check.

## Provenance limits
- The library change at `60de2ee` was outside this review; its separate PRE/POST was not repeated.
- The static report establishes the supplied four-body size/normalized-body comparison only—not RIP-reference, caller, worker, whole-program or performance equivalence (`static-dense/comparison.json`, `limitation`).
- Full build metadata was not bundled; selected receipts are not proof that I inspected the complete dependency graph.
- Existing pinned/toolkit implementations were unchanged and referenced through prior review; helper internals were not independently re-inspected here.
- Python adaptations are attributed to the project's own prior runners/guards. No new foreign implementation is evident in the supplied sources.
- No actual probe process, runtime guard qualification or performance result is approved by this report.

## Delete list
- **Keep deleted:** evidence harvesting/copying before terminal persistence; retained `TMPDIR` replaces that dependency (`record_public.py:101–104,145–159`).
- **Keep deleted:** outer admission retries and the old one-retry override; the existing wrapper owns admission retries (`:229–255`).
- **Do not add:** a generic process framework, new statistics, new adoption gate or canonical-wrapper changes. Correct the three local lifecycle/completion paths instead.
- No additional complexity-only deletion is justified. **Net: 0 additional lines identified for deletion.**

## Summary
The recorder is thin and its coverage, ordering, raw retention and diagnostic-only interpretation are appropriate. The PRE fixes substantially improved the implementation, but **terminal-receipt fallback, interruption-safe ownership/cleanup, and deadline-safe completion remain must-fix before freeze or recording**.

Fix the Critical/Important findings above, then request a fresh review.
