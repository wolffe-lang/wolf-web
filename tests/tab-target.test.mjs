/* Ruling #37 = B (wolf-web#55): the tab reads `cfg(target = …)` as
 * x86_64-unknown-linux-gnu.
 *
 * lupin evaluates `#[cfg(target = "…")]` against the target it was built
 * for (`wolf_interp::attrs::build_target`, cargo's TARGET). This module is
 * built for wasm32-unknown-unknown, which no `cfg` in the corpus names, so
 * before the ruling `corpus/grammar/cfg_target_arch.lu` — one function
 * defined twice, gated to `x86_64` and to `aarch64` — lost both definitions
 * and the tab answered `unsupported` ("`arch_bits` does not resolve") where
 * every compiler tier and lupin at a terminal print `64`. The bridge now runs
 * every observation under `with_build_target(BUNDLE_TARGET, …)`, the target
 * lupin's own conformance bundle is observed as, and says so in
 * `lupin_version()`.
 *
 * These tests hold the module the build publishes, through the ABI
 * site/play/lupin.js uses, not a host build of the crate: the defect only
 * exists in the wasm build, so only the wasm build can witness it.
 *
 * The module is a build artifact. CI runs `node --test tests/*.test.mjs`
 * BEFORE ./scripts/build.sh, where these stand down, and runs this file again
 * by name afterwards with WOLF_WEB_REQUIRE_MODULE=1, where a missing module
 * is a failure rather than a skip.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const wasmPath = join(root, "dist", "play", "lupin.wasm");
const corpus = join(root, "upstream", "wolf-lang", "corpus");
const TARGET = "x86_64-unknown-linux-gnu";

const built = existsSync(wasmPath) && existsSync(corpus);
const required = process.env.WOLF_WEB_REQUIRE_MODULE === "1";

function standDown() {
  if (required) {
    assert.fail(`WOLF_WEB_REQUIRE_MODULE=1 and ${wasmPath} or ${corpus} is missing`);
  }
  console.log("  (skipped: dist/play/lupin.wasm or the pinned corpus is not there)");
}

let exportsCache = null;
async function module() {
  if (!exportsCache) {
    const compiled = await WebAssembly.compile(readFileSync(wasmPath));
    exportsCache = new WebAssembly.Instance(compiled, {}).exports;
  }
  return exportsCache;
}

const encoder = new TextEncoder();
const decoder = new TextDecoder();

function take(ex, pointer) {
  const view = new Uint8Array(ex.memory.buffer);
  const length =
    view[pointer] | (view[pointer + 1] << 8) | (view[pointer + 2] << 16) | (view[pointer + 3] << 24);
  const text = decoder.decode(view.subarray(pointer + 4, pointer + 4 + length));
  ex.lupin_result_free(pointer);
  return JSON.parse(text);
}

function call(ex, entry, source) {
  const bytes = encoder.encode(source);
  const buffer = ex.lupin_alloc(bytes.length);
  new Uint8Array(ex.memory.buffer).set(bytes, buffer);
  try {
    return take(ex, ex[entry](buffer, bytes.length));
  } finally {
    ex.lupin_free(buffer, bytes.length);
  }
}

const program = (rel) => readFileSync(join(corpus, rel), "utf-8");

test("cfg_target_arch.lu prints 64 in the tab, as it does at a terminal", async () => {
  if (!built) return standDown();
  const ex = await module();
  const seen = call(ex, "lupin_observe", program("grammar/cfg_target_arch.lu"));
  assert.equal(seen.verdict, "exit(0)", `the tab answered ${JSON.stringify(seen)}`);
  assert.equal(seen.stdout, "64\n");
  assert.equal(seen.stderr, "");
  assert.equal(seen.unsupported, null);
});

test("the record the tab shows says the same", async () => {
  if (!built) return standDown();
  const ex = await module();
  const line = call(ex, "lupin_record", program("grammar/cfg_target_arch.lu"));
  assert.ok(line.record, `no record: ${JSON.stringify(line)}`);
  const record = JSON.parse(line.record);
  assert.equal(record.verdict, "exit(0)", line.record);
  assert.equal(record.stdout_inline, "64\n");
});

test("the freestanding target is still not this one", async () => {
  if (!built) return standDown();
  const ex = await module();
  const seen = call(ex, "lupin_observe", program("grammar/cfg_target_freestanding.lu"));
  assert.equal(seen.verdict, "exit(0)", JSON.stringify(seen));
  assert.equal(seen.stdout, "hosted\n1\n");
});

test("a gate on the other architecture is dropped, as on an x86-64 host", async () => {
  if (!built) return standDown();
  const ex = await module();
  const source =
    '#[cfg(target = "aarch64")]\nfn which() -> int {\n    2\n}\n\n' +
    '#[cfg(target = "x86_64-unknown-linux-gnu")]\nfn which() -> int {\n    1\n}\n\n' +
    'fn main() -> int {\n    print("{which()}")\n    0\n}\n';
  const seen = call(ex, "lupin_observe", source);
  assert.equal(seen.verdict, "exit(0)", JSON.stringify(seen));
  assert.equal(seen.stdout, "1\n");
});

test("the module states the target it reads cfg as", async () => {
  if (!built) return standDown();
  const ex = await module();
  const version = take(ex, ex.lupin_version());
  assert.equal(version.target, TARGET, JSON.stringify(version));
});
