**/lid-coach review — Visit Planner**

### Executive summary

**Posture:** Clean, well-linked design layer; the arrow stops at EARS, and one fulfillment path quietly trades away a named tenet.

**Scorecard**
- ⚠ Configuration — `## LID` block declares Mode/Version, but the instruction file never states it's using *linked-intent-dev* itself
- ✓ Intent-tree alignment — `INTAKE-*` and `FILL-*` specs are unique, grep-friendly, and trace cleanly to their LLDs and HLD components
- ✓ HLD discipline — no schemas, signatures, or implementation detail have crept upstream
- ⚠ Tenet cascade — the near-term (≤36h) checkout path works against "first asked, first served"
- ✗ Arrow completeness — no tests or code exist anywhere in the repo yet
- ✓ Mutation hygiene — no change-narration, stale markers, or conversational residue in either LLD

**Headline:** The design layer is in good shape — two cleanly scoped LLDs, disciplined specs, nothing accumulating — but the arrow currently ends at EARS (no Tests/Code phase exists), and the 36-hour-or-less fulfillment path quietly trades away the fairness tenet the HLD names elsewhere, with no record of that trade-off.

### Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block declares Mode and Version but never uses the "linked-intent-dev" directive language the coach keys off of — flagged here per dispatch, recommend `/update-lid` to reconcile. · *modes are declared, not inferred*
- **F2 (high):** For openings ≤36 hours out, any eligible signed-in account can win checkout as soon as it's published — racing ahead of patients who asked earlier whenever more than one person is watching the same cancellation — with no Decisions row recording this trade-off against urgency. · *tenets capture forward-looking preference* (tenet cascade vs. "first asked, first served")
- **F3 (high):** All 15 specs across both components are marked done (`[x]`), but no test or code files exist anywhere in the repo — the Tests and Code phases of the arrow haven't started. · *canonical arrow shape* / *tests before code*
- **F4 (medium):** The HLD covers Problem, Approach, Tenets, Goals, and Components, but has no Target Users, Non-Goals, Success Metrics, or Key Design Decisions sections. · *HLD is architecture and rationale*
- **F5 (medium):** Intake's Decisions table names "keys require expiry state" as the accepted cost of client idempotency keys, but neither the design text nor any spec describes how or when a key expires. · *docs carry current intent* (decision capture)
- **F6 (low):** The HLD's four tenets are an unordered list, and two of them ("first asked, first served" vs. the urgency handling above) already show tension — an explicit priority order would help resolve future conflicts. · *tenets capture forward-looking preference*

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files (`intake-specs.md`, `fulfillment-specs.md`)
- Enumerated: 2 components, 2 LLDs, 15 specs (7 Intake + 8 Fulfillment), 0 test files, 0 code files
- No `docs/arrows/` overlay present — not required, not flagged
- Note: no interactive follow-up occurred in this run; where the skill would ask the user how to proceed, this run took the skill's stated default (full review, since the project is clearly LID-shaped despite the missing directive text)

### Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.