# ww36's census legs and probes (kasumi). Adapted from ww35-measure.sh:
# modules 0.1.42 (8e2516d, the deployed one) and 0.1.44 (ba47627, the pin);
# corpora 0.2.19 (c2401f05) and 0.2.21 (dfcc2f13).
set -x
L=~/lanes/ww36
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww36 || exit 1
git checkout -q -B ww36 origin/ww36 || exit 1
test "$(git branch --show-current)" = ww36 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs $L/ || exit 1
mkdir -p dist/play
# 0.1.44 module (the gitlink)
./scripts/build-wasm.sh > $L/wasm-0144.log 2>&1; echo "WASM44-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.44.wasm || exit 1
# 0.1.42 module (the deployed one) for the control legs
git -C upstream/wolf-interp checkout -q 8e2516dc47bf808512388cc687e070981d331d98 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive
./scripts/build-wasm.sh > $L/wasm-0142.log 2>&1; echo "WASM42-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.42.wasm || exit 1
git -C upstream/wolf-interp checkout -q ba4762714d75c37bb14b300610e2d52630665a05 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive
cp $L/lupin-0.1.44.wasm dist/play/lupin.wasm
sha256sum $L/lupin-0.1.4*.wasm
# census legs
git -C upstream/wolf-lang checkout -q c2401f05f37794a078d2acf62f837dad98e5950d || exit 1
for v in 42 44; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0219-01$v.json > $L/leg-0219-01$v.txt 2>&1; echo "LEG 0219-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q dfcc2f13e7c73182bdd41fc9bec2802c7da3b024 || exit 1
for v in 42 44; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0221-01$v.json > $L/leg-0221-01$v.txt 2>&1; echo "LEG 0221-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww36-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-c2401f0.txt $L/run-dfcc2f1.txt | sed 's|^corpus/||')
for v in 44 42; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR grammar/range_header_inclusive_max.lu grammar/range_value_wide_iter.lu > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
echo MEASURE-DONE
