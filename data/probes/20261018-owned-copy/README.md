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
