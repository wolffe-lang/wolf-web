/* The commit distance crossed 999 at ww46. Keep its prose spelling a
 * measured stamp, including the first value the old stamper refused. */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const script = join(dirname(fileURLToPath(import.meta.url)), "..", "scripts", "stamp-counts.py");
function spell(n) {
  return spawnSync("python3", ["-I", "-c",
    "import runpy,sys; print(runpy.run_path(sys.argv[1])['word'](int(sys.argv[2])))", script, String(n)],
    { encoding: "utf-8" });
}
for (const [n, want] of [
  [0, "zero"], [99, "ninety-nine"], [100, "one hundred"],
  [999, "nine hundred and ninety-nine"], [1000, "one thousand"],
  [1067, "one thousand and sixty-seven"], [1100, "one thousand one hundred"],
  [1101, "one thousand one hundred and one"],
  [999999, "nine hundred and ninety-nine thousand nine hundred and ninety-nine"],
]) {
  test(`the count stamp spells ${n}`, () => {
    const done = spell(n);
    assert.equal(done.status, 0, done.stderr);
    assert.equal(done.stdout.trim(), want);
  });
}
for (const n of [-1, 1000000]) {
  test(`the count stamp refuses ${n}`, () => {
    const done = spell(n);
    assert.notEqual(done.status, 0);
    assert.match(done.stderr, new RegExp(`no prose spelling for ${n}`));
  });
}
