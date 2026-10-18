# Native GEMM shared-floor experiment — no timing yet

Candidate7f713a1401f18546d1ef0c134df982be80626b2e on isolated
`perf/native-gemm-work-floor`; baseline b7715c5 is the separately reviewed
empty-extent/K0 correctness prerequisite, NOT old2240 binary. Neither LU gate
restoration, copy tile nor HH partial merge is included. Main remains unchanged.
One private helper reuses the adopted dtype-work floor at all3 native entrances;
no policy constant/API/unsafe/scratch/dependency added. The internal old32³ gate
remains only on fallback, with original dimensions; native uses effective ones.

## Evidence

- `candidate.diff`, `identity.json`: exact code/test delta and source hashes.
  Patch uses zero context (`git apply --unidiff-zero`), avoiding patch-context
  space-before-tab/blank-line false positives in artifact whitespace checks.
- `focused.log`:initial2 new tests passed. Extreme-cutoff algebra was then added;
  `library.log` records FINAL217passed/2existingignored, including that extension.
- `no-rayon.log`:std,linalg check succeeds,13 existing warnings on unchanged
  declarations; not proof of forced-generic numerical execution.
- `kache.log`:33,981 entries all valid, zero corruption/missing/orphans/checksum
  failure/index drift.
- PRE and bounded gpt-6.1-sol POST COMPLETE, no findings. POST covers immutable
  code7f713a1 and all focus areas; source hashes still match. Full report in
  `docs/reviews/20261018-native-gemm-budget-post-review.{md,json}`. No independent
  execution, native worker-utilization, performance or merge approval.
- Module-owned public f64/c64 oracle covers Seq/owned8, C/F, lower/upper/strict/unit
  representative masks,1/32/64/128, Add/Replace, conjugation and parent canaries.
  Mapped128×96×64 tests check real diagonal present/absent above the floor. Existing
  small all-mask/all-map/depth0+2 oracle is repeated with8 budget. Finite checks
  precede max norm. f32/c32 helper decisions tested, not structured numerics.

## Predeclared development grids

`freeze_grid.py` exports complete full identities/statuses from original validated
full-MKL run0 census, checked against independently enumerated Cartesian requested
axes (not an A/B intersection). No operation is timed or remeasured. Output:
`grid.json` metadata/hashes and `stage{1,2}-grid.csv`. Preserve all note variants
and skipped cases. Both A/B must match the exact declared inventory; actual command,
worker/source/binary/topology/rotation checks must be frozen before recording.

Both stages: f64/c64 ×C/F ×budgets1/4/8 ×three engines (fork,upstream,MKL).
Three starts/engine with full rotations,5 mediansamples/250ms prime; normal
idle3s/max5%/8bounded retries and rejected-attempt archives. One vendor arm at a
time. Dynamic L3/topology-derived measured/observer pins, including explicit
1-worker backend/vendor readback. No all-core overhead baseline. Do not edit,
checkout or build while recording. Comparison-completeness correction and POSTs
must finish before recording. All identities/commands to be bound to fresh builds.

| stage | fork ok/skip | upstream ok/skip | MKL ok/skip | total rows/start |
|---|---:|---:|---:|---:|
|1, focused targets/guards|228/0|228/0|108/84|648|
|2, broad shared-helper guards|732/180|732/180|540/324|2688|

Stage1: Cholesky32/64/96/128/256 (96/128/256 at4/8 target); GEMM32³/64³/96³/128³;
triangular_solve32/64/128/256; HH64²/1024×64/4096×256, block+sequence.
MKL's48 triangular-solve and36 HH records are explicit skips, not performance
coverage. Stage1 is diagnostic filtering, NOT adoption. A guard/control failure
holds/rejects this exact candidate; no omitted cell, selective start, changed
threshold or wake-up explanation waives a failure.

Stage2 only if stage1 reproduces controls and meets target/guard rules: all14
families. Factor/decompose128²/256²/512²/1024×64/64×1024; eig128²/256²/512²;
HH+upgrade64²/512²/1024×64/4096×256; GEMM32/64/96/128/192/256/512 cubes plus
4096×64×64,16×4096×240,4096×16×240,64×64×4096. Unsupported engine/shape/upgrade
rows stay in the census. Formal adoption still needs complete validated manifests
and official comparator with unchanged statistics, not descriptive gains alone.

The guard decision uses baseline process ranges±5% and retains complete paired
geomeans/SD; no third identical LU pair or substitute fixed-reference gate.
This experiment cannot restore LU's ancestor-reduced budget or explain1T binary
shifts. Even a successful stage2 does not finish the all-regression goal: remaining
causes and original improvement guards remain, then final freeze and BOTH full
suites/vendor arms. Square2048/3072/4096 remain strictly FINAL-ONLY; thin4096×256
here is distinct. No final freeze, timing or adoption has happened.

Provenance: own MIT code/tests, existing gemm getter/criterion; no vendor source.
The census is evidence inventory, not imported third-party implementation/tests.
