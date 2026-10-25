/// 石を挟む 8 方向。盤の 64 ビットの表現をその方向へ 1 升ずらす（ADR 0005）。
enum Direction: CaseIterable {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest

    /// a 列のビットを落とすマスク。右（列が増える向き）へずらすと h 列が次の行の a 列へ回り込むので、それを消す。
    private static let notColumnA: UInt64 = 0xFEFE_FEFE_FEFE_FEFE
    /// h 列のビットを落とすマスク。左へずらしたときの回り込みを消す。
    private static let notColumnH: UInt64 = 0x7F7F_7F7F_7F7F_7F7F

    /// 盤のビットの集合をこの方向へ 1 升ずらす。盤の外へ出たビットは消える。
    func shift(_ bits: UInt64) -> UInt64 {
        switch self {
        case .north:
            return bits >> 8
        case .northEast:
            return (bits >> 7) & Self.notColumnA
        case .east:
            return (bits << 1) & Self.notColumnA
        case .southEast:
            return (bits << 9) & Self.notColumnA
        case .south:
            return bits << 8
        case .southWest:
            return (bits << 7) & Self.notColumnH
        case .west:
            return (bits >> 1) & Self.notColumnH
        case .northWest:
            return (bits >> 9) & Self.notColumnH
        }
    }
}
