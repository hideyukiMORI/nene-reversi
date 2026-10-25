/// 升の中の 1 行で石を塗る範囲（升の左端からの桁と幅）。幅は偶数（FR-07）。
struct DiscSpan: Sendable, Hashable {
    let offset: Int
    let width: Int
}
