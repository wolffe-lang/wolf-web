# ww41's census legs and probes (kasumi). Adapted from ww40-measure.sh:
# modules 0.1.49 (the one live on lupp.us since ww40's deploy, fetched, sha recorded) and 0.1.51 (f72e78d7, the pin, built here
# with trunk's wasm-portability.patch, which the build applies to the staged copy); corpora 0.2.26 (89dc1394) and 0.2.28 (f71ece8e).
set -x
L=~/lanes/ww41
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
git fetch -q origin ww41 || exit 1
git checkout -q -- . && git checkout -q -B ww41 ${1:-origin/ww41} || exit 1
test "$(git branch --show-current)" = ww41 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
# measured at the wolf pin, before the lupin gitlink commit: the interpreter checkout is moved to the target by hand
git -C upstream/wolf-interp fetch -q --tags origin || exit 1
git -C upstream/wolf-interp checkout -q f72e78d7a9d0ceb39d80380389ad6a2072991c63 || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs docs/audit/ww38-evidence/ww38-records.mjs $L/ || exit 1
sha256sum crates/lupin-wasm/wasm-portability.patch
mkdir -p dist/play
./scripts/build-wasm.sh > $L/wasm-0151.log 2>&1; echo "WASM51-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.51.wasm || exit 1
curl -sfo $L/lupin-0.1.49.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.49.wasm $L/lupin-0.1.51.wasm
O=89dc139443da38078df6093568da87bc6d0ee6f9; N=f71ece8e1ad2234940040d300359888932ad67af
git -C upstream/wolf-lang checkout -q $O || exit 1
for v in 49 51; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0226-01$v.json > $L/leg-0226-01$v.txt 2>&1; echo "LEG 0226-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
for v in 49 51; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0228-01$v.json > $L/leg-0228-01$v.txt 2>&1; echo "LEG 0228-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww41-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-89dc139.txt $L/run-f71ece8.txt | sed 's|^corpus/||')
EXTRA="conc/atomic_counter.lu conc/chan_struct_payload.lu conc/reason_interp.lu net/spawn_accept.lu os/signal_supervisor.lu os/chdir_relative.lu"
for v in 51 49; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR $EXTRA > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
REC="$ARR $EXTRA memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu grammar/cfg_target_arch.lu"
for v in 51 49; do node $L/ww38-records.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $REC > $L/records-01$v.txt 2>&1; echo "RECORDS 01$v exit=$?"; done
node $L/ww41-stdout-all.mjs $L/lupin-0.1.49.wasm $L/lupin-0.1.51.wasm upstream/wolf-lang/corpus $(sed 's|^corpus/||' $L/run-f71ece8.txt) > $L/stdout-all.txt 2>&1; echo "STDOUT-ALL exit=$?"
git -C upstream/wolf-lang checkout -q $O || exit 1
echo MEASURE-DONE; touch $L/measure.done
