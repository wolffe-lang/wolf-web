# ww43: the staged browser gates on nomad-1 (adapted from ww42-gate-staged.sh): the book's contents gate (full) and
# --retry, the book's CSP check, and the site's two-hop link walk; /play/ is ww43-play.mjs, run beside this.
S=/Users/mfwolffe/lanes/ww43
export PLAYWRIGHT_MODULE=/Users/mfwolffe/.npm/_npx/e41f203b7505f1fb/node_modules/playwright-core
cd $S/wolf-book/tests/contents || exit 1
echo "# STAGED gates: kasumi's dist at ww43 0254e28 (every book script ?v=95d68ad); the book served by wolf-book 95d68ad tests/contents/serve.mjs under lupp.us's headers, --unversioned; contents.mjs sha256 $(shasum -a 256 contents.mjs | cut -c1-8)…; the site served by ww43-serve.mjs on 127.0.0.1:8743 (pid $(cat $S/ev/serve.pid)) with nginx/lupp.us.conf's headers; playwright-core 1.63.0, nomad-1"
echo "started $(date -u +%FT%TZ)"
node ww43-book.mjs --root $S/stage/book > $S/ev/book-staged.txt 2>&1; echo BOOK-EXIT=$?; tail -1 $S/ev/book-staged.txt
node $S/ev/ww43-links.mjs --base http://127.0.0.1:8743 --json $S/ev/links-staged.json > $S/ev/links-staged.txt 2>&1; echo LINKS-EXIT=$?; cat $S/ev/links-staged.txt
node contents.mjs --root $S/stage/book --unversioned --json $S/ev/gate-staged.json; echo GATE-EXIT=$?
node contents.mjs --retry --root $S/stage/book --unversioned --log $S/ev/retry-staged.log; echo RETRY-EXIT=$?
echo "retry log: $(wc -l < $S/ev/retry-staged.log) lines, $(grep -c 'HTTP 404' $S/ev/retry-staged.log) 'HTTP 404', $(grep -c ERROR $S/ev/retry-staged.log) ERROR"
echo "finished $(date -u +%FT%TZ)"
echo STAGED-DONE
