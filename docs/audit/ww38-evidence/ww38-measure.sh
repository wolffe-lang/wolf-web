# ww38's census legs and probes (kasumi). Adapted from ww37-measure.sh:
# modules 0.1.45 (the one live on lupp.us, fetched, sha recorded) and 0.1.46 (f9269e33, the pin, built here);
# corpora 0.2.22 (8e36bc1a) and 0.2.23 (8edac3ee).
set -x
L=~/lanes/ww38
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww38 || exit 1
git checkout -q -B ww38 origin/ww38 || exit 1
test "$(git branch --show-current)" = ww38 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
# measured at the wolf pin, before the lupin gitlink commit: the interpreter checkout is moved to the target by hand
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q f9269e3364169585fdfe92407639418220be373b || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs $L/ || exit 1
mkdir -p dist/play
# 0.1.46 module (the gitlink)
./scripts/build-wasm.sh > $L/wasm-0146.log 2>&1; echo "WASM46-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.46.wasm || exit 1
# 0.1.45 module: the one served live at ww37's deploy
curl -sfo $L/lupin-0.1.45.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.4*.wasm
# census legs
O=8e36bc1a0f92bbbbc6861b10d5b2638f76412d6a; N=8edac3eeb48632b32f02ef41ea87d484d1423492
git -C upstream/wolf-lang checkout -q $O || exit 1
for v in 45 46; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0222-01$v.json > $L/leg-0222-01$v.txt 2>&1; echo "LEG 0222-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
for v in 45 46; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0223-01$v.json > $L/leg-0223-01$v.txt 2>&1; echo "LEG 0223-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww38-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-8e36bc1.txt $L/run-8edac3e.txt | sed 's|^corpus/||')
EXTRA="rows/unit_discard_if_value.lu grammar/cfg_target_arch.lu grammar/cfg_target_freestanding.lu memory/raw_ptr_private_sig.lu memory/raw_ptr_mut_param.lu"
for v in 46 45; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR $EXTRA > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
# the full record (reason included) for every row the pages may name: arrivals, the module-leg rows, the standing declines among 0.2.22's arrivals
REC="$ARR $EXTRA membrane/extern_libc.lu grammar/attr_implemented_set.lu memory/raw_repr_c_layout.lu"
for v in 46 45; do node $L/ww38-records.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $REC > $L/records-01$v.txt 2>&1; echo "RECORDS 01$v exit=$?"; done
echo MEASURE-DONE; touch $L/measure.done
