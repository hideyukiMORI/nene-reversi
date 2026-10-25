import NeNeReversiCore

/// アルファベータ探索（FR-03）。深さを 1 から上げていき、ノード数の上限を超えたら 1 つ浅い深さの結果を使う（ADR 0010）。
///
/// 時計を読まない（ARC-007）。乱数は引数で受け取るので、同じシードからは同じ手が出る。パスも手の 1 つとして読む（ADR 0005）。
struct Searcher {
    private static let infinity = Evaluator.win * 2

    private let weights: StyleWeights
    private let nodeLimit: Int
    private var nodes = 0
    private var exhausted = false

    private init(weights: StyleWeights, nodeLimit: Int) {
        self.weights = weights
        self.nodeLimit = nodeLimit
    }

    /// その局で打つ手。合法手が無ければ nil。返す手は必ず `game.legalMoves()` の中にある。
    static func choose(in game: Game, profile: SearchProfile, using generator: inout some RandomNumberGenerator)
        -> Move?
    {
        let position = game.position
        let moves = ordered(position.legalMoves(), in: position, weights: profile.weights)
        guard let first = moves.first else {
            return nil
        }
        guard moves.count > 1 else {
            return first
        }
        let empties = 64 - position.count(of: .black) - position.count(of: .white)
        let depth = empties <= profile.solveEmpties ? empties + 2 : profile.depth
        var searcher = Searcher(weights: profile.weights, nodeLimit: profile.nodeLimit)
        var scored = moves.map { ScoredMove(move: $0, score: 0) }
        for current in 1...max(depth, 1) {
            let round = searcher.scoreRoot(moves, in: position, depth: current)
            if searcher.exhausted {
                break
            }
            scored = round
        }
        let margin = game.moves.count < profile.openingMoves ? profile.openingMargin : profile.tieMargin
        let best = scored.map(\.score).max() ?? 0
        let candidates = scored.filter { $0.score >= best - margin }
        return candidates.randomElement(using: &generator)?.move ?? first
    }

    private mutating func scoreRoot(_ moves: [Move], in position: Position, depth: Int) -> [ScoredMove] {
        var round: [ScoredMove] = []
        let full = Window(alpha: -Self.infinity, beta: Self.infinity)
        for move in moves {
            let score = -negamax(position.applying(move), depth: depth - 1, window: full)
            if exhausted {
                return round
            }
            round.append(ScoredMove(move: move, score: score))
        }
        return round
    }

    private mutating func negamax(_ position: Position, depth: Int, window: Window) -> Int {
        nodes += 1
        if nodes > nodeLimit {
            exhausted = true
            return 0
        }
        let moves = position.legalMoves()
        if moves.isEmpty {
            return Evaluator.final(
                position.count(of: position.sideToMove) - position.count(of: position.sideToMove.opponent))
        }
        if depth <= 0 {
            return Evaluator.score(position, weights: weights)
        }
        var current = window
        for move in Self.ordered(moves, in: position, weights: weights) {
            let score = -negamax(position.applying(move), depth: depth - 1, window: current.flipped)
            if exhausted {
                return 0
            }
            if score >= current.beta {
                return current.beta
            }
            current = current.raising(to: score)
        }
        return current.alpha
    }

    /// 升の値の高い順（角が先、空いた角の隣が後）に並べる。同じ値なら元の順（a1 から h8）。
    static func ordered(_ moves: [Move], in position: Position, weights: StyleWeights) -> [Move] {
        func key(_ move: Move) -> Int {
            switch move.kind {
            case .place(let square):
                return Evaluator.squareValue(square, in: position, weights: weights)
            case .pass:
                return 0
            }
        }
        return moves.enumerated().sorted { lhs, rhs in
            let (left, right) = (key(lhs.element), key(rhs.element))
            return left != right ? left > right : lhs.offset < rhs.offset
        }.map(\.element)
    }
}
