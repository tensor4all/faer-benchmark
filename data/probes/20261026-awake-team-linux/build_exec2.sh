#!/usr/bin/env bash
# Build every measurement binary of the awake-team Linux probe against the team-gemm-executor fork
# (faer exp/team-gemm-executor 7e0f98f = serial-path fix + min_cost check, t4a-private-gemm-x86 212cacf = 0.1.26, threadteam 7095893) into
# awake-team-linux/target-bench/<name>-exec2 and write raw-exec2/build-info.txt. Nothing is timed here.
# The acceptance-run binaries (target-bench/{fbench,tt,tt-trace,consts,stack,qr128,...}) are never touched.
#
#   build_exec2.sh            # all        build_exec2.sh info   # only (re)write raw-exec2/build-info.txt
#
# Builds run on all CPUs unless awake-team-linux/MEASURING exists (then 0-3,12-15). RUSTC_WRAPPER is emptied.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
R="$(cd "$HERE/../../../.." && pwd)"; FB="$R/faer-benchmark"; T="$R/target-bench"
CPUS=0-23; [[ -e "$R/MEASURING" ]] && CPUS=0-3,12-15
export RUSTC_WRAPPER=
FORK_REV=${FORK_REV:-7e0f98fbd886e74a59a8b9569c5a785c34ccbc3b}
B="$HERE/bench"
mkdir -p "$HERE/raw-exec2"
# strided-rs moved on after the exec build (5da0ef3 changes the map API); the stack probe stays on the handoff bd03608,
# a clean clone in extern-build/ (the worktree is only read)
STRIDED_REV=bd0360888353fe65dcbbb87da1414a65d2761ac8
[[ -d "$R/extern-build/strided-rs-bd03608" ]] || git clone -q "$R/strided-rs" "$R/extern-build/strided-rs-bd03608"
git -C "$R/extern-build/strided-rs-bd03608" checkout -q --detach "$STRIDED_REV"
if [[ "${1:-all}" != info ]]; then
  # fbench: only through build_for_faer_rev.sh (clean clones in extern-build/, not worktrees)
  git -C "$R/extern-build/t4a-faer" fetch -q https://github.com/tensor4all/faer exp/team-gemm-executor || true
  git -C "$R/extern-build/t4a-faer" checkout -q --detach "$FORK_REV"
  git -C "$R/extern-build/upstream-faer" checkout -q --detach 0539947ffb757a739d7e703a7d2fa0c792a909c1
  (cd "$FB" && BENCH_TARGET_DIR="$T/fbench-exec2" taskset -c "$CPUS" scripts/build_for_faer_rev.sh \
      --checkout "$R/extern-build/t4a-faer" --upstream "$R/extern-build/upstream-faer" --vendor none --features team \
      --out "$T/fbench-exec2.env" --bin fbench)
  # read the lock diff unfiltered, then restore the committed lock (the patched graph re-resolves it)
  (cd "$FB" && git diff Cargo.lock > "$HERE/raw-exec2/fbench-cargo-lock.diff" && git checkout -- Cargo.lock)
  B="$HERE/bench"
  for d in stack qr128 consts; do
    CARGO_TARGET_DIR="$T/$d-exec2" taskset -c "$CPUS" cargo build --release --manifest-path "$B/$d-exec2/Cargo.toml"
  done
  CARGO_TARGET_DIR="$T/tt-exec2" taskset -c "$CPUS" cargo build --release --manifest-path "$B/tt/Cargo.toml" --bin dispatch_cost --bin wake_probe
  CARGO_TARGET_DIR="$T/tt-trace-exec2" taskset -c "$CPUS" cargo build --release --features trace --manifest-path "$B/tt/Cargo.toml" --bin idle_trace
fi
{
  echo "# build-info (exec2) $(date -u +%FT%TZ)"
  echo "rustc: $(rustc --version)  cargo: $(cargo --version)"
  for d in threadteam-rs faer-teamgemm-pin strided-rs tcontract-rs cpueinsum-rs tlinalg-rs faer-benchmark; do
    printf '%s %s branch=%s dirty=%s\n' "$d" "$(git -C "$R/$d" rev-parse HEAD)" "$(git -C "$R/$d" branch --show-current)" \
      "$([[ -n "$(git -C "$R/$d" status --porcelain --untracked-files=no)" ]] && echo yes || echo no)"
  done
  echo "extern-build/strided-rs-bd03608 $(git -C "$R/extern-build/strided-rs-bd03608" rev-parse HEAD) (stack-exec2 strided path; the strided-rs worktree line above is not used)"
  echo "extern-build/t4a-faer $(git -C "$R/extern-build/t4a-faer" rev-parse HEAD)  extern-build/upstream-faer $(git -C "$R/extern-build/upstream-faer" rev-parse HEAD)"
  echo "t4a-private-gemm-x86 git rev 212cacf5b4a2f79f5e1a409542ff0e91930caa1f (feat/executor, 0.1.26); threadteam 709589322fe50a9bcd6f33ef81aec0ba3e6042ed"
  echo "graph check (one entry each in the lock of every build):"
  for d in stack-exec2 qr128-exec2 consts-exec2; do
    echo "  $d: threadteam x$(grep -c '^name = "threadteam"' "$HERE/bench/$d/Cargo.lock"), t4a-private-gemm-x86 x$(grep -c '^name = "t4a-private-gemm-x86"' "$HERE/bench/$d/Cargo.lock") $(grep -A2 '^name = "t4a-private-gemm-x86"' "$HERE/bench/$d/Cargo.lock" | grep -o 'rev=[0-9a-f]\{7\}' | head -1)"
  done
  echo "  fbench-exec2: patched lock (resolved during the build; committed lock restored): see raw-exec2/fbench-cargo-lock.diff; harness threadteam rev $(grep -o 'rev = "[0-9a-f]\{7\}' "$FB/fbench/Cargo.toml" | head -1)"
  for b in fbench-exec2/release/fbench tt-exec2/release/dispatch_cost tt-exec2/release/wake_probe tt-trace-exec2/release/idle_trace \
           consts-exec2/release/consts consts-exec2/release/regions_consts stack-exec2/release/thr-confirm stack-exec2/release/tl-probe \
           stack-exec2/release/tl-team-diag qr128-exec2/release/qr128-fix; do
    [[ -x "$T/$b" ]] && sha256sum "$T/$b"
  done
} | tee "$HERE/raw-exec2/build-info.txt"
