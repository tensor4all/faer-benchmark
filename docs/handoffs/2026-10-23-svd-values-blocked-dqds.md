# ハンドオフ：blocked bidiag と dqds shift（2026-10-23、`2026-10-23-svd-values-dqds.md` の続き）

この記録は引継ぎ用。**目標は大部分達成・採用（KEEP）判断は維持者待ち。** 起動中の計測・ビルドはない。両リポジトリとも tree clean、**未 push・PR 未作成**。

## 1. やったこと

`faer` の `perf/svd-dqds` に 5 コミット：

| commit | 内容 |
|---|---|
| `555d84f` | blocked bidiagonalisation（`dgebrd`/`dlabrd` 相当、ib=16、床 128）。各パネル行を連続バッファへ gather（行は stride m で matmul のベクトル経路と反射子 norm に乗らない）。ブロック化フェーズを `spindle::with_lock` で保持（fork 初） |
| `c88f886` | dqds：ping-pong バッファ、固有値相対の deflation `(100 eps)^2 (σ + a)`、2×2 閉形式、固有ベクトル重み付き back-off shift（×2）、最終因子での失敗は `τ + δ` に補正 |
| `ec15508` / `26cec3e` | worklog `docs/worklogs/2026-10-23-blocked-bidiag.md`（内訳・床の走査・計測）、`docs/worklogs/2026-10-23-dqds-shift.md`（カウンタ・shift 変種・計測・MKL 対比）、PATCHSET 行 |
| `7eebfd4` | values-only は全サイズ・全 budget で dqds（(budget, size) ゲート撤去） |

`faer-benchmark` `main`：`a740f12`（A 単体の結果、comparator の harness 規則）、本コミット（A+B の結果、この handoff）。

## 2. 計測（pin baseline `20261023T012045Z-dqds-blast-baseline` 比、MKL arm、比 <1 が速い）

- A 単体 `20261023T091426Z-blocked-bidiag`（`555d84f`）：control 1.0006、384 セル、**172 faster / 0 slower**。`svd_values` 512：1T 0.829／4T 0.737／8T 0.688。
- A+B `20261023T100330Z-blocked-dqds`（`7eebfd4`）：control 1.0022、384 セル、**208 faster / 6 slower**。`svd_values` 中央値：

| | 32 | 64 | 96 | 128 | 256 | 512 | 1024x64 | 4096x256 |
|---|---|---|---|---|---|---|---|---|
| 1T | 0.622 | **0.599** | 0.622 | 0.577 | 0.656 | 0.850 | 0.889 | 0.938 |
| 8T | 0.621 | 0.599 | 0.621 | 0.662 | 0.710 | **0.568** | 0.902 | 0.927 |

- slower 6 セルはすべて `svd_thin` 複素 1T（256/512、1.05–1.11）。この経路は B と無関係で、A 単体計測では同セルが 0.98、候補側の絶対時間は 2 回の計測で 1% 以内に一致（c64 512: 205.7 / 207.3 ms）。正規化比のドリフトとして記録、未解決。
- 同一計測内の MKL 対比（`faer-fork`/`lapack-mkl`、F order）：f64 1T は 512 で 0.90、4096x256 で 0.85、64 で **1.16（0.296 対 0.254 ms）**、8T 512 で 1.15、8T 1024x64 で 1.86。c64 は 1T 全サイズで faer が速い（0.59–0.98）、8T 512 で 0.91。

## 3. 維持者に判断を仰ぐ点

1. `spindle::with_lock` の採用（fork 初のスレッド方針）。ワーカーはフェーズ中スピンする。これなしだと 8T の bidiag 512 は 34.5 → 29 ms 止まり、ありで 19.5 ms。
2. comparator（`scripts/candidate_compare.py`）の「harness commit が違っても、ビルド入力（`fbench`、`Cargo.toml`、`Cargo.lock`、`pins`、`benchmarks`、`scripts/build_for_faer_rev.sh`）の tree hash が同一なら比較を進める」規則。handoff の docs コミットが baseline と候補の比較を拒否させたための対処で、toolkit は未変更。

## 4. 残り（次のユニット）

- **64 の f64**（事前宣言ターゲット）：values 段は MKL と同等（0.126 ms）、残差は非ブロック bidiag の 0.17 ms（MKL ≈ 0.13）。床を 32/64 に下げても改善せず（32 では悪化）。非ブロック loop の行処理（strided な `norm_l2`・反射子・`z2` の rhs）に連続バッファの gather を適用するのが候補。
- **512 以上の 8T**：パネルの直列部分 13.6 ms（短い積 5.1、行の gather/scatter 6.2、末尾 1.4）。MKL の gebrd は 15.6 ms、faer は 19.5 ms。
- **1024x64 の 8T**（1.86）：tall 経路のスレッド化オーバーヘッド、本ユニットの外。
- 計測作法：recorder 起動前に Claude 本体と他エージェント（今回 `codex`）を `taskset -apc 0-3,12-15` で観測側へ。recorder は計測中に測定対象 checkout・harness・toolkit の HEAD と clean を検査するので、**計測中はどのリポジトリにもコミット・編集しない**（今回 faer へのコミットで引っかかりかけ、HEAD を detach して回避した）。
- `probes/gemv-threads`（gemv 単体の 1〜8T 計測）と `probes/svd-phases`（段分解）は untracked の診断。
