# ww44 — The Site at 0.2.32

Class: one repo, one bump (three gitlinks), one deploy. Opus. Crawl 54.
Contract: the planning repo's sprints/web/ww44-the-site-at-0232.md (planning
8fae160, read 2026-10-18), which keeps every rule of ww43's and ww42's (and
through them ww41's and ww40's). One deliverable: lupp.us serves wolf 0.2.32,
lupin 0.1.54 and the book at wolf-book e9862f6 (bs68), every stamped number
derived at the checkout. The site skips 0.2.31: both releases' surfaces
arrive at once, as at ww41. This commit is empty; its message is sections 1
to 3, cut from wolf-web trunk 683f138 with all three gitlinks at ww43's
values. Section 4 lands later in docs/audit/ww44-contract-0232.md; sections 1
to 3 are not edited after this commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests run on kasumi under
  ~/lanes/ww44/. nomad-1 runs git, gh, curl, ssh/scp and the browser gates
  only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww44/bin/; a browser engine the gate needs and a host
  lacks is reported, not installed.
- No rm outside ~/lanes/ww44/ (both hosts); no deletion in any tree this
  lane did not create. No git add -A. Nothing under ~/.claude. No edit to
  another lane's file. Scratch under ~/lanes/ww44/ only, never /tmp.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy, before the merge or after it. PR open, unmerged; the
  orchestrator audits and fast-forwards; the deploy is that push run's
  "deploy to lupp.us" job (sprints/HOSTING.md). No ssh to almanta, no
  scripts/deploy.sh or ci-deploy.sh run by this lane, no nginx, no tunnel or
  its config, no DNS, no listing of cloudflared's arguments.
- The site describes the RELEASED toolchain: wolf 0.2.32, lupin 0.1.54 and
  the std the archive bundles (wolf-std d37c911). Nothing from wolf-lang or
  wolf-std trunk (ruling #85's wrappers at dcf3e89: process.poll, Status,
  Group, lead_group, join_group, signal.send_group, send_all, last,
  realtime, text, host) is shown as available.
- No merge, tag, issue filed or closed, cancelled run of another lane. No
  2>/dev/null on a checkout; the branch is asserted before every commit.
- No "seen red" without a run id, sha, path or digest in the same
  paragraph. File checksums carry a trailing ….
- Kill only this lane's own pids, recorded at launch; on kasumi killable
  jobs start under setsid, never ssh -f, never a process-group kill. Host
  ports 8080 and 8088 are not used; a preview server binds loopback on a
  recorded port and is stopped by pid.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-18 23:59 - 2026-10-19 00:05 UTC, before any gitlink moves)

