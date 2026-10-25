import NeNeReversiCore

/// 盤の置き場所と升の大きさ。升は市松に塗り、石は升とは別の色で塗った空白のブロックで描く（FR-07・ADR 0007）。
struct BoardFrame: Sendable, Hashable {
    let column: Int
    let row: Int
    let squareWidth: Int
    let squareHeight: Int
    /// 升の各行で石を塗る範囲（升の行の数だけ）。
    let disc: [DiscSpan]
    /// 直前の手の升で `[` と `]` を書く行。
    let markerLines: [Int]

    /// 1 升 6 桁 × 3 行。石は 2・4・2 桁の 3 行で丸く見せる。
    static let large = BoardFrame(
        column: 4, row: 2, squareWidth: 6, squareHeight: 3,
        disc: [DiscSpan(offset: 2, width: 2), DiscSpan(offset: 1, width: 4), DiscSpan(offset: 2, width: 2)],
        markerLines: [1]
    )

    /// 1 升 4 桁 × 2 行。石は 2 桁 × 2 行。
    static let compact = BoardFrame(
        column: 3, row: 2, squareWidth: 4, squareHeight: 2,
        disc: [DiscSpan(offset: 1, width: 2), DiscSpan(offset: 1, width: 2)],
        markerLines: [0, 1]
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
            if let disc = look.disc, line < self.disc.count {
                let span = self.disc[line]
                grid.paint(column: left + span.offset, row: top + line, width: span.width, color: theme.color(of: disc))
            }
        }
        guard look.hot else {
            return
        }
        let bracket = CellColors(foreground: theme.accent, background: background)
        for line in markerLines {
            grid.write("[", column: left, row: top + line, colors: bracket)
            grid.write("]", column: left + squareWidth - 1, row: top + line, colors: bracket)
        }
    }
}
