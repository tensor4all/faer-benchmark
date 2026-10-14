#!/usr/bin/env python3
"""Turn one run's `fbench` CSVs into the tracked report for a (profile, suite) cell.

Only the numbers that came from a verified run are published: every row here was
gated by `fbench verify` (residual, reconstruction, orthonormality and no-NaN
checks, family by family, each provider against its own contract) before the
timing pass started. The report repeats the run's provenance in its own header,
because a table that is copied into a discussion without its fork revision, its
upstream baseline and its harness is the thing this repository exists to stop.

The CSV columns this reads are the harness's contract and are not all produced
by anything else, so they are listed here rather than discovered:

    regime, family, dtype, order, m, n, k, batch, row, threads,
    total_ms, per_item_us, status, note

`order` is `c` or `f` and is part of the cell identity; `k` is the contraction
dimension of a three-index `gemm` shape and is empty for every other family. A
harness that emits a row without one of these fails the report rather than
silently publishing a cell with an unknown order or shape.
"""
import argparse
import csv
import pathlib
import statistics
import sys

from campaign import FAER_ENGINES, ROOT, load

COLUMNS = ["regime", "family", "dtype", "order", "m", "n", "k", "batch", "row", "threads",
           "total_ms", "per_item_us", "status", "note"]


def read_rows(csv_paths):
    """Rows from the run CSVs, tagged with the repeat they came from.

    A repeat is one complete pass over the declared populations; the harness
    already reduced `--reps` timed iterations to a best time, so a repeat holds
    one number per (case, engine row).
    """
    rows = []
    for path in csv_paths:
        repeat = pathlib.Path(path).stem.split("-")[0]  # run0-small-8t -> run0
        with open(path) as handle:
            reader = csv.DictReader(handle)
            for row in reader:
                missing = [c for c in COLUMNS if c not in row]
                if missing:
                    raise SystemExit(f"{path}: missing columns {missing}")
                row["repeat"] = repeat
                rows.append(row)
    return rows


def case_name(row):
    if row["k"]:
        shape = f"{row['m']}x{row['k']}x{row['n']}"
    elif row["m"] == row["n"]:
        shape = f"n{row['n']}"
    else:
        shape = f"{row['m']}x{row['n']}"
    return f"{row['family']}/{shape}/b{row['batch']}"


def best_per_case(rows):
    """(regime, case, dtype, order, threads) -> engine row -> times, from the ok rows only.

    A family whose case the arm cannot take is written by the harness as `skipped` and is not a
    measurement; the run's manifest carries those per population (`run_spec.populations[].skipped`),
    which is what the tables below report, so this does not have to re-derive them.
    """
    best = {}
    for row in rows:
        if row["status"] != "ok":
            continue
        key = (row["regime"], case_name(row), row["dtype"], row["order"], int(row["threads"]))
        best.setdefault(key, {}).setdefault(row["row"], []).append(float(row["total_ms"]))
    return best


def providers_text(manifest):
    """The two faer rows' identities as a report fragment, from the manifest."""
    out = []
    for name in FAER_ENGINES:
        prov = next((p for p in manifest.get("providers", []) if p["name"] == name), None)
        if prov is None:
            continue
        text = f"`{prov['name']}`"
        if prov.get("version"):
            text += f" {prov['version']}"
        if prov.get("commit"):
            text += f" @ `{prov['commit']}`"
        if prov.get("note"):
            text += f" ({prov['note']})"
        out.append(text)
    return out


def provider_text(prov):
    """One provider's identity as a report fragment."""
    text = f"`{prov['name']}`"
    if prov.get("version"):
        text += f" {prov['version']}"
    if prov.get("commit"):
        text += f" @ `{prov['commit']}`"
    if prov.get("note"):
        text += f" ({prov['note']})"
    return text


