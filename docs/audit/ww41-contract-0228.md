# ww41 — The Site at 0.2.28

Class: one repo, one bump (three gitlinks), one deploy. Opus. Wave 53.
Contract: the planning repo's sprints/web/ww41-the-site-at-0228.md (read
2026-10-12), which keeps every rule of ww40's. One deliverable: lupp.us
serves wolf 0.2.28, lupin 0.1.51 and the book at wolf-book b845e07 (bs65),
every stamped number derived at the checkout. The site skipped 0.2.27 /
0.1.50; both releases' surfaces arrive at once. This commit is empty; its
message is sections 1 to 3, cut from wolf-web trunk a621f5e with all three
gitlinks at ww40's values. Section 4 lands later in
docs/audit/ww41-contract-0228.md; sections 1 to 3 are not edited after this
commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests run on kasumi under
  ~/lanes/ww41/. nomad-1 runs git, gh, curl, ssh/scp and Playwright only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww41/bin/; Playwright and its browsers are the ones
  already cached on nomad-1, read in place.
- No rm outside ~/lanes/ww41/ (both hosts); no deletion in any tree this
  lane did not create. No git add -A. Nothing under ~/.claude. No edit to
  another lane's file; ~/lanes/ww32/ and ~/lanes/ww40/ on kasumi are read,
  never written.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy before the merge. PR open, unmerged; the orchestrator audits and
  fast-forwards; the deploy is the push run's "deploy to lupp.us" job
  (sprints/HOSTING.md). No ssh to almanta, no nginx, no tunnel, no DNS.
- No merge, tag, issue filed or closed, cancelled run of another lane. No
  2>/dev/null on a checkout; the branch is asserted before every commit.
- No "seen red" without a run id, sha, path or digest in the same
  paragraph. File checksums carry a trailing ….
- Kill only this lane's own pids, recorded at launch; on kasumi killable
  jobs start under setsid. Host ports 8080 and 8088 on nomad-1 are not used.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-12 09:00-09:20 UTC, before any gitlink moves)

