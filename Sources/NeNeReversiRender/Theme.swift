import NeNeReversiCore

/// カラーテーマ。色の値を持つのはここだけ（FR-12）。
///
/// いまは 1 つ（Phase 3 の手順 2）。12 テーマと `t` での切り替えは手順 5 で入れる。配色は NeNe Gambit の既定テーマ NEON
/// （`Sources/NeNeGambitRender/Theme.swift`・コミット f850722 以降）を写し、駒の 2 色を石の 2 色に当てた。
/// 文字の色は地と升に対して 4.5:1 以上、石の色は升に対して 3:1 以上離れる（テストで確かめる）。
public struct Theme: Sendable, Hashable {
    /// 画面と起動オプションに使う名前。
    public let name: String
    let ground: Rgb
    let text: Rgb
    let dim: Rgb
    let accent: Rgb
    let lightSquare: Rgb
    let darkSquare: Rgb
    let blackDisc: Rgb
    let whiteDisc: Rgb

    /// 既定のテーマ。
    public static let standard = Theme(
        name: "NEON",
        hex: [0x05070D, 0xC8D3E0, 0x6B7F99, 0x00E5FF, 0x1A2740, 0x0F1828, 0xFF4FA8, 0xEAFBFF]
    )

    /// 名前と 8 色（地・文字・控えめな文字・強調・明るい升・暗い升・黒石・白石の順）から作る。
    private init(name: String, hex: [UInt32]) {
        precondition(hex.count == 8, "テーマの色は 8 つ")
        let colors = hex.map { value in
            Rgb(red: UInt8(value >> 16 & 0xFF), green: UInt8(value >> 8 & 0xFF), blue: UInt8(value & 0xFF))
        }
        self.name = name
        ground = colors[0]
        text = colors[1]
        dim = colors[2]
        accent = colors[3]
        lightSquare = colors[4]
        darkSquare = colors[5]
        blackDisc = colors[6]
        whiteDisc = colors[7]
    }

    /// 石の色。
    func color(of disc: Disc) -> Rgb {
        switch disc {
        case .black:
            return blackDisc
        case .white:
            return whiteDisc
        }
    }
}
