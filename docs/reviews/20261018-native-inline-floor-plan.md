# Two native entries, direct existing floor (new minimal candidate)

7cd372f is HELD: all4densebodiesdifferent afterfreshA/B, no timing/stage1/stage2,
no flag/alignment fiddling. Same-source control b7715c5/af8273f on df383e8 used
sameflags/builder/fullpaths/tool9daa, docs-onlywhole delta/equal all measured trees;
four dense bodies and FULL ELFsha256 both2decf425... exactlyequal. Onewarm/cold
control, not universalcompiler/cacheproof or7cdcause/performance. Allrefusals stay.

Distinct candidate: simplify needed policy at only TWO callers, not move helper /
add inline pragmas / change flags or linker alignment to fit assembly. Baseb7715c5
(correctness repair, noLU/copy/HHexperiments). Leave ENTIRE
faer/src/linalg/matmul/mod.rs BYTE-IDENTICALbaseline, not just densebody.
No common helper/function/module registration there. Two short expressions are
less production code than a4argumentgenerichelper+cfg+rootmodule edit for2users.
One getter/cutoff per entry; no new numericalalgorithm, unsafe, API, dependency,
scratch/allocation/threshold, machine/shape specialization or ancestorLUgate.

1. triangular.rs nativecall thread argument becomes direct existingfloor:
   dst.nrows().saturating_mul(dst.ncols()).saturating_mul(lhs.ncols())
      >= gemm::get_threading_threshold().div_ceil(if T::IS_REAL {1}else{4})
   ? par.degree() : 1 (Rust if expression).
   These are exactly the effective dimensions already passed to native kernel.
2. internal/mod.rs nativecall uses SAME expression with post-strict/unit-adjusted
   nrows/ncols/depth; all pointers/maps/conj/Accum/alpha/diagonal/indexvalidation/
   K0 handling untouched. Retain previousapproved relocation of pre-existing32³
   gate after native return into fallback, using ORIGINALdimensions/budget there.
3. Dense baseline2*threshold expression/source remains completely untouched;
   helper's MAC-normalization is used only at these2nativeentries. No claimdense
   extreme threshold arithmetic is hardened. Saturating product / ceil(1or4)
   identical to reviewed7fhelper policy incl0/MAX; callerreturnonly1orpar.degree().
   No new test-only production hooks to observe threads. Explain two expressions
   as deliberate minimal2users, not independently tunablepolicies/cutoffs.

Tests owned by implementation module, not dense root: retain old7f genuinef64/c64
scalar/finite/C/F/masks/Add/Replace/conj/parentguards/Seq/owned8 and mappeddiag
numerical cases, register under internal's tests. Existing b771 strict/K0 allmask/
allmap oracle retained +8T parameterization alreadyreviewed7f. Remove needfor
newroothelper-dependent decision test rather than add test-onlyAPI/macro/parser.
NUMERICtests exercise real changed native branches/defaultfloor below/above;
they do not observe private backendworkerutilization or prove actualchosenbudget.
Budget1orcallerdegree and safe cutoff arithmetic are source-inspected; no false
claim directproductionhelper unitcoverage. Old pure u128cutoff proof remains
historical evidence for exactsameformula, not a new production hook. No forced-
generic/f32/c32numerical coverage claim. Focusednumeric tests/full library/noRayon
sequential; no concurrentCargo sharedtarget; existingkachehealthy, no bypass.

PRE scope: is deleting this2-user abstraction and leaving denseowningmodule
unchanged a legitimate minimal implementation, not machine/shape/alignment tuning?
Check math/effective dimensions/callerbound/cfg/fallbackpreservation/testinglimits.
No code yet, finished diff POST required. Do not re-auditallunchangedsource.

After tests/POST, freezecode/tool/commands then freshfullcheckout A/B build exact
existingbuilder, sameharness. ALL4matchingdense sizes+normalizedbodies mustequal
beforetiming. Ifdifferent retainHOLD/noperf, no declaration/flag/position fiddling
or selective retry. Equality NOT RIP/reference/caller/wholeprogram/performance
proof. Unchanged648fullidentities/start×3starts/side controls/guards/allvariants/
skips/engines/rotations; onlyvalidstage1allows2688all14stage2, no LU thirdpair.
Standardmedian5/250ms/3s5%idle8boundedtries/fullrejects retained. Large square
2048/3072/4096final-only; strict/unit correctness alwaysDEV. No finalfreeze/main/
pin/release/upstreamreport. Allremainingregressions/expandedgoalremainunresolved.

Provenance: own MITfork/reuse own reviewed expression andtests; no foreigncode.
