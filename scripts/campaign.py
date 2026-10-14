#!/usr/bin/env python3
"""Shared reading of the campaign's declarations.

`record_run.py`, `validate_run.py` and `report_run.py` all have to agree on what
a suite declares and on which provider an engine name belongs to. That
agreement is exactly what a schema cannot express, so it lives here rather than
being restated in each script, where the copies would drift.
"""
from __future__ import annotations

import pathlib

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent

# What provides each engine name the harness emits. An arm whose provider cannot
# be identified refuses the run: a page that says "LAPACK (unknown vendor)" is
# exactly the opacity the result pages exist to remove.
#
# Two faer rows are measured in one binary -- the fork and upstream are distinct
# dependency keys, and therefore distinct engines -- so their providers are the
# fork and upstream themselves. A vendor-backed engine names its vendor twice:
# once as the provider, and once in the engine string itself
# (`lapack-openblas`), because the harness derives that string from the vendor
# library it linked. The two are checked against each other rather than trusted
# separately, so a page cannot label a row with a vendor the binary did not link.
PROVIDER_OF_ENGINE = {
    "faer-fork": "faer-fork",
    "faer-upstream": "faer-upstream",
    "lapack-openblas": "openblas",
    "lapack-mkl": "mkl",
}

# The providers that own the BLAS/LAPACK symbols. They are mutually exclusive in
# one process, so they are the axis a run -- and a page -- is split on.
VENDOR_PROVIDERS = ("openblas", "mkl")

# The two faer rows every arm carries. They are the measured library and its
# baseline, not a vendor, so they appear in every vendor arm's run.
FAER_ENGINES = ("faer-fork", "faer-upstream")


def load(path) -> dict:
    return yaml.safe_load(pathlib.Path(path).read_text())


def find_suite(suite_id: str):
    """The declaration file and body whose `id` is `suite_id`."""
    for f in sorted((ROOT / "benchmarks/suites").glob("*.yaml")):
        data = load(f)
        if data["id"] == suite_id:
            return f, data
    return None, None


def run_spec(suite: dict) -> dict:
    """The suite's declared measurements. One spec per suite, as the model says."""
    return suite["runs"][0]


def populations(suite: dict) -> list[dict]:
    """The declared populations with their family groups expanded.

    The expansion is the definition of what the suite covers, so every script
    expands it the same way instead of trusting a manifest's own account.
    """
    groups = suite["family_groups"]
    out = []
    for spec in run_spec(suite)["populations"]:
        families = [f for group in spec["groups"] for f in groups[group]]
        out.append({"regime": spec["regime"], "families": families,
                    "n": [str(n) for n in spec["n"]], "batch": [int(b) for b in spec["batch"]]})
    return out


def same_populations(covered: list[dict], declared: list[dict]) -> bool:
    def key(p):
        return (p["regime"], tuple(p["families"]), tuple(p["n"]), tuple(p["batch"]))
    return sorted(key(p) for p in covered) == sorted(key(p) for p in declared)


def vendor_engines(engines) -> list[str]:
    """The vendor libraries a declared engine list measures against, in order.

    One binary links one vendor library, so this is a list only to catch the case
    a declaration asks for two: a run cannot carry more than one of them.
    """
    out = []
    for engine in engines:
        provider = PROVIDER_OF_ENGINE.get(engine)
        if provider in VENDOR_PROVIDERS and provider not in out:
            out.append(provider)
    return out


def vendor_of_engines(engines) -> str | None:
    """The one vendor a run measures against, or None when it declares none."""
    vendors = vendor_engines(engines)
    return vendors[0] if len(vendors) == 1 else None


def engines_for_vendor(suite: dict, vendor: str) -> list[str]:
    """The engines one vendor arm of this suite is expected to measure.

    A binary links one vendor library, so an arm cannot measure another vendor's
    rows. A vendor cell is therefore the two faer rows the declaration names plus
    that vendor's own LAPACK row, and `covers_declared_suite` is measured against
    this projection rather than against the whole declaration -- otherwise no
    single-vendor run could ever cover the suite, and every cell would be partial
    for ever. The recorder and the validator both call this, so the two cannot
    disagree about what coverage means.
    """
    out = []
    for engine in run_spec(suite)["engines"]:
        provider = PROVIDER_OF_ENGINE.get(engine)
        if provider not in VENDOR_PROVIDERS or provider == vendor:
            out.append(engine)
    return out


