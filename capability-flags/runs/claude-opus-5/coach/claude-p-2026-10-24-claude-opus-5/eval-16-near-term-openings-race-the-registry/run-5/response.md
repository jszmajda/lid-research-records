## LID Coach — Visit Planner

### Executive summary

**Posture: Design layer is clean and well-reasoned; the arrow stops at the spec level, and the fairness tenet is in tension with the fast-cancellation path.**

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ⚠ Arrow completeness — `HLD → LLD → EARS` is real and linked; Tests and Code phases are absent while specs read as complete
- ⚠ Tenet cascade — the ≤36h open-search window works against *first asked, first served*
- ⚠ LLD sufficiency — "compatible" is the load-bearing predicate and is never closed
- ⚠ Configuration — the `## LID` block declares mode and version but carries no LID directives

**Headline.** The two-component split is clean, the tenets are genuine tie-breakers rather than platitudes, and the Decisions & Alternatives tables are doing real work — this is a well-shaped arrow. The fastest wins are reconciling the instruction file, deciding what the `[x]` markers mean while no tests or code exist, and recording the fairness trade the fast-cancellation path makes.

### Findings (12 total · 5 high · 5 medium · 2 low)

- **F1 (high):** `CLAUDE.md:5-7` has the `## LID` block (Mode: Full, Version 1.4.0) but no LID directive block, so a fresh session gets the mode without the methodology · *modes are declared, not inferred* — the mode only steers behavior if the directives that read it are present; run `/update-lid` to reconcile
- **F2 (high):** all 15 specs are marked `[x]` across both spec files, but the repo contains no tests and no code — the arrow has no Tests or Code phase · *coherence is adjacency* — a status marker with nothing downstream citing it tells the next session the behavior is settled when nothing verifies it
- **F3 (high):** `FILL-003`/`FILL-004` publish a ≤36h opening to open portal search for 20 minutes, letting any eligible account claim ahead of patients already queued · *tenets capture forward-looking preference* — this defeats "an earlier request is never passed by one made after it" under exactly the condition the LLD describes, and no Decisions row names the tenet traded against
- **F4 (high):** "compatible active entries" (`fulfillment-design.md:7,9`, `FILL-001`, `FILL-005`) is never defined — service, allowed sites, time window, and accessibility needs are all stored by Intake, but which of them constrain matching is left open · *LLDs close enough of the solution space* — two reasonable agents would ship different matchers, and accessibility is the edge most likely to get dropped
- **F5 (high):** the HLD declares "staff may act for patients who call" (`high-level-design.md:7`) and Intake's Context echoes it, but `INTAKE-001` only covers "an authenticated account submits" — the proxy path has no spec and no actor model · *effective intent-tree alignment* — declared behavior with no spec is unnamed intent
- **F6 (medium):** the 36-hour threshold, the 20-minute scan delay, and the two-hour offer window carry no Decisions & Alternatives row in either leaf · *docs carry current intent* — a cold reader would question all three and cannot reconstruct what was given up
- **F7 (medium):** `INTAKE-006` resets queue position when a patient changes service, while preference edits preserve `enteredAt` — a consequential fairness asymmetry with no row recording it · *docs carry current intent* (decision capture) — a cold reader would be tempted to reverse this
- **F8 (medium):** the HLD has Problem, Approach, Tenets, Goals, and Components, but no target users, non-goals, or success metrics · *HLD is architecture and rationale* — non-goals are what stop later sessions from widening scope by inference
- **F9 (medium):** spec files carry no `prefix:` frontmatter, and `FILL-*` doesn't match its `fulfillment` leaf path · *specs are grep-anchored linkage* — the leaf prefix is the cascade boundary, so it should be declared rather than inferred from the directory name
- **F10 (medium):** the two-hour offer duration is fixed in `fulfillment-design.md:7` but no spec states it; `FILL-002` only says the offer expires · *coherence is adjacency* — a parameter living one level above its spec drifts silently
- **F11 (low):** "registry scan", "the matcher", "the cancellation handler", and `notBefore` enter the fulfillment doc undefined, and the entry `status` value set is never enumerated despite `status` being a stored field · cold-read pass — these resolve from the authoring conversation, not from the page
- **F12 (low):** four tenets in an unordered list where at least two can collide in the fast-cancellation path · *tenets capture forward-looking preference* — order them once more than two can conflict

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 15 EARS specs (7 Intake, 8 Fulfillment), 8 Decisions & Alternatives rows
- Arrow-path sampled: both segments traced HLD section → LLD → spec; both terminate at the spec level
- Linkage metric: 0 `@spec` annotations — no code or test files exist in the repository
- Overlay: `docs/arrows/` absent, so no structural index was available; no `[inferred]` markers found
- Cold-read pass: all 5 LID docs
- Dispatch: `CLAUDE.md` carries no LID directives but the project is clearly LID-shaped, so this ran as a full review per the skill's dispatch table, with F1 surfacing the gap. Mode taken as declared (Full), so no out-of-scope section applies. Non-interactive run: report rendered inline only, not persisted to disk — the skill's default.

---

Want me to walk through any of these in detail, focus on a theme (the fairness tension in F3/F7 is the most interesting thread here), or work through specific items together? Pick a finding and I'll go deep on remedies and which command to point it at.

If you have broader questions about using LID on this project — when to promote Fulfillment to a sub-HLD, where a PRD would fit alongside the HLD, how to bring tests and code into the arrow from here, or whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.