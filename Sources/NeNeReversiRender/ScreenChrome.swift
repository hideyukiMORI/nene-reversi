import NeNeReversiCore
import NeNeReversiEngine

/// 上端の題・盤の下の COMMS・下端のキーのヘルプ（FR-15: 常に出す）と直前の手。
///
/// 形は NeNe Gambit の `ScreenChrome`（コミット 64b82ec）にならった。字形の切り替え（`g`）は持たない（Q4・Q9）。
enum ScreenChrome {
    /// ` ▌NENE//REVERSI  │  GAME 012  │  SEED 0x…  │  24BIT`
    static func header(_ state: ScreenState, glyphs: FrameGlyphs) -> [Segment] {
        let theme = state.options.theme
        let divider = Segment("  " + glyphs.vertical + "  ", theme.frame)
        return [
            Segment(" " + glyphs.marker + Wording.title, theme.accent), divider,
            Segment(Wording.headerGame(state.series.gameNumber), theme.text), divider,
            Segment(Wording.seed(state.seed), theme.text), divider,
            Segment(Wording.colors(state.options.traits.colors), theme.dim),
        ]
    }

    /// `[q] QUIT   [t] THEME: NEON   │   LAST d3`
    static func footer(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [Segment] {
        let theme = state.options.theme
        var segments = [
            Segment(" " + Wording.quitKey, theme.accent), Segment(Wording.quitName, theme.dim),
            Segment(Wording.themeKey, theme.accent), Segment(compact ? " " : Wording.themeName, theme.dim),
            Segment(theme.name, theme.text),
        ]
        let moves = state.series.game.moves
        if let move = moves.last {
            // パスも手なので、手は黒から交互（ADR 0005）
            let mover: Disc = moves.count % 2 == 1 ? .black : .white
            segments += [
                Segment("   " + glyphs.vertical + "   ", theme.frame), Segment(Wording.lastLabel, theme.dim),
                Segment(MoveNotation.text(of: move), theme.color(of: mover)),
            ]
        }
        return segments
    }

    /// COMMS の 2 行（古い方は控えめな色、新しい方は話し手の側の色・ADR 0012）。
    static func comms(_ state: ScreenState, glyphs: FrameGlyphs, compact: Bool) -> [[Segment]] {
        let theme = state.options.theme
        let lines = state.series.banter.lines
        return lines.enumerated().map { index, remark in
            let newest = index == lines.count - 1
            let tag = remark.side == .black ? "B" : "W"
            let handle = compact ? remark.persona.handle + " " : remark.persona.handle.padding(to: 11)
            let lead = compact ? glyphs.marker + tag + " " : glyphs.marker + " " + tag + "  "
            let face = remark.face + (compact ? " " : "  ")
            guard newest else {
                return [Segment(lead + handle + face + remark.text, theme.dim)]
            }
            return [
                Segment(lead + handle, theme.color(of: remark.side)), Segment(face, theme.accentAlt),
                Segment(remark.text, theme.text),
            ]
        }
    }
}
