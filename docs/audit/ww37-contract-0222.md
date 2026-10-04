# ww37 — The Site at 0.2.22

Class: one repo, one bump (three gitlinks), one deploy. Opus. Wave 53.
Contract: the planning repo's sprints/web/ww37-the-site-at-0222.md (planning
trunk 2ecdead). One deliverable: lupp.us serves wolf 0.2.22, lupin 0.1.45 and
the book at wolf-book f1d894ec, every stamped number derived at the checkout.
This commit is empty; its message is sections 1 to 3, cut from wolf-web trunk
6f4b7cf with all three gitlinks at ww36's values. Section 4 lands later in
docs/audit/ww37-contract-0222.md; sections 1 to 3 are not edited after this
commit except to append.

## 1. Forbidden, absolutely

- No build on nomad-1. The wasm module, the book render, the PDF, the site
  build, the census and the node tests run on kasumi under ~/lanes/ww37/.
  nomad-1 runs git, gh, curl, ssh/scp and the browser gate, nothing that
  compiles.
- No install anywhere. typst is read from ~/lanes/ww32/bin/typst through a
  symlink in ~/lanes/ww37/bin/; Playwright and its browsers are the ones
  already cached on nomad-1.
- No rm outside ~/lanes/ww37/ (kasumi), this lane's worktree and this lane's
  scratch dir; no deletion in any tree this lane did not create. No
  git add -A. Nothing under ~/.claude. No edit to another lane's file;
  ~/lanes/ww32/ and ~/lanes/ww36/ on kasumi are read, never written.
- No hand-typed count, version or distance in site/. Every number comes from
  the stamps; every stamped or literal sentence changes only through the
  allowlists.
- No deploy before the merge. PR open, unmerged; the orchestrator audits and
  fast-forwards; the deploy is the push run's "deploy to lupp.us" job.
- Never touch almanta's nginx config or anything needing sudo. A server
  change would be staged in the repo and reported.
- No merge, no rebase-merge. No 2>/dev/null on a checkout; the branch is
  asserted after every checkout.
- No "seen red" without a run id, sha, path or digest in the same paragraph.
- Kill only this lane's own pids, never a pattern or a process group; on
  kasumi killable jobs start under setsid.
- No gh run watch without --interval 60; every wait prints at least every
  five minutes. No attribution trailer on any commit or in the PR body.

## 2. Inputs, verified (re-derived 2026-10-04 03:00-03:30 UTC, before any gitlink moves)

Script ww37-derive.sh, log derive.log (kasumi ~/lanes/ww37/, landing under
docs/audit/ww37-evidence/).

