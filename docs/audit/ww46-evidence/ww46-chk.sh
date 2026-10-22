#!/bin/bash
# ww46: ship the worktree's site/, scripts/, tests/ and CHANGELOG.md into kasumi's build clone and run the prose audits
# and the node suites there (no build on nomad-1). Adapted from ww45-chk.sh.
cd /Users/mfwolffe/lanes/ww46/wolf-web || exit 1
COPYFILE_DISABLE=1 tar --no-xattrs -cf /Users/mfwolffe/lanes/ww46/wt.tar site scripts tests CHANGELOG.md && scp -q /Users/mfwolffe/lanes/ww46/wt.tar kasumi:lanes/ww46/wt.tar || exit 1
ssh kasumi bash -s <<'EOS'
cd ~/lanes/ww46/web && tar -xf ../wt.tar && git submodule update --init --recursive -q || exit 1
echo "kasumi HEAD $(git rev-parse --short HEAD) + worktree files"
for m in wolf-book wolf-interp wolf-lang; do echo "$m $(git -C upstream/$m rev-parse --short HEAD)"; done
python3 scripts/check-lag-phrases.py site upstream/wolf-lang upstream/wolf-interp; echo LAG-EXIT=$?
python3 scripts/check-version-prose.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp; echo VP-EXIT=$?
python3 scripts/check-counts.py --also CHANGELOG.md site upstream/wolf-lang upstream/wolf-interp upstream/wolf-book; echo CC-EXIT=$?
node --test tests/*.test.mjs > ../chk-node.log 2>&1; echo NODE-EXIT=$?; grep -E "^ℹ (tests|pass|fail|skipped)" ../chk-node.log; grep -E "^not ok|^    not ok" ../chk-node.log | head -20
EOS
