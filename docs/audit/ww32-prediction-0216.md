# ww32 — the prediction, committed before the first gitlink moves

Written at branch point `12162ed`, with all three gitlinks still at ww31's
values (book `bcad859`, wolf-lang `2e4ca769`, wolf-interp `6e94436`). Nothing
below was measured through a build of the new pins; everything below is
derivable from the two checkouts' history, the allowlists in `scripts/`, and
the two upstream CHANGELOGs, or it is a guess with its reasoning written down.
Each item names what would falsify it.

## 0. Inputs, re-derived 2026-09-24 (§2)

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | `12162ed` | `12162ed` | `git fetch origin`, `origin/trunk` |
| book gitlink | `bcad859` | `bcad859aac047f5eead4150016a79ed6b8f6e919` | `git ls-tree HEAD upstream/` |
| wolf-lang gitlink | `2e4ca769` | `2e4ca769b396219585a07ff18492529c944672d9` | same |
| wolf-interp gitlink | `6e94436` | `6e94436b2cae285bf2ffc19477600535e33ccbbb` | same |
| live `version.json` | built 2026-09-17T20:51:12Z, lupin 0.1.36, spec-pin a7f517e, missing [] | identical, HTTP 200 | `curl https://lupp.us/version.json` |
| wolf 0.2.16 | `93a5fe50`, four assets, zero drafts, release 395302343 | tag `v0.2.16` -> `93a5fe504593ca7642b78ba83b4986e7a03cfe71`; release 395302343, `draft:false`, 4 assets; 0 draft releases in the repo | `gh api` |
| lupin 0.1.38 | `ba357aa` | tag `v0.1.38` -> `ba357aa6a2e32040d4f089d2cefe05bab86c4f86`; 0 draft releases | `gh api` |
| book target | `e0a44a3` | wolf-book trunk `e0a44a337ecbf0b8421f36d4bc38af880c698d1a` | `gh api` |
| lupin's conformance pin | `vendor/upstream/PIN` -> `2e4ca769` | `2e4ca769b396219585a07ff18492529c944672d9` | `gh api contents` at `ba357aa` |
| the lag | one release, 148 commits | `2e4ca769...93a5fe50` is `status: ahead`, `ahead_by: 148`, `behind_by: 0` | `gh api compare` |

No drift. The one thing that is not as a reader might assume: the shared
checkout at `~/GithubOrgs/wolffe-lang/wolf-web` is stale at `3525d78` (ww23)
and carries a dirty `upstream/wolf-interp`; it is not this lane's and nothing
was committed there. This branch is cut from `origin/trunk`.

## 1. The served page count

**63 pages dry, 63 live, no URL added and none removed**, and the book's web
edition stays **48 pages**.

The reasoning is not a memory of ww31's number: the book bump `bcad859` ->
`e0a44a3` is 25 commits over 34 files with **three files added**
(`LICENSE-TRAINING-DATA`, `docs/audit/bs51-prediction-0216.md`,
`snapshots/diagnostics/book__ch07__part-movedleaf.txt`), **none removed, none
renamed, and `SUMMARY.md` not in the diff at all**. The web render walks
`SUMMARY.md`, and none of the three added files is a chapter, so the render
has the same page set. No page under `site/` is added or deleted by this lane.

Falsified by: any dry count other than 63, any live count other than 63, or a
book page count other than 48.

## 2. The version strings

- `/install/` and `/play/` stamp `__WOLF_VERSION__` = **0.2.16** (the first
  `## <n.n.n>` heading of the pinned wolf-lang CHANGELOG, which is what
  `build.sh` reads) and `__LUPIN_VERSION__` = **0.1.38** (`version` in the
  pinned `wolf-interp/Cargo.toml`, verified at `ba357aa` to read `0.1.38`).
- `version.json` becomes: `lupin 0.1.38`, pins `wolf-lang 93a5fe5`,
  `wolf-interp ba357aa`, `wolf-book e0a44a3`, `spec-pin 2e4ca76`,
  `missing: []`.

`spec-pin` moves `a7f517e` -> `2e4ca76` because it is read off
`wolf-interp`'s own gitlink, and 0.1.38 re-pinned to the v0.2.15 tag.

