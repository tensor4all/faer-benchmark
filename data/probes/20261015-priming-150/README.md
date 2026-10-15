# 150 ms vs 250 ms priming (24 processes, 0 guard rejections, boost off)

Three process starts per setting per cell, `--reps 5`, rotation-paired per row.

| cell | 150/250 ratio per rotation | reading |
| --- | --- | --- |
| gemm 256^3 f64 1T | 0.995 - 1.002 | no effect |
| lu 256^2 c64 4T | 0.985 - 1.008 | no effect |
| qr_factor 4096x256 f64 8T | 0.981 - 1.023 | no meaningful effect |
| cholesky 512^2 f64 8T | 0.959 - 1.039 | upstream row reads ~3% faster at 150 ms in all three rotations |

Within-process relative SD: 0.67% (250 ms) vs 0.82% (150 ms).

The hypothesis that dropping the small sizes makes priming cheaper to skip is only
half right: cells whose calls are microseconds (gemm) or tens of milliseconds
(qr_factor) do not care, but the one mid-size decomposition cell here shows a small
systematic shift and slightly noisier rows. Verdict: 150 ms is defensible for a fast
daily loop, **250 ms stays the frozen baseline setting** - the saving is under an
hour and this cell is the kind the baseline is supposed to resolve.
