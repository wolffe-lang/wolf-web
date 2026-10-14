# ww42: the four census legs compared (adapted from ww41-rows.py).
import json, os
L = os.path.expanduser("~/lanes/ww42")
def rows(n): return {r["file"]: r for r in json.load(open(f"{L}/census-{n}.json"))["rows"]}
a, b, c, d = rows("0228-0151"), rows("0228-0152"), rows("0229-0151"), rows("0229-0152")
def diff(x, y, label):
    ch = [(f, x[f]["verdict"], y[f]["verdict"]) for f in sorted(set(x) & set(y)) if x[f]["cls"] != y[f]["cls"] or x[f]["verdict"] != y[f]["verdict"]]
    print(f"== {label}: {len(ch)} rows differ")
    for f, v1, v2 in ch: print(f"   {f}: {v1} -> {v2}")
def summ(n, x):
    k = {}
    for r in x.values(): k[r["cls"]] = k.get(r["cls"], 0) + 1
    print(f"census-{n} {len(x)} programs: {dict(sorted(k.items()))}; candidates {k.get('exit',0)+k.get('trap',0)}")
for n, x in [("0228-0151", a), ("0228-0152", b), ("0229-0151", c), ("0229-0152", d)]: summ(n, x)
diff(a, b, "module move on 0.2.28 corpus (0.1.51 -> 0.1.52)")
diff(a, c, "corpus move under 0.1.51 (common rows)")
diff(b, d, "corpus move under 0.1.52 (common rows)")
diff(c, d, "module move on 0.2.29 corpus (0.1.51 -> 0.1.52)")
print("== arrivals at 0.2.29 under 0.1.52:")
for f in sorted(set(d) - set(b)): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}  (0.1.51: {c[f]['verdict']})")
print("== departures:", sorted(set(b) - set(d)))
print("== non exit/trap rows at 0.2.29 under 0.1.52:")
for f in sorted(d):
    if d[f]["cls"] not in ("exit", "trap"): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}")
for f in ["os/signal_shell_rows.lu", "os/job_rows.lu", "conc/atomic_counter.lu", "os/signal_supervisor.lu", "os/chdir_relative.lu", "os/env_unset.lu", "link/module_c.lu", "memory/raw_repr_c_layout.lu", "memory/raw_repr_packed_layout.lu", "memory/raw_repr_align_layout.lu", "membrane/extern_let_image.lu", "membrane/extern_libc.lu", "grammar/cfg_target_arch.lu"]:
    print("probe", f, "0.1.51:", c.get(f, {}).get("verdict"), "0.1.52:", d.get(f, {}).get("verdict"))
print("died rows:", [f for f in d if d[f]["cls"] == "died"])
