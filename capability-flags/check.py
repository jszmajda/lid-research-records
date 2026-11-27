"""Recompute the evidence cells and output medians in capability-flags.md from these records.

Usage: python3 check.py path/to/capability-flags.md

capability-flags.md is plugins/linked-intent-dev/skills/linked-intent-dev/references/capability-flags.md
in https://github.com/jszmajda/lid. Each run's grading.json names the cell it counts toward and
whether it passed; this script tallies them, compares every cell in the file's three evidence
tables, and recomputes the Output per run medians from timing.json (opencode) or usage.json
(Claude Code), counting both turns. Standard library only.
"""
import collections, glob, json, os, re, statistics, sys

HERE = os.path.dirname(os.path.abspath(__file__))
cf = open(sys.argv[1]).read().splitlines()

cells = collections.defaultdict(lambda: [0, 0])
reasoning, other = collections.defaultdict(list), collections.defaultdict(list)
for g in glob.glob(f"{HERE}/runs/*/*/*/eval-*/run-*/grading.json"):
    j = json.load(open(g)); c = j["evidence_cell"]; m = j["model"]
    cells[(m, c["cell"])][0] += c["passed"]; cells[(m, c["cell"])][1] += 1
    d = os.path.dirname(g)
    if os.path.exists(f"{d}/usage.json"):  # Claude Code: the session's top-level usage, both turns
        r = o = 0
        for turn in json.load(open(f"{d}/usage.json")).values():
            u = turn.get("usage") or {}
            t = (u.get("output_tokens_details") or {}).get("thinking_tokens", 0) or 0
            r += t; o += (u.get("output_tokens", 0) or 0) - t
        reasoning[m].append(r); other[m].append(o)
    elif os.path.exists(f"{d}/timing.json"):  # opencode: tokens as the harness reported them, both turns
        t = json.load(open(f"{d}/timing.json")); r = o = 0
        for turn in (t, t.get("follow_up") or {}):
            tok = turn.get("tokens") or {}
            r += tok.get("reasoning", 0) or 0; o += tok.get("output", 0) or 0
        reasoning[m].append(r); other[m].append(o)

bad = n = 0
for l in cf:
    m = re.match(r"\| `([^`]+)` \| [^|]+ \| medium \| ([^|]+) \| ([^|]+) \| (\d{4}-\d\d-\d\d) \|", l)
    if m:
        for part in m.group(2).split(";"):
            kind, e, a, b = re.match(r"\s*(eval|core|coach) (\d+) (\d+)/(\d+)", part).groups()
            key = (m.group(1), ("coach" if kind == "eval" else kind) + e); n += 1
            if tuple(cells[key]) != (int(a), int(b)):
                bad += 1; print("cell differs:", key, "file", f"{a}/{b}", "records", "%d/%d" % tuple(cells[key]))
    m = re.match(r"\| `([^`]+)` \| [^|]+ \| medium \| (\d+) \| ([\d,]+) \| ([\d,]+) \|", l)
    if m:
        model = m.group(1)
        if not reasoning[model]:
            print("output medians: no token records for", model); continue
        got = (len(reasoning[model]), round(statistics.median(reasoning[model])), round(statistics.median(other[model])))
        want = (int(m.group(2)), int(m.group(3).replace(",", "")), int(m.group(4).replace(",", "")))
        if any(abs(x - y) > 1 for x, y in zip(got, want)):
            print("output medians differ:", model, "file", want, "records", got)
print(f"{n} cells compared, {bad} differ")
