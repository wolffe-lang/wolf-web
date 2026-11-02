# r41q — the site at wolf 0.2.36 and lupin 0.1.58

Class: one repo, one bump (four gitlinks, all four moving), one deploy. Crawl
54. Contract: the planning repo's `sprints/release/r41q-the-app-pins.md`
(item 4, wolf-web last) and `sprints/the-lane-rules-1031.md`. One deliverable:
lupp.us serves wolf 0.2.36, lupin 0.1.58, the book at wolf-book `64bb3c76`
and the standard library at wolf-std `dee6206f`, with every sentence those pins
make false rewritten and every one they leave true re-read. A merge to trunk
deploys lupp.us; this lane never merges. The orchestrator merges and reads the
live site back.

Ruled before the pages were written:
- **R-r41q-9** (A): finish wolf-web in this lane. That means the pins, every
  sentence they make false, and three pieces of staleness older than this
  lane: the front page described 0.2.34 under the 0.2.35 stamp, /spec/ said
  the EBNF was v0.2.23's byte for byte, and /install/ and /play/ made terminal
  claims about lupin that were last measured at 0.1.55. All of it is run again
  at 0.1.58.

## Prediction

Committed before the first change as `notes/r41q-prediction.txt` (`86d24cb`),
quoted there whole. In short:
- `version.json`: lupin `0.1.58`; pins wolf-lang `5adf3d9`, wolf-interp
  `6240efe`, wolf-book `64bb3c7`, wolf-std `dee6206`; spec-pin `a5378e3`;
  `missing []`.
- The stamps would read 0.2.36 and 0.1.58.
- The lag would be "one release" on "a development revision", 123 commits
  back.
- Every clock in the three allowlists would come due.

How it held:
- **Pins, stamps, lag phrase and distance:** held as predicted (see the
  evidence index).
- **Wrong in one place:** the prediction planned hasu builds with the wasm and
  the PDF waived. The builds below waive nothing: the nix rustc carries
  `wasm32-unknown-unknown`, and ww48's typst 0.15.1 was copied into this lane's
  directory.
