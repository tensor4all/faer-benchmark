## Stage 2 families, 6 threads: median wall time (ms) over processes and ratios per process

`*` marks a cell from a process flagged busy (host below 85 percent idle at some sample).

| op | shape | held ms | hot ms | free ms | team ms | team/held | team/hot | team/free | processes | busy | team cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cholesky | 512 | 0.526 | 0.458 | 0.577 | 0.432 | 0.823 | 0.944 | 0.75 | 2 |  | 5.23 |
| cholesky | 1024 | 3.44 | 2.65 | 2.96 | 2.54 | 0.738 | 0.959 | 0.858 | 1 | * | 5.84 |
| cholesky | 2048 | 25.9 | 18.6 | 19 | 18.4 | 0.711 | 0.992 | 0.971 | 1 | * | 5.96 |
| gemm | 64x4096x64 | 0.608 | 0.145 | 0.426 | 0.142 | 0.233 | 0.983 | 0.333 | 2 |  | 6.06 |
| gemm | 512x512x512 | 4.54 | 0.855 | 0.959 | 0.895 | 0.197 | 1.05 | 0.932 | 2 |  | 6.00 |
| gemm | 1024x1024x1024 | 36.5 | 7.04 | 7.06 | 7.14 | 0.196 | 1.01 | 1.01 | 1 | * | 5.29 |
| gemm | 2048x2048x64 | 26.3 | 7.14 | 7.04 | 2.28 | 0.0867 | 0.319 | 0.323 | 2 |  | 6.01 |
| gemm | 2048x2048x2048 | 290 | 59.8 | 59.8 | 61.6 | 0.212 | 1.03 | 1.03 | 1 | * | 5.98 |
| gemm | 4096x64x64 | 0.825 | 0.165 | 0.196 | 0.11 | 0.134 | 0.668 | 0.565 | 2 |  | 6.51 |
| lu | 512 | 2.04 | 1.14 | 1.52 | 1.14 | 0.557 | 0.998 | 0.749 | 2 |  | 6.13 |
| lu | 1024 | 14.2 | 5.69 | 6.98 | 5.38 | 0.379 | 0.946 | 0.771 | 1 | * | 6.10 |
| lu | 2048 | 108 | 34.5 | 38.3 | 35.4 | 0.328 | 1.02 | 0.923 | 1 | * | 5.96 |
| qr_factor | 512 | 1.79 | 1.88 | 5.14 | 1.73 | 0.964 | 0.919 | 0.336 | 2 |  | 6.09 |
| qr_factor | 1024 | 9.8 | 9.57 | 17.6 | 8.83 | 0.901 | 0.923 | 0.503 | 1 | * | 5.96 |
| qr_factor | 2048 | 59.9 | 59.9 | 92.8 | 58.7 | 0.98 | 0.981 | 0.633 | 1 | * | 5.99 |

## Small-operation sequences, 6 threads (median of the 41 repetitions, per call in microseconds)

| sequence | held | hot | free | team | team/held | team/free | team cpu/wall | busy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gemm32 | 1.42 | 1.37 | 1.41 | 1.35 | 0.96 | 0.962 | 1.00 |  |
| gemm64 | 10 | 10.4 | 10.1 | 10.1 | 1 | 1.01 | 1.00 |  |
| gemm128 | 80.9 | 18.9 | 53.6 | 19.4 | 0.239 | 0.362 | 5.99 |  |
| lu64 | 10.3 | 10.5 | 10.3 | 10.3 | 1 | 1 | 1.00 |  |
| lu128 | 52.8 | 54.1 | 53.2 | 53.1 | 1 | 1 | 1.00 |  |
| chain | 18.6 | 19.7 | 18.6 | 18.8 | 1.01 | 1.01 | 1.00 |  |

Engagement of the team row (one untimed pass per sequence):

* gemm32: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm64: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=2000 run[6:2000] split[]
* lu64: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* lu128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* chain: gemm_below_floor=1000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
