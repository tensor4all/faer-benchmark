#!/usr/bin/env python3
"""Tables for the stage 1 run: python3 summarize.py <run-dir> > tables.md

Per cell (set, family, shape, threads) every process gives one median per row (the median of that
process's timed repetitions). Ratios are taken per process (so the rotation that put a row first or
last cancels in the average over the three rotations) and the table shows their median and range.
"""
import csv, glob, json, os, re, statistics, sys
from collections import defaultdict

run = sys.argv[1]
COMPACT = "--compact" in sys.argv
HELD, HOT, FREE = "faer-fork", "faer-fork-hot", "faer-fork-free"
cells = defaultdict(lambda: defaultdict(dict))  # key -> row -> rot -> record
for path in sorted(glob.glob(os.path.join(run, "*-T*-rot*.csv"))):
    tag = os.path.basename(path)[:-4]
    m = re.match(r"(\w+)-T(\d+)-rot(\d+)$", tag)
    if not m or m.group(1) == "dispatch":
        continue
    st, T, rot = m.group(1), int(m.group(2)), int(m.group(3))
    for r in csv.DictReader(open(path)):
        if r["status"] != "ok":
            continue
        key = (r["family"], int(r["m"]), int(r["n"]), r["k"] and int(r["k"]), T)
        wall = [float(x) for x in json.loads(r["samples_ms"])] if r["samples_ms"] else []
        cpu = [float(x) for x in json.loads(r["cpu_samples_ms"])] if r.get("cpu_samples_ms") else []
        cells[key][r["row"]][rot] = {"med": statistics.median(wall), "q1": statistics.quantiles(wall, n=4)[0] if len(wall) > 3 else None,
                                       "q3": statistics.quantiles(wall, n=4)[2] if len(wall) > 3 else None,
                                       "cpu_over_wall": (sum(cpu) / sum(wall)) if cpu and sum(wall) else None,
                                       "loop": (float(r["loop_cpu_ms"]) / float(r["loop_wall_ms"])) if r.get("loop_wall_ms") else None}


def shape(k):
    fam, m, n, kk, T = k
    if fam == "gemm":
        return f"{m}x{kk}x{n}"
    return f"{m}"


def fmt(x, p=3):
    return "" if x is None else f"{x:.{p}g}"


def ratios(row_a, row_b):
    out = []
    for rot, a in row_a.items():
        b = row_b.get(rot)
        if b:
            out.append(a["med"] / b["med"])
    return out


order = {"gemm": 0, "lu": 1, "qr_factor": 2, "cholesky": 3}
keys = sorted(cells, key=lambda k: (k[4], order.get(k[0], 9), k[1] * (k[3] or 1) * k[2], k[1]))
print("## Wall time per cell (ms, median over the three rotations of the per-process medians)\n")
print("`hot/held` and `free/held` are the median over rotations of the per-process ratio; the bracket is the min to max over rotations. Below 1 means faster than the held spindle group.\n")
for T in sorted({k[4] for k in keys}):
    print(f"### {T} threads\n")
    if COMPACT:
        print("| op | shape | held ms | hot ms | free ms | hot/held [min, max] | free/held |")
        print("| --- | --- | --- | --- | --- | --- | --- |")
    else:
        print("| op | shape | held (ms) | hot (ms) | free (ms) | hot/held | free/held | held cpu/wall | hot cpu/wall | free cpu/wall |")
        print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for k in [k for k in keys if k[4] == T]:
        c = cells[k]
        if not all(r in c for r in (HELD, HOT, FREE)):
            continue
        med = {r: statistics.median(v["med"] for v in c[r].values()) for r in (HELD, HOT, FREE)}
        rh, rf = ratios(c[HOT], c[HELD]), ratios(c[FREE], c[HELD])
        cw = {r: statistics.median(v["cpu_over_wall"] for v in c[r].values() if v["cpu_over_wall"]) if any(v["cpu_over_wall"] for v in c[r].values()) else None for r in (HELD, HOT, FREE)}
        rng = lambda x: f"{statistics.median(x):.3f} [{min(x):.3f}, {max(x):.3f}]"
        if COMPACT:
            print(f"| {k[0]} | {shape(k)} | {fmt(med[HELD])} | {fmt(med[HOT])} | {fmt(med[FREE])} | {rng(rh)} | {statistics.median(rf):.3f} |")
            continue
        print(f"| {k[0]} | {shape(k)} | {fmt(med[HELD])} | {fmt(med[HOT])} | {fmt(med[FREE])} | {rng(rh)} | {rng(rf)} | {fmt(cw[HELD], 3)} | {fmt(cw[HOT], 3)} | {fmt(cw[FREE], 3)} |")
    print()

