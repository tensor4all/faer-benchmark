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
The production internal matmul file is byte-identical to upstream0539947
(`negative-identity.json`); upstream itself was NOT separately executed.

`spicy_matmul` shrinks A/B and either destination or index views for native
strict/unit triangular output, then passes the original dimensions to the native
call. With an empty1×1 strict lower triangle it changes the parent's diagonal
7→8. With a nonempty3×3 destination cut from an allocated4×4 parent it changes
the protected parent row7→20. Buffers have allocated extra source/destination
rows/columns; there is no new unsafe in the reproducer. Both tests fail with
exit101 in `both-negative.log`; `empty-negative.log` retains the first test too.
No implementation has been applied and no test pass is claimed.

All five current production call sites use Rectangular or non-strict
TriangularLower. The strict/unit branches are not reached by those callers;
this is not evidence of a public-path failure or an explanation of performance
regressions. Correct the extent mismatch independently before extending the
shared native budget policy, without adding unsafe/API/thresholds or mixing the
correctness fix into a timing acceptance claim.

`pre-plan.md` records the proposed native-local effective-dimension/empty-return
fix. Independent PRE review on gpt-6.1-sol is pending. Planned checks include
real/complex, strict/unit lower/upper, empty and nonempty guarded views, and
indexed/unindexed valid mappings. Existing upstream notices remain intact; the
new tests are own code, not imported vendor tests. No upstream tracker submission
or permission to make one follows from this record.
