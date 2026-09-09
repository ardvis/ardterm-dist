cask "ardterm" do
  version "0.1.3"
  sha256 "2a534f436b19d115989beca8d9aa21ca4dae8530efd92f55440c479711036db5"
  url "https://github.com/ardvis/ardterm-dist/releases/download/v#{version}/Ardterm-macos-arm64.zip"
  name "Ardterm"
  desc "Native macOS terminal with authenticated remote sessions"
  homepage "https://github.com/ardvis/ardterm-dist"
  depends_on macos: :tahoe
  depends_on arch: :arm64
  app "Ardterm.app"
end
