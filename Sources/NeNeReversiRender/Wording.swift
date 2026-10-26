import NeNeReversiCore

/// 画面に出す文言。文言のリテラルを持つのはここだけ（キャラクターの名前は Engine の性格が持つ）。
///
/// 英語の大文字の ASCII にしてある。罫線とブロックは `FrameGlyphs` が持ち、幅を測ってから使う（ADR 0011）。
enum Wording {
    static let title = "NENE//REVERSI"
    static let match = "MATCH"
    static let discs = "DISCS"
    static let score = "SCORE"
    static let log = "LOG"
    static let result = "RESULT"
    static let nextGame = "NEXT GAME  "
    static let gameLabel = "GAME      "
    static let blackLabel = "BLACK     "
    static let whiteLabel = "WHITE     "
    static let turnLabel = "TURN      "
    static let lastLabel = "LAST "
    static let noTurn = "--"
    static let quitKey = "[q]"
    static let quitName = " QUIT   "
    static let themeKey = "[t]"
    static let themeName = " THEME: "

    static func gameNumber(_ number: Int) -> String {
        padded(number, width: 3)
    }

    static func headerGame(_ number: Int) -> String {
        "GAME " + padded(number, width: 3)
    }

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func colors(_ mode: ColorMode) -> String {
        switch mode {
        case .trueColor:
            return "24BIT"
        case .palette256:
            return "256C"
        }
    }

    static func side(_ disc: Disc) -> String {
        switch disc {
        case .black:
            return "BLACK"
        case .white:
            return "WHITE"
        }
    }

    static func tag(_ disc: Disc) -> String {
        switch disc {
        case .black:
            return "B  "
        case .white:
            return "W  "
        }
    }

    static let drawTag = "=  "

    static func moveNumber(_ number: Int) -> String {
        " :: MOVE " + padded(number, width: 2)
    }

    static func headline(_ result: GameResult, black: Int, white: Int) -> String {
        let score = "  " + padded(black, width: 2) + "-" + padded(white, width: 2)
        switch result {
        case .blackWins:
            return ">> BLACK WINS" + score
        case .whiteWins:
            return ">> WHITE WINS" + score
        case .draw:
            return ">> DRAW" + score
        }
    }

    /// 終局の理由。盤が埋まったか、両者とも打てなくなったか。
    static func reason(boardFull: Bool) -> String {
        boardFull ? "BOARD FULL" : "NO MOVES LEFT"
    }

    static func seconds(_ value: Int) -> String {
        "\(value)s"
    }

    static func tooSmall(need size: ScreenSize) -> String {
        "TERMINAL TOO SMALL (NEED \(size.columns)x\(size.rows))"
    }

    static func padded(_ number: Int, width: Int) -> String {
        let digits = String(number)
        return String(repeating: "0", count: max(width - digits.count, 0)) + digits
    }
}

extension String {
    /// 右を空白で埋めて `width` 桁にする（長ければそのまま）。
    func padding(to width: Int) -> String {
        self + String(repeating: " ", count: max(width - count, 0))
    }
}
