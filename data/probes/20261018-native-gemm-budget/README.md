# Native GEMM shared-floor experiment — stage1 INCONCLUSIVE / NOT ADOPTED

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
here is distinct. Stage1 recording is now complete (below); no stage2, final freeze or adoption.

## Completed canonical stage1

Four groups per side completed with fresh immutable A=b7715c53ba75946d68a97d5655f481b198332447
and B=7f713a1401f18546d1ef0c134df982be80626b2e; upstream0539947ffb757a739d7e703a7d2fa0c792a909c1,
harness651807301c4fd0d485a66038346388dffe289073, toolkit9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5,
MKL2026.1. Exact648 full identities/statuses/start/side ×3 (3888 timing-CSV rows,
including unsupported records). No intersections; all samples, skips and HH
variants retained. `summarize_stage1.py` asserts census, starts, raw5 samples,
worker budgets, source identities and unchanged binary hashes. Full result:
`runtime-stage1/outcome.json`, all four official CLI logs and HH's successful
DESCRIPTIVE comparison JSON. All8 validated run manifests/raw CSVs are under
`data/results/zen5-cpu/faer-kernels/*native-floor-stage1-*`, no published pages.

|group|upstream controls|failed|fork cells|candidate median above A-max+5% (descriptive)|
|---|---:|---:|---:|---:|
|Cholesky|60|6|60|0|
|GEMM|48|1|48|3|
|triangular solve|48|4|48|0|
|HH|72|0|72|0|

**INCONCLUSIVE / NOT ADOPTED. No stage2.** Three CLI refusals cannot be overridden
by target gains or HH's passing subset. Cholesky24 target ratios .529–.999 are
descriptive only. Accepted A c64C256/8T starts5.143332/.822805/.849886ms are all
retained; a large first start affects the geometric ratio. GEMM geomean>1.05:
c64F96/4T1.076, f64C128/4T1.073, f64C96/4T1.139, c64C128/8T1.089. The f64C96
median lies inside A's broad range; the other three exceed A-max+5%. These data
do not prove a compiler/worker/alignment cause; no guard is waived.

A binary SHA2562decf425848a5b0706f9c20de65084822a23d659071b38b6bf7c9dea9d347e4a;
B=f8e8e3337463fe7219395de47c8161bba8c95fb604e743ca89266f587bcfce2a. Source hashes
still match reviewed7f713a1. Runtime Cargo graphs retained for each side. All
source checks remained clean; no source edits/builds/checkouts overlapped a run.
Three post-rejected attempts fully retained: A-HH verification peer18 busy10.3%
(40rows), B-tri verification peer21 busy11.9% (24rows), B-HH timing peer16 busy10.3%
(20rows). Normal declared retry, no outer timing repeat/outlier filtering. Measured
CPUs4 /4-7 /4-11; watched4-11,16-23; observer0-3,12-15, boost0/performance/max2GHz.

`static-cholesky-leaves.json` bounded inspection reuses existing analyzer functions
without overwriting old artifacts. Four matching leaves have equal sizes and
normalized instructions; entries shift -211312 bytes (+16 mod64). Both engines'
leaves included, not individually attributed; RIP/external references not audited.
Not equivalence or alignment causality, and NOT a replacement control gate.
Next upstream-only isolation is a separately reviewed DIAGNOSTIC, not adoption.

## Completed upstream-only isolation — diagnostic, no adoption

Recording-source harness311c2fb45b50e14eb09a15fd929eb81bce343341; SAME compiled
harness651807301c4fd0d485a66038346388dffe289073 and same A=b7715c53ba75946d68a97d5655f481b198332447 /
B=7f713a1401f18546d1ef0c134df982be80626b2e binaries/upstream0539947ffb757a739d7e703a7d2fa0c792a909c1/
MKL2026.1/toolkit9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5 as above. PRE COMPLETE,
3minorwording findings fixed; POST COMPLETE2IMPORTANT (info-output retention and
optimized-Python fail-open) source-verified/fixed with focused before/after checks.
No reviewer execution or independent rereview of corrections claimed.

All96 full identities/block ×8 ABBABAAB blocks =768 accepted timing records,
4starts/binary, all5 samples each;18verify/72timing/6info processes with explicit
1/4/8T readback. Exact CSV counters/finite samples/clean source/binary/power/agent
thread affinity passed. All operations upstream-only; fork/vendor budget setters
and MKL loading remain, not all initialization effects removed. No source edit,
checkout or build during recording. Same dynamic L3/observer/2GHz policy. Owned
controller1725492 exited after complete marker, no outer timing retry.

