## x86_64 GEMM path: which threads run the product (`fbench diag-gemm`)

Per row and size: `participants` = distinct threads that took a share of 200 probe fan-outs through the row's own entry point (`spindle::for_each_raw` inside `with_lock` for held; Rayon `par_iter` for hot and free; `Team::run` for team, plus the leader); `busy` = of those, busy more than half of the wall time during the GEMM loop; `cpu participants / other` = on-CPU ms of the probed threads against all other threads of the process (other pool threads, e.g. the idle Rayon pool under the team row). A row whose work runs where its probe says has `cpu other` near 0; for lu/qr_factor/cholesky under the team row a non-zero `cpu other` / `busy other threads` is `private-gemm-x86` threading through spindle outside the team (`par.degree()` of a team token).

| process | row | op+n | calls | per call ms | participants | busy | cpu participants ms | cpu other ms | busy other threads | team counters |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| diag-gemm-T4-p1 | faer-fork | gemm512 | 1366 | 2.1976 | 4 | 4 | 12006.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | gemm1024 | 172 | 17.5304 | 4 | 4 | 12061.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu512 | 779 | 3.8514 | 4 | 4 | 12000.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu1024 | 174 | 17.2606 | 4 | 4 | 11388.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor512 | 736 | 4.0766 | 4 | 4 | 11998.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor1024 | 149 | 20.2014 | 4 | 4 | 12038.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky512 | 2289 | 1.3110 | 4 | 4 | 12003.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky1024 | 534 | 5.6254 | 4 | 4 | 12014.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm512 | 1361 | 2.2055 | 4 | 4 | 11989.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm1024 | 171 | 17.6090 | 4 | 4 | 12039.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu512 | 785 | 3.8244 | 4 | 4 | 11998.6 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu1024 | 177 | 17.0278 | 4 | 4 | 12040.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor512 | 736 | 4.0788 | 4 | 4 | 12005.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor1024 | 149 | 20.2134 | 4 | 4 | 12040.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky512 | 2348 | 1.2782 | 4 | 4 | 11944.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky1024 | 548 | 5.4812 | 4 | 4 | 11969.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm512 | 1355 | 2.2141 | 5 | 4 | 11984.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm1024 | 171 | 17.5939 | 5 | 4 | 12023.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu512 | 776 | 3.8685 | 5 | 1 | 4330.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu1024 | 172 | 17.4762 | 5 | 1 | 6053.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor512 | 710 | 4.2288 | 5 | 1 | 6555.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor1024 | 146 | 20.5744 | 5 | 4 | 8625.6 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky512 | 2079 | 1.4436 | 5 | 1 | 6041.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky1024 | 523 | 5.7368 | 5 | 4 | 8767.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-team | gemm512 | 1329 | 2.2584 | 4 | 4 | 12002.1 | 0.0 | 0 | gemm_tiled=1329 gemm_below_floor=0 gemm_one_tile=0 run[4:1329] split[] |
| diag-gemm-T4-p1 | faer-fork-team | gemm1024 | 163 | 18.4535 | 4 | 4 | 12030.9 | 0.0 | 0 | gemm_tiled=163 gemm_below_floor=0 gemm_one_tile=0 run[4:163] split[] |
| diag-gemm-T4-p1 | faer-fork-team | lu512 | 1009 | 2.9753 | 4 | 4 | 12007.2 | 0.0 | 0 | gemm_tiled=12108 gemm_below_floor=90810 gemm_one_tile=0 run[2:4036 4:8072] split[2:8072 4:2018] |
| diag-gemm-T4-p1 | faer-fork-team | lu1024 | 232 | 12.9528 | 4 | 4 | 12018.9 | 0.0 | 0 | gemm_tiled=8352 gemm_below_floor=44080 gemm_one_tile=0 run[2:1856 4:6496] split[2:6496 4:1392] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor512 | 726 | 4.1374 | 4 | 4 | 12013.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=310002 gemm_one_tile=0 run[] split[2:11616 4:13068] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor1024 | 147 | 20.4779 | 4 | 4 | 12041.9 | 0.0 | 0 | gemm_tiled=1764 gemm_below_floor=147735 gemm_one_tile=0 run[2:1764] split[2:12936 4:9702] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky512 | 1606 | 1.8682 | 4 | 3 | 9601.0 | 2383.1 | 4 | gemm_tiled=3212 gemm_below_floor=83512 gemm_one_tile=0 run[2:3212] split[2:11242] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky1024 | 323 | 9.2989 | 4 | 3 | 7441.5 | 4457.0 | 4 | gemm_tiled=646 gemm_below_floor=20672 gemm_one_tile=0 run[2:646] split[2:6137] |
| diag-gemm-T8-p1 | faer-fork | gemm512 | 2546 | 1.1788 | 8 | 8 | 24010.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | gemm1024 | 335 | 8.9792 | 8 | 8 | 24061.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu512 | 721 | 4.1643 | 8 | 8 | 14848.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu1024 | 186 | 16.1416 | 8 | 8 | 20984.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor512 | 829 | 3.6209 | 8 | 8 | 24012.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor1024 | 208 | 14.4402 | 8 | 8 | 24030.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky512 | 2214 | 1.3555 | 8 | 8 | 24005.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky1024 | 695 | 4.3192 | 8 | 8 | 24013.6 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm512 | 2563 | 1.1709 | 8 | 8 | 23909.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm1024 | 333 | 9.0296 | 8 | 8 | 24032.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu512 | 727 | 4.1282 | 8 | 8 | 23993.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu1024 | 186 | 16.2083 | 8 | 8 | 24078.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor512 | 847 | 3.5427 | 8 | 8 | 24005.6 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor1024 | 208 | 14.4696 | 8 | 8 | 24075.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky512 | 2456 | 1.2220 | 8 | 8 | 23745.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky1024 | 698 | 4.3031 | 8 | 8 | 23844.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm512 | 2547 | 1.1782 | 9 | 8 | 23908.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm1024 | 333 | 9.0339 | 9 | 8 | 24030.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu512 | 698 | 4.2989 | 9 | 1 | 3987.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu1024 | 188 | 16.0304 | 9 | 1 | 7038.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor512 | 796 | 3.7717 | 9 | 1 | 8343.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor1024 | 201 | 14.9348 | 9 | 1 | 12831.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky512 | 2203 | 1.3620 | 9 | 1 | 10072.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky1024 | 644 | 4.6627 | 9 | 2 | 13353.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-team | gemm512 | 2402 | 1.2493 | 8 | 8 | 24022.0 | 0.0 | 0 | gemm_tiled=2402 gemm_below_floor=0 gemm_one_tile=0 run[8:2402] split[] |
| diag-gemm-T8-p1 | faer-fork-team | gemm1024 | 296 | 10.1446 | 8 | 8 | 24022.8 | 0.0 | 0 | gemm_tiled=296 gemm_below_floor=0 gemm_one_tile=0 run[8:296] split[] |
| diag-gemm-T8-p1 | faer-fork-team | lu512 | 1046 | 2.8693 | 8 | 8 | 24012.3 | 0.0 | 0 | gemm_tiled=19874 gemm_below_floor=84726 gemm_one_tile=0 run[2:8368 4:4184 8:7322] split[2:8368] |
| diag-gemm-T8-p1 | faer-fork-team | lu1024 | 279 | 10.7529 | 8 | 8 | 23998.9 | 0.0 | 0 | gemm_tiled=13671 gemm_below_floor=110205 gemm_one_tile=0 run[2:4464 4:2232 8:6975] split[2:12276 8:558] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor512 | 849 | 3.5374 | 8 | 8 | 24029.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=551001 gemm_one_tile=0 run[] split[2:10188 8:11886] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor1024 | 203 | 14.7829 | 8 | 8 | 24006.9 | 0.0 | 0 | gemm_tiled=2436 gemm_below_floor=288260 gemm_one_tile=0 run[4:2436] split[2:15022 4:2030 8:8526] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky512 | 455 | 6.5950 | 8 | 7 | 15832.6 | 7347.6 | 8 | gemm_tiled=2730 gemm_below_floor=47320 gemm_one_tile=0 run[2:1820 4:910] split[2:5005] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky1024 | 265 | 11.4123 | 8 | 7 | 15015.8 | 8846.3 | 8 | gemm_tiled=1590 gemm_below_floor=45580 gemm_one_tile=0 run[2:1060 4:530] split[2:10335] |
| diag-gemm-T8-p2 | faer-fork | gemm512 | 2544 | 1.1794 | 8 | 8 | 23998.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | gemm1024 | 334 | 8.9858 | 8 | 8 | 24005.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu512 | 722 | 4.1579 | 8 | 8 | 14842.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu1024 | 186 | 16.1428 | 8 | 8 | 20974.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor512 | 831 | 3.6103 | 8 | 8 | 23998.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor1024 | 209 | 14.4110 | 8 | 8 | 24096.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky512 | 2227 | 1.3474 | 8 | 8 | 24006.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky1024 | 694 | 4.3238 | 8 | 8 | 24006.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | gemm512 | 2561 | 1.1717 | 8 | 8 | 23896.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | gemm1024 | 333 | 9.0167 | 8 | 8 | 24000.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu512 | 696 | 4.3162 | 8 | 8 | 24018.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu1024 | 186 | 16.1723 | 8 | 8 | 24012.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor512 | 822 | 3.6515 | 8 | 8 | 24006.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor1024 | 205 | 14.6568 | 8 | 8 | 24033.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky512 | 2459 | 1.2200 | 8 | 8 | 23719.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky1024 | 697 | 4.3066 | 8 | 8 | 23824.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm512 | 2550 | 1.1769 | 9 | 8 | 23900.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm1024 | 333 | 9.0249 | 9 | 8 | 24004.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu512 | 694 | 4.3275 | 9 | 1 | 3983.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu1024 | 188 | 16.0195 | 9 | 1 | 7043.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor512 | 792 | 3.7907 | 9 | 1 | 8310.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor1024 | 202 | 14.8983 | 9 | 1 | 12881.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky512 | 2239 | 1.3399 | 9 | 1 | 10071.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky1024 | 648 | 4.6327 | 9 | 2 | 13345.7 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-team | gemm512 | 2388 | 1.2564 | 8 | 8 | 24013.9 | 0.0 | 0 | gemm_tiled=2388 gemm_below_floor=0 gemm_one_tile=0 run[8:2388] split[] |
| diag-gemm-T8-p2 | faer-fork-team | gemm1024 | 300 | 10.0163 | 8 | 8 | 24038.8 | 0.0 | 0 | gemm_tiled=300 gemm_below_floor=0 gemm_one_tile=0 run[8:300] split[] |
| diag-gemm-T8-p2 | faer-fork-team | lu512 | 1045 | 2.8712 | 8 | 8 | 23998.3 | 0.0 | 0 | gemm_tiled=19855 gemm_below_floor=84645 gemm_one_tile=0 run[2:8360 4:4180 8:7315] split[2:8360] |
| diag-gemm-T8-p2 | faer-fork-team | lu1024 | 279 | 10.7857 | 8 | 8 | 24070.8 | 0.0 | 0 | gemm_tiled=13671 gemm_below_floor=110205 gemm_one_tile=0 run[2:4464 4:2232 8:6975] split[2:12276 8:558] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor512 | 857 | 3.5012 | 8 | 8 | 24006.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=556193 gemm_one_tile=0 run[] split[2:10284 8:11998] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor1024 | 204 | 14.7409 | 8 | 8 | 24062.6 | 0.0 | 0 | gemm_tiled=2448 gemm_below_floor=289680 gemm_one_tile=0 run[4:2448] split[2:15096 4:2040 8:8568] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky512 | 384 | 7.8275 | 8 | 7 | 16064.5 | 6963.3 | 8 | gemm_tiled=2304 gemm_below_floor=39936 gemm_one_tile=0 run[2:1536 4:768] split[2:4224] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky1024 | 96 | 31.2968 | 8 | 7 | 14809.2 | 8398.3 | 8 | gemm_tiled=576 gemm_below_floor=16512 gemm_one_tile=0 run[2:384 4:192] split[2:3744] |
