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

# The versions the pins carry, derived once and used everywhere below.
# Wolf's is the first release heading of the pinned CHANGELOG — content,
# not tag objects, so a shallow submodule clone cannot mislead it.
WOLF_VER=$(sed -n 's/^## \([0-9][0-9.]*\) .*/\1/p' upstream/wolf-lang/CHANGELOG.md | head -1)
LUPIN_VER=$(grep -m1 '^version' upstream/wolf-interp/Cargo.toml | cut -d'"' -f2)
[[ -n "$WOLF_VER" && -n "$LUPIN_VER" ]] || {
  echo "could not read the pinned versions (wolf '$WOLF_VER', lupin '$LUPIN_VER')" >&2
  exit 1
}

step "Static site"
test -d site || { echo "site/ is missing — nothing to serve" >&2; exit 1; }

# The version-drift tripwire. Current-version claims in site prose are
# __WOLF_VERSION__/__LUPIN_VERSION__ placeholders stamped below from the
# pins; every literal version mention must be a listed, counted, audited
# entry in scripts/version-allowlist.txt. The prose fossilized at v0.1.0
# once; this is what keeps the class at zero. It takes BOTH pinned
# checkouts, because an entry names the clock that audits it and lupin
# releases on its own (wolf-web#8). Since ww16 it also holds
# scripts/stamp-allowlist.txt: a placeholder cannot fossilize, but a
# sentence built around one can be true of exactly the release it names
# and false the moment the stamp moves, so the release-bound ones are
# counted and re-read at a bump like any literal.
#
# `--also CHANGELOG.md` for the same reason the count audit takes it: this
# repository's changelog renders to /changelog/site/, so it is served prose
# living outside site/ where both audits root (wolf-web#27). ww25 closed the
# count half; the version half needed a grammar change first, because the
# entry grammar made the clock mandatory and a dated entry's `v0.2.4` cannot
# rot. Those entries are `frozen` — no clock, no re-read — and what they buy
# is that writing a version into a served sentence costs one allowlist line,
# everywhere.
python3 scripts/check-version-prose.py --also CHANGELOG.md \
  site upstream/wolf-lang upstream/wolf-interp

# The same rule for a count. A number written into prose as an English word
# read exactly as trustworthy as the gated numbers beside it and was held by
# nothing, and one of them was wrong for two releases (wolf-web#17). A count
# a machine can measure is a __COUNT_ placeholder, stamped below; every other
# number word is a listed, counted entry in scripts/count-allowlist.txt that
# says how many of its occurrences a pin bump can still move.
#
# `--also CHANGELOG.md` because this repository's own changelog renders to
# /changelog/site/ and is therefore served prose, while living outside site/
# where both audits root — so its numbers were held by nothing, and ww24's
# entry went out stating three counts of its own allowlists, two of them wrong
# (wolf-web#27). Its entries are frozen: a wave's measurement cannot be made
# false by a later pin, so they carry no clock. The cost of writing a number
# into a served sentence is one allowlist line, everywhere.
python3 scripts/check-counts.py --also CHANGELOG.md \
  site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book

# And the third prose rule, which until ww28 was not one of these at all.
#
# /install/ and /play/ state how far the interpreter's specification pin sits
# behind the compiler this site advertises, in a CLOSED SET of four phrases,
# and the page must carry the one for the counted gap and none of the other
# three. That rule is as old as ww13 and it lived in PowerShell, inside the
# `the specification pin lag the site records` step of
# .github/workflows/windows.yml — on a runner nobody runs locally, in a job the
# linux `CI` workflow does not depend on. At ww27 a new /play/ paragraph quoted
# the phrase for a gap of zero while the gap was one: this gauntlet was green
# twice, linux `CI` was green, and one Windows runner was the only thing in the
# world that saw it (wolf-web#38).
#
# Every other prose rule above is a script here that reds on the author's
# machine at the moment the sentence is written. This is that rule in that
# shape. The windows step calls this same file now, so there is ONE
# implementation and not two that can drift apart.
#
# It runs here, on site/, while the placeholders are still placeholders: two of
# the three things it checks ARE placeholders (the revision stamp and the
# distance stamp), and after the sweep below there would be nothing left to
# check. It needs the compiler checkout to carry history and tags, exactly as
# stamp-counts.py's `speccommits` does further down.
python3 scripts/check-lag-phrases.py \
  site upstream/wolf-lang upstream/wolf-interp

rsync -a site/ "$DIST"/

