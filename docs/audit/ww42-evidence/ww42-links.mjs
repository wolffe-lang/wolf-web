// ww42: the site's own links, two hops deep, in browser engines under the production headers
// (three engines x two viewports). Hop 1: every same-origin link on the front page is CLICKED on the page
// (the element's own click, so a script that intercepts it runs) and the document it lands on is recorded.
// Hop 2: every same-origin link found on every hop-1 page is navigated to. A target that is not a page
// (.pdf, .md, .ebnf, .json, .wasm, .lu, .txt) is fetched through the browser context instead of opened.
// Recorded per target: the status, and every CSP violation, console error and page error on the page.
//   PLAYWRIGHT_MODULE=<playwright-core> node ww42-links.mjs --base <origin> --json <out.json>
import { createRequire } from "node:module"; import fs from "node:fs";
const require = createRequire(import.meta.url);
const pw = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const a = process.argv.slice(2); const arg = (k) => a[a.indexOf(k) + 1];
const base = arg("--base").replace(/\/$/, ""), out = arg("--json");
const VP = { phone: { width: 390, height: 844 }, desktop: { width: 1440, height: 900 } };
const ASSET = /\.(pdf|md|ebnf|json|wasm|lu|txt|xml|gz|zip)$/i;
const result = { base, started: new Date().toISOString(), cells: {} };
let failed = false;
// A click can land through a redirect (a directory without its slash), and an engine may report the page loaded
// before the second navigation commits; reading the links is retried until the document holds still.
const links = async (page) => {
  for (let i = 0; ; i++) {
    try {
      await page.waitForLoadState("load", { timeout: 60000 });
      return await page.$$eval("a[href]", (xs) => [...new Set(xs.map((x) => x.href.split("#")[0]).filter((h) => h.startsWith(location.origin)))]);
    } catch (e) { if (i >= 5 || !/context was destroyed|navigation/i.test(String(e))) throw e; await page.waitForTimeout(250); }
  }
};
console.log(`links: against ${base}/`);
for (const engine of ["chromium", "firefox", "webkit"]) {
  const browser = await pw[engine].launch();
  for (const vp of ["phone", "desktop"]) {
    const ctx = await browser.newContext({ viewport: VP[vp] });
    const page = await ctx.newPage();
    let errs = [];
    page.on("console", (m) => { if (m.type() === "error" || /Content.Security|CSP|Refused/i.test(m.text())) errs.push(`console ${m.type()}: ${m.text()}`); });
    page.on("pageerror", (e) => errs.push(`pageerror: ${e.message}`));
    await page.addInitScript(() => { window.__csp = []; document.addEventListener("securitypolicyviolation", (e) => window.__csp.push(`${e.violatedDirective} ${e.blockedURI}`)); });
    const cell = { hop1: [], hop2: [], faults: [] };
    const settle = async (url, status, hop, how) => {
      let csp = []; try { csp = await page.evaluate(() => window.__csp || []); } catch {}
      const row = { url: url.replace(base, ""), status, how, csp: csp.length, errors: errs.length };
      cell[hop].push(row);
      if (!(status === 200 || status === 304) || csp.length || errs.length) cell.faults.push({ ...row, detail: [...csp, ...errs] });
      errs = [];
    };
    const fetchAsset = async (url, hop) => { const r = await ctx.request.get(url); cell[hop].push({ url: url.replace(base, ""), status: r.status(), how: "fetch", csp: 0, errors: 0 }); if (r.status() !== 200) cell.faults.push({ url, status: r.status(), how: "fetch" }); };
    try {
      await page.goto(`${base}/`, { waitUntil: "load", timeout: 60000 });
      const front = await links(page);
      const pages1 = [];
      for (const target of front) {
        if (ASSET.test(target)) { await fetchAsset(target, "hop1"); continue; }
        await page.goto(`${base}/`, { waitUntil: "load", timeout: 60000 }); errs = [];
        const [resp] = await Promise.all([
          page.waitForResponse((r) => r.request().isNavigationRequest() && r.request().frame() === page.mainFrame() && !(r.status() >= 300 && r.status() < 400), { timeout: 60000 }),
          page.evaluate((t) => { const el = [...document.querySelectorAll("a[href]")].find((x) => x.href.split("#")[0] === t); el.click(); }, target),
        ]);
        const found = await links(page);
        await settle(page.url(), resp.status(), "hop1", "click");
        pages1.push({ url: page.url().split("#")[0], found });
      }
      const seen = new Set([`${base}/`, ...front, ...pages1.map((p) => p.url)]);
      const second = [];
      for (const p of pages1) for (const t of p.found) if (!seen.has(t)) { seen.add(t); second.push(t); }
      for (const target of second) {
        if (ASSET.test(target)) { await fetchAsset(target, "hop2"); continue; }
        errs = [];
        const resp = await page.goto(target, { waitUntil: "load", timeout: 60000 });
        await settle(page.url(), resp.status(), "hop2", "goto");
      }
    } catch (e) { cell.error = String(e); }
    const ok = !cell.error && cell.faults.length === 0 && cell.hop1.length > 0 && cell.hop2.length > 0;
    failed ||= !ok;
    const n = (h) => `${cell[h].filter((r) => r.status === 200 || r.status === 304).length}/${cell[h].length}`;
    console.log(`links: ${engine} ${vp}: hop 1 ${n("hop1")} landed (${cell.hop1.filter((r) => r.how === "click").length} clicked), hop 2 ${n("hop2")} landed, ${cell.faults.length} faults — ${ok ? "ok" : "FAIL"}`);
    if (cell.error) console.log(`  ! ${cell.error}`);
    for (const f of cell.faults.slice(0, 20)) console.log(`  ! ${JSON.stringify(f)}`);
    result.cells[`${engine} ${vp}`] = cell;
    await ctx.close();
  }
  await browser.close();
}
result.finished = new Date().toISOString();
fs.writeFileSync(out, JSON.stringify(result));
console.log(`links: ${failed ? "FAILED" : "ok — every link two hops from the front page lands, no CSP violation, no console error"}`);
process.exit(failed ? 1 : 0);
