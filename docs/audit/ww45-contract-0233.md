# ww45 — The Site at 0.2.33

Class: one repo, one bump (three gitlinks, two of which move), one deploy.
Opus. Crawl 54. Contract: the planning repo's
sprints/web/ww45-the-site-at-0233.md (planning 2c43b57, read 2026-10-19),
which keeps every rule of ww44's and ww43's (and through them ww42's to
ww40's), and sprints/RULES.md. One deliverable: lupp.us serves wolf 0.2.33,
lupin 0.1.54 and the book at wolf-book 3ac6fa9 (bs69), every stamped number
derived at the checkout. The interpreter does not move: r38 kept the pairing
at lupin 0.1.54, so the third gitlink is re-read, not bumped. This commit is
empty; its message is sections 1 to 3, cut from wolf-web trunk d4fbf3a with
all three gitlinks at ww44's values. Section 4 lands later in
docs/audit/ww45-contract-0233.md; sections 1 to 3 are not edited after this
commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests run on kasumi under
  ~/lanes/ww45/. nomad-1 runs git, gh, curl, ssh/scp and the browser gates
  only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww45/bin/; a browser engine the gate needs and a host
  lacks is reported, not installed.
- No rm outside ~/lanes/ww45/ (both hosts) and this lane's worktree; no
  deletion in any tree this lane did not create. No git add -A. Nothing
  under ~/.claude. No edit to another lane's file.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy, before the merge or after it. PR open, unmerged; the
  orchestrator audits and fast-forwards; the deploy is that push run's
  "deploy to lupp.us" job (sprints/HOSTING.md). No ssh to almanta, no
  scripts/deploy.sh or ci-deploy.sh run by this lane, no nginx, no tunnel or
  its config, no ~/.cloudflared, no DNS, no listing of cloudflared's
  arguments, no host port 8080 or 8088.
- The site describes the RELEASED toolchain: wolf 0.2.33, lupin 0.1.54 and
  the std the archive bundles (wolf-std cceda63, which carries ruling #85's
  wrappers for 0.2.31's calls). Nothing from wolf-std past cceda63 (sc66's
  wrappers for 0.2.33's five calls, wolf-std#74) or from wolf-lang trunk is
  shown as available.
- RULES.md §5: signals, faults and forks only to processes this lane
  started, never on a host's process table: every terminal run of §34.6's
  programs (one.lu sends itself a SEGV, again.lu starts a child that ends
  itself by a signal) runs inside its own pid namespace on kasumi
  (unshare --user --map-current-user --pid --fork --mount-proc), RLIMIT_CORE
  0, SigBlk/SigIgn printed first.
- No merge, tag, issue filed or closed, cancelled run of another lane. No
  2>/dev/null on a checkout; the branch is asserted before every commit.
- No "seen red" without a run id, sha, path or digest in the same
  paragraph. File checksums carry a trailing ….
- Kill only this lane's own pids, recorded at launch; on kasumi killable
  jobs start under setsid with a pid file (~/lanes/ww45/launch.sh), never
  ssh -f, never a process-group kill. A preview server binds loopback on a
  recorded port and is stopped by pid.
- Plants per RULES.md §7: the smallest run that shows the plant red, here
  the PR's own CI run (and the windows learner path's push run beside it).
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.
- The final run: hand back per RULES.md §6 with its id.

## 2. Inputs, verified (re-derived 2026-10-19 23:10 - 23:20 UTC, before any gitlink moves)

Scripts ww45-derive.sh (log derive.log), ww45-archives.sh
(release-assets.txt), ww45-wasm-control.sh (wasm-control.txt), kasumi
~/lanes/ww45/, landing under docs/audit/ww45-evidence/; release facts and the
live site read with gh and curl on nomad-1 (live-headers.txt,
live-version.json, aur-live.txt).

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | d4fbf3a (ww44) | d4fbf3ab… ; PR #63 the last merged | git |
| gitlinks at trunk | 0.2.32 / 0.1.54 / e9862f6 | wolf-lang 72de141f… (v0.2.32), wolf-interp 0e536e8f… (v0.1.54), book e9862f6a… | git submodule status |
| live site | serves 0.2.32 / 0.1.54 / e9862f6 | HTTP/2 200, nginx/1.20.1, CSP default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; …; version.json built 2026-10-19T00:55:41Z, lupin 0.1.54, pins 72de141 / 0e536e8 / e9862f6, spec-pin 294d626, missing []; /play/lupin.wasm bf9877a5… | curl |
| wolf 0.2.33 | v0.2.33 at 85dab5d7, release 417610226 | v0.2.33 (annotated tag object 56110e4f…) -> 85dab5d7e597… read twice; release 417610226, draft false, 4 archives, published 2026-10-19T18:37:53Z; wolf-lang trunk = 85dab5d7 | gh api; derive.log |
| lupin 0.1.54 | v0.1.54 at 0e536e8 | v0.1.54 -> 0e536e8fb451… read twice; release 415937354, 5 assets; interp trunk = 0e536e8f; Cargo.toml 0.1.54; the gitlink does NOT move | derive.log |
| archives by digest, each read twice | — | all four wolf 0.2.33 archives and all five lupin 0.1.54 assets downloaded twice, both reads equal to GitHub's digest (ARCHIVES-FAIL=0); Windows archive 96774801…, linux x86-64 pair 4f955e8d… / 175df238…; `wolf 0.2.33 (wolfgang, pin 85dab5d)` / `paired with lupin 0.1.54 (reference interpreter), pin 294d626`; `lupin 0.1.54 (wolf-interp, reference interpreter at pin 294d626)` | release-assets.txt |
| the archive's std/ and the book's manifest | mirror the book's CI staging step and its manifest check, 54 .lu files at cceda63 | all four archives hold std/: 58 files (54 .lu), manifest 4382865a… by wolf-book 3ac6fa9's own recipe (book.yml:193 names the same), STD-REV cceda631…; the book's staging step MIRRORED on kasumi (wolf-std cloned with autocrlf off at v0.2.33's STD-PIN cceda631…, std/ + the two licences + STD-REV): 58 files (54 .lu), manifest 4382865a…, diff -r against the linux archive's std/ IDENTICAL | release-assets.txt |
| does the site build run a wolf? | any wolf the site builds needs std/ beside it | no: at 3ac6fa9 `xtask render` runs typst (render.rs:522) and git (highlight.rs:346) only; lupin and wolf are run by the samples, console and diagrams subcommands, which build.sh does not call. The one wolf this lane runs is the published linux archive's, std/ beside it as the archive places it | derive.log |
| lupin's spec gitlink | — | 294d626d = v0.2.24, unchanged | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of 85dab5d7 (exit 0); rev-list --count 294d626d..85dab5d7 = 955; 72de141f..85dab5d7 = 42; CHANGELOG heads 0.2.33 … 0.2.25 above 0.2.24, so the counted gap = 9 | derive.log |
| book target | 3ac6fa9 (bs69) | wolf-book trunk 3ac6fa94…; e9862f6a an ancestor, 21 commits; SUMMARY byte-identical (404c8c4b), 34 chapters; book/ changes: ch01, ch22, ch34 (§34.5 on the std's process and signal surface, new §34.6 One signal at a time, and an end by one), back/colophon, back/solutions; book/diagrams untouched | derive.log |
| ch01's Windows block | names wolf-0.2.33-x86_64-pc-windows-msvc | book/ch01.md:237-238 at 3ac6fa9 do; /install/ stamps the same name from __WOLF_VERSION__ (site/install/index.html:144, 149, 161) | derive.log |
| the five calls in lupin 0.1.54 | do not resolve until 0.1.55 | builtin.rs at 0e536e8 names none of os_signal_ignore_one, os_signal_default_one, os_exit_signal, os_wait_status_core, os_wait_poll_core; os_signal_text sits in the wasm build's process-tier decline arm (builtin.rs:751) | derive.log; predict.txt |
| corpus | — | phase: run set 682 -> 683: os/signal_one_rows.lu in, 0 out; os/group_rows.lu modified (its text_zero row moved to signal_gaps_lanes.rs, #787); anchors 661 -> 664 (os.signal.disp.one, os.signal.exit, os.signal.gaps.note), 0 dropped; grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18 unchanged; docs/platforms.md unchanged; spec 02, 03, 11, anchors.json, prelude.json changed | derive.log |
| spec/03's stale sentence (ww44's finding) | — | caught up at v0.2.33 (#788): `[conc.task.order]` now says os_signal_wait makes no system call outside a killable scope since 0.2.31, so /spec/'s "has not caught up" sentence is false at the new stamp | derive.log |
| linux aarch64 at 0.2.33 | — | release run 39302694537, job 118236149954 (run gate, ubuntu-22.04-arm): `wolf 0.2.33 (wolfgang, pin 85dab5d)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` | release-0233-rungate-arm-118236149954.log |
| tap and AUR | — | AUR wolf-lang and wolf-lang-bin 0.2.33-1, lupin and lupin-bin 0.1.54-1, lobo-bin 0.1.4-1; homebrew-wolf 3490dab names v0.2.33 / 85dab5d7… (std cceda631…) and v0.1.54 / 0e536e8f… | aur-live.txt |
| lupin 0.1.54 on wasm32 | the wasm path as ww44 left it | wolf-interp#222 open; unpatched still fails (UNPATCHED-EXIT=1, E0433 `cannot find fs in super`); the carried patch (sha256 2cc2b8a3…) applies unchanged, PATCHED-EXIT=0, imports 0, module e05169d1… | wasm-control.txt |
| wolf-std trunk | nothing past cceda63 shown | wolf-std trunk is cceda631… itself (sc66 not merged) | derive.log |

Drift, reported:
1. **The kasumi module is not ww44's.** Same interpreter (0e536e8f), same
   patch (2cc2b8a3…), same toolchain pin (1.97.1), same host: ww44 built
   04ce1322… in ~/lanes/ww44/web, this lane e05169d1… in ~/lanes/ww45/web.
   Equal length (1,402,931 B), 22,541 bytes differ, all in data-segment
   offsets; the build directory's path appears 24 times in each. The live
   module, built by the deploy host in its own checkout, is bf9877a5…. The
   census legs below compare the live module with this one.
2. The gap reaches nine releases (955 commits), one past the guard's closed
   set; at the wolf pin the guard will exit naming the missing phrase. Both
   pages' sentences get written, then `nine releases` joins the set.
3. The site build runs no wolf (as at ww41 to ww44), so the contract's
   "mirror the book's CI staging step" has no binary in this build to stage
   beside; the step was mirrored on kasumi on its own and held against the
   archives and book.yml (above).
4. wolf's CHANGELOG counts "37 commits since 0.2.32, all s246's, then r38's
   release commits"; git counts 42. The stamp is git's (955 from the spec
   pin).
5. The worktree is ~/GithubOrgs/wolffe-lang/wolf-web-ww45 (nomad-1); the
   build clone is ~/lanes/ww45/web (kasumi).

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 64 dry, 64 live (no new chapter); the book's web edition
49 pages. The six ch07 SVGs sha-identical to ww44's.

3.2 Version strings. /install/ and /play/ stamp 0.2.33 and 0.1.54; the
Windows archive link reads wolf-0.2.33-x86_64-pc-windows-msvc.tar.gz, as
ch01 §1.2 does. version.json: lupin 0.1.54, pins wolf-lang 85dab5d,
wolf-interp 0e536e8, wolf-book 3ac6fa9, spec-pin 294d626, missing [].

3.3 The lag. After the phrase is added, check-lag-phrases.py --json
answers {"gap": 9, "phrase": "nine releases", "tagged": true, "commits":
955, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.33"}. The
stamped distance "nine hundred and thirteen" -> "nine hundred and
fifty-five". The guard exits at the wolf pin commit, naming the missing
phrase ("9 releases behind … for 0 through 8 only"), and the windows learner
path's push run at that commit goes red on its lag step; it goes green only
with `nine releases` added and both pages rewritten. Falsified by: any other
gap or count, or a guard that passes at the wolf pin.

3.4 The census at 0.2.33 / 0.1.54, PREDICTED BY MACHINE (ww45-predict.py,
predict.txt, census-0233-predicted.json): ww44's measured census of the
0.2.32 corpus through 0.1.54 (682 / 499 / 51 / 132) carried row by row, a
program both corpora carry unchanged keeps its class, a modified one keeps
it unless its diff adds a name 0.1.54 does not resolve, an arrival naming
one of 0.2.33's five is unsupported at that name. Harness
docs/audit/ww33-evidence/census.mjs unmodified; four legs (0.2.32 and 0.2.33
corpora x the live 0.1.54 module, fetched from lupp.us, and the 0.1.54
module built here).

| class | live (0.2.32 / 0.1.54) | ww45 predicted | delta |
|---|---|---|---|
| programs | 682 | 683 | +1 |
| exit | 499 | 499 | 0 |
| trap | 51 | 51 | 0 |
| unsupported | 132 | 133 | +1 |
| fail | 0 | 0 | 0 |
| candidates | 550 | 550 | 0 |
| kills the instance | 0 | 0 | 0 |

The arrival os/signal_one_rows.lu is unsupported at its first call,
`os_signal_ignore_one` does not resolve; os/group_rows.lu stays unsupported
with the process tier. Module leg (live -> kasumi-built, both 0.1.54): 0
rows change on either corpus. Whole-set stdout walk: 683 of 683 identical
across the two modules in verdict and stdout.

3.5 §34.6's five calls in the tab. Each of os_signal_ignore_one,
os_signal_default_one, os_exit_signal, os_wait_status_core and
os_wait_poll_core, one call alone through the 0.1.54 module, answers verdict
unsupported, phase resolve, "`<name>` does not resolve" (lupin 0.1.54 has
never heard of it; not the process tier's reason), identically under the live
module and the kasumi one; none runs, none traps, none kills the instance.
os_signal_text(0), whose host answer 0.2.33 changed to words, is declined
with the process and signal tier, as every os_signal_text call is in the tab.
§34.6's two programs are unsupported in the tab at their first std call
(one.lu at `signal.kill`, again.lu at `env.args`: the tab has no standard
library); §34.5's three as bs69 re-wrote them: groups.lu at
`process.lead_group`, jobs.lu at `signal.listen`, nochild.lu (unchanged, the
one `run(…)` block) declined at os_wait_poll with the process tier. At a
terminal lupin 0.1.54 answers the five the same way (does not resolve), so
the tab and the terminal agree; wolf 0.2.33 (checked and native, in a pid
namespace) prints the chapter's lines. The tab refuses nothing it served
before: the 36 menu programs' verdicts unchanged in every engine.

3.6 Allowlist lines. The wolf and book clocks move (0.2.32 -> 0.2.33,
e9862f6 -> 3ac6fa9); the lupin clock does not. Reddened: 103 clocked lines —
version-allowlist 86 wolf, stamp-allowlist 4 wolf, count-allowlist 9 wolf
and 4 book; the 37 lupin lines (30 / 2 / 5) hold untouched. Predicted to
arrive: v0.2.32 where 0.2.32's paragraphs become history (front page, /spec/,
/install/, /play/). The lag phrase is a number word: `eight` 3 -> 2 on
/install/ (the two "low eight bits" stay) and its /play/ entry leaves; `nine`
joins /install/ and /play/'s `nine` goes 1 -> 2.

3.7 lupin 0.1.54 on wasm32: measured in §2 (wasm-control.txt); the
prediction is that the build at the head reproduces the control's module,
e05169d1… (same directory, same pins).

3.8 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.33's story leads (the five calls; os_signal_text(0)'s
  words; a SEGV or BUS another process sends ends the program under the
  default; a program naming os_signal_wait_fd starts with two more
  descriptors; the archive's std/ moves to cceda63 and wraps 0.2.31's calls,
  none of 0.2.33's five; lupin 0.1.54 unchanged and not resolving the five);
  0.2.32's becomes history beside 0.2.31's.
- /install/: the lag paragraph at nine releases, the interpreter the SAME
  release as at v0.2.32's pin (it did not release; the compiler tagged
  once); the arrivals paragraph re-derived from the census; 0.2.31-0.2.32's
  arrivals become history; the declines unchanged.
- /play/: the lag at nine releases and the cycle paragraph's new step (the
  compiler tagging once with no interpreter release between); what the tab
  answers for §34.6's five and links /book/ch34.html#34.6; §34.5's programs
  re-read as bs69 re-wrote them (std calls now); "lupin 0.1.53, the
  interpreter this page served until now" no longer true (the interpreter
  is unchanged); the refused list re-derived (3.9).
