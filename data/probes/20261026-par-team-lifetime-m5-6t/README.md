# `Par<'team>` on a threadteam team, rough M5, 6 threads, UserInitiated QoS (2026-10-25)

Stage 2 families and the small-operation sequences of tensor4all/faer-benchmark#24 on the value-carried
authority `Par::Team(TeamExec<'team>)` (tensor4all/faer `exp/par-team-lifetime`, draft PR). A rough
measurement on a shared interactive laptop; it makes no decision, and acceptance is measured later on a
quiet Linux machine. The prototype this supersedes (thread-local team, `exp/team-par`) was not re-run in
this session, so no prototype-to-new ratio is claimed; the earlier numbers are in
`../20261025-awake-team-stage2-m5-6t/`.

## What was measured

* Rows interleaved inside every process: `faer-fork` (spindle group held, `Par::Rayon(6)`),
  `faer-fork-hot` (awake borrowed Rayon team), `faer-fork-free` (nothing held), `faer-fork-team`
  (`Par::Team`, 6 participants, the leader included).
* Main families (f64, column-major): gemm, lu, qr_factor, cholesky at 512 (41 reps), 1024 and 2048
  (15 reps, checked up to 1024), gemm skinny shapes (31 reps); 250 ms priming. Row order rotations 0 and 2 for
  the 512 and skinny sets (2 processes per cell), rotation 0 only for 1024 and 2048 (1 process per cell, to
  stay inside the time budget).
* Small-operation sequences (`fbench smallops`, 41 repetitions after 3 warm-ups): 2 rotations, plus one extra
  process (`smallops-extra`, rotation 2; it ran by a mistake in the plan and is kept, its numbers are in the
  per-call medians). `FBENCH_SETTLE_MS=300`: the leader sleeps 300 ms before each sequence so the team's
  members have parked (the 200 ms spin tail) when its CPU/wall window opens.
* 6 threads only; the 1 thread rows were not run.
* QoS: `FBENCH_QOS=user-initiated`, verified on the main thread and every harness pool worker for every
  process (`qos` in `raw/processes.log`). The team's pool workers are created with `qos(UserInitiated)`.

## Harness changes this run depends on

* The fork's `Par` is not `Copy`: ops keep a `ParCfg` and build a `Par` per call. The team row's `Par` is a
  reborrow of the session's `TeamExec`. The harness `Op`s are `'static`, so the session keeps the `TeamExec`
  in its frame and `team_row::par()` hands out reborrows through a thread-local pointer set for the session's
  duration (harness only; the library has no such shim).
* `lu` and `cholesky` for the fork rows (all four) now call `lu_in_place` and `cholesky_in_place` with the
  row's explicit parallelism: the high level `partial_piv_lu()` and `llt()` read the global parallelism, which
  a team cannot be. The in-place entry points reuse buffers that `prepare` restores, so the clocked region no
  longer includes the allocation and copy of the owned factorisation. Fork lu and cholesky numbers are
  therefore not comparable with the earlier stage 1 and stage 2 numbers; the check compares the packed factors
  against the library's own sequential entry point.

## Revisions

* t4a-faer `cfbab1cbf380d3c88a65ea9ca22bca329f2c4064` (`exp/par-team-lifetime`, clean), features `std`,
  `rayon`, `threadteam`.
* threadteam `6e878626485a06f71b23e71af4498e9e1f39a1fa` (`feat/team`; idle clock made explicit, `trace`
  feature; no API change).
* harness: commit `c12334f` (`bench/par-team-lifetime`) plus this directory; `--release --features
  faer-only,team`, upstream faer from `/Users/hiroshi/projects/tensor4all/faer-rs`; binary sha256
  `bf288a4d3028fd79f782640f1a9b6724f7c2c1e698f394a75bd32ff03d789c52`. `rustc` 1.96.0, Apple M5 Max, AC power.

## Ambient idle and the host protocol

Before each process the runner checked for other fbench, cargo or test processes (none found) and polled
`top` until the machine was at least 85 percent idle (it never had to wait: `waited_s` is 0 everywhere). Per
process, `raw/processes.log` holds the idle polls, the three top CPU consumers and the load average before
and after, and an idle sample every 25 s while the process ran.

| process | idle before | load1 before | idle after | idle during (samples) | top consumers before | busy |
| --- | --- | --- | --- | --- | --- | --- |
| main small rot0 | 91.7 | 4.17 | 92.4 | none (7 s) | WindowServer 21.9, ChatGPT 20.4, WallpaperAerialsExtension 13.8 | no |
| main skinny rot0 | 92.2 | 4.73 | 91.4 | none (7 s) | WindowServer 20.7, WallpaperAerialsExtension 13.0, loginwindow 11.9 | no |
| smallops extra rot2 | 91.4 | 5.40 | 91.2 | 89.5 | WindowServer 21.8, WallpaperAerialsExtension 14.1, loginwindow 11.9 | no |
| main skinny rot2 | 91.6 | 5.47 | 91.5 | none (7 s) | WindowServer 20.8, loginwindow 12.1, WallpaperAerialsExtension 11.4 | no |
| main large rot0 | 92.6 | 5.08 | 88.8 | 88.2, 87.8, 87.5, **64.4**, 80.4, 87.9, 88.3, 87.7 | WindowServer 19.7, loginwindow 11.3, WallpaperAerialsExtension 10.4 | **yes** |
| smallops rot0 | 91.5 | 3.81 | 89.6 | 89.8 | WindowServer 20.8, WallpaperAerialsExtension 12.1, loginwindow 11.6 | no |
| smallops rot2 | 90.9 | 5.44 | 89.5 | 88.8 | launchd 34.0, WindowServer 23.1, WallpaperAerialsExtension 15.6 | no |
| main small rot2 | 92.6 | 4.84 | 87.6 | none (7 s) | WindowServer 20.5, loginwindow 12.2, WallpaperAerialsExtension 11.6 | no |

The large process is marked busy because one in-run sample read 64.4 percent idle; the benchmark itself
holds 6 of 18 logical CPUs, so in-run samples include its own load (the other seven samples read 87 to 88).
The cells it produced (1024 and 2048) are marked `*` in `tables.md`; they are single-process cells. After the
process, `sysmond` was the top consumer (80.8). The run is otherwise on a quiet host, below the 85 percent
threshold in no pre-run poll. The top consumers are the desktop session, not a benchmark.

## Files

`run_bench.py` (runner and host protocol), `summarize.py`, `tables.md`, `raw/` (CSV per process,
`processes.log`), `run.log`.
