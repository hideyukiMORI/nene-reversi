import NeNeReversiCore
import NeNeReversiEngine

/// 1 つの配置（大きな盤か縮小版）の各部品の置き場所と描き方（ADR 0011）。
///
/// 上端に題の帯、左に盤（行の番号は左、列の文字は下）、右に罫線の枠の HUD、盤の下に COMMS の 2 行、下端にキーの帯。
struct ScreenLayout: Sendable, Hashable {
    let board: BoardFrame
    let hudColumn: Int
    let hudWidth: Int
    let hudRows: Int
    let commsRow: Int
    let footerRow: Int
    let isCompact: Bool

    /// 大きな盤（1 升 6 桁 × 3 行）と MATCH / DISCS / SCORE / LOG / RESULT の HUD。
    static let large = ScreenLayout(board: .large, hudWidth: 37, isCompact: false)
    /// 縮小版（1 升 4 桁 × 2 行）と詰めた HUD。
    static let compact = ScreenLayout(board: .compact, hudWidth: 35, isCompact: true)

    private init(board: BoardFrame, hudWidth: Int, isCompact: Bool) {
        self.board = board
        hudColumn = board.column + board.width + 4
        self.hudWidth = hudWidth
        hudRows = board.height
        // 盤の下に列の文字が 1 行、その下に COMMS の 2 行、その下にキーの帯
        commsRow = board.row + board.height + 1
        footerRow = commsRow + 2
        self.isCompact = isCompact
    }

    /// この配置がちょうど入る大きさ。
    var size: ScreenSize {
        ScreenSize(columns: hudColumn + hudWidth + 1, rows: footerRow + 1)
    }

    func draw(_ state: ScreenState, into grid: inout Grid) {
        let glyphs = FrameGlyphs.of(state.options.traits.frame)
        let theme = state.options.theme
        let game = state.series.game
        grid.write(
            String(repeating: " ", count: grid.size.columns), column: 0, row: 0,
            colors: CellColors(foreground: theme.text, background: theme.panel))
        grid.write(ScreenChrome.header(state, glyphs: glyphs), column: 0, row: 0, background: theme.panel)
        board.draw(game.position, last: Self.lastSquare(game), theme: theme, into: &grid)
        for (offset, line) in hudLines(state, glyphs: glyphs).prefix(hudRows).enumerated() {
            grid.write(line, column: hudColumn, row: board.row + offset, background: theme.ground)
        }
        grid.write(
            String(repeating: " ", count: grid.size.columns), column: 0, row: footerRow,
            colors: CellColors(foreground: theme.text, background: theme.panel))
        grid.write(
            ScreenChrome.footer(state, glyphs: glyphs, compact: isCompact), column: 0, row: footerRow,
            background: theme.panel)
    }

    private func hudLines(_ state: ScreenState, glyphs: FrameGlyphs) -> [[Segment]] {
        let sections = HudSections(state: state, panel: Panel(width: hudWidth, glyphs: glyphs))
        let result = sections.result()
        let theme = state.options.theme
        let bottom = sections.panel.footer(frame: result.isEmpty ? theme.frame : theme.accentAlt)
        if isCompact {
            let top = sections.compactMatch()
            let middle = result.isEmpty ? sections.log(rows: hudRows - top.count - 2) : result
            return top + middle + [bottom]
        }
        let top = sections.match() + sections.discs() + sections.score()
        let logRows = hudRows - top.count - result.count - 2
        return top + sections.log(rows: logRows) + result + [bottom]
    }

    /// 直前の手の升。まだ打っていないか、直前の手がパスなら nil。
    private static func lastSquare(_ game: Game) -> Square? {
        guard case .place(let square) = game.moves.last?.kind else {
            return nil
        }
        return square
    }
}
