#!/usr/bin/env bash
# ------------------------------------------------------------------
# Build the site into dist/.
#
# Everything the site serves is generated from the pinned submodules,
# so the site cannot claim a version of wolf that does not exist:
#
#   upstream/wolf-book    -> the book's web edition        -> dist/book/
#   upstream/wolf-interp  -> lupin compiled to wasm        -> dist/play/
#   upstream/wolf-lang    -> spec, diagnostics, samples    -> dist/spec/, dist/docs/
#
# Run from the repo root:  ./scripts/build.sh
# ------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
DIST="$ROOT/dist"

step() { printf '\n▶ %s\n' "$1"; }

test -f upstream/wolf-interp/Cargo.toml || {
  echo "submodules are empty — run: git submodule update --init --recursive" >&2
  exit 1
}

rm -rf "$DIST"
mkdir -p "$DIST"

step "Static site"
rsync -a --exclude 'play/vendor/.gitkeep' site/ "$DIST"/

step "The book (web edition)"
if (cd upstream/wolf-book && cargo run -p xtask --quiet -- render web >/dev/null 2>&1); then
  rsync -a upstream/wolf-book/target/render/web/ "$DIST/book/"
  echo "  book: $(find "$DIST/book" -name '*.html' | wc -l) pages"
else
  echo "  book: render failed — see upstream/wolf-book; leaving a placeholder"
  mkdir -p "$DIST/book"
  printf '<!doctype html><title>The book</title><p>This build could not render the book. The site is deployed; the book is not.\n' > "$DIST/book/index.html"
fi

step "The interpreter (wasm)"
if ./scripts/build-wasm.sh; then
  echo "  wasm: $(du -h "$DIST/play/lupin.wasm" 2>/dev/null | cut -f1) at dist/play/lupin.wasm"
else
  echo "  wasm: build failed — the playground will say so rather than pretend" >&2
fi

step "Docs and spec"
mkdir -p "$DIST/docs" "$DIST/spec"
for f in upstream/wolf-lang/docs/diagnostics.md upstream/wolf-lang/docs/warnings.md; do
  [[ -f "$f" ]] && cp "$f" "$DIST/docs/"
done
rsync -a --include '*.md' --include '*.json' --include '*.ebnf' --exclude '*' \
  upstream/wolf-lang/spec/ "$DIST/spec/" 2>/dev/null || true
if [[ -d upstream/wolf-lang/docs/api ]]; then
  rsync -a upstream/wolf-lang/docs/api/ "$DIST/docs/api/"
fi

step "Sample programs for the playground"
mkdir -p "$DIST/play/samples"
python3 scripts/collect-samples.py upstream/wolf-lang/corpus "$DIST/play/samples" || \
  echo "  samples: collector failed; the playground falls back to its built-in program"

step "Version stamp"
BOOK_SHA=$(git -C upstream/wolf-book rev-parse --short HEAD 2>/dev/null || echo unknown)
INTERP_SHA=$(git -C upstream/wolf-interp rev-parse --short HEAD 2>/dev/null || echo unknown)
LANG_SHA=$(git -C upstream/wolf-lang rev-parse --short HEAD 2>/dev/null || echo unknown)
LUPIN_VER=$(grep -m1 '^version' upstream/wolf-interp/Cargo.toml | cut -d'"' -f2)
cat > "$DIST/version.json" <<EOF
{
  "built": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "lupin": "$LUPIN_VER",
  "pins": { "wolf-lang": "$LANG_SHA", "wolf-interp": "$INTERP_SHA", "wolf-book": "$BOOK_SHA" }
}
EOF

printf '\n✓ dist/ built (%s)\n' "$(du -sh "$DIST" | cut -f1)"
