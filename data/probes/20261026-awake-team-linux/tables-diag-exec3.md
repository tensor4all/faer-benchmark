## x86_64 GEMM path: which threads run the product (`fbench diag-gemm`)

Per row and size: `participants` = distinct threads that took a share of 200 probe fan-outs through the row's own entry point (`spindle::for_each_raw` inside `with_lock` for held and upstream; Rayon `par_iter` for hot and free; `Team::run` for team, plus the leader); `busy` = of those, busy more than half of the wall time during the GEMM loop; `cpu participants / other` = on-CPU ms of the probed threads against all other threads of the process (other pool threads, e.g. the idle Rayon pool under the team row). A row whose work runs where its probe says has `cpu other` near 0; for lu/qr_factor/cholesky under the team row a non-zero `cpu other` / `busy other threads` is `private-gemm-x86` threading through spindle outside the team (`par.degree()` of a team token).

| process | row | op+n | calls | per call ms | participants | busy | cpu participants ms | cpu other ms | busy other threads | team counters |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| diag-gemm-T4-p1 | faer-fork | gemm512 | 1363 | 2.2021 | 4 | 4 | 12002.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | gemm1024 | 172 | 17.5293 | 4 | 4 | 12058.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu512 | 983 | 3.0550 | 4 | 4 | 12010.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu1024 | 214 | 14.0644 | 4 | 4 | 12039.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor512 | 837 | 3.5867 | 4 | 4 | 12005.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor1024 | 154 | 19.5621 | 4 | 4 | 12046.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky512 | 3043 | 0.9859 | 4 | 4 | 11999.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky1024 | 602 | 4.9857 | 4 | 4 | 12006.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | gemm512 | 1365 | 2.1981 | 4 | 4 | 12002.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | gemm1024 | 171 | 17.5542 | 4 | 4 | 12006.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | lu512 | 972 | 3.0891 | 4 | 4 | 12001.6 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | lu1024 | 223 | 13.5041 | 4 | 4 | 12035.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | qr_factor512 | 663 | 4.5304 | 4 | 4 | 12011.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | qr_factor1024 | 141 | 21.3374 | 4 | 4 | 12020.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | cholesky512 | 2933 | 1.0230 | 4 | 4 | 11995.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | cholesky1024 | 611 | 4.9136 | 4 | 4 | 12005.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm512 | 1360 | 2.2070 | 4 | 4 | 11983.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm1024 | 171 | 17.5886 | 4 | 4 | 12022.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu512 | 983 | 3.0541 | 4 | 4 | 11980.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu1024 | 226 | 13.3271 | 4 | 4 | 12018.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor512 | 820 | 3.6620 | 4 | 4 | 12008.6 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor1024 | 153 | 19.6239 | 4 | 4 | 11959.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky512 | 3175 | 0.9451 | 4 | 4 | 11915.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky1024 | 637 | 4.7138 | 4 | 4 | 11957.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm512 | 1351 | 2.2207 | 5 | 4 | 11971.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm1024 | 171 | 17.5799 | 5 | 4 | 12014.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu512 | 962 | 3.1198 | 5 | 1 | 5996.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu1024 | 218 | 13.8189 | 5 | 4 | 7974.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor512 | 783 | 3.8325 | 5 | 1 | 7398.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor1024 | 147 | 20.4918 | 5 | 4 | 9002.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky512 | 2821 | 1.0635 | 5 | 4 | 8804.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky1024 | 600 | 5.0070 | 5 | 4 | 10223.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-team | gemm512 | 1362 | 2.2033 | 4 | 4 | 12009.8 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[4:1362] split[] |
| diag-gemm-T4-p1 | faer-fork-team | gemm1024 | 171 | 17.5456 | 4 | 4 | 12002.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[4:342] split[] |
| diag-gemm-T4-p1 | faer-fork-team | lu512 | 1085 | 2.7662 | 4 | 4 | 12006.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=107415 gemm_one_tile=0 run[2:5425 4:17360] split[2:8680 4:6510] |
| diag-gemm-T4-p1 | faer-fork-team | lu1024 | 245 | 12.2493 | 4 | 4 | 12003.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=48755 gemm_one_tile=0 run[2:2205 4:12740] split[2:6860 4:3430] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor512 | 827 | 3.6286 | 4 | 4 | 12002.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=372150 gemm_one_tile=0 run[2:3308] split[2:52928 4:42177] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor1024 | 159 | 18.9749 | 4 | 4 | 12066.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=132924 gemm_one_tile=0 run[2:8745] split[2:18126 4:34821] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky512 | 3169 | 0.9467 | 4 | 4 | 11998.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=164788 gemm_one_tile=0 run[2:6338 4:22183] split[2:22183] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky1024 | 642 | 4.6780 | 4 | 4 | 12014.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=41088 gemm_one_tile=0 run[2:1284 4:9630] split[2:12198] |
| diag-gemm-T8-p1 | faer-fork | gemm512 | 2641 | 1.1359 | 8 | 8 | 23998.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | gemm1024 | 334 | 8.9923 | 8 | 8 | 24022.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu512 | 1089 | 2.7551 | 8 | 8 | 23998.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu1024 | 275 | 10.9258 | 8 | 8 | 24031.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor512 | 1016 | 2.9542 | 8 | 8 | 24005.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor1024 | 222 | 13.5228 | 8 | 8 | 24023.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky512 | 3880 | 0.7733 | 8 | 8 | 24006.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky1024 | 879 | 3.4145 | 8 | 8 | 24006.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | gemm512 | 2545 | 1.1789 | 8 | 8 | 23998.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | gemm1024 | 334 | 8.9908 | 8 | 8 | 24021.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | lu512 | 1042 | 2.8794 | 8 | 8 | 23991.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | lu1024 | 281 | 10.6901 | 8 | 8 | 24017.6 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | qr_factor512 | 617 | 4.8657 | 8 | 8 | 23985.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | qr_factor1024 | 154 | 19.5470 | 8 | 8 | 24027.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | cholesky512 | 3258 | 0.9210 | 8 | 8 | 23996.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | cholesky1024 | 877 | 3.4226 | 8 | 8 | 24005.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm512 | 2614 | 1.1478 | 8 | 8 | 23922.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm1024 | 333 | 9.0196 | 8 | 8 | 24009.6 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu512 | 1084 | 2.7689 | 8 | 8 | 23902.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu1024 | 284 | 10.5840 | 8 | 8 | 23935.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor512 | 1011 | 2.9690 | 8 | 8 | 24012.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor1024 | 219 | 13.7450 | 8 | 8 | 24007.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky512 | 3459 | 0.8673 | 8 | 8 | 23651.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky1024 | 918 | 3.2693 | 8 | 8 | 23757.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm512 | 2582 | 1.1622 | 9 | 8 | 23874.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm1024 | 333 | 9.0360 | 9 | 8 | 24030.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu512 | 964 | 3.1135 | 9 | 1 | 7960.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu1024 | 263 | 11.4294 | 9 | 1 | 11317.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor512 | 968 | 3.1016 | 9 | 1 | 10968.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor1024 | 206 | 14.5888 | 9 | 8 | 14213.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky512 | 3158 | 0.9503 | 9 | 8 | 14871.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky1024 | 840 | 3.5753 | 9 | 8 | 17668.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-team | gemm512 | 2649 | 1.1326 | 8 | 8 | 24014.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:2649] split[] |
| diag-gemm-T8-p1 | faer-fork-team | gemm1024 | 334 | 8.9909 | 8 | 8 | 24028.7 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:668] split[] |
| diag-gemm-T8-p1 | faer-fork-team | lu512 | 1197 | 2.5069 | 8 | 8 | 24006.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=107730 gemm_one_tile=0 run[2:9576 4:4788 8:16758] split[2:9576 8:2394] |
| diag-gemm-T8-p1 | faer-fork-team | lu1024 | 309 | 9.7229 | 8 | 8 | 24037.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=125454 gemm_one_tile=0 run[2:4944 4:2472 8:14832] split[2:13596 8:1854] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor512 | 1040 | 2.8851 | 8 | 8 | 24006.8 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=652080 gemm_one_tile=0 run[2:1040 3:1040 4:2080] split[2:56160 4:8320 8:35360] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor1024 | 233 | 12.9248 | 8 | 8 | 24094.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=258863 gemm_one_tile=0 run[2:7456 3:1398 4:10485] split[2:26096 4:9320 6:6757 8:27960] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky512 | 4078 | 0.7357 | 8 | 8 | 24000.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=424112 gemm_one_tile=0 run[2:16312 4:8156 5:16312 8:12234] split[2:44858] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky1024 | 965 | 3.1106 | 8 | 8 | 24015.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=165980 gemm_one_tile=0 run[2:3860 4:1930 5:7720 8:6755] split[2:37635] |
| diag-gemm-T8-p2 | faer-fork-hot | gemm512 | 2613 | 1.1485 | 8 | 8 | 23907.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | gemm1024 | 333 | 9.0200 | 8 | 8 | 24000.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu512 | 1083 | 2.7719 | 8 | 8 | 23899.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu1024 | 284 | 10.5892 | 8 | 8 | 23931.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor512 | 1012 | 2.9655 | 8 | 8 | 24005.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor1024 | 219 | 13.7556 | 8 | 8 | 24037.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky512 | 3437 | 0.8729 | 8 | 8 | 23651.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky1024 | 920 | 3.2612 | 8 | 8 | 23760.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm512 | 2585 | 1.1608 | 9 | 8 | 23879.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm1024 | 332 | 9.0447 | 9 | 8 | 23980.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu512 | 997 | 3.0112 | 9 | 1 | 7994.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu1024 | 265 | 11.3408 | 9 | 1 | 11318.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor512 | 942 | 3.1848 | 9 | 1 | 10943.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor1024 | 206 | 14.5787 | 9 | 8 | 14226.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky512 | 2953 | 1.0161 | 9 | 6 | 14469.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky1024 | 832 | 3.6060 | 9 | 8 | 17682.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-team | gemm512 | 2640 | 1.1365 | 8 | 8 | 23997.7 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:2640] split[] |
| diag-gemm-T8-p2 | faer-fork-team | gemm1024 | 334 | 9.0021 | 8 | 8 | 24054.6 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:668] split[] |
| diag-gemm-T8-p2 | faer-fork-team | lu512 | 1144 | 2.6243 | 8 | 8 | 24021.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=102960 gemm_one_tile=0 run[2:9152 4:4576 8:16016] split[2:9152 8:2288] |
| diag-gemm-T8-p2 | faer-fork-team | lu1024 | 311 | 9.6575 | 8 | 8 | 24030.5 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=126266 gemm_one_tile=0 run[2:4976 4:2488 8:14928] split[2:13684 8:1866] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor512 | 1041 | 2.8824 | 8 | 8 | 24005.7 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=652707 gemm_one_tile=0 run[2:1041 3:1041 4:2082] split[2:56214 4:8328 8:35394] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor1024 | 233 | 12.9007 | 8 | 8 | 24046.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=258863 gemm_one_tile=0 run[2:7456 3:1398 4:10485] split[2:26096 4:9320 6:6757 8:27960] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky512 | 3742 | 0.8018 | 8 | 8 | 23998.3 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=389168 gemm_one_tile=0 run[2:14968 4:7484 5:14968 8:11226] split[2:41162] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky1024 | 948 | 3.1664 | 8 | 8 | 24014.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=163056 gemm_one_tile=0 run[2:3792 4:1896 5:7584 8:6636] split[2:36972] |
| diag-gemm-T8-p2 | faer-fork | gemm512 | 2640 | 1.1366 | 8 | 8 | 24005.7 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | gemm1024 | 333 | 9.0120 | 8 | 8 | 24006.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu512 | 1056 | 2.8417 | 8 | 8 | 24006.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu1024 | 276 | 10.8884 | 8 | 8 | 24037.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor512 | 1021 | 2.9411 | 8 | 8 | 24023.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor1024 | 221 | 13.6240 | 8 | 8 | 24086.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky512 | 3869 | 0.7756 | 8 | 8 | 24007.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky1024 | 880 | 3.4125 | 8 | 8 | 24022.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | gemm512 | 2544 | 1.1796 | 8 | 8 | 24007.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | gemm1024 | 334 | 9.0086 | 8 | 8 | 24069.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | lu512 | 1106 | 2.7134 | 8 | 8 | 23995.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | lu1024 | 282 | 10.6413 | 8 | 8 | 23992.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | qr_factor512 | 624 | 4.8096 | 8 | 8 | 23968.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | qr_factor1024 | 155 | 19.4810 | 8 | 8 | 24102.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | cholesky512 | 3220 | 0.9317 | 8 | 8 | 23985.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | cholesky1024 | 877 | 3.4214 | 8 | 8 | 23990.9 | 0.0 | 0 |  |
