/// 発言のきっかけになる出来事（話す本人から見た向き・ADR 0012）。
public enum Cue: Sendable, Hashable, CaseIterable {
    case start
    /// 自分が 6 個以上返した。
    case bigFlip
    /// 相手に 6 個以上返された。
    case flipped
    /// 自分が角を取った。
    case corner
    /// 相手に角を取られた。
    case cornerLost
    /// 自分が打てずにパスした。
    case passing
    /// 相手にパスさせた。
    case forcedPass
    /// 静かな手が続いている。
    case idle
    case win
    case lose
    case draw

    /// その出来事を言うときの気分。
    public var mood: Mood {
        switch self {
        case .bigFlip, .corner, .forcedPass, .win:
            return .smug
        case .start, .idle, .draw:
            return .neutral
        case .flipped, .cornerLost, .passing, .lose:
            return .grim
        }
    }
}
