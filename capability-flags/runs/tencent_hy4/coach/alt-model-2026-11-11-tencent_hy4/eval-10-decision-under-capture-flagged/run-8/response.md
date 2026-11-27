# LID Coach — Project Review (2026-11-11)

## Executive summary

**Posture:** Healthy, compact arrow — with one live decision at the sync leaf left under-explained.

**Scorecard**
- ✓ Linkage & intent-tree alignment — `SYNC` prefix traces cleanly HLD → LLD → specs; IDs unique, zero-padded, EARS-compliant.
- ✓ Mutation hygiene / cold-read — docs stand alone; no change-narration, fossils, or obsolete specs kept beside replacements.
- ✓ HLD discipline & tenet quality — lean architecture-and-rationale doc; one real tie-breaker ("Boring over clever"), no implementation detail bleeding upstream.
- ⚠ Tenet cascade — a documented operating condition undercuts a stated goal at the sync leaf.
- ⚠ Decision capture — one Decisions row leaves a choice a cold reader would question under-explained.
- ⚠ Arrow completeness — no test/code phase; specs marked `[x]` with zero `@spec` linkage.

**Headline:** The arrow is real and cleanly linked across HLD → LLD → EARS, and the docs read cold with no residue; the single most valuable next step is to resolve the clock-skew vs. last-writer-wins tension at the sync leaf, where the HLD goal and the LLD's Decisions row disagree.

## Findings (4 total · 2 high · 1 medium · 1 low)

- **F1 (high):** Goal *"Convergent state after reconnect"* is undercut by *last-writer-wins by device wall-clock* under the condition the LLD itself documents (*"clocks are frequently wrong by several minutes; they resync NTP only when connectivity returns"*) — a fast-clock device's older edit beats a genuinely-later slow-clock edit, which is silently discarded, and no Decisions row records the trade-off; consider recording the exception (or revisiting the ordering) · *tenets capture forward-looking preference* — tenets and goals pre-narrow the choices no spec anticipates, so a leaf design should not work against them under a described condition.
- **F2 (high):** The *"Conflict resolution → Last-writer-wins by device wall-clock → Simpler"* row leaves a cold reader unable to reconstruct what was given up (skew-tolerant ordering) or why the cost (discarded later edits) is acceptable; the choice also looks technically off, which is its own design concern and makes the capture gap stronger, so consider a fuller row naming the alternative and the cost · *docs carry current intent* — a doc must stand on its own for a reader with no memory of the chat that produced it.
- **F3 (medium):** The arrow stops at EARS — no test layer, no code, zero `@spec` annotations, yet both specs carry `[x]` "done" markers; if docs-only is intentional this is fine, otherwise consider aligning the markers with a tests+code phase so a spec marked complete isn't an orphan · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase walkable; *tests carry @spec annotations* — each test cites the spec it protects.
- **F4 (low):** No tie-break is defined when two offline edits carry equal wall-clock timestamps (`SYNC-002` / "Conflict handling"); consider a deterministic rule · *LLDs close enough of the solution space* — specific enough that two agents land compatibly without copying code.

## What was audited

- Read fully: `CLAUDE.md` (instruction file), `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`.
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 EARS specs (`SYNC-001`, `SYNC-002`), 2 Decisions-&-Alternatives rows.
- Cold-read pass over all four LID docs; decisions-table sweep on both rows ("Note storage / SQLite" passes the cold-reader test; "Conflict resolution / LWW" does not).
- Code/tests: no code or test files exist in the repo; `@spec` references: 0; no `docs/arrows/` overlay (no `index.yaml`). Sampling was by judgment — the `sampling.md` thresholds (>15 LLDs, >200 `@spec` files, overlay present) were not met, so no end-to-end code arrow path could be sampled.
- Dispatch: fully configured (LID directives + `- Mode: Full` + HLD + `docs/intent/`), so a full review; Full mode, so no out-of-scope paths.

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Run defaults (non-interactive): full review taken (project fully configured; no reduced-review or corrupt-index branch reached); declared `- Mode: Full` honored, so the "default Full when the marker is absent" fallback was not needed; report rendered inline with no disk write and no file changes, per the advisory posture ("do not persist to disk unless the user asks" / "this skill does not edit project files"); the two closing invitations left open with no follow-up selected; sampling by judgment since no overlay and thresholds unmet.*