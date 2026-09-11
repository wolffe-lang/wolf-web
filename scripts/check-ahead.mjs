/* The tab must not run what the advertised compiler does not carry.
 *
 *     usage: node scripts/check-ahead.mjs <dist-dir> [<pinned-wolf-lang-dir>]
 *                                         [--witnesses <file>]
 *
 * The `the specification pin lag the site records` step in
 * .github/workflows/windows.yml computes the distance between two
 * SPECIFICATION REVISIONS by ancestry, and holds /install/ and /play/ to the
 * phrase for the number it gets. At lupin 0.1.33 it was zero:
 * the interpreter's pin WAS the tag this site advertised, and both pages said
 * `the same commit`. That was correct arithmetic and an incomplete claim, and
 * the difference was visible to a reader for the first time at that pin —
 * lupin 0.1.33 ran a one-line `if` that wolf v0.2.10 refused, because the
 * clause had been read from the compiler's trunk AFTER the tag, deliberately
 * and with the interpreter's release notes saying so (wolf-web#35).
 *
 * Nothing on this site could notice, for three reasons, and each of them is
 * structural rather than an oversight:
 *
 *   the lag compares revisions, not behaviour — gap zero says both machines
 *   were built to one text, not that they answer alike;
 *
 *   the divergence census only walks the PINNED corpus, so a clause that is
 *   in neither the release nor its corpus has no witness to walk, and the
 *   census correctly reports no moved rows;
 *
 *   every parting this site had ever described ran the other way (compiler
 *   ahead, tab refusing), so the prose had no vocabulary for "the tab runs
 *   something your compiler will not" — which is the failure a reader
 *   actually hits, copying a program out of the playground.
 *
 * So this is the gate. Each witness in scripts/ahead-witnesses.json is a
 * program and the spec anchor whose clause it needs. Every one is fed to the
 * module the build published, and:
 *
 *   if it RUNS, the anchor must be present in the pinned compiler's
 *   spec/anchors.json, and the program must answer the stdout the witness
 *   declares. A program that runs here against a clause the release does not
 *   declare is exactly wolf-web#35's defect and reddens the build.
 *
 *   if it does NOT run, that is the ordinary state — the tab is not ahead on
 *   that clause — and the witness simply waits. An entry is never retired for
 *   going quiet; it is retired when the clause it names stops existing.
 *
 * The anchor list is the compiler RELEASE's own declaration of what it
 * carries, read off the pinned checkout rather than inferred, which is the
 * same discipline every other audit here uses. The module is reached through
 * the ABI in crates/lupin-wasm/src/lib.rs, the one site/play/lupin.js uses —
 * a gate that talked to the module a different way would be proving something
 * about itself.
 */
import fs from "node:fs";
import path from "node:path";

const argv = process.argv.slice(2);
let witnessPath = path.join("scripts", "ahead-witnesses.json");
while (argv.includes("--witnesses")) {
  const i = argv.indexOf("--witnesses");
  if (i + 1 >= argv.length) {
    console.error("check-ahead: --witnesses needs a file");
    process.exit(1);
  }
  witnessPath = argv[i + 1];
  argv.splice(i, 2);
}

const dist = argv[0] || "dist";
const lang = argv[1] || path.join("upstream", "wolf-lang");
const wasmPath = path.join(dist, "play", "lupin.wasm");
const anchorPath = path.join(lang, "spec", "anchors.json");

if (!fs.existsSync(wasmPath)) {
  console.error(`check-ahead: ${wasmPath} is missing — run scripts/build.sh first`);
  process.exit(1);
}
if (!fs.existsSync(anchorPath)) {
  console.error(
    `check-ahead: ${anchorPath} is missing — the gate holds the module against the ` +
      `pinned compiler's own declaration; run: git submodule update --init`,
  );
  process.exit(1);
}
if (!fs.existsSync(witnessPath)) {
  console.error(`check-ahead: ${witnessPath}: no such file`);
  process.exit(1);
}