print("## Median of the ratios over all cells of a family (and rotations)\n")
print("| threads | op | cells | median hot/held | min | max | median free/held | median free/hot |")
print("| --- | --- | --- | --- | --- | --- | --- | --- |")
agg = defaultdict(lambda: ([], [], []))
for k in keys:
    c = cells[k]
    if not all(r in c for r in (HELD, HOT, FREE)):
        continue
    a = agg[(k[4], k[0])]
    a[0].append(statistics.median(ratios(c[HOT], c[HELD])))
    a[1].append(statistics.median(ratios(c[FREE], c[HELD])))
    a[2].append(statistics.median(ratios(c[FREE], c[HOT])))
for (T, fam), (h, f, fh) in sorted(agg.items(), key=lambda kv: (kv[0][0], order.get(kv[0][1], 9))):
    print(f"| {T} | {fam} | {len(h)} | {statistics.median(h):.3f} | {min(h):.3f} | {max(h):.3f} | {statistics.median(f):.3f} | {statistics.median(fh):.3f} |")
print()

# dispatch
rows = []
for path in sorted(glob.glob(os.path.join(run, "dispatch-T*-rot*.csv"))):
    m = re.match(r"dispatch-T(\d+)-rot(\d+)", os.path.basename(path))
    for r in csv.DictReader(open(path)):
        rows.append((int(m.group(1)), int(m.group(2)), r))
if rows:
    g = defaultdict(list)
    for T, rot, r in rows:
        g[(T, r["test"], int(r["gap_us"]), r["row"])].append((float(r["median_ns"]), float(r["p90_ns"]), float(r["max_ns"]), float(r["cpu_over_wall"])))
    print("## Tiny parallel region: dispatch cost and wake latency (ns, median over three row orders)\n")
    print("`b2b_*`: dispatches back to back (mean per dispatch over blocks of 1000). `gap_*`: latency of one dispatch after the leader worked serially for `gap` us; `cpu/wall` is the process CPU time over wall time across that loop (cores kept busy, the leader's own core counts as 1).\n")
    for T in sorted({k[0] for k in g}):
        print(f"### {T} threads\n")
        print("| test | gap (us) | held median | hot median | free median | held p90 | hot p90 | free p90 | held cpu/wall | hot cpu/wall | free cpu/wall |")
        print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
        tests = sorted({(k[1], k[2]) for k in g if k[0] == T}, key=lambda x: (x[0] != "b2b_spindle_for_each", x[0], x[1]))
        for test, gap in tests:
            cell = {}
            for row in (HELD, HOT, FREE):
                v = g.get((T, test, gap, row))
                cell[row] = (statistics.median(x[0] for x in v), statistics.median(x[1] for x in v), statistics.median(x[3] for x in v)) if v else (None,) * 3
            print(f"| {test} | {gap} | {fmt(cell[HELD][0])} | {fmt(cell[HOT][0])} | {fmt(cell[FREE][0])} | {fmt(cell[HELD][1])} | {fmt(cell[HOT][1])} | {fmt(cell[FREE][1])} | {fmt(cell[HELD][2])} | {fmt(cell[HOT][2])} | {fmt(cell[FREE][2])} |")
        print()
