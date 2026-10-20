# Exact builtin-scalar copy tiles, preserving generic Clone semantics

Status: PRE requested, no implementation. Separate from native-floor candidates:
7f refused;7cd/f013 HELD beforetiming. Their four-body pre-timinggate remains
binding, continuation is not approval tochangeit. No thresholds/criteria waived.

Base faer7364be5ce22d950343c10d82b99e9fc79d537cd2 (main, runtimecode2240b07).
No LU ancestorbudget/correctnessrepair/HH/native-floor/copyd635 combined.

## Real problem and smallest distinct candidate

Existing Option<T> tiledcopy imposestag/take/unwrap traffic on builtin numerics.
Prior d635 replaced Option withzeroTtile, measured~.70-.91C-nativecopy ratios
(descriptive), but extraZero/Clone oncustomComplexField notaccepted; unchanged
c64F512 control~1.123, no performanceadoption. No rerun/adoptionofthatcandidate.
Actualbaselinealreadyinitializes Optionbuffer ONCEperworker, notpertile: do NOT
invent aninit-hoistfix. Blanketuntiledcopy previouslylostlarge/conflict layouts.

Keep existing publiccopy_across_layouts<T:ComplexField> callers/parallel column
partitions/16x16 tile/loopindexing/readwrite order/allocation boundaries unchanged.
Keep privatecopy_across_layouts_block<T:Clone> entry and ORIGINAL Optionbody as
fallback. At its entry use EXISTINGsafe crate::hacks::nonstatic_typeid::<T>()
compared withcore::any::TypeId::of for EXACT f32/f64/cratec32/cratec64 aliases.
No new 'static bound, no unsafe/coercion, no use of overridable IS_NATIVE flags.
AllotherT retain original Optionbody (including custom Clone-only/drop/heap
values, nonnative ComplexField, references and alternateComplexImpl types).

Onexactbuiltinmatch call oneprivate copy_across_layouts_native_block<T:Clone>
andreturn. Nativehelper keepssame16x16 stagingloops, but [T;256] insteadOption:
if m==0||n==0 return before readingseed; otherwise array::from_fn clones src[0,0]
into seedslots, actualstaging overwrites eachreadslot, writeoutclones thoseT.
No T::zero/Default calls. ExtraClone calls restricted toexactbuiltin Copy scalars
whoseClone is unobservablebitcopy/noDrop; NO newzero/clone/drop calls forcustomT.
Nativehelperprivate/singleproductiondispatchcaller, no independent publicAPI.
One modest duplicated loopbody is deliberate representation difference, not a
TileSlot trait/macro/framework/testhook; reviewer should suggestless onlyif it
preserves exactgenericClone/drop semantics withoutnewunsafe/scratchallocation.
Oldfallback body staysbyteidentical (exceptcodeinsertedbeforeit); no publicbound
change, no ISA/shape/machine threshold/new scratch/heap dependency/flags/tuning.
Existingnonstatic_typeid isalreadyinrepo/usedbycoerce, hasinternalunsafe butnewcode
callsits EXISTINGsafeinterface only. Its lifetimeerasure cannot equate a borrowed
wrapper/reference with anyofthese fourlifetime-free concretebuiltin types.

## Tests, correctness and honesty

Implementation-owned faer/src/linalg/tests/copy_layouts.rs; existingtestmodule
registration only, no externaltestdir/macro API. Reuse ownMIT d635 numericalcases
and extend to actualf32/f64/c32/c64, bothC/F directions, source ANDdestination
reversed strides, empty/1/tails15/16/17/rectangles/129x65, Seq+owned4/8 poolreadback,
wholeparentguards. Exactbit checks includenegativezero/NaNpayload/Inf asdata, not
floatingcomparison ormaxnorm. No need GEMM-stylefinite rejection forpurecopy.

Direct production privateT:Clone entry tests a customCountedClone withheapVec/
ArcAtomic counters/Drop: eachlogicalsource cloned exactlyonce; exactlyoneold
logicaldestination dropped perentry, guards unchanged, separateheapownership,
emptydoesneither; droppingallmatrices leavesexpectedtotaldropcounts. Thistests
REALdispatcher/fallback, not a replica. It is Clone-only, NOTclaimed a complete
customComplexField fixture. ExactTypeIdfilter+originalfallbackinspection covers
thatgenericcontract; do not addhundredmethoddummyComplexField or productionhook.
No SIMD/numericworkerutilization assertion beyond ownedpoolcount.
Focusedtests, full --lib, no-default std,linalg/noRayon; sequentialsharedtarget,
kache verifyfirst; targetedformat/no broadchurn. POST coherent source required
before push/build/performancework. No newpubliccontract tradeoff requested.

## Performance gates (not approval from a plan)

Do not time until sourcePOST/frozen source+harness/tool/commands. Firstretain
public to_owned/cloned allocation+copy+destruction probe at effective1T/Seq1,
existing declared shapes/dtypes/layouts and balancedstarts/all5samples/250msprime,
normalidle/pinnedwatch/rejectedretention; genericcloned/unchangedF-layout shifts
areguards, notdiscardableoutliers. No thresholds tuned from timings.
Canonicaladoption still requires unchangedcomparatorwholecoverage/control/guard/
spread/statisticalrules and declared affected-blast-radius shapes/families,
allsharedcopycallers. Freeze exactinventory/argv beforeformalrecording, not a
posthocintersection. No thirdidenticalLU pair, no square2048/3072/4096 duringdev.
Existingfullcheckoutbuilder/provenance paths only, oneCargo/recording atatime,
no edits/checkouts/builds duringrecording. RuntimeL3/observer/actual1T readbacks
andpower/hashcapture mandatory, no defaultall-core overheadbaseline.

No claimthisremovesallregressions, publiccopy speedup isnotcompositeLU proof.
Main/adoptionpin/release/upstreamtracker unchanged. Fullfinalsuites onlyafter
justifiedfinalfreeze. Review explicitly mustcheck sourcecallercontract, actual
fourtypeidentity/emptyseed/nonnativefallback/Clone&Drop tests/provenance/minimality;
no sourceimplementation or performanceapproval inferred from PRE.

## Final source review / conservative static qualification

PRE andfinishedcoherent2-filePOST COMPLETE/no mustfix, source60de2ee unchanged.
Libraryarchive26950b6 pushed/remoteverified; reported212pass2ignored/narrow
noRayon13existingwarnings suppliednotreviewerexecuted. No performanceapproval.
ApplyEXISTINGfourmatchingdense sizes+normalizedbodies prefilter alsoforthisnew
builtin-copycandidate BEFORE ANY performanceverify/timing, publicprobeincluded.
Any mismatchHOLD/no code/flag/positionfit/selectiveretry. Originalf013HOLD/gate
unchanged. Frozenstatic-only commands/data nowseparatefromdraft3624formal
inventory; no recordcontroller/clockcommands builtbeforestaticqualification.
