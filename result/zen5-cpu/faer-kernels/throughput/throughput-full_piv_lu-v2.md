# full_piv_lu - plotted data (nominal GFLOP/s)

Nominal operation count: `2n^3/3 (no vendor row: unsupported)`. Each value is the median of the process
medians for that cell, `+-` is the between-start sample SD, a dot means that row is not
measured in that arm, and the chart of the same name holds the same numbers.

## 1T

| n | faer-fork | faer-upstream | lapack-mkl | lapack-openblas |
|---|---|---|---|---|
| 32 | 2.1 +- 0.062 | 2.02 +- 0.049 | . | . |
| 64 | 3.72 +- 0.0078 | 3.74 +- 0.022 | . | . |
| 96 | 4.38 +- 0.031 | 4.38 +- 0.027 | . | . |
| 128 | 4.5 +- 0.017 | 4.47 +- 0.03 | . | . |
| 256 | 4.06 +- 0.018 | 4.04 +- 0.023 | . | . |
| 512 | 3.93 +- 0.043 | 3.92 +- 0.06 | . | . |

## 4T

| n | faer-fork | faer-upstream | lapack-mkl | lapack-openblas |
|---|---|---|---|---|
| 32 | 2.1 +- 0.043 | 2 +- 0.05 | . | . |
| 64 | 3.72 +- 0.033 | 3.68 +- 0.013 | . | . |
| 96 | 4.41 +- 0.017 | 4.41 +- 0.031 | . | . |
| 128 | 4.46 +- 0.024 | 4.47 +- 0.01 | . | . |
| 256 | 4.06 +- 0.0069 | 4.05 +- 0.0069 | . | . |
| 512 | 4.97 +- 0.023 | 4.93 +- 0.054 | . | . |
| 1024 | 9.1 +- 0.31 | 9.08 +- 0.25 | . | . |

## 8T

| n | faer-fork | faer-upstream | lapack-mkl | lapack-openblas |
|---|---|---|---|---|
| 32 | 2.1 +- 0.021 | 2.01 +- 0.055 | . | . |
| 64 | 3.76 +- 0.045 | 3.74 +- 0.0082 | . | . |
| 96 | 4.39 +- 0.097 | 4.4 +- 0.1 | . | . |
| 128 | 4.48 +- 0.033 | 4.48 +- 0.015 | . | . |
| 256 | 4.04 +- 0.012 | 4.05 +- 0.019 | . | . |
| 512 | 4.98 +- 0.054 | 5 +- 0.08 | . | . |
| 1024 | 10.5 +- 0.044 | 10.5 +- 0.41 | . | . |

