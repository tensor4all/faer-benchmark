# Upstream-regression triage (diagnostic, not adoption)

Question: are the LU/solve and Householder gaps vs upstream reproducible, and did the native GEMM flop floor introduce any LU/solve effects through shared subproducts?

Predeclared slice, before execution:
- Existing release fbench binaries at 0627828d965b (before native GEMM floor) and 2240b076a030 (merged floor). These measured source trees differ in GEMM and its test only; verify hashes/diff before interpreting.
- LU/solve c64 n256, budgets 1/4/8; Householder apply f64 n64 budgets 1/4/8 and 1024x64/4096x256 at 8. C/F order and both Householder forms emitted by the harness.
- Rows faer-fork,faer-upstream,lapack-mkl, 3 process starts with full row rotations, median of 5, 250 ms priming, verify before timing.
- Use existing pinned.sh, idle guard 3 s and 5% maximum busy with 8 admissions. Measured CPU sets read from the zen5-cpu profile and confined to one L3; observer on the other L3. No concurrent builds or measurements.
- This isolated diagnostic does not carry a recorder run.yaml, cannot replace adoption runs, and cannot prove unchanged unmeasured paths. Binary SHA256, effective thread census (including explicit 1T), source revisions and output are retained here. No mechanism is inferred from unchanged code alone.
