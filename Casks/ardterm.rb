cask "ardterm" do
  version "0.1.2"
  sha256 "d4ce8e75f17845dc9fed7e5fafcf0b4ac62b0583f84755fd659490d2834c9446"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
