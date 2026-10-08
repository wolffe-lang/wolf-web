# ww39 — The Site at 0.2.25

Class: one repo, one bump (three gitlinks), one deploy. Opus. Wave 53.
Contract: the planning repo's sprints/web/ww39-the-site-at-0225.md (planning
trunk 0ef25dc). One deliverable: lupp.us serves wolf 0.2.25, lupin 0.1.48 and
the book at wolf-book fde77b8d (bs63: chapter 7 with its six memory diagrams),
every stamped number derived at the checkout. This commit is empty; its
message is sections 1 to 3, cut from wolf-web trunk ddd72b6 with all three
gitlinks at ww38's values. Section 4 lands later in
docs/audit/ww39-contract-0225.md; sections 1 to 3 are not edited after this
commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census and the node tests run on kasumi under ~/lanes/ww39/.
  nomad-1 runs git, gh, curl, ssh/scp, Playwright and the deploy step only.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww39/bin/; Playwright and its browsers are the ones
  already cached on nomad-1 (playwright-core read in place, never written).
- No rm outside ~/lanes/ww39/ (kasumi), this lane's worktree and this lane's
  namespaced scratch files; no deletion in any tree this lane did not create.
  No git add -A. Nothing under ~/.claude. No edit to another lane's file;
  ~/lanes/ww32/ and ~/lanes/ww38/ on kasumi are read, never written.
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
- No "seen red" without a run id, sha, path or digest in the same paragraph.
  File checksums carry a trailing ….
- Kill only this lane's own pids, never a pattern or a process group; on
  kasumi killable jobs start under setsid. In zsh a variable before a colon
  is braced.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-08 00:15-00:25 UTC, before any gitlink moves)

