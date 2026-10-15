# Union numerical verification of the daily suite (2026-10-15/16)

Supplementary to the mandatory per-population `verify` that `record_run` runs before any timing.
Each grid below verifies the union of every shape the daily suite declares, with all declared
families and both dtypes, at one thread budget, with the declared vendor environment removed:

| grid | exit | rows | ok | skipped | failed | tolerance line |
| --- | --- | --- | --- | --- | --- | --- |
| `faer-kernels-mkl` 1T / 4T / 8T | 0 | 3,944 each | 1,332 each | 2,612 each | 0 | present |
| `faer-kernels-openblas` 1T / 4T / 8T | 0 | 3,944 each | 1,332 each | 2,612 each | 0 | present |

Raw gzipped CSVs/logs: `raw/`; machine-readable counts and binary SHA-256: `summary.json`.
Binary identities at run time: mkl `7a0c2d6474f1...`, openblas `25322cf27657...` (both rebuilt from
harness `e55c7e4` with `--rows` support).

**Not claimed:** the same union grids for `faer-kernels-large` were started and cut off by the
harness timeout (their logs are kept in `raw/` marked by the missing tolerance line and nonzero
status they never reached); the large tiers are not covered by this supplementary evidence, and
nothing here is a timing measurement.
