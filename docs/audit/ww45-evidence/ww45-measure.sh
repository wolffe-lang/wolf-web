# ww45's census legs and probes (kasumi). Adapted from ww44-measure.sh. The interpreter pin does not move, so the two
# modules are both lupin 0.1.54: the one live on lupp.us since ww44's deploy (built by the deploy host, fetched, sha
# recorded) and the one built here at 0e536e8f with trunk's wasm-portability.patch (the control, ww45-wasm-control.sh);
# corpora 0.2.32 (72de141f) and 0.2.33 (85dab5d7).
# Probes: 0.2.33's five builtins one call each, text(0), §34.6's two programs and §34.5's three (wolf-book 3ac6fa9),
# through both modules; ww44's twelve probes and ww43's eighteen again through both.
set -x
L=~/lanes/ww45
export PATH="$L/bin:$HOME/.cargo/bin:$PATH" CARGO_BUILD_JOBS=4 CARGO_INCREMENTAL=0
cd $L/web || exit 1
test "$(git branch --show-current)" = ww45 || exit 1
git rev-parse HEAD
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse HEAD)"; done
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww33-evidence/stdout-probe.mjs docs/audit/ww38-evidence/ww38-records.mjs $L/ || exit 1
curl -sfo $L/lupin-0.1.54-live.wasm https://lupp.us/play/lupin.wasm || exit 1
sha256sum $L/lupin-0.1.54-live.wasm $L/lupin-0.1.54-control.wasm
O=72de141f624662fdff522e8beba459fab7c5cf66; N=85dab5d7e597680d6fd7034f1d7ed2acb9a92f97
git -C upstream/wolf-lang checkout -q $O || exit 1
for v in live control; do node $L/census.mjs $L/lupin-0.1.54-$v.wasm upstream/wolf-lang/corpus $L/census-0232-$v.json > $L/leg-0232-$v.txt 2>&1; echo "LEG 0232-$v exit=$?"; done
git -C upstream/wolf-lang checkout -q $N || exit 1
for v in live control; do node $L/census.mjs $L/lupin-0.1.54-$v.wasm upstream/wolf-lang/corpus $L/census-0233-$v.json > $L/leg-0233-$v.txt 2>&1; echo "LEG 0233-$v exit=$?"; done
git -C upstream/wolf-lang rev-parse HEAD; git -C upstream/wolf-interp rev-parse HEAD
python3 $L/ww45-rows.py > $L/rows.txt 2>&1
ARR=$(comm -13 $L/run-72de141.txt $L/run-85dab5d.txt | sed 's|^corpus/||')
EXTRA="os/group_rows.lu os/job_poll_rows.lu comptime/shift_value.lu os/signal_shell_rows.lu os/job_rows.lu conc/atomic_counter.lu os/signal_supervisor.lu os/chdir_relative.lu os/env_unset.lu link/module_c.lu"
for v in control live; do
  node $L/stdout-probe.mjs $L/lupin-0.1.54-$v.wasm upstream/wolf-lang/corpus $ARR $EXTRA > $L/stdout-probe-$v.txt 2>&1; echo "PROBE $v exit=$?"
done
REC="$ARR $EXTRA memory/raw_repr_c_layout.lu memory/raw_repr_packed_layout.lu memory/raw_repr_align_layout.lu membrane/extern_let_image.lu membrane/extern_libc.lu grammar/cfg_target_arch.lu"
for v in control live; do node $L/ww38-records.mjs $L/lupin-0.1.54-$v.wasm upstream/wolf-lang/corpus $REC > $L/records-$v.txt 2>&1; echo "RECORDS $v exit=$?"; done
node $L/ww45-stdout-all.mjs $L/lupin-0.1.54-live.wasm $L/lupin-0.1.54-control.wasm upstream/wolf-lang/corpus $(sed 's|^corpus/||' $L/run-85dab5d.txt) > $L/stdout-all.txt 2>&1; echo "STDOUT-ALL exit=$?"
for v in control live; do node $L/ww45-builtins.mjs $L/lupin-0.1.54-$v.wasm $L/probes > $L/builtins-$v.txt 2>&1; echo "BUILTINS $v exit=$?"; done
for v in control live; do node $L/ww45-builtins.mjs $L/lupin-0.1.54-$v.wasm docs/audit/ww44-evidence/probes > $L/builtins-ww44-$v.txt 2>&1; echo "BUILTINS-WW44 $v exit=$?"; done
for v in control live; do node $L/ww45-builtins.mjs $L/lupin-0.1.54-$v.wasm docs/audit/ww43-evidence/probes > $L/builtins-ww43-$v.txt 2>&1; echo "BUILTINS-WW43 $v exit=$?"; done
git -C upstream/wolf-lang checkout -q $O || exit 1
echo MEASURE-DONE; touch $L/measure.done
