## x86_64 GEMM path: which threads run the product (`fbench diag-gemm`)

Per row and size: `participants` = distinct threads that took a share of 200 probe fan-outs through the row's own entry point (`spindle::for_each_raw` inside `with_lock` for held and upstream; Rayon `par_iter` for hot and free; `Team::run` for team, plus the leader); `busy` = of those, busy more than half of the wall time during the GEMM loop; `cpu participants / other` = on-CPU ms of the probed threads against all other threads of the process (other pool threads, e.g. the idle Rayon pool under the team row). A row whose work runs where its probe says has `cpu other` near 0; for lu/qr_factor/cholesky under the team row a non-zero `cpu other` / `busy other threads` is `private-gemm-x86` threading through spindle outside the team (`par.degree()` of a team token).

| process | row | op+n | calls | per call ms | participants | busy | cpu participants ms | cpu other ms | busy other threads | team counters |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| diag-gemm-T4-p1 | faer-fork | gemm512 | 1364 | 2.1998 | 4 | 4 | 11998.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | gemm1024 | 172 | 17.5182 | 4 | 4 | 12051.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu512 | 956 | 3.1402 | 4 | 4 | 12006.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | lu1024 | 212 | 14.2088 | 4 | 4 | 12047.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor512 | 826 | 3.6320 | 4 | 4 | 11999.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | qr_factor1024 | 152 | 19.7475 | 4 | 4 | 12006.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky512 | 3014 | 0.9955 | 4 | 4 | 12003.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork | cholesky1024 | 593 | 5.0603 | 4 | 4 | 12002.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | gemm512 | 1368 | 2.1944 | 4 | 4 | 12006.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | gemm1024 | 172 | 17.4885 | 4 | 4 | 12030.1 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | lu512 | 1028 | 2.9197 | 4 | 4 | 11996.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | lu1024 | 224 | 13.4265 | 4 | 4 | 12018.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | qr_factor512 | 675 | 4.4469 | 4 | 4 | 11996.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | qr_factor1024 | 142 | 21.1690 | 4 | 4 | 12012.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | cholesky512 | 2957 | 1.0148 | 4 | 4 | 11989.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-upstream | cholesky1024 | 613 | 4.8965 | 4 | 4 | 12004.0 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm512 | 1360 | 2.2064 | 4 | 4 | 11980.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | gemm1024 | 171 | 17.5549 | 4 | 4 | 12003.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu512 | 1021 | 2.9394 | 4 | 4 | 11978.9 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | lu1024 | 228 | 13.1686 | 4 | 4 | 11982.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor512 | 825 | 3.6403 | 4 | 4 | 12010.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | qr_factor1024 | 153 | 19.6121 | 4 | 4 | 11955.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky512 | 3271 | 0.9174 | 4 | 4 | 11922.2 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-hot | cholesky1024 | 660 | 4.5494 | 4 | 4 | 11960.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm512 | 1354 | 2.2170 | 5 | 4 | 11979.3 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | gemm1024 | 171 | 17.5586 | 5 | 4 | 11999.8 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu512 | 959 | 3.1306 | 5 | 1 | 6031.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | lu1024 | 218 | 13.8155 | 5 | 4 | 7988.5 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor512 | 775 | 3.8741 | 5 | 1 | 7351.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | qr_factor1024 | 146 | 20.5664 | 5 | 4 | 8967.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky512 | 2768 | 1.0841 | 5 | 4 | 8892.4 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-free | cholesky1024 | 605 | 4.9651 | 5 | 4 | 10235.7 | 0.0 | 0 |  |
| diag-gemm-T4-p1 | faer-fork-team | gemm512 | 1368 | 2.1936 | 4 | 4 | 12009.8 | 0.2 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[4:1368] split[] |
| diag-gemm-T4-p1 | faer-fork-team | gemm1024 | 172 | 17.5159 | 4 | 4 | 12050.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[4:344] split[] |
| diag-gemm-T4-p1 | faer-fork-team | lu512 | 1030 | 2.9134 | 4 | 4 | 12002.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=103000 gemm_one_tile=0 run[4:10300] split[2:8240 4:2060] |
| diag-gemm-T4-p1 | faer-fork-team | lu1024 | 235 | 12.7829 | 4 | 4 | 12015.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=47940 gemm_one_tile=0 run[4:7050] split[2:6580 4:1410] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor512 | 839 | 3.5773 | 4 | 4 | 12002.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=375033 gemm_one_tile=0 run[] split[2:16780 4:17619] |
| diag-gemm-T4-p1 | faer-fork-team | qr_factor1024 | 156 | 19.2593 | 4 | 4 | 12014.9 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=164892 gemm_one_tile=0 run[2:1248] split[2:14976 4:11856] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky512 | 3124 | 0.9604 | 4 | 4 | 11998.3 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=181192 gemm_one_tile=0 run[4:9372] split[2:21868] |
| diag-gemm-T4-p1 | faer-fork-team | cholesky1024 | 628 | 4.7797 | 4 | 4 | 12006.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=46472 gemm_one_tile=0 run[4:4396] split[2:11932] |
| diag-gemm-T8-p1 | faer-fork | gemm512 | 2540 | 1.1811 | 8 | 8 | 23998.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | gemm1024 | 335 | 8.9734 | 8 | 8 | 24047.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu512 | 1002 | 2.9967 | 8 | 8 | 24022.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | lu1024 | 262 | 11.4881 | 8 | 8 | 24079.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor512 | 1031 | 2.9104 | 8 | 8 | 24006.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | qr_factor1024 | 222 | 13.5479 | 8 | 8 | 24063.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky512 | 3375 | 0.8890 | 8 | 8 | 24006.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork | cholesky1024 | 856 | 3.5056 | 8 | 8 | 24006.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | gemm512 | 2551 | 1.1764 | 8 | 8 | 24007.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | gemm1024 | 334 | 8.9955 | 8 | 8 | 24038.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | lu512 | 1107 | 2.7122 | 8 | 8 | 24018.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | lu1024 | 276 | 10.8700 | 8 | 8 | 23990.9 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | qr_factor512 | 625 | 4.8040 | 8 | 8 | 23983.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | qr_factor1024 | 157 | 19.1576 | 8 | 8 | 24015.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | cholesky512 | 3252 | 0.9226 | 8 | 8 | 23993.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-upstream | cholesky1024 | 829 | 3.6196 | 8 | 8 | 23994.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm512 | 2554 | 1.1749 | 8 | 8 | 23909.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | gemm1024 | 333 | 9.0265 | 8 | 8 | 24018.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu512 | 1039 | 2.8880 | 8 | 8 | 23895.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | lu1024 | 276 | 10.8880 | 8 | 8 | 23933.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor512 | 1006 | 2.9828 | 8 | 8 | 24004.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | qr_factor1024 | 219 | 13.7136 | 8 | 8 | 23983.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky512 | 3321 | 0.9036 | 8 | 8 | 23691.1 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-hot | cholesky1024 | 912 | 3.2910 | 8 | 8 | 23766.5 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm512 | 2549 | 1.1773 | 9 | 8 | 23907.4 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | gemm1024 | 332 | 9.0463 | 9 | 8 | 23981.7 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu512 | 941 | 3.1884 | 9 | 1 | 8285.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | lu1024 | 261 | 11.5201 | 9 | 1 | 11496.8 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor512 | 934 | 3.2128 | 9 | 1 | 10853.3 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | qr_factor1024 | 206 | 14.5963 | 9 | 8 | 14213.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky512 | 3081 | 0.9737 | 9 | 8 | 15931.2 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-free | cholesky1024 | 829 | 3.6200 | 9 | 8 | 17928.0 | 0.0 | 0 |  |
| diag-gemm-T8-p1 | faer-fork-team | gemm512 | 2536 | 1.1830 | 8 | 8 | 24015.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:2536] split[] |
| diag-gemm-T8-p1 | faer-fork-team | gemm1024 | 334 | 8.9962 | 8 | 8 | 24038.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:668] split[] |
| diag-gemm-T8-p1 | faer-fork-team | lu512 | 1044 | 2.8750 | 8 | 8 | 24007.3 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=105444 gemm_one_tile=0 run[8:11484] split[2:8352 8:2088] |
| diag-gemm-T8-p1 | faer-fork-team | lu1024 | 290 | 10.3766 | 8 | 8 | 24075.3 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=124410 gemm_one_tile=0 run[8:8990] split[2:12760 8:1740] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor512 | 1038 | 2.8925 | 8 | 8 | 24015.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=804450 gemm_one_tile=0 run[] split[2:22836 8:24912] |
| diag-gemm-T8-p1 | faer-fork-team | qr_factor1024 | 226 | 13.3297 | 8 | 8 | 24101.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=342616 gemm_one_tile=0 run[4:3616] split[2:23052 4:4520 8:16272] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky512 | 3184 | 0.9424 | 8 | 8 | 24007.4 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=362976 gemm_one_tile=0 run[8:9552] split[2:35024] |
| diag-gemm-T8-p1 | faer-fork-team | cholesky1024 | 914 | 3.2830 | 8 | 8 | 24007.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=170004 gemm_one_tile=0 run[8:6398] split[2:35646] |
| diag-gemm-T8-p2 | faer-fork-hot | gemm512 | 2572 | 1.1667 | 8 | 8 | 23907.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | gemm1024 | 334 | 9.0031 | 8 | 8 | 24033.6 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu512 | 1033 | 2.9048 | 8 | 8 | 23901.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | lu1024 | 277 | 10.8514 | 8 | 8 | 23946.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor512 | 1005 | 2.9858 | 8 | 8 | 24005.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | qr_factor1024 | 219 | 13.7108 | 8 | 8 | 23974.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky512 | 3303 | 0.9084 | 8 | 8 | 23690.6 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-hot | cholesky1024 | 912 | 3.2896 | 8 | 8 | 23771.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm512 | 2535 | 1.1836 | 9 | 8 | 23871.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | gemm1024 | 333 | 9.0250 | 9 | 8 | 24006.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu512 | 987 | 3.0413 | 9 | 1 | 8322.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | lu1024 | 262 | 11.4752 | 9 | 1 | 11454.4 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor512 | 957 | 3.1360 | 9 | 1 | 10892.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | qr_factor1024 | 206 | 14.5854 | 9 | 8 | 14234.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky512 | 3085 | 0.9725 | 9 | 8 | 15956.7 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-free | cholesky1024 | 832 | 3.6075 | 9 | 8 | 17995.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork-team | gemm512 | 2540 | 1.1812 | 8 | 8 | 24022.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:2540] split[] |
| diag-gemm-T8-p2 | faer-fork-team | gemm1024 | 334 | 8.9987 | 8 | 8 | 24047.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=0 gemm_one_tile=0 run[8:668] split[] |
| diag-gemm-T8-p2 | faer-fork-team | lu512 | 1036 | 2.8966 | 8 | 8 | 24006.5 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=104636 gemm_one_tile=0 run[8:11396] split[2:8288 8:2072] |
| diag-gemm-T8-p2 | faer-fork-team | lu1024 | 291 | 10.3263 | 8 | 8 | 24040.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=124839 gemm_one_tile=0 run[8:9021] split[2:12804 8:1746] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor512 | 1038 | 2.8927 | 8 | 8 | 24014.0 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=804450 gemm_one_tile=0 run[] split[2:22836 8:24912] |
| diag-gemm-T8-p2 | faer-fork-team | qr_factor1024 | 226 | 13.3284 | 8 | 8 | 24095.1 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=342616 gemm_one_tile=0 run[4:3616] split[2:23052 4:4520 8:16272] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky512 | 3446 | 0.8706 | 8 | 8 | 23998.5 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=392844 gemm_one_tile=0 run[8:10338] split[2:37906] |
| diag-gemm-T8-p2 | faer-fork-team | cholesky1024 | 914 | 3.2849 | 8 | 8 | 24015.2 | 0.0 | 0 | gemm_tiled=0 gemm_below_floor=170004 gemm_one_tile=0 run[8:6398] split[2:35646] |
| diag-gemm-T8-p2 | faer-fork | gemm512 | 2539 | 1.1816 | 8 | 8 | 24006.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | gemm1024 | 334 | 8.9950 | 8 | 8 | 24029.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu512 | 978 | 3.0699 | 8 | 8 | 24015.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | lu1024 | 259 | 11.5851 | 8 | 8 | 24006.0 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor512 | 1011 | 2.9684 | 8 | 8 | 24006.9 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | qr_factor1024 | 219 | 13.7308 | 8 | 8 | 24054.2 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky512 | 3356 | 0.8941 | 8 | 8 | 23999.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-fork | cholesky1024 | 850 | 3.5315 | 8 | 8 | 24014.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | gemm512 | 2542 | 1.1802 | 8 | 8 | 24006.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | gemm1024 | 334 | 8.9876 | 8 | 8 | 24012.3 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | lu512 | 1050 | 2.8595 | 8 | 8 | 24006.1 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | lu1024 | 287 | 10.4812 | 8 | 8 | 24050.7 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | qr_factor512 | 621 | 4.8337 | 8 | 8 | 23986.6 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | qr_factor1024 | 156 | 19.2329 | 8 | 8 | 23963.8 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | cholesky512 | 3223 | 0.9311 | 8 | 8 | 23998.5 | 0.0 | 0 |  |
| diag-gemm-T8-p2 | faer-upstream | cholesky1024 | 877 | 3.4225 | 8 | 8 | 24004.2 | 0.0 | 0 |  |
