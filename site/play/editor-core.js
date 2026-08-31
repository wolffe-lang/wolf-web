/* The editor's mathematics, and none of its DOM.
 *
 * Every behavior the playground's editor has — auto-indent, brace and quote
 * pairing, goal columns, multiple cursors, block indent, line comments, the
 * undo-coalescing rule — is a pure function in this file over (text, cursors).
 * The DOM half (site/play/editor.js) routes events here and draws what comes
 * back; it decides nothing. That split is what makes the editor testable
 * without a browser: tests/editor-core.test.mjs runs this file under node.
 *
 * The lexical facts are wolf's, from spec/01-grammar.md at the pinned
 * wolf-lang: `//` comments; `"…"` f-strings whose `{…}` interpolation
 * re-enters code mode ({{ and }} are literal braces); `"""` multiline
 * strings, interpolation included; `r"…"`/`r#"…"#` raw strings and
 * IDENT-prefixed generalized literals, both without escapes or
 * interpolation; `'c'` char literals. The one behavior that makes this
 * wolf's editor and not a generic one: interpolation braces pair INSIDE
 * strings, because a `{` there opens code.
 *
 * Conventions: positions are UTF-16 offsets (the textarea's own coordinate
 * space); a cursor is {anchor, head} with head the caret end; `cursors` is
 * kept sorted by position and deduplicated. `wolf fmt`'s 4-space step is the
 * indent unit.
 */

export const INDENT = "    ";
const TAB = 4;

/* ------------------------------------------------------------------ */
/* cursors                                                             */
/* ------------------------------------------------------------------ */

export const cursor = (anchor, head = anchor) => ({ anchor, head });
const lo = (c) => Math.min(c.anchor, c.head);
const hi = (c) => Math.max(c.anchor, c.head);
const isEmpty = (c) => c.anchor === c.head;

/** Sorts by position and merges cursors that touch or overlap. */
export function normalize(cursors) {
  const sorted = [...cursors].sort((a, b) => lo(a) - lo(b) || hi(a) - hi(b));
  const out = [];
  for (const c of sorted) {
    const last = out[out.length - 1];
    if (last && lo(c) <= hi(last)) {
      if (isEmpty(c) && lo(c) === hi(last) && !isEmpty(last)) continue;
      if (isEmpty(last) && isEmpty(c)) continue;
      /* Overlapping selections merge into one spanning both. */
      const from = Math.min(lo(last), lo(c));
      const to = Math.max(hi(last), hi(c));
      out[out.length - 1] = cursor(from, to);
      continue;
    }
    out.push(cursor(c.anchor, c.head));
  }
  return out;
}

/* ------------------------------------------------------------------ */
/* lines and columns                                                   */
/* ------------------------------------------------------------------ */

export function lineStartAt(text, pos) {
  return text.lastIndexOf("\n", pos - 1) + 1;
}

export function lineEndAt(text, pos) {
  const at = text.indexOf("\n", pos);
  return at === -1 ? text.length : at;
}

/** The leading whitespace of the line containing `pos`. */
export function indentAt(text, pos) {
  const start = lineStartAt(text, pos);
  let end = start;
  while (end < text.length && (text[end] === " " || text[end] === "\t")) end += 1;
  return text.slice(start, end);
}

/**
 * The visual column of `pos` on its line, tabs advancing to the next
 * 4-column stop — the coordinate goal columns remember.
 */
export function visualCol(text, pos) {
  const start = lineStartAt(text, pos);
  let col = 0;
  for (let i = start; i < pos; i += 1) {
    col = text[i] === "\t" ? (Math.floor(col / TAB) + 1) * TAB : col + 1;
  }
  return col;
}

/** The position on the line starting at `lineStart` nearest visual column `goal`. */
export function posAtVisualCol(text, lineStart, goal) {
  const end = lineEndAt(text, lineStart);
  let col = 0;
  let i = lineStart;
  while (i < end && col < goal) {
    col = text[i] === "\t" ? (Math.floor(col / TAB) + 1) * TAB : col + 1;
    i += 1;
  }
  return i;
}

/* ------------------------------------------------------------------ */
/* the scanner: what is the text AT this position?                     */
/* ------------------------------------------------------------------ */

