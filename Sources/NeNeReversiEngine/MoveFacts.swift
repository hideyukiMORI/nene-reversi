import NeNeReversiCore

/// 1 手で起きたこと（発言のきっかけを選ぶための事実）。
struct MoveFacts: Sendable, Hashable {
    let mover: Disc
    let isPass: Bool
    let tookCorner: Bool
    /// 返した石の数（パスなら 0）。
    let flipped: Int

    /// 打つ前と打った後の局面から読む。返した数は「手番の側の石の増えた数 − 打った 1 個」。
    init(before: Position, move: Move, after: Position) {
        mover = before.sideToMove
        switch move.kind {
        case .place(let square):
            isPass = false
            tookCorner = [0, 7].contains(square.column) && [0, 7].contains(square.row)
            flipped = after.count(of: mover) - before.count(of: mover) - 1
        case .pass:
            isPass = true
            tookCorner = false
            flipped = 0
        }
    }
}
