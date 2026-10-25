# Stage 1 of faer-benchmark#24 on an Apple M5 Max (aarch64, macOS), 2026-10-25

Held spindle group against an awake borrowed Rayon team against nothing, three rows in one binary.
Stage 1 makes no decision: the decision rule written in tensor4all/faer-benchmark#24 is not applied to
these numbers, and the data feeds the single decision after stage 2 (tensor4all/tensor4all-meta#48).
The harness change is tensor4all/faer-benchmark#25. The path analysis (which faer, `gemm` and spindle
calls run on aarch64) is the comment that opens the results on #24.

## Rows

| Row | Wrapper around priming, every repetition and the check |
| --- | --- |
| `faer-fork` (held) | `spindle::with_lock(threads)` |
| `faer-fork-hot` (hot) | `fbench/src/team.rs`: `threads - 1` workers borrowed through a top level `rayon::scope`, members loop on `rayon::yield_now()` and `spin_loop`, acknowledged start-up on distinct pool threads |
| `faer-fork-free` (free) | nothing |

On aarch64 no library change is needed. `t4a-private-gemm-x86` is not compiled, so the x86_64
feature planned in #24 is neither implemented nor measured here.

## Revisions and build

* t4a-faer `1599884dba654c9ffd246f6acd7e806eada251d9`, branch `exp/awake-team-stage1` of tensor4all/faer: `a399408` (head of tensor4all/faer#52) merged with main `752a0a6` (#55). No library edits. Version 0.24.9.
* harness `f11a72aa34fbb33174ff3b9bb4239ab9f4d97deb` (branch `bench/awake-team-stage1`, clean). Built `--release --features faer-only` with `t4a-faer` patched to the checkout above. Binary sha256 `05b8ab44e47da3d91536cf9359609b0b40a80a983bb44054bf11c8ae2771da47` is in `raw/identity.json`.
* spindle 0.2.6, gemm 0.19.0, gemm-common 0.19.0, rayon 1.12.0, rayon-core 1.13.0, nano-gemm 0.2.2, pulp 0.22.3, rustc 1.96.0. Upstream `faer` 0.24.4 is linked by the harness but no upstream row was run.
* Host: Apple M5 Max, macOS (Darwin 25.5.0), 6 Super + 12 Performance cores (L2 per cluster 16 MB and 8 MB), on AC power, no thermal warning recorded. No pinning, no boost control.

## Protocol

* Thread counts 1, 6, 12, 18: the global Rayon pool has exactly that many workers. The scheduler, not the harness, chooses the cores.
* Column-major (`--orders F`), f64. Operations: `gemm` (256, 512, 1024, 2048 squares, 4096 square at 1, 6, 12 and 18 threads in one rotation only, and three skinny shapes 4096x64x64, 64x4096x64, 2048x2048x64 as MxKxN), `lu`, `qr_factor` and `cholesky` at 256, 512, 1024, 2048.
* Per process: 250 ms of priming, then 41 repetitions (256, 512), 31 (skinny), 15 (1024, 2048) or 7 (4096). The row order rotates between processes (`--rotate-rows 0,1,2`), so every cell has one process with each row first, second and last. A cell's number is the median of a process's repetitions; the ratio is taken per process and the tables show its median over the three rotations with the min and max.
* Results above 1024 are not checked inside the timed session (`--check-max-dim 1024`): the reference math is serial and would keep a held or hot team spinning for seconds between cells. Correctness of the smaller cells is checked after timing, inside each wrapper.
* The dispatch probe (`fbench dispatch`) runs each wrapper in turn (row order rotated) and times a tiny `spindle::for_each` (faer's own path) and a plain Rayon `par_iter` (the `gemm` crate's path). Back to back cost is the mean over blocks of 1000. After a serial gap of 0 to 100 000 microseconds (the leader busy waits), one dispatch is timed. The CPU over wall ratio is the process CPU time across the loop.
* One process per (set, thread count, rotation); 12 rotations of the main sets, 9 dispatch processes (6, 12, 18 threads), 4096 at 12 and 18 threads in rotation 0 only. The first attempt at 4096 spent 11 minutes per process in reference math at operation construction, so 4096 was cut to one rotation after the first two processes (1 and 6 threads, rotation 0) had run.

## Host load

The machine is a shared interactive laptop. `idle_before` in `raw/processes.log` is the reading of `top` taken just before each process, with no benchmark running (the runner waited up to 126 s for at least 88 percent idle and then ran regardless, recording the wait).

| run | processes | ambient idle before a process, min / median | notes |
| --- | --- | --- | --- |
| `raw` (main) | 49 | 81.7 / 91.9 percent | a `team_ledger` test process of threadteam-rs-team at 97 percent of a core and, from about 16:58, Zwift and a video encoder were running (see `raw/load.csv`, which includes the benchmark's own load) |
| `raw-repeat18` (repeat of 18 threads) | 12 | 69.5 / 78.7 percent | heavier ambient load: about four cores busy outside the benchmark |

The 18 thread repeat was taken under heavier load and is reported as a separate table, not merged: it
shows how the same cells move when cores are contested.

## Files

* `run_stage1.py`: the runner (identity capture, ambient wait, one CSV per process); `summarize.py`: the tables.
* `raw/`: `identity.json` (and `identity-2.json` for the second invocation), `processes.log`, `load.csv`, `small|large|skinny|gemm4096-T<threads>-rot<k>.csv` and `dispatch-T<threads>-rot<k>.csv`. The CSV has the campaign columns plus `cpu_samples_ms`, `loop_wall_ms` and `loop_cpu_ms`.
* `raw-repeat18/`: the same for the 18 thread repeat.
* `tables-main.md`, `tables-main-compact.md`, `tables-repeat18-loaded.md`, `tables-repeat18-loaded-compact.md`: generated by `summarize.py`.

## Headline (main run)

Median over the cells of a family of the per-cell median ratio (hot over held, free over held). Below 1 means faster than the held spindle group. The 1 thread rows are the noise floor: the three rows take the same code path and their ratios stay within 0.996 to 1.005.

| threads | family | hot / held | min to max over cells | free / held |
| --- | --- | --- | --- | --- |
| 1 | gemm, lu, qr_factor, cholesky | 0.999 to 1.003 | 0.996 to 1.005 | 0.997 to 1.000 |
| 6 | gemm | 0.202 | 0.192 to 0.264 | 0.232 |
| 6 | lu | 0.490 | 0.313 to 1.000 | 0.641 |
| 6 | qr_factor | 1.036 | 1.020 to 1.077 | 2.263 |
| 6 | cholesky | 0.823 | 0.743 to 1.008 | 0.942 |
| 12 | gemm | 0.119 | 0.108 to 0.263 | 0.155 |
| 12 | lu | 0.525 | 0.244 to 0.983 | 0.770 |
| 12 | qr_factor | 1.101 | 1.037 to 1.194 | 3.665 |
| 12 | cholesky | 0.753 | 0.533 to 1.003 | 0.889 |
| 18 | gemm | 0.101 | 0.084 to 33.1 | 0.152 |
| 18 | lu | 0.606 | 0.232 to 1.343 | 1.084 |
| 18 | qr_factor | 1.721 | 0.998 to 1.876 | 5.917 |
| 18 | cholesky | 0.664 | 0.408 to 1.024 | 0.904 |

The per-cell tables (all sizes, rotation ranges, CPU over wall) are in `tables-main.md`.

## Dispatch cost, wake latency and spinning (microseconds)

### main

Median over the three row orders. Times in microseconds. `b2b`: back to back dispatch. `after gap`: one dispatch after the leader worked serially for the gap. `cpu/wall`: cores kept busy across the gap loop.

| threads | measure | held | hot | free |
| --- | --- | --- | --- | --- |
| 6 | b2b `spindle::for_each` | 0.83 | 0.77 | 10.84 |
| 6 | b2b Rayon `par_iter` (the `gemm` crate's fork) | 0.06 | 0.59 | 10.81 |
| 6 | after gap 100 us, median (p90) | 0.54 (1.25) | 0.88 (3.83) | 11.96 (20.46) |
| 6 | after gap 1000 us, median (p90) | 12.75 (17.42) | 2.46 (4.17) | 15.96 (22.21) |
| 6 | after gap 100000 us, median (p90) | 14.67 (20.00) | 3.58 (5.58) | 23.88 (31.33) |
| 6 | cpu/wall, gap 1000 us | 3.69 | 5.98 | 1.10 |
| 6 | cpu/wall, gap 100000 us | 1.03 | 5.97 | 1.00 |
| 12 | b2b `spindle::for_each` | 2.11 | 2.65 | 33.95 |
| 12 | b2b Rayon `par_iter` (the `gemm` crate's fork) | 0.12 | 2.35 | 33.77 |
| 12 | after gap 100 us, median (p90) | 1.62 (2.38) | 2.75 (5.88) | 76.29 (99.79) |
| 12 | after gap 1000 us, median (p90) | 27.58 (289) | 3.92 (7.17) | 82.25 (113) |
| 12 | after gap 100000 us, median (p90) | 41.83 (63.38) | 5.42 (8.79) | 102 (145) |
| 12 | cpu/wall, gap 1000 us | 7.12 | 11.91 | 1.90 |
| 12 | cpu/wall, gap 100000 us | 1.06 | 11.97 | 1.01 |
| 18 | b2b `spindle::for_each` | 3.30 | 7.18 | 81.88 |
| 18 | b2b Rayon `par_iter` (the `gemm` crate's fork) | 0.18 | 6.33 | 80.06 |
| 18 | after gap 100 us, median (p90) | 2.75 (48.04) | 4.71 (29.50) | 132 (177) |
| 18 | after gap 1000 us, median (p90) | 318 (553) | 8.79 (225) | 157 (214) |
| 18 | after gap 100000 us, median (p90) | 148 (590) | 10.21 (3830) | 199 (261) |
| 18 | cpu/wall, gap 1000 us | 11.33 | 17.28 | 2.64 |
| 18 | cpu/wall, gap 100000 us | 1.13 | 17.30 | 1.02 |

### repeat of 18 threads under heavier load

Median over the three row orders. Times in microseconds. `b2b`: back to back dispatch. `after gap`: one dispatch after the leader worked serially for the gap. `cpu/wall`: cores kept busy across the gap loop.

| threads | measure | held | hot | free |
| --- | --- | --- | --- | --- |
| 18 | b2b `spindle::for_each` | 18.75 | 57.84 | 75.51 |
| 18 | b2b Rayon `par_iter` (the `gemm` crate's fork) | 0.18 | 51.40 | 72.52 |
| 18 | after gap 100 us, median (p90) | 11.62 (536) | 14.58 (1350) | 143 (196) |
| 18 | after gap 1000 us, median (p90) | 543 (567) | 85.96 (5347) | 176 (226) |
| 18 | after gap 100000 us, median (p90) | 573 (954) | 19.83 (5216) | 220 (316) |
| 18 | cpu/wall, gap 1000 us | 11.25 | 15.54 | 2.63 |
| 18 | cpu/wall, gap 100000 us | 1.16 | 15.38 | 1.02 |

## Observations (aarch64, this host, this load; no decision)

* **Noise floor.** At 1 thread the three rows take the same path and agree within 0.5 percent.
* **GEMM.** The held group starves the `gemm` crate's Rayon fork: the 1024 product takes 36.7 ms at 6, 12 and 18 threads, its 1 thread time (36.4 ms), with CPU over wall 1.0. Hot and free are 5.1, 8.6 and 10 times faster at 1024 and agree within 6 percent for sizes of 1024 and above. At 512 and below hot is faster than free (256: 0.113 against 0.156 ms at 6 threads, 0.074 against 0.183 at 12, 0.071 against 0.31 at 18).
* **LU and Cholesky.** Their trailing products are starved under the held group. Hot takes 0.24 to 0.65 of the held time for LU from 512 up, and 0.53 to 0.89 for Cholesky from 512 up (6 and 12 threads). Free lies between held and hot. At 256 all three are equal.
* **QR.** The work is mostly spindle regions with small products, and the held group is as fast or faster: hot over held is 1.02 to 1.08 at 6 threads and 1.04 to 1.19 at 12 threads; free is 1.3 to 4.6 times slower than held. This is the family where the candidate loses.
* **Dispatch.** Back to back, a tiny `spindle::for_each` costs 0.83 (held) and 0.77 (hot) microseconds at 6 threads, 2.1 and 2.65 at 12, 3.3 and 7.2 at 18; free costs 10.8, 34 and 82. Rayon `par_iter` inside a held group costs 0.06 microseconds because the leader runs it alone, which is the starvation.
* **Wake latency.** The held group spins for less than 1 ms (CPU over wall falls from 5.98 at a 100 us gap to 3.69 at 1 ms at 6 threads) and then sleeps on a futex: the first dispatch after a 1 ms gap takes 12.8, 27.6 and 318 microseconds at 6, 12 and 18 threads. Hot stays at 2.5, 3.9 and 8.8. Free takes 16, 82 and 157.
* **CPU cost of spinning.** Hot keeps all borrowed cores at 100 percent for any gap (CPU over wall 5.97, 11.97 and 17.3 across 100 ms gaps); held drops to about 1.0 after its spin window, free to about 1.0 after 1 ms. CPU time per call of QR 2048 at 12 threads: held 472 ms, hot 509 ms, free 758 ms; of LU 2048: held 455 ms, hot 329 ms, free 296 ms. For sub-millisecond calls the CPU over wall column is inflated by the clock reads that sit outside the wall window (21 at 18 threads).
* **18 threads is every core.** The cells vary by rotation and by ambient load: `gemm` 64x4096x64 took 28 ms in the hot row of the main run (0.26 to 72 times held over the rotations) against 0.63 ms held; QR hot over held ranges 1.0 to 1.9. In the repeat under heavier load hot over held is 1.1 to 1.5 for LU, QR and Cholesky while free is 0.42 to 0.49 of held for LU and Cholesky, and the hot team's dispatch after a gap shows 5 ms spikes at the 90th percentile. A team that spins on every core competes with whatever else runs; at 12 threads (two thirds of the cores) the main run shows no such behaviour.
* **Not measured.** The reserved team, the 200 ms idle policy (the hot row spins without limit), several engines at once, x86_64.