def declared_for(suite: dict, regime: str) -> list[dict]:
    """Every population the suite declares under one regime.

    A regime may be declared more than once, because a population carries one shape grid for a
    set of families and the `gemm` shapes are triples that cannot share a grid with the linalg
    shapes. So "which declaration does this population belong to" is a list, not one entry.
    """
    return [p for p in populations(suite) if p["regime"] == regime]


def population_covers(covered: dict, declared: list[dict]) -> bool:
    """True when a covered population is a subset of what is declared for its regime.

    The comparison is against the union of everything declared for that regime, because a regime
    can carry more than one population. `same_populations` remains the exact check that decides
    full coverage; this only decides whether a covered grid is *part of* the declaration.
    """
    candidates = [p for p in declared if p["regime"] == covered.get("regime")]
    if not candidates:
        return False
    return (set(covered.get("families", [])) <= {f for p in candidates for f in p["families"]}
            and set(covered.get("n", [])) <= {n for p in candidates for n in p["n"]}
            and set(covered.get("batch", [])) <= {b for p in candidates for b in p["batch"]})


def coverage_of(suite: dict, manifest: dict) -> str:
    """How a run relates to the *current* declaration, by content rather than by hash.

    `full` when the run covered the whole declared grid for its vendor arm, `partial`
    when it covered a subset of it, and `declaration-changed` when what it covered is
    not a subset of what is declared today, so the two have to be compared by hand.
    The grid is what a reader needs to know about; a hash would have called an edited
    sentence a moved declaration. The publish rule and the index both call this, so
    they cannot disagree about which pages are full.
    """
    spec = run_spec(suite)
    rs = manifest.get("run_spec", {})
    arm = vendor_of_engines(rs.get("engines", []))
    want = populations(suite)
    got = rs.get("populations", [])
    if not got:
        return "declaration-changed"
    subset = all(population_covers(p, want) for p in got)
    declared_engines = set(engines_for_vendor(suite, arm))
    if not (subset
            and set(manifest["threads"]["counts"]) <= set(spec["threads"])
            and set(rs.get("dtypes", [])) <= set(spec["dtypes"])
            and set(rs.get("order", [])) <= set(spec["order"])
            and set(rs.get("engines", [])) <= declared_engines):
        return "declaration-changed"
    full = (same_populations(got, populations(suite))
            and manifest["threads"]["counts"] == spec["threads"]
            and rs.get("dtypes") == spec["dtypes"]
            and rs.get("order") == spec["order"]
            and rs.get("engines") == engines_for_vendor(suite, arm))
    return "full" if full else "partial"


def page_relative(profile: str, suite_id: str, manifest: dict) -> str:
    """The published page for a run, relative to the repository root.

    One page per measured comparison, named after the two library revisions so
    that measuring a new commit -- of either library -- adds a page instead of
    replacing the previous one. A result depends on three independently moving
    revisions (fork, upstream, harness) and the page name carries the two that
    name a *comparison*: `<t4a-faer12>-<upstream-faer12>[-<vendor>]`. The harness
    revision is recorded in `run.yaml` and repeated in the page header, because a
    page is only attributable to one harness; it is not in the name because the
    harness does not change what is being compared.

    The vendor is part of the name because it is part of the measurement: one
    binary links one vendor library, so an arm is its own run, and two arms at
    one revision are two pages a reader compares.
    """
    library = manifest["library"]
    upstream = manifest["upstream"]
    suffix = "-dirty" if library["dirty"] or upstream["dirty"] else ""
    vendor = (manifest.get("vendor") or {}).get("name")
    arm = f"-{vendor}" if vendor else ""
    return (f"result/{profile}/{suite_id}/"
            f"{library['commit'][:12]}-{upstream['commit'][:12]}{arm}{suffix}.md")


def page_source(page):
    """The run directory a page was generated from, read out of the page itself, or None.

    Publication refuses a partial run over a full-coverage page, so the newest manifest
    that would have written a path is not the same thing as the run whose numbers the page
    holds. The page names the report it was copied from; nothing has to guess.
    """
    import re
    with open(page) as handle:
        first = handle.readline()
    found = re.match(r"<!-- generated from (\S+)/report\.md by ", first)
    return ROOT / found.group(1) if found else None
