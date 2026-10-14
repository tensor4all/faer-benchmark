# Worklog

Decisions, fixed failures and open items for this campaign. Newest first.

## 2026-10-14 — the first recording is blocked: `householder_apply` at 8T trips a faer assertion

**What was attempted.** The first page for the MKL arm at fork `9de95f7` (which carries
`tensor4all/faer#9`): `gemm-tall,linalg-medium`, `--threads 1,8`, `f64,c64`, five repetitions,
500 ms of priming, upstream at the pinned tag `faer-v0.24.4`. The recorder built the harness,
took the vendor identity, and ran `verify` first — and **published nothing**, which is the
protocol working as designed.

**What stopped it.** `verify` for `linalg-medium` at 8T aborted in the measured library itself:

```
Assertion failed at faer/src/linalg/matmul/triangular.rs:990
Assertion failed: lhs_ncols == rhs_nrows
- lhs_ncols = 64
- rhs_nrows = 32
```

Bisected over families at `--threads 8 --n 256 --dtype f64`: `lu`, `full_piv_lu`, `cholesky`,
`solve`, `triangular_solve`, `qr_factor`, `qr`, `svd_values`, `svd_thin` and `eigh` each pass,
and so does the whole `factor`/`decompose` group together. The trigger is the `householder`
group: `--family upgrade_factor,householder_apply` reproduces it, `upgrade_factor` alone is
recorded as `skipped` (the backend does not implement it), so the case actually measured is
**`householder_apply` at 8 threads**. Every one of these shapes passes at `--threads 1`.

Because the panic aborts the process before stdout is flushed, the per-case verify log for that
population is empty on disk; the assertion is in the guard log, not the report. That is a
harness wart worth fixing later (flush per line), not the cause.

**What is not yet known, and must be settled before the page exists.** Two explanations fit the
evidence and they have different owners:

- *the harness's fixture* — `householder_apply` builds a basis and its compact-WY factor by
  hand, and faer's threaded path is the one that reaches the shape assertion; if the fixture's
  block layout is not the one the threaded kernels require, the fault is `fbench`'s;
- *the library* — the same assertion, at the same line, fails in an existing fork test on the
  parent revision (`sparse::linalg::qr::tests::test_numeric_simplicial_qr_1_transpose`, verified
  failing on a clean checkout of `22f23cf`), so this assertion is reachable from more than one
  entry point and predates `faer#9`, which only removes regions *below* a floor and leaves the
  threaded shapes unchanged.

Until that is decided no page can be recorded for a population containing `householder_apply`,
and the worklog says so rather than publishing a page that hides which families could not be
verified.

