#!/usr/bin/env python3
"""Record one (profile, suite) run: build at a revision, verify, measure, publish.

Order matters and is enforced here:

1. one campaign-level admission lock is taken first and held across build,
   verify and timing. The campaign is one measurement at a time and no build
   while a measurement runs; a lock inside a per-revision target directory
   would let a second recorder build another revision during this one;
2. the harness (`fbench`, in *this* repository) is built with the measured fork
   faer and the upstream faer both linked *by path* from their checkouts, into a
   target directory keyed by the fork revision and the vendor arm;
3. `fbench verify` runs over every population and thread budget before any
   timing, and a mismatch aborts the run (nothing is published from an
   unverified run);
4. each measurement goes through this repository's pinned, idle-checked protocol
   script (`benchmarks/scripts/pinned.sh`): faer has no `benchmarks/` directory
   of its own and the fork's AGENTS.md forbids adding one, so the harness owns
   the protocol as well;
5. the manifest is validated against its schema *before* it is written, and both
   recorded library commits (fork and upstream) must resolve in a checkout.

Fields this recorder needs from the harness, because nothing else can produce
them, and the checks that stand on them:

- `fbench info` must print one `key=value` per line, and at least
  `vendor.name`, `vendor.linkage` (and, for the vendor arm, `vendor.version`,
  `vendor.config`, `vendor.corename`, `vendor.parallel`, `vendor.procs` when the
  vendor reports them). `vendor.name` must equal the `--vendor` arm that was
  built; a page may not name a vendor the binary did not link.
- `fbench run --csv` must write the columns the report reads: `regime`, `family`,
  `dtype`, `order`, `m`, `n`, `k` (empty for a non-`gemm` family), `batch`,
  `row`, `threads`, `total_ms`, `per_item_us`, `status`, `note`. A family whose
  declared shape the arm cannot take must be written with `status=skipped`
  rather than omitted.

`library` is the measured fork; `upstream` is the baseline it is compared with;
`harness` is this repository. All three are recorded because changing any one of
them can move a number.
"""
import argparse
import csv
import datetime
import fcntl
import hashlib
import os
import pathlib
import platform
import shlex
import subprocess
import sys

import yaml

from campaign import (FAER_ENGINES, PROVIDER_OF_ENGINE, ROOT, engines_for_vendor, populations,
                       same_populations, vendor_engines)

# One binary links one vendor library, so a run measures one arm, and the arm decides the
# features. `BENCH_FEATURES` must not be inherited: the feature set is what names the vendor in
# the manifest, and a run that measured one library while recording another is worse than no run.
# The arm is passed to `build_for_faer_rev.sh`, which declares what the vendor is built with and
# reports it back for the manifest to record.
VENDOR_ARMS = ("openblas", "mkl")

# Thread-budget and tuning variables that belong to a vendor library, not to the measurement. The
# harness sets the budget from the row's thread count and reads it back, so an inherited value must
# not reach the measured process as if it were a declaration. MKL adds a budget, a domain budget and
# two selectable layers, one of which is an ABI; Intel and GNU OpenMP add a limit, a placement and a
# conditional-numerical-reproducibility switch, each of which can change how many workers run where,
# or which code path they take. A read-back of the thread count is not evidence that none of them
# was set: they were removed, and their values are recorded.
VENDOR_ENV = (
    "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS",
    "MKL_DOMAIN_NUM_THREADS",
    "MKL_INTERFACE_LAYER",
    "MKL_THREADING_LAYER",
    "MKL_DYNAMIC",
    "MKL_ENABLE_INSTRUCTIONS",
    "MKL_CBWR",
    "OMP_NUM_THREADS",
    "OMP_THREAD_LIMIT",
    "OMP_PROC_BIND",
    "OMP_PLACES",
    "KMP_AFFINITY",
    "GOMP_CPU_AFFINITY",
    "RAYON_NUM_THREADS",
)


def sh(cmd, **kw):
    print(f"+ {' '.join(str(c) for c in cmd)}", file=sys.stderr)
    return subprocess.run([str(c) for c in cmd], check=True, text=True,
                          capture_output=True, **kw)


def git(dir_, *args):
    return subprocess.run(["git", "-C", str(dir_), *args], check=True,
                          text=True, capture_output=True).stdout.strip()


