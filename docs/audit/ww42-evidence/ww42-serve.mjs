// ww42: a loopback static server for a staged dist/, answering with the response headers nginx/lupp.us.conf
// sends (read out of that file, never typed here): the four server-level add_header lines, wasm as
// application/wasm, .md/.ebnf as text/plain, try_files $uri $uri/ $uri.html, /book/ misses to /book/404.html
// and every other miss to /404.html, both with status 404.
//   node ww42-serve.mjs <dist> <nginx/lupp.us.conf> <port>     (binds 127.0.0.1 only; prints its pid)
import http from "node:http"; import fs from "node:fs"; import path from "node:path";
const [root, conf, port] = process.argv.slice(2);
const text = fs.readFileSync(conf, "utf8");
const server = text.slice(text.indexOf("listen 443"));
const headers = {};
for (const m of server.slice(0, server.indexOf("location /")).matchAll(/^\s*add_header\s+(\S+)\s+(?:"([^"]*)"|(\S+))\s+always;/gm)) headers[m[1]] = m[2] ?? m[3];
if (!headers["Content-Security-Policy"]) { console.error("no CSP read from the nginx config"); process.exit(2); }
const TYPES = { ".html": "text/html", ".js": "application/javascript", ".mjs": "application/javascript", ".css": "text/css", ".json": "application/json", ".wasm": "application/wasm", ".svg": "image/svg+xml", ".png": "image/png", ".ico": "image/x-icon", ".woff": "font/woff", ".woff2": "font/woff2", ".pdf": "application/pdf", ".md": "text/plain; charset=utf-8", ".ebnf": "text/plain; charset=utf-8", ".txt": "text/plain", ".lu": "application/octet-stream", ".xml": "text/xml" };
const file = (p) => { try { return fs.statSync(p).isFile() ? p : null; } catch { return null; } };
const dir = (p) => { try { return fs.statSync(p).isDirectory(); } catch { return false; } };
http.createServer((req, res) => {
  const u = decodeURIComponent(new URL(req.url, "http://x").pathname);
  const p = path.join(root, path.normalize(u));
  if (!p.startsWith(path.resolve(root))) { res.writeHead(403, headers); return res.end(); }
  let hit = file(p), status = 200;
  if (!hit && dir(p)) {
    if (!u.endsWith("/")) { res.writeHead(301, { ...headers, Location: u + "/" }); return res.end(); }
    hit = file(path.join(p, "index.html"));
  }
  if (!hit) hit = file(p + ".html");
  if (!hit) { status = 404; hit = file(path.join(root, u.startsWith("/book/") ? "book/404.html" : "404.html")); }
  if (!hit) { res.writeHead(404, headers); return res.end("404"); }
  const h = { ...headers, "Content-Type": TYPES[path.extname(hit)] || "application/octet-stream" };
  if (u.startsWith("/book/")) h["Cache-Control"] = "no-cache";
  res.writeHead(status, h); fs.createReadStream(hit).pipe(res);
}).listen(Number(port), "127.0.0.1", () => console.log(`serving ${root} on http://127.0.0.1:${port} pid ${process.pid}; CSP: ${headers["Content-Security-Policy"]}`));
