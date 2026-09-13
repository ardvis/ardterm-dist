# Ardterm distribution agent guidance

This public repository contains Ardterm Homebrew and release metadata. It has no
application source or signing credentials.

- Treat casks, checksums, dependency locks, and source revisions as generated
  output of `scripts/release.sh` in the Ardterm source repository.
- Do not invoke `scripts/publish.sh` directly or hand-edit release metadata to
  repair a publication. Rerun the source release workflow, which safely resumes
  and verifies existing assets.
- Published archives and versions are immutable; a changed binary requires a
  new patch version.
- Keep licensing and installation documentation aligned with real assets.

Documentation checks are local and safe. Publishing, tagging, pushing, and
Homebrew release changes require explicit task scope.
