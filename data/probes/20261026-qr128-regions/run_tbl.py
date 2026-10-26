#!/usr/bin/env python3
"""Before (6788b20) and after (dd0bc19) tables: each cell is one process of the bench, serial / plain (Par::rayon(6)
from outside the pool) / team(6) in interleaved rounds. Pass r alternates the order of the two builds."""
import os, subprocess, sys
cells = [(f, n) for f in ("qr", "svd", "evd", "tinv") for n in (128, 256, 512)] + [("spmm", n) for n in (500, 2000, 8000)]
if os.environ.get("FAMS"):  # passes 4 to 6 re-run QR only (the block apply estimate changed after pass 3)
    cells = [c for c in cells if c[0] in os.environ["FAMS"].split(",")]

bins = {"before": "bench-tbl-before/target/release/tblbefore", "after": "bench-tbl/target/release/tbl"}
for r in [int(x) for x in sys.argv[1:]]:
    for f, n in cells:
        order = ["before", "after"] if r % 2 == 0 else ["after", "before"]
        if os.environ.get("VERS"):
            order = os.environ["VERS"].split(",")
        for v in order:
            out = f"raw/tbl-{v}-{f}-{n}-r{r}.csv"
            if os.path.exists(out):
                continue
            env = dict(os.environ, MAXWAIT="40")
            subprocess.run(["python3", "guarded.py", f"tbl-{v}-{f}-{n}-r{r}", out, bins[v], "tbl", f, str(n)], env=env)
