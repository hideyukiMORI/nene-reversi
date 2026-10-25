/// 局面を次の局面へ進める 1 回の手。パスも手の 1 つ（ADR 0005）。
///
/// init は private で、Core の外の手は `Position.legalMoves()` からしか得られない。
public struct Move: Sendable, Hashable {
    public let kind: MoveKind

    private init(kind: MoveKind) {
        self.kind = kind
    }

    /// 升に打つ手。合法かどうかは作る側（`Position.legalMoves()`）が保証する。
    static func place(_ square: Square) -> Move {
        Move(kind: .place(square))
    }

    /// パス。
    static let pass = Move(kind: .pass)
}
