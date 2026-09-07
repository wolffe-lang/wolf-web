#!/usr/bin/env python3
"""No version claim in the site's prose may drift from the pins.

The rule has three halves:

  1. A claim about the CURRENT version never appears as a literal. It is
     written as __WOLF_VERSION__ (or __LUPIN_VERSION__) and build.sh
     stamps it from the pinned checkouts, the way __PDF_SIZE__ already
     works. Those claims cannot fossilize.

  2. A HISTORICAL mention ("declared at v0.1.0") is a literal, and every
     literal must be enumerated in scripts/version-allowlist.txt with
     the file it lives in, how many times it appears there, and the
     pinned version it was last audited against. A mention this list
     does not carry, a count that drifts, or a pin that has moved past
     the audit all fail the build — so a version bump forces the
     historical prose to be re-read, entry by entry, instead of rotting.

Two projects release on this site, on two clocks, so half two reads TWO
pins and every allowlist entry names which one audits it:

    audited-at-wolf=0.2.5    re-read when the compiler tags
    audited-at-lupin=0.1.26  re-read when the interpreter tags

Keying every entry on the wolf pin — the only clock this file had through
ww14 — meant a lupin-only bump re-read nothing, and lupin moves faster:
0.1.20 → 0.1.26 across three wolf tags, covered by hand at ww11 and again
at ww14. That is wolf-web#8's second half; the first is the literal regex
below, which through ww14 saw only `v`-prefixed forms and so was blind to
`lupin 0.1.22` — the spelling the site uses everywhere else, since
`lupin __LUPIN_VERSION__` stamps without a `v`. Both are closed here.

The widened regex also sees version-shaped numbers that are not wolf or
lupin claims (a toolchain pin, say). Those are what the allowlist is for:
they get an entry, a count, and the clock whose checkout carries them.

  3. A PLACEHOLDER is exempt from half two by construction, and that
     exemption is the third half's whole reason. `__WOLF_VERSION__ is a
     release about writing servers` cannot fossilize — but it is true of
     exactly one release, and when the stamp moves it renders with a new
     number and is simply false, with nothing anywhere to notice. ww15
     found two such sentences; ww16 found four more, three of them
     carrying no placeholder at all ("the release", "a release ago").
     So every placeholder occurrence is enumerated in
     scripts/stamp-allowlist.txt with a total and how many of them are
     RELEASE-BOUND, and a file with a bound one carries an audited-at
     that the pin bump moves past exactly as it does for a literal.

Usage: check-version-prose.py <site-dir> <pinned-wolf-lang-dir> <pinned-wolf-interp-dir>
"""
import re
import sys
from pathlib import Path

SITE = Path(sys.argv[1] if len(sys.argv) > 1 else "site")
LANG = Path(sys.argv[2] if len(sys.argv) > 2 else "upstream/wolf-lang")
INTERP = Path(sys.argv[3] if len(sys.argv) > 3 else "upstream/wolf-interp")

# Each pin's own word for what is released, derived from content rather than
# tag objects so a shallow submodule clone cannot mislead either one. Wolf
# says it in the first heading of its CHANGELOG; lupin says it in the
# `version` of its Cargo.toml, which is what build.sh already stamps from.
head = re.search(r"^## (\d[\d.]*)\s", (LANG / "CHANGELOG.md").read_text(), re.M)
if not head:
    sys.exit("check-version-prose: no release heading in the pinned wolf-lang CHANGELOG.md")
crate = re.search(r'^version\s*=\s*"([^"]+)"', (INTERP / "Cargo.toml").read_text(), re.M)
if not crate:
    sys.exit("check-version-prose: no version in the pinned wolf-interp Cargo.toml")
pins = {"wolf": head.group(1), "lupin": crate.group(1)}

# `v0.2.5`, `version 0.2.5`, and — since wolf-web#8 — a bare `0.1.26`. Three
# components for the bare form: two would make every `0.5 seconds` a version
# claim. The `v`-prefixed alternative is first so that `v0.1.22` matches
# whole rather than leaving a bare tail.
LITERAL = re.compile(
    r"\bv\d+\.\d+(?:\.\d+)?\b|\b[Vv]ersion \d+\.\d+(?:\.\d+)?\b|\b\d+\.\d+\.\d+\b"
)

found: dict[tuple[str, str], int] = {}
for page in sorted(SITE.rglob("*.html")):
    rel = page.relative_to(SITE).as_posix()
    for m in LITERAL.finditer(page.read_text()):
        key = (rel, m.group(0))
        found[key] = found.get(key, 0) + 1

# <path> <literal> <count> audited-at-<project>=<version>. The literal is
# matched loosely because one of its spellings carries a space ("version
# 0.1.0"), which a bare split() would tear in half.
ENTRY = re.compile(r"^(\S+)\s+(.+?)\s+(\d+)\s+audited-at-(wolf|lupin)=(\S+)$")

