#!/bin/zsh
export MAXWAIT=40
python3 guarded.py modes128-a9813bf raw/modes-128-a9813bf.csv bench/target/release/regions modes 128 --prime-ms 250
python3 guarded.py apply-a9813bf raw/apply-a9813bf.csv bench/target/release/regions apply 128 --prime-ms 250
python3 guarded.py trace128-a9813bf raw/trace-128-a9813bf.csv bench/target/release/regions trace 128
for r in 0 1 2; do
  python3 guarded.py qr-old9cd-$r raw/qr-old9cd-r$r.csv bench-old/target/release/regionsold qr 128 --prime-ms 250
  python3 guarded.py qr-new-$r raw/qr-new-r$r.csv bench/target/release/regions qr 128 --prime-ms 250
done
python3 run_tbl.py 4 5 6
