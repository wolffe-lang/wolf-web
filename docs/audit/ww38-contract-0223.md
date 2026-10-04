# ww38 — The Site at 0.2.23

Class: one repo, one bump (three gitlinks), one deploy. Opus. Wave 53.
Contract: the planning repo's sprints/web/ww38-the-site-at-0223.md (planning
trunk fefbab6). One deliverable: lupp.us serves wolf 0.2.23, lupin 0.1.46 and
the book at wolf-book e7772338, every stamped number derived at the checkout.
This commit is empty; its message is sections 1 to 3, cut from wolf-web trunk
5e12ded with all three gitlinks at ww37's values. Section 4 lands later in
docs/audit/ww38-contract-0223.md; sections 1 to 3 are not edited after this
commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census and the node tests run on kasumi under ~/lanes/ww38/.
  nomad-1 runs git, gh, curl, ssh/scp and the browser gate, nothing that
  compiles.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww38/bin/; Playwright and its browsers are the ones
  already cached on nomad-1.
- No rm outside ~/lanes/ww38/ (kasumi), this lane's worktree and this lane's
  scratch files; no deletion in any tree this lane did not create. No
  git add -A. Nothing under ~/.claude. No edit to another lane's file;
  ~/lanes/ww32/ and ~/lanes/ww37/ on kasumi are read, never written.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy before the merge. PR open, unmerged; the orchestrator audits and
  fast-forwards; the deploy is the push run's "deploy to lupp.us" job.
- Never touch almanta's nginx config or anything needing sudo. A server
  change would be staged in the repo and reported. Never touch
  ~/scratch/wolf/lobo-demo or wolf.espadonne.com.
- No merge, no rebase-merge. No 2>/dev/null on a checkout; the branch is
  asserted after every checkout.
- No "seen red" without a run id, sha, path or digest in the same paragraph.
- Kill only this lane's own pids, never a pattern or a process group; on
  kasumi killable jobs start under setsid.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-04 20:35-20:45 UTC, before any gitlink moves)

Script ww38-derive.sh, log derive.log (kasumi ~/lanes/ww38/, landing under
docs/audit/ww38-evidence/ with release-assets.txt).

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | 5e12ded (ww37) | 5e12ded | git ls-remote origin trunk |
| gitlinks at trunk | book f1d894e, wolf-lang 8e36bc1 (v0.2.22), wolf-interp 9f4e4a1 (v0.1.45) | identical: f1d894ec0fe8…, 8e36bc1a0f92… (v0.2.22), 9f4e4a175da1… (v0.1.45) | git ls-tree HEAD upstream/ |
| live version.json | built 2026-10-04T04:03:46Z, lupin 0.1.45 | identical; pins 8e36bc1 / 9f4e4a1 / f1d894e, spec-pin dfcc2f1, missing [] | curl https://lupp.us/version.json |
| live release, nginx | — | current -> releases/2026-10-04-040313 (ww37's CI deploy); /etc/nginx/conf.d/lupp.us.conf sha256 2c6f09d1… = trunk's nginx/lupp.us.conf | ssh almanta readlink, sha256sum |
| wolf 0.2.23 | 8edac3ee, release 403069562 | tag object b05c0ef3… -> 8edac3eeb486…; release 403069562 draft:false prerelease:false, 4 assets, published 2026-10-04T15:20:26Z | gh api; release-assets.txt |
| lupin 0.1.46 | f9269e33, release 403040421 | tag object 281fe8c7… -> f9269e336416…; release 403040421 draft:false, 5 assets, published 2026-10-04T13:45:39Z; Cargo.toml version = "0.1.46"; linux x86-64 archive d13a0379…, the digest wolf-lang 0.2.23's CHANGELOG pairs by | gh api; derive.log |
| lupin 0.1.46's spec gitlink | — | upstream at f9269e3 = 8e36bc1a = v0.2.22 (0.1.45's was dfcc2f13, v0.2.21) | derive.log |
| book target | e7772338 (bs60) | wolf-book trunk e77723384283…; f1d894e an ancestor, 21 commits, 54 files | derive.log |
| ancestry and the lag | — | merge-base --is-ancestor 8e36bc1a 8edac3ee exits 0; rev-list --count 8e36bc1a..8edac3ee = 200 (the CHANGELOG says 187 + 13 = 200, agreeing); CHANGELOG headings at the pin run 0.2.23, 0.2.22, … so the guard's gap = 1 | derive.log |
| the book's statement of the pair | — | bs60 ecd883a: "the pair reads 0.2.23 / 0.1.46 — 200 commits, one release" | derive.log |
| lupin's kept pins at 0.1.46 | volatile #185, layouts #188, module-state #[section] #190 | 23 kept: attr_implemented_set 1, volatile 6 (#185), repr_layout 9 (#188), static 7 (#190); 37 dropped (#174 12, #181 4, #175 7, #178 1, #179 6, #184/#182 7) | wolf-lang 0.2.23 CHANGELOG; *_lanes.rs at 8edac3ee |
| doors | — | AUR wolf-lang / wolf-lang-bin 0.2.23-1, lupin / lupin-bin 0.1.46-1; tap head 187a001, wolf.rb v0.2.23 rev 8edac3ee…, lupin.rb v0.1.46 rev f9269e33… | release-assets.txt |
| W0304 (prelude size_of/align_of/offset_of) | grep | no site/ program and no book page at e7772338 defines one | derive.log |
| wolf-lang#585 (module-level """) | name it if reached | no phase: run corpus program at 8edac3ee and nothing under site/; the book's ch06 capstone (book/ch06.md:808, `let USAGE = """`) is one | derive.log |

