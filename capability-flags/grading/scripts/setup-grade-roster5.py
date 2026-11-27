"""Build grade-roster5: blind grading batches for the 2026-10-24 Claude roster (claude-sonnet-5, claude-opus-5) via
claude -p on the stripped copy of 919c4b4.

Same method as grade-roster3, plus:
- runs whose claude -p turn reported an error are not graded;
- one grading batch per core/coach eval (~22 runs), with one known-fail and one known-pass control from rounds 1-2.
"""
import glob, json, os, random, shutil
from collections import defaultdict

WS = "<workspace>/"
T = "<lid-evalstrip-1016 checkout>/plugins/linked-intent-dev/skills"
OUT = "grade-roster5"
C = "<workspace>/roster/claude-1024"
os.chdir(WS)
assert not os.path.exists(OUT), OUT + " exists"

sk = {"core": "linked-intent-dev", "coach": "lid-coach", "update": "update-lid"}
ws = {"core": "linked-intent-dev-workspace", "coach": "lid-coach-workspace", "update": "update-lid-workspace"}
evdefs = {s: {e["id"]: e for e in json.load(open(f"{T}/{k}/evals/evals.json"))["evals"]} for s, k in sk.items()}
# (batch date, model, suite, eval) cells cut short by the outage; their reruns are dated 2026-10-19
EXCLUDE = {("2026-10-18", "google/gemini-3.8-flash", "coach", 16), ("2026-10-18", "xiaomi/mimo-v2.6-flash", "core", 3)}

runs, skipped = [], defaultdict(int)
for model_dir in sorted(glob.glob(f"{C}/claude-*")):
    m = os.path.basename(model_dir)
    for s_ in ("core", "coach", "update"):
        for r in glob.glob(f"{model_dir}/{s_}/eval-*/run-*"):
            e = int(r.split("/eval-")[1].split("/")[0])
            raws = [json.load(open(f)) for f in (r + "/raw.json", r + "/raw2.json") if os.path.exists(f)]
            if any(j.get("is_error") for j in raws) or not os.path.exists(r + "/response.md"):
                skipped["error"] += 1
                continue
            runs.append((s_, e, m, r))

# controls: known-fail and known-pass on each key assertion, from rounds 1-2 (never regraded runs)
K, G = {}, {}
for kf, gd in (("grade-roster-key.json", "grade-roster"), ("grade-roster2-key.json", "grade-roster2")):
    K.update(json.load(open(kf)))
    for f in glob.glob(f"{gd}/batch-*/grades.json"):
        G.update(json.load(open(f)))
RG = json.load(open("grade-roster2/regrade/regrade.json"))
IDX = {("core", 0): [1], ("core", 3): [1], ("core", 1): [1], ("core", 2): [2],
       ("coach", 10): [0], ("coach", 11): [0, 4], ("coach", 15): [0], ("coach", 16): [0]}
cands = defaultdict(lambda: {"fail": [], "pass": []})
for rid, k in K.items():
    key = (k["suite"], k["eval"])
    if key not in IDX or rid not in G or k["model"].startswith("CONTROL") or rid in RG:
        continue
    if not os.path.exists(k["path"] + "/response.md"):
        continue
    vals = [bool(G[rid]["first"][i]["pass"]) for i in IDX[key]]
    if all(vals):
        cands[key]["pass"].append((rid, k["path"]))
    elif not any(vals):
        cands[key]["fail"].append((rid, k["path"]))

random.seed(1024)
by = defaultdict(list)
for s, e, m, r in runs:
    by[(s, e)].append((m, r))

groups = []
for (s, e), lst in sorted(by.items()):
    if s == "update":
        continue
    g = lst + [("CONTROL-FAIL:" + x[0], x[1]) for x in random.sample(cands[(s, e)]["fail"], 1)] \
            + [("CONTROL-PASS:" + x[0], x[1]) for x in random.sample(cands[(s, e)]["pass"], 1)]
    random.shuffle(g)
    groups.append([((s, e), g)])
groups.append([(k, v) for k, v in sorted(by.items()) if k[0] == "update"])

key = {}
for gi, group in enumerate(groups):
    cdir = f"{OUT}/batch-{gi:02d}"
    os.makedirs(cdir)
    defs = {}
    for (s, e), lst in group:
        ed = evdefs[s][e]
        k_ = f"{s}-{e}"
        defs[k_] = {"first_prompt": ed["prompt"],
                    "first_turn_assertions": [a["text"] for a in ed["assertions"]],
                    "follow_up_prompt": (ed.get("follow_up") or {}).get("prompt"),
                    "follow_up_assertions": [a["text"] for a in (ed.get("follow_up") or {}).get("assertions", [])]}
        for f in ed.get("files", []):
            p = f"{cdir}/fixture-{k_}/{f['path']}"
            os.makedirs(os.path.dirname(p), exist_ok=True)
            open(p, "w").write(f["content"])
        for m, r in lst:
            rid = "Z%04d" % random.randint(0, 9999)
            while rid in key:
                rid = "Z%04d" % random.randint(0, 9999)
            d = f"{cdir}/{rid}"
            os.makedirs(d)
            for f in ("response.md", "response2.md", "changes1.patch", "changes.patch"):
                if os.path.exists(f"{r}/{f}"):
                    shutil.copy(f"{r}/{f}", f"{d}/{f}")
            if os.path.isdir(f"{r}/project"):
                shutil.copytree(f"{r}/project", f"{d}/project", symlinks=True)
            assert os.path.exists(f"{d}/response.md"), r
            open(f"{d}/EVAL", "w").write(k_)
            key[rid] = {"suite": s, "eval": e, "model": m, "path": r, "batch": gi}
    json.dump(defs, open(f"{cdir}/evals.json", "w"), indent=1)
json.dump(key, open(f"{OUT}-key.json", "w"), indent=1)

print(len(groups), "batches", len(key), "runs; skipped", dict(skipped))
for b in sorted(glob.glob(f"{OUT}/batch-*")):
    print(b, len([x for x in os.listdir(b) if x.startswith("Z")]), list(json.load(open(b + "/evals.json"))))
per = defaultdict(lambda: defaultdict(int))
for k in key.values():
    if not k["model"].startswith("CONTROL"):
        per[k["model"]][f"{k['suite']}-{k['eval']}"] += 1
for m, c in sorted(per.items()):
    print(m, dict(sorted(c.items())))