Script ww39-derive.sh, log derive.log (kasumi ~/lanes/ww39/, landing under
docs/audit/ww39-evidence/).

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | ddd72b69 | ddd72b69d5ab… | git ls-remote origin trunk |
| gitlinks at trunk | (ww38's: 0.2.23 / 0.1.46) | book e7772338…, wolf-lang 8edac3ee… (v0.2.23), wolf-interp f9269e33… (v0.1.46) | git ls-tree origin/trunk upstream/ |
| live version.json | — | built 2026-10-05T15:41:42Z, lupin 0.1.46, pins 8edac3e / f9269e3 / e777233, spec-pin 8e36bc1, missing [] | curl https://lupp.us/version.json |
| landed since ww38 | say whether anything did | yes: is71 (PR #57, ddd72b6, ruling #37 = B): the tab reads cfg(target) as x86_64-unknown-linux-gnu; deployed 2026-10-05T15:41Z | gh pr list; git log |
| wolf 0.2.25 | 6710f9e0, release 406122367 | tag object 90f1c11e… -> 6710f9e0cbc3…; release 406122367 draft:false prerelease:false, 4 assets, published 2026-10-07T20:18:34Z | gh api |
| lupin 0.1.48 | 531bf058, release 405340127 | tag object 469352f5… -> 531bf0581dea…; release 405340127 draft:false, 5 assets, published 2026-10-07T03:17:57Z; Cargo.toml version = "0.1.48" | gh api; derive.log |
| lupin 0.1.48's spec gitlink | — | 294d626d = v0.2.24 (0.1.46's was 8e36bc1a = v0.2.22) | derive.log |
| ancestry and the lag | — | 294d626d is an ancestor of 6710f9e0 (exit 0); rev-list --count 294d626d..6710f9e0 = 50; 8edac3ee..6710f9e0 = 189; CHANGELOG heads 0.2.25, 0.2.24, 0.2.23 so the guard's gap = 1 | derive.log |
| book target | fde77b8 (bs63, merged) | wolf-book trunk fde77b8d28c7…; e7772338 an ancestor, 71 commits, 153 files; SUMMARY blob identical (c5819603), 33 chapters | derive.log |
| chapter 7 | the memory chapter with its diagrams | book/ch07.md +265 −34; six ```memory fences (s3 L5, part-packcopy L5/L6/L7, part-handover L4, s7 L4) rendered as <figure class="memory-diagram"><img src="diagrams/ch07/…svg"> (xtask preprocess.rs); six SVGs under book/diagrams/ch07/, 2.6–3.7 KB, no <script>, no <style>, no external href (presentation attributes only); new since e7772338 | derive.log |
| corpus | — | phase: run set 580 -> 592: 12 in, 0 out, no pre-existing run program modified; anchors 586 -> 595 (9 added: conc.mm.atomic.*, conc.mm.fence, mem.unsafe.raw.4; 0 dropped); grammar.ebnf byte-identical; ## E 151 -> 153 (E1308, E1309), ## W 34, corpus/net 18 | derive.log |
| lupin's kept pins at 0.1.48 | is74 not in 0.1.48 | kept: attr_closed_set's control 1, volatile 6 (#185), kw11 atomic rows 9 + the racy counter (#194); dropped 16 (static 7, #190; repr_layout 9, #188); raw_align's repr(c) element and packed field re-keyed to wolf-interp#205 (`unsupported`, "has no member") | wolf-lang 0.2.25 CHANGELOG; *_lanes.rs at 6710f9e0 |

Drift, reported:
1. Something landed since ww38: is71 (ddd72b6). The live module is lupin
   0.1.46 built with is71's bridge, so the census baseline is is71's head
   leg, not ww38's: 580 programs, 434 exit, 39 trap, 102 unsupported, 5 fail,
   473 candidates (docs/audit/is71-evidence/census-diff.txt). /play/'s
   refused list on the live site is five entries (#188 ×4, #190), with
   cfg_target_arch already exiting 0.
2. wolf 0.2.25's CHANGELOG says "49 since v0.2.24" (39 + 10); rev-list
   --count v0.2.24..v0.2.25 says 50. ww38's pair agreed (187 + 13 = 200).
   The stamp is git's count; the one-commit difference is recorded, not
   absorbed.
3. lupin 0.1.48 re-pinned two releases forward (v0.2.22 -> v0.2.24), so the
   gap stays one release but the distance falls from 200 commits to 50.
4. The worktree is ~/GithubOrgs/wolffe-lang/wolf-web-ww39 (not under wt/).

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 63 dry, 63 live; the book's web edition 48 pages (SUMMARY
blob identical). Plus six SVG files under dist/book/diagrams/ch07/.
Falsified by any other count.

3.2 Version strings. /install/ and /play/ stamp 0.2.25 and 0.1.48; the
Windows archive link reads wolf-0.2.25-x86_64-pc-windows-msvc.tar.gz.
version.json: lupin 0.1.48, pins wolf-lang 6710f9e, wolf-interp 531bf05,
wolf-book fde77b8, spec-pin 294d626, missing [].

3.3 The lag. check-lag-phrases.py --json answers {"gap": 1, "phrase": "one
release", "tagged": true, "commits": 50, "spec": "294d626", "release":
"0.2.24", "advertised": "0.2.25"}. The phrase stays "one release"; the
stamped distance moves "two hundred" -> "fifty". The guard reddens at the
wolf pin commit (lupin 0.1.46's 8e36bc1 is v0.2.22, three releases behind
0.2.25: gap 3, "three releases") and is green again at the lupin pin with
no page edit.

3.4 The census at 0.2.25 / 0.1.48. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.23 and 0.2.25 corpora × the live 0.1.46 module,
fetched from lupp.us, and the built 0.1.48). Baseline: is71's head leg (the
live module on the 0.2.23 corpus).

| class | live (0.2.23 / 0.1.46 + is71) | ww39 predicted | delta |
|---|---|---|---|
| programs | 580 | 592 | +12 |
| exit | 434 | 443 | +9 |
| trap | 39 | 39 | 0 |
| unsupported | 102 | 110 | +8 |
| fail | 5 | 0 | −5 |
| candidates | 473 | 482 | +9 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.23 corpus (0.1.46 -> 0.1.48): exactly the five
refusals move, none to fail. comptime/layout_query_repr_c.lu and
memory/packed_fields_at_offset_of.lu fail(E0817) -> exit(0) (layout queries
and byte stores at offset_of: is73, #188); memory/raw_repr_packed_layout.lu
and memory/raw_repr_align_layout.lu fail(E0817) -> unsupported (packed and
align are admitted, then the whole-aggregate store through a *T to a struct
is declined by name; their headers say lupin refuses it by name, #205's
family); membrane/extern_let_image.lu fail(E0201) -> unsupported (the line
parses; a link-time symbol is declined by name, #190). Common rows: 0 move
under either module. Arrivals (12) under 0.1.48: 7 exit
(kernels/lshr_top_bits, memory/raw_aligned_control, raw_lshr_top_bits,
raw_store_call_writes, static_str_literals, static_var_call_deep,
static_var_call_writes) and 5 unsupported (conc/atomic_counter, atomic_fence,
atomic_orders, atomic_widths: no atomic surface yet, #194, is74 lands in
0.1.49; memory/packed_field_raw_read: the struct pointee, "has no member
`limit`", #205). The rows held least firmly: raw_repr_align_layout (could
exit if lupin stores a struct element), and extern_let_image's code.

Stdout probe under 0.1.48 (the 12 arrivals plus the five module-leg rows):
every exit program prints its header's stdout — 0 real DIFF. In particular
the s214 rows print 33554304 1 131071 15 31, 33554304 1 15 31, 9 9 4,
42 42 7 42 and 99 99 1, and static_str_literals prints the dedented values.

3.5 Old wrong answers. The census and /play/ run lupin, which printed the
right answer on #598, #600, #601 and #585 throughout (the rows' own
headers), so no /play/ or census program printed an old wrong answer that
0.2.25 corrects. Falsified by a menu or census program whose 0.1.46 output
differs from 0.1.48's on any of the s214 / s210 rows, or a menu program
that reads module state across a call or shifts a u64's top half.

3.6 Allowlist lines. All three clocks move (wolf 0.2.23 -> 0.2.25, lupin
0.1.46 -> 0.1.48, book e777233 -> fde77b8), so every clocked line reddens:
101 — version-allowlist 74 (55 wolf, 19 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 21 (10 wolf, 6 lupin, 5 book). Predicted to
arrive: v0.2.23 where 0.2.23's paragraphs become history (front page,
/spec/, /install/, /play/), v0.2.24 on /install/ and /play/ in the lag
paragraph (the tag lupin reads), and 0.1.46 on /play/ where the five
refusals are told as history. Leaves: none predicted. The arrivals are the
part I expect to get wrong.

3.7 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.25's story leads, with 0.2.24's beside it since the site
  skipped 0.2.24 (atomics and fences, E1308/E1309, the freestanding
  allocator, row L4, a module string holding its value, wolf prelude --json;
  then #598/#600/#601 fixed); 0.2.23's becomes history.
- /spec/: the bound sentences gain 02's row L4 and static clause, 03's
  atomics and fence, 04's freestanding allocator.
- /install/ and /play/: the lag paragraphs move from the v0.2.22 tag to the
  v0.2.24 tag; the gap holds one release.
- /play/: the refused list is re-derived from the census (3.8).
- /reading/: chapter 7 now draws its memory states; any reading that
  names chapter 7 is re-read.

3.8 /play/'s refused list after the bump: EMPTY — no refusal and no output
parting (it was five refusals, #188 ×4 and #190). Leaving: all five; two to
exit, three to a decline by name. The declines that stand or arrive (each
named): volatile (#185), the four atomics rows (#194), the struct pointee
rows (#205), extern let's link symbol (#190's by-name half).

3.9 Stamps other than the distance: bookchapters 33, diagnostics 153,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 595 anchors.

3.10 The menu. check-samples.mjs: 36 programs, every one in class.

3.11 The PDF. 5.75 MB ± 0.2 MB (chapter 7 grew by ~265 lines and six vector
figures).

3.12 Book assets: every same-origin .js/.css reference in dist/book carries
?v=fde77b8, 0 bare, 569 references (no page added). The six diagrams are
<img> references, unversioned, all resolving (check-links 0 dead).

3.13 Chapter 7 under the production CSP (staged on nomad-1, kasumi's
dist/book under lupp.us's headers; then live): ch07.html shows 6
figure.memory-diagram images, each with naturalWidth > 0 on three engines ×
two viewports, 0 CSP violations in the console, each SVG served
image/svg+xml with status 200.

3.14 The staged gate (nomad-1, three engines × two viewports): 2,205
clicks, 0 faults each; --retry from ch07.html hop 1 90/90, hop 2 90/90, 0
404s on all six; the book's 404 path 0 faults.

3.15 The deploy. The orchestrator's fast-forward starts ci.yml on push; its
"deploy to lupp.us" job prints "Deployed <stamp>"; live version.json = 3.2;
63 of 63 pages at 200; book pages load wolf-boot.js?v=fde77b8.

3.16 The live gate (nomad-1, three engines, two viewports): 2,205 clicks per
cell, 0 faults; --retry from ch07.html hop 1 90/90, hop 2 90/90 on all six,
0 HTTP 404 lines; chapter 7's six diagrams rendered as in 3.13. WebKit
timeouts over the public internet are reported with their lines, never
rerun away.

What I expect to get wrong: the two packed/align rows' module-leg class,
the allowlist arrivals, and the PDF size.



## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `7138c7b` (an empty commit), unedited.* Built on kasumi at
`0bfd316` (`build-summary.txt`, the build the staged gate served); later
commits touch only `CHANGELOG.md`, its allowlist lines and `docs/audit/`.
The gates' browsers ran on nomad-1. Files are under
`docs/audit/ww39-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `7138c7b`, first pin `f21205b`; `git merge-base --is-ancestor 7138c7b f21205b` exits 0; `7138c7b` was pushed to origin before any pin |
| three gitlink commits | book `f21205b` (-> `fde77b8d`, 4 book count lines), wolf `c44175f` (-> `6710f9e0`, 9 wolf count lines), lupin `1277b5d` (-> `531bf058`, 5 lupin count lines) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers, chapter 7's fences | `derive.log` (script `ww39-derive.sh`) |
| archive digests matched | `release-assets.txt`: wolf-lang release 406122367's four archives and wolf-interp release 405340127's five assets with GitHub's sha256; the linux x86-64 lupin archive is `81cfd77a…`, the digest wolf-lang 0.2.25's CHANGELOG pairs by, and the archive `native-0148.txt` downloaded and ran hashes to it (`lupin 0.1.48 (… at pin 294d626)`); the tap's formulae name `v0.2.25` and `v0.1.48` rev `531bf058…` (tap head `83fcd63`); AUR 0.2.25-1 / 0.1.48-1 read live |
| the guard reddens at the wolf pin | `guard-at-wolf-pin.txt` (kasumi, `c44175f`: wolf `6710f9e0` against lupin `f9269e3`): `the gap is 3 and the page does not say so — it must carry the phrase 'three releases'` on both pages, `LAG-EXIT=1`; in CI at `c44175f`: run **37707626036** (step "editor core and CSP gates", log `ci-red-at-wolf-pin-37707626036.log`) and windows run **37707621297** (step "the specification pin lag the site records", log `ci-red-at-wolf-pin-windows-37707621297.log`) |
| the guard green at the lupin pin with no page edit | `version-prose-red.txt` at `1277b5d`: `LAG-EXIT=0`; windows run 37707887050 at `1277b5d` green |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.25 is advertised; lupin was built at the v0.2.24 tag (294d626) — it reads the release before this one, and both pages carry 'one release' and neither carries another`; `--json`: `{"gap": 1, "phrase": "one release", "tagged": true, "commits": 50, "spec": "294d626", "release": "0.2.24", "advertised": "0.2.25"}` |
| stamped lag | `speccommits 50`; `fifty commits` once on each built page (`build-summary.txt`) |
| allowlists reddened | `version-prose-red.txt`: at `1277b5d`, before any prose edit, 72 version lines and 6 stamp entries asked to be re-read, `VP-EXIT=1`; CI run 37707890720 at `1277b5d` red on the same audit; the 18 clocked count lines were re-read and re-stamped in the three pin commits (`CC-EXIT=0` there) |
| census, four legs | `census-022{3,5}-014{6,8}.json`, `rows.txt` (script `ww39-rows.py`), driver `ww39-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.23 / 0.1.46 leg equals is71's served census (580 / 434 / 39 / 102 / 5) |
| stdout probe, records, the whole running set's stdout | `stdout-probe-0148.txt`, `stdout-probe-0146.txt`; `records-0148.txt`, `records-0146.txt` (script `docs/audit/ww38-evidence/ww38-records.mjs`); `stdout-all.txt` (script `ww39-stdout-all.mjs`): all 592 running programs on the 0.2.25 corpus through both modules, 586 identical in verdict and stdout, the 6 that differ the refusals named in §4's table |
| the named rows at a terminal | `native-0148.txt`: the published lupin 0.1.48 archive on cfg_target_arch (`64`), the two layout rows (headers' stdout), the three by-name declines, packed_field_raw_read, atomics, volatile, and static_var_call_writes (`99 99 1`) |
| modules | `lupin-0.1.48` built at `531bf058`, sha256 `6cd0c2ce…` = the built `dist/play/lupin.wasm`; the 0.1.46 control is the live module fetched from lupp.us, `c2a1f8bd…` (`measure.log`) |
| book assets | `build-summary.txt`: `569 … versioned ?v=fde77b8; nothing exempt`, 0 bare, `wolf-boot.js?v=fde77b8` on 47 pages |
| chapter 7 | `build-summary.txt`: six `<figure class="memory-diagram"><img src="diagrams/ch07/…svg">` in `dist/book/ch07.html`, six SVGs (2,644–3,732 B, sha256 listed), whose only style-like markup is 15 `font-style=` presentation attributes; `ch07-staged.txt` (script `ww39-ch07.mjs`): on three engines × two viewports under lupp.us's headers, 6 diagrams, 6 rendered, 6 responses `200 image/svg+xml`, 0 CSP violations, 0 console errors; the checker seen red on a plant (one SVG removed, one inline script added): `ch07-plant.txt`, 5 rendered and 1 CSP violation on every cell, exit 1. `ch07-staged-run1-favicon-counted.txt` is the checker's first run, whose Firefox cells failed on its own count (it counted the page's `favicon.svg`); the filter was narrowed to `diagrams/ch07/` and rerun |
| staged gate | `gate-staged.txt` / `.json.gz`: 2,205 clicks and 0 faults on all six engine × viewport cells (the book's 404 path, `no-such-page.html` and `front/no-such-page.html`, is in every cell's walk); retry from ch07 hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| audits, links, tests, menu, ahead | `build-summary.txt`: build exit 0; node tests 119 / 119; links 1,513 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 595 anchors; planted 8 pass; tab-target 5 / 5 |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| served pages | 63; book 48; six SVGs | 63; book 48; six SVGs |
| version strings, version.json | 0.2.25 / 0.1.48; pins 6710f9e / 531bf05 / fde77b8, spec-pin 294d626, missing [] | identical (`build-summary.txt`) |
| lag | gap 1, 50 commits, "fifty"; gap 3 at the wolf pin | identical |
| census | 592 / 443 / 39 / 110 / 0 / 482 / 0 died | 592 / 443 / 39 / 110 / 0 / 482 / 0 died |
| module leg on the 0.2.23 corpus | the five refusals: 2 to exit, 3 to unsupported; 0 common rows | identical, each as named |
| arrivals | 7 exit, 5 unsupported, each as named | identical |
| stdout probe | 0 real DIFF | 0 DIFF among exits (the 8 DIFF lines are the declines, which print nothing); `static_str_literals` has no stdout in its header and prints its strings dedented |
| old wrong answers in the tab | none | none: 586 of 592 identical across modules, the 6 the refusals |
| clocked allowlist lines | 101 (74 / 6 / 21) | **96 (72 / 6 / 18)**: my count grepped `audited-at-` in the files' comment headers too (five lines of prose that quote the column). The prediction was wrong; every real entry reddened |
| arrivals / leaves | v0.2.23 on four pages, v0.2.24 on install and play, 0.1.46 on play; 0 leave | v0.2.23 on index (1), spec (6), install (3), play (4); v0.2.24 on index (1), spec (3), install (2), play (1); 0.1.46 on install (2) and play (2); **0.1.47 on install (1)** (the unserved pairing named); 0 leave; install's 0.1.45 2 -> 1, play's v0.2.21 4 -> 3 |
| bound placeholders | — | spec `__WOLF_VERSION__` 6 -> 3, bound 3 (v0.2.23's three bound sentences dated) |
| stamps | 33 / 153 / 34 / 18 / 36; 595 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 5.75 ± 0.2 MB | 5.7 MB (5,732,506 B) |
| book assets | 569 versioned, 0 bare | 569, 0 bare |
| chapter 7 under the CSP | 6 rendered × 6 cells, 0 violations | identical (staged); live in the PR |
| staged gate | 2,205 clicks, 0 faults ×6; retry 90/90 ×2 hops ×6 | identical: 2,205 × 6 at 0 faults; retry 90/90 × 2 hops × 6, 0 `HTTP 404` |
| /play/'s refused list | empty | empty: 0 refusals, 0 output partings |

**Found, not predicted.**
1. **The refusal list is empty for the first time the site has measured it,
   and the pages had no sentence for that shape.** /install/ and /play/ said
   "at these pins it does so for the programs the list below names"; both now
   say the tab refuses none of the programs the compiler runs and name the
   declines instead.
2. **The front page's linux aarch64 sentence may be stale.** It says that
   archive "runs programs on the checked tier rather than compiling them";
   wolf-lang#614 (open, filed at 0.2.24) reports `wolf build` refusing the
   native tier there and `--release` building. Nothing in 0.2.24 or 0.2.25
   touched it, no host here is linux aarch64, and the sentence is not
   release-bound, so it is reported, not changed.
3. **wolf 0.2.25's CHANGELOG counts 49 commits since v0.2.24; git counts 50**
   (§2 drift 2). The stamp is git's.

## 5. Done-when

- [x] Branch `ww39` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim; census
      table, allowlist diff, probes, page count in §4.
- [x] Chapter 7 and its six diagrams served and checked under the production
      headers; the staged gate's 404 path and ch07 path at 0 faults.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion.
- [ ] After the merge: the deploy job's output, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
