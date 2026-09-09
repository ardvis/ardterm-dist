cask "ardterm" do
  version "0.1.6"
  sha256 "4ad499dc8d314c639e29857cd043f7bbfebe0a13ebce86080d6787bc3f81fede"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on cask: "font-fira-code"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
