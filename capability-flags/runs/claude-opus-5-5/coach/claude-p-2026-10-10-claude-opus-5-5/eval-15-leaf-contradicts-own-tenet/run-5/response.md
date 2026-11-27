# LID Coach — Shelfwise

## Executive summary

**Posture:** Clear, well-reasoned design layer; one tenet conflict in allocation, and the arrow stops at the specs.

**Scorecard**
- ✓ Design-doc quality — the HLD is architecture and rationale only, with one LLD per component and no history residue.
- ✓ Decision capture — seven of the eight choices a reader would question have a row naming what was rejected and the cost accepted.
- ✓ Spec hygiene — 13 EARS specs with unique, stable IDs that trace to their LLDs.
- ⚠ Tenet cascade — hold allocation leans against the first tenet with no recorded exception.
- ⚠ LLD sufficiency — hold cancellation and a few delivery and expiry edges are left open.
- ✗ Arrow completeness — every spec is marked `[x]`, but the repository has no tests or code.
- ⚠ Configuration — `CLAUDE.md` has the `## LID` block but not the LID directives.

**Headline:** The design layer is in good shape, and the pickup-notices Decisions table is a model: its "Expiry handling" row names the goal it trades against and why. The most valuable next step is to settle branch-first allocation against the "waiting is honored in sequence" tenet.

## Findings (9 total · 4 high · 3 medium · 2 low)

- **F1 (high):** Branch-first allocation lets a later local hold receive a copy ahead of an older hold at another branch, which the tenet "nobody's wait is lengthened by a patron who asked after them" rules out (`hold-allocation-design.md` Design ¶2; HOLDALLOC-003/004) · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The branch-first choice has no Decisions row. Its only rationale is a prose aside about the courier van, with no rejected alternative and no mention of the tenet being traded · *decision capture* — a choice a cold reader would question carries what was given up and why.
- **F3 (high):** All 13 specs are checked `[x]`, yet there are no tests, code, or `@spec` annotations here. Consider either noting where the implementation lives or resetting the markers · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, with each phase present or its absence explicit.
- **F4 (high):** `CLAUDE.md` carries Mode and Version but no LID directives, so a session without the plugin gets no workflow guidance. `/update-lid` reconciles this · *modes are declared, not inferred* — the instruction file is the foundation everything else keys off.
- **F5 (medium):** Hold cancellation is referenced (HOLDALLOC-007) but never specified. Nothing says how a hold is cancelled, what happens if its copy is already on the holds shelf, or that its record is deleted as the "hold history is not kept" tenet requires · *effective intent-tree alignment* — LLD behaviours without specs drift silently.
- **F6 (medium):** Pickup notices leaves edges open. A failed dialer call is undefined (only email and SMS failures are named). It is unclear whether a patron can still check out between lapse and the morning pull, since the LLD closes the hold at lapse and PICKUP-005 closes it at scan-off. A patron whose hold expires gets no message · *LLDs close enough of the solution space* — two agents reading the LLD should land on compatible implementations.
- **F7 (medium):** Some terms only resolve with context that is not on the page: Goal 1's "business hours", when the "morning pull list" is produced, and the contract with the unnamed "circulation system" · *docs carry current intent, written to be read cold* — future sessions have only the page.
- **F8 (low):** The four tenets are an unordered list, though they can pull against each other ("hear once" vs. staff exceptions; sequence vs. automation). Consider ordering them · *tenets capture forward-looking preference* — tie-breakers need a precedence when they collide.
- **F9 (low):** The HLD has no non-goals or target-users section, such as whether renewals, fines, or catalog search are deliberately out · *HLD is architecture and rationale* — non-goals stop later sessions from guessing at scope.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, and both spec files (6 files — the whole repository).
- Enumerated: 2 LLDs, 13 specs (HOLDALLOC-001–007, PICKUP-001–006), 7 Decisions rows, 4 tenets, 2 goals.
- Code and tests: none present; 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not installed, so no structural audit was run.
- Dispatch: `CLAUDE.md` lacks the LID directives but the project is clearly LID-shaped, so this was a full review in Full mode as declared. Nothing was edited.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.