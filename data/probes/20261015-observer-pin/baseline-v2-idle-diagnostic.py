"""Measure guard-window failures on an otherwise idle host, and name the CPU consumers."""
import time
from pathlib import Path

ROOT = Path('/')
WATCH = sorted({c for base in range(4, 12) for c in (base, base + 16)})  # 4-11 and SMT siblings 16-23
WINDOW = 3.0
MAX_BUSY = 0.05
WINDOWS = 100  # ~5 minutes


def cpu_times():
    out = {}
    for line in (ROOT / 'proc/stat').read_text().splitlines():
        head, *fields = line.split()
        if head.startswith('cpu') and head != 'cpu':
            v = [int(x) for x in fields]
            idle = v[3] + (v[4] if len(v) > 4 else 0)
            out[int(head[3:])] = (sum(v[:8]) - idle, sum(v[:8]))
    return out


def process_times():
    out = {}
    for entry in (ROOT / 'proc').iterdir():
        if not entry.name.isdigit():
            continue
        try:
            fields = (entry / 'stat').read_text().rsplit(') ', 1)[1].split()
            out[int(entry.name)] = (int(fields[11]) + int(fields[12]), (entry / 'cmdline').read_bytes()[:60])
        except (OSError, IndexError, ValueError):
            continue
    return out


def name(cmd):
    text = ' '.join(p.decode(errors='replace') for p in cmd.split(b'\0') if p)[:60]
    return text or '?'


fails = 0
for window in range(WINDOWS):
    c0, p0 = cpu_times(), process_times()
    time.sleep(WINDOW)
    c1, p1 = cpu_times(), process_times()
    frac = {c: ((c1[c][0] - c0[c][0]) / (c1[c][1] - c0[c][1])) if c in c0 and c in c1 and c1[c][1] > c0[c][1] else 0.0
            for c in WATCH}
    busy = {c: f for c, f in frac.items() if f > MAX_BUSY}
    if not busy:
        continue
    fails += 1
    deltas = sorted(((v[0] - p0[pid][0], pid, name(v[1])) for pid, v in p1.items() if pid in p0), reverse=True)[:4]
    print(f"{time.strftime('%H:%M:%S')} window {window}: busy={ {c: round(f, 3) for c, f in sorted(busy.items())} }")
    for delta, pid, text in deltas:
        if delta > 0:
            print(f"    pid {pid} cpu+{delta} jiffies: {text}")
print(f"guard windows failing: {fails}/{WINDOWS} at max_busy={MAX_BUSY} over {WINDOW}s")
