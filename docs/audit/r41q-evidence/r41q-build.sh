#!/usr/bin/env bash
# web-build.sh SHA [gauntlet] : wolf-web's full build at one commit, on hasu's host, in a clone made
# for that commit (web/g-<sha7>, copied from web/new, checked out detached and cleaned; never the
# live tree). typst 0.15.1 is the copy in r41q/tools (ww48's binary, sha 29273eaa); rustc is the
# nix 1.97.1 with wasm32-unknown-unknown. No ALLOW_* waiver is set. With `gauntlet`, the CI build
# job's other steps run too, in CI's order. Every step prints END <name> exit=<rc>, and the first
# nonzero step stops the run.
# The dist is kept as web/dist-<sha7> for the deploy diff. Run under bin/block (R41Q_CPUS).
set -u
SHA=${1:?sha}
MODE=${2:-build}
R=/home/mfwolffe/lanes/r41q
W=$R/web
S7=${SHA:0:7}
G=$W/g-$S7
export PATH=$R/tools:$HOME/lanes/hasu-env/bin:$HOME/lanes/hasu-env/profile/bin:$PATH
export CARGO_HOME=$W/cargo
export CARGO_BUILD_JOBS=6
step() {
    local name=$1
    shift
    echo "== STEP $name $(date -u +%FT%TZ)"
    "$@"
    local rc=$?
    echo "END $name exit=$rc"
    if [ "$rc" -ne 0 ]; then echo "WEB-BUILD-STOPPED at $name"; exit "$rc"; fi
}
clone() {
    git -C "$W/new" fetch --quiet origin trunk r41q-wolf-web || return 1
    git -C "$W/new" cat-file -e "$SHA^{commit}" || { echo "no commit $SHA"; return 1; }
    rm -rf "$G" && cp -a "$W/new" "$G" || return 1
    cd "$G" || return 1
    git fetch --quiet origin trunk r41q-wolf-web || return 1
    git checkout --quiet -f --detach "$SHA" || return 1
    git clean -fdxq || return 1
    git submodule update --init --recursive --quiet || return 1
    git submodule foreach --quiet 'git clean -fdxq' || return 1
    test "$(git rev-parse HEAD)" = "$SHA" || return 1
    test -z "$(git status --porcelain)" || { git status --short; return 1; }
    echo "head $(git rev-parse HEAD)"
    git submodule status
    typst --version; rustc --version; node --version; python3 --version
}
pins() {
    cd "$G" || return 1
    for m in wolf-book wolf-interp wolf-lang wolf-std; do
        want=$(git ls-tree HEAD "upstream/$m" | awk '{print $3}')
        have=$(git -C "upstream/$m" rev-parse HEAD)
        test "$want" = "$have" || { echo "upstream/$m is $have, the pin says $want"; return 1; }
        echo "$m ${have:0:7}"
    done
    if [ "$(git -C upstream/wolf-lang rev-parse --is-shallow-repository)" = true ]; then echo "wolf-lang is shallow"; return 1; fi
    echo "upstream/wolf-lang carries $(git -C upstream/wolf-lang rev-list --count HEAD) commits"
}
parse() { cd "$G" && for f in scripts/*.sh; do bash -n "$f" || return 1; done; }
nodetests() { cd "$G" && node --test tests/*.test.mjs 2>&1 | tail -12; return "${PIPESTATUS[0]}"; }
pytests() { cd "$G" && python3 -m unittest discover -s tests -p '*_test.py' 2>&1 | tail -4; return "${PIPESTATUS[0]}"; }
build() {
    cd "$G" || return 1
    ./scripts/build.sh > "$W/build-$S7.log" 2>&1
    local rc=$?
    tail -25 "$W/build-$S7.log"
    rm -rf "$W/dist-$S7" && cp -a dist "$W/dist-$S7"
    return $rc
}
advertises() {
    cd "$G" || return 1
    test -s dist/index.html || return 1
    wolfver=$(sed -n 's/^## \([0-9][0-9.]*\) .*/\1/p' upstream/wolf-lang/CHANGELOG.md | head -1)
    grep -q "This is version $wolfver" dist/index.html || { echo "no 'This is version $wolfver'"; return 1; }
    if grep -rq '__WOLF_VERSION__\|__LUPIN_VERSION__\|__PIN_' dist; then echo "a placeholder reached dist/"; return 1; fi
    test -s dist/play/lupin.wasm && test -s dist/version.json || return 1
    for p in $(python3 -c 'import json; v = json.load(open("dist/version.json")); print(" ".join(list(v["pins"].values()) + [v["spec-pin"]]))'); do
        echo "$p" | grep -Eq '^[0-9a-f]{7}$' || { echo "version.json publishes '$p'"; return 1; }
    done
    test -d dist/book && test -s dist/book/wolf-book.pdf || return 1
    head -c 5 dist/book/wolf-book.pdf | grep -q '%PDF-' || return 1
    grep -q '/book/wolf-book.pdf' dist/reading/index.html || return 1
    python3 scripts/check-links.py dist || return 1
    python3 scripts/check-std.py || return 1
    python3 scripts/std-reference.py --check || return 1
    python3 scripts/render-std.py dist/std/reference.json dist/std --check || return 1
    cat dist/version.json
}
samples() { cd "$G" && node scripts/check-samples.mjs dist upstream/wolf-lang/corpus 2>&1 | tail -6; return "${PIPESTATUS[0]}"; }
ahead() { cd "$G" && node scripts/check-ahead.mjs dist upstream/wolf-lang 2>&1 | tail -6; return "${PIPESTATUS[0]}"; }
witnesses() { cd "$G" && node --test tests/ahead-witnesses.test.mjs 2>&1 | tail -8; return "${PIPESTATUS[0]}"; }
target() { cd "$G" && WOLF_WEB_REQUIRE_MODULE=1 node --test tests/tab-target.test.mjs 2>&1 | tail -8; return "${PIPESTATUS[0]}"; }
stdref() {
    local D=$W/stdref-$S7
    rm -rf "$D" && mkdir -p "$D" && cd "$G" || return 1
    python3 -m unittest discover -s tests -p '*_test.py' > "$D/unittest.log" 2>&1 || { tail -5 "$D/unittest.log"; return 1; }
    echo "std-reference unittests: $(tail -1 "$D/unittest.log")"
    CHROMIUM=chromium node scripts/check-std-browser.mjs 2>&1 | tail -6; return "${PIPESTATUS[0]}"
}
lagred() {
    # the lag gate seen red: the pin commit c5a67ea, whose gitlinks are the head's for wolf-lang and
    # wolf-interp but whose pages still said eleven releases, must be refused by check-lag-phrases.py
    local D=$W/lagred-$S7 rc
    rm -rf "$D" && mkdir -p "$D" || return 1
    git -C "$G" archive c5a67ea site scripts | tar -x -C "$D" || return 1
    ln -s "$G/upstream" "$D/upstream" || return 1
    (cd "$D" && python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp) > "$D/lag.log" 2>&1
    rc=$?
    cat "$D/lag.log"
    [ "$rc" -ne 0 ] || { echo "the lag check passed the pin commit's pages; it should have refused them"; return 1; }
    grep -q "eleven releases" "$D/lag.log" || { echo "refused, but not for the eleven-release phrase"; return 1; }
    echo "seen red at c5a67ea: exit $rc, as it must be"
}
versions() {
    "$R/archives/wolf-0.2.36-x86_64-unknown-linux-gnu/wolf-0.2.36-x86_64-unknown-linux-gnu/wolf" --version || return 1
    "$R/archives/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin" --version || return 1
}
deploydiff() {
    # what a deploy of this head changes on lupp.us: the trunk build (dist-b5f5ac3) against this one
    local O=$W/dist-b5f5ac3 N=$W/dist-$S7
    test -d "$O" && test -d "$N" || { echo "need both dists"; return 1; }
    echo "-- version.json, trunk then head"; cat "$O/version.json"; cat "$N/version.json"
    echo "-- the front page's version line"; grep -o 'This is version [0-9.]*' "$O/index.html" "$N/index.html"
    echo "-- stamped versions on the pages (wolf 0.2.x / lupin 0.1.x literals, counted per page)"
    for f in index.html install/index.html play/index.html spec/index.html; do
        echo "$f trunk: $(grep -o '0\.2\.35\|0\.1\.56' "$O/$f" | sort | uniq -c | tr -s ' ' | tr '\n' ';') head: $(grep -o '0\.2\.36\|0\.1\.58' "$N/$f" | sort | uniq -c | tr -s ' ' | tr '\n' ';')"
    done
    echo "-- stamped counts (build.sh's own line)"; grep -h 'counts: .* stamped' "$W/build-b5f5ac3.log" "$W/build-$S7.log"
    echo "-- files"; (cd "$O" && find . -type f | sort) > "$W/files-old.txt"; (cd "$N" && find . -type f | sort) > "$W/files-new.txt"
    echo "added: $(comm -13 "$W/files-old.txt" "$W/files-new.txt" | wc -l), removed: $(comm -23 "$W/files-old.txt" "$W/files-new.txt" | wc -l), in both: $(comm -12 "$W/files-old.txt" "$W/files-new.txt" | wc -l)"
    comm -13 "$W/files-old.txt" "$W/files-new.txt" | head -20 | sed 's/^/  + /'
    comm -23 "$W/files-old.txt" "$W/files-new.txt" | head -20 | sed 's/^/  - /'
    local changed=0 f
    while read -r f; do cmp -s "$O/$f" "$N/$f" || { changed=$((changed + 1)); echo "$f" >> "$W/files-changed-$S7.txt"; }; done < <(rm -f "$W/files-changed-$S7.txt"; comm -12 "$W/files-old.txt" "$W/files-new.txt")
    echo "changed: $changed of those in both; by top directory:"
    sed -E 's|^\./([^/]+)/.*|\1/|; s|^\./([^/]+)$|\1|' "$W/files-changed-$S7.txt" | sort | uniq -c | sort -rn | head -20
}
echo "web-build $SHA $MODE cpus=${R41Q_CPUS:-unset} $(date -u +%FT%TZ)"
step clone clone
step pins pins
if [ "$MODE" = gauntlet ]; then
    step versions versions
    step lag-red-at-pin lagred
    step scripts-parse parse
    step node-tests nodetests
    step py-tests pytests
fi
step build build
if [ "$MODE" = gauntlet ]; then
    step advertises advertises
    step check-samples samples
    step check-ahead ahead
    step ahead-witnesses witnesses
    step tab-target target
    step std-reference stdref
    step deploy-diff deploydiff
fi
echo "WEB-BUILD-DONE $SHA"
