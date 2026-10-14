# ww42 — The Site at 0.2.29

Class: one repo, one bump (three gitlinks), one deploy. Opus. Wave 53.
Contract: the planning repo's sprints/web/ww42-the-site-at-0229.md (planning
8e628aa, read 2026-10-13), which keeps every rule of ww41's and ww40's. One
deliverable: lupp.us serves wolf 0.2.29, lupin 0.1.52 and the book at
wolf-book 0a5fecc (bs66), every stamped number derived at the checkout. This
commit is empty; its message is sections 1 to 3, cut from wolf-web trunk
7134ad2 with all three gitlinks at ww41's values. Section 4 lands later in
docs/audit/ww42-contract-0229.md; sections 1 to 3 are not edited after this
commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests run on kasumi under
  ~/lanes/ww42/. nomad-1 runs git, gh, curl, ssh/scp and the browser gates
  only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww42/bin/; a browser engine the gate needs and a host
  lacks is reported, not installed.
- No rm outside ~/lanes/ww42/ (both hosts); no deletion in any tree this
  lane did not create. No git add -A. Nothing under ~/.claude. No edit to
  another lane's file. Scratch under ~/lanes/ww42/ only, never /tmp.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy, before the merge or after it. PR open, unmerged; the
  orchestrator audits and fast-forwards; the deploy is that push run's
  "deploy to lupp.us" job (sprints/HOSTING.md). No ssh to almanta, no
  scripts/deploy.sh or ci-deploy.sh run by this lane, no nginx, no tunnel or
  its config, no DNS, no listing of cloudflared's arguments.
- The site describes the RELEASED toolchain: wolf 0.2.29, lupin 0.1.52 and
  the std the archive bundles (wolf-std d7c2968). Nothing from wolf-lang or
  wolf-std trunk (the terminal builtins, std.signal's twenty names) is shown
  as available.
- No merge, tag, issue filed or closed, cancelled run of another lane. No
  2>/dev/null on a checkout; the branch is asserted before every commit.
- No "seen red" without a run id, sha, path or digest in the same
  paragraph. File checksums carry a trailing ….
- Kill only this lane's own pids, recorded at launch; on kasumi killable
  jobs start under setsid, never ssh -f. Host ports 8080 and 8088 are not
  used; a preview server binds loopback on a recorded port and is stopped by
  pid.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-13 23:54-23:59 UTC, before any gitlink moves)

