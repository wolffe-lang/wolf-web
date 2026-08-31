/* Headless tests for the playground editor's core: pure functions over
 * (text, cursors), no DOM, no browser. Run with `node --test tests/`.
 *
 * The fixtures spell wolf, because the behaviors under test are wolf's:
 * 4-space indent (wolf fmt's unit), brace style, f-string interpolation
 * braces pairing inside strings, `//` comments.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import {
  INDENT,
  cursor,
  normalize,
  scan,
  type,
  enter,
  backspace,
  deleteForward,
  moveVertical,
  home,
  end,
  addCursorVertical,
  indentLines,
  dedentLines,
  tabInsert,
  toggleComment,
  paste,
  addNextOccurrence,
  collapseToPrimary,
  coalesces,
  visualCol,
  posAtVisualCol,
} from "../site/play/editor-core.js";

const at = (text, marker = "|") => {
  const pos = text.indexOf(marker);
  return { text: text.replace(marker, ""), pos };
};

/* ------------------------------------------------------------------ */
/* the scanner                                                         */
/* ------------------------------------------------------------------ */

test("scan: code is code", () => {
  assert.equal(scan("let x = 1", 9).mode, "code");
});

test("scan: inside a plain string", () => {
  const { text, pos } = at('print("hel|lo")');
  assert.equal(scan(text, pos).mode, "string");
});

test("scan: interpolation braces re-enter code", () => {
  const { text, pos } = at('print("hello, {wh|o}")');
  const ctx = scan(text, pos);
  assert.equal(ctx.mode, "code");
  assert.equal(ctx.inInterp, true);
});

test("scan: {{ is a literal brace, not an interpolation", () => {
  const { text, pos } = at('print("{{not code|}}")');
  assert.equal(scan(text, pos).mode, "string");
});

test("scan: a nested string inside an interpolation", () => {
  const { text, pos } = at('print("{ "wrap-|" }")');
  assert.equal(scan(text, pos).mode, "string");
});

test("scan: line comments", () => {
  const { text, pos } = at("let x = 1 // a com|ment");
  assert.equal(scan(text, pos).mode, "comment");
});

test("scan: char literals", () => {
  const { text, pos } = at("let c = '|w'");
  assert.equal(scan(text, pos).mode, "char");
});

test("scan: raw strings do not interpolate", () => {
  const { text, pos } = at('let r = r"a{b|}c"');
  assert.equal(scan(text, pos).mode, "raw");
});

test("scan: multiline strings", () => {
  const { text, pos } = at('let s = """\nline |one\n"""');
  assert.equal(scan(text, pos).mode, "string");
});

test("scan: an escaped quote does not close the string", () => {
  const { text, pos } = at('print("a\\"b|c")');
  assert.equal(scan(text, pos).mode, "string");
});

test("scan: open brackets carry their positions", () => {
  const src = "fn main() -> !int {\n    ";
  const ctx = scan(src, src.length);
  assert.equal(ctx.brackets.length, 1);
  assert.equal(src[ctx.brackets[0].pos], "{");
});

/* ------------------------------------------------------------------ */
/* pairing                                                             */
/* ------------------------------------------------------------------ */

test("type: an opener inserts its pair, caret inside", () => {
  const r = type("let x = ", [cursor(8)], "(");
  assert.equal(r.text, "let x = ()");
  assert.deepEqual(r.cursors, [cursor(9)]);
});

test("type: a closer types over its twin", () => {
  const r = type("let x = ()", [cursor(9)], ")");
  assert.equal(r.text, "let x = ()");
  assert.deepEqual(r.cursors, [cursor(10)]);
});

test("type: a quote pairs in code and types over itself", () => {
  const open = type("let s = ", [cursor(8)], '"');
  assert.equal(open.text, 'let s = ""');
  assert.deepEqual(open.cursors, [cursor(9)]);
  const close = type(open.text, open.cursors, '"');
  assert.equal(close.text, 'let s = ""');
  assert.deepEqual(close.cursors, [cursor(10)]);
});

