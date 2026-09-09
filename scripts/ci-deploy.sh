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

# wolf-web#19: the two pythons, side by side, in the deploy log. The build
# about to run is the same build the PR ran, and it is only a rehearsal if it
# ran on this interpreter. A mismatch stops the deploy here rather than in the
# middle of a build, and names both versions so the fix is obvious: either the
# host was upgraded and scripts/deploy-python.txt has not caught up, or the
# wrong python is first on this account's PATH.
WANT=$(grep -v '^#' scripts/deploy-python.txt | tr -d '[:space:]')
HAVE=$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')
echo "▶ Python: this host $HAVE ($(python3 --version 2>&1)), CI rehearsed on $WANT"
if [[ "$HAVE" != "$WANT" ]]; then
  echo "the deploy host runs python3 $HAVE and CI rehearsed the build on $WANT." >&2
  echo "Nothing here has been exercised on $HAVE. Edit scripts/deploy-python.txt" >&2
  echo "to $HAVE, let a PR run rehearse on it, and deploy that." >&2
  exit 1
fi

echo "▶ Deploy $(git rev-parse --short HEAD)"
exec ./scripts/deploy.sh
