# ww44 input derivation (kasumi). Adapted from ww42-derive.sh: the pins move
# wolf 1b37f368 (v0.2.30) -> 72de141f (v0.2.32; the site skips 0.2.31), lupin 7896eddc (0.1.53) -> 0e536e8 (0.1.54),
# book 95d68ad0 (bs67) -> e9862f6a (bs68). Adapted from ww43-derive.sh.
L=~/lanes/ww44
W=$L/web/upstream
OLD=1b37f368228db92eca505c8c4cd3c531ea60be48
IOLD=7896eddc17fd9e3e015b025b354ccf62a766734b
BOLD=95d68ad0e4f77ad714abb165915c29d6ac90a892
BNEW=e9862f6abe6374a759645aa53b52bc7e38603ebd
echo "derive run $(date -u +%FT%TZ) on $(hostname)"
cd $W/wolf-lang || exit 1
git fetch -q --tags origin || exit 1
NEW=$(git rev-parse v0.2.32^{commit}) || exit 1
git -C $W/wolf-interp fetch -q --tags origin || exit 1
INEW=$(git -C $W/wolf-interp rev-parse v0.1.54^{commit}) || exit 1
echo "NEW $NEW INEW $INEW"
test -n "$NEW" -a -n "$INEW" || exit 1
echo "=== tags"; for t in v0.2.24 v0.2.25 v0.2.26 v0.2.27 v0.2.28 v0.2.29 v0.2.30 v0.2.31 v0.2.32; do echo "$t $(git rev-parse $t^{commit})"; done
echo "trunk $(git rev-parse origin/trunk)"
echo "=== interp gitlinks"; cd $W/wolf-interp || exit 1
git fetch -q --tags origin || exit 1
for r in $IOLD $INEW; do echo "$r upstream: $(git ls-tree $r upstream)"; done
SPEC_OLD=$(git ls-tree $IOLD upstream | awk '{print $3}')
SPEC_NEW=$(git ls-tree $INEW upstream | awk '{print $3}')
git show $INEW:Cargo.toml | grep -m1 '^version'
echo "tag v0.1.53 -> $(git rev-parse v0.1.53^{commit}); tag v0.1.54 -> $(git rev-parse v0.1.54^{commit})"
echo "interp commits IOLD..INEW = $(git rev-list --count $IOLD..$INEW)"
git log --oneline $IOLD..$INEW | head -200
echo "=== interp files changed"; git diff --stat $IOLD $INEW | tail -3
echo "=== interp wasm-relevant files changed"; git diff --stat $IOLD $INEW -- '*wasm*' 'src/eval/mod.rs' | tail -5
echo "=== lupin CHANGELOG 0.1.54 entry"; git show $INEW:CHANGELOG.md | awk '/^## /{n++} n==1' | head -400
cd $W/wolf-lang
echo "=== spec pins: SPEC_OLD $SPEC_OLD SPEC_NEW $SPEC_NEW"
for t in v0.2.22 v0.2.23 v0.2.24 v0.2.25 v0.2.26 v0.2.27 v0.2.28 v0.2.29 v0.2.30 v0.2.31 v0.2.32; do [ "$(git rev-parse $t^{commit})" = "$SPEC_NEW" ] && echo "SPEC_NEW is $t"; done
echo "=== ancestry"
git merge-base --is-ancestor $SPEC_NEW $NEW; echo "is-ancestor SPEC_NEW(${SPEC_NEW:0:8}) NEW exit=$?"
git merge-base --is-ancestor $OLD $NEW; echo "is-ancestor OLD NEW exit=$?"
echo "rev-list --count SPEC_NEW..NEW = $(git rev-list --count $SPEC_NEW..$NEW)"
echo "rev-list --count SPEC_OLD..OLD = $(git rev-list --count $SPEC_OLD..$OLD)"
echo "rev-list --count OLD..NEW = $(git rev-list --count $OLD..$NEW)"
echo "rev-list --count v0.2.30..v0.2.31 = $(git rev-list --count v0.2.30..v0.2.31)"; echo "rev-list --count v0.2.31..v0.2.32 = $(git rev-list --count v0.2.31..v0.2.32)"
echo "=== CHANGELOG headings at NEW"; git show $NEW:CHANGELOG.md | grep -E '^## [0-9]' | head -9
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
echo "=== platforms.md / README / workflows OLD..NEW"; git diff --stat $OLD $NEW -- docs/platforms.md README.md .github/workflows/release.yml .github/workflows/ci.yml
echo "=== platforms.md diff"; git diff $OLD $NEW -- docs/platforms.md
echo "=== release.yml run gate at NEW (arm lines)"; git show $NEW:.github/workflows/release.yml | grep -nE 'arm|aarch64|refuses|checked tier|native tier|release tier' | head -40
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
echo "=== CHANGELOG 0.2.32 and 0.2.31 entries"; git show $NEW:CHANGELOG.md | awk '/^## [0-9]/{n++} n<=2'
echo "=== PAIRING at NEW"; git show $NEW:crates/wolf_driver/PAIRING 2>&1 | head
echo "=== STD-PIN at NEW"; git show $NEW:crates/wolf_driver/STD-PIN 2>&1 | head
echo "=== book"
cd $W/wolf-book || exit 1
git fetch -q origin || exit 1
echo "book trunk $(git rev-parse origin/trunk)"
echo "count BOLD..BNEW = $(git rev-list --count $BOLD..$BNEW)"; git merge-base --is-ancestor $BOLD $BNEW; echo "book ancestry exit=$?"
git diff --stat $BOLD $BNEW | tail -1
git diff --stat $BOLD $BNEW -- book/ theme/ xtask/ book.toml | tail -40
echo "SUMMARY sha $(git rev-parse $BOLD:book/SUMMARY.md) -> $(git rev-parse $BNEW:book/SUMMARY.md)"
echo "chapters in SUMMARY: $(git show $BNEW:book/SUMMARY.md | grep -cE '\]\(ch[0-9]+\.md\)')"
echo "=== book diagrams changed"; git diff --stat $BOLD $BNEW -- book/diagrams | tail -3
echo "=== ch34 at BNEW"; git show $BNEW:book/ch34.md | grep -nE "^## |^# " ; git show $BNEW:book/SUMMARY.md | grep -nE "ch3[2-5]"; echo "=== chapters with new headings BOLD..BNEW"; for f in $(git diff --name-only $BOLD $BNEW -- book/); do diff <(git show $BOLD:$f 2>/dev/null | grep -E "^#+ ") <(git show $BNEW:$f | grep -E "^#+ ") | sed "s|^|$f |"; done
echo "=== ch01 Windows block at BNEW"; git show $BNEW:book/ch01.md | grep -nE 'windows-msvc|wolf-0\.2\.' | head
echo "=== inline scripts or event handlers in book sources at BNEW"
git grep -nE '<script|onclick=|onload=|javascript:' $BNEW -- book theme 2>&1 | head -20; echo "(end)"
echo "=== book render path: external commands"; git grep -n 'Command::new' $BNEW -- xtask/src/render.rs xtask/src/highlight.rs
echo "=== site grep"
cd $L/web; grep -rnE 'aarch64|windows-msvc|0\.2\.30|0\.1\.53' site/ | grep -v '^site/docs/api' | cut -c1-220 | head -40; echo "(end site grep)"
echo "=== 0.2.31's seven new hosted builtins in lupin at INEW"
cd $W/wolf-interp; git grep -nE 'os_signal_send_group|os_signal_send_all|os_set_pgid|os_signal_last|os_signal_realtime|os_signal_text|os_wait_poll' $INEW -- src | cut -c1-260 | head -80
echo "=== and at IOLD (expect none)"; git grep -cE 'os_signal_send_group|os_signal_send_all|os_set_pgid|os_signal_last|os_signal_realtime|os_signal_text|os_wait_poll' $IOLD -- src; echo "(end)"
echo "=== wasm cfg gates near them"; git grep -nE 'target_arch = "wasm32"|target_family = "wasm"' $INEW -- src | wc -l
echo "=== book CI std staging step at BNEW"
cd $W/wolf-book; git grep -nE 'std/|STD-REV|ab2576df|1f7389b7|manifest|sha256' $BNEW -- .github/workflows | cut -c1-240 | head -90
echo "=== book pins at BNEW"; git show $BNEW:book.toml 2>/dev/null | grep -nE 'wolf|lupin|rev|std' | head -20; git grep -nE '0\.2\.32|0\.1\.54|d37c911|72de141|0e536e8' $BNEW -- '*.toml' '*.json' '*.txt' '*.yml' | cut -c1-220 | head -40
echo "=== book file diff BOLD..BNEW"; git diff --stat $BOLD $BNEW | cat
echo "=== book/ prose diff"; git diff $BOLD $BNEW -- book/ | head -400
echo "=== std trunk wrappers (process.poll, group wrappers) and 0.2.31 names on the site (must not be shown as available)"
cd $L/web; grep -rnE 'os_signal_send_group|os_signal_send_all|os_set_pgid|os_signal_last|os_signal_realtime|os_signal_text|os_wait_poll|process\.poll|signal\.send_group|type\.int\.shift|exit 71' site/ | grep -v '^site/docs/api' | cut -c1-220 | head -40; echo "(end)"
cd $W/wolf-lang; git checkout -q $OLD || exit 1
echo "=== lupin wasm declines for the seven"; cd $W/wolf-interp; git grep -nE "target_family = \"wasm\"|target_arch = \"wasm32\"" $INEW -- src/eval/builtin.rs | head -20
echo DERIVE-DONE
