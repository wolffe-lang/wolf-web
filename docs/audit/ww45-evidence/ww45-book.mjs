// ww45: chapter 7's memory diagrams and the pages bs69 changed, each by a block it changed (ch01, ch22, the colophon,
// ch34's §34.6 programs and §34.5's group program as bs69 re-wrote it on the std), under lupp.us's CSP, three engines x
// two viewports. Adapted from ww44-book.mjs. Run beside wolf-book's tests/contents/serve.mjs (3ac6fa9):
//   PLAYWRIGHT_MODULE=<playwright-core> node ww45-book.mjs --root <dist/book> | --base https://lupp.us/book/
// ch07: the figure.memory-diagram <img> count, each loaded (complete, naturalWidth > 0), each SVG response's
// status and content type. ch01/ch22/colophon: the page's status and its changed block's text present in a code block.
// Every page: every CSP violation or console error.
import { createRequire } from "node:module";
import { serve } from "./serve.mjs";
const require = createRequire(import.meta.url);
const pw = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const a = process.argv.slice(2);
const root = a[a.indexOf("--root") + 1], baseArg = a.includes("--base") ? a[a.indexOf("--base") + 1] : null;
let server = null, base = baseArg;
if (!baseArg) { server = await serve(root, 0, {}); base = server.url; }
const VP = { phone: { width: 390, height: 844 }, desktop: { width: 1440, height: 900 } };
const SAMPLES = { "ch01.html": "tar -xzf wolf-0.2.33-x86_64-pc-windows-msvc.tar.gz", "ch22.html": "wolfi v0 · toolchain 0.2.33 · edition v1", "back/colophon.html": "wolf 0.2.33 (wolfgang, pin 85dab5d)", "ch34.html": "os_signal_ignore_one(meaning) else |e| {", "ch34.html ": "if a == \"again\" { os_exit_signal(signal.terminate())? }", "ch34.html  ": "signal.send_group(g, meaning) else |e| {" };
let failed = false;
console.log(`book: against ${base}${baseArg ? " (live)" : " (render served with lupp.us's headers)"}`);
for (const engine of ["chromium", "firefox", "webkit"]) {
  const browser = await pw[engine].launch();
  for (const vp of ["phone", "desktop"]) {
    for (const pg of ["ch07.html", ...Object.keys(SAMPLES)]) {
      const ctx = await browser.newContext({ viewport: VP[vp] });
      const page = await ctx.newPage();
      const errs = [], svgs = [];
      page.on("console", (m) => { if (m.type() === "error" || /Content.Security|CSP|Refused/i.test(m.text())) errs.push(`console ${m.type()}: ${m.text()}`); });
      page.on("pageerror", (e) => errs.push(`pageerror: ${e.message}`));
      page.on("response", (r) => { if (/\/diagrams\/ch07\/[^/]*\.svg$/.test(r.url())) svgs.push(`${r.status()} ${r.headers()["content-type"]} ${r.url().split("/book/")[1]}`); });
      await page.addInitScript(() => { window.__csp = []; document.addEventListener("securitypolicyviolation", (e) => window.__csp.push(`${e.violatedDirective} ${e.blockedURI}`)); });
      const resp = await page.goto(base + pg.trim(), { waitUntil: "load", timeout: 60000 });
      let ok, line;
      if (pg === "ch07.html") {
        const imgs = await page.$$eval("figure.memory-diagram img", (xs) => Promise.all(xs.map(async (i) => { i.scrollIntoView(); try { await i.decode(); } catch {} return { complete: i.complete, w: i.naturalWidth, h: i.naturalHeight }; })));
        const csp = await page.evaluate(() => window.__csp);
        ok = resp.status() === 200 && imgs.length === 6 && imgs.every((i) => i.complete && i.w > 0) && csp.length === 0 && errs.length === 0 && svgs.length === 6 && svgs.every((s) => s.startsWith("200 image/svg+xml") || s.startsWith("304"));
        line = `page ${resp.status()}, ${imgs.length} diagrams, ${imgs.filter((i) => i.complete && i.w > 0).length} rendered (${imgs.map((i) => `${i.w}x${i.h}`).join(" ")}), ${svgs.length} svg responses, ${csp.length} CSP violations, ${errs.length} console errors`;
        errs.unshift(...csp);
      } else {
        const found = await page.$$eval("pre code", (xs, want) => xs.some((x) => x.textContent.includes(want)), SAMPLES[pg]);
        const csp = await page.evaluate(() => window.__csp);
        ok = resp.status() === 200 && found && csp.length === 0 && errs.length === 0;
        line = `page ${resp.status()}, new sample ${found ? "present" : "MISSING"} (${JSON.stringify(SAMPLES[pg])}), ${csp.length} CSP violations, ${errs.length} console errors`;
        errs.unshift(...csp);
      }
      failed ||= !ok;
      console.log(`book: ${engine} ${vp} ${pg}: ${line} — ${ok ? "ok" : "FAIL"}`);
      for (const s of svgs) console.log(`  svg ${s}`);
      for (const e of errs) console.log(`  ! ${e}`);
      await ctx.close();
    }
  }
  await browser.close();
}
if (server) await server.close();
console.log(`book: ${failed ? "FAILED" : "ok — six diagrams rendered and the changed blocks served on every cell, no CSP violation"}`);
process.exit(failed ? 1 : 0);
