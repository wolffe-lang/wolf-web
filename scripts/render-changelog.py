#!/usr/bin/env python3
"""Render one project's CHANGELOG.md into a site page.

The reading-page discipline applies: the page is generated from the
pinned checkout, so it can only show what the pin carries — never wrong,
only honestly behind. A pinned repo that does not carry a CHANGELOG.md
yet gets a page that SAYS so; an absent file is a fact to report, not a
build failure.

The markdown dialect is the small one the org's changelogs actually use:
#..#### headings, flat `- ` lists with indented continuations, fenced
code blocks, paragraphs, and inline `code`, **strong** and [links](…).
Everything is HTML-escaped first; no script, no style, CSP untouched.

Usage:
  render-changelog.py <name> <sub> <changelog.md> <repo-url> <pin> <outdir>

<changelog.md> may name a file that does not exist — that renders the
honest stub. Writes <outdir>/index.html, mode 0644.
"""
import html
import re
import sys
from pathlib import Path

name, sub, src, repo, pin, outdir = sys.argv[1:7]
src = Path(src)

CODE = re.compile(r"`([^`]+)`")
STRONG = re.compile(r"\*\*([^*]+)\*\*")
LINK = re.compile(r"\[([^\]]+)\]\((https?://[^)\s]+|/[^)\s]*|#[^)\s]+)\)")


def inline(text: str) -> str:
    out = html.escape(text, quote=False)
    out = CODE.sub(r"<code>\1</code>", out)
    out = STRONG.sub(r"<strong>\1</strong>", out)
    out = LINK.sub(r'<a href="\2">\1</a>', out)
    return out


def slug(text: str, seen: dict) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-") or "section"
    seen[s] = seen.get(s, 0) + 1
    return s if seen[s] == 1 else f"{s}-{seen[s]}"


def render(md: str) -> str:
    out: list[str] = []
    seen: dict = {}
    para: list[str] = []
    in_list = False
    in_code = False
    code_lines: list[str] = []
    first_h1_dropped = False

    def flush_para():
        nonlocal para
        if para:
            out.append(f"<p>{inline(' '.join(para))}</p>")
            para = []

    def close_list():
        nonlocal in_list
        if in_list:
            out.append("</ul>")
            in_list = False

    for line in md.splitlines():
        if in_code:
            if line.startswith("```"):
                out.append("<pre><code>" + html.escape("\n".join(code_lines)) + "</code></pre>")
                code_lines = []
                in_code = False
            else:
                code_lines.append(line)
            continue
        if line.startswith("```"):
            flush_para()
            close_list()
            in_code = True
            continue
        m = re.match(r"(#{1,4}) (.*)", line)
        if m:
            flush_para()
            close_list()
            level, text = len(m.group(1)), m.group(2).strip()
            if level == 1 and not first_h1_dropped:
                first_h1_dropped = True  # the page chrome is the h1
                continue
            tag = f"h{max(2, level)}"
            out.append(f'<{tag} id="{slug(text, seen)}">{inline(text)}</{tag}>')
            continue
        if line.startswith("- "):
            flush_para()
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append(f"<li>{inline(line[2:].strip())}</li>")
            continue
        if in_list and line.startswith("  ") and line.strip():
            out[-1] = out[-1][: -len("</li>")] + " " + inline(line.strip()) + "</li>"
            continue
        if not line.strip():
            flush_para()
            close_list()
            continue
        close_list()
        para.append(line.strip())
    flush_para()
    close_list()
    if in_code:  # an unclosed fence is still content
        out.append("<pre><code>" + html.escape("\n".join(code_lines)) + "</code></pre>")
    return "\n".join(out)


if src.is_file():
    body = f'<section>\n{render(src.read_text())}\n</section>'
    footer = (
        f'Rendered from <code>CHANGELOG.md</code> at\n'
        f'  <a href="{repo}">{html.escape(name)}</a> revision <code>{pin}</code>, the checkout '
        f'this site was built from. The page shows what that revision carries — never wrong, '
        f'only honestly behind.'
    )
else:
    body = (
        '<section>\n'
        f'  <p>The checkout of <a href="{repo}">{html.escape(name)}</a> this site is built'
        f' from (<code>{pin}</code>) does not carry a <code>CHANGELOG.md</code> yet, so there'
        ' is honestly nothing to render. This page fills in when the site\'s pin advances'
        ' past one; until then, the commit log at the repository is the record.</p>\n'
        '</section>'
    )
    footer = (
        f'Generated from <a href="{repo}">{html.escape(name)}</a> revision '
        f'<code>{pin}</code>, the checkout this site was built from.'
    )

page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(name)} changelog · wolf</title>
<meta name="description" content="{html.escape(sub, quote=True)}">
<link rel="stylesheet" href="/style.css">
<link rel="icon" href="/wolf.svg" type="image/svg+xml">
</head>
<body>
<header>
  <h1>{html.escape(name)} changelog</h1>
  <p class="sub">{inline(sub)}</p>
  <nav class="site">
    <a href="/">wolf</a>
    <a href="/play/">playground</a>
    <a href="/reading/">the book</a>
    <a href="/docs/">docs</a>
    <a href="/spec/">spec</a>
    <a href="/changelog/">changelog</a>
  </nav>
</header>

<main>
{body}
</main>

<footer>
  <p>{footer}</p>
</footer>
</body>
</html>
"""

out = Path(outdir)
out.mkdir(parents=True, exist_ok=True)
target = out / "index.html"
target.write_text(page)
target.chmod(0o644)
state = "rendered" if src.is_file() else "absent, said so"
print(f"  changelog/{out.name}: {state}")
