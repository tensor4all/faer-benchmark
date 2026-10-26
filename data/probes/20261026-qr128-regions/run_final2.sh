#!/bin/zsh
export MAXWAIT=40
export VERS=after
python3 run_tbl.py 7 8
export VERS=before
FAMS=tinv,qr python3 run_tbl.py 7
python3 guarded.py modes128-final raw/modes-128-final.csv bench/target/release/regions modes 128 --prime-ms 250
