# ww40's census legs and probes (kasumi). Adapted from ww39-measure.sh:
# modules 0.1.48 (the one live on lupp.us since ww39's deploy, fetched, sha recorded) and 0.1.49 (f516a5f4, the pin, built here);
# corpora 0.2.25 (6710f9e0) and 0.2.26 (89dc1394).
set -x
L=~/lanes/ww40
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4
cd $L/web || exit 1
git fetch -q origin ww40 || exit 1
git checkout -q -- . && git checkout -q -B ww40 ${1:-origin/ww40} || exit 1
test "$(git branch --show-current)" = ww40 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
# measured at the wolf pin, before the lupin gitlink commit: the interpreter checkout is moved to the target by hand
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q f516a5f4ea4341acd3a30f3e5cdd4327aede1912 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs docs/audit/ww38-evidence/ww38-records.mjs $L/ || exit 1
mkdir -p dist/play
# lupin 0.1.49 does not compile for wasm32 as it stands (os_error_text calls eval::fs, gated out on wasm):
# the portability patch build-wasm.sh is designed to apply, staged here before the lupin pin commit carries it
cp $L/wasm-portability.patch crates/lupin-wasm/wasm-portability.patch || exit 1
sha256sum crates/lupin-wasm/wasm-portability.patch
./scripts/build-wasm.sh > $L/wasm-0149.log 2>&1; echo "WASM49-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.49.wasm || exit 1
curl -sfo $L/lupin-0.1.48.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.4*.wasm
O=6710f9e0cbc3a7264349093751ce7a46a407e473; N=89dc139443da38078df6093568da87bc6d0ee6f9
git -C upstream/wolf-lang checkout -q $O || exit 1
for v in 48 49; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0225-01$v.json > $L/leg-0225-01$v.txt 2>&1; echo "LEG 0225-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
for v in 48 49; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0226-01$v.json > $L/leg-0226-01$v.txt 2>&1; echo "LEG 0226-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww40-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-6710f9e.txt $L/run-89dc139.txt | sed 's|^corpus/||')
EXTRA="conc/atomic_fence.lu conc/atomic_orders.lu conc/atomic_widths.lu memory/volatile_widths.lu memory/packed_field_raw_read.lu"
for v in 49 48; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR $EXTRA > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
REC="$ARR $EXTRA conc/atomic_counter.lu memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu grammar/attr_implemented_set.lu grammar/cfg_target_arch.lu"
for v in 49 48; do node $L/ww38-records.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $REC > $L/records-01$v.txt 2>&1; echo "RECORDS 01$v exit=$?"; done
node $L/ww40-stdout-all.mjs $L/lupin-0.1.48.wasm $L/lupin-0.1.49.wasm upstream/wolf-lang/corpus $(sed 's|^corpus/||' $L/run-89dc139.txt) > $L/stdout-all.txt 2>&1; echo "STDOUT-ALL exit=$?"
git -C upstream/wolf-lang checkout -q $O || exit 1
echo MEASURE-DONE; touch $L/measure.done
