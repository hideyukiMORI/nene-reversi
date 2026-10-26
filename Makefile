# 単一ゲート（QLT-001）。ローカルと CI はどちらも `make check` だけを呼ぶ。
# 個別のターゲットは反復中の狭い検査として使ってよいが、完了の定義は `make check` だけである。

BASE ?= origin/main
SWIFTLINT := .tools/swiftlint

.PHONY: check bootstrap tools build test smoke format lint conformance conformance-test commits release

check: tools build format lint conformance conformance-test test smoke commits
	@echo "make check: 緑"

bootstrap: tools
	git config core.hooksPath .githooks

tools:
	eng/install-tools.sh

build:
	eng/swift-strict.sh swift build

# perft の深いところはデバッグ構成では遅いので、テストは release 構成で回す（ADR 0006）。
test:
	eng/swift-strict.sh swift test -c release

# 実行ファイルを疑似端末で動かし、キーと終わり方ごとの端末の復元を見る（FR-08・ADR 0008）。release 構成の実行ファイルを使う
smoke:
	eng/swift-strict.sh swift build -c release --product nene-reversi
	python3 eng/smoke-terminal.py .build/release/nene-reversi

format:
	eng/swift-sources.sh | xargs -0 swift-format lint --strict --configuration .swift-format

lint:
	eng/lint.sh $(SWIFTLINT) --config .swiftlint.yml

conformance:
	python3 eng/conformance.py

conformance-test:
	python3 -m unittest discover -s eng/tests -q

commits:
	python3 eng/validate-commit-message.py --range "$(BASE)..HEAD"

# 配布物を作る唯一の経路（QLT-014・ADR 0013）。完了の定義ではない（make check の代わりにならない）。
release:
	eng/package-release.sh $(TAG)
