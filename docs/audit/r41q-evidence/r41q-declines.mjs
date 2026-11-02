// r41q (from ww45-stdout-all.mjs's loader): every named corpus program through one module; prints each row the
// module answers other than a normal exit, with its verdict, phase, exit and unsupported reason.
// usage: node declines.mjs <lupin.wasm> <corpus> <file>...
import fs from "node:fs";
const [w, corpus, ...files] = process.argv.slice(2);
const enc = new TextEncoder(), dec = new TextDecoder();
const mod = await WebAssembly.compile(fs.readFileSync(w));
let ex = new WebAssembly.Instance(mod, {}).exports;
const mem = () => new Uint8Array(ex.memory.buffer);
const counts = {};
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  let o;
  try { const r = ex.lupin_observe(p, b.length); const v = mem();
    const n = v[r] | (v[r+1] << 8) | (v[r+2] << 16) | (v[r+3] << 24);
    o = JSON.parse(dec.decode(v.subarray(r + 4, r + 4 + n))); ex.lupin_result_free(r); ex.lupin_free(p, b.length);
  } catch (e) { ex = new WebAssembly.Instance(mod, {}).exports; o = { verdict: "died", err: String(e) }; }
  const v = typeof o.verdict === "string" ? o.verdict : JSON.stringify(o.verdict);
  counts[v] = (counts[v] ?? 0) + 1;
  if (v === "unsupported" || v === "died") console.log(`${f}\t${v}\t${o.phase ?? ""}\t${o.exit ?? ""}\t${o.unsupported ?? o.err ?? ""}`);
}
console.log(`declines: ${files.length} programs ${JSON.stringify(counts)}`);
