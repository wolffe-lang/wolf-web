/* Integration tests for editor.js — the DOM half — under node, against a
 * shim just deep enough to stand in for the textarea, the gutter and the
 * caret mirror. What the pure-core tests cannot see, these do: the event
 * routing, the undo stack and its coalescing, the mirror's marks, and the
 * primary selection landing back in the textarea.
 *
 * node exposes `navigator` (the MAC detection reads navigator.platform);
 * `document` is shimmed below before editor.js ever calls into it.
 */
import { test } from "node:test";
import assert from "node:assert/strict";

/* ------------------------------------------------------------------ */
/* the shim                                                            */
/* ------------------------------------------------------------------ */

function makeNode(tag) {
  return {
    tag,
    className: "",
    children: [],
    _text: "",
    get textContent() {
      if (this.children.length === 0) return this._text;
      return this.children.map((c) => c.textContent ?? c._text ?? "").join("");
    },
    set textContent(v) {
      this._text = v;
      this.children = [];
    },
    append(...nodes) {
      this.children.push(...nodes);
    },
    classList: {
      _set: new Set(),
      add(c) {
        this._set.add(c);
      },
      remove(c) {
        this._set.delete(c);
      },
      contains(c) {
        return this._set.has(c);
      },
    },
  };
}

function makeTextarea() {
  const node = makeNode("textarea");
  Object.assign(node, {
    value: "",
    selectionStart: 0,
    selectionEnd: 0,
    scrollHeight: 0,
    scrollLeft: 0,
    scrollWidth: 0,
    clientWidth: 100,
    style: {},
    handlers: {},
    addEventListener(kind, fn) {
      (this.handlers[kind] ??= []).push(fn);
    },
    setSelectionRange(a, b) {
      this.selectionStart = a;
      this.selectionEnd = b;
    },
    fire(kind, props = {}) {
      const event = {
        defaultPrevented: false,
        preventDefault() {
          this.defaultPrevented = true;
        },
        ctrlKey: false,
        metaKey: false,
        altKey: false,
        shiftKey: false,
        isComposing: false,
        ...props,
      };
      for (const fn of this.handlers[kind] ?? []) fn(event);
      return event;
    },
  });
  return node;
}

const textarea = makeTextarea();
const documentHandlers = {};
globalThis.document = {
  createElement: makeNode,
  createTextNode: (text) => ({ _text: text, textContent: text }),
  activeElement: textarea,
  addEventListener(kind, fn) {
    (documentHandlers[kind] ??= []).push(fn);
  },
};

const { attachEditor } = await import("../site/play/editor.js");

const MAC = /Mac|iPhone|iPad/.test(navigator.platform);
const MOD = MAC ? { metaKey: true } : { ctrlKey: true };

let ran = 0;
const gutter = makeNode("pre");
const caretLayer = makeNode("div");
const editor = attachEditor({
  textarea,
  gutter,
  caretLayer,
  onRun: () => {
    ran += 1;
  },
});

const press = (key, props = {}) => textarea.fire("keydown", { key, ...props });
const typeString = (s) => {
  for (const ch of s) press(ch);
};
const reset = (text = "") => {
  editor.setValue(text);
};
/* One macrotask: releases the editor's post-render `applying` guard, the
 * same way the browser's task queue would between a render and a click. */
const tick = () => new Promise((resolve) => setTimeout(resolve, 0));
/* A user placing the caret: the native move plus the selectionchange the
 * browser fires for it. */
async function setSel(a, b = a) {
  await tick();
  textarea.setSelectionRange(a, b);
  for (const fn of documentHandlers.selectionchange ?? []) fn();
}

/* ------------------------------------------------------------------ */
/* routing                                                             */
/* ------------------------------------------------------------------ */

test("typed keys route through the core: pairs appear in the textarea", () => {
  reset();
  typeString("fn f() {");
  assert.equal(textarea.value, "fn f() {}");
  press("Enter");
  assert.equal(textarea.value, "fn f() {\n    \n}");
  assert.equal(textarea.selectionStart, "fn f() {\n    ".length);
});

test("the gutter counts the lines", () => {
  reset("a\nb\nc");
  assert.equal(gutter.textContent, "1\n2\n3");
});

