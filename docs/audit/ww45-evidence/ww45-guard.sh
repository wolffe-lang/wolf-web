# ww45: the lag guard and the prose audits at a named commit of origin/ww45 (kasumi), no build. Adapted from ww44-guard.sh.
# usage: bash ww45-guard.sh <sha>
S=$1
cd ~/lanes/ww45/web || exit 1
git fetch -q origin ww45 || exit 1
git checkout -q -- . && git checkout -q -B ww45 $S || exit 1
test "$(git branch --show-current)" = ww45 || exit 1
git submodule update --init --recursive -q || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
echo "HEAD $(git rev-parse --short HEAD)"
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse --short HEAD)"; done
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
python3 scripts/check-lag-phrases.py --json site upstream/wolf-lang upstream/wolf-interp; echo
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp > ~/lanes/ww45/vp.txt 2>&1; echo VP-EXIT=$?; echo "version-prose lines: $(wc -l < ~/lanes/ww45/vp.txt)"; head -5 ~/lanes/ww45/vp.txt
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
