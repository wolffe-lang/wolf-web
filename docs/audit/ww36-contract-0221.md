# ww36 — The Site at 0.2.21

**Class:** one repo, one bump (three gitlinks), one deploy. **Opus.**
**Wave:** 53. **Contract:** the planning repo's
`sprints/web/ww36-the-site-at-0221.md` (planning trunk `08755cd`); this file
is the lane's copy with every input re-derived. One deliverable: lupp.us
serves wolf 0.2.21, lupin 0.1.44 and the book at wolf-book `fba6210a`, every
stamped number derived at the checkout, and `wolf-boot.js` versioned
`?v=<pin>` like every other book script.

Sections 1 to 3 are the branch's first commit (an empty commit whose message
is this text, cut from wolf-web trunk `35bbd3cd` with all three gitlinks at
ww35's values). This file lands later with section 4 filled; sections 1 to 3
are not edited after the prediction commit except to append.

## 1. Forbidden, absolutely

- **No build on nomad-1.** The wasm module, the book render, the PDF, the
  site build, the census and the node tests run on kasumi under
  `~/lanes/ww36/`. nomad-1 runs `git`, `gh`, `curl`, `ssh`/`scp` and the
  browser gate (below), nothing that compiles.
- **No install anywhere.** typst is read from `~/lanes/ww32/bin/typst` through
  a symlink in `~/lanes/ww36/bin/`; Playwright and its browsers are the ones
  already cached on nomad-1 (`playwright-core` 1.63.0 under `~/.npm/_npx/`).
- No `rm` outside `~/lanes/ww36/` (kasumi), `/private/tmp/ww36-web` and this
  lane's `ww36-*` scratch files; no deletion in any tree this lane did not
  create. No `git add -A`. Nothing under `~/.claude`. No edit to another
  lane's file; `~/lanes/ww32/` and `~/lanes/ww35/` on kasumi are read, never
  written.
- **No hand-typed count, version or distance in `site/`.** Every number comes
  from the stamps; every stamped or literal sentence changes only through the
  allowlists.
- **No deploy before the merge.** PR open, unmerged; the orchestrator audits
  and fast-forwards.
- **Never touch almanta's nginx config or anything needing sudo.** A server
  change would be staged in the repo and reported.
- No merge, no rebase-merge. No `2>/dev/null` on a checkout; the branch is
  asserted after every checkout.
- No "seen red" without a run id, sha, path or digest in the same paragraph.
- Kill only this lane's own pids, never a pattern or a process group; on
  kasumi killable jobs start under `setsid`.
