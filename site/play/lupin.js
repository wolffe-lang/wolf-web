/* The playground's glue.
 *
 * Everything this file knows about wolf it learned from the wasm module. It
 * moves UTF-8 in, reads JSON out, and draws the result. It parses no wolf, it
 * decides no verdicts, and when it cannot load the interpreter it says so
 * rather than sitting there looking broken.
 *
 * The ABI is documented in crates/lupin-wasm/src/lib.rs. In one sentence: a
 * result is a pointer to four bytes of little-endian length followed by that
 * many bytes of UTF-8 JSON, and the caller frees it.
 *
 * No bundler and no dependencies. The nginx CSP is `script-src 'self'
 * 'wasm-unsafe-eval'`, which admits this file and the module's compilation and
 * nothing else.
 */

const WASM_URL = "/play/lupin.wasm";
const SAMPLES_URL = "/play/samples/index.json";
const VERSION_URL = "/version.json";

/* Used when the sample index cannot be fetched. Kept to the one program whose
 * output is stated in the compiler's own README, so even the fallback is a
 * claim someone checks. */
const FALLBACK = `fn main() -> !int {
    let who = "wolf"
    print("hello, {who}")
    0
}
`;

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const el = (id) => document.getElementById(id);
const dom = {
  banner: el("banner"),
  bannerText: el("banner-text"),
  run: el("run"),
  record: el("record"),
  samples: el("samples"),
  source: el("source"),
  gutter: el("gutter"),
  provenance: el("provenance"),
  verdict: el("verdict"),
  stdout: el("stdout"),
  stderr: el("stderr"),
  span: el("span"),
  warnings: el("warnings"),
  recordJson: el("record-json"),
  outStdout: el("out-stdout"),
  outStderr: el("out-stderr"),
  outSpan: el("out-span"),
  outWarnings: el("out-warnings"),
  outRecord: el("out-record"),
};

/* ------------------------------------------------------------------ */
/* the module                                                          */
/* ------------------------------------------------------------------ */

/** The compiled module, kept so a trapped instance can be replaced. */
let compiled = null;
/** The live instance. Discarded and rebuilt after any trap. */
let exports = null;

/**
 * The URL to fetch the module from, with the build's interpreter pin on it.
 *
 * nginx caches `*.wasm` for seven days and this file is not fingerprinted, so a
 * visitor who came back after a deploy would run the module from before it. The
 * pin in `version.json` changes when the submodule moves, which is exactly when
 * the bytes change, and `version.json` is not in the hard-cached set. A build
 * with no version stamp falls through to the bare URL rather than failing:
 * a cached module is better than no playground.
 */
async function versionedWasmUrl() {
  try {
    const response = await fetch(VERSION_URL, { cache: "no-cache" });
    if (!response.ok) return WASM_URL;
    const stamp = await response.json();
    const pin = stamp.pins && stamp.pins["wolf-interp"];
    return pin ? `${WASM_URL}?pin=${encodeURIComponent(pin)}` : WASM_URL;
  } catch {
    return WASM_URL;
  }
}

async function load() {
  const url = await versionedWasmUrl();
  let response;
  try {
    response = await fetch(url);
  } catch (cause) {
    throw new Error(`the request for ${WASM_URL} failed (${cause.message})`);
  }
  if (!response.ok) {
    throw new Error(`${WASM_URL} answered ${response.status} ${response.statusText}`);
  }

  /* instantiateStreaming needs application/wasm on the response. nginx is
   * configured for it; a static file server that is not falls back here
   * instead of failing, because a working playground matters more than one
   * fewer copy of the bytes. */
  const type = response.headers.get("content-type") || "";
  if (type.includes("application/wasm") && WebAssembly.compileStreaming) {
    compiled = await WebAssembly.compileStreaming(response);
  } else {
    compiled = await WebAssembly.compile(await response.arrayBuffer());
  }

  /* The module imports nothing by design, and build-wasm.sh refuses to publish
   * one that does. If that ever changes, this is where it shows up. */
  const imports = WebAssembly.Module.imports(compiled);
  if (imports.length > 0) {
    const names = imports.map((i) => `${i.module}.${i.name}`).join(", ");
    throw new Error(`the module expects host functions this page cannot provide (${names})`);
  }

  instantiate();
}

function instantiate() {
  exports = new WebAssembly.Instance(compiled, {}).exports;
}

/** Fresh every time: the buffer detaches whenever linear memory grows. */
const memory = () => new Uint8Array(exports.memory.buffer);

