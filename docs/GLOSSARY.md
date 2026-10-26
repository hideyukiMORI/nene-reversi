# 用語集 — NeNe Reversi

> Status: normative（規範）/ 2026-10-26 初版
> ここに載っている語は、コード・ドキュメント・Issue で**同じ意味**で使う。同義語を発明しない。

| 語 | 意味 | 型／場所 |
| --- | --- | --- |
| 結果（outcome） | 期待される成功・失敗を表す閉じた型 | `*Outcome` |
| 拒否理由（rejection / failure） | 結果に添える閉じた理由の集合 | `*Rejection` / `*Failure` |
| 合成ルート | 依存を結ぶ唯一の場所。時計・乱数・環境を読み、標準入出力と終了コードを持つ | `nene-reversi`（executable target） |
| 描画（render） | 局面と HUD の値から文字セルの格子という値を作ること。端末への書き出しは含まない | `NeNeReversiRender` |
| 隔離区画 | 可変性を許した唯一の場所 | ARC-005 の表 |
| 規約検査（conformance） | NeNe Reversi 固有の自作ゲート | `eng/conformance.py`（CNF-NNN） |
| waiver | 1 つの規則に対する期限付きの狭い例外 | `docs/waivers/WVR-NNNN-*.md` |
| 機械強制の状態 | active / planned / 不能 / 不採用 | `docs/QUALITY_GATES.md` の強制マトリクス |
| negative proof | ゲートが意図した規則で落ちることの実測 | `docs/quality/gate-proofs.md` |
| リバーシ（Reversi） | このゲームの名前。登録商標のボードゲームの商品名は使わない（REQUIREMENTS の Q1・CNF-023） | — |
| 石（disc） | 盤に置く黒か白の駒。画面では升とは別の色で塗ったブロックで描く（FR-07） | `NeNeReversiCore` |
| 局面（position） | 盤上の石と手番を合わせた値 | `NeNeReversiCore` |
| 手（move） | 局面を次の局面へ進める 1 回の着手。パスも手の 1 つとして表す。内部表記は `MoveKind`（`.place(Square)` か `.pass`）の 1 つ（ADR 0005） | `Move` |
| 合法手（legal move） | 相手の石を 1 つ以上挟んで反転させられる升への着手 | `NeNeReversiCore` |
| 反転（flip） | 打った石と自分の石で 8 方向のどれかに挟んだ相手の石を、自分の色に変えること | `NeNeReversiCore` |
| パス（pass） | 合法手が 1 つも無い側が打たずに手番を渡すこと | `NeNeReversiCore` |
| 終局（game over） | 両者とも合法手が無い状態（盤が埋まった場合を含む）。石の数で勝敗を決める | `NeNeReversiCore` |
| perft | 局面から深さ N までの手の列の数。合法手生成の正しさを公表値と突き合わせる。パスは 1 手と数え、途中で終局した列は数えない（ADR 0006） | Core のテスト |
| 局面の文字列表現 | 局面を 1 行の文字列で表したもの。読み書きは Core の 1 経路だけ。形は「盤の 64 文字（黒 `X`・白 `O`・空き `-`）・空白・手番の 1 文字」（ADR 0005） | `PositionCodec` |
| 局（game） | 初期局面から終局までの 1 回の対局 | 合成ルート |
| キャスト（cast）・性格（persona） | 黒白を受け持つ 4 名のキャラクター（FLIP.BAT・CORNER.SYS・SPAM.EML・LAZY.CRON）。探索の深さ・評価の重み・セリフの組（FR-06・FR-14・ADR 0010） | `NeNeReversiEngine` |
| シード（seed） | 自前の PRNG の初期値。同じシードからは同じ対局の列と同じセリフが出る | 合成ルートが読み、Engine に渡す |
| セル格子 | 端末の 1 画面分の文字セルの 2 次元配列。Render が作り、Terminal が差分で書く | `NeNeReversiRender` |

## 使ってはいけない語

`Manager` / `Helper` / `Util` / `Utils` / `Common` を型名の語尾に使わない（SWF-010）。
役割を語る名前が思いつかないときは、その型が 2 つの責務を持っている可能性が高い。
