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
