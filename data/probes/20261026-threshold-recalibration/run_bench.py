#!/usr/bin/env python3
"""Rough M5 confirmation of the remaining gates (t4a-faer `exp/par-team-lifetime`): QR, Cholesky, SVD (values) and EVD (eigh)
at 128, 256 and 512, serial vs plain (called from outside the pool) vs team, before (9cd64f0) vs after (6788b20).

Host protocol (coordinator request): before every process, check that no other fbench, cargo or
test process is running and wait (poll every 20 s, up to --max-wait) until the machine is at least
85 percent idle; record idle, load average and the three top CPU consumers before and after;
sample idle every 25 s while the process runs. A process that starts below 85 percent idle after the
wait, or that sees a sample below it, is marked `busy` in processes.log and in the README tables.
Every cell is primed for 250 ms (`--prime-ms 250`) before it is timed, which covers the ~40 ms warm-up the
bimodal serial times need after an idle period (the pool and team sleep between cells, not within one).
"""
import argparse, json, os, re, subprocess, sys, threading, time

ROWS = ["faer-fork-free", "faer-fork-team"]
FAMS = "qr_factor,cholesky,svd_values,eigh"
SHAPES = "128,256,512"
# set name -> (family list, shapes, dtypes, reps, threads, rows)
SETS = {
    "par": (FAMS, SHAPES, "f64", 41, 6, ROWS),
    # one thread, the serial reference (rows with no parallel route)
    "serial": (FAMS, SHAPES, "f64", 41, 1, ["faer-fork"]),
}
IDLE_MIN = 85.0


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()


def cpu_usage():
    out = sh("top -l 2 -s 1 -n 0 | grep 'CPU usage' | tail -1")
    m = re.search(r"([\d.]+)% user, ([\d.]+)% sys, ([\d.]+)% idle", out)
    return float(m.group(3)) if m else None


def top3():
    rows = sh("ps -Ao pcpu,comm -r | head -4 | tail -3").splitlines()
    return [" ".join(r.split(None, 1)[0:1] + [os.path.basename(r.split(None, 1)[1])]) for r in rows if r.strip()]


def others_running(me):
    out = sh("ps -Ao pid,command").splitlines()
    bad = []
    for l in out:
        pid, _, cmd = l.strip().partition(" ")
        if not pid.isdigit() or int(pid) in me:
            continue
        if re.search(r"(^|/)(fbench|faer-[0-9a-f]+)( |$)|cargo (build|test|bench|check)|rustc ", cmd) and "grep" not in cmd:
            bad.append(cmd[:80])
    return bad


class During(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True)
        self.samples, self.stop = [], threading.Event()

    def run(self):
        while not self.stop.wait(25):
            u = cpu_usage()
            self.samples.append((round(time.time()), u, round(os.getloadavg()[0], 2)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", action="append", required=True, help="label=path")
    ap.add_argument("--out", required=True)
    ap.add_argument("--max-wait", type=int, default=240)
    ap.add_argument("--plan", required=True, help="label:set:rot,...")
    args = ap.parse_args()
    bins = dict(b.split("=", 1) for b in args.bin)
    os.makedirs(args.out, exist_ok=True)
    log = open(os.path.join(args.out, "processes.log"), "a")
    me = {os.getpid(), os.getppid()}
    for item in args.plan.split(","):
        label, name, rot = item.split(":")
        rot = int(rot)
        fam, shapes, dtypes, reps, threads, rows0 = SETS[name]
        rows = rows0[rot % len(rows0):] + rows0[:rot % len(rows0)]
        tag = f"{label}-{name}-T{threads}-rot{rot}"
        csv = os.path.join(args.out, "raw", tag + ".csv")
        os.makedirs(os.path.dirname(csv), exist_ok=True)
        if os.path.exists(csv):
            continue
        waited, seen, blockers = 0, [], []
        while True:
            blockers = others_running(me)
            u = cpu_usage()
            seen.append(u)
            if not blockers and u is not None and u >= IDLE_MIN:
                break
            if waited >= args.max_wait:
                break
            time.sleep(20)
            waited += 21
        busy_start = bool(blockers) or seen[-1] is None or seen[-1] < IDLE_MIN
        before = {"idle": seen[-1], "load": os.getloadavg(), "top3": top3(), "others": blockers}
        cmd = [bins[label], "run", "--threads", str(threads), "--n", shapes, "--family", fam, "--dtype", dtypes,
               "--rows", ",".join(rows), "--rotate-rows", "0", "--orders", "F", "--reps", str(reps), "--prime-ms", "250",
               "--statistic", "median", "--regime", f"threshold-recal-{name}", "--check-max-dim", "128"]
        env = dict(os.environ, FBENCH_QOS="user-initiated")
        d = During(); d.start()
        t0 = time.time()
        r = subprocess.run(cmd + ["--csv", csv], capture_output=True, text=True, env=env)
        t1 = time.time()
        d.stop.set()
        after = {"idle": cpu_usage(), "load": os.getloadavg(), "top3": top3()}
        during_idle = [s[1] for s in d.samples if s[1] is not None]
        busy = busy_start or any(i < IDLE_MIN for i in during_idle) or (after["idle"] is not None and after["idle"] < IDLE_MIN)
        qos = [l for l in r.stderr.splitlines() if l.startswith("qos.")]
        log.write(json.dumps({"tag": tag, "cmd": cmd[1:], "rc": r.returncode, "wall_s": round(t1 - t0, 1), "waited_s": waited,
                              "idle_polls": seen, "before": before, "during": d.samples, "after": after, "busy": busy,
                              "qos": qos, "stderr": "\n".join(l for l in r.stderr.splitlines() if not l.startswith("qos."))[-300:]}) + "\n")
        log.flush()
        print(f"{tag}: rc={r.returncode} {t1 - t0:.0f}s waited={waited}s idle_before={before['idle']} during_min={min(during_idle) if during_idle else None} "
              f"after={after['idle']} load={os.getloadavg()[0]:.2f} busy={busy}", flush=True)


if __name__ == "__main__":
    main()
