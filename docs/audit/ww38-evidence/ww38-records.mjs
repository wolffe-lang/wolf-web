// ww38: the full observation record for named corpus programs (the reason an unsupported or fail carries).
import fs from "node:fs";
const [wasm, corpus, ...files] = process.argv.slice(2);
const inst = new WebAssembly.Instance(await WebAssembly.compile(fs.readFileSync(wasm)), {});
const ex = inst.exports; const enc = new TextEncoder(), dec = new TextDecoder();
const mem = () => new Uint8Array(ex.memory.buffer);
function observe(src) {
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  try { const r = ex.lupin_observe(p, b.length); const v = mem();
    const n = v[r] | (v[r+1] << 8) | (v[r+2] << 16) | (v[r+3] << 24);
    const t = dec.decode(v.subarray(r + 4, r + 4 + n)); ex.lupin_result_free(r); return JSON.parse(t);
  } finally { ex.lupin_free(p, b.length); }
}
for (const f of files) console.log(f, JSON.stringify(observe(fs.readFileSync(`${corpus}/${f}`, "utf8"))));
