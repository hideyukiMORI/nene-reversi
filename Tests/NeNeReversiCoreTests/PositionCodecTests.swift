import Testing

@testable import NeNeReversiCore

/// 局面の文字列表現の読み書き（ADR 0005）。
struct PositionCodecTests {
    static let initialText = "---------------------------OX------XO--------------------------- X"

    @Test func initialPositionEncodesToTheDocumentedText() {
        #expect(PositionCodec.encode(.initial) == Self.initialText)
        #expect(PositionCodec.decode(Self.initialText) == .decoded(.initial))
    }

    static let wellFormed: [String] = [
        initialText,
        "-OOX----" + "OO------" + "X-X-----" + String(repeating: "-", count: 40) + " O",
        String(repeating: "XO", count: 32) + " X",
        String(repeating: "-", count: 64) + " O",
    ]

    @Test(arguments: wellFormed)
    func decodingThenEncodingGivesTheSameText(_ text: String) {
        let outcome = PositionCodec.decode(text)
        guard case .decoded(let position) = outcome else {
            Issue.record("読めない: \(outcome)")
            return
        }
        #expect(PositionCodec.encode(position) == text)
    }

    struct Rejected: Sendable, CustomTestStringConvertible {
        let text: String
        let reason: PositionDecodeRejection

        var testDescription: String {
            "\(reason)"
        }
    }

    static let malformed: [Rejected] = [
        Rejected(text: String(repeating: "-", count: 64), reason: .fieldCount),
        Rejected(text: String(repeating: "-", count: 64) + "  X", reason: .fieldCount),
        Rejected(text: String(repeating: "-", count: 63) + " X", reason: .boardLength),
        Rejected(text: String(repeating: "-", count: 63) + "x X", reason: .boardCharacter),
        Rejected(text: String(repeating: "-", count: 64) + " B", reason: .sideToMove),
        Rejected(text: String(repeating: "-", count: 64) + " ", reason: .sideToMove),
    ]

    @Test(arguments: malformed)
    func malformedTextIsRejectedWithItsReason(_ entry: Rejected) {
        #expect(PositionCodec.decode(entry.text) == .rejected(entry.reason))
    }
}
