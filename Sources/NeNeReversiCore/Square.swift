/// 盤の升。a1 が 0、h8 が 63（`index = row * 8 + column`）。
///
/// 列（column）は 0 = a 〜 7 = h、行（row）は 0 = 1 行目 〜 7 = 8 行目。リバーシの慣習どおり 1 行目は盤の上端で、
/// 初期局面の黒は d5 と e4、白は d4 と e5 にある。盤の外の升は作れない。
public struct Square: Sendable, Hashable {
    public let index: Int

    private init(index: Int) {
        self.index = index
    }

    /// 64 升すべて（a1, b1, …, h8 の順）。
    public static let all: [Square] = (0..<64).map { Square(index: $0) }

    /// 列と行から升を作る。盤の外なら nil。
    public static func at(column: Int, row: Int) -> Square? {
        (0..<8).contains(column) && (0..<8).contains(row) ? Square(index: row * 8 + column) : nil
    }

    /// 列。0 = a 〜 7 = h。
    public var column: Int {
        index % 8
    }

    /// 行。0 = 1 行目 〜 7 = 8 行目。
    public var row: Int {
        index / 8
    }

    /// 盤の 64 ビットの表現でこの升が占めるビット（ADR 0005）。
    var bit: UInt64 {
        1 << UInt64(index)
    }
}
