## LID Coach Review — Visit Planner

**Clean intent docs; the arrow stops short of implementation and one tenet is quietly contradicted.**

The HLD, both LLDs, and both spec files are current, well-scoped, and free of changelog residue — a genuinely tidy intent layer for a project its size. The biggest opportunity is closing the downstream half of the arrow: every spec is marked done, but there is no test or code layer to walk into, and the short-notice path needs reconciling with your "First asked, first served" tenet.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no history sections or obsolete markers
- ✓ HLD discipline — architecture-and-rationale only; no schemas or signatures bleeding upstream
- ✓ EARS hygiene — clean `When/If/While … shall` forms, no orphaned ID collisions
- ⚠ Arrow completeness — Tests and Code phases absent while specs read as complete
- ⚠ LLD sufficiency — "registry scan", "compatible", and "eligible" are left open
- ⚠ Tenet cascade — the short-notice claim window undercuts *First asked, first served*
- ⚠ Configuration — mode marker present, but no LID directive naming for a cold session

**Findings (11 total · 4 high · 5 medium · 2 low)**

- **F1 (high):** `CLAUDE.md` has a `## LID` mode block but no directive naming "linked-intent-dev"/"Linked-Intent Development", so a fresh session may not know to load the workflow · *modes are declared, not inferred*
- **F2 (high):** Arrow ends at EARS — no tests and no code anywhere, yet all 15 specs are checked `- [x]`; completion is asserted with nothing downstream to verify it · *canonical arrow shape*
- **F3 (high):** FILL-003/004 let any eligible signed-in account claim a short-notice opening during the 20-minute searchable window, so a later request can pass an earlier one — directly against the "First asked, first served" tenet, with no recorded exception · *intent attaches at the lowest node that dominates it* / *tenets capture forward-looking preference*
- **F4 (high):** "registry scan" (fulfillment-design line 9), "compatible", and "eligible" are undefined; two agents reading these LLDs could land on different implementations · *LLDs close enough of the solution space*
- **F5 (medium):** The 36-hour threshold, the 20-minute scan delay, and the short-notice FCFS bypass have no Decisions & Alternatives row explaining what was traded · *docs carry current intent*
- **F6 (medium):** `- [x]` status markers have no documented meaning and currently imply implemented/verified; consider defining them or dropping them until the arrow reaches code · *docs carry current intent*
- **F7 (medium):** HLD has Problem/Approach/Tenets/Goals/Components but no Non-goals or Success metrics (and target users are only implied) · *HLD is architecture and rationale*
- **F8 (medium):** "First asked, first served" and "Clinical fit precedes utilization" can conflict on a scarce opening, and the tenets are unordered so precedence is left to the reader · *tenets capture forward-looking preference*
- **F9 (medium):** Spec prefix `FILL-` does not match the `fulfillment` leaf path and there is no `prefix:` frontmatter, so `grep FULFILLMENT` finds nothing · *specs are grep-anchored linkage*
- **F10 (low):** Coverage gaps between design and specs: the two-hour offer duration and the claim-path row lock appear in the LLD but have no spec · *coherence is adjacency*
- **F11 (low):** The short-notice offer path never states an offer duration (only the >36h path says two hours), leaving the scan path's behavior open · *LLDs close enough of the solution space*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md`
- Enumerated: 2 LLDs, 2 spec files, 15 spec IDs (7 INTAKE, 8 FILL), 4 HLD tenets
- Encoding: 0 test files, 0 code files, 0 `@spec` annotations, no `docs/arrows/` overlay
- Sampling: project is small (<15 LLDs, no annotation-bearing files), so every file was read end-to-end rather than sampled

**Out-of-scope note:** none — Full mode, so the whole project was reviewed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large — I can help with those too.

---

*Defaults taken in this non-interactive run: dispatch resolved to the "missing directives but LID-shaped artifacts" branch, so a full review ran on the declared Full mode; no follow-up iteration was performed (advisory posture — no files changed); the report was rendered inline rather than persisted to disk.*