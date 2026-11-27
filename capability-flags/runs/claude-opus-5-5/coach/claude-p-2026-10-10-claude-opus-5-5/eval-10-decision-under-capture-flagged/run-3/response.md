# LID Coach — Field Notes

## Executive summary

**Posture:** Bootstrapping — the design tree is in place and well-linked, but the arrow stops at specs and one live decision is under-captured.

**Scorecard**
- ✓ Configuration and mode — the LID directives and `Mode: Full` are declared, and Full fits a project this size
- ✓ Linkage — `SYNC-001` and `SYNC-002` resolve through the `prefix: SYNC` frontmatter to one leaf LLD
- ✓ Mutation hygiene — no changelog residue, obsolete markers, or "as discussed" phrasing; the docs read cold
- ⚠ Decision capture — the conflict-resolution row says only "Simpler."
- ⚠ LLD sufficiency — the sync path leaves several edges open
- ✗ Arrow completeness — there are no tests or code, yet both specs are marked `[x]`

**Headline:** The HLD → LLD → specs chain is clean, current, and cheap to walk. The most valuable next step is to revisit the last-writer-wins decision against the clock skew the LLD itself describes, and record what it trades away.

## Findings (7 total · 3 high · 3 medium · 1 low)

- **F1 (high):** The conflict rule keeps the edit with the later device wall-clock time, but the same LLD's Context says device clocks are "frequently wrong by several minutes". A fast clock can therefore beat a genuinely newer edit, and the losing technician's note is discarded without trace. State still converges, so the Goal is met on paper, and *Boring over clever* arguably supports the choice. This is a design concern to weigh, not a tenet conflict. · *LLDs close enough of the solution space* — two agents reading the design should land on compatible, intended behaviour
- **F2 (high):** The Decisions row for conflict resolution gives "Simpler." as its whole rationale, and the table has no alternatives column. A cold reader who notices F1 cannot tell what was considered, whether skew was weighed, or what loss was accepted. · *docs carry current intent, written to be read cold* — a choice a reader would still question needs its trade-off on the page
- **F3 (high):** `SYNC-001` and `SYNC-002` are both marked `[x]`, but the repository has no tests and no code. Consider resetting the markers, or noting in `CLAUDE.md` where the implementation lives if it is in another repository. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, each phase present or its absence explicit
- **F4 (medium):** The sync LLD leaves edges open: what "merges" means, whether conflicts are per note or per field, what happens on a timestamp tie, how deletions are handled, and what happens when an upload fails partway. · *LLDs close enough of the solution space* — open edges are where an implementer guesses
- **F5 (medium):** The HLD names a device-local store, and the Goal "No blocked capture in the field" depends on it, but there is no LLD or spec for capture or storage. The "Note storage: SQLite on device" decision sits in the sync LLD instead. · *effective intent-tree alignment* — every architecture concept traces to a design node and specs
- **F6 (medium):** The HLD is skeletal: Architecture is a single line, and there are no target users, key design decisions, or success metrics. Offline-first and central reconciliation are architecture-level choices with no stated rationale. · *HLD is architecture and rationale* — the HLD carries the long-lived "why"
- **F7 (low):** `SYNC-002` does not say what happens when timestamps are equal or when the same device produced both edits. Tightening it would follow naturally from F1 and F4. · *scope disambiguation* — a spec found by grep alone should be unambiguous

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — these are the only tracked files.
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 specs, 2 Decisions rows, 1 tenet.
- Code and tests: none in the repository, so there are 0 `@spec` references. Annotation placement, tests-first evidence, and semantic legibility could not be assessed.
- Git history: a single commit, so there is no cascade history to read.
- Arrow overlay: `docs/arrows/` is not present, so `/arrow-maintenance` does not apply.
- Non-interactive run: dispatch resolved to a full review with nothing to ask. Per the skill's default, the report is inline only and no project files were edited.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are best taken as a pair.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.