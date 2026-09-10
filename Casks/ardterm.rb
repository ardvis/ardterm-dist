cask "ardterm" do
  version "0.1.8"
  sha256 "9ae78a0969a7d813d4bfc1f60c6df22ffc1ca9f8a718d61e0be0e4aea2ffcd46"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on cask: "font-fira-code"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
