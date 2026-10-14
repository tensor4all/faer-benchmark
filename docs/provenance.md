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
| `schemas/benchmark-suite.schema.json` | same path | copied, then extended (see below) |
| `schemas/benchmark-run.schema.json` | same path | copied, then extended (see below) |
| `scripts/campaign.py` | same path | provider map and arm projection adapted to the faer engine names; page identity now carries two revisions |
| `scripts/record_run.py` | same path | binary `fbench`, two checkouts, two pins, protocol scripts from this repository |
| `scripts/validate_run.py` | same path | resolves both recorded commits, validates the `order` axis |
| `scripts/gen_index.py` | same path | two reference revisions and two checkouts; currency is the worse of the two |
| `scripts/publish_report.py` | same path | copied unchanged (it reads `campaign.py`) |
| `scripts/report_run.py` | same path | fork/upstream/harness header, `order` and `k` in the cell identity |
| `scripts/compare_runs.py` | same path | refuses a comparison across two upstream baselines or two harnesses |
| `scripts/build_for_faer_rev.sh` | `scripts/build_for_tlinalg_rev.sh` | rewritten for a path-linked measured library and two checkouts |
| `requirements.txt` | same path | `jsonschema>=4`, `pyyaml>=6` |
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

Neither extension removes a check; both add a declared axis the sibling's suites
do not have.

- `benchmark-suite.schema.json`: `runs[].order` is required, and the shape
  pattern is widened from `^[0-9]+(x[0-9]+)?$` to `^[0-9]+(x[0-9]+){0,2}$` so a
  three-index `gemm` shape can be written. Every shape the original pattern
  accepted is still accepted.
- `benchmark-run.schema.json`: `upstream` is required (the second recorded
  library identity), and `run_spec.order` is required and validated. Every
  existing required field is kept.

## Determined, not copied

The upstream pin `faer-v0.24.4` was established from the fork itself (tag
ancestry, `faer/Cargo.toml`, `CHANGELOG.md`, `PATCHSET.md`), as recorded in
`pins/upstream-faer.rev`. It is not a version string copied from a source file.
