#!/usr/bin/env python3
"""Host protocol of the Linux acceptance run (tensor4all-meta#51), one process at a time.

Replaces the macOS pieces of the M5 runners (QoS, `top` polling, idle >= 85 percent) with the frozen
protocol of docs/protocol-v2-baseline.md and the semantics of benchmarks/scripts/pinned.sh and idle_cpus.py:

* the measured process is pinned with `taskset -c <mask>` (1T: 4, 4T: 4-7, 8T: 4-11); the runner itself
  (the observer) must sit on the other L3 domain, 0-3,12-15 (refused otherwise);
* before every process the whole measured L3 domain (4-11,16-23: the cache peers of the mask) must be idle
  (`idle_cpus.py check`, 3 s window, max_busy 0.05); after the process again. A rejected attempt is
  archived under raw/rejected/ and retried (up to 8 attempts, 30 s apart), never selected;
* no cargo, rustc, cc, test or benchmark process may be running (any process of this family, whoever
  started it); the runner waits like it does for a busy domain;
* CPU boost must be off (`/sys/devices/system/cpu/cpufreq/boost` is 0), else refusal unless FBENCH_ALLOW_BOOST=1;
* the measured process gets a scrubbed environment (no RAYON_NUM_THREADS, OMP_*, MKL_*, ...): the thread budget
  is passed explicitly on its command line;
* per process, one JSON line in raw/processes.log: affinity masks (requested, and read back from the child),
  idle-guard output before and after, load average, the three top CPU consumers, governor, boost, EPP,
  platform profile, a during-run sample of the CPUs of the domain that are not measured, every attempt.

`dry_run=True` only prints the command a process would run.
"""
import json, os, re, shlex, subprocess, sys, threading, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
IDLE_SCRIPT = HERE.parents[2] / "benchmarks" / "scripts" / "idle_cpus.py"   # faer-benchmark/benchmarks/scripts
DOMAIN = "4-11,16-23"          # the measured L3 domain (whole domain is guarded)
OBSERVER = "0-3,12-15"         # the other L3 domain
MASKS = {1: "4", 4: "4-7", 8: "4-11"}
RAWNAME = "raw"                # raw directory under out_dir; run_awake.py --bins exec sets "raw-exec"
IDLE_SECONDS, MAX_BUSY, RETRIES, WAIT = 3, 0.05, 8, 30
DURING_INTERVAL, DURING_REJECT = 10.0, 0.20   # busy fraction of an unmeasured domain CPU that rejects a run
SCRUB = re.compile(r"^(RAYON_NUM_THREADS|OMP_.*|GOMP_.*|KMP_.*|MKL_.*|OPENBLAS_.*|GOTO_NUM_THREADS|BLIS_.*|"
                   r"VECLIB_MAXIMUM_THREADS|NUMEXPR_.*|FBENCH_QOS|TLINALG_BENCH_THREADS|TT_.*)$")
BLOCKERS = re.compile(r"(^|/)(cargo|rustc|cc1|cc1plus|lld|ld|clang|gcc|fbench|consts|regions_consts|"
                      r"thr-confirm|tl-probe|tl-team-diag|qr128(-[a-z0-9]+)?|dispatch_cost|wake_probe|idle_trace|faer-[0-9a-f]{8,}|"
                      r"[a-z_0-9]+-[0-9a-f]{16})( |$)")


def parse_cpus(text):
    out = []
    for part in text.split(","):
        if "-" in part:
            a, b = part.split("-")
            out += range(int(a), int(b) + 1)
        elif part:
            out.append(int(part))
    return out


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()


def rd(path):
    try:
        return Path(path).read_text().strip()
    except OSError:
        return None


def boost():
    return rd("/sys/devices/system/cpu/cpufreq/boost")


def host_state(mask):
    cpus = parse_cpus(mask)
    base = "/sys/devices/system/cpu/cpufreq/policy{}/{}"
    gov = sorted({rd(base.format(c, "scaling_governor")) or "?" for c in cpus})
    epp = sorted({rd(base.format(c, "energy_performance_preference")) or "?" for c in cpus})
    freq = {c: rd(base.format(c, "scaling_cur_freq")) for c in cpus[:4]}
    return {"boost": boost(), "governor": gov, "epp": epp, "platform_profile": rd("/sys/firmware/acpi/platform_profile"),
            "pstate_status": rd("/sys/devices/system/cpu/amd_pstate/status"), "cur_khz_sample": freq,
            "load": os.getloadavg(), "top3": top3()}


