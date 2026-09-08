#!/usr/bin/env bash
# Explicit publication of an already signed, reviewed release.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
[[ $# == 1 ]] || { echo 'Usage: scripts/publish.sh /absolute/release-directory' >&2; exit 2; }
assets="$(cd "$1" && pwd)"
version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$assets/release.json")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 2
[[ -z "$(git -C "$root" status --porcelain)" ]] || { echo 'Commit distribution changes first' >&2; exit 1; }
(cd "$assets" && shasum -a 256 -c SHA256SUMS)
ruby -c "$assets/ardterm.rb"
# gh create fails if the immutable version already exists; never replace assets.
gh release create "v$version" "$assets/Ardterm-macos-arm64.zip" "$assets/SHA256SUMS" "$assets/Package.resolved" "$assets/release.json" \
  --repo ardvis/ardterm-dist --draft --title "Ardterm $version" --notes "Signed and notarized macOS 26 arm64 release."
verify="$(mktemp -d)"
trap 'rm -rf "$verify"' EXIT
gh release download "v$version" --repo ardvis/ardterm-dist --dir "$verify" --pattern 'Ardterm-macos-arm64.zip' --pattern SHA256SUMS
(cd "$verify" && shasum -a 256 -c SHA256SUMS)
ditto -x -k "$verify/Ardterm-macos-arm64.zip" "$verify"
codesign --verify --deep --strict "$verify/Ardterm.app"
xcrun stapler validate "$verify/Ardterm.app"
gh release edit "v$version" --repo ardvis/ardterm-dist --draft=false
mkdir -p "$root/Casks"
cp "$assets/ardterm.rb" "$root/Casks/ardterm.rb"
echo 'Release published. Review and commit Casks/ardterm.rb, then push the tap and verify brew install.'
