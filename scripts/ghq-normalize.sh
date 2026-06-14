#!/usr/bin/env bash
# Ensure every ghq-managed repo folder is named after its actual repo: the
# leaf of its origin URL. ghq derives paths from remotes, but a repo cloned or
# renamed by hand can drift; this renames the leaf back so `ghq list`/`gr` work.
# Driven off `ghq list` so it only touches managed repos, never nested git
# checkouts (e.g. vendored bundler gems). Idempotent: correctly-named repos
# and repos without an origin are skipped.
set -uo pipefail

command -v ghq >/dev/null 2>&1 || { echo "ghq not installed, nothing to do"; exit 0; }

ghq list --full-path | while read -r repo; do
    url="$(git -C "$repo" remote get-url origin 2>/dev/null)" || continue
    [ -n "$url" ] || continue

    # Expected leaf = last path component of the remote, minus a trailing .git.
    want="$(basename "$url")"; want="${want%.git}"
    have="$(basename "$repo")"
    [ "$want" = "$have" ] && continue

    dest="$(dirname "$repo")/$want"
    if [ -e "$dest" ]; then
        echo "skip: $have -> $want (target already exists)"
    elif mv "$repo" "$dest"; then
        echo "renamed: $have -> $want"
    else
        echo "skip: could not rename $have -> $want"
    fi
done
