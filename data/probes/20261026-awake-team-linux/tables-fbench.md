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

