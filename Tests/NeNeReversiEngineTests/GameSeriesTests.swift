import NeNeReversiCore
import Testing

@testable import NeNeReversiEngine

/// 対局の列（FR-04・FR-05 の決定性）。
struct GameSeriesTests {
    /// 局が 3 つ終わるまで進めた列の、各局の棋譜。
    static func records(seed: UInt64) -> [[Move]] {
        var generator = SplitMix64(seed: seed)
        var series = GameSeries.first
        var finished: [[Move]] = []
        while finished.count < 3 {
            let next = series.advanced(using: &generator)
            if next.gameNumber != series.gameNumber {
                finished.append(series.game.moves)
            }
            series = next
        }
        return finished
    }

    @Test func sameSeedGivesTheSameGames() {
        #expect(Self.records(seed: 42) == Self.records(seed: 42))
    }

    @Test func differentSeedsGiveDifferentGames() {
        #expect(Self.records(seed: 1) != Self.records(seed: 2))
    }

    @Test func everyMoveIsLegalAndFinishedGamesAreCounted() {
        var generator = SplitMix64(seed: 7)
        var series = GameSeries.first
        while series.gameNumber <= 3 {
            let next = series.advanced(using: &generator)
            if next.gameNumber == series.gameNumber {
                #expect(next.game.moves.dropLast() == series.game.moves[...])
                if let move = next.game.moves.last {
                    #expect(series.game.legalMoves().contains(move))
                }
            } else {
                #expect(series.game.status != .ongoing)
                #expect(next.game == Game.starting(from: .initial))
                #expect(next.tally.finishedGames == series.gameNumber)
            }
            series = next
        }
        #expect(series.tally.finishedGames == 3)
    }
}
