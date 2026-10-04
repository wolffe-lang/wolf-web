# ww38's input derivation (kasumi). Adapted from ww37-derive.sh: the pins move
# wolf 8e36bc1a (v0.2.22) -> 8edac3ee (v0.2.23), lupin 9f4e4a17 (0.1.45) -> f9269e33 (0.1.46),
# book f1d894ec (bs59) -> e7772338 (bs60).
L=~/lanes/ww38
W=$L/web/upstream
OLD=8e36bc1a0f92bbbbc6861b10d5b2638f76412d6a
NEW=8edac3eeb48632b32f02ef41ea87d484d1423492
SPEC_OLD=dfcc2f13e7c73182bdd41fc9bec2802c7da3b024
IOLD=9f4e4a175da109bc4dc0acec3e8a4bc54358b941
INEW=f9269e3364169585fdfe92407639418220be373b
BOLD=f1d894ec0fe8a2d861d292657f2c0963417df975
BNEW=e777233842830279c44933df830843d5ee218873
echo "derive run $(date -u +%FT%TZ) on $(hostname)"
cd $W/wolf-lang || exit 1
echo "=== tags"; for t in v0.2.21 v0.2.22 v0.2.23; do echo "$t $(git rev-parse $t^{commit})"; done
echo "=== interp gitlinks"; cd $W/wolf-interp || exit 1
echo "IOLD upstream: $(git ls-tree $IOLD upstream)"; echo "INEW upstream: $(git ls-tree $INEW upstream)"
SPEC_NEW=$(git ls-tree $INEW upstream | awk '{print $3}')
git show $INEW:Cargo.toml | grep -m1 '^version'
echo "tag v0.1.46 -> $(git rev-parse v0.1.46^{commit})"
echo "interp commits IOLD..INEW = $(git rev-list --count $IOLD..$INEW)"
git log --oneline $IOLD..$INEW | head -80
echo "=== interp files changed"; git diff --stat $IOLD $INEW | tail -3
cd $W/wolf-lang
echo "=== ancestry"
git merge-base --is-ancestor $SPEC_NEW $NEW; echo "is-ancestor SPEC_NEW(${SPEC_NEW:0:8}) NEW exit=$?"
git merge-base --is-ancestor $OLD $NEW; echo "is-ancestor OLD NEW exit=$?"
echo "rev-list --count SPEC_NEW..NEW = $(git rev-list --count $SPEC_NEW..$NEW)"
echo "rev-list --count OLD..NEW = $(git rev-list --count $OLD..$NEW)"
echo "rev-list --count SPEC_OLD..OLD = $(git rev-list --count $SPEC_OLD..$OLD)"
echo "=== CHANGELOG headings at NEW"; git show $NEW:CHANGELOG.md | grep -E '^## [0-9]' | head -5
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
git checkout -q $OLD || exit 1
wc -l $L/run-*.txt
echo "--- in:"; comm -13 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt
echo "--- out:"; comm -23 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt
echo "=== corpus diff name-status"; git diff --name-status $OLD $NEW -- corpus
echo "--- pre-existing run programs modified:"; git diff --name-only --diff-filter=M $OLD $NEW -- corpus | grep -Fxf $L/run-${OLD:0:7}.txt
echo "=== spec/ docs/ stat"; git diff --stat $OLD $NEW -- spec/ docs/
echo "=== new run program headers"
for f in $(comm -13 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt); do echo "## $f"; git show $NEW:$f | grep -E '^//!' | head -20; done
echo "=== modified run program diffs"
for f in $(git diff --name-only --diff-filter=M $OLD $NEW -- corpus | grep -Fxf $L/run-${OLD:0:7}.txt); do git diff $OLD $NEW -- $f; done
for v in 0.2.23 0.2.22; do echo "=== CHANGELOG $v entry"; git show $NEW:CHANGELOG.md | awk -v h="^## $v " '$0~h{p=1;print;next} /^## /{if(p)exit} p'; done
echo "=== pairing pins at NEW naming wolf-interp issues"; git grep -nE "wolf-interp#1[0-9][0-9]" $NEW -- '*.toml' '*.json' '*pairing*' | head -20
echo "=== lupin CHANGELOG heads"; git -C $W/wolf-interp show $INEW:CHANGELOG.md | grep -E "^## " | head -4
echo "=== book"
cd $W/wolf-book
echo "count BOLD..BNEW = $(git rev-list --count $BOLD..$BNEW)"; git merge-base --is-ancestor $BOLD $BNEW; echo "book ancestry exit=$?"
git diff --stat $BOLD $BNEW | tail -1
git diff --name-only $BOLD $BNEW
echo "SUMMARY sha $(git rev-parse $BOLD:book/SUMMARY.md) -> $(git rev-parse $BNEW:book/SUMMARY.md)"
echo "chapters in SUMMARY: $(git show $BNEW:book/SUMMARY.md | grep -cE '\]\(ch[0-9]+\.md\)')"
git log --oneline $BOLD..$BNEW

echo "=== site programs defining size_of/align_of/offset_of (W0304 under the 0.2.23 prelude)"
cd $L/web; grep -rnE 'fn (size_of|align_of|offset_of)\b' site/ | head; git -C $W/wolf-book grep -nE 'fn (size_of|align_of|offset_of)\b' $BNEW | head; echo "(end grep)"
echo "=== module-level triple-quoted strings (wolf-lang#585) in site programs and run corpus"
grep -rlE '^(pub )?(let|const) [A-Za-z_]+[^=]*= *"""' site/ | head; git -C $W/wolf-book grep -lE '^(pub )?(let|const) [A-Za-z_]+[^=]*= *"""' $BNEW | head; echo "(end site/book grep)"
cd $W/wolf-lang; git checkout -q $NEW || exit 1
grep -lE '^(pub )?(let|const) [A-Za-z_]+[^=]*= *"""' $(cat $L/run-${NEW:0:7}.txt) 2>&1 | head; echo "(end corpus grep)"
git checkout -q $OLD || exit 1
echo DERIVE-DONE