Facts read off the checkouts (derive.log): spec/grammar.ebnf moves
(910ff9d5… -> 67816f8f…: bare_item gains extern_let_item, kw09's
`extern "c" let`); anchors 569 -> 586 (17 added: abi.interrupt,
abi.layout.align/packed/query, abi.link + .extern/.script/.section,
mem.prov.device, mem.static + .1/.2/.3, mem.unsafe.volatile + .1/.2/.3;
none dropped); `## E` 147 -> 151, `## W` 34 -> 34, corpus/net 18 -> 18.
Spec documents moved: 01, 02, 04, 10, anchors.json, grammar.ebnf;
docs/diagnostics.md. The phase: run set 559 -> 580, 21 in, 0 out; one
pre-existing run program modified, in a comment only
(rows/unit_discard_fallible_body_stmt.lu). lupin 9f4e4a1..f9269e3: 66
commits. Book f1d894e..e777233: SUMMARY blob identical (c581960), 33
chapters; chapters touched 01, 03, 09, 18, 20, 22, 32, appendices A and C,
the colophon, solutions; 13, 21, 25 and 29 untouched.

Drift, reported:
1. The contract's preamble says "the book at bs58's head"; its own §2 names
   bs60's e7772338, which is the target.
2. Planning trunk is 992fba8 at this commit (one commit past the contract's
   fefbab6: px05's record; this contract's file unchanged).
