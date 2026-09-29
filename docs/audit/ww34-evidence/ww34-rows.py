import json, os
L = os.path.expanduser("~/lanes/ww34")
def rows(n): return {r["file"]: r for r in json.load(open(f"{L}/census-{n}.json"))["rows"]}
a, b, c, d = rows("0217-0140"), rows("0217-0141"), rows("0218-0140"), rows("0218-0141")
def diff(x, y, label):
    ch = [(f, x[f]["verdict"], y[f]["verdict"]) for f in sorted(set(x) & set(y)) if x[f]["cls"] != y[f]["cls"] or x[f]["verdict"] != y[f]["verdict"]]
    print(f"== {label}: {len(ch)} rows differ")
    for f, v1, v2 in ch: print(f"   {f}: {v1} -> {v2}")
diff(a, b, "module move on 0.2.17 corpus (0.1.40 -> 0.1.41)")
diff(a, c, "corpus move under 0.1.40 (common rows)")
diff(b, d, "corpus move under 0.1.41 (common rows)")
diff(c, d, "module move on 0.2.18 corpus (0.1.40 -> 0.1.41)")
print("== arrivals at 0.2.18 under 0.1.41:")
for f in sorted(set(d) - set(b)): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}  (0.1.40: {c[f]['verdict']})")
print("== departures:", sorted(set(b) - set(d)))
for f in ["grammar/range_header_inclusive_max.lu", "grammar/range_value_wide_iter.lu", "memory/list_session_struct.lu"]:
    print("probe", f, d.get(f, {}).get("verdict"))
print("died rows:", [f for f in d if d[f]["cls"] == "died"])
