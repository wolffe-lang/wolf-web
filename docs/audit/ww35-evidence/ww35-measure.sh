# ww35's census legs and probes (kasumi). Adapted from ww34-measure.sh:
# modules 0.1.41 (0cfc0cf, the deployed one) and 0.1.42 (8e2516d, the pin);
# corpora 0.2.18 (ec56a08f) and 0.2.19 (c2401f05).
set -x
L=~/lanes/ww35
export PATH="$L/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww35 || exit 1
git checkout -q -B ww35 origin/ww35 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs $L/ || exit 1
mkdir -p dist/play
# 0.1.42 module (the gitlink)
./scripts/build-wasm.sh > $L/wasm-0142.log 2>&1; echo "WASM42-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.42.wasm || exit 1
# 0.1.41 module (the deployed one) for the control legs
git -C upstream/wolf-interp checkout -q 0cfc0cfc89af5fd2aeb71d46c86742745b902869 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive
./scripts/build-wasm.sh > $L/wasm-0141.log 2>&1; echo "WASM41-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.41.wasm || exit 1
git -C upstream/wolf-interp checkout -q 8e2516dc47bf808512388cc687e070981d331d98 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive
cp $L/lupin-0.1.42.wasm dist/play/lupin.wasm
sha256sum $L/lupin-0.1.4*.wasm
# census legs
git -C upstream/wolf-lang checkout -q ec56a08f04ff318ea659fd58683f7ae4f22dc7a5 || exit 1
for v in 0141 0142; do node $L/census.mjs $L/lupin-0.1.${v#01}.wasm upstream/wolf-lang/corpus $L/census-0218-$v.json > $L/leg-0218-$v.txt 2>&1; echo "LEG 0218-$v exit=$?"; done
git -C upstream/wolf-lang checkout -q c2401f05f37794a078d2acf62f837dad98e5950d || exit 1
for v in 0141 0142; do node $L/census.mjs $L/lupin-0.1.${v#01}.wasm upstream/wolf-lang/corpus $L/census-0219-$v.json > $L/leg-0219-$v.txt 2>&1; echo "LEG 0219-$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww35-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-ec56a08.txt $L/run-c2401f0.txt | sed 's|^corpus/||')
for v in 42 41; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR grammar/range_header_inclusive_max.lu grammar/range_value_wide_iter.lu memory/ctl_store_order_nested_index.lu > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
echo MEASURE-DONE
