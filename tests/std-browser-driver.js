/* Runs in a real browser under production CSP, never in the shipped site. */
(async () => {
  const result = document.getElementById("result");
  const frame = document.getElementById("page");
  const errors = [];
  function assert(value, message) { if (!value) throw new Error(message); }
  function loaded(action) {
    return new Promise(resolve => { frame.onload = resolve; action(); });
  }
  const doc = () => frame.contentDocument;
  function verify() {
    assert(doc().body.classList.contains("std-enhanced"), "external ToC script did not run");
    assert(!doc().querySelector("[style], style, script:not([src])"), "inline content");
    doc().addEventListener("securitypolicyviolation", e => errors.push(e.violatedDirective));
  }
  try {
    for (const width of [390, 1440]) {
      frame.width = String(width);
      await loaded(() => { frame.src = "/std/"; });
      verify();
      await loaded(() => doc().querySelector('a[href="/std/fs/"]').click()); // first hop
      verify();
      const toc = doc().getElementById("std-toc");
      const toggle = doc().getElementById("std-toggle");
      if (width === 390) {
        assert(toc.inert, "closed narrow contents is not inert");
        toggle.click();
        assert(!toc.inert && toggle.getAttribute("aria-expanded") === "true", "contents did not open");
        assert(doc().activeElement.id === "std-close", "open did not focus close button");
        doc().dispatchEvent(new frame.contentWindow.KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
        assert(toc.inert && doc().activeElement === toggle, "Escape did not close and restore focus");
        toggle.click();
      } else {
        assert(!toc.inert, "desktop contents is inert");
      }
      const link = toc.querySelector('a[href="#read_text"]');
      link.click();
      assert(frame.contentWindow.location.hash === "#read_text", "item anchor failed");
      // Wait for the browser's real scroll, then ask its event path to update.
      await new Promise(resolve => setTimeout(resolve, 100));
      frame.contentWindow.dispatchEvent(new Event("scroll"));
      await new Promise(resolve => setTimeout(resolve, 100));
      assert(toc.querySelector('[aria-current="location"]')?.hash === "#read_text", "scroll highlight did not track item");
      assert(doc().documentElement.scrollWidth <= width, "horizontal page overflow");
      await loaded(() => doc().querySelector('a[href="/std/"]').click()); // second hop
      verify();
      await loaded(() => doc().querySelector('a[href="/std/x/"]').click());
      await loaded(() => doc().querySelector('a[href="/std/x.json/"]').click());
      verify();
      assert(doc().querySelector('[data-std-item="float_at"]') || doc().querySelector('[data-std-item]'), "nested module lost its items");
      const response = await fetch("/std/fs.txt");
      assert(response.ok && response.headers.get("content-type").startsWith("text/plain"), "machine edition MIME/status");
      assert((await response.text()).includes("std.fs.read_text pub fn"), "machine edition lost read_text");
    }
    assert(errors.length === 0, "CSP violation: " + errors.join(", "));
    result.textContent = "PASS: std browser two hops, narrow/desktop, keyboard, anchors, scroll, text, CSP";
  } catch (error) {
    result.textContent = "FAIL: " + error.message;
  }
})();
