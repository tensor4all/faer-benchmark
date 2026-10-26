#!/usr/bin/env python3
"""Driver of the Linux acceptance measurement of tensor4all-meta#51 (awake-team design).

    run_awake.py PHASE [--dry-run] [--only SUBSTR] [--out DIR] [--bins exec]
    PHASE: a  threadteam dispatch cost per token kind, wake latency, idle spin trace
           b  serial throughput constants at 1 thread (f64/c64, GEMM also f32/c32)
           c  fbench stage comparisons (rows held/upstream/hot/free/team) at 4T and 8T, dispatch, smallops
           d  strided / tcontract / cpueinsum / tlinalg confirmation sweeps
           e  x86_64 GEMM path diagnostic (which threads run the GEMM under each row)
           verify  untimed fbench correctness check (a few seconds)
           all  a b c d e in this order (verify first)

Every process goes through hostguard.run_guarded (taskset mask, idle guard on the whole measured L3 domain
before and after, no other build/test process, boost off, scrubbed thread environment, raw/processes.log).
`--dry-run` prints the planned process list with estimated wall time and runs nothing (no guard, no sleeping).
Run it under the observer mask:  taskset -c 0-3,12-15 python3 run_awake.py c

`--bins exec2`: the same for the *-exec2 binaries (build_exec2.sh: faer 7e0f98f, threadteam 7095893, kernel 212cacf) and raw-exec2/.
`--bins exec3`: the same for the *-exec3 binaries (build_exec3.sh: faer 9f92e5c, threadteam 0036264, kernel 212cacf, strided-rs 5da0ef3, fbench svd_values/eigh/svd_thin/triangular_solve on the explicit Par) and raw-exec3/.
`--bins exec`: the *-exec binaries (target-bench/{fbench,tt,tt-trace,consts,stack}-exec) and raw-exec/ instead of raw/.

Resume: a process whose tag is already in raw/processes.log with busy=false is skipped.
"""
import argparse, json, os, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import hostguard as hg

ROOT = HERE.parents[3]                      # .../awake-team-linux
def bin_table(suffix):
    """Binary paths; suffix "" = acceptance run (target-bench/<dir>), "exec" = target-bench/<dir>-exec."""
    d = (lambda n: n + "-" + suffix) if suffix else (lambda n: n)
    t = ROOT / "target-bench"
    return {
        "fbench": t / d("fbench") / "release/fbench",
        "dispatch_cost": t / d("tt") / "release/dispatch_cost",
        "wake_probe": t / d("tt") / "release/wake_probe",
        "idle_trace": t / d("tt-trace") / "release/idle_trace",
        "consts": t / d("consts") / "release/consts",
        "regions_consts": t / d("consts") / "release/regions_consts",
        "thr-confirm": t / d("stack") / "release/thr-confirm",
        "tl-probe": t / d("stack") / "release/tl-probe",
    }


BIN = bin_table(os.environ.get("AWAKE_BINS", ""))   # --bins overrides (main); phase functions read this global
ROWS = ["faer-fork", "faer-upstream", "faer-fork-hot", "faer-fork-free", "faer-fork-team"]   # held, upstream (held), hot, free, team
NROT = len(ROWS)   # one rotation per row position: every row takes every position once
GUARD_S = 25   # idle checks (2 x 3 s), host state, startup, per process

# --- fbench sets (phase c). (name, families, shapes, reps, check-max-dim, rotations)
FAMS = "gemm,lu,qr_factor,cholesky,svd_values,eigh"
SETS = [
    ("small", FAMS, "128,256,512", 41, 512, NROT),
    ("n1024", FAMS, "1024", 21, 0, NROT),
    ("n2048", FAMS, "2048", 9, 0, NROT),
    ("skinny", "gemm", "4096x64x64,64x4096x64,2048x2048x64", 31, 0, NROT),
]
# best-row time of one call in ms at the M5 6T (data of the par-team-lifetime probe; svd/eigh scaled from the recalibration
# probe); used only for the wall-time estimate: host factor 1.3 per core, 5 rows cost about 4.4 best rows.
BASE_MS = {
    "gemm": {128: .04, 256: .17, 512: .85, 1024: 7.1, 2048: 60},
    "lu": {128: .08, 256: .3, 512: 1.13, 1024: 5.4, 2048: 35},
    "qr_factor": {128: .15, 256: .5, 512: 1.8, 1024: 8.8, 2048: 59},
    "cholesky": {128: .03, 256: .1, 512: .46, 1024: 2.5, 2048: 18.4},
    "svd_values": {128: .76, 256: 4.1, 512: 23, 1024: 190, 2048: 1500},
    "eigh": {128: .85, 256: 3.1, 512: 14, 1024: 100, 2048: 800},
}
SKINNY_MS = {"4096x64x64": .2, "64x4096x64": .2, "2048x2048x64": 7.0}


class P:
    def __init__(self, tag, cmd, mask, est, stdout=None, outputs=(), env=None):
        self.tag, self.cmd, self.mask, self.est = tag, [str(c) for c in cmd], mask, est
        self.stdout, self.outputs, self.env = stdout, outputs, env or {}


