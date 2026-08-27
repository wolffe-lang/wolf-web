# wolf-web

The site at [lupp.us](https://lupp.us): the book, a live interpreter, the
docs.

Everything the site serves is generated from pinned submodules, so a page
cannot claim a version of wolf that does not exist. The interpreter in the
playground is not a reimplementation — it is `lupin`, the reference
interpreter, compiled to WebAssembly and run in the visitor's browser.

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
reload; it will ask.

The book ships twice from the one pinned checkout: the web edition under
`dist/book/`, and the typst-set `dist/book/wolf-book.pdf` that the reading
page offers for download with its measured size. The PDF needs `typst` on
the box (PATH, `$TYPST`, or `~/.cargo/bin`); CI installs a pinned release
binary. Without it the build refuses (`ALLOW_NO_PDF=1` waives) and the
reading page drops the download link rather than leaving it to 404.

Every step of `build.sh` degrades rather than aborting: a book that will not
render leaves a page saying so, a wasm build that fails leaves a playground
that says so, and the deploy still happens. The exit code is about the build,
never about the completeness of what it built.

## The playground

`scripts/build-wasm.sh` compiles the pinned interpreter for
`wasm32-unknown-unknown` and publishes one file, `dist/play/lupin.wasm`. The
module imports nothing; the script checks that and refuses to publish one that
does. `site/play/lupin.js` is hand-written glue over a byte-buffer ABI
documented in `crates/lupin-wasm/src/lib.rs`. There is no wasm-bindgen and no
npm, so the toolchain is cargo alone and the nginx CSP needs nothing beyond
`'self' 'wasm-unsafe-eval'`.

The build needs the wasm target. On a rustup box the script adds it. On a
distro rust without rustup, install the distribution's wasm std, or point
`WOLF_WASM_SYSROOT` at a sysroot that has one.

### One piece of debt

The pinned interpreter does not compile to wasm as it stands: the parser and
the evaluator each run on a thread they size themselves, and the machine reads
a monotonic clock at startup. None of the three exists on
`wasm32-unknown-unknown`, and each aborts the module rather than failing.
`crates/lupin-wasm/wasm-portability.patch` gates them on the target and
declines, by name, the two tiers that need a thread and the one that needs a
clock. `build-wasm.sh` applies it to a staged copy under `target/`; the
submodule is never touched.

That patch belongs upstream in wolf-interp. Once it lands and the pin moves
past it, `build-wasm.sh` reports that the pin already carries the gates and
skips the file, which is the signal to delete it. If the pin moves and the
patch stops applying, the script fails loudly rather than guessing.

## The samples

`scripts/collect-samples.py` copies conformance-corpus programs into
`dist/play/samples/`, verbatim, header comment and all. The running order is a
list in that script; the bytes are the corpus's. Programs whose tiers the
browser build declines are left out, and the reasons are in the script's
docstring.

## Updating what the site serves

Move a submodule to the revision you want and commit the pin:

    git -C upstream/wolf-book fetch origin && git -C upstream/wolf-book checkout <sha>
    git add upstream/wolf-book && git commit -m "pins: book <sha>"
    ./scripts/deploy.sh

## First-time nginx setup

See `nginx/lupp.us.bootstrap.conf` for the command sequence. Short version:
install the bootstrap config, run certbot, install the real config.
