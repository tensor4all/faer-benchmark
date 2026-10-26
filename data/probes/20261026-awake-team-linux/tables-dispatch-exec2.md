## Dispatch cost, pool of 8 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 | w=6 | w=8 |
| --- | --- | --- | --- | --- |
| team/hot | 0.46 | 0.61 | 0.80 | 0.98 |
| team/gap1ms | 0.82 | 0.99 | 1.09 | 1.26 |
| team/gap10ms | 0.85 | 1.03 | 1.13 | 1.33 |
| team/gap300ms | 72.80 | 77.03 | 84.51 | 89.81 |
| team/load10us-minus-10us | 0.57 | 0.70 | 0.87 | 0.98 |
| team/fork-hot | 0.52 | 0.66 | 0.92 | 1.05 |
| plain/outside-hot | 4.75 | 6.82 | 5.78 | 7.48 |
| plain/outside-gap1ms | 29.42 | 30.68 | 31.28 | 26.91 |
| plain/outside-gap10ms | 103.27 | 105.21 | 108.28 | 117.88 |
| plain/outside-load10us-minus-10us | 9.65 | 10.15 | 8.71 | 6.70 |
| external/outside-hot | 4.82 | 4.77 | 4.49 | 4.43 |
| external/outside-gap1ms | 28.49 | 23.95 | 29.30 | 29.07 |
| plain/in-pool | 0.42 | 1.05 | 1.47 | 2.05 |
| plain/in-pool-load10us-minus-10us | 3.00 | 3.57 | 3.50 | 3.05 |

## Dispatch cost, pool of 4 (us per section, median over 3 processes; `load10us-minus-10us` rows give every share 10 us of work and subtract it)

| kind | w=2 | w=4 |
| --- | --- | --- |
| team/hot | 0.48 | 0.62 |
| team/gap1ms | 0.82 | 0.95 |
| team/gap10ms | 0.79 | 0.97 |
| team/gap300ms | 72.25 | 76.28 |
| team/load10us-minus-10us | 0.56 | 0.69 |
| team/fork-hot | 0.48 | 0.68 |
| plain/outside-hot | 4.02 | 4.30 |
| plain/outside-gap1ms | 28.85 | 31.90 |
| plain/outside-gap10ms | 100.45 | 115.67 |
| plain/outside-load10us-minus-10us | 6.41 | 5.94 |
| external/outside-hot | 2.94 | 2.91 |
| external/outside-gap1ms | 28.79 | 28.81 |
| plain/in-pool | 0.17 | 0.52 |
| plain/in-pool-load10us-minus-10us | 1.45 | 1.63 |

## Linux row of `DispatchCosts` (anchors 2, 4, 6 from the pool-of-8 processes; 10 us share rows)

```rust
// Measured on <host> (AMD Ryzen AI 9 HX 470), 8 threads on cores 4-11, boost off, from the back to back sections whose
// shares carry 10 us of work (faer-benchmark data/probes/20261026-awake-team-linux), us at widths 2, 4, 6:
// team: 0.6, 0.7, 0.9
// in_pool: 3.0, 3.6, 3.5
// outside: 9.7, 10.1, 8.7
pub fn linux_x86() -> Self {
    DispatchCosts {
        team: WidthCosts::new([us_f(0.6), us_f(0.7), us_f(0.9)]),
        in_pool: WidthCosts::new([us_f(3.0), us_f(3.6), us_f(3.5)]),
        outside: WidthCosts::new([us_f(9.7), us_f(10.1), us_f(8.7)]),
    }
}
```

Width 8 against the model's proportional extrapolation above the last anchor (`cost(6) * 8 / 6`):

| kind | measured w=8 us | model us | ratio |
| --- | --- | --- | --- |
| team | 0.98 | 1.16 | 0.85 |
| in_pool | 3.05 | 4.66 | 0.65 |
| outside | 6.70 | 11.61 | 0.58 |

M5 row for comparison (`DispatchCosts::apple_m5`): team 3.0, 2.3, 1.4; in pool 6.0, 11, 5.5; outside 14, 18, 19.

## Wake latency after a park (`wake_probe`; microseconds, median over processes; parked = 12 ms pause with a 2 ms idle spin)

