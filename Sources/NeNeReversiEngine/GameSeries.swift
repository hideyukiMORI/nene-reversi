import NeNeReversiCore

/// 対局の列: いまの局・何局目か・通算の勝敗・その局の黒白の性格・発言（ARC-004）。
///
/// 値型で、1 歩進めると新しい値を返す。時計を知らない（「何秒に 1 歩進めるか」は合成ルートが決める）。
/// 乱数は引数から受け取るので、同じシードの乱数源からは同じ対局の列が出る（FR-05 の決定性）。
public struct GameSeries: Sendable, Hashable {
    public let game: Game
    /// 何局目か（1 から）。
    public let gameNumber: Int
    /// 終わった局の通算。いまの局が終わった時点で数える。
    public let tally: Tally
    /// その局の黒と白の性格。
    public let players: Players
    /// 対局中の発言（ADR 0012）。
    public let banter: Banter

    private init(game: Game, gameNumber: Int, tally: Tally, players: Players, banter: Banter) {
        self.game = game
        self.gameNumber = gameNumber
        self.tally = tally
        self.players = players
        self.banter = banter
    }

    /// 初期局面の第 1 局から始まる列。性格の組と最初のひと言を乱数で決める。
    public static func starting(using generator: inout some RandomNumberGenerator) -> GameSeries {
        starting(with: .drawn(using: &generator), using: &generator)
    }

    /// 決まった組で始まる列（テストと計測のため）。次の局からは乱数で組む。
    static func starting(with players: Players, using generator: inout some RandomNumberGenerator) -> GameSeries {
        GameSeries(
            game: .starting(from: .initial), gameNumber: 1, tally: .zero, players: players,
            banter: Banter.silent.starting(players, using: &generator))
    }

    /// 1 歩進める。いまの局が続いていれば手番の側の性格が 1 手打ち、終わっていれば次の局を初期局面から始める。
    public func advanced(using generator: inout some RandomNumberGenerator) -> GameSeries {
        guard case .ongoing = game.status else {
            return nextGame(using: &generator)
        }
        let mover = players.persona(for: game.position.sideToMove)
        guard let move = mover.choose(in: game, using: &generator) else {
            preconditionFailure("続いている局で合法手が無い")
        }
        let next = game.playing(move)
        let facts = MoveFacts(before: game.position, move: move, after: next.position)
        let said = banter.reacting(to: facts, status: next.status, players: players, using: &generator)
        switch next.status {
        case .ongoing:
            return GameSeries(game: next, gameNumber: gameNumber, tally: tally, players: players, banter: said)
        case .finished(let result):
            return GameSeries(
                game: next, gameNumber: gameNumber, tally: tally.recording(result), players: players, banter: said)
        }
    }

    /// 次の局を初期局面から始める。性格の組を乱数で選び直し、始まりのひと言を言う。
    private func nextGame(using generator: inout some RandomNumberGenerator) -> GameSeries {
        let players = Players.drawn(using: &generator)
        return GameSeries(
            game: .starting(from: .initial), gameNumber: gameNumber + 1, tally: tally, players: players,
            banter: banter.starting(players, using: &generator))
    }
}
