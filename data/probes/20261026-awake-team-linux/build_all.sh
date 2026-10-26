#!/usr/bin/env bash
# Build every binary of the Linux acceptance run into awake-team-linux/target-bench/ and record the revisions,
# the rustc version and the binary sha256 in raw/build-info.txt. Nothing is timed here.
#
#   build_all.sh            # all
#   build_all.sh fbench     # one of: fbench tt consts stack
#
# Builds run on all CPUs (`taskset -c 0-23`) unless awake-team-linux/MEASURING exists, in which case they are
# confined to the observer domain 0-3,12-15 (never build on the measured cores while a measurement runs).
# RUSTC_WRAPPER is emptied: the kache wrapper breaks path-patched builds.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
R="$(cd "$HERE/../../../.." && pwd)"            # awake-team-linux
FB="$R/faer-benchmark"
CPUS=0-23
[[ -e "$R/MEASURING" ]] && CPUS=0-3,12-15
export RUSTC_WRAPPER=
mkdir -p "$R/target-bench" "$HERE/raw" "$R/extern-build"
want() { [[ $# -eq 0 ]]; }
WHAT=("${@:-all}")
sel() { [[ "${WHAT[0]}" == all ]] || [[ " ${WHAT[*]} " == *" $1 "* ]]; }

# --- fbench: ONLY through scripts/build_for_faer_rev.sh. The script needs real `.git` directories (not worktrees):
# extern-build/ holds local clones of the two handoff revisions (faer 2107b81, upstream faer-v0.24.4).
if sel fbench; then
  [[ -d "$R/extern-build/t4a-faer/.git" ]] || { git clone -q --no-hardlinks --no-checkout "$R/faer" "$R/extern-build/t4a-faer"; }
  git -C "$R/extern-build/t4a-faer" checkout -q --detach 2107b81a6d730cb93fae560d783277d3ee2a0fa8
  [[ -d "$R/extern-build/upstream-faer/.git" ]] || { git clone -q --no-hardlinks --no-checkout "$FB/../../faer-benchmark/extern/upstream-faer" "$R/extern-build/upstream-faer" 2>/dev/null \
      || git clone -q --no-hardlinks --no-checkout /home/shinaoka/projects/tensor4all/faer-benchmark/extern/upstream-faer "$R/extern-build/upstream-faer"; }
  git -C "$R/extern-build/upstream-faer" checkout -q --detach 0539947ffb757a739d7e703a7d2fa0c792a909c1
  (cd "$FB" && BENCH_TARGET_DIR="$R/target-bench/fbench" taskset -c "$CPUS" scripts/build_for_faer_rev.sh \
      --checkout "$R/extern-build/t4a-faer" --upstream "$R/extern-build/upstream-faer" --vendor none --features team \
      --out "$R/target-bench/fbench.env" --bin fbench)
  # The build re-resolves Cargo.lock for the patched graph (path sources for faer, faer-traits; windows-sys). Keep the
  # diff as evidence and put the committed lock back: it must not be committed with the checkout paths.
  (cd "$FB" && git diff Cargo.lock > "$HERE/raw/fbench-cargo-lock.diff" && git checkout -- Cargo.lock)
fi
if sel tt; then
  CARGO_TARGET_DIR="$R/target-bench/tt" taskset -c "$CPUS" cargo build --release --manifest-path "$HERE/bench/tt/Cargo.toml" --bin dispatch_cost --bin wake_probe
  CARGO_TARGET_DIR="$R/target-bench/tt-trace" taskset -c "$CPUS" cargo build --release --features trace --manifest-path "$HERE/bench/tt/Cargo.toml" --bin idle_trace
fi
if sel consts; then
  CARGO_TARGET_DIR="$R/target-bench/consts" taskset -c "$CPUS" cargo build --release --manifest-path "$HERE/bench/consts/Cargo.toml"
fi
if sel stack; then
  CARGO_TARGET_DIR="$R/target-bench/stack" taskset -c "$CPUS" cargo build --release --manifest-path "$HERE/bench/stack/Cargo.toml"
fi

{
  echo "# build-info $(date -u +%FT%TZ)"
  echo "rustc: $(rustc --version)  cargo: $(cargo --version)"
  for d in threadteam-rs faer strided-rs tcontract-rs cpueinsum-rs tlinalg-rs faer-benchmark; do
    printf '%s %s dirty=%s\n' "$d" "$(git -C "$R/$d" rev-parse HEAD)" "$([[ -n "$(git -C "$R/$d" status --porcelain --untracked-files=no)" ]] && echo yes || echo no)"
  done
  echo "extern-build/t4a-faer $(git -C "$R/extern-build/t4a-faer" rev-parse HEAD)  extern-build/upstream-faer $(git -C "$R/extern-build/upstream-faer" rev-parse HEAD)"
  echo "threadteam-rs d08b3e7 vs 5afe0b4 (the rev the fork and fbench pin): diff of src/ Cargo.toml benches/: $(git -C "$R/threadteam-rs" diff --stat 5afe0b4 d08b3e7 -- src Cargo.toml benches | tail -1)"
  for b in fbench/release/fbench tt/release/dispatch_cost tt/release/wake_probe tt-trace/release/idle_trace \
           consts/release/consts consts/release/regions_consts stack/release/thr-confirm stack/release/tl-probe; do
    [[ -x "$R/target-bench/$b" ]] && sha256sum "$R/target-bench/$b"
  done
} | tee "$HERE/raw/build-info.txt"
