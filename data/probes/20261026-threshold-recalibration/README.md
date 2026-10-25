# Threshold recalibration of the remaining faer regions, rough M5 confirmation (2026-10-26)

Rough measurement for the remaining regions of tensor4all/threadteam-rs `docs/design/thresholds.md` section 3.4
in the t4a-faer fork (`exp/par-team-lifetime`, draft PR tensor4all/faer#61), faer-benchmark#24. One shared
laptop, QoS `UserInitiated`; it decides nothing, acceptance is on a quiet Linux host.

## What was measured

### Serial throughput constants (`constants/`)

`constants/bench` is a standalone program (not part of the fbench workspace) that links the fork by path and
times the serial (`Par::Seq`, one thread) in-place routines: full pivoting LU, Bunch-Kaufman with full pivoting,
QR with column pivoting, bidiagonalization, the unblocked Hessenberg reduction and tridiagonalization on square
matrices 96 to 384 (Hessenberg 96 to 224, its unblocked range), matvec 128 to 768 in both layouts, the rank one
Householder apply, and the block apply, triangular product and triangular solve as multiply-add rates against
the GEMM rate. Units are those of the gate of each family. Time per unit is the whole serial operation over
the sum of the per-step units (so it includes the serial parts of a step). Each shape is primed for 250 ms,
timed as the median of at least 9 repetitions in 0.6 s, f64 and c64, two processes per group.

| family | type | median | clean median | range | cells |
| --- | --- | --- | --- | --- | --- |
| bidiag | c64 | 1.3563 | 1.3563 | 1.2253 to 1.4902 | 10 |
| bidiag | f64 | 0.4801 | 0.4801 | 0.4290 to 0.5999 | 10 |
| block_apply_per_mac | c64 | 0.1648 | 0.1648 | 0.1643 to 0.1772 | 6 |
| block_apply_per_mac | f64 | 0.0371 | 0.0371 | 0.0348 to 0.0372 | 6 |
| bunch_kaufman_full | c64 | 0.3796 | 0.3753 | 0.3528 to 0.3963 | 10 |
| bunch_kaufman_full | f64 | 0.2379 | 0.2371 | 0.2054 to 0.2626 | 10 |
| gemm_per_mac | c64 | 0.1624 | 0.1624 | 0.1610 to 0.1663 | 6 |
| gemm_per_mac | f64 | 0.0364 | 0.0364 | 0.0350 to 0.0375 | 6 |
| hessenberg_unblocked | c64 | 1.5693 | nan | 1.4460 to 1.9982 | 8 |
| hessenberg_unblocked | f64 | 0.4514 | nan | 0.4193 to 0.5345 | 8 |
| householder_rank_one | c64 | 0.7253 | 0.7251 | 0.7045 to 0.7699 | 8 |
| householder_rank_one | f64 | 0.2117 | 0.2069 | 0.2035 to 0.2228 | 8 |
| lu_full_pivot | c64 | 0.5996 | 0.5996 | 0.5826 to 0.6478 | 10 |
| lu_full_pivot | f64 | 0.2156 | 0.2156 | 0.2035 to 0.2479 | 10 |
| matvec_colmajor | c64 | 0.2810 | 0.2810 | 0.2659 to 0.3696 | 10 |
| matvec_colmajor | f64 | 0.1116 | 0.1116 | 0.0865 to 0.1381 | 10 |
| matvec_rowmajor | c64 | 0.4249 | 0.4249 | 0.3713 to 0.4552 | 10 |
| matvec_rowmajor | f64 | 0.0867 | 0.0867 | 0.0839 to 0.0949 | 10 |
| qr_col_pivot | c64 | 0.7127 | 0.6969 | 0.6412 to 0.8122 | 10 |
| qr_col_pivot | f64 | 0.2021 | 0.2023 | 0.1868 to 0.2319 | 10 |
| triangular_matmul_per_mac | c64 | 0.1755 | 0.1755 | 0.1655 to 0.1908 | 6 |
| triangular_matmul_per_mac | f64 | 0.0388 | 0.0388 | 0.0384 to 0.0445 | 6 |
| triangular_solve_per_mac | c64 | 0.1866 | 0.1866 | 0.1810 to 0.1914 | 4 |
| triangular_solve_per_mac | f64 | 0.0512 | 0.0512 | 0.0465 to 0.0554 | 4 |
| tridiag | c64 | 1.1642 | 1.1642 | 1.0830 to 1.3316 | 10 |
| tridiag | f64 | 0.3392 | 0.3392 | 0.2992 to 0.4222 | 10 |

Adopted constants (`faer::utils::cost::rate`, ns per unit, f64 / c64): LU full pivoting 0.216 / 0.600,
Bunch-Kaufman 0.238 / 0.380, QR column pivoting 0.202 / 0.713, bidiagonalization 0.480 / 1.36, Hessenberg
0.451 / 1.57 (both processes busy, values within 25 percent of each other), tridiagonalization 0.339 / 1.16,
matvec 0.100 / 0.340 (the mean of the two layouts: f64 column major 0.112, row major 0.087; c64 0.281 and
0.425), rank one apply 0.212 / 0.725. The block apply (0.037 / 0.165 per multiply-add), triangular product
(0.039 / 0.176) and triangular solve (0.051 / 0.187) are at or within 1.4 times the GEMM rate (0.037 / 0.165,
measured again here: 0.036 / 0.162), so those regions use the GEMM rate; for the solve this is 30 percent low,
which stays serial a little longer. f32 and c32 are half of f64 and c64 (only the GEMM was checked, 0.019 and
0.084).

### Before and after (`run_bench.py`, `summarize.py`, `tables.md`, `raw/`)

fbench (`faer-only,team` build, threadteam pinned at `5afe0b4` like the fork), f64, column major, 41 reps,
250 ms priming, median, `--check-max-dim 128` (all checked cells `ok`). `before` is t4a-faer `9cd64f0` (the
commit before this change), `after` is `6788b20`. Rows: `faer-fork` at `--threads 1` is the serial time (the
serial processes of both builds are pooled: the serial path is the same code); `faer-fork-free` is a plain
token called from outside the pool (`Par::Rayon(6)`), `faer-fork-team` a team of 6. Four processes per build
at 6 threads (row order rotations 0 to 3), three serial processes per build, interleaved before and after.

## Host protocol

Before every process: no other fbench, cargo or test process, idle at least 85 percent (polled, up to 300 s),
idle, load average and the three top CPU consumers recorded before and after; a process is `busy` when it
started or ended below 85 percent idle. The load average is high because of the desktop session (the top
consumers are WindowServer, iTerm2 and browser renderers, never a benchmark).

Constants (the busy flag comes from the idle after the process; those after values dipped to 74 to 78 percent
for a few seconds, the cause was not identified):

| process | idle before | load1 before | idle after | top 3 before | busy |
| --- | --- | --- | --- | --- | --- |
| gemm-r0 | 91.94 | 11.37 | 89.45 | 21.6 iTerm2; 11.0 WindowServer; 8.3 TextEdit | no |
| lu_full-r0 | 89.55 | 10.23 | 90.19 | 37.7 WindowServer; 32.5 iTerm2; 9.6 pi | no |
| bk-r0 | 85.76 | 8.3 | 76.6 | 43.9 WindowServer; 23.8 iTerm2; 11.3 Codex (Renderer) | yes |
| qr_cp-r0 | 85.22 | 9.66 | 78.58 | 57.0 iTerm2; 44.8 WindowServer; 20.8 com.apple.WebKit.WebContent | yes |
| bidiag-r0 | 85.77 | 8.0 | 87.5 | 56.0 iTerm2; 46.8 WindowServer; 14.3 pi | no |
| hess-r0 | 86.32 | 12.6 | 76.9 | 98.7 rustc; 40.5 WindowServer; 14.5 CursorUIViewService | yes |
| tridiag-r0 | 85.7 | 9.43 | 89.54 | 70.5 com.apple.WebKit.WebContent; 31.5 WindowServer; 11.6 com.apple.WebKit.GPU | no |
| matvec-r0 | 86.59 | 8.52 | 89.92 | 78.0 rustfmt; 24.3 WindowServer; 11.4 iTerm2 | no |
| rank_one-r0 | 87.5 | 14.73 | 73.86 | 54.0 iTerm2; 16.5 WindowServer; 14.2 com.apple.WebKit.WebContent | yes |
| block_apply-r0 | 92.19 | 7.47 | 92.69 | 17.6 iTerm2; 7.5 WindowServer; 6.3 TextEdit | no |
| tri-r0 | 92.56 | 7.19 | 92.55 | 19.7 iTerm2; 9.0 mdworker_shared; 7.5 TextEdit | no |
| gemm-r1 | 91.27 | 6.4 | 93.31 | 23.3 iTerm2; 8.4 TextEdit; 6.6 claude | no |
| lu_full-r1 | 93.22 | 5.57 | 92.18 | 22.7 iTerm2; 8.1 TextEdit; 5.5 WindowServer | no |
| bk-r1 | 89.91 | 4.82 | 89.23 | 24.7 azooKeyMac; 20.3 iTerm2; 16.6 WindowServer | no |
| qr_cp-r1 | 90.78 | 4.39 | 88.89 | 21.1 iTerm2; 15.7 WindowServer; 13.2 azooKeyMac | no |
| bidiag-r1 | 88.21 | 4.55 | 90.2 | 38.0 azooKeyMac; 24.4 WindowServer; 19.9 iTerm2 | no |
| hess-r1 | 89.82 | 4.55 | 77.43 | 26.6 azooKeyMac; 19.8 iTerm2; 14.1 WindowServer | yes |
| tridiag-r1 | 85.7 | 3.98 | 91.59 | 85.8 com.apple.WebKit.WebContent; 19.6 iTerm2; 12.4 koushi-desktop | no |
| matvec-r1 | 92.33 | 3.68 | 90.1 | 20.7 iTerm2; 8.2 WindowServer; 7.0 TextEdit | no |
| rank_one-r1 | 92.95 | 3.82 | 92.97 | 20.8 iTerm2; 13.3 WindowServer; 8.2 TextEdit | no |
| block_apply-r1 | 92.74 | 3.67 | 92.8 | 23.1 iTerm2; 8.5 TextEdit; 8.5 WindowServer | no |
| tri-r1 | 92.87 | 3.42 | 90.84 | 23.5 iTerm2; 9.1 WindowServer; 8.3 TextEdit | no |

Before and after:

| process | idle before | load1 before | idle after | top 3 before | busy |
| --- | --- | --- | --- | --- | --- |
| before-serial-T1-rot0 | 89.33 | 7.1 | 92.54 | 37.4 WindowServer; 26.1 iTerm2; 15.8 CursorUIViewService | no |
| after-serial-T1-rot0 | 89.67 | 7.21 | 88.48 | 26.1 WindowServer; 20.2 iTerm2; 19.8 WindowManager | no |
| before-par-T6-rot0 | 92.4 | 6.63 | 91.94 | 44.3 com.apple.WebKit.WebContent; 19.8 iTerm2; 9.6 WindowServer | no |
| after-par-T6-rot0 | 93.7 | 5.61 | 92.11 | 17.4 iTerm2; 9.8 WindowServer; 6.1 TextEdit | no |
| after-par-T6-rot1 | 93.4 | 5.23 | 92.81 | 19.6 iTerm2; 9.6 WindowServer; 7.1 TextEdit | no |
| before-par-T6-rot1 | 93.2 | 5.12 | 92.44 | 21.2 iTerm2; 7.5 WindowServer; 6.1 TextEdit | no |
| after-serial-T1-rot1 | 92.53 | 5.3 | 92.95 | 21.8 iTerm2; 10.3 WindowServer; 7.3 TextEdit | no |
| before-serial-T1-rot1 | 92.99 | 4.86 | 92.79 | 19.5 iTerm2; 19.0 Cursor Helper (Renderer); 7.0 WindowServer | no |
| after-par-T6-rot2 | 87.95 | 3.25 | 93.38 | 56.5 koushi-desktop; 42.6 com.apple.WebKit.WebContent; 22.0 iTerm2 | no |
| before-par-T6-rot2 | 92.35 | 3.3 | 92.36 | 20.4 iTerm2; 9.3 WindowServer; 6.1 TextEdit | no |
| before-par-T6-rot3 | 93.12 | 4.46 | 92.34 | 22.0 iTerm2; 8.2 WindowServer; 7.5 TextEdit | no |
| after-par-T6-rot3 | 92.83 | 4.49 | 91.77 | 22.2 iTerm2; 9.3 WindowServer; 6.6 TextEdit | no |
| before-serial-T1-rot2 | 92.3 | 4.31 | 88.41 | 19.7 iTerm2; 9.4 WindowServer; 8.6 talagentd | no |
| after-serial-T1-rot2 | 92.81 | 4.1 | 92.46 | 20.8 iTerm2; 7.6 WindowServer; 6.4 TextEdit | no |

## Results (`tables.md`)

Microseconds per call (median of processes), f64, `*` marks a cell with a busy process. Ratios are to the one thread serial time.

| family | n | serial | plain before | plain after | team before | team after | plain b/s | plain a/s | team b/s | team a/s |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| QR (factorization) | 128 | 119.9 | 298.3 | 121.6 | 85.9 | 102.4 | 2.49 | 1.01 | 0.72 | 0.85 |
| QR (factorization) | 256 | 681.1 | 1357.4 | 547.7 | 415.1 | 395.8 | 1.99 | 0.80 | 0.61 | 0.58 |
| QR (factorization) | 512 | 4180.1 | 5086.0 | 1994.8 | 1704.6 | 1701.3 | 1.22 | 0.48 | 0.41 | 0.41 |
| Cholesky | 128 | 28.6 | 28.5 | 28.6 | 28.5 | 28.6 | 1.00 | 1.00 | 1.00 | 1.00 |
| Cholesky | 256 | 149.9 | 143.8 | 150.3 | 102.0 | 101.9 | 0.96 | 1.00 | 0.68 | 0.68 |
| Cholesky | 512 | 1016.6 | 580.4 | 605.2 | 419.4 | 421.7 | 0.57 | 0.60 | 0.41 | 0.41 |
| SVD (singular values) | 128 | 930.7 | 760.4 | 760.5 | 762.4 | 760.4 | 0.82 | 0.82 | 0.82 | 0.82 |
| SVD (singular values) | 256 | 4757.3 | 5011.7 | 4120.4 | 4972.1 | 4140.8 | 1.05 | 0.87 | 1.05 | 0.87 |
| SVD (singular values) | 512 | 26362.4 | 28788.0 | 23212.8 | 28724.2 | 23241.0 | 1.09 | 0.88 | 1.09 | 0.88 |
| EVD (eigh) | 128 | 850.2 | 1056.5 | 856.3 | 1045.3 | 857.5 | 1.24 | 1.01 | 1.23 | 1.01 |
| EVD (eigh) | 256 | 3842.3 | 3103.0 | 3120.0 | 3053.8 | 3120.5 | 0.81 | 0.81 | 0.79 | 0.81 |
| EVD (eigh) | 512 | 21115.8 | 14615.3 | 13971.6 | 14591.7 | 13907.1 | 0.69 | 0.66 | 0.69 | 0.66 |

## Reading

* The plain token from outside the pool was slower than serial at 128 and 256 for QR (2.49 and 1.99 times) and
  at 128 for the eigensolver (1.24); it now stays serial at 128 (1.01) and is faster than before everywhere
  else: QR 256 0.80 (was 1.99), 512 0.48 (1.22), SVD 256 and 512 0.87 and 0.88 (1.05 and 1.09).
* The team token: QR 256 and 512 are unchanged (0.61 to 0.58, 0.41 to 0.41); SVD 256 and 512 improve (1.05 and
  1.09 to 0.87 and 0.88); EVD and Cholesky are unchanged within noise. **QR 128 on a team is worse than
  before**: 86 us before (0.72 of serial), 102 us now (0.85), still faster than serial. The cause is not
  established; the candidates are the Householder regions of the blocked QR that the old `8192` floors kept
  parallel at 128 and the new floors (4.2 us of serial time, 113 thousand multiply-adds at the GEMM rate) keep
  serial, at shapes whose GEMM rate is below the L2 resident rate used for the constant (`16^3` is 0.07 ns per
  MAC against 0.037).
* Plain Cholesky 512 is 4 percent slower (580 to 605 us), the team is unchanged (419 to 422).
* SVD 128 serial (931 us) is 22 percent slower than every 6 thread row at 128 (760 us, before and after), which
  all run their serial reductions: the difference comes from the parallel divide and conquer joins of
  `bidiag_svd` and `tridiag_evd`, which have no gate of the families of this change.

## Files

`run_bench.py` (runner and host protocol), `summarize.py`, `tables.md`, `raw/` (one CSV per process),
`processes.log`, `run.log`, `run2.log`; `constants/` (`bench/` source, `run_consts.py`, `summarize_consts.py`,
`raw/`, `processes.log`, `run.log`, `tables.md`).
