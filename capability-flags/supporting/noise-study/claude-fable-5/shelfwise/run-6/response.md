# LID Coach — Shelfwise

**Posture: Strong intent layer; the arrow stops at specs.**

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent; no changelog residue, no obsolete markers, no conversational fossils
- ✓ LLD granularity — one LLD per intent component, matching the HLD's component list exactly
- ✓ Spec hygiene — clean EARS phrasing, unique zero-padded IDs, two well-separated namespaces
- ⚠ Tenet/design coherence — the allocation design leans against one of the HLD's own tenets
- ⚠ Configuration — `## LID` mode block present, but the LID directive block is missing from `CLAUDE.md`
- ✗ Arrow completeness — no Tests or Code phase anywhere, yet every spec is checked `[x]`

The intent layer here is genuinely good — the HLD, both LLDs, and all 13 specs read cold, the Decisions & Alternatives tables mostly name what was given up and at what cost, and the tenets are real tie-breakers rather than platitudes. The fastest wins are reconciling the instruction file with `/update-lid` and resolving what the `[x]` status markers mean when the repository holds no tests or code.

**Findings (6 total · 3 high · 2 medium · 1 low)**
- **F1 (high):** `CLAUDE.md` has the `## LID` mode block but no LID directive block — run `/update-lid` to reconcile · *modes are declared, not inferred* — configuration lives explicitly in the instruction file, or every session runs on defaults
- **F2 (high):** Branch-first allocation (HOLDALLOC-003/004) lets a later local hold jump an older hold at another branch, against the tenet "Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them" — consider qualifying the tenet or revisiting the rule · *coherence is adjacency* — each arrow level agrees with the one above it
- **F3 (high):** All 13 specs are checked `[x]`, but the repo contains no tests, no code, and zero `@spec` annotations — if implementation lives elsewhere, document that deviation; if not, the markers are premature · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, with deviations explicit
- **F4 (medium):** The branch-first-vs-county-wide-FIFO choice — the biggest call in hold allocation, and the one behind F2 — has no Decisions & Alternatives row; its rationale ("keeps most copies off the courier van") sits only in body prose. Consider a row naming the rejected strict-FIFO alternative and the accepted cost · *docs carry current intent* — a cold reader should be able to reconstruct a choice they'd still question
- **F5 (medium):** Hold cancellation is consumed by HOLDALLOC-007 (cancelled-while-in-transit) but never specified — no spec covers how a hold is cancelled, or what happens when one is cancelled while its copy sits allocated on a shelf · *effective intent-tree alignment* — behavior the design relies on should trace to a spec
- **F6 (low):** The "Hold history is not kept" tenet is half triggered-rule — "a closed hold's record is deleted" already lives as PICKUP-003; consider tightening the tenet to its lean ("Shelfwise knows who is waiting, never who has read what") · *tenets capture forward-looking preference* — a lean, not a *when X, do Y*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 specs (7 HOLDALLOC, 6 PICKUP), all status-marked `[x]`
- Searched project-wide: 0 `@spec` annotations, no test or code files, no `docs/arrows/` overlay
- Mode: Full (declared in the `## LID` block); review covered the whole project

**Worth a second look:** I could not load the capability-flags reference in this run (it sits outside my permitted directories), so per the coach's own rule I'm treating its flags as applying. One known flag area — missing designs that contradict a project's own tenets — falls squarely inside this review, so please check the leaf designs against your HLD tenets yourself, F2 included.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for Shelfwise — where the implementation repo fits if code lives elsewhere, multi-repo setups, mode transitions, when to add the arrow-maintenance overlay — I can help with those too.