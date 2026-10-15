"""Attribute guard-window busy time to specific processes, pinned observer on CPUs 0-3."""
import subprocess, threading, time
from pathlib import Path
ROOT = Path('/')
BIN = '/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/bfe4041cd991-mkl/release/fbench'
WATCH = sorted({c for base in range(4, 12) for c in (base, base + 16)})
samples = []
lock = threading.Lock()


def read_cpu():
    out = {}
    for line in (ROOT / 'proc/stat').read_text().splitlines():
        head, *fields = line.split()
        if head.startswith('cpu') and head != 'cpu':
            v = [int(x) for x in fields]
            out[int(head[3:])] = (sum(v[:8]) - v[3] - (v[4] if len(v) > 4 else 0), sum(v[:8]))
    return out


def read_proc():
    out = {}
    for entry in (ROOT / 'proc').iterdir():
        if not entry.name.isdigit():
            continue
        try:
            f = (entry / 'stat').read_text().rsplit(') ', 1)[1].split()
            cmd = ' '.join(p.decode(errors='replace') for p in (entry / 'cmdline').read_bytes().split(b'\0') if p)[:80]
            out[int(entry.name)] = (int(f[11]) + int(f[12]), cmd or '?')
        except (OSError, IndexError, ValueError):
            continue
    return out


def sampler(stop, pid):
    prev_c, prev_p = read_cpu(), read_proc()
    while not stop.is_set():
        time.sleep(0.25)
        cur_c, cur_p = read_cpu(), read_proc()
        with lock:
            samples.append((time.time(), {c: (cur_c[c][0] - prev_c[c][0], cur_c[c][1] - prev_c[c][1])
                                          for c in WATCH if c in prev_c and c in cur_c},
                            [(cur_p[p][0] - prev_p[p][0], p, cur_p[p][1]) for p in cur_p if p in prev_p]))
        prev_c, prev_p = cur_c, cur_p


def check():
    t0 = time.time()
    r = subprocess.run(['python3', '/home/shinaoka/projects/tensor4all/faer-benchmark/benchmarks/scripts/idle_cpus.py',
                        'check', '4-11', '--seconds', '3', '--max-busy', '0.05'], capture_output=True, text=True)
    return t0, time.time(), r.returncode, r.stderr


def report(t0, t1, rcs, stderr):
    with lock:
        window = [s for s in samples if t0 - 0.2 <= s[0] <= t1 + 0.2]
    percpu = {c: (sum(x[1].get(c, (0, 0))[0] for x in window), sum(x[1].get(c, (0, 0))[1] for x in window)) for c in WATCH}
    frac = {c: round(b / t, 3) for c, (b, t) in percpu.items() if t and b / t > 0.05}
    perpid = {}
    for _, _, procs in window:
        for d, p, cmd in procs:
            total, text = perpid.get(p, (0, cmd))
            perpid[p] = (total + d, text)
    top = sorted(((d, p, t) for p, (d, t) in perpid.items()), reverse=True)[:5]
    print(f"  busy CPUS over window: {frac}")
    for d, p, t in top:
        if d:
            print(f"    pid {p}: {d} jiffies ({d * 10} ms) {t}")


stop = threading.Event()
threading.Thread(target=sampler, args=(stop, 0), daemon=True).start()
fails = 0
for i in range(20):
    b0, b1, brc, bstderr = check()
    t = time.time()
    subprocess.run(['taskset', '-c', '4-11', BIN, 'verify', '--threads', '8', '--n', '4096x256',
                    '--family', 'householder_apply', '--dtype', 'f64', '--batch', '1', '--regime', 'householder',
                    '--csv', '/tmp/baseline-v2-guard-repro.csv'], capture_output=True, text=True)
    a0, a1, arc, astderr = check()
    if brc or arc:
        fails += 1
        print(f"iter {i}: rejection (before={brc} after={arc})", flush=True)
        if brc:
            print(' before window:'); report(b0, b1, brc, bstderr)
        if arc:
            print(' after window:'); report(a0, a1, arc, astderr)
stop.set()
print(f'guard rejections: {fails}/20')