/** Reads and frees a result buffer, returning the parsed JSON. */
function takeResult(pointer) {
  const view = memory();
  const length =
    view[pointer] |
    (view[pointer + 1] << 8) |
    (view[pointer + 2] << 16) |
    (view[pointer + 3] << 24);
  const text = decoder.decode(view.subarray(pointer + 4, pointer + 4 + length));
  exports.lupin_result_free(pointer);
  return JSON.parse(text);
}

/** Calls one of the observing exports with a source string. */
function call(name, source) {
  const bytes = encoder.encode(source);
  const pointer = exports.lupin_alloc(bytes.length);
  memory().set(bytes, pointer);
  try {
    return takeResult(exports[name](pointer, bytes.length));
  } finally {
    /* Reached even when the call trapped, and harmless then: the instance is
     * about to be thrown away and this write goes nowhere anyone reads. */
    exports.lupin_free(pointer, bytes.length);
  }
}

/* ------------------------------------------------------------------ */
/* the editor                                                          */
/* ------------------------------------------------------------------ */

function drawGutter() {
  const lines = dom.source.value.split("\n").length;
  const numbers = new Array(lines);
  for (let i = 0; i < lines; i += 1) numbers[i] = i + 1;
  dom.gutter.textContent = numbers.join("\n");
  // The textarea grows to its content, so the page is the only vertical
  // scroll context and gutter line N sits beside source line N by
  // construction — no scrollTop mirroring, nothing to desync (#2).
  dom.source.style.height = "auto";
  dom.source.style.height = `${dom.source.scrollHeight}px`;
}

/** Tab indents by four spaces. A textarea that moves focus instead is not an
 * editor, and wolf source is indented four. */
function onKeyDown(event) {
  if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
    event.preventDefault();
    run();
    return;
  }
  if (event.key !== "Tab" || event.ctrlKey || event.metaKey || event.altKey) return;
  event.preventDefault();
  const box = dom.source;
  const { selectionStart: from, selectionEnd: to, value } = box;

  if (from === to && !event.shiftKey) {
    box.value = `${value.slice(0, from)}    ${value.slice(to)}`;
    box.selectionStart = box.selectionEnd = from + 4;
    drawGutter();
    return;
  }

  /* A selection indents or outdents whole lines. */
  const start = value.lastIndexOf("\n", from - 1) + 1;
  const endBreak = value.indexOf("\n", to);
  const end = endBreak === -1 ? value.length : endBreak;
  const block = value.slice(start, end);
  const shifted = event.shiftKey
    ? block.replace(/^ {1,4}/gm, "")
    : block.replace(/^/gm, "    ");
  box.value = value.slice(0, start) + shifted + value.slice(end);
  box.selectionStart = start;
  box.selectionEnd = start + shifted.length;
  drawGutter();
}

/* ------------------------------------------------------------------ */
/* drawing an observation                                              */
/* ------------------------------------------------------------------ */

function show(box, pre, text) {
  if (text) {
    pre.textContent = text;
    box.classList.remove("hidden");
  } else {
    pre.textContent = "";
    box.classList.add("hidden");
  }
}

function clearOutput() {
  dom.verdict.classList.add("hidden");
  dom.verdict.textContent = "";
  for (const [box, pre] of [
    [dom.outStdout, dom.stdout],
    [dom.outStderr, dom.stderr],
    [dom.outSpan, dom.span],
    [dom.outWarnings, dom.warnings],
    [dom.outRecord, dom.recordJson],
  ]) {
    show(box, pre, "");
  }
}

function field(label, value, mono) {
  const key = document.createElement("span");
  key.className = "k";
  key.textContent = label;
  const val = document.createElement("span");
  val.className = mono ? "v" : "";
  val.textContent = value;
  const wrap = document.createElement("span");
  wrap.append(key, document.createTextNode(" "), val);
  return wrap;
}

function drawVerdict(observation) {
  const box = dom.verdict;
  box.textContent = "";
  box.className = "verdict";
  const verdict = observation.verdict || "";
  if (verdict.startsWith("exit(")) {
    box.classList.add(observation.exit === 0 ? "ok" : "fault");
  } else if (verdict === "unsupported") {
    box.classList.add("declined");
  } else {
    box.classList.add("fault");
  }
  box.append(field("verdict", verdict, true));
  box.append(field("phase reached", observation.phase, true));
  box.append(field("exit code", String(observation.exit), true));
  if (observation.leaks > 0) {
    box.append(field("regions leaked", String(observation.leaks), true));
  }
  box.classList.remove("hidden");
}

/** Expands tabs so the caret ruler lines up under the source line. */
const expand = (text) => text.replace(/\t/g, "    ");

