# `faer-benchmark`

The benchmark campaign for the tensor4all [faer](https://github.com/tensor4all/faer)
fork: results keyed by **library commit × hardware profile**, measured at faer's
own API, with the staleness of every cell visible rather than implied. It is the
same shape as [`tlinalg-benchmark`](https://github.com/tensor4all/tlinalg-benchmark)
and [`tcontract-benchmark`](https://github.com/tensor4all/tcontract-benchmark),
which own the same job one layer up.

| | |
|---|---|
| Latest results | [`result/INDEX.md`](result/INDEX.md) — generated table of contents over the per-revision pages |
| Result layout | [`docs/results.md`](docs/results.md) |
| Timing policy | [`docs/timing-policy.md`](docs/timing-policy.md) |
| Reference revisions | [`pins/t4a-faer.rev`](pins/t4a-faer.rev) (the fork) and [`pins/upstream-faer.rev`](pins/upstream-faer.rev) (the baseline) — what `status` is measured against |
| Design record | [`docs/worklog.md`](docs/worklog.md) — decisions, fixed failures, open items |
| Provenance | [`docs/provenance.md`](docs/provenance.md) — what was copied from which sibling and under what terms |

## Status: skeleton

The declarations, schemas, scripts, pins and CI are in place. The harness crate
`fbench` is **not written here** — [`fbench/Cargo.toml`](fbench/Cargo.toml) is a
placeholder with no `src/`, so no run has been recorded and `result/INDEX.md`
lists empty cells. `scripts/record_run.py` and `scripts/build_for_faer_rev.sh`
describe the build, verify and timing contract that harness has to satisfy; they
cannot run until the crate exists.

## How it works

The harness lives **here**, not in the fork: faer has no `benchmarks/` directory
and the fork's `AGENTS.md` forbids adding one, because campaign infrastructure
would be a rebase cost. So `fbench` links the measured library *by path* from a
checkout, and it owns the timing protocol
(`benchmarks/scripts/{pinned.sh,idle_cpus.py}`) as well.

A result therefore depends on **three** independently moving revisions, and all
three are recorded in `run.yaml`:

| identity | what it is | pinned by |
|---|---|---|
| `library` | the measured fork checkout (`t4a-faer`, lib name `faer`) | `pins/t4a-faer.rev` |
| `upstream` | the upstream `faer` release the fork is based on | `pins/upstream-faer.rev` |
| `harness` | this repository, whose commit and dirty state can move a number | per run (`harness.commit`) |

```bash
# one vendor arm, build + verify + measure + validate + publish + reindex.
# One binary links one vendor library, so an arm is a run of its own.
python3 scripts/record_run.py zen5-cpu faer-kernels --vendor openblas \
    --checkout /path/to/t4a-faer --upstream /path/to/upstream-faer
python3 scripts/record_run.py zen5-cpu faer-kernels --vendor mkl \
    --checkout /path/to/t4a-faer --upstream /path/to/upstream-faer
```

Four arms are compared at faer's own API: the fork (`faer-fork`), upstream
(`faer-upstream`), CBLAS + LAPACK against OpenBLAS, and the same calls against
Intel oneAPI MKL. The two faer rows share one binary — the fork is package
`t4a-faer` and upstream is package `faer`, so they are distinct dependency keys
and distinct crate identities even though both declare `[lib] name = "faer"`. The
two vendor arms cannot share a process (they own the same symbols), so a vendor
arm is its own build, its own run and its own page.

## Tooling

The seven `scripts/*.py` entry points are thin shims over
[`campaign-toolkit`](https://github.com/tensor4all/campaign-toolkit), the shared
package the campaigns now have in common. `requirements.txt` pins it by git
revision; `benchmarks/campaign.yaml` is this campaign's descriptor, naming the
measured fork, the upstream baseline, the two vendor arms, the `order` case axis
and every other value the toolkit needs. The `schemas/` copies are gone: the
toolkit supplies them.

`scripts/setup_extern_deps.sh` materialises `extern/t4a-faer` and
`extern/upstream-faer` from the pins, which is what `gen_index.py --check` needs to
say whether a recorded page is current.

For local development, install the toolkit from a checkout instead of from git:

```bash
pip install -e ../campaign-toolkit
```

## What this repository is not

It is not the fork's per-PR gate; the fork's CI is a build, and this repository
owns the campaign. It is not tlinalg or tenferro marshalling, batch loops, lane
policy, tensor construction or dtype dispatch — those are `tlinalg-benchmark`'s
and `tenferro-benchmark`'s rows. It is not upstream's website bench page: no
nalgebra/eigen arms, no `fx128`. No API change to faer follows from it.