const declared = JSON.parse(fs.readFileSync(anchorPath, "utf8")).anchors;
if (!declared || typeof declared !== "object") {
  console.error(`check-ahead: ${anchorPath} declares no anchors`);
  process.exit(1);
}
const { witnesses } = JSON.parse(fs.readFileSync(witnessPath, "utf8"));
if (!Array.isArray(witnesses) || witnesses.length === 0) {
  console.error(`check-ahead: ${witnessPath} carries no witnesses`);
  process.exit(1);
}

const compiled = await WebAssembly.compile(fs.readFileSync(wasmPath));
let exports = new WebAssembly.Instance(compiled, {}).exports;
const encoder = new TextEncoder();
const decoder = new TextDecoder();
const memory = () => new Uint8Array(exports.memory.buffer);

function takeResult(pointer) {
  const view = memory();
  const length =
    view[pointer] |
    (view[pointer + 1] << 8) |
    (view[pointer + 2] << 16) |
    (view[pointer + 3] << 24);
  const text = decoder.decode(view.subarray(pointer + 4, pointer + 4 + length));
  exports.lupin_result_free(pointer);
  return JSON.parse(text);
}

function observe(source) {
  const bytes = encoder.encode(source);
  const pointer = exports.lupin_alloc(bytes.length);
  memory().set(bytes, pointer);
  try {
    return takeResult(exports.lupin_observe(pointer, bytes.length));
  } finally {
    exports.lupin_free(pointer, bytes.length);
  }
}

/* `trap` counts as running: the program reached the interpreter's runtime,
 * which is the only thing this gate asks. A tier refusal or a parse error
 * does not. */
const RUNS = new Set(["exit", "trap"]);

let failures = 0;
let ahead = 0;
const rows = [];
for (const w of witnesses) {
  for (const field of ["name", "anchor", "program"]) {
    if (typeof w[field] !== "string") {
      console.error(`check-ahead: a witness is missing its ${field}`);
      process.exit(1);
    }
  }
  let observed;
  try {
    observed = observe(w.program);
  } catch (cause) {
    observed = { verdict: `the module trapped (${cause.message})`, stdout: "" };
    exports = new WebAssembly.Instance(compiled, {}).exports;
  }
  const verdict = String(observed.verdict ?? "?");
  const runs = RUNS.has(verdict.split("(")[0]);
  const carried = Object.prototype.hasOwnProperty.call(declared, w.anchor);
  let problem = "";
  if (runs && !carried) {
    problem =
      `runs here and the pinned compiler does not declare ${w.anchor} — the tab is ` +
      `AHEAD of the release this site advertises, so a reader can copy this out of ` +
      `the playground and watch their compiler refuse it. The counted pin lag cannot ` +
      `see this: it compares revisions, not behaviour.`;
  } else if (runs && typeof w.stdout === "string" && (observed.stdout ?? "") !== w.stdout) {
    problem =
      `runs, but answers ${JSON.stringify(observed.stdout ?? "")} where the witness ` +
      `declares ${JSON.stringify(w.stdout)} — "it runs" is only a claim about ` +
      `${w.anchor} if it answers the way the clause says it should`;
  }
  if (problem) failures++;
  if (runs && carried) ahead++;
  rows.push({ name: w.name, anchor: w.anchor, verdict, runs, carried, problem });
}

const width = Math.max(...rows.map((r) => r.name.length));
for (const r of rows) {
  const state = r.problem
    ? "AHEAD OF THE RELEASE"
    : r.runs
      ? "both sides carry it"
      : "the module refuses it too";
  console.log(`  ${r.name.padEnd(width)}  ${r.verdict.padEnd(12)} ${state}`);
  if (r.problem) console.error(`check-ahead: ${r.name}: ${r.problem}`);
}
console.log(
  `check-ahead: ${witnesses.length} witness(es) against the built module and ` +
    `${Object.keys(declared).length} anchors the pinned release declares — ` +
    `${ahead} run on both sides, ${witnesses.length - ahead - failures} not yet ` +
    `mirrored here, ${failures} ahead of the release`,
);
process.exit(failures ? 1 : 0);
