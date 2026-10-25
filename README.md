# NeNe Reversi

A terminal screensaver in which two hand-written Reversi AIs play each other, game after game, until you press `q`.
Written in Swift for Ubuntu on WSL2 and Windows Terminal. The Reversi AI (legal moves, evaluation, alpha-beta search) is written from scratch,
with no external engine. It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit), the chess version.

🚧 **Nothing runs on screen yet.** Legal move generation, flipping, passing and game-over detection are in place, with no screen,
and perft matches the published counts from the initial position up to depth 11. Drawing the board comes next.

## Development

```bash
make bootstrap   # once after cloning (commit hook and a static SwiftLint binary)
make check       # the one definition of done, identical locally and on CI
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). What the machines enforce right now is in [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md); the owner's decisions are in [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)

## License

MIT ([LICENSE](LICENSE))
