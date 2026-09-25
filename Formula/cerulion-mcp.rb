# Rendered by scripts/render_cerulion_mcp.sh from the cerulion-mcp release
# workflow's SHA256SUMS. Do not edit by hand.
# The checksums are zero until cerulion-mcp v0.1.0 is released.
class CerulionMcp < Formula
  desc "MCP server that lets AI coding agents drive the Cerulion CLI"
  homepage "https://docs.cerulion.com/cerulion/guides/connect-an-mcp-client"
  license :cannot_represent

  # The MCP server drives the Cerulion CLI as a separate process.
  depends_on "cerulion-inc/cerulion/cerulion"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/cerulion-inc/cerulion-mcp/releases/download/v0.1.0/cerulion-mcp-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    else
      url "https://github.com/cerulion-inc/cerulion-mcp/releases/download/v0.1.0/cerulion-mcp-0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/cerulion-inc/cerulion-mcp/releases/download/v0.1.0/cerulion-mcp-0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    else
      url "https://github.com/cerulion-inc/cerulion-mcp/releases/download/v0.1.0/cerulion-mcp-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "bin/cerulion_mcp"
    # Proprietary licence and the notices (licences and source revisions) of
    # every crate the binary links, including its first-party AGPL-3.0
    # crates; the archive's own README, client examples and demo workspace
    # go beside them.
    doc.install "LICENSE", "THIRD_PARTY_NOTICES", "README.md", "manifest.json"
    pkgshare.install "config", "demo"
  end

  def caveats
    <<~TEXT
      Add the server to your MCP client with absolute paths, for example:

        claude mcp add --transport stdio cerulion -- \\
          #{opt_bin}/cerulion_mcp --workspace /absolute/path/to/robot-workspace \\
          --bin #{HOMEBREW_PREFIX}/bin/cerulion

      Client examples: #{opt_pkgshare}/config
      Demo workspace:  #{opt_pkgshare}/demo/pd_tracking_demo
      Nodes need the CLI's Rust compiler once: cerulion-install-rust
    TEXT
  end

  test do
    assert_match "cerulion-mcp #{version}", shell_output("#{bin}/cerulion_mcp --version")
    request = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18",' \
              '"capabilities":{},"clientInfo":{"name":"brew-test","version":"0"}}}'
    output = pipe_output("#{bin}/cerulion_mcp --workspace #{testpath}", "#{request}\n", 0)
    assert_match "cerulion-mcp", output
  end
end
