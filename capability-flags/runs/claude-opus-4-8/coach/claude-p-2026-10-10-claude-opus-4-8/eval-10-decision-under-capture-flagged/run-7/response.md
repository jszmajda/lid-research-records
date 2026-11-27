# LID Coach Review — Field Notes

**Posture:** *Clean design layer; the arrow stops short of code, and one load-bearing decision needs tightening.*

**Scorecard**
- ✓ **Mutation hygiene** — docs read cold cleanly; no history residue, planning text, or obsolete markers
- ✓ **Linkage** — spec IDs (`SYNC-001/002`) are grep-clean and the `SYNC` prefix matches the leaf's `prefix:` frontmatter
- ✓ **Tenets** — "boring over clever" is a real tie-breaker with a defensible opposite, not a platitude
- ✓ **Mode fit** — Full matches a single-component greenfield project
- ⚠ **Arrow completeness** — HLD → LLD → EARS is in place; the Tests and Code phases don't exist yet
- ⚠ **Decision capture** — the conflict-resolution choice is under-documented against the LLD's own stated context

**Headline:** The design layer is genuinely coherent — one HLD, one well-scoped LLD, two EARS specs that trace cleanly to it, and docs that carry current intent without residue. The two fastest wins: extend the arrow past EARS into tests + code, and tighten the one decision whose rationale fights the context the doc itself supplies.

---

**Findings (4 total · 1 high · 2 medium · 1 low)**

- **F1 (high):** `SYNC-001/002` are marked `[x]` (complete), but no Tests or Code phase exists anywhere and nothing cites the specs · *canonical arrow shape* + *tests before code* — the arrow is walkable only as far as EARS, so there's no edge-detection between intent and a running system, and "complete" currently asserts intent, not verified behavior.
- **F2 (medium):** Last-writer-wins by *device wall-clock* contradicts the LLD's own Context ("devices' clocks are frequently wrong by several minutes") · design-correctness concern — a later real edit can silently lose to an earlier one whose device clock ran fast, discarding captured field data. This is a live design question a cold reader would immediately raise.
- **F3 (medium):** The Decisions & Alternatives row for conflict resolution reads only "Simpler." · *docs carry current intent* (keep-side) — a cold reader holding the Context can't reconstruct what was traded away (accuracy under known-bad clocks) or what cost was accepted (lost edits). The row should name the clock-skew trade-off it's making, or the choice should change (F2).
- **F4 (low):** Conflict handling leaves edges open — ties on equal timestamps, merges across three or more devices, and what counts as a "pending edit" · *LLDs close enough of the solution space* — two reasonable agents could implement these corners differently, which is where drift enters.

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 specs). No arrow overlay (`docs/arrows/` absent). No code or test files present in the repo.
- Sampled by judgment (small project, well under the sampling thresholds); cold-read pass and Decisions-table sweep run over all four docs.

---

Want me to walk through any of these in detail, focus on a priority tier, or work through a specific item — say, rewriting the conflict-resolution decision or sketching the first tests for `SYNC-001/002`? Just name one and we'll dig in.

If you have broader questions about using LID here — when to split `sync` into its own sub-tree as it grows, how status markers should track an arrow that hasn't reached code yet, or mode choice as the project expands — I can help with those too.