Script ww42-derive.sh, log derive.log (kasumi ~/lanes/ww42/, landing under
docs/audit/ww42-evidence/); release facts read with gh on nomad-1.

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | 7134ad2 (ww41) | 7134ad2ce24c… ; PR #60 the last merged | gh api |
| gitlinks at trunk | 0.2.28 / 0.1.51 / b845e07 | wolf-lang f71ece8e… (v0.2.28), wolf-interp f72e78d7… (v0.1.51), book b845e077… | git submodule status |
| live version.json | — | built 2026-10-12T09:50:51Z, lupin 0.1.51, pins f71ece8 / f72e78d / b845e07, spec-pin 294d626, missing [] | curl https://lupp.us/version.json |
| live headers | CSP blocks inline scripts | server nginx/1.20.1; content-security-policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'self' | curl -sI https://lupp.us |
| wolf 0.2.29 | v0.2.29 at 6ffe7c60 | v0.2.29 (annotated) -> 6ffe7c6056ee…; release 411040788, draft false, 4 archives, published 2026-10-12T23:22:55Z | gh api; derive.log |
| lupin 0.1.52 | v0.1.52 at 025428b | v0.1.52 (annotated) -> 025428b725a3…; release 410845419, 5 assets, published 2026-10-12T17:20:49Z; Cargo.toml 0.1.52; 13 commits since f72e78d7 | gh api; derive.log |
| lupin's spec gitlink | — | 294d626d = v0.2.24 at 0.1.51 AND 0.1.52: UNCHANGED | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of 6ffe7c60 (exit 0); rev-list --count 294d626d..6ffe7c60 = 611; f71ece8e..6ffe7c60 = 70; CHANGELOG heads 0.2.29, 0.2.28, 0.2.27, 0.2.26, 0.2.25, 0.2.24, so the counted gap = 5 | derive.log |
| book target | 0a5fecc (bs66) | wolf-book trunk 0a5fecc0c173…; b845e077 an ancestor, 11 commits; SUMMARY blob identical (c5819603), 33 chapters; book/ changes: ch01, ch22, colophon, solutions (29 insertions, 22 deletions); book/diagrams untouched | derive.log |
| ch01's Windows block | names wolf-0.2.29-x86_64-pc-windows-msvc | book/ch01.md:237-238 at 0a5fecc do; /install/ stamps the same name from __WOLF_VERSION__ (site/install/index.html:144, 149, 161) | derive.log |
| the book render and std/ | any wolf the site builds needs std/ beside it; mirror bs66's staging and manifest 229202f5… | the site builds no wolf: at 0a5fecc `xtask render web` / `render pdf` still run typst (render.rs:522) and git (highlight.rs:346) only, and ch22's listing is spliced into the source by bs66. book.yml:173-195 is the staging step and names 229202f5b647… for the 0.2.29 archive; with no wolf in this build there is nothing to stage it beside. The Windows job (windows.yml) is the one place this repo unpacks a wolf archive, and it already asserts std/ and std/STD-REV | derive.log |
| bundled std | wolf-std d7c2968 | 0.2.29 CHANGELOG: the bundled std is d7c2968 (0.2.28 shipped 98e1b7b); its std.signal names nine meanings and wraps none of the five new builtins | derive.log |
| corpus | — | phase: run set 658 -> 659: 1 in (os/signal_shell_rows.lu), 0 out; one pre-existing run program modified (os/job_rows.lu: its outside bit 512 -> 1048576); anchors 634 -> 640 (6 added: os.proc.self, os.signal.ignored, os.signal.number, os.signal.send, os.signal.set.stable, os.signal.shell.note; 0 dropped); grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18, all unchanged; docs/platforms.md unchanged; spec/ changes: 02, 03, 11, anchors.json, prelude.json | derive.log |
| the five new builtins in lupin | hosted-only | builtin.rs at 025428b: on a hosted build os_pid, os_ppid and os_signal_number are served, os_signal_send and os_signal_ignored refused by name after their shape rows; under cfg(target_family = "wasm") all five sit in the process tier's decline arm (builtin.rs:664-693) | derive.log |
| lupin 0.1.52 on wasm32 | the wasm path as ww41 left it | wolf-interp#222 still OPEN; the control build (patched and unpatched) is measured before the lupin gitlink moves | gh issue view; §3.7 |
| wolf-lang and wolf-std trunk | not shown as available | wolf-lang trunk b407c73b (past v0.2.29: s233, s234's terminal builtins); the site has no line naming os_term_size, os_signal_wait_fd, os_term_chars or std.signal (grep of site/, 0 lines) | derive.log |

Drift, reported:
1. **The gap widens to five releases** (611 commits), and
   check-lag-phrases.py's closed set stops at four: at the wolf pin the
   guard will exit naming the missing phrase, as it did at ww41. Both pages'
   sentences get written, then `five releases` joins the set.
2. The contract asks for bs66's std staging step to be mirrored; this build
   runs no wolf, so there is nothing to mirror it onto (as ww41 found for
   bs65). Reported, not absorbed.
3. wolf's CHANGELOG counts 56 commits for 0.2.29 "then r34's release
   commits"; git counts v0.2.28..v0.2.29 = 70. The stamp is git's.
4. The worktree is ~/lanes/ww42/wolf-web (nomad-1); the build clone is
   ~/lanes/ww42/web (kasumi).

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 63 dry, 63 live; the book's web edition 48 pages (SUMMARY
blob identical). The six ch07 SVGs sha-identical to ww41's.

