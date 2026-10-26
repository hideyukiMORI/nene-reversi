import NeNeReversiCore
import NeNeReversiEngine
import Testing

@testable import NeNeReversiRender

/// 1 画面分の格子（FR-07・FR-10・FR-12・FR-15・FR-16・ADR 0007・0009・0011）。
struct TableRendererTests {
    static let boxed = TerminalTraits(frame: .boxDrawing, colors: .trueColor)

    /// シード 3 で `steps` 歩進めた列。
    static func series(steps: Int) -> GameSeries {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.starting(using: &generator)
        for _ in 0..<steps {
            series = series.advanced(using: &generator)
        }
        return series
    }

    /// シード 3 の第 1 局を終局まで進めた列。
    static func finished() -> GameSeries {
        var generator = SplitMix64(seed: 3)
        var series = GameSeries.starting(using: &generator)
        while case .ongoing = series.game.status {
            series = series.advanced(using: &generator)
        }
        return series
    }

    static func render(
        _ series: GameSeries, size: ScreenSize,
        options: DisplayOptions = DisplayOptions(theme: .standard, traits: boxed),
        countdown: Countdown? = nil
    ) -> Grid {
        let state = ScreenState(series: series, options: options, seed: 3, countdown: countdown)
        return TableRenderer.render(state, size: size)
    }

    static func cells(_ grid: Grid) -> [Cell] {
        (0..<grid.size.rows).flatMap { row in (0..<grid.size.columns).map { grid[$0, row] } }
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    static let layouts: [ScreenLayout] = [.large, .compact]

    @Test(arguments: layouts)
    func discCellsAreBlankBlocksInTheDiscColor(_ layout: ScreenLayout) {
        let series = Self.series(steps: 20)
        let grid = Self.render(series, size: layout.size)
        let theme = Theme.standard
        let perDisc = layout.board.disc.reduce(0) { $0 + $1.width }
        let frame = layout.board
        for disc in Disc.allCases {
            let painted = (frame.row..<frame.row + frame.height).flatMap { row in
                (frame.column..<frame.column + frame.width).map { grid[$0, row] }
            }.filter { $0.background == theme.color(of: disc) }
            #expect(painted.allSatisfy { $0.character == " " })
            #expect(painted.count == series.game.position.count(of: disc) * perDisc)
        }
    }

    /// どの升も最上行には石を塗らない。縦に並んだ石の塗りが升の境目で接して 1 本の柱に見えないように（Issue #7・ADR 0009）。
    @Test(arguments: layouts)
    func discsLeaveTheTopRowOfEverySquareEmpty(_ layout: ScreenLayout) {
        let series = Self.series(steps: 40)
        let grid = Self.render(series, size: layout.size)
        let frame = layout.board
        let discColors = Disc.allCases.map { Theme.standard.color(of: $0) }
        for square in Square.all {
            let top = frame.row + square.row * frame.squareHeight
            let left = frame.column + square.column * frame.squareWidth
            let touched = (left..<left + frame.squareWidth).contains { discColors.contains(grid[$0, top].background) }
            #expect(!touched, "\(MoveNotation.name(of: square))")
        }
        #expect(series.game.position.count(of: .black) + series.game.position.count(of: .white) > 20)
    }

    /// ASCII の枠では画面の文字はすべて ASCII。罫線の枠でも、ASCII 以外は枠の字形だけ（石に Emoji の文字を使わない）。
    @Test func charactersAreASCIIOrFrameGlyphs() {
        let series = Self.series(steps: 30)
        let ascii = Self.render(
            series, size: TableRenderer.largeSize,
            options: DisplayOptions(theme: .standard, traits: TerminalTraits(frame: .ascii, colors: .trueColor)))
        #expect(Self.cells(ascii).allSatisfy { $0.character.isASCII })
        let glyphs = FrameGlyphs.of(.boxDrawing)
        let allowed = Set(
            [
                glyphs.topLeft, glyphs.topRight, glyphs.teeLeft, glyphs.teeRight, glyphs.bottomLeft, glyphs.bottomRight,
                glyphs.horizontal, glyphs.vertical, glyphs.barFull, glyphs.barEmpty, glyphs.barOpen, glyphs.barClose,
                glyphs.marker, glyphs.cursor,
            ].flatMap { Array($0) })
        let boxed = Self.render(series, size: TableRenderer.largeSize)
        #expect(Self.cells(boxed).allSatisfy { $0.character.isASCII || allowed.contains($0.character) })
        #expect(Self.cells(boxed).contains { $0.character == Character(glyphs.topLeft) })
    }

    @Test func lastMoveIsBracketedOnTheDiscRows() throws {
        let series = Self.series(steps: 5)
        let grid = Self.render(series, size: TableRenderer.largeSize)
        guard case .place(let square) = try #require(series.game.moves.last).kind else {
            Issue.record("直前の手がパス")
            return
        }
        let frame = BoardFrame.large
        let left = frame.column + square.column * frame.squareWidth
        let top = frame.row + square.row * frame.squareHeight
        for span in frame.disc {
            #expect(grid[left, top + span.line].character == "[")
            #expect(grid[left + frame.squareWidth - 1, top + span.line].character == "]")
        }
        let board = (frame.row..<frame.row + frame.height).flatMap { row in
            (frame.column..<frame.column + frame.width).map { grid[$0, row] }
        }
        #expect(board.filter { $0.character == "[" }.count == frame.disc.count)
    }

