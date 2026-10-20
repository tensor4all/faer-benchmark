# Structured-native floor only — next distinct minimal candidate

## Evidence and scope

Continue all-regression goal, not an adoption retry of7f713a1 or a third LU pair.
Canonical stage1 A=b7715c53ba75946d68a97d5655f481b198332447,
B=7f713a1401f18546d1ef0c134df982be80626b2e, upstream0539947ffb757a739d7e703a7d2fa0c792a909c1,
compiled harness651807301c4fd0d485a66038346388dffe289073, toolkit9daa5bc,
MKL2026.1: controls fail6/1/4 Cholesky/GEMM/triangular; HH72 reproduce, dense
GEMM guards flagged. NOT ADOPTED, no stage2. All data retained.

The completed upstream-only diagnostic (recording harness311c2fb45b50e14eb09a15fd929eb81bce343341)
retains96 cells×8 ABBABAAB blocks/768 records,18 verification/72 timing/6 info
processes, four starts per binary. Seven cells leave the descriptive A-range±5%
band. Upstream c64F triangular256/1T A=.025298/.024907/.024907/.024927ms and
B=.022403/.022271/.023064/.022142ms: ~10% shift remains without fork/vendor
operations. This excludes their execution history as a sufficient explanation,
not initialization, allocator/caller/cache/code placement or temporal confounds.
Canonical refusal unchanged; isolated results cannot adopt code.

Bounded generated-code inspection finds four matching dense matmul_imp symbols:
two normalized bodies unchanged, two changed230/634 diff lines (3444→3437 and
3368→3342bytes). RIP references were normalized, engine attribution/whole-program
equivalence not proven. Thus mathematically equivalent dense policy refactoring
DID change machine code; we must not claim it preserved the dense timing path.

## Smallest next change

Base remains correctness-onlyb7715c5 (strict effective extents + K0 repair), not
LU/copy/HH experimental branches. Reuse exactly7f713a1's private cfg(x86_64,std)
MAC-normalized helper and its TWO structured call sites:

- triangular native entry: effective output M,N and lhs depth.
- mapped/diagonal internal entry: post-shift effective dimensions, caller budget.
- preserve the existing internal32³ gate after native return, fallback-only with
  original dimensions/budget, exactly as reviewed/tested7f713a1.

**DO NOT replace the already-adopted dense native expression with the helper.**
Restore/leave dense matmul_imp's source body exactly asb7715c5; nano/generic paths
also unchanged. No new threshold, host/shape specialization, API, unsafe, scratch,
allocation, dependency, pointer/mapping/conjugation/Accum change. The helper has
two real callers, not a speculative wrapper. Its comment must accurately say the
dense expression is intentionally untouched, not that all routes call it.

This deliberately leaves the existing dense expression's extreme cutoff
arithmetic behavior unchanged (2*get_threading_threshold). Do not claim that route
has7f713a1's overflow hardening. It is the current unadopted baseline behavior,
not a new overflow policy or numerical/public-contract tradeoff; no unrelated
hardening refactor belongs in this experiment. Helper's saturating MAC/div_ceil
checks still cover the two changed structured entries and caller-budget bound.

## Correctness and static pre-filter, before timing

Reuse7f713a1 module-owned tests and separately justified baselineK0/strict oracle:
f32/f64/c32/c64 floor decisions incl extreme thresholds; genuinef64/c64 structured
Add/Replace/strict/unit/conjugation/map/parent guards, Seq and owned8. No f32/c32
structured numeric or forced-generic claim. Run focused tests, full library suite,
no-Rayon check and kache verify sequentially, not concurrent Cargo targets.
PRE before implementation, completed independent POST on final coherent code
before push; corrections get focused checks, not repeated design cycles.

After freezing new candidate and commands/tool/harness identities, build BOTH
A=b7715c5 and new B freshly through existing full-checkout builder, exact Cargo
linkage/features/buildenv/readback/hash/source evidence. No worktree .git-file
builder bypass, no stale2240binary, no builds/checkouts while recording.

**Static pre-filter:** source diff must leave dense function untouched. Compare
all four matching dense f64/c64 matmul_imp symbols from fresh A/B using the existing
bounded normalizer; require unchanged sizes/normalized bodies before measuring.
If this narrow preservation hypothesis fails, retain diagnostics and do NOT run
timing or fiddle linker flags/alignments. Static equality does not establish RIP
reference equivalence, caller/kernel/worker equivalence or timing acceptance.
This is a development filter, NOT a changed adoption gate.

## Conditional performance path, unchanged contract

Only if code/tests/review/static filter pass: same frozen stage1 grid648 full
records/statuses/start/side including skips/HH variants, both dtypes/layouts and
1/4/8T, four existing family/shape groups; median5/250ms, MKL3 starts/full engine
rotations, normal idle3s/max5%/8 retries and complete rejected evidence. New label
must distinguish this candidate from7f713a1. Fresh exact inventories, no A/B
intersections or dropped samples. Runtime topology/observer/boost/power/source/
binary/worker safeguards unchanged; all1T explicit/read back. No square2048+
tier or final freeze here. Official candidate_compare must validate both whole
inputs and reproduce upstream controls. Success remains descriptive, all guards
and targets inspected. Failed controls/guards => hold/reject, NOT selective retry,
weaker thresholds or another identical LU pair.

Only a valid target/guard/control pass permits the previously frozen all14-family
stage2 inventory2688 records/start; full goal/final suites and other regressions
remain pending. No adoption from this plan, prior diagnostics or static equality.

Provenance: own reviewed7f713a1 helper/tests reused within MIT fork; existing gemm
threshold getter, not vendor code or foreign tests. Preserve all inherited notices.
