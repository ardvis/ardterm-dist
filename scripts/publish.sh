#!/usr/bin/env bash
# Internal publication step invoked by ../ardterm/scripts/release.sh.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
[[ "${ARDTERM_RELEASE_PUBLISH_READY:-}" == 1 ]] || {
  echo 'Run ../ardterm/scripts/release.sh; this publisher is not a release entry point.' >&2
  exit 64
}
[[ $# == 1 ]] || { echo 'Usage: scripts/publish.sh /absolute/release-directory' >&2; exit 2; }
assets="$(cd "$1" && pwd)"
version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$assets/release.json")"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 2
[[ -z "$(git -C "$root" status --porcelain)" ]] || { echo 'Commit distribution changes first' >&2; exit 1; }
[[ "$(git -C "$root" branch --show-current)" == main ]] || { echo 'The distribution repository must be checked out on main' >&2; exit 1; }
git -C "$root" remote get-url origin >/dev/null 2>&1 || { echo 'The distribution repository must have an origin remote' >&2; exit 1; }
(cd "$assets" && shasum -a 256 -c SHA256SUMS)
ruby -c "$assets/ardterm.rb"
tag="v$version"
required_assets=(Ardterm-macos-arm64.zip SHA256SUMS Package.resolved release.json)

find_release() {
  gh release view "$tag" --repo ardvis/ardterm-dist \
    --json databaseId,isDraft,tagName \
    --jq '[.databaseId, .isDraft, .tagName] | @tsv' 2>/dev/null || true
}

# Create the draft separately from asset uploads. GitHub can return an upload
# error after accepting an asset; keeping the draft lets a later invocation
# discover the accepted files and upload only what is still missing.
release_record="$(find_release)"
if [[ -z "$release_record" ]]; then
  gh release create "$tag" --repo ardvis/ardterm-dist --draft \
    --title "Ardterm $version" --notes "Signed and notarized macOS 26 arm64 release."
  for attempt in {1..10}; do
    release_record="$(find_release)"
    [[ -n "$release_record" ]] && break
    sleep 1
  done
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
existing_verify="$(mktemp -d)"
verify=""
cleanup() {
  rm -rf "$existing_verify"
  [[ -z "$verify" ]] || rm -rf "$verify"
}
trap cleanup EXIT
for asset in "${required_assets[@]}"; do
  if grep -Fqx -- "$asset" <<<"$existing_assets"; then
    gh release download "$tag" --repo ardvis/ardterm-dist --dir "$existing_verify" --pattern "$asset"
    cmp "$assets/$asset" "$existing_verify/$asset" || {
      echo "Existing GitHub asset differs from the reviewed release: $asset" >&2
      exit 1
    }
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
if git -C "$root" diff --quiet -- Casks/ardterm.rb; then
  echo 'Homebrew cask already matches the published release.'
else
  git -C "$root" add Casks/ardterm.rb
  git -C "$root" commit -m "Publish Ardterm v$version release metadata"
  git -C "$root" push origin HEAD:main
fi
echo 'Release verified and Homebrew metadata published.'