- **Not foreseen:** how much of /install/'s and /play/'s present-tense prose
  the 0.2.35 bump had left unmeasured (section "What the pages said that was
  false").

## Forbidden

The lane never:
- merged, labelled, tagged or released anything, or pushed to trunk.
- filed or closed an issue.
- deployed by hand, or touched almanta, DNS or nginx.
- edited the planning repository or `~/.claude`.
- added an attribution trailer.
- built on the Mac, or used kasumi.
- killed anything by process group.
- used a `trap`/`kill` signal witness.

Every hasu job ran under both lock names of one block, the block name outside,
under `/home/mfwolffe/lanes/r41q/`. Containers were the lane's own
`r41q-pack-ci` image, run with `--memory 12g`, `--init` and `--network none`,
with `taskset` inside. No file under `/var/folders` was created or changed.

## Inputs verified

Each pin was read twice from GitHub (2026-11-02T17:23:06Z and 17:23:09Z) and
compared with `sprints/release/r41-evidence.md`. None was copied from it.

| gitlink | trunk had | now | read |
|---|---|---|---|
| upstream/wolf-lang | `cf0c13d` (v0.2.35) | `5adf3d91f75b3545ff8d38e5b6693b0b9f367a05` | tag v0.2.36, object `86d61559`, peels to it; r41-evidence line 10 agrees |
| upstream/wolf-interp | `28547b4` (v0.1.56) | `6240efe5570dba1a33ba6269e3ba44bae33dd972` | tag v0.1.58, object `dc4689e3`, peels to it; r41-evidence line 11 agrees; spec pin `a5378e3` |
| upstream/wolf-book | `591cd5d` | `64bb3c762abef32b32d1848419c76ccecd3a11e4` | wolf-book trunk after #100 merged by fast-forward |
| upstream/wolf-std | `5f49efd` | `dee6206fa99025336ca7a01845ef80cf9f6dc09a` | wolf-std trunk; its own `upstream` gitlink is `5adf3d91`, the pairing R-ww50-4 requires |

**`a5378e3`** is wolf-lang's "corpus: gate variadic declarations by target"
(2026-10-25):
- It is not a tag.
- It is 138 commits after v0.2.35 and 123 before v0.2.36.
- It is an ancestor of `5adf3d91`.
- Its newest release ancestor is v0.2.35, so the gap is one release.

**The live site** (curl `https://lupp.us/version.json`, 2026-11-01T20:39Z):
built 2026-10-25T22:06:56Z, lupin 0.1.56, pins `cf0c13d` / `28547b4` /
`591cd5d` / `5f49efd`, spec-pin `294d626`.

The live tap and AUR were read at 2026-11-02T17:39:47Z (`r41q-evidence/channels-live.txt`):
- The AUR carries `wolf-lang` and `wolf-lang-bin` 0.2.36-1, and `lupin` and `lupin-bin` 0.1.58-1. The fifth package is `lobo-bin`.
- The `wolffe-lang/homebrew-wolf` formulae build tags v0.2.36 and v0.1.58.

wolf-lang's release run 40744446774 (v0.2.36), job 123045503944, is the arm run gate (`r41q-evidence/arm-gate-0236.txt`). It reports:
- `wolf 0.2.36 (wolfgang, pin 5adf3d9)`.
- The native and release tiers each "refuse by name, exit 2".
- The checked tier answers `exit(0), hello, wolf`.
- The highest GLIBC symbol needed is 2.34.

The release has five assets: the four host archives and `wolf-rt-0.2.36-x86_64-unknown-linux-musl.tar.gz`.

The book's programs the pages name (§3.3, §34.3, §34.5–§34.8) were compared block by block between the old book pin `591cd5d` and `64bb3c76`:
- Only §34.6's two changed. They now go through `std.signal` and `std.process`, and both were measured again.
- ch13, ch21, ch25, ch29 and ch26–32 are unchanged, so the counts the front page and /reading/ hold on the book clock stand.

wolf-lang's `spec/10-types.md` and `docs/platforms.md` are byte-identical between `cf0c13d` and `5adf3d91`. So "ten" combinators and the "thirty-six" rows stand.

`grammar/1` still stands at 0.2.36. The production `, ...` widens the grammar, and `[gram.version.1]` allows additive change.

## Evidence index

Commits on trunk `b5f5ac3d`:
- `86d24cb` the prediction, before any change
- `c5a67ea` the pins: wolf-lang `5adf3d91`, wolf-interp `6240efe5`, wolf-std `dee6206f`
- `3651b06` the book at `64bb3c76`
- `a81820b` the front page: 0.2.36 advertised, with 0.2.35 and 0.2.34 as history
- `9cffc40` /spec/: the grammar's variadic production; the fork dated
- `6bc07d7` /install/, /play/: the lag at one release, on a development revision
- `0c8eddb` /spec/: the clauses v0.2.35 and v0.2.36 added
- `63782b5` the front page: v0.2.35's names of the system and the architecture
- `43a0c67` /install/: the release's fifth file
- `7a44a59` /install/: what 0.2.36, 0.2.35 and 0.2.34 brought, measured
- `a722ce9` /play/: the same, for the tab; the three declines that wait on a release
- `e813afc` the front page: what the interpreter runs of 0.2.35
- the allowlists, the CHANGELOG entry, the evidence and this record follow (the PR body lists every sha)

### What the pages said that was false, and what it is now

1. **The front page** described 0.2.34 under the 0.2.35 stamp, and v0.2.35 had no paragraph. The advertised paragraph is 0.2.36's now, v0.2.35 has its own, and 0.2.34 is history.
2. **/spec/** said "At (the stamp) the document and its EBNF are v0.2.23's, byte for byte". That became false when `spec/grammar.ebnf` changed at 0.2.36. It also told v0.2.34's fork under the current stamp. Both sentences are dated now. The entries for 02, 04, 05, 10 and 11 describe the clauses v0.2.35 and v0.2.36 added; the 0.2.35 bump had described none of them.
3. **The lag paragraphs on /install/ and /play/** said "eleven releases" on a release tag. Now they say "one release", on a development revision, 123 commits back. /install/'s second statement of the pin, which no gate reads, said "a release tag on the compiler's own line"; it says "a development revision" now.
4. **"The release above brought no program into the corpus's running set"**, on both pages, was 0.2.34's story under 0.2.35's stamp. Its claim that 0.2.34's seven calls "do not resolve … until a later lupin release mirrors them" was false from the 0.2.35 bump on: lupin 0.1.56 had mirrored them, and its module declines each with a tier. Both pages now carry the measured 0.2.36, 0.2.35 and 0.2.34 paragraphs.
5. **/play/ said the tab has "none of the second kind"**, that is, nothing waiting on an interpreter release. Three programs do:
   - `os/arg0.lu` and `os/args_bytes.lu`: their calls are mirrored on wolf-interp's trunk and ship in 0.1.59 (wolf-interp#295, closed 2026-11-01).
   - `os/core_limit_rows.lu`: its call is wolf-interp#277, open. That one was already true at 0.1.56.
   /install/'s matching "declined for the tab's own reasons" was corrected the same way.
6. **Both pages named one program that parts from its header in the tab**, `os/chdir_relative.lu`. The earlier lanes' second walk compared two modules, never the headers. This lane held every program the module runs to its header (`header-check-0.1.58.txt`):
   - 4 part for the tab's reasons: `chdir_relative.lu`, `args_cwd.lu` and `region_os_cwd_charged.lu` (a page has no working directory) and `cpus.lu`.
   - 2 part in both places: `faults/assert_msg_effect_fails.lu` and `assert_msg_name_fails.lu` print the assert's message before the trap. `[conf.trap.assert]` allows that rendering; wolf-lang#556 is open, and wolf-interp's divergence log carries it as DIV-2026-027.
7. **/play/ said the §34.8 save stops at a terminal at `fs_sync`.** Under lupin 0.1.58 alone it runs, printing the four lines the compiler prints.
8. **/install/'s "carries four archives"**: the release now carries a fifth, the musl runtime, which is no toolchain. It is named.
9. **The 0.2.33 history paragraphs** spoke of "the one this site served until now" and "before these pins". They are past tense now.

### Measurements (hasu, each job under both lock names of one block)

Every result below is in `docs/audit/r41q-evidence/`, with the script that made it.

**The census** (`census-*.json`, `census-*.txt`; `r41q-measure.sh`, ww33's `census.mjs`):

| module | corpus | programs | exit | trap | unsupported |
|---|---|---|---|---|---|
| live 0.1.56 | `cf0c13d` | 722 | 521 | 57 | 144 |
| live 0.1.56 | `5adf3d9` | 730 | 525 | 57 | 148 |
| 0.1.58 build | `5adf3d9` | 730 | 534 | 51 | 145 |

- No program is refused (`fail`), and no instance died.
- The wasm module was built by the site's own `build-wasm.sh`, as released, with no patch. It has no imports: 1527 KiB raw, 551 KiB gzipped (`build-wasm.log`).

**The second walk** (`stdout-all.txt`, `reasons-all.txt`; `r41q-walk.sh`) ran all 730 through 0.1.56's module and 0.1.58's:
- 721 are identical in verdict, stdout, phase, exit and reason.
- 9 differ: `list_reserve`, `list_reset`, `region_outer_write_reset` (declined under 0.1.56, run now) and `region_copy_shares_str`, `region_outer_write_{field,map,str_push,struct}`, `region_str_call_index_store` (trapped `region-fault`, run now). All are 0.2.35 arrivals.

**The decline reasons** (`declines-*.txt`): the reason for each of the 145 unsupported answers, under 0.1.58 at `5adf3d9` and under 0.1.56 at `cf0c13d`.

**The header check** (`header-check-0.1.58.txt`; `r41q-header-check.mjs`) held every census program in the tab to its `//! check: run(...)`:
- 572 AS HEADER.
- 145 declined.
- 7 with no run check.
- 6 DIFFERS: the six programs in item 6 above.

**The tab probes** (`probes-tab-*.txt`; `r41q-probes.sh` tab step, run again clean by `r41q-arrivals.sh`) put 76 programs through both modules (`probes/`):
- The calls of 0.2.33–0.2.36, one each.
- The book programs the pages name, verbatim; §34.6's in both the old and the new spelling.
- wolf-interp's own two variadic-call sources.

Results:
- 0.2.34's 7 calls are declined with their tiers: process, filesystem, time.
- 0.2.35's 13 and 0.2.36's `env_arg0` and `env_args_bytes` each answer "does not resolve".
- Both variadic calls are declined by name under 0.1.58. Under 0.1.56 they were `fail(E0201)`: the ellipsis did not parse.
- Everything else is identical under the two modules.

**At a terminal**, lupin 0.1.58 ran alone in the lane's container (`--init`, `--network none`, `--memory 12g`, `taskset` inside):
- **The probes** (`probes-terminal.txt`), with wolf 0.2.36 native beside each:
  - The syncs, `fs_realpath` and `os_clock_ns` answer; the restore and the wait over descriptors give the compiler's rows; `os_fork` is refused by name.
  - Both §34.7 programs stop at `os_fork`. §34.8's wait stops at `signal.listen`, since no std sits beside lupin. Its save prints the compiler's four lines.
  - 0.2.35's 13 calls and 0.2.36's two do not resolve.
- **The terminal pass** (`terminal-0.1.58.txt`) covered every `phase: run` program under os/, fs/, conc/ and time/, plus the programs the pages name: 99 programs, 80 as their headers say, 15 declined by name, 4 other, each agreeing with its check.
- **The net pass** (`terminal-net-0.1.58.txt`; `r41q-net.sh`): 18 programs, 15 as their headers say, 2 declined by name. `net/unix_echo.lu` parts, exactly as in ww46's pass.
- **The arrivals** (`terminal-arrivals-0.1.58.txt`) are the 47 `phase: run` programs v0.2.35 and v0.2.36 added: 39 as their headers say, 6 declined by name. The copy pair ran first, before any program had made `target/`, and answered `not_found`. Run again with `target/` present (`terminal-assert-0.1.58.txt`), `copy_chunk_failed_write.lu` prints its header and `copy_chunk_dev_full.lu` is declined by name, as in the terminal pass.
- **The assert pair under `lupin run --json`**: `stdout_inline` is `"effect\nm\n"` and `"before\nboom\n"`.
- The container's `SigBlk` is `0x380000` (SIGTSTP, SIGTTIN and SIGTTOU, from the ssh session). No probe uses them.

**Process faults, all mine, none in a result above:**
- The first tab run picked up 28 AppleDouble `._*.lu` files that an early tar had carried across. They were removed, and the tab step was run again clean.
- `web-probes.sh` was edited while it was queued, and its run read the file mid-edit. It stopped after its terminal step with a syntax error. The remaining steps were queued as a new file, `r41q-arrivals.sh`, never edited after.
- The first three jobs waited through a `flock -w 120` retry helper, against the lane rules' long-flock rule. Every later job used `r41q-block2.sh`: one `flock -w 21600` per lock name.
- One trunk-build job was queued with a mistyped sha. It stopped at its first step and built nothing.

### Builds

- **Trunk `b5f5ac3d`** (`build-trunk-b5f5ac3.log`; `r41q-build.sh` in build mode, block B, 2026-11-02T19:45:55Z–19:47:54Z):
  - Everything built, with no waiver: the book (49 pages), the PDF (6.1 MB), the wasm (1463 KiB raw), 36 samples, and the stamps.
  - `version.json` equals the live site's, apart from `built`.
- **The final head**: the gauntlet (`r41q-build.sh SHA gauntlet`) runs on hasu at the PR's final head. It works in a clone made for that commit (`web/g-<sha7>`, checked out detached and cleaned), and runs the CI build job's steps in CI's order:
- the pins against their gitlinks;
- the parse of every script;
- the node and python tests;
- `build.sh` with nothing waived;
- the "site has what it advertises" block, with `check-links`, `check-std` and the std reference checks;
- `check-samples`, `check-ahead`, the ahead witnesses and the tab-target test;
- the std-reference job's tests and its browser check.

Before the build it shows the lag gate red at the pin commit `c5a67ea`: those pages still said eleven releases, so `check-lag-phrases.py` must refuse them, and the step passes only if it does. The wrapper stops at the first nonzero step. Its `END` lines are in the PR body, verbatim, because they are measured at a head that already contains this record.

### What the deploy changes

A merge deploys trunk, and almanta builds it with `build.sh`. The PR body carries the diff between the trunk build (`dist-b5f5ac3`) and the gauntlet's build of the final head. It covers:
- `version.json` field by field;
- every stamped version string;
- every stamped count;
- every file added, removed or changed under `dist/`.

As predicted and as the pages are written:
- `version.json`: `lupin` `0.1.56` → `0.1.58`; pins `wolf-lang` `cf0c13d` → `5adf3d9`, `wolf-interp` `28547b4` → `6240efe`, `wolf-book` `591cd5d` → `64bb3c7`, `wolf-std` `5f49efd` → `dee6206`; `spec-pin` `294d626` → `a5378e3`; `missing` stays `[]`; `built` is the deploy's own time.
- "This is version 0.2.35" becomes "This is version 0.2.36". Every wolf version stamp reads 0.2.36, and every lupin stamp reads 0.1.58.
- The speccommits count was 1,338 commits at trunk (lupin 0.1.56's distance to v0.2.35, as spelled) and is 123 at the head. The other stamped counts are measured at the head and listed in the PR body.

## Done-when

- [ ] The PR is open at its final head, with `Footprint: cross-cutting`.
- [ ] The PR's CI run is green at that head: `std-reference` and `build`. `build` builds the whole site with nothing waived and runs the gates after it.
- [ ] The Windows learner path workflow is green at the same head. It runs on every push.
- [ ] The gauntlet at the final head has every step `exit=0` (END lines in the PR body).
- [ ] `lane-audit.sh wolf-web r41q-wolf-web <PR>` has been run once, and its last line is quoted in the hand-back.
- [ ] Handed back at the labelled head. The orchestrator merges, the deploy job runs, and the live site is read back against "What the deploy changes" above.

## R-list (the whole lane)

Rulings and recommendations across the lane's PRs (lair#26, fugue#35, trail#9, pack#47, cub#94, yew#101, wolf-book#100 and this one).

**R-r41q-1, the release tier's switch at 0.2.36** (lair).
- (A) keep `WOLF_MIDEND=0` until a pin carries s270; (B) drop it now.
- Recommended and implemented: A.

**R-r41q-2, lair's `ci/games.conf`.**
- (A) drop the merged `cb00`; (B) leave it and list the stale branch.
- Recommended and implemented: A.

**R-r41q-3, the plant's base.**
- (A) trunk plus one changed digest digit; (B) the branch plus the same.
- Recommended and implemented: A. The plant is lair#25 (run 41256355894).

**R-r41q-4, pack's own `wolf-toolchain.toml`.**
- (A) move it, and say it is unread; (B) delete it.
- Recommended and implemented: A.

**R-r41q-5, pack's README test split.**
- (A) the measured path split, 128 + 62; (B) the total alone.
- Recommended and implemented: A.

**R-r41q-6, yew's local gauntlet scope.**
- (A) the linux x86-64 `port` job step for step, with the rest left to CI; (B) the whole suite.
- Recommended and implemented: A.

**R-r41q-7, wolf-book's `[lupin-trace]`.**
- (A) follow `[lupin].rev` on byte-identical re-taken traces; (B) stay.
- Recommended and implemented: A.

**R-r41q-8, wolf-book's CHANGELOG gap.**
- (A) list it for the book's owner lane; (B) write the missing entries.
- Implemented: A. The orchestrator files it.

**R-r41q-9, finishing wolf-web.**
- Ruled A: this lane does the pins, every sentence they make false, and the three old pieces of staleness.

**R-r41q-10, how /install/ and /play/ hold their programs.** Asked here: they were held to the previous module, not to their headers.
- (A) hold the running set to its headers and correct the pages from that check, as done here (`r41q-header-check.mjs`).
- (B) keep the module walk alone and leave the partings sentence.
- Recommended and implemented: A. The header check is a measurement in this lane, not a gate in the site's CI. Making it one is listed for a later ww lane.

**R-r41q-11, /spec/'s missing v0.2.35 clauses.** Asked here.
- (A) describe them in this PR beside 0.2.36's.
- (B) list them for a later lane.
- Recommended and implemented: A. They are a handful of sentences, each checked against the pinned spec.

**R-r41q-12, wolf-web's CHANGELOG at 0.2.35.** Asked here: the 0.2.35 bump wrote no entry.
- (A) tell what this lane re-measured of 0.2.35 inside r41q's entry.
- (B) write a separate entry for that bump's merge.
- Recommended and implemented: A. The 0.2.35 bump's own changes, the lag at eleven and the re-read tier count and entropy sentences, stand in its commits.
