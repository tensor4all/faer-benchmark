#!/usr/bin/env python3
"""Serial throughput constants (one thread, M5, QoS UserInitiated) with the host protocol: before every
process poll until idle >= 85 percent with no other cargo, rustc, fbench or test process; record idle, load
and the top 3 CPU consumers before and after; a process that starts or ends below 85 percent idle is `busy`."""
import json, os, re, subprocess, sys, time

IDLE_MIN = 85.0
GROUPS = ["gemm", "lu_full", "bk", "qr_cp", "bidiag", "hess", "tridiag", "matvec", "rank_one", "block_apply", "tri"]


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()


def cpu_idle():
    out = sh("top -l 2 -s 1 -n 0 | grep 'CPU usage' | tail -1")
    m = re.search(r"([\d.]+)% idle", out)
    return float(m.group(1)) if m else None


def top3():
    rows = sh("ps -Ao pcpu,comm -r | head -4 | tail -3").splitlines()
    return [" ".join([r.split(None, 1)[0], os.path.basename(r.split(None, 1)[1])]) for r in rows if r.strip()]


def others(me):
    bad = []
    for l in sh("ps -Ao pid,command").splitlines():
        pid, _, cmd = l.strip().partition(" ")
        if not pid.isdigit() or int(pid) in me:
            continue
        if re.search(r"(^|/)(fbench|consts|faer-[0-9a-f]+)( |$)|cargo (build|test|bench|check)|rustc ", cmd) and "grep" not in cmd:
            bad.append(cmd[:80])
    return bad


def main():
    binp, out, rounds = sys.argv[1], sys.argv[2], int(sys.argv[3])
    os.makedirs(os.path.join(out, "raw"), exist_ok=True)
    log = open(os.path.join(out, "processes.log"), "a")
    me = {os.getpid(), os.getppid()}
    for r in range(rounds):
        for g in GROUPS:
            tag = f"{g}-r{r}"
            csv = os.path.join(out, "raw", tag + ".csv")
            if os.path.exists(csv):
                continue
            waited, idle, bl = 0, None, []
            while True:
                bl = others(me)
                idle = cpu_idle()
                if not bl and idle is not None and idle >= IDLE_MIN:
                    break
                if waited >= 300:
                    break
                time.sleep(15)
                waited += 16
            before = {"idle": idle, "load": os.getloadavg()[0], "top3": top3(), "others": bl}
            t0 = time.time()
            res = subprocess.run([binp, g], capture_output=True, text=True)
            wall = time.time() - t0
            after = {"idle": cpu_idle(), "load": os.getloadavg()[0], "top3": top3()}
            busy = bool(bl) or idle is None or idle < IDLE_MIN or after["idle"] is None or after["idle"] < IDLE_MIN
            open(csv, "w").write(res.stdout)
            log.write(json.dumps({"tag": tag, "rc": res.returncode, "wall_s": round(wall, 1), "waited_s": waited,
                                  "before": before, "after": after, "busy": busy}) + "\n")
            log.flush()
            print(f"{tag}: rc={res.returncode} {wall:.0f}s idle_before={idle} after={after['idle']} busy={busy}", flush=True)


if __name__ == "__main__":
    main()
