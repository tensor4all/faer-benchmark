# Worklog

Decisions, fixed failures and open items for this campaign. Newest first.

## 2026-10-14 — the repository is created, skeleton only, no run recorded yet

**Scope.** A campaign for the tensor4all faer fork at faer's own API, on the model
of `tlinalg-benchmark` and `tcontract-benchmark`: the declarations, the two
revision pins, the run manifests, the published reports and a generated staleness
index. This entry records what was adopted, what is deliberately empty, and what
the harness still has to provide. **No number exists yet**: `result/INDEX.md`
lists empty cells, `data/results/` holds no run, and nothing here should be
quoted as a measurement.

**Why a third campaign.** The fork is measured one layer up today:
`tlinalg-benchmark` measures faer through tlinalg's batched wrapper, so its
numbers carry tlinalg's packing, batch loop and lane policy on top of the faer
call. The fork's five KEEP rows in `PATCHSET.md` land at faer's own API, and the
one open `tlinalg-rs#46` item (the tall compact-WY trailing update reaching
3.5-3.9x on eight cores where OpenBLAS reaches 5.5x, a kernel ceiling rather than
a decomposition one) needs a faer-level harness to iterate on. Upstream's own
bench page has vendor arms; what it lacks is campaign discipline.

**Adopted rather than reinvented.** The layout, the schemas, the index/coverage
model and the timing policy come from `tlinalg-benchmark` at `2716cd0` (see
`docs/provenance.md` for the exact files and terms). The timing protocol
`benchmarks/scripts/{pinned.sh,idle_cpus.py}` is the copy from `tlinalg-rs` at
`c5d1d61f`, which expands the idle gate to the SMT siblings of the measured cores.

**The harness lives here, and is not written.** `fbench` is a crate in this
repository, linked to the measured fork and to upstream by path, with a CLI
(`info`, `verify`, `run`) matching `tlbench`'s. The fork's `AGENTS.md` forbids
adding a `benchmarks/` directory to the fork, so the harness owns the timing
protocol as well. `fbench/Cargo.toml` is a placeholder with no `src/`; the build
script, the recorder and the report describe the contract it has to satisfy, and
they fail rather than guess when a field is absent. **No run can be recorded until
that crate exists** — this is stated rather than stubbed.

**Three recorded identities, two pins.** A result depends on the measured fork
(`library`), the upstream release it is compared against (`upstream`), and the
harness (`harness`). The first two are pinned and drive `result/INDEX.md`'s
currency; the harness commit is recorded per run and repeated in every page
header, and it has no pin, so a harness change does not by itself move a cell's
`status`. That is a known gap, written down in `docs/results.md` rather than
implied away. The page identity is
`<t4a-faer12>-<upstream-faer12>[-<vendor>]`.

- `pins/t4a-faer.rev` is the fork revision at repository creation,
  `22f23cfd42383fe8d9d2f5816ea49e045f0d0ef5`.
- `pins/upstream-faer.rev` is `faer-v0.24.4`, determined from the fork (the tag
  is an ancestor of the fork revision and `faer-v0.24.5` is not; the fork's
  `faer/Cargo.toml` is 0.24.4 and `PATCHSET.md` records the published 0.24.4
  release), not assumed from a version string. Pin files therefore allow `#`
  comments, and `gen_index.py` ignores them.

**The declaration.** `benchmarks/suites/faer-kernels.yaml` names the actual faer
entry point each family is, not a family label, and declares ten populations over
the issue's five shape classes (small, medium, large, tall, wide), rather than one
Cartesian product. `gemm` and the linalg families cannot share a population,
because a gemm shape is a triple (`MxKxN`) and a linalg shape is not, so the
regime label carries the family class too (`gemm-small`, `linalg-small`, ...) and
is the population's identity. That is not cosmetic: the harness's raw-data names,
its skip keys and the report's tables are keyed by the regime, and CI asserts the
labels are unique so two populations cannot overwrite each other's CSVs.

**Two deliberate schema extensions.** The suite schema is the sibling's plus two
declared axes this suite needs: `runs[].order` (C/F is part of the cell identity
here, because faer's gemm and Householder paths dispatch differently on layout and
the fork's row-split gates were chosen on F-order shapes), and a shape grammar
that permits `MxKxN` for `gemm` (the tall class's two Householder legs are
`16x4096x240` and `4096x16x240`, which two indices cannot express). The extension
is backwards compatible: every shape the sibling's grammar accepted is still
accepted. The run schema is the sibling's plus the required `upstream` identity
and the `order` axis recorded in `run_spec`.

**`required_profiles` is empty, deliberately.** `missing` is a normal cell state,
and it becomes an error only for a profile a suite lists as required, so
`zen5-cpu` is `optional_profiles` until the first recorded `(zen5-cpu,
faer-kernels)` cell exists — the same sequence `tlinalg-benchmark` followed.
`gen_index.py --check` therefore passes with nothing recorded, and its currency
check reports an absent checkout as a problem only when there is a page whose
currency it would decide.

**CI is content only.** One job, `index`, on the smallest runner: the declarations
against their schemas, every `data/results/*/*/*/run.yaml` against
`validate_run.py` (none yet, so the step passes saying so), and
`gen_index.py --check`. The harness build is not gated here: a run is only
recorded when that same revision already built, verified and timed on the host
that owns the numbers, so a smoke build would be post hoc — the same call
`tlinalg-benchmark` made in its `2026-10-13 (later still)` entry. No measured
checkout is cloned either: `fbench` links both libraries by path, and the index
reports an absent `extern/` checkout only when there is a recorded page whose
currency it would decide, so a repository with no evidence is not failed for the
absence of the trees that would date it.

**Not yet done.**

- The harness crate itself (`fbench`), and therefore every run and every page.
- The direct-faer pooled spread has not been measured; until an A/A pair exists
  here, a table from this campaign is a scan, not a claim.
- The resolved dependency lock (the harness's locked faer revisions and their
  transitive features) is **not** recorded yet. Both faer revisions and the
  harness's feature set are; a lock hash is the remaining piece the issue's page
  identity calls for, and it needs a field the run schema does not have.
- The `1024` shapes, `f32`/`c32`, BLIS, sparse, iterative and GPU arms are later
  declarations, not machinery built now.
