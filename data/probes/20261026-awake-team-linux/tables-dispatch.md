## Dispatch cost, pool of 8 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 | w=6 | w=8 |
| --- | --- | --- | --- | --- |
| team/hot | 1.60 | 1.45 | 1.32 | 1.14 |
| team/gap1ms | 4.85 | 3.74 | 2.36 | 1.27 |
| team/gap10ms | 5.91 | 4.46 | 2.96 | 1.27 |
| team/gap300ms | 82.44 | 83.64 | 83.03 | 84.12 |
| team/load10us-minus-10us | 2.83 | 2.23 | 1.66 | 1.11 |
| team/fork-hot | 1.63 | 1.50 | 1.44 | 1.27 |
| plain/outside-hot | 4.70 | 5.50 | 5.83 | 6.90 |
| plain/outside-gap1ms | 29.46 | 30.36 | 31.52 | 33.96 |
| plain/outside-gap10ms | 102.78 | 107.61 | 112.75 | 119.93 |
| plain/outside-load10us-minus-10us | 9.49 | 10.13 | 8.76 | 6.70 |
| external/outside-hot | 4.49 | 4.79 | 4.52 | 4.41 |
| external/outside-gap1ms | 29.16 | 29.05 | 24.25 | 29.20 |
| plain/in-pool | 0.44 | 1.06 | 1.51 | 2.07 |
| plain/in-pool-load10us-minus-10us | 3.08 | 3.58 | 3.52 | 3.03 |

## Dispatch cost, pool of 4 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 |
| --- | --- | --- |
| team/hot | 0.80 | 0.65 |
| team/gap1ms | 2.05 | 1.00 |
| team/gap10ms | 2.81 | 1.03 |
| team/gap300ms | 74.54 | 74.60 |
| team/load10us-minus-10us | 1.43 | 0.74 |
| team/fork-hot | 0.85 | 0.72 |
| plain/outside-hot | 3.99 | 4.37 |
| plain/outside-gap1ms | 28.88 | 31.15 |
| plain/outside-gap10ms | 99.64 | 111.32 |
| plain/outside-load10us-minus-10us | 6.36 | 5.87 |
| external/outside-hot | 2.95 | 2.94 |
| external/outside-gap1ms | 28.91 | 28.30 |
| plain/in-pool | 0.17 | 0.55 |
| plain/in-pool-load10us-minus-10us | 1.46 | 1.61 |

## Linux row of `DispatchCosts` (anchors 2, 4, 6 from the pool-of-8 processes; 10 us share rows)

```rust
// Measured on <host> (AMD Ryzen AI 9 HX 470), 8 threads on cores 4-11, boost off, from the back to back sections whose
// shares carry 10 us of work (faer-benchmark data/probes/20261026-awake-team-linux), us at widths 2, 4, 6:
// team: 2.8, 2.2, 1.7
// in_pool: 3.1, 3.6, 3.5
// outside: 9.5, 10.1, 8.8
pub fn linux_x86() -> Self {
    DispatchCosts {
        team: WidthCosts::new([us_f(2.8), us_f(2.2), us_f(1.7)]),
        in_pool: WidthCosts::new([us_f(3.1), us_f(3.6), us_f(3.5)]),
        outside: WidthCosts::new([us_f(9.5), us_f(10.1), us_f(8.8)]),
    }
}
```

Width 8 against the model's proportional extrapolation above the last anchor (`cost(6) * 8 / 6`):

| kind | measured w=8 us | model us | ratio |
| --- | --- | --- | --- |
| team | 1.11 | 2.21 | 0.50 |
| in_pool | 3.03 | 4.69 | 0.65 |
| outside | 6.70 | 11.68 | 0.57 |

M5 row for comparison (`DispatchCosts::apple_m5`): team 3.0, 2.3, 1.4; in pool 6.0, 11, 5.5; outside 14, 18, 19.

## Wake latency after a park (`wake_probe`; microseconds, median over processes; parked = 12 ms pause with a 2 ms idle spin)

| pool | width | variant | state | total | slowest share start | late > 1 ms | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | 2 | plain Exec::fork | idle | 94.1 | 83.7 | 0% | 112.1 |
| 4 | 2 | team qos=builder-default | parked | 70.6 | 69.7 | 0% | 107.4 |
| 4 | 2 | team qos=builder-default | spinning | 0.7 | 0.5 | 0% | 2.2 |
| 4 | 4 | plain Exec::fork | idle | 111.7 | 91.6 | 0% | 144.3 |
| 4 | 4 | team qos=builder-default | parked | 72.3 | 71.3 | 0% | 538.4 |
| 4 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 20.5 |
| 8 | 2 | plain Exec::fork | idle | 80.7 | 67.5 | 0% | 114.1 |
| 8 | 2 | team qos=builder-default | parked | 63.4 | 62.7 | 0% | 98.3 |
| 8 | 2 | team qos=builder-default | spinning | 0.7 | 0.5 | 0% | 8.2 |
| 8 | 4 | plain Exec::fork | idle | 103.1 | 92.0 | 0% | 136.6 |
| 8 | 4 | team qos=builder-default | parked | 72.7 | 71.8 | 0% | 117.7 |
| 8 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 7.8 |
| 8 | 8 | plain Exec::fork | idle | 116.8 | 103.2 | 0% | 180.0 |
| 8 | 8 | team qos=builder-default | parked | 83.0 | 82.2 | 0% | 108.8 |
| 8 | 8 | team qos=builder-default | spinning | 1.2 | 1.0 | 0% | 21.5 |

## Idle spin trace `idle-trace-T4.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 4, idle_spin 200 ms; members m1..m3 (the pool has 4 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.30  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.1 ms  cpu/wall 3.93  | m0: spin   2% park   0% run  98% m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 4.01  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.18  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.37  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0%
```

## Idle spin trace `idle-trace-T8.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 8, idle_spin 200 ms; members m1..m7 (the pool has 8 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.70  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0% m4: spin  10% park  90% run   0% m5: spin  10% park  90% run   0% m6: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.1 ms  cpu/wall 7.91  | m0: spin   3% park   0% run  97% m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97% m3: spin   3% park   0% run  97% m4: spin   3% park   0% run  97% m5: spin   3% park   0% run  97% m6: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.41  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0% m4: spin   6% park  94% run   0% m5: spin   6% park  94% run   0% m6: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.86  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0% m4: spin  12% park  88% run   0% m5: spin  12% park  88% run   0% m6: spin  12% park  88% run   0%
```

