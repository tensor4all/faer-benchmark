#!/usr/bin/env python3
"""QR 128 and tlinalg follow-up experiments (tensor4all-meta#51), each process under hostguard.

Three faer builds per QR experiment: qr128-old (2107b81), qr128 (c47e8e2, stopgap), qr128-exec (4ed3db8, kernel on
the team). Outputs under raw-exec/followup/, one stdout file per process, records in raw-exec/followup/processes.log.
"""
import sys
from pathlib import Path

import hostguard

HERE = Path(__file__).resolve().parent
B = Path("/home/shinaoka/projects/tensor4all/awake-team-linux/target-bench")
OUT = HERE / "raw-exec" / "followup"
QR = {"old": B / "qr128/release/qr128-old", "stopgap": B / "qr128/release/qr128", "exec": B / "qr128-exec/release/qr128-exec"}
TL = {"old": B / "stack-faer2107/release/tl-team-diag", "stopgap": B / "stack/release/tl-team-diag",
      "exec": B / "stack-exec/release/tl-team-diag"}


def plan():
    out = []
    for w, mask in ((8, "4-11"), (4, "4-7")):
        for name, exe in QR.items():
            out.append((f"qr-e0-{name}-T{w}", mask, [str(exe), "time", str(w), "128", "--ms", "600", "--modes",
                                                      "seq,rayon,team-serial"]))
            out.append((f"qr-e1-{name}-T{w}", mask, [str(exe), "time", str(w), "128", "--ms", "600", "--modes",
                        "seq,team-serial,team-ntasks-never,team-generic,team-linux,team-pays1,team-ntasks-always,team-par"]))
            out.append((f"qr-e2-{name}-T{w}", mask, [str(exe), "apply", str(w), "--ms", "150"]))
            for lw in (() if name == "old" else ("1", "0")):  # 2107b81 probe has no anatomy mode
                out.append((f"qr-e3-{name}-T{w}-lw{lw}", mask, [str(exe), "anatomy", str(w), "--m", "128", "--reps",
                                                               "3000", "--leader-writes", lw]))
    for name, exe in TL.items():
        out.append((f"tl-solo-{name}", "4", [str(exe), "solo", "5"]))
    return out


def main():
    dry = "--dry-run" in sys.argv
    hostguard.RAWNAME = "raw-exec"
    OUT.mkdir(parents=True, exist_ok=True)
    for tag, mask, cmd in plan():
        dest = OUT / f"{tag}.txt"
        if not dry and dest.exists() and dest.stat().st_size > 0:
            continue
        hostguard.run_guarded(tag, cmd, mask, HERE, stdout_file=str(dest) if not dry else None, dry_run=dry,
                              log=OUT / "processes.log")


if __name__ == "__main__":
    main()
