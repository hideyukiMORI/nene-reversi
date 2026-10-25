/// 局面の文字列表現を読んだ結果。
public enum PositionDecodeOutcome: Sendable, Hashable {
    case decoded(Position)
    case rejected(PositionDecodeRejection)
}
