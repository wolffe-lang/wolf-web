# ww45: the staged browser gates on nomad-1 (adapted from ww44-gate-staged.sh): /play/ (ww45-play.mjs), then the book's
# changed pages under the CSP (ww45-book.mjs), the site's two-hop link walk with §34.6, §34.5 and §3.3 (ww45-links.mjs),
# and the book's contents gate (full) and --retry. The site is served by ww42-serve.mjs on 127.0.0.1:8754 (started
# beforehand, pid in ev/serve.pid) with nginx/lupp.us.conf's headers.
S=/Users/mfwolffe/lanes/ww45
export PLAYWRIGHT_MODULE=/Users/mfwolffe/.npm/_npx/e41f203b7505f1fb/node_modules/playwright-core
cp $S/k/ww45-book.mjs $S/wolf-book/tests/contents/ || exit 1
cd $S/wolf-book/tests/contents || exit 1
echo "# STAGED gates: kasumi's dist at ww45 $(cat $S/stage.head) (every book script ?v=3ac6fa9); the book served by wolf-book 3ac6fa9 tests/contents/serve.mjs under lupp.us's headers, --unversioned; contents.mjs sha256 $(shasum -a 256 contents.mjs | cut -c1-8)…; the site served by ww42-serve.mjs on 127.0.0.1:8754 (pid $(cat $S/ev/serve.pid)) with nginx/lupp.us.conf's headers; playwright-core 1.63.0, nomad-1"
echo "started $(date -u +%FT%TZ)"
node $S/k/ww45-play.mjs --base http://127.0.0.1:8754 --probes $S/ev/probes --json $S/ev/play-staged.json > $S/ev/play-staged.txt 2>&1; echo PLAY-EXIT=$?; tail -1 $S/ev/play-staged.txt
node $S/k/ww45-play-compare.mjs $S/ev/play-live-before.json $S/ev/play-staged.json > $S/ev/play-compare-staged.txt 2>&1; echo COMPARE-EXIT=$?; tail -1 $S/ev/play-compare-staged.txt
node ww45-book.mjs --root $S/stage/book > $S/ev/book-staged.txt 2>&1; echo BOOK-EXIT=$?; tail -1 $S/ev/book-staged.txt
node $S/k/ww45-links.mjs --base http://127.0.0.1:8754 --json $S/ev/links-staged.json > $S/ev/links-staged.txt 2>&1; echo LINKS-EXIT=$?; cat $S/ev/links-staged.txt
node contents.mjs --root $S/stage/book --unversioned --json $S/ev/gate-staged.json; echo GATE-EXIT=$?
node contents.mjs --retry --root $S/stage/book --unversioned --log $S/ev/retry-staged.log; echo RETRY-EXIT=$?
echo "retry log: $(wc -l < $S/ev/retry-staged.log) lines, $(grep -c 'HTTP 404' $S/ev/retry-staged.log) 'HTTP 404', $(grep -c ERROR $S/ev/retry-staged.log) ERROR"
echo "finished $(date -u +%FT%TZ)"
echo STAGED-DONE
