# Attempt 1 — aborted by the idle guard (preserved, not published)

This directory holds the complete artifacts of control attempt 1, run
2026-10-15T07:26:18Z–07:32:18Z from the production smoke2 binaries
(MKL `cce1442034a105ef6ad8c59d9c85964c7cdad9b50c515a89c28f6894d3c34751`).

Sequence: `verify-gemm-1t`, `verify-qr-factor-1t`, `run0-gemm-1t`,
`run0-qr-factor-1t`, `run1-gemm-1t`, `run1-qr-factor-1t`, `run2-gemm-1t` all
passed. `run2-qr-factor-1t` then exited 75 from the pinned protocol with:

```
pinned.sh: cpus=4 idle_window=3s max_busy=0.05 retries=1
pinned.sh: cpus 4 busy after run (attempt 1); discarding it
pinned.sh: no valid run on cpus 4
```

The measured result was therefore **discarded by the admission guard**, and the
driver aborted the package deliberately (`PINNED_RETRIES=1`, no retry). The
remaining 56 processes of the declared 64 never ran, so no control set exists
here and these CSVs must not be analysed as if they did.

Most likely contamination source, and the reason this is not a retry chosen for
favourable numbers: the operator polling loop that ran in the same 20 s cadence
during this attempt (one `python3` start per poll, plus the agent process
itself). Attempt 2 is executed with **no concurrent polling or other local
work**. Whether system timers (`sysstat-collect.timer` every 10 min,
`logrotate.timer`, `anacron.timer`, `fwupd-refresh.timer`; none of them were
firing at 07:32:00Z) also contribute remains unestablished.

Both attempts are archived; attempt 2 is not selected because its numbers look
better, and its own guard outcomes are recorded like these.
