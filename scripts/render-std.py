#!/usr/bin/env python3
"""Render HTML and a plain-text surface from the single extracted std JSON."""
import argparse
import hashlib
import html
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('std_reference', ROOT / 'scripts/std-reference.py')
ref = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ref)
E = html.escape
SECTIONS = [('types', 'Types and traits'), ('functions', 'Functions and methods'),
            ('constants', 'Constants'), ('errors', 'Errors and row tags')]


def inline(text):
    # Interpret only code and emphasis; all other source prose stays literal.
    # In particular raw HTML can never become executable markup.
    parts = re.split(r'(`[^`]+`)', text)
    return ''.join('<code>%s</code>' % E(p[1:-1]) if p.startswith('`') else
                   re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', E(p)) for p in parts)


def prose(text):
    out, paragraph, code = [], [], None
    def flush():
        if paragraph:
            out.append('<p>' + inline(' '.join(paragraph)) + '</p>')
            paragraph.clear()
    for line in text.splitlines():
        if line.startswith('```'):
            flush()
            if code is None:
                code = []
            else:
                out.append('<pre><code>' + E('\n'.join(code)) + '</code></pre>')
                code = None
        elif code is not None:
            code.append(line)
        elif not line.strip():
            flush()
        else:
            paragraph.append(line)
    flush()
    if code is not None:
        out.append('<pre><code>' + E('\n'.join(code)) + '</code></pre>')
    return '\n'.join(out)


def plain(text):
    return re.sub(r'\[([^]]+)\]\([^)]*\)', r'\1', text).replace('`', '').replace('**', '')


def machine(module):
    lines = ['std.%s [%s]' % (module['name'], module['tier'])]
    for item in module['items']:
        lines.append('std.%s.%s %s — %s' % (module['name'], item['name'],
                     item['signature'], plain(ref.first_sentence(item['doc']))))
    return '\n'.join(lines) + '\n'


def page(title, body, toc, data):
    asset = hashlib.sha256((ROOT / 'site/std/toc.js').read_bytes()).hexdigest()[:12]
    css = hashlib.sha256((ROOT / 'site/std/reference.css').read_bytes()).hexdigest()[:12]
    pin = data['std_pin']
    return '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>%s · wolf</title>
<link rel="stylesheet" href="/style.css">
<link rel="stylesheet" href="/std/reference.css?v=%s">
<link rel="icon" href="/wolf.svg" type="image/svg+xml">
<script src="/std/toc.js?v=%s" defer></script>
</head>
<body class="std-reference">
<a class="std-skip" href="#reference">Skip to reference</a>
<header>
<h1>%s</h1>
<nav class="site" aria-label="Site">
<a href="/">wolf</a><a href="/install/">install</a><a href="/play/">playground</a>
<a href="/reading/">the book</a><a href="/std/">std</a><a href="/spec/">spec</a>
<a href="/docs/">docs</a><a href="/changelog/">changelog</a>
</nav>
<p class="note">wolf-std <a href="https://github.com/wolffe-lang/wolf-std/tree/%s"><code>%s</code></a>
 · toolchain pin verified against wolf %s (<code>%s</code>).
Source signatures and documentation; execution support is stated in each module.</p>
<button id="std-toggle" type="button" aria-controls="std-toc" aria-expanded="false" hidden>Contents</button>
</header>
<nav id="std-toc" aria-label="On this page">
<button id="std-close" type="button" hidden>Close contents</button>
<h2>On this page</h2>%s</nav>
<main id="reference" tabindex="-1">%s</main>
<footer><p>Generated from the pinned library source. <a href="/std/index.txt">Whole surface as plain text</a>.
<a href="/std/reference.json">JSON with source lines</a>.
<a href="https://github.com/wolffe-lang/wolf-std/blob/%s/API-CONVENTIONS.md">API conventions</a>.</p></footer>
</body></html>
''' % (E(title), css, asset, E(title), pin, pin[:7], E(data['wolf_version']),
       data['compiler_pin'][:7], toc, body, pin)


def render(data):
    outputs, index, index_toc = {}, [], []
    modules = data['modules']
    for number, (group, _) in enumerate(ref.GROUPS):
        anchor = 'group-%d' % number
        index_toc.append('<li><a href="#%s">%s</a></li>' % (anchor, E(group)))
        index.append('<section id="%s"><h2>%s</h2><dl class="index">' % (anchor, E(group)))
        for module in modules:
            if module['group'] != group:
                continue
            name = module['name']
            index.append('<dt><a href="/std/%s/">std.%s</a> <span class="std-tier">%s</span></dt><dd>%s</dd>' %
                         (name, name, E(module['tier']), inline(module['summary'])))
        index.append('</dl></section>')
    intro = '<p>The public standard-library surface, grouped by the API conventions. Nursery modules may change or disappear.</p><p><a href="/std/index.txt">Download the whole surface as plain text</a>.</p>'
    outputs['index.html'] = page('Standard library', intro + ''.join(index),
                                 '<ul>' + ''.join(index_toc) + '</ul>', data)
    outputs['index.txt'] = '\n'.join(machine(m) for m in modules)
    for module in modules:
        name = module['name']
        body = ['<p><a href="/std/">All modules</a> · <a href="/std/%s.txt">Plain text</a> · Stability tier: %s</p>' % (name, E(module['tier'])),
                '<section id="module-doc"><h2>Module</h2>' + prose(module['doc']) + '</section>']
        toc = ['<li><a href="#module-doc">Module</a></li>']
        children = [m for m in modules if m['name'].rsplit('.', 1)[0] == name and m['name'] != name]
        if children:
            body.append('<section id="modules"><h2>Modules</h2><ul>' + ''.join(
                '<li><a href="/std/%s/">std.%s</a></li>' % (m['name'], m['name']) for m in children) + '</ul></section>')
            toc.append('<li><a href="#modules">Modules</a></li>')
        for kind, label in SECTIONS:
            items = [i for i in module['items'] if ref.KINDS[i['kind']] == kind]
            section_id = 'section-' + kind
            toc.append('<li><a href="#%s">%s</a><ul>' % (section_id, label))
            body.append('<section id="%s"><h2>%s</h2>' % (section_id, label))
            if kind == 'errors':
                rows = set()
                for item in module['items']:
                    for row in re.findall(r'!\s*\{([^}]+)\}', item['signature']):
                        rows.update(re.findall(r'(?:^|,)\s*([A-Za-z_]\w*)', row))
                if rows:
                    body.append('<p>Tags named by public signatures: ' + ', '.join('<code>' + E(tag) + '</code>' for tag in sorted(rows)) + '. Their conditions are documented on the functions that return them.</p>')
            if not items:
                body.append('<p class="note">No public declarations in this section.</p>')
            for item in items:
                item_name = item['name']
                toc.append('<li><a href="#%s">%s</a></li>' % (item_name, item_name))
                link = 'https://github.com/wolffe-lang/wolf-std/blob/%s/%s#L%d' % (data['std_pin'], item['source'], item['line'])
                body.append('<article id="%s" data-std-item="%s"><h3><a href="#%s">%s</a></h3><p class="note">%s · <a href="%s">Source line %d</a></p><pre class="std-signature"><code>%s</code></pre>%s</article>' %
                            (item_name, item_name, item_name, item_name, E(item['kind']), E(link), item['line'], E(item['signature']), prose(item['doc']) if item['doc'] else '<p class="note">No item documentation at this pin.</p>'))
            body.append('</section>')
            toc.append('</ul></li>')
        outputs[name + '/index.html'] = page('std.' + name, ''.join(body), '<ul>' + ''.join(toc) + '</ul>', data)
        outputs[name + '.txt'] = machine(module)
    return outputs


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('input', type=Path)
    p.add_argument('out', type=Path)
    p.add_argument('--check', action='store_true')
    args = p.parse_args()
    outputs = render(json.loads(args.input.read_text()))
    for name, content in outputs.items():
        target = args.out / name
        if args.check:
            if not target.is_file() or target.read_text() != content:
                p.exit(1, 'std rendered drift: %s\n' % name)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
            target.chmod(0o644)
    print('std render: %d outputs%s' % (len(outputs), ', no drift' if args.check else ''))


if __name__ == '__main__':
    main()
