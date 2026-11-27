# LID Coach Review — Field Notes

**Posture:** Bootstrapping — arrow skeleton in place, intent sparse and one seam internally at odds.

**Scorecard**
- ✗ Arrow completeness — intent stops at EARS; no tests or code exist
- ⚠ Linkage hygiene — spec↔LLD linkage is clean, but nothing downstream to link to
- ⚠ HLD discipline — no upstream implementation bleed, but the architecture *why* is thin
- ⚠ Decision capture — the load-bearing conflict decision is recorded only as "Simpler."
- ⚠ LLD coherence — the conflict design contradicts the clock-skew fact stated beside it
- ✓ Mutation hygiene — docs are clean, present-tense, no history residue
- ✓ Mode fit — Full mode is right for a project this small and greenfield
- ✓ Verticalization — one design axis, no parallel index or tag structure

**Headline:** The `SYNC` arrow is genuinely spec-linked and the docs read cold without residue — the fastest wins are reconciling the wall-clock conflict decision against its own stated clock skew, and giving the other two architecture concepts (device-local store, reconciliation) their own intent.

**Findings (6 total · 3 high · 3 medium)**
- **F1 (high):** the arrow stops at EARS — no tests, no code, so no spec can be walked to a consumer · *canonical arrow shape* / *tests before code* (specs drive tests drive implementation)
- **F2 (high):** `sync-design.md` Conflict handling picks last-writer-wins by device wall-clock while its own Context says device clocks are "frequently wrong by several minutes" — the chosen mechanism defeats its own premise · *LLDs close enough of the solution space* (design must be followable without guessing)
- **F3 (high):** the LWW Decisions row gives only "Simpler." as rationale; a cold reader holding the clock-skew context would question or reverse it and cannot reconstruct what was given up · *docs carry current intent — decision capture* (live decisions need their alternative and cost on the page)
- **F4 (medium):** the HLD is architecture-level but skeletal — Approach and Architecture are one-liners, with no target users, key design decisions, or measurable success metrics · *HLD is architecture and rationale* (the long-lived *why* lives here)
- **F5 (medium):** `SYNC-001` covers upload and `SYNC-002` covers conflict, but the LLD's "merge into the canonical store" and the device-local note store have no specs at all · *effective intent-tree alignment* (behaviors with no specs are unnamed intent)
- **F6 (medium):** the HLD names three architecture concepts (device-local store, sync service, reconciliation) but only Sync has an LLD — store and capture are missing intent components · *one LLD per intent component* (the design tree should mirror the architecture)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 EARS specs; 0 test files, 0 source files, 0 `@spec` references
- No arrow overlay present (`docs/arrows/` absent); sampling thresholds not reached, so a full projective read was done instead of sampling
- Cold-read pass and Decisions & Alternatives sweep run over all three LID docs
- Defaults applied (non-interactive run): Full-mode review, report rendered inline only, no files edited (advisory posture), no follow-up conversation started

**Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.**

**If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.**