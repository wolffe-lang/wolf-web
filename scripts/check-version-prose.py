#!/usr/bin/env python3
"""No version claim in the site's prose may drift from the pins.

The rule has two halves:

  1. A claim about the CURRENT version never appears as a literal. It is
     written as __WOLF_VERSION__ (or __LUPIN_VERSION__) and build.sh
     stamps it from the pinned checkouts, the way __PDF_SIZE__ already
     works. Those claims cannot fossilize.

  2. A HISTORICAL mention ("declared at v0.1.0") is a literal, and every
     literal must be enumerated in scripts/version-allowlist.txt with
     the file it lives in, how many times it appears there, and the
     pinned wolf version it was last audited against. A mention this
     list does not carry, a count that drifts, or a pin that has moved
     past the audit all fail the build — so a version bump forces the
     historical prose to be re-read, entry by entry, instead of rotting.

Usage: check-version-prose.py <site-dir> <pinned-wolf-lang-dir>
"""
import re
import sys
from pathlib import Path

SITE = Path(sys.argv[1] if len(sys.argv) > 1 else "site")
LANG = Path(sys.argv[2] if len(sys.argv) > 2 else "upstream/wolf-lang")

# The pin's own word for what is released: the first entry heading of the
# pinned CHANGELOG. Deterministic from content — no tag objects needed.
head = re.search(r"^## (\d[\d.]*)\s", (LANG / "CHANGELOG.md").read_text(), re.M)
if not head:
    sys.exit("check-version-prose: no release heading in the pinned wolf-lang CHANGELOG.md")
pin = head.group(1)

LITERAL = re.compile(r"\bv\d+\.\d+(?:\.\d+)?\b|\b[Vv]ersion \d+\.\d+(?:\.\d+)?\b")

found: dict[tuple[str, str], int] = {}
for page in sorted(SITE.rglob("*.html")):
    rel = page.relative_to(SITE).as_posix()
    for m in LITERAL.finditer(page.read_text()):
        key = (rel, m.group(0))
        found[key] = found.get(key, 0) + 1

allowed: dict[tuple[str, str], tuple[int, str]] = {}
allowfile = Path(__file__).parent / "version-allowlist.txt"
for n, line in enumerate(allowfile.read_text().splitlines(), 1):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    try:
        path, literal, count, audited = line.split()
        assert audited.startswith("audited-at=")
        allowed[(path, literal)] = (int(count), audited.removeprefix("audited-at="))
    except (ValueError, AssertionError):
        sys.exit(f"check-version-prose: {allowfile.name}:{n}: cannot parse {line!r}")

problems: list[str] = []
for (path, literal), count in sorted(found.items()):
    if (path, literal) not in allowed:
        problems.append(
            f"{path}: {literal!r} ×{count} is not in {allowfile.name} — a current-version "
            f"claim belongs in a __WOLF_VERSION__ stamp; a historical mention gets a listed entry"
        )
        continue
    want, audited = allowed[(path, literal)]
    if count != want:
        problems.append(f"{path}: {literal!r} appears ×{count}, the allowlist says ×{want}")
    if audited != pin:
        problems.append(
            f"{path}: {literal!r} was audited at wolf {audited}, the pin is now {pin} — "
            f"re-read the sentence, then re-stamp its audited-at"
        )
for (path, literal) in sorted(set(allowed) - set(found)):
    problems.append(f"{allowfile.name} lists {literal!r} in {path}, which no longer carries it")

if problems:
    for p in problems:
        print(f"version prose: {p}", file=sys.stderr)
    sys.exit(1)

print(f"version prose: {sum(found.values())} literal mention(s) audited against wolf {pin}, "
      f"{len(allowed)} allowlisted")