| input | contract says | re-derived | source |
|---|---|---|---|
| wolf-web trunk | 6f4b7cf (ww36) | 6f4b7cf | git rev-parse origin/trunk |
| gitlinks at trunk | book fba6210, wolf-lang dfcc2f13 (v0.2.21), wolf-interp ba47627 (v0.1.44) | identical: fba6210a1af2…, dfcc2f13e7c7… (v0.2.21), ba4762714d75… (v0.1.44) | git ls-tree HEAD upstream/ |
| live version.json | built 2026-10-03T12:32:14Z, lupin 0.1.44, missing [] | identical; pins dfcc2f1 / ba47627 / fba6210, spec-pin cdde128 | curl https://lupp.us/version.json |
| live release, nginx | — | current -> releases/2026-10-03-123135 (ww36's CI deploy); /etc/nginx/conf.d/lupp.us.conf sha256 2c6f09d1… = trunk's nginx/lupp.us.conf | ssh almanta readlink, sha256sum |
| wolf 0.2.22 | 8e36bc1a, tag v0.2.22, release 402696856 | tag object 173a3ef9… -> 8e36bc1a0f92…; release 402696856 draft:false prerelease:false, 4 assets, published 2026-10-03T21:37:36Z; 0 drafts | gh api |
| lupin 0.1.45 | 9f4e4a17, tag v0.1.45, release 402670966 | tag object 25c7932d… -> 9f4e4a175da1…; release 402670966 draft:false, 5 assets, published 2026-10-03T20:03:34Z; Cargo.toml version = "0.1.45" | gh api; derive.log |
| lupin 0.1.45's spec gitlink | — | upstream at 9f4e4a1 = dfcc2f13 = v0.2.21 (0.1.44's was cdde128a, v0.2.20) | derive.log |
| book target | f1d894ec (bs59) | wolf-book trunk f1d894ec0fe8… = PR #71's merge = its head; fba6210 an ancestor, 23 commits, 39 files | gh pr view 71; derive.log |
| ancestry and the lag | — | merge-base --is-ancestor dfcc2f13 8e36bc1a exits 0; rev-list --count dfcc2f13..8e36bc1a = 222; CHANGELOG headings at the pin run 0.2.22, 0.2.21, … so the guard's gap = 1 | derive.log |
| the book's statement of the pair | — | bs59 06fd89a: "the pair reads 0.2.22 / 0.1.45 — 222 commits, one release" | wolf-book log |
| #176 | the parting is gone at 0.1.45 | 0.2.22's CHANGELOG: eu_bind_empty_row_handled.lu "Verdict -> agreement", the #176 pin dropped; lupin's run ledger at 9f4e4a1 lists it exit(0) | derive.log; wolf-interp tests/run_corpus.rs |
| the 26 kept pins | 26 known partings, each naming its issue | attr_closed_set 13 (#174), c_membrane 4 (#181), first_diagnostic 7 (#175), region_view_for 1 (#178), unit_discard 1 (#179); one kept verdict changed (cfg_target_freestanding.lu unsupported -> fail(E0401), #174) | wolf-lang 0.2.22 CHANGELOG; *_lanes.rs at 8e36bc1a |
| doors | — | AUR wolf-lang / wolf-lang-bin 0.2.22-1, lupin / lupin-bin 0.1.45-1; tap head 3347689, wolf.rb v0.2.22 rev 8e36bc1a…, lupin.rb v0.1.45 rev 9f4e4a17… | AUR RPC v5; gh api homebrew-wolf |

Facts read off the checkouts (derive.log): spec/grammar.ebnf byte-identical
(910ff9d5… both sides); anchors 546 -> 569 (23 added: abi.asm x5,
abi.c.export, abi.c.import, abi.layout.c, abi.target x6, gram.item.attr.cfg,
gram.item.attr.set, mem.unsafe.sig, os.fs.read_at/seek/std/tell,
proto.record.first, type.numlit.cast.narrow; none dropped); `## E` 144 -> 147,
`## W` 34 -> 34, corpus/net 18 -> 18. Spec documents moved: 01, 02, 04 (+206),
06, 08, 10, 11 (+126), anchors.json; docs/diagnostics.md. The phase: run set
533 -> 559, 26 in, 0 out; two pre-existing run programs modified, both in
comments or an attribute (comptime.lu drops #[noalloc]; wrap_narrow_cast.lu
comment). Arrivals' check: lines: 23 run(exit=0…), 3 run(exit=trap(overflow)).
lupin ba47627..9f4e4a1: 58 commits. Book fba6210..f1d894e: SUMMARY blob
identical (c581960), 33 chapters; chapters touched 01, 06, 09, 18, 20, 22,
32, appendix C, the index, colophon, solutions; 13, 21, 25 and 29 untouched
(ch25's exercises file moved, not the chapter).

Drift, reported:
1. The contract's preamble says "the book at bs58's head"; its own §2 names
   bs59's f1d894ec, which is the target (bs58's head is the book live now).
2. wolf-lang's 0.2.22 CHANGELOG says "Eight lanes and 209 commits"; the
   compiler's history carries 222 dfcc2f13..8e36bc1a (the book says 222).
   The site prints only the stamped 222.
3. The live lupin.wasm is sha256 db934cd7…, not ww36's kasumi build
   68a400b5…: the deploy builds on almanta and the module embeds its build
   path (ww34's path-control.txt). The 0.1.44 control leg here is the live
   module, fetched, not a rebuild.
4. r27's evidence names typecheck/numlit_binding_value_later_use.lu as a new
   mismatch (lupin traps overflow, wolf-interp#173), but lupin's own run
   ledger at 9f4e4a1 lists it exit(0) and ww36's probe under 0.1.44 matched it.
   The census decides; prediction below says it matches.
5. "26 known partings" are gate cases, most of them negatives the run census
   never feeds. The ones a phase: run census can meet are cfg_target_arch,
   cfg_target_freestanding, attr_implemented_set (#174), raw_ptr_private_sig,
   raw_ptr_mut_param (#181), and unit_discard_if_value's output (#179).
6. kasumi /home 94 %, 60 GB free (03:30 UTC). nomad-1's main checkout
   (37 behind trunk, modified gitlinks, not this lane's) is untouched; this
   branch lives in the worktree ~/GithubOrgs/wolffe-lang/wolf-web-ww37.

## 3. Prediction, committed before the first gitlink moves

3.1 Served pages. 63 dry, 63 live; the book's web edition 48 pages (SUMMARY
blob identical). Falsified by any other count.

3.2 Version strings. /install/ and /play/ stamp 0.2.22 and 0.1.45; the
Windows archive link reads wolf-0.2.22-x86_64-pc-windows-msvc.tar.gz.
version.json: lupin 0.1.45, pins wolf-lang 8e36bc1, wolf-interp 9f4e4a1,
wolf-book f1d894e, spec-pin dfcc2f1, missing []. Falsified by any of these on
the built dist/ or the live file.

3.3 The lag. check-lag-phrases.py --json answers {"gap": 1, "phrase": "one
release", "tagged": true, "commits": 222, "spec": "dfcc2f1", "release":
"0.2.21", "advertised": "0.2.22"}. The phrase stays "one release"; the stamped
distance moves "ninety-one" -> "two hundred and twenty-two". The guard reddens
at the wolf pin commit (lupin 0.1.44's cdde128 is v0.2.20, two releases
behind 0.2.22: gap 2, "two releases") and is green again at the lupin pin
with no page edit. Falsified by any other value.

3.4 The census at 0.2.22 / 0.1.45. Harness docs/audit/ww33-evidence/census.mjs
unmodified; four legs (0.2.21 and 0.2.22 corpora x the live 0.1.44 module and
the built 0.1.45). Baseline ww36's census-0221-0144.json.

| class | ww36 (0.2.21 / 0.1.44) | ww37 predicted | delta |
|---|---|---|---|
| programs | 533 | 559 | +26 |
| exit | 401 | 416 | +15 |
| trap | 35 | 38 | +3 |
| unsupported | 96 | 101 | +5 |
| fail | 1 | 4 | +3 |
| candidates | 436 | 454 | +18 |
| kills the instance | 0 | 0 | 0 |

Module leg on the 0.2.21 corpus (0.1.44 -> 0.1.45): 2 rows move —
rows/eu_bind_empty_row_handled.lu fail(E0801) -> exit(0) (#176 healed) and
memory/nested_fn_mut_param.lu unsupported -> exit(0) (#169). Corpus leg,
common rows: 0 move under either module. Arrivals (26) under 0.1.45:
13 exit (cast_narrow_in_range, cast_narrow_wrapping_truncates, export_called,
raw_compound_assign, region_str_view_for_inside, first_list_literal_sum,
seven unit_discard_*), 3 trap(overflow) (cast_narrow_*_trap), 4 fail —
grammar/cfg_target_arch.lu fail(E0302) and grammar/cfg_target_freestanding.lu
fail(E0401) (wolf-interp#174: lupin reads no cfg), memory/raw_ptr_private_sig.lu
and memory/raw_ptr_mut_param.lu fail(E1302) (#181: lupin refuses *T in every
signature) — and 6 unsupported: fs/read_at, fs/seek_tell (no files in a tab),
membrane/export_child (sibling files), membrane/extern_libc (a bodyless
extern, declined by name), grammar/attr_implemented_set (#174's measured
decline), memory/raw_repr_c_layout (a whole-aggregate raw store, declined by
name).

Stdout probe under 0.1.45 (the 26 arrivals plus eu_bind_empty_row_handled and
numlit_binding_value_later_use): every exit program that names its stdout
prints it, except rows/unit_discard_if_value.lu, which prints "() none" for
"() ()" (#179) — 1 DIFF among the exits; eu_bind_empty_row_handled prints
43 42 42; numlit_binding_value_later_use matches. Falsified by any other
class count, any died row, a module-leg row beyond the two, or another DIFF.

3.5 Allowlist lines. All three clocks move, so every clocked line reddens:
87 — version-allowlist 63 (48 wolf, 15 lupin), stamp-allowlist 6 (4 wolf,
2 lupin), count-allowlist 18 (9 wolf, 5 lupin, 4 book). Predicted to arrive:
v0.2.21 where 0.2.21's paragraphs become history (front page, /spec/,
/install/, /play/) and 0.1.44 on /install/ and /play/ where #176 is told as
history. Leaves: none predicted. The arrivals are the part I expect to get
wrong.

3.6 Sentences false at the new stamps (re-read, rewritten).
- front page: 0.2.22's story leads (the freestanding target, asm in wolf.pkg,
  the closed attribute set, the narrowing cast, the export seam, seek/tell and
  the standard streams); 0.2.21's becomes history.
- /spec/: the bound sentences gain 04's ABI clauses, 11's offset and
  standard-stream clauses, 10's narrowing cast, 01's attribute set.
- /install/ and /play/: the lag paragraphs move from the v0.2.20 tag to the
  v0.2.21 tag; "at these pins it is one program long" and every "one
  program" sentence about #176 comes off; #176 becomes history (healed in
  0.1.45); the refused list is re-derived from the census (3.7).

3.7 /play/'s refused list after the bump: four programs, each named with its
open lupin issue, none worked around — grammar/cfg_target_arch.lu
fail(E0302) and grammar/cfg_target_freestanding.lu fail(E0401) (#174),
memory/raw_ptr_private_sig.lu and memory/raw_ptr_mut_param.lu fail(E1302)
(#181); and one output parting, rows/unit_discard_if_value.lu (#179). #176's
program leaves the list.

3.8 Stamps other than the distance: bookchapters 33, diagnostics 147,
warnings 34, netprograms 18, samples 36. check-ahead: 0 ahead, 569 anchors.
The /reading/ readings stand (chapters 13, 21, 25, 29 untouched).

3.9 The menu. check-samples.mjs: 36 programs, every one in class.

3.10 The PDF. 5.7 MB +- 0.2 MB.

3.11 wolf-boot.js stays versioned (ww36): every same-origin .js/.css
reference in dist/book carries ?v=f1d894e, 0 bare, 569 references.

3.12 The staged gate (nomad-1, kasumi's dist/book under the site's CSP):
2,205 clicks, 0 faults on each of three engines x two viewports; --retry
from ch07.html hop 1 90/90, hop 2 90/90, 0 404s on all six.

3.13 The deploy. The orchestrator's fast-forward starts ci.yml on push; its
"deploy to lupp.us" job prints "Deployed <stamp>"; live version.json = 3.2;
63 of 63 pages at 200; book pages load wolf-boot.js?v=f1d894e.

3.14 The live gate (nomad-1, three engines, two viewports): 2,205 clicks per
cell, 0 status/title/number/entries/state/search faults; --retry from
ch07.html hop 1 90/90, hop 2 90/90 on all six, 0 HTTP 404 lines. Click
timeouts over the public internet are reported with their lines, never
rerun away.

What I expect to get wrong: the arrivals' classes under the wasm build
(attr_implemented_set, raw_repr_c_layout and export_called are read off
terminal gates, not measured in a tab), the allowlist arrivals, and WebKit's
click timeouts on the live gate.

## 4. Evidence index

*Filled in after the measurement; sections 1 to 3 above are the text of the
prediction commit `374a267` (an empty commit), unedited but for backticks
around §2's `## E` and `## W`, which a line wrap had made a Markdown heading.* Built on kasumi at
`cb288ab` (`build-summary.txt`, the build the staged gate served); later
commits touch only `docs/audit/`. The gates' browsers ran on nomad-1. Files
are under `docs/audit/ww37-evidence/`.

| claim | artifact |
|---|---|
| prediction precedes the first pin | prediction `374a267`, first pin `4b2e56b`; `git merge-base --is-ancestor 374a267 4b2e56b` exits 0; `374a267` was pushed to origin before any pin |
| three gitlink commits | book `4b2e56b` (-> `f1d894ec`, 4 book count lines), wolf `9c4e836` (-> `8e36bc1a`, 9 wolf count lines), lupin `ba51a13` (-> `9f4e4a17`, 5 lupin count lines) |
| inputs, lag, corpus sets, anchors, grammar, arrivals' headers | `derive.log` (script `ww37-derive.sh`) |
| archive digests matched | `release-assets.txt`: wolf-lang release 402696856's four archives and wolf-interp release 402670966's five assets with GitHub's sha256; the linux x86-64 lupin archive is `907cfb1a…`, the digest wolf-lang 0.2.22's CHANGELOG pairs by; the tap's formulae name tag `v0.2.22` rev `8e36bc1a…` and `v0.1.45` rev `9f4e4a17…`, the gitlinks |
| the guard reddens at the wolf pin | `guard-at-wolf-pin.txt`: the site at `9c4e836` against wolf `8e36bc1a` and lupin `ba47627`: `the gap is 2 and the page does not say so — it must carry the phrase 'two releases'` on both pages, exit 1 |
| ancestry guard, verbatim | `build-summary.txt`: `lag phrases: wolf 0.2.22 is advertised; lupin was built at the v0.2.21 tag (dfcc2f1) — it reads the release before this one, and both pages carry 'one release' and neither carries another`; `--json`: `{"gap": 1, "phrase": "one release", "tagged": true, "commits": 222, "spec": "dfcc2f1", "release": "0.2.21", "advertised": "0.2.22"}` |
| stamped lag | `speccommits 222`; `two hundred and twenty-two commits` once on each built page (`build-summary.txt`) |
| allowlists reddened | `version-prose-red.txt`: at `ba51a13`, before any prose edit, 63 version lines (48 wolf, 15 lupin) and 6 stamp entries asked to be re-read, exit 1; the 18 clocked count lines were re-read and re-stamped in the three pin commits |
| census, four legs | `census-022{1,2}-014{4,5}.json`, `rows.txt` (script `ww37-rows.py`), driver `ww37-measure.sh`, log `measure.log`, harness `docs/audit/ww33-evidence/census.mjs` unmodified; the 0.2.21 / 0.1.44 leg equals ww36's served census (533 / 401 / 35 / 96 / 1) |
| stdout probe, records | `stdout-probe-0145.txt`, `stdout-probe-0144.txt`; `records-0145.txt` (script `ww37-records.mjs`): the full observation record, reason included, for every decline and refusal named on the pages |
| modules | `lupin-0.1.45.wasm` sha256 `f03b1d92…` = the built `dist/play/lupin.wasm`; the 0.1.44 control is the live module fetched from lupp.us, `db934cd7…` (`measure.log`) |
| wolf-boot.js versioned | `build-summary.txt`: `569 … versioned ?v=f1d894e; nothing exempt`, 0 bare, `wolf-boot.js?v=f1d894e` on 47 pages |
| staged gate | `gate-staged.txt` / `.json.gz`: 2,205 clicks and 0 faults on all six engine × viewport cells; retry hop 1 and hop 2 90/90 on all six, 0 `HTTP 404`, 0 `ERROR` in 1,092 hop lines |
| audits, links, tests, menu, ahead | `build-summary.txt`: build exit 0; node tests 114 / 114; links 1,507 across 63 pages, 0 dead; check-samples 36 in class, 18 net unsupported; check-ahead 0 ahead, 569 anchors; planted 8 pass |
| CI at head | in the PR body |

**Prediction vs measurement**

| item | predicted | measured |
|---|---|---|
| pages dry / book | 63 / 48 | 63 / 48 |
| versions, `version.json` | 0.2.22, 0.1.45; `8e36bc1` `9f4e4a1` `f1d894e`, spec-pin `dfcc2f1`, missing [] | identical (built) |
| guard JSON | gap 1, one release, tagged, 222, `dfcc2f1`, 0.2.21, 0.2.22 | identical |
| guard at the wolf pin | gap 2, two releases | gap 2, two releases, both pages |
| census programs / exit / trap / unsupported / fail / candidates / died | 559 / 416 / 38 / 101 / 4 / 454 / 0 | 559 / 416 / 38 / **100** / **5** / 454 / 0 |
| arrivals | 13 exit, 3 trap, 4 fail, 6 unsupported | 13 exit, 3 trap, **5** fail, **5** unsupported — `membrane/extern_libc.lu` is `fail(E1302)` on `strlen`'s `*u8` parameter (#181), not a decline of the bodyless extern: the signature check comes first |
| module leg on the 0.2.21 corpus | 2 rows (#176 healed, #169 runs) | 2 rows, those two |
| corpus legs, common rows | 0 | 0 under either module |
| stdout probe, exits | 1 DIFF (#179) | 1 real DIFF (`unit_discard_if_value.lu`, `() none` for `() ()`, #179); the probe also reports `cast_narrow_in_range.lu` and `cast_narrow_wrapping_truncates.lu` as DIFF on a trailing newline only — their headers spell no `\n`, and the compiler's own corpus check strips one (`xtask/src/main.rs:722` at `8e36bc1a`), so neither is a parting; `eu_bind_empty_row_handled` `43 42 42` and `numlit_binding_value_later_use` MATCH |
| clocked allowlist lines | 87 (63 / 6 / 18) | 87 (63 / 6 / 18) |
| arrivals / leaves | `v0.2.21` on 4 pages, `0.1.44` on install and play; 0 leave | `v0.2.21` on index (1), spec (2), install (3), play (4); `0.1.44` on install (2) and play (3); **2 leave** (install's `0.1.43` and `v0.2.20`); play's `v0.2.18` 3 -> 2 |
| bound placeholders | — | spec `__WOLF_VERSION__` 3 -> 7, all bound (01 ×2, 02, 04, 06, 10, 11) |
| stamps | 33 / 147 / 34 / 18 / 36; 569 anchors | identical |
| menu | 36 in class | 36 in class |
| PDF | 5.7 ± 0.2 MB | 5.7 MB (5,667,318 B) |
| book assets | 569 versioned, 0 bare | 569, 0 bare |
| staged gate | 2,205 clicks, 0 faults ×6; retry 90/90 ×2 hops ×6 | identical |
| /play/'s refused list | 4 refusals (#174 ×2, #181 ×2) and 1 output parting (#179) | **5** refusals (#174 ×2, #181 ×3) and 1 output parting (#179) |

**Found, not predicted.**
1. **#174 and #181 are the distance; #179 is not.** `[gram.item.attr.cfg]` and
   `[mem.unsafe.sig]` are anchors 0.2.22 added, so the five refusals witness
   clauses written after the text lupin 0.1.45 was built to; `[type.unit.context]`
   and `[type.unit.discard]` are in v0.2.21's `anchors.json`, so #179's output
   parting is a disagreement inside the text both read. The pages say which is
   which.
2. **A unit `main` whose tail raises exited 1 under the deployed 0.1.44**
   (`rows/unit_discard_unit_main.lu`, `hi\nerror: bad`); 0.1.45 exits 0.
   A wolf-only bump would have served that parting too (`stdout-probe-0144.txt`:
   13 DIFF under the live interpreter).
3. **`grammar/attr_implemented_set.lu` prints `3` and then declines** at its
   `comptime fn` (`records-0145.txt`): the page counts it as a decline of the
   interpreter's scope, not a parting.

## 5. Done-when

- [x] Branch `ww37` on origin; PR open, **unmerged**, body carries these five
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
