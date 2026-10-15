## Files reviewed

All four prepared, line-numbered/SHA source packs were read completely, once each.

**Toolkit paths relative to `/home/shinaoka/projects/tensor4all/campaign-toolkit/`:**
- `campaign_toolkit/record_run.py` — lines 1–555.
- `campaign_toolkit/validate_run.py` — lines 1–267.
- `schemas/benchmark-run.schema.json` — lines 1–562.
- `schemas/campaign.schema.json` — lines 1–366.
- `campaign_toolkit/campaign.py` — lines 203–229.
- Scoped supplementary publication/comparison/API checks: `compare_runs.py:39–103`, `publish_report.py:1–88`, `descriptor.py:274–289`, and selected `report_run.py` call boundaries through line 303.

**Harness paths relative to `/home/shinaoka/projects/tensor4all/faer-benchmark/`:**
- `scripts/build_for_faer_rev.sh` — lines 1–246.
- `benchmarks/campaign.yaml` — lines 1–169.
- `requirements.txt` — line 1.
- `data/probes/20261015-v2-representative/run.py` — lines 1–141.
- Both supplied smoke `run.yaml` manifests — lines 1–151 / 1–154.
- Supplementary linkage/protocol checks in `fbench/Cargo.toml`, the two measured-package `Cargo.lock` entries, and `benchmarks/scripts/pinned.sh`.

## Status

**COMPLETE for the bounded orchestration/provenance slice.** Two IMPORTANT findings and one MINOR finding; no BLOCKER found.

No files were modified, commands/builds/tests executed, or performance measurements independently verified.

## Focus area verdicts

1. **Recorder → verification → timing → validation/report: PASS at the orchestration boundary.**  
   The campaign lock precedes building; verification covers all selected population/budget combinations before timing; v2 passes explicit repetition, priming, median and rotation arguments; manifest validation precedes reporting (`record_run.py:328–341,403–451,538–548`). The validator dispatches v2 evidence checking only for v2 (`validate_run.py:230–236`). Census/sample validator internals remain excluded.

2. **Provenance and same-source/linking assurance: FINDING — IMPORTANT installation prerequisite mismatch.**  
   The actual build helper patches both package dependencies to the named checkout paths and separates vendor target directories (`scripts/build_for_faer_rev.sh:78–95,113–116,212–226`). Post-timing binary/source checks exist (`record_run.py:461–471`). Both supplied manifests name the same requested fork/upstream commits and paths. However, ordinary installation from `requirements.txt` does not provide the Git source layout assumed for toolkit provenance; see finding 1.

3. **Budget and guard capture: PASS within this scope.**  
   Ambient declared vendor/thread variables are removed, each invocation receives the selected thread count and CPU set, and guard stderr is retained (`record_run.py:381–386,409–419,433–446`). The manifest records repetitions, priming, CPU sets and guard policy (`record_run.py:494–519`). This does **not** establish active-worker traces; measured-process readback consistency belongs to the excluded evidence/runtime reviews.

4. **Schemas, legacy compatibility and v1 page protection: PASS, with a MINOR default issue.**  
   V2 selection is explicit (`record_run.py:253–254`); v2-only flags and evidence dispatch are conditional (`record_run.py:415–416,441–442`; `validate_run.py:231–236`). Legacy comparison explicitly refuses v2 (`compare_runs.py:49–52`). The configured page template includes `{timing}`, which is empty for v1 and `-timing-v2` for v2 (`benchmarks/campaign.yaml:94–96`; `campaign.py:219–229`). See finding 3 concerning the unusable default process-set count.

5. **Failure preservation, publication and `--no-publish`: FINDING — IMPORTANT status propagation gap.**  
   Verification/timing failures retain the produced CSVs and guard logs; validation failure retains `run.yaml` (`record_run.py:418–424,445–450,538–543`). `--no-publish` still validates and generates the local report, then bypasses publication (`record_run.py:540–550`), so it does not invoke page/index mutation. Normal publication can nevertheless fail without causing recorder failure; see finding 2.

6. **Diagnostic driver integration and scheduling: PASS for the reviewed call boundary.**  
   It uses the same campaign lock, strips declared ambient variables, forces one guard attempt, runs verification before timing for each selected budget, rotates all three engine orders, retains command/stdout/guard records, and aborts rather than automatically retrying failures (`data/probes/20261015-v2-representative/run.py:55–68,96–124`). Its report calls match the available APIs, and it writes a separately named control contract rather than pretending its bespoke populations satisfy the published suite declaration (`run.py:126–132`). GNU `timeout` is invoked without `--foreground`, preserving its process-group timeout behavior (`run.py:101–105`).

## Findings

### 1. IMPORTANT — Declared toolkit installation does not satisfy the provenance implementation

**Evidence:** `requirements.txt:1` specifies an ordinary pinned VCS package installation. `campaign_toolkit/record_run.py:321–325` instead assumes the installed module’s grandparent is a clean Git toolkit checkout.

An ordinary wheel installation does not preserve that checkout. Outside another repository, recording fails at the Git lookup; inside an ignored repository-local virtual environment, Git can resolve an enclosing repository instead, recording that repository’s identity as the toolkit identity.

The supplied editable-checkout smokes satisfy the assumption; the declared installation path does not guarantee it.

**Suggested fix:** Make installation explicitly provision the pinned editable Git checkout and verify that its Git top-level is the toolkit source root, or derive installed-package provenance without assuming Git checkout layout.

**Disposition:** Must fix the supported installation/provenance contract before merge.

### 2. IMPORTANT — Publication/index failures can be reported as recorder success

**Evidence:**
- `campaign_toolkit/record_run.py:550–551` ignores the publication subprocess result and returns zero.
- `campaign_toolkit/descriptor.py:288–289` runs subprocesses without `check=True`.
- `campaign_toolkit/publish_report.py:74` similarly ignores the index-generation subprocess result.

Consequently, publication can fail while the recorder succeeds. Index generation can also fail after a page was written, leaving a stale index while both publication and recording appear successful.

**Suggested fix:** Check and propagate the subprocess return codes at these publication/index call sites.

**Disposition:** Must fix before treating successful production recorder exit as successful publication. This does not invalidate the supplied `--no-publish` smoke path. Whether the gap predates this change was not established from the supplied source packs.

### 3. MINOR — The opted-in campaign’s default invocation necessarily rejects its default `--aa`

**Evidence:** `record_run.py:256` defaults `--aa` to 1, while `record_run.py:319–320` requires complete engine-order cycles. `benchmarks/campaign.yaml:145–146` opts into v2 without overriding that default; each supplied vendor manifest declares three engines.

Thus an otherwise ordinary invocation without explicit `--aa` exits before building. The smoke commands correctly supplied `--aa 3`.

**Suggested fix:** Use an engine-count-based v2 default, or declare `timing.aa: 3` for this campaign.

**Disposition:** Acceptable for the explicitly parameterized smokes/controls; a CLI usability correction, not a performance-validity finding.

## Delete list

No substantive over-engineering deletion is justified in this slice. Keep the evidence checks and failure-preservation plumbing.

**net: 0 lines identified for safe deletion.**

## Summary

The bounded orchestration path is reviewed, and the supplied smoke manifests consistently name the intended library revisions and paths. The installation/provenance prerequisite and publication error propagation need correction.

Unchecked by design: `timing_evidence.py` internals, report mathematics, numerical/runtime contracts, raw smoke-artifact census, diagnostic analysis, and representative/full performance measurements. The diagnostic driver remains prepared—not validated by execution here. No baseline performance, equality, confidence, or physical-cause claim is established.

**Fix the Critical/Important findings above, then request a fresh review.**