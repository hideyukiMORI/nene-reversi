/// 1 局の経過: いまの局面と、初期局面から打った手（パスを含む）の列（ARC-004）。
///
/// 手を打つと新しい値を返す。「パスか」「終局したか」は局面の `legalMoves()` から決まる（ADR 0005）。
public struct Game: Sendable, Hashable {
    public let position: Position
    /// 打った手の列（古い順）。
    public let moves: [Move]

    private init(position: Position, moves: [Move]) {
        self.position = position
        self.moves = moves
    }

    /// 局面から始まる 1 局。
    public static func starting(from position: Position) -> Game {
        Game(position: position, moves: [])
    }

    /// 局の状態。
    public var status: PositionStatus {
        position.status
    }

    /// いまの局面で合法な手。
    public func legalMoves() -> [Move] {
        position.legalMoves()
    }

    /// 手を打った次の局。手はいまの局面の `legalMoves()` から得たものに限る。
    public func playing(_ move: Move) -> Game {
        Game(position: position.applying(move), moves: moves + [move])
    }
}
