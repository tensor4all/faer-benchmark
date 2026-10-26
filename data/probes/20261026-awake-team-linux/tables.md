## Stage comparison, 4 threads: median wall time (ms) over rotations, ratios per rotation

Rows: held = `faer-fork` (spindle group held), hot = awake Rayon team, free = nothing held, team = `Par::Team`. Ratios are medians over the rotation processes of the per-process ratio (below 1: team faster). `rot` counts the row-order rotations that produced the cell (`--rotate-rows`); `pos` is the spread of the team ratio to held over rotations (max/min): a large value means row position matters.

| op | shape | held ms | hot ms | free ms | team ms | team/held | team/hot | team/free | rot | pos | team cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cholesky | 128 | 0.0636 | 0.0602 | 0.0732 | 0.0759 | 1.19 | 1.26 | 1.03 | 4 | 1.1 | 2.15 |
| cholesky | 256 | 0.284 | 0.254 | 0.29 | 0.312 | 1.1 | 1.23 | 1.08 | 4 | 1.02 | 4.06 |
| cholesky | 512 | 1.22 | 1.18 | 1.27 | 1.67 | 1.37 | 1.41 | 1.31 | 4 | 1.01 | 4.02 |
| cholesky | 1024 | 5.02 | 4.95 | 5.18 | 7.27 | 1.43 | 1.47 | 1.4 | 4 | 1.1 | 3.78 |
| cholesky | 2048 | 30.9 | 29.6 | 30.2 | 70.3 | 2.26 | 2.38 | 2.33 | 4 | 1.23 | 3.93 |
| eigh | 128 | 2.25 | 2.25 | 2.25 | 2.25 | 1 | 1 | 1 | 4 | 1.01 | 1 |
| eigh | 256 | 7.23 | 7.2 | 7.43 | 7.43 | 1.02 | 1.03 | 0.999 | 4 | 1.01 | 1.42 |
| eigh | 512 | 30.9 | 30.4 | 31.1 | 31.2 | 1.01 | 1.02 | 1 | 4 | 1.01 | 1.65 |
| eigh | 1024 | 149 | 147 | 149 | 149 | 1 | 1.01 | 1 | 4 | 1.01 | 2.09 |
| eigh | 2048 | 831 | 824 | 838 | 838 | 1.01 | 1.02 | 0.999 | 4 | 1.01 | 3.01 |
| gemm | 64x4096x64 | 1.21 | 1.2 | 1.21 | 0.307 | 0.255 | 0.257 | 0.254 | 4 | 1.23 | 3.9 |
| gemm | 128x128x128 | 0.134 | 0.134 | 0.134 | 0.0382 | 0.286 | 0.285 | 0.286 | 4 | 1.02 | 3.87 |
| gemm | 256x256x256 | 0.308 | 0.294 | 0.308 | 0.293 | 0.953 | 0.996 | 0.952 | 4 | 1 | 3.76 |
| gemm | 512x512x512 | 2.21 | 2.21 | 2.24 | 2.34 | 1.06 | 1.06 | 1.04 | 4 | 1.05 | 4.02 |
| gemm | 1024x1024x1024 | 17.5 | 17.6 | 17.6 | 18.5 | 1.06 | 1.06 | 1.06 | 4 | 1.02 | 4 |
| gemm | 2048x2048x64 | 5.72 | 5.75 | 5.76 | 6.41 | 1.12 | 1.12 | 1.11 | 4 | 1.04 | 3.99 |
| gemm | 2048x2048x2048 | 141 | 141 | 141 | 148 | 1.05 | 1.05 | 1.05 | 4 | 1 | 3.99 |
| gemm | 4096x64x64 | 0.297 | 0.301 | 0.312 | 0.327 | 1.1 | 1.09 | 1.05 | 4 | 1.11 | 4.32 |
| lu | 128 | 0.105 | 0.105 | 0.105 | 0.105 | 0.999 | 1 | 1 | 4 | 1.01 | 1 |
| lu | 256 | 0.648 | 0.646 | 0.648 | 0.524 | 0.807 | 0.809 | 0.809 | 4 | 1.05 | 4.05 |
| lu | 512 | 3.89 | 3.85 | 3.84 | 2.83 | 0.726 | 0.733 | 0.734 | 4 | 1.03 | 4.02 |
| lu | 1024 | 17.2 | 16.4 | 17.2 | 12.8 | 0.747 | 0.76 | 0.743 | 4 | 1.04 | 4 |
| lu | 2048 | 84.9 | 81.5 | 82.6 | 72.9 | 0.859 | 0.895 | 0.882 | 4 | 1.01 | 3.98 |
| qr_factor | 128 | 0.308 | 0.31 | 0.305 | 0.303 | 0.992 | 0.986 | 0.999 | 4 | 1.03 | 4.1 |
| qr_factor | 256 | 1.26 | 1.26 | 1.3 | 0.984 | 0.779 | 0.779 | 0.754 | 4 | 1.01 | 3.95 |
| qr_factor | 512 | 3.98 | 3.99 | 4.11 | 4.05 | 1.02 | 1.01 | 0.986 | 4 | 1.01 | 4 |
| qr_factor | 1024 | 19.7 | 19.7 | 20.1 | 20.2 | 1.02 | 1.02 | 1 | 4 | 1.02 | 3.93 |
| qr_factor | 2048 | 130 | 131 | 133 | 133 | 1.02 | 1.01 | 0.998 | 4 | 1 | 3.99 |
| svd_values | 128 | 2.11 | 2.1 | 2.16 | 2.16 | 1.02 | 1.02 | 0.998 | 4 | 1 | 1.26 |
| svd_values | 256 | 10.3 | 10.3 | 10.3 | 10.3 | 1 | 1 | 0.998 | 4 | 1.01 | 1.21 |
| svd_values | 512 | 56.7 | 56.3 | 56.5 | 56.3 | 0.992 | 1 | 0.996 | 4 | 1.02 | 1.16 |
| svd_values | 1024 | 277 | 277 | 285 | 285 | 1.03 | 1.03 | 1 | 4 | 1 | 1.42 |
| svd_values | 2048 | 1.64e+03 | 1.65e+03 | 1.7e+03 | 1.7e+03 | 1.04 | 1.03 | 1 | 4 | 1 | 2.77 |

## Small-operation sequences, 4 threads (median of 41 repetitions, microseconds per call; settle 300 ms)

| sequence | held | hot | free | team | team/held | team/free | team cpu/wall | rot |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gemm32 | 2.31 | 2.32 | 2.31 | 2.5 | 1.08 | 1.08 | 1 | 4 |
| gemm64 | 17.2 | 17.3 | 17.2 | 5.49 | 0.319 | 0.32 | 4 | 4 |
| gemm128 | 135 | 135 | 135 | 40.3 | 0.299 | 0.299 | 4 | 4 |
| lu64 | 25 | 25.1 | 25 | 25 | 1 | 1 | 1 | 4 |
| lu128 | 109 | 110 | 109 | 110 | 1 | 1 | 1 | 4 |
| chain | 34.4 | 34.5 | 34.4 | 12.4 | 0.359 | 0.359 | 4 | 4 |

Engagement of the team row (one untimed pass per sequence):

* gemm32: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm64: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=2000 run[4:2000] split[]
* gemm128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=2000 run[4:2000] split[]
* lu64: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* lu128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* chain: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=1000 run[4:1000] split[]

## `fbench dispatch`, 4 threads: median ns over rotations (cpu/wall in brackets)

| test | gap us | held | hot | free | team |
| --- | --- | --- | --- | --- | --- |
| b2b_rayon_par_iter | 0 | 221 (4.38) | 1092 (3.98) | 4462 (3.87) |  |
| b2b_spindle_for_each | 0 | 1258 (3.88) | 1434 (4.00) | 4738 (3.90) |  |
| b2b_team_run | 0 |  |  |  | 613 (3.95) |
| gap_spindle_for_each | 0 | 1232 (3.92) | 1377 (4.00) | 4588 (3.88) |  |
| gap_spindle_for_each | 1 | 1227 (4.01) | 1372 (4.02) | 4609 (3.83) |  |
| gap_spindle_for_each | 10 | 1242 (4.00) | 1383 (4.00) | 5646 (3.68) |  |
| gap_spindle_for_each | 30 | 1242 (4.00) | 1392 (4.00) | 14036 (2.01) |  |
| gap_spindle_for_each | 100 | 1242 (4.00) | 1403 (4.00) | 14598 (1.40) |  |
| gap_spindle_for_each | 1000 | 1322 (4.00) | 1442 (4.00) | 14121 (1.06) |  |
| gap_spindle_for_each | 10000 | 23112 (1.65) | 1478 (4.00) | 34840 (1.01) |  |
| gap_spindle_for_each | 100000 | 23388 (1.06) | 1492 (4.00) | 35407 (1.00) |  |
| gap_team_run | 0 |  |  |  | 616 (3.97) |
| gap_team_run | 1 |  |  |  | 606 (4.01) |
| gap_team_run | 10 |  |  |  | 616 (4.00) |
| gap_team_run | 30 |  |  |  | 626 (4.00) |
| gap_team_run | 100 |  |  |  | 636 (4.00) |
| gap_team_run | 1000 |  |  |  | 722 (4.00) |
| gap_team_run | 10000 |  |  |  | 736 (4.00) |
| gap_team_run | 100000 |  |  |  | 762 (4.00) |

## Stage comparison, 8 threads: median wall time (ms) over rotations, ratios per rotation

Rows: held = `faer-fork` (spindle group held), hot = awake Rayon team, free = nothing held, team = `Par::Team`. Ratios are medians over the rotation processes of the per-process ratio (below 1: team faster). `rot` counts the row-order rotations that produced the cell (`--rotate-rows`); `pos` is the spread of the team ratio to held over rotations (max/min): a large value means row position matters.

