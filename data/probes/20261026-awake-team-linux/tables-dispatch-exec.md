## Dispatch cost, pool of 8 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 | w=6 | w=8 |
| --- | --- | --- | --- | --- |
| team/hot | 1.62 | 1.45 | 1.33 | 1.14 |
| team/gap1ms | 5.04 | 3.84 | 2.39 | 1.29 |
| team/gap10ms | 6.22 | 4.65 | 3.06 | 1.30 |
| team/gap300ms | 84.54 | 82.75 | 84.19 | 84.00 |
| team/load10us-minus-10us | 2.84 | 2.18 | 1.66 | 1.08 |
| team/fork-hot | 1.64 | 1.50 | 1.44 | 1.26 |
| plain/outside-hot | 4.62 | 5.45 | 5.82 | 7.50 |
| plain/outside-gap1ms | 29.25 | 30.51 | 31.32 | 31.79 |
| plain/outside-gap10ms | 100.08 | 107.90 | 108.02 | 118.77 |
| plain/outside-load10us-minus-10us | 9.51 | 10.12 | 8.73 | 6.67 |
| external/outside-hot | 4.53 | 4.73 | 4.57 | 4.48 |
| external/outside-gap1ms | 29.23 | 29.38 | 29.43 | 28.81 |
| plain/in-pool | 0.42 | 1.05 | 1.48 | 2.05 |
| plain/in-pool-load10us-minus-10us | 3.00 | 3.60 | 3.49 | 3.02 |

## Dispatch cost, pool of 4 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 |
| --- | --- | --- |
| team/hot | 0.80 | 0.65 |
| team/gap1ms | 2.16 | 0.98 |
| team/gap10ms | 2.75 | 1.00 |
| team/gap300ms | 74.34 | 74.23 |
| team/load10us-minus-10us | 1.45 | 0.74 |
| team/fork-hot | 0.85 | 0.72 |
| plain/outside-hot | 4.06 | 4.31 |
| plain/outside-gap1ms | 28.51 | 31.19 |
| plain/outside-gap10ms | 98.47 | 109.64 |
| plain/outside-load10us-minus-10us | 6.34 | 5.87 |
| external/outside-hot | 2.88 | 2.91 |
| external/outside-gap1ms | 28.55 | 28.53 |
| plain/in-pool | 0.17 | 0.53 |
| plain/in-pool-load10us-minus-10us | 1.45 | 1.61 |

## Linux row of `DispatchCosts` (anchors 2, 4, 6 from the pool-of-8 processes; 10 us share rows)

```rust
// Measured on <host> (AMD Ryzen AI 9 HX 470), 8 threads on cores 4-11, boost off, from the back to back sections whose
// shares carry 10 us of work (faer-benchmark data/probes/20261026-awake-team-linux), us at widths 2, 4, 6:
// team: 2.8, 2.2, 1.7
// in_pool: 3.0, 3.6, 3.5
// outside: 9.5, 10.1, 8.7
pub fn linux_x86() -> Self {
    DispatchCosts {
        team: WidthCosts::new([us_f(2.8), us_f(2.2), us_f(1.7)]),
        in_pool: WidthCosts::new([us_f(3.0), us_f(3.6), us_f(3.5)]),
        outside: WidthCosts::new([us_f(9.5), us_f(10.1), us_f(8.7)]),
    }
}
```

Width 8 against the model's proportional extrapolation above the last anchor (`cost(6) * 8 / 6`):

| kind | measured w=8 us | model us | ratio |
| --- | --- | --- | --- |
| team | 1.08 | 2.21 | 0.49 |
| in_pool | 3.02 | 4.65 | 0.65 |
| outside | 6.67 | 11.64 | 0.57 |

M5 row for comparison (`DispatchCosts::apple_m5`): team 3.0, 2.3, 1.4; in pool 6.0, 11, 5.5; outside 14, 18, 19.

## Wake latency after a park (`wake_probe`; microseconds, median over processes; parked = 12 ms pause with a 2 ms idle spin)

| pool | width | variant | state | total | slowest share start | late > 1 ms | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | 2 | plain Exec::fork | idle | 94.4 | 83.9 | 0% | 108.4 |
| 4 | 2 | team qos=builder-default | parked | 71.6 | 70.8 | 0% | 101.9 |
| 4 | 2 | team qos=builder-default | spinning | 0.7 | 0.5 | 0% | 24.8 |
| 4 | 4 | plain Exec::fork | idle | 113.9 | 94.1 | 0% | 142.8 |
| 4 | 4 | team qos=builder-default | parked | 73.4 | 72.6 | 0% | 102.6 |
| 4 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 22.2 |
| 8 | 2 | plain Exec::fork | idle | 94.4 | 84.0 | 0% | 130.6 |
| 8 | 2 | team qos=builder-default | parked | 71.5 | 70.6 | 0% | 86.9 |
| 8 | 2 | team qos=builder-default | spinning | 0.6 | 0.5 | 0% | 11.3 |
| 8 | 4 | plain Exec::fork | idle | 91.0 | 72.5 | 0% | 137.5 |
| 8 | 4 | team qos=builder-default | parked | 64.4 | 63.5 | 0% | 102.3 |
| 8 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 1.8 |
| 8 | 8 | plain Exec::fork | idle | 113.8 | 101.2 | 0% | 168.8 |
| 8 | 8 | team qos=builder-default | parked | 63.1 | 62.4 | 0% | 97.6 |
| 8 | 8 | team qos=builder-default | spinning | 1.2 | 1.0 | 0% | 19.0 |

## Idle spin trace `idle-trace-T4.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 4, idle_spin 200 ms; members m1..m3 (the pool has 4 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 4.00  | m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.30  | m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.1 ms  cpu/wall 4.00  | m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97% m3: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 4.00  | m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.18  | m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 4.00  | m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 4.00  | m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.37  | m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0%
```

## Idle spin trace `idle-trace-T8.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 8, idle_spin 200 ms; members m1..m7 (the pool has 8 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.70  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0% m4: spin  10% park  90% run   0% m5: spin  10% park  90% run   0% m6: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.3 ms  cpu/wall 7.97  | m0: spin   4% park   0% run  96% m1: spin   4% park   0% run  96% m2: spin   4% park   0% run  96% m3: spin   4% park   0% run  96% m4: spin   4% park   0% run  96% m5: spin   4% park   0% run  96% m6: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.42  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0% m4: spin   6% park  94% run   0% m5: spin   6% park  94% run   0% m6: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.87  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0% m4: spin  12% park  88% run   0% m5: spin  12% park  88% run   0% m6: spin  12% park  88% run   0%
```

