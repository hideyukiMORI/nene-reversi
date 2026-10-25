/// HUD の 1 行。見出しは強調の色で描く。
struct HudLine: Sendable, Hashable {
    let text: String
    let heading: Bool
}