| op | shape | held ms | hot ms | free ms | team ms | team/held | team/hot | team/free | rot | pos | team cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cholesky | 128 | 0.0554 | 0.0609 | 0.078 | 0.0809 | 1.44 | 1.33 | 1.03 | 4 | 1.04 | 3.92 |
| cholesky | 256 | 0.274 | 0.283 | 0.334 | 0.311 | 1.13 | 1.11 | 0.933 | 4 | 1.12 | 8.39 |
| cholesky | 512 | 1.17 | 1.14 | 1.26 | 5.26 | 4.21 | 4.4 | 3.99 | 4 | 10.4 | 7.75 |
| cholesky | 1024 | 3.68 | 3.69 | 3.97 | 10.9 | 2.95 | 2.95 | 2.74 | 4 | 10.7 | 7.62 |
| cholesky | 2048 | 18.2 | 17.7 | 18.5 | 106 | 5.75 | 5.86 | 5.6 | 4 | 3.54 | 7.73 |
| eigh | 128 | 2.25 | 2.26 | 2.25 | 2.25 | 1 | 0.998 | 0.999 | 4 | 1.01 | 1 |
| eigh | 256 | 7.54 | 7.52 | 7.86 | 7.81 | 1.04 | 1.04 | 0.994 | 4 | 1.01 | 1.43 |
| eigh | 512 | 29.6 | 29 | 29.6 | 29.6 | 1 | 1.02 | 1 | 4 | 1.01 | 1.83 |
| eigh | 1024 | 151 | 148 | 150 | 150 | 0.989 | 1.01 | 0.995 | 4 | 1.03 | 2.14 |
| eigh | 2048 | 600 | 584 | 604 | 604 | 1.01 | 1.04 | 1 | 4 | 1.03 | 4.35 |
| gemm | 64x4096x64 | 0.553 | 0.558 | 0.568 | 0.2 | 0.363 | 0.359 | 0.354 | 4 | 1.25 | 7.76 |
| gemm | 128x128x128 | 0.134 | 0.134 | 0.134 | 0.02 | 0.149 | 0.149 | 0.149 | 4 | 1.05 | 9.53 |
| gemm | 256x256x256 | 0.249 | 0.197 | 0.219 | 0.156 | 0.627 | 0.793 | 0.711 | 4 | 1.2 | 8.22 |
| gemm | 512x512x512 | 1.19 | 1.18 | 1.19 | 1.3 | 1.09 | 1.1 | 1.09 | 4 | 1.04 | 8.08 |
| gemm | 1024x1024x1024 | 8.99 | 9.01 | 9.04 | 9.97 | 1.11 | 1.11 | 1.1 | 4 | 1.04 | 8.01 |
| gemm | 2048x2048x64 | 3.11 | 3.15 | 3.17 | 3.63 | 1.17 | 1.15 | 1.15 | 4 | 1.03 | 7.99 |
| gemm | 2048x2048x2048 | 71.3 | 71.4 | 71.4 | 76.9 | 1.08 | 1.08 | 1.08 | 4 | 1.09 | 7.96 |
| gemm | 4096x64x64 | 0.157 | 0.164 | 0.178 | 0.161 | 1.02 | 0.982 | 0.901 | 4 | 1.07 | 7.14 |
| lu | 128 | 0.105 | 0.105 | 0.105 | 0.105 | 0.999 | 0.997 | 1 | 4 | 1.03 | 1.01 |
| lu | 256 | 0.648 | 0.647 | 0.645 | 0.515 | 0.774 | 0.774 | 0.775 | 4 | 1.07 | 8.27 |
| lu | 512 | 4.17 | 4.19 | 4.15 | 2.73 | 0.654 | 0.652 | 0.657 | 4 | 1.01 | 8.01 |
| lu | 1024 | 16 | 15.3 | 16 | 10.5 | 0.654 | 0.674 | 0.66 | 4 | 1.04 | 8.04 |
| lu | 2048 | 68.3 | 66.6 | 68.6 | 49.1 | 0.719 | 0.736 | 0.715 | 4 | 1.02 | 7.95 |
| qr_factor | 128 | 0.299 | 0.299 | 0.297 | 0.318 | 1.06 | 1.06 | 1.07 | 4 | 1.02 | 8.01 |
| qr_factor | 256 | 1.43 | 1.43 | 1.42 | 0.88 | 0.616 | 0.614 | 0.617 | 4 | 1.02 | 8.12 |
| qr_factor | 512 | 3.5 | 3.51 | 3.65 | 3.35 | 0.958 | 0.953 | 0.918 | 4 | 1.06 | 8.02 |
| qr_factor | 1024 | 14 | 14 | 14.4 | 14.6 | 1.04 | 1.04 | 1.01 | 4 | 1.04 | 7.76 |
| qr_factor | 2048 | 84.6 | 84.7 | 87.6 | 81.7 | 0.966 | 0.965 | 0.933 | 4 | 1.19 | 7.95 |
| svd_values | 128 | 2.12 | 2.11 | 2.18 | 2.16 | 1.02 | 1.02 | 0.989 | 4 | 1.01 | 1.29 |
| svd_values | 256 | 10.3 | 10.3 | 10.4 | 10.4 | 1.01 | 1.01 | 0.999 | 4 | 1.01 | 1.23 |
| svd_values | 512 | 56.5 | 56.3 | 56.5 | 56.4 | 0.999 | 1 | 0.998 | 4 | 1.01 | 1.17 |
| svd_values | 1024 | 284 | 282 | 290 | 290 | 1.03 | 1.03 | 0.999 | 4 | 1.02 | 1.47 |
| svd_values | 2048 | 1.43e+03 | 1.44e+03 | 1.53e+03 | 1.53e+03 | 1.07 | 1.06 | 1 | 4 | 1.02 | 4.3 |

## Small-operation sequences, 8 threads (median of 41 repetitions, microseconds per call; settle 300 ms)

| sequence | held | hot | free | team | team/held | team/free | team cpu/wall | rot |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gemm32 | 2.3 | 2.31 | 2.3 | 2.49 | 1.08 | 1.08 | 1 | 4 |
| gemm64 | 17.2 | 17.2 | 17.2 | 19 | 1.1 | 1.1 | 0.999 | 4 |
| gemm128 | 135 | 135 | 135 | 24.2 | 0.179 | 0.178 | 8 | 4 |
| lu64 | 24.9 | 24.8 | 24.9 | 24.9 | 1 | 1 | 1 | 4 |
| lu128 | 109 | 109 | 109 | 109 | 1 | 1 | 1 | 4 |
| chain | 34.4 | 34.5 | 34.4 | 8.66 | 0.252 | 0.251 | 8.01 | 4 |

Engagement of the team row (one untimed pass per sequence):

* gemm32: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm64: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=2000 run[8:2000] split[]
* lu64: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* lu128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* chain: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=1000 run[8:1000] split[]

## `fbench dispatch`, 8 threads: median ns over rotations (cpu/wall in brackets)

| test | gap us | held | hot | free | team |
| --- | --- | --- | --- | --- | --- |
| b2b_rayon_par_iter | 0 | 441 (5.37) | 2566 (8.00) | 6581 (7.89) |  |
| b2b_spindle_for_each | 0 | 2545 (7.91) | 2894 (8.00) | 7027 (7.87) |  |
| b2b_team_run | 0 |  |  |  | 1037 (7.79) |
| gap_spindle_for_each | 0 | 2374 (7.90) | 2735 (8.00) | 6742 (7.89) |  |
| gap_spindle_for_each | 1 | 2390 (7.96) | 2740 (8.02) | 6994 (7.81) |  |
| gap_spindle_for_each | 10 | 2384 (8.00) | 2746 (8.01) | 10524 (7.25) |  |
| gap_spindle_for_each | 30 | 2394 (7.99) | 2760 (8.00) | 13700 (4.29) |  |
| gap_spindle_for_each | 100 | 2394 (8.00) | 2790 (8.00) | 14352 (2.26) |  |
| gap_spindle_for_each | 1000 | 2560 (8.00) | 2850 (8.00) | 33648 (1.16) |  |
| gap_spindle_for_each | 10000 | 26374 (2.53) | 2885 (8.00) | 35596 (1.02) |  |
| gap_spindle_for_each | 100000 | 26784 (1.15) | 2931 (8.00) | 35346 (1.00) |  |
| gap_team_run | 0 |  |  |  | 982 (8.04) |
| gap_team_run | 1 |  |  |  | 972 (8.04) |
| gap_team_run | 10 |  |  |  | 982 (7.99) |
| gap_team_run | 30 |  |  |  | 982 (8.00) |
| gap_team_run | 100 |  |  |  | 986 (8.00) |
| gap_team_run | 1000 |  |  |  | 1077 (8.01) |
| gap_team_run | 10000 |  |  |  | 1087 (8.00) |
| gap_team_run | 100000 |  |  |  | 1127 (8.00) |


## Dispatch cost, pool of 8 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 | w=6 | w=8 |
| --- | --- | --- | --- | --- |
| team/hot | 1.60 | 1.45 | 1.32 | 1.14 |
| team/gap1ms | 4.85 | 3.74 | 2.36 | 1.27 |
| team/gap10ms | 5.91 | 4.46 | 2.96 | 1.27 |
| team/gap300ms | 82.44 | 83.64 | 83.03 | 84.12 |
| team/load10us-minus-10us | 2.83 | 2.23 | 1.66 | 1.11 |
| team/fork-hot | 1.63 | 1.50 | 1.44 | 1.27 |
| plain/outside-hot | 4.70 | 5.50 | 5.83 | 6.90 |
| plain/outside-gap1ms | 29.46 | 30.36 | 31.52 | 33.96 |
| plain/outside-gap10ms | 102.78 | 107.61 | 112.75 | 119.93 |
| plain/outside-load10us-minus-10us | 9.49 | 10.13 | 8.76 | 6.70 |
| external/outside-hot | 4.49 | 4.79 | 4.52 | 4.41 |
| external/outside-gap1ms | 29.16 | 29.05 | 24.25 | 29.20 |
| plain/in-pool | 0.44 | 1.06 | 1.51 | 2.07 |
| plain/in-pool-load10us-minus-10us | 3.08 | 3.58 | 3.52 | 3.03 |

## Dispatch cost, pool of 4 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 |
| --- | --- | --- |
| team/hot | 0.80 | 0.65 |
| team/gap1ms | 2.05 | 1.00 |
| team/gap10ms | 2.81 | 1.03 |
| team/gap300ms | 74.54 | 74.60 |
| team/load10us-minus-10us | 1.43 | 0.74 |
| team/fork-hot | 0.85 | 0.72 |
| plain/outside-hot | 3.99 | 4.37 |
| plain/outside-gap1ms | 28.88 | 31.15 |
| plain/outside-gap10ms | 99.64 | 111.32 |
| plain/outside-load10us-minus-10us | 6.36 | 5.87 |
| external/outside-hot | 2.95 | 2.94 |
| external/outside-gap1ms | 28.91 | 28.30 |
| plain/in-pool | 0.17 | 0.55 |
| plain/in-pool-load10us-minus-10us | 1.46 | 1.61 |

## Linux row of `DispatchCosts` (anchors 2, 4, 6 from the pool-of-8 processes; 10 us share rows)

