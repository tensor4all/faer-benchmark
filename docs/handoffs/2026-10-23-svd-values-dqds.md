# ハンドオフ：`svd_values` の dqds と、次にやる A/B/C（2026-10-23）

この記録は作業の引継ぎ用。**目標は部分達成・作業継続中。採用（KEEP）ではない。** 起動中の計測・ビルドはない。すべての branch は tree clean、**未 push・PR 未作成**。

## 1. 目標と現在地

`svd_values` は pin `50c2b98` で正方形 32–512 の全域で両ベンダに劣後していた（64 で faer 0.52 ms 対 OpenBLAS 0.276 / MKL 0.265）。原因は**値のみ経路が dqds でないこと**。

- LAPACK の公開ソースで確認：`dgesdd(jobz='N')` → `DBDSDC(compq='N')` → `DLASDQ(NCVT=NRU=NCC=0)` → `DBDSQR`（`ROTATE=false`）→ **`DLASQ1`（dqds, O(n²), 回転なし, high relative accuracy）**。faer は 128 未満が回転ベース QR、128 以上が D&C（値のみでもマージ中間を構築）。
- 実装済み（`perf/svd-dqds`、`801c197`）：`faer/src/linalg/svd/dqds.rs`。平方前スケーリング、shift 受理判定つきリトライ、`b_i=0` 分割、Li deflation、sqrt＋降順ソートはカーネル内、零対角は回転経路へフォールバック。**`thin_svd` と n=2..40 × 4 スペクトルで 1e-10 一致**、lib 217 passed / 2 ignored。
- 経路は **(budget, size) で選択**（`9f77705`）：dqds は「`par` が Seq または n < 256」、それ以上は D&C。dqds が直列で、置き換えた D&C のマージは threading するため。
- キャンペーン測定（同一スタック・ペア、MKL arm、`svd_values`、比 <1 が速い）：

| | 32 | 64 | 96 | 128 | 256 | 512 | 1024x64 | 4096x256 |
|---|---|---|---|---|---|---|---|---|
| 1T | 0.909 | 0.879 | 0.877 | **0.789** | 0.856 | 0.922 | 0.975 | 0.978 |
| 4T | 0.910 | 0.879 | 0.877 | 0.911 | 1.004 | 0.999 | 0.977 | 0.999 |
| 8T | 0.911 | 0.873 | 0.877 | 0.899 | 0.999 | 1.000 | 0.986 | 0.998 |

`20261023T065035Z-dqds-gated` 対 `20261023T012045Z-dqds-blast-baseline`、192 セル、**110 faster / 0 slower beyond 5%**。control（`faer-upstream`）1.0016。**事前宣言した主目標（64 で 0.275 ms へ接近）は未達**（0.476 ms）。

## 2. 段の分解（自前プローブ、f64、min of 5–7）

`n=512`、bidiag / values 段（ms）：

| | faer 1T | faer 8T | MKL 1T | MKL 8T |
|---|---|---|---|---|
| bidiag | 42.9 | 34.5 | 39.8 | **15.6** |
| values | 15.8 | 16.6 | **7.1** | **6.9** |

- 512/8T の差 28.7 ms の内訳：**bidiag の threading 不足が 18.9 ms（2/3）**、values 段が 9.7 ms（1/3）。
- MKL の段分解は公開 API（`?gebrd` と `?gesdd(jobz='N')`）を自前ドライバで測ったもの。**MKL の値のみ段はスレッド数で動かない**（7.13 → 6.89）＝ 値段は直列、bidiag は 2.6× スレッドが効く。
- faer の values 段は全サイズで MKL の 2.2–2.4×（64: 0.302 対 0.131、512: 15.8 対 7.1）。
- faer の bidiag は 1T では MKL の 1.08–1.3×、8T で 2.2×。

**結論**：大きなサイズの負けは「values 段」ではなく **(i) bidiag の分解・スレッド化**、小さなサイズは **(ii) values 段の実装品質**。

## 3. 次にやる A / B（C は保留）