    @Test func hudShowsTheMatchTheDiscsAndTheKeys() {
        let series = Self.series(steps: 1)
        let text = Self.text(Self.render(series, size: TableRenderer.largeSize))
        #expect(text.contains("NENE//REVERSI"))
        #expect(text.contains("GAME 001"))
        #expect(text.contains("SEED 0x0000000000000003"))
        #expect(text.contains("24BIT"))
        #expect(text.contains("BLACK     \(series.players.black.handle)"))
        #expect(text.contains("WHITE     \(series.players.white.handle)"))
        #expect(text.contains("TURN      WHITE :: MOVE 01"))
        #expect(text.contains("[ DISCS ]"))
        let position = series.game.position
        #expect(text.contains("  0\(position.count(of: .black))"))
        #expect(text.contains("[q] QUIT"))
        #expect(text.contains("[t] THEME: NEON"))
        #expect(text.contains("LAST \(MoveNotation.text(of: series.game.moves[0]))"))
    }

    @Test func finishedGameShowsTheResultAndTheCountdown() {
        let series = Self.finished()
        let grid = Self.render(series, size: TableRenderer.largeSize, countdown: Countdown(remaining: 2, total: 3))
        let text = Self.text(grid)
        #expect(text.contains("[ RESULT ]"))
        #expect(text.contains(">> "))
        #expect(text.contains("NEXT GAME"))
        #expect(text.contains("2s"))
        #expect(text.contains("TURN      --"))
    }

    @Test func compactLayoutFitsAndShowsTheMatch() {
        let series = Self.series(steps: 6)
        let text = Self.text(Self.render(series, size: TableRenderer.minimumSize))
        #expect(text.contains("[ MATCH 001 ]"))
        #expect(text.contains("B \(series.players.black.handle)  vs  W \(series.players.white.handle)"))
        #expect(text.contains("[t] NEON"))
    }

    @Test func tooSmallScreenShowsOneLineWithTheNeededSize() {
        let small = ScreenSize(columns: TableRenderer.minimumSize.columns - 1, rows: TableRenderer.minimumSize.rows)
        let grid = Self.render(Self.series(steps: 3), size: small)
        let need = TableRenderer.minimumSize
        #expect(Self.text(grid).hasPrefix("TERMINAL TOO SMALL (NEED \(need.columns)x\(need.rows))"))
        #expect(Self.cells(grid).allSatisfy { $0.background == Theme.standard.ground })
    }

