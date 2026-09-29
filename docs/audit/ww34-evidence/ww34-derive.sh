L=~/lanes/ww34
W=$L/web/upstream
OLD=02afce84f05c7841856a10671b6d7924f79193cc
NEW=ec56a08f04ff318ea659fd58683f7ae4f22dc7a5
SPEC=93a5fe504593ca7642b78ba83b4986e7a03cfe71
IOLD=54f85e694d4c03e5cd40bef461f85ca0ac373332
INEW=0cfc0cfc89af5fd2aeb71d46c86742745b902869
BOLD=f2f4280f3a06e49a2a8e76fb581a2666e480105d
BNEW=dadc38bee9eb8d5570cfe638bf9fb79bfe977ab0
echo "derive run $(date -u +%FT%TZ) on $(hostname)"
cd $W/wolf-lang
echo "=== tags"; for t in v0.2.16 v0.2.17 v0.2.18; do echo "$t $(git rev-parse $t^{commit})"; done
echo "=== ancestry"; git merge-base --is-ancestor $SPEC $NEW; echo "is-ancestor $SPEC $NEW exit=$?"
git merge-base --is-ancestor $OLD $NEW; echo "is-ancestor $OLD $NEW exit=$?"
echo "rev-list --count SPEC..NEW = $(git rev-list --count $SPEC..$NEW)"
echo "rev-list --count OLD..NEW = $(git rev-list --count $OLD..$NEW)"
echo "rev-list --count SPEC..OLD = $(git rev-list --count $SPEC..$OLD)"
echo "=== CHANGELOG headings at NEW"; git show $NEW:CHANGELOG.md | grep -E '^## [0-9]' | head -5
echo "=== interp gitlinks"; cd $W/wolf-interp
echo "IOLD upstream: $(git ls-tree $IOLD upstream)"; echo "INEW upstream: $(git ls-tree $INEW upstream)"
git show $INEW:Cargo.toml | grep -m1 '^version'
echo "interp commits IOLD..INEW = $(git rev-list --count $IOLD..$INEW)"
git log --oneline $IOLD..$INEW | head -60
echo "=== interp files changed"; git diff --stat $IOLD $INEW | tail -3
cd $W/wolf-lang
echo "=== counts OLD vs NEW"
for r in $OLD $NEW; do
  e=$(git show $r:docs/diagnostics.md | grep -cE '^## E'); w=$(git show $r:docs/warnings.md | grep -cE '^## W')
  n=$(git ls-tree -r --name-only $r corpus/net | grep -c '\.lu$')
  a=$(git show $r:spec/anchors.json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(len(d.get("anchors", d)))')
  echo "${r:0:8} E=$e W=$w net=$n anchors=$a"
done
python3 - <<PY
import json, subprocess
def anchors(rev):
    d=json.loads(subprocess.run(['git','show',f'{rev}:spec/anchors.json'],capture_output=True,text=True).stdout)
    a=d.get('anchors',d); return set(a.keys()) if isinstance(a,dict) else set(a)
o,n=anchors('$OLD'),anchors('$NEW')
print("anchors added",len(n-o),sorted(n-o)); print("anchors dropped",len(o-n),sorted(o-n))
PY
a=$(git show $OLD:spec/grammar.ebnf | sha256sum | cut -c1-16); b=$(git show $NEW:spec/grammar.ebnf | sha256sum | cut -c1-16); echo "grammar.ebnf $a -> $b"; [ "$a" = "$b" ] && echo BYTE-IDENTICAL || { echo DIFFERS; git diff $OLD $NEW -- spec/grammar.ebnf; }
echo "=== phase:run sets"
for r in $OLD $NEW; do git checkout -q $r || exit 1; grep -rlE '^//!\s*phase:\s*run\b' --include='*.lu' corpus | sort > $L/run-${r:0:7}.txt; done
git checkout -q $OLD
wc -l $L/run-*.txt
echo "--- in:"; comm -13 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt
echo "--- out:"; comm -23 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt
echo "=== corpus diff name-status"; git diff --name-status $OLD $NEW -- corpus
echo "--- pre-existing run programs modified:"; git diff --name-only --diff-filter=M $OLD $NEW -- corpus | grep -Fxf $L/run-${OLD:0:7}.txt
echo "=== spec/ docs/ stat"; git diff --stat $OLD $NEW -- spec/ docs/
echo "=== new run program headers"
for f in $(comm -13 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt); do echo "## $f"; git show $NEW:$f | grep -E '^//!' | head -20; done
echo "=== book"
cd $W/wolf-book
echo "count BOLD..BNEW = $(git rev-list --count $BOLD..$BNEW)"; git merge-base --is-ancestor $BOLD $BNEW; echo "book ancestry exit=$?"
git diff --stat $BOLD $BNEW | tail -1
git diff --name-only $BOLD $BNEW
echo "SUMMARY sha $(git rev-parse $BOLD:book/SUMMARY.md) -> $(git rev-parse $BNEW:book/SUMMARY.md)"
echo "chapters in SUMMARY: $(git show $BNEW:book/SUMMARY.md | grep -cE '\]\(ch[0-9]+\.md\)')"
git log --oneline $BOLD..$BNEW
echo DERIVE-DONE
