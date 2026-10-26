#!/usr/bin/env python3
"""Tables from raw/ (writes tables-<name>.md next to this file and prints them).

    summarize.py fbench     stage comparison rows held/hot/free/team per thread budget, smallops, fbench dispatch
    summarize.py dispatch   threadteam dispatch cost per token kind, the DispatchCosts Linux row, wake latency
    summarize.py consts     serial throughput constants against the M5 values of thresholds.md 2.3
    summarize.py confirm    strided / tcontract / cpueinsum / tlinalg ratios to serial and break-even sizes
    summarize.py diag       x86_64 GEMM path: threads busy per row
    summarize.py hosts      host protocol per process (idle before/after, load, top 3, governor, boost, EPP)
    summarize.py all

Adapted from par-team-lifetime-m5-6t/summarize.py, threadteam-rs thresholds-data/summarize.py and the
recalibration probe's summarize_consts.py. A process in raw/processes.log is valid (the runner never keeps a
rejected attempt); `busy` is therefore always false and cells carry no `*`.
"""
import collections, csv, glob, json, os, re, statistics as st, sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.environ.get("AWAKE_RAW", os.path.join(HERE, "raw"))
HELD, HOT, FREE, TEAM = "faer-fork", "faer-fork-hot", "faer-fork-free", "faer-fork-team"


def med(v):
    v = [x for x in v if x is not None]
    return st.median(v) if v else None


def fmt(x, p=3):
    return "" if x is None else f"{x:.{p}g}"


