## LID Coach — Visit Planner

**Posture:** Clean, well-written design layer; the arrow stops at specs, and the configuration block is a precursor.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no changelogs, no `[obsolete]` residue, no `[inferred]` backlog
- ✓ Intent-tree alignment — two leaf designs, two spec files, every spec traces to its own leaf
- ⚠ Configuration — the `## LID` block carries Mode and Version but no LID directives
- ✗ Arrow completeness — no tests and no code exist, yet every spec is marked `[x]`
- ⚠ Tenet cascade — the short-notice path leans against *first asked, first served* with no recorded exception
- ⚠ Decision capture — the timing constants that drive fulfillment carry no rationale

**Headline:** The design layer is genuinely good — tight EARS, real tenets with defensible opposites, Decisions tables with accepted costs on both leaves, and not a trace of accumulation. The fastest wins are reconciling the instruction file, resolving the fairness tension in the 36-hour path, and getting the spec status markers to tell the truth about what is built.

**Findings (12 total · 4 high · 6 medium · 2 low)**
- **F1 (high):** `CLAUDE.md:5-7` declares Mode and Version but never names linked-intent-dev, so a fresh session loads the mode without the methodology · *modes are declared, not inferred* — the mode is read, but nothing tells the agent what to do with it; run `/update-lid` to reconcile
- **F2 (high):** `FILL-003`/`FILL-004` publish a short-notice opening to open portal search for 20 minutes, letting any eligible account claim ahead of the earliest `enteredAt` entry, with no Decisions row naming the trade · *tenet cascade / keep the arrow coherent* — the HLD's lead tenet promises an earlier request is never passed by a later one
- **F3 (high):** every spec in both files is marked `[x]` while the repo contains no tests and no code · *canonical arrow shape*, *tests before code* — the markers assert a downstream that does not exist, so the first implementation session inherits a false baseline
- **F4 (high):** staff acting for patients who call appears in `high-level-design.md:7` and `intake-design.md:4`, but every intake spec is written for a self-submitting authenticated account · *effective intent-tree alignment* — described behavior with no spec is unnamed intent
- **F5 (medium):** the 36-hour split, the 20-minute scan delay, and the two-hour offer window appear only as bare numbers in `fulfillment-design.md:7-9` · *decision capture* — a cold reader would want to reverse or retune these and has nothing to reconstruct from
- **F6 (medium):** "compatible" and "current eligibility" are never defined — whether accessibility needs are part of the match predicate is open, as is the tie-break on equal `enteredAt` · *LLDs close enough of the solution space*
- **F7 (medium):** offers are created (`FILL-001`, `FILL-005`) but no spec covers the offered patient accepting within the two-hour window · *effective intent-tree alignment* — the happy path of the far-out flow is unspecified
- **F8 (medium):** the goal of a traceable explanation for every confirmation, expiry, and withdrawal has event-append specs but no behavior that reads them back for staff · *effective intent-tree alignment*
- **F9 (medium):** `fulfillment-design.md:9` turns on a "registry scan" over a "registry" that no other doc names — intake calls them interest entries · *semantic legibility as cheap linkage*
- **F10 (medium):** neither leaf design carries a `prefix:` declaration, so `FILL-*` → `fulfillment` is inferable but not authoritative · *specs are grep-anchored linkage*
- **F11 (low):** four tenets, unordered, and at least two can collide in the short-notice path · *tenets capture forward-looking preference* — order them when more than two could conflict
- **F12 (low):** notification delivery past the outbox write (`FILL-007`) belongs to no design node · *one LLD per intent component*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 15 EARS specs (7 intake, 8 fulfillment), 8 Decisions & Alternatives rows
- Arrow-path sampled: both segments end-to-end — HLD component → leaf design → specs → (no tests) → (no code)
- Linkage metric: 0 `@spec` annotations found; no test or source files present in the repository
- No `docs/arrows/` overlay, so structural enumeration was not attempted
- Non-interactive run: proceeded with a full review per the declared `Mode: Full`, and did not persist this report to disk (the default)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F2 and F3 are the two I would start with.

If you have broader questions about using LID on this project — when to promote a leaf to a sub-HLD, how to handle a design-first project with no code yet, where staff-facing and patient-facing flows should split — I can help with those too.