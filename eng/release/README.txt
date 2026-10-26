NeNe Reversi @VERSION@ (Linux x86_64)
======================================

端末の中で、4 名のキャストが手作りのリバーシ AI で延々と打ち続けるスクリーンセーバー。
1 局が終わると次の局が始まり、q を押すまで続く。

動作環境: WSL2 の Ubuntu（Windows Terminal）など、x86_64 の Linux で glibc 2.35 以上（Ubuntu 22.04 以降）。
Swift は要らない（標準ライブラリを静的にリンクしてある）。

ダウンロードと確認
------------------
1. GitHub の Release から次の 2 つを同じフォルダに落とす
     nene-reversi-@VERSION@-linux-x86_64.tar.gz
     SHA256SUMS
2. 照合する（OK と出ること）
     sha256sum --check SHA256SUMS
3. 展開して起動する
     tar -xzf nene-reversi-@VERSION@-linux-x86_64.tar.gz
     ./nene-reversi-@VERSION@-linux-x86_64/nene-reversi

キー
----
  q   終了
  t   カラーテーマ（12 種類）

起動オプション
--------------
  --theme NAME          NEON PHOSPHOR AMBER SYNTHWAVE GLACIER BLOODMOON VAPOR MONO TOXIC GILDED ABYSS PAPER
  --seed N              同じシードなら同じ対局と同じ会話
  --move-interval SEC   1 手の間隔（既定 1.0 秒）
  --result-pause SEC    終局後に結果を見せる時間（既定 3 秒）
  --version             版を出して終わる

端末は 75x22 以上。93x30 以上で大きな盤になる。

ライセンス: MIT（同梱の LICENSE）
ソース: https://github.com/hideyukiMORI/nene-reversi