3.2 Version strings. /install/ and /play/ stamp 0.2.29 and 0.1.52; the
Windows archive link reads wolf-0.2.29-x86_64-pc-windows-msvc.tar.gz, as
ch01 §1.2 does. version.json: lupin 0.1.52, pins wolf-lang 6ffe7c6,
wolf-interp 025428b, wolf-book 0a5fecc, spec-pin 294d626, missing [].

3.3 The lag. After the phrase is added, check-lag-phrases.py --json
answers {"gap": 5, "phrase": "five releases", "tagged": true, "commits":
611, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.29"}. The
stamped distance "five hundred and forty-one" -> "six hundred and eleven".
The guard exits at the wolf pin commit and still at the lupin pin commit
(0.1.52 keeps the v0.2.24 pin); it goes green only with the new phrase and
both pages rewritten. Falsified by: any other gap or count, or a guard that
passes at either pin commit.

3.4 The census at 0.2.29 / 0.1.52. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.28 and 0.2.29 corpora x the live 0.1.51 module,
fetched from lupp.us, and the built 0.1.52). Baseline: the live module on
the 0.2.28 corpus (ww41's served census, 658 / 487 / 47 / 124 / 0).

| class | live (0.2.28 / 0.1.51) | ww42 predicted | delta |
|---|---|---|---|
| programs | 658 | 659 | +1 |
| exit | 487 | 487 | 0 |
| trap | 47 | 47 | 0 |
| unsupported | 124 | 125 | +1 |
| fail | 0 | 0 | 0 |
| candidates | 534 | 534 | 0 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.28 corpus (0.1.51 -> 0.1.52): 0 rows change class.
The one arrival, os/signal_shell_rows.lu, is unsupported in the tab under
0.1.52 (its first call is a poll, and the wasm build declines the process
tier by name); under 0.1.51 it is unsupported too, or a fail on an unknown
name (least firm). os/job_rows.lu stays unsupported under both modules
(os_spawn_job is declined before its moved bit is read). Whole-set stdout
walk: 659 of 659 identical across the two modules in verdict and stdout,
unless 0.1.51 fails the arrival on a name it does not know.

3.5 The five new builtins in the tab (os_pid, os_ppid, os_signal_send,
os_signal_number, os_signal_ignored): each a one-call program through the
built 0.1.52 module answers verdict unsupported, the message naming the
builtin and that the wasm build has no processes; none runs, none traps,
none kills the instance. Under the live 0.1.51 module the same five
programs do not run either (the names do not exist there). So the tab
refuses nothing it served before.

3.6 Allowlist lines. All three clocks move (wolf 0.2.28 -> 0.2.29, lupin
0.1.51 -> 0.1.52, book b845e07 -> 0a5fecc), so every clocked entry reddens:
122 — version-allowlist 98 (72 wolf, 26 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book), entry lines only.
Predicted to arrive: v0.2.28 where 0.2.28's paragraphs become history
(front page, /spec/, /install/, /play/), 0.1.51 on /install/ and /play/.
Leaves: none predicted. play's `five` count moves (the lag phrase is a
number word).

3.7 lupin 0.1.52 on wasm32. As released it still fails (E0433 at
builtin.rs, the os_error_text call into eval::fs; wolf-interp#222 open);
ww40's wasm-portability.patch (sha256 2cc2b8a3…) applies unchanged and the
module imports nothing. Falsified by: an unpatched build that succeeds (the
patch then goes), or a patch that no longer applies.

3.8 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.29's story leads (a task per connection with no cap and
  no cpu while parked, #713; every signal POSIX names, what was ignored at
  start, a poll that never trails a delivery, this process's id and a send
  to any pid, ruling #70; wolf lsp finds the standard library, #724; the
  bundled std at d7c2968, whose std.signal predates the twenty meanings);
  0.2.28's becomes history beside 0.2.27's.
