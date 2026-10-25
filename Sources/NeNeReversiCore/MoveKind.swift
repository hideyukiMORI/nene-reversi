/// 手の中身。升に石を打つか、パスか（ADR 0005）。
public enum MoveKind: Sendable, Hashable {
    /// 升に石を打つ。
    case place(Square)
    /// 合法手が無いので打たずに手番を渡す。
    case pass
}
