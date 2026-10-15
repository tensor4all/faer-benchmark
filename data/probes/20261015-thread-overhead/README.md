# Small-shape overhead probe (6 processes, gemm, f64)

`gemm` at 4^3, 32^3 and 256^3 with 1/4/8 threads, two rotations, 500 ms priming,
30 calls. Median per-call time (us), F and C orders agree:

| shape | 1T | 4T | 8T | 4T-1T | 8T-1T |
| --- | --- | --- | --- | --- | --- |
| 4^3 (faer) | 0.11 | 0.11 | 0.11 | 0.0 | 0.0 |
| 32^3 (faer) | 2.3 | 10.1 | 13.7 | +7.8 | +11.4 |
| 32^3 (MKL) | 4.5 | 5.2 | 4.8 | +0.7 | +0.3 |
| 256^3 (faer) | 1077 | 307 | 209 | -769 | -868 |
| 256^3 (MKL) | 1205 | 345 | 179 | -860 | -1026 |

Reading: 4^3 never enters a parallel path (0.11 us/call, no thread cost at all);
32^3 pays a roughly **constant +8 to +11 us** for the 4T/8T row, which is
thread-region start-up rather than kernel work (the fork's own worklog notes ~3 us
of rayon region per reflector); MKL's small-shape step is +0.3 to +0.8 us. Only at
256^3 does the kernel dominate the price.

Consequence for the suite: cells in the small regimes, at 4T/8T, measure the
dispatch/launch policy of each engine rather than kernel scaling, and their 8-12%
within-process relative SD is timer/scheduling noise on a sub-microsecond call.
They stay as declared coverage, but no cross-budget or cross-engine throughput
claim may be read from them, and they must not be used to explain large-shape
behaviour. Artifacts: six `*.json` / `*.csv` / `*.guard` triples and `probe.py`.
