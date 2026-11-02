#!/usr/bin/env bash
# web-walk.sh : r41q's second walk (ww46's shape) at 5adf3d91: every program the census ran,
# through the live lupp.us module (lupin 0.1.56) and the 0.1.58 build, by ww45-stdout-all.mjs
# (verdict and stdout) and ww46-reasons.mjs (also phase, exit and the unsupported reason); and
# declines.mjs: every decline's reason, under 0.1.58 at 5adf3d91 and under the live module at cf0c13d.
set -u
R=/home/mfwolffe/lanes/r41q
M=$R/web/measure
NEW=$R/web/new
export PATH=$HOME/lanes/hasu-env/bin:$HOME/lanes/hasu-env/profile/bin:$PATH
step() {
    local name=$1
    shift
    echo "== STEP $name $(date -u +%FT%TZ)"
    "$@"
    local rc=$?
    echo "END $name exit=$rc"
    return 0
}
list() {
    python3 -I -c "import json,sys; [print(r['file']) for r in json.load(open(sys.argv[1]))['rows']]" "$M/census-5adf3d9-control.json" > "$M/run-5adf3d9.txt" || return 1
    wc -l < "$M/run-5adf3d9.txt"
}
walk() {
    node "$NEW/docs/audit/ww45-evidence/ww45-stdout-all.mjs" "$M/lupin-0.1.56-live.wasm" "$M/lupin-0.1.58-control.wasm" "$NEW/upstream/wolf-lang/corpus" $(cat "$M/run-5adf3d9.txt") > "$M/stdout-all.txt" || return 1
    tail -1 "$M/stdout-all.txt"
}
reasons() {
    node "$NEW/docs/audit/ww46-evidence/ww46-reasons.mjs" "$M/lupin-0.1.56-live.wasm" "$M/lupin-0.1.58-control.wasm" "$NEW/upstream/wolf-lang/corpus" $(cat "$M/run-5adf3d9.txt") > "$M/reasons-all.txt" || return 1
    tail -1 "$M/reasons-all.txt"
}
declines() {
    node "$R/bin/declines.mjs" "$M/lupin-0.1.58-control.wasm" "$NEW/upstream/wolf-lang/corpus" $(cat "$M/run-5adf3d9.txt") > "$M/declines-0.1.58-control.txt" || return 1
    node "$R/bin/declines.mjs" "$M/lupin-0.1.56-live.wasm" "$R/web/old/upstream/wolf-lang/corpus" $(python3 -I -c "import json,sys; [print(r['file']) for r in json.load(open(sys.argv[1]))['rows']]" "$M/census-cf0c13d-live.json") > "$M/declines-0.1.56-live-cf0c13d.txt" || return 1
    tail -1 "$M"/declines-*.txt
}
step list list
step declines declines
step walk walk
step reasons reasons
echo WALK-DONE