def top3():
    rows = sh("ps -eo pcpu,comm --sort=-pcpu --no-headers | head -3").splitlines()
    return [" ".join(r.split(None, 1)) for r in rows]


def refuse_if_boost():
    b = boost()
    if b is None:
        print("hostguard: cannot read cpufreq/boost; recording it as unknown", file=sys.stderr)
        return
    if b.strip() == "1" and os.environ.get("FBENCH_ALLOW_BOOST") != "1":
        raise SystemExit("hostguard: CPU boost is ON (/sys/devices/system/cpu/cpufreq/boost = 1). Disable it "
                         "(echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost) or set FBENCH_ALLOW_BOOST=1 "
                         "to run anyway (the run is then marked boost=1 in processes.log).")


def refuse_if_observer_misplaced():
    mine = set(os.sched_getaffinity(0))
    if mine & set(parse_cpus(DOMAIN)) and os.environ.get("FBENCH_ALLOW_OBSERVER_ON_MEASURED") != "1":
        raise SystemExit(f"hostguard: this runner may run on measured-domain CPUs {sorted(mine & set(parse_cpus(DOMAIN)))}; "
                         f"start it under `taskset -c {OBSERVER}` (the observer belongs on the other L3 domain)")


def blockers():
    me = {os.getpid(), os.getppid()}
    bad = []
    for line in sh("ps -eo pid,args --no-headers").splitlines():
        pid, _, cmd = line.strip().partition(" ")
        if not pid.isdigit() or int(pid) in me:
            continue
        # the first tokens, so a measured binary started under `taskset -c ...` is found too
        toks = cmd.split()[:6]
        if any(BLOCKERS.search(os.path.basename(t) + " ") for t in toks) and not toks[0].endswith("bash"):
            if "ps -eo" in cmd or "hostguard" in cmd or "run_awake" in cmd:
                continue
            bad.append(cmd[:100])
    return bad


def idle_check(cpus=DOMAIN):
    r = subprocess.run([sys.executable, str(IDLE_SCRIPT), "check", cpus, "--seconds", str(IDLE_SECONDS),
                        "--max-busy", str(MAX_BUSY)], capture_output=True, text=True)
    return r.returncode == 0, r.stderr.strip().splitlines()


def _stat():
    out = {}
    for line in Path("/proc/stat").read_text().splitlines():
        h, *f = line.split()
        if h.startswith("cpu") and h != "cpu":
            v = [int(x) for x in f]
            idle = v[3] + (v[4] if len(v) > 4 else 0)
            out[int(h[3:])] = (sum(v[:8]) - idle, sum(v[:8]))
    return out


class During(threading.Thread):
    """Busy fraction of the CPUs of the measured domain that are NOT in the measured mask, every 10 s."""
    def __init__(self, mask):
        super().__init__(daemon=True)
        self.watch = [c for c in parse_cpus(DOMAIN) if c not in set(parse_cpus(mask))]
        self.samples, self.stop, self.max = [], threading.Event(), 0.0

    def run(self):
        a = _stat()
        while not self.stop.wait(DURING_INTERVAL):
            b = _stat()
            worst = 0.0
            for c in self.watch:
                dt = b[c][1] - a[c][1]
                worst = max(worst, (b[c][0] - a[c][0]) / dt if dt > 0 else 0.0)
            self.samples.append(round(worst, 3))
            self.max = max(self.max, worst)
            a = b


def clean_env(extra=None):
    env = {k: v for k, v in os.environ.items() if not SCRUB.match(k)}
    env.update(extra or {})
    return env


