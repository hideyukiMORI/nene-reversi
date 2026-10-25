import NeNeReversiCore

/// その局の黒と白の性格。局ごとに 4 名から違う 2 名をランダムに組む（施主の決定 Q7）。
public struct Players: Sendable, Hashable {
    public let black: Persona
    public let white: Persona

    private init(black: Persona, white: Persona) {
        self.black = black
        self.white = white
    }

    /// 4 名から違う 2 名を乱数で選ぶ。
    static func drawn(using generator: inout some RandomNumberGenerator) -> Players {
        let shuffled = Persona.allCases.shuffled(using: &generator)
        return Players(black: shuffled[0], white: shuffled[1])
    }

    /// 決まった 2 名の組（テストと計測のため）。同じ性格どうしでもよい。
    static func pairing(black: Persona, white: Persona) -> Players {
        Players(black: black, white: white)
    }

    /// その色を受け持つ性格。
    public func persona(for disc: Disc) -> Persona {
        switch disc {
        case .black:
            return black
        case .white:
            return white
        }
    }
}
