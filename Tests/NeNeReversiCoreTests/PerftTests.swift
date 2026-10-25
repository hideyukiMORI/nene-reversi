import Testing

@testable import NeNeReversiCore

/// perft（初期局面から深さ N までの手の列の数）を公表値と突き合わせる（FR-02）。数え方と回す深さは ADR 0006。
///
/// 期待値の出典（2026-10-26 に取得した本文から写した。記憶では書いていない）:
/// - 出典 1: OEIS A124004「Number of possible Reversi games at the end of the n-th ply」 https://oeis.org/A124004
///   （`fmt=text` の `%S` `%T` 行）。深さ 19〜21 を出した Dominic Hofer の実装
///   https://github.com/PanicSheep/ReversiPerftCUDA の `Perft/Perft.cpp` が同じ表を持ち、数え方（パスは 1 手・途中で終局した列は数えない）を示す
/// - 出典 2: Edax（https://github.com/abulmo/edax-reversi）4.6.13 の `./edax-4.6.13 -count games 17` の出力。
///   作者（abulmo）が 2026-06-04 に Codeberg の blefebvre のリポジトリの Issue #1 に投稿したもの
///   （リポジトリ名に登録商標のゲーム名を含むので URL は書かない・CNF-023）。`moves` の列が深さ 1〜17 で出典 1 と全部一致する
/// パスは深さ 9 から現れる（出典 2 の `passes` の列）。
struct PerftTests {
    /// 深さ 1, 2, … の公表値。
    static let publishedCounts: [Int] = [
        4, 12, 56, 244, 1_396, 8_200, 55_092, 390_216, 3_005_288, 24_571_056, 212_258_216,
    ]

    @Test func matchesPublishedCounts() {
        let measured = (1...Self.publishedCounts.count).map { Self.perft(.initial, depth: $0) }
        #expect(measured == Self.publishedCounts)
    }

    /// 深さ 0 は 1。合法手が空（終局）なら、深さが残っていても 0（その列は深さ N まで届かない）。
    /// 深さ 1 は合法手の数をそのまま数える（葉で局面を作らない）。
    static func perft(_ position: Position, depth: Int) -> Int {
        if depth == 0 {
            return 1
        }
        let moves = position.legalMoves()
        if depth == 1 {
            return moves.count
        }
        return moves.reduce(0) { sum, move in sum + perft(position.applying(move), depth: depth - 1) }
    }
}
