/* Every program in the playground's menu, fed to the module the build
 * publishes, through the same export the page calls.
 *
 *     usage: node scripts/check-samples.mjs <dist-dir> [<pinned-corpus-dir>]
 *
 * The menu is a promise: a visitor picks a label and expects a program that
 * does something. scripts/collect-samples.py could only ever check the
 * corpus header's `phase: run` directive, which is the COMPILER's claim about
 * the program — it says nothing about what the interpreter in the tab does
 * with it, and the two are not the same machine. A sample that the pinned
 * lupin declines looks broken, and for a while nothing could have caught one.
 *
 * So the rule this file holds is the one the menu actually needs, and it runs
 * in BOTH directions:
 *
 *   an entry with NO note must answer `exit` or `trap` — it runs, or it
 *   traps on purpose, which is a thing three of the samples are for;
 *
 *   an entry WITH a note must NOT — the note exists precisely because the
 *   program does not run here, and a note that outlived its refusal is a
 *   sentence on the page that has stopped being true.
 *
 * The second half is the one that retires itself. When the interpreter pin
 * moves past the release that refuses the program, the gate goes red, and
 * the note comes off because it has to rather than because someone
 * remembered.
 *
 * Since ww19 it holds a second claim, for the same reason and against the
 * same module. /play/ says how many of the corpus's net programs the browser
 * build declines, and that number was written by hand and wrong for two
 * releases (wolf-web#17). The number is a __COUNT_netprograms_ stamp now,
 * counted off `corpus/net/` in the pinned checkout — but a count of the
 * directory is only the right number if the whole directory really does
 * answer `unsupported`, and nothing said so. So every `.lu` file in
 * `corpus/net/` goes through the module here and every one must decline.
 * When a browser grows sockets, or the interpreter starts serving one of
 * them some other way, this is what says the sentence has to change.
 *
 * No dependencies: node's own WebAssembly, and the wasm ABI documented in
 * crates/lupin-wasm/src/lib.rs — a result is a pointer to four bytes of
 * little-endian length followed by that many bytes of UTF-8 JSON, and the
 * caller frees it. This is the same ABI site/play/lupin.js uses, on purpose:
 * a gate that talked to the module a different way would be proving
 * something about itself.
 */
import fs from "node:fs";
import path from "node:path";

const dist = process.argv[2] || "dist";
const corpus = process.argv[3] || path.join("upstream", "wolf-lang", "corpus");
const wasmPath = path.join(dist, "play", "lupin.wasm");
const indexPath = path.join(dist, "play", "samples", "index.json");
const netDir = path.join(corpus, "net");

for (const f of [wasmPath, indexPath]) {
  if (!fs.existsSync(f)) {
    console.error(`check-samples: ${f} is missing — run scripts/build.sh first`);
    process.exit(1);
  }
}
if (!fs.existsSync(netDir)) {
  console.error(
    `check-samples: ${netDir} is missing — the net half needs the pinned corpus; ` +
      `pass it as the second argument, or run: git submodule update --init`,
  );
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

const { samples } = JSON.parse(fs.readFileSync(indexPath, "utf8"));
if (!samples || samples.length === 0) {
  console.error("check-samples: the sample index is empty");
  process.exit(1);
}

/* The classes a menu entry may answer in without a note. `trap` is here
 * deliberately: four samples exist to show a checked fault stopping a
 * program, and each one's own corpus header says so. */
const RUNS = new Set(["exit", "trap"]);

let failures = 0;
const rows = [];
for (const sample of samples) {
  const file = path.join(dist, "play", "samples", sample.name);
  let verdict;
  try {
    verdict = String(observe(fs.readFileSync(file, "utf8")).verdict ?? "?");
  } catch (cause) {
    /* A module that trapped is unusable; a fresh instance costs nothing and
     * the remaining samples still get measured. */
    verdict = `the module trapped (${cause.message})`;
    exports = new WebAssembly.Instance(compiled, {}).exports;
  }
  const runs = RUNS.has(verdict.split("(")[0]);
  const noted = Boolean(sample.note);
  let problem = "";
  if (!noted && !runs) {
    problem =
      "answers outside exit/trap with no note beside it — a menu entry that " +
      "cannot run looks broken; give it a note in scripts/collect-samples.py " +
      "or take it off the menu";
  } else if (noted && runs) {
    problem =
      "runs at this pin, and still carries the note that says it does not — " +
      "retire the note in scripts/collect-samples.py";
  }
  if (problem) failures++;
  rows.push({ title: sample.title, corpus: sample.corpus_path, verdict, noted, problem });
}

const width = Math.max(...rows.map((r) => r.corpus.length));
for (const row of rows) {
  const mark = row.problem ? "FAIL" : "ok  ";
  const note = row.noted ? "  (noted)" : "";
  console.log(`  ${mark} ${row.corpus.padEnd(width)}  ${row.verdict}${note}`);
  if (row.problem) console.log(`       ${row.corpus}: ${row.problem}`);
}

if (failures > 0) {
  console.error(
    `\ncheck-samples: ${failures} of ${rows.length} menu entries do not match ` +
      `what the page says about them`,
  );
  process.exit(1);
}
console.log(
  `\ncheck-samples: ${rows.length} menu entries, each in the class the page ` +
    `claims for it (${rows.filter((r) => r.noted).length} noted as not running here)`,
);

/* The net directory, whole. /play/ counts it and says every one of them is
 * declined here; the count is stamped off this directory, and this is the
 * half that makes counting it the right thing to do. */
const netFiles = fs.readdirSync(netDir).filter((f) => f.endsWith(".lu")).sort();
if (netFiles.length === 0) {
  console.error(`check-samples: ${netDir} carries no .lu programs — the count would be zero`);
  process.exit(1);
}
const served = [];
for (const name of netFiles) {
  let verdict;
  try {
    verdict = String(observe(fs.readFileSync(path.join(netDir, name), "utf8")).verdict ?? "?");
  } catch (cause) {
    verdict = `the module trapped (${cause.message})`;
    exports = new WebAssembly.Instance(compiled, {}).exports;
  }
  if (verdict.split("(")[0] !== "unsupported") served.push(`${name} ${verdict}`);
}
if (served.length > 0) {
  console.error(
    `\ncheck-samples: ${served.length} of ${netFiles.length} programs in ` +
      `${netDir} do NOT answer unsupported in this build:`,
  );
  for (const row of served) console.error(`       ${row}`);
  console.error(
    `       /play/ counts that directory and says the browser declines all of ` +
      `it — rewrite the sentence, then decide what the count should be off`,
  );
  process.exit(1);
}
console.log(
  `check-samples: all ${netFiles.length} programs in ${netDir} answer ` +
    `unsupported, which is what /play/ counts`,
);
