#!/usr/bin/env python3
"""Before/after tables: median over processes of per_item_us per cell; a cell with a busy process is marked `*`."""
import csv, glob, json, os, statistics, collections
here = os.path.dirname(os.path.abspath(__file__))
busy = {}
for l in open(os.path.join(here, "processes.log")):
    d = json.loads(l); busy[d["tag"]] = d["busy"]
cells = collections.defaultdict(list)
for f in sorted(glob.glob(os.path.join(here, "raw", "*.csv"))):
    tag = os.path.basename(f)[:-4]
    label = tag.split("-")[0]
    for r in csv.DictReader(open(f)):
        if r["status"] != "ok":
            continue
        cells[(label, r["family"], int(r["threads"]), int(r["m"]), r["row"])].append((float(r["per_item_us"]), busy[tag]))
def med(key):
    v = cells.get(key)
    if not v:
        return None, False
    return statistics.median(x[0] for x in v), any(x[1] for x in v)
def serial(fam, n):
    v = cells.get(("before", fam, 1, n, "faer-fork"), []) + cells.get(("after", fam, 1, n, "faer-fork"), [])
    return (statistics.median(x[0] for x in v), any(x[1] for x in v)) if v else (None, False)
out = ["Microseconds per call (median of processes), f64, `*` marks a cell with a busy process. Ratios are to the one thread serial time.", ""]
names = {"qr_factor": "QR (factorization)", "cholesky": "Cholesky", "svd_values": "SVD (singular values)", "eigh": "EVD (eigh)"}
out.append("| family | n | serial | plain before | plain after | team before | team after | plain b/s | plain a/s | team b/s | team a/s |")
out.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
for fam in ["qr_factor", "cholesky", "svd_values", "eigh"]:
    for n in [128, 256, 512]:
        s, sb = serial(fam, n)
        vals = []
        for lab, row in [("before", "faer-fork-free"), ("after", "faer-fork-free"), ("before", "faer-fork-team"), ("after", "faer-fork-team")]:
            vals.append(med((lab, fam, 6, n, row)))
        f = lambda x: "-" if x[0] is None else f"{x[0]:.1f}{'*' if x[1] else ''}"
        r = lambda x: "-" if x[0] is None or s is None else f"{x[0] / s:.2f}{'*' if x[1] or sb else ''}"
        out.append(f"| {names[fam]} | {n} | {f((s, sb))} | " + " | ".join(f(v) for v in vals) + " | " + " | ".join(r(v) for v in vals) + " |")
open(os.path.join(here, "tables.md"), "w").write("\n".join(out) + "\n")
print("\n".join(out))
