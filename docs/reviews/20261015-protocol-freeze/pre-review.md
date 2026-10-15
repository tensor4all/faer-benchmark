## Findings by severity

**Read-only review:** no files changed, no builds, tests, analysis scripts, or measurements executed.

The control evidence identifies fork `bfe4041cd991…`, upstream `0539947ffb75…`, harness **`198730904711…`**, and toolkit `916dace82589…` (`data/probes/20261015-v2-representative/metadata.json:2437–2466`). That control harness identity must remain distinct from the proposed recording harness `e6430e2`.

Below, **`P/`** means `data/probes/20261015-v2-representative/`; **`T/`** means `/home/shinaoka/projects/tensor4all/campaign-toolkit/campaign_toolkit/`.

### BLOCKER

**1. Three rotations do not position-balance cells with a skipped vendor.**

`fbench/src/main.rs:461–465` rotates the binary’s engine list, including unsupported engines. But an unsupported operation emits a skip and immediately continues—there is no priming or measured work occupying that position (`main.rs:514–544`).

For a vendor-skipped cell, the actual timed order is:

| Rotation | Emitted engine order | Timed engine order |
|---|---|---|
| 0 | fork, upstream, vendor-skip | fork, upstream |
| 1 | upstream, vendor-skip, fork | upstream, fork |
| 2 | vendor-skip, fork, upstream | fork, upstream |

Thus fork is first twice and upstream once. With a fixed first-versus-second multiplicative effect \(q\), the equal-weight geometric fork/upstream ratio retains a factor \(q^{1/3}\). A skipped CSV record preserves an **emission position**, not a measurement position.

This affects `full_piv_lu`, square `triangular_solve`, and both Householder variants; the vendor exclusions are explicit in `fbench/src/lapack.rs:710–731`. The retained Householder CSVs demonstrate the schedule directly (`P/mkl/8t/run0-householder-8t.csv:2–6`, `run1-householder-8t.csv:2–6`, `run2-householder-8t.csv:2–6`).

Other missing-row cases:

- A genuinely missing declared engine/base cell is rejected by the census and rotation checks, rather than balanced (`T/timing_evidence.py:88–90,132–137`).
- Within a Householder **variant**, the vendor has no matching variant row: its generic skip note is different. It must not be manufactured into a third observation.
- Fully skipped cells have no ratio.
- A two-engine binary with `aa=3` is rejected by the existing complete-cycle requirement (`T/timing_evidence.py:69–70`).

**Required change:** either narrow the claim and label these as schedule-averaged, unbalanced comparisons, or change and validate the schedule/estimator for supported-engine cells before recording. Merely increasing `aa` to six while retaining the same three cyclic orders does **not** fix this.

---

**2. Even a complete 3×3 square does not cancel “any” position effect.**

The cancellation holds under a specific model, for example

\[
\log m_{e,r}=\alpha_e+\beta_r+\gamma_{p(e,r)},
\]

where the position effect is **shared across engines and invariant across process starts**. It does not hold for arbitrary engine×position effects, process×position interactions, predecessor effects, or additive millisecond penalties.

The controls already show why the qualification matters. In MKL C-order Cholesky, fork’s first-position median is about 1.386 ms versus approximately 1 ms subsequently; upstream shows the corresponding first-position slowdown. But MKL, first in rotation 2, remains approximately 0.868 ms, close to its other rotations—not 40% slower (`P/between-process.csv:62–64`). Treating all three as receiving one common positional multiplier is not established by those observations.

The analyzer nevertheless states unconditional cancellation (`P/analyze_positions.py:4–16,98–99`), which the plan repeats.

**Required change:** call the quantity a **rotation-averaged geometric ratio**, describe the model under which cancellation occurs, and explicitly retain interaction/history uncertainty. This does not require establishing the hardware mechanism or adding confidence intervals.

### IMPORTANT

**3. The frozen formula is mathematically wrong as written.**

Plan §2 specifies:

```text
exp(mean(log(median_engineA - median_engineB)))
```

That is not a ratio, is dimensionful, and is undefined whenever A ≤ B. The control analyzer actually computes the difference **between log medians** (`P/analyze_positions.py:84–90`).

Freeze the unambiguous expression:

\[
R_{A/B}=\exp\left(\frac13\sum_{r=0}^{2}
[\log m_{A,r}-\log m_{B,r}]\right).
\]

State the numerator convention: a time ratio greater than one means A took longer. This is probably a transcription error, but it cannot remain in an implementation contract.

---

**4. The evidence does not establish the claimed separation into common process shifts and position effects.**