**Tracked as [tensor4all/faer#12](https://github.com/tensor4all/faer/issues/12)**, with the bisect, the
reproducer and the two candidate owners above; the campaign consumes that issue rather than
re-deriving the bisect.

**Reproducer.**

```
fbench verify --threads 8 --n 256 --batch 1 --dtype f64 --family upgrade_factor,householder_apply
```

with the binary built by `scripts/build_for_faer_rev.sh --vendor mkl` at the fork revision
above; the same command at `--threads 1` passes.

## 2026-10-14 — `fbench` lands: `info`, `verify`, `run`, with a measured subset

**What is implemented.** The harness crate `fbench` replaces the placeholder
manifest: `Cargo.toml` (two crates-io faer dependencies named `faer_fork =
{ package = "t4a-faer" }` and `faer_upstream = { package = "faer" }`, plus the
`link-openblas`/`link-mkl` vendor features), `build.rs`, and `src/` split into
`main.rs` (CLI, CSV writer), `shared.rs` (scalar trait, layout-aware reference
math), `op.rs` (prepare/run/check closures), `timing.rs` (wall-clock priming,
best of `reps`), `vendor.rs` (the linked vendor's identity and thread budget),
`backend.rs` (a macro expanded once per faer crate so the same family logic runs
against both, whose `Mat`/`Par`/trait types are not interchangeable), and
`lapack.rs` (the hand-written CBLAS/LAPACKE `extern "C"` bindings).

`fbench info` prints `vendor.name`/`vendor.linkage` and, per arm, the fields the
library reports: OpenBLAS gets `version`, `config`, `corename`, `parallel`,
`procs`; MKL gets only `version` (2026.1), because it reports no kernel and no
processor count. `fbench verify` checks each provider against its own contract
with provider-independent reference math (residuals, orthonormality, the
Frobenius norm identity, no NaN), never one provider against another, and ends
with exactly `all comparisons within tolerance`; every failure prints `MISMATCH`
and exits non-zero. `fbench run` writes the nine-declared-column CSV, one row per
`(case, order, arm)`, with `order` measured as an axis and `k` empty for every
non-`gemm` family.

**Families measured.** The faer arms implement `gemm`, `qr_factor`, `qr`, `lu`,
`cholesky`, `solve`, `triangular_solve`, `svd_values`, `svd_thin`, `eigh`,
`full_piv_lu` and `householder_apply`. The vendor arm implements `gemm`,
`qr_factor`, `qr`, `lu`, `cholesky`, `solve`, `svd_values`, `svd_thin` and `eigh`.

**Deliberately not implemented, and recorded as `skipped`.** `upgrade_factor`
(no faer or LAPACK route written yet: a valid blocked-tau layout has to be built
by hand to measure and check it honestly) and `eig` (the non-symmetric solver is
outside this first version). The vendor arm has no route for
`triangular_solve`, `full_piv_lu` or `householder_apply`. A family a provider
cannot take is written with `status=skipped` and a truthful note; a number is
never fabricated for it.

**Two vendor-arm details this host forced.** (1) `mkl_set_num_threads` and
`mkl_set_num_threads_local` segfault in this MKL 2026.1 install before any
computational call — reproduced with a plain C program linked
the same way — so the budget is set through the Intel OpenMP layer MKL is linked
against (`omp_set_num_threads`) and read back with `mkl_get_max_threads`. (2)
`intel-mkl-src` emits `-L`/`-l` but no rpath, and the linker's `--as-needed`
default drops `mkl_intel_thread`, `mkl_core` and `iomp5` (the harness's own
undefined symbols are all in `mkl_intel_lp64`), so `build.rs` records the
versioned directories as rpath and forces the chain back in after
`--no-as-needed`. Without either the recorder could not execute the binary with
no loader path.

**Acceptance, actually run on this host** (fork `22f23cfd4238`, upstream
`ddbd2ae52808`, `AMD Ryzen AI 9 HX 470`, MKL 2026.1):

1. `scripts/build_for_faer_rev.sh --checkout /home/shinaoka/projects/tensor4all/faer
   --upstream /tmp/faer-rs --vendor mkl --out /tmp/fbench-mkl.env --bin fbench` →
   `built fbench for fork 22f23cfd42383fe8d9d2f5816ea49e045f0d0ef5 and upstream
   ddbd2ae5280825fe97f86735618fed2f6f4eb0b3 (dirty=false/false) in
   .../target/faer-rev/22f23cfd4238-mkl/release`.
2. `fbench info` → `vendor.name=mkl`, `vendor.linkage=shared`,
   `vendor.version=2026.1`, `harness.name=fbench`, `host.logical_cpus=24`.
3. `fbench verify --threads 1 --n 128,256 --batch 1 --dtype f64,c64 --family
   gemm,qr_factor,qr,lu,cholesky,svd_values,svd_thin,eigh,householder_apply,upgrade_factor`
   → 241 lines, 32 `skip`, 0 `MISMATCH`, last line exactly
   `all comparisons within tolerance`, exit 0 (4.5 s).
4. `fbench run --threads 1 --n 128 --batch 1 --dtype f64,c64 --family
   gemm,qr_factor,qr,lu,cholesky,svd_values,eigh --regime medium --reps 3
   --prime-ms 200 --csv /tmp/fbench.csv` → header
   `regime,family,dtype,order,m,n,k,batch,row,threads,total_ms,per_item_us,status,note`;
   e.g. `medium,gemm,f64,c,128,128,128,1,faer-fork,1,0.073217,73.217000,ok,`,
   `medium,qr_factor,f64,c,128,128,,1,lapack-mkl,1,0.140044,140.044000,ok,`,
   `medium,eigh,c64,f,128,128,,1,faer-upstream,1,...,ok,`; all seven families
   present; 84 rows, all `ok`.
5. `python3 -c "import csv;r=list(csv.DictReader(open('/tmp/fbench.csv')));print(len(r))"`
   → `84`; the reader reports exactly the 14 declared columns and no non-numeric
   `total_ms` on any non-`skipped` row. A second run with `--family
   lu,upgrade_factor,svd_values` shows the `skipped` path: `upgrade_factor` is
   written for all three arms with `status=skipped` and an empty `total_ms`.
6. `cargo fmt --all -- --check` inside `fbench/` is clean. From the repository
   root, `cargo clippy -p fbench --features fbench/link-mkl --config
   patch.crates-io.t4a-faer.path=... --config patch.crates-io.faer.path=... -- -D
   warnings` is clean for `fbench` (exit 0). The only warnings in the build are
   pre-existing ones in the two measured crates themselves: `unused import:
   crate::prelude::*` in each `src/io.rs`, and the never-read `re`/`im` fields of
   `ComplexDistribution` in each `src/stats/mod.rs` (2 per crate).
7. End-to-end recorder, exactly as written in the task:
   `python3 scripts/record_run.py zen5-cpu faer-kernels --checkout
   /home/shinaoka/projects/tensor4all/faer --upstream /tmp/faer-rs --vendor mkl
   --regimes medium --threads 1 --families gemm,qr_factor --dtypes f64 --reps 3
   --prime-ms 200` **fails before any measurement**, verbatim:

   ```
   FAIL .../data/results/zen5-cpu/faer-kernels/20261014T022823Z/run.yaml
     schema: $.run_spec.populations: [] is too short

   ERROR: run.yaml does not validate; nothing published
   ```

   The cause is the flag, not the harness: the suite's populations are labelled
   `gemm-medium` and `linalg-medium`, so `--regimes medium` selects no
   population and `record_run.py` records an empty `run_spec`. With the labels
   the suite actually declares, the same pipeline completes:
   `--regimes gemm-medium,linalg-medium --families gemm,qr_factor` → `ok
   .../run.yaml` from `validate_run.py`, `wrote .../report.md from 12 rows`,
   `published result/zen5-cpu/faer-kernels/22f23cfd4238-ddbd2ae52808-mkl.md
   (coverage=partial)`, `wrote result/INDEX.md`. That is a `medium`-regime run
   covering `gemm` and `qr_factor` at 1T; it is a scan, not an A/A comparison.
   Its `data/results/` and `result/` artifacts were **not committed**: this
   repository's CI validates every committed `run.yaml` by resolving its library
   commits in `extern/` checkouts, which CI does not clone, so committing a
   manifest measured from `/home/...` and `/tmp/...` would redden the required
   `index` job. The run is reported here and can be re-recorded on the measuring
   host.

**Known gaps.** `upgrade_factor` and `eig`; a vendor route for
`triangular_solve`/`full_piv_lu`/`householder_apply`; `householder_apply` is a
single timed row (the block apply) with the sequence form verified against it,
not a second timed row, because the CSV has no sub-family column and two rows
under one `(family, shape, arm)` key would be merged by the report; `f32`/`c32`
are not accepted; and the harness commit still has no pin of its own, as the
skeleton entry notes. The OpenBLAS arm was **compile-checked, not measured**:
`cargo check -p fbench --features fbench/link-openblas` (with the two `--config
patch...` arguments, `OPENBLAS_DYNAMIC_ARCH=1`) built `openblas-src` from source
and finished in 2 m 46 s with 0 errors, so the feature compiles, but no OpenBLAS
number was taken and no `openblas` run was recorded.

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
