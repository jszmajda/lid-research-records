# LID Coach — Field Notes

## Executive summary

**Posture:** Bootstrapping — the design half of the arrow is in place and clean, but it stops at specs, and one live decision is under-captured.

**Scorecard**
- ✓ Configuration and mode — `## LID` block, Full mode, and the standard directories are all present and coherent
- ✓ Linkage and tree alignment — `SYNC-001/002` resolve to the `SYNC` leaf via its `prefix:` frontmatter, the LLD names its parent, and the spec file points back at the LLD
- ✓ Mutation hygiene — no history residue, obsolete markers, or planning text; every doc reads as current intent
- ⚠ Decision capture — the conflict-resolution row says only "Simpler."
- ⚠ LLD sufficiency and coverage — the sync LLD leaves several edges open, and the device-side half of the HLD has no design node
- ✗ Arrow completeness — no tests or code in the repository, yet both specs are marked `[x]`

**Headline:** The skeleton is right — one HLD, a correctly prefixed leaf, well-formed EARS specs, and nothing stale. The most valuable next step is to revisit the conflict-resolution decision and record what it trades away, because the LLD's own Context section undercuts it.

## Findings (8 total · 3 high · 4 medium · 1 low)

- **F1 (high):** Last-writer-wins relies on device wall-clocks that the same LLD says are "frequently wrong by several minutes". The edit that wins may not be the later one, and the loser is discarded with no trace, so a technician's captured note can vanish silently. This is a design concern in its own right. · *LLDs close enough of the solution space* — a design should hold under the conditions it describes
- **F2 (high):** The conflict-resolution row's rationale is "Simpler." A cold reader who sees the clock-skew sentence will question this choice, and cannot tell what alternatives were weighed or whether the data loss was accepted knowingly. · *docs carry current intent, written to be read cold* — a decision that stays contestable needs its trade-off on the page
- **F3 (high):** `SYNC-001` and `SYNC-002` are marked `[x]`, but the repository has no tests, no code, and no `@spec` annotations. Either the markers are ahead of reality or the implementation lives somewhere the arrow cannot reach. · *canonical arrow shape* — HLD → LLD → specs → tests → code, each phase present or its absence explicit
- **F4 (medium):** The HLD goal "No blocked capture in the field" and the "device-local store" architecture element have no LLD and no specs. Half the stated intent has nothing to test against. · *effective intent-tree alignment* — every HLD concept traces down to a design node and specs
- **F5 (medium):** The "Note storage: SQLite on device" decision sits in the sync LLD, though it belongs to the device store. Consider moving it when that node exists (see F4). · *intent attaches at the lowest node that dominates it* — a decision lives with the component it governs
- **F6 (medium):** The sync LLD leaves edges open that two implementers would close differently:
  - equal timestamps;
  - which timestamp counts (edit time or upload time);
  - deletes versus edits;
  - interrupted or repeated uploads;
  - what "pending" means;
  - whether the technician is told an edit lost.
  
  · *LLDs close enough of the solution space* — specific enough that two agents land on compatible implementations
- **F7 (medium):** The HLD is one line per section and has no target users, key design decisions, or success metrics. "Convergent state after reconnect" is not defined, in particular whether converging by dropping an edit counts. · *HLD is architecture and rationale* — the HLD carries the why that leaf designs lean on
- **F8 (low):** The single tenet, "Boring over clever", is a real tie-breaker, and last-writer-wins follows it. It gives no lean on the tension F1 exposes, simplicity versus never losing a captured note. Consider a second, ordered tenet. · *tenets capture forward-looking preference* — tenets pre-decide the calls no spec anticipated

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the whole tracked repository (4 files, 1 commit)
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 spec IDs, 2 Decisions & Alternatives rows
- Decisions sweep: the "Note storage" row passes as written (placement aside, F5); the "Conflict resolution" row is F2
- Code and tests: none present, so `@spec` placement, tests-first evidence, and semantic legibility could not be assessed (0 `@spec` references)
- Arrow overlay: `docs/arrows/` is not installed, so no structural audit inputs
- Dispatch: fully configured, so a full review; no prompts were needed in this non-interactive run

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 pair naturally.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.