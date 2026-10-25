/* Same approach as the book's contents gate: serve the build under nginx's
 * actual headers, then drive a real browser. No server config is deployed. */
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dist = path.join(root, "dist");
const conf = fs.readFileSync(path.join(root, "nginx/lupp.us.conf"), "utf8");
const headers = {};
for (const match of conf.matchAll(/^\s*add_header (X-Content-Type-Options|Referrer-Policy|X-Frame-Options|Content-Security-Policy) (?:"([^"]+)"|([^; ]+)) always;/gm)) {
  const value = match[2] ?? match[3];
  if (headers[match[1]] && headers[match[1]] !== value) throw new Error("nginx header copies differ");
  headers[match[1]] = value;
}
if (Object.keys(headers).length !== 4) throw new Error("production security headers were not found");
const types = { ".html": "text/html", ".css": "text/css", ".js": "application/javascript", ".txt": "text/plain; charset=utf-8", ".json": "application/json", ".svg": "image/svg+xml" };
const server = http.createServer((req, res) => {
  const url = new URL(req.url, "http://localhost");
  let body, type;
  if (url.pathname === "/__std_test__/") {
    body = '<!doctype html><title>Std browser gate</title><pre id="result">PENDING</pre><iframe id="page" width="390" height="720" title="Reference under test"></iframe><script src="/__std_test__/driver.js" defer></script>';
    type = "text/html";
  } else if (url.pathname === "/__std_test__/driver.js") {
    body = fs.readFileSync(path.join(root, "tests/std-browser-driver.js"));
    type = "application/javascript";
  } else {
    const target = path.resolve(dist, "." + decodeURIComponent(url.pathname));
    const file = [target, path.join(target, "index.html"), target + ".html"].find(p => {
      try { return p.startsWith(dist + path.sep) && fs.statSync(p).isFile(); } catch { return false; }
    });
    if (!file) { res.writeHead(404, headers); res.end("Not found"); return; }
    body = fs.readFileSync(file);
    type = types[path.extname(file)] ?? "application/octet-stream";
  }
  res.writeHead(200, { ...headers, "Content-Type": type });
  res.end(body);
});
await new Promise(resolve => server.listen(0, "127.0.0.1", resolve));
const url = `http://127.0.0.1:${server.address().port}`;
const targetDir = path.join(root, "target");
fs.mkdirSync(targetDir, { recursive: true });
const profiles = [];
const browser = process.env.CHROMIUM ?? "chromium";
async function render(route, js) {
  const profile = fs.mkdtempSync(path.join(targetDir, "std-chromium-"));
  profiles.push(profile);
  const args = ["--headless", "--disable-gpu", "--no-first-run", "--no-default-browser-check", "--disable-dev-shm-usage", "--disable-background-timer-throttling", "--run-all-compositor-stages-before-draw", "--user-data-dir=" + profile, "--virtual-time-budget=15000", "--dump-dom", ...(js ? [] : ["--blink-settings=scriptEnabled=false"]), url + route];
  const child = spawn(browser, args, { stdio: ["ignore", "pipe", "pipe"] });
  console.log(`std browser pid ${child.pid}: ${js ? "JS on" : "JS off"}, production headers from nginx config`);
  let stdout = "", stderr = "";
  child.stdout.on("data", data => { stdout += data; });
  child.stderr.on("data", data => { stderr += data; });
  const timer = setTimeout(() => child.kill(), 60000);
  try {
    await new Promise((resolve, reject) => {
      child.on("error", reject);
      child.on("exit", code => code === 0 ? resolve() : reject(new Error(`browser exit ${code}: ${stderr}`)));
    });
    return stdout;
  } finally { clearTimeout(timer); }
}
try {
  const html = await render("/__std_test__/", true);
  const result = /<pre id="result">([^<]+)<\/pre>/.exec(html)?.[1];
  if (!result?.startsWith("PASS:")) throw new Error(result ?? "browser produced no result");
  console.log(result);
  // The JS-off harness is an HTTP render: no scripts are executed.
  const off = await (await fetch(url + "/std/fs/")).text();
  if (!off.includes('id="std-toc"') || !off.includes('href="#read_text"') || /class="[^"]*std-enhanced/.test(off)) throw new Error("std JS-off inline contents failed");
  console.log("PASS: std JS-off fetch keeps inline contents and item anchors");
} finally {
  await new Promise(resolve => server.close(resolve));
  for (const profile of profiles) fs.rmSync(profile, { recursive: true, force: true });
}
