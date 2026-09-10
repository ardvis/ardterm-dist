# Ardterm distribution

This public repository hosts signed, notarized macOS 26 arm64 releases and the
Homebrew cask. It contains no application source or signing credentials.

Read [licensing and legal information](LICENSING.md). New releases include
**Ardterm → Legal & Privacy…**, `ardterm --licenses`, and plain-text notices in
`Ardterm.app/Contents/Resources/Legal`. Use the notices supplied with your exact
app version. Existing published archives are not changed by this documentation.

The source repository's `scripts/release.sh` is the only release entrypoint. It
uses this checked-out repository, creates an immutable versioned archive,
checksums, dependency lockfile, source revision, and cask, then creates or
resumes the GitHub Release, verifies every asset, publishes it, and commits and
pushes `Casks/ardterm.rb`. Before the first release there is deliberately no
installable cask: its checksum and download URL must identify an actual verified
release.

The publication helper in `scripts/publish.sh` is internal and refuses direct
invocation. A rerun through the source release command safely resumes accepted
assets, verifies their exact contents, and repairs a failed cask push. A changed
binary requires a new patch version.

After publication:

```sh
brew tap ardvis/ardterm-dist https://github.com/ardvis/ardterm-dist.git
brew audit --cask --strict ardvis/ardterm-dist/ardterm
brew install --cask ardvis/ardterm-dist/ardterm
open /Applications/Ardterm.app
```

Verify terminal input, shell integration, resources, and remote-session enrollment
from the installed application, then verify `brew upgrade` on the next release.
