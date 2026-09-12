/* The lag-phrase gate: the rule that lived on one runner now reds here.
 *
 * /install/ and /play/ are held to a CLOSED SET of four phrases for the
 * counted distance between the compiler this site advertises and the
 * specification the pinned interpreter was built to. The rule is correct and
 * has been since ww13 — and until now it lived only in PowerShell, inside
 * `.github/workflows/windows.yml`, in a job the linux `CI` workflow does not
 * depend on and no local gauntlet reproduced (wolf-web#38).
 *
 * THE WITNESS IS ww27's OWN PARAGRAPH. PR #37 added a sentence to /play/ that
 * quoted the phrase for a gap of zero while the gap was one. The local
 * gauntlet was green (eleven gates, exit 0, twice), the linux `CI` workflow
 * was green, and `windows learner path` was the only thing that refused it.
 * That paragraph is planted below and the check must red on it — a gate
 * nobody has watched fail is a claim.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { cpSync, existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const script = join(root, "scripts", "check-lag-phrases.py");
const lang = join(root, "upstream", "wolf-lang");
const interp = join(root, "upstream", "wolf-interp");

/* The check reads both gitlinks and the compiler's tag history, so every test
 * here needs the submodules. The editor-suites job on the Windows runner
 * checks this repository out WITHOUT them, the way the other suites account
 * for already. */
const pinned = existsSync(join(lang, "CHANGELOG.md")) && existsSync(join(interp, "Cargo.toml"));
function noPins() {
  console.log("  (skipped: upstream/ is not checked out)");
}

/** Run the check over a copy of site/ that `edit` rewrote. */
function withSite(edit) {
  const dir = mkdtempSync(join(tmpdir(), "ww28-lag-"));
  try {
    cpSync(join(root, "site"), dir, { recursive: true });
    for (const rel of ["install/index.html", "play/index.html"]) {
      const page = join(dir, rel);
      const next = edit(readFileSync(page, "utf-8"), rel);
      if (next !== null) writeFileSync(page, next, "utf-8");
    }
    const done = spawnSync("python3", [script, dir, lang, interp], { encoding: "utf-8" });
    return { status: done.status, stderr: done.stderr ?? "", stdout: done.stdout ?? "" };
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/* What the check itself measured at these pins. Every test below that needs
 * a phrase or a distance asks for it rather than spelling it: the answers
 * move at every interpreter bump — the gap was one at ww27 and is zero the
 * moment lupin's pin catches the compiler's — and a test that hardcoded
 * "one release" would be the same fossil the check exists to refuse. */
function measured() {
  const dir = mkdtempSync(join(tmpdir(), "ww28-lag-facts-"));
  try {
    cpSync(join(root, "site"), dir, { recursive: true });
    const done = spawnSync("python3", [script, dir, lang, interp, "--json"], {
      encoding: "utf-8",
    });
    return done.status === 0 ? JSON.parse(done.stdout) : null;
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

test("the site as it stands passes, and says what it measured", () => {
  if (!pinned) return noPins();
  const out = withSite((html) => html);
  assert.equal(out.status, 0, out.stderr);
  assert.match(out.stdout, /both pages carry/, "and it reports the reading");
});

test("ww27's own paragraph reds — the phrase for another gap, quoted", () => {
  if (!pinned) return noPins();
  /* Verbatim in shape: a sentence that is HISTORY about the previous pin,
   * reads correctly to a person, and is still refused. The rule is page-wide
   * by design — it cannot tell a quotation from a claim, and a lag paragraph
   * left unrewritten is indistinguishable from one by any test a machine can
   * apply. */
  const out = withSite((html, rel) =>
    rel === "play/index.html"
      ? html.replace(
          "</body>",
          "<p>it said <em>the same commit</em> at the pin where the tab ran\nsomething your compiler refused</p>\n</body>",
        )
      : null,
  );
  assert.equal(out.status, 1, "the check must refuse it");
  assert.match(out.stderr, /play[\\/]index\.html/, "and name the page");
  assert.match(out.stderr, /left unrewritten/, "and say what it thinks happened");
  assert.match(out.stderr, /cannot tell a quotation from a claim/, "and why it refuses one");
});

test("a page that drops the phrase for the counted gap reds", () => {
  if (!pinned) return noPins();
  const f = measured();
  if (!f) return noPins();
  /* The phrase is asked for, not spelled — see measured() above. */
  const out = withSite((html, rel) =>
    rel === "install/index.html" ? html.split(f.phrase).join("the lag") : null,
  );
  assert.equal(out.status, 1, "the check must notice the page stopped saying it");
  assert.match(out.stderr, /install[\\/]index\.html/);
  assert.match(out.stderr, /must carry the phrase/);
});

test("the revision written by hand reds, even when it is correct", () => {
  if (!pinned) return noPins();
  const link = spawnSync("git", ["-C", interp, "ls-tree", "HEAD", "upstream"], {
    encoding: "utf-8",
  });
  const sha = /^160000 commit ([0-9a-f]{40})/.exec(link.stdout ?? "");
  if (!sha) return noPins();
  const out = withSite((html, rel) =>
    rel === "play/index.html"
      ? html.replace("</body>", `<p>built to ${sha[1].slice(0, 7)}</p>\n</body>`)
      : null,
  );
  assert.equal(out.status, 1);
  assert.match(out.stderr, /by hand/);
  assert.match(out.stderr, /__PIN_specrev_short__/, "and says what to write instead");
});

test("the distance stamp is required exactly when there is a distance", () => {
  if (!pinned) return noPins();
  const f = measured();
  if (!f) return noPins();
  if (f.commits > 0) {
    /* There IS a distance: taking the stamp out must red. What goes in its
     * place is a number written by hand, which is check-counts.py's half of
     * the same sentence; only the missing stamp is this check's. */
    const out = withSite((html) => html.split("__COUNT_speccommits_word__").join("some"));
    assert.equal(out.status, 1);
    assert.match(out.stderr, /states no distance/);
  } else {
    /* There is NO distance — the two pins are one commit — so a page that
     * states one must red. This is the branch a gap-zero bump runs, and it is
     * why neither half is spelled as a constant here. */
    const out = withSite((html, rel) =>
      rel === "play/index.html"
        ? html.replace("</body>", "<p>__COUNT_speccommits_word__ commits</p>\n</body>")
        : null,
    );
    assert.equal(out.status, 1);
    assert.match(out.stderr, /there is no distance to state/);
  }
});

test("no arguments is a usage error, on any checkout", () => {
  const done = spawnSync("python3", [script], { encoding: "utf-8" });
  assert.equal(done.status, 2);
  assert.match(done.stderr, /usage/);
});
