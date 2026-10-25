/// 評価関数の重み（性格ごと・FR-06）。
struct StyleWeights: Sendable, Hashable {
    /// 角の石 1 つの値。
    let corner: Int
    /// 角でも危険な升でもない辺の石 1 つの値。
    let edge: Int
    /// 空いた角の隣（X の升と C の升）の石 1 つの損。相手に角を渡しやすい。
    let danger: Int
    /// 打てる升の数の差 1 つあたりの値。
    let mobility: Int
    /// 石の数の差 1 つあたりの値。
    let discs: Int
}
