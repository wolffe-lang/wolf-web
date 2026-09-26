# ww33 — The Site at 0.2.17

**Class:** short, one repo, one bump, three gitlinks. **Opus.** **Wave:** 48.
**Written 2026-09-26 by the lane**, from ww32's contract
(`wolf/sprints/web/ww32-the-site-at-0216.md`) with every input re-derived.
One deliverable: lupp.us serves wolf 0.2.17, lupin 0.1.40 and the book at
bs53's head, with every stamped number derived at the checkout and the lag
the ancestry guard computes, not a number anyone typed.

This file is the first commit on branch `ww33`, cut from wolf-web trunk
`c70c0f5` with all three gitlinks still at ww32's values. Sections 2 and 3
are written before any gitlink moves; section 4 is filled in afterwards,
below a line that says so.

## 1. Forbidden, absolutely

- **No build on nomad-1.** Everything that compiles — the wasm module, the
  book render, the site build — runs on kasumi under `~/lanes/ww33/` with
  `CARGO_BUILD_JOBS=4`. nomad-1 runs `git`, `gh`, `curl` and nothing else.
- No `rm` outside `~/lanes/ww33/` and `/private/tmp/ww33`; no deletion in any
  tree this lane did not create (ww32's `~/lanes/ww32/` is read, never
  touched). No `git add -A`. No `~/.claude/`. No edit to another lane's file.
- **No hand-typed count, version or distance anywhere in `site/`.** Every
  number the pages carry comes from the stamps (`stamp-counts.py`,
  `stamp-revisions.py`, `stamp-sizes.py`) and every stamped or literal
  sentence changes only through the allowlists.
- **No deploy.** PR open, unmerged. The fast-forward fires the deploy job;
  after the merge the lane only reads the deploy run and the live
  `version.json`.
- No merge, no rebase-merge. No `2>/dev/null` on a checkout.
- No "seen red" without a run id, sha, path or digest in the same paragraph.
- Kill only this lane's own pids, never a pattern or a process group.
- No `gh run watch` without `--interval 60`; every wait prints elapsed time
  at least every five minutes.
- No attribution trailer on any commit or in the PR body.
- kasumi `/home` is at 95 %: the lane's build dirs are pruned once the
  evidence is written.

## 2. Inputs, verified (re-derived 2026-09-26, before any gitlink moves)

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | `c70c0f5` | `c70c0f5acba50c0f51dbb1b74448b36af9edc38e` | `gh api repos/wolffe-lang/wolf-web/commits/trunk` |
| book gitlink | `e0a44a3` | `e0a44a337ecbf0b8421f36d4bc38af880c698d1a` | `git ls-tree HEAD upstream/` |
| wolf-lang gitlink | `93a5fe5` | `93a5fe504593ca7642b78ba83b4986e7a03cfe71` (tag `v0.2.16`) | same |
| wolf-interp gitlink | `ba357aa` | `ba357aa6a2e32040d4f089d2cefe05bab86c4f86` (tag `v0.1.38`) | same |
| live `version.json` | — | built `2026-09-24T06:29:52Z`, lupin `0.1.38`, pins `93a5fe5` / `ba357aa` / `e0a44a3`, spec-pin `2e4ca76`, `missing: []` | `curl https://lupp.us/version.json` |
| wolf 0.2.17 | `02afce84`, release 397045016 | annotated tag `v0.2.17` → `02afce84f05c7841856a10671b6d7924f79193cc`; release 397045016, `draft:false`, `prerelease:false`, 4 assets, published 2026-09-26T02:51:54Z; 0 draft releases in the repo; `releases/latest` = `v0.2.17` | `gh api` |
| lupin 0.1.40 | `54f85e6`, release 397033025 | annotated tag `v0.1.40` → `54f85e694d4c03e5cd40bef461f85ca0ac373332`; release 397033025, `draft:false`, 5 assets, published 2026-09-26T02:08:09Z; 0 draft releases; `Cargo.toml` `version = "0.1.40"` at that commit | `gh api`; `git show 54f85e6:Cargo.toml` |
| lupin 0.1.40's spec gitlink | pins v0.2.16 `93a5fe5` | `upstream` gitlink at `54f85e6` = `93a5fe504593ca7642b78ba83b4986e7a03cfe71`, the `v0.2.16` tag commit exactly | `gh api contents/upstream?ref=54f85e6`; `git ls-tree 54f85e6 upstream` |
| book target | `f2f4280` (bs53) | wolf-book trunk `f2f4280f3a06e49a2a8e76fb581a2666e480105d`; `e0a44a3` is its ancestor, 40 commits | `git -C wolf-book log origin/trunk`; `merge-base --is-ancestor` |
| ancestry | — | `git merge-base --is-ancestor 93a5fe5 02afce84` exits **0** | kasumi, `~/lanes/ww33/derive.log` |
| the lag | one release, not zero | `rev-list --count 93a5fe5..02afce84` = **72**; `gh api compare` = `ahead 72, behind 0`; pinned CHANGELOG headings run `0.2.17`, `0.2.16`, … so the guard's `gap` = index of `0.2.16` = **1** | kasumi `derive.log`; `gh api compare` |
| the book's own statement of the pair | — | wolf-book `CHANGELOG.md` at `f2f4280`, bs53 entry: "The pair is wolf 0.2.17 / lupin 0.1.40 … the interpreter's clause is 72 commits and one release behind" | `git grep` at `f2f4280` |
| doors | "both are current" | AUR RPC: `wolf-lang` 0.2.17-1, `wolf-lang-bin` 0.2.17-1, `lupin` 0.1.40-1, `lupin-bin` 0.1.40-1 (all modified 2026-09-26 03:05–03:06Z), `lobo-bin` 0.1.1-1; tap `Formula/wolf.rb` tag `v0.2.17` rev `02afce84…`, `Formula/lupin.rb` tag `v0.1.40` rev `54f85e6…`, tap head `7f8c735` | `aur.archlinux.org/rpc/v5/info`; `gh api repos/wolffe-lang/homebrew-wolf` |

