# Changelog

lupp.us has no release tags; an entry here is a merged sprint, in the
shape D65 rules: user-visible changes only, the sprint id named.

## ww07 — 2026-08-31

The prose catches up. Every version claim on the site was re-recorded
against the pins it already served — eleven stale claims, from "this is
version 0.1.0" under a v0.2.0 toolchain to a spec page missing four
normative documents — and a tripwire now keeps the class at zero:
current-version claims are stamped into the pages at build time from the
pinned checkouts, and every literal version mention must be counted and
re-audited on each pin bump or the build refuses. The site also grew
/changelog: each public project's CHANGELOG.md rendered from the pinned
checkout it was built from, with a repo that has none yet getting a page
that says so instead of a broken link.

## ww06 — 2026-08-30

The site catches up: pins move to wolf v0.2.0, lupin v0.1.18 and the
post-bs19 book, so the playground runs six releases' worth of
interpreter (+10.7% wasm) and diagnostics point at line:col instead of
byte offsets. The editor grows manners — auto-indent, wolf-aware bracket
pairing (interpolation braces pair inside strings), goal columns, and
multi-cursor editing with one-step undo — under a CSP gate that proves
no script source was added to get them.

## ww05 — 2026-08-26

The PDF on the page: the reading page offers the typst-set print edition
for download, rendered from the same pinned book source as the web
pages, with its measured size printed beside the link — and the line
removed entirely when a build has no PDF, so the page never advertises a
file the dist does not carry. Trunk work soon after fixed the page the
fix shipped on: a 0600 file had been 403ing live, and the build now
refuses any dist file nginx cannot read.

## ww00-era — 2026-08-13 to 2026-08-22

The site exists. A landing page, the playground (lupin compiled to
WebAssembly, running conformance-corpus samples entirely in the tab),
the spec and diagnostic catalogues copied from a pinned compiler
checkout, and the book rendered from its own pinned repo — everything
served generated from submodule pins, so no page can claim a version of
wolf that does not exist. CI builds on every push, a link checker walks
the dist, deploys go to lupp.us over a restricted key, and a build
missing a piece refuses to ship unless waived by name.
