# LID Coach — Field Notes

**Posture:** Bootstrapping — arrow in place, content sparse.

**Scorecard**
- ✓ Mode fit — Full mode is declared and matches a small, whole-repo project
- ⚠ Arrow completeness — the arrow currently ends at EARS; no test or code phase exists
- ⚠ LLD sufficiency — the sync design leaves the conflict-timestamp source and sync lifecycle open
- ⚠ Decision capture — the one consequential decision (last-writer-wins) is recorded as "Simpler"
- ⚠ LLD granularity — one leaf owns three components the HLD names separately
- ✓ Mutation hygiene — no history residue, changelogs, or obsolete markers; spec IDs are unique and correctly namespaced to the `SYNC` leaf

**Headline:** The design layer is real and clean — a crisp HLD, one coherent LLD, and two correctly-namespaced EARS specs. The fastest wins are specifying the conflict-timestamp source (it drives a silent-data-loss path) and adding the missing test and code phases.

**Findings (9 total · 3 high · 5 medium · 1 low)**
- **F1 (high):** the arrow stops at EARS — no test files, no code, and zero `@spec` annotations anywhere · *canonical arrow shape* — each phase exists for every in-scope component; consider either completing the arrow with tests-first, or recording explicitly that this repo is currently a design-only stage
- **F2 (high):** the LLD never states whether the wall-clock timestamp is taken at edit time or upload time — under the natural capture-time reading, the clocks the Context says are "wrong by several minutes" decide which edit survives · *LLDs close enough of the solution space* — two reasonable implementers would build incompatible conflict behavior
- **F3 (high):** both specs carry `[x]` status markers asserting implemented behavior that does not exist in the repo · *docs carry current intent* — a doc states current intent as if authored fresh today; a reader cold-reading the spec file would reasonably conclude the behavior shipped
- **F4 (medium):** the last-writer-wins row's rationale is "Simpler." — a cold reader would question the choice and cannot reconstruct what was given up (the discarded edit, potential data loss) or the cost accepted · *decision capture* — the reasoning that survives only in conversation is lost to every future session
- **F5 (medium):** the `sync` LLD owns three components the HLD names separately — device-local store, sync service, and reconciliation — while carrying the local store's SQLite decision · *one LLD per intent component, or split into a sub-HLD when it outgrows one node* — consider giving the device-local store or reconciliation its own leaf so the note-store design has an addressable home
- **F6 (medium):** the sync lifecycle is unspecified — what constitutes a pending edit, what acknowledgment clears it, and how retries and duplicates are handled · *LLDs close enough of the solution space* — an agent filling these edges is exactly where intent drift enters
- **F7 (medium):** the HLD's Architecture section is a component list with no rationale, there is no Key Design Decisions section, and the goals ("No blocked capture in the field", "Convergent state after reconnect") are not stated as measurable outcomes · *HLD is architecture and rationale* — this is the why-layer future sessions load; consider adding the missing sections and an explicit edit-durability goal
- **F8 (medium):** no spec covers the local store, the acknowledgment step, or the "no blocked capture" goal, and the note-storage decision has no behavioral spec · *effective intent-tree alignment* — LLD behaviors with no specs are unnamed intent that drifts silently
- **F9 (low):** both specs open with "the system SHALL" — consider naming the actor explicitly, since a second sync variant or a local-only path would make the scope ambiguous · *scope disambiguation* — a universal-sounding spec must actually be universal

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 0 arrow overlay segments (`docs/arrows/` is not installed)
- Sampled: all repository code and test files — the repo contains documentation only (4 tracked files, 1 commit)
- Linkage metric: 0 `@spec` references, 0 spec-citing tests, 0 implementation files
- Cold-read pass applied to every LID document; decisions-table sweep run against the HLD and LLD above it
- Defaults taken: Full-mode review (the project is fully configured); overlay treated as absent; the report was rendered inline and nothing was written to disk — `/lid-coach` is advisory and does not edit project files

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for this project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.