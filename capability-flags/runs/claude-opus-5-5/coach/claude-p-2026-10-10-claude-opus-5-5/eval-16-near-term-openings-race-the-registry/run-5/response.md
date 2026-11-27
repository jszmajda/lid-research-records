## LID Coach report: Visit Planner

**Posture:** Bootstrapping — clean design tree, with one design path that leans against a tenet and nothing downstream of the specs.

**Scorecard**
- ✓ Doc hygiene — every doc reads cold as current intent, with no history residue or chat-dependent phrasing
- ✓ LLD granularity — two components, two LLDs, each with a full Decisions & Alternatives table
- ✓ Spec form — EARS phrasing throughout, with unique, stable IDs
- ✗ Tenet cascade — the short-notice path in Fulfillment works against the HLD's first tenet
- ✗ Arrow completeness — no tests or code in the repository, yet every spec is checked off
- ⚠ Configuration — `CLAUDE.md` declares the mode but carries no LID directive block

**Headline:** The HLD, both LLDs and both spec files are tight, current and consistent with each other in almost every respect. The most valuable next step is to settle how short-notice openings square with "First asked, first served".

**Findings (10 total · 4 high · 3 medium · 3 low)**
- **F1 (high):** For openings 36 hours or less away, `fulfillment-design.md:9` and FILL-003/004 let any eligible signed-in account claim the opening for 20 minutes before the matcher looks at waiting entries. A later asker can therefore pass an earlier one, which the tenet "First asked, first served" says never happens. · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean
- **F2 (high):** The Fulfillment Decisions table has no row for the 36-hour split or the 20-minute open window. A cold reader cannot tell what was traded against the ordering tenet or why. · *decision capture* — a choice a reader would question records what was given up
- **F3 (high):** FILL-001–008 and INTAKE-001–007 are all marked `[x]`, but the repository holds no tests, no code and no `@spec` annotations. Consider resetting the markers, or noting where the implementation lives. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, each phase present
- **F4 (high):** `CLAUDE.md` has the `## LID` mode block but no linked-intent-dev directives, so a fresh session is not told to follow the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — configuration lives explicitly in the instruction file
- **F5 (medium):** Several designed behaviours have no spec: the two-hour offer length, the claim's row lock, staff acting for patients who call (HLD Approach; INTAKE-001 covers only "an authenticated account"), and the verified-profile requirement. · *effective intent-tree alignment* — every LLD behaviour has a spec to test against
- **F6 (medium):** FILL-004 covers "a published opening", but only short-notice openings are defined as published (FILL-003), while the LLD Context says ordinary openings are also published weeks ahead. Consider putting the 36-hour scope in the clause. · *scope disambiguation* — a spec found by grep alone is unambiguous about where it applies
- **F7 (medium):** The Fulfillment LLD leaves some edges open: what "compatible" checks, how long a short-notice offer lasts when the visit may be under two hours away, and whether FILL-005 means *active* entries as FILL-001 does. · *LLDs close enough of the solution space* — two agents reading it would build compatible things
- **F8 (low):** The four tenets are an unordered list, though the first two can pull against each other and against the goal "refill canceled visits quickly". Consider ordering them. · *tenets capture forward-looking preference* — tie-breakers, ranked when they can conflict
- **F9 (low):** The HLD has no target users, non-goals or success metrics. Non-goals would be especially useful given the "routine primary-care" boundary in Goals. · *HLD is architecture and rationale*
- **F10 (low):** The `FILL-` prefix does not match its `fulfillment` node name, and neither LLD declares a `prefix:`. Consider declaring it so the link does not rest on inference. · *specs are grep-anchored linkage* — IDs resolve to their owning node by grep

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 15 specs (8 FILL, 7 INTAKE), 8 Decisions rows
- Code and tests: none in the repository, so no arrow path could be sampled past the spec level, and there are 0 `@spec` references
- Arrow overlay: not installed (`docs/arrows/` absent)
- Run notes: this was a non-interactive run. The missing directives in `CLAUDE.md` put the project on the skill's "LID-shaped but directives missing" path, so I ran a full review in the declared Full mode. Nothing was edited.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.