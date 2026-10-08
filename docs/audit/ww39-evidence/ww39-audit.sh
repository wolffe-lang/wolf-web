# ww39: the three prose audits at origin/ww39's head (kasumi), no build.
cd ~/lanes/ww39/web || exit 1
git fetch -q origin ww39 || exit 1
git checkout -q -B ww39 origin/ww39 || exit 1
test "$(git branch --show-current)" = ww39 || exit 1
git submodule update --init --recursive -q || exit 1
echo "HEAD $(git rev-parse --short HEAD)"
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
