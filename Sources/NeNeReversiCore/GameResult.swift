/// 1 局の結果。終局の局面の石の数で決める（FR-04）。
public enum GameResult: Sendable, Hashable, CaseIterable {
    case blackWins
    case whiteWins
    case draw
}
