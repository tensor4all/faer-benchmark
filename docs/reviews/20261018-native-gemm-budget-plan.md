# PRE: reuse the adopted native GEMM work floor at its other entrances

## Objective / known limits

New, isolated performance experiment on correctness baseline b7715c53ba75946d68a97d5655f481b198332447 (production af8273f, based on main7364be5/adopted2240b07). Do not combine LU a537746, copy d6358ca or declined Householder ad9f2ef. No claim this explains the 1T binary-associated Cholesky gap. No new policy constant, shape/host tuning, API, unsafe, scratch, dependency, threshold relaxation or comparison-contract change. Expensive2048/3072/4096 final-only, no development run.

Source audit: dense native GEMM already requires saturating M*N*K*(2 real /8 complex) >=2*gemm::get_threading_threshold(); private-gemm-x86 has no own generic work floor. Triangular mat_x_mat_into_lower_impl_unchecked returns from the native branch before its generic128^3 fallback gate, passing caller degree directly. Internal spicy_matmul uses a separate32^3-MAC gate and passes that lowered degree to native indexed/diagonal GEMM. This is an unmeasured lead, not adopted speedup or a proven cause of upstream regression.

## Smallest change

1. Extract the existing dense floor into one private cfg(x86_64 && std) #[inline] helper native_gemm_threads<T:ComplexField>(m,n,k,par)->usize in linalg/matmul/mod.rs. Same boundary/global getter/dtype cost. Express the identical mathematical comparison in per-dtype MAC units: saturating m*n*k >= threshold for real, or >=threshold.div_ceil(4) for complex (8/2=4). This avoids copying the current dense expression's unchecked2*threshold multiplication into more paths and avoids saturating both sides of a flop comparison. Normal-domain choices must match the old expression; extreme counts/thresholds must remain mathematically correct. No new early-return policy, validation layer or knob. Keep existing dense rationale with helper, explaining the equivalent units.
2. Replace dense expression with helper call (same M,N,K,T,Par). Nano and non-native routes untouched.
3. At triangular native GEMM call, call same helper using adjusted dst.nrows(),dst.ncols(),lhs.ncols(),par AFTER existing skip-diagonal view adjustment. No added mask/stride/extent changes.
4. At internal native GEMM call, call helper using effective nrows/ncols AFTER reviewed strict/unit adjustments and empty-output return, depth, original caller par. Move the old32^3-MAC Par gate from the function entry to immediately AFTER the native branch and BEFORE fallback scratch/operations; preserve fallback arithmetic and logic verbatim. Thus it no longer preemptively suppresses native budgets independently of the adopted dtype-aware policy. Existing index validation and K=0 handling still precede native entry.
5. Full-rectangle flop estimate intentionally follows existing dense policy, not a new triangular-half-work cost model. Caller budget is an upper bound, not a promise to thread. No ancestor LU gate changed, so do not claim this repairs its lost caller budget.

## Tests

- Module-owned helper decision tests below/at threshold (plus comparison to an independent u128-saturating flop oracle over representative/overflowing dimension tuples): f64/f32 at K=threshold with M=N=1, complex c64/c32 at ceil(threshold/4); below cutoff Seq1, at cutoff caller8. Caller Seq always1. No setter/global mutation. Default positive threshold; account explicitly for zero threshold without subtract underflow. Saturating work with huge dimensions tested without allocating. Compile cfg consistently with helper/Rayon.
- Preserve existing dense thread_budget_does_not_change_the_product and randomized structured-product test, but add deterministic real/complex public triangular products at small/medium sizes on both sides of policy (N=1/32/64/128,K=2/32/64/128 as bounded cases), lower/upper/strict/unit output, Add/Replace, C/F views, Seq/owned8, independent scalar oracle plus finite/parent guards. Keep focused matrix small, no broad new framework.
- Extend existing internal scalar/canary fixture from Seq to Seq/owned8 at small sizes and add one or two above-floor rectangular/inclusive-lower mapped+diagonal real/complex cases; no new unsafe. Preserve K=0 tests and all four mapping combinations.
- Run focused affected tests, cargo test -p t4a-faer --lib, no-Rayon std/linalg check sequentially (one Cargo target). Actual native CPU available. Independent POST required before any integration/handoff.

## Measurement / reject path

Build fresh A=b7715c5, B=isolated floor candidate with verified actual Cargo graph and source/binary identities. Existing frozen baseline2240 binary is not this A. Use unchanged official median5/prime250ms, MKL row3/start3 full rotations, 1T explicit Seq/pool1 then4/8T, dynamic whole-L3/watch/observer pins, unchanged power/admission/retention, one recording at a time. Source/library/harness immutable throughout recording.

Before first timing, predeclare exact focused-stage grids/identity counts and abort conditions. Initial targets: Cholesky96/128/256 at4/8T; guards: Cholesky32/64 (incl1T), small dense GEMM32/64/96/128/256 (existing floor), triangular_solve32/64/96/128/256, Householder64/1024x64/4096x256 block+sequence, f64/c64 C/F1/4/8T. Verify all selected grids and native/worker census before timing. Vendor unsupported rows remain explicit skips. Any new guard regression beyond the fixed rule => hold/reject this exact candidate and do not run downstream stages. Exact cell coverage, variants, sample/start counts; retain all accepted/rejected attempts. This initial stage is diagnostic, not automatic adoption.

If initial gates pass, formal candidate_compare acceptance must cover all reachable families/shapes/budgets (up to512 and thin MID rectangles here; final-only square tiers deferred by explicit user instruction) including LU/solve/full_piv_lu, QR/QR-factor/Householder, Cholesky/triangular_solve, SVD/eigh and dense GEMM. Shared helper reaches structured products through those paths, plus sparse correctness outside the harness. Do not claim all shape coverage from an intersection or an unrun family. Formal upstream controls and target/guard gates unchanged. Audit comparator complete-input protection before relying on it. No third identical LU pair, fixed-reference waiver, selected retry or discarded bad control. A failed candidate branches to diagnosis, not global goal stop.

## Provenance

Own rearrangement of the existing fork floor and module-owned tests. Existing upstream MIT notices remain; no imported kernel/test code. Records/PATCHSET on isolated branch; no upstream submission or public release.
