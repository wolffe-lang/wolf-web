import json, subprocess, pathlib, collections
L=pathlib.Path.home()/'lanes/ww46'; W=L/'web/upstream/wolf-lang'
old='85dab5d7e597680d6fd7034f1d7ed2acb9a92f97'; new='9da7bdcf2aea9adf48df6570bedc58e16e9ef853'
base=json.loads((L/'web/docs/audit/ww45-evidence/census-0233-control.json').read_text())
sets=[set((L/f'run-{r[:7]}.txt').read_text().splitlines()) for r in (old,new)]
assert sets[0]==sets[1]
assert {'corpus/'+r['file'] for r in base['rows']}==sets[0]
# No arrivals/departures; term_editor_rows only removes an output row behind a
# process-tier call already unsupported on wasm. 0.1.55 resolves older calls,
# but its wasm process-tier decline remains in front of every corpus use.
rows=[{k:r[k] for k in ('file','cls','verdict')} for r in base['rows']]
counts=collections.Counter(r['cls'] for r in rows)
print('Prediction before pins or new-module census:',len(rows),dict(counts))
print('Candidates',counts['exit']+counts['trap'],'fail',counts.get('fail',0))
print('Rule: carry baseline classes; same run set, one edit removing a row after an already declined call; interpreter wasm process-tier decline remains.')
print('Prediction across both corpora and both modules: zero class moves; reason words may move for the five names learned in 0.1.55.')
print('New seven probes: unsupported, resolve, exit 4, each name does not resolve. Menu: none newly refused.')
json.dump({'rows':rows},open(L/'census-0234-predicted.json','w'),indent=1)