- /install/: the lag paragraph at five releases; the arrivals paragraph
  re-derived from the census; the declines unchanged.
- /play/: the lag at five releases; what the tab answers for the five new
  names; the refused list re-derived (3.9).
- /spec/: the bound sentences gain 0.2.29's anchors (11's signal set,
  ignored, send, number, proc.self, set.stable; 03's task-order cost).
- linux aarch64 sentences: re-read against the 0.2.29 release run's arm
  gate; no edit beyond the stamp expected.

3.9 /play/'s refused list after the bump: EMPTY (0 refusals, 0 output
partings). Declines that stand: the three whole-struct raw stores,
extern_let_image, extern_libc; atomic_counter the tab's; chdir_relative
still the near miss.

3.10 Stamps other than the distance: bookchapters 33, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 640
anchors. The menu: 36 programs, every one in class.

3.11 The PDF. 5.8 MB +- 0.2 MB (bs66 moves version text only).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=0a5fecc, 0 bare, 569 references.

3.13 ch07's diagrams and the changed chapters (ch01, ch22) load under the
production CSP (staged from kasumi's dist/book under lupp.us's headers,
then live): 0 CSP violations, 0 console errors, ch07's six diagrams
rendered on three engines x two viewports; ch01 carries
wolf-0.2.29-x86_64-pc-windows-msvc, ch22 `toolchain 0.2.29`.

3.14 The staged gate (three engines x two viewports): 0 faults each;
--retry from ch07.html hop 1 and hop 2 at 90/90 on all six.

