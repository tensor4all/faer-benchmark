# Preserve idle-guard-rejected samples (small corrective design)

Problem: benchmarks/scripts/pinned.sh deletes its temporary stdout on exit and
reexecutes a command after a failed post-run check. fbench --csv overwrites the
same CSV on retry; campaign_toolkit.record_run invokes this wrapper directly.
Thus a guard rejection is reported but its samples can be lost. The fixed-binary
ABBA diagnostic lost exactly one initial4T CSV this way; no1T loss was reported.
Do not pretend those historical samples can be recovered.

Correction implemented; bounded PRE and POST reviews completed on gpt-6.1-sol.
Findings, resolutions and verification: `20261018-rejected-attempt-retention-review.md`.

Correction:
- Keep pinning, topology expansion, idle durations/thresholds, retries, waits,
  command arguments and timing loops unchanged. No schema/criterion relaxation.
- On a failed POST check only, archive temporary command stdout, the caller-
  declared CSV (if present), and the full failed idle check log.
  The recorder explicitly supplies `PINNED_CSV` for its effective CSV path;
  the generic wrapper does NOT parse arbitrary program arguments. This resolves
  the PRE-review's repeated/ambiguous-option finding without a generic parser.
  Use a unique sibling directory of that CSV, or a unique /tmp directory for
  stdout-only commands. Report the archive path in stderr/guard log.
- Preserve failing pre-check diagnostics in stderr too. Capture check output
  rather than silently redirecting its detailed CPU/cache-peer fractions away.
- Do not overwrite a prior archive. If archival fails, abort instead of retrying
  and leave still-existing temp output available with its path reported.
- Valid command stdout/CSV and successful numerical timing boundaries stay
  identical. Archive I/O occurs only AFTER a check has already rejected a run.
- Existing record_run manifests keep their canonical result_files; nested rejected
  archives are evidence, never inputs to medians/reporting. Verify these callers.
- Add one stdlib test with fake idle/command programs: first executed sample fails
  its post-check, second succeeds; original samples/guard evidence must survive
  and final stdout/CSV must be from the accepted attempt. Also test no-CSV stdout
  and archive/command-failure behavior without sleeping or actual CPU timing.

This fixes an observed data-retention defect; it is not a new provider, policy
framework, accepted-run timing contract or authority to retry without bounds.
