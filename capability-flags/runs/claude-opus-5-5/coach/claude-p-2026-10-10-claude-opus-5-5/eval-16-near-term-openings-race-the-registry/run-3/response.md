# LID Coach — Visit Planner

## Executive summary

**Posture:** *Clear, well-shaped intent docs; one design path leans against the lead tenet, and the arrow stops at specs.*

**Scorecard**
- ✓ Doc hygiene — every doc reads cold, with no history residue, planning text or obsolete markers
- ✓ LLD granularity — Intake and Fulfillment are two clean components with matching spec prefixes
- ✓ Spec form — all 15 specs are EARS-shaped with unique, stable IDs
- ⚠ Tenet cascade — the short-notice path in Fulfillment works against "First asked, first served"
- ⚠ Decision capture — the choices a reader would most want to question have no Decisions row
- ✗ Arrow completeness — no tests or code in the repository, yet every spec is checked `[x]`

**Headline:** The HLD's tenets are real tie-breakers and the two LLDs are concise and specific. The most valuable next step is to resolve how the 20-minute open-checkout window for short-notice openings squares with "an earlier request is never passed by one made after it".

## Findings (10 total · 4 high · 4 medium · 2 low)

- **F1 (high):** Short-notice openings can go to someone who asked later, or never asked. For openings 36 hours or less away, `fulfillment-design.md` (and FILL-003/004) opens portal checkout to any eligible signed-in account for 20 minutes before consulting the interest list. Patients who rely on staff after calling are also outside that window. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say; here the tenet is "First asked, first served".
- **F2 (high):** The 36-hour split and the 20-minute open window have no Decisions & Alternatives row. Nothing says what was given up or that the tenet was knowingly traded, so a cold reader cannot tell whether F1 is intended. · *decision capture* — a choice a future reader would question needs its reasoning on the page.
- **F3 (high):** No tests or code exist in the repository, but all 15 specs are marked `[x]`. If the implementation lives elsewhere, consider saying where; if not, the markers overstate status. · *canonical arrow shape* — HLD → LLDs → specs → tests → code, each phase present and linked by `@spec`.
- **F4 (high):** `CLAUDE.md` has the `## LID` mode block but none of the linked-intent-dev directives, so future sessions get the mode without the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is the foundation everything else keys off.
- **F5 (medium):** FILL-002 ("release the opening and run matching again") reads as universal, but there are two matching paths. It does not say what happens when an offer expires after the opening has crossed inside 36 hours. · *scope disambiguation* — a spec that applies to one variant should name it in its WHEN clause.
- **F6 (medium):** Fulfillment leaves some edges open: whether rematch can re-offer to the entry that just let its offer lapse, what accepting an offer does, and how an opening moves between the long-notice and short-notice paths. A repeating two-hour offer to an unresponsive patient could work against the "refill quickly" goal. · *LLDs close enough of the solution space* — two agents reading the doc should land on compatible implementations.
- **F7 (medium):** Some designed behaviors have no spec: the two-hour offer duration, offer acceptance, the row lock on claim, and the staff-assisted path named in the HLD Approach. · *effective intent-tree alignment* — behavior with no spec has nothing to test against and drifts silently.
- **F8 (medium):** Intake keeps `enteredAt` when time, site or accessibility needs change but resets it on a service change, with no Decisions row. A patient can widen their window later and keep their place, which a reader holding "First asked, first served" would question. · *decision capture*.
- **F9 (low):** The four tenets are unordered, though "First asked, first served" and "Clinical fit precedes utilization" can pull in different directions. Consider ranking them. · *tenets capture forward-looking preference* — tie-breakers need an order when they can conflict.
- **F10 (low):** The HLD has no non-goals, target users, key design decisions or success metrics. The 36-hour policy split may belong there as a key decision. · *HLD is architecture and rationale* — the HLD carries the long-lived "why".

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 15 specs (8 `FILL`, 7 `INTAKE`), 8 Decisions rows.
- Code and tests: none in the repository, so there are 0 `@spec` references and nothing to sample.
- Arrow overlay: `docs/arrows/` is not present, so no structural audit was available.
- Dispatch: LID-shaped artifacts are present and the mode is declared Full, but the directive text is missing, so I ran a full review and raised the gap as F4.
- This was a non-interactive run; no questions came up that needed a default. Nothing was edited.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.