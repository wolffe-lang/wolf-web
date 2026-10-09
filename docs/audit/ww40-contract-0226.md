# ww40 — The Site at 0.2.26

Class: one repo, one bump (three gitlinks), one deploy. Opus. Wave 53.
Contract: the planning repo's sprints/web/ww40-the-site-at-0226.md (planning
origin/trunk, read 2026-10-09). One deliverable: lupp.us serves wolf 0.2.26,
lupin 0.1.49 and the book at wolf-book 2504a0fc (bs64: `!` on integers in
ch02, `-> never` in ch06, `copy region` in ch08), every stamped number
derived at the checkout, and the front page's linux aarch64 sentence made
true at 0.2.26 (wolf-lang#614). This commit is empty; its message is
sections 1 to 3, cut from wolf-web trunk 296aa31 with all three gitlinks at
ww39's values. Section 4 lands later in docs/audit/ww40-contract-0226.md;
sections 1 to 3 are not edited after this commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census, the prose audits and the node tests run on kasumi under
  ~/lanes/ww40/. nomad-1 runs git, gh, curl, ssh/scp, Playwright and the
  deploy step only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww40/bin/; Playwright and its browsers are the ones
  already cached on nomad-1 (read in place, never written).
- No rm outside ~/lanes/ww40/ (kasumi), this lane's worktree and this lane's
  namespaced scratch files; no deletion in any tree this lane did not
  create. No git add -A. Nothing under ~/.claude. No edit to another lane's
  file; ~/lanes/ww32/ and ~/lanes/ww39/ on kasumi are read, never written.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy before the merge. PR open, unmerged; the orchestrator audits and
  fast-forwards; the deploy is the push run's "deploy to lupp.us" job.
- Never touch almanta's nginx config or anything needing sudo, nor other
  Cloudflare tunnels, ~/.cloudflared/config.yml or DNS. A server change
  would be staged in the repo and reported.
- No merge, no rebase-merge. No 2>/dev/null on a checkout; the branch is
  asserted before every commit.
- No "seen red" without a run id, sha, path or digest in the same
  paragraph. File checksums carry a trailing ….
- Kill only this lane's own pids, never a pattern or a process group; on
  kasumi killable jobs start under setsid. In zsh a variable before a colon
  is braced.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-09 20:05-20:25 UTC, before any gitlink moves)

