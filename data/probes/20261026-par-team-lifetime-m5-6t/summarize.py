#!/usr/bin/env python3
"""python3 summarize.py <raw-dir> > tables.md: per cell and per row the median of the process medians
(1 to 2 processes), ratios per process; the `busy` flag of each process comes from processes.log."""
import csv, glob, json, os, re, statistics, sys
from collections import defaultdict
run = sys.argv[1]
busy = {}
for l in open(os.path.join(run, "processes.log")):
    d = json.loads(l); busy[d["tag"]] = d["busy"]
HELD, HOT, FREE, TEAM = "faer-fork", "faer-fork-hot", "faer-fork-free", "faer-fork-team"
cells = defaultdict(lambda: defaultdict(dict))
for path in sorted(glob.glob(os.path.join(run, "main-*.csv"))):
    tag = os.path.basename(path)[:-4]
    for r in csv.DictReader(open(path)):
        if r["status"] != "ok": continue
        wall = [float(x) for x in json.loads(r["samples_ms"])]
        cpu = [float(x) for x in json.loads(r["cpu_samples_ms"])] if r.get("cpu_samples_ms") else []
        key = (r["family"], int(r["m"]), int(r["n"]), r["k"] and int(r["k"]))
        cells[key][r["row"]][tag] = (statistics.median(wall), sum(cpu) / sum(wall) if cpu else None)
def shape(k):
    return f"{k[1]}x{k[3]}x{k[2]}" if k[0] == "gemm" else f"{k[1]}"
print("## Stage 2 families, 6 threads: median wall time (ms) over processes and ratios per process\n")
print("`*` marks a cell from a process flagged busy (host below 85 percent idle at some sample).\n")
print("| op | shape | held ms | hot ms | free ms | team ms | team/held | team/hot | team/free | processes | busy | team cpu/wall |")
print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
for k in sorted(cells, key=lambda k: (k[0], k[1], k[2])):
    c = cells[k]
    tags = sorted(set(c.get(TEAM, {})) & set(c.get(HELD, {})))
    if not tags: continue
    med = lambda row: statistics.median(c[row][t][0] for t in tags if t in c.get(row, {})) if c.get(row) else None
    ratio = lambda a, b: statistics.median(c[a][t][0] / c[b][t][0] for t in tags if t in c.get(a, {}) and t in c.get(b, {})) if c.get(a) and c.get(b) else None
    f = lambda x: "" if x is None else f"{x:.3g}"
    cw = statistics.median(c[TEAM][t][1] for t in tags if c[TEAM][t][1])
    b = "*" if any(busy.get(t) for t in tags) else ""
    print(f"| {k[0]} | {shape(k)} | {f(med(HELD))} | {f(med(HOT))} | {f(med(FREE))} | {f(med(TEAM))} | {f(ratio(TEAM,HELD))} | {f(ratio(TEAM,HOT))} | {f(ratio(TEAM,FREE))} | {len(tags)} | {b} | {cw:.2f} |")
print("\n## Small-operation sequences, 6 threads (median of the 41 repetitions, per call in microseconds)\n")
rows = defaultdict(lambda: defaultdict(dict))
for path in sorted(glob.glob(os.path.join(run, "smallops-*.csv"))):
    tag = os.path.basename(path)[:-4]
    for r in csv.DictReader(open(path)):
        rows[r["seq"]][r["row"]][tag] = (float(r["per_call_us"]), float(r["cpu_over_wall"]), r["engagement"])
print("| sequence | held | hot | free | team | team/held | team/free | team cpu/wall | busy |")
print("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
for s, c in rows.items():
    tags = sorted(c[TEAM])
    med = lambda row: statistics.median(c[row][t][0] for t in tags if t in c[row])
    ratio = lambda a, b: statistics.median(c[a][t][0] / c[b][t][0] for t in tags if t in c[a] and t in c[b])
    cw = statistics.median(c[TEAM][t][1] for t in tags)
    b = "*" if any(busy.get(t) for t in tags) else ""
    print(f"| {s} | {med(HELD):.3g} | {med(HOT):.3g} | {med(FREE):.3g} | {med(TEAM):.3g} | {ratio(TEAM,HELD):.3g} | {ratio(TEAM,FREE):.3g} | {cw:.2f} | {b} |")
print("\nEngagement of the team row (one untimed pass per sequence):\n")
for s, c in rows.items():
    t = sorted(c[TEAM])[0]
    print(f"* {s}: {c[TEAM][t][2]}")
