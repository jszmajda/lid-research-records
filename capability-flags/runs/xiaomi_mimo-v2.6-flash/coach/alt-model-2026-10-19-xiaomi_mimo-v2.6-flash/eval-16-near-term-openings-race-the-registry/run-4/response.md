# LID Coach — Visit Planner

**Posture: Bootstrapping — design layer is solid; downstream arrow not yet built, with two intent gaps worth closing before code starts.**

**Scorecard**
- ✓ **Design-layer coherence** — every LLD behavior has a spec, every spec traces back to an LLD; no adjacent-level drift found
- ✓ **Tenet quality** — four real tie-breakers, each with a defensible opposite, none spec-shaped
- ⚠ **Tenet cascade** — near-day checkout trades against "first asked, first served" with no recorded exception
- ⚠ **Configuration** — mode declared, but the instruction file never points agents at `linked-intent-dev`
- ⚠ **Downstream linkage** — 15 specs, zero tests/code; `[x]` markers read as completion claims nothing corroborates
- ✓ **Mutation hygiene** — no history residue, no obsolete markers, docs hold up on a cold read

The design layer is genuinely in good shape: two clean LLDs whose scopes don't overlap, specs that mirror the design text closely, and decisions tables with real accepted costs. The fastest wins now are reconciling the instruction file so future agents actually load the workflow, and recording the one tenet trade the fulfillment design already makes in practice.

**Findings (10 total · 2 high · 5 medium · 3 low)**

- **F1 (high):** the `## LID` block declares mode and version but contains no directive naming `linked-intent-dev` — an agent reading `CLAUDE.md` has no signal to load the workflow skill · *modes are declared, not inferred* (a declaration nobody is told to read is half a declaration) → **`/update-lid`**
- **F2 (high):** FILL-003/004 let any eligible signed-in account win a ≤36h opening through checkout, passing earlier interest entries — a direct trade against tenet "First asked, first served … an earlier request is never passed by one made after it," recorded nowhere; the intake service-change rule (new entry, new `enteredAt`) trades the same tenet and is likewise unrecorded · *tenets capture forward-looking preference* (future sessions meet the conflict cold and resolve it arbitrarily)
- **F3 (medium):** the fulfillment LLD's central mechanism — the 36-hour split, the 20-minute scan delay, immediate portal publish — has no Decisions row; a cold reader cannot reconstruct why 36h or why 20 minutes · *decision capture* (docs carry current intent)
- **F4 (medium):** "compatible" and "eligible" are never enumerated anywhere — HLD says "clinical compatibility," FILL-006 says "service and patient eligibility," no doc defines either; intake's status lifecycle (active/closed/withdrawn) and "registry scan" are likewise undefined · *LLDs close enough of the solution space* (two reasonable agents would land on different matching rules)
- **F5 (medium):** the HLD's staff-acting path ("staff may act for patients who call") appears in intake's Context but gets no design detail and no spec in either component · *effective intent-tree alignment* (behavior with no spec drifts silently because there's nothing to test against)
- **F6 (medium):** all 15 specs carry `- [x]` while the repo has no tests or code — unclear whether the box means "authored" or "implemented," and if the latter it claims completion at a seam with nothing beneath it · *coherence is adjacency* (adjacent levels must agree)
- **F7 (medium):** specs don't disambiguate portal vs. staff-assisted flows ("authenticated account," "eligible signed-in account"); with a staff-acting variant on the HLD's own horizon, the litmus fails — a second variant would leave these ambiguous · *scope disambiguation* (a universally-sounding spec that is quietly scoped is an implementation trap)
- **F8 (low):** spec prefix `FILL` doesn't match the leaf name `fulfillment`, so grepping the leaf name misses its specs — consider making the prefix explicit via `prefix:` frontmatter on the LLD while the IDs are still cheap to settle · *specs are grep-anchored linkage*
- **F9 (low):** four tenets sit in an unordered list where "first asked, first served" and "clinical fit precedes utilization" can conflict; FILL-001 resolves it (filter, then earliest) but the tenet list doesn't state the precedence · *tenets capture forward-looking preference* (an unordered list when tenets can conflict leaves the tie-break implicit)
- **F10 (low):** cold-read vocabulary drift — "registry scan," "verified profile" (intake) vs. "signed-in account" (fulfillment), "patient" vs. "account" — small ambiguities a fresh reader has to resolve unaided · *docs carry current intent* (in-conversation-only meaning)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files — the entire repository
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 INTAKE, 8 FILL), 8 Decisions rows, 4 tenets
- Spec hygiene: all 15 IDs unique, EARS shape consistent, no `[inferred]` or `[obsolete]` markers anywhere
- Code/tests: none exist (git history is a single fixture commit), so no `@spec` annotation sampling was possible
- No `docs/arrows/` overlay present, so index-guided sampling did not apply
- Run notes (non-interactive defaults taken): full review per the declared Full mode; report rendered inline and not persisted to disk; no project files modified — advisory posture stands

**Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.**

**If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.**