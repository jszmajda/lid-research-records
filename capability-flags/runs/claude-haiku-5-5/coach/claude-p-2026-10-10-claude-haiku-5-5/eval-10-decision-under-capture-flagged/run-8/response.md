**LID Coach review: sync project**

**Posture:** Sound foundations, early and thin. The conflict design needs the most attention.

**Scorecard**
- ✓ Mode fit: Full matches a single-subsystem project declared in the instruction file
- ✓ Spec hygiene: SYNC-001 and SYNC-002 are EARS-formed, with grep-anchored IDs and scoped WHEN clauses
- ✓ Mutation, not accumulation: no change-narration, obsolete markers, or planning residue
- ✓ HLD discipline: problem, approach, goals, and non-goals, with no schemas or signatures
- ⚠ LLD sufficiency: conflict handling leaves edges open
- ⚠ Decision capture: the conflict-rule row doesn't record its cost

**Headline:** The HLD is clean and the two sync specs are well-formed, which is a solid base. The most valuable next step is to pin down what a losing edit means, then re-check the wall-clock rule against the clock skew the LLD already names.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** Conflict handling leaves edges open: "edit" is undefined (whole note or field?), the fate of the discarded edit is unstated, and "pending" is undefined if an upload is interrupted · *LLDs close enough of the solution space*
- **F2 (high):** The conflict-rule row says only "Simpler." and doesn't record what was given up: the losing edit is discarded, and the row doesn't say what that costs a technician · *docs carry current intent* (decision capture)
- **F3 (medium):** Wall-clock last-writer-wins sits awkwardly with the skew the Context names; a "later" edit can be the wrong one · *boring over clever*, the HLD's own tenet. A well-worn ordering scheme may honor SYNC-002's intent better under skew.
- **F4 (medium):** No tests or code exist yet, so the arrow only walks as far as specs and tests-first and `@spec` linkage can't be assessed · *canonical arrow shape*. This is expected at this stage.
- **F5 (medium):** The HLD names a "device-local store" as its own architecture piece, but it has no LLD, and the SQLite decision sits inside the sync LLD · *one LLD per intent component*. Consider whether the store is its own node or part of sync.
- **F6 (low):** The HLD has no target users, key design decisions, or success metrics · *HLD is architecture and rationale*. These sections tell a future reader why, and are worth adding as the design firms up.
- **F7 (low):** One tenet covers the design. The tension this LLD resolved (local capture versus central consistency) is a candidate for a second tenet · *tenets capture forward-looking preference*, a tie-breaker for the next decision of that shape.

**What was audited**
- Dispatch: fully configured (LID directives, Full mode marker, HLD and `docs/intent/`), so this is a full review
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 specs
- Arrow overlay: not present (no `docs/arrows/`), so no index or arrow paths were read
- Code and tests: none in the repository, so no `@spec` linkage was measured (0 references)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.