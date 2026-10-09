// ww40: every named corpus program through two modules; prints each row whose stdout or verdict differs between them.
import fs from "node:fs";
const [wa, wb, corpus, ...files] = process.argv.slice(2);
const enc = new TextEncoder(), dec = new TextDecoder();
async function load(w) {
  const mod = await WebAssembly.compile(fs.readFileSync(w));
  let ex = new WebAssembly.Instance(mod, {}).exports;
  const mem = () => new Uint8Array(ex.memory.buffer);
  return (src) => {
    const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
    try { const r = ex.lupin_observe(p, b.length); const v = mem();
      const n = v[r] | (v[r+1] << 8) | (v[r+2] << 16) | (v[r+3] << 24);
      const t = dec.decode(v.subarray(r + 4, r + 4 + n)); ex.lupin_result_free(r); ex.lupin_free(p, b.length); return JSON.parse(t);
    } catch (e) { ex = new WebAssembly.Instance(mod, {}).exports; return { verdict: "died", err: String(e) }; }
  };
}
const A = await load(wa), B = await load(wb);
let same = 0, differ = 0;
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const a = A(src), b = B(src);
  const sa = a.stdout_inline ?? a.stdout ?? null, sb = b.stdout_inline ?? b.stdout ?? null;
  if (JSON.stringify(a.verdict) === JSON.stringify(b.verdict) && sa === sb) { same++; continue; }
  differ++;
  console.log(`${f}\n  A ${JSON.stringify(a.verdict)} ${JSON.stringify(sa)}\n  B ${JSON.stringify(b.verdict)} ${JSON.stringify(sb)}`);
}
console.log(`stdout-all: ${files.length} programs, ${same} identical in verdict and stdout, ${differ} differ`);
