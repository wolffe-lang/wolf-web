# ww45: the four census legs compared (adapted from ww44-rows.py). Modules: lupin 0.1.54 live on lupp.us and the
# same release built on kasumi (the control); corpora 0.2.32 and 0.2.33.
import json, os
L = os.path.expanduser("~/lanes/ww45")
def rows(n): return {r["file"]: r for r in json.load(open(f"{L}/census-{n}.json"))["rows"]}
a, b, c, d = rows("0232-live"), rows("0232-control"), rows("0233-live"), rows("0233-control")
def diff(x, y, label):
    ch = [(f, x[f]["verdict"], y[f]["verdict"]) for f in sorted(set(x) & set(y)) if x[f]["cls"] != y[f]["cls"] or x[f]["verdict"] != y[f]["verdict"]]
    print(f"== {label}: {len(ch)} rows differ")
    for f, v1, v2 in ch: print(f"   {f}: {v1} -> {v2}")
def summ(n, x):
    k = {}
    for r in x.values(): k[r["cls"]] = k.get(r["cls"], 0) + 1
    print(f"census-{n} {len(x)} programs: {dict(sorted(k.items()))}; candidates {k.get('exit',0)+k.get('trap',0)}")
for n, x in [("0232-live", a), ("0232-control", b), ("0233-live", c), ("0233-control", d)]: summ(n, x)
diff(a, b, "module move on 0.2.32 corpus (live -> control)")
diff(a, c, "corpus move under the live module (common rows)")
diff(b, d, "corpus move under the control module (common rows)")
diff(c, d, "module move on 0.2.33 corpus (live -> control)")
print("== arrivals at 0.2.33 under the control module:")
for f in sorted(set(d) - set(b)): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}  (live: {c[f]['verdict']})")
print("== departures:", sorted(set(b) - set(d)))
print("== non exit/trap rows at 0.2.33 under the control module:")
for f in sorted(d):
    if d[f]["cls"] not in ("exit", "trap"): print(f"   {d[f]['cls']:12} {f}  {d[f]['verdict']}")
for f in ["os/signal_one_rows.lu", "os/group_rows.lu", "os/job_poll_rows.lu", "comptime/shift_value.lu", "os/signal_shell_rows.lu", "os/job_rows.lu", "conc/atomic_counter.lu", "os/signal_supervisor.lu", "os/chdir_relative.lu", "os/env_unset.lu", "link/module_c.lu", "memory/raw_repr_c_layout.lu", "memory/raw_repr_packed_layout.lu", "memory/raw_repr_align_layout.lu", "membrane/extern_let_image.lu", "membrane/extern_libc.lu", "grammar/cfg_target_arch.lu"]:
    print("probe", f, "0.2.32 live:", a.get(f, {}).get("verdict"), "| 0.2.33 live:", c.get(f, {}).get("verdict"), "| 0.2.33 control:", d.get(f, {}).get("verdict"))
print("died rows:", [f for f in d if d[f]["cls"] == "died"], [f for f in c if c[f]["cls"] == "died"])