The “50/172” statistic is a range across each **engine-cell’s** three medians. Those observations change both process start and row position. `P/analyze.py:39–50` does not remove position effects or estimate a common process factor. Consequently, that count is evidence of **scheduled between-process variation**, not a count of isolated process-level shifts.

There is evidence of shared movement in particular cells, but not a universal common level:

- MKL F-order LU: fork moves approximately 1.224 → 2.115 ms, upstream 0.903 → 1.499 ms, vendor 0.582 → 0.663 ms (`P/between-process.csv:35–37`). The vendor/faer comparisons do not enjoy the same apparent stability as upstream/fork.
- OpenBLAS C-order Cholesky has fork slow in rotation 0, upstream in rotation 1, and vendor in rotation 2—precisely the first-position schedule (`P/between-process.csv:148–150`).
- OpenBLAS C-order factor QR shows substantial vendor-only movement while both faer rows remain stable (`P/between-process.csv:136–138`).

Also, disagreement between geometric ratios and ratios of median-of-three values does not itself identify a position effect; differing estimators can disagree under engine-specific variation.

**Required change:** retain the descriptive statistics, but replace “process-level level shifts dominate, with all engines moving together” with the narrower observation that substantial variation remains between scheduled process starts, sometimes shared and sometimes position- or engine-dependent. Do not infer that arbitrary within-process comparisons are stable.

---

**5. The proposed position warning inherits an invalid estimator for skipped cells, and its stated maximum is wrong.**

The analyzer reconstructs positions from engines having successful rows (`P/analyze_positions.py:60–73`). For Householder, this becomes a two-engine design with three rotations—not a balanced 3×3 design. Position means then contain unequal mixtures of engine effects. Six Householder entries exceed the warning threshold in the displayed output, so the reported “17/60” is not a clean count of estimated position effects.

Furthermore:

- The stored range is a **difference of mean log medians**, not a percentage (`P/analyze_positions.py:77–78`).
- Thresholding uses `log(1.05)` (`:113`).
- The output contains an OpenBLAS Cholesky range of **0.396**, exceeding MKL’s 0.214 (`P/position-analysis.txt:9,39`). On the corresponding multiplicative scale these are about 49% and 24%, respectively—not a worst case of 21%.

**Required change:** define the warning’s scale exactly, restrict any position-effect interpretation to a design for which it is identifiable, and correct the supporting summary. “Unavailable/confounded” is preferable to inventing an estimate for skipped/absent-engine cases. The process-range warning should also explicitly say whether it is per engine or triggered by any engine in the comparison cell.

---

**6. The report extension is feasible, but the pilot analyzer is unsafe to lift into the production reducer unchanged.**

Two concrete implementation hazards:

- `P/analyze_positions.py:49–50` omits **dtype**, regime, and batch from its key. The pilot has one dtype per budget (`P/run.py:94`); the full run has both dtypes at every budget. Reusing this grouping would overwrite/mix evidence.
- `T/report_run.py:34–41` preserves repeat identity, but `best_per_case` reduces medians into unlabelled lists (`:60–85`). Per-process ratios must join by explicit repeat identity, not by incidental list order.

The existing production keys already preserve variants and report axes (`T/report_run.py:46–57,68–69`). Keep those boundaries, the current median ± SD/W cells, v1 behavior, and the v2 validation gate.

**Schema consequence:** derived ratios and warnings need no new raw CSV or manifest schema. Keep `timing_policy.statistic: median`, since that describes each process’s samples. The schema permits only `best`/`median` and rejects undeclared policy properties (`T/schemas/benchmark-run.schema.json:325–361`). If adding machine-readable policy fields, schema work is real scope—not an implicit reporting tweak. The smaller alternative is fixed documented semantics using existing evidence and notes.

Finally, changed toolkit code cannot still be recorded as `916dace`: commit it, update `requirements.txt:1`, and record the actual clean toolkit/harness identities. The recorder already enforces clean source identity (`T/record_run.py:331–339`).

---

**7. The retry policy is defensible, but the supporting control manifests misstate it and the “default” justification is inaccurate.**

The actual controls used eight retries, but the copied contracts still say one:

- `P/openblas/8t/control-contract.yaml:93–99`: `attempts: 1`.
- Its generated report repeats one attempt (`P/openblas/8t/report.md:15`).
- `P/openblas/8t/run2-decompose-8t.guard:1–3`: eight permitted attempts, success on attempt 2.

The driver changes the environment but copies the old manifest and only clears its guard-log list (`P/run.py:68,95–107`). The timing-evidence validator does not validate guard-log policy.

The production default is **three**, not eight: `benchmarks/scripts/pinned.sh:28` and `T/record_run.py:531`. One was the earlier control override.

