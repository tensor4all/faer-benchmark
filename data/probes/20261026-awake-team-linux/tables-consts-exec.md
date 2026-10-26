## Serial throughput constants, 1 thread on core 4 (ns per unit; median over shapes and rounds)

M5 = thresholds.md 2.3 (Apple M5 Max). ratio = Linux / M5.

| family | type | median | range | cells | M5 | ratio |
| --- | --- | --- | --- | --- | --- | --- |
| bidiag | c64 | 2.2025 | 1.8552 to 2.5641 | 10 | 1.36 | 1.62 |
| bidiag | f64 | 1.0392 | 0.7818 to 1.4122 | 10 | 0.48 | 2.16 |
| block_apply_per_mac | c64 | 0.2688 | 0.2664 to 0.2766 | 6 | 0.165 | 1.63 |
| block_apply_per_mac | f64 | 0.0670 | 0.0662 to 0.0690 | 6 | 0.037 | 1.81 |
| bunch_kaufman_full | c64 | 1.3888 | 1.3342 to 1.5040 | 10 | 0.38 | 3.65 |
| bunch_kaufman_full | f64 | 0.6979 | 0.6514 to 0.7637 | 10 | 0.238 | 2.93 |
| gemm_per_mac | c32 | 0.1279 | 0.1272 to 0.1301 | 8 |  |  |
| gemm_per_mac | c64 | 0.2566 | 0.2546 to 0.2584 | 8 | 0.165 | 1.56 |
| gemm_per_mac | f32 | 0.0320 | 0.0318 to 0.0328 | 8 |  |  |
| gemm_per_mac | f64 | 0.0641 | 0.0637 to 0.0650 | 8 | 0.037 | 1.73 |
| hessenberg_unblocked | c64 | 2.2302 | 2.0458 to 2.4398 | 8 | 1.57 | 1.42 |
| hessenberg_unblocked | f64 | 0.8595 | 0.7108 to 1.1145 | 8 | 0.451 | 1.91 |
| householder_rank_one | c64 | 1.0827 | 1.0400 to 1.1059 | 8 | 0.725 | 1.49 |
| householder_rank_one | f64 | 0.4807 | 0.4647 to 0.4960 | 8 | 0.212 | 2.27 |
| lu_full_pivot | c64 | 0.9307 | 0.7733 to 1.1324 | 10 | 0.6 | 1.55 |
| lu_full_pivot | f64 | 0.3988 | 0.3385 to 0.4619 | 10 | 0.216 | 1.85 |
| lu_partial_per_flop | c64 | 0.1846 | 0.1449 to 0.2680 | 8 |  |  |
| lu_partial_per_flop | f64 | 0.0662 | 0.0405 to 0.1341 | 8 | 0.03 | 2.21 |
| matvec_colmajor | c64 | 0.3997 | 0.3125 to 0.5929 | 10 | 0.281 | 1.42 |
| matvec_colmajor | f64 | 0.1714 | 0.1541 to 0.1781 | 10 | 0.112 | 1.53 |
| matvec_rowmajor | c64 | 0.5051 | 0.4824 to 0.5626 | 10 | 0.425 | 1.19 |
| matvec_rowmajor | f64 | 0.1569 | 0.1391 to 0.1649 | 10 | 0.087 | 1.80 |
| qr_col_pivot | c64 | 1.0262 | 0.8628 to 1.4187 | 10 | 0.713 | 1.44 |
| qr_col_pivot | f64 | 0.3635 | 0.2996 to 0.5397 | 10 | 0.202 | 1.80 |
| triangular_matmul_per_mac | c64 | 0.2812 | 0.2720 to 0.3031 | 6 | 0.176 | 1.60 |
| triangular_matmul_per_mac | f64 | 0.0713 | 0.0706 to 0.0794 | 6 | 0.039 | 1.83 |
| triangular_solve_per_mac | c64 | 0.4178 | 0.3687 to 0.4650 | 4 | 0.187 | 2.23 |
| triangular_solve_per_mac | f64 | 0.0915 | 0.0834 to 0.0994 | 4 | 0.051 | 1.79 |
| tridiag | c64 | 1.9192 | 1.6827 to 2.5123 | 10 | 1.16 | 1.65 |
| tridiag | f64 | 0.7608 | 0.5542 to 1.3229 | 10 | 0.339 | 2.24 |

## Region constants (block apply streaming, divide and conquer solves, triangular inverse, sparse product)

| group | median ns/unit | range | cells |
| --- | --- | --- | --- |
| bsvd_f64 | 0.81113 | 0.29953 to 2.63210 | 14 |
| spmm_c64_n20000_d8 | 8.32404 | 8.23128 to 8.41680 | 2 |
| spmm_c64_n2000_d12 | 3.84935 | 3.84452 to 3.85418 | 2 |
| spmm_c64_n2000_d4 | 4.40638 | 4.40010 to 4.41265 | 2 |
| spmm_c64_n4000_d40 | 4.55865 | 4.51166 to 4.60563 | 2 |
| spmm_c64_n8000_d16 | 5.76926 | 5.74532 to 5.79320 | 2 |
| spmm_c64_n8000_d6 | 5.88710 | 5.82128 to 5.95291 | 2 |
| spmm_f64_n20000_d8 | 5.94283 | 5.90691 to 5.97875 | 2 |
| spmm_f64_n2000_d12 | 3.01893 | 3.01321 to 3.02465 | 2 |
| spmm_f64_n2000_d4 | 3.95204 | 3.94545 to 3.95863 | 2 |
| spmm_f64_n4000_d40 | 3.25370 | 3.24277 to 3.26463 | 2 |
| spmm_f64_n8000_d16 | 4.20219 | 4.20154 to 4.20284 | 2 |
| spmm_f64_n8000_d6 | 4.36021 | 4.30326 to 4.41715 | 2 |
| tevd_f64 | 0.49278 | 0.19939 to 1.37766 | 14 |
| tinv_c64 | 0.07231 | 0.05411 to 0.14038 | 14 |
| tinv_f64 | 0.01946 | 0.01446 to 0.04728 | 14 |
