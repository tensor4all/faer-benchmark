# Candidate evidence for the adopted revision `fe41bbd`

These two runs measured the adopted fork revision against the pinned baseline with the frozen
settings and `--no-publish`:

| run | subset | what it answered |
| --- | --- | --- |
| `20261016T093643Z-candidate-fe41bbd-mkl` | square 256 f64, `gemm`/`lu`/`cholesky`/`qr_factor`, 1/4/8T | no regression on square cells (median ratio 0.993) |
| `20261016T111756Z-candidate-fe41bbd-tall-mkl` | C/F `4096x256` f64+c64, `qr_factor`/`qr`/`lu`, 4T/8T | the target improvement (`qr_factor` f64 C-order 0.223/0.187, `lu` 0.740/0.724, guards at 1.00) |
| `20261016T130607Z-candidate-fe41bbd-wide-mkl` | C/F `64x1024` f64+c64, `qr_factor`, 1/4/8T | the wide case this change deliberately does **not** touch: ratios 0.96-1.02, control reproduced |

They live here rather than under `data/results/` because the campaign's CI resolves every recorded
manifest's `library.commit` in the pinned `extern/t4a-faer` checkout, and a candidate revision is by
definition not in it. The matching baseline runs (which do resolve) stay under `data/results/`:
`20261016T093307Z-baseline-ref-subset-mkl`, `20261016T110534Z-baseline-ref-tall-mkl` and
`20261016T130237Z-baseline-ref-wide-mkl`.

The historical page's losing cells for these families are covered by the daily declaration
(`linalg-tall` `4096x256`, `linalg-wide` `64x1024`, `linalg-mid` `256`/`512`). This change fixes the
tall/square C-order path only: the `64x1024` wide loss is still there, and the remaining losing cells
of the historical page (`lu/n256` c64, `lu/n512`, `solve`, `cholesky`, `gemm`) are left to the normal
daily runs rather than re-measured here.

Decision record: `docs/worklog.md` (2026-10-16 entry) and the fork's `PATCHSET.md`.
