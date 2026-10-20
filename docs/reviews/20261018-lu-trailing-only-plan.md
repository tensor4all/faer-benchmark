# LU trailing-product-only caller budget: bounded independent PRE

Base: main7364be5ce22d950343c10d82b99e9fc79d537cd2, upstream0539947ffb757a739d7e703a7d2fa0c792a909c1. This is NOT the copy60de/native-floor/correctness candidate. No implementation/build/timing yet.

## Smallest real hypothesis

Fork LU gates both its panel TRSM and trailing GEMM using A11 area and the existing public par_threshold. Dense GEMM already has its own work-aware native/generic floors. Restore the caller's par ONLY for the trailing GEMM argument, leaving the panel's par_here calculation/call, permutation floor, recursion, row-major adaptation, leaf GEMM implementation/defaults/params, arithmetic/views/scratch/API unchanged. Replace the now-inaccurate enclosing comment and affected test explanation; no new helper, threshold, type condition, unsafe, dependency, attribute, flags, heap or scratch.

The claimed benefit is a hypothesis, not measured/adopted. An area floor independent of K can suppress leaf-admissible work; entrust the already-adopted leaf policy rather than add another work model. No machine/shape-specific tuning. Explicit caller Seq remains Seq, caller degree remains the ceiling. Review the public par_threshold documentation/custom-param semantics rather than silently assuming compatibility.

## Genuinely different from old unaccepted LU experiment

Olda53774682edd4e96f0387a80ddaa7bec2f3d1d70 restored BOTH TRSM and GEMM to caller par, and its two formal pairs failed canonical controls. Those failures remain; NO third identical pair or acceptance from descriptive gains.

This variant retains TRSM's existing area gate. In default square256 recursion, the first split is128 and A11 area equals128*128, so panel par_here is Seq. TRSM(n128,k128) hits `k >64 && n <=128` and invokes join_raw with that passed budget. Olda537 instead passes caller Rayon there. This is a material scheduling-policy difference, not helper/direct-expression/source-position/assembly fitting. It is not claimed that this source argument trace measures utilization or proves performance causality.

## Checks and decision boundaries

Reuse implementation-owned real/genuine-complex C/F reconstruction/permutation tests from reviewed a537, Seq/owned4/owned8, 64/256 squares and129x65/65x129. Existing 96/128/192/256/512 numerical test remains, explanation corrected (256 equality is NOT above strict area floor). Focused/full library, no-Rayon std,linalg check, touched formatting/diff and coherent self-review. No private hook/framework or claim these tests observe exact budget/utilization. New test code is project-owned reuse, not vendor import.

If independent PRE/source review finds the variant is not genuinely distinct or changes a promised public contract, stop and resolve rather than disguise a retry. Finished-source POST before archival push/performance build. Freeze exact source/tool/config/argv, use real full-checkout builder/linkage metadata. Existing ALL4 matching dense sizes/normalized-body pre-timing gate is binding before ANY performance verify/timing; mismatch means HOLD without code/flag/alignment/position tuning or selective retry. Equality is not reference/caller/whole-program equivalence or adoption.

Only if statically qualified: preregister a fresh focused canonical pair for this different policy with all affected LU/solve shapes/dtypes/layouts/budgets and fullpiv/Cholesky/GEMM guards, exact skips/starts/rotations, unchanged upstream controls/normal criteria/retention. No timing is authorized by this source PRE; do not implement a new recorder in advance. No final-only large squares, main/pin/release change or final campaign/final-freeze claim.

## PRE outcome: HOLD before implementation

Completed independent gpt-6.1-sol PRE confirms distinctness from olda537, but
finds a public/custom par_threshold behavior change. Verified directly: a
threshold of usize::MAX currently passes Seq to the recursive product; the
proposal passes caller par instead and the leaf has no LU-parameter input.
This does not imply all LU was previously sequential (the final wide TRSM
already takes caller par). No unsupported claim of whole-LU sequential control.

No implementation, new build or timing. Do not add a default-value exception,
alternate threshold, hidden tuning knob or scheduling hook to bypass the issue.
Ask whether to restore upstream-style trailing-product control and explicitly
narrow/document this fork knob, or retain current custom-parameter behavior and
hold this experiment. A goal-continuation message is not authorization. Existing
oldpair failures and all4 gate remain binding. Full report archived separately.
