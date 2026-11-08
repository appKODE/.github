#!/usr/bin/env bash
# Creates a GitHub Release for every tag of a repo that has none, oldest first (so the newest ends up "Latest").
# Notes = the version's CHANGELOG section at that tag, else GitHub-generated notes marked as reconstructed.
#
#   scripts/backfill-releases.sh appKODE/amvi [tag-prefix=v] [--dry-run]
set -euo pipefail

repo="$1"
prefix="${2-v}"
dry="${3-}"
notes=$(mktemp)
trap 'rm -f "$notes"' EXIT

released=$(gh release list -R "$repo" --limit 1000 --json tagName --jq '.[].tagName')
for tag in $(gh api "repos/$repo/tags" --paginate --jq '.[].name' | sort -V); do
  grep -qxF "$tag" <<<"$released" && continue
  version="${tag#"$prefix"}"
  { gh api "repos/$repo/contents/CHANGELOG.md?ref=$tag" -H 'Accept: application/vnd.github.raw' 2>/dev/null || true; } \
    | awk -v v="$version" '/^## /{ s = $2; gsub(/[][]/, "", s); f = (s == v); next } f' >"$notes"
  if grep -q '[^[:space:]]' "$notes"; then
    echo "$tag: CHANGELOG section"
    args=(--notes-file "$notes")
  else
    echo "$tag: generated notes"
    args=(--generate-notes --notes "_Notes reconstructed: no CHANGELOG section for this version._")
  fi
  [ "$dry" = --dry-run ] || gh release create "$tag" -R "$repo" --verify-tag --title "$tag" --latest=false "${args[@]}"
done
# backfilled releases are older: keep "Latest" on the highest version
[ "$dry" = --dry-run ] || [ -z "${tag-}" ] || gh release edit "$tag" -R "$repo" --latest >/dev/null