def raw(out, name):
    return str(Path(out) / hg.RAWNAME / name)


NROW = len(ROWS)


def est_fbench_set(threads, fams, shapes, reps):
    s = 1.3 * 6 / threads
    total = 0.0
    for shape in shapes.split(","):
        if "x" in shape:
            n = shape
            for fam in fams.split(","):
                total += NROW * 0.5 + 4.4 * s * SKINNY_MS[shape] * reps / 1000
            continue
        n = int(shape)
        for fam in fams.split(","):
            base = BASE_MS[fam][n]
            construct = 0.3 + (2.0 if n >= 2048 else 0.0)
            total += NROW * (construct + 0.25) + 4.4 * s * base * reps / 1000
    return total


def phase_a(out):
    ps = []
    for i in (1, 2, 3):   # pool of 8 on the 8T mask: widths 2,4,6,8 (6 = the WidthCosts anchor)
        ps.append(P(f"dispatch-T8-p{i}", [BIN["dispatch_cost"], raw(out, f"dispatch-T8-p{i}.csv")], hg.MASKS[8], 120,
                    stdout=raw(out, f"dispatch-T8-p{i}.txt"), outputs=[raw(out, f"dispatch-T8-p{i}.csv")],
                    env={"TT_POOL": "8", "TT_WIDTHS": "2,4,6,8"}))
    for i in (1, 2, 3):   # pool of 4 on the 4T mask: widths 2,4
        ps.append(P(f"dispatch-T4-p{i}", [BIN["dispatch_cost"], raw(out, f"dispatch-T4-p{i}.csv")], hg.MASKS[4], 60,
                    stdout=raw(out, f"dispatch-T4-p{i}.txt"), outputs=[raw(out, f"dispatch-T4-p{i}.csv")],
                    env={"TT_POOL": "4", "TT_WIDTHS": "2,4"}))
    for i in (1, 2):
        ps.append(P(f"wake-T8-p{i}", [BIN["wake_probe"]], hg.MASKS[8], 40, stdout=raw(out, f"wake-T8-p{i}.txt"),
                    env={"TT_WIDTHS": "2,4,8"}))
    ps.append(P("wake-T4-p1", [BIN["wake_probe"]], hg.MASKS[4], 25, stdout=raw(out, "wake-T4-p1.txt"), env={"TT_WIDTHS": "2,4"}))
    ps.append(P("idle-trace-T8", [BIN["idle_trace"], "200"], hg.MASKS[8], 30, stdout=raw(out, "idle-trace-T8.txt"), env={"TT_POOL": "8"}))
    ps.append(P("idle-trace-T4", [BIN["idle_trace"], "200"], hg.MASKS[4], 30, stdout=raw(out, "idle-trace-T4.txt"), env={"TT_POOL": "4"}))
    return ps


def phase_b(out):
    ps = []
    groups = ["gemm", "lu_partial", "lu_full", "bk", "qr_cp", "bidiag", "hess", "tridiag", "matvec", "rank_one", "block_apply", "tri"]
    for r in (0, 1):
        for g in groups:
            ps.append(P(f"consts-{g}-r{r}", [BIN["consts"], g], hg.MASKS[1], 25 if g != "gemm" else 40,
                        stdout=raw(out, f"consts-{g}-r{r}.csv")))
        for g in ("bsvd", "tevd", "tinv", "spmm"):
            ps.append(P(f"rconsts-{g}-r{r}", [BIN["regions_consts"], "consts", g], hg.MASKS[1], 30,
                        stdout=raw(out, f"rconsts-{g}-r{r}.csv")))
    return ps


def phase_c(out):
    ps = [P("fbench-verify-T8", [BIN["fbench"], "verify", "--threads", "8", "--n", "128,256", "--family", FAMS, "--dtype", "f64",
                                 "--orders", "F", "--rows", ",".join(ROWS)], hg.MASKS[8], 30,
            stdout=raw(out, "fbench-verify-T8.txt"))]
    for T in (4, 8):
        mask = hg.MASKS[T]
        for name, fams, shapes, reps, chk, nrot in SETS:
            for rot in range(nrot):
                csv = raw(out, f"main-{name}-T{T}-rot{rot}.csv")
                cmd = [BIN["fbench"], "run", "--threads", T, "--n", shapes, "--family", fams, "--rows", ",".join(ROWS),
                       "--rotate-rows", rot, "--orders", "F", "--reps", reps, "--prime-ms", 250, "--statistic", "median",
                       "--regime", f"awake-linux-{name}", "--check-max-dim", chk, "--csv", csv]
                ps.append(P(f"main-{name}-T{T}-rot{rot}", cmd, mask, GUARD_S + est_fbench_set(T, fams, shapes, reps), outputs=[csv]))
        for rot in range(NROT):   # smallops and dispatch order the rows as listed
            rows = ROWS[rot:] + ROWS[:rot]
            csv = raw(out, f"smallops-seq-T{T}-rot{rot}.csv")
            ps.append(P(f"smallops-seq-T{T}-rot{rot}", [BIN["fbench"], "smallops", "--threads", T, "--rows", ",".join(rows), "--reps", 41, "--csv", csv],
                        mask, GUARD_S + 75, outputs=[csv], env={"FBENCH_SETTLE_MS": "300"}))
        for rot in range(NROT):
            rows = ROWS[rot:] + ROWS[:rot]
            csv = raw(out, f"dispatch-fbench-T{T}-rot{rot}.csv")
            ps.append(P(f"dispatch-fbench-T{T}-rot{rot}", [BIN["fbench"], "dispatch", "--threads", T, "--rows", ",".join(rows), "--reps", 10, "--csv", csv],
                        mask, GUARD_S + 62, outputs=[csv]))
    return ps


