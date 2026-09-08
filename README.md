# wolf-web

The site at [lupp.us](https://lupp.us): the book, a live interpreter,
the docs.

Everything the site serves is generated from pinned submodules, so a
page cannot claim a version of wolf that does not exist. The
interpreter in the playground is `lupin`, the reference interpreter,
compiled to WebAssembly and run in the visitor's browser.

## Layout

    site/          the static source: pages, styles, the playground shell
    crates/        lupin-wasm, the playground's bridge to the interpreter
    scripts/       build and deploy
    nginx/         the two configs, bootstrap and final
    upstream/      pinned submodules (book, interpreter, compiler)
    dist/          build output, not tracked

## Build and deploy

    git submodule update --init --recursive
    ./scripts/build.sh          # writes dist/
    ./scripts/deploy.sh         # builds, stages a release, flips current

`deploy.sh` needs sudo for the parts under `/var/www` and for the nginx
reload, and asks for it.

The book ships twice from the one pinned checkout: the web edition
under `dist/book/`, and the typst-set `dist/book/wolf-book.pdf` that
the reading page offers for download with its measured size. The PDF
needs `typst` on the machine (on `PATH`, at `$TYPST`, or in
`~/.cargo/bin`); CI installs a pinned release binary. Without it the
build stops (`ALLOW_NO_PDF=1` lets it continue), and the reading page
then omits the download link.

Each step of `build.sh` degrades instead of aborting: a book that will
not render leaves a page saying so, a wasm build that fails leaves a
playground that says so, and the deploy still goes out. The exit code
reports whether the build ran, and the pages report what it produced.

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

Move a submodule to the revision you want and commit the pin:

    git -C upstream/wolf-book fetch origin && git -C upstream/wolf-book checkout <sha>
    git add upstream/wolf-book && git commit -m "pins: book <sha>"
    ./scripts/deploy.sh

## First-time nginx setup

See `nginx/lupp.us.bootstrap.conf` for the command sequence. In short:
install the bootstrap config, run certbot, install the real config.
