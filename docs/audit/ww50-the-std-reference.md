## Prediction

Committed before implementation in `notes/ww50-prediction.txt` (b4421ed). Expected `wolf doc --json` to omit part of the surface and fs to be the largest page at 120–180 KiB. Measured: its tree invocation exits 0 but exposes 36 modules/614 items, omitting public inherent methods and unimported nested modules; it provides no source positions. The source extractor includes 58 module/namespace pages and 852 public declarations. fs is largest at 147,843 bytes (144.38 KiB), uncompressed. The initial top-level census missed cmp's eight public methods; the final count is 15. Other direct-module predictions hold.

This PR body carries the required five-section lane note: the wrapper prohibits writing report/notes `.md` files, so `notes/ww50-the-std-reference.md` is not created.

## Forbidden

No manual deploy, merge, release, PR label, new frontend dependency, CDN, inline script/style, or changes to almanta, DNS, tunnels, the planning repository or `~/.claude`. No system compiler used. Builds/tests ran only on kasumi CPUs 12–15 under `/home/mfwolffe/lanes/kasumi-cores-12-15.lock`.

## Inputs verified

- wolf-std `5f49efd84140167c594c4107061769bf26841f84`, read twice; its compiler gitlink matches the site's `cf0c13d38479f444b69bb8356ad5709d07eff323` (wolf 0.2.35). R-ww50-4 is pin pairing, not a fixed release number.
- The pinned compiler release archive, x86_64 Linux, SHA-256 `4cc4045bbbb605c07835bc4f32685953c784eeef4cd3139a48b457dfc90dad1a`, release digest and local bytes read twice. Used only to probe `wolf doc --json --std-root upstream/wolf-std/std`; the build needs no compiler executable for source extraction.
- The banner verifies paired toolchain pins, not universal execution support. Module docs state lane-specific support; the browser playground has no std filesystem.
- API-CONVENTIONS, representative module docs, site build/style/nav, ww35 CSP history, book contents pattern and existing tests. The existing nginx tests inspect configuration; the new browser server reads its exact security headers and exercises Chromium without modifying nginx.
- R-ww50-1..3: `/std/`, public declarations only, pins move at site bumps or on request. Nested names use dots; namespace pages include `mem`, `x`, `x.crypto`, `x.tls`.
- Own bounded lexical extractor: signatures, module/item prose, stability tier and source lines. Unknown public forms, duplicate names and mismatched toolchain pins fail closed. Extend wolf-lang#968's existing documentation request with inherent-method/nested-module/source-location coverage; do not file a duplicate installed-toolchain std-doc issue.

## Evidence index

- b4421ed: prediction before code.
- d374cdf: pinned standard library.
- ccc0b9c: source extractor, explicit pin helper and parser controls.
- 295faae: generated HTML/text/JSON and progressive contents.
- e71c68b: site navigation and docs entry point.
- eb4765d: completeness, drift, anchor and browser gates.
- 4523b6f: README refresh, including accurate automatic deployment.
- cc0f3d0: changelog and deploy dependency on std gates.
- a34b617: exact signatures, actual changed-pin control, shallow-clone independence.
- 5b9aab1: row vocabulary and literal-preserving signatures.

Final code head: `5b9aab18d35616b8a0314bb3c8e635bf5dc34dcf`.

Kasumi evidence, all under `/home/mfwolffe/lanes/ww50/wolf-web/`:
- `.ww50-build.log`, `.ww50-build.status`: final-head full build exit 0; 132 Node tests and 11 Python tests pass, no skips. Build 17:54:37–17:55:07 -04:00 on 2026-10-25; build PID 1388524.
- `.ww50-final-checks.log`: final head printed; extractor and render `--check` green; 36 playground menu entries and 18 net refusals agree; ahead gate green; five required wasm target tests green, no skips.
- Full-site checker: 2,582 internal links across 123 HTML pages, zero dead. Reference: 58 pages, 852 items exactly once in HTML and each text edition, signatures held independently.
- Browser gate: 390px and 1440px, two hops plus nested nursery, external ToC running under production CSP, Escape/focus return, inert closed panel, anchors/current-item highlight, no horizontal overflow, text MIME; JS-off fetch retains inline contents. It uses installed Chromium, not a new package or framework.
- `doc-probe.log`, `doc-probe.status`: pinned wolf doc invocation and its exit 0.

Plant: draft #72, left open. Final plant head `4fb6d049621a7e36326a8c1c5003b1c86750e204`; run **40237624353**, failed solely at `test_std_public_items_and_js_off_contents` in **std extractor and drift controls**, naming `std-public-items: std.base64` and the omitted `encode`. Focused std job only. The previous run 40237462998 also exposed a shallow-clone-dependent negative control; that control is fixed on both branches.

Counts per module:
```text
base64 5; bytes 10; cmp 15; deque 0; env 19; errors 7
fmt 18; fmt.decimal 4; fs 83; hex 5; io 8; iter 6; json 27
list 36; map 13; math 18; math.float 39; mem 0; mem.budget 3
net 27; net.unix 2; ops 7; option 4; os 3; os.users 11; pool 2
prelude 3; process 56; rand 8; range 5; search 11; set 0
signal 50; sort 11; str 40; strbuf 10; term 17; testing 12; time 33; unicode 10
x 0; x.crypto 0; x.crypto.chacha20 7; x.crypto.curve25519 7
x.crypto.p256 8; x.crypto.sha2 28; x.deque_int 12; x.jose 10
x.json 23; x.list_eq 6; x.option_expect 1; x.option_flatten 1; x.testing_text 1
x.tls 0; x.tls.cert 14; x.tls.client 22; x.tls.handshake 55; x.tls.record 19
```
Whole text edition: 148,839 bytes. Generated output is not committed. After testing, pruned remote dist/, target/, upstream/wolf-book/target/, .ww50-toolchain/, .ww50-bin/, both downloaded compiler archives and ww50.bundle; retained logs and .ww50-reference.json for review.

## Done-when

- [x] Pin/extractor with source provenance and `--check`.
- [x] Module/index pages, named sections, row tags, progressive offcanvas contents, nav and version banner.
- [x] Whole/per-module machine editions.
- [x] Unit, integration, browser, JS-off, drift and missing-item plant evidence.
- [x] README and CHANGELOG refreshed; note carried here under the wrapper restriction.
- [x] Final-head local build and supplementary gates green; no deployment performed.
- [ ] Final-head GitHub CI: CI **40237931772** and Windows **40237927242**, both in progress when read once; handed to the orchestrator, not watched by this lane.
- [ ] Orchestrator audit/merge and automatic trunk deployment. The required audit ran once at the final head; last line: `AUDIT FAIL (footprint: cross-cutting)`. Its failures were pending CI and the still-present local worktree; local lane worktrees were subsequently pruned. CI remains the orchestrator's gate.

