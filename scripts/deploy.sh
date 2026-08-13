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

echo "▶ Stage release $STAMP"
sudo mkdir -p "$WEBROOT/releases/$STAMP"
sudo rsync -a --delete dist/ "$WEBROOT/releases/$STAMP/"

echo "▶ Flip 'current'"
sudo ln -nfs "$WEBROOT/releases/$STAMP" "$WEBROOT/current"

echo "▶ Restore SELinux context"
sudo restorecon -R "$WEBROOT/releases/$STAMP" >/dev/null

echo "▶ Reload nginx"
sudo nginx -t
sudo systemctl reload nginx

# Keep the last five releases; older ones are just disk.
echo "▶ Prune old releases (keeping 5)"
sudo bash -c "cd '$WEBROOT/releases' && ls -1dt */ | tail -n +6 | xargs -r rm -rf"

echo "✓ Deployed $STAMP to https://$DOMAIN"
