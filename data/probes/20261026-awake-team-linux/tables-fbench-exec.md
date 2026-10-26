## Stage comparison, 4 threads: median wall time (ms) over rotations, ratios per rotation

Rows: held = `faer-fork` (spindle group held), upstream = upstream faer 0.24.4 (spindle group held), hot = awake Rayon team, free = nothing held, team = `Par::Team`. Ratios are medians over the rotation processes of the per-process ratio (below 1: team faster). `rot` counts the row-order rotations that produced the cell (`--rotate-rows`); `pos` is the spread of the team ratio to held over rotations (max/min): a large value means row position matters.

| op | shape | held ms | upstream ms | hot ms | free ms | team ms | team/held | team/upstream | team/hot | team/free | rot | pos | team cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cholesky | 128 | 0.0645 | 0.0616 | 0.0579 | 0.0734 | 0.059 | 0.908 | 0.951 | 1.02 | 0.805 | 5 | 1.13 | 1.01 |
| cholesky | 256 | 0.256 | 0.259 | 0.22 | 0.296 | 0.21 | 0.842 | 0.797 | 0.965 | 0.726 | 5 | 1.19 | 3.82 |
| cholesky | 512 | 0.91 | 0.937 | 0.827 | 0.941 | 0.794 | 0.894 | 0.859 | 0.961 | 0.846 | 5 | 1.07 | 3.94 |
| cholesky | 1024 | 4.63 | 4.69 | 4.32 | 4.53 | 4.25 | 0.925 | 0.904 | 0.984 | 0.943 | 5 | 1.01 | 4.01 |
| cholesky | 2048 | 30.3 | 30.6 | 28.8 | 29.4 | 28.6 | 0.945 | 0.936 | 0.995 | 0.975 | 5 | 1.02 | 3.94 |
| eigh | 128 | 2.25 | 2.15 | 2.26 | 2.26 | 2.26 | 1 | 1.05 | 1 | 1 | 5 | 1.01 | 1 |
| eigh | 256 | 6.94 | 6.76 | 6.88 | 7.1 | 7.09 | 1.03 | 1.05 | 1.03 | 1 | 5 | 1.01 | 1.52 |
| eigh | 512 | 27.8 | 24.6 | 27.6 | 28.6 | 28.5 | 1.02 | 1.16 | 1.03 | 0.996 | 5 | 1.02 | 1.98 |
| eigh | 1024 | 121 | 114 | 121 | 125 | 125 | 1.03 | 1.1 | 1.03 | 1 | 5 | 1.02 | 2.7 |
| eigh | 2048 | 805 | 782 | 797 | 811 | 812 | 1.01 | 1.04 | 1.02 | 1 | 5 | 1.01 | 3.14 |
| gemm | 64x4096x64 | 1.2 | 1.2 | 1.19 | 1.2 | 1.2 | 0.988 | 1 | 0.998 | 0.998 | 5 | 1.05 | 4 |
| gemm | 128x128x128 | 0.0676 | 0.0729 | 0.0508 | 0.0784 | 0.0607 | 0.947 | 0.803 | 1.2 | 0.776 | 5 | 13.9 | 4.25 |
| gemm | 256x256x256 | 0.307 | 0.308 | 0.295 | 0.308 | 0.308 | 1 | 1 | 1.04 | 0.996 | 5 | 1.02 | 4.08 |
| gemm | 512x512x512 | 2.2 | 2.21 | 2.21 | 2.24 | 2.2 | 0.999 | 1 | 0.996 | 0.984 | 5 | 1 | 3.99 |
| gemm | 1024x1024x1024 | 17.5 | 17.5 | 17.5 | 17.5 | 17.5 | 1 | 1 | 0.998 | 0.997 | 5 | 1 | 4.01 |
| gemm | 2048x2048x64 | 5.71 | 5.73 | 5.74 | 5.77 | 5.72 | 1 | 1 | 0.995 | 0.992 | 5 | 1.01 | 4 |
| gemm | 2048x2048x2048 | 141 | 141 | 141 | 141 | 141 | 1 | 1 | 0.999 | 1 | 5 | 1.01 | 3.99 |
| gemm | 4096x64x64 | 0.296 | 0.296 | 0.299 | 0.311 | 0.295 | 0.998 | 0.996 | 0.987 | 0.952 | 5 | 1.01 | 4.27 |
| lu | 128 | 0.105 | 0.117 | 0.106 | 0.106 | 0.106 | 1.01 | 0.905 | 0.999 | 1 | 5 | 1.02 | 1 |
| lu | 256 | 0.566 | 0.594 | 0.553 | 0.583 | 0.562 | 0.987 | 0.931 | 0.999 | 0.955 | 5 | 1.07 | 3.97 |
| lu | 512 | 3.12 | 2.94 | 2.96 | 3.12 | 2.82 | 0.903 | 0.967 | 0.953 | 0.903 | 5 | 1.03 | 4.02 |
| lu | 1024 | 13.6 | 12.8 | 12.7 | 13.2 | 12.2 | 0.896 | 0.955 | 0.959 | 0.925 | 5 | 1.01 | 4 |
| lu | 2048 | 77 | 73.9 | 72.2 | 73.6 | 70.3 | 0.915 | 0.951 | 0.974 | 0.956 | 5 | 1.01 | 3.98 |
| qr_factor | 128 | 0.295 | 0.411 | 0.297 | 0.295 | 0.254 | 0.859 | 0.612 | 0.856 | 0.861 | 5 | 1.01 | 4.16 |
| qr_factor | 256 | 0.901 | 1.3 | 0.903 | 0.956 | 0.889 | 0.988 | 0.681 | 0.984 | 0.931 | 5 | 1.01 | 3.97 |
| qr_factor | 512 | 3.6 | 4.41 | 3.62 | 3.76 | 3.54 | 0.984 | 0.802 | 0.978 | 0.94 | 5 | 1 | 4.01 |
| qr_factor | 1024 | 19 | 20.5 | 19 | 19.9 | 18.6 | 0.981 | 0.907 | 0.978 | 0.935 | 5 | 1 | 3.92 |
| qr_factor | 2048 | 130 | 135 | 129 | 132 | 127 | 0.977 | 0.94 | 0.987 | 0.965 | 5 | 1.02 | 3.99 |
| svd_values | 128 | 2.12 | 2.11 | 2.1 | 2.17 | 2.17 | 1.03 | 1.03 | 1.03 | 1 | 5 | 1.02 | 1.26 |
| svd_values | 256 | 10.3 | 10.3 | 10.3 | 10.3 | 10.3 | 1.01 | 1 | 1 | 1 | 5 | 1 | 1.21 |
| svd_values | 512 | 50.2 | 40.9 | 51.4 | 52.3 | 52.3 | 1.04 | 1.28 | 1.02 | 1 | 5 | 1.01 | 1.5 |
| svd_values | 1024 | 192 | 180 | 202 | 211 | 211 | 1.1 | 1.17 | 1.05 | 0.999 | 5 | 1.02 | 2.15 |
| svd_values | 2048 | 1.53e+03 | 1.52e+03 | 1.54e+03 | 1.6e+03 | 1.6e+03 | 1.04 | 1.05 | 1.04 | 1 | 5 | 1 | 2.98 |

