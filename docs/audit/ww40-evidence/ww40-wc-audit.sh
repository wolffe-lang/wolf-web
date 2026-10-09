# ww40: the three prose audits over the working copy synced from nomad-1 (no fetch, no checkout)
cd ~/lanes/ww40/web || exit 1
test "$(git branch --show-current)" = ww40 || exit 1
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