/**
 * Scans from the start of the text to `pos` with wolf's lexer modes and
 * answers two questions: which mode `pos` sits in, and which brackets are
 * open around it (each with the offset of its opener, for dedent-to-match).
 *
 * Mode is one of "code", "string" (plain or multiline), "raw", "char",
 * "comment". `frames` is the mode stack — an interpolation pushes "code"
 * back on top of "string", which is exactly why `{` pairs inside a string.
 * A whole-text scan per keystroke is deliberate: playground programs are
 * small, and one obviously-correct scanner beats an incremental one with
 * edge cases.
 */
export function scan(text, pos) {
  const frames = [{ mode: "code", brackets: [] }];
  const top = () => frames[frames.length - 1];
  const isIdent = (ch) => /[A-Za-z0-9_]/.test(ch || "");
  let i = 0;
  while (i < pos) {
    const frame = top();
    const ch = text[i];
    if (frame.mode === "comment") {
      if (ch === "\n") frames.pop();
      i += 1;
      continue;
    }
    if (frame.mode === "char") {
      if (ch === "\\") i += 2;
      else if (ch === "'" || ch === "\n") {
        frames.pop();
        i += 1;
      } else i += 1;
      continue;
    }
    if (frame.mode === "raw") {
      if (ch === '"' && text.startsWith(frame.fence, i + 1)) {
        frames.pop();
        i += 1 + frame.fence.length;
      } else i += 1;
      continue;
    }
    if (frame.mode === "string") {
      if (ch === "\\") i += 2;
      else if (ch === "{" && text[i + 1] === "{") i += 2;
      else if (ch === "}" && text[i + 1] === "}") i += 2;
      else if (ch === "{") {
        frames.push({ mode: "code", brackets: [] });
        i += 1;
      } else if (frame.multi && text.startsWith('"""', i)) {
        frames.pop();
        i += 3;
      } else if (!frame.multi && (ch === '"' || ch === "\n")) {
        frames.pop();
        i += 1;
      } else i += 1;
      continue;
    }
    /* code */
    if (ch === "/" && text[i + 1] === "/") {
      frames.push({ mode: "comment" });
      i += 2;
    } else if (ch === '"') {
      const multi = text.startsWith('"""', i);
      /* IDENT" with no gap is a generalized literal: raw-mode body. An
       * r-prefix with #-fences is the spelled raw string. */
      if (!multi && isIdent(text[i - 1])) {
        let fences = 0;
        let back = i - 1;
        if (text[back] === "#") {
          while (text[back] === "#") {
            fences += 1;
            back -= 1;
          }
        }
        frames.push({ mode: "raw", fence: "#".repeat(fences) });
        i += 1;
      } else {
        frames.push({ mode: "string", multi });
        i += multi ? 3 : 1;
      }
    } else if (ch === "#" && isIdent(text[i - 1])) {
      /* r#"…"# — consume the fence run; the quote branch above sees the
       * ident through the #s. Only a fence if a quote follows. */
      let j = i;
      while (text[j] === "#") j += 1;
      if (text[j] === '"') {
        frames.push({ mode: "raw", fence: text.slice(i, j) });
        i = j + 1;
      } else i += 1;
    } else if (ch === "'") {
      frames.push({ mode: "char" });
      i += 1;
    } else if (ch === "(" || ch === "[" || ch === "{") {
      frame.brackets.push({ ch, pos: i });
      i += 1;
    } else if (ch === ")" || ch === "]") {
      if (frame.brackets.length > 0) frame.brackets.pop();
      i += 1;
    } else if (ch === "}") {
      if (frame.brackets.length > 0) frame.brackets.pop();
      else if (frames.length > 1) frames.pop(); /* closes the interpolation */
      i += 1;
    } else i += 1;
  }
  const frame = top();
  return {
    mode: frame.mode,
    inInterp: frame.mode === "code" && frames.length > 1,
    brackets: frame.mode === "code" ? [...frame.brackets] : [],
  };
}

/* ------------------------------------------------------------------ */
/* applying one edit per cursor                                        */
/* ------------------------------------------------------------------ */

/**
 * Applies one replacement per cursor in a single pass and returns the new
 * text with the new cursors. `plan(c, i)` maps a cursor to
 * {from, to, insert, caret} in OLD coordinates (caret relative to `from`
 * after insertion; a caret of null means from + insert.length). One call =
 * one undo step, however many cursors — the coalescing rule never has to
 * know about cursor count.
 */
