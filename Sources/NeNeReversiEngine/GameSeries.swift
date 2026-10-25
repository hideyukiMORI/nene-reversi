import NeNeReversiCore

/// 対局の列: いまの局・何局目か・通算の勝敗（ARC-004）。
///
/// 値型で、1 歩進めると新しい値を返す。時計を知らない（「何秒に 1 歩進めるか」は合成ルートが決める）。
/// 乱数は引数から受け取るので、同じシードの乱数源からは同じ対局の列が出る（FR-05 の決定性）。
/// いまは両者とも合法手からランダムに選ぶ（Phase 3 の手順 2）。評価と探索は手順 4 で入れる。
public struct GameSeries: Sendable, Hashable {
    public let game: Game
    /// 何局目か（1 から）。
    public let gameNumber: Int
    /// 終わった局の通算。いまの局が終わった時点で数える。
    public let tally: Tally

    private init(game: Game, gameNumber: Int, tally: Tally) {
        self.game = game
        self.gameNumber = gameNumber
        self.tally = tally
    }

    /// 初期局面の第 1 局から始まる列。
    public static let first = GameSeries(game: .starting(from: .initial), gameNumber: 1, tally: .zero)

    /// 1 歩進める。いまの局が続いていれば手番の側が 1 手打ち、終わっていれば次の局を初期局面から始める。
    public func advanced(using generator: inout some RandomNumberGenerator) -> GameSeries {
        guard case .ongoing = game.status else {
            return GameSeries(game: .starting(from: .initial), gameNumber: gameNumber + 1, tally: tally)
        }
        guard let move = game.legalMoves().randomElement(using: &generator) else {
            preconditionFailure("続いている局で合法手が無い")
        }
        let next = game.playing(move)
        switch next.status {
        case .ongoing:
            return GameSeries(game: next, gameNumber: gameNumber, tally: tally)
        case .finished(let result):
            return GameSeries(game: next, gameNumber: gameNumber, tally: tally.recording(result))
        }
    }
}
