Now I have a complete picture of the project. Let me run the full lid-coach review.

---

# LID Coach Review Report

## Executive Summary

**Posture line.** *Bootstrapping — arrow in place through specs, tests and code phases not yet authored.*

**Scorecard**
- ✓ Linkage hygiene — spec IDs align with LLD prefix, grep-anchored
- ✓ HLD discipline — architecture and rationale only, no implementation detail
- ✓ Effective intent-tree alignment — HLD → LLD → specs trace cleanly
- ⚠ Arrow completeness — tests and code phases missing; arrow stops at EARS
- ⚠ Decision capture — conflict resolution decision contradicts stated context (clock skew)
- ⚠ Tenet quality — single tenet is valid but minimal; could capture more tie-breakers

**Headline sentence.** The arrow is real and well-linked across the one active component; the fastest wins are authoring tests and code to complete the arrow, and strengthening the conflict-resolution decision record to acknowledge the clock-skew tension the LLD itself describes.

---

## Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Arrow stops at EARS — no tests and no code exist for the SYNC segment. *canonical arrow shape — with a recursive design layer* (the canonical phases are HLD → LLD → EARS → Tests → Code; collapsing or skipping phases without documentation is a deviation). The cascade cannot be verified end-to-end, and behavioral specs have no executable check. Consider authoring tests citing SYNC-001 and SYNC-002 first, then implementing the sync logic.

- **F2 (high):** The LLD's Context states "Field devices' clocks are frequently wrong by several minutes," yet the Decisions table chooses last-writer-wins by device wall-clock with rationale only "Simpler." *docs carry current intent, written to be read cold* — a decision that stays live once landed (a cold reader would question it given the clock-skew context) but survives with a rationale that doesn't address the stated problem. This is an under-captured decision. Consider expanding the row to name the rejected alternative (e.g., server-time or vector-clock ordering) and the accepted cost (possible data loss when clocks diverge), or add a decision doc if the trade-off warrants a debated record.

- **F3 (medium):** HLD has only one tenet ("Boring over clever"). *tenets capture forward-looking preference* — a Full-mode HLD benefits from multiple tie-breakers that narrow future decisions (e.g., offline-first vs. online-first, local durability vs. sync latency). The current tenet is a valid lean (defensible opposite: "novel over proven"), but the space is under-constrained. Consider adding 1–2 more tenets that reflect actual architectural trade-offs the project has made or will make.

- **F4 (medium):** LLD is thin on operational detail — no mention of retry policy, backoff, partial upload handling, or what happens when the sync service is unavailable. *LLDs close enough of the solution space* — under-specified edges become agent guesswork. Consider expanding the Architecture section with these behaviors, then adding corresponding EARS specs.

- **F5 (medium):** No `@spec` annotations exist anywhere (no code or tests to carry them). *@spec annotations at entry points* — when code arrives, annotations must land at entry points, not helpers, so the arrow stays walkable. Plan to add `@spec SYNC-001` and `@spec SYNC-002` on the top-level sync functions when implementing.

- **F6 (low):** Full mode declared but only one LLD exists; the rest of the repo is empty. *mode fit* — Full mode matches a project that intends to cover the whole repo; if the active LID surface will stay small, consider Scoped mode to reduce perceived overhead. `/update-lid` handles the transition.

---

## What was audited

- Read fully: CLAUDE.md (instruction file), docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 EARS specs (SYNC-001, SYNC-002)
- Arrow-path sampled: 1 segment end-to-end (HLD → LLD → EARS); Tests and Code phases absent
- Linkage metric: 0 `@spec` references (no code/tests), 2 unique spec IDs
- No arrow-maintenance overlay present (`docs/arrows/` absent)
- No code or test files found in the repository

---

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.