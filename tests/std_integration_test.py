"""Real source -> JSON -> pages/text, with negative controls for each gate."""
import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / ('scripts/' + name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


ref, renderer, checker = map(load, ['std-reference', 'render-std', 'check-std'])


class Integration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = ref.extract(ROOT / 'upstream/wolf-std', ROOT / 'upstream/wolf-lang')
        cls.output = renderer.render(cls.data)

    def test_every_source_module_and_public_declaration_is_extracted(self):
        dirs = sorted(p for p in (ROOT / 'upstream/wolf-std/std').rglob('*') if p.is_dir())
        self.assertEqual({m['name'] for m in self.data['modules']},
                         {'.'.join(p.relative_to(ROOT / 'upstream/wolf-std/std').parts) for p in dirs})
        for module in self.data['modules']:
            directory = ROOT / 'upstream/wolf-std/std' / module['name'].replace('.', '/')
            # Independent line census catches silent loss inside the extractor.
            import re
            count = sum(len(re.findall(r'^\s*pub\s', p.read_text(), re.M)) for p in directory.glob('*.lu'))
            self.assertEqual(len(module['items']), count, module['name'])
        cmp = next(m for m in self.data['modules'] if m['name'] == 'cmp')
        self.assertIn('Ordering.reverse', [i['name'] for i in cmp['items']])

    def make_tree(self, path):
        (path / 'reference.json').write_text(ref.json_text(self.data))
        for name, text in self.output.items():
            file = path / name
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text(text)

    def test_std_public_items_and_js_off_contents(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'target') as temp:
            root = Path(temp)
            self.make_tree(root)
            checker.check(root)
            p = root / 'base64/index.html'
            p.write_text(p.read_text().replace('data-std-item="encode"', 'data-omitted="encode"'))
            with self.assertRaisesRegex(ValueError, 'std-public-items'):
                checker.check(root)

    def test_drifted_json_pin_is_rejected(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'target') as temp:
            out = Path(temp) / 'reference.json'
            out.write_text(ref.json_text(self.data))
            command = ['python3', str(ROOT / 'scripts/std-reference.py'), '--out', str(out), '--check']
            self.assertEqual(subprocess.run(command, capture_output=True).returncode, 0)
            changed = dict(self.data, std_pin='0' * 40)
            out.write_text(ref.json_text(changed))
            failed = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(failed.returncode, 0)
            self.assertIn('std reference drift', failed.stderr)

    def test_changed_std_checkout_pin_is_rejected(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'target') as temp:
            temp = Path(temp)
            checkout = temp / 'std'
            subprocess.run(['git', 'clone', '--shared', '--quiet', str(ROOT / 'upstream/wolf-std'), str(checkout)], check=True)
            subprocess.run(['git', '-C', str(checkout), 'checkout', '--quiet', '-b', 'std-drift-test'], check=True)
            subprocess.run(['git', '-C', str(checkout), '-c', 'user.name=Std test', '-c', 'user.email=std-test@example.invalid', 'commit', '--allow-empty', '--no-gpg-sign', '--quiet', '-m', 'Change fixture pin'], check=True)
            out = temp / 'reference.json'
            out.write_text(ref.json_text(self.data))
            failed = subprocess.run(['python3', str(ROOT / 'scripts/std-reference.py'), '--std', str(checkout), '--out', str(out), '--check'], capture_output=True, text=True)
            self.assertNotEqual(failed.returncode, 0)
            self.assertRegex(failed.stderr, 'std reference drift|toolchain pin differs')

    def test_html_escaping(self):
        self.assertNotIn('<script>', renderer.prose('A <script>bad()</script>.'))
        self.assertIn('&lt;script&gt;', renderer.prose('A <script>bad()</script>.'))


(ROOT / 'target').mkdir(exist_ok=True)
if __name__ == '__main__':
    unittest.main()