/**
 * Locates a byte span in the source and renders it the way a compiler does:
 * the line, then a ruler under the offending bytes.
 *
 * Spans on the wire are byte offsets into the UTF-8 source, so the arithmetic
 * happens in bytes and only the slices that get displayed are decoded.
 */
function locate(source, span) {
  if (!span || span.length !== 2) return "";
  const bytes = encoder.encode(source);
  const [from, to] = span;
  if (from > bytes.length) return "";

  let line = 1;
  let lineStart = 0;
  for (let i = 0; i < from; i += 1) {
    if (bytes[i] === 0x0a) {
      line += 1;
      lineStart = i + 1;
    }
  }
  let lineEnd = lineStart;
  while (lineEnd < bytes.length && bytes[lineEnd] !== 0x0a) lineEnd += 1;

  const text = expand(decoder.decode(bytes.subarray(lineStart, lineEnd)));
  const before = expand(decoder.decode(bytes.subarray(lineStart, Math.min(from, lineEnd))));
  const inner = expand(
    decoder.decode(bytes.subarray(Math.max(from, lineStart), Math.min(to, lineEnd))),
  );
  /* A zero-width span points at an absence, and one caret is the honest mark
   * for it. Code points rather than UTF-16 units, so an emoji counts once. */
  const width = Math.max(1, [...inner].length);
  const column = [...before].length;

  const label = String(line);
  const pad = " ".repeat(label.length);
  return [
    `${label} | ${text}`,
    `${pad} | ${" ".repeat(column)}${"^".repeat(width)}`,
    `${pad} |`,
    `${pad} = bytes ${from}..${to}, line ${line} column ${column + 1}`,
  ].join("\n");
}

function drawWarnings(observation, source) {
  const warnings = observation.warnings;
  if (!warnings || warnings.length === 0) {
    show(dom.outWarnings, dom.warnings, "");
    return;
  }
  const lines = warnings.map((warning) => {
    const where = locate(source, warning.span);
    const first = where ? where.split("\n")[0].trim() : "";
    return `${warning.code} at bytes ${warning.span[0]}..${warning.span[1]}${first ? `\n    ${first}` : ""}`;
  });
  show(dom.outWarnings, dom.warnings, lines.join("\n"));
}

function draw(observation, source) {
  drawVerdict(observation);
  show(dom.outStdout, dom.stdout, observation.stdout);
  show(dom.outStderr, dom.stderr, observation.stderr);

  /* One span gets the ruler: the thing that stopped the program. The detail,
   * the trap and the UB finding are mutually exclusive by construction. */
  const primary = observation.detail || observation.trap || observation.ub || null;
  show(dom.outSpan, dom.span, primary ? locate(source, primary.span) : "");
  drawWarnings(observation, source);

  if (observation.forest) {
    dom.stderr.textContent +=
      `\ninterpreter self-check failed: ${observation.forest}\n` +
      "That is a bug in lupin. The region forest invariant broke during this run.";
    dom.outStderr.classList.remove("hidden");
  }
}

/** A wasm trap. The instance is not worth trusting after one, so it goes. */
function drawAbort(cause) {
  clearOutput();
  const box = dom.verdict;
  box.className = "verdict fault";
  box.append(field("verdict", "the interpreter aborted", true));
  box.classList.remove("hidden");
  show(
    dom.outStderr,
    dom.stderr,
    `${cause}\n\n` +
      "A panic in the interpreter becomes a WebAssembly trap, and there is no\n" +
      "verdict for a crash. This is a bug in lupin rather than in the program:\n" +
      "please report it with the source above.\n\n" +
      "A fresh interpreter has been loaded, so the next run starts clean.",
  );
  instantiate();
}

/* ------------------------------------------------------------------ */
/* running                                                             */
/* ------------------------------------------------------------------ */

let lastSource = "";

async function run() {
  if (!exports) return;
  const source = dom.source.value;
  dom.run.disabled = true;
  dom.run.textContent = "Running";
  /* Let the button repaint before a synchronous call that can take a moment.
   * The interpreter's fuel limit bounds it, so there is no runaway to cancel. */
  await new Promise((resolve) => requestAnimationFrame(resolve));

  try {
    const observation = call("lupin_observe", source);
    clearOutput();
    draw(observation, source);
    lastSource = source;
    dom.record.disabled = false;
    dom.record.textContent = "Show the record";
  } catch (cause) {
    drawAbort(String(cause));
    dom.record.disabled = true;
  } finally {
    dom.run.disabled = false;
    dom.run.textContent = "Run";
  }
}

