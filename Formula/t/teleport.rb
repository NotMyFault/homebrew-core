class Teleport < Formula
  desc "Modern SSH server for teams managing distributed infrastructure"
  homepage "https://goteleport.com/"
  url "https://github.com/gravitational/teleport/archive/refs/tags/v14.2.1.tar.gz"
  sha256 "c71fb53887b8067ae0ddc738464c26be545d96727c586a307526982f9c05c638"
  license "Apache-2.0"
  head "https://github.com/gravitational/teleport.git", branch: "master"

  # As of writing, two major versions of `teleport` are being maintained
  # side by side and the "latest" release can point to an older major version,
  # so we can't use the `GithubLatest` strategy. We use the `GithubReleases`
  # strategy instead of `Git` because there is often a notable gap (days)
  # between when a version is tagged and released.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "33528f4defb524b912eb1317ca533735b254810668962391d60ecabae9f1a703"
    sha256 cellar: :any,                 arm64_ventura:  "4ee570333833a4557ea55c2c1e14bf841bb6fe998c659fa07d4960e0492abda7"
    sha256 cellar: :any,                 arm64_monterey: "112674d9c81f2e256601b04a5b398eae566f8dbfb163f795ef26683448a5fbae"
    sha256 cellar: :any,                 sonoma:         "a5d3194895ddd0cf792bb8a88daeb68227790a0661bc419814a615d7ee8cf532"
    sha256 cellar: :any,                 ventura:        "2a4efbdc9d947f766f60cb1a165082e4180d18de6bb9c41e7a376ae0dbd478e8"
    sha256 cellar: :any,                 monterey:       "ec5f3bf5910737c1062bfebbba872aa597465ae679465a5552c9dd70f10033dc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a7ab2ffe79660d25489c371784f9525d04b06a70303fdfc866bcad955029c551"
  end

  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "yarn" => :build
  depends_on "libfido2"
  depends_on "node"
  depends_on "openssl@3"

  uses_from_macos "curl" => :test
  uses_from_macos "netcat" => :test
  uses_from_macos "zip"

  conflicts_with "etsh", because: "both install `tsh` binaries"

  def install
    ENV.deparallelize { system "make", "full", "FIDO2=dynamic" }
    bin.install Dir["build/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/teleport version")
    assert_match version.to_s, shell_output("#{bin}/tsh version")
    assert_match version.to_s, shell_output("#{bin}/tctl version")

    mkdir testpath/"data"
    (testpath/"config.yml").write <<~EOS
      version: v2
      teleport:
        nodename: testhost
        data_dir: #{testpath}/data
        log:
          output: stderr
          severity: WARN
    EOS

    fork do
      exec "#{bin}/teleport start --roles=proxy,node,auth --config=#{testpath}/config.yml"
    end

    sleep 10
    system "curl", "--insecure", "https://localhost:3080"

    status = shell_output("#{bin}/tctl --config=#{testpath}/config.yml status")
    assert_match(/Cluster\s*testhost/, status)
    assert_match(/Version\s*#{version}/, status)
  end
end
