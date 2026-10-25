# ADR 0003 — ゲートと規約検査は NeNe Gambit から移植し、証明はこのリポジトリで取り直す

- 状態: 受理
- 日付: 2026-10-26
- Issue: #1
- 影響する規則: QLT-001 / QLT-007 / CNF-001〜CNF-023 / GIT-003

## 文脈

NeNe Gambit（https://github.com/hideyukiMORI/nene-gambit）は、同じ施主・同じ MIT ライセンス・同じ厳格規約で作った兄弟のリポジトリである。
施主の方針として、Gambit のゲートと規約検査・文書の形・端末と描画の土台・配布の形は、自分たちのコードとして移植してよい。
ただし中身を理解せずに丸ごと写すのではなく、リバーシに要らないもの（チェス固有の部分）を落とし、名前を合わせ、検査の証明（negative proof）は
このリポジトリで取り直す。

Phase 0 の実測（ADR 0001）は、Gambit の検査に**このリポジトリで測った形の穴**があることを示した（CNF-013 が括弧と並びの全捕捉を通す・
`.swift-format` の鍵を見ない・extension の init と `@preconcurrency` と並行の語を見ない）。写すだけでは穴も一緒に写る。

## 決定

Issue #1 で次のファイルを Gambit から移植した。移植元のコミットは、そのファイルを最後に変えた Gambit のコミット（`git log -1 -- <file>`）である。
Gambit の main の HEAD はいずれも `64b82ec`。

| このリポジトリのファイル | 移植元（Gambit） | 変えたこと |
| --- | --- | --- |
| `eng/measure-language.py` | `8c5b8f6` | 19 ケースを足した（ADR 0001）。`--swiftlint` の相対パスを解決する（一時ディレクトリで回すと見つからなかった）。テストの失敗行も診断に残す |
| `eng/conformance.py` | `bbfb078` | CNF-013 を `case` の選択肢ごとの判定に書き換えた。CNF-005 に `.swift-format` の鍵の許可リスト・CNF-014 に `@preconcurrency` を足した。CNF-021〜CNF-023 を足した。CNF-006 は実測の空の証明行を証明に数えない。`.gitignore` の許可から `.release/` を外した（配布は Phase 4） |
| `eng/tests/test_conformance.py` | `8c5b8f6` | 上の変更の正例・反例を足した（例のファイル名からチェスの語を外した） |
| `eng/prove-gates.py` | `8c5b8f6`（足場の方式） | 名前を合わせた。作業木の複製を `git ls-files` の一覧で行う（作業用の非公開ディレクトリを名指ししない）。このリポジトリで足した検査の証明を足した |
| `eng/swift-strict.sh` | `72691db` | 事故の参照先を「NeNe Gambit の Issue #3」と明記した（Gambit が見つけた SwiftPM の警告の穴を、最初から塞ぐ） |
| `eng/install-tools.sh`・`eng/install-swift.sh`・`eng/lint.sh`・`eng/swift-sources.sh`・`eng/validate-commit-message.py`・`eng/tests/test_commit_message.py`・`eng/swift.lock`・`eng/swiftlint.lock`・`eng/dependency-allowlist.txt` | `8c5b8f6` | 変えていない |
| `Makefile` | `8c5b8f6`（足場の段） | `build` を `eng/swift-strict.sh` 経由にした（`bbfb078` の形）。`test`・`smoke`・`release` の段はまだ足さない（Phase 3・4） |
| `.swift-format`・`.swiftlint.yml`・`.githooks/commit-msg`・`.github/pull_request_template.md` | `8c5b8f6` | 変えていない |
| `.github/workflows/ci.yml`・`eng/ci-require-ready.sh` | `8c5b8f6` | コメントの事故の参照先を「NeNe Gambit の PR #2」と明記した（このリポジトリの PR #2 は別の PR） |
| `docs/` の各文書・`CLAUDE.md`・`AGENTS.md` | `8c5b8f6` の形 | 中身はリバーシとこのリポジトリの実測で書き直した |

持ってこなかったもの: チェスのルール・評価・探索（Core と Engine はリバーシで一から書く）・キャストとセリフ（新しい 4 名で書く）・
`eng/smoke-terminal.py`・`eng/package-release.sh`・`install.sh`・端末と描画の土台（どれも Phase 3・4 で、使う PR で移植してこの表に足す）。

**証明はすべてこのリポジトリで取り直した**（`python3 eng/prove-gates.py`・[gate-proofs.md](../quality/gate-proofs.md)）。Gambit の証明の結果は一つも写していない。
GitHub 側の証明（ruleset・draft の CI）もこのリポジトリの PR と run で取った。

## 強制

- **active**: 移植した検査はすべて、このリポジトリの証明が通ってから強制マトリクスで active にした（CNF-006 が証明行の無い active を拒否する）
- **不能**: 「移植元を理解して写したか」はレビュー事項である。この表は、次に誰かが Gambit の修正を取り込むときの照合元として置く

## 結果

- 3 回分の実測と事故（draft の CI のスキップ・SwiftPM の警告・静的バイナリが黙って規則を飛ばす）から生まれた検査を、最初から持てる
- Gambit の検査の穴（CNF-013 ほか）を見つけたのは移植の副産物である。Gambit 側への還流は Gambit の Issue として施主に提案する（このリポジトリの範囲外）
- 失うもの: Gambit の検査器が直されても、このリポジトリには自動では入らない。2 つの検査器は別々に保守する

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| Gambit の検査器を共有のパッケージや submodule にする | 依存を足すことになり（CODING_RULES 第 5 節の 3 点が要る）、片方の都合の変更がもう片方のゲートを黙って変える。規約は製品ごとの「守るべきこと」を含む |
| 検査器を一から書き直す | 先に踏んだ地雷（スキップの CI・静的バイナリ・manifest の上書き）を自分で踏み直すことになる。移植してよいと施主が決めている |
| Gambit の gate-proofs の結果を写す | 「設定が在ることは検査が効いている証明ではない」（ポリシー P-09）。このリポジトリの木で落ちるのを見ていない |
| Gambit の main の HEAD の `prove-gates.py` を移植する | 実装済みの target のソースに違反を仕込む形で、target が 0 本の足場では動かない。足場を置いて仕込む `8c5b8f6` の形を移植した |
