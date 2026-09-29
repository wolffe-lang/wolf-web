set -x
L=~/lanes/ww34
export PATH="$L/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww34 || exit 1
git checkout -q -B ww34 origin/ww34 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs $L/
mkdir -p dist/play
# 0.1.41 module (the gitlink)
./scripts/build-wasm.sh > $L/wasm-0141.log 2>&1; echo "WASM41-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.41.wasm || exit 1
# 0.1.40 module (the deployed one) for the control legs
git -C upstream/wolf-interp checkout -q 54f85e694d4c03e5cd40bef461f85ca0ac373332 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive
./scripts/build-wasm.sh > $L/wasm-0140.log 2>&1; echo "WASM40-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.40.wasm || exit 1
git -C upstream/wolf-interp checkout -q 0cfc0cfc89af5fd2aeb71d46c86742745b902869 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive
cp $L/lupin-0.1.41.wasm dist/play/lupin.wasm
sha256sum $L/lupin-0.1.4*.wasm
# census legs
git -C upstream/wolf-lang checkout -q 02afce84f05c7841856a10671b6d7924f79193cc || exit 1
for v in 0140 0141; do node $L/census.mjs $L/lupin-0.1.${v#01}.wasm upstream/wolf-lang/corpus $L/census-0217-$v.json > $L/leg-0217-$v.txt 2>&1; echo "LEG 0217-$v exit=$?"; done
git -C upstream/wolf-lang checkout -q ec56a08f04ff318ea659fd58683f7ae4f22dc7a5 || exit 1
for v in 0140 0141; do node $L/census.mjs $L/lupin-0.1.${v#01}.wasm upstream/wolf-lang/corpus $L/census-0218-$v.json > $L/leg-0218-$v.txt 2>&1; echo "LEG 0218-$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww34-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-02afce8.txt $L/run-ec56a08.txt | sed 's|^corpus/||')
for v in 41 40; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR grammar/range_header_inclusive_max.lu grammar/range_value_wide_iter.lu memory/list_session_struct.lu > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
echo MEASURE-DONE
