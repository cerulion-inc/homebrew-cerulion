# The release workflow writes this file.
class Cerulion < Formula
  desc "Zero-copy, deterministic communication for real-time robotics"
  homepage "https://github.com/cerulion-inc/cerulion"
  license "AGPL-3.0-only"
  version "2.0.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/cerulion-inc/cerulion/releases/download/v2.0.0/cerulion-2.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "58fed1e4560ae060a5cfa4e380d1b192cdad600df8ece93d7292dddd1ec5d4a2"
    else
      url "https://github.com/cerulion-inc/cerulion/releases/download/v2.0.0/cerulion-2.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "89647614be48d6d9bd5c6cdfbcc3a4f4878f38fb421e7269f150eb1a788055ea"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/cerulion-inc/cerulion/releases/download/v2.0.0/cerulion-2.0.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "b308209d939d674bf8d80fb617e6ec5f5feaf96fc0fdab310f48cb6f09b4d723"
    else
      url "https://github.com/cerulion-inc/cerulion/releases/download/v2.0.0/cerulion-2.0.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0d0074bad212bffc8a1a8fbd66bc9da79ad5b13fbd5b120bc9d063635af16ab9"
    end
  end

  def install
    ["cerulion", "cerulion-netd", "cerulion-connectd", "cerulion-remoted"].each do |binary|
      path = Dir["{,*/}#{binary}"].find { |candidate| File.file?(candidate) }
      odie "release archive is missing #{binary}" unless path
      bin.install path
    end

    # The ROS 2 Jazzy rmw and the heap hook ship in the Linux archives only
    # and sit beside the CLI, where `cerulion ros2 run` looks for both.
    # macOS archives carry neither: ROS 2 Jazzy has no macOS binaries.
    on_linux do
      ["librmw_cerulion.so", "libcerulion_heaphook.so"].each do |library|
        path = Dir["{,*/}#{library}"].find { |candidate| File.file?(candidate) }
        odie "release archive is missing #{library}" unless path
        bin.install path
      end
    end

    # The license notices the archive carries. Installing these binaries
    # redistributes the dependency graph they statically link, and most of
    # those licenses require the license text and the copyright notice to
    # accompany a binary distribution. They land in the formula's doc
    # directory, the Homebrew counterpart of the Debian package's
    # /usr/share/doc/cerulion. Missing ones stop the install rather than
    # producing an installation with nothing to point a reader at.
    ["LICENSE", "NOTICE", "LICENSE-BSD-3-CLAUSE",
     "THIRD-PARTY-LICENSES.md"].each do |notice|
      path = Dir["{,*/}#{notice}"].find { |candidate| File.file?(candidate) }
      odie "release archive is missing #{notice}" unless path
      doc.install path
    end

    # The install-provenance marker the CLI reports as its install method in
    # usage telemetry: share/cerulion/install.json one level above its bin.
    (share/"cerulion").mkpath
    (share/"cerulion/install.json").write "{\"method\":\"brew\",\"version\":\"#{version}\"}\n"

    # Homebrew runs the install with HOME pointing at a directory it deletes
    # afterwards, so a formula cannot put a Rust toolchain in the home folder
    # of the person installing it. Carry the archive's own setup helper, which
    # installs current stable Rust (1.95 or newer), and hand over one command
    # instead.
    helper = Dir["{,*/}install_rust.sh"].find { |candidate| File.file?(candidate) }
    if helper
      libexec.install helper
      (bin/"cerulion-install-rust").write <<~WRAPPER
        #!/bin/sh
        if [ "$#" -ne 0 ]; then
            echo "usage: cerulion-install-rust" >&2
            exit 2
        fi
        # The helper speaks for the archive installer, whose failure arms say
        # the Cerulion binaries were left alone. Here they are already
        # installed and nothing was staged to replace, so say what happened.
        /bin/sh "#{opt_libexec}/install_rust.sh"
        status=$?
        if [ "$status" -ne 0 ]; then
            echo "The Cerulion programs are installed; only the compiler setup failed." >&2
        fi
        exit "$status"
      WRAPPER
      chmod 0755, bin/"cerulion-install-rust"
    end

    generate_completions_from_executable(bin/"cerulion", "completions")
  end

  # Printed unconditionally, so `brew info cerulion` carries the one extra
  # command before anyone installs anything.
  def caveats
    <<~TEXT
      Running Cerulion needs nothing further. Building your own nodes needs
      Rust 1.95 or newer. Install current stable Rust with:

        cerulion-install-rust

      Then put Cargo's programs on your PATH, in your shell startup file:

        export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"

      That is a separate step because Homebrew itself never writes into your
      home folder, and a Rust toolchain lives there.
    TEXT
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cerulion --version")
  end
end