export function applyPerCursor(text, cursors, plan) {
  const parts = [];
  const out = [];
  let last = 0;
  let delta = 0;
  normalize(cursors).forEach((c, i) => {
    const edit = plan(c, i) || { from: hi(c), to: hi(c), insert: "", caret: 0 };
    const from = Math.max(edit.from, last);
    const to = Math.max(edit.to, from);
    parts.push(text.slice(last, from), edit.insert);
    const caret =
      from + delta + (edit.caret === null || edit.caret === undefined
        ? edit.insert.length
        : edit.caret);
    out.push(
      edit.select
        ? cursor(caret, caret + edit.select)
        : cursor(caret),
    );
    delta += edit.insert.length - (to - from);
    last = to;
  });
  parts.push(text.slice(last));
  return { text: parts.join(""), cursors: normalize(out) };
}

/* ------------------------------------------------------------------ */
/* typing, with pairs                                                  */
/* ------------------------------------------------------------------ */

const PAIRS = { "(": ")", "[": "]", "{": "}", '"': '"', "'": "'" };
const CLOSERS = new Set([")", "]", "}", '"', "'"]);

/** Auto-close only when what follows would not glue to the closer. */
function closable(text, at) {
  const next = text[at];
  return next === undefined || /[\s)\]}.,;:"']/.test(next);
}

/**
 * One typed character at every cursor. Pairing:
 *  - an opener with a selection wraps it;
 *  - an opener in code inserts its pair (when the next character permits);
 *  - `{` inside a string opens an interpolation, so it pairs there too —
 *    the wolf-specific case;
 *  - a closer types over an identical character to its right;
 *  - a lone closer on a whitespace-only line first dedents the line to its
 *    opener's indent (wolf's brace style);
 *  - quotes pair in code, type over their own closer, and never pair in
 *    comments, raw strings, or char literals.
 */
export function type(text, cursors, ch) {
  return applyPerCursor(text, cursors, (c) => {
    const from = lo(c);
    const to = hi(c);
    const ctx = scan(text, from);

    /* Wrap a selection in the typed pair. */
    if (from !== to && PAIRS[ch]) {
      const inner = text.slice(from, to);
      return { from, to, insert: ch + inner + PAIRS[ch], caret: 1, select: inner.length };
    }

    const pairsHere =
      ctx.mode === "code" ||
      ((ctx.mode === "string") && ch === "{");

    /* Type over an identical closer. */
    if (CLOSERS.has(ch) && text[to] === ch) {
      const overInString =
        ctx.mode === "string" && (ch === "}" || ch === '"');
      if (ctx.mode === "code" || overInString) {
        return { from: to, to, insert: "", caret: 1 };
      }
    }

    /* A closer on a whitespace-only line dedents to its opener's line. */
    if ((ch === "}" || ch === ")" || ch === "]") && ctx.mode === "code") {
      const start = lineStartAt(text, from);
      if (/^[ \t]*$/.test(text.slice(start, from))) {
        const want = { ")": "(", "]": "[", "}": "{" }[ch];
        const opener = [...ctx.brackets].reverse().find((b) => b.ch === want);
        if (opener) {
          const indent = indentAt(text, opener.pos);
          return { from: start, to, insert: indent + ch, caret: indent.length + 1 };
        }
      }
    }

    if ((ch === "(" || ch === "[" || ch === "{") && pairsHere && closable(text, to)) {
      return { from, to, insert: ch + PAIRS[ch], caret: 1 };
    }
    if ((ch === '"' || ch === "'") && ctx.mode === "code" && closable(text, to)) {
      /* A quote right after an identifier is a generalized literal opener
       * (re"…"), which is raw and closes itself differently; pair anyway —
       * the closer is still the same character. But after a backslash or
       * inside nothing typable, just insert. */
      return { from, to, insert: ch + ch, caret: 1 };
    }
    return { from, to, insert: ch, caret: null };
  });
}

/* ------------------------------------------------------------------ */
/* enter, with auto-indent                                             */
/* ------------------------------------------------------------------ */

/**
 * Enter at every cursor: carry the line's leading whitespace; one more
 * step after a line that ends (at the caret) with an opener; and when the
 * very next character is that opener's closer, split the pair — body line
 * indented one step, closer moved to its own line at the original indent.
 */
