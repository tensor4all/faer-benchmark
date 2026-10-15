## Verdict: changes needed

The ratio calculation matches the intended formula for validated evidence, but the `!` warning measures the wrong quantity. A second warning promised by the design is also absent.

Paths below are relative to `campaign-toolkit/` unless prefixed with `faer-benchmark/`. This was a read-only source review; counterexamples below were derived from the code and retained evidence, not executed.

## Findings

### 1. IMPORTANT — `!` measures differences between engines, not variation between starts

**Evidence:** `campaign_toolkit/report_run.py:289–291`.

`medians` contains **one median-of-start-medians per engine**. Its range therefore measures engine-to-engine performance differences. It does not measure any engine’s between-start range, despite the explanation at lines 241–243.

This produces both kinds of error:

- **False negative:** retained OpenBLAS, 4T, C-order, c64 GEMM `16x240x4096`. The three engine medians are approximately `1.167434`, `1.181840`, and `1.132474`; the implemented warning evaluates to approximately **4.23%**, so no `!`. But the fork and upstream per-start ranges are **25.25%** and **26.31%** respectively.  
  Evidence: `faer-benchmark/data/probes/20261015-v2-representative/between-process.csv:112–114`.
- **False positive:** retained MKL, 8T, C-order, f64 `qr_factor/4096x256`. Every engine’s between-start range is below **1.25%**, but their different performance levels make the implemented warning approximately **104%**, so it prints `!`.  
  Evidence: the same CSV, lines **50–52**.

The existing synthetic test also exposes this statically: every engine has start medians `[2, 3, 4]`, a range/median of **66.7%**, while the warning sees `[3, 3, 3]` and evaluates false. The test checks neither warning presence nor absence.

**Claim 4 is false.** Fixing the prose to describe the current calculation would not satisfy the promised between-start warning.

### 2. IMPORTANT — The design’s position-effect warning is missing

**Evidence:** `campaign_toolkit/report_run.py:287–300`.

Design §2 promises warnings for both:

1. between-start median range/median exceeding 5%; and
2. estimated position-effect ratio exceeding 1.05 in balanced cells.

The reporting branch computes no per-position estimate and has only the incorrect warning described above. `balanced` controls the `*` suffix only.

The referenced standalone analysis does implement the omitted quantity:

- `faer-benchmark/data/probes/20261015-v2-representative/analyze_positions.py:80–87`: per-position mean log medians and their effect ratio.
- Lines **122–123**: comparison against `1.05`.

This is a design/deliverable discrepancy independent of finding 1. The narrower wording in design §5 does not explicitly withdraw the §2 requirement.

### 3. MINOR — An unbalanced cell can have no `*` marker

**Evidence:** `campaign_toolkit/report_run.py:294–299`.

The missing-ratio branch executes `continue` before attaching the balance marker.

For a valid campaign whose **first-declared engine is skipped** for a cell, while other engines are measured in every repeat:

- `balanced` is false;
- every comparison to the first engine is `None`;
- the column prints only `` `engine` - `` entries;
- no `*` appears anywhere.

Such a declaration is not rejected by `timing_evidence.validate`; it requires the recorded schedule to follow declaration order, not that the first engine be measured.

This does **not** publish an invalid numeric ratio, but it falsifies the unconditional claim that cells missing a declared measured engine are marked `*`. It does not affect the current fork-first Householder example.

## Other attacked cases

- **Partial repeats:** `rotation_ratios` alone can return `balanced=True` for incomplete repeat maps because line 102 checks only nonemptiness. However, the normal publication path validates first (`report_run.py:146–148`), and `timing_evidence.py:132–139` rejects missing cells, status changes, and missing process sets. I do **not** classify this as a reachable publication bug.
- **`best` populated but `series` absent:** not produced by successful v2 `best_per_case`; both are populated in the same branch. It occurs normally for v1, where ratio rendering is disabled.
- **Only one shared start:** lines 109–112 correctly return `None`; no ratio is calculated.
- **Fewer than two engines:** zero engines are rejected by validation. One measured engine with at least two starts is accepted and does not crash, but produces an empty `vs <engine>` column and can never receive the current `!`.
- **Formula and keys:** explicit repeat intersection, log-ratio averaging, `[note]`, and case-axis keys are preserved. No list-order pairing found.
- **Compatibility:** the supplied diff changes neither schema nor raw CSV. `statistic == 'median'` remains enforced. The v1 rendered paths appear unchanged, though `best_per_case`’s Python return tuple changes from three values to four; the repository callers found were updated.
- **Campaign independence:** no campaign names are introduced by the reviewed changes. The position-cancellation prose explicitly includes the shared, stable position-effect qualifier.
- **Harness pin:** `faer-benchmark/requirements.txt:1` points to `401dff6d1d8fe6b03bb8c6269c08311f51d4eb44`.

## Delete list

1. `campaign_toolkit/report_run.py:111`: **MINOR — delete:** `detail[engine] = '-'` is unread by the renderer when the ratio is `None`; replacement: nothing.
2. `campaign_toolkit/report_run.py:87`: **MINOR — shrink:** duplicated `statistics.median(values)` calculation; replacement: reuse the median already appended as `times[-1]`.

**net: -1 line possible**, plus one redundant median calculation removed.

## Not checked

I ran no tests, Ruff, rendering commands, builds, benchmarks, or measurements. I did not independently verify Git cleanliness or the complete commit-range diff beyond the supplied patch and inspected source. I did not audit the recorder, admission/guard implementation, or production-run completeness. The author’s reported successful checks remain unverified.
