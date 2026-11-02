#!/usr/bin/env python3
"""web-allow.py LOG : apply check-version-prose.py's complaints (LOG) to
scripts/version-allowlist.txt in the wolf-web checkout (cwd), after the
sentences were re-read by hand: re-stamp the clock of every due entry to the
new pins, set a drifted count to what the page carries, drop an entry whose
literal the page no longer carries, and add an entry for a new historical
literal (the clock by the literal's project: 0.1.x is lupin's, the rest
wolf's). Prints every change."""
import re
import sys

WOLF, LUPIN = "0.2.36", "0.1.58"
log = open(sys.argv[1]).read().splitlines()
path = "scripts/version-allowlist.txt"
lines = open(path).read().split("\n")

restamp, counts, drop, add = set(), {}, set(), {}
for l in log:
    m = re.match(r"version prose: (\S+): '([^']+)' was audited at (wolf|lupin) ", l)
    if m:
        restamp.add((m[1], m[2]))
        continue
    m = re.match(r"version prose: (\S+): '([^']+)' appears ×(\d+), the allowlist says ×(\d+)", l)
    if m:
        counts[(m[1], m[2])] = m[3]
        continue
    m = re.match(r"version prose: version-allowlist.txt lists '([^']+)' in (\S+), which no longer carries it", l)
    if m:
        drop.add((m[2], m[1]))
        continue
    m = re.match(r"version prose: (\S+): '([^']+)' ×(\d+) is not in version-allowlist.txt", l)
    if m:
        add[(m[1], m[2])] = m[3]

out = []
for l in lines:
    if l.startswith("#") or not l.strip():
        out.append(l)
        continue
    parts = l.split()
    key = (parts[0], parts[1])
    if key in drop:
        print(f"drop    {l}")
        continue
    new = list(parts)
    if key in counts:
        new[2] = counts[key]
    if key in restamp or key in counts:
        new = [f"audited-at-wolf={WOLF}" if x.startswith("audited-at-wolf=") else
               f"audited-at-lupin={LUPIN}" if x.startswith("audited-at-lupin=") else x for x in new]
    nl = " ".join(new)
    if nl != l:
        print(f"change  {l}\n     -> {nl}")
    out.append(nl)
# New entries go after the last entry for the same page.
for (page, lit), n in sorted(add.items()):
    clock = "frozen" if page == "CHANGELOG.md" else f"audited-at-lupin={LUPIN}" if re.match(r"^v?0\.1\.", lit) else f"audited-at-wolf={WOLF}"
    entry = f"{page} {lit} {n} {clock}"
    idx = max((i for i, l in enumerate(out) if l.split()[:1] == [page]), default=len(out) - 1)
    out.insert(idx + 1, entry)
    print(f"add     {entry}")
open(path, "w").write("\n".join(out))
left = [k for k in restamp if k not in {(l.split()[0], l.split()[1]) for l in out if l.strip() and not l.startswith('#')}]
print(f"restamped {len(restamp)}, recounted {len(counts)}, dropped {len(drop)}, added {len(add)}; unmatched restamps {left}")
