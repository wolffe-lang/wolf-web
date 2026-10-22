# ww46 — The Site at 0.2.34

Class: one repo, one bump (three gitlinks, all three moving), one deploy.
Crawl 54. Contract: the planning repo's sprints/web/ww46-the-site-at-0234.md
(planning 471e794, read 2026-10-22), which keeps every rule of ww45's and
ww44's, and sprints/RULES.md. One deliverable: lupp.us serves wolf 0.2.34,
lupin 0.1.55 and the book at wolf-book f1fd824 (bs70), every stamped number
derived at the checkout. The lane was begun by two Codex agents (GPT-6.1-Sol)
whose connection kept dropping; they left the prediction, the three pins, the
word stamper and its tests, and the first measurements, and the lane was
finished from that branch state (Opus). Sections 1 and 2 below are written
from the contract and the derivation; section 3 is the prediction commit
`51807c4` (an empty commit) quoted verbatim, pushed before the first pin.

Rulings answered before the pages were written:
- **R-ww46-1** the published lupin 0.1.55 resolves none of 0.2.34's seven
  names (the contract's line that six resolve was wrong; they resolve only on
  wolf-interp trunk, unreleased): /play/ shows the lag as measured.
- **R-ww46-2** the word stamper (`scripts/stamp-counts.py`'s `word()`,
  ceiling 999) extended through 999,999 in the site's spelling, with boundary
  tests (999, 1,000, 1,067, 999,999 and the first refused value), its pre-fix
  failure planted in the PR's gate beside the lag-phrase plant, seen red and
  reverted. The one deviation from ww45's shape.
- **R-ww46-3** wolf-web is not tiered: no `full-matrix` label; the PR's CI run
  and the windows push workflow green at the final head are the merge
  evidence.

