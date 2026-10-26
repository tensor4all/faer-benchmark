#!/usr/bin/env bash
# Build every measurement binary of the awake-team Linux probe against the team-gemm-executor fork
# (faer exp/team-gemm-executor 9f92e5c = min_cost check, threadteam pin 0036264 (post parker fix, linux_x86 row 0.6/0.7/0.9), t4a-private-gemm-x86 212cacf = 0.1.26, strided-rs 5da0ef3; fbench with explicit-Par svd_values/eigh/svd_thin/triangular_solve) into
# awake-team-linux/target-bench/<name>-exec3 and write raw-exec3/build-info.txt. Nothing is timed here.
# The acceptance-run binaries (target-bench/{fbench,tt,tt-trace,consts,stack,qr128,...}) are never touched.
#
#   build_exec3.sh            # all        build_exec3.sh info   # only (re)write raw-exec3/build-info.txt
#
# Builds run on all CPUs unless awake-team-linux/MEASURING exists (then 0-3,12-15). RUSTC_WRAPPER is emptied.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
R="$(cd "$HERE/../../../.." && pwd)"; FB="$R/faer-benchmark"; T="$R/target-bench"
CPUS=0-23; [[ -e "$R/MEASURING" ]] && CPUS=0-3,12-15
export RUSTC_WRAPPER=
FORK_REV=${FORK_REV:-9f92e5c23d170eb79f3dcce53957c3ceb7cb4ddc}
B="$HERE/bench"
mkdir -p "$HERE/raw-exec3"
# strided-rs feat/dispatch-cost 5da0ef3 (MapFn/Classed: thr-confirm's exp declares KernelClass::Transcendental); a clean clone in extern-build/
STRIDED_REV=5da0ef39597d2d7e29a9a5a03df1769a4c336eee
[[ -d "$R/extern-build/strided-rs-5da0ef3" ]] || git clone -q "$R/strided-rs" "$R/extern-build/strided-rs-5da0ef3"
git -C "$R/extern-build/strided-rs-5da0ef3" checkout -q --detach "$STRIDED_REV"
if [[ "${1:-all}" != info ]]; then
  # fbench: only through build_for_faer_rev.sh (clean clones in extern-build/, not worktrees)
  git -C "$R/extern-build/t4a-faer" fetch -q https://github.com/tensor4all/faer exp/team-gemm-executor || true
  git -C "$R/extern-build/t4a-faer" checkout -q --detach "$FORK_REV"
  git -C "$R/extern-build/upstream-faer" checkout -q --detach 0539947ffb757a739d7e703a7d2fa0c792a909c1
  (cd "$FB" && BENCH_TARGET_DIR="$T/fbench-exec3" taskset -c "$CPUS" scripts/build_for_faer_rev.sh \
      --checkout "$R/extern-build/t4a-faer" --upstream "$R/extern-build/upstream-faer" --vendor none --features team \
      --out "$T/fbench-exec3.env" --bin fbench)
  # read the lock diff unfiltered, then restore the committed lock (the patched graph re-resolves it)
  (cd "$FB" && git diff Cargo.lock > "$HERE/raw-exec3/fbench-cargo-lock.diff" && git checkout -- Cargo.lock)
  B="$HERE/bench"
  for d in stack qr128 consts; do
    CARGO_TARGET_DIR="$T/$d-exec3" taskset -c "$CPUS" cargo build --release --manifest-path "$B/$d-exec3/Cargo.toml"
  done
  CARGO_TARGET_DIR="$T/tt-exec3" taskset -c "$CPUS" cargo build --release --manifest-path "$B/tt/Cargo.toml" --bin dispatch_cost --bin wake_probe
  CARGO_TARGET_DIR="$T/tt-trace-exec3" taskset -c "$CPUS" cargo build --release --features trace --manifest-path "$B/tt/Cargo.toml" --bin idle_trace
fi
{
  echo "# build-info (exec3) $(date -u +%FT%TZ)"
  echo "rustc: $(rustc --version)  cargo: $(cargo --version)"
  for d in threadteam-rs faer-teamgemm-pin strided-rs tcontract-rs cpueinsum-rs tlinalg-rs faer-benchmark; do
    printf '%s %s branch=%s dirty=%s\n' "$d" "$(git -C "$R/$d" rev-parse HEAD)" "$(git -C "$R/$d" branch --show-current)" \
      "$([[ -n "$(git -C "$R/$d" status --porcelain --untracked-files=no)" ]] && echo yes || echo no)"
  done
  echo "extern-build/strided-rs-5da0ef3 $(git -C "$R/extern-build/strided-rs-5da0ef3" rev-parse HEAD) (stack-exec3 strided path; the strided-rs worktree line above is not used)"
  echo "extern-build/t4a-faer $(git -C "$R/extern-build/t4a-faer" rev-parse HEAD)  extern-build/upstream-faer $(git -C "$R/extern-build/upstream-faer" rev-parse HEAD)"
  echo "t4a-private-gemm-x86 git rev 212cacf5b4a2f79f5e1a409542ff0e91930caa1f (feat/executor, 0.1.26); threadteam 0036264f1d2c2e6575dd6130698a8a59eb5fb663"
  echo "graph check (one entry each in the lock of every build):"
  for d in stack-exec3 qr128-exec3 consts-exec3; do
    echo "  $d: threadteam x$(grep -c '^name = "threadteam"' "$HERE/bench/$d/Cargo.lock"), t4a-private-gemm-x86 x$(grep -c '^name = "t4a-private-gemm-x86"' "$HERE/bench/$d/Cargo.lock") $(grep -A2 '^name = "t4a-private-gemm-x86"' "$HERE/bench/$d/Cargo.lock" | grep -o 'rev=[0-9a-f]\{7\}' | head -1)"
  done
  echo "  fbench-exec3: patched lock (resolved during the build; committed lock restored): see raw-exec3/fbench-cargo-lock.diff; harness threadteam rev $(grep -o 'rev = "[0-9a-f]\{7\}' "$FB/fbench/Cargo.toml" | head -1)"
  for b in fbench-exec3/release/fbench tt-exec3/release/dispatch_cost tt-exec3/release/wake_probe tt-trace-exec3/release/idle_trace \
           consts-exec3/release/consts consts-exec3/release/regions_consts stack-exec3/release/thr-confirm stack-exec3/release/tl-probe \
           stack-exec3/release/tl-team-diag qr128-exec3/release/qr128-fix; do
    [[ -x "$T/$b" ]] && sha256sum "$T/$b"
  done
} | tee "$HERE/raw-exec3/build-info.txt"
