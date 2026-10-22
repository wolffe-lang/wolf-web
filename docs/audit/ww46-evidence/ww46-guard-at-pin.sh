# ww46: the lag guard and the prose audits at the last pin commit 15e9fac (all three gitlinks moved, no page yet
# rewritten), from that commit's own site/ and scripts/ (git archive), against the pinned checkouts. Expected: the guard
# exits naming the gap no page has; the version and count audits red on the clocked lines.
L=~/lanes/ww46; W=$L/web; D=$L/at-pin; rm -rf "${L:?}/at-pin"; mkdir -p $D
git -C $W archive 15e9fac82dcd49072459a9734b2e48f65d7f9579 site scripts CHANGELOG.md | tar -x -C $D || exit 1
echo "tree 15e9fac; pins: $(git -C $W ls-tree 15e9fac upstream/ | awk '{print $4"="substr($3,1,8)}' | tr '\n' ' ')"
for m in wolf-lang wolf-interp wolf-book; do echo "$m checkout $(git -C $W/upstream/$m rev-parse --short=8 HEAD)"; done
cd $D || exit 1
python3 scripts/check-lag-phrases.py site $W/upstream/wolf-lang $W/upstream/wolf-interp; echo "LAG-EXIT=$?"
python3 scripts/check-version-prose.py --also CHANGELOG.md site $W/upstream/wolf-lang $W/upstream/wolf-interp > vp.txt 2>&1; echo "VP-EXIT=$? ($(grep -c 'was audited at' vp.txt) clocked lines red)"
python3 scripts/check-counts.py --also CHANGELOG.md site $W/upstream/wolf-lang $W/upstream/wolf-interp $W/upstream/wolf-book > cc.txt 2>&1; echo "CC-EXIT=$?"; cat cc.txt | head -5
python3 -I -c "import runpy; w=runpy.run_path('scripts/stamp-counts.py')['word']
try: print(w(1067))
except ValueError as e: print('word(1067) at 15e9fac:', e)"
cd $L && rm -rf "${L:?}/at-pin"; echo GUARD-AT-PIN-DONE
