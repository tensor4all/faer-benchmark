## Wall time per cell (ms, median over the three rotations of the per-process medians)

`hot/held` and `free/held` are the median over rotations of the per-process ratio; the bracket is the min to max over rotations. Below 1 means faster than the held spindle group.

### 18 threads

| op | shape | held (ms) | hot (ms) | free (ms) | hot/held | free/held | held cpu/wall | hot cpu/wall | free cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| gemm | 64x4096x64 | 0.702 | 0.382 | 1.85 | 0.545 [0.426, 5.193] | 2.660 [2.454, 2.678] | 0.997 | 15.5 | 11.8 |
| gemm | 256x256x256 | 0.665 | 0.0688 | 0.319 | 0.108 [0.102, 0.109] | 0.484 [0.451, 0.507] | 0.997 | 17 | 12.2 |
| gemm | 4096x64x64 | 0.867 | 0.0865 | 0.337 | 0.098 [0.097, 0.110] | 0.378 [0.371, 0.418] | 0.997 | 16.2 | 11.2 |
| gemm | 512x512x512 | 5.25 | 2.08 | 0.875 | 0.377 [0.152, 1.085] | 0.172 [0.163, 0.177] | 0.995 | 15.5 | 11 |
| gemm | 2048x2048x64 | 34 | 8.97 | 5.22 | 0.264 [0.259, 0.309] | 0.154 [0.154, 0.155] | 0.997 | 15.4 | 12.4 |
| gemm | 1024x1024x1024 | 41.5 | 8.53 | 5.14 | 0.218 [0.193, 0.233] | 0.124 [0.124, 0.128] | 0.997 | 15.5 | 10.9 |
| gemm | 2048x2048x2048 | 330 | 35 | 34.3 | 0.108 [0.106, 0.110] | 0.104 [0.103, 0.106] | 0.996 | 14.8 | 12.2 |
| lu | 256 | 0.985 | 0.782 | 0.521 | 0.794 [0.565, 1.619] | 0.523 [0.516, 0.587] | 15 | 15.8 | 4.36 |
| lu | 512 | 8.13 | 12.8 | 4.14 | 1.704 [1.076, 2.052] | 0.510 [0.496, 0.535] | 14.7 | 15.6 | 9.02 |
| lu | 1024 | 37 | 44.5 | 17.7 | 1.229 [1.020, 1.921] | 0.469 [0.343, 0.491] | 12.3 | 15.5 | 9.86 |
| lu | 2048 | 200 | 201 | 61.4 | 1.001 [0.744, 1.124] | 0.305 [0.302, 0.333] | 8.27 | 15.5 | 9.61 |
| qr_factor | 256 | 8.39 | 7.27 | 4.19 | 1.920 [0.213, 1.926] | 0.499 [0.144, 1.232] | 15.4 | 15.4 | 11.1 |
| qr_factor | 512 | 16.8 | 29.7 | 15.5 | 1.430 [0.835, 3.083] | 0.983 [0.385, 1.605] | 15.4 | 15.3 | 11.1 |
| qr_factor | 1024 | 44.8 | 77.4 | 47.3 | 1.602 [0.918, 1.729] | 1.057 [0.484, 1.121] | 15.6 | 15.6 | 11.3 |
| qr_factor | 2048 | 213 | 299 | 141 | 1.254 [0.923, 1.573] | 0.663 [0.443, 0.685] | 15.3 | 15.4 | 10.8 |
| cholesky | 256 | 1.04 | 0.216 | 0.232 | 0.230 [0.208, 0.551] | 0.223 [0.208, 0.740] | 15.3 | 16 | 6.11 |
| cholesky | 512 | 2.8 | 3.87 | 1.17 | 1.385 [0.350, 2.110] | 0.419 [0.361, 0.436] | 15.4 | 15.6 | 9.11 |
| cholesky | 1024 | 9.68 | 15.9 | 4.2 | 1.409 [1.070, 2.124] | 0.433 [0.374, 0.495] | 14 | 15.2 | 9.32 |
| cholesky | 2048 | 39.9 | 41 | 16.7 | 1.026 [0.922, 4.191] | 0.417 [0.411, 0.799] | 9.28 | 15.3 | 8.9 |

## Median of the ratios over all cells of a family (and rotations)

| threads | op | cells | median hot/held | min | max | median free/held | median free/hot |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 18 | gemm | 7 | 0.218 | 0.098 | 0.545 | 0.172 | 0.971 |
| 18 | lu | 4 | 1.115 | 0.794 | 1.704 | 0.490 | 0.357 |
| 18 | qr_factor | 4 | 1.516 | 1.254 | 1.920 | 0.823 | 0.566 |
| 18 | cholesky | 4 | 1.206 | 0.230 | 1.409 | 0.418 | 0.361 |

## Tiny parallel region: dispatch cost and wake latency (ns, median over three row orders)

`b2b_*`: dispatches back to back (mean per dispatch over blocks of 1000). `gap_*`: latency of one dispatch after the leader worked serially for `gap` us; `cpu/wall` is the process CPU time over wall time across that loop (cores kept busy, the leader's own core counts as 1).

### 18 threads

| test | gap (us) | held median | hot median | free median | held p90 | hot p90 | free p90 | held cpu/wall | hot cpu/wall | free cpu/wall |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| b2b_spindle_for_each | 0 | 1.88e+04 | 5.78e+04 | 7.55e+04 | 3.3e+04 | 9.88e+04 | 7.97e+04 | 15.6 | 15.6 | 11.2 |
| b2b_rayon_par_iter | 0 | 178 | 5.14e+04 | 7.25e+04 | 199 | 1.66e+05 | 7.63e+04 | 3.77 | 15.7 | 11.3 |
| gap_spindle_for_each | 0 | 2.75e+03 | 6.79e+03 | 5.38e+04 | 3.08e+03 | 1.4e+04 | 1.55e+05 | 15.6 | 15.5 | 11.3 |
| gap_spindle_for_each | 1 | 2.79e+03 | 1.23e+04 | 6.11e+04 | 3.08e+03 | 7.93e+05 | 1.66e+05 | 15.6 | 14.5 | 11.2 |
| gap_spindle_for_each | 10 | 2.88e+03 | 7.25e+03 | 9.5e+04 | 4.27e+05 | 8.98e+04 | 1.74e+05 | 15.6 | 15.6 | 10.8 |
| gap_spindle_for_each | 30 | 3e+03 | 9.21e+03 | 1.31e+05 | 5.28e+05 | 6.96e+05 | 1.92e+05 | 15.4 | 15.4 | 10.1 |
| gap_spindle_for_each | 100 | 1.16e+04 | 1.46e+04 | 1.43e+05 | 5.36e+05 | 1.35e+06 | 1.96e+05 | 15.6 | 15.1 | 7.43 |
| gap_spindle_for_each | 1000 | 5.43e+05 | 8.6e+04 | 1.76e+05 | 5.67e+05 | 5.35e+06 | 2.26e+05 | 11.2 | 15.5 | 2.63 |
| gap_spindle_for_each | 10000 | 5.76e+05 | 1.82e+04 | 2.21e+05 | 1.46e+06 | 1.6e+06 | 2.92e+05 | 2.55 | 15.5 | 1.22 |
| gap_spindle_for_each | 100000 | 5.73e+05 | 1.98e+04 | 2.2e+05 | 9.54e+05 | 5.22e+06 | 3.16e+05 | 1.16 | 15.4 | 1.02 |