On the substantive policy:

- Eight attempts do not loosen the before/after thresholds.
- `set -e` plus the direct command at `pinned.sh:42` means a nonzero benchmark exit aborts rather than becoming another admission attempt.
- Successful data is selected by guard outcome, not by measured time.
- However, this is evidence conditional on passing endpoint windows, **not proof of contamination-free execution or absence of selection effects**. The script observes no intervening workload, suppresses the checker’s CPU details, and does not wait 30 seconds after a failed post-window—only after a failed pre-window (`pinned.sh:30,37–48`).

Observer affinity 0–3 is recorded for the control driver (`P/metadata.json:2547–2561`), but neither the driver nor recorder sets it. An external launch can satisfy the contract; recorder affinity alone does not establish the already-running agent’s affinity.

**Required change:** reconcile the control-contract/report discrepancy without erasing original evidence; state the actual default; and freeze an explicit launch environment/observer placement rather than treating either as an existing automatic guarantee. No new retry framework is needed.

### MINOR

**8. The census mixes base cells with variant-expanded rows. The priming floor itself is correct.**

The suite expands to 5,148 **base engine-cells** per set/vendor. Householder returns two operations for each faer engine (`fbench/src/backend.rs:859–863`), adding 192 rows over the declared Householder shapes.

Source-derived accounting is therefore:

- 5,148 base cells;
- 3,756 successful base cells;
- 192 additional successful variant rows;
- **3,948 primed rows**;
- **1,392 skips**;
- **5,340 emitted CSV rows**.

Thus “5,148 base cells, of which 3,948 measurement rows, the rest skips” is not a valid partition.

The floor remains \(3948×3\text{s}×3=9.87\) hours/vendor. The process count also matches the recorder: ten populations × three budgets gives 30 verification and 90 timing invocations/vendor (`T/record_run.py:419–446`). Retries can increase actual starts.

**Budget judgement:** Option A is the conservative choice because it retains the tested settings—not because 3 s has demonstrated steady state. Option B has no representative evidence at its proposed settings. The 1.5–3-day estimate is a planning allowance, not a measured bound.

The cheaper **3 s / 10 calls / three sets** variant preserves the priming floor, chronological samples, defined sample SDs, and the same rotation schedule. It does **not** preserve 30-call evidence or repair findings 1–2. There is no cheaper budget variant that preserves the plan’s current universal cancellation guarantee, because that guarantee is already false.

---

**9. Correct the control-summary labels before using them as the frozen rationale.**

`P/run.py:94` measures c64 at 4T and f64 at 1T/8T. The summary mislabels the 4T GEMM example as f64 and the 8T Cholesky example as c64 (`docs/worklog.md:35–41`; also `P/analysis.md:27,43`).

The claimed approximately 2.26× difference applies to F-order **factor QR**, not both QR families: the MKL explicit-Q ratio is approximately 1.80 (`P/position-analysis.txt:26–29`). More generally, source divergence does not prove every observed performance difference is a real algorithmic difference (`P/analysis.md:12–15`).

These are descriptive controls, not identical-source A/A controls, equality evidence, or provider-superiority evidence. The numerical-grid README supports successful numerical checks at the recorded binaries; it does not validate the proposed comparison estimator.

## Delete list

1. **Plan §2 / `P/analysis.md:46–50`: `delete:` unconditional “cancels any position effect”; replace with the explicit model-dependent, rotation-averaged interpretation.**
2. **Plan §5: `reuse:` do not introduce a parallel ratio CSV/schema/configuration layer; use the existing chronological samples, repeat labels, variant keys, and v2 report path.**
3. **Plan §4: `delete:` unchosen budget alternatives from the final frozen contract; retain one human-approved setting, without a new runtime policy selector.**

**Net: −0 existing code lines proposed; avoid adding a separate evidence/configuration layer.**

## Unchecked scope

- No scripts, validators, tests, builds, or measurements were run; numerical summaries were inspected, not independently regenerated.
- Raw timing CSVs were spot-checked for schedule and sample evidence; not every sample or archived aborted-attempt CSV was audited.
- The compressed full-grid artifacts, binary hashes, Git cleanliness, and library diffs were not independently verified.
- Actual agent/thread placement, intervening host activity, thermal/frequency state, active-worker utilization, and full-suite elapsed time were not observed.
- No implementation diff exists yet, so v1 regression behavior and final publication/index behavior were not executed.

**Verdict: Must change before implementation—correct the formula, withdraw universal position-cancellation claims, define skipped/variant-cell comparison and warning semantics, reconcile admission evidence, then freeze one budget and the actual post-change source identities.**
