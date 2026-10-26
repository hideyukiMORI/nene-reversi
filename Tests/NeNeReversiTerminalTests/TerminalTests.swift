import Testing

@testable import NeNeReversiRender
@testable import NeNeReversiTerminal

/// 端末を使わずに確かめられる部分（差分のバイト列・キーの読み取り・256 色への近似）。端末そのものは `make smoke`（ADR 0008）。
struct TerminalTests {
    static let ink = Rgb(red: 200, green: 200, blue: 200)
    static let ground = Rgb(red: 0, green: 0, blue: 0)

    static func grid(_ text: String) -> Grid {
        var grid = Grid.filled(
            ScreenSize(columns: 4, rows: 2), with: Cell(character: " ", foreground: ink, background: ground))
        grid.write(text, column: 0, row: 0, colors: CellColors(foreground: ink, background: ground))
        return grid
    }

    @Test func qQuitsTCyclesAndOtherKeysAndEscapeSequencesAreIgnored() {
        #expect(KeyIntent.decode(Array("q".utf8)) == [.quit])
        #expect(KeyIntent.decode(Array("Q".utf8)) == [.quit])
        #expect(KeyIntent.decode([0x1B, UInt8(ascii: "["), UInt8(ascii: "A"), UInt8(ascii: "q")]) == [.quit])
        #expect(KeyIntent.decode(Array("xg".utf8)).isEmpty)
        #expect(KeyIntent.decode(Array("tTq".utf8)) == [.cycleTheme, .cycleTheme, .quit])
    }

    @Test func firstFrameClearsTheScreenAndWritesEverything() {
        let bytes = String(
            decoding: FrameEncoder.encode(Self.grid("ab"), previous: nil, colors: .trueColor), as: UTF8.self)
        #expect(bytes.hasPrefix("\u{1B}[0m\u{1B}[2J"))
        #expect(bytes.contains("38;2;200;200;200;48;2;0;0;0m"))
        #expect(bytes.contains("ab"))
    }

    @Test func unchangedFrameWritesNothingAndChangedCellsOnly() {
        let before = Self.grid("ab")
        #expect(FrameEncoder.encode(before, previous: before, colors: .trueColor).isEmpty)
        let bytes = String(
            decoding: FrameEncoder.encode(Self.grid("ac"), previous: before, colors: .trueColor), as: UTF8.self)
        #expect(bytes.hasPrefix("\u{1B}[1;2H"))
        #expect(bytes.contains("c"))
        #expect(!bytes.contains("a"))
    }

    @Test func cursorReportReadsTheLastColumn() {
        #expect(CursorReport.column(in: Array("\u{1B}[3;2R".utf8)) == 2)
        #expect(CursorReport.column(in: Array("x\u{1B}[1;9Ry\u{1B}[4;12R".utf8)) == 12)
        #expect(CursorReport.column(in: Array("no report".utf8)) == nil)
    }

    @Test func palette256PicksTheNearestColor() {
        #expect(Palette256.nearest(Rgb(red: 0, green: 0, blue: 0)) == 16)
        #expect(Palette256.nearest(Rgb(red: 255, green: 255, blue: 255)) == 231)
        #expect(Palette256.nearest(Rgb(red: 128, green: 128, blue: 128)) == 244)
    }
}
