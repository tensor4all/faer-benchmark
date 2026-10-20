# Native GEMM empty-boundary PRE reviews

Main-agent record of two **completed** independent read-only consultations on
openai/gpt-6.1-sol. This is a faithful decision/limitation summary, not a claim
that the reviewer executed tests. The earlier broad14-tool-call attempt failed
and was INCOMPLETE; it is not counted as review.

## PRE1: post-shift native dimensions — COMPLETE

Input: `/tmp/native-bounds-pre-bundle.md`, a self-contained15KB snapshot of the
plan, internal wrapper, fallback logical masks, BlockStructure enum and all five
actual caller excerpts. Reviewer used read-only `subagent_consult`, cwd `/tmp`.

Verdict: **Safe to implement as proposed**, no mandatory plan correction. The
existing IMPORTANT defect is stale dimensions after A/B and destination/index
view shifts. Native-local `nrows=A.nrows()`, `ncols=B.ncols()`, then zero-output
return is sufficient and minimal. Original dimensions must remain for fallback.

- Strict/unit lower: effective `(m-1,n)`, logical row `r=i+1`; inclusive native
  `c<=i` means original `c<r`.
- Strict/unit upper: effective `(m,n-1)`, column `c=j+1`; inclusive native
  `r<=j` means original `r<c`.
- Same coordinate reasoning covers indexed/unindexed and rectangular cases.
  A1×N upper or M×1 lower can remain nonempty; test adjusted dimensions, not an
  unconditional dimension-equals-one rule.
- Unit destinations preserve physical diagonal storage; do not write ones.
- Existing actual callers use inclusive lower/rectangular, with unchanged extents.
- Do **not** return unconditionally for `depth==0`: Replace still needs zeroing.

Required checks: retain N=1/N=3 reproducers; real/complex, strict/unit lower/upper,
zero/one/nonempty and both orientations of rectangles, Add/Replace, all four
index-presence combinations with nonidentity maps, scalar-product oracle and
parent guards, positive and zero depth, verified native dispatch plus separate
build/fallback limitations. Optional MINOR deletion: old pre-shift zero checks are
redundant with entry checks. They were retained to keep the correction local.

Limits: supplied source/contract only, not private backend internals or an
independent test execution; omitted/unrelated code, performance and adoption
were outside scope. No imported implementation/test code or notice changes.

## PRE2: zero-depth Replace addendum — COMPLETE

The mandatory zero-depth test then reproduced a separate existing defect: native
K=0/Replace leaves7 instead of zero in stored strict-lower entries. Evidence is
`data/probes/20261018-native-gemm-callers/zero-depth-negative.log`.
Input: `/tmp/native-zero-depth-addendum.md` plus the earlier source bundle.

Verdict: **Safe to implement as written**, no mandatory correction: place the
common empty-product branch after existing index validation and before native
view shifts/dispatch/fallback. Add returns unchanged. Replace assigns T::zero()
only to original logically stored entries, then maps them to destination indices.

All seven masks were reviewed: Rectangular all; inclusive lower `i>=j`; strict/
unit lower `i>j`; inclusive upper `i<=j`; strict/unit upper `i<j`. Independent
row/column extents correctly handle rectangular tails. Mask logical coordinates,
not physical mapped coordinates: a logical off-diagonal can map onto a physical
diagonal and still must be written. Empty-output entry return and positive-depth
paths remain unchanged. No scratch needed on the common K=0 path.

Required checks: all seven variants, Add/Replace, four nonidentity-map presence
combinations, nonsquare/empty shapes and destination guards. Delete list: none;
do not replace this with an unconditional K=0 return.

Limits: reviewer did not run tests or inspect the backend; the actual dense
empty-product implementation was not included in this second input. Main verified
the existing dense wrapper's K=0 zero-fill in matmul/mod.rs and included its exact
source in the subsequent POST bundle. Neither PRE is implementation, performance
or adoption approval.