test("type: no pairing against a word", () => {
  const { text, pos } = at("let x = |wolf");
  const r = type(text, [cursor(pos)], "(");
  assert.equal(r.text, "let x = (wolf");
});

test("type: a selection is wrapped, and stays selected", () => {
  const r = type("print(who)", [cursor(6, 9)], "{");
  assert.equal(r.text, "print({who})");
  assert.deepEqual(r.cursors, [cursor(7, 10)]);
});

test("type: parens do not pair inside a string", () => {
  const { text, pos } = at('print("hello |world")');
  const r = type(text, [cursor(pos)], "(");
  assert.equal(r.text, 'print("hello (world")');
});

test("type: interpolation braces DO pair inside a string", () => {
  const { text, pos } = at('print("hello, |")');
  const r = type(text, [cursor(pos)], "{");
  assert.equal(r.text, 'print("hello, {}")');
  assert.deepEqual(r.cursors, [cursor(pos + 1)]);
});

test("type: the interpolation's closing brace types over", () => {
  const { text, pos } = at('print("hello, {who|}")');
  const r = type(text, [cursor(pos)], "}");
  assert.equal(r.text, 'print("hello, {who}")');
  assert.deepEqual(r.cursors, [cursor(pos + 1)]);
});

test("type: nothing pairs in a comment", () => {
  const { text, pos } = at("// see (|");
  const r = type(text, [cursor(pos)], "(");
  assert.equal(r.text, "// see ((");
});

test("type: nothing pairs in a raw string", () => {
  const { text, pos } = at('let r = r"path/|"');
  const r = type(text, [cursor(pos)], "{");
  assert.equal(r.text, 'let r = r"path/{"');
});

test("type: a lone } dedents to its opener's line", () => {
  const src = "fn main() -> !int {\n    let x = 1\n        ";
  const r = type(src, [cursor(src.length)], "}");
  assert.equal(r.text, "fn main() -> !int {\n    let x = 1\n}");
});

/* ------------------------------------------------------------------ */
/* enter                                                               */
/* ------------------------------------------------------------------ */

test("enter: carries the leading whitespace", () => {
  const { text, pos } = at("    let x = 1|");
  const r = enter(text, [cursor(pos)]);
  assert.equal(r.text, "    let x = 1\n    ");
  assert.deepEqual(r.cursors, [cursor(r.text.length)]);
});

test("enter: a {-suffixed line indents one step", () => {
  const { text, pos } = at("fn main() -> !int {|");
  const r = enter(text, [cursor(pos)]);
  assert.equal(r.text, `fn main() -> !int {\n${INDENT}`);
});

test("enter: between the braces, the pair splits", () => {
  const { text, pos } = at("fn main() -> !int {|}");
  const r = enter(text, [cursor(pos)]);
  assert.equal(r.text, `fn main() -> !int {\n${INDENT}\n}`);
  assert.deepEqual(r.cursors, [cursor(`fn main() -> !int {\n${INDENT}`.length)]);
});

test("enter: a { inside a string does not indent", () => {
  const { text, pos } = at('let s = "a {|'); // unterminated string: still a string
  const r = enter(text, [cursor(pos)]);
  assert.equal(r.text, 'let s = "a {\n');
});

/* ------------------------------------------------------------------ */
/* deletion                                                            */
/* ------------------------------------------------------------------ */

test("backspace: an empty pair goes together", () => {
  const { text, pos } = at("let x = (|)");
  const r = backspace(text, [cursor(pos)]);
  assert.equal(r.text, "let x = ");
});

test("backspace: leading whitespace backs up one stop", () => {
  const { text, pos } = at("      |let");
  const r = backspace(text, [cursor(pos)]);
  assert.equal(r.text, "    let");
  assert.deepEqual(r.cursors, [cursor(4)]);
});

test("backspace: one code point, even an astral one", () => {
  const r = backspace("a🐺", [cursor(3)]);
  assert.equal(r.text, "a");
});

test("delete forward: a selection or one code point", () => {
  assert.equal(deleteForward("abc", [cursor(1)]).text, "ac");
  assert.equal(deleteForward("a🐺b", [cursor(1)]).text, "ab");
  assert.equal(deleteForward("abc", [cursor(0, 2)]).text, "c");
});

