/// 枠と棒グラフの字形の組（ADR 0011）。移植元: NeNe Gambit `Sources/NeNeGambitRender/FrameStyle.swift`（コミット 64b82ec）。
public enum FrameStyle: Sendable, Hashable {
    /// 罫線とブロック（`┌─┤│█░▌`）。施主の選んだ形。端末がこれを 1 桁で描くときだけ使う
    case boxDrawing
    /// ASCII（`+-|#->`）。罫線が 2 桁で描かれる端末へ自動で落とす先
    case ascii
}
