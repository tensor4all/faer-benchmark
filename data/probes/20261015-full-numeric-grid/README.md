# Full-shape union numerical verification (both binaries)

Deterministic `verify` grids (no timing) over the union of every declared population shape,
f64+c64, batch 1, at 1/4/8T per vendor, with the declared vendor environment removed.
Raw gzipped CSVs/logs under `raw/`; counts and exit codes in the two summary JSON files.

| revision | binary sha256 | grids | rows each | ok | skipped | failed | tolerance line | budget anomalies |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| pre-correction harness 201c4af | `292be71f6cd13094...` | 3 | 3784 | 1448 | 2336 | 0 | present | 0 |
| pre-correction harness 201c4af | `5ca8f220b5f7d855...` | 3 | 3784 | 1448 | 2336 | 0 | present | 0 |
| corrected harness 780e91d | `cce1442034a105ef...` | 3 | 3784 | 1448 | 2336 | 0 | present | 0 |
| corrected harness 780e91d | `d59f5a802112d8fe...` | 3 | 3784 | 1448 | 2336 | 0 | present | 0 |

The pre-correction grid ran on the previously built binaries; the corrected harness changed only
the failure-row label and a comment, and the corrected-source rebuild is the exact binary the
representative controls and the intended baseline use (same sha256 as the rev2 grid column).
Not checked here: timing, active-worker utilisation, performance, provider equality.
