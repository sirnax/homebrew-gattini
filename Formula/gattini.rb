# Generated from a checksum-verified Gattini release archive.
require "json"
require "shellwords"

class Gattini < Formula
  desc "Local-first durable AI coding job broker"
  homepage "https://github.com/sirnax/gattini"
  url "https://github.com/sirnax/gattini/releases/download/v0.2.0/gattini-0.2.0.tgz"
  sha256 "97ab34442ff72130333945ff177ff82a82c78a469da050ff1f818d0cc027e06f"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos
  depends_on "node@24"

  def install
    source = (buildpath/"package/package.json").exist? ? buildpath/"package" : buildpath
    libexec.install source/"package.json", source/"dist", source/"LICENSE", source/"README.md", source/"docs"
    node = formula_opt_bin("node@24")/"node"
    (bin/"gattini").write <<~SH
      #!/bin/sh
      exec "#{node}" "#{libexec}/dist/src/cli/gattini.js" "$@"
    SH
    (bin/"gattinid").write <<~SH
      #!/bin/sh
      exec "#{node}" "#{libexec}/dist/src/daemon/gattinid.js" "$@"
    SH
    chmod 0755, [bin/"gattini", bin/"gattinid"]
  end

  service do
    run opt_bin/"gattinid"
    keep_alive false
  end

  test do
    state = testpath/"state"
    task = testpath/"task with spaces.txt"
    task.write("Homebrew offline fake job\n")
    ENV["GATTINI_STATE_DIR"] = state.to_s
    pid = spawn((bin/"gattinid").to_s, out: (testpath/"daemon.log").to_s, err: (testpath/"daemon.err").to_s)
    begin
      socket = state/"gattinid.sock"
      100.times do
        break if socket.exist?

        sleep 0.1
      end
      assert_path_exists socket
      command = "#{bin}/gattini run --task-file #{Shellwords.escape(task.to_s)}"
      output = shell_output("#{command} --idempotency-key brew-smoke --role code --json")
      result = JSON.parse(output)
      assert_equal "completed", result.fetch("state")
      assert_equal "unverified", result.fetch("result").fetch("acceptance")
      assert_path_exists state/"jobs.sqlite"
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
