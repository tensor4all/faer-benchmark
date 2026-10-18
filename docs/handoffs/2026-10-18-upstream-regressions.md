# 性能退行調査のハンドオフ（2026-10-18、ユーザー依頼で一時停止）

この記録は既存Issue tensor4all/faer#18への引継ぎ用。**目標未達・作業一時停止。完了、採用、最終候補凍結を意味しない。** 私が起動した計測・ビルド・独立レビューは終了しており、バックグラウンド計測はない。

## 1. 目標と現在地

upstream `0539947ffb757a739d7e703a7d2fa0c792a909c1` に対する、ノイズ帯を超えて再現する技術的に解消可能な性能退行を、正しさ・一般性を維持して解消する。最初の92セルは固定スコープではなく出発点。共有関数の波及、新たに見つかる退行も対象。

最終候補凍結後に `faer-kernels` と `faer-kernels-large` の全宣言population、dtype、C/F、thread budget、MKL/OpenBLAS各arm、境界とadoption-only tierを計測する。宣言済みunsupported/skippedを残す。**2048/3072/4096の大きな正方形は最終凍結後だけ**。途中はfocused検証のみで、新規ベンチ実装を完了条件に加えない。

Issue本文の旧43セル等をそのまま現在の完了判定に流用しない。2026-10-15/16にはCargo patchが無視されregistry `t4a-faer 0.24.5`をリンクした計測がある。`docs/reviews/20261016-linked-crate-provenance.md`を先に読む。現在の実リンク検証済み比較の出発点は10/18の2240b07対upstream。そこで399 faster / 92 slower / 865 band（1356セル）。元データ・分類の意味は `docs/worklog.md` と次のrunに保存されている。

- MKL: `data/results/zen5-cpu/faer-kernels/20261018T022054Z-final-full-mkl`（harness `60a1c92ed4d81d21822b19a00c9b2e2e860c372f`、toolkit `c04ea318cf7f002a751d58212fe31fc79d915665`、MKL 2026.1。後述の現行toolkitとは区別）
- OpenBLAS: `20261018T044649Z-final-full-openblas`（upstream行なし）

これらは拡張後の目標に対する最終全体計測ではない。

## 2. 採用済みと正確なソース状態

| 項目 | 状態・識別子 |
|---|---|
| library main | `7364be5ce22d950343c10d82b99e9fc79d537cd2` |
| 採用済み実測コード・adoption pin | `2240b076a03011b2f128988fecf2967c4b1dda1c`。QRタスク分割＋dense GEMM work floor。mainとの差はdocsのみ |
| benchmark | `perf/upstream-regression-campaign`。主要copy計測アーカイブ `4586adeb359b774fc8248685adb62b6f7c1a1da8`。今回の補足は同branchへまとめてpush |
| toolkit | `fix/rejected-attempt-retention`, `9daa5bc69a13b36c2a31680e20dbb53e2e42c9d5`。拒否試行保存と比較カバレッジ修正済み |
| copy候補 | `60de2ee06467fc41f7c0fd4a3a5b1856bc40d984`、archive branch `perf/native-copy-tile` HEAD `c8763486c66ca5db56bf2e5e2b0056d3086454b2`。未採用 |
| 空extent/K0修正 | production `2e221c75887ff292dc80e19891cb12ec222f0a23`、tests `af8273f5a76f0965d6aedd769ac20b663a0c5d50`、archive `b7715c53ba75946d68a97d5655f481b198332447`。未統合 |

作業ディレクトリは `/home/shinaoka/projects/tensor4all/{faer,faer-benchmark,campaign-toolkit}`。`faer`の作業treeはmainではなく、未採用HH枝 `perf/householder-partial-traffic` のdocs HEAD `f96f226750c89fc5cb707a8c1426405031274f79`。**これをmain/採用候補と取り違えない**。

- `/tmp/faer-native-copy-tile`: 上記copy archive
- `/tmp/faer-native-gemm-audit`: 空extent/K0 archive b7715c5
- full checkout `faer-benchmark/extern/t4a-faer`: 最終確認時60de2ee。upstream checkoutは0539947。再開時に再確認
- 古い未追跡 `faer-benchmark/probes/` はビルドtreeを含む。無差別にaddしない
- `/tmp`だけを引継ぎ証拠にしない。ソースはcommit、結果・完全レビューはbenchmarkリポジトリのtracked artifactsを参照

## 3. 直近のcopy候補：HOLD / NOT ADOPTED

