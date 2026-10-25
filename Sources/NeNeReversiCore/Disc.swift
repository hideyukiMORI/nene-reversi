/// 石の色。手番の側もこの型で表す（黒が先手）。
public enum Disc: Sendable, Hashable, CaseIterable {
    case black
    case white

    /// 相手の色。
    public var opponent: Disc {
        switch self {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
}
