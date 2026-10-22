// ww46: every running corpus program the tab answers "`<name>` does not resolve", through one module, with the name,
// so /play/'s "none of the second kind at these pins" (no program waiting on the interpreter's mirror) is read off
// the module: a name that is a std function (the tab has no std) or a sibling module is the tab's; a prelude
// builtin the interpreter lacks would be the mirror's.
import fs from "node:fs";
const [w, corpus, ...files] = process.argv.slice(2);
const enc = new TextEncoder(), dec = new TextDecoder();
const mod = await WebAssembly.compile(fs.readFileSync(w));
let ex = new WebAssembly.Instance(mod, {}).exports;
const mem = () => new Uint8Array(ex.memory.buffer);
let n = 0;
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  const q = ex.lupin_observe(p, b.length); const v = mem();
  const len = v[q] | (v[q+1] << 8) | (v[q+2] << 16) | (v[q+3] << 24);
  const r = JSON.parse(dec.decode(v.subarray(q + 4, q + 4 + len))); ex.lupin_result_free(q); ex.lupin_free(p, b.length);
  const m = /^`([^`]*)` does not resolve$/.exec(r.unsupported ?? "");
  if (m) { n++; console.log(`${f}: ${m[1]}`); }
}
console.log(`${n} programs answer that a name does not resolve`);