# Stamp the placeholders. dist/ holds only the static site at this point,
# so the sweep cannot touch the book's rendered pages.
while IFS= read -r f; do
  tmp=$(mktemp)
  sed -e "s/__WOLF_VERSION__/$WOLF_VER/g" -e "s/__LUPIN_VERSION__/$LUPIN_VER/g" "$f" > "$tmp" \
    && mv "$tmp" "$f"
  chmod 644 "$f"
done < <(grep -rl '__WOLF_VERSION__\|__LUPIN_VERSION__' "$DIST" || true)
if grep -rl '__WOLF_VERSION__\|__LUPIN_VERSION__' "$DIST"; then
  echo "a version placeholder survived the stamp" >&2
  exit 1
fi
echo "  version prose stamped: wolf $WOLF_VER, lupin $LUPIN_VER"

# The other class of claim that rots without failing anything: how big a
# document is. The spec and docs pages print a size beside every link so a
# reader knows what one costs before following it, and those numbers were
# written by hand until four of them had drifted at once. They are stamped
# from the pinned checkout now, the way the versions are.
python3 scripts/stamp-sizes.py "$DIST" upstream/wolf-lang

# And the same rule for a revision. /install/ and /play/ name the specification
# commit the pinned interpreter was built to, and that sha was rewritten by
# hand at every interpreter bump: it is not a version, so the prose audit is
# blind to it, and not a count, so the count audit is too — the hole ww21
# wrote down. It is stamped off the interpreter's own gitlink now, and the same
# pass refuses a git revision typed into a page, including a correct one, which
# is the kind that rots quietly. It runs here, while dist/ is the static site
# alone: the rendered changelogs below are full of revisions and every one of
# them is history.
python3 scripts/stamp-revisions.py "$DIST" upstream/wolf-lang upstream/wolf-interp

step "The book (web edition)"
if (cd upstream/wolf-book && cargo run -p xtask --quiet -- render web >/dev/null 2>&1); then
  rsync -a upstream/wolf-book/target/render/web/ "$DIST/book/"
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
  chmod 644 "$DIST/reading/index.html"   # mktemp is 0600; nginx must read it
  echo "  pdf: $pdf_mb MB at dist/book/wolf-book.pdf"
else
  echo "  pdf: not built (typst missing, or the render failed) — dropping the download link"
  tmp=$(mktemp)
  sed "/__PDF_SIZE__/d" "$DIST/reading/index.html" > "$tmp" \
    && mv "$tmp" "$DIST/reading/index.html"
  chmod 644 "$DIST/reading/index.html"   # mktemp is 0600; nginx must read it
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

step "The changelogs"
# Each public project's CHANGELOG.md, rendered from the checkout this
# build pins (the reading-page discipline: the page can only show what
# the pins carry). A repo without one gets a page that says so — absence
# is a fact to report, never a build failure. Lupin's page is named for
# the program, since that is what the playground runs.
#
# Seven characters, asked for, not inherited (wolf-web#26). Bare `--short`
# picks its width from the object count of the repository being asked, so the
# four pins below came out at three different widths across three repositories
# and would have moved again on nobody's schedule. Every other revision this
# repository publishes is seven by construction — the gitlink `spec-pin` below,
# `stamp-revisions.py`'s page stamps, `check-counts.py`'s book clock — and a
# reader or a check holding one against another must not have to slice first.
# It is wolf-lang#301's ruling for the D57 build stamp, one layer out.
LANG_PIN=$(git -C upstream/wolf-lang rev-parse --short=7 HEAD)
INTERP_PIN=$(git -C upstream/wolf-interp rev-parse --short=7 HEAD)
BOOK_PIN=$(git -C upstream/wolf-book rev-parse --short=7 HEAD)
SELF_REV=$(git rev-parse --short=7 HEAD 2>/dev/null || echo working-tree)
python3 scripts/render-changelog.py wolf \
  "The compiler. An entry per tagged release, written at the release commit." \
  upstream/wolf-lang/CHANGELOG.md https://github.com/wolffe-lang/wolf-lang \
  "$LANG_PIN" "$DIST/changelog/wolf"
python3 scripts/render-changelog.py lupin \
  "The reference interpreter. An entry per tagged release, each against a named specification pin." \
  upstream/wolf-interp/CHANGELOG.md https://github.com/wolffe-lang/wolf-interp \
  "$INTERP_PIN" "$DIST/changelog/lupin"
python3 scripts/render-changelog.py "the book" \
  "The language text. An entry per merged sprint of writing." \
  upstream/wolf-book/CHANGELOG.md https://github.com/wolffe-lang/wolf-book \
  "$BOOK_PIN" "$DIST/changelog/book"
