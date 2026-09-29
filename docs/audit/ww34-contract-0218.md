# ww34 — The Site at 0.2.18

**Class:** short, one repo, one bump, three gitlinks. **Opus.** **Wave:** 50.
**Written 2026-09-28 by the lane**, from ww33's contract
(`docs/audit/ww33-contract-0217.md`) and its record in `wolf/sprints/wave-48.md`,
with every input re-derived. One deliverable: lupp.us serves wolf 0.2.18,
lupin 0.1.41 and the book at bs54's head, with every stamped number derived at
the checkout and the lag the ancestry guard computes, not a number anyone
typed.

This file is the first commit on branch `ww34`, cut from wolf-web trunk
`2f8f395` with all three gitlinks still at ww33's values. Sections 2 and 3
are written before any gitlink moves; section 4 is filled in afterwards,
below a line that says so.

## 1. Forbidden, absolutely

- **No build on nomad-1.** Everything that compiles — the wasm module, the
  book render, the site build — runs on kasumi under `~/lanes/ww34/` with
  `CARGO_BUILD_JOBS=4`. nomad-1 runs `git`, `gh`, `curl` and nothing else.
- No `rm` outside `~/lanes/ww34/` and `/private/tmp/ww34`; no deletion in any
  tree this lane did not create (`~/lanes/ww32/` is read, never touched). No
  `git add -A`. No `~/.claude/`. No edit to another lane's file.
- **No hand-typed count, version or distance anywhere in `site/`.** Every
  number the pages carry comes from the stamps (`stamp-counts.py`,
  `stamp-revisions.py`, `stamp-sizes.py`) and every stamped or literal
  sentence changes only through the allowlists.
- **No deploy.** PR open, unmerged. The fast-forward fires the deploy job.
- No merge, no rebase-merge. No `2>/dev/null` on a checkout.
- No "seen red" without a run id, sha, path or digest in the same paragraph.
- Kill only this lane's own pids, never a pattern or a process group.
- No `gh run watch` without `--interval 60`; every wait prints at least every
  five minutes.
- No attribution trailer on any commit or in the PR body.
- kasumi `/home` is at 96 % (42 GB free at 01:22Z): the lane's build dirs are
  pruned once the evidence is written.

## 2. Inputs, verified (re-derived 2026-09-28/29 UTC, before any gitlink moves)

| input | brief says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | `2f8f395` | `2f8f395d1a8ff857940c02ffe2e1e128a7ef8a2e` | `gh api repos/wolffe-lang/wolf-web/commits/trunk` |
| book gitlink | — | `f2f4280f3a06e49a2a8e76fb581a2666e480105d` | `git ls-tree HEAD upstream/` |
| wolf-lang gitlink | — | `02afce84f05c7841856a10671b6d7924f79193cc` (tag `v0.2.17`) | same |
| wolf-interp gitlink | — | `54f85e694d4c03e5cd40bef461f85ca0ac373332` (tag `v0.1.40`) | same |
| live `version.json` | — | built `2026-09-26T23:21:34Z`, lupin `0.1.40`, pins `02afce8` / `54f85e6` / `f2f4280`, spec-pin `93a5fe5`, `missing: []` | `curl https://lupp.us/version.json` |
| wolf 0.2.18 | `ec56a08f`, release 397723077 | annotated tag `v0.2.18` (`d9732fb`) → `ec56a08f04ff318ea659fd58683f7ae4f22dc7a5`; release 397723077 `draft:false` `prerelease:false`, 4 assets, published 2026-09-27T16:38:47Z; 0 drafts in the repo; `releases/latest` = `v0.2.18` | `gh api` |
| lupin 0.1.41 | `0cfc0cf`, release 397709135 | annotated tag `v0.1.41` (`0390e81`) → `0cfc0cfc89af5fd2aeb71d46c86742745b902869`; release 397709135 `draft:false`, 5 assets, published 2026-09-27T15:48:37Z; 0 drafts; `Cargo.toml` `version = "0.1.41"` at that commit | `gh api`; `contents/Cargo.toml?ref=0cfc0cf` |
| lupin 0.1.41's spec gitlink | pins v0.2.16 `93a5fe5` | `upstream` gitlink at `0cfc0cf` = `93a5fe504593ca7642b78ba83b4986e7a03cfe71` = `v0.2.16^{commit}`; unchanged from 0.1.40's (`54f85e6`, same sha) | `gh api contents/upstream?ref=0cfc0cf`; kasumi `derive.log` |
| book target | `dadc38b` (bs54) | wolf-book trunk `dadc38bee9eb8d5570cfe638bf9fb79bfe977ab0`; `f2f4280` is its ancestor, 19 commits | `gh api compare`; `derive.log` |
| ancestry | — | `merge-base --is-ancestor 93a5fe5 ec56a08f` exits **0**; `02afce84` is an ancestor of `ec56a08f` too | `derive.log` |
| the lag | two releases | `rev-list --count 93a5fe5..ec56a08f` = **152** (= 72 + 80: `93a5fe5..02afce84` 72, `02afce84..ec56a08f` 80); `gh api compare` = `ahead 152, behind 0`; pinned CHANGELOG headings run `0.2.18`, `0.2.17`, `0.2.16`, … so the guard's `gap` = index of `0.2.16` = **2** | `derive.log`; `gh api compare` |
| the book's statement of the pair | — | wolf-book `CHANGELOG.md` at `dadc38b`, bs54 entry: "The pair is wolf 0.2.18 / lupin 0.1.41 … releases behind the compiler's" (bs54's ledger row: 152 commits / two releases) | kasumi `git show dadc38b:CHANGELOG.md` |
| doors | "tap and AUR current" | AUR RPC: `wolf-lang` 0.2.18-1, `wolf-lang-bin` 0.2.18-1, `lupin` 0.1.41-1, `lupin-bin` 0.1.41-1 (modified 2026-09-27 16:50–16:51Z), `lobo-bin` 0.1.1-1; tap `Formula/wolf.rb` tag `v0.2.18` rev `ec56a08f…`, `Formula/lupin.rb` tag `v0.1.41` rev `0cfc0cf…`, tap head `5fc8302` | `aur.archlinux.org/rpc/v5/info`; `gh api repos/wolffe-lang/homebrew-wolf` |

