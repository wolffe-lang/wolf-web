# ww44: every staged checker on a planted copy of the same dist (stage-plant, served on 127.0.0.1:8745): an inline
# script on the front page and /play/, /play/'s §34.5 link removed, ch34's id="34.5" renamed, one ch07 SVG removed,
# ch01's archive name set back to 0.2.30, ch03's wrapping[u8] program's type changed, the menu's last entry removed,
# and hello.lu replaced by the os_wait_poll probe. Each checker must exit non-zero.
S=/Users/mfwolffe/lanes/ww44
export PLAYWRIGHT_MODULE=/Users/mfwolffe/.npm/_npx/e41f203b7505f1fb/node_modules/playwright-core
cd $S/wolf-book/tests/contents || exit 1
echo "started $(date -u +%FT%TZ)"
node ww44-book.mjs --root $S/stage-plant/book > $S/ev/book-plant.txt 2>&1; echo "PLANT-BOOK-EXIT=$?"; grep -c FAIL $S/ev/book-plant.txt
node $S/ev/ww44-play.mjs --base http://127.0.0.1:8745 --probes $S/ev/probes --json $S/ev/play-plant.json > $S/ev/play-plant.txt 2>&1; echo "PLANT-PLAY-EXIT=$?"; grep -c FAIL $S/ev/play-plant.txt
node $S/ev/ww44-play-compare.mjs $S/ev/play-live-before.json $S/ev/play-plant.json > $S/ev/play-compare-plant.txt 2>&1; echo "PLANT-COMPARE-EXIT=$?"; tail -1 $S/ev/play-compare-plant.txt
node $S/ev/ww44-links.mjs --base http://127.0.0.1:8745 --json $S/ev/links-plant.json > $S/ev/links-plant.txt 2>&1; echo "PLANT-LINKS-EXIT=$?"; grep -c FAIL $S/ev/links-plant.txt
echo "finished $(date -u +%FT%TZ)"; echo PLANT-DONE