Script ww44-derive.sh, log derive.log, ww44-archives.sh, release-assets.txt,
ww44-wasm-control.sh, wasm-control.txt (kasumi ~/lanes/ww44/, landing under
docs/audit/ww44-evidence/); release facts read with gh on nomad-1.

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | 683f138 (ww43) | 683f138fc6ca… ; PR #62 the last merged | gh api |
| gitlinks at trunk | 0.2.30 / 0.1.53 / 95d68ad | wolf-lang 1b37f368… (v0.2.30), wolf-interp 7896eddc… (v0.1.53), book 95d68ad0… | git submodule status |
| live version.json | — | built 2026-10-16T23:43:15Z, lupin 0.1.53, pins 1b37f36 / 7896edd / 95d68ad, spec-pin 294d626, missing [] | curl https://lupp.us/version.json |
| live headers | CSP blocks inline scripts | server nginx/1.20.1; content-security-policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'self' | curl -sI https://lupp.us |
| wolf 0.2.32 | v0.2.32 at 72de141f | v0.2.32 -> 72de141f6246…; release 416327027, draft false, 4 archives, published 2026-10-18T08:38:14Z; wolf-lang trunk = 72de141f | gh api; derive.log |
| wolf 0.2.31 (skipped by the site) | — | v0.2.31 -> f4faf59d…; release 416069503, 4 archives, published 2026-10-17T21:33:07Z | gh api |
| lupin 0.1.54 | v0.1.54 at 0e536e8 | v0.1.54 -> 0e536e8fb451…; release 415937354, 5 assets, published 2026-10-17T16:48:34Z; Cargo.toml 0.1.54; 43 commits since 7896eddc | gh api; derive.log |
| archives by digest, each read twice | — | all four wolf archives and all five lupin assets downloaded twice, both reads equal to GitHub's digest (ARCHIVES-FAIL=0); linux x86-64 wolf --version: `wolf 0.2.32 (wolfgang, pin 72de141)` / `paired with lupin 0.1.54 (reference interpreter), pin 294d626`; lupin: `lupin 0.1.54 (wolf-interp, reference interpreter at pin 294d626)` | release-assets.txt |
| lupin's spec gitlink | — | 294d626d = v0.2.24 at 0.1.53 AND 0.1.54: UNCHANGED | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of 72de141f (exit 0); rev-list --count 294d626d..72de141f = 913; 1b37f368..72de141f = 196 (v0.2.30..v0.2.31 170, v0.2.31..v0.2.32 26); CHANGELOG heads 0.2.32 … 0.2.25 above 0.2.24, so the counted gap = 8 | derive.log |
| book target | e9862f6 (bs68) | wolf-book trunk e9862f6abe63…; 95d68ad0 an ancestor, 22 commits; SUMMARY byte-identical (404c8c4b), 34 chapters; book/ changes: ch01, ch03 (§3.3's shift paragraph, two programs; the E0801 sample s16 -> s18), ch22, ch33 (§33.3 exit 71), ch34 (§34.5 Groups, and what the children did, its subsection The children's changes), back/colophon, back/solutions; book/diagrams untouched | derive.log |
| ch01's Windows block | names wolf-0.2.32-x86_64-pc-windows-msvc | book/ch01.md:237-238 at e9862f6 do; /install/ stamps the same name from __WOLF_VERSION__ (site/install/index.html:144, 149, 161) | derive.log |
| the book render and std/ | any wolf the site builds needs std/ beside it; mirror the book's staging and manifest 1f7389b7…, 58 files | the site builds no wolf: at e9862f6 `xtask render` still runs typst (render.rs:522) and git (highlight.rs:346) only. book.yml:173-195 is the staging step and names 1f7389b7a666… for the 0.2.32 archive. All four 0.2.32 archives hold std/, 58 files, manifest 1f7389b7… by that step's own recipe, STD-REV d37c911f… | derive.log; release-assets.txt |
| bundled std | wolf-std d37c911 | 0.2.31 and 0.2.32 CHANGELOGs: the bundled std is d37c911 at both (0.2.30 shipped fd6bcdc); it adds env.uid … groups, fs.set_owner …, process.set_ids, std.os.users, term.size, term.chars, signal.wait_fd, and no wrapper for 0.2.31's seven builtins; no file under the archive's std/ names any of the seven | derive.log; release-assets.txt |
| linux aarch64 at 0.2.32 | — | release run 39111522633, job 117630431208 (run gate, ubuntu-22.04-arm): `wolf 0.2.32 (wolfgang, pin 72de141)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` | release-0232-rungate-arm-117630431208.log |
| corpus | — | phase: run set 670 -> 682: 12 in (comptime/shift_value, four faults/int_shift_*, kernels/wrap_lshr_fold, os/group_rows, os/job_poll_rows, typecheck/int_shift_value, three typecheck/straight_line_sh*), 0 out; one run program modified (memory/raw_lshr_top_bits.lu, its header comment only); anchors 648 -> 661 (13 added, 0 dropped); grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18 unchanged; docs/platforms.md unchanged | derive.log |
| 0.2.31's seven builtins in lupin | hosted-only | builtin.rs at 0e536e8: on a hosted build the six group, host-number and text calls answer their shape rows and refuse each well-formed call by name, os_wait_poll answers (-1, 0) with no child and is refused by name with one; under cfg(target_family = "wasm") all seven sit in the process tier's decline arm (builtin.rs:710-752), whose reason is now hosted_tier_decline's (#245): "belongs to the hosted-only process and signal tier … no host process of its own" | derive.log |
| lupin 0.1.54 on wasm32 | the wasm path as ww43 left it | wolf-interp#222 open; as released it fails (`UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\``); the carried patch (sha256 2cc2b8a3…) applies unchanged, `PATCHED-EXIT=0`, imports 0, module 04ce1322… | wasm-control.txt |
| tap and AUR | — | AUR wolf-lang and wolf-lang-bin 0.2.32-1, lupin and lupin-bin 0.1.54-1, lobo-bin 0.1.4-1; the tap names v0.2.32 / 72de141f… (std d37c911f…) and v0.1.54 / 0e536e8f… | aur-live.txt |
| wolf-lang and wolf-std trunk | not shown as available | wolf-lang trunk is v0.2.32 itself; wolf-std dcf3e89 adds process.poll, Status, Group and the signal group wrappers, none released; a grep of site/ for 0.2.31's seven builtins, the shift rule and exit 71 finds 0 lines | derive.log |

