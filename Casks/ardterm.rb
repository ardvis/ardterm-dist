cask "ardterm" do
  version "0.1.4"
  sha256 "fefbf9468b7702a08e12251e7a8eecfc977ad991d70356a26d1b8a6d1be02cf6"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
