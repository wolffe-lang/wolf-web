#!/usr/bin/env bash
# ------------------------------------------------------------------
# The only command the deploy key may run.
#
# GitHub Actions holds a key restricted to this script, so a leaked key
# buys a deploy of whatever is on trunk and nothing else: no shell, no
# arbitrary command, no path outside this repo.
# ------------------------------------------------------------------
set -euo pipefail

REPO="$HOME/src/wolf-web"
cd "$REPO"

echo "▶ Fetch trunk"
git fetch --quiet origin trunk
git checkout --quiet trunk
git reset --hard --quiet origin/trunk

echo "▶ Deploy $(git rev-parse --short HEAD)"
exec ./scripts/deploy.sh
