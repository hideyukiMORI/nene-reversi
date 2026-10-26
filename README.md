# NeNe Reversi

> *Four smug little programs play Reversi in your terminal. Forever. Press `q` to make them stop.*

A terminal screensaver in which a cast of four plays Reversi with a hand-written AI, game after game, commenting on every corner they steal.
When one game ends, the next one starts. You don't have to do anything. Just watch, and smirk now and then.
It is the sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit), the chess version.

[![release](https://img.shields.io/github/v/release/hideyukiMORI/nene-reversi)](https://github.com/hideyukiMORI/nene-reversi/releases/latest)
![platform](https://img.shields.io/badge/platform-Linux%20x86__64%20%2F%20WSL2-555)
![license](https://img.shields.io/badge/license-MIT-555)

**English** · [日本語](README.ja.md)

![CORNER.SYS beats FLIP.BAT 54-10 in the NEON theme](docs/images/result-neon.png)

<sub>A real screenshot: the v0.1.0 binary running in Windows Terminal on WSL2 (`--seed 11`, 120×30, captured at 1859×1079 px).
CORNER.SYS has just filled the board, 54 to 10. FLIP.BAT demands an audit.</sub>

> **Beta.** v0.1.0 is the first release. The look and the cast may still be tuned.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-reversi/main/install.sh | bash
```

This downloads the latest [release](https://github.com/hideyukiMORI/nene-reversi/releases/latest), verifies it against `SHA256SUMS`,
and only then installs it as `~/.local/bin/nene-reversi`. If the checksum doesn't match, nothing is installed.
The whole script is [install.sh](install.sh), about 45 lines. Reading it before you pipe it takes under a minute.

- Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04+). Tested on Ubuntu under WSL2 with Windows Terminal
- No Swift needed. It is a single file with the Swift standard library linked statically; the only dynamic dependencies are libc, libm, libstdc++ and libgcc_s
- To uninstall: `rm ~/.local/bin/nene-reversi`

<details>
<summary>Install by hand</summary>

```bash
v=0.1.0
curl -fsSL -O https://github.com/hideyukiMORI/nene-reversi/releases/download/v$v/nene-reversi-$v-linux-x86_64.tar.gz \
           -O https://github.com/hideyukiMORI/nene-reversi/releases/download/v$v/SHA256SUMS
sha256sum --check SHA256SUMS
tar -xzf nene-reversi-$v-linux-x86_64.tar.gz
./nene-reversi-$v-linux-x86_64/nene-reversi
```
</details>

## How to play (well, how to watch)

```bash
nene-reversi
```

| Key | |
| --- | --- |
| `q` | Quit (Ctrl+C works too; however it ends, your terminal is restored) |
| `t` | Next color theme (12 in total) |

| Option | |
| --- | --- |
| `--theme NAME` | `NEON` `PHOSPHOR` `AMBER` `SYNTHWAVE` `GLACIER` `BLOODMOON` `VAPOR` `MONO` `TOXIC` `GILDED` `ABYSS` `PAPER` |
| `--seed N` | Same seed, same games, **same banter** |
| `--move-interval SEC` | Time per move (default 1.0 s) |
| `--result-pause SEC` | How long the result stays up after a game (default 3 s) |
| `--version` | Print the version and exit |

The terminal needs at least 75×22. At **93×30 or larger you get the big board** (six columns by three rows per square).
If the window is too small, it tells you, in one line, how big it needs to be.

### Reading the screen

![A game in progress in the NEON theme](docs/images/game-neon.png)

- **Board**: discs are blocks painted in the disc color, not characters. The square of the last move is bracketed `[ ]`
- **MATCH**: game number, who plays Black and White, whose turn it is and how many moves have been played
- **DISCS**: how many discs each side has right now, as bars
- **SCORE**: running totals of Black wins, White wins and draws
- **LOG**: the most recent moves, Black and White side by side. A pass is a move too, written `PASS`. The cursor `▌` sits in the column of the side to move
- **RESULT**: appears when a game ends: the winner and the final count, why it ended (`BOARD FULL` or `NO MOVES LEFT`) and a countdown to the next game
- **COMMS**: the two lines under the board, the latest things the cast said. The brighter line is the newer one

## The cast

At the start of every game, two of the four are drawn at random to sit at Black and White. Each plays differently, and each is insufferable differently.

| | How they play | In their words |
| --- | --- | --- |
| **FLIP.BAT** `$_$` | Greedy. Counts discs like assets and loves big flips. Looks 3 moves ahead | *"Every disc on this board is a future asset. Mine, specifically."* |
| **CORNER.SYS** `[=]` | Cold strategist. Trusts only corners and edges. Searches deepest, 4 moves ahead, and solves the last 10 empty squares exactly | *"Kernel loaded. Emotions unloaded."* |
| **SPAM.EML** `\o/` | A cheerful spam email. Looks 2 moves ahead and strays far from the best-looking move. Does take corners | *"CONGRATULATIONS! You have been selected to lose at Reversi!"* |
| **LAZY.CRON** `zzz` | A cron job that would rather not. Flips as little as possible and starves the opponent of moves. Looks 3 moves ahead | *"Scheduled to start. Not scheduled to try."* |

Over 96 measured games, CORNER.SYS and LAZY.CRON win about three games in four, but FLIP.BAT and SPAM.EML still beat them about one time in eight.
Each character has 50 lines, written for specific events: big flips, being flipped, taking a corner, losing one, passing, forcing a pass, quiet stretches, winning, losing, drawing.
A few of them:

> **FLIP.BAT** (after losing) *"Error: insufficient discs. Press any key to cry."*<br>
> **CORNER.SYS** (taking a corner) *"This square is permanent. Like my disappointment in you."*<br>
> **SPAM.EML** (losing a corner) *"ERROR 404: corner not found. Have you tried rebooting?"*<br>
> **LAZY.CRON** (forced to pass) *"Pass. Best move I've made all day."*

The other 196 are yours to collect.

## Twelve themes

Cycle with `t`: `NEON` (default), `PHOSPHOR` (green CRT), `AMBER` (amber CRT), `SYNTHWAVE`, `GLACIER`, `BLOODMOON`, `VAPOR`, `MONO`, `TOXIC`, `GILDED`, `ABYSS`, and `PAPER` (the only light theme).
The palettes are NeNe Gambit's, with Reversi's own rules on top.

| SYNTHWAVE | PHOSPHOR |
| --- | --- |
| ![SYNTHWAVE](docs/images/synthwave.png) | ![PHOSPHOR](docs/images/phosphor.png) |
| **BLOODMOON** | **PAPER** |
| ![BLOODMOON](docs/images/bloodmoon.png) | ![PAPER](docs/images/paper.png) |

In every theme, letters and digits have a contrast ratio of at least 4.5:1 against their background, discs stand out from both square colors by at least 3:1,
the two disc colors differ in lightness by at least 2.2:1, and **the Black disc is always the darker one** (more on that below).
No human eyeballs this: a test computes it every time from the colors of the cells it actually renders.

---

## Under the hood (a story in seven parts)

NeNe Reversi wears the face of a screensaver, but like its sibling it is also **an experiment in having machines enforce the rules**.
Everything from the first rule to this release happened in two days, 2026-10-25 and 26. Every number below is in the repository's records (ADRs, tests, gate proofs).

### 1. The AI is written from scratch, and perft was nearly wrong from memory

No Reversi engine, no library. The product has zero external dependencies.
Move generation is checked with **perft**: the number of move sequences possible from the starting position down to depth N, compared against published values.
In Reversi that number depends on how you count passes, so the counting rule was taken from the code of the person who computed the published values (pass counts as a move; a game that ends early doesn't reach depth N).

The expected values were copied from two independent sources (OEIS A124004 and the output of the Edax engine), never from memory, as the project's rules demand.
That rule earned its keep on day one: the value remembered for depth 10 was 24,571,284. The published value is **24,571,056**.

- Depths 1 to 11, **240,289,780 sequences in total**, match exactly. Passes first appear at depth 9 and finished games at depth 10, so the counting rule is actually exercised
- The board is two 64-bit integers, one per color. Depth 11 takes about 5 seconds in the release configuration, on every `make check` ([ADR 0005](docs/adr/0005-bitboards-and-move-representation.md), [ADR 0006](docs/adr/0006-perft-counting-and-gate-depth.md))
- "Is this a pass?" and "is the game over?" are answered in exactly one place: the list of legal moves contains `PASS` when you must pass, and is empty when the game is over

### 2. Discs are painted, not typed

NeNe Gambit spent four round trips getting chess symbols to sit straight in Windows Terminal: the terminal says a symbol is one column wide and then draws it two wide, and one pawn turned into a purple emoji.
So here, **discs are not characters at all**. They are blank cells painted in the disc color, an even number of columns wide. Every character on the screen is ASCII, except the box-drawing frame, which is used only after measuring that the terminal draws it one column wide.

### 3. The first real screenshot showed columns, not discs

The first design painted each disc as a little cross (2, 4 and 2 columns over three rows) that reached the top and bottom edges of its square.
The first screenshot from a real Windows Terminal showed what that means: discs in the same column **touched and fused into vertical pillars**. You couldn't count them.
Two alternatives were photographed side by side; the winner leaves the top row of every square empty. A test now fails if any disc touches the top row of its square ([ADR 0009](docs/adr/0009-disc-blocks-leave-the-top-row.md)).

### 4. On paper, White was black

The twelve palettes come from NeNe Gambit. In its light `PAPER` theme, the White pieces are ink and the Black pieces are red, which is fine for chess.
In Reversi, the screenshot showed **White discs that were plainly black**. Since the disc color is the whole meaning of a disc, a rule went in: the Black disc must be the darker of the two, checked for all twelve themes. On PAPER, the colors were swapped ([ADR 0011](docs/adr/0011-cyber-hud-themes-and-frame.md)).

### 5. An AI that never reads the clock, tuned by counting games

The search stops after a fixed depth and node budget, not after a number of seconds. The board, AI and rendering code **cannot read** the time, random numbers or environment variables; if they try, a home-grown check fails the build.
Randomness comes from a seeded SplitMix64, which is why `--seed 42` gives you the same games and the same trash talk every time.

With the first weights, the two strong characters won **all 64 of 64** games against the two weak ones, by 40 to 60 discs. That makes a dull screensaver.
The weak ones learned to fear the squares next to an empty corner, the strong ones got a wider margin of randomness, and after re-measuring 96 games the underdogs win 12.5% of the time ([ADR 0010](docs/adr/0010-evaluation-search-and-cast.md)).

### 6. Rules aren't written down, they're enforced

The repository has 72 rules, each with an ID and a status saying whether a machine enforces it. Right now **51 are active** (break one and `make check` fails); the rest are honestly labeled "planned" or "cannot be enforced by a machine" ([quality gates](docs/QUALITY_GATES.md)).
Before any product code, Swift 6.4.1 was measured in 75 cases ([phase0-results.json](docs/quality/phase0-results.json)). Among the findings: `case (let x):`, `case .a, _:` and `case (_, _):`
all silently kill the `switch` exhaustiveness check, and **the sibling project's check let all three through**. This repository's check catches them.
No check is trusted until it has been seen to fail: violations were planted one at a time, **64 of them** plus a clean control, and each was caught by the intended rule ([gate proofs](docs/quality/gate-proofs.md)).

### 7. The bug the README found

While taking the screenshots for this README, the two COMMS lines were both CORNER.SYS making small talk.
The quiet-stretch remark came every six moves from "the opponent of whoever just moved", and six is even, so within a quiet stretch **it was always the same character**: 55 of 57 back-to-back remarks.
The test was written first and seen to fail; now the speaker is a coin flip (24 of 51).

---

## Development

```bash
make bootstrap           # once after cloning (commit hook and a static SwiftLint binary)
make check               # the one definition of done, identical locally and on CI (build, tests incl. perft, format, lint, conformance, terminal smoke, commit format)
make release TAG=v<ver>  # build the release artifacts (only if they pass the checks)
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product. About 2,900 lines of source and 900 lines of tests
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). Design decisions are in 13 [ADRs](docs/adr/README.md); requirements and the owner's decisions are in [REQUIREMENTS.md](docs/REQUIREMENTS.md) (both in Japanese)
- Humans and AI write under the same rules and the same gates. The code here was written by Claude Code; the project owner set the direction and made the decisions

## License

MIT ([LICENSE](LICENSE))
