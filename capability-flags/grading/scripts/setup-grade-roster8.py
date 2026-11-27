"""Build grade-roster8: blind grading batches for the 2026-11-20 roster (google/gemini-4-hydrogen, google/gemini-4-carbon,
google/gemini-4-neon) on the stripped copy of 919c4b4 (tree 3a5bd791), rebuilt in lid-evalstrip-1120.

Same method as grade-roster7:
- only `completed` runs are graded (ALT-EVAL-REC-003);
- built in two parts so grading can start before the slowest model finishes; each part grades each core/coach eval
  in one batch of up to 20 runs with two known-fail and two known-pass controls drawn from rounds 1-2 (none reused
  across parts), or in two batches with one of each when it has more runs;
- update-lid over three batches.
Batches named in SKIP_BATCHES (superseded by a whole-eval rerun) are left out.
"""
import glob, json, os, random, shutil, sys
from collections import defaultdict

WS = "<workspace>/"
T = "<lid-evalstrip-1120 checkout>/plugins/linked-intent-dev/skills"
# usage: setup-grade-roster8.py OUT MODEL[,MODEL...] SUITE[,SUITE...] [EXCLUDE_KEY_JSON ...]
# e.g. grade-roster8a for Hydrogen and Neon core/coach while Carbon still runs; grade-roster8b for Carbon and update-lid.
OUT = sys.argv[1]
os.chdir(WS)
assert not os.path.exists(OUT), OUT + " exists"

sk = {"core": "linked-intent-dev", "coach": "lid-coach", "update": "update-lid"}
ws = {"core": "linked-intent-dev-workspace", "coach": "lid-coach-workspace", "update": "update-lid-workspace"}
evdefs = {s: {e["id"]: e for e in json.load(open(f"{T}/{k}/evals/evals.json"))["evals"]} for s, k in sk.items()}

MODELS = set(sys.argv[2].split(","))
SUITES = set(sys.argv[3].split(","))
SKIP_BATCHES = set()  # batch directory basenames superseded by reruns
USED_CONTROLS = set()  # controls already drawn into an earlier part of this round
USED_IDS = set()  # run IDs an earlier part already assigned, so the parts' keys can be merged
for kf in sys.argv[4:]:
    USED_CONTROLS |= {k["model"].split(":")[1] for k in json.load(open(kf)).values() if k["model"].startswith("CONTROL")}
    USED_IDS |= set(json.load(open(kf)))
runs, skipped = [], defaultdict(int)
for s in SUITES:
    for r in glob.glob(f"{T}/{ws[s]}/alt-model-2026-11-2*-google_gemini-4-*/eval-*/with_skill/run-*"):
        bdir = r.split("/eval-")[0]
        if os.path.basename(bdir) in SKIP_BATCHES:
            skipped["superseded-by-rerun"] += 1
            continue
        b = json.load(open(bdir + "/batch.json"))
        if b["model"] not in MODELS:
            continue
        assert b["plugins_tree"] == "3a5bd791ca773e215b506752985d4e08c519972f", bdir
        assert b["head_commit"].startswith("919c4b4"), bdir
        assert b["state"] == "complete", bdir + " is " + b["state"]
        e = int(r.split("/eval-")[1].split("-")[0])
        st = json.load(open(r + "/timing.json"))["status"]
        if st != "completed":
            skipped[st] += 1
            continue
        runs.append((s, e, b["model"], r))

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
    if key not in IDX or rid not in G or k["model"].startswith("CONTROL") or rid in RG or rid in USED_CONTROLS:
        continue
    if not os.path.exists(k["path"] + "/response.md"):
        continue
    vals = [bool(G[rid]["first"][i]["pass"]) for i in IDX[key]]
    if all(vals):
        cands[key]["pass"].append((rid, k["path"]))
    elif not any(vals):
        cands[key]["fail"].append((rid, k["path"]))

random.seed(OUT)
by = defaultdict(list)
for s, e, m, r in runs:
    by[(s, e)].append((m, r))

groups = []
for (s, e), lst in sorted(by.items()):
    if s == "update":
        continue
    fails = random.sample(cands[(s, e)]["fail"], 2)
    passes = random.sample(cands[(s, e)]["pass"], 2)
    random.shuffle(lst)
    if len(lst) > 20:  # two batches, one known-fail and one known-pass control each
        half = len(lst) // 2
        parts = [(lst[:half], fails[:1], passes[:1]), (lst[half:], fails[1:], passes[1:])]
    else:  # one batch with both pairs of controls
        parts = [(lst, fails, passes)]
    for part, fs, ps in parts:
        g = part + [("CONTROL-FAIL:" + f[0], f[1]) for f in fs] + [("CONTROL-PASS:" + p_[0], p_[1]) for p_ in ps]
        random.shuffle(g)
        groups.append([((s, e), g)])
upd = [(k, v) for k, v in sorted(by.items()) if k[0] == "update"]
for lo, hi in ((0, 4), (5, 9), (10, 13)):
    if any(lo <= k[1] <= hi for k, v in upd):
        groups.append([(k, v) for k, v in upd if lo <= k[1] <= hi])

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
            while rid in key or rid in USED_IDS:
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