Falsified by: any of those eight strings differing on the built `dist/` or,
after the deploy, on the live file.

## 3. The lag

**148 commits, one release.**

`check-lag-phrases.py` counts by ancestry: the newest release heading in the
pinned wolf-lang CHANGELOG that is an ancestor of the interpreter's own
gitlink, and its index in that heading list. lupin 0.1.38's gitlink is
`2e4ca769`, which is the `v0.2.15` tag commit exactly; the pinned CHANGELOG's
headings run `0.2.16`, `0.2.15`, ... so `spec = 0.2.15` and `gap = 1`.

- both pages must carry **`one release`** and none of `the same commit`,
  `two releases`, `three releases`. Today `three releases` stands **five**
  times — twice in `site/install/index.html`, three times in
  `site/play/index.html` — and every one of them has to go.
- `tagged` is **true** (the pin is the tag commit, not a revision past it), so
  the reserved `a development revision` vocabulary is **refused**, not
  required. It is absent from both pages today and stays absent: **the "no
  release" reserved sentence does not come off, because it was never on at
  this trunk.** That is the one item in §3 where I expect the contract's
  phrasing and the code to part company, and the code is the authority.
- `__COUNT_speccommits_word__` stamps **`one hundred and forty-eight`**
  (`stamp-counts.py`'s speller: `one hundred and ` + `forty-eight`).

Independent corroboration, found after the derivation and not used to make
it: wolf-book's colophon at `e0a44a3` reads "148 commits, one release".

Falsified by: `check-lag-phrases.py --json` reporting any `gap` but 1, any
`commits` but 148, `tagged` false, or the stamped distance spelling
differently.

## 4. The census at 0.2.16

Definition, stated first because ww31's number and mine do not agree and the
difference is definitional, not a drift: a census program here is a file under
the pinned `corpus/` matching `^//! phase: run` in its header block. By that
rule the corpus carries **387** at `2e4ca769` and **411** at `93a5fe50`,
**24 in and 0 out** (the set difference was taken both ways, not subtracted).
ww31's entry reports **385** at the same compiler pin, so its harness excluded
two files mine keeps; I will say which two after the measurement rather than
guess now.

Predicted, module = lupin 0.1.38's wasm build, corpus = 0.2.16:

| class | ww31 (0.2.15 corpus, 0.1.36 module) | ww32 predicted | delta |
|---|---|---|---|
| `phase: run` programs | 385 (387 by this rule) | **411** | +26 (+24) |
| `exit` | 250 | **289** | +39 |
| `trap` | 31 | **32** | +1 |
| `unsupported` | 81 | **88** | +7 |
| `fail` | 22 | **2** | −20 |
| candidates (`exit` + `trap`) | 281 | **321** | +40 |
| kills the instance | 1 | **0** | −1 |

The `fail` column is the whole claim. All twenty-two partings ww31 listed are
constructs of v0.2.13, v0.2.14 and v0.2.15 — the list literal, a nullary
variant as a pattern, `range[int]`/`range[char]` as types, the `error` alias,
and s166's method-and-combinator surface. lupin 0.1.38 is built to the
**v0.2.15 tag**, so its text contains every one of them and **all twenty-two
close at once**.

The two I predict open in their place are `corpus/memory/pool_accessors.lu`
and `corpus/memory/pool_place_write.lu`: the pool surface is 0.2.16's, it is
not in the v0.2.15 text 0.1.38 reads, and both files are new `phase: run`
entries at this pin. Predicted verdict `fail(E0201)` or `fail(E0301)`.

The `unsupported` rise is the three new `conc` programs
(`freeze_proc_snapshot.lu`, `proc_join_param.lu`, `proc_join_value.lu` — a
browser has no threads), the two new module-graph programs whose D59 graph
names sibling files (`rows/error_alias_qualified/main.lu`,
`typecheck/fn_param_shadows_import/main.lu` — a stdin buffer cannot resolve a
sibling), and two more I have not named.

Falsified by: any `fail` count other than 2, or a `fail` set that is not
exactly those two files.

## 5. The allowlist lines

**61 clocked lines are re-read**, because this is the first bump in this
site's history at which **all three clocks move at once** (wolf 0.2.15 ->
0.2.16, lupin 0.1.36 -> 0.1.38, book `bcad859` -> `e0a44a3`):

