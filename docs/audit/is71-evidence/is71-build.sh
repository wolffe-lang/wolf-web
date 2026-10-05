# is71: the full site build and CI's gates at a commit (kasumi). Adapted from ww38-build.sh.
# typst is ww38's pinned binary, used read-only from its lane dir.   usage: bash is71-build.sh <commit>
set -u
L=~/lanes/is71; REV=$1
export PATH="$HOME/lanes/ww38/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin is71 || exit 1
git checkout -q --detach "$REV" || exit 1
echo "HEAD $(git rev-parse HEAD)"
git submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
python3 --version; node --version; typst --version
echo "=== node tests (pre-build)"; node --test tests/*.test.mjs > $L/pre.log 2>&1; echo "PRE-EXIT=$?"; grep -E "^ℹ (tests|pass|fail)" $L/pre.log
echo "=== build"; ./scripts/build.sh > $L/build.log 2>&1; echo "BUILD-EXIT=$?"
grep -E "version prose|counts:|lag phrases|stamped|wasm:|samples|everything built|dist/ built" $L/build.log
echo "=== samples"; node scripts/check-samples.mjs dist upstream/wolf-lang/corpus > $L/samples.log 2>&1; echo "SAMPLES-EXIT=$?"; tail -3 $L/samples.log
echo "=== ahead"; node scripts/check-ahead.mjs dist upstream/wolf-lang > $L/ahead.log 2>&1; echo "AHEAD-EXIT=$?"; tail -2 $L/ahead.log
echo "=== ahead planted"; node --test tests/ahead-witnesses.test.mjs 2>&1 | grep -E "^ℹ (tests|pass|fail)"
echo "=== tab target"; WOLF_WEB_REQUIRE_MODULE=1 node --test tests/tab-target.test.mjs > $L/tab-target-build.log 2>&1; echo "TAB-EXIT=$?"; grep -E "^ℹ (tests|pass|fail|skipped)" $L/tab-target-build.log
echo "=== links"; python3 scripts/check-links.py dist > $L/links.log 2>&1; echo "LINKS-EXIT=$?"
echo "=== wasm"; sha256sum dist/play/lupin.wasm
echo "=== banner source"; grep -n "reading cfg as" dist/play/lupin.js
echo BUILD-DONE; touch $L/build.done