| pool | width | variant | state | total | slowest share start | late > 1 ms | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 4 | 2 | plain Exec::fork | idle | 94.7 | 84.2 | 0% | 125.5 |
| 4 | 2 | team qos=builder-default | parked | 71.7 | 70.8 | 0% | 101.9 |
| 4 | 2 | team qos=builder-default | spinning | 0.6 | 0.5 | 0% | 0.9 |
| 4 | 4 | plain Exec::fork | idle | 116.0 | 95.2 | 0% | 129.6 |
| 4 | 4 | team qos=builder-default | parked | 76.8 | 75.8 | 0% | 104.4 |
| 4 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 26.2 |
| 8 | 2 | plain Exec::fork | idle | 96.5 | 85.8 | 0% | 119.5 |
| 8 | 2 | team qos=builder-default | parked | 71.3 | 70.5 | 0% | 92.7 |
| 8 | 2 | team qos=builder-default | spinning | 0.6 | 0.5 | 0% | 25.2 |
| 8 | 4 | plain Exec::fork | idle | 102.7 | 91.8 | 0% | 116.0 |
| 8 | 4 | team qos=builder-default | parked | 76.2 | 75.3 | 0% | 78.6 |
| 8 | 4 | team qos=builder-default | spinning | 0.8 | 0.6 | 0% | 9.5 |
| 8 | 8 | plain Exec::fork | idle | 113.5 | 101.7 | 0% | 152.8 |
| 8 | 8 | team qos=builder-default | parked | 89.1 | 88.2 | 0% | 122.1 |
| 8 | 8 | team qos=builder-default | spinning | 1.1 | 0.9 | 0% | 20.8 |

## Idle spin trace `idle-trace-T4.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 4, idle_spin 200 ms; members m1..m3 (the pool has 4 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.30  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0%
C 2000 sections back to back       wall    41.4 ms  cpu/wall 3.98  | m0: spin   2% park   0% run  98% m1: spin   2% park   0% run  98% m2: spin   2% park   0% run  98%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 4.02  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.18  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.0 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 4.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.37  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0%
```

## Idle spin trace `idle-trace-T8.txt` (acceptance condition 3: members do not spin beyond the 200 ms idle spin)

```
team of 8, idle_spin 200 ms; members m1..m7 (the pool has 8 workers, one is unused)
A seq 120 ms (no section)          wall   120.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m6: spin 100% park   0% run   0% m7: spin 100% park   0% run   0%
B seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.70  | m0: spin  10% park  90% run   0% m1: spin  10% park  90% run   0% m2: spin  10% park  90% run   0% m3: spin  10% park  90% run   0% m4: spin  10% park  90% run   0% m6: spin  10% park  90% run   0% m7: spin  10% park  90% run   0%
C 2000 sections back to back       wall    42.0 ms  cpu/wall 7.98  | m0: spin   3% park   0% run  97% m1: spin   3% park   0% run  97% m2: spin   3% park   0% run  97% m3: spin   3% park   0% run  97% m4: spin   3% park   0% run  97% m6: spin   3% park   0% run  97% m7: spin   3% park   0% run  97%
D seq 150 ms after sections        wall   150.0 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m6: spin 100% park   0% run   0% m7: spin 100% park   0% run   0%
E seq 800 ms after D               wall   800.0 ms  cpu/wall 1.41  | m0: spin   6% park  94% run   0% m1: spin   6% park  94% run   0% m2: spin   6% park  94% run   0% m3: spin   6% park  94% run   0% m4: spin   6% park  94% run   0% m6: spin   6% park  94% run   0% m7: spin   6% park  94% run   0%
F 1 section, then seq 150 ms       wall   150.1 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m6: spin 100% park   0% run   0% m7: spin 100% park   0% run   0%
G 10 sections, 100 ms gaps         wall  1000.2 ms  cpu/wall 8.00  | m0: spin 100% park   0% run   0% m1: spin 100% park   0% run   0% m2: spin 100% park   0% run   0% m3: spin 100% park   0% run   0% m4: spin 100% park   0% run   0% m6: spin 100% park   0% run   0% m7: spin 100% park   0% run   0%
H seq 800 ms (no section)          wall   800.0 ms  cpu/wall 1.86  | m0: spin  12% park  88% run   0% m1: spin  12% park  88% run   0% m2: spin  12% park  88% run   0% m3: spin  12% park  88% run   0% m4: spin  12% park  88% run   0% m6: spin  12% park  88% run   0% m7: spin  12% park  88% run   0%
```