def phase_d(out):
    ps = []
    for W, nproc in ((8, 2), (4, 1)):
        for i in range(1, nproc + 1):
            ps.append(P(f"confirm-T{W}-p{i}", [BIN["thr-confirm"], 2, W], hg.MASKS[W], 230, stdout=raw(out, f"confirm-T{W}-p{i}.csv")))
            ps.append(P(f"tlinalg-T{W}-p{i}", [BIN["tl-probe"], 2, W], hg.MASKS[W], 150, stdout=raw(out, f"tlinalg-T{W}-p{i}.csv")))
    return ps


def phase_e(out):
    ps = []
    for T, nproc in ((8, 2), (4, 1)):
        for i in range(1, nproc + 1):
            rot = 2 * (i - 1)   # the two 8T passes start at different row positions (a diagnostic of thread use, not a timing)
            rows = ROWS[rot:] + ROWS[:rot]
            ps.append(P(f"diag-gemm-T{T}-p{i}", [BIN["fbench"], "diag-gemm", "--threads", T, "--family", "gemm,lu,qr_factor,cholesky", "--n", "512,1024", "--reps", 3,
                                                 "--rows", ",".join(rows)], hg.MASKS[T], GUARD_S + 100,
                        stdout=raw(out, f"diag-gemm-T{T}-p{i}.csv")))
    return ps


PHASES = {"a": phase_a, "b": phase_b, "c": phase_c, "d": phase_d, "e": phase_e}


def done_tags(out):
    path = Path(out) / hg.RAWNAME / "processes.log"
    tags = set()
    if path.exists():
        for line in path.read_text().splitlines():
            try:
                d = json.loads(line)
            except ValueError:
                continue
            if d.get("busy") is False and d.get("rc") == 0:
                tags.add(d["tag"])
    return tags


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("phase", choices=list(PHASES) + ["verify", "all"])
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--only", default="", help="run only processes whose tag contains this text")
    ap.add_argument("--out", default=str(HERE))
    ap.add_argument("--bins", default=os.environ.get("AWAKE_BINS", ""), choices=["", "exec", "exec2", "exec3"],
                    help="binary set: '' = target-bench/<dir> (acceptance run, output raw/); exec = target-bench/<dir>-exec "
                         "(team-gemm-executor build, output raw-exec/; log it with `| tee run-exec.log`)")
    a = ap.parse_args()
    BIN.clear(); BIN.update(bin_table(a.bins))
    hg.RAWNAME = "raw-" + a.bins if a.bins else "raw"
    phases = list(PHASES) if a.phase == "all" else ([] if a.phase == "verify" else [a.phase])
    plan = []
    for ph in phases:
        plan += [(ph, p) for p in PHASES[ph](a.out)]
    if a.phase in ("verify", "all"):
        plan = [("c", p) for p in phase_c(a.out) if p.tag == "fbench-verify-T8"] + [x for x in plan if x[1].tag != "fbench-verify-T8"]
    plan = [(ph, p) for ph, p in plan if a.only in p.tag]
    if not a.dry_run:
        for name, path in BIN.items():
            if not Path(path).exists() and any(name in " ".join(p.cmd) for _, p in plan):
                raise SystemExit(f"missing binary {path}: run build_all.sh")
        Path(a.out, hg.RAWNAME).mkdir(parents=True, exist_ok=True)
        done = done_tags(a.out)
    total = {}
    if a.dry_run:
        print(f"planned processes (mask = taskset -c; observer {hg.OBSERVER}; guard domain {hg.DOMAIN}):")
    for ph, p in plan:
        if a.dry_run:
            hg.run_guarded(p.tag, p.cmd, p.mask, a.out, dry_run=True)
            print(f"{'':36}est {p.est:6.0f} s  env {p.env or ''}")
        elif p.tag in done:
            print(f"{p.tag}: already done, skipping")
        else:
            hg.run_guarded(p.tag, p.cmd, p.mask, a.out, stdout_file=p.stdout, outputs=p.outputs, env_extra=p.env)
        total[ph] = total.get(ph, 0) + p.est
    if a.dry_run:
        for ph, t in total.items():
            print(f"phase {ph}: {len([1 for q, _ in plan if q == ph])} processes, estimated {t / 60:.0f} min")
        print(f"total estimated {sum(total.values()) / 60:.0f} min ({sum(total.values()) / 3600:.1f} h), plus guard retries")


if __name__ == "__main__":
    main()
