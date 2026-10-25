/// 盤上の石と手番を合わせた値（局面）。盤は黒と白の石の位置を 1 枚ずつの 64 ビットで持つ（ADR 0005）。
///
/// 手の適用は新しい局面を返し、元の局面を変えない。「パスか」「終局したか」を決める経路は `legalMoves()` の 1 つだけ。
public struct Position: Sendable, Hashable {
    /// 黒石のある升のビット。
    let black: UInt64
    /// 白石のある升のビット。
    let white: UInt64
    /// 手番の側。
    public let sideToMove: Disc

    private init(black: UInt64, white: UInt64, sideToMove: Disc) {
        self.black = black
        self.white = white
        self.sideToMove = sideToMove
    }

    /// 初期局面。黒は d5 と e4、白は d4 と e5。黒の手番。
    public static let initial = Position(
        black: 1 << 28 | 1 << 35,
        white: 1 << 27 | 1 << 36,
        sideToMove: .black
    )

    /// 黒と白の石の位置と手番から局面を作る。同じ升に両方の石がある値は欠陥として止める。
    static func arranged(black: UInt64, white: UInt64, sideToMove: Disc) -> Position {
        precondition(black & white == 0, "同じ升に黒と白の石がある")
        return Position(black: black, white: white, sideToMove: sideToMove)
    }

    /// 升にある石。空の升なら nil。
    public func disc(at square: Square) -> Disc? {
        if black & square.bit != 0 {
            return .black
        }
        if white & square.bit != 0 {
            return .white
        }
        return nil
    }

    /// 盤上のその色の石の数。
    public func count(of disc: Disc) -> Int {
        discs(of: disc).nonzeroBitCount
    }

    /// その色が石を打てる升の数（手番でなくても数える）。評価関数が相手の打てる升を数えるのに使う（ADR 0010）。
    public func placementCount(of disc: Disc) -> Int {
        mobility(of: disc).nonzeroBitCount
    }

    /// その色の石のある升のビット。
    func discs(of disc: Disc) -> UInt64 {
        switch disc {
        case .black:
            return black
        case .white:
            return white
        }
    }

    /// 合法手。手番の側に打てる升があればその升への手（a1 から h8 の順）、
    /// 無くて相手に打てる升があればパス 1 つ、両者とも打てなければ空（終局）。
    public func legalMoves() -> [Move] {
        let placements = mobility(of: sideToMove)
        if placements != 0 {
            return Self.squares(in: placements).map(Move.place)
        }
        return mobility(of: sideToMove.opponent) == 0 ? [] : [Move.pass]
    }

    /// 局面の状態。合法手が空なら終局で、石の多い側の勝ち。
    public var status: PositionStatus {
        guard legalMoves().isEmpty else {
            return .ongoing
        }
        let difference = count(of: .black) - count(of: .white)
        if difference > 0 {
            return .finished(.blackWins)
        }
        if difference < 0 {
            return .finished(.whiteWins)
        }
        return .finished(.draw)
    }

    /// 手を適用した次の局面。手は `legalMoves()` から得たものに限る。合法でない手は欠陥として止める。
    public func applying(_ move: Move) -> Position {
        let mover = sideToMove
        switch move.kind {
        case .place(let square):
            precondition((black | white) & square.bit == 0, "合法でない手: 石のある升に打った")
            let flipped = flips(placingAt: square)
            precondition(flipped != 0, "合法でない手: 挟める石が無い")
            return Self.placing(
                mine: discs(of: mover) | square.bit | flipped,
                theirs: discs(of: mover.opponent) & ~flipped,
                mover: mover
            )
        case .pass:
            precondition(mobility(of: mover) == 0 && mobility(of: mover.opponent) != 0, "合法でない手: パスできない")
            return Position(black: black, white: white, sideToMove: mover.opponent)
        }
    }

    /// 手番の側（mover）の石と相手の石から、相手の手番の局面を作る。
    private static func placing(mine: UInt64, theirs: UInt64, mover: Disc) -> Position {
        switch mover {
        case .black:
            return arranged(black: mine, white: theirs, sideToMove: .white)
        case .white:
            return arranged(black: theirs, white: mine, sideToMove: .black)
        }
    }

    /// ビットの立っている升（index の小さい順）。
    private static func squares(in bits: UInt64) -> [Square] {
        var rest = bits
        var found: [Square] = []
        found.reserveCapacity(rest.nonzeroBitCount)
        while rest != 0 {
            found.append(Square.all[rest.trailingZeroBitCount])
            rest &= rest - 1
        }
        return found
    }
}
