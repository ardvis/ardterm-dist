cask "ardterm" do
  version "0.1.7"
  sha256 "5c65cbbac86c00d56ff7842afe96481f2afbd7223e8252bb31f22b25854e6d44"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on cask: "font-fira-code"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