## Small-operation sequences, 4 threads (median of 41 repetitions, microseconds per call; settle 300 ms)

| sequence | held | upstream | hot | free | team | team/held | team/upstream | team/free | team cpu/wall | rot |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gemm32 | 2.34 | 3.77 | 2.34 | 2.34 | 2.37 | 1.01 | 0.629 | 1.01 | 1 | 5 |
| gemm64 | 17.3 | 18.9 | 17.3 | 17.2 | 17.3 | 1 | 0.914 | 1 | 0.999 | 5 |
| gemm128 | 73.9 | 75.9 | 61.2 | 76.8 | 70.3 | 0.963 | 0.91 | 0.916 | 4 | 5 |
| lu64 | 24.9 | 27.2 | 25 | 24.9 | 25 | 1 | 0.924 | 1 | 1 | 5 |
| lu128 | 110 | 120 | 110 | 110 | 110 | 1 | 0.916 | 1 | 1 | 5 |
| chain | 34.4 | 24.4 | 34.5 | 34.4 | 23.6 | 0.684 | 0.96 | 0.685 | 4 | 5 |

Engagement of the team row (one untimed pass per sequence):

* gemm32: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm64: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[4:2000] split[]
* lu64: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* lu128: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* chain: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[4:1000] split[]

## `fbench dispatch`, 4 threads: median ns over rotations (cpu/wall in brackets)

