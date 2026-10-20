# ELF re-comparison: what it can and cannot support (2026-10-18)

Status: **correction record**. Three performance conclusions in this campaign rested on
comparing machine code of already-built ELFs. They are demoted here to static
observations. No new build, measurement or adoption follows from this record, and it
does not by itself clear or convict any candidate.

## The claims that existed

| where | claim | what it was used for |
|---|---|---|
| handoff §3 (`20261018-native-copy-tile`, `public-code/aliases-complete/`) | both cloned measures and four cloned wrappers have the same size and normalized instruction sequence | support for "the unchanged control that moved 17% is not explained by the candidate" |
| handoff §5 (`20261018-native-gemm-callers/main-vs-correctness-*`) | all four dense functions at four sizes have identical normalized instructions, difference 0 | support for "the empty-extent/K0 correctness fix does not change performance" |
| `20261018-upstream-binary-abba` (`code-comparison.json`, `leaf*-normalized.diff`) | four SIMD leaves have the same normalized instructions with +16-byte entry shifts | part of the binary-follows-the-difference diagnostic |

## Why none of them is a performance statement

1. **The campaign's own data contradicts the inference.** The copy diagnostic in §3
   found the ELFs of the unchanged control cell identical, and that same control cell
   then left its baseline band by 17% (`c64/C/64x1024/cloned/1T`, B/A 0.8265). If
   identical code of that function implied an unchanged time, the run would not have
   happened. This is not a new argument: it is the counterexample already retained in
   `data/probes/20261018-native-copy-tile/public-outcome.json`.

2. **The comparison is between different build contexts.** The two ELFs come from
   different binaries: different total code size, different addresses, different
   inlining decisions outside the compared functions, different allocator call sites.
   `main-vs-correctness-*` in particular compares a saved `7364be5` binary with a
   `b7715c5` binary, not two builds of one recipe.

3. **Normalized instructions of four functions do not constrain the whole program.**
   The `upstream-binary-abba` README already says this ("narrows the possibilities but
   does not prove alignment causality or whole-program equivalence"). The 16-byte entry
   shifts and the unequal Equator vtable pointers in that probe are exactly the
   confounders a timing difference can follow.

4. **A function can be byte-identical and still be slower.** The cost can sit in a
   caller, in a dispatch decision, in what the callee is handed, or in the schedule of
   parallel regions around it. The fork's own `c64` `n256` LU regression is an example
   of a change that is entirely a scheduling argument, not an instruction difference.

## What these records now say

- §3: static observation about the copy candidate's code shape. **It neither explains
  nor exonerates the shifted unchanged control.** The cause of that shift is unestablished.
- §5: static observation about two saved binaries. **It is not a performance clearance
  for the empty-extent/K0 fix.** Whether that fix moves a number is unmeasured.
- ABBA probe: unchanged as a diagnostic, with its stated limitations. It does not
  become adoption evidence by being re-read.

## What would replace them

The campaign already has the right design and does not need a new one: the
2026-10-15 same-source control (`docs/worklog.md`, "the fork-vs-upstream column is not
a controlled comparison") -- a rename-only build as one row, the fork as the other, and
the two rows swapped, so a difference that follows the position inverts and a difference
that follows the code does not. Any performance claim that was resting on ELF identity
should be taken from a paired run with that control, at a passing control gate.

**Not done here:** no rebuild, no re-timing, no re-review. The three claims are demoted
in this file and in the handoff's correction note; the measurements they were standing in
for are still missing.
