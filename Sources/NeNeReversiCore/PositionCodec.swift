/// 局面の文字列表現の読み書き。局面と文字列を行き来する経路はここ 1 つ（ARC-001 / ARC-008・ADR 0005）。
///
/// 形は「盤の 64 文字・空白 1 つ・手番の 1 文字」。盤は a1, b1, …, h1, a2, …, h8 の順に、黒石を `X`、白石を `O`、
/// 空き升を `-` で書く。手番は黒が `X`、白が `O`。初期局面は
/// `---------------------------OX------XO--------------------------- X`。
/// 盤の中身が実際の対局で現れうるかは見ない（手で作った局面をテストで読むため）。
public enum PositionCodec {
    /// 局面の文字列表現を読む。
    public static func decode(_ text: String) -> PositionDecodeOutcome {
        let fields = text.split(separator: " ", omittingEmptySubsequences: false)
        guard fields.count == 2 else {
            return .rejected(.fieldCount)
        }
        let cells = Array(fields[0])
        guard cells.count == 64 else {
            return .rejected(.boardLength)
        }
        var black: UInt64 = 0
        var white: UInt64 = 0
        for (index, cell) in cells.enumerated() {
            let bit: UInt64 = 1 << UInt64(index)
            if cell == "X" {
                black |= bit
            } else if cell == "O" {
                white |= bit
            } else if cell != "-" {
                return .rejected(.boardCharacter)
            }
        }
        guard let side = disc(named: fields[1]) else {
            return .rejected(.sideToMove)
        }
        return .decoded(Position.arranged(black: black, white: white, sideToMove: side))
    }

    /// 局面を文字列表現に書く。`decode` で読んだ文字列は同じ文字列に戻る。
    public static func encode(_ position: Position) -> String {
        let board = Square.all.map { square in position.disc(at: square).map(letter) ?? "-" }.joined()
        return board + " " + letter(position.sideToMove)
    }

    private static func letter(_ disc: Disc) -> String {
        switch disc {
        case .black:
            return "X"
        case .white:
            return "O"
        }
    }

    private static func disc(named name: Substring) -> Disc? {
        if name == "X" {
            return .black
        }
        if name == "O" {
            return .white
        }
        return nil
    }
}
