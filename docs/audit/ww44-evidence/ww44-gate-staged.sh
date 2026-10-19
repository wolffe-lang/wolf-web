# ww44: the staged browser gates on nomad-1 (adapted from ww43-gate-staged.sh): /play/ (ww44-play.mjs), then the book's
# changed pages under the CSP (ww44-book.mjs), the site's two-hop link walk with §34.5 and §3.3 (ww44-links.mjs), and the
# book's contents gate (full) and --retry.
S=/Users/mfwolffe/lanes/ww44
export PLAYWRIGHT_MODULE=/Users/mfwolffe/.npm/_npx/e41f203b7505f1fb/node_modules/playwright-core
cp $S/ev/ww44-book.mjs $S/wolf-book/tests/contents/ || exit 1
cd $S/wolf-book/tests/contents || exit 1
echo "# STAGED gates: kasumi's dist at ww44 d40b64b (every book script ?v=e9862f6); the book served by wolf-book e9862f6 tests/contents/serve.mjs under lupp.us's headers, --unversioned; contents.mjs sha256 $(shasum -a 256 contents.mjs | cut -c1-8)…; the site served by ww42-serve.mjs on 127.0.0.1:8744 (pid $(cat $S/ev/serve.pid)) with nginx/lupp.us.conf's headers; playwright-core 1.63.0, nomad-1"
echo "started $(date -u +%FT%TZ)"
node $S/ev/ww44-play.mjs --base http://127.0.0.1:8744 --probes $S/ev/probes --json $S/ev/play-staged.json > $S/ev/play-staged.txt 2>&1; echo PLAY-EXIT=$?; tail -1 $S/ev/play-staged.txt
node $S/ev/ww44-play-compare.mjs $S/ev/play-live-before.json $S/ev/play-staged.json > $S/ev/play-compare-staged.txt 2>&1; echo COMPARE-EXIT=$?; tail -1 $S/ev/play-compare-staged.txt
node ww44-book.mjs --root $S/stage/book > $S/ev/book-staged.txt 2>&1; echo BOOK-EXIT=$?; tail -1 $S/ev/book-staged.txt
node $S/ev/ww44-links.mjs --base http://127.0.0.1:8744 --json $S/ev/links-staged.json > $S/ev/links-staged.txt 2>&1; echo LINKS-EXIT=$?; cat $S/ev/links-staged.txt
node contents.mjs --root $S/stage/book --unversioned --json $S/ev/gate-staged.json; echo GATE-EXIT=$?
node contents.mjs --retry --root $S/stage/book --unversioned --log $S/ev/retry-staged.log; echo RETRY-EXIT=$?
echo "retry log: $(wc -l < $S/ev/retry-staged.log) lines, $(grep -c 'HTTP 404' $S/ev/retry-staged.log) 'HTTP 404', $(grep -c ERROR $S/ev/retry-staged.log) ERROR"
echo "finished $(date -u +%FT%TZ)"
echo STAGED-DONE
