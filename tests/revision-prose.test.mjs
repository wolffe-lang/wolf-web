/* The revision gate: a sha in the site's prose is measured or it is refused.
 *
 * /install/ and /play/ name the specification revision the pinned interpreter
 * was built to. Through ww21 that sha was typed in by hand at every bump, held
 * by nothing — it is not a version and not a count, so neither site audit can
 * see it. scripts/stamp-revisions.py stamps it from the interpreter's gitlink
 * and refuses a revision written into a page.
 *
 * A gate nobody has watched fail is a claim, so this plants one and proves it
 * reds: a stale sha, the CORRECT sha (the kind that rots quietly, because it
 * looks right until the pin moves), and a placeholder naming a source that
 * does not exist. The stamping half is checked against the same gitlink the
 * build reads, so this test cannot agree with a wrong answer.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const script = join(root, "scripts", "stamp-revisions.py");
const lang = join(root, "upstream", "wolf-lang");
const interp = join(root, "upstream", "wolf-interp");

/** Run the stamper over a one-page dist/ holding `html`, and report. */
function sweep(html) {
  const dist = mkdtempSync(join(tmpdir(), "ww22-revisions-"));
  try {
    mkdirSync(join(dist, "play"), { recursive: true });
    const page = join(dist, "play", "index.html");
    writeFileSync(page, html, "utf-8");
    const done = spawnSync("python3", [script, dist, lang, interp], {
      encoding: "utf-8",
    });
    return {
      status: done.status,
      stderr: done.stderr ?? "",
      stdout: done.stdout ?? "",
      page: readFileSync(page, "utf-8"),
    };
  } finally {
    rmSync(dist, { recursive: true, force: true });
  }
}

/** The specification revision the pinned interpreter records, or null when
 * the submodules are not checked out. */
function gitlink() {
  const done = spawnSync("git", ["-C", interp, "ls-tree", "HEAD", "upstream"], {
    encoding: "utf-8",
  });
  const match = /^160000 commit ([0-9a-f]{40})/.exec(done.stdout ?? "");
  return match ? match[1] : null;
}

test("a stale revision planted in a page reds the build", () => {
  const out = sweep("<p>built to <code>e9a17cb</code>, a development revision</p>\n");
  assert.equal(out.status, 1, "the sweep must refuse it");
  assert.match(out.stderr, /e9a17cb/, "the message names the revision");
  /* the path is the platform's: play\index.html on the Windows runner. */
  assert.match(out.stderr, /play[\\/]index\.html/, "and the page that carries it");
  assert.match(out.stderr, /__PIN_specrev_short__/, "and what to write instead");
});

test("the correct revision, written by hand, reds too", () => {
  const sha = gitlink();
  if (!sha) {
    console.log("  (no gitlink: upstream/wolf-interp is not checked out)");
    return;
  }
  const out = sweep(`<p>built to <code>${sha.slice(0, 7)}</code></p>\n`);
  assert.equal(out.status, 1, "a literal is refused whatever it says");
  assert.match(out.stderr, /written\s+by hand/);
});

test("a placeholder naming no source reds rather than stamping nothing", () => {
  const out = sweep("<p>built to <code>__PIN_bogus_short__</code></p>\n");
  assert.equal(out.status, 1);
  assert.match(out.stderr, /names no source/);
  assert.match(out.page, /__PIN_bogus_short__/, "and the page is left alone");
});

test("the stamp is the interpreter's own gitlink", () => {
  const sha = gitlink();
  if (!sha) {
    console.log("  (no gitlink: upstream/wolf-interp is not checked out)");
    return;
  }
  const out = sweep(
    "<p>built to <code>__PIN_specrev_short__</code>, and in full " +
      "<code>__PIN_specrev_full__</code></p>\n",
  );
  assert.equal(out.status, 0, out.stderr);
  assert.match(out.page, new RegExp(`<code>${sha.slice(0, 7)}</code>`));
  assert.match(out.page, new RegExp(`<code>${sha}</code>`));
  assert.ok(!out.page.includes("__PIN_"), "no placeholder survives");
});

test("english prose is not a revision", () => {
  /* Seven hex letters with no digit is a word, and seven digits with no
   * letter is a number. Neither is a sha, and a gate that says otherwise
   * would be turned off within a week. */
  const out = sweep("<p>effaced, deadfaced, 1234567 and 0.1.30 all stand.</p>\n");
  assert.equal(out.status, 0, out.stderr);
});

test("both pages carry the stamp and neither carries a literal", () => {
  for (const page of ["install", "play"]) {
    const html = readFileSync(join(root, "site", page, "index.html"), "utf-8");
    assert.match(
      html,
      /__PIN_specrev_short__/,
      `site/${page}/ states the revision as a stamp`,
    );
    assert.ok(
      !/(?<![0-9A-Za-z])(?=[0-9a-f]*[0-9])(?=[0-9a-f]*[a-f])[0-9a-f]{7,40}(?![0-9A-Za-z])/.test(
        html,
      ),
      `site/${page}/ writes no revision by hand`,
    );
  }
});
