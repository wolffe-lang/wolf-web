# ww39's census legs and probes (kasumi). Adapted from ww38-measure.sh:
# modules 0.1.46 (the one live on lupp.us since is71's deploy, fetched, sha recorded) and 0.1.48 (531bf058, the pin, built here);
# corpora 0.2.23 (8edac3ee) and 0.2.25 (6710f9e0).
set -x
L=~/lanes/ww39
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww39 || exit 1
git checkout -q -B ww39 origin/ww39 || exit 1
test "$(git branch --show-current)" = ww39 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
# measured at the wolf pin, before the lupin gitlink commit: the interpreter checkout is moved to the target by hand
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q 531bf0581dea6bba4b1247edb2abada5214c18ab || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs docs/audit/ww38-evidence/ww38-records.mjs $L/ || exit 1
mkdir -p dist/play
# 0.1.48 module (the gitlink-to-be)
./scripts/build-wasm.sh > $L/wasm-0148.log 2>&1; echo "WASM48-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.48.wasm || exit 1
# 0.1.46 module: the one served live since is71's deploy
curl -sfo $L/lupin-0.1.46.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.4*.wasm
O=8edac3eeb48632b32f02ef41ea87d484d1423492; N=6710f9e0cbc3a7264349093751ce7a46a407e473
git -C upstream/wolf-lang checkout -q $O || exit 1
for v in 46 48; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0223-01$v.json > $L/leg-0223-01$v.txt 2>&1; echo "LEG 0223-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
for v in 46 48; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0225-01$v.json > $L/leg-0225-01$v.txt 2>&1; echo "LEG 0225-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww39-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-8edac3e.txt $L/run-6710f9e.txt | sed 's|^corpus/||')
EXTRA="comptime/layout_query_repr_c.lu memory/packed_fields_at_offset_of.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu"
for v in 48 46; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR $EXTRA > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
REC="$ARR $EXTRA memory/volatile_widths.lu memory/raw_repr_c_layout.lu membrane/extern_libc.lu grammar/attr_implemented_set.lu"
for v in 48 46; do node $L/ww38-records.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $REC > $L/records-01$v.txt 2>&1; echo "RECORDS 01$v exit=$?"; done
# every run program's stdout under both modules on the 0.2.25 corpus: what 0.1.48 prints differently from the live module
node $L/ww39-stdout-all.mjs $L/lupin-0.1.46.wasm $L/lupin-0.1.48.wasm upstream/wolf-lang/corpus $(sed 's|^corpus/||' $L/run-6710f9e.txt) > $L/stdout-all.txt 2>&1; echo "STDOUT-ALL exit=$?"
git -C upstream/wolf-lang checkout -q $O || exit 1
echo MEASURE-DONE; touch $L/measure.done