    @Test func emptyScreenDoesNotCrash() {
        let grid = Self.render(Self.series(steps: 3), size: ScreenSize(columns: 0, rows: 0))
        #expect(grid.size == ScreenSize(columns: 0, rows: 0))
    }

    /// 12 テーマ × 2 つの配置 × 対局中と終局後で、英字・数字と盤の上の `[ ]` は前景と背景が 4.5:1 以上（WCAG）。
    /// 枠の罫線と飾りの記号は控えめな色で描く設計なので対象にしない（NeNe Gambit と同じ・ADR 0011）。
    /// 石は升に対して 3:1 以上（文字でない図形の基準）、白黒の石どうしは明るさで 2.2:1 以上（色だけでなく明るさでも分かれる）。
    @Test(arguments: Theme.catalog)
    func everyThemeHasEnoughContrast(_ theme: Theme) {
        for series in [Self.series(steps: 20), Self.finished()] {
            for layout in Self.layouts {
                let grid = Self.render(
                    series, size: layout.size, options: DisplayOptions(theme: theme, traits: Self.boxed),
                    countdown: Countdown(remaining: 1, total: 3))
                let frame = layout.board
                for row in 0..<grid.size.rows {
                    for column in 0..<grid.size.columns {
                        let cell = grid[column, row]
                        let onBoard =
                            (frame.column..<frame.column + frame.width).contains(column)
                            && (frame.row..<frame.row + frame.height).contains(row)
                        guard cell.character.isLetter || cell.character.isNumber || (onBoard && cell.character != " ")
                        else {
                            continue
                        }
                        let ratio = Contrast.ratio(cell.foreground, cell.background)
                        #expect(ratio >= 4.5, "\(theme.name) \(column),\(row) '\(cell.character)' \(ratio)")
                    }
                }
            }
        }
        for disc in Disc.allCases {
            for square in [theme.lightSquare, theme.darkSquare] {
                #expect(Contrast.ratio(theme.color(of: disc), square) >= 3, "\(theme.name) \(disc)")
            }
        }
        #expect(Contrast.ratio(theme.blackDisc, theme.whiteDisc) >= 2.2, "\(theme.name)")
        #expect(Contrast.luminance(theme.blackDisc) < Contrast.luminance(theme.whiteDisc), "\(theme.name) 黒石は暗いほう")
    }

    @Test func themesCycleAndAreNamedCaseInsensitively() {
        #expect(Theme.catalog.count == 12)
        #expect(Set(Theme.catalog.map(\.name)).count == 12)
        #expect(Theme.standard.name == "NEON")
        #expect(Theme.standard.next.name == "PHOSPHOR")
        #expect(Theme.catalog[11].next == Theme.standard)
        #expect(Theme.named("paper")?.name == "PAPER")
        #expect(Theme.named("nope") == nil)
    }

    /// LOG は黒白 1 手ずつの行で、次に打つ側の空きにカーソルを置く。
    @Test func logPairsMovesAndPlacesTheCursor() {
        let one = Self.series(steps: 1).game
        let rows = MoveLogRow.recent(one, count: 5)
        #expect(
            rows == [MoveLogRow(number: "01.", black: MoveNotation.text(of: one.moves[0]), white: "", cursor: .white)])
        let two = Self.series(steps: 2).game
        #expect(MoveLogRow.recent(two, count: 5).last?.cursor == .black)
        #expect(MoveLogRow.recent(two, count: 5).last?.number == "02.")
    }

    @Test func notationNamesSquaresWithRowOneAtTheTop() {
        #expect(Square.at(column: 3, row: 2).map(MoveNotation.name) == "d3")
        #expect(Square.at(column: 7, row: 7).map(MoveNotation.name) == "h8")
    }
}
