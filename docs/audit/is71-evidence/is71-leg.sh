# is71's measurement leg on kasumi: build the module at a commit, hold it with
# tests/tab-target.test.mjs, census the pinned corpus through it, and record
# the cfg rows in full.   usage: bash is71-leg.sh <name> <commit>
set -u
L=~/lanes/is71; NAME=$1; REV=$2
export PATH="$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin is71 || exit 1
git checkout -q --detach "$REV" || exit 1
echo "HEAD $(git rev-parse HEAD)"
git submodule update --init --recursive || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
node --version
./scripts/build-wasm.sh > $L/wasm-$NAME.log 2>&1; echo "WASM-EXIT=$?"
tail -4 $L/wasm-$NAME.log
cp dist/play/lupin.wasm $L/lupin-$NAME.wasm || exit 1
sha256sum $L/lupin-$NAME.wasm
echo "=== tab-target suite"
WOLF_WEB_REQUIRE_MODULE=1 node --test tests/tab-target.test.mjs > $L/tab-target-$NAME.log 2>&1; echo "SUITE-EXIT=$?"
grep -E "^(not )?ok |^ℹ (tests|pass|fail|skipped)" $L/tab-target-$NAME.log
echo "=== census"
node docs/audit/ww33-evidence/census.mjs $L/lupin-$NAME.wasm upstream/wolf-lang/corpus $L/census-$NAME.json > $L/census-$NAME.txt 2>&1; echo "CENSUS-EXIT=$?"
tail -6 $L/census-$NAME.txt
echo "=== records"
node docs/audit/ww38-evidence/ww38-records.mjs $L/lupin-$NAME.wasm upstream/wolf-lang/corpus \
  ffi.lu grammar/cfg_target_arch.lu grammar/cfg_target_freestanding.lu grammar/cfg_target_unknown.lu membrane/extern_let_image.lu \
  > $L/records-$NAME.txt 2>&1; echo "RECORDS-EXIT=$?"
cut -c1-400 $L/records-$NAME.txt
echo LEG-DONE; touch $L/leg-$NAME.done
