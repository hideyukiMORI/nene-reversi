/// 起動オプション（ARC-008: 境界で 1 度だけ検証し、型に変えてから中へ渡す）。
///
/// `--seed <0 以上の整数>` / `--move-interval <秒>` / `--result-pause <秒>`。
/// 移植元: NeNe Gambit `Sources/nene-gambit/LaunchOptions.swift`（コミット 64b82ec）。字形とテーマの選択は落とした（テーマは手順 5）。
struct LaunchOptions {
    /// 乱数のシード。与えられなければ nil（起動時にシステムの乱数から決める）。
    let seed: UInt64?
    /// 1 手を打つ間隔（FR-11 の初期値は 1.0 秒）。
    let moveInterval: Duration
    /// 終局後に結果を見せる時間（FR-11 の初期値は 3 秒）。
    let resultPause: Duration

    static let defaults = LaunchOptions(seed: nil, moveInterval: .milliseconds(1000), resultPause: .seconds(3))

    /// 起動オプションを読む（プログラム名を除いた引数）。
    static func parse(_ arguments: [String]) -> LaunchParsing {
        var options = defaults
        var rest = arguments[...]
        while let name = rest.popFirst() {
            guard let value = rest.popFirst() else {
                return .rejected("\(name) に値が無い")
            }
            guard let next = options.setting(name, value) else {
                return .rejected("読めないオプション: \(name) \(value)（--seed / --move-interval / --result-pause）")
            }
            options = next
        }
        return .parsed(options)
    }

    /// 文字列で分岐するので `switch` ではなく `if` で書く（SWF-002: 全捕捉を書かない）。
    private func setting(_ name: String, _ value: String) -> LaunchOptions? {
        if name == "--seed" {
            return UInt64(value).map { LaunchOptions(seed: $0, moveInterval: moveInterval, resultPause: resultPause) }
        }
        if name == "--move-interval" {
            return Self.duration(value).map { LaunchOptions(seed: seed, moveInterval: $0, resultPause: resultPause) }
        }
        if name == "--result-pause" {
            return Self.duration(value).map { LaunchOptions(seed: seed, moveInterval: moveInterval, resultPause: $0) }
        }
        return nil
    }

    /// 0.05〜60 秒の秒数。
    private static func duration(_ text: String) -> Duration? {
        guard let seconds = Double(text), (0.05...60).contains(seconds) else {
            return nil
        }
        return .milliseconds(Int((seconds * 1000).rounded()))
    }
}