def fbench():
    out = []
    for T in (4, 8):
        cells = collections.defaultdict(lambda: collections.defaultdict(dict))
        for path in sorted(glob.glob(os.path.join(RAW, f"main-*-T{T}-rot*.csv"))):
            tag = os.path.basename(path)[:-4]
            for r in csv.DictReader(open(path)):
                if r["status"] != "ok":
                    continue
                wall = [float(x) for x in json.loads(r["samples_ms"])]
                cpu = [float(x) for x in json.loads(r["cpu_samples_ms"])] if r.get("cpu_samples_ms") else []
                key = (r["family"], int(r["m"]), int(r["n"]), r["k"] and int(r["k"]))
                cells[key][r["row"]][tag] = (st.median(wall), sum(cpu) / sum(wall) if cpu else None, max(wall) / min(wall))
        if not cells:
            continue
        out.append(f"## Stage comparison, {T} threads: median wall time (ms) over rotations, ratios per rotation\n")
        out.append("Rows: held = `faer-fork` (spindle group held), hot = awake Rayon team, free = nothing held, team = `Par::Team`. "
                   "Ratios are medians over the rotation processes of the per-process ratio (below 1: team faster). "
                   "`rot` counts the row-order rotations that produced the cell (`--rotate-rows`); `pos` is the spread of "
                   "the team ratio to held over rotations (max/min): a large value means row position matters.\n")
        out.append("| op | shape | held ms | hot ms | free ms | team ms | team/held | team/hot | team/free | rot | pos | team cpu/wall |")
        out.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
        for k in sorted(cells, key=lambda k: (k[0], k[1], k[2])):
            c = cells[k]
            tags = sorted(set(c.get(TEAM, {})) & set(c.get(HELD, {})))
            if not tags:
                continue
            m = lambda row: med([c[row][t][0] for t in tags if t in c.get(row, {})])
            ratio = lambda a, b: [c[a][t][0] / c[b][t][0] for t in tags if t in c.get(a, {}) and t in c.get(b, {})]
            rr = ratio(TEAM, HELD)
            shape = f"{k[1]}x{k[3]}x{k[2]}" if k[0] == "gemm" else f"{k[1]}"
            cw = med([c[TEAM][t][1] for t in tags])
            out.append(f"| {k[0]} | {shape} | {fmt(m(HELD))} | {fmt(m(HOT))} | {fmt(m(FREE))} | {fmt(m(TEAM))} | {fmt(med(rr))} | "
                       f"{fmt(med(ratio(TEAM, HOT)))} | {fmt(med(ratio(TEAM, FREE)))} | {len(tags)} | {fmt(max(rr) / min(rr), 3)} | {fmt(cw, 3)} |")
        out.append("")
        # smallops
        rows = collections.defaultdict(lambda: collections.defaultdict(dict))
        for path in sorted(glob.glob(os.path.join(RAW, f"smallops-seq-T{T}-rot*.csv"))):
            tag = os.path.basename(path)[:-4]
            for r in csv.DictReader(open(path)):
                rows[r["seq"]][r["row"]][tag] = (float(r["per_call_us"]), float(r["cpu_over_wall"]), r["engagement"])
        if rows:
            out.append(f"## Small-operation sequences, {T} threads (median of 41 repetitions, microseconds per call; settle 300 ms)\n")
            out.append("| sequence | held | hot | free | team | team/held | team/free | team cpu/wall | rot |")
            out.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
            for s, c in rows.items():
                tags = sorted(c[TEAM])
                m = lambda row: med([c[row][t][0] for t in tags if t in c[row]])
                ratio = lambda a, b: med([c[a][t][0] / c[b][t][0] for t in tags if t in c[a] and t in c[b]])
                out.append(f"| {s} | {fmt(m(HELD))} | {fmt(m(HOT))} | {fmt(m(FREE))} | {fmt(m(TEAM))} | {fmt(ratio(TEAM, HELD))} | "
                           f"{fmt(ratio(TEAM, FREE))} | {fmt(med([c[TEAM][t][1] for t in tags]), 3)} | {len(tags)} |")
            out.append("\nEngagement of the team row (one untimed pass per sequence):\n")
            for s, c in rows.items():
                out.append(f"* {s}: {c[TEAM][sorted(c[TEAM])[0]][2]}")
            out.append("")
        # fbench dispatch
        d = collections.defaultdict(lambda: collections.defaultdict(list))
        for path in sorted(glob.glob(os.path.join(RAW, f"dispatch-fbench-T{T}-rot*.csv"))):
            for r in csv.DictReader(open(path)):
                d[(r["test"], int(r["gap_us"]))][r["row"]].append((float(r["median_ns"]), float(r["cpu_over_wall"])))
        if d:
            out.append(f"## `fbench dispatch`, {T} threads: median ns over rotations (cpu/wall in brackets)\n")
            out.append("| test | gap us | held | hot | free | team |")
            out.append("| --- | --- | --- | --- | --- | --- |")
            for (test, gap), c in sorted(d.items()):
                cell = lambda row: "" if row not in c else f"{med([x[0] for x in c[row]]):.0f} ({med([x[1] for x in c[row]]):.2f})"
                out.append(f"| {test} | {gap} | {cell(HELD)} | {cell(HOT)} | {cell(FREE)} | {cell(TEAM)} |")
            out.append("")
    return "\n".join(out)


