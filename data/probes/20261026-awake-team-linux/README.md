# Awake-team acceptance run on Linux (tensor4all-meta#51) - runners, not results

Status: prepared, nothing timed. Host: AMD Ryzen AI 9 HX 470, 12 cores / 24 CPUs, L3 domains {0-3,12-15} (observer)
and {4-11,16-23} (measured). Masks: 1T `taskset -c 4`, 4T `4-7`, 8T `4-11`. Protocol: docs/protocol-v2-baseline.md
(prime 250 ms, median, rotations, boost off, idle guard on the whole measured L3 domain: 3 s window, max_busy 0.05,
8 attempts, 30 s wait; rejected attempts archived in raw/rejected/ and never selected). Record the protocol version
used here when the run is done.

Build: `./build_all.sh` (revisions, rustc, sha256 in raw/build-info.txt). Run, from the observer domain:

    taskset -c 0-3,12-15 python3 run_awake.py {verify|a|b|c|d|e|all} [--dry-run] [--only TAG]
    python3 summarize.py all        # tables-*.md

Files: hostguard.py (host protocol), run_awake.py (plan, estimates), summarize.py, build_all.sh, bench/{tt,consts,stack}
(Linux ports of the threadteam benches, the recalibration/qr128 constants, the 6760aa1 confirmation sweep, a tlinalg
batched LU/QR probe), raw/ (processes.log, outputs).

Harness changes in this branch (uncommitted): `scripts/build_for_faer_rev.sh` gained `--vendor none`, `--features`,
`BENCH_TARGET_DIR`; `fbench diag-gemm`; the gemm reference product is computed lazily (only when a check runs) and the
column-major reference products are cache friendly (bit-identical sums); `--rotate-rows` is the only row rotation in
`fbench run` (the M5 runner reordered `--rows`, which `run` ignores).
