**LID Coach — Field Notes**

## Executive summary

**Posture:** Well-formed arrow head, unbuilt tail — the design layer is coherent and genuinely linked; the conflict rule is the one place intent and stated goals pull apart.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` carries the `## LID` block, Full mode, v1.4.0; dispatch was unambiguous
- ✓ Intent-tree alignment — `SYNC-001/002` resolve cleanly to the `prefix: SYNC` leaf, which declares `parent: high-level-design`
- ✓ HLD discipline — no schemas, signatures, or pseudocode have crept upstream; the HLD stays architecture-level
- ⚠ Decision capture — the load-bearing conflict-resolution choice is recorded in one word
- ⚠ Tenet/goal cascade — the merge mechanism works against a stated goal under a condition the LLD itself describes
- ✗ Arrow completeness — the arrow stops at EARS; no tests or code exist, yet both specs are marked `[x]`

**Headline:** For a project this young the linkage discipline is already right — specs trace to a real leaf, the leaf names its parent, and the spec IDs are grep-anchored and stable — so the highest-value next move is not more structure but tightening the sync LLD's conflict decision, where the design currently contradicts a goal and the record doesn't say why.

## Findings (8 total · 3 high · 3 medium · 2 low)

- **F1 (high):** `sync-design.md:17` picks the later *device* wall-clock while `sync-design.md:9` states those clocks are routinely minutes off — under that described condition the genuinely later edit is silently discarded, working against the HLD goal "Convergent state after reconnect", with no row recording the exception · *tenet cascade — design nodes should lean the way the HLD's tenets and goals say to lean*
- **F2 (high):** the conflict-resolution row's rationale is "Simpler." — a cold reader holding the clock-skew paragraph would still want to reverse this choice, and can't reconstruct what was given up (server-assigned timestamps? logical clocks? a CRDT?) or what cost was accepted (permanent loss of a real edit) · *docs carry current intent — keep the live decision's reasoning, not just its outcome*
- **F3 (high):** both specs carry `[x]` while the repo holds no tests and no code, so the status markers assert a downstream state that doesn't exist and the Tests and Code phases are absent rather than deliberately deferred · *coherence is adjacency — each level agrees with the one next to it*; *canonical arrow shape*
- **F4 (medium):** `high-level-design.md:13` names three architecture pieces (device-local store, sync service, reconciliation) but only sync has a design node — the store that makes "No blocked capture in the field" true has no LLD and no specs · *effective intent-tree alignment*
- **F5 (medium):** the HLD has no Key Design Decisions and no success metrics, so the two goals at line 21 state a direction without anything that would tell you they were met · *HLD is architecture and rationale*
- **F6 (medium):** "the losing edit is discarded" leaves the user-visible consequence off the page entirely — a cold reader can't tell whether the technician is told, whether the loss is recoverable, or whether silence is intended · *docs carry current intent, written to be read cold*
- **F7 (low):** the LLD Architecture section (line 13) restates the HLD Approach (line 9) nearly verbatim, so neither earns its place; the leaf could spend those lines on the merge contract instead · *LLDs close enough of the solution space*
- **F8 (low):** the LLD describes the non-conflicting merge path ("merges them into the canonical store") with no spec covering it — only the conflict case is spec'd · *effective intent-tree alignment*

A note on F1: the choice is consistent with your "Boring over clever" tenet, which is genuinely well-formed — defensible opposite, a lean rather than a trigger. The tension is with the *goal*, not the tenet, which is exactly the case tenets alone can't arbitrate.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the project's entire file inventory outside `.git`
- Enumerated: 1 HLD, 1 leaf LLD, 1 spec file, 2 EARS specs, 2 Decisions & Alternatives rows
- Arrow-path sampled: 1 segment, end to end (HLD Approach/Architecture → `SYNC` leaf → `SYNC-001/002` → *no tests* → *no code*)
- Linkage metric: 0 `@spec` annotations across 0 code and test files; no `docs/arrows/` overlay present, so no structural index was available
- Cold-read pass: all 4 docs
- Non-interactive run: no dispatch ambiguity arose, so no prompts were defaulted; per the skill's default the report was rendered inline and not written to disk

---

Want me to walk through the findings in detail, focus on a theme or priority (the conflict-resolution cluster F1/F2/F6 is the densest thread), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — when to promote `sync` to a sub-HLD, where the device-store component should sit in the tree, how status markers should behave before code exists, or whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.