3.15 The PR's CI does not deploy: the run at the PR head has a `build the
site` job and its `deploy to lupp.us` job is skipped (pull_request event).
After the orchestrator's fast-forward the push run's deploy job deploys;
live version.json = 3.2.

3.16 The live gate (three engines, two viewports): 0 faults, hop 1 and hop
2 90/90 on all six, 0 HTTP 404 lines.

What I expect to get wrong: the arrival's class under the old module, the
allowlist arrivals' counts, and whether the wasm patch still applies
without an offset.


## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `87352a6` (an empty commit), unedited.* Built on kasumi at
`cb9b639` (`build-summary.txt`, the build the staged gates served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1: kasumi
has a system chromium and firefox and no Playwright and no WebKit, nothing was
installed, and the three engines are the ones playwright-core 1.63.0 already
had cached on nomad-1, as ww41 used them. Files are under
`docs/audit/ww42-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `87352a6`, first pin `8471a27`; `87352a6` was pushed to origin before any pin |
| three gitlink commits | book `8471a27` (-> `0a5fecc0`, 4 book count lines), wolf `9f7fa48` (-> `6ffe7c60`, 9 wolf count lines), lupin `7e8c517` (-> `025428b7`, 5 lupin count lines; `crates/lupin-wasm/wasm-portability.patch` unchanged, sha256 `2cc2b8a3…`) |
| inputs, lag, corpus sets, anchors, grammar, the arrival's header, the book's diff, the 0.2.29 and 0.1.52 CHANGELOGs, lupin's five builtins | `derive.log` (script `ww42-derive.sh`) |
| linux aarch64 at 0.2.29 | `release-0229-rungate-arm-115048045767.log`: release run 38314217297, job 115048045767 (run gate, ubuntu-22.04-arm): `wolf 0.2.29 (wolfgang, pin 6ffe7c6)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` |
| archive digests, each read twice | `release-assets.txt` (script `ww42-archives.sh`, kasumi): wolf-lang release 411040788's four archives and wolf-interp release 410845419's five assets, each downloaded twice, both reads equal to the sha256 GitHub publishes (`ARCHIVES-FAIL=0`); the Windows archive is `e8a37a7f…` |
| the archive's `std/` and the book's manifest check | `release-assets.txt`: all four wolf archives hold `std/`, 57 files, manifest `229202f5…` by wolf-book `0a5fecc`'s own recipe (book.yml:193 names the same digest), `std/STD-REV` = `d7c2968c…`; no file under it names any of the five new builtins. This build runs no `wolf`, so there is no binary here to stage it beside (§2) |
| tap and AUR | `aur-live.txt`: AUR wolf-lang and wolf-lang-bin 0.2.29-1, lupin and lupin-bin 0.1.52-1, lobo-bin 0.1.3-1; the tap's formulae name `v0.2.29` / `6ffe7c60…` and `v0.1.52` / `025428b7…` |
| lupin 0.1.52 on wasm32 | `wasm-control.txt` (script `ww42-wasm-control.sh`): with the patch `PATCHED-EXIT=0`, module `e531173e…`, imports 0 (`wasm-0152-patched.log`); without it `UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\`` (`wasm-0152-unpatched.log`); wolf-interp#222 still open |
| the guard exits at the wolf pin | `guard-at-wolf-pin.txt` (kasumi, `9f7fa48`): `check-lag-phrases: the interpreter is 5 releases behind and /install/ and /play/ have prose for 0 through 4 only — write the sentence, then add its phrase here`, `LAG-EXIT=1`, 76 version-prose lines, `VP-EXIT=1`. The windows run at that commit, 38487565477, was cancelled by the next push and shows nothing |
| and still at the lupin pin | `guard-at-lupin-pin.txt` (kasumi, `7e8c517`): the same line, `LAG-EXIT=1`, 104 version-prose lines (98 literal, 6 stamp), `VP-EXIT=1`, `CC-EXIT=0`. The windows run at that commit, 38487586888, was cancelled the same way |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.29 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 5 releases back, and both pages carry 'five releases' and neither carries another`; `--json`: `{"gap": 5, "phrase": "five releases", "tagged": true, "commits": 611, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.29"}` |
| stamped lag | `speccommits 611`; `six hundred and eleven commits` once on each built page (`build-summary.txt`) |
| census, four legs | `census-022{8,9}-015{1,2}.json`, `rows.txt` (script `ww42-rows.py`), driver `ww42-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified |
| stdout probe, records, the whole running set's stdout | `stdout-probe-0152.txt`, `stdout-probe-0151.txt`; `records-0152.txt`, `records-0151.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww42-stdout-all.mjs`): all 659 running programs on the 0.2.29 corpus through both modules, 659 identical in verdict and stdout |
| the five new builtins, module level | `builtins-0152.txt`, `builtins-0151.txt` (script `ww42-builtins.mjs`, programs `probes/*.lu`): under 0.1.52 each is `unsupported`, phase `resolve`, exit 4, reason `` `<name>` is the s40 process trio; this wasm build has no processes to spawn, so the tier is declined rather than mocked ``; under 0.1.51 each is `unsupported`, `` `<name>` does not resolve ``; 0 instance deaths |
| the same five at a terminal | `native-0152.txt` (script `ww42-native.sh`): the published lupin 0.1.52 linux archive (`f5194b74…`, equal to GitHub's digest): `os_pid` and `os_ppid` answer, `os_signal_number(16)` is 2, `os_signal_send` and `os_signal_ignored` are refused by name (exit 4); `os/signal_shell_rows.lu` and `os/job_rows.lu` print their headers; the five standing declines decline; `chdir_relative.lu` prints its header |
| modules | lupin 0.1.52 built at `025428b7` with the patch, sha256 `e531173e…`, identical in the control, the measure run and both builds' `dist/play/lupin.wasm`; the 0.1.51 control is the live module fetched from lupp.us, `0b7095c9…` (`measure.log`) |
| the build | `build-summary.txt`: build exit 0; node tests 120 / 120; links 1,513 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 640 anchors; planted 8 pass; tab-target 5 / 5; version.json lupin 0.1.52, pins 6ffe7c6 / 025428b / 0a5fecc, spec-pin 294d626, missing [] |
| book assets | `build-summary.txt`: `569 … versioned ?v=0a5fecc; nothing exempt`, 0 bare, `wolf-boot.js?v=0a5fecc` on 47 pages; PDF 5,773,403 B |
| /install/'s Windows archive name | `build-summary.txt`: the built page carries `wolf-0.2.29-x86_64-pc-windows-msvc` four times (the link, its text, the `tar` line, the PATH line), all from the stamp; the book's ch01 carries the same name twice and 0.2.28's none |
| nothing unreleased is named | `build-summary.txt`: no built page outside the rendered upstream changelogs and spec names `os_term_size`, `os_signal_wait_fd`, `os_term_chars` or a `std.signal` wrapper (0 lines) |
| ch07 and the changed pages | `build-summary.txt`: six ch07 SVGs sha-identical to ww41's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww42-book.mjs`): three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, ch01's Windows tar line, ch22's `toolchain 0.2.29` line and the colophon's pairing line each in a code block, 0 CSP violations, 0 console errors on every page. The checker on a plant (one SVG removed, an inline script in ch22, ch01's archive name set back to 0.2.28): `book-plant.txt`, 18 FAIL lines, `PLANT-EXIT=1` |
| /play/ in engines | `play-staged.txt` / `play-staged.json` (script `ww42-play.mjs`, served by `ww42-serve.mjs` with the headers read out of `nginx/lupp.us.conf`): on all six cells the module boots (`lupin 0.1.52 … reading cfg as x86_64-unknown-linux-gnu`), the 36 menu programs run from the menu with the page's Run button (31 exit, 5 trap), the five probes each answer `unsupported` naming the call, 0 CSP violations, 0 console errors, and the six cells agree |
| /play/ refuses nothing it served | `play-live-before.txt` / `.json`: the same walk against https://lupp.us before the merge (lupin 0.1.51); `play-compare-staged.txt` (script `ww42-play-compare.mjs`): 216 menu runs over six cells, 0 verdicts moved, 0 served before and refused or missing now. The checker and the comparison on a plant (an inline script in the page, a menu entry removed, `hello.lu` replaced by a declined program): `play-plant.txt`, six FAIL cells, `PLANT-PLAY-EXIT=1`, `PLANT-COMPARE-EXIT=1` |
| the site's links, two hops | `links-staged.txt` / `.json.gz` (script `ww42-links.mjs`): on all six cells the front page's 7 links clicked and landed, the 29 further targets on those pages landed, 0 faults. The first run lost both firefox cells to the walker, not the site (`links-staged-run1-harness-race.txt`). On the plant (an inline script on the front page, /reading/ removed): `links-plant.txt`, six FAIL cells, `PLANT-LINKS-EXIT=1` |
| staged contents gate | `gate-staged.txt` / `.json.gz` (script `ww42-gate-staged.sh`): 2,205 clicks and 0 faults on all six engine × viewport cells (the book's 404 path is in every cell's walk); retry from ch07 hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 63; book 48; six SVGs sha-identical | 63; book 48; six SVGs sha-identical |
| version strings, version.json | 0.2.29 / 0.1.52; pins 6ffe7c6 / 025428b / 0a5fecc, spec-pin 294d626, missing [] | identical |
| lag | gap 5, 611, "five releases"; the guard exits at the wolf pin and the lupin pin | identical (kasumi; both windows runs at the pin commits were cancelled by the next push, so no CI run shows it) |
| census | 659 / 487 / 47 / 125 / 0 / 534 / 0 died | **identical in every total** |
| module leg on the 0.2.28 corpus | 0 rows move | 0 rows move, on either corpus |
| the arrival | `os/signal_shell_rows.lu` unsupported under 0.1.52; under 0.1.51 unsupported or a fail | unsupported under both, declined at `os_signal_poll` under both |
| whole-set stdout | 659 of 659 identical | 659 of 659 identical |
| the five builtins in the tab | each unsupported, naming the builtin and that the wasm build has no processes; under 0.1.51 none runs | identical; under 0.1.51 each `does not resolve` |
| old answers | none moves | none moves |
| clocked allowlist lines | 122 (98 / 6 / 18) | **122 (98 / 6 / 18)**: 104 version-prose lines red at the lupin pin, the 18 count lines re-read in the three pin commits |
| arrivals / leaves | v0.2.28 on four pages, 0.1.51 on install and play; 0 leave; play's `five` moves | v0.2.28 on index (2), spec (3), install (4), play (4); 0.1.51 on install (2), play (1); play `five` 6 -> 7; **not predicted:** install `five` 1 -> 2 (the lag phrase is a number word there too), install v0.2.27 1 -> 2, install v0.2.26 5 -> 3 and play v0.2.26 4 -> 3, install's `__LUPIN_VERSION__` 7 -> 8 (bound 3 -> 4), spec's stamps 5 -> 4; 0 leave |
| lupin 0.1.52 on wasm32 | red unpatched (E0433), the patch applies unchanged, 0 imports | identical |
| stamps | 33 / 153 / 34 / 18 / 36; 640 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 5.8 ± 0.2 MB | 5.8 MB (5,773,403 B) |
| book assets | 569 versioned, 0 bare | 569, 0 bare |
| ch07 and changed chapters under the CSP | 0 violations on ch01, ch22; six diagrams rendered | 0 violations and six diagrams on ch07, ch01, ch22 and the colophon |
| staged gate | 0 faults ×6; retry 90/90 ×2 hops ×6 | identical |
| /play/'s refused list | empty | empty; the declines stand as named |

**Found, not predicted.**
1. **The lag phrase is a number word.** `five releases` puts a `five` on
   /install/ and /play/ that the count audit sees; both count lines grew by one
   occurrence and say, in a comment, that the lag guard holds that one.
2. **The tab's reason for the new calls names the wrong tier's history.** The
   wasm build answers `os_pid` and `os_signal_number` with "is the s40 process
   trio; this wasm build has no processes to spawn", though neither spawns
   anything; lupin builds all five only where it has the process tier
   (wolf-interp `84f87c1`). /play/ says so in its own words. Not filed (this
   lane files nothing); listed in the report.
3. **/install/'s "Five things a program can reach" on Windows** counts
   docs/platforms.md's named refusals, and that document is byte-identical to
   v0.2.28's; 0.2.29's spec adds `unsupported` rows on windows for `os_ppid`,
   `os_signal_send`, `os_signal_number` and `os_signal_ignored` that
   platforms.md does not list. The sentence was left as ww41 left it, on the
   reading it has had since 0.2.27 added rows the same way; reported.
4. **The deploy host's module is not this build's.** ww41 recorded its kasumi
   build of lupin 0.1.51 as `33465bdb…`; the module lupp.us serves is
   `0b7095c9…`. The site builds its wasm on the host it is served from, so a
   PR's module digest is the builder's, as ww32 found for the PDF.
5. wolf 0.2.29's CHANGELOG counts 56 commits "then r34's release commits";
   git counts 70.
6. Two stale sentences ww41 reported stand unedited, for ww41's reason:
   /docs/'s "E0005 did at this pin" and the front page's "both artifacts".

## 5. Done-when

- [x] Branch `ww42` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim;
      census table, allowlist diff, probes, page count in §4.
- [x] /play/, chapter 7, the changed pages and the site's links checked in
      three engines × two viewports under the production headers; the staged
      gate's 404 path and ch07 path at 0 faults.
- [x] What the tab answers for the five new builtins, measured in the module
      and in the engines.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion; the
      PR's run does not deploy.
- [ ] After the merge: the deploy job's run id, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
