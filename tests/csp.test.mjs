/* The CSP gate: the editor grew features, the policy grew nothing.
 *
 * The house doctrine for the playground is that everything is built, not
 * imported: no npm, no CDN, no wasm-bindgen, no eval, no inline scripts.
 * The nginx CSP is the enforcement — `script-src 'self' 'wasm-unsafe-eval'`
 * and not one source more — and this test is the tripwire that a change
 * widening it, or a page quietly needing it widened, fails CI instead of
 * shipping.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

test("nginx CSP: script-src is 'self' 'wasm-unsafe-eval', exactly", () => {
  const conf = readFileSync(join(root, "nginx", "lupp.us.conf"), "utf-8");
  const line = conf
    .split("\n")
    .find((l) => l.includes("Content-Security-Policy"));
  assert.ok(line, "the config sets a Content-Security-Policy header");
  const scriptSrc = /script-src ([^;]*)/.exec(line);
  assert.ok(scriptSrc, "the policy has a script-src directive");
  assert.equal(scriptSrc[1].trim(), "'self' 'wasm-unsafe-eval'");
  assert.match(line, /style-src 'self'[;"]/, "styles come from the site alone");
  assert.ok(!line.includes("unsafe-inline"), "nothing inline, ever");
});

function htmlFiles(dir) {
  const out = [];
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) out.push(...htmlFiles(path));
    else if (name.endsWith(".html")) out.push(path);
  }
  return out;
}

test("site pages: no inline scripts, no inline styles, no foreign sources", () => {
  for (const page of htmlFiles(join(root, "site"))) {
    const html = readFileSync(page, "utf-8");
    for (const tag of html.match(/<script[^>]*>/g) ?? []) {
      assert.match(tag, /\bsrc="\//, `${page}: every script is same-origin by path: ${tag}`);
    }
    assert.ok(!/<style[\s>]/.test(html), `${page}: no <style> blocks`);
    assert.ok(!/\sstyle="/.test(html), `${page}: no style attributes`);
    assert.ok(!/\son\w+="/.test(html), `${page}: no inline event handlers`);
    /* href navigation is not a resource load; src is. Nothing the page
     * LOADS may leave the origin. */
    for (const src of html.match(/\bsrc="https?:\/\/[^"]*"/g) ?? []) {
      assert.fail(`${page}: a foreign source slipped in: ${src}`);
    }
    for (const link of html.match(/<link[^>]*href="https?:\/\/[^"]*"[^>]*>/g) ?? []) {
      assert.fail(`${page}: a foreign stylesheet or preload slipped in: ${link}`);
    }
  }
});

test("the editor is dependency-free: its modules import only each other", () => {
  for (const file of ["editor.js", "editor-core.js", "lupin.js"]) {
    const source = readFileSync(join(root, "site", "play", file), "utf-8");
    for (const spec of source.match(/from\s+"[^"]*"/g) ?? []) {
      assert.match(spec, /from\s+"\.\/(editor|editor-core)\.js"/, `${file}: ${spec}`);
    }
    assert.ok(!source.includes("eval("), `${file}: no eval`);
    assert.ok(!source.includes("innerHTML"), `${file}: no markup injection`);
  }
});
