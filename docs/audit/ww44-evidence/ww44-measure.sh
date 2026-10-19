# ww44's census legs and probes (kasumi). Adapted from ww43-measure.sh:
# modules 0.1.53 (the one live on lupp.us since ww43's deploy, fetched, sha recorded) and 0.1.54 (0e536e8f, the pin, built here
# with trunk's wasm-portability.patch, which the build applies to the staged copy); corpora 0.2.30 (1b37f368) and 0.2.32 (72de141f).
# Probes: 0.2.31's seven builtins (book §34.5), one call each, §34.5's three programs and §3.3's two, through both modules;
# ww43's eighteen probes again through both.
set -x
L=~/lanes/ww44
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
git fetch -q origin ww44 || exit 1
git checkout -q -- . && git checkout -q -B ww44 ${1:-origin/ww44} || exit 1
test "$(git branch --show-current)" = ww44 || exit 1
git rev-parse HEAD
git submodule update --init --recursive || exit 1
git -C upstream/wolf-interp submodule update --init --recursive || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs docs/audit/ww38-evidence/ww38-records.mjs $L/ || exit 1
sha256sum crates/lupin-wasm/wasm-portability.patch
mkdir -p dist/play
./scripts/build-wasm.sh > $L/wasm-0154.log 2>&1; echo "WASM54-EXIT=$?"
cp dist/play/lupin.wasm $L/lupin-0.1.54.wasm || exit 1
curl -sfo $L/lupin-0.1.53.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.53.wasm $L/lupin-0.1.54.wasm $L/lupin-0.1.54-control.wasm
O=1b37f368228db92eca505c8c4cd3c531ea60be48; N=72de141f624662fdff522e8beba459fab7c5cf66
git -C upstream/wolf-lang checkout -q $O || exit 1
for v in 53 54; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0230-01$v.json > $L/leg-0230-01$v.txt 2>&1; echo "LEG 0230-01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
for v in 53 54; do node $L/census.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $L/census-0232-01$v.json > $L/leg-0232-01$v.txt 2>&1; echo "LEG 0232-01$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww44-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-1b37f36.txt $L/run-72de141.txt | sed 's|^corpus/||')
EXTRA="memory/raw_lshr_top_bits.lu os/signal_shell_rows.lu os/job_rows.lu conc/atomic_counter.lu os/signal_supervisor.lu os/chdir_relative.lu os/env_unset.lu link/module_c.lu"
for v in 54 53; do
  node $L/stdout-probe.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $ARR $EXTRA > $L/stdout-probe-01$v.txt 2>&1; echo "PROBE 01$v exit=$?"
done
REC="$ARR $EXTRA memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu grammar/cfg_target_arch.lu"
for v in 54 53; do node $L/ww38-records.mjs $L/lupin-0.1.$v.wasm upstream/wolf-lang/corpus $REC > $L/records-01$v.txt 2>&1; echo "RECORDS 01$v exit=$?"; done
node $L/ww44-stdout-all.mjs $L/lupin-0.1.53.wasm $L/lupin-0.1.54.wasm upstream/wolf-lang/corpus $(sed 's|^corpus/||' $L/run-72de141.txt) > $L/stdout-all.txt 2>&1; echo "STDOUT-ALL exit=$?"
for v in 54 53; do node $L/ww44-builtins.mjs $L/lupin-0.1.$v.wasm $L/probes > $L/builtins-01$v.txt 2>&1; echo "BUILTINS 01$v exit=$?"; done
for v in 54 53; do node $L/ww44-builtins.mjs $L/lupin-0.1.$v.wasm docs/audit/ww43-evidence/probes > $L/builtins-ww43-01$v.txt 2>&1; echo "BUILTINS-WW43 01$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
echo MEASURE-DONE; touch $L/measure.done
