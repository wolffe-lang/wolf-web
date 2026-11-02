#!/usr/bin/env bash
# web-net.sh : r41q's terminal pass over corpus/net (ww46's terminal-net shape), lupin 0.1.58 alone in a
# container with no network but its own loopback; the same verdict reader as web-measure.sh's terminal pass.
# Run under bin/block (R41Q_CPUS); every step prints END. The container prints its interfaces and
# signal masks first.
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
# One run only: this job is queued on both blocks, and whichever takes its block first runs it;
# the other finds the claim (or the done mark) and exits at once.
if [ -e "$M/net.done" ]; then echo "net: already measured ($(cat "$M/net.done")); nothing to do"; exit 0; fi
if ! mkdir "$M/net.claim" 2>/dev/null; then echo "net: another run holds the claim; nothing to do"; exit 0; fi
step() {
    local name=$1
    shift
    echo "== STEP $name $(date -u +%FT%TZ)"
    "$@"
    local rc=$?
    echo "END $name exit=$rc"
    return 0
}
net() {
    local C=$NEW/upstream/wolf-lang T=$M/terminal-net
    rm -rf "$T" && mkdir -p "$T" && cp -r "$C/corpus" "$T/corpus" || return 1
    (cd "$C" && grep -rlE '^//! phase: run' corpus/net) | sort -u > "$T/list"
    echo "programs: $(wc -l < "$T/list")"
    cp "$LUPIN" "$T/lupin"
    cat > "$T/run.sh" <<'EOS'
#!/bin/bash
ulimit -c 0
cd /t/corpus
ip -br addr 2>/dev/null || cat /proc/net/if_inet6; grep -E "^Sig(Blk|Ign)" /proc/self/status
/t/lupin --version
while read -r f; do
  out=$(timeout 60 /t/lupin run "${f#corpus/}" < /dev/null 2>/t/err); code=$?
  printf '%s\t%s\t%s\t%s\n' "$f" "$code" "$(printf '%s' "$out" | base64 -w0)" "$(head -c 300 /t/err | base64 -w0)"
done < /t/list > /t/raw.tsv
EOS
    chmod +x "$T/run.sh"
    podman run --rm --init --memory 12g --network none -v "$T:/t" "$IMG" taskset -c "$CPUS" /t/run.sh || return 1
    python3 -I - "$C" "$T/raw.tsv" > "$M/terminal-net-0.1.58.txt" <<'PY'
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
    tail -1 "$M/terminal-net-0.1.58.txt"
}
step net net
echo "$(date -u +%FT%TZ) on cpus $CPUS" > "$M/net.done"
echo "R41Q_WEB_NET_DONE $(date -u +%FT%TZ)"
