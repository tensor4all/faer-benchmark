# PRE: minimal native strict-triangle extent correction

Repository/worktree: /tmp/faer-native-gemm-audit, detached baseline7364be5ce22d950343c10d82b99e9fc79d537cd2.
Production is UNCHANGED. Only module-owned reproducer tests were added in
faer/src/linalg/matmul/internal/mod.rs. No implementation has been written.

## Evidence and contract
`spicy_matmul` records nrows/ncols before its native-only strict/unit triangular
handling. Lower drops the first source A row and either the first destination row
or first row index; upper similarly drops B/destination column or column index.
It still passes the original nrows/ncols to private_gemm_x86::gemm.

The new1×1 test already failed on this host with valid parent buffers:
strict lower should write nothing, but parent matrix changed from all7 to
[[8,7],[7,7]]. Log: /tmp/faer-native-strict-bounds-test.log, exit101.
A3×3 parent-canary test is now also present (execution pending). Parent buffers
have an extra allocated row/column; no new unsafe code is used in either test.

Current real callers (3dense in linalg/cholesky/ldlt/factor.rs,2sparse in
sparse/linalg/cholesky.rs) use Rectangular or TriangularLower, not this strict
branch. This is a separate correctness correction while auditing the shared
native call sites, not an explanation of measured performance regressions.

## Proposed implementation (not applied)
Immediately after the existing native view/index adjustments, derive effective
nrows from the adjusted A.nrows() and ncols from B.ncols(). Return if either is
zero; use those dimensions in the existing native call. Keep original dimensions
for the fallback (native-local shadowing), original strides/index semantics,
conjugation/diagonal scaling/Accum/alpha, scratch, scheduling and all thresholds.
No new public API, unsafe, dependency, validation framework or benchmark.

## Verification
Keep the failing empty-triangle reproducer and nonempty parent canary. Extend a
single small module-owned check to real/complex, strict/unit lower/upper,
N=0/1/3, nonzero depth, Add/Replace and indexed/unindexed valid mappings.
Compare stored entries to an independent scalar product and preserve unstored
entries and allocated parent guards. Run focused tests, full library default
features, and no-Rayon std/linalg check sequentially. Do NOT run any performance
recording during builds; do NOT run final-only large tiers.

## Review request
Read actual source and callers before agreeing. Attack dimension/index/mask
semantics, N=1 empty views, rectangular cases and ownership; is recomputing A/B
extents sufficient and the smallest correct fix? Flag mandatory corrections,
missed tests and anything to delete. Read-only: do not edit files or build.
Report BLOCKER/IMPORTANT/MINOR with file:line evidence, Delete list, provenance
and limitations. No performance or adoption approval. Upstream tracker feedback
is deferred by AGENTS.md; there is no permission to submit it upstream.
