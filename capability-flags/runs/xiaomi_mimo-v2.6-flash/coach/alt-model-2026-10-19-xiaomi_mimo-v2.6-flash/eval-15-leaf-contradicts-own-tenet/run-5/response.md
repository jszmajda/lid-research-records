**Shelfwise — LID Coach review**

**Posture:** Bootstrapping but unusually tidy — the design layer is real and the drift is concentrated in configuration and one unrecorded trade-off.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; four tenets, two goals, no implementation detail
- ✓ LLD granularity — one leaf per component, matching the HLD's Components list; segments don't overlap
- ✓ Spec hygiene — 14 EARS specs, unique prefixes, every one trigger-scoped (no bare "The system SHALL")
- ✓ Decision capture — most Decisions rows name the cost accepted; the expiry row even names Goal 1's tension
- ⚠ Tenet cascade — branch-first allocation trades Tenet 1 with nothing on the page recording it
- ⚠ Configuration — the instruction file declares a mode but carries no LID directives

**Headline:** The arrow is well-formed and reads cleanly cold across both components; the fastest wins are reconciling `CLAUDE.md` via `/update-lid` and recording the allocation-order exception before any code lands.

**Findings (8 total · 2 high · 4 medium · 2 low)**
- **F1 (high):** `CLAUDE.md`'s `## LID` block sets `- Mode: Full` but never names *linked-intent-dev*, so a fresh agent has no directive to load the workflow · *modes are declared, not inferred* (the mode must be visible and the block must point at the methodology) → `/update-lid`
- **F2 (high):** branch-first allocation hands the copy to a later local requester ahead of an earlier county-wide waiter — against Tenet 1, "nobody's wait is lengthened by a patron who asked after them" — with no row or decision doc recording the exception · *tenet cascade* (design nodes should lean the way the tenets say; conflicts need the trade named)
- **F3 (medium):** that same allocation-order choice survives only as a prose aside in `hold-allocation-design.md:11` ("keeps most copies off the courier van") — no Decisions row · *decision capture* (a live decision should record what was given up, not just a passing rationale)
- **F4 (medium):** cancelling a hold while its copy sits `allocated` on the shelf is designed nowhere — in-transit cancellation is covered (HOLDALLOC-007), the on-shelf case is left to the implementer's guess · *LLDs close enough of the solution space*
- **F5 (medium):** the spec↔LLD seam drifted one step each way: HOLDALLOC-005's "leave for reshelving" case appears in no design prose, and the LLD's `allocated` marking (`hold-allocation-design.md:13`) has no spec creating the state · *coherence is adjacency* (adjacent levels should agree) — for precise enumeration, `/arrow-maintenance`
- **F6 (medium):** every spec is marked `[x]` with no legend; in a codeless repo the marker can't mean "implemented," so a cold reader can't say what it asserts · *docs carry current intent* (in-conversation-only meaning — content that only resolves if you were in the chat)
- **F7 (low):** prefixes `HOLDALLOC`/`PICKUP` appear only inside spec files — no leaf records its prefix, so ID→node mapping rides on folder-name abbreviation · *specs are grep-anchored linkage*
- **F8 (low):** Tenet 4 opens with the triggered rule "a closed hold's record is deleted," already fixed by PICKUP-003/005; the tie-breaker worth keeping is the privacy lean · *tenets capture forward-looking preference* (a tenet is a lean, not a when-X-do-Y rule)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (5 docs, 88 lines)
- Enumerated: 2 LLDs, 2 spec files, 14 spec IDs (7 HOLDALLOC, 7 PICKUP)
- Arrow-path sampled: both segments end-to-end (HLD component → LLD → spec file)
- Linkage: 14 `@spec`-shaped IDs; zero `@spec` annotations in code/tests — no code or tests exist yet, so those dimensions couldn't be exercised
- No `docs/arrows/` overlay, so sampling guidance and structural enumeration weren't applicable
- Non-interactive run defaults taken: Full mode per the declared marker; report rendered inline with no file edits (advisory posture); no user prompts asked

Out-of-scope note: none — Full mode covers the whole project.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.