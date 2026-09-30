# ww35 — The Site at 0.2.19, and the Book's Contents Reach Readers

**Class:** one repo, one bump (three gitlinks), one nginx change, one deploy.
**Opus.** **Wave:** 52. **Written 2026-09-30 by the lane**, from ww34's
contract (`docs/audit/ww34-contract-0218.md`) and wolf-book PR #65 (bs55,
merged at `bd3484e`), with every input re-derived. Deliverables:

1. lupp.us serves wolf 0.2.19, lupin 0.1.42 and the book at `bd3484e`, every
   stamped number derived at the checkout and the lag the ancestry guard
   computes (ww34's steps: version literals, allowlists, clocks).
2. nginx: a miss under `/book/` answers the book's own `/book/404.html` (today
   the site's `/404.html`); the CSP stays exactly as strict — no
   `unsafe-inline`, `base-uri 'none'` kept.
3. The stale-script window closed for the book's unfingerprinted scripts
   (decision and reason in §3.11).
4. Deployed to almanta from this branch; the config staged if its reload needs
   sudo, with the exact command reported.
5. bs55's contents gate run against the LIVE `https://lupp.us/book/` — three
   engines, phone and desktop, second hops included — numbers recorded; the
   maintainer's path from `ch07.html` at 0 404s.

This file is the first commit on branch `ww35`, cut from wolf-web trunk
`19e8b06` with all three gitlinks still at ww34's values. Sections 2 and 3
are written before any gitlink moves; section 4 is filled in afterwards, below
a line that says so.

## 1. Forbidden, absolutely

- **No build on nomad-1** (this Mac). The wasm module, the book render and the
  site build run on kasumi under `~/lanes/ww35/` with `CARGO_BUILD_JOBS=4`.
  nomad-1 runs `git`, `gh`, `curl`, the python audits, `node --test` and the
  Playwright gate from the cached `playwright-core` 1.63.0 — nothing that
  compiles.
- No `rm` outside `~/lanes/ww35/` (kasumi, almanta), `/private/tmp/ww35` and
  this lane's `ww35-*` scratch files; on almanta, only the deploy's own
  release pruning in `/var/www/lupp.us/releases/`. No `git add -A`. No
  `~/.claude/`. No edit to another lane's file; `~/lanes/ww32/` on kasumi is
  read (as a clone reference, dissociated), never touched.
- **No sudo route on almanta.** `espadon` has no passwordless sudo; the nginx
  config is staged and the reload command reported, never attempted another
  way. `/etc/nginx/` and `~/src/wolf-web` (the CI deploy's checkout) are not
  written.
- **No loosening of the CSP**: no `unsafe-inline`, no `base-uri` change, no
  new script source. Every `Content-Security-Policy` line in the config is
  byte-identical to today's.
- **No hand-typed count, version or distance in `site/`.** Every number comes
  from the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No merge, no rebase-merge. No `2>/dev/null` on a checkout.
- No "seen red" without a run id, sha, path or digest in the same paragraph.
- Kill only this lane's own pids, never a pattern or a process group.
- No `gh run watch` without `--interval 60`; every wait prints at least every
  five minutes.
- No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-09-30 UTC, before any gitlink moves)

| input | brief says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | `19e8b061` | `19e8b06189444109ef99353deba4f3023b6a22c5` | `gh api repos/wolffe-lang/wolf-web/commits/trunk` |
| gitlinks at trunk | — | book `dadc38bee9eb…`, wolf-lang `ec56a08f04ff…` (`v0.2.18`), wolf-interp `0cfc0cfc89af…` (`v0.1.41`) | `git ls-tree HEAD upstream/` |
| live `version.json` | — | built `2026-09-29T02:04:37Z`, lupin `0.1.41`, pins `ec56a08` / `0cfc0cf` / `dadc38b`, spec-pin `93a5fe5`, `missing: []` | `curl https://lupp.us/version.json` |
| live release | — | `current -> /var/www/lupp.us/releases/2026-09-29-020406`; five releases kept (oldest `2026-09-15-223322`) | `ssh almanta ls` |
| wolf 0.2.19 | the pin | annotated tag `v0.2.19` (`ba0b43a`) → `c2401f05f37794a078d2acf62f837dad98e5950d`; release 400208356 `draft:false` `prerelease:false`, 4 assets, published 2026-09-30T16:02:58Z; 0 drafts; `releases/latest` = `v0.2.19` | `gh api` |
| lupin 0.1.42 | the pin | annotated tag `v0.1.42` (`4f299fd`) → `8e2516dc47bf808512388cc687e070981d331d98`; release 400022505 `draft:false`, 5 assets, published 2026-09-30T12:28:23Z; 0 drafts; `Cargo.toml` `version = "0.1.42"` | `gh api`; `derive.log` |
| lupin 0.1.42's spec gitlink | re-pinned on v0.2.18 | `upstream` at `8e2516dc` = `ec56a08f04ff…` = `v0.2.18^{commit}` (0.1.41's was `93a5fe5`, v0.2.16) | `gh api contents/upstream?ref=v0.1.42`; `derive.log` |
| book target | `bd3484e` (bs55's merge) | wolf-book trunk `bd3484edd6c3ee38d468167fe04d3f1d7572740f` = PR #65's merge commit (fast-forward, head = merge); `dadc38b` is its ancestor, 26 commits, 43 files | `gh pr view 65`; `derive.log` |
| ancestry and the lag | one release | `merge-base --is-ancestor ec56a08f c2401f05` exits **0**; `rev-list --count ec56a08f..c2401f05` = **105**; `gh api compare` `ahead 105, behind 0`; pinned CHANGELOG headings run `0.2.19`, `0.2.18`, … so the guard's gap = **1** | `derive.log` |
| the book's statement of the pair | — | bs55: "0.2.19 / 0.1.42, 105 commits, one release" (§1.2, colophon) | wolf-book PR #65 |
| doors | "tap and AUR current" | AUR RPC `wolf-lang` / `wolf-lang-bin` 0.2.19-1, `lupin` / `lupin-bin` 0.1.42-1; tap `Formula/wolf.rb` tag `v0.2.19` rev `c2401f05…`, `Formula/lupin.rb` tag `v0.1.42` rev `8e2516dc…`, tap head `6f60a67` | AUR RPC v5; `gh api repos/wolffe-lang/homebrew-wolf` |
| live nginx config | — | `/etc/nginx/conf.d/lupp.us.conf` (root-owned, 2026-08-14) is **byte-identical** to `nginx/lupp.us.conf` at trunk (`diff` empty); nginx 1.20.1 | `ssh almanta cat`; `diff` |
| almanta access | `espadon`, no passwordless sudo | `sudo -n true` → "a password is required"; `/var/www/lupp.us` and its releases owned by `espadon` (content deploy needs no root) | `ssh almanta` |
| live headers | — | `/book/toc.js`: `cache-control: max-age=604800`, `public`, **no** `x-content-type-options`, no CSP; `/book/no-such-page.html`: 404 with the site's `/404.html` (1121 B) and all four security headers | `curl -sI` |
| the book's asset names | `toc.js` unfingerprinted | the live HTML loads `toc.js`, `elasticlunr.min.js`, `mark.min.js`, `searcher.js`, `book.js` and six stylesheets by bare name (`../toc.js` one directory down); bs55 adds `wolf-boot.js`, also bare | `curl …/ch07.html`, `…/front/how-to-read.html`; `theme/index.hbs` at `bd3484e` |

Facts read off the checkouts (kasumi, `docs/audit/ww35-evidence/derive.log`,
script `ww35-derive.sh`): `spec/grammar.ebnf` **byte-identical** across the
bump (`910ff9d5…` both sides); anchors **542 → 542**, none added or dropped;
`## E` 142 → 142, `## W` 34 → 34, `corpus/net/*.lu` 18 → 18. Documents moved:
`spec/02-memory-model.md` (+22 −13) and `docs/diagnostics.md` (3 lines) only.
Corpus: 31 files added, 1 modified (`memory/mut_elem_excl.lu`, typecheck →
run), 0 removed; the `phase: run` set 445 → **464, 19 in, 0 out**; no
pre-existing run program modified. lupin `0cfc0cf..8e2516d`: 59 commits
(is57–is60 and the re-pin). Book `dadc38b..bd3484e`: `book/SUMMARY.md` blob
identical (`c581960`), 33 chapters; chapters touched 01, 05, 07, 08, 22, 28,
31 and back matter; 13, 21, 25 and 29 untouched; theme `index.hbs`, `book.js`
and the new `book/wolf-boot.js`.

**Drift, reported:**

1. **wolf-lang's 0.2.19 CHANGELOG says "Three lanes and 100 commits"; the
   compiler's history carries 105** `ec56a08f..c2401f05` (ww34 found the same
   shape at 0.2.18: 74 written, 80 in history). The site prints only the
   stamped 105.
