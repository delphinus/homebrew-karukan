# typed: false
# frozen_string_literal: true

# karukan-server, the HTTP server of karukan (togatoga/karukan) that converts
# kana to kanji with a small language model run by llama.cpp. Upstream has
# released only v0.1.0 (2026-02), so this formula pins a commit of master.
class KarukanServer < Formula
  desc "Neural kana-kanji conversion server of karukan"
  homepage "https://github.com/togatoga/karukan"
  # pinned commit: 2f0a00a1802538b668e11b49760d4a97f717b637 (2026-11-21)
  url "https://github.com/togatoga/karukan/archive/2f0a00a1802538b668e11b49760d4a97f717b637.tar.gz"
  # The version of karukan-cli in Cargo.toml, then the date of the commit:
  # the Cargo version stays 0.1.0 while master moves.
  version "0.1.0.20261121"
  sha256 "03b6c00bda59124d0312de49ed6f8de729f84c694b30a1e47b4b82cb97e4d1a4"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/togatoga/karukan.git", branch: "main"

  bottle do
    root_url "https://github.com/delphinus/homebrew-karukan/releases/download/karukan-server-0.1.0.20261121"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "0a123974d829f68c755731ee7cfc111a0c10e110a78476c25d446028a902ff5c"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  def install
    # karukan-cli has other binaries (karukan-dict, sudachi-dict, ajimee-bench);
    # only the server is wanted.
    system "cargo", "install", "--bin", "karukan-server", *std_cargo_args(path: "karukan-cli")
  end

  def caveats
    <<~EOS
      karukan-server listens on http://127.0.0.1:3000 (--host / --port).

      When it starts for the first time, it downloads its models from Hugging
      Face into ~/.cache/huggingface; until they are loaded, it answers 503.
      It loads every model of the [models] table of karukan's config.toml
      (six by default), which takes about 900 MB of memory.
    EOS
  end

  service do
    run opt_bin/"karukan-server"
    keep_alive true
    process_type :interactive
    log_path var/"log/karukan-server.log"
    error_log_path var/"log/karukan-server.log"
  end

  test do
    assert_match "kana-kanji conversion server", shell_output("#{bin}/karukan-server --help")
  end
end
