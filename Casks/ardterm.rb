cask "ardterm" do
  version "0.1.5"
  sha256 "af05518048abb481d7420bf6f54dfa2c2259a09b80164da760a12678079dbaee"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on cask: "font-fira-code"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