def dispatch():
    out = []
    data = {}
    for T in (8, 4):
        rows = collections.defaultdict(list)
        for p in sorted(glob.glob(os.path.join(RAW, f"dispatch-T{T}-p*.csv"))):
            for r in csv.DictReader(open(p)):
                rows[(r["kind"], int(r["width"]))].append(float(r["ns"]))
        data[T] = rows
        if not rows:
            continue
        kinds = []
        for k, _ in rows:
            if k not in kinds:
                kinds.append(k)
        ws = sorted({w for _, w in rows})
        out.append(f"## Dispatch cost, pool of {T} (us per section, median over {max(len(v) for v in rows.values())} processes; "
                   "`load10us-minus-10us` rows give every share 10 us of work and subtract it)\n")
        out.append("| kind | " + " | ".join(f"w={w}" for w in ws) + " |")
        out.append("| --- |" + " --- |" * len(ws))
        for k in kinds:
            out.append(f"| {k} | " + " | ".join(f"{med(rows[(k, w)]) / 1000:.2f}" if (k, w) in rows else "-" for w in ws) + " |")
        out.append("")
    rows8 = data.get(8) or {}
    if rows8:
        key = {"team": "team/load10us-minus-10us", "in_pool": "plain/in-pool-load10us-minus-10us", "outside": "plain/outside-load10us-minus-10us"}
        out.append("## Linux row of `DispatchCosts` (anchors 2, 4, 6 from the pool-of-8 processes; 10 us share rows)\n")
        out.append("```rust\n// Measured on <host> (AMD Ryzen AI 9 HX 470), 8 threads on cores 4-11, boost off, from the back to back sections whose\n"
                   "// shares carry 10 us of work (faer-benchmark data/probes/20261026-awake-team-linux), us at widths 2, 4, 6:")
        vals = {k: [med(rows8.get((kind, w))) for w in (2, 4, 6)] for k, kind in key.items()}
        for k, v in vals.items():
            out.append(f"// {k}: " + ", ".join("n/a" if x is None else f"{x / 1000:.1f}" for x in v))
        if all(x is not None for v in vals.values() for x in v):
            f = lambda v: "WidthCosts::new([" + ", ".join(f"us_f({x / 1000:.1f})" for x in v) + "])"
            out.append("pub fn linux_x86() -> Self {\n    DispatchCosts {\n        team: " + f(vals['team']) + ",\n        in_pool: " +
                       f(vals['in_pool']) + ",\n        outside: " + f(vals['outside']) + ",\n    }\n}")
        out.append("```\n")
        out.append("Width 8 against the model's proportional extrapolation above the last anchor (`cost(6) * 8 / 6`):\n")
        out.append("| kind | measured w=8 us | model us | ratio |")
        out.append("| --- | --- | --- | --- |")
        for k, kind in key.items():
            m8, m6 = med(rows8.get((kind, 8))), med(rows8.get((kind, 6)))
            if m8 and m6:
                out.append(f"| {k} | {m8 / 1000:.2f} | {m6 * 8 / 6 / 1000:.2f} | {m8 / (m6 * 8 / 6):.2f} |")
        out.append("")
        out.append("M5 row for comparison (`DispatchCosts::apple_m5`): team 3.0, 2.3, 1.4; in pool 6.0, 11, 5.5; outside 14, 18, 19.\n")
    # wake latency
    pat = re.compile(r"^\s*(\d+)\s+(team qos=builder-default|plain Exec::fork)\s+(\w+)\s+([\d.]+)\s+([\d.]+)\s+(\d+)%\s+([\d.]+)")
    wake = collections.defaultdict(list)
    for p in sorted(glob.glob(os.path.join(RAW, "wake-T*-p*.txt"))):
        T = re.search(r"wake-T(\d+)", p).group(1)
        for line in open(p):
            m = pat.match(line)
            if m:
                wake[(T, int(m.group(1)), m.group(2), m.group(3))].append(tuple(float(x) for x in m.groups()[3:]))
    if wake:
        out.append("## Wake latency after a park (`wake_probe`; microseconds, median over processes; parked = 12 ms pause with a 2 ms idle spin)\n")
        out.append("| pool | width | variant | state | total | slowest share start | late > 1 ms | max |")
        out.append("| --- | --- | --- | --- | --- | --- | --- | --- |")
        for (T, w, var, state), v in sorted(wake.items()):
            c = lambda i: med([x[i] for x in v])
            out.append(f"| {T} | {w} | {var} | {state} | {c(0):.1f} | {c(1):.1f} | {c(2):.0f}% | {c(3):.1f} |")
        out.append("")
    for p in sorted(glob.glob(os.path.join(RAW, "idle-trace-T*.txt"))):
        out.append(f"## Idle spin trace `{os.path.basename(p)}` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)\n")
        out.append("```\n" + open(p).read().strip() + "\n```\n")
    return "\n".join(out)


