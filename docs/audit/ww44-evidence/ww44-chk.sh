#!/bin/bash
# ww44: ship the worktree's site/, scripts/, tests/ and CHANGELOG.md into kasumi's build clone and run the three prose audits there (no build).
cd ~/lanes/ww44/wolf-web || exit 1
COPYFILE_DISABLE=1 tar --no-xattrs -cf ~/lanes/ww44/wt.tar site scripts tests CHANGELOG.md && scp -q ~/lanes/ww44/wt.tar kasumi:lanes/ww44/wt.tar || exit 1
ssh kasumi bash -s <<'EOS'
cd ~/lanes/ww44/web && tar -xf ../wt.tar 2>/dev/null || exit 1
echo "kasumi HEAD $(git rev-parse --short HEAD) + worktree files"
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse --short HEAD)"; done
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
EOS
