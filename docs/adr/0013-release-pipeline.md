# ADR 0013 — 版の入力は Version.swift の 1 か所、配布物は静的リンクの 1 経路で作り、検査してから梱包する

- 状態: 受理
- 日付: 2026-10-26
- Issue: #15
- 影響する規則: ARC-006 / QLT-011 / QLT-014（新規）/ CNF-005

## 文脈

Phase 4 は、版の入力 1 か所・公開スクリプト 1 本・成果物の検査・`SHA256SUMS`・`install.sh` で、Linux x86_64 の実行ファイルを GitHub Release に置く。
SwiftPM の manifest には製品の版の欄が無い。既定の `swift build -c release` は Swift のランタイムに動的に依存し、Swift の入っていない WSL では起動しない
（NeNe Gambit ADR 0012 の実測）。兄弟の Gambit はこの問題を同じ規約で解いて v0.1.1 を公開している。配布の仕組みは移植してよい（ADR 0003）。

## 決定

Gambit ADR 0012 の決定 1〜5 を、名前を合わせて引き継ぐ。移植元はコミット 64b82ec の `eng/package-release.sh`・`install.sh`・`eng/release/README.txt`・`Version.swift` の形。

1. 版の入力は `Sources/nene-reversi/Version.swift` の `Version.current` の 1 か所（最初の版は 0.1.0）。`nene-reversi --version` はそこから `nene-reversi <版>` の 1 行を出す
   （ARC-006 の「合成ルートが出してよい 1 行」に `--version` を足す）
2. 配布物は `eng/package-release.sh [v<版>]`（`make release TAG=v<版>`）だけが作る。単一ゲートとは別のビルドディレクトリ（`.release/build`）で
   規約検査・release 構成のテスト・`--static-swift-stdlib` のビルドを通し、`strip` してから検査する:
   x86-64 の ELF・動的依存が `ld-linux-x86-64.so.2` `libc.so.6` `libgcc_s.so.1` `libm.so.6` `libstdc++.so.6` の中だけ・`--version` が版と一致・タグが版と一致・
   同梱物が `nene-reversi` `README.txt` `LICENSE` の 3 つと完全一致。検査は新しい規則 **QLT-014** として QUALITY_GATES に置く
3. 梱包は再現できる形（tar の並び・時刻・持ち主を固定、gzip の時刻を入れない）。`SHA256SUMS` をスクリプトが書く
4. 利用者向けの `README.txt`（ダウンロード → 照合 → 展開 → 起動・キー・起動オプション）は `eng/release/README.txt` に置き、版を埋めて同梱する。
   `install.sh` は最新（または `NENE_REVERSI_VERSION`）の配布物を落とし、`SHA256SUMS` で照合してから `~/.local/bin` に入れる。照合に落ちたら何も入れない
5. 公開は squash 統合後の clean な `main` から同じスクリプトで作り直し、短い起動を確かめてから `v<版>` のタグと同名の Release に配布物と
   `SHA256SUMS` を添付し、再ダウンロードして照合する。🔴 **公開は施主の確認を取ってから行う**（Q12）。この ADR の PR では公開もタグの作成もしない
6. `.release/` を生成物の置き場として `.gitignore` に足し、規約検査の「無視してよい置き場」の許可リスト（CNF-005）にも足す。
   中身は公開スクリプトが毎回消して作り直す生成物だけで、ソースは置かない

## 強制

- **active**（QLT-014）: 証明 P51（タグの不一致）・P52（静的リンクを外すと Swift のランタイムへの動的依存で落ちる）・P53（余計な同梱物）・P54（`--version` の不一致）

## 結果

実測（2026-10-26・WSL2 Ubuntu 22.04・Swift 6.4.1・`make release TAG=v0.1.0`）:

- 公開スクリプトは約 29 秒（2 回目以降・ビルドの再利用あり）。tar.gz の SHA-256 は 2 回作って同じ（`095bf1ff8d9c…`）
- 実行ファイルは `strip` 後 7.3 MB。動的依存は許可した 5 つだけ。要求する glibc は 2.35（`GLIBC_2.35`）。つまり Ubuntu 22.04 以降
- 証明 P51〜P54 はそれぞれ意図した理由（タグ v9.9.9 が版 v0.1.0 と違う・`libswiftCore.so` への動的依存・`./notes.txt` の同梱・`--version` が `nene-reversi 0.0.0`）で落ちた

- 失うもの: 公開スクリプトの中でテストをもう一度回すので、公開に時間がかかる。これはフルゲートの代わりではない
- 🔴 CNF-005 の許可リストに `.release/` を足したのは、検査の対象を狭める変更である。`.release/` にソースを置けば規約検査から隠れる。
  公開スクリプトが毎回 `rm -rf .release/stage .release/out` してから作るので、置いても残らないが、`.release/build` は消さない（ビルドの再利用のため）

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 版を `VERSION` ファイルに置き、ビルド時に読む | SwiftPM でビルド時にファイルを読むにはビルドプラグインが要る（SWF-009 で禁止） |
| 版を git のタグから取る | タグの無い木で `--version` が決まらない。ソースが版を知らないことになる |
| Swift のランタイムを同梱して動的リンクのまま配る | 同梱物と `LD_LIBRARY_PATH` の扱いが増える。静的リンクなら 1 ファイルで動く |
| 配布物を `.build/` の中に作る | 単一ゲートのビルドと混ざる。別のビルドディレクトリで作り直すことが検査の前提 |
| この PR で Release まで公開する | 公開は外に出る操作で、施主の確認を取る決まり（Q12）。README の画面写真も施主が見た目を確かめてから撮る |
