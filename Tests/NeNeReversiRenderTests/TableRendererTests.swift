import NeNeReversiCore
import NeNeReversiEngine
import Testing

@testable import NeNeReversiRender

/// 1 画面分の格子（FR-07・FR-10・FR-15・ADR 0007）。
struct TableRendererTests {
    static let theme = Theme.standard

    /// シード 3 で `steps` 歩進めた列の画面。
    static func render(steps: Int, size: ScreenSize, countdown: Countdown? = nil) -> (GameSeries, Grid) {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first
        for _ in 0..<steps {
            series = series.advanced(using: &generator)
        }
        let state = ScreenState(series: series, theme: theme, seed: 3, countdown: countdown)
        return (series, TableRenderer.render(state, size: size))
    }

    static func cells(_ grid: Grid) -> [Cell] {
        (0..<grid.size.rows).flatMap { row in (0..<grid.size.columns).map { grid[$0, row] } }
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    @Test(arguments: [TableRenderer.largeSize, TableRenderer.minimumSize])
    func discCellsAreBlankBlocksInTheDiscColor(_ size: ScreenSize) {
        let (series, grid) = Self.render(steps: 20, size: size)
        let perDisc = size == TableRenderer.largeSize ? 8 : 4
        for disc in Disc.allCases {
            let painted = Self.cells(grid).filter { $0.background == Self.theme.color(of: disc) }
            #expect(painted.allSatisfy { $0.character == " " })
            #expect(painted.count == series.game.position.count(of: disc) * perDisc)
        }
    }

    /// 画面の文字はすべて ASCII（1 文字 1 桁の前提・石に Emoji の文字を使わない）。
    @Test func everyCharacterIsASCII() {
        let (_, grid) = Self.render(steps: 30, size: TableRenderer.largeSize)
        #expect(Self.cells(grid).allSatisfy { $0.character.isASCII })
    }

    @Test func lastMoveIsBracketed() throws {
        let (series, grid) = Self.render(steps: 5, size: TableRenderer.largeSize)
        guard case .place(let square) = try #require(series.game.moves.last).kind else {
            Issue.record("直前の手がパス")
            return
        }
        let frame = BoardFrame.large
        let left = frame.column + square.column * frame.squareWidth
        let middle = frame.row + square.row * frame.squareHeight + 1
        #expect(grid[left, middle].character == "[")
        #expect(grid[left + frame.squareWidth - 1, middle].character == "]")
        #expect(Self.cells(grid).filter { $0.character == "[" }.count == 1)
    }

    @Test func hudShowsTheGameTheTurnAndTheDiscCounts() {
        let (series, grid) = Self.render(steps: 1, size: TableRenderer.largeSize)
        let text = Self.text(grid)
        #expect(text.contains("GAME   001"))
        #expect(text.contains("TURN   WHITE"))
        let position = series.game.position
        #expect(text.contains("DISCS  BLACK 0\(position.count(of: .black))  WHITE 0\(position.count(of: .white))"))
        #expect(text.contains("Q QUIT"))
        #expect(text.contains("SEED 0x0000000000000003"))
    }

    @Test func finishedGameShowsTheResultAndTheCountdown() {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.first
        while case .ongoing = series.game.status {
            series = series.advanced(using: &generator)
        }
        let state = ScreenState(
            series: series, theme: Self.theme, seed: 3, countdown: Countdown(remaining: 2, total: 3))
        let text = Self.text(TableRenderer.render(state, size: TableRenderer.largeSize))
        #expect(text.contains("RESULT"))
        #expect(text.contains("NEXT GAME IN 2"))
        #expect(text.contains("TURN   OVER"))
    }

    @Test func tooSmallScreenShowsOneLineWithTheNeededSize() {
        let small = ScreenSize(columns: TableRenderer.minimumSize.columns - 1, rows: TableRenderer.minimumSize.rows)
        let (_, grid) = Self.render(steps: 3, size: small)
        let need = TableRenderer.minimumSize
        #expect(Self.text(grid).hasPrefix("TERMINAL TOO SMALL: NEED \(need.columns)x\(need.rows)"))
        #expect(Self.cells(grid).allSatisfy { $0.background == Self.theme.ground })
    }

    @Test func emptyScreenDoesNotCrash() {
        let (_, grid) = Self.render(steps: 3, size: ScreenSize(columns: 0, rows: 0))
        #expect(grid.size == ScreenSize(columns: 0, rows: 0))
    }

    /// 文字のあるセルは前景と背景が 4.5:1 以上（WCAG）。石は升に対して 3:1 以上（文字でない図形の基準）。
    @Test(arguments: [TableRenderer.largeSize, TableRenderer.minimumSize])
    func textAndDiscsHaveEnoughContrast(_ size: ScreenSize) {
        let (_, grid) = Self.render(steps: 20, size: size)
        for cell in Self.cells(grid) where cell.character != " " {
            #expect(Contrast.ratio(cell.foreground, cell.background) >= 4.5, "\(cell)")
        }
        for disc in Disc.allCases {
            for square in [Self.theme.lightSquare, Self.theme.darkSquare] {
                #expect(Contrast.ratio(Self.theme.color(of: disc), square) >= 3)
            }
        }
    }

    @Test func notationNamesSquaresWithRowOneAtTheTop() {
        #expect(Square.at(column: 3, row: 2).map(MoveNotation.name) == "d3")
        #expect(Square.at(column: 7, row: 7).map(MoveNotation.name) == "h8")
    }
}
