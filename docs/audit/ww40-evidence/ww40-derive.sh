# ww40 input derivation (kasumi). Adapted from ww39-derive.sh: the pins move
# wolf 6710f9e0 (v0.2.25) -> 89dc1394 (v0.2.26), lupin 531bf058 (0.1.48) -> f516a5f4 (0.1.49),
# book fde77b8d (bs63) -> 2504a0fc (bs64).
L=~/lanes/ww40
W=$L/web/upstream
OLD=6710f9e0cbc3a7264349093751ce7a46a407e473
NEW=89dc139443da38078df6093568da87bc6d0ee6f9
IOLD=531bf0581dea6bba4b1247edb2abada5214c18ab
INEW=f516a5f4ea4341acd3a30f3e5cdd4327aede1912
BOLD=fde77b8d28c720206415c9e508c859f6753dd1d4
BNEW=2504a0fcef5a36422c8704c734912b0a23d12962
echo "derive run $(date -u +%FT%TZ) on $(hostname)"
cd $W/wolf-lang || exit 1
git fetch -q --tags origin || exit 1
echo "=== tags"; for t in v0.2.24 v0.2.25 v0.2.26; do echo "$t $(git rev-parse $t^{commit})"; done
echo "trunk $(git rev-parse origin/trunk)"
echo "=== interp gitlinks"; cd $W/wolf-interp || exit 1
git fetch -q --tags origin || exit 1
echo "IOLD upstream: $(git ls-tree $IOLD upstream)"; echo "INEW upstream: $(git ls-tree $INEW upstream)"
SPEC_OLD=$(git ls-tree $IOLD upstream | awk '{print $3}')
SPEC_NEW=$(git ls-tree $INEW upstream | awk '{print $3}')
git show $INEW:Cargo.toml | grep -m1 '^version'
echo "tag v0.1.49 -> $(git rev-parse v0.1.49^{commit})"
echo "interp commits IOLD..INEW = $(git rev-list --count $IOLD..$INEW)"
git log --oneline $IOLD..$INEW | head -120
echo "=== interp files changed"; git diff --stat $IOLD $INEW | tail -3
echo "=== lupin CHANGELOG 0.1.49 entry"; git show $INEW:CHANGELOG.md | awk '/^## /{n++} n==1' | head -200
cd $W/wolf-lang
echo "=== spec pins: SPEC_OLD $SPEC_OLD SPEC_NEW $SPEC_NEW"
for t in v0.2.22 v0.2.23 v0.2.24 v0.2.25 v0.2.26; do [ "$(git rev-parse $t^{commit})" = "$SPEC_NEW" ] && echo "SPEC_NEW is $t"; done
echo "=== ancestry"
git merge-base --is-ancestor $SPEC_NEW $NEW; echo "is-ancestor SPEC_NEW(${SPEC_NEW:0:8}) NEW exit=$?"
git merge-base --is-ancestor $OLD $NEW; echo "is-ancestor OLD NEW exit=$?"
echo "rev-list --count SPEC_NEW..NEW = $(git rev-list --count $SPEC_NEW..$NEW)"
echo "rev-list --count SPEC_OLD..NEW = $(git rev-list --count $SPEC_OLD..$NEW)"
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
echo "=== diagnostics added"; diff <(git show $OLD:docs/diagnostics.md | grep -E '^## [EW]') <(git show $NEW:docs/diagnostics.md | grep -E '^## [EW]')
echo "=== warnings added"; diff <(git show $OLD:docs/warnings.md | grep -E '^## W') <(git show $NEW:docs/warnings.md | grep -E '^## W')
a=$(git show $OLD:spec/grammar.ebnf | sha256sum | cut -c1-16); b=$(git show $NEW:spec/grammar.ebnf | sha256sum | cut -c1-16); echo "grammar.ebnf $a -> $b"; [ "$a" = "$b" ] && echo BYTE-IDENTICAL || { echo DIFFERS; git diff $OLD $NEW -- spec/grammar.ebnf; }
echo "=== platforms.md OLD..NEW"; git diff --stat $OLD $NEW -- docs/platforms.md README.md .github/workflows/release.yml .github/workflows/ci.yml
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
echo "=== CHANGELOG 0.2.26 entry"; git show $NEW:CHANGELOG.md | awk '/^## 0\.2\.26 /{p=1;print;next} /^## /{if(p)exit} p'
echo "=== PAIRING at NEW"; git show $NEW:crates/wolf_driver/PAIRING 2>&1 | head
echo "=== kept lupin pins at NEW (0.1.4x literals in lane gates)"
git grep -nE "0\.1\.4[6-9]" $NEW -- 'crates/*/tests/*lanes*.rs' 2>&1 | head -60
echo "=== book"
cd $W/wolf-book || exit 1
git fetch -q origin || exit 1
echo "book trunk $(git rev-parse origin/trunk)"
echo "count BOLD..BNEW = $(git rev-list --count $BOLD..$BNEW)"; git merge-base --is-ancestor $BOLD $BNEW; echo "book ancestry exit=$?"
git diff --stat $BOLD $BNEW | tail -1
git diff --name-only $BOLD $BNEW
echo "SUMMARY sha $(git rev-parse $BOLD:book/SUMMARY.md) -> $(git rev-parse $BNEW:book/SUMMARY.md)"
echo "chapters in SUMMARY: $(git show $BNEW:book/SUMMARY.md | grep -cE '\]\(ch[0-9]+\.md\)')"
git log --oneline $BOLD..$BNEW
echo "=== book.toml at BNEW (pins)"; git show $BNEW:book.toml 2>&1 | grep -nE 'wolf|lupin|rev|version' | head -20
echo "=== new surfaces in book sources at BNEW"
git grep -nE 'copy region|-> never|![a-z_]*\b.*int|\bnever\b' $BNEW -- 'book/ch02.md' 'book/ch06.md' 'book/ch08.md' | head -40
echo "=== book diff ch02 ch06 ch08 stat"; git diff --stat $BOLD $BNEW -- book/ | tail -20
echo "=== inline scripts or event handlers in book sources at BNEW"
git grep -nE '<script|onclick=|onload=|javascript:' $BNEW -- book theme 2>&1 | head -20; echo "(end)"
echo "=== new memory fences / diagrams"; git ls-tree -r --name-only $BNEW | grep -iE 'diagram|svg' | head -40
echo "=== site programs vs 0.2.26 surface"
cd $L/web; grep -rnE 'copy region|-> never|aarch64' site/ | grep -v '^site/docs/api' | cut -c1-200 | head -20; echo "(end site grep)"
cd $W/wolf-lang; git checkout -q $OLD || exit 1
echo DERIVE-DONE
