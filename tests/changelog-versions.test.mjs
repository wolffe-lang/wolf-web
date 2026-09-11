/* The version audit's second root, and the class that made it possible.
 *
 * render-changelog.py turns CHANGELOG.md into /changelog/site/, so every
 * sentence in it is a page a reader can load — but both prose audits take
 * `site/` as their root and CHANGELOG.md is not under it (wolf-web#27). ww25
 * closed the COUNT half with `--also` alone and measured why the version half
 * could not follow: 34 distinct literals across 153 mentions, all of them
 * history, against an entry grammar that made `audited-at-<project>=` a
 * mandatory column. Admitting the file on those terms would have put every
 * one of them on the wolf or lupin clock and reddened all of them at every
 * release, for prose that cannot rot.
 *
 * So the grammar admits `frozen` in the clock's place — `counted=0` spelled
 * for literals — and only for a path given as an `--also` root.
 *
 * A gate nobody has watched fail is a claim. The planted defect here is the
 * one the frozen class must still catch: a frozen literal EDITED to a version
 * that never existed. The mutation is made in a temporary working directory
 * whose CHANGELOG.md is a copy — the audit keys on the path as written and
 * reads its allowlist beside itself, so `--also CHANGELOG.md` from that cwd
 * audits the mutant under the real allowlist without writing into the tree.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, writeFileSync, readFileSync, rmSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const script = join(root, "scripts", "check-version-prose.py");
/* Absolute, so the audit answers the same from any working directory; only
 * the --also key is meant to be read relative to cwd. */
const roots = [join(root, "site"), join(root, "upstream/wolf-lang"), join(root, "upstream/wolf-interp")];

/* The audit reads its pins out of the pinned checkouts, so the tests that run
 * it need them. The editor-suites job on the Windows runner checks this
 * repository out WITHOUT submodules, the way tests/revision-prose.test.mjs
 * and tests/changelog-counts.test.mjs already account for. The argument-error
 * and allowlist-grammar tests below need no checkout, by construction. */
const pinned = existsSync(join(root, "upstream", "wolf-lang", "CHANGELOG.md"));
function noPins() {
  console.log("  (skipped: upstream/ is not checked out)");
}

function audit(args, cwd = root) {
  const done = spawnSync("python3", [script, ...args, ...roots], { cwd, encoding: "utf-8" });
  return { status: done.status, stderr: done.stderr ?? "", stdout: done.stdout ?? "" };
}

/** build.sh's invocation, against a CHANGELOG.md whose text `edit` rewrote. */
function withEditedChangelog(edit) {
  const dir = mkdtempSync(join(tmpdir(), "ww27-versions-"));
  try {
    writeFileSync(
      join(dir, "CHANGELOG.md"),
      edit(readFileSync(join(root, "CHANGELOG.md"), "utf-8")),
      "utf-8",
    );
    return audit(["--also", "CHANGELOG.md"], dir);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("the invocation build.sh makes is green", () => {
  if (!pinned) return noPins();
  const out = audit(["--also", "CHANGELOG.md"]);
  assert.equal(out.status, 0, `expected a pass, got:\n${out.stderr}`);
  assert.match(out.stdout, /\d+ frozen in 1 dated root\(s\)/);
});

test("the copy the mutation tests are built on is itself green", () => {
  if (!pinned) return noPins();
  const out = withEditedChangelog((t) => t);
  assert.equal(out.status, 0, `expected a pass, got:\n${out.stderr}`);
});

test("a frozen literal edited to a version that never existed reds", () => {
  if (!pinned) return noPins();
  /* v0.2.44 is not a release and never will be one. The audit has to notice
   * twice: the literal that lost an occurrence, and the one nobody listed. */
  const out = withEditedChangelog((t) => t.replace("v0.2.4 ", "v0.2.44 "));
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stderr, /'v0\.2\.44' ×1 is not in version-allowlist\.txt/);
  assert.match(out.stderr, /'v0\.2\.4' appears ×5, the allowlist says ×6/);
});

test("a frozen literal that simply disappears reds too", () => {
  if (!pinned) return noPins();
  const out = withEditedChangelog((t) => t.replace(/\b1\.97\.1\b/g, "the pinned toolchain"));
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  assert.match(out.stderr, /lists '1\.97\.1' in CHANGELOG\.md, which no longer carries it/);
});

test("--also is what carries the CHANGELOG.md block", () => {
  if (!pinned) return noPins();
  const out = audit([]);
  assert.equal(out.status, 1, `expected a refusal, got:\n${out.stderr}${out.stdout}`);
  /* The frozen guard answers first, and it is the more useful message: the
   * entries are not merely stale, they name a root nobody passed. */
  assert.match(out.stdout + out.stderr, /CHANGELOG\.md is not an --also root/);
});

test("frozen is refused on a living site page", () => {
  /* The guard that keeps half two's re-read from being optional. Run with the
   * real allowlist but a DIFFERENT --also root, so every CHANGELOG.md entry
   * becomes an entry on a path nobody named. */
  const dir = mkdtempSync(join(tmpdir(), "ww27-frozen-"));
  try {
    writeFileSync(join(dir, "OTHER.md"), "nothing to see\n", "utf-8");
    const out = audit(["--also", join(dir, "OTHER.md")]);
    assert.equal(out.status, 1);
    assert.match(out.stdout + out.stderr, /cannot be `frozen`/);
    assert.match(out.stdout + out.stderr, /carries the clock that re-reads it/);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
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
