# いまのタスク — NeNe Reversi

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-25（75 ケース・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-26（Issue #1・PR #2・ruleset 25825059） |
| Phase 2 negative proof | ✅ 2026-10-26（60 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 盤面と合法手生成・perft（Core だけ） | 🔄 Issue #3（perft 深さ 1〜11 一致・ADR 0005 / 0006） |
| Phase 3-2 以降（画面・探索・HUD） | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・`swift test -c release`・コミットの形）
- `NeNeReversiCore`: 盤（黒白の 64 ビット 2 枚）・合法手生成・反転・パス・終局と勝敗・局面の文字列表現の読み書き。perft は初期局面の深さ 1〜11 が公表値と一致

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（作業環境の権限で止められた・gate-proofs 第 3 節）

- 画面・端末・探索・合成ルート（Phase 3-2 以降）

## 次の 1 手

Issue #3 の PR をマージしたあと、Phase 3 の手順 2「ランダムに打つ 2 者の自動対局を画面に出す」の Issue を立てる
（1 局の値・終局から次の局へ・`q` で終了・端末の復元・疑似端末での smoke）。
