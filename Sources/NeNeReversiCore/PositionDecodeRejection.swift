/// 局面の文字列表現を読めなかった理由。
public enum PositionDecodeRejection: Sendable, Hashable {
    /// 空白 1 つで区切った欄が 2 つ（盤と手番）でない。
    case fieldCount
    /// 盤の欄が 64 文字でない。
    case boardLength
    /// 盤の欄に `X`・`O`・`-` 以外の文字がある。
    case boardCharacter
    /// 手番の欄が `X` でも `O` でもない。
    case sideToMove
}
