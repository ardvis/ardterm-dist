cask "ardterm" do
  version "0.1.1"
  sha256 "7efcbd77b649854f871bf057dcb3a0518d8538f470a75f2cfbe311eeeba85a2e"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
