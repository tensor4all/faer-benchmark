#!/usr/bin/env python3
"""Stage 1 of tensor4all/faer-benchmark#24 on an Apple M5 Max (macOS, aarch64).

One invocation records everything under --out: identity.json (revisions, host, build), one CSV
per process, a load log, and the machine-state lines before and after every process. It does not
use scripts/record_run.py, which needs taskset, the idle guard and boost control (Linux only).

Variant for the quiet host baseline (6 threads, QOS_CLASS_USER_INITIATED): the harness is run with
FBENCH_QOS=user-initiated, the `qos.*` stderr lines of every process are kept in processes.log,
4096 is not run, and the runner aborts when the host stays busy for more than --max-wait seconds.

Rows (`faer-fork` held spindle group, `faer-fork-hot` awake Rayon team, `faer-fork-free` nothing)
are interleaved inside every process, one cell after another, and the row order rotates between
processes (`--rotate-rows 0,1,2`), so a full rotation of the three rows is taken for every cell.
The outer loop is the rotation, then the thread count, so the three rotations of one thread count
are separated by the other thread counts' runs.
"""
import argparse, hashlib, json, os, re, subprocess, sys, threading, time

ROWS = ["faer-fork", "faer-fork-hot", "faer-fork-free"]
SETS = {
    # name: (families, shapes, reps, prime_ms, extra)
    "small": ("gemm,lu,qr_factor,cholesky", "256,512", 41, 250, []),
    "large": ("gemm,lu,qr_factor,cholesky", "1024,2048", 15, 250, ["--check-max-dim", "1024"]),
    "skinny": ("gemm", "4096x64x64,64x4096x64,2048x2048x64", 31, 250, ["--check-max-dim", "1024"]),
    "gemm4096": ("gemm", "4096", 7, 250, ["--check-max-dim", "1024"]),
}
LARGE_REPS_1T = 9  # the 1 thread serial reference: fewer repetitions of 1024/2048 (the three rows take one path)


def sh(cmd, **kw):
    return subprocess.run(cmd, shell=isinstance(cmd, str), capture_output=True, text=True, **kw).stdout.strip()


def cpu_usage():
    """One instantaneous 'CPU usage' line from top (second sample of two, one second apart)."""
    out = sh("top -l 2 -s 1 -n 0 | grep 'CPU usage' | tail -1")
    m = re.search(r"([\d.]+)% user, ([\d.]+)% sys, ([\d.]+)% idle", out)
    return (float(m.group(1)), float(m.group(2)), float(m.group(3))) if m else None


def load1():
    return os.getloadavg()[0]


class Sampler(threading.Thread):
    def __init__(self, path, period=30):
        super().__init__(daemon=True)
        self.path, self.period, self.stop = path, period, threading.Event()

    def run(self):
        new = not os.path.exists(self.path)
        with open(self.path, "a") as f:
            if new:
                f.write("unix_time,load1,user_pct,sys_pct,idle_pct,note\n")
            while not self.stop.is_set():
                u = cpu_usage() or (float("nan"),) * 3
                f.write(f"{time.time():.0f},{load1():.2f},{u[0]},{u[1]},{u[2]},\n")
                f.flush()
                self.stop.wait(self.period)


def wait_quiet(max_wait, idle_min):
    """Wait until the machine (outside our process) is at least idle_min % idle."""
    waited, seen = 0, []
    while True:
        u = cpu_usage()
        seen.append(u[2] if u else None)
        if u and u[2] >= idle_min:
            return waited, seen
        if waited >= max_wait:
            raise SystemExit(f"ABORT: host stayed below {idle_min}% idle for {waited} s: {seen}")
        time.sleep(20)
        waited += 21