```rust
// Measured on <host> (AMD Ryzen AI 9 HX 470), 8 threads on cores 4-11, boost off, from the back to back sections whose
// shares carry 10 us of work (faer-benchmark data/probes/20261026-awake-team-linux), us at widths 2, 4, 6:
// team: 2.8, 2.2, 1.7
// in_pool: 3.1, 3.6, 3.5
// outside: 9.5, 10.1, 8.8
pub fn linux_x86() -> Self {
    DispatchCosts {
        team: WidthCosts::new([us_f(2.8), us_f(2.2), us_f(1.7)]),
        in_pool: WidthCosts::new([us_f(3.1), us_f(3.6), us_f(3.5)]),
        outside: WidthCosts::new([us_f(9.5), us_f(10.1), us_f(8.8)]),
    }
}
```

Width 8 against the model's proportional extrapolation above the last anchor (`cost(6) * 8 / 6`):

| kind | measured w=8 us | model us | ratio |
| --- | --- | --- | --- |
| team | 1.11 | 2.21 | 0.50 |
| in_pool | 3.03 | 4.69 | 0.65 |
| outside | 6.70 | 11.68 | 0.57 |

M5 row for comparison (`DispatchCosts::apple_m5`): team 3.0, 2.3, 1.4; in pool 6.0, 11, 5.5; outside 14, 18, 19.

## Wake latency after a park (`wake_probe`; microseconds, median over processes; parked = 12 ms pause with a 2 ms idle spin)

| pool | width | variant | state | total | slowest share start | late > 1 ms | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | 2 | plain Exec::fork | idle | 94.1 | 83.7 | 0% | 112.1 |
| 4 | 2 | team qos=builder-default | parked | 70.6 | 69.7 | 0% | 107.4 |
| 4 | 2 | team qos=builder-default | spinning | 0.7 | 0.5 | 0% | 2.2 |
| 4 | 4 | plain Exec::fork | idle | 111.7 | 91.6 | 0% | 144.3 |
| 4 | 4 | team qos=builder-default | parked | 72.3 | 71.3 | 0% | 538.4 |
| 4 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 20.5 |
| 8 | 2 | plain Exec::fork | idle | 80.7 | 67.5 | 0% | 114.1 |
| 8 | 2 | team qos=builder-default | parked | 63.4 | 62.7 | 0% | 98.3 |
| 8 | 2 | team qos=builder-default | spinning | 0.7 | 0.5 | 0% | 8.2 |
| 8 | 4 | plain Exec::fork | idle | 103.1 | 92.0 | 0% | 136.6 |
| 8 | 4 | team qos=builder-default | parked | 72.7 | 71.8 | 0% | 117.7 |
| 8 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 7.8 |
| 8 | 8 | plain Exec::fork | idle | 116.8 | 103.2 | 0% | 180.0 |
| 8 | 8 | team qos=builder-default | parked | 83.0 | 82.2 | 0% | 108.8 |
| 8 | 8 | team qos=builder-default | spinning | 1.2 | 1.0 | 0% | 21.5 |

