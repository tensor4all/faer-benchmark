#!/usr/bin/env python3
"""Median ns per unit over shapes and rounds, per family and dtype; also the median over clean (not busy) processes."""
import csv, glob, json, os, statistics as st, collections
busy = {}
for l in open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "processes.log")):
    d = json.loads(l); busy[d["tag"]] = d["busy"]
rows = collections.defaultdict(list)
for f in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), "raw", "*.csv"))):
    tag = os.path.basename(f)[:-4]
    for r in csv.DictReader(open(f)):
        rows[(r["name"], r["type"])].append((float(r["ns_per_unit"]), busy[tag], r["shape"]))
out = ["| family | type | median | clean median | range | cells |", "| --- | --- | --- | --- | --- | --- |"]
for (n, t), v in sorted(rows.items()):
    vals = [x[0] for x in v]; clean = [x[0] for x in v if not x[1]]
    cm = st.median(clean) if clean else float("nan")
    out.append(f"| {n} | {t} | {st.median(vals):.4f} | {cm:.4f} | {min(vals):.4f} to {max(vals):.4f} | {len(vals)} |")
open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "tables.md"), "w").write("\n".join(out) + "\n")
print("\n".join(out))
