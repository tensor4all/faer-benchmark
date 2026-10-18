# LU work floor: decision on the §4 public-contract blocker (2026-10-18)

Status: **decided, source committed, no timing run**. This record answers the two options
the handoff left open at §4 and replaces them with a third that does not touch the
contract. It is not an adoption, not a pin move, and not an independent review.

## What the handoff asked

The LU trailing-GEMM-only plan restored the caller's `Par` to the recursion's trailing
product while keeping the panel TRSM gate. An independent PRE review blocked it as
`COMPLETE / HOLD`: with `par_threshold = usize::MAX` the trailing GEMM would still be
parallelised by `matmul`'s own floor, so the knob no longer forces a sequential LU.
The two offered answers were "accept the behaviour change and document the knob's new
scope" or "keep the current meaning and shelve the plan".

## What upstream actually does with `par_threshold`

Checked at `0539947ffb757a739d7e703a7d2fa0c792a909c1`:

- `faer/src/linalg/lu/partial_pivoting/factor.rs:144` is the only reader of
  `params.par_threshold` in that file, and it gates **the row-swap stage only**
  (`let par = if m * (ncols - n) > params.par_threshold`).
- The panel TRSM and the trailing product are passed the caller's `par`
  unconditionally (the same function, around lines 100-130).

So "`par_threshold = usize::MAX` means a sequential LU" was never upstream's behaviour.
It is the fork's, introduced by `28bc13b` ("floor the blocked partial-pivoting
recursion's trailing update"), which gave an existing public knob a second meaning.

That makes the §4 blocker a fork-internal question, and it also names the cause of the
measured regression: the same commit is what makes the fork slower than upstream at
`c64 n256`.

## The regression it causes

From `data/results/zen5-cpu/faer-kernels/20261018T022054Z-final-full-mkl/report.md`
(fork `2240b07`, upstream `0539947`, MKL arm, paired rows in one binary, three
rotations):

| cells | fork/upstream | evidence class |
|---|---|---|
| `lu`, `solve` at `n256` `c64`, C and F, 4T and 8T | 1.26-1.51 | clean (no `!`, not dispatch-dominated) |
| `lu` at `n64`/`n96`/`n128` `f64`, F, 4T/8T | 0.49-0.66 | clean |

The sign flips with the dtype at the same code and the same area. A floor counted in
elements predicts exactly that: `A11.nrows() * A11.ncols() > 16384` puts a `c64`
`128x128` trailing update on the sequential side of a crossover that was swept on `f64`.

The LU budget pair (`data/probes/20261018-upstream-lu-pair-repeat/`) measured the
opposite change -- caller `par` restored unconditionally (`a537746`) -- at
**0.740 / 0.696** for `c64 F256` at 4T/8T. That is the right fix for the 22 `lu` cells
and the 19 `solve` cells, but it also deletes the floor, and with it the clean
0.49-0.66 wins at `f64` 64/96/128. Both pairs failed the unchanged-upstream control
gate (1/396 and 12/396), so those figures are diagnostic only.

## Decision

**Neither offered option. Fix the floor's unit instead of the contract.**

`par_threshold` stays an element count of the submatrix, and the floor is applied the
way `2000dd9` already applies the dense GEMM floor: in *flops*, not in bytes or
elements.

```rust
let work = A11.nrows().saturating_mul(A11.ncols())
    .saturating_mul(if T::IS_REAL { 2 } else { 8 });
let par_here = if work > params.par_threshold.saturating_mul(2) { par } else { Par::Seq };
```

- `f64` decisions are bit-for-bit unchanged (`area * 2 > 16384 * 2` iff `area > 16384`),
  so the sweep that chose 16384 keeps its meaning.
- The complex crossover moves from `area > 16384` to `area > 4096`; only `c64`/`c32`
  shapes of 192 and above change, and `n256`'s 128x128 trailing update becomes threaded,
  which is the cell the campaign flagged.
- The comparison saturates, so `par_threshold = usize::MAX` still returns `Par::Seq` at
  every level. The "disable parallelism" meaning survives, which is why this option
  does not need the contract decision at all.

Rationale for preferring this to the unconditional restore: the restore is the larger
behaviour change (it removes a knob the fork documented and tested), and it is the one
that was measured to cost 1.5-2x on the small `f64` cells. The unit fix changes only
the decisions the unit error made wrong.

## What is and is not established

- Committed: `9dc0f0c` on `fix/lu-work-floor-units` (worktree `/tmp/faer-lu-work-floor`,
  branch base `7364be5`), one file, no new knob, no new threshold, no new unsafe.
- Gate: `cargo test -p t4a-faer --lib`, **210 passed / 2 ignored**, the same count as
  main. The existing `threaded_lu_matches_the_sequential_one` now also covers `c64` at
  96/128/192/256/512.
- **Not measured.** No timing run, no formal pair, no pin move. The size of the recovery
  at `c64 n256` is predicted from the `a537746` pair (which restores a superset of this
  scheduling) and from the fact that the `f64` side is untouched; neither is a
  measurement of this commit.
- Adoption still requires a pair that passes the unchanged-upstream control gate. That
  gate, not this decision, is the open blocker: two complete pairs failed it with median
  control ratios of 0.99975 and 0.99899, which is a measurement-stability question and
  not a statement about the candidate.
