#!/usr/bin/env python3
"""Hold the served reference to the source-derived JSON, not to its renderer."""
import json
import re
import sys
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path


class Page(HTMLParser):
    def __init__(self, source):
        super().__init__()
        self.items, self.ids, self.links, self.scripts = [], [], [], []
        self.inline = False
        self.feed(source)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'data-std-item' in attrs:
            self.items.append(attrs['data-std-item'])
        if 'id' in attrs:
            self.ids.append(attrs['id'])
        if tag == 'a':
            self.links.append(attrs.get('href', ''))
        if tag == 'script':
            self.scripts.append(attrs.get('src', ''))
        if tag == 'style' or 'style' in attrs or any(k.startswith('on') for k in attrs):
            self.inline = True


def check(root):
    data = json.loads((root / 'reference.json').read_text())
    whole = (root / 'index.txt').read_text().splitlines()
    expected_whole = []
    for module in data['modules']:
        name = module['name']
        path = root / name / 'index.html'
        if not path.is_file():
            raise ValueError('std-module-pages: missing ' + name)
        source = path.read_text()
        page = Page(source)
        expected = Counter(i['name'] for i in module['items'])
        if Counter(page.items) != expected:
            raise ValueError('std-public-items: std.%s expected %s, got %s' % (name, expected, Counter(page.items)))
        lines = (root / (name + '.txt')).read_text().splitlines()
        text_names = [line.split(' ', 1)[0] for line in lines if line.startswith('std.' + name + '.')]
        wanted = ['std.' + name + '.' + i['name'] for i in module['items']]
        if Counter(text_names) != Counter(wanted):
            raise ValueError('std-public-items: text surface differs for ' + name)
        expected_whole.extend(wanted)
        if len(page.ids) != len(set(page.ids)):
            raise ValueError('std-anchors: duplicate id in ' + name)
        for href in page.links:
            if href.startswith('#') and href[1:] not in page.ids:
                raise ValueError('std-anchors: broken link ' + name + href)
        if 'id="std-toc"' not in source or '<ul>' not in source or 'id="std-toc" hidden' in source:
            raise ValueError('std-js-off: missing inline contents in ' + name)
        if page.inline or not page.scripts or any(not src.startswith('/std/') for src in page.scripts):
            raise ValueError('std-csp: inline or foreign resource in ' + name)
    whole_names = [line.split(' ', 1)[0] for line in whole if re.match(r'^std\.\S+ pub ', line)]
    if Counter(whole_names) != Counter(expected_whole):
        raise ValueError('std-public-items: whole text surface differs')
    print('std-public-items: %d modules, %d items present exactly once in HTML and both text editions' % (len(data['modules']), len(expected_whole)))
    print('std-anchors, std-csp, std-js-off: PASS')


if __name__ == '__main__':
    try:
        check(Path(sys.argv[1] if len(sys.argv) > 1 else 'dist/std'))
    except (ValueError, OSError) as e:
        sys.exit(str(e))