2. **The `.js`/`.css`/`.wasm` locations drop every security header.** An
   `add_header` inside a `location` replaces the server-level set, so today
   `/book/toc.js` and every site script answer with no `nosniff`, no
   `Referrer-Policy`, no `X-Frame-Options` and no CSP (live headers above).
   Not in the brief; fixed beside deliverable 2 because the book's new
   location needs its own `add_header` and would repeat the defect.
3. **A regex location beats `location /book/`.** nginx takes the regex
   `location ~* \.(js|css|woff2?)$` over a plain prefix match, so an
   `error_page` inside `location /book/` alone would not reach a `/book/*.js`
   miss and would not change `toc.js`'s cache header. The book's location
   becomes `^~ /book/`, with its own nested rules.
4. **ww34 deployed through the merge**, not from its branch: PR #51 merged
   2026-09-29T02:01:24Z and the CI deploy job made release
   `2026-09-29-020406` three minutes later. This lane's PR stays unmerged, so
   the deploy goes out from the branch by hand (§3.13), with the same
   `scripts/deploy.sh`.
5. The main checkout `~/GithubOrgs/wolffe-lang/wolf-web` carries modified
   `upstream/wolf-book` and `upstream/wolf-interp` gitlinks that are not this
   lane's; untouched. This branch lives in the worktree `/private/tmp/ww35`.
