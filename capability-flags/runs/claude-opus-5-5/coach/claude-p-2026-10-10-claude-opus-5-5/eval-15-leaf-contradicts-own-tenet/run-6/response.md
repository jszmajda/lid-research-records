# LID Coach — Shelfwise

## Executive summary

**Posture:** Well-shaped design tree, with one design-versus-tenet conflict and no tests or code behind the specs yet.

**Scorecard**
- ✓ Design-tree shape — one HLD, two leaf LLDs that match the HLD's Components list, one spec file each
- ✓ HLD discipline — problem, approach, tenets and goals only; no schemas or API shapes
- ✓ Decision capture in pickup notices — every row names the alternative and the accepted cost, and two name the tenet or goal they trade against
- ⚠ Tenet cascade — hold allocation's branch-first rule works against "Waiting is honored in sequence"
- ⚠ Configuration — `CLAUDE.md` has the mode marker but not the LID directive block
- ✗ Arrow completeness — all 13 specs are marked `[x]`, but the repository has no tests or code

**Headline:** The docs read cleanly cold, and the pickup-notices Decisions table is a model of recording a trade-off (the expiry row names its cost against Goal 1 outright). The most valuable next step is to settle whether branch-first allocation is an intended exception to your first tenet, and record the answer either way.

## Findings (8 total · 3 high · 3 medium · 2 low)

- **F1 (high):** Branch-first allocation lets a later request overtake an earlier one. The design (`hold-allocation-design.md:11`) and HOLDALLOC-003 give a returned copy to the oldest hold at the scanning branch, even when a patron at another branch asked earlier. That works against the tenet "nobody's wait is lengthened by a patron who asked after them", and no row records the exception. The same rule is reused for cancel-in-transit (HOLDALLOC-007) and expiry (PICKUP-005). · *tenet cascade — leaf designs should lean the way the HLD's tenets say*
- **F2 (high):** The branch-first choice has no Decisions row. Its only rationale is one prose sentence about the once-a-day courier van, with no rejected alternative (strict county-wide order) and no accepted cost. A cold reader holding the tenet would question it, and likely "fix" it. · *decision capture — a choice a reader would still question needs its trade-off on the page*
- **F3 (high):** All 13 specs are checked `[x]`, but there are no tests, no code and no `@spec` annotations in the repository. Either the markers are ahead of reality or the implementation lives somewhere the docs don't name; either way the arrow stops at the specs. · *canonical arrow shape — HLD → LLDs → specs → tests → code, each phase present*
- **F4 (medium):** `CLAUDE.md` carries `## LID` with Mode and Version but no linked-intent-dev directives, so a fresh session gets the mode and not the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred — the instruction file is the foundation everything else keys off*
- **F5 (medium):** Hold cancellation is only half-specified. The only case covered is a cancel while the copy is in transit; cancelling a waiting hold, or one whose copy is already on the holds shelf, has no design text or spec. Nothing says a cancelled hold's record is deleted, which the "Hold history is not kept" tenet requires. · *LLDs close enough of the solution space — two agents should land on compatible implementations*
- **F6 (medium):** The phone-dialer channel has no failure definition. "Failed delivery" names bounced email and undeliverable SMS only, so an unanswered or voicemail call is left to the implementer (PICKUP-006). · *LLDs close enough of the solution space*
- **F7 (low):** The pickup-notices design and specs differ on when a lapsed hold closes. The design prose (`pickup-notices-design.md:11`) reads as closing at lapse; PICKUP-005 closes it when staff scan the copy off the shelf. A patron who arrives between lapse and the morning pull is not covered. · *coherence is adjacency — each level agrees with the one next to it*
- **F8 (low):** The four tenets are an unordered list, yet they can pull against each other and against the goals (sequence versus Goal 1 speed is exactly F1). Consider ordering them so the tie-break is explicit. · *tenets capture forward-looking preference — a tenet is a tie-breaker, and tie-breakers need a rank when they collide*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 13 specs (HOLDALLOC-001 to 007, PICKUP-001 to 006), 7 Decisions rows.
- Code and tests: none in the repository, so there was nothing to sample and 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not present.
- Review type: full review in Full mode, anchored on the existing docs because the directive block is missing (F4).
- Cold-read pass: no change-narration or conversation-dependent wording found in any doc.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.