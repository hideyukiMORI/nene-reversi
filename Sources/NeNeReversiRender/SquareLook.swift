import NeNeReversiCore

/// 1 つの升の見た目: 置かれた石と、直前の手の升か。
struct SquareLook: Sendable, Hashable {
    /// 升の石。空き升なら nil。
    let disc: Disc?
    /// 直前の手の升なら true（`[ ]` で囲む）。
    let hot: Bool
}
