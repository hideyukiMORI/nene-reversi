import NeNeReversiCore
import Testing

@testable import NeNeReversiEngine

/// 評価と探索（FR-03・FR-06・ADR 0010）。
struct SearchTests {
    static func position(_ text: String) throws -> Position {
        let outcome = PositionCodec.decode(text)
        guard case .decoded(let position) = outcome else {
            Issue.record("読めない: \(outcome)")
            return try #require(nil as Position?)
        }
        return position
    }

    /// シードで決まるランダムな手で `moves` 手進めた局（終局したらそこで止める）。
    static func randomGame(seed: UInt64, moves: Int) -> Game {
        var generator = SplitMix64(seed: seed)
        var game = Game.starting(from: .initial)
        for _ in 0..<moves {
            guard let move = game.legalMoves().randomElement(using: &generator) else {
                break
            }
            game = game.playing(move)
        }
        return game
    }

    /// 探索が返す手は必ず合法手の中にある（2-2 の不変条件）。4 名それぞれ、序盤・中盤・終盤・パスしかない局面で。
    @Test(arguments: Persona.allCases)
    func everyPersonaPlaysOnlyLegalMoves(_ persona: Persona) throws {
        var generator = SplitMix64(seed: 17)
        let pass = Game.starting(from: try Self.position("OX" + String(repeating: "-", count: 62) + " X"))
        for game in [
            Game.starting(from: .initial), Self.randomGame(seed: 1, moves: 24), Self.randomGame(seed: 2, moves: 52),
            pass,
        ] {
            let move = try #require(persona.choose(in: game, using: &generator))
            #expect(game.legalMoves().contains(move))
        }
    }

    /// 升の値は、角 > 辺 > 内側 > 空いた角の隣。角が埋まると、その隣は危険でなくなり辺の値になる（4 名とも）。
    @Test(arguments: Persona.allCases)
    func squareValuesFollowTheCornerRule(_ persona: Persona) throws {
        let weights = persona.profile.weights
        let empty = try Self.position(String(repeating: "-", count: 64) + " X")
        let a1 = try #require(Square.at(column: 0, row: 0))
        let b1 = try #require(Square.at(column: 1, row: 0))
        let b2 = try #require(Square.at(column: 1, row: 1))
        let d1 = try #require(Square.at(column: 3, row: 0))
        let d4 = try #require(Square.at(column: 3, row: 3))
        let corner = Evaluator.squareValue(a1, in: empty, weights: weights)
        let edge = Evaluator.squareValue(d1, in: empty, weights: weights)
        let inner = Evaluator.squareValue(d4, in: empty, weights: weights)
        #expect(corner > edge && edge > inner)
        #expect(Evaluator.squareValue(b2, in: empty, weights: weights) < inner)
        #expect(Evaluator.squareValue(b1, in: empty, weights: weights) < inner)
        let taken = try Self.position("X" + String(repeating: "-", count: 63) + " X")
        #expect(Evaluator.squareValue(b1, in: taken, weights: weights) == edge)
        #expect(Evaluator.squareValue(b2, in: taken, weights: weights) == edge)
    }

    /// 空き升が少なく最後まで読める局面では、勝ち・引き分け・負けを読み違えない（素朴に全部読んだ結果と比べる）。
    @Test(arguments: [11, 12, 13, 14, 15])
    func endgameChoiceKeepsTheBestOutcome(_ seed: UInt64) throws {
        let game = Self.randomGame(seed: seed, moves: 56)
        try #require(game.status == .ongoing)
        var generator = SplitMix64(seed: seed)
        let move = try #require(Persona.corner.choose(in: game, using: &generator))
        let best = game.legalMoves().map { -Self.exact(game.position.applying($0)) }.max() ?? 0
        let chosen = -Self.exact(game.position.applying(move))
        #expect(chosen.signum() == best.signum(), "選んだ手 \(chosen)・最善 \(best)")
    }

    /// 手番の側から見た終局の石差（全部読む）。
    static func exact(_ position: Position) -> Int {
        let moves = position.legalMoves()
        guard !moves.isEmpty else {
            return position.count(of: position.sideToMove) - position.count(of: position.sideToMove.opponent)
        }
        return moves.map { -exact(position.applying($0)) }.max() ?? 0
    }

    /// 同じシードの乱数源からは同じ手が出る。
    @Test(arguments: Persona.allCases)
    func sameSeedGivesTheSameMove(_ persona: Persona) throws {
        let game = Self.randomGame(seed: 9, moves: 20)
        var first = SplitMix64(seed: 4)
        var second = SplitMix64(seed: 4)
        #expect(persona.choose(in: game, using: &first) == persona.choose(in: game, using: &second))
    }
}
