# ww46 note (added when the evidence landed): copied unchanged below this note. Its first probe pass wrote two
# malformed probes (`List[int]::new()`, `List[byte]::new()`, no wolf spelling: E0201 at parse); those two were fixed
# and every builtins file re-measured by ww46-builtins.sh, which overwrote builtins-*.txt.
set -eu
L=$HOME/lanes/ww46
cd "$L/web"
cp docs/audit/ww33-evidence/census.mjs docs/audit/ww45-evidence/ww45-stdout-all.mjs docs/audit/ww45-evidence/ww45-builtins.mjs "$L/"
curl -fsS https://lupp.us/play/lupin.wasm -o "$L/lupin-0.1.54-live.wasm"
sha256sum "$L"/*.wasm
mkdir -p "$L/probes"
python3 -I - <<'PY'
from pathlib import Path
import re
L=Path.home()/'lanes/ww46'
calls={'os_fork':'os_fork()?','os_term_restore_at_exit':'os_term_restore_at_exit(-1, -1, List[byte]::new())?','os_signal_wait_fds':'os_signal_wait_fds(List[int]::new(), 0, -1)?','fs_sync':'fs_sync(-1)?','fs_sync_dir':'fs_sync_dir("")?','fs_realpath':'fs_realpath("")?','os_clock_ns':'os_clock_ns()'}
for name,call in calls.items(): (L/'probes'/f'{name}.lu').write_text(f'fn main() -> !int {{\n    {call}\n    0\n}}\n')
text=(L/'web/upstream/wolf-book/book/ch34.md').read_text()
for sec,label in [('34.7','fork'),('34.8','editor')]:
    part=text.split('## '+sec+' ',1)[1].split('\n## ',1)[0]
    for i,source in enumerate(re.findall(r'```wolf[^\n]*\n(.*?)\n```',part,re.S)):
        (L/'probes'/f'ch34-{label}-{i}.lu').write_text(source+'\n')
PY
for rev in 85dab5d7 9da7bdcf; do
 git -C upstream/wolf-lang checkout -q "$rev"
 for module in live control; do
   if [ "$module" = live ]; then wasm="$L/lupin-0.1.54-live.wasm"; else wasm="$L/lupin-0.1.55-control.wasm"; fi
   node "$L/census.mjs" "$wasm" upstream/wolf-lang/corpus "$L/census-$rev-$module.json" > "$L/leg-$rev-$module.txt" 2>&1
   echo "CENSUS $rev $module finished $(date -u +%FT%TZ)"
 done
done
for module in live control; do
 if [ "$module" = live ]; then wasm="$L/lupin-0.1.54-live.wasm"; else wasm="$L/lupin-0.1.55-control.wasm"; fi
 node "$L/ww45-builtins.mjs" "$wasm" "$L/probes" > "$L/builtins-$module.txt"
 node "$L/ww45-builtins.mjs" "$wasm" docs/audit/ww45-evidence/probes > "$L/builtins-ww45-$module.txt"
done
node "$L/ww45-stdout-all.mjs" "$L/lupin-0.1.54-live.wasm" "$L/lupin-0.1.55-control.wasm" upstream/wolf-lang/corpus $(sed 's|^corpus/||' "$L/run-9da7bdc.txt") > "$L/stdout-all.txt"
python3 -I - <<'PY'
from pathlib import Path
import json,collections
L=Path.home()/'lanes/ww46'
base=json.loads((L/'census-0234-predicted.json').read_text())['rows']
for p in sorted(L.glob('census-*-*.json')):
 d=json.loads(p.read_text()); print(p.name,d.get('summary',{}))
 if 'summary' in d:
  expected={r['file']:r['cls'] for r in base}; got={r['file']:r['cls'] for r in d['rows']}
  moves=[(k,expected.get(k),v) for k,v in got.items() if expected.get(k)!=v]
  print('class moves vs prediction',moves); assert not moves
PY
echo MEASURE-DONE