**Drift, reported:**

1. None against the brief's shas, release ids, or the lag of two releases.
2. **wolf-lang's 0.2.18 CHANGELOG says "Five lanes and 74 commits"; the
   compiler's history carries 80 commits `02afce84..ec56a08f`.** The site
   states no such count (the only distance it prints is the stamped 152); noted
   so nobody copies 74 into a page.
3. The main checkout at `~/GithubOrgs/wolffe-lang/wolf-web` is at trunk and
   not this lane's; this branch lives in the worktree `/private/tmp/ww34`, cut
   from `origin/trunk`. ww33's kasumi dir `~/lanes/ww33/` no longer exists
   (pruned by its lane), so the census harness is taken from the committed
   `docs/audit/ww33-evidence/census.mjs`, unmodified.

Other facts read off the checkouts (kasumi, `~/lanes/ww34/derive.log`):
`spec/grammar.ebnf` **byte-identical** across the bump (`910ff9d5…` both
sides); anchors 541 → **542** (`+mem.model.place.elem`, none dropped, set
difference taken both ways). Documents moved: **`spec/02-memory-model.md`**
(131 lines of the diff's 144), `spec/anchors.json`, and `docs/diagnostics.md` only — no other spec
document. `docs/diagnostics.md` `## E` 142 → 142, `docs/warnings.md` `## W`
34 → 34, `corpus/net/*.lu` 18 → 18. Corpus: 40 files added, 2 modified
(`memory/elem_move_one_place.lu`, typecheck → run; `memory/list_session_struct.lu`,
`let s2 = tbl[2]` → `copy tbl[2]`), 0 removed. The `phase: run` set 422 →
**445, 23 in, 0 out**; the one pre-existing run program modified is
`list_session_struct.lu`. lupin `54f85e6..0cfc0cf`: 20 commits, one lane
(is56: every element read path traps on a moved element, #141; DIV-2026-026
files `list_session_struct.lu` as trapping at the 0.2.16 corpus). Book
`f2f4280..dadc38b`: 33 files, `book/SUMMARY.md` sha identical (`c581960`), 33
chapters; chapters touched 01, 05, 07, 08, 22, 28, 31 and back matter
(colophon, solutions); 13, 21, 25 and 29 untouched.

## 3. Prediction, committed before the first gitlink moves

Each item names what falsifies it.

**3.1 Served pages.** **63 dry, 63 live, no URL added or removed**; the book's
web edition stays **48 pages** (SUMMARY.md byte-identical). *Falsified by* any
other count.

**3.2 Version strings.** `__WOLF_VERSION__` = **0.2.18**, `__LUPIN_VERSION__` =
**0.1.41**. `version.json`: lupin `0.1.41`, pins `wolf-lang ec56a08`,
`wolf-interp 0cfc0cf`, `wolf-book dadc38b`, `spec-pin 93a5fe5`, `missing: []`.
*Falsified by* any of these on the built `dist/`, or after the merge on the
live file.

**3.3 The lag.** `check-lag-phrases.py --json` answers `gap 2`, `phrase "two
releases"`, `tagged true`, `commits 152`, `spec 93a5fe5`, `release 0.2.16`,
`advertised 0.2.18`. Both pages move **from `one release` to `two releases`**
and carry none of the other three phrases (so every incidental "one release"
on either page must be worded around); `a development revision` stays absent.
The stamped distance becomes **`one hundred and fifty-two`** (was
`seventy-two`). The guard reds on the gitlink commit that moves wolf-lang and
stays red until the two pages are rewritten. *Falsified by* any other value in
the guard's JSON.

**3.4 The census at 0.2.18 / 0.1.41.** Same rule and harness as ww33
(`census.mjs`, unmodified). Baseline is ww33's committed measurement
(`docs/audit/ww33-evidence/census-0217-0140.json`, module sha256 `df4cecc3…`):
422 programs, 297 exit, 33 trap, 92 unsupported, 0 fail, 330 candidates, 0 died.

| class | ww33 (0.2.17 corpus, 0.1.40 module) | ww34 predicted | delta |
|---|---|---|---|
| programs | 422 | **445** | +23 |
| `exit` | 297 | **319** | +22 |
| `trap` | 33 | **33** | 0 |
| `unsupported` | 92 | **93** | +1 |
| `fail` | 0 | **0** | 0 |
| candidates (`exit` + `trap`) | 330 | **352** | +22 |
| kills the instance | 0 | **0** | 0 |

Reasoning. The 23 arrivals: seven `ctl_store_order*` (the raw-pointer one
included — the five `import c` run programs already in the corpus all exit in
the tab), eleven `elem_*` and four `mut_param_restore_*` read only elements
that were not moved, or restore before reading, so 0.1.41's new trap does not
fire → **22 `exit`**; `elem_pool_handle_revive.lu` (header: "lupin declines
`Pool` by name") → **1 `unsupported`**. No pre-existing row changes class on
the new corpus.

The four legs, separately: **module move on the 0.2.17 corpus (0.1.40 →
0.1.41): exactly one row moves, `memory/list_session_struct.lu` `exit(0)` →
`trap(use-after-move)`** (DIV-2026-026, the old text moved `tbl[2]` and walked
`tbl`). **Corpus move under 0.1.41: that row moves back** (`copy tbl[2]`) and
no other common row moves; **corpus move under 0.1.40: 0 common rows move.**

**Output, not class (the stdout probe):** of the 22 `exit` arrivals, **21 print
their header's stdout and one does not: `ctl_store_order_nested_index.lu`**,
where lupin runs every index operand but the last twice (wolf-interp#145, open
at 0.1.41; the header says so). That is a parting the class census cannot see
and the pages must state. *Falsified by* any class count other than the
table's, any `fail` or died row, any other module-leg row, or a probe mismatch
count other than one.

**3.5 Allowlist lines.** All three clocks move, so every clocked line reddens:
**60** — `version-allowlist.txt` 36 (29 wolf, 7 lupin), `stamp-allowlist.txt`
6 (4 wolf, 2 lupin), `count-allowlist.txt` 18 (9 wolf, 5 lupin, 4 book). The
56 `frozen` version entries and 61 `counted=0` count entries carry no clock.
Predicted to **arrive**: `v0.2.17` literals on `index.html` (0.2.17's
paragraphs become history), `spec/index.html` (the four bound 0.2.17 sentences
on 01, 02, 06 and 11) and `install/index.html` (the lag history); a lupin
literal `0.1.40` on `play/index.html` (the index-store programs "the interpreter
this site served until this bump"). Predicted to **leave**: none. The
`stamp-allowlist` totals on `spec/index.html` fall by the four sentences that
become literals. *Falsified by* the audits reddening on any number of clocked
lines but 60.

**3.6 Sentences false at the new stamps** (the class ww33 found five of,
unstamped):
- front page: "The release this page advertises gives back what the one before
  it took away" and the two 0.2.17 paragraphs after it (#449's walk, #431, the
  index store) — rewritten as v0.2.17's history, with 0.2.18's two silent wrong
  answers (#460, #464) first, then element places, R3 over any `Copy` local,
  and index-then-value.
- `/spec/`: the four bound `v__WOLF_VERSION__` sentences on 01, 02, 06 and 11
  become `v0.2.17`; 01's "at v__WOLF_VERSION__ it is still grammar/1" stays
  stamped (grammar byte-identical); 02's "the order of the place's own operands
  … is not ruled" is false at 0.2.18 (s183 rules it) and gains 0.2.18's
  sentence (`[mem.model.place.elem]`, `[mem.tier0.mode.mut]`'s every-return rule,
  index first).
- `/play/` and `/install/`: every "one release", "tagged once since", "the
  narrowest a distance can be … second bump running", "the pin before this
  one", "two pins back" and "until this bump" is re-read; each relative
  reference that now points at a different pin names its version literally.
  The vintage paragraphs change from "nowhere" to **one program whose output
  parts** (3.4).
- `/install/` doors: still agree (3.2 inputs); "At the pin before this one they
  had parted" becomes false (that was 0.2.16's bump) and names its release.

**3.7 Stamps other than the distance:** `bookchapters` 33, `diagnostics` 142,
`warnings` 34, `netprograms` 18, `samples` 36. The four `/reading/` readings
(thirty-one written through, chapter 29 whole, chapter 25 one section, chapter
21 three of five, part 5 six programs) **stand**; the front page's `eighteen`
(cores in §13.1) stands; §13.1's bench table still leads with the 2.3× slower
row.

**3.8 The #128 / B57 regression probe.** `grammar/range_header_inclusive_max.lu`
and `grammar/range_value_wide_iter.lu`, fed to the 0.1.41 module, still
**exit 0** with their header's stdout; the instance does not die.

**3.9 The menu.** `check-samples.mjs`: 36 programs, every one in the class the
page claims, none noted — no menu program moves under 0.1.41's traps.

**3.10 The PDF.** 5.6 MB ± 0.1 MB on kasumi.

**What I expect to get wrong:** a pre-existing census row that moved an
element and later read the container through one of the newly-trapping paths
(`for`, `get`, a slice) — `list_session_struct` is the one lupin's own
ledger filed, but lupin's ledger reads its own pinned 0.2.16 corpus, not
0.2.18's; and the allowlist arrivals, whose count depends on how the rewrites
spell their history.

## 4. Evidence index

*Filled in after the measurement; nothing above this line is edited after the
prediction commit except to append.*

Measured on kasumi at branch head `e13fb0c` (the last change the build reads;
later commits touch only this file and `docs/audit/ww34-evidence/`). Files
below are under `docs/audit/ww34-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction commit `f0b56e2`; first pin commit `fc877f0`; `git merge-base --is-ancestor f0b56e2 fc877f0` exits 0 |
| three gitlink commits | book `fc877f0` (→ `dadc38b`), wolf `cdb7fd8` (→ `ec56a08f`), lupin `c86c5d5` (→ `0cfc0cf`) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers | `derive.log` (script `ww34-derive.sh`) |
| book readings at `dadc38b` | `book.log` |
| ancestry guard, verbatim | `summary.txt`: `lag phrases: wolf 0.2.18 is advertised; lupin was built at the v0.2.16 tag (93a5fe5) — it reads 2 releases back, and both pages carry 'two releases' and neither carries another`; `--json`: `{"gap": 2, "phrase": "two releases", "tagged": true, "commits": 152, "spec": "93a5fe5", "release": "0.2.16", "advertised": "0.2.18"}` |
| stamped lag | `speccommits 152` in `summary.txt`; `one hundred and fifty-two commits` on both built pages (`summary.txt`, gates) |
| census, four legs | `summary.txt` (per-leg class counts), `census-0218-0141.json` (the served census, 445 rows), `census-0217-0140.json` (the control leg), `rows.txt` (row-level diffs, script `ww34-rows.py`); harness `docs/audit/ww33-evidence/census.mjs`, byte-identical (`cmp`), driver `ww34-measure.sh` |
| arrivals print their headers' stdout | `stdout-probe-0141.txt`: 21 MATCH of 22 `exit` arrivals; DIFF `ctl_store_order_nested_index.lu` (`i\ni\nj\nval…` vs `i\nj\nval…`, #145); the `Pool` row DIFFs as a decline; `list_session_struct.lu` DIFFs only on the header's missing trailing `\n` (probe artifact, verdict `exit(0)`); `stdout-probe-0140.txt` the same three under 0.1.40 |
| #128 / B57 probe | `stdout-probe-0141.txt`: `range_header_inclusive_max.lu` and `range_value_wide_iter.lu` `exit(0)` MATCH; `rows.txt`: `died rows: []` |
| modules | 0.1.41 wasm sha256 `d4e28724…` = the served `dist/play/lupin.wasm`; 0.1.40 control `170d1136…` (`summary.txt`) |
| 0.1.40 control reproduces ww33 | row-identical to ww33's `census-0217-0140.json` (422 rows, 0 verdict diffs); digest differs from ww33's `df4cecc3…`: the module embeds the absolute build path (16 × `lanes/ww34/`), and swapping the path back does not recover it (`path-control.txt`) — the census, not the digest, is what reproduces |
| audits, links, tests, menu, ahead gate | `summary.txt`: version prose / counts / lag exit 0; 1457 internal links across 63 pages, 0 dead; node tests 104 pass 0 fail; planted ahead 8 pass; check-samples 36 in class; check-ahead 0 ahead, 542 anchors |
| allowlist cost | `8cda8c2` (the 60 clocked lines plus the rewrites' literals), `e13fb0c` (7 CHANGELOG lines); book/wolf-clock count lines in `fc877f0`, `cdb7fd8` |
| dry vs live pages | 63 dry (`summary.txt`); 63 of 63 answer 200 on the served site today (`summary.txt`, live check line) |
| release asset digests | `summary.txt` (from the release API; the site build consumes no archive) |
| CI at head | recorded in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| pages dry / live / book | 63 / 63 / 48 | 63 / 63 / 48 |
| versions, `version.json` | 0.2.18, 0.1.41; `ec56a08` `0cfc0cf` `dadc38b`, spec-pin `93a5fe5`, missing [] | identical |
| guard | gap 2, "two releases", tagged, 152 commits | identical |
| census programs / exit / trap / unsupported / fail / candidates / died | 445 / 319 / 33 / 93 / 0 / 352 / 0 | 445 / 319 / 33 / 93 / 0 / 352 / 0 |
| module leg on the 0.2.17 corpus | `list_session_struct` exit → trap, nothing else | identical |
| corpus legs | under 0.1.41 that row back; under 0.1.40 none | identical |
| stdout of the 22 `exit` arrivals | 21 match, `ctl_store_order_nested_index` does not | identical |
| clocked allowlist lines | 60 (36 / 6 / 18) | 60 (36 / 6 / 18) |
| leaves / arrivals | 0 leave; `v0.2.17` on index, spec, install; `0.1.40` on play | 0 leave; 10 arrive: those 4 plus `0.1.40` on spec, `0.1.39`, `v0.2.15`, `v0.2.16`, `v0.2.17` on play and `v0.2.15` on install — the relative pins ("two pins back", "the pin before this one") each named by release |
| stamp totals | spec `__WOLF_VERSION__` 5 → 1 | 5 → 2 (one new bound 0.2.18 sentence on 02); play `__LUPIN_VERSION__` 1 → 2 (the #145 sentence), not predicted |
| stamps | 33 / 142 / 34 / 18 / 36 | identical |
| #128 probe | exit 0, no death | exit 0, stdout matches, no death |
| menu | 36, none moves | 36, all in class |
| PDF | 5.6 MB ± 0.1 | 5.6 MB (5,616,882 B on kasumi) |

**Found, not predicted.** Four unstamped sentences were false and no gate
could see them: /spec/ 01 "Every release since has widened it" (0.2.16 and
0.2.18 left `grammar.ebnf` byte-identical); /spec/ 11 "the interpreter this
site pins is the first release of it to serve … a path that climbs out" (that
was lupin 0.1.40, false the moment the pin moved); /play/ "the program a reader
could not run here a week ago" (the range program has run here since
wolf-interp#83); /install/ "nothing this release's corpus adds parts from the
compiler" (true at 0.2.17, false at 0.2.18 by #145). The wasm module is not
byte-reproducible across lane directories (above), so ww33's "built twice,
identical" held only within one directory.

## 5. Done-when

- [ ] Branch `ww34` on origin; PR open, **unmerged**, body carries these five
      sections.
- [ ] The prediction commit precedes the first gitlink commit (machine-checked:
      `git merge-base --is-ancestor <prediction> <first pin>`).
- [ ] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [ ] Every gate green in the build on kasumi at the head; CI green at the
      head sha (`gh run view`), waited to completion.
- [ ] The ancestry guard's line and JSON quoted verbatim; census table,
      allowlist count, #128 probe, dry page count in §4.
- [ ] CHANGELOG entry in D65's shape.
- [ ] kasumi build dirs pruned; no orphans; worktree `/private/tmp/ww34`
      removed at the close (after the merge).
