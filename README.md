# Ardterm distribution

This public repository hosts signed, notarized macOS 26 arm64 releases and the
Homebrew cask. It contains no application source or signing credentials.

Read [licensing and legal information](LICENSING.md). New releases include
**Ardterm → Legal & Privacy…**, `ardterm --licenses`, and plain-text notices in
`Ardterm.app/Contents/Resources/Legal`. Use the notices supplied with your exact
app version. Existing published archives are not changed by this documentation.

The source repository's `scripts/release.sh` prepares an immutable versioned
archive, checksums, dependency lockfile, source revision, and `ardterm.rb`.
Before the first release there is deliberately no installable cask: its checksum
and download URL must identify an actual verified release.

After reviewing those outputs, run `scripts/publish.sh /absolute/release-directory`
on the signing Mac. It creates or resumes a draft, uploads only missing assets,
downloads and verifies the published archive, publishes it, and writes
`Casks/ardterm.rb`. The command is safe to rerun after an upload or local failure:
it never replaces assets in a published release and verifies an existing published
version before updating the cask. Commit and push that cask only after the release
is public. A changed binary requires a new patch version.

After publication:

```sh
brew tap ardvis/ardterm-dist https://github.com/ardvis/ardterm-dist.git
brew audit --cask --strict ardvis/ardterm-dist/ardterm
brew install --cask ardvis/ardterm-dist/ardterm
open /Applications/Ardterm.app
```

Verify terminal input, shell integration, resources, and remote-session enrollment
from the installed application, then verify `brew upgrade` on the next release.
