/// 合法手の有無から決まる局面の状態（FR-04）。
public enum PositionStatus: Sendable, Hashable {
    /// どちらかに合法手がある（手番の側に無ければ、手番の側はパスする）。
    case ongoing
    /// 両者とも合法手が無い（盤が埋まった場合を含む）。
    case finished(GameResult)
}
