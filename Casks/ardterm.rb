cask "ardterm" do
  version "0.1.0"
  sha256 "ceca3e14162f6270677921c8a6f4adb35c3e0e416a2e9011e02dba2f97cc088f"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
