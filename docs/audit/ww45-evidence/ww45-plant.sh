# ww45: every staged checker on the planted copy (stage-plant, served on 127.0.0.1:8755). Each must exit non-zero.
# Adapted from ww44-plant.sh.
S=/Users/mfwolffe/lanes/ww45
export PLAYWRIGHT_MODULE=/Users/mfwolffe/.npm/_npx/e41f203b7505f1fb/node_modules/playwright-core
cd $S/wolf-book/tests/contents || exit 1
echo "started $(date -u +%FT%TZ)"
node ww45-book.mjs --root $S/stage-plant/book > $S/ev/book-plant.txt 2>&1; echo "PLANT-BOOK-EXIT=$?"; grep -c FAIL $S/ev/book-plant.txt
node $S/k/ww45-play.mjs --base http://127.0.0.1:8755 --probes $S/ev/probes --json $S/ev/play-plant.json > $S/ev/play-plant.txt 2>&1; echo "PLANT-PLAY-EXIT=$?"; grep -c FAIL $S/ev/play-plant.txt
node $S/k/ww45-play-compare.mjs $S/ev/play-live-before.json $S/ev/play-plant.json > $S/ev/play-compare-plant.txt 2>&1; echo "PLANT-COMPARE-EXIT=$?"; tail -1 $S/ev/play-compare-plant.txt
node $S/k/ww45-links.mjs --base http://127.0.0.1:8755 --json $S/ev/links-plant.json > $S/ev/links-plant.txt 2>&1; echo "PLANT-LINKS-EXIT=$?"; grep -c FAIL $S/ev/links-plant.txt
echo "finished $(date -u +%FT%TZ)"; echo PLANT-DONE