export function enter(text, cursors) {
  return applyPerCursor(text, cursors, (c) => {
    const from = lo(c);
    const to = hi(c);
    const indent = indentAt(text, from);
    const before = text.slice(lineStartAt(text, from), from);
    const ctx = scan(text, from);
    const opener = /[{([]\s*$/.exec(before)?.[0]?.trimEnd();
    /* Not inside an interpolation: a plain string ends at its line, so
     * splitting one across lines must not also indent the wreckage. */
    if (ctx.mode === "code" && !ctx.inInterp && opener) {
      const closer = PAIRS[opener];
      if (text[to] === closer) {
        const insert = `\n${indent}${INDENT}\n${indent}`;
        return { from, to, insert, caret: 1 + indent.length + INDENT.length };
      }
      return { from, to, insert: `\n${indent}${INDENT}`, caret: null };
    }
    return { from, to, insert: `\n${indent}`, caret: null };
  });
}

/* ------------------------------------------------------------------ */
/* deletion                                                            */
/* ------------------------------------------------------------------ */

const lowSurrogate = (ch) => ch >= "\udc00" && ch <= "\udfff";

/**
 * Backspace at every cursor: a selection deletes itself; a caret between
 * the two halves of an empty pair removes both; a caret inside leading
 * whitespace backs up to the previous 4-column stop; otherwise one code
 * point goes.
 */
export function backspace(text, cursors) {
  return applyPerCursor(text, cursors, (c) => {
    const from = lo(c);
    const to = hi(c);
    if (from !== to) return { from, to, insert: "", caret: 0 };
    if (from === 0) return { from, to, insert: "", caret: 0 };
    const prev = text[from - 1];
    if (PAIRS[prev] === text[from] && text[from] !== undefined) {
      return { from: from - 1, to: from + 1, insert: "", caret: 0 };
    }
    const start = lineStartAt(text, from);
    if (from > start && /^[ ]+$/.test(text.slice(start, from))) {
      const col = from - start;
      const back = col % TAB === 0 ? TAB : col % TAB;
      return { from: from - back, to: from, insert: "", caret: 0 };
    }
    const width = lowSurrogate(prev) && from >= 2 ? 2 : 1;
    return { from: from - width, to: from, insert: "", caret: 0 };
  });
}

/** Delete forward: a selection, or one code point. */
export function deleteForward(text, cursors) {
  return applyPerCursor(text, cursors, (c) => {
    const from = lo(c);
    const to = hi(c);
    if (from !== to) return { from, to, insert: "", caret: 0 };
    if (from >= text.length) return { from, to, insert: "", caret: 0 };
    const cp = text.codePointAt(from);
    return { from, to: from + (cp > 0xffff ? 2 : 1), insert: "", caret: 0 };
  });
}

/* ------------------------------------------------------------------ */
/* movement: goal columns, home/end, added cursors                     */
/* ------------------------------------------------------------------ */

/**
 * Vertical movement for every cursor, remembering goal columns. `goals`
 * parallels `cursors` (null = derive from the current column). Returns
 * {cursors, goals}; the text never changes. At the first line Up goes to
 * the start, at the last line Down goes to the end — and the goal survives
 * both, which is the classic.
 */
export function moveVertical(text, cursors, goals, dir, extend = false) {
  const outC = [];
  const outG = [];
  cursors.forEach((c, i) => {
    const head = c.head;
    const goal = goals?.[i] ?? visualCol(text, head);
    const start = lineStartAt(text, head);
    let target;
    if (dir < 0) {
      if (start === 0) target = 0;
      else target = posAtVisualCol(text, lineStartAt(text, start - 1), goal);
    } else {
      const end = lineEndAt(text, head);
      if (end === text.length) target = text.length;
      else target = posAtVisualCol(text, end + 1, goal);
    }
    outC.push(cursor(extend ? c.anchor : target, target));
    outG.push(goal);
  });
  /* Two cursors that collapse onto one line merge; their goals follow. */
  const merged = normalize(outC);
  const mergedGoals =
    merged.length === outC.length
      ? outG
      : merged.map((m) => outG[outC.findIndex((c) => c.head === m.head)] ?? null);
  return { cursors: merged, goals: mergedGoals };
}

/** Home: first non-whitespace, or column 0 when already there. */
export function home(text, cursors, extend = false) {
  return normalize(
    cursors.map((c) => {
      const start = lineStartAt(text, c.head);
      let firstInk = start;
      const end = lineEndAt(text, c.head);
      while (firstInk < end && (text[firstInk] === " " || text[firstInk] === "\t")) firstInk += 1;
      const target = c.head === firstInk ? start : firstInk;
      return cursor(extend ? c.anchor : target, target);
    }),
  );
}

/** End of line for every cursor. */
export function end(text, cursors, extend = false) {
  return normalize(
    cursors.map((c) => {
      const target = lineEndAt(text, c.head);
      return cursor(extend ? c.anchor : target, target);
    }),
  );
}

/**
 * Ctrl+Alt+Down grows the column: one new cursor on the line below the
 * bottom cursor, at the bottom cursor's goal column (Up mirrors, above the
 * top). The originals stay. Returns {cursors, goals} unchanged when there
 * is no line to grow into.
 */
export function addCursorVertical(text, cursors, goals, dir) {
  const edgeIndex = dir < 0 ? 0 : cursors.length - 1;
  const edge = cursors[edgeIndex];
  const goal = goals?.[edgeIndex] ?? visualCol(text, edge.head);
  const start = lineStartAt(text, edge.head);
  let target = null;
  if (dir < 0 && start > 0) {
    target = posAtVisualCol(text, lineStartAt(text, start - 1), goal);
  } else if (dir > 0) {
    const lineEnd = lineEndAt(text, edge.head);
    if (lineEnd < text.length) target = posAtVisualCol(text, lineEnd + 1, goal);
  }
  if (target === null) return { cursors, goals: goals ?? cursors.map(() => goal) };
  const outC = [...cursors, cursor(target)];
  const outG = [...(goals ?? cursors.map((c) => visualCol(text, c.head))), goal];
  const order = outC
    .map((c, i) => ({ c, g: outG[i] }))
    .sort((a, b) => lo(a.c) - lo(b.c));
  const merged = normalize(order.map((o) => o.c));
  return {
    cursors: merged,
    goals: merged.map((m) => order.find((o) => o.c.head === m.head)?.g ?? null),
  };
}

/* ------------------------------------------------------------------ */
/* block indent, comments, paste, occurrences                          */
/* ------------------------------------------------------------------ */

/** The start offsets of every line any cursor touches, each once. */
function touchedLineStarts(text, cursors) {
  const starts = new Set();
  for (const c of cursors) {
    let at = lineStartAt(text, lo(c));
    const stop = hi(c);
    while (true) {
      starts.add(at);
      const nl = text.indexOf("\n", at);
      if (nl === -1 || nl >= stop) break;
      at = nl + 1;
    }
  }
  return [...starts].sort((a, b) => a - b);
}

/** Replaces line prefixes and remaps the cursors across the deltas. */
function editLines(text, cursors, edits) {
  /* edits: [{at, remove, insert}] sorted by at, non-overlapping. */
  let out = "";
  let last = 0;
  for (const e of edits) {
    out += text.slice(last, e.at) + e.insert;
    last = e.at + e.remove;
  }
  out += text.slice(last);
  const remap = (pos) => {
    let delta = 0;
    for (const e of edits) {
      if (pos <= e.at) break;
      const removedEnd = e.at + e.remove;
      if (pos < removedEnd) return e.at + delta + e.insert.length;
      delta += e.insert.length - e.remove;
    }
    return pos + delta;
  };
  return {
    text: out,
    cursors: normalize(cursors.map((c) => cursor(remap(c.anchor), remap(c.head)))),
  };
}

/** Tab with a selection or several cursors: every touched line, one step in. */
export function indentLines(text, cursors) {
  const edits = touchedLineStarts(text, cursors)
    .filter((at) => text[at] !== "\n" && at !== text.length)
    .map((at) => ({ at, remove: 0, insert: INDENT }));
  return editLines(text, cursors, edits);
}

/** Shift+Tab: up to one step of leading spaces off every touched line. */
export function dedentLines(text, cursors) {
  const edits = [];
  for (const at of touchedLineStarts(text, cursors)) {
    const m = /^ {1,4}/.exec(text.slice(at, lineEndAt(text, at)));
    if (m) edits.push({ at, remove: m[0].length, insert: "" });
  }
  return editLines(text, cursors, edits);
}

/** Tab with a single bare caret: spaces to the next 4-column stop. */
export function tabInsert(text, cursors) {
  return applyPerCursor(text, cursors, (c) => {
    const pad = TAB - (visualCol(text, lo(c)) % TAB);
    return { from: lo(c), to: hi(c), insert: " ".repeat(pad), caret: null };
  });
}

/**
 * Ctrl+/: if every non-blank touched line is commented, uncomment them
 * all; otherwise comment them all with `// ` at the shallowest indent.
 */
export function toggleComment(text, cursors) {
  const starts = touchedLineStarts(text, cursors);
  const lines = starts.map((at) => ({
    at,
    body: text.slice(at, lineEndAt(text, at)),
  }));
  const inked = lines.filter((l) => l.body.trim() !== "");
  if (inked.length === 0) return { text, cursors: normalize(cursors) };
  const allCommented = inked.every((l) => /^\s*\/\//.test(l.body));
  const edits = [];
  if (allCommented) {
    for (const l of inked) {
      const m = /^(\s*)\/\/ ?/.exec(l.body);
      edits.push({ at: l.at + m[1].length, remove: m[0].length - m[1].length, insert: "" });
    }
  } else {
    const depth = Math.min(...inked.map((l) => /^[ \t]*/.exec(l.body)[0].length));
    for (const l of inked) {
      edits.push({ at: l.at + depth, remove: 0, insert: "// " });
    }
  }
  return editLines(text, cursors, edits);
}

/**
 * Paste. The VSCode rule: when the clipboard has exactly as many lines as
 * there are cursors (and more than one), each cursor takes its line;
 * otherwise every cursor takes the whole clipboard.
 */
export function paste(text, cursors, clip) {
  const norm = normalize(cursors);
  const lines = clip.split(/\r\n|\r|\n/);
  const perCursor = norm.length > 1 && lines.length === norm.length;
  return applyPerCursor(text, norm, (c, i) => ({
    from: lo(c),
    to: hi(c),
    insert: perCursor ? lines[i] : clip.replace(/\r\n|\r/g, "\n"),
    caret: null,
  }));
}

const wordChar = (ch) => /[A-Za-z0-9_]/.test(ch || "");

/**
 * Ctrl+D. With an empty primary selection: select the word under the last
 * cursor. With a selection: add a cursor selecting the next occurrence
 * (wrapping), if one exists that no cursor already holds.
 */
export function addNextOccurrence(text, cursors) {
  const norm = normalize(cursors);
  const primary = norm[norm.length - 1];
  if (isEmpty(primary)) {
    let from = primary.head;
    let to = primary.head;
    while (from > 0 && wordChar(text[from - 1])) from -= 1;
    while (to < text.length && wordChar(text[to])) to += 1;
    if (from === to) return { cursors: norm };
    return { cursors: normalize([...norm.slice(0, -1), cursor(from, to)]) };
  }
  const needle = text.slice(lo(primary), hi(primary));
  if (needle === "" || needle.includes("\n")) return { cursors: norm };
  const taken = new Set(norm.map((c) => lo(c)));
  let at = text.indexOf(needle, hi(primary));
  while (at !== -1 && taken.has(at)) at = text.indexOf(needle, at + 1);
  if (at === -1) {
    at = text.indexOf(needle);
    while (at !== -1 && (taken.has(at) || at >= lo(primary))) at = text.indexOf(needle, at + 1);
  }
  if (at === -1) return { cursors: norm };
  return { cursors: normalize([...norm, cursor(at, at + needle.length)]) };
}

/** Esc: back to one cursor — the last one, selection collapsed to its head. */
export function collapseToPrimary(cursors) {
  const primary = cursors[cursors.length - 1] ?? cursor(0);
  return [cursor(primary.head)];
}

/* ------------------------------------------------------------------ */
/* undo coalescing                                                     */
/* ------------------------------------------------------------------ */

/**
 * Whether an edit joins the previous one as a single undo step. Runs of
 * typed characters coalesce until a word ends (a space after ink breaks),
 * runs of backspaces coalesce together; everything else — Enter, paste,
 * indent, comment, any cursor-count change — is its own step. A
 * multi-cursor edit is one step by construction (one applyPerCursor call),
 * so this rule never needs to know how many cursors there were.
 */
export function coalesces(prev, next) {
  if (!prev || prev.kind !== next.kind) return false;
  if (prev.cursorCount !== next.cursorCount) return false;
  if (next.kind === "type") {
    if (next.ch === undefined || next.ch.length !== 1) return false;
    return !(/\s/.test(next.ch) && prev.ch !== undefined && !/\s/.test(prev.ch));
  }
  return next.kind === "backspace" || next.kind === "delete";
}
