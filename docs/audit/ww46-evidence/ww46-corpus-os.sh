# ww46: the corpus's os rows that /install/ and /play/ name, verbatim from wolf-lang v0.2.34, through both modules
# (the live lupp.us lupin 0.1.54 and this lane's 0.1.55), to read the tab's reason word for each (the census keeps
# only the class).
L=~/lanes/ww46; C=$L/web/upstream/wolf-lang
test "$(git -C $C rev-parse HEAD)" = 9da7bdcf2aea9adf48df6570bedc58e16e9ef853 || exit 1
D=$L/corpus-os; rm -rf "${L:?}/corpus-os"; mkdir -p $D
for f in signal_one_rows group_rows job_poll_rows term_editor_rows signal_gaps_rows; do test -f $C/corpus/os/$f.lu && cp $C/corpus/os/$f.lu $D/; done
ls $D
for module in live control; do
  if [ "$module" = live ]; then wasm=$L/lupin-0.1.54-live.wasm; else wasm=$L/lupin-0.1.55-control.wasm; fi
  node $L/ww45-builtins.mjs $wasm $D > $L/corpus-os-$module.txt || exit 1
done
python3 -I - <<'PY'
import json, pathlib
L = pathlib.Path.home() / 'lanes/ww46'
rows = {}
for module in ('live', 'control'):
    for line in (L / f'corpus-os-{module}.txt').read_text().splitlines():
        if ': {' not in line: continue
        f, rec = line.split(': ', 1); r = json.loads(rec)
        rows.setdefault(f, {})[module] = (r['verdict'], r['phase'], r['unsupported'])
for f, m in sorted(rows.items()):
    print(f"{f}: 0.1.54 {m['live'][0]} :: {m['live'][2]}")
    print(f"{' '*len(f)}  0.1.55 {m['control'][0]} :: {m['control'][2]}")
PY
rm -rf "${L:?}/corpus-os"
echo CORPUS-OS-DONE
