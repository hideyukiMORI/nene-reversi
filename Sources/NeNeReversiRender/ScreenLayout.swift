import NeNeReversiCore
import NeNeReversiEngine

/// 1 つの配置（大きな盤か縮小版）の各部品の置き場所と描き方。上端に題とシード、左に盤、右に HUD、下端にキーのヘルプ（ADR 0007）。
struct ScreenLayout: Sendable, Hashable {
    let board: BoardFrame
    let hudColumn: Int
    let hudWidth: Int
    let footerRow: Int

    static let large = ScreenLayout(board: .large, gap: 4, hudWidth: 34)
    static let compact = ScreenLayout(board: .compact, gap: 3, hudWidth: 30)

    private init(board: BoardFrame, gap: Int, hudWidth: Int) {
        self.board = board
        hudColumn = board.column + board.width + gap
        self.hudWidth = hudWidth
        // 盤の下に列の文字が 1 行、その下を 1 行あけてキーのヘルプ
        footerRow = board.row + board.height + 2
    }

    /// この配置がちょうど入る大きさ。
    var size: ScreenSize {
        ScreenSize(columns: hudColumn + hudWidth + 1, rows: footerRow + 1)
    }

    func draw(_ state: ScreenState, into grid: inout Grid) {
        let theme = state.theme
        let game = state.series.game
        let accent = CellColors(foreground: theme.accent, background: theme.ground)
        let dim = CellColors(foreground: theme.dim, background: theme.ground)
        grid.write(Wording.title, column: board.column, row: 0, colors: accent)
        grid.write(Wording.seed(state.seed), column: hudColumn, row: 0, colors: dim)
        board.draw(game.position, last: Self.lastSquare(game), theme: theme, into: &grid)
        let lines = HudPanel.lines(state, height: footerRow - board.row - 1)
        for (offset, line) in lines.enumerated() {
            let colors = CellColors(foreground: line.heading ? theme.accent : theme.text, background: theme.ground)
            grid.write(String(line.text.prefix(hudWidth)), column: hudColumn, row: board.row + offset, colors: colors)
        }
        grid.write(Wording.help, column: board.column, row: footerRow, colors: dim)
    }

    /// 直前の手の升。まだ打っていないか、直前の手がパスなら nil。
    private static func lastSquare(_ game: Game) -> Square? {
        guard case .place(let square) = game.moves.last?.kind else {
            return nil
        }
        return square
    }
}
