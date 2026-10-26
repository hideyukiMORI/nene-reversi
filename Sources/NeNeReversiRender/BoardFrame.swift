import NeNeReversiCore

/// 盤の置き場所と升の大きさ。升は市松に塗り、石は升とは別の色で塗った空白のブロックで描く（FR-07・ADR 0007）。
struct BoardFrame: Sendable, Hashable {
    let column: Int
    let row: Int
    let squareWidth: Int
    let squareHeight: Int
    /// 石を塗る範囲。升の最上行は塗らない（縦に並んだ石が接して 1 本の柱に見えないように・ADR 0009）。
    /// 直前の手の `[` と `]` は、石を塗る行の左右の端に書く。
    let disc: [DiscSpan]

    /// 1 升 6 桁 × 3 行。石は下の 2 行を 4 桁ずつ塗る。
    static let large = BoardFrame(
        column: 4, row: 2, squareWidth: 6, squareHeight: 3,
        disc: [DiscSpan(line: 1, offset: 1, width: 4), DiscSpan(line: 2, offset: 1, width: 4)]
    )

    /// 1 升 4 桁 × 2 行。石は下の 1 行を 2 桁塗る。
    static let compact = BoardFrame(
        column: 3, row: 2, squareWidth: 4, squareHeight: 2,
        disc: [DiscSpan(line: 1, offset: 1, width: 2)]
    )

    var width: Int {
        8 * squareWidth
    }

    var height: Int {
        8 * squareHeight
    }

    /// 盤と、行の番号（左）・列の文字（下）を描く。
    func draw(_ position: Position, last: Square?, theme: Theme, into grid: inout Grid) {
        for square in Square.all {
            let look = SquareLook(disc: position.disc(at: square), hot: square == last)
            drawSquare(square, look, theme: theme, into: &grid)
        }
        let labels = CellColors(foreground: theme.dim, background: theme.ground)
        for square in Square.all where square.column == 0 {
            let name = MoveNotation.name(of: square)
            let top = row + square.row * squareHeight + squareHeight / 2
            grid.write(String(name.suffix(1)), column: column - 2, row: top, colors: labels)
        }
        for square in Square.all where square.row == 0 {
            let name = MoveNotation.name(of: square)
            let left = column + square.column * squareWidth + squareWidth / 2
            grid.write(String(name.prefix(1)), column: left, row: row + height, colors: labels)
        }
    }

    private func drawSquare(_ square: Square, _ look: SquareLook, theme: Theme, into grid: inout Grid) {
        let background = (square.column + square.row) % 2 == 0 ? theme.lightSquare : theme.darkSquare
        let left = column + square.column * squareWidth
        let top = row + square.row * squareHeight
        for line in 0..<squareHeight {
            grid.paint(column: left, row: top + line, width: squareWidth, color: background)
        }
        if let disc = look.disc {
            for span in self.disc {
                grid.paint(
                    column: left + span.offset, row: top + span.line, width: span.width, color: theme.color(of: disc))
            }
        }
        guard look.hot else {
            return
        }
        let bracket = CellColors(foreground: theme.marker, background: background)
        for span in disc {
            grid.write("[", column: left, row: top + span.line, colors: bracket)
            grid.write("]", column: left + squareWidth - 1, row: top + span.line, colors: bracket)
        }
    }
}
