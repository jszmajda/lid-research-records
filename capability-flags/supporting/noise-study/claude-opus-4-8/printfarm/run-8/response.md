I've reviewed the project. Here is the coach report.

---

## `/lid-coach` — printfarm

### 1. Executive summary

**Posture:** *Clean and well-linked at the top of the arrow — but the design drifts from a stated tenet, and the arrow currently stops at specs.*

**Scorecard**
- ✓ **Configuration & mode fit** — directives + `- Mode: Full` present; Full matches a two-node, fully-LID repo
- ✓ **Mutation hygiene** — docs read as current intent; no changelogs, `[obsolete]` residue, or planning text
- ✓ **Intent-tree alignment (up)** — every spec's prefix (`QUEUE`, `REG`) resolves cleanly to its leaf LLD, which parents to the HLD
- ⚠ **Arrow completeness** — Tests and Code phases are absent from the tree, yet all 8 specs are marked `[x]` done
- ⚠ **Decision capture** — the most consequential job-queue choice (volatile in-memory queue) is unrecorded and contradicts a tenet
- ⚠ **Tenet quality** — real tie-breakers, but unordered and one is overridden by the design

**Headline:** The arrow's design layer is genuinely good — two clean intent components, honest Decisions tables, clean grep-anchored IDs, and a tidy HLD free of implementation detail. The single most valuable next step is to reconcile the in-memory queue design with the *"a submitted job is a promise"* tenet — and capture that decision — because right now the design quietly breaks the project's headline commitment.

### 2. Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** job-queue holds the queue "entirely in process memory" and drops accepted-but-undispatched jobs on restart — while its own Context notes *"unattended OS updates and the occasional power blip"* — which contradicts the HLD tenet *"a submitted job is a promise: members should be able to upload and walk away"* · *tenets capture forward-looking preference* (design should obey the declared lean)
- **F2 (high):** The decision **not** to persist the queue (accept job loss vs. persist it, as the registry does with SQLite) is absent from job-queue's Decisions & Alternatives — the choice a cold reader would most want to reverse is the one that isn't recorded · *docs carry current intent* (decision capture)
- **F3 (high):** No Tests or Code phase exists in the tree, yet every spec is `[x]` (done) — the arrow is walkable only `HLD → LLD → EARS`, and no `@spec` annotation can link a spec to a test or entry point · *canonical arrow shape* + *tests before code*
- **F4 (medium):** Several LLD behaviors have no EARS spec — job-queue's "accept only if the class has a registered printer," the priority + FIFO ordering rule, and content-hash dedup; printer-registry has a spec for retiring a printer but none for registering one · *effective intent-tree alignment* (LLD behavior with no spec is unnamed intent)
- **F5 (medium):** The three tenets are an unordered list, but two demonstrably conflict ("a submitted job is a promise" vs. "the service stays small") — and the design silently resolved it toward "small" · *tenets capture forward-looking preference* (order tenets that can conflict)
- **F6 (low):** The HLD has no success-metrics section and no explicit Key Design Decisions; goals like "fair access to popular printer classes" carry no measurable target · *HLD is architecture and rationale*

### 3. What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both LLD design docs, both `*-specs.md` files
- **Enumerated:** 2 LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 2 arrow segments
- **Absent from the tree:** `docs/arrows/` overlay (reviewed as overlay-not-installed); any code or test files
- **Could not read:** the core skill's `references/capability-flags.md` (outside this session's accessible directories) — per the skill, flags are therefore treated as applying
- **Note:** this working copy is not a git repository, so tests-first commit ordering could not be checked from history

### 4. Worth a second look

I couldn't read the capability-flags reference, so I'm treating the flags as applying. Models in my class are known to miss designs that contradict a project's own tenets — the exact shape of F1/F5 here. Please sanity-check the two leaf designs against your HLD tenets yourself; in particular, confirm whether the volatile-queue behavior is an accepted trade against *"a submitted job is a promise"* or an oversight.

### 5. Offer to help

Want me to walk through these findings in detail, focus on the tenet/design tension (F1–F2), or work through a specific fix together? You can also pick any single finding to dig into.

If you have broader questions about using LID for printfarm — where a PRD would fit above this HLD, when the queue design would warrant its own decision doc, or how to bring the Tests and Code phases of the arrow into the repo — I can talk through those too.