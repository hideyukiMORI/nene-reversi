import NeNeReversiEngine

/// 1 画面を描くのに要るすべての値（ARC-011: Render はこれを描くだけ）。
public struct ScreenState: Sendable {
    public let series: GameSeries
    public let theme: Theme
    /// 対局の列のシード（画面に出す）。
    public let seed: UInt64
    /// 終局後の秒読み。続いている局では nil。
    public let countdown: Countdown?

    /// 組を作る。
    public init(series: GameSeries, theme: Theme, seed: UInt64, countdown: Countdown?) {
        self.series = series
        self.theme = theme
        self.seed = seed
        self.countdown = countdown
    }
}
