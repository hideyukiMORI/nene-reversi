import NeNeReversiCore
import Testing

@testable import NeNeReversiEngine

/// キャラクターの発言（FR-14・ADR 0012）。
struct BanterTests {
    /// 台本は 1 人 50 本・出来事ごとに 1 本以上・どれも ASCII の印字可能な文字だけで 72 文字以内・重複なし。
    @Test(arguments: Persona.allCases)
    func scriptHasFiftyShortAsciiLines(_ persona: Persona) {
        let lines = Cue.allCases.flatMap { persona.lines(for: $0) }
        #expect(lines.count == 50)
        #expect(Set(lines).count == lines.count)
        for cue in Cue.allCases {
            #expect(!persona.lines(for: cue).isEmpty, "\(persona.handle) に \(cue) のセリフが無い")
        }
        for line in lines {
            #expect(line.count <= 72, "長すぎる: \(line)")
            #expect(line.unicodeScalars.allSatisfy { (0x20...0x7E).contains($0.value) }, "ASCII でない: \(line)")
        }
    }

    /// 顔は気分ごとに ASCII 3 文字で、4 名とも違う。
    @Test(arguments: Persona.allCases)
    func facesAreThreeAsciiCharacters(_ persona: Persona) {
        for mood in Mood.allCases {
            let face = persona.face(mood)
            #expect(face.count == 3 && face.unicodeScalars.allSatisfy { (0x20...0x7E).contains($0.value) }, "\(face)")
        }
        let others = Persona.allCases.filter { $0 != persona }
        #expect(others.allSatisfy { $0.face(.smug) != persona.face(.smug) })
    }

    /// 局が始まると黒、白の順に始まりのひと言を言う。黒白は違う 2 名。
    @Test(arguments: [UInt64(1), 2, 3, 4, 5])
    func gameStartsWithBothGreetings(_ seed: UInt64) {
        var generator = SplitMix64(seed: seed)
        let series = GameSeries.starting(using: &generator)
        #expect(series.players.black != series.players.white)
        #expect(series.banter.lines.map(\.cue) == [.start, .start])
        #expect(series.banter.lines.map(\.side) == [.black, .white])
        #expect(series.banter.lines.map(\.persona) == [series.players.black, series.players.white])
    }

    /// 終局の 1 歩で両者が最後のひと言を言う（勝った側が先・引き分けなら黒が先）。
    @Test(arguments: [UInt64(6), 7, 8])
    func gameOverEndsWithBothVerdicts(_ seed: UInt64) {
        var generator = SplitMix64(seed: seed)
        var series = GameSeries.starting(using: &generator)
        while case .ongoing = series.game.status {
            series = series.advanced(using: &generator)
        }
        let lines = series.banter.lines
        guard case .finished(let result) = series.game.status else {
            Issue.record("終局していない")
            return
        }
        switch result {
        case .blackWins:
            #expect(lines.map(\.cue) == [.win, .lose])
            #expect(lines.map(\.side) == [.black, .white])
        case .whiteWins:
            #expect(lines.map(\.cue) == [.win, .lose])
            #expect(lines.map(\.side) == [.white, .black])
        case .draw:
            #expect(lines.map(\.cue) == [.draw, .draw])
        }
    }

    /// パスした手では、パスした側が必ずぼやく。
    @Test func passIsAlwaysRemarkedByThePasser() throws {
        let facts = MoveFacts(
            before: try SearchTests.position("OX" + String(repeating: "-", count: 62) + " X"), move: try Self.pass(),
            after: try SearchTests.position("OX" + String(repeating: "-", count: 62) + " O"))
        var generator = SplitMix64(seed: 1)
        for _ in 0..<20 {
            let pick = try #require(Banter.pick(facts, quietMoves: 0, using: &generator))
            #expect(pick.prompt == Prompt(speaker: .black, cue: .passing))
        }
    }

    static func pass() throws -> Move {
        let position = try SearchTests.position("OX" + String(repeating: "-", count: 62) + " X")
        return try #require(position.legalMoves().first)
    }

    /// 同じシードからは同じ会話が出る。
    @Test func sameSeedGivesTheSameBanter() {
        #expect(Self.transcript(seed: 21, moves: 80) == Self.transcript(seed: 21, moves: 80))
        #expect(Self.transcript(seed: 21, moves: 80) != Self.transcript(seed: 22, moves: 80))
    }

    /// 話す頻度: 100 手あたり 8〜30 回（局の始まりと終わりを除く）。「黙り込む」「しゃべりすぎる」退行を捕まえるための範囲（ADR 0012 に実測）。
    @Test func talksOftenButNotConstantly() {
        let framing: Set<Cue> = [.start, .win, .lose, .draw]
        let lines = Self.transcript(seed: 4, moves: 300).filter { !framing.contains($0.cue) }
        let perHundred = lines.count * 100 / 300
        #expect((8...30).contains(perHundred), "100 手あたり \(perHundred) 回")
    }

    /// `moves` 歩のあいだに新しく出た発言の列。
    static func transcript(seed: UInt64, moves: Int) -> [Remark] {
        var generator = SplitMix64(seed: seed)
        var series = GameSeries.starting(using: &generator)
        var spoken: [Remark] = series.banter.lines
        for _ in 0..<moves {
            let before = series.banter.lines
            series = series.advanced(using: &generator)
            spoken += series.banter.lines.filter { !before.contains($0) }
        }
        return spoken
    }
}
