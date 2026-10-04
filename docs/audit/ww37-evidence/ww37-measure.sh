# ww37's census legs and probes (kasumi). Adapted from ww36-measure.sh:
# modules 0.1.44 (the one live on lupp.us, fetched, sha recorded) and 0.1.45 (9f4e4a17, the pin, built here);
# corpora 0.2.21 (dfcc2f13) and 0.2.22 (8e36bc1a).
set -x
L=~/lanes/ww37
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww37 || exit 1
git checkout -q -B ww37 origin/ww37 || exit 1
test "$(git branch --show-current)" = ww37 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
# measured at the wolf pin, before the lupin gitlink commit: the interpreter checkout is moved to the target by hand
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q 9f4e4a175da109bc4dc0acec3e8a4bc54358b941 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs $L/ || exit 1
mkdir -p dist/play
# 0.1.45 module (the gitlink)
./scripts/build-wasm.sh > $L/wasm-0145.log 2>&1; echo "WASM45-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.45.wasm || exit 1
# 0.1.44 module: the one served live at ww36's deploy
curl -sfo $L/lupin-0.1.44.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.4*.wasm
# census legs
git -C upstream/wolf-lang checkout -q dfcc2f13e7c73182bdd41fc9bec2802c7da3b024 || exit 1
for v in 44 45; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0221-01$v.json > $L/leg-0221-01$v.txt 2>&1; echo "LEG 0221-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q 8e36bc1a0f92bbbbc6861b10d5b2638f76412d6a || exit 1
for v in 44 45; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0222-01$v.json > $L/leg-0222-01$v.txt 2>&1; echo "LEG 0222-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww37-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-dfcc2f1.txt $L/run-8e36bc1.txt | sed 's|^corpus/||')
for v in 45 44; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR rows/eu_bind_empty_row_handled.lu typecheck/numlit_binding_value_later_use.lu > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
echo MEASURE-DONE; touch $L/measure.done
