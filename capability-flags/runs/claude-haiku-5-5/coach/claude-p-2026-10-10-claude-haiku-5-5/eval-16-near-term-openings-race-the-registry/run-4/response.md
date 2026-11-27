## LID Coach: Visit Planner

**Posture:** Solid design docs, with drift at the tenet seam. In this repo the arrow stops at the specs.

**Scorecard**
- ✓ Linkage: spec IDs are unique, namespaced (`FILL-`, `INTAKE-`), and each traces to one LLD
- ✓ Mutation: no change-narration, obsolete markers, or planning residue
- ⚠ Tenet cascade: the late-window checkout path can pass an earlier request
- ⚠ Decision capture: two live choices have no Decisions row
- ⚠ Arrow completeness: no tests or code in this repo to walk to
- ⚠ Configuration: `CLAUDE.md` has the `## LID` block but no LID directive

**Headline:** The HLD stays at the architecture level, the tenets are real tie-breakers, and the spec IDs are clean. The fastest wins are resolving the late-window tenet conflict and running `/update-lid` to reconcile the instruction file.

**Findings (12 total · 3 high · 7 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` has the LID block but no LID directive; `/update-lid` can reconcile it · *modes are declared, not inferred*
- **F2 (high):** No tests or code exist in this repo, so the Tests and Code phases can't be checked · *canonical arrow shape*
- **F3 (high):** A ≤36-hour opening can be claimed by checkout in the first 20 minutes, passing an earlier compatible entry. That works against "first asked, first served" and "refill canceled visits quickly", and no row records the trade · *tenets capture forward-looking preference*
- **F4 (medium):** The 36-hour split between offer-by-queue and open checkout has no Decisions row, so the accepted cost of passing an earlier request is unrecorded · *docs carry current intent*
- **F5 (medium):** Changing the requested service resets `enteredAt` and forfeits queue position. Changing time or site keeps it. No row explains why · *docs carry current intent*
- **F6 (medium):** Window edges are open: offer expiry inside 36 hours (FILL-002 doesn't say which window applies), an unclaimed opening crossing the threshold, and checkout while an offer is outstanding · *LLDs close enough of the solution space*
- **F7 (medium):** Offer notifications have no specified path. FILL-007 covers the outbox only for committed ownership, though *commit before communicating* applies to offers too · *LLDs close enough of the solution space*
- **F8 (medium):** Load-bearing terms are defined nowhere on the page: "compatible", "eligible", "registry", "matcher", "portal search", "checkout". The fulfillment design says it validates clinical compatibility without saying against what · *docs carry current intent*
- **F9 (medium):** Staff-assisted intake (named in the intake Context and the HLD) has no spec · *effective intent-tree alignment*
- **F10 (medium):** All 15 specs are marked `[x]`, with no legend and no code or tests to back "done" · *coherence is adjacency*
- **F11 (low):** The tenets aren't ordered, though "first asked" and "refill quickly" collide in F3. Saying which wins would narrow the lean · *tenets capture forward-looking preference*
- **F12 (low):** The HLD has no non-goals, target users, or success metrics · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/fulfillment/fulfillment-design.md` and `-specs.md`, `docs/intent/intake/intake-design.md` and `-specs.md`
- Enumerated: 2 LLDs, 2 spec files, 15 specs (FILL-001 to FILL-008, INTAKE-001 to INTAKE-007)
- Arrow-path sampled: none, because the repo has no code or tests
- Linkage metric: 0 `@spec` annotations, because there is no code
- Overlay: `docs/arrows/` is absent. At this size the sampling reference wasn't needed.
- Dispatch: full review. The project is LID-shaped (HLD and specs present) but its instruction file lacks the directive, so F1 is raised as the configuration finding.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.