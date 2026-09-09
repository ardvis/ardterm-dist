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
tag="v$version"
required_assets=(Ardterm-macos-arm64.zip SHA256SUMS Package.resolved release.json)

find_release() {
  gh api "repos/ardvis/ardterm-dist/releases?per_page=100" \
    --jq ".[] | select(.tag_name == \"$tag\") | [.id, .draft] | @tsv" | head -n 1
}

# Create the draft separately from asset uploads. GitHub can return an upload
# error after accepting an asset; keeping the draft lets a later invocation
# discover the accepted files and upload only what is still missing.
release_record="$(find_release)"
if [[ -z "$release_record" ]]; then
  gh release create "$tag" --repo ardvis/ardterm-dist --draft \
    --title "Ardterm $version" --notes "Signed and notarized macOS 26 arm64 release."
  release_record="$(find_release)"
fi
[[ -n "$release_record" ]] || { echo "Could not resolve GitHub release $tag" >&2; exit 1; }
IFS=$'\t' read -r release_id draft <<< "$release_record"
case "$draft" in
  true)
    ;;
  false)
    # Published releases are immutable. Continue with verification so a retry
    # after a post-publication local failure remains safe and useful.
    ;;
  *)
    echo "Unexpected draft state for $tag: $draft" >&2
    exit 1
    ;;
esac
existing_assets="$(gh api "repos/ardvis/ardterm-dist/releases/$release_id/assets?per_page=100" --jq '.[].name')"
for asset in "${required_assets[@]}"; do
  if grep -Fqx -- "$asset" <<<"$existing_assets"; then
    continue
  fi
  if [[ "$draft" != true ]]; then
    echo "Published release $tag is missing immutable asset $asset" >&2
    exit 1
  fi
  gh api --method POST \
    --header 'Content-Type: application/octet-stream' \
    "https://uploads.github.com/repos/ardvis/ardterm-dist/releases/$release_id/assets?name=$asset" \
    --input "$assets/$asset" >/dev/null
done
verify="$(mktemp -d)"
trap 'rm -rf "$verify"' EXIT
gh release download "$tag" --repo ardvis/ardterm-dist --dir "$verify" --pattern 'Ardterm-macos-arm64.zip' --pattern SHA256SUMS
(cd "$verify" && shasum -a 256 -c SHA256SUMS)
ditto -x -k "$verify/Ardterm-macos-arm64.zip" "$verify"
codesign --verify --deep --strict "$verify/Ardterm.app"
test -s "$verify/Ardterm.app/Contents/Resources/Legal/THIRD_PARTY_NOTICES.txt"
test -s "$verify/Ardterm.app/Contents/Resources/Ardterm_ArdtermCLI.bundle/Legal/catalog.json"
xcrun stapler validate "$verify/Ardterm.app"
if [[ "$draft" == true ]]; then
  gh release edit "$tag" --repo ardvis/ardterm-dist --draft=false
fi
mkdir -p "$root/Casks"
cp "$assets/ardterm.rb" "$root/Casks/ardterm.rb"
echo 'Release verified. Review and commit Casks/ardterm.rb, then push the tap and verify brew install.'
