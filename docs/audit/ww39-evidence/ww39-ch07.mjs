// ww39: chapter 7's memory diagrams under lupp.us's CSP, three engines x two viewports.
// Run beside wolf-book's tests/contents/serve.mjs (fde77b8):
//   PLAYWRIGHT_MODULE=<playwright-core> node ww39-ch07.mjs --root <dist/book> | --base https://lupp.us/book/
// Per cell: the figure.memory-diagram <img> count, each one loaded (complete, naturalWidth > 0),
// each SVG response's status and content type, and every CSP violation or console error on the page.
import { createRequire } from "node:module";
import { serve } from "./serve.mjs";
const require = createRequire(import.meta.url);
const pw = require(process.env.PLAYWRIGHT_MODULE || "playwright");
const a = process.argv.slice(2);
const root = a[a.indexOf("--root") + 1], baseArg = a.includes("--base") ? a[a.indexOf("--base") + 1] : null;
let server = null, base = baseArg;
if (!baseArg) { server = await serve(root, 0, {}); base = server.url; }
const VP = { phone: { width: 390, height: 844 }, desktop: { width: 1440, height: 900 } };
let failed = false;
console.log(`ch07: against ${base}${baseArg ? " (live)" : " (render served with lupp.us's headers)"}`);
for (const engine of ["chromium", "firefox", "webkit"]) {
  const browser = await pw[engine].launch();
  for (const vp of ["phone", "desktop"]) {
    const ctx = await browser.newContext({ viewport: VP[vp] });
    const page = await ctx.newPage();
    const errs = [], svgs = [];
    page.on("console", (m) => { if (m.type() === "error" || /Content.Security|CSP|Refused/i.test(m.text())) errs.push(`console ${m.type()}: ${m.text()}`); });
    page.on("pageerror", (e) => errs.push(`pageerror: ${e.message}`));
    page.on("response", (r) => { if (/\/diagrams\/ch07\/[^/]*\.svg$/.test(r.url())) svgs.push(`${r.status()} ${r.headers()["content-type"]} ${r.url().split("/book/")[1]}`); });
    await page.addInitScript(() => { window.__csp = []; document.addEventListener("securitypolicyviolation", (e) => window.__csp.push(`${e.violatedDirective} ${e.blockedURI}`)); });
    const resp = await page.goto(base + "ch07.html", { waitUntil: "load", timeout: 60000 });
    const imgs = await page.$$eval("figure.memory-diagram img", (xs) => Promise.all(xs.map(async (i) => { i.scrollIntoView(); try { await i.decode(); } catch {} return { src: i.getAttribute("src"), complete: i.complete, w: i.naturalWidth, h: i.naturalHeight, alt: (i.getAttribute("alt") || "").length }; })));
    const csp = await page.evaluate(() => window.__csp);
    const ok = resp.status() === 200 && imgs.length === 6 && imgs.every((i) => i.complete && i.w > 0) && csp.length === 0 && errs.length === 0 && svgs.length === 6 && svgs.every((s) => s.startsWith("200 image/svg+xml") || s.startsWith("304"));
    failed ||= !ok;
    console.log(`ch07: ${engine} ${vp}: page ${resp.status()}, ${imgs.length} diagrams, ${imgs.filter((i) => i.complete && i.w > 0).length} rendered (${imgs.map((i) => `${i.w}x${i.h}`).join(" ")}), ${svgs.length} svg responses, ${csp.length} CSP violations, ${errs.length} console errors — ${ok ? "ok" : "FAIL"}`);
    for (const s of svgs) console.log(`  svg ${s}`);
    for (const e of [...csp, ...errs]) console.log(`  ! ${e}`);
    await ctx.close();
  }
  await browser.close();
}
if (server) await server.close();
console.log(`ch07: ${failed ? "FAILED" : "ok — six diagrams rendered on every cell, no CSP violation"}`);
process.exit(failed ? 1 : 0);
