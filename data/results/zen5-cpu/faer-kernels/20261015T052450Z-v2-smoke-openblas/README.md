# Initial timing-v2 recorder software smoke: OpenBLAS

This is **not a new performance baseline or a validated priming policy**.
It exercised the production recorder -> numerical census -> three timed processes
-> v2 evidence validation -> descriptive report with `--no-publish`.

Selection: GEMM 4/8/16/32/64 cubed, f64, C/F, 1T on CPU4, batch1.
Settings intentionally reduced for software testing: 2 chronological calls,
3 engine rotations/process starts, 1ms wall-clock priming. All 90 timed rows and
180 samples were validated; all four sibling-aware before/after guards passed
on attempt1 (`PINNED_RETRIES=1`). No result page/index was published or altered.

Both vendors' smokes used the same clean fork/upstream paths/revisions and
harness/toolkit identities; `run.yaml`, `build-info.json`, and `binary-info.txt`
retain the exact provenance. No optimization candidate was measured. This initial
smoke precedes later POST-review installation/publication gate corrections;
its recorded source identities and raw observations are retained unchanged.
