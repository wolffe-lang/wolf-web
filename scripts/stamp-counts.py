#!/usr/bin/env python3
"""Stamp counted populations into the site's prose, measured at build time.

    usage: stamp-counts.py <dist-dir> <pinned-wolf-lang-dir>
                           <pinned-wolf-interp-dir> <pinned-wolf-book-dir>

The pages count things: how many diagnostic codes the compiler has, how many
programs are on the playground's menu, how many of the corpus's net programs
the browser build declines. Those numbers were written by hand, and they are
the same shape of claim as a file size or a version — nothing fails when the
pin moves, they just quietly stop being true. One of them was: /play/ said
TWELVE net programs from ww16 to ww18 while the corpus carried thirteen and
then sixteen, and no gate anywhere could have noticed (wolf-web#17).

So the derivable ones work the way sizes have worked since ww13 and versions
since ww07: the page writes a placeholder and the build fills it in from the
pinned checkout or from the index the build itself produced.

    <dt><a href="/docs/diagnostics.md">Diagnostics</a> (__COUNT_diagnostics_digits__ codes)</dt>
    <p>All __COUNT_samples_word__ of them, and none carries a note.</p>

A placeholder names a SOURCE and a SPELLING, because the pages spell a number
three different ways and all three have to come off one measurement:

    digits   136           a parenthetical beside a link
    word     thirty-four   prose
    Word     Sixteen       prose at the start of a sentence
    odd      thirty-odd    prose that means "about this many"

`odd` rounds DOWN to the ten, which is what "thirty-odd" claims and what the
front page and /spec/ meant by it when a person wrote it.

The sources are enumerated in SOURCES below, each a function of the pinned
checkout or of the built dist. A placeholder naming a source that is not
there fails the build rather than stamping a zero, exactly as an absent
document does in stamp-sizes.py.

One source is not a file but a distance. /install/ and /play/ both say how far
the interpreter's specification pin is from the commit the compiler was tagged
at, and at ww20 that stopped being a number of releases: lupin 0.1.29 was built
to `e9a17cb`, a development revision of the compiler's trunk with no tag on it.
A distance in commits is exactly the shape of claim this file exists for — a
machine can measure it, and it changes at every bump — so `speccommits` counts
it with git over the two pinned gitlinks. It needs the pinned wolf-lang
checkout to carry history; a depth-1 clone cannot answer, and the build says so
by name rather than stamping a zero.

One source is the BOOK, which /reading/ cites on the book's own pin. Four
numbers stand in that paragraph and exactly one of them has no judgement in
it: the chapter total is `](chNN.md)` entries in the pinned SUMMARY.md and
nothing else (wolf-web#28). At the book bump f0e2dd1 -> 3edba7d all four
reddened and two had moved, the total among them — so it is the one a future
bump can get wrong, and it is the class this file exists for.

The other three stay literals on purpose, and /reading/ says why beside them.
"Thirty-one written through" is a READING: the book publishes no such field,
this site derives it as the total minus the chapters holding a whole page
back, and it decides what holding back means — the book's own README counts
it differently and the colophon differently again. Three readings, one book;
stamping one would publish a number the source does not agree with. Chapter
21's five sections and part 5's six programs are measurable in the same thin
sense and stated inside sentences about which of them are reserved, which is
prose. Grouping them with the reading is the conservative call.

What this file does NOT cover is the editorial count — "seven tiers report
unsupported", "five things a program can reach" — which is a reading of a
population rather than a measurement of one. Those are literals, enumerated
in scripts/count-allowlist.txt with a count and the clock that re-reads them,
and scripts/check-counts.py holds that half.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

TOKEN = re.compile(r"__COUNT_([A-Za-z][A-Za-z0-9_]*)_(digits|word|Word|odd)__")

ONES = (
    "zero one two three four five six seven eight nine ten eleven twelve "
    "thirteen fourteen fifteen sixteen seventeen eighteen nineteen"
).split()
TENS = "_ _ twenty thirty forty fifty sixty seventy eighty ninety".split()


def word(n: int) -> str:
    """A count as the pages spell it in prose. Beyond 99 they use digits."""
    if n < 0 or n > 99:
        raise ValueError(f"no prose spelling for {n}")
    if n < 20:
        return ONES[n]
    tens, ones = divmod(n, 10)
    return TENS[tens] if not ones else f"{TENS[tens]}-{ONES[ones]}"


def odd(n: int) -> str:
    """"thirty-odd": the ten below, which is the claim the word makes."""
    if n < 20 or n > 99:
        raise ValueError(f"no '-odd' spelling for {n}")
    return f"{TENS[n // 10]}-odd"


SPELL = {
    "digits": str,
    "word": word,
    "Word": lambda n: word(n).capitalize(),
    "odd": odd,
}


def spec_commits(lang: Path, interp: Path) -> int:
    """How far the interpreter's specification pin is behind the compiler pin,
    in commits of the compiler's own history.

    Both ends are gitlinks, which cannot be worded differently: the
    interpreter records the specification checkout it was built to as a
    submodule, and this site records the compiler it advertises the same way.
    """
    link = git(interp, "ls-tree", "HEAD", "upstream")
    pin = re.match(r"^160000 commit ([0-9a-f]{40})", link)
    if not pin:
        raise ValueError(
            f"{interp} records no gitlink for its specification checkout — "
            f"the distance cannot be measured"
        )
    return int(git(lang, "rev-list", "--count", f"{pin.group(1)}..HEAD"))


def git(where: Path, *args: str) -> str:
    done = subprocess.run(
        ["git", "-C", str(where), *args], capture_output=True, text=True
    )
    if done.returncode != 0:
        raise ValueError(
            f"git {' '.join(args)} in {where} failed: {done.stderr.strip()} "
            f"(a shallow checkout cannot answer this; fetch its history)"
        )
    return done.stdout.strip()


def headings(path: Path, prefix: str) -> int:
    """`## E0001 — …` headings in a pinned document, which is how both code
    lists declare a code."""
    return len(re.findall(rf"^## {prefix}\d", path.read_text(encoding="utf-8"), re.M))


def main() -> int:
    if len(sys.argv) != 5:
        print(" ".join(l.strip() for l in __doc__.strip().splitlines()[2:4]), file=sys.stderr)
        return 2
    dist, lang, interp, book = (Path(a) for a in sys.argv[1:5])

    # Each source is (what it measures, how). Measured once, before any page is
    # touched, so every placeholder for a source gets the same number and a
    # source that cannot be measured stops the build instead of stamping one.
    sources: dict[str, tuple[str, object]] = {
        "diagnostics": (
            "`## E` headings in the pinned docs/diagnostics.md",
            lambda: headings(lang / "docs/diagnostics.md", "E"),
        ),
        "warnings": (
            "`## W` headings in the pinned docs/warnings.md",
            lambda: headings(lang / "docs/warnings.md", "W"),
        ),
        "netprograms": (
            "`.lu` files in the pinned corpus/net/",
            lambda: len(list((lang / "corpus/net").glob("*.lu"))),
        ),
        "speccommits": (
            "commits between the interpreter's specification gitlink and this "
            "site's compiler gitlink",
            lambda: spec_commits(lang, interp),
        ),
        # The book's chapter entries in its own table of contents. `](chNN.md)`
        # is how SUMMARY.md declares a chapter, and back matter is `back/`, so
        # the pattern counts chapters and nothing else.
        "bookchapters": (
            "`](chNN.md)` entries in the pinned book/SUMMARY.md",
            lambda: len(
                re.findall(
                    r"\]\(ch\d+\.md\)",
                    (book / "book/SUMMARY.md").read_text(encoding="utf-8"),
                )
            ),
        ),
        "samples": (
            "entries in the sample index this build wrote",
            lambda: len(
                json.loads(
                    (dist / "play/samples/index.json").read_text(encoding="utf-8")
                )["samples"]
            ),
        ),
    }

    problems: list[str] = []
    measured: dict[str, int] = {}

    def value(source: str) -> int | None:
        if source not in measured:
            try:
                measured[source] = int(sources[source][1]())
            except (OSError, KeyError, ValueError, json.JSONDecodeError) as cause:
                problems.append(f"{source} could not be measured: {cause}")
                return None
        return measured[source]

    stamped = 0
    pages = 0
    for page in sorted(dist.rglob("*.html")):
        text = page.read_text(encoding="utf-8")
        if not TOKEN.search(text):
            continue
        pages += 1

        def fill(match: re.Match[str]) -> str:
            nonlocal stamped
            source, spelling = match.group(1), match.group(2)
            if source not in sources:
                problems.append(
                    f"{page.relative_to(dist)}: {match.group(0)} names no source — "
                    f"add one to stamp-counts.py or write the number as a listed "
                    f"literal in count-allowlist.txt"
                )
                return match.group(0)
            n = value(source)
            if n is None:
                return match.group(0)
            try:
                out = SPELL[spelling](n)
            except ValueError as cause:
                problems.append(f"{page.relative_to(dist)}: {match.group(0)}: {cause}")
                return match.group(0)
            stamped += 1
            return out

        page.write_text(TOKEN.sub(fill, text), encoding="utf-8")

    if problems:
        for problem in problems:
            print(f"counts: {problem}", file=sys.stderr)
        return 1

    named = ", ".join(f"{k} {v}" for k, v in sorted(measured.items()))
    print(f"  counts: {stamped} stamped across {pages} page(s) — {named}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
