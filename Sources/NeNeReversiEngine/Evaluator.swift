import NeNeReversiCore

/// 局面の評価（手番の側から見た値・FR-03）。値と重みを持つのはここと性格の `SearchProfile` だけ。
///
/// 位置の項は 64 升の表を手で書かず、升の種類（角・空いた角の隣・辺・内側）から式で決める（公表された表を記憶で写さない）。
enum Evaluator {
    /// 勝ちの値。終局の局面は「勝ち＋石差」で、どんな途中の評価より大きい。
    static let win = 100_000

    /// 4 つの角と、それぞれの隣の升（X の升は斜め、C の升は辺の上で隣）。
    private static let corners: [Neighborhood] = [(0, 0), (7, 0), (0, 7), (7, 7)].compactMap { column, row in
        Neighborhood.around(column: column, row: row)
    }

    /// 手番の側から見た評価。
    static func score(_ position: Position, weights: StyleWeights) -> Int {
        let me = position.sideToMove
        let mine = position.count(of: me)
        let theirs = position.count(of: me.opponent)
        if position.legalMoves().isEmpty {
            return final(mine - theirs)
        }
        let placement = position.placementCount(of: me) - position.placementCount(of: me.opponent)
        return positional(position, for: me, weights: weights) + weights.mobility * placement
            + weights.discs * (mine - theirs)
    }

    /// 終局の値。勝ちと負けはどんな途中の評価よりも大きく離し、その中では石差が大きいほうを選ぶ。
    static func final(_ difference: Int) -> Int {
        if difference > 0 {
            return win + difference
        }
        if difference < 0 {
            return -win + difference
        }
        return 0
    }

    /// 升ごとの石の値の合計（自分の石は足し、相手の石は引く）。
    private static func positional(_ position: Position, for me: Disc, weights: StyleWeights) -> Int {
        var total = 0
        for square in Square.all {
            guard let disc = position.disc(at: square) else {
                continue
            }
            let value = squareValue(square, in: position, weights: weights)
            total += disc == me ? value : -value
        }
        return total
    }

    /// 升 1 つの値。角は高く、空いた角の隣は損、それ以外の辺は少し得、内側は 0。
    static func squareValue(_ square: Square, in position: Position, weights: StyleWeights) -> Int {
        for neighborhood in corners {
            if square == neighborhood.corner {
                return weights.corner
            }
            if neighborhood.adjacent.contains(square) {
                return position.disc(at: neighborhood.corner) == nil ? -weights.danger : weights.edge
            }
        }
        let onEdge = square.column == 0 || square.column == 7 || square.row == 0 || square.row == 7
        return onEdge ? weights.edge : 0
    }
}
