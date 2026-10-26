import NeNeReversiCore
import NeNeReversiEngine

/// HUD のパネルの各段（MATCH・DISCS・SCORE・LOG・RESULT）の行を作る（FR-10）。
///
/// 段の形は NeNe Gambit の `HudSections`（コミット 64b82ec）にならい、DISCS（いまの石の数・Q6）を足した。
struct HudSections: Sendable {
    let state: ScreenState
    let panel: Panel

    private var theme: Theme {
        state.options.theme
    }

    private var game: Game {
        state.series.game
    }

    /// MATCH: 局の番号・黒白の性格・手番と手数。
    func match() -> [[Segment]] {
        let series = state.series
        return [
            panel.header(Wording.match, title: theme.accent, frame: theme.frame, first: true),
            row([Segment(Wording.gameLabel, theme.dim), Segment(Wording.gameNumber(series.gameNumber), theme.text)]),
            row([Segment(Wording.blackLabel, theme.dim), Segment(series.players.black.handle, theme.blackDisc)]),
            row([Segment(Wording.whiteLabel, theme.dim), Segment(series.players.white.handle, theme.whiteDisc)]),
            row([Segment(Wording.turnLabel, theme.dim)] + turn()),
        ]
    }

    /// 手番（終局していれば `--`）と、打った手の数。
    func turn() -> [Segment] {
        let side: Segment
        switch game.status {
        case .ongoing:
            let mover = game.position.sideToMove
            side = Segment(Wording.side(mover), theme.color(of: mover))
        case .finished:
            side = Segment(Wording.noTurn, theme.dim)
        }
        return [side, Segment(Wording.moveNumber(game.moves.count), theme.dim)]
    }

    /// DISCS: いまの石の数の棒（盤上の石の合計に対する割合）。
    func discs() -> [[Segment]] {
        let position = game.position
        let total = position.count(of: .black) + position.count(of: .white)
        return [panel.header(Wording.discs, title: theme.accent, frame: theme.frame, first: false)]
            + Disc.allCases.map { disc in
                barRow(
                    Segment(Wording.tag(disc), theme.color(of: disc)),
                    Fraction(value: position.count(of: disc), total: total),
                    fill: theme.color(of: disc))
            }
    }

    /// SCORE: 黒勝ち・白勝ち・引き分けの棒（通算の局数に対する割合）。
    func score() -> [[Segment]] {
        let tally = state.series.tally
        let total = tally.finishedGames
        return [
            panel.header(Wording.score, title: theme.accent, frame: theme.frame, first: false),
            barRow(
                Segment(Wording.tag(.black), theme.blackDisc), Fraction(value: tally.blackWins, total: total),
                fill: theme.accent),
            barRow(
                Segment(Wording.tag(.white), theme.whiteDisc), Fraction(value: tally.whiteWins, total: total),
                fill: theme.accentAlt),
            barRow(Segment(Wording.drawTag, theme.dim), Fraction(value: tally.draws, total: total), fill: theme.dim),
        ]
    }

    private func barRow(_ tag: Segment, _ share: Fraction, fill: Rgb) -> [Segment] {
        row(
            [tag] + panel.bar(share, cells: 20, fill: fill, frame: theme.frame)
                + [Segment("  " + Wording.padded(share.value, width: 2), theme.text)])
    }

    /// LOG: 直近の手を `count` 行（足りない分は空の行）。
    func log(rows count: Int) -> [[Segment]] {
        let cursor = Segment(panel.glyphs.cursor, theme.accent)
        let lines = MoveLogRow.recent(game, count: count).map { entry -> [Segment] in
            let black = entry.cursor == .black ? [cursor] : [Segment(entry.black, theme.blackDisc)]
            let gap = String(repeating: " ", count: max(9 - (entry.cursor == .black ? 1 : entry.black.count), 1))
            let white = entry.cursor == .white ? [cursor] : [Segment(entry.white, theme.whiteDisc)]
            return row([Segment(entry.number + "  ", theme.dim)] + black + [Segment(gap, theme.dim)] + white)
        }
        let empty = Array(repeating: row([]), count: max(count - lines.count, 0))
        return [panel.header(Wording.log, title: theme.accent, frame: theme.frame, first: false)] + lines + empty
    }

    /// RESULT: 勝敗と石の数・理由・次の局までの秒読み。終局していなければ空。
    func result() -> [[Segment]] {
        guard case .finished(let outcome) = game.status else {
            return []
        }
        let position = game.position
        let black = position.count(of: .black)
        let white = position.count(of: .white)
        let frame = theme.accentAlt
        var rows = [
            panel.header(Wording.result, title: theme.accentAlt, frame: frame, first: false),
            panel.row([Segment(Wording.headline(outcome, black: black, white: white), theme.accentAlt)], frame: frame),
            panel.row(
                [
                    Segment(Wording.reason(boardFull: black + white == 64), theme.text),
                    Segment(Wording.moveNumber(game.moves.count), theme.dim),
                ],
                frame: frame),
        ]
        if let countdown = state.countdown {
            let share = Fraction(value: countdown.remaining, total: countdown.total)
            let bar = panel.bar(share, cells: 15, fill: theme.accent, frame: theme.frame)
            let seconds = Segment("  " + Wording.seconds(countdown.remaining), theme.accent)
            rows.append(panel.row([Segment(Wording.nextGame, theme.dim)] + bar + [seconds], frame: frame))
        } else {
            rows.append(panel.row([], frame: frame))
        }
        return rows
    }

    /// 縮小版の MATCH（題に局の番号・1 行に黒白の性格・手番・石の数・通算）。
    func compactMatch() -> [[Segment]] {
        let series = state.series
        let tally = series.tally
        let position = game.position
        let title = Wording.match + " " + Wording.gameNumber(series.gameNumber)
        return [
            panel.header(title, title: theme.accent, frame: theme.frame, first: true),
            row([
                Segment("B ", theme.dim), Segment(series.players.black.handle, theme.blackDisc),
                Segment("  vs  W ", theme.dim), Segment(series.players.white.handle, theme.whiteDisc),
            ]),
            row([Segment("TURN ", theme.dim)] + turn()),
            row([
                Segment(Wording.discs + "  ", theme.dim),
                Segment(
                    Wording.tag(.black) + Wording.padded(position.count(of: .black), width: 2) + "  ", theme.blackDisc),
                Segment(Wording.tag(.white) + Wording.padded(position.count(of: .white), width: 2), theme.whiteDisc),
            ]),
            row([
                Segment(Wording.score + "  ", theme.dim),
                Segment(Wording.tag(.black) + Wording.padded(tally.blackWins, width: 2) + "  ", theme.blackDisc),
                Segment(Wording.tag(.white) + Wording.padded(tally.whiteWins, width: 2) + "  ", theme.whiteDisc),
                Segment(Wording.drawTag + Wording.padded(tally.draws, width: 2), theme.dim),
            ]),
        ]
    }

    func row(_ content: [Segment]) -> [Segment] {
        panel.row(content, frame: theme.frame)
    }
}
