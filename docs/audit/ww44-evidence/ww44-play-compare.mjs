// ww44 (copied from ww43-play-compare.mjs, unchanged): does the tab refuse anything it served before? Two records of ww44-play.mjs (before, after) compared
// per cell and per menu program by corpus path: a program that exited or trapped before and does anything else
// after is a refusal of something served. Also prints the probes' answers side by side.
import fs from "node:fs";
const [b, a] = process.argv.slice(2).map((f) => JSON.parse(fs.readFileSync(f, "utf8")));
let lost = 0, moved = 0, rows = 0;
const ran = (v) => v.startsWith("exit(") || v.startsWith("trap");
for (const cell of Object.keys(b.cells)) {
  const after = new Map(a.cells[cell].samples.map((s) => [s.corpus, s.verdict]));
  for (const s of b.cells[cell].samples) {
    rows++;
    const v = after.get(s.corpus);
    if (v === undefined) { lost++; console.log(`${cell}: ${s.corpus} was on the menu (${s.verdict}) and is not now`); continue; }
    if (v !== s.verdict) { moved++; console.log(`${cell}: ${s.corpus} ${s.verdict} -> ${v}${ran(s.verdict) && !ran(v) ? "  REFUSED NOW" : ""}`); if (ran(s.verdict) && !ran(v)) lost++; }
  }
  const added = a.cells[cell].samples.filter((s) => !b.cells[cell].samples.some((t) => t.corpus === s.corpus));
  for (const s of added) console.log(`${cell}: ${s.corpus} is new on the menu (${s.verdict})`);
}
const c = "chromium desktop";
for (const n of Object.keys(a.cells[c].probes)) console.log(`${n}: before ${b.cells[c].probes[n].verdict} (${b.cells[c].probes[n].stderr}) | after ${a.cells[c].probes[n].verdict} (${a.cells[c].probes[n].stderr})`);
console.log(`compare: ${b.base} -> ${a.base}: ${rows} menu runs over ${Object.keys(b.cells).length} cells, ${moved} verdicts moved, ${lost} served before and refused or missing now`);
process.exit(lost ? 1 : 0);
