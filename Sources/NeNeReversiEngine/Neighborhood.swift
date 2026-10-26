import NeNeReversiCore

/// 角と、その隣の 3 升（X の升と 2 つの C の升）。
struct Neighborhood: Sendable, Hashable {
    let corner: Square
    let adjacent: [Square]

    /// 角の升の列と行から作る。角でなければ nil。
    static func around(column: Int, row: Int) -> Neighborhood? {
        guard [0, 7].contains(column), [0, 7].contains(row), let corner = Square.at(column: column, row: row) else {
            return nil
        }
        let inward = (column == 0 ? 1 : -1, row == 0 ? 1 : -1)
        let adjacent = [
            Square.at(column: column + inward.0, row: row),
            Square.at(column: column, row: row + inward.1),
            Square.at(column: column + inward.0, row: row + inward.1),
        ].compactMap { $0 }
        return Neighborhood(corner: corner, adjacent: adjacent)
    }
}
