class Jellyfish < Formula
  desc "Fast, memory-efficient counting of DNA k-mers"
  homepage "http://www.genome.umd.edu/jellyfish.html"
  url "https://github.com/gmarcais/Jellyfish/releases/download/v2.3.0/jellyfish-2.3.0.tar.gz"
  sha256 "e195b7cf7ba42a90e5e112c0ed27894cd7ac864476dc5fb45ab169f5b930ea5a"
  license any_of: ["BSD-3-Clause", "GPL-3.0-or-later"]

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "f684c546aded8b84b1ef0bf20e87dd88c2dd0a6bd8f6298d3c62c73b0c825d6b"
    sha256 cellar: :any,                 arm64_ventura:  "9e0526e92d9b87bb9c26732174f0aa7b700db587e965941bd79d1bfc761a8b3e"
    sha256 cellar: :any,                 arm64_monterey: "3368a53a61d961a9169a4156a60d8023aee069084c108d67e8b81d12c01e5106"
    sha256 cellar: :any,                 arm64_big_sur:  "15ceae21239d0a1f851e878d20889ef5539b121222153829b3b1e2dcb6cc2548"
    sha256 cellar: :any,                 sonoma:         "8ef9e9c705140f0f1888e63640547298b925d94bd49e5ff724c6a7e54c836840"
    sha256 cellar: :any,                 ventura:        "d1331785c605eee45bfa7053ad06da959b624d2af91c5a032da5350b0c1820f2"
    sha256 cellar: :any,                 monterey:       "00ffb57295d4f3362c58fc69bb017c183efbb7a7533a57d49cbf2dd83ca4d5cb"
    sha256 cellar: :any,                 big_sur:        "04b22121bce09df2e3cee997d3973a12e9f58e9b5e928465502eb4e83d429352"
    sha256 cellar: :any,                 catalina:       "0ce228d3b386be6f7e10bed1186abfc74544658e092defaa4a7001a06c7f0eed"
    sha256 cellar: :any,                 mojave:         "78083728d3d3d1cba0ec71786d1f633c4a626c1b64432ce46f84dacfb0a714d6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1e1922bf36c12b1d56d19e1ead6bd461000bd7ed19a8ac5cfd4398f2bbd54e61"
  end

  depends_on "pkg-config" => :build
  depends_on "htslib"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
  end

  def install
    system "./configure", *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.fa").write <<~EOS
      >Homebrew
      AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC
    EOS
    system "#{bin}/jellyfish", "count", "-m17", "-s100M", "-t2", "-C", "test.fa"
    assert_match "1 54", shell_output("#{bin}/jellyfish histo mer_counts.jf")
    assert_match(/Unique:\s+54/, shell_output("#{bin}/jellyfish stats mer_counts.jf"))
  end
end