### A. bidiag のブロック化（dlabrd 相当）— **設計はレビュー2回済み、実装前**

`faer/src/linalg/svd/bidiag.rs` は**非ブロック**：`BidiagParams` は `par_threshold` だけ、trailing update は `matmul(y2, A21ᴴ, A22)` / `matmul(z2, A22, A12ᴴ)` という **matvec 形**。LAPACK の `dgebrd` は `dlabrd`（パネル）＋**GEMM** trailing update。

見積り（`probes/rankk`、`A22 -= A21 A12`、n=512、`ib` ごと、min of 5）：

| ib | 1T / update | 1T 換算（n/ib 回） | 8T / update | 8T 換算 |
|---|---|---|---|---|
| 16 | 0.283 ms (29.6 GFLOP/s) | 9.1 ms | 0.077 ms | 2.5 ms |
| 32 | 0.550 ms (30.5) | 8.8 ms | 0.090 ms (185.8) | 1.4 ms |
| 64 | 1.079 ms (31.1) | 8.6 ms | 0.157 ms (213.7) | 1.3 ms |

パネル生成側（`probes/bidiag-panel`、`m x ib` の `bidiag_in_place` を `m/ib` 回、行数が縮む分を見ない過大評価）：

| ib | 1 パネル 1T | 1T 換算 | 1 パネル 8T | 8T 換算 |
|---|---|---|---|---|
| 16 | 0.068 ms | 2.2 ms | 0.067 ms | 2.2 ms |
| 32 | 0.218 ms | 3.5 ms | 0.215 ms | 3.4 ms |
| 64 | 0.827 ms | 6.6 ms | 0.830 ms | 6.6 ms |

ib=32 で **パネル 3.5 + 更新 8.8 = 約 12 ms（1T）**、8T で **3.4 + 1.4 = 約 5 ms**。ただしこれは **カーネル単位の診断値であって、このアルゴリズムの bound ではない**（更新側は 1 つの GEMM を数えただけで、実際は 2 積＋correction 漸化が要る／パネル側は細い行列で測っており右側 reflector の全幅作業が入っていない）。現在の bidiag は 42.9 / 34.5 ms。

**ただしこの見積りは楽観側**：MKL の `?gebrd` も blocked（公開 API の測定で 1T 39.8 ms / 8T 15.6 ms）であり、上の構成要素から期待される 12 ms より 3× 遅い。差は dlabrd が work 行列 X/Y に対して行う level-2 適用（1 パネルあたり 4 回）で説明される可能性があり、**この 2 つの数値の間が A の実際の効果**。実装して測る以外に決められない。

**設計（`faer/docs/worklogs/2026-10-23-blocked-bidiag.md`、`dfb28dd` 時点）**。初版はレビューで根本的に否定され、LAPACK `dlabrd`/`dgebrd` の形に作り直した：

1. **パネル漸化（deferred update）**：各 `i` で `A(i:m,i)` / `A(i,i+1:n)` を、既に溜めた correction 列との**短い積**（幅 i-1）で更新 → 列 reflector と行 reflector を生成 → `Y(i+1:n,i)`, `X(i+1:m,i)` を作る。スケールは **`tl.recip()` / `tr.recip()`**（faer は `H = I − v vᴴ / tau` で保持し、`Hl`/`Hr` には `tl`/`tr` 本体を入れる）。
2. **trailing update は 1 パネル 1 回・level-3**：`A22 -= V·Yᵀ + X·Uᵀ`（`V = A(i+ib:m, i:i+ib)`, `U = A(i:i+ib, i+ib:n)`）を**素の `matmul` 2 回**で。`householder` の block helper は使わない（初版の誤り）。
3. 右 reflector は A の**行**に入っているので、右側は `V.transpose(), Conj::Yes`（`bidiag.rs:483-485` と同じ）。左の transpose 適用も `Conj::Yes`。
4. **ループ述語**：残り寸法 `min(m-p, n-p) > 128`（厳密）の間だけブロック。`min(m,n) <= 128` はブロックに入らない。床は scratch query にも反映。
5. **末尾への入り方**：パネルの 2 積で trailing は既に更新済みなので、非ブロック末尾は**ローカル添字を新規に切り、pending な `y`/`z` 対を持たない**状態で開始（`bidiag.rs:87-103,111-116` の `k>0` 分岐をそのまま使うと二重更新になる）。以降は既存の per-step 演算そのまま、出力 factor の upgrade は最後に 1 回。
6. **scratch**：`X (m×ib)` と `Y (n×ib)` がパネルと update の間ずっと生きる。`any_of` 共有は不可。2 つの積はどちらも `A22` に直接加算するので結果バッファ不要。既存の query（`svd_imp_scratch`、tall 経路の reduction）が大きくなった要求を伝播するので**呼び出し側の変更は不要**。
7. **公開 knob を足さない**：`ib` は内部定数（初期 32）。