## Idle spin trace `idle-trace-T4.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 4, idle_spin 200 ms; members m1..m3 (the pool has 4 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.30  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.1 ms  cpu/wall 3.93  | m0: spin   2% park   0% run  98% m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 4.01  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.18  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.37  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0%
```

## Idle spin trace `idle-trace-T8.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 8, idle_spin 200 ms; members m1..m7 (the pool has 8 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.70  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0% m4: spin  10% park  90% run   0% m5: spin  10% park  90% run   0% m6: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.1 ms  cpu/wall 7.91  | m0: spin   3% park   0% run  97% m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97% m3: spin   3% park   0% run  97% m4: spin   3% park   0% run  97% m5: spin   3% park   0% run  97% m6: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.41  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0% m4: spin   6% park  94% run   0% m5: spin   6% park  94% run   0% m6: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.86  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0% m4: spin  12% park  88% run   0% m5: spin  12% park  88% run   0% m6: spin  12% park  88% run   0%
```


## Serial throughput constants, 1 thread on core 4 (ns per unit; median over shapes and rounds)

M5 = thresholds.md 2.3 (Apple M5 Max). ratio = Linux / M5.

| family | type | median | range | cells | M5 | ratio |
| --- | --- | --- | --- | --- | --- | --- |
| bidiag | c64 | 2.3332 | 1.9632 to 2.6550 | 10 | 1.36 | 1.72 |
| bidiag | f64 | 1.0362 | 0.7847 to 1.4101 | 10 | 0.48 | 2.16 |
| block_apply_per_mac | c64 | 0.2691 | 0.2667 to 0.2768 | 6 | 0.165 | 1.63 |
| block_apply_per_mac | f64 | 0.0667 | 0.0662 to 0.0692 | 6 | 0.037 | 1.80 |
| bunch_kaufman_full | c64 | 1.3893 | 1.3236 to 1.5057 | 10 | 0.38 | 3.66 |
| bunch_kaufman_full | f64 | 0.8351 | 0.8003 to 0.9045 | 10 | 0.238 | 3.51 |
| gemm_per_mac | c32 | 0.1280 | 0.1275 to 0.1299 | 8 |  |  |
| gemm_per_mac | c64 | 0.2568 | 0.2550 to 0.2584 | 8 | 0.165 | 1.56 |
| gemm_per_mac | f32 | 0.0320 | 0.0318 to 0.0328 | 8 |  |  |
| gemm_per_mac | f64 | 0.0640 | 0.0637 to 0.0650 | 8 | 0.037 | 1.73 |
| hessenberg_unblocked | c64 | 2.3084 | 2.1331 to 2.5007 | 8 | 1.57 | 1.47 |
| hessenberg_unblocked | f64 | 0.8581 | 0.7117 to 1.1089 | 8 | 0.451 | 1.90 |
| householder_rank_one | c64 | 1.0222 | 0.9958 to 1.0966 | 8 | 0.725 | 1.41 |
| householder_rank_one | f64 | 0.4780 | 0.4647 to 0.4882 | 8 | 0.212 | 2.25 |
| lu_full_pivot | c64 | 0.8689 | 0.7725 to 1.0531 | 10 | 0.6 | 1.45 |
| lu_full_pivot | f64 | 0.4002 | 0.3386 to 0.4637 | 10 | 0.216 | 1.85 |
| lu_partial_per_flop | c64 | 0.1845 | 0.1448 to 0.2666 | 8 |  |  |
| lu_partial_per_flop | f64 | 0.0657 | 0.0405 to 0.1310 | 8 | 0.03 | 2.19 |
| matvec_colmajor | c64 | 0.5517 | 0.5216 to 0.5868 | 10 | 0.281 | 1.96 |
| matvec_colmajor | f64 | 0.1734 | 0.1505 to 0.1782 | 10 | 0.112 | 1.55 |
| matvec_rowmajor | c64 | 0.5057 | 0.4843 to 0.5657 | 10 | 0.425 | 1.19 |
| matvec_rowmajor | f64 | 0.1541 | 0.1379 to 0.1662 | 10 | 0.087 | 1.77 |
| qr_col_pivot | c64 | 1.0284 | 0.8597 to 1.4165 | 10 | 0.713 | 1.44 |
| qr_col_pivot | f64 | 0.3647 | 0.2996 to 0.5481 | 10 | 0.202 | 1.81 |
| triangular_matmul_per_mac | c64 | 0.2807 | 0.2718 to 0.3031 | 6 | 0.176 | 1.60 |
| triangular_matmul_per_mac | f64 | 0.0711 | 0.0704 to 0.0791 | 6 | 0.039 | 1.82 |
| triangular_solve_per_mac | c64 | 0.4169 | 0.3688 to 0.4646 | 4 | 0.187 | 2.23 |
| triangular_solve_per_mac | f64 | 0.0915 | 0.0834 to 0.0998 | 4 | 0.051 | 1.80 |
| tridiag | c64 | 1.9156 | 1.6807 to 2.5008 | 10 | 1.16 | 1.65 |
| tridiag | f64 | 0.7717 | 0.5594 to 1.2831 | 10 | 0.339 | 2.28 |

## Region constants (block apply streaming, divide and conquer solves, triangular inverse, sparse product)

| group | median ns/unit | range | cells |
| --- | --- | --- | --- |
| bsvd_f64 | 0.80390 | 0.29975 to 2.62943 | 14 |
| spmm_c64_n20000_d8 | 8.30794 | 8.29423 to 8.32164 | 2 |
| spmm_c64_n2000_d12 | 3.88370 | 3.82376 to 3.94363 | 2 |
| spmm_c64_n2000_d4 | 4.38224 | 4.37409 to 4.39040 | 2 |
| spmm_c64_n4000_d40 | 4.56232 | 4.55060 to 4.57404 | 2 |
| spmm_c64_n8000_d16 | 5.74778 | 5.74539 to 5.75016 | 2 |
| spmm_c64_n8000_d6 | 5.78613 | 5.78479 to 5.78747 | 2 |
| spmm_f64_n20000_d8 | 5.93704 | 5.92005 to 5.95403 | 2 |
| spmm_f64_n2000_d12 | 3.01528 | 3.00902 to 3.02155 | 2 |
| spmm_f64_n2000_d4 | 3.99281 | 3.96648 to 4.01915 | 2 |
| spmm_f64_n4000_d40 | 3.26361 | 3.24952 to 3.27769 | 2 |
| spmm_f64_n8000_d16 | 4.21012 | 4.19904 to 4.22119 | 2 |
| spmm_f64_n8000_d6 | 4.88959 | 4.69582 to 5.08336 | 2 |
| tevd_f64 | 0.49281 | 0.19950 to 1.38034 | 14 |
| tinv_c64 | 0.07258 | 0.05421 to 0.13999 | 14 |
| tinv_f64 | 0.01942 | 0.01443 to 0.04708 | 14 |

### strided, tcontract, cpueinsum chain, width 8 (median over processes and rounds; ratios to serial, below 1 is a win)

#### copy

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 0.24 | 0.26 | 0.26 | 0.26 | 1.09 | 1.09 | 1.08 | 4 |
| 2048 | 0.42 | 0.44 | 0.45 | 0.44 | 1.05 | 1.05 | 1.05 | 4 |
| 4096 | 1.01 | 1.04 | 1.04 | 1.04 | 1.02 | 1.03 | 1.02 | 4 |
| 8192 | 1.91 | 1.94 | 1.94 | 1.93 | 1.01 | 1.01 | 1.01 | 4 |
| 16384 | 2.80 | 2.83 | 2.83 | 2.82 | 1.01 | 1.01 | 1.01 | 4 |
| 32768 | 4.29 | 4.32 | 4.32 | 4.32 | 1.01 | 1.01 | 1.01 | 4 |
| 65536 | 19.06 | 19.16 | 17.07 | 19.07 | 1.00 | 0.90 | 1.00 | 4 |
| 131072 | 37.19 | 37.25 | 37.19 | 20.64 | 1.00 | 1.00 | 0.56 | 4 |
| 262144 | 82.16 | 82.57 | 80.27 | 21.66 | 1.00 | 0.98 | 0.26 | 4 |
| 524288 | 157 | 159 | 93.60 | 20.34 | 1.01 | 0.60 | 0.13 | 4 |
| 1048576 | 346 | 335 | 208 | 73.66 | 0.97 | 0.60 | 0.21 | 4 |
| 2097152 | 844 | 697 | 674 | 606 | 0.83 | 0.80 | 0.72 | 4 |

#### map

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 0.20 | 0.22 | 0.22 | 0.22 | 1.09 | 1.09 | 1.08 | 4 |
| 2048 | 0.32 | 0.34 | 0.34 | 0.34 | 1.06 | 1.07 | 1.06 | 4 |
| 4096 | 0.77 | 0.79 | 0.80 | 0.79 | 1.03 | 1.04 | 1.03 | 4 |
| 8192 | 1.42 | 1.45 | 1.45 | 1.45 | 1.02 | 1.02 | 1.02 | 4 |
| 16384 | 2.83 | 2.86 | 2.85 | 2.86 | 1.01 | 1.01 | 1.01 | 4 |
| 32768 | 5.21 | 5.23 | 5.23 | 5.24 | 1.00 | 1.00 | 1.01 | 4 |
| 65536 | 14.96 | 14.94 | 14.87 | 14.92 | 1.00 | 0.99 | 1.00 | 4 |
| 131072 | 39.17 | 38.94 | 39.29 | 20.37 | 0.99 | 1.00 | 0.52 | 4 |
| 262144 | 82.87 | 82.37 | 83.22 | 20.89 | 0.99 | 1.00 | 0.25 | 4 |
| 524288 | 173 | 185 | 95.32 | 20.82 | 1.07 | 0.55 | 0.12 | 4 |
| 1048576 | 360 | 362 | 210 | 75.16 | 1.01 | 0.58 | 0.21 | 4 |
| 2097152 | 939 | 692 | 672 | 605 | 0.74 | 0.72 | 0.64 | 4 |

#### exp

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 5.74 | 5.77 | 5.78 | 5.77 | 1.00 | 1.01 | 1.00 | 4 |
| 2048 | 11.45 | 11.48 | 11.65 | 11.46 | 1.00 | 1.02 | 1.00 | 4 |
| 4096 | 22.92 | 23.02 | 23.39 | 22.98 | 1.00 | 1.02 | 1.00 | 4 |
| 8192 | 45.72 | 45.84 | 46.29 | 46.03 | 1.00 | 1.01 | 1.01 | 4 |
| 16384 | 89.65 | 89.67 | 92.80 | 89.65 | 1.00 | 1.04 | 1.00 | 4 |
| 32768 | 179 | 179 | 180 | 179 | 1.00 | 1.00 | 1.00 | 4 |
| 65536 | 361 | 361 | 412 | 360 | 1.00 | 1.14 | 1.00 | 4 |
| 131072 | 726 | 720 | 839 | 366 | 0.99 | 1.16 | 0.50 | 4 |
| 262144 | 1441 | 1443 | 1681 | 373 | 1.00 | 1.17 | 0.26 | 4 |
| 524288 | 2981 | 3047 | 1456 | 368 | 1.02 | 0.49 | 0.12 | 4 |
| 1048576 | 5969 | 5872 | 1473 | 734 | 0.98 | 0.25 | 0.12 | 4 |
| 2097152 | 11931 | 1524 | 1522 | 1496 | 0.13 | 0.13 | 0.13 | 4 |

#### sum

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 0.12 | 0.14 | 0.14 | 0.13 | 1.19 | 1.20 | 1.16 | 4 |
| 2048 | 0.23 | 0.25 | 0.25 | 0.24 | 1.09 | 1.10 | 1.07 | 4 |
| 4096 | 0.43 | 0.45 | 0.45 | 0.44 | 1.05 | 1.05 | 1.03 | 4 |
| 8192 | 0.89 | 0.91 | 0.91 | 0.91 | 1.03 | 1.03 | 1.02 | 4 |
| 16384 | 1.72 | 1.74 | 1.74 | 1.74 | 1.01 | 1.02 | 1.01 | 4 |
| 32768 | 3.36 | 3.38 | 3.38 | 3.38 | 1.01 | 1.01 | 1.01 | 4 |
| 65536 | 6.66 | 6.67 | 6.68 | 6.68 | 1.00 | 1.00 | 1.00 | 4 |
| 131072 | 17.09 | 17.16 | 17.08 | 9.90 | 1.00 | 1.00 | 0.58 | 4 |
| 262144 | 39.98 | 40.05 | 40.02 | 9.98 | 1.00 | 1.00 | 0.25 | 4 |
| 524288 | 87.97 | 88.04 | 86.50 | 12.58 | 1.00 | 0.98 | 0.14 | 4 |
| 1048576 | 192 | 197 | 102 | 19.67 | 1.03 | 0.53 | 0.10 | 4 |
| 2097152 | 353 | 242 | 204 | 68.44 | 0.69 | 0.58 | 0.19 | 4 |

#### tc_matmul

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 32 | 2.53 | 2.62 | 2.62 | 2.80 | 1.03 | 1.04 | 1.11 | 4 |
| 48 | 7.54 | 7.68 | 7.68 | 7.86 | 1.02 | 1.02 | 1.04 | 4 |
| 64 | 17.23 | 17.41 | 17.41 | 5.58 | 1.01 | 1.01 | 0.32 | 4 |
| 96 | 56.98 | 57.17 | 57.20 | 9.07 | 1.00 | 1.00 | 0.16 | 4 |
| 128 | 134 | 134 | 135 | 19.68 | 1.00 | 1.00 | 0.15 | 4 |
| 192 | 453 | 148 | 148 | 60.59 | 0.33 | 0.33 | 0.13 | 4 |
| 256 | 1070 | 219 | 204 | 155 | 0.20 | 0.19 | 0.14 | 4 |

#### einsum_chain

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 32 | 4.99 | 5.28 | 5.41 | 5.56 | 1.06 | 1.09 | 1.11 | 4 |
| 48 | 15.11 | 15.39 | 15.78 | 15.74 | 1.02 | 1.04 | 1.04 | 4 |
| 64 | 34.72 | 35.04 | 35.21 | 12.02 | 1.01 | 1.01 | 0.35 | 4 |
| 96 | 114 | 114 | 116 | 19.16 | 1.00 | 1.02 | 0.17 | 4 |
| 128 | 269 | 269 | 270 | 44.13 | 1.00 | 1.00 | 0.16 | 4 |
| 192 | 905 | 301 | 293 | 126 | 0.33 | 0.32 | 0.14 | 4 |

#### break-even: first shape after which the mode stays below 0.95 x serial (serial time there)

| family | plain_out | plain_in | team |
|---|---|---|---|
| copy | 2097152 (844 us) | 524288 (157 us) | 131072 (37.19 us) |
| map | 2097152 (939 us) | 524288 (173 us) | 131072 (39.17 us) |
| exp | 2097152 (11931 us) | 524288 (2981 us) | 131072 (726 us) |
| sum | 2097152 (353 us) | 1048576 (192 us) | 131072 (17.09 us) |
| tc_matmul | 192 (453 us) | 192 (453 us) | 64 (17.23 us) |
| einsum_chain | 192 (905 us) | 192 (905 us) | 64 (34.72 us) |
### strided, tcontract, cpueinsum chain, width 4 (median over processes and rounds; ratios to serial, below 1 is a win)

#### copy

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 0.24 | 0.26 | 0.26 | 0.26 | 1.09 | 1.08 | 1.07 | 2 |
| 2048 | 0.40 | 0.42 | 0.42 | 0.42 | 1.05 | 1.05 | 1.05 | 2 |
| 4096 | 0.99 | 1.02 | 1.02 | 1.01 | 1.02 | 1.03 | 1.02 | 2 |
| 8192 | 1.93 | 1.95 | 1.95 | 1.95 | 1.01 | 1.01 | 1.01 | 2 |
| 16384 | 2.81 | 2.83 | 2.83 | 2.82 | 1.01 | 1.01 | 1.01 | 2 |
| 32768 | 4.31 | 4.33 | 4.33 | 4.32 | 1.01 | 1.00 | 1.00 | 2 |
| 65536 | 13.09 | 13.14 | 13.21 | 13.15 | 1.00 | 1.01 | 1.00 | 2 |
| 131072 | 37.13 | 37.60 | 37.20 | 18.66 | 1.01 | 1.00 | 0.50 | 2 |
| 262144 | 80.42 | 82.56 | 80.81 | 19.02 | 1.03 | 1.00 | 0.24 | 2 |
| 524288 | 156 | 158 | 94.97 | 43.23 | 1.02 | 0.61 | 0.28 | 2 |
| 1048576 | 341 | 329 | 212 | 182 | 0.96 | 0.62 | 0.53 | 2 |
| 2097152 | 853 | 671 | 656 | 655 | 0.79 | 0.77 | 0.77 | 2 |

#### map

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 0.19 | 0.21 | 0.21 | 0.21 | 1.10 | 1.10 | 1.09 | 2 |
| 2048 | 0.36 | 0.38 | 0.38 | 0.38 | 1.05 | 1.05 | 1.05 | 2 |
| 4096 | 0.76 | 0.78 | 0.80 | 0.79 | 1.03 | 1.05 | 1.04 | 2 |
| 8192 | 1.43 | 1.45 | 1.45 | 1.44 | 1.02 | 1.01 | 1.01 | 2 |
| 16384 | 2.83 | 2.85 | 2.85 | 2.85 | 1.01 | 1.01 | 1.01 | 2 |
| 32768 | 5.21 | 5.23 | 5.23 | 5.23 | 1.00 | 1.00 | 1.00 | 2 |
| 65536 | 15.04 | 15.12 | 15.01 | 15.14 | 1.01 | 1.00 | 1.01 | 2 |
| 131072 | 38.95 | 39.03 | 39.12 | 19.63 | 1.00 | 1.00 | 0.50 | 2 |
| 262144 | 82.07 | 82.06 | 82.24 | 18.83 | 1.00 | 1.00 | 0.23 | 2 |
| 524288 | 185 | 182 | 93.25 | 43.13 | 0.99 | 0.51 | 0.23 | 2 |
| 1048576 | 400 | 360 | 214 | 179 | 0.90 | 0.54 | 0.45 | 2 |
| 2097152 | 939 | 668 | 659 | 653 | 0.71 | 0.70 | 0.70 | 2 |

#### exp

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 5.86 | 5.84 | 5.86 | 5.88 | 1.00 | 1.00 | 1.00 | 2 |
| 2048 | 11.51 | 11.46 | 11.61 | 11.47 | 1.00 | 1.01 | 1.00 | 2 |
| 4096 | 23.12 | 22.82 | 23.14 | 22.96 | 0.99 | 1.00 | 0.99 | 2 |
| 8192 | 45.92 | 45.82 | 47.13 | 45.87 | 1.00 | 1.03 | 1.00 | 2 |
| 16384 | 91.24 | 89.60 | 89.59 | 90.13 | 0.98 | 0.98 | 0.99 | 2 |
| 32768 | 180 | 179 | 182 | 180 | 0.99 | 1.01 | 1.00 | 2 |
| 65536 | 390 | 390 | 420 | 420 | 1.00 | 1.08 | 1.08 | 2 |
| 131072 | 775 | 775 | 839 | 363 | 1.00 | 1.08 | 0.47 | 2 |
| 262144 | 1561 | 1527 | 1682 | 364 | 0.98 | 1.08 | 0.23 | 2 |
| 524288 | 3000 | 3167 | 1445 | 723 | 1.06 | 0.48 | 0.24 | 2 |
| 1048576 | 6108 | 6249 | 1479 | 1466 | 1.02 | 0.24 | 0.24 | 2 |
| 2097152 | 12464 | 3156 | 3108 | 3253 | 0.25 | 0.25 | 0.26 | 2 |

#### sum

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 1024 | 0.12 | 0.14 | 0.14 | 0.13 | 1.19 | 1.22 | 1.16 | 2 |
| 2048 | 0.23 | 0.25 | 0.25 | 0.25 | 1.10 | 1.11 | 1.08 | 2 |
| 4096 | 0.42 | 0.44 | 0.45 | 0.45 | 1.05 | 1.06 | 1.06 | 2 |
| 8192 | 0.88 | 0.91 | 0.91 | 0.91 | 1.03 | 1.03 | 1.03 | 2 |
| 16384 | 1.71 | 1.73 | 1.74 | 1.74 | 1.01 | 1.01 | 1.02 | 2 |
| 32768 | 3.36 | 3.37 | 3.39 | 3.38 | 1.00 | 1.01 | 1.01 | 2 |
| 65536 | 6.65 | 6.68 | 6.68 | 6.67 | 1.00 | 1.00 | 1.00 | 2 |
| 131072 | 16.51 | 16.66 | 16.80 | 8.43 | 1.01 | 1.02 | 0.51 | 2 |
| 262144 | 39.95 | 39.69 | 40.05 | 7.83 | 0.99 | 1.00 | 0.20 | 2 |
| 524288 | 86.57 | 85.74 | 86.64 | 18.42 | 0.99 | 1.00 | 0.21 | 2 |
| 1048576 | 177 | 184 | 101 | 42.89 | 1.04 | 0.57 | 0.24 | 2 |
| 2097152 | 352 | 248 | 171 | 152 | 0.71 | 0.48 | 0.43 | 2 |

#### tc_matmul

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 32 | 2.53 | 2.53 | 2.53 | 2.82 | 1.00 | 1.00 | 1.11 | 2 |
| 48 | 7.53 | 7.59 | 7.60 | 7.92 | 1.01 | 1.01 | 1.05 | 2 |
| 64 | 17.26 | 17.33 | 17.33 | 5.79 | 1.00 | 1.00 | 0.34 | 2 |
| 96 | 57.06 | 57.03 | 57.05 | 15.84 | 1.00 | 1.00 | 0.28 | 2 |
| 128 | 134 | 134 | 134 | 37.58 | 1.00 | 1.00 | 0.28 | 2 |
| 192 | 453 | 153 | 149 | 122 | 0.34 | 0.33 | 0.27 | 2 |
| 256 | 1070 | 310 | 300 | 293 | 0.29 | 0.28 | 0.27 | 2 |

#### einsum_chain

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| 32 | 4.99 | 5.13 | 5.29 | 5.47 | 1.03 | 1.06 | 1.10 | 2 |
| 48 | 15.13 | 15.25 | 15.62 | 15.64 | 1.01 | 1.03 | 1.03 | 2 |
| 64 | 34.70 | 34.88 | 35.04 | 12.17 | 1.01 | 1.01 | 0.35 | 2 |
| 96 | 114 | 114 | 116 | 32.13 | 1.00 | 1.01 | 0.28 | 2 |
| 128 | 269 | 269 | 269 | 79.86 | 1.00 | 1.00 | 0.30 | 2 |
| 192 | 905 | 312 | 306 | 247 | 0.34 | 0.34 | 0.27 | 2 |

#### break-even: first shape after which the mode stays below 0.95 x serial (serial time there)

| family | plain_out | plain_in | team |
|---|---|---|---|
| copy | 2097152 (853 us) | 524288 (156 us) | 131072 (37.13 us) |
| map | 1048576 (400 us) | 524288 (185 us) | 131072 (38.95 us) |
| exp | 2097152 (12464 us) | 524288 (3000 us) | 131072 (775 us) |
| sum | 2097152 (352 us) | 1048576 (177 us) | 131072 (16.51 us) |
| tc_matmul | 192 (453 us) | 192 (453 us) | 64 (17.26 us) |
| einsum_chain | 192 (905 us) | 192 (905 us) | 64 (34.70 us) |
### tlinalg batched small LU and QR, width 8 (median over processes and rounds; ratios to serial, below 1 is a win)

#### tl_lu

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| n4xb1 | 0.50 | 0.91 | 0.92 | 0.87 | 1.81 | 1.83 | 1.73 | 4 |
| n4xb8 | 2.11 | 2.43 | 2.47 | 2.42 | 1.15 | 1.17 | 1.15 | 4 |
| n4xb64 | 14.69 | 14.99 | 15.07 | 15.18 | 1.02 | 1.03 | 1.03 | 4 |
| n4xb256 | 57.80 | 58.22 | 58.47 | 58.80 | 1.01 | 1.01 | 1.02 | 4 |
| n8xb1 | 0.88 | 1.29 | 1.30 | 1.24 | 1.46 | 1.47 | 1.41 | 4 |
| n8xb8 | 5.16 | 5.47 | 5.47 | 5.47 | 1.06 | 1.06 | 1.06 | 4 |
| n8xb64 | 38.70 | 39.05 | 38.88 | 39.08 | 1.01 | 1.00 | 1.01 | 4 |
| n8xb256 | 155 | 155 | 154 | 154 | 1.00 | 0.99 | 1.00 | 4 |
| n16xb1 | 2.06 | 2.45 | 2.48 | 2.40 | 1.19 | 1.21 | 1.17 | 4 |
| n16xb8 | 14.67 | 14.99 | 15.06 | 15.04 | 1.02 | 1.03 | 1.03 | 4 |
| n16xb64 | 117 | 117 | 117 | 117 | 1.00 | 1.01 | 1.00 | 4 |
| n16xb256 | 469 | 470 | 471 | 79.18 | 1.00 | 1.00 | 0.17 | 4 |
| n32xb1 | 5.43 | 5.87 | 5.94 | 5.86 | 1.08 | 1.09 | 1.08 | 4 |
| n32xb8 | 41.55 | 41.90 | 42.23 | 42.06 | 1.01 | 1.02 | 1.01 | 4 |
| n32xb64 | 333 | 337 | 339 | 61.35 | 1.01 | 1.02 | 0.18 | 4 |
| n32xb256 | 1352 | 1352 | 254 | 239 | 1.00 | 0.19 | 0.18 | 4 |
| n64xb1 | 20.86 | 21.29 | 21.33 | 21.14 | 1.02 | 1.02 | 1.01 | 4 |
| n64xb8 | 165 | 165 | 161 | 32.26 | 1.00 | 0.98 | 0.20 | 4 |
| n64xb64 | 1345 | 258 | 255 | 240 | 0.19 | 0.19 | 0.18 | 4 |
| n64xb256 | 5951 | 1188 | 1200 | 1077 | 0.20 | 0.20 | 0.18 | 4 |
| n128xb1 | 96.84 | 97.19 | 96.57 | 98.39 | 1.00 | 1.00 | 1.02 | 4 |
| n128xb8 | 806 | 156 | 151 | 140 | 0.19 | 0.19 | 0.17 | 4 |
| n128xb64 | 7034 | 1342 | 1314 | 1217 | 0.19 | 0.19 | 0.17 | 4 |
| n128xb256 | 28337 | 5480 | 5383 | 5144 | 0.19 | 0.19 | 0.18 | 4 |

#### tl_qr

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| n8xb1 | 2.70 | 3.17 | 3.22 | 3.25 | 1.18 | 1.19 | 1.21 | 4 |
| n8xb8 | 18.16 | 18.52 | 18.67 | 19.37 | 1.02 | 1.03 | 1.07 | 4 |
| n8xb64 | 142 | 142 | 142 | 148 | 1.00 | 1.00 | 1.04 | 4 |
| n8xb256 | 562 | 561 | 571 | 591 | 1.00 | 1.02 | 1.05 | 4 |
| n16xb1 | 8.80 | 9.31 | 9.35 | 9.51 | 1.06 | 1.06 | 1.08 | 4 |
| n16xb8 | 66.94 | 67.45 | 67.68 | 69.49 | 1.01 | 1.01 | 1.04 | 4 |
| n16xb64 | 533 | 531 | 534 | 545 | 1.00 | 1.00 | 1.02 | 4 |
| n16xb256 | 2130 | 2128 | 2134 | 280 | 1.00 | 1.00 | 0.13 | 4 |
| n32xb1 | 34.96 | 35.31 | 35.59 | 36.47 | 1.01 | 1.02 | 1.04 | 4 |
| n32xb8 | 275 | 275 | 276 | 285 | 1.00 | 1.00 | 1.03 | 4 |
| n32xb64 | 2207 | 2201 | 283 | 291 | 1.00 | 0.13 | 0.13 | 4 |
| n32xb256 | 8853 | 1124 | 1120 | 1157 | 0.13 | 0.13 | 0.13 | 4 |
| n64xb1 | 138 | 138 | 138 | 151 | 1.00 | 1.00 | 1.10 | 4 |
| n64xb8 | 1097 | 1096 | 152 | 161 | 1.00 | 0.14 | 0.15 | 4 |
| n64xb64 | 8763 | 1120 | 1112 | 1206 | 0.13 | 0.13 | 0.14 | 4 |
| n64xb256 | 35053 | 4506 | 4481 | 4898 | 0.13 | 0.13 | 0.14 | 4 |
| n128xb1 | 584 | 585 | 603 | 624 | 1.00 | 1.03 | 1.07 | 4 |
| n128xb8 | 4671 | 646 | 642 | 703 | 0.14 | 0.14 | 0.15 | 4 |
| n128xb64 | 37423 | 4860 | 4829 | 5529 | 0.13 | 0.13 | 0.15 | 4 |
| n128xb256 | 149701 | 19172 | 19139 | 21903 | 0.13 | 0.13 | 0.15 | 4 |

#### break-even: first shape after which the mode stays below 0.95 x serial (serial time there)

| family | plain_out | plain_in | team |
|---|---|---|---|
| tl_lu | n128xb8 (806 us) | n128xb8 (806 us) | n128xb8 (806 us) |
| tl_qr | n128xb8 (4671 us) | n128xb8 (4671 us) | n128xb8 (4671 us) |
### tlinalg batched small LU and QR, width 4 (median over processes and rounds; ratios to serial, below 1 is a win)

#### tl_lu

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| n4xb1 | 0.50 | 0.73 | 0.74 | 0.72 | 1.45 | 1.48 | 1.43 | 2 |
| n4xb8 | 2.15 | 2.32 | 2.31 | 2.27 | 1.08 | 1.08 | 1.06 | 2 |
| n4xb64 | 14.67 | 14.82 | 15.02 | 14.89 | 1.01 | 1.02 | 1.02 | 2 |
| n4xb256 | 57.94 | 58.08 | 58.56 | 58.31 | 1.00 | 1.01 | 1.01 | 2 |
| n8xb1 | 0.88 | 1.12 | 1.12 | 1.12 | 1.27 | 1.27 | 1.26 | 2 |
| n8xb8 | 5.19 | 5.41 | 5.37 | 5.43 | 1.04 | 1.03 | 1.05 | 2 |
| n8xb64 | 39.91 | 39.62 | 39.50 | 39.46 | 0.99 | 0.99 | 0.99 | 2 |
| n8xb256 | 156 | 157 | 156 | 157 | 1.00 | 1.00 | 1.01 | 2 |
| n16xb1 | 2.13 | 2.36 | 2.35 | 2.33 | 1.11 | 1.10 | 1.09 | 2 |
| n16xb8 | 15.33 | 15.31 | 15.27 | 15.39 | 1.00 | 1.00 | 1.00 | 2 |
| n16xb64 | 120 | 121 | 123 | 121 | 1.01 | 1.02 | 1.01 | 2 |
| n16xb256 | 485 | 489 | 485 | 138 | 1.01 | 1.00 | 0.29 | 2 |
| n32xb1 | 5.54 | 5.79 | 5.85 | 5.80 | 1.05 | 1.06 | 1.05 | 2 |
| n32xb8 | 42.42 | 42.71 | 42.82 | 42.52 | 1.01 | 1.01 | 1.00 | 2 |
| n32xb64 | 342 | 341 | 344 | 102 | 1.00 | 1.01 | 0.30 | 2 |
| n32xb256 | 1385 | 1377 | 426 | 415 | 0.99 | 0.31 | 0.30 | 2 |
| n64xb1 | 21.17 | 21.37 | 21.27 | 21.19 | 1.01 | 1.00 | 1.00 | 2 |
| n64xb8 | 166 | 166 | 164 | 50.54 | 1.00 | 0.99 | 0.30 | 2 |
| n64xb64 | 1349 | 410 | 404 | 396 | 0.30 | 0.30 | 0.29 | 2 |
| n64xb256 | 5989 | 1916 | 1913 | 1827 | 0.32 | 0.32 | 0.31 | 2 |
| n128xb1 | 95.76 | 96.31 | 96.45 | 98.52 | 1.01 | 1.01 | 1.03 | 2 |
| n128xb8 | 820 | 256 | 240 | 237 | 0.31 | 0.29 | 0.29 | 2 |
| n128xb64 | 7101 | 2218 | 2185 | 2094 | 0.31 | 0.31 | 0.29 | 2 |
| n128xb256 | 28629 | 8678 | 8651 | 8490 | 0.30 | 0.30 | 0.30 | 2 |

#### tl_qr

| shape | seq us | plain_out us | plain_in us | team us | plain_out/seq | plain_in/seq | team/seq | n |
|---|---|---|---|---|---|---|---|---|
| n8xb1 | 2.71 | 2.98 | 3.00 | 3.11 | 1.10 | 1.11 | 1.15 | 2 |
| n8xb8 | 18.38 | 18.51 | 18.52 | 19.36 | 1.01 | 1.01 | 1.05 | 2 |
| n8xb64 | 141 | 141 | 142 | 149 | 1.00 | 1.01 | 1.05 | 2 |
| n8xb256 | 568 | 565 | 567 | 590 | 0.99 | 1.00 | 1.04 | 2 |
| n16xb1 | 8.92 | 9.17 | 9.18 | 9.46 | 1.03 | 1.03 | 1.06 | 2 |
| n16xb8 | 67.64 | 67.93 | 68.09 | 69.50 | 1.00 | 1.01 | 1.03 | 2 |
| n16xb64 | 543 | 543 | 538 | 553 | 1.00 | 0.99 | 1.02 | 2 |
| n16xb256 | 2146 | 2170 | 2156 | 559 | 1.01 | 1.00 | 0.26 | 2 |
| n32xb1 | 35.16 | 35.39 | 35.41 | 36.31 | 1.01 | 1.01 | 1.03 | 2 |
| n32xb8 | 275 | 276 | 276 | 284 | 1.00 | 1.00 | 1.03 | 2 |
| n32xb64 | 2209 | 2215 | 559 | 576 | 1.00 | 0.25 | 0.26 | 2 |
| n32xb256 | 8863 | 2239 | 2237 | 2306 | 0.25 | 0.25 | 0.26 | 2 |
| n64xb1 | 137 | 137 | 138 | 150 | 1.00 | 1.01 | 1.09 | 2 |
| n64xb8 | 1092 | 1092 | 280 | 300 | 1.00 | 0.26 | 0.27 | 2 |
| n64xb64 | 8740 | 2250 | 2215 | 2383 | 0.26 | 0.25 | 0.27 | 2 |
| n64xb256 | 35039 | 8904 | 8900 | 9626 | 0.25 | 0.25 | 0.27 | 2 |
| n128xb1 | 587 | 588 | 607 | 568 | 1.00 | 1.03 | 0.97 | 2 |
| n128xb8 | 4695 | 1201 | 1191 | 1339 | 0.26 | 0.25 | 0.29 | 2 |
| n128xb64 | 37564 | 9581 | 9530 | 10770 | 0.26 | 0.25 | 0.29 | 2 |
| n128xb256 | 150221 | 38476 | 38011 | 43076 | 0.26 | 0.25 | 0.29 | 2 |

#### break-even: first shape after which the mode stays below 0.95 x serial (serial time there)

| family | plain_out | plain_in | team |
|---|---|---|---|
| tl_lu | n128xb8 (820 us) | n128xb8 (820 us) | n128xb8 (820 us) |
| tl_qr | n128xb8 (4695 us) | n128xb8 (4695 us) | n128xb8 (4695 us) |

## x86_64 GEMM path: which threads run the product (`fbench diag-gemm`)

Per row and size: `participants` = distinct threads that took a share of 200 probe fan-outs through the row's own entry point (`spindle::for_each_raw` inside `with_lock` for held; Rayon `par_iter` for hot and free; `Team::run` for team, plus the leader); `busy` = of those, busy more than half of the wall time during the GEMM loop; `cpu participants / other` = on-CPU ms of the probed threads against all other threads of the process (other pool threads, e.g. the idle Rayon pool under the team row). A row whose work runs where its probe says has `cpu other` near 0; for lu/qr_factor/cholesky under the team row a non-zero `cpu other` / `busy other threads` is `private-gemm-x86` threading through spindle outside the team (`par.degree()` of a team token).

| process | row | op+n | calls | per call ms | participants | busy | cpu participants ms | cpu other ms | busy other threads | team counters |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| diag-gemm-T4-p1 | faer-fork | gemm512 | 1366 | 2.1976 | 4 | 4 | 12006.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | gemm1024 | 172 | 17.5304 | 4 | 4 | 12061.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu512 | 779 | 3.8514 | 4 | 4 | 12000.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu1024 | 174 | 17.2606 | 4 | 4 | 11388.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor512 | 736 | 4.0766 | 4 | 4 | 11998.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor1024 | 149 | 20.2014 | 4 | 4 | 12038.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky512 | 2289 | 1.3110 | 4 | 4 | 12003.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky1024 | 534 | 5.6254 | 4 | 4 | 12014.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm512 | 1361 | 2.2055 | 4 | 4 | 11989.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm1024 | 171 | 17.6090 | 4 | 4 | 12039.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu512 | 785 | 3.8244 | 4 | 4 | 11998.6 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu1024 | 177 | 17.0278 | 4 | 4 | 12040.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor512 | 736 | 4.0788 | 4 | 4 | 12005.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor1024 | 149 | 20.2134 | 4 | 4 | 12040.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky512 | 2348 | 1.2782 | 4 | 4 | 11944.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky1024 | 548 | 5.4812 | 4 | 4 | 11969.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm512 | 1355 | 2.2141 | 5 | 4 | 11984.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm1024 | 171 | 17.5939 | 5 | 4 | 12023.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu512 | 776 | 3.8685 | 5 | 1 | 4330.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu1024 | 172 | 17.4762 | 5 | 1 | 6053.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor512 | 710 | 4.2288 | 5 | 1 | 6555.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor1024 | 146 | 20.5744 | 5 | 4 | 8625.6 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky512 | 2079 | 1.4436 | 5 | 1 | 6041.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky1024 | 523 | 5.7368 | 5 | 4 | 8767.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-team | gemm512 | 1329 | 2.2584 | 4 | 4 | 12002.1 | 0.0 | 0 | gemm_tiled=1329 gemm_below_floor=0 gemm_one_tile=0 run[4:1329] split[] |
| diag-gemm-T4-p1 | faer-fork-team | gemm1024 | 163 | 18.4535 | 4 | 4 | 12030.9 | 0.0 | 0 | gemm_tiled=163 gemm_below_floor=0 gemm_one_tile=0 run[4:163] split[] |
| diag-gemm-T4-p1 | faer-fork-team | lu512 | 1009 | 2.9753 | 4 | 4 | 12007.2 | 0.0 | 0 | gemm_tiled=12108 gemm_below_floor=90810 gemm_one_tile=0 run[2:4036 4:8072] split[2:8072 4:2018] |
| diag-gemm-T4-p1 | faer-fork-team | lu1024 | 232 | 12.9528 | 4 | 4 | 12018.9 | 0.0 | 0 | gemm_tiled=8352 gemm_below_floor=44080 gemm_one_tile=0 run[2:1856 4:6496] split[2:6496 4:1392] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor512 | 726 | 4.1374 | 4 | 4 | 12013.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=310002 gemm_one_tile=0 run[] split[2:11616 4:13068] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor1024 | 147 | 20.4779 | 4 | 4 | 12041.9 | 0.0 | 0 | gemm_tiled=1764 gemm_below_floor=147735 gemm_one_tile=0 run[2:1764] split[2:12936 4:9702] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky512 | 1606 | 1.8682 | 4 | 3 | 9601.0 | 2383.1 | 4 | gemm_tiled=3212 gemm_below_floor=83512 gemm_one_tile=0 run[2:3212] split[2:11242] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky1024 | 323 | 9.2989 | 4 | 3 | 7441.5 | 4457.0 | 4 | gemm_tiled=646 gemm_below_floor=20672 gemm_one_tile=0 run[2:646] split[2:6137] |
| diag-gemm-T8-p1 | faer-fork | gemm512 | 2546 | 1.1788 | 8 | 8 | 24010.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | gemm1024 | 335 | 8.9792 | 8 | 8 | 24061.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu512 | 721 | 4.1643 | 8 | 8 | 14848.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu1024 | 186 | 16.1416 | 8 | 8 | 20984.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor512 | 829 | 3.6209 | 8 | 8 | 24012.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor1024 | 208 | 14.4402 | 8 | 8 | 24030.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky512 | 2214 | 1.3555 | 8 | 8 | 24005.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky1024 | 695 | 4.3192 | 8 | 8 | 24013.6 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm512 | 2563 | 1.1709 | 8 | 8 | 23909.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm1024 | 333 | 9.0296 | 8 | 8 | 24032.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu512 | 727 | 4.1282 | 8 | 8 | 23993.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu1024 | 186 | 16.2083 | 8 | 8 | 24078.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor512 | 847 | 3.5427 | 8 | 8 | 24005.6 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor1024 | 208 | 14.4696 | 8 | 8 | 24075.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky512 | 2456 | 1.2220 | 8 | 8 | 23745.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky1024 | 698 | 4.3031 | 8 | 8 | 23844.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm512 | 2547 | 1.1782 | 9 | 8 | 23908.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm1024 | 333 | 9.0339 | 9 | 8 | 24030.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu512 | 698 | 4.2989 | 9 | 1 | 3987.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu1024 | 188 | 16.0304 | 9 | 1 | 7038.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor512 | 796 | 3.7717 | 9 | 1 | 8343.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor1024 | 201 | 14.9348 | 9 | 1 | 12831.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky512 | 2203 | 1.3620 | 9 | 1 | 10072.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky1024 | 644 | 4.6627 | 9 | 2 | 13353.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-team | gemm512 | 2402 | 1.2493 | 8 | 8 | 24022.0 | 0.0 | 0 | gemm_tiled=2402 gemm_below_floor=0 gemm_one_tile=0 run[8:2402] split[] |
| diag-gemm-T8-p1 | faer-fork-team | gemm1024 | 296 | 10.1446 | 8 | 8 | 24022.8 | 0.0 | 0 | gemm_tiled=296 gemm_below_floor=0 gemm_one_tile=0 run[8:296] split[] |
| diag-gemm-T8-p1 | faer-fork-team | lu512 | 1046 | 2.8693 | 8 | 8 | 24012.3 | 0.0 | 0 | gemm_tiled=19874 gemm_below_floor=84726 gemm_one_tile=0 run[2:8368 4:4184 8:7322] split[2:8368] |
| diag-gemm-T8-p1 | faer-fork-team | lu1024 | 279 | 10.7529 | 8 | 8 | 23998.9 | 0.0 | 0 | gemm_tiled=13671 gemm_below_floor=110205 gemm_one_tile=0 run[2:4464 4:2232 8:6975] split[2:12276 8:558] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor512 | 849 | 3.5374 | 8 | 8 | 24029.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=551001 gemm_one_tile=0 run[] split[2:10188 8:11886] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor1024 | 203 | 14.7829 | 8 | 8 | 24006.9 | 0.0 | 0 | gemm_tiled=2436 gemm_below_floor=288260 gemm_one_tile=0 run[4:2436] split[2:15022 4:2030 8:8526] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky512 | 455 | 6.5950 | 8 | 7 | 15832.6 | 7347.6 | 8 | gemm_tiled=2730 gemm_below_floor=47320 gemm_one_tile=0 run[2:1820 4:910] split[2:5005] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky1024 | 265 | 11.4123 | 8 | 7 | 15015.8 | 8846.3 | 8 | gemm_tiled=1590 gemm_below_floor=45580 gemm_one_tile=0 run[2:1060 4:530] split[2:10335] |
| diag-gemm-T8-p2 | faer-fork | gemm512 | 2544 | 1.1794 | 8 | 8 | 23998.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | gemm1024 | 334 | 8.9858 | 8 | 8 | 24005.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu512 | 722 | 4.1579 | 8 | 8 | 14842.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu1024 | 186 | 16.1428 | 8 | 8 | 20974.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor512 | 831 | 3.6103 | 8 | 8 | 23998.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor1024 | 209 | 14.4110 | 8 | 8 | 24096.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky512 | 2227 | 1.3474 | 8 | 8 | 24006.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky1024 | 694 | 4.3238 | 8 | 8 | 24006.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | gemm512 | 2561 | 1.1717 | 8 | 8 | 23896.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | gemm1024 | 333 | 9.0167 | 8 | 8 | 24000.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu512 | 696 | 4.3162 | 8 | 8 | 24018.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu1024 | 186 | 16.1723 | 8 | 8 | 24012.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor512 | 822 | 3.6515 | 8 | 8 | 24006.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor1024 | 205 | 14.6568 | 8 | 8 | 24033.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky512 | 2459 | 1.2200 | 8 | 8 | 23719.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky1024 | 697 | 4.3066 | 8 | 8 | 23824.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm512 | 2550 | 1.1769 | 9 | 8 | 23900.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm1024 | 333 | 9.0249 | 9 | 8 | 24004.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu512 | 694 | 4.3275 | 9 | 1 | 3983.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu1024 | 188 | 16.0195 | 9 | 1 | 7043.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor512 | 792 | 3.7907 | 9 | 1 | 8310.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor1024 | 202 | 14.8983 | 9 | 1 | 12881.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky512 | 2239 | 1.3399 | 9 | 1 | 10071.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky1024 | 648 | 4.6327 | 9 | 2 | 13345.7 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-team | gemm512 | 2388 | 1.2564 | 8 | 8 | 24013.9 | 0.0 | 0 | gemm_tiled=2388 gemm_below_floor=0 gemm_one_tile=0 run[8:2388] split[] |
| diag-gemm-T8-p2 | faer-fork-team | gemm1024 | 300 | 10.0163 | 8 | 8 | 24038.8 | 0.0 | 0 | gemm_tiled=300 gemm_below_floor=0 gemm_one_tile=0 run[8:300] split[] |
| diag-gemm-T8-p2 | faer-fork-team | lu512 | 1045 | 2.8712 | 8 | 8 | 23998.3 | 0.0 | 0 | gemm_tiled=19855 gemm_below_floor=84645 gemm_one_tile=0 run[2:8360 4:4180 8:7315] split[2:8360] |
| diag-gemm-T8-p2 | faer-fork-team | lu1024 | 279 | 10.7857 | 8 | 8 | 24070.8 | 0.0 | 0 | gemm_tiled=13671 gemm_below_floor=110205 gemm_one_tile=0 run[2:4464 4:2232 8:6975] split[2:12276 8:558] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor512 | 857 | 3.5012 | 8 | 8 | 24006.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=556193 gemm_one_tile=0 run[] split[2:10284 8:11998] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor1024 | 204 | 14.7409 | 8 | 8 | 24062.6 | 0.0 | 0 | gemm_tiled=2448 gemm_below_floor=289680 gemm_one_tile=0 run[4:2448] split[2:15096 4:2040 8:8568] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky512 | 384 | 7.8275 | 8 | 7 | 16064.5 | 6963.3 | 8 | gemm_tiled=2304 gemm_below_floor=39936 gemm_one_tile=0 run[2:1536 4:768] split[2:4224] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky1024 | 96 | 31.2968 | 8 | 7 | 14809.2 | 8398.3 | 8 | gemm_tiled=576 gemm_below_floor=16512 gemm_one_tile=0 run[2:384 4:192] split[2:3744] |

## Host protocol per process

| process | mask | attempt | idle before | idle after | unmeasured-domain busy (max) | load1 before | top 3 before | governor | boost | EPP | platform profile |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fbench-verify-T8 | 4-11 | 1 | idle | idle | 0.0 | 0.52 | 5.3 claude; 1.2 python3; 0.6 herdr | performance | 0 | performance | None |
| dispatch-T8-p1 | 4-11 | 1 | idle | idle | 0.005 | 0.56 | 5.2 claude; 0.9 python3; 0.6 herdr | performance | 0 | performance | None |
| dispatch-T8-p2 | 4-11 | 1 | idle | idle | 0.001 | 4.10 | 5.1 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-T8-p3 | 4-11 | 1 | idle | idle | 0.0 | 4.37 | 4.9 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-T4-p1 | 4-7 | 1 | idle | idle | 0.001 | 4.60 | 4.7 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-T4-p2 | 4-7 | 1 | idle | idle | 0.0 | 3.41 | 4.6 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-T4-p3 | 4-7 | 1 | idle | idle | 0.001 | 2.47 | 4.5 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| wake-T8-p1 | 4-11 | 1 | idle | idle | 0.001 | 2.65 | 4.5 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| wake-T8-p2 | 4-11 | 1 | idle | idle | 0.001 | 2.48 | 4.4 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| wake-T4-p1 | 4-7 | 1 | idle | idle | 0.004 | 1.84 | 4.4 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| idle-trace-T8 | 4-11 | 1 | idle | idle | 0.0 | 1.38 | 4.3 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| idle-trace-T4 | 4-7 | 1 | idle | idle | 0.0 | 1.24 | 4.3 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-gemm-r0 | 4 | 1 | idle | idle | 0.0 | 1.13 | 4.3 claude; 1.2 python3; 0.6 herdr | performance | 0 | performance | None |
| consts-lu_partial-r0 | 4 | 1 | idle | idle | 0.0 | 1.03 | 4.3 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-lu_full-r0 | 4 | 1 | idle | idle | 0.0 | 0.94 | 4.3 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-bk-r0 | 4 | 1 | idle | idle | 0.0 | 0.94 | 4.2 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-qr_cp-r0 | 4 | 1 | idle | idle | 0.0 | 0.88 | 4.2 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-bidiag-r0 | 4 | 1 | idle | idle | 0.0 | 0.82 | 4.2 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-hess-r0 | 4 | 1 | idle | idle | 0.0 | 0.78 | 4.2 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-tridiag-r0 | 4 | 1 | idle | idle | 0.0 | 0.73 | 4.2 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-matvec-r0 | 4 | 1 | idle | idle | 0.0 | 0.71 | 100 ps; 4.2 claude; 0.6 herdr | performance | 0 | performance | None |
| consts-rank_one-r0 | 4 | 1 | idle | idle | 0.0 | 0.76 | 4.1 claude; 0.6 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-block_apply-r0 | 4 | 1 | idle | idle | 0.0 | 0.71 | 4.1 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-tri-r0 | 4 | 1 | idle | idle | 0.0 | 0.68 | 4.1 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-bsvd-r0 | 4 | 1 | idle | idle | 0.0 | 0.65 | 4.1 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-tevd-r0 | 4 | 1 | idle | idle | 0.0 | 0.65 | 4.1 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-tinv-r0 | 4 | 1 | idle | idle | 0.002 | 0.62 | 4.1 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-spmm-r0 | 4 | 1 | idle | idle | 0.0 | 0.62 | 4.0 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-gemm-r1 | 4 | 1 | idle | idle | 0.0 | 0.58 | 4.0 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-lu_partial-r1 | 4 | 1 | idle | idle | 0.0 | 0.56 | 4.0 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-lu_full-r1 | 4 | 1 | idle | idle | 0.0 | 0.55 | 4.0 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-bk-r1 | 4 | 1 | idle | idle | 0.0 | 0.57 | 4.0 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-qr_cp-r1 | 4 | 1 | idle | idle | 0.0 | 0.56 | 3.9 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-bidiag-r1 | 4 | 1 | idle | idle | 0.0 | 0.57 | 3.9 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-hess-r1 | 4 | 1 | idle | idle | 0.0 | 0.51 | 3.9 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-tridiag-r1 | 4 | 1 | idle | idle | 0.0 | 0.51 | 100 ps; 3.9 claude; 0.5 herdr | performance | 0 | performance | None |
| consts-matvec-r1 | 4 | 1 | idle | idle | 0.0 | 0.46 | 3.9 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-rank_one-r1 | 4 | 1 | idle | idle | 0.0 | 0.47 | 3.9 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-block_apply-r1 | 4 | 1 | idle | idle | 0.0 | 0.39 | 3.9 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| consts-tri-r1 | 4 | 1 | idle | idle | 0.0 | 0.41 | 3.8 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-bsvd-r1 | 4 | 1 | idle | idle | 0.0 | 0.50 | 3.8 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-tevd-r1 | 4 | 1 | idle | idle | 0.0 | 0.52 | 3.8 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-tinv-r1 | 4 | 1 | idle | idle | 0.001 | 0.52 | 3.8 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| rconsts-spmm-r1 | 4 | 1 | idle | idle | 0.0 | 0.54 | 3.8 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| diag-gemm-T8-p1 | 4-11 | 1 | idle | idle | 0.001 | 0.56 | 3.8 claude; 1.2 python3; 0.5 herdr | performance | 0 | performance | None |
| diag-gemm-T8-p2 | 4-11 | 1 | idle | idle | 0.002 | 5.35 | 3.6 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| diag-gemm-T4-p1 | 4-7 | 1 | idle | idle | 0.001 | 7.11 | 3.5 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T4-rot0 | 4-7 | 1 | idle | idle | 0.001 | 4.33 | 3.4 claude; 1.2 python3; 0.5 herdr | performance | 0 | performance | None |
| main-small-T4-rot1 | 4-7 | 1 | idle | idle | 0.002 | 3.10 | 3.4 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T4-rot2 | 4-7 | 1 | idle | idle | 0.001 | 2.96 | 3.3 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T4-rot3 | 4-7 | 1 | idle | idle | 0.001 | 2.89 | 3.3 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T4-rot0 | 4-7 | 1 | idle | idle | 0.001 | 2.53 | 3.3 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T4-rot1 | 4-7 | 1 | idle | idle | 0.003 | 1.98 | 3.2 claude; 0.5 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T4-rot2 | 4-7 | 1 | idle | idle | 0.002 | 1.77 | 3.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T4-rot3 | 4-7 | 1 | idle | idle | 0.004 | 3.08 | 3.1 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T4-rot0 | 4-7 | 1 | idle | idle | 0.006 | 2.72 | 3.1 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T4-rot1 | 4-7 | 1 | idle | idle | 0.004 | 3.00 | 3.0 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T4-rot2 | 4-7 | 1 | idle | idle | 0.004 | 3.04 | 2.9 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T4-rot3 | 4-7 | 1 | idle | idle | 0.005 | 3.26 | 2.8 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T4-rot0 | 4-7 | 1 | idle | idle | 0.0 | 2.56 | 2.7 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T4-rot1 | 4-7 | 1 | idle | idle | 0.0 | 2.46 | 2.7 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T4-rot2 | 4-7 | 1 | idle | idle | 0.0 | 2.38 | 2.7 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T4-rot3 | 4-7 | 1 | idle | idle | 0.0 | 2.31 | 2.7 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T4-rot0 | 4-7 | 1 | idle | idle | 0.002 | 2.25 | 2.7 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T4-rot1 | 4-7 | 1 | idle | idle | 0.006 | 2.16 | 2.7 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T4-rot2 | 4-7 | 1 | idle | idle | 0.002 | 1.74 | 2.6 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T4-rot3 | 4-7 | 1 | idle | idle | 0.001 | 1.67 | 100 ps; 2.6 claude; 0.4 herdr | performance | 0 | performance | None |
| dispatch-fbench-T4-rot0 | 4-7 | 1 | idle | idle | 0.001 | 1.79 | 2.6 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T4-rot1 | 4-7 | 1 | idle | idle | 0.001 | 1.98 | 2.6 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T4-rot2 | 4-7 | 1 | idle | idle | 0.001 | 2.15 | 2.5 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T4-rot3 | 4-7 | 1 | idle | idle | 0.001 | 2.12 | 2.5 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T8-rot0 | 4-11 | 1 | idle | idle | 0.001 | 2.05 | 2.5 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T8-rot1 | 4-11 | 1 | idle | idle | 0.001 | 2.60 | 2.5 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T8-rot2 | 4-11 | 1 | idle | idle | 0.003 | 3.27 | 2.5 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-small-T8-rot3 | 4-11 | 1 | idle | idle | 0.001 | 3.51 | 2.4 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T8-rot0 | 4-11 | 1 | idle | idle | 0.001 | 4.02 | 2.4 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T8-rot1 | 4-11 | 1 | idle | idle | 0.001 | 4.24 | 2.4 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T8-rot2 | 4-11 | 1 | idle | idle | 0.001 | 4.01 | 2.4 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n1024-T8-rot3 | 4-11 | 1 | idle | idle | 0.002 | 3.76 | 2.4 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T8-rot0 | 4-11 | 1 | idle | idle | 0.002 | 3.12 | 2.4 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T8-rot1 | 4-11 | 1 | idle | idle | 0.003 | 4.80 | 2.3 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T8-rot2 | 4-11 | 1 | idle | idle | 0.002 | 3.77 | 2.3 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-n2048-T8-rot3 | 4-11 | 1 | idle | idle | 0.002 | 5.37 | 2.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T8-rot0 | 4-11 | 1 | idle | idle | 0.0 | 5.73 | 2.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T8-rot1 | 4-11 | 1 | idle | idle | 0.0 | 5.44 | 2.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T8-rot2 | 4-11 | 1 | idle | idle | 0.0 | 5.35 | 2.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| main-skinny-T8-rot3 | 4-11 | 1 | idle | idle | 0.0 | 5.11 | 2.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T8-rot0 | 4-11 | 1 | idle | idle | 0.001 | 4.40 | 2.2 claude; 0.4 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T8-rot1 | 4-11 | 1 | idle | idle | 0.001 | 3.00 | 2.2 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T8-rot2 | 4-11 | 1 | idle | idle | 0.004 | 2.43 | 2.2 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| smallops-seq-T8-rot3 | 4-11 | 1 | idle | idle | 0.001 | 3.34 | 2.1 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T8-rot0 | 4-11 | 1 | idle | idle | 0.002 | 2.73 | 2.1 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T8-rot1 | 4-11 | 1 | idle | idle | 0.0 | 4.06 | 2.1 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T8-rot2 | 4-11 | 1 | idle | idle | 0.001 | 3.81 | 2.1 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| dispatch-fbench-T8-rot3 | 4-11 | 1 | idle | idle | 0.001 | 4.48 | 2.1 claude; 0.3 herdr; 0.3 gnome-shell | performance | 0 | performance | None |
| confirm-T8-p1 | 4-11 | 1 | idle | idle | 0.005 | 3.97 | 2.1 claude; 1.2 python3; 0.3 herdr | performance | 0 | performance | None |
| tlinalg-T8-p1 | 4-11 | 1 | idle | idle | 0.002 | 0.88 | 2.0 claude; 0.3 herdr; 0.3 herdr | performance | 0 | performance | None |
| confirm-T8-p2 | 4-11 | 1 | idle | idle | 0.004 | 0.85 | 2.0 claude; 0.3 herdr; 0.3 herdr | performance | 0 | performance | None |
| tlinalg-T8-p2 | 4-11 | 1 | idle | idle | 0.005 | 0.77 | 2.0 claude; 0.3 herdr; 0.3 herdr | performance | 0 | performance | None |
| confirm-T4-p1 | 4-7 | 1 | idle | idle | 0.006 | 1.35 | 2.0 claude; 0.3 herdr; 0.3 herdr | performance | 0 | performance | None |
| tlinalg-T4-p1 | 4-7 | 1 | idle | idle | 0.004 | 1.01 | 2.0 claude; 0.3 herdr; 0.3 herdr | performance | 0 | performance | None |

