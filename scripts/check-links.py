#!/usr/bin/env python3
"""Every internal href in dist/ must resolve to a file we shipped.

A relative href resolves against the directory of the file that
contains it, not against the site root. Getting that wrong reports the
book's own appendices as dead, which is how this script started.
"""
import os
import re
import sys
from pathlib import Path

DIST = Path(sys.argv[1] if len(sys.argv) > 1 else "dist")
HREF = re.compile(rb'(?:href|src)="([^"]+)"')

def resolves(target: Path) -> bool:
    return target.is_file() or (target / "index.html").is_file() or target.with_suffix(".html").is_file()

allow: set[str] = set()
allowfile = Path(__file__).parent / "link-allowlist.txt"
if allowfile.is_file():
    for line in allowfile.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            allow.add(line)

dead: list[str] = []
checked = 0
for page in DIST.rglob("*.html"):
    for raw in HREF.findall(page.read_bytes()):
        href = raw.decode("utf-8", "replace")
        if href.startswith(("http://", "https://", "//", "#", "mailto:", "data:")):
            continue
        path = href.split("#", 1)[0].split("?", 1)[0]
        if not path:
            continue
        base = DIST if path.startswith("/") else page.parent
        target = (base / path.lstrip("/")).resolve()
        checked += 1
        try:
            target.relative_to(DIST.resolve())
        except ValueError:
            dead.append(f"{page.relative_to(DIST)} -> {href} (escapes the site)")
            continue
        if not resolves(target):
            entry = f"{page.relative_to(DIST)} -> {href}"
            if entry not in allow:
                dead.append(entry)

for d in sorted(set(dead)):
    print(f"::error::dead link: {d}")
stale = sorted(a for a in allow if a not in set(dead) and a not in {f"{p.relative_to(DIST)} -> {h}" for p in [] for h in []})
print(f"link check: allowlist carries {len(allow)} known-dead link(s)")
print(f"link check: {checked} internal links across {len(list(DIST.rglob('*.html')))} pages, {len(set(dead))} dead")
sys.exit(1 if dead else 0)
