# LID Coach Report: Shelfwise

**Healthy spec structure, with one tenet conflict and an instruction file to reconcile.**

**Scorecard**
- ✓ Mutation hygiene: the docs read as current intent, with no change-narration or history residue
- ✓ Linkage: spec IDs are unique, namespaced by component, and written in EARS form
- ✓ Adjacent coherence: the LLDs and specs agree on the 7-day window, the 15-hold cap, and the slip types
- ⚠ Tenet fit: the local-first allocation rule pulls against the "waiting is honored in sequence" tenet, and nothing records that trade
- ⚠ Configuration: `CLAUDE.md` has the `## LID` mode block but no LID directive text
- ✗ Arrow completeness: the arrow stops at the specs in this repo, with no tests or code

**Headline:** The two components, their specs, and the decision tables are clean and linked. The fastest wins are reconciling the instruction file and deciding how the first tenet should meet local-first allocation.

**Findings (11 total · 3 high · 4 medium · 4 low)**
- **F1 (high):** `CLAUDE.md` has the mode and version but no LID directive text, so `/update-lid` can reconcile it · *modes are declared, not inferred* (the mode lives in the instruction file)
- **F2 (high):** Local-first allocation can lengthen an older county-wide hold's wait, which pulls against the "waiting is honored in sequence" tenet · *tenet cascade* (a mechanism working against a tenet, with no shared wording)
- **F3 (high):** The arrow ends at the specs here, with no tests or code · *canonical arrow shape*
- **F4 (medium):** No Decisions row records choosing local-first over oldest-first across branches · *decision capture* (a live choice that survives only in prose)
- **F5 (medium):** The failed-delivery staff call reaches patrons off their chosen channel, and the row doesn't name the "patrons hear once" tenet it trades against · *tenet cascade*
- **F6 (medium):** The tenets are an unordered list, but "staff attention goes to exceptions" and "patrons hear once" can conflict · *tenets capture forward-looking preference* (ordering when they could conflict)
- **F7 (medium):** Cancelling a hold that isn't in transit (an allocated copy, or one already on the holds shelf) has no spec, and nothing defines when `allocated` is set or cleared · *LLDs close enough of the solution space*
- **F8 (low):** The "Hold history is not kept" tenet's second sentence is a triggered rule duplicated in PICKUP-003 and PICKUP-005 · *tenets capture forward-looking preference* (lean, not trigger)
- **F9 (low):** Every spec is marked `[x]`, with no legend for what the mark means · *delete obsolete specs* (a status marker's meaning should be clear)
- **F10 (low):** The HLD has no non-goals or target users · *HLD is architecture and rationale*
- **F11 (low):** PICKUP-005 and the pickup design depend on allocation without linking the hold-allocation LLD · *verticalize intent* (cross-component references)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 13 spec IDs (HOLDALLOC-001 to 007, PICKUP-001 to 006)
- Arrow-path sampled: none. There are no tests or code in this repo to walk to.
- `@spec` references: 0. No code or tests are present.
- No `docs/arrows/` overlay, so no structural index to check.
- Git history: a single commit, `fixture`.

**Notes on the findings**
- F2 example: a patron places a hold at Branch 1 on Jan 1. A patron places one at Branch 2 on Jan 5. A copy is checked in at Branch 2 on Jan 10. The Branch 2 patron gets it, and the earlier patron keeps waiting (`docs/intent/hold-allocation/hold-allocation-design.md:11`, `docs/high-level-design.md:13`). This may be exactly the trade you want. If so, recording it in a Decisions row resolves F2 and F4 together.
- F3 depends on where the code lives. If the implementation is in another repo, point me at it and I'll re-run the arrow check against it.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.