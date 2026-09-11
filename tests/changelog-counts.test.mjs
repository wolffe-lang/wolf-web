/* The count audit's second root: this repository's own CHANGELOG.md.
 *
 * render-changelog.py turns CHANGELOG.md into /changelog/site/, so every
 * sentence in it is a page a reader can load — but both prose audits take
 * `site/` as their root and CHANGELOG.md is not under it, so its numbers were
 * held by nothing (wolf-web#27). ww24's own entry went out claiming three
 * counts of its allowlists, two of them wrong, in a paragraph whose subject
 * was the discipline of counting, and the build was green over it from the
 * first commit to the last.
 *
 * check-counts.py takes `--also <file>` now, and build.sh passes
 * `--also CHANGELOG.md`. A gate nobody has watched fail is a claim, so this
 * plants an unlisted number word in a file the flag names and proves it reds,
 * proves the invocation build.sh actually makes is green, and proves the flag
 * is what carries the CHANGELOG.md block — drop it and the allowlist is left
 * naming a file the walk never reads.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, writeFileSync, rmSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const script = join(root, "scripts", "check-counts.py");
const roots = ["site", "upstream/wolf-lang", "upstream/wolf-interp", "upstream/wolf-book"];

/* The audit reads its pins out of the pinned checkouts, so the tests that run
 * it need them. The editor-suites job on the Windows runner checks this
 * repository out WITHOUT submodules, the way tests/revision-prose.test.mjs
 * already accounts for, so those tests say so and stand down rather than
 * reporting the absence as a defect. The argument-error tests below need no
 * checkout at all, by construction — check-counts.py validates --also while it
 * is reading its arguments. */
const pinned = existsSync(join(root, "upstream", "wolf-lang", "CHANGELOG.md"));
function noPins() {
  console.log("  (skipped: upstream/ is not checked out)");
}

/** The audit, run from the repo root so that every path is the spelling
 * build.sh uses — the allowlist is keyed on the path as written. */
function audit(args) {
  const done = spawnSync("python3", [script, ...args, ...roots], {
    cwd: root,
    encoding: "utf-8",
  });
  return { status: done.status, stderr: done.stderr ?? "", stdout: done.stdout ?? "" };
}

/** build.sh's invocation, plus one more root holding `text`. */
function withPlanted(text) {
  const dir = mkdtempSync(join(tmpdir(), "ww25-counts-"));
  const file = join(dir, "PLANTED.md");
  try {
    writeFileSync(file, text, "utf-8");
    return audit(["--also", "CHANGELOG.md", "--also", file]);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("the invocation build.sh makes is green", () => {
  if (!pinned) return noPins();
  const out = audit(["--also", "CHANGELOG.md"]);
  assert.equal(out.status, 0, `expected a pass, got:\n${out.stderr}`);
  assert.match(out.stdout, /number word\(s\) in \d+ entries/);
});

test("a number word in an --also file that the allowlist does not carry reds", () => {
  if (!pinned) return noPins();
  const out = withPlanted("The lane re-read seventeen sentences and stood by all of them.\n");
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stderr, /'seventeen'/);
  assert.match(out.stderr, /PLANTED\.md/);
});

test("an --also file that counts nothing is no trouble", () => {
  if (!pinned) return noPins();
  const out = withPlanted("The pin moved and nothing on the page counted anything.\n");
  assert.equal(out.status, 0, `expected a pass, got:\n${out.stderr}`);
});

test("--also is what carries the CHANGELOG.md block: without it the allowlist is stale", () => {
  if (!pinned) return noPins();
  const out = audit([]);
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stderr, /count-allowlist\.txt lists .* in CHANGELOG\.md/);
});

test("the key is the path as written, not the file it resolves to", () => {
  if (!pinned) return noPins();
  const out = audit(["--also", join(root, "CHANGELOG.md")]);
  assert.equal(out.status, 1, "an absolute path is a different key than CHANGELOG.md");
});

test("--also with no file named is a refusal, not a silent skip", () => {
  const done = spawnSync("python3", [script, "--also"], { cwd: root, encoding: "utf-8" });
  assert.equal(done.status, 1);
  assert.match(done.stdout + done.stderr, /--also needs a file/);
});

test("--also naming a file that is not there is a refusal", () => {
  const out = audit(["--also", "NO-SUCH-FILE.md"]);
  assert.equal(out.status, 1);
  assert.match(out.stdout + out.stderr, /no such file/);
});
