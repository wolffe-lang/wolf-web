import fs from "node:fs";
const [wasm, corpus, ...files] = process.argv.slice(2);
const inst = new WebAssembly.Instance(await WebAssembly.compile(fs.readFileSync(wasm)), {});
let ex = inst.exports; const enc = new TextEncoder(), dec = new TextDecoder();
const mem = () => new Uint8Array(ex.memory.buffer);
function observe(src) {
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  try { const r = ex.lupin_observe(p, b.length); const v = mem();
    const n = v[r] | (v[r+1] << 8) | (v[r+2] << 16) | (v[r+3] << 24);
    const t = dec.decode(v.subarray(r + 4, r + 4 + n)); ex.lupin_result_free(r); return JSON.parse(t);
  } finally { ex.lupin_free(p, b.length); }
}
let bad = 0;
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const rec = observe(src);
  const m = src.match(/^\/\/! check: run\(exit=(\d+), stdout="((?:[^"\\]|\\.)*)"\)/m);
  const want = m ? JSON.parse(`"${m[2]}"`) : null;
  const got = rec.stdout_inline ?? rec.stdout ?? null;
  const ok = want === null ? "n/a" : (got === want ? "MATCH" : "DIFF");
  if (ok === "DIFF") bad++;
  console.log(`${ok.padEnd(5)} ${f} verdict=${rec.verdict} stdout=${JSON.stringify(got)} want=${JSON.stringify(want)}${rec.reason ? " reason=" + JSON.stringify(rec.reason) : ""}`);
  if (f.includes("proc_join_param")) console.log("   record keys:", Object.keys(rec).join(","), JSON.stringify(rec).slice(0, 400));
}
console.log(`stdout mismatches: ${bad}`);
