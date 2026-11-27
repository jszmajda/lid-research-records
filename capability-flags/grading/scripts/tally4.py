"""Unblind and tally grade-roster4 (2026-10-18/19 roster). Same columns as tally3, with lid-coach eval 11 scored for
the under-captured table as A1 and A2 (the thin record gets a finding of its own)."""
import collections, glob, json, os

WS = "<workspace>/"
T = "<lid-evalstrip-1016 checkout>/plugins/linked-intent-dev/skills"
os.chdir(WS)
K = json.load(open("grade-roster4-key.json"))
G = {}
for f in glob.glob("grade-roster4/batch-*/grades.json"):
    G.update(json.load(open(f)))
missing = [r for r in K if r not in G]
print("graded", len(G), "of", len(K), "missing", missing[:10])
short = lambda m: m.split("/")[-1]


def cols(s, e, f):
    out = {}
    if s == "core":
        if e in (0, 3):
            out[f"core{e}"] = f[1] or f[2]
        if e == 1:
            out["core1"] = f[1]
        if e == 2:
            out["core2"] = f[2]
    if s == "coach":
        if e == 10:
            out["coach10"] = f[0]
        if e == 11:
            out["coach11"] = f[0] and f[1]
            out["coach11.A5"] = f[4]
        if e in (15, 16):
            out[f"coach{e}"] = f[0]
            out[f"coach{e}.restraint"] = f[1]
    return out


T_ = collections.defaultdict(lambda: [0, 0])
tot = collections.defaultdict(lambda: [0, 0])
ctrl = []
for r, k in K.items():
    if r not in G:
        continue
    s, e, m, g = k["suite"], k["eval"], k["model"], G[r]
    f = [bool(x["pass"]) for x in g["first"]]
    fu = [bool(x["pass"]) for x in g.get("follow_up", [])]
    if m.startswith("CONTROL"):
        ctrl.append((s, e, m.split(":")[0], cols(s, e, f)))
        continue
    tot[(short(m), s)][0] += sum(f) + sum(fu)
    tot[(short(m), s)][1] += len(f) + len(fu)
    for c, v in cols(s, e, f).items():
        T_[(short(m), c)][0] += v
        T_[(short(m), c)][1] += 1

print("\nCONTROLS (FAIL expects False on the key column, PASS expects True):")
bad = 0
for s, e, kind, c in sorted(ctrl, key=lambda x: x[:3]):
    keycol = {("core", 0): "core0", ("core", 3): "core3", ("core", 1): "core1", ("core", 2): "core2",
              ("coach", 10): "coach10", ("coach", 11): "coach11.A5", ("coach", 15): "coach15", ("coach", 16): "coach16"}[(s, e)]
    ok = c[keycol] == (kind == "CONTROL-PASS")
    bad += not ok
    print("  %-5s %-3d %-13s %-11s %s" % (s, e, kind, keycol, "ok" if ok else "MISMATCH " + str(c)))
print("  control mismatches:", bad)

C = ["core0", "core3", "coach10", "coach11", "coach11.A5", "coach15", "coach16", "core1", "core2",
     "coach15.restraint", "coach16.restraint"]
print()
for m in sorted({k[0] for k in T_}):
    print(m)
    print("   " + "  ".join("%s %d/%d" % (c, *T_[(m, c)]) for c in C if T_[(m, c)][1]))
    print("   totals", {s: "%d/%d" % tuple(tot[(m, s)]) for s in ("core", "coach", "update") if tot[(m, s)][1]})

# timeouts in the batches the grades rest on (the outage's partial cells excluded, as in setup)
EXCLUDE = {("2026-10-18", "google/gemini-3.8-flash", "lid-coach", 16), ("2026-10-18", "xiaomi/mimo-v2.6-flash", "linked-intent-dev", 3)}
to = collections.defaultdict(collections.Counter)
for f in glob.glob(f"{T}/*-workspace/alt-model-2026-10-1[89]-*/eval-*/with_skill/run-*/timing.json"):
    t = json.load(open(f))
    if t["status"] != "timeout":
        continue
    skill = f.split(T + "/")[1].split("-workspace")[0]
    bdir = f.split("/eval-")[0]
    date = os.path.basename(bdir)[10:20]
    e = int(f.split("/eval-")[1].split("-")[0])
    if (date, t["model"], skill, e) in EXCLUDE:
        continue
    to[short(t["model"])][f"{skill} {e}"] += 1
print("\nTIMEOUTS (not graded):", {m: dict(c) for m, c in to.items()})
