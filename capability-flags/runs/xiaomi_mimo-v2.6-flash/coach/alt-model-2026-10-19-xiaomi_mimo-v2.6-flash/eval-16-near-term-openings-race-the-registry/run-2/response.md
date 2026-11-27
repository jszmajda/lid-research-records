# LID Coach Review — Visit Planner

**Posture:** Healthy, compact design layer; configuration and downstream coherence need attention.

**Scorecard**
- ⚠ Configuration — the `## LID` block is well-formed (Full, v1.4.0, current with the installed plugin) but the instruction file carries no LID directives
- ✓ Design layer — HLD with four real tenets, one LLD per component, Decisions tables with selected/rejected/accepted-cost on every row
- ✓ Mutation hygiene — no history residue, no obsolete markers, no stale `[inferred]` entries
- ⚠ Linkage — spec IDs are unique and grep-friendly, but no design doc declares the `prefix:` bridge from ID to document
- ⚠ Downstream coherence — every spec is marked implemented while the repo holds no tests and no code
- ⚠ Decision capture — load-bearing thresholds and the same-day checkout call are stated without rationale

**Headline:** The arrow's design half is real and unusually tidy for its size — the fastest wins are running `/update-lid` to install the missing directive block, then reconciling the spec status markers with the actual implementation state.

**Findings (10 total · 2 high · 5 medium · 3 low)**
- **F1 (high):** CLAUDE.md declares Full mode and a version but contains no LID directives — nothing tells a future session to consult LID or walk the arrow · *modes are declared, not inferred* (the mode bullet is only half of configuration; the directive block is what makes the workflow load-bearing) → recommend `/update-lid`
- **F2 (high):** all 15 specs carry `[x]`, which in LID means *implemented — code and tests exist*, yet the repo has zero code and zero tests · *coherence is adjacency* — the EARS→Tests→Code seam asserts a state that isn't present; if implementation lives elsewhere, a pointer would keep the markers honest, otherwise they will be trusted by every future session
- **F3 (medium):** the tenet "an earlier request is never passed by one made after it" meets FILL-004's first-click portal checkout for ≤36h openings, where the earliest `enteredAt` can lose to a later claimant, with no Decisions row naming the trade · *tenet cascade* — consider a row recording the same-day-speed-for-FCFS exchange, or scoping the tenet to queued matching
- **F4 (medium):** solution edges left open across both leaves — what "compatible" and "eligibility" cover (does the claim recheck include site, time window, accessibility?), tie-breaks on equal `enteredAt`, what happens when the delayed scan fails, who may check out, and what closes an entry after an offer · *LLDs close enough of the solution space* — two reasonable agents would diverge here
- **F5 (medium):** the 36-hour boundary, the 20-minute delayed scan, and the 2-hour offer appear in prose with no rationale or Decisions row · *docs carry current intent* — a cold reader's first question will be "why 36 hours?", and nothing on the page answers it
- **F6 (medium):** the HLD's "staff may act for patients who call" never reaches the LLDs or specs; INTAKE-001, FILL-004, and FILL-006 speak of an "authenticated account" / "patient" without separating actor from subject · *effective intent-tree alignment* — a named HLD behavior with no leaf to own it drifts silently
- **F7 (medium):** neither design doc carries `prefix:`/`parent:` frontmatter, and the `FILL` prefix doesn't mirror its leaf folder `fulfillment`, so there is no declared bridge from an ID to its owning doc (convention drift for a project claiming v1.4.0) · *specs are grep-anchored linkage* → the frontmatter half is `/update-lid`'s mechanical reconcile; the prefix spelling is the project's call
- **F8 (low):** "registry" and "registry scan" appear only in the fulfillment LLD and are never defined in the HLD's vocabulary ("one view", "portal search") · *semantic legibility as cheap linkage*
- **F9 (low):** the HLD has no Non-goals or success-metrics sections · *HLD is architecture and rationale* — non-goals especially help future sessions know what not to build
- **F10 (low):** EARS lines deviate from the template shape (no colon after the ID, lowercase "the system shall") · minor, but agents pattern-match the canonical line format

**What was audited**
- Read fully: CLAUDE.md (all 6 tracked files), docs/high-level-design.md, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 15 specs (INTAKE-001…007, FILL-001…008); IDs unique, no collisions
- Linkage metric: 0 `@spec` references in the repo (no code or test files exist to sample); design layer walked HLD → LLD → EARS for both components
- `docs/arrows/` overlay absent, so no index or arrow docs to read (also means the >15-LLD / >200-`@spec` sampling threshold was not triggered)
- Run defaults taken (non-interactive): dispatched as a full review in the declared Full mode rather than refusing over the missing directives; report rendered inline; no files modified — the coach is advisory, so fixes land via you, `/update-lid`, or `/arrow-maintenance`

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.