| test | gap us | held | upstream | hot | free | team |
| --- | --- | --- | --- | --- | --- | --- |
| b2b_rayon_par_iter | 0 | 221 (4.27) | 200 (4.12) | 1146 (3.99) | 4469 (3.86) |  |
| b2b_spindle_for_each | 0 | 1321 (4.00) | 1364 (3.92) | 1454 (4.00) | 4656 (3.89) |  |
| b2b_team_run | 0 |  |  |  |  | 632 (4.02) |
| gap_spindle_for_each | 0 | 1262 (3.99) | 1292 (4.01) | 1392 (4.00) | 4529 (3.87) |  |
| gap_spindle_for_each | 1 | 1252 (4.01) | 1262 (4.02) | 1383 (4.02) | 4568 (3.82) |  |
| gap_spindle_for_each | 10 | 1242 (4.00) | 1252 (3.99) | 1393 (4.00) | 5731 (3.66) |  |
| gap_spindle_for_each | 30 | 1232 (4.00) | 1253 (4.00) | 1393 (4.00) | 14047 (2.01) |  |
| gap_spindle_for_each | 100 | 1263 (4.00) | 1282 (4.00) | 1403 (4.00) | 14657 (1.40) |  |
| gap_spindle_for_each | 1000 | 1293 (4.00) | 1292 (4.00) | 1463 (4.00) | 14366 (1.06) |  |
| gap_spindle_for_each | 10000 | 23584 (1.65) | 23113 (1.65) | 1452 (4.00) | 34604 (1.01) |  |
| gap_spindle_for_each | 100000 | 23745 (1.06) | 23344 (1.06) | 1523 (4.00) | 35366 (1.00) |  |
| gap_team_run | 0 |  |  |  |  | 671 (3.99) |
| gap_team_run | 1 |  |  |  |  | 661 (4.00) |
| gap_team_run | 10 |  |  |  |  | 661 (4.00) |
| gap_team_run | 30 |  |  |  |  | 662 (4.00) |
| gap_team_run | 100 |  |  |  |  | 662 (4.00) |
| gap_team_run | 1000 |  |  |  |  | 781 (4.01) |
| gap_team_run | 10000 |  |  |  |  | 781 (4.00) |
| gap_team_run | 100000 |  |  |  |  | 771 (4.00) |

## Stage comparison, 8 threads: median wall time (ms) over rotations, ratios per rotation

Rows: held = `faer-fork` (spindle group held), upstream = upstream faer 0.24.4 (spindle group held), hot = awake Rayon team, free = nothing held, team = `Par::Team`. Ratios are medians over the rotation processes of the per-process ratio (below 1: team faster). `rot` counts the row-order rotations that produced the cell (`--rotate-rows`); `pos` is the spread of the team ratio to held over rotations (max/min): a large value means row position matters.

