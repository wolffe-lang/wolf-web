# ww46: the seven 0.2.34 calls one each (the two malformed probes of the first pass fixed: `List[int]::new()` and
# `List[byte]::new()` are no wolf spelling, so those two records were a parse error, E0201, not the call's answer),
# §34.7's two programs and §34.8's two verbatim from wolf-book f1fd824, and ww45's eleven 0.2.33 probes, through
# the live lupp.us module (lupin 0.1.54) and this lane's lupin 0.1.55 build, as /play/ loads it.
L=~/lanes/ww46
cd $L/web || exit 1
sha256sum $L/lupin-0.1.54-live.wasm $L/lupin-0.1.55-control.wasm
for module in live control; do
  if [ "$module" = live ]; then wasm=$L/lupin-0.1.54-live.wasm; else wasm=$L/lupin-0.1.55-control.wasm; fi
  node $L/ww45-builtins.mjs $wasm $L/probes > $L/builtins-$module.txt || exit 1
  node $L/ww45-builtins.mjs $wasm docs/audit/ww45-evidence/probes > $L/builtins-ww45-$module.txt || exit 1
  echo "$module: $(tail -1 $L/builtins-$module.txt); ww45 probes $(tail -1 $L/builtins-ww45-$module.txt)"
done
python3 -I - <<'PY'
import json, pathlib
L = pathlib.Path.home() / 'lanes/ww46'
for name in ('builtins', 'builtins-ww45'):
    rows = {}
    for module in ('live', 'control'):
        for line in (L / f'{name}-{module}.txt').read_text().splitlines():
            if line.endswith('.lu: DIED') or ': {' not in line: continue
            f, rec = line.split(': ', 1); r = json.loads(rec)
            rows.setdefault(f, {})[module] = (r['verdict'], r['phase'], r['exit'], r['unsupported'] or (r['detail'] or {}).get('message'))
    for f, m in sorted(rows.items()):
        same = 'same' if m['live'] == m['control'] else 'MOVES'
        print(f"{name} {f}: live {m['live'][0]}/{m['live'][1]}/{m['live'][2]} | 0.1.55 {m['control'][0]}/{m['control'][1]}/{m['control'][2]} [{same}] :: {m['control'][3]}")
PY
echo BUILTINS-DONE
