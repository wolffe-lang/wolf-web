// ww43 (adapted from ww42-builtins.mjs): chapter 34's builtins — the eleven wolf 0.2.30 adds, one call each — and
// chapter 34's seven programs verbatim, through a wasm module as /play/ loads it. Prints the whole record.
// usage: node ww43-builtins.mjs <lupin.wasm> <probes-dir>
import fs from "node:fs";
const [wasm, dir] = process.argv.slice(2);
const mod = await WebAssembly.compile(fs.readFileSync(wasm));
console.log(`module ${wasm}: imports ${WebAssembly.Module.imports(mod).length}`);
let ex = new WebAssembly.Instance(mod, {}).exports; const enc = new TextEncoder(), dec = new TextDecoder();
const mem = () => new Uint8Array(ex.memory.buffer);
let died = 0;
const names = fs.readdirSync(dir).filter((f) => f.endsWith(".lu")).sort();
for (const f of names) {
  const src = fs.readFileSync(`${dir}/${f}`, "utf8");
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  try { const r = ex.lupin_observe(p, b.length); const v = mem();
    const len = v[r] | (v[r+1] << 8) | (v[r+2] << 16) | (v[r+3] << 24);
    const t = dec.decode(v.subarray(r + 4, r + 4 + len)); ex.lupin_result_free(r); ex.lupin_free(p, b.length);
    console.log(`${f}: ${t}`);
  } catch (e) { died++; console.log(`${f}: DIED ${e}`); ex = new WebAssembly.Instance(mod, {}).exports; }
}
console.log(`${names.length} programs; instance deaths: ${died}`);