| op | shape | held ms | upstream ms | hot ms | free ms | team ms | team/held | team/upstream | team/hot | team/free | rot | pos | team cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cholesky | 128 | 0.0538 | 0.0563 | 0.0619 | 0.0792 | 0.0558 | 1.04 | 0.988 | 0.921 | 0.703 | 5 | 1.08 | 1.01 |
| cholesky | 256 | 0.225 | 0.242 | 0.243 | 0.295 | 0.283 | 1.21 | 1.17 | 1.16 | 0.953 | 5 | 1.22 | 7.42 |
| cholesky | 512 | 0.771 | 0.825 | 0.735 | 0.869 | 0.777 | 1.02 | 0.949 | 1.06 | 0.894 | 5 | 1.04 | 7.96 |
| cholesky | 1024 | 3.03 | 3.12 | 2.8 | 3.11 | 2.81 | 0.926 | 0.904 | 1.01 | 0.902 | 5 | 1.01 | 7.75 |
| cholesky | 2048 | 17.3 | 17.1 | 16 | 16.8 | 15.9 | 0.916 | 0.926 | 0.991 | 0.946 | 5 | 1.01 | 7.8 |
| eigh | 128 | 2.25 | 2.16 | 2.26 | 2.25 | 2.25 | 1 | 1.04 | 1 | 1 | 5 | 1.01 | 1 |
| eigh | 256 | 6.75 | 6.74 | 6.68 | 7.08 | 7.07 | 1.04 | 1.05 | 1.05 | 0.996 | 5 | 1.02 | 1.72 |
| eigh | 512 | 24.9 | 23.3 | 24.9 | 25.9 | 25.9 | 1.04 | 1.11 | 1.04 | 0.995 | 5 | 1.02 | 2.73 |
| eigh | 1024 | 96.8 | 95.4 | 96.1 | 101 | 101 | 1.05 | 1.06 | 1.05 | 0.998 | 5 | 1.01 | 4.1 |
| eigh | 2048 | 549 | 559 | 533 | 555 | 556 | 1.01 | 0.994 | 1.04 | 1 | 5 | 1 | 4.91 |
| gemm | 64x4096x64 | 0.554 | 0.553 | 0.561 | 0.57 | 0.547 | 0.988 | 0.991 | 0.978 | 0.957 | 5 | 1 | 8.03 |
| gemm | 128x128x128 | 0.0723 | 0.111 | 0.0687 | 0.0825 | 0.113 | 1.55 | 1.01 | 1.64 | 1.37 | 5 | 1.1 | 7.68 |
| gemm | 256x256x256 | 0.225 | 0.245 | 0.197 | 0.212 | 0.251 | 1.12 | 1.03 | 1.26 | 1.19 | 5 | 1.08 | 8.12 |
| gemm | 512x512x512 | 1.18 | 1.18 | 1.18 | 1.19 | 1.18 | 0.998 | 0.998 | 1 | 0.996 | 5 | 1 | 7.97 |
| gemm | 1024x1024x1024 | 8.98 | 8.98 | 9 | 9.02 | 8.98 | 1 | 1 | 0.997 | 0.995 | 5 | 1 | 8.01 |
| gemm | 2048x2048x64 | 3.11 | 3.11 | 3.16 | 3.2 | 3.14 | 0.999 | 0.998 | 0.985 | 0.984 | 5 | 1.07 | 8.04 |
| gemm | 2048x2048x2048 | 71.3 | 71.2 | 71.4 | 71.3 | 71.3 | 1 | 1 | 0.999 | 0.999 | 5 | 1 | 7.95 |
| gemm | 4096x64x64 | 0.157 | 0.157 | 0.165 | 0.179 | 0.156 | 0.994 | 0.996 | 0.949 | 0.872 | 5 | 1.01 | 9.65 |
| lu | 128 | 0.105 | 0.112 | 0.106 | 0.106 | 0.106 | 1 | 0.942 | 1 | 1 | 5 | 1.02 | 1 |
| lu | 256 | 0.563 | 0.587 | 0.557 | 0.591 | 0.581 | 1.03 | 0.996 | 1.04 | 0.983 | 5 | 1.04 | 8.14 |
| lu | 512 | 2.85 | 2.67 | 2.82 | 2.98 | 2.73 | 0.939 | 0.998 | 0.957 | 0.9 | 5 | 1.04 | 7.95 |
| lu | 1024 | 11.1 | 10.4 | 10.6 | 11.2 | 10 | 0.906 | 0.966 | 0.945 | 0.893 | 5 | 1.03 | 7.99 |
| lu | 2048 | 51 | 48.6 | 48 | 50.1 | 46.4 | 0.91 | 0.954 | 0.964 | 0.927 | 5 | 1.01 | 7.92 |
| qr_factor | 128 | 0.289 | 0.52 | 0.29 | 0.289 | 0.236 | 0.818 | 0.454 | 0.817 | 0.818 | 5 | 1.02 | 7.51 |
| qr_factor | 256 | 0.806 | 1.56 | 0.81 | 0.891 | 0.78 | 0.966 | 0.498 | 0.965 | 0.875 | 5 | 1.01 | 8.01 |
| qr_factor | 512 | 2.85 | 4.7 | 2.88 | 3.08 | 2.78 | 0.971 | 0.591 | 0.964 | 0.9 | 5 | 1.01 | 7.95 |
| qr_factor | 1024 | 13.1 | 18.9 | 13.2 | 14.2 | 12.8 | 0.976 | 0.678 | 0.968 | 0.903 | 5 | 1.01 | 7.73 |
| qr_factor | 2048 | 83.1 | 107 | 81.4 | 85.1 | 79.8 | 0.962 | 0.745 | 0.978 | 0.937 | 5 | 1.02 | 7.96 |
| svd_values | 128 | 2.12 | 2.11 | 2.11 | 2.22 | 2.16 | 1.02 | 1.02 | 1.02 | 0.974 | 5 | 1.01 | 1.28 |
| svd_values | 256 | 10.3 | 10.4 | 10.3 | 10.4 | 10.4 | 1.01 | 1 | 1 | 1 | 5 | 1.01 | 1.22 |
| svd_values | 512 | 50.4 | 39.3 | 51.2 | 53.5 | 53.5 | 1.07 | 1.36 | 1.05 | 1 | 5 | 1.01 | 2.11 |
| svd_values | 1024 | 167 | 155 | 180 | 194 | 194 | 1.16 | 1.25 | 1.08 | 1 | 5 | 1.01 | 3.28 |
| svd_values | 2048 | 1.22e+03 | 1.21e+03 | 1.25e+03 | 1.35e+03 | 1.35e+03 | 1.1 | 1.11 | 1.07 | 1 | 5 | 1.01 | 5.09 |

