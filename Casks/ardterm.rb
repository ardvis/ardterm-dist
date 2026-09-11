cask "ardterm" do
  version "0.1.11"
  sha256 "ac4cd98bd03c4e31b2ce7db8cf4027003ae4a9a5481e220915acaeba74db1d52"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on cask: "font-fira-code"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