正確なbuiltin4型だけに値タイルを使い、その他の型は既存Optionタイルを保持。追加unsafe/API/依存/Zero/Defaultなし。借用を持つClone-only型＋heap所有のClone/Drop検査も通した。ソースPRE/POST完了、focused2・library212 passed/2 ignored、no-Rayon check通過。カウントは候補60deに対するもの。

fresh FBE A/Bの対象4dense関数はサイズ・正規化命令列とも一致。これはRIP参照先、呼出側、whole-programの同一性や採用を保証しない。

公開コピーAPIの独立診断を一度実行：

- baseline A=`7364be5`、candidate B=`60de2ee`、upstream参照=`0539947`
- compiled harness=`499da6ebac0aa33b3be226940e940ca7a3fe9e0e`
- recording harness=`f79812e89ec02302d4d8bcc11d37c4e44ee1d14f`
- toolkit=`9daa5bc`、vendor engineなし（補助FBE imageはMKL arm）
- ABBABAAB、4 starts/side、64 cells/start、5 samples、250ms prime、allocation/copy/destruction込み
- 実効worker1、faer Seq。CPU4、全L3/SMT監視4-11,16-23、観測側0-3,12-15
- **8 starts / 512 rows / 2560 raw samples、拒否試行0、runtime source/hash/power/thread guards通過**
- 16 targetsと48 unchanged controlsを全件保持。一つのunchanged control `c64/C/64x1024/cloned/1T`がbaseline帯±5%から速い側へ外れた（B/A中央値比0.8264969689777594）。速いからと除外せずHOLD

保存先：`data/probes/20261018-native-copy-tile/` の `public-outcome.json`, `public-decision.json`, `public-retention.json`, `runtime-public/`。90個のruntimeファイルはarchive4586adeのGit blobとSHA一致を確認。起動したPGIDにlive memberなし。

既存ELFだけを調べた結果、両cloned measureと4cloned wrappersは同じサイズ・正規化命令列。aliasを潰していた予備6関数reportは残し、`public-code/aliases-complete/` の全8関数reportで明示的に置換。これで制御セルの差の原因は説明できない。同一B ELF・同じAB順でも開始間の5 samplesが別帯なのでAB/BAラベルだけでも説明不足。アドレス、allocator、cache、周波数等の原因は未確定。**同一診断の再試行、quiet subset、outlier削除、assemblyに合うコード/flag/配置調整をしない。**

運用recorderも独立PRE/POST完了。ただしPOSTの3 Importantをmain agentが修正・dummyチェックしたもので、修正後に別の独立承認を得たと主張しない。完全report、resolution、再現器、checksが `docs/reviews/20261018-builtin-copy-recorder-*` 等にある。`-O`/PYTHONOPTIMIZE拒否、絶対deadline、端末結果先行保存、所有process groupのTERM/KILL/reap、永続TMPDIRを維持。

**formal composite計測は未実施。3624 records/startの全14 family gridはdraft。main/pin変更なし。**

## 4. LU末尾GEMM-only案：公開契約の判断待ち、未実装

新案は再帰LUの末尾GEMMだけにcaller parを戻し、パネルTRSMのarea gateを残す。旧 `a53774682edd4e96f0387a80ddaa7bec2f3d1d70` は両方を戻したため実質的に別案。256平方のpanel128×128でjoin_rawの予算が異なるとソースで確認され、独立PREでもdistinctness PASS。

しかし独立PRE（gpt-6.1-sol）は **COMPLETE / HOLD、public par_threshold互換性BLOCKER**：`par_threshold=usize::MAX`が現在Seqにする末尾GEMMを、新案はGEMM自身の判定で並列化し得る。GEMMはLUの設定値を受け取らない。全LUをSeqにする保証だったという過大な主張はしない（最終wide TRSMは元々caller par）。

ユーザーへ次の判断を尋ねたが、**まだ許可なし**：
1. upstream型の末尾GEMM制御へ戻し、このfork knobの適用範囲をパネル/置換として明記する動作変更を認める。
2. 現在のカスタム閾値の意味を維持し、この案は保留する。

実装・ビルド・計測なし。default値だけ特例にする隠れた分岐、新しいknob/threshold/hookで回避しない。goal continuationは承認ではない。

完全記録：`docs/reviews/20261018-lu-trailing-only-{plan,pre-review}.md` とverbatim JSON。レビューagentは終了済み。旧a537の二つのformal pairはそれぞれ1/12個のupstream controlが失敗して未採用。**第三の同一ペアを試さない**。その失敗を新案のdistinctnessで帳消しにしない。

## 5. 空extent/K0正しさ修正：source検証済み、性能承認・統合は未了

