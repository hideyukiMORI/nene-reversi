import NeNeReversiCore

/// 対局中の発言（COMMS）の状態。どの出来事で誰が話すかの規則はここだけにある（ADR 0012）。
///
/// 規則の形は NeNe Gambit の `Banter`（コミット 64b82ec）にならった。
/// - 1 手に 1 行まで。その手でいちばん優先度の高い出来事だけを見て、確率に外れたら黙る
/// - 同じ側は話してから 2 手は黙る（局の始まりと終わりは例外で、両者が続けて話す）
/// - 返しのひと言は次の 1 歩で出す。同じ人は直近 8 回と同じセリフを言わない
/// - 乱数は引数から受け取るので、同じシードからは同じ会話になる
public struct Banter: Sendable, Hashable {
    /// 6 個以上返したら「たくさん返した」。
    static let bigFlip = 6
    /// 出来事の無い手がこの数だけ続くたびに、静かな局面のひと言を考える。
    static let idleEvery = 6

    /// 画面に出す発言（古い順・最後の 2 つ）。
    public let lines: [Remark]
    private let recent: [Persona: [String]]
    private let lastSpokeMove: [Disc: Int]
    private let pending: Prompt?
    private let moveNumber: Int
    /// 出来事（パス・角・たくさん返した）の無い手が続いた数。
    /// 格納が private なので、合成される memberwise init も private になる。
    private let quietMoves: Int

    static let silent = Banter(lines: [], recent: [:], lastSpokeMove: [:], pending: nil, moveNumber: 0, quietMoves: 0)

    /// 局の始まり: 黒、白の順に 1 言ずつ。
    func starting(_ players: Players, using generator: inout some RandomNumberGenerator) -> Banter {
        let fresh = Banter(
            lines: lines, recent: recent, lastSpokeMove: [:], pending: nil, moveNumber: 0, quietMoves: 0)
        return fresh.saying(Prompt(speaker: .black, cue: .start), players, using: &generator)
            .saying(Prompt(speaker: .white, cue: .start), players, using: &generator)
    }

    /// 1 手の後。終局なら両者の最後のひと言、そうでなければ規則に従って 0〜1 行。
    func reacting(
        to facts: MoveFacts, status: PositionStatus, players: Players,
        using generator: inout some RandomNumberGenerator
    ) -> Banter {
        let quiet = Self.isQuiet(facts) ? quietMoves + 1 : 0
        let ticked = Banter(
            lines: lines, recent: recent, lastSpokeMove: lastSpokeMove, pending: nil, moveNumber: moveNumber + 1,
            quietMoves: quiet)
        if case .finished(let result) = status {
            return ticked.finishing(result, players, using: &generator)
        }
        if let pending {
            return ticked.saying(pending, players, using: &generator)
        }
        guard let pick = Self.pick(facts, quietMoves: quiet, using: &generator), ticked.mayTalk(pick.prompt.speaker)
        else {
            return ticked
        }
        let spoken = ticked.saying(pick.prompt, players, using: &generator)
        return Banter(
            lines: spoken.lines, recent: spoken.recent, lastSpokeMove: spoken.lastSpokeMove, pending: pick.reply,
            moveNumber: spoken.moveNumber, quietMoves: spoken.quietMoves)
    }

    private static func isQuiet(_ facts: MoveFacts) -> Bool {
        !facts.isPass && !facts.tookCorner && facts.flipped < bigFlip
    }

    private func mayTalk(_ side: Disc) -> Bool {
        lastSpokeMove[side].map { moveNumber - $0 > 2 } ?? true
    }

    private func finishing(_ result: GameResult, _ players: Players, using generator: inout some RandomNumberGenerator)
        -> Banter
    {
        let order: [Prompt]
        switch result {
        case .blackWins:
            order = [Prompt(speaker: .black, cue: .win), Prompt(speaker: .white, cue: .lose)]
        case .whiteWins:
            order = [Prompt(speaker: .white, cue: .win), Prompt(speaker: .black, cue: .lose)]
        case .draw:
            order = [Prompt(speaker: .black, cue: .draw), Prompt(speaker: .white, cue: .draw)]
        }
        return order.reduce(self) { banter, prompt in banter.saying(prompt, players, using: &generator) }
    }

    /// 1 行を言う。直近 8 回のセリフを避けて乱数で選ぶ（全部が直近なら避けない）。
    private func saying(_ prompt: Prompt, _ players: Players, using generator: inout some RandomNumberGenerator)
        -> Banter
    {
        let persona = players.persona(for: prompt.speaker)
        let all = persona.lines(for: prompt.cue)
        let said = recent[persona] ?? []
        let fresh = all.filter { !said.contains($0) }
        let text = (fresh.isEmpty ? all : fresh).randomElement(using: &generator) ?? ""
        var remembered = recent
        remembered[persona] = Array((said + [text]).suffix(8))
        var spoke = lastSpokeMove
        spoke[prompt.speaker] = moveNumber
        let remark = Remark(side: prompt.speaker, persona: persona, cue: prompt.cue, text: text)
        return Banter(
            lines: Array((lines + [remark]).suffix(2)), recent: remembered, lastSpokeMove: spoke, pending: nil,
            moveNumber: moveNumber, quietMoves: quietMoves)
    }

    /// その手でいちばん優先度の高い出来事と、その確率の抽選の結果。
    /// パス（必ず・相手が 50% で返す）＞角（80%・もう片方が 40% で返す）＞たくさん返した（60%）＞静かな手が 6 手続くたび（50%・話し手はどちらか半々）。
    static func pick(_ facts: MoveFacts, quietMoves: Int, using generator: inout some RandomNumberGenerator)
        -> BanterPick?
    {
        let mover = facts.mover
        let other = mover.opponent
        let roll = Int.random(in: 0..<100, using: &generator)
        let coin = Bool.random(using: &generator)
        if facts.isPass {
            let reply = coin ? Prompt(speaker: other, cue: .forcedPass) : nil
            return BanterPick(prompt: Prompt(speaker: mover, cue: .passing), reply: reply)
        }
        if facts.tookCorner {
            let gloat = Prompt(speaker: mover, cue: .corner)
            let groan = Prompt(speaker: other, cue: .cornerLost)
            let answer = roll % 5 < 2 ? (coin ? groan : gloat) : nil
            return roll < 80 ? BanterPick(prompt: coin ? gloat : groan, reply: answer) : nil
        }
        if facts.flipped >= bigFlip {
            let prompt = coin ? Prompt(speaker: mover, cue: .bigFlip) : Prompt(speaker: other, cue: .flipped)
            return roll < 60 ? BanterPick(prompt: prompt, reply: nil) : nil
        }
        if quietMoves > 0, quietMoves % idleEvery == 0, roll < 50 {
            // 6 手ごとなので、話し手を手番から決めると同じ区間の中では毎回同じ側になる（Issue #18）
            return BanterPick(prompt: Prompt(speaker: coin ? mover : other, cue: .idle), reply: nil)
        }
        return nil
    }
}
