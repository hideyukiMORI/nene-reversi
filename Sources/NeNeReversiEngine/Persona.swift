import NeNeReversiCore

/// 黒白の性格（キャスト）。施主の決定 Q7: 4 名で、名前・性格・打ち方はリナが決める（NeNe Gambit の 4 名とは別）。局ごとにランダムに組む。
///
/// 性格は「打ち方」（`SearchProfile`・FR-06・ADR 0010）と、顔と台本（FR-14・ADR 0012）を持つ。
public enum Persona: Sendable, Hashable, CaseIterable {
    /// 返せるだけ返したがる欲張り。石の数を数えて悦に入る。
    case flip
    /// 角と辺だけを信じる冷静な策士。いちばん深く読む。
    case corner
    /// 陽気な迷惑メール。根拠のない自信で、ばらつきの大きい手を打つ。
    case spam
    /// できるだけ働きたくない定期実行。返す石を少なく、相手の打てる升を減らす。
    case lazy

    /// 画面に出す名前。
    public var handle: String {
        switch self {
        case .flip:
            return "FLIP.BAT"
        case .corner:
            return "CORNER.SYS"
        case .spam:
            return "SPAM.EML"
        case .lazy:
            return "LAZY.CRON"
        }
    }

    /// 打ち方（ADR 0010）。
    var profile: SearchProfile {
        switch self {
        case .flip:
            return SearchProfile(
                depth: 3, nodeLimit: 40_000, solveEmpties: 6, openingMoves: 6, openingMargin: 20, tieMargin: 6,
                weights: StyleWeights(corner: 80, edge: 4, danger: 35, mobility: 2, discs: 8))
        case .corner:
            return SearchProfile(
                depth: 4, nodeLimit: 120_000, solveEmpties: 10, openingMoves: 8, openingMargin: 60, tieMargin: 40,
                weights: StyleWeights(corner: 120, edge: 10, danger: 50, mobility: 8, discs: 0))
        case .spam:
            return SearchProfile(
                depth: 2, nodeLimit: 10_000, solveEmpties: 4, openingMoves: 12, openingMargin: 200, tieMargin: 30,
                weights: StyleWeights(corner: 100, edge: 6, danger: 30, mobility: 4, discs: 2))
        case .lazy:
            return SearchProfile(
                depth: 3, nodeLimit: 60_000, solveEmpties: 8, openingMoves: 6, openingMargin: 40, tieMargin: 25,
                weights: StyleWeights(corner: 100, edge: 6, danger: 40, mobility: 12, discs: -4))
        }
    }

    /// その局で打つ手。合法手が無ければ nil。返す手は必ず合法手の中にある。
    public func choose(in game: Game, using generator: inout some RandomNumberGenerator) -> Move? {
        Searcher.choose(in: game, profile: profile, using: &generator)
    }

    /// 気分ごとの顔（ASCII 3 文字）。
    public func face(_ mood: Mood) -> String {
        faces.face(mood)
    }

    private var faces: Faces {
        switch self {
        case .flip:
            return Faces(smug: "$_$", neutral: "o.o", grim: "T_T")
        case .corner:
            return Faces(smug: "[=]", neutral: "[-]", grim: "[x]")
        case .spam:
            return Faces(smug: "\\o/", neutral: ":D ", grim: "D: ")
        case .lazy:
            return Faces(smug: "-.-", neutral: "zzz", grim: "~_~")
        }
    }

    /// セリフの台本（1 人 50 本）。
    var script: [ScriptLine] {
        switch self {
        case .flip:
            return Self.flipScript
        case .corner:
            return Self.cornerScript
        case .spam:
            return Self.spamScript
        case .lazy:
            return Self.lazyScript
        }
    }

    /// その出来事のセリフ（名前や顔と同じく性格の公開の属性）。
    public func lines(for cue: Cue) -> [String] {
        script.filter { $0.cue == cue }.map(\.text)
    }
}
