## Files reviewed
- `/tmp/lu-trailing-only-pre.md` — all 711 lines, in one read. Includes the plan, pinned production LU implementation, TRSM branch, dense dispatch excerpt, old candidate diff, and complete reusable numerical test.
- No other files read; no commands, edits, builds, or timing performed.

## Status
**COMPLETE — all supplied focus areas reviewed within the bounded PRE scope.**

**Verdict: HOLD before implementation pending resolution of the public `par_threshold` compatibility issue.** The proposed scheduling policy is genuinely different from olda537, but that does not establish compatibility or performance.

## Focus area verdicts

1. **Distinctness from olda537: PASS.**  
   The old diff restores caller `par` to both calls. The proposal restores it only to the trailing GEMM and retains the panel gate. At square 256, the first split is 128, and `128 * 128 > 128 * 128` is false: the proposed panel receives `Seq`, whereas olda537 supplies caller `par`. The included TRSM implementation then takes `k > 64 && n <= 128` and passes that supplied budget to `join_raw`. This is a concrete scheduling-policy difference, not a source-position or expression rewrite.  
   **Evidence:** bundle lines 16–18; included `factor.rs:100–129`; “Actual pinned base TRSM relevant implementation,” opening branch.  
   **Limit:** this proves distinct inputs to a scheduling branch, not distinct utilization or favorable timing.

2. **Public threshold/custom parameters: FINDING — BLOCKER.**  
   The one-call change bypasses an existing public parameter for recursive trailing products. See Finding 1.  
   **Evidence:** bundle lines 10–12 and 24; included `factor.rs:110–128`; `PartialPivLuParams::par_threshold` documentation.

3. **Caller budget propagation: PASS, narrowly.**  
   Substituting the existing caller `par` does not manufacture a larger budget. Explicit `Seq` remains `Seq`; the native dense branch passes either `par.degree()` or 1, and the generic branch maps the supplied Rayon degree directly. Recursion and permutation gating remain unchanged.  
   **Evidence:** bundle line 10; included `factor.rs:110–128`; “Actual existing dense native floor region,” base lines **1371–1470**.  
   **Limit:** the bundle does not include `join_raw` or the generic GEMM scheduler implementation, so it does not independently prove a whole-execution worker-count ceiling. The defensible claim is preservation of the supplied budget value at this changed call.

4. **Arithmetic, ownership, scratch, layouts and cfg: PASS for the proposed edit.**  
   The same disjoint `A11`, `A10`, and `A01` views, coefficient, accumulation mode, and call order remain. The panel completes before GEMM, and GEMM returns before subsequent factorization. No new borrow, allocation, scratch requirement, unsafe operation, or feature-specific production expression is proposed. Row-major adaptation and the final wide-matrix TRSM are unchanged.  
   **Evidence:** bundle line 10; included `factor.rs:100–129`; full production section, `lu_in_place_scratch` and `lu_in_place`.  
   **Limit:** parallel execution can change floating-point reduction order; unchanged mathematical operations do not promise bitwise-identical factors. This is a design review, not compilation or numerical verification.

5. **Reusable test and verification scope: PASS, with explicit limits.**  
   The supplied test checks reconstruction using the returned permutation, inverse-permutation consistency, real and genuinely complex inputs, both layouts, rectangular cases, and owned Rayon pools. Its use of the returned permutation ends before direct array inspection, so no apparent ownership conflict arises. The old diff guards the test module with `all(test, feature = "rayon")`. Correcting the 256-size equality explanation is necessary and planned.  
   **Evidence:** bundle line 22; old diff’s test-module registration and numerical-test comment; complete reusable test, `check` and `recursive_products_preserve_real_and_complex_lu`.  
   **Limits:** it does not inspect scheduling, prove utilization, exercise custom parameters, cover every dtype, or independently verify the reported transposition count beyond an upper bound. These limits are acceptable for a numerical regression test, but it cannot establish threshold compatibility.

6. **Smallest change, no infrastructure or assembly fitting: PASS.**  
   A single production argument change plus accurate comments is appropriately bounded. No helper, second work model, recorder, tuning knob, or dense-kernel modification is needed to express this hypothesis.  
   **Evidence:** bundle lines 10, 24 and 26.  
   **Qualification:** small diff size does not remove the public-contract issue.

7. **Performance authorization and prior failures: PASS as decision boundaries; performance unproven.**  
   The plan preserves the two failed olda537 formal pairs, prohibits an identical retry, requires the existing ALL4 dense pre-timing gate, and disallows fitting code/flags/alignment/position after mismatch. It requires fresh preregistration rather than treating this PRE as timing authorization.  
   **Evidence:** bundle lines 16, 24 and 26.  
   The native dense excerpt supports the work-aware-floor rationale. The generic excerpt shows budget forwarding, not the generic floor’s implementation; that part of the rationale remains supplied context rather than independently traced source evidence.

## Findings

### 1. BLOCKER — Removing the trailing gate changes the behavior of public `par_threshold`

**Evidence:** The public field is documented as the “threshold at which size parallelism should be disabled.” The pinned implementation explicitly applies it to both the panel and trailing product through `par_here` (`factor.rs:110–128`). The proposal changes only the latter to unconditional caller `par` (bundle line 10).

A concrete custom setting exposes the difference:

- Keep recursion enabled and set `par_threshold = usize::MAX`.
- Supply a multi-threaded caller budget.
- Previously, recursive trailing products receive `Seq`.
- Under the proposal, they receive the caller budget and can become parallel when the dense leaf admits the work.

The dense floor cannot preserve this custom threshold semantics: it never receives `PartialPivLuParams`. This does **not** mean the old parameter disabled every parallel operation throughout LU—the included wide-matrix final TRSM already receives caller `par` directly. It does establish removal of a specific, existing threshold-controlled behavior.

The plan explicitly requires stopping to resolve a promised-contract change rather than assuming compatibility (bundle line 24). That resolution is absent.

**Suggested fix:** Retain the existing gate unless an explicit public-contract change is agreed; if changing the contract is authorized, document the narrowed semantics and add a focused custom-threshold regression test before implementation approval.

## Delete list
- Delete any claim that public/custom `par_threshold` behavior is preserved by the proposed one-call substitution.
- Replace the enclosing two-call scheduling comment; remove the incorrect claim that square 256 is above the strict default floor.
- Do not add instrumentation, private hooks, a new recorder, alternate thresholds, dtype/shape exceptions, or assembly-position adjustments.
- Do not discard prior failed pairs or present numerical reconstruction tests as scheduling evidence.
- No production deletion beyond the proposed argument substitution is justified by this bundle.

## Summary
The proposal is **materially distinct from olda537**, and its arithmetic/ownership/scratch/cfg footprint is suitably small. Its performance benefit remains unproven, and **this PRE authorizes no performance execution**.

The blocking issue is the unacknowledged loss of public custom-threshold control over recursive trailing GEMM. Resolve that contract before implementation.

**Fix the Critical/Important findings above, then request a fresh review.**