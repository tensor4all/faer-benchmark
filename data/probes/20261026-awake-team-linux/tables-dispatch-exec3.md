## Dispatch cost, pool of 8 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 | w=6 | w=8 |
| --- | --- | --- | --- | --- |
| team/hot | 0.48 | 0.62 | 0.79 | 0.96 |
| team/gap1ms | 0.81 | 0.98 | 1.09 | 1.21 |
| team/gap10ms | 0.80 | 1.00 | 1.11 | 1.27 |
| team/gap300ms | 74.43 | 76.54 | 84.03 | 89.86 |
| team/load10us-minus-10us | 0.57 | 0.70 | 0.86 | 1.02 |
| team/fork-hot | 0.50 | 0.66 | 0.89 | 1.04 |
| plain/outside-hot | 4.65 | 5.44 | 5.79 | 7.36 |
| plain/outside-gap1ms | 28.81 | 30.24 | 30.25 | 24.75 |
| plain/outside-gap10ms | 102.88 | 104.56 | 111.55 | 117.36 |
| plain/outside-load10us-minus-10us | 9.65 | 9.62 | 8.64 | 6.86 |
| external/outside-hot | 4.75 | 4.68 | 4.45 | 4.38 |
| external/outside-gap1ms | 24.34 | 28.85 | 28.98 | 28.43 |
| plain/in-pool | 0.41 | 1.03 | 1.50 | 2.06 |
| plain/in-pool-load10us-minus-10us | 2.99 | 3.55 | 3.50 | 3.05 |

## Dispatch cost, pool of 4 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 |
| --- | --- | --- |
| team/hot | 0.48 | 0.59 |
| team/gap1ms | 0.84 | 0.96 |
| team/gap10ms | 0.80 | 0.99 |
| team/gap300ms | 72.96 | 76.59 |
| team/load10us-minus-10us | 0.57 | 0.71 |
| team/fork-hot | 0.50 | 0.66 |
| plain/outside-hot | 3.95 | 4.30 |
| plain/outside-gap1ms | 28.87 | 32.76 |
| plain/outside-gap10ms | 99.46 | 113.78 |
| plain/outside-load10us-minus-10us | 6.42 | 5.93 |
| external/outside-hot | 2.91 | 2.90 |
| external/outside-gap1ms | 28.76 | 28.67 |
| plain/in-pool | 0.17 | 0.52 |
| plain/in-pool-load10us-minus-10us | 1.44 | 1.65 |

## Linux row of `DispatchCosts` (anchors 2, 4, 6 from the pool-of-8 processes; 10 us share rows)

```rust
// Measured on <host> (AMD Ryzen AI 9 HX 470), 8 threads on cores 4-11, boost off, from the back to back sections whose
// shares carry 10 us of work (faer-benchmark data/probes/20261026-awake-team-linux), us at widths 2, 4, 6:
// team: 0.6, 0.7, 0.9
// in_pool: 3.0, 3.5, 3.5
// outside: 9.6, 9.6, 8.6
pub fn linux_x86() -> Self {
    DispatchCosts {
        team: WidthCosts::new([us_f(0.6), us_f(0.7), us_f(0.9)]),
        in_pool: WidthCosts::new([us_f(3.0), us_f(3.5), us_f(3.5)]),
        outside: WidthCosts::new([us_f(9.6), us_f(9.6), us_f(8.6)]),
    }
}
```

Width 8 against the model's proportional extrapolation above the last anchor (`cost(6) * 8 / 6`):

| kind | measured w=8 us | model us | ratio |
| --- | --- | --- | --- |
| team | 1.02 | 1.14 | 0.89 |
| in_pool | 3.05 | 4.67 | 0.65 |
| outside | 6.86 | 11.52 | 0.60 |

M5 row for comparison (`DispatchCosts::apple_m5`): team 3.0, 2.3, 1.4; in pool 6.0, 11, 5.5; outside 14, 18, 19.

## Wake latency after a park (`wake_probe`; microseconds, median over processes; parked = 12 ms pause with a 2 ms idle spin)

| pool | width | variant | state | total | slowest share start | late > 1 ms | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | 2 | plain Exec::fork | idle | 95.4 | 84.7 | 0% | 112.6 |
| 4 | 2 | team qos=builder-default | parked | 72.0 | 71.1 | 0% | 102.0 |
| 4 | 2 | team qos=builder-default | spinning | 0.6 | 0.4 | 0% | 1.2 |
| 4 | 4 | plain Exec::fork | idle | 113.4 | 92.9 | 0% | 119.8 |
| 4 | 4 | team qos=builder-default | parked | 75.7 | 74.8 | 0% | 674.9 |
| 4 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 2.2 |
| 8 | 2 | plain Exec::fork | idle | 96.7 | 85.9 | 0% | 114.3 |
| 8 | 2 | team qos=builder-default | parked | 74.2 | 73.3 | 0% | 95.0 |
| 8 | 2 | team qos=builder-default | spinning | 0.6 | 0.5 | 0% | 15.1 |
| 8 | 4 | plain Exec::fork | idle | 104.5 | 93.6 | 0% | 129.7 |
| 8 | 4 | team qos=builder-default | parked | 77.1 | 76.1 | 0% | 99.3 |
| 8 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 1.3 |
| 8 | 8 | plain Exec::fork | idle | 118.2 | 104.4 | 0% | 145.8 |
| 8 | 8 | team qos=builder-default | parked | 89.5 | 88.6 | 0% | 424.4 |
| 8 | 8 | team qos=builder-default | spinning | 1.1 | 0.9 | 0% | 19.3 |

## Idle spin trace `idle-trace-T4.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 4, idle_spin 200 ms; members m1..m3 (the pool has 4 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 3.97  | m0: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.30  | m0: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0%
C 2000 sections back to back       wall    41.4 ms  cpu/wall 3.96  | m0: spin   2% park   0% run  98% m2: spin   2% park   0% run  98% m3: spin   2% park   0% run  98%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.18  | m0: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.37  | m0: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0%
```

## Idle spin trace `idle-trace-T8.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 8, idle_spin 200 ms; members m1..m7 (the pool has 8 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.70  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0% m4: spin  10% park  90% run   0% m5: spin  10% park  90% run   0% m6: spin  10% park  90% run   0%
C 2000 sections back to back       wall    41.9 ms  cpu/wall 7.90  | m0: spin   3% park   0% run  97% m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97% m3: spin   3% park   0% run  97% m4: spin   3% park   0% run  97% m5: spin   3% park   0% run  97% m6: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.41  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0% m4: spin   6% park  94% run   0% m5: spin   6% park  94% run   0% m6: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.1 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m5: spin 100% park   0% run   0% m6: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.86  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0% m4: spin  12% park  88% run   0% m5: spin  12% park  88% run   0% m6: spin  12% park  88% run   0%
```

