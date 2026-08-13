# wolf-web

The site at [lupp.us](https://lupp.us): the book, a live interpreter, the
docs.

Everything the site serves is generated from pinned submodules, so a page
cannot claim a version of wolf that does not exist. The interpreter in the
playground is not a reimplementation — it is `lupin`, the reference
interpreter, compiled to WebAssembly and run in the visitor's browser.

## Layout

    site/          the static source: pages, styles, the playground shell
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

## Updating what the site serves

Move a submodule to the revision you want and commit the pin:

    git -C upstream/wolf-book fetch origin && git -C upstream/wolf-book checkout <sha>
    git add upstream/wolf-book && git commit -m "pins: book <sha>"
    ./scripts/deploy.sh

## First-time nginx setup

See `nginx/lupp.us.bootstrap.conf` for the command sequence. Short version:
install the bootstrap config, run certbot, install the real config.
