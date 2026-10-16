# What the 2026-10-15/16 runs actually linked (found 2026-10-16, not corrected by re-recording)

A `[patch]` is ignored when the locked version is not the version the checkout provides, and cargo
only warns. `Cargo.lock` pinned the crates.io release **`t4a-faer 0.24.5`** while the pinned fork
checkout `bfe4041cd9918815e3b3f766ac0332b792badb7d` carries version **0.24.4**, so every run
recorded with that lock linked the registry release for the `faer-fork` row and the named checkout
only for `faer-upstream` (whose patch did apply). Evidence:

```
warning: patch `t4a-faer v0.24.4 (/…/extern/t4a-faer/faer)` was not used in the crate graph
cargo metadata: t4a-faer 0.24.5 …/registry/src/index.crates.io-…/t4a-faer-0.24.5/Cargo.toml
                faer     0.24.4 …/extern/upstream-faer/faer/Cargo.toml
```

The registry release is not the pinned revision: of 145 source files, three differ —
`src/linalg/evd/mod.rs`, `src/linalg/householder.rs`, `src/linalg/lu/partial_pivoting/factor.rs` —
and it matches neither the baseline checkout nor the candidate branch.

Affected (numbers are the fork's published **0.24.5 release** against the upstream checkout, not the
pinned revision): the four `-timing-v2` pages of 2026-10-15/16, the union verification grids committed
under `data/probes/20261015-union-verify-daily/`, and the throughput charts generated from those runs.
The historical v1 pages were recorded under an earlier lock state and are untouched by this.

The fix is committed with this note: `Cargo.lock` now pins `t4a-faer 0.24.4` (the checkout's version)
and `scripts/build_for_faer_rev.sh` resolves the dependency graph first, refusing to build unless
both measured crates come from the checkouts named on the command line. Re-recording was deliberately
**not** done; treat the affected pages as an approximate picture of the fork's 0.24.5 release and
re-record before quoting them as evidence about `bfe4041`.
