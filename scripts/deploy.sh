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

# build.sh degrades rather than dies when the wasm toolchain is absent,
# which is right for a developer's laptop and wrong for a deploy: the
# playground is the reason most visitors are here, and a version.json
# health check cannot see that it is missing. 200 KiB is well under any
# real build and well over a stub.
wasm=dist/play/lupin.wasm
if [[ ! -f "$wasm" ]] || [[ $(wc -c < "$wasm") -lt 200000 ]]; then
  echo "$wasm missing or implausibly small — refusing to deploy a dead playground." >&2
  echo "Set DEPLOY_WITHOUT_WASM=1 to ship the site anyway." >&2
  test "${DEPLOY_WITHOUT_WASM:-0}" = "1" || exit 1
  echo "note: shipping without a working playground, as asked" >&2
fi

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

# Probe by name against this box, following the port-80 redirect, so the
# certificate is validated too. Port 80 answers 301 once TLS is on — the
# old probe read that as a dead site and rolled back good releases.
code=$(curl -sS -o /dev/null -w '%{http_code}' -L \
  --resolve "$DOMAIN:80:127.0.0.1" --resolve "$DOMAIN:443:127.0.0.1" \
  "http://$DOMAIN/" || echo 000)

# A fresh box has no certificate yet, so the redirect target does not
# answer. Plain HTTP serving the site directly is a legitimate state
# there, and only there.
if [[ "$code" != "200" ]]; then
  code=$(curl -sS -o /dev/null -w '%{http_code}' -H "Host: $DOMAIN" http://127.0.0.1/ || echo 000)
fi

# And it must be THIS release: a symlink that did not take, or an nginx
# still holding an old root, answers 200 all day with last week's site.
live=$(curl -sS -L --resolve "$DOMAIN:80:127.0.0.1" --resolve "$DOMAIN:443:127.0.0.1" \
  "http://$DOMAIN/version.json" 2>/dev/null \
  || curl -sS -H "Host: $DOMAIN" http://127.0.0.1/version.json 2>/dev/null || true)

if [[ "$code" != "200" || "$live" != "$(cat dist/version.json)" ]]; then
  if [[ "$code" != "200" ]]; then
    echo "the site answers $code, not 200 — rolling 'current' back" >&2
  else
    echo "the site answers 200 but not with $STAMP's version.json — rolling back" >&2
  fi
  prev=$(cd "$WEBROOT/releases" && ls -1dt */ | sed -n 2p | tr -d /)
  test -n "$prev" && ln -nfs "$WEBROOT/releases/$prev" "$WEBROOT/current"
  exit 1
fi

echo "✓ Deployed $STAMP to https://$DOMAIN"