python3 scripts/render-changelog.py "this site" \
  "lupp.us itself. An entry per merged sprint." \
  CHANGELOG.md https://github.com/wolffe-lang/wolf-web \
  "$SELF_REV" "$DIST/changelog/site"

step "Sample programs for the playground"
mkdir -p "$DIST/play/samples"
python3 scripts/collect-samples.py upstream/wolf-lang/corpus "$DIST/play/samples" || {
  echo "  samples: collector failed; the playground falls back to its built-in program"
  degrade "samples:ALLOW_NO_SAMPLES:the playground offers no example programs"
}

# The counts the pages state, measured now rather than written by hand. This
# runs here and not beside stamp-sizes.py because one of its sources is the
# sample index the step above just wrote. It takes the interpreter checkout as
# well, because one of the counts is a distance: how far the specification pin
# lupin was built to sits behind the compiler this site advertises, in commits
# of the compiler's own history. That needs both gitlinks and a wolf-lang
# checkout with history behind it. And the book, for the one number on
# /reading/ that is a measurement rather than a reading: the chapter total,
# counted off the pinned SUMMARY.md (wolf-web#28). The audit above already
# takes the book checkout, so the stamp and its clock come off one pin.
python3 scripts/stamp-counts.py "$DIST" upstream/wolf-lang upstream/wolf-interp \
  upstream/wolf-book

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
# Seven characters by decision here too — see the changelog renderer above.
# These three are the served version.json, which is what every post-deploy
# check reads, so this is the field the width mattered most in.
BOOK_SHA=$(git -C upstream/wolf-book rev-parse --short=7 HEAD 2>/dev/null || echo unknown)
INTERP_SHA=$(git -C upstream/wolf-interp rev-parse --short=7 HEAD 2>/dev/null || echo unknown)
LANG_SHA=$(git -C upstream/wolf-lang rev-parse --short=7 HEAD 2>/dev/null || echo unknown)
# The specification revision the pinned interpreter was built to. It is the
# gitlink /install/ and /play/ now carry as a stamp, written here as well so
# that what the pages say can be held against what the build measured without
# asking git anything — which is what the post-deploy checks do.
SPEC_SHA=$(git -C upstream/wolf-interp ls-tree HEAD upstream | awk '{print substr($3, 1, 7)}')
[[ -n "$SPEC_SHA" ]] || SPEC_SHA=unknown
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
  "spec-pin": "$SPEC_SHA",
  "missing": [$WAIVED_JSON]
}
EOF
# A width the site decides is a width the site checks (wolf-web#26). Every
# revision published here is seven hex characters; a build that would serve
# any other number stops, rather than leaving the next post-deploy check to
# discover it by comparing a seven against an eight and going red over nothing.
for pin in "$LANG_SHA" "$INTERP_SHA" "$BOOK_SHA" "$SPEC_SHA"; do
  [[ "$pin" == unknown || "$pin" =~ ^[0-9a-f]{7}$ ]] || {
    echo "version.json would publish the revision '$pin'; pins are seven hex characters" >&2
    exit 1
  }
done

# The placeholder sweep above ran on site/ alone, before the book, the docs
# and the changelog pages existed. A page generated AFTER it — the rendered
# CHANGELOGs, most easily — can carry a live placeholder all the way to the
# reader, and did: a ww12 changelog entry quoting `__WOLF_VERSION__` reached
# dist/ with the token intact, past a guard that had already run. Sweep the
# finished tree, where every generated page is finally present.
if grep -rl '__WOLF_VERSION__\|__LUPIN_VERSION__\|__KIB_\|__COUNT_\|__PIN_' "$DIST"; then
  echo "a placeholder reached the finished dist/ (the files above)" >&2
  echo "the early sweep runs on site/ only; a generated page needs its own" >&2
  exit 1
fi

# Every shipped file must be world-readable — nginx serves as its own user.
# A 0600 file (mktemp's default, if one slips into the dist unnormalized)
# is a silent 403 in production; refuse to ship it. This guard exists
# because reading/index.html once shipped 0600 and 403'd the live page.
unreadable=$(find "$DIST" -type f ! -perm -004)
if [[ -n "$unreadable" ]]; then
  echo "refusing to ship files nginx cannot read (not world-readable):" >&2
  echo "$unreadable" >&2
  exit 1
fi

printf '\n✓ dist/ built (%s)\n' "$(du -sh "$DIST" | cut -f1)"
