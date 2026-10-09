# ww40: the lag guard and the prose audits at a named commit of origin/ww40 (kasumi), no build.
# usage: bash ww40-guard.sh <sha> <out>
S=$1
cd ~/lanes/ww40/web || exit 1
git fetch -q origin ww40 || exit 1
git checkout -q -- . && git checkout -q -B ww40 $S || exit 1
test "$(git branch --show-current)" = ww40 || exit 1
git submodule update --init --recursive -q || exit 1
git -C upstream/wolf-lang fetch -q --tags origin || exit 1
echo "HEAD $(git rev-parse --short HEAD)"
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse --short HEAD)"; done
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
python3 scripts/check-lag-phrases.py --json site upstream/wolf-lang upstream/wolf-interp; echo
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
