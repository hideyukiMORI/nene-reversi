import NeNeReversiCore

/// 画面に出す文言。文言のリテラルを持つのはここだけ。
///
/// ASCII の英語の大文字にしてある。1 文字 1 桁の前提（ADR 0007）を全角や幅の曖昧な文字で崩さないため。
enum Wording {
    static let title = "NENE//REVERSI"
    static let match = "MATCH"
    static let score = "SCORE"
    static let log = "LOG"
    static let result = "RESULT"
    static let help = "Q QUIT"

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func game(_ number: Int) -> String {
        "GAME   " + padded(number, width: 3)
    }

    static func turn(_ side: Disc?) -> String {
        "TURN   " + (side.map(name) ?? "OVER")
    }

    static func moveCount(_ count: Int) -> String {
        "MOVES  " + padded(count, width: 3)
    }

    static func discs(black: Int, white: Int) -> String {
        "DISCS  BLACK " + padded(black, width: 2) + "  WHITE " + padded(white, width: 2)
    }

    static func player(_ disc: Disc, _ handle: String) -> String {
        name(disc) + "  " + handle
    }

    static func wins(_ disc: Disc, _ count: Int) -> String {
        name(disc) + "  " + padded(count, width: 3)
    }

    static func draws(_ count: Int) -> String {
        "DRAW   " + padded(count, width: 3)
    }

    static func logEntry(number: Int, mover: Disc, move: String) -> String {
        padded(number, width: 2) + " " + name(mover) + " " + move
    }

    static func outcome(_ result: GameResult, black: Int, white: Int) -> String {
        let score = padded(black, width: 2) + "-" + padded(white, width: 2)
        switch result {
        case .blackWins:
            return "BLACK WINS " + score
        case .whiteWins:
            return "WHITE WINS " + score
        case .draw:
            return "DRAW " + score
        }
    }

    static func nextGame(in seconds: Int) -> String {
        "NEXT GAME IN " + String(seconds)
    }

    static func tooSmall(need size: ScreenSize) -> String {
        "TERMINAL TOO SMALL: NEED \(size.columns)x\(size.rows)"
    }

    static func name(_ disc: Disc) -> String {
        switch disc {
        case .black:
            return "BLACK"
        case .white:
            return "WHITE"
        }
    }

    private static func padded(_ number: Int, width: Int) -> String {
        let digits = String(number)
        return String(repeating: "0", count: max(width - digits.count, 0)) + digits
    }
}