Script ww40-derive.sh, log derive.log (kasumi ~/lanes/ww40/, landing under
docs/audit/ww40-evidence/); release and issue facts read with gh on nomad-1.

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | 296aa31 or later | 296aa31ac9c0… (nothing landed since ww39; PR #58 the last) | gh api; gh pr list |
| gitlinks at trunk | wolf 0.2.25, lupin 0.1.48, book fde77b8 | wolf-lang 6710f9e0… (v0.2.25), wolf-interp 531bf058… (v0.1.48), book fde77b8d… | git ls-tree HEAD upstream/ |
| live version.json | 0.2.25 / 0.1.48 / fde77b8 | built 2026-10-08T01:03:02Z, lupin 0.1.48, pins 6710f9e / 531bf05 / fde77b8, spec-pin 294d626, missing [] | curl https://lupp.us/version.json |
| wolf 0.2.26 | 89dc1394, release 408143286 | v0.2.26 -> 89dc139443da…; release 408143286 draft:false prerelease:false, 4 assets, published 2026-10-09T17:48:26Z | gh api |
| lupin 0.1.49 | f516a5f, release 408028965 | v0.1.49 -> f516a5f4ea43…; release 408028965 draft:false, 5 assets, published 2026-10-09T15:05:40Z; Cargo.toml version = "0.1.49"; 55 commits since 531bf058 | gh api; derive.log |
| lupin 0.1.49's spec gitlink | — | 294d626d = v0.2.24, UNCHANGED from 0.1.48 | derive.log |
| ancestry and the lag | — | 294d626d an ancestor of 89dc1394 (exit 0); rev-list --count 294d626d..89dc1394 = 213; 6710f9e0..89dc1394 = 163; CHANGELOG heads 0.2.26, 0.2.25, 0.2.24, so the guard's gap = 2 | derive.log |
| book target | 2504a0f (bs64, merged) | wolf-book trunk 2504a0fcef5a…; fde77b8d an ancestor, 28 commits, 81 files; SUMMARY blob identical (c5819603), 33 chapters; book/ changes: ch01, ch02, ch05, ch06, ch08, ch22, ch24, appendix-e, colophon, solutions; ch07.md and book/diagrams/ untouched | derive.log |
| wolf-lang trunk | moved on (s220 at ac0ac498) | ac0ac498c251…; the site pins the tag | derive.log |
| corpus | — | phase: run set 592 -> 618: 26 in, 0 out, no pre-existing run program modified; anchors 595 -> 607 (12 added: mem.list.bytes, mem.region.copyout, mem.static.4, mem.unsafe.raw.5, os.fs.chdir, os.fs.copy, os.fs.error, os.fs.isatty, os.proc.fds, os.proc.pipe, type.fn.never, type.int.not; 0 dropped); grammar.ebnf byte-identical; ## E 153, ## W 34, corpus/net 18, all unchanged | derive.log |
| the platform ledger | docs/platforms.md at v0.2.26 | byte-identical to v0.2.25's (only README.md moved among platforms.md, README.md, release.yml, ci.yml); its tier table has rows for linux x86-64, macOS aarch64 and windows x86-64 only, no linux aarch64 row; its preamble says both linux archives are built on 22.04 and the run gate runs "one program on each tier" | git show v0.2.26:docs/platforms.md |
| what 0.2.26 measures on linux aarch64 | neither tier builds (#614) | release.yml at v0.2.26, run gate on ubuntu-22.04-arm: native "refuses by name, exit 2", release "refuses by name, exit 2", checked "exit(0), hello, wolf"; GLIBC_2.34 needed; `wolf 0.2.26 (wolfgang, pin 89dc139)` — release run 37963417253, job 113939696545 (success) | gh run view --log |
| wolf-lang#614 | neither tier at 0.2.24-0.2.26 | OPEN; body + correction comment: native and release both refused on linux aarch64 at 0.2.24 (pelt runs 37548350989, 37554842187) | gh issue view |
| per-change CI on linux aarch64 | — | ci.yml at v0.2.26 runs ubuntu-latest, macos-latest, windows-latest only; release.yml runs dist and run gate on ubuntu-22.04-arm | git show v0.2.26:.github/workflows/ |
| /play/'s declines at ww39 | #194 atomics, #185 volatile, #205 struct field read | wolf-interp#185, #194, #205 all CLOSED; 0.1.49 carries is74 and s213's struct pointee | gh issue view; derive.log |

Drift, reported:
1. **lupin 0.1.49 did not re-pin.** Its spec gitlink is 294d626d (v0.2.24),
   the same as 0.1.48's, so the gap WIDENS from one release (50 commits) to
   two releases (213 commits). The contract's §2 does not say; wolf 0.2.26's
   CHANGELOG does ("The spec pin is unchanged").
2. **The front page's linux aarch64 sentence is mostly true at 0.2.26; one
   clause is false and the install page is incomplete.** "its archive runs
   programs on the checked tier rather than compiling them" is what the
   release's run gate asserts. "without a CI runner" is false: release.yml
   builds the arm archive and runs its gate on ubuntu-22.04-arm at every tag
   (the per-change CI has no arm runner). /install/ says "wolf run refuses
   the host by name" and is silent on `--release`, which #614's first
   reading thought built; the gate asserts it refuses too. /install/ also
   says `wolf test` runs there, which no gate measures on that host (the
   driver runs tests on the checked machine, test_cmd.rs at v0.2.26).
3. **docs/platforms.md carries no linux aarch64 row**, so "from the
   release's own platform ledger" reads a silence; the measurement of
   record is release.yml's run gate at v0.2.26 (job 113939696545). The
   ledger's missing row is reported, not fixed here (not this repo).
4. wolf 0.2.26's CHANGELOG counts "149 commits integrated by r31 … then r31's
   release commits"; git counts v0.2.25..v0.2.26 = 163. The stamp is git's.
5. Chapter 7 did not move (book/ch07.md and book/diagrams/ch07/ identical
   between fde77b8 and 2504a0f): item 3 is a re-check of what ww39 put live.
6. The worktree is ~/GithubOrgs/wolffe-lang/wolf-web-ww40.

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 63 dry, 63 live; the book's web edition 48 pages (SUMMARY
blob identical). Six SVG files under dist/book/diagrams/ch07/, sha-identical
to ww39's. Falsified by any other count.

3.2 Version strings. /install/ and /play/ stamp 0.2.26 and 0.1.49; the
Windows archive link reads wolf-0.2.26-x86_64-pc-windows-msvc.tar.gz.
version.json: lupin 0.1.49, pins wolf-lang 89dc139, wolf-interp f516a5f,
wolf-book 2504a0f, spec-pin 294d626, missing [].

3.3 The lag. check-lag-phrases.py --json answers {"gap": 2, "phrase": "two
releases", "tagged": true, "commits": 213, "spec": "294d626", "release":
"0.2.24", "advertised": "0.2.26"}. The phrase moves "one release" -> "two
releases"; the stamped distance "fifty" -> "two hundred and thirteen". The
guard reddens at the wolf pin commit (gap 2 against pages saying "one
release") and STAYS red at the lupin pin commit, because 0.1.49 keeps
0.1.48's spec pin: it goes green only when /install/'s and /play/'s prose is
rewritten. (ww39's guard went green at the lupin pin with no page edit;
this one cannot.)

3.4 The census at 0.2.26 / 0.1.49. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.25 and 0.2.26 corpora × the live 0.1.48 module,
fetched from lupp.us, and the built 0.1.49). Baseline: the live module on
the 0.2.25 corpus (ww39's served census, 592 / 443 / 39 / 110 / 0).

| class | live (0.2.25 / 0.1.48) | ww40 predicted | delta |
|---|---|---|---|
| programs | 592 | 618 | +26 |
| exit | 443 | 463 | +20 |
| trap | 39 | 40 | +1 |
| unsupported | 110 | 115 | +5 |
| fail | 0 | 0 | 0 |
| candidates | 482 | 503 | +21 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.25 corpus (0.1.48 -> 0.1.49): five rows move, all
unsupported -> exit(0), none to fail: conc/atomic_fence.lu,
atomic_orders.lu, atomic_widths.lu (is74, #194), memory/volatile_widths.lu
(is74, #185), memory/packed_field_raw_read.lu (s213's struct pointee,
#205). conc/atomic_counter.lu stays unsupported for the tab's own reason
(the task tier needs a thread per task and the wasm build has none). The
three whole-struct stores (raw_repr_c_layout, raw_repr_packed_layout,
raw_repr_align_layout) stay declined by name; extern_let_image and
extern_libc stay declined. Common rows otherwise: 0 move.
Arrivals (26) under 0.1.49: 15 exit (memory/bytes_scan,
raw_field_store, raw_field_store_compound, raw_field_store_nested,
raw_field_store_packed, region_copyout_exits, region_copyout_loop,
region_copyout_map, region_copyout_struct, region_str_call_inside,
region_str_call_static; typecheck/fn_never_handler_arm, int_not_byte,
int_not_mask, int_not_signed), 1 trap (typecheck/fn_never_trap,
trap(assert)), 10 unsupported (fs/copy_chunk, fs/os_error,
fs/std_write_bytes: the tab's filesystem; os/chdir_relative,
os/pipe_round_trip, os/spawn_fds_rows: the tab's process surface;
memory/static_qualified, static_qualified_let, static_qualified_var: the
census's one-file shape; typecheck/fn_never_extern: a bodyless extern).
The rows held least firmly: fs/std_write_bytes (descriptor 1 may be served
in the tab), fn_never_extern (the handler is never taken, so the
declaration may never be asked), os/pipe_round_trip.

Stdout probe under 0.1.49 (the 26 arrivals plus the five module-leg rows):
every exit program prints its header's stdout — 0 real DIFF.

3.5 Old wrong answers. The tab runs lupin, which trapped #618's shape
(a str result held past its region) where checked, native and release read
freed bytes; no menu or census program printed an old wrong answer that
0.2.26 corrects. Falsified by a common row whose 0.1.48 stdout differs from
0.1.49's other than the five module-leg rows.

3.6 Allowlist lines. All three clocks move (wolf 0.2.25 -> 0.2.26, lupin
0.1.48 -> 0.1.49, book fde77b8 -> 2504a0f), so every clocked entry reddens:
107 — version-allowlist 83 (62 wolf, 21 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book), counted on entry
lines only (ww39's comment-header miscount not repeated). Predicted to
arrive: v0.2.25 where 0.2.25's paragraphs become history (front page,
/spec/, /install/, /play/), 0.1.48 on /play/ and /install/ where the
declines and the lag are told as history; a new bound __WOLF_VERSION__ on
the front page's aarch64 sentence (stamp-allowlist). Leaves: none
predicted. The arrivals are the part I expect to get wrong.

3.7 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.26's story leads (#618 fixed; standard streams as bytes,
  a child's descriptors, pipes, the working directory; `-> never` and `!`
  on integers; `copy region`; capabilities derived from what code reaches),
  0.2.25's becomes history.
- front page and /install/: linux aarch64 — neither compiled tier serves
  it at 0.2.26, `wolf run` / `wolf build` and `--release` each refuse the
  host by name (exit 2), the checked tier runs (`wolf conform-run
  --checked`), as the release's own run gate asserts on an arm runner at
  every tag; "without a CI runner" goes; the front page's sentence becomes
  release-bound (stamped, so the next bump re-reads it).
- /spec/: the bound sentences gain 02's [mem.region.copyout],
  [mem.static.4], [mem.unsafe.raw.5], [mem.list.bytes]; 10's
  [type.fn.never], [type.int.not]; 11's six os anchors; 08's derived
  capabilities.
- /install/ and /play/: the lag paragraphs go to "two releases": the
  compiler has tagged twice since v0.2.24 and lupin 0.1.49 released
  without re-pinning, so the gap widened a step.
- /play/: the refused list re-derived from the census (3.8).
- /reading/: the book's new samples (ch02, ch06, ch08) re-read against
  any reading that names those chapters.

3.8 /play/'s refused list after the bump: EMPTY (0 refusals, 0 output
partings), as at ww39. Declines leaving: atomic_fence, atomic_orders,
atomic_widths, volatile_widths, packed_field_raw_read (all five to exit;
wolf-interp#185, #194, #205 closed). Declines that stand: the three
whole-struct raw stores, extern let's link symbol, extern_libc's bodyless
C declaration, and the arrival fn_never_extern beside it.

3.9 Stamps other than the distance: bookchapters 33, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 607
anchors.

3.10 The menu. check-samples.mjs: 36 programs, every one in class.

3.11 The PDF. 5.78 MB ± 0.2 MB (bs64 adds 193 lines of prose and three
samples).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=2504a0f, 0 bare, 569 references (no page added). The six ch07
diagrams resolve (check-links 0 dead).

3.13 Chapter 7 and the new samples under the production CSP (staged on
nomad-1, kasumi's dist/book under lupp.us's headers; then live):
ch07.html shows 6 figure.memory-diagram images, each naturalWidth > 0 on
three engines × two viewports, 0 CSP violations, each SVG 200
image/svg+xml; ch02.html, ch06.html and ch08.html each load with 0 CSP
violations and 0 console errors and carry their new sample (`!` on an
integer's mask, `fn die(why: str) -> never`, `copy region`).

3.14 The staged gate (nomad-1, three engines × two viewports): 2,205
clicks, 0 faults each; --retry from ch07.html hop 1 90/90, hop 2 90/90, 0
404s on all six; the book's 404 path 0 faults.

3.15 The deploy. The orchestrator's fast-forward starts ci.yml on push; its
"deploy to lupp.us" job prints "Deployed <stamp>"; live version.json = 3.2;
63 of 63 pages at 200; book pages load wolf-boot.js?v=2504a0f.

3.16 The live gate (nomad-1, three engines, two viewports): 2,205 clicks per
cell, 0 faults; --retry from ch07.html hop 1 90/90, hop 2 90/90 on all six,
0 HTTP 404 lines; 3.13 holds live. WebKit timeouts over the public internet
are reported with their lines, never rerun away.

What I expect to get wrong: the arrivals' classes in the tab (std_write_bytes,
fn_never_extern, pipe), the allowlist arrivals, and the PDF size.


## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `be09778` (an empty commit), unedited.* Built on kasumi at
`f53290b` (`build-summary.txt`, the build the staged gates served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1. Files
are under `docs/audit/ww40-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `be09778`, first pin `b201091`; `git merge-base --is-ancestor be09778 b201091` exits 0; `be09778` was pushed to origin before any pin |
| three gitlink commits | book `b201091` (-> `2504a0fc`, 4 book count lines), wolf `181ca63` (-> `89dc1394`, 9 wolf count lines), lupin `1278c1e` (-> `f516a5f4`, 5 lupin count lines, and `crates/lupin-wasm/wasm-portability.patch`, sha256 `2cc2b8a3…`) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers, the book's diff, the 0.2.26 CHANGELOG | `derive.log` (script `ww40-derive.sh`) |
| linux aarch64 at 0.2.26 | `release-0226-rungate-arm-113939696545.log`: release run 37963417253, job 113939696545 (run gate, ubuntu-22.04-arm): `wolf 0.2.26 (wolfgang, pin 89dc139)`, `native tier: refuses by name, exit 2`, `release tier: refuses by name, exit 2`, `checked tier: exit(0), hello, wolf`; `release.yml` at v0.2.26 lines 203–217 assert both refusals |
| archive digests matched | `release-assets.txt`: wolf-lang release 408143286's four archives and wolf-interp release 408028965's five assets with GitHub's sha256; the linux x86-64 lupin archive is `84911a35…`, the digest wolf 0.2.26's CHANGELOG pairs by, and the archive `native-0149.txt` downloaded and ran hashes to it (`lupin 0.1.49 (… at pin 294d626)`); the tap's formulae name `v0.2.26` / `89dc1394…` and `v0.1.49` / `f516a5f4…` (tap head `0eecb7e`); AUR 0.2.26-1 / 0.1.49-1 / lobo-bin 0.1.2-1 read live |
| the guard reddens at the wolf pin | `guard-at-wolf-pin.txt` (kasumi, `181ca63`: wolf `89dc1394` against lupin `531bf05`): `the gap is 2 and the page does not say so — it must carry the phrase 'two releases'` on both pages, `LAG-EXIT=1`; CI run **37987036556** at `181ca63` (step "editor core and CSP gates", log `ci-red-at-wolf-pin-37987036556.log`) |
| the guard STAYS red at the lupin pin | `version-prose-red.txt` (kasumi, `1278c1e`): the same four lag lines, `LAG-EXIT=1`, and 89 version-prose lines (83 literal, 6 stamp), `VP-EXIT=1`, `CC-EXIT=0` (the 18 count lines re-stamped in the pins); CI run **37987716983** at `1278c1e` (log `ci-red-at-lupin-pin-37987716983.log`) |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.26 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads 2 releases back, and both pages carry 'two releases' and neither carries another`; `--json`: `{"gap": 2, "phrase": "two releases", "tagged": true, "commits": 213, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.26"}` |
| stamped lag | `speccommits 213`; `two hundred and thirteen commits` once on each built page (`build-summary.txt`) |
| census, four legs | `census-022{5,6}-014{8,9}.json`, `rows.txt` (script `ww40-rows.py`), driver `ww40-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.25 / 0.1.48 leg equals ww39's served census (592 / 443 / 39 / 110 / 0) |
| stdout probe, records, the whole running set's stdout | `stdout-probe-0149.txt`, `stdout-probe-0148.txt`; `records-0149.txt`, `records-0148.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww40-stdout-all.mjs`): all 618 running programs on the 0.2.26 corpus through both modules, 599 identical in verdict and stdout; the 19 that differ are the 18 module-moved rows and `fs/os_error.lu` (declined under both; 0.1.49 prints `start=0` before the fs tier declines) |
| the named rows at a terminal | `native-0149.txt`: the published lupin 0.1.49 archive on cfg_target_arch (`64`), the three atomics, atomic_counter (`400000 100000`), volatile, packed_field_raw_read, the three whole-struct stores and the two membrane rows (declined by name), fn_never_extern (`2`), chdir_relative (the header's eight lines, exit 0), pipe_round_trip and std_write_bytes (exit 0) |
| lupin 0.1.49 does not compile for wasm32 | `wasm-control-unpatched-red.txt` and `wasm-0149-unpatched.log` (script `ww40-wasm-control.sh`): the same build-wasm.sh at the same pins with the patch absent, `UNPATCHED-EXIT=1`, `error[E0433]: cannot find \`fs\` in \`super\``; `measure-run1-wasm-red.log` is the first measure run, stopped by it; with the patch `wasm-0149.log` says `applied wasm-portability.patch to the staged copy (submodule untouched)`; filed wolf-interp#222 |
| modules | lupin 0.1.49 built at `f516a5f4` with the patch, sha256 `289e6897…`, identical in the measure run and the build's `dist/play/lupin.wasm`; the 0.1.48 control is the live module fetched from lupp.us, `ee3d7b9f…` (`measure.log`) |
| book assets | `build-summary.txt`: `569 … versioned ?v=2504a0f; nothing exempt`, 0 bare, `wolf-boot.js?v=2504a0f` on 47 pages |
| chapter 7 and the new samples | `build-summary.txt`: six `<figure class="memory-diagram"><img src="diagrams/ch07/…svg">`, six SVGs sha-identical to ww39's (`5f9fae68…` … `d7209369…`); `book-staged.txt` (script `ww40-book.mjs`): on three engines × two viewports under lupp.us's headers, ch07 6 diagrams 6 rendered, 6 responses `200 image/svg+xml`, and ch02/ch06/ch08 each 200 with its new sample in a code block, 0 CSP violations, 0 console errors on every page; the checker seen red on a plant (one SVG removed, an inline script in ch02, ch08's `copy` dropped from its sample): `book-plant.txt`, 18 FAIL lines, `PLANT-EXIT=1` |
| staged gate | `gate-staged.txt` / `.json.gz` (script `ww40-gate-staged.sh`): 2,205 clicks and 0 faults on all six engine × viewport cells (the book's 404 path is in every cell's walk); retry from ch07 hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| audits, links, tests, menu, ahead | `build-summary.txt`: build exit 0; node tests 119 / 119; links 1,512 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 607 anchors; planted 8 pass; tab-target 5 / 5 |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 63; book 48; six SVGs sha-identical | 63; book 48; six SVGs sha-identical |
| version strings, version.json | 0.2.26 / 0.1.49; pins 89dc139 / f516a5f / 2504a0f, spec-pin 294d626, missing [] | identical (`build-summary.txt`) |
| lag | gap 2, 213, "two releases"; red at the wolf pin AND the lupin pin | identical (kasumi and CI 37987036556 / 37987716983) |
| census | 618 / 463 / 40 / 115 / 0 / 503 / 0 died | **618 / 465 / 40 / 113 / 0 / 505 / 0 died** — two arrivals I called declines run: `typecheck/fn_never_extern.lu` exits 0 (`2`; the handler is never taken, so the bodyless extern is never asked) and `os/chdir_relative.lu` exits 1 (see Found 2) |
| module leg on the 0.2.25 corpus | the five declines to exit(0) | identical, each as named |
| arrivals | 15 exit, 1 trap, 10 unsupported | 16 exit(0) + 1 exit(1), 1 trap, 8 unsupported |
| stdout probe | 0 real DIFF | 1 real DIFF: chdir_relative (`error: io`); bytes_scan's DIFF is the header's missing final newline; the rest are declines |
| old wrong answers in the tab | none | none: 599 of 618 identical across modules, the 19 as above |
| clocked allowlist lines | 107 (83 / 6 / 18) | 107 (83 / 6 / 18) |
| arrivals / leaves | v0.2.25 on four pages, 0.1.48 on play and install, a bound stamp on the front page; 0 leave | v0.2.25 on index (1), spec (1), install (4), play (5); 0.1.48 on install (3) and play (2); front page stamps 4 -> 5 (bound 2 -> 3); spec stamps 3 -> 7 (bound 3 -> 7); spec v0.2.16 6 -> 7; **play's v0.2.24 leaves** (1 -> 0); install 0.1.46 2 -> 1, v0.2.23 3 -> 2, v0.2.24 2 -> 1; play v0.2.18 2 -> 3, v0.2.21 3 -> 2, v0.2.22 4 -> 2, v0.2.23 4 -> 2; counts: play five 6 -> 7 (counted 5 -> 6), CHANGELOG five 30 -> 31 |
| stamps | 33 / 153 / 34 / 18 / 36; 607 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 5.78 ± 0.2 MB | 5.8 MB (5,763,958 B) |
| book assets | 569 versioned, 0 bare | 569, 0 bare |
| chapter 7 and new samples under the CSP | 6 rendered × 6 cells, samples present, 0 violations | identical (staged); live after the deploy |
| staged gate | 2,205 clicks, 0 faults ×6; retry 90/90 ×2 hops ×6 | identical |
| /play/'s refused list | empty; five declines leave | empty; the five leave; the declines that stand are the three whole-struct stores, extern let and extern libc (fn_never_extern is not one) |

**Found, not predicted.**
1. **lupin 0.1.49 does not compile to WebAssembly as released.** The new
   `os_error_text` arm calls `eval::fs::host_error_text`, and `mod fs` is
   gated out on wasm (E0433). The site's build has a designed path for this —
   `crates/lupin-wasm/wasm-portability.patch`, applied to a staged copy, the
   submodule untouched — and the patch rides with the lupin gitlink (it does
   not apply to 0.1.48): on wasm the arm declines by name, as the fs tier
   does. Seen red without it (`wasm-control-unpatched-red.txt`), filed as
   wolf-interp#222. When a release gates the arm, the script's reverse check
   reports the gate as upstream and the patch file can be deleted.
2. **One program answers differently in the tab without being declined.**
   `corpus/os/chdir_relative.lu` exits 1 printing `error: io` in the tab: the
   wasm build's `os_chdir` answers the `io` row (as `os_cpus` does there)
   where the fs tier and `os_pipe`/`os_spawn_fds` decline by name. At a
   terminal lupin 0.1.49 prints the header and exits 0 (`native-0149.txt`).
   /install/ and /play/ name it; noted on wolf-interp#222.
3. **/spec/ carried a stale relative sentence**: 03's Proc story said "the
   tab refused at the pin before this one", true at v0.2.16's bump; it is
   dated v0.2.16 now.
4. **docs/platforms.md has no linux aarch64 row** at v0.2.26 (unchanged since
   v0.2.25); the pages cite the release's run gate instead. Not this repo's
   to fix; reported.

## 5. Done-when

- [x] Branch `ww40` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim; census
      table, allowlist diff, probes, page count in §4.
- [x] Chapter 7 and its six diagrams, and the three new samples, served and
      checked under the production headers; the staged gate's 404 path and
      ch07 path at 0 faults.
- [x] CHANGELOG entry naming what moved, in words.
- [x] linux aarch64 sentences true at 0.2.26 (front page, /install/).
- [ ] CI green at the head sha (`gh run view`), waited to completion.
- [ ] After the merge: the deploy job's output, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