function showRecord() {
  if (!exports || !lastSource) return;
  if (!dom.outRecord.classList.contains("hidden")) {
    show(dom.outRecord, dom.recordJson, "");
    dom.record.textContent = "Show the record";
    return;
  }
  try {
    const answer = call("lupin_record", lastSource);
    /* The record arrives as the one-line JSON the protocol puts on stdout.
     * Re-indenting it is the page's only liberty, and the line itself is
     * recoverable from it. */
    const text = answer.record
      ? JSON.stringify(JSON.parse(answer.record), null, 2)
      : `the record could not be built: ${answer.error}`;
    show(dom.outRecord, dom.recordJson, text);
    dom.record.textContent = "Hide the record";
  } catch (cause) {
    drawAbort(String(cause));
  }
}

/* ------------------------------------------------------------------ */
/* samples                                                             */
/* ------------------------------------------------------------------ */

let samples = [];

async function loadSamples() {
  const response = await fetch(SAMPLES_URL);
  if (!response.ok) throw new Error(`${SAMPLES_URL} answered ${response.status}`);
  const index = await response.json();
  samples = index.samples || [];
  if (samples.length === 0) throw new Error("the sample index is empty");

  for (const [position, sample] of samples.entries()) {
    const option = document.createElement("option");
    option.value = String(position);
    option.textContent = sample.title;
    dom.samples.append(option);
  }
  dom.samples.disabled = false;
}

async function pick(position) {
  const sample = samples[position];
  if (!sample) return;
  const response = await fetch(`/play/samples/${encodeURIComponent(sample.name)}`);
  if (!response.ok) {
    dom.provenance.textContent = `${sample.corpus_path} could not be fetched (${response.status}).`;
    return;
  }
  dom.source.value = await response.text();
  drawGutter();
  window.scrollTo({ top: 0 });
  clearOutput();
  dom.record.disabled = true;
  describe(sample);
}

function describe(sample) {
  const parts = [sample.corpus_path];
  if (sample.check) parts.push(`the file expects ${sample.check}`);
  dom.provenance.textContent = `${parts.join(" — ")}.`;
}

/* ------------------------------------------------------------------ */
/* boot                                                               */
/* ------------------------------------------------------------------ */

function fail(message, detail) {
  dom.banner.classList.add("broken");
  dom.bannerText.textContent = message;
  const extra = document.createElement("p");
  extra.textContent = detail;
  dom.banner.append(extra);
  dom.run.disabled = true;
  dom.record.disabled = true;
  dom.samples.disabled = true;
}

async function boot() {
  dom.source.value = FALLBACK;
  drawGutter();
  dom.source.addEventListener("input", drawGutter);
  // The page owns the vertical axis (wolf-web#2); the textarea's one
  // remaining axis is horizontal, and browsers hand a textarea's
  // shift+wheel to UA text-control scrolling that goes nowhere once
  // overflow-y is hidden (wolf-web#3). Own it: shift+wheel and
  // trackpad deltaX pan the code; plain vertical wheel still falls
  // through to the page untouched.
  dom.source.addEventListener(
    "wheel",
    (event) => {
      const dx = event.deltaX !== 0 ? event.deltaX : event.shiftKey ? event.deltaY : 0;
      if (dx === 0) return;
      if (dom.source.scrollWidth <= dom.source.clientWidth) return;
      dom.source.scrollLeft += dx;
      event.preventDefault();
    },
    { passive: false },
  );
  dom.source.addEventListener("keydown", onKeyDown);
  dom.run.addEventListener("click", run);
  dom.record.addEventListener("click", showRecord);
  dom.samples.addEventListener("change", (event) => {
    const value = event.target.value;
    if (value !== "") pick(Number(value));
  });

  try {
    await load();
  } catch (cause) {
    fail(
      "The interpreter did not load, so nothing on this page can run.",
      `${cause.message}. The editor still works and the samples still load, ` +
        "and running a program will not. If this persists, the site's build " +
        "published a broken module and the maintainers want to know.",
    );
    /* The samples are useful reading even with no interpreter. */
    try {
      await loadSamples();
      await pick(0);
    } catch {
      /* Already reported: the banner says the page cannot run anything. */
    }
    return;
  }

  const version = takeResult(exports.lupin_version());
  dom.banner.classList.remove("broken");
  dom.bannerText.textContent =
    `${version.impl} ${version.impl_version}, compiled to WebAssembly, ` +
    `running in this tab against spec and corpus pin ${version.upstream_pin.slice(0, 7)}.`;
  dom.run.disabled = false;

  try {
    await loadSamples();
    dom.samples.value = "0";
    await pick(0);
  } catch (cause) {
    dom.provenance.textContent =
      `The sample programs did not load (${cause.message}); ` +
      "the editor is holding a built-in program instead.";
  }
}

boot();
