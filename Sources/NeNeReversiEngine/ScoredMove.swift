import NeNeReversiCore

/// 根の手と、その手を打った後の局面の評価（手番の側から見た値）。
struct ScoredMove: Sendable, Hashable {
    let move: Move
    let score: Int
}