/* ------------------------------------------------------------------ */
/* goal columns                                                        */
/* ------------------------------------------------------------------ */

test("goal columns: a short line does not forget the target", () => {
  const text = "a long enough line\nab\nanother long line";
  const start = 8; // column 8 on line 1
  let state = moveVertical(text, [cursor(start)], null, +1);
  // line 2 is short: the caret lands at its end…
  assert.equal(state.cursors[0].head, text.indexOf("ab") + 2);
  state = moveVertical(text, state.cursors, state.goals, +1);
  // …and line 3 restores column 8.
  const line3 = text.indexOf("another");
  assert.equal(state.cursors[0].head, line3 + 8);
});

test("goal columns: up from the first line goes to the start", () => {
  const state = moveVertical("abc\ndef", [cursor(2)], null, -1);
  assert.equal(state.cursors[0].head, 0);
});

test("visual columns treat a tab as a 4-stop", () => {
  assert.equal(visualCol("\tx", 2), 5);
  assert.equal(posAtVisualCol("\tx", 0, 4), 1);
});

test("home: first ink, then column zero", () => {
  const { text, pos } = at("    let |x = 1");
  const first = home(text, [cursor(pos)]);
  assert.equal(first[0].head, 4);
  const second = home(text, first);
  assert.equal(second[0].head, 0);
});

test("end: end of line for every cursor", () => {
  const text = "ab\ncdef";
  const r = end(text, [cursor(0), cursor(4)]);
  assert.deepEqual(r.map((c) => c.head), [2, 7]);
});

/* ------------------------------------------------------------------ */
/* multiple cursors                                                    */
/* ------------------------------------------------------------------ */

test("add cursor below, then typing lands at both", () => {
  const text = "let a = 1\nlet b = 2";
  const grown = addCursorVertical(text, [cursor(4)], null, +1);
  assert.equal(grown.cursors.length, 2);
  assert.deepEqual(grown.cursors.map((c) => c.head), [4, 14]);
  const typed = type(text, grown.cursors, "x");
  assert.equal(typed.text, "let xa = 1\nlet xb = 2");
  assert.deepEqual(typed.cursors.map((c) => c.head), [5, 16]);
});

test("add cursor above mirrors, with the goal column", () => {
  const text = "short\na much longer line";
  const grown = addCursorVertical(text, [cursor(6 + 12)], null, -1);
  assert.equal(grown.cursors.length, 2);
  // line 1 is shorter than column 12: the new cursor clamps to its end
  assert.equal(grown.cursors[0].head, 5);
});

test("add cursor below at the last line adds nothing", () => {
  const grown = addCursorVertical("one line", [cursor(3)], null, +1);
  assert.equal(grown.cursors.length, 1);
});

test("backspace applies at every cursor as one edit", () => {
  const r = backspace("aXb\ncXd", [cursor(2), cursor(6)]);
  assert.equal(r.text, "ab\ncd");
  assert.deepEqual(r.cursors.map((c) => c.head), [1, 4]);
});

test("escape collapses to the primary", () => {
  const collapsed = collapseToPrimary([cursor(1), cursor(5), cursor(9, 12)]);
  assert.deepEqual(collapsed, [cursor(12)]);
});

test("paste: line-per-cursor when the counts match", () => {
  const text = "a\nb\nc";
  const r = paste(text, [cursor(1), cursor(3), cursor(5)], "1\n2\n3");
  assert.equal(r.text, "a1\nb2\nc3");
});

test("paste: whole clipboard at each cursor when they do not", () => {
  const r = paste("a\nb", [cursor(1), cursor(3)], "1\n2\n3");
  assert.equal(r.text, "a1\n2\n3\nb1\n2\n3");
});

test("paste: a single cursor takes the whole clipboard", () => {
  const r = paste("ab", [cursor(1)], "1\n2");
  assert.equal(r.text, "a1\n2b");
});

