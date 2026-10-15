# Protocol freeze for the timing-v2 baseline re-record (v2, after the design pre-review)

Pre-review findings accepted: the formula below replaces the mis-written one, the
position-balance claim is restricted to cells where every declared engine has a
measured row and to the shared-position model, and the budget/guard/accounting
numbers are corrected. Optimization stays frozen; `fe41bbd...` is not measured here.

## 1. What is measured (unchanged declared grid)

- Engines per binary: `faer-fork` (extern/t4a-faer @ bfe4041cd9918815e3b3f766ac0332b792badb7d),
  `faer-upstream` (extern/upstream-faer @ 0539947ffb757a739d7e703a7d2fa0c792a909c1), one vendor row.
  Both vendor binaries link the same two checkouts; toolkit `916dace` + the committed report change;
  harness at the recorded clean commit.
- The suite's 10 populations, all families and shapes, `f64`+`c64`, order `c`+`f`, batch 1,
  budgets 1/4/8 on CPU sets 4, 4-7, 4-11. Per vendor per set: 5,148 base engine-cells,
  3,756 successful base cells, 192 Householder variant rows = 3,948 primed rows, 1,392 declared
  skips, 5,340 emitted CSV rows.
- Frozen budgets: `--reps 30`, `--prime-ms 3000`, `--aa 3` (rotation step 1), `--statistic median`,
  full declared coverage (no `--regimes`/`--families` filter), `PINNED_RETRIES=8`, `PINNED_WAIT=30`.

## 2. Comparison semantics

For a cell and two engines A, B measured in the same cell:

    R(A/B) = exp( (1/N) * sum over the process starts r of [ log m(A,r) - log m(B,r) ] )
    m(e,r) = median of engine e's chronological samples inside process start r;  R > 1 means A is slower.

- `R` is called the **rotation-averaged ratio**. It removes a position effect only under
  `log m[e,r] = alpha_e + beta_r + gamma_position(e,r)` — one position effect shared by all engines
  and stable across process starts. Engine x position, predecessor and process x position
  interactions are not removed, so the per-start ratios are always shown next to `R`, and no
  page text may claim that the rotation "cancels position effects" without that qualifier.
- `R` is **position-balanced only when every declared engine has a measured row** in that cell.
  Where an engine has no row (vendor `full_piv_lu`, square `triangular_solve`, Householder), the
  remaining engines are not a Latin square; the page marks such cells and does not present `R`
  as position-balanced.
- Absolute per-engine values stay descriptive: median of the per-start medians, between-start
  sample SD, median within-start sample SD. Page text states that between-start variation can
  exceed the difference being compared.
- Descriptive warnings, no rejection and no trimming: flag a cell when its per-start median range
  / median exceeds 5%, and (where the design is balanced) when the estimated position-effect ratio
  exceeds 1.05. Flagged cells are published with the warning. No CIs, no equality/superiority
  claims, no minimum-repetition filtering of individual calls, C and F never pooled.
- Only complete, validated evidence is published: an incomplete run keeps its artifacts and is not
  published as a page.

## 3. Admission and environment

- One campaign lock, one vendor run at a time, build-then-verify-then-time inside the recorder;
  verification covers every population x budget before any timing (30 verify + 90 timing
  processes per vendor run), each wrapped in the pinned protocol.
- Idle admission unchanged: 3 s window, `max_busy=0.05`, sibling-aware. `PINNED_RETRIES=8` with
  `PINNED_WAIT=30` (the protocol default is 3; 1 demonstrably cannot finish a 64-process package
  here: two aborted controls, and ~3.5% of windows are rejected by unrelated host activity).
  Retries are admission retries: a rejected attempt's CSV is overwritten by the first attempt whose
  windows were idle, every attempt appears in the guard log, and success is selected by the guard,
  never by the measured times. Known limitation: `pinned.sh` waits only after a rejected
  *before*-window; a rejected *after*-window retries immediately.
- The observing side (recorder, guard checker, agent) is launched on CPUs 0-3, off the measured
  L3 domain; the launch affinity is recorded with the run. The recorder does not and cannot set the
  affinity of an already-running agent, so the placement is an explicit launch condition, not an
  automatic guarantee.
- A failed check, a non-guard nonzero exit or an exhausted retry budget aborts the run and preserves
  its directory; nothing is silently re-run for a different number.

## 4. Cost and the budget decision

- Priming floor at 3 s: 3,948 primed rows/set/vendor x 3 s x 3 sets = 9.87 h per vendor, 19.7 h for
  both, before measured calls, checks, guard overhead (~7 s/process), verification and two builds.
  The control's smaller cells cost 3.5-7.2 s/row in total; the heaviest suite cells (512^3 GEMM,
  512^2 decompositions at 1T) are larger than any control cell.
- **Option A (conservative, recommended):** the frozen values above; ~1.5-3 days unattended.
- **Option B (cheapest with the same schedule):** `--prime-ms 3000` unchanged, `--reps 10`,
  `--aa 3`. Keeps the priming floor, chronological samples, defined SDs and the rotation schedule;
  loses the 30-call evidence. Priming is unaffected (19.7 h), so the saving is in call time only.
- `--prime-ms 1000` is **not** recommended: no representative control exists at that setting and the
  earlier 500 ms pilot showed process/position instability that 3000 ms did not.

## 5. Deliverable

- Two validated vendor runs (one per arm) and their v2 pages (`-timing-v2` names), with raw CSVs,
  chronological samples, census, guard logs, build/binary/source provenance and the validation record.
- `report_run.py` gains, for v2 only: the rotation-averaged per-cell engine ratios joined by explicit
  repeat identity, a marker for cells whose schedule is not position-balanced, and the per-cell
  between-start warning. Existing median ± SD (W) cells, variant keys, `case_axes` handling and all
  v1 rendering stay as they are; no schema change (derived columns are report-only).
- Toolkit committed and the harness `requirements.txt` pin updated to that commit before recording.
- The candidate-vs-baseline comparison is a later step under this same contract.

## Open question for the human

Option A or B? Both are measured; the difference is machine time (Option A keeps 30 calls per row).
