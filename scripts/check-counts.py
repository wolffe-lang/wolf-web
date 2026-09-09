#!/usr/bin/env python3
"""No count in the site's prose may sit on the page held by nothing.

    usage: check-counts.py <site-dir> <wolf-lang-dir> <wolf-interp-dir> <wolf-book-dir>

The rule is the version rule, applied to populations instead of releases, and
it has the same two halves:

  1. A count that a machine can MEASURE is never a word on the page. It is a
     `__COUNT_<source>_<spelling>__` placeholder and scripts/stamp-counts.py
     fills it in at build from the pinned checkout or the sample index. Those
     numbers cannot fossilize, so this file never sees them: on `site/`, where
     it runs, they are still placeholders.

  2. Every other number word is a LITERAL, and every literal is enumerated in
     scripts/count-allowlist.txt with the file it lives in, how many times it
     appears there, how many of those occurrences are LIVE, and — when any
     are — the pin they were last read against. A word this list does not
     carry, a total that drifts, or a pin that has moved past the audit all
     fail the build.

`counted=<n>` is the same idea as `bound=<n>` in stamp-allowlist.txt: how many
of a file's occurrences state a number that a pin bump can still move. The
rest are frozen — a historical measurement ("the page said twelve from ww16"),
a property of the language ("the low eight bits"), a quantity that measures no
population at all ("twenty years", "six minutes apart") — and they stay true
whatever the pins do, so they carry no clock. When `counted` is more than zero
the entry carries an `audited-at`, and the bump moves past it exactly the way
it does for a version literal: re-read the sentence against what it counts,
then re-stamp.

Three projects can move a number here, so there are three clocks and every
entry names the one that audits it:

    audited-at-wolf=0.2.8      the compiler's releases and its corpus
    audited-at-lupin=0.1.28    what the interpreter in the tab answers
    audited-at-book=f0e2dd1    the book, which has no releases, so its pin

Why the vocabulary starts at five
---------------------------------

The words this file looks for are five and up, plus the tens and their
hyphenated forms and `-odd`. One through four are ordinary English on this
site — "one release behind", "the two implementations", "a release or two",
"the four calls" — and enumerating every occurrence of "one" would produce a
file nobody reads and a re-read nobody does. It is the same trade the version
regex makes when it requires three components for a bare literal, so that
"0.5 seconds" is not a release claim: a boundary that admits a little silence
in exchange for a list that stays legible. wolf-web#17's defect lived well
above the line — twelve, thirteen, sixteen, thirty-four, thirty-six.
"""

import re
import sys
from pathlib import Path

SITE = Path(sys.argv[1] if len(sys.argv) > 1 else "site")
LANG = Path(sys.argv[2] if len(sys.argv) > 2 else "upstream/wolf-lang")
INTERP = Path(sys.argv[3] if len(sys.argv) > 3 else "upstream/wolf-interp")
BOOK = Path(sys.argv[4] if len(sys.argv) > 4 else "upstream/wolf-book")

# The same readings check-version-prose.py takes, from content rather than tag
# objects, plus the book's — which publishes no version, so its pin is the
# revision this repository records for it.
head = re.search(r"^## (\d[\d.]*)\s", (LANG / "CHANGELOG.md").read_text(), re.M)
if not head:
    sys.exit("check-counts: no release heading in the pinned wolf-lang CHANGELOG.md")
crate = re.search(r'^version\s*=\s*"([^"]+)"', (INTERP / "Cargo.toml").read_text(), re.M)
if not crate:
    sys.exit("check-counts: no version in the pinned wolf-interp Cargo.toml")

book_pin = ""
try:
    import subprocess

    book_pin = subprocess.run(
        ["git", "-C", str(BOOK), "rev-parse", "--short=7", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
except Exception as cause:  # a tarball checkout, or no git
    sys.exit(f"check-counts: cannot read the pinned book revision: {cause}")

pins = {"wolf": head.group(1), "lupin": crate.group(1), "book": book_pin}

ONES = (
    "five six seven eight nine ten eleven twelve thirteen fourteen fifteen "
    "sixteen seventeen eighteen nineteen"
).split()
ALL_ONES = "one two three four".split() + ONES
TENS = "twenty thirty forty fifty sixty seventy eighty ninety".split()
WORD = re.compile(
    r"\b(?:(?:%s)(?:-(?:%s|odd))?|%s|hundred)\b"
    % ("|".join(TENS), "|".join(ALL_ONES), "|".join(ONES)),
    re.I,
)

found: dict[tuple[str, str], int] = {}
for page in sorted(SITE.rglob("*.html")):
    rel = page.relative_to(SITE).as_posix()
    for m in WORD.finditer(page.read_text()):
        key = (rel, m.group(0))
        found[key] = found.get(key, 0) + 1

ENTRY = re.compile(
    r"^(\S+)\s+(\S+)\s+(\d+)\s+counted=(\d+)(?:\s+audited-at-(wolf|lupin|book)=(\S+))?$"
)

allowed: dict[tuple[str, str], tuple[int, int, str, str]] = {}
allowfile = Path(__file__).parent / "count-allowlist.txt"
for n, line in enumerate(allowfile.read_text().splitlines(), 1):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    entry = ENTRY.match(line)
    if not entry:
        sys.exit(
            f"check-counts: {allowfile.name}:{n}: cannot parse {line!r} — an entry is "
            f"<path> <word> <total> counted=<n> [audited-at-wolf=<version>]"
        )
    path, wordform, total, counted, project, audited = entry.groups()
    if int(counted) > int(total):
        sys.exit(f"check-counts: {allowfile.name}:{n}: counted={counted} of only {total}")
    if int(counted) and not project:
        sys.exit(
            f"check-counts: {allowfile.name}:{n}: {path} has {counted} live "
            f"{wordform!r} — a live count needs an audited-at-<project>="
        )
    if not int(counted) and project:
        sys.exit(
            f"check-counts: {allowfile.name}:{n}: {path} {wordform!r} is counted=0, "
            f"which is a number no pin can move — it carries no clock"
        )
    allowed[(path, wordform)] = (int(total), int(counted), project or "", audited or "")

problems: list[str] = []
for (path, wordform), total in sorted(found.items()):
    if (path, wordform) not in allowed:
        problems.append(
            f"{path}: {wordform!r} ×{total} is not in {allowfile.name} — a measurable "
            f"count belongs in a __COUNT_<source>_<spelling>__ stamp; anything else "
            f"gets a listed entry saying how many occurrences a pin can still move"
        )
        continue
    want, counted, project, audited = allowed[(path, wordform)]
    if total != want:
        problems.append(f"{path}: {wordform!r} appears ×{total}, the allowlist says ×{want}")
    if counted and audited != pins[project]:
        problems.append(
            f"{path}: {counted} live {wordform!r} count(s) were read at {project} "
            f"{audited}, the {project} pin is now {pins[project]} — re-read them "
            f"against what they count, then re-stamp its audited-at-{project}"
        )
for (path, wordform) in sorted(set(allowed) - set(found)):
    problems.append(f"{allowfile.name} lists {wordform!r} in {path}, which no longer carries it")

if problems:
    for p in problems:
        print(f"counts: {p}", file=sys.stderr)
    sys.exit(1)

live = sum(c for _, c, _, _ in allowed.values())
print(
    f"counts: {sum(found.values())} number word(s) in {len(allowed)} entries, "
    f"{live} of them live and re-read at this bump (wolf {pins['wolf']}, "
    f"lupin {pins['lupin']}, book {pins['book']})"
)
