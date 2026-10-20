#!/bin/sh
# One publication of this campaign: both arms at the pin, then the site.
#
# The routine (campaign_toolkit.publish) preflights the machine and the trees, runs this,
# commits what it wrote and pushes. Do not run it while another campaign measures: the
# recorder's lock and the preflight both refuse that.
set -eu
REV=$(grep -v '^#' pins/t4a-faer.rev | grep -E '^[0-9a-f]{40}' | head -1)
LABEL="pub-$(echo "$REV" | cut -c1-8)-$(date -u +%Y%m%d)"
TASKSET="taskset -c 0-3,12-15"

$TASKSET python3 scripts/record_run.py zen5-cpu faer-kernels \
    --vendor mkl --engines faer-fork,faer-upstream,lapack-mkl --threads 1,4,8 \
    --dtypes f64,c64 --reps 5 --aa 3 --prime-ms 250 --label "$LABEL-mkl"
$TASKSET python3 scripts/record_run.py zen5-cpu faer-kernels \
    --vendor openblas --engines faer-fork,lapack-openblas --threads 1,4,8 \
    --dtypes f64,c64 --reps 5 --aa 6 --prime-ms 250 --label "$LABEL-openblas"

MKL=$(ls -1dt data/results/zen5-cpu/faer-kernels/*"$LABEL-mkl" | head -1)
OPENBLAS=$(ls -1dt data/results/zen5-cpu/faer-kernels/*"$LABEL-openblas" | head -1)
PREV=$(ls -1dt data/results/zen5-cpu/faer-kernels/*-mkl | grep -v "$LABEL-mkl" | head -1 || true)
CONTROL=""
[ -n "$PREV" ] && CONTROL="--control-mkl $PREV"
python3 scripts/gen_comparison.py --mkl "$MKL" --openblas "$OPENBLAS" $CONTROL \
    --out "result/zen5-cpu/faer-kernels/$(echo "$REV" | cut -c1-12)-comparison.html" \
    --index result/index.html