allowed: dict[tuple[str, str], tuple[int, str, str]] = {}
allowfile = Path(__file__).parent / "version-allowlist.txt"
for n, line in enumerate(allowfile.read_text().splitlines(), 1):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    entry = ENTRY.match(line)
    if not entry:
        sys.exit(
            f"check-version-prose: {allowfile.name}:{n}: cannot parse {line!r} — an entry is "
            f"<path> <literal> <count> audited-at-wolf=<version> (or audited-at-lupin=)"
        )
    path, literal, count, project, audited = entry.groups()
    allowed[(path, literal)] = (int(count), project, audited)

problems: list[str] = []
for (path, literal), count in sorted(found.items()):
    if (path, literal) not in allowed:
        problems.append(
            f"{path}: {literal!r} ×{count} is not in {allowfile.name} — a current-version "
            f"claim belongs in a __WOLF_VERSION__ stamp; a historical mention gets a listed entry"
        )
        continue
    want, project, audited = allowed[(path, literal)]
    if count != want:
        problems.append(f"{path}: {literal!r} appears ×{count}, the allowlist says ×{want}")
    if audited != pins[project]:
        problems.append(
            f"{path}: {literal!r} was audited at {project} {audited}, the {project} pin is now "
            f"{pins[project]} — re-read the sentence, then re-stamp its audited-at-{project}"
        )
for (path, literal) in sorted(set(allowed) - set(found)):
    problems.append(f"{allowfile.name} lists {literal!r} in {path}, which no longer carries it")

# Half three: the placeholders. Their clock is their own name, so a
# __LUPIN_VERSION__ sentence is re-read when the interpreter tags even when
# every literal beside it rides the wolf clock — which is the pin-lag
# paragraph on /install/ and /play/, exactly.
PLACEHOLDER = {"__WOLF_VERSION__": "wolf", "__LUPIN_VERSION__": "lupin"}
STAMP = re.compile(
    r"^(\S+)\s+(__(?:WOLF|LUPIN)_VERSION__)\s+(\d+)\s+bound=(\d+)"
    r"(?:\s+audited-at-(wolf|lupin)=(\S+))?$"
)

stamps: dict[tuple[str, str], int] = {}
for page in sorted(SITE.rglob("*.html")):
    rel = page.relative_to(SITE).as_posix()
    text = page.read_text()
    for token in PLACEHOLDER:
        n = text.count(token)
        if n:
            stamps[(rel, token)] = n

declared: dict[tuple[str, str], tuple[int, int, str, str]] = {}
stampfile = Path(__file__).parent / "stamp-allowlist.txt"
for n, line in enumerate(stampfile.read_text().splitlines(), 1):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    entry = STAMP.match(line)
    if not entry:
        sys.exit(
            f"check-version-prose: {stampfile.name}:{n}: cannot parse {line!r} — an entry is "
            f"<path> <placeholder> <total> bound=<n> [audited-at-<project>=<version>]"
        )
    path, token, total, bound, project, audited = entry.groups()
    if int(bound) > int(total):
        sys.exit(f"check-version-prose: {stampfile.name}:{n}: bound={bound} of only {total}")
    if int(bound) and not project:
        sys.exit(
            f"check-version-prose: {stampfile.name}:{n}: {path} has {bound} release-bound "
            f"{token} — a bound stamp needs an audited-at-{PLACEHOLDER[token]}="
        )
    if project and project != PLACEHOLDER[token]:
        sys.exit(
            f"check-version-prose: {stampfile.name}:{n}: {token} is stamped from the "
            f"{PLACEHOLDER[token]} pin, so it is audited-at-{PLACEHOLDER[token]}=, not {project}"
        )
    declared[(path, token)] = (int(total), int(bound), project or "", audited or "")

for (path, token), count in sorted(stamps.items()):
    if (path, token) not in declared:
        problems.append(
            f"{path}: {token} ×{count} is not in {stampfile.name} — say how many of "
            f"them are release-bound (true only of the release the stamp names)"
        )
        continue
    total, bound, project, audited = declared[(path, token)]
    if count != total:
        problems.append(f"{path}: {token} appears ×{count}, {stampfile.name} says ×{total}")
    if bound and audited != pins[project]:
        problems.append(
            f"{path}: {bound} release-bound {token} sentence(s) were audited at {project} "
            f"{audited}, the {project} pin is now {pins[project]} — re-read them, then "
            f"re-stamp its audited-at-{project}"
        )
for (path, token) in sorted(set(declared) - set(stamps)):
    problems.append(f"{stampfile.name} lists {token} in {path}, which no longer carries it")

if problems:
    for p in problems:
        print(f"version prose: {p}", file=sys.stderr)
    sys.exit(1)

by_project = {p: sum(1 for _, pr, _ in allowed.values() if pr == p) for p in pins}
print(
    f"version prose: {sum(found.values())} literal mention(s) audited against wolf "
    f"{pins['wolf']} and lupin {pins['lupin']}, {len(allowed)} allowlisted "
    f"({by_project['wolf']} on the wolf clock, {by_project['lupin']} on lupin's)"
)
print(
    f"version prose: {sum(stamps.values())} placeholder(s) in {len(declared)} entries, "
    f"{sum(b for _, b, _, _ in declared.values())} of them release-bound and re-read at "
    f"this bump"
)
