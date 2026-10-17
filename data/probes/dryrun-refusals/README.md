# Dry-run artifacts that record a real gap the dry run found

`20261017T094038Z-dryrun-refusal/` is a `gemm-small` run recorded while the *observer* (the
recorder process) was pinned to CPU 7 and the measured cell ran on CPU 4 - the same L3 domain. The
recorder's observer check compared the observer's affinity with the measured CPUs and their SMT
siblings only, so it did not refuse; the idle guard watches the whole domain and would have rejected
any process start whose window caught that observer.

The check now refuses an observer inside any measured L3 domain, which is what
`faer-benchmark/docs/protocol-v2-baseline.md` always said. The run is kept here as the reproduction:
it proves the gap existed, and it is not evidence about any library revision.
