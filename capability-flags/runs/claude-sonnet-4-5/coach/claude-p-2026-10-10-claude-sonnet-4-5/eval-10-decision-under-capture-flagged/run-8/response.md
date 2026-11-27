# LID Coach Report

## Executive Summary

**Posture:** Bootstrapping — clean configuration, intent docs present, implementation phases absent.

**Scorecard**
- ✓ Configuration — Full mode declared, directive block in place
- ✓ Mutation hygiene — docs carry current intent with no history residue
- ✓ Linkage structure — spec IDs follow SYNC prefix convention
- ⚠ Arrow completeness — Tests and Code phases entirely missing
- ✗ LLD sufficiency — under-specified, leaves solution edges open
- ✗ Decision capture — critical clock-skew tension unaddressed in rationale

**Headline:** The project has clean LID configuration and docs that carry current intent without accumulation drift; the highest-value next steps are closing the solution space in the sync LLD and completing the arrow through Tests and Code.

## Findings (5 total · 3 high · 2 medium)

- **F1 (high):** Arrow incomplete — Tests and Code phases entirely absent · *canonical arrow shape*
- **F2 (high):** Clock-skew contradiction unresolved in decision capture — LLD states clocks are "frequently wrong by several minutes" but conflict resolution uses device wall-clock timestamps; Decisions table rationale ("Simpler") doesn't address what was traded or why the contradiction is acceptable · *decision capture; docs carry current intent*
- **F3 (high):** Sync LLD under-specified — leaves critical edges open (edit format, pending-edit detection, merge semantics, note identity, discarded-edit handling); two reasonable agents would produce incompatible implementations · *LLDs close enough of the solution space*
- **F4 (medium):** Decisions table entries too terse — "Simpler" and "Standard embedded store" don't capture alternatives considered or costs accepted; a cold reader can't reconstruct what was given up · *decision capture*
- **F5 (medium):** HLD extremely sparse — present sections are architecture-level (correct), but Goals/Non-Goals are one-line bullets and no Key Design Decisions section exists; not wrong, but minimal for a Full-mode project · *HLD is architecture and rationale*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 LLD, 1 spec file containing 2 specs (SYNC-001, SYNC-002)
- Arrow coverage: HLD → LLD → EARS present; Tests and Code phases absent
- Project footprint: 4 files total (excluding .git)

## Findings Detail

**F1 — Arrow incomplete:** The canonical LID arrow is `HLD → LLDs → EARS → Tests → Code`. This project has the first three phases (HLD, one LLD, one spec file) but no tests or code whatsoever. Without tests citing specs via `@spec` annotations and code implementing those specs, the arrow isn't walkable end-to-end, and the intent-to-implementation linkage that makes LID effective is missing. The specs exist but aren't verified or implemented.

**F2 — Clock-skew contradiction unresolved:** The sync LLD's Context section explicitly states "Field devices' clocks are frequently wrong by several minutes," yet the Conflict Handling section chooses last-writer-wins by device wall-clock timestamp. A cold reader holding these two facts would immediately question how this can work — if clocks are wrong, timestamps can't reliably order edits. The Decisions table entry for this choice gives rationale as "Simpler" without addressing the alternative that was rejected (vector clocks? Lamport timestamps? Server-assigned order?) or acknowledging the cost (incorrect conflict resolution when clocks are skewed). This looks like either an intent gap (the design doesn't see the contradiction) or a deliberate trade-off that was never written down. Either way, the decision isn't captured well enough for a future reader to understand why the contradiction is acceptable.

**F3 — Sync LLD under-specified:** The LLD says "Each device uploads its pending edits on reconnect; the sync service merges them into the canonical store" but leaves these edges open: What format are edits (full note snapshots? deltas? operation logs)? How does a device determine which edits are "pending"? What does "merge" mean algorithmically? How is "same note" determined (by ID? by content hash?)? What happens to a discarded edit (logged? surfaced to user? silent loss)? Two agents reading this LLD could reasonably choose JSON patches vs. operational transforms, optimistic vs. pessimistic locking, different note-identity mechanisms, and produce implementations that are incompatible. A good LLD closes enough solution space that agents land on compatible implementations without reproducing code — this one is too open.

**F4 — Decisions table too terse:** Both Decisions entries ("Simpler" for conflict resolution, "Standard embedded store" for SQLite) state the chosen option but don't capture what was compared against or what cost was accepted. "Simpler than what?" isn't answerable from the table. A cold reader can't reconstruct the design space that was considered. The Decisions & Alternatives table exists to help future sessions understand what was given up — these entries don't carry that.

**F5 — HLD extremely sparse:** The HLD is correctly architecture-level (no implementation detail), but Goals is a single sentence, Non-Goals is a single sentence, and there's no Key Design Decisions section. Tenets has one entry (valid). For a Full-mode project this is minimal. It's not *wrong* — nothing in the HLD violates HLD discipline — but it's at the lower bound of what "architecture and rationale" usually means. If this is an early-stage project, this may be fine; if the project has grown beyond this HLD, consider fleshing out the rationale layer.

## Next Steps by Priority

**High priority** — blocks the arrow from being walkable or leaves design contradictions unresolved:
1. Complete the arrow through Tests and Code (F1)
2. Resolve or document the clock-skew contradiction in the sync LLD's Decisions table (F2)
3. Close the solution space in the sync LLD — specify edit format, merge semantics, note identity, and discarded-edit handling (F3)

**Medium priority** — weakens coherence without breaking the arrow:
4. Expand Decisions table entries to capture alternatives and costs (F4)
5. Assess whether the HLD's brevity matches project maturity; if the project has grown, consider adding Key Design Decisions (F5)

---

Want me to walk through any of these findings in detail, suggest specific language for the Decisions table, or help close the solution space in the sync LLD? You can also ask about a specific finding.

If you have broader questions about using LID for your project — how to know when an LLD is "specified enough," when to promote a leaf to a sub-HLD, or how decision capture should scale as a project matures — I can help with those too.