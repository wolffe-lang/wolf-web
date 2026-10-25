/* Progressive enhancement: the source nav is always an ordinary inline list.
 * No storage, framework, injected HTML, inline styles or foreign requests. */
(() => {
  const toc = document.getElementById("std-toc");
  const toggle = document.getElementById("std-toggle");
  const close = document.getElementById("std-close");
  if (!toc || !toggle || !close) return;
  const narrow = matchMedia("(max-width: 75rem)");
  let open = false;
  function state(next, focus = false) {
    open = narrow.matches && next;
    document.body.classList.toggle("std-open", open);
    toc.inert = narrow.matches && !open;
    toggle.setAttribute("aria-expanded", String(open));
    if (open && focus) close.focus();
  }
  toggle.addEventListener("click", () => state(!open, true));
  close.addEventListener("click", () => { state(false); toggle.focus(); });
  document.addEventListener("keydown", (event) => {
    if (!open) return;
    if (event.key === "Escape") { state(false); toggle.focus(); }
    if (event.key === "Tab") {
      const targets = [...toc.querySelectorAll("a, button")];
      const first = targets[0], last = targets[targets.length - 1];
      if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
      if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    }
  });
  toc.addEventListener("click", (event) => {
    const link = event.target.closest("a[href^='#']");
    if (!link) return;
    state(false);
    const target = document.getElementById(link.hash.slice(1));
    if (target) { target.setAttribute("tabindex", "-1"); target.focus({ preventScroll: true }); }
  });
  narrow.addEventListener("change", () => state(false));
  toggle.hidden = false;
  close.hidden = false;
  document.body.classList.add("std-enhanced");
  state(false);
  const links = [...toc.querySelectorAll("a[href^='#']")];
  const targets = links.map(link => document.getElementById(link.hash.slice(1)));
  function highlight() {
    let current = 0;
    for (let i = 0; i < targets.length; i++) {
      if (targets[i] && targets[i].getBoundingClientRect().top <= 100) current = i;
    }
    links.forEach((link, i) => {
      if (i === current) link.setAttribute("aria-current", "location");
      else link.removeAttribute("aria-current");
    });
  }
  let pending = false;
  window.addEventListener("scroll", () => {
    if (pending) return;
    pending = true;
    requestAnimationFrame(() => { pending = false; highlight(); });
  }, { passive: true });
  window.addEventListener("hashchange", highlight);
  highlight();
})();