strict/unitのnative extent不一致とK0/Replaceを修正。Addは変更せず、Replaceは論理的stored entriesだけゼロ化し、mapping/strict-unit対角/反対三角/parent guardsを維持。PRE/POST完了、focused4・full214 passed/2 ignored、no-Rayon check通過。新unsafe/API/thresholdなし。

保存済みmain7364 ELFとb771 ELFの対象4dense関数を比較し、**全4サイズ・正規化命令列一致、差分0**。全ELF hashは異なる。別build contextの既存ELF比較で、新規controlled buildや因果証明ではない。source変更/build/kernel/verify/timingなし。

`data/probes/20261018-native-gemm-callers/` の `main-vs-correctness-*` に保存。これだけで性能承認・main統合しない。

**再開時の重要な訂正**：最新の追跡では、spicy_matmulのproduction5呼出はdense LDLTの3か所とsparse Choleskyの2か所。LLTは共有LDLT routineをis_llt=trueで呼ぶが、その場合のupdateは別分岐のtriangular/dense matmulであり、修正対象を直接実行するとは言えない。以前の「dense LLT/LDLTがinternalを使う」という表現は広すぎた。既存native-floor stage1をそのまま「正しさ修正の直接性能検証」として起動しない。まずdeclared backend/solverのreachabilityを詰め、既存ガードを選ぶ。未実装LDLT/sparseベンチを完了条件に追加しない。

既存canonical record_runは各runでbuilderを呼ぶ。旧driverは別run間にcheckoutを切り替える。今回のpublic recorderのimmutable/no-build phaseへそのまま置換できる手順ではない。**新controller作成・新build・新verify・新timingはしていない。**

## 6. その他の保留を復活・採用扱いしない

- native floor `7f713a1`: canonical controls/guards不成立。stage2未実施、INCONCLUSIVE。
- structured `7cd372f` とdirect two-entry `f013756`: 全4dense生成コード不一致、**HOLD before timing**。これらのverify/timingを実行していない。
- 「4body同一性ゲートを診断扱いへ変更してよいか」は未承認。保守的にcopyにも適用して通過したが、ゲート削除許可とは違う。
- HH `ad9f2ef`: 小さいF64/8T guard失敗。未採用、downstream未実施、復活時POST未完了。
- 古いcopy `d6358ca`: generic型への追加Zero/Clone/Drop契約は未承認。新60deと混ぜない。
- SVD always-implicit-QR、upgrade floorの棄却も維持。

## 7. 再開の順序・禁止事項

1. ユーザーが再開を指示したら、各repoのHEAD/dirty、保存refs、外部checkout、起動済み所有processの有無を再確認。未保存ユーザー変更を消さない。直近kache doctorは33990/33990 valid、corruption/missing/orphan/checksum/index drift0、repair不要。
2. 公開契約の許可なくLU案を実装しない。native gate変更も許可扱いしない。
3. 正しさ修正の直接call graphと宣言済みbenchmark reachabilityを先に確定し、最小の既存focusedガードを選ぶ。新しいrecording frameworkを作らない。元の計測・レビュー記録を読み、不要な同じcheck/buildを繰り返さない。
4. 別の最小実験へ進む場合も「失敗=全体停止」にせず、かといって同一失敗ペアを繰り返さない。コード形だけを変えてassembly gateへ合わせない。
5. 計測前にsource/tool/config/argvをcommitし、実際のCargo package pathでリンクを確認。full checkoutと既存builderを使う。計測中にedit/checkout/build/Cargo並行をしない。測定側/観測側CPUをライブtopologyから決め直す。ベースの小仕事は明示的1T。
6. median5/250ms prime、MKL3engine/3starts/full rotation、OpenBLAS2/2、idle3s/max5%/PINNED_RETRIES8、拒否/partial evidence保存を維持。比較は両run全体validator、skip込み同一coverage、exact starts/samples。intersectionで比較しない。CLI exit0は自動採用ではない。
7. 比較契約の実質変更、公開契約/正しさトレードオフ、範囲縮小、共有マシン設定/費用、証拠付き不可避残差だけをユーザー判断へ。無断upstream投稿/公開releaseなし。
8. 正しさと性能ガードを満たした変更だけを統合。最終候補凍結後に全宣言suite/armを逐次実行し、同一codeのmerge前後重複計測はしない。
9. 全要件を実測/tests/保存成果物へ対応付けるまで、goalやIssueを完了扱いにしない。

goal ID `c3af003b-ab2a-45ea-a6e0-e27c7f85abf0` は未完了・一時停止。今回の依頼はハンドオフ保存だけであり、自動的な再開許可ではない。
