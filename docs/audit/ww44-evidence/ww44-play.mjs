// ww44 (adapted from ww43-play.mjs): /play/ in browser engines under the production headers, three engines x two
// viewports. Per cell: the page loads and the module boots (banner text, Run enabled); every program on the samples
// menu is loaded from the menu and run with the page's own Run button (verdict recorded); every program in the probes
// directory — §34.5's builtins, the seven wolf 0.2.31 adds, one call each, §34.5's three programs and §3.3's two
// verbatim — is typed into the editor and run (verdict and stderr recorded);
// every CSP violation, console error and page error is recorded.
//   PLAYWRIGHT_MODULE=<playwright-core> node ww44-play.mjs --base <origin> --probes <dir> --json <out.json>
import { createRequire } from "node:module"; import fs from "node:fs";
const require = createRequire(import.meta.url);
const pw = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const a = process.argv.slice(2); const arg = (k) => a[a.indexOf(k) + 1];
const base = arg("--base").replace(/\/$/, ""), probes = arg("--probes"), out = arg("--json");
const VP = { phone: { width: 390, height: 844 }, desktop: { width: 1440, height: 900 } };
const NAMES = fs.readdirSync(probes).filter((f) => f.endsWith(".lu")).map((f) => f.slice(0, -3)).sort();
const result = { base, started: new Date().toISOString(), cells: {} };
let failed = false;
async function runAndRead(page) {
  await page.evaluate(() => { const v = document.getElementById("verdict"); v.classList.add("hidden"); v.textContent = ""; });
  await page.click("#run");
  await page.waitForFunction(() => !document.getElementById("verdict").classList.contains("hidden"), null, { timeout: 60000 });
  return page.evaluate(() => {
    const t = (id) => document.getElementById(id).textContent;
    const spans = [...document.querySelectorAll("#verdict > span")].map((s) => s.textContent);
    return { verdict: (spans[0] || "").replace(/^verdict\s*/, ""), fields: spans, cls: document.getElementById("verdict").className, stdout: t("stdout"), stderr: t("stderr") };
  });
}
console.log(`play: against ${base}/play/`);
for (const engine of ["chromium", "firefox", "webkit"]) {
  const browser = await pw[engine].launch();
  for (const vp of ["phone", "desktop"]) {
    const ctx = await browser.newContext({ viewport: VP[vp] });
    const page = await ctx.newPage();
    const errs = [];
    page.on("console", (m) => { if (m.type() === "error" || /Content.Security|CSP|Refused/i.test(m.text())) errs.push(`console ${m.type()}: ${m.text()}`); });
    page.on("pageerror", (e) => errs.push(`pageerror: ${e.message}`));
    await page.addInitScript(() => { window.__csp = []; document.addEventListener("securitypolicyviolation", (e) => window.__csp.push(`${e.violatedDirective} ${e.blockedURI}`)); });
    const cell = { samples: [], probes: {} };
    try {
      const resp = await page.goto(`${base}/play/`, { waitUntil: "load", timeout: 60000 });
      cell.status = resp.status(); cell.csp_header = resp.headers()["content-security-policy"] || null;
      await page.waitForFunction(() => !document.getElementById("run").disabled && !document.getElementById("samples").disabled, null, { timeout: 60000 });
      cell.banner = await page.textContent("#banner-text");
      // The menu is the page's own index: each option's value is its position in it, and the page writes the
      // sample's corpus path into #provenance only after the editor holds its source, so that text is the signal
      // that the program about to be run is the one named.
      const index = await page.evaluate(async () => (await (await fetch("/play/samples/index.json")).json()).samples.map((s) => ({ path: s.corpus_path, note: s.note || null })));
      const titles = await page.$$eval("#samples option", (os) => os.filter((o) => o.value !== "").map((o) => [o.value, o.textContent]));
      if (titles.length !== index.length) throw new Error(`menu has ${titles.length} options, the index ${index.length}`);
      for (const [value, title] of titles) {
        const want = index[Number(value)];
        if (value !== "0") await page.selectOption("#samples", value);
        await page.waitForFunction((p) => document.getElementById("provenance").textContent.startsWith(p), want.path, { timeout: 30000 });
        const source = await page.inputValue("#source");
        const r = await runAndRead(page);
        cell.samples.push({ title, corpus: want.path, noted: want.note, bytes: source.length, verdict: r.verdict });
      }
      for (const n of NAMES) {
        const src = fs.readFileSync(`${probes}/${n}.lu`, "utf8");
        await page.fill("#source", src);
        const held = await page.inputValue("#source");
        const r = await runAndRead(page);
        cell.probes[n] = { typed: held === src, verdict: r.verdict, fields: r.fields, stdout: r.stdout, stderr: r.stderr.trim() };
      }
      cell.csp = await page.evaluate(() => window.__csp);
    } catch (e) { cell.error = String(e); }
    cell.errors = errs;
    const k = {}; for (const s of cell.samples) { const c = s.verdict.startsWith("exit(") ? "exit" : s.verdict.startsWith("trap") ? "trap" : s.verdict; k[c] = (k[c] || 0) + 1; }
    const pv = NAMES.map((n) => `${n}=${cell.probes[n]?.verdict ?? "?"}`).join(" ");
    const ok = !cell.error && cell.status === 200 && cell.samples.length > 0 && (cell.csp || []).length === 0 && errs.length === 0 && NAMES.every((n) => cell.probes[n]?.typed);
    failed ||= !ok;
    console.log(`play: ${engine} ${vp}: page ${cell.status}, banner ${JSON.stringify(cell.banner)}, ${cell.samples.length} menu programs run ${JSON.stringify(k)}, probes ${pv}, ${(cell.csp || []).length} CSP violations, ${errs.length} console errors — ${ok ? "ok" : "FAIL"}`);
    if (cell.error) console.log(`  ! ${cell.error}`);
    for (const e of [...(cell.csp || []), ...errs]) console.log(`  ! ${e}`);
    result.cells[`${engine} ${vp}`] = cell;
    await ctx.close();
  }
  await browser.close();
}
const first = result.cells["chromium desktop"];
if (first?.probes) for (const n of NAMES) console.log(`play: ${n}: ${JSON.stringify(first.probes[n]?.fields)} stderr ${JSON.stringify(first.probes[n]?.stderr)}`);
const maps = Object.entries(result.cells).map(([c, v]) => [c, JSON.stringify(v.samples.map((s) => [s.corpus, s.verdict])) + JSON.stringify(NAMES.map((n) => [v.probes[n]?.verdict, v.probes[n]?.stderr]))]);
const agree = maps.every(([, m]) => m === maps[0][1]);
console.log(`play: the six cells ${agree ? "agree on every verdict and every probe's answer" : "DISAGREE"}`);
failed ||= !agree;
result.finished = new Date().toISOString();
fs.writeFileSync(out, JSON.stringify(result, null, 1));
console.log(`play: ${failed ? "FAILED" : "ok"}`);
process.exit(failed ? 1 : 0);