def render(manifest, suite, rows, run_dir):
    vendor = manifest.get("vendor") or {}
    upstream = manifest.get("upstream") or {}
    library = manifest["library"]
    faer = [p for p in manifest.get("providers", []) if p["name"] in FAER_ENGINES]
    engines = manifest["run_spec"]["engines"]
    # The columns are the engines this run recorded measuring, in the declaration's order: a page
    # prints the arms it has, and a vendor arm has one LAPACK row because one binary links one
    # vendor library.
    row_names = list(engines)
    best = best_per_case(rows)
    out = [
        f"# `{manifest['suite_id']}` on `{manifest['target_profile']}`",
        "",
        f"- t4a-faer (fork, measured) commit: `{library['commit']}`"
        + (" **(dirty)**" if library["dirty"] else ""),
        f"- t4a-faer version: `{library.get('version') or '-'}`",
        f"- upstream faer commit: `{upstream.get('commit', '-')}`"
        + (" **(dirty)**" if upstream.get("dirty") else ""),
        f"- upstream faer ref/version: `{upstream.get('ref') or '-'}` / "
        f"`{upstream.get('version') or '-'}`",
        f"- features: `{', '.join(library['features']) or 'default'}`",
        *(["- faer rows: " + "; ".join(providers_text(manifest))] if faer else []),
        f"- harness commit: `{manifest['harness']['commit']}`",
        f"- hardware profile: `{manifest['target_profile']}`",
        f"- timestamp: `{manifest['timestamp']}`",
        f"- timing policy: v{manifest['timing_policy']['version']}, "
        f"{manifest['timing_policy']['statistic']} of {manifest['timing_policy']['repetitions']} reps, "
        f"priming {manifest['timing_policy']['minimum_untimed_priming_ms']} ms "
        f"(time-based, identical on every row)",
        f"- guards: idle window {manifest['guards']['idle_window_seconds']} s, "
        f"max busy {manifest['guards']['max_busy_percent']}% including SMT siblings, "
        f"{manifest['guards']['attempts']} attempts",
        f"- command: `{manifest['command']}`",
        f"- raw data: `{run_dir.relative_to(ROOT)}/`",
        "",
        "## What was measured",
        "",
        f"- **Workload** — {suite['workloads']['description']}",
        f"  Source: {suite['workloads']['source']}",
    ]
    for spot in suite["workloads"].get("known_blind_spots", []):
        out.append(f"  Known blind spot: {spot}")
    out += ["- **Rows** — one row per engine in every table below:"]
    for engine in row_names:
        doc = suite["engines_doc"].get(engine)
        if doc is None:
            out.append(f"  - `{engine}` — (undocumented in the suite declaration)")
            continue
        out.append(f"  - `{engine}` — {doc['summary']}")
        out.append(f"    Identity: {doc['identity']}")
        if doc.get("caveat"):
            out.append(f"    Caveat: {doc['caveat']}")
        if engine in FAER_ENGINES:
            measured = next((p for p in faer if p["name"] == engine), None)
            if measured:
                out.append("    As measured: " + provider_text(measured))
        if engine == f"lapack-{vendor.get('name')}":
            # From the identity the harness read out of the library it linked, never from the arm
            # that was requested.
            parts = [f"linked {vendor.get('linkage', '?')}", str(vendor.get("name"))]
            if vendor.get("version"):
                parts[-1] += f" {vendor['version']}"
            parts.append(f"kernel dispatched to `{vendor['corename']}`" if vendor.get("corename")
                         else "kernel not reported by the vendor")
            if vendor.get("parallel"):
                parts.append(f"{vendor['parallel']} threading")
            if vendor.get("config"):
                parts.append(f"config `{vendor['config']}`")
            out.append("    As measured: " + "; ".join(parts))
    out += [
        "",
        "## Hardware",
        "",
        f"- CPU: `{manifest['host']['cpu']}`",
        f"- logical CPUs: `{manifest['host']['logical_cpus']}`",
        f"- L3: `{manifest['host']['l3']}`",
        f"- L3 domains: `{manifest['host'].get('l3_domains') or manifest['host']['l3']}`",
        f"- OS / arch: `{manifest['host']['os']}` / `{manifest['host']['arch']}`",
        f"- hostname: `{manifest['host']['hostname']}`",
        "- CPU sets: " + ", ".join(f"{t}T -> `{c}`"
                                   for t, c in sorted(manifest["threads"]["cpu_sets"].items(),
                                                      key=lambda kv: int(kv[0]))),
        "",
        "Every row below passed `fbench verify` on the same grid before timing: each provider's",
        "factorizations are checked against that provider's documented convention",
        "(residual, reconstruction, orthonormality, no NaN), never against another provider's",
        "floating-point output. Times are milliseconds, the best wall time per case and engine",
        "row; with more than one complete set repeat the table shows the best repeat, and the",
        "A/A spread is reported at its foot. C and F order are separate cells, because the order",
        "decides which path each provider takes.",
        "",
    ]
    for population in manifest["run_spec"]["populations"]:
        regime = population["regime"]
        # A regime can carry more than one population (the `gemm` shape grid cannot share a
        # population with the linalg grid), and both are labelled with the same regime in the CSV,
        # so the cases are narrowed to this population's families rather than the whole regime.
        families = set(population["families"])
        for dtype in manifest["run_spec"]["dtypes"]:
            for order in manifest["run_spec"].get("order", []):
                for threads in manifest["threads"]["counts"]:
                    cases = sorted({k[1] for k in best if k[0] == regime and k[2] == dtype
                                    and k[3] == order and k[4] == threads
                                    and k[1].split("/")[0] in families})
                    if not cases:
                        continue
                    out.append(f"## {regime}, {dtype}, {order} order, {threads}T "
                               f"(CPU {manifest['threads']['cpu_sets'].get(str(threads), '?')})")
                    out.append("")
                    out.append("| case | " + " | ".join(f"{e} (ms)" for e in row_names) + " |")
                    out.append("|" + "---|" * (len(row_names) + 1))
                    for case in cases:
                        cells = []
                        for engine in row_names:
                            times = best.get((regime, case, dtype, order, threads), {}).get(engine, [])
                            cells.append(f"{min(times):.4f}" if times else "-")
                        out.append(f"| `{case}` | " + " | ".join(cells) + " |")
                    out.append("")
        if population.get("skipped"):
            out.append(f"Not applicable to this population's shapes and reported as skipped: "
                       f"{', '.join('`' + c + '`' for c in population['skipped'])}.")
            out.append("")
    if manifest["run_spec"]["aa"] > 1:
        spreads = []
        for key, per_row in best.items():
            for engine, times in per_row.items():
                if len(times) > 1 and min(times) > 0:
                    spreads.append(max(times) / min(times))
        if spreads:
            out.append(f"A/A across {manifest['run_spec']['aa']} complete set repeats: "
                       f"median max/min {statistics.median(spreads):.3f}, "
                       f"worst {max(spreads):.3f}. A comparison is made from paired repeats, "
                       f"not from one table read twice.")
            out.append("")
    else:
        out.append("This run made a single complete set, so it carries no A/A: it is a scan, "
                   "not a paired comparison.")
        out.append("")
    return "\n".join(out).rstrip("\n") + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run-dir", required=True)
    args = ap.parse_args()
    run_dir = pathlib.Path(args.run_dir).resolve()
    manifest = load(run_dir / "run.yaml")
    suite = load(ROOT / "benchmarks/suites" / f"{manifest['suite_id']}.yaml")
    # Exactly the files the manifest names, not every CSV that happens to be in the directory:
    # the manifest is what the validator checked, and a report built from anything else would
    # publish numbers nothing gated.
    listed = manifest.get("result_files") or []
    if not listed:
        raise SystemExit(f"{run_dir}/run.yaml names no result files")
    missing = [f for f in listed if not (run_dir / f).exists()]
    if missing:
        raise SystemExit(f"{run_dir}: result files named by the manifest are absent: {missing}")
    rows = read_rows([run_dir / f for f in listed])
    (run_dir / "report.md").write_text(render(manifest, suite, rows, run_dir))
    print(f"wrote {run_dir}/report.md from {len(rows)} rows")
    return 0


if __name__ == "__main__":
    sys.exit(main())
