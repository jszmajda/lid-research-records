# LID Coach — Field Notes

**Posture:** Bootstrapping — a clean, well-formed arrow stub whose two load-bearing decisions are not yet sound.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` declares Full mode and the LID directive block; no scope section needed in Full
- ✓ Mutation hygiene — no history residue, no `[obsolete]` specs, no changelog sections
- ⚠ Arrow completeness — HLD → LLD → EARS exist; the tests and code phases do not
- ⚠ Intent-tree alignment — the `sync` leaf is coherent, but an HLD architecture component has no leaf, and an LLD behavior has no spec
- ⚠ HLD discipline — no implementation detail, but several architecture-level sections are missing
- ✗ Decision capture — the one decision the whole design turns on is recorded with a one-word rationale that hides the cost it accepts

**Headline:** The skeleton is right — hierarchy, ID namespacing, and EARS phrasing are all clean; the fastest wins are finishing the arrow with tests and code, and settling the conflict-resolution decision the LLD's own clock-skew constraint already undermines.

## Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** the arrow stops at EARS — no test files and no implementation exist, yet both specs are marked `[x]` as complete · *canonical arrow shape — each phase exists for every component in scope* (the `[x]` markers claim a phase that was never built)
- **F2 (high):** `SYNC-002` resolves conflicts by device wall-clock, but `sync-design.md:9` states clocks are wrong by minutes and NTP only runs on reconnect — so "later timestamp" can select the older edit · *intent leads; code is compiled output — specs fix the triggered action, so a spec that contradicts a stated constraint propagates the flaw*
- **F3 (high):** the conflict-resolution row (`sync-design.md:23`) records only "Simpler." — a cold reader cannot reconstruct what skew tolerance or tie-break behavior was given up, and would rightly ask to reverse the choice · *decision capture — a live decision needs its reasoning and accepted cost on the page*
- **F4 (medium):** the HLD has no target users, key design decisions, or success metrics section; Goals ("No blocked capture in the field", "Convergent state after reconnect") are aspirations, not measurable metrics · *HLD is architecture and rationale — it carries the why at architecture level*
- **F5 (medium):** HLD Architecture names a "Device-local store" and the problem statement centers on capturing notes, but no LLD or spec owns local capture/storage as an intent component · *effective intent-tree alignment — leaf paths should cover the HLD's architecture concepts*
- **F6 (medium):** the LLD assigns the sync service the behavior "merges them into the canonical store," but no spec covers the service-side merge — only the device-side upload (SYNC-001) · *effective intent-tree alignment — an LLD behavior with no spec is unnamed intent*
- **F7 (medium):** `sync-design.md` leaves solution edges open: behavior on repeated reconnect/retry, idempotency of re-uploaded edits, partial-failure handling, and ordering of multiple pending edits are unspecified · *LLDs close enough of the solution space — two reasonable agents reading this would land on incompatible implementations*
- **F8 (low):** cold-read gaps — "canonical store," "device-local store," and "pending edits" are never defined; the spec file carries no `prefix:` frontmatter and heads itself "# sync specs" · *docs carry current intent, written to be read cold*
- **F9 (low):** the HLD's Architecture section is a one-line list that restates Approach rather than reasoning about boundaries and ownership · *HLD is architecture and rationale*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the entire tracked repository (4 files, 55 lines)
- Enumerated: 1 HLD, 1 LLD (`SYNC`), 1 spec file, 2 EARS specs (SYNC-001, SYNC-002)
- Arrow-path sampled: 0 end-to-end paths — no test or code files exist to complete a path
- Linkage metric: 0 `@spec` annotations, 0 test files, 0 source files; `docs/arrows/` overlay absent, so no index or drift flags to read
- Configuration check: LID directives present, `- Mode: Full` present, no scope declaration (Full mode → out-of-scope section omitted)
- Cold-read and decisions-table sweeps were run over all three design docs; the LLD's two Decisions rows were both re-examined against the HLD

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken (non-interactive run):* kept the skill's advisory posture, so no project files were edited and the report was rendered inline rather than persisted to disk; no user checkpoints were paused on — the skill's instruction to route configuration changes to `/update-lid` and structural enumeration to `/arrow-maintenance` was preserved in the findings rather than acted on.