## Serial throughput constants, 1 thread on core 4 (ns per unit; median over shapes and rounds)

M5 = thresholds.md 2.3 (Apple M5 Max). ratio = Linux / M5.

| family | type | median | range | cells | M5 | ratio |
| --- | --- | --- | --- | --- | --- | --- |
| bidiag | c64 | 2.1997 | 1.8567 to 2.5618 | 10 | 1.36 | 1.62 |
| bidiag | f64 | 1.0427 | 0.7890 to 1.4165 | 10 | 0.48 | 2.17 |
| block_apply_per_mac | c64 | 0.2685 | 0.2660 to 0.2768 | 6 | 0.165 | 1.63 |
| block_apply_per_mac | f64 | 0.0676 | 0.0663 to 0.0690 | 6 | 0.037 | 1.83 |
| bunch_kaufman_full | c64 | 1.3904 | 1.3194 to 1.5056 | 10 | 0.38 | 3.66 |
| bunch_kaufman_full | f64 | 0.8295 | 0.6716 to 0.8982 | 10 | 0.238 | 3.49 |
| gemm_per_mac | c32 | 0.1283 | 0.1274 to 0.1302 | 8 |  |  |
| gemm_per_mac | c64 | 0.2565 | 0.2552 to 0.2585 | 8 | 0.165 | 1.55 |
| gemm_per_mac | f32 | 0.0320 | 0.0319 to 0.0329 | 8 |  |  |
| gemm_per_mac | f64 | 0.0641 | 0.0637 to 0.0650 | 8 | 0.037 | 1.73 |
| hessenberg_unblocked | c64 | 2.2212 | 2.0510 to 2.4270 | 8 | 1.57 | 1.41 |
| hessenberg_unblocked | f64 | 0.8576 | 0.7159 to 1.1435 | 8 | 0.451 | 1.90 |
| householder_rank_one | c64 | 1.0303 | 1.0036 to 1.1022 | 8 | 0.725 | 1.42 |
| householder_rank_one | f64 | 0.4783 | 0.4704 to 0.4941 | 8 | 0.212 | 2.26 |
| lu_full_pivot | c64 | 0.8679 | 0.7774 to 1.0364 | 10 | 0.6 | 1.45 |
| lu_full_pivot | f64 | 0.4011 | 0.3372 to 0.4610 | 10 | 0.216 | 1.86 |
| lu_partial_per_flop | c64 | 0.1853 | 0.1449 to 0.2682 | 8 |  |  |
| lu_partial_per_flop | f64 | 0.0658 | 0.0405 to 0.1312 | 8 | 0.03 | 2.19 |
| matvec_colmajor | c64 | 0.3373 | 0.3113 to 0.4384 | 10 | 0.281 | 1.20 |
| matvec_colmajor | f64 | 0.1743 | 0.1498 to 0.1779 | 10 | 0.112 | 1.56 |
| matvec_rowmajor | c64 | 0.5057 | 0.4825 to 0.5686 | 10 | 0.425 | 1.19 |
| matvec_rowmajor | f64 | 0.1565 | 0.1389 to 0.1649 | 10 | 0.087 | 1.80 |
| qr_col_pivot | c64 | 1.0320 | 0.8609 to 1.4238 | 10 | 0.713 | 1.45 |
| qr_col_pivot | f64 | 0.3645 | 0.3001 to 0.5408 | 10 | 0.202 | 1.80 |
| triangular_matmul_per_mac | c64 | 0.2812 | 0.2719 to 0.3037 | 6 | 0.176 | 1.60 |
| triangular_matmul_per_mac | f64 | 0.0715 | 0.0704 to 0.0792 | 6 | 0.039 | 1.83 |
| triangular_solve_per_mac | c64 | 0.4190 | 0.3717 to 0.4669 | 4 | 0.187 | 2.24 |
| triangular_solve_per_mac | f64 | 0.0919 | 0.0836 to 0.1002 | 4 | 0.051 | 1.80 |
| tridiag | c64 | 1.9252 | 1.6847 to 2.5209 | 10 | 1.16 | 1.66 |
| tridiag | f64 | 0.7695 | 0.5669 to 1.2772 | 10 | 0.339 | 2.27 |

## Region constants (block apply streaming, divide and conquer solves, triangular inverse, sparse product)

| group | median ns/unit | range | cells |
| --- | --- | --- | --- |
| bsvd_f64 | 0.80401 | 0.29815 to 2.62641 | 14 |
| spmm_c64_n20000_d8 | 8.37763 | 8.33822 to 8.41704 | 2 |
| spmm_c64_n2000_d12 | 3.88694 | 3.87768 to 3.89621 | 2 |
| spmm_c64_n2000_d4 | 4.51294 | 4.49947 to 4.52641 | 2 |
| spmm_c64_n4000_d40 | 4.66019 | 4.63625 to 4.68414 | 2 |
| spmm_c64_n8000_d16 | 5.82301 | 5.81668 to 5.82935 | 2 |
| spmm_c64_n8000_d6 | 5.80814 | 5.79664 to 5.81963 | 2 |
| spmm_f64_n20000_d8 | 5.91615 | 5.86110 to 5.97120 | 2 |
| spmm_f64_n2000_d12 | 3.04002 | 3.03612 to 3.04393 | 2 |
| spmm_f64_n2000_d4 | 4.03620 | 4.00469 to 4.06770 | 2 |
| spmm_f64_n4000_d40 | 3.25917 | 3.24848 to 3.26987 | 2 |
| spmm_f64_n8000_d16 | 4.22675 | 4.22016 to 4.23335 | 2 |
| spmm_f64_n8000_d6 | 4.24384 | 4.24063 to 4.24705 | 2 |
| tevd_f64 | 0.49404 | 0.19969 to 1.38020 | 14 |
| tinv_c64 | 0.07228 | 0.05427 to 0.14041 | 14 |
| tinv_f64 | 0.01936 | 0.01447 to 0.04686 | 14 |
