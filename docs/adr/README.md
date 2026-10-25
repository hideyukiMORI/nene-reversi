# アーキテクチャ決定記録（ADR）

トレードオフのある判断を、**理由ごと**残す場所。正本ドキュメントが「いま何が規範か」を書くのに対し、
ADR は「なぜそう決めたか」「何を却下したか」を書く。

## 書き方

- 連番 4 桁 ＋ kebab の題名: `NNNN-short-kebab-title.md`
- `0000-template.md` を複製して書く
- 状態は `提案` / `受理` / `却下` / `置換（→ NNNN）`
- **却下した選択肢を必ず書く。** 再提案は、その理由への反論から始めること
- 受理された ADR を後から書き換えない。変えるときは新しい ADR で置き換える
- 文脈は可能な限り実データ（コード・履歴・計測・コンパイラの出力）で裏を取る

## 一覧

| ADR | 題名 | 状態 |
| --- | --- | --- |
| [0001](0001-strictness-is-mechanically-enforced.md) | 厳格さは機械で強制する | 受理 |
| [0002](0002-swift-testing-only.md) | テスト枠組みは Swift Testing だけにする | 受理 |
| [0003](0003-port-gates-from-gambit.md) | ゲートと規約検査は NeNe Gambit から移植し、証明はこのリポジトリで取り直す | 受理 |
| [0004](0004-target-split-and-dependency-graph.md) | target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、Gambit と同じ向きで依存させる | 受理 |
| [0005](0005-bitboards-and-move-representation.md) | 盤は黒と白の 64 ビット 2 枚、手は「升に打つ／パス」の閉じた enum、適用は新しい局面を返す | 受理 |
| [0006](0006-perft-counting-and-gate-depth.md) | perft はパスを 1 手と数える出典に合わせ、release 構成で深さ 11 までゲートに回す | 受理 |
| [0007](0007-screen-layout-and-disc-blocks.md) | 画面の文字は ASCII だけ、石は升とは別の色で塗った偶数桁の空白、盤は 2 段の大きさ | 受理 |
| [0008](0008-terminal-loop-and-signals.md) | 並行は 1 本のループだけ、シグナルは原子的な旗、異常終了はハンドラが端末を戻す | 受理 |
