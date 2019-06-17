require "language/node"

class ImageoptimCli < Formula
  desc "CLI for ImageOptim, ImageAlpha and JPEGmini"
  homepage "https://jamiemason.github.io/ImageOptim-CLI/"
  url "https://github.com/JamieMason/ImageOptim-CLI/archive/2.3.6.tar.gz"
  sha256 "9b8ad6bbea060b1ae67d1b7d42e1606c9d649f58e1e92a5a4cdbcea82a4bffec"

  bottle do
    cellar :any_skip_relocation
    sha256 "30cedd350da40ba28e82942531b611bcb108676d6c50f625b92553d48b51c81f" => :mojave
    sha256 "64ded277ec1e03e05754a02f51c8ac18866b91abc15decd86760f6043d3f2950" => :high_sierra
    sha256 "abeda37cf2377abc740158bd64c30ada8aaf491a3e6ee16afe89c31fc90e0c9c" => :sierra
  end

  depends_on "node@10" => :build
  depends_on "yarn" => :build

  def install
    system "yarn"
    system "npm", "run", "build"
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/imageoptim -V").chomp
  end
end