Script ww41-derive.sh, log derive.log (kasumi ~/lanes/ww41/, landing under
docs/audit/ww41-evidence/); release facts read with gh on nomad-1.

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | a621f5e (ww40) | a621f5e5e794… ; PR #59 the last merged | gh api |
| gitlinks at trunk | 0.2.26 / 0.1.49 / 2504a0f | wolf-lang 89dc1394… (v0.2.26), wolf-interp f516a5f4… (v0.1.49), book 2504a0fc… | git submodule status |
| live version.json | — | built 2026-10-09T21:48:44Z, lupin 0.1.49, pins 89dc139 / f516a5f / 2504a0f, spec-pin 294d626, missing [] | curl https://lupp.us/version.json |
| wolf 0.2.28 | — | v0.2.28 -> f71ece8e1ad2…; release 410118732, draft false, 4 archives, published 2026-10-12T04:09:37Z (release run 38198234720) | gh api |
| wolf 0.2.27 (skipped) | — | v0.2.27 -> 0ddda6b7ab9f…; release 409367590 | gh api |
| lupin 0.1.51 | — | v0.1.51 -> f72e78d7a9d0…; release 409991647, 5 assets; Cargo.toml 0.1.51; 51 commits since f516a5f4 | gh api; derive.log |
| lupin's spec gitlink | — | 294d626d = v0.2.24 at 0.1.49, 0.1.50 AND 0.1.51: UNCHANGED | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of f71ece8e (exit 0); rev-list --count 294d626d..f71ece8e = 541; 89dc1394..f71ece8e = 328 (v0.2.26..v0.2.27 196, v0.2.27..v0.2.28 132); CHANGELOG heads 0.2.28, 0.2.27, 0.2.26, 0.2.25, 0.2.24, so the counted gap = 4 | derive.log |
| book target | b845e07 (bs65) | wolf-book trunk b845e0773a40…; 2504a0fc an ancestor, 25 commits; SUMMARY blob identical (c5819603), 33 chapters; book/ changes: ch01, ch16, ch22, ch24, ch25, appendix-e, colophon, solutions; book/diagrams untouched | derive.log |
| ch01's Windows block | names wolf-0.2.28-x86_64-pc-windows-msvc | book/ch01.md:237-238 at b845e07 do; /install/ stamps the same name from __WOLF_VERSION__ | derive.log |
| the book render and std/ | any wolf the site builds needs std/ beside it | the site builds no wolf: `xtask render web` / `render pdf` run typst (render.rs:522) and git (highlight.rs:346) only; the consoles are spliced into the sources at bs65. Nothing to stage; bs65's manifest 98e9a178… does not apply to this build | derive.log |
| corpus | — | phase: run set 618 -> 658: 40 in, 0 out; five pre-existing run programs modified (atomic_counter, chan_struct_payload, reason_interp, net/spawn_accept, os/signal_supervisor); anchors 607 -> 634 (27 added, 0 dropped); grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18, all unchanged | derive.log |
| linux aarch64 at 0.2.28 | checked only, no native (r33) | release run 38198234720, job 114656248225 (run gate, ubuntu-22.04-arm): `wolf 0.2.28 (wolfgang, pin f71ece8)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf`; docs/platforms.md byte-identical to v0.2.26's (still no linux aarch64 row, wolf-lang#645 open) | gh run view --log |
| lupin 0.1.51 on wasm32 | 0.1.49 did not (wolf-interp#222) | #222 OPEN. At f72e78d7 with trunk's wasm-portability.patch (sha256 2cc2b8a3…, ww40's, unchanged): applies to the staged copy, PATCHED-EXIT=0, imports 0, module 33465bdb…; without it UNPATCHED-EXIT=1, `error[E0433]: cannot find \`fs\` in \`super\`` at builtin.rs:489. The patch rides on | wasm-control.txt (script ww41-wasm-control.sh) |
| the archives carry std/ | — | 0.2.27's CHANGELOG: every archive carries wolf-std as std/ beside wolf, the default std root (s204, ruling #59) | derive.log |

Drift, reported:
1. **The gap widens to four releases**, and check-lag-phrases.py's closed
   set stops at three: at the wolf pin the guard does not list wrong phrases,
   it exits ("the interpreter is 4 releases behind and /install/ and /play/
   have prose for 0 through 3 only — write the sentence, then add its phrase
   here"). Both pages' sentences get written, then `four releases` joins the
   set, with a test.
2. wolf's CHANGELOG counts 184 commits for 0.2.27 and 120 for 0.2.28; git
   counts v0.2.26..v0.2.27 = 196 and v0.2.27..v0.2.28 = 132. The stamp is
   git's.
3. The site's install page says an archive holds the binary, the runtime and
   the licences; since 0.2.27 it holds std/ too. The Windows job asserts the
   folder's contents, so the sentence and its assertion move together.
4. The worktree is ~/lanes/ww41/wolf-web (nomad-1); the build clone is
   ~/lanes/ww41/web (kasumi).

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 63 dry, 63 live; the book's web edition 48 pages (SUMMARY
blob identical). The six ch07 SVGs sha-identical to ww40's.

3.2 Version strings. /install/ and /play/ stamp 0.2.28 and 0.1.51; the
Windows archive link reads wolf-0.2.28-x86_64-pc-windows-msvc.tar.gz, as
ch01 §1.2 does. version.json: lupin 0.1.51, pins wolf-lang f71ece8,
wolf-interp f72e78d, wolf-book b845e07, spec-pin 294d626, missing [].

3.3 The lag. After the phrase is added, check-lag-phrases.py --json
answers {"gap": 4, "phrase": "four releases", "tagged": true, "commits":
541, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.28"}. The
stamped distance "two hundred and thirteen" -> "five hundred and
forty-one". The guard reddens (exits) at the wolf pin commit and stays red
at the lupin pin commit (0.1.51 keeps the v0.2.24 pin); it goes green only
with the new phrase and both pages rewritten.

3.4 The census at 0.2.28 / 0.1.51. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.26 and 0.2.28 corpora × the live 0.1.49 module,
fetched from lupp.us, and the built 0.1.51). Baseline: the live module on
the 0.2.26 corpus (ww40's served census, 618 / 465 / 40 / 113 / 0).

| class | live (0.2.26 / 0.1.49) | ww41 predicted | delta |
|---|---|---|---|
| programs | 618 | 658 | +40 |
| exit | 465 | 487 | +22 |
| trap | 40 | 47 | +7 |
| unsupported | 113 | 124 | +11 |
| fail | 0 | 0 | 0 |
| candidates | 505 | 534 | +29 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.26 corpus (0.1.49 -> 0.1.51): 0 rows change class;
chdir_relative still exits 1 in the tab (#222 open). Arrivals (40) under
0.1.51: 22 exit (the twelve typecheck int_truth/numlit_radix rows, the
seven json dup rows, link/module_c, conc/chan_sent_arg_legal,
memory/region_kept_arg_legal), 7 trap (faults/int_truth_*: five
overflow, two div-zero), 11 unsupported (fs/change_rows, hard_link,
mode_symlink, set_times, truncate: the tab's filesystem; os/env_unset,
exec_rows, job_rows, umask: the tab's process surface, umask refused by
name everywhere; memory/region_net_read_charged: the net tier;
conc/chan_sent_arg_legal_tasks: tasks). Least firm: chan_sent_arg_legal
(it may spawn), region_kept_arg_legal (#233: a sound copy of a scalar
struct under `in r` traps in lupin), os/env_unset (the tab may serve env).

Stdout probe under 0.1.51 (the 40 arrivals and the five modified
programs): every exit program prints its header's stdout — 0 real DIFF.

3.5 Old wrong answers. 0.2.28's soundness fixes (#660, #665) are E1010
refusals at compile time; lupin traps region-fault on those shapes, so no
menu or census program printed an old wrong answer in the tab. 0.2.27's
three P0s (#551, #538, #553: unsigned and wrapping integers) were wrong on
the compiled tiers; lupin 0.1.49 already printed the unsigned values
(wolf-lang#538's report), so no common row's stdout moves 0.1.49 -> 0.1.51.

3.6 Allowlist lines. All three clocks move (wolf 0.2.26 -> 0.2.28, lupin
0.1.49 -> 0.1.51, book 2504a0f -> b845e07), so every clocked entry reddens:
114 — version-allowlist 90 (66 wolf, 24 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book), entry lines only.
Predicted to arrive: v0.2.26 where 0.2.26's paragraphs become history
(front page, /spec/, /install/, /play/), 0.1.49 on /play/ and /install/.
Leaves: none predicted.

3.7 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.28's story leads (#660/#665 refused at the call; the
  checked machine runs tasks; the calls that change a file; a server stops
  growing; a List slice is one copy), 0.2.27's beside it (std ships in the
  archive; unsigned and wrapping integers print and compute right; Ctrl-C,
  process groups and the terminal; exec and env unset; the full stat;
  json last-wins; ffi on a C declaration); 0.2.26's becomes history.
- /install/: the lag paragraph at four releases; the archive's contents
  gain std/ (and the Windows job's claim with it); the arrivals paragraph
  re-derived from the census; the declines unchanged.
- /play/: the lag at four releases; the refused list re-derived (3.8).
- /spec/: the bound sentences gain 0.2.27's and 0.2.28's anchors.
- linux aarch64 sentences: true at 0.2.28 by the run gate above; no edit
  beyond the stamp.

3.8 /play/'s refused list after the bump: EMPTY (0 refusals, 0 output
partings). Declines that stand: the three whole-struct raw stores,
extern_let_image, extern_libc; atomic_counter the tab's; chdir_relative
still the near miss.

3.9 Stamps other than the distance: bookchapters 33, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 634
anchors.

3.10 The menu. check-samples.mjs: 36 programs, every one in class.

3.11 The PDF. 5.8 MB ± 0.2 MB (bs65 adds about 90 lines of book prose).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=b845e07, 0 bare, 569 references.

3.13 ch07's diagrams and the changed chapters (ch01, ch16, ch22, ch24, ch25)
load under the production CSP (staged on nomad-1 from kasumi's dist/book,
then live): 0 CSP violations, 0 console errors, ch07's six diagrams
rendered on three engines × two viewports; ch01 carries
wolf-0.2.28-x86_64-pc-windows-msvc.

3.14 The staged gate (nomad-1, three engines × two viewports): 0 faults
each; --retry from ch07.html hop 1 and hop 2 at 90/90 on all six.

3.15 The deploy. The orchestrator's fast-forward starts ci.yml on push; its
"deploy to lupp.us" job deploys; live version.json = 3.2.

3.16 The live gate (nomad-1, three engines, two viewports): 0 faults, hop 1
and hop 2 90/90 on all six, 0 HTTP 404 lines.

What I expect to get wrong: the arrivals' classes in the tab
(chan_sent_arg_legal, region_kept_arg_legal, env_unset), the allowlist
arrivals, and the PDF size.



## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `226564c` (an empty commit), unedited.* Built on kasumi at
`1845f18` (`build-summary.txt`, the build the staged gates served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1. Files
are under `docs/audit/ww41-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `226564c`, first pin `8651bc3`; `226564c` was pushed to origin before any pin (its windows run 38227538834 is green at it) |
| three gitlink commits | book `8651bc3` (-> `b845e077`, 4 book count lines), wolf `9611ad8` (-> `f71ece8e`, 9 wolf count lines), lupin `4502777` (-> `f72e78d7`, 5 lupin count lines; `crates/lupin-wasm/wasm-portability.patch` unchanged, sha256 `2cc2b8a3…`) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers, the book's diff, the 0.2.27 and 0.2.28 CHANGELOGs | `derive.log` (script `ww41-derive.sh`) |
| linux aarch64 at 0.2.28 | `release-0228-rungate-arm-114656248225.log`: release run 38198234720, job 114656248225 (run gate, ubuntu-22.04-arm): `wolf 0.2.28 (wolfgang, pin f71ece8)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf` |
| archive digests | `release-assets.txt`: wolf-lang releases 409367590 (0.2.27) and 410118732 (0.2.28), wolf-interp 409303515 (0.1.50) and 409991647 (0.1.51), every asset with GitHub's sha256; the Windows 0.2.28 archive downloaded on nomad-1 hashes to `bb9e2f5f…` as published, holds `std/` (115 entries) and `std/STD-REV` = `98e1b7bc…` |
| tap and AUR | `aur-live.txt`: AUR wolf-lang and wolf-lang-bin 0.2.28-1, lupin and lupin-bin 0.1.51-1, lobo-bin 0.1.3-1; the tap's formulae name `v0.2.28` / `f71ece8e…` and `v0.1.51` / `f72e78d7…` |
| lupin 0.1.51 on wasm32 | `wasm-control.txt` (script `ww41-wasm-control.sh`): with the patch `PATCHED-EXIT=0`, module `33465bdb…`, imports 0 (`wasm-0151-patched.log`); without it `UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\`` at `builtin.rs:489` (`wasm-0151-unpatched.log`); wolf-interp#222 still open |
| the guard exits at the wolf pin | `guard-at-wolf-pin.txt` (kasumi, `9611ad8`): `check-lag-phrases: the interpreter is 4 releases behind and /install/ and /play/ have prose for 0 through 3 only — write the sentence, then add its phrase here`, `LAG-EXIT=1`; windows run **38227670981** at `9611ad8` (`ci-windows-red-38227670981.log`) |
| and still at the lupin pin | `guard-at-lupin-pin.txt` (kasumi, `4502777`): the same line, `LAG-EXIT=1`, 94 version-prose lines (88 literal, 6 stamp), `VP-EXIT=1`, `CC-EXIT=0`; windows run **38228009461** at `4502777` (`ci-windows-red-38228009461.log`) |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.28 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 4 releases back, and both pages carry 'four releases' and neither carries another`; `--json`: `{"gap": 4, "phrase": "four releases", "tagged": true, "commits": 541, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.28"}` |
| stamped lag | `speccommits 541`; `five hundred and forty-one commits` once on each built page (`build-summary.txt`) |
| census, four legs | `census-022{6,8}-01{49,51}.json`, `rows.txt` (script `ww41-rows.py`), driver `ww41-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.26 / 0.1.49 leg equals ww40's served census row for row (618 rows, 0 differ) |
| stdout probe, records, the whole running set's stdout | `stdout-probe-0151.txt`, `stdout-probe-0149.txt`; `records-0151.txt`, `records-0149.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww41-stdout-all.mjs`): all 658 running programs on the 0.2.28 corpus through both modules, 649 identical in verdict and stdout; the 9 that differ are arrivals (the seven json rows, env_unset, int_truth_wrap_mul_wide) |
| modules | lupin 0.1.51 built at `f72e78d7` with the patch, sha256 `33465bdb…`, identical in the control, the measure run and the build's `dist/play/lupin.wasm`; the 0.1.49 control is the live module fetched from lupp.us, `323c0a87…` (`measure.log`) |
| the build | `build-summary.txt`: build exit 0; node tests 120 / 120 (one new: the closed set has no hole); links 1,513 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 634 anchors; planted 8 pass; tab-target 5 / 5; version.json lupin 0.1.51, pins f71ece8 / f72e78d / b845e07, spec-pin 294d626, missing [] |
| book assets | `build-summary.txt`: `569 … versioned ?v=b845e07; nothing exempt`, 0 bare, `wolf-boot.js?v=b845e07` on 47 pages; PDF 5,773,409 B |
| ch07 and the changed chapters | `build-summary.txt`: six ch07 SVGs sha-identical to ww40's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww41-book.mjs`): three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, ch01's Windows tar line, ch22's `module pkg :: std.range` and ch24's E1504 explain each in a code block, 0 CSP violations, 0 console errors on every page; the checker seen red on a plant (one SVG removed, an inline script in ch22, ch01's archive name set back to 0.2.26): `book-plant.txt`, 18 FAIL lines, `PLANT-EXIT=1` |
| staged gate | `gate-staged.txt` / `.json.gz` (script `ww41-gate-staged.sh`): 2,205 clicks and 0 faults on all six engine × viewport cells (the book's 404 path is in every cell's walk); retry from ch07 hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| Windows job at the head | windows run 38228905927 at `1845f18` green: `lupin reads 4 releases back — both pages carry 'four releases'`, `ok the archive carries std`, `ok the archive carries std\STD-REV`, `ok std\STD-REV names a commit` |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 63; book 48; six SVGs sha-identical | 63; book 48; six SVGs sha-identical |
| version strings, version.json | 0.2.28 / 0.1.51; pins f71ece8 / f72e78d / b845e07, spec-pin 294d626, missing [] | identical |
| lag | gap 4, 541, "four releases"; the guard exits at the wolf pin and the lupin pin | identical (kasumi and windows runs 38227670981 / 38228009461) |
| census | 658 / 487 / 47 / 124 / 0 / 534 / 0 died | **identical in every total**; two rows swapped classes inside it: `os/env_unset.lu` exits 0 (I called it a decline: the tab serves `env_unset`) and `link/module_c.lu` is declined (I called it exit: its module `c` is a sibling file the editor does not have) |
| module leg on the 0.2.26 corpus | 0 rows move; chdir_relative still exit 1 | identical |
| arrivals | 22 exit, 7 trap, 11 unsupported | 22 exit, 7 trap, 11 unsupported (the composition above) |
| stdout probe | 0 real DIFF | 0 real DIFF among the arrivals (three header-without-final-newline diffs: chan_sent_arg_legal, env_unset, numlit_radix); chdir_relative, v0.2.26's, the one known |
| old answers | no common row's stdout moves | identical (649 of 658); found beside it: under 0.1.49 the json arrivals answered first-wins, env_unset was declined and wrap_mul_wide trapped — arrivals, never served by the live tab |
| clocked allowlist lines | 114 (90 / 6 / 18) | **112 (88 / 6 / 18)**: my count read two comment lines as entries; 88 = 65 wolf + 23 lupin |
| arrivals / leaves | v0.2.26 on four pages, 0.1.49 on play and install; 0 leave | v0.2.26 on index (1), spec (5), install (5), play (4); **v0.2.27 on index (1), spec (4), install (1)** and **0.1.50 on install (1)**, not predicted; 0.1.49 on install (3), play (1); install v0.2.25 4 -> 3, play v0.2.25 5 -> 4; spec stamps 7 -> 5 (bound 7 -> 5); play `five` 7 -> 6 (counted 6 -> 5); 0 leave |
| stamps | 33 / 153 / 34 / 18 / 36; 634 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 5.8 ± 0.2 MB | 5.8 MB (5,773,409 B) |
| book assets | 569 versioned, 0 bare | 569, 0 bare |
| ch07 and changed chapters under the CSP | 0 violations on ch01, ch16, ch22, ch24, ch25; six diagrams rendered | 0 violations and six diagrams on ch07, ch01, ch22, ch24 (the checker's pages); ch16 and ch25 were loaded by the contents gate's walk, not by the CSP checker |
| staged gate | 0 faults ×6; retry 90/90 ×2 hops ×6 | identical |
| /play/'s refused list | empty | empty; the declines stand as named |

**Found, not predicted.**
1. **The lag guard's closed set ended at three.** At a gap of four it exits
   naming the missing phrase rather than listing wrong ones; the pages were
   written first, then `four releases` joined the set (`148dd81`) with a test
   that the set runs from zero with no hole.
2. **Three answers the old tab would have given are gone** (all arrivals, so
   never served): repeated json names first-wins, `env_unset` declined, and
   `typecheck/int_truth_wrap_mul_wide.lu` trapping `overflow` where every
   compiler tier prints `3596837031075064250 4 0 1`.
3. **A stale pre-existing sentence, not edited:** /docs/'s footer says "E0005
   did at this pin", true at an old bump only. Not this bump's to fix (no
   stamp or release moved it); reported.
4. **The front page's source recipe says `cargo xtask install` copies "both
   artifacts"**; at v0.2.28 it copies three (`wolf`, `libwolf_rt.a`,
   `wolf-cimport-worker`) and no `std/`. The std half is now stated; the
   "both" is older than this bump and left as it was; reported.
5. wolf 0.2.27's CHANGELOG counts 184 commits and 0.2.28's 120; git counts
   196 and 132 (as ww40 found for 0.2.26).

## 5. Done-when

- [x] Branch `ww41` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim;
      census table, allowlist diff, probes, page count in §4.
- [x] Chapter 7 and the changed chapters served and checked under the
      production headers; the staged gate's 404 path and ch07 path at 0 faults.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion.
- [ ] After the merge: the deploy job's output, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
