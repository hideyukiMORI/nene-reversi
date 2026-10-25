# いまのタスク — NeNe Reversi

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-25（75 ケース・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-26（Issue #1・PR #2・ruleset 25825059） |
| Phase 2 negative proof | ✅ 2026-10-26（60 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 盤面と合法手生成・perft（Core だけ） | ✅ 2026-10-26（Issue #3・PR #4・perft 深さ 1〜11 一致・ADR 0005 / 0006） |
| Phase 3-2 ランダムに打つ 2 者の対局を端末に出す | ✅ 2026-10-26（Issue #5・PR #6・ADR 0007 / 0008） |
| Phase 3-3 実機の画面写真 | 🔄 Issue #7（石が縦につながって見えた → ADR 0009） |
| Phase 3-4 以降（探索・HUD とテーマ・キャスト） | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・`swift test -c release`・疑似端末での smoke・コミットの形）
- `NeNeReversiCore`: 盤（黒白の 64 ビット 2 枚）・合法手生成・反転・パス・終局と勝敗・局面の文字列表現の読み書き。perft は初期局面の深さ 1〜11 が公表値と一致
- `nene-reversi`: ランダムに打つ 2 者の対局を描き続ける（1 テーマ・`q` で終了・`--seed` / `--move-interval` / `--result-pause`）

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（作業環境の権限で止められた・gate-proofs 第 3 節）
- 評価と探索・12 テーマ・キャストのセリフ・罫線の枠・配布（Phase 3-3 以降・Phase 4）
- Windows Terminal の実機の画面写真は撮った（2026-10-26）。施主にはまだ見てもらっていない

## 次の 1 手

Issue #7 の PR をマージしたあと、手順 4「評価関数＋アルファベータ探索・序盤のばらつき・性格」の Issue を立てる。
勝ち負けと石差のばらつきを数十局で計測して ADR に書く。
