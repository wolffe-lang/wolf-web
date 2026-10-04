# ww37: the three prose audits at origin/ww37's head (kasumi), no build.
cd ~/lanes/ww37/web || exit 1
git fetch -q origin ww37 || exit 1
git checkout -q -B ww37 origin/ww37 || exit 1
test "$(git branch --show-current)" = ww37 || exit 1
git submodule update --init --recursive -q || exit 1
echo "HEAD $(git rev-parse --short HEAD)"
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
