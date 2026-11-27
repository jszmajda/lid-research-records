**LID Coach — Field Notes**

**Executive summary**

*Healthy foundation, with the arrow stopping short of compile and one live decision under-recorded.*

**Scorecard**
- ✓ Linkage hygiene — two globally unique, grep-friendly IDs resolving cleanly to the `SYNC` leaf
- ✓ Mutation hygiene — docs read as current intent; no change-narration or `[obsolete]` residue
- ✓ Mode fit — Full mode matches a repo whose whole surface is the one `sync` component
- ⚠ Arrow completeness — specs exist; Tests and Code phases do not
- ⚠ Decision capture — the conflict-resolution tradeoff isn't on the page
- ⚠ HLD completeness — architecture and rationale are thin for what the arrow depends on

The design docs are clean and coherent for their size; the fastest wins are recording why wall-clock last-writer-wins is acceptable despite the clock-skew the LLD itself flags, and not letting `[x]` specs imply code and tests that don't exist.

**Findings (6 total · 2 high · 3 medium · 1 low)**

- **F1 (high):** Both specs are marked `[x]`, yet there is no test suite and no source code in the repo—the Tests and Code phases are absent · *canonical arrow shape* (all five phases present) and *tests before code* (tests preload the target's use before implementation)
- **F2 (high):** The Conflict-handling logic is chosen as "Last-writer-wins by device wall-clock" with rationale "Simpler.", while the LLD's own Context says device clocks are "frequently wrong by several minutes" and only resync on reconnect—the doc never reconciles trusting a clock it just said is untrustworthy, and the row records no cost given up · *docs carry current intent / decision capture* (a live decision a cold reader would question, with its tradeoff left out)
- **F3 (medium):** The single `sync` LLD bundles three HLD architecture concepts—device-local store, sync service, reconciliation—without giving the store a design; consider whether it's a sub-HLD over the store and sync-service leaves · *one LLD per intent component* (a node bundling distinct concerns may be a sub-HLD in disguise)
- **F4 (medium):** Merge/upload semantics beyond the two-device conflict are left open—upload retry, idempotency on reconnect, and how non-conflicting edits merge into the canonical store · *LLDs close enough of the solution space* (leaves open edges an agent must guess)
- **F5 (medium):** The HLD's Architecture is one sentence and there are no Key Design Decisions or success metrics; the rationale the arrow leans on lives mostly nowhere · *HLD is architecture and rationale* (the HLD carries the durable *why*)
- **F6 (low):** In `SYNC-002` the actor is ambiguous—"the system" could be the device or the sync service—and `[x]` status markers are used with no defined legend · *scope disambiguation* (universal-sounding specs must be unambiguous if a second variant appears)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 specs (`SYNC-001`, `SYNC-002`)
- No arrow overlay (`docs/arrows/` absent); no code or test files exist, so `@spec` annotation coverage and entry-point placement could not be assessed
- Linkage metric: 0 `@spec` references (no code to carry them)

Want me to walk through these in detail, focus on a priority or theme (e.g. the decision-capture and arrow-completeness pair), or work through a specific finding together?

If you have broader questions about using LID here—where device-store design fits, how to stage tests-first when specs are already written, or mode transitions—I can help with those too.

*Non-interactive defaults taken: Full-mode declared review (no scope excludes); advisory posture honored—no files edited; report rendered inline, not persisted; since the coach asks no questions mid-run, no other prompts were defaulted.*