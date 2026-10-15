# Descriptive GEMM reliability pilot (not a published campaign run)

## Identity and scope

- Fork: `4738e8dcbc2dff0f23520b131d62e6d94fa36c99`, clean.
- Upstream: `0539947ffb757a739d7e703a7d2fa0c792a909c1`, clean.
- Harness: `80fb350ce807b29c7ffd0b1858a3dbe8fc73a2a1` **plus the dirty source**
  captured in `harness.diff`; source SHA256s and exact binary SHA256s are in
  `metadata.json`. This is not a run of clean harness commit `80fb350`.
- Ryzen AI 9 HX 470, CPU 4, explicit one-thread budget. Both faer adapters select
  `Par::Seq`; the vendor reports its configured maximum as 1. Identity readback
  is captured separately for MKL 2026.1 and OpenBLAS 0.3.32 (Cooperlake).
  This is not an active-worker trace and makes no threaded-scaling claim.
- GEMM only, f64, `256x256x256`, batch 1, C and F as separate cases. All adapters
  use the common seed formula and matching A/B seed arguments; inputs, reference
  result, and output buffers are built outside timing, output restoration is
  outside timing, and `run` computes GEMM with replacement/beta=0.
- No changes to library code during these measurements, no builds concurrent
  with timing. `target/campaign.lock` held; each invocation uses the repository's
  `pinned.sh` on CPU 4 with its default 3-second pre/post sibling-aware idle
  check, maximum 5% busy, and one attempt. Every retained guard passed.

## Design and artifacts

`run_pilot.py` captures the exact first-stage driver. The 12-process schedule
crosses two vendor binaries, 500/3000ms per-row priming, and three row rotations.
Vendor/priming order is counterbalanced, not randomized. Each process executes
**the same case twice**, through the same compiled code for each row, retaining
30 chronological timed calls for each occurrence/order/engine. This is a
same-row repetition control, not proof of equivalence between two crates.
The 12-process stage has **one process per exact vendor/prime/rotation setting**;
rotations are not independent replication at fixed order.

`run_fixed.py` adds four processes in MKL/OpenBLAS/OpenBLAS/MKL order at
3000ms and rotation 0. Together with the first-stage process at that setting,
this gives **three separate process starts per vendor at fixed settings**.
These are a small descriptive sample on this host, not independent randomized
trials sufficient for a population claim or a confidence interval.

- `metadata.json`: process schedule, UTC start, exact command/CSV, exit status,
  build environment, CPU information, identity readbacks, binary/source hashes.
- `[00..15]-*.csv`: raw `samples_ms` arrays; no samples/outliers are discarded.
  Each successful row has 30 calls. Physical CSV record order preserves engine
  position and both case occurrences.
- `*.guard` and `*-verify.log`: the guarded commands' output and correctness gate.
- `distributions.csv`: per-process, per-occurrence, per-order, per-engine count,
  mean, median, sample variance, sample SD, min and max. Count is **30 sequential
  calls**, not 30 independent processes. Matrix `n` and `sample_count` are distinct.
- `fixed-process-distributions.csv`: the three process medians at the fixed
  3000ms/rotation-0 setting, plus their mean, sample SD and sample variance;
  occurrences remain separate. Calls are never pooled across processes.

Regenerate both summaries (does not rerun timing):

```sh
python3 data/probes/20261015-reliability-gemm/analyze.py
```

## Observations and limits

At 500ms, slow first-occurrence C-order faer rows have tightly clustered samples
while later occurrences are faster. The slow row changes with engine position;
OpenBLAS also shows first-occurrence C-order sensitivity. Thus small within-row
SD does not establish a small process/order effect. Increasing `--reps` alone
cannot repair that effect.

At 3000ms, the large median shift was not observed in this pilot. This supports
longer priming as an experimental candidate, **not** a proven hardware mechanism
or a sufficient priming floor for other sizes, dtypes, families or threads.
The fixed-setting process medians and their SDs remain visible rather than being
reduced to a best value. One OpenBLAS F-order row contains a late isolated slow
sample; its effect on mean/variance is retained, not trimmed. Looking only at
five early calls would miss that event.

Thirty calls were useful for this diagnostic, but do not establish an optimal
count or measurement precision. Additional fixed-setting process replication and
other representative cases are required before adopting a full-run policy.
No cache-conflict/frequency explanation is proved; temporal dependence remains.

The legacy campaign report still displays minima and does not consume these
sample distributions. No historical result page or generated index was changed.
The full campaign is **not yet validated**: vendor `qr_factor` currently times
input-copy/tau allocation inside `run` while faer's route prepares buffers
outside it; composite checks often refactor rather than checking the exact timed
result; and threaded faer budgets are splitting hints without an owned measured
pool. These boundaries must be resolved before full re-record/performance claims.
