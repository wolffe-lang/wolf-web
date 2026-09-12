#!/usr/bin/env python3
"""The lag sentence on /install/ and /play/ is held where it is written.

    usage: check-lag-phrases.py <site-dir> <pinned-wolf-lang-dir>
                                <pinned-wolf-interp-dir> [--json]

Two implementations are compared against one specification and they do not tag
together, so the site has to say which one is behind. /install/ and /play/ both
write that sentence in prose, in a CLOSED SET of four phrases — `the same
commit`, `one release`, `two releases`, `three releases` — and the rule is that
the page carries the phrase for the counted gap and NONE of the other three,
anywhere on the page.

The rule is not new. It has been enforced since ww13, correctly, in PowerShell,
inside the `the specification pin lag the site records` step of
.github/workflows/windows.yml — on a runner nobody runs locally, in a job the
linux `CI` workflow does not depend on. At ww27 that cost the site a full
round trip: a new /play/ paragraph quoted the phrase for a gap of zero while
the gap was one, the local gauntlet was green (eleven gates, exit 0, twice),
the linux `CI` workflow was green, and `windows learner path` was the only
thing in the world that saw it (wolf-web#38).

Every other prose rule this site has — the version literals, the number words,
the revisions, the placeholder sweep — is a script under scripts/ that runs in
build.sh and therefore reds on the author's machine at the moment the sentence
is written. This is that rule, in that shape. The windows step calls this file
now, so there is one implementation and not two that can disagree.

WHY IT IS PAGE-WIDE, and why that is not a bug. The check cannot tell a
quotation from a claim, so a sentence that mentions another gap's phrase for
any reason at all reds. That is deliberate: a lag paragraph left unrewritten
is exactly what the rule was written to catch, and it is indistinguishable
from a deliberate quotation by any test a machine can apply. The phrases are
short on purpose. Word around them.

THE ARITHMETIC. Both ends of the distance are gitlinks, which cannot be worded
differently: the interpreter records the specification checkout it was built to
as a submodule, and this site records the compiler it advertises the same way.
The gap is counted by ANCESTRY in the compiler's own history — the newest
release tag that is an ancestor of the interpreter's pin — because since ww20
the interpreter's pin has not always been a tag at all (lupin 0.1.29 was built
to `e9a17cb`, a development revision of trunk). A pin that is not a tag gets
its own half of the rule: `a development revision` is reserved vocabulary
beside the four phrases, required when the pin is no release and refused when
it is.

That needs the compiler checkout to carry history and tags. A depth-1 clone
cannot answer, and this says so by name rather than guessing.

Two more facts about the same gap are checked here because they are written in
the same paragraph and rot on the same schedule: the revision itself must be
the __PIN_specrev_short__ stamp and never a literal (correct-today is exactly
how that sentence went stale — wolf-web#21), and the distance in commits must
be the __COUNT_speccommits_word__ stamp exactly when there IS a distance.

This walks site/, where the placeholders are still placeholders. It runs
beside the other two prose audits, before the stamps.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

# The closed set. Adding one means writing the sentence first, on both pages.
PHRASES = {
    0: "the same commit",
    1: "one release",
    2: "two releases",
    3: "three releases",
}
DEVREV = "a development revision"
SPECREV = "__PIN_specrev_short__"
DISTANCE = "__COUNT_speccommits_word__"
PAGES = ("install/index.html", "play/index.html")


def git(where: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", "-C", str(where), *args], capture_output=True, text=True
    )


def out(where: Path, *args: str) -> str:
    done = git(where, *args)
    if done.returncode != 0:
        raise SystemExit(
            f"check-lag-phrases: git {' '.join(args)} in {where} failed: "
            f"{done.stderr.strip()} (a shallow checkout without tags cannot "
            f"answer this; fetch --unshallow --tags)"
        )
    return done.stdout.strip()


def facts(lang: Path, interp: Path) -> dict:
    """Everything about the lag that a page could get wrong."""
    changelog = (lang / "CHANGELOG.md").read_text(encoding="utf-8")
    releases = re.findall(r"^## (\d[\d.]*)\s", changelog, re.M)
    if len(releases) < 2:
        raise SystemExit(
            "check-lag-phrases: the pinned wolf-lang CHANGELOG.md has fewer "
            "than two releases — the gap cannot be counted"
        )

    link = out(interp, "ls-tree", "HEAD", "upstream")
    pin = re.match(r"^160000 commit ([0-9a-f]{40})", link)
    if not pin:
        raise SystemExit(
            f"check-lag-phrases: {interp} records no gitlink for its "
            f"specification checkout — the pin cannot be read"
        )
    lup = pin.group(1)
    own = out(lang, "rev-parse", "HEAD")
    short = lup[:7]

    if git(lang, "cat-file", "-e", f"{lup}^{{commit}}").returncode != 0:
        raise SystemExit(
            f"check-lag-phrases: the interpreter was built to {short}, which "
            f"is not a commit in the pinned compiler checkout — one of the two "
            f"pins is wrong, or the revision was never pushed"
        )
    if git(lang, "merge-base", "--is-ancestor", lup, own).returncode != 0:
        raise SystemExit(
            f"check-lag-phrases: the interpreter was built to {short}, which "
            f"the compiler this site pins does not descend from — the "
            f"interpreter is reading a specification that is not on this line"
        )
    commits = int(out(lang, "rev-list", "--count", f"{lup}..{own}"))

    spec = ""
    for r in releases:
        if git(lang, "rev-parse", "-q", "--verify", f"v{r}^{{commit}}").returncode != 0:
            continue
        if git(lang, "merge-base", "--is-ancestor", f"v{r}^{{commit}}", lup).returncode == 0:
            spec = r
            break
    if not spec:
        raise SystemExit(
            f"check-lag-phrases: no release in the pinned wolf CHANGELOG is an "
            f"ancestor of {short} — the interpreter was built to a revision "
            f"older than every tag this checkout can see (or the tags were "
            f"never fetched)"
        )
    tagged = out(lang, "rev-parse", f"v{spec}^{{commit}}") == lup
    gap = releases.index(spec)

    if gap not in PHRASES:
        raise SystemExit(
            f"check-lag-phrases: the interpreter is {gap} releases behind and "
            f"/install/ and /play/ have prose for 0 through {max(PHRASES)} "
            f"only — write the sentence, then add its phrase here"
        )
    if gap == 0 and lup != own:
        raise SystemExit(
            f"check-lag-phrases: the counted gap is zero but this site pins "
            f"wolf-lang at {own[:7]} while lupin was built at {short} — the "
            f"two pages would say '{PHRASES[0]}' about two commits"
        )
    return {
        "gap": gap,
        "phrase": PHRASES[gap],
        "tagged": tagged,
        "commits": commits,
        "spec": short,
        "release": spec,
        "advertised": releases[0],
    }


def main() -> int:
    args = [a for a in sys.argv[1:] if a != "--json"]
    as_json = "--json" in sys.argv[1:]
    if len(args) != 3:
        print(__doc__.strip().splitlines()[2].strip(), file=sys.stderr)
        return 2
    site, lang, interp = (Path(a) for a in args)

    f = facts(lang, interp)
    gap, want, tagged, commits, short = (
        f["gap"], f["phrase"], f["tagged"], f["commits"], f["spec"]
    )

    problems: list[str] = []
    for rel in PAGES:
        page = site / rel
        if not page.is_file():
            problems.append(f"{rel} is missing — the lag is stated on both pages")
            continue
        text = re.sub(r"\s+", " ", page.read_text(encoding="utf-8"))

        if want not in text:
            problems.append(
                f"{rel}: the gap is {gap} and the page does not say so — it "
                f"must carry the phrase '{want}'"
            )
        for k, other in PHRASES.items():
            if k != gap and other in text:
                problems.append(
                    f"{rel}: still carries '{other}' while the counted gap is "
                    f"{gap} — a lag paragraph was left unrewritten (the rule is "
                    f"page-wide: it cannot tell a quotation from a claim)"
                )
        if not tagged and DEVREV not in text:
            problems.append(
                f"{rel}: lupin was built at {short}, which is no release, and "
                f"the page does not say so — it must carry '{DEVREV}'"
            )
        if tagged and DEVREV in text:
            problems.append(
                f"{rel}: lupin was built at the v{f['release']} tag and the "
                f"page still calls it '{DEVREV}' — a lag paragraph was left "
                f"unrewritten"
            )
        if SPECREV not in text:
            problems.append(
                f"{rel}: states no specification revision — it must carry "
                f"{SPECREV}, which the build stamps from the gitlink"
            )
        if short in text:
            problems.append(
                f"{rel}: writes the revision {short} by hand — that is what "
                f"{SPECREV} is for, and a literal is stale one bump later"
            )
        stamped = DISTANCE in text
        if commits > 0 and not stamped:
            problems.append(
                f"{rel}: the interpreter's pin is {commits} commits behind and "
                f"the page states no distance — it must carry {DISTANCE}"
            )
        if commits == 0 and stamped:
            problems.append(
                f"{rel}: carries {DISTANCE} while the two pins are one commit "
                f"— there is no distance to state"
            )

    if problems:
        for p in problems:
            print(f"lag phrases: {p}", file=sys.stderr)
        return 1

    if as_json:
        print(json.dumps(f))
    else:
        reads = (
            "this release" if gap == 0
            else "the release before this one" if gap == 1
            else f"{gap} releases back"
        )
        at = (
            f"the v{f['release']} tag ({short})" if tagged
            else f"{short}, a development revision past v{f['release']}, "
                 f"{commits} commits back"
        )
        print(
            f"lag phrases: wolf {f['advertised']} is advertised; lupin was "
            f"built at {at} — it reads {reads}, and both pages carry "
            f"'{want}' and neither carries another"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