test("mod+Enter runs and edits nothing", () => {
  reset("x");
  const before = textarea.value;
  press("Enter", MOD);
  assert.equal(ran, 1);
  assert.equal(textarea.value, before);
});

/* ------------------------------------------------------------------ */
/* multiple cursors, through real events                               */
/* ------------------------------------------------------------------ */

test("ctrl+alt+down grows a column; typing lands at each; Esc collapses", async () => {
  reset("let a = 1\nlet b = 2");
  await setSel(4);
  textarea.fire("keydown", { key: "ArrowDown", altKey: true, ctrlKey: true });
  typeString("x");
  assert.equal(textarea.value, "let xa = 1\nlet xb = 2");
  /* The mirror carries the secondary caret; the primary is the native one. */
  assert.equal(caretLayer.classList.contains("hidden"), false);
  const marks = caretLayer.children.filter((c) => c.className === "mc-caret");
  assert.equal(marks.length, 1);
  press("Escape");
  assert.equal(caretLayer.classList.contains("hidden"), true);
  typeString("y");
  assert.equal(textarea.value.match(/y/g).length, 1);
});

test("paste distributes line-per-cursor when the counts match", async () => {
  reset("a\nb");
  await setSel(1);
  textarea.fire("keydown", { key: "ArrowDown", altKey: true, ctrlKey: true });
  textarea.fire("paste", {
    clipboardData: { getData: () => "1\n2" },
  });
  assert.equal(textarea.value, "a1\nb2");
});

/* ------------------------------------------------------------------ */
/* undo                                                                */
/* ------------------------------------------------------------------ */

test("a typed word undoes as one step; the next word is its own", () => {
  reset("");
  typeString("who let");
  /* Two steps by the coalescing rule: "who", then " let" — the space after
   * ink opens the next step and the word joins it. */
  press("z", MOD);
  assert.equal(textarea.value, "who");
  press("z", MOD);
  assert.equal(textarea.value, "");
});

test("a multi-cursor edit undoes as ONE step", async () => {
  reset("let a = 1\nlet b = 2");
  await setSel(4);
  textarea.fire("keydown", { key: "ArrowDown", altKey: true, ctrlKey: true });
  typeString("x");
  assert.equal(textarea.value, "let xa = 1\nlet xb = 2");
  press("z", MOD);
  assert.equal(textarea.value, "let a = 1\nlet b = 2");
});

test("redo brings a step back", () => {
  reset("");
  typeString("ab");
  press("z", MOD);
  assert.equal(textarea.value, "");
  press("z", { ...MOD, shiftKey: true });
  assert.equal(textarea.value, "ab");
});

/* ------------------------------------------------------------------ */
/* the supporting basics                                               */
/* ------------------------------------------------------------------ */

test("tab indents the caret to the next stop; shift+tab dedents the line", async () => {
  reset("ab");
  await setSel(2);
  press("Tab");
  assert.equal(textarea.value, "ab  ");
  reset("    ab");
  await setSel(6);
  press("Tab", { shiftKey: true });
  assert.equal(textarea.value, "ab");
});

test("mod+/ comments and uncomments", () => {
  reset("let a = 1");
  textarea.setSelectionRange(0, 0);
  press("/", MOD);
  assert.equal(textarea.value, "// let a = 1");
  press("/", MOD);
  assert.equal(textarea.value, "let a = 1");
});

test("mod+d selects the word, then adds the next occurrence", () => {
  reset("who and who");
  textarea.setSelectionRange(1, 1);
  press("d", MOD);
  assert.equal(textarea.selectionStart, 0);
  assert.equal(textarea.selectionEnd, 3);
  press("d", MOD);
  /* Two selections now: the primary (the second who) is native… */
  assert.equal(textarea.selectionStart, 8);
  /* …and the first shows in the mirror as a highlight. */
  const sels = caretLayer.children.filter((c) => c.className === "mc-sel");
  assert.equal(sels.length, 1);
  assert.equal(sels[0].textContent, "who");
});

test("goal columns survive keyboard travel over a short line", async () => {
  reset("a long enough line\nab\nanother long line");
  await setSel(8);
  press("ArrowDown");
  assert.equal(textarea.selectionStart, "a long enough line\nab".length);
  press("ArrowDown");
  assert.equal(textarea.selectionStart, "a long enough line\nab\n".length + 8);
});
