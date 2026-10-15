# Frozen protocol — timing-v2 baseline and candidate mode

This is the contract the baseline re-record and every later optimization iteration
are run under. It is frozen as of this commit; changing it needs an explicit
decision and a new version suffix on the page, because numbers recorded under a
different contract are not comparable.

## 1. Frozen measurement settings

| Setting | Value |
| --- | --- |
| `--prime-ms` | **250** (calibrated: 250/10 and 250/30 are within 0.978-1.006 of 3000/30 over 18 rows, far below the 0.5-35% between-start range) |
| `--reps` | **5** |
| `--aa` | **3** complete process sets, row rotation step 1 (each engine occupies each row position once) |
| `--statistic` | `median` |
| Coverage | the declared suite, fully: all populations, `f64`+`c64`, order `c`+`f`, batch 1, threads 1/4/8 |
| Small-shape grids | `gemm-small` and `linalg-small` are declared as **8, 64** only: their 4T/8T cells were measured to be thread-region dominated (gemm 32^3 pays a constant +8 to +11 us at 4T/8T; 4^3 never enters a parallel path; MKL +0.3-0.8 us), so they are not worth the machine time at every budget |
| Rows per arm | MKL: `faer-fork`, `faer-upstream`, `lapack-mkl`. OpenBLAS: `faer-fork`, `lapack-openblas`. The duplicated faer rows differ by 2% median (26% worst, the known rotation bump) between arms, so the fork/upstream pair is kept in one arm and the vendor pair in both |

## 2. Frozen machine preconditions (enforced, not remembered)

- **Boost/turbo off.** The recorder refuses to start while a boost switch is on
  (`cpufreq_boost=1` or `intel_pstate/no_turbo=0`); the exact command is printed.
  `FBENCH_ALLOW_BOOST=1` records the deviation instead, and such a run is not
  comparable with a boost-off run. Boost on/off is the largest single factor seen
  so far: `cholesky` 512^2 f64 8T process-median range fell from 40-73% to 1.5-5%
  once boost was disabled, `lu` 256^2 c64 4T from 74% to 33%.
- **Power state recorded.** `host.power` in `run.yaml` carries boost, governor,
  EPP hint, `scaling_max_freq` and the platform profile when the host exposes
  them. Governor/EPP/profile are `performance` for the baseline host.
- **Measured threads share one L3 domain.** A declared set spanning domains is
  legal and warns instead of failing; every CPU in every touched domain must then
  stay idle.
- **The observing side stays off the measured L3 domains.** The recorder derives
  the measured set and the free CPUs from sysfs and refuses to start when its own
  affinity overlaps; the agent's own pin lives in its process and is
  re-established after a restart. A run that needs every domain can only proceed
  with `FBENCH_OBSERVER_SHARES_L3=1`, which records the residual sharing.
- **The idle guard watches whole L3 domains**, SMT siblings and cache peers
  included, so a partially filled domain cannot hide unrelated work. 3 s window,
  `max_busy=0.05`, `PINNED_RETRIES=8`, `PINNED_WAIT=30`; a rejected attempt is
  discarded and re-run on the same schedule, never selected by its numbers.
- One campaign lock, build-then-verify-then-time, no build while a measurement
  runs, abort on any failure with the artifacts preserved.

## 3. What a recorded number means

- Per row: chronological calls, median reported; per cell and engine: median of
  the process medians, between-start sample SD, median within-start SD.
- Comparison: the **rotation-averaged ratio** `exp(mean over starts of
  log(median_A / median_B))` inside a cell, with the per-start ratios printed
  beside it. It removes a position effect only under one position effect shared by
  the engines and stable across starts, and only where every declared engine has a
  measured row (`*` marks a cell where one does not).
- Warnings, never rejections or trimming: `!` a per-engine between-start range
  above 5% of its median, `p` a balanced cell whose estimated position-effect
  ratio exceeds 1.05.
- No confidence intervals, no equality or superiority claims, no cross-cell
  pooling, `c` and `f` never merged, skipped cells recorded as skipped.

## 4. Candidate mode (optimization iterations)

An optimization iteration does **not** re-measure every backend on every test. It
runs in three steps, and a comparison is published only if all three pass.

1. **Same-machine precondition, checked from the record.** The candidate run's
   `library` commit is the only identity allowed to differ from the baseline. Its
   upstream revision, harness commit, toolkit commit, suite declaration, host
   block (`cpu`, `logical_cpus`, `l3`, `l3_domains`, `host.power`), thread CPU sets
   and timing policy must equal the frozen baseline run's. A difference in the
   machine state refuses the comparison before any timing.
2. **In-run machine-state control.** The candidate binary carries the *unchanged*
   `faer-upstream` row. A predeclared overlap set of cells — at minimum
   `gemm 256^3 f64 1T`, `lu 256^2 c64 4T`, `cholesky 512^2 f64 8T`,
   `qr_factor 4096x256 f64 8T`, `svd_thin 64x1024 c64 4T`, `householder_apply
   4096x256 f64 8T` — is measured and the upstream row compared with its recorded
   baseline value. If it leaves the recorded between-start spread (or the cell's
   warning threshold), the machine is not in the baseline state and the comparison
   is refused rather than reported.
3. **Fork-only measurement of the selected cells.** Once step 2 passes, only the
   `faer-fork` row (plus the upstream control row) is measured on the chosen
   subset. The comparison is the rotation-averaged ratio of the candidate fork to
   the recorded baseline fork per cell, with the candidate's own process spread
   recorded beside it.

Rules that make this honest rather than convenient:

- The subset is declared **before** the run, is reported with the comparison, and
  is never widened after seeing the numbers.
- Missing coverage is reported as missing; a cell that was not measured carries no
  inference, and "unchanged elsewhere" is not claimed from a subset.
- A candidate run that has to be repeated keeps both attempts; the reported one is
  never selected because its numbers look better.
- Absolute values for the candidate come from its own run, not from copying the
  baseline's; the baseline remains the reference for the fork-vs-upstream and
  fork-vs-vendor ratios.
- Adoption of an optimization still requires the same evidence as any other
  change: the candidate comparison above, the numerical verification grid, and an
  independent review of the finished diff.

## 5. What is explicitly out of scope

Establishing the mechanism of the remaining between-start variation; publishing
candidate numbers as if they displaced the baseline; treating the vendor rows as
identical low-level implementations; and any claim about cells the declared suite
does not contain.
