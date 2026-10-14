# Provenance

This repository adopts the conventions, layout and many files of
[`tensor4all/tlinalg-benchmark`](https://github.com/tensor4all/tlinalg-benchmark).
This document records what was copied, from which revision, and the basis for
doing so.

## Authorization

Copied and adapted content in this repository is the work of the same
organization and the same author as the source (`tensor4all`, maintained by
Hiroshi Shinaoka), and is taken from repositories that are `MIT`-licensed:

- `tlinalg-benchmark` carries no `LICENSE` file in its tree, but every script and
  document it holds derives from `tlinalg-rs` and `tprims-rs`, which are
  `MIT` (`tlinalg-rs/LICENSE-MIT`, and the notices in the copies of
  `benchmarks/scripts/*.py`, `MIT, Copyright (c) 2026 Lukas Devos and tensor4all
  contributors`).
- The measured fork, `tensor4all/faer`, is `MIT` (upstream copyright held in
  `faer/LICENSE`), and nothing in this repository redistributes its source.

Copied files keep their in-file attribution. No third-party license is
reinterpreted: the code ported into faer itself from Eigen, LAPACK and SuiteSparse
keeps its own terms (see the fork's `NOTICE`), and none of that code is copied
here.

## Copied from `tlinalg-benchmark` at `2716cd0529058e0080fd6ac5d1472791d653818e`

(`git -C tlinalg-benchmark rev-parse HEAD` on 2026-10-14; `2716cd0` is
"ci: content checks only, on the smallest runner, with auto-merge".)

| file here | source | note |
|---|---|---|
| `benchmarks/profiles.yaml` | same path | `zen5-cpu` verbatim, including the heterogeneous-L3 wording; the "unknown profile = schema error" rule and `schema_version` kept |
| `benchmarks/campaign.yaml` | new | this campaign's descriptor: the measured fork, the upstream baseline, the two vendor arms, the `order` case axis and the page name. It replaced the campaign-specific constants the scripts had carried |
| `scripts/{campaign,record_run,validate_run,gen_index,publish_report,report_run,compare_runs}.py` | same paths | thin shims over `campaign-toolkit`. The logic they carried -- the faer engine names and arm projection, two checkouts and two pins, the `order`/`k` cell identity, the two-revision page identity, the refusal to compare across two baselines -- was contributed to the toolkit and is pinned by revision in `requirements.txt`. The toolkit's own `docs/extraction.md` records what it took from which campaign |
| `scripts/build_for_faer_rev.sh` | `scripts/build_for_tlinalg_rev.sh` | rewritten for a path-linked measured library and two checkouts |
| `requirements.txt` | same path | `campaign-toolkit` pinned by git revision |
| `docs/timing-policy.md` | same path | policy kept; identities and the measured-noise section adapted |
| `README.md`, `AGENTS.md`, `docs/results.md`, `docs/worklog.md` | same paths | structure and rules adopted; content rewritten for three identities |
| `.gitignore`, `.github/workflows/ci.yml` | same paths | adapted paths; the one `index` job kept, no smoke build |

## Copied from `tlinalg-rs` at `c5d1d61f299dc2bd0db128e9defc120832f4be09`

The timing protocol does not live in the campaign repository there; it lives in
the measured library (`tlinalg-rs/benchmarks/scripts/`). This campaign's measured
library, faer, has no `benchmarks/` directory and the fork's `AGENTS.md` forbids
adding one, so the harness repository carries the copy.

| file here | source | note |
|---|---|---|
| `benchmarks/scripts/pinned.sh` | `benchmarks/scripts/pinned.sh` | same policy; the in-file provenance header now names this repository and the copy revision |
| `benchmarks/scripts/idle_cpus.py` | `benchmarks/scripts/idle_cpus.py` | SMT-sibling expansion kept; the in-file provenance header updated |

Both files are themselves adapted from `tensor4all/tprims-rs`
(`MIT, Copyright (c) 2026 Lukas Devos and tensor4all contributors`), which is
where the `pinned.sh`/`idle_cpus.py` pattern originated. That attribution is kept
in the files.

## Deliberate extensions of the copied schemas

Neither extension removes a check; both add a shape the sibling's suites do not have.
They are no longer copies in this repository: the schemas are the toolkit's
(`campaign_toolkit/schemas/`), and the toolkit takes the `identities` a campaign
declares to decide whether a second library revision is allowed rather than required.

- `benchmark-suite.schema.json`, `benchmark-run.schema.json`: the shape pattern is
  widened from `^[0-9]+(x[0-9]+)?$` to `^[0-9]+(x[0-9]+){0,2}$`, so a three-index
  `gemm` shape can be written. Every shape the original pattern accepted is still
  accepted.
- `benchmark-run.schema.json`: `upstream` is allowed as an optional second recorded
  library identity, and a run may record the `order` axis it covered.

## The tooling lives in `campaign-toolkit`

The seven `scripts/*.py` entry points are shims over
[`campaign-toolkit`](https://github.com/tensor4all/campaign-toolkit), which
`requirements.txt` pins by git revision; `benchmarks/campaign.yaml` is this
campaign's descriptor. The `schemas/` copies that used to live here are gone: the
toolkit ships them, and `benchmarks/campaign.yaml` names the profiles, the engine map
and the cell label the toolkit reads. This campaign's additions to the shared tooling
-- a declared `case_axes` axis, a three-index shape, and the second recorded identity
in the report header and the coverage comparison -- are on the toolkit's `main`.

## Determined, not copied

The upstream pin `faer-v0.24.4` was established from the fork itself (tag
ancestry, `faer/Cargo.toml`, `CHANGELOG.md`, `PATCHSET.md`), as recorded in
`pins/upstream-faer.rev`. It is not a version string copied from a source file.