Asked by this lane, implemented as recommended:
- **R-ww46-4** /play/'s "Eight tiers report unsupported here that work when
  you run lupin at a terminal" rides the lupin clock and was false at 0.1.55
  for two of the eight: `os_signal_listen` (lupin 0.1.55's wasm build declines
  it with the process and signal tier, and at a terminal it is refused by
  name, "arms a signal's trampoline, which is `sigaction`") and `os_random`
  (lupin resolves it in no build: "does not resolve" in the tab and at a
  terminal). Recommendation, built: "Six tiers", and one sentence naming the
  two. The listen's half moved at this pin; the `os_random` half was already
  false (lupin has never carried the name: `git log -S os_random` over
  wolf-interp's sources finds nothing).

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests ran on kasumi under
  ~/lanes/ww46/. nomad-1 ran git, gh, curl, ssh/scp and the browser gates.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww46/bin/; the three engines are the ones playwright-core
  1.63.0 already had cached on nomad-1.
- No rm outside ~/lanes/ww46/ (both hosts) and this lane's worktree. No
  `git add -A`. Nothing under ~/.claude. No edit to another lane's file.
- No hand-typed count, version or distance in site/: every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists. The lag phrase is the guard's, the distance is the
  `speccommits` stamp.
- No deploy, before the merge or after it. PR open, unmerged; the
  orchestrator audits and fast-forwards; the deploy is that push run's
  "deploy to lupp.us" job (sprints/HOSTING.md). No ssh to almanta, no
  deploy script, no nginx, no tunnel, no ~/.cloudflared, no DNS, no host port
  8080 or 8088. Preview servers bound 127.0.0.1:8754 and :8755, stopped by
  recorded pid.
- The site describes the RELEASED toolchain: wolf 0.2.34, lupin 0.1.55 and
  the std the archive bundles (wolf-std e036bec, 58 files). Nothing from
  wolf-std past e036bec (sc69's wrappers at 3bacc5f), wolf-lang trunk or
  wolf-interp trunk (where #268 and #269 closed after 0.1.55) is shown as
  available.
- RULES.md §5: every terminal run of §34.7's and §34.8's programs (forks, a
  resize raised at itself) and of ww45's §34.6 probes (a SEGV sent to itself,
  a child ending itself by a signal) ran inside its own pid namespace on
  kasumi (`unshare --user --map-current-user --pid --fork --mount-proc`),
  RLIMIT_CORE 0, SigBlk/SigIgn printed first (both 0: the jobs were launched
  with `setsid -f`). The corpus's net programs ran in a namespace with its
  own network, loopback only.
- No merge, tag, issue filed or closed, cancelled run of another lane. The
  branch is asserted before every commit. No attribution trailer.
- Plants per RULES.md §7: the smallest run that shows the plant red, here the
  PR's own CI run and the windows learner path's push run beside it.

## 2. Inputs, verified (re-derived 2026-10-22 01:11 - 01:55 UTC, before any page was rewritten)

Scripts ww46-derive.sh (derive.log), ww46-archives.sh (release-assets.txt),
ww46-wasm-control.sh (wasm-control.txt), kasumi ~/lanes/ww46/, landing under
docs/audit/ww46-evidence/; release facts and the live site read with gh and
curl on nomad-1 (live-headers.txt, live-version.json, aur-live.txt).

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | 0a5306a (ww45) | 0a5306a9… | git |
| gitlinks at trunk | 0.2.33 / 0.1.54 / 3ac6fa9 | wolf-lang 85dab5d7… (v0.2.33), wolf-interp 0e536e8f… (v0.1.54), book 3ac6fa94… | git submodule status |
| live site | serves 0.2.33 / 0.1.54 / 3ac6fa9 | HTTP/2 200, nginx/1.20.1, CSP default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; …; version.json built 2026-10-20T00:40:24Z, lupin 0.1.54, pins 85dab5d / 0e536e8 / 3ac6fa9, spec-pin 294d626, missing []; /play/lupin.wasm bf9877a5… | curl |
| wolf 0.2.34 | v0.2.34 at 9da7bdcf, release 419552903 | annotated tag object 38ab81cb… -> 9da7bdcf2aea… read twice; release 419552903, 4 archives, published 2026-10-21T12:58:10Z; wolf-lang trunk 0477ce62 is past it | gh api; derive.log |
| lupin 0.1.55 | v0.1.55 at e642f26, release 418932753 | v0.1.55 -> e642f2630ad4… read twice; release 418932753, published 2026-10-20T22:11:27Z, 5 assets; Cargo.toml 0.1.55; interp trunk 4c9e6159 is past it | derive.log |
| archives by digest, each read twice | x86-64 88a9dd3d…, aarch64 ca5cadf9…, macOS 29c8331f…, windows 77bb8403…; lupin linux x86-64 1152abc0… | all four wolf archives and all five lupin assets downloaded twice, both reads equal to GitHub's digest (ARCHIVES-FAIL=0), the five named digests exactly; `wolf 0.2.34 (wolfgang, pin 9da7bdc)` / `paired with lupin 0.1.55 (reference interpreter), pin 294d626`; `lupin 0.1.55 (wolf-interp, reference interpreter at pin 294d626)` | release-assets.txt |
| the archive's std/ and the book's manifest | e036bec, 58 files, manifest 5d6253b6…; mirror the book's CI staging step | all four archives hold std/: 58 files (54 .lu), manifest 5d6253b6… by wolf-book f1fd824's own recipe (book.yml names the same), STD-REV e036bec3…; the staging step mirrored on kasumi (wolf-std at v0.2.34's STD-PIN, autocrlf off, the licences and STD-REV): the same manifest, diff -r against the linux archive's std/ IDENTICAL | release-assets.txt |
| does the site build run a wolf? | any wolf the site builds needs std/ beside it | no: at f1fd824 `xtask render` runs typst (render.rs:522) and git (highlight.rs:346) only; the one wolf this lane ran is the published linux archive's, std/ beside it as the archive places it | derive.log |
| lupin's spec gitlink | — | 294d626d = v0.2.24, unchanged | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of 9da7bdcf (exit 0); rev-list --count 294d626d..9da7bdcf = 1067; 85dab5d7..9da7bdcf = 112; CHANGELOG heads 0.2.34 … 0.2.25 above 0.2.24, so the counted gap = 10 | derive.log |
| book target | f1fd824 (bs70) | wolf-book trunk f1fd8247…; 3ac6fa94 an ancestor, 40 commits; SUMMARY byte-identical (404c8c4b), 34 chapters; book/ changes: ch01, ch22, ch34 (new §34.7 A child that keeps running, §34.8 What an editor asks of the host), back/colophon, back/solutions; book/diagrams untouched | derive.log |
| ch01's windows block | names wolf-0.2.34-x86_64-pc-windows-msvc | book/ch01.md:237-238 at f1fd824 do; /install/ stamps the same name from the wolf version stamp | derive.log |
| the seven 0.2.34 names in lupin 0.1.55 | (contract: six resolve) | none resolves (R-ww46-1): each answers `` `<name>` does not resolve `` through the 0.1.55 module and at a terminal | builtins-*.txt, native-0234.txt |
| corpus | — | phase:run set 683 -> 683, 0 in, 0 out; os/term_editor_rows.lu modified (its bit-5 row moved out: s248 made bits 5–7 fields); anchors 664 -> 672 (os.clock.ns, os.editor.calls.note, os.fs.realpath, os.fs.sync, os.proc.fork, os.proc.fork.note, os.signal.wait.fds, os.term.restore), 0 dropped; grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18 unchanged; docs/platforms.md, docs/ and demo/ unchanged; spec 02 (version stamps only), 11, anchors.json, prelude.json changed | derive.log |
| linux aarch64 at 0.2.34 | — | release run 39602781235, job 119234816831 (run gate, ubuntu-22.04-arm): `wolf 0.2.34 (wolfgang, pin 9da7bdc)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` | release-0234-rungate-arm-119234816831.log |
| tap and AUR | — | AUR wolf-lang and wolf-lang-bin 0.2.34-1, lupin and lupin-bin 0.1.55-1, lobo-bin 0.1.5-1; homebrew-wolf 69f72d1's formulae name v0.2.34 / 9da7bdcf… (std e036bec3…) and v0.1.55 / e642f263… | aur-live.txt |
| lupin 0.1.55 on wasm32 | the wasm path as ww45 left it | wolf-interp#222 open; unpatched still fails (UNPATCHED-EXIT=1, E0433 `cannot find fs in super`); the carried patch (sha256 2cc2b8a3…) applies unchanged, PATCHED-EXIT=0, imports 0, module 1fc52ce9… | wasm-control.txt |
| wolf-std trunk | nothing past e036bec shown | wolf-std trunk is 3bacc5f6… (sc69's wrappers); no built page outside the book, the changelogs and /spec/ names them (build-summary.txt) | derive.log |

Drift, reported:
1. **The contract's line that six of 0.2.34's names resolve in 0.1.55 was
   wrong** (R-ww46-1): the published 0.1.55 resolves none; the mirror closed
   on wolf-interp trunk after the release (#268, #269, 2026-10-21T21:58Z).
2. **The distance crosses 999 commits**, past the word stamper's ceiling: at
   the pin the stamper refuses ("no prose spelling for 1067",
   guard-at-pin.txt), so the build would have stopped (R-ww46-2).
3. **The gap reaches ten releases**, one past the guard's closed set; at the
   pin the guard exits naming the missing phrase (guard-at-pin.txt, and the
   windows run at the pin push, 39704758640, job 119582108605). Both pages'
   sentences were written, then `ten releases` joined the set.
4. The site build runs no wolf, so the book CI's staging step was mirrored on
   its own and held against the archives and book.yml.
5. wolf's CHANGELOG counts "97 commits since 0.2.33 (s247 29, s248 68), then
   r39's release commits"; git counts 112. The stamp is git's (1067 from the
   spec pin).
6. The first probe pass (the Codex agents') wrote two malformed probes
   (`List[int]::new()`, `List[byte]::new()`, no wolf spelling): their records
   were a parse error, E0201, not the call's answer. Fixed (`[0]`,
   `List[byte]()`, the shapes wolf-lang's own fixtures use) and every probe
   re-measured (ww46-builtins.sh).
7. The three pin commits moved the count allowlist's clocks to the new pins
   with no sentence re-read; one of those lines was false (`Eight tiers`,
   R-ww46-4). Every clocked line was re-read with its page's commit.
8. The worktree is ~/lanes/ww46/wolf-web (nomad-1); the build clone is
   ~/lanes/ww46/web (kasumi).

## 3. Prediction, committed before the first gitlink moved

The prediction commit `51807c4` (empty), pushed at 2026-10-22T01:15:54Z,
before the pins (pushed 01:16:48Z). Its message, verbatim:

```
Predict the site at wolf 0.2.34 and lupin 0.1.55

Inputs re-derived on kasumi before any pin changes: wolf v0.2.34
9da7bdcf2aea9adf48df6570bedc58e16e9ef853, lupin v0.1.55
e642f2630ad4c7f53740428d5cca705f2e0d295b, book
f1fd824711b8949d6d4400c5ce5e8d61b328fe0f. Archives read twice and
verified against published digests; std e036bec, 58 files, manifest
5d6253b63c97c050e3bf068cfb15c8515453b7ec5b98cd62a91a955bd2a9fc9a.

Machine prediction (kasumi ~/lanes/ww46/predict.py and predict.txt):
683 programs, 499 exit, 51 trap, 133 unsupported, 0 fail, 550 candidates.
The run sets are identical; term_editor_rows only removes a row behind
an already declined call. The wasm process tier remains declined. Four
legs (old/new corpus x live 0.1.54/new 0.1.55 module): no class moves.
All seven new names: unsupported, resolve, exit 4, does not resolve.
The menu refuses nothing served before. Reason words may change for
0.2.33's five names learned in 0.1.55.

Pins stamp 0.2.34/0.1.55; spec stays 294d626/v0.2.24, ten releases and
1067 commits behind. New anchors 8, dropped 0, total 672. Diagnostics
153, warnings 34, net programs 18, menu 36, book chapters 34, pages 64
(book 49), book assets 581 versioned, 0 bare. PDF 6.2 +/- 0.3 MB.
Install Windows name matches book ch01. Ch34 has 34.7 and 34.8. Browser
gates: three engines x two viewports, production CSP, two-hop links.

R-ww46-1 answered: published lupin resolves none of 0.2.34's seven;
contract expectation of six resolving withdrawn. Promise nothing.
R-ww46-2 answered: extend word() through 999999, match existing style,
boundary tests, pre-fix thousand failure planted beside the lag plant.
This required stamper extension is the sole deviation from ww45's shape.
Prediction: one thousand and sixty-seven; the lag guard gains ten releases
after both pages say it. CI plant removes ten and restores the 999 ceiling;
node tests and windows lag gate go red. Revert restores identical tree.

No build on nomad-1; all computation on kasumi. No deploy, no public step,
no issue filed or closed, no attribution. PR cross-cutting; tier pr green
at final head, label then hand back tier full to the orchestrator.
```

## 4. Evidence index

*Filled in after the measurement.* Built on kasumi at `a674427`
(`build-summary.txt`, the build the staged gates served); later commits touch
only `docs/audit/` until the plant. The gates' browsers ran on nomad-1:
kasumi has no Playwright and no WebKit, nothing was installed. Files are
under `docs/audit/ww46-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `51807c4` pushed 2026-10-22T01:15:54Z (branch creation), the three pins `752407f`, `cddb781`, `15e9fac` pushed 01:16:48Z (GitHub's activity API for `refs/heads/ww46`) |
| three gitlink commits | book `752407f` (-> `f1fd8247`), wolf `cddb781` (-> `9da7bdcf`), lupin `15e9fac` (-> `e642f263`); each moved its count-allowlist clocks (drift 7) |
| the guard and the stamper at the pin | `guard-at-pin.txt` (script `ww46-guard-at-pin.sh`, kasumi, the tree of `15e9fac` by `git archive`): `the interpreter is 10 releases behind and /install/ and /play/ have prose for 0 through 9 only`, `LAG-EXIT=1`; 122 clocked version-prose lines red, `VP-EXIT=1`; `word(1067)`: `no prose spelling for 1067`. The windows learner path's run at that push, 39704758640 (head `15e9fac`), went red: job 119582108605, step "the specification pin lag the site records", the same line (`windows-at-pins-119582108605.log`, line 211) |
| the word stamper | `5880322` the tests (999, 1,000, 1,067, 1,100, 1,101, 999,999 spelled; -1 and 1,000,000 refused), `bfa634c` the extension; `one thousand and sixty-seven commits` once on each built page (`build-summary.txt`) |
| inputs, lag, corpus sets, anchors, grammar, the book's diff, the 0.2.34 CHANGELOG | `derive.log` (script `ww46-derive.sh`) |
| linux aarch64 at 0.2.34 | `release-0234-rungate-arm-119234816831.log` |
| archive digests, each read twice; the archive's `std/`; the book CI's staging step mirrored | `release-assets.txt` (script `ww46-archives.sh`) |
| tap and AUR | `aur-live.txt` |
| lupin 0.1.55 on wasm32 | `wasm-control.txt` (script `ww46-wasm-control.sh`), `wasm-0155-patched.log`, `wasm-0155-unpatched.log` |
| census, predicted by machine | `predict.txt`, `census-0234-predicted.json` (script `ww46-predict.py`, run before any module measurement): 683 / 499 exit / 51 trap / 133 unsupported, 550 candidates |
| census, four legs | `census-85dab5d7-{live,control}.json` (the 0.2.33 corpus), `census-9da7bdcf-{live,control}.json` (the 0.2.34 corpus), `leg-*.txt`, driver `ww46-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; modules: the live lupp.us module `bf9877a5…` (lupin 0.1.54, the deploy host's build) and this lane's `1fc52ce9…` (lupin 0.1.55); every leg 683 / 499 / 51 / 133, 0 class moves against the prediction |
| stdout and reasons over the running set | `stdout-all.txt` (script `docs/audit/ww45-evidence/ww45-stdout-all.mjs`): 683 of 683 identical in verdict and stdout across the two modules; `reasons-all.txt` (script `ww46-reasons.mjs`, the same walk comparing phase, exit and the unsupported reason too): 680 identical, 3 differ, each only in its reason: `os/signal_one_rows.lu` (`os_signal_ignore_one` does not resolve -> the process tier), `os/signal_loopback.lu` and `os/signal_supervisor.lu` (`os_signal_listen` does not resolve -> the process tier) |
| the tab's reason strings | `tiers.txt` (script `ww46-tiers.mjs`): the 133 unsupported programs by masked reason under each module, 19 distinct each; `unresolved-0155.txt` (script `ww46-unresolved.mjs`): the 26 "does not resolve" answers at 0.1.55 are 23 sibling-module names and `os_random` three times; `tier-probes-*.txt` (programs `tier-probes/*.lu`): one call per tier the page named, both modules — task, time, process, net and fs declined with their tiers, `os_random` "does not resolve" in both, `os_signal_listen` "does not resolve" at 0.1.54 and the process tier at 0.1.55 (R-ww46-4) |
| the seven calls and the chapter programs, module level | `builtins-{live,control}.txt` (script `ww46-builtins.sh`, programs `probes/*.lu`: the seven calls one each and §34.7's and §34.8's four programs verbatim from wolf-book `f1fd824`), identical under both modules: each of `os_fork`, `os_term_restore_at_exit`, `os_signal_wait_fds`, `fs_sync`, `fs_sync_dir`, `fs_realpath`, `os_clock_ns` answers `unsupported`, phase `resolve`, exit 4, `` `<name>` does not resolve ``; `fork.lu` stops at `os_pipe` (the process tier), `busy.lu` at the task tier, `wait.lu` at `` `signal.listen` does not resolve ``, `save.lu` at `fs_exists` (the fs tier); 0 instance deaths. ww45's eleven probes through both modules: `builtins-ww45-*.txt`; the five 0.2.33 calls move from "does not resolve" to the process tier, the rest identical |
| the corpus's os rows in the tab | `corpus-os-{live,control}.txt` (script `ww46-corpus-os.sh`): `signal_one_rows.lu` at `os_signal_ignore_one` (does not resolve -> the process tier), `group_rows.lu`, `job_poll_rows.lu` and `term_editor_rows.lu` at their first call with the process tier under both |
| at a terminal, and the compiler's answer | `native-0234.txt` (script `ww46-native.sh`, pid namespace, `SigBlk 0`, `SigIgn 0`), the published linux pair from `release-assets.txt`: lupin 0.1.55 answers each of the seven `` unsupported: `<name>` does not resolve `` (exit 4); `fork.lu` and `busy.lu` at `os_fork`, `wait.lu` at `signal.listen` (lupin alone: no std beside it), `save.lu` at `fs_sync`; `signal_one_rows.lu`, `group_rows.lu`, `job_poll_rows.lu`, `term_editor_rows.lu` print their rows and exit 0; the 0.2.33 shape probes `invalid`, `poll_core: -1, 0 live`, `wait_status_core: io`; `os_signal_text(0)` refused by name ("the C library's words … std has no `strsignal`"). wolf 0.2.34 native prints the book's lines for all four programs; the checked machine answers `os_fork` `unsupported` (`fork.lu` prints `error: unsupported`, exit(1); `busy.lu` prints the book's two `unsupported` lines) and runs `wait.lu` and `save.lu` to the book's lines; ww45's `one.lu` is refused by name on checked and `again.lu`'s re-exec runs `wolf` itself there, as at 0.2.33 |
| every terminal sentence on /install/ and /play/ | `terminal-host.out` and `terminal-net.out` (script `ww46-terminal.sh`, pid namespace; the net pass in its own network, loopback only): lupin 0.1.55 over every running program under `corpus/os`, `fs`, `conc`, `time` and `net` and the five named declines, each held to its header: host pass 86 programs, 73 as their headers say, 12 declined by name, 1 other (`conc/proc_link_root_death.lu`, whose header names no exit); net pass 18, 15 as their headers say, 2 declined by name (fd inheritance), 1 other (`net/unix_echo.lu`'s bind, under the root-mapped namespace) |
| the build | `build-summary.txt`: build exit 0; node tests 131 / 131; links 1,548 across 64 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 672 anchors; planted 8 pass; tab-target 5 / 5; version.json lupin 0.1.55, pins 9da7bdc / e642f26 / f1fd824, spec-pin 294d626, missing []; `This is version 0.2.34.` |
| the lag, verbatim | `lag phrases: wolf 0.2.34 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 10 releases back, and both pages carry 'ten releases' and neither carries another`; `--json`: `{"gap": 10, "phrase": "ten releases", "tagged": true, "commits": 1067, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.34"}`; on each page `ten releases` once and every other phrase 0 times |
| book assets, PDF | 581 references `?v=f1fd824` (293 css, 288 js), 0 bare, `wolf-boot.js?v=f1fd824` on 48 pages; PDF 6,078,615 B |
| ch34 and the /play/ links | `id="34.1"` … `id="34.8"` once each in `dist/book/ch34.html` (105,394 B); /play/ links `#34.8`, `#34.7`, `#34.6`, `#34.5`, `#34.3` and `ch03.html#3.3` once each |
| /install/'s windows archive name | the built page carries `wolf-0.2.34-x86_64-pc-windows-msvc` four times, all from the stamp; ch01 carries it twice and 0.2.33's none |
| nothing unreleased is named | no built page outside the book, the changelogs and /spec/ names sc69's wrappers (`process.fork`, `fs.sync`, `fs.sync_dir`, `fs.realpath`, `time.now_ns`, `raw_cr`, `raw_output`, `strip8`): 0 lines |
| ch07 and the changed pages | six ch07 SVGs sha-identical to ww45's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww46-book.mjs`): three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, ch01's windows tar line, ch22's `toolchain 0.2.34` line, the colophon's `wolf 0.2.34 (wolfgang, pin 9da7bdc)`, §34.7's `fork.lu` and `busy.lu` lines and §34.8's `wait.lu` and `save.lu` lines each in a code block, 0 CSP violations, 0 console errors on every page (48 page loads). The colophon reads `1067 commits, ten releases`; ch22 carries `toolchain 0.2.33` once, inside bs70's audit-ledger HTML comment |
| /play/ in engines | `play-staged.txt` / `.json` (script `ww46-play.mjs`, served by `docs/audit/ww42-evidence/ww42-serve.mjs` on 127.0.0.1:8754 with the headers read out of `nginx/lupp.us.conf`): on all six cells the module boots (`lupin 0.1.55, compiled to WebAssembly, … reading cfg as x86_64-unknown-linux-gnu.`), the 36 menu programs run from the menu (31 exit, 5 trap), the 22 probes each answer as at module level, 0 CSP violations, 0 console errors, and the six cells agree |
| /play/ refuses nothing it served | `play-live-before.txt` / `.json`: the same walk against https://lupp.us before the merge (ww45's deploy, lupin 0.1.54); `play-compare-staged.txt` (script `ww46-play-compare.mjs`): 216 menu runs over six cells, 0 verdicts moved, 0 served before and refused or missing now; the probes' reason words move only for ww45's five 0.2.33 calls (does not resolve -> the process tier) |
| the site's links, two hops, §34.7 and §34.8 | `links-staged.txt` / `.json.gz` (script `ww46-links.mjs`): on all six cells the front page's 7 links clicked and landed, 40 further targets landed, ch34 and ch03 in the two-hop set, `ch34.html#34.1` … `#34.8` and `ch03.html#3.3` each landed 200 with its heading found and scrolled to (`34.7 A child that keeps running`, `34.8 What an editor asks of the host`), 0 faults |
| staged contents gate | `gate-staged.txt` / `.json.gz`: 50 pages, 46 entries, 2,300 clicks and 0 faults on all six cells; retry from ch07 hop 1 and hop 2 at 0 `HTTP 404` and 0 `ERROR` in 1,116 lines (`retry-staged.log`) |
| every staged checker on a plant | `stage-plant.txt` (script `ww46-stage-plant.sh`): an inline script on the front page and /play/, /play/'s §34.7 link removed, ch34's `id="34.8"` renamed, one ch07 SVG removed, ch01's archive name set back to 0.2.33, §34.7's `fork.lu` call renamed, the menu's last entry removed, `hello.lu` replaced by the `os_fork` probe; served on 127.0.0.1:8755 (`ww46-plant.sh`, `plant.txt`): `book-plant.txt` 19 FAIL lines, exit 1; `play-plant.txt` 7 FAIL lines, exit 1; `play-compare-plant.txt` 6 verdicts moved and 12 served before and refused or missing now, exit 1; `links-plant.txt` 7 FAIL lines, exit 1 |
| the prose audits between commits | `ww46-chk.sh`: ships the worktree's `site/`, `scripts/`, `tests/` and `CHANGELOG.md` to kasumi's build clone and runs the lag, version and count audits and the node suites there, never a build on nomad-1 |
| CI at head, and the plant | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| census, by machine | 683 / 499 / 51 / 133 / 0 / 550 | **683 / 499 / 51 / 133 / 0 / 550 / 0 died** on all four legs, every row as predicted |
| run sets, term_editor_rows | identical; one row removed behind a declined call | identical; the bit-5 row gone, the program declined at `os_signal_wait_fd` with the process tier |
| four legs | no class moves | none |
| the seven names | unsupported, resolve, exit 4, does not resolve | identical in both modules and six engine cells (after the two malformed probes were fixed, drift 6), and at a terminal |
| the menu | refuses nothing served before | 216 runs, 0 moved |
| reason words | may change for 0.2.33's five names | they changed, and so did two programs' reasons the prediction did not name (`signal_loopback.lu`, `signal_supervisor.lu`: lupin 0.1.55 resolves `os_signal_listen` and its wasm build declines it with the process tier) |
| pins and the lag | 0.2.34 / 0.1.55; 294d626 / v0.2.24, ten releases, 1067 commits | identical |
| anchors | 8 new, 0 dropped, 672 | identical |
| stamps | 153 / 34 / 18 / 36 / 34 | identical |
| pages | 64 (book 49) | 64 (book 49) |
| book assets | 581 versioned, 0 bare | 581, 0 bare |
| PDF | 6.2 ± 0.3 MB | 6.1 MB (6,078,615 B), inside the band |
| install's windows name | matches ch01 | matches |
| ch34 | #34.7 and #34.8 | both, and two hops from the front page |
| browser gates | 3 × 2, production CSP, two-hop links | all green; every checker red on its plant |
| the word stamp | one thousand and sixty-seven | identical, once per page |
| the plant | ten out and the 999 ceiling back: node tests and the windows lag gate red; the revert's tree identical | in the PR body |
| the lupin module | — | `1fc52ce9…` in the control and the build (same directory) |

**Found, not predicted.**
1. **/play/'s tier count was false at this pin** (R-ww46-4): `os_signal_listen`
   moved into the process tier's decline in the wasm build and is refused by
   name at a terminal; `os_random` has never resolved in lupin, in the tab or
   at a terminal, so "work when you run lupin at a terminal" was false for it
   since 3b44fe0 (2026-09-07), the commit that first counted it.
2. **Two decline reasons moved beyond the five calls**: `signal_loopback.lu`
   and `signal_supervisor.lu` (above). The pages name all three.
3. **wolf-interp#268 and #269 are closed** (2026-10-21T21:58Z, after 0.1.55):
   the mirror is on wolf-interp trunk and in no release. The pages cite both
   as what a later lupin release mirrors and claim nothing from trunk.
4. **The pin commits moved the count clocks without the re-read** (drift 7),
   and `Eight tiers` passed the count audit at the pin for that reason. The
   clock is only as good as the re-read it stands for.
5. The first probe pass's two malformed probes (drift 6).
6. The checked machine and §34.7: `fork.lu` prints `error: unsupported` and
   exits 1 there (the book marks it `wolf-run`, native, and shows only
   `busy.lu`'s checked record). Not a site matter.
7. The built `ch22.html` carries `toolchain 0.2.33` once, inside bs70's
   unpublished audit-ledger comment (as at ww45).

## 5. Done-when

- [x] Branch `ww46` on origin; PR open, **unmerged**, body carries the five
      sections by name, commit shas as bullets, a test checklist and
      `Footprint: cross-cutting`.
- [x] The prediction commit precedes the first gitlink commit; the census
      predicted by machine.
- [x] Three gitlink commits (book, wolf, lupin).
- [x] The word stamper extended through 999,999 with boundary tests
      (R-ww46-2).
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim;
      census table, probes, page count in §4.
- [x] /play/, chapter 7, the changed pages, §34.7, §34.8 and the site's
      links checked in three engines × two viewports under the production
      headers; the staged gate's 404 path and ch07 path at 0 faults; every
      checker red on a plant.
- [x] What the tab answers for §34.7's and §34.8's calls, measured in the
      module, in the engines and at a terminal.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] The plant (lag phrase and word ceiling) seen red in CI, reverted.
- [ ] The final head's PR run and windows run green, handed back with ids
      (RULES.md §6).
- [ ] After the merge (the orchestrator's): the deploy job's run id, the live
      gate, the live `version.json`, `id="34.7"` and `id="34.8"` live.
- [ ] kasumi pruned; preview servers stopped (done: 8754 and 8755 by pid).
