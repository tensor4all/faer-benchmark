# Rough M5 baseline: stage 1 of faer-benchmark#24 at 6 threads, UserInitiated QoS (Apple M5 Max, 2026-10-25)

A rough baseline on a shared interactive laptop, not a quiet host. Stage 1 makes no decision. Final
acceptance is measured later on a quiet Linux machine. Same rows as
`../20261025-awake-team-stage1-m5/` (held `faer-fork`, hot `faer-fork-hot`, free `faer-fork-free`).

## Conditions

* Threads 1 and 6 only (global Rayon pool of exactly that size). macOS cannot pin, so 6 threads and QoS aim at the 6 Super cores.
* QoS: `FBENCH_QOS=user-initiated`. `fbench` sets `QOS_CLASS_USER_INITIATED` (0x19) on the main thread and, through a Rayon `start_handler`, on every pool thread (these are also the spindle workers and the hot team's members). Verified with `pthread_get_qos_class_np` on the main thread and on every pool worker before and after the timed work, in every process: all 0x19 (`qos` field of each line in `raw/processes.log`). The earlier busy-host run did not set QoS: with the same harness binary and no variable, main is 0x21 (USER_INTERACTIVE, inherited from the launching app) and the pool workers are 0x15 (DEFAULT).
* Families: gemm (256/512/1024/2048 squares, 4096x64x64, 64x4096x64, 2048x2048x64), lu, qr_factor, cholesky at 256/512/1024/2048. No 4096. Column-major, f64.
* Repetitions: 41 (256, 512), 31 (skinny), 9 (1024, 2048, at 1 and 6 threads), 250 ms priming. Dispatch probe: 15 blocks.
* 2 rotations (row orders 0 and 1) per set and thread count, rows interleaved inside every process. Ratios are per process; the tables show the median and min to max over the 2 rotations (the headers in the generated tables say "three", they were written for the first run).
* Idle: there was no per-process idle wait. `idle_before` in `raw/processes.log` is the `top` reading just before each of the 14 processes: min 83.2, median 88.3, max 92.3 percent idle. `raw/load.csv` samples every 30 s. Load came from WindowServer, the Claude desktop app and WebKit helpers, about 1 to 3 cores. AC power.
* Not run: 4096, 12 and 18 threads, more than 2 rotations. Earlier attempts in this directory: `aborted-idle92/` (runner aborted after 609 s without reaching 92 percent idle, no benchmark ran), `superseded-full-plan/` (a 6 rotation plan stopped after 5 processes when the plan was cut down; not used).

## Revisions

* t4a-faer `1599884dba654c9ffd246f6acd7e806eada251d9` (branch `exp/awake-team-stage1` of tensor4all/faer), clean, no library edits, version 0.24.9.
* harness `b8fbfee` (branch `bench/awake-team-stage1`: stage 1 harness plus the QoS change), `--release --features faer-only`, binary sha256 `afda9c2f68477f4853b26d0e534e4761911c735c50169e43d83477fc23655d8d`. The runner and summarizer in this directory are the stage 1 ones with the QoS variable, `--idle-min 0`, and 9 repetitions for 1024 and 2048.
* Upstream `faer` 0.24.4 is linked by the harness, no upstream row was run. Details in `raw/identity.json`.

## Files

`run_stage1.py`, `summarize.py`, `raw/` (CSV per process, `processes.log`, `load.csv`, `identity.json`), `tables.md` (full, with CPU over wall), `tables-compact.md`.
