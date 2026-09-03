#!/usr/bin/env python3
"""Stamp file sizes into the site's prose from the checkout it was built from.

    usage: stamp-sizes.py <dist-dir> <pinned-wolf-lang-dir>

The spec and docs pages print how big each document is, so a reader on a
phone knows what a link costs before they follow it. Those numbers were
written by hand, and they are exactly the shape of claim that rots: nothing
about them fails when the pin moves, they just quietly stop being true. Four
of them had drifted by ww13 — spec/10 said 13 KiB for a document that had
grown to 17 when `byte` was declared in it — and re-recording them by hand
every time the pin moves is a chore that will be skipped eventually.

So they work the way version claims have worked since ww07: the page writes
a placeholder and the build fills it in from the pinned checkout. A page
cannot claim a size the file does not have, for the same reason it cannot
claim a version of wolf that does not exist.

The placeholder is `__KIB_<path>__`, where the path is relative to the
pinned wolf-lang checkout:

    <dt><a href="/spec/10-types.md">10. Types</a> (__KIB_spec/10-types.md__ KiB)</dt>

The unit stays in the HTML, so the page reads as prose in the editor. A
placeholder naming a file the checkout does not carry fails the build rather
than stamping a zero — an absent document is a fact worth interrupting for.

Rounding follows what the pages already did by hand: one decimal below
10 KiB, where the difference between 5.8 and 6 is most of the number, and a
whole number at or above it.
"""

import re
import sys
from pathlib import Path

TOKEN = re.compile(r"__KIB_([A-Za-z0-9_][A-Za-z0-9_./-]*)__")


def render(size: int) -> str:
    """A byte count as the pages spell it."""
    kib = size / 1024
    return f"{kib:.1f}" if kib < 10 else f"{round(kib)}"


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__.strip().splitlines()[2].strip(), file=sys.stderr)
        return 2
    dist, lang = Path(sys.argv[1]), Path(sys.argv[2])

    problems: list[str] = []
    stamped = 0
    pages = 0
    for page in sorted(dist.rglob("*.html")):
        text = page.read_text(encoding="utf-8")
        found = TOKEN.findall(text)
        if not found:
            continue
        pages += 1

        def fill(match: re.Match[str]) -> str:
            nonlocal stamped
            rel = match.group(1)
            target = lang / rel
            # The pin is a checkout, not a place to reach out of.
            if ".." in Path(rel).parts or not target.is_file():
                problems.append(
                    f"{page.relative_to(dist)}: __KIB_{rel}__ names "
                    f"{lang}/{rel}, which the pinned checkout does not carry"
                )
                return match.group(0)
            stamped += 1
            return render(target.stat().st_size)

        page.write_text(TOKEN.sub(fill, text), encoding="utf-8")

    if problems:
        for problem in problems:
            print(f"file sizes: {problem}", file=sys.stderr)
        return 1

    print(f"  file sizes: {stamped} stamped from the pin across {pages} page(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
