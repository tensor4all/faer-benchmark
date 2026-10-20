# Historical phase-claim audit (no remeasurement)

While the new native-budget/coverage PRE reviews run, correct misleading claims
in the original worklogs rather than treating them as established mechanisms.
The `.stdout` files are original tool-result payloads recovered from the main
session, not new benchmarks. `provenance.json` records original commands/times;
`audit.json` records hashes and arithmetic. No binary hashes, complete historical
Cargo graphs, observed pool census or missing guard records have been recovered.
Do not promote these best-of7 diagnostics to formal timing-v2 acceptance.

## Confirmed corrections

- The SVD baseline-labelled phase table actually used the QR candidate output.
  Original baseline512²/8T is bidiag34.1394/values48.0793/thin59.3615ms, remainder
  13.9400ms, not candidate34.3408/54.1986/59.1544/19.8578. One-thread values improve
  65.7368→63.0998, about4%, NOT11%. Both original outputs remain here.
- Standalone bidiag reuses buffers, while public SVD calls allocate outputs and
  scratch inside the clock. Subtraction includes those differences, not an exact
  isolated bidiagonal-SVD timer. QR rejection does not show D&C intermediate
  vector optimization is useless. Child two-row results in the storage are read in
  bidiag_svd.rs1177–1183/1243–1250; no blanket 'never read back' claim.
- QR's tuple is (apply_calls,apply_ns,upgrade_calls,upgrade_ns,panel_ns), not a panel
  call count. Raw512 output shows default1T7.941/4T4.933/8T5.294ms;8T Seq-apply
  override9.227ms, apply6.850 vsdefault3.190ms (threaded about2.15x faster).
  Counts496/255 mean upgrade/apply CALLS, not actual parallel regions. No argument
  histogram or synchronization census was recorded. `qr-instrumentation-current.diff`
  is the still-present diagnostic source snapshot, not a reconstructed binary.
- The rejected upgrade-floor guard still rejects its candidate, but untimed
  preparation/parked-worker wake-up is only a hypothesis. Same algorithmic path
  cannot prove identical generated code or exclude linked-binary layout effects.
- Rectangles16×4096×240 /4096×16×240 /64×64×4096 contain15.7–16.8M MACs,
  31.5–33.6M real FLOPs. The former text mistakenly called MACs FLOPs. Native
  private GEMM has no work floor; the existing budget was faer's, not the kernel's.
  A4.33x upstream timing shift cannot be dismissed as timer precision from duration
  alone. No control waiver, start trimming or retroactive adoption follows.

## Reference-LAPACK call-chain source check

Read stable3.12.1 source, not inferred vendor behavior:

- https://github.com/Reference-LAPACK/lapack/blob/v3.12.1/SRC/dbdsdc.f
- https://github.com/Reference-LAPACK/lapack/blob/v3.12.1/SRC/dlasdq.f
- https://github.com/Reference-LAPACK/lapack/blob/v3.12.1/SRC/dbdsqr.f

For the nontrivial no-vector branch: DBDSDC→DLASDQ→DBDSQR→DLASQ1; INFO2 allows
QR fallback. The previous prose omitted DBDSQR. Larger explicit/compact vector
subproblems use DLASD0/DLASDA respectively. This does not trace proprietary MKL.
No LAPACK implementation or tests are imported; source is cited as evidence
(BSD-3-Clause). Diagnostic counter patch is own work in the existing MIT fork.
All production code, source pins and timing criteria remain unchanged.