| file | wolf clock | lupin clock | book clock | total |
|---|---|---|---|---|
| `scripts/version-allowlist.txt` | 26 | 8 | 0 | **34** |
| `scripts/stamp-allowlist.txt` | 4 | 2 | 0 | **6** |
| `scripts/count-allowlist.txt` | 14 | 3 | 4 | **21** |
| | | | | **61** |

The 50 `frozen` version entries and the 58 `counted=0` count entries carry no
clock and are not re-read. For comparison ww31 moved 40 (24 version, 4 stamp,
12 counts) with the lupin clock standing still.

Falsified by: `check-version-prose.py` and `check-counts.py` reddening on any
other number of lines, or a clocked line surviving the bump unedited.

## 6. The /play/ divergence list

It is **rewritten to two rows, not retired**. The six bullet groups standing
today — list literals (6 files), the nullary-variant pattern (1), the range
types (5), the `error` alias (3), the wide-range iteration witness (1), the
method surface (6) — are all v0.2.13–v0.2.15 constructs, and all 22 close.
The pool pair of §4 is what is left.

If the measurement returns zero `fail` rows, the list retires the way ww23's
did and the page says the parting is none and says what it measured to know
it; if it returns rows I did not name, they are reported as found and not
edited into the shape above.

**wolf-lang#449 watch (§2.6 of the contract).** 0.2.16 refuses a program both
arms of whose `if`/`else` claim the same non-`Copy` place. That refusal runs
the *other* way from everything on this list — the compiler refusing what the
tab runs — so it cannot appear in the `fail` column at all; it can only show
as a corpus file leaving `phase: run`, and **no file left `phase: run` at this
bump** (0 out, measured above). So I predict **#449 costs this site's census
nothing**, which is bs51's finding for the book arriving here by a different
route. If the sample menu or the census does show a program moving from
accepted to refused with the phrase inside the outer call's extent, it is
recorded as #449 and not restructured.

## 7. The #128 / B57 probe

**I predict the module no longer dies.** `corpus/grammar/range_header_inclusive_max.lu`
reached lupin 0.1.36's own `unreachable` and took the wasm instance with it
(ww31). lupin 0.1.38's CHANGELOG records is52 fixing exactly that cause — the
interpreter materialized `for i in a..b` instead of walking it, 3.91 GB peak
RSS on a 50-million range — and names this file and
`grammar/range_value_wide_iter.lu` as matches against the real corpus at the
new pin. A walked range needs no allocation a sandbox cannot give.

So: fed explicitly (`check-samples.mjs` feeds only the menu and this file has
never been on it), the 0.1.38 module returns a verdict rather than trapping,
and /play/'s "one program is worse than a refusal" paragraph comes off.

Falsified by: the instance dying again, or any answer that is not a clean
verdict for that file.

## 8. The other pages

- `/reading/`'s paragraph added at `12162ed` — "at these pins that pair is not
  this site's" — **comes off**. The book's colophon at `e0a44a3` states wolf
  0.2.16 paired with lupin 0.1.38, which is exactly the pair this site serves
  after this bump, so the sentence is false the moment the third gitlink
  lands.
- The stamps that are not the distance are predicted **unchanged**, each read
  off the new pins rather than remembered: `bookchapters` 33 (`SUMMARY.md` not
  in the book diff), `diagnostics` 142 and `warnings` 34 (`## E`/`## W`
  headings are 142 and 34 at both `2e4ca769` and `93a5fe50`), `netprograms` 18
  (`corpus/net/*.lu` is 18 at both), `samples` 36.
- §13.1's bench table still leads with the 2.3x slower row. A render that
  reorders it is a defect.

## 9. What I expect to get wrong

The census's `exit`/`trap`/`unsupported` split. The `fail` column is an
argument from what text lupin 0.1.38 reads and I will stand on it; the other
three are arithmetic over 24 new files whose verdicts I have not run. If one
number in §4 is wrong I expect it to be `unsupported`, where I named five of
seven and guessed the rest.
