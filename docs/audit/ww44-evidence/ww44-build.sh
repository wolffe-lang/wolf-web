# ww44's full build and gates at the branch head (kasumi). Adapted from ww44-build.sh.
L=~/lanes/ww44
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
git fetch -q origin ww44 || exit 1
git checkout -q -- . && git checkout -q -B ww44 origin/ww44 || exit 1
test "$(git branch --show-current)" = ww44 || exit 1
echo "HEAD $(git rev-parse HEAD)"
git submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
python3 --version; node --version; typst --version
echo "=== node tests (pre-build)"; node --test tests/*.test.mjs 2>&1 | grep -E "^ℹ (tests|pass|fail)"
echo "=== build"; ./scripts/build.sh > $L/build.log 2>&1; echo "BUILD-EXIT=$?"
grep -E "version prose|counts:|lag phrases|stamped|file sizes|revisions:|book:|book assets|pdf:|wasm:|samples|everything built|dist/ built" $L/build.log
echo "=== guard json"; python3 scripts/check-lag-phrases.py --json site upstream/wolf-lang upstream/wolf-interp
echo "=== version.json"; cat dist/version.json
echo "=== links"; python3 scripts/check-links.py dist; echo "LINKS-EXIT=$?"
echo "=== samples"; node scripts/check-samples.mjs dist upstream/wolf-lang/corpus 2>&1 | tail -4; echo "SAMPLES-EXIT=$?"
echo "=== ahead"; node scripts/check-ahead.mjs dist upstream/wolf-lang 2>&1 | tail -3; echo "AHEAD-EXIT=$?"
echo "=== ahead planted"; node --test tests/ahead-witnesses.test.mjs 2>&1 | grep -E "^ℹ (tests|pass|fail)"
echo "=== pages"; find dist -name '*.html' | grep -v '^dist/book/' | grep -v '^dist/docs/api/' | wc -l; find dist/book -name '*.html' | wc -l
echo "=== all html (site pages as ww34 counted)"; find dist -name '*.html' | wc -l
echo "=== book asset refs"; grep -rhoE '(src|href)="[^"]*\.(js|css)(\?v=[0-9a-f]+)?"' dist/book --include='*.html' | sed -E 's/.*\.(js|css)(\?v=[0-9a-f]+)?"/\1 \2/' | sort | uniq -c
echo "=== bare local js/css refs in dist/book"; grep -rnoE '(src|href)="[^"?:#]*\.(js|css)"' dist/book --include='*.html' | grep -v '"//' | wc -l
echo "=== wolf-boot refs"; grep -rhoE "wolf-boot\.js[^\"]*\"" dist/book --include="*.html" | sort | uniq -c
echo "=== md under dist/book"; find dist/book -name '*.md' | wc -l
echo "=== wasm"; sha256sum dist/play/lupin.wasm; ls -l dist/book/wolf-book.pdf
echo "=== stamps"; grep -oE "(nine hundred and thirteen) commits" dist/install/index.html dist/play/index.html | sort | uniq -c
echo "=== phrases"; for f in dist/install/index.html dist/play/index.html; do for p in "the same commit" "one release" "two releases" "three releases" "four releases" "five releases" "six releases" "seven releases" "eight releases" "a development revision"; do printf '%s %s %s\n' "$f" "$p" "$(grep -c "$p" $f)"; done; done
echo "=== chapter 7 diagrams"; grep -o '<figure class="memory-diagram"><img src="[^"]*"' dist/book/ch07.html; ls -l dist/book/diagrams/ch07/; sha256sum dist/book/diagrams/ch07/*.svg
echo "=== the changed chapters (ch01 Windows block, ch01 old name, ch22 toolchain line, ch22 old, colophon distance)"; grep -c "wolf-0.2.32-x86_64-pc-windows-msvc" dist/book/ch01.html; grep -c "wolf-0.2.30-x86_64-pc-windows-msvc" dist/book/ch01.html; grep -c "toolchain 0.2.32" dist/book/ch22.html; grep -c "toolchain 0.2.30" dist/book/ch22.html; grep -o "913 commits, eight releases" dist/book/colophon.html | head -1
echo "=== install page: the Windows archive name as stamped"; grep -o "wolf-0.2.32-x86_64-pc-windows-msvc[^\"<; ]*" dist/install/index.html | sort | uniq -c
echo "=== unreleased surfaces named on any built site page (expect 0 lines): wolf-std dcf3e89's wrappers (ruling #85)"; grep -rlE "process\.(poll|Status|Group|Change|status_from|group_of|own_group|lead_group|join_group)|signal\.(send_group|send_all|last|realtime|text|host)\b|(lead|join|own)_group\(" dist --include="*.html" | grep -v "^dist/changelog/" | grep -v "^dist/spec/" | grep -v "^dist/book/" ; echo "(end)"
echo "=== chapter 34 and 3: anchors, /play/ links"; ls -l dist/book/ch34.html dist/book/ch03.html; for a in 34.1 34.2 34.3 34.4 34.5; do printf '%s id=%s\n' "$a" "$(grep -c "id=\"$a\"" dist/book/ch34.html)"; done; printf '3.3 id=%s\n' "$(grep -c 'id="3.3"' dist/book/ch03.html)"; grep -c 'href="/book/ch34.html#34.5"' dist/play/index.html; grep -c 'href="/book/ch34.html#34.3"' dist/play/index.html; grep -c 'href="/book/ch03.html#3.3"' dist/play/index.html; grep -c "exit status is 71" dist/book/ch33.html; grep -c "os_wait_poll" dist/book/ch34.html
echo "=== ch07 svgs vs ww43 (sha256)"; sha256sum dist/book/diagrams/ch07/*.svg | cut -c1-16
echo "=== svg contents scan (script/style/external refs)"; grep -cE '<script|<style|style=|href=|@import|url\(' dist/book/diagrams/ch07/*.svg
echo "=== stamps (counts)"; grep -oE "(seven hundred and seventeen|nine hundred and thirteen) commits" dist/install/index.html dist/play/index.html | sort | uniq -c
echo "=== play banner"; grep -o "x86_64-unknown-linux-gnu" dist/play/index.html | head -2
echo "=== tab target suite"; node --test tests/tab-target.test.mjs 2>&1 | grep -E "^ℹ (tests|pass|fail)"
echo BUILD-DONE; touch $L/build.done
