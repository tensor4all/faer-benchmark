# Proposal: separate host-state control from linked-binary variation

Status: proposal only; NO protocol, gate or timing boundary has been changed.
User approval is required before an effective comparison-contract change.

## Goal and boundaries

Remove every reproducible, technically removable fork slowdown against upstream,
then freeze the final candidate and rerun the declared daily and large suites on
both vendors. 2048/3072/4096 are FINAL-ONLY, never development-loop cells.
No threshold relaxation, favorable-cell omission, fabricated adoption, or third
identical full-pair retry. Existing failed pairs remain INCONCLUSIVE.

## Evidence

- The two 396-cell LU pairs failed unchanged-upstream controls: 1 cell, then12;
  median control ratios0.999747/0.998988. See
  `data/probes/20261018-upstream-lu-pair-repeat/` and the four linked run dirs.
- NEW, smaller diagnostic (not a third pair): fixed old/new binaries, upstream
  Cholesky row only, n32/64/96/128, f64/c64, C/F, budgets1/4. Sequence
  A B B A B A A B, verify first, same CPU sets, guard, median5 and250ms.
  `data/probes/20261018-upstream-binary-abba/` retains hashes, worker census,
  commands, all samples, power observations and descriptive comparisons.
- At1T, upstream f64 n32 C is consistently B/A1.0779 (A range3.206–3.226us,
  B3.437–3.507us); complex n32 C instead B/A0.9571. A simple uniform host-speed
  change cannot explain that dtype-dependent, binary-following shift alone.
- In the two binaries, all four SIMD Cholesky leaves have unchanged sizes and
  normalized instruction sequences, but entry addresses differ by16 bytes.
  The timed upstream f64 path reaches leaf A0x209420/B0x209430 through
  Llt::new -> cholesky_recursion_right_looking. RIP displacements were normalized,
  so equal referenced constants and exact alignment causality are NOT proven.
  Kernel PMU counters are unavailable under current perf_event_paranoid4;
  do not change shared sysctls to obtain them.

These findings establish a repeatable fixed-binary effect in selected controls,
not a universal mechanism or a license to ignore all control failures.

## Smallest proposal for review

Keep all original public-call boundaries, fixtures, priming, statistics, thread
budgets, row rotations and in-binary fork/upstream/vendor rows. Do not present
new numbers as comparable merely because sources are unchanged.

Add a SHA256-pinned reference executable as a separate pre/post host-state
check as a diagnostic sidecar only (not an acceptance replacement). Reuse an existing fbench executable and its
upstream row, original pinned.sh and unchanged numerical verification. Declare
representative control cells BEFORE a future candidate pair and freeze the
reference binary, source provenance, grids, budgets and spread. The reference
must be the SAME executable on both sides. Keep current in-binary upstream
comparisons as reported evidence, including their movement; never silently
substitute external-reference values into the published performance table.

This would distinguish 'fixed-program host check failed' from 'the linked
unchanged-source row moved'. A failed fixed-reference check would still block
acceptance. A changed in-binary control that cannot be bounded/explained must
also keep the decision inconclusive; passing an external reference alone does
NOT prove every target/guard delta is algorithmic. Need a precise conservative
rule for linked-binary uncertainty before accepting anything, rather than
choosing a larger percentage after seeing a result.

No new dependency, numeric API or provider layer is proposed. Start with the
existing command-line fbench, sidecar records and comparison helpers. If a
correct, conservative acceptance rule cannot be expressed this way, report it
and ask about a proper revised protocol instead of expanding infrastructure.

## Alternatives / reviewer questions

1. Can the existing predeclared-control provision support a new, genuinely
   predeclared experiment without a contract revision? This MUST NOT relabel the
   two refused pairs or cherry-pick controls just because they passed.
2. Does a fixed reference materially address host-state attribution while leaving
   cross-binary fork guard uncertainty unresolved? Identify that limitation.
3. Is a versioned adoption-policy change sufficient with unchanged timed loops,
   or is a new timing suffix needed under the frozen contract? Do not overwrite
   historical v2 pages with different semantics.
4. What is the smallest scientifically defensible next step, without machine/
   shape-specific padding or compilation tricks and without big-size reruns?

No adoption is proposed from the evidence collected so far.