## Small-operation sequences, 8 threads (median of 41 repetitions, microseconds per call; settle 300 ms)

| sequence | held | upstream | hot | free | team | team/held | team/upstream | team/free | team cpu/wall | rot |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gemm32 | 2.34 | 4.05 | 2.34 | 2.33 | 2.43 | 1.04 | 0.601 | 1.04 | 1 | 5 |
| gemm64 | 17.2 | 10.6 | 17.2 | 17.2 | 17.4 | 1.01 | 1.64 | 1.01 | 0.999 | 5 |
| gemm128 | 88.5 | 103 | 71.2 | 91 | 103 | 1.17 | 1.01 | 1.15 | 8 | 5 |
| lu64 | 24.9 | 27.7 | 24.7 | 24.8 | 24.9 | 1 | 0.9 | 1 | 1 | 5 |
| lu128 | 110 | 116 | 109 | 110 | 110 | 1 | 0.948 | 1 | 1 | 5 |
| chain | 34.4 | 27.9 | 34.4 | 34.4 | 27.4 | 0.795 | 0.969 | 0.79 | 8.01 | 5 |

Engagement of the team row (one untimed pass per sequence):

* gemm32: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm64: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* gemm128: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[8:2000] split[]
* lu64: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* lu128: gemm_below_floor=2000 gemm_one_tile=0 gemm_tiled=0 run[] split[]
* chain: gemm_below_floor=0 gemm_one_tile=0 gemm_tiled=0 run[8:1000] split[]

## `fbench dispatch`, 8 threads: median ns over rotations (cpu/wall in brackets)

| test | gap us | held | upstream | hot | free | team |
| --- | --- | --- | --- | --- | --- | --- |
| b2b_rayon_par_iter | 0 | 444 (4.78) | 442 (4.91) | 2498 (7.99) | 6588 (7.88) |  |
| b2b_spindle_for_each | 0 | 2736 (8.00) | 2744 (8.03) | 2759 (8.00) | 6823 (7.88) |  |
| b2b_team_run | 0 |  |  |  |  | 1041 (8.28) |
| gap_spindle_for_each | 0 | 2635 (7.92) | 2605 (7.90) | 2705 (8.00) | 6682 (7.89) |  |
| gap_spindle_for_each | 1 | 2444 (8.03) | 2414 (8.02) | 2685 (8.03) | 6973 (7.78) |  |
| gap_spindle_for_each | 10 | 2494 (8.01) | 2474 (7.99) | 2715 (8.01) | 10500 (7.21) |  |
| gap_spindle_for_each | 30 | 2475 (7.99) | 2575 (8.01) | 2725 (8.00) | 13475 (4.28) |  |
| gap_spindle_for_each | 100 | 2474 (8.00) | 2565 (8.00) | 2735 (8.00) | 14607 (2.26) |  |
| gap_spindle_for_each | 1000 | 2695 (8.00) | 2705 (8.00) | 2795 (8.00) | 33864 (1.16) |  |
| gap_spindle_for_each | 10000 | 26720 (2.53) | 26579 (2.52) | 2825 (8.00) | 35496 (1.02) |  |
| gap_spindle_for_each | 100000 | 27121 (1.15) | 26870 (1.15) | 2996 (8.00) | 35617 (1.00) |  |
| gap_team_run | 0 |  |  |  |  | 1032 (7.97) |
| gap_team_run | 1 |  |  |  |  | 1022 (8.05) |
| gap_team_run | 10 |  |  |  |  | 1022 (8.00) |
| gap_team_run | 30 |  |  |  |  | 1022 (8.00) |
| gap_team_run | 100 |  |  |  |  | 1022 (8.00) |
| gap_team_run | 1000 |  |  |  |  | 1072 (8.01) |
| gap_team_run | 10000 |  |  |  |  | 1072 (8.00) |
| gap_team_run | 100000 |  |  |  |  | 1072 (8.00) |

