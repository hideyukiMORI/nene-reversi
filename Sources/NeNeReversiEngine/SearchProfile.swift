/// 1 人の性格の打ち方（FR-06）。時計ではなく深さとノード数で打ち切る（ARC-007）。
struct SearchProfile: Sendable, Hashable {
    /// 読む深さ（手）。
    let depth: Int
    /// 1 手あたりに調べる局面の上限。超えたら、その深さを打ち切って 1 つ浅い深さの結果を使う。
    let nodeLimit: Int
    /// 空き升がこの数以下なら終局まで読む（ノードの上限は同じくかかる）。
    let solveEmpties: Int
    /// 序盤のこの手数までは、最善から `openingMargin` 以内の手から乱数で選ぶ（FR-05）。
    let openingMoves: Int
    let openingMargin: Int
    /// それ以後も、最善から `tieMargin` 以内の手から乱数で選ぶ（同点の手の揺らぎ）。
    let tieMargin: Int
    let weights: StyleWeights
}
