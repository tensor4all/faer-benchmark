# Householder partial-merge diagnostic (predeclared)

A=fixed2240b076a030 binary from the first LU-baseline manifest (SHA checked).
B=ad9f2ef45e3508dddc15c275f5482e597f1da7c4, built once by the normal MKL build
script, whose actual-checkout Cargo graph check passed. No LU/copy candidate
is combined here. Upstream stays0539947ffb757a739d7e703a7d2fa0c792a909c1.
The measured fbench/Cargo sources are unchanged from the old binary's harness.

This is a staged diagnostic, NOT adoption or a replacement for the failed control
comparisons. Keep every sample, failed guard attempt and unchanged-row shift.
Do not apply looser thresholds or trim inconvenient starts. The complete-public-
call boundary, preparation, allocation/destruction and caller thread budget stay
unchanged. The code change only moves the partial sum to existing column tasks;
longer partial-buffer/packing overlap may itself regress.

## Stage1: householder

- family=householder_apply; shapes64²,1024x64,4096x256; f64/c64; C/F;
  block+sequence;1/4/8T. Vendor's unsupported HH cells remain explicit skips.
-64² is an unchanged-path check, not an expected fix.1024x64 is an existing
  improvement guard;4096x256 is the target for the serial partial-merge lead.
-4096x256 belongs to the existing MID suite and is thin, not the4096² large tier.

Only if the complete stage1 grid supports the mechanism and no new HH regression
appears, run stage2. If stage1 rejects it, keep its data, reject/diagnose the
candidate, and do not spend time on the downstream grid. Unrun guards never pass.

## Stage2: downstream (not automatically launched)

QR factor/composite at512² and1024x64; SVD values/thin/eigh at512², f64/c64,
C/F,1/4/8T. These are diagnostic shared-caller guards, NOT complete acceptance.
All declared affected populations still need verification before adoption.

Run from faer-benchmark with `python3 data/probes/20261018-householder-partial-merge/run.py householder`.
The `downstream` argument is a separately launched stage after the complete
stage1 evidence has been checked, not an automatic continuation.

## Common fixed conditions

Use the existing campaign lock, frozen binaries, dynamic sysfs whole-L3 topology
and recorded profile CPU sets; observer/agent outside that domain. Boost0,
amd_pstate active, governor/EPP performance, maximum2GHz as in the reference
manifest. Check power before/after every invocation. All selected grids verified
for both binaries and all budgets before any timing. Info plus every CSV records
actual Rayon/vendor counts;1T must be Par::Seq, observed1/1.

Three complete process starts per binary/budget, row rotations0/1/2, medians of5,
250ms time priming; rows fork/upstream/MKL. Source order per budget: A B B A A B
(each binary's process counter determines its row rotation). The new pinned.sh
retains rejected stdout/CSV/CPU guard logs; explicit PINNED_CSV per invocation,
idle3s/5% with8 bounded admissions. Never modify tracked harness/toolkit/library
source or build during recording. Check binary hashes/HEAD/clean state again.
Audit full cell identity, variants, sample count and process count, not an
intersection of cells. Ratios are descriptive only, with all start medians saved.

**faer-kernels-large2048/3072/4096 are NOT run here. They run only after final
candidate freeze in the final all-suite campaign, per the user's instruction.**
