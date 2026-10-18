# Merging a candidate into `faer` main

The procedure behind criterion 1-3 of `protocol-v2-baseline.md`, written down so a merge does not
depend on what the last session remembered. `AGENTS.md` links here; the protocol owns the rules and
this file is the order of operations.

## What a merge means

A merge moves `faer` `main` to a revision that has already been measured at *that* revision. The
full declared suite is not part of a merge; it is recorded once at the final frozen candidate and
published afterwards. A merge is not an adoption claim about cells nobody measured.

## Preconditions

1. **The branch is a descendant of `main`** - `git rev-list --count <branch>..main` is 0. If it is
   not, rebase first; never merge a branch whose base predates `main`.
2. **The correctness gate passes** - `cargo test -p t4a-faer --lib` in the branch checkout, with the
   same pass/ignore count as `main` plus the tests the change adds. The change's own focused tests
   are part of this gate, not a substitute for it.
3. **The measured paths are the merged paths** - `scripts/candidate_compare.py --merged-commit
   <rev> --checkout <fork checkout>` compares the tree hashes of `faer/src`, `faer-traits/src`,
   `faer-macro/src` and the two `Cargo.toml`s plus `Cargo.lock`. A merge, rebase or rename that
   leaves them alone keeps the measurement valid; one that changes them invalidates the cells that
   depend on it, and those are re-measured rather than assumed.
4. **A correctness-only change** whose changed code is on no declared benchmark path needs no pair.
   Say which paths it reaches and why no declared cell executes them - `spicy_matmul` reaching only
   dense LDLT and sparse Cholesky is the worked example - and merge on the tests. That is a
   statement about reachability, not a performance claim, and it is recorded as such.

## The pair

The target and guard grids are declared **before** the runs, from the changed paths: the affected
families at every declared shape, dtype and order at 4T and 8T, the target cells at 1T, and two or
three collateral cells of families the change cannot reach.

1. Build and verify before timing; the recorder holds one campaign-level lock across build, verify
   and timing, so nothing else builds or measures meanwhile.
2. Record the baseline at `main` and the candidate at the branch head, interleaved in time, with the
   frozen policy (250 ms priming, 5 calls, three complete process sets, boost off, observer off the
   measured L3 domain, the whole-domain idle guard).
3. `scripts/candidate_compare.py --baseline <run> --candidate <run> --merged-commit <rev>`. The
   control decision is the unchanged `faer-upstream` row's **median** within 2%; the per-cell tail
   is printed and retained but does not refuse, because the unchanged row moves with the linked
   binary and a cell-by-cell rule refuses even two runs of one revision.
4. A refused comparison means no merge. It is not retried with a relaxed band or a trimmed start.

## The merge and the record

- Merge the measured revision (fast-forward when the branch is a descendant, so the measured tree is
  the merged tree), then confirm the tree hashes again.
- Record in `PATCHSET.md` and the campaign worklog: the measured commit, the tree hashes, the target
  and guard results, the run directories that carry them, and the date. An entry without its run
  directory is not a record.
- Move `pins/t4a-faer.rev` to the measured revision when the candidate is adopted: the pin names the
  revision the campaign materialises and the pages quote, so it follows the adoption, not `main`.
  It moved to `2870062` when `0c71ca2` was merged. Re-recording the declared suite at that revision
  is the publication step that follows a merge, and it is a separate, deliberately started run.
- Rejected and HOLD branches stay where they are with their records. A merge does not delete the
  branches that lost, and a HOLD candidate is not revived by a neighbouring merge.

## Current candidates

| candidate | kind | state |
| --- | --- | --- |
| `fix/native-gemm-empty-extents` (`2e221c7`, `af8273f`) | correctness, no declared benchmark path | tests pass; merge on precondition 4 |
| `fix/lu-work-floor-units` (`9dc0f0c`) | performance, `lu`/`solve` at 4T and 8T | needs its pair |
