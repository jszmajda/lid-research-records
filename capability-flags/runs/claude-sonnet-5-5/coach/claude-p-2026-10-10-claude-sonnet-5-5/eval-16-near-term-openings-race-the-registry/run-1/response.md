# LID Coach Report: Visit Planner

## Executive summary

**Posture:** Well-formed arrow with one live design-versus-tenet conflict.

**Scorecard**
- ✓ HLD discipline: problem, approach, ordered tenets and goals, no implementation detail upstream
- ✓ Intent-tree alignment: HLD components map one-to-one to the Intake and Fulfillment LLDs and their `INTAKE-` and `FILL-` specs
- ✓ Mutation hygiene: no change-narration, obsolete markers, or conversational residue in any doc
- ✓ Spec quality: EARS-shaped, unique, stable IDs
- ⚠ Tenet cascade: the Fulfillment near-term path works against the first tenet
- ⚠ Decision capture: the near-term path has no Decisions row
- ⚠ Configuration: the instruction file carries a mode marker but no LID directives

**Headline:** The design tree is clean, cold-readable, and has real tie-breaker tenets. The most valuable next step is to reconcile the ≤36-hour claim window with *First asked, first served*, either by changing the mechanism or by recording the exception.

## Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** Fulfillment's ≤36-hour path lets any eligible signed-in account claim an opening through checkout for 20 minutes before the queue is consulted (`fulfillment-design.md` §Design ¶2; FILL-003/004/005). This can pass earlier requests, which the tenet "an earlier request is never passed by one made after it" rules out. · *tenet cascade: design nodes should lean the way the HLD's tenets say to*
- **F2 (high):** The 36-hour threshold and 20-minute head start have no Decisions & Alternatives row, and no row or decision doc names a trade against the first-served tenet. · *decision capture: a live choice a cold reader would question should carry its rejected alternative and accepted cost*
- **F3 (high):** `CLAUDE.md` has the `## LID` mode block but none of the linked-intent-dev directives, so a fresh session isn't told how to work the arrow. Consider `/update-lid`. · *modes are declared, not inferred*
- **F4 (medium):** Changing a requested service closes the entry and issues a new `enteredAt` (INTAKE-006), so the patient loses their place in line. This is a plausible choice, but it has no Decisions row explaining what it trades against the first-served tenet. · *decision capture*
- **F5 (medium):** Every spec is marked `[x]`, yet the repo contains no tests or code carrying `@spec` annotations, so the arrow stops at EARS and the checkmarks can't be traced. If code lives elsewhere, consider linking it; otherwise the status markers may be ahead of reality. · *tests carry `@spec` annotations* / *coherence is adjacency*
- **F6 (low):** The HLD says staff may act for callers, but no Intake spec covers staff-initiated submissions (INTAKE-001 only mentions an authenticated account). The HLD also has no non-goals list. · *effective intent-tree alignment* / *HLD is architecture and rationale*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, 2 LLDs (intake, fulfillment), 2 spec files (7 INTAKE and 8 FILL specs)
- Not present: `docs/arrows/` overlay, tests, source code, so no code sampling or arrow-path walk was possible
- Cold-read pass and Decisions-table sweep done on all docs

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.