# Priming calibration with turbo disabled (27 processes, 0 guard rejections)

Machine state during the run: `cpufreq_boost=0`, governor `performance`, EPP
`performance`, PPD `performance`, `scaling_max_freq=2000000` kHz (recorded by the
recorder as `host.power`; it resets on reboot). Three process starts
(rotations 0/1/2) per setting per cell, so a setting effect is separable from the
between-process variation that one start cannot resolve.

## Setting effect is far below the remaining variation

Rotation-paired ratio of the cheap settings to `--prime-ms 3000 --reps 30`, over
all 18 engine rows: **0.978 - 1.006** (`250/30` vs `3000/30`) and **0.981 - 1.006**
(`250/10` vs `3000/30`). No row moves by more than 2.2%, while the between-process
range in the same cells is 0.5-35%. A 250 ms priming with 10 calls is therefore
defensible for this harness and host, and cuts the priming floor by 12x.

## Turbo/boost was a large part of the process-level variation

| cell | process-median range (this run, boost off) | same cells, boost on |
| --- | --- | --- |
| `gemm` 256^3 f64 1T | 0.48-0.94% median, 1.5% worst | 0.9-1.9% |
| `lu` 256^2 c64 4T | 9.6-10.5% median, **33-35% worst** | **74% worst** |
| `cholesky` 512^2 f64 8T | 1.5-2.9% median, 4.6-5.1% worst | 40-73% |

The `cholesky` C-order cell that moved by 40-73% with boost on now moves by
1.5-5%. The `faer` F-order row of `lu` 4T still shows a systematic rotation-2 bump
(2.009 / 2.017 / 2.503 ms), so boost was a major but not the only contributor.

## Artifacts

27 `*.json` / `*.csv` / `*.guard` triples, `calibrate.py`. Not a published page:
one session, one host state, three starts per setting.
