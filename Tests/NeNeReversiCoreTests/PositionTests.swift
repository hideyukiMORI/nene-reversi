import Testing

@testable import NeNeReversiCore

/// 手で作った局面で、反転・パス・終局を確かめる（FR-02 / FR-04）。
struct PositionTests {
    @Test func initialPositionHasFourMoves() {
        let squares = Self.placements(Position.initial.legalMoves())
        #expect(squares == [Self.square("d3"), Self.square("c4"), Self.square("f5"), Self.square("e6")])
        #expect(Position.initial.count(of: .black) == 2)
        #expect(Position.initial.count(of: .white) == 2)
        #expect(Position.initial.status == .ongoing)
    }

    @Test func cornerMoveFlipsInThreeDirectionsAtOnce() throws {
        let position = try Self.position(
            rows: ["-OOX----", "OO------", "X-X-----", "--------", "--------", "--------", "--------", "--------"],
            side: "X"
        )
        let move = try #require(position.legalMoves().first { $0.kind == .place(Self.square("a1")) })
        let next = position.applying(move)
        let expected = try Self.position(
            rows: ["XXXX----", "XX------", "X-X-----", "--------", "--------", "--------", "--------", "--------"],
            side: "O"
        )
        #expect(next == expected)
    }

    @Test func rayEndingAtAnEmptySquareOrTheEdgeDoesNotFlip() throws {
        let position = try Self.position(
            rows: ["-OO-----", "O-------", "O-------", "--------", "--------", "--------", "--------", "-------X"],
            side: "X"
        )
        #expect(position.flips(placingAt: Self.square("a1")) == 0)
        #expect(position.legalMoves().allSatisfy { $0.kind != .place(Self.square("a1")) })
    }

    /// h1 と a2 は 64 ビットでは隣り合うが、盤では隣でない。行をまたいで挟まない。
    @Test func discsDoNotWrapAroundTheRowEdge() throws {
        let position = try Self.position(
            rows: ["-------X", "O-------", "--------", "--------", "--------", "--------", "--------", "--------"],
            side: "X"
        )
        #expect(position.legalMoves().isEmpty)
        #expect(position.status == .finished(.draw))
    }

    @Test func sideWithoutPlacementsMustPass() throws {
        let position = try Self.position(
            rows: ["OX------", "--------", "--------", "--------", "--------", "--------", "--------", "--------"],
            side: "X"
        )
        #expect(position.legalMoves().map(\.kind) == [.pass])
        #expect(position.status == .ongoing)
        let passed = position.applying(try #require(position.legalMoves().first))
        #expect(passed.sideToMove == .white)
        #expect(passed.count(of: .black) == 1)
        #expect(passed.count(of: .white) == 1)
        #expect(Self.placements(passed.legalMoves()) == [Self.square("c1")])
    }

    @Test func fullBoardIsFinishedAndCountedByDiscs() throws {
        let blackHeavy = try Self.decode(String(repeating: "X", count: 33) + String(repeating: "O", count: 31) + " O")
        #expect(blackHeavy.legalMoves().isEmpty)
        #expect(blackHeavy.status == .finished(.blackWins))
        let whiteHeavy = try Self.decode(String(repeating: "X", count: 31) + String(repeating: "O", count: 33) + " X")
        #expect(whiteHeavy.status == .finished(.whiteWins))
        let even = try Self.decode(String(repeating: "XO", count: 32) + " X")
        #expect(even.status == .finished(.draw))
    }

    /// 毎回いちばん前の手・いちばん後ろの手を選んで 1 局ずつ終局まで進め、1 手ごとの不変条件を見る。
    @Test(arguments: [MovePick.first, MovePick.last])
    func invariantsHoldAlongAWholeGame(_ pick: MovePick) {
        var position = Position.initial
        var plies = 0
        while let move = pick.choose(from: position.legalMoves()) {
            Self.expectLegalMovesMatchFlips(position)
            let next = position.applying(move)
            Self.expectDiscCounts(before: position, move: move, after: next)
            #expect(PositionCodec.decode(PositionCodec.encode(next)) == .decoded(next))
            position = next
            plies += 1
        }
        #expect(position.status != .ongoing)
        #expect(plies >= 9)
    }

    enum MovePick: Sendable, CaseIterable {
        case first
        case last

        func choose(from moves: [Move]) -> Move? {
            switch self {
            case .first:
                return moves.first
            case .last:
                return moves.last
            }
        }
    }

    /// 合法手の升は、反転が 1 つ以上ある空き升とちょうど一致する（打てる升の計算と反転の計算は別の経路）。
    static func expectLegalMovesMatchFlips(_ position: Position) {
        let flippable = Square.all.filter { square in
            position.disc(at: square) == nil && position.flips(placingAt: square) != 0
        }
        let moves = position.legalMoves()
        if flippable.isEmpty {
            #expect(moves.allSatisfy { $0.kind == .pass })
            #expect(moves.count <= 1)
        } else {
            #expect(placements(moves) == flippable)
        }
    }

    /// 打つ手では石の総数がちょうど 1 増え、反転した数だけ手番側が増え相手が減る。パスでは変わらない。
    static func expectDiscCounts(before: Position, move: Move, after: Position) {
        let mover = before.sideToMove
        #expect(after.sideToMove == mover.opponent)
        switch move.kind {
        case .place(let square):
            let flipped = before.flips(placingAt: square).nonzeroBitCount
            #expect(flipped > 0)
            #expect(after.count(of: mover) == before.count(of: mover) + flipped + 1)
            #expect(after.count(of: mover.opponent) == before.count(of: mover.opponent) - flipped)
        case .pass:
            #expect(after.count(of: mover) == before.count(of: mover))
            #expect(after.count(of: mover.opponent) == before.count(of: mover.opponent))
        }
    }

    static func placements(_ moves: [Move]) -> [Square] {
        moves.compactMap { move in
            if case .place(let square) = move.kind {
                return square
            }
            return nil
        }
    }

    /// `d3` のような升の名前から升を作る（テストの読みやすさのためだけ。表示用の表記は Render が持つ）。
    static func square(_ name: String) -> Square {
        let letters = Array(name.unicodeScalars)
        let column = Int(letters[0].value) - Int(("a" as Unicode.Scalar).value)
        let row = Int(letters[1].value) - Int(("1" as Unicode.Scalar).value)
        guard let square = Square.at(column: column, row: row) else {
            preconditionFailure("盤の外の升の名前: \(name)")
        }
        return square
    }

    /// 1 行目から 8 行目までの 8 文字ずつと手番から局面を作る。
    static func position(rows: [String], side: String) throws -> Position {
        try decode(rows.joined() + " " + side)
    }

    static func decode(_ text: String) throws -> Position {
        let outcome = PositionCodec.decode(text)
        guard case .decoded(let position) = outcome else {
            Issue.record("局面の文字列を読めない: \(outcome)")
            return try #require(nil as Position?)
        }
        return position
    }
}
