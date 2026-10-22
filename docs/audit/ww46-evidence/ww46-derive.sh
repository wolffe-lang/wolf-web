# ww46 note (added when the evidence landed): this is the script that ran on kasumi at 2026-10-22T01:11Z, copied
# unchanged below this note. Its first three comment lines were carried from ww45's and are wrong for ww46: the lupin
# pin DOES move (0e536e8 -> e642f26, the script's own line 4 of derive.log says so), the old wolf pin is 85dab5d7
# (v0.2.33) and the book moves to bs70's f1fd824. FIVE names 0.2.33's calls, not 0.2.34's seven; the seven are held
# absent from lupin e642f26 by builtins-*.txt and native-0234.txt. Its tag list skips v0.2.33 (the gap is counted by
# the guard, which reads the CHANGELOG).
# ww46 input derivation (kasumi). Adapted from ww44-derive.sh: the pins move
# wolf 72de141f (v0.2.32) -> 85dab5d7 (v0.2.34), lupin 0e536e8 (0.1.54) -> 0e536e8 (0.1.54, unchanged: r38 kept the pairing),
# book e9862f6a (bs68) -> f1fd8244 (bs69).
L=~/lanes/ww46
W=$L/web/upstream
OLD=85dab5d7e597680d6fd7034f1d7ed2acb9a92f97
IOLD=0e536e8fb4518eaa798ac426901ab81275db5c9f
BOLD=3ac6fa944da048cc24814ec3f500f8d51765034d
BNEW=f1fd824
FIVE='os_signal_ignore_one|os_signal_default_one|os_exit_signal|os_wait_status_core|os_wait_poll_core'
echo "derive run $(date -u +%FT%TZ) on $(hostname)"
cd $W/wolf-lang || exit 1
git fetch -q --tags origin || exit 1
NEW=$(git rev-parse v0.2.34^{commit}) || exit 1
echo "NEW (twice) $NEW $(git rev-parse refs/tags/v0.2.34^{commit}); tag object $(git rev-parse refs/tags/v0.2.34) type $(git cat-file -t refs/tags/v0.2.34)"
git -C $W/wolf-interp fetch -q --tags origin || exit 1
INEW=$(git -C $W/wolf-interp rev-parse v0.1.55^{commit}) || exit 1
echo "NEW $NEW INEW $INEW (IOLD $IOLD)"; [ "$INEW" = "$IOLD" ] && echo "LUPIN PIN UNCHANGED" || echo "LUPIN PIN MOVES"
echo "=== tags"; for t in v0.2.24 v0.2.25 v0.2.26 v0.2.27 v0.2.28 v0.2.29 v0.2.30 v0.2.31 v0.2.32 v0.2.34; do echo "$t $(git rev-parse $t^{commit})"; done
echo "trunk $(git rev-parse origin/trunk)"
echo "=== interp"; cd $W/wolf-interp || exit 1
echo "interp trunk $(git rev-parse origin/trunk); tags containing the pin: $(git tag --contains $INEW | tr '\n' ' ')"
echo "$INEW upstream: $(git ls-tree $INEW upstream)"
SPEC=$(git ls-tree $INEW upstream | awk '{print $3}')
git show $INEW:Cargo.toml | grep -m1 '^version'
echo "=== interp: the five names at the pin (expect none)"; git grep -cE "$FIVE" $INEW -- src; echo "(end)"
echo "=== interp: os_signal_text at the pin"; git grep -nE 'os_signal_text' $INEW -- src/eval/builtin.rs | cut -c1-220 | head
cd $W/wolf-lang
echo "=== spec pin: SPEC $SPEC"
for t in v0.2.22 v0.2.23 v0.2.24 v0.2.25 v0.2.34; do [ "$(git rev-parse $t^{commit})" = "$SPEC" ] && echo "SPEC is $t"; done
echo "=== ancestry"
git merge-base --is-ancestor $SPEC $NEW; echo "is-ancestor SPEC(${SPEC:0:8}) NEW exit=$?"
git merge-base --is-ancestor $OLD $NEW; echo "is-ancestor OLD NEW exit=$?"
echo "rev-list --count SPEC..NEW = $(git rev-list --count $SPEC..$NEW)"
echo "rev-list --count SPEC..OLD = $(git rev-list --count $SPEC..$OLD)"
echo "rev-list --count OLD..NEW = $(git rev-list --count $OLD..$NEW)"
echo "=== CHANGELOG headings at NEW"; git show $NEW:CHANGELOG.md | grep -E '^## [0-9]' | head -11
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
echo "=== diagnostics diff"; diff <(git show $OLD:docs/diagnostics.md | grep -E '^## [EW]') <(git show $NEW:docs/diagnostics.md | grep -E '^## [EW]')
echo "=== warnings diff"; diff <(git show $OLD:docs/warnings.md | grep -E '^## W') <(git show $NEW:docs/warnings.md | grep -E '^## W')
a=$(git show $OLD:spec/grammar.ebnf | sha256sum | cut -c1-16); b=$(git show $NEW:spec/grammar.ebnf | sha256sum | cut -c1-16); echo "grammar.ebnf $a -> $b"; [ "$a" = "$b" ] && echo BYTE-IDENTICAL || { echo DIFFERS; git diff $OLD $NEW -- spec/grammar.ebnf; }
echo "=== platforms.md / README / workflows OLD..NEW"; git diff --stat $OLD $NEW -- docs/platforms.md README.md .github/workflows/release.yml .github/workflows/ci.yml | cat
echo "=== platforms.md diff"; git diff $OLD $NEW -- docs/platforms.md
echo "=== phase:run sets"
for r in $OLD $NEW; do git checkout -q $r || exit 1; grep -rlE '^//!\s*phase:\s*run\b' --include='*.lu' corpus | sort > $L/run-${r:0:7}.txt; done
git checkout -q $OLD || exit 1
wc -l $L/run-*.txt
echo "--- in:"; comm -13 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt
echo "--- out:"; comm -23 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt
echo "=== corpus diff name-status"; git diff --name-status $OLD $NEW -- corpus
echo "--- pre-existing run programs modified:"; git diff --name-only --diff-filter=M $OLD $NEW -- corpus | grep -Fxf $L/run-${OLD:0:7}.txt
echo "=== spec/ docs/ demo/ stat"; git diff --stat $OLD $NEW -- spec/ docs/ demo/ | cat
echo "=== new run program headers"
for f in $(comm -13 $L/run-${OLD:0:7}.txt $L/run-${NEW:0:7}.txt); do echo "## $f"; git show $NEW:$f | grep -E '^//!' | head -24; done
echo "=== modified run program diffs"
for f in $(git diff --name-only --diff-filter=M $OLD $NEW -- corpus | grep -Fxf $L/run-${OLD:0:7}.txt); do git diff $OLD $NEW -- $f; done
echo "=== PAIRING at NEW"; git show $NEW:crates/wolf_driver/PAIRING 2>&1 | head
echo "=== STD-PIN at OLD and NEW"; git show $OLD:crates/wolf_driver/STD-PIN 2>&1 | grep -v '^#' | head -4; git show $NEW:crates/wolf_driver/STD-PIN 2>&1 | grep -v '^#' | head -4
echo "=== spec 03 [conc.task.order] at NEW (ww44 found it stale)"; git show $NEW:spec/03-concurrency.md | grep -nE 'futex|polls' | head -8
echo "=== book"
cd $W/wolf-book || exit 1
git fetch -q origin || exit 1
echo "book trunk $(git rev-parse origin/trunk); BNEW twice $(git rev-parse $BNEW^{commit}) $(git rev-parse f1fd824^{commit})"
echo "count BOLD..BNEW = $(git rev-list --count $BOLD..$BNEW)"; git merge-base --is-ancestor $BOLD $BNEW; echo "book ancestry exit=$?"
git diff --stat $BOLD $BNEW | tail -1
git diff --stat $BOLD $BNEW -- book/ theme/ xtask/ book.toml wolf-toolchain.toml .github | cat
echo "SUMMARY sha $(git rev-parse $BOLD:book/SUMMARY.md) -> $(git rev-parse $BNEW:book/SUMMARY.md)"
echo "chapters in SUMMARY: $(git show $BNEW:book/SUMMARY.md | grep -cE '\]\(ch[0-9]+\.md\)')"
echo "=== book diagrams changed"; git diff --stat $BOLD $BNEW -- book/diagrams | tail -3
echo "=== ch34 headings at BNEW"; git show $BNEW:book/ch34.md | grep -nE "^## |^# |^### "
echo "=== chapters with new headings BOLD..BNEW"; for f in $(git diff --name-only $BOLD $BNEW -- book/); do diff <(git show $BOLD:$f 2>/dev/null | grep -E "^#+ ") <(git show $BNEW:$f | grep -E "^#+ ") | sed "s|^|$f |"; done
echo "=== ch01 Windows block at BNEW"; git show $BNEW:book/ch01.md | grep -nE 'windows-msvc|wolf-0\.2\.3' | head
echo "=== ch22 toolchain line at BNEW"; git show $BNEW:book/ch22.md | grep -nE 'toolchain 0\.2|0\.2\.3[0-9]' | head
echo "=== colophon distance at BNEW"; git show $BNEW:book/back/colophon.md | grep -nE 'commits|releases|0\.2\.3|0\.1\.5' | head
echo "=== inline scripts or event handlers in book sources at BNEW"
git grep -nE '<script|onclick=|onload=|javascript:' $BNEW -- book theme 2>&1 | head -20; echo "(end)"
echo "=== book render path: external commands (render runs typst and git; diagrams/samples/console are other subcommands)"; git grep -n 'Command::new' $BNEW -- xtask/src/render.rs xtask/src/highlight.rs xtask/src/preprocess.rs; git grep -nE 'Some\("(render|samples|console|diagrams)"\)' $BNEW -- xtask/src/main.rs
echo "=== book CI std staging step at BNEW"
git show $BNEW:.github/workflows/book.yml | sed -n '150,200p'
echo "=== book pins at BNEW"; git show $BNEW:wolf-toolchain.toml | grep -vE '^\s*#' | grep -nE 'wolf|lupin|rev|std|sha|version' | head -30
echo "=== book/ prose diff"; git diff $BOLD $BNEW -- book/ | head -900
echo "=== site grep (0.2.32 / 0.1.54 literals)"
cd $L/web; grep -rnE 'aarch64|windows-msvc|0\.2\.32|0\.2\.31|0\.1\.54' site/ | grep -v '^site/docs/api' | cut -c1-220 | head -60; echo "(end site grep)"
grep -rnE "$FIVE|signal_one|exit_signal|_core\b|34\.6|text\(0\)" site/ | grep -v '^site/docs/api' | cut -c1-220 | head -20; echo "(end five-name grep)"
echo "=== wolf-std trunk (sc66's wrappers are past cceda63 and must not be shown)"
echo "std trunk: $(git ls-remote https://github.com/wolffe-lang/wolf-std refs/heads/trunk)"
cd $W/wolf-lang; git checkout -q $OLD || exit 1
echo DERIVE-DONE
