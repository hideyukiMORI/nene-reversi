import NeNeReversiCore
import NeNeReversiEngine

/// HUD の中身（FR-10）: 局と手番・石の数・通算の勝敗・終局の結果と秒読み・直近の手。
enum HudPanel {
    /// 上から並べる行。直近の手は `height` に収まるだけ（新しい手が下）。
    static func lines(_ state: ScreenState, height: Int) -> [HudLine] {
        let series = state.series
        let position = series.game.position
        let black = position.count(of: .black)
        let white = position.count(of: .white)
        var lines = [
            HudLine(text: Wording.match, heading: true),
            HudLine(text: Wording.game(series.gameNumber), heading: false),
            HudLine(text: Wording.player(.black, series.players.black.handle), heading: false),
            HudLine(text: Wording.player(.white, series.players.white.handle), heading: false),
            HudLine(text: Wording.turn(turn(series.game)), heading: false),
            HudLine(text: Wording.moveCount(series.game.moves.count), heading: false),
            HudLine(text: Wording.discs(black: black, white: white), heading: false),
            HudLine(text: "", heading: false),
            HudLine(text: Wording.score, heading: true),
            HudLine(text: Wording.wins(.black, series.tally.blackWins), heading: false),
            HudLine(text: Wording.wins(.white, series.tally.whiteWins), heading: false),
            HudLine(text: Wording.draws(series.tally.draws), heading: false),
            HudLine(text: "", heading: false),
        ]
        if case .finished(let result) = series.game.status {
            lines.append(HudLine(text: Wording.result, heading: true))
            lines.append(HudLine(text: Wording.outcome(result, black: black, white: white), heading: false))
            if let countdown = state.countdown {
                lines.append(HudLine(text: Wording.nextGame(in: countdown.remaining), heading: false))
            }
            lines.append(HudLine(text: "", heading: false))
        }
        lines.append(HudLine(text: Wording.log, heading: true))
        return lines + log(series.game.moves, room: max(height - lines.count, 0))
    }

    /// 手番の側。終局していれば nil。
    private static func turn(_ game: Game) -> Disc? {
        switch game.status {
        case .ongoing:
            return game.position.sideToMove
        case .finished:
            return nil
        }
    }

    /// 直近の手を `room` 行まで。パスも手なので、手番は黒から 1 手ごとに入れ替わる。
    private static func log(_ moves: [Move], room: Int) -> [HudLine] {
        let first = max(moves.count - room, 0)
        return moves.indices.dropFirst(first).map { index in
            let mover: Disc = index % 2 == 0 ? .black : .white
            let text = Wording.logEntry(number: index + 1, mover: mover, move: MoveNotation.text(of: moves[index]))
            return HudLine(text: text, heading: false)
        }
    }
}
