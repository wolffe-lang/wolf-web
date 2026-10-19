# ww45: the census PREDICTED BY MACHINE, before any measurement and before the first gitlink moves (kasumi).
# Inputs: ww44's measured census of the 0.2.32 corpus through lupin 0.1.54 (docs/audit/ww44-evidence/census-0232-0154.json,
# 682 rows; the module served live since ww44's deploy is that release), the two run sets ww45-derive.sh wrote, and the
# 0.2.33 corpus. The interpreter does not move, so the rule is mechanical:
#   - a program both corpora carry byte-identically keeps its measured class;
#   - a modified program keeps its class unless its diff ADDS a name lupin 0.1.54 does not resolve;
#   - an arrival that names a builtin lupin 0.1.54 does not resolve (0.2.33's five) is unsupported, verdict
#     "<first such name in source order> does not resolve"; an arrival naming a process-tier builtin the wasm build
#     declines is unsupported with that tier; anything else is predicted exit (least firm).
import json, os, re, subprocess
L = os.path.expanduser("~/lanes/ww45"); C = f"{L}/web/upstream/wolf-lang"
OLD, NEW = "72de141f624662fdff522e8beba459fab7c5cf66", "85dab5d7e597680d6fd7034f1d7ed2acb9a92f97"
INTERP = f"{L}/web/upstream/wolf-interp"; IPIN = "0e536e8fb4518eaa798ac426901ab81275db5c9f"
FIVE = ["os_signal_ignore_one", "os_signal_default_one", "os_exit_signal", "os_wait_status_core", "os_wait_poll_core"]
git = lambda *a, cwd=C: subprocess.run(["git", *a], cwd=cwd, capture_output=True, text=True, check=True).stdout
base = {r["file"]: r for r in json.load(open(f"{L}/web/docs/audit/ww44-evidence/census-0232-0154.json"))["rows"]}
old = [l.strip()[len("corpus/"):] for l in open(f"{L}/run-72de141.txt")]
new = [l.strip()[len("corpus/"):] for l in open(f"{L}/run-85dab5d.txt")]
assert set(base) == set(old), "ww44's census is not the 0.2.32 run set"
src = git("show", f"{IPIN}:src/eval/builtin.rs", cwd=INTERP)
known = set(re.findall(r'"(os_[a-z_]+|fs_[a-z_]+|net_[a-z_]+)"', src))
unknown = [n for n in FIVE if n not in known]
print(f"lupin 0.1.54 (builtin.rs at {IPIN[:7]}) names {len(known)} os/fs/net builtins; of 0.2.33's five it knows {sorted(set(FIVE) & known)}, so {unknown} do not resolve")
modified = set(git("diff", "--name-only", "--diff-filter=M", OLD, NEW, "--", "corpus").split())
pred, why = {}, {}
for f in new:
    p = f"corpus/{f}"
    if f in base and p not in modified:
        pred[f] = (base[f]["cls"], base[f]["verdict"]); why[f] = "unchanged: ww44's measured class"; continue
    text = git("show", f"{NEW}:{p}")
    body = "\n".join(l for l in text.splitlines() if not l.lstrip().startswith("//"))
    hits = sorted(((m.start(), n) for n in unknown for m in re.finditer(rf"\b{n}\s*\(", body)))
    if f in base:
        added = git("diff", OLD, NEW, "--", p)
        add = [l for l in added.splitlines() if l.startswith("+") and not l.startswith("+++")]
        if any(re.search(rf"\b{n}\s*\(", l) for l in add for n in unknown):
            pred[f] = ("unsupported", f"`{hits[0][1]}` does not resolve"); why[f] = "modified, adds an unresolved name"
        else:
            pred[f] = (base[f]["cls"], base[f]["verdict"]); why[f] = "modified, adds no name 0.1.54 lacks: ww44's measured class"
        continue
    if hits:
        pred[f] = ("unsupported", f"`{hits[0][1]}` does not resolve"); why[f] = "arrival naming a 0.2.33 builtin 0.1.54 lacks"
    else:
        pred[f] = ("exit", "exit(0)"); why[f] = "arrival naming nothing 0.1.54 lacks (least firm)"
k = {}
for c, _ in pred.values(): k[c] = k.get(c, 0) + 1
print(f"predicted census, 0.2.33 corpus through lupin 0.1.54: {len(pred)} programs {dict(sorted(k.items()))}, candidates {k.get('exit',0)+k.get('trap',0)}, fail 0, died 0")
for f in sorted(set(new) - set(old)): print(f"  arrival   {f}: {pred[f][0]} ({pred[f][1]}) — {why[f]}")
for f in sorted(set(old) - set(new)): print(f"  departure {f}")
for f in sorted(x[len('corpus/'):] for x in modified if x[len('corpus/'):] in pred and x[len('corpus/'):] in base): print(f"  modified  {f}: {pred[f][0]} ({pred[f][1]}) — {why[f]}")
print("predicted module leg (live 0.1.54 -> kasumi-built 0.1.54) on either corpus: 0 rows move")
json.dump({"rows": [{"file": f, "cls": c, "verdict": v} for f, (c, v) in sorted(pred.items())]}, open(f"{L}/census-0233-predicted.json", "w"), indent=1)
print("PREDICT-DONE")
