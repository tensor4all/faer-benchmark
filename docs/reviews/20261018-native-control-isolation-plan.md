# Native-budget control isolation — diagnostic only

## Reason and question

Native stage1 A=b7715c53ba75946d68a97d5655f481b198332447 versus
B=7f713a1401f18546d1ef0c134df982be80626b2e completed all648 full
identities/statuses per start, three starts per side. Official CLI refuses
Cholesky6/60, GEMM1/48 and triangular-solve4/48 upstream controls; HH72/72
reproduces. The exact candidate remains INCONCLUSIVE / NOT ADOPTED; stage2
is not permitted. Four dense GEMM rotation ratios exceed1.05 (three median
values exceed baseline process-max+5%). All observations remain retained.

Question: do the new upstream control shifts persist when the changed fork's
operations and vendor operations are never constructed/executed? This is a
bounded intervention in process/provider history, NOT a different acceptance gate.

The actual runtime is one global explicitly sized Rayon pool shared by providers
(`fbench/src/main.rs:369–391`). Both faer budgets and vendor budget are set once.
Rows rotate and run sequentially; operations are built only for selected rows
(:482–567). Each op receives250ms priming then five timed calls and an outside-
clock check (`timing.rs:12–35`). Thus changing fork work can change preceding
worker/allocation/cache history seen by the source-unchanged row. Triangular solve also moved despite having no vendor row; this does not exclude
vendor initialization or preceding vendor history. History is a hypothesis, not a proven explanation. Four matching
fork/upstream SIMD Cholesky leaves have identical normalized instructions/sizes,
all moved -211312 bytes (+16 modulo64); RIP/external targets are not verified.
No whole-program equivalence or instruction-alignment causality claim follows.

## Minimal diagnostic

Reuse the SAME immutable MKL-linked binaries and existing pinned.sh, not builds
or new library/harness code:

- A binary target/faer-rev/b7715c53ba75-mkl/release/fbench,
  SHA2562decf425848a5b0706f9c20de65084822a23d659071b38b6bf7c9dea9d347e4a.
- B binary target/faer-rev/7f713a1401f1-mkl/release/fbench,
  SHA256f8e8e3337463fe7219395de47c8161bba8c95fb604e743ca89266f587bcfce2a.
- Upstream0539947ffb757a739d7e703a7d2fa0c792a909c1,
  compiled harness651807301c4fd0d485a66038346388dffe289073,
  toolkit9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5, MKL2026.1.

One axis only: `--rows faer-upstream`. No KMP_BLOCKTIME/OMP_WAIT_POLICY changes,
fixed-address linking, new flags/thresholds/unsafe/API/dependency, increased prime
or fixed-reference adoption policy. The DSO remains loaded and configure_threads
still initializes provider budgets; this does not remove every vendor influence.

Predeclare ALL f64/c64 ×C/F ×1/4/8T cells for:

- Cholesky32/128/256 (36 upstream cells).
- GEMM32³/96³/128³ (36 upstream cells).
- triangular_solve128²/256² (24 upstream cells).

Total96 cells/start, no intersection or post-hoc selection. Preserve family,
dtype, layout, shape, budget, variant, full raw samples and skips if any. Dedicated
diagnostic regime keeps these files distinct from declared-suite acceptance data.
Verify each binary/family/budget before timing (all18 invocations), then eight
schedule blocks in ABBABAAB order: four per binary. Within each block use fixed
family order cholesky,gemm,triangular_solve and budgets1,4,8: nine fresh timing
processes/block,72 timing processes plus18 verification invocations. Exactly96 cells
per block; no selective retries or optional early success stop. Keep median5/250ms,
normal idle3s/max5%/8 bounded protocol retries, all rejected evidence. Existing
campaign lock across verification+timing, no builds/source edits/checkouts during
recording, runtime topology/power/hash/source checks. All1T processes explicitly
request/read back one Rayon worker and one vendor thread; no all-core baseline.
Use only one L3 domain for each measured cell; observer outside complete L3/SMT.

Retain argv/info/source identities, full stdout/CSV/guard logs, all failures and
all available incomplete evidence. Samples buffered in the unchanged harness
before CSV output cannot be recovered after command failure/timeout. A120second
deadline may abort before all eight protocol attempts; this remains incomplete,
not permission for an outer retry. A command failure stops without outer retry. Use normal
process-group deadlines (~120seconds for each verify/timing invocation, total
expected ~12–15minutes); inspect owned descendants/logs on timeout, don't blindly
repeat. No large square tier or stage2/final campaign here.

## Interpretation limits and next branch

This diagnostic cannot adopt any code, replace controls, erase a GEMM guard,
retroactively accept7f713a1, or count as another LU adoption pair. Canonical
stage1 evidence/results remain immutable and refused.

If shifts persist over balanced isolated starts, cross-engine execution history
is not a sufficient explanation; pursue bounded binary/code/reference evidence.
That still does not prove alignment, allocation, or whole-program causality. If
shifts shrink/change, provider/process history remains a lead, not proof of MKL
spinning or a specific synchronization mechanism. Canonical and diagnostic runs
are not contemporaneous; elapsed time and host drift remain alternatives, so
disappearance alone does not identify a cause. Compare all96
cells and all starts/spread; never remove inconvenient data or promote a quiet
subset to formal acceptance. No universal attribution from a single counter.
Any later change to formal measurement/adoption contract requires separate
explicit user approval; none is requested or made by this diagnostic.

Own experiment data; existing attributed protocol reused unchanged; no new
foreign implementation/tests imported. Preserve wrapper's existing MIT notices.
PRE required before execution; a bounded POST covers the final operational driver
before it is run, not an independent timing execution or performance approval.
