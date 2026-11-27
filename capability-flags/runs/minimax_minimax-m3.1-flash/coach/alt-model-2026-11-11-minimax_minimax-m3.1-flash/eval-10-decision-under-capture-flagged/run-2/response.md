# LID Coach — Field Notes

**Posture:** Bootstrapping — the intent skeleton is clean, but the arrow stops at EARS and one load-bearing decision contradicts the LLD's own stated facts.

> **Scorecard**
> - ✓ **Arrow shape** — depth-2 design tree, canonical phase order, no non-design phases
> - ✗ **Arrow completeness** — the arrow stops at EARS: no tests, no code
> - ✓ **Spec IDs** — `SYNC-001/002` resolve to the `sync` leaf's `prefix:`, zero-padded, grep-friendly, no reuse
> - ✓ **Mutation hygiene** — no change-narration, no obsolete markers, no conversational fossils in any doc
> - ⚠ **HLD discipline** — no implementation bleed upward, but three root sections are missing
> - ⚠ **Decision capture** — the conflict rule records no alternatives and no accepted cost

*What is working:* the intent tree is wired correctly — `parent:`/`prefix:` frontmatter, a leaf folder with a paired `-specs.md`, IDs that grep cleanly, and specs whose WHEN clauses carry their scope explicitly. The docs read cold with no residue. *The single most valuable next step:* before any code lands, reopen the conflict-resolution decision and add the missing EARS coverage — both are cheap now and expensive once implementation hardens them.

## Findings (10 total · 4 high · 4 medium · 2 low)

- **F1 (high):** the arrow stops at EARS — no tests, no source files exist, yet both specs are marked `[x]` (*implemented*) · *canonical arrow shape — HLD → LLD → EARS → Tests → Code*; *tests before code — tests preload the use of the system before implementation exists*
- **F2 (high):** conflict resolution is last-writer-wins by **device wall-clock**, but the LLD's own Context says device clocks are "frequently wrong by several minutes"; the row's rationale is the single word "Simpler" · *docs carry current intent — a decision that survives only as a thin row leaves a cold reader unable to reconstruct what was given up*
- **F3 (high):** the root HLD omits `Target Users`, `Key Design Decisions`, and `Success Metrics`; "Goals" are not falsifiable · *HLD is architecture and rationale — the HLD carries the project-global why*
- **F4 (high):** the flagship behavior — capturing a note locally while offline — has no EARS anywhere; the `SQLite on device` decision has no spec behind it · *effective intent-tree alignment — LLD behaviors with no spec drift silently because there is nothing to test against*
- **F5 (medium):** the LLD leaves the solution space open at merge semantics ("merges them into the canonical store"), upload failure/retry/idempotency, and timestamp tie-breaks — two reasonable agents would land on incompatible implementations · *LLDs close enough of the solution space — under-specified edges are where intent drift enters*
- **F6 (medium):** one tenet ("Boring over clever") covers the whole project, and nothing leans on the tradeoff this component actually faces — offline-first simplicity vs. lossless preservation of field edits · *tenets capture forward-looking preference — the tenet is a tie-breaker for the unforeseen choice, and this is the unforeseen choice*
- **F7 (medium):** the Decisions & Alternatives table omits the "Alternatives Considered" column, and both rationales are a single word ("Simpler.", "Standard embedded store.") · *docs carry current intent, written to be read cold — this table is the sanctioned home for rejected alternatives*
- **F8 (medium):** every spec says "the system SHALL" without naming the actor — device or sync service — so a grep-found spec doesn't say who implements it · *scope disambiguation — a spec found out of context must still be unambiguous*
- **F9 (low):** the spec file deviates from the EARS surface — status markers are backticked (`` `[x]` ``) rather than plain `- [x]`, and the file has no section headings · *minimum surface, maximum discipline — stay on the standard arrow surface*
- **F10 (low):** no `docs/arrows/` overlay is installed — optional, but it is what gives precise structural audits (orphans, drift) later · recommend `/arrow-maintenance` when the tree grows past a few leaves

## What was audited

- Read fully (the entire tracked repo is 4 files): `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD (prefix `SYNC`), 1 spec file, 2 EARS specs — both marked `[x]`
- Linkage metric: **0** `@spec` references, 0 test files, 0 source files — nothing downstream of EARS exists yet, so code-side placement and test-coverage signals could not be sampled
- Cold-read pass performed on both LID docs (no conversation context), plus a decisions-table sweep of all 2 rows against the HLD above them
- Git history: 1 commit (`fixture`) — no change-narration residue to read, and no prior-state drift to compare
- Overlay: absent (`docs/arrows/` not present); the `## LID` block declares `Mode: Full` with `Version: 1.4.0`, and the instruction file's directives are present and coherent
- Depth note: this is a small project, so coverage is complete rather than sampled — nothing was left unread

## Defaults I took (non-interactive run)

- Dispatched on the **declared `Mode: Full`** in `CLAUDE.md`; no `## LID Scope` exists, so all paths were treated as in-scope and the out-of-scope section was omitted per the report structure.
- Where the skill would normally ask, I took the stated default and did not block: I proceeded with a full review rather than pausing, and treated the missing `docs/arrows/` overlay as absent rather than corruption (it does not exist).
- **No files were changed** — the coach is advisory by design (*user is always right — with warning*); the report is rendered inline and not persisted to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.