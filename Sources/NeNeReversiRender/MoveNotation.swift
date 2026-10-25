import NeNeReversiCore

/// 手の表示用の表記。升の名前（`d3`）への変換を持つのは Render のここだけ（PROJECT_LAYOUT 第 3 節）。
public enum MoveNotation {
    private static let columnLetters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]

    /// 升の名前。列の文字（a〜h）と行の番号（1〜8・1 行目が盤の上端）。
    public static func name(of square: Square) -> String {
        "\(columnLetters[square.column])\(square.row + 1)"
    }

    /// 手の表記。打つ手は升の名前、パスは `PASS`。
    public static func text(of move: Move) -> String {
        switch move.kind {
        case .place(let square):
            return name(of: square)
        case .pass:
            return "PASS"
        }
    }
}
