# Native GEMM caller audit and a separate correctness reproducer

This is not a performance run or adoption evidence. The Householder stage ended
before these Cargo commands; no recording overlapped them. The cache doctor
verified all33,980 entries with zero corruption before this separate worktree.

## Real call graph / floor lead (unmeasured)

Native private_gemm_x86 entry points exist in:

- `faer/src/linalg/matmul/mod.rs`: the adopted dtype-flop floor.
- `faer/src/linalg/matmul/triangular.rs`: native lower-output call returns before
  the generic fallback's work floor; it receives `par.degree()` directly.
- `faer/src/linalg/matmul/internal/mod.rs`: indexed/diagonal `spicy_matmul` has a
  fixed32³ MAC gate, not the dense dtype-flop floor. Used by dense LLT/LDLT and
  two sparse Cholesky update sites. These are real callers, not a hypothetical
  new backend. Extending/reusing the existing floor is a lead, not a measured win.

## Separate strict/unit extent bug: reproduced, implementation pending

In a detached worktree of library main7364be5ce22d950343c10d82b99e9fc79d537cd2,
only module-owned tests were added. Apply `reproducer.diff` to that commit with
`git apply --unidiff-zero /path/to/reproducer.diff`.
The pre-fix production internal matmul file is byte-identical to upstream0539947
(`negative-identity.json`); upstream itself was NOT separately executed.

`spicy_matmul` shrinks A/B and either destination or index views for native
strict/unit triangular output, then passes the original dimensions to the native
call. With an empty1×1 strict lower triangle it changes the parent's diagonal
7→8. With a nonempty3×3 destination cut from an allocated4×4 parent it changes
the protected parent row7→20. Buffers have allocated extra source/destination
rows/columns; there is no new unsafe in the reproducer. Both tests fail with
exit101 in `both-negative.log`; `empty-negative.log` retains the first test too.
At that initial checkpoint no implementation had been applied; those negative
logs are not test passes. The implemented follow-up is recorded below.

All five current production call sites use Rectangular or non-strict
TriangularLower. The strict/unit branches are not reached by those callers;
this is not evidence of a public-path failure or an explanation of performance
regressions. Correct the extent mismatch independently before extending the
shared native budget policy, without adding unsafe/API/thresholds or mixing the
correctness fix into a timing acceptance claim.

`pre-plan.md` records the original native-local effective-dimension/empty-return
plan. Its first broad PRE attempt was incomplete; the later bounded PRE completed
as recorded below. Planned checks include
real/complex, strict/unit lower/upper, empty and nonempty guarded views, and
indexed/unindexed valid mappings. Existing upstream notices remain intact; the
new tests are own code, not imported vendor tests. No upstream tracker submission
or permission to make one follows from this record.

## Implemented follow-up (local, NOT integrated/performance-accepted)

Two reduced, self-contained gpt-6.1-sol PRE consultations completed; their verdicts
and limitations are recorded in
[the PRE review record](../../../docs/reviews/20261018-native-gemm-empty-pre-review.md).
The first approved post-shift dimensions and required zero-depth testing. That
exposed a second existing defect: K=0/Replace leaves stored entries unchanged
(`zero-depth-negative.log`). A separate PRE approved a common empty-product path
after existing index validation, before native shifts/dispatch or fallback.

`fixed.diff` (apply with `git apply --unidiff-zero`) contains the25-line production
correction and module-owned checks. It keeps original logical masks/index mapping,
unit/strict diagonal preservation, scratch, positive-depth scheduling and all
thresholds. New native-local dimensions fix the unsafe extent mismatch. K=0/Add
returns unchanged; Replace zeroes only stored logical entries through existing
maps. No new unsafe/API/dependency; no imported implementation or tests.

`fixed-identity.json` records source checksum and exact validation commands.
`focused-fixed.log`:4 tests pass. After targeted formatting, `library-fixed.log`:
214 pass/2 existing ignore; `no-rayon-fixed.log`:std/linalg check passes,13 warnings
all in untouched files. The scalar oracle covers f64/c64, all seven structures,
K=0/2, empty/one/nonempty/square/rectangular shapes, Add/Replace, four mapping
presence combinations with descending nonidentity maps, conjugated A, real D,
complex alpha and all parent guards. `positive-depth-fixed.log` preserves the
separately isolated positive-depth pass while K=0 was still failing.

Host AVX2/FMA/AVX512F and default std/native scalar dispatch are recorded; a
forced-generic numerical run or separate f32/c32 fixture is NOT claimed. These
are correctness tests with Par::Seq, not performance measurements. Self-review
then added an explicit finite-output assertion before norm_max. Both focused and
full checks passed again (`focused-finite-fixed.log`, `library-finite-fixed.log`);
production matches the POST snapshot exactly, so the no-Rayon check still applies.
The source checksum and local commit are updated in `fixed-identity.json`.
The final independent POST review is pending. No source combination, performance adoption,
final candidate freeze, large-tier execution or upstream submission has occurred.
