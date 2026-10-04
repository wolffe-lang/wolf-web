import json, os
L = os.path.expanduser("~/lanes/ww37")
def rows(n): return {r["file"]: r for r in json.load(open(f"{L}/census-{n}.json"))["rows"]}
a, b, c, d = rows("0221-0144"), rows("0221-0145"), rows("0222-0144"), rows("0222-0145")
def diff(x, y, label):
    ch = [(f, x[f]["verdict"], y[f]["verdict"]) for f in sorted(set(x) & set(y)) if x[f]["cls"] != y[f]["cls"] or x[f]["verdict"] != y[f]["verdict"]]
    print(f"== {label}: {len(ch)} rows differ")
    for f, v1, v2 in ch: print(f"   {f}: {v1} -> {v2}")
def summ(n, x):
    k = {}
    for r in x.values(): k[r["cls"]] = k.get(r["cls"], 0) + 1
    print(f"census-{n} {len(x)} programs: {dict(sorted(k.items()))}; candidates {k.get('exit',0)+k.get('trap',0)}")
for n, x in [("0221-0144", a), ("0221-0145", b), ("0222-0144", c), ("0222-0145", d)]: summ(n, x)
diff(a, b, "module move on 0.2.21 corpus (0.1.44 -> 0.1.45)")
diff(a, c, "corpus move under 0.1.44 (common rows)")
diff(b, d, "corpus move under 0.1.45 (common rows)")
diff(c, d, "module move on 0.2.22 corpus (0.1.44 -> 0.1.45)")
print("== arrivals at 0.2.22 under 0.1.45:")
for f in sorted(set(d) - set(b)): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}  (0.1.44: {c[f]['verdict']})")
print("== departures:", sorted(set(b) - set(d)))
print("== non exit/trap rows at 0.2.22 under 0.1.45:")
for f in sorted(d):
    if d[f]["cls"] not in ("exit", "trap"): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}")
for f in ["rows/eu_bind_empty_row_handled.lu", "typecheck/numlit_binding_value_later_use.lu"]:
    print("probe", f, "0.1.44:", c.get(f, {}).get("verdict"), "0.1.45:", d.get(f, {}).get("verdict"))
print("died rows:", [f for f in d if d[f]["cls"] == "died"])
