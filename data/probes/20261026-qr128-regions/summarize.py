#!/usr/bin/env python3
"""Tables from raw/tbl-*.csv (median over passes of the per-process medians) and the process log."""
import csv, glob, json, os, statistics as st, sys
busy = {}
for l in open("processes.log"):
    d = json.loads(l)
    busy[d["tag"]] = d["busy"]
cells = {}
for f in sorted(glob.glob("raw/tbl-*.csv")):
    tag = os.path.basename(f)[:-4]
    _, v, fam, n, r = tag.split("-")
    line = open(f).read().strip().splitlines()
    if not line:
        continue
    p = line[-1].split(",")
    cells.setdefault((fam, int(n)), {}).setdefault(v, []).append((float(p[2]), float(p[3]), float(p[4]), busy.get(tag, True)))
names = {"qr": "QR (no pivoting)", "svd": "SVD (U, V)", "evd": "EVD (eigenvectors)", "tinv": "triangular inverse", "spmm": "sparse matmul (4/col, n = dimension)"}
out = ["Microseconds per call (median over passes), f64; ratios are to the one thread serial time of the same process. `*` marks a cell with a busy process.", "",
       "| family | n | serial | plain before | plain after | team before | team after | plain b/s | plain a/s | team b/s | team a/s |", "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
for (fam, n), d in sorted(cells.items(), key=lambda kv: (list(names).index(kv[0][0]), kv[0][1])):
    if "before" not in d or "after" not in d:
        continue
    def m(v, i):
        return st.median([x[i] for x in d[v]])
    mark = "*" if any(x[3] for v in d for x in d[v]) else ""
    ser = st.median([x[0] for v in d for x in d[v]])
    sb, sa = m("before", 0), m("after", 0)
    pb, pa, tb, ta = m("before", 1), m("after", 1), m("before", 2), m("after", 2)
    # the ratio uses the serial of the same build
    out.append(f"| {names[fam]} | {n}{mark} | {ser/1e3:.1f} | {pb/1e3:.1f} | {pa/1e3:.1f} | {tb/1e3:.1f} | {ta/1e3:.1f} | {pb/sb:.2f} | {pa/sa:.2f} | {tb/sb:.2f} | {ta/sa:.2f} |")
open("tables.md", "w").write("\n".join(out) + "\n")
print("\n".join(out))
