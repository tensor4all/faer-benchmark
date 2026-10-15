"""Reproduce guard rejections for the exact failing workload and name the CPU consumer."""
import subprocess, threading, time
from pathlib import Path
ROOT = Path('/')
BIN = Path('/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/bfe4041cd991-mkl/release/fbench')
WATCH = sorted({c for base in range(4, 12) for c in (base, base + 16)})
spikes = []


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
            cmd = ' '.join(p.decode(errors='replace') for p in (entry / 'cmdline').read_bytes().split(b'\0') if p)[:70]
            out[int(entry.name)] = (int(f[11]) + int(f[12]), cmd or '?')
        except (OSError, IndexError, ValueError):
            continue
    return out


def sampler(stop):
    prev_c, prev_p = read_cpu(), read_proc()
    while not stop.is_set():
        time.sleep(0.25)
        cur_c, cur_p = read_cpu(), read_proc()
        frac = {c: (cur_c[c][0] - prev_c[c][0]) / (cur_c[c][1] - prev_c[c][1]) for c in cur_c if c in prev_c and cur_c[c][1] > prev_c[c][1]}
        spikes.append((time.strftime('%H:%M:%S'), round(max((frac.get(c, 0.0) for c in WATCH), default=0.0), 2),
                       sorted(((cur_p[p][0] - prev_p[p][0], p, cur_p[p][1]) for p in cur_p if p in prev_p), reverse=True)[:3]))
        prev_c, prev_p = cur_c, cur_p


def check():
    r = subprocess.run(['python3', '/home/shinaoka/projects/tensor4all/faer-benchmark/benchmarks/scripts/idle_cpus.py',
                        'check', '4-11', '--seconds', '3', '--max-busy', '0.05'], capture_output=True, text=True)
    frac = {int(line.split()[0][3:]): float(line.split()[1].split('=')[1]) for line in r.stderr.splitlines() if line.startswith('cpu')}
    return r.returncode, frac


stop = threading.Event()
thread = threading.Thread(target=sampler, args=(stop,), daemon=True)
thread.start()
fails = 0
for i in range(10):
    before, _ = check()
    t = time.time()
    subprocess.run(['taskset', '-c', '4-11', str(BIN), 'verify', '--threads', '8', '--n', '4096x256',
                    '--family', 'householder_apply', '--dtype', 'f64', '--batch', '1', '--regime', 'householder',
                    '--csv', '/tmp/baseline-v2-guard-repro.csv'], capture_output=True, text=True)
    dur = time.time() - t
    after, frac = check()
    print(f"iter {i}: run={dur:.1f}s before_rc={before} after_rc={after} "
          f"busy={ {c: round(f, 3) for c, f in sorted(frac.items()) if f > 0.05} }", flush=True)
    fails += before != 0 or after != 0
stop.set()
print(f'guard rejections: {fails}/10')
worst = [s for s in spikes if s[1] > 0.05]
print(f'sampling buckets with any watched-CPU fraction > 0.05: {len(worst)}/{len(spikes)}')
for stamp, frac, top in worst[:12]:
    print(' ', stamp, 'maxfrac', frac, ['%s(%s)+%d' % (cmd.split()[-1][:28], pid, d) for d, pid, cmd in top if d])
