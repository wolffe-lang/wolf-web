#!/usr/bin/env python3
"""Stamp the revision the interpreter reads, and refuse one written by hand.

    usage: stamp-revisions.py <dist-dir> <pinned-wolf-lang-dir> <pinned-wolf-interp-dir>

/install/ and /play/ both name the specification revision lupin was built to —
a seven-character sha, three times across the two pages — because a reader
comparing the tab's answer with the compiler's needs to know which text each
one read. That sha moves at every interpreter pin bump, and until ww22 it moved
BY HAND. It is the one fact in the pin-lag paragraph no gate could hold: it is
not a version, so scripts/check-version-prose.py cannot see it, and it is not a
count, so scripts/check-counts.py cannot either. ww21 changed all three by hand
and wrote down that the next hole was this shape.

So it works the way sizes have worked since ww13, versions since ww07 and
counts since ww20: the page writes a placeholder and the build fills it in from
the pins.

    was built to <code>__PIN_specrev_short__</code>, a development revision

The placeholder names a SOURCE and a SPELLING:

    short   2c03ed9    seven characters, which is how the pages write one
    full    2c03ed9…   all forty, for a page that ever needs the whole thing

`specrev` is the same gitlink `speccommits` measures a distance from in
stamp-counts.py: the interpreter records the specification checkout it was
built to as a submodule, and a gitlink cannot be worded differently. The sha is
checked against the compiler this site advertises before it is stamped — a page
may not print a revision the pinned checkout does not carry, for the same
reason it may not claim a version of wolf that does not exist.

The other half is the refusal, and it is what makes the stamp a gate rather
than a convenience. A stamped page cannot go stale, but nothing stops the next
editor from typing the sha back in beside it, which is exactly what the site
did for four bumps. So every page this sweep touches is read for a bare git
revision FIRST, before anything is substituted, and one found stops the build —
including the sha that happens to be correct today, because a correct literal
is the one that rots quietly. No page has ever needed a historical revision in
prose; when one does, this refusal is where the counted, audited allowlist goes,
the way scripts/version-allowlist.txt holds historical versions.

The sweep runs on dist/ before the book, the docs and the changelogs are
generated, so it reads the site's own pages and nothing else. The rendered
CHANGELOGs are full of revisions and every one of them is history.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

TOKEN = re.compile(r"__PIN_([A-Za-z][A-Za-z0-9_]*)_(short|full)__")

# A git revision as prose writes one: seven to forty hex characters, standing
# alone. Both lookaheads are there to keep English out of it — a run with no
# digit is a word ("effaced", "deface"), a run with no letter is a number.
LITERAL = re.compile(
    r"(?<![0-9A-Za-z])(?=[0-9a-f]*[0-9])(?=[0-9a-f]*[a-f])[0-9a-f]{7,40}(?![0-9A-Za-z])"
)

SPELL = {
    "short": lambda sha: sha[:7],
    "full": lambda sha: sha,
}


def git(where: Path, *args: str) -> str:
    done = subprocess.run(
        ["git", "-C", str(where), *args], capture_output=True, text=True
    )
    if done.returncode != 0:
        raise ValueError(
            f"git {' '.join(args)} in {where} failed: {done.stderr.strip()}"
        )
    return done.stdout.strip()


def spec_revision(lang: Path, interp: Path) -> str:
    """The specification revision the pinned interpreter was built to, read off
    its gitlink and checked against the compiler this site advertises."""
    link = git(interp, "ls-tree", "HEAD", "upstream")
    pin = re.match(r"^160000 commit ([0-9a-f]{40})", link)
    if not pin:
        raise ValueError(
            f"{interp} records no gitlink for its specification checkout — "
            f"the revision cannot be read"
        )
    sha = pin.group(1)
    try:
        git(lang, "cat-file", "-e", f"{sha}^{{commit}}")
    except ValueError:
        raise ValueError(
            f"{sha[:7]} is not a commit in {lang} — the site would print a "
            f"revision of the compiler it advertises that the compiler does "
            f"not carry"
        ) from None
    return sha


def main() -> int:
    if len(sys.argv) != 4:
        print(__doc__.strip().splitlines()[2].strip(), file=sys.stderr)
        return 2
    dist, lang, interp = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])

    sources = {
        "specrev": (
            "the specification gitlink the pinned interpreter records",
            lambda: spec_revision(lang, interp),
        ),
    }

    problems = []
    measured = {}

    def value(source):
        if source not in measured:
            try:
                measured[source] = sources[source][1]()
            except (OSError, ValueError) as cause:
                problems.append(f"{source} could not be read: {cause}")
                return None
        return measured[source]

    stamped = 0
    pages = 0
    for page in sorted(dist.rglob("*.html")):
        text = page.read_text(encoding="utf-8")

        # The refusal reads the page as written, before any substitution, so
        # a hand-written revision is caught even when it is today's.
        for literal in dict.fromkeys(LITERAL.findall(text)):
            problems.append(
                f"{page.relative_to(dist)}: {literal} is a git revision written "
                f"by hand — write __PIN_specrev_short__ and the build stamps it "
                f"from the pin"
            )

        if not TOKEN.search(text):
            continue
        pages += 1

        def fill(match):
            nonlocal stamped
            source, spelling = match.group(1), match.group(2)
            if source not in sources:
                problems.append(
                    f"{page.relative_to(dist)}: {match.group(0)} names no source — "
                    f"add one to stamp-revisions.py"
                )
                return match.group(0)
            sha = value(source)
            if sha is None:
                return match.group(0)
            stamped += 1
            return SPELL[spelling](sha)

        page.write_text(TOKEN.sub(fill, text), encoding="utf-8")

    if problems:
        for problem in problems:
            print(f"revisions: {problem}", file=sys.stderr)
        return 1

    named = ", ".join(f"{k} {v[:7]}" for k, v in sorted(measured.items()))
    print(f"  revisions: {stamped} stamped across {pages} page(s) — {named}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