`summarize_isolation.py` reads ALL768 records, references/checks all576 original
canonical96-cell records (3repeats×2binary) without overwriting or intersecting.
`runtime-isolation/descriptive-comparison.json` retains every process median and
both descriptive summaries; original raw5-sample arrays stay in accepted CSVs.
Seven/96 isolated cells leave A-process-range±5% descriptively (2Cholesky,
1GEMM,4triangular). Not an official replacement gate or a successful control run.
Strong example: upstream c64F256 triangular/1T A=.025298/.024907/.024907/.024927ms,
B=.022403/.022271/.023064/.022142ms, medianB/A=.89646; all four B starts below
A-min-5%. c64C32Cholesky/4T medianB/A=.93955; both sets stay disjoint.
Provider execution history alone is therefore insufficient, NOT proof of binary
alignment/caller/allocation causality. Campaigns are not contemporaneous, other
cells change their bands/spread, and all remain reported. Canonical stage1 STILL
REFUSED/NOT ADOPTED. No stage2, final freeze or acceptance from this diagnostic.

Two rejected attempts fully archived: block0-A-cholesky1T12rows, cachepeer5 at8%;
block1-B-gemm1T12rows, cachepeer5 at10%. Three pre-admission delays retained in
logs, no sample/outlier removal. `retention-inventory.json` preserves full details.
The earlier shell-background launcher produced no surviving recorder/output;
explicit detached Popen session launch then executed this one diagnostic, receipt
retained. Unflushed harness samples remain unrecoverable on failure; no such
incomplete command was promoted here.

Bounded dense generated-code inspection in `runtime-stage1/dense-code/` reuses
existing analyzer functions. Four symbols match: two normalized bodies unchanged,
two change230/634 diff lines (3444→3437,3368→3342bytes). Address/RIP normalization
is not engine attribution/reference/whole-program equivalence. Mathematically
equivalent dense policy refactor did NOT preserve every generated body. Next
minimal proposal keeps the dense source body untouched and applies the adopted
floor only at two structured entries; PRE pending, no implementation yet.

## Preflight attempt retained; zero timed cells in that attempt

First stage1 launcher stopped before any build/recorder/CSV at offline Cargo
metadata: uncached `redox_users 0.4.6` under the MKL feature. All partial output,
source commit IDs and log retained in `preflight-offline-missing-crate/`. No owned
recorder/build descendants or native-floor result directories remained. This was
not a measured pair, guard rejection or performance result.

Existing Cargo metadata with the SAME patches/features plus `--locked` and
network access populated the declared target-platform dependencies (redox/windows);
full graph/fetch log retained. Cargo.lock unchanged; no dependencies, guard,
statistics, pin or host policy changed. Resume normal offline preflight using
unchanged launcher; no selective timing retry or old-binary substitution.

## Recorder command/host preparation

`commands.json` freezes direct existing `record_run.py` argv:4 family/shape groups
per side for each stage, avoiding accidental rectangular-selection extra cells.
Existing `expected_cells` projection matches the frozen census (576/2592 base
identities before independently noted variants); actual CSVs must still match
ALL648/2688 note/status identities per start. No custom suite/recorder/statistics.

Build script rejects worktree `.git` FILES. Use full `extern/t4a-faer` at exact
A=b7715c5 / B=7f713a1, local fetch as needed, fresh builds via existing script;
switch ONLY between completed recording runs. No old2240 binary substitution,
concurrent build/switch or source edits. Commit all source/tool pins/commands
before entire pair; no harness/toolkit identity changes between its parts.
Comparator POST/delivery is complete (toolkit9daa5bc remotely verified and pinned;
hosted CI content job succeeded). `record-stage1.sh` invokes only these8 existing
recorder commands, serial A then B, with the declared retry/idle settings and
15-minute process-group deadlines; no outer retry or automatic stage2/adoption.
It retains full Cargo metadata per side, logs and partial evidence, refuses to
reuse its runtime output directory, and holds the existing campaign lock while
switching or resolving graphs. Each recorder owns its normal build/verify/timing
lock, source/binary identity checks and runtime observer/boost rechecks. No source
edit/commit is permitted until the entire stage1 job finishes or fails.

`preflight-topology.json` is preparation, not durable runtime evidence. Sysfs:
measured1/4/8T CPUs4 /4-7 /4-11; watched complete L3/SMT4-11,16-23; observer
0-3,12-15. Agent1492359 all11 current threads outside watched L3, no repin needed.
Boost0, governor/EPP performance, max2GHz across watched CPUs. Recheck immediately
before recording; no host setting/shared service changed, no builds or timings.

Provenance: own MIT code/tests, existing gemm getter/criterion; no vendor source.
The census is evidence inventory, not imported third-party implementation/tests.
