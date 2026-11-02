#!/usr/bin/env bash
# web-probes.sh : r41q's probes for /install/ and /play/ at wolf 0.2.36 / lupin 0.1.58.
# The probe set (probes/*.lu): ww46's eleven verbatim (the seven 0.2.34 calls one each and
# section 34.7's and 34.8's four programs, unchanged in wolf-book 64bb3c76), 0.2.35's thirteen
# prelude names one each, 0.2.36's env_arg0 and env_args_bytes, and wolf-interp's two
# variadic-call sources from tests/variadic_is81.rs; ww45's eleven verbatim as ww45-*.lu (the
# 0.2.33 calls one each and section 34.5's three and 34.6's two programs as wolf-book had them),
# ww42's, ww43's and ww44's verbatim likewise (ww42-*, ww43-*, ww44-*: the 0.2.29 to 0.2.32 calls
# one each and the book programs those lanes measured), and section 34.6's two programs as wolf-book 64bb3c76 has them (book-34.6-*.lu; 34.5's are
# unchanged there). Run under bin/block (R41Q_CPUS).
#   1. the tab: ww45-builtins.mjs through the live lupp.us module (0.1.56) and the 0.1.58 build
#   3. every program the census ran, through the 0.1.58 module, held to its header
#   2. a terminal: in a container (--init, its own pid table, no network), lupin 0.1.58 alone
#      and wolf 0.2.36 native (wolf run) over each probe in its own directory, stdin /dev/null
set -u
R=/home/mfwolffe/lanes/r41q
M=$R/web/measure
PR=$R/web/probes
NEW=$R/web/new
LUPIN=$R/archives/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin-0.1.58-x86_64-unknown-linux-gnu/lupin
WOLF=$R/archives/wolf-0.2.36-x86_64-unknown-linux-gnu/wolf-0.2.36-x86_64-unknown-linux-gnu
IMG=localhost/r41q-pack-ci:fbee7e864f7dbee6
CPUS=${R41Q_CPUS:?run under bin/block}
export PATH=$HOME/lanes/hasu-env/bin:$HOME/lanes/hasu-env/profile/bin:$PATH
# One run only: this job is queued on both blocks, and whichever takes its block first runs it;
# the other finds the claim (or the done mark) and exits at once.
if [ -e "$M/probes.done" ]; then echo "probes: already measured ($(cat "$M/probes.done")); nothing to do"; exit 0; fi
if ! mkdir "$M/probes.claim" 2>/dev/null; then echo "probes: another run holds the claim; nothing to do"; exit 0; fi
step() {
    local name=$1
    shift
    echo "== STEP $name $(date -u +%FT%TZ)"
    "$@"
    local rc=$?
    echo "END $name exit=$rc"
    return 0
}
tab() {
    sha256sum "$M/lupin-0.1.56-live.wasm" "$M/lupin-0.1.58-control.wasm" "$PR"/*.lu
    node "$R/bin/ww45-builtins.mjs" "$M/lupin-0.1.56-live.wasm" "$PR" > "$M/probes-tab-0.1.56-live.txt" || return 1
    node "$R/bin/ww45-builtins.mjs" "$M/lupin-0.1.58-control.wasm" "$PR" > "$M/probes-tab-0.1.58-control.txt" || return 1
    tail -1 "$M"/probes-tab-*.txt
}
terminal() {
    local T=$M/probes-terminal
    rm -rf "$T" && mkdir -p "$T/p" || return 1
    for f in "$PR"/*.lu; do b=$(basename "$f" .lu); mkdir -p "$T/p/$b" && cp "$f" "$T/p/$b/"; done
    cp "$LUPIN" "$T/lupin" && cp -r "$WOLF" "$T/wolf" || return 1
    cat > "$T/run.sh" <<'EOS'
#!/bin/bash
ulimit -c 0
unset WOLF_STD LUPIN_STD
echo "pid $$ procs $(ls -d /proc/[0-9]* | wc -l) core $(ulimit -c)"
grep -E '^Sig(Blk|Ign)' /proc/self/status
/t/lupin --version
/t/wolf/wolf --version
for d in /t/p/*/; do
  b=$(basename "$d")
  for tool in lupin wolf; do
    cd "$d" || exit 1
    if [ $tool = lupin ]; then out=$(timeout 60 /t/lupin run "$b.lu" < /dev/null 2>/t/err); code=$?
    else out=$(timeout 120 /t/wolf/wolf run "$b.lu" < /dev/null 2>/t/err); code=$?; fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$b" "$tool" "$code" "$(printf '%s' "$out" | base64 -w0)" "$(head -c 600 /t/err | base64 -w0)"
  done
done > /t/raw.tsv
EOS
    chmod +x "$T/run.sh"
    podman run --rm --init --memory 12g --network none -v "$T:/t" "$IMG" taskset -c "$CPUS" /t/run.sh || return 1
    python3 -I - "$T/raw.tsv" > "$M/probes-terminal.txt" <<'PY'
import sys, base64, pathlib
for line in pathlib.Path(sys.argv[1]).read_text().splitlines():
    b, tool, code, out, err = line.split('\t')
    out = base64.b64decode(out).decode('utf-8', 'replace').strip().replace('\n', ' | ')
    err = base64.b64decode(err).decode('utf-8', 'replace').strip().split('\n')
    print(f"{b} {tool}: exit {code} stdout [{out[:200]}] stderr-last [{err[-1][:260]}]")
PY
    wc -l < "$M/probes-terminal.txt"
}
arrivals() {
    # lupin 0.1.58 at a terminal over every phase:run program v0.2.35 and v0.2.36 added or moved to run
    # (git diff 9da7bdcf..5adf3d91 of corpus/), held to its header by the measure pass's reader
    local C=$NEW/upstream/wolf-lang T=$M/terminal-arrivals
    rm -rf "$T" && mkdir -p "$T" && cp -r "$C/corpus" "$T/corpus" || return 1
    (cd "$C" && git diff --name-only --diff-filter=AM 9da7bdcf 5adf3d91 -- corpus | grep '\.lu$' | while read -r f; do grep -qE '^//! phase: run' "$f" 2>/dev/null && echo "$f"; done) | sort -u > "$T/list"
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
    python3 -I - "$C" "$T/raw.tsv" > "$M/terminal-arrivals-0.1.58.txt" <<'PY'
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
    tail -1 "$M/terminal-arrivals-0.1.58.txt"
}
headers() {
    # every program the census ran, through the 0.1.58 module, held to its header (r41q's header-check.mjs)
    python3 -I -c "import json,sys; [print(r['file']) for r in json.load(open(sys.argv[1]))['rows']]" "$M/census-5adf3d9-control.json" > "$M/run-5adf3d9.txt" || return 1
    node "$R/bin/header-check.mjs" "$M/lupin-0.1.58-control.wasm" "$R/web/new/upstream/wolf-lang/corpus" $(cat "$M/run-5adf3d9.txt") > "$M/header-check-0.1.58.txt" || return 1
    tail -n 1 "$M/header-check-0.1.58.txt"
}
step tab tab
step terminal terminal
step headers headers
step arrivals arrivals
echo "$(date -u +%FT%TZ) on cpus $CPUS" > "$M/probes.done"
echo PROBES-DONE