6. kasumi `/home` is at **97 %, 37 GB free** (14:31 EDT).

## 3. Prediction, committed before the first gitlink moves

Each item names what falsifies it.

**3.1 Served pages.** **63 dry, 63 live, no URL added or removed**; the book's
web edition stays **48 pages** (SUMMARY.md blob identical). *Falsified by* any
other count.

**3.2 Version strings.** `__WOLF_VERSION__` = **0.2.19**, `__LUPIN_VERSION__`
= **0.1.42**. `version.json`: lupin `0.1.42`, pins `wolf-lang c2401f0`,
`wolf-interp 8e2516d`, `wolf-book bd3484e`, **`spec-pin ec56a08`**,
`missing: []`. *Falsified by* any of these on the built `dist/`, or after the
deploy on the live file.

**3.3 The lag.** `check-lag-phrases.py --json` answers `gap 1`, `phrase "one
release"`, `tagged true`, `commits 105`, `spec "ec56a08"`, `release
"0.2.18"`, `advertised "0.2.19"`. Both pages move **from `two releases` to
`one release`** and carry none of the other three phrases; `a development
revision` stays absent. The stamped distance becomes **`one hundred and
five`** (was `one hundred and fifty-two`). The guard reds on the gitlink
commit that moves wolf-interp and stays red until the two pages are rewritten.
*Falsified by* any other value in the guard's JSON.

**3.4 The census at 0.2.19 / 0.1.42.** Same rule and harness as ww33/ww34
(`docs/audit/ww33-evidence/census.mjs`, unmodified). Baseline is ww34's
committed measurement (`docs/audit/ww34-evidence/census-0218-0141.json`):
445 programs, 319 exit, 33 trap, 93 unsupported, 0 fail, 352 candidates,
0 died.

