# One permitted complete-pair repeat

Initial pair: baseline 2240b07, run `20261018T070736Z-upstream-lu-baseline`;
candidate a537746, run `20261018T073559Z-upstream-lu-restored-budget`.

The official comparator refused: upstream cholesky c64 F128 4T baseline process
medians 0.190235/0.190123/0.189072 ms, candidate 0.177781/0.183040/0.178817 ms.
One of 396 control cells leaves the band; median control ratio is 0.999747.
Also retain the full-pivot LU c64 F512 4T run2 increase in BOTH engines:
candidate fork49.400431 ms, upstream49.375202 ms vs ~28.4 ms in other starts.
These are observed variations, not an established mechanism or grounds for
trimming the start. Do not claim this initial pair passed or adopt from it.

The frozen protocol section5b allows one whole-pair repeat when one control
cell fails but median control ratio stays within2%. Before rerunning, declare:
- Repeat the COMPLETE original grid, numerical verification and row rotations;
  not only the failed or favourable cells. Same clean harness/toolkit, flags,
  source revisions, guard, power settings and CPU sets.
- Reverse revision order: candidate then baseline, yielding B,C,C,B across both
  pairs rather than repeating the original time ordering. Engine rotations
  within each run remain0/1/2, 250ms, median5, aa3, MKL3rows.
- No concurrent builds/timing or measured-source edits. Keep both pairs.
- Compare the repeated pair with the official comparator and retain all results.
  Report both pairs; use the protocol's two-pair median for adoption, with all
  target/guard results shown. A second control failure blocks adoption rather
  than triggering further retries. No thresholds or coverage are relaxed.

## Outcome

**INCONCLUSIVE / NOT ADOPTED.** Repeat candidate
`20261018T081053Z-upstream-lu-restored-budget-repeat`, repeat baseline
`20261018T084143Z-upstream-lu-baseline-repeat`: the official comparator refuses
12/396 unchanged upstream controls; median control ratio0.998988. The two-pair
median target candidate/baseline ratios remain0.740/0.696 for c64 F256 LU/solve
4T and0.698/0.650 at8T. These are diagnostic-only figures, not an acceptance
claim: the failed control gate cannot be waived by consistent target gains.

All four runs contain4428 rows each and retain their manifests, verification,
process samples, guard logs and reports. `pair-1.json` and `pair-2.json` retain
all396 control and396 fork-cell comparisons for each pair, explicitly marked
inconclusive. No third retry, relaxed threshold, trimmed start or replacement
published page. Source candidate remains on a branch; the campaign pin and
main are unchanged. The cause of the control movement is not established as
host variation versus a difference between linked binaries.
