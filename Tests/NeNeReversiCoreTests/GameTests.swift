import Testing

@testable import NeNeReversiCore

/// 1 局の経過（ARC-004）。
struct GameTests {
    @Test func playingRecordsTheMoveAndAdvancesThePosition() throws {
        let game = Game.starting(from: .initial)
        let move = try #require(game.legalMoves().first)
        let next = game.playing(move)
        #expect(next.moves == [move])
        #expect(next.position == Position.initial.applying(move))
        #expect(game.moves.isEmpty)
    }

    /// パスも手の 1 つとして記録する。
    @Test func passIsRecordedAsAMove() throws {
        let outcome = PositionCodec.decode("OX" + String(repeating: "-", count: 62) + " X")
        guard case .decoded(let position) = outcome else {
            Issue.record("読めない: \(outcome)")
            return
        }
        let game = Game.starting(from: position)
        let pass = try #require(game.legalMoves().first)
        #expect(pass.kind == .pass)
        #expect(game.playing(pass).moves.map(\.kind) == [.pass])
        #expect(game.playing(pass).status == .ongoing)
    }

    @Test func gameEndsWhenNeitherSideCanMove() {
        var game = Game.starting(from: .initial)
        while let move = game.legalMoves().last {
            game = game.playing(move)
        }
        #expect(game.status != .ongoing)
        #expect(game.moves.count >= 9)
    }
}
