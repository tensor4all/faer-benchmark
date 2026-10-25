#!/usr/bin/env python3
"""Rough M5 run of the stage 2 families and the small-operation sequences on `Par<'team>`
(t4a-faer `exp/par-team-lifetime`), 6 threads, QoS UserInitiated.

Host protocol (coordinator request): before every process, check that no other fbench, cargo or
test process is running and wait (poll every 20 s, up to --max-wait) until the machine is at least
85 percent idle; record idle, load average and the three top CPU consumers before and after;
sample idle every 25 s while the process runs. A process that starts below 85 percent idle after the
wait, or that sees a sample below it, is marked `busy` in processes.log and in the README tables.
`FBENCH_SETTLE_MS=300` makes the leader sleep before each small-operation sequence.
"""
import argparse, json, os, re, subprocess, sys, threading, time

ROWS = ["faer-fork", "faer-fork-hot", "faer-fork-free", "faer-fork-team"]
SETS = {
    "small": ("gemm,lu,qr_factor,cholesky", "512", 41, 250, []),
    "large": ("gemm,lu,qr_factor,cholesky", "1024,2048", 15, 250, ["--check-max-dim", "1024"]),
    "skinny": ("gemm", "4096x64x64,64x4096x64,2048x2048x64", 31, 250, ["--check-max-dim", "1024"]),
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
    ap.add_argument("--binary", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--threads", type=int, default=6)
    ap.add_argument("--max-wait", type=int, default=240)
    ap.add_argument("--plan", default="main:small:0,main:skinny:0,small:small:2,main:skinny:2,main:large:0,smallops::0,smallops::2")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    log = open(os.path.join(args.out, "processes.log"), "a")
    me = {os.getpid(), os.getppid()}
    for item in args.plan.split(","):
        kind, name, rot = item.split(":")
        rot = int(rot)
        rows = ROWS[rot % 4:] + ROWS[:rot % 4]
        tag = f"{kind}-{name or 'seq'}-T{args.threads}-rot{rot}"
        csv = os.path.join(args.out, tag + ".csv")
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
        if kind == "main":
            fam, shapes, reps, prime, extra = SETS[name]
            cmd = [args.binary, "run", "--threads", str(args.threads), "--n", shapes, "--family", fam, "--rows", ",".join(rows),
                   "--rotate-rows", "0", "--orders", "F", "--reps", str(reps), "--prime-ms", str(prime), "--statistic", "median",
                   "--regime", f"par-team-{name}"] + extra
        else:
            cmd = [args.binary, "smallops", "--threads", str(args.threads), "--rows", ",".join(rows), "--reps", "41"]
        env = dict(os.environ, FBENCH_QOS="user-initiated", FBENCH_SETTLE_MS="300")
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