**期待値の読み替え（レビュー2回目）**：ベンダの blocked `?gebrd` は 1T 39.8 ms / 8T 15.6 ms で、faer の非ブロックは 42.9 / 34.5。**パネル側 level-2 は level-3 更新と同程度**なので、**1T はほぼ動かない可能性が高く、効くのは 8T**。よって主ゲートは **`svd_values` 512 の 8T < 20 ms（現 49.1）**、1T は「悪化しない」ガード。

**テスト（レビュー2回目）**：既存の bidiag テストは 4/8、SVD テストは 150 で `Par::Seq` なので、上の述語では2枚目のパネルを跨がない。**`min(m,n)=300` ＋ 長方形状**で、real/complex、`Par::Seq` と threaded（**threaded 側は `par_threshold = 0`**。既定 192*256 では 199² が床を割って逐次になる）。

### B. dqds の shift（dlaq4 相当）— **仮説として扱う**

3案（shift 相対 deflation、late-failure shift 補正、解析的2値 deflation）はどれも混在スペクトルで非収束。ただし**複数変更を同時に入れた実験**なので、shift 選択と deflation／浮動小数点処理を分離できていない。「構成上 admissible」「リトライ不要」は**未確立**。

- 先にやる：**受理された shift／ゼロ shift／棄却 sweep／deflation をフィクスチャ毎に数える**計装。今回カウンタを試作したが static 累積のリセットが効かず数値は未信頼（`dqds::singular_values` の入口でリセットする実装が必要）。そのうえで失敗フィクスチャ（`d=[1e-6, O(1), …]`、n=3–4）に当てる。
- `shift_candidate` の `half_trace - disc` は分離スペクトルで**小固有値を桁落ちで 0 にしうる**（`faer/src/linalg/svd/dqds.rs` の `shift_candidate`）。まず 0 になる頻度を測り、**桁落ち安全な 2×2 固有値**（他方の根から求める形）を試す。それでも足りなければ `dlaq4` 相当の shift 選択。
- B は**shift の変更だけ**を単独で評価する（deflation 緩和と 2 値解放を同時に入れない）。

### C. 小 K の gemm — 今回は作らない

A の実測（上表）で trailing update は既に 30–214 GFLOP/s 出ており、gemm カーネルは律速ではない。A を入れた後の実測で必要と判明したときだけ、専用形状（rank-32、大きな m,n）を足す。

### D.（レビュー由来の安い候補）

既存 D&C の**根が values-only でも特異ベクトルを作っている**（`bidiag_svd.rs` の D&C 入口で `TwoRowsStorage` が捨てる経路）。D&C の再帰は threading 済みなので、**根の不要なベクトル構築・回転だけを省く**のが B より安い可能性。512/256 の values 段でどれだけ占めるかを先に測る。

## 4. 触ってはいけない/信用してはいけないもの