test("ctrl+d: word first, then the next occurrence", () => {
  const text = "let who = 1\nprint(who)\nwho";
  const first = addNextOccurrence(text, [cursor(5)]);
  assert.deepEqual(first.cursors, [cursor(4, 7)]);
  const second = addNextOccurrence(text, first.cursors);
  assert.equal(second.cursors.length, 2);
  assert.equal(second.cursors[1].anchor, text.indexOf("who", 8));
  const third = addNextOccurrence(text, second.cursors);
  assert.equal(third.cursors.length, 3);
});

test("normalize: overlapping cursors merge, duplicates drop", () => {
  assert.equal(normalize([cursor(3), cursor(3)]).length, 1);
  assert.equal(normalize([cursor(1, 5), cursor(4, 8)]).length, 1);
});

/* ------------------------------------------------------------------ */
/* block indent and comments                                           */
/* ------------------------------------------------------------------ */

test("tab: a bare caret pads to the next 4-stop", () => {
  const r = tabInsert("ab", [cursor(2)]);
  assert.equal(r.text, "ab  ");
});

test("indent and dedent every touched line", () => {
  const text = "one\ntwo\nthree";
  const indented = indentLines(text, [cursor(1, 9)]);
  assert.equal(indented.text, "    one\n    two\n    three");
  const back = dedentLines(indented.text, indented.cursors);
  assert.equal(back.text, text);
});

test("indent with two cursors touches both lines once each", () => {
  const r = indentLines("a\nb", [cursor(0), cursor(2)]);
  assert.equal(r.text, "    a\n    b");
});

test("ctrl+/: comments align at the shallowest indent, and back", () => {
  const text = "    let a = 1\n        let b = 2";
  const on = toggleComment(text, [cursor(0, text.length)]);
  assert.equal(on.text, "    // let a = 1\n    //     let b = 2");
  const off = toggleComment(on.text, [cursor(0, on.text.length)]);
  assert.equal(off.text, text);
});

test("ctrl+/: mixed lines all gain comments", () => {
  const text = "// a\nb";
  const r = toggleComment(text, [cursor(0, text.length)]);
  assert.equal(r.text, "// // a\n// b");
});

/* ------------------------------------------------------------------ */
/* undo coalescing                                                     */
/* ------------------------------------------------------------------ */

test("coalescing: a typed word is one step, the space after it is not", () => {
  const a = { kind: "type", ch: "w", cursorCount: 1 };
  const b = { kind: "type", ch: "o", cursorCount: 1 };
  const c = { kind: "type", ch: " ", cursorCount: 1 };
  assert.equal(coalesces(a, b), true);
  assert.equal(coalesces(b, c), false);
  assert.equal(coalesces(c, { kind: "type", ch: " ", cursorCount: 1 }), true);
});

test("coalescing: backspaces run together, kinds never mix", () => {
  const bs = { kind: "backspace", cursorCount: 1 };
  assert.equal(coalesces(bs, { kind: "backspace", cursorCount: 1 }), true);
  assert.equal(coalesces(bs, { kind: "type", ch: "a", cursorCount: 1 }), false);
  assert.equal(coalesces(null, bs), false);
});

test("coalescing: a cursor-count change breaks the run", () => {
  const one = { kind: "type", ch: "a", cursorCount: 1 };
  const two = { kind: "type", ch: "b", cursorCount: 2 };
  assert.equal(coalesces(one, two), false);
});

/* ------------------------------------------------------------------ */
/* the whole dance: a small session                                    */
/* ------------------------------------------------------------------ */

test("session: typing a wolf function with the manners on", () => {
  let text = "";
  let cursors = [cursor(0)];
  const typeAll = (s) => {
    for (const ch of s) ({ text, cursors } = type(text, cursors, ch));
  };
  typeAll("fn main() -> !int {");
  // the ( paired and was typed over; the { paired
  assert.equal(text, "fn main() -> !int {}");
  ({ text, cursors } = enter(text, cursors));
  assert.equal(text, "fn main() -> !int {\n    \n}");
  typeAll('print("hi, {who}")');
  // the quote paired, the interpolation brace paired inside it,
  // and every closer was typed over rather than doubled
  assert.equal(text, 'fn main() -> !int {\n    print("hi, {who}")\n}');
});
