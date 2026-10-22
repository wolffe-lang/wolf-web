// ww46 (from ww45-stdout-all.mjs): every named corpus program through two modules; prints each row whose verdict,
// stdout, phase, exit or unsupported reason differs between them (stdout-all compares only verdict and stdout, and
// lupin 0.1.55 moves reason words without moving a class).
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
const key = (x) => JSON.stringify([x.verdict, x.stdout_inline ?? x.stdout ?? null, x.phase ?? null, x.exit ?? null, x.unsupported ?? null]);
let same = 0, differ = 0;
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const a = A(src), b = B(src);
  if (key(a) === key(b)) { same++; continue; }
  differ++;
  console.log(`${f}\n  A ${key(a)}\n  B ${key(b)}`);
}
console.log(`reasons-all: ${files.length} programs, ${same} identical in verdict, stdout, phase, exit and reason, ${differ} differ`);