def run_guarded(tag, cmd, mask, out_dir, stdout_file=None, outputs=(), env_extra=None, dry_run=False, log=None):
    """Run `taskset -c mask cmd` under the protocol. `outputs` are files the command writes (archived when an
    attempt is rejected). Returns the JSON record; raises on a command failure or when no valid attempt exists."""
    full = ["taskset", "-c", mask] + cmd
    if dry_run:
        print(f"  {tag:<34} {mask:<5} {shlex.join(cmd)}")
        return None
    out_dir = Path(out_dir)
    (out_dir / RAWNAME / "rejected").mkdir(parents=True, exist_ok=True)
    refuse_if_observer_misplaced()
    attempts = []
    for attempt in range(1, RETRIES + 1):
        refuse_if_boost()
        bl = blockers()
        if bl:
            attempts.append({"attempt": attempt, "rejected": "other build/test/benchmark process", "blockers": bl})
            print(f"{tag}: blocked by {bl[:2]}; waiting {WAIT}s", file=sys.stderr)
            time.sleep(WAIT)
            continue
        ok_before, g_before = idle_check()
        if not ok_before:
            attempts.append({"attempt": attempt, "rejected": "domain busy before", "guard": g_before})
            print(f"{tag}: domain {DOMAIN} busy before (attempt {attempt}); waiting {WAIT}s", file=sys.stderr)
            time.sleep(WAIT)
            continue
        state = host_state(mask)
        during = During(mask)
        during.start()
        env = clean_env(env_extra)
        t0 = time.time()
        stdout = open(stdout_file, "w") if stdout_file else subprocess.PIPE
        p = subprocess.Popen(full, stdout=stdout, stderr=subprocess.PIPE, text=True, env=env)
        time.sleep(0.3)
        child_aff = sh(f"taskset -cp {p.pid}").split(":")[-1].strip()
        err = p.communicate()[1]
        t1 = time.time()
        during.stop.set()
        if stdout_file:
            stdout.close()
        ok_after, g_after = idle_check()
        rec = {"tag": tag, "cmd": cmd, "mask": mask, "observer_mask": OBSERVER, "runner_affinity": sorted(os.sched_getaffinity(0)),
               "child_affinity_read_back": child_aff, "domain_guarded": DOMAIN,
               "guard_params": {"seconds": IDLE_SECONDS, "max_busy": MAX_BUSY, "retries": RETRIES, "wait_s": WAIT},
               "host_before": state, "idle_before": g_before, "idle_after": g_after, "host_after": host_state(mask),
               "during_unmeasured_domain_busy_max": round(during.max, 3), "during_samples": during.samples,
               "wall_s": round(t1 - t0, 1), "rc": p.returncode, "attempt": attempt, "attempts": attempts,
               "env_scrubbed": sorted(k for k in os.environ if SCRUB.match(k)), "stderr_tail": err[-400:]}
        if p.returncode != 0:
            rec["busy"] = None
            _write(log, out_dir, rec)
            raise SystemExit(f"{tag}: command failed rc={p.returncode}: {err[-300:]}")
        if not ok_after or during.max > DURING_REJECT:
            why = "domain busy after" if not ok_after else f"unmeasured domain CPU busy during ({during.max:.2f})"
            for i, f in enumerate([stdout_file, *outputs]):
                if f and os.path.exists(f):
                    os.replace(f, out_dir / RAWNAME / "rejected" / f"{tag}.attempt{attempt}.{os.path.basename(f)}")
            attempts.append({"attempt": attempt, "rejected": why, "guard": g_after, "during_max": round(during.max, 3)})
            print(f"{tag}: rejected ({why}); archived under raw/rejected/, retrying", file=sys.stderr)
            time.sleep(WAIT)
            continue
        rec["busy"] = False
        rec["attempts"] = attempts
        _write(log, out_dir, rec)
        print(f"{tag}: ok {rec['wall_s']}s attempt={attempt} load={os.getloadavg()[0]:.2f} boost={state['boost']}", flush=True)
        return rec
    raise SystemExit(f"{tag}: no valid attempt in {RETRIES} tries; attempts: {json.dumps(attempts)[:600]}")


def _write(log, out_dir, rec):
    with open(log or (Path(out_dir) / RAWNAME / "processes.log"), "a") as f:
        f.write(json.dumps(rec) + "\n")
