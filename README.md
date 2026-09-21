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
