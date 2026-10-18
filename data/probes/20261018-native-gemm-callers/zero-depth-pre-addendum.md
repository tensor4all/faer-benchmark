# Native boundary PRE addendum: zero-depth Replace

The first bounded PRE completed and approved post-shift native-local dimensions.
That5-line fix is now applied in /tmp/faer-native-gemm-audit. Both original negative
reproducers pass, and the full nonzero-depth scalar-oracle grid passes: f64/c64,
all strict/unit lower/upper, four index-presence combinations with descending
nonidentity mappings, Add/Replace, 0x3/3x0/1x1/3x3/1x3/3x1/2x4/4x2, real D and
conjugated left input, parent guards. This is correctness only, not performance.

The mandatory zero-depth case exposed a separate pre-existing wrapper defect:
M=N=3,K=0,strict lower,Replace leaves7 in stored entries instead of zero. Evidence
/tmp/faer-native-strict-bounds-maps.log. The private native GEMM returns without
zeroing. Original full dense wrapper already handles K=0 explicitly. Do not
interpret fixing empty output as permitting an unconditional depth==0 return.

## Planned correction (NOT implemented)
After existing row/column index-bound assertions, before native dispatch or
scratch/fallback handling, handle depth==0:
- Add: return without changing data.
- Replace: for original logical i,j, write T::zero only where the declared
  BlockStructure stores an entry; use existing row/col maps for destination.
- Rectangular stores all, lower i>j, upper i<j, plus i==j only for Generic diagonal.
  Unit/Strict preserve diagonal and opposite triangle. Then return.
No unsafe/API/dependency/threshold changes. Keep all index validation, dimensions,
positive-depth paths, alpha/D/conjugation and scheduling unchanged. Empty product
matches the full dense wrapper's zero-fill convention, independent of alpha.

Proposed core:
```rust
if depth == 0 {
    if beta == Accum::Replace {
        let diagonal = matches!(C_block.diag_kind(), DiagonalKind::Generic);
        for j in 0..ncols {
            for i in 0..nrows {
                if C_block.is_dense()
                    || (C_block.is_lower() && i > j)
                    || (C_block.is_upper() && i < j)
                    || (diagonal && i == j)
                {
                    C[(row_idx.map_or(i, |rows| rows[i].zx()),
                       col_idx.map_or(j, |cols| cols[j].zx()))] = T::zero();
                }
            }
        }
    }
    return;
}
```

Review this limited addition against the contract/source in
/tmp/native-bounds-pre-bundle.md; read that existing bundle only as needed.
The block is placed AFTER bounds assertions, BEFORE any adjusted views, so masks
use original logical coordinates and fallback scratch is not needed. All enum
variants must be tested, including Rectangular/inclusive triangles for K=0.
Read-only; no builds/edits. Return COMPLETE verdict, mandatory corrections,
Delete list/provenance/limitations. Current production callers have K>0; this is
not performance adoption or a proposed new abstraction. Same gpt-6.1-sol model.
