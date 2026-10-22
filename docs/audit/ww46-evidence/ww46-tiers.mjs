// ww46: the reason strings the tab gives for every `unsupported` running program, through one module, with the
// declined name masked, so /play/'s tier count is read off the module rather than off the page.
import fs from "node:fs";
const [w, corpus, ...files] = process.argv.slice(2);
const enc = new TextEncoder(), dec = new TextDecoder();
const mod = await WebAssembly.compile(fs.readFileSync(w));
let ex = new WebAssembly.Instance(mod, {}).exports;
const mem = () => new Uint8Array(ex.memory.buffer);
const counts = new Map();
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  let r;
  try { const q = ex.lupin_observe(p, b.length); const v = mem();
    const n = v[q] | (v[q+1] << 8) | (v[q+2] << 16) | (v[q+3] << 24);
    r = JSON.parse(dec.decode(v.subarray(q + 4, q + 4 + n))); ex.lupin_result_free(q); ex.lupin_free(p, b.length);
  } catch (e) { ex = new WebAssembly.Instance(mod, {}).exports; r = { verdict: "died", unsupported: String(e) }; }
  if (r.verdict !== "unsupported") continue;
  const why = (r.unsupported ?? "").replace(/^`[^`]*`/, "`NAME`");
  const k = why.length > 150 ? why.slice(0, 150) + "…" : why;
  if (!counts.has(k)) counts.set(k, []);
  counts.get(k).push(f);
}
for (const [k, fs_] of [...counts].sort((a, b) => b[1].length - a[1].length)) console.log(`${String(fs_.length).padStart(4)}  ${k}  e.g. ${fs_[0]}`);
console.log(`${[...counts.values()].reduce((a, b) => a + b.length, 0)} unsupported, ${counts.size} distinct reasons`);
