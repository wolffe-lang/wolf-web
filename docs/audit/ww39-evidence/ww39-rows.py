# ww39: the four census legs compared (adapted from ww38-rows.py).
import json, os
L = os.path.expanduser("~/lanes/ww39")
def rows(n): return {r["file"]: r for r in json.load(open(f"{L}/census-{n}.json"))["rows"]}
a, b, c, d = rows("0223-0146"), rows("0223-0148"), rows("0225-0146"), rows("0225-0148")
def diff(x, y, label):
    ch = [(f, x[f]["verdict"], y[f]["verdict"]) for f in sorted(set(x) & set(y)) if x[f]["cls"] != y[f]["cls"] or x[f]["verdict"] != y[f]["verdict"]]
    print(f"== {label}: {len(ch)} rows differ")
    for f, v1, v2 in ch: print(f"   {f}: {v1} -> {v2}")
def summ(n, x):
    k = {}
    for r in x.values(): k[r["cls"]] = k.get(r["cls"], 0) + 1
    print(f"census-{n} {len(x)} programs: {dict(sorted(k.items()))}; candidates {k.get('exit',0)+k.get('trap',0)}")
for n, x in [("0223-0146", a), ("0223-0148", b), ("0225-0146", c), ("0225-0148", d)]: summ(n, x)
diff(a, b, "module move on 0.2.23 corpus (0.1.46 -> 0.1.48)")
diff(a, c, "corpus move under 0.1.46 (common rows)")
diff(b, d, "corpus move under 0.1.48 (common rows)")
diff(c, d, "module move on 0.2.25 corpus (0.1.46 -> 0.1.48)")
print("== arrivals at 0.2.25 under 0.1.48:")
for f in sorted(set(d) - set(b)): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}  (0.1.46: {c[f]['verdict']})")
print("== departures:", sorted(set(b) - set(d)))
print("== non exit/trap rows at 0.2.25 under 0.1.48:")
for f in sorted(d):
    if d[f]["cls"] not in ("exit", "trap"): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}")
for f in ["comptime/layout_query_repr_c.lu", "memory/packed_fields_at_offset_of.lu", "memory/raw_repr_packed_layout.lu", "memory/raw_repr_align_layout.lu", "membrane/extern_let_image.lu"]:
    print("probe", f, "0.1.46:", c.get(f, {}).get("verdict"), "0.1.48:", d.get(f, {}).get("verdict"))
print("died rows:", [f for f in d if d[f]["cls"] == "died"])
