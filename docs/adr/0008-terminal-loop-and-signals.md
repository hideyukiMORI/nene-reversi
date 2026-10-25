# ADR 0008 — 並行は 1 本のループだけ、シグナルは原子的な旗、異常終了はハンドラが端末を戻す

- 状態: 受理
- 日付: 2026-10-26
- Issue: #5
- 影響する規則: SWF-013 / SWF-009 / ARC-002 / ARC-004 / ARC-005 / ARC-006 / ARC-007 / QLT-001 / FR-08

## 文脈

SWF-013 は「ループの待ち方（シグナルの受け方とキー入力の待ち方）は Phase 3 の縦切りで決め、ADR に書く」とした。
要件: 異常終了（SIGSEGV を含む）でも端末を必ず復元する・`SIGWINCH` で大きさに追従する・Core と Engine は時計を知らず、
「何秒に 1 手打つか」は合成ルートが決める。Swift 6 の言語モードでは、可変なグローバル変数はデータ競合の検査で拒まれる。

兄弟の NeNe Gambit が同じ問題を同じ規約で解いている（Gambit ADR 0006）。端末の区画は自分たちのコードとして移植してよい（ADR 0003）。

## 決定

Gambit ADR 0006 の 1〜8 を、名前を合わせて引き継ぐ。移植元はコミット 64b82ec の `Sources/NeNeGambitTerminal/`（`Console`・`ConsoleOpening`・
`ConsoleSignals`・`ConsoleState`・`FrameEncoder`・`KeyIntent`・`Palette256`）・`Sources/nene-gambit/`（`Screensaver`・`LaunchOptions`・`LaunchParsing`・`main`）・
`eng/smoke-terminal.py`。

1. **並行の形は 1 つ: 合成ルートの 1 本のループ**（`Screensaver.run`）。ループは `Console.waitForInput(milliseconds:)`（`poll(2)`）で次の 1 歩の締め切りまで入力を待ち、
   起きたら意図・シグナル・時計の順に見る。`Task` / `async` / スレッドは作らない（CNF-022）
2. 終了と大きさの変化のシグナル（SIGINT・SIGTERM・SIGHUP・SIGWINCH）のハンドラは `Synchronization.Atomic<UInt32>` の旗を立てるだけで、ループが `Console.takeSignals()` で取り出す。
   そのために、依存グラフの正本で `NeNeReversiTerminal` の標準モジュールに **`Synchronization` を足す**（Terminal だけ）
3. 異常終了のシグナル（SIGSEGV・SIGBUS・SIGILL・SIGFPE・SIGABRT・SIGTRAP。`precondition` の失敗もここに来る）のハンドラは、その場で端末を戻し
   （メモリを確保しない `write(2)` と `tcsetattr(3)` だけ）、既定の動作に戻して同じシグナルを送り直す
4. 端末の退避値（termios）は `ConsoleState` の 1 か所だけに置き、`nonisolated(unsafe)` のグローバル変数にする（`unsafe=allowed` の Terminal の中だけ・CNF-014）
5. Ctrl+C は termios の `ISIG` を残して SIGINT として受ける。キーは `q` だけ（Q9。`t` は手順 5）
6. 端末の外へのテキストの出力は `Console` だけが持つ。起動できなかった理由 1 行を何と書くかは合成ルートが決め、`Console.reportFailure` で出す
7. 状態の持ち主（ARC-004 の表に名前を書く）: 対局の列は Engine の値型 `GameSeries` で、合成ルートの `Screensaver` が 1 つだけ持つ。1 局の経過は Core の `Game`。
   画面の前フレームは `Screensaver.previous`（合成ルート）。シードは合成ルートが `--seed` かシステムの乱数から決め、`SplitMix64` に渡す
8. 端末の確かめは 2 段: 端末を使わない単体テスト（差分のバイト列・キーの読み取り・256 色への近似）と、実行ファイルを疑似端末で動かす `make smoke`
   （`q`・Ctrl+C・SIGTERM・SIGSEGV・大きさの変化のそれぞれで端末が戻ること・間違った起動オプションと端末の外からの起動は理由 1 行）

Gambit から変えたこと:

- `NeNeReversiTerminalTests` の依存に Engine を足さない（Gambit ADR 0006 の 9）。このリポジトリは `@testable import` を使うので（SWF-008）、
  テストは格子を `Grid.filled` で直接作れる
- 罫線の幅の問い合わせ（`Console.columnsAdvanced`・`CursorReport`）は移植しない。罫線の枠は手順 5 で足す
- 駒記号の後でカーソルを明示的に動かす処理（Gambit ADR 0010）は落とした。画面の文字は ASCII だけ（ADR 0007）

## 強制

- **active**（QLT-001 の一部・FR-08）: `make smoke` が終わり方ごとの端末の復元を見る。証明は P49（端末を戻す列を壊すと smoke が落ちる）
- **active**（SWF-013）: CNF-022 が `async` / `await` / `Task` / `actor` / スレッド / Dispatch の語を拒む

## 結果

- 時計を読むのは合成ルートのループだけで、Core・Engine・Render・Terminal はどれも時計を知らない（ARC-007）
- 🔴 `kill -9`（SIGKILL）は捕まえられないので、端末は戻らない。これは塞げない
- 🔴 異常終了のハンドラの中で Swift の配列の `withUnsafeBufferPointer` を使っている。確保はしないが、Swift の実行時が非同期シグナル安全だという保証は無い（Gambit と同じ）
- `make check` が実行ファイルを release 構成で作り、疑似端末で 5 通り動かす
- smoke は疑似端末での振る舞いを見るだけで、Windows Terminal での見え方の代わりにはならない（QLT-013・手順 3）

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| `Task` と `AsyncStream` でキー入力と時計を別々に待つ | 並行の形が 2 つになる（SWF-013）。1 本の `poll` で足りる |
| シグナルを `signalfd` / self-pipe で受ける | 旗 1 つで足りる。ファイル記述子が増え、`poll` の相手が 2 つになる |
| シグナルのハンドラから直接描き直す | ハンドラの中でメモリを確保することになる（非同期シグナル安全でない） |
| `atexit` で端末を戻す | 異常終了のシグナルでは呼ばれない |
| `Synchronization` を使わず、C の `sig_atomic_t` 相当を `nonisolated(unsafe)` の変数で持つ | Swift 6 のデータ競合の検査を `unsafe` で黙らせることになる。`Atomic` なら検査の中で書ける |
| Terminal を Gambit と共有のパッケージにして依存する | 外部依存を足すことになる（ADR・許可リスト・規約の表の 3 点が要る）。兄弟でも版の進み方が違う |
