# Fixed-binary upstream-only crossed diagnostic

This is a NEW diagnostic, not a third baseline/candidate adoption pair or a
replacement comparison policy. Question: do the failing unchanged-upstream
controls follow the linked binary rather than the chronological execution order?

Predeclared before execution:
- Fixed release binaries A=2240b076a030, B=a53774682edd, identities checked against
  their existing run.yaml SHA256. No rebuilding and no measured source changes.
- Only the `faer-upstream` row, Cholesky n32/64/96/128, f64+c64, C+F, budgets1/4.
  1T is the overhead baseline (Par::Seq, observed pool1);4T is a secondary check
  including the original failed c64 F128 control. No claim about unmeasured cells.
- Verify every selected grid before timing. Time original Op boundaries,
  prime250ms, median5, retaining all five samples. Each budget's process order:
  A B B A B A A B (two mirrored ABBA cycles, four processes per binary).
- Existing pinned.sh/whole-L3 idle guard,3s,max5%,8admissions. CPU sets from the
  recorded host profile; observer off measured L3. No concurrent builds/timing.
- Keep all raw records, guard failures, binary hashes, effective thread census,
  source identities, power observations and exact commands. Compare distributions
  by entire cell identity; no cell/sample is discarded for being inconvenient.
- Consistent binary-following shifts support a linked-binary effect, not a CPU
  or allocator mechanism by themselves. Mixed shifts remain unresolved. This
  diagnosis cannot approve the LU candidate or relax any adoption guard.

## Outcome and limitations

All4 verification grids and16 retained timing grids audit successfully, with
32 complete cells and4 process medians per binary/cell. 1T f64 n32 C B/A1.0779
versus c64 n32 C0.9571 supports a binary-associated effect, not a universal host
multiplier. Measured CPUs were4 (1T) and4-7 (4T), watched L3 CPUs4-11,16-23;
observer0-3,12-15. These sets were obtained from the recorded profile and sysfs.

**Guard rejection retained, samples lost:** `process0-A-4t.log` records an initial
post-run idle-guard rejection before its accepted second attempt. The legacy
pinned.sh overwrites the command's `--csv` on retry and deletes its temporary
stdout. That rejected first attempt's samples cannot be recovered. Do NOT claim
all attempted4T samples were retained or treat this diagnostic as complete
adoption evidence. No1T process or owned-copy probe reported a rejection. All
available logs and accepted samples remain, with this explicit limitation; no
favorable rerun was manually selected. Future diagnostic commands must retain
attempt-specific files or use a one-attempt pre/post guard with retained output.

Static inspection: `code_compare.py` retains raw disassembly and normalized
diffs. `reference_compare.py` resolves all RIP operands, reads actual numeric
constants, local-code targets, GOT initializers and external-object prefixes.
Numeric operands, the complete4352-byte pulp LD_ST table/544 relocations and
helper region0x4d514c–0x4d717b agree. Exact reference equality remains FALSE for
one reference per leaf: the Equator assertion vtable at0x53b880 contains code
pointers moved+16 (test and formatting closures). Those pointer differences are
retained, not normalized away as equal. This is bounded static evidence, not a
proof of whole-program equivalence or isolation of instruction alignment.

Disassembly is generated from the MIT-licensed faer crates at the recorded
revisions; see the accompanying upstream license. It is not new production code.
