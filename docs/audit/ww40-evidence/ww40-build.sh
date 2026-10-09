# ww40's full build and gates at the branch head (kasumi). Adapted from ww39-build.sh.
L=~/lanes/ww40
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww40 || exit 1
git checkout -q -- . && git checkout -q -B ww40 origin/ww40 || exit 1
test "$(git branch --show-current)" = ww40 || exit 1
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
echo "=== stamps"; grep -oE "(two hundred and thirteen) commits" dist/install/index.html dist/play/index.html | sort | uniq -c
echo "=== phrases"; for f in dist/install/index.html dist/play/index.html; do for p in "the same commit" "one release" "two releases" "three releases" "a development revision"; do printf '%s %s %s\n' "$f" "$p" "$(grep -c "$p" $f)"; done; done
echo "=== chapter 7 diagrams"; grep -o '<figure class="memory-diagram"><img src="[^"]*"' dist/book/ch07.html; ls -l dist/book/diagrams/ch07/; sha256sum dist/book/diagrams/ch07/*.svg
echo "=== new samples"; grep -c "copy region" dist/book/ch08.html; grep -c "never" dist/book/ch06.html; grep -c "0xfff\|mask" dist/book/ch02.html
echo "=== svg contents scan (script/style/external refs)"; grep -cE '<script|<style|style=|href=|@import|url\(' dist/book/diagrams/ch07/*.svg
echo "=== stamps (counts)"; grep -oE "(fifty|two hundred and thirteen) commits" dist/install/index.html dist/play/index.html | sort | uniq -c
echo "=== play banner"; grep -o "x86_64-unknown-linux-gnu" dist/play/index.html | head -2
echo "=== tab target suite"; node --test tests/tab-target.test.mjs 2>&1 | grep -E "^ℹ (tests|pass|fail)"
echo BUILD-DONE; touch $L/build.done
