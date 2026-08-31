/* The editor's DOM half.
 *
 * The textarea stays the input surface on purpose: the browser keeps
 * providing the caret, the selection, IME composition, the context menu and
 * the accessibility tree, none of which this file wants to reimplement. What
 * a textarea cannot do is show more than one caret — so the extra cursors
 * live in a transparent mirror layered over it: the same text in the same
 * font, invisible except for the caret marks and selection highlights, which
 * line up with the textarea's glyphs by construction.
 *
 * Every decision in here is delegated to editor-core.js, which is pure and
 * tested headlessly. This file only routes events, keeps the undo stack, and
 * draws — with text nodes and classes, never markup strings, so there is
 * nothing here the CSP has to know about and no dependency to audit.
 */

import {
  cursor,
  normalize,
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
} from "./editor-core.js";

const MAC = /Mac|iPhone|iPad/.test(navigator.platform);

export function attachEditor({ textarea, gutter, caretLayer, onRun }) {
  let state = {
    text: textarea.value,
    cursors: [cursor(textarea.selectionStart, textarea.selectionEnd)],
    goals: null,
  };
  /* Undo: snapshots of the state BEFORE each step. `lastMeta` is what the
   * coalescing rule compares against; a step that coalesces reuses the
   * snapshot already on the stack, which is exactly what makes a typed word
   * one undo and a multi-cursor edit one undo (one op, one snapshot). */
  const undoStack = [];
  const redoStack = [];
  let lastMeta = null;
  let applying = false;
  let altClickCursors = null;

  const snapshot = () => ({
    text: state.text,
    cursors: state.cursors.map((c) => cursor(c.anchor, c.head)),
  });

  const primary = () => state.cursors[state.cursors.length - 1];

  /* ---------------------------------------------------------------- */
  /* drawing                                                           */
  /* ---------------------------------------------------------------- */

  function drawGutter() {
    const lines = state.text.split("\n").length;
    const numbers = new Array(lines);
    for (let i = 0; i < lines; i += 1) numbers[i] = i + 1;
    gutter.textContent = numbers.join("\n");
    /* The textarea grows to its content; the page is the only vertical
     * scroll context (wolf-web#2). */
    textarea.style.height = "auto";
    textarea.style.height = `${textarea.scrollHeight}px`;
  }

  /** The mirror: the whole text, transparent, with marks where the
   * secondary cursors sit. Built with createTextNode — no markup parsing. */
  function drawCarets() {
    caretLayer.textContent = "";
    if (state.cursors.length < 2) {
      caretLayer.classList.add("hidden");
      return;
    }
    caretLayer.classList.remove("hidden");
    const prim = primary();
    const marks = [];
    for (const c of state.cursors) {
      if (c === prim) continue; /* the native caret draws the primary */
      const from = Math.min(c.anchor, c.head);
      const to = Math.max(c.anchor, c.head);
      if (from !== to) marks.push({ at: from, end: to, kind: "sel" });
      marks.push({ at: c.head, end: c.head, kind: "caret" });
    }
    marks.sort((a, b) => a.at - b.at);
    let last = 0;
    for (const m of marks) {
      if (m.at > last) caretLayer.append(document.createTextNode(state.text.slice(last, m.at)));
      const span = document.createElement("span");
      span.className = m.kind === "sel" ? "mc-sel" : "mc-caret";
      if (m.kind === "sel") span.textContent = state.text.slice(m.at, m.end);
      caretLayer.append(span);
      last = Math.max(last, m.end);
    }
    caretLayer.append(document.createTextNode(state.text.slice(last)));
    caretLayer.scrollLeft = textarea.scrollLeft;
  }

  function render() {
    applying = true;
    if (textarea.value !== state.text) textarea.value = state.text;
    const prim = primary();
    textarea.setSelectionRange(
      Math.min(prim.anchor, prim.head),
      Math.max(prim.anchor, prim.head),
      prim.head < prim.anchor ? "backward" : "forward",
    );
    drawGutter();
    drawCarets();
    /* The flag holds through the selectionchange this render provokes;
     * released on the next tick so real user moves are seen again. */
    setTimeout(() => {
      applying = false;
    }, 0);
  }

  /* ---------------------------------------------------------------- */
  /* applying ops                                                      */
  /* ---------------------------------------------------------------- */

  /** One undoable step: snapshot (unless coalescing), run, redraw. */
  function apply(meta, run) {
    if (!coalesces(lastMeta, meta)) undoStack.push(snapshot());
    redoStack.length = 0;
    lastMeta = meta;
    const next = run(state.text, state.cursors, state.goals);
    state = {
      text: next.text ?? state.text,
      cursors: next.cursors ?? state.cursors,
      goals: next.goals ?? null,
    };
    render();
  }

  /** A cursor motion: no snapshot, no coalescing run survives it. */
  function move(run) {
    lastMeta = null;
    const next = run(state.text, state.cursors, state.goals);
    state = {
      text: state.text,
      cursors: next.cursors ?? next,
      goals: next.goals ?? null,
    };
    render();
  }

  function undo() {
    if (undoStack.length === 0) return;
    redoStack.push(snapshot());
    const prev = undoStack.pop();
    state = { text: prev.text, cursors: prev.cursors, goals: null };
    lastMeta = null;
    render();
  }

  function redo() {
    if (redoStack.length === 0) return;
    undoStack.push(snapshot());
    const next = redoStack.pop();
    state = { text: next.text, cursors: next.cursors, goals: null };
    lastMeta = null;
    render();
  }

  /** The textarea changed under us (IME, drop, autocomplete): adopt it. */
  function resync(kind) {
    undoStack.push(snapshot());
    redoStack.length = 0;
    lastMeta = { kind, cursorCount: 1 };
    state = {
      text: textarea.value,
      cursors: [cursor(textarea.selectionStart, textarea.selectionEnd)],
      goals: null,
    };
    render();
  }

  /* ---------------------------------------------------------------- */
  /* events                                                            */
  /* ---------------------------------------------------------------- */

  function onKeyDown(event) {
    if (event.isComposing) return;
    const mod = MAC ? event.metaKey : event.ctrlKey;
    const multi = state.cursors.length > 1;
    const meta = (kind, extra = {}) => ({ kind, cursorCount: state.cursors.length, ...extra });

    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault();
      onRun?.();
      return;
    }
    if (event.key === "Escape" && multi) {
      event.preventDefault();
      move((t, c) => ({ cursors: collapseToPrimary(c) }));
      return;
    }
    /* Ctrl+Alt+Up/Down adds a cursor (Cmd+Alt too, the macOS spelling). */
    if (
      (event.key === "ArrowUp" || event.key === "ArrowDown") &&
      event.altKey &&
      (event.ctrlKey || event.metaKey)
    ) {
      event.preventDefault();
      const dir = event.key === "ArrowUp" ? -1 : 1;
      move((t, c, g) => addCursorVertical(t, c, g, dir));
      return;
    }
    if ((event.key === "ArrowUp" || event.key === "ArrowDown") && !event.altKey && !mod) {
      event.preventDefault();
      const dir = event.key === "ArrowUp" ? -1 : 1;
      move((t, c, g) => moveVertical(t, c, g, dir, event.shiftKey));
      return;
    }
    if ((event.key === "ArrowLeft" || event.key === "ArrowRight") && multi && !mod && !event.altKey) {
      event.preventDefault();
      const dir = event.key === "ArrowLeft" ? -1 : 1;
      move((t, c) => ({
        cursors: normalize(
          c.map((cur) => {
            if (!event.shiftKey && cur.anchor !== cur.head) {
              const edge = dir < 0 ? Math.min(cur.anchor, cur.head) : Math.max(cur.anchor, cur.head);
              return cursor(edge);
            }
            const head = Math.max(0, Math.min(t.length, cur.head + dir));
            return cursor(event.shiftKey ? cur.anchor : head, head);
          }),
        ),
      }));
      return;
    }
    if (event.key === "Home" || (MAC && mod && event.key === "ArrowLeft")) {
      event.preventDefault();
      move((t, c) => home(t, c, event.shiftKey));
      return;
    }
    if (event.key === "End" || (MAC && mod && event.key === "ArrowRight")) {
      event.preventDefault();
      move((t, c) => end(t, c, event.shiftKey));
      return;
    }
    if (event.key === "Tab" && !mod && !event.altKey) {
      event.preventDefault();
      const bare =
        !event.shiftKey &&
        state.cursors.length === 1 &&
        state.cursors[0].anchor === state.cursors[0].head;
      apply(meta(event.shiftKey ? "dedent" : "indent"), (t, c) =>
        event.shiftKey ? dedentLines(t, c) : bare ? tabInsert(t, c) : indentLines(t, c),
      );
      return;
    }
    if (event.key === "/" && mod) {
      event.preventDefault();
      apply(meta("comment"), (t, c) => toggleComment(t, c));
      return;
    }
    if ((event.key === "d" || event.key === "D") && mod && !event.shiftKey && !event.altKey) {
      event.preventDefault();
      move((t, c) => addNextOccurrence(t, c));
      return;
    }
    if ((event.key === "z" || event.key === "Z") && mod) {
      event.preventDefault();
      if (event.shiftKey) redo();
      else undo();
      return;
    }
    if (event.key === "y" && event.ctrlKey && !MAC) {
      event.preventDefault();
      redo();
      return;
    }
    if (event.key === "Enter" && !mod && !event.altKey) {
      event.preventDefault();
      apply(meta("enter"), (t, c) => enter(t, c));
      return;
    }
    if (event.key === "Backspace" && !mod && !event.altKey) {
      event.preventDefault();
      apply(meta("backspace"), (t, c) => backspace(t, c));
      return;
    }
    if (event.key === "Delete" && !mod && !event.altKey) {
      event.preventDefault();
      apply(meta("delete"), (t, c) => deleteForward(t, c));
      return;
    }
    /* A printable character. Alt stays allowed: on macOS Option+key IS how
     * some characters are typed, and event.key already carries the result. */
    if (event.key.length === 1 && !event.ctrlKey && !event.metaKey) {
      event.preventDefault();
      apply(meta("type", { ch: event.key }), (t, c) => type(t, c, event.key));
    }
  }

  function onPaste(event) {
    const clip = event.clipboardData?.getData("text/plain");
    if (clip === undefined || clip === null) return;
    event.preventDefault();
    apply({ kind: "paste", cursorCount: state.cursors.length }, (t, c) => paste(t, c, clip));
  }

  /** Multi-cursor copy: the selections, top to bottom, one line each. */
  function onCopy(event) {
    if (state.cursors.length < 2) return;
    const pieces = state.cursors
      .filter((c) => c.anchor !== c.head)
      .map((c) => state.text.slice(Math.min(c.anchor, c.head), Math.max(c.anchor, c.head)));
    if (pieces.length === 0) return;
    event.preventDefault();
    event.clipboardData.setData("text/plain", pieces.join("\n"));
    if (event.type === "cut") {
      apply({ kind: "cut", cursorCount: state.cursors.length }, (t, c) =>
        paste(t, c, "")
      );
    }
  }

  /** A native caret move (click, drag). Adopt it; Alt+click adds instead. */
  function onSelectionChange() {
    if (applying || document.activeElement !== textarea) return;
    const from = textarea.selectionStart;
    const to = textarea.selectionEnd;
    const prim = primary();
    /* An echo of the primary is not a user move — a browser may re-fire
     * selectionchange after focus churn, and it must not cost the extra
     * cursors their lives. */
    if (
      Math.min(prim.anchor, prim.head) === from &&
      Math.max(prim.anchor, prim.head) === to
    ) {
      return;
    }
    if (altClickCursors) {
      const grown = normalize([...altClickCursors, cursor(from, to)]);
      altClickCursors = null;
      state = { text: state.text, cursors: grown, goals: null };
      lastMeta = null;
      render();
      return;
    }
    state = { text: state.text, cursors: [cursor(from, to)], goals: null };
    lastMeta = null;
    drawCarets();
  }

  textarea.addEventListener("keydown", onKeyDown);
  textarea.addEventListener("paste", onPaste);
  textarea.addEventListener("copy", onCopy);
  textarea.addEventListener("cut", onCopy);
  textarea.addEventListener("compositionend", () => {
    if (textarea.value !== state.text) resync("ime");
  });
  textarea.addEventListener("input", (event) => {
    /* Everything this file routes calls preventDefault first, so a real
     * input event means the browser edited the value natively. */
    if (!applying && !event.isComposing && textarea.value !== state.text) resync("native");
  });
  textarea.addEventListener("mousedown", (event) => {
    altClickCursors = event.altKey ? state.cursors.map((c) => cursor(c.anchor, c.head)) : null;
  });
  document.addEventListener("selectionchange", onSelectionChange);
  textarea.addEventListener("scroll", () => {
    caretLayer.scrollLeft = textarea.scrollLeft;
  });
  /* The page owns the vertical axis (wolf-web#2); shift+wheel and trackpad
   * deltaX pan the code (wolf-web#3). Plain vertical wheel falls through. */
  textarea.addEventListener(
    "wheel",
    (event) => {
      const dx = event.deltaX !== 0 ? event.deltaX : event.shiftKey ? event.deltaY : 0;
      if (dx === 0) return;
      if (textarea.scrollWidth <= textarea.clientWidth) return;
      textarea.scrollLeft += dx;
      event.preventDefault();
    },
    { passive: false },
  );

  render();

  return {
    getValue: () => state.text,
    setValue(text) {
      undoStack.push(snapshot());
      redoStack.length = 0;
      lastMeta = null;
      state = { text, cursors: [cursor(0)], goals: null };
      render();
    },
    refresh: render,
  };
}
