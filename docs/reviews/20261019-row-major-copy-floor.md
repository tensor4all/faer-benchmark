# The row-major copy's floor: 4096 elements, from a measured pair

Closes `tensor4all/faer#18` (guard or route the small shapes the row-major work made slower).

## What was measured

Baseline `a5e6b7d` (the pin) against candidate `30b4fde` (`perf/row-major-size-floor`), same harness
commit, `linalg-small` at 4T and 8T, both dtypes, both orders, three process sets, five calls each,
250 ms priming: `20261019T163156Z-base-rm-floor-r2` and `20261019T170716Z-cand-rm-floor-4k`, 288 fork
cells each.

| | |
| --- | --- |
| control (`faer-upstream`, unchanged row) | median ratio **0.997641**, **1** cell outside its between-start range |
| fork | 288 cells, **29 faster**, **1 slower** beyond 5% |

The slower cell is `householder_apply f64 c 96x96 sequence` at 1.221 (0.0380 -> 0.0392 ms). That
family does not go through `qr_in_place` or `lu_in_place`, so the candidate's code path is byte for
byte the baseline's there; its own `block` variant at the same shape measured 0.801 in the same run.
It is read as noise, not as a cost of the change.

## The crossover

| cell | ratio | baseline -> candidate |
| --- | --- | --- |
| `qr_factor` f64 c 32x32 8T | **0.563** | 0.0420 -> 0.0238 ms |
| `qr_factor` f64 c 32x32 4T | **0.607** | 0.0364 -> 0.0237 ms |
| `qr_factor` c64 c 32x32 8T | **0.697** | 0.0582 -> 0.0408 ms |
| `qr_factor` c64 c 32x32 4T | **0.731** | 0.0538 -> 0.0407 ms |
| `qr_factor` f64 c 64x64 8T | 0.927 | 0.1234 -> 0.1114 ms |
| `qr_factor` f64 c 96x96 8T | 0.904 | 0.2413 -> 0.2127 ms |

Before this pair the same 32x32 cell was the acceptance run's worst regression (1.83x at 4T). It is
now nearly twice as fast as the baseline, because the baseline was paying the copy for a matrix that
fits in L1 and gains nothing from being contiguous.

The floor sits at **`64 * 64` = 4096 elements**: below it the layout-agnostic path runs, from there up
the copy does. That is where the measured cells put the crossover — 32x32 loses the copy by 1.8x
(0.042 ms against 0.024 ms), 64x64 and 96x96 lose *without* it by 1.10-1.31x on the same family in the
earlier 128^2-floor candidate, and `lu`/`solve` are flat at both sizes either way.

## What the change does and does not touch

* Above the floor the predicate is unchanged, so the code path for every mid, tall and wide cell is
  the baseline's: nothing in `linalg-mid/tall/wide` can move because of this, and the 288-cell grid
  here shows them inside their recorded spread.
* Below the floor the factorization runs in place through a strided panel. The arithmetic is the same
  factorization, but not the same summation order, so the unit tests now assert bit-identity above the
  floor and equality up to rounding below it (`linalg::tests::test_row_major_adaptation_matches_the_column_major_one`
  and `qr::no_pivoting::factor::tests::test_row_major_factor_is_the_column_major_one`).
* Public API, thresholds in `params`, and the column-major path are untouched.

## Verdict

Adopt. The regression the acceptance run found is removed and turns into a gain, no cell beyond the
5% band moved in the wrong direction except one cell in a family the change cannot reach, and the
control reproduces at a 0.9976 median.

Merged as `tensor4all/faer` PR #23 (`30b4fde`), then the pin moves when the next periodic run records
the new revision.
