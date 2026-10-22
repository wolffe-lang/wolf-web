# ww46: a planted copy of the staged dist (stage-plant), for every staged checker to be seen red on (adapted from
# ww45-stage-plant.sh): an inline script on the front page and /play/, /play/'s §34.7 link removed, ch34's id="34.8"
# renamed, one ch07 SVG removed, ch01's archive name set back to 0.2.33, §34.7's fork.lu line changed, the menu's last
# entry removed, and hello.lu replaced by the os_fork probe.
S=/Users/mfwolffe/lanes/ww46; P=$S/stage-plant
rm -rf "${S:?}/stage-plant" && cp -R $S/stage $P || exit 1
python3 - "$P" "$S/ev/probes/os_fork.lu" <<'PY'
import json, sys, os
P, probe = sys.argv[1], sys.argv[2]
def edit(rel, old, new, count=1):
    p = os.path.join(P, rel); s = open(p, encoding="utf-8").read()
    assert s.count(old) >= 1, (rel, old[:40]); s = s.replace(old, new, count); open(p, "w", encoding="utf-8").write(s); print(f"planted {rel}: {old[:50]!r} -> {new[:50]!r}")
edit("index.html", "</body>", "<script>window.__planted = 1</script></body>")
edit("play/index.html", "</body>", "<script>window.__planted = 1</script></body>")
edit("play/index.html", 'href="/book/ch34.html#34.7"', 'href="/book/ch34.html"')
edit("book/ch34.html", 'id="34.8"', 'id="34.8-planted"')
edit("book/ch01.html", "wolf-0.2.34-x86_64-pc-windows-msvc", "wolf-0.2.33-x86_64-pc-windows-msvc", 99)
p = os.path.join(P, "book/ch34.html"); s = open(p, encoding="utf-8").read(); old = "os_fork()?"; i = s.index(old); s = s[:i] + "os_fork_planted()?" + s[i+len(old):]; open(p, "w", encoding="utf-8").write(s); print("planted book/ch34.html: fork.lu's first os_fork()? -> os_fork_planted()?")
idx = os.path.join(P, "play/samples/index.json"); d = json.load(open(idx)); gone = d["samples"].pop(); json.dump(d, open(idx, "w")); print(f"planted play/samples/index.json: last entry {gone.get('corpus_path')} removed")
first = d["samples"][0]; f = os.path.join(P, "play/samples", first["name"]); open(f, "w", encoding="utf-8").write(open(probe, encoding="utf-8").read()); print(f"planted play/samples/{first['name']} ({first['corpus_path']}): replaced by the os_fork probe")
PY
ls $P/book/diagrams/ch07/ | head -1 | while read f; do rm "$P/book/diagrams/ch07/$f" && echo "planted: removed book/diagrams/ch07/$f"; done
echo STAGE-PLANT-DONE
