// ww40: chapter 7's memory diagrams and the three chapters bs64 gave new samples, under lupp.us's CSP,
// three engines x two viewports. Adapted from ww39-ch07.mjs. Run beside wolf-book's tests/contents/serve.mjs (2504a0f):
//   PLAYWRIGHT_MODULE=<playwright-core> node ww40-book.mjs --root <dist/book> | --base https://lupp.us/book/
// ch07: the figure.memory-diagram <img> count, each loaded (complete, naturalWidth > 0), each SVG response's
// status and content type. ch02/ch06/ch08: the page's status and its new sample's text present in a code block.
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
const SAMPLES = { "ch02.html": "let high = n & !0xff", "ch06.html": "fn die(why: str) -> never", "ch08.html": "let summary = copy region command {" };
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
      const resp = await page.goto(base + pg, { waitUntil: "load", timeout: 60000 });
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
console.log(`book: ${failed ? "FAILED" : "ok — six diagrams rendered and the three new samples served on every cell, no CSP violation"}`);
process.exit(failed ? 1 : 0);
