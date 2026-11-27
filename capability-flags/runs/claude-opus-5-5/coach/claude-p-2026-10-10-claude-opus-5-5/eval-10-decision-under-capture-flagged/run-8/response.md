# LID Coach — Field Notes

## Executive summary

**Posture:** *Bootstrapping — clean design chain in place, with one live decision under-recorded and nothing downstream of the specs.*

**Scorecard**
- ✓ Configuration and mode — `## LID` block, Full mode, HLD and `docs/intent/` are all present, and Full fits a project this size
- ✓ Linkage — `prefix: SYNC` in the LLD frontmatter matches the spec IDs, the spec file points back at its LLD, and both specs are well-formed EARS
- ✓ Mutation hygiene — no changelog residue, obsolete markers or "was X, now Y" narration anywhere
- ⚠ Decision capture — the conflict-resolution row says only "Simpler."
- ⚠ LLD sufficiency — the sync design leaves several edges open, including how devices receive merged state
- ✗ Arrow completeness — both specs are marked `[x]`, but the repo has no tests and no code

**Headline:** The HLD → LLD → specs chain is coherent, and the LLD honestly records that device clocks are often wrong by several minutes. The most valuable next step is to revisit the conflict-resolution choice in light of that clock fact, and write down what it trades away.

## Findings (8 total · 3 high · 3 medium · 2 low)

- **F1 (high):** Conflict resolution picks the winner by device wall-clock, yet the same LLD's Context says those clocks are off by minutes. Under skew, an older edit can win and a technician's newer note is silently discarded. · *LLDs close enough of the solution space* — a design should hold under the conditions its own doc describes.
- **F2 (high):** The "Last-writer-wins by device wall-clock" row gives "Simpler." as its whole rationale. A cold reader can't tell simpler than what, or that losing field edits was a cost knowingly accepted. · *docs carry current intent, written to be read cold* — a decision a reader would still question needs its alternatives and accepted cost on the page.
- **F3 (high):** `SYNC-001` and `SYNC-002` are marked `[x]`, but the repo contains no tests, no code and no `@spec` annotations. Consider resetting the markers, or noting in `CLAUDE.md` where the implementation lives. · *canonical arrow shape* — intent flows HLD → LLD → specs → tests → code, and a status marker is a claim about the downstream phases.
- **F4 (medium):** The HLD goal "Convergent state after reconnect" has only an upload path (`SYNC-001`). No design or spec covers how merged state gets back to devices. · *effective intent-tree alignment* — every goal should trace down to specs that can be tested.
- **F5 (medium):** The Conflict handling section leaves open what happens on equal timestamps, whether the unit is the whole note or a field, how deletes interact with edits, and whether the losing device is told. · *LLDs close enough of the solution space* — two agents reading the LLD should land on compatible implementations.
- **F6 (medium):** The HLD names a device-local store, and "No blocked capture in the field" is a goal, but neither has an LLD or specs. The "Note storage: SQLite on device" decision sits in the Sync LLD instead. · *one LLD per intent component* — each "thing" a user would name gets its own design node.
- **F7 (low):** The HLD's Architecture is a single line, and there are no Key Design Decisions, target users or success metrics. The local-first choice and its rationale are a natural candidate to record there. · *HLD is architecture and rationale* — the HLD carries the long-lived "why".
- **F8 (low):** The one tenet, "Boring over clever", is a real tie-breaker, and last-writer-wins is consistent with it. It doesn't cover this project's sharpest trade-off, simplicity versus never losing a captured note; consider a second, ordered tenet. · *tenets capture forward-looking preference* — a tenet pre-decides the choice no spec anticipated.

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the whole repository (4 files, 1 commit).
- **Enumerated:** 1 HLD, 1 LLD, 1 spec file with 2 specs, 2 Decisions & Alternatives rows, 0 `[inferred]` markers.
- **Code and tests:** none exist, so `@spec` placement, tests-first evidence and code naming could not be reviewed.
- **Arrow overlay:** `docs/arrows/` is not installed, so there was no index to review.
- **Decisions sweep:** the "Note storage: SQLite on device" row passes as written; the conflict-resolution row is F2.
- **No files were changed:** this review is advisory, and the report was not saved to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into — F1 and F2 are best taken as a pair.

If you have broader questions about using LID for this project — where a PRD fits, when to split Sync into more nodes, how to stage tests before code, or what to do as the design grows — I can help with those too.