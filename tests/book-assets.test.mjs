/* The book's scripts and styles carry the book's pin (ww35).
 *
 * scripts/version-book-assets.py rewrites every same-origin `.js` and `.css`
 * reference in the book's pages to `?v=<pin>`, so a returning reader whose
 * browser cached the old `toc.js` for a week asks for the new one the first
 * time a new page names it. The fixture below is the shapes the rendered book
 * carries — a page at the root, one a directory down, and the 404 page whose
 * links are absolute under /book/ — beside the shapes it must leave alone.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const script = join(root, "scripts", "version-book-assets.py");

function run(files, pin = "bd3484e") {
  const dir = mkdtempSync(join(tmpdir(), "ww35-book-"));
  try {
    for (const [name, body] of Object.entries(files)) {
      mkdirSync(dirname(join(dir, name)), { recursive: true });
      writeFileSync(join(dir, name), body);
    }
    const r = spawnSync("python3", [script, dir, pin], { encoding: "utf-8" });
    const out = {};
    for (const name of Object.keys(files)) out[name] = readFileSync(join(dir, name), "utf-8");
    return { status: r.status, stdout: r.stdout, stderr: r.stderr, out };
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

const CHAPTER = [
  '<link rel="stylesheet" href="css/chrome.css">',
  '<script src="toc.js"></script>',
  '<script src="wolf-boot.js"></script>',
  '<script src="https://example.com/x.js"></script>',
  '<script src="//cdn.example/y.js"></script>',
  '<a href="ch08.html">next</a>',
  '<link rel="icon" href="favicon.svg">',
].join("\n");

test("every local script and stylesheet reference gains ?v=<pin>, nothing else moves", () => {
  const r = run({
    "ch07.html": CHAPTER,
    "front/how-to-read.html": '<script src="../toc.js"></script><link href="../css/general.css" rel="stylesheet">',
    "404.html": '<script src="/book/toc.js"></script><link rel="stylesheet" href="/book/css/variables.css">',
  });
  assert.equal(r.status, 0, r.stderr);
  const ch = r.out["ch07.html"];
  assert.match(ch, /href="css\/chrome\.css\?v=bd3484e"/);
  assert.match(ch, /src="toc\.js\?v=bd3484e"/);
  assert.match(ch, /src="wolf-boot\.js\?v=bd3484e"/);
  assert.match(ch, /src="https:\/\/example\.com\/x\.js"/, "a foreign URL is not this build's to version");
  assert.match(ch, /src="\/\/cdn\.example\/y\.js"/, "nor a protocol-relative one");
  assert.match(ch, /href="ch08\.html"/, "a page link is navigation, not an asset");
  assert.match(ch, /href="favicon\.svg"/);
  assert.match(r.out["front/how-to-read.html"], /src="\.\.\/toc\.js\?v=bd3484e"/);
  assert.match(r.out["front/how-to-read.html"], /href="\.\.\/css\/general\.css\?v=bd3484e"/);
  assert.match(r.out["404.html"], /src="\/book\/toc\.js\?v=bd3484e"/);
  assert.match(r.stdout, /7 script and stylesheet reference\(s\) across 3 of 3 page\(s\)/);
});

test("a second pass versions nothing twice, and so refuses the zero", () => {
  const r = run({ "ch07.html": '<script src="toc.js?v=dadc38b"></script>' });
  assert.equal(r.status, 1);
  assert.match(r.stderr, /refusing a zero/);
});

test("a book with no assets to version is refused, not reported as done", () => {
  const r = run({ "ch07.html": "<p>no scripts</p>" });
  assert.equal(r.status, 1);
  assert.match(r.stderr, /refusing a zero/);
});

test("the pin is seven hex characters", () => {
  const r = run({ "ch07.html": CHAPTER }, "bd3484edd6");
  assert.equal(r.status, 2);
  assert.match(r.stderr, /seven hex/);
});