| class | ww34 (0.2.18 corpus, 0.1.41 module) | ww35 predicted | delta |
|---|---|---|---|
| programs | 445 | **464** | +19 |
| `exit` | 319 | **337** | +18 |
| `trap` | 33 | **33** | 0 |
| `unsupported` | 93 | **94** | +1 |
| `fail` | 0 | **0** | 0 |
| candidates (`exit` + `trap`) | 352 | **370** | +18 |
| kills the instance | 0 | **0** | 0 |

Reasoning. The 19 arrivals: eleven `elem_const_*`, `mut_elem_excl.lu` and
`mut_two_fields_one_region.lu` state lupin 0.1.41's bytes in their headers;
`elem_header_methods_after_move{,_map}.lu` say lupin 0.1.40 and 0.1.41 run
them; `elem_header_methods_under_claim.lu`, `elem_member_read_after_mut.lu`
and `elem_member_read_under_claims.lu` trap under 0.1.41 and are the rows
0.1.42 mirrors (is59/is60) → **18 `exit`**; `elem_header_methods_after_move_pool.lu`
("lupin declines `Pool` by name") → **1 `unsupported`**. No pre-existing row
changes class.

The four legs: **module move on the 0.2.18 corpus (0.1.41 → 0.1.42): 0 rows
change class or verdict** (#143–#146, #149, #151, #152 are traps on shapes the
compiler refuses, which the run set does not carry). **Corpus move under
0.1.41: the three claim rows above arrive as `trap`** (15 exit, 3 trap,
1 unsupported among the arrivals); **under 0.1.42 all three `exit`**; 0 common
rows move under either module.

**Output, not class (the stdout probe):** all **18 `exit` arrivals print their
header's stdout under 0.1.42**, and **`ctl_store_order_nested_index.lu` now
matches too** — ww34's one parting (#145, each index operand run twice) closes
at 0.1.42 (wolf-lang's 0.2.19 entry: "whose lupin stdout is now the
compiler's"). So the pages go from **one program parting in output to none**.
*Falsified by* any class count other than the table's, any `fail` or died row,
any module-leg row on the 0.2.18 corpus, or a probe mismatch among those 19.

**3.5 Allowlist lines.** All three clocks move, so every clocked line reddens:
**70** — `version-allowlist.txt` 46 (36 wolf, 10 lupin), `stamp-allowlist.txt`
6 (4 wolf, 2 lupin), `count-allowlist.txt` 18 (9 wolf, 5 lupin, 4 book). The
60 `frozen` version entries and the `counted=0` count entries carry no clock.
Predicted to **arrive**: `v0.2.18` literals where 0.2.18's paragraphs become
history (front page, `/spec/` 02, `/install/`, `/play/`); `0.1.41` on
`/play/` and `/install/` where the #145 parting is told as history. Predicted
to **leave**: none. *Falsified by* the audits reddening on any number of
clocked lines but 70.

**3.6 Sentences false at the new stamps.**
- front page: 0.2.18's release paragraphs (#460/#464 refused first, element
  places, R3, index first) become v0.2.18's history; 0.2.19's story leads:
  EG2 element-granular claims, #470 (a release-tier ICE in 0.2.18), 1(c)
  under a claim, header reads.
- `/spec/`: the two bound `v__WOLF_VERSION__` sentences (01's grammar/1 stays
  stamped — the grammar is byte-identical; 02's element-place sentence becomes
  `v0.2.18` and 02 gains 0.2.19's: claims per element, 1(c) under a claim,
  the header reads).
- `/install/` and `/play/`: every "two releases", "tagged twice since", the
  #145 parting ("open at this interpreter", "the only program that parts")
  and every relative pin reference re-read; the parting sentences become
  history naming 0.1.41; the lag paragraphs name v0.2.18 as the spec pin.
- `/install/` doors: agree (the table above).

