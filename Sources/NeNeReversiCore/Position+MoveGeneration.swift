/// 合法な升と反転する石の計算（ADR 0005）。8 方向それぞれに盤のビットをずらして求める。
extension Position {
    /// その色が石を打てる升のビット。相手の石を 1 つ以上挟んで自分の石に届く空き升。
    func mobility(of disc: Disc) -> UInt64 {
        let mine = discs(of: disc)
        let theirs = discs(of: disc.opponent)
        let empty = ~(mine | theirs)
        var placements: UInt64 = 0
        for direction in Direction.allCases {
            // 自分の石から続く相手の石の列。間に挟める相手の石は 1 方向に最大 6 個。
            var run = direction.shift(mine) & theirs
            for _ in 0..<5 {
                run |= direction.shift(run) & theirs
            }
            placements |= direction.shift(run) & empty
        }
        return placements
    }

    /// 手番の側が升に打ったときに反転する相手の石のビット。挟めなければ 0。
    func flips(placingAt square: Square) -> UInt64 {
        let mine = discs(of: sideToMove)
        let theirs = discs(of: sideToMove.opponent)
        var flipped: UInt64 = 0
        for direction in Direction.allCases {
            var ray: UInt64 = 0
            var cursor = direction.shift(square.bit)
            while cursor & theirs != 0 {
                ray |= cursor
                cursor = direction.shift(cursor)
            }
            if cursor & mine != 0 {
                flipped |= ray
            }
        }
        return flipped
    }
}
