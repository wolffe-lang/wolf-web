import json, os
L = os.path.expanduser("~/lanes/ww38")
def rows(n): return {r["file"]: r for r in json.load(open(f"{L}/census-{n}.json"))["rows"]}
a, b, c, d = rows("0222-0145"), rows("0222-0146"), rows("0223-0145"), rows("0223-0146")
def diff(x, y, label):
    ch = [(f, x[f]["verdict"], y[f]["verdict"]) for f in sorted(set(x) & set(y)) if x[f]["cls"] != y[f]["cls"] or x[f]["verdict"] != y[f]["verdict"]]
    print(f"== {label}: {len(ch)} rows differ")
    for f, v1, v2 in ch: print(f"   {f}: {v1} -> {v2}")
def summ(n, x):
    k = {}
    for r in x.values(): k[r["cls"]] = k.get(r["cls"], 0) + 1
    print(f"census-{n} {len(x)} programs: {dict(sorted(k.items()))}; candidates {k.get('exit',0)+k.get('trap',0)}")
for n, x in [("0222-0145", a), ("0222-0146", b), ("0223-0145", c), ("0223-0146", d)]: summ(n, x)
diff(a, b, "module move on 0.2.22 corpus (0.1.45 -> 0.1.46)")
diff(a, c, "corpus move under 0.1.45 (common rows)")
diff(b, d, "corpus move under 0.1.46 (common rows)")
diff(c, d, "module move on 0.2.23 corpus (0.1.45 -> 0.1.46)")
print("== arrivals at 0.2.23 under 0.1.46:")
for f in sorted(set(d) - set(b)): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}  (0.1.45: {c[f]['verdict']})")
print("== departures:", sorted(set(b) - set(d)))
print("== non exit/trap rows at 0.2.23 under 0.1.46:")
for f in sorted(d):
    if d[f]["cls"] not in ("exit", "trap"): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}")
for f in ["rows/unit_discard_if_value.lu", "grammar/cfg_target_arch.lu", "grammar/cfg_target_freestanding.lu", "membrane/extern_libc.lu"]:
    print("probe", f, "0.1.45:", c.get(f, {}).get("verdict"), "0.1.46:", d.get(f, {}).get("verdict"))
print("died rows:", [f for f in d if d[f]["cls"] == "died"])
