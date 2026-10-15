# Priming calibration, first attempt (inconclusive — kept, not deleted)

24 guarded processes on 2026-10-15 with the original power state (boost enabled,
`powersave` governor, EPP `balance_performance`, PPD balanced). Compared
`--prime-ms 3000 --reps 30` with `250/30` and `250/10` on four cells, one process
per setting per rotation.

It is **inconclusive by design**: one process per setting cannot separate a priming
effect from the already-measured between-process variation (same cells, up to 74%
between starts). The per-row differences (up to +33.7% median, up to +40% within
one rotation) are the same order as that variation, so no setting was adopted from
this run. The follow-up run with boost disabled and three process starts per
setting is in `../20261015-priming-calibration-boostoff/`; these artifacts stay as
they are, including the cells where the two settings disagreed.
