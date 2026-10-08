# ww39 input derivation (kasumi). Adapted from ww38-derive.sh: the pins move
# wolf 8edac3ee (v0.2.23) -> 6710f9e0 (v0.2.25), lupin f9269e33 (0.1.46) -> 531bf058 (0.1.48),
# book e7772338 (bs60) -> fde77b8d (bs63).
L=~/lanes/ww39
W=$L/web/upstream
OLD=8edac3eeb48632b32f02ef41ea87d484d1423492
NEW=6710f9e0cbc3a7264349093751ce7a46a407e473
SPEC_OLD=8e36bc1a0f92bbbbc6861b10d5b2638f76412d6a
IOLD=f9269e3364169585fdfe92407639418220be373b
INEW=531bf0581dea6bba4b1247edb2abada5214c18ab
BOLD=e777233842830279c44933df830843d5ee218873
BNEW=fde77b8d28c720206415c9e508c859f6753dd1d4
echo "derive run $(date -u +%FT%TZ) on $(hostname)"
cd $W/wolf-lang || exit 1
echo "=== tags"; for t in v0.2.23 v0.2.24 v0.2.25; do echo "$t $(git rev-parse $t^{commit})"; done
echo "=== interp gitlinks"; cd $W/wolf-interp || exit 1
echo "IOLD upstream: $(git ls-tree $IOLD upstream)"; echo "INEW upstream: $(git ls-tree $INEW upstream)"
SPEC_NEW=$(git ls-tree $INEW upstream | awk '{print $3}')
git show $INEW:Cargo.toml | grep -m1 '^version'
echo "tag v0.1.48 -> $(git rev-parse v0.1.48^{commit})"
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
for v in 0.2.25 0.2.24; do echo "=== CHANGELOG $v entry"; git show $NEW:CHANGELOG.md | awk -v h="^## $v " '$0~h{p=1;print;next} /^## /{if(p)exit} p'; done
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

echo "=== chapter 7 at BNEW"
cd $W/wolf-book
git diff --stat $BOLD $BNEW -- book/ch07.md book/ch07 2>&1 | tail -3
git ls-tree -r --name-only $BNEW | grep -iE 'ch07|diagram|svg|trace' | head -40
git show $BNEW:book/ch07.md | grep -nE '!\[|<img|<svg|\.svg|<object|<embed|<script' | head -40
echo "=== book.toml at BNEW"; git show $BNEW:book.toml 2>&1 | head -60
echo "=== inline scripts or event handlers in book sources at BNEW"
git grep -nE '<script|onclick=|onload=|javascript:' $BNEW -- book theme 2>&1 | head -20; echo "(end)"
echo "=== kept lupin pins at NEW naming wolf-interp issues"
cd $W/wolf-lang
git grep -nE "0\.1\.4[6-8]" $NEW -- 'crates/*/tests/*lanes*.rs' 'crates/wolf_driver/PAIRING' 2>&1 | head -60
git show $NEW:crates/wolf_driver/PAIRING 2>&1 | head
echo "=== diagnostics E1308 E1309 at NEW"; git show $NEW:docs/diagnostics.md | grep -nE '^## E130[0-9]' 
echo "=== site programs vs 0.2.24/0.2.25 surface"
cd $L/web; grep -rnE 'copy region|extern "c" let|Order\.|atomic' site/ | head; echo "(end site grep)"
cd $W/wolf-lang; git checkout -q $OLD || exit 1
echo DERIVE-DONE
