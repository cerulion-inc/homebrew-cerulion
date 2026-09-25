# Homebrew tap for Cerulion

```bash
brew tap cerulion-inc/cerulion
brew install cerulion-inc/cerulion/cerulion
```

The first line adds this repository as a tap; the second installs the `cerulion` command-line tools. Homebrew treats a third-party tap as untrusted until you install a fully qualified name, which is why the second line spells the formula out; on Homebrew 6.0.x, if the tap itself is refused, run `brew trust --formula cerulion-inc/cerulion/cerulion` first and try again.

Building your own nodes needs one more command, run once, and Cargo's programs on your PATH:

```bash
cerulion-install-rust
export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"
```

The formula in `Formula/cerulion.rb` is generated for each release of [cerulion-inc/cerulion](https://github.com/cerulion-inc/cerulion) by that repository's release workflow, which opens a pull request here with the checksums published in the release. Report problems with Cerulion itself in the [main repository](https://github.com/cerulion-inc/cerulion/issues); this repository holds only the formula.

## Cerulion MCP

```bash
brew install cerulion-inc/cerulion/cerulion-mcp
```

installs `cerulion_mcp`, the MCP server that lets AI coding agents (Claude Code, Codex, Cursor, ...) drive the Cerulion CLI; it pulls in the `cerulion` formula. It is proprietary, binary-only software; see [Connect an MCP client](https://docs.cerulion.com/cerulion/guides/connect-an-mcp-client). `Formula/cerulion-mcp.rb` is rendered by `scripts/render_cerulion_mcp.sh VERSION SHA256SUMS [BASE_URL]` from the `SHA256SUMS` that the cerulion-mcp release workflow uploads. To try an unreleased build, pass a `file://` directory holding the archives as `BASE_URL` and install from a local tap (`brew tap cerulion-inc/cerulion /path/to/this/checkout`).
