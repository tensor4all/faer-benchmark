#!/usr/bin/env python3
"""Cholesky 128-512 at 8 and 4 threads on the exec3 binaries (parker fix, GEMM race fix, post-fix Linux row), five rows, every rotation;
plus diag-gemm counters for cholesky 256/512. Under hostguard; outputs raw-exec3/chol/."""
import sys
from pathlib import Path
import hostguard

HERE = Path(__file__).resolve().parent
FB = "/home/shinaoka/projects/tensor4all/awake-team-linux/target-bench/fbench-exec3/release/fbench"
ROWS = "faer-fork,faer-upstream,faer-fork-hot,faer-fork-free,faer-fork-team"
OUT = HERE / "raw-exec3" / "chol"


def main():
    dry = "--dry-run" in sys.argv
    hostguard.RAWNAME = "raw-exec3"
    OUT.mkdir(parents=True, exist_ok=True)
    plan = []
    for T, mask in ((8, "4-11"), (4, "4-7")):
        for rot in range(5):
            csv = OUT / f"chol-T{T}-rot{rot}.csv"
            plan.append((f"chol-T{T}-rot{rot}", mask, [FB, "run", "--threads", str(T), "--n", "128,256,512", "--family",
                         "cholesky", "--rows", ROWS, "--rotate-rows", str(rot), "--orders", "F", "--reps", "41",
                         "--prime-ms", "250", "--statistic", "median", "--regime", "chol-check", "--check-max-dim", "512",
                         "--csv", str(csv)], None, [str(csv)]))
    plan.append(("chol-diag-T8", "4-11", [FB, "diag-gemm", "--threads", "8", "--family", "cholesky", "--n", "256,512",
                 "--reps", "3", "--rows", ROWS], OUT / "chol-diag-T8.csv", []))
    for tag, mask, cmd, so, outs in plan:
        hostguard.run_guarded(tag, cmd, mask, HERE, stdout_file=str(so) if so and not dry else None, outputs=outs,
                              dry_run=dry, log=OUT / "processes.log")


if __name__ == "__main__":
    main()