3. The contract's "volatile rows #185, new layouts #188, module-state
   `#[section]` #190, each by name": the pins at 8edac3ee say the four
   kw08 run rows are `fail(E0817)` under 0.1.46 (its closed attribute set
   refuses `repr(c, packed)` / `repr(c, align(N))`), not a by-name decline,
   and `membrane/extern_let_image.lu` is `fail(E0201)` (lupin's grammar is
   v0.2.22's, which has no `extern "c" let`). Those are refusals, so they
   join /play/'s refused list rather than its declines.
4. lupin 0.1.46 reads `cfg(target = …)` against the triple it was built for
   (src/attrs.rs build_target, LUPIN_HOST_TRIPLE = cargo's TARGET). The tab's
   module is built for wasm32-unknown-unknown, so in the tab neither of
   cfg_target_arch.lu's two `arch_bits` survives. Not in the contract.
5. wolf-lang#585 is reached by the book (ch06's capstone), not by /play/ or
   the census. The site serves the book page as bs60 wrote it; named here
   and in the report, not worked around.
6. kasumi /home 95 %, 55 GB free (20:45 UTC). nomad-1's main checkout
   (19e8b06, modified gitlinks, not this lane's) is untouched; this branch
   lives in the worktree ~/GithubOrgs/wolffe-lang/wt/wolf-web-ww38.

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 63 dry, 63 live; the book's web edition 48 pages (SUMMARY
blob identical). Falsified by any other count.

3.2 Version strings. /install/ and /play/ stamp 0.2.23 and 0.1.46; the
Windows archive link reads wolf-0.2.23-x86_64-pc-windows-msvc.tar.gz.
version.json: lupin 0.1.46, pins wolf-lang 8edac3e, wolf-interp f9269e3,
wolf-book e777233, spec-pin 8e36bc1, missing []. Falsified by any of these
on the built dist/ or the live file.

3.3 The lag. check-lag-phrases.py --json answers {"gap": 1, "phrase": "one
release", "tagged": true, "commits": 200, "spec": "8e36bc1", "release":
"0.2.22", "advertised": "0.2.23"}. The phrase stays "one release"; the
stamped distance moves "two hundred and twenty-two" -> "two hundred". The
guard reddens at the wolf pin commit (lupin 0.1.45's dfcc2f1 is v0.2.21,
two releases behind 0.2.23: gap 2, "two releases") and is green again at
the lupin pin with no page edit. Falsified by any other value.

3.4 The census at 0.2.23 / 0.1.46. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.22 and 0.2.23 corpora x the live 0.1.45 module and
the built 0.1.46). Baseline ww37's census-0222-0145.json.

| class | ww37 (0.2.22 / 0.1.45) | ww38 predicted | delta |
|---|---|---|---|
| programs | 559 | 580 | +21 |
| exit | 416 | 433 | +17 |
| trap | 38 | 39 | +1 |
| unsupported | 100 | 102 | +2 |
| fail | 5 | 6 | +1 |
| candidates | 454 | 472 | +18 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.22 corpus (0.1.45 -> 0.1.46): 5 rows move —
grammar/cfg_target_freestanding.lu fail(E0401) -> exit(0) (#174),
memory/raw_ptr_private_sig.lu and memory/raw_ptr_mut_param.lu fail(E1302)
-> exit(0) (#181), membrane/extern_libc.lu fail(E1302) -> unsupported (the
bodyless C declaration declined by name), and grammar/cfg_target_arch.lu
fail(E0302) -> fail(E0401): lupin reads cfg now, but in the tab the build
target is wasm32, which neither definition names, so `arch_bits` is
unresolved. This is the prediction I hold least firmly; the code may be
another resolve code. Corpus leg, common rows: 0 move under either module.
Arrivals (21) under 0.1.46: 14 exit (prov_addr_with_addr,
prov_cast_round_trip, prov_expose_round_trip, prov_is_null,
prov_narrow_cast, raw_deref, raw_deref_signed, static_const_let,
static_var, five unit_discard_tail_if*), 1 trap(overflow)
(prov_narrow_cast_trap), 5 fail — comptime/layout_query_repr_c.lu,
memory/packed_fields_at_offset_of.lu, memory/raw_repr_packed_layout.lu,
memory/raw_repr_align_layout.lu fail(E0817) (#188: the closed attribute set
refuses repr(c, packed) and repr(c, align(N))) and
membrane/extern_let_image.lu fail(E0201) (`extern "c" let` is v0.2.23
grammar; #190) — and 1 unsupported: memory/volatile_widths.lu (#185, by
name, `_volatile`).

Stdout probe under 0.1.46 (the 21 arrivals plus unit_discard_if_value):
every exit program that names its stdout prints it — 0 real DIFF;
rows/unit_discard_if_value.lu prints "() ()" (#179 healed), prov_narrow_cast
prints "200 -1 4294967295" (#184 healed). Trailing-newline-only DIFFs, as
ww37 saw, are not partings. Falsified by any other class count, any died
row, a module-leg row beyond the five, or a real DIFF.

3.5 Allowlist lines. All three clocks move, so every clocked line reddens:
91 — version-allowlist 67 (51 wolf, 16 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book). Predicted to arrive:
v0.2.22 where 0.2.22's paragraphs become history (front page, /spec/,
/install/, /play/) and 0.1.45 on /install/ and /play/ where #174, #181 and
#179 are told as history. Leaves: none predicted. The arrivals are the part
I expect to get wrong.

3.6 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.23's story leads (integer/pointer conversion and *p,
  volatile, packed and align(N) with size_of/align_of/offset_of, module
  state as image data, #[section] and extern "c" let, interrupts, ruling
  #34); 0.2.22's becomes history.
- /spec/: the bound sentences gain 02's provenance, volatile and static
  clauses, 04's layout, link and interrupt clauses, 01's extern let.
- /install/ and /play/: the lag paragraphs move from the v0.2.21 tag to the
  v0.2.22 tag; #174's, #181's and #179's partings become history (healed
  in 0.1.46); the refused list is re-derived from the census (3.7).

3.7 /play/'s refused list after the bump: six refusals and no output
parting (it was five refusals and one output parting). Leaving: both #174
rows as #174, both #181 rows and extern_libc (now a decline), and #179's
output. Arriving or staying: the four kw08 rows fail(E0817) (#188),
membrane/extern_let_image.lu fail(E0201) (#190, v0.2.23 grammar), and
grammar/cfg_target_arch.lu, which stays refused for a new reason (the
tab's wasm32 target, not vintage). The contract expected the list to
shrink; by count of refusals I predict it does not (5 -> 6), by entries it
holds (6 -> 6), and every member but one changes.

3.8 Stamps other than the distance: bookchapters 33, diagnostics 151,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 586 anchors.
The /reading/ readings stand (chapters 13, 21, 25, 29 untouched).

3.9 The menu. check-samples.mjs: 36 programs, every one in class.

3.10 The PDF. 5.7 MB +- 0.2 MB.

3.11 wolf-boot.js stays versioned: every same-origin .js/.css reference in
dist/book carries ?v=e777233, 0 bare, 569 references.

3.12 The staged gate (nomad-1, kasumi's dist/book under the site's CSP):
2,205 clicks, 0 faults on each of three engines x two viewports; --retry
from ch07.html hop 1 90/90, hop 2 90/90, 0 404s on all six.

3.13 The deploy. The orchestrator's fast-forward starts ci.yml on push; its
"deploy to lupp.us" job prints "Deployed <stamp>"; live version.json = 3.2;
63 of 63 pages at 200; book pages load wolf-boot.js?v=e777233.

3.14 The live gate (nomad-1, three engines, two viewports): 2,205 clicks per
cell, 0 status/title/number/entries/state/search faults; --retry from
ch07.html hop 1 90/90, hop 2 90/90 on all six, 0 HTTP 404 lines. Click
and goto timeouts over the public internet are reported with their lines,
never rerun away.

What I expect to get wrong: cfg_target_arch's code in the tab, the
allowlist arrivals, the staged gate's click count if the book's pages grew
links, and WebKit's timeouts on the live gate.


## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `9091c43` (an empty commit), unedited.* Built on kasumi at
`c840e08` (`build-summary.txt`, the build the staged gate served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1. Files
are under `docs/audit/ww38-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `9091c43`, first pin `4384163`; `git merge-base --is-ancestor 9091c43 4384163` exits 0; `9091c43` was pushed to origin before any pin |
| three gitlink commits | book `4384163` (-> `e7772338`, 4 book count lines), wolf `e033b2f` (-> `8edac3ee`, 9 wolf count lines), lupin `6dfa3e7` (-> `f9269e33`, 5 lupin count lines) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers | `derive.log` (script `ww38-derive.sh`) |
| archive digests matched | `release-assets.txt`: wolf-lang release 403069562's four archives and wolf-interp release 403040421's five assets with GitHub's sha256; the linux x86-64 lupin archive is `d13a0379…`, the digest wolf-lang 0.2.23's CHANGELOG pairs by, and the archive `native-cfg.txt` ran hashes to it; the tap's formulae name tag `v0.2.23` rev `8edac3ee…` and `v0.1.46` rev `f9269e33…`, the gitlinks |
| the guard reddens at the wolf pin | `guard-at-wolf-pin.txt`: the site at `e033b2f` against wolf `8edac3ee` and lupin `9f4e4a1`: `the gap is 2 and the page does not say so — it must carry the phrase 'two releases'` on both pages, exit 1 |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.23 is advertised; lupin was built at the v0.2.22 tag (8e36bc1) — it reads the release before this one, and both pages carry 'one release' and neither carries another`; `--json`: `{"gap": 1, "phrase": "one release", "tagged": true, "commits": 200, "spec": "8e36bc1", "release": "0.2.22", "advertised": "0.2.23"}` |
| stamped lag | `speccommits 200`; `two hundred commits` once on each built page (`build-summary.txt`) |
| allowlists reddened | `version-prose-red.txt`: at `6dfa3e7`, before any prose edit, 67 version lines and 6 stamp entries asked to be re-read, `VP-EXIT=1`; the 18 clocked count lines were re-read and re-stamped in the three pin commits (`CC-EXIT=0` there) |
| census, four legs | `census-022{2,3}-014{5,6}.json`, `rows.txt` (script `ww38-rows.py`), driver `ww38-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.22 / 0.1.45 leg equals ww37's served census (559 / 416 / 38 / 100 / 5). `measure-run1-no-0145.log` is the first run, whose 0.1.45 legs had no module (the fetch line was cut from the script); the second run is the measurement |
| stdout probe, records | `stdout-probe-0146.txt`, `stdout-probe-0145.txt`; `records-0146.txt`, `records-0145.txt` (script `ww38-records.mjs`): the full observation record, reason included, for every refusal and decline the pages name |
| the tab's cfg parting | `records-0146.txt`: `grammar/cfg_target_arch.lu` `unsupported`, "`arch_bits` does not resolve"; `native-cfg.txt`: the published lupin 0.1.46 linux archive prints `64`, exit 0, on the same file; filed wolf-web#55 |
| modules | `lupin-0.1.46.wasm` sha256 `eea1c09f…` = the built `dist/play/lupin.wasm`; the 0.1.45 control is the live module fetched from lupp.us, `7a9be83c…` (`measure.log`) |
| wolf-boot.js versioned | `build-summary.txt`: `569 … versioned ?v=e777233; nothing exempt`, 0 bare, `wolf-boot.js?v=e777233` on 47 pages |
| staged gate | `gate-staged.txt` / `.json.gz`: 2,205 clicks and 0 faults on all six engine × viewport cells; retry hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| audits, links, tests, menu, ahead | `build-summary.txt`: build exit 0; node tests 114 / 114; links 1,508 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 586 anchors; planted 8 pass |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| pages dry / book | 63 / 48 | 63 / 48 |
| versions, `version.json` | 0.2.23, 0.1.46; `8edac3e` `f9269e3` `e777233`, spec-pin `8e36bc1`, missing [] | identical (built); the Windows link reads `wolf-0.2.23-x86_64-pc-windows-msvc.tar.gz` (3 references) |
| guard JSON | gap 1, one release, tagged, 200, `8e36bc1`, 0.2.22, 0.2.23 | identical |
| guard at the wolf pin | gap 2, two releases | gap 2, two releases, both pages |
| census programs / exit / trap / unsupported / fail / candidates / died | 580 / 433 / 39 / 102 / 6 / 472 / 0 | 580 / 433 / 39 / **103** / **5** / 472 / 0 |
| module leg on the 0.2.22 corpus | 5 rows; cfg_target_arch fail(E0302) -> fail(E0401) | 5 rows, those five; **cfg_target_arch fail(E0302) -> unsupported** ("`arch_bits` does not resolve"): lupin declines an unresolved name in the tab rather than refusing it |
| corpus legs, common rows | 0 | 0 under either module |
| arrivals | 14 exit, 1 trap, 5 fail, 1 unsupported, each as named | identical, each as named |
| stdout probe, exits | 0 real DIFF; `unit_discard_if_value` `() ()`, `prov_narrow_cast` `200 -1 4294967295` | 0 DIFF among the exits; both as predicted. Under 0.1.45 the same probe has 6 exit DIFFs (`prov_narrow_cast` `0 0 0`, four `unit_discard_tail_if*`, `unit_discard_if_value`) |
| clocked allowlist lines | 91 (67 / 6 / 18) | 91 (67 / 6 / 18) |
| arrivals / leaves | `v0.2.22` on 4 pages, `0.1.45` on install and play; 0 leave | `v0.2.22` on index (1), spec (7), install (3), play (4); `0.1.45` on install (2) and play (3); **1 leaves** (play's `v0.2.20`); install's `0.1.44` 2 -> 1 and `v0.2.21` 3 -> 2, play's `0.1.44` 3 -> 2 |
| bound placeholders | — | spec `__WOLF_VERSION__` 7 -> 6, all bound (01 ×2, 02, 04 ×2, 10); install `__LUPIN_VERSION__` 6 -> 7, bound 2 -> 3 |
| stamps | 33 / 151 / 34 / 18 / 36; 586 anchors | identical |
| menu | 36 in class | 36 in class; no menu program uses `cfg` |
| PDF | 5.7 ± 0.2 MB | 5.7 MB (5,676,404 B) |
| book assets | 569 versioned, 0 bare | 569, 0 bare |
| staged gate | 2,205 clicks, 0 faults ×6; retry 90/90 ×2 hops ×6 | identical |
| /play/'s refused list | 6 refusals (#188 ×4, #190, cfg_target_arch), 0 output partings | **5** refusals (#188 ×4, #190), 0 output partings, and cfg_target_arch as a decline that parts in the tab alone (wolf-web#55) |

**/play/'s list, before and after.** At ww37 (0.2.22 / 0.1.45): five
refusals — `grammar/cfg_target_arch.lu` `fail(E0302)` and
`grammar/cfg_target_freestanding.lu` `fail(E0401)` (#174),
`memory/raw_ptr_private_sig.lu`, `memory/raw_ptr_mut_param.lu` and
`membrane/extern_libc.lu` `fail(E1302)` (#181) — and one output parting,
`rows/unit_discard_if_value.lu` (#179). At ww38 (0.2.23 / 0.1.46): five
refusals — `comptime/layout_query_repr_c.lu`,
`memory/packed_fields_at_offset_of.lu`, `memory/raw_repr_packed_layout.lu`,
`memory/raw_repr_align_layout.lu` `fail(E0817)` (#188) and
`membrane/extern_let_image.lu` `fail(E0201)` (#190) — no output parting, and
`grammar/cfg_target_arch.lu` `unsupported` in the tab only. Every one of
ww37's six left the list; it holds as many refusals as before because 0.2.23
brought five new witnesses lupin 0.1.46 does not mirror yet. Entries 6 -> 6
counting the tab's decline, 6 -> 5 without it.

**Found, not predicted.**
1. **The tab claims to be WebAssembly when it reads `cfg`.** lupin 0.1.46
   evaluates `cfg(target = …)` against the triple it was built for
   (`LUPIN_HOST_TRIPLE` = cargo's `TARGET`), and `crates/lupin-wasm` builds
   for `wasm32-unknown-unknown`. A program gated to `x86_64` and `aarch64`
   loses both definitions in the tab and is declined; at a terminal it prints
   `64`. Not the distance and not the text: a choice about which machine the
   tab says it is, so it is named on the pages and filed (wolf-web#55, three
   options). In the tab an unresolved name is a decline, not lupin's
   terminal `E0401`, so my code guess was wrong too.
2. **The book's ch06 capstone reaches wolf-lang#585.** `book/ch06.md:808`
   opens wordcount with a module-level `let USAGE = """…"""` and says it is
   "dedented by its closing `"""` exactly as in chapter 2"; on the compiled
   tiers at 0.2.23 a module `let` holding a `"""` string prints its raw
   literal (#585, which bs60 filed from ch22). No /play/ program or census row
   reaches it. The site serves the book as bs60 wrote it; reported, not
   worked around.
3. **A count can ride only one clock.** The count allowlist keys one clock per
   word per page, so a page whose new sentences put a wolf-clocked `five`
   beside a lupin-clocked `five` cannot be listed honestly. Three sentences
   name the programs instead of counting them (`e39e793`, `c1bab66`).

## 5. Done-when

- [x] Branch `ww38` on origin; PR open, **unmerged**, body carries these five
      sections by name, commit shas as bullets, a test checklist.
- [x] The prediction commit precedes the first gitlink commit.
- [x] Three gitlink commits (book, wolf, lupin), each with its count-allowlist
      lines.
- [x] Stamps at the checkout; the guard's line and JSON quoted verbatim; census
      table, allowlist diff, probes, page count in §4.
- [x] `wolf-boot.js` versioned; the staged gate's 404 path and ch07 path at 0
      faults.
- [x] CHANGELOG entry naming what moved, in words.
- [ ] CI green at the head sha (`gh run view`), waited to completion.
- [ ] After the merge: the deploy job's output, the live gate, the live
      `version.json`.
- [ ] Worktree removed; `target/` pruned on kasumi; no orphans.
