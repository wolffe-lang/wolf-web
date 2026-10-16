# ww43 — The Site at 0.2.30

Class: one repo, one bump (three gitlinks), one deploy. Opus. Crawl 54.
Contract: the planning repo's sprints/web/ww43-the-site-at-0230.md (planning
ac09382, read 2026-10-16), which keeps every rule of ww42's and ww41's (and
through them ww40's). One deliverable: lupp.us serves wolf 0.2.30, lupin
0.1.53 and the book at wolf-book 95d68ad (bs67), every stamped number derived
at the checkout. This commit is empty; its message is sections 1 to 3, cut
from wolf-web trunk ddedc61 with all three gitlinks at ww42's values. Section
4 lands later in docs/audit/ww43-contract-0230.md; sections 1 to 3 are not
edited after this commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests run on kasumi under
  ~/lanes/ww43/. nomad-1 runs git, gh, curl, ssh/scp and the browser gates
  only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww43/bin/; a browser engine the gate needs and a host
  lacks is reported, not installed.
- No rm outside ~/lanes/ww43/ (both hosts); no deletion in any tree this
  lane did not create. No git add -A. Nothing under ~/.claude. No edit to
  another lane's file. Scratch under ~/lanes/ww43/ only, never /tmp.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy, before the merge or after it. PR open, unmerged; the
  orchestrator audits and fast-forwards; the deploy is that push run's
  "deploy to lupp.us" job (sprints/HOSTING.md). No ssh to almanta, no
  scripts/deploy.sh or ci-deploy.sh run by this lane, no nginx, no tunnel or
  its config, no DNS, no listing of cloudflared's arguments.
- The site describes the RELEASED toolchain: wolf 0.2.30, lupin 0.1.53 and
  the std the archive bundles (wolf-std fd6bcdc). Nothing from wolf-lang or
  wolf-std trunk (0.2.31's shift rule, wolf-std#65's id wrappers, std
  wrappers for s234's three calls) is shown as available.
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

## 2. Inputs, verified (re-derived 2026-10-16 21:54-21:58 UTC, before any gitlink moves)

Script ww43-derive.sh, log derive.log, ww43-archives.sh, release-assets.txt
(kasumi ~/lanes/ww43/, landing under docs/audit/ww43-evidence/); release facts
read with gh on nomad-1.

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | ddedc61 (ww42) | ddedc612d79f… ; PR #61 the last merged | gh api |
| gitlinks at trunk | 0.2.29 / 0.1.52 / 0a5fecc | wolf-lang 6ffe7c60… (v0.2.29), wolf-interp 025428b7… (v0.1.52), book 0a5fecc0… | git submodule status |
| live version.json | — | built 2026-10-14T01:07:21Z, lupin 0.1.52, pins 6ffe7c6 / 025428b / 0a5fecc, spec-pin 294d626, missing [] | curl https://lupp.us/version.json |
| live headers | CSP blocks inline scripts | server nginx/1.20.1; content-security-policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self'; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'self' | curl -sI https://lupp.us |
| wolf 0.2.30 | v0.2.30 at 1b37f368 | v0.2.30 -> 1b37f368228d…; release 413582739, draft false, 4 archives, published 2026-10-15T08:53:05Z | gh api; derive.log |
| lupin 0.1.53 | v0.1.53 at 7896edd | v0.1.53 -> 7896eddc17fd…; release 413375414, 5 assets, published 2026-10-15T03:01:38Z; Cargo.toml 0.1.53; 26 commits since 025428b7 | gh api; derive.log |
| archives by digest, each read twice | — | all four wolf archives and all five lupin assets downloaded twice, both reads equal to GitHub's digest (ARCHIVES-FAIL=0); linux x86-64 wolf --version: `wolf 0.2.30 (wolfgang, pin 1b37f36)` / `paired with lupin 0.1.53 (reference interpreter), pin 294d626` | release-assets.txt |
| lupin's spec gitlink | — | 294d626d = v0.2.24 at 0.1.52 AND 0.1.53: UNCHANGED | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of 1b37f368 (exit 0); rev-list --count 294d626d..1b37f368 = 717; 6ffe7c60..1b37f368 = 106; CHANGELOG heads 0.2.30, 0.2.29, 0.2.28, 0.2.27, 0.2.26, 0.2.25, so the counted gap = 6 | derive.log |
| book target | 95d68ad (bs67) | wolf-book trunk 95d68ad0e4f7…; 0a5fecc0 an ancestor, 25 commits; SUMMARY c5819603 -> 404c8c4b, 34 chapters, `[Signals and the process](ch34.md)` after ch33; ch34's sections 34.1-34.4 and Exercises; book/ changes: SUMMARY, ch01, ch13, ch22, ch33, ch34 (new, 558 lines), front/how-to-read, back/colophon, back/solutions; book/diagrams untouched | derive.log |
| ch01's Windows block | names wolf-0.2.30-x86_64-pc-windows-msvc | book/ch01.md:237-238 at 95d68ad do; /install/ stamps the same name from __WOLF_VERSION__ (site/install/index.html:144, 149, 161) | derive.log |
| the book render and std/ | any wolf the site builds needs std/ beside it; mirror the book's staging and manifest ab2576df… | the site builds no wolf: at 95d68ad `xtask render` still runs typst (render.rs:522) and git (highlight.rs:346) only, and ch22's listing and ch34's consoles are spliced into the source by bs67. book.yml:173-195 is the staging step and names ab2576df6580… for the 0.2.30 archive. All four 0.2.30 archives hold std/, 57 files, manifest ab2576df… by that step's own recipe, STD-REV fd6bcdcb… | derive.log; release-assets.txt |
| bundled std | wolf-std fd6bcdc | 0.2.30 CHANGELOG: the bundled std is fd6bcdc (0.2.29 shipped d7c2968); its std.signal names all twenty-eight meanings with signal.send, number, ignored, env.pid and ppid; no wrappers for the release's eleven builtins; no file under the archive's std/ names any of the eleven | derive.log; release-assets.txt |
| linux aarch64 at 0.2.30 | — | release run 38706839251, job 116331591687 (run gate, ubuntu-22.04-arm): `wolf 0.2.30 (wolfgang, pin 1b37f36)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` | release-0230-rungate-arm-116331591687.log |
| corpus | — | phase: run set 659 -> 670: 11 in (conc/proc_must_join_legal, os/ids_read, os/ids_rows, os/term_editor_rows, seven typecheck/straight_line_*), 0 out, no pre-existing run program modified; anchors 640 -> 648 (8 added: os.fs.owner, os.proc.ids, os.proc.ids.note, os.proc.ids.set, os.signal.wait.fd, os.term.chars, os.term.editor.note, os.term.size; 0 dropped); grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18, all unchanged; docs/platforms.md unchanged; spec/ changes: 02, 03, 11, anchors.json, prelude.json | derive.log |
| the eleven new builtins in lupin | hosted-only | builtin.rs at 7896edd: on a hosted build fs_set_owner and fs_set_owner_fd are served, the five id reads, os_set_ids and the three terminal calls refused by name after their shape rows; under cfg(target_family = "wasm") fs_set_owner and fs_set_owner_fd sit in the fs tier's decline arm (builtin.rs:468-472) and the other nine in the process tier's (builtin.rs:718-729) | derive.log |
| lupin 0.1.53 on wasm32 | the wasm path as ww42 left it | wolf-interp#222 still OPEN; the control build (patched and unpatched) is measured before the lupin gitlink moves | gh issue view; §3.7 |
| wolf-lang and wolf-std trunk | not shown as available | wolf-lang trunk 211d28cb (past v0.2.30); a grep of site/ for the eleven new builtins finds 0 lines (its hits are 0.2.29's five and the archive-std sentence) | derive.log |

Drift, reported:
1. **The gap widens to six releases** (717 commits), and
   check-lag-phrases.py's closed set stops at five: at the wolf pin the
   guard will exit naming the missing phrase, as it did at ww41 and ww42.
   Both pages' sentences get written, then `six releases` joins the set.
2. The contract asks for the book CI's std staging step to be mirrored;
   this build runs no wolf, so there is nothing to mirror it onto (as ww41
   and ww42 found). The manifest is checked against the four published
   archives instead (release-assets.txt). Reported, not absorbed.
3. wolf's CHANGELOG counts 89 commits for 0.2.30 "then r35's release
   commits"; git counts v0.2.29..v0.2.30 = 106. The stamp is git's.
4. The worktree is ~/lanes/ww43/wolf-web (nomad-1); the build clone is
   ~/lanes/ww43/web (kasumi).

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 64 dry, 64 live (one more: ch34); the book's web edition
49 pages. The six ch07 SVGs sha-identical to ww42's.

3.2 Version strings. /install/ and /play/ stamp 0.2.30 and 0.1.53; the
Windows archive link reads wolf-0.2.30-x86_64-pc-windows-msvc.tar.gz, as
ch01 §1.2 does. version.json: lupin 0.1.53, pins wolf-lang 1b37f36,
wolf-interp 7896edd, wolf-book 95d68ad, spec-pin 294d626, missing [].

3.3 The lag. After the phrase is added, check-lag-phrases.py --json
answers {"gap": 6, "phrase": "six releases", "tagged": true, "commits":
717, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.30"}. The
stamped distance "six hundred and eleven" -> "seven hundred and seventeen".
The guard exits at the wolf pin commit and still at the lupin pin commit
(0.1.53 keeps the v0.2.24 pin); it goes green only with the new phrase and
both pages rewritten. Falsified by: any other gap or count, or a guard that
passes at either pin commit.

3.4 The census at 0.2.30 / 0.1.53. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.29 and 0.2.30 corpora x the live 0.1.52 module,
fetched from lupp.us, and the built 0.1.53). Baseline: the live module on
the 0.2.29 corpus (ww42's served census, 659 / 487 / 47 / 125 / 0).

| class | live (0.2.29 / 0.1.52) | ww43 predicted | delta |
|---|---|---|---|
| programs | 659 | 670 | +11 |
| exit | 487 | 494 | +7 |
| trap | 47 | 47 | 0 |
| unsupported | 125 | 129 | +4 |
| fail | 0 | 0 | 0 |
| candidates | 534 | 541 | +7 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.29 corpus (0.1.52 -> 0.1.53): 0 rows change class.
The eleven arrivals under 0.1.53: the seven straight_line_* programs exit
0 printing their headers' lines (lupin answered them at 0.1.52 already);
conc/proc_must_join_legal.lu is declined at its proc spawn (the task and
proc tiers); os/ids_read.lu, os/ids_rows.lu and os/term_editor_rows.lu are
declined by name at their first new call (process or fs tier). Under
0.1.52 the same seven exit and the same four are unsupported (a name that
does not resolve, or the same tier) (least firm: the class under 0.1.52 of
the three os rows). Whole-set stdout walk: 670 of 670 identical across the
two modules in verdict and stdout.

3.5 Chapter 34's builtins in the tab. Each of the eleven (os_uid, os_euid,
os_gid, os_egid, os_groups, os_set_ids, fs_set_owner, fs_set_owner_fd,
os_term_size, os_term_chars, os_signal_wait_fd), one call alone through the
built 0.1.53 module, answers verdict unsupported naming the call: nine with
the process tier's reason, the two owner calls with the fs tier's; none
runs, none traps, none kills the instance. Under the live 0.1.52 module
each does not resolve. The chapter's std.signal programs (`use
std.signal`) are unsupported in the tab under both modules, as every `use
std` program is; 0.2.29's five (os_pid, os_ppid, os_signal_send,
os_signal_number, os_signal_ignored) answer as ww42 measured. So the tab
refuses nothing it served before.

3.6 Allowlist lines. All three clocks move (wolf 0.2.29 -> 0.2.30, lupin
0.1.52 -> 0.1.53, book 0a5fecc -> 95d68ad), so every clocked entry reddens:
128 — version-allowlist 104 (76 wolf, 28 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book), entry lines only.
Predicted to arrive: v0.2.29 where 0.2.29's paragraphs become history
(front page, /spec/, /install/, /play/), 0.1.52 on /install/ and /play/.
Leaves: none predicted. The lag phrase is a number word: `five` -1 and
`six` +1 on /install/ and /play/.

3.7 lupin 0.1.53 on wasm32. As released it still fails (E0433 at
builtin.rs, the os_error_text call into eval::fs; wolf-interp#222 open);
the carried wasm-portability.patch (sha256 2cc2b8a3…) applies unchanged and
the module imports nothing. Falsified by: an unpatched build that succeeds
(the patch then goes), or a patch that no longer applies.

3.8 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.30's story leads (the crash fix on native and release,
  s755 #755; the must-join check at every call, E1010, s233 #678; the
  terminal's size, special characters and a wait a key and a signal both
  end, FLOW and EXTENDED, s234 #719; who a process runs as, a file's owner
  and the drop, s236 #633 #701 #742; the bundled std at fd6bcdc names all
  twenty-eight meanings and wraps none of the eleven); 0.2.29's becomes
  history beside 0.2.28's.
- /install/: the lag paragraph at six releases; the arrivals paragraph
  re-derived from the census; the declines unchanged.
- /play/: the lag at six releases; what the tab answers for the eleven
  new names; the refused list re-derived (3.9).
- /spec/: the bound sentences gain 0.2.30's anchors (11's ids, owner, set,
  terminal size, characters, wait; 03's must-join).
- /reading/: the chapter count is a stamp; any sentence naming the last
  chapter re-read.
- linux aarch64 sentences: re-read against the 0.2.30 release run's arm
  gate; no edit beyond the stamp expected.

3.9 /play/'s refused list after the bump: EMPTY (0 refusals, 0 output
partings). Declines that stand: the three whole-struct raw stores,
extern_let_image, extern_libc; atomic_counter the tab's; chdir_relative
still the near miss.

3.10 Stamps other than the distance: bookchapters 34, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 648
anchors. The menu: 36 programs, every one in class.

3.11 The PDF. 6.0 MB +- 0.2 MB (ch34 adds about 560 lines).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=95d68ad, 0 bare, 581 references (569 plus one page's twelve).

3.13 ch07's diagrams and the changed chapters (ch01, ch22, ch34) load under
the production CSP (staged from kasumi's dist/book under lupp.us's headers,
then live): 0 CSP violations, 0 console errors, ch07's six diagrams
rendered on three engines x two viewports; ch01 carries
wolf-0.2.30-x86_64-pc-windows-msvc, ch22 `toolchain 0.2.30`; ch34 is in
the sidebar after ch33 and its anchors #34.1-#34.4 resolve.

3.14 The staged gate (three engines x two viewports): 0 faults each;
--retry from ch07.html hop 1 and hop 2 at 90/90 on all six. The links walk
two hops deep reaches ch34.html and its four anchors on all six.

3.15 The PR's CI does not deploy: the run at the PR head has a `build the
site` job and its `deploy to lupp.us` job is skipped (pull_request event).
After the orchestrator's fast-forward the push run's deploy job deploys;
live version.json = 3.2.

3.16 The live gate (three engines, two viewports): 0 faults, hop 1 and hop
2 90/90 on all six, 0 HTTP 404 lines; ch34 and its anchors live.

What I expect to get wrong: the arrivals' classes under the old module,
the allowlist arrivals' counts, the book asset count, and the PDF size.



## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `611ad8a` (an empty commit), unedited.* Built on kasumi at
`0254e28` (`build-summary.txt`, the build the staged gates served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1: kasumi
has no Playwright and no WebKit, nothing was installed, and the three engines
are the ones playwright-core 1.63.0 already had cached on nomad-1, as ww41 and
ww42 used them. Files are under `docs/audit/ww43-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `611ad8a`, first pin `209b7ad`; `611ad8a` was pushed to origin before any pin |
| three gitlink commits | book `209b7ad` (-> `95d68ad0`, 3 of 4 book count lines hold; reading's `Thirty-one` moves in `6fc0985`), wolf `dd61b81` (-> `1b37f368`, 9 wolf count lines), lupin `e5c25d8` (-> `7896eddc`, 5 lupin count lines; `crates/lupin-wasm/wasm-portability.patch` unchanged, sha256 `2cc2b8a3…`) |
| inputs, lag, corpus sets, anchors, grammar, the arrivals' headers, the book's diff, the 0.2.30 and 0.1.53 CHANGELOGs, lupin's eleven builtins | `derive.log` (script `ww43-derive.sh`) |
| linux aarch64 at 0.2.30 | `release-0230-rungate-arm-116331591687.log`: release run 38706839251, job 116331591687 (run gate, ubuntu-22.04-arm): `wolf 0.2.30 (wolfgang, pin 1b37f36)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` |
| archive digests, each read twice | `release-assets.txt` (script `ww43-archives.sh`, kasumi): wolf-lang release 413582739's four archives and wolf-interp release 413375414's five assets, each downloaded twice, both reads equal to the sha256 GitHub publishes (`ARCHIVES-FAIL=0`); the Windows archive is `2772a997…` |
| the archive's `std/` and the book's manifest check | `release-assets.txt`: all four wolf archives hold `std/`, 57 files, manifest `ab2576df…` by wolf-book `95d68ad`'s own recipe (book.yml:193 names the same digest), `std/STD-REV` = `fd6bcdcb…`; no file under it names any of the eleven new builtins. This build runs no `wolf`, so there is no binary here to stage it beside (§2) |
| tap and AUR | `aur-live.txt`: AUR wolf-lang and wolf-lang-bin 0.2.30-1, lupin and lupin-bin 0.1.53-1, lobo-bin 0.1.4-1; the tap's formulae name `v0.2.30` / `1b37f368…` (std `fd6bcdcb…`) and `v0.1.53` / `7896eddc…` |
| lupin 0.1.53 on wasm32 | `wasm-control.txt` (script `ww43-wasm-control.sh`): with the patch `PATCHED-EXIT=0`, module `5904cf96…`, imports 0 (`wasm-0153-patched.log`); without it `UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\`` (`wasm-0153-unpatched.log`); wolf-interp#222 still open |
| the guard exits at the wolf pin | `guard-at-wolf-pin.txt` (kasumi, `dd61b81`): `check-lag-phrases: the interpreter is 6 releases behind and /install/ and /play/ have prose for 0 through 5 only — write the sentence, then add its phrase here`, `LAG-EXIT=1`, 76 literal version-prose lines red, `VP-EXIT=1`. The windows run at that commit, 38973337843, was cancelled by the next push and shows nothing |
| and still at the lupin pin | `guard-at-lupin-pin.txt` (kasumi, `e5c25d8`): the same line, `LAG-EXIT=1`, 110 version-prose lines (104 literal, 6 stamp), `VP-EXIT=1`, `CC-EXIT=0`. The windows run at that commit, 38973418710, was cancelled the same way; the CI plant is in the PR body |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.30 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 6 releases back, and both pages carry 'six releases' and neither carries another`; `--json`: `{"gap": 6, "phrase": "six releases", "tagged": true, "commits": 717, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.30"}` |
| stamped lag | `speccommits 717`; `seven hundred and seventeen commits` once on each built page (`build-summary.txt`) |
| census, four legs | `census-0229-015{2,3}.json`, `census-0230-015{2,3}.json`, `rows.txt` (script `ww43-rows.py`), driver `ww43-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified |
| stdout probe, records, the whole running set's stdout | `stdout-probe-0153.txt`, `stdout-probe-0152.txt`; `records-0153.txt`, `records-0152.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww43-stdout-all.mjs`): all 670 running programs on the 0.2.30 corpus through both modules, 670 identical in verdict and stdout |
| chapter 34's builtins and programs, module level | `builtins-0153.txt`, `builtins-0152.txt` (script `ww43-builtins.mjs`, programs `probes/*.lu`: the eleven new calls one each, and chapter 34's seven `wolf-run` programs verbatim): under 0.1.53 every one `unsupported`, phase `resolve`, exit 4 — `os_uid`, `os_euid`, `os_gid`, `os_egid`, `os_groups`, `os_set_ids`, `os_term_size`, `os_term_chars`, `os_signal_wait_fd`: `` `<name>` is the s40 process trio; this wasm build has no processes to spawn, so the tier is declined rather than mocked ``; `fs_set_owner`, `fs_set_owner_fd`: `` `<name>` is the s38/s90 fs tier; this wasm build has no filesystem to open … ``; the chapter's programs at `signal.listen`, `signal.interrupt`, `env.pid`, `term.raw` (`does not resolve`: no std in the tab), `os_pid` and `os_term_size`; under 0.1.52 each new name `does not resolve`; 0 instance deaths. 0.2.29's five through both modules: `builtins-ww42-015{2,3}.txt`, unchanged |
| the same at a terminal, and the compiler's answer | `native-0153.txt` (script `ww43-native.sh`): the published lupin 0.1.53 and wolf 0.2.30 linux archives (`5db55332…`, `4e55b39e…`, each equal to GitHub's digest). lupin: `fs_set_owner` ok, `fs_set_owner_fd` and `os_set_ids` `invalid` (shape rows), `os_signal_wait_fd` `io` (empty set), the five id reads and `os_term_size`/`os_term_chars` refused by name (exit 4); `proc_must_join_legal`, `ids_rows`, `term_editor_rows`, `signal_shell_rows`, `job_rows`, `chdir_relative`, `cfg_target_arch` print their headers; `ids_read` refused at `os_uid`; the five standing declines decline; the chapter's std programs do not resolve `std.*` (lupin's archive ships no std). wolf 0.2.30: all eighteen probes run on the checked machine and on native and print the chapter's lines (`os_groups` declined on the checked machine for a home-module method call in the probe's loop; native prints `groups: true`) |
| modules | lupin 0.1.53 built at `7896eddc` with the patch, sha256 `5904cf96…`, identical in the control, the measure run and the build's `dist/play/lupin.wasm`; the 0.1.52 control is the live module fetched from lupp.us, `e40cfab1…` (`measure.log`) |
| the build | `build-summary.txt`: build exit 0; node tests 120 / 120; links 1,543 across 64 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 648 anchors; planted 8 pass; tab-target 5 / 5; version.json lupin 0.1.53, pins 1b37f36 / 7896edd / 95d68ad, spec-pin 294d626, missing [] |
| book assets | `build-summary.txt`: `581 … versioned ?v=95d68ad; nothing exempt`, 0 bare, `wolf-boot.js?v=95d68ad` on 48 pages; PDF 5,932,055 B |
| chapter 34 | `build-summary.txt`: `dist/book/ch34.html` 45,319 B, `id="34.1"` … `id="34.4"` once each; ch33's page links `ch34.html` (the sidebar and the next-chapter link); /play/ links `/book/ch34.html#34.3` once |
| /install/'s Windows archive name | `build-summary.txt`: the built page carries `wolf-0.2.30-x86_64-pc-windows-msvc` four times, all from the stamp; the book's ch01 carries the same name twice and 0.2.29's none |
| nothing unreleased is named | `build-summary.txt`: no built page outside the rendered changelogs, spec and book names wolf-std#65's wrappers (`env.uid` …, `fs.set_owner`, `process.set_ids`), a std wrapper for s234's three calls, or 0.2.31's `[type.int.shift]` (0 lines) |
| ch07 and the changed pages | `build-summary.txt`: six ch07 SVGs sha-identical to ww42's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww43-book.mjs`): three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, ch01's Windows tar line, ch22's `toolchain 0.2.30` line, the colophon's pairing line and ch34's first program each in a code block, 0 CSP violations, 0 console errors on every page. The checker on a plant (one SVG removed, an inline script in ch22, ch01's archive name set back to 0.2.29, ch34's `reload` misspelled): `book-plant.txt`, 24 FAIL lines, `PLANT-EXIT=1` |
| /play/ in engines | `play-staged.txt` / `play-staged.json` (script `ww43-play.mjs`, served by `docs/audit/ww42-evidence/ww42-serve.mjs` on 127.0.0.1:8743 with the headers read out of `nginx/lupp.us.conf`): on all six cells the module boots (`lupin 0.1.53 … reading cfg as x86_64-unknown-linux-gnu`), the 36 menu programs run from the menu with the page's Run button (31 exit, 5 trap), the eighteen probes each answer `unsupported` with the module-level reasons above, 0 CSP violations, 0 console errors, and the six cells agree |
| /play/ refuses nothing it served | `play-live-before.txt` / `.json`: the same walk against https://lupp.us before the merge (lupin 0.1.52); `play-compare-staged.txt` (script `ww43-play-compare.mjs`): 216 menu runs over six cells, 0 verdicts moved, 0 served before and refused or missing now. The checker and the comparison on a plant (an inline script in the page, a menu entry removed, `hello.lu` replaced by the `os_uid` probe): `play-plant.txt`, six FAIL cells, `PLANT-PLAY-EXIT=1`, `PLANT-COMPARE-EXIT=1` |
| the site's links, two hops, and chapter 34's anchors | `links-staged.txt` / `.json.gz` (script `ww43-links.mjs`): on all six cells the front page's 7 links clicked and landed, the 34 further targets on those pages landed, chapter 34 in the two-hop set, and `ch34.html#34.1` … `#34.4` each landed 200 with its heading found and scrolled to, 0 faults. The first run lost every cell to the walker, not the site: a goto differing only in its fragment answers no response (`links-staged-run1-harness-null.txt`). On the plant (an inline script on the front page and /play/, /reading/ removed, /play/'s chapter 34 link removed, `id="34.2"` renamed): `links-plant.txt`, six FAIL cells, each naming chapter 34 out of the two-hop set and `#34.2` missing, `PLANT-LINKS-EXIT=1` |
| staged contents gate | `gate-staged.txt` / `.json.gz` (script `ww43-gate-staged.sh`): 50 pages, 46 entries, 2,300 clicks and 0 faults on all six engine × viewport cells (the book's 404 path is in every cell's walk); retry from ch07 hop 1 and hop 2 92/92 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,116 hop lines |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 64; book 49; six SVGs sha-identical | 64; book 49; six SVGs sha-identical |
| version strings, version.json | 0.2.30 / 0.1.53; pins 1b37f36 / 7896edd / 95d68ad, spec-pin 294d626, missing [] | identical |
| lag | gap 6, 717, "six releases"; the guard exits at the wolf pin and the lupin pin | identical (kasumi; both windows runs at the pin commits were cancelled by the next push, so the CI red is the plant in the PR) |
| census | 670 / 494 / 47 / 129 / 0 / 541 / 0 died | **identical in every total** |
| module leg on the 0.2.29 corpus | 0 rows move | 0 rows move, on either corpus |
| the arrivals | 7 straight-line exit; must-join, ids_read, ids_rows, term_editor_rows unsupported; the same under 0.1.52 | identical, and the same under 0.1.52 |
| whole-set stdout | 670 of 670 identical | 670 of 670 identical |
| chapter 34's builtins in the tab | each unsupported by name, nine process tier, two fs tier; under 0.1.52 none resolves; std programs unsupported | identical |
| clocked allowlist lines | 128 (104 / 6 / 18) | **128 (104 / 6 / 18)**: 110 version-prose lines red at the lupin pin, the 18 count lines re-read in the three pin commits |
| arrivals / leaves | v0.2.29 on four pages, 0.1.52 on install and play; 0 leave; `five` −1 and `six` +1 on install and play | v0.2.29 on index (1), spec (2), install (3), play (4); 0.1.52 on install (2), play (1); `five` and `six` as predicted; **not predicted:** 0.1.51 leaves /play/ (1 -> 0) and drops on /install/ (2 -> 1), v0.2.28 drops on install and play (4 -> 3), reading's `Thirty-one` -> `Thirty-two` |
| lupin 0.1.53 on wasm32 | red unpatched (E0433), the patch applies unchanged, 0 imports | identical |
| stamps | 34 / 153 / 34 / 18 / 36; 648 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 6.0 ± 0.2 MB | 5.9 MB (5,932,055 B) |
| book assets | 581 versioned, 0 bare | 581, 0 bare |
| ch07 and changed chapters under the CSP | 0 violations on ch01, ch22, ch34; six diagrams rendered | 0 violations and six diagrams on ch07, ch01, ch22, the colophon and ch34 |
| staged gate | 0 faults ×6; retry 90/90 ×2 hops ×6 | 0 faults ×6; retry **92/92** (the walk grew with ch34) |
| links, ch34 in two hops | ch34.html and its four anchors on all six | identical (once the walker's fragment navigation was fixed) |
| /play/'s refused list | empty | empty; the declines stand as named |

**Found, not predicted.**
1. **Chapter 34 was not within two hops of the front page.** The reading page
   links the parts' first chapters only, so before this lane's /play/
   paragraph linked `/book/ch34.html#34.3`, chapter 34 was reachable from the
   front page in three hops (via /reading/, /book/, the sidebar). The /play/
   link is a true sentence (the chapter teaches the calls the paragraph lists)
   and is the two-hop path the walk measures; the plant without it reds.
2. **The tab's reason for the id and terminal calls names the process trio
   again**, as ww42 found for 0.2.29's five: none of them spawns anything, and
   lupin builds them only where it has the process tier (builtin.rs:718-729 at
   `7896eddc`). /play/ says so in its own words. Not filed (this lane files
   nothing); listed in the report.
3. **The deploy host builds its own module.** The module lupp.us serves for
   0.1.52 is `e40cfab1…`; ww42's kasumi build of 0.1.52 was `e531173e…`. The
   site builds its wasm on the host it is served from, as ww42 found.
4. **lobo-bin is 0.1.4-1 on the AUR** (ww42 read 0.1.3-1). No site sentence
   names lobo's version; the count is still five project packages.
5. wolf 0.2.30's CHANGELOG counts 89 commits "then r35's release commits";
   git counts 106 (§2).
6. /install/'s "Five things a program can reach" on Windows still counts
   docs/platforms.md's named refusals, and that document is byte-identical to
   v0.2.29's (#749 open for the 0.2.29 rows; 0.2.30's eight id and owner calls
   are `unsupported` on windows by the spec and also unlisted there). Left as
   ww41 and ww42 left it; reported.

## 5. Done-when

- [x] Branch `ww43` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim;
      census table, allowlist diff, probes, page count in §4.
- [x] /play/, chapter 7, the changed pages, chapter 34 and its anchors, and the
      site's links checked in three engines × two viewports under the
      production headers; the staged gate's 404 path and ch07 path at 0 faults.
- [x] What the tab answers for chapter 34's builtins, measured in the module
      and in the engines.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion; the
      PR's run does not deploy.
- [ ] After the merge: the deploy job's run id, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