def identity(args, binary):
    fork = args.fork
    cl = open(os.path.join(args.repo, "Cargo.lock")).read()
    def ver(n):
        m = re.search(r'name = "%s"\nversion = "([^"]+)"' % re.escape(n), cl)
        return m.group(1) if m else None
    git = lambda d, *a: sh(["git", "-C", d, *a])
    return {
        "date": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "harness": {"repo": args.repo, "commit": git(args.repo, "rev-parse", "HEAD"),
                    "dirty": bool(git(args.repo, "status", "--porcelain", "--untracked-files=no")),
                    "branch": git(args.repo, "rev-parse", "--abbrev-ref", "HEAD")},
        "library": {"checkout": fork, "commit": git(fork, "rev-parse", "HEAD"),
                    "dirty": bool(git(fork, "status", "--porcelain", "--untracked-files=no")),
                    "branch": git(fork, "rev-parse", "--abbrev-ref", "HEAD"),
                    "parents": git(fork, "log", "-1", "--format=%P").split(),
                    "version": re.search(r'^version = "([^"]+)"', open(os.path.join(fork, "faer/Cargo.toml")).read(), re.M).group(1)},
        "dependencies": {k: ver(k) for k in ["spindle", "gemm", "gemm-common", "gemm-f64", "rayon", "rayon-core", "libc", "nano-gemm", "pulp"]},
        "build": {"features": "faer-only", "profile": "release", "rustc": sh("rustc -vV").splitlines()[:3],
                  "binary": binary, "sha256": hashlib.sha256(open(binary, "rb").read()).hexdigest()},
        "host": {"uname": sh("uname -a"), "sw_vers": sh("sw_vers").splitlines(),
                 "cpu": sh("sysctl -n machdep.cpu.brand_string"), "model": sh("sysctl -n hw.model"),
                 "perflevels": {n: {"name": sh(f"sysctl -n hw.perflevel{n}.name"),
                                    "logical": int(sh(f"sysctl -n hw.perflevel{n}.logicalcpu")),
                                    "l2_per_cluster_bytes": int(sh(f"sysctl -n hw.perflevel{n}.l2cachesize")),
                                    "cpus_per_l2": int(sh(f"sysctl -n hw.perflevel{n}.cpusperl2"))} for n in (0, 1)},
                 "power": sh("pmset -g batt").splitlines()[:2], "thermal": sh("pmset -g therm").splitlines()[:3]},
        "protocol": {"pinning": "none (macOS)", "boost": "not controlled", "qos": "FBENCH_QOS=user-initiated (QOS_CLASS_USER_INITIATED 0x19 on the main thread and every Rayon worker)", "large_reps_1t": LARGE_REPS_1T, "rows": ROWS,
                     "rotations": args.rotations, "threads": args.threads, "sets": {k: {"families": v[0], "shapes": v[1], "reps": v[2], "prime_ms": v[3], "extra": v[4]} for k, v in SETS.items()},
                     "orders": "F", "statistic": "median over samples_ms",
                     "idle_wait": {"idle_min_pct": args.idle_min, "max_wait_s": args.max_wait}},
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--fork", required=True)
    ap.add_argument("--binary", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--threads", default="1,6,12,18")
    ap.add_argument("--rotations", default="0,1,2")
    ap.add_argument("--sets", default="small,large,skinny,gemm4096")
    ap.add_argument("--dispatch", action="store_true", help="also run the dispatch probe")
    ap.add_argument("--idle-min", type=float, default=92.0)
    ap.add_argument("--max-wait", type=int, default=240)
    args = ap.parse_args()
    args.threads = [int(t) for t in args.threads.split(",")]
    args.rotations = [int(r) for r in args.rotations.split(",")]
    os.makedirs(args.out, exist_ok=True)
    n = len([f for f in os.listdir(args.out) if f.startswith("identity")])
    json.dump(identity(args, args.binary), open(os.path.join(args.out, "identity.json" if n == 0 else f"identity-{n + 1}.json"), "w"), indent=2)
    sampler = Sampler(os.path.join(args.out, "load.csv"))
    sampler.start()
    log = open(os.path.join(args.out, "processes.log"), "a")

    def record(tag, cmd):
        csv = os.path.join(args.out, tag + ".csv")
        if os.path.exists(csv):
            print("skip (exists)", tag)
            return
        waited, seen = wait_quiet(args.max_wait, args.idle_min)
        t0, l0, u0 = time.time(), load1(), cpu_usage()
        env = dict(os.environ, FBENCH_QOS="user-initiated")
        r = subprocess.run(cmd + ["--csv", csv], capture_output=True, text=True, env=env)
        qos = [l for l in r.stderr.splitlines() if l.startswith("qos.")]
        t1, l1, u1 = time.time(), load1(), cpu_usage()
        log.write(json.dumps({"tag": tag, "cmd": cmd, "rc": r.returncode, "start": t0, "end": t1, "wall_s": t1 - t0,
                              "waited_s": waited, "idle_before": seen, "load1_before": l0, "load1_after": l1,
                              "cpu_before": u0, "cpu_after": u1, "qos": qos, "stderr": "\n".join(l for l in r.stderr.splitlines() if not l.startswith("qos."))[-400:]}) + "\n")
        log.flush()
        print(f"{tag}: rc={r.returncode} {t1 - t0:.0f}s waited={waited}s idle={seen[-1]} load1={l1:.2f}", flush=True)

    for rot in args.rotations:
        order = ROWS[rot % 3:] + ROWS[:rot % 3]
        for t in args.threads:
            for name in args.sets.split(","):
                fam, shapes, reps, prime, extra = SETS[name]
                if name == "large":
                    reps = LARGE_REPS_1T
                record(f"{name}-T{t}-rot{rot}",
                       [args.binary, "run", "--threads", str(t), "--n", shapes, "--family", fam,
                        "--rows", ",".join(ROWS), "--rotate-rows", str(rot), "--orders", "F",
                        "--reps", str(reps), "--prime-ms", str(prime), "--statistic", "median",
                        "--regime", f"stage1-{name}"] + extra)
            if args.dispatch and t > 1:
                record(f"dispatch-T{t}-rot{rot}",
                       [args.binary, "dispatch", "--threads", str(t), "--rows", ",".join(order), "--reps", "15"])
    sampler.stop.set()
    json.dump({"finished": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "load1": load1(), "sets": args.sets, "threads": args.threads, "rotations": args.rotations},
              open(os.path.join(args.out, f"finished-{int(time.time())}.json"), "w"))


if __name__ == "__main__":
    main()