M5 = {  # thresholds.md 2.3: f64, c64
    "gemm_per_mac": (0.037, 0.165), "lu_full_pivot": (0.216, 0.600), "bunch_kaufman_full": (0.238, 0.380),
    "qr_col_pivot": (0.202, 0.713), "bidiag": (0.480, 1.36), "hessenberg_unblocked": (0.451, 1.57), "tridiag": (0.339, 1.16),
    "matvec_colmajor": (0.112, 0.281), "matvec_rowmajor": (0.087, 0.425), "householder_rank_one": (0.212, 0.725),
    "block_apply_per_mac": (0.037, 0.165), "triangular_matmul_per_mac": (0.039, 0.176), "triangular_solve_per_mac": (0.051, 0.187),
    "lu_partial_per_flop": (0.030, None),
}


def consts():
    rows = collections.defaultdict(list)
    for f in sorted(glob.glob(os.path.join(RAW, "consts-*.csv"))):
        for r in csv.DictReader(open(f)):
            rows[(r["name"], r["type"])].append((float(r["ns_per_unit"]), r["shape"]))
    out = ["## Serial throughput constants, 1 thread on core 4 (ns per unit; median over shapes and rounds)\n",
           "M5 = thresholds.md 2.3 (Apple M5 Max). ratio = Linux / M5.\n",
           "| family | type | median | range | cells | M5 | ratio |", "| --- | --- | --- | --- | --- | --- | --- |"]
    for (n, t), v in sorted(rows.items()):
        vals = [x[0] for x in v]
        m5 = M5.get(n)
        m5v = None if not m5 else (m5[0] if t == "f64" else m5[1] if t == "c64" else None)
        out.append(f"| {n} | {t} | {st.median(vals):.4f} | {min(vals):.4f} to {max(vals):.4f} | {len(vals)} | "
                   f"{'' if m5v is None else m5v} | {'' if m5v is None else f'{st.median(vals) / m5v:.2f}'} |")
    r2 = collections.defaultdict(list)
    for f in sorted(glob.glob(os.path.join(RAW, "rconsts-*.csv"))):
        for r in csv.DictReader(open(f)):
            r2[r["group"]].append((float(r["ns_per_unit"]), r["n"]))
    if r2:
        out += ["", "## Region constants (block apply streaming, divide and conquer solves, triangular inverse, sparse product)\n",
                "| group | median ns/unit | range | cells |", "| --- | --- | --- | --- |"]
        for g, v in sorted(r2.items()):
            vals = [x[0] for x in v]
            out.append(f"| {g} | {st.median(vals):.5f} | {min(vals):.5f} to {max(vals):.5f} | {len(vals)} |")
    return "\n".join(out)


def table(prefix_glob, modes=("seq", "plain_out", "plain_in", "team"), thr=0.95):
    cells = collections.defaultdict(lambda: collections.defaultdict(list))
    order = []
    for p in sorted(glob.glob(os.path.join(RAW, prefix_glob))):
        for r in csv.DictReader(open(p)):
            k = (r["family"], r["shape"])
            if k not in order:
                order.append(k)
            cells[k][r["mode"]].append(float(r["ns"]))
    out, fams, be = [], [], {}
    for k in order:
        if k[0] not in fams:
            fams.append(k[0])
    us = lambda x: f"{x / 1000:.2f}" if x < 1e5 else f"{x / 1000:.0f}"
    for f in fams:
        out.append(f"\n#### {f}\n")
        out.append("| shape | " + " | ".join(f"{m} us" for m in modes) + " | " + " | ".join(f"{m}/seq" for m in modes[1:]) + " | n |")
        out.append("|" + "---|" * (len(modes) * 2 + 1))
        rows = [k for k in order if k[0] == f]
        md = {}
        for k in rows:
            md[k] = {m: st.median(cells[k][m]) for m in modes if cells[k][m]}
            r = md[k]
            out.append(f"| {k[1]} | " + " | ".join(us(r[m]) for m in modes) + " | " + " | ".join(f"{r[m] / r['seq']:.2f}" for m in modes[1:]) + f" | {len(cells[k]['seq'])} |")
        for m in modes[1:]:
            idx = None
            for i in range(len(rows) - 1, -1, -1):
                r = md[rows[i]]
                if r[m] / r["seq"] < thr:
                    idx = i
                else:
                    break
            be[(f, m)] = (rows[idx][1], md[rows[idx]]["seq"]) if idx is not None else None
    out.append(f"\n#### break-even: first shape after which the mode stays below {thr} x serial (serial time there)\n")
    out.append("| family | " + " | ".join(modes[1:]) + " |")
    out.append("|" + "---|" * len(modes))
    for f in fams:
        out.append(f"| {f} | " + " | ".join((f"{be[(f, m)][0]} ({us(be[(f, m)][1])} us)" if be[(f, m)] else "none") for m in modes[1:]) + " |")
    return "\n".join(out)


