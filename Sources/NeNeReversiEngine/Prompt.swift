import NeNeReversiCore

/// 誰が、どの出来事について話すか。
struct Prompt: Sendable, Hashable {
    let speaker: Disc
    let cue: Cue
}
