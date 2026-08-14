#!/usr/bin/env bash
# ------------------------------------------------------------------
# Deploy lupp.us.
#
# Builds the site into dist/, copies it to a timestamped release
# directory, flips the `current` symlink, restores SELinux labels and
# reloads nginx. Same shape as the other projects on this box.
#
# Run from the repo root:  ./scripts/deploy.sh
# ------------------------------------------------------------------
set -euo pipefail

DOMAIN=lupp.us
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBROOT=/var/www/$DOMAIN
STAMP=$(date +%Y-%m-%d-%H%M%S)

cd "$ROOT"

if [[ "${SKIP_BUILD:-0}" != "1" ]]; then
  echo "▶ Build"
  ./scripts/build.sh
else
  echo "▶ Skipping build (SKIP_BUILD=1); using dist/ as it stands"
fi

test -f dist/index.html || { echo "dist/index.html missing — build failed?" >&2; exit 1; }

# The webroot belongs to this user and carries httpd_sys_content_t, which
# new files inherit, and nginx resolves `current` per request. So a
# content deploy needs no root at all: no chown, no restorecon, no
# reload. Only an nginx CONFIG change needs sudo, and that is not this
# script's job.
test -w "$WEBROOT/releases" || {
  echo "$WEBROOT/releases is not writable by $(id -un)." >&2
  echo "One-time fix:  sudo chown -R $(id -un) $WEBROOT" >&2
  exit 1
}

echo "▶ Stage release $STAMP"
mkdir -p "$WEBROOT/releases/$STAMP"
rsync -a --delete dist/ "$WEBROOT/releases/$STAMP/"

echo "▶ Flip 'current'"
ln -nfs "$WEBROOT/releases/$STAMP" "$WEBROOT/current"

# Keep the last five releases; older ones are just disk.
echo "▶ Prune old releases (keeping 5)"
(cd "$WEBROOT/releases" && ls -1dt */ | tail -n +6 | xargs -r rm -rf)

echo "▶ Verify what is being served"
served=$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" http://127.0.0.1/ || echo 000)
test "$served" = "200" || {
  echo "the site answers $served, not 200 — rolling 'current' back" >&2
  prev=$(cd "$WEBROOT/releases" && ls -1dt */ | sed -n 2p | tr -d /)
  test -n "$prev" && ln -nfs "$WEBROOT/releases/$prev" "$WEBROOT/current"
  exit 1
}

echo "✓ Deployed $STAMP to https://$DOMAIN"