**3.7 Stamps other than the distance:** `bookchapters` 33, `diagnostics` 142,
`warnings` 34, `netprograms` 18, `samples` 36. The four `/reading/` readings
stand (chapters 13, 21, 25, 29 untouched by bs55); §13.1's bench row stands.

**3.8 The #128 / B57 regression probe.** `grammar/range_header_inclusive_max.lu`
and `grammar/range_value_wide_iter.lu` under 0.1.42 **exit 0** with their
header's stdout; the instance does not die.

**3.9 The menu.** `check-samples.mjs`: 36 programs, every one in class.

**3.10 The PDF.** 5.6 MB ± 0.1 MB on kasumi.

**3.11 The stale-script window — decision: fingerprint in the build, and
`no-cache` under `/book/` in nginx.**
- *Why fingerprint:* the readers bs55 worries about already hold a `toc.js`
  cached with `max-age=604800` from the 2026-09-29 release. No header this
  deploy sends can reach a copy the browser will not ask about again; only a
  new URL can. `build.sh` appends `?v=<book pin>` (seven hex, `bd3484e`) to
  every same-origin `.js` and `.css` reference in `dist/book/**/*.html`, so
  the first page a returning reader loads fetches the new `toc.js`. It lands
  with the static files and needs no sudo. Any later book pin is a new URL.
- *Why also `no-cache`:* scripts the book loads by name at run time
  (`searchindex.js` via `path_to_root`) and the HTML itself (no explicit
  header today, so browsers cache it heuristically from `Last-Modified`) are
  not reachable by a build-time rewrite. `Cache-Control: no-cache` under
  `/book/` makes every one revalidate (`ETag`/`Last-Modified` answer 304
  when nothing changed).
- *Predicted:* **every** local `.js`/`.css` reference in the book's HTML
  carries `?v=bd3484e` and **0 remain bare**; the rewrite refuses to report
  zero (a zero is believed only when the search fires). On the staged config:
  `/book/toc.js` answers `cache-control: no-cache` with all four security
  headers; site scripts keep 7 days and gain the four headers.
  *Falsified by* any bare local `.js`/`.css` reference in `dist/book/`, or
  any header other than those.

**3.12 nginx behaviour (staged config, served by almanta's own nginx 1.20.1
unprivileged on a loopback port, TLS lines removed, nothing else changed):**
`/book/no-such-page.html` and `/book/front/no-such-page.html` → **404 with
the book's `404.html`** (a sidebar of 45 entries); `/book/nope.js` → 404 with
the book's page; `/no-such-page` → 404 with the site's `/404.html`; `/book` →
301 to `/book/`; every response's CSP byte-identical to today's. The contents
gate against that server: **2,205 clicks, 2,205 at 200, 0 faults** on each of
three engines × two viewports. *Falsified by* any other status or body, or any
fault.

**3.13 The deploy.** dist built on kasumi at the branch head, copied to
almanta and shipped with `SKIP_BUILD=1 ./scripts/deploy.sh` from a checkout of
this branch under `~/lanes/ww35/` — the script's own release directory,
`current` flip, `version.json` and PDF checks, and rollback. The config is
staged, not installed: `sudo` needs a password, so the maintainer's command is
reported. *Predicted:* the deploy prints `✓ Deployed`, the live
`version.json` equals §3.2, 63/63 pages answer 200.

**3.14 The live gate, after the deploy.** The maintainer's path
(`--retry`, from `https://lupp.us/book/ch07.html`, untoggled and toggled, each
first hop followed by a second click): **before** the deploy it repeats bs55's
`retry-live.txt` — hop 1 90/90 at 200 with **16** number mismatches, hop 2
**66/90** — and **after** it **hop 1 90/90, 0 mismatches, hop 2 90/90**, on
all six engine × viewport pairs. **0 404s.** The full gate against live:
- **before the maintainer reloads nginx** (files new, config old): every
  click from the 47 real pages lands — **2,115 clicks, 2,115 at 200** — and
  the two misses fail by design, because the site's `/404.html` draws no
  sidebar: `entries` 2 and `state` 6 per engine × viewport, nothing else;
