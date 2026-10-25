# wolf-web

The site at [lupp.us](https://lupp.us): the book, a live interpreter,
the docs and the standard-library reference.

Everything the site serves is generated from pinned submodules, so a
page cannot claim a version of wolf that does not exist. The
interpreter in the playground is `lupin`, the reference interpreter,
compiled to WebAssembly and run in the visitor's browser.

## Layout

    site/          the static source: pages, styles, the playground shell
    crates/        lupin-wasm, the playground's bridge to the interpreter
    scripts/       build and deploy
    nginx/         the two configs, bootstrap and final
    upstream/      pinned submodules (book, interpreter, compiler, standard library)
    dist/          build output, not tracked

## Build and deploy

    git submodule update --init --recursive
    ./scripts/build.sh          # writes dist/

CI builds and tests pull requests. A push to `trunk` deploys automatically
through the existing nginx host on almanta. Do not deploy a lane by hand.
`scripts/ci-deploy.sh` and `scripts/deploy.sh` implement that deployment.

The book ships twice from the one pinned checkout: the web edition
under `dist/book/`, and the typst-set `dist/book/wolf-book.pdf` that
the reading page offers for download with its measured size. The PDF
needs `typst` on the machine (on `PATH`, at `$TYPST`, or in
`~/.cargo/bin`); CI installs a pinned release binary. Without it the
build stops (`ALLOW_NO_PDF=1` lets it continue), and the reading page
then omits the download link.

Missing book, PDF, wasm or sample output fails the build unless the
corresponding explicit `ALLOW_NO_*` waiver is set. A waived build records
its missing outputs in `version.json`; it is not a complete release.

## Standard-library reference

`upstream/wolf-std` is pinned alongside the compiler. Its own `upstream`
gitlink must match `upstream/wolf-lang`; generation refuses a mismatched
pair. Move these pins together at a site version bump, or on request,
never by following a moving branch during the build.

`scripts/std-reference.py` reads every public declaration and its doc
comments, including member files, inherent methods and nested modules.
It writes `dist/std/reference.json` with signatures, tiers, source paths
and line numbers. It does not compile the library: the displayed toolchain
verification is the paired pin, and each module documents its execution
posture. The pinned `wolf doc --json` omits inherent methods and unimported
nested modules, and does not provide source positions (wolf-lang#968 tracks
the installed-toolchain std documentation door).

`scripts/render-std.py` consumes that JSON to build `/std/`,
`/std/<module>/`, `/std/index.txt` and `/std/<module>.txt`. Nested module
names use dots, such as `/std/net.unix/` and `/std/x.tls.client.txt`.
Namespace pages link their children. The text edition has a module header
and a qualified name, source signature and first doc sentence per item.
Generated output is never committed.

The contents script and stylesheet are same-origin external files with
content-hashed query strings. On a narrow screen the contents panel closes
with Escape and restores focus; without JavaScript it remains an inline
list. No frontend dependency or CSP relaxation is required.

Reference checks can run without building the book or wasm:

    python3 -m unittest discover -s tests -p '*_test.py' -v
    mkdir -p dist && cp -R site/. dist/
    python3 scripts/std-reference.py
    python3 scripts/render-std.py dist/std/reference.json dist/std
    python3 scripts/check-std.py
    python3 scripts/std-reference.py --check
    python3 scripts/render-std.py dist/std/reference.json dist/std --check
    CHROMIUM=chromium node scripts/check-std-browser.mjs

The browser gate uses an installed Chromium executable, a temporary profile,
and the exact response headers read from `nginx/lupp.us.conf`; it does not
start or alter nginx. It clicks through module pages on phone and desktop
widths and checks the no-script HTTP edition. The complete build also runs
`scripts/check-links.py dist` over the book and site together.

## The playground

`scripts/build-wasm.sh` compiles the pinned interpreter for
`wasm32-unknown-unknown` and publishes one file, `dist/play/lupin.wasm`.
The module imports nothing; the script checks that and refuses to
publish one that does. `site/play/lupin.js` is hand-written glue over a
byte-buffer ABI documented in `crates/lupin-wasm/src/lib.rs`. There is
no wasm-bindgen and no npm, so the toolchain is cargo alone and the
nginx CSP needs only `'self' 'wasm-unsafe-eval'`.

The build needs the wasm target. On a rustup machine the script adds
it. On a distro rust without rustup, install the distribution's wasm
std, or point `WOLF_WASM_SYSROOT` at a sysroot that has one.

### The portability patch

The site once carried `crates/lupin-wasm/wasm-portability.patch`. The
pinned interpreter ran the parser and the evaluator on threads it sized
itself and read a monotonic clock at startup, none of which exists on
`wasm32-unknown-unknown`, and the patch gated all three on the target.
Upstream took the gates in wolf-interp c1ec02e and the patch was
deleted; the interpreter has owned its wasm behaviour since. At the
current pin that covers the interpreter's larger surface too: the net
tier and the process functions decline on wasm the same way tasks,
procs and the time functions do, so the build applies nothing and the
module still imports nothing. `build-wasm.sh` keeps the
staging-and-patch machinery. If a future pin regresses, a patch dropped
into `crates/lupin-wasm/` is picked up again, and one that does not
apply fails the build.

## The samples

`scripts/collect-samples.py` copies conformance-corpus programs into
`dist/play/samples/` verbatim, header comment included. The running
order is a list in that script; the bytes are the corpus's. Programs
whose tiers the browser build declines are left out, and the reasons
are in the script's docstring.

## Updating what the site serves

Move a submodule to an explicit revision and review the staged pin:

    bash scripts/pin.sh wolf-book <sha>
    bash scripts/pin.sh wolf-lang <sha>
    bash scripts/pin.sh wolf-std <sha>
    bash scripts/pin.sh wolf-interp <sha>
    ./scripts/build.sh

Commit the reviewed pins and prose updates in a pull request. The compiler
and library pins must agree before building. CI deploys after merge.

## First-time nginx setup

See `nginx/lupp.us.bootstrap.conf` for the command sequence. In short:
install the bootstrap config, run certbot, install the real config.
