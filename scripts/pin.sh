#!/usr/bin/env bash
# Move an explicitly named input, never track its moving trunk at build time.
# Move compiler and std together; build.sh refuses different compiler pins.
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# == 2 ]] || { echo 'usage: scripts/pin.sh wolf-book|wolf-interp|wolf-lang|wolf-std REVISION' >&2; exit 2; }
case "$1" in wolf-book|wolf-interp|wolf-lang|wolf-std) ;; *) echo 'unknown site input' >&2; exit 2;; esac
path="upstream/$1"
[[ -z $(git -C "$path" status --porcelain) ]] || { echo "$path is dirty" >&2; exit 1; }
git -C "$path" fetch origin
git -C "$path" checkout --detach "$2"
git add "$path"
echo 'Pin staged; update its paired inputs, build and review before committing.'
