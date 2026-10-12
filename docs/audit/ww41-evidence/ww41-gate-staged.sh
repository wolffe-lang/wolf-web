# ww41: the book's contents gate (full) and --retry, STAGED on nomad-1 (adapted from ww40-gate-staged.sh)
S=/Users/mfwolffe/lanes/ww41
cd $S/wolf-book/tests/contents || exit 1
export PLAYWRIGHT_MODULE=/Users/mfwolffe/.npm/_npx/e41f203b7505f1fb/node_modules/playwright-core
echo "# contents gate (full) and --retry, STAGED: kasumi's dist/book at ww41 1845f18 (every script ?v=b845e07) served by wolf-book b845e07 tests/contents/serve.mjs under lupp.us's headers, --unversioned; contents.mjs sha256 $(shasum -a 256 contents.mjs | cut -c1-8)…, playwright-core 1.63.0, nomad-1"
echo "started $(date -u +%FT%TZ)"
node contents.mjs --root $S/stage/book --unversioned --json $S/ev/gate-staged.json; echo GATE-EXIT=$?
node contents.mjs --retry --root $S/stage/book --unversioned --log $S/ev/retry-staged.log; echo RETRY-EXIT=$?
echo "retry log: $(wc -l < $S/ev/retry-staged.log) lines, $(grep -c 'HTTP 404' $S/ev/retry-staged.log) 'HTTP 404', $(grep -c ERROR $S/ev/retry-staged.log) ERROR"
echo "finished $(date -u +%FT%TZ)"
echo STAGED-DONE
