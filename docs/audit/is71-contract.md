# is71 — the tab's target (ruling #37 = B, wolf-web#55)

Contract: wolffe-lang/wolf `sprints/interpreter/41-the-tab-target/is71-the-tab-target.md`
at planning trunk `f7c299c`; STATUS ruling #37 = B. The contract commit is
`647d7de` (empty, five sections, prediction before any change). Builds and
measurements ran on kasumi under `~/lanes/is71/`; nothing was built on nomad-1.

## 1. Forbidden

As committed in `647d7de`: no rm outside `~/lanes/is71/` and this lane's
worktree; no `git add -A`; nothing under `~/.claude`; no build on nomad-1; no
merge, no tag; no `2>/dev/null` on a checkout; no attribution trailers; no
kernel source read; no lupin pin moved or widened; no native lupin build
changed. Kept: wolf-interp is not edited at all, and the wolf-interp gitlink
stays `f9269e3` (v0.1.46).

## 2. Inputs, verified

- **Correction to the contract and the brief.** `crates/lupin-wasm` is not in
  wolf-interp: wolf-interp `c63b612` has no wasm crate and its CI has no wasm
  job. The crate is wolf-web's, built by `scripts/build-wasm.sh` for
  `wasm32-unknown-unknown` from the `upstream/wolf-interp` gitlink. The branch
  is `is71` on wolf-web, off `origin/trunk` `98e3df4`.
- The API option B needs is public at the pin v0.1.46 (`f9269e3`):
  `wolf_interp::attrs::with_build_target` (src/attrs.rs:152) and
  `wolf_interp::export::BUNDLE_TARGET` = `x86_64-unknown-linux-gnu`
  (src/export.rs:90). **So the change needs no lupin release**: it ships with
  wolf-web's next deploy at any pin from v0.1.46 on, not in lupin 0.1.47.
- On wasm, `parse()` runs on the caller's stack (src/parse.rs,
  `#[cfg(target_family = "wasm")]`), so the thread-local the wrapper sets is
  the one the parse's `cfg` decisions read.
- wolf-web CI builds the real module and runs node gates against it; it does
  not run the crate's cargo tests, rustfmt or clippy.

## 3. Prediction, scored

| row | predicted | measured (trunk -> head module) | |
|---|---|---|---|
| grammar/cfg_target_arch.lu | unsupported -> exit(0) "64\n" | unsupported ("`arch_bits` does not resolve") -> exit(0) "64\n" | hit |
| grammar/cfg_target_freestanding.lu | exit(0) "hosted\n1\n" both | the same | hit |
| grammar/cfg_target_unknown.lu | fail(E0817) both | the same | hit |
| membrane/extern_let_image.lu | unsupported both, the reason moving | **fail(E0201) both**, unmoved: the tab's grammar has no `extern "c" let` (wolf-interp#190), so the file never reaches `cfg` | miss |
| ffi.lu | unchanged | **exit(1) -> unsupported** (inline `asm`, declined by name) | miss |
| census | one row moves; unsupported 103 -> 102, exit 433 -> 434 | exactly that, one row moved (`census-diff.txt`) | hit |

The `ffi.lu` miss is the finding beyond the brief: at trunk the tab dropped
both architecture-gated `asm` blocks and **exited 1 on a program whose header
says `run(exit=0)`**, with no diagnostic. With the target it keeps the x86_64
`asm` and declines it by name, which is what lupin does at a terminal on every
host (wolf-interp CI: "ffi.lu keeps one asm variant on every host and declines
it by name"). It is `phase: resolve`, so the census never walked it.

## 4. Evidence index

All under `docs/audit/is71-evidence/`.

| claim | evidence |
|---|---|
| witness red at trunk, locally | `leg-trunk.out`, `tab-target-trunk.log` (`ed856b0a…`): module `7cba64c5…` built at `6b136c4` (the test, no fix), 4 of 5 fail; the first failure quotes the tab's `unsupported` |
| witness red at trunk, in CI | run **37332226850** at `6b136c4`, step "the tab reads cfg as x86_64-unknown-linux-gnu" failed; log `ci-red-at-trunk-37332226850.log` (`287e9bf1…`) |
| witness green with the fix | `leg-head.out`, `tab-target-head.log` (`e59fea09…`): module `92b948ad…` at `9b5c460`, 5 of 5; CI run 37332346803 green at `9b5c460` |
| planted break red in CI, reverted | plant `af5790f` (`lupin_observe` without the wrapper) red in run **37333104467**, tests 1 and 4 failing, record and version tests passing; log `ci-plant-red-37333104467.log` (`c8fbcee7…`); reverted by `f0e1771` |
| census before and after | `census-trunk.json.gz` (`c27b2d65…`), `census-head.json.gz` (`25b87951…`), diff `census-diff.txt` (`8b8a6d70…`, script `is71-diff.py`), harness `docs/audit/ww33-evidence/census.mjs` unmodified; trunk equals ww38's 0.2.23 / 0.1.46 leg (580 / 433 / 39 / 103 / 5) |
| the cfg rows in full | `records-trunk.txt` (`5d06b0e8…`), `records-head.txt` (`814a995d…`), script `docs/audit/ww38-evidence/ww38-records.mjs` |
| the crate's host gates | `crate.out`, `crate-test.log` (`cca7d773…`): clippy `-D warnings` exit 0, 10 of 10 tests (two new: the bridge reads `cfg` as the bundle target under a wasm32 ambient target, for observe and for the record); rustfmt's one remaining diff is a pre-existing line, red at trunk `98e3df4` too (`fmt-trunk-vs-head.txt`) |
| full build and every CI gate at `a28dec6` | `build.out` (`aa000fcc…`): pre-build 119/119, build exit 0 (version prose, counts, lag phrases, stamps), samples 36 in class, ahead gate 0 ahead and 8/8 planted, tab target 5/5, links exit 0, the banner line in dist |
| native builds unchanged | wolf-interp is not edited; its gitlink stays `f9269e3`; the change is in the wasm bridge alone |
| CI green at head | the PR body names the run at the final head |

Scripts: `is71-leg.sh`, `is71-crate.sh`, `is71-build.sh`, `is71-diff.py`.

## 5. Done-when

- Branch `is71`, PR wolf-web#57 open and unmerged.
- CI green at head (run id in the PR body).
- Close nothing. wolf-web#55 closes when lupp.us serves this branch's module
  (the deploy job runs on the merge to trunk; no lupin release is needed).
