# ww46: the published lupin 0.1.55 at a terminal (stdin /dev/null, no tty) over every phase:run program under corpus/os/,
# corpus/fs/ and corpus/conc/ at wolf-lang v0.2.34, plus the named stragglers, each held to its own header's
# `check: run(exit=…, stdout=…)` where the header carries one. Every program runs from a scratch copy of the corpus,
# plus the five programs /install/ and /play/ name as declined the same way at a terminal, its path relative to the corpus root (the fs programs open their fixtures that way), and net/ and time/ join the set.
# The net programs bind 127.0.0.1:0 only; they run in a second pass (`terminal.sh net`) in a namespace with its own
# network, loopback up, mapped as root there so `ip` may raise it (with --map-current-user the shell keeps no
# capability across exec, and a first pass with loopback down answered every net program `io`). /install/ and /play/ say what this interpreter answers
# at a terminal for programs the tab declines; this is the measurement behind each such sentence at the new lupin pin.
# RULES.md §5: inside its own pid namespace (the os/ and conc/ programs spawn, signal and wait), RLIMIT_CORE 0.
L=~/lanes/ww46
MODE=${1:-host}
if [ -z "$WW46_IN_NS" ]; then
  if [ "$MODE" = net ]; then
    exec unshare --user --map-root-user --pid --fork --mount-proc --net env WW46_IN_NS=1 bash $L/terminal.sh net
  fi
  exec unshare --user --map-current-user --pid --fork --mount-proc env WW46_IN_NS=1 bash $L/terminal.sh host
fi
ulimit -c 0
if [ "$MODE" = net ]; then ip link set lo up && echo "net namespace: $(ip -brief addr show lo | tr -s ' ')" || exit 1; fi
echo "namespace: pid $$ procs $(ls -d /proc/[0-9]* | wc -l) uid $(id -u) core $(ulimit -c)/$(ulimit -Hc)"
grep -E '^Sig(Blk|Ign)' /proc/self/status
unset WOLF_STD LUPIN_STD
B=$L/pair/lupin-0.1.55-x86_64-unknown-linux-gnu/lupin; $B --version
C=$L/web/upstream/wolf-lang
test "$(git -C $C rev-parse HEAD)" = 9da7bdcf2aea9adf48df6570bedc58e16e9ef853 || { echo "corpus not at v0.2.34"; exit 1; }
T=$L/tmp-terminal; rm -rf "${L:?}/tmp-terminal"; mkdir -p $T
cp -r $C/corpus $T/corpus || exit 1
if [ "$MODE" = net ]; then grep -E '^corpus/net/' $L/run-9da7bdc.txt > $T/list
else (grep -E '^corpus/(os|fs|conc|time)/' $L/run-9da7bdc.txt; for x in grammar/cfg_target_arch memory/raw_repr_c_layout memory/raw_repr_packed_layout memory/raw_repr_align_layout membrane/extern_let_image membrane/extern_libc; do echo corpus/$x.lu; done) | sort -u > $T/list; fi
echo "programs: $(wc -l < $T/list)"
while read -r f; do
  e=$T/err; out=$( cd $T/corpus && timeout 60 $B run ${f#corpus/} < /dev/null 2>$e ); code=$?
  printf '%s\t%s\t%s\t%s\n' "$f" "$code" "$(printf '%s' "$out" | base64 -w0)" "$(head -c 300 $e | base64 -w0)"
done < $T/list > $L/terminal-raw-$MODE.tsv
python3 -I - "$C" "$L/terminal-raw-$MODE.tsv" <<'PY'
import re, sys, base64, pathlib, json
C = pathlib.Path(sys.argv[1]); rows = []
for line in pathlib.Path(sys.argv[2]).read_text().splitlines():
    f, code, out, err = line.split('\t'); out = base64.b64decode(out).decode('utf-8', 'replace'); err = base64.b64decode(err).decode('utf-8', 'replace')
    head = (C / f).read_text().splitlines()
    chk = next((h for h in head if h.startswith('//! check: run(')), None)
    want_exit = want_out = None
    if chk:
        m = re.search(r'exit=(-?\d+)', chk); want_exit = int(m.group(1)) if m else None
        m = re.search(r'stdout="((?:[^"\\]|\\.)*)"', chk)
        if m: want_out = json.loads('"' + m.group(1) + '"')
    if int(code) == 4: verdict = 'declined: ' + err.strip().split('\n')[-1][:160]
    elif want_exit is None: verdict = f'exit {code} (header names no exit)'
    elif int(code) == want_exit and (want_out is None or out.rstrip('\n') == want_out.rstrip('\n')): verdict = 'AS HEADER'
    else: verdict = f'DIFFERS: exit {code} want {want_exit}; stdout {out[:120]!r} want {str(want_out)[:120]!r}'
    rows.append((f, verdict))
for f, v in rows: print(f'{f}: {v}')
n = len(rows); a = sum(v == 'AS HEADER' for _, v in rows); dcl = sum(v.startswith('declined') for _, v in rows)
print(f'TERMINAL ({sys.argv[2].split("-")[-1][:-4]}): {n} programs, {a} as their headers say, {dcl} declined by name (exit 4), {n - a - dcl} other')
PY
rm -rf "${L:?}/tmp-terminal"
echo TERMINAL-DONE
