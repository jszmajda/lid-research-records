# LID Coach — Visit Planner

## Executive summary

**Posture:** Clear, well-shaped design layer; one design choice runs against the first tenet, and the arrow stops at the specs.

**Scorecard**
- ✓ Design-tree shape — one HLD, two leaf designs that match the HLD's Components list, each with its own spec file
- ✓ Mutation hygiene — every doc reads as current intent, with no changelog or "was X, now Y" residue
- ✓ Decision capture (existing rows) — all eight Decisions rows name the rejected alternative and the accepted cost
- ✗ Tenet cascade — the short-notice path in Fulfillment works against "First asked, first served"
- ✗ Arrow completeness — no tests or code in the repo, though all 15 specs are checked `[x]`
- ⚠ Design sufficiency — several terms and behaviours the specs lean on are not defined anywhere
- ⚠ Configuration — `CLAUDE.md` has the mode marker but not the LID directive block

**Headline:** The design layer is small, legible and traceable from HLD to spec. The most valuable next step is to decide whether the 20-minute open-search window for short-notice openings is a deliberate exception to "First asked, first served", and to record that decision either way.

## Findings (11 total · 4 high · 5 medium · 2 low)

- **F1 (high):** Short-notice openings bypass the waitlist for 20 minutes. For openings 36 hours or less away, `fulfillment-design.md` (Design ¶2, FILL-003/004/005) lets any eligible signed-in account book before the waitlist is consulted, so a patient who asked weeks ago can be passed by someone who never asked. The HLD's first tenet says an earlier request "is never passed by one made after it". · *tenet cascade* — leaf designs should lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The 36-hour split and 20-minute open window have no Decisions row. Nothing records the alternative (offer to the waitlist first, with a shorter offer), the reason, or the tenet traded away, and the Context section only says short-notice cancellations "also occur". · *decision capture* — a choice a cold reader would question needs its reasoning on the page.
- **F3 (high):** All 15 specs are marked `[x]`, but the repo holds no tests, no code and no `@spec` annotations. If the implementation lives in another repo, consider saying where; if it does not exist yet, the markers are overstating status. · *canonical arrow shape* — HLD → LLDs → specs → tests → code, with each phase present and linked.
- **F4 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full) but none of the linked-intent-dev directives, so a new session is told the mode but not the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is where LID's foundation is made explicit.
- **F5 (medium):** "Compatible" and "eligible" carry the second tenet ("Clinical fit precedes utilization") but are not defined in any design or spec. FILL-006 says to recheck eligibility without saying what is checked. · *LLDs close enough of the solution space* — two agents reading the design should land on compatible implementations.
- **F6 (medium):** Several designed behaviours have no spec, or a spec with no design:
  - the two-hour offer length is in the design but not in FILL-001;
  - accepting or declining an offer has no spec;
  - staff acting for a patient (HLD Approach) is not covered, since INTAKE-001 only names "an authenticated account";
  - idempotency-key expiry is an accepted cost in Intake's Decisions table, with no rule behind it;
  - ties on `enteredAt` are unresolved.
  
  · *effective intent-tree alignment* — behaviour without a spec is unnamed intent with nothing to test against.
- **F7 (medium):** The HLD's "normalized view of clinic openings" has no owning component, so how openings and cancellations enter the system is undesigned. "Registry scan" in Fulfillment and FILL-003/005 uses a term defined nowhere. · *docs carry current intent, written to be read cold* — a doc should stand without the conversation that produced it.
- **F8 (medium):** Some specs read as universal but are quietly scoped:
  - FILL-002 does not say which path an expired offer re-enters once the opening has crossed inside 36 hours;
  - FILL-004's "published opening" leaves open whether openings more than 36 hours away are ever searchable;
  - FILL-005 drops the word "active" that FILL-001 has.
  
  · *scope disambiguation* — a spec found by grep, out of context, should still be unambiguous.
- **F9 (medium):** The HLD has no Target Users, Non-Goals, Key Design Decisions or Success Metrics sections. Non-goals matter most here: the Goals say "routine primary-care", but nothing states what is excluded. · *HLD is architecture and rationale* — the HLD carries the long-lived "why" and the edges of scope.
- **F10 (low):** The four tenets are an unordered list, and at least two can pull against each other (first-asked order versus refilling quickly, which is the tension in F1). Consider stating precedence. · *tenets capture forward-looking preference* — tenets are tie-breakers, so they need an order when they conflict.
- **F11 (low):** Fulfillment's specs use the prefix `FILL`, but nothing in `fulfillment-design.md` declares it (no `prefix:` frontmatter), so the link from prefix to design relies on a reader's guess. · *specs are grep-anchored linkage* — IDs should lead to their owning design with one grep.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` (intake, fulfillment)
- Enumerated: 2 leaf designs, 2 spec files, 15 specs (INTAKE-001 to 007, FILL-001 to 008), 8 Decisions rows
- Code and tests: none in the repo; 0 `@spec` references
- Arrow overlay: `docs/arrows/` not present, so no structural audit input
- Dispatch: `CLAUDE.md` lacks the directive block but the project has LID artifacts, so I ran a full review in the declared Full mode
- Non-interactive run: no questions needed defaults; no files were edited

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are the natural pair to start with.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.