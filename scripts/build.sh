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

# A step that cannot do its job records itself here instead of exiting,
# so one run reports every problem rather than one per run. The build
# then FAILS at the end unless the named waiver is set.
#
# The degradations are real conveniences — a laptop without the wasm32
# target should still be able to look at the site — but the default has
# to be refusal. Shipping a placeholder book or an absent playground
# while exiting 0 puts the burden on whatever runs next to notice, and
# for a while nothing did.
degraded=()
degrade() { degraded+=("$1"); }

# Sync the submodules to the revisions this repo pins. `git pull` does not
# move a submodule, so without this a checkout can build yesterday's
# interpreter while version.json reports today's pin: the site would be
# lying about what it serves, quietly, which is the one thing it must not
# do.
step "Submodules at their pinned revisions"
git submodule update --init --recursive --quiet || {
  echo "could not sync submodules" >&2
  exit 1
}
for m in wolf-book wolf-interp wolf-lang; do
  want=$(git ls-tree HEAD "upstream/$m" | awk '{print $3}')
  have=$(git -C "upstream/$m" rev-parse HEAD 2>/dev/null || echo none)
  if [[ "$want" != "$have" ]]; then
    echo "upstream/$m is at ${have:0:7}, the pin says ${want:0:7}" >&2
    exit 1
  fi
  echo "  $m ${have:0:7}"
done

rm -rf "$DIST"
mkdir -p "$DIST"

step "Static site"
test -d site || { echo "site/ is missing — nothing to serve" >&2; exit 1; }
rsync -a site/ "$DIST"/

step "The book (web edition)"
if (cd upstream/wolf-book && cargo run -p xtask --quiet -- render web >/dev/null 2>&1); then
  rsync -a upstream/wolf-book/target/render/web/ "$DIST/book/"
  # The book's pages link css/print.css and its renderer does not emit the
  # css/ directory, so every published page references a stylesheet that
  # 404s (wolffe-lang/wolf-book#1). The site ships what its pages ask for
  # until the render is fixed upstream.
  if [[ ! -f "$DIST/book/css/print.css" && -d upstream/wolf-book/theme/css ]]; then
    mkdir -p "$DIST/book/css"
    rsync -a upstream/wolf-book/theme/css/ "$DIST/book/css/"
    echo "  book: supplied css/ from the theme (wolf-book#1)"
  fi
  echo "  book: $(find "$DIST/book" -name '*.html' | wc -l) pages"
else
  echo "  book: render failed — see upstream/wolf-book; leaving a placeholder"
  mkdir -p "$DIST/book"
  printf '<!doctype html><title>The book</title><p>This build could not render the book. The site is deployed; the book is not.\n' > "$DIST/book/index.html"
  degrade "book:ALLOW_NO_BOOK:the book is a placeholder, not the book"
fi

step "The book (PDF)"
# The reading page offers this file for download and prints its size, so a
# phone is not ambushed by a silent multi-megabyte fetch. Both facts are
# stamped here at build time: the PDF is rendered from the SAME pinned
# checkout as the web pages above (never ingested from anywhere else, so
# the pair cannot drift), and the size on the page is measured from the
# file actually shipped. If there is no PDF — typst absent, render broken —
# the page's download line is removed rather than left to 404: the site
# does not advertise a file the dist does not carry.
rm -f upstream/wolf-book/target/render/wolf-book.pdf   # never ship a stale one
if (cd upstream/wolf-book && cargo run -p xtask --quiet -- render pdf >/dev/null 2>&1) \
    && [[ -s upstream/wolf-book/target/render/wolf-book.pdf ]]; then
  mkdir -p "$DIST/book"
  cp upstream/wolf-book/target/render/wolf-book.pdf "$DIST/book/wolf-book.pdf"
  pdf_bytes=$(wc -c < "$DIST/book/wolf-book.pdf")
  pdf_mb=$(awk "BEGIN { printf \"%.1f\", $pdf_bytes / 1000000 }")
  tmp=$(mktemp)
  sed "s/__PDF_SIZE__/$pdf_mb MB/" "$DIST/reading/index.html" > "$tmp" \
    && mv "$tmp" "$DIST/reading/index.html"
  echo "  pdf: $pdf_mb MB at dist/book/wolf-book.pdf"
else
  echo "  pdf: not built (typst missing, or the render failed) — dropping the download link"
  tmp=$(mktemp)
  sed "/__PDF_SIZE__/d" "$DIST/reading/index.html" > "$tmp" \
    && mv "$tmp" "$DIST/reading/index.html"
  degrade "pdf:ALLOW_NO_PDF:the book cannot be downloaded"
fi

step "The interpreter (wasm)"
if ./scripts/build-wasm.sh; then
  echo "  wasm: $(du -h "$DIST/play/lupin.wasm" 2>/dev/null | cut -f1) at dist/play/lupin.wasm"
else
  echo "  wasm: build failed — the playground will say so rather than pretend" >&2
  degrade "wasm:ALLOW_NO_WASM:the playground cannot run anything"
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
python3 scripts/collect-samples.py upstream/wolf-lang/corpus "$DIST/play/samples" || {
  echo "  samples: collector failed; the playground falls back to its built-in program"
  degrade "samples:ALLOW_NO_SAMPLES:the playground offers no example programs"
}

step "What could not be built"
waived=()
blocking=()
for d in ${degraded[@]+"${degraded[@]}"}; do
  name=${d%%:*}
  rest=${d#*:}
  var=${rest%%:*}
  why=${rest#*:}
  if [[ "${!var:-0}" == "1" ]]; then
    waived+=("$name")
    echo "  $name: $why — waived by $var"
  else
    blocking+=("$name")
    echo "  $name: $why (set $var=1 to build anyway)" >&2
  fi
done
if [[ ${#blocking[@]} -gt 0 ]]; then
  echo "" >&2
  echo "refusing to produce a dist/ that is missing: ${blocking[*]}" >&2
  exit 1
fi
if [[ ${#degraded[@]} -eq 0 ]]; then echo "  everything built"; fi

step "Version stamp"
BOOK_SHA=$(git -C upstream/wolf-book rev-parse --short HEAD 2>/dev/null || echo unknown)
INTERP_SHA=$(git -C upstream/wolf-interp rev-parse --short HEAD 2>/dev/null || echo unknown)
LANG_SHA=$(git -C upstream/wolf-lang rev-parse --short HEAD 2>/dev/null || echo unknown)
LUPIN_VER=$(grep -m1 '^version' upstream/wolf-interp/Cargo.toml | cut -d'"' -f2)
# A waived build is still a build that is missing something. Say so in
# the stamp: the site's one rule is that it does not misreport itself.
WAIVED_JSON=""
for w in ${waived[@]+"${waived[@]}"}; do
  WAIVED_JSON="$WAIVED_JSON${WAIVED_JSON:+, }\"$w\""
done
cat > "$DIST/version.json" <<EOF
{
  "built": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "lupin": "$LUPIN_VER",
  "pins": { "wolf-lang": "$LANG_SHA", "wolf-interp": "$INTERP_SHA", "wolf-book": "$BOOK_SHA" },
  "missing": [$WAIVED_JSON]
}
EOF

printf '\n✓ dist/ built (%s)\n' "$(du -sh "$DIST" | cut -f1)"
