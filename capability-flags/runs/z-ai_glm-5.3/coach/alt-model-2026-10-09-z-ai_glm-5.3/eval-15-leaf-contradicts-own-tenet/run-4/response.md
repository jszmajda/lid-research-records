**LID Coach — Shelfwise review**

**Posture:** Bootstrapping — the arrow is authored through specs and implementation has not yet begun, with one intent-level tension worth settling before code lands.

**Scorecard**
- ✓ Tenet quality — four real tie-breakers, each with a defensible opposite
- ✓ Mutation hygiene — every doc reads as if authored fresh today; no history residue or conversational fossils
- ✓ Granularity — one LLD per intent component; the allocation/notice seam is clean and cross-referenced, not overlapping
- ✓ Intent-tree alignment — all 13 spec IDs resolve to their leaf LLDs, which trace to HLD components
- ⚠ Tenet cascade — the core allocation mechanism leans against one of your own tenets (F2)
- ⚠ Configuration — mode marker present, but the instruction file carries no linked-intent-dev directives (F1)

**Headline:** The doc discipline here is genuinely strong — a clean, rationale-first HLD, two well-scoped LLDs with unusually good Decisions & Alternatives rows, and 13 well-formed EARS specs. The single most valuable next step is recording the local-first allocation decision (and its tension with the sequence tenet) before any implementation session meets it cold.

---

**Findings (6 total · 3 high · 2 medium · 1 low)**

- **F1 (high):** CLAUDE.md has the `## LID` mode marker (`Mode: Full`, v1.4.0) but no linked-intent-dev directive block — no reference to the workflow skill, so a fresh session won't be pointed at the LID workflow when making changes · *modes are declared, not inferred*. Recommend `/update-lid` to reconcile (a light append; the mode marker is already correct).
- **F2 (high):** Local-first allocation (HOLDALLOC-003 before HOLDALLOC-004) serves a later-placed hold at the scanning branch ahead of an older hold at another branch — under that condition the mechanism works against the tenet *waiting is honored in sequence* (the design tree should lean the way the HLD says to lean). No Decisions row or exception records the tension, naming the tenet traded and why. Consider: either soften the tenet to name the local-first exception, or record the trade explicitly.
- **F3 (high):** The central policy choice — local-branch-first vs. county-wide FIFO allocation — exists only as a prose aside ("keeps most copies off the courier van, which runs once a day") with no row in the hold-allocation Decisions & Alternatives table and no key-design-decision entry in the HLD · *decision capture* (a cold reader of the landed design would immediately ask "why isn't this strict FIFO?" and find no recorded answer). This is the same choice as F2, flagged separately: the tenet tension is one finding, the missing record is another.
- **F4 (medium):** All 13 specs carry a `[x]` status marker while the repo contains no code or tests — the marker either means something other than "implemented" (undefined convention) or asserts completion that doesn't exist · *coherence is adjacency* / *intent leads; code is compiled output*. Settle the marker's meaning now, before implementation sessions inherit the ambiguity.
- **F5 (medium):** Cancellation edges are open in the hold-allocation LLD: in-transit cancellation is specified (HOLDALLOC-007), but a hold cancelled while its copy sits *on the holds shelf* has no specified path — the `allocated` state's exits are listed as "picked up or expired," omitting cancelled-on-shelf · *LLDs close enough of the solution space*. One sentence closes it.
- **F6 (low):** The HLD has no Non-Goals section (target users are also only implicit in the Problem) · *HLD is architecture and rationale*. A line or two — e.g., what Shelfwise deliberately is not (a catalog, a patron-facing app) — would help future sessions avoid re-litigating the boundary.

Not flagged, but worth knowing: the arrow currently ends at EARS — there are no tests or code to audit, so linkage hygiene (`@spec` annotations at entry points) and tests-first evidence are not yet applicable. They become live the moment implementation starts.

---

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files — the entire repository (6 files, single-commit history)
- Enumerated: 2 LLDs, 13 EARS specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`)
- Code/tests: none exist (0 source files); 0 `@spec` annotations to audit; linkage and tests-first dimensions deferred
- No `docs/arrows/` overlay present, so no index or arrow segments were read

---

Want me to walk through any of these findings in detail — F2/F3 (the allocation-policy record) is where I'd start — or work through specific items together? And if you have broader questions about using LID for this project — how tests-first should start here, what to do when a component grows past one LLD, mode transitions — I can help with those too.

*Run notes: this invocation was non-interactive; the skill's advisory posture was taken as the default (report rendered inline, no files edited — apply changes yourself or via `/update-lid` / `/arrow-maintenance`), and the declared `Mode: Full` was used as-is. No other user-decision points arose.*