Drift, reported:
1. **The gap reaches eight releases** (913 commits), two past the guard's
   closed set: the site skipped 0.2.31, so the counted gap jumps from six to
   eight. At the wolf pin the guard will exit naming the missing phrase.
   Both pages' sentences get written, then `seven releases` (so a page left
   at seven is refused, never written) and `eight releases` join the set.
2. The contract asks for the book CI's std staging step to be mirrored;
   this build runs no wolf, so there is nothing to mirror it onto (as ww41
   to ww43 found). The manifest is checked against the four published
   archives instead (release-assets.txt). Reported, not absorbed.
3. wolf's CHANGELOG counts 153 commits for 0.2.31 and 22 for 0.2.32, "then"
   the release commits; git counts 170 and 26. The stamp is git's.
4. The worktree is ~/lanes/ww44/wolf-web (nomad-1); the build clone is
   ~/lanes/ww44/web (kasumi).

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 64 dry, 64 live (no new chapter); the book's web edition
49 pages. The six ch07 SVGs sha-identical to ww43's.

3.2 Version strings. /install/ and /play/ stamp 0.2.32 and 0.1.54; the
Windows archive link reads wolf-0.2.32-x86_64-pc-windows-msvc.tar.gz, as
ch01 §1.2 does. version.json: lupin 0.1.54, pins wolf-lang 72de141,
wolf-interp 0e536e8, wolf-book e9862f6, spec-pin 294d626, missing [].

3.3 The lag. After the phrases are added, check-lag-phrases.py --json
answers {"gap": 8, "phrase": "eight releases", "tagged": true, "commits":
913, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.32"}. The
stamped distance "seven hundred and seventeen" -> "nine hundred and
thirteen". The guard exits at the wolf pin commit and still at the lupin pin
commit (0.1.54 keeps the v0.2.24 pin); it goes green only with the new
phrases and both pages rewritten. Falsified by: any other gap or count, or a
guard that passes at either pin commit.

3.4 The census at 0.2.32 / 0.1.54. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.30 and 0.2.32 corpora x the live 0.1.53 module,
fetched from lupp.us, and the built 0.1.54). Baseline: the live module on
the 0.2.30 corpus (ww43's served census, 670 / 494 / 47 / 129 / 0).

| class | live (0.2.30 / 0.1.53) | ww44 predicted | delta |
|---|---|---|---|
| programs | 670 | 682 | +12 |
| exit | 494 | 500 | +6 |
| trap | 47 | 51 | +4 |
| unsupported | 129 | 131 | +2 |
| fail | 0 | 0 | 0 |
| candidates | 541 | 551 | +10 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.30 corpus (0.1.53 -> 0.1.54): 0 rows change class
(the process tier's reason words change with #245, not its class). The
twelve arrivals under 0.1.54: comptime/shift_value, kernels/wrap_lshr_fold,
typecheck/int_shift_value and the three straight_line_sh* exit 0 printing
their headers' lines; the four faults/int_shift_* trap overflow;
os/group_rows and os/job_poll_rows are declined at their first new call with
the process tier. Under 0.1.53 the same six exit and the same four trap
(lupin 0.1.52 trapped them already, by their headers), and the two os rows
are unsupported (a name that does not resolve) (least firm: shift_value
under 0.1.53, whose module constants is76 changed). Whole-set stdout walk:
682 of 682 identical across the two modules in verdict and stdout, save
reason words.

3.5 §34.5's builtins in the tab. Each of the seven (os_signal_send_group,
os_signal_send_all, os_set_pgid, os_signal_last, os_signal_realtime,
os_signal_text, os_wait_poll), one call alone through the built 0.1.54
module, answers verdict unsupported naming the call, with the hosted-only
process and signal tier's reason; none runs, none traps, none kills the
instance. Under the live 0.1.53 module each does not resolve. §34.5's
programs: groups.lu and jobs.lu (`use std.signal`) are unsupported in the
tab under both modules, as every `use std` program is; nochild.lu, the
chapter's one `run(…)` block, is unsupported in the tab under 0.1.54 (the
poll is declined with the tier) although lupin at a terminal answers it
`(-1, 0)`, and does not resolve under 0.1.53. §3.3's shift.lu traps overflow
after printing `100 0` and rotate.lu exits 0 printing `144 1 200`, under
both modules. So the tab refuses nothing it served before.

