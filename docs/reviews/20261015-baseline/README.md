# timing-v2 baseline — audit of what was obtained (2026-10-15)

Generated after the runs finished. `record_run` published each page only after its own
verification census, validation and binary/source re-checks passed.

| run | suite | vendor | engines | threads | aa | rows | samples | guards | discards | power | validation |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `20261015T130805Z-baseline-v2-faer-kernels-mkl` | `faer-kernels` | `mkl` | faer-fork+faer-upstream+lapack-mkl | [1, 4, 8] | 3 | 15156 | 55260 | 96 | 2 | boost=0, gov=performance | ok |
| `20261015T194810Z-baseline-v2-faer-kernels-openblas` | `faer-kernels` | `openblas` | faer-fork+lapack-openblas | [1, 4, 8] | 2 | 6672 | 23280 | 72 | 1 | boost=0, gov=performance | ok |

## Pages

- `result/zen5-cpu/faer-kernels/bfe4041cd991-0539947ffb75-mkl-timing-v2.md` (305 KiB)
- `result/zen5-cpu/faer-kernels/bfe4041cd991-0539947ffb75-openblas-timing-v2.md` (196 KiB)

## What is not here

- `faer-kernels-large` (1024/1536 at 4T/8T): declared, not recorded in this pass.
- The candidate comparison: the frozen candidate-mode spec is in `docs/protocol-v2-baseline.md` §4 and is
  not implemented yet, so no optimization result is claimed.

## Two honest notes

- The OpenBLAS page reads `coverage=partial`: by the frozen protocol that arm measures only
  `faer-fork` + `lapack-openblas` (the duplicated `faer-upstream` row is not measured twice), while the
  suite declaration still lists `faer-upstream` as expected for every arm. The numbers are complete for
  the rows the arm declares; the label reflects the declaration, not a missing measurement.
- The supplementary union verification finished for the daily suite on both binaries at 1/4/8T
  (1,332 ok rows each, zero failed, tolerance line present). Its large-suite grids were cut off by the
  harness timeout and are not claimed; the mandatory per-population `verify` gate ran inside every
  recorded run.

- Discarded attempts appear only as counts here; each guard log records its own attempt history and no
  discarded run's CSV was kept.

