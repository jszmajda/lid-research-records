# LID Coach — Visit Planner

## Executive summary

**Posture:** Clean, well-shaped design tree; one design choice runs against the lead tenet, and the arrow stops at specs.

**Scorecard**
- ✓ Doc hygiene — every doc reads as current intent, with no history, changelog or conversational residue
- ✓ Design-tree shape — one HLD, two leaf designs matching the HLD's two components, stable and unique spec IDs
- ✓ Decision capture (intake) — the Decisions tables name the rejected alternative and the accepted cost
- ✗ Tenet cascade — the short-notice path in Fulfillment works against "First asked, first served"
- ✗ Arrow completeness — no tests or code in the repository, yet all 15 specs are checked off
- ⚠ Configuration — `CLAUDE.md` has the mode marker but not the LID directive block

**Headline:** The docs are tight, cold-readable and consistently structured, and the Decisions tables are the kind most projects never get to. The most valuable next step is to settle the short-notice opening path against "First asked, first served": either change the design or record the exception on the page.

## Findings (11 total · 4 high · 5 medium · 2 low)

- **F1 (high):** Short-notice openings (36 hours or less) are opened to any signed-in account for 20 minutes before the waitlist is consulted (`fulfillment-design.md:9`, FILL-003/004/005). An account that asked later, or never asked, can take the opening ahead of the earliest waiting entry. The HLD says close-in cancellations are the common case, and the tenet says an earlier request is "never passed". · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean
- **F2 (high):** That same choice has no Decisions row: nothing names the tenet traded away, the gain, or where 36 hours and 20 minutes come from. A cold reader would want to reverse it and can't tell whether it was deliberate. · *decision capture* — a choice a reader would still question carries its reasoning on the page
- **F3 (high):** The arrow ends at specs: there are no tests, no code and no `@spec` annotations, while every spec is marked `[x]`. If the implementation lives elsewhere, consider saying where; if it doesn't exist yet, the markers overstate. · *canonical arrow shape* — HLD → LLDs → specs → tests → code, each phase present
- **F4 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full) but no linked-intent-dev directives, so future sessions aren't told to follow the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is the foundation everything else keys off
- **F5 (medium):** The four tenets are unordered, and none speaks to refill speed, though the goal "refill canceled visits quickly" is evidently what F1's design is leaning on. Consider ordering them, and stating the speed-versus-order lean. · *tenets capture forward-looking preference* — tie-breakers, ranked when they can collide
- **F6 (medium):** Fulfillment leaves edges open around offers: the two-hour offer is stated only for far-out openings; what "run matching again" means for a short-notice opening is unclear; and it is unclear whether an opening under offer counts as "free" for FILL-004. · *LLDs close enough of the solution space* — two agents reading it would build compatible things
- **F7 (medium):** Some described behaviour has no spec: offer acceptance, the two-hour offer duration, and staff acting for patients who call (INTAKE-001 and FILL-004 name only authenticated or signed-in accounts). · *coherence is adjacency* — specs match the design above them
- **F8 (medium):** The HLD's "normalized view of clinic openings", and the goal "maintain one view of openings and ownership", has no owning design node; neither Intake nor Fulfillment describes where openings come from. · *effective intent-tree alignment* — every architecture concept traces to a node
- **F9 (medium):** Changing the requested service resets a patient's place in line while other edits keep it (`intake-design.md:7`, INTAKE-006). This is a queue-position choice a reader may question, with no Decisions row. · *decision capture*
- **F10 (low):** "Registry scan" is used in Fulfillment and FILL-003 without the registry being defined anywhere. · *docs carry current intent, written to be read cold*
- **F11 (low):** The HLD has no non-goals, target users, key design decisions or success metrics. Also, the `FILL` prefix isn't declared on the Fulfillment design, whereas `INTAKE` matches its node name. · *HLD is architecture and rationale*; *specs are grep-anchored linkage*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 15 specs (7 INTAKE, 8 FILL), 8 Decisions rows (all swept)
- Code and tests: none in the repository; 0 `@spec` references, so no arrow paths could be sampled past specs
- Arrow overlay: not installed (`docs/arrows/` absent)
- Dispatch: the instruction file lacks the LID directives but the project is LID-shaped, so this was a full review in Full mode
- Non-interactive run: no questions arose that needed a default, and the report was not saved to disk

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are the natural pair to start with.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.