- **after the reload:** **2,205 clicks, 2,205 at 200, 0 faults** on all six.

*Falsified by* any 404 on the maintainer's path, any title or number fault on
a real page, or a count other than these.

**What I expect to get wrong:** the allowlist arrivals (their count depends on
how the rewrites spell their history); whether the heuristic HTML cache or a
`fonts/` stylesheet reference escapes the rewrite; and the live gate's
timings — a click bounded at 60 s over the public internet may time out where
the loopback run did not (that would be a `click` fault, and it would be
reported as one, not rerun away).

## 4. Evidence index

*Filled in after the measurement; nothing above this line is edited after the
prediction commit except to append.*

Measured on kasumi at branch head `a494fe8` (the last change the build reads;
later commits touch only this file and `docs/audit/ww35-evidence/`); deployed
from that head; the gate run on nomad-1. Files below are under
`docs/audit/ww35-evidence/`; `summary.txt` gathers every figure with its file.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction commit `4c9b225`; first pin commit `3841f19`; `git merge-base --is-ancestor 4c9b225 3841f19` exits 0 |
| three gitlink commits | book `3841f19` (→ `bd3484e`), wolf `3cb9c6a` (→ `c2401f05`), lupin `48afadf` (→ `8e2516d`) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers | `derive.log` (script `ww35-derive.sh`) |
| book readings at `bd3484e` | `book.log` |
| the guard reddens on the pins, then holds | windows run 36760054806 at `48afadf`: step "the specification pin lag the site records" FAILED, `the gap is 1 and the page does not say so` on both pages; green from `6f7d976` on |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.19 is advertised; lupin was built at the v0.2.18 tag (ec56a08) — it reads the release before this one, and both pages carry 'one release' and neither carries another`; `--json`: `{"gap": 1, "phrase": "one release", "tagged": true, "commits": 105, "spec": "ec56a08", "release": "0.2.18", "advertised": "0.2.19"}` |
| stamped lag | `speccommits 105`; `one hundred and five commits` once on each built page (`build-summary.txt`) |
| census, four legs | `census-02{18,19}-014{1,2}.json`, `rows.txt` (script `ww35-rows.py`), driver `ww35-measure.sh`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.18/0.1.41 control is row-identical to ww34's `census-0218-0141.json` (445 rows, 0 diffs) |
| arrivals print their headers' stdout; #145 closed | `stdout-probe-0142.txt`: 21 MATCH of 22 (19 arrivals, 2 range probes, `ctl_store_order_nested_index.lu`), the 1 DIFF the `Pool` row's decline; `stdout-probe-0141.txt`: 5 DIFF (the decline, the three claim traps, #145's doubled `i`) |
| #128 / B57 probe | `stdout-probe-0142.txt`: both range programs `exit(0)` MATCH; `rows.txt`: `died rows: []` |
| modules | 0.1.42 sha256 `d921d279…` = the served `dist/play/lupin.wasm`; 0.1.41 control `64d3ed51…` (ww34's `d4e28724…`; the module embeds its build path — ww34's `path-control.txt`) |
| audits, links, tests, menu, ahead gate | `build-summary.txt`: version prose / counts / lag exit 0; 1504 internal links across 63 pages, 0 dead; node tests 114 pass 0 fail; ahead planted 8 pass; check-samples 36 in class; check-ahead 0 ahead, 542 anchors |
| allowlist cost | `3cb9c6a` (9 wolf count lines), `3841f19` (4 book), `e200cc9` (46 version + 6 stamp + 5 lupin count = 57, 8 literals in, 1 out), `6f7d976` (5 CHANGELOG literals) |
| nginx gate seen red | `nginx-test-red.txt`: `tests/nginx.test.mjs` on trunk's config (= almanta's installed file) 2 pass 3 fail; test commit `c5c3432` precedes the config commit `0044e5a` |
| asset-versioning gates seen red | `book-assets-planted.txt` (planted regex, 1 of 4 fail); `book-assets-wolfboot-red.txt` (the `fb51e6a` script against the wolf-boot cases, 2 of 5 fail) |
| the staged gate caught a regression before any deploy | `gate-staged-wolfboot-red.txt`: the `6f7d976` build, `wolf-boot.js?v=…`, chromium phone `2205 clicks, 1620 at 200 — FAIL {"status":585…}` (`front/how-to-read.html -> "1. Hello, Wolf": HTTP 404 /book/front/ch01.html`); fixed `d5c9a9b`; filed wolf-book#66 |
| staged config behaves | `staged-headers.txt` (script `ww35-stage-nginx.sh`; almanta nginx 1.20.1, loopback): three `/book/` misses 404 with the book's page (5,667 B), `/no-such-page` the site's (1,121 B), `/book` 301, book files `no-cache`, site scripts 7 days, the same CSP line on 12 of 12 responses; `nginx.diff`; staged file sha256 `2c6f09d1…`, installed `b087dba7…` (trunk's) |
| deploy | `deploy.log`: `✓ Deployed 2026-09-30-191146`, `current -> …/2026-09-30-191146`, from `a494fe8` with `SKIP_BUILD=1`; `live-after-deploy.txt`: live `version.json` = the built one, 63 of 63 `.html` at 200, the book's pages load `toc.js?v=bd3484e` |
| the maintainer's path, live | `retry-live-before.txt` (144 `HTTP 404` lines; hop 2 66/90 ×6) and `retry-live-after.txt` (0 `HTTP 404`; hop 1 90/90, 0 mismatches, hop 2 90/90 ×6) |
| full gate, live | `gate-live-prereload.txt` / `.json`; classified by `ww35-faults.py` |
| full gate, staged config | `gate-staged.txt` / `.json.gz`; classified by `ww35-faults.py` |
| the 304 class | wolf-book#67 filed; every 304 in both records on the right title and number (`ww35-faults.py`) |
| CI at head | recorded in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| pages dry / live / book | 63 / 63 / 48 | 63 / 63 / 48 |
| versions, `version.json` | 0.2.19, 0.1.42; `c2401f0` `8e2516d` `bd3484e`, spec-pin `ec56a08`, missing [] | identical (built and live) |
| guard | gap 1, "one release", tagged, 105, `ec56a08`, 0.2.18, 0.2.19 | identical |
| where the guard reddens | on the commit that moves wolf-interp | **already on the wolf pin** (`3cb9c6a`: gap 3, "three releases") and on the lupin pin (gap 1, pages "two releases"); CI saw only `48afadf`, the pushed head |
| census programs / exit / trap / unsupported / fail / candidates / died | 464 / 337 / 33 / 94 / 0 / 370 / 0 | 464 / 337 / 33 / 94 / 0 / 370 / 0 |
| module leg on the 0.2.18 corpus | 0 rows | 0 rows |
| arrivals under 0.1.41 | 15 exit, 3 trap, 1 unsupported | 15 / 3 / 1 (census-0219-0141: 334 / 36 / 94) |
| stdout | 18 arrivals + #145's program match | identical |
| clocked allowlist lines | 70 (46 / 6 / 18) | 70 (46 / 6 / 18) |
| arrivals / leaves | `v0.2.18` on 4 pages, `0.1.41` on play and install; 0 leave | 8 arrive: `v0.2.18` on index (4), spec (1), install (5), play (4); `0.2.18` on install and play; `0.1.41` on install (2), play (3); **1 leaves**: install's `v0.2.17` |
| stamps | 33 / 142 / 34 / 18 / 36 | identical |
| #128 probe | exit 0 | exit 0, stdout matches, no death |
| menu | 36 in class | 36 in class |
| PDF | 5.6 MB ± 0.1 | 5.6 MB (5,616,740 B) |
| book assets | every local ref versioned, 0 bare | **wrong at first**: versioning `wolf-boot.js` broke the root it reads from its own src (585 404s staged); now 522 versioned, `wolf-boot.js` bare by design (47), 0 other bare |
| staged nginx statuses | as §3.12 | as §3.12 |
| staged gate | 2,205 / 2,205 at 200, 0 faults ×6 | **chromium** exact; **firefox and webkit** land every click on the right page but report **HTTP 304** for most (firefox 2042 / 2038, webkit 1818 / 1817): under `no-cache` they revalidate and surface the 304 as the navigation's status; 0 404, 0 title, 0 number, 0 entries, 0 state, 0 search, 0 click on all six |
| deploy | `✓ Deployed`, live `version.json` §3.2, 63/63 | identical |
| maintainer's path before | hop 1 90/90, 16 mismatches, hop 2 66/90 | identical ×6 |
| maintainer's path after | 90/90, 0, 90/90, 0 404s | identical ×6, 0 404s |
| live gate before the reload | 2,115 / 2,115 at 200; entries 2, state 6, nothing else | entries 2 / state 6 exact ×6; chromium ×2 and firefox desktop exact; **firefox phone** 139 at 304 (right page); **webkit phone** 3 at 304 (right page) and 1 click timeout; **webkit desktop** 2 `page.goto` timeouts on `back/solutions.html` — reported, not rerun; 0 404s on any real page |

**Found, not predicted.**
1. **`wolf-boot.js` reads its own `src`** to set `path_to_root`, so any query
   string on it empties the root — the maintainer's 404, reintroduced by a
   cache-busting change. The staged gate saw it before the deploy; filed
   wolf-book#66 (the book could strip a query).
2. **A revalidated landing is a gate fault.** The contents gate demands 200;
   Firefox and WebKit report 304 when they revalidate, which `no-cache` makes
   routine and heuristic caching makes occasional (live today: 139 and 3).
   Every 304 in both records lands on the right title and number. Filed
   wolf-book#67; until it lands, a Firefox or WebKit run against lupp.us
   with the new config reads red on correct landings.
3. **The script, style and wasm locations sent no security headers** (drift 2),
   now repeated in every header-setting location and held by
   `tests/nginx.test.mjs`.
4. The book ships one `.md` file (`fonts/LICENSE-SourceCodePro.md`, linked
   from nowhere); under `^~ /book/` it is typed by the http default rather
   than the site's `text/plain` rule.

**The one command the maintainer runs** (almanta; `espadon` has no
passwordless sudo). The staged file is this branch's `nginx/lupp.us.conf`,
sha256 `2c6f09d1…`:

```
sudo cp /home/espadon/lanes/ww35/web/nginx/lupp.us.conf /etc/nginx/conf.d/lupp.us.conf && sudo restorecon -v /etc/nginx/conf.d/lupp.us.conf && sudo nginx -t && sudo systemctl reload nginx
```

Until it runs, lupp.us serves the new book and site (the Contents links and
the maintainer's path are fixed now, by the book's own files) under the old
config: a `/book/` miss gets the site's 404 page, and the book's HTML is
cached heuristically. The versioned references already reach readers holding
the old `toc.js`.

## 5. Done-when

- [ ] Branch `ww35` on origin; PR open, **unmerged**, body carries these five
      sections.
- [ ] The prediction commit precedes the first gitlink commit
      (`git merge-base --is-ancestor <prediction> <first pin>`).
- [ ] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [ ] Every gate green in the kasumi build at the head; CI green at the head
      sha (`gh run view`), waited to completion.
- [ ] The ancestry guard's line and JSON quoted verbatim; census table,
      allowlist count, probes, page count in §4.
- [ ] nginx: `/book/` misses answer the book's 404, CSP lines byte-identical,
      book scripts `no-cache`; a node test holds each; the config staged on
      almanta and served there unprivileged for the gate.
- [ ] Deployed; the live sha and `version.json` recorded; the live gate and
      the maintainer's path recorded with their numbers.
- [ ] CHANGELOG entry in D65's shape.
- [ ] kasumi build dirs pruned once evidence is written; no orphans; the
      worktree `/private/tmp/ww35` removed at the close (after the merge).
