// r41q (from ww45-stdout-all.mjs's loader): every named corpus program through one module, held to its
// header's `//! check: run(...)` line as the terminal pass holds lupin: exit N or trap(kind) or nonzero,
// and stdout="..." when the header gives one. Prints one row per program and a summary.
// usage: node header-check.mjs <lupin.wasm> <corpus> <file>...
import fs from "node:fs";
const [w, corpus, ...files] = process.argv.slice(2);
const enc = new TextEncoder(), dec = new TextDecoder();
const mod = await WebAssembly.compile(fs.readFileSync(w));
let ex = new WebAssembly.Instance(mod, {}).exports;
const mem = () => new Uint8Array(ex.memory.buffer);
const tally = {};
for (const f of files) {
  const src = fs.readFileSync(`${corpus}/${f}`, "utf8");
  const chk = (src.split("\n").find((l) => l.startsWith("//! check: ")) || "").slice(11);
  const b = enc.encode(src); const p = ex.lupin_alloc(b.length); mem().set(b, p);
  let o;
  try { const r = ex.lupin_observe(p, b.length); const v = mem();
    const n = v[r] | (v[r+1] << 8) | (v[r+2] << 16) | (v[r+3] << 24);
    o = JSON.parse(dec.decode(v.subarray(r + 4, r + 4 + n))); ex.lupin_result_free(r); ex.lupin_free(p, b.length);
  } catch (e) { ex = new WebAssembly.Instance(mod, {}).exports; o = { verdict: "died" }; }
  const verdict = typeof o.verdict === "string" ? o.verdict : JSON.stringify(o.verdict);
  const out = o.stdout_inline ?? o.stdout ?? "";
  let row;
  if (verdict === "unsupported" || verdict === "died") row = `declined: ${o.unsupported ?? verdict}`;
  else {
    const m = chk.match(/^run\(exit=(nonzero|trap\([a-z-]+\)|-?\d+)/);
    const s = chk.match(/stdout="((?:[^"\\]|\\.)*)"/);
    if (!m) row = `no run check (${chk}): ${verdict}`;
    else {
      const want = m[1];
      const exitOk = want === "nonzero" ? verdict !== "exit(0)" : want.startsWith("trap") ? verdict === want : verdict === `exit(${want})`;
      const outOk = !s || out.replace(/\n+$/, "") === JSON.parse(`"${s[1]}"`).replace(/\n+$/, "");
      row = exitOk && outOk ? "AS HEADER" : `DIFFERS: ${verdict} ${JSON.stringify(out).slice(0, 120)} want ${want} ${s ? s[1].slice(0, 120) : ""}`;
    }
  }
  const k = row.split(":")[0]; tally[k] = (tally[k] ?? 0) + 1;
  console.log(`${f}: ${row}`);
}
console.log(`header-check: ${files.length} programs ${JSON.stringify(tally)}`);
