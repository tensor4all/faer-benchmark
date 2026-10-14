# Timing policy, version 1

Recorded in every `run.yaml` as `timing_policy`. A run carries the version in
force when it was taken; do not compare ratios across versions, and do not use an
earlier version's numbers to assess a later library revision.

## What is timed

Steady-state kernel execution. Inputs, layouts, output buffers and the recycling
vendor workspace are prepared before the clock starts. The clock stops after the
provider call returns, with outputs still alive. Restoring a mutated input
between iterations happens **outside** the clock: this is the boundary the
campaign declares, and it is deliberately not the boundary of upstream faer's own
bench page (`faer/examples/bench.rs` + `bench.toml`), which restores inputs
inside the clock, nor of tlinalg's Criterion rows. Compare across any of them only
after accounting for that.

**Allocation performed inside the measured call stays inside the clock.** The
fork's two row splits allocate their partial buffers inside the public call, and
the public scratch function does not expose them. The campaign reports that as it
is instead of changing faer's API to make the boundary look cleaner.

Tensor construction, dtype dispatch, tlinalg batching/packing and tenferro
session entry are other repositories' work and are not in any number here.

## Priming

At least 0.5 s of untimed, time-based priming per row, and the same amount of
time on every row. A fixed call count is not equivalent: after an idle gate this
host reads low for the first second or two of sustained work, which is easily
mistaken for a kernel defect. The sibling harness in `tlinalg-rs` records
`minimum_untimed_priming_ms: 500` while `tprims-rs`'s timer performed a single
warm-up call; `fbench` measures the priming time instead, and the recorder records
the value it was asked for.

## Thread budget

`--threads N` is required for a campaign row and is enforced at both levels: a
host-owned Rayon pool of `N` workers for the two faer rows (the faer row executes
inside it, because `Par::rayon(n)` is a count hint and does not create the pool,
so the effective worker count is recorded), and the vendor library's own thread
count for the LAPACK row, set with `openblas_set_num_threads` and read back with
`openblas_get_num_threads` before each measurement. A mismatch is an error, not a
warning, because a row labelled `1T` whose vendor library ran on 24 threads is a
lie with a number attached. The ambient `OPENBLAS_NUM_THREADS`, `OMP_NUM_THREADS`,
`RAYON_NUM_THREADS`, the MKL budget/domain and interface/threading-layer variables
and the OpenMP limit/placement variables are removed from the measured process,
and their absence is recorded. The harness pins MKL's LP64 interface and its
threading layer before the first MKL call, because MKL otherwise lets the
environment choose them and the interface layer is an ABI.

## Statistic and repetitions

`best` wall time per engine row and case, over 5 timed repetitions, with the
complete set repeated for A/A when a comparison is being made. The harness
reports the best time per row; the report aggregates repeats and prints the A/A
spread. A single scan flags suspects; only a complete paired run makes a
performance claim.

**The noise floor is measured here, not inherited.** The sibling's measured floor
includes tlinalg's lane policy, which this campaign removes, so the direct-faer
pooled spread is a property of this harness and this host and is measured here
before any pooled number is quoted as a value. The sibling's own result stands
for its rows only: a per-cell claim there is made on the 1T rows (a complete set
reproduces to about 3%), the pooled 8T rows move by up to 2.5x between complete
sets of identical code, and the vendor's threaded rows sit in between. Until this
campaign has its own A/A pair, a table here is a scan. 8T kernel-scaling claims
are made from complete-set A/A pairs, not excluded by a 1T-only rule, because the
fork's row splits are exactly a threaded-kernel change.

## Guarding the host

Every measurement runs through `benchmarks/scripts/pinned.sh` in this repository
(the harness owns the protocol, because faer has no `benchmarks/` directory and
the fork's `AGENTS.md` forbids adding one): `taskset` to the declared CPU set, a
3-second `/proc/stat` idle window covering those CPUs **and their SMT siblings**,
at most 5% busy before and after, 3 attempts. A spoiled run is discarded, not
published. The recorder holds one campaign-level lock across build, verify and
timing, so no second recorder builds another revision while a measurement runs;
unrelated workloads remain an operator precondition.

## What a report may and may not claim

A report states the fork revision, the upstream revision, the harness, the host,
the vendor and its kernel, the coverage and the guards, and it is a claim about
*that* cell. It is not evidence about a population the run did not contain: a grid
whose large regime has unit batch extent says nothing about per-batch-element
cost at that size, and the index's `coverage` column plus
`run_spec.populations[].skipped` are the mechanisms that keep that visible. C and
F order are separate cells, and a C-order cell may not be read as the F-order one.
