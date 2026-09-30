/* The nginx gate: what lupp.us answers for the book, and what it sends with it.
 *
 * ww35. bs55 (wolf-book PR #65) found the maintainer's Contents 404s were the
 * site's CSP refusing the book theme's inline scripts, and fixed the book. Three
 * things were left for this config, and each is held here:
 *
 *   1. A miss under /book/ answers the BOOK's 404 page, which draws the book's
 *      sidebar at any depth — not the site's /404.html, which has none.
 *   2. The book's scripts are not fingerprinted, so a 7-day cache kept a
 *      returning reader on the old sidebar. The book revalidates instead.
 *   3. The CSP stays exactly as strict. An `add_header` inside a location
 *      REPLACES the server's whole set, so every location that sets one must
 *      repeat all four security headers, byte for byte — until ww35 the script,
 *      style and wasm locations sent none of them.
 *
 * The parser below reads only what this file needs: `location` blocks inside
 * the `server_name lupp.us;` server, and the directives directly in each.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const conf = readFileSync(join(root, "nginx", "lupp.us.conf"), "utf-8");

const SECURITY = ["X-Content-Type-Options", "Referrer-Policy", "X-Frame-Options", "Content-Security-Policy"];

/** Split a config into blocks: { head, body: [directive lines], children }. */
function parse(text) {
  const lines = text
    .split("\n")
    .map((l) => l.replace(/#.*$/, "").trim())
    .filter(Boolean);
  const top = { head: "", body: [], children: [] };
  const stack = [top];
  for (const line of lines) {
    const cur = stack[stack.length - 1];
    if (line.endsWith("{")) {
      const block = { head: line.slice(0, -1).trim(), body: [], children: [] };
      cur.children.push(block);
      stack.push(block);
      /* a one-line block: `location /docs/ { try_files ... }` */
    } else if (/\{.*\}$/.test(line)) {
      const head = line.slice(0, line.indexOf("{")).trim();
      const inner = line.slice(line.indexOf("{") + 1, -1).trim();
      cur.children.push({ head, body: inner.split(";").map((d) => d.trim()).filter(Boolean), children: [] });
    } else if (line === "}") {
      stack.pop();
    } else {
      cur.body.push(line.replace(/;$/, ""));
    }
  }
  return top;
}

const site = parse(conf).children.find(
  (b) => b.head === "server" && b.body.includes("server_name lupp.us"),
);

function locations(block) {
  return block.children.filter((c) => c.head.startsWith("location")).flatMap((c) => [c, ...locations(c)]);
}

const headers = (block) => block.body.filter((d) => d.startsWith("add_header"));

test("the site's server block is found", () => {
  assert.ok(site, "a server block with `server_name lupp.us;`");
  assert.ok(locations(site).length >= 5, "its locations parse");
});

test("CSP: every Content-Security-Policy line is the server's, byte for byte, and strict", () => {
  const csp = conf
    .split("\n")
    .filter((l) => l.includes("Content-Security-Policy"))
    .map((l) => l.trim());
  assert.ok(csp.length >= 1);
  for (const line of csp) {
    assert.equal(line, csp[0], "a repeated CSP may not differ from the server's");
  }
  assert.ok(!csp[0].includes("unsafe-inline"), "nothing inline, ever");
  assert.match(csp[0], /base-uri 'none'/, "base-uri stays 'none'");
  assert.match(csp[0], /script-src 'self' 'wasm-unsafe-eval';/, "no new script source");
});

test("every location that sets a header repeats all four security headers", () => {
  const server = headers(site);
  for (const name of SECURITY) {
    assert.ok(server.some((h) => h.includes(name)), `the server sets ${name}`);
  }
  for (const loc of locations(site)) {
    const own = headers(loc);
    if (own.length === 0) continue; // inherits the server's set
    for (const name of SECURITY) {
      const want = server.find((h) => h.includes(name));
      assert.ok(own.includes(want), `${loc.head}: sets headers of its own, so it must repeat \`${want}\``);
    }
  }
});

test("a miss under /book/ answers the book's 404 page", () => {
  const book = locations(site).find((l) => l.head === "location ^~ /book/");
  assert.ok(book, "the book's location is `^~ /book/`, so no regex location outranks it");
  assert.ok(book.body.includes("try_files $uri $uri/ $uri.html =404"), "the book keeps nginx's try_files");
  assert.ok(book.body.includes("error_page 404 /book/404.html"), "its misses get the book's own 404 page");
  assert.ok(site.body.includes("error_page 404 /404.html"), "the rest of the site keeps the site's 404 page");
});

test("the book revalidates: its unfingerprinted files are never cached blind", () => {
  const book = locations(site).find((l) => l.head === "location ^~ /book/");
  assert.ok(book, "the book's location exists");
  assert.ok(
    headers(book).some((h) => /Cache-Control "no-cache"/.test(h)),
    "the book answers Cache-Control: no-cache",
  );
  assert.ok(!book.body.some((d) => d.startsWith("expires")), "and sets no expiry that would outlive a deploy");
  for (const nested of locations(book)) {
    assert.ok(!nested.body.some((d) => d.startsWith("expires")), `${nested.head}: no expiry inside the book`);
  }
});
