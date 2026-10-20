# Canonical owned-copy diagnostic (1T only)

Hypothesis, not yet an adoption claim: fork MatRef::to_owned routes canonical
non-column-contiguous sources through zeros+16x16 Option-staged tiled copy.
MatRef::cloned uses Mat::from_fn, the same elementwise strategy as upstream's
canonical to_owned. Small row-major public LU/full-piv LU/QR calls all pay the
owned-copy cost. Test that cost directly without changing the numerical API.

Predeclared: shapes32/64/96/128/256/512/1024x64/64x1024, f64/c64, C/F; same
canonical input values; compare current to_owned versus cloned. No2048–4096.
Verify exact equality for every shape/layout/type. Each timed call includes
allocation, copy, black_box and destruction. Prime250ms, median of5, all samples
retained. Four process starts with method orders AB,BA,BA,AB (A=current,B=cloned).
Force faer Par::Seq and a one-worker Rayon pool; print the effective census.
Use existing pinned.sh3s/max5%/8admissions, profile1T CPU set and whole-L3 guard,
observer off measured L3. No concurrent compilation or timing.

Diagnostic boundaries differ from factorization only by measuring the copy
itself. This cannot replace complete-public-call adoption measurements or
justify changing the tiled path without a correctness/large-copy guard.

## Follow-up candidate predeclaration

Candidate `d6358cad06e38850f74aaeb499d5587037b4ffa8` changes ONLY the numeric tile
staging (Option->zero-valued numeric array) and its tests/docs; it keeps the
existing16x16 block, all copy routes and allocation/scheduling boundaries. It is
not the LU-budget candidate. The same Rust probe, fixture, shapes,1T setup,
250ms priming and5 samples run in4 balanced starts into `numeric-tile/`.
Baseline samples stay unchanged. Keep the original baseline binary separately
in `target/probe-owned-copy/baseline/` before compiling the candidate.

For this follow-up the runner preserves command output directly, outside
pinned.sh's discardable temporary stdout, and permits just one EXECUTED attempt
per start. Up to8 admission-only retries are allowed when the pre-check fails;
a post-run rejection retains the CSV/log and stops the phase, never overwrites
or silently repeats it. This corrects the legacy wrapper's artifact-loss risk,
not the numerical clock or acceptance criterion. The previous copy-only phase
had no reported guard rejection. Complete-public-call acceptance still pending.

The follow-up completed4 starts with all64 rows/start and five samples/call,
no reported guard rejection and observed pool1 / Par::Seq. C-order owned-copy
candidate/baseline ratios are0.70–0.79 for f64 and0.76–0.91 for c64 across the
selected grid. The elementwise C-order controls stay within about3%, but an
untouched c64 F512 cloned control moves1.123x; all its samples remain. This is
positive, incomplete diagnostic evidence, NOT full-public-call guard acceptance
or proof that every unchanged operation was unaffected. `comparison.json`
in `numeric-tile/` retains all64 method/cell comparisons.
