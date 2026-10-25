import NeNeReversiCore

/// 通算の勝敗（FR-10）。
public struct Tally: Sendable, Hashable {
    public let blackWins: Int
    public let whiteWins: Int
    public let draws: Int

    private init(blackWins: Int, whiteWins: Int, draws: Int) {
        self.blackWins = blackWins
        self.whiteWins = whiteWins
        self.draws = draws
    }

    /// 1 局も終わっていない。
    public static let zero = Tally(blackWins: 0, whiteWins: 0, draws: 0)

    /// 終わった局の数。
    public var finishedGames: Int {
        blackWins + whiteWins + draws
    }

    /// 1 局の結果を足した通算。
    func recording(_ result: GameResult) -> Tally {
        switch result {
        case .blackWins:
            return Tally(blackWins: blackWins + 1, whiteWins: whiteWins, draws: draws)
        case .whiteWins:
            return Tally(blackWins: blackWins, whiteWins: whiteWins + 1, draws: draws)
        case .draw:
            return Tally(blackWins: blackWins, whiteWins: whiteWins, draws: draws + 1)
        }
    }
}