- No `gh run watch` without `--interval 60`; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-03 ~10:50 UTC, before any gitlink moves)

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | `35bbd3cd` (ww35) | `35bbd3cd9e3fc46debcd73e34dcd363d7b1e6836` | `git rev-parse origin/trunk` |
| gitlinks at trunk | book `bd3484ed`, wolf-lang `c2401f05`, wolf-interp `8e2516dc` | book `bd3484edd6c3…`, wolf-lang `c2401f05f377…` (`v0.2.19`), wolf-interp `8e2516dc47bf…` (`v0.1.42`) | `git ls-tree HEAD upstream/` |
| live `version.json` | built `2026-09-30T20:28:01Z`, lupin `0.1.42`, `missing: []` | identical; pins `c2401f0` / `8e2516d` / `bd3484e`, spec-pin `ec56a08` | `curl https://lupp.us/version.json` |
| live release | — | `current -> releases/2026-09-30-202723` (the CI deploy of ww35's merge, not ww35's hand deploy `…-191146`); five kept | `ssh almanta readlink` |
| live nginx | ww35's config installed by the maintainer (2026-10-02) | `/etc/nginx/conf.d/lupp.us.conf` sha256 `2c6f09d1…` = trunk's `nginx/lupp.us.conf` | `sha256sum` both |
| wolf 0.2.21 | `dfcc2f13`, tag `v0.2.21`, release 402328307 | tag → `dfcc2f13e7c73182bdd41fc9bec2802c7da3b024`; release 402328307 `draft:false` `prerelease:false`, 4 assets, published 2026-10-03T05:53:45Z; 0 drafts | `gh api` |
| lupin 0.1.44 | `ba47627`, tag `v0.1.44`, release 402215729 | tag → `ba4762714d75c37bb14b300610e2d52630665a05`; release 402215729 `draft:false`, 5 assets, published 2026-10-02T23:15:03Z; `Cargo.toml` `version = "0.1.44"` | `gh api`; `derive.log` |
| lupin 0.1.44's spec gitlink | — | `upstream` at `ba47627` = `cdde128a30999652…` = `v0.2.20^{commit}` (0.1.42's was `ec56a08`, v0.2.18) | `derive.log` |
| book target | `fba6210a` (bs58's head, fast-forwarded) | wolf-book trunk `fba6210a1af2…` = PR #70's merge commit = its head; `bd3484e` an ancestor, **41 commits**, 75 files | `gh pr view 70`; `derive.log` |
| ancestry and the lag | — | `merge-base --is-ancestor cdde128a dfcc2f13` exits **0**; `rev-list --count cdde128a..dfcc2f13` = **91**; CHANGELOG headings at the pin run `0.2.21`, `0.2.20`, … so the guard's gap = **1** | `derive.log` |
| the book's statement of the pair | — | bs58 `effc3ed`: "the pair reads 0.2.21 / 0.1.44 — 91 commits, one release" | wolf-book log |
| the pinned parting | lupin 0.1.44 refuses an inferred-empty-row match (#176) | `rows/eu_bind_empty_row_handled.lu` is a `phase: run` arrival at 0.2.21, header `run(exit=0, stdout="43\n42\n42\n")`; wolf-lang 0.2.21's CHANGELOG pins 0.1.44's `fail(E0801)` on it by version | `derive.log`, `arrivals-headers.txt` |
| doors | r26: doors-fresh 8/8 | AUR RPC `wolf-lang`/`wolf-lang-bin` 0.2.21-1, `lupin`/`lupin-bin` 0.1.44-1; tap `Formula/wolf.rb` tag `v0.2.21` rev `dfcc2f13…`, `Formula/lupin.rb` tag `v0.1.44` rev `ba476271…`, tap head `c307c84` | AUR RPC v5; `gh api repos/wolffe-lang/homebrew-wolf` |
| wolf-boot.js | bs56 made it read its root from its own `src` with a query cut | `fba6210a:book/wolf-boot.js` strips `[?#].*$` from its src before comparing the name (`2dec44a`, #66) | `git show` |

Facts read off the checkouts (kasumi, `docs/audit/ww36-evidence/derive.log`,
script `ww36-derive.sh`): `spec/grammar.ebnf` **byte-identical** across the
bump (`910ff9d5…` both sides); `spec/01-grammar.md` moves 5 lines (struct
shorthand is the longhand, s190 — prose, not grammar); anchors **542 → 546**
(`mem.tier0.excl.4`, `type.row.defer`, `type.row.else`, `type.row.match`;
none dropped); `## E` **142 → 144**, `## W` 34 → 34, `corpus/net/*.lu`
18 → 18. Documents moved: `spec/02`, `spec/10`, `spec/11`, `spec/01`,
`spec/anchors.json`, `docs/diagnostics.md`. The `phase: run` set
**464 → 533, 69 in, 0 out**; one pre-existing run program modified
(`faults/index_origin_min_overflow.lu`: `let i: int` annotated, still a trap).
Arrivals' `check:` lines: 67 `run(exit=0…)`, 2 `run(exit=trap(assert)…)`.
lupin `8e2516d..ba47627`: 90 commits (0.1.43 and 0.1.44). Book
`bd3484e..fba6210`: `book/SUMMARY.md` blob identical (`c581960`), 33
chapters; chapters touched 01, 05, 06 (§6.6, bs57), 22, appendix C,
colophon, solutions; 13, 21, 25 and 29 untouched; `book/wolf-boot.js` moved.

**Drift, reported:**

1. **wolf-lang's 0.2.21 CHANGELOG says "Four lanes and 80 commits"; the
   compiler's history carries 91** `cdde128a..dfcc2f13` (ww34 and ww35 found
   the same shape). The site prints only the stamped 91.
2. **The deploy is not a hand step at this pin.** `ci.yml`'s `deploy to
   lupp.us` job runs on every push to trunk, so the orchestrator's
   fast-forward deploys through `scripts/ci-deploy.sh` on almanta, as ww33
   and ww34's merges did (ww35 deployed by hand only because it deployed
   before its merge). The deploy step of this lane is that job on the push
   run at this branch's head; a hand `deploy.sh` follows only if the job
   fails, and the report says which ran.
3. **The browser gate cannot run on kasumi**: kasumi has no Playwright
   browsers (`~/.cache/ms-playwright` absent) and this lane installs nothing.
   The gate runs on nomad-1 from the cached `playwright-core` 1.63.0 and its
   cached chromium 1243 / firefox 1543 / webkit 2359, as bs56's and ww35's
   did. That is a browser, not a build.
4. **ww35's lane dir on kasumi has no `bin/`** (pruned); typst 0.15.1 is read
   from `~/lanes/ww32/bin/typst`, symlinked, not copied.
5. kasumi `/home` is at **93 %, 67 GB free** (10:49 UTC).
6. The main checkout `~/GithubOrgs/wolffe-lang/wolf-web` (21 behind trunk,
   modified gitlinks, not this lane's) is untouched; this branch lives in the
   worktree `/private/tmp/ww36-web`.

## 3. Prediction, committed before the first gitlink moves

Each item names what falsifies it.

**3.1 Served pages.** **63 dry, 63 live**, no URL added or removed; the book's
web edition **48 pages** (SUMMARY blob identical). *Falsified by* any other
count.

**3.2 Version strings.** `/install/` and `/play/` stamp `__WOLF_VERSION__` =
**0.2.21** and `__LUPIN_VERSION__` = **0.1.44**; the Windows archive link
reads `wolf-0.2.21-x86_64-pc-windows-msvc.tar.gz`. `version.json`: lupin
`0.1.44`, pins `wolf-lang dfcc2f1`, `wolf-interp ba47627`, `wolf-book
fba6210`, **`spec-pin cdde128`**, `missing: []`. *Falsified by* any of these
on the built `dist/` or, after the deploy, on the live file.

**3.3 The lag.** `check-lag-phrases.py --json` answers
`{"gap": 1, "phrase": "one release", "tagged": true, "commits": 91,
"spec": "cdde128", "release": "0.2.20", "advertised": "0.2.21"}`. The phrase
on both pages **stays `one release`** (it was one release at ww35 too); the
stamped distance moves **`one hundred and five` → `ninety-one`**. The guard
reddens on the wolf pin commit (lupin 0.1.42's `ec56a08` is v0.2.18, three
releases behind 0.2.21: `gap 3`, `three releases`) and is green again at the
lupin pin with no page edit, because the pages already say `one release`.
That green is not a re-read; the allowlist clocks are what force the re-read
(3.5). *Falsified by* any other value in the JSON.

**3.4 The census at 0.2.21 / 0.1.44.** Harness `docs/audit/ww33-evidence/census.mjs`
unmodified, four legs as ww35 (0.2.19 and 0.2.21 corpora × 0.1.42 and 0.1.44
modules). Baseline: ww35's `census-0219-0142.json`.

| class | ww35 (0.2.19 / 0.1.42) | ww36 predicted | delta |
|---|---|---|---|
| programs | 464 | **533** | +69 |
| `exit` | 337 | **402** | +65 |
| `trap` | 33 | **35** | +2 |
| `unsupported` | 94 | **95** | +1 |
| `fail` | 0 | **1** | +1 |
| candidates (`exit` + `trap`) | 370 | **437** | +67 |
| kills the instance | 0 | **0** | 0 |

Reasoning. Of the 69 arrivals, 67 headers say `run(exit=0…)` and 2 say
`run(exit=trap(assert)…)` (`faults/assert_msg_effect_fails.lu`,
`faults/assert_msg_name_fails.lu`). Two of the 67 do not run here:
**`rows/eu_bind_empty_row_handled.lu` → `fail(E0801)`**, the pinned parting
(wolf-interp#176, a refusal where every compiler machine prints `43 42 42`);
and **`memory/nested_fn_mut_param.lu` → `unsupported`**, a decline lupin
0.1.44 makes at a terminal too (a nested fn with a moded parameter, #169,
waived by name in lupin's own conformance test). So arrivals: **65 exit,
2 trap, 1 unsupported, 1 fail**. The module leg on the 0.2.19 corpus
(0.1.42 → 0.1.44): **0 rows** change class or verdict. The corpus leg under
either module: **0 common rows** change (the one modified run program,
`index_origin_min_overflow.lu`, traps `overflow` before and after). Under
0.1.42 several arrivals trap `exclusivity` (headers say so); that leg's
counts are measured, not predicted.

**Output, not class (the stdout probe, 0.1.44, all 69 arrivals plus the two
#128 range programs):** every `exit` arrival prints its header's stdout —
**67 MATCH**, the two traps' headers carry no `exit=<n>` and read `n/a`, and
**2 DIFF**: the #176 refusal and the #169 decline. *Falsified by* any class
count other than the table's, any `died` row, any module-leg row on the
0.2.19 corpus, or any probe DIFF beyond those two.

**3.5 Allowlist lines.** All three clocks move, so every clocked line
reddens: **77** — `version-allowlist.txt` 53 (41 wolf, 12 lupin),
`stamp-allowlist.txt` 6 (4 wolf, 2 lupin), `count-allowlist.txt` 18 (9 wolf,
5 lupin, 4 book). The 62 `frozen` version entries and the `counted=0` count
entries carry no clock. Predicted to **arrive**: `v0.2.19` where 0.2.19's
paragraphs become history (front page, `/spec/`, `/install/`, `/play/`),
`v0.2.20` where its two-phase arguments are told (front page, `/spec/`), and
`0.1.42` on `/install/` and `/play/` where the narrowing is told as history.
Predicted to **leave**: none. *Falsified by* the audits reddening on any
number of clocked lines but 77; the arrivals are the part I expect to get
wrong.

**3.6 Sentences false at the new stamps (re-read, rewritten).**
- front page: "The release this page advertises" told 0.2.19 (element claims,
  EG2); 0.2.21's story leads — `match` over a fallible value (#21), `?` under
  a defer refused (E0611, #19), a block's `errdefer` on its own error value
  (#20), the literal at an unannotated binding is `i32` (#458) — then
  v0.2.20's (two-phase arguments, #17; EG3 for one call), then v0.2.19's as
  history.
- `/spec/`: the two bound `v__WOLF_VERSION__` sentences. 01's
  `grammar/1` sentence stands (grammar byte-identical); 02's "carries the
  distinct places from moves to claims" becomes `v0.2.19`'s, and 02/10 gain
  the 0.2.20/0.2.21 clauses (`[mem.tier0.excl.4]`, `[type.row.else]`,
  `[type.row.match]`, `[type.row.defer]`).
- `/install/` and `/play/`: the lag paragraphs ("re-pinned on the v0.2.18
  tag", "At v0.2.18's pin … v0.2.16's text") move to the v0.2.20 tag and keep
  0.2.19's narrowing as history; the "newest programs" paragraphs describe
  0.2.21's arrivals; **"none of them answers a refusal where the compiler
  runs the program" becomes false** and the page names
  `rows/eu_bind_empty_row_handled.lu` and wolf-interp#176 by name, and the
  decline `memory/nested_fn_mut_param.lu` as a decline.
- `/install/` doors: "read live at this bump, the two channels agree" stays
  true (the table above).

**3.7 /play/'s refused list after the bump: exactly one program,**
`rows/eu_bind_empty_row_handled.lu`, `fail(E0801)`, wolf-interp#176 (fixed on
wolf-interp trunk by is69 `6135d4d`, unreleased). Not worked around.

**3.8 Stamps other than the distance:** `bookchapters` 33, `diagnostics`
**144**, `warnings` 34, `netprograms` 18, `samples` 36. `check-ahead`:
0 ahead, **546** anchors. The `/reading/` readings stand (chapters 13, 21,
25, 29 untouched by bs56–bs58); §13.1's bench table leads with the slower
row.

**3.9 The menu.** `check-samples.mjs`: 36 programs, every one in class.

**3.10 The PDF.** 5.6 MB ± 0.2 MB on kasumi.

**3.11 wolf-boot.js versioned.** `scripts/version-book-assets.py` drops its
one exemption; every same-origin `.js`/`.css` reference in `dist/book/`
carries `?v=fba6210`, **0 bare**, about **569** references (ww35's 522 plus
the 47 `wolf-boot.js` it left bare). `tests/book-assets.test.mjs` is turned
first: its two wolf-boot cases go red against trunk's script (seen red,
recorded with a path) before the script changes. *Falsified by* any bare
reference, or a count off ww35's sum without a render change to explain it.

**3.12 The staged gate (nomad-1, kasumi's built `dist/book` served by
wolf-book `fba6210a`'s `tests/contents/serve.mjs` under the site's CSP,
`--unversioned` because the dist is already versioned):** the full gate
**2,205 clicks, 0 faults** on each of three engines × two viewports
(Firefox and WebKit report 304s, which bs56's gate counts as landings); the
two misses draw the 45-entry sidebar; `--retry` from `ch07.html` **hop 1
90/90, hop 2 90/90, 0 404s** on all six. *Falsified by* any status, title,
number, entries, state or search fault.

**3.13 The deploy.** The orchestrator's fast-forward of trunk to this head
starts `ci.yml` on push; its `deploy to lupp.us` job runs `ci-deploy.sh` on
almanta (python check, `deploy.sh`, full build there) and prints
`✓ Deployed <stamp>`. *Predicted:* the job green, the live `version.json` =
3.2, 63 of 63 pages at 200, the book's pages loading
`wolf-boot.js?v=fba6210`.

**3.14 The live gate, after the deploy (nomad-1, three engines, two
viewports):** the full gate against `https://lupp.us/book/` — **2,205
clicks per cell, 0 status / title / number / entries / state / search
faults**; `--retry` from `ch07.html`: **hop 1 90/90, hop 2 90/90 on all six,
0 `HTTP 404` lines**. Playwright click timeouts over the public internet
(bs56 saw three on WebKit) are reported as `click` faults with their lines,
never rerun away. *Falsified by* any 404 on a real page or any wrong landing.

**What I expect to get wrong:** the allowlist arrivals (their count depends
on how the rewrites spell their history); the module leg on the 0.2.19
corpus (0.1.43's mirrors are of 0.2.20's arrivals, but I have not measured
the common rows); and WebKit's click timeouts on the live gate.

## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `755194c` (an empty commit), unedited.* Built on kasumi
at `8873a34` (`build-summary-8873a34.txt`, which the staged gate served) and
again at `52b08bb` (`build-summary.txt`; the CHANGELOG's arrival count
corrected, nothing else the build reads moved; every figure identical, the
`built` time aside); later commits touch only `docs/audit/`. The gates'
browsers ran on nomad-1. Files are under
`docs/audit/ww36-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `755194c`, first pin `b923aab`; `git merge-base --is-ancestor 755194c b923aab` exits 0; `755194c` was pushed to origin before any pin |
| three gitlink commits | book `b923aab` (→ `fba6210a`, 4 book count lines), wolf `7269b44` (→ `dfcc2f13`, 9 wolf count lines), lupin `ef38b42` (→ `ba47627`, 5 lupin count lines) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers | `derive.log` (script `ww36-derive.sh`), `arrivals-headers.txt` |
| the guard reddens at the wolf pin | `guard-at-wolf-pin.txt`: the site at `7269b44` against wolf `dfcc2f13` and lupin `8e2516d`: `the gap is 3 and the page does not say so — it must carry the phrase 'three releases'` on both pages, exit 1. Measured on kasumi after the fact: CI never ran `7269b44` alone (it was pushed with `ef38b42`; windows run 37118069861 at `ef38b42` was cancelled by the next push) |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.21 is advertised; lupin was built at the v0.2.20 tag (cdde128) — it reads the release before this one, and both pages carry 'one release' and neither carries another`; `--json`: `{"gap": 1, "phrase": "one release", "tagged": true, "commits": 91, "spec": "cdde128", "release": "0.2.20", "advertised": "0.2.21"}` |
| stamped lag | `speccommits 91`; `ninety-one commits` once on each built page (`build-summary.txt`) |
| allowlists reddened | `version-prose-red.txt`: 53 version lines and 6 stamp entries asked to be re-read at the pins (before any prose edit); the 18 clocked count lines were re-read and re-stamped in the three pin commits |
| census, four legs | `census-02{19,21}-014{2,4}.json`, `rows.txt` (script `ww36-rows.py`), driver `ww36-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.19 / 0.1.42 leg equals ww35's served census (464 / 337 / 33 / 94) |
| stdout probe | `stdout-probe-0144.txt`: 65 MATCH, 3 n/a (the two `trap(assert)` rows and `mut_read_overlap.lu`, whose header names no stdout), 3 DIFF (the #176 refusal, the two declines); `stdout-probe-0142.txt`: 27 DIFF under the deployed interpreter |
| modules | `lupin-0.1.44.wasm` sha256 `68a400b5…` = the served `dist/play/lupin.wasm` (`build-summary.txt`); 0.1.42 control `b92af77f…` (built here; ww35's `d921d279…` differs, the module embeds its build path, as ww34's `path-control.txt` found) |
| wolf-boot.js versioned, red first | `book-assets-wolfboot-red.txt`: `tests/book-assets.test.mjs` at `08b4745` against trunk's script, 3 pass 2 fail; fixed `2a9c1ef`; build: `569 … versioned ?v=fba6210; nothing exempt`, 0 bare, `wolf-boot.js?v=fba6210` on 47 pages |
| staged gate | `gate-staged.txt` / `.json.gz`: 2,205 clicks and 0 faults on all six engine × viewport cells; retry hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| audits, links, tests, menu, ahead | `build-summary.txt`: build exit 0; node tests 114 / 114; links 1,507 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 546 anchors; planted 8 pass |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| pages dry / book | 63 / 48 | 63 / 48 |
| versions, `version.json` | 0.2.21, 0.1.44; `dfcc2f1` `ba47627` `fba6210`, spec-pin `cdde128`, missing [] | identical (built) |
| guard JSON | gap 1, one release, tagged, 91, `cdde128`, 0.2.20, 0.2.21 | identical |
| guard at the wolf pin | gap 3, three releases | gap 3, three releases, both pages (`guard-at-wolf-pin.txt`) |
| census programs / exit / trap / unsupported / fail / candidates / died | 533 / 402 / 35 / 95 / 1 / 437 / 0 | 533 / **401** / 35 / **96** / 1 / **436** / 0 |
| arrivals | 65 exit, 2 trap, 1 unsupported, 1 fail | **64** exit, 2 trap, **2** unsupported, 1 fail — `memory/versioned_loop_cross_module/main.lu` is a sibling-files program, which this build declines (its header says `exit=0` at a terminal); I read headers and missed the directory |
| module leg on the 0.2.19 corpus | 0 rows | 0 rows |
| corpus legs, common rows | 0 | 0 under either module |
| the #176 refusal | `fail(E0801)` | `fail(E0801)` (0.1.42 ran it, `exit(0)`) |
| stdout probe | 67 MATCH, 2 n/a, 2 DIFF | **65** MATCH, **3** n/a, **3** DIFF (the cross-module decline; `mut_read_overlap.lu` names no stdout) |
| clocked allowlist lines | 77 (53 / 6 / 18) | 77 (53 / 6 / 18) |
| arrivals / leaves | `v0.2.19` on 4 pages, `v0.2.20` on index and spec, `0.1.42` on install and play; 0 leave | 11 arrive: `v0.2.19` on index (1), spec (1), install (3), play (2); `v0.2.20` on index (2), spec (2), install (1), play (1); `0.1.42` on install and play; `0.1.43` on install. **1 leaves**: play's `0.2.18`; four counts fall (install `v0.2.16` 4→3, `v0.2.18` 5→4; play `v0.2.16` 3→2, `v0.2.18` 4→3) |
| bound placeholders | — | install `__LUPIN_VERSION__` 5→6 (bound 1→2: the #176 sentence), spec `__WOLF_VERSION__` 2→3 (bound 3) |
| stamps | 33 / 144 / 34 / 18 / 36; 546 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 5.6 ± 0.2 MB | 5.7 MB (5,657,062 B on kasumi) |
| book assets | ~569 versioned, 0 bare | 569, 0 bare |
| staged gate | 2,205 clicks, 0 faults ×6; retry 90/90 ×2 hops ×6 | identical |

**Found, not predicted.**
1. **Two download sizes on /install/ were typed by hand and stale**: the
   Windows archive "about 11 MB" (0.2.21's is 12,071,285 B) and `lupin.exe`
   "about 5 MB" (0.1.44's is 6,107,648 B; 5,390,848 B at 0.1.30). No audit
   reads a digit followed by `MB`, so nothing would have caught them; both are
   dropped rather than retyped.
2. **Two sentences outside the lag paragraphs were false at the pin**: /play/'s
   "the census behind this page counts no program at all that answers
   differently from the compiler" and /install/'s "nothing the release above
   adds to the corpus parts from the compiler" — both true until #176. Neither
   is clocked; found by reading.
3. **Under the deployed interpreter (0.1.42) the 0.2.21 corpus parts in 27
   outputs and 9 classes** (`stdout-probe-0142.txt`): a site that bumped wolf
   without lupin would have served a tab disagreeing with the compiler on the
   `recv_view_arg_*`, `mut_claim_*` and `match_row_*` rows.

## 5. Done-when

- [x] Branch `ww36` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [ ] The prediction commit precedes the first gitlink commit
      (`git merge-base --is-ancestor <prediction> <first pin>`).
- [ ] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [ ] Stamps at the checkout; the ancestry guard's line and JSON quoted
      verbatim; census table, allowlist diff, probes, page count in §4.
- [ ] `wolf-boot.js` versioned; its test seen red first; the staged gate's
      404 path and ch07 path at 0 faults.
- [ ] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion.
- [ ] After the merge: the deploy job's output, the live gate, the live
      `version.json`.
- [ ] Worktree `/private/tmp/ww36-web` removed; `target/` pruned on kasumi;
      no orphans.
