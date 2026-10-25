#!/usr/bin/env python3
"""Source reference, deliberately independent of compiler resolution.

wolf doc at the site's pin omits public inherent methods and unimported nested
modules; its JSON has no source positions. This bounded lexer preserves source
signatures (including rows), never resolves or executes a body, and refuses
unknown public forms rather than silently publishing a partial surface.
"""
import argparse
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GROUPS = [
    ('Foundations and ordering', 'prelude option errors cmp ops testing'),
    ('Containers and regions', 'list map set deque pool iter range mem'),
    ('Strings', 'str strbuf bytes unicode'),
    ('Numerics', 'math rand sort search'),
    ('Formatting and encodings', 'fmt hex base64 json'),
    ('The os tier', 'fs io net time env process signal term os'),
    ('Nursery', 'x'),
]
KINDS = {'fn': 'functions', 'struct': 'types', 'enum': 'types',
         'trait': 'types', 'type': 'types', 'const': 'constants', 'error': 'errors'}


def git(path, *args):
    return subprocess.check_output(['git', '-C', str(path), *args], text=True).strip()


def masked(source):
    """Keep offsets/newlines, hide comments and quoted strings from structure."""
    pattern = r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\[\s\S]|[^"\\])*"|\'(?:\\[\s\S]|[^\'\\])*\''
    return re.sub(pattern, lambda m: re.sub(r'[^\n]', ' ', m[0]), source)


def closing(text, start, left='{', right='}'):
    depth = 0
    for i in range(start, len(text)):
        if text[i] == left:
            depth += 1
        elif text[i] == right:
            depth -= 1
            if not depth:
                return i
    raise ValueError('unclosed declaration at offset %d' % start)


def docs_before(source, start):
    lines = source[:start].splitlines()
    if lines and not lines[-1].strip():
        lines.pop()  # indentation before pub
    out = []
    for line in reversed(lines):
        match = re.match(r'^\s*///(?!/)(?: ?)(.*)$', line)
        if not match:
            break
        out.append(match[1])
    return '\n'.join(reversed(out))


def declarations(source, path):
    text = masked(source)
    # Only public inherent methods need qualification. Trait/struct contents
    # remain part of their type's signature; implementation bodies do not.
    scopes = []
    for m in re.finditer(r'\bimpl\s+([^{}]+)\{', text):
        scopes.append((m.end() - 1, closing(text, m.end() - 1), m[1].strip()))
    items = []
    for m in re.finditer(r'\bpub\s+(\w+)\s+(\w+)', text):
        kind, name = m[1], m[2]
        if kind not in KINDS:
            raise ValueError('%s: unsupported public kind %s' % (path, kind))
        start, pos = m.start(), m.end()
        if kind == 'fn':
            # A brace inside arguments/generics is a row, not the body.
            square = paren = 0
            while pos < len(text):
                ch = text[pos]
                if ch == '[': square += 1
                elif ch == ']': square -= 1
                elif ch == '(': paren += 1
                elif ch == ')': paren -= 1
                elif ch == '{':
                    prefix = text[start:pos].rstrip()
                    if square or paren or prefix.endswith('!'):
                        pos = closing(text, pos)
                    else:
                        break
                elif ch == ';' and not square and not paren:
                    break
                pos += 1
            if pos == len(text):
                raise ValueError('%s: function has no body: %s' % (path, name))
        elif kind in ('struct', 'enum', 'trait'):
            brace = text.find('{', pos)
            eq = text.find('=', pos)
            if eq >= 0 and (brace < 0 or eq < brace):
                pos = text.find('\n', pos)
            else:
                pos = closing(text, brace) + 1
        else:
            # Constants and row aliases end at a balanced newline.
            while pos < len(text) and text[pos] != '\n':
                if text[pos] in '{[(':
                    left = text[pos]
                    pos = closing(text, pos, left, {'{': '}', '[': ']', '(': ')'}[left])
                pos += 1
        owner = next((s[2] for s in scopes if s[0] < start < s[1]), None)
        if owner:
            if not re.fullmatch(r'\w+(?:\[[^]]+\])?', owner):
                raise ValueError('%s: unsupported public impl scope %s' % (path, owner))
            name = owner.split('[')[0] + '.' + name
        # Strip comments, not strings, from signatures; constants keep values.
        sig = re.sub(r'"(?:\\[\s\S]|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/',
                     lambda m: m[0] if m[0].startswith('"') else '', source[start:pos]).strip()
        sig = re.sub(r'\s+', ' ', sig)
        items.append(dict(name=name, kind=kind, signature=sig,
                          doc=docs_before(source, start), source=path,
                          line=source.count('\n', 0, start) + 1))
    # Every pub token must have been understood, including newly added syntax.
    if len(items) != len(re.findall(r'\bpub\b', text)):
        raise ValueError('%s: an unrecognized public declaration' % path)
    return items


def first_sentence(doc):
    text = ' '.join(doc.split())
    # A period inside std.foo or a number is not sentence punctuation.
    return re.split(r'(?<=[.!?])\s+', text, maxsplit=1)[0]


def extract(std, compiler):
    std_pin = git(std, 'rev-parse', 'HEAD')
    compiler_pin = git(compiler, 'rev-parse', 'HEAD')
    std_compiler = git(std, 'ls-tree', 'HEAD', 'upstream').split()[2]
    if std_compiler != compiler_pin:
        raise ValueError('std toolchain pin differs from the site compiler pin')
    for path in (std, compiler):
        if git(path, 'status', '--porcelain', '--untracked-files=no'):
            raise ValueError('dirty reference input: %s' % path)
    version = re.search(r'^## ([\d.]+) ', (compiler / 'CHANGELOG.md').read_text(), re.M)[1]
    groups = {name: group for group, names in GROUPS for name in names.split()}
    modules = {}
    for directory in sorted(p for p in (std / 'std').rglob('*') if p.is_dir()):
        name = '.'.join(directory.relative_to(std / 'std').parts)
        top = name.split('.')[0]
        if top not in groups:
            raise ValueError('new module needs an API-CONVENTIONS group: %s' % name)
        files = sorted(directory.glob('*.lu'), key=lambda p: (p.stem != directory.name, p.name))
        module_docs, items = [], []
        for file in files:
            source = file.read_text()
            doc = '\n'.join(m[1] for m in re.finditer(r'^//! ?(.*)$', source, re.M)
                            if m[1] != 'member: true').strip()
            if doc:
                module_docs.append(doc)
            items.extend(declarations(source, file.relative_to(std).as_posix()))
        doc = '\n\n'.join(module_docs)
        tier = re.search(r'Stability\s+tier:\s*(core|penumbra|x)\b', doc.replace('*', ''))
        if not files:
            doc = 'Namespace for the modules listed below.'
        elif not tier:
            raise ValueError('module has no stability tier: %s' % name)
        for item in items:
            item['tier'] = tier[1]
        names = [i['name'] for i in items]
        if len(names) != len(set(names)):
            raise ValueError('duplicate item anchors in %s' % name)
        modules[name] = dict(name=name, group=groups[top], tier=tier[1] if tier else
                             ('x' if top == 'x' else 'namespace'), doc=doc,
                             summary=first_sentence(doc), items=items)
    return dict(schema=1, extractor='source', std_pin=std_pin, compiler_pin=compiler_pin,
                wolf_version=version, modules=list(modules.values()))


def json_text(data):
    return json.dumps(data, ensure_ascii=False, indent=2) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--std', type=Path, default=ROOT / 'upstream/wolf-std')
    parser.add_argument('--compiler', type=Path, default=ROOT / 'upstream/wolf-lang')
    parser.add_argument('--out', type=Path, default=ROOT / 'dist/std/reference.json')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    try:
        data = extract(args.std, args.compiler)
        content = json_text(data)
        if args.check:
            if not args.out.is_file() or args.out.read_text() != content:
                raise ValueError('std reference drift: regenerate from the pinned sources')
        else:
            args.out.parent.mkdir(parents=True, exist_ok=True)
            args.out.write_text(content)
        print('std reference: %d modules, %d public items%s' % (
            len(data['modules']), sum(len(m['items']) for m in data['modules']),
            ', no drift' if args.check else ''))
    except (ValueError, subprocess.CalledProcessError) as e:
        parser.exit(1, 'std reference: %s\n' % e)


if __name__ == '__main__':
    main()