- /spec/: 03's [conc.task.order] sentence ("has not caught up") goes, the
  document caught up at v0.2.33 (#788); 0.2.32's bound sentences dated; 11's
  [os.signal.disp.one], [os.signal.exit], [os.signal.gaps.note] and the core
  siblings bound to the stamp.
- /reading/: no chapter added; re-read only.
- linux aarch64 sentences: re-read against the 0.2.33 release run's arm gate
  (job 118236149954); no edit beyond the stamp expected.

3.9 /play/'s refused list after the bump: EMPTY (0 refusals, 0 output
partings). Declines that stand: the three whole-struct raw stores,
extern_let_image, extern_libc; atomic_counter the tab's; chdir_relative
still the near miss.

3.10 Stamps other than the distance: bookchapters 34, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 664
anchors. The menu: 36 programs, every one in class.

3.11 The PDF. 6.1 MB +- 0.2 MB (bs69 adds about 270 lines net).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=3ac6fa9, 0 bare, 581 references.

3.13 ch07's diagrams and the changed chapters (ch01, ch22, ch34, the
colophon, the solutions) load under the production CSP (staged from kasumi's
dist/book under lupp.us's headers): 0 CSP violations, 0 console errors,
ch07's six diagrams rendered on three engines x two viewports; ch01 carries
wolf-0.2.33-x86_64-pc-windows-msvc, ch22 `toolchain 0.2.33`, the colophon
`955 commits, nine releases`; ch34's anchors #34.1 to #34.6 resolve.

3.14 The staged gate (three engines x two viewports): 0 faults each;
--retry from ch07.html hop 1 and hop 2 at 92/92 on all six. The links walk
two hops deep reaches ch34.html#34.6 on all six (through /play/'s link).

3.15 The PR's CI does not deploy: its `deploy to lupp.us` job is skipped
(pull_request event). After the orchestrator's fast-forward the push run's
deploy job deploys; live version.json = 3.2; ch34.html carries id="34.6".

3.16 The plant (RULES.md §7, the lag guard as ww44's 0bfbee6): `nine
releases` taken out of the closed set, the PR's own CI run red at "editor
core and CSP gates" (tests/lag-phrases.test.mjs) naming "9 releases behind …
for 0 through 8 only", and the windows learner path's push run red on its
lag step; the revert's tree identical to the commit before the plant.

What I expect to get wrong: the verdict words for the std programs in the
tab (which std name each stops at), the allowlist arrivals' counts, the PDF
size, and whether os_wait_status_core(-1) reaches its own row on wolf.



## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `d9730cb` (an empty commit), unedited.* Built on kasumi at
`01b1dc1` (`build-summary.txt`, the build the staged gates served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1: kasumi
has no Playwright and no WebKit, nothing was installed, and the three engines
are the ones playwright-core 1.63.0 already had cached on nomad-1, as ww41 to
ww44 used them. Files are under `docs/audit/ww45-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `d9730cb`, pushed to origin at 2026-10-19T23:20:13Z, before the first pin `d1c46a0` was committed |
| three gitlink commits | book `d1c46a0` (-> `3ac6fa94`, all 4 book count lines hold), wolf `70d9d98` (-> `85dab5d7`, 9 wolf count lines hold), the interpreter re-read in its own (empty) commit `4ef38de` (stays `0e536e8f`; `crates/lupin-wasm/wasm-portability.patch` unchanged, sha256 `2cc2b8a3…`) |
| inputs, lag, corpus sets, anchors, grammar, the arrival's header, the book's diff, the 0.2.33 CHANGELOG, the five names absent from lupin | `derive.log` (script `ww45-derive.sh`) |
| linux aarch64 at 0.2.33 | `release-0233-rungate-arm-118236149954.log`: release run 39302694537, job 118236149954 (run gate, ubuntu-22.04-arm): `wolf 0.2.33 (wolfgang, pin 85dab5d)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` |
| archive digests, each read twice | `release-assets.txt` (script `ww45-archives.sh`, kasumi): wolf-lang release 417610226's four archives and wolf-interp release 415937354's five assets, each downloaded twice, both reads equal to the sha256 GitHub publishes (`ARCHIVES-FAIL=0`); the Windows archive is `96774801…`, the linux x86-64 pair `4f955e8d…` / `175df238…` |
| the archive's `std/`, and the book's CI staging step mirrored | `release-assets.txt`: all four archives hold `std/`, 58 files (54 `.lu`), manifest `4382865a…` by wolf-book `3ac6fa9`'s own recipe (book.yml:193 names the same digest), `std/STD-REV` `cceda631…`; the staging step re-run on kasumi exactly as book.yml:173-195 writes it (wolf-std cloned with autocrlf off and checked out at v0.2.33's `STD-PIN`, `std/` copied with the two licences and `STD-REV`): 58 files (54 `.lu`), manifest `4382865a…`, `diff -r` against the linux archive's `std/` IDENTICAL. No file under `std/` names any of 0.2.33's five calls; ruling #85's wrappers (`process.poll`, `Status`, `Group`, `lead_group`, `join_group`, `signal.send_group`, `send_all`, `last`, `realtime`, `text`, `host`) are there. This build runs no `wolf` (§2), so the one `wolf` this lane ran is the published archive's, `std/` beside it as the archive places it |
| tap and AUR | `aur-live.txt`: AUR wolf-lang and wolf-lang-bin 0.2.33-1, lupin and lupin-bin 0.1.54-1, lobo-bin 0.1.4-1; homebrew-wolf `3490dab`'s formulae name `v0.2.33` / `85dab5d7…` (std `cceda631…`) and `v0.1.54` / `0e536e8f…` |
| lupin 0.1.54 on wasm32 | `wasm-control.txt` (script `ww45-wasm-control.sh`): with the patch `PATCHED-EXIT=0`, module `e05169d1…`, imports 0 (`wasm-0154-patched.log`); without it `UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\`` (`wasm-0154-unpatched.log`); wolf-interp#222 still open |
| the guard exits at the wolf pin, here and in CI | `guard-at-wolf-pin.txt` (kasumi, `70d9d98`): `check-lag-phrases: the interpreter is 9 releases behind and /install/ and /play/ have prose for 0 through 8 only — write the sentence, then add its phrase here`, `LAG-EXIT=1`, 90 version-prose lines red (86 literal, 4 stamp), `VP-EXIT=1`, `CC-EXIT=0`. The windows learner path's run at that push, 39341065267 (head `4ef38de`, whose tree's pins are `70d9d98`'s), went red: job 118362456716, step "the specification pin lag the site records", the same line (`windows-at-wolf-pin-118362456716.log`, line 207); the run then shows cancelled because the next push cancelled its second job. The CI plant is in the PR body |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.33 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 9 releases back, and both pages carry 'nine releases' and neither carries another`; `--json`: `{"gap": 9, "phrase": "nine releases", "tagged": true, "commits": 955, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.33"}` |
| stamped lag | `speccommits 955`; `nine hundred and fifty-five commits` once on each built page; on each page `nine releases` once and every other phrase of the closed set 0 times (`build-summary.txt`) |
| census, predicted by machine | `predict.txt`, `census-0233-predicted.json` (script `ww45-predict.py`, run before the first pin moved): 683 / 499 exit / 51 trap / 133 unsupported, 550 candidates; the arrival at `os_signal_ignore_one`; `group_rows.lu` unchanged in class |
| census, four legs | `census-0232-{live,control}.json`, `census-0233-{live,control}.json`, `rows.txt` (script `ww45-rows.py`), driver `ww45-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; modules: the live lupp.us module `bf9877a5…` (lupin 0.1.54, the deploy host's build) and this lane's `e05169d1…` |
| stdout probe, records, the whole running set's stdout | `stdout-probe-{control,live}.txt`; `records-{control,live}.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww45-stdout-all.mjs`): all 683 running programs on the 0.2.33 corpus through both modules, 683 identical in verdict and stdout |
| §34.6's five calls, text(0), §34.6's two programs and §34.5's three, module level | `builtins-{control,live}.txt` (script `ww45-builtins.mjs`, programs `probes/*.lu`: the five calls one each, `os_signal_text(0)`, and the five chapter programs verbatim from wolf-book `3ac6fa9`), identical under both modules: each of `os_signal_ignore_one`, `os_signal_default_one`, `os_exit_signal`, `os_wait_status_core`, `os_wait_poll_core` answers `unsupported`, phase `resolve`, exit 4, `` `<name>` does not resolve ``; `os_signal_text(0)` the process and signal tier's reason; `ch34-one` at `` `signal.kill` does not resolve ``, `ch34-again` at `` `env.args` ``, `ch34-groups` at `` `process.lead_group` ``, `ch34-jobs` at `` `signal.listen` ``, `ch34-nochild` the tier at `os_wait_poll`; 0 instance deaths. ww44's twelve probes and ww43's eighteen through both modules: `builtins-ww44-*.txt`, `builtins-ww43-*.txt`, the two modules identical on each |
| the same at a terminal, and the compiler's answer | `native-0233.txt` (script `ww45-native.sh`), every run inside its own pid namespace (`namespace: pid 1 procs 4 uid 1000 core 0/0`; `SigBlk 0`, `SigIgn 0x6`, INT and QUIT, inherited from the detached launch), the published linux pair from `release-assets.txt`'s reads. lupin 0.1.54: `os/signal_one_rows.lu` and each of the five probes `` unsupported: `<name>` does not resolve `` (exit 4); `os_signal_text(0)` `text(0): invalid`; `group_rows.lu` and `job_poll_rows.lu` print their headers; the chapter's std programs do not resolve `std.*`, the no-child poll prints `nothing to report: -1, 0 live`. wolf 0.2.33 checked (`conform-run --json --checked`) and native: the shape rows `invalid`, `poll_core: -1, 0 live`, `wait_status_core: io`, `text(0): Unknown signal 0`; `one.lu` natively prints the chapter's four lines (`lived through the segment_fault() it sent itself`) and the checked machine refuses it by name (`os_signal_ignore_one` of a fault meaning: the `wolf` process's own stack guard holds them); `again.lu` natively prints `ended by terminate(): true` / `and with a core: false`, and on the checked machine its re-exec reaches the `wolf` binary itself (`wolf: \`again\` is not a wolf command.`), so its first line is false there; the book marks both `wolf-run` (native) |
| modules | lupin 0.1.54 built at `0e536e8f` with the patch, sha256 `e05169d1…`, identical in the control, the measure run and the build's `dist/play/lupin.wasm`; the live module fetched from lupp.us is `bf9877a5…`; ww44's kasumi build was `04ce1322…` (§2 drift 1) |
| the build | `build-summary.txt`: build exit 0; node tests 120 / 120; links 1,546 across 64 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 664 anchors; planted 8 pass; tab-target 5 / 5; version.json lupin 0.1.54, pins 85dab5d / 0e536e8 / 3ac6fa9, spec-pin 294d626, missing []; `This is version 0.2.33.` |
| book assets | `build-summary.txt`: `581 … versioned ?v=3ac6fa9; nothing exempt`, 0 bare, `wolf-boot.js?v=3ac6fa9` on 48 pages; PDF 6,013,287 B (6.0 MB) |
| §34.6 and the /play/ links | `build-summary.txt`: `id="34.1"` … `id="34.6"` once each in `dist/book/ch34.html` (75,895 B), `id="3.3"` once in `ch03.html`; /play/ links `/book/ch34.html#34.6`, `#34.5`, `#34.3` and `/book/ch03.html#3.3` once each |
| /install/'s Windows archive name | `build-summary.txt`: the built page carries `wolf-0.2.33-x86_64-pc-windows-msvc` four times, all from the stamp; the book's ch01 carries the same name twice and 0.2.32's none |
| nothing unreleased is named | no built page anywhere in `dist/` (book, changelogs and spec included) names sc66's wrappers for the five calls on wolf-std `sc66` `11c2741f…` (`wait_status_core`, `status_from_core`, `dumped_core`, `poll_core`, `CoreChange`, `signal.exit_signal`, `ignore_one`, `reset_one`): 0 lines. The front page and /play/ name ruling #85's wrappers, which `cceda63` ships |
| ch07 and the changed pages | `build-summary.txt`: six ch07 SVGs sha-identical to ww44's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww45-book.mjs`): three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, ch01's Windows tar line, ch22's `toolchain 0.2.33` line, the colophon's `wolf 0.2.33 (wolfgang, pin 85dab5d)`, §34.6's `one.lu` and `again.lu` lines and §34.5's std group program each in a code block, 0 CSP violations, 0 console errors on every page (42 page loads). The colophon reads `955 commits, nine releases`; ch22 carries `toolchain 0.2.32` once, inside bs69's audit-ledger HTML comment, which no reader sees |
| /play/ in engines | `play-staged.txt` / `play-staged.json` (script `ww45-play.mjs`, served by `docs/audit/ww42-evidence/ww42-serve.mjs` on 127.0.0.1:8754 with the headers read out of `nginx/lupp.us.conf`): on all six cells the module boots (`lupin 0.1.54 … reading cfg as x86_64-unknown-linux-gnu`), the 36 menu programs run from the menu with the page's Run button (31 exit, 5 trap), the eleven probes each answer as at module level, 0 CSP violations, 0 console errors, and the six cells agree |
| /play/ refuses nothing it served | `play-live-before.txt` / `.json`: the same walk against https://lupp.us before the merge (the ww44 deploy, the same lupin 0.1.54); `play-compare-staged.txt` (script `ww45-play-compare.mjs`): 216 menu runs over six cells, 0 verdicts moved, 0 served before and refused or missing now |
| the site's links, two hops, §34.6 | `links-staged.txt` / `.json` (script `ww45-links.mjs`): on all six cells the front page's 7 links clicked and landed, the 38 further targets landed, ch34 and ch03 in the two-hop set, `ch34.html#34.1` … `#34.6` and `ch03.html#3.3` each landed 200 with its heading found and scrolled to, 0 faults |
| staged contents gate | `gate-staged.txt` / `.json.gz`: 50 pages, 46 entries, 2,300 clicks and 0 faults on all six engine × viewport cells (the book's 404 path is in every cell's walk); retry from ch07 hop 1 and hop 2 92/92 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,116 hop lines (`retry-staged.log`) |
| every staged checker on a plant | `stage-plant.txt` (script `ww45-stage-plant.sh`): an inline script on the front page and /play/, /play/'s §34.6 link removed, ch34's `id="34.6"` renamed, one ch07 SVG removed, ch01's archive name set back to 0.2.32, §34.6's `again.lu` line changed, the menu's last entry removed, `hello.lu` replaced by the `os_exit_signal` probe; served on 127.0.0.1:8755 (`ww45-plant.sh`, `plant.txt`): `book-plant.txt` 19 FAIL lines, `PLANT-BOOK-EXIT=1`; `play-plant.txt` 7 FAIL lines (both inline-script CSP violations on every cell), `PLANT-PLAY-EXIT=1`; `play-compare-plant.txt` 12 served before and refused or missing now (`hello.lu` refused, `wordtree.lu` gone, on six cells), `PLANT-COMPARE-EXIT=1`; `links-plant.txt` six FAIL cells (3 or 4 faults each: both inline scripts, `#34.6` missing, and on chromium and webkit the missing SVG's 404), `PLANT-LINKS-EXIT=1` |
| the prose audits between commits | `ww45-chk.sh`: ships the worktree's `site/`, `scripts/`, `tests/` and `CHANGELOG.md` to kasumi's build clone and runs the lag, version and count audits there, never a build on nomad-1 |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 64; book 49; six SVGs sha-identical | identical |
| version strings, version.json | 0.2.33 / 0.1.54; pins 85dab5d / 0e536e8 / 3ac6fa9, spec-pin 294d626, missing [] | identical |
| lag | gap 9, 955, "nine releases"; the guard exits at the wolf pin, the windows run red there | identical (kasumi `guard-at-wolf-pin.txt`; windows run 39341065267, job 118362456716) |
| census, by machine | 683 / 499 / 51 / 133 / 0 / 550 / 0 died | **683 / 499 / 51 / 133 / 0 / 550 / 0 died**, every row as predicted |
| module leg (live -> kasumi build) | 0 rows move on either corpus | 0 on both |
| whole-set stdout | 683 of 683 identical | 683 of 683 identical |
| §34.6's five in the tab | each `unsupported`, resolve, "does not resolve", not the tier's reason | identical, both modules, six engine cells |
| text(0) in the tab | the process tier | identical |
| the chapter programs | one.lu at `signal.kill`, again.lu at `env.args`, groups at `process.lead_group`, jobs at `signal.listen`, nochild the tier | identical |
| at a terminal | lupin does not resolve the five; wolf prints the chapter's lines | lupin identical; wolf native prints them, the checked machine refuses `one.lu` by name and its `again.lu` re-exec reaches `wolf` itself (not predicted) |
| clocked allowlist lines | 103 reddened (86 / 4 / 13), 37 lupin hold | 103: 90 version-prose lines red at the wolf pin (86 literal, 4 stamp), the 13 count lines re-read in the two pin commits; the 37 lupin lines held on their clock |
| arrivals / leaves | v0.2.32 on four pages; `eight` 3 -> 2 on install, its play entry leaves; `nine` on install, play's 1 -> 2 | v0.2.32 on index (1), spec (2), install (4), play (5); **not predicted:** v0.2.31 arrives on install (1) and play (1), v0.2.30 drops on install (3 -> 2) and play (4 -> 3), one 0.1.53 leaves install (2 -> 1); `eight` / `nine` as predicted |
| lupin 0.1.54 on wasm32 | red unpatched, the patch applies, the build's module equals the control's | identical (`e05169d1…` twice) |
| stamps | 34 / 153 / 34 / 18 / 36; 664 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 6.1 ± 0.2 MB | 6.0 MB (6,013,287 B), inside the band |
| book assets | 581 versioned, 0 bare | 581, 0 bare |
| ch07 and changed chapters under the CSP | 0 violations; six diagrams; #34.1-#34.6 resolve | identical |
| staged gate | 0 faults ×6; retry 92/92 ×2 hops ×6 | identical |
| links, #34.6 in two hops | on all six | identical, with #34.1-#34.5 and #3.3 |
| /play/'s refused list | empty | empty; the declines stand as named |

**Found, not predicted.**
1. **The kasumi module is not ww44's**, at the same pins, patch, toolchain
   pin and host (`04ce1322…` in `~/lanes/ww44/web`, `e05169d1…` in
   `~/lanes/ww45/web`; 22,541 bytes differ, all data-segment offsets, the
   build path embedded 24 times). The module's bytes depend on where it is
   built, so a served module can never be checked against a lane's by
   digest; the census and the stdout walk compare behaviour instead, and
   found none different.
2. **spec/03 caught up** (#788): ww44's raised-not-filed finding is closed by
   0.2.33 itself, and /spec/ says so.
3. **The checked machine and §34.6's programs.** `one.lu` is refused by name
   on `conform-run --checked` (`[os.signal.disp.one]`: the `wolf` process's
   stack guard holds the fault signals) and `again.lu`'s re-exec there runs
   `wolf` itself, so it prints `ended by terminate(): false`; both programs
   are `wolf-run` in the book (native), where they print the chapter's
   lines. Not a site matter; listed for the book.
4. **SigIgn 0x6 inside the pid namespace**: INT and QUIT ignored, inherited
   from the detached (`setsid … &`) launch's non-interactive shell; no
   probe here reads a disposition, but a lane that does must launch
   otherwise.
5. Windows learner runs queue for a long time while the org's twenty-job
   slot budget is held elsewhere; the pin-push run was cancelled by the next
   push after its first job had already gone red.
6. The built `ch22.html` carries `toolchain 0.2.32` once, inside bs69's
   unpublished audit-ledger comment (as ww44's finding 8).

## 5. Done-when

- [x] Branch `ww45` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit; the census
      predicted by machine.
- [x] Three gitlink commits (book, wolf, the interpreter's re-read), each with
      its count-allowlist lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim;
      census table, allowlist diff, probes, page count in §4.
- [x] /play/, chapter 7, the changed pages, §34.6 and the site's links checked
      in three engines × two viewports under the production headers; the
      staged gate's 404 path and ch07 path at 0 faults.
- [x] What the tab answers for §34.6's five calls, measured in the module and
      in the engines.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] The plant seen red in CI (RULES.md §7), reverted.
- [ ] The final head's PR run, handed back with its id (RULES.md §6).
- [ ] After the merge (the orchestrator's): the deploy job's run id, the live
      gate, the live `version.json`, `id="34.6"` live.
- [ ] Worktree removed; kasumi pruned; no orphans.
