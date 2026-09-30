"""Classify the contents gate's status faults from its --json record (ww35).

The gate (wolf-book bd3484e tests/contents/contents.mjs) counts any landing
whose navigation response is not exactly 200 as a `status` fault. A browser
that revalidates a cached page gets 304 Not Modified and renders its cached
copy; Firefox (and sometimes WebKit) reports that 304 as the navigation's
status. This reads each status fault line, splits it by HTTP code, and for
the 304s applies the gate's own title and number judgement to the title and
h1 the line records — so a 304 that landed on the right page is told apart
from a real miss. Nothing is re-run; the record is the input.
"""
import json, re, sys
SUFFIX = " - The Wolf Book"
LINE = re.compile(r'^(?P<src>\S+) -> "(?P<label>.*)": HTTP (?P<code>\d+|null) (?P<url>\S+) title="(?P<title>.*)" h1="(?P<h1>.*)"$')
def parse(label):
    m = re.match(r"^(\d+)\.\s+(.*)$", label)
    return (m.group(1), m.group(2)) if m else (None, label)
for path in sys.argv[1:]:
    for r in json.load(open(path)):
        by, right, wrong = {}, 0, []
        for f in r["faults"]["status"]:
            m = LINE.match(f)
            code = m.group("code") if m else "unparsed"
            by[code] = by.get(code, 0) + 1
            if m and code == "304":
                num, name = parse(m.group("label"))
                h1num = parse(m.group("h1"))[0]
                if m.group("title") == name + SUFFIX and h1num == num:
                    right += 1
                else:
                    wrong.append(f)
        other = {k: len(v) for k, v in r["faults"].items() if k != "status" and v}
        print(f"{r['engine']:8} {r['viewport']:7} clicks {r['clicks']:4}  at200 {r['landed200']:4}  status-by-code {by}  "
              f"304-landed-right {right}  304-wrong {len(wrong)}  other {other}")
        for f in wrong[:5]: print("   WRONG", f)
        for k in ("click", "entries", "state", "load", "search", "title", "number"):
            for f in r["faults"][k][:3]: print(f"   {k}: {f}")