**Drift, reported:**

1. **wave-48.md's ww33 row says the lag is *zero*.** It is one release: lupin
   0.1.40 is built to the `v0.2.16` tag, and the site advertises 0.2.17. The
   row carries its own question mark and the brief and bu09's lesson both say
   one; the guard computes it, and the guard is what the pages are held to.
2. **ww32's contract said `spec/grammar.ebnf` is byte-identical across its
   bump; this bump it is not.** 0.2.17 adds two productions
   (`index_place '=' 'take' expr` and `index_place ::= expr '[' expr ']'`,
   s182's `[gram.expr.assign]`). Anchors 539 → **541**: `+mem.model.place.rhs`,
   `+os.fs.path.domain`, none dropped (set difference taken both ways).
3. The main checkout at `~/GithubOrgs/wolffe-lang/wolf-web` sits at trunk with
   three dirty submodules and untracked `.DS_Store`/`.docs`; it is not this
   lane's and nothing is committed there. This branch lives in the worktree
   `/private/tmp/ww33`, cut from `origin/trunk`.

Other facts read off the two compiler checkouts (kasumi, `derive.log`):
`docs/diagnostics.md` `## E` headings 142 → 142, `docs/warnings.md` `## W`
34 → 34, `corpus/net/*.lu` 18 → 18; corpus 18 files added, 1 modified, 0
removed; the `phase: run` set 411 → 422, **11 in, 0 out**, no pre-existing
run program's file modified. Five documents moved: `spec/01-grammar.md`,
`02-memory-model.md`, `06-differential-protocol.md`, `11-os.md`, and
`docs/diagnostics.md`. Book `e0a44a3..f2f4280`: 69 files, `book/SUMMARY.md`
not in the diff (sha identical), chapters touched 01, 04, 05, 07, 08, 11, 14,
22, 28 and back matter (colophon, solutions); 29, 25, 21 and 13 untouched.

## 3. Prediction, committed before the first gitlink moves

Each item names what falsifies it.

**3.1 Served pages.** **63 dry, 63 live, no URL added or removed**; the book's
web edition stays **48 pages** (SUMMARY.md is byte-identical across the book
bump, and the render walks it). *Falsified by* any other count.

**3.2 Version strings.** `/install/` and `/play/` stamp `__WOLF_VERSION__` =
**0.2.17** and `__LUPIN_VERSION__` = **0.1.40**. `version.json`: lupin
`0.1.40`, pins `wolf-lang 02afce8`, `wolf-interp 54f85e6`, `wolf-book f2f4280`,
`spec-pin 93a5fe5`, `missing: []`. *Falsified by* any of these on the built
`dist/` or, after the merge, on the live file.

**3.3 The lag.** `check-lag-phrases.py` answers `gap 1`, `phrase "one
release"`, `tagged true`, `commits 72`, `spec 93a5fe5`, `release 0.2.16`,
`advertised 0.2.17`. Both pages keep **`one release`** and neither acquires
another phrase; `a development revision` stays absent (the pin is the tag
commit, so the reserved "no release" sentence is refused, and it is not on
either page today — it does not "come off", it was never on). The stamped
distance becomes **`seventy-two`** (it was `one hundred and forty-eight`).
*Falsified by* any other value in the guard's JSON.

**3.4 The census at 0.2.17 / 0.1.40.** Same rule as ww32: every file under
the pinned `corpus/` whose header matches `^//!\s*phase:\s*run\b`, fed to the
module this build publishes. Baseline is ww32's committed measurement at the
deployed pins (`~/lanes/ww32/ww32-census-0216-0138.json`, module sha256
`7bcb9e1e…`): 411 programs, 287 exit, 33 trap, 90 unsupported, 1 fail
(`conc/proc_join_param.lu`, `fail(E0301)`), 320 candidates.

| class | ww32 (0.2.16 corpus, 0.1.38 module) | ww33 predicted | delta |
|---|---|---|---|
| programs | 411 | **422** | +11 |
| `exit` | 287 | **297** | +10 |
| `trap` | 33 | **33** | 0 |
| `unsupported` | 90 | **92** | +2 |
| `fail` | 1 | **0** | −1 |
| candidates (`exit` + `trap`) | 320 | **330** | +10 |
| kills the instance | 0 | **0** | 0 |

Reasoning, row by row. The eleven arrivals: the four `index_store_*` (#438,
which 0.1.40 is "the first lupin that answers as ruled"), the four
`mut_claim_*` (#449 — a compiler-side extent bug; each file's header says
lupin 0.1.38 already prints the answer), and `store_rhs_first_list`/`_map`
(headers: `7 65` on lupin 0.1.38) → **ten `exit`**; `store_rhs_first_pool`
(header: lupin declines `Pool` by name) → **one `unsupported`**. The one
parting, `proc_join_param`, closes because lupin 0.1.39 made `Scope` and
`Proc[T]` prelude type names (wolf-interp#130); it then reaches a proc spawn,
which the browser build declines, so it moves **`fail` → `unsupported`**, not
to `exit`. No pre-existing row other than that one changes class.
*Falsified by* any class count other than the table's, any `fail` row, or any
pre-existing row changing class besides `proc_join_param`. Measured two ways
(the module's move alone on the old corpus, and both new) so the corpus's
share and the module's share are separate numbers.

**3.5 Allowlist lines.** All three clocks move, so every clocked line reddens:
**56** — `version-allowlist.txt` 32 (25 wolf, 7 lupin), `stamp-allowlist.txt`
6 (4 wolf, 2 lupin), `count-allowlist.txt` 18 (9 wolf, 5 lupin, 4 book). ww32
re-read 61. The 53 `frozen` version entries and 61 `counted=0` count entries
carry no clock. Predicted to **leave**: `install/index.html 0.2.14` and
`install/index.html 0.1.36` (the AUR's trailing versions, which the doors
sentence no longer names). Predicted to **arrive**: `v0.2.16` literals on
`index.html` and `spec/index.html` (the sentences that today tell 0.2.16's
story under the wolf stamp) and a `v0.2.15` literal on `index.html` (the
"release before this one" paragraph becomes two releases back). *Falsified
by* the audits reddening on any number of clocked lines but 56.

**3.6 Sentences false at the new stamps** (the class ww32 found four of):
- front page: the "release this page advertises" paragraph (the exit
  status, 0.2.16's), "four programs the release before this one got wrong"
  (0.2.15's defects), **"one defect goes out with this release"** (#431 —
  fixed in 0.2.17, so this becomes false outright), and "the release before
  this one grew a surface" (0.2.15's). Rewritten for 0.2.17: #449 and #431
  fixed first, then the index store follows `push` (#438), the store
  evaluates its right-hand side first (`[mem.model.place.rhs]`), and the
  record names a diagnostic's file (#437).
- `/spec/`: the six bound `v__WOLF_VERSION__` sentences on 01, 02, 03, 05, 06
  and 10 describe 0.2.16 and move to the literal `v0.2.16`; 03's "the one
  corpus program the tab refuses at these pins" becomes false (3.4); new
  sentences for what 0.2.17 moved in 01, 02, 06 and 11.
- `/play/`: the lag paragraph's history ("It did not at the pin before
  this one…" about 0.1.37) is re-read, and **"Where the vintage shows: in
  one program"** retires — the parting is none (3.4).
- `/install/`: the doors paragraph. **Both channels agree again**: tap and
  all four AUR packages read 0.2.17 / 0.1.40 live, so "the AUR is not … two
  tags" comes off and the sentence says the channels agree, read live.

**3.7 Stamps other than the distance, read off the new pins:**
`bookchapters` 33, `diagnostics` 142, `warnings` 34, `netprograms` 18,
`samples` 36. The four `/reading/` book readings (thirty-one written through,
chapter 29 whole, chapter 25 one section, chapter 21 three of five, part 5
six programs) **stand** — none of 13, 21, 25, 29 is in the book diff. The
front page's `eighteen` (cores in §13.1) stands. §13.1's bench table still
leads with the 2.3× slower row.

**3.8 The #128 / B57 regression probe.** `corpus/grammar/range_header_inclusive_max.lu`
and `grammar/range_value_wide_iter.lu`, fed explicitly to the 0.1.40 module,
still **exit 0**; the instance does not die. *Falsified by* a trap of the
instance or any verdict but `exit(0)`.

**3.9 The menu.** `check-samples.mjs`: 36 programs, every one in the class
the page claims, none carrying a note — no menu program moves.

**3.10 The PDF.** 5.6 MB ± 0.1 MB on kasumi (the solutions back matter grew;
typst output is not byte-stable across hosts, so the served figure is the
deploy host's).

**What I expect to get wrong:** the `unsupported` split, if a pre-existing
row flips on something 0.1.39/0.1.40 changed that no corpus header names; and
the allowlist arrivals, whose exact count depends on how the rewrites spell
their history.

## 4. Evidence index

*Filled in after the measurement; nothing above this line is edited after the
prediction commit except to append.*

Measured on kasumi at branch head `ebd69f0` (the last site change; later
commits touch only this file and `docs/audit/ww33-evidence/`). Files below are
under `docs/audit/ww33-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction commit `f7ca63c`; first pin commit `dff4642`; `git merge-base --is-ancestor f7ca63c dff4642` exits 0 |
| three gitlink commits | book `dff4642` (→ `f2f4280`), wolf `44cfb27` (→ `02afce84`), lupin `ecaca09` (→ `54f85e6`) |
| inputs, lag, corpus sets, anchors, grammar | `derive.log` |
| ancestry guard, verbatim | `summary.txt`: `lag phrases: wolf 0.2.17 is advertised; lupin was built at the v0.2.16 tag (93a5fe5) — it reads the release before this one, and both pages carry 'one release' and neither carries another`; `--json`: `{"gap": 1, "phrase": "one release", "tagged": true, "commits": 72, "spec": "93a5fe5", "release": "0.2.16", "advertised": "0.2.17"}` |
| stamped lag | `speccommits 72` in `summary.txt`; `seventy-two commits` on both built pages |
| census, four legs | `summary.txt` (per-leg class counts), `census-0217-0140.json` (the served census, 422 rows), `rows.txt` (row-level diffs), harness `census.mjs` (ww32's, unmodified), `rows.py` |
| arrivals print their headers' stdout | `stdout-probe.txt` (10 MATCH; the two non-matches are the `Pool` and proc declines), `stdout-probe.mjs` |
| #128 / B57 probe | `stdout-probe.txt`: `range_header_inclusive_max.lu` `exit(0)` `first 0\ntail 3\n` MATCH; `range_value_wide_iter.lu` MATCH; `rows.txt`: `died rows: []` |
| modules | 0.1.40 wasm sha256 `df4cecc3…` (built twice from the gitlink, identical); 0.1.38 wasm `7bcb9e1e…` = ww32's (`summary.txt`) |
| audits, links, tests, menu, ahead gate | `summary.txt`: version prose / counts / lag exit 0; 1457 internal links across 63 pages, 0 dead; node tests 104 pass 0 fail; check-samples 36 in class; check-ahead 0 ahead, 541 anchors |
| allowlist cost | commit `1bf710c` (the 56 clocked lines plus leaves/arrivals) and `ebd69f0` (8 CHANGELOG lines); book/wolf-clock count lines in `dff4642`, `44cfb27` |
| dry vs live pages | 63 dry (`summary.txt`); 63 of 63 answer 200 on the served site today (`summary.txt`, live check line) |
| release asset digests | `summary.txt` (from the release API; the site build consumes no archive) |
| windows claims at 0.2.17 | windows learner path run 36278485139 at `1bf710c`, green, log shows `wolf 0.2.17 (wolfgang, pin 02afce8)`; the lag step reddened at `b778d9b` (run 36278449146) on a reserved phrase the doors sentence spelled, fixed by the next commit |
| CI at head | recorded in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| pages dry / live / book | 63 / 63 / 48 | 63 / 63 / 48 |
| versions, `version.json` | 0.2.17, 0.1.40; `02afce8` `54f85e6` `f2f4280`, spec-pin `93a5fe5`, missing [] | identical |
| guard | gap 1, tagged, 72 commits | identical |
| census programs / exit / trap / unsupported / fail / candidates / died | 422 / 297 / 33 / 92 / 0 / 330 / 0 | 422 / 297 / 33 / 92 / 0 / 330 / 0 |
| rows that change class besides `proc_join_param` | none pre-existing | none pre-existing (on the old corpus); on the new corpus the old module traps the two `index_store_copies_*` arrivals, which the prediction did not state and does not contradict |
| clocked allowlist lines | 56 | 56 (32 version, 6 stamp, 18 count) |
| leaves / arrivals | 2 leave; `v0.2.16` on index and spec, `v0.2.15` on index | 2 leave; 6 arrive: those 3 plus `v0.2.16` on install, `v0.2.14` and `0.1.37` on play — the three stale sentences the prediction did not know about |
| stamps | 33 / 142 / 34 / 18 / 36 | identical |
| #128 probe | exit 0, no death | exit 0, stdout matches, no death |
| menu | 36, none moves | 36, all in class |
| PDF | 5.6 MB ± 0.1 | 5.6 MB (5,611,925 B on kasumi) |

**Found, not predicted.** Four unstamped sentences named the wrong release
and no gate could see them: /spec/ 01 "this release" (FORMAT_SPEC is
v0.2.15's, false since 0.2.16), /install/ "a shape this release gave the
record" (v0.2.16's), /install/ "the tag the compiler above was cut two tags
after" (false since ww32, when the gap became one), /play/ "one of them is
this release's" plus "the newest is not in it yet" about `writev_head` (the
witness is v0.2.14's; `net_writev_head` has been in lupin since 0.1.37). And
ww32's insertions on /spec/ 05 and 06 split two sentences mid-clause
("…number in the / At v… / thousands."). All fixed at this bump.

## 5. Done-when

- [ ] Branch `ww33` on origin; PR open, **unmerged**, body carries these five
      sections.
- [ ] The prediction commit precedes the first gitlink commit (machine-checked:
      `git merge-base --is-ancestor <prediction> <first pin>`).
- [ ] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [ ] Every gate green in the build on kasumi at the head; CI green at the
      head sha (`gh run view`).
- [ ] The ancestry guard's line quoted verbatim; census table, allowlist
      count, #128 probe, dry page count in §4.
- [ ] CHANGELOG entry in D65's shape (no placeholder token quoted).
- [ ] kasumi build dirs pruned; no orphans; after the merge, the deploy run
      and live `version.json` read and reported; worktree `/private/tmp/ww33`
      removed at the close.
