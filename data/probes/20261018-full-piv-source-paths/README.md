# Full-pivoting LU: source-path exclusion, no remeasurement

Compared upstream0539947ffb75 with main7364be5ce22d. `factor.diff` is RAW
`git diff --unified=0` (not formatted terminal output). `source-proof.json`
records refs/hashes and an executable-text comparison: removing ONLY the added
row-major adaptation recovers the ENTIRE upstream full-pivoting factor file.
This proves source equality of the remaining file, not compiled-code equality.

Actual benchmark path (`fbench/src/backend.rs:467–520`): input C/F view ->
`full_piv_lu()` -> `FullPivLu::new` (`faer/src/linalg/solvers.rs:1036–1070`)
-> `A.to_owned()` -> canonical owned column-major `Mat` -> `new_imp`
-> default params + global Par -> `lu_in_place(LU.as_mut(),...)`.
The fork-only row-major adaptation condition (`factor.rs:486–507`) needs
`abs(row_stride)!=1`, hence is not taken for this owned column-major factor.
The initial public C-order to_owned DOES use the existing copy helper; F-order
owned route does not. This is why the independent builtin-copy experiment has
C targets and F guards, not a claim that the low-level adaptation itself caused
the observed high-level F regression. Do not remove that low-level API
optimization just to fit generated code; its row-major callers are different.

Default unblocked gate (`factor.rs:372,436–448`) is identical upstream:
trailing `(m-k-1)*(n-k-1) < 256*512` changes Par permanently to Seq.
For square32/64/96/128/256 and1024x64/64x1024 every update is therefore Seq
under default params EVEN IN nominal4T/8T benchmark processes. Metadata's pool
budget is not evidence of actual factor parallelism. For square512 there are
at most149 eligible update slots k=0..148 under nominal4/8T, not149 proven
parallel regions; early rank break, runtime scheduling and utilization were
not measured. Nominal1T has no parallel slots. These are existing declared
development sizes, no final-only large square was recorded.

`rank_one_update_and_best_in_matrix` (`factor.rs:287–323`) uses its fused SIMD
path when supported and both destination/lhs permit column-major access;
its fallback explicitly calls matmul with Par::Seq. Neither branch is a
new fork scheduling policy. Do not infer that removing a fork-only parallel
threshold can fix default full-pivoting256: this file contains no such
threshold difference. Trait/helper/compiler/caller/layout/allocator/pool or
runtime effects remain possible; source equality is NOT causal proof or a
waiver of between-binary controls. No code edits/builds/kernel execution,
timing, adoption, contract change or third LU pair was performed here.
