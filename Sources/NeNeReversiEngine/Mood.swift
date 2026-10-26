/// 発言のときの気分。
public enum Mood: Sendable, Hashable, CaseIterable {
    /// 得意げ（たくさん返した・角を取った・パスさせた・勝った）。
    case smug
    /// ふつう（始まり・静かな局面・引き分け）。
    case neutral
    /// 沈んでいる（返された・角を取られた・パスした・負けた）。
    case grim
}
