#!/bin/sh
# Render Formula/cerulion-mcp.rb from a cerulion-mcp release's SHA256SUMS.
#
# Usage: scripts/render_cerulion_mcp.sh VERSION SHA256SUMS [BASE_URL]
#
# SHA256SUMS is the file the cerulion-mcp release workflow uploads (one
# "<sha256>  cerulion-mcp-<version>-<target>.tar.gz" line per target).
# BASE_URL defaults to the cerulion-mcp GitHub release for VERSION; pass a
# file:// directory to test the formula from a local tap.
set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "usage: $0 VERSION SHA256SUMS [BASE_URL]" >&2
    exit 2
fi
version=$1
sums=$2
base=${3:-https://github.com/cerulion-inc/cerulion-mcp/releases/download/v$version}
out="$(dirname "$0")/../Formula/cerulion-mcp.rb"

sha() {
    value=$(awk -v file="cerulion-mcp-$version-$1.tar.gz" '$2 == file || $2 == "*" file { print $1 }' "$sums")
    case "$value" in
        "" | *[!0-9a-f]*) ;;
        *) [ "${#value}" -eq 64 ] && { echo "$value"; return; } ;;
    esac
    echo "error: $sums has no sha256 for cerulion-mcp-$version-$1.tar.gz" >&2
    exit 1
}
mac_arm=$(sha aarch64-apple-darwin)
mac_x86=$(sha x86_64-apple-darwin)
linux_arm=$(sha aarch64-unknown-linux-gnu)
linux_x86=$(sha x86_64-unknown-linux-gnu)

cat > "$out" <<RUBY
# Rendered by scripts/render_cerulion_mcp.sh from the cerulion-mcp release
# workflow's SHA256SUMS. Do not edit by hand.${NOTE:+
# $NOTE}
class CerulionMcp < Formula
  desc "MCP server that lets AI coding agents drive the Cerulion CLI"
  homepage "https://docs.cerulion.com/cerulion/guides/connect-an-mcp-client"
  license :cannot_represent

  # The MCP server drives the Cerulion CLI as a separate process.
  depends_on "cerulion-inc/cerulion/cerulion"

  on_macos do
    if Hardware::CPU.arm?
      url "$base/cerulion-mcp-$version-aarch64-apple-darwin.tar.gz"
      sha256 "$mac_arm"
    else
      url "$base/cerulion-mcp-$version-x86_64-apple-darwin.tar.gz"
      sha256 "$mac_x86"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "$base/cerulion-mcp-$version-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "$linux_arm"
    else
      url "$base/cerulion-mcp-$version-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "$linux_x86"
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

        claude mcp add --transport stdio cerulion -- \\\\
          #{opt_bin}/cerulion_mcp --workspace /absolute/path/to/robot-workspace \\\\
          --bin #{HOMEBREW_PREFIX}/bin/cerulion

      Client examples: #{opt_pkgshare}/config
      Demo workspace:  #{opt_pkgshare}/demo/pd_tracking_demo
      Nodes need the CLI's Rust compiler once: cerulion-install-rust
    TEXT
  end

  test do
    assert_match "cerulion-mcp #{version}", shell_output("#{bin}/cerulion_mcp --version")
    request = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18",' \\
              '"capabilities":{},"clientInfo":{"name":"brew-test","version":"0"}}}'
    output = pipe_output("#{bin}/cerulion_mcp --workspace #{testpath}", "#{request}\\n", 0)
    assert_match "cerulion-mcp", output
  end
end
RUBY
echo "wrote $out"
