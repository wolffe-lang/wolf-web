/* The gate wolf-web#35 asked for, and the planted case that proves it reds.
 *
 * The counted pin lag compares specification REVISIONS. At lupin 0.1.33 it was
 * zero — the interpreter's pin was the tag this site advertised — and both
 * /install/ and /play/ said `the same commit`. Correct arithmetic, incomplete
 * claim: the interpreter mirrors a clause ahead of its pin on purpose, and at
 * that pin it ran a one-line `if` the advertised compiler refused. A reader
 * could copy a program out of the playground and watch their compiler decline
 * it, and nothing here could have noticed.
 *
 * scripts/check-ahead.mjs runs each witness through the module the build
 * publishes and requires every one that RUNS to name an anchor the pinned
 * release declares. The first witness closed at v0.2.11 — `gram.expr.if` is in
 * the pinned spec/anchors.json now — so the live corpus is green, which is
 * exactly the state in which a gate is a claim rather than a measurement. The
 * planted witness below is the measurement.
 *
 * The module is a build artifact, so these tests stand down when dist/ is not
 * there: CI runs `node --test tests/*.test.mjs` BEFORE ./scripts/build.sh, and
 * runs this file again by name afterwards, when the module exists.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, writeFileSync, rmSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const script = join(root, "scripts", "check-ahead.mjs");
const dist = join(root, "dist");
const lang = join(root, "upstream", "wolf-lang");

const built =
  existsSync(join(dist, "play", "lupin.wasm")) &&
  existsSync(join(lang, "spec", "anchors.json"));
function notBuilt() {
  console.log("  (skipped: dist/play/lupin.wasm or the pinned anchors are not there)");
}

/** The one-line `if` of wolf-web#35 — the spelling the whole issue is about. */
const ONE_LINE_IF =
  'fn main() -> !int {\n    let n = 29\n    let m = if n > 10 then n - 1 else n + 1\n' +
  '    print("{n}")\n    print("{m}")\n    0\n}\n';

function gate(extra = []) {
  const done = spawnSync("node", [script, dist, lang, ...extra], {
    cwd: root,
    encoding: "utf-8",
  });
  return { status: done.status, stderr: done.stderr ?? "", stdout: done.stdout ?? "" };
}

function withWitnesses(witnesses) {
  const dir = mkdtempSync(join(tmpdir(), "ww27-ahead-"));
  const file = join(dir, "planted.json");
  try {
    writeFileSync(file, JSON.stringify({ witnesses }), "utf-8");
    return gate(["--witnesses", file]);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("the invocation CI makes is green", () => {
  if (!built) return notBuilt();
  const out = gate();
  assert.equal(out.status, 0, `expected a pass, got:\n${out.stderr}`);
  assert.match(out.stdout, /0 ahead of the release/);
});

test("the first witness runs on both sides now — it closed at v0.2.11", () => {
  if (!built) return notBuilt();
  const out = gate();
  assert.match(out.stdout, /a one-line if\s+exit\(0\)\s+both sides carry it/);
});

test("a program the module runs against a clause the release does not declare reds", () => {
  if (!built) return notBuilt();
  /* The planted defect: the same program, pointed at an anchor no release has
   * ever carried. This is wolf-web#35's shape exactly — the tab ahead of the
   * compiler — reproduced at a pin where the real witness is green. */
  const out = withWitnesses([
    {
      name: "a clause the release never declared",
      anchor: "gram.expr.neverexisted",
      stdout: "29\n28\n",
      program: ONE_LINE_IF,
    },
  ]);
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stderr, /does not declare gram\.expr\.neverexisted/);
  assert.match(out.stderr, /AHEAD of the release/);
  assert.match(out.stdout, /1 ahead of the release/);
});

test("a witness the module refuses is not a failure — the tab is simply not ahead", () => {
  if (!built) return notBuilt();
  const out = withWitnesses([
    {
      name: "a spelling neither machine has",
      anchor: "gram.expr.neverexisted",
      program: 'fn main() -> !int {\n    let q = ??? \n    0\n}\n',
    },
  ]);
  assert.equal(out.status, 0, `expected a pass, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stdout, /the module refuses it too/);
});

test("a witness that runs but answers differently reds — 'it runs' is a claim", () => {
  if (!built) return notBuilt();
  const out = withWitnesses([
    { name: "the if, misdeclared", anchor: "gram.expr.if", stdout: "1\n", program: ONE_LINE_IF },
  ]);
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stderr, /answers .* where the witness declares/);
});

test("--witnesses with no file named is a refusal", () => {
  const done = spawnSync("node", [script, "--witnesses"], { cwd: root, encoding: "utf-8" });
  assert.equal(done.status, 1);
  assert.match(done.stdout + done.stderr, /--witnesses needs a file/);
});

test("--witnesses naming a file that is not there is a refusal", () => {
  if (!built) return notBuilt();
  const out = gate(["--witnesses", "NO-SUCH-FILE.json"]);
  assert.equal(out.status, 1);
  assert.match(out.stdout + out.stderr, /no such file/);
});

test("a missing module is a refusal, not a silent pass", () => {
  const done = spawnSync("node", [script, join(tmpdir(), "ww27-no-such-dist"), lang], {
    cwd: root,
    encoding: "utf-8",
  });
  assert.equal(done.status, 1);
  assert.match(done.stdout + done.stderr, /run scripts\/build\.sh first/);
});
