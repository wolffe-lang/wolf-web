"""Parser controls run before the site build; integration runs after it."""
import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('std_reference', Path(__file__).resolve().parents[1] / 'scripts/std-reference.py')
ref = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ref)


class Extractor(unittest.TestCase):
    def test_multiline_rows_and_quoted_braces(self):
        items = ref.declarations('''//! module
/// Read the value.
/// Rows: eof.
pub fn read[T](v: T ! {none}) -> str ! {
    eof, io
} {
    let s = "} pub fn hidden() {"
    s
}
// pub fn comment() {}
fn private() {}
''', 'std/sample/sample.lu')
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]['signature'], 'pub fn read[T](v: T ! {none}) -> str ! { eof, io }')
        self.assertEqual(items[0]['doc'], 'Read the value.\nRows: eof.')
        self.assertEqual(items[0]['line'], 4)

    def test_types_constants_errors_and_methods(self):
        items = ref.declarations('''pub struct File { fd: int }
pub enum Answer { Yes, No }
pub trait Eq { fn eq(self, other: Self) -> bool }
pub error Io = {io, eof}
pub const FLAG: int = 16
impl File {
    /// Read it.
    pub fn read(self) -> int { 1 }
}
''', 'fixture.lu')
        self.assertEqual([i['name'] for i in items], ['File', 'Answer', 'Eq', 'Io', 'FLAG', 'File.read'])
        self.assertEqual(items[-1]['doc'], 'Read it.')
        self.assertEqual(items[0]['signature'], 'pub struct File { fd: int }')
        self.assertEqual(items[3]['signature'], 'pub error Io = {io, eof}')
        self.assertEqual(items[4]['signature'], 'pub const FLAG: int = 16')

    def test_no_doc_leaks_from_private_item(self):
        items = ref.declarations('/// Private.\nfn hidden() {}\n\npub fn visible() {}', 'fixture')
        self.assertEqual(items[0]['doc'], '')

    def test_unknown_public_syntax_fails_closed(self):
        for text in ['pub use other', 'pub extern fn foreign() {}', 'pub ???']:
            with self.assertRaises(ValueError):
                ref.declarations(text, 'fixture')

    def test_summary_preserves_qualified_names(self):
        self.assertEqual(ref.first_sentence('std.fs — files.\nMore.'), 'std.fs — files.')


if __name__ == '__main__':
    unittest.main()
