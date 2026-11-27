## LID Coach — Visit Planner

### Executive summary

**Posture:** Well-formed design layer with one design-versus-tenet conflict; nothing yet downstream of the specs.

**Scorecard**
- ✓ Doc hygiene — every doc reads as current intent, with no history, planning text or chat residue
- ✓ Spec form — 15 EARS specs with unique, stable, grep-friendly IDs, each traceable to its design doc
- ✓ Granularity — two components, two design docs, one spec segment each, matching the HLD's component list
- ⚠ Tenet cascade — the short-notice path in Fulfillment works against the HLD's first tenet
- ⚠ Decision capture — the choices a reader would most want to question have no Decisions row
- ✗ Arrow completeness — no tests or code in the repository, yet every spec is checked off
- ⚠ Configuration — `CLAUDE.md` declares the mode but lacks the LID directive block

**Headline:** The design layer is clean, small and easy to read cold, with the HLD, both design docs and their specs agreeing closely. The most valuable next step is to resolve the short-notice opening path against "First asked, first served" by changing the mechanism or recording the exception.

### Findings (9 total · 4 high · 4 medium · 1 low)

- **F1 (high):** For openings 36 hours or less away, `fulfillment-design.md` and FILL-003/004 let any eligible signed-in account claim the opening for 20 minutes before the waiting entries are consulted. The tenet says an earlier request is "never passed by one made after it", and no Decisions row records the exception. · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean, or record why not
- **F2 (high):** The 36-hour threshold, the 20-minute open window and the two-hour offer length appear only in design prose, with no source, rejected alternative or accepted cost. · *decision capture* — a choice a cold reader would question needs its reasoning on the page
- **F3 (high):** There are no tests and no code in the repository, while all 15 specs are marked `[x]`. If the implementation lives elsewhere, say where; if not, the markers overstate the state. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, each phase present or its absence explicit
- **F4 (high):** `CLAUDE.md` has the `## LID` block with `Mode: Full` but no linked-intent-dev directives, so future sessions get the mode without the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is what every session keys off
- **F5 (medium):** "Compatible" and "eligible" are never defined, though "Clinical fit precedes utilization" rests on them. How an offer is accepted or declined, and what happens to the entry after confirmation, are also open. · *LLDs close enough of the solution space* — two agents reading the design should land on compatible implementations
- **F6 (medium):** The HLD says staff may act for patients who call, but the specs speak only of an "authenticated account" (INTAKE-001) and an "eligible signed-in account" (FILL-004). Neither design doc covers the staff-assisted path. · *effective intent-tree alignment* — behaviour named upstream has specs downstream
- **F7 (medium):** Editing time, site or accessibility needs keeps `enteredAt` (INTAKE-005), so a narrow early entry can later be broadened and outrank people who asked for that slot first. This is a live choice against the first tenet with no Decisions row. · *decision capture*
- **F8 (medium):** FILL-002 reads as applying to every expired offer. It does not say whether a short-notice opening goes back to portal search, straight to the next entry, or through another 20-minute window. · *scope disambiguation* — a universal-sounding spec must stay unambiguous across variants
- **F9 (low):** The HLD has no non-goals, target users or success metrics. Its four tenets are an unordered list, although "First asked, first served" and "Clinical fit precedes utilization" can pull against each other. · *tenets capture forward-looking preference* — ordered tie-breakers for decisions no spec anticipated

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` — the whole repository, 6 tracked files
- Enumerated: 2 LLDs, 2 spec files, 15 specs (INTAKE-001–007, FILL-001–008), 8 Decisions rows
- Code and tests: none present, so `@spec` placement, tests-first evidence and code naming could not be assessed (0 `@spec` references)
- Arrow overlay: `docs/arrows/` is not installed, so no structural audit was run
- Dispatch: LID-shaped artifacts are present but the directive block is missing, so this was a full review in the declared Full mode
- Non-interactive run: no questions were needed; the report is inline only and no files were edited

### Next steps

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.