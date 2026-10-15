# Representative v2 controls (prepared; not executed yet)

These diagnostic controls precede freezing the full-suite budgets. They are not
new baseline performance results, and are not published pages. The proposed
settings are **3000 ms wall-clock priming per operation, 30 chronological calls,
three process starts with engine rotations 0/1/2**, both vendors and C/F. Batch=1.
No method is accepted because fork/upstream point estimates agree. C/F fixtures
are distinct logical matrices, identical across providers within each fixed cell.

`run.py` declares all cases before execution:

| Budget / CPUs | dtype | Families / shapes |
|---|---|---|
| 1 / 4 | f64 | GEMM 4 and 256; factor-only QR 64x8 and 8x64 |
| 4 / 4-7 | c64 | GEMM 16x4096x240; LU/solve 256; thin SVD 64x1024 |
| 8 / 4-11 | f64 | factor-only/explicit-Q QR 4096x256; Cholesky/EVD/values-only SVD 512; both Householder apply variants 4096x256 |

Expected: 64 separately guarded processes (16 census processes + 48 timing
processes), 528 timed CSV rows including 12 declared vendor Householder skips,
15,480 chronological samples. The two Householder variants stay separate.
Configured pool/vendor budgets are checked in each actual CSV row, not inferred
from a separate `info` call or claimed to be active-worker traces.

Supply the two fresh, reviewed-source `--no-publish` smoke directories explicitly:

```sh
python3 data/probes/20261015-v2-representative/run.py \
  data/results/zen5-cpu/faer-kernels/<reviewed-mkl-smoke> \
  data/results/zen5-cpu/faer-kernels/<reviewed-openblas-smoke>
```

This avoids changing committed driver code just to name generated timestamps.
The initial `052425Z`/`052450Z` smokes remain preserved but cannot admit a newer
harness/toolkit revision. The driver refuses changed commits, tracked source edits,
or binary hashes. Both binaries link `extern/t4a-faer` at `bfe4041cd991...` and
`extern/upstream-faer` at `0539947ffb75...`; the saved optimization candidate is
not used. Build/vendor metadata is copied from those production recorder smokes;
current per-budget `info --threads` output is also retained. The driver and analysis
source hashes, driver argv, settings, CPU sets, exact guarded argv, timestamps and exit statuses
are written in `metadata.json` before/after each attempt.

`target/campaign.lock` is held throughout. No builds or other timing campaigns may
run concurrently. The existing sibling-aware 3-second/5% before-and-after guard is
used with **one attempt only**. A spoiled, numerically invalid or timed-out process
aborts the pilot and preserves its CSV/log/progress artifacts; it is not retried
until favorable. Each process is bounded by GNU `timeout` (180 s, kill after 10 s)
for its owned process group. Inspect a timeout's logs/owned descendants before any
changed attempt; do not restart this script into existing directories. An existing
`metadata.json` is refused before it can be overwritten.

Each completed vendor/budget folder has a `control-contract.yaml`: it is an
explicit *diagnostic* grid, **not** a declaration-valid `run.yaml` for the published
suite. The common toolkit v2 evidence validator verifies the complete census,
processes/cells/variants/statuses/rotation, raw samples, medians and budget
readbacks against that grid before a descriptive report is written. It does not
pretend those bespoke cells are the published campaign's selected populations.

After all six controls complete, run `python3 data/probes/20261015-v2-representative/analyze.py`.
It regenerates `within-process.csv` and `between-process.csv`. The former retains
sample SD/variance and min/max per process/variant. The latter preserves all three
process medians, their median and sample SD, and median within-process SD. A
process-median range/median >5% is flagged **descriptively**, not deleted or treated
as a confidence bound. Within-process calls are serial observations, not 30
independent replicates; scheduled between-process variation includes engine order.
No outliers are removed and no paired-treatment/equality claim is made. Any
remaining instability must be disclosed before full-suite settings are frozen.
