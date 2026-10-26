#!/usr/bin/env python3
"""Run one measuring process under the host protocol: wait for idle >= 85 percent and no other
cargo, rustc, fbench or test process; log idle, load and top 3 before and after; mark busy.
usage: guarded.py TAG OUTFILE CMD..."""
import json, os, re, subprocess, sys, time
IDLE_MIN = 85.0
def sh(c): return subprocess.run(c, shell=True, capture_output=True, text=True).stdout.strip()
def idle():
    m = re.search(r"([\d.]+)% idle", sh("top -l 2 -s 1 -n 0 | grep 'CPU usage' | tail -1"))
    return float(m.group(1)) if m else None
def top3():
    return [" ".join([r.split(None, 1)[0], os.path.basename(r.split(None, 1)[1])]) for r in sh("ps -Ao pcpu,comm -r | head -4 | tail -3").splitlines() if r.strip()]
def others():
    bad = []
    for l in sh("ps -Ao pid,command").splitlines():
        pid, _, cmd = l.strip().partition(" ")
        if pid.isdigit() and int(pid) not in (os.getpid(), os.getppid()) and re.search(r"(^|/)(fbench|regions|consts)( |$)|cargo (build|test|bench|check)|rustc |faer-[0-9a-f]{8,}", cmd) and "grep" not in cmd and "guarded" not in cmd:
            bad.append(cmd[:80])
    return bad
tag, out, cmd = sys.argv[1], sys.argv[2], sys.argv[3:]
waited = 0
while True:
    bl, i = others(), idle()
    if not bl and i is not None and i >= IDLE_MIN: break
    if waited >= int(os.environ.get("MAXWAIT", "300")): break
    time.sleep(15); waited += 16
before = {"idle": i, "load": os.getloadavg(), "top3": top3(), "others": bl}
t0 = time.time()
r = subprocess.run(cmd, capture_output=True, text=True)
after = {"idle": idle(), "load": os.getloadavg(), "top3": top3()}
busy = bool(bl) or i is None or i < IDLE_MIN or after["idle"] is None or after["idle"] < IDLE_MIN
open(out, "w").write(r.stdout)
open(os.path.join(os.path.dirname(out), "..", "processes.log"), "a").write(json.dumps({"tag": tag, "cmd": cmd, "rc": r.returncode, "wall_s": round(time.time()-t0,1), "waited_s": waited, "before": before, "after": after, "busy": busy, "stderr": r.stderr[-300:]}) + "\n")
print(tag, "rc", r.returncode, "idle", i, "busy", busy, flush=True)
