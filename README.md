# appKODE/.github

Shared GitHub Actions for appKODE libraries.

- [`gh-release.yml`](.github/workflows/gh-release.yml): reusable workflow. On a version tag it checks that the tag
  matches `gradle.properties` and that `CHANGELOG.md` has a section for the version, then creates the GitHub Release
  with that section as notes. Usage is in the file header.
- [`scripts/backfill-releases.sh`](scripts/backfill-releases.sh): one-off, creates releases for existing tags without
  one (`--dry-run` first).

## Release convention

1. Bump `versionName` in `gradle.properties`.
2. Add a `## X.Y.Z - YYYY-MM-DD` section to `CHANGELOG.md`.
3. Merge, then push tag `vX.Y.Z`. CI publishes to Maven Central and creates the GitHub Release.

Maven Central limits the org's releases and files per month, so batch releases (see the hand-over doc).