3.6 Allowlist lines. All three clocks move (wolf 0.2.30 -> 0.2.32, lupin
0.1.53 -> 0.1.54, book 95d68ad -> e9862f6), so every clocked entry reddens:
133 — version-allowlist 109 (80 wolf, 29 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book), entry lines only.
Predicted to arrive: v0.2.30 where 0.2.30's paragraphs become history
(front page, /spec/, /install/, /play/), 0.1.53 on /install/ and /play/.
The lag phrase is a number word: `six` -1 and `eight` +1 on /install/ and
/play/.

3.7 lupin 0.1.54 on wasm32. As released it still fails (E0433;
wolf-interp#222 open); the carried wasm-portability.patch (sha256 2cc2b8a3…)
applies unchanged and the module imports nothing (measured in §2 already,
wasm-control.txt; the prediction is that the build at the lupin pin
reproduces the control's module, 04ce1322…).

3.8 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.32's story leads, with 0.2.31's (a closed standard
  descriptor stays closed and the dev tier makes the hub and the set only
  where they are reached, #778; the checked machine's net_wait and big
  writes hand over, #720 #777; the shift rule, #736, ruling #77; exit 71 at
  start when the runtime cannot make its readiness set or signal hub,
  ruling #80; the poll of the children, 256 + N, and a signal wait with no
  timer, #680, ruling #84; the group send, the move into a group, host
  numbers and a signal's words, #739 #740 #741 #762, ruling #79; the
  bundled std at d37c911 wraps 0.2.30's calls and none of 0.2.31's seven);
  0.2.30's becomes history beside 0.2.29's.
- /install/: the lag paragraph at eight releases; the arrivals paragraph
  re-derived from the census; the declines unchanged.
- /play/: the lag at eight releases; what the tab answers for the seven
  new names; the process tier's reason no longer calls the id and terminal
  calls the process trio (#245), so ww43's sentence saying it does is false
  and goes; the refused list re-derived (3.9).
- /spec/: the bound sentences gain 0.2.31's anchors (10's shift rule, 11's
  group send, host numbers, text, poll, hub and reactor).
- /reading/: no chapter added; re-read only.
- linux aarch64 sentences: re-read against the 0.2.32 release run's arm
  gate; no edit beyond the stamp expected.

3.9 /play/'s refused list after the bump: EMPTY (0 refusals, 0 output
partings). Declines that stand: the three whole-struct raw stores,
extern_let_image, extern_libc; atomic_counter the tab's; chdir_relative
still the near miss.

3.10 Stamps other than the distance: bookchapters 34, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 661
anchors. The menu: 36 programs, every one in class.

3.11 The PDF. 6.0 MB +- 0.2 MB (bs68 adds about 300 lines).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=e9862f6, 0 bare, 581 references.

3.13 ch07's diagrams and the changed chapters (ch01, ch03, ch22, ch33,
ch34) load under the production CSP (staged from kasumi's dist/book under
lupp.us's headers, then live): 0 CSP violations, 0 console errors, ch07's
six diagrams rendered on three engines x two viewports; ch01 carries
wolf-0.2.32-x86_64-pc-windows-msvc, ch22 `toolchain 0.2.32`; ch34's anchor
#34.5 resolves.

3.14 The staged gate (three engines x two viewports): 0 faults each;
--retry from ch07.html hop 1 and hop 2 at 92/92 on all six. The links walk
two hops deep reaches ch34.html#34.5 on all six (through /play/'s link,
which names §34.5 after this lane's paragraph).

3.15 The PR's CI does not deploy: the run at the PR head has a `build the
site` job and its `deploy to lupp.us` job is skipped (pull_request event).
After the orchestrator's fast-forward the push run's deploy job deploys;
live version.json = 3.2.

3.16 The live gate (three engines, two viewports): 0 faults, hop 1 and hop
2 92/92 on all six, 0 HTTP 404 lines; #34.5 live.

What I expect to get wrong: shift_value's class under 0.1.53, whether the
census records reason words (and so whether the module leg moves verdict
strings), the allowlist arrivals' counts, and the PDF size.



## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `37fd0a6` (an empty commit), unedited.* Built on kasumi at
`d40b64b` (`build-summary.txt`, the build the staged gates served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1: kasumi
has no Playwright and no WebKit, nothing was installed, and the three engines
are the ones playwright-core 1.63.0 already had cached on nomad-1, as ww41 to
ww43 used them. Files are under `docs/audit/ww44-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `37fd0a6`, first pin `6b14a12`; `37fd0a6` was pushed to origin before any pin |
| three gitlink commits | book `6b14a12` (-> `e9862f6a`, all 4 book count lines hold), wolf `499ddc4` (-> `72de141f`, 9 wolf count lines hold), lupin `d625618` (-> `0e536e8f`, 5 lupin count lines hold; `crates/lupin-wasm/wasm-portability.patch` unchanged, sha256 `2cc2b8a3…`) |
| inputs, lag, corpus sets, anchors, grammar, the arrivals' headers, the book's diff, the 0.2.31 and 0.2.32 CHANGELOGs and 0.1.54's, lupin's seven builtins | `derive.log` (script `ww44-derive.sh`) |
| linux aarch64 at 0.2.32 | `release-0232-rungate-arm-117630431208.log`: release run 39111522633, job 117630431208 (run gate, ubuntu-22.04-arm): `wolf 0.2.32 (wolfgang, pin 72de141)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` |
| archive digests, each read twice | `release-assets.txt` (script `ww44-archives.sh`, kasumi): wolf-lang release 416327027's four archives and wolf-interp release 415937354's five assets, each downloaded twice, both reads equal to the sha256 GitHub publishes (`ARCHIVES-FAIL=0`); the Windows archive is `40eb42af…`, the linux x86-64 pair `4c37f9c5…` / `175df238…` |
| the archive's `std/` and the book's manifest check | `release-assets.txt`: all four wolf archives hold `std/`, 58 files, manifest `1f7389b7…` by wolf-book `e9862f6`'s own recipe (book.yml:193 names the same digest), `std/STD-REV` = `d37c911f…`; no file under it names any of 0.2.31's seven builtins, and `std/process` declares no `poll` (ruling #85's wrappers are wolf-std trunk). This build runs no `wolf`, so there is no binary here to stage it beside (§2) |
| tap and AUR | `aur-live.txt`: AUR wolf-lang and wolf-lang-bin 0.2.32-1, lupin and lupin-bin 0.1.54-1, lobo-bin 0.1.4-1; the tap's formulae name `v0.2.32` / `72de141f…` (std `d37c911f…`) and `v0.1.54` / `0e536e8f…` |
| lupin 0.1.54 on wasm32 | `wasm-control.txt` (script `ww44-wasm-control.sh`): with the patch `PATCHED-EXIT=0`, module `04ce1322…`, imports 0 (`wasm-0154-patched.log`); without it `UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\`` (`wasm-0154-unpatched.log`); wolf-interp#222 still open |
| the guard exits at the wolf pin | `guard-at-wolf-pin.txt` (kasumi, `499ddc4`): `check-lag-phrases: the interpreter is 8 releases behind and /install/ and /play/ have prose for 0 through 6 only — write the sentence, then add its phrase here`, `LAG-EXIT=1`, 84 version-prose lines red, `VP-EXIT=1`, `CC-EXIT=0` |
| and still at the lupin pin, here and in CI | `guard-at-lupin-pin.txt` (kasumi, `d625618`): the same line, `LAG-EXIT=1`, 115 version-prose lines (109 literal, 6 stamp), `VP-EXIT=1`, `CC-EXIT=0`. The windows learner path's run at that push, 39179322242 (head `d625618`), went red: job 117828507138, step "the specification pin lag the site records", the same line (`windows-at-lupin-pin-117828507138.log`, line 207). The CI plant is in the PR body |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.32 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 8 releases back, and both pages carry 'eight releases' and neither carries another`; `--json`: `{"gap": 8, "phrase": "eight releases", "tagged": true, "commits": 913, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.32"}` |
| stamped lag | `speccommits 913`; `nine hundred and thirteen commits` once on each built page; on each page `eight releases` once and every other phrase of the closed set 0 times (`build-summary.txt`) |
| census, four legs | `census-0230-015{3,4}.json`, `census-0232-015{3,4}.json`, `rows.txt` (script `ww44-rows.py`), driver `ww44-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified |
| stdout probe, records, the whole running set's stdout | `stdout-probe-0154.txt`, `stdout-probe-0153.txt`; `records-0154.txt`, `records-0153.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww44-stdout-all.mjs`): all 682 running programs on the 0.2.32 corpus through both modules, 682 identical in verdict and stdout |
| §34.5's builtins and programs and §3.3's two, module level | `builtins-0154.txt`, `builtins-0153.txt` (script `ww44-builtins.mjs`, programs `probes/*.lu`: the seven new calls one each, §34.5's three programs and §3.3's two verbatim from wolf-book `e9862f6`): under 0.1.54 each of `os_signal_send_group`, `os_signal_send_all`, `os_set_pgid`, `os_signal_last`, `os_signal_realtime`, `os_signal_text`, `os_wait_poll` answers `unsupported`, phase `resolve`, exit 4, `` `<name>` belongs to the hosted-only process and signal tier ([os.proc], [os.signal]): this wasm build runs in a page, with no host process of its own to ask about, signal from or start another from, so the tier is declined rather than mocked ``; `ch34-groups` the same at `os_set_pgid`, `ch34-nochild` the same at `os_wait_poll`, `ch34-jobs` at `` `signal.listen` does not resolve ``; `ch03-shift` prints `100 0` and traps `overflow` (exit 3), `ch03-rotate` exits 0 printing `144 1 200`; under 0.1.53 each new name `does not resolve` and the two §3.3 programs answer the same; 0 instance deaths. ww43's eighteen probes through both: `builtins-ww43-015{3,4}.txt`, the verdicts unchanged, the process tier's words #245's under 0.1.54 |
| the same at a terminal, and the compiler's answer | `native-0154.txt` (script `ww44-native.sh`): the published lupin 0.1.54 and wolf 0.2.32 linux archives (`175df238…`, `4c37f9c5…`, each equal to GitHub's digest). lupin: `os/group_rows.lu` and `os/job_poll_rows.lu` print their headers, `os_set_pgid(-1)` is `invalid`, `os_wait_poll()` and §34.5's no-child program print `-1, 0 live`, and each well-formed group call, the host range and a signal's words are refused by name (exit 4, `… and this machine admits no unsafe`); `comptime/shift_value.lu` is declined at its `comptime fn` (exit 4); the shift programs print or trap as their headers say; the standing declines decline; §34.5's std programs do not resolve `std.*` (lupin's archive ships no std). wolf 0.2.32: all twelve probes run on the checked machine and on native and print the chapter's lines (groups: `leads a group of its own: true` … `host numbers past the table's: true`; jobs: `a stop: true, by stop(): true` … `then: -1, 0 live`) |
| modules | lupin 0.1.54 built at `0e536e8f` with the patch, sha256 `04ce1322…`, identical in the control, the measure run and the build's `dist/play/lupin.wasm`; the 0.1.53 control is the live module fetched from lupp.us, `e8e187ed…` (`measure.log`) |
| the build | `build-summary.txt`: build exit 0; node tests 120 / 120; links 1,545 across 64 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 661 anchors; planted 8 pass; tab-target 5 / 5; version.json lupin 0.1.54, pins 72de141 / 0e536e8 / e9862f6, spec-pin 294d626, missing [] |
| book assets | `build-summary.txt`: `581 … versioned ?v=e9862f6; nothing exempt`, 0 bare, `wolf-boot.js?v=e9862f6` on 48 pages; PDF 5,982,488 B |
| §34.5 and §3.3 | `build-summary.txt`: `id="34.1"` … `id="34.5"` once each in `dist/book/ch34.html` (62,070 B), `id="3.3"` once in `ch03.html`; /play/ links `/book/ch34.html#34.5`, `#34.3` and `/book/ch03.html#3.3` once each; ch33 carries `exit status is 71` once |
| /install/'s Windows archive name | `build-summary.txt`: the built page carries `wolf-0.2.32-x86_64-pc-windows-msvc` four times, all from the stamp; the book's ch01 carries the same name twice and 0.2.30's none |
| nothing unreleased is named | `build-summary.txt`: no built page outside the rendered changelogs, spec and book names ruling #85's wrappers at wolf-std `dcf3e89` (`process.poll`, `Status`, `Group`, `lead_group`, `join_group`, `signal.send_group` …) (0 lines) |
| ch07 and the changed pages | `build-summary.txt`: six ch07 SVGs sha-identical to ww43's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww44-book.mjs`): three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, ch01's Windows tar line, ch22's `toolchain 0.2.32` line, the colophon's pairing line, ch03's `wrapping[u8]` program, ch33's exit-71 line and §34.5's group program each in a code block, 0 CSP violations, 0 console errors on every page. The checker on a plant (one SVG removed, ch01's archive name set back to 0.2.30, ch03's `wrapping` type changed, beside the other plants below): `book-plant.txt`, 19 FAIL lines, `PLANT-BOOK-EXIT=1` |
| /play/ in engines | `play-staged.txt` / `play-staged.json` (script `ww44-play.mjs`, served by `docs/audit/ww42-evidence/ww42-serve.mjs` on 127.0.0.1:8744 with the headers read out of `nginx/lupp.us.conf`): on all six cells the module boots (`lupin 0.1.54 … reading cfg as x86_64-unknown-linux-gnu`), the 36 menu programs run from the menu with the page's Run button (31 exit, 5 trap), the twelve probes each answer as at module level, 0 CSP violations, 0 console errors, and the six cells agree |
| /play/ refuses nothing it served | `play-live-before.txt` / `.json`: the same walk against https://lupp.us before the merge (lupin 0.1.53); `play-compare-staged.txt` (script `ww44-play-compare.mjs`): 216 menu runs over six cells, 0 verdicts moved, 0 served before and refused or missing now. The checker and the comparison on a plant (an inline script in the page, the menu's last entry removed, `hello.lu` replaced by the `os_wait_poll` probe): `play-plant.txt`, 7 FAIL lines, `PLANT-PLAY-EXIT=1`; `play-compare-plant.txt`, 12 served before and refused or missing now, `PLANT-COMPARE-EXIT=1` |
| the site's links, two hops, §34.5 and §3.3 | `links-staged.txt` / `.json.gz` (script `ww44-links.mjs`): on all six cells the front page's 7 links clicked and landed, the 37 further targets landed, ch34 and ch03 in the two-hop set, `ch34.html#34.1` … `#34.5` and `ch03.html#3.3` each landed 200 with its heading found and scrolled to, 0 faults. On the plant (an inline script on the front page and /play/, /play/'s §34.5 link removed, `id="34.5"` renamed, a ch07 SVG gone): `links-plant.txt`, six FAIL cells (3 or 4 faults each), each naming both inline scripts and `#34.5` missing, chromium and webkit the missing SVG's 404 too, `PLANT-LINKS-EXIT=1` (scripts `ww44-gate-staged.sh`, `ww44-plant.sh`; output `gate-staged.txt`, `plant.txt`) |
| staged contents gate | `gate-staged.txt` / `.json.gz`: 50 pages, 46 entries, 2,300 clicks and 0 faults on all six engine × viewport cells (the book's 404 path is in every cell's walk); retry from ch07 hop 1 and hop 2 92/92 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,116 hop lines (`retry-staged.log`) |
| the prose audits between commits | `ww44-chk.sh`: ships the worktree's `site/`, `scripts/`, `tests/` and `CHANGELOG.md` to kasumi's build clone and runs the lag, version and count audits there, never a build on nomad-1 |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 64; book 49; six SVGs sha-identical | 64; book 49; six SVGs sha-identical |
| version strings, version.json | 0.2.32 / 0.1.54; pins 72de141 / 0e536e8 / e9862f6, spec-pin 294d626, missing [] | identical |
| lag | gap 8, 913, "eight releases"; the guard exits at the wolf pin and the lupin pin | identical (kasumi; and the windows run at the lupin pin push went red in CI, 39179322242) |
| census | 682 / 500 / 51 / 131 / 0 / 551 / 0 died | **682 / 499 / 51 / 132 / 0 / 550 / 0 died**: one row off, `comptime/shift_value.lu`, unsupported, not exit |
| module leg on the 0.2.30 corpus | 0 rows move | 0 rows move, on either corpus |
| the arrivals | 6 exit, 4 trap, 2 unsupported; the same under 0.1.53 | 5 exit, 4 trap, 3 unsupported (shift_value declined at its `comptime fn` under both modules: lupin declines compile-time evaluation by name); the same under 0.1.53 |
| whole-set stdout | 682 of 682 identical, save reason words | 682 of 682 identical (the census does not compare the reason's words; the probes show them) |
| §34.5's builtins in the tab | each unsupported by name with the process and signal tier; under 0.1.53 none resolves; groups and jobs unsupported, nochild unsupported | identical; groups.lu stops at `os_set_pgid` before its std import is needed |
| §3.3 in the tab | shift traps after `100 0`, rotate prints `144 1 200`, under both | identical |
| clocked allowlist lines | 133 (109 / 6 / 18) | **133 (109 / 6 / 18)**: 115 version-prose lines red at the lupin pin, the 18 count lines re-read in the three pin commits |
| arrivals / leaves | v0.2.30 on four pages, 0.1.53 on install and play; `six` −1 and `eight` +1 on install and play | v0.2.30 on index (1), spec (2), install (3), play (4); 0.1.53 on install (2), play (1); `six` and `eight` as predicted; **not predicted:** v0.2.31 arrives on index (2) and spec (3); v0.2.29 drops on install (3 -> 2) and play (4 -> 3); 0.1.52 drops on install (2 -> 1) and leaves play |
| lupin 0.1.54 on wasm32 | red unpatched (E0433), the patch applies unchanged, 0 imports, the build's module equals the control's | identical (`04ce1322…` three times) |
| stamps | 34 / 153 / 34 / 18 / 36; 661 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 6.0 ± 0.2 MB | 6.0 MB (5,982,488 B) |
| book assets | 581 versioned, 0 bare | 581, 0 bare |
| ch07 and changed chapters under the CSP | 0 violations; six diagrams rendered; #34.5 resolves | 0 violations and six diagrams on ch07, ch01, ch03, ch22, ch33, the colophon and ch34 |
| staged gate | 0 faults ×6; retry 92/92 ×2 hops ×6 | identical |
| links, #34.5 in two hops | on all six | identical, and #3.3 with it |
| /play/'s refused list | empty | empty; the declines stand as named |

**Found, not predicted.**
1. **`comptime/shift_value.lu` is declined, not run.** Its shifts are inside a
   `comptime fn`, and lupin declines compile-time evaluation by name in every
   build (`` `wrapped` is a `comptime fn` ``, records-0154.txt and
   native-0154.txt). /install/ and /play/ say so.
2. **spec/03's `[conc.task.order]` still names `os_signal_wait` as the wait
   that polls** (~196 futex calls a second, 03-concurrency.md:228 and 239 at
   v0.2.32), while 0.2.31's CHANGELOG says an idle signal wait makes none now
   (s242, #680). /spec/ says the document has not caught up. Not filed (this
   lane files nothing); listed in the report.
3. **§34.5's one `run(…)` block is declined in the tab.** The book runs
   `os_wait_poll` with no child on lupin at a terminal, where it answers
   `(-1, 0)` without the host; the wasm build declines the whole process and
   signal tier before that answer (builtin.rs:710-752 at `0e536e8`). /play/
   says so. Not filed; listed.
4. **The guard's red was seen in CI at the pin this time.** The windows
   learner path ran at the lupin pin push and went red on the lag step
   (39179322242, job 117828507138); at ww43 both pin runs were cancelled by
   the next push.
5. **The live 0.1.53 module is not ww43's kasumi build.** lupp.us serves
   `e8e187ed…`; ww43's control was `5904cf96…`. The deploy host builds its own
   module, as ww42 and ww43 found.
6. wolf's CHANGELOG counts 153 commits for 0.2.31 and 22 for 0.2.32 before
   the release commits; git counts 170 and 26 (§2).
7. /install/'s Windows refusal count still reads docs/platforms.md, unchanged
   since v0.2.29 (#749 open); 0.2.31's group calls are `unsupported` on
   windows by the spec and unlisted there too. Left as ww41 to ww43 left it.
8. The built `ch22.html` carries `toolchain 0.2.30` once, inside bs67's
   unpublished audit-ledger comment, which the render passes through as an
   HTML comment; no reader sees it.

## 5. Done-when

- [x] Branch `ww44` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim;
      census table, allowlist diff, probes, page count in §4.
- [x] /play/, chapter 7, the changed pages, §34.5 and §3.3, and the site's
      links checked in three engines × two viewports under the production
      headers; the staged gate's 404 path and ch07 path at 0 faults.
- [x] What the tab answers for §34.5's builtins, measured in the module and in
      the engines.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion; the
      PR's run does not deploy.
- [ ] After the merge: the deploy job's run id, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
