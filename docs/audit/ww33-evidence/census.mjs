/* ww32 census: every `phase: run` program in a corpus, fed to a wasm module.
 * usage: node ww32-census.mjs <lupin.wasm> <corpus-dir> [out.json]
 * A program is a census program iff its header block matches ^//!\s*phase:\s*run\b.
 */
import fs from "node:fs";
import path from "node:path";

const wasmPath = process.argv[2];
const corpus = process.argv[3];
const outPath = process.argv[4] || null;

const compiled = await WebAssembly.compile(fs.readFileSync(wasmPath));
let exports = new WebAssembly.Instance(compiled, {}).exports;
const encoder = new TextEncoder();
const decoder = new TextDecoder();
const memory = () => new Uint8Array(exports.memory.buffer);

function takeResult(pointer) {
  const view = memory();
  const length =
    view[pointer] | (view[pointer + 1] << 8) | (view[pointer + 2] << 16) | (view[pointer + 3] << 24);
  const text = decoder.decode(view.subarray(pointer + 4, pointer + 4 + length));
  exports.lupin_result_free(pointer);
  return JSON.parse(text);
}
function observe(source) {
  const bytes = encoder.encode(source);
  const pointer = exports.lupin_alloc(bytes.length);
  memory().set(bytes, pointer);
  try {
    return takeResult(exports.lupin_observe(pointer, bytes.length));
  } finally {
    exports.lupin_free(pointer, bytes.length);
  }
}

const HEADER = /^\/\/!\s*phase:\s*run\b/m;
function walk(dir, acc = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, acc);
    else if (e.name.endsWith(".lu")) acc.push(p);
  }
  return acc;
}

const files = walk(corpus)
  .filter((f) => HEADER.test(fs.readFileSync(f, "utf8")))
  .sort();

const rows = [];
const classes = {};
for (const f of files) {
  let verdict, cls;
  try {
    verdict = String(observe(fs.readFileSync(f, "utf8")).verdict ?? "?");
    cls = verdict.split("(")[0];
  } catch (cause) {
    verdict = `MODULE-DIED: ${cause.message}`;
    cls = "died";
    exports = new WebAssembly.Instance(compiled, {}).exports;
  }
  classes[cls] = (classes[cls] || 0) + 1;
  rows.push({ file: path.relative(corpus, f), verdict, cls });
}

const summary = { wasm: wasmPath, corpus, programs: files.length, classes };
summary.candidates = (classes.exit || 0) + (classes.trap || 0);
console.log(JSON.stringify(summary, null, 2));
console.log("--- non exit/trap rows:");
for (const r of rows) if (r.cls !== "exit" && r.cls !== "trap") console.log(`  ${r.cls.padEnd(12)} ${r.file}  ${r.verdict}`);
if (outPath) fs.writeFileSync(outPath, JSON.stringify({ summary, rows }, null, 2));
