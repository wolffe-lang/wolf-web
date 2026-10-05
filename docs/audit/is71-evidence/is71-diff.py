# is71: every census row whose answer moved between the trunk module and the head module.
import json, sys
a = json.load(open(sys.argv[1])); b = json.load(open(sys.argv[2]))
def rows(c):
    r = c["rows"]
    return {x["file"]: x for x in r} if isinstance(r, list) else r
ra, rb = rows(a), rows(b)
print("trunk", json.dumps(a["summary"], sort_keys=True))
print("head ", json.dumps(b["summary"], sort_keys=True))
moved = [f for f in sorted(set(ra) | set(rb)) if ra.get(f) != rb.get(f)]
print(f"moved {len(moved)}")
for f in moved:
    print(f, json.dumps(ra.get(f), sort_keys=True), "->", json.dumps(rb.get(f), sort_keys=True))
