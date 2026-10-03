#!/usr/bin/env python3
"""Version every script and stylesheet the book's pages load, by the book's pin.

    usage: version-book-assets.py <dist/book> <pin>

mdBook names its scripts and styles the same at every render — `toc.js`,
`book.js`, `css/chrome.css` — and lupp.us served them with a 7-day cache. So
when the book moved, a returning reader's browser kept the old `toc.js`, which
IS the sidebar, for up to a week (wolf-book PR #65, bs55's note for ww35). A
header sent by the next deploy cannot reach a copy the browser will not ask
about again; only a new URL can. This rewrites every same-origin `.js` and
`.css` reference in the book's HTML to carry `?v=<pin>`, the book's seven-hex
pin, so a page from a new book asks for new files, and a page from the same
book asks for the ones already cached.

nginx serves the file and ignores the query, so nothing on disk moves, and the
CSP (`script-src 'self'`) is indifferent to it. What this cannot reach is a
script the book loads by name at run time (`searchindex.js`); the nginx config
makes the whole book revalidate for that (`Cache-Control: no-cache`).

NO FILE IS LEFT BARE. Through ww35 one was: `wolf-boot.js`, the script bs55
moved the theme's inline code into, which learns the book's root by reading
its OWN `src` attribute and cutting `wolf-boot.js` off the end — so
`wolf-boot.js?v=…` left it with no root at all and every sidebar link from
`front/` and `back/` landed a folder too deep (585 404s on chromium phone in
ww35's first staged gate). bs56 made it cut a query or fragment off its src
before comparing the name (wolf-book `2dec44a`, #66), and from ww36 the book
is pinned past that, so it is versioned like everything else.

It refuses two outcomes rather than report them: rewriting nothing (a zero is
believed only when the search is shown to fire), and a bare local `.js` or
`.css` reference left anywhere after the pass.
"""

import re
import sys
from pathlib import Path

# src="…" or href="…" whose value is a local path ending in .js or .css: no
# scheme, not protocol-relative, no query or fragment already.
REF = re.compile(r'\b(src|href)="((?!//)[^":?#]*\.(?:js|css))"')

# Files left unversioned. Empty since ww36 (see above); kept so an exemption
# is one named line, never a regex edit.
BARE: tuple = ()


def keep(path: str) -> bool:
    return path.rsplit("/", 1)[-1] in BARE


def version(html: str, pin: str) -> tuple[str, int]:
    return REF.subn(
        lambda m: m.group(0) if keep(m.group(2)) else f'{m.group(1)}="{m.group(2)}?v={pin}"', html
    )


def bare(html: str) -> bool:
    return any(not keep(m.group(2)) for m in REF.finditer(html))


def main(argv: list) -> int:
    if len(argv) != 2:
        print(__doc__.strip().splitlines()[2].strip(), file=sys.stderr)
        return 2
    book, pin = Path(argv[0]), argv[1]
    if not re.fullmatch(r"[0-9a-f]{7}", pin):
        print(f"book assets: the pin must be seven hex characters, got '{pin}'", file=sys.stderr)
        return 2
    pages = sorted(book.rglob("*.html"))
    total = 0
    touched = 0
    for page in pages:
        text = page.read_text(encoding="utf-8")
        new, _ = version(text, pin)
        n = sum(1 for m in REF.finditer(text) if not keep(m.group(2)))
        if n:
            page.write_text(new, encoding="utf-8")
            total += n
            touched += 1
    if total == 0:
        print(f"book assets: no script or stylesheet reference found in {len(pages)} page(s) under {book} — refusing a zero", file=sys.stderr)
        return 1
    left = [str(p.relative_to(book)) for p in pages if bare(p.read_text(encoding="utf-8"))]
    if left:
        print(f"book assets: bare references remain in {', '.join(left)}", file=sys.stderr)
        return 1
    print(
        f"  book assets: {total} script and stylesheet reference(s) across {touched} of {len(pages)} page(s) "
        f"versioned ?v={pin}"
        + (f"; {', '.join(BARE)} left bare" if BARE else "; nothing exempt")
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