def confirm():
    out = []
    for name, pat in (("strided, tcontract, cpueinsum chain", "confirm-T{}-p*.csv"), ("tlinalg batched small LU and QR", "tlinalg-T{}-p*.csv")):
        for W in (8, 4):
            if glob.glob(os.path.join(RAW, pat.format(W))):
                out.append(f"### {name}, width {W} (median over processes and rounds; ratios to serial, below 1 is a win)")
                out.append(table(pat.format(W)))
    return "\n".join(out)


def diag():
    out = ["## x86_64 GEMM path: which threads run the product (`fbench diag-gemm`)\n",
           "Per row and size: `participants` = distinct threads that took a share of 200 probe fan-outs through the row's own entry point "
           "(`spindle::for_each_raw` inside `with_lock` for held; Rayon `par_iter` for hot and free; `Team::run` for team, plus the leader); "
           "`busy` = of those, busy more than half of the wall time during the GEMM loop; `cpu participants / other` = on-CPU ms of the "
           "probed threads against all other threads of the process (other pool threads, e.g. the idle Rayon pool under the team row). "
           "A row whose work runs where its probe says has `cpu other` near 0; for lu/qr_factor/cholesky under the team row a non-zero `cpu other` / `busy other threads` is `private-gemm-x86` threading through spindle outside the team (`par.degree()` of a team token).\n",
           "| process | row | op+n | calls | per call ms | participants | busy | cpu participants ms | cpu other ms | busy other threads | team counters |",
           "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
    for p in sorted(glob.glob(os.path.join(RAW, "diag-gemm-*.csv"))):
        tag = os.path.basename(p)[:-4]
        lines = [l for l in open(p).read().splitlines() if not l.startswith("#") and l and not l.startswith("row,")]
        for r in csv.reader(lines):
            out.append(f"| {tag} | {r[0]} | {r[1]} | {r[3]} | {r[5]} | {r[6]} | {r[7]} | {r[8]} | {r[9]} | {r[11]} | {r[12]} |")
    return "\n".join(out)


def hosts():
    out = ["## Host protocol per process\n",
           "| process | mask | attempt | idle before | idle after | unmeasured-domain busy (max) | load1 before | top 3 before | governor | boost | EPP | platform profile |",
           "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
    path = os.path.join(RAW, "processes.log")
    if not os.path.exists(path):
        return ""
    for l in open(path):
        d = json.loads(l)
        h = d["host_before"]
        ib = "idle" if not any("busy=" in x and float(x.split("busy=")[1].split()[0]) > 0.05 for x in d["idle_before"]) else "BUSY"
        ia = "idle" if not any("busy=" in x and float(x.split("busy=")[1].split()[0]) > 0.05 for x in d["idle_after"]) else "BUSY"
        out.append(f"| {d['tag']} | {d['mask']} | {d['attempt']} | {ib} | {ia} | {d['during_unmeasured_domain_busy_max']} | {h['load'][0]:.2f} | "
                   f"{'; '.join(h['top3'])} | {','.join(h['governor'])} | {h['boost']} | {','.join(h['epp'])} | {h['platform_profile']} |")
    return "\n".join(out)


FUNCS = {"fbench": fbench, "dispatch": dispatch, "consts": consts, "confirm": confirm, "diag": diag, "hosts": hosts}


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    for name in (FUNCS if which == "all" else [which]):
        text = FUNCS[name]()
        if text:
            open(os.path.join(HERE, f"tables-{name}.md"), "w").write(text + "\n")
            print(text + "\n")


if __name__ == "__main__":
    main()
