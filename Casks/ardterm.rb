cask "ardterm" do
  version "0.1.15"
  sha256 "7f2f50f2b752fb2736a7fc35a057048b11d8230c2668ae5daf377fee2712ae79"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on cask: "font-fira-code"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
