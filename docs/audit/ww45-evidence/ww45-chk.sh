#!/bin/bash
# ww45: ship the worktree's site/, scripts/, tests/ and CHANGELOG.md into kasumi's build clone and run the three prose audits there (no build). Adapted from ww44-chk.sh.
cd /Users/mfwolffe/GithubOrgs/wolffe-lang/wolf-web-ww45 || exit 1
COPYFILE_DISABLE=1 tar --no-xattrs -cf /Users/mfwolffe/lanes/ww45/wt.tar site scripts tests CHANGELOG.md && scp -q /Users/mfwolffe/lanes/ww45/wt.tar kasumi:lanes/ww45/wt.tar || exit 1
ssh kasumi bash -s <<'EOS'
cd ~/lanes/ww45/web && tar -xf ../wt.tar && git submodule update --init --recursive -q || exit 1
echo "kasumi HEAD $(git rev-parse --short HEAD) + worktree files"
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse --short HEAD)"; done
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
EOS