def build(checkout, upstream, vendor):
    env_file = ROOT / "target" / f"pin-{vendor}.env"
    env_file.parent.mkdir(parents=True, exist_ok=True)
    sh([ROOT / "scripts/build_for_faer_rev.sh",
        "--checkout", checkout, "--upstream", upstream, "--vendor", vendor,
        "--out", env_file, "--bin", "fbench"],
       env=dict(os.environ, BENCH_VENDOR=vendor))
    pin = {}
    for line in env_file.read_text().splitlines():
        if "=" not in line:
            continue
        # The builder writes shell assignments with `printf %q`, so they are read back as shell
        # words: `.strip("\'\"")` leaves the backslash `%q` puts before a space.
        (assignment,) = shlex.split(line)
        k, _, v = assignment.partition("=")
        pin[k] = v
    return pin


def host_info(profile_name, profiles):
    profile = next(p for p in profiles if p["name"] == profile_name)
    lscpu = subprocess.run(["lscpu"], capture_output=True, text=True).stdout
    logical = next((int(l.split(":")[1].strip()) for l in lscpu.splitlines()
                    if l.startswith("CPU(s):")), 0)
    l3 = next((l.split(":", 1)[1].strip() for l in lscpu.splitlines()
               if l.startswith("L3 cache:")), None)
    return {
        "hostname": platform.node(),
        "cpu": profile["cpu"],
        "os": f"{platform.system()} {platform.release()}",
        "arch": platform.machine(),
        "logical_cpus": logical or profile["logical_cpus"],
        "l3": l3 or profile.get("l3"),
        "l3_domains": profile.get("l3"),
        "notes": profile.get("description"),
    }


# What provides each engine name the harness emits lives in campaign.py, shared
# with the validator so the two cannot disagree.


def vendor_identity(binary, env):
    """`fbench info` -> the vendor's own account of what was linked.

    Read from the binary that will be measured, executed directly the way the
    recorder executes it, so a loader or link problem shows up here rather than
    halfway through a timing pass.
    """
    out = subprocess.run([str(binary), "info"], capture_output=True, text=True, env=env)
    if out.returncode != 0:
        sys.exit(f"ERROR: {binary} info failed: {out.stderr.strip()}")
    fields = {}
    for line in out.stdout.splitlines():
        if "=" in line:
            k, _, v = line.partition("=")
            fields[k.strip()] = v.strip()
    return fields


def providers_for(engines, vendor, pin):
    """The providers and vendor library this run was measured against.

    The two faer entries name the revisions themselves, so `library` and
    `upstream` are restated where a reader looks for a provider's identity. The
    vendor entry is written from the identity the harness read out of the linked
    library, never from the arm that was requested: the point of reading it back
    is that the manifest records what was linked, not what was asked for.
    """
    out = []
    names = {PROVIDER_OF_ENGINE.get(e) for e in engines}
    for engine in FAER_ENGINES:
        if engine not in names:
            continue
        if engine == "faer-fork":
            out.append({"name": engine, "version": pin.get("FAER_FORK_VERSION") or None,
                        "commit": pin.get("FAER_FORK_REV"), "path": pin.get("FAER_FORK_DIR"),
                        "note": "the measured library: the tensor4all fork (package t4a-faer, "
                                "lib name faer) linked by path from its checkout"})
        else:
            out.append({"name": engine, "version": pin.get("FAER_UPSTREAM_VERSION") or None,
                        "commit": pin.get("FAER_UPSTREAM_REV"),
                        "path": pin.get("FAER_UPSTREAM_DIR"),
                        "note": f"upstream faer at {pin.get('FAER_UPSTREAM_REF') or 'a pinned revision'}, "
                                f"linked by path from its checkout"})
    for provider in vendor_engines(engines):
        if vendor.get("vendor.name") != provider:
            continue
        note = f"linked {vendor.get('vendor.linkage', '?')}"
        if vendor.get("vendor.corename"):
            note += f", kernel dispatched to {vendor['vendor.corename']}"
        elif provider == "mkl":
            note += ", kernel not reported by the vendor"
        if vendor.get("vendor.config"):
            note += f", config {vendor['vendor.config']}"
        out.append({"name": provider, "version": vendor.get("vendor.version") or None,
                    "commit": None, "path": None, "note": note})
    return out


def vendor_block(vendor, build_env):
    """The structured vendor identity, or None when no vendor arm was declared."""
    if not vendor.get("vendor.name") or vendor["vendor.name"] == "none":
        return None
    return {
        "name": vendor["vendor.name"],
        "linkage": vendor.get("vendor.linkage") or "none",
        "version": vendor.get("vendor.version") or None,
        "config": vendor.get("vendor.config") or None,
        "corename": vendor.get("vendor.corename") or None,
        "parallel": vendor.get("vendor.parallel") or None,
        "procs": int(vendor["vendor.procs"]) if vendor.get("vendor.procs") else None,
        "build_env": build_env or None,
    }


