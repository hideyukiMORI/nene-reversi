/// 升の中で石を塗る 1 行の範囲（升の上端からの行・左端からの桁・幅）。幅は偶数（FR-07）。
struct DiscSpan: Sendable, Hashable {
    let line: Int
    let offset: Int
    let width: Int
}