- **`probes/svd-anatomy` は誤り**：繰り返し毎に入力を復元せず、下側副対角を読んでいる（`bidiag_in_place` は上側に格納）。段の切り分けには使わない。`probes/svd-phases`（bidiag と合計の差）と `probes/rankk`（A の見積り）を使う。
- `probes/` はすべて untracked の診断で、キャンペーン証拠ではない。数値を引用するときは「診断」と書く。
- `faer-benchmark` の `Cargo.lock` は **`cargo check --features link-*` で registry の `t4a-faer 0.24.8` に再解決される**。`scripts/build_for_faer_rev.sh` のガードがビルド前に止める（実際に踏んだ）。触ったら `git checkout -- Cargo.lock`。

## 5. harness 側の変更（`faer-benchmark`、未 push）

| commit | 内容 |
|---|---|
| `02f5ae8` | `Dtype::F32/C32`、`Scalar` 実装、dtype ごとの tolerance、`ops` 分岐、`svd_values_op` がネイティブ `T::Real` を保存、`LapackGemm` を `LapackScalar` から分離し `cblas_sgemm/cgemm`、`--dtype f32/c32`、**`--n` 省略時は 64 セルのみ** |
| `7c1d7a5` | f32/c32 の床を実測値 **6e-5 フラット**に（1e-5 は `svd_thin` の 1.09e-5 を誤って拒否） |
| `34a75d7` | suite に `dtypes: [f64, c64, f32, c32]` を宣言（ループ測定に必須） |
| `fca2090` | `Cargo.lock` 復元 |
| `908bdec` | `docs/rules.md` に「最適化ループは 64 ターゲット／32 ガード」 |

- 検証：`fbench verify --dtype f64,c64,f32,c32 --n 32,64` で各 dtype 104 ok / 16 skip（skip は既存の `eig`/`upgrade_factor`）。
- f32/c32 の vendor 行は `gemm` のみ（LAPACK ドライバ未対応、`skipped` に dtype 名入りの理由）。
- 計測作法：**観測側（pi 本体）を先に別コマンドで pin** してから起動すること。同一コマンド内で `taskset -apc` しても、フォーク済みのシェルは古い affinity を継承して recorder に拒否される（実際に踏んだ）。1T→CPU4、4T→4-7、8T→4-11、観測側 0-3,12-15。

## 6. 証拠の置き場所

- `faer`：`perf/svd-dqds`（`801c197` dqds 本体、`9f77705` 経路ゲート、`f95626f` 以降 docs、`2fdb2e0` PATCHSET 行は EXPERIMENT）、worklog `docs/worklogs/2026-10-23-dqds-values-only.md`、`docs/worklogs/2026-10-23-svd-values-at-64.md`。
- `faer-benchmark`：`data/results/zen5-cpu/faer-kernels/` の
  - `20261023T012045Z-dqds-blast-baseline`（pin、baseline）
  - `20261022T223956Z-dqds-loop-baseline`（pin、64/32 ループ）
  - `20261022T230352Z-dqds-loop-candidate`（ループ、dqds 全面）
  - `20261023T000823Z-dqds-blast`（blast、dqds 全面）
  - `20261023T043848Z-dqds-off-control`（dqds コンパイルのみ・未呼び出しの対照）
  - `20261023T065035Z-dqds-gated`（最終、(budget,size) ゲート）
  - `20261023T233722Z-dqds-blast`（f32 tolerance で verify 失敗、破棄）
- 比較 JSON（/tmp、消える）：`/tmp/dqds-*.json`

## 7. 再開手順

1. `kache doctor --verify`（cargo が kache 経由なら）。
2. `faer`：`git switch perf/svd-dqds`、`cargo test -p t4a-faer --lib` → 217 passed / 2 ignored を確認。
3. `faer-benchmark`：`git status`（`Cargo.lock` を含めて clean か）、`python3 scripts/record_run.py --help`。
4. A の最初の測定（パネル vs trailing update、512 の 1T/8T、64/128 ガード）→ 前提が崩れないことを確認してから `bidiag.rs` を触る。
5. B は計装（受理/ゼロ/棄却/deflation のカウント）から。数値が取れてから shift を設計する。
