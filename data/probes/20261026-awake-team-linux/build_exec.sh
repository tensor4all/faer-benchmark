#!/usr/bin/env bash
# Build every measurement binary of the awake-team Linux probe against the team-gemm-executor fork
# (faer exp/team-gemm-executor 4ed3db8, t4a-private-gemm-x86 4f51ae9, threadteam 586738b) into
# awake-team-linux/target-bench/<name>-exec and write raw-exec/build-info.txt. Nothing is timed here.
# The acceptance-run binaries (target-bench/{fbench,tt,tt-trace,consts,stack,qr128,...}) are never touched.
#
#   build_exec.sh            # all        build_exec.sh info   # only (re)write raw-exec/build-info.txt
#
# Builds run on all CPUs unless awake-team-linux/MEASURING exists (then 0-3,12-15). RUSTC_WRAPPER is emptied.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
R="$(cd "$HERE/../../../.." && pwd)"; FB="$R/faer-benchmark"; T="$R/target-bench"
CPUS=0-23; [[ -e "$R/MEASURING" ]] && CPUS=0-3,12-15
export RUSTC_WRAPPER=
FORK_REV=4ed3db8cef92185555c12d51048587760ff32db5
B="$HERE/bench"
mkdir -p "$HERE/raw-exec"
if [[ "${1:-all}" != info ]]; then
  # fbench: only through build_for_faer_rev.sh (clean clones in extern-build/, not worktrees)
  git -C "$R/extern-build/t4a-faer" fetch -q https://github.com/tensor4all/faer exp/team-gemm-executor || true
  git -C "$R/extern-build/t4a-faer" checkout -q --detach "$FORK_REV"
  git -C "$R/extern-build/upstream-faer" checkout -q --detach 0539947ffb757a739d7e703a7d2fa0c792a909c1
  (cd "$FB" && BENCH_TARGET_DIR="$T/fbench-exec" taskset -c "$CPUS" scripts/build_for_faer_rev.sh \
      --checkout "$R/extern-build/t4a-faer" --upstream "$R/extern-build/upstream-faer" --vendor none --features team \
      --out "$T/fbench-exec.env" --bin fbench)
  # read the lock diff unfiltered, then restore the committed lock (the patched graph re-resolves it)
  (cd "$FB" && git diff Cargo.lock > "$HERE/raw-exec/fbench-cargo-lock.diff" && git checkout -- Cargo.lock)
  B="$HERE/bench"
  for d in stack qr128 consts; do
    CARGO_TARGET_DIR="$T/$d-exec" taskset -c "$CPUS" cargo build --release --manifest-path "$B/$d-exec/Cargo.toml"
  done
  CARGO_TARGET_DIR="$T/tt-exec" taskset -c "$CPUS" cargo build --release --manifest-path "$B/tt/Cargo.toml" --bin dispatch_cost --bin wake_probe
  CARGO_TARGET_DIR="$T/tt-trace-exec" taskset -c "$CPUS" cargo build --release --features trace --manifest-path "$B/tt/Cargo.toml" --bin idle_trace
fi
{
  echo "# build-info (exec) $(date -u +%FT%TZ)"
  echo "rustc: $(rustc --version)  cargo: $(cargo --version)"
  for d in threadteam-rs faer-teamgemm strided-rs tcontract-rs cpueinsum-rs tlinalg-rs faer-benchmark; do
    printf '%s %s branch=%s dirty=%s\n' "$d" "$(git -C "$R/$d" rev-parse HEAD)" "$(git -C "$R/$d" branch --show-current)" \
      "$([[ -n "$(git -C "$R/$d" status --porcelain --untracked-files=no)" ]] && echo yes || echo no)"
  done
  echo "extern-build/t4a-faer $(git -C "$R/extern-build/t4a-faer" rev-parse HEAD)  extern-build/upstream-faer $(git -C "$R/extern-build/upstream-faer" rev-parse HEAD)"
  echo "t4a-private-gemm-x86 git rev 4f51ae9a83a851fad46fba13aa3d92bf136cf49d (feat/executor); threadteam 586738b6b6384617a455e35f0bcdfe616e40ea04"
  echo "graph check (one entry each in the lock of every build):"
  for d in stack-exec qr128-exec consts-exec; do
    echo "  $d: threadteam x$(grep -c '^name = "threadteam"' "$HERE/bench/$d/Cargo.lock"), t4a-private-gemm-x86 x$(grep -c '^name = "t4a-private-gemm-x86"' "$HERE/bench/$d/Cargo.lock") $(grep -A2 '^name = "t4a-private-gemm-x86"' "$HERE/bench/$d/Cargo.lock" | grep -o 'rev=[0-9a-f]\{7\}' | head -1)"
  done
  echo "  fbench-exec: patched lock (resolved during the build; committed lock restored): see raw-exec/fbench-cargo-lock.diff; harness threadteam rev $(grep -o 'rev = "[0-9a-f]\{7\}' "$FB/fbench/Cargo.toml" | head -1)"
  for b in fbench-exec/release/fbench tt-exec/release/dispatch_cost tt-exec/release/wake_probe tt-trace-exec/release/idle_trace \
           consts-exec/release/consts consts-exec/release/regions_consts stack-exec/release/thr-confirm stack-exec/release/tl-probe \
           stack-exec/release/tl-team-diag qr128-exec/release/qr128-exec; do
    [[ -x "$T/$b" ]] && sha256sum "$T/$b"
  done
} | tee "$HERE/raw-exec/build-info.txt"