def skipped_of(csv_paths):
    """`family/shape` pairs one population's harness calls reported as not applicable.

    Taken per population rather than per regime: a regime can carry more than one population
    (the `gemm` shape grid cannot share a population with the linalg grid), and the harness
    labels every call with the population's regime, so keying by regime would merge two
    populations' skips. Recorded rather than inferred: a family the provider rejects is coverage
    the run did not have, and a page that claimed the whole grid would be wrong.
    """
    seen = set()
    for path in csv_paths:
        with open(path) as handle:
            for row in csv.DictReader(handle):
                if row.get("status") != "skipped":
                    continue
                shape = row["n"] if row["m"] == row["n"] else f"{row['m']}x{row['n']}"
                seen.add(f"{row['family']}/{shape}")
    return sorted(seen)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("profile")
    ap.add_argument("suite_id")
    ap.add_argument("--checkout", default=str(ROOT / "extern/t4a-faer"),
                    help="the measured fork faer checkout the harness links by path")
    ap.add_argument("--upstream", default=str(ROOT / "extern/upstream-faer"),
                    help="the upstream faer checkout the harness links by path, as the baseline")
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--aa", type=int, default=1, help="number of complete set repeats (>=2 gives A/A)")
    ap.add_argument("--prime-ms", type=int, default=500)
    ap.add_argument("--regimes", default=None, help="override, comma separated")
    ap.add_argument("--families", default=None,
                    help="override: measure only these families (comma separated). The run records the "
                         "subset it covered, so a partial population is visible rather than implied.")
    ap.add_argument("--threads", default=None, help="override, comma separated")
    ap.add_argument("--dtypes", default=None)
    ap.add_argument("--engines", default=None,
                    help="which engine rows to declare as this run's own, for a report. It does not "
                         "select what the harness measures: the binary measures the rows it was "
                         "built with, whatever this says.")
    ap.add_argument("--vendor", default=None,
                    help="which vendor arm to record: one binary links one vendor library, so an arm "
                         "is its own run. Required when the suite declares more than one.")
    ap.add_argument("--label", default=None, help="suffix for the run directory")
    args = ap.parse_args()

    profiles = yaml.safe_load((ROOT / "benchmarks/profiles.yaml").read_text())["profiles"]
    suite = yaml.safe_load((ROOT / "benchmarks/suites" / f"{args.suite_id}.yaml").read_text())
    spec = suite["runs"][0]
    declared = populations(suite)
    covered = declared
    if args.regimes:
        wanted = set(args.regimes.split(","))
        covered = [p for p in declared if p["regime"] in wanted]
    if args.families:
        wanted = set(args.families.split(","))
        declared_families = {f for p in declared for f in p["families"]}
        unknown = wanted - declared_families
        if unknown:
            sys.exit(f"ERROR: {sorted(unknown)} are not declared by this suite")
        covered = [dict(p, families=[f for f in p["families"] if f in wanted]) for p in covered]
        covered = [p for p in covered if p["families"]]
    threads = [int(t) for t in args.threads.split(",")] if args.threads else spec["threads"]
    dtypes = args.dtypes.split(",") if args.dtypes else spec["dtypes"]
    order = spec["order"]
    arms = vendor_engines(spec["engines"])
    if args.vendor:
        arm = args.vendor
    elif len(arms) == 1:
        arm = arms[0]
    else:
        sys.exit(f"ERROR: this suite declares the vendor arms {arms}, and one binary links one vendor "
                 f"library, so one run records one of them: pass --vendor")
    if arm not in arms:
        sys.exit(f"ERROR: --vendor {arm!r} is not one of the arms this suite declares ({arms})")
    if arm not in VENDOR_ARMS:
        sys.exit(f"ERROR: unknown vendor arm {arm!r}; this recorder knows {list(VENDOR_ARMS)}")
    # The engines this arm is expected to measure: the two faer rows every arm carries, plus this
    # arm's own LAPACK row. Anything else is another binary's to measure.
    engines = args.engines.split(",") if args.engines else engines_for_vendor(suite, arm)
    cpu_sets = {str(t): spec["cpu_sets"][spec["threads"].index(t)] for t in threads}

    # One measurement at a time, and no build while a measurement runs. Taken
    # before the build and held for the whole run.
    lock_path = ROOT / "target/campaign.lock"
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    lock = open(lock_path, "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit("ERROR: another campaign run holds target/campaign.lock; "
                 "the campaign is one measurement at a time")

    checkout = pathlib.Path(args.checkout)
    upstream = pathlib.Path(args.upstream)
    pin = build(checkout, upstream, arm)
    fork_rev, fork_dirty = pin["FAER_FORK_REV"], pin["FAER_FORK_DIRTY"] == "true"
    up_rev, up_dirty = pin["FAER_UPSTREAM_REV"], pin["FAER_UPSTREAM_DIRTY"] == "true"
    if fork_dirty or up_dirty:
        print("WARNING: a measured checkout is dirty; this cell will be marked dirty", file=sys.stderr)

    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    name = f"{stamp}-{args.label}" if args.label else stamp
    run_dir = ROOT / "data/results" / args.profile / args.suite_id / name
    run_dir.mkdir(parents=True, exist_ok=True)

    bin_dir = pathlib.Path(pin["BIN_DIR"])
    fbench = bin_dir / "fbench"
    # The timing protocol belongs to the harness, and the harness lives here: faer has no
    # benchmarks/ directory and the fork's AGENTS.md forbids adding one.
    pinned = ROOT / "benchmarks/scripts/pinned.sh"
    idle = ROOT / "benchmarks/scripts/idle_cpus.py"
    if not pinned.exists() or not idle.exists():
        sys.exit(f"ERROR: {pinned} or {idle} missing; the protocol scripts belong to the harness")

    # The thread budget is the measurement's, not the environment's. The vendor
    # library is set from the row's budget by the harness and read back, so an
    # ambient value must not be inherited as if it were a declaration.
    env = dict(os.environ)
    for variable in VENDOR_ENV:
        env.pop(variable, None)
    env.setdefault("CARGO_BUILD_JOBS", str(max(1, (os.cpu_count() or 4) // 4)))

    # What the harness reports it linked decides the manifest, not what was asked for: the arm
    # and the binary have to agree, or the run is not recorded at all.
    identity = vendor_identity(fbench, env)
    if identity.get("vendor.name") != arm:
        sys.exit(f"ERROR: this run records the {arm} arm, but the harness built for it reports "
                 f"{identity.get('vendor.name')!r}; a page may not name a vendor the binary did "
                 f"not link")

    guards = []
    csvs = []
    per_population = {}

    # 1. correctness first, for the whole covered grid, at every budget.
    for population in covered:
        for t in threads:
            stem = f"verify-{population['regime']}-{t}t"
            out = run_dir / f"{stem}.txt"
            guard = run_dir / f"{stem}.guard"
            r = subprocess.run([str(pinned), cpu_sets[str(t)], "--", str(fbench), "verify",
                                "--threads", str(t),
                                "--n", ",".join(population["n"]),
                                "--batch", ",".join(str(b) for b in population["batch"]),
                                "--dtype", ",".join(dtypes),
                                "--family", ",".join(population["families"])],
                               env=env, capture_output=True, text=True)
            out.write_text(r.stdout)
            guard.write_text(r.stderr)
            guards.append(guard.name)
            if r.returncode != 0 or "MISMATCH" in r.stdout:
                sys.exit(f"ERROR: verify failed for {population['regime']} {t}T (see {out}); nothing published")
            if "all comparisons within tolerance" not in r.stdout:
                sys.exit(f"ERROR: verify did not report a clean grid for {population['regime']} {t}T")

    # 2. timing, one CSV per (repeat, population, threads).
    for rep in range(args.aa):
        for index, population in enumerate(covered):
            for t in threads:
                stem = f"run{rep}-{population['regime']}-{t}t"
                csv_path = run_dir / f"{stem}.csv"
                r = subprocess.run([str(pinned), cpu_sets[str(t)], "--", str(fbench), "run",
                                    "--threads", str(t),
                                    "--n", ",".join(population["n"]),
                                    "--batch", ",".join(str(b) for b in population["batch"]),
                                    "--dtype", ",".join(dtypes),
                                    "--family", ",".join(population["families"]),
                                    "--regime", population["regime"],
                                    "--reps", str(args.reps), "--prime-ms", str(args.prime_ms),
                                    "--csv", str(csv_path)],
                                   env=env, capture_output=True, text=True)
                (run_dir / f"{stem}.guard").write_text(r.stderr)
                guards.append(f"{stem}.guard")
                if r.returncode != 0:
                    sys.exit(f"ERROR: run failed for {population['regime']} {t}T (repeat {rep}): {r.stderr[-2000:]}")
                if not csv_path.exists():
                    sys.exit(f"ERROR: no CSV produced for {population['regime']} {t}T")
                csvs.append(str(csv_path))
                per_population.setdefault(index, []).append(csv_path)

    recorded = []
    for index, population in enumerate(covered):
        entry = dict(population)
        skipped = skipped_of(per_population.get(index, []))
        if skipped:
            entry["skipped"] = skipped
        recorded.append(entry)

    manifest = {
        "schema_version": 1,
        "target_profile": args.profile,
        "suite_id": args.suite_id,
        "suite_file": f"benchmarks/suites/{args.suite_id}.yaml",
        "suite_sha256": hashlib.sha256(
            (ROOT / "benchmarks/suites" / f"{args.suite_id}.yaml").read_bytes()).hexdigest(),
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z"),
        "command": " ".join(sys.argv),
        "library": {
            "url": "https://github.com/tensor4all/faer",
            "commit": fork_rev,
            "dirty": fork_dirty,
            "features": [f for f in pin["BUILD_FEATURES"].split(",") if f],
            "measured_path": pin["FAER_FORK_DIR"],
            "version": pin.get("FAER_FORK_VERSION") or None,
        },
        "upstream": {
            "url": "https://codeberg.org/sarah-quinones/faer",
            "commit": up_rev,
            "version": pin.get("FAER_UPSTREAM_VERSION") or None,
            "ref": pin.get("FAER_UPSTREAM_REF") or None,
            "dirty": up_dirty,
            "measured_path": pin["FAER_UPSTREAM_DIR"],
        },
        "vendor": vendor_block(identity, pin.get("BUILD_ENV")),
        "harness": {
            "commit": git(ROOT, "rev-parse", "HEAD"),
            "dirty": bool(git(ROOT, "status", "--porcelain", "--untracked-files=no")),
        },
        "host": host_info(args.profile, profiles),
        "threads": {
            "counts": threads,
            "cpu_sets": cpu_sets,
            "env": {k: os.environ.get(k) for k in VENDOR_ENV},
            "note": "the vendor's budget is set by the harness from the row's thread count and "
                    "read back before each measurement; these variables were removed from the "
                    "measured process's environment so it cannot inherit a different one"
                    + (", and the harness pins MKL's LP64 interface and Intel OpenMP layers "
                       "before its first call" if arm == "mkl" else ""),
        },
        "timing_policy": {
            "version": 1,
            "minimum_untimed_priming_ms": args.prime_ms,
            "statistic": "best",
            "repetitions": args.reps,
            "notes": "priming is time-based, not a call count: after an idle gate this host "
                     "reads low for the first second or two of sustained work",
        },
        "guards": {
            "idle_window_seconds": int(os.environ.get("PINNED_IDLE_SECONDS", 3)),
            "max_busy_percent": round(float(os.environ.get("PINNED_MAX_BUSY", 0.05)) * 100, 3),
            "attempts": int(os.environ.get("PINNED_RETRIES", 3)),
            "sibling_aware": True,
            "logs": sorted(set(guards)),
        },
        "providers": providers_for(engines, identity, pin),
        "invalidated_by": suite["invalidated_by"],
        "result_files": [pathlib.Path(c).name for c in csvs],
        "run_spec": {
            "populations": recorded,
            "dtypes": dtypes,
            "order": order,
            "engines": engines,
            "aa": args.aa,
            "covers_declared_suite": (threads == spec["threads"]
                                      and dtypes == spec["dtypes"]
                                      and order == spec["order"]
                                      and engines == engines_for_vendor(suite, arm)
                                      and same_populations(covered, declared)),
        },
    }

    manifest_path = run_dir / "run.yaml"
    manifest_path.write_text(yaml.safe_dump(manifest, sort_keys=False))
    v = subprocess.run([sys.executable, str(ROOT / "scripts/validate_run.py"), str(manifest_path)],
                       capture_output=True, text=True)
    print(v.stdout + v.stderr, file=sys.stderr)
    if v.returncode != 0:
        sys.exit("ERROR: run.yaml does not validate; nothing published")

    subprocess.run([sys.executable, str(ROOT / "scripts/report_run.py"), "--run-dir", str(run_dir)], check=True)
    subprocess.run([sys.executable, str(ROOT / "scripts/publish_report.py"), str(run_dir)], check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
