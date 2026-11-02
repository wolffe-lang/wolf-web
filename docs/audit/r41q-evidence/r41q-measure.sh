#!/usr/bin/env bash
# web-measure.sh : r41q's measurement for wolf-web at wolf 0.2.36 / lupin 0.1.58
# (ww46's shape). Run under bin/block (R41Q_CPUS); every step prints END.
#   1. lupin 0.1.58 compiled to wasm by the site's own scripts/build-wasm.sh
#   2. the live module from lupp.us (lupin 0.1.56)
#   3. census.mjs (ww33's) over the corpus: live at cf0c13d (what the page says
#      today), live and control at 5adf3d91 (what moves)
#   4. lupin 0.1.58 at a terminal, in a container (--init, its own pid table),
#      over every phase:run program under os/ fs/ conc/ time/, the eight
#      programs 0.2.36 added and the programs /install/ and /play/ name
set -u
R=/home/mfwolffe/lanes/r41q
W=$R/web
M=$W/measure
NEW=$W/new
OLD=$W/old
LUPIN=$R/archives/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin
IMG=localhost/r41q-pack-ci:fbee7e864f7dbee6
CPUS=${R41Q_CPUS:?run under bin/block}
export PATH=$HOME/lanes/hasu-env/bin:$HOME/lanes/hasu-env/profile/bin:$PATH
export CARGO_HOME=$W/cargo
mkdir -p "$M"
step() {
    local name=$1
    shift
    echo "== STEP $name $(date -u +%FT%TZ)"
    "$@"
    local rc=$?
    echo "END $name exit=$rc"
    return 0
}
wasm() {
    (cd "$NEW" && ./scripts/build-wasm.sh) > "$M/build-wasm.log" 2>&1 || { tail -20 "$M/build-wasm.log"; return 1; }
    cp "$NEW/dist/play/lupin.wasm" "$M/lupin-0.1.58-control.wasm" && tail -6 "$M/build-wasm.log" && sha256sum "$M/lupin-0.1.58-control.wasm"
}
live() { curl -fsS https://lupp.us/play/lupin.wasm -o "$M/lupin-0.1.56-live.wasm" && sha256sum "$M/lupin-0.1.56-live.wasm"; }
census() {
    local c=$NEW/docs/audit/ww33-evidence/census.mjs
    node "$c" "$M/lupin-0.1.56-live.wasm" "$OLD/upstream/wolf-lang/corpus" "$M/census-cf0c13d-live.json" > "$M/census-cf0c13d-live.txt" 2>&1 || return 1
    node "$c" "$M/lupin-0.1.56-live.wasm" "$NEW/upstream/wolf-lang/corpus" "$M/census-5adf3d9-live.json" > "$M/census-5adf3d9-live.txt" 2>&1 || return 1
    node "$c" "$M/lupin-0.1.58-control.wasm" "$NEW/upstream/wolf-lang/corpus" "$M/census-5adf3d9-control.json" > "$M/census-5adf3d9-control.txt" 2>&1 || return 1
    tail -3 "$M"/census-*.txt
}
terminal() {
    local C=$NEW/upstream/wolf-lang T=$M/terminal
    rm -rf "$T" && mkdir -p "$T" && cp -r "$C/corpus" "$T/corpus" || return 1
    (cd "$C" && grep -rlE '^//! phase: run' corpus/os corpus/fs corpus/conc corpus/time;
     for x in memory/read_lend_frame memory/read_lend_value_semantics rows/else_fallback_bound_slice rows/else_fallback_paren_slice \
              grammar/cfg_target_arch memory/raw_repr_c_layout memory/raw_repr_packed_layout memory/raw_repr_align_layout \
              membrane/extern_let_image membrane/extern_libc membrane/variadic_declarations membrane/variadic_position \
              rows/else_fallback_range_refused; do echo corpus/$x.lu; done) | sort -u > "$T/list"
    echo "programs: $(wc -l < "$T/list")"
    cp "$LUPIN" "$T/lupin"
    cat > "$T/run.sh" <<'EOS'
#!/bin/bash
ulimit -c 0
cd /t/corpus
/t/lupin --version
while read -r f; do
  out=$(timeout 60 /t/lupin run "${f#corpus/}" < /dev/null 2>/t/err); code=$?
  printf '%s\t%s\t%s\t%s\n' "$f" "$code" "$(printf '%s' "$out" | base64 -w0)" "$(head -c 300 /t/err | base64 -w0)"
done < /t/list > /t/raw.tsv
EOS
    chmod +x "$T/run.sh"
    podman run --rm --init --memory 12g --network none -v "$T:/t" "$IMG" taskset -c "$CPUS" /t/run.sh || return 1
    python3 -I - "$C" "$T/raw.tsv" > "$M/terminal-0.1.58.txt" <<'PY'
import re, sys, base64, pathlib, json
C = pathlib.Path(sys.argv[1]); rows = []
for line in pathlib.Path(sys.argv[2]).read_text().splitlines():
    f, code, out, err = line.split('\t'); out = base64.b64decode(out).decode('utf-8', 'replace'); err = base64.b64decode(err).decode('utf-8', 'replace')
    head = (C / f).read_text().splitlines()
    chk = next((h for h in head if h.startswith('//! check: ')), '')
    want_exit = want_out = None
    if chk.startswith('//! check: run('):
        m = re.search(r'exit=(-?\d+)', chk); want_exit = int(m.group(1)) if m else None
        m = re.search(r'stdout="((?:[^"\\]|\\.)*)"', chk)
        if m: want_out = json.loads('"' + m.group(1) + '"')
    last = (err.strip().split('\n') or [''])[-1][:200]
    if int(code) == 4: verdict = 'declined: ' + last
    elif want_exit is None: verdict = f'exit {code} ({chk[4:] or "no check line"}) {last}'
    elif int(code) == want_exit and (want_out is None or out.rstrip('\n') == want_out.rstrip('\n')): verdict = 'AS HEADER'
    else: verdict = f'DIFFERS: exit {code} want {want_exit}; stdout {out[:120]!r} want {str(want_out)[:120]!r}; {last}'
    rows.append((f, verdict))
for f, v in rows: print(f'{f}: {v}')
n = len(rows); a = sum(v == 'AS HEADER' for _, v in rows); dcl = sum(v.startswith('declined') for _, v in rows)
print(f'TERMINAL: {n} programs, {a} as their headers say, {dcl} declined by name (exit 4), {n - a - dcl} other')
PY
    tail -1 "$M/terminal-0.1.58.txt"
}
echo "r41q web measure start $(date -u +%FT%TZ) cpus $CPUS"
step wasm wasm
step live live
step census census
step terminal terminal
echo "R41Q_WEB_MEASURE_DONE $(date -u +%FT%TZ)"
